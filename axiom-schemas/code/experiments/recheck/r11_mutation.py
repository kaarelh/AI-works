"""R11: mutation test of the referee's ZF checker: inject plausible bugs into ZFEval and confirm the
finite-structure check detects them (validates the power of R3/R4)."""
import sys, random
sys.path.insert(0, '/home/user/AI-works/axiom-schemas/code')
import dtrc.oracle_zf as OZ
from dtrc.datasets import rand_zf_formula
from dtrc.syntax import canon_params
from indep_eval import Struct, qdepth, strip_close

orig_eq, orig_in, orig_quant = OZ.ZFEval._eq, OZ.ZFEval._in, OZ.ZFEval.quant
def bad_eq(a, b):           # mutation 1: generic never equals a concrete set
    r = orig_eq(a, b)
    return False if r is None else r
def bad_in(a, b):           # mutation 2: generic never an element of a concrete set
    r = orig_in(a, b)
    if isinstance(a, OZ.Gen) and not isinstance(b, OZ.Gen):
        return False
    return r
def bad_quant(self, isall, body, env, level):   # mutation 3: forget the in-scope generics case
    gens = [x for x in env if isinstance(x, OZ.Gen)]
    saved = list(env)
    return orig_quant(self, isall, body, env, level)

def run(name):
    rng = random.Random(5)
    structs = [Struct(random.Random(5 + i), 6, p, q) for i, (p, q) in enumerate(((0, 0), (0.3, 0.3), (0.8, 0.6)))]
    ev = OZ.ZFEval(); bad = 0; n = 0
    while n < 600:
        params = rng.choice([[], ['c'], ['c', 'd']])
        f = canon_params((rng.choice(['all', 'ex']), rand_zf_formula(rng, 0, 1, params, rng.randint(2, 5))))
        if qdepth(strip_close(f)) > 4: continue
        r = ev.truth(f)
        if r is None: continue
        n += 1
        if any(M.truth(f) != r for M in structs): bad += 1
    print(name, 'contradictions detected: %d / %d definitive verdicts' % (bad, n))

run('original')
OZ.ZFEval._eq = staticmethod(bad_eq); run('mutation: G=c always False'); OZ.ZFEval._eq = staticmethod(orig_eq)
OZ.ZFEval._in = staticmethod(bad_in); run('mutation: G in c always False'); OZ.ZFEval._in = staticmethod(orig_in)

def make_quant(drop):
    def quant(self, isall, body, env, level):
        conn = 'imp' if isall else 'and'
        if body[0] == conn and body[1][0] == 'in' and body[1][1] == ('v', 0) and OZ.no_v0(body[1][2]):
            tv = self.val(body[1][2], [None] + env)
            if not isinstance(tv, OZ.Gen):
                return self.combine(isall, (self.ev(body[2], [x] + env, level + 1) for x in OZ.sorted_elems(tv)))
        concretes = [x for x in env if not isinstance(x, OZ.Gen)]
        gens = [x for x in env if isinstance(x, OZ.Gen)]
        E = OZ.tc_with(concretes) if concretes else OZ.EMPTY
        self.ngen += 1
        newg = OZ.Gen(self.ngen, E, tuple(g.id for g in gens))
        cases = ([] if drop == 'fresh' else [newg]) + ([] if drop == 'gens' else gens) + OZ.sorted_elems(E)
        unknown = False
        for x in cases:
            r = self.ev(body, [x] + env, level + 1)
            if isall and r is False: return False
            if (not isall) and r is True: return True
            if r is None: unknown = True
        if not unknown:
            return True if isall else False
        return None
    return quant
for drop in ('gens', 'fresh'):
    OZ.ZFEval.quant = make_quant(drop); run('mutation: drop %s case' % drop)
OZ.ZFEval.quant = make_quant(None); run('re-implementation without HF search (control)')
OZ.ZFEval.quant = orig_quant
