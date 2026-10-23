# Theory: generalization bounds for the circuit-growth picture

Three derivations, written by separate agents and checked numerically by their own scripts in [`checks/`](checks/). The overview is [Part 2.3 of the project README](../README.md#23-generalization-bounds).

| file | question | main results | review status |
|---|---|---|---|
| [`A-discrete-model.md`](A-discrete-model.md) | bounds for the discrete model | **A1:** Occam bound uniform over circuit size. **A2:** training time bounds depth, incoherent size $T\le\kappa(\tau/\Theta)^2$ and readout $\ell_1$ norm, but not the raw gate count. **A3:** fresh-batch SGD reproduces the population run under utility gaps. **A4:** greedy versus minimum circuits. | Refereed once (see below). A repair pass was started at the end of the session; check the file's "Revision notes" section, if present, for what it changed. |
| [`B-nn-time-bounds.md`](B-nn-time-bounds.md) | bounds for the actual network, with no discrete model | Displacement bounds as a function of time (gradient flow, GD, SGD, Adam). Norm-based bounds are vacuous even at initialization. PAC-Bayes centred at initialization is non-vacuous at $n=16384$ and for short runs. Online progressive validation. | Refereed once: every proof step checked and found correct. Two major overclaims in Theorem B3.3: the "KL term grows linearly in training time" holds only for part (a), gradient flow and GD under the descent condition, not for the SGD and Adam parts (b) and (c); and its 'Reading' paragraph overstates what is rigorous for SGD. There are also minor number and prose slips. Not repaired. |
| [`C-bridge-and-certificates.md`](C-bridge-and-certificates.md) | from networks to circuits | **C1:** distillation certificates from unlabelled inputs, the only non-vacuous bounds on the real networks. **C2:** rigorous "time limits size" for diagonal linear networks. **C3:** conditional transfer to ReLU networks. **C4:** online-to-batch. | Not refereed. |

**Referee findings on A (round 1).** The core results A1, A2.1, A2.3 and A2.4 were checked and stand. The following were flagged:
- **Proposition A3.4(2)** (multi-epoch reuse reproduces the full-batch race) is labelled Proved but is not proved. Read it as Heuristic.
- **Proposition A2.2(3)** (duplicate gates always fire together) is false as stated: a later-available duplicate lags and, under least-squares refits, never fires.
- **Lemma 2.2(4)** ($\alpha$ only sets the unit of time) holds only for the pure attach-move race, not once fresh chains with thresholds $\sim\alpha^{-(k-2)}$ are added.
- **The summary's "SGD reproduces the population run"** holds only for the greedy argmax model under the stated utility-gap assumption.
- **Corollary A2.5(a)** depends on the data-dependent $\kappa(t)$, so it is not a bound in terms of training time alone.
- **A gap in Proposition A4.2(2)**, which the referee closed.
- **Minor issues:** constants, citation details, and a sign bug in a check script that does not affect the reported numbers.

Status labels follow [`neural-network-generalization/`](../../neural-network-generalization/TECHNICAL-FAQ.md). "Proved" means a complete proof in the file; none of this has been reviewed by a human.
