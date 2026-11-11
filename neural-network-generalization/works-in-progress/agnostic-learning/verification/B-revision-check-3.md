# Check of the revised Claim B note (round 3)

*Published record of a check of the revised note, made during finalization. Paths under `stage/` refer to the lead's unpublished working copies; the pre-revision text there is the version that the referee reports reviewed, published as [`B-first-version.md`](B-first-version.md). This check's scripts and outputs are in the `../checks/revision-check-*` folder named below. Re-runs of the note's own scripts, which some reports keep in a `rerun/` subfolder, are not published; each report says whether they reproduced the recorded outputs.*

**Document:** `research-notes/B-tempered-likelihood.md` (1044 lines; its timestamp did not change during the check), compared with the pre-revision text `stage/B-tempered-likelihood.md` (927 lines). I read all 45 diff hunks against the three referee reports, the brief, the two earlier check reports and `checks/B/`.

**Verdict: minor fixes.** The revision resolves all 33 referee issues. Every changed number, exponent and new argument that I re-derived is correct. Three presentational problems remain, and none of them touches a proof.

The only one with mathematical content is a missing qualifier. The new statements that no fixed $c$ works (§1, and the "Tempering" paragraph of §0) are proved only for guarantees that are uniform over the input dimension. At fixed $d$ the same cube family is consistent for every $c$ (Claim A, Proposition 5.2).

## What was verified

**(a) Referee issues.** §12 has one row for each of the 33 issues:

- logic 1–8, 9a–9c, 10 and 11;
- computation M1–M10;
- scope 1–10.

I found each fix in the place its row names, and I found no fix that is wrong. No issue was rebutted. The points raised by the first check (7) and the second check (8) are also resolved as §12 says. The exception is the numbering rebuttal (issue 2 below).

**(b) Changed passages.** I recomputed these from the formulas in the text, not from the authors' scripts. The script is `../checks/revision-check-B-3/verify_r3.py` and its output is `verify_r3.out`.

*Theorem 6.3 example*
- The displayed $\mathrm{Exc}_n$ crosses $0.1$ exactly once, at $10^{14.088}$.
- The bound with $K=n^\theta+1$ crosses at $10^{13.379}$.
- The closed-form $n_0$ is $10^{29.23}$, and $\mathrm{Exc}_n(10^{13.4})=0.146$.
- The degrees of $n_0$ per variable match the numerical slopes in five $(H,\theta)$ settings. Each of $2/(1-\theta H)$, $4/(1-\theta H)$ and the value $4$ is the active maximum in at least one setting.

*Theorem 6.2 (route 1)*
- I wrote my own implementation of the Proposition 4.1 count, with the exact $J+1$ and the ceilings. Each setting has a single crossing:
  - $10^{53.99}$ at $L=2$, $\theta=1/4$;
  - $10^{101.37}$, $10^{101.94}$ and $10^{260.61}$ at $L=3$, for $\theta=1/16$, $1/32$ and $1/10$.
- At the crossing, the term $(E_*+1)n^{-\theta}$ carries $0.075$ of the $0.1$ for $\theta=1/32$, and the cover term carries $0.075$ for $\theta=1/10$, as the text says.

*Theorem 7.4(b) scale*
- At $H=2$ the lower bound is $0,0,0,0.328$ for $\theta=0.55$ and $0.197,0.364$ for $\theta=0.75$.
- In each case the memorizer term is the largest term of $\varepsilon_n$.

*§1 (fixed $c$)*
- The power-posterior identity holds.
- $K_{\rm mem}/(\sqrt n\log_2n)\to3$ at $H=2$ and $\to0$ at $H=3$.
- $\varepsilon_{c,t}\to0$ for $c=1$ and $c=10$.
- $m_t=\lceil2(d+1)^3n^{3/2}\ln2\rceil+1$ holds exactly.
- $n^{-1/4}\le1/4$ if and only if $n\ge256$.

*Checked by hand:* Corollary 3.2(3), Remark 6.1a, Remark 6.5 and the Remark 6.6 bullet.

*Lemma 4.2, Steps 1 and 4*
- No violation in 7869 grid cases, with $L$ up to $10^4$.
- The termwise split first fails at $L=16$ when $d=K=1$, as stated.

*§7.5*
- Both $m_t$ formulas are correct.
- The window is nonempty if and only if $\kappa<1/(2H+1)$ (checked with sympy).

*Corollary 8.1*
- At $H=1$, $\beta>0$ if and only if $\alpha<1/8$, and $\beta=\frac12-4\alpha$ for $\alpha>1/16$.
- The depth-3 example gives $\beta=1/8$.
- The interval endpoints are $3/20$ and $1/8$.

*Remark 8.2*
- On 300 random biased networks, the converted networks agree to within $4.9\times10^{-15}$.
- The weight bound $\max\{B,1\}/\tanh1$ is attained.

*Proposition 9.1(c)*
- The new matching proof holds under $\theta<1/H$ (and $\theta\le1/2$ when $H=1$) in fixed $d$.
- The arithmetic holds: $3.25$, $2^{1/L}/\sqrt L\le1$, and $\omega^2\ge2.004$.

*Corollary 9.3*
- The definition of "works" is consistent.
- The positive half (a): $p$ is polynomial in $(d,1/\varepsilon,\log(1/\delta))$ because $2\alpha<\theta$ and $2\alpha<1/2$.
- Cases 1 and 2 hold, and so does the closing step at $\varepsilon=1/10$, $\delta=1/4$.

*§9 Discussion*
- The three bullets hold.
- The bound $3.25(n/c+1)$ holds.
- For the counterexample, $g_R'(0)=R/10$, $L_D(g_R)>1$, and the energy is at least $L(R/10)^{2/L}$.

*Remark 9.4*
- The chain bound $2\lVert f\rVert_\infty^3/(3R^2)$ holds for every $f$ when $R^2\ge2$. I derived it by hand, and numerically the largest ratio is $0.969$ over $\lvert f\rvert\le6$ and $H\le6$.
- $\sqrt\varepsilon/2+\sqrt{\varepsilon/4}=\sqrt\varepsilon$.
- Tanh ridge sums contain the constants and the sigmoid ridge sums, so Cybenko's theorem applies.

**(c) Strength of claims.** No proved result was dropped. The passages that were removed or replaced were unproved or false statements, and §12 records each of them. Every new claim is proved in the text: §1, Remark 6.1a, Remark 8.2, Remark 9.4, the matching half of Proposition 9.1(c), and "So $c(n)=n^{1-\theta}$ works". Issue 1 is the one place where a new sentence reads more broadly than its proof.

**(d) Numbering.** All 39 pre-revision labels keep their numbers and their order. The additions are Remark 6.1a, Remark 8.2, Remark 9.4 and §12. Every typed cross-reference resolves to a label of the right kind, with two exceptions:

- "Theorem 5.1" of `red-team.md`, an external citation;
- "Remark 6.5a" in §12 (issue 2).

**(e) Paths and outputs.**
- Every `NNG/` path resolves, and so does every `../` path except `../README.md`.
- `problem-brief.md` now exists. Its quoted passages ("the degree in K is about…", "should condition to be pretty close…", "(norm-based Rademacher bounds?)") match the text of the note.
- Three linked files are absent, as the planned layout expects: `../README.md`, `A-tight-conditioning-fails.md` and `red-team.md`.
- Bare script names occur only in the §10 table, whose lead sentence names the folder.
- I re-ran copies of `sample_sizes.py` and `transition_window.py`, and both outputs are byte-identical to the `.out` files. `transition_window.out` equals the pre-revision output. `sample_sizes.out` keeps every old value and adds the displayed-bound column and the $\theta=1/10$ row.
- The docstrings now name Theorems 6.2 and 6.3, Proposition 7.3 and Theorem 7.4(a) correctly.
- Every value the text quotes matches its `.out` file, including those in the §10 table, `v_cube_twopoint.out` and `width_dependence.out` ($0.4697$ and $0.0286$).

## Remaining issues (all minor)

1. **The fixed-$c$ failure lacks the qualifier "uniform over input dimensions".**

   *Where:* §1, the paragraph after the definition of SP$_c$; §0, "Tempering, not close conditioning"; and, more mildly, §9 Discussion, "for $H\ge2$ every fixed $c$ fits noise … on the noisy cube".

   *The text:*
   - §1: "For $H\ge2$ this dependence on $n$ cannot be removed at large widths."
   - §0: "this expectation fails in the agnostic setting" and "Its likelihood scale must depend on $n$".

   *The problem:* The proof is Proposition 7.3 on the noisy cube with $d=\log_2n$. It therefore refutes only guarantees that are uniform over the input dimension, which is the brief's reading. At fixed $d$ the cube family is consistent for every $c$, at every width (Claim A, Proposition 5.2, in `../research-notes/A-tight-conditioning-fails.md`). Read without the qualifier, these sentences claim more than the note shows. Scope issue 1 asked for exactly this kind of qualifier. Remark 9.4 states it for Theorem 7.4(b) and Corollary 9.3, but not for this result.

   *Fix:*
   - In §1, write "cannot be removed at large widths if the guarantee is to be uniform over laws and input dimensions (the noisy cube below has $d=\log_2n$)".
   - In §0, add the same qualifier to "this expectation fails" and to "must depend on $n$".
   - Optionally, name the §1 statement in the first sentence of Remark 9.4, and add "in dimension $\log_2n$" in the §9 sentence.

2. **Criterion (d), and the appeal in §12 to a rule the reader cannot see.**

   *The problem:* Remark 8.2, Remark 9.4 and §12 are added with plain numbers, but the criterion for this check admits only primed or lettered additions. No existing number moved, so no citation breaks.

   §12 (second check, point 4) rebuts this by citing "the editorial rule for this revision". It says the rule's examples of admissible numbers are "Remark 9.4 and Remark 6.5a". I could not find that rule in the staged files (`stage/scratch/record.md`, `stage/wfres/main_result.json`), and it conflicts with the criterion given to this check. Moreover, "Remark 6.5a" does not exist in the note, so a reader of the published §12 cannot check the rebuttal.

   *Fix:* The lead decides which rule applies.
   - If appended plain numbers are acceptable, replace the appeal to the rule with the reason that stands on its own: no existing number moved, and each new item follows the last item of its section.
   - Otherwise, rename Remark 8.2 to 8.1a and Remark 9.4 to 9.3a, and update the references.

3. **$N_0(n)$ names two different widths.**

   *The problem:* Theorem 7.4(b) and the §0 sharpness row define $N_0(n)=\lceil2(d+1)^3n^{1+\theta}\ln2\rceil+1$ for $c=n^{1-\theta}$. Three places use the same symbol for the noisy-cube width of Corollary 9.3, Case 1: the §0 weight-bound row, §8 ("How far can $\alpha$ go?") and Remark 9.4. For arbitrary $c(n)$ that width is $m_t=\lceil2(d+1)^3n^2\ln2/c(n)\rceil+1$. The two agree only when $c=n^{1-\theta}$. Both widths exceed $n$, so no stated claim is false.

   *Fix:* In Case 1 of the proof of Corollary 9.3, write "put $N_0(n):=m_t=\lceil2(d+1)^3n^2\ln2/c(n)\rceil+1$, which is the $N_0(n)$ of Theorem 7.4(b) when $c=n^{1-\theta}$".

## Files

All in `../checks/revision-check-B-3/`:

| file | content |
|---|---|
| `verify_r3.py`, `verify_r3.out` | the recomputations listed under (b) |
| `rerun/` | re-runs of the two changed author scripts, with their outputs |
| `labels.py`, `xrefs.py` | label and cross-reference comparison |
| `paths.py` | path resolution |
| `full.diff` | the diff |
