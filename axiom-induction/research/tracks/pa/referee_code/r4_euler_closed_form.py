# r4_euler_closed_form.py -- referee for track "pa", F4 (c5_euler.py).  Independent recomputation of
# L(H_mem) - L(H_sch) from the final counts with closed-form Dirichlet(1/2) marginals (lgamma), instead of the
# track's sequential KT updates; the data are the same draws (same seeds, same rejection sampler).  Also: the effect
# of the track's size formula, whose comment says that m occurs twice in
#   Prime(m) := ~m=0 & ~m=S0 & Aa Ab (a*b = m -> a = S0 v b = S0),
# while m occurs three times there.  Output: r4_euler_closed_form.out next to this script.
import math, random, os
HERE = os.path.dirname(os.path.abspath(__file__))
lg = math.lgamma
def isprime(m):
    if m < 2: return False
    d = 2
    while d * d <= m:
        if m % d == 0: return False
        d += 1
    return True

def dir_bits(counts, a):
    """-log2 Dirichlet(1/2) marginal of a count vector over an alphabet of size a (unlisted symbols have count 0)."""
    n = sum(counts)
    v = lg(a / 2) - lg(n + a / 2) + sum(lg(c + 0.5) - lg(0.5) for c in counts)
    return -v / math.log(2)

def sizes(occ):
    msz = lambda k: 3 * (k + 1) + 42 + 3          # numerals k, k, k, 41 and the symbols *, +, +
    frame = 22 if occ == 2 else 27                 # 27: the logical frame of the definition above, counted by hand
    datum = lambda k: occ * msz(k) + frame
    templ = occ * (3 * 1 + 42 + 3) + frame
    return datum, templ

def run(rho, seed, checkpoints, occ):
    rng = random.Random(seed)
    datum, templ = sizes(occ)
    ks = []
    out = {}
    nmax = max(checkpoints)
    for t in range(1, nmax + 1):
        while True:
            k = int(math.log(1 - rng.random()) / math.log(rho))
            if isprime(k * k + k + 41): break
        ks.append(k)
        if t in checkpoints:
            from collections import Counter
            cnt = Counter(ks)
            # H_sch, flat grammar: one binary context; numeral k = k symbols 'S' then '0'
            ones = sum(ks); zeros = t
            Lflat = 5 * templ + dir_bits([zeros, ones], 2)
            # H_sch, depth grammar: context d; datum k emits 'S' at depths 0..k-1 and '0' at depth k
            maxk = max(ks)
            ge = [0] * (maxk + 2)                  # ge[d] = #data with k >= d
            for kk, c in cnt.items():
                ge[kk] += c
            for d in range(maxk, -1, -1):
                ge[d] += ge[d + 1] if d + 1 <= maxk + 1 else 0
            Ldepth = 5 * templ
            for d in range(maxk + 1):
                eq_d = cnt.get(d, 0)               # emit '0' at depth d
                gt_d = ge[d] - eq_d                # emit 'S' at depth d
                Ldepth += dir_bits([eq_d, gt_d], 2)
            # H_mem: one ground axiom per distinct value, index code over the m axioms (in hindsight)
            Lmem = 5 * sum(datum(kk) for kk in cnt) + dir_bits(list(cnt.values()), len(cnt))
            out[t] = (len(cnt), Lmem - Lflat, Lmem - Ldepth)
    return out

lines = []
TRACK = {0.9: {100: (34920, 34848), 1000: (62051, 61905), 10000: (108705, 108491), 100000: (151955, 152216),
               1000000: (209380, 215537)},
         0.97: {100: (82519, 82353), 1000: (304073, 303660), 10000: (555168, 555281), 100000: (846132, 855034),
                1000000: (1184382, 1285163)}}
CPS = (100, 1000, 10000, 100000, 1000000)
for rho, seed in ((0.9, 5), (0.97, 6)):
    r2 = run(rho, seed, CPS, 2)
    r3 = run(rho, seed, CPS, 3)
    lines.append('rho=%.2f seed %d: L(H_mem)-L(H_sch) [flat, depth]; track c5_euler.out; with m counted 3 times' % (rho, seed))
    for n in CPS:
        m, f, d = r2[n]
        _, f3, d3 = r3[n]
        tf, td = TRACK[rho][n]
        lines.append('  n=%8d m=%4d  closed form %9.0f %9.0f   track %9d %9d   (3 occurrences: %9.0f %9.0f)'
                     % (n, m, f, d, tf, td, f3, d3))
open(os.path.join(HERE, 'r4_euler_closed_form.out'), 'w').write('\n'.join(lines) + '\n')
print('\n'.join(lines))
