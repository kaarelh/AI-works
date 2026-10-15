"""c1: the brief's counterexample to the private-randomness simulator in Hanni's Thm 1 sketch.

Inputs {a, b}; f(a) = f(b) = beta with beta a uniform bit; Delta shows a, then b.
P predicts y1 uniform and y2 = y1.

We compute, with exact rational arithmetic:
  * P's loss (1 bit for each beta);
  * the private-randomness simulator g (each input gets its own simulated history):
    marginals 1/2, 1/2, independent across inputs, so loss 2 bits;
  * the per-input Jensen bound that the sketch relies on, evaluated with the TRUE
    history (0 bits at b) and with the SIMULATED history (1 bit at b): the sketch
    averages over simulated histories, whose labels come from P, not from f;
  * the shared-randomness simulator G (one simulated trajectory, G(x) = label at the
    first visit of x): loss 1 bit;
  * the uniform mixture of the two constant functions (a deterministic-hypothesis
    mixture inside SFI): loss 1 bit.
No randomness is used; the seed is recorded for uniformity with the other checks.
"""
from fractions import Fraction as Fr
from math import log2
import itertools, json, sys

SEED = 0  # unused (exact computation)

Y = [0, 1]

def P_first(y1):
    return Fr(1, 2)

def P_second(y1, y2):
    return Fr(1) if y2 == y1 else Fr(0)

out = {}
for beta in Y:
    # P's sequential probability of (beta, beta)
    pP = P_first(beta) * P_second(beta, beta)
    # private-randomness simulator: g(a) ~ simulated y1; g(b) ~ simulated y2 after simulated (a, y1')
    g_a = {y: P_first(y) for y in Y}
    g_b = {y: sum(P_first(y1) * P_second(y1, y) for y1 in Y) for y in Y}
    p_private = g_a[beta] * g_b[beta]  # independent private randomness
    # shared-randomness simulator: one trajectory (y1', y2'); G(a)=y1', G(b)=y2'
    p_shared = sum(P_first(y1) * P_second(y1, y2)
                   for y1 in Y for y2 in Y if y1 == beta and y2 == beta)
    # uniform mixture of constant functions
    p_const = Fr(1, 2)
    # per-input losses at b
    true_hist_loss_b = -log2(P_second(beta, beta))          # history (a, beta), the true one
    sim_hist_pred_b = g_b[beta]                              # average over simulated histories
    out[beta] = dict(
        P_prob=str(pP), P_loss=-log2(pP),
        private_prob=str(p_private), private_loss=-log2(p_private),
        shared_prob=str(p_shared), shared_loss=-log2(p_shared),
        const_mixture_loss=-log2(p_const),
        per_input_loss_at_b_true_history=true_hist_loss_b,
        per_input_loss_at_b_private_sim=-log2(sim_hist_pred_b),
    )

assert all(out[b]["P_loss"] == 1.0 for b in Y)
assert all(out[b]["private_loss"] == 2.0 for b in Y)
assert all(out[b]["shared_loss"] == 1.0 for b in Y)
print(json.dumps(out, indent=2))
print("RESULT: private simulator loss 2 > P loss 1 for both beta; shared simulator and "
      "constant-function mixture achieve 1. Sketch's 'simulator loss <= P loss' fails; "
      "the theorem is not refuted by this instance.")
