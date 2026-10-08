"""r3 (referee): scope of Theorem 4.1 (time-uniform soundness) and Prop 4.2 of notes.md.

Part 1.  Theorem 4.1 is proved in setting W (fixed weights).  The default model of Def 1.3 uses Dirichlet weights, and
section 5.4 and the 'what can be promised' paragraph apply the theorem there.  With Dirichlet weights the generator
class C* has prior mass 0 (a point in a continuous simplex), and the Ville argument needs L_t(T*) to be the true
likelihood, which the Dirichlet marginal is not.  Counterexample at a fixed interior w*:
  * PCFG Q on closed terms, root law p = (p0, pS, p+, p*) = (0.5, 0.5 - eps, eps/2, eps/2)  (subcritical).
  * Truth: T* = {0+0=0, (Sz)+0=Sz} with weights w* = (p0, pS)/(1-eps); data i.i.d. from P_{T*,w*} (L0).
  * Competitor: T' = {z+0=z}, a single template (no weights).  T' proves q := (0*0)+0 = 0*0; T* does not
    (term model: + returns its first argument on (a, 0) only when a has root 0 or S).
  * Class {T*, T'}, prior 1/2 each; T* has Dir(1/2,1/2) weights.  The verifier accepts q iff pi_n(T*) <= delta.
  * Log-ratio log P_T'(D) - log P^Dir_T*(D) = n0 ln p0 + nS ln pS - ln DirMult(n0, nS; 1/2) (children factors cancel).
  The analogue of Theorem 4.1 would bound P(exists n: accept q) by delta / pi(T*) = 0.02.  We estimate it, checking only
  a geometric grid of n (so the estimate is a lower bound).  Contrast A: fixed weights (never accepted).  Contrast B:
  w* drawn from the Dirichlet prior (Bayes-averaged well-specification), where Ville's bound does hold.

Part 2.  Prop 4.2 says a prover that 'submits S0 = 0 in every round' gets it accepted with probability 1.  Under the
protocol of section 4 the verifier may ESCALATE a query it does not accept; the oracle's answer kills T_esc.  We run
Example 3.4's class with a verifier that escalates every non-accepted query: the non-adaptive prover never succeeds,
while a prover that waits until pi(T_esc) >= 1 - delta succeeds always.
"""
import math
import numpy as np
from scipy.special import gammaln

out = []
rng = np.random.default_rng(303)

def ln_dirmult2(n0, n1, a=0.5):
    return gammaln(2 * a) - gammaln(2 * a + n0 + n1) + gammaln(a + n0) + gammaln(a + n1) - 2 * gammaln(a)

delta = 0.01
pi_star = 0.5
thresh = math.log((1 - delta) / delta * pi_star / (1 - pi_star))     # accept iff log-ratio >= thresh
out.append(f"Part 1: delta = {delta}, pi(T*) = pi(T') = 1/2; accept q iff log P_T'/P^Dir_T* >= {thresh:.3f}; "
           f"claimed bound delta/pi(T*) = {delta / pi_star:.3f}")

R = 2000
for eps in (1e-3, 1e-4, 1e-5, 1e-6):
    p0, pS = 0.5, 0.5 - eps
    w0 = p0 / (1 - eps)
    nmax = int(8 / eps)
    grid = np.unique(np.geomspace(1, nmax, 600).astype(np.int64))
    steps = np.diff(np.concatenate([[0], grid]))
    for mode in ('fixed w*', 'w* ~ Dir prior'):
        hits = 0
        best = []
        for r in range(R):
            w = w0 if mode == 'fixed w*' else rng.beta(0.5, 0.5)
            inc = rng.binomial(steps, w)
            n0 = np.cumsum(inc)
            n1 = grid - n0
            lr = n0 * math.log(p0) + n1 * math.log(pS) - ln_dirmult2(n0, n1)
            best.append(lr.max())
            hits += bool((lr >= thresh).any())
        out.append(f"  eps = {eps:.0e}, {mode:15s}: P(exists n <= {nmax}: q accepted) >= {hits / R:.3f}"
                   f"   (median of max log-ratio = {np.median(best):.2f})")
    # fixed-weight contrast: ratio P_T'/P_{T*,w*} = (1-eps)^n <= 1, so pi_n(T*) >= 1/2 always
out.append("  contrast A (fixed weights, the setting of Thm 4.1): P_T'/P_{T*,w*} = (1-eps)^n <= 1, so pi_n(T*) >= 1/2 "
           "and q is never accepted.")

# ---------------- Part 2 ----------------
PH = {'0': 0.7, '+': 0.3}
PQ = {'0': 0.5, 'S': 0.3, '+': 0.1, '*': 0.1}

def sample_tree(rng, p):
    syms = list(p)
    probs = np.array([p[s] for s in syms])
    def rec():
        s = syms[rng.choice(len(syms), p=probs)]
        if s == '0':
            return ('0',)
        return ('+', rec(), rec())
    return rec()

def qprob(t, p):
    r = p[t[0]]
    for c in t[1:]:
        r *= qprob(c, p)
    return r

def all_trees(maxsize):
    by = {1: [('0',)]}
    for n in range(2, maxsize + 1):
        by[n] = [('+', a, b) for k in range(1, n - 1) for a in by[k] for b in by[n - 1 - k]]
    return [t for v in by.values() for t in v]

small = sorted(all_trees(9), key=lambda t: -qprob(t, PH))
m = 20
cov = small[:m]
covset = [set(cov[:j + 1]) for j in range(m)]
covmass = [sum(qprob(t, PH) for t in cov[:j + 1]) for j in range(m)]
prior = np.array([0.99 / m] * m + [0.01])
R2 = 400
res = {'non-adaptive, escalating verifier': 0, 'waiting prover, escalating verifier': 0}
for prover in res:
    for r in range(R2):
        logpost = np.log(prior)
        esc_dead = False
        accepted = False
        for n in range(1, 2001):
            t = sample_tree(rng, PH)
            ph = qprob(t, PH)
            for j in range(m):
                if np.isfinite(logpost[j]):
                    logpost[j] = logpost[j] + math.log(ph / covmass[j]) if t in covset[j] else -np.inf
            if np.isfinite(logpost[m]):
                logpost[m] += math.log(qprob(t, PQ))
            if not np.isfinite(logpost).any():
                break                      # every theory dead: posterior undefined, nothing accepted
            mx = logpost[np.isfinite(logpost)].max()
            w = np.where(np.isfinite(logpost), np.exp(logpost - mx), 0.0)
            pesc = w[m] / w.sum()
            submit = (prover.startswith('non-adaptive')) or (pesc >= 1 - delta)
            if submit:
                if pesc >= 1 - delta:      # non-deriving mass = 1 - pesc <= delta: ACCEPT
                    accepted = True
                    break
                logpost[m] = -np.inf       # not accepted: ESCALATE; oracle says S0=0 is not a Q-theorem
        res[prover] += accepted
for k, v in res.items():
    out.append(f"Part 2: {k}: S0 = 0 accepted in {v}/{R2} runs")

text = "\n".join(out)
print(text)
open(__file__.replace('.py', '.out'), 'w').write(text + "\n")
