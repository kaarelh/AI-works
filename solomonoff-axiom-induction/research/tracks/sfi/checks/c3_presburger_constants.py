"""c3_presburger_constants.py -- thread `sfi`, T9 (revised 2026-10-16): from which sentence length m on
do the contradictions in the Presburger separations bite, for illustrative constants?

Revision.  The development-round version (kept as v1-outputs/c3_presburger_constants.v1.py with its
output) bounded log2(C 2^a + m) by a + log2(C) + 1.  That bound needs m <= C 2^a and is not
conservative when the clock exponent a is small (referee B, issue 3: 8 of 144 thresholds were 1 to 6
too small).  This version evaluates every quantity exactly with mpmath (60 digits), so each m0 is
exact up to the 60-digit evaluation, and it prints the rows whose value changed against v1.
It also tabulates the budgets forced in Prop 9.4 (size, material and (a1) readings).

Fischer and Rabin (1974), in the form used in notes-final.md section 9 (F_FR), with sentence length
measured as the symbol count |phi| of notes-final.md section 9: there is c > 0 such that every
(also every nondeterministic) decision procedure for Th(N,0,1,+) runs more than 2^(2^(c m)) steps on
some sentence of length m, for all large m.  The overhead polynomial q (TF Convention 1.5) is
q(x) = x^k, and C is the hypothesis' constant.  Nothing is asserted about the true c.

(A) coin-free clocked consistent SOI (Prop 9.1), tau(m) = 2^(2^(c'm)):
    q(C tau(m) + m) < 2^(2^(c m))  <=>  log2 k + log2 log2(C tau + m) < c m.
(B) one tape, exponential clock tau(m) = 2^(c'm) (Prop 9.2): 2^tau(m) q(C tau(m) + m) < 2^(2^(cm))
    <=>  log2( tau + k log2(C tau + m) ) < c m.
(C) one tape, doubly exponential clock, conditional route (Prop 9.3): T = q(C tau + m),
    tau = 2^(2^(c'm)); a Sigma_2 simulation in time about T^3 (log T)^2 (any T^kappa with kappa >= 3
    for large T) must stay below 2^(2^(c_B m)):  log2( 3 log2 T + 2 log2 log2 T ) < c_B m.
For each parameter set m0 := the least m such that the inequality holds for every m in [m0, 3000]
('none' if it fails at m = 3000).

(D) Prop 9.4: the budgets forced on a hypothesis with polynomial membership time.
    size reading: d(m)^{c_e} > 2^(2^(cm)), i.e. log2 log2 d > c m - log2 c_e;
    material reading (b): size <= (g+m)(g+m+1)/2, so g > sqrt(2 d) - m - 1;
    reading (a1) (AI-paper Prop E.23(a)): deterministic time 2^(C_a H log2 H) (H^e + 1)^(C_a) must
    exceed 2^(2^(cm)); H := max(h(m), m+1); we print the least H that does it.
Deterministic.  Output: c3_presburger_constants.out
"""
import os
import mpmath as mp

mp.mp.dps = 60
HERE = os.path.dirname(os.path.abspath(__file__))
out_lines = []


def out(s=''):
    out_lines.append(s)
    print(s)


def log2(x):
    return mp.log(x, 2)


def L_of(X, C, m):
    """log2(C 2^X + m) = X + log2(C + m 2^-X).  For X > log2(m) + 400 the term m 2^-X is below
    2^-400, far below the 60-digit precision, and is dropped (the result is then exact to 60 digits)."""
    if X > log2(m) + 400:
        return X + log2(C)
    return X + log2(C + m * mp.power(2, -X))


def condA(m, c, cp, C, k):
    X = mp.power(2, cp * m)
    return log2(k) + log2(L_of(X, C, m)) < c * m


def condB(m, c, cp, C, k):
    a = mp.mpf(cp * m)
    tau = mp.power(2, a)
    return log2(tau + k * L_of(a, C, m)) < c * m


def condC(m, cB, cp, C, k):
    X = mp.power(2, cp * m)
    lT = k * L_of(X, C, m)
    return log2(3 * lT + 2 * log2(max(lT, mp.mpf(2)))) < cB * m


def threshold(cond, *args, M=3000):
    # the inequalities are eventually monotone; scan from M downwards to the last failure
    for m in range(M, 0, -1):
        if not cond(m, *args):
            return 'none' if m == M else m + 1
    return 1


def read_v1():
    path = os.path.join(HERE, 'v1-outputs', 'c3_presburger_constants.v1.out')
    rows = {}
    if not os.path.exists(path):
        return rows
    part = None
    for line in open(path):
        s = line.strip()
        if s.startswith('(A)') or s.startswith('(B)') or s.startswith('(C)'):
            part = s[:3]
            continue
        f = s.split()
        if part and len(f) == 5 and f[0][0].isdigit():
            rows[(part, float(f[0]), float(f[1]), float(f[2]), int(f[3]))] = f[4]
    return rows


def main():
    out('c3_presburger_constants.py (revised; deterministic; mpmath %s, 60 digits)' % mp.__version__)
    v1 = read_v1()
    changed = []
    for name, cond, cname in (('(A) coin-free, tau = 2^(2^(c\'m))', condA, 'c'),
                              ('(B) one tape, tau = 2^(c\'m)', condB, 'c'),
                              ('(C) one tape, tau = 2^(2^(c\'m)), Sigma_2 route', condC, 'c_B')):
        out('')
        out(name)
        out('   %-4s  %-6s  %-9s  %-3s  %-5s  %s' % (cname, "c'", 'C', 'k', 'm0', 'v1 m0'))
        for c in (1.0, 0.5, 0.2, 0.05):
            for frac in (0.9, 0.5, 0.25):
                cp = frac * c
                for C in (10.0, 1e6):
                    for k in (2, 6):
                        m0 = threshold(cond, c, cp, C, k)
                        old = v1.get((name[:3], c, round(cp, 6), C, k), '?')
                        if old == '?':
                            # v1 printed c' with %g; match on rounded values
                            for key, val in v1.items():
                                if key[0] == name[:3] and abs(key[1] - c) < 1e-9 and abs(key[2] - cp) < 1e-6 \
                                        and key[3] == C and key[4] == k:
                                    old = val
                        flag = ''
                        if str(m0) != old:
                            flag = '  <- changed'
                            changed.append((name[:3], c, cp, C, k, old, m0))
                        out('   %-4g  %-6g  %-9g  %-3d  %-5s  %s%s' % (c, cp, C, k, m0, old, flag))
    out('')
    out('Rows whose m0 changed against the development-round output (v1 used the non-conservative')
    out('estimate log2(C 2^a + m) <= a + log2 C + 1): %d' % len(changed))
    for r in changed:
        out('   %s c=%g c\'=%g C=%g k=%d: v1 m0 = %s, exact m0 = %s' % r)
    out('Rows quoted in notes-final.md section 9 (c\' = 0.9c):')
    for part, cond in (('(A)', condA), ('(B)', condB), ('(C)', condC)):
        for c in (1.0, 0.05):
            vals = [threshold(cond, c, 0.9 * c, C, k) for C in (10.0, 1e6) for k in (2, 6)]
            out('   %s c=%g: m0 in [%s, %s]' % (part, c, min(vals), max(vals)))

    out('')
    out('(D) Prop 9.4: budgets forced at sentence length m (illustrative constants)')
    out('   (i) size reading: c'' := any constant below c; threshold from which 2^(cm)/c_e >= 2^(c\'\' m),')
    out('       i.e. m >= log2(c_e)/(c - c\'\'):')
    for c in (1.0, 0.2, 0.05):
        for ce in (2, 10, 100):
            for frac in (0.5, 0.9):
                cpp = frac * c
                m_thr = int(mp.ceil(log2(ce) / (c - cpp)))
                # verify on a window
                ok = all(mp.power(2, c * m) / ce >= mp.power(2, cpp * m) for m in range(max(m_thr, 1), m_thr + 300))
                out('       c=%-5g c_e=%-4d c\'\'=%-6g: from m = %-4d (checked on 300 lengths: %s)'
                    % (c, ce, cpp, m_thr, ok))
    out('   (ii) forced budgets, c = 0.2, c_e = 10; (a1) with C_a = 4, e = 2:')
    out('       %-5s %-22s %-24s %-22s' % ('m', 'size: log2 log2 d >', 'material: log2 log2 g >', '(a1): log2 h >='))
    c, ce, Ca, e = mp.mpf('0.2'), 10, 4, 2
    for m in (20, 40, 80, 160, 320, 640):
        lld = c * m - log2(ce)                       # log2 log2 d
        ld = mp.power(2, lld)                        # log2 d
        lg = (ld + 1) / 2                            # g ~ sqrt(2 d): log2 g = (log2 d + 1)/2 (minus m, negligible)
        llg = log2(lg) if lg > 1 else mp.mpf(0)
        target = mp.power(2, c * m)
        # least H with Ca*H*log2 H + Ca*log2(H^e+1) >= 2^(cm); bisection on log2 H
        lo, hi = mp.mpf(0), mp.mpf(4000)
        for _ in range(200):
            mid = (lo + hi) / 2
            H = mp.power(2, mid)
            val = Ca * H * mid + Ca * log2(mp.power(H, e) + 1)
            if val >= target:
                hi = mid
            else:
                lo = mid
        lh = max(hi, log2(m + 1))
        out('       %-5d %-22s %-24s %-22s' % (m, mp.nstr(lld, 6), mp.nstr(llg, 6), mp.nstr(lh, 6)))
    out('   Reading: log2 log2 d and log2 log2 g grow linearly in m (doubly exponential budgets); under')
    out('   (a1) log2 h grows linearly in m (singly exponential: log2 h ~ cm - log2 m - const).')
    out('')
    out('Reading: in every row of (A)-(C) the inequality holds from some m0 on (for c\' < c it holds once')
    out("2^((c-c')m) exceeds k times a constant), as the proofs need; m0 grows as c' approaches c and as")
    out('c shrinks.  The separations are asymptotic: below m0 a clocked hypothesis may label every short')
    out('sentence correctly.')
    with open(os.path.join(HERE, 'c3_presburger_constants.out'), 'w') as fh:
        fh.write('\n'.join(out_lines) + '\n')


if __name__ == '__main__':
    main()
