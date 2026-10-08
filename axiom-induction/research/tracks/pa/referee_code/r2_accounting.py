# r2_accounting.py -- referee for track "pa": (a) Prop. 4.1 (cost of a spare slot) in closed form at every n of
# c4_bdtrc.out; (b) the "constant" SDPC margin of section 2.2; (c) which split templates H_root actually uses under
# the usage laws G1, G2, G3, and what L(H_root) - L(H_true) becomes when the prior charges every template of H_root
# (the track's c2_mdl.codelength charges only the templates that some datum uses, while the KT index code still
# ranges over all of them).  Deterministic (data regenerated with the track's seeds random.Random(n)).
# Output: r2_accounting.out next to this script.
import sys, os, math, random
sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
OUT = []
def say(s=''):
    print(s, flush=True); OUT.append(s)

# ---------------------------------------------------------------------------------------------- (a) Prop 4.1
say('(a) Prop. 4.1: cost of a never-used template tau added to K templates, Dirichlet(1/2) weights')
say('    exact = beta|tau| + log2[ Gamma(K/2) Gamma(n+(K+1)/2) / (Gamma((K+1)/2) Gamma(n+K/2)) ]')
lg = math.lgamma
K, tau_bits = 8, 5 * 3        # Q1..Q7 + T_Ind; tau = (F -> F), 3 symbols at 5 bits
reported = {10: 15.9, 30: 16.6, 100: 17.4, 300: 18.2, 1000: 19.0, 3000: 19.8}   # c4_bdtrc.out, spare row
for n, rep in reported.items():
    exact = tau_bits + (lg(K / 2) + lg(n + (K + 1) / 2) - lg((K + 1) / 2) - lg(n + K / 2)) / math.log(2)
    asym = tau_bits + 0.5 * math.log2(n) + (lg(K / 2) - lg((K + 1) / 2)) / math.log(2)
    say('    n=%5d  exact %7.3f   asymptotic formula %7.3f   c4 output %5.1f' % (n, exact, asym, rep))

# ---------------------------------------------------------------------------------------------- (b) SDPC drift
say()
say('(b) SDPC margin L(H_root)-L(H_true) from c2_mdl.out, and its slope per doubling of n')
SDPC = {'G1': {1000: 770, 4000: 768, 16000: 766, 64000: 764, 256000: 762},
        'G2': {1000: 415, 4000: 413, 16000: 411, 64000: 409, 256000: 407}}
for g, row in SDPC.items():
    ns = sorted(row)
    slope = (row[ns[-1]] - row[ns[0]]) / math.log2(ns[-1] / ns[0])
    say('    %s: %s   slope %.2f bits per doubling; extrapolated zero crossing at log2 n = %.0f'
        % (g, row, slope, math.log2(ns[0]) + row[ns[0]] / -slope))

# ---------------------------------------------------------------------------------------------- (c) prior bookkeeping
say()
say('(c) roots used by the induction data, and the prior of the split templates that H_root lists but never uses')
sys.path.insert(0, os.path.join(HERE, '..', 'checks'))
import c2_mdl
from dtlib import size
from practice import pa_data
SPLIT, ROOTS, TBITS = c2_mdl.SPLIT, c2_mdl.ROOTS, c2_mdl.TBITS
say('    template sizes |T_f| (symbols): ' + ', '.join('%s %d' % (f, size(SPLIT[f])) for f in ROOTS)
    + ';  |T_Ind| = %d' % size(c2_mdl.T_IND))
REPORTED = {   # c2_mdl.out, the 'root' (full split) column per mode
    'G2': {'SDPC': {1000: 415, 4000: 413, 16000: 411, 64000: 409, 256000: 407},
           'DPC': {1000: 1428, 4000: 2116, 16000: 2822, 64000: 3564, 256000: 4313}},
    'G3': {'SDPC': {1000: 300, 4000: 298, 16000: 296, 64000: 294, 256000: 292},
           'RDPC': {1000: 946, 4000: 1326, 16000: 1760, 64000: 2189, 256000: 2596}}}
GEN = {'G1': lambda n, r: pa_data(n, r, p_ind=0.5), 'G2': c2_mdl.g2_data, 'G3': c2_mdl.g3_data}
for g in ('G1', 'G2', 'G3'):
    for n in (1000, 4000, 16000, 64000, 256000):
        data = GEN[g](n, random.Random(n))
        used = sorted({s[2][1][0] for k, s in data if not k.startswith('Q')})
        unused = [f for f in ROOTS if f not in used]
        missing = TBITS * sum(size(SPLIT[f]) for f in unused)
        line = '    %s n=%6d  roots used %-38s unused %-26s prior not charged: %4d bits' % (
            g, n, used, unused, missing)
        if g in REPORTED:
            line += ';  corrected margins: ' + ', '.join(
                '%s %+d -> %+d' % (m, REPORTED[g][m][n], REPORTED[g][m][n] + missing) for m in REPORTED[g])
        say(line)
open(os.path.join(HERE, 'r2_accounting.out'), 'w').write('\n'.join(OUT) + '\n')
