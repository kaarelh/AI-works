# Re-referee report (scope and definitions), final candidate: `../research-notes/depth-two.md`

*Published record of a referee report on the final candidate of the note, made during finalization. Paths under `stage/` refer to the lead's unpublished working copies; the pre-revision text there is the version that the second-round referee reports reviewed, published as [`depth-two-first-version.md`](depth-two-first-version.md). The referee's scripts and outputs are in the `../checks/depth-two-referee-*` folder named below. Re-runs of the note's own scripts (`author_rerun/` and similar subfolders) are not published; the report says whether they reproduced the recorded outputs.*

**Lens.** Scope and definitions. I checked four things:

- whether the formulations the note claims to refute, (P$_2$) and (P$_2^{o(1)}[\phi]$) with the readings (R1), (R1′), (R2) and (R3), are well defined, non-vacuous and consistent with `../research-notes/problem-brief.md` §1 and with `../research-notes/B-tempered-likelihood.md` Corollary 8.1;
- whether every "refuted", "holds", "not refuted" and "open" status is exactly right;
- whether the three major issues of the second-round logic report (`RT-depth2-logic-revised.md`, issues 1–3) are fixed;
- every statement in the note about what `B-tempered-likelihood.md` (B below) proves at depth two, against B itself.

**What I read.**

- All of `../research-notes/depth-two.md` (the note), with the focus on §0, §1.4, Corollary 5.2 and its proof, the remarks after Proposition 5.3, Remarks 5.2a, 5.3a, 5.4, 5.5, 5.7, 5.7a and 5.8, the §6 errata, and §§8–9.
- `../research-notes/problem-brief.md` §§1–2 and §4 (Claims B and D).
- B: §0, §1, Lemmas 2.1, 2.3, 3.1, 5.3, Corollary 3.2, Proposition 6.1 and the paragraph after it, Remark 6.5, Theorems 6.3, 6.4 and 7.4, §7.5, Corollary 8.1, §9 (Proposition 9.1, Lemma 9.2, Corollary 9.3, Discussion, Remark 9.4) and §11.
- `../research-notes/A-tight-conditioning-fails.md` §5.1 ((P$_L$), (R1)–(R3)), Proposition 5.2, §5.3 item 2, §5.4 and Proposition 8.2.
- `../research-notes/small-learner-width.md` Theorem 1(c) and Remark 7.
- The staged `red-team.md`: §0 item 6, §2.3 A3, §5, §6.1, §6.4, §7 item 3 and Appendix A, to check that every erratum quotes its target exactly.
- The four earlier reports, and the second-round referees' scripts `width1_strawman` and `every_learner_dn` with their outputs.

**Script.** `../checks/depth-two-referee-scope-1/prop91_depth2.py`, with its output `prop91_depth2.out`, is in the staging folder next to this report. It should move to a `../checks/` subfolder if this report is published. It checks the depth-two consequence of B Proposition 9.1 described in issue 1.

---

## Verdict: minor fixes

The second round's major issues are fixed:

- **Issue 1 is fixed.** (P$_2^{o(1)}$) now asks for the bound at every learner width $N\ge n^\alpha$, as B Corollary 8.1 does.
- **Issue 2 is fixed.** No claim remains that Proposition 5.3 refutes a formulation, and Remark 5.3a proves that uniformity over $d\asymp n$ is impossible for every learner.
- **Issue 3 is fixed.** The open range now separates what B states from what the note derives by combining B's statements.

Both formulations are well defined. They are satisfied by B's tempered learner in the clipped readings, and in the unclipped readings with one unrefereed combination that I re-derived. They are consistent with the brief, with `A-tight-conditioning-fails.md` §5.1 and with B Corollary 8.1. Every refutation the note claims is correct and meaningful.

One statement about B is wrong. Remark 5.7a says "B does not treat the negative side at depth two". In fact B Proposition 9.1, stated for every $L=H+1\ge2$ and every $c>0$, is a depth-two lower bound for general $c$. It shows that both (P$_2$) and (P$_2^{o(1)}[\phi]$) fail for every $c(n)\ge n^{1-o(1)}$, under every reading and at every learner width. The note leaves this range "not classified". Meanwhile §0 ("The open range is therefore …") and the erratum for RT §0 item 6 ("open only while $c=O(\log^2n)$") silently treat it as settled. This changes no theorem, and the open range the note states becomes correct once Proposition 9.1 is cited. So the issue is minor, but it falls squarely within this lens.

The remaining issues are small gaps in the two unrefereed remarks, wording, and cross-document bookkeeping (§4).

---

## 1. Answers to the focus questions

| Question | Answer |
|---|---|
| Are the formulations well defined? | **Yes.** (P$_2$) is `A-tight-conditioning-fails.md` (P$_L$) at $L=2$, with identical quantifiers. In (P$_2^{o(1)}[\phi]$), $\alpha$ and $\epsilon_n$ are fixed before $\delta$; $\epsilon_n$ is uniform over $d\le\phi(n)$, laws and learner widths $N\ge n^\alpha$; and $\mathcal G^{(\alpha)}_n$ is explicit. The readings fix the $\sigma$-quantifier ("$\sigma_0$ may depend on everything except the sample"). They also state the measurability of (R1) (joint continuity of the density, Tonelli) and the outer probability of (R3). Both work in both directions: for a refutation the bad event lies in a measurable event of small probability, and for a positive result the good event contains one of large probability. |
| Are they non-vacuous? | **Yes**, for every reading. (P$_2$): clipped readings by B Theorem 6.3 (every $\theta\in(0,1)$ at $H=1$), unclipped readings by B Theorem 6.4 ($\theta<1/2$), with the sample-uniform $\sigma_0$ of the paragraph after B Proposition 6.1 and B Lemma 3.1. (P$_2^{o(1)}[\log_2n+C_0]$): clipped readings by B Corollary 8.1 at $H=1$, $\alpha<1/8$. Unclipped readings only by the note's own combination in Remark 5.7a (B Lemma 5.3(b), the unclipped half of Proposition 6.1, and the argument of Corollary 8.1), for $\sqrt n\log n\ll c\le n^{1-\epsilon}$. I re-derived that combination and it is correct; it is unrefereed, as the note says. (P$_2^{o(1)}[\phi]$) with $\phi(n)\ge n/b$ is unsatisfiable (Remark 5.3a), and the note now treats it so. |
| Consistent with the brief and with B Corollary 8.1? | **Yes.** The learner-width quantifier is $N\ge m$ in (P$_2$), as in brief §1, and $N\ge n^\alpha$ in (P$_2^{o(1)}$), as in B Corollary 8.1 (quoted exactly). $\mathcal G^{(\alpha)}_n$ is B's class: same architecture, width $\le\lfloor n^\alpha\rfloor$, weights in $[-n^\alpha,n^\alpha]$. The note's property is required width by width, while B Corollary 8.1 holds simultaneously over widths. So the note's property is the weaker one: B's result implies it, and refuting it is the stronger statement. It also matches `A-tight-conditioning-fails.md` §5.3 item 2. One wording point: the brief calls the two formulations "equivalent", and Remark 5.7a correctly shows that they differ at depth two ($c=\log^3n$). |
| Is every status claim exactly right? | All "refuted", "holds", "not refuted" and "false for every learner" claims are right (§3). The "open" range for the "$+o(1)$" formulation is right. The note's account of why the complementary large-$c$ range is not open is missing: B Proposition 9.1 settles it negatively, and the note says B has nothing there (issue 1). |
| Are the three second-round major issues fixed? | **Yes** (§2). |
| Are the claims about B at depth two right? | All but one (§3.1). "B does not treat the negative side at depth two" is false (issue 1). |

---

## 2. The three issues of the second-round logic report

**Issue 1 (width quantifier): fixed.**

- §1.4 now requires "every learner width $N\ge n^\alpha$". The "Learner widths" paragraph explains why: the competitors' width bound, as in brief §1 and B Corollary 8.1.
- Corollary 5.2(b) exhibits the width $N=\max\{N_0(a_d),\lceil n^\alpha\rceil\}$.
- The single-width sentence is kept.
- Remark 5.2a records the width-one strawman. I checked its numbers: $g^*(0)=\tanh1=0.76159$ and $g^*(\pm1)=0.11673$, so $\Delta=0.64486$ and $\Delta^2/6=0.06931$, matching `../checks/verify-RT-depth2-logic-revised/width1_strawman.out`.
- The restriction of Remark 5.2a to readings (R1) and (R3) is correct. At width one a posterior mean can mix increasing and decreasing networks, so the monotonicity argument does not cover (R2).
- No text still states (P$_2^{o(1)}$) with $N\ge1$. The remaining "$N\ge1$" occurrences concern Proposition 5.3's construction and the $m=1$ competitor of Remark 5.7, and both are correct.

**Issue 2 (uniformity over $d\asymp n$): fixed.**

- The withdrawn entries are gone, from §0, §0.1 item 3, §0.2 row 3, the remarks after Proposition 5.3, Remark 5.4, Remark 5.8 item 4 and the errata for RT §0 item 6, RT §6.1 and the sentence after RT Proposition 5.3.
- Remark 5.3a proves the impossibility. I checked it:
  - $g_\theta\in\mathcal G^{(\alpha)}_n$, with weights $0,\pm n^{-\alpha},n^\alpha$, and $L_{D_\theta}(g_\theta)\le n^{-4\alpha}/9$.
  - The unseen-coordinate argument and the averaging over $\theta$ are correct.
  - The $d=\lceil n/b\rceil$ extension gives $e^{-b}/2-o(1)$.
  - $M\ge n/(\lambda+1)$ is correct.
- One small gap remains in the "every reading" claim (issue 2 below).

**Issue 3 (open range): fixed.** I checked Remark 5.7a against B:

- Corollary 8.1 at $H=1$: $\theta=(1+8\alpha)/3$, $c=n^{(2-8\alpha)/3}$, $\Xi_n=d(d+1)+4+8\sqrt2\sqrt{2(d+1)\ln(n+1)}+4\sqrt{2\ln(2/\delta)}$, $\beta=\min\{(1-4\alpha)/3,\frac12-4\alpha\}$, and decay only for $\alpha<1/8$. All agree with B (B lines 790–816).
- The general-$c$ bound (5.7a): Lemma 5.3(a) at $H=1$ with $K=n/c+1$ gives $8D_n\sqrt{1/c+1/n}+4\sqrt{\ln(2/\delta)/(2n)}$, and Proposition 6.1 adds $c(E_*+1)/n+(U+1)^2\sqrt{\cdot}$. ✓
- The class version: $E_*+1\le(d(d+1)+4)n^{4\alpha}$ and $4+(U+1)^2\le8n^{4\alpha}$. ✓ The three-term limit for $d\le\log_2n+C_0$, $\alpha<\min\{1/8,\epsilon/4\}$, and the choice of $\epsilon_n$ and $n_\delta$ are correct.
- The unclipped variant has order $D_n\sqrt n/c$. ✓
- The statuses in the table are right for the ranges they list. I confirmed that B Proposition 9.1 does not reach the open range. There $n/c\ge n^{1/2-o(1)}$, so its competitor needs weights of order at least $n^{1/4-o(1)}$ (width one), or $\alpha>1/6$ for the width-$n^\alpha$ chain of B Lemma 9.2. That excludes only large $\alpha$, while (P$_2^{o(1)}$) asks for some $\alpha>0$.
- The new problem is in what Remark 5.7a says about B outside the table (issue 1).

The other second-round issues (logic 4–9, computation 1–7 and the script remark) are all resolved as §9 of the note records. I spot-checked each location.

- Logic 6 was optional and was declined with reasons. The note calls this "rebutted", although it agrees with the referee's mathematics, so "declined" is the accurate word (issue 6(b)).
- In computation 2, the values $0.389$ and $0.576$ for every near-minimizer equal $\phi-c/G$ with $G=154.8$ and $634.1$. ✓

---

## 3. Audit tables

### 3.1 Every statement about what B proves at depth two

| Statement in the note | Where | B source | Verdict |
|---|---|---|---|
| Theorem 6.3 allows every $\theta\in(0,1)$ at $H=1$. The clipped excess is $\le(E_*+1)n^{-\theta}+8\sqrt2D_nn^{-(1-\theta)/2}+(4+(U+1)^2)\sqrt{\ln(2/\delta)/(2n)}$ at every $N\ge m$, with polynomial $n_0$. So SP$_{n^{1-\theta}}$ has (P$_2$) in the clipped readings. | §0.2 row 1; Rem. 5.7a | Thm 6.3 (statement and $n_0$); $(2/H)^{H/2}=\sqrt2$; $D_n$ has no $(H-1)/2$ term at $H=1$ | correct |
| Theorem 6.4 does the same for the unclipped readings when $\theta<1/2$ | same | Thm 6.4 ($\theta<1/L$) | correct |
| Corollary 8.1 asks "simultaneously for all learner widths $N\ge n^\alpha$" | §1.4; §0.4 item 1 | Cor 8.1 | correct, quoted exactly |
| Corollary 8.1 at $H=1$: the constants and the range $c\in(n^{1/3},n^{2/3})$ | Rem. 5.7a | Cor 8.1 and its proof | correct ($\delta$-dependence of $\Xi_n$, issue 3) |
| Proposition 6.1 holds for every $c>0$ with $K=n/c+1$; Lemma 5.3 for every $K>0$; (5.7a) is their combination, "not displayed in B" | Rem. 5.7, 5.7a | Prop 6.1; Lemma 5.3 | correct |
| The unclipped bound is of order $D_n\sqrt n/c$ | Rem. 5.7, 5.7a | Prop 6.1 (unclipped half); Lemma 5.3(b) | correct |
| $\sigma_0$ does not depend on the sample | Rem. 5.7a | paragraph after Prop 6.1 (clipped); Lemma 3.1 and Cor 3.2 (unclipped) | correct |
| §7.5 item 3: vanishing excess on the noisy cube once $c\gg D_n^2$ | Rem. 5.7a | §7.5 item 3 | correct |
| "B does not treat the negative side at depth two" | Rem. 5.7a, third bullet | Prop 9.1 (for every $L\ge2$, $c>0$); §9 Discussion ("for every $c$ and $n$ with $n/c\ge2L$"); §0 table, weight-bound row | **incorrect** (issue 1) |
| Theorem 7.4 and §7.5 items 1–2 assume $H\ge2$ | Rem. 5.7a | §7 opens "Throughout this section $H\ge2$" | correct, but B's general-$c$ material is not confined to §7 (issue 1) |
| "the tempered SP$_c$ that B proves consistent" | Rem. 5.2a | Thm 6.3 | correct |
| Remark 5.7 window: vanishing clipped excess for $\log^2n\ll c\ll n/\log^2n$ | Rem. 5.7; §6 erratum for RT §5 "Open" | Prop 6.1 with $g\equiv0$ written as a width-one net, $E_*=d^2+d+2$ | correct but not sharp (issue 6(c)) |

### 3.2 Every status claim

| Status claim | Where | Verdict |
|---|---|---|
| (P$_2$) is refuted for every $0<c\le\mathrm{poly}(d)$, under (R1), (R1′), (R2) and (R3), at $N\ge N_0$ | §0; §0.1 (i); §0.2 row 1; Cor 5.2(a) | correct; meaningful, since (P$_2$) is satisfiable |
| (P$_2$) holds for clipped readings at $c=n^{1-\theta}$, $\theta\in(0,1)$, and unclipped at $\theta<1/2$ | §0.2 row 1 | correct |
| "Other $c$ are not settled here" | §0.2 row 1 | true of this note. B Prop 9.1 settles $c\ge n^{1-o(1)}$ negatively, and $c\ge n/4$ already on one fixed law in $d=1$ (issue 1) |
| (P$_2^{o(1)}[\log_2n+C_0]$) is refuted for $c(n)\le\nu/\log_2n$, every $\alpha>0$, every $\epsilon_n\to0$, all readings | §0; §0.2 row 2; Cor 5.2(b) | correct; meaningful (B Cor 8.1) |
| It holds for clipped readings when $\log^2n\ll c\le n^{1-\epsilon}$, and for all readings when $\sqrt n\log n\ll c\le n^{1-\epsilon}$ | §0.2 row 2; Rem. 5.7a | correct (combination re-derived; unrefereed) |
| It is open for $c\log n\to\infty$ and $c=O(\log^2n)$ (clipped) or $c=O(\sqrt n\log n)$ (unclipped); this includes every fixed $c$ | §0; §0.2 row 2; Rem. 5.7a; Rem. 5.8 item 1 | correct. No result in the note, B, A or `small-learner-width.md` settles it (§2, issue 3) |
| "The open range is therefore …" and "open only while $c=O(\log^2n)$" | §0, third bullet; §6 erratum for RT §0 item 6 | correct only once B Prop 9.1 is cited. As written they contradict Rem. 5.7a's "neither is $c\ge n^{1-o(1)}$" classified (issue 1) |
| "$+o(1)$" uniform over $d\le n$, or over $d\le n/b$, is false for every learner | §0.2 row 3; Rem. 5.3a | correct (one-line gap for (R1′), issue 2) |
| Proposition 5.3 refutes no formulation of the conjecture | §0; Prop. 5.3 remarks; §6 | correct |
| Fixed $d$: not refuted by the cube family; excess $\le(8\cdot2^d/\delta+4c)/n$ | §0.2 row 4 | correct (A Prop 5.2(c), $t=1$) |
| Nothing is refuted at widths below $N_0$; clipped near-minimizers succeed below $n/\log^2n$ on the example | Rem. 5.5 | correct (`small-learner-width.md` Thm 1(c) substitution checked) |
| The progressive mixture is not covered | Rem. 5.6 | correct |
| Proposition 5.3 under unit-ball inputs for $c\ge\sqrt{\beta(\lambda)}/2$ is an open question about the learner | Rem. 5.4; Rem. 5.8 item 4 | correct |
| The two formulations differ at $c=\log^3n$ | Rem. 5.7a | correct (rests on the unrefereed combination) |

---

## 4. Issues, most severe first

### Issue 1 (minor; claim about B, and an unclassified range). B Proposition 9.1 is a depth-two negative result for general $c$, and it settles $c\ge n^{1-o(1)}$

**Where.**

- Remark 5.7a, third bullet: "B does not treat the negative side at depth two", and the next sentence, which presents §7 as the place "where B treats the threshold and general $c$".
- Remark 5.7a, the sentence after the table: "neither is $c\ge n^{1-o(1)}$" classified.
- §0.2 row 1: "Other $c$ are not settled here".
- §0, third bullet: "The open range is therefore …".
- §6, erratum for RT §0 item 6: "For clipped predictors it is open only while $c=O(\log^2n)$".
- §0.4 item 3: "Remark 5.7a states what that note proves at depth two".

**Problem.**

- B Proposition 9.1 is stated for every $L=H+1\ge2$, every $c>0$ and every $n$, with $K=n/c+1$.
- B's §9 Discussion repeats it "for every $c$ and $n$ with $n/c\ge2L$", and B's §0 table states it without any restriction on $H$.
- `small-learner-width.md` Remark 7 already imports it at $L=2$ ("The window is $[0.25,0.333]$ at $L=2$").

At $L=2$, $d=1$ and $X=\{\pm\delta_0\}$ with labels $\operatorname{sign}x$, take $\delta_0=\min\{1/2,1/K\}$. Then:

- **(a) The learner.** Every $w\in\mathcal N_1^{(N)}$, at every width and for every sample, has $\lvert z_w(\delta_0)-z_w(-\delta_0)\rvert\le2\eta$ with $\eta=\delta_0K/2\le\frac12$. Hence $L_D\ge\frac14$. The same holds for $\mathcal G_\sigma$, $\mathcal G^{\rm clip}_\sigma$, $\bar f_\sigma$ and $\bar z_\sigma$ (Prop 9.1(a)), and for $\operatorname{clip}\bar z_\sigma$, since clip is 1-Lipschitz. The $\sigma$-corrections are uniform in $S$ by B Lemma 3.1, so every reading of §1.4 is covered.
- **(b) The competitor.** A width-one competitor with zero loss and weights $\le1.5\max\{\sqrt2,\sqrt K\}$ fits the law exactly (Prop 9.1(b)).

Consequences at depth two:

- **The "$+o(1)$" formulation.** If $n/c(n)=n^{o(1)}$, the competitor lies in $\mathcal G^{(\alpha)}_n$ for every $\alpha>0$ and all large $n$. Since $d=1\le\log_2n+C_0$, (P$_2^{o(1)}[\phi]$) fails for every $\phi\ge1$, under every reading and at every learner width, with probability one.
- **The polynomial-sample property.** The same competitor has weight bound $B_n=n^{o(1)}$, so $\mathsf p(1,1,B_n,1/\varepsilon,\log(1/\delta))<n$ eventually, and (P$_2$) fails.
- **Large $c$ on a fixed law.** For $c\ge n/4$ ($K\le5$), a single fixed law ($\delta_0=1/5$) and a single fixed competitor (weights $\le2.39$) defeat SP$_c$ for every $n$.

`prop91_depth2.out` confirms the arithmetic:

- the $L=2$ Lipschitz step holds on 20000 random networks, with largest ratio $0.962$;
- for $c=n/\ln n$ the competitor enters $\mathcal G^{(0.05)}_n$ from $n\approx10^{16}$;
- L-BFGS on $F_{n/4}$ returns the zero network, with test MSE $1$, at widths $1$, $4$ and $16$.

So the statement about B is false, and the note leaves unclassified a range that B settles. The §0 sentence and the erratum reach the right open range only through this unstated result. Without it, the note's own logic would make $c\ge n^{1-o(1)}$ open too.

**Fix.**

- In Remark 5.7a, add under "Stated in B at depth two" a bullet for Proposition 9.1(a),(b) and the §9 Discussion at $L=2$.
- Restrict "B does not treat the negative side" to the noisy cube (B §7.5 item 3).
- Add a table row "$n/c(n)=n^{o(1)}$, i.e. $c\ge n^{1-o(1)}$: fails / fails (B Proposition 9.1, $d=1$)".
- In §0.2 row 1, add that (P$_2$) fails for $c\ge n^{1-o(1)}$, and for $c\ge n/4$ already on one fixed law.
- Then §0's "therefore" and the erratum's "open only while" become justified. Sequences that oscillate between rows remain unclassified.

### Issue 2 (minor; unrefereed Remark 5.3a). "Every reading" is proved only for readings whose output is a single function

**Where.** Remark 5.3a, "So, for every learner, every reading, every width and every $c$ …".

**Problem.** The proof works with one output $f$: a posterior draw, a posterior mean or a selected near-minimizer. Under (R1′) the learner's loss is the Gibbs risk $\mathcal G=\mathbb E_\xi L_{D_\theta}(f_\xi)$, which is not the loss of any single output. The claim is true, and a one-line extension proves it. Given $S$, set $q_j=\Pr_\xi(s_j(\xi)=-\theta_j)$ for $j\in\mathcal U$. Each $q_j$ is a function of $\theta_j$ alone, and the $q_j$ are independent with mean $\frac12$ under the uniform $\theta_{\mathcal U}$. Since $\mathcal G\ge n^{-1}\sum_{j\in\mathcal U}q_j$, Hoeffding's inequality gives $\mathcal G\ge1/(2e)-o(1)$ with probability $1-o(1)$.

**Fix.** Add that sentence.

### Issue 3 (minor; Remark 5.7a, Corollary 8.1 bullet). $\Xi_n$ depends on $\delta$, but $\epsilon_n$ may not

**Where.** "Since $\Xi_nn^{-\beta}\to0$ uniformly over $d\le\log_2n+C_0$, this is (P$_2^{o(1)}[\log_2n+C_0]$)".

**Problem.**

- In (P$_2^{o(1)}$), $\epsilon_n$ is chosen before $\delta$, but $\Xi_n$ contains $4\sqrt{2\ln(2/\delta)}$. The next paragraph does the absorption correctly for general $c$ (choosing $n_\delta$); this bullet skips it.
- Corollary 8.1 is stated for $\limsup_{\sigma\downarrow0}$. Readings (R1), (R1′) and (R2) need the bound at all $\sigma<\sigma_0$. The sentence after the bullets supplies that, but for (R1) one should also say that B is applied at $\delta/2$ with posterior bad mass $\eta=\delta/2$.

**Fix.** One clause each, for example "with $\epsilon_n$ and $n_\delta$ chosen as in the next paragraph".

### Issue 4 (minor; wording). The unit-ball parenthesis overstates the proved amount

**Where.**

- §0.2 row 3: "(inputs of norm $\sqrt d$; for unit-ball inputs only for $c<\sqrt{\beta(\lambda)}/2$, Remark 5.4)", attached to "worse … by $\beta(\lambda)-o(1)$".
- The §6 erratum for RT §6.1: "for unit-ball inputs it shows this only when $c<\sqrt{\beta(\lambda)}/2$".

**Problem.** Under unit-ball inputs Remark 5.4 proves $\beta(\lambda)\bigl(1-\sqrt{2c/\sqrt{\beta(\lambda)}}\bigr)_+^2-o(1)$. That amount is $\beta(\lambda)-o(1)$ only when $c\to0$. §0.1 item 3 states it correctly ("gives a constant only when …").

A nit in the same place: the "What it shows" bullet names the property "for all laws with $d\le n$". Proposition 5.3 has $d=M\le n$ only when $\lambda\ge1$; write "$d\le n/\lambda$" or "$d\asymp n$".

**Fix.** "For unit-ball inputs it shows a constant amount only when $c<\sqrt{\beta(\lambda)}/2$, and $\beta(\lambda)-o(1)$ only when $c\to0$."

### Issue 5 (minor; scope wording). Say that the properties belong to one learner and that the conjecture is not refuted at depth two

**Where.** §1.4 and §0. The clearest case is Remark 5.5: "they therefore refute width-uniform formulations, which is how `problem-brief.md` §1 formalises the conjecture".

**Problem.** (P$_2$) and (P$_2^{o(1)}$) are properties of a single learner. The brief's conjecture lets us pick the learner ("We may pick whichever version of Bayesian learning is best"). At depth two the conjecture is not refuted in either formulation: B's tempered SP$_c$ has both in the clipped readings. The note implies this through §0.2, but never says it, and Remark 5.5's sentence can be read as refuting the brief's formalisation itself. `A-tight-conditioning-fails.md` §5.1 and §5.4 state it explicitly for depth $\ge3$.

**Fix.**

- Add one sentence to §0 or §1.4: "(P$_2$) and (P$_2^{o(1)}$) are properties of one learner. The conjecture asks that some Bayesian learner have them, and at depth two it is not refuted: B's tempered SP$_c$ has both (clipped readings)."
- In Remark 5.5, write "refute, for SP$_c$ with these $c$, …".

### Issue 6 (minor; cross-document consistency and bookkeeping)

- **(a) B's open list is now out of date.** B §0 "Still open" has "Depth two with $c=O(\mathrm{polylog}\,n)$", and §11 has "(iii) The negative side at depth two for $c=\mathrm{polylog}(n)$; known only from the red-team report". This note now refutes (P$_2$) for every $c\le\mathrm{polylog}(n)$ and the "$+o(1)$" formulation for $c\le\nu/\log n$. It also shows, from B's own Proposition 6.1, that the "$+o(1)$" formulation holds in the clipped readings for $\log^2n\ll c\le n^{1-\epsilon}$, which includes polylogarithmic $c$ such as $\log^3n$. B is final. So the README, or a sentence in this note's §0, should say that depth-two.md supersedes those two B items. Otherwise the published package calls the same $c$ "open" in one note and "refuted" or "holds" in another.
- **(b) Record-keeping.**
  - Once RT §5 becomes a pointer, the depth-two table of RT §5.4 (the $d=8,10$ runs, and the $c\in\{4,16\}$ sweep) is no longer in either document. Yet the §6 erratum for RT §0 item 6 quotes $\phi=0.396$ and $0.578$ from it, and RT Appendix A says "The runs are those in the §5 table". Carry the table into this note's §7 or into RT Appendix A.
  - In §9, logic 6 is "declined", not "rebutted"; the note agrees with the referee's mathematics.
  - The §8 preamble says "one sentence of C3 below is corrected there", but the corrected sentence is in §8 itself, and §9 only records it.
- **(c) Optional: the window in Remark 5.7 is not sharp.** Its upper end, $n/\log^2n$, comes from writing $g\equiv0$ as a width-one network with $E_*=d^2+d+2$. B Remark 6.5 with $w'=0$ ($E_*=0$, $U=0$; the form used in B Theorem 7.4(a)) gives $c/n+8D_n\sqrt{1/c+1/n}+5\sqrt{\ln(2/\delta)/(2n)}$ on the cube. So the clipped excess vanishes for $\log^2n\ll c=o(n)$. The stated window is correct, only narrower than what B gives.

---

## 5. What I re-derived or recomputed

- **(P$_2$) against A's (P$_L$).** (P$_2$) agrees with A §5.1's (P$_L$) at $L=2$, quantifier by quantifier. The (R1) $\sigma_0$ clause is consistent with A's list $d,n,N,D,g,\varepsilon,\delta$.
- **Non-vacuity of (P$_2^{o(1)}[\log_2n+C_0]$).** For the clipped readings: B Corollary 8.1 at $H=1$, with $\epsilon_n=(d(d+1)+4+8\sqrt2D_n)n^{-\beta}|_{d=\lfloor\log_2n+C_0\rfloor}+n^{-\beta/2}$ and $n_\delta$ from the $\delta$ term. For the unclipped readings: the Remark 5.7a combination; with $c\gg\sqrt n\log n$ and $c\le n^{1-\epsilon}$ every term vanishes.
- **The two refutations.** Corollary 5.2(b) refutes (P$_2^{o(1)}$) for every $\alpha$, since $N_0(a_d)=O(n\log^4n)$ and the width $\max\{N_0,\lceil n^\alpha\rceil\}$ is covered. Corollary 5.2(a)'s refutation of (P$_2$) passes the polynomial threshold, because $1/\varepsilon_d=\mathrm{poly}(d)$ when $c\le d^k$.
- **The open range.** It is not reached by B Proposition 9.1, which with the width-$n^\alpha$ chain needs $c\gg n^{1-3\alpha}$ at $L=2$. A Proposition 8.3 at $H=1$ adds nothing there: its training-point bound is of order $D_{d,1}/\sqrt c$, and its test bound is unclipped, of order $D_{d,1}\sqrt n/c$. `small-learner-width.md` Theorem 1 covers only small widths.
- **Remark 5.2a.** Its numbers are correct, and its restriction to (R1) and (R3) is correct.
- **Remark 5.3a.** The argument is correct, with the (R1′) addition of issue 2. The $b$-fraction extension and $M\ge n/(\lambda+1)$ are correct.
- **The fixed-$d$ row.** It matches A Proposition 5.2(c) with $t=1$: $8M=2^{d+3}$ and $Me^{-n/(8M)}=2^de^{-n/2^{d+3}}$.
- **Quotations.** Every quotation of RT text in §0.3 and §6 matches the staged `red-team.md` exactly: the Corollary 5.2 sentence, A3, the §6.1 bullet, the §7 item 3 sentence, the sentence after Proposition 5.3, the §5.4 sentence and the §5 heading.
- **Script.** `prop91_depth2.py` (issue 1) is deterministic, with seed 20261111. It runs in about 6 seconds, and a re-run reproduces `prop91_depth2.out` exactly.
