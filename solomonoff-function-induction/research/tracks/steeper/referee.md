# Referee report: track "steeper" (`notes.md` and `checks/`)

*Adversarial referee, second run (2026-10-12).*

**What I read.**
* The brief, and the H9 sources: `prior/hanni-grokking-a-notion.md`, `prior/hanni-lesswrong-comment-thread.md` and `prior/hanni-sfi-notes.md`.
* T5, `../../inferential-learning/research/theory/T5-steeper-simplicity-and-normativity-from-imitation.md`, in particular Thm 2.5, Lemma 2.5c, Prop 4.4 and Prop 4.5.
* The foundations notes that the track cites as "F".
* `notes.md` in full, and the scripts in `checks/` with their saved outputs.

**What I did.**
* I checked every proof tagged **proved**, line by line.
* I wrote new, independent code in `referee_code/q1`–`q4`. It is seeded or deterministic, and its outputs are saved next to the scripts.
* I searched the literature with WebSearch (snippets only).
* I did not edit the notes.

**Earlier material.** A referee report from the first run of this workflow existed. I preserved it as `referee-run1.md`, and its scripts `referee_code/r1`–`r6` are untouched. I formed my own view before reading it.
* Where my findings coincide with it, I say so and give my own evidence.
* Two of my major issues are new: M1 (prior work on λ-weighted two-part MDL in classification) and M3 (the trick depends on the error rule being incompressible).

**Scripts changed since `notes.md`.** `checks/c3` and `c5` were edited after `notes.md` was written (20:32–20:35), and `checks/c6` and `checks/t5_rerun/` were added then. I review `notes.md` against the scripts as they now stand. Where a quoted number differs from the current outputs, I say so.

---

## Verdict

* **No fatal errors.** Every theorem I checked is true as stated, up to the explicit machine constant κ: Theorem 1, Prop 1.3/Cor 1.4, Lemmas 2.1–2.4, Theorem 2 (o)–(iv), Lemma 2.6, Prop 2.8, Prop 2.9, Theorems 3–5, Props 3.5–3.8 and Props 4.1–4.2.
  * The proofs are careful.
  * Every number I recomputed matches, with one exception (minor 1).
* **Four major issues.** None of them is an error in a proof. Each concerns what the results are said to establish.
  * **M1.** Directly relevant prior work on λ-weighted two-part MDL and Bayes in supervised classification is missing. The novelty claims and the answer to Hänni's "have people not already considered this?" depend on it.
  * **M2.** Wyeth's objection is not answered explicitly, although the brief requires it. "At λ = 1 nothing is lost" is false relative to $M_F$.
  * **M3.** Theorem 2 works only if the error rule is algorithmically incompressible given the model ($\delta_S\approx0$). Every numerical claim sets $\delta_S=0$ without saying so. The §5 verdict "Confirmed … in his example" overstates. For an error rule with the same density but a cheap structured half, the learner provably does not select the good model across most of the window (q4 (C)).
  * **M4.** Several "never selected" or "defeats the trick" verdicts are tagged proved or computed, but they hold only with κ = 0, or they treat upper bounds on program lengths as exact lengths.
* **About twenty minor issues** are listed below, with evidence and fixes.

---

## Major issues

### M1. Missing prior work on steeper (λ > 1) two-part codes and Bayes in classification

**Claim.**
* §3.6 lists as new "steeper simplicity analysed in function induction with *private* randomness".
* §5 answers Hänni's "have people not already considered this for solving the model + data split problem?" with "Partly … The product/private-randomness split appears not to have been studied (search-level check only)".
* §2.5 and §4.4 present "a fixed λ eventually learns the errors; λ must grow with N" as a finding.

**Problem.** The λ-weighted two-part MDL rule for binary classification has been studied directly. Its hypotheses are a classifier plus a label-noise code, which is a product hypothesis with private noise.
* **Zhu & Srebro, COLT 2025.** "Quantifying Overfitting along the Regularization Path for Two-Part-Code MDL in Supervised Classification", PMLR 291:6124–6155; arXiv 2503.02110.
  * Bibliographic data verified by search. Content seen in snippets only.
  * Per the snippets: it characterises the whole regularisation curve of a "modified two-part-code MDL rule" with penalty λ on the prior code length, for any prior.
  * It extends Grünwald–Langford's λ = 1 inconsistency to all λ, as a worst-case limiting error that depends on λ and on the noise level.
  * It notes that $\lambda_m\asymp\sqrt m$ gives SRM-type consistency.
* **Zhu, Ohannessian & Srebro, arXiv 2603.22644 (March 2026).** "Overfitting and Generalizing with (PAC) Bayesian Prediction in Noisy Binary Classification".
  * Bibliographic data verified by search. Content seen in snippets only.
  * Per the snippets: the standard Bayesian predictor can overfit; "any bounded λ leads to harmful overfitting"; consistency requires λ to grow with the sample size.
  * This is the power-posterior side, i.e. the notes' $\Pi_\lambda$ and Prop 2.8.
* **Grünwald & Langford.** "Suboptimal behavior of Bayes and MDL in classification under misspecification", *Machine Learning* 66:119–149, 2007; COLT 2004 version.
  * Verified bibliographically.
  * It shows that λ = 1 MDL and Bayes are inconsistent for classification under misspecification.
* **Barron & Cover 1991.**
  * A secondary source (snippet) states that their two-part-code consistency theorem needs the prior to satisfy $\sum_\theta w(\theta)^\eta<\infty$ for some η < 1. For code lengths this is $\sum2^{-\eta L}<\infty$, i.e. a multiplier $1/\eta>1$ on a Kraft code length.
  * So λ > 1 two-part codes are classical in MDL. Unverified against the paper; the notes already flag that they could not check it.

These papers do not study teacher's mistakes, the shared-versus-private contrast, or Kolmogorov-complexity hypothesis classes. But they study the same objective, over a product-type hypothesis class, with the same qualitative finding:
* a bounded λ fits the noise eventually;
* λ must grow with the sample size.

They also use a different growth rate ($\sqrt m$) from Hänni's $\lambda=cN$, which the notes adopt without discussing alternatives.

**Evidence.** WebSearch results for the four items above (titles, venues and abstract-level statements); see the references table.

**Fix.**
* Cite these works with an honest status: bibliographic data verified, content per abstract.
* Restate what is new. The plausible candidates are:
  * the contrast between shared and private randomness, with the universal element (Thm 1 versus Cor 1.4 and Remark 1.5);
  * the all-hypotheses, Kolmogorov-complexity analysis via list decoding (Thm 2);
  * the teacher's-mistakes framing and its limits;
  * the model-versus-randomness theorems (Thms 3–5);
  * the product algorithmic-statistics notions.
* Remove "fixed λ must fail" from the list of findings, or credit it.
* Discuss $\lambda=cN$ against $\lambda\asymp\sqrt N$. Under $\lambda=cN$ the learner is deliberately not consistent for the teacher's channel; it pays $c\,\ell$ per sample. Say so.

### M2. Wyeth's objection is not answered explicitly, and the cost of the answer is understated

I independently agree with M2 of `referee-run1.md`.

**Claim.**
* The brief: "The paper must answer Wyeth's objection explicitly."
* §1.6: "At λ = 1 nothing is lost: $M_{\rm prod}$ already dominates every product hypothesis."

**Problem.**
* *No explicit answer.* `grep -i wyeth notes.md` returns nothing. All the ingredients are present but never assembled into an answer:
  * Theorem 1 is his objection made exact, for SI and for shared-randomness SFI.
  * Cor 1.4 and Remark 1.5 explain why it fails for private randomness.
  * Prop 4.1 shows where it returns.
  * §3.5 is the algorithmic statistics he points to.
* *The cost is understated.*
  * Steeper SFI is defined over product hypotheses, so at λ = 1 it is $M_{\rm prod}$, not $M_F$, the predictor the foundations track recommends.
  * F Prop 4.5 shows that $M_F/M_{\rm prod}$ is unbounded, already against an O(1)-complexity shared-randomness law (one coin per input length).
  * So restricting to private randomness gives up dominance over every law with a shared latent cause, such as a labeller's persistent mood or a per-batch coin. "Nothing is lost" is true only relative to the product class.
* *The reason for the restriction should be stated.* The restriction looks ad hoc unless the text gives the reason it already has: Hänni's dominance template is stated against x-only samplers with separate randomness per input (`prior/hanni-sfi-notes.md`, "use different bits of randomness … for sampling on different inputs").

**Fix.** Add a subsection, "Answer to Wyeth's objection", with four parts:
* (i) Theorem 1 as his point, exact for SI and $M_F$;
* (ii) Cor 1.4, Remark 1.5 and Prop 4.2 as the reasons it fails in the product class;
* (iii) the price, F Prop 4.5, and the return of absorption with labelled history (Prop 4.1);
* (iv) the algorithmic-statistics reading (Prop 3.8).

Replace "nothing is lost" with the exact statement.

### M3. The trick needs the error rule to be incompressible given the model; this hypothesis is hidden and the §5 verdicts overstate

**Claim.**
* §0: "*A rigorous instance with his numbers* (Thm 2) … every near-optimal hypothesis holds at most a few dozen bits of information about the error rule … gives the teacher's erroneous label average probability at most ≈ 0.20–0.27".
* §5, row 2: "**Confirmed** … in his example the selected hypothesis is the good model (Thm 2)".
* §5, row 3: "**Settled** for the instance".

**Problem.** Theorem 2 is correct. Its deficiency $\delta_S=L_S-K(S\mid a,K(a))$ enters every slack term: Λ₂, Δ(c), $\Delta_\ell$ and $\Gamma_g$.
* All numerical conclusions (§0, Thm 2, Cor 2.5, Cor 2.7, the c3 tables) set $\delta_S=0$, and none says so. `checks/c3` uses `deltaS=0.0` throughout.
* The justification, "most S have small deficiency", is a statement about a *uniformly random* error rule.
* Hänni's case is "systematic human error". T5 itself stresses the opposite case: "Real systematic errors are the opposite case: they are low-complexity patterns" (T5 Prop 4.5, *error envelopes*). The track lists Prop 4.5 under "not reused".
* So the theorem shows that the trick works for incompressible junta error rules. It does not show it for Hänni's example, which fixes only a density and a description length.

**Evidence.**
* `referee_code/q4_absorption_and_regimes.out`, part (C), takes Hänni's density with a different structure:
  * $p=2^{-10}$, $d=100$, $m=20$, $|S|=1024$;
  * $S=S_{\rm cheap}\cup S_{\rm rand}$, where $S_{\rm cheap}=\{z:z_1..z_{11}=0\}$ (512 points, about 9 extra bits) and $S_{\rm rand}$ is 512 random points;
  * κ = 0, explicit product hypotheses.
* Results:
  * The "envelope" hypothesis (good model plus "flip on the cheap subcube") has $\ell=d+28.9$ and $R=0.00608$.
  * The good model has $\ell=d+19.9$ and $R=0.01117$.
  * So the envelope beats the good model for every $c<5.7\cdot10^{-4}$, while the full memoriser wins only below $9.5\cdot10^{-7}$.
  * Over almost all of the nominal window, therefore, the good model is not selected. The better hypothesis gives the teacher's error label average probability 0.50 on E. The good model gives 0.001.
* Theorem 2 is not contradicted. Here $\delta_S\approx5300$ bits, and its bounds degrade accordingly.
* `q1_constants.out` [D] shows that even modest deficiencies move the stated bounds. With $\delta_S=20$:
  * at Cor 2.5, λ = 2: e ≤ 0.251 instead of 0.220, and the information bound is 90.8 instead of 70.8 bits;
  * at Thm 2, c = 10⁻⁴: e ≤ 0.218 instead of 0.199.

**Fix.**
* State $\delta_S$ in every numerical claim.
* Define the information bound, $I:=B_S-K(S\mid a,\pi)\le\Delta_\ell+\Lambda_3$, and say what it is relative to.
* Re-derive T5 Prop 4.5 (error envelopes) as a limit next to Prop 2.11. It is the general form of q4 (C).
* Reword §5:
  * "Confirmed for error rules that are incompressible relative to the model (junta instance, uniform inputs, parity model, $p<0.056$)";
  * "Refuted for error rules with a cheap high-rate part (envelopes)";
  * "Open in general".
* Also list the other hypotheses of Theorem 2 that the instance relies on:
  * a list-decodable model class (parities);
  * the product structure $E=S\times\{0,1\}^{d-m}$, which Lemma 2.3 needs to code S with $2^mR_B$ bits; for an unstructured E this becomes $2^dR_B$, which is useless;
  * uniform inputs;
  * $p<0.056$.

### M4. Numerical verdicts tagged proved or computed that hold only at κ = 0, or only for upper-bound lengths

I agree with M1 of `referee-run1.md`, with independent evidence.

**Claim.**
* §0, 2(b): "With machine constants set to 0, a 3-bit error rule on 1/8 of the inputs, or a 6-bit one on 1/64 at d ≥ 1000, defeats the trick for every λ. This is proved over all hypotheses."
* Prop 2.11 [proved; computed: c3], Examples: "A single 7-bit error prefix … satisfies (i): the good model is never selected. A 6-bit one … satisfies (i) at d = 100."

**Problem.**
* (a) Prop 2.11(ii)'s implication is proved. Whether its hypothesis holds at given (d, m, p) depends on κ. `q1_constants.out` [H]:
  * d = 100, m = 3 fails for κ ≥ 20;
  * d = 1000, m = 6 fails at κ = 30.
  
  A larger d (300 and 3000 respectively) makes both robust up to κ = 30.
* (b) Prop 2.11(i) is about the *exact* lengths of three programs. The examples insert the upper bounds $d+\kappa_g$ and $d+\lceil L_S\rceil+\kappa_b$. The m = 7 verdict rests on rates of 9.42·10⁻³ (memoriser) against 7.86·10⁻³ (coin) in c3. It flips if $\ell_b-\ell_g$ is 1.4 bits longer than the upper-bound difference used, which is well inside the O(log d) uncertainty. So (i)'s verdicts are not established for any κ.

**Fix.**
* Tag the instances as "illustration at κ = 0".
* Give the robust form: for fixed (m, p), the inequality of (ii) holds for all d ≥ d₀(κ), since its left side decays like 1/log d and its right side like 1/d. Give d₀.
* Drop "proved" from (i)'s examples, or restate them with explicit, fixed code lengths in a computable class.

---

## Minor issues

1. **Prop 2.8 example exponent.**
   * The notes give "a ratio of at most $2^{-776}$ (c5(e))". From the notes' own formula, $J_g=c(d+\kappa_g)+H(p)=0.02317$ at κ = 0, so the exponent is $-758.3$ (`q1_constants.out` [F]). The current `c5_limits.out` also prints −758.
   * −776 would need $\ell(\pi_g)=d$, i.e. $\kappa_g=0$. Fix the number.
2. **Lemma 3.2: the sum over seeds can double-count.**
   * The proof sums $2^{-\ell(\varphi_s)}$ over consistent seeds s. Def 1.3's universality only guarantees *one* program per function of length at most $K(\cdot)+\kappa$, and distinct seeds often give the same function.
   * `q3_split.out` (A):
     * n = 2, r = 4: 4096 seeds give only 16 distinct functions;
     * n = 3, r = 3: 512 seeds give 169 functions.
   * Exactness of $\Pr_s[\varphi_s\supseteq D]=\nu(D)$ is confirmed with 0 error in all cases.
   * *Fix.* Define $\Pi_\times$ by a universal prefix machine with the simulation property: $V(rq)=V'(q)$, so that distinct seed strings are distinct programs (F's W uses this). Alternatively, apply the conditional coding theorem to the seed-induced semimeasure on truth tables.
   * Separately, (F1)'s proof text, "read input bits until the string read so far is enumerated in Π", hangs on prefixes that are not in Π. The fact is true (read a bit whenever an enumerated element strictly extends the current prefix). Fix the sentence.
3. **Lemma 2.3: the normaliser is misprinted.**
   * The text has $Q(S'):=\prod_zq_z(1_{S'}(z))/(1+\tau_B)$, a single division. That is not a semimeasure: for a deterministic hypothesis at the smallest allowed B, $\sum_{S'}Q(S')=1.119$ (`q2_lemmas.out` (c)).
   * The proof's $\beta_B=2^m\log(1+\tau_B)$ is correct for per-factor normalisation, $\prod_z[q_z/(1+\tau_B)]$. With that, the identity $-\log Q(S)=2^mR_B+\beta_B$ holds to 2·10⁻¹⁵ and the total mass is at most 1 (q2 (c)).
   * Fix the formula. Also say that B must be an integer, or otherwise simple, for the $2\log B$ term.
4. **Theorem 2(iii) and (iv) near $2^{-m}$.** §0 says "Below it, every near-optimal hypothesis reproduces the errors". `q4_absorption_and_regimes.out` (B), at d = 100, m = 20, κ = 0, $\delta_S=0$:
   * the condition $\rho<(1-c2^m)B_S/2^m$ of (iii) holds only for $c<0.9942\cdot2^{-m}$;
   * the error-label bound reaches 1/2 only for $c\le0.937\cdot2^{-m}$, and is 0.010 at $c=0.99\cdot2^{-m}$;
   * the (iv) threshold is $0.9947\cdot2^{-m}$ (q1 [G]).
   
   So in a band of relative width about 6% below $2^{-m}$, nothing useful is proved. Reword: "for c ≤ (1 − ε)·2^{-m}, with e ≥ … ".
5. **Overstatements about Theorem 4.**
   * §0 item 4 and §4.4 say steeper SFI "identifies any computable product teacher exactly and never memorises its noise".
   * Theorem 4 gives:
     * almost-sure *eventual* ν-equivalence *on the run*, i.e. summable Hellinger differences, not equality;
     * a MAP of length at most $(\lambda k+m^*)/(\lambda-1)$, so it may memorise $O((k+m^*)/(\lambda-1))$ bits of noise;
     * an exponentially small but nonzero posterior on fill-ins.
   * Also, (iv) needs infinitely many distinct inputs, hence an infinite X. The same holds for "→ 1" in Prop 2.9(a), which is stated on a domain of $2^d$ points.
6. **Theorem 3 scope.**
   * §0 item 3 states "posterior odds … in $[2^{-O(\log N)},2^{k+m^*}]$" for "a sampler ν of length k".
   * The lower end is proved only for samplers that read exactly r uniform bits (dyadic probabilities), at a cost of $2\log(n+1)+2\log(r+1)$ more. The input length n and the bit count r are hidden in "O(log N)".
   * A computable ν with non-dyadic probabilities, such as the Bern(1/3) labels of H6, is not covered.
   * Either prove the extension: hash to $R\approx\log(N/\varepsilon)$ bits and truncate, losing a factor $(1-\varepsilon)$ when ν's conditionals are bounded below. Or state the restriction in §0.
7. **Prop 2.8 "Consequence".** The uniform-deviation term must use $\hat L'=(J_g+\varepsilon_1+\eta)/c$, not Lemma 2.6's $\hat L=(J_g+\varepsilon_1)/c$, because near-minimisers have length up to $(\hat J_g+\eta)/c$. So "$\eta'=\eta+\varepsilon_N$" is slightly too small: by η/c = 10 bits in $\hat L$ for the quoted example. Restate η′ explicitly.
8. **Prop 2.13 is under-specified in the notes.**
   * The predictive distributions of the three options are not defined, and "teacher noise η" sits next to "although the teacher never erred".
   * I re-derived the rates from T5's model:
     * in G-contexts, the teacher and the σ-model put $1-\eta+\eta/M$ on σ;
     * in ¬G-contexts, the teacher plays a fixed non-σ step;
     * "guarded" is uniform over the other M − 1 steps in ¬G-contexts.
   * From that model, `q1_constants.out` [I] gives:
     * $\rho_\sigma=1.2226\cdot10^{-2}$ and $\rho_G=1.8103\cdot10^{-4}$, with path guarded → unguarded at $1.81\cdot10^{-4}$ → none at $1.22\cdot10^{-2}$;
     * for the second instance, guarded → none at $3.203\cdot10^{-4}$. The notes' $3.21\cdot10^{-4}$ is a grid artefact.
   * State the model in the notes, and say "never applied σ outside G" instead of "never erred".
9. **Cor 2.7 table.** The "—" cells at c = 10⁻³, N = 10¹¹ are $\varepsilon_N/c=0.71$ bits and $\ell\le d+20.7$ (q1 [E]). Fill them in.
10. **Example 3.4.**
    * $\ell_U=12$ is an arbitrary length assigned to a finite Bayes mixture; it is not a universal element. Say it is an illustration of Theorem 5's mechanism, not an instance of it.
    * The threshold 1.315 is reproduced as 1.311 from the rounded inputs that c4 prints (q1 [J]).
11. **Theorem 5 and SI with adaptive inputs.** In §3.1, inputs may be adaptive or non-computable. An SI hypothesis is a semimeasure on the interleaved string, inputs included, so (Dom) for SI in that setting needs Hutter's chronological universal semimeasure (F Prop 7.2) rather than Solomonoff's M. Say so where Theorem 5 is applied to SI.
12. **Prop 3.7.**
    * Its consequence compares product sophistication, conditional on dom D, with the unconditional set sophistication of §3.5. Use a conditional set version, or add $K(\mathrm{dom}D)$.
    * Its "O(log)" contains $\log\rho\approx\log N$.
13. **Prop 3.5, "Reading".** "λ slightly above 1 selects an approximately minimal sufficient statistic" has the trade-off backwards.
    * As λ → 1, the complexity slack $(c+\kappa)/(\lambda-1)$ blows up. The selected model is then nearly sufficient but not nearly minimal.
    * Near-minimality needs λ − 1 = Θ(1), at a sufficiency loss of $(\lambda-1)\,\mathrm{soph}_c$.
14. **Lemma 1.2(iii) wording.** "Vertex … with finite negative slopes" excludes the two end vertices, which are unique minimisers on $(c_0,\infty)$ and $(0,c_1)$. Reword as "its set of supporting slopes contains an open interval".
15. **λ = cN is not a single predictor.**
    * With the prior exponent growing in N, the sequence of steeper predictors is not the conditional sequence of any one semimeasure.
    * So §1.1's telescoping and order independence (F Prop 5.2) do not apply. §4.4's "regret λℓ(π)" is a per-N batch statement.
    * Say so wherever "steeper SFI" is called a predictor.
16. **T5 improvements dropped.**
    * Theorem 2 and Prop 3.8 need $G_1>H(p)$, i.e. p < 0.056.
    * For the full-table case (Cor 2.5, Prop 3.8), T5's Lemma 2.5c, added after T5's own referee, already gives a kink for every p < 1/4 once $\varepsilon_E$ is small.
    * The track lists it as not reused and calls this open problem 2. The brief asks to keep T5's corrections. Reuse it, or explain why not.
    * T5 Prop 4.5 is also dropped; see M3.
17. **"Corrections relative to T5: none of substance."** This is accurate for the results reused. The section should also say what was *dropped* and why: Lemma 2.5c, Prop 4.5, Thm 3.3 and §5.
18. **Hänni's Version 1** (100-bit error model, rate ratio 10). Only the three-point arithmetic is checked (c1). §5's "His three hypotheses and numbers: Confirmed" should say that Version 1 is not realised by any theorem.
19. **The δ_S = 0 convention and "information" are undefined.** This is part of M3; listed here so that the revision does not miss it in Cor 2.5 and Cor 2.7.

---

## Claims I confirmed

Each item was checked line by line. My independent code is cited where relevant.

* **Setup.**
  * Lemma 1.1 is confirmed.
  * Lemma 1.2 (i), (ii) and (iv) are confirmed; (iii) is right up to the wording in minor 14.
  * The telescoping identity of §1.1 is confirmed.
  * Facts F2–F5 are standard. F1 is true; only its proof sentence is wrong (minor 2).
* **Theorem 1 (a)–(d).**
  * Proof and constants confirmed: $L_\lambda=(\lambda\ell_U+c_0)/(\lambda-1)$ equals T5's threshold.
  * The (c3) finiteness argument and the (d) chain rule with sub-probabilities are confirmed.
  * In an explicit shared class that contains its own mixture, q4 (A) found 0 violations of the length and loss bounds in 300 MAP checks, and 0 violations of (c1) and of Thm 5(ii).
  * The largest $\ell({\rm MAP})/L_\lambda$ seen was 0.972, so the bound is nearly attained.
* **Prop 1.3 and Cor 1.4.**
  * The Gibbs-inequality bound and the Sion minimax argument on $\Delta_\varepsilon$ are confirmed.
  * q2 (a): the example's value is 2.54311 (dual), with an identical primal value at the marginals of the optimal Q.
  * Over 60 random families, the duality gap at the dual optimum is at most 3.6·10⁻⁵, and there are 0 weak-duality violations among 3000 random sub-probability ν.
* **Remark 1.5 and Lemma 1.6.** Confirmed.
* **Lemma 2.1.**
  * The identity $u=\frac12(\mathbb E[h_0+h_1]+\hat s)$ is confirmed.
  * $A_t$ is c.e. because u is lower semicomputable.
  * q2 (b): 400 adversarial semimeasure hypotheses at d = 7, 0 violations of $|A_t|<4^t$.
* **Lemma 2.2.** Confirmed.
* **Lemma 2.3.** Confirmed with per-factor normalisation (minor 3).
* **Lemma 2.4 (D1), (D2).** Confirmed; symmetry of information is used correctly.
* **Theorem 2.**
  * (o): the concavity of $G_j$ is confirmed (I checked the derivatives).
  * (i): the ψ-minimum and Δ(c) are confirmed.
  * (ii)(a)–(e): both cases of (b) are confirmed, and so is (d) via symmetry of information.
  * (e): the c.e. set $B_\theta$, Hoeffding without replacement, the index code, and the contradiction with the choice of $j_g$ are confirmed.
  * The counting step was checked exhaustively in q2 (d): 0 violations over 120 populations × 4 values of γ; the largest count/bound ratio is 0.651.
  * (iii) and (iv) are confirmed; see minor 4 on their scope.
* **Numbers I reproduced independently** (`q1_constants.out`):
  * $L_S=11{,}710.273$ bits, from an exact big-integer binomial;
  * the crossover p = 0.05596;
  * the windows, by bisection on $J_g\le M_2$:
    * (9.5367·10⁻⁷, 8.0618·10⁻³] at d = 100;
    * λ ∈ (1, 11945] for the full table at d = 20;
    * (1, 6456] at κ = 30;
  * Cor 2.5 at λ = 2: u ≥ 0.9913, ℓ ≤ d + 58.2, information ≤ 70.8, e ≤ 0.220 with g optimised (the notes have 0.23);
  * Cor 2.5 at λ = 105: ℓ ≤ d + 15.7 and information ≤ 28.3;
  * Thm 2 at c = 10⁻⁴: u ≥ 0.9831, ℓ ≤ d + 20.4, e ≤ 0.199;
  * m = 24: e ≤ 0.058;
  * Cor 2.7 rows: ε/c = 9.16 and 0.92 bits;
  * Prop 2.9(b): e ≥ 0.649 and 0.958;
  * Hänni's Version 2: window (1.1185·10⁻⁶, 8.9893·10⁻³), ratio 8037, λ = 1 switch at N = 8.94·10⁵; Version 1's window (10, 100).
* **Lemma 2.6, Cor 2.7, Prop 2.8 (the inequality) and Prop 2.9 (a)–(c).** Confirmed.
* **Props 2.12–2.14.** Confirmed; Prop 2.13's numbers re-derived (minor 8).
* **Lemma 3.1 (Ville).**
  * The supermartingale is valid for adaptive inputs.
  * q3 (B) uses an adversarial adaptive input rule (the next input is where ξ deviates most from ν). The empirical $\Pr[\sup\ge m]$ is 0.355, 0.163, 0.069, 0.035 and 0.0065 for m = 1, 2, 3, 4, 6, all below $2^{-m}$. The adversary gets much closer to the bound than c4's run (0.1185 at m = 1).
* **Lemma 3.2.** The statement is true and exact (q3 (A)). The proof needs minor 2.
* **Theorem 3, Prop 3.3, Theorem 4 (i)–(iv) and Theorem 5.**
  * The Hellinger martingale $\sqrt{\Lambda_N}/\prod(1-H_i^2)$ is correct, with $H_i^2$ predictable.
  * q3 (C) uses an explicit, Kraft-valid product class (Kraft sum 0.909) of samplers, fill-ins and partial memorisers, with 30 runs × 12 sample sizes × 4 values of λ. It found 0 violations of Thm 4(i) (length and loss), (ii), (iii), and Thm 3(iii)'s upper end, over 1440 MAP checks.
* **Props 3.5–3.8.**
  * Injectivity of $(a',E')\mapsto$ table for p < 1/4 is confirmed.
  * $K(z)\ge d+L_E-\delta_E-\kappa$ is confirmed.
  * The c-range in 3.8(ii) is consistent. Its lower end contains $\log(n+1)=d$; this is the usual $O(\log n)$ slack of algorithmic statistics, not a defect.
* **Props 4.1, 4.2 and Remark 4.3.** Confirmed. Prop 4.1 needs the mixture's predictive to be computable (e.g. computable w and $\nu_\theta$); add this.
* **Cross-references to F.** Def 2.1, 2.5 and 5.1; Prop 3.3(a); Thm 3.2 and 3.4; Problem 3.6; Thm 4.2; Props 4.4 and 4.5; Cor 6.6; Prop 6.8. All exist in `../foundations/notes.md` and say what the track uses them for.

---

## Important questions from the brief that the track missed or left thin

1. **An explicit answer to Wyeth** (M2).
2. **Prior work on steeper two-part codes in classification**, and the choice of λ's growth rate: $cN$ versus $\sqrt N$ (M1).
3. **Which error rules the trick handles** (M3): incompressible ones only. Error envelopes (T5 Prop 4.5), the realistic case for systematic human error, are not covered.
4. **Input-distribution dependence.**
   * Theorem 2 assumes uniform inputs.
   * Rates, and hence the window, scale with the input law; this is T5 (d7), not re-derived.
   * A covariate shift can move a component across the threshold. This bears directly on the H8 (OOD) discussion.
5. **Steeper SFI and Hänni's OOD proposition (H8).**
   * The bad variant "good model + if (test property) output 0" costs $\Delta$ extra bits, so its relative weight is $2^{-\lambda\Delta}$, which vanishes for $\lambda=cN$.
   * So steeper SFI may *remove* the constant-probability OOD failure that plain SFI has. But it also prefers the shortest train-equivalent rule.
   * Neither direction is discussed. This is a candidate for "something one can do with SFI but not SI".
6. **Computable, circuit and NN versions (H10).**
   * The track does not say whether the mechanism survives in time-bounded or circuit SFI. That mechanism is per-input pricing plus list decoding of the model.
   * It also does not relate λ > 1 to the tempered/cold-posterior literature in Bayesian deep learning. There, cold posteriors scale prior and likelihood together. A steeper prior scales only the prior.
7. **General samplers in the λ = 1 split** (minor 6). This includes the Bern(1/3) labels of H6.
8. **Version 1 of Hänni's example** (minor 18).

---

## References checked

Verified by WebSearch in this run (bibliographic data; content only from abstracts and snippets):

| Reference | Status |
|---|---|
| Koppel 1987, *Complex Systems* 1(6):1087–1091 | verified |
| Antunes & Fortnow 2009, *Theory Comput. Syst.* 45(1):150–161 | verified |
| Vereshchagin & Shen 2017, LNCS 10010:669–737 (arXiv 1607.08077) | verified |
| Grünwald 2012, ALT, LNCS 7568:169–183 | verified |
| Barron & Cover 1991, *IEEE IT* 37(4):1034–1054 | verified; the η < 1 prior condition comes from a secondary snippet, unverified |
| Hoeffding 1963, *JASA* 58(301):13–30 | verified; that "Thm 4" is the without-replacement result could not be confirmed from snippets; mark it unverified |
| **Missing:** Zhu & Srebro 2025, COLT, PMLR 291:6124–6155 | verified; content per abstract |
| **Missing:** Zhu, Ohannessian & Srebro 2026, arXiv 2603.22644 | verified; content per abstract |
| **Missing:** Grünwald & Langford 2007, *Machine Learning* 66:119–149 (COLT 2004) | verified; content per abstract |
| All others in the notes (Bissiri et al., Bhattacharya et al., Grünwald & van Ommen, Zhang, Gneiting & Raftery, Kakutani, Sion, GTV 2001, VV 2004, Vitányi 2006, Koppel & Atlan, Solomonoff 1978, Poland & Hutter, Kushilevitz & Mansour) | not re-searched by me; the data match my knowledge, and the notes already mark content as unverified |

Also relevant, as flagged in `referee-run1.md` and not re-checked by me: Vereshchagin & Vitányi 2010, "Rate distortion and denoising of individual data using Kolmogorov complexity", *IEEE IT* 56(7). Its Hamming-ball models are a special case of the product models of §3.5.

---

## Referee code (this run)

* `referee_code/q1_constants.py` → `.out`. Deterministic. Recomputes, independently of the track's scripts:
  * Hänni's numbers and the exact $L_S$;
  * the $G_1=H(p)$ crossover;
  * Theorem 2's window, by bisection, for κ ∈ {0, 10, 30};
  * the identification bounds, with g optimised and $\delta_S\in\{0,20\}$;
  * Cor 2.7 and Prop 2.9(b);
  * the Prop 2.8 exponent and the Thm 2(iv) threshold;
  * Prop 2.11 verdicts against κ;
  * Prop 2.13 from an explicit teacher model;
  * the Example 3.4 threshold.
* `referee_code/q2_lemmas.py` → `.out`. Seed 20261012.
  * (a) Prop 1.3 minimax, by mirror ascent and subgradient methods;
  * (b) Lemma 2.1 list bound on adversarial semimeasures;
  * (c) the Lemma 2.3 identity and normalisation, exhaustive over subsets, including the misprint;
  * (d) the Thm 2(ii)(e) counting step, exhaustive.
* `referee_code/q3_split.py` → `.out`. Seed 777.
  * (A) Lemma 3.2 with my own GF(2^q) arithmetic, including seed collisions;
  * (B) Ville with an adaptive adversary;
  * (C) Theorems 3–4 in a Kraft-coded product class with fill-ins and partial memorisers.
* `referee_code/q4_absorption_and_regimes.py` → `.out`. Seed 4242.
  * (A) Theorems 1 and 5 in a shared class that contains its own mixture;
  * (B) the range where Thm 2(iii) applies;
  * (C) the structured-error-rule example behind M3.
