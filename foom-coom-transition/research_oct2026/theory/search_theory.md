# What search and complexity theory constrain in the foom–coom model

Research note, 2 October 2026. This is a theoretical audit, with no empirical fitting. Read alongside the previous [tail evidence](../../forecast_revision/tail_evidence.md), [forecast](../../forecast_revision/REPORT.md), [mathematical model](../../forecast_revision/MATH.md), [recalibration](../../calibration_revision/REPORT.md), and [consolidated PDF source](../../report.md). The current normalization is $k_0\simeq10^{-29}$ per raw FLOP; some prior documents use the superseded $10^{-27.5}$ value.

**Finding:** the literature supports a diversity of possible improvement mechanisms. It does not establish a probability distribution over their prevalence, and it does not justify the earlier concentration on extremely slow residuals. The earlier $10^{110}$ median was a transparent elicitation, but the theoretical case for its particular family weights is weaker than the precision of that number suggests. Equally, there is no theorem implying an early finish or a low ceiling near human efficiency.

## 1. Keep three different complexity questions separate

The report needs a law for the multiplier discovered after research input, $a(F)$, with

$$\frac{dF}{dx}=a(F),\qquad C(F)=1/a(F),\qquad k(x)=-\frac{C'(F)}{C(F)^2}.$$

The last identity follows directly by the chain rule. It preserves the common multiplier. A theorem about any of the following supplies a law for $C(F)$ only after additional assumptions:

1. **Execution complexity:** operations needed to solve a task of size $n$ using an already specified algorithm.
2. **Search complexity:** oracle calls or operations needed to find a satisfactory object, algorithm, or proof.
3. **Research productivity:** how the value-weighted efficiency of future research and consumption changes after spending resources on discovery.

In particular, a lower bound increasing with task size $n$ is not a lower bound on the residual improvement exponent as research input $F$ grows. A convergence theorem per function evaluation is not automatically a convergence theorem per raw FLOP. Evaluation cost, accuracy, verification, and the relationship between the task objective and the shared multiplier must be specified.

For a *fixed* task portfolio, reference implementation, accuracy and machine, $T_{\rm reference}/T_{\rm minimum}$ is a meaningful speedup ceiling. Changing task size, acceptable error, or the consumption portfolio changes that ratio. A brain-equivalent implementation supplies a feasible reference point; feasibility by itself is an upper bound on minimum implementation cost, not a lower bound. It therefore cannot establish that little algorithmic headroom remains. This last statement is an elementary inequality, not an empirical claim about brains.

## 2. Primary-source audit

Each entry states the result's scope and what it fails to identify. These are primary papers, including author preprints; the paper texts, rather than commentary about them, were used where accessible.

**Wolpert and Macready (1997), “No Free Lunch Theorems for Optimization.”** The finite black-box result averages performance over all objective functions; the search history contains queried points and objective values, and the algorithms in the basic comparison do not revisit points. On that uniform problem average, an advantage on one subset is offset elsewhere. It does not say that all algorithms perform equally under a structured distribution representing physical or engineering problems. It identifies no residual exponent, no human-relative ceiling, and no preference for random search in the actual world. See the setup and Theorem 1, pp. 68–70. [Original paper PDF](https://victoryepes.blogs.upv.es/wp-content/uploads/2020/10/No-free-lunch.pdf), [publisher DOI](https://doi.org/10.1109/4235.585893).

**Igel and Toussaint (2003), “Recent Results on No-Free-Lunch Theorems for Optimization.”** The sharpened finite-class result requires closure under permutations for the uniform class average; the paper also derives conditions for arbitrary nonuniform distributions. Thus the relevant question is the distribution of real tasks and what structure survives relabeling, not whether the algorithm is called intelligent or adaptive. A problem distribution with physical locality, compositional structure, or useful observations need not satisfy NFL symmetry. This is a direct reason not to invoke NFL as evidence for a blind-search production law. [Author preprint, including the generalized theorem](https://arxiv.org/pdf/cs/0303032).

**Levin (1973), “Universal Sequential Search Problems.”** Theorem 2 gives a search algorithm optimal up to a multiplicative constant and an additional input-length term in its specified computational setting. The problem is finding a witness satisfying a checkable relation; it is not unrestricted scientific discovery or maximizing an unspecified utility. The constant is not a small numerical guarantee. The result supplies neither a practical finite-budget discovery bound nor a law connecting discoveries to the common efficiency multiplier. [Original publication record](https://www.mathnet.ru/php/archive.phtml?jrnid=ppi&option_lang=eng&paperid=914&wshow=paper), [English text hosted by Lance Fortnow](https://lance.fortnow.com/papers/files/Levin%20Universal.pdf).

**Hutter (2002), “The Fastest and Shortest Algorithm for All Well-Defined Problems.”** Theorem 1 gives $T_M(u)\le5t_p(u)+d_pT_{t_p}(u)+c_p$ for programs with provable equivalence and provable time bounds in the chosen formal system. Section 5 gives $d_p=40\,2^{\ell(p)+\ell(t_p)}$ and an additive proof-search bound exponential in proof length. The factor five alone is consequently not a usable ceiling on attainable improvement. The theorem restricts its competitor class, and its explicit overhead bound may be vastly above $10^{120}$. This does not prove that actual overhead must be that large. Section 2 also makes Levin search's verification cost and exponential program-length factor explicit. None of these bounds calibrates research productivity. [Original preprint, Theorem 1 and Sections 2, 5–6](https://arxiv.org/pdf/cs/0206022).

**Blum (1967), “A Machine-Independent Theory of the Complexity of Recursive Functions.”** The paper constructs functions with very different speedup behavior: some have nearly quickest programs, while others admit repeated large asymptotic speedups. The existence of the latter rules out an unrestricted assertion that every computable task has an asymptotically fastest program. It is not a prevalence claim about useful tasks or a discoverability bound, and it does not imply unbounded speedup for a fixed finite input portfolio. The publisher article could not be fetched here; this limited description is supported by its indexed abstract and the author's publication listing, and is also consistent with Hutter's explicit use of the result. [Primary article DOI](https://doi.org/10.1145/321386.321395), [author's publication listing](https://www.cs.cmu.edu/~mblum/research/).

**McNerney, Farmer, Redner and Trancik (2009 preprint; 2011 publication), “The Role of Design Complexity in Technology Improvement.”** Random trials replace costs in interacting component clusters and retain an improvement if their sum falls. Equations 5–7 relate a power exponent to component-cost density and design complexity: $p=1/(\gamma d^*)$. The general $d^*$ is a max–min over available modifying clusters, not simply the total number of variables. Alternative modification routes can matter even in this model. It supplies a concrete slow-tail mechanism under fixed rules, not a theorem about optimal intelligent redesign. Mapping trial count to $F$, adding a positive cost floor, and assigning priors to $\gamma,d^*$ are further modeling choices. It does not measure these parameters for future AI. [Primary preprint, model steps and equations 5–7](https://arxiv.org/pdf/0907.0036), [published DOI](https://doi.org/10.1073/pnas.1017298108).

**Stich, Müller and Gärtner (2011), “Optimization of Convex Functions with Random Pursuit.”** The algorithm repeatedly optimizes along a random line. Theorems 5.1–5.2 establish geometric convergence in expectation under suitable curvature and smoothness assumptions; Theorem 5.3 gives an inverse-iteration bound for general smooth convex objectives. An exact or suitably accurate line-search oracle is assumed. With fixed absolute line-search error, the strong-convexity result has an error floor. These upper bounds demonstrate how adaptation can defeat fixed-sampling geometry; they do not guarantee those conditions, constant oracle cost, or exponential progress in AI research. [Original preprint, Section 5](https://arxiv.org/pdf/1111.0194).

**Rudolph, “Massively Parallel Simulated Annealing and its Relation to Evolutionary Algorithms.”** Pages 4–5 give the contrast especially directly: fixed sampling on the quadratic sphere has an expected gap proportional to $t^{-2/d}$, whereas adapting the generating distribution can accelerate convergence. This is a statement about an optimization algorithm and an objective class, not a universal limit imposed by dimension alone. It also separates probability of finding an exact finite-state optimum from expected continuous objective error. Those are distinct convergence quantities and must not be swapped when choosing a tail model. [Author-hosted paper, Examples 1–2](https://ls11-www.cs.tu-dortmund.de/people/rudolph/publications/papers/ecj1.4.pdf).

**Zalka (1999), “Grover's quantum searching algorithm is optimal.”** For unstructured oracle search, the paper gives a matching quantum query bound, with approximately $(\pi/4)\sqrt M$ queries needed for near-certain success among $M$ possibilities. This is a genuine restriction on how much adaptation helps in that oracle model. It does not establish that research is unstructured, translate query cost into FLOPs, or say how much value finding a candidate produces. Quantum query complexity should not be substituted directly into the report's classical FLOP budget. [Original paper](https://arxiv.org/pdf/quant-ph/9711070).

## 3. Why adaptive versus blind search matters

The following is an elementary derivation, independent of the source summaries. Suppose a smooth minimum is locally quadratic in $d$ coordinates and a fixed sampler has positive finite density there. A gap at most $\epsilon$ occupies volume proportional to $\epsilon^{d/2}$. For $m$ independent draws,

$$P(\text{best gap}>\epsilon)\simeq\exp(-A m\epsilon^{d/2}),$$

so a characteristic best gap is $\epsilon_m\asymp m^{-2/d}$. This gives $p=2/d$ only if candidate evaluations cost a constant amount of effective research and the sampling density never improves. It is not a lower bound for all methods.

For a deliberately simple counterexample, let $q(\theta)=\|\theta-\theta_*\|^2$ with known quadratic form and unknown center. Exact values at $0,e_1,\ldots,e_d$ recover $\theta_{*,i}=[q(0)+1-q(e_i)]/2$. The center is identified after $d+1$ function evaluations, despite the blind search exponent $2/d$. Finite arithmetic and evaluation precision must be accounted for in either example; the point is that the same geometry admits radically different search laws depending on useful information.

Conversely, with one uniformly hidden successful candidate among $M$ possibilities and only success/failure feedback, a classical nonrepeating search has success probability $m/M$ after $m\le M$ queries. Failures contain no clue about which of the unqueried candidates is better. A finite search can therefore be prohibitively expensive without generating a smooth tail of progressively smaller improvements. The forecast needs to distinguish **hardness that leaves many tiny valuable improvements** from **hardness that makes the next valuable improvement uneconomic**.

## 4. What heterogeneous bottlenecks do—and do not—imply

These are deductions inside the report's cost representation, not empirical estimates.

### A. Finite sums select the smallest exponent only asymptotically

For $z=1+F/F_0$ and

$$C=f+\sum_{i=1}^m w_i z^{-p_i},\qquad w_i>0,\quad p_i>0,$$

the smallest $p_i$ eventually controls the residual cost. It does not follow that the smallest exponent is near zero, or that its amplitude becomes relevant within the budget. At a finite horizon the relevant marginal terms are $p_iw_i z^{-p_i}$, because

$$k=\frac{\sum_i p_iw_i z^{-p_i}}{F_0zC^2}.$$

A slow component $s$ overtakes a faster component $b$ in the marginal gain only if

$$\ln z>\frac{\ln[p_bw_b/(p_sw_s)]}{p_b-p_s}.$$

Cost dominance uses $w_i$ without the $p_i$ factor and can occur at a different point. A component with exactly $p=0$ is an irreducible cost, not a source of marginal progress. An extremely small positive exponent need not be an economically important residual over a finite interval. Since $F\le HN$ under a ceiling $a\le H$, one can test the crossover against $\ln(1+HN/F_0)$ rather than appealing to $F\to\infty$.

### B. Optimal allocation alone does not eliminate a mandatory slow component

Suppose independent components have structural gaps $w_iF_i^{-p_i}$ and the agent chooses $F_i$ subject to $\sum_iF_i=F$. The interior optimum satisfies

$$F_i=\left(\frac{p_iw_i}{\lambda}\right)^{1/(1+p_i)}.$$

As $F\to\infty$, the smallest exponent receives the dominant research allocation and still sets the aggregate power. Thus “the researcher can allocate intelligently” is not by itself a rebuttal to bottleneck dominance. The substantial uncertainty is whether a component is mandatory and its production curve remains fixed. Learning better search heuristics, changing representations, allowing substitute architectures, or abandoning a negligible consumption task changes those assumptions.

### C. An infinite hierarchy needs a distributional assumption near zero

Let $t=\ln z$ and $g(t)=\int_0^{p_{\max}}w(p)e^{-pt}\,dp$. If $w(p)\sim A p^{\nu-1}$ as $p\downarrow0$, with $A>0$ and $\nu>0$, a change of variable $u=pt$ gives

$$g(t)\sim A\Gamma(\nu)t^{-\nu}.$$

This produces the logarithmic cost gap used in the prior report. The claim is mathematically sound, but the assumption about $w(p)$ is doing the work. Generic heterogeneity does not imply it. Nor does a continuous prior *over one world's unknown exponent* imply that each realized world contains a physical continuum of exponents. The former is uncertainty across worlds; the latter is within-world aggregation. Averaging them before solving the stopping problem can change the forecast object.

For example, suppose $p=1/D$ and large difficulty $D$ has an exponentially falling density. The induced exponent density near zero is proportional to $p^{-2}e^{-b/p}$, not a nonzero constant. More generally, if $w(p)$ has the suppression $e^{-b/p}$ times a power of $p$, Laplace's method minimizes $pt+b/p$ at $p\simeq\sqrt{b/t}$ and yields

$$\ln g(t)=-2\sqrt{bt}+O(\ln t).$$

This remains slower than every fixed power of $z$, but differs strongly from an inverse power of $\ln z$. Conversely, a strict lower cutoff $p_{\min}>0$ produces a power factor $z^{-p_{\min}}$ (with an additional $1/\ln z$ factor for a regular continuous density at its lower endpoint). These examples are not preferred priors; they show why the zero-exponent neighborhood needs its own justification.

For a finite number $m$ of independently sampled mandatory components, if $P(p_i<\epsilon)\simeq A\epsilon^\nu$, then

$$P(p_{\min}>\epsilon)\simeq\exp(-mA\epsilon^\nu).$$

The number of components, their dependence, their cost weights, and the near-zero probability law jointly determine the smallest relevant exponent. “There are many components” is insufficient to set any of them.

## 5. A further finite-budget constraint: tiny payoff is not automatically worth waiting for

Suppose at a current allocation $x$ the remaining raw budget is $R=N-x$. A known research project costs $d$ additional raw FLOPs and then improves the multiplier by a factor $1+\delta$, with no intermediate gain or later opportunities. Completing it is worthwhile exactly when

$$a(1+\delta)(R-d)>aR
\quad\Longleftrightarrow\quad
d<\frac{\delta}{1+\delta}R.$$

This preserves the common multiplier and is an exact finite comparison. Discovery can be possible but not worth doing. Complexity theory may make the cost $d$ high while leaving $\delta$ small; that creates earlier cessation, not automatically a slowly improving tail that remains worth funding.

For genuinely random completion times, success probabilities, and partial observations, this inequality must be replaced by an expected-value or adaptive stopping calculation. A smooth expected improvement path can hide long realized plateaus and rare jumps. Differentiating that path is not equivalent to solving each world's known-law stopping point or the agent's optimal learning policy.

## 6. Consequences for the distribution

1. **Do not infer a low universal ceiling from human efficiency.** A task-specific lower bound on execution cost could constrain that task's headroom; the current universal multiplier does not specify such a task or lower bound.
2. **Do not treat the 35% hard-residual branch and 10% near-zero continuum branch as theorem-backed probabilities.** Those previous weights encode judgments about mandatory components, their amplitude, persistence and searchability. The papers establish possibility under assumptions, not these probabilities.
3. **Retain both slow and fast mechanisms.** Slow convergence is possible under restricted search, persistent interactions, or new hard tasks. Fast convergence is possible when structure becomes exploitable, a finite design space is exhausted, or the remaining projects fail the payoff test. No result here supplies their relative weights.
4. **Condition on a mechanism before eliciting an exponent.** A more interpretable prior would ask about fixed versus changing task portfolios; irreplaceable versus bypassable bottlenecks; informative versus uninformative feedback; finite candidate spaces versus continuous refinements; and the relation between payoff and discovery cost. Then state the induced exponent assumptions explicitly.
5. **Show a sensitivity that removes the continuum and relaxes mandatory hard residuals.** This is a robustness test for the prior median, not evidence that these mechanisms have zero probability. A second sensitivity can retain them while varying amplitude–difficulty dependence and the lower exponent cutoff.
6. **Treat the $10^{110}$ central value as underidentified.** This theoretical audit weakens the claimed direction of the update from $10^{74}$ toward $10^{110}$: the late mechanisms are legitimate counterexamples to an early universal prediction, but they are not calibrated evidence that late cases dominate. The justified conclusion is broader uncertainty, not an independently derived replacement median.

No new numerical probability weights are proposed here. Choosing precise weights from this review would repeat the central weakness being audited. All formulas above are analytic and reproducible from the displayed assumptions; no new empirical data or fitted parameters were used.
