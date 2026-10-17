# Referee report A (proofs) on thread `laws`

*Adversarial referee A, 2026-10-16. Object: `tracks/laws/notes.md` (653 lines, last modified 02:47; unchanged when this report was finished) and its scripts in `checks/`. Sources checked against: the project brief and the thread brief, `NOTATION-draft.md`, the `fundamentals` record (`../fundamentals/notes.md`: Defs 1.2, 1.4, 1.7, Prop 1.8, Thm 4.1, Thm 5.1, Prop 5.2, Props 5.6, 6.1, Thm 6.2), SOI Paper 2 (`paper-steeper/sections/setup.tex`, `kinks.tex`, `app-setup.tex`, `app-kinks.tex`: `def:setup:data`, `def:setup:product`, `def:setup:shared`, `def:setup:class`, `def:setup:objectives`, `lem:setup:basic`, `lem:setup:hull`, `lem:setup:coding`, `def:algstat:product`, `def:kink:kinks`, `lem:kink:main`, `cor:kink:locate`, `cor:kink:split`, `thm:kink:converse`, `prop:kink:universal`, `rem:kink:reading`, `cor:absorb:nouniversal`), scout N2's record (Prop 4.5), and the literature scout's record (`../../scouts/literature/notes.md` §5). My own checks are in `referee_code/ra1_checks.py`, with its output in `ra1_checks.out` (seed 20261016, 42 s).*

## Verdict

**Accept after revision. Nothing is fatal. Six issues are major, and each has a concrete fix.**

What holds up:

* Most proofs are correct line by line. That includes §1, the core probability of §§2–3, Thm 3.8, §4, §5 and Prop 7.1(a)–(c).
* The thread uses P2's lemmas and the `fundamentals` results with their hypotheses. The exceptions are the minor gaps listed below.

The major issues:

* **M1.** The probabilistic setting of §3 (Setting S3) contradicts the formal setting of §1. Times are numerals, so no atomless law of times exists. Repeated times change the rates of Prop 3.3, and my check shows the change is large. Distinct times instead make the cost $\pi_c$ of naming a time unbounded. The fix is a restatement, not a new proof. It affects the deterministic-patch pricings and the code-R results.
* **M2.** The reading of Prop 7.1 says the honest form is "exactly" what the two theories have in common. This is false: their common content is $T_0\vee T_N$. The same wording appears in §0, §7, §9.1 and §13.
* **M3–M4.** These are two statements that are false as written, each with a one-line fix:
  * Prop 4.3(b),(c) need a background that decides the relevant sentences;
  * Prop 6.1(b) and Prop 6.2(b) fail at ties, and Prop 6.1's own part (c) and its table use exactly the tie case.
* **M5.** Thm 3.8 is applied to code-R costs, which are unbounded. The theorem's stated hypothesis is bounded costs.
* **M6.** The "peakedness" reported for the real Kepler residuals is a ratio across two different fits. It is not $\mathrm{pk}(e)$ of any one law.

There are 21 minor issues. One of them (m4) tightens Lemma 3.6: it gives a proof that moves the "about 24°" constant of Props 3.7 and 6.1(c) to about 66°. The novelty claims agree with scout L's record. Two citations are missing:
* a known form of the quantile result of Prop 3.5, from ν-support-vector regression;
* the ILP precedent for law-plus-exceptions coding (Srinivasan–Muggleton–Bain 1994), which scout L lists and §9.2 omits.

---

## Major issues

### M1 (major). Setting S3 contradicts Def 1.5: atomless i.i.d. times cannot be numerals

**Where.**
* The conflict: Setting S3 (§3.1), "times are i.i.d. from an atomless $\mu$ (so they are almost surely distinct)", against Def 1.5, which uses "fresh constants $q_t$ for $t$ in a decidable set $I$ of numerals".
* Used in:
  * Prop 3.3 (rates of P, and of H in code R);
  * Thm 3.8's application in Cor 3.9;
  * Prop 3.10(a) ("$t'$ is almost surely not a patched time");
  * §3.6 (the det pricings, with "naming a time costs $\pi_c=\log(\text{days in window})+2$");
  * Props 6.1(b),(c) and 6.2(b);
  * the scripts `l3`, `l5`, `l8`, which draw $t\sim U[0,1)$.

**Problem.**
* **No atomless law exists.** Data are sentences, so they mention at most countably many times, and no atomless probability law lives on a countable set. The two ways to repair this both change the theorems.
* **(i) I.i.d. times from a law on a countable set repeat.** The number $K_n$ of distinct times among $n$ draws is $o(n)$ almost surely. The proof is short: fix a finite $F$ with $\mu(F)\ge1-\epsilon$; then $K_n\le|F|+\#\{j\le n:t_j\notin F\}$, and the strong law gives $\limsup K_n/n\le\epsilon$. Repeats change the per-datum costs:
  * A patched law withdraws the law at a whole time. Every later datum at a refuted time is then an exception, so P's rate climbs towards $\gamma\cdot\Pr[t\text{ eventually refuted}]$.
  * In code R the cells at one time intersect (Def 1.7). The honest law's cost per datum therefore falls.
  * Q/rand withdraws the law per time, not per datum.

  `ra1_checks.out` part E shows this. The settings: sinusoidal error, $\varepsilon^*=1'$, $\Delta=60'$, $\lambda=1$, times uniform on the 4383 days of a 12-year window, and $\pi_c=\log_24383+2$ as in §3.6. The costs per datum are:

  | $n$ | $K_n/n$ | P (Q/det) | H (code Q) | H (code R) |
  |---|---|---|---|---|
  | $10^3$ | $0.90$ | $0.40$ | $0.26$ | $0.037$ |
  | $10^5$ | $0.044$ | $1.96$ | $0.28$ | $0.026$ |
  | $2\times10^5$ | $0.022$ | $3.23$ | $0.28$ | $0.022$ |

  For comparison, Prop 3.3 gives $m_P=0.240$, $m_H=0.283$ and $m_H^R=0.030$. So on this grid P is eventually far worse than H under Q/det, whereas the rates of Prop 3.3 make P the winner.
* **(ii) Distinct times leave no i.i.d. law of times, and the naming cost grows.** One could take $t_j$ the $j$-th fresh numeral, with the errors and dithers i.i.d. But at most $2^k$ numerals have codes of length $\le k$. So all but $O(2^k)$ of the first $n$ times cost more than $k$ bits to name, and $\pi_c(t_j)\gtrsim\log j$. More precisely, a random patch set $S\subseteq\{1..n\}$ of density $p$ has $K(S)\approx nH_2(p)$, so no sentence code names it more cheaply. Deterministic patching therefore costs at least about $H_2(p)/p$ bits per exception, and with literal numerals about $\log n$. A constant $\pi_c$ is a finite-horizon approximation, valid while $n\ll2^{\pi_c}$, and at that horizon repeats begin as in (i).

**What survives.**
* **Props 2.4–2.6.** An exact law decides each datum by itself, so the refutation indicators stay i.i.d. even with repeated times.
* **The randomised-exception pricings (Q/rand, R/rand)** with distinct times. These need no naming of times, and they are what §§0, 3.6 and 9.1 call SAI's pricing.
* **Thm 3.8** itself, given its hypotheses.

**Fix.**
* **Restate Setting S3.** Use distinct times, $t_j$ an injective computable sequence of numerals (for instance $t_j=j$), with the pairs $(e(t_j),u_j)$ i.i.d. (or stationary ergodic, if the Kepler sampling is to be modelled).
* **For the det pricings, choose one of two readings:**
  * (a) replace $\pi_c$ by the actual code length $\pi_c(t_j)$, show that P's per-datum cost diverges or approaches $H_2(p)/p$ per exception, and restate Cor 3.9 and the §3.6 Q/det conclusions as statements at a stated horizon; or
  * (b) state openly that Q/det and R/det with constant $\pi_c$ are a finite-horizon model ($n\le2^{\pi_c}$, times drawn without replacement), and drop "almost surely, eventually" for them.
* **State the repeated-times case as a remark,** citing part E.
* **Update the scripts' docstrings,** which say $t\sim U[0,1)$.
* **Prop 3.10(a)** then needs "$t'$ fresh" by assumption.

### M2 (major). Prop 7.1's reading: the honest form is not "exactly what the two theories have in common"

**Where.**
* §0 T7: "shares with it exactly the honest form".
* §7 Reading, second bullet: "The honest form is exactly what the old and the new theory have in common (d)".
* §9.1 "Explanation": "exactly what its successor derives and what the two theories have in common".
* §13 row "Prop 7.1 (a)–(d)": "honest law is the strongest common consequence".

**Problem.**
* **What Prop 7.1(d) proves is narrower.** Among the tolerance forms $H^\varepsilon_W$, the strongest one that both $T_0^W$ and $T_N^W$ prove is $H^{\varepsilon_{\min}(W)}_W$. That is correct.
* **The common content is larger.** For finite theories it is $\Cn(T_0^W)\cap\Cn(T_N^W)=\Cn(T_0^W\vee T_N^W)$, which pins each $x_t$ to one of two points, while $H^{\varepsilon_{\min}}_W$ only bounds $x_t$ to a disc.
* **Concrete model.** `ra1_checks.out` part F, with $W=1$, $P=JR$, $\eta=1/100$: the point $x_1=Ra+\eta Pa/2=(149/250,803/1000)$ satisfies $|x_1-Ra|^2=1/40000\le\varepsilon_{\min}(1)^2=1/10000$, and it equals neither $Ra$ nor $Aa$. So $(a,x_1)$ is a real model of $H^{\varepsilon_{\min}}_1$ and of neither theory.
* **The successor derives more.** "Exactly what its successor derives" is also false: $T_N$ proves $x_t=A^ta$.

**Fix.**
* Replace these phrases with: "the strongest tolerance form of the old law that the successor proves, and the strongest one common to both theories".
* Add one sentence: the full common content is $T_0\vee T_N$, which is not a tolerance law.
* Correct the §13 row.

### M3 (major; false as stated, one-line fix). Prop 4.3(b),(c) need a background that decides the relevant sentences

**Where.** Prop 4.3(b), "inconsistent iff $f_i(t)\ne f_j(t)$ for some $t\in\mathrm{Dom}_i\cap\mathrm{Dom}_j$", and (c), "consistent iff for each $t$ the balls have a common point". The stated hypothesis is only "a background $B$ true in the intended structure".

**Problem.**
* The "if" of (b) and the "only if" of (c) need $B$ to *prove* the failure. In (b) that is $\exists t\in\mathrm{Dom}_i\cap\mathrm{Dom}_j\,f_i(t)\ne f_j(t)$; in (c) it is the corresponding disjointness.
* The proof's "which $B$ refutes" does not follow from $B$ being true.
* **Counterexample.** $B=\emptyset$, $f_i(t),f_j(t)$ distinct constant symbols, $\mathrm{Dom}$ a single point: $\bigcup T^0_i$ is consistent (interpret the two constants as equal) although the values differ in the intended structure.
* The proof of (c) ("the models are exactly the choices of $q(t)$ in the intersection") describes only expansions of the intended structure, not all models of $B$.

**Fix.** Assume that $B$ decides every sentence built from the $f_i$, the $\mathrm{Dom}_i$ and the $\varepsilon_i$ (for instance $B=\mathrm{RCF}$ with semialgebraic $f_i$, $\mathrm{Dom}_i$ and rational $\varepsilon_i$, which is the case §4 uses). Then the proofs go through as written. Alternatively, state (b),(c) for consistency with the complete theory of the intended structure.

### M4 (major; internally inconsistent, one-line fix). Prop 6.1(b) and Prop 6.2(b) fail at ties, and 6.1(c) uses the tie case

**Where.**
* Prop 6.1(b): "almost surely the restriction is eventually in the λ-MAP iff $\gamma<\min(m^M_P,m^M_H)$".
* Prop 6.1(c), last sentence, and the l8 A table, code Q at $\Delta=10',60'$: "Moon excluded (honest law silent at the literal rate)".
* Prop 6.2(b): "iff $m_K<m_N$".

**Problem.**
* **Code Q at $\Delta\le2\varepsilon^*_M$ is a tie.** The honest form of $M$ costs exactly $\gamma$ on every datum, the same as literal data, so $m^M_H=\gamma$ and the cost difference is $0$ almost surely. By Thm 3.8(ii), last sentence, the constants then decide forever:
  $$J_\lambda(\Lambda_{\rm Dom})-J_\lambda(\Lambda+E_M\text{ honest})=\lambda(\|\mathrm{Dom}\|-k_M-h_M)<0 .$$
  So the restriction *is* eventually (indeed always) in the MAP, against P when $m^M_P>\gamma$.
* **The two statements disagree.** (b) says "not eventually in", since $\gamma=m^M_H$ is not $<$. Yet (c) and the table assert exclusion.
* **Prop 6.2(b) has the same gap** when $q_K=1$, $\gamma_{\rm si}=c_N$ in code Q.

**Fix.** State the three cases of Thm 3.8:
* strict inequality decides;
* a tie with non-constant difference oscillates;
* a tie with almost surely constant difference is decided by the length terms.

Then (c)'s code-Q sentence becomes: "the restriction pays iff $m^M_P>\gamma$ and $\|\mathrm{Dom}\|<k_M+h_M$".

### M5 (major). Thm 3.8 assumes bounded costs, but it is applied to code-R costs, which are unbounded

**Where.**
* Thm 3.8 assumes $c_X(d)\in[0,b]\cup\{\infty\}$.
* Verification log item 5 says: "the exact law's infinite cost is the only unbounded one".
* Thm 3.8(i) is applied to R/det and R/rand in §3.6 ("The asymptotic λ-MAP among the forms is the least rate (Thm 3.8(i))") and in Props 6.1(b),(c) and 6.2(b) with code R.

**Problem.**
* **The cost is unbounded.** The code-R cost of a silent datum is $-\log(\text{share of the band in }q\text{'s cell})$. By the proof of Lemma 3.6 this is $-\log V$ or $-\log(1-V)$, which exceeds every $b$ when $q$ is near an end of its band ($|e(t)|\to\varepsilon^*$). That happens for the sinusoid and for the Kepler residuals.
* **The step that uses boundedness.** The proof of (i) uses it to get "$m_X=\infty\Rightarrow\Pr[c_X=\infty]>0$". (iii) uses $b$ in the Wald bound.

**Fix.** Restate the parts under weaker hypotheses:
* (i) for integrable finite costs (the strong law needs only $\Ex|c_X|<\infty$; treat $m_X=\infty$ with finite costs separately or exclude it);
* (ii) for finite variance (the central limit theorem);
* (iii) as it stands, for bounded increments.

Add one line: the code-R silence cost has all moments, since $-\log V$ with $V$ uniform is exponential. Then every application in the record is covered.

### M6 (major). The reported "peakedness" of the real Kepler errors is a cross-fit ratio, not $\mathrm{pk}(e)$

**Where.**
* §3.6: "$\varepsilon^*$ is the smallest sample maximum over the fits …, $\Ex|e|$ the smallest sample mean"; the table column "$\mathrm{pk}(e)$ range"; "the real Kepler errors are spread, with peakedness between 1.9 and 4.0".
* §0 T3: "The peakedness is 1.9–4.0".
* `l5_kepler_select.py` docstring: "Pure forms: P = (eps = 0, mean fit), H = (eps = eps* of the minimax fit, minimax fit)"; `pk = eps_star / Ee`.

**Problem.**
* **The ratio mixes two fits.** NOTATION §6.4 defines $\mathrm{pk}(e):=\sup|e|/\Ex|e|$ for *one* error function. The reported number is $\varepsilon^*(\text{minimax fit})/\Ex|e|(\text{mean fit})$, which comes from two different ellipses.
* **It sits between the two true values.** It lies between the minimax fit's own $\mathrm{pk}$ (smaller) and the mean fit's own $\mathrm{pk}$ (larger), and is neither.
* **Prop 3.4 is about one law.** Prop 3.4 compares the honest and patched forms of *one* law. What `l5` checks (1757/1757) is the criterion $q_{\rm minimax}\gamma_{\rm si}<p_{\rm mean}\gamma_{\rm ex}$ for two different laws of about equal length. That is a legitimate comparison, and the rate-based selection results stand, but it is not Prop 3.4 as stated.

**Fix.**
* Report each fit's own $\mathrm{pk}$.
* Rename the cross ratio (for instance "$\varepsilon^*_{\rm mm}/\Ex|e_{\rm mean}|$").
* State Prop 3.4's two-law variant in one line (the proof is the same).
* Rephrase "the real Kepler errors are spread" accordingly.
* Also note that $\varepsilon^*$ is a sample maximum. A true honest law needs the window's true supremum, so H with the sample maximum is slightly false and would eventually be refuted. Inflate the tolerance slightly, or say that the tolerance family's randomised exceptions cover it.

---

## Minor issues

**m1. Lemma 3.2's "coarse regime" condition is too weak when $\varepsilon>\varepsilon^*$.**
* **Problem.** With $|e|=\varepsilon^*=1$, $\varepsilon=2$, $\Delta=3=\varepsilon+\varepsilon^*$, the lemma's coarse formula gives silence probability $2\varepsilon/\Delta=4/3$. The true value is $1$ (`ra1_checks.out` A). The self-check in Verification log item 5 covers only $\varepsilon\le|e|$.
* **Fix.** Use $\Delta\ge\varepsilon+\max(\varepsilon,\varepsilon^*)$. All uses in the record have $\varepsilon\le\varepsilon^*$ and are unaffected.

**m2. Data must be sentences.**
* **Problem.**
  * In Prop 2.5 and Setting S3 the cell endpoints $\Delta(m-u_j)$ with $u_j\sim U[0,1)$ are irrational almost surely. In Prop 2.4 the centres $v_j=q(t_j)+\eta_j$ must be rational. Neither condition fits interval sentences of $\mathrm{RCF}$ with rational constants (Def 1.5).
  * Setting S3 puts the quantity on a circle. There a wrapping cell is a union of two intervals, and Def 1.5's range $[0,\mathsf R]$ does not apply.
* **Fix.** Use a fine rational (dyadic) dither $u_j\in\{k/N\}$ (probabilities change by $O(1/N)$), or allow real algebraic constants. Write a wrapping cell as a disjunction, and say so.

**m3. Prop 1.10(i): the class $\mathcal H^R$ must be a restricted presentation language.**
* **Problem.**
  * "Programs are the codewords of law presentations (a decidable prefix-free set)" with $P^R_T$ "computable uniformly in $T$" needs every presentation to compute a total pair $l\le u$. No decidable set of programs covers all total computable functions.
  * The class must also fit P2's `def:setup:data`: a finite label set $Y$, with $X=\{0,1\}^*$. Questions with different numbers of cells need an encoding.
* **Fix.** Fix a presentation language of total programs (for instance primitive recursive, or clipped and time-bounded programs). Say that Def 1.5's "computable $l\le u$" ranges over it. Fix an encoding of answers into a finite $Y$, or say that the point-family results (the only ones used) do not need $Y$.

**m4. Lemma 3.6's fine-regime bound tightens from $2\log e$ to $\log e$, which moves the 24° constant to about 66°.**
* **Proof.** In the case $a,b<1$ (with $a+b=L/\Delta\ge1$), $y/\Delta=1$ on $[1-b,a]$, so
  $$\Ex[-\ln(y/\Delta)]=f(a)+f(b),\qquad f(x)=\int_x^1-\ln s\,ds=1-x+x\ln x .$$
  $f$ is decreasing, so the maximum is on $a+b=1$, where $f(a)+f(1-a)=1+a\ln a+(1-a)\ln(1-a)\le1$ nat. The case $a<1\le b$ is the record's own bound. So the excess over $\log(2\varepsilon^*/\Delta)$ is at most $\log e$, attained as $w\to0$.
* **Numerical check.** `ra1_checks.out` B gives a maximum excess of $1.4427=\log e$ over 16 values of $L/\Delta$ and 401 values of $w$.
* **Consequences.**
  * Prop 3.7's condition becomes $\varepsilon^*<\mathsf R/(2e)$.
  * Prop 6.1(c)'s "about 24°" becomes about 66°, since $\mathsf R/(2e)=3973'$.
  * The record's statements stay true but are weaker than necessary.
  * The §6.1 reading should say that the 24° (or 66°) figure is a sufficient bound, not a threshold.

**m5. Prop 6.2(c) has a gap: monotonicity of $\gamma_{\rm si}$ in $\Delta$ under code R.**
* **Problem.**
  * The proof asserts that "$\gamma_{\rm si}$ [is] non-increasing in $\Delta$". For code Q this is clear. For code R it is unproved in the fine regime.
  * The hypothesis "$\gamma_{\rm si}\ge c_K$" must hold for every $\Delta$. In code Q, $\gamma=\log(\mathsf R/\Delta)\to0$ as $\Delta\to\mathsf R$.
* **Numerical support.** `ra1_checks.out` C supports the claim: $\gamma_{\rm si}$ is non-increasing for point masses $w=0.5,0.1,0.02$, for uniform $w$ and for arcsine $w$, over $\Delta/2\varepsilon^*\in[0.1,10]$.
* **Fix.** In the fine regime, $\gamma_{\rm si}(\Delta)=\Ex[-\log(y/L)]=\log(L/\Delta)+\Ex[-\log(y/\Delta)]$. A proof or a reference for its monotonicity is needed, or mark (c) for code R as computed. Restrict $\Delta$ to the range where $\gamma_{\rm si}\ge c_K$.

**m6. Prop 1.10(ii) calls $P_T$ "a shared hypothesis (a weak function semimeasure, P2 `def:setup:shared`)".**
* **Problem.** P2's definition requires lower semicomputability, which the same paragraph shows fails. The non-lsc proof also says consistency is undecidable "in any language with a binary relation symbol". That is false for a complete decidable $B$ such as $\mathrm{RCF}$, whose language has $<$, also after adding constants.
* **Fix.** Say "satisfies the semimeasure inequalities of `def:setup:shared` but not its lsc requirement, so $\mathcal H^Q$ is not a hypothesis class of P2". For the proof, take $B=\emptyset$ and a language with a binary relation symbol (Church). Also "`cor:kink:split` holds as stated" should read "holds with offset $b+\kappa+n$".

**m7. Prop 1.11(b): the decidable-case semimeasure fails for inconsistent $T$, and "for every finite $T$" clashes with "e.g. on pointwise interval laws".**
* **Problem.**
  * For inconsistent $T$, $w_T(a\mid\mathcal Q)=1$ for every $a$, so it sums to $|\mathcal Q|$.
  * Pointwise interval laws are infinite theories given by presentations, not finite theories.
* **Fix.** Use "1 for the first answer in a fixed order that $T$ proves", and drop "finite" in (b), using $K(T)\le|T|+c$ for presentations.

**m8. Prop 1.9(c) and §0: "No such restriction is within an additive constant of $L_A$".**
* **Problem.**
  * The proof covers $K_A$ and $J^Q_1$ over finite theories, and hence $J^F_1$, since $\ell(a)\ge1=\gamma$ there. It does not cover $J^R_1$ over pointwise interval laws. That case is easy, because those laws cannot express correlations between times: data in which pairs of times share a cell give $L_A\approx n\gamma/2$ against $J^R_1\gtrsim n\gamma$. But it is not written.
  * "No restricted class matches it" (§0) is false for a class containing $G_U$.
* **Fix.** Write "none of the three restrictions of (b)", and add the two-line $J^R$ example or drop $J^R$ from the claim.

**m9. Prop 4.2 states an iff that needs more hypotheses.**
* **Problem.** "Iff $r\le r^*(\delta)$" needs linear $F$ in $d=1$ for the "only if" (tightness, Prop 4.1(b)). Also $r^*$ is defined in 4.1(c) with $e_0=0$, while 4.2 allows $e_0>0$. And "a true datum at precision below the actual deviation" must be centred so that the interval excludes $F^r(a)$.
* **Fix.** Add these hypotheses, or state the "if" direction for general Lipschitz $F$.

**m10. Prop 5.7's constant depends on $\mathcal L'$.**
* **Problem.** $c$ depends on $\mathcal L'$ and its syntax code (the decoder must parse $T$). If $\mathcal L'$ or its code is chosen after the data, $c$ is not a machine constant. The honest form is $K(y_D\mid\dom D)-K(\text{code of }\mathcal L')-c$.
* **Fix.** Say "for $\mathcal L'$ and its code fixed independently of $D$". This is exactly the point of the trivialisation worry.

**m11. Copernicus–Ptolemy (§5.3): two comparisons are mixed.**
* **Problem.** "In the best system for $\lambda<\sum_pa_p/H$" holds only if $H<\sum_pa_p$. Otherwise Ptolemy with stated coincidences beats Copernicus at every $\lambda$, and for $\lambda<1$ it beats free-phase Ptolemy, so Copernicus is never best. "EP $=\sum a_p/H$ against the stated coincidences, with no change in fit" mixes the comparison with free-phase Ptolemy (fit changes by $\sum a_p$) and the comparison with stated coincidences (fit equal; law bits $H$ against $\sum a_p$).
* **Fix.** Separate the two comparisons and add $H<\sum_pa_p$.

**m12. Prop 3.4's Q/rand remark says the threshold "even then … stays near $1$".**
* **Problem.** The threshold $\tfrac12+H_2(p)/(2p\gamma)$ grows like $\log(e/p)/(2\gamma)$. At $\gamma=\log_2360$ it is $1.17$ at $p=10^{-3}$, $1.76$ at $10^{-6}$ and $2.93$ at $10^{-12}$ (`ra1_checks.out` D).
* **Fix.** Say "grows only logarithmically in $1/p$".

**m13. Prop 3.10(b) omits two cases.**
* **Problem.** It assumes a unique least rate (ties oscillate, Thm 3.8(ii)). The dichotomy "humble (H) or overconfident (P)" also omits the empty law $0$, which is humble.
* **Fix.** Add both.

**m14. Cor 3.9(b) needs $h_N>h$.**
* **Problem.** Otherwise N beats H from $n=0$, and the Wald interval is meaningless. "The typical sequence of λ-MAPs is $0\to E\to P\to H\to N$" in (d) is informal inside a corollary marked proved.
* **Fix.** Add $h_N>h$, and either state (d) as "the predicted order of the expected switch points" or move "typical" to the computed remark.

**m15. Prop 5.3(a) is stated for one theory but used for every λ-MAP.**
* **Problem.** "No λ-MAP with $\lambda>1$ contains it" needs the hypothesis "adding $a$ changes only $d$" *relative to the MAP minus $a$*. In combination with other axioms an answer stated as an axiom may prove more.
* **Fix.** State the hypothesis for the λ-MAP context.

**m16. Def 5.2: an edge slope is a module's EP only when the vertex theories are nested.**
* **Problem.** "On a hull edge the edge slope is the explanatory power of the bits added along it" holds only when the longer vertex theory is the shorter one plus a module. Hull vertices are arbitrary theories.
* **Fix.** Add "when the vertex theories are nested".

**m17. The §1.3 reading overstates what SAI charges.**
* **Problem.** The Reading of Prop 1.8 says "they are what SAI's one-tape law actually charges for exceptions", and §3.6 and §9.1 speak of "the pricing SAI uses".
  * Prop 1.8 is an upper bound, and it concerns data the law is *silent* on.
  * For data the law *refutes*, randomised withdrawal still pays the positional entropy $H_2(p)$ per datum (Def 3.1, Q/rand). So "the cost of saying which question was exceptional disappears" holds only for silence.
  * The precise content of "SAI's pricing" is the relative weight of two named theory machines in $M_A$'s mixture, $2^{-(K(G)-\log\nu_G(D))}$ (Prop 1.9(a)). That is what §3.6 compares.
* **Fix.** Rephrase in these terms.

**m18. §9.1 overstates two results.**
* **Problem.**
  * "Lewis's account has an exact form as a steeper MAP over laws with private literal facts, and only there (Prop 1.9(d))": Prop 1.9(d) shows only that the class of all theory machines collapses. It does not show that no other class works.
  * "Wins at every precision (§3.6)" means against the empty law and the exact law with exceptions, with Newton not in the pool.
* **Fix.** Drop "and only there". Add the scope of "wins".

**m19. The Reading of Cor 2.2 says the inducer "never prefers" weakenings.**
* **Problem.** A shorter weakening that is still compatible is preferred. What is proved is that data never move the odds towards the weaker theory.
* **Fix.** Say that.

**m20. The Myrvold parenthetical is unnecessary.**
* **Problem.** "$U$ above has that form (an identity once $P_\emptyset$ is a product)" suggests a needed hypothesis. In fact $U(D_1,D_2;h)=I(D_1;D_2\mid h)-I(D_1;D_2\mid b)$ holds for any $P_\emptyset$, with $I(D_1;D_2\mid x):=\log\frac{P_x(D_1\cup D_2)}{P_x(D_1)P_x(D_2)}$. This is algebra; `ra1_checks.out` G checks it to $3\times10^{-15}$ on 1000 random laws. A product $P_\emptyset$ only makes the second term zero.
* **Fix.** Say so. Myrvold's exact notation remains unverified: I also could not fetch the full text (proxy 403); search summaries agree with the "informational relevance" reading.

**m21. Literature: two references are missing.**
* **Prop 3.5's tolerance quantile is known in form.**
  * Minimising $\theta\varepsilon+\Ex(|e|-\varepsilon)^+$ over $\varepsilon$ has exactly the $(1-\theta)$-quantiles of $|e|$ as minimisers. This is the standard quantile-loss fact.
  * The same objective, with its "fraction outside the tube" characterisation, is ν-support-vector regression (Schölkopf, Smola, Williamson and Bartlett, "New Support Vector Algorithms", *Neural Computation* 12(5):1207–1245, 2000). There ν upper-bounds the fraction of points outside the ε-tube and lower-bounds the fraction of support vectors. Bibliographic data verified by WebSearch (MIT Press/MPI pages); the ν-property was seen only in secondary sources (scikit-learn's NuSVR documentation; arXiv 2403.01769 for the classification form). The paper's full text could not be fetched.
  * Scout L does not mention this. Prop 3.5's novelty should be limited to its reading for axiom inducers.
* **The ILP precedent is missing.** §9.2 should cite srinivasan1994justification, which scout L lists under seed 5 ("ILP theory plus exceptions by compression", content not seen), as the nearest precedent for law-plus-exceptions coding.

---

## What was checked and found correct

Each item below was checked line by line. Statuses are as the record gives them, except where an issue above applies.

* **§1.**
  * Def 1.1: the equivalence "proves iff $A_T(\mathcal Q)=\{a\}$".
  * Def 1.2: the prefix code, Kraft, $K(T)\le|T|+c$.
  * Prop 1.4: the code length $|T|+\mathrm{Exc}^F$, and the citation of `fundamentals` Thm 5.1 and Prop 5.2(b).
  * Lemma 1.6.
  * Prop 1.8(a). The theory machine $G_T$ is c.e.; the random theory is always consistent; data whose value lies in the open cell are proved; the probability is exactly $P^R_T$ up to null sets, so $\nu_{G_T}=P^R_T$. Dominance holds by `fundamentals` Thm 4.1, whose mixture identity has the extra non-negative term $(1-\Omega_V)\ind[B\vdash\psi_D]$, which is harmless here.
  * Prop 1.8(b),(c).
  * Prop 1.9(a),(b),(d). For (d), P2's `prop:kink:universal`(ii) holds with $\kappa_0=0$, which is better than the stated $c$.
  * Prop 1.9(c), the $J^Q$ example: the theorem on constants is used correctly, and `fundamentals` Prop 1.8(d) gives $K_A(D_n)\le c$.
  * The semimeasure inequality of Prop 1.10(ii).
  * Prop 1.11(a): flags, uniform lower semicomputability, the conditional coding theorem, and the easy chain rule.
  * The hypotheses of P2's hull lemma, `cor:kink:locate`, `thm:kink:converse` and `prop:kink:universal` are point-family hypotheses, and they hold in both classes.
* **§2.**
  * Prop 2.1, Cor 2.2, Prop 2.3.
  * Prop 2.4(a)–(c), including the essential-supremum and support argument.
  * Prop 2.5, which is valid also with repeated times.
  * Prop 2.6.
  * The seed correction, and the number 94 ($=60\pi/2$).
* **§3.**
  * Lemma 3.2: both cases of the "proves" event, and the refutation probability.
  * Lemma 3.6: the coarse formula $\log e-H_2(w)$, and the conditional uniformity of the boundary given a straddle.
  * Prop 3.3 and Prop 3.4: the identity $q\gamma_{\rm si}<p\gamma_{\rm ex}\iff\mathrm{pk}<\gamma_{\rm ex}/2\gamma_{\rm si}$.
  * Prop 3.5: convexity, the one-sided derivatives, the quantile condition and the boundary cases.
  * Prop 3.7's inequality chain.
  * Thm 3.8(i)–(iii): Hewitt–Savage on an exchangeable event, Wald with overshoot at most $b$, the pathwise limits (up to the $\tau=N$ edge case, which is harmless as $L\to\infty$).
  * Cor 3.9's numbers: $m_P=0.3235$, $m_H=0.283$ and the Wald intervals $[495,1250]$ and $[6995,7025]$ recomputed by hand.
  * Prop 3.10(a),(c).
* **§4.**
  * Prop 4.1(a)–(c): the recurrence and solution, the zonotope half-width $e_0\|(A^r)_{i\cdot}\|_1+\varepsilon\sum_{s<r}\|(A^s)_{i\cdot}\|_1$, and $r^*$ in all three regimes of $L$.
  * Prop 4.3(a),(d), Helly in dimension 1 and for boxes, and the disc counterexample (circumradius $2/\sqrt3>1.1$).
  * Remark 4.4: $100\binom{100}{50}2^{-100}=7.96$, $25.2$ at $r=1000$; for $L=1.1$, $1.38\times10^5$ against about $2.4\times10^4$.
* **§5.**
  * Prop 5.1, Def 5.2, Prop 5.3(b): the algebra of the length bound.
  * Prop 5.5 and the refutation of scout N2's Prop 4.5 criterion. N2's statement, "$s\cdot|S(\lambda)|>\lambda L_3$", is quoted correctly. The counterexample is recomputed: $2250<2400$, $s|S|=225<300$.
  * Prop 5.6, against `lem:setup:hull`(v) and `cor:kink:locate`(c) in both directions.
  * Prop 5.8(a)–(c): all three values of $U$ recomputed.
  * Prop 5.9.
* **§6.** Prop 6.1(a), Prop 6.2(a), and the closed form for $\Delta^*$.
* **§7.**
  * Prop 7.1(a): the recurrence and $\delta_t\le((1+\eta\|P\|)^t-1)|a|$.
  * Prop 7.1(b): the rigidity of rationals in ordered fields, and the completeness of $\mathrm{RCF}$.
  * Prop 7.1(c).
  * Prop 7.1(d), within the family $H^\varepsilon$.
* **Citations.** Every key cited `[known: …]` is in `refs.bib`.

## Novelty claims against scout L

* **§9.2, precision.** "Precision-dependent selection is known in other forms (Forster–Sober, MDL, MML); new is the 0/1 proof-requiring compatibility and its two regimes" agrees with scout L §5.1 seed 3 ("New in the axiom setting; must cite Forster–Sober and MDL/MML") and its verdict on scout P's Prop 2.3.
* **The peakedness criterion and tolerance quantile.** These are "not found" in scout L. That is consistent, but see m21: the quantile result is known in form from ν-SVR and quantile loss.
* **EP.** EP as compression at rate λ, citing Myrvold and ILP compression, agrees with scout L seed 9 ("New in form; must cite Myrvold and ILP compression").
* **The kink reading of best systems, and laws against initial conditions.** These agree with scout L seed 5 ("New in form"). Srinivasan et al. 1994 should be added (m21).
* **The SAI-side claims (Props 1.8, 1.9).** These are presented as consequences of `fundamentals` results, which scout L §5.3 rates "new for theory machines". The record makes no separate novelty claim for them.

## Verification log

1. **Reading.**
   * Read in full: the project brief, the thread brief, `NOTATION-draft.md`, and `notes.md` (all 653 lines, at its 02:47 state; re-checked unchanged at 03:18).
   * The `fundamentals` record, §1.1–1.5 (Defs 1.1–1.7, Prop 1.8), Thm 4.1, Thm 5.1, Prop 5.2, Prop 5.6, Prop 6.1 and Thm 6.2.
   * P2's `setup.tex` lines 16–100, `kinks.tex` lines 12–90, `app-setup.tex` (`lem:setup:basic`, the start of the hull-lemma proof), the `app-kinks.tex` proof of `cor:kink:locate`(c), and `absorb.tex` `cor:absorb:nouniversal`.
   * Scout N2's Prop 4.5 statement (lines 554–559).
   * Scout L's §5 (all three tables) and the grep hits for the relevant keys.
   * `l3_phases.py` (docstring and event function) and `l5_kepler_select.py` (docstring, pk computation).
2. **Restart check.** No earlier version of this report existed. A skeleton was saved first and the draft issues after §§1–7; this is the final version.
3. **Independent code.** `referee_code/ra1_checks.py` was written from the record's statements, not from the thread's scripts. It is seeded (20261016), and its output `ra1_checks.out` is saved next to it. It was run once, with `python3 -I` (Python 3.11.15, numpy 2.4.6), in 41.8 s. Parts:
   * A: m1;
   * B: m4;
   * C: m5;
   * D: m12;
   * E: M1;
   * F: M2, exact rational arithmetic;
   * G: m20;
   * H: the constant $\mathsf R/2e^2=24.36°$.

   I did not re-run the thread's scripts. The thread's log reports determinism re-runs. Where I recomputed a number by hand (Cor 3.9's rates and Wald intervals, Remark 4.4, Prop 5.5's counterexample, the Q/rand value 1.04) it matched.
4. **Literature.**
   * WebSearch confirmed the bibliographic data of Schölkopf et al. 2000. Its ν-property was seen only in secondary sources (scikit-learn NuSVR documentation; arXiv 2403.01769).
   * The Myrvold 2003 search gave summaries consistent with the record. Its formula was not seen.
   * Fetches of the ν-SVR PDF (stat.purdue.edu) and of the Myrvold talk and the philsci-archive PDF failed (proxy 403).
5. **Own proofs in this report.**
   * The $o(n)$ bound on distinct values (M1): a finite set of mass at least $1-\epsilon$, plus the strong law.
   * The tightened fine-regime bound (m4): the case split, and $f(a)+f(1-a)=1-H_{\rm nat}(a)\le1$.
   * The common-content statement (M2): $\Cn(T_0)\cap\Cn(T_N)=\Cn(T_0\vee T_N)$ for finite theories, with the explicit model of part F.
6. **Not done.** I did not re-run `l4` (31 min) or `l5`. I did not check the `philosophy` sections that this record cites. I did not obtain the full texts of Lewis 1994, Myrvold 2003 or Schölkopf et al. 2000.
