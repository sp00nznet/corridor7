# Lifting Corridor 7: what it took

Corridor 7 is a Wolfenstein-engine game built with a later Borland C++ than
Blake Stone, so the Blake Stone lifter and runtime were the starting point.
What follows is everything that differed, in the order it turned up.

## 1. The relocation table is where the header says

Blake Stone's executables are LZEXE-packed, and the unpacker always writes
the relocation table at 1Ch, so `tools/lift.py` read it from there.
`CORR7CD.EXE` is not packed, and its table is at 3Eh (header word 0Ch). Read
from 1Ch, the "relocations" pointed past the end of the image. The lifter now
reads the offset from the header. (Blake Stone's copy still has the 1Ch read;
it is harmless there.)

## 2. A newer Borland startup

The startup code makes three DOS calls Blake Stone's never did:

- `21h/5801h`, set allocation strategy, and `21h/67h`, set handle count. It
  aborts ("Abnormal program termination") if either fails.
- To find the top of memory it sets the strategy to **last fit**, allocates
  one paragraph, uses that address + 1 as the heap's top, and frees it. A DOS
  that ignores the strategy hands back a block just above the program, and
  the far heap comes out a few bytes long. The engine's memory check then
  fails with no message: it writes its "not enough memory" screen to text
  memory and exits with 1. `dos.c` now honours first fit and last fit.

The arena also no longer offers the gap below the PSP (segment 60h up). On a
real PC that is DOS and its drivers.

## 3. The CD: MSCDEX

The game checks for its CD before anything else, with `INT 2Fh` (MSCDEX
installed, drive letters, "is D: a CD"). It then switches to the drive with
`21h/0Eh` and reads it back with `21h/19h`, so DOS now keeps a current
drive. Files on "D:" are served from the data folder like any other path,
and `CORR7.ID` (from the CD's root) has to be there.

It reaches `INT 2Fh` through Borland's `int86()`, which writes
`push bp / int nn / pop bp / retf` into data and far-calls it. `dispatch_far`
recognises that stub and runs the interrupt.

## 4. EMS, which the movie player assumes

The intro and cut-scenes are FLC-style movies (`SEQ*.CO7`). The player keeps
its frames in EMS, and its EMS handle is a BSS word that starts at 0. With no
EMS it never sets the handle, takes 0 as valid, maps "pages" into a page frame
at segment 0, and writes the movie over the interrupt vector table. That
later surfaced as INT 67h and INT 08h calls into `0000:0000`.

So the runtime is an EMS 4.0 driver now, as EMM386 was for nearly everyone
in 1994: the `EMMXXXX0` device (open plus IOCTL), `INT 67h` functions 40h–4Ch,
a 64 KB page frame at E000 and 4 MB behind it. Mapping copies a 16 KB page
into the frame and unmapping copies it back. The README's `NOEMS` switch is
not needed.

## 5. Compiled scalers, with transparency and lighting

Like Wolf3D, the game writes one column-drawing routine per height into its
heap and far-calls it. Unlike Wolf3D's, every texel is

```
8A 44 dd        mov al,[si+d]
3C FF           cmp al,FFh       ; FFh is transparent
74 08           je  next
E8 rr rr        call shade       ; at the end of the block
26 88 85 dd dd  mov es:[di+d],al
```

and `shade` is a lighting lookup:

```
89 C3  mov bx,ax   36 22 8F d16  and cl,ss:[bx+d]   28 C8  sub al,cl
88 E9  mov cl,ch   36 8A 9F d16  mov bl,ss:[bx+d]   29 C3  sub bx,ax
20 F8  and al,bh   C3            ret
```

`run_generated()` in `machine.c` interprets exactly those forms from guest
memory at the call. Anything else is still a miss. `C7_MISSDUMP=1` prints the
bytes at a miss, and the helper's bytes too.

## Debugging kit added here

| | |
|---|---|
| `--trace` at exit | the text screen (B800h), where an engine `Quit()` message lands, and the call stack of the `exit()` |
| `[int] vector nn unhooked` | an `INT` through a vector that points at nothing |
| `[ems]`, `[cd]` | every EMS and MSCDEX call (`--trace`) |
