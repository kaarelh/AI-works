# Second check of the revised `small-learner-width.md`

*Published record of a check of the revised note, made during finalization. Paths under `stage/` refer to the lead's unpublished working copies; the pre-revision text there is the version that the second-round referee reports reviewed, published as [`small-learner-width-first-version.md`](small-learner-width-first-version.md). This check's scripts and outputs are in the `../checks/revision-check-*` folder named below. Re-runs of the note's own scripts, which some reports keep in a `rerun/` subfolder, are not published; each report says whether they reproduced the recorded outputs.*

**Verdict: minor fixes.** All issues from the two second-round reports, and all five points from the first revision check (`small-learner-width-revision-check-1.md`), are resolved by correct fixes. None was rebutted. Every changed statement and number I re-derived is right. The three scripts reproduce their `.out` files byte for byte, and every quoted number matches its source file.

One minor wording problem remains (§2 item 1). §7.4 calls A's present wording A's "final text", but that becomes false once A adopts the wording that §7.4 itself proposes. Four optional nits and two notes for the lead follow. None of them affects Lemmas A–F, Theorem 1, Corollaries 2–3, Theorem 4 or the corrected clause.

## 1. What was checked

- **Diff and reports.**
  - I compared the pre-revision text (`stage/small-learner-width.md`, which both second-round referees read) with the revised note, region by region.
  - I checked the changes against both second-round reports: logic m1–m12 plus the §2.7 probe, and computation 1–7 plus the §2.10 observation.
  - I also checked them against the five points of `small-learner-width-revision-check-1.md`.
- **Scripts.**
  - Re-run in `../checks/revision-check-small-learner-width-2/rerun/`, they took 32 s, 4 s and 1 s. The outputs are identical to `checks/small-learner-width/*.out`.
  - Against the pre-revision copies (in the lead's unpublished working folder, `out/RT_width_fixed_scripts/`; the revised scripts are in `../checks/small-learner-width/`), the scripts differ only in docstrings, printed labels and the new part (6). Every docstring item number is current.
- **Independent script.** `../checks/revision-check-small-learner-width-2/indep_check_r2.py` (output in the `.out` file next to it) is coded from the note's definitions. It checks:
  - (a) that $\sup_{t\ge1}t^{-\alpha}\sqrt{\ln2t}=2^\alpha/\sqrt{2e\alpha}$, with the maximizer $t_*=e^{1/(2\alpha)}/2>1$. Over 208 values of $\alpha\in(0,\frac14]$ the agreement is $10^{-50}$.
  - (b) that $\mathrm{Exc}\le(5.2)\le C_{L,\alpha,\delta}n^{2\alpha-1/2}$ on 20,000 random cases with $1\le N\le2n^\alpha$, $1\le d\le n^\alpha$, $n\le10^{300}$ and $H\le10$. The maxima are $0.634$ and $0.996$, and $\mathrm{Exc}/(Cn^{2\alpha-1/2})\le0.413$. This also covers the §0 "more generally" sentence.
  - (c) that $\mathrm{Dev}_N\ge4$ on the cube family, both at $N^*=\sqrt{2n/((H-1)\ln2n)}$ (minimum $7.09$) and at A's $N_0$ (minimum $1.3\cdot10^6$). It also checks that $\mathrm{Dev}_N$ increases in $N$.
  - (d) A's (4.3), recomputed from A's definitions:
    - with $a=1/d$, the certified excess is $0.4493$, $0.4619$ and $0.4710$ at $d=40,60,100$;
    - $N_0/(n\log_2^2n)=4.48\cdot10^5$ at $d=100$;
    - the fixed-$a$ limits $(\sqrt{\beta(1)}-a)^2$ are reached;
    - the schedules $1/\sqrt d$ and $1/\ln d$ rise toward $\beta(1)$.
  - (e) the §7.4 clone term at $c=n^{1/2}$, $\alpha=0.2$: its slope is $0.300$.
  - (f) the averaging example of §7.1 item 1.
  - (g) the weight-bound sentence of the A2 entry. With $\delta_0=\min\{1,\frac12(L/K)^{L/2}\}$, $\eta\le\frac12$ for every $n$ and every $c$.
  - (h) the Theorem 2.10 form of Lemma E(ii), with linear term $b\ell'/(3n)$, against exact binomial tails. The largest tail$/\delta'$ is $0.20$ over 840 cases.
  - (i) the endpoints of the Remark 7 window.
- **By hand.**
  - Lemma F after the notation change: $\lvert w\rvert_N$, $J_\Omega$, $\tau$, $\prod_j\lambda_{N,j}$, and $F\le m_*+\zeta/4$ on the ball.
  - The proof of the $C_{L,\alpha,\delta}$ bound, and the $B_0<1$ addendum.
  - The probabilities in Theorem 4.
  - Remarks 7 and 8, against B and A.
  - Every replacement text in §7.3 and §7.4, against the sentences it quotes.

## 2. Remaining issues

1. **Minor. §7.4, first paragraph ("Its final text cites `red-team.md` Proposition 6.1 as 'refereed with a corrected rate, repair under review' …"), and §10, row logic m3 ("its final text says …").**
   - A's research-notes copy does say this today: §5.3 item 3 (line 579), §5.4 (line 597), §10 item 5 (line 1144) and the referee record (line 1251).
   - But A is still being finalized, and §7.4 exists so that the first three of these sentences get replaced. Once they are, both sentences of this note describe A wrongly.
   - *Fix:* write "Its current text (the version this note was checked against)" in both places. Alternatively, update both sentences when A adopts the wording.
2. *Nit.* Remark 8, success bullet: "Let $g$ be a competitor with fixed $m$ and $B$" omits $m\le N$, which Theorem 1(b) needs. The §7.3 entry for §0 item 1 and the §7.4 wording now state it; §7.4 even says "as Theorem 1(b) does". Add "with $m\le N$".
3. *Nit.* Remark 6(b): "These values agree with the first-round referees' tables." Only the first-round logic referee's table concerns this competitor. The first-round computation referee's table (`RT-width-computation.md`, line 148) uses a different competitor, with $L_D(g)=\frac12$, and gets different ratios: $13.8$ at $\alpha=0.2$, $n=10^{12}$, against $20.0$ here. Write "the first-round logic referee's table".
4. *Nit.* §10, row logic m4: "the referee's numbers quoted". Remark 8 quotes $0.449$, $0.462$, $0.471$ and $4.5\cdot10^5$. These are the computation referee's numbers (`transition_check.out`, issue 1). The logic referee's own numbers (`check_A_width.out`, $a_d=1/\log_2d$) are not quoted. Write "the computation referee's numbers quoted".
5. *Nit.* §8, last paragraph, and §10, paragraph after the table: "two printed labels were changed (the weight exponent is printed as `omega` …)". In `check_explicit_bound.out` part (3), the header also gained ", Bbar=n^w", and the predicted-exponent formulas print `w` (for example `pred 2a+2w-1/2`). "Two" undercounts, and the exponent is printed both as `omega` and as `w`.

**Notes for the lead (not defects of the note).**

- **Red-team §6.3.** The task description says red-team §6.3 will be replaced by a pointer. The note's §7.3 says, correctly, that only lines 480–497 are replaced. Two parts must stay:
  - the list of surviving versions (lines 472–478), with item 2 amended;
  - Remark 6.2 (lines 499–505). It was refereed in `RT-aggregate-logic.md`, and A §5.4 (lines 591 and 597) cites it.

  Finalize `red-team.md` as §7.3 says.
- **Check reports.** §10, "Check of the revision", cites no report file. B links its checks (`../verification/B-revision-check-N.md`); A, C and E do not yet, and `verification/README.md` marks their checks as pending. If the check reports for this note are published, link them there.

## 3. Findings by question

**(a) Referee issues.** None is unaddressed. Each of the 24 rows of the §10 table matches its report item, and the text does what the row says.

- **Notation (m1, computation 4).**
  - $\Lambda_N$ is now only the logarithm.
  - Lemma F uses $\lvert w\rvert_N$ and $\prod_j\lambda_{N,j}$; the old $\det\Lambda$, $U^\ell$, $G_\Omega$ and Lemma F's $a$ are gone.
  - $\eta$ remains only in Remark 7 and §8, as B's quantity. $\kappa$ appears only in quotations in §10.
- **Coverage wording (m2, computation 6).** "In the user's words", §1 and §7.1 items 1 and 6 all carry the fix.
- **Incomplete citation list (m3, computation 2).** Fixed by the §7.3 entry for line 562 and by §7.4.
- **Remark 8 (m4, m5, computation 1).** Fixed in both of its bullets and in the §7.3 entry for §0 item 1.
- **Remark 5 and the §0 bullet (m6).** Fixed.
- **The A2 replacement (m7, computation 3).** The entry quotes red-team line 196 verbatim.
- **Theorem 4's probability (m8).** Fixed.
- **Lemma C's looseness (m9, 7(c)).** Fixed.
- **Corollary 3(i)'s rate (m10, computation 5).** Fixed.
- **The critical exponent (m11).** Fixed.
- **Lemma E's citation (m12, 7(b)).** Fixed.
- **The remaining items** (7(a), 7(d), the §2.7 probe and the §2.10 observation). All addressed.
- **First revision check.** All five points are fixed as §10's second table says:
  - the header and the opening of §7.3;
  - the §0 sentence on depth two;
  - §7.4: "at $c=1$", "for fixed $c>0$", "of width at most $N$", and $d\le n^\alpha$;
  - $\liminf$ in Remark 7;
  - "refereed in its corrected form".

**(b) Correctness of the changed passages.** All correct. Beyond §1, I re-derived the following.

- **The constant of Corollary 3(i).**
  - $t_*>1$ needs only $\alpha<1/(2\ln2)$.
  - $n^{4\alpha-1}\le n^{2\alpha-1/2}$ for $\alpha\le\frac14$.
- **The $B_0<1$ addendum.** It follows from the class inclusion, which lowers the minimum.
- **§7.1 item 1.** Clip is monotone and $(u-y)^2$ is convex, so $(\operatorname{clip}\bar z-y)^2\le\max_i(\operatorname{clip}z_i-y)^2$. In the example, the mean is $<-1$ on each $A_j$.
- **§7.1 item 2.** At $N\ge N_0$ the bound exceeds 4.
- **Remark 7.** Both sides hold under the new definition of a good $\alpha$, and $L/(2(2L-1))$ decreases to $\frac14$.
- **Remark 8.**
  - At $c=1$, A's $\epsilon\to0$ if and only if $a_n\to0$ and $na_n\to\infty$. Bounding the max in $K_{\rm mem}$ by a sum, the terms are $\lambda a^2$, $9(H+1)/(2aM)$, $(H+1)(8ds)^{1/H}/M$, $d(d+1)\alpha_d^2/M$ and $t/M$; for $H\ge2$ only the first two need conditions on $a$.
  - $N_0=O(n\log^2n/a_n^2)$. With $a_n=1/d$ this is $O(n\log^4n)$, and with Corollary 4.5's schedule it is $O(n^{5/3}\log^2n)$.
- **§7.3.**
  - The example in the §0 item 1 entry satisfies both of the entry's conditions.
  - In the A2 entry's $O_L$ form, $1+\ell\le1.73\,\ell$ and $\sqrt{\ln2n}\le\sqrt2\sqrt{\ln n}$ are absorbed.
  - The weight-bound sentence holds for every $c$.
  - In the line-562 entry, Theorem 1(a)'s proof uses $K$ only through $R=\sqrt{KN}$ and Lemma C, so it holds at any fixed $K$. Also $T\le n^{1/2-\epsilon}$ if and only if $\theta<(\gamma-1)/(2(L-2))$.
- **§7.4.**
  - The clone term is of order $c\,n^{4\alpha-1}$, so it diverges if and only if $c\gg n^{1-4\alpha}$. At $c=n^{1/2}$ and $\alpha=0.2$ it grows like $n^{0.3}$.
  - The fixed-$c$ sentence follows from Theorem 1(b), which holds for every $c>0$.

**(c) Claim strength.** Four statements are stronger than in the text the referees read. All four are proved.

1. Corollary 3(i) at the exponent $2\alpha-\frac12$ itself, with an explicit constant (requested in m10 and computation 5).
2. Remark 8's full excess at $N_0=O(n\log^2n/a_n^2)$ (requested in m4 and computation 1). It follows from A Theorem 4.4.
3. The fixed-$c$ form of the fixed-competitor statement in the wording §7.4 suggests for A. It follows from Theorem 1(b), and §7.4 gives the reason.
4. The weight-bound sentence of the A2 entry, imported from B Proposition 9.1(a) and Lemma 9.2. It holds for every $c$.

Everything else changed in the direction of weakening: §0 "Weakened", Remark 5, §7.1 item 2, the extra hypotheses in the §7.3 replacements, and $<$ to $\le$ in Lemma F.

Nothing proved was dropped:

- In §9, the diff shows only additions and changes of symbols.
- The strict-$\kappa$ form of Corollary 3(i) is implied by the new form.
- Remark 8's fixed-accuracy bound survives as its "Fixed accuracy" sub-bullet.

**(d) Cross-references.** Each was checked against the current text of the cited note.

- **B** (final). Lemma 2.3(a) and (c); Lemma 3.1; Corollary 8.1, where $\beta$ is its rate exponent and "$4\alpha-\frac12\le-\beta$" is the last step of its proof; Remark 8.2 (width $m+1$, $B'=\max\{B,1\}/\tanh1$); Proposition 9.1(a) ($\liminf$, clipped and unclipped); Lemma 9.2.
- **A** (research-notes copy). All of the following match:
  - Lemma 2.1 ($N_0$), Theorem 4.4 and (4.3);
  - Corollary 4.5 ($O(d^2n^{5/3})$) and Corollary 4.5a ($45d^3(d+1)2^d$);
  - Remark 4.7 (the fixed-$a$ limit);
  - §5.1, where the name (P$_L$) is introduced (the brief's §1 defines the property without naming it);
  - the wording at lines 579, 597, 1144 and 1251.

  In the stage copy, lines 543 and 1039 read "a parameter-counting sketch I have not checked" and "an unrefereed parameter-counting sketch", which the note paraphrases as "unchecked, unrefereed".
- **`depth-two.md`.** Corollary 5.2(i) and (a), with $N_0=O(n\log^4n)$ for $a_d=1/d$, and the §0 sentence on $c=1$ match.
- **E.** Theorem 2.7: clipped predictions, every $N\ge m$.
- **Red-team** (stage copy, which is the version both referee rounds read). Lines 20, 30, 196, 472–478, 475, 480–495, 497, 499–505, 530 and 562 match.
  - No other citation of Proposition 6.1 exists in red-team.
  - Among the other notes, only `depth-two.md` cites it, at lines 599 and 755, through Theorem 1(c), consistently with this note.
- **`paper.tex`.** The labels `sec:model`, `eq:energy`, `eq:teacher-energy` and `thm:strong` exist.

**(e) Paths and outputs.**

- **Paths.** There are no absolute paths. Every relative path resolves from `research-notes/`, except `../README.md` and `red-team.md`, which may be missing for now.
- **Author's script outputs.** These quoted numbers all match:
  - 160,750; 0.678; 0.631;
  - the slopes, within 0.002;
  - 8,401; 4,400; 0.9997; 0.49;
  - 4.36, 0.67 and 0.030; 0.228; $5.9\cdot10^3$; $1.48\cdot10^{12}$; $3.0\cdot10^{-4}$;
  - 0.37; $6.9\cdot10^{-15}$; $1.5\cdot10^6$ and $1.5\cdot10^8$;
  - 9,090; 864; 0.19 and 0.05; 4,500; 0.73 and 0.49; $3\cdot10^{-14}$; 0.75;
  - 1.63–1.72 and the ratio table, including 2.73, 3.80, 5.02 and 7.54.
- **Referee script outputs.** These also match:
  - 0.90 and 0.64 (`check_lemmas_AC.out`: 0.902, 0.635);
  - 0.92 and 0.74 (`perturb_adv.out`: 0.9186, 0.7400);
  - 0.200 (`bound_check.out` part (5));
  - 0.33–0.69, 0.07–0.26, 400 restarts, four of five settings (`check_bestinclass_fluct.out` and its script);
  - 0.449, 0.462, 0.471, 0.4848 and $4.5\cdot10^5$ (`transition_check.out` part (a)).
