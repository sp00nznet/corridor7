# Roadmap

## Next
- Listen: AdLib music and Sound Blaster effects run but nobody has heard them.
- CD audio: tracks 2-6 of the disc are Red Book audio. MSCDEX play requests
  are acknowledged and logged, not played. Play them from the user's tracks
  (bin/cue or ripped files).
- A conformance script (`--keys` route through the menus to the first floor,
  walk, fire), with checks, like Blake Stone's `tools/conformance.py`.
- Save and load.
- A whole floor, then a whole playthrough. Bonus levels, the boss elevators.
- Network and modem modes are in the menu; untested and probably not useful.

## Then
- Setup: `Setup.cmd` / `setup.sh` that find the CD (drive, or a bin/cue),
  copy `CORR7CD/` and `CORR7.ID`, lift and build.
- recomp-launcher `launcher/launcher.json`, and a netlab project file.
- Linux and macOS: the SDL2 host came over from Blake Stone; build and test it.
- Hi-res and widescreen 3D view: Blake Stone's renderer hooks look for Blake
  Stone's variables and switch off here. Corridor 7's raycaster needs its own.

## Toolkit
- Upstream to pcrecomp what is not Corridor 7-specific: EMS, MSCDEX, DOS
  allocation strategies, the `int86()` stub. They live in this repo's `dos.c`
  and `machine.c`, as Blake Stone's do.
- Blake Stone's `tools/lift.py` still reads the relocation table at 1Ch.
