# Cross-reference check of the agnostic-learning research notes

*Published record of the final check of every cross-reference between the research notes, made at finalization. Its issues, numbered X1–X27, are listed with their ids in [`../checks/final-consistency/final-xref-issues.json`](../checks/final-consistency/final-xref-issues.json) (X3, on the README, was handled with the README check); [`final-xref-resolutions.md`](final-xref-resolutions.md) records how each was resolved, and [`final-xref-edit-check.md`](final-xref-edit-check.md) the independent check of those edits.*

Checker's report, 11 November 2026. Scope: every citation of one research note by another (by file name and result, section, equation or table number), the notes' own summaries (§0, status sections, headers), the verification status that notes attribute to each other (compared with `verification/README.md`), and every relative link and backticked path. No file was edited.

Folder: `neural-network-generalization/works-in-progress/agnostic-learning/`. Paths below are relative to it.

## Verdict

**Major flaw (one item), otherwise minor fixes.** One unrefereed red-team passage still says, without an "At finalization" note, that the conjecture is false and that TUBE and exact interpolation lose the β(λ) memorization excess; the proof notes say the opposite. Everything else is a stale status, an incomplete header, a missing qualifier or a path that does not resolve.

## What was checked and found correct

- **Links and paths.** Every Markdown link in the nine notes, in `README.md` and in `verification/README.md` resolves. Every backticked `NNG/...` and `../...` path resolves. Bare script names inside a section whose lead sentence names the folder were accepted (the convention that B's and E's revision checks adopted). Exceptions: issues 22–24.
- **Result numbers.** A script listed every result defined in A, B, C, E, small-learner-width, depth-two and red-team and every citation of the form "‹note› Theorem/Lemma/Proposition/Corollary/Remark ‹n›". Every cited number exists; "Remark 3 after Theorem C.1" is item 3 of C's list of remarks and exists.
- **Statements checked against the cited item, with hypotheses** (no issue found): A's citations of B Theorem 6.3, Theorem 6.4, Lemma 2.3(c), Proposition 6.1 and the paragraph after it, Remark 8.2, Corollaries 8.1 and 9.3, §7.5 items 1–2; A's citations of C Theorems C.2, C.5 and Proposition C.3(b), of E Theorems 2.7, 5.2, Corollaries 5.3–5.4, Proposition 4.4, §5.4(c), of small-learner-width Theorems 1, 4 and Corollary 3(i), of red-team Remark 6.2(b), §6.2, §6.4, and of `literature.md` item G1. B's citations of A Proposition 5.2 and of depth-two Corollary 5.2 and §0. E's citations of A Lemmas 2.1, 2.2(b),(e), eq. (2.4), Lemmas 3.1(a), 4.1(a),(c), 4.2(b), 4.3(b)–(d), condition (4.4), §1.4, §5.1, Propositions 5.2, 6.1(a′), 6.5, 6.6(b), 6.6a, Corollary 4.6, Remark 2.5, Proposition 8.2, Table 4.1; of B Lemmas 2.1(a), 2.2, 2.3(a), 3.1, 4.2, 5.2, 5.3(a), Theorems 6.2, 6.3, Remark 8.2, Corollary 8.1, §7.5; of C Theorem C.7. small-learner-width's citations of A Theorem 4.4, (4.3), Corollaries 4.5 and 4.5a, Remark 4.7 and of B Lemma 3.1, Lemma 9.2, Proposition 9.1(a), Remark 8.2. depth-two's citations of A §5.1, §5.4, Proposition 5.2(c), the paragraph after Proposition 8.3 ($C_1\approx5.83$), Proposition 8.2(a) at $H=1$; of B Theorems 6.3–6.4, Proposition 6.1, Lemmas 3.1 and 5.3, Corollary 8.1 at $H=1$ ($\Xi_n$, $\beta$, $c=n^{(2-8\alpha)/3}$), Proposition 9.1(a),(b), §7.5 item 3, §9 Discussion, Remark 9.4, B's §0 and §11 open items (quoted exactly); of small-learner-width Theorem 1(c) (Remark 5.5's display, with $K'$). `literature.md`'s pointers to C Theorems C.1, C.2, C.5–C.7 and Remark 3 after C.1, to B Lemmas 5.1–5.2 and Theorems 6.3, 7.4, to A Theorem 4.4 and Corollary 4.5, and to E Theorem 5.2 and Proposition 4.4. The brief's pointer to A Proposition 5.2.
- **Red-team pointers.** The pointer lines for §5 and Proposition 6.1 describe the current depth-two.md and small-learner-width.md results with their qualifiers. Every "verbatim" replacement listed in red-team's record matches its source in small-learner-width.md §7.3 and depth-two.md §6. The status table's claims about which reports re-checked §1 and §3 (RT-aggregate-logic §3.3 and §3.6, RT-width-logic §2.2 and §2.9, RT-width-computation §1, RT-depth2-logic §§2.1–2.3, RT-depth2-computation Issue 6) were opened and hold. Red-team's "At finalization" notes on §0 items 1–4 and 8 and on §8 agree with A, B, C and E. E's "Earlier sketches" and §7 item 6 now describe the finalized red-team §8 correctly.
- **Verification statuses** attributed by A (to B, small-learner-width, red-team Proposition 4.1 and Remark 6.2), by depth-two (to A, B, small-learner-width), by small-learner-width (to A, B), by `literature.md` (to B) and in red-team's status table agree with `verification/README.md`, except issues 2, 3 and 5. The counts in the headers of A, B, small-learner-width and red-team agree with their records and with `verification/README.md`; the scope-report counts of C (14 issues, 7 on the README draft, 1 on the brief) and E (11 issues, 5 points on E) agree too.

## Issues

Severity "major" is used only where a reader would be misled about what is proved or refuted.

### 1. (major) red-team.md, §7 item 1 (also §0 item 7 and §6.1): "the literal conjecture is false", with TUBE grouped in, and no "At finalization" note

> 1. **The literal conjecture is false in the regime that matters for wide Bayesian learners.** Take any learner that conditions closely on the training outputs: SP$_c$ with $c\ll n^{1-1/H}$, TUBE with $\rho$ below the residual level, or exact interpolation. At width beyond about $n$ it can lose roughly half of the irreducible error, $\beta(\lambda)\,\mathrm{Var}(y\mid x)$ with $\beta\le0.517$, relative to the trivial competitor.

The header promises that "Where a later note has settled or corrected a statement made here, a note beginning 'At finalization' says so", and the status table lists only §7 items 3, 5 and 6 as amended. Item 1 has no note, yet A corrects it on both counts. A §0.1, §5.4 and §10 (and README §3, "It refutes particular learners, not the conjecture") say that Claim A refutes (P$_L$) only for SP$_c$ with $cK_{\rm mem}=o(n)$, at learner widths $N\ge N_0$ on laws with $d=\log_2n$, and that the conjecture is not refuted, since B's tempered learner has (P$_L$). A §0.1 also says that "TUBE$_\rho$ does not fail by memorizing noise": for $\rho\le1$ its posterior is undefined once an atom carries both labels (A Lemma 6.4), and for $\rho>1$ it is centred at the midrange of the labels (A Propositions 6.3, 6.6, 6.6a). The β(λ) loss is proved for SP$_c$ only, and "exact interpolation" is undefined on repeated atoms with conflicting labels. Only §0 item 1 carries a note explaining in what sense "A refutes the width-uniform conjecture"; §0 item 7 ("The conjecture still fails with deterministic labels, atomless inputs, or a test distribution that excludes the training inputs") and §6.1 ("Versions that still fail", citing red-team's own Proposition 2.4 for A′, superseded by A Theorem 7.2) use the same framing without one.

*Fix.* Append to §7 item 1: "[At finalization: in the terms of `A-tight-conditioning-fails.md` (its §0.1 and §5.4), this refutes the property (P$_L$) for SP$_c$ with $cK_{\rm mem}=o(n)$, at learner widths $N\ge N_0={\rm poly}(n)$ on laws whose dimension $d=\log_2n$ grows, not the conjecture, which `B-tempered-likelihood.md` satisfies with tempered $c$ for clipped predictions. The loss $\beta(\lambda)\mathrm{Var}(y\mid x)$ is proved for SP$_c$ only. TUBE$_\rho$ fails for a different reason: for $\rho\le1$ its posterior is undefined once an atom carries both labels, and for $\rho>1$ it centres its outputs at the midrange of the labels (A Lemma 6.4 and Propositions 6.3, 6.6 and 6.6a).]" Add to §0 item 7 and to the §6.1 heading "[At finalization: "fails" is meant as in the note on item 1; A′ is proved in A Theorem 7.2 and Corollary 7.2b.]", and list §7 item 1 among the amended items in the status table and the record.

### 2. (minor) A-tight-conditioning-fails.md, §10 item 4: depth-two's refereeing status

> the refereed repair of `red-team.md` §5 (four referee rounds in all, the last two on its final text; see its header)

depth-two.md's header says it was "re-refereed twice during finalization" and that "The changes made in answer to the second re-refereeing round (§0.6) have not been refereed again". `verification/README.md` says that "the last two referee rounds of the depth-two note, read intermediate texts that are not published". The final check (`verification/depth-two-revision-check.md`, point 4) flagged the earlier header wording "re-refereed twice in its final form" for this reason, and depth-two's header was corrected; A's parenthetical still says "on its final text" and points to the header that contradicts it.

*Fix.* "(refereed in two rounds and re-refereed twice during finalization, on intermediate texts; the changes made after the last round were checked independently but not refereed again; see its header)".

### 3. (minor) README.md, §8, "Depth two": same wording

> refereed in two rounds and re-refereed twice in its final form

Same problem as issue 2; this is the wording that `verification/depth-two-revision-check.md` point 4 called loose.

*Fix.* "refereed in two rounds and re-refereed twice during finalization".

### 4. (minor) A-tight-conditioning-fails.md, Remark 6.6b: describes red-team Proposition 4.1 as it was before finalization

> and, for the strong prior at small $\sigma$, bounds the posterior expected loss of the clipped outputs by $(\tau+\rho_0)^2+4\varepsilon/3$ at the polynomial sample size of the continuous-domain paper's Theorem `strong`.

and

> Its statement that such conditioning never memorizes holds only in the energy sense.

The finalized Proposition 4.1 has three parts: (a) $\min\{4,(\tau+\rho_0)^2\}+\tfrac43\varepsilon$; (b) the sharper $\rho^2+\varepsilon$, at a sample size that depends neither on $\rho,\rho_0,\tau$ nor on $N$ (this is the bound README §2 and §8 cite); (c) the energy statement. A quotes only (a), and refers to a "statement that such conditioning never memorizes" that red-team.md no longer contains (red-team's record, point 6(d), notes this). The tightness example in the same remark also omits the qualifier the finalized red-team states: it holds on samples that contain a label $-c_0$, of probability $1-p^n$.

*Fix.* "… bounds the posterior expected loss of the clipped outputs by $\min\{4,(\tau+\rho_0)^2\}+4\varepsilon/3$ (its part (a)) and, at a sample size polynomial in $d,C,B,1/\varepsilon,\log(1/\delta)$ that does not depend on $\rho,\rho_0,\tau$ or $N$, by $\rho^2+\varepsilon$ (its part (b)). Its part (c) keeps the posterior at energy at most $E_*+2$ for every $n$, so it excludes memorization only in the energy sense." In the example add "on samples that contain a label $-c_0$ (probability $1-p^n$)". Adjust the "no conflict" sentence to cover (b): with $\rho>\rho_0\ge1$, $\rho^2+\varepsilon>1\ge L_D(0)$.

### 5. (minor) A-tight-conditioning-fails.md, §5.4 (bullet on E) and §10 item 6: E's refereeing status is incomplete

> Two referee reports (`../verification/E-logic.md`, `../verification/E-computation.md`) found it correct, with minor fixes.

and in §10 item 6:

> Two referee reports on E-finite-prior-scale.md (`../verification/E-logic.md`, `../verification/E-computation.md`) found this correct, with minor fixes.

E was also reviewed by a scope referee (`verification/E-scope.md`; `verification/README.md`, row E), who found E's theorems correct as stated; the report's major issue concerned the README draft. The answers were checked (`verification/E-scope-revision-check.md`).

*Fix.* "Three referee reports (logic, computation and, on the final text, scope: `../verification/E-logic.md`, `../verification/E-computation.md`, `../verification/E-scope.md`) found it correct, with minor fixes in E; the scope report's major issue concerned the README draft." Same change in §10 item 6.

### 6. (minor) A-tight-conditioning-fails.md, record (second-check row 5, third-check row 2) and header: links the finalization edits removed

> fixed: the two reports are linked there too

Third-check row 2 says the two width reports are linked in §5.4, "The heuristic", second paragraph; second-check row 5 says the width reports are linked at "§10 items 4–5" and the reports behind §5 "in §10 item 4". The lead editor's finalization edits (i)–(ii) replaced those citations with `small-learner-width.md` and `depth-two.md`, and the current §5.4 "The heuristic", §10 item 4 and §10 item 5 contain no link to any RT-width or RT-depth2 report. The closing note covers only rows "that describe these results as under review or in repair", not these rows. The header ("the last three tables of the record answer three independent checks of this revision") does not mention that the text was edited after the third check.

*Fix.* Extend the closing note: "Edits (i) and (ii) also removed the links to the two width reports from §5.4, "The heuristic", and §10 item 5, and to the reports on `red-team.md` §5 from §10 item 4, which second-check row 5 and third-check row 2 describe; those reports are linked from `small-learner-width.md` and `depth-two.md`." (Or restore the links.) Add to the header: "After the third check the lead editor updated three citations; the end of the record lists them."

### 7. (minor) A-tight-conditioning-fails.md, §0.1 and §0.2 item 10: depth two and small widths listed as open without pointers

> Open or not covered: fixed input dimension beyond the cube family; input laws with density ratio $2^{o(d^2)}$ and noisy labels; depth two; learner widths below $N_0$; the progressive-mixture predictor; unclipped predictors for $n^{1-1/H}\lesssim c\lesssim n^{1-1/L}$; TUBE on continuous i.i.d. inputs. SP$_c$ at finite prior scale is treated in E-finite-prior-scale.md.

§0.1 ("Learners and predictors not covered. Learner widths below $N_0={\rm poly}(n)$; the progressive-mixture predictor; depth two; SP$_c$ under the finite-scale prior $\mu_{N,\gamma}$, which E-finite-prior-scale.md treats; …") has the same gap. Both summaries point to E for the finite scale but not to `depth-two.md` (SP$_c$ fails (P$_2$) for every $c\le{\rm polylog}(n)$) or `small-learner-width.md` (positive result at width $n^\alpha$, $\alpha<1/4$), which §10 items 4–5 cite. A reader of §0 is told that depth two is open.

*Fix.* Append to §0.2 item 10: "Depth two is treated in `depth-two.md` (`depth-two.md`): SP$_c$ fails (P$_2$) for every $c\le{\rm polylog}(n)$, and whether its excess at $c=1$ tends to $0$ is open. Small learner widths are treated in `small-learner-width.md` (`small-learner-width.md`) (§10 items 4–5)." Add the same two pointers in §0.1.

### 8. (minor) C-fixed-temperature-bayes.md, header: the check of the scope revision is not mentioned

> The changes made in answer to the scope report have not been refereed again.

The record ends with "Check of the scope revision" (`verification/C-scope-revision-check.md`, listed in `verification/README.md`), which found issues 7–12 resolved and the changed passages correct. The header's list of what the record contains stops at the scope report.

*Fix.* Append: "An independent check of these changes ([`../verification/C-scope-revision-check.md`](../verification/C-scope-revision-check.md)) found them resolved as stated; the end of the record gives its three points."

### 9. (minor) E-finite-prior-scale.md, header: the check of the scope revision is not mentioned

> These answers have not been refereed.

As in issue 8: §9 ends with "Check of the scope revision" (`verification/E-scope-revision-check.md`), which re-derived the new numbers and found every issue resolved.

*Fix.* "These answers have not been refereed; an independent check ([`../verification/E-scope-revision-check.md`](../verification/E-scope-revision-check.md)) found them resolved as stated, and the end of Section 9 records its three points."

### 10. (minor) depth-two.md, header: the check of the final revision is not mentioned

> The changes made in answer to the second re-refereeing round (§0.6) have not been refereed again.

§9 ends with "Check of the final revision" (`verification/depth-two-revision-check.md`), which found every point resolved and no mathematical error in a changed passage; red-team.md's status table cites it.

*Fix.* Append: "An independent check of that revision ([`../verification/depth-two-revision-check.md`](../verification/depth-two-revision-check.md)) found every point resolved and no mathematical error in a changed passage; the end of §9 records how its points were resolved."

### 11. (minor) small-learner-width.md, §7.3, opening paragraph: stale future tense about red-team.md

> When `red-team.md` is finalized, lines 480–497 of its §6.3 are replaced by a pointer to this note.

red-team.md is finalized: §6.3 now holds the pointer, and its "Record of the finalization" lists how each entry of §7.3 was applied (verbatim, except the two entries for lines 480–497, which became the pointer and a summary). §7.4 was updated to say that A now uses the suggested wording; §7.3 was not.

*Fix.* "In the finalized `red-team.md`, lines 480–497 of its §6.3 have been replaced by a pointer to this note, and the other entries below have been applied verbatim (`red-team.md`, "Record of the finalization")."

### 12. (minor) small-learner-width.md, §7.3, entry "§8": E's positive result cited without its range of θ

> The finite-scale positive direction is proved by another route in `E-finite-prior-scale.md` Theorem 2.7, for clipped predictions at every width $N\ge m$.

E Theorem 2.7 holds only for $\theta<\theta_{L,\gamma}$, which equals $1/H$ when $\gamma\ge2-1/H$ and is smaller for $1\le\gamma<2-1/H$; the case $\gamma=1$, $L\ge3$ rests on an imported mean-field cover. red-team's own note on §8 states the threshold.

*Fix.* "… for clipped predictions at every width $N\ge m$, for $\theta<\theta_{L,\gamma}$ ($=1/H$ when $\gamma\ge2-1/H$; smaller for $1\le\gamma<2-1/H$, and at $\gamma=1$ conditional on an imported mean-field cover)."

### 13. (minor) B-tempered-likelihood.md, §0 "Still open" and §11 Open (v): finite scale listed as open without a pointer to E

> - Finite prior scale (Claim E).

and

> - (v) Finite prior scale $\gamma\ge1$ (Claim E).

The finalization notes added pointers to `depth-two.md` but B never mentions `E-finite-prior-scale.md`, which treats Claim E.

*Fix.* Add to both: "At finalization: treated in [`E-finite-prior-scale.md` (`E-finite-prior-scale.md`). For clipped predictions the positive direction holds for $\theta<\theta_{L,\gamma}$, which is $1/H$ when $L\ge3$ and $\gamma\ge2-1/H$ and smaller below (its Theorem 2.7); at depth $L\ge3$, $c=1$ and $\theta>1/H$ fail at every $\gamma\ge1$ (its Theorem 5.2). Unclipped predictions and the $n^\alpha$ classes are open there.]"

### 14. (minor) red-team.md, §7 item 2: tempering claims without the clipped qualifier, superseded competitor size, no note

> With $c=n^{1-\theta}$ and $\theta<1/H$, the strong-prior posterior competes with every width-$m$, weight-$B$ network at every learner width. Its rate is $\tilde O(\mathrm{poly}(d,m,B)\,n^{-1/(H+2)})$, and it can compete with networks of size $mB$ up to about $n^{1/(H(H+2))}$ (for $H\ge2$).

B proves $\theta<1/H$ for clipped predictions only (Theorem 6.3; unclipped and the Bayes model average only for $\theta<1/L$, Theorem 6.4). The competitor-size figure comes from red-team's weaker Theorem 3.2 at $\theta=1/(H+2)$; B Corollary 8.1 reaches width and weights $n^\alpha$ for every $\alpha<1/(4H)$ (so $mB$ up to nearly $n^{1/(2H)}$), and Corollary 9.3 shows no $c(n)$ works beyond $\alpha>L/(2H(2L-1))$. "Up to about" reads as a limit. No "At finalization" note, although §3 is marked superseded by B.

*Fix.* Insert "with clipped predictions" after "competes", and append "[At finalization: proved in `B-tempered-likelihood.md` Theorem 6.3 for clipped predictions (unclipped only for $\theta<1/L$, Theorem 6.4). Its Corollary 8.1 covers competitors with width and weights up to $n^\alpha$ for every $\alpha<1/(4H)$, and its Corollary 9.3 shows that no $c(n)$ works, uniformly over laws, beyond $\alpha=L/(2H(2L-1))$.]"

### 15. (minor) red-team.md, §6.3 item 1: cites only its own superseded corollary, without the clipped qualifier

> 1. **Tempered conditioning**, $c=n^{1-\theta}$ with $\theta<1/H$ (Corollary 3.3).

The heading note says each item is "proved here or in the note each item cites", and items 2–4 point to refereed results, but item 1 cites red-team's own Corollary 3.3 (unrefereed; §3 superseded by B), and $\theta<1/H$ is only part (a) of that corollary, for clipped predictions.

*Fix.* "1. **Tempered conditioning**, $c=n^{1-\theta}$ with $\theta<1/H$ for clipped predictions ($\theta<1/L$ unclipped) (Corollary 3.3; proved with explicit sample sizes in `B-tempered-likelihood.md` Theorems 6.3–6.4)."

### 16. (minor) depth-two.md, §6, erratum for red-team §0 item 6 (copied verbatim into red-team.md §0 item 6): source of the "+o(1)" positive range

> (`depth-two.md` Remark 5.7a, from `B-tempered-likelihood.md` Proposition 6.1, Corollary 8.1 and Proposition 9.1)

The range "holds for $\log^2n\ll c\le n^{1-\epsilon}$ (clipped) and $\sqrt n\log n\ll c\le n^{1-\epsilon}$ (all predictors)" comes in Remark 5.7a from B's Proposition 6.1 with Lemma 5.3(a) and, for the unclipped readings, Lemma 5.3(b) and Lemma 3.1; Corollary 8.1 covers only $c=n^{(2-8\alpha)/3}$. depth-two's §0 cites it correctly ("Remark 5.7a, from B's Proposition 6.1 and Lemma 5.3").

*Fix.* In both files: "(`depth-two.md` Remark 5.7a, from `B-tempered-likelihood.md` Proposition 6.1 with Lemmas 5.3 and 3.1, and Proposition 9.1)".

### 17. (minor) B-tempered-likelihood.md, §7.5 item 3: the asymptotic bound is Corollary 5.2(i), and its range is wider

> The red-team report (`red-team.md`, Theorem 5.1, not re-proved here) gives excess $\ge(0.0999-o(1))/(18dc+1)^2$ for bounded $c$ at $n=2^d$.

The displayed asymptotic bound is depth-two Corollary 5.2(i) (Theorem 5.1 gives the non-asymptotic $\max\{\Psi_{\rm tri},\Psi_{\rm cor}\}$), and it holds for every $0<c\le{\rm poly}(d)$ along $n=\lceil\lambda2^d\rceil$, with $\gamma(1)=0.0999$. The finalization note says only that "that theorem … is Theorem 5.1 of depth-two.md".

*Fix.* In the finalization note: "… is Theorem 5.1 of `depth-two.md`, and the displayed bound is its Corollary 5.2(i), which holds for every $0<c\le{\rm poly}(d)$ along $n=\lceil\lambda2^d\rceil$ ($\gamma(1)=0.0999$ at $\lambda=1$) …".

### 18. (minor) problem-brief.md, header note on Claim C

> * *Claim C is proved for clipped predictions only.

Claim C has two halves. The positive half (the progressive-mixture bound at polynomial width) is proved for clipped outputs only; the negative half ("width-uniformity fails even for constant targets") is proved for clipped and unclipped predictors alike (C Theorem C.5(e)).

*Fix.* "The positive half of Claim C is proved for clipped predictions only (C Theorems C.1–C.2, in expectation for the progressive mixture, with high-probability versions in Theorems C.6–C.7); the failure of width-uniformity holds for clipped and unclipped predictors (Theorem C.5(e))."

### 19. (minor) problem-brief.md, header note on Claim B: weight-bound qualifier and the cover threshold

> The competitor's weights must be polynomially bounded with a small exponent

B's scope referee (issue 1) flagged the same phrasing in B because it drops uniformity over laws and the learner-width condition; for a fixed law no weight bound is needed (B Remark 9.4). The same bullet's "not only below the energy-cover threshold 1/(4(L−1))" holds for $L\ge3$ only; at $L=2$ the cover gives $\theta<1/2$ (B Theorem 6.2, §11).

*Fix.* "For a guarantee uniform over laws and input dimensions, at every learner width at least the competitors' width, the competitors' weights must be bounded by $n^\alpha$ with a small $\alpha$ (B Corollary 9.3); for a fixed law no weight bound is needed (B Remark 9.4)." and "the energy-cover threshold $1/(4(L-1))$ ($1/2$ at $L=2$)".

### 20. (minor) problem-brief.md, header: no note on Claim A′

> This answers the objection that real inputs do not

The header corrects A, B and C but not A′, whose near-atomic character was one of the three "major for reporting" scope issues on A (`verification/README.md`). A proves A′ on a different law (Theorem 7.2), whose density is $2^{\Theta(d^2)}$ times uniform (Proposition 7.4); laws with bounded density are open.

*Fix.* Add a header bullet: "*Claim A′ is proved on a different law (A-tight-conditioning-fails.md (`A-tight-conditioning-fails.md`), Theorem 7.2), which is near-atomic at the learner's resolution (density $2^{\Theta(d^2)}$ times uniform, Proposition 7.4). It meets the two objections formally; for input laws with bounded density, with noisy labels, the question is open.*"

### 21. (minor) problem-brief.md, §1: "Equivalently" is not flagged

> Equivalently, test loss <= min over depth-L MLPs with width and weights

red-team §2.3 A3 shows the two formulations are equivalent only when the $o(1)$ is polynomially small and $d\le n^{O(1)}$, and depth-two Remark 5.7a ("The two formulations differ at depth two") exhibits $c=\log^3n$, where one fails and the other holds. The header lists corrections to §4 only.

*Fix.* Add a header bullet: "*The two formulations in §1 are not equivalent in general: they agree when the $o(1)$ is polynomially small and $d\le n^{O(1)}$ (red-team.md (`red-team.md`) §2.3 A3), and they differ at depth two (depth-two.md (`depth-two.md`) Remark 5.7a).*"

### 22. (minor) C-fixed-temperature-bayes.md, §C.9 "Cited": path does not resolve

> * `slt-finite-sample/README.md` §3, re-derived in Appendix C.B.

From `research-notes/` this resolves to nothing; elsewhere C writes the full path.

*Fix.* `NNG/works-in-progress/slt-finite-sample/README.md` §3.

### 23. (minor) C-fixed-temperature-bayes.md §C.0 and literature.md §1.2: `paper.tex` used before it is introduced

> ($\gamma\ge1$, Gaussian or any coordinate law of `paper.tex` eq. `law`)

C uses `paper.tex` twice in §C.0 item 2 and gives the full path only in §C.1.2, without "(cited below as `paper.tex`)". `literature.md` does the same: "* $\mu=\mu_{N,\gamma}$, with Gaussian coordinates or any coordinate law of `paper.tex` eq. `law`;" (Corollary 2) precedes the full path in its proof. E's second revision check (point 5) fixed exactly this in E.

*Fix.* At the first use in each note: "`NNG/side-results/continuous-domains/source/paper.tex` (cited below as `paper.tex`)".

### 24. (minor) A-tight-conditioning-fails.md, Appendix R2 "Numbers and scripts" and first-check row 5: referee outputs named without their folder

> agree with the computation referee's `c10_cor45_width.out` and `c2_table41.out` to the printed digits

These files, and `c2b_flatness.out` in the same paragraph and in first-check row 5, are in `../checks/verify-A-computation/`, not in `../checks/A/`, the folder that §9 names. §4.3 already writes the full path.

*Fix.* `../checks/verify-A-computation/c10_cor45_width.out`, `../checks/verify-A-computation/c2_table41.out`, `../checks/verify-A-computation/c2b_flatness.out`.

### 25. (minor) literature.md, §1.2, remark (iv) after Corollary 2: "cold limit"

> The atom failure is specific to the cold limit, not to Bayesian averaging.

E Theorem 5.2 shows the same atom failure for the finite-scale posterior, with no limit taken ($\sigma^2=N^{-\gamma}$, at widths $N\ge N_*(n)$). The posterior there is still cold (per-sample inverse temperature $N^\gamma/(2c)$), so the point survives, but "the cold limit" now reads as the $\sigma\to0$ limit only. The survey otherwise adds "At finalization" notes where a proof note settled a point.

*Fix.* "The atom failure is specific to cold posteriors, not to Bayesian averaging. [At finalization: `E-finite-prior-scale.md` Theorem 5.2 proves it at finite prior scale, with no limit, at widths $N\ge N_*(n)$, where the per-sample inverse temperature $N^\gamma/(2c)$ is large.]"

### 26. (minor) literature.md, §0 item 4, "At finalization" note: B's sharpness without the learner-width qualifier

> Its Theorem 7.4 shows that $\theta>1/H$ fails for $H\ge2$, on the noisy cube with $d=\log_2n$.

B Theorem 7.4(b) holds at learner widths $N\ge N_0(n)=\lceil2(d+1)^3n^{1+\theta}\ln2\rceil+1$; B's scope referee (issue 9) required this qualifier on every sharpness summary, and red-team's note on §0 item 4 states it.

*Fix.* "… on the noisy cube with $d=\log_2n$, at learner widths $N\ge N_0(n)={\rm poly}(n)$."

### 27. (minor) depth-two.md, §6: errata framed as pending, although red-team.md has applied them

> The first group of items gives replacement text for the places elsewhere in `red-team.md` that summarise §5; the second records the corrections to §5 itself.

Each item reads "Replace … by …", but red-team.md's record lists every one as applied verbatim. A reader cannot tell from depth-two that the replacements are in place.

*Fix.* Add: "All replacements in the first group have been made, verbatim, in the finalized `red-team.md` (its "Record of the finalization")."
