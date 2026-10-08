GPT-6 (Codex) — 2026-09-13

# Prediction and allocation under uncertainty: an explicit two-model calculation

This is a deliberately bounded illustration, not a calibrated prior. It distinguishes the distribution of the realized optimal stopping time from a planned allocation chosen before learning which improvement law applies.

Set $N=10^{120}$, $k_0=10^{-27.5}$ and normalize $\alpha(0)=1$. With probability $\pi$, efficiency follows the unbounded raw-input power law

$$\alpha_P(x)=1+k_0x.$$

With probability $1-\pi$, use the finite-ceiling model

$$\alpha_C(x)=\frac{M}{1+(M-1)e^{-rx}},\qquad M=10^6,\qquad r=\frac{Mk_0}{M-1}.$$

Both have initial marginal proportional gain $k_0$. The second follows from $\alpha_C(F)=M-(M-1)e^{-F/F_0}$, $F_0=(M-1)/k_0$ and the shared feedback equation $dF/dx=\alpha_C$. Its individual optimum is approximately

$$x_C\simeq\frac1r\ln\!\left(Mk_0N-(M-1)\right)=7.1722\times10^{29}\text{ FLOPs}.$$

The displayed expression is the exact $k=1/N$ crossing; replacing $N$ with $N-x_C$ gives the true interior optimum. Their relative discrepancy is negligible here because $x_C/N\simeq7.17\times10^{-91}$. The power model's individual optimum is $(N-k_0^{-1})/2\simeq N/2$.

## A single allocation chosen before learning

The expected objective is

$$V(x)=(N-x)\left[(1-\pi)\alpha_C(x)+\pi(1+k_0x)\right].$$

At a macroscopic fraction of $N$, the ceiling branch is saturated with exponentially negligible derivative. Define

$$B=(1-\pi)M+\pi.$$

Then

$$V(x)\simeq(N-x)(B+\pi k_0x),$$

whose stationary point is

$$\boxed{x_{\rm late}=\frac N2-\frac{B}{2\pi k_0}.}$$

This late optimum becomes positive when

$$\boxed{\pi>\pi_{\rm crit}=\frac{M}{k_0N+M-1}\simeq3.1623\times10^{-87}.}$$

For $\pi$ well above this threshold, the optimum approaches $N/2$. For $\pi$ below it, the plateau approximation must not be used to conclude that the optimum is literally zero: initial research is strongly worthwhile in both models, and the true optimum remains near the early finite-ceiling optimum. Within an extraordinarily narrow neighborhood of the threshold, the neglected ceiling derivative determines a smooth crossover. The threshold formula correctly determines the appearance of a macroscopic late allocation to the precision relevant here.

More explicitly, let $R=\pi k_0N/B$. Relative to the almost costless early saturation allocation, whose utility is approximately $BN$, the optimized late allocation gives

$$\frac{x_{\rm late}}N=\frac{R-1}{2R},\qquad\frac{V(x_{\rm late})}{BN}=\frac{(1+R)^2}{4R}=1+\frac{(R-1)^2}{4R},\qquad R>1.$$

Thus optimized nontrivial late research beats early saturation as soon as $R>1$. A fixed choice of exactly $N/2$ beats early saturation only for $R>2$, or $\pi\gtrsim6.3246\times10^{-87}$.

| Prior probability of the power model | Planned late research fraction | Expected utility / early-saturation utility |
|---:|---:|---:|
| $10^{-87}$ | No macroscopic late allocation | Approximately 1 |
| $6.3246\times10^{-87}$ | $0.25$ | $1.125$ |
| $10^{-86}$ | $0.341886$ | $1.36963$ |
| $10^{-85}$ | $0.484189$ | $8.41360$ |
| $10^{-80}$ | $0.499999842$ | $7.90570\times10^5$ |

The reason is that the power branch's multiplier at cosmic research scales is of order $k_0N=10^{92.5}$, compared with only $10^6$ in the other branch. Expected effective-cooming utility weights those levels directly. This calculation does not say that the power branch is probable, or that the realized optimal stopping time is usually late.

## What changes if every world has multiplier at most $10^{12}$?

A universal ceiling $M_{\max}=10^{12}$ removes the $10^{92.5}$ utility scale. A rare branch's maximum multiplier advantage over the baseline ceiling $M=10^6$ is at most $10^6$. Its contribution cannot dominate expected terminal efficiency unless its probability is of order $10^{-6}$ or larger:

$$\pi M_{\max}>(1-\pi)M\quad\Longleftrightarrow\quad\pi>\frac{M}{M_{\max}+M}\simeq10^{-6}.$$

This also bounds the probability needed to justify sacrificing a macroscopic consumption fraction. Suppose early research already obtains $M$ in the usual world and some multiplier $a_E\geq1$ in the rare world. If researching to $fN$ could obtain $M_{\max}$ in the rare world, even the best possible late outcome cannot beat the early allocation unless

$$\boxed{\pi\geq\frac{fM}{(1-f)M_{\max}-a_E+fM}.}$$

For $f=1/2$ and $a_E$ small relative to $M_{\max}$, this is again approximately $10^{-6}$. It is a necessary condition under this two-world comparison, not a sufficient condition: the ceiling might not actually be reachable by $fN$, or it might already be reachable much earlier. Different baseline or rare-world paths change the exact comparison.

A cap does not remove every incentive to spend research on tiny-probability opportunities. For example, replace the power law with the capped law

$$\alpha_{P,\mathrm{cap}}(x)=\min(10^{12},1+k_0x).$$

This reaches its ceiling at

$$x_H=\frac{10^{12}-1}{k_0}=3.1623\times10^{39}\text{ FLOPs},$$

only about $3.16\times10^{-81}$ of the budget. Once both branches saturate, further research is wasteful. So there is no macroscopic late optimum. Nevertheless, probabilities near $10^{-87}$ can justify this relatively cheap research: the approximate expected marginal-return condition before $x_H$ remains $\pi k_0N>B$. The research cost is so small relative to $N$ that an extremely small expected efficiency increment can repay it. The hard cap can be smoothed without changing this conclusion materially.

## Learning makes the precommitment conclusion inapplicable to typical stopping

The actual toy agent need not commit to an $x$ before observing research outcomes. These two illustrative deterministic laws are distinguishable very early: around $x=k_0^{-1}\simeq3.16\times10^{27}$, the ceiling branch has $\alpha_C\approx e$ while the power branch has $\alpha_P=2$. With reliable observation, the agent can identify the branch long before either individual optimum, then stop near $7.17\times10^{29}$ in the ceiling world or near $N/2$ in the power world.

Consequently a tiny prior on the power branch does not force almost every realized world to spend half its compute researching. The large utility tail changes the optimal initial policy only to the extent that the law remains uncertain and investigating it has a cost. Realistic noise, partial observability and later regime changes require an adaptive learning model.

For reporting the requested best guess, distinguish (1) a subjective prediction of the realized optimal stopping time, (2) the best fixed allocation before any further learning, and (3) an adaptive policy. The table above addresses only (2). It must not be substituted for (1) or (3).
