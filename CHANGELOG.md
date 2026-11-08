# Changelog

All notable changes to this project are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project uses
[Semantic Versioning](https://semver.org/).

## [Unreleased]

## [0.1.0] - 2026-11-08

### Added
- First playable: `CORR7CD.EXE` (CD release) lifted to C (869 functions) and
  built as a native Windows program. It boots, finds its CD, plays the
  Capstone logo, title and intro movie, and goes through the menus to the
  first floor, where you can walk, turn, fire and die, then to the high
  scores and the attract loop.
- Runtime, from the Blake Stone recomp's: a fake MSCDEX with one CD drive at
  D:, an EMS 4.0 driver (the movie player needs it), DOS allocation
  strategies (first and last fit), set handle count, the current drive, and
  Borland's `int86()` stubs.
- An interpreter for the compiled scalers the game writes at run time,
  including their transparency test and lighting call.
- `docs/lifting.md`: what Corridor 7 needed beyond Blake Stone.
