# Paper 2: mathematical review of the body sections and appendices

**Paper.** *Steeper Simplicity Priors in Solomonoff Function Induction*, `paper-steeper/` (sources in `sections/*.tex`, build `main.pdf`).

**Scope.** Every statement and proof in `setup`, `absorb`, `teacher`, `limits`, `split`, `algstat` and `related`, and in the appendices `app-setup`, `app-absorb`, `app-teacher`, `app-limits`, `app-split`, `app-algstat` and `app-related`. Each was checked on its own and against `research/tracks/steeper/notes-final.md`, which is the only source of claims, together with its checks and referee code and the companion-paper results it cites. `app-verification`, the abstract, the introduction and the discussion are outside this review. They are consulted only where they repeat a body claim that is flagged below.

**Method.**
* Each proof was read line by line and every displayed inequality re-derived after the notation swap given in `OUTLINE.md`.
* Every printed number was recomputed with new code written from the formulas as printed in the paper. The code does not import or read the track's scripts. It is in `research/paper-review/scratch/p2-math/`:
  * `teacher_numbers.py` covers sec. 4 and app. C.
  * `limits_split_numbers.py` covers secs. 5-7 and apps. D-F.
  * `schedule_counterexample.py` computes the counterexample of issue P2M-03.
  * `structural_checks.py` runs randomized checks of the price inequality, list decoding with the risk floor, and hull (iii).
  * `make_issues_p2_math.py` writes the JSON issue list.
  * Each script's output is saved next to it as a `.out` file.
* Where my number differed from the paper's, I read the track's script to locate the cause.

**Verdict.** The mathematics is in good shape:
* All main theorems are true as stated, apart from the points listed below:
  * the absorption theorem;
  * per-input pricing;
  * the price of private randomness;
  * the teacher's-mistakes theorem (o)-(iv);
  * the full-table and finite-sample corollaries;
  * power-posterior concentration;
  * error envelopes;
  * rate blindness with its κ-robust lemma;
  * Theorems 3-5 of the split (`thm:split:lambda1`, `thm:split:private`, `thm:split:shared`);
  * the stream-prefix lemma (Lemma 3.2′ of the notes);
  * the hashing lemma;
  * the algorithmic-statistics propositions.
* Nearly every number reproduces exactly. Exceptions are listed.

The issue count is **2 fatal, 6 major and 34 minor** (42 items). P2M-01 to P2M-24 come from the first pass. P2M-25 to P2M-42 come from a second, independent pass, described in section 9 below. That pass found three more major issues:
* `cor:teacher:fulltable`(ii) is missing a hypothesis (P2M-25);
* a false statement that the teacher's-mistakes theorem "does not cover" the envelope rule (P2M-26);
* the power-prior posterior is identified with fractional/generalised posteriors (P2M-27).

The first pass's own count was 2 fatal, 3 major and 19 minor.
* **The two fatal issues** are false general sentences. Each can be repaired locally:
  * the remark after the coding bound claims that a class's own mixture attains K(y_D | dom D) + O(1);
  * the corollary on no universal product hypothesis claims "(Dom) fails in every product class".
* **The three major issues:**
  * an asymptotic claim about schedules λ_n/n → 0 that is false at a fixed instance;
  * a missing "λ fixed" in the absorption theorem (c);
  * the unqualified phrase "gives the erroneous labels little probability".

## 1. Setting (`setup.tex`, `app-setup.tex`)

* **Definitions and the basic lemma.** These are correct and match the notes: data, product and shared hypotheses, hypothesis classes and canonical classes with closure under prefix-free simulation, the objectives, `lem:setup:basic`, and `rem:setup:persample` with its batch caveat for λ = cn. The recalled companion-paper facts are consistent with the foundations notes:
  * M_prod, M_F and M^w agree up to K(dom D) + O(1) (chain theorem);
  * M_F/M_prod is unbounded (Prop 4.5);
  * fresh noise gives infinite loss with positive probability, hence infinite expected loss.
* **Hull lemma.** Parts (i)-(iv) and the refuted strengthening were all re-proved:
  * the boundary structure;
  * the extreme points of conv(A′) + orthant lying in A′;
  * the vertex/exposed-point argument;
  * the monotonicity in (ii);
  * the converse in (iv), including the vertical and horizontal rays.

  The two examples check: thresholds at 0.05 for {(0,1),(10,0.5),(20,0)}, and (5,0.9) above the boundary for L ∈ [5,10). My randomized check of (iii) on 400 point sets (2555 point/set pairs) found no mismatch (`structural_checks.out`).
* **Coding bound.** The coding bound is correct. The paragraph after it is false (**P2M-01, fatal**). No weak function semimeasure attains K(y_D | dom D) + O(1) on every data set. The foundations notes' Example 6.4 ("swap" data) shows this for M_F, and a binary-label version is in the issue. What (Dom) gives is that U attains the class's best two-part length up to a constant.

## 2. Absorption (`absorb.tex`, `app-absorb.tex`)

* **Absorption theorem.** I re-derived each part:
  * (a): the length bound, the loss bound and the L-threshold equivalence;
  * (b): the sandwich and the κ₁ version;
  * (c1)-(c3): telescoping, the finite set H_{≤ℓ*}, and the bounded/unbounded-loss split;
  * (d): the chain rule over bit positions, with nonnegative KL to a sub-probability at input positions.

  All are correct **for fixed λ**. The statement of (c) omits this, and (c3) can fail for λ = cn (**P2M-04, major**). A minor gap: (a) needs U(o) > 0 (**P2M-14**).
* **Examples remark.** The (Dom) proofs for H_F, H_w, H_SI and H_chr are correct, including the empty data set for H_F and H_chr.
* **Per-input pricing.**
  * (i): the bound and the Sion minimax argument (compactness of Δ_ε, uniform error n·log(1−|Y|ε)) are correct. A one-line density remark is missing to pass from all ν to lsc ν (**P2M-13**).
  * The example value is reproduced: max_Q Σ H(Q_x) = 2.54311 < 2.58496.
  * (ii) and (iii) are correct.
* **No universal product hypothesis (`cor:absorb:nouniversal`).** The parity construction and the length d + 2 log d + κ are correct. The final clause "(Dom) fails in every product class" is false for product classes that lack short parity programs, and stronger than the source, which concerns the canonical class (**P2M-02, fatal**).
* **`rem:absorb:condsemi`.** Correct.
* **`rem:absorb:why`.** Matches the foundations notes: the chain theorem, Prop 4.5 and Remark 4.5a, the latter as K^pad(k+1).
* **Price of private randomness (`prop:absorb:price`).** Re-proved:
  * AM-GM per coin pair;
  * Q_π is an lsc semimeasure, and R̃ ≤ 2^{−K(β|k)+κ};
  * the cases λ ≤ 2 (using Q ≤ 1) and λ ≥ 2;
  * Σ t^γ ≤ (Σ t)^γ;
  * the arithmetic of (iv), with γ ≤ 2, γ ≤ λ and (γ+1)κ ≤ (λ+2)κ.

  My randomized check found 0 violations in 12,996 cases.
* **History propositions.** Telescoping, computability of Z_i from a computable Σw, the measure property, and the extended-input reduction are all correct.
* **Answer to the objection (`rem:absorb:wyeth`).** The answer is consistent with the results. Part (i)'s "samplers longer than about ℓ_U" is accurate only for λ away from 1 (**P2M-24**). No visible text names or quotes Wyeth; only the footnote cites the thread, as the binding note allows.

## 3. The teacher's-mistakes theorem (`teacher.tex`, `app-teacher.tex`)

* **Instance.** Checked:
  * δ_S ≥ −2 log m − 2 log s₀ − κ, which the paper states correctly; the notes' "δ_S ≥ −κ" was too optimistic;
  * Pr[δ_S > j] < 2^{−j};
  * the binomial bounds;
  * the reference-program lengths;
  * s(t) ≤ 4t;
  * monotonicity and concavity of G.
* **Lemmas.** All re-proved:
  * List decoding: u(π;a′) = ½(E[h₀+h₁] + ŝ(a′)), Parseval, |A_t| < 2^{2t}, and the c.e. enumeration from the lsc agreement.
  * Floor: by Jensen.
  * Sharp floor: the identity, the c.e. V-side set, the finite-stage A-side set, and the Hoeffding counting via the coding step.
  * Coding lemma: per-factor normalisation, total mass ≤ 1, −log Q(S) = 2^m R_B + β_B.
  * Two-part bounds (D1) and (D2).

  My randomized check of the list identity, list size and floor at d = 6 found 0 violations.
* **Theorem.**
  * (o): the level-1 bound via ψ_c, the reduction to the endpoints φ(2) and φ(t*) by linear + concave, and the cases t > t* and t = ∞.
  * (i): ψ_c minimised at B_S/2^m when c2^m > 1, and the Δ(c) bound.
  * (ii)(a)-(e): the identity cB_S − H = (c2^m−1)H − c(2^mH − B_S), the second branch of (b), Δ_ℓ, symmetry of information in (d), and the counting in (e) with γ_g² = j_g ln 2/(2s₀).
  * (iii): ψ_c ≥ cB_S + (1−c2^m) min{R, B_S/2^m}, and the Jensen step for e.
  * (iv).

  All are correct. The c_hi closed form agrees with bisection to 10⁻¹⁵ in my code.
* **Numbers reproduced** (`teacher_numbers.out`):
  * Hänni's arithmetic: 8.989·10⁻³; 1.1185·10⁻⁶; ratio 8037; switch at n = 8.94·10⁵; H = 0.0112 against 0.0098.
  * L_S = 11,710.273.
  * Crossover p = 0.05596.
  * Windows: c_hi = 8.0618·10⁻³ and 3.6590·10⁻³; ratios 8453 and 3837.
  * **Table (a):** all 20 cells.
  * c = 10⁻³: u ≥ 0.912, e ≤ 0.270.
  * m = 24: L_S = 187,457, e ≤ 0.065 (κ = 0) and 0.084 (κ = 30).
  * **Table (b):** 11 of 12 cells. In the κ = 30, c2^m = 0.99 cell, (iii) does not apply (**P2M-08**).
  * The thresholds 0.99418, 0.937 and 0.99471.
  * Full table: λ ≤ 11945.0 and 6456.2; all 16 cells of the λ = 2 / λ = 105 table.
  * Finite samples: all three rows (9.16, 0.92 and 0.71 bits) and the n = 10⁹ row (92.47 bits, d + 113.9, e ≤ 0.284).
  * Version 1: L_S = 115.580; H = 0.1161; c_hi at κ = 0/5/10/20/30; the λ-window (9.77, 58.0]; ℓ and I at four values of c; u ≥ 0.800; threshold 6.917·10⁻⁴; 0.308 against margin 0.2239.
  * d = 13: 86.2, 62.0 and 39.7. The paper truncates the last two to 61.9 and 39.6 (**P2M-22**).
  * Concentration: −758.33 and L̂′ = 241.72, ε′ = 1.0933·10⁻³. The appendix's "−1000 + 242.3" is an arithmetic slip (**P2M-09**).
* **Framing.** "gives the erroneous labels little probability" (body and abstract) needs quantifying: the bound is 0.20-0.29 at Hänni's sizes and vacuous for Version 1 (**P2M-05, major**). `prop:teacher:concentration` needs cn ≥ 1 (**P2M-15**). The Version 1 finite-sample sentence uses Λ₁ at B = ∞ without saying why that is legitimate (**P2M-18**).

## 4. Limits (`limits.tex`, `app-limits.tex`)

* **Plain Bayes, MDL and SI.** The proofs of (a)-(c) are correct. Reproduced: 11,852.9 exceptions out of 1.2379·10²⁷ error inputs, fraction 9.575·10⁻²⁴, and every e-value in the appendix (0.255, 0.649, 0.958, 0.996; 0.045, 0.734, 0.970; 0 for n^{0.9}). Two problems:
  * The gloss "if λ_n/n → 0 this tends to 1 − 2^{−B} (within n ≤ 2^d)" and the remark's "every schedule with λ_n/n → 0 eventually reproduces the errors" are false for the paper's fixed instance (**P2M-03, major**). For λ_n = n^{0.9} the bound is 0 for every n ≤ 2^{100}. Worse, for n ∈ [10²³, 2^{100}] the theorem and `cor:teacher:sampled` give e ≤ 0.43 to 0.27 with probability ≥ 0.99, so the errors are never reproduced. The correct statement needs (λ_n/n)(d + L_S) → 0, or a growing family of instances.
  * The main text's "O(log dm)" is inconsistent with the displayed κ_b. The appendix fixes it (**P2M-19**).
* **Error envelopes.** Re-proved:
  * concavity giving R_e < H(p);
  * (i) via (o) and (D1);
  * (ii): complement coding, the chain, and min over x of the bracket = min(c, 2^{−m}) B₂′.

  Reproduced:
  * log₂ binom = 6,364.3 and 10,418.3;
  * H − R_e = 0.00510 and 0.00123;
  * c_env = 6.98, 4.95 and 3.13·10⁻⁵ (j = 11) and 1.64, 1.17 and 0.746·10⁻⁵ (j = 13);
  * shares 0.475/0.423 and 0.315/0.249;
  * deficiencies of 5,346 and 1,292 bits;
  * J_e < Φ₂ on (0, c_env];
  * the three-hypothesis threshold 1.876·10⁻⁴.

  The e₁ table comes from the relaxed bound for c ≥ 2^{−m}, not from the displayed R̄₁. The values are valid but weaker, and the source should be stated (**P2M-17**). The verdict "the extension ... is false" is supported.
* **Rate blindness and the robust lemma.**
  * Rate blindness (i)-(iii): correct.
  * Lemma, part (i): the identity H·F(d) = difference of the two sides, and the side condition, are re-derived.
  * Parts (ii)-(iii): correct.
  * The d₀ table is reproduced in all 30 cells. My first run was off in the m = 4, 6, 7 rows because lgamma round-off pushed ⌈L_S⌉ up by 1 when L_S is an integer. After guarding that, everything agrees.
  * The 3-bit rule at d = 100 holds for κ ≤ 10 and fails for κ ≥ 20.
  * The three-hypothesis margins are 9.56 and 1.39 bits, and the 8-bit prefix leaves a window.
* **Other pathologies:**
  * Separable components: correct.
  * Guard erosion: correct, including H_G, g, Δ_G, ρ_σ, ρ_G, factor 67.5 and the crossing 3.2032·10⁻⁴. A minor point: the hull lemma is applied to shifted, negative risks (**P2M-21**).
  * Non-identifiability: correct, with the c-path losses 1.0, 0.0112, 0.0112, 0.
  * Input law: correct.
* **Unseen properties (`prop:limits:ood`).** The proof is correct. "The programs ... carry exactly" should be "a family ... carries exactly" (**P2M-12**).
* **`rem:limits:method`.** Reproduced p < 0.1233, the order √(H/p) of the deviation term, and the large-level floor at p < 0.1525.

## 5. The model-randomness split (`split.tex`, `app-split.tex`)

* **Ville lemma.** Correct. The supermartingale argument holds for adaptive and randomised input rules.
* **Stream-prefix lemma (Lemma 3.2′).** Re-proved in full:
  * the length-lexicographic index bound 2^{d+1} − 2;
  * the Cantor pairing bound ⟨j, i−1⟩ < (j+i)² ≤ (2^{d+1}+i)², which is tighter than the notes' version and correct;
  * the certification interval inclusion;
  * nested-interval consistency;
  * the uncertified mass ≤ 3·2^{−i};
  * 3·2^{−i_D} ≤ β_D/(2n);
  * Bernoulli's inequality giving ≥ ν(D)/2;
  * 2^{2^t} ≥ (2^{d+1}(i+1))²;
  * the program count 2^{−k−2log(t+1)−|r|−2}.

  Reproduced costs:
  * stream prefixes: 5.61 bits (d = 20), 6.34 (d = 100, both values of β), 7.17 (d = 1000) and 8.92 (d = 10⁶);
  * hashing: 31.9, 56.3, 60.1, 106.6 and 142.7 bits. The last two use different r (106.6 at r = 10, 142.7 at r = 2), which the text does not state. This is harmless.
* **Hashing lemma.** Correct: exact recovery of dyadic values, the Vandermonde bijection, and one program per seed.
* **`thm:split:lambda1` and `prop:split:si`.** Both correct. The phrases "do not depend on how much randomness was sampled" and "whatever the sampled randomness" overstate. The lower end depends on β_n, triply logarithmically in −log ν(D_n) (**P2M-10**).
* **`thm:split:private`.** Correct:
  * (i), (ii) and (iii) re-derived, including the λδ* exponent of (iii) and the tempered bound;
  * (iv): the Hellinger supermartingale, predictability of g_n, countably many programs, and the posterior split at length L.
* **`thm:split:shared`.** Correct. The "predictively both converge ... by the merging theorem" remark cites a λ = 1 theorem for M_F. It holds for fixed λ by the same dominance argument and should say so (**P2M-11**).
* **Noisy-parity example.** Consistent with the track's output: −log ν = 2218.0, −log U = 2234.0, threshold 16.0/12.2 = 1.311 from rounded values against 1.315 unrounded. It is correctly presented as an illustration.

## 6. Algorithmic statistics (`algstat.tex`, `app-algstat.tex`)

* **Sets and products.**
  * `prop:algstat:set`: correct, including existence and the refuted reading.
  * `prop:algstat:product`: correct.
  * `prop:algstat:coarse`: correct, including y_D ∈ A, |A| ≤ 2^ρ and the +1 absorbed into κ.
* **The noisy parity (`prop:algstat:parity`).**
  * (i): injectivity for p < 1/4, K(A₀), and K(z) via minimum-distance decoding and symmetry of information. The main text claims flatness "from α = O(log d) on", while the proof covers only α ≤ d + O(log d) (**P2M-16**).
  * (ii): correct. The memoriser's K(z | d) ≤ d + NH(p) + 2 log N + κ is valid with s₀ given through r.
  * (iii): correct.
  * (iv): correct. The level bound comes from (D1); the sharp floor with I < d + κ gives F_t.
* **The table.** It reproduces only with "the least admissible g", not "the best (t, g)". Optimising g gives b-ranges about 3 times larger and F₂ − H between 0.034 and 0.209, not between 0.016 and 0.064 (**P2M-06**). The κ = 30 rows use 2κ in j_d (**P2M-07**). The printed intervals are valid.

## 7. Computable versions and related work (`related.tex`, `app-related.tex`)

* `prop:related:computable`: the inspection is correct.
* `prop:related:computability`: the diagonal argument for raw and normalised conditionals, and limit computability, are correct.
* The cold-posterior direction, the NN-Bayes remark and the T5 correspondence are consistent with the notes. The rigorous d = 20 value c_hi = 0.01139 against T5's heuristic 0.049 is reproduced.
* `rem:related:mdl` attributes "bounded λ overfits; λ must grow" to the cited work and does not claim it as new. Its last sentence, however, says "we do not claim that a fixed λ eventually learns the errors", which contradicts `prop:limits:plain`(b) (**P2M-20**).

## 8. Notation

Several symbols are overloaded across sections, sometimes inside one proof: ρ, r, a, b, g, k and q (**P2M-23**).

---

## Numbered issue list

Severity: fatal = false or unsupported mathematical claim, or a claim stronger than the sources; major = missing hypothesis, wrong number, inconsistency, misleading framing, or a reader cannot follow; minor = local wording or formatting. The full text of each item (problem, evidence and fix) is in `issues-p2-math.json`.

**P2M-01 (fatal)**
* **Where:** `setup.tex` line 89, the paragraph after `lem:setup:coding`.
* **Problem:** the paragraph claims that "the mixture" attains the coding bound K(y_D|dom D) + O(1) on every data set in a class containing its own mixture. This is false for M_F and M^w. Evidence: foundations Example 6.4, and the binary swap argument, under which no weak function semimeasure can attain it.
* **Fix:** say "attains the class's best two-part length min_π [ℓ(π) − log P_π(D)] up to ℓ_U + κ₀".

**P2M-02 (fatal)**
* **Where:** `absorb.tex`, `cor:absorb:nouniversal`.
* **Problem:** "(Dom) fails in every product class" is false; a one-program class satisfies (Dom). It is also stronger than the source, which concerns the canonical class.
* **Fix:** restrict the claim to H_× and to classes that contain parity programs of length o(2^d).

**P2M-03 (major)**
* **Where:** `limits.tex`, `prop:limits:plain`(b) and `rem:limits:schedule`; also intro line 18.
* **Problem:** "λ_n/n → 0 ⇒ the errors are eventually reproduced" is false at a fixed instance. For λ_n = n^{0.9} at Hänni's sizes, e ≤ 0.43 to 0.27 holds with probability ≥ 0.99 for all n ∈ [10²³, 2^{100}].
* **Fix:** require (λ_n/n)(d + L_S) → 0, or state the result along a family of instances with d growing.

**P2M-04 (major)**
* **Where:** `absorb.tex`, `thm:absorb:absorption`(c); also intro and discussion.
* **Problem:** the theorem does not say "λ fixed". (c1) has no meaning for λ = λ_n, and (c3) can fail for λ = cn (sketch in the JSON).
* **Fix:** add "λ > 1 fixed" and propagate it to the intro and discussion.

**P2M-05 (major)**
* **Where:** `teacher.tex` line 105, and the abstract.
* **Problem:** "gives the erroneous labels little probability" is unqualified. The bound is 0.20-0.29 at Hänni's sizes and vacuous when s₀ is small, as in Version 1.
* **Fix:** quantify.

**P2M-06 (minor)**
* **Where:** `app-algstat.tex`, `tab:algstat:numbers` and its text.
* **Problem:** the table uses the least admissible g, not "the best (t, g)". The quoted F₂ − H range of 0.016-0.064 belongs to that g; with optimised g it is 0.034-0.209.
* **Fix:** reword, or recompute with optimised g.

**P2M-07 (minor)**
* **Where:** `tab:algstat:numbers`, κ = 30 rows.
* **Problem:** computed with 2κ in j_d, while the printed formula has κ. The d = 20, p = 15/64 upper end is 5.6·10² by the printed formula, against 8.1·10³ in the table.
* **Fix:** recompute the rows, or print the 2κ.

**P2M-08 (minor)**
* **Where:** `tab:teacher:numbers`(b), κ = 30, c2^m = 0.99.
* **Problem:** (iii) does not apply there; it needs c < 0.98914·2^{−m}.
* **Fix:** print "—" and give the κ = 30 thresholds (0.989 and 0.888).

**P2M-09 (minor)**
* **Where:** `app-teacher.tex` line 216.
* **Problem:** "−1000 + 242.3" should be "−1000 + 241.7 = −758.3".

**P2M-10 (minor)**
* **Where:** `split.tex`, the section introduction and `thm:split:lambda1`(iii).
* **Problem:** "do not depend on / whatever the sampled randomness" is too strong. The lower end depends on β_n, triply logarithmically.

**P2M-11 (minor)**
* **Where:** `split.tex` line 97.
* **Problem:** "both converge ... by the merging theorem" cites a theorem about M_F at λ = 1.
* **Fix:** say "for fixed λ, by the dominance argument of the merging theorem".

**P2M-12 (minor)**
* **Where:** `prop:limits:ood`(i).
* **Problem:** "the programs ... carry exactly" should refer to a specific family; all such programs together carry at least this mass.

**P2M-13 (minor)**
* **Where:** `app-absorb.tex`, the value part of `prop:absorb:pricing`(i).
* **Fix:** add a density remark to pass from all ν to lsc ν.

**P2M-14 (minor)**
* **Where:** `thm:absorb:absorption`(a) and `thm:split:shared`(i).
* **Problem:** both need U(o) > 0 in the statement.

**P2M-15 (minor)**
* **Where:** `prop:teacher:concentration`.
* **Problem:** needs λ = cn ≥ 1.

**P2M-16 (minor)**
* **Where:** `prop:algstat:parity`(i).
* **Problem:** the main text claims flatness "from α = O(log d) on", but the proof stops at d + O(log d).
* **Fix:** align the main text with the proof, or add the one-line extension.

**P2M-17 (minor)**
* **Where:** `app-limits.tex`, the e₁ table.
* **Problem:** the values come from the relaxed bound for c ≥ 2^{−m}. The displayed R̄₁ gives 0.879/0.587 at c = 1.01·2^{−m}.
* **Fix:** say which bound the table uses.

**P2M-18 (minor)**
* **Where:** `app-teacher.tex`, the Version 1 finite-sample sentence.
* **Problem:** the bound 0.308 uses Λ₁(∞) without saying why that is legitimate.
* **Fix:** justify it via (D1) with 2 log d + κ.

**P2M-19 (minor)**
* **Where:** `prop:limits:plain`(a).
* **Problem:** the displayed κ_b (with 2 log s₀) is inconsistent with "O(log dm)".
* **Fix:** say that s₀ is given through r, as the appendix does.

**P2M-20 (minor)**
* **Where:** `rem:related:new`.
* **Problem:** "we do not claim that a fixed λ eventually learns the errors" contradicts `prop:limits:plain`(b).
* **Fix:** write "not claimed as new".

**P2M-21 (minor)**
* **Where:** `app-limits.tex`, guard-erosion proof.
* **Problem:** the hull lemma is applied to negative, shifted risks, outside its hypothesis R ∈ [0, ∞].
* **Fix:** note translation invariance, or use the unshifted risks.

**P2M-22 (minor)**
* **Where:** `app-teacher.tex` line 198.
* **Problem:** 61.9 and 39.6 are truncated; to nearest they are 62.0 and 39.7.

**P2M-23 (minor)**
* **Where:** notation across sections.
* **Problem:** ρ, r, a, b, g, k and q are overloaded.
* **Fix:** rename locally.

**P2M-24 (minor)**
* **Where:** `rem:absorb:wyeth`(i).
* **Problem:** "samplers longer than about ℓ_U are never selected" is accurate only for λ away from 1. The exact threshold is ℓ*_λ = ℓ_U + (ℓ_U + κ₀)/(λ − 1).

## What I checked and found correct (no issue)

The following statements were checked and found correct, each as described in sections 1-7 above:
* the definitions;
* `lem:setup:basic`;
* hull (i)-(iv) and its examples;
* the coding bound;
* (Dom) for H_F, H_w, H_SI and H_chr;
* absorption (a), (b) and (d), and (c) for fixed λ;
* pricing (i)-(iii) and the value 2.5431;
* `rem:absorb:condsemi`;
* the price of private randomness (i)-(iv), with 0 violations in my randomized check;
* both history propositions;
* every lemma of sec. 4 and app. C, including the sharp floor;
* the teacher's-mistakes theorem (o)-(iv);
* the full-table, finite-sample and concentration statements;
* Version 1;
* all of sec. 5 except the items above;
* Ville, the stream prefixes, hashing, and Theorems 3-5 of the split;
* the SI proposition;
* the noisy-parity example (as an illustration);
* every proposition of sec. 6;
* computability and the computable-class transfer.

The numbers reproduced exactly are listed in sections 3-6.

---

## 9. Second independent pass (additional findings, P2M-25 to P2M-42)

**How this pass was done.**
* A second reviewer read every body section and appendix in scope against `research/tracks/steeper/notes-final.md`, working independently of sections 1-8.
* Every proof was re-derived, and every printed number was recomputed with separate code written from the paper's formulas. The scripts are in `research/paper-review/scratch/p2-math/`, alongside the first pass's scripts:
  * `v1_teacher.py`: sec. 4 and app. C;
  * `v2_limits.py`: sec. 5 and app. D;
  * `v3_split_algstat.py`: pricing, stream and hashing costs, the envelope e₁ under the relaxed bound, and the table of `prop:algstat:parity`(iv) with optimised g;
  * `v4_extra.py`: the teacher's-mistakes theorem for the envelope rules, and the finite-sample corollary at n = 10⁶ to 10¹⁰;
  * `v5_hull_price.py` and `v5b_hull_exact.py`: the price inequality, with 0 violations in 9,156 checks, and an exact rational check of hull (iii), with 0 mismatches in 17,588 point tests.
* The new items were appended to `issues-p2-math.json` by `make_issues_p2_math_add.py`. The first pass's files are preserved unchanged in `scratch/p2-math/first-pass-backup/`.

**Agreement with the first pass.**
* This pass found 11 of the first pass's issues independently: P2M-01, -02, -06, -08, -12, -14, -15, -16, -17, -22 and -24.
* It checked and confirms P2M-03, -04, -05, -07 and -09:
  * P2M-03: for λ_n = n^{0.9}, λ_n/n ≥ 2⁻¹⁰ for every n ≤ 2^{100}, and the bound of `prop:limits:plain`(b) is 0 throughout.
  * P2M-07: with κ entering j_d once, as printed, the d = 20, p = 15/64, κ = 30 upper end is 559 at g = 6.
  * P2M-09: J_g(10⁻⁴) = 0.023167, so (J_g + ε)/c = 241.67.
* It reproduces every number listed in sections 3-6. One addition: for d = 13 the end points are c_hi·2¹³ = 61.99 and 39.68 (P2M-22).
* On the envelope e₁ table (P2M-17): the printed values are reproduced exactly by the relaxed bound with K(S₁) ≤ 2 log(j+1) + 2 log m. The displayed R̄₁ with K(S₁) ≤ 2 log(j+1) gives 0.889 (j = 11) and 0.615 (j = 13) at c = 1.01·2^{−m}.

**New findings, in brief.**
* **The full-table corollary (P2M-25, major).** Part (ii), "at λ = 1 the optimum, J₁(π_g) and J₁(π_b) lie within O(log N) + δ_E", is stated for every admissible p. Its proof bounds level-≥2 programs only through N·G₁ > J₁(π_g), which needs G₁ > H(p), that is p < 0.056. At p = 1/16, G₁ = 0.2996 < H(p) = 0.3373. The statement is true for every p < 1/4 by the coding bound together with minimum-distance decoding, which covers all levels at once. The proof should use that argument. The notation J₁ also clashes with the per-sample J_c of the section.
* **The envelope rule is covered by the main theorem (P2M-26, major).** The parenthesis "Its deficiency is about 1,300 bits, so thm:teacher:main does not cover it; above c_env nothing is proved for it" is false. The theorem holds for every error rule, with δ_S as a parameter. For the j = 13 rule, with δ_S about 1,260-1,310, at c = 10⁻⁴ and κ = 0 it gives u ≥ 0.983, ℓ ≤ d + 33, I ≤ 50 and e ≤ 0.71. The source's "vacuous for the error label" concerns the j = 11 rule, with δ_S about 5,300; there my e-bound is 1.38.
* **Power-prior posterior versus fractional posterior (P2M-27, major).** Π_λ ∝ 2^{−λℓ}P is not the generalised/fractional posterior with learning rate 1/λ; that is Π^{1/λ}. The two share their maximiser, and Π_λ ∝ (Π^{1/λ})^λ. The paper's posterior theorems are about Π_λ. The identification is made in `setup.tex` line 48 and `rem:related:posteriors`, and repeated in the intro and discussion.
* **Minor items.**
  * The finite-sample framing "needs about 10¹¹ samples" contradicts the appendix's n = 10⁹ row. At c = 10⁻³ and n = 10⁸ the corollary already gives u ≥ 0.90, ℓ ≤ d + 43 and e ≤ 0.31 (P2M-28).
  * ν_len is defined differently from the companion paper (P2M-29).
  * Y = {0,1} is not stated in the teacher's instance (P2M-30).
  * The stated reason for {J_g ≤ Φ₂} = (0, c_hi] is wrong (P2M-31).
  * The identification window is closed at c_hi but should be open (P2M-32).
  * The kink is stated with only its lower side (P2M-33).
  * "Removes his constant lower bound" overstates what is shown (P2M-34).
  * "Exceeds by cℓ" should be "at most" (P2M-35).
  * NN memorisers should be qualified as deterministic (P2M-36).
  * "No program ... is optimal" overstates "beaten or tied", and "about 8000" should be 8453 (P2M-37).
  * The conjunction-ladder framing conflicts with the companion paper's `rem:comp:uniformties` (P2M-38).
  * The m = 24 number omits its δ_S (P2M-39).
  * The (Dom) wording in `thm:split:shared`'s scope sentence is wrong (P2M-40).
  * The intro's "not a fill-in once the sampled randomness is larger" has no threshold (P2M-41).
  * Hull (iv) should say "open" ray (P2M-42).

### Numbered issue list, continued

The full problem, evidence and fix for each item are in `issues-p2-math.json`.

**P2M-25 (major)**
* **Where:** `teacher.tex`, `cor:teacher:fulltable`(ii) (line 153), and `app-teacher.tex` line 134.
* **Problem:** the hypothesis p < 0.056 and N(G₁ − H(p)) > d + κ_g + log(N+1) is missing. A counterexample to the proof step is p = 1/16.
* **Fix:** prove the lower bound on the optimum by `lem:setup:coding` with minimum-distance decoding, which works for every p < 1/4, or add the hypothesis. Write J₁(π;D) for the two-part length.

**P2M-26 (major)**
* **Where:** `limits.tex` line 44.
* **Problem:** the claim that the theorem "does not cover" the j = 13 envelope rule and that "above c_env nothing is proved" is false. The theorem gives u ≥ 0.983, ℓ ≤ d + 33 and e ≤ 0.71 at c = 10⁻⁴.
* **Fix:** state these weaker bounds and say what remains open.

**P2M-27 (major)**
* **Where:** `setup.tex` line 48, `related.tex` line 39, intro line 50 and discussion line 67.
* **Problem:** the power-prior posterior is not a fractional or generalised posterior with η = 1/λ. Only the tempered Π^{1/λ} is, and the two share their maximiser.
* **Fix:** correct the identification.

**P2M-28 (minor)**
* **Where:** `teacher.tex` lines 164 and 183, intro line 52 and discussion line 75.
* **Problem:** "needs about 10¹¹ samples" is inconsistent with the appendix's n = 10⁹ row. Nontrivial guarantees hold from n of about 10⁸.
* **Fix:** reword.

**P2M-29 (minor)**
* **Where:** `app-absorb.tex` line 67.
* **Problem:** ν_len is defined differently from Paper 1, which uses ω_{|x|+1}.
* **Fix:** align with Paper 1, or rename the law σ.

**P2M-30 (minor)**
* **Where:** `def:teacher:instance`.
* **Fix:** add "Y = {0,1}".

**P2M-31 (minor)**
* **Where:** `teacher.tex` line 72.
* **Problem:** the reason given for {J_g ≤ Φ₂} = (0, c_hi] is wrong. The correct reason is that J_g minus each piece is increasing; non-emptiness needs G₁ > H(p).

**P2M-32 (minor)**
* **Where:** `cor:teacher:fulltable`.
* **Problem:** the identification window should be open at N·c_hi, but the numbers print it closed.

**P2M-33 (minor)**
* **Where:** `prop:algstat:parity`(ii) and (iv).
* **Fix:** state the upper side of the kink, ρ^×_D(α) ≤ N·H(p) for α ≥ d + κ_g.

**P2M-34 (minor)**
* **Where:** `limits.tex` line 95.
* **Problem:** only the lower bound vanishes; the probability is not shown to vanish.
* **Fix:** reword.

**P2M-35 (minor)**
* **Where:** `rem:limits:schedule`.
* **Fix:** "exceeds ... by **at most** cℓ(π) bits per sample".

**P2M-36 (minor)**
* **Where:** `rem:related:nn`.
* **Problem:** the bound covers only deterministic memorisers.

**P2M-37 (minor)**
* **Where:** `limits.tex` line 61.
* **Problem:** "is optimal at any c" should be "is the unique optimum at any c". "About 8000" should be "about 8500 (8453)".

**P2M-38 (minor)**
* **Where:** `app-limits.tex` line 143.
* **Problem:** the conjunction ladder illustrates deterministic tie-breaking, not the posterior, which is the companion paper's reading.

**P2M-39 (minor)**
* **Where:** `rem:teacher:numbers`.
* **Fix:** give δ_S = 0 for the m = 24 bound (0.065), and add 0.084 at κ = 30.

**P2M-40 (minor)**
* **Where:** `thm:split:shared`, scope sentence.
* **Problem:** (Dom) does hold in H_SI. What fails is that the sampler has no program in H_SI.

**P2M-41 (minor)**
* **Where:** intro line 23.
* **Fix:** give the threshold λ(k + δ*)/(λ−1) on −log ν(D_n).

**P2M-42 (minor)**
* **Where:** hull (iv).
* **Fix:** "open horizontal ray".

### What the second pass also checked and found correct

The following were re-derived independently and found correct, with nothing to add:
* every lemma of sec. 4, including the sharp floor's two-sided counting;
* the teacher's-mistakes theorem (o)-(iv);
* Ville;
* the stream-prefix lemma, including certification, consistency, the 3·2^{−i} loss and the 2^{2^t} length;
* hashing;
* Theorems 3-5 of the split;
* the SI proposition;
* the price inequality;
* both history propositions;
* `prop:related:computability`;
* every number in Tables `tab:teacher:numbers`(a) and (b), the d₀ table and the guard-erosion and non-identifiability numbers;
* Version 1 at κ = 0, 5, 10, 20 and 30.
