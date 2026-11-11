# Re-referee report, round 2 (scope and definitions), final candidate: `../research-notes/depth-two.md`

*Published record of a referee report on the final candidate of the note, made during finalization. Paths under `stage/` refer to the lead's unpublished working copies; the pre-revision text there is the version that the second-round referee reports reviewed, published as [`depth-two-first-version.md`](depth-two-first-version.md). The referee's scripts and outputs are in the `../checks/depth-two-referee-*` folder named below. Re-runs of the note's own scripts (`author_rerun/` and similar subfolders) are not published; the report says whether they reproduced the recorded outputs.*

**Lens.** Scope and definitions. I checked four things:

- whether the formulations that the note says SP$_c$ fails, (P$_2$) and (P$_2^{o(1)}[\phi]$) under the readings (R1), (R1′), (R2) and (R3), are well defined, satisfiable by some learner, and consistent with `../research-notes/problem-brief.md` §1 and with `../research-notes/B-tempered-likelihood.md` (B below) Corollary 8.1;
- whether every "refuted", "fails", "holds", "not refuted", "not settled" and "open" status is exactly right;
- whether the three major issues of the second-round logic report (`RT-depth2-logic-revised.md`, issues 1–3) are fixed;
- every statement in the note about what B proves at depth two, against B itself.

The header says that the material added after the check of the revision has not been reviewed, chiefly Remark 5.7a's paragraph on B's Proposition 9.1 and §7.1. I read those passages with particular care, together with every place that relies on them: §0, §0.2, §0.4–§0.5, the table of Remark 5.7a, the §6 errata and §9.

**What I read.**

- All of `../research-notes/depth-two.md` (the note).
- `../research-notes/problem-brief.md` §§1, 2 and 4.
- B: §0, §1, Lemmas 2.1, 2.3, 3.1 and 5.3, Corollary 3.2, Proposition 6.1 and the paragraph after it, Theorems 6.3 and 6.4, Remark 6.5, the opening of §7, Theorem 7.4, §7.5, Corollary 8.1, Proposition 9.1, the §9 Discussion, Remark 9.4 and §11.
- `../research-notes/A-tight-conditioning-fails.md` (A below): §5.1–§5.4, Proposition 8.2, and §8.3 (Proposition 8.3 and the paragraph after it).
- `../research-notes/small-learner-width.md` Theorem 1(c) and Remark 8.
- The staged `red-team.md`: §0 item 6, §2.3 A3, §5, §6.1, §6.4, §7 item 3 and Appendix A, to check each erratum against its target.
- The four referee reports on the note, the two reports of the check of the revision (scope, and logic and computation), and the author's `../checks/depth-two/prop91_l2.py` and `rt54_record.py` with their outputs.

**Script.** `../checks/depth-two-referee-scope-2/fixed_d_and_other_c.py`, with its output `fixed_d_and_other_c.out`, is in the staging folder next to this report. It should move to a `../checks/` subfolder if this report is published. It is deterministic (seed 20261111) and runs in about 30 seconds; a re-run reproduces the output byte for byte. It supports issues 1 and 3 and nit 8 (§5).

---

## Verdict: minor fixes

- **The three major issues of the second round are fixed** (§2).
- **Both formulations are well defined and non-vacuous in every reading.** They agree with the brief, with A's (P$_L$) and with B Corollary 8.1 (§1).
- **Every statement about what B proves at depth two is correct.** This includes the new paragraph on B's Proposition 9.1 and every consequence drawn from it in §0, §0.2, the Remark 5.7a table and the §6 errata (§3.1).
- **Every "refuted", "fails" and "holds" entry is correct, and so is the open range of the "$+o(1)$" formulation** (§3.2).

Three status statements are not exact. Each needs a qualifier or one added sentence (§4):

1. **Fixed $d$.** The statements "not refuted by the cube family" (§0.2, last row) and "at a fixed $d$ it is learned consistently" (§0, §0.2) hold only for $c=o(n)$, where the quoted bound vanishes. For $c$ of order $n$, near-minimizers fail on the cube itself at $d=1$. A says so after its Proposition 8.3 for $c\ge C_1n\approx5.8\,n$, and this report's script certifies excess at least $0.05$ at $c=n/10$. The same row gives B's two-point failure only for $c\ge n/4$, while the first row has it, correctly, in dimension $1$ for every $c\ge n^{1-o(1)}$.
2. **One learner.** §1.4 says that at depth two the conjecture "is not refuted in either formulation" without naming $\phi$. For $\phi(n)\ge n/b$, Remark 5.3a proves that no learner has (P$_2^{o(1)}[\phi]$).
3. **"Other $c$ are not settled here"** (§0.2, first row). The note's own bound (5.7a) gives (P$_2$) in the clipped readings for every $c$ between $n^a$ and $n^{1-a}$, for a fixed $a>0$. The proof of Corollary 5.2(a) needs only $c_d=2^{o(d)}$, so (P$_2$) fails for every $c\le n^{o(1)}$, not only for $c\le\mathrm{polylog}(n)$. In the clipped readings, the depth-two status of (P$_2$) is then complete, except for sequences that move between ranges.

None of the three changes a theorem. The remaining points are nits (§4, items 4–9).

---

## 1. Answers to the focus questions

| Question | Answer |
|---|---|
| Are the formulations well defined? | **Yes.** (P$_2$) is the brief's §1 property and A §5.1's (P$_L$) at $L=2$, quantifier for quantifier, with learner widths $N\ge m$. (P$_2^{o(1)}[\phi]$) has the order ∃$\alpha$ ∃$(\epsilon_n)$ ∀$\delta$ ∃$n_\delta$ ∀$n\ge n_\delta$ ∀$d\le\phi(n)$ ∀$D$ ∀$N\ge n^\alpha$, followed by the reading's quantifier on $\sigma$; $\mathcal G^{(\alpha)}_n$ is B's class. The readings fix the output, the quantifier on $\sigma$ ("$\sigma_0$ may depend on everything except the sample") and how probabilities are taken: Tonelli for (R1), outer probability for (R3). |
| Are they non-vacuous? | **Yes, in every reading.** (P$_2$): the clipped readings by B Theorem 6.3 (any $\theta\in(0,1)$ at $H=1$), the unclipped ones by B Theorem 6.4 ($\theta<1/2$), with B's sample-free $\sigma_0$. (P$_2^{o(1)}[\log_2n+C_0]$): the clipped readings by B Corollary 8.1 at $H=1$, $\alpha<1/8$, with Remark 5.7a's choice of $\epsilon_n$ and $n_\delta$; the unclipped ones only by Remark 5.7a's combination, for $\sqrt n\log n\ll c\le n^{1-\epsilon}$, which I re-derived. One learner, SP$_{n^{1/2}}$, has both in the clipped readings: $\theta=1/2$ in Theorem 6.3, and $\alpha=1/16$ in Corollary 8.1 gives $\theta=(1+8\alpha)/3=1/2$ and $\beta=\min\{1/4,1/4\}=1/4$. The zero learner fails (P$_2^{o(1)}$) on Remark 5.2a's law, so the property is not trivially satisfied either. (P$_2^{o(1)}[\phi]$) with $\phi\ge n/b$ is unsatisfiable, and the note treats it so. |
| Consistent with the brief and with B Corollary 8.1? | **Yes.** The learner widths are $N\ge m$ in (P$_2$) and $N\ge n^\alpha$ in (P$_2^{o(1)}$), and B Corollary 8.1 is quoted exactly ("simultaneously for all learner widths $N\ge n^\alpha$"). The note's property asks width by width and only for $d\le\phi(n)$, so B's statement, which is simultaneous in $N$ and holds for every $d$, implies it. The brief calls the two formulations "equivalent"; the note shows, correctly, that they differ at depth two ($c=\log^3n$). |
| Is every status claim exactly right? | Every "refuted", "fails", "holds" and "open" entry is right (§3.2). Three statements are not exact: the fixed-$d$ statements (issue 1), §1.4's "either formulation" (issue 2) and "Other $c$ are not settled here" (issue 3). |
| Are the three second-round major issues fixed? | **Yes** (§2). |
| Are the statements about what B proves at depth two right? | **Yes, all of them** (§3.1). |

---

## 2. The three issues of the second-round logic report

**Issue 1 (the learner-width quantifier): fixed.**

- §1.4 asks for the bound at every learner width $N\ge n^\alpha$, and its "Learner widths" paragraph explains why.
- Corollary 5.2(b) and its proof use the width $N=\max\{N_0(a_d),\lceil n^\alpha\rceil\}$.
- Remark 5.2a records the width-one example. I checked its numbers: $\Delta=0.64486$ and $\Delta^2/6=0.06931$.
- No passage still states (P$_2^{o(1)}$) with $N\ge1$. The remaining "$N\ge1$" occurrences are historical (§0.4 item 1, §1.4, Remark 5.2a, §9), concern Proposition 5.3's construction (§0.1, §0.2, Proposition 5.3), or concern Remark 5.7's bound against the width-one zero competitor; all are correct.

**Issue 2 (uniformity over $d\asymp n$): fixed.**

- I checked every occurrence of "refut" in the note. No sentence says that Proposition 5.3 refutes a formulation.
- §0, §0.1 item 3, §0.2 row 3, the remarks after Proposition 5.3, Remark 5.8 item 4 and the errata for RT §0 item 6, RT §6.1 and the sentence after RT Proposition 5.3 all describe it as a comparison with the Bayes-optimal zero network.
- Remark 5.3a's impossibility proof is correct. This includes the new (R1′) step, where the $q_j$ depend on $\theta_j$ alone, and the "One law" step, which takes the minimum of $\sigma_0(\theta)$ over the $2^n$ sign vectors.
- The unit-ball wording matches Remark 5.4.

**Issue 3 (the open range): fixed.**

- The open range of the "$+o(1)$" formulation is $c\log n\to\infty$ with $c=O(\log^2n)$ for the clipped readings, or $c=O(\sqrt n\log n)$ for the unclipped ones. §0, §0.2, Corollary 5.2(c), Remark 5.7a, Remark 5.8 and the §6 errata all state it this way.
- Remark 5.7a settles the range above it positively, by combining B's statements, and the far end negatively, by B's Proposition 9.1.
- Nothing I know settles the open range itself:
  - B's Proposition 9.1 needs competitor weights of order $\sqrt{n/c}$. Even at the top of the open range, $c=O(\sqrt n\log n)$, that reaches $\mathcal G^{(\alpha)}_n$ only for $\alpha$ of at least about $1/4$ (width one) or $1/6$ (B's width-$n^\alpha$ chains of Lemma 9.2), and lower in the range it needs larger $\alpha$, while (P$_2^{o(1)}$) asks only for some $\alpha>0$.
  - A's Proposition 8.3 at $H=1$ gives a seen-atom bound of order $D/\sqrt c$ and an unclipped test bound of order $D\sqrt n/c$. Both vanish only above the open range.
  - `small-learner-width.md` treats only small learner widths.

The remaining second-round issues (logic 4–9, computation 1–7 and the script remark) are resolved as §9 of the note says; I spot-checked each place. Logic 6, which was optional, is declined, and the stated reason is accurate.

---

## 3. Audit tables

### 3.1 Statements about what B proves at depth two

| Statement in the note | Where | B source | Verdict |
|---|---|---|---|
| SP$_c$ with $c=n^{1/2}$ has (P$_2$) and (P$_2^{o(1)}[\log_2n+C_0]$) in the clipped readings (Theorem 6.3 with $\theta=1/2$, Corollary 8.1 with $\alpha=1/16$) | §0; §1.4; §9, row S5 | Thm 6.3 ("any $\theta\in(0,1)$ when $H=1$"); Cor 8.1 | correct |
| Theorem 6.3 at $H=1$: excess $(E_*+1)n^{-\theta}+8\sqrt2D_nn^{-(1-\theta)/2}+(4+(U+1)^2)\sqrt{\ln(2/\delta)/(2n)}$ at every $N\ge m$, with a polynomial sample size; Theorem 6.4 does the same unclipped for $\theta<1/2$ | Rem. 5.7a; §0.2 row 1 | Thm 6.3 and its $n_0$; Thm 6.4 ($\theta<1/L$) | correct |
| Corollary 8.1 at $H=1$: decays only for $\alpha<1/8$ (B allows $\alpha<1/4$); $c=n^{(2-8\alpha)/3}\in(n^{1/3},n^{2/3})$; $\Xi_n$ and $\beta$; stated for the $\limsup_{\sigma\downarrow0}$; "simultaneously for all learner widths $N\ge n^\alpha$" | Rem. 5.7a; §1.4; §0.4 item 1 | Cor 8.1 and its proof | correct; quotation exact |
| B's events depend on neither $\sigma$ nor $N$; $\sigma_0(N,n,c,d,H,\eta)$ does not depend on the sample; bad posterior mass at most $\eta$, clipped Gibbs risk at most the bound plus $4\eta$; the unclipped correction comes from Lemma 3.1 | Rem. 5.7a, "Passage to the readings" | Thm 6.3 ("not depending on $N$ or $\sigma$"); the paragraph after Prop 6.1; Lemma 3.1; Cor 3.2 | correct |
| Proposition 6.1 holds for every $c>0$ with $K=n/c+1$, Lemma 5.3 for every $K>0$; (5.7a) is not displayed in B | Rem. 5.7, 5.7a | Prop 6.1; Lemma 5.3 | correct |
| The unclipped bound has order $D_n\sqrt n/c$ | Rem. 5.7, 5.7a | Lemma 5.3(b); the unclipped part of Prop 6.1 | correct |
| §7.5 item 3: vanishing excess on the noisy cube for $c\gg D_n^2$, "and $c=o(n)$" (added, with the reason); no negative side on the noisy cube at depth two, since Lemma 7.2 needs $H\ge2$; B cites RT Theorem 5.1, which is Theorem 5.1 of the note | Rem. 5.7a; §0 | §7.5 item 3; Remark 6.5 with $w'=0$ | correct |
| Theorem 7.4 and §7.5 items 1–2 assume $H\ge2$ | Rem. 5.7a | opening of §7 ("Throughout this section $H\ge2$") | correct |
| Proposition 9.1(a),(b) is stated for every $L\ge2$, $c>0$ and $n$; the §9 Discussion repeats it "for every $c$ and $n$ with $n/c\ge2L$"; $\eta_0=\delta_0K/2$ is B's $\eta$ at $L=2$; (a) covers the four listed $\liminf$ predictors; (b) gives weights at most $1.5\,\delta_0^{-1/2}$ when $\delta_0\le1/2$ | Rem. 5.7a | Prop 9.1; §9 Discussion | correct; quotation exact |
| B's proof bounds the $\sigma$-corrections by $\Pi_\sigma(\mathcal N_1^c)$ and $\mathbb E_{\Pi_\sigma}[(1+F)\mathbf 1_{\mathcal N_1^c}]$, which are uniform in the sample by Lemma 3.1; $\operatorname{clip}\bar z_\sigma$ follows because clip is 1-Lipschitz | Rem. 5.7a, "Large $c$" | proof of Prop 9.1(a); Lemma 3.1 | correct |
| Remark 9.4: rescaling to unit range removes the shrinking two-point laws | Rem. 5.7a | Rem 9.4 | correct |
| B's open items "Depth two with $c=O(\mathrm{polylog}\,n)$" (§0) and "(iii) The negative side at depth two for $c=\mathrm{polylog}(n)$; known only from the red-team report" (§11) | §0 | §0; §11 | quotations exact; the supersession is right, and on the (P$_2$) side the note proves more than it says (issue 3) |
| "the tempered SP$_c$ that `B-tempered-likelihood.md` proves consistent" | Rem. 5.2a | Thm 6.3 | correct |
| Remark 5.7's bound was refereed in `B-logic.md`, `B-computation.md` and `B-scope.md` | Rem. 5.7 | §12 | correct |

### 3.2 Status claims

| Status claim | Where | Verdict |
|---|---|---|
| (P$_2$) is refuted for every $0<c\le\mathrm{poly}(d)$, under (R1), (R1′), (R2) and (R3), at every $N\ge N_0$ | §0; §0.1 item 2; §0.2 row 1; Cor. 5.2(a) | correct; not sharp: the same proof covers every $c\le n^{o(1)}$ (issue 3) |
| (P$_2$) fails for every $c\ge n^{1-o(1)}$ in dimension $1$, and for $c\ge n/4$ on one fixed law, under every reading and at every width | §0; §0.2 row 1; Rem. 5.7a; §0.5 item 1 | correct; the fixed-law case extends to every $c\ge n/k$ (nit 8) |
| (P$_2$) holds for the clipped readings at $c=n^{1-\theta}$, $\theta\in(0,1)$, and for the unclipped ones at $\theta<1/2$ | §0.2 row 1 | correct |
| "Other $c$ are not settled here" | §0.2 row 1 | not exact (issue 3) |
| (P$_2^{o(1)}[\log_2n+C_0]$) is refuted for $c\le\nu/\log_2n$, for every $\alpha>0$ and every $\epsilon_n\to0$, under all readings, with excess $\Gamma_\lambda(\nu)$, and $\beta(\lambda)$ when $c\log n\to0$ | §0; §0.1 item 2; §0.2 row 2; Cor. 5.2(b) | correct |
| It fails for every $c\ge n^{1-o(1)}$, for every $\phi\ge1$, under every reading and at every learner width | §0; §0.2 row 2; Rem. 5.7a | correct |
| It holds for the clipped readings when $\log^2n\ll c\le n^{1-\epsilon}$, and for all readings when $\sqrt n\log n\ll c\le n^{1-\epsilon}$ | §0; §0.2 row 2; Rem. 5.7a | correct (a combination of B's statements, which I re-derived) |
| It is open when $c\log n\to\infty$ and $c=O(\log^2n)$ (clipped) or $c=O(\sqrt n\log n)$ (unclipped); this includes $c=1$ | §0; §0.2; Cor. 5.2(c); Rem. 5.7a, 5.8; §6 | correct (§2) |
| Sequences that fit no row are not classified | Rem. 5.7a; §0 | correct |
| "$+o(1)$" uniform over $d\le n$, or over $d$ up to a fixed fraction of $n$, is false for every learner | §0.2 row 3; Rem. 5.3a | correct |
| Proposition 5.3 refutes no formulation; SP$_c$ with $c=o(\sqrt n)$ is worse than the zero network by $\beta(\lambda)-o(1)$; under unit-ball inputs a constant gap only for $c<\sqrt{\beta(\lambda)}/2$ | §0; §0.1 item 3; §0.2 row 3; §5; §6 | correct |
| Fixed $d$: "not refuted by the cube family"; "learned consistently" | §0; §0.2 | not exact for $c=\Omega(n)$ (issue 1) |
| At depth two the conjecture is not refuted in either formulation | §0 ($\phi$ named); §1.4 ($\phi$ not named) | correct as §0 states it; §1.4 needs $\phi$ (issue 2) |
| With $N\ge1$ the property would fail for every learner under (R1) and (R3) | Rem. 5.2a | correct; it also fails under (R1′), but not necessarily under (R2) |
| Nothing is refuted at widths below $N_0$ for the stated $c$; clipped near-minimizers succeed below about $n/\log^2n$ on the cube family | Rem. 5.5; §1.4; §0 | correct |
| The progressive-mixture predictor is not covered | Rem. 5.6 | correct |
| Proposition 5.3 under unit-ball inputs is open for $c\ge\sqrt{\beta(\lambda)}/2$ | Rem. 5.4; Rem. 5.8 item 4 | correct; one sentence of Remark 5.4 is worded loosely (nit 5) |
| The two formulations differ at $c=\log^3n$ | Rem. 5.7a; §6 (A3) | correct |
| What the runs of RT §5.4 certify | §7.1; §6 | correct for that sample at the run's width (nit 6) |

---

## 4. Issues, most severe first

### Issue 1 (minor; status at fixed $d$). "Learned consistently" and "not refuted by the cube family" need $c=o(n)$

**Where.**

- §0.2, last row: "**not refuted** by the cube family. At every width its excess is at most $(8\cdot2^d/\delta+4c)/n$ … For $c\ge n/4$, (P$_2$) restricted to $d=1$ fails on B's two-point law (first row)".
- §0, the "Not covered" bullet: "a fixed input dimension, at which the cube family is learned consistently (§0.2; for $c\ge n/4$, B's two-point law defeats SP$_c$ already in dimension $1$, Remark 5.7a)".
- §0.2, "Input dimension": "At a fixed $d$ it is learned consistently (last row of the table)."

**Problem.**

- **The cube family itself defeats (R3) when $c$ is of order $n$.** The quoted bound, A's Proposition 5.2(c) with $t=1$, vanishes if and only if $c=o(n)$. When $c$ is of order $n$, the slack $1$ in $\mathcal N_1$ is of the order of $F_c$'s whole range.
  - $F_{c,S}=\kappa_N+(\mathcal R+W)/c\ge W/c$, so $\min F_{c,S}\ge W/c$. Hence every $w$ with $\kappa_N(w)+\mathcal R(z_w)/c\le1$ lies in $\mathcal N_1$, at every width.
  - A constant output $a$ costs $\kappa_N=d\,b^2+a^2/\tanh^2b$ at every width. At $d=1$, $c=n/4$ and $a=0.2$ this is $0.43$, and $\kappa_N+\mathcal R/c=0.58\le1$. The test excess is $a^2=0.04$ (script part (2), explicit networks at widths $1$, $5$ and $64$).
  - Over 200 samples per setting and $n\in\{10^3,10^4,10^5\}$ (script part (1)), such near-minimizers have certified excess at least $0.050$ at $c=n/10$, $0.085$ at $c=n/4$ and $0.14$ at $c=n$ when $d=1$. At $d=3$ the values are at least $0.024$ and $0.043$ for $c=n/10$ and $c=n/4$ (at $n=10^3$; $0.034$ and $0.049$ at $n=10^5$). They do not shrink as $n$ grows.
  - The same computation works for every $c\ge n/k$ with $k$ fixed. At $d=1$ the constant output $a$ costs $2a+O(a^2)$, so some $a$ of order $k^{-1/2}$ is admissible, and the excess $a^2$ is of order $1/k$, whatever $n$.
  - A records this itself, in the paragraph after its Proposition 8.3: "The condition $\vartheta>0$, which makes $c=o(n)$, cannot be dropped at a fixed slack $t$." There the excess "does not depend on $n$" once $c\ge C_tn$, where $C_1=2(1+\sqrt{1/2})^2\approx5.83$ at slack $t=1$.

  So under (R3) and $c=\Omega(n)$, the cube family refutes (P$_2$) restricted to $d=1$, and "not refuted by the cube family" is false there. (R1), (R1′) and (R2) are not affected. As $\sigma\downarrow0$ the posterior concentrates near $\operatorname{argmin}F_c$, whose energy is at most $G/c=O(2^d/n)$.
- **The two-point failure is understated.** Row 4 gives it only for $c\ge n/4$. Row 1 has it, correctly, in dimension $d=1$ for every $c\ge n^{1-o(1)}$, with laws that change with $n$. The fixed-law version also holds for every $c\ge n/k$ with $k$ fixed (nit 8).
- **The bound depends on $1/\delta$.** Its confidence dependence is $1/\delta$, not $\log(1/\delta)$. It therefore shows consistency, and that the cube family does not refute the "$+o(1)$" version at a fixed $d$ when $c=o(n)$. For (P$_2$) restricted to a fixed $d$, it does not give the $\log(1/\delta)$ sample size, so there "not refuted" means only that no refutation is known.

**Fix.**

- Row 4: "For $c=o(n)$, not refuted by the cube family: at every width its excess is at most … (A Prop. 5.2(c), $t=1$), so it tends to $0$ in probability. For $c$ of order $n$, near-minimizers fail on the cube itself at $d=1$ (A §8.3), and every reading fails on one fixed two-point law (B Prop. 9.1). For $c\ge n^{1-o(1)}$, (P$_2$) restricted to $d=1$ fails on B's two-point laws (first row)."
- §0 and §0.2, "Input dimension": write "learned consistently when $c=o(n)$".

### Issue 2 (minor; wording). §1.4, "One learner", does not name $\phi$

**Where.** §1.4: "(P$_2$) and (P$_2^{o(1)}[\phi]$) are properties of one learner $\mathsf A$. … and at depth two the conjecture is not refuted in either formulation (§0)."

**Problem.** For $\phi(n)\ge n/b$, Remark 5.3a proves that (P$_2^{o(1)}[\phi]$) fails for every learner. In that formulation the conjecture is false (trivially, but false), and §0.2 row 3 says so. "Not refuted in either formulation" is right for $\phi(n)=\log_2n+C_0$, which §0 names but this sentence does not.

**Fix.** "… and at depth two the conjecture is not refuted in either formulation with $\phi(n)=\log_2n+C_0$ (§0); with $\phi(n)\ge n/b$ no learner has (P$_2^{o(1)}[\phi]$) (Remark 5.3a)."

### Issue 3 (minor; status). "Other $c$ are not settled here" understates what the note settles for (P$_2$)

**Where.** §0.2 row 1, last sentence. §0 bullet 1 and Corollary 5.2(a) also state the failure only for $c\le\mathrm{poly}(d)$.

**Problem.**

- **Positive side.** (5.7a), derived in Remark 5.7a, holds for every $c>0$. Suppose $n^a\le c(n)\le n^{1-a}$ for a fixed $a>0$. Then its right side is at most
  $$(E_*+1)n^{-a}+8\sqrt2\,D_nn^{-a/2}+\bigl(4+(U+1)^2\bigr)\sqrt{\ln(2/\delta)/(2n)},$$
  and the sample-size arithmetic of B's Theorem 6.3 gives a polynomial $n_0$, raised if necessary to the point from which $n^a\le c(n)\le n^{1-a}$ holds. So SP$_c$ has (P$_2$) in the clipped readings for every such $c$, not only for $c=n^{1-\theta}$. One example is $c=\sqrt n\ln n$: at $d=5$, the least $n$ at which the bound is at most $\varepsilon$ grows like $\varepsilon^{-4}$ (script part (4)). The unclipped variant gives (P$_2$) for $n^{1/2+a}\le c\le n^{1-a}$.
- **Negative side.** The proof of Corollary 5.2(a) uses $c\le d^k$ in two places only.
  - It needs $c(dF_d+1)/(M\vartheta_c)\to0$, which requires only $c^2d^5=o(2^d)$.
  - It uses "$1/\varepsilon_d$ is at most a polynomial in $d$" only to get $n\ge\mathsf p(d,1,1,1/\varepsilon_d,\log(1/\delta))$. If $c_d=2^{o(d)}$, then $1/\varepsilon_d=3(18dc+1)^2/\gamma=2^{o(d)}$, so $\mathsf p(\dots)=2^{o(d)}<\lambda2^d$ eventually.

  On the event, $\Psi_{\rm cor}/(\gamma\vartheta_c^2)\to1$. Script part (5) evaluates the worst case of §4's formula. For $c=2^{\sqrt d}$ and $c=d^{\ln d}$ the ratio is at least $0.987$ from $d=256$ on and tends to $1$, while $\log_2(1/\varepsilon_d)/d$ falls to $0.04$–$0.06$ at $d=4096$. For the contrast case $c=n^{1/3}$ it stays near $2/3$. So (P$_2$) fails, under every reading, for every $c(n)\le n^{o(1)}$, for example $c=2^{\sqrt{\log n}}$, and not only for $c\le\mathrm{polylog}(n)$.
- **The resulting picture.** With B's Proposition 9.1 for $c\ge n^{1-o(1)}$, in the clipped readings (P$_2$) at depth two holds when $c$ is polynomially separated from $1$ and from $n$, and fails when $c\le n^{o(1)}$ or $c\ge n^{1-o(1)}$. This is the $H=1$ case of B's sharp threshold $\theta=1/H$. Two cases remain unclassified: sequences that move between these ranges, and, for the unclipped readings, $n^a\le c\le n^{1/2+o(1)}$.

So "Other $c$ are not settled here" is not exact. It also leaves open, for the reader, that the (P$_2$) transition at depth two might lie at polylogarithmic $c$, which is what B §7.5 item 3 suggests ("any transition lies at $c=O(\mathrm{polylog}\,n)$"). In the (P$_2$) sense it lies above every polylogarithm (nit 4).

**Fix.**

- At least, replace the sentence by: "By (5.7a), (P$_2$) also holds in the clipped readings whenever $n^a\le c\le n^{1-a}$ for a fixed $a>0$ (unclipped readings: $n^{1/2+a}\le c\le n^{1-a}$). Not classified here: $c$ between $\mathrm{polylog}(n)$ and $n^{o(1)}$, and sequences that move between ranges."
- Better, add a remark that extends Corollary 5.2(a) to $c_d=2^{o(d)}$, with the two lines above, and then state the complete picture. This strengthens a refereed statement, so mark the remark as not refereed.

### Nits

4. **Two meanings of "the transition" at depth two (optional).**
   - The replacement for RT §7 item 3 says "the transition lies between $c\approx1/\log n$ … and $c\approx\log^2n$ …". B §7.5 item 3, which the note cites, says "So at depth two any transition lies at $c=O(\mathrm{polylog}\,n)$". Both describe where the excess on the cube changes from constant to vanishing, that is, the transition of the "$+o(1)$" formulation.
   - The surrounding RT item ("Deeper networks need more tempering", $c^\star\approx n^{1-1/H}$) is about the tempering that a polynomial sample bound needs. At depth two that is different: (P$_2$) fails at every $c\le\mathrm{polylog}(n)$, and indeed at every $c\le n^{o(1)}$ (issue 3).
   - Fix: add to the RT §7 item 3 replacement "For the polynomial-sample version, every $c\le\mathrm{polylog}(n)$ fails (Corollary 5.2(a)), and $c=n^{1-\theta}$ works." The paragraph "Relation to the open items of B" could note the same about B §7.5 item 3.
5. **Remark 5.4, "What is not settled".** "For $c$ of order one, in particular $c=1$, the proof gives nothing under unit-ball inputs" is false for constants below $\sqrt{\beta(\lambda)}/2\approx0.348$; at $c=0.1$ the proof gives $0.104$. Write "For $c\ge\sqrt{\beta(\lambda)}/2$, in particular $c=1$", as Remark 5.8 item 4 does.
6. **Width qualifier in the errata on the runs of RT §5.4.**
   - The replacement for RT §0 item 6 says "Every near-minimizer leaves at most $(1-\phi)G+c$". That holds at the run's width, and at its integer multiples, where depth-two clones have the same energy. It need not hold at every width; §7.1 says "at the run's width".
   - In the replacement for RT Appendix A, "at the run's width" is attached to the clause about networks whose objective is at most the one found, which holds at every width. It belongs to the near-minimizer clause. Move it.
7. **"$n/c=n^{o(1)}$".** Remark 5.7a's first consequence and its table row write "$n/c=n^{o(1)}$, that is $c\ge n^{1-o(1)}$". Read two-sidedly, $n/c=n^{o(1)}$ excludes $c\ge n^{1+\epsilon}$, which the argument covers ($K\le2$ there). Write "$n/c\le n^{o(1)}$".
8. **Fixed law (optional).** The fixed-law failure holds for every $c\ge n/k$ with $k$ fixed, not only for $k=4$. Then $K\le k+1$, and the law $D_{1/(k+1)}$ with the competitor of first-layer row $(0,\sqrt{k+1})$ and readout $1/\tanh(1/\sqrt{k+1})$ gives every reading test MSE at least $1/4$, against $0$ (script part (3)). So (P$_2$) fails on one fixed law for every $c=\Omega(n)$.
9. **Record.**
   - After this check, the header sentence that the new material "has not been reviewed" needs updating.
   - §9 labels the points of the two checks S1–S6 and LC1–LC9 but gives no path to their reports. When those reports are published, cite them, as B cites `../verification/B-revision-check-*.md`.

---

## 5. What I re-derived or recomputed

- **The formulations.** (P$_2$) against brief §1 and A §5.1's (P$_L$): the same quantifiers, and the (R1) clause on $\sigma_0$ matches A's list. (P$_2^{o(1)}[\phi]$) against B Corollary 8.1: the same class $\mathcal G^{(\alpha)}_n$ and the same learner-width bound.
- **Non-vacuity.** For SP$_{n^{1/2}}$: B Theorem 6.3 with $\theta=1/2$. For Corollary 8.1 with $\alpha=1/16$: $\theta=(1+8\alpha)/3=1/2$, $c=n^{(2-8\alpha)/3}=n^{1/2}$ and $\beta=1/4$.
- **Remark 5.7a, positive side.**
  - $\Xi_n$ at $H=1$: $2L=4$, $8(2/H)^{H/2}=8\sqrt2$, and $D_n$ without the $(H-1)/2$ term.
  - The choice of $\epsilon_n$ and $n_\delta$, with $\epsilon_n$ independent of $\delta$.
  - (5.7a) and its class version: $E_*+1\le(d(d+1)+4)n^{4\alpha}$ and $4+(U+1)^2\le8n^{4\alpha}$. The three rates.
  - The unclipped variant, of order $D_n\sqrt n/c$, with a $\delta$-term of order $\sqrt n/c$.
  - The passage to the readings: bad posterior mass at most $\eta$, an added $4\eta$, and $(1-\delta/2)^2\ge1-\delta$.
- **B's Proposition 9.1 at $L=2$.**
  - The Lipschitz step $\lvert z(x)-z(x')\rvert\le(\kappa_N/2)\lvert x-x'\rvert$, with $\kappa_N\le K$.
  - The choice $\delta_0=\min\{1/2,1/K\}$ gives $\omega^2=1/\delta_0\ge2$ and $\eta_0\le1/2$; also $v\le1.5\,\omega$.
  - For $D_{1/5}$: row $(0,\sqrt5)=(0,2.2361)$ and readout $2.3832$, as in `prop91_l2.out`.
  - "From $n=10^{16}$" for $c=n/\ln n$ and $\alpha=0.05$ refers to the competitor's actual largest weight $v\approx\sqrt K$, which is $6.20$ against $n^{0.05}=6.31$ there. The stated bound $1.5\sqrt K$ would enter $\mathcal G^{(\alpha)}_n$ only later. The sentence, which speaks of "the competitor", is right.
  - In every consequence drawn in §0, §0.2, Remark 5.7a and §6, the law may depend on $n$, as both properties allow (compare A's Corollary 7.2b); the competitor's weight bound is $n^{o(1)}$; and $d=1\le\phi(n)$.
- **Remarks 5.2a and 5.3a**, including the (R1′) and "One law" steps.
- **The open range**, against B, A §8.3 at $H=1$ and `small-learner-width.md` (§2).
- **§7.1's certified values** against `rt54_record.out`: $0.3958$ and $0.5777$; $0.3894$ and $0.5761$; $0.0146$ and $0.0325$.
- **Quotations.** B §0 ("Still open"), §11 (iii), Corollary 8.1, Proposition 9.1, the §9 Discussion and the opening of §7; brief §1; and the staged `red-team.md` §0 item 6, A3, §6.1, §6.4, §7 item 3 and Appendix A. All are exact.

**Script** (`../checks/depth-two-referee-scope-2/`, staging folder):

| Part | What it checks | Result (`fixed_d_and_other_c.out`) |
|---|---|---|
| (1) | Cube family, $d\in\{1,2,3\}$, $n\in\{10^3,10^4,10^5\}$, $c/n\in\{0.1,0.25,1,4\}$, 200 samples each: the largest constant output $a$ with $\min_b\kappa_N+\mathcal R(a)/c\le1$, which is a near-minimizer at every width since $\min F_c\ge W/c$; certified excess $a^2$; A's bound for comparison | minimum over samples, for $c/n=0.1,0.25,1,4$: at $d=1$, $0.050$, $0.085$, $0.143$, $0.174$ ($n=10^3$; slightly larger at $10^4$ and $10^5$); at $d=3$, $0.024$, $0.043$, $0.063$, $0.072$ ($n=10^3$) and $0.034$, $0.049$, $0.066$, $0.072$ ($n=10^5$); A's bound is at least $1$ for $c\ge n/4$ |
| (2) | Explicit networks for one sample ($d=1$, $n=10^4$, $c=n/4$, $a=0.2$) at widths $1$, $5$ and $64$: $F$ computed from the sample | $F-W/c=0.585\le1$, test excess $0.040$, clipped or not |
| (3) | B Proposition 9.1 on one fixed law for $c\ge n/k$, $k\in\{4,10,100,1000\}$ | $\eta_0\le1/2$, learner test MSE at least $1/4$, exact fit by the stated competitor |
| (4) | (5.7a) with the zero competitor at $c=\sqrt n\ln n$, $d=5$, $\delta=0.05$ | bound at most $\varepsilon$ from $n=2^{30},2^{33},2^{37},2^{41},2^{45}$ for $\varepsilon=0.2,\dots,0.0125$: $n_\varepsilon$ grows like $\varepsilon^{-4}$ |
| (5) | The argument of Corollary 5.2(a) beyond $\mathrm{poly}(d)$: §4's worst case of $\Psi_{\rm cor}$ ($\lambda=1$, $a=1/d$) divided by $\gamma(1)\vartheta_c^2$, and $\log_2(1/\varepsilon_d)/d$ | $c=2^{\sqrt d}$: ratio $0.988$ at $d=256$, $0.999$ at $d=4096$, with $\log_2(1/\varepsilon_d)/d$ down to $0.040$. $c=d^{\ln d}$: ratio $0.988$ to $0.999$, down to $0.058$. Contrast $c=n^{1/3}$: $\log_2(1/\varepsilon_d)/d$ stays near $0.68$ |
