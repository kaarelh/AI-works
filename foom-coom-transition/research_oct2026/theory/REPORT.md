# What theory does and does not identify about the research tail

GPT-6 (Codex), 2 October 2026. Independent theory contribution to the foom–coom revision. All operation counts use the stipulated common FLOP convention, with \(N=10^{120}\) and \(k_0=10^{-29}\). No empirical data were fitted for this contribution.

**The previous median near \(10^{110}\) is not a consequence of finite headroom, search complexity, or heterogeneous bottlenecks. It depends materially on guaranteeing that a selected slow mechanism persists across the extrapolation.** Removing just the guaranteed slow component from the existing heterogeneous branch moves the old mixture median to approximately \(10^{86}\), with all other branch weights and draws retained. This is a diagnostic, not a recommended replacement forecast. Theory supports a distribution over mechanisms and their persistence, but does not provide defensible numerical weights for that distribution.

The user's objection to a low ceiling inferred from brain efficiency is sound. A ceiling for a fixed execution task does not bound improvement in the value of arbitrary thought. Dropping the old ceiling range \(10\)–\(10^{12}\) broadens the possibilities; it does not necessarily move stopping later, because shared feedback can make higher headroom accelerate the passage through research.

## The invariant model

Let \(a(0)=1\), effective research satisfy \(dF/dx=a\), and terminal valuable consumption be \(U(x)=a(x)(N-x)\). Write execution cost \(C(F)=1/a(F)\). Then

\[
x(F)=\int_0^F C(u)du,\qquad
k(x)=\frac{d\ln a}{dx}=\frac{da}{dF}=-\frac{C'(F)}{C(F)^2}.
\]

For a known differentiable law, an interior stationary point satisfies \(k(x)=1/(N-x)\). It is a global stopping rule only with additional conditions, such as the log-convex cost families audited previously. A plateau followed by a known valuable breakthrough is a direct counterexample to stopping at the first marginal crossing.

Every positive, nondecreasing raw-input path \(a(x)\) can preserve shared feedback: define \(F(x)=\int_0^x a(u)du\), invert this strictly increasing function, and use \(a(F)=a(x(F))\). Thus specifying a rival law directly in raw research is not inherently a violation of feedback. It is a different production assumption, and should be labeled as such.

## A finite observation interval cannot identify the stopping distribution

Here is a constructive result stronger than merely noting that extrapolation is long. Suppose an observed law is known exactly on \([0,X]\), its endpoint is \(a_X\), and its best historical terminal utility is

\[
B=\max_{0\leq x\leq X}a(x)(N-x).
\]

Choose any future target \(T>X\) and ceiling \(H>a_X\) satisfying \(H(N-T)>B\). Extend the law with a plateau at \(a_X\) until \(T\), a jump to \(H\) at \(T\), and a plateau thereafter. Its unique global optimum is \(T\): pre-jump future consumption is worse than at \(X\), the jump beats the whole observed prefix, and utility declines thereafter. Each such law exactly shares the observed prefix, its initial slope, and its ceiling. It also satisfies shared feedback via the integral above. The jump can be replaced by a narrow smooth rise, and the joins smoothed immediately after the observed interval, making the optimum arbitrarily close to \(T\) while preserving the prefix. This does not require claiming an analytic continuation from a globally analytic law.

The supplied calculation uses the identical prefix \(a(x)=1+k_0x\) through \(X=10^{30}\), hence \(a_X=11\). With the same ceiling \(H=10^6\), global optima at \(10^{31},10^{60},10^{100},10^{119}\), and \(9\times10^{119}\) are all possible. This is an existence proof, not a claim that any particular delayed discovery is plausible.

For data consisting only of measurements of \(a(x)\) on \([0,X]\), under the same observation and noise model, any probability measure over the admissible targets can therefore induce an identical likelihood. Posterior odds between these extensions equal their prior odds. Noise only widens the set of indistinguishable extensions. Other evidence about algorithm internals, proofs, or physical constraints could distinguish the extensions even during that interval. Restricting the model to a particular stationary search mechanism or an analytic family can also restore identification within that restriction; the restriction supplies the extrapolation. This is why adding more fits to the same efficiency history cannot by itself establish the remote stopping distribution.

## What finite headroom actually constrains

For fixed task, input distribution, required accuracy, machine model, and output unit, a positive minimum execution cost bounds speedup. For a changing task frontier, those conditions fail. A best attainable algorithm may exist for the finite physical universe, but its existence supplies neither a useful ceiling relative to today's universal thought nor the effort needed to find it. Physical operation bounds constrain available computation; they do not also determine the value extracted from each operation. [Lloyd, *Ultimate physical limits to computation*](https://arxiv.org/abs/quant-ph/9908043).

For any ceiling \(H\), global optimality compared with consuming immediately implies only

\[
a(x_*)(N-x_*)\geq N\quad\Rightarrow\quad x_*/N\leq1-1/H.
\]

If \(k(x)\) is additionally nonincreasing, integrating the stopping condition yields the tighter bound

\[
\ln H\geq\int_0^{x_*}k(x)dx\geq\frac{x_*}{N-x_*},
\qquad x_*/N\leq\frac{\ln H}{1+\ln H}.
\]

Even \(H=10\) permits 70% of the budget under the second bound; \(H=10^{12}\) permits about 96.5%. Neither bounds the stop to a tiny fraction of the budget. Monotonicity matters: the delayed-jump construction need not satisfy it.

Human energy use, present neural inference cost, and thermodynamic cost per logical operation concern different denominators. None supplies the missing stationary utility unit or a justified universal \(H\leq10^{12}\). This does not establish infinite useful headroom; it removes one proposed argument for a particular low numerical cap.

Even with a valid task match, a feasible brain implementation gives \(C_{\min}\leq C_{\rm brain}\), an upper bound on the minimum cost. Bounding headroom from above requires the opposite kind of result: a positive lower bound on \(C_{\min}\). A feasible implementation alone cannot supply it.

## Search theory leaves several rival mechanisms open

Blind sampling near a nondegenerate quadratic optimum in \(d\) dimensions gives probability of a gap below \(\epsilon\) proportional to \(\epsilon^{d/2}\), hence best gap after \(n\) independent samples scales as \(n^{-2/d}\). This elementary volume argument assumes a fixed proposal density and fixed evaluation cost. Its exponent is not a lower bound on an adaptive researcher's performance.

Adaptive optimization can concentrate search. Random Pursuit has geometric convergence on suitably strongly convex objectives and \(O(1/n)\) convergence on the broader smooth convex class under its line-search assumptions. Those results are in oracle iterations, not FLOPs, and absolute line-search error can create a limiting error. [Stich, Müller and Gärtner, section 5](https://arxiv.org/pdf/1111.0194). Noise and limited observation can restore polynomial minimax rates, but the oracle class and information constraints must be specified. [Agarwal et al., theorems 1 and 2](https://arxiv.org/pdf/1009.0571). Neither theorem says general AI research converges quickly, or that its ultimate exponent is small.

An interacting-design model derives an inverse relation between improvement exponent and design complexity. This supplies a mechanism for persistent bottlenecks under its random local redesign rule; it does not establish that a smarter researcher must retain that rule or architecture. [McNerney et al., *Role of design complexity in technology improvement*](https://arxiv.org/abs/0907.0036). The separate [source audit](search_theory.md) distinguishes this issue from optimal allocation among genuinely mandatory bottlenecks: allocation alone generally does not remove the asymptotically slowest exponent.

Universal algorithm search is not a practical bound on research completion. Hutter's near-optimal execution theorem requires provable equivalence and time bounds, and retains large program-dependent costs; Blum-style speedup addresses asymptotic algorithm runtimes on growing inputs. Neither translates to a probability over when discovery returns fall to \(10^{-120}\). [Hutter, theorem 1 and section 5](https://hutter1.net/ai/pfastprg.pdf). Nor does a no-free-lunch theorem under a symmetric objective distribution justify blind search under a structured scientific prior; see the source audit for the exact scope.

## Explicit rival laws and stopping scales

The following are conditional examples with identical \(k_0\), budget, and shared feedback. None is an empirical fit or a forecast weight. Table entries are \(\log_{10}\) optimal raw FLOPs, computed by the accompanying script.

| Law | Ceiling \(10^{12}\) | Ceiling \(10^{60}\) |
|---|---:|---:|
| Exponential cost gap in effective research | 29.00 | 29.00 |
| Exponential efficiency gap in effective research | 31.38 | 31.54 |
| Raw linear efficiency until a hard cap | 41.00 | 89.00 |
| Power cost gap, \(p=2\) | 55.63 | 39.63 |
| Power cost gap, \(p=1\) | 74.50 | 74.50 |
| Power cost gap, \(p=0.5\) | 93.37 | 109.37 |
| Power cost gap, \(p=0.25\) | 108.40 | 119.40 |
| Power cost gap, \(p=0.1\) | 118.99 | 119.00 |
| Uniform continuum of cost-gap exponents on \((0,1)\) | 117.68 | 117.68 |

For power cost gaps, put \(f=H^{-1}\), \(z=1+F/F_0\), and

\[
C=f+(1-f)z^{-p},\quad F_0=p(1-f)/k_0,
\]
\[
x=F_0\{f(z-1)+(1-f)I_p(z)\},\qquad
k=\frac{k_0z^{-p-1}}{C^2},
\]

where \(I_p(z)=(z^{1-p}-1)/(1-p)\), or \(\ln z\) for \(p=1\). The exact root is \(x+1/k=N\). If the floor dominates both instantaneous cost and the research integral, and \(x_*\ll N\),

\[
x_*\sim p(1-f)N^{1/(p+1)}k_0^{-p/(p+1)}f^{(p-1)/(p+1)}.
\]

This explains why increasing headroom moves the stop later for \(p<1\), earlier for \(p>1\), and cancels for \(p=1\). Once the asymptotic regime fails, use the exact law. For \(0<p<1\) and an irrelevant ceiling, \(x_*\simeq pN\).

An exponential **cost** gap is \(C=f+(1-f)e^{-F/S}\), with \(S=(1-f)/k_0\). It gives

\[
x=S\{fF/S+(1-f)(1-e^{-F/S})\},\qquad
k=k_0e^{-F/S}/C^2.
\]

An exponential **efficiency** gap is \(a(F)=H-(H-1)e^{-F/S}\), with \(S=(H-1)/k_0\). Its exact raw law is logistic:

\[
a(x)=\frac{H}{1+(H-1)e^{-rx}},\quad r=\frac{Hk_0}{H-1},
\]

and, when the optimal fraction is negligible,

\[
x_*\simeq r^{-1}\ln\{Hk_0N-(H-1)\}.
\]

Even the variable to which “exponential convergence” applies matters. For a capped raw power law,

\[
a(x)=\min\{H,(1+k_0x/q)^q\},\quad
x_* = \min\left\{\frac{q}{k_0}(H^{1/q}-1),\frac{q}{1+q}(N-k_0^{-1})\right\}.
\]

Thus a finite ceiling can imply \(10^{41}\) or \(10^{89}\) with the same raw linear growth until exhaustion. A smooth cap can approximate this example.

## The old tiny-exponent weight is a substantive prior commitment

The prior gives 35% to a heterogeneous law that *always* contains a residual exponent drawn log-uniformly from 0.03 to 0.3, with cost amplitude between \(10^{-12}\) and \(10^{-2}\). It separately gives 10% to an actual continuum of exponents extending to zero. The single-power branch contributes additional slow-law probability. These choices do not follow from merely having many components.

At finite \(t=\ln z\), marginal gains of components are proportional to

\[
p_iw_i e^{-p_i t}.
\]

Small \(p_i\) is penalized by its own prefactor. A smaller exponent dominates only after its amplitude and crossover permit it. As \(p\to0\), a component becomes an approximately constant floor and its derivative vanishes. “The smallest exponent wins” is an eventual statement, not a monotone finite-budget prediction. The [prior audit](tail_prior_audit.md) provides examples and the noncommuting limits.

A continuum with cost density nonzero at zero produces \(g(z)\sim1/\ln z\). It assumes a sufficiently dense, persistent spectrum of progressively harder improvements with that specific weight distribution. It is not equivalent to uncertainty about one finite positive exponent. In the old \(H=10^{12}\) example, the stop occurs at \(a\approx210\), far below the ceiling: logarithmic pre-ceiling growth, rather than an already exhausted brain-like efficiency margin, drives the result.

For a useful alternative parameterization, let \(p=1/D\), where \(D\) is a latent difficulty. A cost-weighted density constant near \(p=0\) corresponds to a difficulty tail proportional to \(D^{-2}\). An exponentially declining difficulty density instead induces \(w(p)\propto p^{-2}e^{-b/p}\); a saddle-point calculation gives \(\ln g\sim-2\sqrt{b\ln z}\), not \(-\ln\ln z\). This is our derivation, explained in the source audit. No choice is automatically correct. The lesson is to elicit difficulty, opportunity value, and persistence, rather than silently treating a flat exponent density as neutral.

The numerical ablation holds every old family weight and ceiling draw fixed, and replaces the heterogeneous branch by its existing fast component alone, recalibrated to the same \(k_0\). The continuum and single-power priors remain unchanged.

| Prior diagnostic | Median \(\log_{10}x_*\) | Middle 50% | Probability \(x_*\geq0.01N\) |
|---|---:|---:|---:|
| Old mixture at \(k_0=10^{-29}\) | 110.12 | 95.82–117.68 | 23.38% |
| Guaranteed slow residual removed from that branch | 86.35 | 67.30–117.68 | 21.12% |

The median changes by nearly 24 orders, while the rightmost tail barely changes. The separate 20% scale-free branch places every one of its saved draws beyond 1% of \(N\). Consequently the old “23%” tail probability is also largely a family-weight choice. Removing the residual is no more empirically established than retaining it; this calculation identifies what must be justified.

## Architectural resets and finite completion

An early finite set of refinements can be exhausted; a difficult component can be bypassed; or a redesign can expose a new set of harder opportunities. A reset therefore invalidates the old tail, but does not necessarily stop research. Its direction must be modeled. This differs from simply adding an additional slow component that survives forever.

A transparent persistence diagnostic lets a tail cease to apply with constant hazard \(h\) per decade of \(1+k_0x\). Its survival to \(x\) is

\[
S(x)=\exp[-h\log_{10}(1+k_0x)].
\]

This is an elicitation parameterization, not evidence for a constant hazard. At \(x=10^{110}\), approximately 81 decades have elapsed: \(h=0.01\) gives survival 44.5%, and \(h=0.03\) gives 8.8%. Applied only as a no-reset diagnostic to the old heterogeneous-plus-continuum branch mass, their total 45% surviving mass at their old stopping points falls to about 19.9% or 4.0%, respectively. This does **not** assign the missing mass an earlier stopping time: it requires a post-reset law and a decision model. Resets could also reveal longer-lived opportunities.

A finite-completion countermodel makes the mechanism concrete. Suppose \(m\) known projects each multiply the common efficiency by \(B>1\) and each requires \(E\) effective research. With complete feedback, after \(j\) projects the raw cost of the next is \(E/B^j\), so

\[
x_m=\frac{EB}{B-1}(1-B^{-m}),\qquad a_m=B^m.
\]

All projects are worth doing if \(N>EB/(B-1)\), since their terminal utilities increase with \(m\); research ends exactly after the finite list. Taking \(E=\ln B/k_0\) matches the initial *finite-difference* log gain per raw input; the step path's derivative is zero between discoveries and undefined at the jumps. Then even large finite \(H=B^m\) can be reached in raw cost of order \(k_0^{-1}\). The strong assumptions are a finite list, known costs, and no growth in effective difficulty across projects. Replacing \(E\) by growing project costs may prevent exhaustion. This example is a mechanism-level rival to a fixed residual hierarchy, not evidence that all research is such a list.

An infinite sequence with geometrically shrinking raw project costs would create a formal finite-input divergence. The finite list avoids it. Ord's recent work emphasizes the corresponding importance of feedback-loop duration for calendar-time singularities; it does not identify the raw-FLOP stopping tail. The retrieved primary page is dated 28 August 2026, not September. [Ord, *The Dynamics of Intelligence Explosions*, “Going Finite” and the discrete model](https://www.forethought.org/research/the-dynamics-of-intelligence-explosions).

## Known-law optima and adaptive decisions are different targets

The former forecast samples a deterministic law and optimizes as if it were known. A fixed allocation under uncertainty instead maximizes \((N-x)\mathbb E[a(x)]\); averaging laws, averaging their optima, and optimizing an expected law are distinct operations. A Bayesian adaptive policy conditions on observations and can buy information or pursue discrete projects through a plateau.

For an exact example, suppose the current state has multiplier \(a\), one potential gain by factor \(B\), and exponential discovery hazard \(\lambda\) per raw research unit. Stop immediately on discovery, or after a timeout \(t\). Then

\[
V(t)/a=\int_0^t\lambda e^{-\lambda s}B(N-s)ds+e^{-\lambda t}(N-t),
\]
\[
V'(t)/a=e^{-\lambda t}\{\lambda(B-1)(N-t)-1\},\qquad
 t_*=\max\{0,N-[\lambda(B-1)]^{-1}\}.
\]

The realized stop is \(\min(T,t_*)\), not the optimum of the expected smooth curve. Shared feedback is preserved by \(\lambda=\rho a\) for a hazard \(\rho\) per effective research, while the pre-discovery multiplier remains constant. Matching \(\lambda(B-1)=k_0\) matches the initial proportional slope of expected efficiency; it does **not** match realized \(d\ln a/dx\), which is zero between jumps, or the slope of expected log efficiency, which is \(\lambda\ln B\). For known \(\lambda\), failure conveys no information about its value. Unknown rates, uncertain existence of a discovery, or a finite candidate list update the failure-conditioned hazard and change the policy. The prior audit derives a Gamma-mixture example.

A plateau therefore cannot prove that useful opportunities are gone. Conversely, the possibility of an arbitrarily remote breakthrough does not force endless research: its gain, probability, evidence, and research cost enter the decision.

## Distributional changes I would carry forward

1. **Retire \(10^{110}\) as a theory-backed central estimate.** Retain it only as the output of the documented old prior. The ablation establishes that a specific slow-residual commitment substantially sets its median.
2. **Elicit the existence and persistence of bottlenecks separately from their conditional tail.** Include a probability that the dominant slow component is absent, finite, bypassable, or replaced, and model resets jointly with new opportunity creation. Heterogeneity alone does not justify guaranteed \(p\in[0.03,0.3]\) or a dense continuum down to zero.
3. **Remove the unsupported low universal headroom cap.** Separate fixed-task ceilings from a changing task frontier, and allow large finite or budget-irrelevant headroom. Infer no common direction of the stopping revision from this change alone.
4. **Use conditional scenario CDFs and a prior-sensitivity envelope before a pooled CDF.** The evidence supports the distinction between rapid completion, persistent improvement, and later regime changes more strongly than any numerical mixture. The ablation is a required sensitivity, not a replacement probability distribution.
5. **State the forecast target.** Known-law global optima, realized adaptive stopping, and a fixed allocation require different distributions. The historical initial slope does not determine discovery hazards or an observation model.

No theoretical argument audited here justifies a unique updated median or numerical branch weights. There is also no theorem favoring every mathematically admissible continuation equally. A better *elicited* distribution is possible if the report explicitly asks which persistence and task-frontier assumptions its weights encode. A narrower apparently objective distribution obtained by counting papers, selecting tiny exponents, or imposing brain-based headroom would be less justified.

The robust forecast implications are that initial research is valuable conditional on the causal interpretation of \(k_0N\gg1\); stops much earlier than \(N\) and at macroscopic fractions of \(N\) both remain possible; finite ceilings alone do not settle the issue; and neither short historical curves nor the cited complexity theorems identify the tail across this horizon.

## Reproduction and files

[Reproduction instructions](REPRODUCE.md), [calculation code](calculate_theory.py), [machine-readable results](theory_results.json), and a [compact scenario table](rival_stopping_scenarios.csv) accompany this report. [Search theory and primary-source limits](search_theory.md) and [independent tail-prior audit](tail_prior_audit.md) contain further derivations. A later [review of the proposed synthesis prior](PROPOSED_MIXTURE_REVIEW.md) critiques its parameter commitments before inspecting its resulting quantiles. The script reads prior calculation modules and saved prior draws, writes only in this folder, and disables bytecode writes outside it.
