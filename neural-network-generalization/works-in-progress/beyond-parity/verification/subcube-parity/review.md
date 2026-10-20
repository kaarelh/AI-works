# Independent checks of the subcube-parity note

20 October 2026. The [note](../../subcube-parity.md), this package, and the FAQ text that summarizes them were checked in three stages by AI agents that had not written the material under check. Each checker read the cited lemmas in the subcritical paper's LaTeX source rather than paraphrases. These are AI checks, not human review, and nothing here is Lean verified. Literature was checked against abstracts and search summaries only; full texts could not be fetched in this environment.

## Stage 1: the targets without a parity subcube

The results of Section 5 of the note, and the literature of Sections 3.3 and 5.3, were first derived separately and then checked by four adversarial verifiers, one per topic.

- **Sign-staircase** (12 claims). Nothing false was found. Nine claims held as stated. Three needed repairs, all applied:
  - the ceiling of the distance route holds at constant failure, not at exponentially small failure;
  - the two-sided rate $`\mathrm{err}_r=\exp(-\Theta(r^2/d))`$ needs moderate-deviation binomial tails over the whole range $`C\sqrt d\le r\le d/C`$;
  - the per-coefficient bound for restriction parities needs the sup-norm form, $`\lvert\hat f(U)\rvert\le\Pr[\text{bad}]`$.

  The checks were exhaustive at small $d$ and are in [`staircase/`](staircase/).
- **Symmetric targets** (8 claims). Nothing false was found. Five claims held as stated, two needed clarification, and the extension of main result 4 to antiperiodic targets holds only as an audit of the target-dependent steps, not as a written-out proof. The note labels it so.
- **Literature and Fourier facts.** The invariant-kernel bound needs a hypothesis that the training inputs have a law invariant under signed coordinate permutations, and it concerns squared-error regression only. The positive result for almost-full parities survives Gaussian perturbations of size $`O(1/d)`$ of $\pm1$ weights, so "discrete initialization only" overstated it.
- **Numerics.** Both numerical claims were reproduced from independent code, including the restriction lower bound for the staircase.

## Stage 2: the subcube theorem, the two-head networks, and the gradient side

- **Theorem A and Corollary B.** Two verifiers, one checking the lemma hypotheses and the localization, the other the global chain from lemmas to sample complexity, each re-derived every step of the proof against all source files.
  - Both found no gap at fixed $k$.
  - They confirmed that the list of places where the target enters the paper's proof is complete, and that every other ingredient holds for every labeling.
  - One tried to construct a way for the learner to use the labels off the subcube, and found none. A kernel-interpolation check at $d=11$ ([`transfer_check.py`](transfer_check.py)) also shows no transfer.

  Repairs applied:
  - the bookkeeping in $k$ needed a small-sample term at $\gamma=0$, which restricts $k=\varepsilon\log d$ to small $\varepsilon$;
  - the explicit $`k`$-dependence is proved only if every $o(1)$ term is uniform in $k$, which is asserted but not written out;
  - the suggested route to removing the $`2^{-O(k)}`$ loss was corrected: with the ambient-degree cutoff the restricted tail eigenvalue is about $`\binom{k+1}{\lceil(k+1)/2\rceil}\ell_r`$, not $`(1+k)\ell_r`$ ([`restricted_tail.py`](restricted_tail.py));
  - three figures in the sanity checks were corrected.
- **Proposition C.** It was found correct, with repairs:
  - it must cite the paper's theorems on the limiting posteriors at margin $a/\sqrt2$, not `thm:main`;
  - at $0<\gamma<1$ only the large-deviation rate and the set of minimizing sign pairs factorize;
  - it needs equal readout variances;
  - its reading as evidence of feature learning is heuristic.
- **The greedy learner and the gradient-descent theory.** Lemma D and Theorem E were found correct and reproduced by exact Walsh transforms at $d=7$ to $13$ ([`walsh_checks.py`](walsh_checks.py)). Repairs:
  - a false constant in the low-degree weight of $`f^*`$, now $`(2\lceil cd\rceil-3)m_1^2/4`$;
  - a numerically checked inequality, now proved;
  - a wording slip;
  - the learner is a correlation-query procedure, not gradient descent on a standard network.

  The NTK claim is proved only as an expectation identity, and its infinite-width form is literature. The closeness inequality does not cover restriction parities, and the conclusion drawn from it is heuristic. All checked citations matched their abstracts; three details that could not be confirmed were dropped.

## Stage 3: the written note, this package, and the FAQ text

Five reviewers read the finished material, each with one lens. Together they made 75 findings; all were addressed before publication.

- **Mathematics of Sections 1–2.** All 34 cited LaTeX labels exist and say what the note claims, and every step and constant was re-derived. No mathematical gap was found. The fixes were statements stronger than the proofs:
  - the summary and the FAQ said the two-head posterior splits at every $\gamma<1$, which was corrected as in Stage 2;
  - the every-sample statement holds only for part (i) of Theorem A;
  - a factor $N$ was missing in a covariance formula;
  - the margin at $\gamma<0$ was misattributed;
  - the NTK bullet was given the right status and its derivation.

  A Monte Carlo cross-covariance of $0.066$ had been read as nonzero; the exact value is zero, and $0.066$ is sampling error. The reviewer confirmed this with 60 reruns.
- **Sections 3–6.** Every number in the training tables was checked against the run summaries. The fixes:
  - **Wrong attribution.** A claim that exact Walsh transforms confirm the trunks found on the control and on parity alone was removed; no script checks them.
  - **Overclaims and scope.**
    - The summary now states that a plain fully connected network, the shape of Theorem A's learner, did not learn $`f^*`$ at $d=31$, so the positive gradient evidence is for the two-head shape.
    - The summary's claim about symmetric targets now matches Section 5.2.
    - The literature negative now says "Gaussian initialization", because $\pm1$ weights with small Gaussian perturbations do learn almost-full parities.
  - **Imprecise comparisons.** Sample counts compared unlike quantities, and some input-coverage fractions were imprecise.
  - **Threshold convention.** Errors are computed in single precision, so "samples to 5%" means the first error strictly below $0.05$; the text now says so.
- **The FAQ section.** The fixes:
  - **Headings.** A heading claimed that a large parity is necessary for an exponential bound, where only sufficiency is proved.
  - **Two-head wording.** The two-head claims followed the Stage 2 repairs.
  - **Order.** The new paragraphs were reordered so that the Bayesian statements come before the gradient-descent ones, and the paragraph on targets without a parity subcube moved next to the subcube theorem.
  - **Symbols.** Clashing symbols were renamed: the minimizing function in Setting is now $v$, and the readouts are now $`w_1,w_2`$.
  - **Status labels.** "Numerical" and "literature (abstract-level)" were added to the FAQ's status key.
- **This package.** The fast scripts were rerun from their folders and matched their saved outputs. The fixes:
  - **README index.** A sign error in the description of `symmetric/v1.py`, wrong section pointers, and coverage stated too broadly.
  - **Caveats.** Undisclosed differences between `greedy_learner.py` and the theorem it illustrates, and an unconverged run in `random_features.txt`, which the README now flags.
  - **Earlier outputs.** The `.out` files the comparisons refer to are not included, and the README now says so.
- **Rendering and links.** Underscores and asterisks inside plain inline math can pair into emphasis on GitHub. Every such span in the note, the companion note and the FAQ section now uses the `` $`...`$ `` form. Every relative link and anchor resolves.

## Runs added after the package was first assembled

Sixteen training runs finished after the package was first assembled; they are in `numerics/runs/` and `numerics/results.md`. Three were added before the first publication; the other 13 came later. They add, all numerically:

- the two-head run at $d=35$ with Gaussian initialization, and the control at $d=31$;
- parity alone on the three-layer trunk with one readout at $d=19$, 23, 27 and 31, none learned within its budget;
- the plain MLP with Gaussian initialization at $d=19$, 23 and 27, which learned the parity half of $`f^*`$ only at $d=19$;
- second seeds;
- one SGD run;
- default-initialization runs at $d=35$.

The following were updated to match:

- the note's Summary;
- Section 3.2 (Tables 1 and 1b, their bullets, and the text after Tables 3 and 4);
- Section 5.3;
- Section 6, item 6;
- this package's README;
- the FAQ section;
- the collection README's row.

Two independent agents then checked the changes, one for numbers and one for wording. Every number matched the run summaries, and the refitted growth rates were reproduced. The wording check found one overstatement. The text had said the staircase half is what made the parity learnable on the trunk, but the control target's parity half was also learned at $d=19$ and 23. The text now says that parity was learned there only as half of a two-half target, and at $d=27$ and 31 only next to the staircase half. Smaller fixes covered seed counts, the SGD sample counts, statements that the default-initialization run at $d=35$ contradicted, and caveats in this package's README that had been attached to the wrong network.

## Not checked

- Full texts of the cited literature.
- The training runs beyond one or two seeds per configuration and $d\le35$; they cannot distinguish polynomial from exponential growth.
- That the width limit of a network with a Rademacher first layer is the Rademacher kernel (heuristic in the note).
- The audit-level extension of main result 4 to antiperiodic symmetric targets has not been written out as a proof.
