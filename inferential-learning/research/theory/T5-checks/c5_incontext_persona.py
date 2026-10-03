"""Check 5: in-context error learning ('persona' pathology).
Blocks (documents) of steps by one human.  Persona theta in {correct, AC-committer}, prior q.
In an AC-type context the teacher plays the AC move with prob a_theta (else uniform over the
other M-1 moves).  The input to a hypothesis includes the block history, so a FUNCTION
hypothesis (private randomness per input) can still be a Bayes mixture over personas.
Compare per-AC-context log-loss of:
  h_N   : norm model, AC only as noise                       (cost 0 extra bits)
  h_avg : learns the population-average AC rate               (cost ell_AC bits)
  h_ic  : in-context mixture over personas (posterior from block history)  (cost ell_AC + ~3 bits)
as a function of K = number of AC-type contexts per block."""
from math import log2
M, eta, q = 64, 0.05, 0.3
a = {"corr": eta / M, "AC": (1 - eta) + eta / M}
prior = {"corr": 1 - q, "AC": q}
def loss(atheta, b):
    return -(atheta * log2(b) + (1 - atheta) * log2((1 - b) / (M - 1)))
def risk_const(b):
    return sum(prior[t] * loss(a[t], b) for t in prior)
bN = eta / M; bavg = q * a["AC"] + (1 - q) * a["corr"]
RN, Ravg = risk_const(bN), risk_const(bavg)
Rorc = sum(prior[t] * loss(a[t], a[t]) for t in prior)          # persona known (Bayes risk of teacher)

def risk_ic(K):
    """average per-AC-context log-loss of the in-context Bayes mixture over K contexts in a block"""
    tot = 0.0
    for t in prior:
        # distribution over number of AC moves observed so far: dynamic programming
        dist = {0: 1.0}                                   # count of AC moves seen -> prob
        for k in range(K):
            new = {}
            for s, pr in dist.items():
                # posterior AC-persona given s AC moves among k observations
                la = log2(prior["AC"]) + s*log2(a["AC"]) + (k-s)*log2(1-a["AC"])
                lc = log2(prior["corr"]) + s*log2(a["corr"]) + (k-s)*log2(1-a["corr"])
                mx = max(la, lc); wa = 2**(la-mx); wc = 2**(lc-mx); pa = wa/(wa+wc)
                b = pa*a["AC"] + (1-pa)*a["corr"]
                tot += prior[t] * pr * loss(a[t], b)
                new[s+1] = new.get(s+1, 0) + pr*a[t]
                new[s] = new.get(s, 0) + pr*(1-a[t])
            dist = new
    return tot / K

print(f"per-AC-context log-loss: norm {RN:.3f}, population-average {Ravg:.3f}, persona-oracle {Rorc:.3f}")
ell_AC, piA = 20, 0.02          # bits for the AC schema; AC-type contexts per step
for K in [1, 2, 4, 8, 32, 128]:
    Ric = risk_ic(K)
    print(f"  K={K:4d} AC-contexts/block: in-context mixture {Ric:.3f}  "
          f"rate(h_avg)={piA*(RN-Ravg)/ell_AC:.2e}  rate(h_ic)={piA*(RN-Ric)/(ell_AC+3):.2e}")
print("=> the in-context component's rate grows with block length toward the persona-oracle rate;\n"
      "   a c that rejects the population-average error can still admit in-context error imitation.")

# ---- many idiosyncratic personas: a single cheap 'copier' covers all of them ----------------
# Error contexts have a large move space M2 (free-form wrong steps).  A fraction q of humans has
# an idiosyncratic rule 'in error contexts play move j' with j uniform over M2 (so each rule
# costs log2 M2 bits as a component, and the population average of all rules is uniform: no
# single component is worth learning).  Correct humans play the valid move v.  The in-context
# Bayes mixture over {correct} U {persona j} has O(1) description length (it is 'copy this
# human's own earlier error'), and is a function of the input because the input contains the
# block history.
import random
random.seed(0)
M2, q2, eta2 = 2**16, 0.2, 0.05
def predictive(hist):
    """Bayes mixture predictive for the next move given this block's history; returns dict"""
    # weights: correct (prior 1-q2), persona j for each j seen in hist, plus 'unseen persona' mass
    def lik(rule, h):
        L = 1.0
        for mv in h:
            L *= (1-eta2+eta2/M2) if mv == rule else eta2/M2
        return L
    w = {"v": (1-q2)*lik("v", hist)}
    seen = set(hist) - {"v"}
    for j in seen: w[j] = (q2/M2)*lik(j, hist)
    unseen_mass = (q2/M2)*(M2-len(seen))*lik("__none__", hist)   # personas not yet seen
    Z = sum(w.values()) + unseen_mass
    return w, unseen_mass, Z
def prob_of(move, hist):
    w, um, Z = predictive(hist)
    p = 0.0
    for rule, wt in w.items():
        p += wt/Z * ((1-eta2+eta2/M2) if move == rule else eta2/M2)
    # unseen personas: each assigns (1-eta2+eta2/M2) to its own move
    if move != "v" and move not in w:
        p += um/Z * ((1-eta2+eta2/M2)/(M2-len(w)+1) + eta2/M2)
    else:
        p += um/Z * eta2/M2
    return p
e_n = q2*(1 - eta2/M2) + (1-q2)*eta2*(M2-1)/M2      # calibrated flat noise rate for the norm model
def norm_prob(move):
    return (1-e_n) if move == "v" else e_n/(M2-1)
for K in [1, 2, 4, 16]:
    tot_ic = tot_n = 0.0; T = 4000
    for _ in range(T):
        persona = "v" if random.random() > q2 else random.randrange(M2)
        hist = []
        for k in range(K):
            mv = persona if random.random() < 1-eta2 else random.randrange(M2)
            tot_ic += -log2(prob_of(mv, hist)); tot_n += -log2(norm_prob(mv))
            hist.append(mv)
    print(f"  copier, K={K:2d} error-contexts/block: per-context loss norm {tot_n/(T*K):6.3f}, "
          f"in-context copier {tot_ic/(T*K):6.3f}")
print("=> with K >= 2 the O(1)-bit copier beats the norm model on every error context, although\n"
      "   each idiosyncratic rule alone (16 bits, used by q/M2 of humans) has rate ~ 0.")
