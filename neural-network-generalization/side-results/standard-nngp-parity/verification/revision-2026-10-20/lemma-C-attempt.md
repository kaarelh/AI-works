# Lemma C (log-free one-sided squared coercivity at linear degree): analysis

Scratch work, scripts and raw logs: `/tmp/claude-0/-home-user-AI-works/5853d160-1439-5d10-be76-59b58f86c983/scratchpad/expd/deep0/`.

## 0. Verdict

**Status: open.** I could neither prove nor disprove Lemma C, including its weak form (K, c depending on ρ). Here is what I established.

1. **No counterexample. The numerics support even the strong form, with absolute K and c.**
   - **Two-sided smallest eigenvalue.** For degree-≤r Walsh features at n = K·D_r, the smallest eigenvalue λ_min of the empirical Gram matrix follows the Marchenko–Pastur edge (1−K^{−1/2})² and does not drift as D_r grows at fixed ρ. This holds for ρ = 1/5, 1/6 and ρ ≈ 0.1 (D_r up to 12 951), and λ_min is still stable at ρ = 1/3, 0.4 and 1/2.
   - **One-sided minimum.** The minimum of P_n(Q_−²) found by an exact-step alternating minimization tracks the Gaussian-design/Gordon value (√(1/2) − √(1/K))². At K = 4 the Gordon value is 0.0429, and along ρ = 1/6 the minimum is 0.041 at both (18,3) and (24,4). The Walsh/Gaussian ratio is noisy (0.25–1.2) at D ≤ 80 and settles to 0.88–1.10 at D ≈ 1000–2300 (0.97 at D = 2325).
   - **Minimizers are delocalized.** Kurtosis ‖Q‖₄⁴/‖Q‖₂⁴ is about 3.3–7.2; at D = 6196 it is 3.49. A Christoffel kernel has about 13–70, and a random direction about 3. The coupon-collector mechanism, which would require spiky minimizers, is not what drives the minimum.
2. **Rigorous log-free results (§3):**
   - **Thm 1 (flat directions).** Coercivity holds with K = C·H on every "H-flat" direction. The proof uses truncation, the contraction principle and Bousquet's inequality, with no VC theory and no Paley–Zygmund step. For ‖Q‖₄ ≤ L‖Q‖₂ this gives L⁴ instead of the synthesis's L⁸. Unconditionally (all P), Lemma C holds with K = e^{2r+O(√r)} instead of 81^r. That is still far worse than A·log(2D_r) at linear r.
   - **Thm 2 (fixed set E).** A localized version: for any fixed set E, the bound holds uniformly over all P, with failure probability e^{−c n μ(E)/θ}.
   - **Thm 3 (main reduction).** Combining the layer cake, the relative VC bound and a structured union bound gives, with high probability and for all P,
     P_n((fP)_−²) ≥ ½·Str_F(P/‖P‖)·‖P‖².
     Here Str is the "structured negative mass" defined in §3.3. So **Lemma C ⟸ (S): inf_P Str_F(P) ≥ 2c for some family F with log|F_q| ≤ (K/32)·q·D_r.** The failure probability is then super-exponentially small. The two-sided analogue (S2) gives the two-sided log-free lower isometry.
   - **Prop 4 (radial directions).** (S) holds, unconditionally, for every P that is radial about any centre. These include the Christoffel kernels, which are the extremal spiky directions (mass on sets of measure ≈ e^{−1.96r}). So the spikiest directions are harmless; the needed sample size is only C·d·e^{3r} ≪ D_r.
   - **Prop 4′ (radial × free factor).** The same holds for P = (radial)·(free factor of degree ≤ r′, with arbitrary sign pattern), and sums of such over a common centre, provided D_{r′}d²e^{3r}log n ≪ D_r (e.g. r′ = r/2 when ρ < e^{−6}).
   - **Prop 5 (localization costs degree).** I computed the exact spectrum of Π_r 1_C Π_r for a subcube C of codimension k. It has ≈ (4ρ(1−ρ))^{k/2}·(trace) eigenvalues ≥ ½. The generic trace bound allows 2·(trace), so localizing to measure 2^{−k} costs degree ≈ k/2.
   - **Prop 6 (necessity).** Lemma C implies the log-free two-sided lower isometry for Poly_{≤r}.
3. **Where it is stuck: only (S).** Every step is log-free except one: showing that the superlevel sets {(fP)_−² ≥ s} of *spiky* P contain structured subsets of comparable measure, drawn from a family of entropy O(q·D_r). Here "spiky" means measure < 32 log(2eK)/K. This is a pure statement about degree-r polynomials, with no probability in it. §4 explains why every soft tool tried fails exactly here.
4. **Problems found in the synthesis (§6):**
   - (a) **The decay condition is too weak.** The stated condition ρ·log(K/c) → 0 does not suffice for the CONSEQUENCE. In the Theorem-10.2 skeleton the final bound is ≍ ρ·√((b + K)/c)·√(τ_r/τ_u), so a polynomial condition ρ²(K + b)/c → 0 is needed.
   - (b) **"Lemma C alone gives no improvement" is wrong.** Inside the skeleton, Lemma C alone (with Tropp's Gram bound) moves the reachable sample size from exp(d^{3/5}) to exp(d^{3/4}).
   - (c) **Side result (proof sketch in §6.3; worth an independent check).** Run the existing logged tools at polynomial degree r ≤ c·d^{3/5}/(log d)^{1/5}, rather than at linear degree. The tools are Lemma 4.4, the paper's universal tail-Gram lemma (Tropp-based), the universal level-mass inequality and clipped parity. This gives **failure of the sign-only tanh learner (any fixed depth) on ≥ 3/8 of inputs for all n ≤ exp(c d^{3/5}(log d)^{4/5}), on typical samples**.
     - The only kernel-specific input is level-mass regularity τ_r ≤ Cτ_{r+2}.
     - I prove it from c_{m+2} ≥ c₀c_m: by a walk coupling, π_{j+2} ≥ c₀(1 − (2j+1)/D)·π_j for the level masses. The ratio bound passes to every composite by a composition-injection argument, and c₀ > 0 holds for the first-layer tanh dual by a saddle-point estimate.
     - This improves exp(√d·log d) for (S), for typical training sets.

---

## 1. Setting and notation

- Ω = {±1}^d with the uniform measure μ. V = V_r = Poly_{≤r} has dimension D = D_r = Σ_{q≤r} C(d,q).
- Orthonormal basis φ(x) = (χ_U(x))_{|U|≤r}, with flat Christoffel function |φ(x)|² ≡ D.
- f = χ_[d]. Lemma C concerns Q = fP with P ∈ V_r.
- X_1..X_n are iid μ, n = K·D, and P_n is the empirical mean. t_− = max(−t, 0).
- **Parity balance** (subcritical Lemma "parity-squared-balance"): E(fP)_−² ≥ (½ − √(r/d))‖P‖².
- **Spiky mass:** M_P(q) := sup{E[P²1_T] : μ(T) ≤ q}.
- **Hypercontractivity:** ‖P‖_{2+2s} ≤ (1+2s)^{r/2}‖P‖₂. With s = 1 and μ(T) ≤ e^{−3r},
  M_P(e^{−3r}) ≤ 3^r e^{−1.5r}‖P‖² = e^{−0.40r}‖P‖².
  So only scales q ∈ [e^{−3r}, 1] matter. For ρ < e^{−2}, e^{−3r}D_r ≥ (e^{−2}/ρ)^r/poly is exponentially large; this is the "no coupon collector at scale 1/n" remark of the synthesis.

## 2. Reductions

- **Prop 6 (necessity).** (fP)_−² ≤ P², so Lemma C(K,c) implies P_n(P²) ≥ c‖P‖² for all P ∈ V_r. This is the log-free two-sided lower isometry λ_min(Φ^TΦ/n) ≥ c. Any counterexample to the latter disproves Lemma C. None was found (§5).
- **Layer cake.** For g ≥ 0, P_n g = ∫₀^∞ P_n{g ≥ s} ds. Applied to g = (fP)_−², the superlevel sets are
  L_s(P) := {x : f(x)P(x) ≤ −√s} = {x : ⟨a, f(x)φ(x)⟩ + √s ≤ 0},
  which are affine halfspaces in the feature space ψ = fφ ∈ ℝ^D. So the whole problem is a *relative* ε-approximation problem for halfspaces, restricted to the halfspaces that occur as level sets. This is the source of the "union over E" issue.

## 3. Rigorous results

### 3.1 Theorem 1 (flat directions, log-free)

**Setting.** Let V be any D-dimensional function space on a probability space with flat Christoffel function |φ|² ≡ D. Let y: Ω → {±1} be any label function, H > 0, and g_P := min((yP)_−², H).

**Statement.** For every x > 0, with probability ≥ 1 − e^{−x}, simultaneously for all P ∈ V with ‖P‖₂ ≤ 1,

  P_n g_P ≥ E g_P − 8√(HD/n) − √(2x(H + 16√(HD/n))/n) − x/(3n).

**Proof.** Let Z = sup_{‖P‖≤1}(E g_P − P_n g_P); it is measurable because V is finite-dimensional.

1. Symmetrization gives EZ ≤ 2E sup|n^{−1}Σ ε_i g_P(X_i)|.
2. Conditionally on X, g_P(X_i) = ψ_i(P(X_i)) with ψ_i(t) = min((y(X_i)t)_−², H). Each ψ_i is 2√H-Lipschitz with ψ_i(0) = 0. The contraction principle (Ledoux–Talagrand Thm 4.12) bounds the Rademacher sum by 2·2√H·E_ε sup_{‖P‖≤1}|Σ ε_i P(X_i)|.
3. sup_{‖P‖≤1}|Σε_iP(X_i)| = |Σ ε_i φ(X_i)|₂, whose ε-mean is ≤ (Σ|φ(X_i)|²)^{1/2} = √(nD). Hence EZ ≤ 8√(HD/n).
4. Concentration: f_P := E g_P − g_P satisfies f_P ≤ E g_P ≤ ‖P‖² ≤ 1 and Var f_P ≤ E g_P² ≤ H·E g_P ≤ H. Bousquet's inequality, applied to nZ with v = nH + 2nEZ, gives the claim. ∎

**Corollary 1.1.** Take V = V_r, y = f, r ≤ d/64, n = KD_r. Since min((fP)_−², H) ≥ (fP)_−² − (P² − H)_+, on this event

  P_n(fP)_−² ≥ (½ − √(r/d) − η_P(H) − ε_n)‖P‖²,  where η_P(H) := E(P² − H‖P‖²)_+ / ‖P‖²,

and ε_n = 8√(H/K) + O(√(xH/(KD_r))). Consequences:
- **"H-flat" directions** (η_P(H) ≤ 1/8) are coercive with constant 1/8 as soon as K ≥ C₀H. This is log-free.
- **‖P‖₄ ≤ L‖P‖₂** implies η_P ≤ L⁴/(4H), so K ≍ L⁴ suffices (the synthesis has L⁸).
- **All P.** Hypercontractivity gives η_P(H) ≤ (1+2s)^{(1+s)r}H^{−s}. Taking s = 1 gives H = 8·9^r; optimizing s gives H = e^{2r+O(√r)}. So **Lemma C holds unconditionally with K = e^{2r+O(√r)}**, which beats the quoted 81^r. It is useless at linear r, where A·log(2D_r) ≈ A·r·log(e/ρ) ≪ e^{2r}.

### 3.2 Theorem 2 (one fixed set E, uniform over all P)

Same setting. For a fixed E with μ(E) = q and g_P^E := min((yP)_−², H)1_E, with probability ≥ 1 − e^{−x}, for all ‖P‖ ≤ 1:

  P_n g_P^E ≥ E g_P^E − 8√(HqD/n) − √(2x(H + 16√(HqD/n))/n) − x/(3n).

**Proof.** ψ_i ≡ 0 when X_i ∉ E, so the contraction is applied only to I = {i : X_i ∈ E}. This gives √(|I|D), and E√|I| ≤ √(nq). ∎

**Use.** With H = θ/q, the error is 8√(θ/K) + small, with failure probability exp(−cε²nq/θ). A union bound over sets of measure ≈ q is therefore log-free whenever the family has entropy ≤ cε²KqD/θ. This is the synthesis's "one fixed E is log-free" claim, now uniform over **all** P and not just those near a local subspace.

**Limitation (the multi-scale problem).** The error is absolute; it is not proportional to the mass P has on E. A P whose negative mass is spread over J dyadic height scales gets J such errors, forcing K ∝ J² (or ∝ J, even if every E is spectrally "nice"; see §4.5). J can be ≍ r. Theorem 3 avoids this.

### 3.3 Theorem 3 (main reduction: layer cake + relative VC + structured union bound)

**Setup.**
- Let n = KD_r, δ ∈ (0,1), and q₁ := 16[(D_r+1)log(2eK) + log(4/δ)]/n (≈ 16 log(2eK)/K).
- For k ≥ 0 let F_k be families of subsets of Ω with μ(E) ≥ 2^{−k−1} for E ∈ F_k and log|F_k| ≤ A·2^{−k}D_r. Put F = ∪F_k.
- For ‖P‖ = 1 define
  m_s(P) := max{ μ(L_s(P))·1[μ(L_s(P)) ≥ q₁],  sup{μ(E) : E ∈ F, E ⊆ L_s(P)} },  Str_F(P) := ∫₀^∞ m_s(P) ds.

**Statement.** With probability ≥ 1 − δ − Σ_k exp(−(K/16 − A)2^{−k}D_r), every P ∈ V_r satisfies

  P_n((fP)_−²) ≥ ½·Str_F(P/‖P‖)·‖P‖².

**Proof.**
1. **VC event.** The sets L_s(P) are affine halfspaces in ψ-space, a class of VC dimension ≤ D_r + 1 with shatter function ≤ (em/(D_r+1))^{D_r+1}. The relative-deviation inequality (Vapnik–Chervonenkis; Anthony–Shawe-Taylor 1993),
   P(∃A: μ(A) − P_n(A) > ε√μ(A)) ≤ 4Π(2n)e^{−nε²/4},
   with 4ε² = q₁ gives, with probability ≥ 1 − δ, P_n(A) ≥ μ(A)/2 for every such A with μ(A) ≥ q₁.
2. **Structured event.** Chernoff gives P(P_n(E) < μ(E)/2) ≤ e^{−nμ(E)/8} ≤ e^{−K2^{−k}D/16} for E ∈ F_k. Take a union bound.
3. **Combine.** On both events, P_n(L_s) ≥ m_s(P)/2 for every s simultaneously, using P_n(L_s) ≥ P_n(E) for E ⊆ L_s. Integrate over s. ∎

**Corollary 3.1 (conditional Lemma C).** Suppose that for some K ≥ 32(A+1) and c > 0, every unit P ∈ V_r has Str_F(P) ≥ 2c (hypothesis **(S)**). Then Lemma C(K, c) holds. The failure probability is ≤ δ + Σ_k e^{−(K/32)2^{−k}D_r}.

Only the scales 2^{−k} ≥ e^{−3r} are needed: the rest cost at most M_P(e^{−3r}) ≤ e^{−0.4r} of Str. So the structured part of the failure probability is ≤ r·exp(−(K/32)e^{−3r}D_r), which is super-exponentially small for ρ < e^{−2}.

**Unconditional content.** Str_F(P) ≥ E min((fP)_−², s₁(P)) ≥ ½ − √(r/d) − M_P(q₁), where s₁ is the level at which μ(L_s) drops below q₁. So **Lemma C holds log-free on {P : M_P(32 log(2eK)/K) ≤ ¼}**, i.e. for every direction that does not put a quarter of its mass on a set of measure ≍ log K/K. The open part is exactly the spiky directions.

**Theorem 3′ (two-sided).** The same statement holds with L_s replaced by {P² ≥ s}, which is a union of two halfspaces (log-shatter ≤ 2(D+1)log(2en/(D+1))). Hypothesis (S2) on superlevel sets of P² then gives the log-free two-sided lower isometry.

### 3.4 Proposition 4 (radial directions are harmless, unconditionally)

**Family.** Let F_rad = {∪_{h∈H} S_h(x₀) : x₀ ∈ Ω, H ⊆ {0..d}}, where S_h is a Hamming sphere. Then |F_rad| ≤ 2^{2d+1}.

**Key observation.** If P(x) = g(dist(x, x₀)), then fP is constant on each sphere, because f = f(x₀)(−1)^h there. Hence L_s(P) ∈ F_rad.

**Proof.** Chernoff plus a union bound over F_rad, restricted to sets of measure ≥ e^{−3r}, gives P_n(E) ≥ μ(E)/2 for all of them with probability ≥ 1 − 2^{2d+1}e^{−ne^{−3r}/16}. The layer cake then gives

  P_n(fP)_−² ≥ ½(E(fP)_−² − M_P(e^{−3r})) ≥ ½(½ − √(r/d) − e^{−0.4r})‖P‖² ≥ ‖P‖²/8

for **all** P that are radial about some centre, provided r ≤ d/64 and r ≥ 8. Only n ≳ d·e^{3r} is needed, which is ≪ D_r for ρ < e^{−2}. ∎

**Christoffel kernels.** The kernels k_r(x₀,·) are radial and are the extremal spiky directions; see the table below, where κ_C = ‖k_r(x₀,·)/√D‖₄⁴ (exact Krawtchouk computation, `christoffel.py`):

| d | r | ρ | log κ_C / r | log(κ_C/D_r) / r | D_r/(κ_C·d) |
|---|---|---|---|---|---|
| 160 | 20 | 1/8 | 1.89 | −1.02 | 4.2·10⁶ |
| 320 | 20 | 1/16 | 1.95 | −1.68 | 1.1·10¹² |
| 320 | 40 | 1/8 | 1.96 | −0.99 | 4.5·10¹⁴ |
| 320 | 53 | 1/6 | 1.94 | −0.72 | 1.4·10¹⁴ |
| 320 | 160 | 1/2 | 1.38 | −0.004 | 0.006 |

So the effective support is p_C = 1/κ_C → e^{−2r}, the hypercontractive extreme. At ρ = ½ a Christoffel kernel is essentially a point mass, which is the beginning of the coupon collector at ρ → 1.

### 3.4′ Proposition 4′ (radial localizer × low-degree free factor)

**Setting.** Fix r′ ≤ r and write D′ = D_{r′}. Let 𝒫(r′) be the set of P ∈ V_r for which there is a centre x₀ such that, on every sphere S_h(x₀), P agrees with a polynomial of degree ≤ r′. Examples:
- P = R(dist(·,x₀))·g with deg g ≤ r′;
- sums Σ_j R_j(dist)·g_j over a common centre.

These are spiky (the mass sits in the radial localizer's ball), and the sign of fP oscillates arbitrarily inside the mass set through g.

**Statement.** Suppose r ≤ d/64, r ≥ 8, and
  n ≥ 32(d+1)e^{3r}[(D′+1)log(2en) + 2d + log(8(d+1)/δ)].
Then with probability ≥ 1 − 2δ, every P ∈ 𝒫(r′) satisfies P_n(fP)_−² ≥ ‖P‖²/12.

**Proof sketch.**
1. **Sphere counts.** Condition on N_h = #{i : X_i ∈ S_h(x₀)}; given N_h, these points are iid uniform on S_h. Chernoff gives N_h ≥ nμ(S_h)/2 for every sphere of measure ≥ e^{−3r}/(2(d+1)).
2. **Relative VC inside each sphere.** On S_h the sets L_s(P) ∩ S_h are halfspaces in degree-≤r′ features, a class of VC dimension ≤ D′+1. Apply the relative-deviation bound inside S_h, with a union bound over the 2^d(d+1) pairs (x₀, h).
3. **What is lost.** The pieces left uncovered (thin spheres, or level pieces of relative measure below the VC threshold) have total measure ≤ e^{−3r}, hence carry ≤ M_P(e^{−3r}) ≤ e^{−0.4r}‖P‖² of mass.
4. **Conclusion.** The layer cake plus parity balance gives ≥ ¼(½ − √(r/d) − e^{−0.4r}). ∎

**When this is useful.** The sample requirement is ≪ D_r whenever D_{r′}·d²·e^{3r}·log n ≪ D_r. For r′ = r/2 this means (1/ρ)^{r/2} ≫ e^{3r}·poly, i.e. ρ < e^{−6} roughly; for r′ = r/4 it suffices that ρ < e^{−4}.

**Mechanism.** This is the mechanism (S) asks for in general: a structured localizer from a small family, plus a free factor whose local VC dimension is small compared with the local sample size. For general P (r′ = r) the condition fails, which is exactly the open case.

### 3.5 Proposition 5 (subcube localization costs degree; exact)

Let C = {x_S = σ} with |S| = k. In the basis χ_Aχ_B (A ⊆ S, B ⊆ S^c, |A| + |B| ≤ r), Π_r 1_C Π_r is block-diagonal over B, and each block is rank one, 2^{−k}vv^T with v_A = σ_A. Hence:
- the nonzero eigenvalues are θ_B = 2^{−k}·Σ_{i ≤ r−|B|} C(k,i), one for each B ⊆ S^c with |B| ≤ r;
- θ_B = 1 iff |B| ≤ r − k, and θ_B ≥ ½ iff r − |B| ≥ ⌈(k−1)/2⌉;
- the trace is 2^{−k}D_r.

So N_C(½) ≈ D_{r−k/2}(d−k) ≈ (4ρ(1−ρ))^{k/2}·trace = q^{1+γ}D_r, with q = 2^{−k} and γ = log₂(1/(4ρ(1−ρ)))/2 (≈ 2.0 at ρ = 1/64). The generic Landau/trace bound only gives 2qD_r. (Checked numerically: `check_subcube.py`, max error 6e−16.)

---

## 4. Where it gets stuck

### 4.1 The missing statement

**(S_K)** Fix K large. One needs families F_k of subsets of {±1}^d with μ(E) ≥ 2^{−k−1} and log|F_k| ≤ (K/32)2^{−k}D_r, for 2^{−k} ∈ [e^{−3r}, q₁], such that for every unit P ∈ V_r:

  ∫_{s : μ(L_s) < q₁} sup{μ(E) : E ∈ F, E ⊆ L_s(P)} ds ≥ 2c − ∫_{s : μ(L_s) ≥ q₁} μ(L_s) ds.

In words, either P has ≥ 2c of negative mass at "VC-visible" levels (measure ≥ q₁ ≍ log K/K), or its spiky negative level sets contain structured subsets of comparable measure from a family of entropy O(qD_r). By Cor. 3.1 this implies Lemma C with absolute K and c.

**What is known about (S):**
- **Radial P:** holds (Prop 4).
- **Radial × free factor of degree ≤ r′, D_{r′} ≪ e^{−3r}D_r/(d² log n):** holds (Prop 4′).
- **Subcube-supported P = 1_C·g, codim k ≥ 3r/(log(1/(2ρ)) + 3):** holds, by the argument of Prop 4′ with subcubes in place of spheres.
  - Inside C, fP = ±f′g with f′ the parity of the free coordinates, so the level pieces are halfspaces in features of VC dimension D_{r−k}(d−k)+1.
  - The local ratio is K′ = n2^{−k}/D_{r−k}(d−k) ≈ K(2ρ)^{−k} ≥ e^{3(r−k)}·polylog, so the uncovered pieces fall below the hypercontractive scale of g.
  - For smaller k this only reduces to the same question in dimension d−k at degree r−k, with the better ratio K(2ρ)^{−k}.
- **Products of radial factors on a bounded number m of disjoint blocks:** holds by the same proof as Prop 4. Here fP is constant on products of spheres, so L_s is a union of at most (d+1)^m such pieces. The family has entropy ≤ ((d+1)^m + d)·log 2 + d·log m ≪ e^{−3r}D_r when (d+1)^m ≪ e^{−3r}D_r. For m ≍ r the count is too large and the case is open.
- **General spiky P:** open.

The parity enters (S) only through "E ⊆ {fP < 0}". On a structured piece where P has constant sign, E can be taken as (piece) ∩ {f = ∓1}, which has half the measure for balls and subcubes. Pieces where P oscillates need a structured description of the oscillation, as spheres provide for radial P.

**A functional form of (S) that would suffice (conjecture S′).** For every unit P ∈ V_r with M_P(q) ≥ ¼ (q ≤ q₁), there should exist:
- polynomials h₁..h_m of degree ≤ s, with m·D_s·log(1/q) ≤ c·q·D_r;
- a set G carrying ≥ ⅛ of P's mass at levels of measure ≤ q;

such that on G, sign(P) and the dyadic level of P² are functions of (h₁(x), .., h_m(x)) of bounded semi-algebraic complexity.

Then the sets {(h₁,..,h_m) ∈ A} ∩ {f = ±1} form a class of VC dimension O(m·D_s) (Warren/Milnor sign-pattern bounds). The relative VC bound handles them at every measure ≥ C·m·D_s·log n/n ≪ q, and the layer cake gives (S).

All the proved cases are instances:
- radial: m = 1, h = ⟨x, x₀⟩;
- radial × free: h = (⟨x, x₀⟩, g);
- subcube: h = (x_S, g);
- powers P = h^j: level sets of h together with the parity classes;
- products of radial factors on m blocks.

The heuristic "localization costs degree" (§4.3) predicts s ≲ 2r/log(1/q), which is compatible with S′ for small ρ.

### 4.2 Why the soft tools all fail at the same place

- **Small ball (Koltchinskii–Mendelson, Mendelson).** The uniform small-ball constant is e^{−Θ(r)}: subcube indicators give 2^{−r}, Christoffel kernels e^{−2r}.
- **Uniform integrability (Yaskov) and truncation (Thm 1).** sup_P E[P²1{P² > T}] ≈ 1 until T ≈ e^{2r}.
- **Lee/Rudelson chaining (Lemma 4.4).** The log is E max_{i≤n}|⟨g, φ(X_i)⟩| ≈ √(2D log n), the ℓ_∞(sample) entropy of the unit ball. It is sharp for that functional.
- **Matrix Chernoff and Brailovskaya–van Handel universality.** These carry an R·log D term with R = D/n = 1/K. The coupon collector shows this is sharp for general flat-Christoffel spaces.
  - In the Gaussian proxy G − I = Σ_W γ_W M_W/√n (M_W the group translations compressed to B_r), BBvH's v(X) ≈ σ(X), so their v-bound gives nothing.
  - Only the crossing/alignment parameter is small, and only heuristically: with identity contractions and averaged over the diagonal, w(X)⁴ ≈ σ⁴·κ_C/D, where κ_C/D ≈ e^{−r(log(1/ρ)−1)} (table above). The supremum over all contractions was not computed. See §4.6.
- **PAC-Bayes with Gaussian smoothing.** Smoothing adds flat noise but does not remove the spike. The lower-tail exponent is still governed by E P⁴.
- **Random-label reduction.** Condition on all coordinates but one, j. Then f(X_i)P(X_i) = y_i·(P₀ + X_{ij}P₁)(X_i′), with y_i iid uniform signs independent of X′ and ‖P₁‖² = ‖D_jP‖² averaging ≤ ρ‖P‖². So parity labels are equivalent to *random* labels (Wendel-symmetric). Robust Cover for a fixed subspace and random signs, however, still needs "empirical flatness" of the subspace: sup_a Σ y_i a_i|a_i| ≤ 2τ√D + (mass of a above height τ). Spiky directions violate this.
- **Union over local subspaces W_E.** For one E the bound is log-free (Thm 2). The number of distinct supports (traces of mass sets on the sample) is the whole issue. In the coupon-collector space it is C(D, qD) = e^{qD log(1/q)}, and the log is then real (K ≳ log(1/q)).

### 4.3 The quantitative coupon-collector picture

**Generic VC.** Level sets at scale q need n ≳ D·log(1/q)/q.

**Under (S).** n ≳ D suffices (Thm 3).

**Necessary for failure (union-bound heuristic).** A failure needs ≳ e^{c·n·q} "independent" spiky directions at a common scale q ∈ [e^{−2r}, log K/K]. Since n·q ≥ K·e^{−2r}·D_r is exponentially large, a counterexample needs a doubly-exponential family of spiky degree-r polynomials whose mass sets are nearly independent. Every explicit family I know (radial, subcube, products, exponential tilts by lower-degree g) has entropy e^{poly(d)} or e^{D_s} with D_s ≪ q·D_r.

**Heuristic for (S) ("localization costs degree").** Take a degree-r polynomial concentrated on {g ≥ θ}, where g is Gaussian-like of degree s and the set has measure q = e^{−θ²/2}. The Hermite coefficients of the localizer up to order ≈ θ²/4 must lie in V_r, so s·log(1/q)/2 ≲ r. Hence spiky mass sets at scale q should be level sets of polynomials of degree ≤ 2r/log(1/q), a family of entropy D_{2r/log(1/q)}·O(log) ≪ q·D_r for small ρ. Checks:
- Christoffel kernels: s = 1, q = e^{−2r}.
- Subcubes: Prop 5.
- Tilts (1 + h/m)^m: deg h = r/m.

### 4.4 What a full proof would need

Either:
- **(a)** a structure theorem: every P with M_P(q) ≥ ¼ has its spiky negative level sets inner-approximated by sets from a family of entropy O(qD_r); this would give (S) and hence Lemma C with absolute constants; or
- **(b)** a chaining or moment argument that sees the local dimension.

For (b), the two-sided version reduces to the combinatorics in §4.6. The one-sided version needs, in addition, a uniform local Cover argument, which the moment method does not supply.

### 4.5 Why localized Rademacher bounds (Thm 2) cannot replace (S)

For P with mass m on a fixed E at height H, the contraction bound gives error ≍ √(H·μ(E)·D/n) ≍ √(m/K). This is not ≍ m. It is the sup over all P of the linear process on E's sample points, Σ_{i∈I_E}ε_iP(X_i), which does not shrink with m.

Localizing via the ellipsoid {⟨P, Π1_EΠ P⟩ ≤ m} gives √(n·Σ_k min(θ_k, m)) ≥ √(n·m·N_E(m)), where θ_k are the eigenvalues of Π1_EΠ. This is ≍ m only for m ≳ θ/K. Summed over J ≍ r scales this forces K ≳ J.

The layer cake of Thm 3 avoids the issue because it needs only fixed-set hitting events, P_n(E) ≥ μ(E)/2, and no uniformity over P inside E.

### 4.6 Two-sided version: a plausible moment-method route (sketch, not done)

**Reduction to flows.** Let E = G_n − I = (ε_{U△V})_{U,V∈B_r}, where ε_W is the empirical Walsh coefficient. Then

  E tr E^{2p} = Σ_π n^{−2p}(n)_{|π|}·N(π),

summed over partitions π of [2p] with no singletons. Here N(π) is the number of F₂^d-valued flows on the quotient multigraph H_π (vertices = blocks, edges = consecutive steps) with every edge value in B_r. In Fourier form, N(π) = E_y Π_s k(y_{B(s)} ⊕ y_{B(s+1)}), with k the Christoffel kernel.

**What is checked.**
- Non-crossing π give exactly the free-Poisson (Marchenko–Pastur) moments.
- The first crossing, π = {13, 24}, contributes E(B_r)/D³ = κ_C/D relative to the non-crossing terms. That is exponentially small for ρ < 1/e (table in §3.4).

**Sanity check** (`moment4.py`). At (d,r) = (16..20, 3), K = 4, 8, the observed (1/D)·tr E⁴ = 0.1409, 0.1421, 0.1436 (K = 4) and 0.0330 (K = 8). These lie between the Marchenko–Pastur value 2y² + y³ (y = 1/K) and that value plus the predicted crossing term (κ_C/D)y², within sampling noise.

**What is missing.** A uniform bound on N(π) of the form D^{1+2p−|π|}·(κ_C/D)^{c·cr(π)}·poly, valid up to p ≍ log D (the cr(π)-term is a q-Gaussian-type suppression). With it one would get ‖G_n − I‖ ≤ (2/√K + 1/K)(1 + o(1)), i.e. the two-sided version.

---

## 5. Numerics (all in `deep0/`)

**Two-sided λ_min of Φ^TΦ/n.** Source: `exp1_lmin.txt`, `exp1b.log`, `exp1c.log`. Dense eigensolver up to D ≈ 3000, Lanczos above.

| ρ | (d,r): D_r | K = 4: λ_min (MP 0.250) | K = 8: λ_min (MP 0.418) |
|---|---|---|---|
| 1/5 | (10,2): 56 · (15,3): 576 · (20,4): 6196 | 0.219 · 0.229 · 0.239 | 0.392 · 0.398 · 0.403 |
| 1/6 | (12,2): 79 · (18,3): 988 · (24,4): 12951 | 0.234 · 0.242 · 0.245 | 0.412 · 0.412 · 0.412 |
| ≈1/10 | (24,3): 2325 · (27,3): 3304 · (30,3): 4526 | 0.2474 · 0.2480 · 0.2494 | – |
| 1/3 | (9,3): 130 · (12,4): 794 · (15,5): 4944 | 0.195 · 0.190 · 0.195 | – |
| 0.4 | (10,4): 386 · (15,6): 9949 | 0.150 · 0.158 | – |
| r = 2 fixed | (32,2): 529 · (40,2): 821 · (48,2): 1177 | 0.248 · 0.253 · 0.247 | – |
| 1/2 | (10,5): 638 · (12,6): 2510 · (14,7): 9908 | 0.082 · 0.097 · 0.094 | 0.216 · 0.231 · 0.213 |

- **No downward drift with D at any fixed ρ.** For ρ ≤ 1/6 the values converge to the MP edge.
- **ρ ≥ 1/3.** The limit is below MP but stable. At ρ = ½, n/2^d = K/2, so sampling is Poisson-like and the relevant law is a free compression, not MP.
- **Upper edge.** λ_max exceeds MP slightly and grows slowly at ρ = ½. That is the max-load coupon collector on the upper side, which is irrelevant to Lemma C.

**One-sided minimum of P_n(Q_−²) over unit Q ∈ fV_r.** Source: `exp2_onesided.txt`.
- **Method.** Alternating minimization of ‖Φ_f a − s‖² over s ≥ 0 and the unit sphere. The sphere step is an exact trust-region step via the eigendecomposition of G, so the objective decreases monotonically.
- **Starts.** 16–24 per instance: random, ± bottom eigenvectors, Christoffel kernels.
- **Baseline.** The same algorithm on an iid Gaussian design with the same (D, n), and Gordon's value (√½ − √(1/K))².

| (d,r): D | K | Walsh min | Gaussian min | Gordon | Walsh/Gauss |
|---|---|---|---|---|---|
| (10,2): 56 | 4 | 0.0378 | 0.0526 | 0.0429 | 0.72 |
| (15,3): 576 | 4 | 0.0363 | 0.0445 | 0.0429 | 0.82 |
| (18,3): 988 | 4 | 0.0410 | 0.0433 | 0.0429 | 0.95 |
| (20,3): 1351 | 4 | 0.0403 | 0.0394 | 0.0429 | 1.02 |
| (24,3): 2325 | 4 | 0.0403 | 0.0417 | 0.0429 | 0.97 |
| (20,4): 6196 | 4 | 0.0397 (300 iterations, 8 starts; minimizer kurtosis 3.49) | – | 0.0429 | – |
| (24,4): 12951 | 4 | 0.0411 (300 iterations, 3 starts: 0.04105 / 0.04113 / 0.04106) | – | 0.0429 | – |
| (15,3): 576 | 6 | 0.0742 | 0.0902 | 0.0893 | 0.82 |
| (18,3): 988 | 6 | 0.0780 | 0.0884 | 0.0893 | 0.88 |
| (20,3): 1351 | 6 | 0.0874 | 0.0894 | 0.0893 | 0.98 |
| (24,3): 2325 | 6 | 0.0894 | 0.0918 | 0.0893 | 0.97 |
| (18,3): 988 | 8 | 0.1147 | 0.1294 | 0.1250 | 0.89 |

**Diagnostics** (`exp3.log`):
- One-sided minimizers have kurtosis 3.3–7.2 (3.49 for the best minimizer at D = 6196) and carry 10–19% of their mass on the top 1% of points (8.5% for a random direction).
- Bottom eigenvectors have kurtosis 3.5–9; Christoffel kernels have 13–70.
- The empirical Christoffel ratio min_x φ^TG^{−1}φ/φ^TG^{−2}φ over 2·10⁴ random x stays well above λ_min (0.23–0.49 versus 0.16–0.34).

So the extremal directions are bulk and delocalized, not sample-adapted spikes. These sizes are very far from the lemma's regime (ρ ≤ 1/64 and r ≥ d/log d force log d ≥ 64), so this is evidence about the mechanism only.

---

## 6. The CONSEQUENCE paragraph: checks

### 6.1 The skeleton (Thm 10.2 adapted)

**Choice of cutoffs.** Take the odd r with K D_r ≤ n < K D_{r+2}, and u = r + s.

**Bounds on the posterior mean m.**
- Head (coercivity): c‖m_{≤r}‖² ≤ P_n(m − m_{≤r})² ≤ ‖Q_{SS}‖ ≤ bτ_r.
- Band: ‖m_{(r,u]}‖² ≤ nλ_{r+1} ≤ K_eff·τ_r, with K_eff := n/C(D, r+2).
- Tail: nλ_{u+1} ≤ K_eff·(C(D,r+2)/C(D,u+2))·τ_u ≤ K_eff(2ρ)^s τ_u. Choosing s ≈ log(K_eff/ε)/log(1/(2ρ)) makes it ≤ ετ_u.

**Clipped parity.** It then requires

  Φ := (u/d)·(2√2/c_θ)·√((b/c + K_eff)·τ_r/τ_u) ≤ ⅛,  with 2√2/c_θ ≈ 63.

**Consequences.**
- The claim "(i) log-free coercivity + log-free tail-Gram ⟹ exp(Ω(d)) for (S)" is **correct**, given level-mass regularity τ_r/τ_{r+s} ≤ C_ρ for s = O(1). The synthesis' numerics indicate w_{q+2}/w_q ≈ 0.36–0.46, i.e. τ_r/τ_{r+2} ≈ 2–3.
- The dependence on K and b is **polynomial**: one needs ρ²(K + b)/c → 0 as ρ → 0. The condition "ρ·log(K/c) → 0" in Lemma C does not suffice; for example K = e^{1/√ρ} fails it. So the claimed "K = polylog(d) gives exp(c d logloglog d/loglog d)" does not follow from this skeleton; it gives exp(d/polylog d).

### 6.2 Reachable sample sizes from the same skeleton

All rows assume level-mass regularity.

| coercivity (K_eff) | Gram constant b | constraint | reachable n |
|---|---|---|---|
| Lemma 4.4, K_eff ≍ r log(d/r) | Tropp: b ≍ √(d·K_eff) | r ≲ d^{3/5}(log d)^{−1/5} | **exp(c d^{3/5}(log d)^{4/5})** |
| Lemma 4.4 | log-free b ≍ K_eff | r ≲ d^{2/3}(log d)^{−1/3} | exp(c d^{2/3}(log d)^{2/3}) |
| Lemma C, K = O(1) | Tropp | r ≲ d^{3/4} | exp(c d^{3/4} log d)* |
| Lemma C | log-free | ρ ≤ ρ₀ | exp(c d) |

\* This row needs the log-free coercivity at r ≍ d^{3/4}, which is below the stated range d/log d ≤ r of Lemma C. The same proof strategy applies there, and is easier, since ρ → 0.

### 6.3 Side result (first row of the table): exp(c d^{3/5}(log d)^{4/5}) for the sign-only tanh learner

This uses only existing tools. Check the requirements in turn:
- Lemma 4.4 needs r ≤ d/64.
- Lemma gram-general's far-pair term needs r ≥ (log d)².
- Its near-pair and collision terms need n ≤ e^{c₁d}.
- The variance and tail steps work with s = 2 when r ≤ d^{2/3}.
- The small-n regime is covered by ABFR at v ≍ d^{1/3}.

The kernel-specific input is **level-mass regularity** τ_r ≤ Cτ_{r+2} for r ≤ d/4. It follows from a ratio bound on the dual coefficients.

**Step 1 (walk coupling).** Let π_j := C(D,j)a_j = Σ_m c_m·P(walk distance after m steps = j). From distance j, the next two steps both increase the distance with probability ((D−j)/D)((D−j−1)/D). Hence

  π_{j+2} ≥ Σ_m c_{m+2}P(dist_{m+2} = j+2) ≥ (1 − (2j+1)/D)·Σ_m c_{m+2}P(dist_m = j).

So if c_{m+2} ≥ c₀c_m for all odd m, then π_{j+2} ≥ c₀(1 − (2j+1)/D)·π_j.

**Step 2 (from π to level masses).** For odd F,
- w_q = A·((D−q)/D)·π_q for q odd,
- w_q = A·((q+1)/D)·π_{q+1} for q even.

Hence w_{q+2} ≥ c₀(1 − O(q/D))·w_q, and τ_r = w_{r+1} + w_{r+2} + τ_{r+2} ≤ (1 + 2/c₀)·τ_{r+2}.

**Step 3 (composites).** If g_{i+2} ≥ c₀g_i for all odd i, then the same holds for every power G^k: add 2 to the first part of each composition, which is an injection. It therefore holds for every nonnegative mixture Σ_k f_k G^k. So the composite F_L∘…∘F₁ inherits c₀(F₁).

**Step 4 (first layer).** For the first-layer tanh dual, c_m = s^{2m}I_m(s)²/(m!v) > 0 for all odd m, since I_m > 0. A saddle-point estimate of I_m (saddle at w* ≈ √m/s, where 1/sinh(πw/2) ≈ 2e^{−πw/2}) gives

  c_m = C·m^{−1/2}·e^{−(π/s)√m}·(1 + o(1)).

So c_{m+2}/c_m → 1 and c₀ = inf_m c_{m+2}/c_m > 0.

**Final arithmetic.** With u = r + 2,
- K_eff ≤ C·A·r·H_r;
- b_r = C_δ(1 + √(d·r·H_r) + r·H_r) (the paper's universal Gram lemma);
- the tail is nλ_{u+1}/τ_u ≤ K_eff·O(ρ²) → 0 for r ≪ d^{2/3}.

The clipped-parity bound becomes ≲ (r/d)(d·r·log d)^{1/4} ≤ c for r ≤ c·d^{3/5}(log d)^{−1/5}, i.e. log n ≍ d^{3/5}(log d)^{4/5}.

This is a proof sketch; each step matches a lemma already in the two papers, but it deserves an independent check before being relied on.

---

## 7. Precise final statements

**Lemma C — status: OPEN** (not proved, not disproved).
- *No counterexample:* none in the explored range, and every structured spiky family I could test satisfies (S).
- *Numerics:* consistent even with the strong form (absolute K and c, with the threshold near the Gaussian/Cover value).


**Proved:**
- Theorems 1, 2, 3, 3′ and Propositions 4, 4′, 5, 6 above, including the unconditional Lemma C with K = e^{2r+O(√r)}.
- Lemma C holds log-free on the directions with M_P(32 log(2eK)/K) ≤ ¼.

**Conditional:** Lemma C(K, c) with absolute constants ⟸ (S_K). The two-sided analogue ⟸ (S2).

**Open:** (S) for general spiky P, hence Lemma C itself. No counterexample exists in the explored range, and all structured spiky families satisfy (S).

**Files** (all in `/tmp/claude-0/-home-user-AI-works/5853d160-1439-5d10-be76-59b58f86c983/scratchpad/expd/deep0/`):

| file | contents |
|---|---|
| `walsh.py`, `fwht.c` | Walsh/FWHT utilities |
| `onesided.py` | exact trust-region alternating minimizer |
| `exp1*_lmin.py`, `exp1_lmin.txt` | two-sided λ_min runs |
| `exp2*_onesided.py`, `exp2_onesided.txt` | one-sided minimum runs |
| `exp3_diag.py` | diagnostics |
| `christoffel.py`, `christoffel.txt` | exact Christoffel statistics |
| `check_subcube.py` | check of Prop 5 |
