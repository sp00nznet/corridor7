# Testing

## The self-test

`tests/selftest.c` builds as `build\Release\selftest.exe` and checks the
machine model with no game data: 14 checks of the VGA (chain-4, Mode X,
latches, CRTC start, DAC), the x87 and the Sound Blaster/AdLib models.

```
build\Release\selftest.exe
```

Expected: `selftest: all passed`. `Setup.cmd` runs it after the build, and
netlab's `corridor7` recipe runs it as QA.

## Headless runs

With the game, every check today is a headless run whose evidence is looked
at: `--headless` has no window and no audio device, and time is emulated, so
the same `--keys` script gives the same frames every run.

```
build\Release\corridor7.exe --headless --seconds 30 --keys "4000:ENTER,6000:ESC" --shot-at "20000:menu.bmp"
build\Release\corridor7.exe --headless --record out.mp4 --seconds 60
```

`--keys` is `ms:KEY[+holdms],...` at emulated milliseconds; `--shot-at` is
`ms:file.bmp,...`. `--record` needs ffmpeg on `PATH`; `--wav` writes the audio
without it.

There is no conformance harness with the game yet ([ROADMAP.md](../ROADMAP.md)).
