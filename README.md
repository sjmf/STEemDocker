# WIP: Run STEem Atari STe emulator on OSX under Docker

Currently non-working.

NB: Intel Macs only currently supported. YMMV using Rosetta on ARM Macs.

You will need:

 * (XQuartz)[https://www.xquartz.org/]
 * (PulseAudio)[https://www.freedesktop.org/wiki/Software/PulseAudio/]
 * (Docker Desktop)[https://docs.docker.com/desktop/install/mac-install/]

Run:

```
brew install pulseaudio
brew install --cask xquartz

pulseaudio --load=module-native-protocol-tcp --exit-idle-time=-1 --daemon

xhost +localhost

docker compose build
docker compose up -d
```

STEem runs but does not show display output in the window. Perhaps this is because
direct draw is not accessible from a container?


### Sources:

 * https://stackoverflow.com/a/50939994/1681205

