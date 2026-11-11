# Check of the revised Claim E note (round 3)

*Published record of a check of the revised note, made during finalization. Paths under `stage/` refer to the lead's unpublished working copies; the pre-revision text there is the version that the referee reports reviewed, published as [`E-first-version.md`](E-first-version.md). This check's scripts and outputs are in the `../checks/revision-check-*` folder named below. Re-runs of the note's own scripts, which some reports keep in a `rerun/` subfolder, are not published; each report says whether they reproduced the recorded outputs.*

**Verdict: minor fixes.**

- Every issue in the two referee reports is resolved, either fixed or validly rebutted.
- All six problems from the round-2 check are fixed, and so is its optional point.
- Every changed statement I re-derived is correct, and no claim was strengthened beyond its proof.
- Nothing proved was dropped, and the numbering is stable.
- All ten scripts reproduce their outputs byte for byte.

Two small problems remain, both in passages the revision did not touch or only partly touched:

- a citation of B that is wrong at depth two;
- one use of `paper.tex`'s law constant $m$ that missed the declared renaming to $m_\nu$.

**Documents.**

- **Revised note:** `research-notes/E-finite-prior-scale.md`, 808 lines, timestamp 17:51, md5 `c9402d79…`. The file did not change during this check.
- **Compared against:**
  - the pre-revision text `stage/E-finite-prior-scale.md` (691 lines, 56 diff hunks, in `../checks/revision-check-E-3/diff_full.txt`);
  - the text that the round-2 check read, `stage/E-r3/E-finite-prior-scale.md.before` (16 hunks, in `../checks/revision-check-E-3/diff_r3.txt`).
- **Also read:**
  - `verification/E-logic.md` and `verification/E-computation.md`;
  - A (revised, `research-notes/`), B (final), C (`research-notes/`) and `stage/red-team.md` §8;
  - the brief, and `paper.tex` Lemma `spectral`.
- **My scratch files** are in `../checks/revision-check-E-3/`.

## 1. Remaining problems

1. **§2.7, item 1, third bullet (line 339; unchanged since the first version).** The bullet reads: "The repository's own energy cover would only give $\theta<1/(4(L-1))$ (B-tempered-likelihood.md Lemma 4.2)."
   - This is right for $L\ge3$ but wrong for $L=2$.
   - B Lemma 4.2 says that at $L=2$ the cover entropy has degree $2$ in $K$, "not $4(L-1)=4$". B Theorem 6.2 accordingly gives $\theta<1/2$ at $L=2$.
   - The surrounding item is stated for general $L$.
   - *Fix:* "…would only give $\theta<1/(4(L-1))$ for $L\ge3$, and $\theta<1/2$ for $L=2$ (B-tempered-likelihood.md Lemma 4.2, Theorem 6.2)."
2. **§2.4, paragraph after Lemma 2.4 (line 213).** The paragraph quotes `paper.tex` Lemma `spectral` as "the condition $N^{\gamma-1}\ge256/(mb^2)$".
   - Here $m$ is `paper.tex`'s law constant; I confirmed this in the source.
   - §1.6 and the logic-10 row of §9 say that this constant is now written $m_\nu$. In this note's notation the bare $m$ is the competitor's width.
   - So the renaming that the revision declares is incomplete at this one place.
   - *Fix:* write $256/(m_\nu b^2)$, with $m_\nu=1$ for Gaussian coordinates.

*Optional, all in unchanged text:*

- **Lemma 2.4, step 2.** The step writes $\gamma(\mathcal B)\ge\frac12$, with $\gamma$ as the Gaussian measure, inside a lemma where $\gamma$ is the prior exponent. Writing $\gamma_{N^2}$ would remove the clash; alternatively, §1.6 could list it.
- **§7, item 2.** "In all 200 draws" means 200 draws per shape, 1000 in all.
- **§8 open list.** The list does not mention $\theta=1/H$ itself, which the §6 table and §0 row 7 treat as open.

## 2. What was verified

**(a) Referee issues.** All are addressed; none is left unaddressed.

- Each row of §9 matches the text at the location it names: logic 1–10, and computation E1, E2 and I-1 to I-10.
- The rebuttals are valid:
  - **I-4, §3.** The old bullet already required $N\ge(\sqrt{d+1}+t_L)^2$.
  - **η not renamed.** A's §1.4 quotes this note's "with $B=\eta n$".
  - **"17%" in logic 6.** This is the absolute dropped mass, 0.88% of $\mathcal A=19.7$.
  - **"0.73–1.52" in I-6.** The printed maximum is 1.515.
  - **I-2 at $\gamma=1$.** At $\gamma=1$ the condition is equivalent to $N^\gamma K'\ge3P_N$. A grid in `check_E_r3.out`, item 9, confirms this: the two conditions agree at $\gamma=1$, and 26 widths separate them at $\gamma=1.5$.
- The round-2 problems are fixed: items 1–6 and the optional point. Specifically:
  - `robust_memorizer_det.py` now prints the expansion error, 1.3–3.6·10⁻¹⁵. With that field removed, its output is byte-identical to the earlier one.
  - The §2.3 bullet treats $\gamma=1$ and $\gamma>1$ separately.
  - Answers (1) and open problem 1 attribute the $\gamma=1$ gap to (C5) and $D_H$.
  - §9 now lists the five exceptions.
  - `paper.tex` is introduced as a short name at line 37.
  - The entry for $c$ is reworded.
  - "here" is added in §2.7.

**(b) Changed passages, re-derived.** The script is `../checks/revision-check-E-3/check_E_r3.py`, with output `check_E_r3.out`.

- **Degrees and $\gamma_H$.** $D_H-(D_T+1)>0$ for $L=3,\dots,8$. $\gamma_H=(D_H-1)/(D_H-H)$ gives 1.02000, 1.00692, 1.00231 and 1.00077, each below the route crossover $2-2/H+1/H^2$. $\theta_{L,\gamma}<1/D_H$ holds exactly when $\gamma<\gamma_H$, on grids of $2\cdot10^5$ points.
- **Answers (1) at $\gamma=1$.** (C5) needs $\theta<1/D_H$, and bridging $T_{\rm mf}$ needs only $\theta<1/(D_T+1)$.
- **Bound on $\Xi$.** The five terms sum to $37/96$ for $H\ge2$, and to $5/12$ with only $H^2\ge1$. The output error is $0.765a$.
- **General-$c$ terms after Corollary 5.4.** The terms are $\frac{2cA}n+\frac{2c\ln(1/\delta')}{N^\gamma n}+\frac{N^\gamma}c$; the sympy residual is $0$, and the residual against the display at $c=n^{1-\theta}$ is also $0$.
- **(C1) and (C2).** At equality in (C1), $h_n=\varepsilon/32$ exactly. The regime totals are 0.8164, 0.7539 and 0.7539, and $\pi^2/24=0.4112$.
- **The $A_L$ form.** The ratio of $A_L-\frac12E_*$ to $(d+m)(1+\ln\frac1\rho+\ln(dmB))$ is at most 6.65, 13.85, 23.90 and 36.65 for $L=2,\dots,5$. At $d=m=B=\rho=1$, $L=3$, $A_L-\frac12E_*=27.71$, so the "1+" is needed.
- **The $N_*$ form.** The ratio of $N_*$ to the stated $O_H$ expression stays bounded for each $H$ as $d,s,1/a$ grow, up to $d=10^6$, $s=10^{30}$ and $a=10^{-20}$ (`nstar_ratio.py`).
- **Corollary 5.3.** $a_d\le1$ and $\eta_d\to0$ for $c=1$ and for $c=n^{1-\theta}$ with $\theta>1/H$, checked numerically up to $d=640$. $N_*\ge256\mathcal A_{\max}^2\ell_d/a_d^2\ge s_0$.
- **Remark 5.4a.** $(1-2x)(1+e)\ge1+e-4x$ on $[0,\frac12]\times[0,1]$. $e_d\le\beta_n\le1$, and the (F0) event lies in $\mathcal E_{\delta_d}^c$.
- **Theorem 5.2(ii).** $V\subseteq B_t^c$ and $\Pi(V)>0$.
- **§3 consequences.** These were checked against Lemma 3.1, with $K_0\le E_*$ and $K_0\le K_{\rm mem}$.
- **§7 item 4.** Each of the following was checked:
  - $1-\Pi_*$ is 0.394 and 0.537;
  - $\Pi_*\cdot0.132=\Pi_*\cdot0.173=0.080$;
  - the dropped mass is 0.15–0.88% of $\mathcal A$;
  - $\Pi_*$ times the sampling error tracks the noisy medians.

**(c) No strengthening.**

- Every changed claim is weaker, or a proved consequence, or a citation: the title, "sharp", "at every width", "tends to 2", "this proves", the capacity remark, and the new Remark 5.4a.
- The more specific §0 row 6 follows from Corollary 5.3 with $t=1$ and Theorem 5.2(i).
- Every item of the old §8 is still there.

**(d) Numbering.**

- Headings, result labels and the tags (1.1)–(5.1) are unchanged.
- The only additions are §1.6, Remark 5.4a, (F0), Remark 2.9(d)–(e), open problems 7–8, and §9 with two unnumbered subsections, all appended or lettered.

**(e) Cross-references.** All match the current texts, except item 1 above.

- **A (revised):**
  - Lemmas 2.1, 2.2(b),(e), 3.1(a), 4.1(a),(c), 4.2(b) and 4.3(b)–(d);
  - eq. (2.4), condition (4.4), Table 4.1, §1.4 and §5.1;
  - Theorem 4.4(i) and Corollary 4.6, with $\eta$, $\sqrt{32n\log(1/\delta)}$ and $v_0\beta(\lambda)$;
  - Proposition 5.2 (fixed $d$, every width);
  - Proposition 6.1(a′) (upper bound, strong prior);
  - Remark 2.5 and Proposition 8.2;
  - Lemma 6.4(a), Propositions 6.5, 6.6(b) and 6.6a (added in the second round), and §10 item 6.
- **B (final):** Lemmas 2.1(a), 2.2, 3.1, 5.2 and 5.3(a); Theorem 6.3; Remark 8.2 ($B'=\max\{B,1\}/\tanh1$, width $m+1$); §7.5 item 1.
- **C:** Theorem C.7 is the final-posterior bound, with $\phi_w=\operatorname{clip}\circ z_w$ in the likelihood. The per-sample inverse temperature $\Lambda_N/n$ matches $\eta$ there.
- **red-team.md:**
  - Only §8 is cited, and accurately: $\theta<(\gamma-1)/(2(L-2))$, mean field open in both directions, and $N(d+m_0+H)$ constraints.
  - No red-team proposition with a restricted status is cited.
  - §9 correctly says that §5 is not cited.

**(f) Paths and outputs.**

- Every link and backticked path resolves from `research-notes/`, except `../README.md` and `red-team.md`, which may be missing for now.
- The four `NNG/` paths exist, and there are no absolute paths.
- Bare script names occur only in §7, under its lead sentence.
- I re-ran all ten scripts into `../checks/revision-check-E-3/rerun/`, and every output is byte-identical to `checks/E/*.out`; the longest run took 79 s.
- Against the first-version outputs (`stage/E_old_outs/`), only two files differ: `theta_table.out` has four added lines, and `robust_memorizer_det.out` has the new field. That is what §7 says.
- Every number quoted in §§1.5, 4, 5, 6, 7 and 9 matches the `.out` files of `checks/E/` and `checks/verify-E-computation/`.
- The largest unrounded difference in $e$ between the two Table 7.1 implementations is $2.97\cdot10^{-5}$ (`../checks/revision-check-E-3/table/`), within the stated $10^{-4}$.
