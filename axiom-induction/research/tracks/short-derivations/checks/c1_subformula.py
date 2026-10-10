"""c1: the subformula lemma for Mendelson's K (Lemma 2.1 of short-derivations/notes.md), on random derivations.

Calculus: Mendelson's K with named variables. Connectives ~ and >, quantifier A (for all); terms over variables
x0..x3, the constant 0, S and +; predicates P (unary), Q (binary) and =. Axiom schemas A1-A3 (propositional),
A4 (A x B) > B[t/x] with t free for x in B, A5 (A x (B > C)) > (B > A x C) with x not free in B,
A6 A x (x = x), A7 (x = y) > (B > B') with B' from B by replacing some free occurrences of x by y (y free there).
Rules: MP and Gen (from B infer A x B). Nonlogical axioms: a fixed random set NL of sentences.

Size |chi| counts symbols: one per connective, quantifier, predicate, function symbol and constant, and
1 + (bits of i) for a variable x_i (the quantifier's variable included).

Procedure.
  * A random generator builds derivations by forward chaining (axiom instances built from existing lines so that MP
    and Gen apply often). Its labels are not trusted: every extracted proof is re-validated by an independent checker
    that recognises each schema by matching (A4 by first-order matching, A7 by a parallel walk).
  * For each derivation, six conclusions phi are chosen: the three lines with the largest dependency sets and three
    random derived lines. For each, the proof is extracted (lines phi depends on), de-duplicated (keep the first
    occurrence of each formula and remap uses) and pruned (every line except the last is used later), to a fixed point.
  * Claims checked on every pruned, de-duplicated proof (Lemma 2.1):
      (C1) every line is a subformula (occurrence) of some member of I + {phi}, I = distinct axiom instances used;
      (C2) #lines <= sum over chi in I + {phi} of #subformula occurrences of chi <= M + |phi|, M = sum_{chi in I} |chi|;
      (C3) every line has size <= max(max_{chi in I} |chi|, |phi|);
      (C4) size(proof) <= (M + |phi|) * max(...) <= (M + |phi|)^2;
      (C5) M <= size(proof);
      (C6) the "chase" of the proof of Lemma 2.1 (MP conclusion -> its major premise; Gen conclusion -> the line that
           uses it) terminates at a member of I + {phi} for every line, with each step a subformula step.
  * Necessity of the hypotheses: on the raw generated derivations (not pruned), count Gen conclusions that are not
    subformulas of I + {last line}; on extracted proofs before de-duplication, count proofs whose line count exceeds
    M + |phi|.
  * Tightness: the MP chain a, a > (a > ... > (a > b)) has size ~ (M + |phi|)^2 / 8: quadratic is attained.
"""
import random
import sys

sys.setrecursionlimit(20000)
SEED = 20261009
rng = random.Random(SEED)
out = []

VARS = [0, 1, 2, 3]
MAXSIZE = 200


# ---------------------------------------------------------------- syntax
def tsize(t):
    if t[0] == 'v':
        return 1 + max(1, t[1].bit_length())
    if t[0] == '0':
        return 1
    return 1 + sum(tsize(s) for s in t[1:])


def fsize(f):
    k = f[0]
    if k == 'P':
        return 1 + tsize(f[1])
    if k in ('Q', '='):
        return 1 + tsize(f[1]) + tsize(f[2])
    if k == '~':
        return 1 + fsize(f[1])
    if k == '>':
        return 1 + fsize(f[1]) + fsize(f[2])
    if k == 'A':
        return 2 + max(1, f[1].bit_length()) + fsize(f[2])
    raise ValueError(f)


def tvars(t):
    if t[0] == 'v':
        return {t[1]}
    if t[0] == '0':
        return set()
    s = set()
    for u in t[1:]:
        s |= tvars(u)
    return s


def fv(f):
    k = f[0]
    if k == 'P':
        return tvars(f[1])
    if k in ('Q', '='):
        return tvars(f[1]) | tvars(f[2])
    if k == '~':
        return fv(f[1])
    if k == '>':
        return fv(f[1]) | fv(f[2])
    if k == 'A':
        return fv(f[2]) - {f[1]}
    raise ValueError(f)


def tsubst(t, x, s):
    if t[0] == 'v':
        return s if t[1] == x else t
    if t[0] == '0':
        return t
    return (t[0],) + tuple(tsubst(u, x, s) for u in t[1:])


def subst(f, x, s):
    """Replace the free occurrences of variable x in f by the term s (no capture check here)."""
    k = f[0]
    if k == 'P':
        return ('P', tsubst(f[1], x, s))
    if k in ('Q', '='):
        return (k, tsubst(f[1], x, s), tsubst(f[2], x, s))
    if k == '~':
        return ('~', subst(f[1], x, s))
    if k == '>':
        return ('>', subst(f[1], x, s), subst(f[2], x, s))
    if k == 'A':
        if f[1] == x:
            return f
        return ('A', f[1], subst(f[2], x, s))
    raise ValueError(f)


def free_for(s, x, f, bound=frozenset()):
    """True iff no free occurrence of x in f lies in the scope of a quantifier on a variable of s."""
    k = f[0]
    if k == 'P':
        return not (x in tvars(f[1]) and (tvars(s) & bound))
    if k in ('Q', '='):
        return not (x in (tvars(f[1]) | tvars(f[2])) and (tvars(s) & bound))
    if k == '~':
        return free_for(s, x, f[1], bound)
    if k == '>':
        return free_for(s, x, f[1], bound) and free_for(s, x, f[2], bound)
    if k == 'A':
        if f[1] == x:
            return True
        return free_for(s, x, f[2], bound | {f[1]})
    raise ValueError(f)


def subformula_occurrences(f):
    """All formula nodes of f (with repetition), f included."""
    res = [f]
    k = f[0]
    if k == '~':
        res += subformula_occurrences(f[1])
    elif k == '>':
        res += subformula_occurrences(f[1]) + subformula_occurrences(f[2])
    elif k == 'A':
        res += subformula_occurrences(f[2])
    return res


# ---------------------------------------------------------------- independent axiom recognisers
def is_A1(f):
    return f[0] == '>' and f[2][0] == '>' and f[2][2] == f[1]


def is_A2(f):
    if f[0] != '>' or f[1][0] != '>' or f[1][2][0] != '>':
        return False
    B, C, D = f[1][1], f[1][2][1], f[1][2][2]
    return f[2] == ('>', ('>', B, C), ('>', B, D))


def is_A3(f):
    if f[0] != '>' or f[1][0] != '>' or f[1][1][0] != '~' or f[1][2][0] != '~':
        return False
    C, B = f[1][1][1], f[1][2][1]
    return f[2] == ('>', ('>', ('~', C), B), C)


def tmatch(s, s2, x, bound, acc):
    """Parallel walk of terms; free occurrences of x in s may be replaced by one common term in s2."""
    if s[0] == 'v' and s[1] == x and x not in bound:
        if acc[0] is None:
            acc[0] = s2
            return True
        return acc[0] == s2
    if s[0] != s2[0] or len(s) != len(s2):
        return False
    if s[0] == 'v':
        return s[1] == s2[1]
    if s[0] == '0':
        return True
    return all(tmatch(a, b, x, bound, acc) for a, b in zip(s[1:], s2[1:]))


def fmatch(f, f2, x, bound, acc):
    if f[0] != f2[0]:
        return False
    k = f[0]
    if k == 'P':
        return tmatch(f[1], f2[1], x, bound, acc)
    if k in ('Q', '='):
        return tmatch(f[1], f2[1], x, bound, acc) and tmatch(f[2], f2[2], x, bound, acc)
    if k == '~':
        return fmatch(f[1], f2[1], x, bound, acc)
    if k == '>':
        return fmatch(f[1], f2[1], x, bound, acc) and fmatch(f[2], f2[2], x, bound, acc)
    if k == 'A':
        return f[1] == f2[1] and fmatch(f[2], f2[2], x, bound | {f[1]}, acc)
    return False


def is_A4(f):
    if f[0] != '>' or f[1][0] != 'A':
        return False
    x, B, B2 = f[1][1], f[1][2], f[2]
    acc = [None]
    if not fmatch(B, B2, x, frozenset(), acc):
        return False
    if acc[0] is None:
        return B == B2
    return free_for(acc[0], x, B)


def is_A5(f):
    if f[0] != '>' or f[1][0] != 'A' or f[1][2][0] != '>' or f[2][0] != '>' or f[2][2][0] != 'A':
        return False
    x, B, C = f[1][1], f[1][2][1], f[1][2][2]
    return f[2][1] == B and f[2][2][1] == x and f[2][2][2] == C and x not in fv(B)


def is_A6(f):
    return f[0] == 'A' and f[2] == ('=', ('v', f[1]), ('v', f[1]))


def treplace_ok(s, s2, x, y, bound):
    if s == s2:
        return True
    if s[0] == 'v' and s[1] == x and x not in bound and s2 == ('v', y) and y not in bound:
        return True
    if s[0] != s2[0] or len(s) != len(s2) or s[0] in ('v', '0'):
        return False
    return all(treplace_ok(a, b, x, y, bound) for a, b in zip(s[1:], s2[1:]))


def freplace_ok(f, f2, x, y, bound):
    if f[0] != f2[0]:
        return False
    k = f[0]
    if k == 'P':
        return treplace_ok(f[1], f2[1], x, y, bound)
    if k in ('Q', '='):
        return treplace_ok(f[1], f2[1], x, y, bound) and treplace_ok(f[2], f2[2], x, y, bound)
    if k == '~':
        return freplace_ok(f[1], f2[1], x, y, bound)
    if k == '>':
        return freplace_ok(f[1], f2[1], x, y, bound) and freplace_ok(f[2], f2[2], x, y, bound)
    if k == 'A':
        return f[1] == f2[1] and freplace_ok(f[2], f2[2], x, y, bound | {f[1]})
    return False


def is_A7(f):
    if f[0] != '>' or f[1][0] != '=' or f[1][1][0] != 'v' or f[1][2][0] != 'v' or f[2][0] != '>':
        return False
    x, y = f[1][1][1], f[1][2][1]
    return freplace_ok(f[2][1], f[2][2], x, y, frozenset())


LOGICAL = [is_A1, is_A2, is_A3, is_A4, is_A5, is_A6, is_A7]


def is_axiom(f, NL):
    return f in NL or any(r(f) for r in LOGICAL)


def check_proof(lines, NL):
    """lines: list of (formula, just). just: ('ax',), ('mp', i, j) [line j = line i > this], ('gen', i)."""
    for n, (f, j) in enumerate(lines):
        if j[0] == 'ax':
            if not is_axiom(f, NL):
                return False, n
        elif j[0] == 'mp':
            i, k = j[1], j[2]
            if not (i < n and k < n and lines[k][0] == ('>', lines[i][0], f)):
                return False, n
        elif j[0] == 'gen':
            i = j[1]
            if not (i < n and f[0] == 'A' and f[2] == lines[i][0]):
                return False, n
        else:
            return False, n
    return True, None


# ---------------------------------------------------------------- random generation
def rterm(d):
    r = rng.random()
    if d <= 0 or r < 0.45:
        return ('v', rng.choice(VARS)) if rng.random() < 0.7 else ('0',)
    if r < 0.75:
        return ('S', rterm(d - 1))
    return ('+', rterm(d - 1), rterm(d - 1))


def rform(d):
    r = rng.random()
    if d <= 0 or r < 0.35:
        a = rng.random()
        if a < 0.4:
            return ('P', rterm(1))
        if a < 0.7:
            return ('Q', rterm(1), rterm(1))
        return ('=', rterm(1), rterm(1))
    if r < 0.5:
        return ('~', rform(d - 1))
    if r < 0.85:
        return ('>', rform(d - 1), rform(d - 1))
    return ('A', rng.choice(VARS), rform(d - 1))


def closure(f):
    for x in sorted(fv(f)):
        f = ('A', x, f)
    return f


def random_replace(B, x, y, bound=frozenset()):
    """Replace a random subset of the free occurrences of x by y, where y is free there."""
    def rt(t, bound):
        if t[0] == 'v' and t[1] == x and x not in bound and y not in bound and rng.random() < 0.5:
            return ('v', y)
        if t[0] in ('v', '0'):
            return t
        return (t[0],) + tuple(rt(u, bound) for u in t[1:])

    def rf(f, bound):
        k = f[0]
        if k == 'P':
            return ('P', rt(f[1], bound))
        if k in ('Q', '='):
            return (k, rt(f[1], bound), rt(f[2], bound))
        if k == '~':
            return ('~', rf(f[1], bound))
        if k == '>':
            return ('>', rf(f[1], bound), rf(f[2], bound))
        return ('A', f[1], rf(f[2], bound | {f[1]}))
    return rf(B, bound)


def generate(steps, NL):
    lines = []
    index = {}

    def add(f, j):
        if fsize(f) > MAXSIZE:
            return None
        lines.append((f, j))
        index.setdefault(f, len(lines) - 1)
        return len(lines) - 1

    def pick():
        """Prefer recent lines, so that dependency chains get deep."""
        if not lines:
            return None
        if rng.random() < 0.75:
            return rng.randrange(max(0, len(lines) - 8), len(lines))
        return rng.randrange(len(lines))

    def mp(i, k):
        A, AB = lines[i][0], lines[k][0]
        if AB[0] == '>' and AB[1] == A:
            return add(AB[2], ('mp', i, k))
        return None

    for _ in range(steps):
        r = rng.random()
        if not lines or r < 0.08:
            add(rng.choice(NL), ('ax',))
        elif r < 0.26:  # A1 then MP
            i = pick()
            B = lines[i][0]
            C = rform(1) if rng.random() < 0.6 else rng.choice(subformula_occurrences(lines[pick()][0]))
            k = add(('>', B, ('>', C, B)), ('ax',))
            if k is not None:
                mp(i, k)
        elif r < 0.38:  # A2 on an existing B > (C > D)
            cand = [n for n, (f, _) in enumerate(lines) if f[0] == '>' and f[2][0] == '>']
            if cand:
                i = max(cand) if rng.random() < 0.6 else rng.choice(cand)
                B, C, D = lines[i][0][1], lines[i][0][2][1], lines[i][0][2][2]
                k = add(('>', lines[i][0], ('>', ('>', B, C), ('>', B, D))), ('ax',))
                if k is not None:
                    m = mp(i, k)
                    if m is not None and ('>', B, C) in index:
                        mp(index[('>', B, C)], m)
        elif r < 0.46:  # A3 on an existing ~C > ~B
            cand = [n for n, (f, _) in enumerate(lines) if f[0] == '>' and f[1][0] == '~' and f[2][0] == '~']
            if cand:
                i = rng.choice(cand)
                C, B = lines[i][0][1][1], lines[i][0][2][1]
                k = add(('>', lines[i][0], ('>', ('>', ('~', C), B), C)), ('ax',))
                if k is not None:
                    m = mp(i, k)
                    if m is not None and ('>', ('~', C), B) in index:
                        mp(index[('>', ('~', C), B)], m)
            else:  # build a contraposition-shaped line via A1
                i = pick()
                B = lines[i][0]
                C = ('~', rform(1))
                k = add(('>', B, ('>', C, B)), ('ax',))
                if k is not None:
                    mp(i, k)
        elif r < 0.60:  # A4 on an existing universal line, then MP
            cand = [n for n, (f, _) in enumerate(lines) if f[0] == 'A']
            if cand:
                i = max(cand) if rng.random() < 0.6 else rng.choice(cand)
                x, B = lines[i][0][1], lines[i][0][2]
                for _try in range(5):
                    t = rterm(2)
                    if free_for(t, x, B):
                        k = add(('>', lines[i][0], subst(B, x, t)), ('ax',))
                        if k is not None:
                            mp(i, k)
                        break
        elif r < 0.66:  # A5 on an existing A x (B > C) with x not free in B
            cand = [n for n, (f, _) in enumerate(lines)
                    if f[0] == 'A' and f[2][0] == '>' and f[1] not in fv(f[2][1])]
            if cand:
                i = rng.choice(cand)
                x, B, C = lines[i][0][1], lines[i][0][2][1], lines[i][0][2][2]
                k = add(('>', lines[i][0], ('>', B, ('A', x, C))), ('ax',))
                if k is not None:
                    mp(i, k)
            else:  # make one: Gen on an implication whose antecedent is closed
                i = pick()
                B = closure(lines[i][0])
                C = rform(1)
                x = rng.choice(VARS)
                k = add(('>', B, ('>', C, B)), ('ax',))
                if k is not None:
                    m = mp(i, k) if lines[i][0] == B else None
                    if m is not None:
                        add(('A', x, lines[m][0]), ('gen', m))
        elif r < 0.70:
            x = rng.choice(VARS)
            add(('A', x, ('=', ('v', x), ('v', x))), ('ax',))
        elif r < 0.74:  # A7
            x, y = rng.choice(VARS), rng.choice(VARS)
            B = lines[pick()][0] if rng.random() < 0.5 else rform(2)
            add(('>', ('=', ('v', x), ('v', y)), ('>', B, random_replace(B, x, y))), ('ax',))
        elif r < 0.88:  # Gen
            i = pick()
            f = lines[i][0]
            free = sorted(fv(f))
            x = rng.choice(free) if free and rng.random() < 0.8 else rng.choice(VARS)
            add(('A', x, f), ('gen', i))
        else:  # any available MP
            pairs = [(index[f[1]], n) for n, (f, _) in enumerate(lines)
                     if f[0] == '>' and f[1] in index and f[2] not in index]
            if pairs:
                mp(*rng.choice(pairs))
    return lines


# ---------------------------------------------------------------- extraction, de-duplication, pruning
def extract(lines, r):
    need, stack = set(), [r]
    while stack:
        n = stack.pop()
        if n in need:
            continue
        need.add(n)
        j = lines[n][1]
        if j[0] == 'mp':
            stack += [j[1], j[2]]
        elif j[0] == 'gen':
            stack.append(j[1])
    order = sorted(need)
    pos = {o: k for k, o in enumerate(order)}
    res = []
    for o in order:
        f, j = lines[o]
        if j[0] == 'mp':
            j = ('mp', pos[j[1]], pos[j[2]])
        elif j[0] == 'gen':
            j = ('gen', pos[j[1]])
        res.append((f, j))
    return res


def dedup(lines):
    first, remap, res = {}, {}, []
    for n, (f, j) in enumerate(lines):
        if f in first:
            remap[n] = first[f]
            continue
        if j[0] == 'mp':
            j = ('mp', remap[j[1]], remap[j[2]])
        elif j[0] == 'gen':
            j = ('gen', remap[j[1]])
        first[f] = len(res)
        remap[n] = len(res)
        res.append((f, j))
    return res


def normalise(lines):
    """De-duplicate and prune to a fixed point; the conclusion is the last line's formula."""
    phi = lines[-1][0]
    cur = lines
    while True:
        d = dedup(cur)
        q = next(n for n, (f, _) in enumerate(d) if f == phi)
        p = extract(d, q)
        if p == cur:
            return p
        cur = p


def chase(lines, n, uses):
    """The chase of Lemma 2.1: returns the formula reached and the number of steps (or None on failure)."""
    steps = 0
    last = len(lines) - 1
    seen = set()
    while True:
        if (n, 'x') in seen:
            return None
        seen.add((n, 'x'))
        f, j = lines[n]
        if j[0] == 'ax':
            return f, steps
        if j[0] == 'mp':
            n = j[2]  # the major premise A > f contains f as a subformula
            steps += 1
            continue
        # Gen conclusion
        if n == last:
            return f, steps
        nxt = None
        for (m, how) in uses.get(n, []):
            if how == 'minor':  # f is the minor premise of an MP at line m: its major premise contains f
                nxt = lines[m][1][2]
                break
        if nxt is None:
            for (m, how) in uses.get(n, []):
                if how == 'gen':
                    nxt = m
                    break
        if nxt is None:
            return None
        n = nxt
        steps += 1


def is_subformula(g, f):
    return g in subformula_occurrences(f)


# ---------------------------------------------------------------- main experiment
def main():
    NL = [closure(rform(2)) for _ in range(6)]
    n_proofs = 0
    fails = {k: 0 for k in ('C0', 'C1', 'C2', 'C3', 'C4', 'C5', 'C6')}
    worst_ratio_sq = 0.0
    worst_ratio_lines = 0.0
    stats_lines, stats_size, stats_M = [], [], []
    raw_gen_nonsub = 0
    raw_gen_total = 0
    undedup_exceed = 0
    undedup_total = 0
    max_depth_chase = 0
    cnt = {k: 0 for k in ('with Gen line', 'Gen conclusion used as minor premise',
                          'Gen chain (Gen of a Gen conclusion)', 'conclusion by Gen', 'with an A4 instance')}
    for trial in range(300):
        lines = generate(220, NL)
        if len(lines) < 10:
            continue
        # necessity of pruning: Gen conclusions in the raw derivation that are not subformulas of axioms/last line
        last = lines[-1][0]
        ax = {f for f, j in lines if j[0] == 'ax'} | {last}
        subs = set()
        for a in ax:
            subs.update(subformula_occurrences(a))
        for f, j in lines:
            if j[0] == 'gen':
                raw_gen_total += 1
                if f not in subs:
                    raw_gen_nonsub += 1
        # conclusions: random lines from the second half, preferring derived ones
        derived = [n for n, (f, j) in enumerate(lines) if j[0] != 'ax' and n >= len(lines) // 3]
        if not derived:
            continue
        by_depth = sorted(derived, key=lambda n: len(extract(lines, n)), reverse=True)
        chosen = by_depth[:3] + rng.sample(derived, min(3, len(derived)))
        for r in chosen:
            ex = extract(lines, r)
            # necessity of de-duplication
            Iu = {f for f, j in ex if j[0] == 'ax'}
            Mu = sum(fsize(f) for f in Iu)
            undedup_total += 1
            if len(ex) > Mu + fsize(ex[-1][0]):
                undedup_exceed += 1
            pf = normalise(ex)
            n_proofs += 1
            ok, _ = check_proof(pf, NL)
            if not ok:
                fails['C0'] += 1
                continue
            phi = pf[-1][0]
            I = {f for f, j in pf if j[0] == 'ax'}
            M = sum(fsize(f) for f in I)
            targets = list(I) + [phi]
            occ = sum(len(subformula_occurrences(t)) for t in targets)
            maxi = max(max((fsize(f) for f in I), default=0), fsize(phi))
            size = sum(fsize(f) for f, _ in pf)
            # C1
            allsubs = set()
            for t in targets:
                allsubs.update(subformula_occurrences(t))
            if any(f not in allsubs for f, _ in pf):
                fails['C1'] += 1
            # C2
            if not (len(pf) <= occ <= M + fsize(phi)):
                fails['C2'] += 1
            # C3
            if max(fsize(f) for f, _ in pf) > maxi:
                fails['C3'] += 1
            # C4
            if not (size <= (M + fsize(phi)) * maxi <= (M + fsize(phi)) ** 2):
                fails['C4'] += 1
            # C5
            if M > size:
                fails['C5'] += 1
            # C6: chase
            uses = {}
            for m, (f, j) in enumerate(pf):
                if j[0] == 'mp':
                    uses.setdefault(j[1], []).append((m, 'minor'))
                    uses.setdefault(j[2], []).append((m, 'major'))
                elif j[0] == 'gen':
                    uses.setdefault(j[1], []).append((m, 'gen'))
            for m, (f, j) in enumerate(pf):
                res = chase(pf, m, uses)
                if res is None or res[0] not in targets or not is_subformula(f, res[0]):
                    fails['C6'] += 1
                    break
                max_depth_chase = max(max_depth_chase, res[1])
            gens = [m for m, (f, j) in enumerate(pf) if j[0] == 'gen']
            if gens:
                cnt['with Gen line'] += 1
            if any(how == 'minor' for m in gens for (_, how) in uses.get(m, [])):
                cnt['Gen conclusion used as minor premise'] += 1
            if any(how == 'gen' for m in gens for (_, how) in uses.get(m, [])):
                cnt['Gen chain (Gen of a Gen conclusion)'] += 1
            if pf[-1][1][0] == 'gen':
                cnt['conclusion by Gen'] += 1
            if any(j[0] == 'ax' and is_A4(f) and not any(r(f) for r in (is_A1, is_A2, is_A3)) for f, j in pf):
                cnt['with an A4 instance'] += 1
            worst_ratio_sq = max(worst_ratio_sq, size / (M + fsize(phi)) ** 2)
            worst_ratio_lines = max(worst_ratio_lines, len(pf) / (M + fsize(phi)))
            stats_lines.append(len(pf))
            stats_size.append(size)
            stats_M.append(M)

    out.append(f"c1_subformula  (seed {SEED})")
    out.append(f"pruned, de-duplicated proofs checked: {n_proofs}")
    out.append(f"  lines per proof: min {min(stats_lines)}, median {sorted(stats_lines)[len(stats_lines)//2]}, max {max(stats_lines)}")
    out.append(f"  size per proof:  min {min(stats_size)}, median {sorted(stats_size)[len(stats_size)//2]}, max {max(stats_size)}")
    out.append(f"  M per proof:     min {min(stats_M)}, median {sorted(stats_M)[len(stats_M)//2]}, max {max(stats_M)}")
    out.append(f"  longest chase (subformula steps to a target): {max_depth_chase}")
    for k, v in cnt.items():
        out.append(f"  proofs {k}: {v}")
    for k, v in fails.items():
        out.append(f"  {k} failures: {v}")
    out.append(f"  max size / (M + |phi|)^2 = {worst_ratio_sq:.4f}   (claim: <= 1)")
    out.append(f"  max #lines / (M + |phi|) = {worst_ratio_lines:.4f}   (claim: <= 1)")
    out.append("")
    out.append("necessity of the hypotheses")
    out.append(f"  raw (unpruned) derivations: {raw_gen_nonsub} of {raw_gen_total} Gen conclusions are not subformulas "
               f"of an axiom instance or of the last line")
    out.append(f"  extracted proofs before de-duplication: {undedup_exceed} of {undedup_total} have more lines than M + |phi|")
    out.append("")

    # de-duplication is needed: citing one axiom k times gives k + 1 lines against M + |phi| = 2|a| + 1
    a0 = ('P', ('0',))
    rep = [(a0, ('ax',)) for _ in range(40)] + [(('A', 0, a0), ('gen', 39))]
    ok_rep, _ = check_proof(rep, [a0])
    M_rep = fsize(a0)
    out.append(f"  constructed: P(0) cited 40 times, then Gen: valid={ok_rep}, lines={len(rep)}, "
               f"M + |phi| = {M_rep + fsize(rep[-1][0])}; after normalisation lines={len(normalise(rep))}")
    out.append("")

    # tightness family
    out.append("tightness: a, a > (a > ... > (a > b)) (k copies of a), then k MP steps; a = P(0), b = Q(0,0)")
    out.append(f"{'k':>6} {'size':>10} {'M':>8} {'|phi|':>6} {'size/(M+|phi|)^2':>18} {'valid':>6}")
    a = ('P', ('0',))
    b = ('Q', ('0',), ('0',))
    for k in (1, 10, 100, 1000):
        big = b
        for _ in range(k):
            big = ('>', a, big)
        NLk = [a, big]
        pf = [(a, ('ax',)), (big, ('ax',))]
        cur = 1
        for _ in range(k):
            pf.append((pf[cur][0][2], ('mp', 0, cur)))
            cur = len(pf) - 1
        ok, _ = check_proof(pf, NLk)
        size = sum(fsize(f) for f, _ in pf)
        M = fsize(a) + fsize(big)
        out.append(f"{k:>6} {size:>10} {M:>8} {fsize(b):>6} {size / (M + fsize(b)) ** 2:>18.4f} {str(ok):>6}")
    verdict = all(v == 0 for v in fails.values()) and worst_ratio_sq <= 1 and worst_ratio_lines <= 1
    out.append("")
    out.append(f"verdict: {'all claims hold' if verdict else 'FAILURE'}")


if __name__ == '__main__':
    main()
    text = "\n".join(out)
    print(text)
    with open(__file__.replace('.py', '.out'), 'w') as fh:
        fh.write(text + "\n")
