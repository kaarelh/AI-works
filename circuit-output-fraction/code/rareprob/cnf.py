"""Tseitin CNF encodings, unit propagation, failed-literal probing, and a
checker for DRUP/RUP refutations.

Literals are nonzero ints in DIMACS style: variable v (1-based) is v, its
negation -v. Circuit gate g is variable g + 1.
"""

from __future__ import annotations

from dataclasses import dataclass, field

from .circuit import Circuit, const_value


def gvar(g: int) -> int:
    return g + 1


def tseitin(C: Circuit, offset: int = 0, gates=None) -> list[list[int]]:
    """Clauses forcing every gate variable of C's cone to its gate value.

    Gate g is variable g + 1 + offset, except inputs, which are always
    variables 1..n (shared between circuits encoded with different offsets).
    CONST gates are read through circuit.const_value (0 or 1). THR gates are
    left unconstrained (a relaxation: every clause still holds at the true
    gate values, so implications derived from them are sound, possibly
    weaker).
    """
    n = C.n

    def V(g: int) -> int:
        return g + 1 if g < n else g + 1 + offset

    cls: list[list[int]] = []
    for g in (C.cone() if gates is None else gates):
        op = C.ops[g]
        a = [V(u) for u in C.args[g]]
        z = V(g)
        if op == "IN":
            continue
        if op == "CONST":
            cls.append([z] if const_value(C.params[g]) else [-z])
        elif op == "NOT":
            cls += [[z, a[0]], [-z, -a[0]]]
        elif op == "AND":
            cls += [[-z, u] for u in a]
            cls.append([z] + [-u for u in a])
        elif op == "OR":
            cls += [[z, -u] for u in a]
            cls.append([-z] + list(a))
        elif op == "XOR":
            # chain of binary XORs with fresh helper variables would need more
            # numbering; for fan-in <= 4 enumerate parity clauses directly.
            k = len(a)
            assert k <= 8, "encode wide XORs as trees of narrow ones"
            for mask in range(1 << k):
                # forbid assignments with (parity of chosen negations) wrong
                lits = [(-u if (mask >> j) & 1 else u) for j, u in enumerate(a)]
                # clause excludes the assignment where all lits are false,
                # i.e. inputs u_j = (mask_j). parity of that assignment:
                par = bin(mask).count("1") % 2
                cls.append(lits + ([-z] if par == 0 else [z]))
        elif op == "THR":
            continue
        else:  # pragma: no cover
            raise ValueError(op)
    return cls


@dataclass
class UP:
    """Unit propagation over a fixed clause set, with an assignment trail."""

    clauses: list = field(default_factory=list)

    def __post_init__(self):
        self.watch: dict[int, list[int]] = {}
        self.clauses = [list(dict.fromkeys(c)) for c in self.clauses]
        for i, c in enumerate(self.clauses):
            for l in c:
                self.watch.setdefault(-l, []).append(i)  # clause i is affected when l becomes false

    def propagate(self, assume: list[int], base: dict[int, bool] | None = None):
        """Returns (ok, assignment dict var->bool). ok=False on conflict.

        Simple counter-free propagation: when a literal becomes false we
        rescan the clauses containing it.
        """
        val: dict[int, bool] = dict(base or {})
        queue: list[int] = []

        def setlit(l: int) -> bool:
            v, b = abs(l), l > 0
            if v in val:
                return val[v] == b
            val[v] = b
            queue.append(l)
            return True

        for l in assume:
            if not setlit(l):
                return False, val
        # initial unit clauses
        for c in self.clauses:
            if len(c) == 1 and not setlit(c[0]):
                return False, val
        # also scan clauses already unit under base
        if base:
            for c in self.clauses:
                r = self._status(c, val)
                if r is False:
                    return False, val
                if r is not True and not setlit(r):
                    return False, val
        while queue:
            l = queue.pop()
            for ci in self.watch.get(l, ()):
                r = self._status(self.clauses[ci], val)
                if r is False:
                    return False, val
                if r is not True:
                    if not setlit(r):
                        return False, val
        return True, val

    @staticmethod
    def _status(c, val):
        """False if falsified, unit literal if unit, True otherwise."""
        unassigned = None
        count = 0
        for l in c:
            v = abs(l)
            if v in val:
                if val[v] == (l > 0):
                    return True
            else:
                count += 1
                unassigned = l
                if count > 1:
                    return True
        if count == 0:
            return False
        return unassigned


def affine_conjuncts(C: Circuit) -> list[tuple[int, int]]:
    """Top-level conjuncts of C that are affine over GF(2) in the inputs
    (cones made only of XOR, NOT and constants), as (mask, c) meaning
    XOR_{i in mask} x_i = c."""
    memo: dict[int, tuple[int, int] | None] = {}

    def aff(g):
        if g in memo:
            return memo[g]
        op = C.ops[g]
        r = None
        if op == "IN":
            r = (1 << g, 0)
        elif op == "CONST":
            r = (0, const_value(C.params[g]))
        elif op == "NOT":
            a = aff(C.args[g][0])
            r = None if a is None else (a[0], a[1] ^ 1)
        elif op == "XOR":
            m, c = 0, 0
            for u in C.args[g]:
                a = aff(u)
                if a is None:
                    m = None
                    break
                m ^= a[0]
                c ^= a[1]
            r = None if m is None else (m, c)
        memo[g] = r
        return r

    out = []
    stack = [C.output]
    seen = set()
    while stack:
        g = stack.pop()
        if g in seen:
            continue
        seen.add(g)
        if C.ops[g] == "AND":
            stack.extend(C.args[g])
            continue
        a = aff(g)
        if a is not None:
            out.append((a[0], 1 ^ a[1]))  # XOR(mask) ^ c = 1  <=>  XOR(mask) = 1 ^ c
    return out


def gauss_forced(rows: list[tuple[int, int]], known: dict[int, int]):
    """Literals implied by the affine system, given known values. Returns a
    dict of newly forced {var: bit}, or None if inconsistent."""
    red = []
    for m, c in rows:
        for i, b in known.items():
            if (m >> i) & 1:
                m ^= 1 << i
                c ^= b
        if m == 0:
            if c:
                return None
            continue
        red.append([m, c])
    # reduced row echelon form
    piv_rows = []
    for r in red:
        m, c = r
        for pm, pc, pb in piv_rows:
            if (m >> pb) & 1:
                m ^= pm
                c ^= pc
        if m == 0:
            if c:
                return None
            continue
        pb = m.bit_length() - 1
        # eliminate pb from existing pivots
        new = []
        for pm, pc, b in piv_rows:
            if (pm >> pb) & 1:
                pm ^= m
                pc ^= c
            new.append((pm, pc, b))
        piv_rows = new + [(m, c, pb)]
    forced = {}
    for m, c, b in piv_rows:
        if m & (m - 1) == 0:  # single variable
            forced[m.bit_length() - 1] = c
    return forced


def forced_input_literals(C: Circuit, probe: bool = True, rounds: int = 3) -> dict[int, int] | None:
    """Input literals implied by C(x) = 1, found by unit propagation on the
    Tseitin encoding plus failed-literal probing. Returns {input: bit}, or
    None if C(x) = 1 is refuted (then p = 0).
    """
    from .ve import binarize

    C = binarize(C)
    cls = tseitin(C) + [[gvar(C.output)]]
    up = UP(cls)
    ok, val = up.propagate([])
    if not ok:
        return None
    if probe:
        for _ in range(rounds):
            changed = False
            for i in range(C.n):
                v = i + 1
                if v in val:
                    continue
                for b in (True, False):
                    ok2, _ = up.propagate([v if b else -v], base=val)
                    if not ok2:
                        ok3, val3 = up.propagate([-v if b else v], base=val)
                        if not ok3:
                            return None
                        val = val3
                        changed = True
                        break
            if not changed:
                break
    lits = {v - 1: int(b) for v, b in val.items() if v - 1 < C.n}
    # Gaussian elimination on affine top-level conjuncts, alternating with UP
    rows = affine_conjuncts(C)
    for _ in range(rounds if rows else 0):
        g = gauss_forced(rows, lits)
        if g is None:
            return None
        new = {i: b for i, b in g.items() if i not in lits}
        if not new:
            break
        ok, val = up.propagate([(i + 1) if b else -(i + 1) for i, b in new.items()], base=val)
        if not ok:
            return None
        lits = {v - 1: int(b) for v, b in val.items() if v - 1 < C.n}
    return lits


def check_rup_refutation(clauses: list[list[int]], proof: list[list[int]],
                         deletions: bool = True) -> bool:
    """Check a DRUP proof (list of added clauses; a clause prefixed by the
    string 'd' is a deletion). Each added clause must be RUP w.r.t. the
    current clause set; the proof must derive the empty clause.
    Deletions only shrink the clause set, so ignoring them is also sound;
    we honour them for speed when deletions=True.
    """
    db: dict[tuple, int] = {}
    for c in clauses:
        k = tuple(sorted(set(c)))
        db[k] = db.get(k, 0) + 1
    for step in proof:
        if step and step[0] == "d":
            if deletions:
                k = tuple(sorted(set(step[1:])))
                if db.get(k, 0) > 0:
                    db[k] -= 1
                    if db[k] == 0:
                        del db[k]
            continue
        cl = [int(l) for l in step]
        up = UP([list(k) for k in db])
        ok, _ = up.propagate([-l for l in cl])
        if ok:
            return False  # not RUP
        if not cl:
            return True
        k = tuple(sorted(set(cl)))
        db[k] = db.get(k, 0) + 1
    up = UP([list(k) for k in db])
    ok, _ = up.propagate([])
    return not ok
