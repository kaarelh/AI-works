# Check of the revised Claim B note (round 2)

*Published record of a check of the revised note, made during finalization. Paths under `stage/` refer to the lead's unpublished working copies; the pre-revision text there is the version that the referee reports reviewed, published as [`B-first-version.md`](B-first-version.md). This check's scripts and outputs are in the `../checks/revision-check-*` folder named below. Re-runs of the note's own scripts, which some reports keep in a `rerun/` subfolder, are not published; each report says whether they reproduced the recorded outputs.*

**Document:** `research-notes/B-tempered-likelihood.md` (1027 lines), compared with the pre-revision text `stage/B-tempered-likelihood.md` (927 lines). I read all 44 diff hunks against the three referee reports, the brief (`../research-notes/problem-brief.md`) and `checks/B/`.

**Verdict: minor fixes.** All 33 referee issues are handled, and the seven round-1 points are resolved as §12 says. Every changed number, exponent and new construction I re-derived is correct. One sentence added for logic issue 1 is now inconsistent with the fixed-dimension qualifier added in round 1 (issue 1 below). The other remaining items are small imprecisions.

## What was verified

**(a) Referee issues.** §12 has one row per issue: logic 1–11 (issue 9 split into a, b, c), computation M1–M10 and scope 1–10, 33 rows in all. I checked each fix in the place the row names. None was rebutted. No issue is left unaddressed.

**(b) Changed passages.** I re-derived the following. The script is `../checks/revision-check-B-2/verify_r2.py`, with output in `verify_r2.out`.

- **Theorem 6.3 example.**
  - The displayed $\mathrm{Exc}_n$ first drops to $\le0.1$ at $10^{14.088}$.
  - With $K=n^\theta+1$ the crossing is at $10^{13.379}$.
  - At $10^{13.4}$ the displayed bound is $0.1463$.
  - The closed-form $n_0$ is $10^{29.23}$.
  - A grid from $10^0$ to $10^{60}$ shows exactly one crossing, so "first drops below" is well defined.
- **Degrees of $n_0$ per variable.** Numerical slopes match $\max\{2/\theta,2/(1-\theta H)\}$ in $d$, $\max\{2/\theta,4\}$ in $m$ and $B$, and $\max\{1/\theta,4/(1-\theta H)\}$ in $1/\varepsilon$, in all five test settings.
- **Route-1 thresholds.** At $\theta=1/32$, the term $(E_*+1)n^{-\theta}$ is $0.075$ of the total $0.100$. At $\theta=1/10$, the cover term carries $0.075$. Both match the text.
- **§1, fixed $c$.**
  - The power-posterior identity holds.
  - $K_{\rm mem}=O(\sqrt n\log n)$ and $\varepsilon_{c,t}\to0$ for $c=1$ and $c=10$, at $H=2,3$.
  - $m_t=\lceil2(d+1)^3n^{3/2}\ln2\rceil+1$ holds exactly.
  - $n^{-1/4}\le1/4$ if and only if $n\ge256$.
- **Corollary 3.2(3).** The tightness argument for $\sigma\in[\sigma_1,1)$ is correct: $Z_\sigma$ is nondecreasing because $F\ge0$.
- **Lemma 4.2, Steps 1 and 4.** All three new proof lines are correct. On 7560 grid points with $L\le2000$ there is no violation. The termwise split fails first at $L=16$ when $d=K=1$, as stated.
- **Remark 6.1a.** Correct.
- **Remark 6.5.** The new scope sentences are correct.
- **Theorem 7.4(b) scale.**
  - The slowest term for $1/H<\theta\le2/H$ is correct, checked asymptotically.
  - At $H=2$ the bound is $0,0,0,0.328$ for $\theta=0.55$ and $0.197,0.364$ for $\theta=0.75$. My independent recomputation reproduces these values.
  - $N_0(n)=m_t$.
- **§7.5(4).** The window is nonempty if and only if $\kappa<1/(2H+1)$.
- **Corollary 8.1.** Checked with sympy:
  - $4\alpha-\theta=-\beta$ and $(1-\theta H)/2=\beta$;
  - $-\beta-(4\alpha-\tfrac12)=(H-16\alpha)/(2(H+2))$;
  - at $H=1$, $\beta>0$ if and only if $\alpha<1/8$, and $\beta=\tfrac12-4\alpha$ for $\alpha>1/16$;
  - at depth 3, $\alpha=1/16$ gives $\beta=1/8$.
- **Remark 8.2.** On 300 random biased nets the converted nets agree with the originals to $4.9\times10^{-15}$. The weight bound $\max\{B,1\}/\tanh1$ is attained.
- **Proposition 9.1(c).**
  - $(1+\frac5{4L})4^{1/L}\le3.25$, and $2^{1/L}/\sqrt L\le1$.
  - $\omega^2\ge2.099$ when $n^\theta\ge2L$.
  - The new matching proof is correct under $\theta<1/H$, with $\theta\le1/2$ when $H=1$, in fixed $d$.
- **Corollary 9.3.** The definition of "works", the positive halves, Case 1, Case 2 and the closing step all check. Both the simultaneous and the per-width readings of "with probability $\ge1-\delta$, at every learner width" are refuted, because the argument uses one width.
- **§9 Discussion.**
  - The three bullets hold.
  - The $3.25(n/c+1)$ statement holds.
  - The $g_R$ counterexample holds: $g_R'(0)=R/10$, $L_D(g_R)>1$, and the energy lower bound $L(R/10)^{2/L}$ holds.
- **Remark 9.4.**
  - The decomposition $L_D=L^\star_D+\lVert f-f^\star\rVert^2$ is correct.
  - The chain bound $2\lVert f\rVert_\infty^3/(3R^2)$ holds for any $\lVert f\rVert_\infty$; the maximum ratio is $0.969$.
  - $\sqrt\varepsilon/2+\sqrt{\varepsilon/4}=\sqrt\varepsilon$ gives $L_D(g_\varepsilon)\le L^\star_D+\varepsilon$.
  - The citations (Cybenko 1989; Leshno et al. 1993) are correct.

**(c) Strength of claims.** No proved result was dropped. New claims are proved in the text: §1 fixed $c$, Remark 6.1a, Remark 8.2, Remark 9.4, and "So $c(n)=n^{1-\theta}$ works" in Corollary 9.3. "$n_0$ independent of $D$" in the §0 row is visible in the formula for $n_0$. Every other change adds a qualifier or claims less.

**(d) Numbering.** Label extraction shows that every pre-revision section and result keeps its number and order. The additions are Remark 6.1a, Remark 8.2, Remark 9.4 and §12. Every internal cross-reference resolves; the only exception is `red-team.md` Theorem 5.1, which is an external citation. See issue 4.

**(e) Paths and outputs.**

- Every `../` path resolves, and so does every `NNG/` path from the project root.
- Absent for now, as the planned layout expects:
  - `../README.md`;
  - `problem-brief.md`;
  - `A-tight-conditioning-fails.md` (in `../checks/` as `../research-notes/A-tight-conditioning-fails.md`);
  - `red-team.md` (in `../checks/` as `../research-notes/red-team.md`).
- I re-ran copies of `sample_sizes.py` and `transition_window.py`. Both outputs are byte-identical to the `.out` files.
- `transition_window.out` is identical to the pre-revision output.
- Every quoted value matches its `.out` file:
  - `sample_sizes`: 14.09, 13.38, 29.23, 101.4, 101.9, 260.6, 54.0;
  - `transition_window`: 0.461, 0.536, 0.634, 0.688;
  - `cover_degree`;
  - all `check_*` rows of §10;
  - `v_cube_twopoint.out`;
  - `width_dependence.out`: $\ge0.4697$ and $0.0286$.
- The docstring changes are correct. The only code change is the added displayed-bound column and the new $\theta=1/10$ row.

## Remaining issues (all minor)

1. **Proposition 9.1(c), line 835: the necessity sentence does not fit the fixed-dimension statement.** The text reads: "The hypothesis $\theta<1/H$ cannot be dropped when $H\ge2$: for $\theta>1/H$ even the zero competitor is not matched on the noisy cube (Theorem 7.4(b))." The matching sentence now holds only "for laws in a fixed dimension $d$", but the noisy cube has $d=\log_2n$. So Theorem 7.4(b) does not show that the hypothesis is needed for that statement.

   It is not obvious that it is needed. In $d=1$, Lemma 2.1(b) caps the Lipschitz constant of near-minimizers at $(K/L)^{L/2}=o(n)$ for $\theta<2/L$, and $2/L>1/H$ when $H\ge2$.

   *Fix:* "Without $\theta<1/H$ the statement fails once the dimension may grow with $n$: for $H\ge2$ and $\theta>1/H$, even the zero competitor is not matched on the noisy cube in dimension $\log_2n$ (Theorem 7.4(b)). In fixed dimension this is not settled here."

2. **§0, first paragraph, line 7.** "The theorems below are therefore uniform-convergence bounds for that objective combined with a Laplace lemma." This also covers the lower bounds summarized below it (Theorem 7.4(b), Proposition 9.1, Corollary 9.3), which are explicit constructions, not uniform-convergence bounds.

   *Fix:* "The positive theorems below …".
3. **§7.5 item 1, line 777.** The negative half now carries the probability qualifier but no learner-width condition. Proposition 7.3 needs $N\ge m_t=\lceil2(d+1)^3n^2\ln2/c\rceil+1$ (with $t=(c/n)^{1/2}$). Every other failure statement now gives its widths.

   *Fix:* add "at every width $N\ge m_t$".
4. **Numbering criterion (d).** Remark 8.2, Remark 9.4 and §12 are new items numbered with plain integers. No existing number moved, and the §12 rebuttal of round-1 point 5 is reasonable. Still, the criterion as worded allows only primed or lettered additions.

   *Fix, if the rule is strict:* Remark 8.1a and Remark 9.3a. An appended §12 seems harmless.
5. **Corollary 8.1, "In the user's words", line 808.**
   - It still omits "with probability $\ge1-\delta$" and "at every learner width $N\ge n^\alpha$", which the §0 row now carries.
   - "The test MSE of the tempered Bayesian network" names no predictor; the next paragraph names them.

   This was pre-existing; low priority.
6. **§12: the reports cite line numbers of the pre-revision text.** `B-computation.md` cites lines 11, 547, 579 and 794 (M1–M4, M6). In the published text those lines hold other content.

   *Fix:* add a sentence saying that line numbers in the reports refer to the version they reviewed.
7. **§12 quotations, rows logic 5 and scope 6.** These rows put paraphrases in quotation marks:
   - "competitors whose minimal energy exceeds the budget cannot be matched";
   - "competitors above the budget cannot be matched";
   - "with $c=1$ far steeper competitors are matched".

   The removed text read "Competitors whose minimal energy exceeds it by a constant factor cannot be matched" and "With $c=1$ the budget is $n$, so far steeper competitors are matched".

   *Fix:* quote exactly, or drop the quotation marks.
8. **Remark 6.5, line 611 (trivial).** "$O(E_0n^{-1/2}\sqrt{\ln(2/\delta)})$" should be $O((E_0+1)n^{-1/2}\sqrt{\ln(2/\delta)})$, since $(\sqrt\kappa+1)^2\ge1$ even at $E_0=0$. This was pre-existing, but the sentence was rewritten in this revision.
