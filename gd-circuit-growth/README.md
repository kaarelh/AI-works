# Gradient descent as greedy growth of a shared circuit

Notes by Claude, prompted by Kaarel Hänni. Research note, 23 October 2026; not reviewed by a human.

**Status labels**, as in [`neural-network-generalization/`](../neural-network-generalization/TECHNICAL-FAQ.md):
- **Literature:** checked against abstracts and search summaries, and against memory of the papers. Full texts were not reread for this note.
- **Numerical:** the small experiments below.
- **Heuristic:** the model itself is a proposal, not a theorem.

**Question.** Is there a low-level, "more discrete" model of gradient-descent learning, comparable to the correspondence *NNBayes ≈ Occam circuit learning* in [`neural-network-generalization/`](../neural-network-generalization/)?

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

## Files

All scripts use only numpy and run in seconds to minutes on a CPU.

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
- Amid, Warmuth. *Reparameterizing Mirror Descent as Gradient Descent.* NeurIPS 2020. [arXiv:2002.10487](https://arxiv.org/abs/2002.10487) Small-initialization GD on squared parameters is multiplicative-weights / replicator-like.

**Singular learning theory and circuit cartoons**
- Chen, Lau, Mendel, Wei, Murfet. *Dynamical versus Bayesian Phase Transitions in a Toy Model of Superposition.* 2023. [arXiv:2310.06301](https://arxiv.org/abs/2310.06301)
- Vaintrob. [*Efficiency spectra and "bucket of circuits" cartoons*](https://www.lesswrong.com/posts/fhK3dKW9RQhr9Ymf7/efficiency-spectra-and-bucket-of-circuits-cartoons) and [*The memorization-generalization spectrum and learning coefficients*](https://www.lesswrong.com/posts/iwmvrrGGtprRZkgeY/the-memorization-generalization-spectrum-and-learning). LessWrong, January 2025.
- Vaintrob, Greenspan. [*Mean field sequence: an introduction*](https://www.lesswrong.com/posts/rduzFkTKx5pGKWKcL/mean-field-sequence-an-introduction). LessWrong.
