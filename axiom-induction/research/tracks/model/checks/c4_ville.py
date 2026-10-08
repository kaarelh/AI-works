"""c4: the thresholded verifier against provers (notes, Thm 4.1 and Prop 4.2).

Part 1, well specified.  L0 with fixed weights; T* = {z+0=z}, P*(t+0=t) = Q(t).
Competitor T_alt = {z+0=z (weight 1-w-w'), S0+0=S0 (weight w), 0+0=S0 (weight w')}.  T_alt proves q := 0+0=S0, T* does not.
The verifier accepts q iff posterior({T : q not in Th(T)}) <= delta, i.e. iff pi_n(T*) <= delta (T* is the only non-prover of q).
Thm 4.1 (Ville): P[exists n: pi_n(T*) <= delta] <= delta / pi(T*).  We estimate the left side.

Part 2, misspecified.  Human states 't = 0' with t a random 0/+ tree (all true, all Q-theorems).
Finite class: m sound theories (ground equations for the m most likely human data, best-case weights) and T_esc = {z = 0}
with the model PCFG.  T_esc proves S0 = 0.  A prover that submits S0 = 0 every round gets it accepted as soon as
pi_n(T_esc) >= 1 - delta.  Prop 4.2: this happens with probability 1.
"""
import math
import random
from terms import sample_term, q_prob, show

P = {'0': 0.5, 'S': 0.3, '+': 0.1, '*': 0.1}
out = []

# ---------------- Part 1 ----------------
rng = random.Random(4)
S0 = ('S', ('0',))
w, w2 = 0.5, 0.01
pi_star = 0.3
for delta in (0.03, 0.01, 0.003):
    bound = delta / pi_star
    hits = 0
    R = 20000
    for _ in range(R):
        logodds = math.log((1 - pi_star) / pi_star)  # log pi_n(T_alt)/pi_n(T*)
        hit = False
        for n in range(300):
            t = sample_term(P, rng)
            qs = q_prob(t, P)
            p_alt = (1 - w - w2) * qs + (w if t == S0 else 0.0)
            logodds += math.log(p_alt / qs)
            pi_n = 1 / (1 + math.exp(logodds))
            if pi_n <= delta:
                hit = True
                break
        hits += hit
    out.append(f"Part 1: delta = {delta}: P[exists n<=300: pi_n(T*) <= delta] ~ {hits/R:.4f}"
               f"  (Ville bound delta/pi(T*) = {bound:.4f})")

# ---------------- Part 2 ----------------
PH = {'0': 0.7, '+': 0.3}   # human: 0/+ trees only, all with value 0

def sample_h(rng):
    return sample_term(PH, rng)

# the m most likely human trees (enumerate small trees and sort)
from terms import enumerate_terms
small = [t for n, ts in enumerate_terms(9, symbols=('0', '+')).items() for t in ts]
small.sort(key=lambda t: -q_prob(t, PH))
m = 20
covered = small[:m]
cov_mass = [sum(q_prob(t, PH) for t in covered[:j]) for j in range(1, m + 1)]
out.append(f"Part 2: human mass covered by the j most likely data, j = 1, 5, 10, 20: "
           f"{cov_mass[0]:.3f}, {cov_mass[4]:.3f}, {cov_mass[9]:.3f}, {cov_mass[19]:.3f}")
# prior: sound theories T_j (j = 1..m) share mass 0.99, T_esc gets 0.01
pri = [0.99 / m] * m + [0.01]
delta = 0.01
rng = random.Random(5)
R = 2000
accept_times = []
for _ in range(R):
    logpost = [math.log(p) for p in pri]
    acc_t = None
    for n in range(1, 2001):
        t = sample_h(rng)
        ph = q_prob(t, PH)
        # sound theory T_j: best-case weights = human probabilities renormalised on its support
        for j in range(m):
            if logpost[j] == -math.inf:
                continue
            if t in covered[:j + 1]:
                logpost[j] += math.log(ph / cov_mass[j])
            else:
                logpost[j] = -math.inf
        logpost[m] += math.log(q_prob(t, P))   # T_esc = {z = 0}: P(t = 0) = Q(t)
        mx = max(logpost)
        z = sum(math.exp(l - mx) for l in logpost if l > -math.inf)
        pi_esc = math.exp(logpost[m] - mx) / z
        if pi_esc >= 1 - delta:
            acc_t = n
            break
    accept_times.append(acc_t)
done = [a for a in accept_times if a is not None]
out.append(f"Part 2: delta = {delta}: S0 = 0 accepted (a non-theorem of Q, false) in {len(done)}/{R} runs within 2000 data;"
           f" median acceptance time {sorted(done)[len(done)//2] if done else None}")
for nmax in (10, 50, 100, 500):
    out.append(f"   fraction accepted by n = {nmax}: {sum(1 for a in done if a <= nmax)/R:.3f}")

text = "\n".join(out)
print(text)
open(__file__.replace('.py', '.out'), 'w').write(text + "\n")
