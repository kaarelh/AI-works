# Theory: generalization bounds for the circuit-growth picture

Four derivations, written by separate agents and checked numerically by their own scripts in [`checks/`](checks/). The overview is [Part 2.3 of the project README](../README.md#23-generalization-bounds).

| file | question | main results | review status |
|---|---|---|---|
| [`A-discrete-model.md`](A-discrete-model.md) | bounds for the discrete model | **A1:** Occam bound uniform over circuit size. **A2:** training time bounds depth, incoherent size $T\le\kappa(\tau/\Theta)^2$ and readout $\ell_1$ norm, but not the raw gate count. **A3:** fresh-batch SGD reproduces the population run under utility gaps. **A4:** greedy versus minimum circuits. | Refereed twice. Round 1 failed (one mislabelled claim, five major issues); revision 2 fixed all of them, and the round-2 referee passed it, with only minor prose issues left (7). |
| [`B-nn-time-bounds.md`](B-nn-time-bounds.md) | bounds for the actual network, with no discrete model | Displacement bounds as a function of time (gradient flow, GD, SGD, Adam). Norm-based bounds are vacuous even at initialization. PAC-Bayes centred at initialization is non-vacuous at $n=16384$ and for short runs. Online progressive validation. | Refereed twice. Round 1 failed on two overclaims in Theorem B3.3; revision 2 restricted "linear in training time" to gradient flow and GD under a descent condition and added an a-priori SGD version under smoothness. Round 2 passed, with only minor issues left (8). |
| [`C-bridge-and-certificates.md`](C-bridge-and-certificates.md) | from networks to circuits | **C1:** distillation certificates from unlabelled inputs, the only non-vacuous bounds on the real networks. **C2:** rigorous "time limits size" for diagonal linear networks. **C3:** conditional transfer to ReLU networks. **C4:** online-to-batch. | Refereed twice. Round 1 passed with required revisions (3 major); revision 2 fixed them, and round 2 passed, with only minor issues left (10). |
| [`D-early-phase-theorem.md`](D-early-phase-theorem.md) | an a-priori theorem for real networks | **Part I, two-layer ReLU:** exact mass-clock race identity; no growth before about $\log(1/\alpha)/U^*$; width-free generalization through the first escape; conditional persistence (D4.1); Conjecture D4 beyond. **Part II, two-layer quadratic networks with fixed output signs (symmetric matrix sensing):** log-det clock, number of grown units $\le\kappa(\tau/\Theta)^2$, generalization uniform in time. | Refereed once: pass with minor issues ([`checks/referee_D_r1.json`](checks/referee_D_r1.json)). These include: the merging law is the classical balancedness conservation law, not new; Part II's network has fixed output signs; Theorem D7's nesting claim needs a fixed grid; and some prose and number slips. Not yet revised. |

**Round-1 referee findings on A, all addressed in revision 2 (kept here for the record).** The core results A1, A2.1, A2.3 and A2.4 were checked and stand. The following were flagged:
- **Proposition A3.4(2)** (multi-epoch reuse reproduces the full-batch race) is labelled Proved but is not proved. Read it as Heuristic.
- **Proposition A2.2(3)** (duplicate gates always fire together) is false as stated: a later-available duplicate lags and, under least-squares refits, never fires.
- **Lemma 2.2(4)** ($\alpha$ only sets the unit of time) holds only for the pure attach-move race, not once fresh chains with thresholds $\sim\alpha^{-(k-2)}$ are added.
- **The summary's "SGD reproduces the population run"** holds only for the greedy argmax model under the stated utility-gap assumption.
- **Corollary A2.5(a)** depends on the data-dependent $\kappa(t)$, so it is not a bound in terms of training time alone.
- **A gap in Proposition A4.2(2)**, which the referee closed.
- **Minor issues:** constants, citation details, and a sign bug in a check script that does not affect the reported numbers.

Status labels follow [`neural-network-generalization/`](../../neural-network-generalization/TECHNICAL-FAQ.md). "Proved" means a complete proof in the file; none of this has been reviewed by a human.
