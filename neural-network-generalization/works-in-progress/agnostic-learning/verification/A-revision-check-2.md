# Second check of the revision of A (`research-notes/A-tight-conditioning-fails.md`)

*Published record of a check of the revised note, made during finalization. Paths under `stage/` refer to the lead's unpublished working copies; the pre-revision text there is the version that the second-round referee reports reviewed, published as [`A-revision-1.md`](A-revision-1.md). This check's scripts and outputs are in the `../checks/revision-check-*` folder named below. Re-runs of the note's own scripts, which some reports keep in a `rerun/` subfolder, are not published; each report says whether they reproduced the recorded outputs.*

**Verdict: minor fixes.** Every second-round referee issue is fixed in the body or declined with a valid reason, and so are the five points of the first check (`A-revision-check-1.md`). The new items are correct. Every new number reproduces. No section or result number moved. Every relative path resolves. Five small points remain (below). None of them affects a theorem, lemma, proposition or corollary.

**What I compared and read.**

* I diffed the pre-revision text (`stage/A-tight-conditioning-fails.md`, 1123 lines) against the revised text (1373 lines). I also diffed the version that the first check read (`stage/a_r3_check/recon/prev.md`) against the revised text.
* I read the three second-round reports, every changed passage and its context, and the cited passages of B (final), E and C (current `research-notes/` versions), `stage/red-team.md`, `verification/RT-tube-*.md`, `NNG/README.md` and `stage/literature.md`.

**Scratch files** are in `../checks/revision-check-A-2/`:

* `diff.txt` and `diff_prev.txt`;
* `indep.py` and `indep.out`, an independent recomputation in mpmath;
* `prop72a_test.py` and `prop72a_test.out`, an adversarial test;
* `rerun/`, which holds the re-runs of the scripts;
* `refs.py`, which checks the internal references.

## (a) Referee issues

Each issue is fixed at the location that the R2 referee record gives:

* all 16 logic issues;
* computation issues 1(a)–7 and the §4 remark on Table 5.1;
* scope issues N1–N9 and the suggestion in scope §5 item 2.

Two suggestions are not adopted, and the reasons given are valid:

* The optional remark in logic issue 11 is not added, because the referee marks it as unchecked.
* The symbols of logic issue 16 are not renamed. E applies Lemma 4.2(b) "with $B=\eta n$" (E, ll. 571 and 576), and E's §1.6 gives the same reason from its side.

Computation issue 5 is fixed with a corrected number. The referee proposed $0.226$. The exact value is $0.225472$; the referee's own `c6_fixed_a.out` prints $0.2255$. So the text's $0.225$ is right.

One suggestion is only partly adopted (point 5 below). Logic issue 6 and scope N7 asked that the RT referee reports be cited. The text states the prescribed statuses but does not link those reports. **Unaddressed issues: none.**

## (b) Mathematics of the changed passages

I re-derived each new or changed statement.

* **Corollary 4.5a.**
  * The proof of Corollary 4.5 uses only $a\to0$ and $a\ge(\max\{c_d,1\}/2^d)^{1/3}$.
  * $N_0\le44.36\,d^3(d+1)2^d+1\le45\,d^3(d+1)2^d$.
  * Proposition 5.1 transfers.
* **Remark 5.1a.** I checked the (R1) step $(1-\epsilon')e+\epsilon'\cdot 0\ge e-\epsilon'$. The outer expectation under (R3) follows because the minorant $1+\underline e_d\mathbf 1_{\mathcal E}$ is measurable.
* **Proposition 5.1.** Under (R2) the $\sigma$-threshold also depends on $\varepsilon$.
* **Proposition 6.1(a′).** I checked $\ell_d$ and $u_d$, both limits, and the $\liminf$/$\limsup$ statements.
* **Proposition 6.6a.**
  * (a): the window $(1-\rho,\rho-1)$, $TU=U$, and the $T$-invariance of $\Pi^{\rm tube}$.
  * (b): symmetry, using that ${\rm clip}$ is odd.
  * (c): $A\cap TA=\emptyset$ by Minkowski.
  * (d): Jensen.
  * (e): the union bound applied to the exact one-atom identity.
  * The thresholds $n>\frac{2M}{1-\eta_0}\log\frac{2M}{1-\delta}$ and, under (R1), $\log\frac{2M}{1-2\delta}$ are right.
  * $\mu_{N,\gamma}$ is a product of centred Gaussians (E §1.1).
* **Remark 6.6b.** $\rho_0\ge1+|g(x)|\ge1$ and $\tau+\rho_0>3\rho_0\ge3$, so the bound exceeds $9>4$.
* **Proposition 7.2a.** I checked every inequality:
  * $2\sqrt{3+3/n}=3.4814\le3.49$ at $n=100$;
  * $2\sqrt2+3/n=2.8584\le2.86$;
  * $2\sqrt2+2/n\le3$.

  An adversarial test (20,000 instances, near-minimality made tight) finds slack at least $3.04$.
* **Corollary 7.2b.** It follows Proposition 5.1 step by step, with Theorem 7.2(iv) for uniformity.
* **Remark 4.7.** The closed form $a^*=\min\{a_{\rm int},a_{\rm kink},1\}$ is right, and $a^*=a_{\rm kink}$ in every row except $(4,30)$.

**Independent recomputation** (`indep.out`) reproduces every new number:

* **Table 4.1.** The whole table reproduces, including the $(2,60)$ entries $1.913\cdot10^{-10}$ and $5.116\cdot10^{42}$. In the last column:
  * $N_0/n$ runs from $4.744\cdot10^7$ to $1.862\cdot10^{11}$;
  * the factors run from $2.347$ to $2.384\cdot10^{13}$.
* **Fixed accuracy.** The finite-$d$ values at fixed $a$ reproduce, for example $0.225472$ and $0.335811$.
* **Theorem 7.2.** $0.0015$, $0.1756$, $0.1088$ and $0.4543$.
* **Proposition 7.2a at $a^*$.**
  * The values are $0.248944$, $0.433669$, $0.406265$ and $0.484485$.
  * $\max c(K_{\rm mem}+t)/n=0.0381$.
  * At $(3,20)$, the referee's grid point $10^{-0.03\cdot69}$ gives $0.40620$. This confirms the R2 explanation of $0.4062$ against $0.4063$.
* **Corollaries 4.5 and 4.5a.** $0.4735$ and $7.75\cdot10^{12}$, and $0.4480$ and $1.16\cdot10^8$, at $(2,40)$; $0.4848$ and $0.4710$ at $d=100$.

**Re-runs.** `r1_table41`, `r1_fixed_d`, `r1_density`, `r1_tube_fixed_d`, `r1_misc` and `r2_numbers` were re-run in a scratch copy. Each gives byte-identical output in at most 3 s. Against `stage/a_r2_timing/`, only Table 4.1 and two labels changed.

## (c) Strengthening and dropped results

Nothing is claimed beyond what is proved. The new results are proved, and every other change qualifies a statement or claims less.

* Remark 7.5 is now marked as an interpretation, and the R2 appendix says so and why.
* Proposition 7.4 is retitled.
* Theorem 7.2 and every result of revision 1 are kept, and no proved result was dropped.

## (d) Numbering

The additions are Corollary 4.5a, Remark 5.1a, Proposition 6.6a, Remark 6.6b, Proposition 7.2a, Corollary 7.2b, Appendix R2 and its "Referee record". Section headers, the equation tags (1.1)–(8.1) and Tables 4.1–7.1 are unchanged. Every internal reference resolves.

## (e) Cross-references

Each cited item says what A states, in its current version:

* **B (final):** Theorem 6.3, Proposition 6.1 and the paragraph after it, Lemma 2.3(c) (but see point 3), Theorem 6.4, Corollary 8.1 (with $\Xi_n$ and $\beta$), Remark 8.2, Corollary 9.3, Remark 9.4 and §7.5.
* **E (`research-notes/`):** §1.1, Theorem 2.7, Proposition 4.4, Theorem 5.2, Corollaries 5.3–5.4, §5.4(c), and both referee reports.
* **C (`research-notes/`):** Theorem C.2, Theorem C.5 and Proposition C.3(b).
* **Repository:** `NNG/README.md` main results 1 and 4 ($\exp(\Omega(k))$ parity bound, $d=k$), and `literature.md` G1.

The red-team statuses are exactly the prescribed ones:

* **Proposition 4.1:** logic and computation referees, minor fixes; "never memorizes" only in the energy sense; the bound $(\tau+\rho_0)^2+4\varepsilon/3$; the exact example $(\rho-p\rho_0)^2+p(1-p)\rho_0^2$ against $L_D(g)=p\rho_0^2$, which matches `RT-tube-computation.md` ("the Gibbs risk tends to").
* **Proposition 6.1:** "refereed with a corrected rate, repair under review"; $\alpha<1/8$ as displayed and $\alpha<1/4$ via Bernstein at rate $\tilde O(n^{2\alpha-1/2})$. The $N=o(\sqrt{n/\log n})$ claim follows from its display.
* **Remark 6.2:** one logic referee; $\tau\ge L_D(g)+(U+1)^2\sqrt{\ln(1/\delta)/(2n)}$.
* **§5:** two referees found the proofs correct; the Corollary 5.2 sentence is false for $c\to0$; a repair is in progress; now cited as a lower bound.

## (f) Paths and outputs

* There are no absolute paths.
* Every relative path resolves from `research-notes/`. The exceptions are `../README.md`, `red-team.md` and `literature.md`, which may be missing for now.
* Every `NNG/` path exists.
* Every quoted output matches its `.out` file: `tube_symmetry`, `c3b_median_noise`, `c5_density`, `c7`, `c8`, `c10`, `c2_table41`, `c2b_flatness`, `v1_constants` (50 digits, $0.9999999750$), `check_constants`, `r1_misc`, `scope_numbers`, `r1_density` and `r2_numbers`.
* The §9 translation of the first-version numbering is complete. The scripts use Theorem 4.1, Lemma 6.2, Lemma 4.2 and identity (2.3), and §9 translates all four.

## Remaining points (all minor or trivial)

1. **Appendix R does not keep its promise of bracketed notes.** Its preamble says "Where the second round changed a passage described here, a bracketed note says so." Some passages lack the note:
   * **R.3 item 12** still says "§10 item 6 lists exactly which TUBE statements hold at finite scale". Round 2 corrected that list: logic issue 3 added the width hypothesis of Proposition 6.5, and Proposition 6.6a was added.
   * **R.1 S1, bullets 1 and 4** say that §0.2 item 4 "carries the referee's suggested sentences" and that "§10 opens with the same statement". Round 2 rewrote the heuristic sentence in both (scope N2, logic issue 12).

   *Fix:* add brackets that point to R2 logic issue 3, scope N2 and logic issue 12.
2. **§1.4 symbol list.** The list claims to give every meaning of each symbol "and the places where each meaning is used", and record row 4 says that a search found the remaining uses. Two details are off:
   * $m$ as the number of sampled features also appears in Remark 2.5 (readout $A/(mk_t)$), which is not listed.
   * The path weights $\rho^\ell_j$ are in step 4 of the proof of Lemma 8.1, not step 3; only the slope is in step 3.

   *Fix:* add Remark 2.5 and "(step 4)".
3. **§5.4, "fit the training data about as well…" paragraph.** It cites B Lemma 2.3(c) as "Every near-minimizer of the tempered learner satisfies $\hat L_S(z_w)\le\hat L_S(g)+c(E_*+1)/n$". B states this only for learner widths $N\ge m$, and for B's slack-1 near-minimizers; with slack $\zeta$ the term is $c(E_*+\zeta)/n$.

   *Fix:* add "at learner widths $N\ge m$ (slack $1$, as in B)".
4. **Proposition 6.6, last sentence of the consequence.** It says "Proposition 6.6a removes the strong-prior restriction" right after "and for every prior when $\rho(n)\le1$". But 6.6a covers only priors with full support that are invariant under the readout flip, not every prior.

   *Fix:* "removes it for every full-support prior that is invariant under the readout flip, both repository priors included".
5. **(Optional) RT reports not linked.** Logic issue 6 and scope N7 asked that the RT width reports be cited. The text gives the prescribed status without linking `../verification/RT-*.md`, and the record rows (logic 6, N7) do not mention this. That is acceptable under the lead's status rule. A link, or a clause in the record, would close it.
