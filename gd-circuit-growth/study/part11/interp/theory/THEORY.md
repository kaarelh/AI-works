# Exact statements about DFG v1.3 run alone

Part 11, Q7 (theory support). The object is **DFG v1.3 run alone** (`dfg13-perm`): the frozen file
`part10/hyb_portfolio3/dfg13.py` (md5 `69cabe5c50345cb24079198ed52b562f`) run as `DFG(readout="logit").fit` inside
`discrete_learner/harness.Permuted` (`part11/eval_dfg.py`), with the constructor's defaults: K = 4, K_later = 3,
c = 1, δ = 0.1, cv_n = 512, sum_nmin = 32, sum_force = True. Written 3 November 2026.

Labels: **Proved** (a proof is given; "by the code" means a direct reading of the cited lines of `dfg13.py`),
**Numerical** (measured; every number is in [`check_theory.json`](check_theory.json), key given in parentheses),
**Heuristic** (a reading or an extrapolation, not a measurement). Files:
[`check_theory.py`](check_theory.py) computes every number and writes `check_theory.json`;
[`theory_fits.py`](theory_fits.py) makes the DFG fits it needs (cached in `cache/`).

## Short answer

1. **P1. Under the null, round 0's tests rarely admit anything** (Proved for the character tests and the linear block).
   Let the labels be independent of uniform inputs, with any law of the labels. In round 0 of any fit call:
   - the global test admits a character of degree k with probability at most 2C(d,k)·(δ/(4K·C(d,k)))^{c²}. With c = 1
     that is δ/(2K) = 0.0125 per degree, for any d and n;
   - the linear block's test passes with probability at most δ;
   - if round 0 admits nothing, the default variant's model is the constant plus the kernel background.

   The proof does not cover the spectral block, the sum blocks, the forced variant, or the cross-validation's choice
   between variants. Numerically the character tests are about 10 times inside their bound (≈ 10⁻³ per degree). The
   spectral test is not safe: with skewed labels (P(+1) = 0.85) at n = 128, 7 of 30 full DFG fits end with spurious
   spectral or sum-block features.
2. **P2. A k-parity is admitted exactly when n(1 − ȳ²) > n_thr(k, d)** (Proved; checked on every parity cell). Here
   n_thr(k, d) = 2 ln(4K·C(d, k)/δ) ≈ 2k ln d, which is 19.5–42.0 for k = 2–4 and d = 15–120.
   - With each seed's own ȳ, this criterion predicts all 250 parity cells at n ≥ 32.
   - Together with the cross-validation's choice of the forced variant at n = 16, it reproduces all 11 measured n*
     (16–56) to within 0.2.
   - par4 at d = 30 has n* = 52 rather than 28 because 2 of its 3 seeds have |Σy| > 6 at n = 32, an event of
     probability 0.12.
   - n_thr is a floor for every target: no degree-k character passes a global test on m ≤ n_thr(k, d) rows (P2′).
   - The networks' n* grows as d^1.0, d^1.9 and d^2.4 over d = 15–60: close to d^(k−1) for k = 2, 3, and below d³
     for k = 4.
   - At d = 1000 (Heuristic) the test would need only n ≈ 56, but DFG v1.3's budget skips its degree-3 and degree-4
     searches there; an exhaustive degree-4 search would cost 56 network runs.
3. **P3. n_glob predicts the round-0 test, and later rounds make characters cheaper** (exact criterion Proved; first
   order Heuristic; checked on 41 targets, seed 0).
   - The round-0 test admits S iff n > 2c²L·s²/v_S², with the sample's v_S and s; n_glob puts ŷ_S and 1 − ŷ₀² in their
     place.
   - Over 8681 (character, n) pairs, n > n_glob agrees with DFG's decision 96.9% of the time, and a normal approximation
     gives the pass rate to within 0.051 in every band of n/n_glob.
   - Characters that enter through this test do so at a median 2^0.26 × n_glob.
   - 266 of the 427 characters predicted within the grid enter earlier, mostly through later-round classes. Characters
     entering through those classes do so a median 1.4–3.7 doublings below n_glob, mainly because the residual variance
     there is 3–19 times smaller; the smaller union bound adds a factor of at most 1.7.
4. **P4. Sum blocks** (Proved).
   - With one group per value, a block represents every function of a signed sum of k inputs with at most k + 1
     parameters, where the Fourier expansion can need 2^k characters.
   - DFG's grouping (groups of at least max(3, 0.005n) points) gives every value its own group in the large-n limit
     iff k ≤ 7. On the mod-3 targets it costs 0.1–0.2% error.
   - A residue class mod 3 has W_j ≤ (16/9)·C(k, j)·3^j·4^(−k). Exactly, W₁ + W₂ is 1.6·10⁻⁶ (f7_05), 5.4·10⁻⁶ (h6_00)
     and 2.1·10⁻⁴ (fd_10). This agrees with Part 10's "W₁ = 0, W₂ ≤ 0.0002" to four decimals, although fd_10's
     W₁ + W₂ is 5% above 0.0002.
   - The search's seeds would need n ≈ 10⁵–10⁷ to see these targets (Heuristic).
5. **P5. Compute** (Proved from the code; checked exactly).
   - The exhaustive degree-3 and degree-4 searches cost ≈ 12n·C(d, 3) and 24n·C(d, 4) FLOPs.
   - Each budgeted search costs at most its share of one network run: 15% for degree 4; 3% for degree 3 per round; 3%
     each for degrees 5 and 6.
   - Degree 4 is subsampled from d = 36 at n = 16384 (from d = 75 at n = 512–1024) and skipped from d = 199.
   - An analytic FLOP model of the "parity path" reproduces the recorded FLOP counts exactly in 232 of the 275 parity
     cells; 4 of these needed a false linear block, confirmed by refits. The other 43 are at n ≤ 32: exactly the cells
     where some fold fit or the final fit does not admit χ_S by its test.

## 0. What the code does (the parts used below)

A **fit call** is one `DFG._fit` on n rows. `DFG.fit` makes one call at n > 512 (the default variant, `scale` = 1,
`hi` = True). At n ≤ 512 it makes 2F + 1 calls (F = 10 folds for n ≤ 64, else 5): each variant on each fold's
training rows (n − ⌈(n − f)/F⌉ rows for fold f; `scale` = 1/(4F), `hi` = False, so no degree-5/6 search), then the
chosen variant on all n rows (`scale` = 0.5, `hi` = True) (lines 553–570). Below, GD = `gd_flops(d)` × `scale`.

- **Round-0 residual** (589–595). The first least-squares fit is on the constant alone. Its normal equation is
  (n + 10⁻⁹) w₀ = Σy, since the ridge leaves the constant unpenalised, so r = y − w₀ with w₀ = Σy/(n + 10⁻⁹).
  Then s = √max(mean r², 10⁻¹²). For ±1 labels, mean r² = 1 − 2w₀ȳ + w₀².
- **The test** (602–613). S becomes a candidate iff |v_S| > thr, where v_S = mean(r χ_S) over the class's rows and
  thr(N) = c·s·√(2 ln(4KN/δ)/n). K is `self.K` = 4 in every round; K_later = 3 only caps the global degree in rounds
  ≥ 1 (616). On the first m rows the code uses thr_m(N, m) = c·rms(r[:m])·√(2 ln(4KN/δ)/m) and the mean over those
  rows. z_S = |v_S| / thr.
- **Candidate classes**:

  | class | candidates | N | rows | runs when |
  |---|---|---|---|---|
  | global, k = 1 | every χ_i | d | n | always |
  | global, k = 2 | every pair | C(d, 2) | n | always |
  | global, k = 3 | every triple | C(d, 3) | m₃ = min(n, ⌊0.03 GD / (d(2d² + 2d))⌋) | m₃ ≥ 32 (every round) |
  | global, k = 4 | every 4-set | C(d, 4) | m₄ = min(n, ⌊0.15 GD / (C(d,2)(2d² + 3d))⌋) | m₄ ≥ 32, round 0 only |
  | global, k = 5, 6 | T₁ ∪ T₂, disjoint, \|T₁\| = ⌈k/2⌉ | C(d, k) | m_k = min(n, ⌊0.03 GD / (2N₁N₂ + N₁k₁ + N₂k₂)⌋) | m_k ≥ 64, round 0, `hi` only |
  | ext1 | T ∪ {j}, T a current character (32 largest \|w\|) | #bases · d | n | some character is a feature |
  | ext2 | T ∪ {j, l} | #bases · C(d, 2) | min(n, ⌊0.03 GD / (#bases (2d² + 3d))⌋) | that m ≥ 32 |
  | local | S ⊆ V, V = inputs of the current characters, 2 ≤ \|V\| ≤ 12 | C(\|V\|, \|S\|) | n | — |

- **Admission** (816–827): the 64 candidates with the largest z, within the room min(256, ⌊n/2⌋) − p.
- **Linear block** (696–700): lin = the inputs whose χ_i is neither a feature nor a candidate. With c₁ = Xᵀr/n and
  T₁ = n Σ_{i∈lin} c₁ᵢ²/s², the block is admitted iff T₁ > k + 2√(k ln(1/δ)) + 2 ln(1/δ) (k = |lin|) and
  n ≥ 2(p + k). In round 0 that needs n ≥ 2(1 + d).
- **Spectral block** (701–709): eigenvalues λ of the symmetrised residual pair matrix (zero diagonal; pairs that are
  features or candidates zeroed) with |λ| > 2s√(d/n)(1 + √(2 ln(1/δ)/d)); at most 4, and only if n ≥ 4d.
- **Sum blocks** (715–815; n ≥ 32): statistic T = |Π r|²/s², Π the projection on the block's group indicators.
  Accepted iff T > m + 2√(mt) + 2t, with m = occupied groups − 1 and t = ln(4K·C(d,k)·2^(k−1)·2·(1 + #modulators)·24/δ)
  (plus ln(2(4d + 20 C(d,2))) for weighted blocks), and only if it also passes on r projected off this round's
  accepted characters. Groups: contiguous runs of values of t(x) = Σ_{i∈S} sᵢxᵢ, each with ≥ max(3, ⌊0.005 n⌋) training
  points (`_edges`, 86–97).
- **Stop**: a round that admits no character and no block ends the fit (824). A round does not start if s < 10⁻⁶,
  or, from round 1 on, if every training sign is already right (596), or if the FLOP count exceeds 0.75 GD (598).
- **Forced variant** (817–822). When nothing passes in a round, at most twice per fit, the forced variant adds a guess.
  If n ≥ 48 and the best sum-block candidate's T/threshold exceeds the square of the best character's z, the guess is
  that block. This needs `sum_force` = True, which is the constructor default although the docstring (line 73) says
  "off by default". Otherwise the guess is the offered character with the largest z. Since nothing passed, the offered
  characters are every degree-1 character, the largest degree-2 entry, the largest entry of each degree-3 and degree-4
  row block, and (from round 1 on) the local subsets whose |coefficient| exceeds the smallest local threshold.
  Degrees 5–6 and the extension classes offer only characters that pass.
- **Cross-validation** (566–567): forced is chosen iff b − c > 2√(b + c). Here b counts the held-out points where the
  default is wrong and forced is right, and c the reverse.
- **Readout**: logistic refinement of the least-squares weights if n ≥ 8p (849); kernel background bg = Xᵀr/n (856).

## 1. P1: no false admission under the null

**Setting.** Rows x₁, …, x_n iid uniform on {−1, 1}^d. Labels y ∈ {−1, 1}^n with any joint law, independent of the
rows: iid with any bias, a fixed vector, anything. The harness's column permutation keeps the rows uniform. N_k = C(d, k)
and L_k = ln(4K N_k/δ).

**P1a (Proved).** Take round 0 of any fit call (final or fold fit, default or forced variant, any `scale`) and any degree
k that the call searches. Then for every u > 0,

  P(max_{|S| = k} z_S ≥ u) ≤ 2 N_k (δ / (4K N_k))^{u²c²}.

At u = 1 this is the test. With c = 1 the bound is δ/(2K) = 0.0125 per degree, for any d and n. Over the degrees a final
fit searches it is at most δ/2 = 0.05 for degrees 1–4, and at most 3δ/4 = 0.075 with the degree-5/6 search.

*Proof.* Condition on y. Then w₀, r, s and rms(r[:m]) are fixed, since they are functions of y alone. Fix a nonempty S.
The values ε_t = χ_S(x_t) are iid uniform signs: a product of independent uniform signs is a uniform sign. They are
independent of y. The statistic on the class's m rows is (1/m) Σ_{t≤m} r_t ε_t (m = n, or the first m rows of a
subsample). Its threshold is c σ √(2L_k/m), where σ = s if m = n and σ = rms(r[:m]) if m < n. In both cases
σ² ≥ (1/m) Σ_{t≤m} r_t², because s² = max(mean r², 10⁻¹²) ≥ mean r².

Hoeffding's inequality for Rademacher sums gives P(|Σ a_t ε_t| ≥ λ) ≤ 2 exp(−λ²/(2 Σ a_t²)). Take a_t = r_t and
λ = u c σ √(2 m L_k). The exponent is λ²/(2 Σ_{t≤m} r_t²) ≥ u²c² L_k. So P(z_S ≥ u | y) ≤ 2 e^{−u²c²L_k} =
2(δ/(4KN_k))^{u²c²}. (If r[:m] = 0, the statistic and the threshold are both 0, and the strict test |0| > 0 fails.)
A union bound over the N_k sets of size k, then over the degrees, and the expectation over y finish the proof.

The degree-5/6 search computes G[p, q] = mean_m(r χ_{T₁} χ_{T₂}) and offers it only when T₁ ∩ T₂ = ∅ (line 662). That is
the same statistic mean_m(r χ_S) for S = T₁ ∪ T₂. A set found by several splits defines one event, so the search is
covered. The decisions are taken in floating point; the statement is for exact arithmetic, and rounding can change a
decision only when |v_S| is within rounding error of its threshold. □

**P1b (Proved).** In round 0, P(T₁ over all d inputs exceeds d + 2√(dx) + 2x) ≤ e^{−x} for every x > 0. At
x = ln(1/δ) this is the code's threshold, so P(the linear block's test passes with lin = all inputs) ≤ δ. In round 0,
lin is smaller than all d inputs only if a degree-1 character passed. Hence P(a false linear block in round 0) ≤
δ + δ/(2K).

*Proof.* Condition on y and let a = r/‖r‖. Since n s² ≥ ‖r‖², T₁ = Σᵢ (Σ_t r_t x_{ti})²/(n s²) ≤ Σᵢ Zᵢ² with
Zᵢ = Σ_t a_t x_{ti}. The Zᵢ depend on disjoint columns of X, so they are independent. Each is a Rademacher sum with
Σ a_t² = 1.

For 0 ≤ λ < ½, let g ~ N(0, 1) be independent; then exp(λz²) = E_g exp(√(2λ) g z). By Fubini and cosh x ≤ exp(x²/2),
E exp(λZᵢ²) = E_g Π_t cosh(√(2λ) g a_t) ≤ E_g exp(λg²) = (1 − 2λ)^{−1/2}. So the moment generating function of ΣZᵢ² is
dominated by that of χ²_d, and log E exp(λ(ΣZᵢ² − d)) ≤ −λd − (d/2) ln(1 − 2λ) ≤ dλ²/(1 − 2λ).

Laurent & Massart's Lemma 1 (Ann. Statist. 2000) derives P(Y − d ≥ 2√(dx) + 2x) ≤ e^{−x} from exactly this bound, by a
Chernoff argument. □

**P1c (Proved, by the code).** If round 0 admits nothing (no character and no block), the default variant stops there
(line 824). Its model is then the constant plus the kernel background bg = Xᵀr/n. In round 0 the extension and local
classes are empty, because there are no current characters. There are also no modulated blocks and no products of
accepted blocks. Hence P(the default variant's model has a feature besides the constant) ≤ 3δ/4 (P1a, degrees 1–6)
+ δ (P1b; its δ/(2K) term is the degree-1 part of P1a) + P(a spectral block in round 0) + P(a sum block in round 0).

**What the proof covers, and what it does not.**

| part of a fit | covered? | why |
|---|---|---|
| round 0: global characters, degrees 1–4, on all rows or a subsample | **yes** (P1a) | conditional on y, each χ_S is an iid fair sign sequence |
| round 0: the degree-5/6 subsample search (final fit only) | **yes** (P1a) | the same statistic; adds 2 × δ/(2K) |
| round 0: linear block | **yes** (P1b) | dominated by χ²_d in moment generating function |
| round 0: extension, local, modulated blocks, products of accepted blocks | empty | no current characters or blocks yet |
| round 0: spectral block | **no** | its edge 2s√(d/n)(1 + √(2 ln(1/δ)/d)) is the asymptotic Wigner edge with a Gaussian correction, not a bound |
| round 0: sum blocks (additive, product, split) | **no** | the χ² threshold is Gaussian-calibrated. Given y, the group sums Σ_{t∈v} r_t are sums over an x-dependent partition, and the groups' edges are chosen from the data. The union bound over every (S, s, fold, modulator, size) is a valid count, but only if each fixed candidate's tail is at most e^{−t}, which is not proved. |
| forced variant | **no**, by design | when nothing passes it adds one or two features |
| the cross-validation's choice of variant (n ≤ 512) | **no** | b − c > 2√(b + c) is a one-sided z-test at 2; the held-out errors of different folds are dependent (each point's label trains the other folds), so no level is proved |
| rounds ≥ 1, every class | not needed; not covered | they run only after an admission (P1c). Then r depends on X through the admitted features, and the candidate sets depend on round 0. |

So P(the final model is not the constant plus the background) ≤ 3δ/4 + δ = 0.175, plus P(spectral) + P(sum) +
P(n ≤ 512 and the forced variant is chosen). The first two terms are proved; the rest are measured below.

**Numerical checks.**

*The proved part* (`P1.sims`, `P1.totals`). I replicated round 0's global tests, the linear statistic and the spectral
statistic exactly as the code computes them; the replica is checked against DFG below. The design has 16 configurations
× 300 null data sets = 4800:
- d = 30, n ∈ {32, 128, 512, 2048}, three label laws: iid fair; iid with P(+1) = 0.85; and one fixed vector (the first
  third +1);
- d = 15, n ∈ {64, 256, 1024}, degrees 1–6, all on all rows;
- d = 60, a 5-fold fit of the cross-validation at n = 512: 410 rows, `scale` = 1/20, degree 4 on its first m₄ = 110
  rows, the subsampled case.

Results:
- **Characters: 280 of 280 checks hold.** Each check is one configuration, degree and level u ∈ {0.7, 0.8, 0.9, 1}; in
  every one the observed frequency of max z ≥ u is at most the bound.
  - At u = 1 no degree-configuration exceeds 2 of 300.
  - 16 of the 4800 data sets have some degree with z > 1.
  - At d = 30 the u = 1 hits by degree are 5, 1, 4, 2 (degrees 1–4, over 3600 data sets).
- **The bound is loose by the Gaussian Mills ratio, not by the union** (Heuristic). The Gaussian approximation
  N·2Φ̄(√(2L)) gives 1.15, 1.01, 0.93 and 0.87·10⁻³ for degrees 1–4 at d = 30, against the bound's 12.5·10⁻³. That is a
  factor of 10.9–14.3, close to the Mills-ratio factor √(2π)·√(2L) = 10.3–13.9 (`P1.bound_over_gauss_d30`), so the
  union over the N nearly independent statistics is nearly tight. Where counts are large it matches. At u = 0.8,
  d = 30, n = 2048 with fair labels, the observed rates for degrees 1–4 are 0.037, 0.063, 0.15, 0.22. The Gaussian
  approximation gives 0.030, 0.069, 0.14, 0.26, and the bound 0.26, 0.69, 1, 1 (`P1.totals.u08_d30_n2048_fair`).
- **Linear block: 64 of 64 checks within e^{−x}.** At x = ln(1/δ) (the code's threshold), 43 of the 4800 data sets
  pass (0.9%). The bound is δ = 10%; the χ²_d level of the Laurent–Massart threshold is 0.79–1.17% for d = 15–120
  (0.92% at d = 30).
- **Spectral block (not covered): it can fail badly.** Where it applies (n ≥ 4d) its statistic exceeds the edge in 0 of
  300 at every n with fair or fixed labels, at d = 15, 30 and 60. With P(+1) = 0.85 at d = 30 it exceeds the edge in
  46 of 300 at n = 128 (15%) and 1 of 300 at n = 512. The edge is the semicircle edge for many comparable weights r_t
  (Heuristic reading). With P(+1) = 0.85, about 0.15n rows carry r ≈ −1.7 against +0.3 for the rest. Those rows add a
  Wishart-like matrix of rank about 0.15n < d at n ≈ 4d, whose top eigenvalue is near (√(0.15n) + √d)² − 0.15n times
  1.7/n: 1.04 at n = 128, against the edge's 0.96 (`P1.quad_skew_heuristic`).

*Full DFG fits on null labels* (`P1.full_fits`, `P1.full_fits_replica`). These are DFG alone with its own
cross-validation, d = 30.
- **Fair labels, 20 fits at each of n = 64, 256, 1024, 4096: 78 of 80 final models are the constant plus the
  background.**
  - One (n = 1024) holds a pair admitted by the round-0 test, z = 1.06. It is the event P1a bounds.
  - One (n = 256) is a forced-variant model that the cross-validation chose, with held-out errors 122 (default)
    against 103 (forced). It holds its two forced characters, of degree 4 (round 0) and degree 3 (round 1). A refit
    and replay show that neither passed a test: z = 0.94 and 0.76 in the only class containing each, the global one
    (`P1.forced_fits_replay`).
  - No linear block, spectral feature or sum block was admitted.
- **Skewed labels (P(+1) = 0.85), 30 fits at n = 128: 7 of 30 final models hold spurious features**, all in the
  default variant (`P1.nonconstant_fits`). Six hold spectral features first admitted in round 0, the uncovered test of
  the previous paragraph. One holds a folded sum block on 7 inputs admitted in round 0, then a spectral feature and a
  second block (on 9 inputs) in round 1, and another spectral feature in round 2.
- **The replica agrees with DFG's own round-0 decisions** (characters by degree, the linear block, the spectral block)
  in 110 of the 110 fits: the 80 fair-label fits and the 30 skewed-label fits.
- Over the fits with a cross-validation (n ≤ 512: 40 fair, 30 skewed), the forced variant was chosen once.

## 2. P2: the sample size at which a k-parity is admitted

**P2 (Proved).** Let f = χ_S with |S| = k, labels noiseless. Take round 0 of a fit call on n rows. Then exactly

  mean(r χ_S) = 1 − w₀ȳ,  mean(r²) = 1 − 2w₀ȳ + w₀²,  w₀ = Σy/(n + 10⁻⁹),

because yχ_S = χ_S² = 1 and y² = 1. Dropping the 10⁻⁹, w₀ = ȳ and mean(r χ_S) = 1 − ȳ² = s². When the degree-k search
runs on all n rows (k ≤ 2 always; k = 3, 4 when m_k = n ≥ 32), χ_S passes iff

  **n (1 − ȳ²) > n_thr(k, d) := 2c² ln(4K C(d, k)/δ).**

(The test reads 1 − ȳ² > c√(1 − ȳ²)·√(2L/n); divide by √(1 − ȳ²) > 0 and square.) On a subsample of the first m < n
rows the test passes iff m (1 − w₀ȳ_m)² > n_thr (1 − 2w₀ȳ_m + w₀²).

Since 1 − ȳ² ≤ 1, n > n_thr is necessary. The χ_S(x_t) are iid fair signs, so Σy = 2B − n with B ~ Bin(n, ½), and
exactly P(pass) = P(|2B − n| < √(n(n − n_thr))). E[n(1 − ȳ²)] = n − 1, so to first order the test passes once
n > n_thr + 1. Because ln C(d, k) = k ln d − ln k! + O(k²/d), n_thr = 2c²(k ln d − ln k! + ln(4K/δ)) + O(k²/d): it
grows like 2k ln d.

**P2′ (Proved): the same floor holds for every target.** For any labels, in any round, a class with N candidates tested
on m rows can admit a character only if m > 2c² ln(4KN/δ). For the global degree-k class that is m > n_thr(k, d). The
reason is Cauchy–Schwarz: |mean_m(r χ_S)| ≤ rms(r[:m]) ≤ σ, so |v_S| > cσ√(2L/m) needs c√(2L/m) < 1. A k-parity with
ȳ = 0 attains the bound, so n_thr is exactly the parity's sample size.

**n_thr(k, d)** (c = 1, K = 4, δ = 0.1; `P2.n_thr`):

| k | d = 15 | 30 | 60 | 120 | 1000 |
|---|---|---|---|---|---|
| 2 | 19.46 | 22.30 | 25.11 | 27.90 | 36.39 |
| 3 | 22.39 | 26.77 | 31.03 | 35.24 | 48.01 |
| 4 | 24.59 | 30.59 | 36.34 | 41.99 | 59.04 |

From d = 15 to 120, n_thr rises by 8.4, 12.9 and 17.4, close to 2k ln 8 = 8.3, 12.5, 16.6 (`P2.n_thr_rise_15_to_120`).

**Check against every parity cell** (Numerical; `P2.agree`, `P2.cells`). These are par2, par3 and par4 in the result
files at d = 15, 30, 60, 120, with each seed's own training set and its own ȳ.
- **n ≥ 32: 250 of 250 cells agree.** The final model's test error is exactly 0 iff the criterion holds in the final
  fit, and 0.488–0.506 otherwise (6 cells; `P2.fail_err_n_ge32`).
- The 10⁻⁹ term never changes a decision: 263 of 263 cells.
- **n = 16:** the criterion fails in all 25 cells. n_thr > 16 at every d, and degrees 3–4 are not searched below
  m = 32. Seven cells still have error 0: par2 at d = 15, 30, 60, every seed. In all 7 the cross-validation chose the
  forced variant and the forced final model holds χ_S. At n = 16 the fold fits have 14–15 rows, so nothing passes (no
  fold fit passes in any of the 25 cells; `P2.cells[*].folds_pass`) and the forced variant guesses the best-z
  character. That guess is χ_S in 9–10 of the 10 forced fold fits at d ≤ 60, and the paired test picks forced
  (held-out errors default/forced 15/2, 7/0, 7/0, 7/0, 9/0, 10/0, 10/0). At d = 120, with
  C(120, 2) = 7140 pairs against 14 rows, the guess is χ_S in only 6 and 7 of 10 fold fits. The default is kept
  (7/5 and 3/3), and the error is 0.49 and 0.50.

**Predicted and measured n*** (`P2.pred`, `P2.networks`). n* is the harness's log-interpolated 10% point of the seed-mean
error on the grid 16, 32, 64, …. The "per-seed" prediction sets each seed's error to 0 where the criterion holds and to
0.5 elsewhere; the "+ forced" column adds the variant DFG's cross-validation chose at n = 16; the "expected" column uses
the exact pass probability P(pass) in place of the seeds.

| target | d | n_thr | first grid n > n_thr | per-seed | + forced | expected | measured | networks |
|---|---|---|---|---|---|---|---|---|
| par2 | 15 | 19.46 | 32 | 27.9 | 16.0 | 27.9 | 16.0 | 100 |
| par3 | 15 | 22.39 | 32 | 27.9 | 27.9 | 27.9 | 27.9 | 241 |
| par4 | 15 | 24.59 | 32 | 27.9 | 27.9 | 28.0 | 27.8 | 508 |
| par2 | 30 | 22.30 | 32 | 27.9 | 16.0 | 27.9 | 16.0 | 200 |
| par3 | 30 | 26.77 | 32 | 27.9 | 27.9 | 28.2 | 27.9 | 843 |
| par4 | 30 | 30.59 | 32 | 52.0 | 52.0 | 33.6 | 51.9 | 2728 |
| par2 | 60 | 25.11 | 32 | 27.9 | 16.0 | 28.0 | 16.0 | 427 |
| par3 | 60 | 31.03 | 32 | 27.9 | 27.9 | 44.3 | 27.8 | 3410 |
| par4 | 60 | 36.34 | 64 | 55.7 | 55.7 | 55.7 | 55.8 | 14255 |
| par2 | 120 | 27.90 | 32 | 27.9 | 27.9 | 28.7 | 27.8 | 842 |
| par3 | 120 | 35.24 | 64 | 55.7 | 55.7 | 55.7 | 55.8 | 14029 |

The per-seed criterion, together with the variant chosen at n = 16, reproduces all 11 measured n* to within 0.2. The
residual differences come from the failing seeds' errors, which are near 0.5 but not exactly 0.5.

**Borderline cases.**
- **par4, d = 30, n = 32** (n_thr = 30.59, just below the grid point). The test passes iff 32(1 − ȳ²) > 30.59, i.e.
  |Σy| ≤ 6. Seeds 0, 1, 2 have Σy = −10, −6, +12, so only seed 1 passes (errors 0.488, 0, 0.500).
  - The cross-validation cannot rescue the other two. The 10 fold fits have 28–29 rows, below 32, so no fold searches
    degree 3 or 4, and no fold fit of either variant holds χ_S (`P2.cells[*].any_fold_with_S`). The held-out errors are
    17/18, 12/15, 16/16, and the default is kept.
  - Exactly, P(pass at n = 32) = 0.785. So P(at least 2 of 3 seeds fail) = 0.12: the measured n* = 52 is an unlucky
    draw from the exact distribution, whose expected-error n* is 33.6.
- **par3, d = 60, n = 32** (n_thr = 31.03). The test passes iff |Σy| ≤ 4, P = 0.62. Both seeds pass (Σy = 0, −4), so the
  measured n* is 27.8 where the expectation gives 44.3.
- **par3 at d = 120 and par4 at d = 60** fail at n = 32 for every ȳ (n_thr > 32) and pass at 64.
- **The permutation** does not affect the test: v_S and s do not depend on the order of the columns. In these cells it
  can matter only through tie-breaking, for example among the forced variant's guesses at n = 16.
- **The folds** were rebuilt from the harness rng (the column permutation first, then `rng.permutation(n) % F`). The
  rebuilt fold sizes equal the recorded fold fits' in all 50 cached cells. In all 50, P2's criterion on each fold's own
  labels predicts exactly how many default-variant fold fits hold χ_S (`P2.fold_criterion_vs_default_folds`).

**Against the networks** (Numerical for d ≤ 120; Heuristic beyond).
- **DFG.** Its measured n* is one of a few values set by which grid interval holds n_thr ≈ 2k ln d:
  - 16·2^0.8 ≈ 28 or 32·2^0.8 ≈ 56, when every seed fails at one grid point and passes at the next;
  - 16, when the forced variant succeeds at n = 16;
  - 52, for par4 at d = 30, where one of three seeds passes at n = 32.
- **Networks.** Their n* grows as d^1.04, d^1.91 and d^2.40 for k = 2, 3, 4. These are least-squares slopes of log n*
  on log d over d = 15–60 (`DSCALE.md`, `dscale.json`). For k = 2 and 3 that is close to d^(k−1); for k = 4 it stays
  below d³ on this range. The d = 120 networks (par2 842, par3 14029) are close to the d = 60 values extrapolated with
  these slopes (879, 12834).
- **d = 1000** (Heuristic). The test-limited DFG prediction is n* = 55.7, 55.7, 56.8 (P(pass at n = 64) = 1.000,
  0.9999, 0.967). The networks' power laws give 8.0·10³, 7.4·10⁵, 1.2·10⁷.
- **But DFG v1.3's budget does not run that test at d = 1000.** There m₃ = 17 (8 under the cross-validation's half
  budget) and m₄ = 0, both below 32, so the degree-3 and degree-4 searches are skipped. As coded, DFG v1.3 would not find
  par3 or par4 by its test at d = 1000. An exhaustive search on n = 64 rows would cost 0.11 network runs (degree 3) and
  55.9 (degree 4).
- More generally, at n > 512 the budgeted search admits no degree-3 character from d = 630 on, and no degree-4
  character from d = 179 on; under the half budget, from 469 and 148 (`P5.d_parity_unreachable`). There m_k < 32 or
  m_k ≤ n_thr(k, d), so P2′ excludes every target, not only parities.
- So DFG's logarithmic sample size is bought with search compute that grows like d^k (P5), while the networks' sample
  size grows polynomially at a cost per run linear in d.

## 3. P3: general characters at round 0, and n_glob

**P3a (Proved).** Take round 0 of a fit call and a set S with |S| = k searched on all n rows (at d = 30: k ≤ 4 at every
grid n). Write ĉ_S = mean(yχ_S) and m_S = mean(χ_S). Then v_S = ĉ_S − w₀m_S and s² = 1 − 2w₀ȳ + w₀², and

  z_S > 1  ⟺  n > 2c² L_k s² / v_S².

For iid uniform rows and nonempty S, exactly E[v_S] = ŷ_S (1 − 1/(n + 10⁻⁹)). The reason: E[y_t χ_S(x_u)] = ŷ_S if
u = t and ŷ₀ · 0 = 0 if u ≠ t, so E[w₀m_S] = ŷ_S/(n + 10⁻⁹). Likewise E[ȳ²] = ŷ₀² + (1 − ŷ₀²)/n.

**P3b (first order; Heuristic as a prediction).** Replace v_S by ŷ_S and s² by 1 − ŷ₀². The round-0 test then admits S
once n exceeds

  **n_glob(S) = 2c² ln(4K C(d, |S|)/δ) (1 − ŷ₀²) / ŷ_S²**,

the quantity ORDER.md uses. Degree enters only through the logarithm and size through 1/ŷ_S². For |S| = 5, 6 the test
runs on m = min(n, m_k) rows, so the condition is m > n_glob. At d = 30, m₅ = 1374 and m₆ = 147 at `scale` 1 (687 and
73 at 0.5), so a degree-6 character is reachable only if n_glob < 147, i.e. |ŷ_S| > 0.50 when ŷ₀ = 0
(`P3.deg56_reach`).

**P3c (Proved: the later-round classes).** In round j the same algebra gives z > 1 ⟺ n > n_cls :=
2c² ln(4K N_cls/δ) s_j²/v_{S,j}², with the class's own N and the round's residual. So

  n_glob / n_cls = [L_glob / L_cls] × [(1 − ŷ₀²) / s_j²] × [v_{S,j}² / ŷ_S²],

the product of three factors: a smaller union bound (for example C(30, 4) = 27405 globally against C(|V|, 4) ≤ 495 in
the local class, or 30 per base in ext1), a smaller residual, and the residual's coefficient on S, which stays near ŷ_S
while S is orthogonal to the fitted features.

**Data** (Numerical). The 41 targets of the `designed` (21) and `random` (20) suites, seed 0, every grid n
(451 fits), and the 1697 non-constant characters of the targets' exact Fourier supports (`P3.targets`, `P3.chars`).
- 330 fits are new (`theory_fits.py`). Every one reproduces the evaluation file's test error and FLOP count exactly, and
  its replayed residual matches DFG's own round log (`P3.identity`: 330, 330 and 330 of 330).
- 121 are the order analysis' seed-0 cells.
- In each fit, every target character's z-score is replayed in every class at the start of every round, with DFG's own
  N, subsample and residual (`order_fit.replay_round`).

**The round-0 decision against n > n_glob** (`P3.test0`), over the 8681 (character, n) pairs with |S| ≤ 4 where the
degree is searched:
- **They agree in 8409 (96.9%).**
- Of the 104 pairs with n > n_glob that fail, 100 lie within one doubling above n_glob.
- Of the 168 pairs with n ≤ n_glob that pass, 139 lie within one doubling below.

The disagreements are the sampling fluctuation of v_S. A normal approximation (Heuristic) treats v_S as
N(ŷ_S, (1 − ŷ_S²)/n) against the threshold √((1 − ŷ₀²)·2L/n), and uses P2's exact probability for |ŷ_S| = 1. It predicts
the observed pass rates to within 0.051 in every band (`P3.test0.calibration`):

| log2(n / n_glob) | ≤ −2 | (−2, −1.5] | (−1.5, −1] | (−1, −0.5] | (−0.5, 0] | (0, 0.5] | (0.5, 1] | (1, 1.5] | (1.5, 2] | > 2 |
|---|---|---|---|---|---|---|---|---|---|---|
| pairs | 5381 | 306 | 323 | 313 | 276 | 236 | 187 | 231 | 185 | 1243 |
| observed pass rate | 0.0006 | 0.020 | 0.062 | 0.115 | 0.373 | 0.623 | 0.941 | 0.983 | 1.000 | 1.000 |
| normal approximation | 0.0005 | 0.014 | 0.049 | 0.118 | 0.349 | 0.658 | 0.890 | 0.992 | 1.000 | 1.000 |

So the pass rate rises from about 6% one doubling below n_glob to 94% one doubling above, with n_glob near the midpoint,
as the normal approximation says.

**First appearance in the model** (`P3.first`). n_first is the first grid n at which χ_S is an explicit feature of the
final model; n_pred is the first grid n with m > n_glob (P3b).
- **427 characters are predicted within the grid** (16 ≤ n_pred ≤ 16384).
  - **105 appear at n_pred**, and **266 earlier**.
  - **54 one doubling later.** All 54 failed the round-0 test at n_pred with z < 1 (at most 0.994), a fluctuation;
    none was cut by the 64-candidate cap or the room (`P3.late`).
  - **2 never.** thr10's x2x8x10 has n_glob = 14498 and z = 0.60 at 16384. majpar's degree-6 term has n_glob = 147.0,
    just at the subsample size m₆ = 147, and z = 0.83 from n = 1024 on.
- **321 characters appear although none was predicted.**
  - 262 come through the local class.
  - 53 come through the round-0 test below their n_glob, on 0.23–0.93 × n_glob rows
    (`P3.first.seen_not_predicted_global_r0`). 37 of these are maj9's degree-3 characters, with n_glob = 17543 just
    above the grid, entering at 8192–16384. The other 16 are 14 small characters of dnf3 (n_glob = 26000–36000,
    entering at 8192–16384), 1 of thr10 (n_glob = 21658, at 16384) and 1 degree-5 character of rand3 (n_glob = 2169,
    against its subsample of 1374 rows at n = 2048).
  - The rest come through ext2 (4), the global test in a later round (1) and the linear block (1).
- **949 are neither predicted nor ever seen.** 168 have degree ≥ 7, where no global test exists. The other 781 have
  n_glob beyond the grid (degree ≤ 4) or beyond the degree-5/6 subsample, by a factor of at least 1.07, and
  |ŷ_S| ≤ 0.25 (`P3.first.never_predicted_never_seen`).
- **249 characters first appear through the round-0 global test.** For them, n_first/n_glob has median 2^0.26, the same
  +0.26 doublings ORDER.md found over 151 character-seeds of the Part 5 targets.
  - 179 lie within one doubling of n_glob.
  - 54 lie more than one doubling after n_glob: exactly one grid step after n_pred, and they are the 54 "later"
    characters above. There the first grid point lay just above n_glob (1.01–1.59 × n_glob, median 1.16), where the
    pass rate is 0.62–0.94 (table above). For example, parmaj's six degree-4 characters failed at n = 512 = 1.05 n_glob
    with z = 0.78–0.99 (`P3.first.global_r0.above_1_detail`).
  - 16 lie more than one doubling before n_glob.

**What makes a character cheaper than n_glob** (`P3.early_routes`, `P3.factors`). The routes of the 266 early
characters are:
- the local class, 70;
- the linear block, 60 (46 of them in round 0; all degree 1, median log2(n_first/n_glob) = −1.8;
  `P3.first.linear_block.earlier`);
- ext1, 33, and ext2, 15;
- the global test in a later round, 36;
- the forced variant, 12, at n = 16–128;
- the round-0 test itself, 40 (35 of them one doubling early).

For the later-round classes, the table gives medians over the characters that enter early or without a prediction
(`P3.entry_vs_nglob`, `P3.factors`):
- "enter below n_glob" is log2(n_glob/n_first), for degree ≤ 6;
- "class gain" is log2(n_glob/n_cls), P3c's factorization at the round of entry. It is the larger of the two, because a
  character enters at the first grid point where its class passes, usually with z > 1;
- the three factor columns are that factorization's union-bound, residual and coefficient factors.

| class | characters (degree ≤ 6) | enter below n_glob (doublings) | class gain (doublings) | L_glob/L_cls | (1 − ŷ₀²)/s_j² | v_j²/ŷ_S² |
|---|---|---|---|---|---|---|
| local | 332 (277) | 3.7 | 4.5 | 1.71 | 19.2 | 0.80 |
| ext2 | 19 (19) | 1.9 | 2.6 | 1.20 | 5.0 | 1.06 |
| ext1 | 33 (33) | 1.7 | 2.3 | 1.32 | 3.2 | 0.86 |
| global, rounds ≥ 1 | 37 (37) | 1.4 | 1.7 | 1.00 | 3.3 | 0.85 |

- **The smaller residual is the main factor in every class.** For the composition classes the smaller union bound adds
  a factor of 1.2–1.7, i.e. at most 0.8 doublings; the global test in later rounds has round 0's union bound.
- **The local class** is DFG's junta completion, every subset of the inputs in use. It enters after the large terms
  are fitted, when s_j² is about 1/19 of the label variance.
- **Degree ≥ 7.** 55 of the local class's 332 characters have degree ≥ 7, where no global test exists. Their
  L_glob is that of a hypothetical global test of their degree.
- **Against ORDER.md.** On the Part 5 targets ORDER.md took every character-seed admitted by each route, of degree
  ≤ 4. It found the global route at +0.26 doublings from n_glob, and the composition classes 1.3–2.4 doublings below it
  (ext1 1.34, ext2 2.42, local 1.74). The same statistic here (41 targets, seed 0; `P3.entry_vs_nglob_all`) is +0.26
  for the round-0 global test, and 1.8 (ext1), 1.7 (ext2), 3.0 (local) and 1.4 (global test in later rounds) doublings
  below n_glob. Every character that first enters through a later-round class is in the table above except 3 local
  ones, so the table's restriction to early or unpredicted characters changes little.

## 4. P4: sum blocks — what they represent, what grouping loses, and their low-degree weight

Notation. A block has inputs S (|S| = k), signs s_i, and t(x) = Σ_{i∈S} s_i x_i ∈ {−k, −k + 2, …, k}. Its groups are
contiguous runs of values of t, cut at the edges E; a point's group is `searchsorted(E, t(x))`. Write
z_i = s_i x_i, which is uniform on {−1, 1}^k, and B = #{i ∈ S : z_i = +1} = (t + k)/2.

**P4a (Proved, by the code).** DFG adds a block's indicators φ_v = [group = v] for every group v occupied in training
except the most populous one, v_max (line 835); the constant is always a feature. On every input whose group is
occupied in training, span{1, φ_v} contains every function of the group label. Hence, if each value of t that occurs in
training is its own group, every function g(t) is represented exactly at every x whose t-value occurs in training. That
takes at most k + 1 parameters (k indicators and the constant). By contrast, the Fourier expansion of g(t) can need all
2^k characters of degree ≤ k (P4d).

*Proof.* For a function h of the group label, h = h(v_max)·1 + Σ_{v ≠ v_max} (h(v) − h(v_max)) φ_v holds on every
occupied group. □

**P4b (Proved, by the code).** `_edges` scans the observed values in increasing order. It closes a group as soon as the
running count reaches mc = max(3, ⌊0.005 n⌋) and merges a short last group into the one before. Hence every observed
value is its own group iff every observed value has at least mc training points. A value with fewer than mc points
always shares a group: with the next value, or with the previous one if it is the last. In the large-n limit (counts
n·P(t = v), mc = 0.005 n) the rarest values are t = ±k, with probability 2^(−k). So every value is its own group iff
2^(−k) ≥ 0.005, i.e. k ≤ 7; for k ≥ 8 the tails merge.

**P4c (Proved).** Any linear combination of one block's features and the constant is constant on each of the block's
groups (P4a). So a sign readout that uses only this block errs on at least Σ_groups min(P(g = +1, group), P(g = −1,
group)), with equality for the majority value in each group. This is what contiguous grouping loses: g must be constant
on runs of values. A threshold or interval in t loses nothing when its ends fall on edges. A function that changes at
every step, such as a residue class, loses the minority mass of every merged run.

**P4d (Proved).** Let f(x) = g(B). Then f̂(T) = 0 unless T ⊆ S, and for T ⊆ S, f̂(T) = (Π_{i∈T} s_i) a_{|T|} with

  a_j = E[g(B) z_1⋯z_j] = 2^(−k) Σ_b g(b) K_j(b),  K_j(b) = Σ_l (−1)^(j−l) C(j, l) C(k − j, b − l),

so W_j = Σ_{|T| = j} f̂(T)² = C(k, j) a_j².

*Proof.* An input outside S is independent of f, so E[fχ_T] = E[fχ_{T∩S}]·E[χ_{T∖S}] = 0 if T ⊄ S. On S, substitute
z_i = s_i x_i, a measure-preserving bijection; then χ_T(x) = (Π_{i∈T} s_i) Π_{i∈T} z_i, and by symmetry the coefficient
depends on |T| only. K_j(b) = Σ_{z : B = b} z_1⋯z_j: choose l of the first j coordinates and b − l of the others to
be +1. □

**P4e (Proved): residue classes mod 3.** Let g(b) = σ(1 − 2[b ≡ ρ (mod 3)]) with σ = ±1, and let ω = e^{2πi/3}. Then
[b ≡ ρ] = ⅓ Σ_{m=0}^{2} ω^{m(b−ρ)}, and since B = Σ (1 + z_i)/2 with independent z_i,
E[ω^{mB} z_1⋯z_j] = ((ω^m − 1)/2)^j ((1 + ω^m)/2)^(k−j). The m = 0 term vanishes for j ≥ 1, and m = 2 is the complex
conjugate of m = 1. With (ω − 1)/2 = (√3/2) e^{5πi/6} and (1 + ω)/2 = ½ e^{πi/3}, for j ≥ 1:

  a_j = −2σ · (2/3) · 3^{j/2} 2^(−k) · cos(5πj/6 + π(k − j)/3 − 2πρ/3),

so |a_j| ≤ (4/3) 3^{j/2} 2^(−k) and W_j ≤ (16/9) C(k, j) 3^j 4^(−k). The low-degree weight is exponentially small in k.
The angle is π(3j + 2k − 4ρ)/6, so the cosine vanishes iff j is odd and k ≡ 2ρ (mod 3). This rule was checked exactly
for k = 2–16 and ρ = 0, 1, 2 (405 cases, no exception; `P4.mod3_vanishing_rule`). For f7_05, h6_00 and fd_10,
k − 2ρ ≡ 2, 2, 1 (mod 3), so every a_j with j ≥ 1 is nonzero.

**P4f (Proved): what the block search sees.** Every starting order and seed of `_block_search` (lines 227–361) is
computed from statistics of one or two inputs. The greedy growth and the local search that follow score larger blocks,
whose statistic sees higher degrees, but only along these starting points. The starting points are:
- the top eigenvectors of the residual pair matrix M, and its strongest entries;
- the degree-1 coefficients c₁, and the best single inputs;
- the inner terms on M's strongest pair;
- at n ≤ 128, a beam started from the best two-input blocks. A two-input block's groups are functions of
  x_i + s x_j, whose span is {1, x_i + s x_j, x_i x_j}, so its statistic depends only on degree ≤ 2 coefficients.

In round 0, for iid rows, exactly E[M_ij] = f̂({i, j})(1 − 1/(n + 10⁻⁹)) for i ≠ j, and
E[c₁ᵢ] = f̂({i})(1 − 1/(n + 10⁻⁹)), by the same computation as P3a. On S×S the expected pair
matrix is a₂(1 − 1/n)(σσᵀ − I) with σ the sign vector. Its largest eigenvalue in absolute value is |a₂|(k − 1)(1 − 1/n).
Off S×S each entry has, given y, mean 0 and standard deviation exactly s/√n (when s² = mean r²): its x_i x_j is then a
fair sign independent of y.

**The three residue-class targets, exactly** (Numerical, exact; `P4.targets`). The W_j are computed as rationals from
P4d. They equal the Walsh–Hadamard transform of each target's own function on all 2^k patterns, and the closed form P4e
to 4·10⁻¹⁶. B counts the signed inputs equal to +1.

| target | definition | k | a₁ | a₂ | W₁ | W₂ | W₁ + W₂ | weight peaks at degree | nonzero characters | block parameters |
|---|---|---|---|---|---|---|---|---|---|---|
| f7_05 (dlheld7) | [B mod 3 ≠ 0] | 14 | 2⁻¹³ | −2⁻¹³ | 14·2⁻²⁶ = 2.1·10⁻⁷ | 91·2⁻²⁶ = 1.36·10⁻⁶ | 105·2⁻²⁶ = **1.56·10⁻⁶** | 11 | 16383 | 15 |
| h6_00 (dlheld6) | [B mod 3 ≠ 1], signed | 13 | −2⁻¹² | 2⁻¹² | 13·2⁻²⁴ = 7.7·10⁻⁷ | 78·2⁻²⁴ = 4.65·10⁻⁶ | 91·2⁻²⁴ = **5.42·10⁻⁶** | 9 | 8191 | 14 |
| fd_10 (dlfamdev) | [B mod 3 = 0], signed | 10 | 2⁻⁹ | 2⁻⁹ | 10·2⁻¹⁸ = 3.8·10⁻⁵ | 45·2⁻¹⁸ = 1.72·10⁻⁴ | 55·2⁻¹⁸ = **2.10·10⁻⁴** | 7 | 1023 | 11 |

- **Against Part 10's "W₁ = 0 and W₂ ≤ 0.0002 for all three".** That is right to four decimals. Exactly, W₁ + W₂ is
  1.6·10⁻⁶ for f7_05 and 5.4·10⁻⁶ for h6_00, 128 and 37 times below 0.0002. For fd_10, W₁ = 3.8·10⁻⁵ is not
  zero, and W₁ + W₂ = 2.10·10⁻⁴ exceeds 0.0002 by 5%.
- **Every character on S is nonzero:** all 2^k − 1 of them (P4e). One block with one group per value represents each
  target with k + 1 parameters or fewer.

**The representation, checked** (Numerical; `P4.grouping`). Give the block one group per observed value. Least squares on
its indicators and the constant then reproduces the seed-0 training labels at n = 16384 exactly (largest residual
2.6·10⁻¹⁴), with 15, 13 and 11 parameters. h6_00 has 13 rather than 14 because its value t = −13 was not drawn.

**What grouping loses** (Numerical; `P4.grouping`, `P4.generic`).
- In the large-n limit (mc = 0.005n), every value of t is its own group iff k ≤ 7 (checked for k = 2–15).
- For the three targets, the limit groups and the groups DFG forms on seed 0's 16384 rows (mc = 81) coincide. The rarest
  values at each end are merged: into runs of three for f7_05 and h6_00 (B ∈ {0, 1, 2} and {k − 2, k − 1, k}), and runs
  of two for fd_10.
- The block alone then cannot beat an error of 1/1024 (f7_05), 7/4096 (h6_00) or 1/512 (fd_10) (P4c). Its
  least-squares fit on the training rows has test error 0.0017, 0.0037 and 0.0017.
- So grouping costs these targets 0.1–0.2% in the population, and the block-only least-squares fits reach 0.17–0.37% on
  the test inputs. That is not why they are never learned.

**What the search sees** (Proved: P4f gives the expectations; Heuristic: the thresholds).
- **Signal per entry.** The expected pair-matrix entry on S is a₂ against noise ≈ s/√n. At n = 16384 that is a
  signal-to-noise ratio of 0.017 (f7_05), 0.033 (h6_00) and 0.27 (fd_10); the degree-1 coefficients give the same
  values, since |a₁| = |a₂|.
- **Eigenvector seed.** By the BBP threshold for a rank-one perturbation of a Wigner matrix (the top eigenvector is
  informative iff |a₂|(k − 1) > s√(d/n)), it needs n ≈ s²d/(a₂²(k − 1)²) = 1.1·10⁷, 3.1·10⁶ and 8.6·10⁴.
- **Degree-1 ranking.** Ranking S's inputs first needs n ≳ 2 ln d · s²/a₁² = 4.1·10⁸, 1.0·10⁸ and 1.6·10⁶.
- All of these are far above the grid's 16384, while Part 10 found the true block passing its test from n = 128
  (unfolded; `part10/interp/TOY_INTERP.md`). This puts numbers on Part 10's reading that the search, not the test,
  limits these targets. (There the eigenvector prefixes covered 0.50–0.57 of S, against |S|/30 = 0.33–0.47 by chance.)

## 5. P5: compute

**P5a (Proved, by the code): the FLOPs of the degree-k search.** The counter charges a multiply-add as 2. For the
round's global search on m_k rows (m_k = n when not subsampled):

| degree | charged FLOPs (lines) | exhaustive (m = n) |
|---|---|---|
| 1 | 2nd (617) | 2nd |
| 2 | 2nd² + nd (621) | 2nd² + nd |
| 3 | (d − 2)(2m₃d² + 2m₃d) (630–631) | 2nd(d + 1)(d − 2) |
| 4 | C(d − 2, 2)(2m₄d² + 3m₄d) (640–643; pairs a < b ≤ d − 3) | n d(2d + 3)(d − 2)(d − 3)/2 ≈ n d⁴ |
| 5, 6 | m_k(2N₁N₂ + N₁k₁ + N₂k₂), N_i = C(d, k_i) (658) | n(2N₁N₂ + N₁k₁ + N₂k₂) |

So the exhaustive degree-3 search costs ≈ 2nd³ ≈ 12n·C(d, 3) FLOPs and the degree-4 search ≈ nd⁴ ≈ 24n·C(d, 4). That
is polynomial in d of degree k: the matrix products also compute the redundant entries (lower triangles and overlapping
sets), so each character costs 12n or 24n rather than 2n. One network run costs GD(d) = 6P·64·T + 10P·T = 394·T·P
FLOPs (`harness.gd_flops`), with P = 128d + 16768 parameters and T = 20000 steps, i.e. 7.88·10⁶·(128d + 16768); the
d = 120 networks trained for T = 40000 steps, which doubles GD(120). It is linear in d.

**P5b (Proved, by the code): the budget rule.** m_k = min(n, ⌊share·GD/c_k⌋), where c_k is the per-row cost estimate in
§0's table: d(2d² + 2d) for k = 3, C(d, 2)(2d² + 3d) for k = 4, and 2N₁N₂ + N₁k₁ + N₂k₂ for k = 5, 6. The shares are
0.15 for degree 4, 0.03 per round for degree 3, 0.03 each for degrees 5 and 6, and 0.03 per round for the two-input
extensions. A search with m < 32 (degrees 3, 4) or m < 64 (degrees 5, 6) is skipped. The true per-row costs
(d − 2)(2d² + 2d) and C(d − 2, 2)(2d² + 3d) are at most the estimates, and for degrees 5–6 they are equal. So **each
budgeted search costs at most its share of GD·`scale`**. The shares of the 2F + 1 calls add up to one run
(0.5 + 2F · 1/(4F) = 1). The other parts (the degree-1 and degree-2 searches, ext1, the local class, the spectral
eigendecomposition, the sum blocks, least squares, the Newton steps and the background) are not budgeted: they are only
stopped by the round cap of 0.75 GD·`scale`, which is checked at the start of each round, so a fit can exceed it by the
cost of its last round.

**The budgeted row counts** (Proved arithmetic from the code; `P5.m_table`). Large n, `scale` 1 / 0.5:

| d | m₃ | m₄ | m₅ | m₆ |
|---|---|---|---|---|
| 15 | 613589 / 306794 | 424996 / 212498 | 45486 / 22743 | 10599 / 5299 |
| 30 | 87307 / 43653 | 29627 / 14813 | 1374 / 687 | 147 / 73 |
| 60 | 13159 / 6579 | 2212 / 1106 | 47 / 23 (skipped) | 2 / 1 (skipped) |
| 120 | 4358 / 2179 | 364 / 182 | 3 / 1 (skipped) | 0 (skipped) |

The fold fits (`scale` 1/20 and 1/40) get m₄ = 110 and 55 at d = 60, and 18 and 9 at d = 120, where degree 4 is skipped.
So on the grid (n ≤ 16384):
- At d = 15 and 30 every degree-3 and degree-4 search runs on all rows. At d = 30 the degree-5 and degree-6 searches are
  subsampled to 1374 and 147 rows, as the docstring says.
- At d = 60 the final fit's degree-4 search is subsampled from n = 4096 (2212 rows) and its degree-3 search at
  n = 16384 (13159 rows). The fold fits' degree-4 search runs on at most 55 rows (10 folds) or 110 rows (5 folds), so it
  is subsampled at n = 64, 256 and 512 (fold sizes 57–58, 204–205, 409–410). The degree-5/6 searches never run.
- At d = 120 the degree-4 search runs on 364 rows (182 under the cross-validation's half budget, i.e. already from
  n = 256), the degree-3 search on 4358 rows from n = 8192. The fold fits skip degree 4 entirely and subsample
  degree 3 at n = 512 (217 of 409–410 rows; `P5.fold_subsampling`).

**At which d the degree-4 search becomes subsampled** (`P5.d_star`): the smallest d with m₄ < n.

| n | 32 | 64 | 128 | 256 | 512 | 1024 | 2048 | 4096 | 8192 | 16384 |
|---|---|---|---|---|---|---|---|---|---|---|
| d | 163 | 133 | 110 | 90 | 75 | 75 | 62 | 51 | 43 | 36 |

For n ≤ 512 the table uses the final fit under the cross-validation (`scale` 0.5). The search is skipped altogether
(m₄ < 32) from d = 199 at n > 512, from d = 163 in the final fit at n ≤ 512, and from d = 85 and 70 in the 5- and
10-fold fits. Degree 3 is skipped from d = 746. These use the harness's GD(d); its one exception is that the d = 120
networks trained twice as long, which doubles every m at d = 120. So d* is the smallest such d, not a threshold for
every larger d: at d = 120 the n = 128 search runs on all its rows (m₄ = 182; `P5.d_star_exceptions_at_d120`, the
table's only exception).

**Exhaustive costs** (`P5.exhaustive`), in network runs GD(d): the degree-4 search on n = 64 rows costs 2.8·10⁻⁴ at d = 30,
4.1·10⁻³ at 60, 0.025 at 120 and 55.9 at 1000. On n = 16384 rows it costs 0.072, 1.04 and 6.5 at d = 30, 60, 120.

**Check against the result files** (Numerical; `P5.check`, `P5.decomposition`). I wrote down the FLOPs of the "parity
path" from the code. This is the path where round 0 admits χ_S alone; the blocks' eigendecomposition (10d³) and the
sum-block projection (16n + 8) are charged; round 1 stops on the sign rule; the readout takes 15 Newton steps and the
background; at n ≤ 512 the 2F fold fits are added with their exact fold sizes n − ⌈(n − f)/F⌉.
- **It reproduces the recorded FLOP count to < 10⁻⁹ relative in 228 of the 275 parity cells** (par2–par4,
  d = 15–120, every n and seed).
- **4 more match exactly once a false linear block admitted next to χ_S is added.** That happened in one fold of par4 at
  d = 30, n = 256 and one of par4 at d = 60, n = 512 (in both variants' fits of that fold), and in the final fits of par3
  at d = 30, n = 16384 and at d = 60, n = 8192. Refits of the 4 cells show the linear block in round 0 and reproduce
  the recorded counts bit for bit (`P5.check.linear_cells_refit`). The FLOP model cannot tell apart folds of equal
  size; the refits place the two fold blocks in fold 2 and fold 1, folds the model allows (`same_place`). These are
  P1b's false linear blocks, seen under the alternative: for k ≥ 2 the degree-1 coefficients have no signal.
- **The other 43 are all at n ≤ 32.** At n ≤ 32 the model is exact in exactly the cells where every fold fit and the
  final fit admit χ_S by P2's criterion on their own rows (`P5.check.n_le_32`, 50 of 50 cells). Those are the 7 par2
  cells at n = 32 and d ≤ 60. At n = 16 no fold fit passes. At n = 32 the fold fits (28–29 rows) do not search
  degrees 3–4, and par2 at d = 120 has only 8 and 9 passing folds of 10.
- **Where the n = 16384 par2 fit spends its compute** (model = recorded to 10⁻¹⁵):
  - d = 15: 0.046 GD (degree 6: 0.030, degree 5: 0.011, degree 4: 0.004);
  - d = 30: 0.137 (degree 4: 0.072; degrees 5 and 6: 0.030 each);
  - d = 60: 0.170 (degree 4 on 2212 rows: 0.140; degree 3: 0.029);
  - d = 120: 0.175 (degree 4 on 364 rows: 0.145; degree 3 on 4358 rows: 0.029).
- **The largest recorded fit** in each suite costs 0.067 GD (d = 15, maj9), 0.37 (d = 30, thr10), 0.18 (d = 60, maj9)
  and 0.18 (d = 120, maj9).
- **The budget bound P5b**, checked over d = 5–399 and the four scales: no budgeted search's charged cost exceeds its
  share (largest ratio 1 − 1.4·10⁻⁸).

## 6. The claims at a glance

| claim | what | label | checked by (key in `check_theory.json`) |
|---|---|---|---|
| P1a | null, round 0: global test admits a degree-k character with prob. ≤ 2N(δ/(4KN))^{u²c²} (δ/(2K) at u = c = 1) | Proved | `P1.sims` (280 checks), `P1.full_fits` |
| P1b | null, round 0: the linear block's statistic exceeds d + 2√(dx) + 2x with prob. ≤ e^{−x} (δ at the code's level) | Proved | `P1.sims[*].linear` (64 checks) |
| P1c | nothing admitted in round 0 ⇒ the default variant's model is the constant plus the background | Proved (code) | `P1.full_fits_replica` (110 / 110) |
| — | spectral block, sum blocks, forced variant, the cross-validation's choice, rounds ≥ 1 | not covered | `P1.sims[*].quad`, `P1.full_fits`, `P1.nonconstant_fits`, `P1.forced_fits_replay` |
| P2 | a k-parity passes iff n(1 − ȳ²) > n_thr(k, d); exact binomial P(pass) | Proved | `P2.agree` (250 / 250), `P2.cells`, `P2.fold_criterion_vs_default_folds` (50 / 50) |
| P2′ | any target, any round: a class of N candidates admits nothing on m ≤ 2c² ln(4KN/δ) rows | Proved | `P5.d_parity_unreachable` (where it binds) |
| — | measured n* = the interpolation from the first passing grid point, plus the forced variant at n = 16 | Numerical | `P2.pred` |
| — | d = 1000, and the networks' extrapolation | Heuristic | `P2.d1000`, `P2.networks` |
| P3a | the exact round-0 criterion; E[v_S] = ŷ_S(1 − 1/(n + 10⁻⁹)) | Proved | — |
| P3b | n_glob as the first-order detection size | Heuristic | `P3.test0` (96.9%, calibration), `P3.first`, `P3.late` |
| P3c | later-round classes: n_glob/n_cls = union-bound × residual × coefficient factors | Proved (identity) | `P3.factors`, `P3.entry_vs_nglob`, `P3.entry_vs_nglob_all` |
| P4a–c | block representation (≤ k + 1 parameters), grouping, what grouping loses | Proved (code) | `P4.grouping`, `P4.generic` |
| P4d–e | Fourier coefficients of g(B); the mod-3 closed form and its bound | Proved | `P4.targets` (exact, equal to Walsh–Hadamard) |
| P4f | E[M_ij] = f̂({i, j})(1 − 1/(n + 10⁻⁹)), E[c₁ᵢ] = f̂({i})(1 − 1/(n + 10⁻⁹)) | Proved | — |
| — | sample sizes at which the search's seeds see a mod-3 class (BBP, degree-1 ranking) | Heuristic | `P4.targets` |
| P5a–b | FLOP formulas; each budgeted search ≤ its share of GD·`scale` | Proved (code) | `P5.check` (232 / 275 exact; `n_le_32`: 50 / 50 explained), `P5.max_share_used_over_share` |
| — | budgeted row counts; where the degree-4 search is subsampled or skipped | Proved (arithmetic) | `P5.m_table`, `P5.d_star`, `P5.d_star_exceptions_at_d120`, `P5.fold_subsampling`, `P5.d_parity_unreachable` |

**Limits of these checks.**
- P3 and the parity refits use seed 0, or the result files' seeds (2–3).
- The full-fit null sample is small: 110 fits, at d = 30 only.
- The uncovered parts' false-admission rates are measured, not bounded, and only for the label laws tried.
- The proved bounds concern round 0. After a false admission, nothing here bounds what the later rounds add.
- Everything about d = 1000 is extrapolation.

## Reproduction and checks of the tooling

- `OMP_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 python theory_fits.py` makes and caches four sets of fits in `cache/`:
  - `p2_cells.json`: the parity cells at n = 16 and 32, with every fold fit's content;
  - `p1_null_fits.json`: 110 fits on null labels (80 fair, 30 skewed);
  - `p3/*.json.gz`: 330 cells, seed 0, the 10 `designed` targets that the order analysis did not fit and all 20
    `random` targets;
  - `p5_cells.json`: the 4 parity cells with a false linear block.

  From scratch this takes about 20 minutes single-threaded; fits already in the cache are skipped, and `--cache=DIR`
  writes to another directory. Then `python check_theory.py` writes `check_theory.json` (about 7 minutes
  single-threaded, mostly P1's simulation); `--only=P3` and similar recompute single sections. `check_theory.py` makes
  one DFG fit itself (the replay of the forced null fit, `P1.forced_fits_replay`); everything else it reads from the
  cache, the result files and `dscale.json`.
- **Rerun from scratch, 3 November** (a container restart had interrupted this analysis). All 494 cached fits
  (4 + 50 + 110 + 330), recomputed into an empty directory, were identical to `cache/` field for field. The only
  exceptions were CPU times and a `law` field that the 80 fair-label null fits predate, which `check_theory.py` reads
  as "fair". A full run of `check_theory.py` then reproduced every value of the previous `check_theory.json` exactly
  (0 differences); the keys cited above that were missing before were added by that run.
- Every DFG fit is `interp/dfg_hooks.fit_toy_dfg` or its recorder, i.e. the evaluation's own fit (frozen file,
  md5-checked; the same rows, rng, column permutation and readout). The P3 cells reuse `interp/order/order_fit.py`'s
  replay functions (`replay_round`, `split_solves`, `columns`, `target_support`), whose decisions ORDER.md validated
  against DFG's own (3217 admissions, 29890 non-admissions, none unexplained). For the 11 targets it fitted, the P3
  analysis reads the order analysis' seed-0 cells.
- The parity cells' test errors and FLOP counts are compared with the result files where they exist (`identity` in each
  cached cell). The P1 replica of round 0 is checked against DFG's own round-0 decisions on the 110 null fits
  (`P1.full_fits_replica`). The cross-validation folds rebuilt for P2 and P5 are checked against the recorded fold
  fits' sizes (`P2.cells[*].fold_rows_match_cache`, 50 of 50).
