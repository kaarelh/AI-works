# Independent check of the standard-scaling NNGP parity paper

19 October 2026. The [paper](../paper.pdf) was checked by AI agents that had not written it. Each reviewer read the cited lemmas in the LaTeX source of the [subcritical paper](../../../main-results/subcritical-exponential/source/) and of the [NNGP note](../../nngp-sample-complexity/source/), not the paper's paraphrases. Reviewers also ran their own numerical checks. These are AI checks, not human review or Lean verification.

## Round 1

Three referees worked in parallel, each on one part of the paper.

### Sections 1–3: model, width limits, spectrum, sign-only learner

**No mathematical error found.** The referee confirmed:

- the Hermite and Mehler identities; nonnegativity and positivity of the composite coefficients; and that the variances $q_\ell$ do not depend on $d$;
- the width-limit induction with all hidden layers of width $N$, continuity of the covariance map on the PSD cone, the identification of the limit kernel, and the portmanteau step for both learners;
- the walk representation, its recursion and the difference identity (by hand), and the reduction $\lambda_q=A(a_q+a_{q+1})$, numerically to about $10^{-17}$ at $d=8$ for tanh, cos and sigmoid;
- monotonicity, positivity, pairing, and all four level-mass inequalities;
- that subcritical Lemma 10.1 uses the kernel only through independence of the tail, its constant variance, its top eigenvalue, and positive definiteness. It therefore transfers to every isotropic positive-definite kernel with nonincreasing eigenvalues and to every training sequence;
- the constants $c_\theta=0.04482$, $C_0=997.7$ and $6C_0<6000$;
- the restriction argument for sparse parity, and the binomial bound $\max_j2^{-k}\binom kj\le\sqrt{2/(\pi k)}$ for $k\le5000$;
- the inequality $\log\binom d{\lfloor\sqrt d/5\rfloor}\ge\frac{\sqrt d}{10}\log d-\frac12\log d$ for $25\le d\le20000$ and on a grid to $10^6$.

**Imprecisions found:**

1. The abstract said the sign-only learner had "the same" threshold as the margin learner. The explicit sign-only bound is weaker for $d<1195$ and exceeds one only for $d\ge385$.
2. The introduction omitted $d\ge25$.
3. A remark compared the sign-only bound with the NNGP note's $\Theta(2^d)$ theorem, which concerns the *margin* learner with specified gains at depth at least $C_a(d+1)$, and called that bound "stronger".
4. Lemma 2.4(a) used an unneeded convention ($a_{D+1}:=0$), and its proof did not say why the boundary case $j=D-2$ of the induction holds.
5. A remark said the $\sqrt d\log d$ scale was "all that" the level-mass lemma "can give". This should be stated for a constant failure fraction.

It also suggested two improvements: the paired form for odd activations, and stating the residual-variance bound with the number $s$ of distinct inputs.

### Sections 4–5: tanh coefficients, eigenvalue bounds, margin learner

**No mathematical error found.** The referee confirmed:

- the Fourier transform of $\mathrm{sech}^2$ to 40 digits, and the coefficient formula against direct Gauss–Hermite projection to 12 digits;
- the coefficient lower bound for $\sigma\in\{0.3,0.5,1,2,4\}$ and odd $m\le681$. The smallest ratio of true value to bound was $1.088$;
- every constant in the eigenvalue lemma, including the requirement $d\ge101$;
- the bump lemma against subcritical Lemma 7.2, including the exponent $-0.006237$ and the cross-term bound;
- the conditioning-cost lemma, the Gibbs-error proposition, and the assembly of the theorem: probability, quantifier order, and $\mathrm{err}_s>0.42$.

**Imprecisions found:**

1. The scope of the activation generalization was stated too broadly. It requires oddness, the standing assumption, and a lower bound on the composite coefficients.
2. The margin theorem holds for $d\ge d_0$ with $d_0$ not explicit, because no rate for the coefficient tail $T(s)$ is proved. The abstract and introduction did not say so.
3. The Gradshteyn–Ryzhik formula number for the Fourier pair could not be confirmed.
4. Several symbols were overloaded: $v$, $\varepsilon_d$, and $N_t$ against the width $N$.
5. The Poisson tail bound was stated without justification.
6. The constant $c_q$ in the remark on thresholds $q>1/2$ was not given.
7. The lower bound $E_b\ge1/A$ needed a clause of justification.

### Section 6: the obstruction

The proposition (cost per sample at least $(a^2-10\tau_r)/(\tau_r(16b_r+4CA_\delta rH_r))$), the universal tail-Gram lemma, the moment argument and the upper bound were confirmed. The referee also checked:

- that subcritical Lemmas 5.1 and 5.2 use only the listed properties of the tail covariance;
- that the odd-$F$, odd-$r$ identity for the tail kernel holds;
- that the cited equation numbers (42) and (45) are correct.

It found **two errors** and several imprecisions.

1. **Error (interpretation).** The draft said the proposition shows that the low-degree part "is not shown to be small", and so the subcritical route fails. In fact the clipped-parity lemma needs the low-degree part to be only $O(a)$, because it is multiplied by $u/d\approx\rho$. The proposition's lower bound has the same form as the upper bound that the subcritical route would need. The proposition therefore refutes only the polynomial normalization of eq. (42), not the strategy.
2. **Error (overclaim).** The abstract, introduction and status table dropped the upper limit $n\le e^{c_1d}$ and the probability. Without the upper limit the claim is false: for fixed $d$, $\mathcal D(S)$ is bounded by the cost of the full sign pattern of $f$, so $\mathcal D(S)/n\to0$.
3. The draft did not define $u$ or say which subcritical step it meant by "second step".
4. It described eq. (42) loosely, as "of order $d^{1+\beta}$".
5. The second sufficient condition was placed on the wrong sample event.
6. An unsupported remark said the entropy bound was useful "only for $n=O(d^2)$".
7. The upper bound on the cost per sample carried an unnecessary condition.
8. The heuristic paragraph said only high-degree components can make jumps; $A x_1$ is a counterexample.

## Changes made

- **Section 6 rewritten.** It is now titled "Where the exponential proof breaks". It says that the proposition refutes only eq. (42). It adds a paragraph labelled *extension suggested by the proof*. That paragraph states the event and constants it uses and the tail band, and explains why an upper bound on the conditioning cost matching the proposition up to constants would give $\exp(\Omega(d))$. The second sufficient route now carries the correct event and constants, and states that its constant must not depend on $\alpha$. The entropy remark and the heuristic paragraph were corrected.
- **Scope of the obstruction claims.** The abstract, introduction, status table, README and FAQ now state the range $\exp(d^\epsilon)\le n\le e^{c_1d}$ and the probability. They describe the exponential question as open, with the missing matching bound identified.
- **Sign-only statements.** The abstract now says "of the same form $d^{\Theta(\sqrt d)}$". The introduction states $d\ge25$ and that the explicit bound is nontrivial only for $d\ge385$. The comparison with the NNGP note now names the different learner and depth. The paired improvement is mentioned. The residual-variance bound is stated with $s$.
- **Margin theorem.** The abstract and introduction now state $d\ge d_0$ (not explicit), and the activation hypotheses are made precise. The constant $c_q$ is explicit.
- **Fourier pair.** The formula number was replaced by a one-line derivation from the beta integral and $|\Gamma(1+ix)|^2=\pi x/\sinh(\pi x)$. While applying this change, a factor 2 in the intermediate identity was found and corrected; the final transform was already correct and had been confirmed numerically.
- **Notation and small gaps.** $v_{\min}$ is used throughout Section 5, and the Poisson count is written $\Pi_t$. The Chernoff justification and the boundary case of the walk induction were added, and the convention $a_{D+1}:=0$ was dropped.

## Round 2

See the section below, added after the second round.
