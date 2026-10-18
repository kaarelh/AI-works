# Referee A (proofs and philosophy) on track `purpose` (2026-10-18)

*Status: complete referee report on `notes.md` (developer record of 2026-10-17/18), its scripts and outputs in `checks/`, and `refs-report.md`. Independent code in `referee_A_code/`, with outputs saved next to each script. Statuses follow the project conventions; my own claims carry statuses too.*

## Verdict

**Accept after a major revision of T6 and of three labels in T1 and T4. No proof marked "proved" was refuted.**

* **The formal core survives an adversarial check.** I re-derived the following and found them correct as stated, with their hypotheses:
  * the locality and chain-rule results (T1.0-T1.4);
  * the random-question proposition (T1.5);
  * the differentiable case of the local-score theorem (T2.1);
  * the closed forms of T3.1;
  * the dithered-cell identity T3.2 and the coarse case of T3.3;
  * the toy closed forms and crossovers of T4(a);
  * the aggregating-algorithm bound T5.0, and the transfers T5.2-T5.3.

  The saved outputs match what the record reports. I did not re-run the developer's scripts; the record reports byte-identical re-runs. Three points need a hypothesis or attribution fixed:
  * T3.3(b) assumes a bounded density, which the paper's own sinusoid and the Kepler residuals do not have (m1);
  * T3.2 is very probably the Zamir-Feder identity for dithered quantisation (m9);
  * the purpose-SAI regret constant scales with the square of an a priori range bound (m7).
* **T6 does not yet assert only what the evidence supports.** It misses the strongest objection to the author's position, from Bayesian decision theory (M1):
  * posterior plus purpose loss gives a purpose-relative account of accepting an approximate law, with no change to credence;
  * so "a limitation ... of any Bayesian cumulative log loss" overreaches.

  Three further points:
  * the split "credence for possibly true laws, adequacy for false ones" overlooks that adequacy hypotheses at a tolerance are themselves propositions that SAI already holds credences in (M2);
  * Kepler's 8′ is evidence for a tolerance set by observational precision, not for purpose-relativity (M3);
  * "approximate correctness is purpose-relative" needs its purpose-neutral core stated (M7).
* **Three labels overclaim.**
  * P27 ("refuted") and row 6a: the reply's "partition, not metric" holds for every realised data set, and the random question design that grades misses belongs to the data, not to SAI (M4).
  * T4(a)'s "misspecification point" is better described as ideal forecasts on non-nested information, a known mechanism (M5).
  * T4(b): the fine-resolution findings are attributed to T3.3(b)'s fine limit. Its hypothesis fails for these series, and the small-error series are far from the limit at 0.1′ (M6). An independent computation of SAI's ideal rate *confirms* the developer's rankings wherever both decide: 10 of 10 winners at 0.1′ and 10 of 10 at 1800′. But two counts change, and several "disagreements" are tie-breaks between practically identical fits.
* **On the author.** I agree with the record that the author's objection contains no probable error, as directed at the paper's move. With M1 the record should say precisely which move it hits: reading posterior pricing as an account of approximate correctness. It does not hit Bayesian inference as such.

No issue is fatal: every error found is in framing, scope, labels or attribution, and each has a concrete fix below.

---

## What I checked

* **Proofs, line by line:** T1.0, T1.1(a)-(d), T1.2, T1.3, T1.4, T1.5(a)-(e), T2.1, T3.1 (all four families, including the generalised-Gaussian constant), T3.2, T3.3(a), (b) and the atomic case, the T4(a) closed forms and both crossover roots, T5.0, the countable-mixability remark, the non-mixability of absolute loss, T5.2, and T5.3(a)-(c).
  * For T5.3(b) I checked the paper's (T1), which is an "iff" (`basic.tex`, Thm. 3.5), so the pull-back argument has what it needs.
  * For T5.3(c) I checked the paper's App. B (proof search and emission).
  * For T1.5 and Prop. 9.2 I checked the definitions in `setting.tex`, `laws.tex` and the proof of Prop. 9.2 in `app-laws.tex`.
* **Scripts read:** `p1_locality.py`, `p4_kepler.py` and `p5_aggregating.py` in full. I also read the outputs of p2, p3 and `p4_toy`, and the winners table of `p4_kepler_allfits.out`.
* **Hand checks:**
  * CRPS 0.4 and 4.0 on the author's example;
  * $r_A(\Delta)=1+\Delta/(4\ln2)-\log\Delta$ (I integrated the trapezoidal density by hand);
  * $H(B)=0.92193$;
  * $\Delta_c=1.5585$ and $1.4296$ (the latter is the root of $4\ln\Delta=\Delta$);
  * the calibrated CRPS of A′ and B′, 1/3 against 1/2.
* **New computation:** `referee_A_code/ra1_fine_rates.py` (M6).
* **Literature:** WebSearch, 2026-10-18; levels are as in `refs-report.md`. See the Verification log.

---

## Issues

Severity: **fatal** (a claim marked proved is false, or the record's main conclusion fails), **major** (a claim or conclusion that must change before it enters the paper), **minor**.

### Fatal

None.

### Major

**M1. The Bayesian decision-theoretic objection is not engaged, and the T6 conclusion overreaches because of it.**
*Where:* Summary item 6 (iv); T6.1, third bullet; T6.2 row 6b; the paragraph after T6.2 ("the purpose-insensitivity is SAI's own behaviour ... it bites on theory choice among approximate laws"); T6.3's suggested text ("This is a limitation of SAI as a model of theory choice, as of any Bayesian cumulative log loss").

*The objection, steelmanned.* A Bayesian keeps credence and choice apart.
* **Credence is set by conditioning.** That is cumulative log loss, local, and order-independent (T1.1).
* **A purpose enters as the loss of an act.** Accepting, teaching or using an approximate law is an act.
* **The posterior-expected purpose loss ranks approximate laws by purpose.** Choose the Kepler ellipse that minimises $\mathbb E_{\Pi_D}[\sum_Q\lambda(\text{answer}_T(Q),\text{true answer}(Q))]$ over a question distribution. Under SAI's ideal posterior, which on computable data concentrates on near-exact theories (T6.1 itself says so), this ranks the ellipses by their purpose loss against the truth:
  * by maximum error for a tolerance purpose;
  * by RMS for $L^2$.

  That is exactly the ranking the author wants. Credence is unchanged; log loss is never used to grade the approximate law.
* **Philosophy of science has this structure too.**
  * Acceptance as a decision with its own utility: Levi 1967, [B]/[S]; Maher 1993, [B] plus the publisher's description: "a Bayesian decision-theoretic account of rational acceptance", acceptance "not reducible to probability", with a chapter on verisimilitude.
  * Niiniluoto's expected truthlikeness: the posterior expectation of a similarity to the truth. It is "posterior plus purpose loss" applied to false theories (`niiniluoto1987truthlikeness`, already in the paper's bibliography; the SEP supplement "Expected truthlikeness", [S]).
  * Engineering practice: validation is defined "from the perspective of the intended uses of the model" (AIAA 1998 and ASME V&V 10, [S]). Calibration is done by likelihood with a model-discrepancy term (Kennedy and O'Hagan 2001, JRSS B 63:425-464, [B]/[S]).

*What follows.*
* **(a) What the objection hits.** It does not hit Bayesian theory choice as such. It hits the use of the posterior weight, the two-part code length or the $\lambda$-MAP of a law-plus-error-model machine as the measure of approximate correctness. That is precisely the paper's §9 move: "SAI's pricing of a form", "the preferred form", the best system as a $\lambda$-MAP.
* **(b) What T4 shows.** T4's comparisons show that posterior pricing differs from adequacy for a purpose. The Bayesian concedes this in advance, so the comparisons support (a). They do not support the claim that Bayesian inference cannot rank approximate laws by purpose.
* **(c) What survives.**
  * (i) SAI as defined has no act layer. The paper's statements about which form SAI "prefers" are statements about credence or compression, not about approximate correctness.
  * (ii) The decision layer needs a good posterior predictive. For a bounded agent with a restricted, misspecified pool, the posterior predictive is that of the KL projection, and its Bayes acts need not be good for the purpose. There the purpose loss must enter learning itself: general Bayes, or the aggregating algorithm, as in T5, and Grünwald and van Ommen 2017.
  * (iii) The ideal agent may also want a *simple* approximate law, because of computation or communication costs. That trade-off (purpose loss plus a cost) is outside posterior plus purpose loss, and it is where the author's "practical messy grading" lives.

*Fix.*
* **T6.1.** Restructure into three positions:
  * credence: conditioning, log, local;
  * acceptance as a decision: posterior plus purpose loss; Levi, Maher, expected truthlikeness;
  * loss-based learning under misspecification or restricted pools: general Bayes, the aggregating algorithm, T5.
* **T6.2 row 6b.** Change the verdict from "imprecise" to "wrong as stated". Solomonoff-style agents combine the universal mixture with arbitrary losses (Hutter 2003, [A]). The objection reaches posterior weight and code length used as theory-choice criteria, and prediction under misspecification.
* **The paragraph after T6.2.** "SAI's pricing ranks approximate laws without regard to purpose; a Bayesian decision layer would not, given a good posterior; restricted pools need the purpose loss in learning."
* **The last sentence of T6.3's suggested paper text.** Replace with: "This is a limitation of reading SAI's posterior pricing as an account of approximate correctness, as it is of any account that ranks approximate laws by posterior weight or code length. A decision layer (posterior plus a purpose loss) ranks them by purpose when the posterior predicts well, and loss-based updating (T5) is needed when it does not. We know of no canonical purpose."

**M2. The "credence versus adequacy" split misplaces adequacy, and the formal rendering of "purpose" is too narrow for the sources cited.**
*Where:* T6.1, first and second bullets; Summary item 6; T6.3, second bullet.

*Problem.*
* **(a) Adequacy hypotheses are propositions.** An example: "on the window $W$, Kepler's ellipse gives Mars's longitude within 8′". Such a proposition can be exactly true. Parker 2009 ([A]) says that fit confirms hypotheses about adequacy for particular purposes, so adequacy is something one holds credence in. SAI expresses these hypotheses:
  * the honest law $T^\delta$ on a domain is a set of sentences;
  * regime G compatibility is exactly their test (T6.4, first bullet, says so);
  * $\mathrm{Bel}_D$ of the honest law is SAI's credence in the adequacy hypothesis.

  So "credence that the law is true is idle" holds for the *exact* law only. Credence in adequacy hypotheses at a tolerance is the normal case, and SAI already has it.
* **(b) What SAI cannot express is grading, not thresholds.** Threshold purposes are expressible: Kepler's tolerance, and the author's own final criterion, "whether the theory gave answers that were good enough for some purpose". Each is a pass/fail partition per answer, which is what a question family with a tolerance encodes (T1.4). What SAI cannot express:
  * **graded fitness**, that is, how bad a miss is;
  * **any aggregation of pass and fail across answers** other than "all must pass" or the code length of exceptions.

  So T1.4's "partition, not metric" cuts less against SAI than T6 suggests. The author's own grading, as worded, is a threshold.
* **(c) The rendering covers predictive purposes only.** "A purpose is a question family with a resolution plus a loss on answers, or more generally a decision problem" omits:
  * Parker's epistemic purposes of explanation and teaching;
  * her relativisation of adequacy to the user, the methodology and the circumstances (Parker 2020, p. 460, at [S]).

  An example: the use of Kepler's laws in deriving the inverse-square law is not graded by a loss on answers.

*Fix.*
* **Rewrite T6.1's two bullets.** Distinguish:
  * credence in exact laws;
  * credence in adequacy (tolerance) hypotheses, which SAI has;
  * graded fitness for a purpose, which SAI lacks.
* **State the scope.** Our rendering covers predictive purposes. Say "(our rendering, not Parker's)" and that it omits non-predictive purposes and the user and circumstances.
* **Add to T6.3.** "Threshold purposes (good enough at a tolerance) are expressible in SAI; graded ones are not."

**M3. Kepler's 8′ is a tolerance set by observational precision, not an instance of purpose-relative grading.**
*Where:* T6.2 row 5 ("right"); the brief's reply ("Kepler's own test was a maximum-error tolerance").

*Problem.*
* **What the test asked.** The 8′ verdict was fixed by the accuracy of Tycho's observations, about 2′ by the secondary accounts the record cites. It asked whether the hypothesis could be correct given measurement error.
* **What kind of test that is.** It is the truth-directed test of regime G: compatibility at a tolerance set by the data's precision, or equivalently a likelihood test with a bounded measurement-error model. It is not a criterion set by a use.
* **What it supports.** The paper's local notion (question family, tolerance, domain). It does not support "the grading is set by a purpose".

The row's verdict "right" lets the reply use the example for a conclusion it does not support.

*Fix.* Row 5: "right about the form (a maximum-error tolerance); but Kepler's tolerance was set by observational precision, an epistemic criterion (regime G), so the example supports the local notion of a tolerance, not purpose-relativity."

**M4. P27 ("refuted") and row 6a ("wrong for SAI's own regime R") overclaim, and contradict the record's own suggested paper text.**
*Where:* Summary item 6 (i); T6.2 row 6a; P27; T6.3, second bullet (suggested text: "where misses must be graded, a loss on the answers, which it cannot").

*Problem.*
* **(i) Pathwise, the reply's claim holds.** On every realised data set SAI's loss is the log score of the realised cell (T1.3, T1.4, applied per datum). What T1.5 adds is an *expected* loss over a randomised question design.
* **(ii) The grading comes from the data.** It is supplied by the dither, a feature of how the questions are drawn (the experimenter's design), not of SAI. "SAI's own regime R" misattributes it: the paper chose a dithered grid for technical reasons (rational cells, no fixed-grid artefacts; App. G, technical points (i)-(ii)). A question design that grades misses is itself a choice of purpose: a threshold weighting, in the sense of the threshold-weighted CRPS of Gneiting and Ranjan 2011 (JBES 29(3):411-422, [B]/[A]).
* **(iii) The substance of the reply stands.** Literally, $\min(\lvert x-y\rvert/\Delta,1)$ *is* a metric, so the word "metric" in the reply fails for random designs. But the substance holds: no grading beyond the cell width, and for near-point forecasts never squared error (T1.5(d)).
* **(iv) The record contradicts itself.** It calls the reply "refuted" (P27) and then recommends that the paper say SAI cannot grade misses.

*Fix.*
* **P27.** Change its status to "refined": true for every realised data set and for fixed designs. Under a randomised design the expected loss grades misses up to the cell width, by a bounded cut-type metric that comes from the design.
* **Row 6a.** Change to "right pathwise; refined in expectation".
* **Summary item 6 (i).** Same.
* **The T6.3 sentence.** "... and, where misses must be graded beyond the resolution of the questions, a loss on the answers, which it lacks."

**M5. T4(a) illustrates non-nested information, not misspecification.**
*Where:* T4(a) ("Both 'law + calibrated error model' forecasts are wrong ... the misspecification point, with exact numbers"); Summary item 4; T6.2 row 3 ("the objection bites under misspecification"); the brief's T4 title.

*Problem.*
* **Each forecast is ideal for its own information.** In regime R's model the error is independent of the question and of the law's prediction. Then the calibrated forecast $\mathrm{BC}_{\mathcal F}$ is the conditional law of the value given the law's own prediction: an ideal forecast relative to that information (`app-laws.tex`, proof of Prop. 9.2(c): $P^\star=\nu_{\mathrm{BC}_{\mathcal F}}$).
* **The information sets are not nested.** Laws A and B condition on different information, and neither set contains the other.
* **The known mechanism.**
  * For ideal forecasts with *nested* information, every strictly consistent scoring function ranks the better-informed forecast first (Holzmann and Eulert 2014, Ann. Appl. Stat. 8(1):595-621, [A]/[S]).
  * With non-nested information the rankings can depend on the loss (Patton 2020, already cited, [A]; Krüger and Ziegel 2021, JBES 39(4):972-983, [A], for the mean functional).

  T4(a) is an exact distributional instance of this mechanism. Calling it "wrong forecasts" makes every forecast short of the point-mass truth "misspecified", which empties the term.
* **This strengthens the philosophical point.** Competing approximate laws, each with a calibrated error model, are like ideal forecasts on different information. Their ranking is purpose-relative *even without misspecification*. P11 (the Gaussian family for a bimodal truth) remains the genuine misspecification example.

*Fix.*
* **T4(a).** Relabel and cite as above.
* **T6.2 row 3.** "the objection bites under misspecification and whenever the competing laws carry non-nested information (the normal case for rival approximate laws)".
* **The brief's T4 heading.** Keep it, but say in the text that the toy is the non-nested case.

**M6. T4(b): the fine-resolution findings are about the rate at 0.1′, not about T3.3(b)'s fine limit, and two counts change under the ideal rate.**
*Where:* T4(b), second bullet of the four-fit summary ("At fine cell widths it agrees exactly with the plug-in entropy $h_{40}$ (0 disagreements at 0.1′), as T3.3(b) predicts"); Caveats; Summary item 4; P18.

*The computation is confirmed.* I re-ran the comparison with an independent estimate of SAI's ideal rate (T3.3): `referee_A_code/ra1_fine_rates.py`, output `ra1_fine_rates.out`, seed 20261018.
* **Method.**
  * For each fit's 8000 errors, $r(\Delta)=H(C_U(e)\mid U)$ is computed exactly from the empirical law through the identity T3.2. There is no band tied to the fit's own maximum and no bin count.
  * Fit pairs are decided by a paired bootstrap ($B=100$, $\lvert\text{difference}\rvert>2\,$SE).
  * (series, $\Delta$) cells with fewer than 20 samples per cell over the error range are flagged unreliable and excluded. At 0.1′ this excludes the Moon series and the 1000- and 2000-year windows of Mercury, Mars and Jupiter.
* **Results.**
  * **Winners.** Wherever both the developer's SH and the ideal rate name a significantly best fit, they name the same one: 10 of 10 series at 0.1′ and 10 of 10 at 1800′.
  * **Pairwise signs at 0.1′.** $h_{40}$ and $r(0.1')$ agree in sign on 105 of the 108 pairs that $r(0.1')$ decides.
  * **Fine-limit entropy.** Where the $k$-nearest-neighbour estimate of the fine-limit entropy $h$ decides (40 pairs), it agrees with $r(0.1')$ on all 40.

  So the 40-bin machine is a faithful proxy here, and the qualitative T4(b) finding stands: SAI's pricing disagrees with every error-size criterion.

*What must change.*
* **(a) The attribution to T3.3(b).** "Agrees exactly with $h_{40}$ ... as T3.3(b) predicts" misattributes:
  * The quantity computed at 0.1′ is the rate at that cell width, $h(e+V_{0.1'})-\log0.1'$ (T3.3 itself), not the fine limit.
  * T3.3(b)'s hypothesis (a bounded density) fails for these residuals (m1).
  * The gap $r(0.1')-(h-\log0.1')$ over the 112 reliable fits has median 0.058 bits, but reaches 0.53-0.57 bits for Saturn over 12 years, whose errors span only a few tenths of an arcminute.
  * $h_{40}$ is not a robust estimate of $h$: it and a 640-bin plug-in disagree in sign on 35 of the 234 pairs.

  Write instead: "at 0.1′ SH agrees with the 40-bin entropy, and both agree with the exact rate at that cell width (T3.3) where it is decided".
* **(b) The counts are estimator-dependent.**
  * At 0.1′ SH's "none of the three classical winners in 4 of 15 series" becomes 2 of 10 under the ideal rate. Of SH's 15 decided series, 4 cannot be estimated at 0.1′ from 8000 samples (Mercury over 2000 years and the three Moon series) and 1 is undecided (Mercury over 100 years). The two that survive are Mars and Mercury over 30 years, both F3.
  * At 1800′ the ideal rate decides more series than SH: "none" in 5 of 16, against SH's 3 of 10.
  * The ideal rate's ranking changes between 0.1′ and 1800′ in 11 fit pairs, against SH's 16. The definitions differ: I compare only the two ends; the developer counts any significant reversal across the 11 widths.
  * Report the counts with their estimator and these ranges.
* **(c) Effect sizes must accompany "significant".**
  * At the coarse end the reversals involve differences of $10^{-5}$ to $10^{-4}$ bits per datum: one bit per $10^4$-$10^5$ data. Example: Jupiter over 12 years, F3 against L2, $+0.00001$ bits at 1800′.
  * One of the two surviving "none" cases (Mars over 30 years) is a tie-break between two practically identical fits: F3 and L2 have RMS errors $0.57460'$ and $0.57452'$, and rates $4.4778$ and $4.4806$ bits at 0.1′.
  * Such cases show that the rankings are fragile, not that a purpose is at stake. T4(b) should report magnitudes, and separate the substantive disagreements (for example Saturn over 100 years, L1 against the others: $0.55$ bits at 0.1′) from the tie-breaks.

**M7. T6.3: state the purpose-neutral core before declaring approximate correctness purpose-relative; this also makes the A′/B′ result the track's strongest.**
*Where:* T6.3, first bullet; Summary item 6; P29; the brief's "there is no purpose-neutral best approximately true law".

*Problem.* Three things are purpose-neutral, given a question family:
* **The error profile.** The function from questions to (answer, truth) is a purpose-neutral description of a law's approximate correctness. Purposes enter only when it is summarised or thresholded.
* **Dominance.** Suppose that for every question in the family law A's answer lies between the truth and law B's answer. Then every purpose loss that increases with the distance from the truth on each side ranks A at least as well as B, asymmetric losses included.
  * For each scalar quantity this order is invariant under any monotone reparametrisation of that quantity.
  * It is therefore immune to Miller's objection that closeness rankings reverse under a change of the quantities used. That objection is in Miller 1975, "The accuracy of predictions", Synthese 30:159-192, [B]/[S]. It is the classical source for "no canonical metric" and should be cited next to the `miller1974popper` the paper already has.
  * Miller's point survives where it belongs: the *choice of quantities*, which is the question family, is not purpose-neutral.
* **What T4(a)'s A′/B′ shows.** A′ dominates B′ in exactly this sense (same sign, $\lvert e_{A'}\rvert\le\lvert e_{B'}\rvert$ at every time). So the result is stronger than "SAI picks another purpose": SAI's pricing below $\Delta_c=1.4296$ is not the ranking of *any* monotone point-prediction purpose. It is the ranking of the forecast's sharpness.

So the claim "there is no purpose-neutral best approximately true law" holds only in general. When one law dominates the others on the question family, it is best for every monotone purpose.

*Fix.* Add to T6.3: "Given a question family, the error profile and the dominance order are purpose-neutral, and the latter is invariant under monotone reparametrisation of each quantity. Purpose-relativity concerns the choice of quantities (Miller 1975) and the completion of the dominance order to a ranking. SAI's pricing can reverse dominance (T4(a))." Reword the brief's claim as "in general no purpose-neutral best law; a dominant law, when there is one, is best for every monotone purpose".

### Minor

**m1. T3.3(b): the bounded-density hypothesis excludes the cases the track applies it to, and the convergence is slow there.**
* Error laws with turning points have densities with inverse-square-root singularities: the paper's sinusoid (arcsine law) and the Kepler residuals. They are unbounded, so T3.3(b) as proved does not cover them.
* `p3_errormodels.out` shows the slowness. For the arcsine law at $\Delta=0.05$ (2.5% of the range) the rate is $5.16689$, against the fine limit $h-\log\Delta=0.6515+4.3219=4.9734$: still $0.19$ bits above it.
* *Fix:* either prove (b) for densities with finite entropy and bounded support (I believe it holds, but did not check a proof), or state it as proved for bounded densities and computed for the arcsine law. Do not invoke it for the Kepler series at 0.1′ (M6).

**m2. "Distance-blind".**
* $h$ is invariant under measure-preserving rearrangements, but it is not scale-blind: $h(\lambda e)=h(e)+\log\lvert\lambda\rvert$.
* *Fix:* "rearrangement-invariant: sensitive to the volume the errors occupy, blind to where it lies".

**m3. One symbol for two things in T5.1.**
* $[-B,B]$ uses $B$, which is the background theory throughout.
* *Fix:* rename the range bound ($Y$ or $\mathsf b$).

**m4. The general-Bayes identification in T5.2 is one of form only.**
* Bissiri, Holmes and Walker update with a fixed loss $\ell(\theta,x)$ on i.i.d. data, and read the result as a belief distribution about the minimiser of the expected loss. The aggregating algorithm's losses are prequential: $\lambda(\text{act}_i(D_{t-1}),\omega_t)$ depends on the past.
* *Fix:* write "have the exponential-weights form of the general-Bayes posterior", and "credences about which machine minimises the expected purpose loss (in Bissiri et al.'s i.i.d. reading), not about which machine is true".

**m5. T5.4 has two problems.**
* (i) Purpose-SAI is defined as the aggregating algorithm, which needs mixability, and absolute loss is not mixable (P20). The concentration claim for absolute loss holds for exponential weights at any fixed $\eta>0$, without a regret bound. State it that way.
* (ii) The outcome is the cell midpoint $m(a_t)$, not the value. So "expected loss $\mathrm{Var}(e)+\text{bias}^2$" holds only up to quantisation terms of order $\Delta$, or exactly in the limit $\Delta\to0$.

**m6. "The log score is the purpose 'state your credence'" (T6.1).**
* Every strictly proper score makes stating one's credence optimal. What singles out the log score is locality, and with it the chain rule, compression and Kelly betting.
* *Fix:* "the log score is the purpose 'compress' (or 'maximise log-wealth')".

**m7. Purpose-SAI's regret constant scales with the square of an a priori range, and the record omits the number that shows it.**
* With $\eta=1/(2B^2)$ the regret is $2B^2K(G)\ln2$.
* For an unbounded real quantity, square loss is mixable for no $\eta$. The CRPS's constant is linear in the range (V'yugin and Trunov 2019, [A]/[Q]).
* `p5_aggregating.out` part C reports $L_{AA}=603{,}492.9$ against $L_A=1348.2$, bound $1.39\cdot10^6$. The record cites only the final weight and the experts' losses.
* *Fix:* report $L_{AA}$. State that the bound needs a known bounded range and scales as its square.

**m8. `p5` part A at $c=0.4$ reports a positive margin of $2.36\cdot10^{-8}$.**
* This is larger than the $5.9\cdot10^{-11}$ the record quotes at $c=0.5$.
* Both are rounding: the margin takes a square root of round-off at degenerate $\pi$. But the record should report both values and say why they are rounding, rather than cite only $c=0.5$.

**m9. T3.2 is very probably known.**
* A secondary source (Theis and Ahmed, arXiv:2110.12805, [S]) states the Zamir-Feder (1992) result for dithered quantisation as $H[K\mid U]=I[Y;Z]$.
* With a uniform dither on one cell, $I(X;X+N)=h(X+N)-h(N)=h(X+N)-\log\Delta$, which is T3.2.
* The bibliographic data of Zamir and Feder 1992 were not seen; the title is given in secondary sources as "On universal quantization by randomized uniform/lattice quantizers".
* *Fix:* "known (Zamir and Feder 1992, as stated by later work, [S]; our proof is elementary)". Mark T3.3's novelty as its reading as SAI's rate, not the identity.

**m10. Missing literature on scoring rules sensitive to distance.**
* The author's "5 nearby vs 5 scattered" is the classical property of being "sensitive to distance":
  * Staël von Holstein 1970, J. Appl. Meteorol. 9:360-364, [B]/[S];
  * the ranked probability score, Epstein 1969, J. Appl. Meteorol. 8(6):985-987, [B]/[S];
  * Jose, Nau and Winkler 2009, Management Science, doi 10.1287/mnsc.1080.0955, [B].
* The opposite steelman also exists: Wheatcroft 2021 (J. Quant. Anal. Sports 17(4), [A]/[S]) argues that sensitivity to distance adds nothing to the aims of scoring, and that the ignorance (log) score did best in his simulations.
* *Fix:* T2 should say that the objection restates a known property, cite both sides, and keep the threshold-weighted CRPS (Gneiting and Ranjan 2011) as the purpose-weighted proper score closest to T1.5.

**m11. Summary item 1 drops T1.5(d)'s scope.**
* "never like squared error" holds for near-point forecasts. With a Gaussian forecast family, log loss grades misses by squared error even on fixed questions (T3.1).
* *Fix:* "for near-point forecasts".

**m12. P28's status.**
* "refuted" is too strong for a claim the record itself calls true for restricted error families: parametric families fitted by maximum likelihood, the practical case.
* *Fix:* "false for the calibrated (true) error law of Prop. 9.2, where every proper score agrees; true for restricted error families".

**m13. T1.5 states $P$ as a sub-probability, but most theory machines do not give one.**
* For a machine silent inside a band (the honest law $T^\varepsilon$), the cell function $\beta_G$ is a belief function (superadditive), not a measure.
* Parts (a)-(c) still hold: Gibbs' inequality only needs $\sum_{C\in\Pi}\beta_G(C)\le1$ per partition. Part (e) needs additivity.
* In (e), for a sub-probability of total mass $m<1$, the case with no grid point in $J$ costs $-\log m$, not 0.
* *Fix:* state these.

**m14. T2.1's outcome space for SAI is not stated.**
* In the two-valued conventions each SAI question has two outcomes, so locality per question singles out nothing.
* The theorem applies to the joint answer list (four or more outcomes for two questions), or to three-valued questions.
* *Fix:* add one sentence (the refs-report says the same).

**m15. T5.3(b) should check that translated questions are questions.**
* Pairwise incompatibility of $\tau\mathcal Q$ follows from (T1) and $B'\vdash\neg\tau\bot$.
* For the disjunction: $B\cup\{\neg a,\neg b\}\vdash\neg(a\vee b)$ gives $B'\cup\{\neg\tau a,\neg\tau b\}\vdash\neg\tau(a\vee b)$ by (T1) and (T2), while $B'\vdash\tau(a\vee b)$. So $B'\vdash\tau a\vee\tau b$, and likewise for $k$ answers.
* *Fix:* add the line.

**m16. T6.4, second bullet, generalises from two error criteria.**
* "rank the forms as every error-size purpose ... does" rests on maximum error and RMS (and the Gaussian graded fit), with no pointwise dominance shown.
* *Fix:* say "as maximum error, RMS error and the Gaussian graded fit do".

**m17. T6.1, third bullet: the ephemeris is not the truth.**
* "SAI's mixture contains the planetary ephemeris, which eventually beats every Kepler-based machine" is true of the track's synthetic data (plan94 as truth). On real data it presupposes a computable truth or a computable approximation good enough for it.
* *Fix:* add the qualifier.

**m18. The T4(b) significance rule is a heuristic, not a test.**
* The five half-splits share the data, and the rule was chosen after a first run (disclosed).
* *Fix:* call it a stability heuristic.

---

## Claim-by-claim verdicts (P1-P30)

| id | record's status | my verdict |
|---|---|---|
| P1 | proved | correct |
| P2 | proved; computed | correct. The per-machine semimeasure loss is a definition by analogy with Def. 2.5; say so |
| P3 | proved; computed | correct |
| P4 | proved | correct (needs $\nu_G(D)>0$, implicit) |
| P5 | proved | correct, for fixed families |
| P6 | proved; computed | correct; see m13 on belief functions |
| P7 | proved; computed | correct for near-point forecasts; keep the scope (m11) |
| P8 | proved; computed | correct; add the $-\log m$ term for $m<1$ (m13) |
| P9 | proved (differentiable); known | correct; state the outcome space (m14) |
| P10 | computed | correct (CRPS checked by hand) |
| P11 | computed | accepted; this is the genuine misspecification example |
| P12 | proved; computed | correct (all closed forms re-derived) |
| P13 | proved; computed | correct; very probably known (m9) |
| P14 | proved; computed | (a) and the atomic case correct; (b) hypothesis excludes arcsine-type laws (m1) |
| P15 | proved; computed | correct |
| P16 | proved; computed | closed forms and both roots correct; relabel (M5); frame as dominance reversal (M7) |
| P17 | computed | accepted (not re-run: 1110 s) |
| P18 | computed | confirmed by an independent ideal-rate computation (winners agree 10/10 at both ends); drop "as T3.3(b) predicts"; give counts with their estimator (2 of 10 / 5 of 16 under the ideal rate) and effect sizes (M6) |
| P19 | known; proved | correct |
| P20 | known; computed; proved | correct; report $c=0.4$ (m8) |
| P21 | proved given P19 | correct; scale (m7); general-Bayes wording (m4) |
| P22 | proved | correct; add the question check (m15) |
| P23 | proved given Lemma B.2 | correct |
| P24 | proof sketch | acceptable as a sketch, with m5 |
| P25, P26 | open | fine |
| P27 | refuted | change to refined (M4) |
| P28 | refuted | change the wording (m12) |
| P29 | assessment | revise per M1, M2, M7 |
| P30 | assessment | "every error-size purpose" to two criteria (m16); otherwise fine |

---

## What I think T6 should assert (for the revision)

Asserted only where the evidence above supports it.

1. **Posterior pricing is credence, not adequacy.** Prop. 9.2 describes the credence- and compression-best forecast in SAI's mixture. Reading its ranking of law-plus-error-model machines as an account of approximate correctness was the paper's mistake. The retraction of "not a limitation" stands.
2. **Credence can attach to adequacy.** Adequacy hypotheses at a tolerance on a domain are propositions, and SAI holds credences in them; Kepler's test was of this kind, with a tolerance set by precision.
3. **What SAI lacks.** It lacks graded fitness and an act layer. A decision layer (posterior plus purpose loss) supplies purpose-relative acceptance when the posterior predicts well. When it does not, as for bounded agents with restricted pools, the purpose loss must enter learning (T5).
4. **SAI's own pricing ignores purpose in a strong sense.** It depends on the resolution of the questions. At fine resolution it is an entropy of the errors. It can reverse dominance, so it is not the ranking of any monotone point purpose (T3.3, T4(a)).
5. **The purpose-neutral core.** Given the question family, the error profile and the dominance order are purpose-neutral. Purpose-relativity concerns the choice of quantities (Miller 1975) and the completion to a ranking.
6. **"No canonical metric" stands.** Better: "no canonical score, and no canonical choice of quantities".

---

## Verification log

* **Restart check (2026-10-18).** No earlier `referee-A.md`. A skeleton was written first and saved again after the main reading pass.
* **Read:**
  * `../../00-brief.md` (epistemic policy; the "approximate correctness" section);
  * `00-brief.md`;
  * `notes.md` in full;
  * `refs-report.md` in full;
  * the paper's `setting.tex`, `laws.tex`, and `app-laws.tex` (the regime R definition, the proof of Prop. 9.2, the coarse-regime table);
  * the "Approximate truth" paragraph of `limits.tex`;
  * Thm. 3.5 and its proof (`basic.tex`, `app-basic.tex`);
  * App. B's proof search, emission and filter passages (`app-soi.tex`).
* **Scripts read:** `p1_locality.py`, `p4_kepler.py` and `p5_aggregating.py` in full. Outputs read: p1, p2, p3, `p4_toy`, p5, and the winners section of `p4_kepler_allfits.out`. No developer script was re-run: the record reports byte-identical re-runs for p1-p3 and `p4_toy`, and my new computation re-reads `p4_allfits.npz` directly.
* **Hand derivations:**
  * T2.1's Lagrange argument;
  * T3.1's four minima and the constant $2\Gamma(1+1/p)(p\mathrm e)^{1/p}$ at $p=1,2,\infty$;
  * T3.2;
  * T3.3(a) by integrating the three pieces of the density of $e+V$;
  * $r_A$ by integrating the trapezoidal density;
  * $H(B)$, $\Delta_c=1.5585$ and $1.4296$;
  * the calibrated CRPS of A′ and B′ (1/3 and 1/2);
  * the CRPS of the author's example (0.4 and 4.0);
  * the AA telescoping;
  * the non-mixability of absolute loss;
  * T1.5(c)-(e).
* **New code:** `referee_A_code/ra1_fine_rates.py`, seed 20261018, output `ra1_fine_rates.out` (see M6). The run takes about 4 minutes. It reads `checks/p4_allfits.npz` and the winners table of `checks/p4_kepler_allfits.out`.
  * Summary numbers:
    * $h_{40}$ against $r(0.1')$: opposite signs on 3 of 108 pairs both decide;
    * $h_{40}$ against $h_{640}$: opposite on 35 of 234;
    * $r(0.1')$ against $h_{kNN}$: opposite on 0 of 40;
    * ideal-rate winners equal SH winners in 10/10 series at 0.1′ and 10/10 at 1800′;
    * ideal-rate "none of the classical winners": 2 of 10 decided at 0.1′, 5 of 16 at 1800′;
    * 11 fit pairs reverse between 0.1′ and 1800′.
  * The estimators were sanity-checked on a $U[-1,1]$ sample of $2\cdot10^5$: the k-NN entropy is $0.999$ bits against $1$.
  * `ra1_fine_rates.log` is the console copy of the output.
  * Version 1 averaged over 64 midpoint dithers. That misses narrow error supports at coarse cell widths and gave $r(1800')=0$ for whole series, an artefact of my code, not of the developer's. Its output is kept as `ra1_fine_rates_v1_midpoint_BUG.out` and is not used.
  * Version 2 computes the dither average exactly, through T3.2 applied to the empirical law. It matches the closed forms: for $U[-1,1]$, $4.35774$ against $4.35800$ at $\Delta=0.1$ (sampling); in the coarse regime it equals $(1/\Delta)\int H_2(F_{\rm emp})$ to $10^{-14}$.
* **Literature (WebSearch, 2026-10-18; levels as in `refs-report.md`):**
  * Holzmann and Eulert 2014, Ann. Appl. Stat. 8(1):595-621 [B], [A]/[S]: nested information sets and consistent scoring functions;
  * Krüger and Ziegel 2021, JBES 39(4):972-983 [B], [A]: forecast dominance under non-nested information, for the mean;
  * Staël von Holstein 1970, J. Appl. Meteorol. 9:360-364 [B], [S]: sensitive to distance;
  * Epstein 1969, J. Appl. Meteorol. 8(6):985-987 [B], [S]: the RPS;
  * Jose, Nau and Winkler 2009, doi 10.1287/mnsc.1080.0955 [B];
  * Wheatcroft 2021, J. Quant. Anal. Sports 17(4) [B], [A]/[S]: the case against the RPS;
  * Gneiting and Ranjan 2011, JBES 29(3):411-422, doi 10.1198/jbes.2010.08110 [B], [A]/[S]: the threshold-weighted CRPS;
  * Miller 1975, "The accuracy of predictions", Synthese 30:159-192 [B], [S]: rankings of closeness reverse under transformation of the quantities;
  * Niiniluoto 1987 [B]; the SEP supplement "Expected truthlikeness" [S];
  * Levi 1967, *Gambling with Truth* [B], [S];
  * Maher 1993, *Betting on Theories* (CUP) [B] plus the publisher's description;
  * Parker 2020, p. 460 (target, user, methodology, circumstances) [S];
  * Kennedy and O'Hagan 2001, JRSS B 63:425-464 [B], [S]: model discrepancy;
  * the AIAA 1998 and ASME definition of validation "from the perspective of the intended uses" [S];
  * Zamir and Feder 1992: the content at [S] via arXiv:2110.12805; bibliographic data not seen;
  * Bernardo 1979's abstract, as reported by search, does not mention "pure inference" or local scores, so nothing beyond the refs-report's attribution should be made;
  * Selten 1998 (Exp. Econ. 1:43-61) characterises the quadratic rule [B], [A]; no claim about the log rule was seen, so I cite it for nothing.
* **No git commands were run.** I wrote only `referee-A.md` and `referee_A_code/`.
