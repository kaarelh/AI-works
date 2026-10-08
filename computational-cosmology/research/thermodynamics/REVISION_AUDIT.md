# Audit of the computational-cosmology revision

8 October 2026. Reviewed the abstract, main sections 6–7, Appendix D's serial hardware model, and Appendix F in the current `report.md`. No report edits made.

**Verdict:** no substantive blocker in the thermodynamic conclusions. The revision successfully separates universal information constraints, declared hardware contracts, and conditional implementations. One small implementation-rounding issue should be clarified before treating the checkpoint formulas as an exact feasibility certificate.

## Clarification recommended

**Appendix F, full versus partial blocks.** The displayed checkpoint formulas assume $L\mid D$. Merely comparing neighboring integer values of $L$ does not ensure that condition. The text acknowledges at most one additional block's costs, but the subsequent “whenever some $L$ satisfies” sufficiency claim should explicitly apply to the rounded execution. Either require divisible blocks and optimize admissible divisors, or test the actual final partial block / reserve a complete extra block before certifying memory, time, and entropy budgets. The clipped $\sqrt{A/C}$ optimum is exact for the continuous full-block expression and is a good long-run design guide; partial-block effects can change the exact short-run integer optimum.

For an exact conservative implementation with provisioned memory $M=2q+\alpha L$ and $n=\lceil D/L\rceil$ blocks, one can simply use

$$t=2D\tau_0+nt_c,\qquad B=2D\sigma+nb_c+\mu M t.$$

These retain the same total forward/reverse step count, charge a full checkpoint primitive for the final block, and maintain the provisioned memory throughout. They remove ambiguity without changing the asymptotic result. The time formula presumes one block can contain fewer than $L$ steps; that primitive's controller must already be included in the stated accounting.

## Checked and approved

- **Checkpoint construction:** the compute–copy–uncompute–reset sequence genuinely uses two classical configuration registers plus bounded history. Copying is explicitly classical. Full-block entropy expansion, coefficients $A,C,K$, the continuous optimum, and memory/deadline inequalities are correct. Costs and total error guarantees are appropriately conditional; conditional erasure, setup, controllers, and experiential-process limitations are stated.
- **Checkpoint numbers:** reran `frontier_calculations.py`. The three quoted entropy costs are $1.000000000009$, $0.001002006009$, and $2.8284321\times10^{-6}$. The reported rounding is correct.
- **Archive bound:** Nayak's random-access-code inequality applies to the specified independent uniform classical records, with all correlated storage counted. Its use at every prefix is justified by data processing: future independent randomness cannot reconstruct previously discarded independent detail. Positive maintenance and a minimum serial interval give exactly $\mu c_\varepsilon\nu\tau_{\min}D(D-1)/2$, excluding post-completion storage. The report correctly treats zero maintenance and compressible/replayed/discarded histories as different cases.
- **Archive numbers:** $1-H_2(.01)=0.9192068641$; for one record bit per step and $B=D=10^{120}$, the necessary target is $\mu\tau_{\min}\lesssim2.1757888\times10^{-120}$. Both displayed values are correct. This is a hardware target, not an empirical estimate or impossibility claim.
- **Serial model:** Cauchy's bound, equal-duration saturation, deadline-limited formula, unrestricted plateau, and one-dimensional minimum-tick optimization are correct. Holding $a,\gamma$ fixed while varying $q$ gives the stated inverse-square-root depth dependence. The requirement to charge output storage after early completion is included.
- **Figure computation:** inspected `analysis/feasible_region.py`. Its normalized depth curves, minimum-tick branch boundaries, and maximum-memory expression agree with the stated serial model. The plotted region does not claim more than its declared primitive contracts. This was a code/algebra review, not a new rendering audit.
- **Main presentation:** sections 6–7 clearly distinguish generic arbitrary quantum targets from large structured quantum computers, erasure from logical work, storage from depth, and thermodynamic efficiency from throughput. The archive paragraph is appropriately task-specific. Abstract claims near these results retain the hardware-model qualification.
- **Older material retained in these sections:** thermal-channel times, activation-barrier example, one-shot Brownian terminal trap, and finite-state counter qualifications remain consistent with the earlier audits. No new concern found; not all underlying literature was re-researched this round.

## Optional editorial trimming

The simple $A/\tau+\Gamma\tau$ optimization near the end of Appendix F repeats the now fuller treatment in main section 7 and Appendix D. It can be replaced by a cross-reference without losing content. This is an editorial suggestion, not a correctness issue.
