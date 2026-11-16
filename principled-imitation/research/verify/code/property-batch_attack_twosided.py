# Adversary's Proposition X2 (a two-sided form of Theorem 6.2(d), with ONE function for a whole weighted family of decision rules).
# Setting: m inputs drawn independently from mu (as in validation: independent of the human's answers), then a decision rule D on the m pairs.
# Claim: with probability >= 1 - eta over F (independent values F(x) ~ P0(.|x)), for all rules D of a family with weights pi_D:
#     | Pr_{P_F}[D accepts] - Pr_{P0}[D accepts] |  <=  C(m,2) coll(mu) + m sqrt( coll(mu) ln(2/(pi_D eta)) / 2 ).
# Pure Python.  Run:  python3 property-batch_attack_twosided.py > property-batch_attack_twosided.out
import math, random, itertools
from math import log, sqrt, comb
random.seed(31337)

# ---------------------------------------------------------------- (1) exhaustive: u = 12 inputs, uniform, coin, m = 2, all 2^12 functions, arbitrary rules
u, m = 12, 2
rules = []
for _ in range(8):
    table = {key: random.randrange(2) for key in itertools.product(range(u), (0, 1), range(u), (0, 1))}
    rules.append(table)
# two structured rules: "the two answers agree", and "the two answers agree and the two inputs differ"
rules.append({k: int(k[1] == k[3]) for k in itertools.product(range(u), (0, 1), range(u), (0, 1))})
rules.append({k: int(k[1] == k[3] and k[0] != k[2]) for k in itertools.product(range(u), (0, 1), range(u), (0, 1))})
M = len(rules); pi = 1.0/M
a0 = [sum(t[(x1, y1, x2, y2)] for x1 in range(u) for x2 in range(u) for y1 in (0, 1) for y2 in (0, 1))/(4.0*u*u) for t in rules]
print(f"(1) exhaustive check: {u} inputs (uniform), fair coin, m = {m} independent inputs, {M} decision rules (8 arbitrary, 2 structured), all 2^{u} functions F:")
devs = []
for fm in range(2**u):
    F = [(fm >> x) & 1 for x in range(u)]
    devs.append([abs(sum(t[(x1, F[x1], x2, F[x2])] for x1 in range(u) for x2 in range(u))/(u*u) - a0[i]) for i, t in enumerate(rules)])
for eta in (0.5, 0.1, 0.01):
    bound = comb(m, 2)/u + m*sqrt(log(2/(pi*eta))/(2*u))
    bad = sum(1 for d in devs if max(d) > bound + 1e-12)
    print(f"    eta = {eta}: bound = {bound:.4f}; fraction of functions with some rule beyond the bound = {bad/2**u:.6f} (must be <= eta); largest deviation = {max(max(d) for d in devs):.4f}")
# the bias term alone: E_F of the acceptance probability minus the coin's, for the rule "the two answers agree"
i_agree = M-2
meanF = sum(sum(rules[i_agree][(x1, ((fm >> x1) & 1), x2, ((fm >> x2) & 1))] for x1 in range(u) for x2 in range(u))/(u*u) for fm in range(2**u))/2**u
print(f"    rule 'the two answers agree': Pr_coin = {a0[i_agree]:.4f}; average over F = {meanF:.4f}; difference {meanF-a0[i_agree]:.4f} = (1/2) Pr[the two inputs coincide] = {0.5/u:.4f} <= C(m,2) coll = {1/u:.4f}")

# ---------------------------------------------------------------- (2) larger scale, exact acceptance probabilities for rules of product form
# rule (S, T, mode): accept iff [(x1,y1) in S] op [(x2,y2) in T], op = AND or XOR; acceptance probabilities are computed exactly from
# the frequencies s = mu{(x, F(x)) in S}, t = mu{(x, F(x)) in T} and the overlap on the diagonal x1 = x2.
u, m = 600, 2; nrules = 40; eta = 0.1; pi = 1.0/nrules
rules = []
for _ in range(nrules):
    S = [[random.randrange(2) for _ in (0, 1)] for _ in range(u)]
    T = [[random.randrange(2) for _ in (0, 1)] for _ in range(u)]
    rules.append((S, T, random.choice(["and", "xor"])))
def acc_F(rule, F):
    S, T, mode = rule
    s = sum(S[x][F[x]] for x in range(u))/u; t = sum(T[x][F[x]] for x in range(u))/u
    return s*t if mode == "and" else s*(1-t) + (1-s)*t                       # exact also on the diagonal: both draws use the same F
def acc_coin(rule):
    S, T, mode = rule
    sb = sum(S[x][0] + S[x][1] for x in range(u))/(2.0*u); tb = sum(T[x][0] + T[x][1] for x in range(u))/(2.0*u)
    return sb*tb if mode == "and" else sb*(1-tb) + (1-sb)*tb                 # answers are independent draws, also when x1 = x2
a0 = [acc_coin(r) for r in rules]
bound = comb(m, 2)/u + m*sqrt(log(2/(pi*eta))/(2*u))
trials = 1500; bad = 0; worst = 0.0
for _ in range(trials):
    F = [random.randrange(2) for _ in range(u)]
    dev = max(abs(acc_F(r, F) - a0[i]) for i, r in enumerate(rules))
    worst = max(worst, dev)
    if dev > bound: bad += 1
print(f"(2) {u} inputs, m = 2, {nrules} rules of product form, {trials} random functions: bound = {bound:.4f}; functions with some rule beyond the bound: {bad} (allowed {eta:.0%}); largest deviation {worst:.4f}")
print("    Every one of these functions is at total variation 1/2 from the coin at every input.")
