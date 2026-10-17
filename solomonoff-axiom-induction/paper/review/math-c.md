# Mathematics review C: §7 (shape), §9 (laws), §10 (kepler), Appendices E (app-shape), G (app-laws), H (app-kepler)

*Reviewer C, 2026-10-17.*

**Scope.** The review covers six files in `paper/sections/`: `shape.tex`, `laws.tex`, `kepler.tex`, `app-shape.tex`, `app-laws.tex` and `app-kepler.tex`. They were compared with the following sources:
* the final records `research/tracks/shape/notes-final.md` (§0–§13), `research/tracks/laws/notes-final.md` (§0–§13) and `research/tracks/philosophy/notes-final.md` (§4, with §11.1);
* the synthesis `research/notes-final.md` (H3, H8, H10, H11, §2.6, §2.8, §5.3, §5.5);
* `research/final-check.md`, whose items on H3, H8 and H11 bear on these sections.

**What was compared.** Every theorem-like environment in the six files was checked against the record item named in its `\src`, for statement, hypotheses, quantifiers, constants and status. Every proof in Appendices E, G and H was re-read against the record's proof, and several were re-derived. Examples:
* the decomposable-circuit induction of Thm 2.6;
* the GKRS reduction;
* the derivative computation of Prop 3.6a(d);
* the Wald and Hewitt–Savage steps of Thm 3.8;
* the opposition argument of Prop 4.3;
* the arc argument of Prop 4.4.

**Computed numbers.** Each computed number printed in these sections was looked up in the saved script outputs. The outputs used are listed in the verification log at the end.

**Build.** Full build under the lock (`flock /tmp/claude-0/paper-build-sai.lock ./build.sh`):
* 0 LaTeX errors;
* 0 undefined references or citations;
* 0 multiply defined labels;
* 0 overfull boxes over 10pt;
* 230 pages.

**Overall.** The three sections and their appendices are faithful to the records. I found no strengthened statement, no dropped hypothesis and no status stronger than the record's. Several statements are more careful than the record:
* `thm:shape:knowhow`(i) is made conditional on the derivation-size bound, which `rem:shape:knowhowsketch` then supplies as a proof sketch;
* `prop:shape:fixeddepth` takes the Chandra–Fortune–Lipton bound as an explicit hypothesis;
* `prop:laws:fine`(c) adds the hypothesis $\varepsilon^*<\mathsf R/(2\mathrm e)$, which the record left implicit;
* `prop:laws:correction`(f) uses a counter-model valid for every $\varepsilon_{\min}>0$.

The cross-references to the companion papers resolve to the intended items:
* in the steeper-priors paper, Definitions 3.3, 3.4, 3.6 and 5.2, Lemmas 3.8, 3.9, 5.3 and A.1, Corollaries 5.4 and 5.5, Theorem 5.6 and Proposition 5.7 are the labels the record cites (checked in that paper's `main.aux`);
* in the earlier axiom-induction report, Definition E.18 is `def:time:short` and Remark E.9(iv) is `rem:time:links`(iv) (checked in its `main.aux`).

**Issues.**
* **C1 (major).** One computed claim is false as printed. The appendix of §9 gives the regime-G refutation probabilities of the sinusoidal error as holding also for the peaked error. For that error they are about nine times smaller at $\delta=1'$ (0.025 against 0.218), and the saved outputs show it.
* **Minor issues.** The others are imprecisions:
  * a bound stated without its regime;
  * a table caption that equates clause counts with listing length;
  * an endpoint case of an optimality characterisation;
  * a "Hence" that needs a uniform form of Håstad's theorem;
  * small numeric overstatements or understatements (835 bits printed as "at most 800", $8.5\times10^9$ printed as "up to $10^9$");
  * a few wordings that drop a qualifier the record or another section keeps.

**Counts:** 0 fatal, 1 major, 13 minor.

**Writing rules.** Every theorem, proposition, lemma, corollary, definition, remark, question, conjecture and example in the six files carries `\status` and `\src` (checked by a script).
* *Process vocabulary.* A search for process words outside `\src` and `\status` (thread, track, scout, referee, workflow, agent, record, synthesis) finds none in printed text.
* *Model names.* None. The only hits for "claude" are the citation keys `claudeSFI2026steeper` and `claude2026axiominduction`, which are not printed.
* *Credit.* Hänni's working notes are credited only in the footnotes of §7 and §9.

---

## Issues

### C1. [major] Regime-G refutation probabilities attributed to the peaked error are wrong

**Location.** `app-laws.tex`, paragraph "Computations." after `prop:laws:choice` (source line 180), in `app:laws:precision`.

**Problem.** The paragraph reads:

> "In regime G, with $\varepsilon^*=1'$, $\delta_0=0.5'$ and $\zeta$ uniform on $[-\delta_0,\delta_0]$, the refutation probability is exactly $r(\delta)=0.218$ at $\delta=1'$, $6.0\times10^{-4}$ at $\delta=1.49'$, and $0$ for $\delta\ge1.5'$, for a sinusoidal error and for an error equal to $\pm\varepsilon^*$ on $5\%$ of the times and $0$ otherwise."

The values 0.218 and $6.0\times10^{-4}$ belong to the sinusoidal error only. For the peaked error, $r(\delta)$ is the following:
* *Datum with $e=0$.* It is never refuted for $\delta\ge0.5'$, since $|\zeta|\le0.5'$.
* *Datum with $e=\pm1'$.* It is refuted with probability $\Pr[|1-\zeta|>\delta]=1.5-\delta$.
* *Together.* $r(\delta)=0.05\,(1.5-\delta)$, which is $0.025$ at $1'$ and $5.0\times10^{-4}$ at $1.49'$.

Only the threshold (0 for $\delta\ge1.5'$, positive below it) holds for both errors.

**Evidence.**
* `research/tracks/laws/referee_code/rb1_dither_exact.out`, part E, is an exact computation:
  * `sinusoid 1.00: 2.180e-01; ... 1.49: 6.005e-04; 1.50: 0.000e+00`;
  * `peaked 1.00: 2.500e-02; ... 1.49: 5.000e-04; 1.50: 0.000e+00`.
* `research/tracks/laws/checks/l2_precision.out`, part A, is a Monte Carlo run: the spread error gives 2.18e-01 and 6.14e-04, and the peaked error 2.49e-02 and 4.89e-04.
* The source sentence is ambiguous. The laws record §2.2 says "Then $r(\delta)$ is exactly 0.218 at $\delta=1'$, $6.0\times10^{-4}$ at 1.49′, and 0 at $\delta\ge1.5'$ … This holds both for the spread error … and for the peaked one". In the paper it became a false numeric claim.

**Fix.** Replace the sentence with:

> "… the refutation probability is exactly $r(\delta)=0.218$ at $\delta=1'$, $6.0\times10^{-4}$ at $\delta=1.49'$ and $0$ for $\delta\ge1.5'$ for a sinusoidal error, and $0.025$, $5.0\times10^{-4}$ and $0$ for an error equal to $\pm\varepsilon^*$ on $5\%$ of the times and $0$ otherwise: positive below $\varepsilon^*+\delta_0$ and zero above it for both."

Consider also clarifying the laws record §2.2. No statement depends on these values.

---

### C2. [minor] The domain-of-applicability bound in §9 is the fine-regime bound, stated without its regime

**Location.** `laws.tex`, `sec:laws:domains`, first paragraph.

**Problem.** The text reads:

> "Under SAI's pricing that never happens, at cell widths below $\mathsf R/\mathrm e$, for a system that the law confines within about $66^\circ$ …: an honest band of half-width $\varepsilon^*$ costs at most $\log(2\varepsilon^*/\Delta)+\log\mathrm e$ bits per datum, below the literal $\log(\mathsf R/\Delta)$ iff $\varepsilon^*<\mathsf R/(2\mathrm e)$."

The bound $\log(2\varepsilon^*/\Delta)+\log\mathrm e$ is `lem:laws:codeR`(ii) and holds only in the fine regime $\Delta\le2\varepsilon^*$. In the coarse regime the cost is $s_\Delta\beta_e\le(2\varepsilon^*/\Delta)\log\mathrm e$, and the printed bound fails there.
* *Example.* At $\Delta=20\varepsilon^*$ the printed bound is $\log 0.1+\log\mathrm e\approx-1.9<0$, while the cost is positive.

The conclusion is right; `prop:laws:domain`(c) states both regimes correctly.

**Evidence.** The laws record Prop 6.1(c) separates the two regimes:
* fine regime: "$m^M_H\le\log(2\varepsilon^*_M/\Delta)+\log e<\gamma$ whenever $\varepsilon^*_M<\mathsf R/(2e)$";
* coarse regime: "$m^M_H=s\beta_e\le s\log e<\gamma$ for $\Delta<\mathsf R/e$".

The same separation is in `app-laws.tex`, proof of `prop:laws:domain`(c).

**Fix.** Rewrite the colon clause as:

> "an honest band of half-width $\varepsilon^*$ costs at most $\log(2\varepsilon^*/\Delta)+\log\mathrm e$ bits per datum when $\Delta\le2\varepsilon^*$, below the literal $\log(\mathsf R/\Delta)$ iff $\varepsilon^*<\mathsf R/(2\mathrm e)$, and at most $(2\varepsilon^*/\Delta)\log\mathrm e<\log(\mathsf R/\Delta)$ when $2\varepsilon^*\le\Delta<\mathsf R/\mathrm e$."

---

### C3. [minor] The caption of the regimes table equates clause counts with listing length "up to the code length per literal"

**Location.** `shape.tex`, `tab:shape:regimes` caption.

**Problem.** The caption reads: "The inducer is $\Klst^{\mathcal R}$ …, whose value on $\mathcal Q(\mathcal S)$ is this size up to the code length per literal". The entries count clauses (or equations), and $\ell_{\rm lst}$ charges each clause its length times $\lceil\log\bar m\rceil+1$ bits, plus a header.
* *Example.* For one parity law over the base variables the entry is $2^{m-1}$ clauses, while $\Klst^{\UP,\mathrm{base}}=2^{m-1}\big(\ell_{\mathbb N}(m)+m(\lceil\log m\rceil+1)\big)+O(m)$. The two differ by the factor $m\log m$, a clause width times a per-literal cost, not by "the code length per literal".

The text line 56 is correct: "written size, which by (a) is $\Klst$ up to the code length per literal" refers to $\lVert\Phi\rVert$, which counts literal occurrences.

**Evidence.**
* `eq:shape:lst` (`app-shape.tex`).
* Shape record Thm 1.12(a): "the size bounds of §2 are bounds on $K_{\rm lst}^{\mathrm{UP},X}$ … up to the per-literal code length ($\ell_{\rm lst}(\Phi)\ge\|\Phi\|$)". These are bounds, and they are stated for written length.

**Fix.** Replace the caption clause with:

> "… whose value on $\mathcal Q(\mathcal S)$ is the listing length of a least usable theory (\cref{thm:shape:visible}(a)): at least its written length, which is at least the number of clauses given here, and at most a factor $O(w\log\bar m)$ larger for clauses of width $w$."

Alternatively: "… determined by these sizes up to the clause width and the code length per literal."

---

### C4. [minor] `prop:shape:depth`(d): the "Hence" needs Håstad's bound uniformly in the depth

**Location.** `shape.tex`, `prop:shape:depth`(c), (d); proof of (d) in `app-shape.tex`.

**Problem.** Part (c) is stated "for every $k\ge1$ and every $m$ large enough given $k$". Part (d) then says: "Hence $\UP_k$-usable theories of size polynomial in $m$ … need $k=\Omega(\log m/\log\log m)$." This applies (c) with $k$ growing with $m$, which (c) as stated does not allow. The appendix proof notes this ("This comparison applies (c) with $k$ growing with $m$, that is, Håstad's bound for depths up to this order"), but the statement says "Hence" and carries the status "(c), (d) proved, given Hastad 1986". The status is right if the cited form of Håstad's theorem is uniform in the depth, for instance size at least $2^{(1/10)^{d/(d-1)}n^{1/(d-1)}}$ for all $n$. With "for $n$ large enough given $d$", as `app-shape.tex` states it, the status is not right.

**Evidence.**
* Shape record Prop 3.8(c), (d): the same gap. The record's Håstad citation is "[known: … the depth-$d$ form $2^{\Omega(n^{1/(d-1)})}$ is the standard statement, checked by referee B at the level of secondary sources]".

**Fix.** Do one of the following.
* State (c) with the uniform form of Håstad's bound used in (d): "there is an absolute $c_{\rm H}>0$ such that for all $k\ge1$ and $m\ge2$ …", if the cited form gives it.
* Or weaken (d) to: "for each fixed $k$, … superpolynomial; and, given Håstad's bound uniformly in the depth, polynomial size needs $k=\Omega(\log m/\log\log m)$". Mark the second clause as resting on that form.

---

### C5. [minor] `prop:laws:quantile`: the characterisation of the minimisers fails at the endpoint $\varepsilon=0$ when $\theta_{\rm ex}>1$

**Location.** `app-laws.tex`, `prop:laws:quantile` and its proof.

**Problem.** The statement says that "its minimisers are the $\varepsilon$ with $\Prob[\lvert e\rvert>\varepsilon]\le\theta_{\rm ex}\le\Prob[\lvert e\rvert\ge\varepsilon]$". On the domain $[0,\varepsilon^*]$ this two-sided condition is right in the interior. At an endpoint only one side applies.
* *Counter-case.* If $\theta_{\rm ex}>1$, no $\varepsilon$ satisfies $\theta_{\rm ex}\le\Prob[\lvert e\rvert\ge\varepsilon]\le1$, yet $\varepsilon=0$ is the unique minimiser. The right derivative $(2\gamma-(\lambda c_{\rm time}+\gamma)\Prob[\lvert e\rvert>0])/\Delta$ is positive everywhere.
* *The proof.* It says that "the last two claims are the cases $\varepsilon=0$ and $\varepsilon=\varepsilon^*$ of it", but the $\theta_{\rm ex}\ge1$ claim does not follow from the two-sided condition at $\varepsilon=0$.

The separate sentence "If $\theta_{\rm ex}\ge1$, the exact law with patches is optimal" is correct.

**Evidence.**
* Laws record Prop 3.5 has the same two-sided condition and the separate $\theta_{\rm ex}\ge1$ claim.
* The proof's own sentence: "a convex function is minimised exactly where its right derivative is non-negative and its left derivative non-positive". At $\varepsilon=0$ the domain has no left side.

**Fix.**
* Statement: "its minimisers on $[0,\varepsilon^*]$ are the $\varepsilon$ with $\Prob[\lvert e\rvert>\varepsilon]\le\theta_{\rm ex}$ and, if $\varepsilon>0$, $\theta_{\rm ex}\le\Prob[\lvert e\rvert\ge\varepsilon]$".
* Proof: "(at $\varepsilon=0$ only the right derivative matters)".

---

### C6. [minor] "Law-text differences are 100–800 bits for every pair of forms except one" is contradicted by the table

**Location.**
* `kepler.tex`, `sec:kepler:pool`, paragraph "What the data decide and what the syntax decides", item (iii);
* `app-kepler.tex`, `sec:kepler:pooldetails`, paragraph "Text against data".

**Problem.** In `tab:kepler:map` two kinds of pair fall outside the stated range:
* *Above 800.* In S1 and S3 the circle (155 bits) and the equant or vicarious texts (990 bits) differ by 835 bits.
* *Below 100.* In S1 and S3 the equant and vicarious texts have equal length (difference 0), so there are three exceptional pairs, not one. The parenthesis that follows concedes this, which contradicts "except one". The appendix's "between 100 and 800 bits … except that in S1 and S3 the equant and vicarious texts have equal length" has the same 835 problem.

**Evidence.**
* `research/tracks/philosophy/checks/c9_revision.out`, part (8), brackets column: circle 155 / 186 / 155; equant 990 / 450 / 990; vicarious 990 / 468 / 990.
* Philosophy record §4.4 has the same phrase.

**Fix.** "Law-text differences are 100–835 bits for every pair of forms except the equant and the vicarious hypothesis, whose texts are 18 bits apart in the epicyclic syntax and of equal length in S1 and S3 …". Make the same change in the appendix ("between 100 and 835 bits").

---

### C7. [minor] Two overestimation factors in the horizon computation are understated

**Location.** `app-laws.tex`, the paragraph after `prop:laws:horizon` ("…overestimates the exact tolerance $h_{r,i}$ by a median factor of $5$–$300$ at $r=10$ and up to $10^9$ at $r=30$, and the $\infty$-norm Lipschitz bound by up to $10^{13}$").

**Problem.** The saved maxima exceed both printed bounds:
* box against exact at $r=30$: $8.5\times10^9$;
* Lipschitz against exact at $r=30$: $6.78\times10^{13}$.

So "up to $10^9$" and "up to $10^{13}$" understate them by almost a factor of ten.

**Evidence.** `research/tracks/laws/checks/l6_horizons.out`, part B: `d=10 rho=1.00 r=30: median box/exact = 8.5e+09  median Lip/exact = 6.78e+13`. The laws record §4 has the same rounding.

**Fix.** "… a median factor of 5–300 at $r=10$ and up to about $10^{10}$ at $r=30$, and the $\infty$-norm Lipschitz bound by up to about $7\times10^{13}$".

---

### C8. [minor] §9 describes the minimax and mean fits as global optima

**Location.** `laws.tex`, `sec:laws:random`, paragraph "Kepler's residuals.": "we kept the fixed Kepler ellipse with the least largest longitude error (the minimax fit) and the one with the least mean error (the mean fit)".

**Problem.** The sentence reads as the globally minimax ellipse. It is in fact the best of four fits by sample maximum (and by sample mean error), which is how `app-laws.tex` (paragraph "The Kepler residuals.") describes it.

**Evidence.** Laws record §3.6: "One fixed Kepler ellipse (seven elements) is fitted four ways … For each window `l4_residuals.npz` keeps the series of the minimax fit (least sample max|e|) and of the mean fit (least sample mean |e|)".

**Fix.** "we fitted one Kepler ellipse four ways and kept the fit with the least largest longitude error (the minimax fit) and the one with the least mean error (the mean fit)".

---

### C9. [minor] "$U$ is $k$ within one system" drops the identification hypothesis

**Location.** `laws.tex`, `sec:laws:explain`, first paragraph: "when a $k$-bit parameter is integrated out, $U$ is $k$ within one system, $0$ across systems with independent parameters, and the bits of a shared constant across systems that share one".

**Problem.** The value $U=k$ holds only under a hypothesis that the main text drops: each part $D_1$, $D_2$ must have likelihood 0 under every parameter value but the true one. For the shared constant, each $D_i$ must identify $(\theta_{\rm sh},\theta'_i)$. Without these hypotheses, $U$ lies between 0 and $k$.

**Evidence.** `prop:laws:EP`(c). Laws record Prop 5.8(c): "If each of $D_1$ and $D_2$ is proved by $h\cup\{\theta^*\}$ and has likelihood $0$ under every other $\theta$, then $U(D_1,D_2;h)=k$".

**Fix.** "… $U$ is $k$ within one system when each part of the data identifies the parameter, …, and the bits of a shared constant across systems that share one and each identify it".

---

### C10. [minor] "Newton's theory … contradicts" Kepler's laws: the masses and initial conditions are needed

**Location.**
* `laws.tex`, `sec:laws:explain`, second paragraph: "Newton's theory does not entail Kepler's laws; it contradicts them (cf. Duhem)";
* `app-laws.tex`, paragraph before `prop:laws:correction`: "Newton's theory does not entail Kepler's laws: it contradicts them".

**Problem.** Newton's axioms alone are consistent with exact Keplerian motion. A single planet, or massless planets, satisfy both theories. The contradiction needs the actual masses, and initial conditions with non-vanishing mutual perturbations. `kepler.tex` (5) states it correctly: "Newton's axioms do not entail $\mathrm{K12}$ or $\mathrm{K3}$, and with the planets' masses they contradict their exact form, as Duhem observed". The toy `prop:laws:correction`(c) also needs the initial state and $\eta_{\rm c}\mathbf Pa\ne0$. The two sections should agree.

**Evidence.**
* Philosophy record §4.5 item 5: "Newton's axioms do not entail K12 or K3; together with masses and initial conditions they entail corrected statements".
* Laws record §7 reading: "The successor does not entail the old law; it contradicts its exact form (c)". There the successor includes $x_0=a$.

**Fix.** "Newton's theory does not entail Kepler's laws; with the planets' masses and initial conditions it contradicts their exact form (cf. Duhem) and derives corrected statements …". Make the same change in `app-laws.tex`.

---

### C11. [minor] "Compatibility … forces $\proj\Phi=\mathcal S$" omits soundness

**Location.** `shape.tex`, `sec:shape:model`, paragraph after `def:shape:model`: "For affine laws and for the implication chain on $m\ge3$ variables, compatibility with $\mathcal Q(\mathcal S)$ already forces $\proj\Phi=\mathcal S$ (\cref{lem:shape:forces})."

**Problem.** `lem:shape:forces` needs a sound reasoner. With an unsound reasoner, compatibility with $\mathcal Q(\mathcal S)$ says nothing about $\proj\Phi$. The named reasoners are sound, but the definition admits any reasoner.

**Evidence.** `lem:shape:forces` begins "Let $\mathcal R$ be sound". Shape record Lemma 1.5 has the same hypothesis.

**Fix.** "… $\mathcal R$-compatibility with $\mathcal Q(\mathcal S)$, for a sound $\mathcal R$, already forces …".

---

### C12. [minor] The rounding claim at $\tau_{\rm d}=1\%$ attributes to $n$ the rounding of all elements

**Location.** `app-kepler.tex`, `sec:kepler:distdetails`, paragraph "The witness at $\tau_{\rm d}=1\%$": "with $n$ rounded to six decimals the longitude error rises to $6.2'$".

**Problem.** The 6.2′ figure is the error of the witness with *all* elements printed to six decimals (as first printed), with the scale re-optimised. It is not the error with $n$ alone rounded. The likely main cause is the rounding of $n$ (0.00914611825 to 0.009146), but no saved output isolates it.

**Evidence.**
* `research/tracks/philosophy/checks/c10_distances_research.out`, part (1): "referee B's witnesses re-checked … (elements as printed, 6 decimals; the scale is re-optimised …) vicarious tau= 1.00%: … max|dlon| 6.217'".
* `research/tracks/philosophy/referee_code/rb3b_distances.out` line 8 prints the elements as `e1=0.102836, e2=0.083797, w=-1.335871, L=-0.882335, n=0.009146`.
* Philosophy record §11.1 item 2 has the same wording.

**Fix.** "with the elements rounded to six decimals (as first printed; the rounding of $n$ to $0.009146$ is the largest change) the longitude error rises to $6.2'$". Alternatively, drop the sentence.

---

### C13. [minor] "Their saved outputs contain every number" overclaims

**Location.** `app-kepler.tex`, `sec:kepler:rerun`: "Their saved outputs contain every number of \cref{sec:kepler} and of this appendix."

**Problem.** Several numbers in §10 and Appendix H are not script outputs:
* *Literature and documentation figures:*
  * Clemence's decomposition (531″, about 574″, 43″);
  * ERFA's quoted accuracies (17″, 71″, 81″; 26″, 78″, 87″; 7700 km);
  * the 900-year period of the great inequality as historical background.
* *Figures derived from script parameters or prose rather than printed:*
  * "the linearised compatible region fills a fraction of $10^{-5}$ or less of its bounding box" appears only in the docstring of `c4_mars_pool.py`;
  * "about 128,000–152,000 chain steps per row" is not printed by `c4_mars_pool.out`; it equals the chain counts times the kept steps.

**Evidence.**
* `research/tracks/philosophy/checks/c4_mars_pool.py` line 56 (docstring).
* `c4_mars_pool.out` (diagnostics lines print chains, failures and seconds only).
* Philosophy record §4.3–4.5 (literature statuses).

**Fix.** "Their saved outputs contain every computed number of \cref{sec:kepler} and of this appendix, except the two sampler figures (bounding-box fraction, chain steps), which follow from the script's parameters; the other figures are from the literature cited."

---

### C14. [minor] "The first and second halves of the kept steps agree to within 0.05 bits except at 8′" is not quite what the output shows

**Location.** `app-kepler.tex`, `sec:kepler:K3details`, paragraph after the table.

**Problem.** For the kernel width whose value is quoted ($h=0.1$ sd), the two halves give 12.28 and 12.34 at 4′, a difference of 0.06. The claim holds for the other two kernel widths at 4′ (12.32/12.35 and 12.29/12.31).

**Evidence.** `research/tracks/philosophy/checks/c4_mars_pool.out`, part B, row `4`: `12.33+-0.03 [12.32,12.35]  12.31+-0.03 [12.28,12.34]  12.30+-0.02 [12.29,12.31]`. Philosophy record §4.4 Part B has the same phrase.

**Fix.** "… agree to within 0.06 bits except at 8′ (11.33 against 11.23) …".

---

## Checked and found consistent (no issue)

### §7 and Appendix E (shape)

**Statements against the record.** Each of the following matches its record item in hypotheses, constants and status:
* `def:shape:model` (Defs 1.1–1.4, 1.6);
* `thm:shape:invisible` (Thm 1.11);
* `thm:shape:visible` (Thm 1.12; $r\ge1$ is in the definition of an affine law);
* `prop:shape:onlyforced` (2.5a), `thm:shape:minimum` (2.6), `cor:shape:simplex` (2.8);
* `prop:shape:oneround` (3.1a), `prop:shape:depth` (3.8, see C4), `thm:shape:systems` (3.6);
* `cor:shape:regimes` and its table (3.9; all 16 cells);
* `thm:shape:directions` (4.3, with Rem 4.4's program-length part);
* `prop:shape:homes` (5.1);
* `thm:shape:knowhow` (5.2), restated as conditional on the derivation size, which is weaker and correct;
* `thm:shape:learning` (6.2(a)–(f)), `thm:shape:spanner` (7.1(i)–(iv)), `thm:shape:depth2` (7.2);
* `prop:shape:fixeddepth` (7.3), with CFL as a hypothesis;
* `rem:shape:cutfree` (8.1, proof sketch), `prop:shape:lemmaenters` (8.2);
* the lemmas and propositions of App. E.1–E.3.

**Proofs re-derived.**
* The decomposition bounds in the proof of Thm 2.6.
* The GKRS projection with weight-1 and weight-3 functionals.
* The gate count of the circuit for $\UP_k$, which gives $3\lVert\Phi\rVert+2m$.
* The splitting argument for the factor 9.
* The pairing and Harris step of Thm 7.2.
* The Kraft sum in Thm 6.2(d).

**Novelty wording.** The wording for Thm 3.6 follows the bib report §4.1 (the SAT 2026 paper is identified as `beame2026extending`).

### §9 and Appendix G (laws)

**Statements against the record.** Each of the following matches its record item:
* `def:laws:setting`;
* `prop:laws:rounding` (2.5);
* `prop:laws:errormodel` (3.6a(a)–(d)); the derivative and the two peakedness bounds were re-derived;
* `prop:laws:kink` (5.6);
* `def:laws:EP` (5.2), `rem:laws:typical` (4.4; $100\binom{100}{50}2^{-100}=7.959$);
* all propositions of App. G, i.e. laws record Props 1.4, 1.8–1.11, Rem 1.9a, Props 2.1–2.6, Lemma 3.2, Props 3.3–3.5, Lemma 3.6, Props 3.7, 3.10, Thm 3.8, Cor 3.9, Props 4.1–4.3, 5.1, 5.3, 5.5–5.9, the Copernicus comparison, and Props 6.1, 6.2, 7.1(a)–(d″), (e).

**Notational changes.** Measuring length by $\lVert T\rVert$ without the stop bit is declared in the appendix preamble and is harmless: it shifts $J_\lambda$ by the constant $\lambda$. Replacing `fundamentals` Prop 1.8(d) by `rem:terms:named` in `prop:laws:twopart` is correct.

### §10 and Appendix H (Kepler)

**Statements against the record.** Each of the following matches philosophy record Props 4.1–4.4, with the true sentences $\zeta_{\rm K3}$, $\zeta_{\rm pos}$ and the universal quantifier over $\psi$:
* `def:kepler:language`;
* `prop:kepler:ramsey`; the paper adds the non-planet case of (b) correctly;
* `prop:kepler:helio`, `prop:kepler:geo`, `prop:kepler:K3worth`;
* `ex:kepler:K3cost`, `ex:kepler:graded`;
* `tab:kepler:minimax`, `tab:kepler:map`, `tab:kepler:residuals`, `tab:kepler:distances`.

**The Kepler figure.** In `fig:kepler:map`, every coordinate equals $4\log_{10}(720'/\delta)$ for the stated $\delta$, and the MAP segments agree with c4 table A4.

**Statement discipline.** The synthesis §5.5 rules are respected: figures are against plan94, minimax values are upper bounds, the pool is hand-picked and heliocentric, "the syntax decides" is limited to the noise-free regime, Part C reproduces the abandonment of circles only, and K3's worth depends on the parametrisation.

---

## Verification log

* **Restart check.** At the start of this run `paper/review/` held only `math-a.*` and `math-b.*`, and no partial `math-c.*` existed. A skeleton `math-c.md` and `math-c.json` were written first, and working notes were appended after each part.
* **Build.** `flock /tmp/claude-0/paper-build-sai.lock ./build.sh`: 0 errors, 0 undefined references or citations, 230 pages.
* **Read in full.**
  * The six section files.
  * The shape record §0–§13.
  * The laws record §0–§13.
  * The philosophy record §4 and §11.1.
  * The synthesis §0, §1 (H1–H15), §2, §5.3–§5.5 and §6.5–§6.6.
  * `final-check.md`.
  * The brief.
  * Bib report §4.1.
* **Outputs checked** (numbers compared with the paper):
  * `shape/checks/c1_linear_noaux.out` (D, E), `c3_directions_decider.out`, `c5_learning.out`, `c6_spanners.out`, `c7_revision.out` (A–M);
  * `laws/checks/l2_precision.out`, `l3_phases.out`, `l6_horizons.out`, `l7_best_system.out`, `l9_correction.out`, `l10_revision.out` (A–J);
  * `laws/referee_code/rb1_dither_exact.out` (E, F), `rb3_selection.out`, `ra1_checks.out` (D, E);
  * `scouts/novel-science/checks/n2_best_system.out` (the asteroid median);
  * `philosophy/checks/c4_mars_pool.out` (A1, A2, B), `c7_geocentric_arc.out`, `c9_revision.out` (2)–(9), `c10_distances_research.out`;
  * `philosophy/referee_code/rb3b_distances.out`;
  * `scouts/philosophy/checks/c1_kepler_fit.out`, `c3_kepler_constant.out`.

  Apart from C1, C6, C7, C12 and C14, every computed number in the six files was found in these outputs, or follows from them by the arithmetic shown in the paper:
  * the figure coordinates;
  * the crossover counts $\text{text advantage}/\text{penalty}$;
  * $\lvert\mathrm{K3}\rvert/s_{\rm K3}$;
  * the Q/R retention ratios $1.83$–$6.90$, $3.87$–$11.3$, $7.62$–$16.0$.

  The asteroid median of about five comes from the scout output; re-running the population generator of `l7_best_system.py` in the scratchpad also gives median 5.
* **Cross-references to companion papers.**
  * `../solomonoff-operator-induction/paper-steeper/main.aux`: `def:setup:product` 3.3, `def:setup:shared` 3.4, `def:setup:objectives` 3.6, `lem:setup:hull` 3.8, `lem:setup:coding` 3.9, `def:kink:kinks` 5.2, `lem:kink:main` 5.3, `cor:kink:locate` 5.4, `cor:kink:split` 5.5, `thm:kink:converse` 5.6, `prop:kink:universal` 5.7, `lem:setup:basic` A.1.
  * The zero-window kink definition in `laws.tex` matches that paper's Definition 5.2.
  * `../axiom-induction/paper/main.aux`: `def:time:short` E.18, `rem:time:links` E.9, whose item (iv) is the observation cited.
* **Scripts run.** Two throwaway scripts in the scratchpad (`/tmp/claude-0/-home-user-AI-works/c4435474-536f-5a96-a73c-7d0c5ea93659/scratchpad/mathc/`):
  * a check for `\status`/`\src` and process words;
  * the population replication `pop.py`.

  Nothing in the repository was changed except the two review files. No git command was run.
* **Not done.**
  * No long script was re-run (c4, c10, l10).
  * No literature was searched.
  * The other referees' code was not re-run.
