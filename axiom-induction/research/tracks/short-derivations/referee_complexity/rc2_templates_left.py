"""rc2: Proposition 6.1 (Horn templates simulate a verifier on literal data) for machines that move left, overwrite
cells in the middle of a tape and reach the left end of the input tape. The notes' c5 uses a verifier that never
moves left and never writes (its delta raises NotImplementedError on left moves), so the left-neighbour templates,
the left-end case and writing were untested.

Construction, written from the text of Prop 6.1 (not from c5):
  conf(q, l0, r0, l1, r1, l2, r2) := pr(t_q, pr(l0, pr(r0, pr(l1, pr(r1, pr(l2, r2))))));
  a tape with its head is (l, r): l the cells left of the head, nearest first; r the cells from the head on;
  cells are s0, s1, s2; e ends both lists (blank).
  Start:  C(x, conf(q0, e, x, e, z, e, e)).
  One template per transition: state, the three read symbols (blank = e), and for each tape whose head moves left
  its left neighbour (s0, s1, s2) or the left end (l = e, the head stays).
  Accept: C(x, pr(t_qacc, y)) -> R(x).   Reject: C(x, pr(t_qrej, y)) -> not R(x).
Machines (3 tapes: input, certificate, work; tape alphabet {0, 1, 2} and blank; both obey the normal form "never
write a blank, never move right from a blank without writing" that the coding needs):
  PAL : acc iff the certificate is empty and w is a palindrome over {0,1}; rej iff the certificate is empty and w is
        not; otherwise no verdict. Copies w to the work tape behind a marker 2, rewinds the work tape (left moves with
        neighbours 0, 1, 2), then compares the input read right-to-left (left moves, ending at the left end) with the
        work tape read left-to-right.
  POW2: acc iff the certificate is empty and |w| is a power of 2; rej iff empty certificate and not. Keeps a binary
        counter (least significant bit first) behind a marker; each input symbol increments it (overwrites 1 -> 0 and
        0 -> 1 in the middle of the tape, extends on a blank), then returns left to the marker.
Checked, for every word |w| <= 9 and certificates in {eps, 0, 2, 01}:
  (1) the MP-chain derivation (Start, (transition, MP)^tau, Accept/Reject, MP) is valid in K for the notes' kcore and
      for the logic referee's rk, with nonlogical axioms recognised by my own matcher against the templates;
      it ends in R(t_w) iff M accepts and in not R(t_w) iff M rejects;
  (2) the state sequence and the decoded tapes equal a direct array simulation at every step;
  (3) number of lines (the notes say 2 tau + 4) and size / (tau + |w| + |c| + 1)^2;
  (4) determinism: no configuration met matches two transition templates;
  (5) junk inputs (a pr(e, e) node inside x or z): a run that decides agrees with M on the word prefixes, and no
      junk x gets both an accepting and a rejecting run over the z tried.
Seeded (random junk positions); writes rc2_templates_left.out next to itself.
"""
import itertools
import os
import random
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, '..', 'checks'))
sys.path.insert(0, os.path.join(HERE, '..', 'referee_logic'))
import kcore as K  # noqa: E402
import rk  # noqa: E402

sys.setrecursionlimit(100000)
SEED = 314159
KMAX = 9
rng = random.Random(SEED)
out = []


def P(*a):
    out.append(' '.join(str(x) for x in a))


B = 'B'
E = ('fn', 'e', ())
JUNK = ('fn', 'pr', (E, E))


def s(a, t):
    return ('fn', 's' + str(a), (t,))


def pr(a, b):
    return ('fn', 'pr', (a, b))


def mv(n):
    return ('mv', n)


def word(cells):
    t = E
    for a in reversed(cells):
        t = s(a, t)
    return t


def C(x, y):
    return ('rel', 'C', (x, y))


def Rr(x):
    return ('rel', 'R', (x,))


def imp(a, b):
    return ('imp', a, b)


def conf(qt, parts):
    l0, r0, l1, r1, l2, r2 = parts
    return pr(qt, pr(l0, pr(r0, pr(l1, pr(r1, pr(l2, r2))))))


# ---------------------------------------------------------------- machines
def pal_delta(q, a0, a1, a2):
    keep = (None, 'S')
    if q == 'q0':
        if a1 != B:
            return 'qNo', [keep, keep, keep]
        return 'qCopy', [keep, keep, (2, 'R')]
    if q == 'qCopy':
        if a0 in (0, 1):
            return 'qCopy', [(None, 'R'), keep, (a0, 'R')]
        if a0 == 2:
            return 'qNo', [keep, keep, keep]
        return 'qRewW', [keep, keep, (None, 'L')]
    if q == 'qRewW':
        if a2 in (0, 1):
            return 'qRewW', [keep, keep, (None, 'L')]
        if a2 == 2:
            return 'qCmp', [(None, 'L'), keep, (None, 'R')]
        return None
    if q == 'qCmp':
        if a2 == B:
            return 'qAcc', [keep, keep, keep]
        if a2 in (0, 1) and a0 in (0, 1):
            if a0 == a2:
                return 'qCmp', [(None, 'L'), keep, (None, 'R')]
            return 'qRej', [keep, keep, keep]
        return 'qNo', [keep, keep, keep]
    return None


def pow2_delta(q, a0, a1, a2):
    keep = (None, 'S')
    if q == 'q0':
        if a1 != B:
            return 'qNo', [keep, keep, keep]
        return 'qInc', [keep, keep, (2, 'R')]
    if q in ('qInc', 'qCarry'):
        if q == 'qInc':
            if a0 == B:
                return 'qZero', [keep, keep, keep]
            if a0 == 2:
                return 'qNo', [keep, keep, keep]
        if a2 == 1:
            return 'qCarry', [keep, keep, (0, 'R')]
        if a2 in (0, B):
            return 'qRet', [keep, keep, (1, 'L')]
        return None
    if q == 'qRet':
        if a2 in (0, 1):
            return 'qRet', [keep, keep, (None, 'L')]
        if a2 == 2 and a0 != B:  # (a0 = B is unreachable here; excluding it keeps the normal form)
            return 'qInc', [(None, 'R'), keep, (None, 'R')]
        return None
    if q == 'qZero':
        if a2 == 0:
            return 'qZero', [keep, keep, (None, 'R')]
        if a2 == 1:
            return 'qOne', [keep, keep, (None, 'R')]
        return 'qRej', [keep, keep, keep]
    if q == 'qOne':
        if a2 == 0:
            return 'qOne', [keep, keep, (None, 'R')]
        if a2 == 1:
            return 'qRej', [keep, keep, keep]
        return 'qAcc', [keep, keep, keep]
    return None


MACHINES = {
    'PAL': (['q0', 'qCopy', 'qRewW', 'qCmp', 'qAcc', 'qRej', 'qNo'], pal_delta,
            lambda w, c: None if c else (w == w[::-1])),
    'POW2': (['q0', 'qInc', 'qCarry', 'qRet', 'qZero', 'qOne', 'qAcc', 'qRej', 'qNo'], pow2_delta,
             lambda w, c: None if c else (len(w) > 0 and (len(w) & (len(w) - 1)) == 0)),
}


# ---------------------------------------------------------------- templates from the text of Prop 6.1
def build_theory(states, delta):
    qbits = max(1, (len(states) - 1).bit_length())

    def qt(q):
        i = states.index(q)
        return word([int(b) for b in format(i, f'0{qbits}b')])

    temps = []
    for q in states:
        for a in itertools.product((0, 1, 2, B), repeat=3):
            d = delta(q, *a)
            if d is None:
                continue
            q2, acts = d
            left_tapes = [i for i in range(3) if acts[i][1] == 'L']
            for nbs in itertools.product((0, 1, 2, 'END'), repeat=len(left_tapes)):
                nb = dict(zip(left_tapes, nbs))
                pat, res = [], []
                for i in range(3):
                    wr, mvv = acts[i]
                    lam, rho = mv(f'l{i}'), mv(f'r{i}')
                    if mvv == 'L':
                        lpat = E if nb[i] == 'END' else s(nb[i], lam)
                    else:
                        lpat = lam
                    rpat = E if a[i] == B else s(a[i], rho)
                    cur = wr if wr is not None else a[i]
                    rest = rho if a[i] != B else E
                    if cur == B:
                        if a[i] != B:
                            raise ValueError('blank written inside the tape: normal form violated')
                        cellrest = E
                    else:
                        cellrest = s(cur, rest)
                    if mvv == 'R':
                        if cur == B:
                            raise ValueError('right move from a blank without writing: normal form violated')
                        nl, nr = s(cur, lpat), rest
                    elif mvv == 'L':
                        if nb[i] == 'END':
                            nl, nr = E, cellrest
                        else:
                            nl, nr = lam, s(nb[i], cellrest)
                    else:
                        nl, nr = lpat, cellrest
                    pat += [lpat, rpat]
                    res += [nl, nr]
                x = mv('x')
                temps.append(('T', imp(C(x, conf(qt(q), pat)), C(x, conf(qt(q2), res)))))
    x, z, y = mv('x'), mv('z'), mv('y')
    start = ('S', C(x, conf(qt('q0'), [E, x, E, z, E, E])))
    acc = ('A', imp(C(x, pr(qt('qAcc'), y)), Rr(x)))
    rej = ('J', imp(C(x, pr(qt('qRej'), y)), ('not', Rr(x))))
    return temps, start, acc, rej, qt


# ---------------------------------------------------------------- my matcher (template against ground formula)
def match(t, f, th):
    if t[0] == 'mv':
        n = t[1]
        if n in th:
            return th if th[n] == f else None
        if not K.closed(f) or f[0] not in ('fn',):
            return None
        th = dict(th)
        th[n] = f
        return th
    if t[0] != f[0]:
        return None
    if t[0] in ('fn', 'rel'):
        if t[1] != f[1] or len(t[2]) != len(f[2]):
            return None
        for a, b in zip(t[2], f[2]):
            th = match(a, b, th)
            if th is None:
                return None
        return th
    if t[0] in ('not', 'all'):
        return match(t[1], f[1], th)
    if t[0] in ('imp', 'eq'):
        th = match(t[1], f[1], th)
        return None if th is None else match(t[2], f[2], th)
    return th if t == f else None


def subst(t, th):
    if t[0] == 'mv':
        return th[t[1]]
    if t[0] in ('fn', 'rel'):
        return (t[0], t[1], tuple(subst(a, th) for a in t[2]))
    if t[0] in ('not', 'all'):
        return (t[0], subst(t[1], th))
    if t[0] in ('imp', 'eq'):
        return (t[0], subst(t[1], th), subst(t[2], th))
    return t


def to_rk(x):
    tag = x[0]
    if tag == 'fn':
        return ('c', x[1], tuple(to_rk(a) for a in x[2]))
    if tag == 'rel':
        return ('R', x[1], tuple(to_rk(a) for a in x[2]))
    if tag == 'not':
        return ('~', to_rk(x[1]))
    if tag == 'imp':
        return ('>', to_rk(x[1]), to_rk(x[2]))
    if tag == 'idx':
        return ('i', x[1])
    if tag == 'par':
        return ('p', x[1])
    if tag == 'eq':
        return ('=', to_rk(x[1]), to_rk(x[2]))
    if tag == 'all':
        return ('A', to_rk(x[1]))
    raise ValueError(x)


def from_rk(x):
    tag = x[0]
    if tag == 'c':
        return ('fn', x[1], tuple(from_rk(a) for a in x[2]))
    if tag == 'R':
        return ('rel', x[1], tuple(from_rk(a) for a in x[2]))
    if tag == '~':
        return ('not', from_rk(x[1]))
    if tag == '>':
        return ('imp', from_rk(x[1]), from_rk(x[2]))
    raise ValueError(x)


# ---------------------------------------------------------------- direct simulation on arrays
def simulate(delta, w, c, maxsteps=100000):
    tapes = [list(w), list(c), []]
    heads = [0, 0, 0]
    q = 'q0'
    trace = []

    def rd(i):
        h = heads[i]
        return tapes[i][h] if h < len(tapes[i]) else B

    while True:
        trace.append((q, [list(t) for t in tapes], list(heads)))
        d = delta(q, rd(0), rd(1), rd(2))
        if d is None or len(trace) > maxsteps:
            return q, trace
        q2, acts = d
        for i, (wr, m) in enumerate(acts):
            if wr is not None:
                while len(tapes[i]) <= heads[i]:
                    tapes[i].append(B)
                tapes[i][heads[i]] = wr
            if m == 'R':
                heads[i] += 1
            elif m == 'L':
                heads[i] = max(0, heads[i] - 1)
        q = q2


def decode_list(t):
    cells = []
    while t != E:
        if t[0] != 'fn' or t[1] not in ('s0', 's1', 's2'):
            return None
        cells.append(int(t[1][1]))
        t = t[2][0]
    return cells


def tape_view(cells, h):
    left = [cells[j] if j < len(cells) else B for j in range(h)][::-1]
    right = list(cells[h:]) if h < len(cells) else []
    while right and right[-1] == B:
        right.pop()
    return left, right


# ---------------------------------------------------------------- run one machine
def run_machine(name):
    states, delta, spec = MACHINES[name]
    temps, start, acc, rej, qt = build_theory(states, delta)
    all_t = [start, acc, rej] + temps
    qstate = {qt(q): q for q in states}

    by_state = {}
    for kind, t in all_t:
        key = t[2][1][2][0] if t[0] == 'rel' else t[1][2][1][2][0]
        by_state.setdefault(key, []).append(t)
    memo = {}

    def member(f):
        # my matcher, tried against every template whose antecedent (or Start conclusion) has f's state term
        if f in memo:
            return memo[f]
        try:
            key = f[2][1][2][0] if f[0] == 'rel' else f[1][2][1][2][0]
        except (IndexError, TypeError):
            memo[f] = False
            return False
        r = any(match(t, f, {}) is not None for t in by_state.get(key, []))
        memo[f] = r
        return r

    def member_rk(g):
        return member(from_rk(g))

    def step_templates(fact):
        hits = []
        for _, t in temps:
            th = match(t[1], fact, {})
            if th is not None:
                hits.append(subst(t, th))
        return hits

    P(f'machine {name}: {len(states)} states, {len(temps)} transition templates (+ Start, Accept, Reject)')
    stats = dict(pairs=0, decided=0, acc=0, rej=0, bad_k=0, bad_rk=0, wrong=0, sim_mismatch=0, nondet=0,
                 lines_wrong=0, max_ratio=0.0, max_tau=0, left_moves=0, left_end=0, mid_writes=0)
    certs = ['', '0', '2', '01']
    for k in range(KMAX + 1):
        for wi in range(2 ** k):
            w = [int(b) for b in format(wi, f'0{k}b')] if k else []
            for cs in certs:
                c = [int(b) for b in cs]
                stats['pairs'] += 1
                qf, trace = simulate(delta, w, c)
                tw, tc = word(w), word(c)
                th0 = {'x': tw, 'z': tc}
                fact = subst(start[1], th0)
                lines = [(fact, ('ax',))]
                tau = 0
                ok_sim = True
                while True:
                    # compare with the direct simulation at step tau
                    qs, tp, hd = trace[tau]
                    st = fact[2][1]
                    if qstate.get(st[2][0]) != qs:
                        ok_sim = False
                    parts = []
                    node = st[2][1]
                    for _ in range(5):
                        parts.append(node[2][0])
                        node = node[2][1]
                    parts.append(node)
                    for i in range(3):
                        lv, rv = tape_view(tp[i], hd[i])
                        if decode_list(parts[2 * i]) != lv or decode_list(parts[2 * i + 1]) != rv:
                            ok_sim = False
                    hits = step_templates(fact)
                    if len(hits) > 1:
                        stats['nondet'] += 1
                    if not hits:
                        break
                    inst = hits[0]
                    lines.append((inst, ('ax',)))
                    lines.append((inst[2], ('mp', len(lines) - 2, len(lines) - 1)))
                    fact = inst[2]
                    tau += 1
                # count exercised features from the direct simulation
                for j in range(len(trace) - 1):
                    q, tp, hd = trace[j]
                    rd = [tp[i][hd[i]] if hd[i] < len(tp[i]) else B for i in range(3)]
                    d = delta(q, *rd)
                    for i, (wr, m) in enumerate(d[1]):
                        if m == 'L':
                            stats['left_moves'] += 1
                            if hd[i] == 0:
                                stats['left_end'] += 1
                        if wr is not None and hd[i] < len(tp[i]) and tp[i][hd[i]] != B:
                            stats['mid_writes'] += 1
                if not ok_sim or tau != len(trace) - 1:
                    stats['sim_mismatch'] += 1
                verdict = None
                for lab, t in (('acc', acc[1]), ('rej', rej[1])):
                    th = match(t[1], fact, {})
                    if th is not None:
                        inst = subst(t, th)
                        lines.append((inst, ('ax',)))
                        lines.append((inst[2], ('mp', len(lines) - 2, len(lines) - 1)))
                        verdict = lab
                expect = spec(w, c)
                want = None if expect is None else ('acc' if expect else 'rej')
                if verdict != want or (qf == 'qAcc') != (verdict == 'acc') or (qf == 'qRej') != (verdict == 'rej'):
                    stats['wrong'] += 1
                if verdict is None:
                    continue
                stats['decided'] += 1
                stats[verdict] += 1
                stats['max_tau'] = max(stats['max_tau'], tau)
                last = lines[-1][0]
                if last != (Rr(tw) if verdict == 'acc' else ('not', Rr(tw))):
                    stats['wrong'] += 1
                ok1, _ = K.check_derivation(lines, member)
                ok2, _ = rk.check([(to_rk(f), j) for f, j in lines], member_rk)
                stats['bad_k'] += (not ok1)
                stats['bad_rk'] += (not ok2)
                if len(lines) != 2 * tau + 3:
                    stats['lines_wrong'] += 1
                ratio = K.derivation_size(lines) / (tau + len(w) + len(c) + 1) ** 2
                stats['max_ratio'] = max(stats['max_ratio'], ratio)
    P(f'  (1)-(3) {stats["pairs"]} (word, certificate) pairs, |w| <= {KMAX}: decided {stats["decided"]} '
      f'(acc {stats["acc"]}, rej {stats["rej"]})')
    P(f'      invalid for kcore: {stats["bad_k"]}; invalid for rk: {stats["bad_rk"]}; wrong verdict or last line: '
      f'{stats["wrong"]}; run != direct simulation: {stats["sim_mismatch"]}')
    P(f'      features exercised: {stats["left_moves"]} left moves ({stats["left_end"]} at the left end), '
      f'{stats["mid_writes"]} overwrites of non-blank cells')
    P(f'      lines == 2 tau + 3 in every decided case: {stats["lines_wrong"] == 0}  (the notes state 2 tau + 4); '
      f'max tau = {stats["max_tau"]}; max size / (tau + |w| + |c| + 1)^2 = {stats["max_ratio"]:.2f}')
    P(f'  (4) configurations matching two transition templates: {stats["nondet"]}')

    # (5) junk
    bad_junk = both = runs = 0
    for _ in range(1500):
        k = rng.randint(0, 8)
        w = [rng.randint(0, 1) for _ in range(k)]
        jpos = rng.randint(0, k)
        x = JUNK
        for a in reversed(w[:jpos]):
            x = s(a, x)
        verdicts = set()
        for cs, jz in (('', False), ('', True), ('0', False), ('1', True)):
            c = [int(b) for b in cs]
            z = JUNK if jz else word(c)
            if jz:
                for a in reversed(c):
                    z = s(a, z)
            fact = subst(start[1], {'x': x, 'z': z})
            steps = 0
            while steps < 5000:
                hits = step_templates(fact)
                if not hits:
                    break
                fact = hits[0][2]
                steps += 1
            runs += 1
            st = fact[2][1][2][0]
            q = qstate.get(st)
            if q in ('qAcc', 'qRej'):
                verdicts.add(q)
                qf, _ = simulate(delta, w[:jpos], c)
                if qf != q:
                    bad_junk += 1
        if len(verdicts) == 2:
            both += 1
    P(f'  (5) junk: {runs} runs from Start(x, z) with a pr(e,e) node in x (and sometimes z): decided runs that '
      f'disagree with M on the word prefixes: {bad_junk}; junk x with both verdicts: {both}')
    return stats, bad_junk, both


P(f'rc2_templates_left  (seed {SEED})')
allok = True
feat = dict(left_moves=0, left_end=0, mid_writes=0)
for name in MACHINES:
    st, bj, both = run_machine(name)
    allok &= (st['bad_k'] == st['bad_rk'] == st['wrong'] == st['sim_mismatch'] == st['nondet'] == 0
              and st['lines_wrong'] == 0 and bj == 0 and both == 0)
    for k in feat:
        feat[k] += st[k]
# feature coverage is required of the two machines together (PAL reaches the left end, POW2 overwrites cells)
allok &= all(v > 0 for v in feat.values())
P(f'features over both machines: {feat}')
P('verdict:', 'all checks pass; the line count is 2 tau + 3, not 2 tau + 4' if allok else 'FAILURES above')
with open(os.path.join(HERE, 'rc2_templates_left.out'), 'w') as fh:
    fh.write('\n'.join(out) + '\n')
print('\n'.join(out))
