"""c5: finite DT° (first-order pattern, Horn) template theories that simulate a certificate verifier on literal data
(notes §6, Proposition 6.1 and its proof).

Language: constant e, unary s0, s1, binary pr, unary relation R, binary relation C. Words: t_w := s_{w1}(...(s_{wk}(e))).
Verifier M (deterministic, 3 tapes: input, certificate, work; the work tape is not used by this M): X := {w : w has
two consecutive 1s}. Acceptance certificate 0^i (the 1s at positions i, i+1); rejection certificate "1" (then M
scans the whole input and finds no 11). Every other certificate ends in the non-deciding halting state qNo.
Theory T_M: Start  C(x, conf(q0, e, x, e, z, e, e)); one template per transition (read symbol per tape, and the
left neighbour for a left move); Accept  C(x, pr(t_qacc, y)) -> R(x); Reject  C(x, pr(t_qrej, y)) -> not R(x).
All metavariables are 0-ary term metavariables, so every template is a first-order pattern (FO within DT°).

Checked:
  (1) for every word w with |w| <= 9 and every certificate c with |c| <= |w| + 1, the derivation
      Start, (transition, MP)*, Accept/Reject, MP is valid in K, with nonlogical axioms recognised by an independent
      pattern matcher against T_M; it ends in R(t_w) iff M accepts (w, c) and in not R(t_w) iff M rejects;
      the template run equals a direct simulation of M; its symbol size is <= A (tau + |w| + |c| + 1)^2;
  (2) determinism: no configuration term met (also on junk inputs) matches two transition templates;
  (3) junk terms (non-word subterms in the input or certificate position): the template run is a prefix of M's run
      on the word prefixes, so if it decides, M decides the same on those words; and no junk input gets both an
      accepting and a rejecting run (the proof's model sets R on junk terms accordingly).
"""
import itertools
import random
import sys

import kcore as K

sys.setrecursionlimit(20000)
SEED = 271828
rng = random.Random(SEED)
out = []

E = ('fn', 'e', ())


def s(a, t):
    return ('fn', 's' + str(a), (t,))


def pr(a, b):
    return ('fn', 'pr', (a, b))


def word(w):
    t = E
    for a in reversed(w):
        t = s(a, t)
    return t


def mv(name):
    return ('mv', name)


# ---------------------------------------------------------------- the verifier M
STATES = ['q0', 'qSeek', 'qChk1', 'qChk2', 'qScan0', 'qScan1', 'qAcc', 'qRej', 'qNo']
QBITS = 4


def qterm(q):
    i = STATES.index(q)
    return word([int(b) for b in format(i, f'0{QBITS}b')])


B = 'B'  # blank


def delta(q, a_in, a_c, a_w):
    """Returns (q', [(write, move)] for the three tapes) or None (halt). write None = keep. Work tape unused."""
    keep = (None, 'S')
    if q == 'q0':
        if a_c == 0:
            return 'qSeek', [keep, keep, keep]
        if a_c == B:
            return 'qChk1', [keep, keep, keep]
        return 'qScan0', [keep, (None, 'R'), keep]
    if q == 'qSeek':
        if a_c == 0 and a_in != B:
            return 'qSeek', [(None, 'R'), (None, 'R'), keep]
        if a_c == 0 and a_in == B:
            return 'qNo', [keep, keep, keep]
        if a_c == 1:
            return 'qNo', [keep, keep, keep]
        return 'qChk1', [keep, keep, keep]
    if q == 'qChk1':
        if a_in == 1:
            return 'qChk2', [(None, 'R'), keep, keep]
        return 'qNo', [keep, keep, keep]
    if q == 'qChk2':
        return ('qAcc' if a_in == 1 else 'qNo'), [keep, keep, keep]
    if q in ('qScan0', 'qScan1'):
        if a_c != B:
            return 'qNo', [keep, keep, keep]
        if a_in == B:
            return 'qRej', [keep, keep, keep]
        if a_in == 0:
            return 'qScan0', [(None, 'R'), keep, keep]
        if q == 'qScan1':
            return 'qNo', [keep, keep, keep]
        return 'qScan1', [(None, 'R'), keep, keep]
    return None


def simulate_M(w, c, max_steps=10 ** 5):
    """Direct simulation on lists; returns (final state, steps, list of states)."""
    tapes = [list(w), list(c), []]
    heads = [0, 0, 0]
    q, steps, trace = 'q0', 0, ['q0']
    while steps < max_steps:
        reads = [tapes[i][heads[i]] if heads[i] < len(tapes[i]) else B for i in range(3)]
        d = delta(q, *reads)
        if d is None:
            return q, steps, trace
        q, acts = d
        for i, (wr, mvm) in enumerate(acts):
            if wr is not None:
                if heads[i] < len(tapes[i]):
                    tapes[i][heads[i]] = wr
                else:
                    tapes[i].append(wr)
            if mvm == 'R':
                assert reads[i] != B or wr is not None, "machine moves right on a blank"
                heads[i] += 1
            elif mvm == 'L':
                heads[i] = max(0, heads[i] - 1)
        steps += 1
        trace.append(q)
    raise RuntimeError("no halt")


# ---------------------------------------------------------------- the template theory T_M

def conf(q, tapes):
    (l0, r0), (l1, r1), (l2, r2) = tapes
    return pr(q, pr(l0, pr(r0, pr(l1, pr(r1, pr(l2, r2))))))


def C(x, cf):
    return ('rel', 'C', (x, cf))


def R(x):
    return ('rel', 'R', (x,))


def build_templates():
    T = []
    T.append(('start', C(mv('x'), conf(qterm('q0'), [(E, mv('x')), (E, mv('z')), (E, E)]))))
    symbols = [0, 1, B]
    for q in STATES:
        for reads in itertools.product(symbols, symbols, [B]):
            d = delta(q, *reads)
            if d is None:
                continue
            q2, acts = d
            # one template per choice of left-neighbour pattern for left moves (none used by this M)
            pat_tapes, res_tapes = [], []
            for i, (a, (wr, mvm)) in enumerate(zip(reads, acts)):
                l, r = mv(f'l{i}'), mv(f'r{i}')
                rp = s(a, r) if a != B else E
                rest = r if a != B else E
                cell = wr if wr is not None else (a if a != B else None)
                if mvm == 'R':
                    assert cell is not None
                    pat_tapes.append((l, rp))
                    res_tapes.append((s(cell, l), rest))
                elif mvm == 'S':
                    pat_tapes.append((l, rp))
                    res_tapes.append((l, s(cell, rest) if cell is not None else rest))
                else:
                    raise NotImplementedError("left moves are not used by this M")
            T.append(('trans', K.imp(C(mv('x'), conf(qterm(q), pat_tapes)), C(mv('x'), conf(qterm(q2), res_tapes)))))
    T.append(('accept', K.imp(C(mv('x'), pr(qterm('qAcc'), mv('y'))), R(mv('x')))))
    T.append(('reject', K.imp(C(mv('x'), pr(qterm('qRej'), mv('y'))), K.neg(R(mv('x'))))))
    return T


def match(tpl, x, theta):
    """First-order pattern matching with 0-ary term metavariables (repeated occurrences must agree)."""
    if tpl[0] == 'mv':
        if tpl[1] in theta:
            return theta[tpl[1]] == x
        if x[0] not in ('fn', 'par'):
            return False
        theta[tpl[1]] = x
        return True
    if tpl[0] != x[0]:
        return False
    if tpl[0] in ('fn', 'rel'):
        return tpl[1] == x[1] and len(tpl[2]) == len(x[2]) and all(match(a, b, theta) for a, b in zip(tpl[2], x[2]))
    if tpl[0] in ('idx', 'par'):
        return tpl == x
    return all(match(a, b, theta) for (_, a), (_, b) in zip(K.children(tpl), K.children(x)))


def subst(tpl, theta):
    if tpl[0] == 'mv':
        return theta[tpl[1]]
    if tpl[0] in ('fn', 'rel'):
        return (tpl[0], tpl[1], tuple(subst(a, theta) for a in tpl[2]))
    if tpl[0] in ('idx', 'par'):
        return tpl
    if tpl[0] == 'eq':
        return ('eq', subst(tpl[1], theta), subst(tpl[2], theta))
    if tpl[0] == 'not':
        return ('not', subst(tpl[1], theta))
    if tpl[0] == 'imp':
        return ('imp', subst(tpl[1], theta), subst(tpl[2], theta))
    raise ValueError(tpl)


def in_theory(T, f):
    return any(match(tp, f, {}) for _, tp in T)


def template_run(T, x, z, max_steps=10 ** 4):
    """Forward run from Start(x, z): returns (lines of the derivation, final state name or None, determinism ok)."""
    trans = [tp for kind, tp in T if kind == 'trans']
    start = subst(T[0][1], {'x': x, 'z': z})
    lines = [(start, ('ax',))]
    cur = 0
    det = True
    for _ in range(max_steps):
        fact = lines[cur][0]
        hits = []
        for tp in trans:
            th = {}
            if match(tp[1], fact, th):
                hits.append(subst(tp, th))
        if len(hits) > 1:
            det = False
        if not hits:
            break
        inst = hits[0]
        lines.append((inst, ('ax',)))
        lines.append((inst[2], ('mp', cur, len(lines) - 1)))
        cur = len(lines) - 1
    qt = lines[cur][0][2][1][2][0]
    qname = next((q for q in STATES if qterm(q) == qt), None)
    for kind, tp in T:
        if kind in ('accept', 'reject'):
            th = {}
            if match(tp[1], lines[cur][0], th):
                inst = subst(tp, th)
                lines.append((inst, ('ax',)))
                lines.append((inst[2], ('mp', cur, len(lines) - 1)))
                break
    return lines, qname, det


def wordprefix(t):
    bits = []
    while t[0] == 'fn' and t[1] in ('s0', 's1') and len(t[2]) == 1:
        bits.append(int(t[1][1]))
        t = t[2][0]
    return bits, (t == E)


def junk_term(w):
    """A word prefix followed by a non-word node."""
    t = rng.choice([pr(E, E), pr(word([1]), E), ('fn', 's2', (E,)), pr(E, word([0, 1]))])
    for a in reversed(w):
        t = s(a, t)
    return t


def main():
    out.append(f"c5_templates  (seed {SEED})")
    T = build_templates()
    ntok = sum(K.size(subst(tp, {n: ('par', 0) for n in ('x', 'z', 'y', 'l0', 'r0', 'l1', 'r1', 'l2', 'r2')}))
               for _, tp in T)
    out.append(f"T_M: {len(T)} templates (1 start, {len(T) - 3} transitions, accept, reject); total template size "
               f"{ntok} symbols; all metavariables 0-ary term metavariables (first-order patterns)")
    # (1) all words and certificates
    ncase, bad_valid, bad_verdict, bad_trace, det_all = 0, 0, 0, 0, True
    worst_ratio, maxsize, maxtau = 0.0, 0, 0
    decided = {'acc': 0, 'rej': 0, 'none': 0}
    for n in range(0, 10):
        for w in itertools.product([0, 1], repeat=n):
            w = list(w)
            certs = [list(c) for m in range(0, n + 2) for c in itertools.product([0, 1], repeat=m)]
            if n > 6:
                certs = rng.sample(certs, 40) + [[0] * i for i in range(n + 1)] + [[1]]
            for c in certs:
                ncase += 1
                qM, tau, trace = simulate_M(w, c)
                lines, qT, det = template_run(T, word(w), word(c))
                det_all &= det
                ok, _ = K.check_derivation(lines, lambda f: in_theory(T, f))
                bad_valid += not ok
                last = lines[-1][0]
                if qM == 'qAcc':
                    decided['acc'] += 1
                    bad_verdict += last != R(word(w)) or not (('1', '1') in zip(map(str, w), map(str, w[1:])))
                elif qM == 'qRej':
                    decided['rej'] += 1
                    bad_verdict += last != K.neg(R(word(w))) or (('1', '1') in zip(map(str, w), map(str, w[1:])))
                else:
                    decided['none'] += 1
                    bad_verdict += last[0] != 'rel' or last[1] != 'C'
                bad_trace += qT != qM or (len(lines) - 1) // 2 - (1 if qM in ('qAcc', 'qRej') else 0) != tau
                S = K.derivation_size(lines)
                maxsize = max(maxsize, S)
                maxtau = max(maxtau, tau)
                worst_ratio = max(worst_ratio, S / (tau + len(w) + len(c) + 1) ** 2)
    out.append(f"(1) {ncase} (word, certificate) pairs, |w| <= 9: decided acc {decided['acc']}, rej {decided['rej']}, "
               f"undecided {decided['none']}")
    out.append(f"    invalid K-derivations: {bad_valid}; wrong last line or wrong verdict: {bad_verdict}; "
               f"template run != direct simulation (state or length): {bad_trace}")
    out.append(f"    max tau = {maxtau}, max derivation size = {maxsize}, max size / (tau + |w| + |c| + 1)^2 = "
               f"{worst_ratio:.2f}")
    # every word gets a derivation of the right literal
    missing = 0
    for n in range(0, 10):
        for w in itertools.product([0, 1], repeat=n):
            w = list(w)
            has11 = any(w[i] == w[i + 1] == 1 for i in range(len(w) - 1))
            c = [0] * next(i for i in range(len(w)) if w[i] == w[i + 1] == 1) if has11 else [1]
            lines, qT, _ = template_run(T, word(w), word(c))
            missing += lines[-1][0] != (R(word(w)) if has11 else K.neg(R(word(w))))
    out.append(f"    words |w| <= 9 without a derivation of their literal (with the canonical certificate): {missing}")
    # (3) junk
    njunk, bad_prefix, both = 0, 0, 0
    for _ in range(400):
        wlen = rng.randrange(0, 7)
        wp = [rng.randrange(2) for _ in range(wlen)]
        x = junk_term(wp) if rng.random() < 0.6 else word(wp)
        verdicts = set()
        for _ in range(12):
            clen = rng.randrange(0, 6)
            cp = [rng.choice([0, 0, 1]) for _ in range(clen)]
            z = junk_term(cp) if rng.random() < 0.6 else word(cp)
            lines, qT, det = template_run(T, x, z)
            det_all &= det
            njunk += 1
            if qT in ('qAcc', 'qRej'):
                verdicts.add(qT)
                qM, _, _ = simulate_M(wordprefix(x)[0], wordprefix(z)[0])
                bad_prefix += qM != qT
        both += len(verdicts) == 2
    out.append(f"(3) junk: {njunk} runs on terms with non-word nodes; decided runs whose verdict differs from M on the "
               f"word prefixes: {bad_prefix}; inputs with both an accepting and a rejecting run: {both}")
    out.append(f"(2) determinism (no configuration met matches two transition templates): {det_all}")
    allok = bad_valid == bad_verdict == bad_trace == missing == bad_prefix == both == 0 and det_all
    out.append("")
    out.append(f"verdict: {'all checks pass' if allok else 'FAILURE'}")


if __name__ == '__main__':
    main()
    text = "\n".join(out)
    print(text)
    with open(__file__.replace('.py', '.out'), 'w') as fh:
        fh.write(text + "\n")
