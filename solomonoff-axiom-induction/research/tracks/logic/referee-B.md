# Referee B (computation and counterexamples) for thread `logic`

*Referee record, 2026-10-16.*
* **Subject:** `research/tracks/logic/notes.md` (development round, 636 lines) and its scripts `checks/c0`–`c5`.
* **Independent code:** `referee_code/rb0`–`rb7`, each output saved next to its script.
* **Notation:** as in `../../NOTATION-draft.md` and the record's §1.
* **Name:** the family has the working name "Solomonoff axiom induction" (SAI); nothing below depends on the name.
* **Referee A:** I read referee A's report (`referee-A.md`) after my own pass over the proofs, and say where my results bear on its issues.

## Verdict

**Sound. No fatal issue. One new major issue (a convention-dependent headline reading), plus agreement with referee A's two majors and nine minor points.**

Every finite combinatorial ingredient that can be checked by computation was tested, with independent code, exhaustively where the case space allows. No counterexample was found to any claim marked [proved]:
* the lottery and its block consistency criterion;
* the true-lottery bookkeeping and the three-case unsoundness argument;
* the majority-vote thresholds;
* the threshold theories, the threshold machine $G^*$ simulated bit by bit, and the prefix sets $U_w$ of the unsound companion;
* the trichotomy's one-sided error pattern;
* the colouring constants;
* the $\Th(\mathbb N)$ syntax constants;
* the line counts of the Kreisel example.

The developer's six scripts reproduce byte for byte.

The computations also give three upgrades the record can use:
* **A rigorous exponent.** Thm 6.1's exponent for the record's own syntax is **proved** to be $\delta\ge0.08234$ by a super-solution certificate checked in exact arithmetic (issue 5). The record has $\approx0.082$ only as "computed, not proved".
* **Exact sentence counts.** These were missing from the proof sketch in §6.2 (issue 6).
* **A non-degenerate counterexample** to the Kreisel property, in which the instances are not logically valid (issue 7, answering referee A's m13(b)).

**The new major issue (issue 1).** Cor 3.6 is correct as stated, for $L_A=-\log M_A$. But its Reading says, without naming a convention, that SAI "pays $m\pm O(\log m)$ bits" for a datum that carries at most one bit. In the normalised convention this is false for most $x$ when $B\supseteq\PA$: the normalised loss is close to $0$, by a short counting argument (proved below). The $m$ bits measure the prior mass of theories that decide the sentence at all, and not a cost of predicting its truth value.

---

## 1. Re-runs of the developer's scripts

I copied `c1`–`c5` to a scratch directory and ran each with `python3 -I`. Every output is byte-identical to the saved `.out` file.

| script | time | bytes | sha256 (first 16) | identical |
|---|---|---|---|---|
| c1_lottery | 0.6 s | 1539 | 83e9a35fd139e681 | yes |
| c2_majority | 2.4 s | 1488 | f37cc02616b01911 | yes |
| c3_threshold | 4.7 s | 464 | 9cbdbac55521253a | yes |
| c4_trichotomy | 0.5 s | 478 | 1aabeea2b38e03b2 | yes |
| c5_syntax | 0.2 s | 635 | 1cf930e5614d6fdd | yes |

`c0_rerun_scout.py` locates scout N1's folder relative to its own path, so a copy of it fails with `FileNotFoundError`. Run in place, with its scratch argument in the session scratchpad, it reproduces its saved output byte for byte. That output records that scout N1's `c1_lottery` (4143 bytes) and `c3_threshold` (379 bytes) also reproduce.

**What the developer's code does and does not test** (details in issue 11):
* `c1` A1's survival enumeration uses a random $j^*$, so it tests only the product identity.
* The second check in `c1` A3 is a tautology of the definition $t:=\min R$.
* `c3` uses dyadic weights, which is the source of its 488 "boundary cases".
* `c3` T4 counts all multiples of $2^{-L}$ at every level, which is the reading under which Remark 3.4's sum double counts.
* `c5`'s growth rate is a numerical extrapolation.
* `c2`'s controls at $\varepsilon=\frac12$ find a violation in only 1 of 598 instances for $r=2$, so they have little power to show that the threshold matters.

None of this makes a claim wrong. My scripts replace each weak check with an exact or exhaustive one.

---

## 2. Independent computations

All scripts are in `referee_code/`, run with `python3 -I`. Each output is saved as `<script>.out`. Each script was run twice from scratch copies, and both runs were byte-identical to the saved output (Verification log). Seed 20261016 where randomness is used; exact rational arithmetic (`fractions.Fraction`) wherever a probability is compared.

| script | claims tested | method | result |
|---|---|---|---|
| `rb0_constants` | Thm 2.2(a) product; Cor 2.6′ fact count and bits; batch horizon; Prop 3.8 constant $\ell$; Cor 3.6 code range $P_m$; $\delta_{\rm str}$; Cor 6.2 binomial bound | exact / 30-digit | all hold. $\prod_k(1-2^{-(k+1)})=0.288788095086602421278899721929$. Fact count $=2^{K+1}+K-2$, which fits in $K+2$ bits, for $K\le60$. Prop 3.8: pigeonhole and $\ell>\log d-2$, 0 failures for $d\le10^6$ (the record's $\ell$ is the largest admissible one in all but 33 cases). $P_m=2^{m+1}-2$. $\delta_{\rm str}=0.052530$ |
| `rb1_lottery_models` | §2.6 instance (1): block consistency criterion and blockwise property (i); existence of $j^*_e$; Thm 2.2(a),(c),(d) and Cor 2.6′ in an exact mixture | **model search** over all structures with $\le5$ elements, $B=\emptyset$, two blocks ($N_0=1$, $N_1=3$; $2^{14}$ subsets); exact mixture with an **adversarial** list (each $\mathsf W_e$ refutes the reported ticket at every lottery but its own) | criterion = satisfiability on all 16384 subsets (2737 satisfiable); blockwise property holds on all; one listed theory dies per lottery, $M(D_n)\ge\frac14\prod$ throughout, and the coin-free weight left is carried by the prefix theories, falling only through the horizon term |
| `rb2_majority_tight` | Prop 2.3(a): is $\varepsilon=1/(r+1)$ the critical threshold? Prop 2.4's $\frac12+\frac12$ pairing | exact extremal family ($r=1..12$); LP (HiGHS) over **all** distributions for **all** 166 nonempty antichains on 4 sentences | no violation at $\varepsilon=1/(s_{\max}+1)$ (LP slack $0$); a violation just above, for every antichain. So $1/(r+1)$ is exactly critical for the argument |
| `rb3_true_lottery` | Thm 2.9(b) bookkeeping; Cor 2.10(iii)'s three cases; consistency of the random lottery theory | **exhaustive** propositional model (tickets $\le7$, every refutation set, every behaviour of $\mathsf W_k$, every winner $J$; truth tables over the false $\Sigma_1$ atoms) | $j^*$ exists, $j^*\ne t$, the data are true, and $\mathsf W_k$ fails (552/552). For every $J\ne t$ the premises entail exactly the record's false $\Sigma_1$ sentence ($\mathcal A_J$, or $\mathcal A_J\vee R_J$), 3136/3136. The output is satisfiable and every model makes a false $\Sigma_1$ atom true (3688/3688). $P(J=t\mid\text{survival})=1/N$ |
| `rb4_threshold` | Thm 3.1; Thm 3.2 ($G^*$ simulated bit by bit; $\nu_{G^*}\ge M$); Thm 4.4 ($U_w$, monotonicity, final segment, longest-prefix case analysis); Remark 3.4 | finite tape spaces with weights $k/3^7$, so that **$\Inc$ is non-dyadic**, as $\Inc_0$ is | 0 violations: 360332 $T_k$ checks; 400 simulated tapes; 300 $\nu$ grids; 24400 prefix checks. **0 boundary cases** $0.w=\Inc$, so the strict statement "$U_w$ consistent iff $0.w>\Inc$" holds as the record states it. Remark 3.4: see issue 4 |
| `rb5_trichotomy` | Prop 4.1(a)–(d) and the one-sided table; Prop 4.5(c) construction | propositional model in which $\Sigma_1$ sentences are **monotone** formulas over $\Sigma_1$ atoms and $\Q$ proves exactly the true atoms (stricter than `c4`'s world model); exact toy universal machines | (a)–(d): 0 violations in 1616 / 1607 / 592 / 577 applicable instances. The four impossible events (Dis on true $\Sigma_1$, Bel on false $\Pi_1$, Indep on true $\Sigma_1$, Indep on false $\Pi_1$) never occur; the four possible ones occur over 1000 times each. $V'$ is prefix-free and the ratio is $\ge2^j-1$ ($j\le10$) |
| `rb6_syntax` | Thm 6.1's constants; the missing step of the §6.2 sketch | formula counts by brute force ($L\le5$), explicit generation ($L\le9$) and recursion ($L\le400$); **exact sentence counts** ($L\le70$); **rigorous super-solution certificate** for the generating functions | all three counting methods agree, and agree with `c5`. Certificate at $\gamma'=5.385$: #formulas of length $\le L$ is $\le0.7482\cdot5.385^L$ for every $L$, so **$\delta\ge0.08234$ is proved**. Sentence data in issue 6 |
| `rb7_kreisel` | §5.5 Example; a non-degenerate variant | small Hilbert-proof checker, line by line; finite countermodels | 5 lines for $n\ge1$ and 3 for $n=0$ ($n\le60$), as stated; the countermodel works. Variant: issue 7 |

---

## 3. Issues

Severity: **fatal** (a main claim is false and cannot be repaired), **major** (a claim must change, or a status is wrong), **minor** (wording, side conditions, evidence).

### Issue 1 [major, new]: Cor 3.6's Reading holds only in the semimeasure and three-valued conventions

*Where.* §3.3, the Reading after Cor 3.6:
> "The datum $(\mathrm{Kgt}_m(x),1)$ carries at most one bit of label information … Yet SAI, and consistent SOI with it, pays $m\pm O(\log m)$ bits … That is the price of the consistency constraint at $\Pi_1$."

The table in §0.2 and the summary in §0.1 repeat it.

*What is true.* The statement of Cor 3.6 bounds $L_A=-\log M_A$. That is the semimeasure convention, and it is right. In the three-valued convention the cost of the label "1" is also $-\log\Bel_\emptyset(\mathrm{Kgt}_m(x))\approx m$, because the inducer predicts "independent" with probability $1-2^{-m+O(\log m)}$. The normalised convention ($\Bel/(\Bel+\Dis)$, NOTATION §7) behaves differently.

**Proposition [proved here].** Let $B$ be decidable and true with $\PA\subseteq\Cn(B)$. Then, for all $m$, $n$ and $j\ge0$, all strings $x\in\{0,1\}^n$ except at most $2^{2m+K(m)+j+c}+2^{m+1}$ of them satisfy:
* $K(x)>m$;
* the normalised loss of the datum $(\mathrm{Kgt}_m(x),1)$ is at most $\log_2(1+2^{-j})\le1.45\cdot2^{-j}$.

*Proof.* The proof has three steps.
1. **Few refutable strings per theory.** For any $N=2^{m+1}$ distinct numerals $\underline{x_1},\dots,\underline{x_N}$, $\PA\vdash\neg\bigwedge_{i\le N}\exists p\le\underline{P_m}\,\exists t\,\mathrm T(p,t,\underline{x_i})$. The reasons:
   * $\PA$ proves that a program has at most one output (uniqueness of computations for the Kleene predicate);
   * $\Q$ proves $p\le\underline{P_m}\to\bigvee_{q\le P_m}p=\underline q$ and $\underline{x_i}\ne\underline{x_j}$;
   * a finite pigeonhole case split finishes the argument.

   So every consistent extension of $B$ refutes $\mathrm{Kgt}_m(x)$ for at most $2^{m+1}-1$ strings $x$. Integrating over tapes gives $\sum_x\Bel_0(\neg\mathrm{Kgt}_m(x))\le2^{m+1}$.
2. **A lower bound on belief.** For $K(x)>m$, Cor 3.6(b) and (Chain) give $\Bel_0(\mathrm{Kgt}_m(x))\ge2^{-m-K(m)-c}$.
3. **Markov's inequality.** At most $2^{2m+K(m)+j+c+1}$ strings have $\Bel_0(\neg\mathrm{Kgt}_m(x))>2^{-j}\cdot2^{-m-K(m)-c}$. At most $2^{m+1}$ strings have $K(x)\le m$. For every other $x$, $\Dis/\Bel\le2^{-j}$, both normalised by the same $M_A(\emptyset)$. ∎

So for $n\ge2m+K(m)+j+c'$, almost every $x$ of length $n$ costs essentially nothing in the normalised convention. Consistent SOI behaves the same way. With $B=\Q$ alone the first step needs $\Q$ to prove uniqueness of outputs, which it may not; the normalised behaviour is then open.

*Why it matters.* The Reading is likely to become a headline ("Chaitin's theorem for random theories"). Unqualified, it attributes to the inducer's *prediction of truth values* a cost that is really the prior mass on theories that decide the sentence at all. NOTATION §7 already requires every lower bound to name its convention.

*Fix.* In the Reading, §0.1 and §0.2, write:
> "in the semimeasure convention (and in the three-valued convention, where the inducer predicts 'independent' with probability $1-2^{-m+O(\log m)}$) SAI pays $m\pm O(\log m)$ bits for one true datum $\mathrm{Kgt}_m(x)$; in the normalised convention, with $B\supseteq\PA$, the cost is near $0$ for all but a $2^{2m+K(m)+O(1)-n}$ fraction of the $x$ of length $n$, because few consistent theories refute $\mathrm{Kgt}_m(x)$. The $m$ bits are the price of *deciding* the sentence, not of predicting its truth value."

Optionally add the proposition above as a remark, with status [proved]. Also add "semimeasure convention" to the statement of Thm 6.1. The normalised predictor's conditionals are ratios of left-c.e. reals and are not lower semicomputable, so the coding-theorem argument behind `fundamentals` Prop 8.6(b) does not transfer to them.

### Issue 2 [major; agrees with referee A's M1]: Prop 4.5 needs $B$ true

I checked referee A's counterexample independently:
* $B=\PA+\neg\Con(\PA)$ is consistent by G2;
* $\PA\vdash\Con(B)\to\Con(\PA)$, so $B\vdash\neg\Con(B)$;
* with $T=\emptyset$ (true) and $\gamma=\Con(B\cup T)$, every compatible theory refutes $\gamma$, so (a) and (c) fail.

`rb5` Part B confirms the arithmetic of (c) once the hypothesis holds. *Fix:* as referee A says, add "$B$ true" (or "$B\cup T$ true").

### Issue 3 [major; agrees with referee A's M2]: §5.4(c) misquotes AI-paper Thm 3.9

I read `../axiom-induction/paper/sections/universal.tex`, lines 102–113:
* (c1) gives $\ind[T^*\vdash_{\mathsf C}\forall x\varphi]$, not the truth value;
* (d1) gives $0$ under $\Lone$, or the prior share under $\Lsel$, for filtered data;
* only `prop:univ:noguard`(c), a proof sketch, gives $\to1$.

*Fix:* referee A's wording.

### Issue 4 [minor; computed evidence for referee A's m6]: Remark 3.4's double count is a gap in one step, not in the conclusion

`rb4` R4 uses 599 intervals of length $\ge2^{-k}$, $k\le8$: random, aligned $(m2^{-k},(m+1)2^{-k})$, and half-shifted. It uses stand-in weights $g(L)=2^{-L-K'(L)}$ with $K'(L)=2\lceil\log_2(L+1)\rceil+1$, and compares indexing by the pair $(j,L)$ ("rep") with indexing by the rational ("dist"). The results:

| reading | check | result |
|---|---|---|
| "dyadic rationals of level $L$" = all multiples of $2^{-L}$ | per-level count holds | 0 failures |
| same, with one index per rational | the summation step ($S_{\rm dist}\ge S_{\rm rep}$) | fails on **284/599** intervals; ratio as low as **0.56** |
| "level $L$" = exact level (odd numerator) | per-level count $\ge2^{L-k-1}$ holds | fails on **28** intervals (half-shifted, at $L=k+1$) |
| index by the pair $(j,L)$ (referee A's fix 1) | displayed bound | 0 failures |
| odd numerators from level $k+2$ (referee A's fix 2) | displayed bound | 0 failures |
| one index per rational | the **displayed final bound** | **0 failures**; minimum ratio **exactly 1.0**, on aligned intervals |

So both readings of the proof have a gap in one step, while the conclusion holds (lower-level rationals carry more weight). *Fix:* referee A's fix 1 (index $Z$ by the pair $(j,L)$) is one line and keeps the stated constant.

### Issue 5 [minor; upgrade]: the exponent $\delta_{\rm wff}$ can be proved

§6.1 gives $\delta\ge0.0525$ rigorously and $\delta\approx0.082$ "computed, not proved". Write $V=x/(1-x)$. The generating functions of the record's syntax satisfy
$$T=x+V+xT+2xT^2,\qquad F=2xT^2+xF+3xF^2+2xVF.$$
A rational super-solution $(x_0,T^*,F^*)$, meaning both equations hold with "$\ge$", bounds the least fixed point by monotone iteration. Then
$$\#\{\text{formulas of length}\le L\}\le\frac{F^*}{1-x_0}\,x_0^{-L}\quad\text{for every }L.$$
`rb6` S3 verifies such a certificate in exact arithmetic at $\gamma'=1/x_0=5.385$ ($T^*\approx0.800042$, $F^*\approx0.609287$, $C=0.7482$). It also cross-checks the bound against the exact counts up to $L=400$.

Hence **$\delta\ge1/(5\log_25.385)=0.08234$ is proved** for the record's 14-symbol syntax with $c_1=5$. The threshold found by bisection is $\gamma\approx5.38295$, consistent with `c5`'s extrapolation $5.3826$. *Fix:* replace "$\delta\approx0.082$ (computed, not proved)" by "$\delta\ge0.0823$ [proved; computer-checked certificate, `rb6` S3]", or keep $0.0525$ in the theorem and add this as a remark.

### Issue 6 [minor; evidence]: sentence counts for the sketch in §6.2

The sketch's missing step is a bound $s(L-5)\ge\rho'\,s(L)$ on the number $s(L)$ of *sentences* (closed formulas), which the record did not count. `rb6` S2 computes $s(L)$ exactly for $L\le70$ by a recursion on (length, set of variables allowed free). The recursion was cross-checked against brute force ($L\le5$) and explicit generation ($L\le9$).

| $L$ | $F(L)$ | $s(L)$ | $s/F$ | $s(L)/s(L-1)$ | $s(L-5)/s(L)$ |
|---|---|---|---|---|---|
| 20 | $3.11\times10^{12}$ | $1.75\times10^{11}$ | 0.056 | 4.80 | $4.17\times10^{-4}$ |
| 40 | $5.16\times10^{26}$ | $1.27\times10^{25}$ | 0.025 | 5.01 | $3.22\times10^{-4}$ |
| 70 | $1.91\times10^{48}$ | $1.81\times10^{46}$ | 0.0094 | 5.12 | $2.86\times10^{-4}$ |

Three observations:
* Closed formulas are a shrinking fraction of all formulas.
* Their growth ratio rises slowly towards the formula ratio.
* $s(L-5)/s(L)\ge2.86\cdot10^{-4}$ on $20\le L\le70$, decreasing towards $\gamma^{-5}\approx2.2\cdot10^{-4}$.

This supports the missing step numerically, for $L\le70$ only. The status stays "proof sketch". The improvement it would give is a factor $1-\rho$ with $\rho\approx2\cdot10^{-4}$, so the paper can drop the sketch without loss. *Fix:* cite these numbers if the sketch is kept, and say that "sentences" (closed formulas) are what is counted.

### Issue 7 [minor; answers referee A's m13(b)]: a non-degenerate counterexample to the Kreisel property

Referee A observed that in §5.5's Example every instance is logically valid, so the data are old evidence. `rb7` Part 2 checks a variant with **non-valid** instances. The setting:
* $B=\emptyset$;
* $R$ a fresh unary predicate;
* data $R(S^n0)$;
* $\varphi(x):=x=0\vee\exists y\,x=Sy$.

Two hypotheses stay compatible:
* $\psi_1:=\forall x(\varphi(x)\to R(x))$ derives every $R(S^n0)$ in **9 lines** (7 for $n=0$). The derivations are checked line by line for $n\le60$. The structure $\{0,1,2,a\}$, with $S(0)=1$, $S(1)=2$, $S(2)=2$, $S(a)=0$ and $R=\{0,1,2\}$, satisfies $\psi_1$ and every datum but not $\forall xR(x)$.
* $\psi_2:=\forall xR(x)$ derives each datum in 3 lines.

So with $\ell=9$, the hypothesis $\psi_1$, which does not prove $\forall x R(x)$, is compatible with every finite part of the data, and the limit belief in $\forall xR(x)$ lies strictly between 0 and 1 under any full-support prior. *Fix:* add this example after the record's one, with status [proved; computed: rb7].

### Issue 8 [minor; optional]: the constant $1/(r+1)$ in Prop 2.3(a) is sharp

`rb2` shows that the majority argument at $\varepsilon$ is sound iff $\varepsilon\le1/(s_{\max}+1)$, where $s_{\max}$ is the largest minimal inconsistent set. The proof is the extremal family:
* inconsistent mass $a$ with $1-r\varepsilon<a<\varepsilon$;
* mass $(1-a)/r$ on each of the $r$ types "edge minus $\varphi_i$".

The LP over all distributions and all antichains on 4 sentences agrees. This explains why the lottery, with unbounded $s_{\max}$, defeats every threshold. *Fix (optional):* one sentence after the proof. In `c2`, replace the random controls, which find 1 violation in 598 for $r=2$, by this family.

### Issue 9 [minor; new]: Cor 3.6(b) needs unique computation codes

$s_m$ is "the largest code of a halting computation of $V$ on a program of length $\le m$". It exists only if each halting program has finitely many $t$ with $\mathrm T(p,t,y)$, for example if computation codes are unique, as for Kleene's $T$. If $\mathrm T$ allowed padded codes, $\beta_m$ would be false. *Fix:* "with $\mathrm T$ chosen so that each halting computation has a unique code".

### Issue 10 [minor; new]: Thm 3.2's upper constant

(Dom) gives $M_A\ge2^{-K(\nu_{G^*})}\nu_{G^*}$ with $K(\nu_{G^*})\le K(G^*)+c$. So the displayed $\nu_{G^*}(D)\le2^{K(G^*)}M_A(D)$ should read $2^{K(G^*)+c}$. Harmless.

### Issue 11 [minor]: the developer's checks

The fixes:
* **c0.** Make it path-independent (take the scout folder as an argument), or document that it must be run in place.
* **c1.**
  * A1's survival enumeration draws $j^*$ at random, so it tests only $\prod(1-2^{-(k+1)})$. The diagonal is tested separately, against random lists.
  * A3's check "a theory that refutes no true ticket refutes no ticket" is a tautology of $t:=\min R$.
  * Neither is wrong. The record's §10 should describe them as bookkeeping, or cite `rb1` (an adversarial list, where each theory survives until its own lottery) and `rb3` (the exhaustive truth-table version).
* **c3.**
  * The dyadic weights make $\Inc$ dyadic, hence the 488 boundary cases and the weakened test "$\ge$". With non-dyadic weights (`rb4` R3) there are no boundary cases, and the record's strict statement is tested directly: 0 violations in 24400 prefix checks.
  * T4 tests only the per-level count under the "multiples" reading (issue 4).
* **c5.** Its $\gamma$ is an extrapolation. `rb6` S3 makes it a theorem (issue 5).

### Issue 12 [minor]: the block criterion is now checked, not only argued

§2.6 instance (1) states the consistency criterion for lottery blocks with a one-line model argument. `rb1` Part A confirms it, with $B=\emptyset$ and two blocks:
* it agrees with satisfiability in all structures of size $\le5$ on all 16384 subsets;
* the blockwise property (i) holds on all of them;
* Lot plus all refutations is unsatisfiable, and dropping any one refutation makes it satisfiable.

*Fix (optional):* add "[computed: rb1 A]" to instance (1).

---

## 4. Claims checked and found correct (computation side)

| item | outcome | evidence |
|---|---|---|
| Thm 2.2 (a)–(d) | correct | rb0 K1 (product); rb1 A (consistency of $G_{\rm lot}$ outputs, existence of $j^*$); rb1 B (exact mixture: survival bound, one listed theory dies per lottery, posterior of deterministic theories falls) |
| §2.3, Prop 2.3, Prop 2.4 | correct | rb2: $1/(r+1)$ critical; $\frac12+\frac12$ pairing sharp |
| Cor 2.6′, batch lottery | correct | rb0 K2 (fact count $2^{K+1}+K-2$, $K+2$ bits; horizons $\le(n+1)^2$, max ratio $0.25$) |
| Prop 2.7 | correct | rb1 A (criterion and (i)) |
| Thm 2.9(b), Cor 2.10(iii) | correct | rb3 (exhaustive, tickets $\le7$) |
| Thms 3.1, 3.2 | correct | rb4 R1, R2 (bit-by-bit simulation of $G^*$; $\nu_{G^*}\ge M$; $A_r$ consistent iff $r>\Inc$) |
| Remark 3.4 | conclusion correct, one step has a gap | rb4 R4 (issue 4) |
| Prop 3.8 constants | correct | rb0 K3 |
| Cor 3.6 | statement correct; Reading convention-dependent | rb0 K4; issue 1 |
| Prop 4.1 | correct | rb5 A (monotone $\Sigma_1$ model) |
| Thm 4.4 (dyadic/prefix structure) | correct | rb4 R3 (non-dyadic $\Inc$, strict, no boundary cases) |
| Prop 4.5(c) construction | correct (given issue 2's hypothesis) | rb5 B |
| §5.5 Example | correct (5/3 lines; countermodel) | rb7 Part 1 |
| Thm 6.1, Cor 6.2 constants | correct, and improvable | rb0 K5, K6; rb6 (issue 5) |

Not computable here and checked by hand only: Lemma 2.8 (the diagonal construction), the uses of G2, the dominance and limit theorems. On these I agree with referee A's line-by-line reading. No counterexample suggested itself beyond issues 1 and 2.

**Possible error in the author's view.** None raised. Nothing computed here bears on a philosophical claim of Hänni's.

---

## 5. Summary of requested changes

| # | severity | where | change |
|---|---|---|---|
| 1 | major | Cor 3.6 Reading, §0.1, §0.2, Thm 6.1 | name the convention: $m$ bits in the semimeasure and three-valued conventions; near 0 for most $x$ in the normalised convention when $B\supseteq\PA$ (proposition above) |
| 2 | major | Prop 4.5 | add "$B$ true" (referee A's M1) |
| 3 | major | §5.4(c), §5.1, §0.1 | correct the AI-paper Thm 3.9 citation (referee A's M2) |
| 4 | minor | Rem 3.4 | index by $(j,L)$ (referee A's fix 1); the conclusion was never in danger (rb4 R4) |
| 5 | minor | Thm 6.1 | $\delta\ge0.0823$ proved by certificate (rb6 S3) |
| 6 | minor | §6.2 sketch | cite exact sentence counts, or drop the sketch |
| 7 | minor | §5.5 | add the non-degenerate example ($\psi_1$, 9 lines) |
| 8 | minor | Prop 2.3 | optional sharpness remark; strengthen `c2`'s controls |
| 9 | minor | Cor 3.6(b) | unique computation codes for $\mathrm T$ |
| 10 | minor | Thm 3.2 | $2^{K(G^*)+c}$ |
| 11 | minor | §10 and checks | c0 path; c1 descriptions; c3 non-dyadic weights; c5 certificate |
| 12 | minor | §2.6 | cite rb1 A for the block criterion |

---

## Verification log

**Read in full:**
* `research/00-brief.md`;
* `tracks/logic/00-brief.md`;
* `NOTATION-draft.md`;
* `tracks/logic/notes.md` (all 636 lines; every proof in §2–§6 re-derived by hand before the code was written);
* `checks/c0`–`c5` (code and outputs);
* `referee-A.md`, read after my own pass.

**Read in part:** `../axiom-induction/paper/sections/universal.tex`, Thm `thm:univ:omega` (lines 100–113) and Prop `prop:univ:noguard` (lines 132–136), for issue 3.

**Re-runs of the developer's code:**
* `c1`–`c5` were copied to the scratchpad and run with `python3 -I`; all are byte-identical to the saved outputs (table in §1).
* `c0` was run in place with its scratch argument in the session scratchpad (a copy cannot find the scout folder); it is byte-identical too.

**Independent code** (`referee_code/`, outputs saved next to each script):

| script | bytes | sha256 (first 16) | time |
|---|---|---|---|
| rb0_constants | 1781 | 3b4796d363d10ac7 | 0.6 s |
| rb1_lottery_models | 2285 | ea2fc1fc84c24f48 | 1.5 s |
| rb2_majority_tight | 1695 | 897edb4ab9a3d6c7 | 2.0 s |
| rb3_true_lottery | 433 | 511adef5847e78ca | 125–147 s |
| rb4_threshold | 1227 | b72d79b8e7975a26 | 43–45 s |
| rb5_trichotomy | 774 | 56aa8b635f1d9b7a | 0.6 s |
| rb6_syntax | 2293 | 488879ab249b2546 | 8.5 s |
| rb7_kreisel | 930 | 669bd31a227a2f86 | 0.03 s |

How the code was run:
* Seed 20261016 where randomness is used (rb1 B, rb4, rb5); the other scripts are exhaustive or deterministic.
* Each script was run twice from scratch copies with `python3 -I`; both runs were byte-identical to the saved `.out`.
* Dependencies: Python 3.11.15, mpmath 1.3.0 (rb0), numpy and scipy 1.17.1 (rb2, HiGHS LP).

Changes made during the round:
* `rb3`'s docstring was corrected (it listed $N=15$, which the code does not run), and its output was regenerated.
* `rb4` was first too slow. Its union-of-emissions loops were replaced by the equivalent minimum-threshold computation, and its R4 part was extended to both readings and to aligned intervals.

**Proof checks for the new claims in this report:**
* Issue 1's proposition: pigeonhole in $\PA$ for standard sizes, plus (Chain), plus Markov's inequality. The proposition's own constants were checked by hand.
* Issue 5's certificate: the monotone-iteration argument is standard; the two inequalities were verified in exact arithmetic.
* Issue 7's example: checked by rb7's proof checker and countermodel.

**Not done:**
* No literature search. Referee A covered the literature; none of my issues depends on a reference.
* No proof assistant.
* The co-r.e. adversary (Prop 2.7) and the horizon bound (Prop 2.6) were not re-simulated beyond rb1. Their finite content is the criterion (rb1 A) and a measure inequality whose proof is two lines.

No git command that changes repository state was run (only `git status`, read-only). Files written:
* this file;
* `referee_code/rb0`–`rb7` (`.py` and `.out`).

Scratch copies are under the session scratchpad.
