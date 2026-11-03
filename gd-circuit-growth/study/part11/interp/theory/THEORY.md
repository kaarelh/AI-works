# Exact statements about DFG v1.3 run alone

Part 11, Q7 (theory support). The object is **DFG v1.3 run alone** (`dfg13-perm`): the frozen file
`part10/hyb_portfolio3/dfg13.py` (md5 `69cabe5c50345cb24079198ed52b562f`) run as `DFG(readout="logit").fit` inside
`discrete_learner/harness.Permuted` (`part11/eval_dfg.py`), with the constructor's defaults: K = 4, K_later = 3,
c = 1, δ = 0.1, cv_n = 512, sum_nmin = 32, sum_force = True. Written 3 November 2026.

Labels: **Proved** (a proof is given; "by the code" means a direct reading of the cited lines of `dfg13.py`),
**Numerical** (measured; every number is in [`check_theory.json`](check_theory.json), key given in brackets),
**Heuristic** (a reading or an extrapolation, not a measurement). Files:
[`check_theory.py`](check_theory.py) computes every number and writes `check_theory.json`;
[`theory_fits.py`](theory_fits.py) makes the DFG fits it needs (cached in `cache/`).

__SHORT__

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
- **Stop**: a round that admits no character and no block ends the fit (824). A round ≥ 1 does not start if s < 10⁻⁶,
  if every training sign is already right (596), or if the FLOP count exceeds 0.75 GD (598).
- **Forced variant** (817–822). When nothing passes in a round, at most twice per fit, the forced variant adds a guess.
  If n ≥ 48 and the best sum-block candidate's T/threshold exceeds the square of the best character's z, the guess is
  that block. This needs `sum_force` = True, which is the constructor default although the docstring (line 73) says
  "off by default". Otherwise the guess is the best-z global character. The guess is chosen among every degree-1
  character, and for degrees 2–4 among the passing characters and each row block's arg-max; degrees 5–6 count only if
  they pass.
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
covered. The decisions are taken in floating point; the statement is for exact arithmetic, and a rounding error
matters only at an exact tie. □

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
  - At d = 30 the u = 1 hits by degree are 6, 1, 4, 3 (degrees 1–4, over 3600 data sets).
- **The bound is loose by the Gaussian Mills ratio, not by the union** (Heuristic). The Gaussian approximation
  N·2Φ̄(√(2L)) gives 1.15, 1.01, 0.93 and 0.87·10⁻³ for degrees 1–4 at d = 30, against the bound's 12.5·10⁻³. That is a
  factor √(2π)·√(2L) ≈ 10–14, and the union over the N nearly independent statistics is nearly tight. Where counts are
  large it matches. At u = 0.8, d = 30, n = 2048 with fair labels, the observed rates for degrees 1–4 are 0.037, 0.063,
  0.15, 0.22. The Gaussian approximation gives 0.030, 0.069, 0.14, 0.27, and the bound 0.26, 0.69, 1, 1.
- **Linear block: 64 of 64 checks within e^{−x}.** At x = ln(1/δ) (the code's threshold), 43 of the 4800 data sets
  pass (0.9%). The bound is δ = 10%; the χ²_d level of the Laurent–Massart threshold is 0.79–1.17% for d = 15–120
  (0.92% at d = 30).
- **Spectral block (not covered): it can fail badly.** Where it applies (n ≥ 4d) its statistic exceeds the edge in 0 of
  300 at every n with fair or fixed labels, at d = 15, 30 and 60. With P(+1) = 0.85 at d = 30 it exceeds the edge in
  46 of 300 at n = 128 (15%) and 1 of 300 at n = 512. The edge is the semicircle edge for many comparable weights r_t.
  With skewed labels, a few large negative residuals make the pair matrix nearly low-rank at n ≈ 4d (Heuristic).

*Full DFG fits on null labels* (`P1.full_fits`, `P1.full_fits_replica`). These are DFG alone with its own
cross-validation, d = 30.
- **Fair labels, 20 fits at each of n = 64, 256, 1024, 4096: 78 of 80 final models are the constant plus the
  background.**
  - One (n = 1024) holds a pair admitted by the round-0 test, z = 1.06. It is the event P1a bounds.
  - One (n = 256) is a forced-variant model that the cross-validation chose, with held-out errors 122 (default)
    against 103 (forced), holding a forced degree-4 character.
  - No linear block, spectral feature or sum block was admitted.
- **Skewed labels (P(+1) = 0.85), 30 fits at n = 128: 7 of 30 final models hold spurious features**, all in the
  default variant. Six hold spectral features first admitted in round 0, the uncovered test of the previous paragraph.
  One holds a folded sum block on 7 inputs admitted in round 0, then a spectral feature and a second block in round 1.
- **The replica agrees with DFG's own round-0 decisions** (characters by degree, the linear block, the spectral block)
  in __REPLICA__ of the __NFULL__ fits.
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

__P2NUM__

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
73 at 0.5), so a degree-6 character is reachable only if n_glob < 147, i.e. |ŷ_S| ≳ 0.5.

**P3c (Proved: the later-round classes).** In round j the same algebra gives z > 1 ⟺ n > n_cls :=
2c² ln(4K N_cls/δ) s_j²/v_{S,j}², with the class's own N and the round's residual. So

  n_glob / n_cls = [L_glob / L_cls] × [(1 − ŷ₀²) / s_j²] × [v_{S,j}² / ŷ_S²],

the product of three factors: a smaller union bound (for example C(30, 4) = 27405 globally against C(|V|, 4) ≤ 495 in
the local class, or 30 per base in ext1), a smaller residual, and the residual's coefficient on S, which stays near ŷ_S
while S is orthogonal to the fitted features.

__P3NUM__

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

**P4f (Proved): what the block search sees.** Every seed of `_block_search` (lines 227–361) is a statistic of one or two
inputs:
- the top eigenvectors of the residual pair matrix M, and its strongest entries;
- the degree-1 coefficients c₁, and the best single inputs;
- the inner terms on M's strongest pair;
- at n ≤ 128, a beam started from the best two-input blocks. A two-input block's groups are functions of
  x_i + s x_j, whose span is {1, x_i + s x_j, x_i x_j}, so its statistic depends only on degree ≤ 2 coefficients.

In round 0, for iid rows, exactly E[M_ij] = f̂({i, j})(1 − 1/(n + 10⁻⁹)) for i ≠ j, and
E[c₁ᵢ] = f̂({i})(1 − 1/(n + 10⁻⁹)), by the same computation as P3a. On S×S the expected pair
matrix is a₂(1 − 1/n)(σσᵀ − I) with σ the sign vector. Its top eigenvalue is a₂(k − 1)(1 − 1/n), while each entry's
noise has standard deviation ≈ s/√n.

__P4NUM__

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
sets), so each character costs 12n or 24n rather than 2n. One network run costs GD(d) = 7.88·10⁶ · (128d + 16768) FLOPs (harness: 6P·64·T + 10P·T, T = 20000 steps; 40000 at
d = 120), which is linear in d.

**P5b (Proved, by the code): the budget rule.** m_k = min(n, ⌊share·GD/c_k⌋), where c_k is the per-row cost estimate in
§0's table: d(2d² + 2d) for k = 3, C(d, 2)(2d² + 3d) for k = 4, and 2N₁N₂ + N₁k₁ + N₂k₂ for k = 5, 6. The shares are
0.15 for degree 4, 0.03 per round for degree 3, 0.03 each for degrees 5 and 6, and 0.03 per round for the two-input
extensions. A search with m < 32 (degrees 3, 4) or m < 64 (degrees 5, 6) is skipped. The true per-row costs
(d − 2)(2d² + 2d) and C(d − 2, 2)(2d² + 3d) are at most the estimates, and for degrees 5–6 they are equal. So **each
budgeted search costs at most its share of GD·`scale`**. The shares of the 2F + 1 calls add up to one run
(0.5 + 2F · 1/(4F) = 1). The other parts (least squares, sum blocks, Newton steps) are not budgeted: they are only
stopped by the round cap of 0.75 GD·`scale`, which is checked at the start of each round, so a fit can exceed it by the
cost of its last round.

__P5NUM__

__SUMMARY__

## Reproduction and checks of the tooling

- `OMP_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 python theory_fits.py` makes and caches three sets of fits in `cache/`:
  - `p2_cells.json`: the parity cells at n = 16 and 32, with every fold fit's content;
  - `p1_null_fits.json`: 80 fits on null labels;
  - `p3/*.json.gz`: 330 cells, seed 0, the 10 `designed` targets that the order analysis did not fit and all 20
    `random` targets.

  Then `python check_theory.py` writes `check_theory.json`.
- Every DFG fit is `interp/dfg_hooks.fit_toy_dfg` or its recorder, i.e. the evaluation's own fit (frozen file,
  md5-checked; the same rows, rng, column permutation and readout). The P3 cells reuse `interp/order/order_fit.py`'s
  replay functions (`replay_round`, `split_solves`, `columns`, `target_support`), whose decisions ORDER.md validated
  against DFG's own (3217 admissions, 29890 non-admissions, none unexplained). For the 11 targets it fitted, the P3
  analysis reads the order analysis' seed-0 cells.
- The parity cells' test errors and FLOP counts are compared with the result files where they exist (`identity` in each
  cached cell). The P1 replica of round 0 is checked against DFG's own round-0 decisions on the 80 null fits
  (`P1.full_fits_replica`).
