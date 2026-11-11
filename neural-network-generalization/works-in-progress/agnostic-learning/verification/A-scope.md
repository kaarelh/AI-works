# Referee report on `../research-notes/A-tight-conditioning-fails.md` (revision 1): scope and adversarial interpretation

*Lens: does what A.r1 proves establish or refute the intended version of the conjecture in brief §1? Would the user who proposed the conjecture accept it, or object that it addresses a different learner, a degenerate distribution, a different loss, or the wrong order of limits? Can a stated result be falsified under a natural reading? Is it consistent with the repository's theorems?*

*This file replaces the round-0 scope report on `A-first-version.md`. That report is preserved as `A-first-version-scope.md`. A.r1's Appendix R cites its issue numbers S1–S10; §3 below gives their status.*

*Read in full: `../research-notes/problem-brief.md` and `../research-notes/A-tight-conditioning-fails.md` (1123 lines, Appendix R included). Read for cross-checks:*

* *`A-logic.md`, the round-1 logic report on A.r1;*
* *`../research-notes/B-tempered-likelihood.md` §§6–9;*
* *`../research-notes/E-finite-prior-scale.md` §0, §2.6 and §5;*
* *`../research-notes/red-team.md` §§4.3, 5, 6 and 7;*
* *`RT-width-logic.md` and `RT-width-computation.md` (verdicts and §§1–2);*
* *`RT-aggregate-logic.md` and `RT-tube-logic.md` (verdicts);*
* *the verdict lines of `verify-B-{logic,computation,scope}.md` and `verify-E-{logic,computation}.md`.*

*Repository sources opened and compared with A.r1's use of them (`NNG/` = the project folder `neural-network-generalization/` of this repository):*

* *`NNG/side-results/continuous-domains/source/paper.tex`:*
  * *§`model`: eq. `posterior` (l. 130), Theorem `strong` (l. 178–197), Theorem `finite` (l. 199–220), Remark `cube` (l. 225–232);*
  * *§`exact`: Proposition `exact` (l. 613–645), Corollary `exact` (l. 647–690).*
* *`NNG/works-in-progress/slt-likelihood/README.md`, all of it:*
  * *§2 strong-prior theorem (l. 46–60) and the $c\sigma^2$ remark (l. 96);*
  * *§2 finite-scale theorem (l. 102);*
  * *§3 "Raw priors" (l. 195–202).*
* *`NNG/works-in-progress/noisy-interpolation/README.md`: §1, the model and theorem (l. 37–76), and the open target (l. 556).*
* *`NNG/TECHNICAL-FAQ.md`, Questions 33–37; in particular Q33's scope paragraph (l. 1452) and Q34 (l. 1493).*
* *`NNG/README.md`: main result 1 (l. 33) and main result 4 (l. 53–55).*

*Scripts are in `../checks/verify-A-scope/`: `tube_symmetry.py` and `scope_numbers.py`, each with a `.out` file (§8).*

---

## 1. Verdict: `minor_fixes`

**Mathematics.** I found no false theorem, lemma or proposition. I found no contradiction with any repository theorem (§6). For this lens I re-derived:

* Propositions 5.1, 5.2, 6.6 (both parts) and 7.4;
* the energy floor of Remark 7.6;
* Lemma 6.2;
* the chain Lemma 4.1(b) → Lemma 4.2(b) → Theorem 4.4(i)–(iii).

These all hold as stated in the body. I agree with the logic report that the remaining proofs are correct.

**Round-0 scope issues.** All ten (S1–S10) are fixed in the body of the text, not only in Appendix R (§3). All four round-0 observations became results:

* R1 became Proposition 5.2;
* R2 became Proposition 7.4, in a strengthened form;
* R3 became Remark 7.6;
* R4 became Proposition 6.6.

**What A.r1 now says it refutes is what it proves.**

* (P$_L$) for SP$_c$ with $cK_{\rm mem}=o(n)$, at depth $L\ge3$ and learner widths $N\ge N_0$, uniformly over the input dimension ($d=\log_2n$), on near-atomic laws.
* (P$_L$) for TUBE$_\rho$ at every tolerance schedule, in the strong-prior limit when $\rho>1$.
* §0.1, §5.4 and §10 state correctly that the conjecture itself is not refuted, and point to ../research-notes/B-tempered-likelihood.md and ../research-notes/E-finite-prior-scale.md.

**What remains.** Nine issues (§4), all minor. None changes a theorem or the verdict on the conjecture.

* **N1.** The framing of TUBE as a "tightly conditioned" learner is wrong for $\rho>1$. Its failures are not noise interpolation. This is the most consequential remaining point for the user.
* **N2.** "The heuristic fails" needs a reading of "pretty close" and a width qualifier.
* **N3.** One summary sentence is literally false: §0.2 item 6, third bullet. I give an explicit instance.
* **N4–N5.** The $n^\alpha$ reading. One sentence states a refutation without naming the learner. ../research-notes/B-tempered-likelihood.md Corollary 8.1 is paraphrased without its ${\rm poly}(d)$ factor.
* **N6.** The strong-prior restriction in Proposition 6.6(a) is removable. Observation S-1 (§4) gives a short symmetry argument, checked numerically. It makes the TUBE negative hold for both repository priors at every scale and width, and for tolerances that may depend on $\sigma$.
* **N7–N9.** Citation status, one loose phrase, and optional additions.

### What is refuted, and what is not (A.r1 as it stands)

| statement | status in A.r1 | my check |
|---|---|---|
| (P$_L$) fails for SP$_c$ with $cK_{\rm mem}=o(n)$, including $c=1$; $L\ge3$; $N\ge N_0$; uniform over $d$ | proved (Proposition 5.1) | ✓ |
| The same with deterministic labels and atomless inputs (A′) | proved (Theorem 7.2). The law is near-atomic: density $2^{\Theta(d^2)}$ times uniform | ✓. The (P$_L$) corollary is not written out (logic Issue 15) |
| At fixed $d$ the cube family is consistent at every width | proved (Proposition 5.2) | ✓ |
| (P$_L$) fails for TUBE$_\rho$ at every schedule, at fixed $d$ | proved; the strong prior is needed for $\rho>1$ | ✓. The restriction is removable (N6) |
| The conjecture (some Bayesian learner has (P$_L$)) | not refuted; ../research-notes/B-tempered-likelihood.md and ../research-notes/E-finite-prior-scale.md give such learners | ✓. Citations checked in the sources |
| "Tight conditioning is what breaks the property" | asserted as the lesson | true for SP$_c$ in the stated regime; needs qualifiers (N2); does not describe TUBE (N1) |

---

## 2. The conjecture, the formalization, and what A.r1 covers

This updates the round-0 table to revision 1. A blank in the last column means A.r1 states the scope correctly.

| quantifier or choice | user's sentence | brief §1 / (P$_L$) | what A.r1's negatives use | remaining scope issue |
|---|---|---|---|---|
| learner | **exists** ("whichever version is best") | one fixed learner | SP$_c$ with $cK_{\rm mem}=o(n)$; TUBE$_\rho$ at every schedule | TUBE is not "tightly conditioned" for $\rho>1$ (N1) |
| input dimension | not mentioned | $\mathsf p$ polynomial in $d$, uniform over $d$ | SP$_c$: $d=\log_2n\to\infty$. TUBE: fixed $d$ | |
| input law | not mentioned | all laws on $X\times[-1,1]$ | cube atoms; A′ corner cubes of side $r\approx L^{L/2}n^{-1-L/2}$ | |
| learner width | not mentioned | every $N\ge m$ | SP$_c$: $N\ge N_0=O(n\log^2n/a^2)$. TUBE: every $N$ | "the heuristic fails" lacks the width qualifier (N2) |
| prior scale and limit | not mentioned | SP$_c$: $\sigma\to0$ at fixed $(N,n,S)$ | the same; TUBE with $\rho>1$ only as $\sigma\to0$ | the TUBE restriction is removable (N6) |
| predictor | not mentioned | Gibbs, posterior mean, progressive mixture | Gibbs, the three posterior means, near-minimizers | |
| loss | MSE | MSE against noisy labels | MSE, clipped and unclipped | |
| depth | "MLPs" | fixed $L$ | SP$_c$: $L\ge3$. TUBE: $L\ge2$ | |
| competitor | "width poly($n$) MLPs" | fixed $g$, $n\ge\mathsf p(d,m,B,\dots)$; or the $n^\alpha$ class | $g\equiv0$ (SP$_c$); width-one $g\equiv\eta_0$ (TUBE) | the $n^\alpha$ reading needs the learner named (N4) and the $d$-range stated (N5) |
| probability | "after seeing $n$ points" | probability at least $1-\delta$ | probability at least $1-e^{-2^{d/2}}$ | the in-expectation reading also fails, trivially (N9) |

---

## 3. Round-0 scope issues: status in A.r1

I checked each fix at its location in the body.

| round-0 issue | status | where in A.r1 |
|---|---|---|
| S1: the conjecture is existential in the learner | fixed | §0.1 (l. 11–16); §0.2 item 4 (l. 39); §5 title; §5.4 (l. 549–561); §10 (l. 1018) |
| S2: the refutation needs $d\to\infty$ | fixed | §0.1 "Input dimension"; Proposition 5.2, re-derived (§5.1 below); §5.3 items 1–2 |
| S3: A′ is near-atomic | fixed | §7 introduction (l. 711–713); Remark 7.3; Proposition 7.4; Remark 7.5; Table 7.1; §10 item 3 |
| S4: TUBE on continuous i.i.d. inputs | fixed | the sentence after Proposition 6.3 (l. 626); Remark 7.6 |
| S5: progressive mixture | fixed | §0.2 item 4; §5.1 |
| S6: order of $N_0$ | fixed | §0.2 item 3; §5.3 item 3. The range should end at $7.3\cdot10^6$, not $7\cdot10^6$ (logic Issue 13; `scope_numbers.out` item 1) |
| S7: finite scale; "the slt-likelihood theorem" | fixed | §5.3 item 5; Remark 4.9; §10 item 6 |
| S8: stale window | fixed | §8.3, last paragraph; §10 item 8 |
| S9: convention for an undefined posterior | fixed | §6.2, conventions (U1)/(U2); Table 6.1, row 1 |
| S10: Remark 4.9 wording | fixed | Remark 4.9 |

Proposition 7.4 is a genuine strengthening of round-0 Observation R2. It uses the transfer radius at variation $2$, which is the largest variation that matters for labels in $[-1,1]$. It also gives an all-$c$ exponent $(L/(2H))d^2$, derived from $K_2\ge K_{\rm mem}$. I re-derived both:

* $K_2/L\ge(8d\,2^d)^{1/H}\ge2^{d/H}$;
* $\frac d2\log_2(8\pi e)=3.047\,d$.

---

## 4. Issues

All issues are **minor**. None breaks a proof or changes what A.r1 says about the conjecture. They are ordered by how much they could mislead the user.

### N1. TUBE is not a "tightly conditioned" learner when $\rho>1$, and its failures are not noise interpolation

**Locations.**

* The title (l. 1): "Tightly conditioned Bayesian networks interpolate noise and fail agnostically".
* §0.1 (l. 13–14), which lists TUBE$_\rho$ "at every tolerance schedule" among "learners that condition tightly on each training output".
* §5.4 (l. 549): "Proposition 6.6 refutes it for TUBE$_\rho$ at every tolerance schedule. Both learners condition tightly on each training output."

**Problem.**

* **Tolerance above 1.** For $\rho>1$ and labels in $[-1,1]$, the tube $\{w:|z_w(x_i)-y_i|<\rho\ \forall i\}$ contains the sup-norm ball $\{w:\max_i|z_w(x_i)|<\rho-1\}$ around the zero network. That is loose conditioning. A tolerance of $\rho=10$ conditions on almost nothing, yet Proposition 6.6 covers it. The failure mechanism (Lemma 6.2) is collapse to the minimum-energy point of the feasible window. The learner ignores the data; it does not fit them.
* **Tolerance at most 1.** The mechanism is infeasibility (an empty tube, Lemma 6.4(a)), not interpolation.
* **The title.** It describes neither mechanism. Only Proposition 6.5 (without replacement, outside (P$_L$)) is an interpolation result.
* **What the TUBE results actually show** is a loss mismatch. On an atom that carries both labels $\pm1$, the constraint is $z(x)\in(1-\rho,\rho-1)$, which is empty when $\rho\le1$. This window is centred at the **midrange** $0$ of the observed labels, not at their mean $\eta_0$.
  * So TUBE in the strong-prior limit returns the minimum-energy function inside windows centred at label midranges.
  * Under asymmetric noise this is biased by a constant **at every tolerance**.
  * A per-point hard tolerance is a sup-norm criterion; MSE needs the conditional mean.
  * Observation S-1 (N6) makes this exact: once every atom carries both labels, the TUBE posterior mean is identically $0$ under every sign-symmetric prior, whatever $\rho>1$ and whatever the scale.

**Why it matters.** The sentence "Both learners condition tightly" and the title enlist TUBE as evidence for the message "tight conditioning breaks the property". The TUBE failure at $\rho>1$ involves no tight conditioning at all. A skeptical reader will notice this and discount the message. It is the correct message for SP$_c$, so it should rest on SP$_c$ alone.

**Fix.**

* In §0.1 and §5.4, separate the two learners:
  > SP$_c$ fails when it conditions tightly, because it memorizes noise. TUBE$_\rho$ fails at every tolerance, tight or loose. For $\rho\le1$ the tube is empty on repeated inputs with conflicting labels. For $\rho>1$ the posterior collapses to the minimum-energy point of windows centred at the label midranges. A per-point hard tolerance targets the midrange of the conditional label law, not its mean.
* Retitle, for example: "Tightly conditioned SP$_c$ memorizes noise, and TUBE fails at every tolerance: negative results for the agnostic bound."
* Optionally, complete the TUBE picture for the user with `../research-notes/red-team.md` Proposition 4.1. Its two referee reports both say "minor fixes". It shows that TUBE with tolerance just above the sup-norm residual $\rho_0$ of a small network satisfies $\mathbb E_\Pi L_D({\rm clip}\,z_w)\le(\tau+\rho_0)^2+\frac43\varepsilon$. That is a tempered bound for bounded noise, not an oracle inequality. On Proposition 6.6's law, $\rho_0=1+\eta_0$ and the bound is vacuous, so there is no conflict.

### N2. "The heuristic fails" needs three qualifiers

**Locations.**

* §0.1 (l. 16): "So what fails is the user's auxiliary heuristic … In the agnostic setting it works the other way."
* §5.4, "The heuristic" (l. 559).

**Problem.** The user's sentence is "the Bayesian learning should condition to be pretty close to the given outputs on train inputs". It has two natural readings, and A.r1's evidence speaks to one of them, in a restricted regime.

* **(a) Per output, closer than the noise level** (interpolation-like). Theorem 4.4 shows that this fails, but only under three conditions:
  * (i) at learner widths $N\ge N_0$, with $N_0/n\ge2\cdot10^5$ in the tabulated range;
  * (ii) on laws whose test inputs repeat training inputs at the learner's resolution (logic Issue 12 makes this point);
  * (iii) with $d\to\infty$.
* **(b) Training fit about as good as the best small network achieves.** This is "pretty close" relative to what is achievable. Under this reading the evidence supports the heuristic.
  * ../research-notes/B-tempered-likelihood.md's successful learner has near-minimizers with $\hat L_S(z_w)\le\hat L_S(g)+c(E_*+1)/n$ (../research-notes/B-tempered-likelihood.md Lemma 2.3(c) with $\zeta=1$, the first step of the proof of ../research-notes/B-tempered-likelihood.md Proposition 6.1). At $c=n^{1-\theta}$ the slack is $(E_*+1)n^{-\theta}\to0$.
  * The learner of `../research-notes/red-team.md` Remark 6.2 conditions on $\hat L_S(z_w)<\tau$ with $\tau\approx\mathrm{OPT}$. It is now refereed (`RT-aggregate-logic.md`: minor fixes, with $\tau\ge\mathrm{OPT}+\Theta(n^{-1/2})$). That referee also notes that $\tau$ can be set from the data. A.r1 (l. 555) still calls it "an unrefereed sketch"; that report postdates A.r1.
* **At small width even reading (a) may survive.** `../research-notes/red-team.md` Proposition 6.1, as repaired in `RT-width-logic.md`, gives success for SP$_1$ itself at learner width $\lceil n^\alpha\rceil$ with $\alpha<1/4$, for clipped predictions.

So what is shown to fail is narrower than the heuristic: per-output tight conditioning, at width $N\ge N_0$, on near-atomic data, uniformly in $d$. The sentence "In the agnostic setting it works the other way" generalizes from this.

**Fix.** Replace the heuristic sentences with:

> What fails is the heuristic in the reading "condition each training output to within less than the noise level", for learners of width at least $N_0$, on laws whose test inputs (nearly) repeat training inputs. In the reading "fit the training data about as well as the best small network does", the heuristic describes what the successful learners do (../research-notes/B-tempered-likelihood.md; `../research-notes/red-team.md` Remark 6.2).

### N3. One summary sentence is false as written

**Location.** §0.2 item 6, third bullet (l. 45):

> TUBE$_\rho$ with $\rho<1$, without replacement (Proposition 6.5): every posterior draw and the posterior mean have excess at least $\frac nM(b-\rho)^2$ at every $\sigma$, where $b$ is the noise amplitude.

**Falsifying instance.** Use Proposition 6.5's own label model, $y_i=\eta(x_i)+b\varepsilon_i$, with $\eta\equiv0$, $b=\frac12$, $\rho=0.9<1$, and any $n\le M$.

* Then $\max_i|y_i|=\frac12<\rho$, so Lemma 6.2 applies.
* As $\sigma\to0$, $\sup_x|\bar z_{\Pi^{\rm tube}}(x)|\to0$, and the excess of the posterior mean tends to $\mathbb E\,\eta^2=0$.
* The bullet asserts an excess of at least $\frac nM(b-\rho)^2=0.16\,\frac nM>0$ at every $\sigma$.

Table 6.1, row 4 (collapse whenever $|y|<\rho$) also contradicts the bullet. Proposition 6.5 itself is correct. It assumes $0<\rho<b$, and $N\ge N_0(d,n,\rho/2)$ for the tube to be nonempty. The logic report's Issue 3 notes the missing hypotheses; this instance shows that the bullet is false, not merely incomplete.

**Fix.** "TUBE$_\rho$ with $\rho<b$, without replacement, at widths $N\ge N_0(d,n,\rho/2)$: …"

### N4. §5.3 item 2 refutes a reading of the conjecture without naming the learner (a remnant of round-0 S1)

**Location.** l. 542: "That reading is refuted for every $\alpha>0$ provided the $o(1)$ term is uniform over the input dimensions $d\le\log_2n$ …"

**Problem.** "That reading" is the conjecture's $n^\alpha$ reading. A.r1 refutes it only for SP$_c$ with $cK_{\rm mem}=o(n)$, at widths $N\ge N_0$. ../research-notes/B-tempered-likelihood.md Corollary 8.1 proves it for tempered SP$_c$ when $\alpha<1/(4H)$. The $o(1)$ there vanishes along $n=2^d$, so it survives exactly the uniformity A.r1 imposes (N5). Read on its own, the sentence contradicts §0.1 and §5.4. The logic report's Issue 8 adds the width qualifier; this issue adds the learner.

**Fix.** "For SP$_c$ with $cK_{\rm mem}=o(n)$, at learner widths $N\ge N_0$, that reading fails for every $\alpha>0$, provided …"

### N5. ../research-notes/B-tempered-likelihood.md Corollary 8.1's error term is ${\rm poly}(d)\cdot n^{-\beta}$, not $O(n^{-\beta})$

**Location.** §5.4, first bullet (l. 553): "../research-notes/B-tempered-likelihood.md Corollary 8.1 gives the reading 'minimum over networks of width and weights at most $n^\alpha$, plus $O(n^{-\beta})$' for $\alpha<1/(4H)$."

**Problem.**

* ../research-notes/B-tempered-likelihood.md Corollary 8.1's term is $\Xi_nn^{-\beta}$, with $\Xi_n\ge d(d+1)$ and $\beta=(1-4\alpha H)/(H+2)$. I checked this in ../research-notes/B-tempered-likelihood.md §8.
* A.r1's own uniformity discussion (§5.3 item 2) takes as its example an $o(1)$ "that bounds the excess for all $d\le n^\alpha$".
* Under that uniformity, ../research-notes/B-tempered-likelihood.md's bound vanishes only if $d^2n^{-\beta}\to0$ at $d=n^\alpha$. That requires $2\alpha<\beta$, which is equivalent to
$$\alpha<\frac1{6H+4}\qquad(H\ge2),$$
  for example $\alpha<\frac1{16}$ at $H=2$, against Corollary 8.1's range $\alpha<\frac18$.
* `scope_numbers.out` item 2 shows this at $H=2$:
  * at $\alpha=\frac1{16}$ and $d=n^\alpha$, the term stays near $1$;
  * at $\alpha=0.1$ and $d=n^\alpha$, it diverges;
  * at $d=\log_2n$ it tends to $0$ for each of the three values of $\alpha$.

So the positive and negative statements meet on the range $d\le{\rm polylog}(n)$, where both hold:

* tight SP$_c$ fails there (Proposition 5.1, where $d=\log_2n$);
* tempered SP$_c$ succeeds there for all $\alpha<1/(4H)$.

They do not meet on $d\le n^\alpha$.

**Fix.**

* Write "plus $O_L\big((d^2+\sqrt{d\log n}+\sqrt{\log(1/\delta)})\,n^{-\beta}\big)$".
* In §5.3 item 2, use "$d\le{\rm polylog}(n)$" rather than "$d\le n^\alpha$" as the example of a uniform $o(1)$.

### N6. Proposition 6.6(a) does not need the strong-prior limit

**Locations.**

* Proposition 6.6(a) and its consequence (l. 669–672);
* §0.1 (l. 14) and §10 (l. 1018), both of which correctly add "in the strong-prior limit";
* §0.2 item 6, last bullet (l. 46), which omits it (logic Issue 2);
* §10 item 6 (l. 1040).

**Problem.** Part (a), the case $\rho>1$, is proved only for $\mu_\sigma$ as $\sigma\to0$. This leaves two cases open.

* **The finite scale.** The repository's prior $\mu_{N,\gamma}$ at fixed width is not covered. This is where the TUBE paper's Theorem `finite` lives (`paper.tex` l. 199–220).
* **Tolerances that depend on the scale.** Consider schedules $\rho=\rho(n,\sigma)$ with $\rho\downarrow1$ as $\sigma\to0$, such as $\rho=1+\sigma$. The inner set $\{\kappa_N<(\rho-1)^2\}$ used in part (a) then has prior mass bounded away from $1$, so the proof breaks.

A symmetry argument closes both gaps, with no limit at all.

**Observation S-1 (TUBE under a sign-symmetric prior).**

*Setting.*

* Let $L\ge2$, $N\ge1$, $d\ge1$, $\eta_0\in(0,1)$ and $\rho>1$.
* Let $\mu$ be a Borel probability measure on the width-$N$ parameter space that is invariant under the readout flip $T(W^1,\dots,W^H,v)=(W^1,\dots,W^H,-v)$, and that charges every nonempty open set. Both $\mu_\sigma$ (every $\sigma>0$) and $\mu_{N,\gamma}$ (every $N$, $\gamma$) qualify: the readout is a centred Gaussian vector independent of the hidden weights.
* Let $D=D^{\eta_0}_d$ and $g\equiv\eta_0$ as in Proposition 6.6.
* Let $S$ be a sample in which every $x\in\mathcal C_d$ occurs with both labels $+1$ and $-1$.

*Claims.*

* (a) $U_{\rho,S}=\{w:\max_{x\in\mathcal C_d}|z_w(x)|<\rho-1\}$. This set is open, contains $0$, and satisfies $TU=U$. So $\Pi^{\rm tube}$ is defined and $T$-invariant.
* (b) For every $x\in\mathcal C_d$, $\int z_w(x)\,\Pi^{\rm tube}(dw)=\int{\rm clip}(z_w(x))\,\Pi^{\rm tube}(dw)=0$. Hence each of $\bar z$, ${\rm clip}\circ\bar z$ and $\int{\rm clip}(z_w)\,d\Pi^{\rm tube}$ has $L_D=L_D(g)+\eta_0^2$.
* (c) For $0<\varepsilon<\eta_0^2$: $\Pi^{\rm tube}\{w:L_D(z_w)\le L_D(g)+\varepsilon\}\le\frac12$. The same holds for ${\rm clip}\circ z_w$.
* (d) $\mathbb E_{\Pi^{\rm tube}}L_D(z_w)\ge L_D(g)+\eta_0^2$. The same holds for ${\rm clip}\circ z_w$.
* (e) $\Pr_S[\text{some atom does not carry both labels}]\le2M\exp\!\big(-\frac{n(1-\eta_0)}{2M}\big)$.

*Proof.*

* **(a).** For an atom carrying both labels, $|z-1|<\rho$ and $|z+1|<\rho$ hold if and only if $z\in(1-\rho,\rho-1)$, that is, $|z|<\rho-1$. Every training input is an atom carrying both labels, which gives the formula for $U_{\rho,S}$.
  * $z_{Tw}=-z_w$, because $z_w(x)=v^\top h^H(x)$ and $h^H$ does not depend on $v$.
  * The set is open because $w\mapsto z_w(x)$ is continuous.
  * It contains $0$ because $\rho-1>0$, so $\mu(U)>0$ by full support.
* **(b).** $T$ is an involution and $TU=U$. So for Borel $B$, $\Pi(TB)=\mu(T(B\cap U))/\mu(U)=\mu(B\cap U)/\mu(U)=\Pi(B)$.
  * On $U$, $|z_w(x)|<\rho-1$, so $z_w(x)$ is integrable, and $\int z_w\,d\Pi=\int z_{Tw}\,d\Pi=-\int z_w\,d\Pi$. Since ${\rm clip}$ is odd, the same holds for ${\rm clip}\circ z_w$.
  * Under the uniform marginal on $\mathcal C_d$, $L_D(f)=L_D(\eta_0)+\frac1M\sum_x(f(x)-\eta_0)^2$, and $L_D(g)=L_D(\eta_0)$. So a predictor that vanishes on $\mathcal C_d$ has excess exactly $\eta_0^2$.
* **(c).** Let $A=\{w\in U:\frac1M\sum_x(z_w(x)-\eta_0)^2\le\varepsilon\}$, which is Borel. Then $TA=\{w\in U:\frac1M\sum_x(z_w(x)+\eta_0)^2\le\varepsilon\}$.
  * If $w\in A\cap TA$, Minkowski's inequality in $\ell^2(\mathcal C_d,\text{uniform})$ gives $2\eta_0=\|(z_w+\eta_0)-(z_w-\eta_0)\|\le2\sqrt\varepsilon$, which contradicts $\varepsilon<\eta_0^2$.
  * So $A$ and $TA$ are disjoint with $\Pi(A)=\Pi(TA)$, hence $\Pi(A)\le\frac12$.
  * The same argument works for ${\rm clip}\circ z_w$, because ${\rm clip}$ is odd.
* **(d).** By Jensen, $\mathbb E_\Pi\frac1M\sum_x(z_w-\eta_0)^2\ge\frac1M\sum_x(\mathbb E_\Pi z_w-\eta_0)^2=\eta_0^2$, using (b).
* **(e).** Take a union bound over the $M$ atoms of the one-atom estimate in A.r1's proof of Proposition 6.6(b): $\Pr[\text{the labels at }e\text{ agree}]\le2e^{-n(1-\eta_0)/(2M)}$, where an unseen atom counts as agreeing. $\square$

**Consequence.** Let the tolerance $\rho$ be arbitrary: it may depend on $n$ and on the prior scale. Let $\mu$ be any sign-symmetric prior, at any scale, width and depth $L\ge2$. Let $n>\frac{2M}{1-\eta_0}\log\frac{2M}{1-\delta}$. By (e), the event "every atom carries both labels" then has a complement of probability below $1-\delta$. On that event:

* if $\rho\le1$, the tube is empty (Lemma 6.4(a)). This is a failure under (U1), and under (U2) the output is $0$, whose excess is $\eta_0^2$;
* if $\rho>1$, every posterior mean has excess exactly $\eta_0^2>\varepsilon$, by (b).

So TUBE violates (P$_L$) under each of the following readings:

* reading (R2), the posterior means, for every $\delta$;
* the posterior-expected-loss reading, for every $\delta$, by (d);
* reading (R1), a single Gibbs draw, for $\delta<\frac12$ and $n>\frac{2M}{1-\eta_0}\log\frac{2M}{1/2-\delta}$, by (c). That suffices, since (P$_L$) quantifies over all $\delta$.

No limit $\sigma\to0$ is used.

**Numerical check** (`tube_symmetry.out`). The setting is $d=2$, depth $3$, width $4$, $\rho=1.3$, $\eta_0=\frac12$, $\varepsilon=0.2$, rejection-sampled from $\mu_{N,1}$ at width $4$.

* Posterior means at the four atoms: $|\,\cdot\,|\le0.0003$, with standard error $0.0004$.
* $\Pi[L_D\le L_D(g)+\varepsilon]=0.184$, against the mirror event $0.185$.
* $\mathbb E_\Pi$ excess: $0.269\ge\eta_0^2=0.25$.
* Excess of the posterior mean: $0.2500$.
* Run (2), the contrast: when one atom carries only the label $+1$, the posterior mean at that atom is $+0.0131$ (standard error $0.0005$). So the all-conflict hypothesis is genuinely needed.
* $\mu_\sigma$ at a fixed $\sigma=0.3$, with no limit, gives the same picture.
* The Monte Carlo frequency of "not every atom carries both labels" lies below $2Me^{-n(1-\eta_0)/(2M)}$ in all 12 cases with $d\le4$.

**Fix.** Add Observation S-1 as part (a′) of Proposition 6.6, or replace part (a) by it. Then:

* drop "in the strong-prior limit" from §0.1, §10 and the TUBE headline;
* state the TUBE negative for both repository priors at every scale, width and depth, and for tolerances that may depend on $\sigma$;
* keep part (a)'s strong-prior route, which also works for $\delta\ge\frac12$ under (R1).

This also resolves logic Issue 2 by strengthening the result rather than qualifying it.

### N7. Citation and refereeing status (cosmetic)

* **../research-notes/E-finite-prior-scale.md.** §5.4 (l. 554) says "One referee report (`E-logic.md`) found it correct". `E-computation.md` also exists, also says "minor fixes", and predates A.r1.
* **`../research-notes/red-team.md` Proposition 6.1.** It is cited at §5.3 item 3 and §10 item 5, with $\alpha<1/4$ and the label "a sketch I have not checked". Both width referee reports say "major flaw, repairable":
  * as displayed, the excess is polynomially small only for $\alpha<1/8$, because the competitor's Hoeffding term is $\Theta(n^{4\alpha-1/2})$;
  * $\alpha<1/4$ holds after a Bernstein repair, at the slower rate $\tilde O(n^{2\alpha-1/2})$;
  * clipped predictions only.

  Cite those reports. This agrees with logic Issue 6.
* **`../research-notes/red-team.md` Remark 6.2.** It is now refereed: minor fixes (N2).
* **`../research-notes/red-team.md` Proposition 4.1.** It is refereed with minor fixes, and it is relevant to the TUBE picture, but it is not mentioned (N1).

### N8. "Pays the difference back at test time" (cosmetic)

**Location.** §5.4 (l. 559).

At $\lambda=1$ the training deficit is $1-\mathbb EW/n\to1-e^{-1}=0.632$ (`scope_numbers.out` item 3). The certified test excess is $\beta(1)=0.485$. For the atom-mean predictor at $n=M$, the expected test excess $\frac1n\mathbb E\sum_{x\in\mathcal S}k_x^{-1}$ is at most the expected training deficit $\mathbb E|\mathcal S|/n$.

**Fix.** "pays a constant part of it back at test time".

### N9. Optional additions

* **In-expectation reading.** On $D_d$, $L_{D_d}(f)\ge1$ for every predictor. Hence $\mathbb E_SL_{D_d}(\mathsf A_n)\ge1+(1-e^{-2^{d/2}})\,\underline e_d$. So the expectation version of (P$_L$) fails too. One line.
* **Precedent for $d$-uniformity.** The repository's own negative main result is also a $d$-uniform refutation: ambient dimension $d=k$, sample sizes $n\le e^{ck}$ (`NNG/README.md` main result 4, l. 53–55). Citing it next to main result 1 (l. 33) strengthens the case that (P$_L$)'s uniformity in $d$ is the repository's convention.
* **Natural "best versions" outside A's scope.** Two could be added to §0.1's "not covered" bullet:
  * the correctly specified Gaussian likelihood, with a fixed observation variance near ${\rm Var}(y\mid x)$; this is FIX$_\eta$, Claim C;
  * a hyperprior on the noise scale.

  Under the strong prior ($\sigma\to0$), both keep the likelihood at a fixed scale while the prior concentrates. By the argument of `slt-likelihood/README.md` §3 (l. 195–202), the posterior then tends to the prior in total variation and ignores the data. That fails (P$_L$) already for a constant target. This is a failure of a different kind from A's, and A need not cover it. Brief §2 and Claim C treat FIX$_\eta$ at finite scale and polynomially bounded width, where it is expected to work.

---

## 5. Adversarial scenarios: what I tried

1. **Fixed $d$ (the cube family).** I re-derived Proposition 5.2.
   * Comparison with $w=0$ gives $\Delta(z_w)\le\Delta_0+ct$.
   * On $\{k_{\min}\ge1\}$, Minkowski gives $L-1\le U_S$.
   * $\mathbb E[k\bar y^2\mid k]=1$ together with Markov's inequality, and Chernoff for $k_{\min}$, give $U_S\le(8M/\delta'+4ct)/n$.

   The cube family is consistent at every width; A.r1 says so. Whether another fixed-$d$ law defeats tight SP$_c$ is open, as stated.
2. **Learner width tied to $n$, say $N=n^{\alpha'}$.** A.r1 makes no claim below $N_0$ and says so (§5.3 item 3; §10 item 5). The picture across $\alpha'$:
   * **$\alpha'>1$.** The fixed-accuracy threshold $N_0=O(n\log^2n/a^2)$ is eventually below $n^{\alpha'}$. So A.r1's failure, with excess $(\sqrt{\beta(\lambda)}-a\sqrt\lambda)_+^2-o(1)$, reaches every reading in which the learner's width is a polynomial of degree above $1$.
   * **Small $\alpha'$.** `../research-notes/red-team.md` Proposition 6.1, as repaired in its two referee reports, gives success for clipped predictions of SP$_1$:
     * against fixed competitors when $N=o(\sqrt{n/\log n})$;
     * against the class of width and weights at most $n^{\alpha'}$ when $\alpha'<1/4$.
   * **In between.** Nothing is known: from $\sqrt n$ to $n\log^2n$ for fixed competitors, and $\alpha'\in[1/4,1]$ for the $n^{\alpha'}$ class.

   One sentence in A.r1 stating these three regimes would help the user.
3. **TUBE at finite scale, $\rho>1$.** Not covered by A.r1; covered by Observation S-1 (N6).
4. **TUBE with $\rho$ depending on $\sigma$.** This falls outside "schedule $\rho(n)$". Part (a)'s proof breaks for $\rho\downarrow1$; Observation S-1 covers it.
5. **Literal falsification of a stated result.** All theorem bodies survived. One summary sentence fails (N3).
6. **"The conjecture holds" in the $n^\alpha$ reading, with $d$ up to $n^\alpha$.** ../research-notes/B-tempered-likelihood.md's bound is not uniform there for $\alpha\ge1/(6H+4)$ (N5). The two sides meet on $d\le{\rm polylog}(n)$.
7. **Bounded-density inputs.** Open, as A.r1 states. I agree that Proposition 7.4 bounds what the Lipschitz transfer at level $K_2$ can reach. Remark 7.5's "needs a density ratio" is an interpretation of that proposition, not a theorem (logic Issue 11).
8. **Depth two.** Open, as stated. If the user's mental model is a one-hidden-layer MLP, nothing in A.r1 applies to SP$_c$. The TUBE results do apply.
9. **Order of limits.** $\sigma\to0$ is taken after $(d,n,N,c,t,S)$ are fixed. This matches `paper.tex` Theorem `strong` (l. 194–196: the threshold "may depend on that finite width, the teacher, $\rho$, and $\varepsilon$; it does not depend on $D,n,\delta$") and slt-likelihood §2 (l. 60: "may depend on the selected $n,N$, the teacher, and the accuracy parameters; it is uniform over $D$"). Reading (R1) is more lenient than both, so refuting it is the stronger statement. The refutation holds for **all** small $\sigma$, so it also covers subsequences and weak limits.
10. **Loss.** MSE against fresh noisy labels. By the bias–variance identity this is equivalent to estimation error $\|f-\eta\|^2_{L^2(D_X)}$, so there is no ambiguity.
11. **Degenerate law.** Pure noise is not essential: Corollary 4.6 handles any signal $\eta$ computed by a network, plus noise with ${\rm Var}\ge v_0$. The genuine degeneracies are the ones A.r1 already lists: atoms (or near-atoms), and $n\asymp2^d$.

---

## 6. Consistency with repository theorems: no contradiction found

| repository result (checked in source) | its hypotheses | A.r1's setting | consistent? why |
|---|---|---|---|
| slt-likelihood §2, strong-prior theorem (l. 46–60) and the $c\sigma^2$ remark (l. 96) | clean labels $y=f(x)$ from a width-$C$ teacher; residual budget $cK$; guarantee for the latent mean | noisy labels; or A′'s $f^\star$ | Yes. With noise the teacher's own residual is $\Theta(n)$, so the budget argument fails (Remark 4.9). $f^\star$ jumps by $2$ inside each connected cluster $X_p$, so no continuous function, and hence no teacher, computes it on $X$ |
| slt-likelihood §2, finite-scale theorem (l. 102) | clean labels, $\mu_{N,\gamma}$, observation variance $N^{-\gamma}$ | not treated (../research-notes/E-finite-prior-scale.md) | no overlap |
| slt-likelihood §3, raw priors (l. 195–202) | fixed likelihood; $\mathbb E[z^2\mid\text{hidden}]\le N^{-\gamma}$ | used only in the finite-scale TUBE remark after Lemma 6.2 | correct use |
| `paper.tex` Theorems `strong` and `finite` (l. 178–220) | TUBE with clean teacher labels; error at tolerance $\tau>\rho$ | Proposition 6.3(b) with $b=0$: clean constant target $\eta_0<\rho$ | Yes. The collapse to $0$ has $\lvert0-\eta_0\rvert<\rho<\tau$, so tolerance error $0$ but MSE excess $\eta_0^2$. Those theorems are not MSE statements (A.r1 l. 626) |
| `paper.tex` Proposition `exact` and Corollary `exact` (l. 613–690) | clean labels; energy $\le E_*$; fit within $\tau/2$ | noise memorizers, energy $K_{\rm mem}\to\infty$ | Yes; no teacher, and energy unbounded in $n$ |
| noisy-interpolation theorem (l. 61–76); open target (l. 556) | margin conditioning; distinct inputs; at most $s$ corruptions; clean classification error | SP$_c$ and TUBE; MSE against noisy labels | Yes. At fair-coin noise the bound is at least $As/n\approx A/2\ge1$, which is vacuous: the explicit coefficient is $A=2+8b_1\ge2$ (README l. 492). For a small flip rate $\eta$, Corollary 4.6 gives an MSE excess of at least $4\eta(1-\eta)\beta(\lambda)-o(1)$. That is of order $\eta$, the same tempered picture as the repository's $P(d,L,U)\eta$ clean-error bound. Different learner, different loss, no clash |
| FAQ Q33 scope (l. 1452: "Repeated inputs with contradictory labels would make exact conditioning impossible"); Q34 (l. 1493: "They do not assert the same bound for data corrupted by fixed positive observation noise") | — | Lemma 6.4(a); Claim A | the same statements |
| `NNG/README.md` main result 1 (l. 33: "polynomial in input dimension") | — | (P$_L$) uniform in $d$ | supports A.r1's reading |
| `NNG/README.md` main result 4 (l. 53–55: $d=k$, $n\le e^{ck}$) | — | $d=\log_2n$ | the same style of $d$-uniform negative (N9) |
| ../research-notes/B-tempered-likelihood.md Theorems 6.3, 6.4 and 7.4; Corollaries 8.1 and 9.3 (sibling, refereed with minor fixes) | tempered SP$_c$, $c=n^{1-\theta}$ | tight SP$_c$ | Consistent. The $c$-ranges are disjoint: A.r1 has $c=o(n^{1-1/H}d^{-1/H})$, B has $\theta<1/H$. B Theorem 7.4(b) reproduces A's failure for $\theta>1/H$, with the weaker constant $1/e$. A.r1 cites Theorems 6.3–6.4 and Corollaries 8.1 and 9.3 correctly, except for N5 |
| ../research-notes/E-finite-prior-scale.md Theorem 2.7, Theorem 5.2, Corollary 5.4 (sibling, refereed with minor fixes) | finite scale, every $\gamma\ge1$ | strong prior | consistent; cited correctly (N7 for the referee status) |
| `../research-notes/red-team.md` Proposition 4.1 (TUBE with matched tolerance; refereed with minor fixes) | $\lvert y-g(x)\rvert\le\rho_0$, $\rho>\rho_0$, $\tau>\rho+\rho_0$ | Proposition 6.6: $\rho_0=1+\eta_0$ | Consistent. There $\tau>2\rho_0$, so the bound $(\tau+\rho_0)^2>9(1+\eta_0)^2>4$. It is vacuous, because $L_D({\rm clip}\,z)\le4$ always |

---

## 7. Would the user accept it?

**What the user should accept.**

* SP$_1$ in the strong-prior limit is the repository's own clean-label Gaussian learner (slt-likelihood §2; FAQ Q34). The order of limits is the repository's, the loss is the requested MSE, and the competitor is the trivial network. The failure covers near-minimizers, Gibbs draws and posterior means, at every large width.
* Uniformity in $d$ is the repository's own convention, both for its positive main result 1 and for its negative main result 4.
* Within that convention, tightly conditioned SP$_c$ is not an agnostic learner at depth $\ge3$ and width $\ge N_0$. TUBE is not an MSE learner under asymmetric label noise at any tolerance, even at a fixed input dimension.
* The conjecture itself is not refuted. A.r1 now says so prominently, and ../research-notes/B-tempered-likelihood.md supplies a learner with the property.

**What the user will object to, and A.r1 now acknowledges.**

* $d\to\infty$ (Proposition 5.2).
* Near-atomic laws; bounded-density laws are open (Proposition 7.4).
* Widths of $10^5n$ and beyond (§5.3 item 3).
* The progressive mixture; depth two; the finite scale (../research-notes/E-finite-prior-scale.md).

**What the user will object to, and A.r1 does not yet address.**

* "TUBE with $\rho=10$ is not tight conditioning" (N1).
* "By 'pretty close' I meant a fit as good as the best small network, which is what your successful learners do" (N2).
* "You say the $n^\alpha$ reading is refuted, but ../research-notes/B-tempered-likelihood.md proves it" (N4). Also, "is the positive side uniform in $d$?" (N5).
* "Does TUBE also fail at the repository's finite scales?" Yes, by Observation S-1 (N6).

---

## 8. Numerical checks

Scripts and outputs are in `../checks/verify-A-scope/`. They are sanity checks, not proofs.

1. **`tube_symmetry.py`** (Observation S-1).
   * Rejection sampling from $\mu_{N,1}$, and from $\mu_\sigma$ at $\sigma=0.3$, at $d=2$, depth $3$, width $4$, with $\rho=1.3$, $\eta_0=0.5$, $\varepsilon=0.2$.
   * With every atom carrying both labels:
     * the posterior means at the four atoms vanish within Monte Carlo error ($\le0.0003$, standard error $0.0004$);
     * the Gibbs success probability equals its mirror ($0.184$ against $0.185$; $0.092$ against $0.093$);
     * the posterior-averaged excess exceeds $\eta_0^2$ ($0.269$; $0.257$);
     * the excess of the posterior mean is $0.2500$.
   * In the contrast run, one atom carries only $+1$, and the posterior mean there becomes nonzero: $+0.0131\pm0.0005$ at finite scale.
   * The Monte Carlo frequency of "not every atom carries both labels" lies below the union bound $2Me^{-n(1-\eta_0)/(2M)}$ in all 12 cases with $d\le4$.
2. **`scope_numbers.py`.**
   * $N_0/n$ at a fixed accuracy ranges from $2.07\cdot10^5$ ($d=20$, $a=0.3$) to $7.28\cdot10^6$ ($d=40$, $a=0.1$).
   * ../research-notes/B-tempered-likelihood.md Corollary 8.1's term $\Xi_nn^{-\beta}$ at $H=2$:
     * at $d=\log_2n$ it tends to $0$ for $\alpha\in\{0.04,0.0625,0.1\}$;
     * at $d=n^\alpha$ it tends to $0$ for $\alpha=0.04$, stays at $1$ for $\alpha=1/16$, and diverges for $\alpha=0.1$.
   * $\mathbb EW/n$ at $\lambda=1$ equals $0.367879=e^{-1}$ (to six digits) at $d=20,30$, so the training deficit is $1-e^{-1}=0.632$.
   * The A′ density ratio is $10^{286.7}$ at $(H,d)=(2,20)$, matching Table 7.1.
   * $\beta(\lambda)$ values: $\beta(1)=0.484829$ and $\beta(1.50286)=0.517351$, matching Lemma 4.3(d).

---

## 9. Summary for the lead

* **Verdict.** `minor_fixes`. The mathematics is sound. The scope of the negative results is now stated correctly in §0.1, §5.4 and §10. The conjecture is correctly reported as **not** refuted. All round-0 scope issues are fixed. I found no contradiction with the repository.
* **Before this goes to the user:**
  * **N1.** Stop calling TUBE "tightly conditioned". For $\rho>1$ it is loose. Its lesson is that a per-point hard tolerance targets the midrange, not the mean. Retitle the section.
  * **N2.** Qualify "the heuristic fails": the per-output reading, width $\ge N_0$, near-atomic data. Note that the aggregate-fit reading is what the successful learners do.
  * **N3.** Fix the false bullet (§0.2 item 6, third bullet). It needs $\rho<b$ and $N\ge N_0(d,n,\rho/2)$.
  * **N4–N5.** Name the learner in §5.3 item 2. Restore the ${\rm poly}(d)$ factor in the ../research-notes/B-tempered-likelihood.md Corollary 8.1 citation, and use $d\le{\rm polylog}\,n$ as the range of uniformity.
* **Recommended strengthening (N6).** Add Observation S-1. It makes the TUBE negative hold for both repository priors at every scale, width and depth, and for any tolerance, with no $\sigma\to0$ limit. The proof is short.
* **Cosmetic (N7–N9).** Update the referee status of ../research-notes/E-finite-prior-scale.md and of `../research-notes/red-team.md` Proposition 6.1, Remark 6.2 and Proposition 4.1. Rephrase "pays the difference back". Optionally add the in-expectation reading and the precedent of main result 4.
