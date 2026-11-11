# Check of the second revision of A (`research-notes/A-tight-conditioning-fails.md`)

*Published record of a check of the revised note, made during finalization. Paths under `stage/` refer to the lead's unpublished working copies; the pre-revision text there is the version that the second-round referee reports reviewed, published as [`A-revision-1.md`](A-revision-1.md). This check's scripts and outputs are in the `../checks/revision-check-*` folder named below. Re-runs of the note's own scripts, which some reports keep in a `rerun/` subfolder, are not published; each report says whether they reproduced the recorded outputs.*

**Verdict: minor fixes.** Every referee issue of the second round is fixed in the body or answered with a reason. The six new items are correct. Every new number reproduces. No section or result number moved. Every relative path resolves. I found three small wording or history errors that the revision introduced (items 1–3 below) and two trivial points (items 4–5). None of them affects a theorem.

Compared: the pre-revision text (`stage/A-tight-conditioning-fails.md`, 1123 lines) and the revised text (1360 lines), with `diff`. Read in full: the three second-round reports (`verification/A-logic.md`, `A-computation.md`, `A-scope.md`), the revised text, and the cited passages of B, C, E, `stage/red-team.md` and the RT referee reports. Scratch work is in `../checks/revision-check-A-1/`: `diff.txt`, `recompute.py`, `recompute.out` and `rerun/`.

## (a) Referee issues

All 16 logic issues, computation issues 1(a) through 7 plus the §4 remark on Table 5.1, and scope issues N1 through N9 plus the §5 item 2 suggestion are fixed at the locations given in the Appendix R2 table. I checked each location.

Two points are not adopted, and the reasons given are valid:

* the optional remark in logic issue 11, because the referee marks it unchecked;
* renaming the symbols of logic issue 16, because E applies Lemma 4.2(b) "with $B=\eta n$" (confirmed in E §1.6 and §5.2).

Scope N7 asked that the RT referee reports be cited. The text gives only the status the lead prescribed, which is consistent with the instructions. Linking `../verification/RT-*.md` is optional. **Unaddressed issues: none.**

## (b) Mathematics of the changed passages

I re-derived each new item.

* **Corollary 4.5a.** $a'_d\ge a_d$ keeps the bound $9(H+1)c_d/(2a2^d)$. $a'_d\to0$. $N_0\le44.4\,d^3(d+1)2^d+1\le45\,d^3(d+1)2^d$.
* **Remark 5.1a.** It uses $L\ge1$ off $\mathcal E$, outer expectation via a measurable minorant, and $(1-\epsilon')e\ge e-\epsilon'$.
* **Proposition 6.6a.** The window is $\vert z\vert<\rho-1$. $T$-invariance gives zero means. In (c), $A\cap TA=\emptyset$ by Minkowski, so $\Pi(A)\le\frac12$. (d) is Jensen. (e) is the one-atom bound times $M$. The thresholds $n>\frac{2M}{1-\eta_0}\log\frac{2M}{1-\delta}$ for (R2) and $\log\frac{2M}{1-2\delta}$ for (R1) follow. Both repository priors qualify: E §1.1 gives $\mu_{N,\gamma}$ independent centred Gaussian coordinates.
* **Proposition 7.2a.** I checked every inequality. $2\sqrt{3+3/n}=3.481\le3.49$ and $2\sqrt2+3/n=2.858\le2.86$ at $n=100$. The exact worst case of the chain, with $C=n$ and $Y=2n$, is $6.33\le7$.
* **Corollary 7.2b.** It follows Proposition 5.1 step for step. Theorem 7.2(iv) gives the uniformity.
* **Remark 4.7 closed form.** $a^*=\min\{a_{\rm int},a_{\rm kink},1\}$ is correct.

Independent recomputation (`recompute.out`) reproduces every new number:

* Table 4.1, including the new column and the $(2,60)$ row ($1.913\cdot10^{-10}$, $5.12\cdot10^{42}$). The $(3,20)$ entry $a=0.012$ is right: the value is $0.0124985$.
* The finite-$d$ fixed-$a$ values ($0.225472$, not the referee's $0.226$).
* Corollary 4.5 against 4.5a: $0.4735$ / $7.75\cdot10^{12}$ and $0.4480$ / $1.16\cdot10^8$ at $(2,40)$; $0.4848$ and $0.4710$ at $d=100$.
* Theorem 7.2 against Proposition 7.2a: $0.0015$, $0.1756$, $0.1088$ and $0.4543$ against $0.2489$, $0.4337$, $0.4063$ and $0.4845$, with $c(K+t)/n\le0.0381$.
* Proposition 6.6a(e) in exact rational arithmetic, cross-checked by brute force.

## (c) Strengthening and dropped results

Nothing proved was dropped. Theorem 7.2 and Proposition 7.4 keep their statements; only Proposition 7.4's title changed. One summary sentence overstates a cited result (item 3).

## (d) Numbering

The only additions are 4.5a, 5.1a, 6.6a, 6.6b, 7.2a and 7.2b, plus Appendix R2 with its subsection "Referee record". Every internal reference resolves.

## (e) Cross-references

Each cited item says what the text claims:

* **B (final):** Theorem 6.3, Proposition 6.1 and the paragraph after it, Lemma 2.3(c), Remark 8.2, Theorem 6.4, Corollary 8.1 (with $\Xi_n$), Corollary 9.3 with Remark 9.4, and §7.5.
* **E:** Theorem 2.7, Proposition 4.4, Theorem 5.2, Corollaries 5.3–5.4 and §5.4(c).
* **C:** Theorems C.2 and C.5, Proposition C.3(b).
* **Repository:** `NNG/README.md` main result 4.

The red-team statuses match the prescribed ones exactly:

* Proposition 4.1, including the exact example (from `RT-tube-computation.md`);
* Proposition 6.1, "refereed with a corrected rate, repair under review", with $\alpha<1/8$ as displayed and $\alpha<1/4$ via Bernstein;
* Remark 6.2, with its $\tau$ condition;
* §5 and the Corollary 5.2 sentence.

Note: `stage/` now holds `depth-two.md` and `small-learner-width.md`, the repairs under review. A's citations of red-team.md §5 and Proposition 6.1 will need updating when those repairs land.

## (f) Paths and outputs

* There are no absolute paths.
* Every relative path resolves from `research-notes/`. The exceptions are `../README.md`, `red-team.md` and `literature.md`, which may be missing for now.
* Every quoted output matches its `.out` file, including the referees' `c3b`, `c5`, `c7`, `c8`, `c10`, `v1_constants`, `scope_numbers` and `tube_symmetry` outputs.
* Re-running `r1_table41`, `r1_fixed_d`, `r1_density`, `r1_tube_fixed_d`, `r1_misc` and `r2_numbers` in a scratch copy gives byte-identical outputs in at most 3 s each.
* The pre-revision outputs in `stage/a_r2_timing/` confirm that only Table 4.1 and two labels changed.

## Issues

1. **(minor) §10 item 8, l. 1147: "that is, below the same window".** The window was just written in $c$, as $n^{1-1/H}\lesssim c\lesssim n^{1-1/L}$. But $\vartheta<1/(H+1)=1/L$ means $c=n^{1-\vartheta}$ lies *above* that window; it is "below" only in $\theta$. *Fix:* "that is, for $c$ above the window ($\vartheta<1/L$)".
2. **(minor) Remark 4.7, l. 455: "The columns for $a$ and $N_0$ were added in revision 1".** This is false for $a$. The first version's Table 4.1 already had the "optimizing $a$" column (`verification/A-first-version.md`, l. 407). Revision 1 changed four of its entries and added $N_0$, as the pre-revision sentence said. *Fix:* "Revision 1 changed four entries of the $a$ column and added the $N_0$ column; …".
3. **(minor) §5.3 item 2, l. 576, last sentence.** "for the tempered SP$_c$, B Corollary 8.1 proves it" omits two restrictions. Corollary 8.1 holds only for $\alpha<1/(4H)$ ($H\ge2$) and for clipped predictions. Read against the sentence before it ("fails for every $\alpha>0$"), it overstates B. B Corollary 9.3 shows that no $c(n)$ works for $\alpha>L/(2H(2L-1))$. *Fix:* insert "for $\alpha<1/(4H)$ and clipped predictions".
4. **(trivial) §1.4 symbol list, l. 101–109.** It says "each meaning is local to the places listed", but some uses are missing:
   * $\rho$ is also a ball radius in Proposition 7.4(a);
   * $\gamma_j$ are the expansion coefficients in Lemma 2.1, Step 2, and $\gamma$ is a generic exponent in "${\rm poly}(d)\,n^{-\gamma}$" (§5.3 item 2);
   * $B$ also denotes balls, $B(w^*,\delta)$ and $B_d(\rho)$.

   *Fix:* add them, or soften the sentence.
5. **(trivial) Appendix R2.**
   * L. 1236 says that all three referees "confirmed that the first-round issues are fixed". The computation referee excepted the $(2,60)$ replacement number; it is fixed here as computation issue 3.
   * L. 1253 says the Proposition 7.2a numbers "agree" with `c2b_flatness.out`. At $(3,20)$ that file gives $0.4062$, against $0.4063$, because its grid in $a$ misses the optimum.
