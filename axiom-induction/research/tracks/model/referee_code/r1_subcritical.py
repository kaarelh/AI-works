"""r1 (referee): Lemma 1.6 / Definition 1.5 of notes.md -- "subcritical" PCFG over bodies.

Definition 1.5 calls Q subcritical if *every type's* expected number of children per node is < 1, where a type is
(sort, number of variables in scope) and the number of variables grows under binders.  Lemma 1.6 then claims bodies are
finite a.s., by domination with a single-type Galton-Watson process "whose mean offspring is the maximum over types".

Check A.  In L_A (and L_in) every formula-sort production has at least one child: atomic formulas have two term
children, connectives and quantifiers have formula children.  So no PCFG has formula-type mean < 1: the hypothesis of
Lemma 1.6 is unsatisfiable for formula metavariables (e.g. the P of T_Ind).

Check B.  In a signature with a nullary predicate T (true), per-type subcriticality holds but bodies can be infinite:
at a formula node with k variables in scope, choose 'forall' (1 child, k+1 variables) w.p. 1 - 1/(k+2)^2 and the leaf T
otherwise.  Mean children = 1 - 1/(k+2)^2 < 1 for every k, but sup_k = 1, and the forall-chain never stops with
probability prod_{k>=0} (1 - 1/(k+2)^2) = 1/2.  We compute the product and simulate.
"""
import random
import math

out = []

# Check A: minimum number of children over formula productions of L_A
LA_formula_productions = {'=': 2, '<': 2, 'not': 1, 'and': 2, 'or': 2, 'imp': 2, 'iff': 2, 'forall': 1, 'exists': 1}
LIN_formula_productions = {'in': 2, '=': 2, 'not': 1, 'and': 2, 'or': 2, 'imp': 2, 'iff': 2, 'forall': 1, 'exists': 1}
for name, prods in (('L_A', LA_formula_productions), ('L_in', LIN_formula_productions)):
    m = min(prods.values())
    out.append(f"Check A, {name}: least number of children of a formula production = {m}; so every formula type has "
               f"mean children >= {m} for every PCFG (per-type subcriticality impossible)")

# Check B: product and simulation
K = 10**6
logp = sum(math.log1p(-1.0 / (k + 2) ** 2) for k in range(K))
out.append(f"Check B: prod_(k<{K}) (1 - 1/(k+2)^2) = {math.exp(logp):.6f}  (exact infinite product = 1/2)")
rng = random.Random(101)
R = 20_000
CAP = 2_000
survive = 0
for _ in range(R):
    k = 0
    while k < CAP:
        if rng.random() < 1.0 / (k + 2) ** 2:
            break
        k += 1
    if k == CAP:
        survive += 1
out.append(f"Check B: simulated P(forall-chain longer than {CAP}) = {survive / R:.4f} over {R} runs "
           f"(prediction prod_(k<{CAP}) = {math.exp(sum(math.log1p(-1.0/(k+2)**2) for k in range(CAP))):.4f})")
out.append("Check B: every type has mean children < 1, yet bodies are infinite with probability 1/2; "
           "Q_tau then has total mass 1/2, so Lemma 1.6's conclusion fails without a uniform bound sup_k < 1.")

text = "\n".join(out)
print(text)
open(__file__.replace('.py', '.out'), 'w').write(text + "\n")
