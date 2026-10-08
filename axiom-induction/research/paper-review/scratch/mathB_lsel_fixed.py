"""Review B: L1-sel with a background and a FIXED common weight (the case Thm univ:B does not list).
C_min, B = {sigma_psi} with instances disjoint from sigma_phi's, S = closed quantifier-free sentences.
Under L1-sel, B (+)_w forall x phi gives phi-instances total weight w_e = w c/(1-w+w c), B (+)_w sigma_phi gives w.
Data: closed instances only, i.i.d. with phi-proportion v*.  The per-datum log odds (forall : sigma) depend only
on the label (phi or psi) because the term factors Q(t) cancel."""
import math, random

c, w = 0.3, 0.5
we = w * c / (1 - w + w * c)
print(f'c={c}, fixed w={w}: effective weight of the forall-version under L1-sel w_e={we:.4f}')
for vstar, label in [(we, 'data = filtered output of B(+)forall'), (w, 'data = output of B(+)sigma'), (0.35, 'other')]:
    rng = random.Random(0)
    lo = 0.0
    for n in range(1, 2001):
        if rng.random() < vstar:
            lo += math.log(we / w)
        else:
            lo += math.log((1 - we) / (1 - w))
    kl = vstar * math.log(vstar / w) + (1 - vstar) * math.log((1 - vstar) / (1 - w)) \
        - (vstar * math.log(vstar / we) + (1 - vstar) * math.log((1 - vstar) / (1 - we)))
    print(f'  v*={vstar:.4f} ({label}): log odds forall:sigma after n=2000 closed instances = {lo:+.1f}; drift {kl:+.4f} nats/datum')
