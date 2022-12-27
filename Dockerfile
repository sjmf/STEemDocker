# Docker image to use with Vagrant
# Aims to be as similar to normal Vagrant usage as possible
# Adds Puppet, SSH daemon, Systemd
# Adapted from https://github.com/BashtonLtd/docker-vagrant-images/blob/master/ubuntu1404/Dockerfile
#
# Run with `docker build -t "samfinnigan/vagrant-ubuntu" .`
#          `docker run -d --name vagrant-ubuntu samfinnigan/vagrant-ubuntu`

FROM ubuntu:22.04
ENV container docker
RUN apt-get update -y && apt-get dist-upgrade -y

# Install system dependencies, you may not need all of these
RUN apt-get install -y --no-install-recommends software-properties-common \
            ssh sudo libffi-dev systemd openssh-client gpg gpg-agent git wget

# Needed to run systemd
# VOLUME [ "/sys/fs/cgroup" ]
# Doesn't appear to be necessary? See comments

RUN apt-get -y install puppet

# Add vagrant user and key for SSH
RUN useradd --create-home -s /bin/bash vagrant
RUN echo -n 'vagrant:vagrant' | chpasswd
RUN echo 'vagrant ALL = NOPASSWD: ALL' > /etc/sudoers.d/vagrant
RUN chmod 440 /etc/sudoers.d/vagrant
RUN mkdir -p /home/vagrant/.ssh
RUN chmod 700 /home/vagrant/.ssh
RUN echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ==" > /home/vagrant/.ssh/authorized_keys
RUN chmod 600 /home/vagrant/.ssh/authorized_keys
RUN chown -R vagrant:vagrant /home/vagrant/.ssh
RUN sed -i -e 's/Defaults.*requiretty/#&/' /etc/sudoers
RUN sed -i -e 's/\(UsePAM \)yes/\1 no/' /etc/ssh/sshd_config

# Start SSH
RUN mkdir /var/run/sshd
EXPOSE 22
RUN /usr/sbin/sshd

# Add App
WORKDIR /app

# Steem dependencies
RUN apt-get install -y libpulse0 libxxf86vm1 libasound2 libx11-6 libxext6 libportaudio2
RUN apt-get install -y build-essential make

RUN wget https://www.kryoflux.com/download/spsdeclib_5.1_source.zip
RUN unzip spsdeclib_5.1_source.zip
RUN unzip capsimg_source_linux_macosx.zip
WORKDIR /app/capsimg_source_linux_macosx/CAPSImg
RUN chmod u+x configure
RUN ./configure
RUN make
RUN make install
RUN ln -s /usr/local/lib/libcapsimage.so.5.1 /usr/local/lib/libcapsimage.so.5
RUN ldconfig

WORKDIR /app
RUN wget https://sourceforge.net/projects/steemsse/files/Steem%20SSE%204.1/v4.1.2/Steem.SSE.4.1.2.Linux64.R5.zip
RUN unzip Steem.SSE.4.1.2.Linux64.R5.zip
RUN mv /app/Steem.SSE.4.1.2.Linux64/* /app/
RUN chmod +x steem64
ENV PULSE_SERVER host.docker.internal

# Start Systemd (systemctl)
SHELL ["/usr/bin/bash"]
#CMD ["/lib/systemd/systemd"]
CMD ["/app/steem64"]

