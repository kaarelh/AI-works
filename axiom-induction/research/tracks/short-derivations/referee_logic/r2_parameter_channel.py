"""r2: parameter indices are an unpriced channel (referee issue M1).

The notes (and the paper, app-time.tex) count a parameter p_N as ONE symbol whatever N is, and Definition 1.2 lets
a hypothesis be ANY decider p of A_p with time O(t(|chi|)), |chi| the node count. Nothing requires A_p to be closed
under renaming parameters. Then a certificate can be hidden in a parameter index:

  A^par_V := { ~phi -> ~(p_N = p_N)    : V(phi, cert(N)) = acc }
           u { ~~phi -> ~(p_N = p_N)   : V(phi, cert(N)) = rej }        (cert(N): binary of N without its leading 1)

Each member is logically equivalent to phi^b (its closure is  A x (~phi^b -> ~ x = x)), so Cn(A^par_V) = Cn(Gamma_{f_V})
is consistent whenever f_V is. Membership is decided in time polynomial in the NODE COUNT (parse phi, read at most
L(|phi|) + 1 bits of the index, run V). Every datum phi^b has the 9-line K-derivation
  1 A.(#0 = #0)                         reflexivity
  2 A.(#0=#0) -> (p_N = p_N)            A4
  3 p_N = p_N                           MP 1,2
  4 (p_N=p_N) -> (~phi^b -> p_N=p_N)    A1
  5 ~phi^b -> p_N = p_N                 MP 3,4
  6 ~phi^b -> ~(p_N = p_N)              member of A^par_V
  7 (~phi^b -> ~(p_N=p_N)) -> ((~phi^b -> p_N=p_N) -> phi^b)    A3
  8 (~phi^b -> p_N=p_N) -> phi^b        MP 6,7
  9 phi^b                               MP 5,8
whose symbol size, material and largest instance are LINEAR in |phi| and INDEPENDENT of the certificate length,
while its bit code (notes Def 5.1) grows linearly in the certificate length.

The script checks, for a toy verifier whose certificates are forced to have length |w|^2 (or |w|^3):
  * the derivation is valid for the notes' own checker (checks/kcore.py) and for rk.py;
  * sizes, material, max instance (exact formulas), and code length against beta*d*log2(d+2);
  * the decider rejects every renaming of the parameter to a small index (A^par_V is not closed under
    permutations), so Lemma 4.1 / Theorem 4.2's test "chi in Ax iff can(chi) in Ax" fails for it;
  * the work of the decider (bits read + V's steps) is polynomial in the node count.
Seeded; writes r2_parameter_channel.out.
"""
import os
import random
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.path.insert(1, os.path.join(os.path.dirname(HERE), 'checks'))
import rk  # noqa: E402
import kcore as K  # noqa: E402  (the notes' own implementation, used only as a second checker)

SEED = 31337
rng = random.Random(SEED)
OUT = []

E = ('c', 'e', ())


def tw(w):
    t = E
    for ch in reversed(w):
        t = ('c', 's' + ch, (t,))
    return t


def Rw(w):
    return ('R', 'R', (tw(w),))


def word_of(t):
    w = ''
    while t != E:
        if t[0] != 'c' or t[1] not in ('s0', 's1') or len(t[2]) != 1:
            return None
        w += t[1][1]
        t = t[2][0]
    return w


def cert_of(N):
    return bin(N)[3:] if N >= 1 else None   # binary without the leading 1


def N_of(cert):
    return int('1' + cert, 2)


def make_V(deg):
    """Toy verifier: X = {w : '11' occurs in w}. Certificates must have length exactly |w|^deg and start with the
    claimed verdict bit; the rest is padding. (Only the LENGTH matters here: it shows what derivation size misses.)"""
    def V(w, c):
        if c is None:
            return '⊥', len(w)
        steps = len(c) + len(w)
        if len(c) != len(w) ** deg or not c:
            return '⊥', steps
        truth = '11' in w
        if c[0] == '1' and truth:
            return 'acc', steps
        if c[0] == '0' and not truth:
            return 'rej', steps
        return '⊥', steps
    return V


def member_factory(V, deg):
    work = {'max_ratio': 0.0}

    def member(chi):
        # shape  ~X -> ~(p_N = p_N)  with X = phi (acc) or X = ~phi (rej), phi = R(t_w)
        if chi[0] != '>' or chi[1][0] != '~' or chi[2][0] != '~' or chi[2][1][0] != '=':
            return False
        X, eq = chi[1][1], chi[2][1]
        if eq[1][0] != 'p' or eq[1] != eq[2]:
            return False
        pol = 'acc'
        if X[0] == '~':
            pol, X = 'rej', X[1]
        if X[0] != 'R' or X[1] != 'R' or len(X[2]) != 1:
            return False
        w = word_of(X[2][0])
        if w is None:
            return False
        L = len(w) ** deg
        N = eq[1][1]
        bits_read = min(N.bit_length(), L + 2)       # a TM reads at most L + 2 bits of the index, then decides
        if N.bit_length() > L + 1:
            res = False
            steps = 0
        else:
            res_v, steps = V(w, cert_of(N))
            res = res_v == pol
        nodes = rk.sz(chi)
        work['max_ratio'] = max(work['max_ratio'], (bits_read + steps) / nodes ** (deg + 1))
        return res
    return member, work


def derivation(w, b, N):
    phi = Rw(w)
    pb = phi if b == 1 else rk.neg(phi)
    pe = ('=', ('p', N), ('p', N))
    L = []
    L.append((rk.REFL, ('ax',)))                                                   # 0
    L.append((rk.imp(rk.REFL, pe), ('ax',)))                                       # 1 A4
    L.append((pe, ('mp', 0, 1)))                                                   # 2
    L.append((rk.imp(pe, rk.imp(rk.neg(pb), pe)), ('ax',)))                       # 3 A1
    L.append((rk.imp(rk.neg(pb), pe), ('mp', 2, 3)))                               # 4
    L.append((rk.imp(rk.neg(pb), rk.neg(pe)), ('ax',)))                            # 5 member
    a3 = rk.imp(rk.imp(rk.neg(pb), rk.neg(pe)), rk.imp(rk.imp(rk.neg(pb), pe), pb))
    L.append((a3, ('ax',)))                                                        # 6 A3
    L.append((a3[2], ('mp', 5, 6)))                                                # 7
    L.append((pb, ('mp', 4, 7)))                                                   # 8
    return L


def to_k(f):
    """rk syntax -> kcore syntax."""
    t = f[0]
    if t == 'i':
        return ('idx', f[1])
    if t == 'p':
        return ('par', f[1])
    if t == 'c':
        return ('fn', f[1], tuple(to_k(a) for a in f[2]))
    if t == 'R':
        return ('rel', f[1], tuple(to_k(a) for a in f[2]))
    if t == '=':
        return ('eq', to_k(f[1]), to_k(f[2]))
    if t == '~':
        return ('not', to_k(f[1]))
    if t == '>':
        return ('imp', to_k(f[1]), to_k(f[2]))
    if t == 'A':
        return ('all', to_k(f[1]))
    raise ValueError(f)


def from_k(f):
    t = f[0]
    m = {'idx': 'i', 'par': 'p', 'fn': 'c', 'rel': 'R', 'eq': '=', 'not': '~', 'imp': '>', 'all': 'A'}[t]
    if t in ('idx', 'par'):
        return (m, f[1])
    if t in ('fn', 'rel'):
        return (m, f[1], tuple(from_k(a) for a in f[2]))
    if t in ('not', 'all'):
        return (m, from_k(f[1]))
    return (m, from_k(f[1]), from_k(f[2]))


def main():
    out = OUT
    bs = 4
    beta = 8.0  # generous: notes' code costs <= b_s + 2log2(l+1) + 1 bits per symbol plus O(log l) per line
    out.append(f"r2_parameter_channel  (seed {SEED}); token bits b_s = {bs}; beta = {beta} (generous)")
    for deg in (2, 3):
        V = make_V(deg)
        member, work = member_factory(V, deg)
        out.append(f"verifier: X = {{w : 11 occurs in w}}, certificates of length |w|^{deg} carried in the index")
        out.append("   |w|  b  cert bits  K-valid(kcore) K-valid(rk)  size  size-9|phi^b|  material  mat-5|phi^b|"
                   "  max inst  inst-3|phi^b|  code bits  beta*d*log2(d+2)  code/that")
        bad = 0
        lin_bad = 0
        renamed_accepted = 0
        renamed_tested = 0
        for m in (2, 4, 6, 8, 10, 12):
            for b in (1, 0):
                # pick a word with the right label
                while True:
                    w = ''.join(rng.choice('01') for _ in range(m))
                    if ('11' in w) == (b == 1):
                        break
                cert = ('1' if b == 1 else '0') + ''.join(rng.choice('01') for _ in range(m ** deg - 1))
                N = N_of(cert)
                L = derivation(w, b, N)
                ok_rk, _ = rk.check(L, member)
                ok_k, _ = K.check_derivation([(to_k(f), j) for f, j in L], lambda f: member(from_k(f)))
                S = rk.dsize(L)
                pb = L[-1][0]
                inst = rk.instances(L)
                Mat = sum(rk.sz(a) for a in inst)
                mx = max(rk.sz(a) for a in inst)
                cl = rk.code_len(L, bs)
                kcl = K.code_length([(to_k(f), j) for f, j in L], bs)
                bound = beta * S * __import__('math').log2(S + 2)
                bad += (not ok_rk) or (not ok_k) or cl != kcl
                # every renaming of the parameter to a small index is rejected by the decider
                for small in range(0, 6):
                    renamed_tested += 1
                    chi = rk.imp(rk.neg(pb), rk.neg(('=', ('p', small), ('p', small))))
                    renamed_accepted += member(chi)
                lin_bad += (S - 9 * rk.sz(pb) != 54) or (Mat - 5 * rk.sz(pb) != 40) or (mx - 3 * rk.sz(pb) != 13)
                out.append(f"  {m:4d}  {b}  {len(cert):9d}  {str(ok_k):>14} {str(ok_rk):>11}  {S:4d}  "
                           f"{S - 9 * rk.sz(pb):13d}  {Mat:8d}  {Mat - 5 * rk.sz(pb):12d}  {mx:8d}  "
                           f"{mx - 3 * rk.sz(pb):13d}  {cl:9d}  {bound:16.0f}  {cl / bound:9.2f}")
        out.append(f"  invalid derivations or code-length mismatch (rk vs kcore): {bad}; "
                   f"deviations from size = 9|phi^b| + 54, material = 5|phi^b| + 40, max instance = 3|phi^b| + 13: {lin_bad}")
        out.append(f"  renamings to p_0..p_5 accepted by the decider: {renamed_accepted} of {renamed_tested} "
                   f"(A^par_V is not closed under permutations of the parameters)")
        out.append(f"  decider work / |chi|^{deg + 1} (bits read + verifier steps): max {work['max_ratio']:.3f}")
    out.append("Reading: symbol size = 9|phi^b| + 54, material = 5|phi^b| + 40, max instance = 3|phi^b| + 13 (exact),")
    out.append("all independent of the certificate; the bit code grows with the certificate, so the bound")
    out.append("'code <= beta * d * log2(d + 2)' (time-followup Thm 4.2(a), used by notes Thm 3.1(iii)) fails for")
    out.append("this hypothesis, and Thm 4.2's renaming test does not apply to it.")
    with open(os.path.splitext(os.path.abspath(__file__))[0] + '.out', 'w') as fh:
        fh.write('\n'.join(out) + '\n')
    print('\n'.join(out))


if __name__ == '__main__':
    main()
