# Independent review: nonexpansive internal rows

Reviewed 2026-11-18 (UTC) by a separate mathematical-review agent. This is a mathematical and statement-correspondence review, not a Lean formalization.

## Scope and verdict

I checked the complete assembled `routes/paper.tex`, `routes/finite-section.tex`, and `routes/counterexample-section.tex`. No substantive mathematical gap was found. Two rendering errors and one explanatory readout-bound sentence were reported and corrected by the author.

The model is a single dense Gaussian network at each fixed width, conditioned on absolute internal row sums at most one (or prescribed gains in the strong-prior theorem). Its comparator networks obey the same restriction. These theorems do not cover arbitrary bounded-width teachers without this restriction.

## Positive results

The capacity argument is valid for continuous odd nondecreasing 1-Lipschitz activations into `[-1,1]`. Such an activation is a scaled mean of threshold signs, giving the initial ridge capacity bound. Symmetric convex feature classes and contraction propagate this bound through bounded absolute row sums without an additional depth factor. Only readout energy `q=N||v||²` is needed. For general gains, the maximum of their product and one is correctly retained in the summary rate.

Balanced cloning preserves the absolute row sums. Its internal energy cost is linear in teacher width times depth, while readout energy is quadratic in width. This gives the displayed `(m²+Hm)/epsilon²` sample dependence, up to logarithms and fixed input/weight parameters, in the strong-prior theorem. Boundary comparators are approached by strictly shrinking internal rows, which supplies positive restricted volume; coercivity and weighted Laplace tails justify raw posterior moments at each fixed width.

For the actual finite posterior, the positive deep result assumes `gamma>=2`; the shallow result permits `gamma>=1`. The comparison measure shrinks internal means, adds Gaussian noise, then conditions each internal noise row to remain within its row-sum budget. Conditioning retains zero mean, so the Gaussian relative-entropy cross term vanishes. Each row event has probability at least `3/4` in the claimed regimes. The resulting comparison entropy preserves coefficient one on full teacher energy.

Readout energy is independent of the prior restriction, so its exponential moment and entropy estimate are exact. The statistical cutoff is only a peeling device. Integrating the global smooth-loss inequality retains the posterior KL term, and its nonlinear terms absorb at most three quarters of this term. Thus the final oracle inequality has coefficient one on comparator risk. The tail control is weighted by raw squared risk, so ordinary posterior means follow by Jensen without changing the likelihood or clipping the actual predictions. The growing-depth condition in the manuscript follows from these explicit constants; it is not inferred merely from a fixed-depth big-O statement.

## Negative result below gamma two

The companion counterexample is also correct. It uses the fixed deterministic law `(X,Y)=(0,1)`, two hidden tanh layers, and an admissible width-one exact teacher with weights bounded by two. It applies for each `1<=gamma<2` and any positive likelihood parameter independent of learner width, including an arbitrary prescribed sample-dependent choice.

I checked the signed-exponential representation of the uniform l1 ball, its subgaussian row estimate, the moment-generating function after Gaussian readout, and the density comparison from the conditioned Gaussian row to the uniform ball. The resulting prior output tail has leading negative exponent proportional to `N^(1+gamma/2)`, whereas the density comparison and posterior normalization cost only `O_lambda(N^gamma)`. This gives posterior convergence to zero in probability precisely for `gamma<2`.

The proof separately controls raw second moments. Radial exponential tilting decreases the mean squared row norm; sign symmetry cancels mixed moments. This yields the evidence lower bound stated in the paper. A Gaussian readout weighted tail, divided by that evidence, gives uniform integrability outside any fixed radius whose square exceeds `1/lambda`. Therefore posterior second moment tends to zero, and both Gibbs and ordinary-mean test risks tend to one. Mere convergence in probability would not have sufficed, but the manuscript supplies the needed weighted estimate.

## Interpretation

The positive and negative finite-scale results establish a threshold at gamma two for this particular conditioned prior and the stated width-independent likelihood calibration. They do not show failure for the unrestricted Gaussian mean-field prior, do not exclude width-dependent calibrations, and do not contradict the separate strong-prior limit at each fixed width. These qualifications are present in the final statements.

## Tanh attenuation interpretation

The subsequent interpretation paragraph was also checked. For tanh and internal row sums at most one, the hidden maximum norm after H layers is at most `tanh^(H-1)(1)<=sqrt(3/(H+2))`. Concavity gives `tanh x>=x/sqrt(2)` on `[0,1]`; integrating `sech²x<=1-x²/2` gives `tanh x<=x-x³/6`, so reciprocal squared amplitudes increase by at least one third each layer. A width-m teacher with readout coefficients bounded by B therefore has amplitude at most `mB sqrt(3/(H+2))`. This is a genuine restriction of deep tanh comparators; the paragraph correctly distinguishes hardtanh, which can pass these amplitudes unchanged. The theorem statements were not changed.
