# Check of the revised `small-learner-width.md` (after the second referee round)

*Published record of a check of the revised note, made during finalization. Paths under `stage/` refer to the lead's unpublished working copies; the pre-revision text there is the version that the second-round referee reports reviewed, published as [`small-learner-width-first-version.md`](small-learner-width-first-version.md). This check's scripts and outputs are in the `../checks/revision-check-*` folder named below. Re-runs of the note's own scripts, which some reports keep in a `rerun/` subfolder, are not published; each report says whether they reproduced the recorded outputs.*

**Verdict: minor fixes.** Every issue in the two second-round reports is handled, and each fix is correct. None was rebutted. Every changed statement and number I re-derived is right. The three scripts re-run byte-for-byte, and every quoted number matches its `.out` file. Three small wording or scope problems remain (§2), plus two optional nits. None affects Theorem 1, Corollaries 2–3, Theorem 4 or the corrected clause.

## 1. What was checked

- **Diff.** I diffed the pre-revision text (`stage/small-learner-width.md`) against the revised note and read all 25 changed regions.
- **Referee reports.** I read both second-round reports in full: `RT-width-logic-revised.md` (m1–m12, plus the §2.7 probe) and `RT-width-computation-revised.md` (issues 1–7, plus the §2.10 observation).
- **Re-running the scripts.** I re-ran the three author scripts in `../checks/revision-check-small-learner-width-1/rerun/`. Their outputs are identical to the `.out` files, in 34 s, 4 s and 1 s.
- **Old against new scripts.** I diffed the scripts and outputs against the pre-revision copies in the lead's unpublished working folder (`out/RT_width_fixed_scripts/`; the revised scripts are in `../checks/small-learner-width/`). Only docstrings, labels (`beta`→`omega`, `redteam`→`red-team`, plus the matching part-(3) header) and the new part (6) changed, as §8 says.
- **Independent check.** `../checks/revision-check-small-learner-width-1/indep_check.py` (output in `.out` next to it) tests the new or changed statements with my own code:
  - (a) the supremum $2^\alpha/\sqrt{2e\alpha}$, and that the maximizer $t_*>1$, on 400 random $\alpha\le\frac14$;
  - (b) $\mathrm{Exc}\le C_{L,\alpha,\delta}n^{2\alpha-1/2}$ on 20,000 random cases with $1\le N\le2n^\alpha$ and $1\le d\le n^\alpha$ (maximum $0.41$). This also covers the §0 "more generally" sentence;
  - (c) the §7.1 item 1 example: the average of the raw outputs is below $-1$ on every $A_j$;
  - (d) the Remark 7 window;
  - (e) $\mathrm{Dev}_N\ge4$ at A's $N_0$, which supports "At such widths Theorem 1's bound exceeds 4" (minimum $8\cdot10^3$);
  - (f) the moment condition behind the Theorem 2.10 remark, $3^{q-2}\le q!/2$;
  - (g) the A2 weight-bound sentence: B's Lemma 9.2 at width 1 with $\eta=\frac12$;
  - (h) the §8 bullet's exponent arithmetic.
- **By hand.** I re-derived:
  - Corollary 3(i) with the explicit constant;
  - the $B_0<1$ addendum;
  - the Lemma F edits, including $<\to\le$ and the norm $\lvert w\rvert_N$;
  - Theorem 4's probabilities;
  - the Lemma E/BLM citations (Corollary 2.11 is the bounded-above form; Theorem 2.10 with $c=b/3$ gives $b\ell'/(3n)$);
  - Remark 7's quantile definition, and both of its sides;
  - both bullets of Remark 8 against A's (4.3).

## 2. Remaining issues

1. **Minor. §7.3, opening paragraph: "When `red-team.md` is finalized, its §6.3 is replaced by a pointer to this note."**
   - In the red-team version the referees read, §6.3 also contains the list of surviving versions (items 1–5, lines 474–478) and **Remark 6.2** (line 499, the aggregate-fit learner). Remark 6.2 was refereed separately (`RT-aggregate-logic.md`) and is cited by A §5.4 (line 591).
   - This note contains neither the list nor Remark 6.2. Read literally, the sentence drops a refereed result and leaves A's citation dangling.
   - It also contradicts §7.3's own entry for "§6.3 item 2 (line 475)", which assumes that the list survives.
   - *Fix:* say that lines 480–497 (Proposition 6.1, its proof, the "In particular" clause and the paragraph after it) are replaced by a pointer, and that the list (item 2 amended as below) and Remark 6.2 stay. The header's "It replaces §6.3 …: Proposition 6.1, …" is fine because of its colon list, but could say "the Proposition 6.1 part of §6.3".
2. **Minor. §0, depth-two sentence: "… refutes the polynomial-sample property for SP$_1$ … with an excess that tends to $0$ as $d\to\infty$."**
   - `depth-two.md` Corollary 5.2(i) gives a *lower bound* $\gamma(\lambda)(18dc+1)^{-2}(1-o(1))$ on the excess.
   - At $c=1$ the actual excess is not known to tend to $0$. depth-two.md §0 says: "At $c=1$ the lower bound of Corollary 5.2 tends to $0$ and the known upper bound does not."
   - *Fix:* "with a certified excess of order $1/d^2\asymp1/\log^2n$, a lower bound that tends to $0$".
3. **Minor. §7.4, suggested wording for A.** Corollary 3(i) is proved at $c=1$ only (§7.1 item 3).
   - In the suggested §5.3 item 3 text, the sentence "Against competitors … the excess is $O(n^{2\alpha'-1/2})$ for every $\alpha'<1/4$ (its Corollary 3(i))" follows "for every $c>0$, $c=1$ included", so it reads as holding for every $c$. A covers SP$_c$ with $c$ growing in $n$. For such $c$ the rate is false: the clone term is $c(\bar E_*+1)/n\approx c\,n^{4\alpha-1}$, which diverges for example at $c=n^{1/2}$, $\alpha=0.2$.
   - The §10 item 5 replacement swaps only the rate clause. The surrounding A text keeps "SP$_c$, $c=1$ included" and has no "$d\le n^\alpha$".
   - *Fix:* add "at $c=1$" in both places, and "$d\le n^\alpha$" in §10 item 5. In the fixed-competitor sentence, say "for fixed $c>0$".
4. *Nit (optional).* Remark 7, first bullet: "The same holds for the limits of the Gibbs risks and posterior means." B Proposition 9.1(a) states the bound for the $\liminf_{\sigma\downarrow0}$. Since the revised definition of "good" uses $\limsup$, "liminf" is the exact word, and it suffices. This text is unchanged from before the revision.
5. *Nit (optional).* §7.4: "(the corrected `red-team.md` Proposition 6.1, refereed twice)". The corrected text was refereed once, in the second round; the first round reviewed the original. "Refereed in two rounds" would be exact.

## 3. Findings by question

**(a) Referee issues.** Every row of §10 (24 rows) was verified against the reports and the text. None is unaddressed or wrongly resolved:

- m1 / computation 4: no stray $\Lambda$, $\det$, $U^\ell$, $G_\Omega$ or $\kappa<$ remains; $\eta$ appears only in Remark 7 and §8; $\omega$ is printed by the script.
- m2 / computation 6: "In the user's words", §1, §7.1 items 1 and 6.
- m3 / computation 2: the §7.3 entry for line 562 and §7.4. The quoted A text matches A's current §5.3 item 3, §5.4 and §10 item 5, and its referee-record row.
- m4 / computation 1: matches A Theorem 4.4, (4.3), Corollaries 4.5 and 4.5a, and Remark 4.7. The numbers are from `transition_check.out`.
- m5, m6, m7 / computation 3: the three A2 sentences are quoted verbatim from red-team line 196.
- m8–m12; computation 5 and 7(a)–(d); both observations.

**(b) Mathematical correctness of the changed passages.** All correct (§1).

**(c) Claim strength.**
- Two statements are now stronger, and both are proved:
  - Corollary 3(i) at $\kappa=\frac12-2\alpha$, with the explicit $C_{L,\alpha,\delta}$;
  - Remark 8's full excess at $N_0=O(n\log^2n/a_n^2)$. This follows from A Theorem 4.4 / (4.3) for any $a_n\to0$ with $na_n\to\infty$, and A Corollary 4.5a states the $O(n\log^4n)$ case.
- The strict-$\kappa$ form of Corollary 3(i) is implied by the new form.
- No proved result was dropped. The only claim widened beyond its source is the suggested A wording of issue 3.

**(d) Cross-references.** I checked each against the current text:
- B: Lemma 2.3(a), Lemma 3.1, Corollary 8.1 ($\beta$ is its rate exponent), Remark 8.2 ($m+1$, $B'=\max\{B,1\}/\tanh1$), Proposition 9.1(a), Lemma 9.2, §9.
- A (research-notes copy, 17:09): Lemma 2.1 ($N_0$), Theorem 4.4, Corollaries 4.5 and 4.5a, Remark 4.7 (the fixed-$a$ limit is at line 472, inside Remark 4.7), §5.1 (the name (P$_L$) is A's; the brief's §1 defines the property without naming it), §5.3, §5.4, §10. The phrase "unchecked, unrefereed" matches the stage copy at lines 543 and 1039.
- depth-two.md Corollary 5.2(i) and (a): $N_0=O(n\log^4n)$ is right; see issue 2.
- E Theorem 2.7: clipped, every $N\ge m$.
- red-team (stage copy): lines 20, 30, 196, 475, 480–495, 497, 530 and 562 match verbatim, and the list of citations of Proposition 6.1 is complete.
- paper.tex: `sec:model`, `eq:energy`, `eq:teacher-energy` and `thm:strong` exist.

**(e) Paths and outputs.**
- No absolute paths.
- Every relative path resolves from `research-notes/` except `../README.md` and `red-team.md`, which are allowed to be missing.
- The author's own scripts are cited by bare file name, with §8 giving the folder. This is acceptable.
- All quoted numbers match the `.out` files: 0.678, 0.631, 160,750, the slopes, 0.228, 5.9e3, 1.48e12, 4.36 / 0.67 / 0.030, 0.37, 6.9e-15, 1.5e6 / 1.5e8, 8,401, 4,400, 0.9997, 0.49, 0.19 / 0.05, 0.73 / 0.49, 3e-14, 0.75, 1.63–1.72, the ratio table, 0.90 / 0.64, 0.92 / 0.74 (only reachable at $H=1$, since the closed/sharper ratio is at most about 0.6 for $H\ge2$), 0.200, 0.33–0.69, 0.07–0.26, 400 restarts, 0.449 / 0.462 / 0.471, $4.5\cdot10^5$, 0.4848.
