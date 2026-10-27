# Bounds on f with unlabeled inputs (Theorem 2; the setting of Bazinet et al. 2026) and on g (Occam)

Best over K compression configurations per trained f; the disagreement term uses delta/(2K).

| data | widths | params | train err f | test err f | float32 Occam | VC | configs K | best T1 (bound on g) | bits | test err g | best T2 (bound on f, unlabeled) | bits | Pr[f≠g] on test inputs | config |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| mnist | [784, 100, 10] | 79510 | 0.0015 | 0.0229 | 1.00 | 1.00 | 27 | 0.2755 | 18367 | 0.0372 | 0.3129 | 18367 | 0.0302 | dct/mixed/rel=2.0/lam=10.0 |
| fashion | [784, 100, 10] | 79510 | 0.0771 | 0.1168 | 1.00 | 1.00 | 8 | 0.4217 | 16590 | 0.1527 | 0.5324 | 16590 | 0.0997 | dct/mixed/rel=2.0/lam=10.0 |
| mnist | [784, 256, 10] | 203530 | 0.0008 | 0.0197 | 1.00 | 1.00 | 15 | 0.3426 | 28144 | 0.0278 | 0.3716 | 28144 | 0.0229 | dct/labels/rel=2.0/lam=10.0 |
| fashion | [784, 256, 10] | 203530 | 0.0672 | 0.1106 | 1.00 | 1.00 | 8 | 0.5118 | 28751 | 0.1445 | 0.6195 | 28751 | 0.0968 | dct/mixed/rel=2.0/lam=10.0 |

## Ablation: first-layer update coded in the pixel basis instead of the DCT basis

| data | widths | params | train err f | test err f | float32 Occam | VC | configs K | best T1 (bound on g) | bits | test err g | best T2 (bound on f, unlabeled) | bits | Pr[f≠g] on test inputs | config |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| mnist | [784, 100, 10] | 79510 | 0.0015 | 0.0229 | 1.00 | 1.00 | 8 | 0.3273 | 23518 | 0.0404 | 0.3695 | 23518 | 0.0352 | id/distill/rel=2.0/lam=10.0 |
