# C0: cross-validation of the data-directed enumerator (which relies on the rigid-prefix lemma C2)
# against a data-independent brute force over ALL SO° templates of size <= SB (args of size <= 2,
# arity <= 2, at most 2 nested quantifiers), for several data sets.
import sys, time
from so_core import *
from so_enum import enumerate_covering, gen_all
from so_pool import *

SB = int(sys.argv[1]) if len(sys.argv) > 1 else 9
t0 = time.time()
ALLT = list(gen_all(SB, amax=2, maxar=2, depth_max=2))
print('brute force: %d templates of size <= %d generated in %.0f s' % (len(ALLT), SB, time.time() - t0))
SETS = {
    'anchor {x=x, ~x=0}': ['x=x', '~x=0'],
    'same root {x=x, x+0=x}': ['x=x', 'x+0=x'],
    'x under S only {Sx=S0, ~Sx=0}': ['Sx=S0', '~Sx=0'],
    'vacuous {0=0, ~0=S0}': ['0=0', '~0=S0'],
    'quantified {Ay.(x=y->y=x), x=x->x=0}': ['Ay.(x=y->y=x)', 'x=x->x=0'],
    'singleton {x=0&x=x}': ['x=0&x=x'],
    'non-unitary example (C4)': None,
}
for label, names in SETS.items():
    if names is None:
        def sent(a, b, g): return AND(ALL(plug(a, [V(0)])), AND(ALL(plug(b, [V(0)])), g))
        D = [sent(eq(X, Z), eq(X, X), eq(Z, Z)), sent(NOT(eq(X, Z)), NOT(eq(X, X)), NOT(eq(Z, Z)))]
    else:
        D = [Ind(POOL[n]) for n in names]
    brute = {T for T in ALLT if covers_all(T, D)}
    dd = enumerate_covering(D, SB, amax=2, maxar=2)
    print('%-42s brute-force covering: %5d   data-directed: %5d   identical: %s' % (label, len(brute), len(dd), brute == dd))
print('total %.0f s' % (time.time() - t0))
