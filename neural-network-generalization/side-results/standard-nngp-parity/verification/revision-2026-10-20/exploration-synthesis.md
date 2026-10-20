# Senior-author synthesis: exp(Ω(d)) parity lower bounds for the fixed-depth, standard-scaling tanh NNGP

**Notation.** As in the task and in `standard-nngp-parity.tex`:
- D = d+1, M = 2^d, D_r = Σ_{q≤r} C(d,q), ρ = r/d, H_r = log(eD/r).
- For odd F and odd r:
  - W_j = C(D,j)·a_j (odd j) are the D-cube pair masses;
  - τ_r = A·Σ_{odd j≥r+2} W_j;
  - λ_{r+1} = A·W_{r+2}/C(D,r+2);
  - θ_r = W_{r+2}/Σ_{odd j≥r+2} W_j = C(D,r+2)·λ_{r+1}/τ_r;
  - s_{2,r} = Σ_{q>r} C(d,q)·λ_q².
- Q = K_{>r}, and Q_SS is its sampled Gram matrix.
- For a function h, R(h,a) = Σ_{U≠∅} ĥ(U)²/a² is the amplitude ratio. The constant term is excluded on purpose.

**Status labels.**
- **proved**: complete argument, checked by its author and by a referee or by me.
- **sketched**: every step written and checked, not yet typeset as a proof.
- **heuristic**: supported only by numerics or by non-rigorous reasoning.
- **refuted**: shown false.

## 0. Bottom line

1. **No strategy proved exp(Ω(d)).** The most important new fact of this round is the **restriction lemma** (from the margin-decide strategy). It is a noisy version of the Aspnes–Beigel–Furst–Rudich (ABFR) bound. It bounds the parity agreement of any function by a quantity that is only **logarithmic** in its amplitude ratio. Every earlier route used the clipped-parity lemma, which is **linear** in amplitude.
2. **A new, nearly complete typical-sample theorem for (S).** It combines three things:
   - the restriction lemma;
   - two proved lemmas from mean-structure: two-step coefficient regularity, and the intrinsic-dimension matrix-Chernoff tail-Gram bound;
   - the existing log-coercivity lemma.

   Together they give: the sign-only learner (S) fails on ≥3/8 of the cube for **n ≤ exp(c·d·loglog d / log d)**, for tanh at every fixed depth and gain (Theorem S1, §4.1). Status: sketched; every ingredient is proved and I re-derived the assembly. This beats the paper's exp(√d log d). It also makes every sublinear-cutoff result of this round (d^{2/3}, d^{5/7}, d^{3/4}, d^{4/5}) obsolete. It is the limit of what any poly(d) amplitude bound can give.
3. **The task's premise w_{r+2}/τ_r = Θ(1) at linear degree is false asymptotically.** In fact θ_r ≈ 1 − exp(−π/(σ_1(1−2ρ')√(Dκ(ρ')))) ~ π/(σ_1√r), where κ(ρ) = −½log(1−2ρ). Support:
   - five independent computations up to d ≈ 10^4;
   - an exact Poisson-mixture identity for L=2 (proved);
   - my own recheck: within 0.1–1% at d=10240.

   The d=160 ratios (about 0.46 per two levels) are pre-asymptotic. The same ratio is 0.82 at d=2560 and 0.90 at d=10240.
4. **Claim (i) of the task is true, and more than is needed.** Two lemmas suffice for exp(Ω(d)) for (S), with the *existing* Tropp tail-Gram bound and no log-free Gram bound:
   - log-free one-sided coercivity (**Lemma C**);
   - sharp spectral regularity (**Lemma T**).

   With the restriction lemma, C may even lose any factor K(ρ) = e^{o(1/ρ)}.
5. **New in this synthesis (sketched; needs an independent check).** The restriction lemma also removes the "contest between constants" that blocked (M):
   - C + T + the bump lemma B (amplitude-matching's Theorem B) ⇒ exp(Ω(d)) for (M);
   - B alone ⇒ exp(c·d·loglog d/log d) for (M).
6. **Everything at linear degree now hinges on Lemma C.** It is open and plausible, and it cannot be tested numerically in the relevant regime.

## 1. Ranked strategies after vetting

Feasibility scale for exp(Ω(d)):
- 5 = within reach with known tools;
- 3 = reduced to one plausible, well-posed open lemma plus routine work;
- 2 = an open lemma of research difficulty plus non-routine pieces;
- 1 = no viable route.

"Value" = value of the rigorous output for the paper.

| # | Strategy | Learner | What survives vetting | Route to exp(Ω(d)) and missing input | Feas. | Value |
|---|---|---|---|---|---|---|
| 1 | margin-decide | S, M | **Restriction lemma (proved).** Exact checks at d=10 (referee) and d=12 (me) found no violation. **Corollary (proved):** deg h ≤ ρd ⇒ P(fh≥a) ≤ ½ + 1.09√(ρ·log(R/η)) + η. **(S) at exp(c d loglog d/log d)** (sketched, ingredients proved). **(M)** at the same threshold given B (sketched). Corrected extremal inequality (proved). The (M) cost-model verdict is heuristic. | Needs a d-free amplitude bound R = e^{o(1/ρ)}, via C+T | 2.5 | 5 |
| 2 | mean-structure | S | **Proved:** two-step regularity c_{m+2} ≥ γ c_m (L=2 first layer, passes to every composite); cube transfer τ_r ≤ (1+4/γ)τ_{r+2}; intrinsic-dimension Chernoff E‖Q_SS‖ ≤ (e−1)nλ_{r+1} + τ_r log(2τ_r/λ_{r+1}); dual-weight positivity y_iα_i = ρ_i(0+) ≥ 0. The "large generic band" premise is numerically contradicted at d ≤ 14 (least-squares suppression); this is heuristic. Its reduction had a bookkeeping error, fixed by the referees: with a single K, clipped parity needs αK→0, not α²K→0. | C+G | 2.5 | 4 (its two lemmas are load-bearing in S1) |
| 3 | comparison-reduction, sampling-no-log, statistical-physics | S | **Corrected spectrum** θ_r ~ π/(σ_1√r) (heuristic + numerics; the L=2 Poisson-mixture identity is proved). **Conditional C+T ⇒ exp(Ω(d))** (sketched; six referees checked it in the clipped-parity form). **Proved:** Koltchinskii–Mendelson coercivity on L⁴-flat cones (log-free); hypercontractive non-concentration; Brascamp–Lieb Cov_post ≤ K; subcube restriction and kernel splitting only worsen the spectrum. Partial theorems d^{5/7} and d^{3/4} are superseded. | C+T | 3 (conditional on C) | 3 |
| 4 | cavity-weights | S | **Proved:** band-variance identity e = 2·d/dt log Z + λ·tr(Φᵀ K⁻¹(K−Cov)K⁻¹Φ) ∈ [·, ·+d_eff]; (C1) c_m decreasing for L=2. **Refuted (numerically):** the Route-B decoupling ansatz; cross terms dominate with the opposite sign. **Heuristic:** MON' holds in 10/10 small cases. The d^{4/5} result is superseded. | MON'+T plus the existing log coercivity. This is the only route that avoids C. | 2.5 | 3 |
| 5 | amplitude-matching | M | **Theorem A (proved):** D(S)/n ≥ c_δ (a²/τ_r)·min{1, A_δ√(rH_r/d)} w.p. ≥ 1−4δ, so the paper's eq. (matching) is false. **Proved:** λ_max(Q_SS) ≥ nλ_{r+1}. **Theorem B** (sketched; known gaps): D/n ≤ C a²/(ρ²τ_{j0}) + C d²/ρ². **Numerical only (d ≤ 256):** the Krawtchouk inequality \|K_j(k)\| ≤ (1−2j/d)·C(d,j). | (M): C+T+B (new) | 2 | 4 |
| 6 | probit-bregman | S | **Proved:** Bregman Lemma 1, log-free denominator Lemma 2, Lemma 3a, noise-gain lemma, LOO identity. | Needs coercivity-strength amplitude control (R), plus a Gram bound in a window where Tropp fails. No gain over row 3. | 1.5 | 2 |
| 7 | margin-switching | M | **Proved:** switching lemma, twisted-variance lemma, per-point Jensen, local-rigidity identity, sharpened obstruction (= Theorem A). **Refuted:** the competition mechanism; it is circular because it conflates empirical and population sign agreement. | none | 1 | 2 |

**Critic follow-up.**
- All three new angles were run: probit-bregman, cavity-weights and margin-decide. Only margin-decide changed the picture.
- The re-examination of margin-switching confirmed its fatal flaw.

**My probability estimates for the next phase:**

| Outcome | Probability |
|---|---|
| Full exp(Ω(d)) proof for (S) (needs C) | ≈15–20% |
| Lemma T for L=2 | ≈75% |
| Lemma T for all depths | ≈50% |
| Lemma B | ≈70% |
| Complete write-up of S1 | ≈90% |

## 2. What would give exp(Ω(d)): the missing lemmas

### 2.1 What the restriction lemma needs

**Restriction lemma (proved).** For any h on {−1,1}^d, any p ∈ (0,1], any integer j ≥ 0 and any a > 0:

P_x(fh ≥ a) ≤ E_{m~Bin(d,p)} β(j,m) + a^{-2}·Σ_U ĥ(U)²·P(Bin(\|U\|,p) > j),

where β(j,m) = 1 − 2^{-m}·Σ_{i≤(m−j−1)/2} C(m,i) ≤ ½ + (j+1)/√(2πm).

Proof: restrict to a random subcube, split off the restricted degree-≤j part, apply ABFR to it, and treat the rest as L² noise against the margin. Setting p = (j+1)/(e²u) gives the corollary above. The constant term carries weight 0, so the large constant baselines of the posteriors are free.

**(S) interface (AL-S).** By the mean/confidence lemma, outside an exceptional set of measure ≤ (2 + 8/c_θ²)·nλ_{u+1}/τ_u we have {q_S > 13/20} ⊂ {fh > a}, with h = m_{≤u} and a = c_θ√(τ_u/8). Therefore F_{13/20} ≥ 3/8 as soon as, on a sample event of probability ≥ 3/4:
- ‖m_{≤u}‖² ≤ K(ρ)·τ_u;
- nλ_{u+1} ≤ ε·τ_u;
- ρ_u·log K ≤ c_*, where c_* ≈ 3·10⁻³ with the present constants.

**(M) interface (AL-M).** On a sample event, Q*(Σ_{1≤\|U\|≤u} Ĝ(U)² > K a²) ≤ 1/8 and E*‖G_{>u}‖² ≤ ε a².

**Hierarchy (sketched).**

| d-dependence of K (equivalently of the coercivity oversampling) | Resulting threshold |
|---|---|
| poly(d) | exp(c·d·loglog d/log d) |
| polylog(d) | exp(c·d·logloglog d/loglog d) |
| independent of d, with ρ·log K(ρ) → 0 | exp(cd) |

Clipped parity with a poly(d) amplitude bound gives only r ≲ √d. That is why all earlier sublinear results stalled between d^{2/3} and d^{4/5}.

### 2.2 Sign-only learner (S)

**Theorem CT (sketched).** Lemma C + Lemma T ⇒ there is c > 0 such that, for large d and all n ≤ e^{cd}, P_S{F_{13/20}(S) ≥ 3/8} ≥ 3/4. The statements of C and T are in the top-lemma list.

Proof sketch:
1. For n ≤ exp(c' d loglog d/log d), use Theorem S1.
2. Otherwise let r be the largest odd number with K·D_r ≤ n, so n/C(D,r+2) ≤ 2K.
3. **Head.** C gives ‖m_{≤r}‖² ≤ c⁻¹‖Q_SS‖.
4. **Gram.** Tropp's lemma (tail-gram.tex, Lemma 5.2) with T gives d·n·s_{2,r}/τ_r² ≤ C(n/C(D,r+2))·d·θ_r² ≤ C·K/ρ. Hence ‖Q_SS‖ ≤ (1 + C√(K/(ρδ)) + 2Kθ_r)·τ_r.
5. **Band.** The band (r,u] has mass ≤ nλ_{r+1} ≤ 2Kθ_r·τ_r → 0.
6. **Cutoff.** Take u = r + 2k with k = O(log(K/ε)/log(1/ρ)) independent of d. Then τ_r/τ_u ≤ exp(2C_T k/√r) → 1.
7. **Close.** R = O(√(K/ρ)/c), and the restriction lemma closes for ρ ≤ ρ_*. The near-pair and collision terms need n ≤ e^{0.065d}.

**Alternative sufficient sets (sketched):**
- **{C, G}.** G is a log-free Gram bound ‖Q_SS‖ ≤ C_G(τ_r + nλ_{r+1}). Only crude regularity is needed.
- **{C_{1/2}, T, G}.** C_{1/2} is coercivity at n ≥ K√r·D_r: weaker coercivity, traded against a stronger Gram bound.
- **{MON', T}.** Uses the existing log coercivity (cavity strategy's Theorem B).

**Necessity (sketched).** No single lemma moves the exponent past S1:
- C with only crude regularity leaves Tropp's √(d·n·s_2) term, so R ~ √(dK).
- T with the coercivity log leaves nλ_{r+1}/τ_r ~ √r·H_r.
- G with the coercivity log leaves the band at ~ √r·H·τ.

### 2.3 Margin learner (M)

**Theorem CTB (new here; sketched; must be checked independently).** Lemma C + Lemma T + Lemma B ⇒ exp(Ω(d)) for (M): Gibbs error ≥ 3/8, and confidence failure on a constant fraction, w.p. ≥ 3/4.

**Lemma B** (amplitude-matching's Theorem B): on a sample event, D(S)/n ≤ C_B·a²/(ρ²·τ_{j0}) + C·d²/ρ², where j0 is the least odd j with C(D,j+2) ≥ C·n·d/ρ². Two requirements:
- The low part must be handled by a sup-norm small-ball event. Using the full prior sup, as the paper's Lemma 5.2 does, costs a factor d.
- The remaining gaps are near and far-field Krawtchouk bounds, antipodal pairs, and keeping only levels j < d/2.

Proof sketch of CTB:
1. **Head.** On the coercivity event, every posterior draw has (f·G_{≤r})_- ≤ \|G_{>r}\| at the training points. Hence Q*(‖G_{≤r}‖² ≥ R a²) ≤ exp(D − (c·n·R·a² − 1.4·n·τ_r)/(4‖Q_SS‖)).
2. **Amplitude.** With C+T, ‖Q_SS‖ = O(√(K/ρ))·τ_r, and T gives τ_r/τ_{j0} → 1. So R = O(K^{1/2}·ρ^{-5/2}/c) suffices.
3. **Band and tail.** The entropy lemma bounds the band by O(K·θ_r·a²/ρ²). The tail above u' = j0 is ≤ ε a².
4. **Conclusion.** The restriction lemma gives Gibbs error ≥ ½ − C√(ρ·log(K/(cρ))) − o(1).

**Why this works where the referees saw a dead end.**
- Under clipped parity, a generalizing structure needs only amplitude ≈ a/ρ. That is the same 1/ρ² order as the baseline's jump factor, so both sides cost about the same.
- Under the restriction lemma it needs amplitude² ≥ a²·e^{cγ²/ρ}. That costs e^{cγ²/ρ} times more per training point than the budget D/n = O(a²/(ρ²τ)) allows.

**Unconditional consequence (sketched).** B alone (with log coercivity and crude regularity) gives R = poly(d), hence (M) at exp(c·d·loglog d/log d).

### 2.4 Attackability, most to least

1. **T.** Deterministic analysis. For L=2 it needs a Laplace estimate on an explicit integral. For L ≥ 3 it needs a local subexponential composition lemma.
2. **B.** An explicit construction with Krawtchouk estimates.
3. **G.** A plausible but long moment-method project on Walsh tail-Gram matrices at linear degree.
4. **C.** Decisive and hardest: a genuinely new log-free random-sampling inequality.
5. **MON'/curvature.** Posterior-specific. The referees consider it close to C in difficulty, and its own repair needs a log-free single-level norm bound.

Coercivity at *fixed* r is already proved log-free: Koltchinskii–Mendelson plus Bonami give K = C·81^r. So numerics at fixed r test constants, not the log.

## 3. Is exp(Ω(d)) true?

**(S): very likely; the true threshold is probably 2^{Θ(d)}.**
- **HMC (heuristic).** Exact HMC at d = 8–14 (full cube) and d = 20 (n=1500): unseen-point Gibbs error ≥ 0.50 for tanh at L=2 and L=3 and for arcsine. Anti-learning appears for n/M ≳ 0.1, with corr(m,f) down to −0.75. Learning curves collapse in s/M across d.
- **Posterior mean (heuristic).** ‖m‖₂² ≈ σ_x². Oversampled levels are least-squares suppressed:
  - their mass is 30–100× below nλ_q, and 100–600× below the isotropic-α heuristic;
  - band alignment ‖Φᵀα‖²/(N‖α‖²) = 0.000–0.04, against 1 for generic α.
- **Parity coefficient (exact identity).** E_cube[f·m] = λ_d·yᵀK_SS⁻¹m_S ≈ 0.
- **Linear proxy (heuristic).** The linear Gaussian-equivalence proxy reproduces the HMC means (correlation 0.93–0.99). With the corrected spectrum it predicts a typical band mass of O(H·τ).
- **No coupon-collector counterexample to C (proved).** Degree-r polynomials keep ≤ ½ of their L² mass on sets of measure < e^{-(2+ε)r}, and e^{-(2+ε)r} ≫ 1/n for ρ < ~0.2. Heuristically, the smallest Hamming ball holding ¾ of a polynomial's mass has log(1/μ) ≈ ½·log D_r.
- **Coercivity numerics (weak, heuristic).** Local-search upper bounds on the minimum at K ≥ 3 are positive and match Gaussian design (0.04 at K=4, 0.12 at K=8), with no drift over N = 79..2517. LP separability holds exactly at K ≤ 2 (Cover's threshold). This is all at r ≤ 4, where C is in fact already proved.
- **Restriction lemma (proved).** Success at n = e^{cd} would need a posterior-mean amplitude ratio of e^{Ω(1/ρ)} near degree ρd. No computation shows that.
- **Analogy.** The arcsine analogue is a theorem. The structural difference is θ_r ≍ 1/r (arcsine) versus π/√r (tanh), and it only matters through the log in coercivity.

**(M): probably true, but less certain.**
- **Proved.** No degree-ρd structure with amplitude ratio e^{o(1/ρ)} has constant advantage. A structure with advantage γ needs wrong-signed squared mass ≥ c·√ρ·a²·exp((γ−√ρ)²/(1.2ρ)).
- **Per-sample cost.** Theorem A (proved) and Theorem B (sketched) pin D(S)/n between ≈ a²/τ_r and C·a²/(ρ²τ_{j0}). So the KL-barrier constructions, whose one-time energy is e^{O(√d log d)}, are irrelevant per sample.
- **Cost model (heuristic).** Constant-advantage structures lose to the baseline (a constant ≈ a/ρ plus edge-optimal bumps) by a factor ≈ ρ²·e^{γ²/(1.2ρ)}. Weak advantage Θ(√ρ) is possible: block-parity majorities reach γ/√ρ ≈ 0.4–0.5 below baseline cost. The restriction lemma is tight for that example up to √log(1/ρ). This is consistent with a constant failing fraction.
- **Small-d numerics.** The training-margin MAP at d = 20, 24 has \|corr\| ≤ 0.03. In full-cube QPs at d=10, parity-correlated sign patterns cost 3–23× the baseline energy (entropy ignored).
- **Not excluded.** An entropic, sign-pattern-volume mechanism.

**What could break the program.**
- C could fail at linear degree, i.e. the log is real. Then only posterior-specific routes (MON') remain.
- For (M), unseen entropic effects.

## 4. Strongest rigorous partial results reachable soon

### 4.1 Theorem S1 (sign-only learner, typical samples)

**Status.** Sketched; all ingredients proved; assembly re-derived by me and confirmed by the margin-decide referee.

**Statement.** Let φ = tanh, with depth L ≥ 2 and gains fixed. There are c > 0 and d_0 such that, for d ≥ d_0 and every n ≤ exp(c·d·loglog d/log d), P_S{F_{13/20}(S) ≥ 3/8} ≥ 3/4.

**Extension (sketched remark).** The same holds for any odd activation satisfying the paper's assumption whose first-layer coefficients satisfy c_{m+2} ≥ γc_m > 0 and c_m ≥ κe^{-Cm}. This includes erf, which the paper's margin theorem does not cover.

**Proof skeleton.**
1. **Small n.** For n < exp((log d)³), use the every-training-set Theorem 3.2 with r+1 = ⌊0.2√d⌋. This gives F ≥ 0.42 − o(1).
2. **Cutoff.** r is the largest odd number with A_δ·D_r·log(2D_r) ≤ n. Subcritical Lemma 4.4 applies (r ≤ d/64). Maximality and Lemma levels(b) give nλ_{r+1}/τ_r ≤ n/C(D,r+2) ≤ C·A_δ·r·H_r.
3. **Head.** f·m > 0 on S and ‖m‖_K² ≤ n give ¼‖m_{≤r}‖² ≤ P_n(f·m_{≤r})_-² ≤ n⁻¹‖Q_SS·α‖² ≤ ‖Q_SS‖.
4. **Gram.** Q_SS = Σ_i ψ(X_i)ψ(X_i)ᵀ with ψ = (√λ_U·χ_U)_{\|U\|>r}, ‖ψ‖² = τ_r, and intrinsic dimension τ_r/λ_{r+1}.
   - Tropp's intrinsic-dimension Chernoff (2015, Thm 7.2.1) gives E‖Q_SS‖ ≤ (e−1)nλ_{r+1} + τ_r·log(2τ_r/λ_{r+1}).
   - Cor. composite gives log(τ_r/λ_{r+1}) ≤ C·r·H_r.
   - By Markov, ‖Q_SS‖ ≤ C·r·H_r·τ_r/δ.
   - No far-pair, near-pair or collision analysis is needed.
5. **Band and tail.** u = r + 2k with k ≈ C·log d/log(1/(2ρ)) gives ‖m_{(r,u]}‖² ≤ nλ_{r+1} and nλ_{u+1}/τ_u ≤ n/C(D,u+2) ≤ ε.
6. **Regularity.** τ_r ≤ (1+4/γ)^k·τ_u = d^{o(1)}·τ_u.
7. **Restriction lemma.** With R ≤ C·r·H_r·d^{o(1)}/(δc_θ²) = d^{1+o(1)} and ρ_u ≤ c_1/log d: F ≥ ½ − C√c_1 − o(1) ≥ 3/8. The success probability over S is ≥ 1 − 2δ.

**My numerical check** (exact L=2 spectra, d ≤ 10240):
- log R ≈ 13.8 + log(b_r·τ_r/τ_u), with b_r ∝ r·H_r and τ_r/τ_u → 1. So R is linear in d.
- With the present constants (c_θ = 0.0448) the theorem needs ρ ≲ 1.5·10⁻⁴ at d ~ 10⁴. It overtakes the paper's explicit sign-only threshold only around d ≈ 2·10⁶. It is purely asymptotic, like every result of this round.

### 4.2 Corrections to the paper, for the next update

- **Section 6, eq. (matching)** is false for every fixed K (Theorem A, proved). The sentence "cannot hold with a smaller right-hand side by more than a constant factor" is wrong.
- **λ_max(Q_SS) ≥ nλ_{r+1}** (proved): the entropy/head route loses the factor nλ_{r+1}/τ_r whatever bound on D is used.
- **The "second sufficient route"** must exclude level 0, since the Laplacian clip kills constants. With the restriction lemma its requirement becomes R = e^{o(1/α)} rather than a constant independent of α.
- **Spectrum.** The d ≤ 160 decay ratios are pre-asymptotic: θ_r ~ π/(σ_1√r).
- **Remark 3.6(3)** says the exponent needs the sharp ratio. S1 shows it does not.

### 4.3 Proved, reusable tools

- Restriction lemma, its corollary, and the corrected extremal inequality.
- Two-step regularity and the cube transfer.
- Intrinsic-dimension Chernoff bound.
- Theorem A.
- Poisson-mixture identity (L=2).
- Dual-weight positivity and the LOO/Mills identities.
- Brascamp–Lieb covariance domination.
- Band-variance identity.
- Twisted-variance lemma.
- Per-point Jensen inequality.
- Switching lemma.
- Koltchinskii–Mendelson flat-cone coercivity.
- Hypercontractive non-concentration.
- Probit Lemmas 1, 2 and 3a.

### 4.4 Conditional theorems ready to state (sketched)

- CT: C+T ⇒ (S).
- CTB: C+T+B ⇒ (M).
- B ⇒ (M) at exp(c·d·loglog d/log d).

## 5. Recommendation

1. **Now (≈1 week): write up S1.** Put Theorem S1 into `standard-nngp-parity.tex` as a new typical-sample section, together with the restriction lemma, two-step regularity and the intrinsic-dimension Chernoff bound. Replace the "extension suggested by the proof" in Section 6 by Theorem A and the corrected discussion, and update the status table. Do this on the project branch when the user asks; nothing was edited here.
2. **Deepening phase, in parallel:**
   - (a) **Lemma T.** L=2 first (≈3–5 days), then L ≥ 3 (≈1–2 weeks). This turns CT into a theorem with the single hypothesis C.
   - (b) **Lemma C.** Falsification first: spiky-seeded local searches at (d,r) = (16,3), (20,4), (24,4), with n = K·D_r for K = 3..8, tracking the best upper bound as log D_r grows at fixed ρ. Also check the concentration-set picture: Shannon-number eigenvalue counts of Π·1_E·Π, and the sample counts in the minimizers' concentration sets. Then the multiscale argument described in the top-lemma list. Fallback targets: C with K = polylog(d), or C_{1/2} + G.
   - (c) **Lemma B** (≈1 week). It gives (M) at exp(c·d·loglog d/log d) and, with C+T, exp(Ω(d)).
3. **Have the new reduction CTB checked** by an independent referee before relying on it.
4. **Backup if C stalls for more than about two weeks.** Pursue MON'/curvature, tested with synthetic Hamming kernels at θ ≈ 0.2, n/M ≤ 1/16 and κθ ∈ [5, 50].
5. **Stop:**
   - pattern switching for (M);
   - the probit route;
   - KL-only bounds;
   - kernel splitting and subcube restriction;
   - further sublinear clipped-parity variants;
   - using HMC at d ≤ 14 as evidence about exponents.

## 6. My checks

All files are in `/tmp/claude-0/-home-user-AI-works/5853d160-1439-5d10-be76-59b58f86c983/scratchpad/expd/synthesis/`. No repository file was edited.

| Script | What it does | Result |
|---|---|---|
| `restr_check.py` | Exact restriction-lemma check at d=12 on ABFR-extremal univariate PTFs, random low-degree polynomials, and noisy and top-level-perturbed variants | Minimum slack 0, attained by the ABFR-extremal cases; no violation |
| `logR_table.py` | Theorem S1 bookkeeping with the exact tanh L=2 spectra (reusing `../mdecide/w_d*.npy`) | log R ≈ 18–20.5 for d = 160..10240, consistent with R ∝ d |
| `chain_S1.py` | Scan of the same bookkeeping with A ∈ {1, 100} | Confirms that the bound is vacuous at accessible d. Its full scan overflows at d=10240; `logR_table.py` covers that case |
| `theta_check.py` | Recheck of θ_r against the saddle-point formula | Agreement within 1–3% for d ≥ 640 and 0.1–1% at d=10240; θ√r ∈ [2.5, 4.3] |
