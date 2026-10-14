# Sub-track "kink": adversarial referee B (computation and counterexamples)

*Report on `notes.md` of this folder and its scripts `checks/k1`–`k5`. Written 2026-10-13.*

* **Read.**
  * The brief `../00-brief.md`.
  * Paper 2:
    * `setup.tex` and `app-setup.tex`: `def:setup:data`, X = {0,1}*, the hull lemma, the coding bound;
    * `split.tex` and `app-split.tex`;
    * `algstat.tex` and `app-algstat.tex`;
    * `teacher.tex` and `app-teacher.tex`: lemmas, the main theorem, the full table.
  * `paper/NOTATION.md`.
  * The sibling notes `../iid/notes.md`, Remark 1.4 and §7.5, for repeated inputs.
  * Referee A's report, read only after my code was written. Agreements are marked "(also A#k)".
* **Code.**
  * All code is in `referee_code/rB1`–`rB6`, independent of `checks/`. Outputs are saved next to each script.
  * Every script is deterministic or seeded (Python 3.11.15, numpy 2.4.6, scipy 1.17.1, mpmath 1.3.0).
  * "rBk(X)" below means part X of the output `referee_code/rBk_*.out`.

**Status tags in this report.**
* **[proved]**: argued here in full.
* **[computed: rBk]**: checked by my script, with output saved.
* **[checked]**: the notes' statement or number reproduced or re-derived.

---

## Verdict

**Accept after one major revision and several minor ones. No fatal issue.**

* **§2–§3.** Every statement survives exact brute force on 1500 random point sets, including duplicates, collinear points and infinite fits. The one exception is Thm 3.2(d) and the matching sentence in §0 item 2, which need τ < σ.
* **§4.** I recomputed every number of k4 from the formulas as written in the notes, with my own code. All of them agree to the printed precision. Every reported λ-range is an interval on a 1000-point grid.
  * The explicit small-d classes confirm the qualitative picture.
  * Two illustrations depend on code details that the notes do not flag:
    * the set-model "slope exactly 1";
    * the zero-window steepness at the exact good model.
* **§5.**
  * The fixed-n results are correct under the without-replacement scheme (wor):
    * Lemma 5.2 holds exactly over a whole class, including fill-ins whose exceptions lie outside the sample;
    * Thm 5.4(i) and (iii) hold in every sample where their hypotheses hold.
  * The i.i.d. scheme (iid), "i.i.d. from a non-atomic law on X", is empty on Paper 2's countable X. In the frozen-label reading with repeats, Cor 5.7(c) is false, and the bound of Lemma 5.1 fails (exact counterexample with an infinite-support μ, rB6).
  * The repair is the per-query object of `../iid/notes.md`.
  * Several finite-sample constants quoted from k3 lie outside the range where the theorems apply under (wor), because n ≤ |X₀| = 65,536.

---

## Issues

### Fatal

None.

### Major

**1. Scheme (iid) is empty on X = {0,1}*. Cor 5.7 is vacuous, and its frozen-label reading is false. (also A#1)**

*Where.*
* §0 item 4.
* §5 "Setting", scheme (iid).
* Lemma 5.1 (iid).
* Cor 5.7.
* §6, last bullet.
* §7 "New".
* The Verification-log cross-check "Cor 5.7(c) … strengthened … under i.i.d. inputs".

*Problem.*
* `def:setup:data` fixes X = {0,1}*. X is countable, so every probability law on it is purely atomic, and no non-atomic μ exists.
* (wor) has n ≤ |X₀| < ∞, so neither scheme gives an infinite sample. Cor 5.7 therefore has no instance.
* With an atomic μ, inputs repeat. Paper 2's data sets keep one frozen label per distinct input (`sec:setup`, "frozen noise"). In that reading two things fail.

*Counterexample* [proved; computed: rB6].
* *Setting.* X is indexed by x = 0, 1, 2, …, with μ(x) = 2^{−(x+1)}, an infinite support. The sampler is ν(1|x) = 1/2 for x ≠ x₀ = 2, and ν(1|x₀) = 1/8.
* *Class* (Kraft sum < 1):
  * the coin, of length 2;
  * π*, the coin except Bern(1/8) at x₀, of length 12; it is the only program μ-a.e. equal to ν;
  * π₂, the coin except label 0 surely at x₀, of length 11.
* *Frozen labels.*
  * Before x₀ appears, the coin and π* have equal fits, and the coin is shorter.
  * After x₀ appears with its frozen label y₀, L(coin) − L(π*) = log(ν(y₀|x₀)/(1/2)) ≤ log(7/4) < 10 ≤ 10λ.
  * So J_λ(coin) < J_λ(π*) for every λ ≥ 1 and every n. The coin differs from ν on an atom of mass 1/8.
  * Hence P[π* is a λ-MAP] = 0 for all n and λ, and Cor 5.7(c) fails with probability 1.
  * Lemma 5.1's bound also fails. E√Λ_n(coin) → 1 − Hel(Bern(1/8), Bern(1/2)) = 0.911, against (1 − Hel_μ)ⁿ → 0 (rB6).
* *Fresh labels* (a new label at every query).
  * E√Λ_n = (1 − Hel_μ)ⁿ exactly.
  * P[π* is a λ-MAP] = 0.9992 at n = 1000 for λ = 2, and 1.0000 at n = 5000 for λ ∈ {1, 1.5, 2, 4} (rB6).
* This is an instance of `../iid/notes.md` Prop 7.5: with frozen noise, no procedure recovers every sampler. Referee A's two-program example (A#1) is another instance.

*Fix.* As in `../iid/notes.md` Remark 1.4:
* State the asymptotic part of §5 for the per-query object: (x_i, y_i) i.i.d. from μ ⊗ ν with repeats, and L(π) = −Σ_{i≤n} log ν_π(y_i|x_i).
  * Lemma 5.1 (iid) then holds with equality, and the rest of §5 goes through.
  * §2–§3 apply to the point family {(ℓ(π), L(π))}. This is not ρ^×_D of one of Paper 2's data sets; say so in §0 item 4 and §6.
* Keep (wor) for the fixed-n statements.
* For frozen labels with an atomic μ, state that only "ν-equivalent on the run" survives (`thm:split:private`(iv), `../iid/notes.md` Prop 7.6), and cite the counterexample.
* Mention non-atomic μ only as a remark: it needs an uncountable input space, outside both papers.

### Minor

**2. Thm 3.2(d) and §0 item 2 ("zero-window kinks at one point are exactly the hull vertices") need τ < σ. (also A#2)** [computed: rB1(T5)]
* In 1500 random point sets, 901 points are zero-window (σ, τ)-kinks with τ = σ, that is, collinear interior points of a hull edge. None of them is a vertex.
* Every zero-window kink with τ < σ is a vertex (3352 cases).
* Minimal instance: {(0,10), (1,5), (2,0)}. The middle point is a zero-window (5, 5)-kink but lies inside the edge.
* *Fix.* Add "with τ < σ" to (d) and to §0 item 2.
* Related and not an issue [computed: rB1(T4)]: at λ = σ exactly, a λ-MAP can lie left of α₋ − w₋ (3494 cases), and at λ = τ exactly, right of α₊ + w₊ (3357 cases). So the strict inequalities in Thm 3.2(a)–(b) are needed. A sentence saying so would help readers.

**3. The sentence after Prop 3.5 cites Cor 3.3(b) for an upper bound on MAP length. (also A#3)**
* Cor 3.3(b) gives lower bounds on length.
* The bound that holds is the absorption bound ℓ(π̂) ≤ ℓ_U + (ℓ_U + κ₀)/(λ − 1), for every λ > 1. rB1(T7) confirms it in 18,000 (point set, U, κ₀, λ) cases.
* It is at most ℓ_U + (ℓ_U + κ₀)/ε only for λ ≥ 1 + ε.
* *Fix.* "For λ ≥ 1 + ε, every λ-MAP has length at most ℓ_U + (ℓ_U + κ₀)/ε, by the absorption bound (`thm:absorb:absorption`(a)); compare Cor 3.3(a)."

**4. Several k3 sample sizes in §5 exceed the domain size, so the theorems behind them never apply to k3's instance.** [checked: k3 output; computed: rB3(E2)]
* k3 samples without replacement from X₀ = {0,1}^16, so n ≤ M = 65,536.
* Cor 5.5. The quoted n₀ = 3·10⁵ to 5·10⁸ all exceed M, so Cor 5.5 is vacuous for k3's instance.
* Thm 5.6 with γ = 10⁻³. At λ = 8, n₀ = 7.8·10⁴ > M. At λ = 1.5 with γ = γ₀ the guarantee is −0.57 (see also A#9).
* Thm 5.4(iii). For caps ℓ̄ = 32, 37 and 47, k3's thresholds are 9.5·10⁴, 1.05·10⁸ and 5.2·10⁸, all above M.
  * k3 nevertheless prints "right-steepness bound τ_L … holds in 92–100%".
  * Those lines test a conclusion that the theorem does not assert at those n. They are not checks of (iii).
* *A test where the hypotheses do hold* [computed: rB3(E2)].
  * d = 12 (M = 4096), p = 1/4, coarse rate grid. Thresholds are 1916–2294 for ℓ̄ = 21–26.
  * The flat part and the secant bound hold in 200/200 samples at each of n = 2048, 3072, 4096.
  * Where σ_n > τ_ℓ̄ (n ≥ 3072), π* is the unique λ-MAP at three λ inside (τ_ℓ̄, σ_n) in 200/200 samples, for every applicable cap.
  * Cor 5.5 applies only at λ = 4 (n₀ = 3350). For λ ∈ {1.5, 2, 8, 16, 32}, n₀ = 6.4·10³ to 2.1·10⁵ > M.
  * The guarantees are conservative. Thm 5.4(iii) first gives a nonempty interval at n = 3072 = 0.75M. Empirically π* is the unique λ-MAP in 100% of samples for λ ∈ [1, 2] from n = 512 and for λ ∈ [1, 8] from n = 1024.
* *Fix.*
  * Say that under (wor) the finite-sample bounds need n ≤ |X₀|, and that k3's n₀ values exceed it.
  * Delete or relabel k3's τ_L lines.
  * Add an instance where (iii) applies, for example E2 above or the per-query scheme of Issue 1.

**5. The set-model illustration of §4 ("The set λ-MAP is A₀ for all λ ∈ (1, 27.5): the parity is noise") depends on the code for v.** [computed: rB2 (set models)]
* k2 codes v with a fixed ⌈log₂(d+1)⌉-bit field, so all sets A_v are exactly collinear, with slope 1.
* With another prefix code, Elias γ(v+1), the parity-knowing set A_{v=0} is a set-hull vertex with left slope:
  * 3.0 at d = 8;
  * 2.5 at d = 10;
  * 2.0 at d = 12;
  * 1.75 at d = 16;
  * 1.67 at d = 20;
  * 1.5 at d = 24;
  * 1.36 at d = 30.
* So for λ ∈ (1, slope) the set λ-MAP *knows the parity*.
* This agrees with Prop 4.4, whose bound is 1 + O((log d + δ_E)/d). rB2 also checks Prop 4.4 in class form for 18 instances: max(σ* − bound) ≤ 0.
* It contradicts the illustration's reading that set models treat the parity as noise for all λ > 1 at d = 8. That reading is an artifact of the fixed-length code.
* *Fix.*
  * Say that at small d the O(log d) code terms decide.
  * State the set corollary with its λ-threshold: for λ − 1 ≫ (c* + δ_E + 2κ)/(d − c*), K(A_λ) ≪ d. This is the bound already given under "Comparison".

**6. The zero-window steepness at the exact good model is a rate-code artifact.** [computed: rB2]
* With k2's codes it is 7.89 (window 0). With a different, equally natural rate code (rB2) it is 2.63 at d = 8, p = 1/16.
* At d = 6, p = 1/16 it is 0.66 < 1, and the exact-rate good model is never a hull vertex: the parity with rate 1/8 dominates it.
* The robust quantity is the steepness with a window of the size of the rate code. In rB2 that is 11.3 at w = 3, against k2's 13.05 at w = 4. Prop 4.1 is stated this way.
* *Fix.* In the Illustration, lead with the windowed steepness and note that the zero-window value depends on the rate code.

**7. The two-kink ranges quoted from k2(F) are incomplete.** [checked: k2 output]
* The notes say "parity + noise for λ ∈ (1.36, 10.0)".
* k2's hull has three parity-with-noise vertices:
  * v1, q = 1/4, on (10.01, 12.76);
  * v2, q = 1/8, on (1.358, 10.01);
  * v3, q = 0.094, on (1.223, 1.358).
* So "parity + noise" holds on (1.223, 12.76).
* rB2's independent two-kink instance (rule m = 5, |S| = 2, 12 random flips) gives parity + noise on (2.58, 11.14) and parity + rule on (0.69, 2.58). So λ = 1 learns the rule there.
* *Fix.* Quote (1.22, 12.8), or say "the best-rate vertex alone".

**8. The bounds u ≥ 0.993 and e ≤ 0.208 in "Numbers (b)" are not among Prop 4.2's conclusions.** [computed: rB4(b)]
* Prop 4.2(a) gives only u > 1/2 + 2^{−t₀−1} = 3/4.
* The quoted value follows from combining (c) with the sharp floor at the budget of (e):
  * u ≥ max_g [2^{−R_max} − p − p(2γ_g + 2^{1−g})]/(1 − 2p), with R_max := H(p) + λ(κ_g + s(t₀) + Λ₁)/N.
* This reproduces 0.9928 and e ≤ 0.2081 at λ = 2, and 0.9904 and 0.1831 at λ = 105. The G floor alone gives 0.9913 and 0.9888.
* *Fix.* Add this as item (g) of Prop 4.2, with the formula.

**9. The constant 0.0188 is rounded up. (also A#4)** [computed: rB4(d)]
* My interval check (2·10⁵ cells, mpmath, using that f₂ and H are increasing) gives min f₂(a) − H(b) = 0.018796. The value at p = 1/4 is 0.018797.
* *Fix.* Write "≥ 0.0187". Only positivity is used.

**10. The k5 ranges after Prop 5.8 are specific to k5's family.** [computed: rB5]
* Prop 5.8 itself holds. Its bound is never violated over a grid of 320 settings, and the largest ratio of exact probability to bound is 0.85, so the bound is not loose everywhere.
* Over that grid of Bernoulli pairs:
  * n(P = 1/2)/n_KL ∈ [0.31, 1.43], against the quoted [0.70, 1.01];
  * for λΔ ≥ 15, the ratio is in [0.92, 1.00], not above 0.95;
  * K̄/(2 log e·Hel) ∈ [1.62, 2.24], against [1.84, 1.97].
* k5's own pairs reproduce 1.837 and 1.895.
* *Fix.* Write "in k5's family" before each range. Combine this with A#8's restriction of the "cannot be improved" sentence.

**11. Smaller points.** All of these agree with Referee A, and my code adds evidence.
* §0 item 4 drops the hypothesis A ≥ 2ℓ₀ of the uniform steepness bound. It also writes "flatness 1" where "flatness τ, for every τ > 1" is meant (A#7).
* Prop 4.2's λ-set is not proved to be an interval (A#6(b)). Every λ-set in rB4(c) is an interval on a sorted 1000-point log grid, refined by bisection. So the numbers stand.

---

## What was checked and found correct

* **Re-runs.** k1–k5 were copied to a scratch directory and re-run. All five outputs are byte-identical to the saved `.out` files.
* **§2–§3** [computed: rB1, exact `Fraction` arithmetic, 1500 point sets].
  * *Thm 2.1.*
    * Vertices were found by an extreme-point test on Pareto points, an O(n³) method that is neither gift wrapping nor a monotone chain. They equal the notes' gift-wrapping rule, implemented literally.
    * The polygon equals the brute-force lower boundary of conv(A) + R²≥0 at 64,876 abscissae.
    * Slopes are strictly decreasing, and every vertex is attained at its exact length.
  * *Thm 2.2.*
    * The brute-force argmin equals the predicted vertex or closed-edge set at 27,374 values of λ. These include 1852 breakpoints, 535 of them with collinear interior points.
    * "Unique on an interval ⟺ vertex" holds at 4253 Pareto points.
    * MAP length is monotone in λ.
  * *Prop 2.3.* The Φ formula holds. Φ's derivative equals the MAP length (3352 cases). The Fenchel recovery holds (53,930 abscissae).
  * *Thm 3.2(a)–(c).* The conclusions hold at 86,120 (left) and 82,676 (right) (point, window, λ) cases with λ strictly inside the range.
  * *Thm 3.4.* Extreme MAP lengths equal α_i and α_j, and extreme kink points equal the same vertices, in 11,938 random (τ, σ) cases, σ = ∞ included.
  * *Prop 3.5* holds in 447,242 kink cases. Its length cap is checked as in Issue 3.
  * *Cor 3.3*, in class form (K := the class's least two-part length, κ = 0): (a) holds in 66,668 cases and (b) in 75,348.
  * *Remark 2.5* holds in 183,337 cases. *The window-absorption remark after Def 3.1* holds in 44,295 cases.
* **§4.**
  * *Numbers* [computed: rB4]. I recomputed independently, from the formulas in the notes and `teacher.tex`, with mpmath log-binomials:
    * N c_hi;
    * the G-floor and sharp-floor level-1 ranges;
    * the identification numbers at d = 20;
    * all 40 rows of the every-rate table (least t₀, range, λ = 2 bounds);
    * the crossovers 0.055964 and 0.123307;
    * the sign of d/dp(f₁ − H), whose grid maximum is −0.43.

    Every value agrees with k4 to its printed precision. The reported K(p) choices are confirmed: 2 log r for p = 2^{−r}, and 2 log(h+1) + 2 log(e+1) otherwise.
  * *Prop 4.1's steepness* σ^{(t₀)} is negative at t₀ = 1 for p ∈ {1/8, 15/64}, and positive and of order N at t₀ = 2. This is why t₀ = 2 is needed there [computed: rB4(e)].
  * *Explicit full-table classes* [computed: rB2; 9 (d, p) settings, d ∈ {6, 8, 10}, 2 seeds each].
    * The brute-force λ-MAP matches the hull intervals with 0 mismatches.
    * Cor 3.3(b)'s bounds, in class form, hold on every λ grid tested.
    * The right flatness at the good model ranges over 0.98–1.27. λ = 1 selects the memoriser in 10 of 18 instances: the memoriser edge, as the notes say.
* **§5.**
  * *Self-test* [computed: rB3(E0)]. At d = 4 I enumerated every program of the class: all 2^16 exception sets J for every parity and rate, and all 2^16 lookup tables. The closed forms used in E1 match it exactly.
  * *Lemma 5.2 over a whole class* [computed: rB3(E1); d = 8, p = 1/4, 400 samples for each n ∈ {8, …, 256}].
    * The class includes programs that memorise inputs outside the sample, which k3 left out ("partial check").
    * The frequencies P[S ≤ −t] are at most 0.003 for t = 1, 2, against bounds 0.5 and 0.25.
    * The minimising program is usually the coin. An exception program (family F3, which includes the outside-sample ones) attains it in 2 of 2400 samples.
  * *Lemma 5.3*: frequencies at most 0.005 against 0.5.
  * *Prop 5.8*: the bounds always exceed the empirical frequency that π* is a λ-MAP (E1; exact in rB5).
  * *Lemma 5.2, one-program step*: exact binomial, never violated, maximum ratio 0.5 at n = 1 [computed: rB5(B)].
  * *Thm 5.4(i)* holds in 200/200 samples at every n where its bound is positive (E2). Part (iii) is covered in Issue 4.
  * *λ = 1* [computed: rB3(E2)].
    * π* is the λ = 1 MAP in 100% of samples from n = 512.
    * The right slope at (ℓ₀, L₀) rises with n/M: median 0.50 at M/8, 0.74 at M/2, 0.997 at n = M (max 0.998).
    * This supports Remark 5.9: below 1 here, but approaching the memoriser edge as the sample becomes the full table.
* **Proofs re-derived** [checked]:
  * the Markov exponent in Lemma 5.2;
  * the Ville length bound and the (2 − λ)⁺ℓ̄_λ term in Cor 5.5;
  * the near/far split of Thm 5.6, with no near programs of length ≤ ℓ₀;
  * E X⁻ ≤ log e/e in Prop 5.8;
  * Prop 4.4;
  * the reduction to t ≤ max(t₀, T) in Prop 4.2;
  * the containment of (1, Nc_hi), via s(t+1) ≤ 4(t+1).

---

## Verification log

* **Environment.** Python 3.11.15, numpy 2.4.6, scipy 1.17.1, mpmath 1.3.0, 2026-10-13. All scripts were run with `python3 -I`.
* **Prover's scripts.** k1 (42 s), k2 (20 s), k3 (47 s), k4 (2 s) and k5 (12 s) were re-run in the scratchpad. All five are byte-identical to the saved outputs.
* **`referee_code/rB1_hull_kinks.py`** (`.out`, 174 s). `random.Random(20261013)`. Exact arithmetic. Covers §2–§3, Issues 2 and 3.
* **`referee_code/rB2_parity_table.py`** (`.out`, 98 s). `numpy.default_rng(777)`. Explicit full-table classes, set models and two kinks. Covers Issues 5, 6 and 7.
  * The lgamma differences used for the set table are accurate up to d ≈ 30, so that table stops at d = 30.
* **`referee_code/rB3_sample_kink.py`** (`.out`, 272 s). `default_rng(4141)` (E0), `4242` (E1), `4343` (E2).
  * The E1 closed forms were validated against full enumeration at d = 4 (E0).
  * The exact hull for E2 uses the fact that, at fixed j and q, an exception program's fit depends on its parity only through its mismatch count, and is monotone in it on each side of j. So four candidate counts per j suffice. E0 confirms this against brute force.
* **`referee_code/rB4_parity_numbers.py`** (`.out`, 54 s). Deterministic, mpmath at 80 digits.
  * A first run used an unsorted λ-grid and flagged one range as "not an interval". That was an artefact of the grid. The saved run uses the sorted grid.
* **`referee_code/rB5_margin_exact.py`** (`.out`, 13 s). Deterministic, exact binomial pmf.
* **`referee_code/rB6_atomic_inputs.py`** (`.out`, 3 s). Deterministic. Covers Issue 1.
* **Not done.**
  * Hoeffding (1963) Thm 4 was not checked against the source.
  * I did not re-derive the paper's lemmas `lem:teacher:list`, `lem:teacher:sharpfloor` and `lem:teacher:twopart`. I recomputed only their numerical consequences.
  * I did not simulate the per-query scheme for the full E2 class. rB6 covers it exactly for a three-program class.
* **Repository.** No git command was run. Files were written only in this sub-track folder: this report and `referee_code/rB*`.
