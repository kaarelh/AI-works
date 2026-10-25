# Gradient descent as greedy growth of a shared circuit

Notes by Claude, prompted by Kaarel Hänni. Research note, 23 October 2026; not reviewed by a human.

**Status labels**, as in [`neural-network-generalization/`](../neural-network-generalization/TECHNICAL-FAQ.md):
- **Literature:** checked against abstracts and search summaries, and against memory of the papers. Full texts were not reread for this note.
- **Numerical:** the small experiments below.
- **Heuristic:** the model itself is a proposal, not a theorem.

**Question.** Is there a low-level, "more discrete" model of gradient-descent learning, comparable to the correspondence *NNBayes ≈ Occam circuit learning* in [`neural-network-generalization/`](../neural-network-generalization/)?

[Part 2](#part-2-an-empirical-study-a-matched-discrete-model-and-generalization-bounds) adds an empirical study of rich-regime networks on 21 Boolean functions, a discrete "race" model that matches their sample complexity within a factor of about 1.3 on held-out functions, and generalization bounds, including certificates that bound trained networks' test error without labelled hold-out data.

[Part 3](#part-3-state-of-understanding-after-an-extended-session) gives the current state of understanding:
- the race model transfers to 20 fresh targets (within about 1.15× on average) and to new input dimensions;
- what makes it work is the sampling noise of its feature search, not its clocks;
- a closed-form law, $n^*\approx\max(n_{\rm Hebb},\,c\max_i N(k_i)/\rho_i^2)$ with $N(k)=d\max(1,d/a)^{\max(k-2,0)}$ along the target's greedy path, predicts the networks' sample complexity, including how it scales with $d$ ($\approx d^{k-1}$ for $k$-parities, not Occam's $k\log d$; checked in a pre-registered test at $d=120$);
- new theorems make "short training ⇒ small circuit ⇒ generalization" rigorous for two-layer quadratic networks, and for two-layer ReLU networks through the first escape.

## Short answer

Mostly yes, and most of it is in the literature under the names *saddle-to-saddle dynamics* and *incremental learning*. In the rich regime (small initialization), gradient flow is well approximated by a discrete greedy algorithm:

1. **Grow.** Among all ways of adding one unit to the active network (a neuron, or a rank-one component), find the one with the largest *utility*. The utility is the first-order rate at which the unit would reduce the loss. Grow that unit.
2. **Refit.** Re-optimize all active weights jointly. The network lands near a new saddle of the full network, which is a local minimum of a smaller network.
3. Repeat until the training loss is near zero.

| setting | discrete algorithm | status |
|---|---|---|
| diagonal linear networks | LARS-like active-set recursion, ending at the minimum-ℓ1 interpolant | proved (Pesme–Flammarion 2023) |
| matrix factorization | greedy low-rank learning | evidence plus partial proofs, under assumptions (Li–Luo–Lyu 2021) |
| deep linear networks | rank increases by one at each saddle | conjectured; dynamics between the first two saddles proved (Jacot et al. 2021) |
| tensor and hierarchical tensor factorization (≈ certain CNNs) | incremental growth of tensor / hierarchical tensor rank | analysed (Razin–Maman–Cohen 2021, 2022) |
| general two-layer networks | **Alternating Gradient Flows**: dormant neurons maximize a utility, active neurons minimize the cost | framework with matching experiments; exact for diagonal linear networks; complete characterization for quadratic networks on modular addition (Kunin et al. 2025) |
| deep ReLU networks | the first escape is approximately rank one in deep layers; GD then visits saddles of increasing bottleneck rank | first escape proved; the sequence is conjectured (Bantzis–Simon–Jacot 2026) |

The last row is the fourth idea in the question: kernels in each layer start with only a few nonzero eigenvalues and grow over training. At every saddle, each layer's kernel has only a few large eigenvalues, and each escape adds about one.

Below are:
1. a discrete model combining these results, stated so that it answers the questions in the prompt;
2. small experiments measuring its rate law, including the cost of the "cross-circuit" move;
3. its relation to NNBayes ≈ Occam circuit learning;
4. where the picture is weakest.

## 1. The model (heuristic)

### State

The state is a layered circuit.
- Layer l has r_l active variables, each `h^l_i(x) = σ(Σ_j W^l_ij h^{l-1}_j(x))`. Here h^0 is the input plus a constant.
- The output is `f(x) = Σ_i a_i h^{L-1}_i(x)`.
- Equivalently, r_l is the number of non-negligible eigenvalues of the layer kernel `K^l(x,x') = Σ_i h^l_i(x) h^l_i(x')`.
- Variables are defined only up to the layer's symmetries: permutation and positive rescaling for ReLU, and rotation in the near-linear part of the representation.
- All other weights are *dormant*, at the initialization scale α.

### Moves

A move inserts new variables. It is classified by the number k of **fresh weight layers in series** that it needs.

- **Attach (k = 2).** Add a new variable at layer l that reads active variables (or inputs) at layer l−1 and writes into active variables (or the output) at layer l+1. This is the move the prompt worried about: a new layer-(l+1) variable built from a layer-l variable of "circuit 1" and one of "circuit 2". In this model it is a local move, because all of a layer's variables live in one space.
- **Fresh chain (k ≥ 3).** Add k−1 new variables in consecutive layers. This is needed when no active variables can carry the new feature. The very first move out of the origin is a fresh chain through the whole network, with k = L.
- **Refit.** Continuously re-optimize the active weights. This is fast (O(1) time), and convex in the readout.
- **Collapse** (needs SGD noise or weight decay; absent in gradient flow). Merge duplicate variables and delete useless ones. SGD noise makes such simpler invariant subnetworks attractive (Chen–Kunin–Yamamura–Ganguli 2023). Collapse is plausibly the dynamical counterpart of the neuron-merging restriction in the NNBayes depth results.

### Rate law

For a candidate move m with unit-norm new weights θ, the **utility** U_m(θ) is the first-order loss decrease per unit growth of the new path. For an attach at layer l, the new variable has incoming weights w from layer l−1 and outgoing weights v into the layer-(l+1) pre-activations:

```
U(w, v) = -E_x[ <δ^{l+1}(x), v> · σ(w · h^{l-1}(x)) ]
```

where `δ^{l+1} = ∂Loss/∂z^{l+1}` is the residual backpropagated to that location. Two processes then run in parallel:

- **Search.** The direction θ performs gradient ascent on U_m from its random initial value, and so finds a *local* maximum U*_m. Random initialization plays the role of the pool of mutations; the local ascent is the hill-climbing.
- **Growth.** The norm ρ of the new path follows k-homogeneous dynamics, `dρ/dt ≈ U ρ^{k-1}` with `ρ(0) ~ α^k`. The move *fires* when ρ reaches O(1), at time
  - `T_m ≈ log(1/α) / U*_m` for k = 2 (exponential growth, as in AGF). Below, deep ReLU attach moves measure as polylog(1/α);
  - `T_m ≈ α^{-(k-2)} / ((k-2) U*_m)` for k ≥ 3 (finite-time blow-up). This is the same law as the singular-value dynamics `dσ/dt ∝ σ^{2-2/N}` of depth-N matrix factorization (Arora–Cohen–Hu–Luo 2019).

### Selection

All candidates race. The first to fire wins, after which the network refits.
- To leading order, the winner minimizes `(k-2)·log(1/α) − log U*_m`.
- Each fresh weight layer in series costs about log(1/α) in log-time. Reusing existing variables is nearly free.

This settles the free parameter in the mutation picture, namely how the mutation rate should scale with mutation size. A move's rate is about `U × α^{k-2}`, where k counts the new weight layers in series.

### Population-genetics reading

For k = 2, `T = (1/s) log(1/p₀)` with `s = 2U` and `p₀ = α²`. This is the sweep time of a beneficial mutant lineage with selection coefficient s that starts at frequency p₀.

Small-initialization GD is therefore a deterministic strong-selection–weak-mutation process: one "mutation" sweeps at a time. The difference from sampled mutations is that every candidate is present from the start at abundance about α, so a race decided by utility replaces sampled mutation events. Two known equivalences bracket this:
- Random small Gaussian mutations of all weights, accepted by a Metropolis-like rule, are equivalent on average to noisy GD (Whitelam–Selin–Park–Tamblyn 2021).
- Valiant's *evolvability*, i.e. mutation and selection on representations, is equivalent to correlational-SQ learning (Feldman 2008). CSQ is also the usual power model for large-batch GD on square loss (Abbe–Kamath–Malach–Sandon–Srebro 2021).

### The four starting ideas in this language

1. **A single circuit, mutated, keeping improvements.** This is strong-selection–weak-mutation evolution, i.e. Valiant evolvability (= CSQ). With continuous weights and small mutations it is GD itself. What was missing is *which* discrete moves are cheap; the rate law above supplies that.
2. **An ensemble of summed circuits, each mutated.** This is the two-layer mean-field picture, with one neuron per particle (Mei–Montanari–Nguyen 2018; Chizat–Bach 2018); noisy SGD adds diffusion, i.e. mutation. With small initialization it becomes AGF.
   - With frozen circuits and a trained readout, it is the lazy (NTK) regime: a large bucket of random circuits whose readout weights are learned.
   - It is also the setting of Vaintrob's "bucket of circuits" cartoons, where the logits of parallel circuits add.
3. **Missing interactions between circuits.** Correct, and the effect is large: an attach move has k = 2, whereas a fresh circuit has k = L. See the experiments.
4. **Kernels per layer that start small, grow, and prefer small.** This is the deep saddle-to-saddle conjecture (Bantzis–Simon–Jacot; Jacot's bottleneck rank).
   - At standard initialization, the continuum description is the layer-kernel DMFT of Bordelon–Pehlevan 2022.
   - The Bayesian or equilibrium counterparts are deep kernel machines (Yang et al. 2023) and adaptive kernel predictors (Lauditi–Bordelon–Pehlevan 2025).
   - Silent alignment (Atanasov–Bordelon–Pehlevan 2022) and condensation (Zhou, Xu et al. 2022) both say that kernel directions reorganize to low rank while the output is still small. The rank trace below shows this.

## 2. Experiments (numerical)

### Setup

- **Data:** d = 8, all 256 points of the Boolean cube; full-batch GD on square loss.
- **Target:** `f = x1 + B·x2·x3`, with B = 0.8 unless stated.
- **Network:** ReLU, width 32, depth L (L weight layers). Biases enter only through a constant input, so the network is L-homogeneous.
- **Initialization:** each layer is α times a fan-in-normalized Gaussian.
- **Optimizer:** step 0.05, with the step norm capped at 0.05, approximating gradient flow.
- **Measurements:** T1 and T2 are the first times at which the output's Fourier coefficients on {1} and on {2,3} reach half their targets. ΔT = T2 − T1.

Two architectures of equal depth and homogeneity are compared:
- **mlp:** an ordinary fully connected net, in which the new x2x3 units can attach to the active x1 path.
- **paths:** an ensemble of 32 independent path-circuits, `out = Σ_k a_k relu(b_k ⋯ relu(w_k · x̃))`, with no cross-talk. Every new feature needs a fresh chain.

### Depth 3

Medians over 5 seeds. The fresh-chain prediction is α^{-1}.

| α | mlp T1 | mlp ΔT | paths T1 | paths ΔT |
|---|---|---|---|---|
| 0.3 | 7.4 | 5.1 | 7.5 | 17.4 |
| 0.1 | 24.5 | 6.3 | 23.8 | 30.1 |
| 0.03 | 83.5 | 10.6 | 76.7 | 87.7 |
| 0.01 | 250.6 | 18.9 | 224.3 | 257.0 |
| 0.003 | 831.4 | 34.2 | 736.3 | 854.7 |
| 0.001 | 2487.1 | 45.1 | 2195.6 | 2566.8 |

Log–log slopes against 1/α:
- T1: 1.02 (mlp) and 0.99 (paths).
- paths ΔT: 1.00. Equivalently, α·ΔT is flat at 2.57.
- mlp ΔT: 0.38 over the smaller-α half. This matches ΔT ≈ (log 1/α)²: `ΔT / log²(1/α)` stays between 0.86 and 1.19 for α ≤ 0.1.

### Depth 4

Medians over 3 seeds. The fresh-chain prediction is α^{-2}.

| α | mlp T1 | mlp ΔT | paths T1 | paths ΔT |
|---|---|---|---|---|
| 0.5 | 8.4 | 4.1 | 18.0 | 43.6 |
| 0.3 | 20.6 | 7.3 | 47.4 | 42.3 |
| 0.2 | 43.6 | 11.5 | 103.1 | 270.4 |
| 0.1 | 165.2 | 21.2 | 397.9 | 1066.9 |
| 0.05 | 651.0 | 32.4 | 1568.7 | 4263.2 |
| 0.03 | 1796.3 | 46.7 | 4339.8 | 11890.6 |

Log–log slopes against 1/α:
- T1: 1.92 (mlp) and 1.95 (paths).
- paths ΔT: 2.00. Equivalently, α²·ΔT is flat at 10.7 for α ≤ 0.2.
- mlp ΔT: 0.65 over the smaller-α half. `ΔT / log²(1/α)` stays between 3.6 and 4.5 for α ≤ 0.2.

Individual depth-4 escape times vary by up to a factor of about 7 across seeds, because finite-time blow-up is sensitive to the initial overlap. The medians are stable. Per-seed values are in `deep_L4.json`.

### Rate ∝ utility

Depth 3, α = 0.01; medians over 3 seeds ([`utility_sweep.txt`](experiments/utility_sweep.txt)). The utility of the x2x3 move is proportional to B.

| B | mlp ΔT | B·ΔT | paths ΔT | B·ΔT |
|---|---|---|---|---|
| 0.1 | 107.5 | 10.7 | 3634.6 | 363.5 |
| 0.2 | 67.5 | 13.5 | 1772.1 | 354.4 |
| 0.4 | 31.1 | 12.4 | 836.9 | 334.8 |
| 0.8 | 18.9 | 15.1 | 257.0 | 205.6 |

At B = 0.8 the paths ensemble's fresh chain had already partly grown during the first plateau.

### Kernel ranks

Depth 3, α = 0.003, one seed ([`rank_trace.txt`](experiments/rank_trace.txt)). Rank is the participation ratio of each hidden layer's centred kernel.

- **mlp, first plateau:** both layers' kernels condense from rank about 9 and 7 down to rank 1 *before* the loss moves.
- **mlp, after each drop:** rank 1 after the first drop; rank about 2 in layer 1 (2.02) and 1.4 in layer 2 after the second.
- **paths:** the same condensation occurs, but the second feature arrives at t ≈ 3465 instead of t ≈ 617.

### Reading

- **First feature:** in both architectures the first escape is a fresh chain through all layers and costs α^{-(L-2)}.
- **Second feature, paths:** with no cross-talk, the second feature costs the same again.
- **Second feature, mlp:** in the shared network the second feature attaches to the existing path and costs only polylog(1/α), at both depths. The predicted log(1/α) is for a single exponential phase. The extra logarithm is probably the direction-alignment phase of the new unit: x2x3 is a leap-two feature for a fresh first-layer unit. That explanation is unverified.
- **Utility:** delays scale like 1/utility.

These are small toy runs at one width and one target. They check the rate law's exponents, not its constants or its applicability to practical training.

## 3. Relation to NNBayes ≈ Occam circuit learning (heuristic)

- **Shared preference, different causes.** Both prefer small circuits. The posterior does so because of prior mass. GD does so because growth is sequential and stops at interpolation, and because each fresh layer in series costs a factor of 1/α in time.
- **GD is greedy and local.** It reaches only circuits that are connected to the current one by a chain of moves with non-negligible utility.
  - This suggests a **circuit leap complexity**. Order a circuit's gates so that each insertion is a positive-utility move, and count the largest number of gates that must be inserted at once. This generalizes the leap complexity of Abbe–Boix-Adserà–Misiakiewicz from Fourier support sets to circuits with shared variables.
  - k-sparse parity has circuit leap k: every proper sub-circuit has zero correlation with the residual, so its search costs about d^{k-1}, consistent with SQ lower bounds.
  - The conjecture is that GD from small initialization learns, in polynomial time, roughly the targets with a small circuit of O(1) circuit leap.
- **A test case.** The subcube-parity target in [`subcube-parity.md`](../neural-network-generalization/works-in-progress/beyond-parity/subcube-parity.md) fits: the staircase half supplies prefix parities that the parity half can reuse. This matches Adam succeeding on the two-head network, where the γ<1 posteriors provably fail. The plain-MLP failure from d = 23 on is a useful stress test: does routing through a learned selector have enough utility?
- **Small initialization ↔ strong prior.** The limit α → 0 is the dynamical analogue of the strong-prior limit.
  - A concrete question: when the circuit leap is O(1), does the α → 0 race select, up to polynomial factors, the circuit size that the γ ≥ 1 posterior concentrates on?
  - Chen–Lau–Mendel–Wei–Murfet (2023) give toy-model evidence that the critical points SGD visits match the Bayesian phase transitions as the sample size grows.
- **Two remaining differences.**
  - Greedy growth can overshoot the minimal circuit (as orthogonal matching pursuit can overshoot ℓ0), and GD has nothing analogous to integrating over the posterior.
  - The rate law weighs the number of fresh weight *layers*, whereas the Gaussian energy weighs squared norms.

## 4. Where the picture is weakest

- **Initialization scale.** Practical initializations are not tiny.
  - At standard parameterization and large width, training is largely lazy: a fixed random-circuit ensemble plus a learned readout.
  - μP or mean-field at standard initialization is rich, but not cleanly stepwise.
  - The discrete model is the α → 0 limit. Real runs are that limit on top of a random-feature background.
- **Nonconvex search.** For ReLU, the direction search is nonconvex, so which local maximum is found, and therefore which move wins, depends on the initialization. Modelling that distribution is the stochastic part of the model.
- **Superposition.** r_l counts dimensions, not features. LLM-like regimes need a sparse-feature version with many near-orthogonal variables per dimension.
- **Optimizer and loss.**
  - Adam behaves like sign descent, which measures utility in a different norm.
  - Cross-entropy adds a long margin-growth phase after interpolation.
  - Weight decay adds slow delete-and-merge moves; grokking-like replacement of a memorizing circuit by a generalizing one is outside the race model.
- **Proof status.** For deep nonlinear networks I found no proof beyond the first escape. The deep part of the model is conjectural.

## Part 2: an empirical study, a matched discrete model, and generalization bounds

Added later on 23 October 2026, in a second session of about three hours, in response to three requests:
1. study rich-regime networks empirically on Boolean functions;
2. find a discrete learning model that matches them behaviourally;
3. find generalization bounds of the form "training has not taken long, so the circuit is still small, so a Chernoff bound over small circuits applies".

Code and generated tables are in [`study/`](study/) (file guide: [`study/README.md`](study/README.md)); proofs are in [`theory/`](theory/). Everything below is **Numerical** at one input dimension (30), one width (128) and one learning rate per optimizer, unless labelled otherwise.

### 2.1 What the networks do

**Setup.**
- **Targets:** 21 targets on $\{-1,1\}^{30}$ ([`study/boolfuncs.py`](study/boolfuncs.py)): dictator, AND, majorities, a random halfspace, parities of 2–4 bits, a staircase, compositions of parities and majorities, a multiplexer, a DNF, a decision list, and four random 6-gate formulas.
- **Network:** a muP two-hidden-layer ReLU MLP of width 128 (small readout, per-layer learning-rate multipliers), square loss.
- **Optimizer:** Adam with learning rate $10^{-3}$, minibatches of 64 sampled with replacement from a fixed training set of size $n\in\{16,\dots,16384\}$, for 20000 steps, 3 seeds. On the 9 held-out targets, μP-SGD (learning rate 0.2, 2 seeds) was also run on the same training sets.
- **Online protocol:** six of the targets were also trained with a fresh minibatch at every step.

The weights move far from initialization: $\lVert\Delta W_1\rVert/\lVert W_1(0)\rVert\approx0.7$–$1.05$. The layer kernels collapse from participation-ratio rank about 36 and 32 at initialization to 3–10.

The sample complexity $n^*$ below is the training-set size at which test error reaches 0.1. The full tables are in [`study/NN-STUDY-TABLES.md`](study/NN-STUDY-TABLES.md); this is a selection.

| target | relevant vars | leap | $n^*$ network | $n^*$ NNGP kernel | $n^*$ Occam over juntas |
|---|---|---|---|---|---|
| $x_1$ | 1 | 1 | 47 | 29 | 16 |
| MAJ$_3$ | 3 | 1 | 112 | 73 | 18 |
| MAJ$_9$ | 9 | 1 | 263 | 1470 | never |
| random halfspace on 10 bits | 10 | 1 | 563 | 1701 | never |
| $x_1x_2$, $x_1x_2x_3$, $x_1x_2x_3x_4$ | 2, 3, 4 | 2, 3, 4 | 200, 843, 2728 | 406, never, never | 16, 23, 37 |
| staircase sign$(x_1+x_1x_2+\dots)$, 5 terms | 5 | 1 | 1514 | never | never |
| MAJ$(x_1x_2,x_3x_4,x_5x_6)$ | 6 | 2 | 1380 | 1129 | never |
| multiplexer $x_4\,?\,x_1x_2x_3:\mathrm{MAJ}_3$ | 4 | 1 | 1156 | never | 37 |
| 3-term DNF | 9 | 1 | 505 | 564 | never |
| sign$(2x_1+x_2x_3+x_4x_5x_6)$ | 6 | 3 | 2205 | never | never |

"Never" means not within the range tested ($n\le4096$ for the kernel, $n\le16384$ otherwise). The Occam learner searches juntas of up to 4 variables, so it cannot represent targets with more relevant variables.

**Observations.**
- **Between a kernel and an Occam learner.**
  - Parities cost the network 3–4× more data per extra bit: 200, 843 and 2728 samples. The Occam learner needs only 16, 23 and 37, and the NNGP kernel fails from 3 bits on.
  - Conversely, dense leap-1 targets such as MAJ$_9$ and the 10-bit halfspace are cheap for the network, 3–6× cheaper than for the kernel, and out of reach of the junta learner.
- **Reuse of a finite training set saves a lot of data.** With fresh samples, the network needs 12,800 samples for $x_1x_2$ and 32,000 for $x_1x_2x_3$, the staircase, the multiplexer and MAJ$(x_1x_2,\dots)$. That is 12–64× its fixed-set $n^*$ (MAJ$_9$: 3,200 against 263).
- **Delayed generalization near $n^*$.**
  - At $n=256$, $x_1x_2$ fits its training set by step 200 but only generalizes at steps 7000–10000.
  - The multiplexer, the DNF, recursive majority and AND$(x_1x_2,x_3x_4)$ show 4–40× delays at their critical $n$.
- **Features are learned in staircase order.** On the staircase target, the network's Fourier coefficient reaches half its target value at step 100 for $x_1$, step 500 for $x_1x_2$ and $x_1x_2x_3$, and step 1000 for $x_1x_2x_3x_4$. On sign$(2x_1+x_2x_3+x_4x_5x_6)$ it is step 100 for $x_1$, then 500, 1000 and 2000 for the higher terms.

### 2.2 A discrete model that matches them

Three designs were planned:
- **race:** an event-driven utility race, i.e. Part 1's model made into an algorithm;
- **sswm:** strong-selection/weak-mutation evolution of one shared fan-in-2 circuit, i.e. the original "mutate and keep improvements" idea;
- **stagewise:** a leap-limited stagewise learner.

Each would be implemented against a common API and scored against the networks. Each model's at most 4 global hyperparameters were calibrated on 12 *calibration* functions only and validated on 9 *held-out* functions. The stagewise design and the planned judge/refinement rounds were not run, for time.

**The race model** ([`study/models/race.py`](study/models/race.py)) is the clear winner.
- **State.** A shared two-level circuit of discrete ReLU gates $g=\mathrm{relu}(\sum_jw_ju_j-b)$. The weights are integers in $\{-3..3\}$, and the wires $u_j$ are the input literals and the earlier first-level gates. The gates feed a ridge least-squares readout, refitted after every gate.
- **Proto-units.** A persistent pool of dormant "proto-units" of orders 1–4 stands in for the not-yet-used hidden units.
- **Alignment.** Each proto-unit's direction aligns to the residual by (tensor) power iteration, at the speed given by the homogeneous law $\dot m=kU_km^{k-1}$. A unit of order $k$ starting from overlap $m\sim D^{-1/2}$ therefore needs time about $D^{(k-2)/2}/U_k$: the "fresh chain" cost of Part 1.
- **Firing.** Its clock then grows at the rate of the rounded gate's utility, and the unit fires when the clock reaches $\theta=\log(1/\alpha)=1.5$.
- **Race and stopping.** The earliest firing wins, after which the readout is refitted. The run stops at zero training error.
- **Clock.** The model's own time is the race clock.

On the **held-out** functions ([`study/MODEL-SCOREBOARD.md`](study/MODEL-SCOREBOARD.md); figures [`model_learning_curves.png`](study/figures/model_learning_curves.png), [`model_nstar_scatter.png`](study/figures/model_nstar_scatter.png)):

| model | mean $\lvert\log_2 n^*_{\rm model}/n^*_{\rm NN}\rvert$ | Spearman of $n^*$ | success agreement | learning-curve MAE | per-example agreement | Spearman of time to generalize |
|---|---|---|---|---|---|---|
| **race** | **0.33** | **1.00** | **0.95** | **0.01** | 0.50 | **0.83** |
| sswm | 1.36 | 0.60 | 0.86 | 0.06 | 0.26 | 0.72 |
| NNGP kernel | 2.58 | 0.73 | 0.85 | 0.04 | **0.69** | 0.22 |
| Occam over juntas | 4.61 | 0.50 | 0.62 | 0.13 | 0.20 | −0.07 |
| *reference: networks trained with μP-SGD instead of Adam* | *0.43* | *0.95* | *0.94* | *0.01* | *0.71* | *0.83* |

The learning curves match in shape, not just at the 0.1 crossing. The race model reproduces the network's intermediate plateaus: test error stays near 0.13 on sign$(2x_1+x_2x_3+x_4x_5x_6)$ from $n\approx256$ to $n\approx2000$. That plateau matches the predictor sign$(2x_1+x_2x_3)$, whose error is exactly $1/8$: the stage at which $x_1$ and $x_2x_3$ have been found but the leap-3 term $x_4x_5x_6$ has not. On recursive majority the error stays near 0.2 from $n\approx100$ to $n\approx1000$. The model also reproduces the sharp parity transitions at the right $n$. Neither model receives the target's identity or any network result: both import only numpy.

How to read the columns:
- **Sample complexity:** the race model's $n^*$ is within a factor of about 1.26 of the network's on average over the held-out functions, and ranks them identically. The scores on the calibration functions are similar (0.24, 0.96, 0.98).
- **Success agreement:** whether test error is at most 0.1 at each $(f,n)$.
- **Per-example agreement:** on cells where the network is partially right, the excess agreement of the predictions over independent errors, on the same training set, as a fraction of the maximum.
- **Time:** the race clock orders the cells by time to generalize much as network training steps do.

**Caveats.**
- The NNGP kernel agrees more with the network's *individual* mistakes at small $n$ (0.69 vs 0.50), although its learning curves are much worse. Where both are partially right, their errors resemble each other's.
- **Reference.** Networks trained with μP-SGD (2 seeds) on the same training sets serve as a ceiling for how alike two gradient-descent learners are. Against the Adam networks they score 0.43 on the $n^*$ ratio, so the race model is closer to the Adam networks' sample complexities than the SGD networks are. Their per-example agreement is 0.71: on individual mistakes, the race model reaches about 70% of the ceiling, and the NNGP kernel nearly all of it.
- The race model is only one model, calibrated against one architecture and one optimizer. Whether the same three constants transfer to other widths, depths, optimizers or input dimensions is untested.
- It is more mechanistic than "greedy Occam":
  - its continuous direction search and rounding make it less discrete than the circuit picture of Part 1;
  - its library (integer-weight discrete ReLUs over all wires) is large, $\approx D\log 7$ nats per gate.

### 2.3 Generalization bounds

Three derivations ([`theory/A-discrete-model.md`](theory/A-discrete-model.md), [`theory/B-nn-time-bounds.md`](theory/B-nn-time-bounds.md), [`theory/C-bridge-and-certificates.md`](theory/C-bridge-and-certificates.md)). Adversarial referees read A and B. They checked every proof step of B, and A's core results, and found them correct. They flagged mislabelled or overstated claims, listed in [`theory/README.md`](theory/README.md); A has been revised accordingly, and B has not. C's referee pass was stopped part-way; the numerical checks it had completed found no problems. *(Superseded: in Part 3, A, B and C were all revised and passed a second referee pass; see 3.4.)*

**Your sketch works, with one correction.**
- **The Chernoff/Occam step needs no assumption on the dynamics.** For any learner whose output after $T$ gates is a circuit from a fixed library followed by a threshold readout, the realizable test error is at most about $\bigl(T(\log|G|+k\log(d+T))+T^2\log2+\log\frac{(T+1)(T+2)}\delta\bigr)/n$ simultaneously for all $T$ (Theorem A1, Proved).
- **The correction:** training time does *not* bound the raw gate count. Many correlated gates can fire at once; on MAJ$_m$, $m^2$ gates fire at the same instant (Proposition A2.2(1–2)).
- **What time does bound,** in the race model, with time measured as $\tau(t)/\log(1/\alpha)$ where $\tau=\int\sqrt{2\hat L}\,dt$:
  - the circuit's **depth** (Proposition A2.1);
  - its **incoherence-weighted size**, $T\le\kappa\,(\tau/\Theta)^2$ with $\kappa$ the top eigenvalue of the fired gates' Gram matrix (Theorem A2.3);
  - the readout's **$\ell_1$ norm** at depth one (Theorem A2.4).

  Each gives a bound on test error as a function of training time (Corollary A2.5). The race reaches the noise floor only at $t\gtrsim\Theta\sqrt{n/\log M}$ (Proposition A2.6), which is the correlational-SQ sample size. That is a precise version of "it hasn't had time to memorize yet".
- **Rigorous for a real gradient-flow model:** for a diagonal linear network over a Boolean feature dictionary, small-initialization gradient flow provably keeps the number of large coordinates at most $\kappa\,\tau^2/\Theta_\varepsilon^2$. This gives a generalization bound uniform in $t$ with only $\ln(\text{dictionary size})$ dependence (C2).
- **For ReLU networks** this is only conditional (C3). The networks inherit the race model's time-indexed bound under an explicit "saddle-to-saddle approximation" hypothesis, which can be checked with unlabelled inputs.
- **SGD / online.**
  - With fresh minibatches, generalization is not the issue: the greedy race makes the same decisions as the population race once the batch exceeds about $\log(M T/\delta)/\gamma^2$ (A3).
  - The progressive (online) error bounds the test error of a random iterate (B3.4, C4). One correct move costs $O(\ln|\mathcal M|/\gamma^2)$ fresh samples (C4.3).

**What works numerically on the real networks.**
- **Parameter-space bounds are vacuous** at every $n\le16384$, even at initialization (B):
  - Frobenius and path norms;
  - the spectral bound;
  - stability (Hardt–Recht–Singer) and mutual information, which also fail their assumptions here.

  A PAC-Bayes bound with prior centred at initialization reaches 0.26–0.56 at $n=16384$ for the simplest targets, and is non-vacuous only in the first ~$10^2$ steps when its time-based form is used.
- **Distillation certificates are non-vacuous and often tight** (C1, Proved; numbers in C §1.4).
  - **Method:** find a small circuit $g$ (a junta truth table, or a sign of a few Fourier characters with small integer weights) that agrees with the trained network on *unlabelled* inputs. Then bound the network's test error by an Occam/Chernoff bound for $g$ on the training set, plus the measured disagreement. No labelled hold-out data is used.
  - **At $n=2048$:** every network is certified below 0.5; 9 of 13 targets below 0.04 (MAJ$_9$ at 0.034 via a sign of 9 characters).
  - **At $n=16384$:** every network is certified at most 0.021.
  - **Failures and validity:** certificates fail exactly where the networks fail, and none of the 117 falls below the true error.
- **Over training time** ([`study/CERTIFICATES.md`](study/CERTIFICATES.md), [`cert_over_time.png`](study/figures/cert_over_time.png)), certificates from [`study/certify.py`](study/certify.py) track delayed generalization.
  - On $x_1x_2x_3$ at $n=1024$, the network fits its training set by step 1000 with test error 0.165; the certificate is 0.23. By step 20000 the test error is 0 and the certificate 0.073.
  - While a network memorizes, the best certifying class temporarily grows, for example to signs of 8–10 characters, and then collapses to the 3-bit parity.
  - My search is weaker than C's: it misses MAJ$(x_1x_2,\dots)$ after step 500 and certifies only 0.60 there.

**Bottom line for "short training ⇒ generalization".**
- **For the discrete model it is a theorem,** with "size" read as depth, incoherent size or readout norm.
- **For real networks** the a-priori version is open beyond diagonal linear networks.
- **The a-posteriori version** (the trained network is close to a small circuit, so Occam applies) is rigorous and gives the only non-vacuous bounds here, often within a few percent of the truth.
- **Missing link:** a theorem that gradient descent keeps the network close to a circuit whose size is controlled by $\tau/\log(1/\alpha)$. That is exactly the "saddle-to-saddle approximation" hypothesis of C3.

### 2.4 Open items from this session

- **Not done, for time:**
  - SGD runs on the calibration functions (they were run on the 9 held-out functions only);
  - online runs for 15 of the 21 targets;
  - the third model design;
  - the judge/refinement stage;
  - the referee pass on C, and repairs to B: Theorem B3.3's "linear in training time" holds only for gradient flow and GD under a descent condition.
- **A's referee corrections were incorporated** in revision 2 of [`theory/A-discrete-model.md`](theory/A-discrete-model.md), which later passed a second referee pass (Part 3). The main changes:
  - Proposition A3.4(2), the multi-epoch reuse claim, was split into a proved conditional statement and a new proved Theorem A3.5 (large batches with reuse reproduce the population run); the small-batch reading is Heuristic.
  - Proposition A2.2(3) was restricted to duplicates with equal availability.
  - The $\alpha$-invariance claim was restricted to the pure $k=2$ race.
  - A genuinely time-only gate-count bound, A2.5(a′), was added; it is weak.
  - The referee found no false core theorem: A1, A2.1, A2.3 and A2.4 stand.
- **Natural next steps:**
  - test whether the race model's three constants transfer to other widths, depths and optimizers;
  - a circuit search (not only juntas and Fourier signs) for the certificates;
  - an attempt at the saddle-to-saddle approximation hypothesis for two-layer ReLU networks from small initialization, using Alternating Gradient Flows.

Several of these items were taken up in Part 3.

## Part 3: state of understanding after an extended session

This part was added on the night of 23–24 October 2026, after about five more hours. It covers:
- new experiments: input dimensions 15 and 60; 20 fresh random targets; widths 32, 64 and 256 (512 was started and abandoned as too slow); SGD at three input dimensions on one target; online runs with prequential logging;
- an investigation of *why* the race model works: ablations, a minimal model, an analytic predictor, and a kernel hybrid;
- a second round of theory: repairs, second referee passes, and a new set of early-phase theorems (D).

A fact-check of every number in this part against its sources, followed by a second check of each flagged item, led to corrections throughout. Where a claim was weakened, the weaker form is the one given here.

Status labels as before.

### 3.1 Summary

1. **Gradient descent's sample complexity follows a "noisy feature search" law, not an Occam law** (Numerical; all exponents below are for Adam, and SGD was checked on one target, see 3.2).
   - **Parities.** For parities of 2, 3 and 4 bits, the networks' $n^*$ grows like $d^{1.04}$, $d^{1.91}$ and $d^{2.40}$ over $d=15,30,60$. That is close to the correlational-SQ rate $d^{k-1}$ for $k\le3$, and somewhat below it for $k=4$. This holds even though training reuses a fixed training set for many epochs.
   - **Other targets.** Leap-1 compositions (staircase, multiplexer) scale like $d^{1.5}$, and dense majority like $d^{1.2}$.
   - **Comparison with Occam.** An Occam learner needs only $\approx k\log d$ samples for a $k$-parity ($\le16$, 23 and 37 samples at $d=30$, against the networks' 200, 843 and 2728; the 2-parity value is censored at the smallest $n$ tested).
2. **A closed-form predictor gets $n^*$ from the target alone** (Heuristic derivation, Numerical test).
   - **Formula.** Along the target's population greedy path,
   $$n^*\approx\max\Bigl(n_{\rm Hebb},\ c\max_{i\le i^*}\frac{N(k_i)}{\rho_i^2}\Bigr),\qquad N(k)=d\,\max(1,d/a)^{\max(k-2,0)}\ \ (k\ge1),\qquad N(0)=|\text{pool}|.$$
     - $\rho_i$ is move $i$'s correlation with the residual.
     - $k_i$ is the number of inputs the move needs that the circuit does not yet use. A move with $k_i=0$ only reuses grown features, and its cost is the size of the small active pool.
     - $i^*$ is the shortest prefix of the path that reaches error 0.1.
     - $n_{\rm Hebb}$ is the sampling-noise floor of the linear part.
     - There are two constants, $c=2.25$ and $a=18$, calibrated on 12 functions.
     - For 19 of the 21 designed targets the closed form reproduces the $n^*$ of the predicted learning curve (it misses the decision list and rand1).
   - **Results.**
     - On 20 fresh random formulas never seen during calibration: mean $|\log_2|$ ratio 0.42 (within about 1.34×) and Spearman 0.92, over $n^*$ from 61 to 3049. A second saved run of the predictor, which scans $n$ more finely, gives Spearman 0.96 ([`study/MINIMAL-MODEL.md`](study/MINIMAL-MODEL.md)).
     - On the 9 held-out functions: 0.38. The constants are clean there, but the model's structure is not: variants that scored better on the calibration set were rejected on principle. The random formulas are the cleaner test.
     - It gets the 2- and 3-parity $d$-exponents right. In a pre-registered test at $d=120$ (3.6) it predicted 817 and 12525 against the networks' 869 and 10691, where the race model was 3× too early on the 3-parity. The $d=15$ agreement, however, depends on the cap $\max(1,d/a)$, which was probably added after the $d=15$ network results had been seen. That part is not a clean out-of-sample test.
3. **The race model transfers out of sample** (Numerical).
   - **Fresh targets.** On the 20 fresh random formulas it matches the networks' $n^*$ within a factor of about 1.15 on average (mean $|\log_2|$ ratio 0.20, Spearman 0.99, success agreement 0.98), better than on the original held-out set.
   - **New input dimensions.** Calibrated at $d=30$ only, it predicts $n^*$ at $d=15$ and $d=60$ with mean $|\log_2|$ ratio 0.45 and 0.43. Its largest miss is 3-bit parity, where its $d$-exponent is half the networks' with the calibrated random stream (0.94 against 1.91). Averaged over several random streams, the race's parity exponents from $d=15$ to 30 are about 1.3 (3-parity) and 1.8 (4-parity), against the networks' 1.8 and 2.4. That gap is about the size of one stream's spread, so "grows too slowly" is a direction, not a precise number. At $d=120$ (3.6) the direction becomes decisive: the race is 3× too early on the 3-parity. It also under-predicts the $d$-growth of MAJ of pair parities (1.12 against 1.75) and of the staircase (1.14 against 1.50).
4. **What makes the race model work is noise in the feature search, not its clocks** (Numerical, ablations).
   - **Little effect on the match.** The following change it by at most about 0.1 beyond the full model's own spread across internal random streams (held-out 0.23–0.33 over six streams); held-out values are 0.25–0.42. On the calibration targets, pool size 1, one power-iteration step and plain greedy sit 0.1–0.2 above that band, mostly because of the 4-parity:
     - the race's timing machinery: clocks, persistence of partial growth, the alignment-time cost;
     - depth-2 gates, which help only staircase-like targets, by about 0.4 in $\log_2$;
     - replacing the race by plain greedy selection (0.27).

     One exception: removing the alignment cost only for orders $\ge3$ gives 0.50.
   - **Breaks the match:**
     - computing the direction search on fresh samples instead of the training set (4.6, a diagnostic that removes sampling noise from the search);
     - removing order-3/4 units (1.4).
   - **Noise level versus noise realization.** Running the search on an independent sample of the *same* size keeps the $n^*$ match (0.31) but halves per-example agreement (0.50 → 0.26, held-out). The *level* of search noise sets sample complexity; the *particular* noise of the training sample sets which examples are wrong. Heuristically, about half of the race model's excess agreement with the networks' mistakes comes from both being misled by the same spurious correlations of the shared training sample.
   - The correct discrete picture is therefore *greedy growth whose acceptance is limited by the sampling noise of a continuous search over directions*.
   - **How that noise depends on $d$.**
     - *What the ablations measure* (Numerical): the search-noise floor directly, as the largest spurious order-$k$ utility found on random labels. Its crossing point grows polynomially in $d$, with an exponent that rises with each input that must be found at once (1.2, 1.6 and 2.0 for $k=2,3,4$ from $d=15$ to 30). That is slower than the networks' $n^*$ (1.1, 2.0, 2.4), and the race model's parity $n^*$ grows too slowly with $d$ for the same reason.
     - *The functional form* (Heuristic): the fitted law of item 2, supported by the networks' parity exponents for $k\le3$.
5. **A trained network looks like a kernel background plus grown features** (Heuristic reading of a Numerical result).
   - **The result.** Adding the NNGP kernel's score to the race model's score with equal weight raises held-out per-example agreement on partially learned tasks from 0.50 to 0.62. The $n^*$ match is unchanged within noise: 0.29 held-out and 0.32 calibration, against the race's 0.33 and 0.24.
   - **References.** Two single Adam networks trained on the same data from *different* initializations agree at 0.62. The average of three such networks reaches 0.68, extrapolating to about 0.71–0.73 (3.6). SGD and Adam networks that share the initialization agree at 0.71. The NNGP kernel alone reaches 0.69.
   - **Reading.** The networks' individual mistakes are kernel-like, while *whether* they generalize is set by feature growth.
6. **Once they generalize, both the networks and the model are functionally small circuits, even when their representation is large** (Numerical).
   - Half of the race model's generalizing fits carry more than 6 gates. Their own Occam bound is then usually vacuous: median 0.67, with 34% below 0.5.
   - Yet most are certified as close to small juntas or Fourier-sign circuits. On a sample of 30, the distillation certificate has median 0.125 and is below 0.2 in 24 cases. In the same sample the own-circuit Occam median is 0.82.
   - **The networks show the same** ([`study/CERTIFICATES.md`](study/CERTIFICATES.md), regenerated in this session because the earlier copy was empty).
     - Over all 21 targets, 5 sizes and 3 seeds, 221 of 315 networks get a non-vacuous certificate and 163 one below 0.2. No certificate falls below the network's actual test error.
     - At $n=16384$ every network is certified at 0.08 or less, except on three targets: MAJ of pair parities (0.54), sparsepoly (0.29) and rand1 (0.42). There the networks generalize, but the certificate's circuit classes do not capture them cheaply.
7. **Bounds** (Proved unless stated). The three derivations A, B and C each passed a second adversarial referee pass, with 7, 8 and 10 minor issues and none major ([`theory/checks/referee_A_r2.json`](theory/checks/referee_A_r2.json), [`_B_r2`](theory/checks/referee_B_r2.json), [`_C_r2`](theory/checks/referee_C_r2.json)). The new derivation D adds:
   - for two-layer ReLU networks trained by gradient flow from balanced small initialization (not the study's μP Adam networks):
     - an exact "mass clock" race identity;
     - a proof that nothing grows before $\approx\log(1/\alpha)/U^*$;
     - a width-free generalization bound through the first escape, which is vacuous below $n\approx10^5$ at $d=16$;
   - for two-layer *quadratic* networks with fixed output signs (equivalently, symmetric matrix sensing), a proof of your sketch at every training time, in weight-free form. The number of grown hidden units is at most $\kappa(\tau/\Theta)^2$, where $\kappa$ is independent of labels, trajectory and width, and $\tau=\int\|r\|$ is read off the training-loss curve. This gives a test-error bound uniform in time. The same statement in raw training time alone is much weaker.

   D passed two adversarial referee passes with minor issues only. In the second, every Proved result was re-derived, including whether the bounds use classes fixed before the sample and whether $\kappa$ is really label-, trajectory- and width-free. The general ReLU case beyond the first escape remains a stated conjecture.
8. **Robustness and SGD.**
   - **Width.** Between widths 32 and 256, the 3-parity's $n^*$ does not change (827–911), while the 4-parity's falls 1.9× and is still falling at 256. Narrowing from 128 to 32 units changes $n^*$ by +2% for the staircase and +23% for the multiplexer. The parity pattern does not fit the noise law with one width-dependent overlap constant; see 3.2. Dense MAJ$_9$ needs 59% more data at width 32 (the reason is untested). The width-128 values are 3-seed means; on the same two seeds as width 32 the changes are a little smaller (multiplexer +13%). Width 512 was started and abandoned as too slow on this CPU.
   - **One-pass training** (Adam on fresh minibatches). The prequential mistake rate certifies the average test error of a window of iterates with no capacity argument ([`study/ONLINE-BOUNDS.md`](study/ONLINE-BOUNDS.md)). The bound tracks the whole learning curve. On MAJ$_9$, over successive windows, it is 0.53, 0.37, 0.20, 0.074, 0.032 and 0.013. After learning it is about 0.002–0.01 (zero mistakes plus the confidence term).

### 3.2 Thread 1: what the networks do

**Sample complexity versus input dimension** ([`study/DSCALE.md`](study/DSCALE.md), [`figures/dscale.png`](study/figures/dscale.png); 2 seeds at $d=15,60$):

| target | $n^*$ at $d$ = 15 / 30 / 60 | exponent | leap rate $d^{k-1}$ (matches CSQ lower bounds on the cube) | Gaussian CSQ rate $d^{k/2}$ (reference by analogy) |
|---|---|---|---|---|
| $x_1x_2$ | 100 / 200 / 427 | 1.04 | 1 | 1 |
| $x_1x_2x_3$ | 241 / 843 / 3410 | 1.91 | 2 | 1.5 |
| $x_1x_2x_3x_4$ | 508 / 2728 / 14255 | 2.40 | 3 | 2 |
| staircase (5 terms) | 433 / 1514 / 3487 | 1.50 | – | – |
| multiplexer | 364 / 1156 / 2848 | 1.48 | – | – |
| MAJ$(x_1x_2,x_3x_4,x_5x_6)$ | 306 / 1380 / 3466 | 1.75 | – | – |
| MAJ$_9$ | 123 / 263 / 625 | 1.17 | – | – |

For the 4-parity, the fixed budget of 20000 steps limits $n^*$ at both $d=15$ and $d=60$: the critical cells are still improving at the last step. So the sign of its effect on the $k=4$ exponent is unknown.

The last two columns are reference rates from the literature, not fits:
- **Leap rate.** $d^{k-1}$ is the online-SGD rate for a leap-$k$ target on the hypercube, which matches CSQ lower bounds there (Abbe–Boix-Adserà–Misiakiewicz). In Gaussian single-index models, plain online SGD has the analogous rate (Ben Arous–Gheissari–Jagannath).
- **Gaussian CSQ rate.** $d^{k/2}$ is the CSQ lower bound for Gaussian single-index models with information exponent $k$, attained by smoothed online SGD (Damian et al. 2023). SQ algorithms and batch reuse go further there by using nonlinear functions of the label (Damian et al. 2024; Dandi et al. 2024).
- **Why the second column is only a reference.** For $\pm1$ labels every SQ is a CSQ plus a label-free query (Bshouty–Feldman 2002), so that further speed-up has no direct analogue on these Boolean targets.

**SGD instead of Adam** (μP-SGD, learning rate 0.2, 2 seeds; $d=15$ and 60 from [`study/run_checks2.sh`](study/run_checks2.sh), $d=30$ from the main sweep). On the 3-parity, SGD needs 382, 1220 and 3562 samples at $d=15,30,60$, against Adam's 241, 843 and 3410.
- **Exponent.** SGD's is 1.61 against Adam's 1.91, between the Gaussian-CSQ reference $d^{1.5}$ and the leap rate $d^{2}$.
- **Uncertainty.** At $d=60$ both $n^*$ are interpolated inside the same factor-2 step of the $n$ grid, between 2048 and 4096. The two seeds agree to within ±0.01, but the grid forces that agreement: both seeds' errors switch from 0.33–0.48 to about 0 between the same two grid points. So it says nothing about seed noise. The interpolation uncertainty is at worst about ±0.25 per exponent.
- **Conclusion.** The data suggest that SGD's exponent is about 0.3 lower: its $n^*$ falls from 1.6× Adam's at $d=15$ to about 1× at $d=60$. That difference is within the interpolation uncertainty, so it is not resolved.

Other observations:
- **Out-of-sample targets.** The 20 fresh random formulas, with 3–5 relevant inputs and 3–8 gates, have network $n^*$ from 61 to 3049 ([`study/RANDOM-SUITE.md`](study/RANDOM-SUITE.md)).
- **The networks' complexity peaks just below $n^*$.**
  - **Where it holds.** For the 3- and 4-bit parities, the staircase and the multiplexer, the networks' layer-2 kernel rank (participation ratio) peaks just below $n^*$ and collapses above it. For MAJ of parities the peak, at $n=2048$, lies above $n^*=1380$.
  - **The race model behaves differently.** Its circuit size sits at its 48-gate cap from well below $n^*$ to beyond it. It collapses to a few gates only for the 3-parity, and for the multiplexer only by $n=16384$. The networks shed their memorizing features once they generalize; the race model mostly keeps them. That is why its own Occam bound is vacuous while its certificate is not (3.1, item 6).
  - **Over all cells,** network rank and model size correlate weakly (Spearman 0.14). At small $n$ the networks move little from initialization (relative $\|\Delta W_1\|$ of 0.17–0.24 at $n\le64$), so their rank reflects random features. Excluding $n<128$ raises the Spearman to 0.59.
- **Time to fit.**
  - *Networks, sparse high-order targets:* it rises up to about $n^*$ and then levels off.
  - *Networks, dense targets:* it keeps rising past $n^*$ (10-bit halfspace: 500 steps at $n=1024$, 7000 at $n=16384$).
  - *Race model:* it peaks near $n^*$ and then mostly declines.

**Width** ([`study/run_width.sh`](study/run_width.sh), [`study/run_checks2.sh`](study/run_checks2.sh), [`study/run_width2.sh`](study/run_width2.sh); 2 seeds except width 128, which has 3). At width 32 against 128, $n^*$ is 419 against 263 for MAJ$_9$, 1417 against 1156 for the multiplexer and 1540 against 1514 for the staircase. For the parities, across four widths:

| width | 3-parity $n^*$ | its test error at $n=512$ | 4-parity $n^*$ | its test error at $n=2048$ |
|---|---|---|---|---|
| 32 | 911 | 0.46, 0.47 | 3554 | 0.49, 0.48 |
| 64 | 827 | 0.37, 0.28 | 3304 | 0.31, 0.33 |
| 128 | 843 | 0.40, 0.38, 0.29 | 2728 | 0.02, 0.36, 0.14 |
| 256 | 873 | 0.43, 0.44 | 1899 | 0.04, 0.07 |

- **3-parity: no width dependence the grid can see.** At every width the test error is 0.28–0.47 at $n=512$ and exactly 0 at $n=1024$. The interpolated $n^*$ values, 827–911, show no trend.
- **4-parity: width helps, monotonically.** The test error at $n=2048$ falls from 0.49 to 0.05 between widths 32 and 256, and $n^*$ falls 1.9×. It has not levelled off at 256, although μP should have a width limit.
- **This contradicts the simplest reading of the noise law** (Numerical). Suppose the constant $a\approx18$ were a single width-dependent "best initial overlap among the hidden units". Then, since $n^*\propto(d/a)^{k-2}$, the 4-parity's width effect would be the square of the 3-parity's. It is not: under 10% for the 3-parity against 1.9× for the 4-parity.
- **A best-of-units account does not fit either** (Heuristic, with a Monte Carlo check). Suppose instead the binding quantity is the luckiest unit's initial order-$k$ coefficient, the largest product of $k$ Gaussian weights over $P$ units.
  - **What it predicts.** That maximum grows from width 32 to 256 by 1.9× for $k=3$ and 2.2× for $k=4$ (Monte Carlo, 4000 draws). So it predicts a width effect for the 3-parity as well, which is absent.
  - **A guess.** The 3-parity may already be at its width limit by width 32: its escape is carried by the bulk of the units, as in mean-field theory. The 4-parity, whose bulk signal is weaker, may still lean on lucky units.
- **What it means for the models.** The race model and the predictor are models of width-128 networks. How order-$\ge4$ costs depend on width is open.

### 3.3 Thread 2: the discrete model

**The model, as now understood.** The race model of Part 2 matches the networks. Its ablations and the minimal model show which of its parts matter.
1. **Candidate features.** These are gates on the inputs. Gates on already-grown features (depth-2 composition) also exist, but they help only staircase-like targets, by about 0.4 in $\log_2$. A move is classified by the number $k$ of inputs it needs that the circuit does not yet use.
2. **Search noise.** A candidate is found from the training set by a *continuous* search over directions. So its acceptance threshold is the noise level of that search, not the best-of-$M$ level of an Occam union bound.
   - **What the ablations show** (Numerical): search noise sets $n^*$.
   - **The functional form is a fitted heuristic**, the minimal model's and predictor's rule (Heuristic): a move needing $k\ge1$ new inputs is accepted when
     $$n\rho^2\gtrsim c\,d\,\max(1,d/a)^{\max(k-2,0)}.$$
     That is $c\,d$ for $k=1,2$, and $c\,d\,(d/a)^{k-2}$ for $k\ge3$ when $d\ge a$. This is the correlational-SQ / leap-complexity scaling, with the constant $a$ entering as a squared initial overlap $m(0)^2=a/d$.
   - **What $a$ means is unclear.** Reading it as "the best overlap among many hidden units" was a guess, and the width data in 3.2 do not support it.
   - **Reuse.** Reusing grown features costs a search over the small active pool, $N(0)=|\text{pool}|$, so it is nearly free.
   - **The race model does not follow this form exactly.** Its 3-parity $d$-exponent is 0.94 on the calibrated stream and about 1.3 averaged over streams.
3. **Readout.** A least-squares readout, with a dense linear (Hebbian) part that carries its own sampling noise.
4. **Selection is greedy.** The race's greedy variant picks the largest utility; the minimal model picks the largest utility relative to its noise level, $n\rho^2/N(k)$.
   - **Time ordering does not come from the race.** The ordering of time to generalize is reproduced about equally well with or without the race (held-out time Spearman: greedy 0.86, race 0.83, noise-free search 0.78). It is set by the targets' feature utilities, not by the race's clocks.
   - The race beats the minimal model's derived clock clearly only on the held-out set (0.83 against 0.69; calibration set 0.89 against 0.86).
   - **What the time Spearman measures.** It ranks *targets* only. Within a target it is about 0 (−0.07 held-out), and a per-target constant, the race's gate count at fit, already scores 0.75. Network step counts also sit on a 1-2-5 checkpoint grid.

**Ablation details** ([`study/ABLATIONS.md`](study/ABLATIONS.md)).
- **Search noise.**
  - *Noise-free search.* With a noise-free direction search, $n^*$ collapses to 16–87 on every target, as far from the networks as the Occam learner.
  - *Fresh sample of the same size.* Drawing a fresh search sample of the same size before every firing lowers $n^*$ by only about 1.5×. What matters is the noise *level* at sample size $n$, not reuse of the training labels.
- **Dense leap-1 targets.** A one-shot Hebbian classifier sign$(\mathbb E_S[yx]\cdot x)$ gives $n^*$ of 53, 116 and 346 for $x_1$, MAJ$_3$ and MAJ$_9$, against the networks' 47, 112 and 263. That is close for the first two and 1.3× high for MAJ$_9$. It is 1.75× too optimistic for the 10-bit halfspace (322 against 563).
- **Time to generalize.** Its *ordering* across cells survives every ablation, including the noise-free search, so it is set by the true features' utilities. Its *magnitudes* are matched only loosely; for example, high-order parities are too slow in the race model at large $n$.

**What this says about the original "mutation size" question** (Heuristic). The cost of a mutation is set by how many new inputs it must coordinate at once, and reusing an existing variable is nearly free.
- **The fitted law.** In the fitted law, each new input beyond the first two multiplies the required sample size by about $d/a$. The networks' 4-parity exponent (2.40 rather than 3) shows this overstates the cost of the fourth input.
- **Analogy with Part 1.** Sample size takes the place of time, $\rho^2$ the place of the utility $U$, and the noise threshold $c\,d\,(d/a)^{k-2}$ the place of $\alpha^{-(k-2)}$ (or $\log(1/\alpha)$ for $k=2$). The two $k$'s count different things, though: new inputs here, fresh weight layers in Part 1. So this is an analogy, not the same law.

**Scoreboard** ([`study/MODEL-SCOREBOARD.md`](study/MODEL-SCOREBOARD.md), [`study/MINIMAL-MODEL.md`](study/MINIMAL-MODEL.md), [`study/HYBRID-QUICK.md`](study/HYBRID-QUICK.md); mean $|\log_2|$ ratio of $n^*$ against the networks):

| model | 9 held-out functions | 20 fresh random formulas | $d=15$ / $d=60$ (7 targets) | per-example agreement (held-out) |
|---|---|---|---|---|
| race model | 0.33 | **0.20** | 0.45 / 0.43 | 0.50 |
| race + kernel background ($\gamma=1$) | 0.29 | – | – | 0.62 |
| minimal model (2 constants) | 0.59 | 0.47 | 0.30 / 0.52 | 0.50 |
| analytic predictor (no simulation) | 0.38 | 0.42 | 0.30 / 0.52 | – |
| sswm (mutate and select) | 1.36 | 1.12 | – | 0.26 |
| NNGP kernel | 2.58 | 1.78 | – | **0.69** |
| Occam over juntas | 4.61 | 3.76 | – | 0.20 |
| *reference: Adam networks retrained from a new initialization* | – | – | – | *0.62* |
| *reference: SGD networks vs Adam networks (same initialization)* | *0.43* | – | – | *0.71* |

Notes on the table:
- **The hybrid's numbers.** Its 0.29 is within the race model's own seed spread (0.27–0.33), and its calibration-set score is worse (0.32 against 0.24). Its $\gamma$ was chosen from a sweep reported on both splits, so its held-out column is not strictly held out.
- **The minimal model's held-out deficit** is partly one-seed luck on two targets: sparsepoly's $n^*$ is set by one seed accepting a 3-leap gate early, and rand3's miss is structural and shared with the predictor.

**Known gaps.**
- **$d$-exponents.**
  - *Race model:* it gets 0.94 for the 3-bit parity, against the networks' 1.91, on its calibrated random stream. Averaged over streams it gets about 1.3 from $d=15$ to 30, against 1.8. It also underestimates MAJ of pair parities (1.12 against 1.75) and the staircase (1.14 against 1.50).
  - *Predictor:* it gets the 3-parity right. It overpredicts the 4-parity at $d=60$ by 1.6× (the minimal model by 2.0×), with exponents 2.75 and 3.00 against the networks' 2.40.
- **Compositions of low-leap moves:** the predictor underpredicts them by 1.4–1.7× already at $d=30$, and by 1.7–2.1× at $d=60$.
- **Very small initialization (from D).** In D's two-layer ReLU runs at $\alpha\le10^{-3}$, every neuron was recruited by the first escape. On $x_1+\tfrac12x_2x_3$ at $\alpha=10^{-6}$, the second feature was not learned by $t=400$. The race model's persistent reservoir of dormant units assumes this does not happen. Whether it happens in the μP networks was not measured; their success on multi-stage targets suggests it does not.

### 3.4 Thread 3: bounds

**Review status** ([`theory/README.md`](theory/README.md)): A, B and C each failed or passed their first referee pass, were revised, and passed a second pass with only minor issues (7, 8 and 10). Those minor fixes were then applied and each checked by a separate agent. D passed its first pass with minor issues only, was revised, and passed a second pass with 7 minor issues, which were then applied (one small addition made in that last step, a minibatch form of D6(5) item 3, is unrefereed).

**What is now proved about "short training ⇒ small circuit ⇒ generalization":**
- **The discrete race model (A).** Time bounds the depth and the incoherence-weighted size at any depth, and the readout $\ell_1$ norm at depth one. With A1, these give test-error bounds uniform in time.
  - *Raw gate count.* Training time does not bound it uniformly over gate libraries (A2.2). For a fixed library only a weak time-only bound holds: A2.5(a′), with a factor $\bar\kappa\approx d$.
  - *Incoherence-weighted bound.* It uses the learned circuit's data-dependent $\kappa(t)$, and is never tighter than A1 applied to the realized size.
- **Diagonal linear networks (C2):** the number of grown coordinates is at most $\kappa(\tau/\Theta)^2$.
- **Two-layer quadratic networks with fixed output signs (D, new):** the same weight-free statement for the number of grown hidden units, with $\tau$ read off the training-loss curve.
  - *What the network is.* It has a shared hidden layer but fixed $\pm1$ output weights, so it is symmetric matrix sensing.
  - *The bound.* It gives a test-error bound uniform in time.
  - *Weak spots.* It weakens on plateaus with nonzero residual, and becomes vacuous on MAJ of pairs.
- **Two-layer ReLU networks trained by gradient flow from balanced small initialization (D, new):**
  - *Proved:*
    - the exact mass-clock identity;
    - no growth before $\approx\log(1/\alpha)/U^*$, with constant 1 sharp;
    - a width-free bound through the first escape (vacuous below $n\approx10^5$ at $d=16$);
    - a merging law. Same-sign neurons that share an activation pattern on the training set merge as their mass grows, through a conserved quantity: the off-diagonal part of the classical balancedness law (Arora–Cohen–Hazan 2018; Du–Hu–Lee 2018).
  - *Conditional:* persistence beyond the first escape, under a condition checkable from the training residuals.
  - *Conjecture:* the a-priori form beyond the first escape.
  - *Scope:* none of this covers the study's μP Adam networks directly.
- **One-pass training** (here Adam on fresh minibatches; Proved, B3.4 and C4.1). The prequential error certifies the *average test error of a window's iterates*, with no capacity argument. It says nothing directly about the final network.
  - *During learning.* On the online runs, which now log prequential mistakes, the certified bound is within about 0.01–0.18 of the test error at each window's end (seed 0, 4 targets). The window-average error, which is what the bound certifies, was not measured.
  - *After learning,* the bound is about 0.002 ([`study/ONLINE-BOUNDS.md`](study/ONLINE-BOUNDS.md)).
  - *Elsewhere.* The B repair independently found agreement within 0.006 on its own runs.
  - *What remains.* For one-pass training, then, the question becomes *how many samples until the feature is found*. Point 1 of 3.5 answers it, so far heuristically.

**What works numerically on the fixed-training-set networks:**
- **Distillation certificates.** These are the only *tight* bounds: the trained network is close to a small circuit. For the networks this was shown in Part 2; for the race model's own large circuits, see [`study/RACE-CERTIFY.md`](study/RACE-CERTIFY.md).
- **PAC-Bayes centred at initialization (B3.2)** is non-vacuous but weak: 0.26–0.56 at $n=16384$, on the simplest targets only.
- **The race model's own-circuit Occam bound** ([`study/RACE-BOUNDS.md`](study/RACE-BOUNDS.md)) has median 0.021 among generalizing fits with at most 6 gates, against 0.67 for those with more. Tightness also needs large $n$.

### 3.5 What I now believe, and what is open

**1. Gradient descent here is greedy circuit growth limited by search noise.**
- **Confidence.**
  - *The qualitative picture: fairly confident, for this setting.* $n^*$ is set by when a move's correlation with the residual beats the sampling noise of a continuous search, and that cost grows polynomially in $d$ with the number of new inputs the move needs at once.
  - *The specific functional form: Heuristic.* That form is $d\,\max(1,d/a)^{\max(k-2,0)}/n$, with reuse of grown features nearly free.
- **Evidence.** Two models match $n^*$ within about 1.15–1.45× on average: the race simulation, and the closed-form noise-law predictor. They do so across:
  - 21 designed targets, 12 of which were calibration data, and 20 random targets;
  - three input dimensions;
  - $n^*$ from 47 to about 14000.

  The ablations say that search noise, not the race's timing machinery, does the work.
- **Known misses.**
  - *Which model embodies the law.* Only the predictor embodies the functional form above. The race model's 3-parity $d$-exponent is half the networks'.
  - *The 4-parity.* The networks scale like $d^{2.40}$, below the law's $d^{3}$.
  - *Width.* The 4-parity's $n^*$ depends on width while the 3-parity's does not, which a single overlap constant $a$ cannot produce.
- **Caveats.** All of this is in one setting:
  - one architecture family: a μP two-hidden-layer ReLU MLP;
  - Adam (SGD gives similar $n^*$ on the held-out targets; its 3-parity $d$-exponent, 1.6 against 1.9, is not resolved from Adam's at this precision);
  - models and noise law tested at width 128 only, with width checks at 32–256 (parities only at 64 and 256);
  - $d\le60$, interactions of at most 4 bits, $n\le65536$;
  - uniform Boolean inputs and square loss.

**2. Relation to NNBayes ≈ Occam circuit learning.**
- **Same answer to *what* is learned.** Once gradient descent generalizes, the network is functionally close to a small circuit, as the certificates show. So the two pictures agree on what is learned when learning succeeds.
- **Different answer to *how many samples*.**
  - Occam (and, per the sibling project, the $\gamma\ge1$ posterior) pays the circuit's description length, about $k\log d$ for a $k$-parity.
  - Gradient descent pays the noise cost of the most expensive move along its greedy path, about $d^{k-1}$ for a leap-$k$ move (somewhat less at $k=4$).
- **Conjecture** (suggested by the predictor, not shown). The two sample complexities are close for targets with a cheap greedy path, i.e. low-leap compositions with large residual correlations at every step. They differ by about $d^{k-1}/(k\log d)$ when a leap of size $k$ is unavoidable. For fixed $k$ that gap is itself polynomial; it becomes super-polynomial only if $k$ grows with $d$.
- **A testable consequence.** The networks' $n^*$ should be predictable from the target's greedy path alone. On 20 random formulas the closed form does this to within about 1.34×, with Spearman 0.92–0.96 depending on the saved predictor run.
- **The cost grows with the leap.** On the 26 targets with at most 4 relevant inputs (designed and random), the ratio of the networks' $n^*$ to the Occam-over-juntas learner's grows with the target's leap, at $d=30$:

  | leap | targets | median ratio |
  |---|---|---|
  | 1 | 14 | 8.1× |
  | 2 | 8 | 16.6× |
  | 3 | 2 | 36× |
  | 4 | 2 | 85× |

  Within leap 1 the spread is wide (1.7×–31×; the multiplexer is 31×), because the correlations along the path matter too, as the predictor says.

**3. Kernel background and grown features.** *Moderately confident* (Heuristic reading). A trained network is a random-feature kernel background plus grown features:
- the features decide whether and when it generalizes;
- the background decides which examples it gets wrong on the way.

Adding the kernel score to the race model brings per-example agreement to 0.62, and the flow hybrid of 3.6 to 0.65. Two single Adam networks trained on the same data from different initializations agree at 0.62, while an initialization-averaged network would reach about 0.71–0.73 (3.6).

**4. Bounds: where "short training ⇒ small circuit ⇒ Occam" now stands.**
- **It is a theorem for:**
  - the discrete model, reading size as depth, incoherence-weighted size, or readout norm at depth one;
  - diagonal linear networks;
  - two-layer quadratic networks with fixed output signs (new), in weight-free form;
  - two-layer ReLU networks under gradient flow from balanced small initialization, through the first escape (new).
- **It is a conjecture for** ReLU networks beyond the first escape (Conjecture D4).
- **Numerically,** on the fixed-training-set networks, the only tight bounds are after the fact. The trained network is certified close to a small circuit using unlabelled inputs. PAC-Bayes at initialization is non-vacuous but weak.
- **For one-pass training,** prequential error certifies the average test error of a window of iterates, with no capacity argument.
- **Note on what the bounds answer.** The bounds bound the train–test gap. The question of *how many samples* is answered, so far heuristically, by the noise law of point 1.
  - *Lower half.* For one-pass (CSQ-type) training, the lower half of that law is the known CSQ rate. For training that reuses a fixed sample, no matching lower bound is known, and the 4-parity data scale below $d^{k-1}$.
  - *Upper half.* For real networks it is open.

**Open problems, roughly in order of promise:**
1. **Prove the noise law** for a two-layer network trained on a fixed sample from small initialization: an order-$k$ feature escapes the plateau iff $n\gtrsim d^{k-1}/\rho^2$ up to logarithms. Ingredients exist: information-exponent results for online SGD (Ben Arous–Gheissari–Jagannath), early alignment (Boursier–Flammarion), and D's mass clock and merging law.
2. **Composition costs.** The predictor underpredicts staircase, multiplexer and MAJ of parities by 1.4–1.7× at $d=30$ and 1.7–2.1× at $d=60$, and the race model misses the 3-parity exponent. Sequential moves may partly add rather than take a maximum. Width dependence is order-dependent: none for the 3-parity, 1.9× from width 32 to 256 for the 4-parity, which one overlap constant $a$ cannot produce.
3. **Reservoir depletion at tiny initialization** (D): the race model assumes a persistent reservoir of dormant units, and D shows it can be used up by the first escape. When does that happen at practical scales?
4. **Beyond this setting:** other architectures, cross-entropy, SGD noise (merging and collapse moves), real data. In particular: is the "noise of a continuous search" law the right replacement for Occam's description length in larger models?
5. **Bayes vs gradient descent:** characterize the targets on which the γ≥1 posterior and gradient descent have polynomially related sample complexity. The predictor suggests: exactly those with a cheap greedy path.

### 3.6 Late results: a kernel-background hybrid (verified) and a pre-registered test at $d=120$

These came from the last workflow of the session. They finished after the report to the user.
- **The hybrid** has had a verification pass, and its corrections are included below.
- **The $d=120$ test** has not had an independent verification pass. I recomputed the networks' $n^*$ from the saved runs and checked the timestamps.
- **Synthesis.** [`study/MODEL-UNDERSTANDING.md`](study/MODEL-UNDERSTANDING.md) collects everything; its sections 3, 6.3 and 7 are unverified.

**Kernel-background hybrid** ([`study/HYBRID.md`](study/HYBRID.md), with its Verification section).
- **The model.**
  - The race model unchanged, with an NNGP-kernel background fitted jointly with its gates in one ridge readout.
  - The background's ridge relaxes on the race's clock like kernel gradient flow, $\lambda_{\rm bg}(t)=c_{\rm bg}n/t$.
  - Growth stops at a square-loss level.
  - There are two new constants, chosen on the calibration set. The schedule form, the stop rule and the end-of-training step were also chosen there.
- **Per-example agreement.** On the held-out targets it rises from 0.50 to 0.65. Bootstrapped over targets, the gain is +0.15, with interval [0.13, 0.17]. It holds on every held-out target, every seed and two further random streams.
- **Price in $n^*$.** Averaged over streams, $n^*$ error is 0.35 against the race's 0.28 (held-out) and 0.37 against 0.26 (calibration). On the summary numbers it is no better than simply adding the two scores (3.1, item 5). Its case is mechanistic.
- **Ceiling, corrected.**
  - Two single networks trained on the same data from different initializations agree at 0.62.
  - The average of three such networks agrees with the original at 0.684, and extrapolates to about 0.71–0.73. So a learner that never sees the initialization can in principle reach the SGD reference's level.
  - The NNGP kernel agrees 0.78 with a three-network average, against 0.68 for a fourth single network. The kernel behaves like the network averaged over initializations.
- **Mechanism** (Numerical measurements, Heuristic reading).
  - *Sample noise.* On partially learned cells, about 45% of a network's output variance is fitted sample noise: 0.59 at $n\le64$ and 0.23 at $n=2048$.
  - *Signal and noise correlations.* Every learner matches the signal part (correlation 0.92–0.98). The noise part correlates 0.81 with the kernel's, 0.70 with a re-initialized network's and 0.48 with the race's.
  - *Swapping noise patterns.* Swapping only the noise patterns moves the race from 0.50 to 0.63 and the kernel from 0.69 to 0.53.
  - *Reading.* The networks memorise like a kernel and generalise like a feature learner.
  - *Order of events.* Over training, the networks interpolate first, within 100–1000 steps, with kernel-like mistakes. Near $n^*$ the generalizing features grow afterwards.
- **Few grown gates.** The hybrid needs about 2 gates per partially learned cell, where the race uses about 22. With the exact kernel at $n=4096$, it needs 3–18 rather than 48. The "circuit" a network grows is small, and the rest is kernel-like. This points to an a-priori bound of the form "Occam for a few grown gates plus a kernel-norm term for the background", which was not attempted.
- **Remaining discrepancy.** On easy targets the networks are 1.1–2.2× less sample-efficient than their own NNGP kernel. The race reproduces this, through its noisy Hebbian first gate; the hybrid does not.

**Pre-registered test at $d=120$** ([`study/MODEL-UNDERSTANDING.md`](study/MODEL-UNDERSTANDING.md) §6.3; predictions in [`study/understanding/predictions_d120.json`](study/understanding/predictions_d120.json)).
- **Protocol.** The predictions were saved at 02:42:06, before the $d=120$ networks were launched; their first results are timestamped 02:44:31. All models kept their $d=30$ calibration constants. The networks used the same protocol, with 2 seeds, and $n^*$ was read at 20000 steps.

| target | networks (factor-2 grid; refined) | analytic predictor | race (4 streams; geometric mean) | Occam law |
|---|---|---|---|---|
| $x_1x_2$ | 869 | **817** | 566 | 315 |
| $x_1x_2x_3$ | 14188; 10691 | **12525** | 3557 | 1015 |
| MAJ$_9$ | 845 | 1143 | 1307 | 1143 |
| multiplexer | 6524; 5195 | 3405 | 4013 | 891 |

- **The 3-parity is decisive.**
  - *Predictor:* the correlational-SQ / leap law predicted that $n^*$ would roughly quadruple from $d=60$ to 120, and it did (refined grid: 2740 → 10691).
  - *Race model:* its acceptance rule grows like about $d^{1.2}$ and is now 3× too early.
  - *Errors:* mean $|\log_2|$ error is 0.41 for the predictor, 0.99 for the race and 2.14 for the Occam law.
- **Updated exponents.** On the refined grid the networks' local exponents from $d=30$ to 120 are 1.09 and 1.03 for the 2-parity, and 1.93 and 1.96 for the 3-parity: $d^{\max(1,k-1)}$.
- **MAJ$_9$.** The whole learning curve is a function of $n/d$ at $d=15$, 30, 60 and 120, within 0.01–0.04 of the constant-free Hebbian-noise law. Its apparent $n^*$ exponent of 0.44 from 60 to 120 is an artifact of where the flat curve crosses 0.1.
- **Multiplexer.** The predictor's composition miss persists: 1.5× too early.
- **What this changes** (Heuristic reading). Point 1 of 3.5 is strengthened for $k\le3$: the networks follow the escape law $d^{k-1}$ out to $d=120$. The race model matches at $d=30$ partly because there its "detect" threshold and the "escape" threshold nearly coincide, and its $d$-scaling is wrong. The closed-form noise law, not the race simulation, is the better discrete description of sample complexity.

## Part 4: does compositional structure beyond leap matter? (24 October 2026)

**The objection.** Leap complexity, and my move classification (k = new inputs), look only at which inputs a term touches. They cannot see intermediate functions that are learned for their own sake and then combined. The proposed test: with $s=x_1+x_2+x_3+x_4$, is $A=s+x_1x_2+x_3x_4+x_1x_2x_3x_4$ easier than $B=s+x_1x_2x_3x_4$? Both have leap 1.

**Design.**
- **Order of work.** The predictions were committed before any network was run ([`study/composition/PREDICTIONS.md`](study/composition/PREDICTIONS.md)): leap's, my move classification's, and the race model's on the networks' exact training sets.
- **Task.** Real-valued regression, with every term at coefficient 1/2; signed labels would wash out the degree-4 term.
- **Measure.** $n^*_4$ is the training-set size at which the network's degree-4 coefficient reaches 80% of its target.
- **Controls.** Pairs that do not multiply to the term ($C$), pairs without the linear part ($E$), the bare parity ($F$), pairs on other inputs ($G$), and one pair ($H$).
- **Results** are in [`study/composition/RESULTS.md`](study/composition/RESULTS.md), with the figure [`study/figures/composition.png`](study/figures/composition.png).

| | target | leap | $n^*_4$, $d=30$ | $n^*_4$, $d=60$ |
|---|---|---|---|---|
| E | $x_1x_2+x_3x_4+x_1x_2x_3x_4$ | 2 | **1332** | – |
| C | $s+x_1x_2+x_2x_3+x_1x_2x_3x_4$ | 1 | 1586 | 3120 |
| A | $s+x_1x_2+x_3x_4+x_1x_2x_3x_4$ | 1 | 1652 | 3165 |
| H | $s+x_1x_2+x_1x_2x_3x_4$ | 1 | 1842 | – |
| B | $s+x_1x_2x_3x_4$ | 1 | 2030 | 5021 |
| G | $s+x_5x_6+x_7x_8+x_1x_2x_3x_4$ | 2 | 3488 | – |
| F | $x_1x_2x_3x_4$ | 4 | 3635 | 14330 |

**Findings** (Numerical):
- **The prediction holds, and the gap grows with $d$.**
  - *Samples:* $A$ needs 1.23× fewer than $B$ at $d=30$, and 1.59× fewer at $d=60$.
  - *Time:* at $n=2048$ the degree-4 term takes 2000 steps for $A$ and 20000 for $B$.
  - *One pass:* after 32000 fresh samples the coefficient is 0.17–0.25 for $A$ and 0.05–0.07 for $B$.
- **Any intermediate feature on the term's own inputs helps; features on other inputs do not.**
  - $C$, whose pairs do not multiply to the term, helps as much as $A$. But $x_1x_2x_3x_4=(x_1x_2)x_3x_4$ is still a product of a learned pair and two learned inputs.
  - $H$ (one pair) lies between $A$ and $B$.
  - $G$ (pairs on other inputs) is as hard as the bare parity.
  - $E$ (pairs, no linear part) is the easiest.
- **Leap gets the class partly right.**
  - From $d=30$ to 60, $A$ and $C$ grow like $d^{0.94}$ and $d^{0.98}$, as leap 1 says.
  - $F$ grows like $d^{1.98}$, not $d^3$.
  - $B$ grows like $d^{1.31}$, in between.
- **Neither of my predictors saw it coming.**
  - *The k-rule* calls the degree-4 term in $B$ a cheap reuse move.
  - *The race model* searches order-4 features over all $d$ inputs. It gave everything nearly the same $n^*_4$ at $d=30$, and at $d=60$ it is 5× too pessimistic for $B$.

**Reading** (Heuristic). The cost of a high-order term is set by how many *existing features* it must combine at once, not by how many new inputs it needs. This is the "circuit leap" suggested in Part 1 §3. The noise law should be refined accordingly; that is not yet done.

**Paper.** A write-up of Parts 1–4 as a paper is in [`paper/`](paper/), as LaTeX sources plus a PDF.

## Part 5: what the network computes while it learns (24–25 October 2026)

Full write-up: [`study/trajectories/TRAJECTORIES.md`](study/trajectories/TRAJECTORIES.md). Figures: [`study/figures/trajectories.png`](study/figures/trajectories.png) and [`study/figures/trajectories_heldout.png`](study/figures/trajectories_heldout.png).

**Question.** For several Boolean targets, characterize the function the network computes at each step of training and the sequence of functions it passes through. Then find a general model that reproduces this.

**Method.**
- *Targets.* Five chosen targets (sparsepoly, stair5, mux, majpar, rmaj9), plus six held-out ones.
- *Conditions.* One-pass training, and fixed $n=16384$, 2048 and 512.
- *What is recorded.* At 72 log-spaced steps, the network's $E[f\mid x_R]$ is recorded exactly on every pattern of the relevant variables. From it come the full Fourier spectrum and each target character's learned fraction.

**What the network computes** (Numerical):
- **A truncated Fourier expansion of the target.** On each plateau, $f\approx\sum_{S\in\mathcal S(t)}\hat y_S\chi_S$, with the correct coefficients on the terms it has and nothing on the rest. The distance is 0.00–0.03 Var $y$. The alternative, "the best function of the inputs discovered so far", is 0.13–0.41 away.
- **The sequence is reproducible.**
  - Online and $n=16384$ agree, and seeds agree to about 15%.
  - The linear stage comes first, at a nearly fixed 50–70 steps.
  - Characters then arrive in *bundles*: everything one new feature direction carries, small coefficients together with large.
  - The *order follows construction, not coefficient size.* For example, mux's largest term, $x_1x_2x_3x_4$, comes last, after the features it is built from.
- **Transient effects.** Coefficients overshoot transiently, by up to 1.36, as the readout refits on the features present.
- **Finite $n$.** At finite $n$ the same sequence stops partway: later stages saturate partially or never start, and memorisation goes into the irrelevant inputs.

**Models** (Heuristic). Three independent designs were calibrated on the five targets and frozen. Only then were networks run on the six held-out targets.
- **`fourier`, a by-hand rule.** It is a race of moves, each of which extends something already learned by $e$ new inputs at once.
  - *Duration:* $\propto e^2\cdot2^{[\text{built on a feature}]}\cdot2^{[\text{odd degree}\ge3]}/\rho^{1/2}$.
  - *Finite $n$:* memorisation cut-off, plus the spiked-estimation level $1-N/(n\rho^2)$.
- **`gates`.** Least-squares fit on greedily grown ReLU-gate bundles, with an alignment-law clock.
- **`flow`.** The network's own Adam dynamics, reduced to the relevant inputs, with the irrelevant inputs entering as noise.

**Results.**
- All three predict the held-out trajectories as well as the calibration ones.
- Like for like, against single network runs (traj, held-out): `flow` 0.0037 online, against 0.0054 for an independent rerun of the network. So it predicts a run better than a rerun does. `fourier` and `gates` score 0.0105, within 2× of rerun variability.
- Online onsets are within about 10% (`flow`) and 25% (`fourier`).
- An independent verifier per model reproduced every score bit for bit, and found no network data read by any predictor. It flagged undercounted degrees of freedom, and the fact that the held-out targets had been trained in the project's earlier study. Both are disclosed.

**The general picture** (Heuristic). The network computes a truncated Fourier expansion of the target, extended in bundles. Each bundle is added by a move that builds on a feature the network already has.
- *Cost:* a move costs more the more new inputs it must coordinate at once, and is cheap when it only composes existing features.
- *Within a stage:* the readout refits on the features present.
- *Finite $n$:* the race against memorisation decides where it stops.

This is the composition finding of Part 4, seen in time rather than in samples.

## Files

Part 2: [`study/`](study/) (NN study, discrete models, certificates; guide in [`study/README.md`](study/README.md)) and [`theory/`](theory/) (derivations A, B, C, with check scripts in `theory/checks/`).

Part 1: all scripts use only numpy and run in seconds to minutes on a CPU.

| file | contents |
|---|---|
| [`experiments/attach.py`](experiments/attach.py), [`experiments/sweep.py`](experiments/sweep.py) | depth-3 experiment and α sweep → `attach_results.json` |
| [`experiments/deep.py`](experiments/deep.py) | depth-L version; `python3 deep.py 4 0.5,0.3,0.2,0.1,0.05,0.03` → `deep_L4.json` |
| [`experiments/summarize.py`](experiments/summarize.py) | tables and slopes; output in `summary_L3.txt`, `summary_L4.txt` |
| [`experiments/utility_sweep.py`](experiments/utility_sweep.py) | B sweep → `utility_sweep.txt` |
| [`experiments/rank_trace.py`](experiments/rank_trace.py) | kernel-rank trace → `rank_trace.txt` |

## References

**Saddle-to-saddle dynamics and incremental learning**
- Kunin, Marchetti, Chen, Karkada, Simon, DeWeese, Ganguli, Miolane. *Alternating Gradient Flows: A Theory of Feature Learning in Two-layer Neural Networks.* NeurIPS 2025. [arXiv:2506.06489](https://arxiv.org/abs/2506.06489)
- Bantzis, Simon, Jacot. *Saddle-to-Saddle Dynamics in Deep ReLU Networks: Low-Rank Bias in the First Saddle Escape.* ICLR 2026. [arXiv:2505.21722](https://arxiv.org/abs/2505.21722)
- Jacot, Ged, Şimşek, Hongler, Gabriel. *Saddle-to-Saddle Dynamics in Deep Linear Networks and Small Initialization.* [arXiv:2106.15933](https://arxiv.org/abs/2106.15933)
- Pesme, Flammarion. *Saddle-to-Saddle Dynamics in Diagonal Linear Networks.* NeurIPS 2023. [arXiv:2304.00488](https://arxiv.org/abs/2304.00488)
- Li, Luo, Lyu. *Towards Resolving the Implicit Bias of Gradient Descent for Matrix Factorization: Greedy Low-Rank Learning.* ICLR 2021. [arXiv:2012.09839](https://arxiv.org/abs/2012.09839)
- Razin, Maman, Cohen. *Implicit Regularization in Tensor Factorization.* ICML 2021. [PMLR](https://proceedings.mlr.press/v139/razin21a.html)
- Razin, Maman, Cohen. *Implicit Regularization in Hierarchical Tensor Factorization and Deep Convolutional Neural Networks.* ICML 2022. [arXiv:2201.11729](https://arxiv.org/abs/2201.11729)
- Arora, Cohen, Hu, Luo. *Implicit Regularization in Deep Matrix Factorization.* NeurIPS 2019.
- Kumar, Haupt. *Learning Neural Networks by Neuron Pursuit.* 2025. [arXiv:2509.12154](https://arxiv.org/abs/2509.12154)
- Abbe, Boix-Adserà, Misiakiewicz. *SGD learning on neural networks: leap complexity and saddle-to-saddle dynamics.* COLT 2023. [arXiv:2302.11055](https://arxiv.org/abs/2302.11055)

**Kernels, condensation, and simplicity**
- Atanasov, Bordelon, Pehlevan. *Neural Networks as Kernel Learners: The Silent Alignment Effect.* ICLR 2022. [arXiv:2111.00034](https://arxiv.org/abs/2111.00034)
- Zhou, Zhou, Jin, Zhang, Xu, et al. *Towards Understanding the Condensation of Neural Networks at Initial Training.* NeurIPS 2022. [arXiv:2105.11686](https://arxiv.org/abs/2105.11686)
- Bordelon, Pehlevan. *Self-Consistent Dynamical Field Theory of Kernel Evolution in Wide Neural Networks.* NeurIPS 2022.
- Lauditi, Bordelon, Pehlevan. *Adaptive Kernel Predictors from Feature-Learning Infinite Limits of Neural Networks.* ICML 2025. [arXiv:2502.07998](https://arxiv.org/abs/2502.07998)
- Yang, Robeyns, Milsom, Anson, Schoots, Aitchison. *A Theory of Representation Learning Gives a Deep Generalisation of Kernel Methods.* ICML 2023.
- Chen, Kunin, Yamamura, Ganguli. *Stochastic Collapse: How Gradient Noise Attracts SGD Dynamics Towards Simpler Subnetworks.* NeurIPS 2023. [arXiv:2306.04251](https://arxiv.org/abs/2306.04251)
- Allen-Zhu, Li. *Backward Feature Correction: How Deep Learning Performs Deep (Hierarchical) Learning.* COLT 2023. [arXiv:2001.04413](https://arxiv.org/abs/2001.04413)

**Mean-field, evolution, and SQ**
- Mei, Montanari, Nguyen. *A Mean Field View of the Landscape of Two-Layer Neural Networks.* PNAS 2018.
- Chizat, Bach. *On the Global Convergence of Gradient Descent for Over-parameterized Models using Optimal Transport.* NeurIPS 2018.
- Whitelam, Selin, Park, Tamblyn. *Correspondence between Neuroevolution and Gradient Descent.* Nature Communications 12, 6317 (2021). [arXiv:2008.06643](https://arxiv.org/abs/2008.06643)
- Valiant. *Evolvability.* JACM 2009.
- Feldman. *Evolvability from Learning Algorithms.* STOC 2008. Evolvability = CSQ learning.
- Abbe, Kamath, Malach, Sandon, Srebro. *On the Power of Differentiable Learning versus PAC and SQ Learning.* NeurIPS 2021.
- Ben Arous, Gheissari, Jagannath. *Online Stochastic Gradient Descent on Non-Convex Losses from High-Dimensional Inference.* JMLR 22 (2021).
- Damian, Pillaud-Vivien, Lee, Bruna. *Computational-Statistical Gaps in Gaussian Single-Index Models.* COLT 2024.
- Dandi, Troiani, Arnaboldi, Pesce, Zdeborová, Krzakala. *The Benefits of Reusing Batches for Gradient Descent in Two-Layer Networks: Breaking the Curse of Information and Leap Exponents.* ICML 2024.
- Amid, Warmuth. *Reparameterizing Mirror Descent as Gradient Descent.* NeurIPS 2020. [arXiv:2002.10487](https://arxiv.org/abs/2002.10487) Small-initialization GD on squared parameters is multiplicative-weights / replicator-like.

**Singular learning theory and circuit cartoons**
- Chen, Lau, Mendel, Wei, Murfet. *Dynamical versus Bayesian Phase Transitions in a Toy Model of Superposition.* 2023. [arXiv:2310.06301](https://arxiv.org/abs/2310.06301)
- Vaintrob. [*Efficiency spectra and "bucket of circuits" cartoons*](https://www.lesswrong.com/posts/fhK3dKW9RQhr9Ymf7/efficiency-spectra-and-bucket-of-circuits-cartoons) and [*The memorization-generalization spectrum and learning coefficients*](https://www.lesswrong.com/posts/iwmvrrGGtprRZkgeY/the-memorization-generalization-spectrum-and-learning). LessWrong, January 2025.
- Vaintrob, Greenspan. [*Mean field sequence: an introduction*](https://www.lesswrong.com/posts/rduzFkTKx5pGKWKcL/mean-field-sequence-an-introduction). LessWrong.
