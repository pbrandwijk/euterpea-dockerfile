# Euterpea Dockerfile

Euterpea2 is a Haskell library that provides a framework for programming music. The library is currently not maintained, but if you want to do the exercises of the book Haskell School of Music, then you need some way to make it run. This Dockerfile aims to make that process easier, by setting all needed software up in a Docker container.

## Pulling the container from ghcr.io

Pull the docker image from GHCR:

```
docker pull ghcr.io/pbrandwijk/euterpea-dockerfile:main
```

Go to the folder where you store your Haskell code for Euterpea and start the container with fluidsynth running in the background:

```
docker run -it --name euterpea -d --device /dev/snd --group-add audio -v ${PWD}:/home/haskell/src/ ghcr.io/pbrandwijk/euterpea-dockerfile:main fluidsynth /usr/share/sounds/sf2/FluidR3_GM.sf2
```

Now you can open a bash shell on the container and run GHCi inside it:

```
docker exec -it euterpea /bin/bash 
```


## Building the container locally

```
docker build --no-cache --progress=plain -t haskell-euterpea .
```

- Use `--no-cache` to build everything from scratch, or leave it out to reuse what was already built.
- Use `--progress=plain` to get a complete output of the console while building, which is helpful for debugging.


## Running the docker container from local build

The container can be run in one go like so:

```
docker run -it --device /dev/snd --group-add audio -v ${PWD}:/home/haskell/src/ haskell-euterpea:latest
```

- The `--device /dev/snd` makes the sound device available to alsa.
- The `--group-add audio` adds the container user to the `audio` group.
- The `-v ${PWD}:/home/haskell/src/` mounts the current directory to `/home/haskell/src`

Inside the container you could start fluidsynth in the background:

```
fluidsynth /usr/share/sounds/sf2/FluidR3_GM.sf2 &
```

The problem is that as soon as the job goes to the background, the process is paused (marked as Stopped in `jobs`). Any midi output sent to it 
will still be processed, but only when the job comes to the foreground again. This is cumbersome.

To keep fluidsynth active, first start the container in detached mode running fluidsynth:

```
docker run -it --name euterpea -d --device /dev/snd --group-add audio -v ${PWD}:/home/haskell/src/ haskell-euterpea:latest fluidsynth /usr/share/sounds/sf2/FluidR3_GM.sf2
```

Now find the name of the created container:

```
docker container ls
```

Now execute a new bash session on the container, leaving the fluidsynth process active:

```
docker exec -it <container name> /bin/bash
```

If this fails saying that the device is busy, you probably have another container active that also uses the device.

Now in the container you can start `ghci`:

```
$ ghci
> import Euterpea
> devices
```

Pick the device `OutputDeviceID <number>   Synth input port (1:0)`. Use the number as an argument to the `playDev` function:

```
Prelude Euterpea> playDev 4 $ c 4 qn
```

## Alternative sound card

Find the card and device with `aplay -l` and `aplay -L`

Add the following config (adapt numbers):

```
echo -e "defaults.pcm.card 2;\ndefaults.pcm.device 3;" > .asoundrc
```

Now run the programs with the appropriate name, like:

```
speaker-test -D hdmi:NVidia
aplay -D plughw:NVidia /path/to/sample.wav
fluidsynth -a alsa -o audio.alsa.device=hdmi:NVidia /usr/share/sounds/sf2/FluidR3_GM.sf2 /usr/src/song.mid
```
