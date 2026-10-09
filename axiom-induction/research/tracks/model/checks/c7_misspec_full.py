"""c7: misspecification in the full class (notes, Remark 3.5; computed illustration, not a proof).

Human data: 't = 0' with t a random 0/+ tree (P_H: '0' w.p. .7, '+' w.p. .3).  All true; all theorems of Q.
Every sound DT° template covers at most one such datum (notes, Lemma 3.3), so a sound theory covering D_n must spend
one template per distinct datum.  We compare three kinds of L0 theories (Dirichlet(1/2) weights, prior 2^(-lam*l)):
  M  = memorisation of all distinct data seen (sound);
  E  = {z = 0} (unsound: proves S0 = 0);
  H  = ground templates for data seen >= 2 times plus z = 0 (unsound); its marginal likelihood is bounded below by the
       single labelling 'repeated data -> their ground template, the rest -> z = 0'.
Code length of a template: 3 bits per symbol (8-symbol alphabet) + 2 bits per metavariable occurrence; theory code
adds an Elias-gamma code of the number of templates.  Model PCFG for z: 0 .5, S .3, + .1, * .1.
Reported: log2 scores (prior + marginal likelihood) relative to M.  Positive = beats memorisation.
"""
import math
import random
from collections import Counter
from scipy.special import gammaln
from terms import sample_term, q_prob, size

PH = {'0': 0.7, '+': 0.3}
PQ = {'0': 0.5, 'S': 0.3, '+': 0.1, '*': 0.1}
LN2 = math.log(2)

def elias(k):
    return 2 * math.floor(math.log2(k)) + 1

def ground_len(t):          # 't = 0': symbols of t, '=', '0'
    return 3 * (size(t) + 2)

LEN_E = 3 * 3 + 2           # '=', metavariable z, '0'

def log2_dirmult(counts, a=0.5):
    K = len(counts)
    n = sum(counts)
    v = gammaln(K * a) - gammaln(K * a + n) + sum(gammaln(a + c) - gammaln(a) for c in counts)
    return v / LN2

out = []
for lam in (1.0, 2.0):
    for seed in (11, 12, 13):
        rng = random.Random(seed)
        data = []
        rows = []
        checkpoints = [10, 100, 1000, 10000]
        for n in range(1, checkpoints[-1] + 1):
            data.append(sample_term(PH, rng))
            if n in checkpoints:
                cnt = Counter(data)
                # M
                prior_M = -lam * (elias(len(cnt)) + sum(ground_len(t) for t in cnt))
                lik_M = log2_dirmult(list(cnt.values()))
                score_M = prior_M + lik_M
                # E
                score_E = -lam * (elias(1) + LEN_E) + sum(math.log2(q_prob(t, PQ)) for t in data)
                # H
                rep = [t for t, c in cnt.items() if c >= 2]
                singles = [t for t, c in cnt.items() if c == 1]
                prior_H = -lam * (elias(len(rep) + 1) + LEN_E + sum(ground_len(t) for t in rep))
                counts_H = [cnt[t] for t in rep] + [len(singles)]
                lik_H = log2_dirmult(counts_H) + sum(math.log2(q_prob(t, PQ)) for t in singles)
                score_H = prior_H + lik_H
                rows.append((n, len(cnt), score_E - score_M, score_H - score_M))
        for n, k, dE, dH in rows:
            out.append(f"lam={lam} seed={seed} n={n:6d} distinct={k:5d}: score(E)-score(M) = {dE:10.1f} bits,"
                       f" score(H)-score(M) >= {dH:10.1f} bits")
text = "\n".join(out)
print(text)
open(__file__.replace('.py', '.out'), 'w').write(text + "\n")
