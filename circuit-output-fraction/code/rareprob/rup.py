"""A small, self-contained DRUP refutation checker (two watched literals,
persistent level-0 assignment, backtracking after each lemma check).

A DRUP proof is a sequence of clauses, each of which must be RUP (reverse
unit propagation) with respect to the input clauses plus the earlier proof
clauses: assigning all its literals false and unit-propagating yields a
conflict. If the sequence derives the empty clause (or the clause database
becomes unit-refutable), the input is unsatisfiable. Deletion steps are
ignored: keeping clauses only adds unit-propagation power, so ignoring
deletions is sound (it can only make checking slower). This checker is the
trusted base of the domination certificates.
"""

from __future__ import annotations

import numbers


class RUPChecker:
    def __init__(self, clauses):
        nv = 0
        for c in clauses:
            for l in c:
                nv = max(nv, abs(int(l)))
        self.nv = nv
        self.val = [0] * (nv + 1)  # 0 unassigned, 1 true, -1 false
        self.trail: list[int] = []
        self.qhead = 0
        self.clauses: list[list[int]] = []
        self.watches: dict[int, list[int]] = {}
        self.refuted = False
        for c in clauses:
            self.add(c)
            if self.refuted:
                break

    # literal truth value: 1 true, -1 false, 0 unassigned
    def _lv(self, l: int) -> int:
        v = self.val[abs(l)] if abs(l) <= self.nv else 0
        return v if l > 0 else -v

    def _grow(self, l: int):
        a = abs(l)
        if a > self.nv:
            self.val.extend([0] * (a - self.nv))
            self.nv = a

    def _assign(self, l: int):
        self.val[abs(l)] = 1 if l > 0 else -1
        self.trail.append(l)

    def _propagate(self) -> bool:
        """Propagate from qhead; True iff a conflict is found."""
        trail, clauses, watches = self.trail, self.clauses, self.watches
        while self.qhead < len(trail):
            l = trail[self.qhead]
            self.qhead += 1
            fl = -l  # this literal just became false
            wl = watches.get(fl)
            if not wl:
                continue
            keep = []
            conflict = False
            i = 0
            nwl = len(wl)
            while i < nwl:
                ci = wl[i]
                i += 1
                if conflict:
                    keep.append(ci)
                    continue
                c = clauses[ci]
                if c[0] == fl:
                    c[0], c[1] = c[1], c[0]
                o = c[0]
                if self._lv(o) == 1:
                    keep.append(ci)
                    continue
                moved = False
                for j in range(2, len(c)):
                    if self._lv(c[j]) != -1:
                        c[1], c[j] = c[j], c[1]
                        watches.setdefault(c[1], []).append(ci)
                        moved = True
                        break
                if moved:
                    continue
                keep.append(ci)
                if self._lv(o) == 0:
                    self._assign(o)
                else:
                    conflict = True
            watches[fl] = keep
            if conflict:
                return True
        return False

    def add(self, c):
        """Add a clause at level 0 (input clause or verified lemma)."""
        if self.refuted:
            return
        c = list(dict.fromkeys(int(l) for l in c))
        if any(-l in c for l in c):
            return  # tautology
        for l in c:
            self._grow(l)
        if any(self._lv(l) == 1 for l in c):
            # satisfied at level 0 forever: still store for completeness
            nonfalse = [l for l in c if self._lv(l) != -1]
            if len(c) >= 2:
                c.sort(key=lambda l: -self._lv(l))
                idx = len(self.clauses)
                self.clauses.append(c)
                self.watches.setdefault(c[0], []).append(idx)
                self.watches.setdefault(c[1], []).append(idx)
            return
        nonfalse = [l for l in c if self._lv(l) == 0]
        if not nonfalse:
            self.refuted = True
            return
        if len(c) == 1 or len(nonfalse) == 1:
            u = nonfalse[0]
            if len(c) >= 2:
                rest = [l for l in c if l != u]
                c = [u] + rest
                idx = len(self.clauses)
                self.clauses.append(c)
                self.watches.setdefault(c[0], []).append(idx)
                self.watches.setdefault(c[1], []).append(idx)
            self._assign(u)
            if self._propagate():
                self.refuted = True
            return
        c = nonfalse[:2] + [l for l in c if l not in nonfalse[:2]]
        idx = len(self.clauses)
        self.clauses.append(c)
        self.watches.setdefault(c[0], []).append(idx)
        self.watches.setdefault(c[1], []).append(idx)

    def is_rup(self, c) -> bool:
        if self.refuted:
            return True
        mark = len(self.trail)
        conflict = False
        for l in c:
            l = int(l)
            self._grow(l)
            t = self._lv(l)
            if t == 1:
                conflict = True  # assigning not-l contradicts level 0
                break
            if t == 0:
                self._assign(-l)
        if not conflict:
            conflict = self._propagate()
        # backtrack to level 0
        for l in self.trail[mark:]:
            self.val[abs(l)] = 0
        del self.trail[mark:]
        self.qhead = mark
        return conflict

    def check_refutation(self, proof) -> bool:
        if self.refuted:
            return True
        for raw in proof:
            # snapshot the step once, as plain ints: a prover-supplied object
            # must not be able to show different clauses to is_rup and add
            if isinstance(raw, (str, bytes)):
                continue
            if not isinstance(raw, (list, tuple)):
                return False
            step = list(raw)
            if step and isinstance(step[0], str):  # deletion: ignored (sound)
                continue
            if not all(isinstance(l, numbers.Integral) and not isinstance(l, bool) for l in step):
                return False
            step = [int(l) for l in step]
            if any(l == 0 for l in step):
                return False
            if not self.is_rup(step):
                return False
            if len(step) == 0:
                return True
            self.add(step)
            if self.refuted:
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
