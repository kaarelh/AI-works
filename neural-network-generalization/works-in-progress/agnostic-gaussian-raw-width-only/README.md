# Learning narrow approximations with Gaussian Bayesian neural networks

[Paper (PDF)](paper.pdf) · [LaTeX source](source/paper.tex) · [Verification record](verification/README.md)

A finite neural network with independent Gaussian weights can predict nearly as well as narrower neural approximations. Both the likelihood and the **ordinary final posterior mean** use the raw real-valued output and all training observations. No output clipping, architecture mixture, or prior support restriction is used.

For the simplest result, start with the paper's arbitrary-input shallow ReLU oracle or its bounded-activation counterpart. They count teacher coefficient magnitudes, need only finite label variance for a confidence guarantee, and give direct width-`n^(1/4)` approximation guarantees. The coefficient-free results below allow arbitrary original weights under their separate input and depth assumptions. The one-dimensional ReLU theorems give sharper rates when the input density is bounded above and below.

For the general coefficient-free theorem, at fixed teacher and suitable fixed learner depths, explicit positive constants `u, η` give, with high probability,

```text
test risk ≤ inf { R(g) : g is a ReLU network of width at most n^u }
            + Õ(n^(-η)).
```

The event covers every prescribed learner width `N ≥ n` and every mean-field-or-stronger scale. The proof only needs the learner to exceed the smaller explicit compiler width. The learner's Gaussian likelihood variance is calibrated from Bayesian evidence and the sample; it does not use the unknown comparison coefficients or risk.

The theorem covers:

- **Boolean inputs with any input distribution.** At fixed depths, a finite sample bound is polynomial jointly in teacher width and input dimension.
- **Continuous inputs with a bounded density.** Two hidden tanh layers suffice for compilation, with worse width exponents depending on dimension and teacher depth.
- **Slab-regular input laws, including uniform spheres.** No ambient Lebesgue density is needed; the circle is covered with a weaker slab exponent.

A direct **shallow ReLU learner works under any input distribution on the cube**, with no teacher-output cap, at every `N ≥ C+1` for a width-`C` affine-output teacher (or `N ≥ C` without its output bias), and every mean-field-or-stronger Gaussian scale. If teacher width is `C` and every coefficient and bias is bounded by `B`, for bounded labels its exact-leading-one remainder is

```text
Õ((n^(-1/2) + d/n) [d(C+1)B² + d]).
```

The exact resource is the normalized path mass `P_g = sqrt(d) Σ |v_j| ||(a_j,b_j)||₂`. The finite-variance confidence version counts `E Y²` and the failure probability explicitly. Its universal eventual schedule `λ_n = log^8(n+2)/sqrt(n) + (d+2)log^8(n+2)/n` needs neither teacher resources nor a known label-moment bound; the starting sample size can depend on the label law and confidence. At fixed dimension and coefficient cap it competes with width `n^(1/4)` at remainder `Õ(n^(-1/4))`. More generally `C_n B_n² = o(sqrt(n)/log^9 n)` gives a vanishing bound at every learner width that can hold that teacher. These are confidence guarantees, not expected-risk claims for arbitrary finite-variance labels.

Under marginally sub-Gaussian labels, this all-width coefficient-controlled shallow ReLU oracle also holds **in expectation**, with the same polynomial powers and extra logarithmic factors under the stated deterministic likelihood calibration. The bounded-monotone oracle with `N λ ≥ c` has the same confidence-to-expectation consequence; this does not claim an all-width expectation theorem. These stronger label tails are used to control exceptional samples; the finite-second-moment statements remain confidence guarantees only.

A separate **shallow tanh, sigmoid, or hardtanh oracle works in every input dimension under any distribution on the cube**. For any width-`C` teacher with coefficients bounded by `B`, without an output cap, its raw risk is at most the teacher risk plus

```text
Õ(sqrt((d+1) A / n)),
A = O(C²B² + (d+1)²B² + (d+1) log(n(CB+1))).
```

The strongest coefficient-controlled confidence theorem holds at **every learner width `N ≥ C`**, with no condition on `N λ`. Its quadratic resource uses the average squared incoming-row norm and `C Σ c_i²`. A separate wide-learner version at `N λ ≥ c` uses squared readout variation and a variation-weighted incoming energy; that refined resource can be independent of the number of comparison neurons. A constant neuron used to implement an output bias is counted in `C`. There is no input regularity assumption. The separate `N λ ≥ c` version has a logarithmic-confidence extension for marginally sub-Gaussian labels; the all-width theorem uses the finite-variance confidence bound. A risk-weighted multiplier bound removes the teacher-output restriction without worsening the rate.

For this shallow arbitrary-input theorem, **only `E Y² < ∞` is needed**. With `E Y² ≤ M₂`, the high-probability remainder is `Õ(sqrt((d+1)(M₂+1) A/(n δ)))`. This pays polynomial dependence on the failure probability `δ`; it is not an expected-risk guarantee for heavy-tailed labels. The actual likelihood still uses every original label, and its predictions remain raw.

A concrete teacher-oblivious schedule is `λ_n = n^(-3/4)`: at fixed dimension and coefficient cap, every `N ≥ floor(n^(1/4))` competes with **all shallow teachers of width at most `n^(1/4)` with the stated coefficient cap**, with leading comparator coefficient one and remainder `Õ(n^(-1/4))`. This holds for any input law and, at each fixed confidence level, any label law with a finite second moment. The hardtanh implementation of a ReLU teacher is covered by the earlier wider-learner result, as specified below.

As an alternative, the earlier result with `N λ ≥ c` and an exact same-depth compiler gives a **hardtanh learner** the fixed-`d,B` sample polynomial `Õ(C² ε^(-2))` against all coefficient-capped shallow ReLU teachers, without an output cap. This changes the learner activation explicitly. The strongest direct ReLU theorem uses a balanced Gaussian comparison and a joint empirical-loss/energy cutoff. The midpoint argument is retained for the faster coefficient-free one-dimensional rates.

At fixed dimension, growing tanh/sigmoid/hardtanh teacher resources `C ≤ n^a`, `B ≤ n^b` are allowed whenever `a+b < 1/2`; the optimized remainder is `Õ(n^(a+b-1/2))`. For the wider-learner regime `N ≥ c n`, one universal schedule `λ = log^7(en/δ)/n` needs neither exponent and has a vanishing remainder for every such fixed pair, with a logarithmic accuracy term. For the hardtanh learner competing with ReLU teachers, the corresponding condition is `a+2b < 1/2`. The same growth ranges hold at fixed confidence under only a finite label second moment; the universal schedule does not require that moment bound as input. These statements still count coefficient magnitudes; they are distinct from the coefficient-free results below.

A qualitative consequence is **universal risk consistency in probability** on the compact input cube, under any input law and only `E Y² < ∞`. For both the ReLU `log^8` schedule and a bounded monotone activation such as tanh at `λ_n = n^(-3/4)`, **any prescribed widths `N_n → ∞` suffice, however slowly**. Both permit arbitrary prescribed scales `0 < ν_n ≤ 1`. This follows from the quantitative oracles and standard ridge-network approximation; it is not an expected-risk claim or a priority claim about Bayesian consistency.

The strongest coefficient-free one-dimensional theorem uses a **one-hidden-layer ReLU learner** with the same independent Gaussian scaling. If the input density is bounded above and below by positive constants and the learner has `N ≥ n` neurons, a declared comparison-width budget `1 ≤ C ≤ n` gives

```text
raw test risk ≤ inf { R(g) : g is a shallow ReLU network of width C }
                + Õ(C^(4/7) n^(-4/7) + C^(4/5) n^(-3/5)).
```

Every original comparison coefficient is unrestricted. A sufficient sample count is `Õ(C ε^(-7/4) + C^(4/3) ε^(-5/3))`. The likelihood scale uses the declared width budget, never its coefficients or unknown risk. An empirical linear program compresses the midpoint training values into at most `n` neurons; it is only a proof device and does not change the actual Gaussian learner.

A universal deterministic scale `λ = Õ(n^(-8/7))` does **not** use `C` and gives a coefficient-one remainder `Õ(C n^(-4/7))`. More generally, each fixed desired growth exponent `u < 3/4` admits a deterministic schedule with a vanishing power-rate remainder, still for every `N ≥ n`.

For the smaller-width regime `N ≥ 6C+6`, a separate theorem gives remainder `Õ(C^(2/5) n^(-3/10))` and sample count `Õ(C^(4/3) ε^(-10/3))`. One C-oblivious schedule in this regime permits every fixed width exponent below `3/4`, with an explicit `O(1/log n)` additive term. A triangular-wave lower bound identifies the comparison-width thresholds of the universal schedules; it is not an impossibility theorem for every likelihood scale. Under only an upper density bound, an evidence-calibrated theorem gives `Õ(C n^(-1/4) + C² n^(-1/2))`. All these statements extend to marginally sub-Gaussian labels through logarithmic factors.

A separate appendix treats **shallow tanh teachers with coefficients bounded by `B` and raw output bounded by one**. It gives remainder `Õ(A^(2/5)n^(-4/5) + A^(2/3)/n)`, where `A ≍ C²B² + log(n(CB+1))`, under the stated condition `N ≥ c/λ`. At fixed `B`, sufficient samples are `Õ(C ε^(-5/4) + C^(4/3) ε^(-1))`. The teacher-output bound is not imposed on the Gaussian prior or its raw predictions. Bounded Lipschitz activations with derivative of finite total variation, including sigmoid and hardtanh, have the same exponents. Marginal sub-Gaussian labels change only logarithmic factors, with the width condition applied to the normalized likelihood scale.

The coefficient-free results allow marginally sub-Gaussian labels. In these coefficient-free results, the comparison networks have arbitrary finite coefficients, affine biases, and unrestricted raw output. Only comparison functions are clipped temporarily inside the proof. Their tanh implementations have bounded raw outputs, allowing the actual Gaussian raw-output oracle to apply.

This is a fixed-depth result. The sufficient exponents are small, the constants can be large, and efficient posterior computation is not established. A short obstruction shows why likelihood calibration matters: with fixed physical variance, `N/n → ∞` prevents learning even the constant target one in the original tanh model without an output bias.

The localized one-dimensional proof uses a sharp empirical norm comparison for splines, localized multiplier bounds, and the exact Gaussian posterior energy identity. The wide-network refinement adds an exact empirical midpoint comparison, using a linear-programming compression into at most `n` neurons. These proofs are included in the paper. The finite-atom representation is the standard conic Carathéodory principle; the related-work section credits Bach’s convex-neural-network treatment and compares the prediction rules with earlier Gaussian-prior aggregation results.

The general fixed-depth proof combines the [finite Gaussian raw-output oracle](../agnostic-smooth-activations/README.md) with explicit coefficient-free compilers and a new fixed-depth slab compiler. Its exact imported statistical statement and likelihood calibration are reproduced in the paper. The [Boolean circuit compiler](../agnostic-width-only-boolean/README.md) supplies its finite-domain arithmetic step.

The proofs have independent AI-agent mathematical reviews and are **not Lean formalized**. Run `bash build.sh` with `pdflatex` to rebuild the PDF.
