#!/usr/bin/env python3
"""rb4_regular.py -- referee B: Theorem 5.3 (signature theories) and the residual counts of section 5.

  A  The window bound in the proof of Thm 5.3: for X with n residuals X_v = {u : uv in X}, the window
     {0,1}^{<max(n-1,1)} separates the residuals.  Tested on 3000 random DFAs (2..7 states, seeded); residual
     classes computed exactly from the automaton (not by truncation); least separating window recorded.
  B  Signature theories for three languages not used by the developer: MOD3 = {#1 = 0 mod 3}, END01 = {w ends
     with 01}, and a random 5-state DFA language RND.  Curried form (one literal per conclusion).  Every
     sentence evaluated in (T, X) at all x = t_v, |v| <= 9; derivations of every datum |w| <= 8 checked by
     rb_logic.check (axioms, A4, MP only); line counts and sizes against |w|.
  C  Windowed residual counts (|v| <= d, window |u| <= d), computed independently, for the languages of
     t4_regular.py Part B; the developer's numbers are compared.
Seed 20261016.  Writes rb4_regular.out next to itself.
"""
import itertools
import os
import random
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import rb_logic as L  # noqa: E402

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "rb4_regular.out")
LOG = []
SEED = 20261016


def log(x=""):
    print(x)
    LOG.append(x)


def words(lo, hi):
    for n in range(lo, hi + 1):
        for t in itertools.product("01", repeat=n):
            yield "".join(t)


class DFA:
    def __init__(self, n, delta, F, q0=0):
        self.n, self.delta, self.F, self.q0 = n, delta, frozenset(F), q0

    def run(self, w, q=None):
        q = self.q0 if q is None else q
        for a in w:
            q = self.delta[q][int(a)]
        return q

    def accepts(self, w):
        return self.run(w) in self.F

    def reachable(self):
        seen, st = {self.q0}, [self.q0]
        while st:
            q = st.pop()
            for a in (0, 1):
                r = self.delta[q][a]
                if r not in seen:
                    seen.add(r)
                    st.append(r)
        return frozenset(seen)

    def residual_classes(self):
        """F_v = {q : delta*(q, v) in F}; X_v determined by F_v & reachable; F_{av} = {q : delta(q,a) in F_v}."""
        R0 = self.reachable()
        start = self.F
        seen = {start & R0: ""}
        frontier = [(start, "")]
        allF = {start}
        while frontier:
            Fv, v = frontier.pop()
            for a in "01":
                Fav = frozenset(q for q in range(self.n) if self.delta[q][int(a)] in Fv)
                if Fav not in allF:
                    allF.add(Fav)
                    frontier.append((Fav, a + v))
                    if (Fav & R0) not in seen:
                        seen[Fav & R0] = a + v
        return seen     # class -> representative word v


def rand_dfa(rng, n):
    delta = [[rng.randrange(n), rng.randrange(n)] for _ in range(n)]
    F = [q for q in range(n) if rng.random() < 0.5]
    return DFA(n, delta, F)


def sig(X, v, W):
    return tuple(X(u + v) for u in words(0, W - 1))


def part_a(rng):
    worst = 0
    tight = 0
    viol = 0
    hist = {}
    for _ in range(3000):
        D = rand_dfa(rng, rng.randint(2, 7))
        classes = D.residual_classes()
        n = len(classes)
        reps = list(classes.values())
        X = D.accepts
        Wstar = None
        for W in range(1, 12):
            if len({sig(X, v, W) for v in reps}) == n:
                Wstar = W
                break
        bound = max(n - 1, 1)
        hist[n] = hist.get(n, 0) + 1
        if Wstar is None or Wstar > bound:
            viol += 1
        else:
            worst = max(worst, Wstar - bound)
            tight += (Wstar == bound and n >= 3)
    log(f"  3000 random DFAs (residual counts n: {dict(sorted(hist.items()))}): least separating window > "
        f"max(n-1,1): {viol}; cases with n >= 3 where the bound n-1 is attained: {tight}")
    return viol == 0


# --------------------------------------------------------------- signature theories (curried form)
def V(n):
    return ("v", n)


def Rlit(t, b):
    a = ("at", "R", (t,))
    return a if b else ("not", a)


def signature_theory(X, W, maxv=12):
    win = list(words(0, W - 1))
    realised = {}
    for v in words(0, maxv):
        s = sig(X, v, W)
        realised.setdefault(s, v)
    trans = {}
    for s, v in realised.items():
        for a in "01":
            trans[(s, a)] = sig(X, a + v, W)
    # separation check: realised signatures must determine the transition (sanity of the window)
    for v in words(0, maxv - 1):
        for a in "01":
            assert trans[(sig(X, v, W), a)] == sig(X, a + v, W), "window does not determine the transition"
    ground = [Rlit(L.word_term(u), b) for u, b in zip(win, sig(X, "", W))]
    axioms = {}
    for (s, a), s2 in trans.items():
        for j, u in enumerate(win):
            body = Rlit(L.word_term(u + a, V("x")), s2[j])
            for u2, b2 in reversed(list(zip(win, s))):
                body = ("imp", Rlit(L.word_term(u2, V("x")), b2), body)
            axioms[(s, a, u)] = ("all", "x", body)
    return win, ground, axioms


def derive(X, W, win, ground, axioms, w):
    B = L.Builder()
    lit = {u: B.ax(g) for u, g in zip(win, ground)}      # literals about t_{u v}, v = current suffix
    v = ""
    for a in reversed(w):
        s = sig(X, v, W)
        new = {}
        for u in win:
            k = B.inst(B.ax(axioms[(s, a, u)]), L.word_term(v))
            for u2 in win:
                k = B.mp(lit[u2], k)
            new[u] = k
        lit = new
        v = a + v
    return B.lines, lit[""]


def part_b(rng):
    langs = []
    langs.append(("MOD3", lambda w: w.count("1") % 3 == 0))
    langs.append(("END01", lambda w: w.endswith("01")))
    D = None
    while D is None or len(D.residual_classes()) < 4:
        D = rand_dfa(rng, 5)
    langs.append(("RND", D.accepts))
    ok = True
    for name, X in langs:
        # least separating window (from residual representatives up to length 10)
        reps = {}
        for v in words(0, 10):
            reps.setdefault(tuple(X(u + v) for u in words(0, 8)), v)
        n = len(reps)
        W = next(W for W in range(1, 10) if len({sig(X, v, W) for v in reps.values()}) == n)
        win, ground, axioms = signature_theory(X, W)
        members = set(ground) | set(axioms.values())
        # truth in (T, X): every axiom at every x = t_v, |v| <= 9
        false = 0
        for (s, a, u), ax in axioms.items():
            j = win.index(u)
            for v in words(0, 9):
                prem = all(X(u2 + v) == b2 for u2, b2 in zip(win, s))
                if prem and X(u + a + v) != trans_val(X, W, s, a, j):
                    false += 1
        false += sum(1 for u, b in zip(win, sig(X, "", W)) if X(u) != b)
        bad = 0
        growth = {}
        for w in words(0, 8):
            lines, top = derive(X, W, win, ground, axioms, w)
            good, msg = L.check(lines, lambda F: F in members)
            want = Rlit(L.word_term(w), X(w))
            if not good or lines[top][0] != want:
                bad += 1
            g = growth.setdefault(len(w), [0, 0])
            g[0] = max(g[0], len(lines))
            g[1] = max(g[1], max(L.size(F) for F, _ in lines))
        log(f"  {name}: residuals n = {n}, least separating window |u| < {W}; theory: {len(members)} sentences; "
            f"false instances in (T, X) for |v| <= 9: {false}; derivations of all 511 data |w| <= 8 invalid {bad}")
        log("    max lines / max line size by |w|: " + ", ".join(f"{k}:{a}/{b}" for k, (a, b) in sorted(growth.items())))
        ok &= false == 0 and bad == 0
    return ok


def trans_val(X, W, s, a, j):
    """Value at u_j of the signature that the theory asserts after reading a from signature s."""
    for v in words(0, 10):
        if sig(X, v, W) == s:
            return sig(X, a + v, W)[j]
    raise RuntimeError


def part_c():
    langs = {"XA": lambda w: "010" in w, "XB": lambda w: len(w) >= 3 and w[2] == "1",
             "EQ' = 0^n1^n": lambda w: len(w) % 2 == 0 and w == "0" * (len(w) // 2) + "1" * (len(w) // 2),
             "PAL": lambda w: w == w[::-1], "EQ": lambda w: w.count("0") == w.count("1")}
    dev = {"XA": [3, 4, 4, 4], "XB": [4, 8, 8, 8], "EQ' = 0^n1^n": [5, 9, 13, 17], "PAL": [7, 31, 127, 511],
           "EQ": [5, 9, 13, 17]}
    ok = True
    for name, X in langs.items():
        counts = []
        for d in (2, 4, 6, 8):
            win = list(words(0, d))
            counts.append(len({tuple(X(u + v) for u in win) for v in words(0, d)}))
        same = counts == dev[name]
        log(f"  {name}: d = 2, 4, 6, 8 -> {counts}; developer's t4_regular.out Part B: {dev[name]}; equal {same}")
        ok &= same
    return ok


def main():
    rng = random.Random(SEED)
    log("rb4_regular.py -- referee B: Thm 5.3 window bound, signature theories, residual counts")
    log("== Part A: the window bound max(n-1,1) on random DFAs ==")
    ok = part_a(rng)
    log("== Part B: signature theories for three fresh languages ==")
    ok &= part_b(rng)
    log("== Part C: windowed residual counts vs the developer's ==")
    ok &= part_c()
    log("")
    log("all referee checks behaved as expected" if ok else "SOME REFEREE CHECK DID NOT BEHAVE AS EXPECTED")
    with open(OUT, "w") as fh:
        fh.write("\n".join(LOG) + "\n")


if __name__ == "__main__":
    main()
