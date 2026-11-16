"""Attack on Corollary 3.6 / 'the asking cannot stop' (finding M1).
Fixed class: N thresholds h_s(x)=1[x<=s], s in {0..N-1}, inputs 1..N-1, weights 1/N (K=log2 N).
Rule: threshold rule Thr_eta with eta < 1/N; abstentions are put to the human (Prop 4.3(a) of the file).
Inputs: (i) uniformly random, (ii) adversarial: always the input that refutes the fewest hypotheses
among those where the rule would abstain (worst case for the number of questions), else random.
Count, over a long horizon h, silent errors, unasked abstentions (0 by construction) and questions."""
import random, math
def run(N, h, adversarial, s, seed):
    rng = random.Random(seed)
    lo, hi = 0, N-1            # consistent thresholds s' in [lo, hi]
    eta = 0.99/N
    sil = qu = 0
    last_q = 0
    for t in range(1, h+1):
        # inputs where rule abstains: x with lo < x <= hi (consistent hypotheses disagree)
        if adversarial and hi > lo:
            # refute fewest: x = hi (answer 1 refutes only s'<x ... choose boundary)
            x = hi if rng.random() < 0.5 else lo+1
        else:
            x = rng.randint(1, N-1)
        V = hi-lo+1
        p1 = sum(1 for sp in range(lo, hi+1) if sp >= x)/V   # posterior M(1|x)
        if p1 >= 1-eta: ans = 1
        elif 1-p1 >= 1-eta: ans = 0
        else: ans = None
        truth = 1 if x <= s else 0
        if ans is None:
            qu += 1; last_q = t
            if truth == 1: lo = max(lo, x)
            else: hi = min(hi, x-1)
        elif ans != truth:
            sil += 1
    return sil, qu, last_q
for N in (16, 64, 256):
    K = math.log2(N)
    for adv in (False, True):
        worst = (0, 0, 0)
        for s in range(N):
            r = run(N, 100000, adv, s, seed=s)
            worst = max(worst, r, key=lambda z: (z[0], z[1]))
        print(f"N={N:4d} K={K:.0f} inputs={'adversarial' if adv else 'random':11s} horizon=1e5: "
              f"max silent errors={worst[0]}, max questions={worst[1]} (bound K ln2/eta={K*math.log(2)*N/0.99:.0f}), "
              f"last question at step {worst[2]}")
print("Theorem 3.3 / Cor 3.6 would require, for Q questions, E[Sil+Abs] >= (N/(Q+1)-(Q+1)/N)/4 only for horizon N-1")
print("and a class of h+1 members: for a FIXED class the asking stops after <= N-1 questions with no silent error.")
