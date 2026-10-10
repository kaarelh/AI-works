"""r4: under reading (a2) (and (b2)) a FINITE theory is never constrained: referee minor m-a2.

Take the Horn theory T_M of the notes' Prop 6.1 / checks/c5 (the verifier 'w contains 11') and replace each template
by ONE universal sentence U_tau := Gen over all its (0-ary term) metavariables. Then every datum is derived from the
finite set {U_tau} by A4 instantiations (logical, free under (a2)) and MP. The nonlogical instances used are members
of {U_tau}: their size is a constant of the theory, independent of the word and of the run length, while the logical
(A4) instances grow with the configurations. No arithmetic and no background (B = empty) are needed; the model of
Prop 6.1(ii) satisfies the universal closures because it satisfies every closed instance.

Checked with the notes' own checker (checks/kcore.py) and with rk.py. Writes r4_a2_finite_theory.out.
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
CHECKS = os.path.join(os.path.dirname(HERE), 'checks')
sys.path.insert(0, HERE)
sys.path.insert(1, CHECKS)
import kcore as K  # noqa: E402
import c5_templates as C5  # noqa: E402  (main() is guarded; only definitions are used)
import rk  # noqa: E402
from r2_parameter_channel import from_k  # noqa: E402

sys.setrecursionlimit(50000)
MVS = ['x', 'z', 'y', 'l0', 'r0', 'l1', 'r1', 'l2', 'r2']


def mv_names(t, acc):
    if t[0] == 'mv':
        if t[1] not in acc:
            acc.append(t[1])
        return acc
    if t[0] in ('fn', 'rel'):
        for a in t[2]:
            mv_names(a, acc)
    elif t[0] in ('not', 'all'):
        mv_names(t[1], acc)
    elif t[0] in ('imp', 'eq'):
        mv_names(t[1], acc)
        mv_names(t[2], acc)
    return acc


def close(tp):
    names = mv_names(tp, [])
    f = C5.subst(tp, {n: ('par', i) for i, n in enumerate(names)})
    for i in range(len(names)):
        f = K.gen(f, i)
    return f, names


def derive_closed(T, x, z):
    """Replay c5's template run, but obtain each instance from its universal closure by A4 + MP."""
    lines_inst, qname, _ = C5.template_run(T, x, z)
    U_of = []
    for kind, tp in T:
        U_of.append((tp, close(tp)))
    out_lines = []
    index_of = {}

    def add(f, j):
        out_lines.append((f, j))
        index_of.setdefault(f, len(out_lines) - 1)
        return len(out_lines) - 1

    for f, j in lines_inst:
        if j[0] == 'ax':
            # find the template and substitution
            for tp, (U, names) in U_of:
                th = {}
                if C5.match(tp, f, th):
                    break
            else:
                raise RuntimeError("no template")
            cur = add(U, ('ax',)) if U not in index_of else index_of[U]
            body = U
            for i in reversed(range(len(names))):
                t = th[names[i]]
                inst = K.instantiate(body[1], t)
                a4 = K.imp(body, inst)
                k = add(a4, ('ax',))
                cur = add(inst, ('mp', cur, k))
                body = inst
            assert body == f
        else:
            a, b = j[1], j[2]
            fa, fb = lines_inst[a][0], lines_inst[b][0]
            add(f, ('mp', index_of[fa], index_of[fb]))
    return out_lines, qname


def main():
    T = C5.build_templates()
    Us = [close(tp)[0] for _, tp in T]
    Uset = set(Us)
    maxU = max(K.size(u) for u in Us)
    out = [f"r4_a2_finite_theory: T_M of c5 as {len(Us)} universal sentences; largest has size {maxU}; "
           f"total size {sum(K.size(u) for u in Us)}"]
    out.append("   |w|  |c|  verdict  lines  K-valid(kcore)  K-valid(rk)  max nonlogical inst  nonlogical material"
               "  max logical (A4) inst  derivation size")
    bad = 0
    cases = [('11', ''), ('0110', '0'), ('00000011', '0' * 6), ('0101010101011', '0' * 11),
             ('0', '1'), ('0100', '1'), ('01010101', '1'), ('010101010101010', '1')]
    for w, c in cases:
        x, z = C5.word([int(a) for a in w]), C5.word([int(a) for a in c])
        L, qn = derive_closed(T, x, z)
        ok_k, _ = K.check_derivation(L, lambda f: f in Uset)
        ok_r, _ = rk.check([(from_k(f), j) for f, j in L], lambda f: f in {from_k(u) for u in Uset})
        last = L[-1][0]
        want = C5.R(x) if '11' in w else K.neg(C5.R(x))
        nl = [f for f, j in L if j[0] == 'ax' and f in Uset]
        lg = [f for f, j in L if j[0] == 'ax' and f not in Uset]
        mat_nl = sum(K.size(f) for f in set(nl))
        bad += (not ok_k) or (not ok_r) or last != want
        out.append(f"  {len(w):4d} {len(c):4d}  {qn:7s}  {len(L):5d}  {str(ok_k):>14}  {str(ok_r):>11}  "
                   f"{max(K.size(f) for f in nl):19d}  {mat_nl:19d}  {max(K.size(f) for f in lg):21d}  "
                   f"{K.derivation_size(L):15d}")
    out.append(f"failures (invalid or wrong last line): {bad}")
    out.append("Reading: nonlogical instances are bounded by the constant above for every datum (reading (a2) with")
    out.append("h >= that constant, and (b2) with g >= the total size, admit this hypothesis), with B empty and no")
    out.append("arithmetic; only the logical A4 instances grow. With a decider M of X in place of the verifier the same")
    out.append("construction (Prop 6.1's model, universally closed) fits every decidable X on literal sequences.")
    with open(os.path.splitext(os.path.abspath(__file__))[0] + '.out', 'w') as fh:
        fh.write('\n'.join(out) + '\n')
    print('\n'.join(out))


if __name__ == '__main__':
    main()
