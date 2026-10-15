"""Referee check for notes.md Prop 5.1 / Cor 5.2 ("order independence characterises Bayesian
random-function predictors"; "SFI is the universal element of that class").

(1) An order-independent sub-probability predictor that is NOT the Bayes predictor of any random
    partial function: q(0|a,{}) = 1, q(0|b,{}) = 1, q(.|b,{a->0}) = q(.|a,{b->0}) = 0 (labels {0,1}).
    We verify order independence by brute force and show by LP that no law P on partial functions
    {a,b} -> {0,1,undef} has P(F contains D) = nu(D) for all D (infeasible), where nu is the product
    of one-step probabilities.
(2) For tau (foundations Example 2.4; three inputs) we recompute by LP the largest c such that some law
    P has P(F contains D) >= c * tau(D) for all D: c = 2/3.  So a random-function law (in particular
    M_F, which is a law of a random partial function) can only dominate such order-independent
    predictors with a loss; foundations Thm 3.5(iii) iterates this to an unbounded gap.
(3) Normalised case: a random total-label predictor (q sums to 1) built from a random law is checked to
    be order independent and to equal its law (sanity).
Exact LP via scipy.optimize.linprog (HiGHS).  Deterministic (no randomness except (3), seeded).
"""
import itertools
from fractions import Fraction

import numpy as np
from scipy.optimize import linprog

OUT = []


def log(s):
    OUT.append(s)
    print(s)


def datasets(inputs, labels):
    """all partial functions from inputs to labels, as frozensets of pairs"""
    res = []
    for dom_size in range(len(inputs) + 1):
        for dom in itertools.combinations(inputs, dom_size):
            for ys in itertools.product(labels, repeat=dom_size):
                res.append(frozenset(zip(dom, ys)))
    return res


def laws(inputs, labels):
    """atoms: total maps inputs -> labels + undefined (None)"""
    return list(itertools.product(list(labels) + [None], repeat=len(inputs)))


def contains(atom, inputs, D):
    m = dict(zip(inputs, atom))
    return all(m[x] == y for x, y in D)


def check_weak(nu, inputs, labels):
    viol = 0
    for D in datasets(inputs, labels):
        dom = {x for x, _ in D}
        for x in inputs:
            if x in dom:
                continue
            s = sum(nu(D | {(x, y)}) for y in labels)
            if s > nu(D) + 1e-12:
                viol += 1
    return viol


def order_independent(nu, inputs, labels):
    """predictor q(y|x,D) = nu(D+(x,y))/nu(D) (0 if nu(D)=0); products along all enumerations equal?"""
    worst = 0.0
    for D in datasets(inputs, labels):
        vals = []
        for perm in itertools.permutations(sorted(D)):
            prod, cur = 1.0, frozenset()
            for (x, y) in perm:
                q = nu(cur | {(x, y)}) / nu(cur) if nu(cur) > 0 else 0.0
                prod *= q
                cur = cur | {(x, y)}
            vals.append(prod)
        worst = max(worst, max(vals) - min(vals)) if vals else worst
    return worst


def lp_equal(nu, inputs, labels):
    atoms = laws(inputs, labels)
    Ds = datasets(inputs, labels)
    A = np.array([[1.0 if contains(a, inputs, D) else 0.0 for a in atoms] for D in Ds])
    b = np.array([nu(D) for D in Ds])
    res = linprog(np.zeros(len(atoms)), A_eq=A, b_eq=b, bounds=[(0, None)] * len(atoms), method="highs")
    return res.status  # 0 = feasible optimum found, 2 = infeasible


def lp_dominate(nu, inputs, labels):
    """max c s.t. exists prob law P with P(F contains D) >= c nu(D) for all D"""
    atoms = laws(inputs, labels)
    Ds = datasets(inputs, labels)
    n = len(atoms)
    # variables: P_atoms (n), c ; maximise c
    cvec = np.zeros(n + 1)
    cvec[-1] = -1.0
    A_ub, b_ub = [], []
    for D in Ds:
        row = [-1.0 if contains(a, inputs, D) else 0.0 for a in atoms] + [nu(D)]
        A_ub.append(row)
        b_ub.append(0.0)
    A_eq = [[1.0] * n + [0.0]]
    res = linprog(cvec, A_ub=np.array(A_ub), b_ub=np.array(b_ub), A_eq=np.array(A_eq), b_eq=np.array([1.0]),
                  bounds=[(0, None)] * (n + 1), method="highs")
    return -res.fun


def main():
    log("(1) two inputs a,b; nu({})=nu({a->0})=nu({b->0})=1, all else 0")
    ins, labs = ["a", "b"], [0, 1]

    def nu1(D):
        D = frozenset(D)
        if D in (frozenset(), frozenset({("a", 0)}), frozenset({("b", 0)})):
            return 1.0
        return 0.0

    log(f"  one-point (weak) inequality violations: {check_weak(nu1, ins, labs)}")
    log(f"  max spread of the product of one-step probabilities over enumerations: {order_independent(nu1, ins, labs)}")
    st = lp_equal(nu1, ins, labs)
    log(f"  LP 'exists a law of a random partial function with P(F contains D) = nu(D) for all D': "
        f"status {st} ({'INFEASIBLE' if st == 2 else 'feasible'})")
    log(f"  LP max c with P >= c nu: {lp_dominate(nu1, ins, labs):.6f} (domination is easy here: F = 0 everywhere)")

    log("\n(2) tau of foundations Example 2.4: inputs a,b,c; singletons 1/2; E1={(a,0),(b,1)}, E2={(b,0),(c,1)}, "
        "E3={(c,0),(a,1)} get 1/2; all else 0")
    ins3 = ["a", "b", "c"]
    E = [frozenset({("a", 0), ("b", 1)}), frozenset({("b", 0), ("c", 1)}), frozenset({("c", 0), ("a", 1)})]

    def tau(D):
        D = frozenset(D)
        if len(D) == 0:
            return 1.0
        if len(D) == 1:
            return 0.5
        if D in E:
            return 0.5
        return 0.0

    log(f"  one-point inequality violations: {check_weak(tau, ins3, labs)}")
    log(f"  order-independence spread: {order_independent(tau, ins3, labs)}")
    log(f"  LP equality with a random-partial-function law: status {lp_equal(tau, ins3, labs)} (2 = infeasible)")
    c = lp_dominate(tau, ins3, labs)
    log(f"  LP max c with P(F contains D) >= c tau(D): {c:.12f} (2/3 = {2/3:.12f})")

    log("\n(3) sanity: normalised predictor from a random law on 3 inputs x 2 labels (no undefined values)")
    rng = np.random.default_rng(7)
    atoms = list(itertools.product(labs, repeat=3))
    p = rng.dirichlet(np.ones(len(atoms)))

    def nu3(D):
        return float(sum(pi for a, pi in zip(atoms, p) if contains(a, ins3, D)))

    log(f"  weak violations {check_weak(nu3, ins3, labs)}; order-independence spread {order_independent(nu3, ins3, labs):.2e}; "
        f"LP equality status {lp_equal(nu3, ins3, labs)} (0 = feasible)")
    log("\nReading: order independence characterises WEAK function semimeasures, not laws of random partial")
    log("functions (only in the normalised case does it give a random total function).  Since M_F is a random-")
    log("function law, the order-independent ideal is the universal weak semimeasure M^w, which exceeds M_F by up")
    log("to 2^{K(dom D)} (foundations Thm 3.5); Cor 5.2's premise (H1(a) for the weak class) is false.")
    with open(__file__.replace(".py", "_output.txt"), "w") as fh:
        fh.write("\n".join(OUT) + "\n")


if __name__ == "__main__":
    main()
