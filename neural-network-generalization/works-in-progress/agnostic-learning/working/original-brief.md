# Brief: an agnostic (misspecified, MSE) version of NNBayes generalization

Repository: `/workspace/ai-works` (branch `claude/nngen-agnostic-2026-11-11`). Project folder:
`/workspace/ai-works/neural-network-generalization` (abbreviated `NNG/` below). Do NOT commit or push; write only to the
scratch output folder given in your task. You may read anything in the repo. Python3 with numpy, scipy, sympy is
available for numerical sanity checks (keep scripts in your own scratch subfolder).

## 1. The user's conjecture (verbatim intent)

> NN bayesian learning has the following property: after seeing n data points, test loss is at most the min test loss
> among all width poly(n) MLPs. Here poly(n) can have a fractional exponent. Use MSE loss. The Bayesian learning should
> condition to be pretty close to the given outputs on train inputs for this to be plausibly true. (We may pick whichever
> version of Bayesian learning is best.)

Interpretation used here: an *agnostic oracle inequality* with polynomial sample complexity. For a learner `A`, depth `L`
fixed, the claim is: there are a polynomial `p` (degree may depend on `L`) such that for every input dimension `d`, every
distribution `D` on `X x [-1,1]` (X compact in `[-1,1]^d`), every competitor network `g` of depth `L`, width `m`, weights
bounded by `B`, every learner width `N >= m` (the repo's results are uniform over learner width), and every
`n >= p(d, m, B, 1/eps, log 1/delta)`, with probability `>= 1-delta`:  `L_D(A_n) <= L_D(g) + eps`,
where `L_D(f) = E_{(x,y)~D} (f(x) - y)^2`. Equivalently, test loss <= min over depth-L MLPs with width and weights
<= n^alpha, plus o(1). Note: weights must be bounded too (the repo's complexity `C_L(f)` bounds width and weights by C).

## 2. Repo model and notation (read the cited sources to confirm)

* Inputs: compact `X subset [-1,1]^d` (or unit ball); `xbar = (1, x)`. Depth `L = H + 1 >= 2`; `H` hidden tanh layers of
  width `N`; `h^0 = xbar`, `h^l = tanh(W^l h^{l-1})`, `z_w(x) = v^T h^{L-1}(x)`; no internal biases (constant wires may
  carry offsets).
* Energy: `kappa_N(w) = (d/N)||W^1||_F^2 + sum_{l=2}^{L-1} ||W^l||_F^2 + N ||v||_2^2`.
* Strong-prior Gaussian prior `mu_sigma`: density proportional to `exp(-kappa_N(w)/(2 sigma^2))` (entry variances
  `N sigma^2/d`, `sigma^2`, `sigma^2/N`). Finite-scale family `mu_{N,gamma}`: `sigma^2 = N^{-gamma}`, `gamma >= 1`.
* Data: `(x_i, y_i)` iid from `D`; `eta(x) = E[y | x]`; `Var(y|x)` the noise.
* Learners considered:
  - **SP_c (strong-prior Gaussian likelihood, ratio c):** prior `mu_sigma`, likelihood `y_i ~ N(z_w(x_i), c sigma^2)`.
    Posterior density proportional to `exp(-F_c(w)/(2 sigma^2))`, `F_c(w) = kappa_N(w) + (1/c) sum_i (z_w(x_i)-y_i)^2`.
    Take `sigma -> 0` at fixed `N, n` (and fixed sample). `c = 1` is the clean-label scaling of the repo theorem in
    `NNG/works-in-progress/slt-likelihood/README.md` Section 2 (polynomial bounds for CLEAN labels at every width). `c` may
    depend on `n`. This is the "condition closely on training outputs" learner in the repo's framework.
  - **TUBE_rho:** prior conditioned on `|z_w(x_i) - y_i| < rho` for all `i` (the learner of
    `NNG/side-results/continuous-domains/source/paper.tex`, eq. (posterior)), strong-prior limit or finite scale.
  - **FIX_eta (ordinary tempered Bayes):** posterior proportional to `mu(dw) exp(-eta sum_i (clip z_w(x_i) - y_i)^2)` with a
    fixed `eta` (e.g. `eta <= 1/8`, the exp-concavity threshold of squared loss on `[-1,1]`), at finite prior scale and
    learner width `N`.
* Predictors: Gibbs (random posterior draw), posterior mean of `z_w` (BMA), progressive mixture (average over prefixes
  `t = 0..n` of posterior means).

## 3. Repo results you may use (verify statements in the sources before relying on them)

1. **Cloning energy** (`NNG/side-results/continuous-domains/source/paper.tex`, Section "Cloning and the mass of a teacher
   tube", eq. `teacher-energy`): a depth-L width-C teacher with weights `<= B` has an exact clone at every `N >= C` with
   `kappa_N <= E_* = d(d+1)B^2 + 2(L-1)C^2B^2`.
2. **Energy-Lipschitz bound** (same paper, eq. `energy-lipschitz`): `kappa_N(w) <= K` implies `Lip(z_w) <= K^{L/2}/sqrt(d)`
   (AM-GM on the four energy terms may give a slightly sharper bound; check).
3. **Width-independent energy cover** (same paper, Lemma `compression` and Proposition `energy-cover`): for `K >= 1`,
   `0 < a <= 1`, a finite family `H_{K,a}` of Borel functions, common to all widths, with
   `inf_h sup_X |z_w - h| <= a` whenever `kappa_N(w) <= K`, and `log|H_{K,a}|` polynomial in `d, K, 1/a` at fixed L.
   Explicit parameters: `lambda = a 2^{-L} K^{-(L-1)/2} / (4(L-1))`, `J ~ 256 lambda^{-4} [D_T + log(L/lambda)]`, number of
   coordinates `P = J(d+1) + (L-2) J^2 + J`, rounding mesh `Delta <= a / (4(d+L+1)(2J^2)^L)`; so the degree in K is about
   `4(L-1)` for `L >= 3`.
4. **Finite-scale teacher tube mass** (same paper, Proposition `tube`): for `N >= C`, `gamma >= 1`,
   `mu_{N,gamma}(U_rho) >= exp(-A_L(d,C,B,rho) N^gamma)` where `U_rho = {w : sup_X |z_w - f| < rho}` and `A_L` is explicit
   (eq. `A`), polynomial in `d, C, B, log(1/rho)`.
5. **Strong-prior Laplace estimates** (same paper, proof of Theorem `strong`): fixed N, Gaussian coordinates:
   `liminf sigma^2 log mu_sigma(U) >= -E/2` for an open set U containing a point of energy E;
   `limsup sigma^2 log mu_sigma{kappa_N > K} <= -K/2`.
6. **Exact-interpolation generalization for clean labels** (same paper, Proposition `exact`, Corollary `exact`).
7. **Cheap deep memorization (noisy-interpolation note)** `NNG/works-in-progress/noisy-interpolation/README.md` Sections 2-3:
   any function `r` on the cube `{-1,1}^d` supported on `s` points with `|r| <= 4U` has a Fourier `l1` bound
   `sum_S |r_hat(S)| <= (sum_x r(x)^2)^{1/2}`; parities are exact signed mixtures of bounded-weight affine-tanh features
   with total coefficient `<= 3 sqrt(d)`; sampling (Hoeffding) gives a width `m_s = O(A_s^2 log 2^{d+1})` approximation
   within `1/4`; with `H >= 2` hidden layers, splitting the amplification `A_s` across layers (scalar tanh chain with
   per-layer gain `R ~ A_s^{1/H}`) yields total correction energy
   `K_corr(s) <= d F_d + (H+5) Q + (H+5) A_s^{2/H}`, `F_d = 1 + (d+1)(d+2)^2`, `Q = 2 + 8(5U)^3`,
   `A_s^2 = 1 + 144 U^2 d (s+1)`, at every width `N >= 2 max(C, m_s)`. NOTE: this construction is for sign corrections and
   accuracy 1/4; for real-valued corrections and accuracy `a`, the Hoeffding width and chain gain need re-derivation.
8. **slt-likelihood note** (`NNG/works-in-progress/slt-likelihood/README.md`): SP_1 positive theorem for clean labels
   (proof structure: posterior concentrates on `J_S <= E_* + 1`, then cover + Chernoff); Section 3: with a fixed smooth
   likelihood, shrinking-output priors give posterior -> prior in total variation as width grows, so even constant targets
   fail; XOR counterexample for fixed likelihoods in the strong-prior-first limit.
9. Existing negative results: gamma < 1 full-parity exponential lower bound (`NNG/main-results/subcritical-exponential`);
   conditional obstruction to joint polynomial depth dependence (`NNG/works-in-progress/conditional-nonpolynomial-learning`);
   FAQ Questions 33-37 in `NNG/TECHNICAL-FAQ.md`.

## 4. Draft claims (the lead's analysis; each must be proved rigorously or refuted)

**A (negative, atoms).** Fix depth `L >= 3` (H >= 2). Let `D_d` = uniform `x` on `{-1,1}^d`, `y = +-1` fair coin
independent of `x` (so `eta = 0`, best competitor the zero/constant network, OPT = 1). Take `n = 2^d` (or `n = lambda 2^d`,
`lambda` ~ 1.5 maximizes the constant) iid samples. For SP_c with `c = 1` (more generally any `c = c(n)` with
`c(n) K_mem(n) = o(n)`, roughly `c << n^{1-1/H} / d^{1/H}`), at every width `N >= N_0(n,d)` (polynomial), in the limit
`sigma -> 0`: with probability -> 1, every posterior near-minimizer, the Gibbs predictor, and the posterior mean have test
MSE `>= 1 + E[1/K ; K >= 1] - o(1)`, `K ~ Bin(n, 2^{-d})` (`~= 1.4848` at `lambda = 1`, `~= 1.517` at `lambda ~ 1.5`).
Mechanism: `F_c(w) = kappa + (1/c) sum_x k_x (z(x) - ybar_x)^2 + W` (W = within-atom sum of squares, constant), a
memorizing network fitting `ybar_x` at every seen atom has energy `K_mem = O(d^4 + (dn)^{1/H} + ...) = o(n)`, so every
near-minimizer has `sum_x k_x (z(x)-ybar_x)^2 <= c(K_mem + 1) = o(n)`; at a seen atom the fresh test label is independent
of `ybar_x`, costing `Var/k_x`. Since `n = 2^d` exceeds any polynomial in `d`, no polynomial sample bound can hold.
Variants to cover: sampling without replacement; general `eta` and noise; TUBE_rho (repeated atoms with conflicting labels
make `rho <= 1` infeasible; `rho > 1` gives a constant bias for non-centred noise; without replacement it interpolates and
fails as above); the posterior mean via convexity.

**A' (negative, continuous inputs, deterministic labels).** Replace atoms by tiny clusters of radius `r(n)` around cube
points with a deterministic fine-scale balanced label pattern inside each cluster (e.g. `x = c_j + r u e_1`,
`u ~ U[0,1]`, `y = (-1)^{floor(uM)}`). Near-minimizers have energy `<= O(n)`, hence Lipschitz `<= poly(n)`, so for
`r << 1/(n^2 Lip_max)` each cluster behaves like an atom; same excess. This answers the objection that real inputs do not
repeat and the objection that real labels are deterministic.

**B (positive, tempered co-scaling).** SP_c with `c = c(n) = n^{1-theta}`, `0 < theta < theta_L` (`theta_L = 1/(4(L-1))`
with the repo cover; possibly larger with a sharper capacity bound): for every `D` on `X x [-1,1]`, competitor `g`
(depth L, width m, weights <= B), every `N >= m`, every `eps, delta`, and `n >= poly_L(d, m, B, 1/eps, log 1/delta)`,
the `sigma -> 0` posterior (all near-minimizers of `F_c`, Gibbs, posterior mean; with clipped or unclipped outputs) has
`L_D <= L_D(g) + eps` with probability `>= 1-delta`. Proof idea: near-minimizers satisfy `kappa <= kappa(g)+1+n U^2/c`
and `Lhat(z) <= Lhat(g) + c (E_*(g)+1)/n`; uniform convergence over the width-independent energy cover at energy
`K ~ n^theta`.

**C (positive, ordinary tempered Bayes at polynomial width; failure at arbitrary width).** FIX_eta with `eta <= 1/8`,
progressive-mixture posterior mean: `E L_D <= L_D(g) + 4 rho + A_L(d,m,B,rho) N^gamma / (eta (n+1))` via exp-concave
aggregation (Vovk / Kivinen-Warmuth / Juditsky-Rigollet-Tsybakov / Audibert) with the tube-mass bound of item 3.4.
Polynomial when learner width `N` is polynomially bounded. At arbitrary width the shrinking-output prior makes the
posterior approach the prior (item 3.8), so width-uniformity fails even for constant targets.

**D (phase transition in c).** Memorization threshold `c ~ n^{1-1/H}` vs uniform-convergence threshold
`c ~ n^{1-1/(4H)}` (repo cover) or `n^{1-1/(H+1)}` (norm-based Rademacher bounds?). Goal: narrow or close the gap.

**E (finite exponent gamma >= 1, every width, no sigma limit).** Do A and B transfer to `mu_{N,gamma}` with observation
variance `c N^{-gamma}`? (Positive: adapt the slt-likelihood finite-scale proof. Negative: needs a tube-mass bound for the
memorizing network with rate `o(n)`; the repo's `A_L` grows with teacher width, so this may be open.)

## 5. Standards

* Full, checkable proofs. Track quantifier and limit order exactly (sigma -> 0 after fixing sample and width).
* Explicit constants where feasible; otherwise explicit polynomial forms.
* State clearly what is proved, what is conjectured, and any gap. Never paper over a gap.
* When citing a repo lemma, give file path and label, and confirm the statement matches your use.
* Write mathematics in Markdown with `$...$` / `$$...$$` LaTeX, suitable for inclusion in a research note.
