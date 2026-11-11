# Scope referee report on `../research-notes/C-fixed-temperature-bayes.md` (Claim C) and on its summary in the README draft

*Published record of a scope referee report made during finalization, on the final text of the note and on the draft of the main README. Line numbers refer to those texts as of the review. The README draft was revised in answer to this report before publication. The referee's scripts and outputs are in [`../checks/verify-C-scope/`](../checks/verify-C-scope/).*

**Verdict: minor fixes.** The theorems of C establish what C says they establish, with the brief's order of quantifiers and limits, and nothing in C contradicts `B-tempered-likelihood.md`, `E-finite-prior-scale.md`, `A-tight-conditioning-fails.md`, `small-learner-width.md` or `NNG/works-in-progress/slt-likelihood/README.md`. Theorem C.5 refutes the brief's width-uniform property (P$_L$) for FIX$_\eta$ under the finite-scale prior, for every $\gamma>0$ and every temperature that does not grow with the width, on a fixed noiseless law in any input dimension. The positive results hold for a weaker property, whose sample size grows with the learner width, and for one predictor, the progressive mixture of the posterior means of clipped outputs. C states all of this where it proves it. The problems are in summaries. The README draft's intro item 5, its §2 table row and three sentences of its §6 state the positive result without the width range in which it holds, without the predictor or the temperature range, and with two phrasings that the note's referees had already removed from the note. A few sentences of C also describe variants, priors or the relation to SP$_c$ more broadly than the proofs support. None of the 14 issues changes a theorem. Issue 1 matters most: in the README's own usage, "polynomial learner width" means a width polynomial in $n$, and at linear widths such as $N=3n$ ($\gamma=1$, $\eta=1/8$) Theorem C.5 proves that FIX$_\eta$ fails.

Scripts and outputs are in `../checks/verify-C-scope/` next to this report (`s1_two_point`, `s2_width_thresholds`, `s3_spc_window`, each `.py` with its `.out`).

---

## Issues

Every issue is minor: none would leave a reader believing a false theorem once the surrounding sentence is read. Issues 1–6 concern the README draft, 7–12 the note, 13 the brief's header, and 14 is informational.

### 1. [minor] README draft, introduction, item 5 (line 19)

> 5. **Ordinary Bayes at a fixed temperature works only at polynomial learner width.** The progressive mixture of tempered posteriors satisfies the oracle inequality with a complexity term $N^\gamma/(\eta n)$ in the learner width $N$, and this dependence is necessary: as $N\to\infty$ the posterior returns to the prior (§6).

The item has four problems.

**(a) The width range.** The README measures learner widths against $n$: "learner width $\lceil n^\alpha\rceil$" (item 7, §8), "learner widths above a polynomial in $n$" (§2). Read that way, "works only at polynomial learner width" says that FIX$_\eta$ works at widths polynomial in $n$. What is proved is much narrower.
- Theorem C.2 gives a useful bound only when $A_LN^\gamma\lesssim\eta n$. On the constant target with $d=10$, $L=3$, $n=10^6$, $\gamma=1$ and $\eta=1/8$, it certifies excess at most $1/2$ only for $N\le83$ (`s2`, Part 1).
- Theorem C.5(c) proves failure from $N^\gamma\ge4(4\eta n+\sqrt{2\eta n})$ on (Gaussian coordinates). At $\gamma=1$ and $\eta=1/8$ this threshold is $N\ge2n+2\sqrt n$. At $N=3n$ the excess is at least $2/3-1/(3\sqrt n)$ on every sample; at $\gamma=2$ and $N=3\sqrt n$ it is at least $0.88$ (`s2`, Part 1).
- The actual crossover is lower still. In the exact one-dimensional version of the most favourable case (all last-layer features equal to $1$, so the prior output variance is the largest possible, $N^{-\gamma}$), the excess passes $1/2$ at $N^\gamma=(2+2\sqrt2)\eta n\approx4.83\,\eta n$, that is $N\approx0.6n$ at $\gamma=1$, $\eta=1/8$ (`s2`, Part 2). The note's own Monte Carlo has test MSE $0.875$ at $N=16$, $n=20$ (C.8 item 4).
- In the user's formulation (Corollary C.2.2) the learner width is $\lceil n^\alpha\rceil$ with $\alpha<1/(4+\gamma)\le1/5$.

The phrase is accurate in the brief's sense, "Polynomial when learner width $N$ is polynomially bounded" (brief §4, Claim C), where the sample size is allowed to grow polynomially with $N$. The note's title and the heading of C.0 item 2 use it in that sense, with the theorem beside it; I would leave those. The README does not define that sense, and the item's second sentence leaves the reader to infer from "$N^\gamma/(\eta n)$" that $N^\gamma$ must be small compared with $\eta n$.

**(b) The predictor and the temperature.** "Ordinary Bayes … works" is proved for the progressive mixture, an average over the sample prefixes $t=0,\dots,n$ of the posterior means of clipped outputs, and only for $\eta\le1/8$. That likelihood is flatter than any Gaussian noise model compatible with labels in $[-1,1]$ (its noise variance is $1/(2\eta)\ge4$). For the final posterior, its mean or one draw, the note proves at a fixed $\eta$ only a bound with an additive $4\eta$ (Theorem C.7), so at $\eta=1/8$ the proved bound on its excess never falls below $1/2$. The final posterior is covered only with $\eta$ chosen from the accuracy ($\eta=\varepsilon/16$) or decreasing with $n$. C states this in item 5 and in "Not proved here"; the README never mentions it.

**(c) "This dependence is necessary."** Theorem C.5(d) locates, for one target and the excess level $1/2$, the width threshold $N^\gamma\asymp\eta n$ up to a factor $O(A_L(d,1,2,1/16)/m_\nu)$. The note says explicitly that this "does not show that the form of the complexity term in item 2 is optimal" (C.0 item 4; Theorem C.5(d)). The logic referee's issue 1 removed "sharp up to the factor $A_L$" from the note for this reason. What is proved necessary is that the sample size grows at least like $N^\gamma/\eta$.

**(d) "As $N\to\infty$ the posterior returns to the prior."** This holds at fixed $n$ and $\eta$ for the shrinking-output prior $\mu_{N,\gamma}$. Convergence in total variation is not by itself why the learner fails; the posterior means tend to $0$. Under the standard fan-in prior the large-width behaviour is open (C.9 open item 4).

*Fix.* Replace the item by:

> 5. **A fixed temperature works only at small learner width.** With a hot clipped likelihood ($\eta\le1/8$) and the finite-scale prior $\mu_{N,\gamma}$, the progressive mixture of the posterior means (an average over sample prefixes) satisfies the oracle inequality, in expectation and, for a variant, with high probability, with sample size of order $A_LN^\gamma/(\eta\varepsilon)$; for the final posterior only a bound with an extra $4\eta$ is proved. The sample size must grow with the width: at fixed $n$ and any fixed $\eta$ the posterior means tend to $0$ as $N\to\infty$, and on a constant target that a width-one network fits exactly the excess is at least $1/2$ once $N^\gamma\ge22\eta n$ and $\eta n\ge1$ (for example $N\ge3n$ at $\gamma=1$, $\eta=1/8$, $n\ge8$) and tends to $1$ (§6).

### 2. [minor] README draft, §2 table, row FIX$_\eta$ (line 60), with the table's preamble (line 51)

> | FIX$_\eta$, progressive mixture | weak, fixed temperature | **holds in expectation at polynomial learner width**, with a term $N^\gamma/(\eta n)$; the width dependence is necessary | §6; [C] Thms C.1, C.2, C.5 |

The preamble says that the result column records whether the learner has (P$_L$) ("'Fails' means that the learner does not have (P$_L$)"). FIX$_\eta$ does not have it: Theorem C.5 refutes (P$_L$) for every $\gamma>0$ and every fixed $\eta$. The cell bolds "holds". The preamble also says that failures are shown "on laws that change with $n$, with input dimension growing like $\log_2n$ … unless the table says otherwise". The row does not say otherwise, yet the FIX$_\eta$ failure is on a fixed law (constant target, any $x$-marginal) in every input dimension, $d=1$ included. The row also omits $\eta\le1/8$ and the clipped outputs, and "at polynomial learner width" has the problem of issue 1(a).

*Fix.*

> | FIX$_\eta$ ($\eta\le1/8$), progressive mixture of the posterior means of clipped outputs | weak, fixed temperature | **fails** (P$_L$) for every $\gamma>0$ and fixed $\eta$: on the constant target, in any input dimension, the excess tends to $1$ as $N\to\infty$ at fixed $n$; **holds** in expectation, and for a variant with probability $1-\delta$, when $n\gtrsim A_LN^\gamma/(\eta\varepsilon)$ | §6; [C] Thms C.1, C.2, C.5, C.6 |

### 3. [minor] README draft, §6, second bullet (line 134)

> At learner width $N=\lceil n^\alpha\rceil$ with $\alpha<1/(4+\gamma)$ and fixed $d$, this is the conjecture's form in expectation: the expected test loss is at most the least test loss over networks with width and weights at most $n^\alpha$, plus $O(d^2n^{(4+\gamma)\alpha-1}\log(dn))$

(a) In README §1 "the conjecture's form" is (P$_L$) against the class of networks with width and weights at most $n^\alpha$, and (P$_L$) quantifies over every learner width $N\ge m$. Corollary C.2.2 holds at the single learner width $\lceil n^\alpha\rceil$, and the next bullet shows that width-uniformity fails. §8 says the analogous thing about SP$_1$ at small width ("it is not uniform over learner widths"); §6 should say it too.
(b) "The least test loss" should be "the infimum of the test loss". The minimum need not be attained, and the note was corrected for this (logic issue 7(iii)).
(c) The $O$-term drops the factor $1/\eta\ge8$ and the dependence on $L,\gamma,\nu$. The note writes $O_{L,\gamma,\nu}(d^2n^{(4+\gamma)\alpha-1}\log(dn)/\eta)$.
(d) In the same bullet, "for every competitor of width $m\le N$" omits the depth $L$, the weight bound $B\ge1$ and $\rho\in(0,1]$.

*Fix.*

> With the finite-scale prior $\mu_{N,\gamma}$, $\gamma\ge1$, and the repository's teacher-tube mass bound, this gives $\mathbb E_SL_D(\bar f_n)\le L_D(g)+4\rho+A_L(d,m,B,\rho)N^\gamma/(\eta(n+1))$ for every $\rho\in(0,1]$ and every depth-$L$ competitor of width $m\le N$ with weights in $[-B,B]$, $B\ge1$. At the single learner width $N=\lceil n^\alpha\rceil$ with $\alpha<1/(4+\gamma)$ and fixed $d$, this gives the conjecture's "$+o(1)$" form in expectation, but not uniformly over learner widths (next item): the expected test loss of $\bar f_n$ is at most the infimum of the test loss over networks with width and weights at most $n^\alpha$, plus $O_{L,\gamma,\nu}(d^2n^{(4+\gamma)\alpha-1}\log(dn)/\eta)$ ([C, Corollary C.2.2]). With probability $1-2\delta$ the same holds for the average over $t<n$, with an additional term of order $\sqrt{\log(1/\delta)/n}$ (Theorem C.6).

### 4. [minor] README draft, §6, third bullet (line 135)

> The width dependence is necessary: for every $\gamma>0$, every $\eta>0$ and every sample, the posterior tends to the prior as $N\to\infty$, the predictors tend to $0$, and on the constant target $y\equiv1$, which a width-one network fits exactly, the excess tends to $1$.

(a) "The predictors tend to $0$": the Gibbs predictor is a random draw. What is proved is that the posterior means $\bar f_n$ and $\hat f_n$ tend to $0$ uniformly on $X$ and that $\sup_x\int z_w(x)^2\,d\Pi_n\to0$. The note was corrected for exactly this (logic issue 3). The second revision check reported that this README sentence still has the old wording (`verification/C-revision-check-2.md`, "Outside the scope of this check"), and it is unchanged.
(b) "The width dependence is necessary": as issue 1(c).

*Fix.*

> Some width dependence is necessary. For every $\gamma>0$, every fixed $\eta>0$ and every sample, as $N\to\infty$ with $n$ fixed the posterior tends to the prior in total variation, the posterior means $\bar f_n$ and $\hat f_n$ tend to $0$ uniformly on $X$, and $\sup_x\int z_w(x)^2\,d\Pi_n\to0$. On the constant target $y\equiv1$, which a width-one network fits exactly, the excess of every predictor considered, clipped or not, tends to $1$; for the clipped predictors it is at least $1/2$ once $N^\gamma\ge4(4\eta n+\sqrt{2\eta n})$. For this target this locates the threshold $N^\gamma\asymp\eta n$ up to a factor $O(A_L)$; it does not show that the complexity term of the previous item has the best possible form.

### 5. [minor] README draft, §6, closing paragraph (line 137)

> Clipping is essential for the first statement; for unclipped outputs it fails for some priors.

Remark 3 after Theorem C.1 is headed "Where clipping is needed: in the predictor, not in the likelihood". With an unclipped likelihood, Theorems C.1 and C.2 still hold, with $4\rho$ replaced by $2\rho\sqrt{L_D(g)}+\rho^2$. A reader of the README, where FIX$_\eta$ is defined by its clipped likelihood (§1), will take "clipping" to mean that likelihood. The failures are shown for a two-point prior whose outputs lie far outside $[-1,1]$ ($M$ up to $10^6$); for the network priors the unclipped predictors are open. The second revision check also reported this sentence.

*Fix.*

> Clipping is needed in the predictor, not in the likelihood. If $\hat f_t$ is replaced by the posterior mean of the unclipped outputs or its clip, the first statement fails for some two-point priors whose outputs lie far outside $[-1,1]$; for the network priors the unclipped predictors are open.

### 6. [minor] README draft, closing paragraph of the introduction (line 23)

> … and the tempering has to be tied to the prior scale to stay width independent.

This sentence draws on C. C proves it for the clipped Gaussian likelihood with a fixed $\eta$ under the repository's shrinking-output priors: $\mu_{N,\gamma}$, $\gamma>0$, as $N\to\infty$ (Theorem C.5), and $\mu_\sigma$ as $\sigma\to0$ (Proposition C.3(b)). It is not proved for the unclipped likelihood: Remark C.6.2 outlines the extension of Lemma C.6.1 and says it is "not written out here". It is not proved for the standard fan-in prior either, under which prior outputs do not shrink and the large-width behaviour is open (C.9 open item 4).

*Fix.*

> … and, with the repository's priors, whose outputs shrink as the width grows, the tempering has to be tied to the prior scale to stay width independent: at a fixed temperature the posterior means vanish at large width (§6; proved for the clipped likelihood).

### 7. [minor] C, "Bearing on the conjecture" (line 35), and C.9, proved list, third bullet (line 522)

In "Bearing on the conjecture", the sentence "then FIX$_\eta$ satisfies the agnostic oracle inequality, in expectation for $\bar f_n$ (item 2) and with probability $\ge1-2\delta$ for $\tilde f_n$ (item 5)" follows a sentence about "any $\gamma>0$" and does not restate $0<\eta\le1/8$. The negative result holds for every $\eta>0$, the positive one only for $\eta\le1/8$; for $\eta>1/8$ only Theorem C.7 is proved, with its additive $4\eta$. Item 2 also needs $\gamma\ge1$; Remark C.4.2 supplies $\gamma<1$.

C.9's bullet "Corollaries C.2.1–C.2.2 give the polynomial sample size and the user's formulation, $\alpha<1/(4+\gamma)$, in expectation, …" omits the two qualifications on which the user's formulation, as proved, differs from the brief's (P$_L$): the predictor is $\bar f_n$, and the learner width is tied to $n$, $N=\lceil n^\alpha\rceil$. C.0 item 2 and "Bearing on the conjecture" state both.

*Fix.* In "Bearing on the conjecture": "then FIX$_\eta$ with $0<\eta\le1/8$ satisfies the agnostic oracle inequality, in expectation for $\bar f_n$ (item 2 for $\gamma\ge1$; Remark C.4.2 for every $\gamma$) and with probability $\ge1-2\delta$ for $\tilde f_n$ (item 5)". In C.9: "Corollaries C.2.1–C.2.2 give the polynomial sample size and, at learner width $N=\lceil n^\alpha\rceil$ with $\alpha<1/(4+\gamma)$, the user's formulation for $\bar f_n$ in expectation, …".

### 8. [minor] C, Remark 2 after Theorem C.1 (line 151): "Genuinely Bayesian variants with the same bound"

Variant (i) is the posterior mean computed from a uniformly random prefix of the sample, which discards half of the data on average. Variant (ii) averages posterior means over the prefixes of all orderings of the sample. Neither is the posterior mean, or a draw, of the posterior given the whole sample, which is what "Bayesian learning" names in the user's statement. For that posterior the note proves only Theorem C.7, with its additive $4\eta$. The heading invites the reader to take the variants for the ordinary Bayesian predictor, and the person who proposed the conjecture would object to that reading.

*Fix.* Rename the remark "*Randomized and symmetrized variants with the same bound*", and add at its end: "Neither is the posterior mean of the posterior given the whole sample; for that predictor see Theorem C.7."

### 9. [minor] C, Remark C.4.2 (line 257) and Proposition C.4 (line 296)

"**At polynomial learner width, FIX$_\eta$ is polynomially agnostic for every real $\gamma$.**" and "So FIX$_\eta$ with the standard fan-in prior is polynomially agnostic at polynomial width." name the learner but not the predictor or the temperature range. Both rest on Theorem C.1, so they hold for $0<\eta\le1/8$, for the progressive mixture $\bar f_n$ in expectation, and for $\tilde f_n$ with high probability (Theorem C.6 applies with the same $Q$), with a sample size that grows polynomially with $N$. For the final posterior they give only the bound of Theorem C.7.

*Fix.* "At polynomial learner width, the progressive mixture $\bar f_n$ of FIX$_\eta$ ($0<\eta\le1/8$) is polynomially agnostic in expectation for every real $\gamma$, and so is $\tilde f_n$ with high probability (Theorem C.6)." Make the same change in Proposition C.4.

### 10. [minor] C, §C.5.1, "Relation to SP$_c$" (line 287)

"Part (a) would then give the width- and scale-free complexity term $2cA_L/(n+1)$." Part (a) has this form only when $\sigma^2\le1/N$. Together with $\sigma^2\ge4/c$, which $\eta\le1/8$ requires, this restricts the width to $N\le c/4$. For larger $N$ the complexity term is the right side of (C.3.1) divided by $\eta(n+1)$, and it grows linearly in $N$. At $n=10^6$, $\theta=1/4$ and $\sigma^2=4/c$ it is $23.7$ for every $N\le c/4$ and $5.7\cdot10^3$ at $N=100c$ (`s3`). The paragraph's conclusion, that the exp-concave route does not reach SP$_c$, is unaffected.

In the same paragraph, "Part (b) is the quantitative form of `slt-likelihood/README.md` §3" is broader than (b). That section covers every fixed bounded likelihood that is positive at zero output, the unclipped Gaussian one included, while (b) is proved for the clipped likelihood only. Remark C.6.3 states this correctly.

*Fix.* "For widths $N\le1/\sigma^2\le c/4$, part (a) would then give the complexity term $2cA_L/(n+1)$, which depends on neither $N$ nor $\sigma$ in that range; for larger $N$ it grows linearly in $N$." and "Part (b) is the quantitative form, for the clipped likelihood of FIX$_\eta$, of …".

### 11. [minor] C, Remark C.6.4, third bullet (line 408): "The obstruction is the width-first limit."

The bullet compares two different learners: the margin- and sign-conditioned posterior of main result 4 in the width-first limit, and FIX$_\eta$ at polynomial width. Its last sentence reads as a statement about both, but nothing in C shows that the learner of main result 4 learns parity at polynomial width.

*Fix.* "For FIX$_\eta$ the obstruction is the large-width limit. Whether the learner of main result 4 learns parity at polynomial width is not addressed here."

### 12. [minor, optional] C, Remark 3 after Theorem C.1 (lines 153–158) and C.9 open item 6

Two additions would complete the record of what fails for unclipped predictors.

(a) The same two-point prior shows that the unclipped Gibbs risk $\int L_D(z_w)\,d\Pi_n$ admits no bound of the form of Theorem C.7. With $M=10e^{2\eta n}$ the posterior weight of $w_1$ is about $e^{-4\eta n}$, so the unclipped Gibbs risk is about $100$ for every $n$. The right side of (C.7.2) with $Q=\delta_{w_2}$ tends to $4\eta$; at $n=100$ and $\delta=0.1$ the comparison is $100$ against $0.92$ (`s1`, part (d)). The note lists this predictor only as "not covered".

(b) For $\operatorname{clip}\bar z_t$ the remark shows only that the first inequality of (C.2.3) fails at $T=1$. There the full chain (C.2.3) still holds, since $4\le8\log2=5.55$. The full chain fails from $T=2$ ($8>5.55$), and (C.2.4) fails as well: at $M=10$, $n=10$ the average loss is $1.71$ against the bound $0.504$ (`s1`, parts (b)–(c)). Stating one of these makes "Theorem C.1 is false" for this replacement unambiguous to a reader who looks at the statistical form.

*Fix.* Add one sentence for each, with these numbers.

### 13. [minor] `problem-brief.md`, header note (line 9)

> *Claim C is proved for clipped predictions only; for some priors the unclipped versions fail …*

Claim C is a statement about the network prior $\mu_{N,\gamma}$, under which the unclipped predictors are open. The failures concern the general-prior inequality (Theorem C.1) under a two-point prior.

*Fix.* "*Claim C is proved for clipped predictions only. For the network prior of Claim C the unclipped predictors are open; for some two-point priors the general inequality (Theorem C.1) fails for them ([C-fixed-temperature-bayes.md](C-fixed-temperature-bayes.md), Remark 3 after Theorem C.1).*"

### 14. [minor, informational] README draft, line 3 and §11

Line 3 says that each proof was refereed "with separate logic, computation and scope reviews". C and E had no scope review before this report; `verification/README.md` says so ("C and E were refereed through the logic and computation lenses only"). §11 omits C's open problems: a bound for the final posterior at a fixed $\eta$ without the additive $4\eta$; the unclipped predictors under the network priors; and FIX$_\eta$ at large width under the fan-in prior or at $\gamma\le0$.

*Fix.* Add this report to the verification record and make line 3 match the record. Add one item to §11 listing C.9 open items 1, 4 and 6.

---

## What I checked

### Sources

I read C in full (694 lines) and, against it: the brief, §§1–4; A, §0 and §5 (the property (P$_L$), the readings (R1)–(R3), Remark 5.1a, §5.4); B, §0 and §1; `NNG/works-in-progress/slt-likelihood/README.md`, §§1–4; `NNG/main-results/subcritical-exponential/source/subcritical-exponential.tex`, lines 95–150; the logic and computation reports on C and the three revision checks; `verification/README.md`; and the README draft in full, with intro item 5, the §2 table and §6 line by line. I also searched E, small-learner-width.md, depth-two.md and literature.md for every reference to C or FIX$_\eta$.

### The points the task singled out

**FIX$_\eta$ as a reading of "NN Bayesian learning".** FIX$_\eta$ is the brief's own learner (§2). It is a legitimate generalized-Bayes posterior over network weights, and the user allowed "whichever version of Bayesian learning is best". Clipping in the likelihood is not needed for the positive results (Remark 3), but the negative Theorem C.5 is proved only with it. A proposer would raise three departures from the Bayesian learner they had in mind, and C states each. First, $\eta\le1/8$ is a very hot likelihood, the opposite of the close conditioning the user expected ("Bearing on the conjecture", last two sentences). Second, the predictors average clipped outputs (C.0, first paragraph; §C.1.3). Third, the positive predictor is the progressive mixture, and the final posterior carries an extra $4\eta$ (C.0 items 2 and 5; "Not proved here"). The README states none of the three in item 5 or in the table (issues 1, 2), and C's Remark 2 overstates how Bayesian the variants are (issue 8).

**Expectation versus high probability.** C states the mode correctly in C.0 items 2 and 5, "Bearing on the conjecture", C.9, Theorem C.5(d) and Remark C.6.4. Remark C.4.2 and Proposition C.4 do not state it (issue 9); there the omission is harmless, because Theorem C.6 applies to any sample-independent $Q$. The README says "in expectation" and never mentions Theorem C.6, which understates the result. README §6's first bullet says "for every $Q$" without requiring $Q$ to be independent of the sample. That is harmless: the right side of (C.2.5) depends on $Q$ only through the population loss, and its infimum over all $Q$ is attained at a sample-independent $Q$, so the inequality holds for every $Q$, sample-dependent or not.

**Theorem C.5 and what it refutes.** (P$_L$) asks for the bound at every learner width $N\ge m$ once $n\ge p(d,m,B,1/\varepsilon,\log(1/\delta))$. Theorem C.5(c) gives, for each fixed $n$ and $\eta$ and on every sample, excess at least $1-2\beta_N$ against the width-one competitor $g_1$ ($m=1$, $B=2$), with $\beta_N\to0$ as $N\to\infty$. So (P$_L$) fails, also in its in-expectation form, and already at a fixed input dimension.
- *What it refutes:* (P$_L$) for FIX$_\eta$ under $\mu_{N,\gamma}$, for every $\gamma>0$ and every temperature that does not grow with $N$. Since the theorem holds at each $n$, this includes any schedule $\eta_n$.
- *What it does not refute:* the conjecture, which is existential in the learner; the weaker property with a sample size polynomial in $N$, which C proves; (P$_L$) under the fan-in prior or at $\gamma\le0$; and learners whose likelihood scales with the prior (`slt-likelihood` §2, B, E).
- *What kind of failure it is:* not an agnostic one. It occurs on a noiseless target that a width-one network fits exactly, and it comes from the prior's output scale $N^{-\gamma/2}$ against a likelihood whose range is fixed.

C's statements match all of this. The README omits the prior restriction (issue 6) and the fixed-law, any-dimension character of the failure (issue 2).

**Corollary C.2.2 and the input dimension.** The bound holds for every $d$, uniformly over $D$, with $\varepsilon_n(d)\le Kd^2n^{(4+\gamma)\alpha-1}\log(dn)/\eta$, which is polynomial in $d$. The stated sufficient condition $d^2\log d=o(n^{1-(4+\gamma)\alpha}/\log n)$ is correct: for $d\ge3$, $\log d\ge1$, so it also controls the $d^2\log n$ part of $d^2\log(dn)$, and for bounded $d$ nothing is needed. At $d=n^\alpha$ the condition becomes $(6+\gamma)\alpha<1$. The learner width is tied to $n$, the competitors' weights are bounded by $n^\alpha$ as the brief prescribes, and the predictor is $\bar f_n$. C.0 item 2 and "Bearing on the conjecture" state all three; C.9 does not (issue 7). README §6 says "fixed $d$", which is a correct special case.

**The counterexamples of Remark 3.** I reproduced them (`s1`): the bounds $0.504$, $0.0549$ and $5.54\cdot10^{-3}$; the losses $2.712$ and $2.706\cdot10^6$ of the progressive mixture of the unclipped posterior means; loss $4$ for its clip at $M=10^3$, $n=10$ and $n=100$ (the third revision check verified every $n\le100$); and $30.25$ and $4$ against $1.7526$ at $T=1$. The clipped progressive mixture satisfies the bound in all nine cases. The prior is a two-point prior with outputs up to $10^6$, far from any network prior. C says "for some priors" and that the network-prior case is open, which is the correct scope. The two optional additions are in issue 12.

**Consistency with B and `slt-likelihood`.** I found no contradiction.
- SP$_c$ has $\eta=1/(2c\sigma^2)\to\infty$ as $\sigma\to0$, outside both Theorem C.5 and Proposition C.3(b), which fix $\eta$.
- `slt-likelihood` §2 uses $\eta=N^\gamma/2$ at finite scale and $\eta=1/(2\sigma^2)$ in the strong-prior limit; both grow, so neither conflicts with Theorem C.5.
- `slt-likelihood` §3 proves convergence to the prior in total variation, and says that it "does not prove failure of the sign of the posterior mean". Lemma C.6.1 adds the vanishing of the posterior mean, for the clipped likelihood. This is consistent with §3, since squared loss fails when the mean vanishes even if its sign is right.
- `slt-likelihood` §4's "width-dependent $N^\gamma$ factor" is the same factor as in Theorem C.2.
- E's §2.2 cites Theorem C.7 as its fixed-temperature counterpart, correctly, and A §0.1 summarizes C correctly.

Two cross-checks with A also came out consistent. On A's noisy cube, Theorem C.2 with $g\equiv0$ gives vanishing excess at $N=\mathrm{poly}(d)$, $n=2^d$. At large width FIX$_\eta$'s posterior means tend to $0$, which is the Bayes predictor on that law. Neither conflicts with A, whose failure concerns SP$_c$ at $N\ge N_0=\mathrm{poly}(n)$.

### Scenarios tried against the summaries

| scenario | outcome |
|---|---|
| fixed $\eta$, $N\to\infty$, constant target | the summaries' "excess tends to $1$" holds (Theorem C.5(c)); the actual crossover is near $N^\gamma\approx4.8\,\eta n$ (`s2`, Part 2) |
| $\eta=\eta_n$ depending on $n$ only | Theorem C.5 still applies at each $n$; "every fixed $\eta$" understates the result, harmlessly |
| $\eta$ growing like $N^\gamma$ | outside Theorem C.5; `slt-likelihood` §2 and E prove width-uniform learning for such learners; no conflict |
| learner width $N=n$, $\gamma=1$, $\eta=1/8$ | the bound of Theorem C.2 is vacuous ($A_LN^\gamma/(\eta n)=8A_L$); Theorem C.5 applies from $N\ge2n+2\sqrt n$; the one-dimensional model fails from $N\approx0.6n$ and the note's Monte Carlo at $N=16$, $n=20$; so "works … at polynomial learner width" is not supported there (issue 1) |
| learner width $N=3n$, same parameters | excess at least $2/3-1/(3\sqrt n)$ on every sample, by Theorem C.5(c) (issue 1) |
| unclipped predictors, two-point prior | failures reproduced; the network-prior case is open, as C says |
| unclipped Gibbs risk, two-point prior | no bound of the form of Theorem C.7 holds (issue 12) |
| $d=n^\alpha$ in Corollary C.2.2 | needs $(6+\gamma)\alpha<1$, consistent with the stated condition |
| SP$_c$ at a fixed scale $\sigma^2\in[4/c,1/N]$ | C's route applies with the unclipped likelihood and clipped predictor, but only for $N\le c/4$ (issue 10) |
| sample-dependent $Q$ in README §6, first bullet | harmless (see above) |

### Numerical checks (`../checks/verify-C-scope/`)

All three scripts are deterministic and run in a few seconds with `python3 -I`.

- `s1_two_point.py`: the two-point prior of Remark 3. It recomputes every number the remark quotes, the full chain (C.2.3) for $\operatorname{clip}\bar z_t$ at $T=1,2,3,5$, the averaged losses that enter (C.2.4) for $\bar z_t$ and $\operatorname{clip}\bar z_t$, and the unclipped Gibbs risk against the right side of (C.7.2).
- `s2_width_thresholds.py`: Part 1 evaluates, for $\gamma\in\{1,2\}$, $(d,L)\in\{(1,2),(10,3)\}$ and $n\in\{10^3,10^6,10^9\}$, the largest width at which Theorem C.2 certifies excess at most $1/2$ on the constant target, the width from which Theorem C.5(c) forces excess at least $1/2$, and the forced excess at $N=3n^{1/\gamma}$ and $N=n^{2/\gamma}$. Part 2 computes the posterior mean of $\operatorname{clip}z$ exactly (mpmath, closed form on $[-1,1]$, constant-likelihood tails outside) in the extremal one-dimensional model, and finds the crossover $N^\gamma=4.8284\,\eta n$ for $\eta n$ from $10$ to $10^6$, against Theorem C.5's guaranteed $N^\gamma\approx16\,\eta n$.
- `s3_spc_window.py`: the complexity term of Proposition C.3(a) for SP$_c$ at $\sigma^2=4/c$, as a function of $N$, at $n\in\{10^6,10^9\}$, $\theta=1/4$. It is constant up to $N=c/4$ and grows linearly beyond.
