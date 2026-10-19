# Independent check of the beyond-parity note

19 October 2026. The [note](../README.md) and its [FAQ question](../../../TECHNICAL-FAQ.md#is-the-bad-sample-complexity-specific-to-parity) were checked in two rounds by AI agents that had not written them. Each reviewer read the cited lemmas in the subcritical paper's source rather than the note's paraphrases. The reviews are AI checks, not human review.

## Round 1

**Mathematical review.** One agent checked Propositions 1–5 and 7, Corollary 6, the remarks in Section 6, and consistency with the rest of the FAQ. It found **no false mathematical statement**. Every cited lemma was used within its hypotheses, and the constants checked out. It confirmed:

- the symmetry argument of Proposition 1 for both sampling schemes;
- Proposition 2, including a randomized numerical test at $d=8,9,10$, $L=2,3$, and several ridges;
- that the Gaussian mean-and-confidence lemma holds for every sign pattern, with repeats or selected samples, and the constants in Proposition 3;
- the use of the strict-margin comparator in Proposition 4: large $d$, $n\le e^{d/25}$, every labeling at once, and a constant independent of the margin;
- Maurer's PAC-Bayes form, the Gaussian shift and union bounds, and the margin bound in Proposition 5;
- the restriction argument behind $\mathrm{err}_{\kappa-2}\ge2^{-P}$, and the exponents in Corollary 6;
- the leap definition, the greedy closure, and the Fourier argument of Proposition 7, together with $\mathrm{err}_r\le W^{>r}$;
- the parity-specific lemma list and the restriction-parity examples in Section 6.

Its other findings were a status claim, overstatements, and small gaps. The most substantive was a missed result: a fixed-degree **$\gamma=0$ analogue** follows from the paper's denominator, quadratic-entropy, and amplitude lemmas. It is now Proposition 4′.

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

ROUND2_PLACEHOLDER
