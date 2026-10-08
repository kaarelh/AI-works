# Pool-dependence check for E3(b) atomic (Rem pa:e3b; tab:exp:e3b): add the PA-equivalent theory
# frag-atoms + T_Ind = Q + {T_=, T_<, T_Ind} to the E3(b) pool and re-run seed(s) of the atomic generator.
# Read-only use of code/experiments (run with PYTHONDONTWRITEBYTECODE=1); nothing is written outside this folder.
import sys, os, math, json
CODE = '/home/user/AI-works/axiom-induction/code/experiments'
sys.path.insert(0, CODE); sys.path.insert(0, os.path.dirname(CODE))
os.chdir(os.path.dirname(os.path.abspath(__file__)))
import common  # noqa: sets up paths
from bai.theory import Theory
from pa_common import ROOTS, T_frag, QSENT, pa_classify
from dtrc.schemas import T_IND
import e2_pa, e3_misspec
seeds = [int(s) for s in sys.argv[1:]] or [0]
ns = [256, 1024, 2048]
gen = e3_misspec.pa_gen('atomic')
for seed in seeds:
    extra = [Theory(QSENT + [T_IND, T_frag(f)], 'T*+T_%s' % f, {'cls': 'spare'}) for f in ROOTS]
    extra.append(Theory(QSENT + [T_frag('='), T_frag('<'), T_IND], 'frag-atoms+T_Ind', {'cls': 'spare'}))
    out = e2_pa.run(seed, gen=lambda sd: gen(sd, max(ns)), ns=ns, extra_fixed=extra, legacy=False)
    for row in out['rows']:
        b = row['bits']
        fa = b.get('frag-atoms'); fi = b.get('frag-atoms+T_Ind')
        print('seed', seed, 'n', row['n'], 'equiv mass', '%.3g' % row['eq']['yes'], 'T*', '%.3g' % row['T*'],
              'MAP', row['map'], '%.4g' % row['map_post'],
              ' bits(frag-atoms+T_Ind)-bits(frag-atoms) =', None if fa is None or fi is None else round(fi - fa, 2),
              ' implied mass ratio 2^-x =', None if fa is None or fi is None else '%.3g' % 2 ** (-(fi - fa)))
