# Third check of the revision of A (`research-notes/A-tight-conditioning-fails.md`)

*Published record of a check of the revised note, made during finalization. Paths under `stage/` refer to the lead's unpublished working copies; the pre-revision text there is the version that the second-round referee reports reviewed, published as [`A-revision-1.md`](A-revision-1.md). This check's scripts and outputs are in the `../checks/revision-check-*` folder named below. Re-runs of the note's own scripts, which some reports keep in a `rerun/` subfolder, are not published; each report says whether they reproduced the recorded outputs.*

**Verdict: minor fixes.** Every second-round referee issue is fixed in the body or declined with a valid reason, and so are the five points of the second check (`A-revision-check-2.md`). I found no mathematical error in any changed passage. Every new number reproduces, both from my own code and from re-running the scripts. No section or result number moved. Every relative path resolves, and every quoted output matches its `.out` file. Three trivial points remain (end of this report). The first was introduced in the latest round. None affects a theorem, lemma, proposition or corollary.

**What I compared and read.**

* The version checked is `research-notes/A-tight-conditioning-fails.md` as of 18:08 (1388 lines). It differs slightly from `stage/a_r4/round3.diff`, which predates the last edits.
* Diffs: the pre-revision text (`stage/A-tight-conditioning-fails.md`, 1123 lines) against the current text, and the text the second check read (`stage/a_r4/before.md`) against the current text.
* Read in full: the current text and the three second-round reports.
* Read the cited passages of: B (final), C and E (`research-notes/` versions), `stage/red-team.md` (§4.3, §5, §6), the verdict sections of the RT reports now linked, the brief §§1–2, `NNG/README.md` main results 1 and 4, and `stage/literature.md` G1.

Scratch files are in `../checks/revision-check-A-3/`: `diff.txt`, `diff_r2.txt`, `indep.py` and `indep.out`, `symbols.py` and `symbols2.py` (with `symbols.out`), `labels.py`, `refs.py` and `rerun/`.

## (a) Referee issues

Each issue is fixed at the location given in the R2 table, and I checked every location:

* all 16 logic issues;
* computation issues 1(a)–7 and the §4 remark;
* scope N1–N9 (the optional part of N1 and all three parts of N9 included) and the suggestion in §5 item 2.

Two suggestions are declined, both with valid reasons:

* The optional remark in logic issue 11 is not added, because the referee marks it as unchecked.
* The symbols of logic issue 16 are not renamed, because E applies Lemma 4.2(b) "with $B=\eta n$" (E, ll. 571 and 576).

Computation issue 5 is fixed with a corrected value: the referee's 0.226 is a rounding of 0.2255, and the exact value is 0.225472.

The second check's points are all fixed: the Appendix R notes and preamble (point 1), the §1.4 symbol list (point 2), B Lemma 2.3(c) with $N\ge m$ and slack $t$ (point 3), the Proposition 6.6 consequence (point 4), and the RT links (point 5).

* I re-checked every Appendix R entry against the current text. No entry misdescribes it without a note.
* An independent search of the seven listed symbols, including letters inside products such as $mk_t$, found no use missing from §1.4.

**Unaddressed issues: none.**

## (b) Mathematics of the changed passages

I re-derived each of the following:

* **Corollary 4.5a.** $a'_d\ge a_d$ keeps the bound on the $9(H+1)c_d/(2a2^d)$ term. $N_0\le44.36\,d^3(d+1)2^d+1\le45\,d^3(d+1)2^d$.
* **Remark 5.1a.** Under (R1), $(1-\epsilon')e_d\ge e_d-\epsilon'$. Also checked the case $e_d<\epsilon'$.
* **Proposition 6.1(a′).** The bounds $\ell_d$ and $u_d$.
* **Proposition 6.6a.**
  * (a)–(e).
  * Under (R2): $\Pr(\mathcal G^c)<1-\delta$ if and only if $n>\frac{2M}{1-\eta_0}\log\frac{2M}{1-\delta}$.
  * Under (R1): $\frac12(1+\Pr(\mathcal G^c))<1-\delta$ if and only if $\Pr(\mathcal G^c)<1-2\delta$.
* **Remark 6.6b.** $\rho_0\ge1$ when an input carries both labels. Then $\tau+\rho_0>3\rho_0\ge3$, so the bound exceeds $9$.
* **Proposition 7.2a.** Every inequality: $R'\le3n+3$, $2\sqrt{3+3/n}=3.481$ and $2\sqrt2+3/n=2.858$ at $n=100$.
* **Corollary 7.2b.**
* **Remark 4.7.** The closed form for $a^*$.
* **Exponents in §5.3–§5.4.**
  * The competitor term is $n^{4\alpha'-1/2}$, so the display gives a polynomially small excess only for $\alpha'<1/8$.
  * $2\alpha<\beta$ if and only if $\alpha<1/(6H+4)$.
  * The parameter-count term vanishes when $N=o(\sqrt{n/\log n})$.
* **The new §5.4 bound.** $\hat L_S(z_w)\le\hat L_S(g)+c(E_*+t)/n$ follows from $F(w)\le F(w_g)+t$ and $\kappa_N(w_g)\le E_*$.
* **The (U2) proviso.** $T$-invariance and integrability give mean $0$.

**Independent recomputation.** `indep.py` uses mpmath and is written from the text's formulas. Its output `indep.out` agrees with the text to the printed digits for:

* Table 4.1, all rows and both $\lambda$, including the last column. The reduction factors run from $2.347$ to $2.384\cdot10^{13}$.
* Theorem 7.2: $0.0015$, $0.1756$, $0.1088$ and $0.4543$.
* Proposition 7.2a: $0.2489$, $0.4337$, $0.4063$ and $0.4845$, with $\max c(K+t)/n=0.0381$.
* The fixed-$a$ values at finite $d$.

The computation referee's table prints $2.2\cdot10^{29}$ and $0.0125$ where Table 4.1 prints $2.1\cdot10^{29}$ and $0.012$. The exact values are $2.146\cdot10^{29}$ and $0.0124985$, so the text is right.

**Re-runs.** I re-ran `r1_table41`, `r1_fixed_d`, `r1_density`, `r1_tube_fixed_d`, `r1_misc` and `r2_numbers` in a scratch copy. Each output is byte-identical, and each run took at most 2.4 s.

## (c) Strengthening and dropped results

Nothing claims more than is proved.

* The new results (4.5a, 5.1a, 6.6a, 7.2a, 7.2b) are proved.
* Every other change qualifies a statement or corrects an understatement (Proposition 8.3(b)).
* The downgrades are recorded as "weakened": Remark 7.5 is now an interpretation, the $\sigma$-threshold of Proposition 5.1 depends on more parameters, and so do the (U2) proviso and the B Lemma 2.3(c) citation.
* No proved result was dropped: Theorem 7.2 and Propositions 6.6 and 7.4 keep their statements.

## (d) Numbering

* **Additions only.** Corollary 4.5a, Remark 5.1a, Proposition 6.6a, Remark 6.6b, Proposition 7.2a, Corollary 7.2b, and Appendix R2 with its "Referee record".
* **Unchanged.** All section headers, in the same order, the 17 equation tags and Tables 4.1–7.1.
* **Internal references.** Every one resolves.

## (e) Cross-references

Each cited item says what A states.

* **B (final).**
  * Lemma 2.3(c), with its hypothesis $N\ge m$ and slack $\zeta$, and Remark 6.1a (theorems at $\zeta=1$).
  * Proposition 6.1 and the paragraph after it.
  * Theorems 6.3 and 6.4.
  * Corollary 8.1 ($H\ge2$, $\alpha<1/(4H)$, $N\ge n^\alpha$, clipped predictions, the error term and $\beta$).
  * Remark 8.2, Corollary 9.3(b) with Remark 9.4, and §7.5 items 1–2.
  * The three referee verdicts.
* **E.**
  * §1.1 (the readout is a centred Gaussian).
  * Theorem 2.7 ($\theta_{L,\gamma}$, $B\ge1$, the mean-field cover at $\gamma=1$).
  * Proposition 4.4, Theorem 5.2, Corollaries 5.3–5.4 and §5.4(c).
  * Both referee verdicts.
* **C.** Theorems C.2 and C.5, and Proposition C.3(b).
* **Red-team results.** Each is cited with exactly the prescribed status:
  * Proposition 4.1, with the energy sense of "never memorizes", the bound $(\tau+\rho_0)^2+4\varepsilon/3$ and the exact example.
  * Proposition 6.1: "refereed with a corrected rate, repair under review"; $\alpha<1/8$ as displayed, and $\alpha<1/4$ at rate $\tilde O(n^{2\alpha-1/2})$ with the Bernstein step.
  * Remark 6.2, with its $\tau$ condition.
  * §5: the proofs are correct, and the sentence of Corollary 5.2 is false for $c\to0$.
* **The newly linked RT reports** have the verdicts that A states:
  * RT-width-logic and RT-width-computation: "the display is correct", and the stated rate is wrong;
  * RT-tube-logic and RT-tube-computation: minor fixes;
  * RT-aggregate-logic: minor fixes;
  * RT-depth2-logic: "the three proofs are correct";
  * RT-depth2-computation: minor fixes.
* **Other sources.** Brief §§1–2, `NNG/README.md` main results 1 and 4, and `literature.md` G1.

## (f) Paths and outputs

* There are no absolute paths.
* Every link and every backticked path resolves from `research-notes/`. The exceptions are `../README.md`, `red-team.md` and `literature.md`, which may be missing for now.
* The bare script names in §9 exist in `../checks/A/`. The old names (`A.md`, `A.r1.md`, `A_scripts/` and so on) appear only as former names.
* Every quoted output matches its `.out` file:
  * the eight first-version outputs;
  * the five `r1_*` outputs and `r2_numbers`;
  * the referees' `c3b`, `c5`, `c7`, `c8` (8 configurations), `c10` and `c2_table41`;
  * `c2b` (with the stated $0.4062$ against $0.4063$);
  * `v1_constants` ($0.9999999750$, at 50 digits);
  * `tube_symmetry` and `scope_numbers`.

## Remaining points (all trivial)

1. **The scope of the (U2) proviso (introduced in this round).** The sentence added to (U2) (l. 669) says that "the statements **below** that use (U2)" assume mean-zero outputs. But the record's last bullet (l. 1388) says that it also covers §0.2 item 6 and the remark after Lemma 6.2. Both of these come before §6.2.
   * §0.2 item 6 (l. 48) still says that Proposition 6.6 gives the failure "for any prior when $\rho(n)\le1$", under either convention.
   * That is false under (U2) for a prior whose outputs have prior mean $\eta_0$, because the fallback is then the Bayes predictor.

   *Fix:* "the statements of this note that use (U2), including the summaries in §0.2 item 6 and after Lemma 6.2". Alternatively, add the mean-zero proviso to §0.2 item 6.
2. **Record row 5, second check (l. 1383).** It says that the width reports are linked "where the status of Proposition 6.1 is stated". §5.4, "The heuristic", second paragraph (l. 597), also states that status, without links; it points to §5.3 item 3, which has them.

   *Fix:* add the links there, or say "linked in §5.3 item 3 and §10 item 5".
3. **§9 item 6 (l. 1109), unchanged since the first version (optional).** "The data term it would remove, which is $G/c\le10$" uses a symbol $G$ that this note never defines.
   * The outputs support the inequality if $G$ is the reduction of the data term: $(160.33-2.98)/16\approx9.8$ at $c=16$.
   * The zero network's own data term is $160.33/16=10.02$.

   *Fix:* define $G$, or write "$(\Delta_0-\Delta)/c\approx9.8$".
