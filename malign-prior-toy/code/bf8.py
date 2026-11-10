"""Reference implementation of the BF8 monotone machine and of its bounded mixture.

BF8 has eight commands, three input bits each, read lazily from the input tape:
  0 '+'  cell += 1 (mod CELLMOD)     4 '['  if cell == 0 jump past the matching ']'
  1 '-'  cell -= 1 (mod CELLMOD)     5 ']'  if cell != 0 jump back to just after the matching '['
  2 '>'  pointer right                      (no matching '[': jump to command 0)
  3 '<'  pointer left                6 '.'  output cell mod 2
                                     7 ':'  output [cell != 0]
Every executed command is one step (a jump is one step; the forward scan of a
skipped loop costs no extra steps).  The k-th output bit is "on schedule" if it is
emitted at a step <= T0 + T1*k.

xi(x) is the probability, over a uniformly random command tape, that the machine
emits x with every bit on schedule and with at most LC commands read when the last
bit of x is emitted.  `mixture_bruteforce` computes it by running all 8**LC tapes;
it is slow and exists to check the C enumerator (bf8enum.c), which forks the
machine state at every read instead.
"""
from fractions import Fraction
from itertools import product

SYMS = "+-><[].:"


def parse(src):
    return [SYMS.index(ch) for ch in src]


def run(cmds, nbits, T0, T1, cellmod=16, pad=None):
    """Run the command list `cmds`.  If the machine needs a command beyond the list it
    stops (pad=None) or reads `pad` forever.  Returns (bits, reads) where reads[k] is the
    number of commands read when bit k was emitted."""
    tape = {}
    ptr = 0
    ip = 0
    nread = 0
    steps = 0
    scan = 0
    out, reads = [], []
    cmds = list(cmds)
    while len(out) < nbits:
        if ip == nread:
            if nread == len(cmds):
                if pad is None:
                    break
                cmds.append(pad)
            nread += 1
        c = cmds[ip]
        if scan > 0:
            if c == 4:
                scan += 1
            elif c == 5:
                scan -= 1
            ip += 1
            continue
        if steps >= T0 + T1 * (len(out) + 1):
            break
        steps += 1
        cell = tape.get(ptr, 0)
        if c == 0:
            tape[ptr] = (cell + 1) % cellmod
        elif c == 1:
            tape[ptr] = (cell - 1) % cellmod
        elif c == 2:
            ptr += 1
        elif c == 3:
            ptr -= 1
        elif c == 4:
            if cell == 0:
                scan = 1
        elif c == 5:
            if cell != 0:
                depth, j = 1, ip - 1
                while j >= 0:
                    if cmds[j] == 5:
                        depth += 1
                    elif cmds[j] == 4:
                        depth -= 1
                        if depth == 0:
                            break
                    j -= 1
                ip = j
        elif c == 6:
            out.append(cell & 1)
            reads.append(nread)
        elif c == 7:
            out.append(1 if cell != 0 else 0)
            reads.append(nread)
        ip += 1
    return out, reads


def mixture_bruteforce(LC, nbits, T0, T1, cellmod=16):
    """dict: bit string -> exact mass, for all strings of length 1..nbits with positive mass."""
    mass = {}
    w = Fraction(1, 8 ** LC)
    for cmds in product(range(8), repeat=LC):
        out, _ = run(cmds, nbits, T0, T1, cellmod)
        s = ""
        for b in out:
            s += "01"[b]
            mass[s] = mass.get(s, 0) + w
    return mass


def load_mixture(path):
    """Read the output file of bf8enum: dict bit string -> exact mass (Fraction)."""
    mass = {}
    with open(path) as f:
        for line in f:
            ln, bits, hx, _ = line.split()
            mass[bits] = Fraction(float.fromhex(hx))
    return mass
