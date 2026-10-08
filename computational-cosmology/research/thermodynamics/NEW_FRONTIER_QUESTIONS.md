# Two sharper questions about feasible cosmic computation

Research memo · 8 October 2026 · For incorporation into the computational-cosmology report

**Recommendation.** Add a concrete family of reversible implementations to the feasible-computation model, and distinguish a long execution from a long *retrievable record*. The first gives a conditional inner region; the second supplies a task-dependent outer constraint. Neither supplies a hardware-independent maximum gate count. These are new consequences developed here from existing reversible-computation and information-theory results, not claims of a new general theorem about physical computers.

## 1. How reversible should a computation be when memory has a carrying cost?

Reversible simulation does not have to mean keeping every intermediate state forever. Bennett established time–space tradeoffs, and Li, Tromp, and Vitányi explicitly studied exchanging additional irreversible erasures for less storage. Their optimality statements concern specified pebble-game models; more general reversible simulators can behave differently. In particular, the existence of space-efficient but exponentially slow simulations prevents promoting a pebbling lower bound into an unrestricted physical impossibility. [Bennett, 1989](https://doi.org/10.1137/0218053); [Li, Tromp & Vitányi, 1998](https://arxiv.org/abs/quant-ph/9703009); [Buhrman, Tromp & Vitányi, 2001](https://arxiv.org/abs/quant-ph/0101133).

A useful addition for cosmology is to charge *how much memory must remain reliable, and for how long*. Here is a deliberately simple architecture whose feasible region can be calculated completely.

### Declared construction and hardware premises

A classical computation has a complete working configuration of at most $q$ bits and $D$ simulated steps. Program state, counters, and required controller storage belong in $q$ or in explicitly reserved overhead. Choose a block length $L$.

1. Simulate $L$ steps reversibly, recording at most $\alpha L$ history bits.
2. Copy the resulting $q$-bit classical configuration into a blank checkpoint register.
3. Reverse those $L$ steps, clearing their history while restoring the old configuration.
4. Reset the old configuration and interchange register roles. Continue from the new checkpoint.

This needs two configuration registers plus history:

$$M(L)=2q+\alpha L.$$

Let a forward or reverse simulation step take $\tau_0$ seconds and consume $\sigma$ entropy bits through dynamic/control imperfections. Let the checkpoint copy, reset, and register switch together take $t_c$ seconds and consume $b_c$ entropy bits. Finally, assume the chosen protection protocol consumes $\mu$ entropy bits per provisioned memory bit per second. Maintaining blank scratch cells is included: they must still be usable as known blank cells. All entropy quantities are measured in $k_B\ln2$ units.

These are assumed properties of a hardware protocol, not universal physical constants. In particular, $b_c=q$ is an idealized *oblivious-reset budget*, not a proof that the conditional entropy of the old checkpoint is $q$. Side information or special structure can reduce the actual erasure cost. The costs, durations, and error guarantee of a reset primitive must be jointly attainable; the model does not assert exact finite-time Landauer saturation.

For $D$ divisible by $L$, ignoring one-time setup and output handoff that must be budgeted separately, this implementation has

$$t(L)=D\left(2\tau_0+\frac{t_c}{L}\right),$$

$$B(L)=D\left[2\sigma+\frac{b_c}{L}+\mu(2q+\alpha L)\left(2\tau_0+\frac{t_c}{L}\right)\right].$$

Rounding the last block changes the corresponding expression by at most one block's costs. One can omit a final unnecessary reset. Such changes matter for short computations but not the long-run tradeoff.

This is an explicit **conditional implementation family**: an $L$ satisfying $M(L)\le M_{\max}$, $t(L)\le T$, and $B(L)\le B_{\max}$ supplies a point in the toy model's feasible region. It is not a necessary condition for other implementations. Physical feasibility also requires the stipulated primitives and maintenance protocol to meet the task's total failure allowance over the actual duration.

### The optimum amount of history

Write entropy per simulated step as

$$h(L)=\frac{A}{L}+C L+K,$$

where

$$A=b_c+2\mu q t_c,\qquad C=2\mu\alpha\tau_0,$$

$$K=2\sigma+4\mu q\tau_0+\mu\alpha t_c.$$

For $C>0$, the unconstrained optimum is

$$L_* = \sqrt{A/C},\qquad h_*=2\sqrt{AC}+K.$$

The $A/L$ term penalizes frequent checkpoint resets. The $CL$ term penalizes preserving a longer scratch history throughout computation. These are different physical costs, so the optimum can be finite even when more memory is available.

For a fixed target depth $D$, memory imposes

$$L\le L_{\max}=\min\!\left[D,\frac{M_{\max}-2q}{\alpha}\right].$$

A deadline requires $T>2D\tau_0$ and

$$L\ge L_{\min}=\max\!\left[1,\frac{D t_c}{T-2D\tau_0}\right]$$

when $t_c>0$. If the interval is empty, this architecture cannot meet the task. Otherwise clip $L_*$ to that interval and evaluate $B(L)$; compare neighboring integers for the discrete optimum. If $t_c=0$, omit the fraction and allow the baseline duration. For $\mu=0$ there is no maintenance-driven finite optimum: larger blocks weakly improve the reset cost. A fully reversible simulator or a reversible algorithm designed for the task can improve on this construction.

**Consequence:** useful extra memory can substitute for entropy expenditure, but its benefit saturates for this implementation. Beyond the optimum, keeping additional history actually makes the execution more expensive. A very tight deadline can force longer blocks to amortize copying, moving the chosen design away from its entropy optimum.

### Numerical illustration, not a hardware forecast

Take $q=10^6$, $\alpha=1$, $b_c=q$, $t_c=q\tau_0$, $\sigma=0$, and $\mu\tau_0=10^{-18}$. These values simply display the dependence; no empirical longevity model supports extrapolating them to cosmological runtimes. Then $L_*=7.07\times10^{11}$ steps.

| Available memory bits | Chosen $L$ | Entropy bits per simulated step | Physical time per step, in units of $\tau_0$ |
|---:|---:|---:|---:|
| $3\times10^6$ | $10^6$ | $1.00$ | $3.00$ |
| $10^9$ | $9.98\times10^8$ | $1.002\times10^{-3}$ | $2.001002$ |
| $10^{12}$ | $7.07\times10^{11}$ | $2.828\times10^{-6}$ | $2.0000014$ |

This simple feasible family produces roughly a $3.5\times10^5$ difference in entropy per simulated step as the memory provision changes. The example shows why fitting one universal entropy-per-gate parameter is an inadequate physical model.

**Limits.** Other checkpoint schedules, non-oblivious erasure, an intrinsically reversible algorithm, or a different noise-protection method may dominate this family. A quantum state cannot generally be copied as used here. Moreover, a simulator that reproduces an input–output relation is not automatically an acceptable realization of a specified internal experience: its reversals and extra work count if the requested causal process makes them relevant. Complete error and controller costs cannot be hidden in ideal copying or assumed away in $\mu$.

## 2. Can an arbitrarily long history remain individually retrievable?

A long-lived small-state process and a growing archive are different tasks. Suppose each of $D$ steps supplies $\nu$ independent, unbiased classical record bits, and after the execution one must be able to request any particular record bit and recover it with error at most $\epsilon<1/2$. Include every accessible register correlated with those bits in the memory accounting; an uncharged external copy is not allowed.

Even quantum storage does not turn this arbitrary classical archive into logarithmic-size memory. Nayak's random-access-code theorem gives

$$Q_{\rm archive}\ge c_\epsilon\nu D,\qquad c_\epsilon=1-H_2(\epsilon).$$

The theorem concerns a decoder for any chosen coordinate, and already applies when only one such query need be answered. Repeated reliable use can impose additional requirements. [Nayak, 1999, Theorem 2.3](https://arxiv.org/abs/quant-ph/9904093).

Thus an archive-memory cap $M_{\max}$ imposes a genuine task-specific depth bound $D\le M_{\max}/(c_\epsilon\nu)$, independently of whether the computation's gates are reversible. This statement does not say that a history's number of moments equals its amount of independent information.

### Adding a physical memory carrying cost gives a stronger consequence

Suppose, additionally, each bit or qubit of available encoded storage requires at least $\mu$ entropy bits per second to maintain, and successive record-generating steps require at least $\tau_{\min}$ seconds. Both assumptions belong to an architecture, and neither has been proved universally. After $j$ steps, the accessible encoded state must preserve sufficient information about the first $\nu j$ bits: future independent randomness cannot restore information that has been lost. Applying the same coding bound at each prefix and summing the required storage time yields

$$B_{\rm archive}\ge\mu c_\epsilon\nu\tau_{\min}\sum_{j=1}^{D-1}j
=\frac{\mu c_\epsilon\nu\tau_{\min}}{2}D(D-1).$$

The sum excludes all retention after the final record, so it is favorable to the computer. Added idle periods only increase the bound. If a record is exported, the counted archive moves with it whenever later retrieval remains part of the task. If one is happy to discard it permanently, the task has changed.

Consequently,

$$D\lesssim\min\!\left[\frac{M_{\max}}{c_\epsilon\nu},\sqrt{\frac{2B_{\max}}{\mu c_\epsilon\nu\tau_{\min}}}\right].$$

**The distinction matters:** fixed-state maintenance costs grow linearly with duration at a fixed speed. Maintaining an expanding irreducible archive through a serial history costs quadratically in the history's length under this protection model. Reversible logic by itself does not remove that growing storage-time requirement.

For $\epsilon=.01$, $c_\epsilon=0.9192069$. A depth-$10^{120}$ history with one independent retained bit per step therefore needs at least $9.19\times10^{119}$ archive qubits or classical bits of equivalent encoded dimension. To fit its archive maintenance inside $10^{120}$ entropy bits requires

$$\mu\tau_{\min}\lesssim2.18\times10^{-120}.$$

This is a conditional performance target, not a claim that it cannot be attained. Passive perfectly stable storage would set $\mu=0$ and remove this particular maintenance bound. For orientation only, choosing $\mu\tau_{\min}=10^{-18}$ in the toy model instead gives $D\lesssim1.48\times10^{69}$; choosing $10^{-30}$ gives $1.48\times10^{75}$.

The important loophole is substantive, not a technical nuisance. A deterministic history generated from a short program and small initial state can often be regenerated instead of archived; its retrieving cost moves into computation time. A being can also keep compressed summaries or let memories go. The present argument concerns recoverable independent detail, not value, consciousness, or the maximum possible duration of existence.

## Audit of the companion fixed-memory frontier

The model agent's proposed $B_{\rm req}\ge h_0D+aD^2/t+\Gamma t$ is algebraically correct when $D$ serial primitive durations sum to $t$, their dynamic costs are $h_0+a/\tau_j$, and the complete live memory has constant maintenance rate $\Gamma$. Cauchy gives equality at equal durations within the primitive model's permitted range. For $h_0=0$, no binding minimum tick, and a deadline by which the result may already have been consumed or handed off, maximizing over $t\le T$ gives the proposed $D_{\max}=\sqrt{(BT-\Gamma T^2)/a}$ until $T=B/(2\Gamma)$, then $B/(2\sqrt{a\Gamma})$. If the output must remain reliable until $T$, its maintenance after early completion must also be charged. The growing-archive result above is distinct because the live-memory requirement itself increases during the task.

## Reproduction and attribution

`frontier_calculations.py` reproduces the tables, checks the direct and expanded checkpoint formulas numerically, and writes `frontier_calculations.json`. The checkpoint construction and erasure–space exchange build on the cited reversible-simulation literature. The particular memory-maintenance optimization and the archive storage-time consequence are calculations developed for this report under their explicitly stated premises. They should not be presented as established cosmic limits or as empirical fits.
