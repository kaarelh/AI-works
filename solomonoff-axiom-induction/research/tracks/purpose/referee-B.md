# Track `purpose`: adversarial referee B (computation, counterexamples, references), 2026-10-18

*Referee B for `notes.md` (developer record, 2026-10-17/18), its scripts in `checks/`, `refs.bib` and `refs-report.md`. My code is in `referee_code/` (`rb1`–`rb6`), with outputs saved next to each script. None of it is copied from `checks/`. Seeds are given in each script header. No git commands were run.*

## Verdict

**Accept after revision.** There are no fatal issues, three major issues and twelve minor ones.

* **Everything computed reproduces.**
  * All seven developer scripts I re-ran reproduce their outputs. Six are byte-identical; `p4_allfits` gives identical arrays and an `.out` that differs only in its timing lines.
  * My independent code reproduces every number I re-derived:
    * T2: log score, CRPS, CRIGN, energy score, and the misspecified Gaussian scales;
    * T3: fitted-scale closed forms; the identity T3.2, also for a singular and a mixed law, which the developer did not test;
    * T4(a): closed forms and crossovers, by simulation rather than integration;
    * T5: the mixability constant 1/(2B²).
  * The exact finite enumerations of T1 found no counterexample to T1.1–T1.4. They cover arbitrary sentence sets, inconsistent theories, repeats, and three-valued and normalised conventions.
* **T4(b) on the real Kepler residuals survives an independent implementation.** Its qualitative findings hold:
  * the criteria disagree;
  * SAI's pricing disagrees with each classical criterion;
  * SAI's ranking of fits flips with the cell width.

  Those findings are robust to the histogram's bin count: 1 opposite decision in 1510 between 40 and 160 bins. In the coarse regime they agree exactly with the ideal calibrated pricing.

  Its exact counts ("16 pairs", "4 of 15", "3 of 10") depend on the random half-split. The "SAI's winner is none of the classical winners" cases are mostly near-ties.
* **The three major issues are statements that would carry an error into the paper:**
  * **M1.** A false comparative sentence about fixed question families, and the counterexample used to mark P27 "refuted".
  * **M2.** The over-general claim that SAI's loss grades misses "only through a separation probability … never like squared error". The track's own T3.1 contradicts it.
  * **M3.** "SAI's rate" used for cross-law comparisons in T4(a). These comparisons only make sense for deterministic error sequences, where the identification of r_F with SAI's rate fails.

**On the author's view.** I agree with the developer's T6 conclusion: no probable error in the author's objection. M2 sharpens what the paper should say about it.

---

## 1. What I ran

### 1.1 Re-runs of the developer's scripts

All on scratch copies, Python 3.11.15, NumPy 2.4.6, SciPy 1.17.1, pyerfa 2.0.1.5 from the scratch library.

| script | time | result |
|---|---|---|
| `p1_locality.py` | 0.6 s | byte-identical to `p1_locality.out` |
| `p2_scores.py` | 3.2 s | byte-identical |
| `p3_errormodels.py` | 6.3 s | byte-identical |
| `p4_toy.py` | 0.7 s | byte-identical |
| `p4_kepler.py` (two fits) | 135 s | byte-identical to `p4_kepler.out` |
| `p5_aggregating.py` | 307 s | byte-identical |
| `p4_allfits.py`, then `p4_kepler.py --all` | 23.7 min, then 4.7 min | npz arrays identical; `.out` identical apart from timings; `p4_kepler_allfits.out` byte-identical (§6) |

### 1.2 My independent code

| script | target | what it does | outcome |
|---|---|---|---|
| `rb1_locality.py` | T1 | Exact rational enumeration in an atom model (Part A setup below). Part B: normalised convention. Part C: joint-cell identity and partitions. Part D: random partitions integrated exactly over the dither. | T1.1–T1.4 hold on every instance. T1.2's formula holds to 9e−16 bits, and the largest order spread found is 2.46 bits. T1.5(c) and (e) hold. **Two counterexamples to statements in the record: D4 (M1) and D5 (M2).** |
| `rb2_scores.py` | T2 | The author's example and variants: CRPS in exact rationals by both formulas. Misspecified Gaussian scales by quadrature and Monte Carlo. Propriety checks of local rules. | All T2 numbers reproduced. Reversal interval 1/5 < m < 0.747. The local Brier rule, the linear rule and a kinked log rule on 3 outcomes are improper; the log rule passes. |
| `rb3_errormodels.py` | T3 | Fitted-scale rankings on 3000 random pairs by numerical minimisation. T3.2 by Monte Carlo against a density grid, for four laws: triangular, beta, atom plus uniform, and Cantor (singular). Coarse identity, fine limit, atoms, bin permutation. | All hold. T3.2 holds within 2.2 standard errors on all 24 (law, Δ) cells. The fine limit converges. For atoms the rate equals H for Δ ≤ the least gap and falls below H above it. |
| `rb4_toy.py` | T4(a) | The toy simulated with deterministic error sequences, 4·10⁵ data, exact cell probabilities. Δ_c by root finding. The regime-R consistency check (M3). | Δ_c = 1.558542 and 1.429612 reproduced. **B(i): the two laws together decode q exactly (rate 0). B(ii): if A's errors are random, B's calibrated machine is worse by H(d) = 0.92 bits at every Δ.** |
| `rb5_kepler.py` | T4(b) | Reads `l4_residuals.npz` and `p4_allfits.npz`. My own band-confined histogram machine SH_B with B = 40 and 160, scored exactly by quadrature in the coarse regime. The plug-in calibrated coarse cost Dcal = ∫H₂(F̂). Held-out histogram entropies. Five splits with my own seeds, plus the developer's split. | Developer's SH reproduced to 6e−5 bits on their split. Classical counts exact (24 of 37; 121, 204 and 101 pairs). SH40 against SH160: 1 opposite in 1510 decided comparisons. SH at coarse Δ against Dcal: 0 opposite. Split-dependent counts differ (m1). Near-ties (§5). |
| `rb6_aggregating.py` | T5 | Mixability by min-max over γ and ω. Bisection for the threshold. Exp-concavity. Absolute loss. **A small purpose-SAI (Def. T5.1)** in the atom model with AA and Vovk's substitution. The scale of the guarantee. | η = 1/(2B²) confirmed (bisection 0.50003). The binding pools are narrow and central, not the endpoints (m5). The T5.2 bound holds on 40 trials, truthful and adversarial (minimum slack +11.2). L_AA/L_A = 347 on the toy (m3). |

The atom model used in rb1:
* there are N atoms;
* a sentence is a subset of the atoms;
* a theory is a finite set of sentences, of which arbitrarily many may be inconsistent;
* a machine is a finite distribution over theories.

---

## 2. Major issues

### M1 (major). The counterexample behind P27 does not show what it is cited for, and one sentence is false

**Where.**
* §T1, after T1.5: "*The author's example under random cells* … So at cell widths above the spacing of the near forecast, regime R already ranks the near forecast better, **which a fixed question family cannot do**."
* P27 marks the reply's "a question family can encode a partition but not a metric" as **refuted**, with this example as the counterexample (0.42 against 2.32 bits at Δ = 5).
* T6.2 row 6a: "wrong for SAI's own regime R".
* Summary item 6(i).

**Evidence.** `rb1_locality.out` part D4.
* Take a fixed grid of width 5, with the cell of the truth [−2.5, 2.5). The near forecast costs **0** bits and the scattered one **2.3219** bits.
* At the worst offset of a fixed width-5 grid, the near forecast costs 0.7370 bits, still below 2.3219. So **every** fixed grid of width 5 ranks the near forecast better.
* The dithered loss 0.4236 is just the average of these fixed-grid losses over the offset.
* The developer's own comparison in p1 part E is with "fixed cells of width Δ < 1". That is not the same resolution.

What a fixed family can encode is exactly "good enough at resolution Δ". That is the content of the reply's sentence, and the example is consistent with it.

**What is true.**
* A fixed family grades a near-point miss by a single cut, 0 or 1 (T1.4).
* A random family is a mixture of partitions. It grades a near-point miss at distance d < Δ by the separation probability σ(d) = min(d/Δ, 1), a bounded pseudometric of cut type (T1.5(c), (d)).
* This is the real refinement, and the developer's part D shows it correctly. For example, the leading coefficient is 0.25 at d = 0.25Δ and 0.5 at d = 0.5Δ (my D3 reproduces 3.1717, 4.8220 and 8.1439 exactly). A fixed partition gives either 0 or 1.
* Neither kind of family grades misses beyond the largest cell.

**Fix.**
1. Delete "which a fixed question family cannot do".
2. In P27, replace "refuted" with **"refined"**. The new wording: "true for fixed families; a random family (regime R) encodes a mixture of partitions, which grades near-point misses by a bounded cut-type pseudometric up to the cell width, and still not beyond it".
3. Replace the counterexample by the graded coefficient of T1.5(d), for instance d = 0.25Δ against d = 0.5Δ.
4. In T6.2 row 6a write "right for fixed questions; refined (not wrong) for regime R", and change Summary 6(i) the same way.

### M2 (major). "Misses are graded … never like squared error" is false outside near-point forecasts, and contradicts T3.1

**Where.**
* Summary item 1: "Questions drawn at random … make the *expected* loss distance-sensitive, but **only through a separation probability**, … misses are graded up to the cell width and **never like squared error**."
* T1.5(d): "no law of questions makes SAI's expected loss grade near-point misses by squared error, **nor by any unbounded cost**". This is correct as stated, for near-point forecasts.
* T6.2 row 6a: "never squared error".
* T6.3's suggested paper text: "where misses must be graded, a loss on the answers, which it cannot".

**Evidence.** `rb1_locality.out` part D5.
* Setup: forecasts of Gaussian shape N(y, 1), the truth at 0, the dithered grid.
* Result: the expected loss grows with the miss y like y²/(2 ln 2), without bound, at **every** cell width.

  | Δ | extra cost at miss 6 (bits) | y²/(2 ln 2) at y = 6 |
  |---|---|---|
  | 0.1 | 25.95 | 25.97 |
  | 1 | 24.27 | 25.97 |
  | 4 | 15.52 | 25.97 |

  At Δ = 4 the growth is still quadratic for large misses.
* This is T3.1's own point: a fixed-scale Gaussian error model makes the log loss squared error.

So the distance sensitivity of SAI's loss does not come only from the questions. It also comes, without bound, from the shape of the hypothesis's own forecast. T1.5(d) is right only because it restricts to near-point forecasts.

**Fix.**
1. In Summary 1 and T6.2 row 6a, restrict to near-point forecasts: "for near-point forecasts the grading of a miss by random questions is a bounded cut-type pseudometric".
2. State the general fact plainly, because it is the precise answer to the author's objection. **Under log loss a miss is graded by the hypothesis's own error model.**
   * A Gaussian-error law prices a 6σ miss at 26 bits more than a hit.
   * The uniform-on-5-values forecast prices every miss alike.
   * So the grading is chosen by each hypothesis, and the hypothesis that compresses best wins (T3.3).
   * A purpose fixes the grading from outside.
3. Reword T6.3's text "a loss on the answers, which it cannot" to: "a grading of misses fixed by the purpose rather than by each hypothesis's own error model, which it cannot".

   The author's "they look the same on log loss" is then true of forecasts with no spread structure, as in the author's own example. In general the right reading is "the weight of a miss is set by the forecaster, not by the purpose".

### M3 (major). "SAI's rate" in the T4(a) toy is not SAI's rate, and regime R cannot hold for two laws with different rates

**Where.**
* T4(a): "SAI's rate is that of the best calibrated error model (Thm. T3.3)". The table header is "SAI rate". The text says "SAI prefers B at every cell width below Δ_c".
* Summary 4: "beats … under SAI's pricing".
* Claims P16. The same wording appears in T6.3's suggested text ("ranks laws by the entropy of their errors … even against pointwise dominance").

**The problem.** T3.3 states that r_F(Δ) is three things at once:
* the rate of BC_F;
* Prop. 9.2(c)'s lower bound for every machine;
* the limit of L_A/n.

The last two need regime R's hypothesis that the errors are random and i.i.d.

**Evidence.**
* **The two roles cannot hold for two laws at once.** If law A's errors are random (`rb4_toy.out` B(ii)), no machine beats r_A. In particular B's calibrated machine is worse by H(d) = 0.92 bits per datum at every Δ (0.916 to 0.920 measured). So two laws for one quantity can both satisfy regime R only if their errors differ by a constant, and then their rates are equal (D(e) and h(e) are translation invariant). In other words, any cross-law ranking by r_F is a ranking of **deterministic** error sequences.
* **There, SAI's own rate is not min(r_A, r_B).** In the toy the pair of laws determines q: e_B is the element of {−M, 0, M} nearest to −(f_A − f_B). rb4 B(i) decodes q exactly on 400 000 of 400 000 data, so a machine stating both laws has rate 0. In the toy's own deterministic-truth setting, L_A/n → 0 for computable q, and Prop. 9.2(c)'s lower bound does not apply.

What the toy validly shows is a comparison of the **prices of two machines**, BC_{F_A} against BC_{F_B}. That is SAI's pricing in the paper's sense: "the weight of a theory machine G in M_A's mixture" (§9.3). The same holds for T4(b), whose residuals are deterministic. The developer says this in T6.1 for the ephemeris, but the T4(a) wording invites the reading "M_A prefers law B".

**Fix.**
1. Rename the quantity in T4(a), its table, Summary 4, P16 and T6.3 to "**the rate (price) of the law's calibrated band-confined completion**".
2. Add one sentence after T3.3: "The identification of r_F with Prop. 9.2(c)'s bound and with lim L_A/n needs random i.i.d. errors. Two laws for one quantity can both satisfy this only if their errors differ by a constant, in which case their rates coincide. So cross-law comparisons (T4) concern deterministic residual sequences, for which r_F is only the rate of BC_F, and SAI's own rate may be much lower (rb4 B(i): 0)."
3. Optionally, cite rb4 B(ii) as the clean statement: **in regime R the law whose errors are the randomness is never out-priced by another law's calibrated machine.**

---

## 3. Minor issues

**m1. T4(b): the exact counts depend on the half-split; report them as approximate and add the robust facts and the magnitudes.** Evidence from `rb5_kepler.out`, with my five seeds 20261018–22.

| claim in notes | developer (seed 20261017) | mine, SH40 | mine, SH160 |
|---|---|---|---|
| SH ranking flips with Δ (four fits) | 16 pairs | 15 pairs | 11 pairs |
| SH winner is none of max/RMS/mae, at 0.1′ | 4 of 15 | 2 of 13 | 1 of 11 |
| same, at 1800′ | 3 of 10 | 3 of 8 | 2 of 8 |
| two fits: SH decided at 0.1′ (mm, mn) | 23 (14, 9) | 25 (15, 10) | – |
| two fits: SH decided at 1800′ (mm, mn) | 19 (9, 10) | 19 (8, 11) | – |
| two fits: series with SH flip | Moon 1 yr only | Moon 1 yr only | – |

The examples the developer quotes all recur in my lists:
* Saturn 100 yr, L2 against Linf;
* Jupiter 100 yr, L2 against L1;
* Mars 12 yr;
* the Moon over one year.

The robust facts, which should be stated:
1. **Bin count does not matter.** SH40 and SH160 are both decided on 1510 (pair, Δ) comparisons and opposite on **1**.
2. **SH matches the ideal pricing in the coarse regime.** In the coarse regime SH40 agrees with the ideal calibrated ranking Dcal = ∫H₂(F̂) on all decided pairs (**0** opposite, up to 139 pairs at 1800′).
3. **The "none" cases are mostly near-ties of F3 against L2,** two zero-bias least-squares fits. Examples:
   * Mars 30 yr: Dcal 1.48274 against 1.48290, SD 0.5746 against 0.5745;
   * Mercury 100 yr: 2.07455 against 2.07526.

   They are not bias absorption: both fits have mean error 0.

   Dcal disagrees with RMS on 39 of 234 pairs. On those, the median relative RMS gap is 1.4·10⁻³, against 8.4·10⁻³ on agreeing pairs. It disagrees with the maximum error on 102 pairs, with a median relative max gap of 0.11. So in the coarse regime SAI's pricing is close to an SD/RMS ranking and departs from it mainly on near-ties. It departs from the maximum and mean-error rankings on substantial differences.

Suggested wording:
* "SAI's ranking of fits changes significantly with the cell width in about 15 of 234 fit pairs (11 to 16 across splits and bin counts)".
* "its significantly best fit is occasionally none of the classical winners (1 to 4 series at 0.1′, 2 to 3 at 1800′), always the 3-D fit F3 in a near-tie with L2".

**m2. "At fine cell widths it agrees exactly with the plug-in entropy h40 (0 disagreements at 0.1′), as T3.3(b) predicts".**
* The agreement is by construction: SH and h40 are the same 40-bin histogram on the fit's own range.
* It is not evidence for T3.3(b). For series with sub-arcminute errors, 0.1′ is not even in the fine regime: the bin width is about 0.05′.
* My held-out entropies give, against SH40 at 0.1′: 2 opposite with 40 bins, 4 with 160, 17 with 640. The 640-bin estimates are noisy and no significance rule was applied.
* Fix: say "as it must, being the same histogram".

**m3. p5 part C and the T4(a) text report the AA's final weight (1.000000 on A) but not its cumulative loss.**
* The losses (developer's run): L_AA = 603 493 against L_A = 1348, about 450 times. In rb6 D: 468 462 against 1350, 347 times, with 90 % of L_AA in the first 22 rounds.
* The regret bound K(G)·ln 2/η = 2B²·K(G)·ln 2 scales with B². For longitudes (B = 10 800′) one bit of K(G) costs 1.6·10⁸ arcmin² of cumulative square loss. Against a law with 1′ errors and K = 2000 bits, the bound is uninformative until n ≫ 3·10¹¹.
* Fix: add one sentence to T5.2 or T5.4. The guarantee is meaningful only for purpose losses on a range comparable to the errors, which needs a local or truncated loss. Report L_AA in T4(a).

**m4. T5.4 says purpose-SAI "under absolute loss" ranks by the mean absolute deviation.**
* Absolute loss is not mixable (P20), so the AA of Def. T5.1 is not defined for it.
* The concentration argument concerns exponential weights ∝ w·e^{−ηL}, which make sense for any loss. Their regret guarantee is the weak aggregating algorithm's O(√n).
* Fix: say "with exponential weights (the weak aggregating algorithm)" there.

**m5. refs-report §4 and `checks/refs_c1_attributions.py` describe the worst pools wrongly.**
* Both say that at η = 1.05/(2B²) "a two-endpoint pool is not dominated". The code comment says "endpoint pools are the hardest case".
* `rb6_aggregating.out` part A: two-endpoint pools stay dominated up to c ≈ 0.609, that is η ≈ 1.22/(2B²). The binding pools are narrow central ones. The worst on a 21 × 21 × 19 grid at c = 0.51 is {−0.2B, 0.2B} with p = 1/2.
* The constant itself is right: bisection over central pools gives c = 0.50003.
* Fix: drop "two-endpoint" from the report and correct the code comment. No downstream claim changes.

**m6. Predictive complexity: the origin is misattributed.**
* refs-report §0 cites `vovk1998universal` (Vovk and Watkins, "Universal Portfolio Selection", COLT 1998) for the "origin of predictive complexity".
* My searches found the Royal Holloway overview stating that the concept was "introduced in [Vovk, 97]". It credits Vovk and Watkins 1998 with the method that proves existence through the AA for all mixable games.
* The 1997 source was not identified.
* Fix: cite `vovk1998universal` for "existence of predictive complexity for mixable games, via the AA" ([S]), not for its origin. The notes' wording "known as predictive complexity (Vovk and Watkins 1998; …)" is acceptable as a citation of the line.

**m7. T6.2 row 5's "about 2′ by secondary accounts" for the accuracy of Tycho's observations is not supported as stated.**
* What I found:
  * Kepler, ch. 19 (MacTutor quotations): the 8′ could not be ignored given Tycho's observations.
  * Sheynin, "Kepler as a statistician" (2017): the 2–3′ figure is Kepler's statement about the error of *his own* observations, and why Kepler was sure Tycho's error was below 8′ is left open.
  * A university lecture gives about 4′ for Tycho.
* Sheynin also reads Kepler as applying a minimax principle. This supports the "maximum-error tolerance" reading at [S].
* Fix: write "an 8′ discrepancy that Tycho's observations could not have produced" and drop "about 2′". Sheynin may be cited for the minimax reading if the paper wants it, after adding it to the bibliography.

**m8. DOIs seen in my searches but missing from `refs.bib`.**

| key | DOI |
|---|---|
| `good1952rational` | 10.1111/j.2517-6161.1952.tb00104.x |
| `patton2020comparing` | 10.1080/07350015.2019.1585256 |
| `vovk1998universal` | 10.1145/279943.279947 |

**m9. A lead for T3.2's attribution, not verified.**
* The identity H(C_U(e) | U) = h(e + V) − log Δ is the standard entropy of a subtractively dithered quantiser: I(X; X + U) = h(X + U) − h(U).
* It is very likely stated in Zamir and Feder, "On universal quantization by randomized uniform/lattice quantizers", IEEE Trans. Inf. Theory 38(2):428–436, 1992. I confirmed only the bibliographic data by search, not the statement.
* The developer's "no attribution" is the safe choice. If the paper wants a citation, the statement needs checking first.

**m10. p5 part C clips law B's predictions to [−B, B].**
* So its squared errors are not the toy's ±1000: L_B = 5.4·10⁸ against 8·10⁸ unclipped. rb6 D reproduces 5.35·10⁸ under the same clipping.
* Fix: state the clipping where the experiment is reported.

**m11. T3.3(b) "beats every law with a continuous error law".**
* "Non-atomic" is the right word. A singular law has no density, and its rate still diverges as Δ → 0: `rb3_errormodels.out` part D, for the Cantor law, gives 2.10, 3.57, 5.03 and 6.49 bits at Δ = 0.5, 0.1, 0.02 and 0.004.
* For atomic errors the rate is H(e) exactly for Δ up to the least gap, and below H above it: 1.231 at Δ = 1.5 for gaps 1 and 2. This is consistent with the statement.

**m12. T1.5(d)'s near-point asymptotics.** Not an error. The ratio S/log(1/s) converges very slowly: 0.306 at s = 10⁻⁸ for σ = 0.25. The record says so in its Verification log. The paper should quote the exact decomposition, not the ratio.

---

## 4. Claims table, referee B's verdicts

| id | developer status | my check | verdict |
|---|---|---|---|
| P1, P2 | proved; computed | rb1 A: 121 two-valued instances and 487 orders with random repeats; 117 three-valued instances, all orders; deviation ≤ 4.4e−16 | confirmed |
| P3 | proved; computed | rb1 B: formula to 8.9e−16 on 1137 instances; non-locality example; order spread up to 2.46 bits | confirmed |
| P4, P5 | proved | rb1 C: 2000 instances, arbitrary (non-interval) sentences; joint-cell identity exact; partition masses ≤ ν(∅) with the equality case characterised in 2000 of 2000 | confirmed |
| P6 | proved; computed | rb1 D1 (separation probability) and D2 (CRIGN identity on 300 random forecasts, 5.6e−16) | confirmed |
| P7 | proved; computed | rb1 D3 reproduces p1 D exactly | confirmed as stated for near-point forecasts; **its generalisation in Summary 1 and T6.2 is false (M2)** |
| P8 | proved; computed | rb1 D2 | confirmed |
| P9 | proved (differentiable case); known | rb2 D sanity checks; the proof read and correct; references re-verified (§5) | confirmed |
| P10 | computed | rb2 A and B: exact rationals; reversal for 1/5 < m < 0.747 | confirmed |
| P11 | computed | rb2 C: s_CRPS = 1.202985 by quadrature; Monte Carlo agrees | confirmed |
| P12 | proved; computed | rb3 A: 3000 / 3000 for each family, by numerical minimisation | confirmed |
| P13 | proved; computed | rb3 B: Monte Carlo against grid, including singular and mixed laws | confirmed |
| P14 | proved; computed | rb3 B–D | confirmed (m11 wording) |
| P15 | proved; computed | rb3 E, own histogram: h unchanged; RMS 0.749 → 1.162; rates differ at Δ = 1 and coarse | confirmed |
| P16 | proved; computed | rb4 A, by simulation | numbers confirmed; **wording "SAI's rate" wrong (M3)** |
| P17 | computed | §6: full re-run; rb5 part 0 | confirmed |
| P18 | computed | rb5 | qualitatively confirmed and robust; counts split-dependent (m1); h40 agreement by construction (m2) |
| P19 | known; proved | the proof read and correct; rb6 C | confirmed |
| P20 | known; computed; proved | rb6 A and B | confirmed (the constant); m5 for the refs-report detail |
| P21 | proved | rb6 C: purpose-SAI on the atom model, 40 trials, truthful and adversarial answers; min slack +11.25 | confirmed |
| P22 | proved | I checked the pull-back equality: consistency is preserved both ways through ⊥ ∈ A\* and B′ ⊢ ¬τ(⊥); provability through compactness and (T1), (T2). It is stronger than the paper's inclusion, and correct. | confirmed |
| P23 | proved, given Lemma B.2 | read only | no objection |
| P24 | proof sketch | – | sketch acceptable; m4 for the absolute-loss case |
| P25, P26 | open | – | – |
| P27 | refuted | rb1 D4 | **mislabelled: "refined", with a different counterexample (M1)** |
| P28 | refuted (in regime R) | argument checked: the true error law is optimal among band-confined completions for every proper score | agree, for rich error families, as the developer restricts |
| P29 | assessment | – | agree, with M2's rewording of the T6.3 text |
| P30 | assessment on computed results | numbers checked against `tracks/philosophy/checks/c4_mars_pool.out`, `c9_revision.out`, `c10_distances_research.out` (640.79, 23.05, 8.17, 1.41 and 1.07′; RMS 454.4 to 0.446′; vicarious 2.82 %, 5.119′ at 1 %, 23.735′ at 0.2 %) | confirmed |

---

## 5. References: re-verification by search

All searches were run on 2026-10-18 with WebSearch; no full texts were read. Every one of the 39 entries in `refs.bib` was searched again. The levels are those of `refs-report.md`: [B] bibliographic data seen, [A] abstract or publisher's description seen, [Q] a passage of the work quoted, [S] a secondary source states the content.

| key | bibliographic data | content as recorded | note |
|---|---|---|---|
| bernardo1979expected | ✓ (Project Euclid: 7(3):686–690, doi) | ✓ [S] | The abstract is about experimental design; the local-rule theorem is attributed by Ehm–Gneiting (p. 689) and others. I did not reproduce refs-report's [Q] of Gneiting–Raftery, only [S]. Secondary sources state it as "for #X > 2 … a(x) − λ ln p_x, λ > 0". |
| good1952rational | ✓ | ✓ [S] | DOI seen (m8) |
| shuford1966admissible | ✓ | ✓ [A]; [S] via McCutcheon | – |
| mccutcheon2019favor | ✓ | ✓ [A]: the differentiability condition of Shuford et al. is unnecessary | – |
| matheson1976scoring | ✓ | ✓ [A], [S] (CRPS) | – |
| gneiting2007strictly | ✓ | ✓ [A] | – |
| parry2012proper | ✓ | ✓ [A] (orders m, even only) | – |
| dawid2012proper | ✓ | ✓ [A] (neighbourhood locality, cliques) | – |
| ehm2012local | ✓ | ✓ [A] | – |
| hyvarinen2005estimation | ✓ | ✓ [A] | – |
| dawid2007geometry | ✓ | ✓ [A] (decision problem → score, entropy, divergence) | – |
| dawid2014theory | ✓ | ✓ [A]: "log score … the only proper scoring rule that is local" | – |
| dawid2016minimum | ✓ | ✓ [A] | – |
| grunwald2004game | ✓ | ✓ [A] | – |
| gneiting2011making | ✓ | ✓ [A] (Bregman ↔ mean, quantiles) | – |
| patton2020comparing | ✓ | ✓ [A] | DOI seen (m8) |
| vovk1990aggregating | ✓ (eds. Fulk and Case, Morgan Kaufmann) | ✓ [A] | – |
| vovk1998game | ✓ | [B] only, as recorded | COLT'95 version doi 10.1145/225298.225304 |
| vovk2001competitive | ✓ | ✓ [A] | – |
| haussler1998sequential | ✓ | ✓ [A] (log N against √(ℓ log N); extension to [0, 1]) | – |
| vovk2009prediction | ✓ | ✓ [A] (Brier game mixable) | – |
| vyugin2019online | ✓ | ✓ [A] (CRPS mixable; time-independent regret) | – |
| kalnishkan2008weak | ✓ | ✓ [A] (√n for bounded losses) | – |
| cesabianchi2006prediction | ✓ (§3.5, p. 52; §3.6, p. 56) | table of contents only, as recorded | – |
| vovk1998universal | ✓ (doi 10.1145/279943.279947) | content: portfolio selection [A]; predictive-complexity existence [S] | **m6: not the origin of predictive complexity** |
| vovk1999complexity | ✓ | ✓ [A] (CAP generalises MDL and MML; reduces to MDL for log loss) | – |
| kalnishkan2004loss | ✓ | ✓ [A] | – |
| vovk2015fundamental | ✓ | ✓ [A] (log loss "most selective"; Brier and spherical) | – |
| hutter2003optimality | ✓ | ✓ [A] (well-specified; general loss; 2^{−K} weights) | – |
| bissiri2016general | ✓ | ✓ [A] | – |
| holmes2017assigning | ✓ | ✓ [A] | – |
| grunwald2012safe | ✓ | ✓ [A] | – |
| grunwald2017inconsistency | ✓ | ✓ [A] (hypercompression; SafeBayes; the journal version is a subset) | – |
| parker2020model | ✓ | ✓ [A] | – |
| parker2009confirmation | ✓ | ✓ [A] | – |
| bokulich2021data | ✓ | ✓ [A] | – |
| teller2001twilight | ✓ | [B] only; PhilArchive has no abstract | as recorded; cite only as commonly read |
| weisberg2013simulation | ✓ | ✓ [A]: ch. 8 "An Account of Similarity", §8.7 "Modeling Goals and Weighting Parameters" | – |
| murphy1993what | ✓ | ✓ [A] (consistency, quality, value) | – |

The developer's three additional references:

| reference | result |
|---|---|
| Tödter and Ahrens 2012, Mon. Wea. Rev. 140(6):2005–2017, doi 10.1175/MWR-D-11-00266.1 | ✓ [B]. [A] via EGU 2012 and 2013 abstracts ("CRIGN … in analogy to the CRPS"). Formula not seen: the developer is right not to claim identity with T1.5(e). |
| Freund, Schapire, Singer and Warmuth 1997, STOC '97, 334–343 | ✓ [B], [A] (abstaining experts; conversion; loss bounds) |
| Kepler's 8′ (ch. 19) | ✓ for the 8′; **"about 2′" not supported as stated (m7)** |

**Verdict on the bibliography.**
* No bibliographic error in `refs.bib`.
* One attribution to correct: m6.
* One content detail in `refs-report.md` §4 is wrong: m5.
* One level could not be reproduced: Bernardo via Gneiting–Raftery [Q], which I reproduced only as [S]. The use at "under regularity conditions" is unaffected.

---

## 6. P17: re-run of `p4_allfits.py`

**Confirmed.** I re-ran `p4_allfits.py` from scratch on a scratch copy: pyerfa 2.0.1.5 from the scratch library, 23 min 43 s wall time with other jobs running alongside.

* The new `p4_allfits.npz` has the same keys as the saved one, and every array is identical (largest difference 0).
* The new `p4_allfits.out` is identical to the saved one apart from the timing lines; it reports a largest difference of 0.00e+00 against `l4_residuals.npz`.
* `p4_kepler.py --all`, run on the regenerated file (4 min 41 s), gives `p4_kepler_allfits.out` byte-identical to the saved one.

Independently, `rb5_kepler.out` part 0 checks the developer's selection with my own rule: the saved minimax and mean series in `l4_residuals.npz` are exactly the four-fit series with the least max |e| and the least mean |e|, with 0 mismatches in 39 series. The fits coincide for EMB over 30 years and the Moon over one month, as the record says.

---

## Verification log

* **Restart check (2026-10-18).** No `referee_code/` and no `referee-B.md` existed. A skeleton report was written first, with a progress log appended after each part. `referee-A.md` appeared during this run; I did not read it, to stay independent.
* **Environment.** Python 3.11.15, NumPy 2.4.6, SciPy 1.17.1. pyerfa 2.0.1.5 comes from the session's scratch library (`PYTHONPATH`). It is used only for the re-run of `p4_allfits.py`; my own code does not need it.
* **My scripts and run times.** Each script writes its `.out` next to itself.

  | script | seed | run time |
  |---|---|---|
  | `rb1_locality.py` | 20261018 | 0.8 s |
  | `rb2_scores.py` | 20261018 | 55 s |
  | `rb3_errormodels.py` | 20261018 | 23 s |
  | `rb4_toy.py` | 20261018 | 1.6 s |
  | `rb5_kepler.py` | 20261018–22; developer split 20261017 | about 8 min from scratch |
  | `rb6_aggregating.py` | 20261018 | 4 s |

  `rb5` keeps a per-series restart cache, deleted after a complete run. The saved `rb5_kepler.out` comes from a clean run without the cache (250 s), and it is identical to the earlier cached run.
* **Bugs found in my own code and fixed before the saved runs.**
  * rb1 D2 first chose the truth off the atoms, which can give an empty cell. It now chooses an atom.
  * rb4 B(i) had a sign error in the decoding (it decoded 80 % of the data). It is fixed, and now decodes 400 000 of 400 000.
  * rb6 A's first bisection used only the p = 1/2 endpoint pool and returned 0.609. That led to finding m5. The final bisection uses central pools and gives 0.50003.
* **Re-runs of the developer's scripts** (§1.1). All seven re-run scripts reproduce their saved outputs:
  * p1, p2, p3, p4_toy, p4_kepler (two fits) and p5 are byte-identical;
  * p4_allfits gives identical arrays and an `.out` that differs only in its timing lines;
  * p4_kepler --all is byte-identical (§6).

  The scratch copies are in the session scratchpad. Nothing was written to `checks/`.
* **References.** About 45 WebSearch queries covering all 39 `refs.bib` entries, the developer's three extra references, predictive-complexity priority, Kepler's 8′, CRIGN's formula, and Zamir–Feder. Results are in §5.
* **Not checked.**
  * Lemma B.2 and the paper's Thm 4.3, on which P23 rests.
  * The exact hypotheses of Bernardo's and McCutcheon's theorems; no full text was available.
  * The Mars-pool fine-resolution entropies, whose residual series were not saved, as the developer says.
