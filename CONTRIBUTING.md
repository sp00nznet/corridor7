# Contributing

Issues and pull requests are welcome.

## The one rule

**Nothing from the game goes in the repository.** No game files (`original/`),
no lifted C (`work/c7/gen/`), no unpacked image or dispatch-miss lists
(`work/`), no disassembly listings, nothing generated from `CORR7CD.EXE`. The
tool ships; its output is made on each person's machine from their own copy.
`.gitignore` covers the usual paths; check `git status` before you commit
anyway. Screenshots of the game running are fine.

## Where your code comes from

Original work or MIT-compatible only. Don't port from DOSBox, ScummVM or any
other GPL emulator, and don't write code with one open: that makes it theirs.

## Before a pull request

1. Lift and build from clean: `py -3 tools\lift.py c7`, then
   `cmake --build build --config Release` ([docs/building.md](docs/building.md)).
2. Run the self-test (no game data needed): `build\Release\selftest.exe`,
   expected `selftest: all passed`.
3. Run the change headless and keep the evidence, for example
   `build\Release\corridor7.exe --headless --seconds 30 --keys "4000:ENTER,6000:ESC" --shot-at "20000:menu.bmp"`
   ([docs/testing.md](docs/testing.md)). A new hardware behavior comes with a
   self-test check.

## Where a fix belongs

- A bug in the 16-bit lifter, `unlzexe` or the CPU model (`runtime/recomp16`)
  belongs in [pcrecomp](https://github.com/sp00nznet/pcrecomp), not here.
- The machine model (DOS, EMS, MSCDEX, VGA, audio) and anything Corridor
  7-specific lives here, in `src/` and `tools/lift.py`, with a comment that
  says what it fixes and why.
- A wall you got past goes in `docs/lifting.md`: what it looked like, what it
  was, what moved it.
