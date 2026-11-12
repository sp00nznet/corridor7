# Notice

The MIT license in [LICENSE](LICENSE) covers what is ours in this repository:
the runtime, the lifter driver, the setup scripts, the tests and the
documentation. It does not cover the game.

*Corridor 7: Alien Invasion* is © 1994 Capstone Software / IntraCorp, and is
not ours to license. Its executable, data files and disc are not in this
repository and are excluded by `.gitignore`.

- You need your own copy of the game to use any of this. Setup copies your CD
  (or an image or copy of it) into `original/c7/`; the pipeline reads it from
  there.
- Lifted code is a derivative work of the binary it came from. Anything the
  pipeline writes into `work/` (the lifted C is `work/c7/gen/`) carries
  whatever license the original carries, not this one. The MIT grant stops at
  our own work.

## Third-party code

| Path | Upstream | Version | License |
|---|---|---|---|
| `third_party/ymfm/` | [ymfm](https://github.com/aaronsgiles/ymfm), © 2021 Aaron Giles; OPL family sources only, unmodified | 2021 sources | BSD-3-Clause, [LICENSES/BSD-3-Clause-ymfm.txt](LICENSES/BSD-3-Clause-ymfm.txt) |

The runtime (`src/`) and `tools/lift.py` began as the
[Blake Stone recomp](https://github.com/sp00nznet/blakestone)'s, and the
compiled-scaler interpreter follows the Wolfenstein 3-D recomp's
(sp00nznet/wolfdlss); both are our own MIT work. The build uses, but does not
include, the [pcrecomp](https://github.com/sp00nznet/pcrecomp) toolkit (MIT).
