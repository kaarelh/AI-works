# Reference check, track "purpose" (2026-10-17/18)

*Reference checker of track `purpose`. Inputs: `../../00-brief.md` (section "Approximate correctness: where the discussion stands"), `00-brief.md` (T1–T6), `../../../paper/bib/{refs,core}.bib` and `bib-report.md`. Outputs: `refs.bib` (39 entries) and this report, plus one sanity-check script, `checks/refs_c1_attributions.py`, with its output `checks/refs_c1_attributions.out`.*

**Restart check.** When this run began, `tracks/purpose/` held only `00-brief.md` and an empty `checks/`. There was no earlier output to recover. Both files were written first as skeletons and saved after each batch of searches.

## How things were checked

* **Searches.** About 60 WebSearch queries were run on 2026-10-17/18.
* **No full text could be read.**
  * WebFetch fails with a DNS error (`getaddrinfo ENOTFOUND`).
  * `curl` through the agent proxy gets `403` on CONNECT for every host tried: arxiv.org, export.arxiv.org, projecteuclid.org, apps.dtic.mil, sites.stat.washington.edu, api.crossref.org, semanticscholar.org, ir.cwi.nl, pmc.ncbi.nlm.nih.gov, boa.unimib.it, mwarmuth.bitbucket.io, onlineprediction.net, durham-repository.worktribe.com, www2.karlin.mff.cuni.cz and public.econ.duke.edu.
  * So "seen" means seen in the text the search tool returned. That text is machine-written, and its quotations were not checked against the pages.
* **Levels.** These are the levels of `paper/bib/bib-report.md`:
  * **[B]**: bibliographic data seen;
  * **[A]**: the abstract or the publisher's description seen;
  * **[Q]**: a passage of the work itself quoted in the results;
  * **[S]**: a secondary source states the content.
* **The rule for writers.** Attribute nothing beyond the recorded level. Give no theorem number, equation number or constant that is not recorded below.

---

## 0. Summary

| key | data | content level | cite for | target |
|---|---|---|---|---|
| `bernardo1979expected` (reused) | Ann. Statist. 7(3):686–690, 1979 | [S], with a [Q] of Gneiting–Raftery | log score = the local proper scoring rule, under regularity conditions | T1, T2 |
| `good1952rational` | JRSS B 14(1):107–114, 1952 | [S] | origin of the log score | T2 |
| `shuford1966admissible` | Psychometrika 31(2):125–145, 1966 | [A], [S] | log rule unique among differentiable "actual-cell" rules | T2 |
| `mccutcheon2019favor` | Philos. Sci. 86(2):286–303, 2019 | [A] | the same without differentiability | T2 |
| `matheson1976scoring` | Manag. Sci. 22(10):1087–1096, 1976 | [A], [S] | origin of the CRPS | T2 |
| `gneiting2007strictly` | JASA 102(477):359–378, 2007 | [A], [Q], [S] | propriety; CRPS; energy score; Bernardo's theorem as stated there | T2, T4 |
| `parry2012proper` | Ann. Statist. 40(1):561–592, 2012 | [A] | "local" for densities; higher-order local rules | T2 |
| `dawid2012proper` | Ann. Statist. 40(1):593–608, 2012 | [A] | "local" on discrete spaces (neighbourhoods) | T2 |
| `ehm2012local` | Ann. Statist. 40(1):609–637, 2012 | [A] | order-2 local rules; Hyvärinen score | T2 (only if needed) |
| `hyvarinen2005estimation` | JMLR 6:695–709, 2005 | [A], [S] | score matching; the Hyvärinen score | T2 (only if needed) |
| `dawid2007geometry` | AISM 59(1):77–93, 2007 | [A] | every decision problem induces a proper score, entropy and divergence | T6 |
| `dawid2014theory` | METRON 72(2):169–183, 2014 | [A], [S] | survey | T2 |
| `dawid2016minimum` | Scand. J. Stat. 43(1):123–138, 2016 | [A] | minimum-score estimation | T4 |
| `grunwald2004game` | Ann. Statist. 32(4):1367–1433, 2004 | [A] | entropy and worst-case loss are dual for arbitrary losses | T6 |
| `gneiting2011making` | JASA 106(494):746–762, 2011 | [A], [S] | the scoring function must match the functional (mean ↔ Bregman, median ↔ absolute error) | T3, T6 |
| `patton2020comparing` | JBES 38(4):796–809, 2020 | [A] | under misspecification, rankings depend on the consistent loss | T4 |
| `vovk1990aggregating` | COLT 1990, 371–383 | [A] | the aggregating algorithm (AA) | T5 |
| `vovk1998game` | JCSS 56(2):153–173, 1998 | [B], [S] | mixability; optimal constants | T5 |
| `vovk2001competitive` | Int. Stat. Rev. 69(2):213–248, 2001 | [A], [S] | AA Lemma 1 (bound with a prior over the pool) | T5 |
| `haussler1998sequential` | IEEE TIT 44(5):1906–1925, 1998 | [A], [S] | log N versus √(ℓ log N) dichotomy; square loss on [0,1] | T5 |
| `vovk2009prediction` | JMLR 10:2445–2471, 2009 | [Q] of the abstract | the Brier game is mixable | T5 |
| `vyugin2019online` | PMLR 105:163–177, 2019 | [A], [Q] | the CRPS is mixable; AA regret (b−a)/2·ln N | T5 |
| `kalnishkan2008weak` | JCSS 74(8):1228–1244, 2008 | [A] | weak aggregating algorithm (WAA): additive C√n for bounded games | T5 |
| `cesabianchi2006prediction` | CUP 2006 | [B], with table-of-contents [Q] fragments | §3.5 the aggregating forecaster, §3.6 mixability | T5 |
| `vovk1998universal` | COLT 1998, 12–23 | [A], [S] | origin of predictive complexity | T5 |
| `vovk1999complexity` | Comput. J. 42(4):318–322, 1999 | [A] | complexity approximation principle | T5 |
| `kalnishkan2004loss` | TCS 313(2):195–207, 2004 | [A] | loss ↔ predictive complexity (Legendre transformation) | T5 |
| `vovk2015fundamental` | LNCS 9300:307–318, 2015 | [A], [Q] | log loss is "most selective"; predictive complexity for log loss is −ln M + O(1) | T5, T6 |
| `hutter2003optimality` | JMLR 4:971–1000, 2003 | [A] | Solomonoff-type Bayes mixture under general loss (well-specified case) | T5 |
| `bissiri2016general` | JRSS B 78(5):1103–1130, 2016 | [A], [S] | loss-based (general) Bayesian updating | T6 |
| `holmes2017assigning` | Biometrika 104(2):497–503, 2017 | [A] | choosing the power w | T6 |
| `grunwald2012safe` | ALT 2012, LNCS 7568:169–183 | [A] | Safe Bayes | T6 |
| `grunwald2017inconsistency` | Bayesian Anal. 12(4):1069–1103, 2017 | [A] | Bayes fails under misspecification; learning-rate repair | T4, T6 |
| `parker2020model` | Philos. Sci. 87(3):457–477, 2020 | [A] | adequacy-for-purpose view of model evaluation | T6 |
| `parker2009confirmation` | Arist. Soc. Suppl. 83(1):233–249, 2009 | [A] | fit confirms adequacy-for-purpose hypotheses, not models | T6 |
| `bokulich2021data` | EJPS 11(1):31, 2021 | [A] | data are evaluated for adequacy-for-purpose | T6 |
| `teller2001twilight` | Erkenntnis 55(3):393–415, 2001 | [B], [S] | context fixes the relevant similarity | T6 |
| `weisberg2013simulation` | OUP 2013 | [A] | weighted feature-matching; goals set the weights | T6 |
| `murphy1993what` | Weather Forecast. 8(2):281–293, 1993 | [A] | consistency, quality and value of forecasts | T6 |

**Keys already in `paper/bib/refs.bib` that this track should reuse rather than duplicate:**
* `berk1966limiting` and `kleijn2006misspecification`: the posterior concentrates on the KL minimisers (the KL projection); [A] there.
* `niiniluoto1987truthlikeness`: the similarity approach to truthlikeness.
* `moulines1976approximate`: approximation in empirical theories.
* `cartwright1983how` and `morgan1999models`.
* `kepler1992new`: the 8′ discrepancy, at [S] there.
* `pettigrew2016accuracy`, `leitgeb2010objective` and `greaves2006justifying`: the accuracy-first arguments for the Brier score, and conditionalisation as maximising expected epistemic utility.

**Not added (bibliographic data incomplete or content not seen)**, see §6.

---

## 1. Locality and the logarithmic score (T1, T2)

### `bernardo1979expected`: Bernardo (1979)

* **How verified.**
  * [B] Project Euclid record: Ann. Statist. 7(3):686–690, May 1979, doi 10.1214/aos/1176344689.
  * [A] The abstract is about expected information as expected utility in the design of experiments. **It does not state the scoring-rule theorem.**
  * The theorem is attributed to this paper by:
    * Gneiting–Raftery 2007 ([Q], quoted below);
    * Parry–Dawid–Lauritzen 2012 [S];
    * Ehm–Gneiting 2012 [S];
    * Dawid–Musio 2014 [S].
* **Exact statement, as Gneiting–Raftery report it** ([Q]):
  > "Bernardo (1979) studied local scoring rules S(p, ω) that depend on the predictive density p only through its value at the event ω that materializes. Assuming regularity conditions, he showed that every proper local scoring rule is equivalent to the logarithmic score, in the sense of (2)."

  * Their "equivalent" means S(p, ω) = a log p(ω) + f(ω), for a constant a ≥ 0 and a function f of the outcome alone.
  * The search text gives this form, as in the DTIC copy.
  * Gneiting–Raftery use positive orientation (larger is better).
* **Hypotheses to state.**
  * **Regularity conditions** (smoothness). These were not seen. Write "under regularity conditions".
  * **Densities (continuous case).** For a finite outcome set, see the discrete statement below.
  * **"Local" in the strict sense of order 0.** The score depends on the forecast only through the probability, or density, it gives the realised outcome.
  * **Proper, not necessarily strictly proper.** a = 0 gives a degenerate rule. Strict propriety forces a > 0.
* **The discrete case.**
  * **What the literature says.**
    * The usual form is: on a finite set with at least three outcomes, the proper local rules are exactly a log q(x) + f(x) with a ≥ 0. Wikipedia ("Scoring rule") states it as "affine functions of the logarithmic scoring rule are the only strictly proper local scoring rules on a finite set that is not binary" [S].
    * Shuford–Albert–Massengill 1966 prove it for rules given by a differentiable function of the probability of the actual cell [S, via McCutcheon].
    * McCutcheon 2019 removes the differentiability assumption [A].
  * **The binary exception is elementary (proved).** With two outcomes, q(x) determines q. So every scoring rule is local, and the Brier score is a proper local rule that is not affine in log q(x).
  * **For the paper.** State "at least three outcomes" and give the two-line binary counterexample yourself. Do **not** cite Shuford et al. for the "≥ 3" hypothesis: their abstract's "negative result for more than two answers" was not identified further.
* **What may be attributed.** In the continuous case, under regularity conditions, every proper scoring rule that depends on the forecast only through the density at the realised outcome is a log p(x) + f(x), a ≥ 0 (Bernardo 1979; see Gneiting–Raftery 2007, Parry–Dawid–Lauritzen 2012). The discrete statement follows the bullets above.
* **Relevance to T1.**
  * SAI scores a theory machine on a finite data set D through ν_G(D). That is the log score of the event "the answers are D", the order-0 local case.
  * Bernardo's theorem is then the reason why *any* proper score that sees only ν_G(D) is the log score, up to an affine map. This is the precise sense of "the log score is *the* local proper score".
  * The hypothesis matters for SAI. The relevant outcome space is the set of possible answer-tuples, which has at least three elements once there are two or more three-valued questions, or two binary ones.

### `good1952rational`, `shuford1966admissible`, `mccutcheon2019favor`

* **Good 1952.**
  * [B] Science Museum Group record and a Philosophy of Science reference list: JRSS B 14(1):107–114.
  * [S] The log score is attributed to it (Dawid–Musio: "the log score (Good 1952)"; it was called "Ignorance" in meteorology after Roulston–Smith 2002).
  * Cite it for the origin of the log score only.
* **Shuford, Albert and Massengill 1966.**
  * [B] Cambridge listing and a 1976 citing list: Psychometrika 31(2):125–145.
  * [A] Scoring systems that reward only honest reports of degrees of belief, and a method to generate them.
  * [S] The uniqueness of the log rule among rules given by a *differentiable* function of the probability of the actual cell.
* **McCutcheon 2019.**
  * [B] Philos. Sci. 86(2):286–303, doi 10.1086/702028.
  * [A] The abstract: the Shuford et al. theorem holds without differentiability; new arguments for the log rule.
  * Its exact hypotheses (number of cells; proper or strictly proper) were not seen.

### `parry2012proper`, `dawid2012proper`, `ehm2012local`, `hyvarinen2005estimation`, `dawid2014theory`

These delimit "local".
* **Parry, Dawid and Lauritzen 2012.**
  * [A] On the real line, the log score is the only proper rule that depends on the density only through its value at the outcome.
  * If the score may also depend on m derivatives at the outcome ("order m"), proper local rules exist for every even m and for no odd m.
  * For m ≥ 2 they do not need the normalising constant.
* **Dawid, Lauritzen and Parry 2012 (discrete).**
  * [A] A rule is local if it depends on the probabilities of points in a nominated neighbourhood of the outcome.
  * Such rules are characterised by homogeneous functions on the cliques of an undirected graph.
  * In this broader sense there are local proper rules other than the log score, and they need q only up to scale.
* **Ehm and Gneiting 2012.** [A] Order 2 characterised for a broad class of Lebesgue densities; their keywords include "Hyvärinen score".
* **Hyvärinen 2005.**
  * [A] Score matching.
  * Its reading as an order-2 local proper rule is [S].
* **Dawid and Musio 2014.** [B]: METRON 72(2):169–183, with no DOI seen. A survey [A, S].
* **For the paper.** SAI's data are discrete answers, so only order 0 is relevant.
  * If "local" is used, define it as order 0 (dependence only on the probability of the realised answers), and say in one clause that broader notions exist (neighbourhoods on discrete spaces; derivatives for densities) [Parry–Dawid–Lauritzen 2012; Dawid–Lauritzen–Parry 2012].
  * Do not discuss Hyvärinen-type scores further: they do not bear on SAI.

---

## 2. Distance-sensitive scores: CRPS and the energy score (T2)

### `gneiting2007strictly`: Gneiting and Raftery (2007)

* **How verified.**
  * [B] Heidelberg and SUFE records: JASA 102(477):359–378, doi 10.1198/016214506000001437.
  * The earlier version is UW Statistics Technical Report 463 (2004, DTIC ADA459827).
  * [A] the abstract.
  * [Q] passages of the technical report in the search text.
  * [S] citing papers.
  * Same key and fields as the SOI and inferential-learning bibliographies.
* **Exact statements that may be attributed.** All scores are positively oriented, as in the paper.
  * **Propriety.** S(Q, Q) ≥ S(P, Q) for all P, Q in the class, where S(P, Q) = E_Q S(P, X). The rule is strictly proper if equality holds only for P = Q [A].
  * **CRPS** [Q]. On ℝ:

    CRPS(F, x) = −∫ (F(y) − 1{y ≥ x})² dy = ½ E|X − X′| − E|X − x|,

    with X, X′ independent draws from F. It is "proper but not strictly proper relative to P. It is strictly proper relative to the class P₁ of probability measures on (ℝ, 𝓑) that have finite first moment" [Q of the tech report]. The kernel form is the kernel score with |z − z′| (§5.1 per [S]).
  * **Energy score** [S]. ES(P, x) = ½ E‖X − X′‖^β − E‖X − x‖^β with 0 < β < 2. It is strictly proper relative to the Borel probability measures with E‖X‖^β < ∞. Székely (2003) gave the first proof. For β = 1 in one dimension it is the CRPS.
  * **Bernardo's theorem** as quoted in §1 [Q].
  * **Optimum (minimum) score estimation** [S]. The estimator maximises the average score. It is consistent for the true parameter when the score is strictly proper and the model is well specified. The log score gives maximum likelihood.
* **Not seen.** Equation numbers; the section of the Bernardo passage; the sections of the CRPS and energy-score definitions. Search results suggest §4.2 and §4.3 [S, unconfirmed]. Cite without numbers.
* **The threshold reading (an identity, no citation needed).** The integrand (F(t) − 1{x ≤ t})² is the Brier score of the probability forecast F(t) for the binary event {X ≤ t}. So the (negatively oriented) CRPS is the integral over t of these Brier scores.
  * The marginal forecasts F(t) are scored separately, without conditioning one threshold event on another.
  * That is the contrast T1 needs with cumulative log loss, which conditions.
* **Matheson–Winkler 1976 and Hersbach 2000.** Several sources credit the "Brier integrated over thresholds" reading to Matheson–Winkler 1976 and Hersbach 2000 [S]. Hersbach is not in `refs.bib` (§6).

### `matheson1976scoring`: Matheson and Winkler (1976)

* **How verified.**
  * [B] INFORMS, Duke and Springer: Management Science 22(10):1087–1096, doi 10.1287/mnsc.22.10.1087.
  * [A] the abstract (scoring rules for continuous distributions).
  * [S] The CRPS is credited to this paper.
* **May be attributed.** "The CRPS (Matheson and Winkler 1976; Gneiting and Raftery 2007)". Gneiting–Raftery cite it for the CRPS. Do not attribute a specific formula or theorem to Matheson–Winkler.

### Check of the author's example (`checks/refs_c1_attributions.out`, part 3)

* **Setup.** Forecasts uniform on {−2, −1, 0, 1, 2} and uniform on {−40, −17, 0, 23, 51}. The outcome is x = 0, contained in both.
* **Log score.** Both give log₂ 5 = 2.3219 bits.
* **CRPS (negatively oriented).** 0.400 for the nearby forecast and 8.440 for the scattered one.
* **The two CRPS forms agree** to 10⁻¹⁵. This confirms the transcription of the formula above.
* This is a sanity check of the transcription. The developer's T2 computation is separate.

---

## 3. Point-forecast losses, misspecification and ranking (T3, T4)

### `gneiting2011making`: Gneiting (2011)

* **How verified.**
  * [B] JASA 106(494):746–762, doi 10.1198/jasa.2011.r10138.
  * [A] the abstract: averaging scores misleads unless the scoring function and the task are matched; with a functional directive, the scoring function must be *consistent* for it.
  * [A/S] A scoring function is consistent for the mean iff it is a Bregman function, and for a quantile iff it is generalised piecewise linear. Absolute error is strictly consistent for the median (CRAN `scoringfunctions` documentation, citing it).
* **May be attributed.**
  * A point forecast is evaluated well only by a scoring function consistent for the functional it is meant to report.
  * Squared error goes with the mean (a Bregman case) and absolute error with the median.
* **Use in T3.**
  * The error-density families correspond to these functionals:
    * fixed-scale Gaussian ↔ squared error ↔ mean;
    * Laplace ↔ absolute error ↔ median;
    * uniform ↔ maximum error ↔ midrange.
  * The correspondence itself is the developer's derivation. Gneiting 2011 supports only the general point that the loss must match the functional.

### `patton2020comparing`: Patton (2020)

* **How verified.**
  * [B] Duke Scholars, DukeSpace, IDEAS: JBES 38(4):796–809, October 2020. No DOI seen.
  * [A] the abstract.
* **Exact statement (abstract level).**
  * Rankings agree across all consistent loss functions when three conditions hold:
    * the models are correctly specified;
    * there is no estimation error;
    * the information sets are nested.
  * Misspecification, estimation error or non-nested information generally make the ranking depend on which consistent loss is used.
  * Patton recommends that forecast users name the specific loss, not only the target functional.
* **May be attributed.** This is the closest published statement of the brief's claim that "proper scores all rank the truth first but rank wrong theories differently". It is for point forecasts and consistent scoring functions for a functional, not for full predictive distributions and proper scoring rules.
* **For distributions, cite instead:**
  * strict propriety (Gneiting–Raftery 2007) for "the truth ranks first under every strictly proper score";
  * `berk1966limiting` and `kleijn2006misspecification` (paper keys) for "the log-loss Bayesian posterior concentrates on the KL projection".
* **What was not found.** No source was seen that *states*, for distributions, that different proper scores have different minimisers under misspecification. It is elementary: the minimum-score target argmin_θ E_true S(P_θ, X) depends on S.
  * Mark it as proved in the record.
  * T4(a)'s toy gives the instance.
  * Dawid–Musio–Ventura 2016 [A] and Gneiting–Raftery 2007 [S] treat minimum-score estimation, and may be cited for the estimator, not for the misspecified-target statement.

### `dawid2016minimum`, `dawid2007geometry`, `grunwald2004game`

* **Dawid, Musio and Ventura 2016.**
  * [B] Scand. J. Stat. 43(1):123–138, doi 10.1111/sjos.12168.
  * [A] Every proper scoring rule gives an unbiased estimating equation; minimum-score estimation, robustness and intervals.
* **Dawid 2007.**
  * [B] AISM 59(1):77–93, doi 10.1007/s10463-006-0099-8.
  * [A] A decision problem (outcomes, actions, loss) yields a proper scoring rule, an entropy, a divergence, a metric and an estimating equation: the "decision geometry".
  * Use it for the following. A purpose, given as a decision problem with a loss, induces a proper scoring rule on forecasts. The forecast is scored by the loss of its Bayes act. So "purpose losses" and "proper scores" are not rival kinds of thing: each purpose has its own proper score.
  * This bears on T6. The log score is the proper score of one particular decision problem (stating a distribution, with self-information loss).
* **Grünwald and Dawid 2004.**
  * [B] Ann. Statist. 32(4):1367–1433, doi 10.1214/009053604000000553.
  * [A] Maximum generalised entropy and minimax expected loss are dual, for arbitrary losses.
  * Cite it for the loss-relativity of entropy and divergence.

---

## 4. The aggregating algorithm, mixability and universal weights (T5)

### The bound with prior weights

* **How verified.**
  * `vovk2001competitive`: [B] Wiley record; [A] the abstract.
  * Lemma 1 is restated in a Royal Holloway thesis on the aggregating algorithm and regression [S]:

    > For any learning rate η > 0, prior P₀ [on the pool] and T = 1, 2, …: Loss_T(AA) ≤ log_β ∫ β^{Loss_T(θ)} P₀(dθ), β = e^{−η},

    in a perfectly (η-)mixable game. The search text showed "=". The AA's loss is bounded by this mixture term; equality holds for the "generalised prediction".
  * The same form, "for any initial weights distribution on experts", appears in Vovk's line of work (Zhdanov–Vovk, "Linear probability forecasting", arXiv:1001.0879, a lemma [Q fragment]).
  * Origins:
    * Vovk 1990 (`vovk1990aggregating`; [A] the AA, generalising Weighted Majority and the Bayes rule);
    * Vovk 1998 (`vovk1998game`; [B] only; [S] mixability and the optimal constants).
* **Corollary (proved; one line).** Take a countable pool with weights w_k > 0, Σ w_k ≤ 1. Then

  Loss_T(AA) ≤ −(1/η) ln Σ_k w_k e^{−η Loss_T(k)} ≤ Loss_T(k) + ln(1/w_k)/η for every k.

  With w_k = 2^{−K(k)} the regret against k is at most K(k)·ln 2/η.
* **Numerical check.** `refs_c1_attributions.out`, part 2: square loss on [−1, 1], 40 constant experts, w_k ∝ 2^{−k}, 2000 seeded outcomes. Loss(AA) = 293.20 ≤ mixture term 296.30 ≤ min_k [L_k + ln(1/w_k)/η] = 296.35.
* **For log loss with η = 1, AA is Bayes.** The weights are posterior probabilities. The search text reports that Vovk shows "the aggregating algorithm reduces to Bayesian updating when log loss is used" [S, via Reid, Frongillo, Williamson and Mehta, "Generalized mixability via entropic duality", arXiv:1406.6130].
* **For other losses, the AA weights after T rounds are ∝ w_k e^{−η L_k}.** This is exactly Bissiri–Holmes–Walker's general-Bayes posterior with loss L and w = η (elementary identity).
  * So "the weights are then not credences" (brief) is right in the sense that they are not conditional probabilities that the hypothesis is true.
  * They are, however, the loss-based belief distributions of `bissiri2016general`.
  * The paper should say this rather than leave the weights uninterpreted.

### The mixability constant of square loss

* **What the literature says.**
  * Outcomes and predictions in [0, 1]: η = 2.
    * Cesa-Bianchi–Lugosi §3.6 [Q fragments]: the conditions "are easily verified with η = 2" and "are satisfied also when D = Y = [0, 1]".
    * Haussler–Kivinen–Warmuth 1998 [A]: extension to [0, 1]; optimal constant.
    * Mhammedi–Williamson (arXiv:1403.2433) [S]: square loss on binary outcomes is 2-mixable, citing Haussler et al. 1998.
    * Vovk–Zhdanov 2009 [S]: square loss is mixable on a bounded interval (Haussler et al. 1998).
  * Exp-concavity, the weaker property the plain exponentially weighted average needs, holds on [0, 1] only for η ≤ 1/2 [S].
* **Rescaling (proved).**
  * If y = a + (b − a)y′, the loss becomes (b − a)²(y′ − p′)². An η-mixable loss multiplied by c is η/c-mixable.
  * So square loss on [a, b] is mixable with η = 2/(b − a)², and on [−B, B] with **η = 1/(2B²)**. This confirms the brief's value.
  * Exp-concavity on [−B, B] holds for η ≤ 1/(8B²).
* **Numerical check.** `refs_c1_attributions.out`, part 1, B = 1 and B = 3, 400 random pools per setting plus scanned two-endpoint pools.
  * At η = 1/(2B²), Vovk's substitution γ* = (G(−B) − G(B))/(4B) dominates every pool tried. The largest gap is −4.7·10⁻⁷ (B = 1) and −4.3·10⁻⁵ (B = 3), so it is ≤ 0.
  * At η = 1.05/(2B²) a two-endpoint pool is not dominated by any prediction (gap +3.2·10⁻³ and +2.8·10⁻²).
  * So 1/(2B²) is the largest η, as the literature's optimality of η = 2 on [0, 1] implies.
* **Do not use** the value 1/(4Y²) given in one 2022 PMLR paper for the square loss on a ball of radius Y. It concerns a different (vector-valued) setting and was not checked.

### Absolute loss

* **What is verified.**
  * Haussler–Kivinen–Warmuth [A]: the minimax regret is Θ(log N) or Θ(√(ℓ log N)), depending on the loss.
  * Absolute loss is not perfectly mixable [S: a 2002 Information and Computation abstract on predictive complexity for absolute loss; bibliographic data incomplete, not in `refs.bib`].
  * Kalnishkan–Vyugin 2008, the weak aggregating algorithm [A]: "additive terms of the form C√n for bounded games".
  * Kalnishkan–Vyugin COLT 2002, "Mixability and the existence of weak complexities", pp. 105–120, doi 10.1007/3-540-45435-7_8 [A, via mlanthology]: for many non-mixable games, weak predictive complexity exists up to order √n. It is not in `refs.bib` because the LNCS volume number was not seen.
* **May be attributed.** For absolute loss there is no bound of the form L_k + O(ln(1/w_k)). The available guarantees have an additive term of order √T (WAA: C√n for bounded games).
* **Not seen.** The WAA's dependence on the prior weights, the constant C, and Cesa-Bianchi–Lugosi's Chapter 2 theorem (the √(T ln N /2) bound for convex bounded losses). Do not state constants.

### Other mixable proper scores

* **`vovk2009prediction`.** [Q of the abstract] "the Brier game of prediction is mixable", with the optimal learning rate and substitution function.
* **`vyugin2019online`.**
  * [A] "CRPS is a mixable loss function". The aggregating algorithm with CRPS loss has a time-independent regret bound.
  * [Q, extended arXiv version] the bound is "(b−a)/2 ln N" for outcomes in [a, b].
  * **This is the cleanest bridge for T5.** A distance-sensitive *proper* score (the CRPS) is mixable, so the aggregating algorithm with universal weights gives regret ≤ (b − a)·K(k)·ln 2/2 against every forecaster k in the pool.
  * The implied η = 2/(b − a) is my inference from the form of the bound. It was not seen stated.

### Predictive complexity: prior art for "Solomonoff with a purpose loss"

* **The finding.** The idea in the brief ("Vovk's aggregating algorithm with prior weights 2^(−K(T)) gives Solomonoff-style competitive bounds for mixable losses") already exists in the literature as **predictive complexity**.
* **Vovk and Watkins 1998** (`vovk1998universal`). [B, A] AA for portfolio selection; computability assumptions lead to "extensions of Kolmogorov complexity". [S, Royal Holloway overview]:
  * in every mixable game there is an optimal aggregating strategy that loses at most an additive constant against any lower semicomputable strategy;
  * that minimal loss is the predictive complexity;
  * log and square loss give mixable games;
  * logarithmic complexity coincides with a variant of Kolmogorov complexity based on Levin's a priori probability.
* **Vovk 2015** (`vovk2015fundamental`), [Q via search]:
  * for a computable mixable loss, a smallest upper semicomputable superloss process exists up to an additive constant;
  * under log loss it equals −ln M(σ) + O(1), with M Levin's a priori semimeasure (binary sequences).
* **Vovk and Gammerman 1999** (`vovk1999complexity`). [A] The complexity approximation principle generalises MDL and MML through predictive complexity. For log loss it reduces to MDL [S].
* **Kalnishkan, Vovk and Vyugin 2004** (`kalnishkan2004loss`). [A] The loss can be recovered from its predictive complexity via the Legendre transformation.
* **Consequences for T5.**
  1. **Cite this line as prior art.** The new content of T5 can only be the SAI analogue: theory machines and question–answer data instead of sequences and predictors. The general "universal weights with a mixable purpose loss" bound is not new.
  2. **What the class must be.** Predictive complexity is defined through *upper semicomputable superloss processes*. This is the exact analogue of semimeasures and of SAI's semimeasure convention. It answers T5's "say what the class must be": not the total computable predictors (not effectively enumerable), but the enumerable class of superloss processes, with a universal element up to an additive constant.
  3. **For absolute loss** only weak (O(√n)) complexities exist, per the Kalnishkan–Vyugin COLT 2002 abstract (above).
* **`hutter2003optimality`.**
  * [B] JMLR 4:971–1000.
  * [A] The Solomonoff-type Bayes mixture, acting Bayes-optimally under a general bounded loss, has cumulative expected loss close to that of the informed predictor when the true distribution is in the class. The paper includes a comparison with expert advice.
  * This is the *credence* route to purpose losses (well specified, expected loss). The aggregating algorithm is the *worst-case* route (individual sequences, misspecification-tolerant). The paper can contrast them in one sentence.

---

## 5. Misspecification, general Bayes, and adequacy for purpose (T6)

### `bissiri2016general`: Bissiri, Holmes and Walker (2016)

* **How verified.**
  * [B] JRSS B 78(5):1103–1130, doi 10.1111/rssb.12158, from several repositories and arXiv:1306.6430.
  * [A] the abstract.
  * [S] the details below.
  * Same key and fields as the sibling bibliographies.
* **May be attributed.**
  * Updating a prior with a loss ℓ(θ, x) linking the parameter to data, in place of a likelihood, giving a coherent posterior ∝ exp{−w ℓ(θ, x)} π(θ) [S for the formula].
  * Standard Bayes is the case of self-information loss.
  * The target is the minimiser of expected loss.
  * The scale w must be chosen. Their options include matching expected losses and frequentist calibration (§3.4) [S]. See also Holmes–Walker 2017 for the power-likelihood case [A].
* **Hedge.** The exact theorem (the coherence axiom) was not seen. Write "Bissiri et al. argue that coherence leads to…" rather than quoting a theorem.

### `grunwald2017inconsistency`, `grunwald2012safe`, `holmes2017assigning`

* **Grünwald and van Ommen 2017.**
  * [B] Bayesian Anal. 12(4):1069–1103, doi 10.1214/17-BA1085.
  * [A] In linear regression with a heteroskedastic truth and a homoskedastic model, Bayesian model averaging and selection, and Bayesian ridge regression, can fail to converge. The posterior drifts to worse models of ever higher dimension ("hypercompression").
  * A learning rate η < 1 chosen by SafeBayes repairs this in their experiments.
  * **May be attributed:** a demonstration that Bayesian (cumulative log-loss) inference under misspecification can fail even by its own (KL) standard, and a learning-rate repair.
  * Do not generalise beyond "in their examples". The journal version has a subset of the arXiv experiments.
* **Grünwald 2012.**
  * [B] ALT 2012, LNCS 7568:169–183, doi 10.1007/978-3-642-34106-9_16.
  * [A] Learn the learning rate from the data, via the mixability gap.
  * This is the tie between misspecification and mixability. The learning rate is the same η as in the aggregating algorithm.
* **Holmes and Walker 2017.** [B] Biometrika 104(2):497–503, doi 10.1093/biomet/asx010. [A] Choosing the power of a power likelihood.

### `vovk2015fundamental`: the strongest published case *for* log loss in this setting

* **Statement.**
  * [A] Among the log, Brier and spherical losses, log loss is "the most selective".
  * A prediction algorithm that is optimal for a data sequence, in the sense of algorithmic randomness, under log loss is optimal under *any computable proper mixable* loss.
  * Some sequence and algorithm are optimal under Brier and spherical loss but not under log loss.
  * Scope: binary sequences, probability forecasts, proper mixable losses.
* **Bearing on the author's objection.**
  * It supports the reply's first point. For credence about hypotheses that might be exactly true, log loss is the most demanding standard: passing it implies passing every computable proper mixable one.
  * It does **not** touch the approximate-truth case. It is about optimality, which is a well-specified notion. It is not about ranking non-optimal (misspecified) predictors, and not about point-prediction purposes.
  * So it fits the two-attitude split in T6, and the developer should cite it there.

### Adequacy for purpose

* **`parker2020model`.**
  * [B] Philos. Sci. 87(3):457–477, doi 10.1086/708691.
  * [A] Models should be assessed for adequacy or fitness for particular purposes. The paper asks three questions:
    * what adequacy-for-purpose means;
    * what makes a model adequate for a purpose;
    * how this differs from assessing representational accuracy.
    It also replies to objections.
  * **May be attributed:** the view, and the distinction between adequacy-for-purpose and representational accuracy.
  * **Not attributable.** Parker's own definitions were not seen. Do not attribute to her any formal notion (a loss function, a metric, a threshold).
  * "Purpose ≈ loss function on answers" is our formalisation, and the paper should say so.
* **`parker2009confirmation`.**
  * [B] Aristotelian Society Supplementary Volume 83(1):233–249, doi 10.1111/j.1467-8349.2009.00180.x.
  * [A] Fit between model output and data confirms hypotheses about a model's adequacy for particular purposes, not the model itself.
  * This is the closest statement to T6's "credence for possibly-true hypotheses, adequacy for known-false ones". Cite it there.
* **`bokulich2021data`.** [B] EJPS 11(1), article 31, doi 10.1007/s13194-020-00345-2. [A] Data, too, are representations evaluated for adequacy for purpose. Optional.
* **`weisberg2013simulation`.**
  * [B] OUP 2013.
  * [A] Chapter 8: a weighted feature-matching account of model–world similarity, after Tversky. Modelling goals set the weights ("Modeling Goals and Weighting Parameters").
  * This is the closest philosophical analogue of "the purpose sets the metric". Cite it at [A]; do not describe the weighting function.
* **`teller2001twilight`.** [B] Erkenntnis 55(3):393–415, with no abstract seen. [S] The context of a modelling activity fixes which similarities are relevant. Cite only as commonly read.
* **`murphy1993what`.**
  * [B] Weather and Forecasting 8(2):281–293.
  * [A] Three kinds of forecast goodness: consistency, quality and value. Value is the benefit to decision makers. High quality need not mean high value [S].
  * This is the forecast-verification counterpart of adequacy-for-purpose. It supports "the grading is set by a purpose": value, not quality, is purpose-relative.
* **Already in the paper's bibliography:**
  * `niiniluoto1987truthlikeness` (truthlikeness needs a similarity metric, which is the point at issue);
  * `moulines1976approximate` (approximation as uniform structures).
  These are the "approximate truth" literature. Parker and Weisberg are the "purpose" literature.

---

## 6. Not added, and cautions

* **Not added to `refs.bib`.**
  * Hersbach 2000 (CRPS decomposition): page range conflicting (550–570 vs 559–570).
  * "The uniqueness of local proper scoring rules: the logarithmic family", Theory and Decision 88(2), 2020, doi 10.1007/s11238-019-09727-2: authors not seen.
  * Kalnishkan–Vyugin COLT 2002: LNCS volume not seen.
  * Kalnishkan–Vyugin ALT 2002, "On the absence of predictive complexity for some games": fields incomplete.
  * The Information and Computation paper on absolute loss: title and authors not confirmed.
  * Korotin–V'yugin–Burnaev on integral mixability: not checked.
  * Székely 2003: not checked.
* **Missing DOIs.** No DOI was seen for `vovk1998game`, `patton2020comparing`, `teller2001twilight`, `dawid2014theory`, `kalnishkan2004loss` or `murphy1993what`. These entries omit it.
* **Content not seen, so do not state it:**
  * Bernardo's regularity conditions;
  * the equation and section numbers of Gneiting–Raftery;
  * the WAA constant and its prior-weight term;
  * Parker's definitions;
  * Weisberg's weighting function;
  * the exact hypotheses of McCutcheon's theorem.
* **Sign conventions.** Gneiting–Raftery use positive orientation (larger is better). Our check and most later literature use negative orientation (smaller is better). The paper should fix one convention, presumably loss (negative) as in SAI, and convert.

---

## 7. Notes for the developer: claims in the brief and what the literature supports

This section goes claim by claim through Claude's reply, as recorded in `../../00-brief.md`.

1. **"The log score is the local proper scoring rule".**
   * Supported, with hypotheses:
     * order-0 locality;
     * at least three outcomes in the discrete case;
     * regularity conditions for densities;
     * equivalence up to a log q + f, a ≥ 0.
   * Cite Bernardo 1979 via Gneiting–Raftery 2007, and Parry–Dawid–Lauritzen 2012. The binary counterexample (Brier) should be in the text.
2. **"Conditioning is cumulative log loss".** This is the chain rule. No citation is needed.
3. **"Proper scores all rank the truth first but rank wrong theories differently (log loss picks the KL projection)".**
   * The first half is the definition of strict propriety (Gneiting–Raftery).
   * KL projection: `berk1966limiting`, `kleijn2006misspecification` (paper keys).
   * Ranking dependence: Patton 2020 for point forecasts [A]. For distributions it is elementary and T4 supplies the instance. No source stating it for proper scores was seen.
4. **Error densities as purposes (T3).** These are elementary derivations. Gneiting 2011 supports the general principle that the loss must be consistent for the reported functional.
5. **"L² is one purpose among others; Kepler's test was a maximum-error tolerance".**
   * Supported in spirit by Gneiting 2011, Patton 2020 and Murphy 1993.
   * Kepler's 8′ is at [S] in `kepler1992new`.
6. **"A question family can encode a partition but not a metric" (T1).**
   * No literature found states this. It is the developer's claim; record it as such.
   * The novelty search was not exhaustive: this run did not look for it in the prediction-markets or logical-induction literature.
7. **"Vovk's AA with weights 2^(−K(T)) gives Solomonoff-style bounds for mixable losses".**
   * True, and **already known as predictive complexity** (Vovk–Watkins 1998; Vovk–Gammerman 1999; Kalnishkan–Vovk–Vyugin 2004; Vovk 2015).
   * The paper must cite this line and claim novelty only for the SAI (theory-machine) analogue.
   * Square loss on [−B, B]: η = 1/(2B²) is confirmed.
   * The CRPS is mixable (V'yugin–Trunov 2019), which gives a distance-sensitive proper score with universal-weight bounds.
8. **Credence versus adequacy (T6).**
   * Credence: Vovk 2015 is the strongest support for log loss.
   * Adequacy: Parker 2009/2020 and Weisberg 2013.
   * Bridge: the general-Bayes reading of the AA weights (Bissiri et al. 2016) and Dawid 2007's "every decision problem has its proper score". The latter suggests a framing: a purpose is a decision problem, and the log score is the purpose "state your credence".

**Possible error in the author's view.** None raised from the references. The literature fits the position the author accepted ("sounds good"):
* in the well-specified case, log loss is the most selective (Vovk 2015);
* under misspecification, rankings depend on the loss (Patton 2020; Grünwald–van Ommen 2017);
* evaluation is purpose-relative (Parker; Murphy).

**One correction to Claude's own reply.** Calling the AA weights simply "not credences" undersells them. They are general-Bayes belief distributions for the purpose loss (Bissiri et al.), and for log loss with η = 1 they are exactly Bayesian posteriors. Suggested wording: "the weights are then loss-based belief distributions in the sense of Bissiri et al. (2016), not probabilities that the theory is true".

---

## Verification log

* **2026-10-17, start.** No earlier output in `tracks/purpose/`. Skeleton files were written.
* **Access tests.** WebFetch failed with DNS errors on sites.stat.washington.edu, apps.dtic.mil, projecteuclid.org and ar5iv.labs.arxiv.org. `curl` via the proxy got 403 CONNECT on 15 hosts (listed in "How things were checked"). Only WebSearch was used.
* **Scoring rules.** About 20 searches: Bernardo; Gneiting–Raftery; Matheson–Winkler; Parry–Dawid–Lauritzen; Dawid–Lauritzen–Parry; Ehm–Gneiting; Hyvärinen; Shuford et al.; McCutcheon; Good; Dawid 2007; Dawid–Musio; Dawid–Musio–Ventura; Grünwald–Dawid; Gneiting 2011; Patton; Hersbach (not added).
* **Expert advice.** About 20 searches:
  * Vovk 1990, 1998, 2001; Haussler–Kivinen–Warmuth; Cesa-Bianchi–Lugosi (table of contents and fragments); Kalnishkan–Vyugin 2008 and 2002; Vovk–Zhdanov; V'yugin–Trunov;
  * the AA lemma (RHUL thesis restatement);
  * the mixability constant (search inconclusive on [−B, B]; derived by rescaling and checked numerically);
  * predictive complexity (Vovk–Watkins, Vovk–Gammerman, Kalnishkan–Vovk–Vyugin, Vovk 2015);
  * Hutter 2003.
* **Misspecification and purpose.** About 15 searches: Bissiri–Holmes–Walker; Holmes–Walker; Grünwald 2012; Grünwald–van Ommen; Parker 2009, 2020; Bokulich–Parker; Teller; Weisberg; Murphy.
* **Keys.**
  * Every new key was checked against `paper/bib/{refs,core,all}.bib`: no collisions.
  * `gneiting2007strictly`, `bissiri2016general`, `grunwald2017inconsistency` and `grunwald2012safe` match the sibling bibliographies (SOI steeper paper; inferential-learning).
  * `bernardo1979expected` is reused with the paper's fields.
* **Check script.** `checks/refs_c1_attributions.py`, seed 20261017, run 2026-10-18. Output: `checks/refs_c1_attributions.out`.
  * **First run.** Part 1 used a grid over γ. Its discretisation error (about 2B·Δγ) produced false positive gaps, and `np.trapz` is absent in NumPy 2.
  * **Fixed.** Convex scalar minimisation over γ (`scipy.optimize.minimize_scalar`), and an exact piecewise integral for the CRPS.
  * **Results (rerun):**
    * (1) η = 1/(2B²) is mixable via Vovk's substitution, and 1.05/(2B²) is not (B = 1, 3);
    * (2) the AA bound holds with weights 2^{−k};
    * (3) the CRPS integral and kernel forms agree; the 5-values example gives log₂ 5 bits for both forecasts and CRPS 0.400 vs 8.440.
* **BibTeX test.** `\nocite{*}` with `plainnat` over `refs.bib` (a scratch copy): all 39 entries typeset, with no warnings.
* **Not done.**
  * No full text was read.
  * No reference was checked against a library catalogue beyond what search returned.
  * The novelty of T1's partition-versus-metric claim was not searched exhaustively.
