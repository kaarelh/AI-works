"""Independent, much more thorough soundness re-check of the final active schemas
of a few algebra coherence runs (the reported 'unsound active = 0' claims)."""
import sys, itertools, random, time
sys.path.insert(0, "/home/user/AI-works/inferential-learning/code")
sys.path.insert(0, "/home/user/AI-works/inferential-learning/code/experiments")
from fractions import Fraction
import mpmath
import exp_algebra_learning as E
from cil.domains import algebra as alg
from cil.learners import LGGLearner, CoherenceConfig, CoherenceRepairer
from cil.domains.algebra import ALGEBRA, WorldOracle

VALS = [alg.UNDEF, Fraction(0), Fraction(1), Fraction(-1), Fraction(2), Fraction(-2), Fraction(1, 2),
        Fraction(-3, 7), mpmath.sqrt(2), -mpmath.sqrt(2)]

def grid_cex(rule, cap=200000):
    vs = rule.vars()
    obj = sorted(alg.atoms(rule.lhs) | alg.atoms(rule.rhs))
    keys = ["?" + v for v in vs] + obj
    n = 0
    for combo in itertools.product(range(len(VALS)), repeat=len(keys)):
        n += 1
        if n > cap:
            break
        env = {}
        ok = True
        for k, i in zip(keys, combo):
            val = VALS[i]
            if not k.startswith("?") and val is alg.UNDEF:
                ok = False; break     # object atoms are always-defined reals
            env[k] = val
        if not ok:
            continue
        g_ok = True
        for p, v in rule.guard.atoms:
            val = env["?" + v]
            if val is alg.UNDEF or (p == "nonzero" and alg._sign(val) == 0) or (p == "nonneg" and alg._sign(val) < 0):
                g_ok = False; break
        if not g_ok:
            continue
        try:
            if not alg.values_equal(alg.evaluate(rule.lhs, env), alg.evaluate(rule.rhs, env)):
                return env
        except alg.EvalSkip:
            continue
    return None

def run(N, noise, seed, learner, mode):
    steps = E.corpus_steps(N, noise, seed)
    tagged, gmode, m, gs = E.LEARNERS[learner]
    calc = LGGLearner(ALGEBRA, tagged=tagged, guard_mode=gmode, m=m, gen_support=gs).fit(steps=steps)
    cfg = CoherenceConfig(mode=mode, seed=seed, allow_split=True, **E.BUDGETS["default"])
    CoherenceRepairer(calc, cfg, oracle=WorldOracle(seed=7000 + seed)).run()
    bad = []
    for s in calc.active():
        r = s.rule
        c1 = alg.schema_counterexample(r, random.Random(987654 + s.sid), n=20000)
        c2 = grid_cex(r)
        if c1 is not None or c2 is not None:
            bad.append((str(r), c1 is not None, c2 is not None))
    return len(calc.active()), bad

if __name__ == "__main__":
    for task in [(500, "both", 0, "tagged", "step"), (500, "both", 1, "untagged", "step"),
                 (500, "both", 2, "tagged", "bag"), (200, "fallacies", 0, "untagged", "bag"),
                 (100, "clean", 1, "tagged", "step")]:
        t0 = time.time()
        n, bad = run(*task)
        print(task, "active", n, "unsound(thorough)", bad, f"{time.time()-t0:.0f}s", flush=True)
