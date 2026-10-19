# Independent check of the beyond-parity note

19 October 2026. The [note](../README.md) and its [FAQ question](../../../TECHNICAL-FAQ.md#is-the-bad-sample-complexity-specific-to-parity) were checked in two rounds by AI agents that had not written them. Each reviewer read the cited lemmas in the subcritical paper's source rather than the note's paraphrases. The reviews are AI checks, not human review.

## Round 1

**Mathematical review.** One agent checked Propositions 1–5 and 7, Corollary 6, the remarks in Section 6, and consistency with the rest of the FAQ. It found **no error in the lower-bound arguments**. Every cited lemma was used within its hypotheses, and the constants checked out. It did find two incorrect upper-bound statements, listed under the changes below, and the second reviewer found two numerical slips. It confirmed:

- the symmetry argument of Proposition 1 for both sampling schemes;
- Proposition 2, including a randomized numerical test at $d=8,9,10$, $L=2,3$, and several ridges;
- that the Gaussian mean-and-confidence lemma holds for every sign pattern, with repeats or selected samples, and the constants in Proposition 3;
- the use of the strict-margin comparator in Proposition 4: large $d$, $n\le e^{d/25}$, every labeling at once, and a constant independent of the margin;
- Maurer's PAC-Bayes form, the Gaussian shift and union bounds, and the margin bound in Proposition 5;
- the restriction argument behind $\mathrm{err}_{\kappa-2}\ge2^{-P}$, and the exponents in Corollary 6;
- the leap definition, the greedy closure, and the Fourier argument of Proposition 7, together with $\mathrm{err}_r\le W^{>r}$;
- the parity-specific lemma list and the restriction-parity examples in Section 6.

Its other findings were a status claim, overstatements, and small gaps. Two of the gaps were incorrect as written: the $0<\gamma<1$ limit statement assumed that tie weights converge, and the $\gamma\le0$ upper bound omitted a $\ln(1/\varepsilon)$ term. The most substantive was a missed result: a fixed-degree **$\gamma=0$ analogue** follows from the paper's denominator, quadratic-entropy, and amplitude lemmas. It is now Proposition 4′.

**Numbers, code, and citations.** A second agent reran every section of the check script; its output matched the recorded output line for line. It recomputed the sign-GP table from the raw rows. It reviewed the Krawtchouk, leap, linear-programming, and exhaustive-search code. It checked the HMC sampler against 4-million-draw rejection sampling at $n=4$, and the Rao–Blackwellized predictor. It found no substantive error. Most citations were confirmed from abstracts and proceedings pages; full texts could not be fetched. Three were only partly confirmed:

- Hsu's $(1-\varepsilon)\binom dk$ bound, seen only through a citing paper;
- the exact form of the Simon et al. parity bound, which the note already qualifies with "about";
- the final form of Maurer's bound: its moment bound for $n\ge8$ was confirmed, and the stated $\mathrm{kl}$ bound is its standard consequence.

**Changes made after round 1.**

- **Added** Proposition 4′ ($\gamma=0$, Gibbs error), and the $\gamma=0$ rows of Corollary 6 and of the exponent table.
- **Added** the every-sample $\gamma<0$ consequence for sparse parity at $r\asymp\sqrt k$, and the sentence in FAQ Question 11 that states it. Question 11 now says that its selected-examples result is for $0<\gamma<1$.
- **Precision.**
  - Regression: "unlearned until roughly $d^{k^*}$" became a lower-bound statement with the factor $(d\log d)^\beta$. The majority claim now concerns all $d$ bits and carries its qualifiers.
  - Halfspaces: "every halfspace" became halfspaces on a fixed coordinate set. Majority of all $d$ bits is costed separately, at about $d^3$.
  - Upper bounds: $\ln(1/(\varepsilon\delta))$ was added to the $\gamma\le0$ upper bounds, the $0<\gamma<1$ limit statement now allows nonconverging tie weights, and Proposition 5 is labelled proved.
  - Lemma count: "three margin-sensitive lemmas" became two margin-sensitive lemmas plus the sign-only small-sample bound.
- **Overstatements removed.**
  - That the lower bounds govern every $\gamma<1$ posterior.
  - That exponential lower bounds require far-from-PTF targets.
  - That these learners respond to margins.
  - That the 97.5% census figure is general.
  - SGD statements: the 2022 merged-staircase result is now described as "necessary and nearly sufficient", and the online-SGD rate as conjectured.
- **Numbers.**
  - Chain agreement: "within 0.004" became "within 0.005" (the maximum is 0.0044).
  - Norm comparison: "four times the norm" became four times the squared norm. The note now adds that degree four lowers the minimum to about $2.4/\lambda_3$ at $d=12$; this was confirmed independently.
  - FAQ numerics now state the threshold and unseen-input figures.
- **Small items.** The dictator citation now points to `thm:dictator-fast` (constants are not covered). The check script's monotonicity test now covers every pair. Section 6 now requires $r$ odd, Proposition 1 states the invertibility hypothesis, and the description of the first proof ingredient now distinguishes $\gamma<0$.

## Round 2

A verification workflow ran six further agents on the revised text. Four were refuters, each with one lens:

- the hypotheses of the lemmas behind Proposition 4′;
- its inequality chain and rates;
- what exactly it bounds;
- the new every-sample sparse-parity remark.

Two were auditors. One checked every round-1 finding against the revised text and checked consistency across the note, the FAQ, Question 11, the collection README, and the verification index. The other gave the note and FAQ section a fresh adversarial read.

**No refuter found an error.** Proposition 4′ was confirmed on every point.

- **Lemma hypotheses.**
  - The conditioning event is defined for arbitrary labels.
  - The rough conditioning-cost bound holds for every labeling at once on one sample event.
  - The quadratic-entropy lemma applies with relative entropy exactly $\mathcal D(S)$.
  - The amplitude lemma's hypotheses hold for $n\le e^{d/25}$ at large $d$.
  - The internal constants of these lemmas were rechecked numerically. A Monte Carlo test at $d=5$ satisfied the tail bound.
- **Inequality chain.** The event inclusion holds pointwise, and the exponent $\kappa-2\beta$ in Corollary 6 follows.
- **Sparse-parity remark.** The ABFR bound on the relevant coordinates, the range of Proposition 3, and consistency with the $0<\gamma<1$ selected-examples paper all check out.

**Changes made after round 2.** All were precision or consistency fixes:

- **Proposition 4′.**
  - Its proof now cites the $r$-independent rough cost bound, and the quadratic-entropy lemma for the target's own labels. The previous citation was the parity-labelled display.
  - The amplitude threshold was renamed, to avoid a clash with the paper's notation.
  - The range of $r$ starts at one.
  - A sentence notes that its constants are large.
- **Gibbs versus confidence.** The 1/3 caveat now covers Propositions 4 and 4′. The note and FAQ now say that the $\gamma\ge0$ junta bounds, at most $1/4$, never give a confidence-failure statement.
- **Corollary 6 hypotheses.** It now states $d\ge d_f$, treats $n=0$ by symmetry, says "uniform iid samples", and names the vanishing terms in its proof.
- **Scope of the three-step description.** The note and FAQ now describe it as the small-sample part of main result 4. At exponential sample sizes, parity also enters through the squared-balance lemma. The note now distinguishes the edge-flip property, used by the two margin-sensitive lemmas, from the orthogonality used by the ABFR lemma.
- **Sparse-parity remark.** The cutoff is now the largest odd $r\le c\sqrt k$, with $c\le1/2$, $k\ge k_0(c,L)$ and $d\ge64$, and the constant carries the factor $r$. The remark states the selected-examples paper's hypotheses and records as open whether selected sets of size $d^{O(\sqrt k)}$ suffice at $\gamma<0$. The FAQ Question 11 sentence now carries the note's status and the same open question.
- **Overstatements removed.**
  - The FAQ heading on sign posteriors now separates lower-bound and upper-bound measures.
  - The hardness-transfer sentences are restricted to fixed juntas and to targets certified by $\mathrm{err}_r$.
  - The Barak et al. sentence no longer infers additive closeness of exponents from $d^{O(k)}$.
  - "Should carry over" became "appear to carry over".
  - The FAQ's description of the kernel-regression literature now says only the lower half is used.
  - Hsu's bound is now hedged.
  - The collection README row no longer says the $\gamma\ge0$ learners need $d^{t^*}$, or that all halfspaces are cheap.
- **Smaller items.**
  - Majority of all $d$ bits is now stated with $d$ odd, and its regression bound with explicit conditions.
  - The arcsine coefficients are defined.
  - The summary's exponential-bound sentence no longer states a necessity, and its halfspace sentence is now a separate bullet.

The reviewers worked from abstracts and search summaries for the literature; full texts could not be fetched in this environment.
