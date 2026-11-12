# Roadmap

## Next
- Listen: AdLib music and Sound Blaster effects run but nobody has heard them.
- CD audio: tracks 2-6 of the disc are Red Book audio. MSCDEX play requests
  are acknowledged and logged, not played. Play them from the user's tracks
  (bin/cue or ripped files).
- A conformance harness (REPO_RULES section 9): a `--keys` route through the
  menus to the first floor, walk, fire, as milestones with a pass count and a
  baseline, like Blake Stone's `tools/conformance.py`. Without the game it
  prints a SKIP line for netlab's `QA_SKIP`. Today netlab's QA is the
  self-test only.
- Save and load.
- A whole floor, then a whole playthrough. Bonus levels, the boss elevators.
- Network and modem modes are in the menu; untested and probably not useful.

## Then
- Run `Setup.cmd` on a clean VM (it has been run from a fresh clone on the
  workstation), and publish the installer (the `installer` workflow, run by
  hand while the repo is private).
- A real `setup.sh` for Linux and macOS (today it says there is none), and
  bin/cue images in `Setup.cmd` (it takes a drive, a folder or an .iso).
- Linux and macOS: the SDL2 host came over from Blake Stone; build and test it.
- Hi-res and widescreen 3D view: Blake Stone's renderer hooks look for Blake
  Stone's variables and switch off here. Corridor 7's raycaster needs its own.

## Toolkit
- Upstream to pcrecomp what is not Corridor 7-specific: EMS, MSCDEX, DOS
  allocation strategies, the `int86()` stub. They live in this repo's `dos.c`
  and `machine.c`, as Blake Stone's do.
- Blake Stone's `tools/lift.py` still reads the relocation table at 1Ch.

## Out of scope
- Shipping any game file or generated source.
