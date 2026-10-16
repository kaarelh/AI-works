# Thread brief: laws (kind: math)

**Title.** Approximate laws, exceptions and the best system: precision, honesty, laws versus initial conditions, explanatory power.

**Read first.** `../../00-brief.md` (the author's request names Kepler's laws giving only approximately correct predictions as a limitation; the seed ideas "Approximate theories", "Laws versus initial conditions" and "Explanation"), `../../NOTATION-draft.md` (binding; §6.4 fixes $J_\lambda$, $\mathrm{Exc}_D$, $\mathrm{EP}_D$, $T_0$, $T^\varepsilon$, $e(t)$, $\varepsilon^*$, $\delta$, $\delta_0$, $\Delta$, $\mathrm{pk}(e)$, $\gamma$), `../../select.md`. Then scout N2's record `../../scouts/novel-science/notes.md` **§0, §1 (C1–C3, C7–C10, C16, C17, C19), §3, §4, §6 items 3–5, §7** with `checks/n2_best_system.*` and `checks/n3_precision_phases.*`; scout P's record `../../scouts/philosophy/notes.md` **§2.4–§2.5** (Prop 2.3, Tables 2.1–2.3, the Newton material) and §5 Q1, Q4, Q8 with `checks/c1_kepler_fit.py`; scout F's F14 (laws plus exceptions); SOI Paper 2 `../../../../solomonoff-function-induction/paper-steeper/` (`setup.tex`, `kinks.tex`: `def:setup:objectives`, `lem:setup:hull`, `lem:setup:coding`, `lem:kink:main`, `thm:kink:converse`, `cor:kink:split`, `cor:kink:locate`).

**Deliverable.** `tracks/laws/notes.md`, scripts in `tracks/laws/checks/`, ending with a Verification log.

---

## Goal

Turn "Kepler's laws are only approximately right" and "laws versus initial conditions" into exact selection theorems for axiom induction, and give the best-systems account of laws and the explanatory-power measure a precise form. Scouts P and N2 found:
* **proof-requiring SAI prefers a false exact law to its true tolerance-weakened version** on interval data at every sample size, and answers finer questions overconfidently (scout P Prop 2.3), so the simplicity prior alone does not deliver honest approximate theories;
* precision belongs to the data set: under guaranteed tolerances an exact false law survives exactly while $\delta\ge\varepsilon^*+\delta_0$; under dithered rounding it is refuted after about $1/p_\Delta$ data however coarse the data (scout N2 Prop 3.1);
* with exceptions coded literally, whether an inexact law is held as "approximately true" (honest, silent at fine precision) or as "exact with exceptions" (overconfident) is decided by the peakedness of its error (the $\mathrm{pk}$ criterion, scout N2 Prop 3.2);
* an honest approximate dynamical law answers only within a derivation horizon (Prop 3.3);
* in the two-part code with a steeper prior, the model–randomness split of SOI Paper 2 separates reused facts from facts used once, not laws from initial conditions; what singles out laws is how their explanatory power scales with the number of systems (Props 4.2–4.7).
The thread must make each of these exact, connect the objective used to the paper's inducers, extend the expected-cost statements to almost-sure ones, and apply them to the real Kepler residuals.

## Targets

**T1 (core) The setting and its relation to SAI.** Define the hypotheses "law plus listed exceptions" $(T,E)$ and the objective $J_\lambda(T;D)=\lambda|T|+\mathrm{Exc}_D(T)$ precisely (what $|T|$ is: an additive prefix code; what an exception costs: the literal code of the datum given the question, with or without its index). Prove the relations to the paper's inducers:
* a pair $(T,E)$ is the theory $T\cup E^\pm$ (or $T$ with a clause withdrawn at the exceptional points, plus the datum), a deterministic hypothesis of $M_A$ and $W_A$; hence $L_A(D)\le\min J_1+O(\log)$ (scout F's F14(b)), and state the converse inequality that holds;
* for $\lambda>1$ the λ-MAP is SOI Paper 2's steeper MAP for a "law + literal facts" class, so that P2's hull lemma, kink lemma and `thm:kink:converse` apply to the point family $(|T|,\mathrm{Exc}_D(T))$. State any hypothesis of P2's lemmas that needs checking in this class.

**T2 (core) Interval data and precision.** Scout P's Prop 2.3 (proof-requiring SAI prefers $T_0$ to $T^\varepsilon$ on every data set compatible with $T^\varepsilon$, with posterior odds $\ge2^{|T^\varepsilon|-|T_0|}$; $T^\varepsilon$ is silent where $T_0$ is overconfident), monotonicity in $\delta$, and scout N2's Prop 3.1 ((G) guaranteed tolerances: sharp threshold $\delta=\varepsilon^*+\delta_0$, almost-sure refutation below it by Borel–Cantelli; (R) dithered rounding: $\Pr[\text{survive }n]=(1-p_\Delta)^n$ with $p_\Delta=\Ex\min(|e|/\Delta,1)$). Correct the brief's seed accordingly (what is true: the switch point is $\varepsilon^*+\delta_0$ under guaranteed tolerances; under rounding the relevant quantity is number of data × error/precision).

**T3 (core) Honest approximate laws against laws with exceptions.** Scout N2's Prop 3.2 (four candidates: exact law $T_0$; $T_0$ with patches; honest law $T^{\varepsilon^*}$; a better theory; per-datum expected costs; for $\Delta\ge2\varepsilon^*$ the honest law is cheaper iff $\lambda\pi_c>\gamma_f(2\,\mathrm{pk}(e)-1)$; for $\Delta\to0$ iff $\Pr[e\ne0]>\gamma_f/(\lambda\pi_c+\gamma_f)$). Then:
* **strengthen to almost-sure statements**: on i.i.d. sampled times and dithers, which of the four is the λ-MAP after $n$ data, eventually almost surely, with the switch points (law of large numbers for the costs; state the exceptional ties);
* the sequence of phases E → P → H → N as $n$ grows, with explicit switch points, checked by simulation;
* the "independent" mass of the posterior on fine questions as the share of honest theories: the trichotomy as the formal home of humility;
* **apply to the real Kepler residuals**: compute $\mathrm{pk}(e)$ per planet and window from ERFA planetary theory residuals of fixed Kepler ellipses (re-use scout P's `c1_kepler_fit.py` machinery on a scratch copy, installing pyerfa in a scratch library folder outside the repository as scout P did; save the residual series you use in your `checks/`), and say which form (honest law or law with exceptions) the inducer selects for each planet, window and precision.

**T4 (core) Derivation horizons and the sound criterion for approximate reasoning.** Scout N2's Prop 3.3 (derived tolerance $e_r=L^re_0+\varepsilon(L^r-1)/(L-1)$; tight for linear maps; horizon $r^*(\delta)$), Cor 3.4 (two exact approximations that differ anywhere are jointly inconsistent; their honest versions are jointly consistent iff the tolerances overlap, and every conclusion carries a propagated tolerance). State the sound criterion as a proposition (this is the formal content behind the "Possible error" candidate of scout N2 §7, which `philosophy` T6 assesses; do not write the assessment here), and the typical-versus-worst-case comparison (random-sign errors) as a computed remark.

**T5 (core) The best system as a steeper MAP; explanatory power.** Scout N2's Prop 4.2 (every module of a λ-MAP has deletion slope $\ge\lambda$; every addition $\le\lambda$), Def 4.3 ($\mathrm{EP}_D$), Prop 4.4 (facts used once never enter for $\lambda>1$; the coding bound), Prop 4.5 (the solar-system toy: closed form for the λ-MAP; the law's slope scales with the number of systems, the elements' with the observations per system; K3 is a law about initial conditions), Prop 4.6 (Lewis's "kind nature": the best system is the same for all $\lambda$ in an interval iff the hull has a kink there; via P2 `thm:kink:converse`), Prop 4.7 (trivialisation by a gerrymandered predicate is blocked: no extension beats $K(\text{answers}\mid\text{questions})-O(1)$), the Copernicus–Ptolemy coincidence as unification without better prediction ($\mathrm{EP}=\sum_pa_p/H$). Relate $\mathrm{EP}$ to ILP compression measures and Myrvold's unification measure (scout L verified Myrvold 2003; verify what Myrvold's measure is and state the relation precisely). In the question format, initial conditions are question antecedents and laws answer conditional questions with no elements at all (cite `philosophy` T4 for the Ramsey-sentence fact; do not re-prove it).

**T6 (core) Domains of applicability and retention of superseded theories.** Scout N2's C16 (a domain-restricted law "$\mathrm{Dom}(b)\to\text{law}(b)$" pays iff $|\mathrm{Dom}|$ plus the excluded data's cost is below the cost of the exceptions; the Moon) and C17 (with derivation-symbol charges at rate $r_d$ bits per symbol, a superseded theory with short derivations stays the MAP on coarse data in its domain while the derivation savings exceed the length difference plus the lost fit). Precise statements and proofs; a small computed instance each.

**T7 (extension, high priority) Explanation by approximate correction.** Scout N2's C19 in a provable toy: a successor theory $T_N$ that proves the honest law $T^{\varepsilon(W)}$ on a window $W$ and refutes the exact law $T_0$. Suggested toy (or a better one): discrete-time planar dynamics over ℚ or real algebraic numbers, $T_0$: $x_t=R_\theta^t x_0$ (uniform circular motion), $T_N$: $x_{t+1}=(R_\theta+\eta P)x_t$ with small $\eta$; then $T_N\vdash|x_t-R_\theta^tx_0|\le\varepsilon(W)$ for $t\le W$ with explicit $\varepsilon(W)$, and $T_N\vdash\neg T_0$; every statement is decidable in real closed fields for fixed $W$, so the derivations exist and their size can be bounded. State the reading: the honest form of an approximate law is exactly what its successor explains (Duhem's point; Schaffner's corrected reduction; verify both references).

**T8 (extension) Learning a domain of applicability.** Scout P's Q8 on a hand-picked pool: does the posterior (or λ-MAP) over theories of the form $\mathrm{Dom}(x)\to\text{law}(x)$ find "planet ∧ window" and exclude the Moon on the Kepler data? Only if T1–T6 are done.

## What is known (references to verify)

Forster–Sober 1994 (AIC and simplicity); Rissanen 1978, Wallace 2005, Grünwald 2007 (MDL, MML, measurement precision); Lewis 1973 (pp. 72–77), 1983, 1994; Cohen–Callender 2009; Woodward 2014; Myrvold 2003; Kitcher 1981, 1989; Friedman 1974; Schaffner 1967; Duhem; Moulines 1976 (structuralist approximation); Niiniluoto 1987 and the Popper–Miller–Tichý refutation (truthlikeness); Valiant 2000 and Juba 2013 (PAC semantics; rules robust to counterexamples); Hutter 2010 (theory plus observer location); Gács–Tromp–Vitányi 2001 and Vereshchagin–Vitányi 2004 (algorithmic statistics; model/noise split). Verify by WebSearch what each says before relating the results to it. Scout N2 could not search; its literature claims are unverified.

## What to verify computationally

* Re-run scout N2's `n2` and `n3` on scratch copies; compare.
* **Independent** code: the closed-form λ-MAP of Prop 4.5 against brute force on fresh random populations; the four-phase sequence and switch points of T3 by simulation with many seeds; the a.s. statements by long runs; the horizon formula against interval propagation for random linear maps.
* The real-residual computation of T3 (saved residual series, $\mathrm{pk}(e)$ per planet and window, selected form per precision).
* T7's toy: exact or interval arithmetic for the bounds $\varepsilon(W)$, and a check that the exact law is refuted.

## What this thread must NOT do

* Not the Kepler language, axioms, Ramsey and direction-language propositions, the historical Mars pool and its tables (`philosophy` T4). Use their data; do not rebuild the example.
* Not usability of theories by bounded reasoners (`shape`), and not theoretical terms (`terms`).
* Not the philosophical assessment of the "Possible error" candidates or of the best-systems debate beyond a precise "what this shows" paragraph (`philosophy`).
* Not re-prove SOI Paper 2's lemmas; cite them and check their hypotheses.
