"""A small, self-contained DRUP refutation checker (two watched literals).

A DRUP proof is a sequence of clauses, each of which must be RUP (reverse
unit propagation) with respect to the input clauses plus the earlier proof
clauses: assigning all its literals false and unit-propagating yields a
conflict. If the sequence derives the empty clause, the input is
unsatisfiable. Deletion steps are ignored (keeping clauses only adds unit
propagation power, so ignoring deletions is sound; it can only make checking
slower). This checker is the trusted base of the domination certificates.
"""

from __future__ import annotations


class RUPChecker:
    def __init__(self, clauses):
        self.clauses: list[list[int]] = []
        self.watches: dict[int, list[int]] = {}
        self.units: list[int] = []
        self.empty = False
        for c in clauses:
            self.add(c)

    def add(self, c):
        c = list(dict.fromkeys(int(l) for l in c))
        if any(-l in c for l in c):
            return  # tautology
        if not c:
            self.empty = True
            return
        idx = len(self.clauses)
        self.clauses.append(c)
        if len(c) == 1:
            self.units.append(c[0])
        else:
            self.watches.setdefault(c[0], []).append(idx)
            self.watches.setdefault(c[1], []).append(idx)

    def _propagate(self, assume) -> bool:
        """True iff assigning `assume` plus units and propagating gives a conflict."""
        val: dict[int, bool] = {}
        trail: list[int] = []

        def assign(l: int) -> bool:
            v = abs(l)
            b = l > 0
            if v in val:
                return val[v] == b
            val[v] = b
            trail.append(l)
            return True

        for l in list(assume) + self.units:
            if not assign(l):
                return True
        head = 0
        while head < len(trail):
            l = trail[head]
            head += 1
            falsified = -l
            wl = self.watches.get(falsified)
            if not wl:
                continue
            keep = []
            conflict = False
            for k, ci in enumerate(wl):
                if conflict:
                    keep.append(ci)
                    continue
                c = self.clauses[ci]
                if c[0] == falsified:
                    c[0], c[1] = c[1], c[0]
                # now c[1] == falsified
                o = c[0]
                ov = val.get(abs(o))
                if ov is not None and ov == (o > 0):
                    keep.append(ci)
                    continue
                found = False
                for j in range(2, len(c)):
                    lj = c[j]
                    vj = val.get(abs(lj))
                    if vj is None or vj == (lj > 0):
                        c[1], c[j] = c[j], c[1]
                        self.watches.setdefault(c[1], []).append(ci)
                        found = True
                        break
                if found:
                    continue
                keep.append(ci)
                if ov is None:
                    assign(o)
                else:
                    conflict = True
            self.watches[falsified] = keep
            if conflict:
                return True
        return False

    def is_rup(self, c) -> bool:
        if self.empty:
            return True
        return self._propagate([-int(l) for l in c])

    def check_refutation(self, proof) -> bool:
        if self.empty or self._propagate([]):
            return True
        for step in proof:
            if isinstance(step, str):
                continue
            if step and isinstance(step[0], str):  # deletion
                continue
            if not self.is_rup(step):
                return False
            if len(step) == 0:
                return True
            self.add(step)
            if self._propagate([]):
                return True
        return False


def parse_drup(lines) -> list:
    """Parse DRUP text lines ('1 -2 0', 'd 1 -2 0') into steps."""
    out = []
    for ln in lines:
        ln = ln.strip()
        if not ln:
            continue
        toks = ln.split()
        if toks[0] == "d":
            out.append(["d"] + [int(t) for t in toks[1:-1]])
        else:
            out.append([int(t) for t in toks[:-1]])
    return out
