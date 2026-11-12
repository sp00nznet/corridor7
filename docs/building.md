# Building by hand

`Setup.cmd` runs exactly these steps; this is the same thing command by command.

## Prerequisites

Windows 10/11, **Python 3.8+** (`py -3 --version`; the lifter needs no
packages), **CMake 3.20+**, **git**, **Visual Studio 2022** (or its Build
Tools) with *Desktop development with C++*, and the pcrecomp toolkit, `main`
branch, cloned **beside** this repository as `pcrecomp` (or `PCRECOMP_HOME`
set to one):

```
some-folder\
  pcrecomp\     <- git clone -b main https://github.com/sp00nznet/pcrecomp
  corridor7\    <- this repository
```

## Steps

1. Copy everything in the CD's `CORR7CD` folder, and `CORR7.ID` from the CD's
   root, into `original\c7\`.
2. Lift it:
   ```
   py -3 tools\lift.py c7
   ```
   It writes `work\c7\gen\`: 869 functions.
3. Build it:
   ```
   cmake -B build -G "Visual Studio 17 2022" -A Win32
   cmake --build build --config Release
   ```
4. Check the hardware models (no game data needed):
   ```
   build\Release\selftest.exe
   ```
   Expected: `selftest: all passed`.
5. Run it: `build\Release\corridor7.exe`.

The game finds "its CD" in drive D: and reads it from `original\c7`. Saved
games and `CONFIG` go to `saves\c7`.

The usual trip-ups: `python` opening the Microsoft Store (that is Windows'
alias placeholder; use `py -3`, or turn the alias off in *Settings > Apps >
Advanced app settings > App execution aliases*), and a freshly installed CMake
or Python not being on `PATH` until you open a new window.

## Command line

```
build\Release\corridor7.exe                    # play, in a window
build\Release\corridor7.exe --fullscreen       # Alt+Enter toggles
```

| Flag | |
|---|---|
| `--data DIR`, `--save DIR` | the game's files (default `original/c7`); CONFIG and saved games (default `saves/c7`) |
| `--headless` | no window, no audio device; time is deterministic |
| `--realtime` | headless, but on the wall clock |
| `--record OUT.mp4` | video and audio through ffmpeg |
| `--seconds N` | quit after N seconds of emulated time |
| `--keys LIST` | scripted input: `ms:KEY[+holdms],...` |
| `--mute` | silence |
| `--scale N`, `--display MODE` | window size in multiples of 320x240 (default 3); `sharp`, `pixel` or `crt` (F11 cycles) |
| `--trace` | log DOS calls to stderr |
| `--shot FILE.bmp`, `--shot-at LIST` | the last frame at exit; frames at emulated times, `ms:file.bmp,...` |
| `--wav OUT.wav` | write the audio (no ffmpeg needed) |

The full list is at the top of [`src/main.c`](../src/main.c).

## netlab

On [netlab](https://github.com/sp00nznet/recomp-netlab) the recipe is
`corridor7`: `netlab build corridor7`, and `netlab check corridor7` runs the
self-test as QA.
