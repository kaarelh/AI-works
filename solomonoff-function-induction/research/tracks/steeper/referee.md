# Referee report: track "steeper" (`notes.md` and `checks/c1`–`c5`)

*Adversarial referee, 2026-10-11. I read the brief, the sources it names for H9 (`prior/hanni-grokking-a-notion.md`, `prior/hanni-lesswrong-comment-thread.md`, `prior/hanni-sfi-notes.md`), the foundations notes that the track cites ("F"), T5 and all five check scripts with their outputs. I also searched `/home/user/kaarelh/notes` for a separate model-vs-randomness note and found none; the grokking note is the only source. I checked every proof tagged **proved** line by line. I wrote independent code in `referee_code/` (r1–r6, seeded or deterministic, outputs saved next to the scripts). I did not edit the notes.*

## Verdict

* **No fatal errors.** I found no false theorem and no proof that fails beyond repair. The core results hold as stated, up to the explicit machine constant κ: Theorem 1, Prop 1.3/Cor 1.4, Lemmas 2.1–2.4, Theorem 2 (o)–(iv), Lemma 2.6, Prop 2.8, Theorems 3–5 and Props 3.5–3.8.
* **Three major issues.** The track:
  * overclaims "proved" for numerical instances that depend on setting κ = 0 (M1);
  * does not answer Wyeth's objection explicitly, as the brief requires, and understates what restricting to private randomness costs (M2);
  * claims novelty for the "product" algorithmic-statistics notions without comparing them with restricted-model-class algorithmic statistics, which is closely analogous (M3).
* **Minor issues.** About twenty, listed below. They include one proof gap that is easy to fix (Lemma 3.2), two script bugs that change no verdict, and several overstatements in the summary.

---

## Major issues

### M1. "Proved over all hypotheses" for instances that hold only with machine constants set to 0

* **Claim.** §0 item 2(b): "With machine constants set to 0, a 3-bit error rule on 1/8 of the inputs, or a 6-bit one on 1/64 at d ≥ 1000, defeats the trick for every λ. This is proved over all hypotheses." Prop 2.11 [proved; computed: c3] gives the examples. Similar "never selected" verdicts appear for single 6- and 7-bit prefixes under Prop 2.11(i).
* **Problem.**
  * Prop 2.11(ii)'s inequality is proved. Whether it holds at given (d, m, p) depends on the unknown machine constant κ. Setting κ = 0 is an illustration, not a proof.
  * Prop 2.11(i)'s examples go further. They use the *upper bounds* $d+\kappa_g$ and $d+\lceil L_S\rceil+\kappa_b$ as if they were the exact program lengths, but (i) is a statement about exact lengths.
* **Evidence.**
  * `referee_code/r1_theorem2_numbers.out` [D] evaluates Prop 2.11(ii) over κ ∈ {0, 10, 20, 30, 50}:
    * the d = 100, m = 3 instance fails for κ ≥ 20;
    * the d = 1000, m = 6 instance fails for κ ≥ 30.
  
    The track's own `checks/c3_junta_window.out` shows the same two failures at κ = 30 ("never selected: False"). The summary does not mention them.
  * [E] shows that the m = 7, d = 100 verdict of Prop 2.11(i) flips if $\ell_b-\ell_g$ grows by 1.4 bits. That is well inside the O(log d) uncertainty.
* **Fix.**
  * State the examples as illustrations at κ = 0.
  * Give the robust version: for fixed (m, p) the inequality of Prop 2.11(ii) holds for all d ≥ d₀(κ). The left side decays like 1/log d, the right side like 1/d. Report d₀ for a range of κ: by r1 [D], d ≥ 300 suffices for m = 3 and d ≥ 3000 for m = 6, at every κ ≤ 50.
  * Drop "proved" from the numerical verdicts of Prop 2.11(i).

### M2. Wyeth's objection is not answered explicitly, and the cost of the answer is understated

* **Claim.** The brief: "The paper must answer Wyeth's objection explicitly." The track never names Wyeth or the thread. §1.6 says: "At λ = 1 nothing is lost: $M_{\rm prod}$ already dominates every product hypothesis."
* **Problem.**
  * *Missing explicit answer.* The ingredients are all present:
    * Theorem 1 is Wyeth's point, made exact, for SI and for shared-randomness SFI;
    * Cor 1.4 and Remark 1.5 show that no product hypothesis is universal, and that the per-input universal semimeasure is a fixed predictor;
    * §3.5 is the algorithmic-statistics connection that Wyeth points to.
    
    But no paragraph says: "Wyeth's construction works for SI and for $M_F$; it is unavailable in the product class for these reasons; here is what it costs."
  * *The cost is understated.*
    * Steeper SFI is defined over product hypotheses, so its λ → 1 limit is $M_{\rm prod}$ (operator induction), not $M_F$. That is the object the foundations track recommends as *the* SFI predictor.
    * F Prop 4.5 shows that $M_F/M_{\rm prod}$ is unbounded, already against the O(1)-complexity shared-randomness law σ (one coin per input length).
    * So relative to SFI as F defines it, restricting to private randomness does lose something. Product hypotheses cannot express a persistent latent cause shared across inputs, such as a labeller's mood or a per-batch coin.
    
    "Nothing is lost" is true only relative to the product class.
  * *Ad hoc?* A sceptic will say the class was chosen to exclude the universal element. The track's best reply is in §1.6: Hänni's dominance template is stated against x-only samplers. That reply should be made explicitly, together with the price just described.
* **Evidence.** `grep -i wyeth notes.md` gives no hits. Compare §1.6 with F Prop 4.5 (`../foundations/notes.md`, §4).
* **Fix.**
  * Add a subsection, "Answer to Wyeth's objection". It should contain:
    * (i) Theorem 1, as his objection made exact for SI and $M_F$;
    * (ii) Cor 1.4, Remark 1.5 and Prop 4.2, as the reasons it fails for private randomness;
    * (iii) the price, F Prop 4.5, and the fact that labelled history restores it (Prop 4.1);
    * (iv) the algorithmic-statistics reading (Prop 3.8).
  * Replace "nothing is lost" with an exact statement.

### M3. Novelty of the "product" algorithmic-statistics notions not checked against restricted model classes

* **Claim.** §3.5: "The product notions are new as far as I could check." §3.6 lists as new "the product structure function, product sufficiency and product sophistication, and the ≈ d gap to the set notions (Prop 3.8)".
* **Problem.** Algorithmic statistics has studied *restricted* model families in which part of the description is forced into the noise.
  * The closest work I found is Vereshchagin & Vitányi, "Rate distortion and denoising of individual data using Kolmogorov complexity", *IEEE Trans. IT* 56(7):3438–3454, 2010 (bibliographic data verified by search; content seen through the abstract only). It considers models given by distortion balls, Hamming balls among them, and treats denoising through low-complexity balls.
    * For $z=f_a\oplus1_E$, a Hamming ball centred at $f_a$ of radius pn is exactly a "parity + i.i.d.-flip" model: complexity ≈ d and log-size ≈ nH(p).
    * The kink at the centre's complexity is the same phenomenon as the kink in the product structure function.
  * Prop 3.7's thresholding argument ($S=\{y:\nu(y)\ge2^{-\rho}\}$) is, I believe, the standard translation between distribution models and set models, discussed in Gács–Tromp–Vitányi 2001 and Vereshchagin–Shen 2017 (unverified: search snippets do not show it).
* **Evidence.** WebSearch results; see the references section below.
* **Fix.**
  * Cite VV 2010 and compare: the product class is a restricted model family, and Hamming-ball models are a special case of product models with uniform flip noise.
  * State what is new: general lower-semicomputable product models, the link to the SFI hypothesis class, and the junta instance.
  * Mark Prop 3.7 as a known translation if confirmed.
  * Tone down "new" until the papers are read.

---

## Minor issues

1. **Lemma 3.2 proof gap: per-seed versus per-function counting.**
   * The proof sums $2^{-\ell(\varphi_s)}$ over all consistent seeds s. With Def 1.3's notion of universality (each member has *some* program of length ≤ K(·) + κ), distinct seeds that compute the same function need not get distinct programs.
   * They often coincide. In `referee_code/r5_hashing.out`, 1024 seeds give only 15 distinct functions on X, with the largest multiplicity 304.
   * *Fix.* Either define the class to contain a prefix-free simulation $\{r q : q\in{\rm dom}V'\}$ for every prefix-free machine V′, as F's W does. Or note that X = {0,1}^n is finite and apply the conditional coding theorem to truth tables: the seed-induced semimeasure on tables is computable from $(\pi_\nu,N,n,r)$.
   * The statement survives, and the independence part is confirmed exactly by r5(a) over GF(32) with n < q and r < q, a case c4(B) does not cover.
2. **Script bug in c3.**
   * `ceil(log2binom(...))` is taken of a float computed with lgamma. For single-prefix rules ($s_0=1$), $L_S=m$ is an integer, but lgamma gives $m+10^{-14}$, so the ceiling is m + 1 for m = 6, 7, 8 (r6(c)).
   * This shifts the Prop 2.11(i) rates; for example, m = 7 gives 8.24e-3 instead of 9.42e-3 (r1 [E]).
   * No verdict changes. Use exact integers.
3. **Prop 2.8 example.**
   * c5(e) hard-codes $J_c(\text{good})=0.0214$ (length 102). The notes' own formula gives $J_g=c(d+\kappa_g)+H(p)=0.0232$, so the exponent is −758, not −776 (r1 [F], r6(d)).
   * It is immaterial, but the quoted number should come from the stated formula.
4. **Unstated assumption $\delta_S=0$ and undefined "information".**
   * All identification numbers (Thm 2, Cor 2.5, Cor 2.7, §0) silently set the deficiency $\delta_S=0$. "Information about the error rule" is never defined.
   * The bound (ii)(d) is $B_S-K(S\mid a,\pi)\le\Delta_\ell+\Lambda_3$. Against $L_S$ it is $\delta_S+\Delta_\ell+\Lambda_3$; against $K(S\mid a)$ add the O(log) cost of describing S.
   * With $\delta_S=20$: e ≤ 0.221 instead of 0.203, and information ≤ 58 bits instead of 38 (d = 100, c = 1e-4; r1 [C]).
   * *Fix.* Define $I:=B_S-K(S\mid a,\pi)$ and state $\delta_S$.
5. **Overstatements in the summary and §4.4.**
   * "identifies a computable product teacher exactly and never memorises its noise". Thm 4 gives almost-sure *eventual* ν-equivalence *on the run* and an exponentially small, nonzero posterior on fill-ins.
   * §0 item 1, "Every product hypothesis pays a mixture's log(1/w) at every input". Only per-input mixtures do (Prop 1.3(iii)).
   * "Below it, every near-optimal hypothesis reproduces the errors". Thm 2(iii) needs $\rho<(1-c2^m)B_S/2^m$, i.e. c below $2^{-m}$ by a relative margin of order $\rho2^m/B_S$.
6. **Finite domains and "eventually".**
   * Thm 4(iv) needs infinitely many distinct inputs, hence infinite X. On X = {0,1}^n, the setting of Lemma 3.2 and Thm 3, "eventually" is vacuous.
   * Likewise Prop 2.9(a), (b) say "→ 1" and "→ 0" as N → ∞ on a domain of $2^d$ points.
   * State the asymptotic statements on an infinite X, or as explicit finite-N bounds.
7. **SI is not a class of "shared hypotheses" in the sense of Def 1.2.**
   * An SI hypothesis is a semimeasure on interleaved strings. It is not a function of the data set: it depends on the order and includes the input probabilities.
   * Theorem 1 still applies to SI, because its proof uses only (Dom) with "data set" read as "string". But Theorem 5's SI clause, in the §3.1 setting with adaptive or non-computable inputs, needs Hutter's chronological universal semimeasure (F Prop 7.2) in place of M. State this.
8. **Prop 4.1: computability of $h_w$.** The predictive $Z_{i+1}/Z_i$ is a ratio of lower-semicomputable sums. It is a computable conditional measure only if, for example, $\sum_\theta w_\theta$ is computable as well as each $\nu_\theta$; otherwise it is not even lower semicomputable. Add the hypothesis.
9. **Prop 3.7.**
   * Its consequence compares product sophistication, which is conditional on dom D, with the unconditional set sophistication of §3.5. A conditional set version is needed, or a $K({\rm dom}D)$ term.
   * The "O(log)" contains $\log\rho\approx\log N$.
10. **Prop 3.5's reading.** "λ slightly above 1 selects an approximately minimal sufficient statistic" has the direction wrong. The slack $(c+\kappa)/(\lambda-1)$ blows up as λ → 1, and the sufficiency loss $(\lambda-1)\,{\rm soph}_c$ grows with λ. The bound is a trade-off and is useful at λ − 1 = Θ(1).
11. **Lemma 1.2(iii) wording.**
    * "Vertex of the lower hull with finite negative slopes" excludes the two end vertices. Yet they are unique minimisers on the open intervals (c₀, ∞) and (0, c₁).
    * Example: {(0,1), (10,0.5), (20,0)} (r6(a)).
    * Reword as: the set of supporting slopes contains an open interval.
12. **Tag of the "flat totals" check.** "[computed: c2(c): flat totals]" for the set models $S_u$ is tautological: the script prints $(d-u)+(u+L_E)$. It is a one-line proof; tag it as proved.
13. **Hänni's Version 1 is not realised rigorously.**
    * §5 marks "His three hypotheses and numbers" as Confirmed, but c1 checks only the three-point arithmetic. Theorem 2 covers Version 2's sizes.
    * Version 1 has a 100-bit error model with rate ratio 10. Theorem 2 *can* realise it, with a full table at d = 13, m = 10, p = 2⁻⁶ and $L_S=116$ bits: the window is λ ∈ (8, 86] at κ = 0 and is still nonempty at κ = 30 (r1 [H]).
    * At those sizes, however, the identification bounds are vacuous or weak (e ≤ 1.44–1.83 at κ = 0; information bound 28–92 bits out of $L_S=116$; r1 [H]).
    * Say so: for Version 1, the window is nonempty and the selected hypothesis provably does not have level ≥ 2, but nothing finer is proved.
14. **Theorem 3 summary.** "$2^{-O(\log N)}$" hides the $2\log(n+1)+2\log(r+1)$ terms (input length and sampler bits) and the restriction to dyadic samplers (Lemma 3.2's hypotheses). The same hidden terms appear in §0 item 3.
15. **λ = cN is not a single Bayesian predictor.** With the prior exponent growing in N, the sequence of steeper predictors is not the conditional sequence of any one semimeasure. So the telescoping and order-independence of §1.1 (F Prop 5.2) do not apply to it. §4.4's "regret cℓ per sample" should be stated with this in mind.
16. **(F1)'s proof description.** "Read input bits until the string read so far is enumerated in Π" would hang on any prefix that is not in Π. The fact is right: a partial computable function with prefix-free domain Π is a prefix machine. Fix the sentence.
17. **Cor 1.4's input space.** It uses $\{0,1\}^d$ for all d, so X must contain all of them (e.g. X = {0,1}^*). §1.1 fixes $X=\{0,1\}^d$ in examples. State it.
18. **Cor 2.7 table.** The "—" entries at c = 10⁻³, N = 10¹¹ are computed by c3 (ε/c = 0.7 bits, ℓ ≤ d + 20.7). Fill them in.
19. **Unsaved re-run.** "T5's own scripts c1–c3 were re-run in a scratch directory and reproduce T5's numbers": no output is saved, so this cannot be checked. Save it or drop the sentence.
20. **References.**
    * Poland & Hutter 2005 has an erratum: *IEEE Trans. IT* 52(3):1279, 2006 (verified by search). Cite it.
    * For Barron & Cover 1991, I believe the consistency theorem assumes $\sum_q2^{-\alpha L(q)}\le1$ for some α < 1. That is a steeper-than-Kraft penalty, i.e. λ > 1 two-part codes, which is direct prior art for "λ > 1". It is unverified (snippets only), as the notes say. It should be checked before any novelty claim about λ > 1 two-part codes.

---

## Claims I confirmed

Each was checked line by line. Independent code checks are noted.

* **Lemma 1.1, Lemma 1.2 (i), (ii), (iv).** Lemma 1.2(iii) is right up to the wording in minor 11.
* **Theorem 1 (a)–(d).**
  * (a): the length and loss bounds.
  * (b): the code-length sandwich.
  * (c1): a cumulative loss of at most $\min\{\lambda\ell_t,\lambda\ell_U+c_0+\ell_t\}$.
  * (c2), and (c3): the finiteness argument.
  * (d): the chain rule with sub-probabilities. One restriction: in (d), μ must model the inputs, so the inputs must be computable i.i.d., as stated.
  * The threshold matches T5 Prop 2.3.
  * Independent finite-class test (r4, `T1a`): 0 violations in 1600 MAP checks.
* **Prop 1.3 and Cor 1.4.**
  * The lower bound via Gibbs' inequality with a sub-probability holds.
  * So does the minimax value via Sion on $\Delta_\varepsilon$.
  * The example value 2.5431 is confirmed by an independent grid search, mirror ascent and a primal certificate, all agreeing to 4·10⁻⁵ (r2).
  * In 12,000 random sub-probability hypotheses on 60 random families, there are 0 violations of max-loss ≥ max_Q ΣH; the primal–dual gap is ≤ 5·10⁻⁴ (r2).
* **Remark 1.5 and Lemma 1.6.**
* **Lemma 2.1.**
  * The identity $u=\tfrac12(\mathbb E[h_0+h_1]+\hat s)$ holds, and so does the strict list bound $<2^{2t}$.
  * $A_t$ is c.e. because u is lower semicomputable.
  * Tests in r3: 600 adversarial hypotheses (partial memorisers, parity mixtures, S-aware tables, random tables), 0 violations.
* **Lemma 2.2.** Jensen with truncation holds, and $\mathbb E\nu(y^*\mid x)\le u+p$. r3: 0 violations at B ∈ {∞, 6, 12}.
* **Lemma 2.3.**
  * The AM–GM step holds, and Q is a semimeasure on *all* subsets.
  * $-\log Q(S)=2^mR_B+\beta_B$ holds exactly.
  * r3 checks the equality on 600 hypotheses and the total mass by brute force over 2¹⁶ subsets.
  * One small point: B must be an integer, or simple, for the 2 log B term.
* **Lemma 2.4 (D1), (D2).** They use (F3) in the form $K(a,S)\le K(\pi)+K(a\mid\pi)+K(S\mid a,\pi)+\kappa$, and symmetry of information for $K(a,S)\ge d+B_S$.
* **Theorem 2.**
  * (o): the concavity of $G_j$ is correct, and so is the reduction to min{φ(2), φ(t*)}.
  * (i): the window, the slack Δ(c), and $\{c:J_g\le M_2\}=(0,c_{\rm hi}]$. The closed form matches bisection to 10⁻¹⁵ (r1 [A]).
  * (ii)(a)–(e): both cases of (b) hold. (d) holds via symmetry of information.
  * (e): the c.e. set $B_\theta$, Hoeffding without replacement, and the index code hold, and the contradiction with the choice of $j_g$ holds. The counting step is checked exhaustively over all C(32,4) subsets in 160 cases, with 0 violations; the ψ-algebra of (ii)(b) and (iii) is checked on 2·10⁵ random parameter draws, with 0 violations (r3).
  * (iii) and (iv) hold.
  * Numbers: the window (9.54e-7, 8.06e-3] and the identification rows (u ≥ 0.983, ℓ ≤ d + 20.4, e ≤ 0.203 at c = 1e-4) are reproduced by independent code (r1 [A], [C]).
* **Cor 2.5** (full table; numbers reproduced: window λ ≤ 1.195·10⁴ at d = 20, κ = 0), **Lemma 2.6** (the union bound with Kraft weights; one-sided, truncated) and **Cor 2.7** (numbers reproduced).
* **Prop 2.8** (the inequality; r4 does not test it separately, but its algebra is two lines and correct) and **Prop 2.9 (a)–(c)**.
* **Props 2.12–2.14.**
  * The guard-erosion numbers are recomputed (r6(b)): unguarded on (1.810e-4, 1.223e-2); guarded → none at 3.203e-4, which the notes round to 3.21e-4 from c5's grid.
* **Lemma 3.1 (Ville).** The supermartingale argument holds for adaptive inputs.
* **Lemma 3.2.** The statement is true; the proof needs minor 1. Independence is exact on GF(32) (r5).
* **Theorem 3, Prop 3.3.**
* **Theorem 4 (i)–(iv).**
  * The Hellinger martingale $\sqrt{\Lambda_N}/\prod(1-H^2_i)$ is right, with $H^2_i$ predictable.
  * r4 builds an explicit infinite product class with Kraft weights: grid samplers, constants, fill-ins, and partial memorisers with memorised prefixes. It finds 0 violations of (i), (ii) and (iii) over 40 runs × 4 values of λ × 10 sample sizes: 14,400 checks, of which 4800 are on (i) (three inequalities for each of 1600 MAPs), 8000 on (ii) and 1600 on (iii).
  * As expected for an asymptotic statement, the MAP at N = 200 is often a neighbouring grid sampler, not ν* (120/160; informational).
* **Theorem 5 (i), (ii).** r4 `T5ii`: 0 violations in 6400 checks.
* **Props 3.5, 3.6, 3.8 (i)–(iii).**
  * The injectivity of $(a',E')\mapsto$ table holds for p < 1/4.
  * The bounds $K(a,E)\le K(z)+\kappa$ (by minimum-distance decoding) and $K(z\mid d)\le d+nH(p)+O(\log n)$ hold.
  * The range of c in (ii) is consistent.
* **Props 4.2 and 4.3.** Prop 4.1 holds with the hypothesis added in minor 8.
* **Cross-references to F.** Def 2.1, Def 2.5, Prop 3.3(a), Thm 3.2, Thm 3.4, Problem 3.6, Thm 4.2, Prop 4.4, Prop 4.5, Def 5.1, Cor 6.6 and Prop 6.8 all exist and say what the track uses them for.
* **Hänni's numbers (c1).**
  * Version 2's window (1.12e-6, 8.99e-3) at ratio 8037 and the λ = 1 switch at 8.94·10⁵ are reproduced (r1 [G]).
  * $L_S=11{,}710.27$ by an exact sum of logarithms (r1 [G]).
  * $p\log(1/p)$ is 12.6% below H(2⁻¹⁰), which the notes round to 13%.
  * The crossover $G_1=H(p)$ is at p = 0.05596 (r1 [B]).

## Important questions from the brief that the track missed or left thin

1. **An explicit answer to Wyeth** (M2).
2. **Steeper simplicity versus the OOD pathology of H8.**
   * In Hänni's OOD proposition, the bad variant "good model + if (test property) output 0" has prior weight $2^{-\Delta}$ relative to the good model. Under the power prior it gets $2^{-\lambda\Delta}$, which vanishes when λ = cN.
   * Conversely, steeper selection favours the *shortest* hypothesis that fits training data up to rate c. That hypothesis may extrapolate badly when the truth is longer than some train-equivalent rule.
   * Neither direction is discussed. Both bear on whether steeper SFI is "something one can do with SFI but not SI" in a useful sense.
3. **Input-distribution dependence.**
   * Theorem 2 is for uniform inputs only.
   * Rates, and so the window, depend on the input law; this is T5 (d7), not re-derived.
   * A shift of the input distribution can move a component across the threshold. Prop 2.12's twin worlds hint at this but do not state it.
4. **Computability of steeper SFI.**
   * The power-prior predictive $\xi_\lambda$ is lower semicomputable only up to normalisation, and the λ-MAP over $\Pi_\times$ is not computable.
   * The H10 bridge, NN Bayes as approximately circuit SFI, would need a computable or circuit analogue. The track does not say whether Theorem 2's mechanism (list decoding plus per-input pricing) survives in a time-bounded or circuit class.
5. **Version 1 of Hänni's example** (minor 13): not realised rigorously, although Theorem 2 nearly does it.
6. **Context for the paper's ML framing.** The tempered- and cold-posterior literature in Bayesian deep learning is relevant to H10. Wenzel et al., "How good is the Bayes posterior in deep neural networks really?", ICML 2020 (verified bibliographically) report that *sharpening* the posterior helps. One sentence should place λ > 1 relative to that literature: in the likelihood-tempering parametrisation they move in opposite directions. I have not checked that anyone has studied λ > 1 for NN Bayes.

## References spot-checked

| Reference as cited in the notes | Status |
|---|---|
| Barron & Cover 1991, *IEEE IT* 37(4):1034–1054 | bibliographic data verified; the α < 1 condition is unverified (minor 20) |
| Bhattacharya, Pati & Yang 2019, *AoS* 47(1):39–66 | verified |
| Grünwald 2012, ALT, LNCS 7568:169–183 | verified |
| Poland & Hutter 2005, *IEEE IT* 51(11):3780–3795 | verified; erratum in 52(3):1279 not cited |
| Koppel 1987, *Complex Systems* 1(6):1087–1091 | verified |
| Gács, Tromp & Vitányi 2001, *IEEE IT* 47(6):2443–2463 | verified (bibliographic) |
| Vereshchagin & Shen 2017, LNCS 10010:669–737 | verified (bibliographic) |
| Vereshchagin & Vitányi 2010, *IEEE IT* 56(7):3438–3454 (missing from the notes) | verified (bibliographic); content per abstract only |
| All others (Bissiri et al.; Grünwald & van Ommen; Zhang; Gneiting & Raftery; Kakutani; Sion; Hoeffding; Antunes & Fortnow; Vitányi 2006; VV 2004; Solomonoff 1978) | not re-searched by me; the data match my knowledge, and the notes already mark content as unverified where appropriate |

## Referee code (`referee_code/`)

* **`r1_theorem2_numbers.py`.** An independent re-implementation of Theorem 2's constants. It computes $c_{\rm hi}$ by bisection and $L_S$ by exact logarithms, and reports sensitivity to κ and δ_S. It also covers Prop 2.11 over a grid of κ and d, the Prop 2.8 exponent, Hänni's numbers, and a Version-1 instance.
* **`r2_minimax.py`.** Prop 1.3(i): the example value, the lower bound and minimax equality on random families.
* **`r3_lemmas.py`.** Lemmas 2.1–2.3, the inequality $\bar v\le1-u$, the Hoeffding counting step done exhaustively, and the ψ-algebra of Thm 2(ii)(b) and (iii).
* **`r4_finite_classes.py`.** Exact computation of Thms 1(a), 4(i)–(iii) and 5(ii) in an explicit infinite product class with fill-ins and partial memorisers.
* **`r5_hashing.py`.** Lemma 3.2 on GF(32) with n < q and r < q, and seed collisions (minor 1).
* **`r6_small_items.py`.** Lemma 1.2(iii) wording, Prop 2.13 numbers, c3's ceiling bug, and the Prop 2.8 example.
