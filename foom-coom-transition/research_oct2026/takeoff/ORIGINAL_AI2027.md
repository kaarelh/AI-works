# Original AI 2027 takeoff forecast: replication and transfer audit

Snapshot: 2 October 2026. All new work is confined to `research_oct2026/takeoff`. The relevant public code is pinned to commit `2085376a178d709ec9c1461f5eef59e543751cd7`; source URLs and SHA-256 digests are in `sources/original_code/manifest.json`.

## What was actually forecast

The April 2025 forecast concerns elapsed calendar time between four capability milestones, conditional on a superhuman coder arriving in March 2027. It estimates how much human-only software research is needed for each transition, then accelerates that research using milestone-specific AI R&D multipliers. Its survey inputs concern hypothetical researcher replacements and experiment-compute constraints. These are small informal elicitation exercises, not controlled measurements of automated research productivity. Its claimed substantial room above human research taste is a judgment from the human range and possible improvements beyond it. No universal algorithmic efficiency ceiling, raw-FLOP consumption objective, or late marginal-return law is fitted. [Primary forecast](https://ai-2027.com/research/takeoff-forecast).

## Parameters and exact equations

The [pinned parameter file](https://github.com/uvafan/timelines-takeoff-ai-2027/blob/2085376a178d709ec9c1461f5eef59e543751cd7/takeoff/params.yaml) fixes milestone speedups at 5, 25, 250 and 2,000. SC→SAR has a 15% zero-time atom; otherwise its human-only time is lognormal with 10th/90th percentiles 1.5/10 years. Automated-median-researcher→SAR time `G` is lognormal with endpoints 1/25 years. The two underlying normal variates have correlation 0.8. The number `J` of SAR→SIAR-equivalent jumps needed after SIAR is independent lognormal with endpoints 0.3/7.5. These are judgmental distributions. The declared 0.7 time-gap correlation does not affect the used three-phase chain; it only feeds unused draws.

The [pinned simulation](https://github.com/uvafan/timelines-takeoff-ai-2027/blob/2085376a178d709ec9c1461f5eef59e543751cd7/takeoff/forecasting_takeoff.py) gives, in human-only years,

\[
B=10+G,\qquad D=B(B/10)^2,\qquad h_{SAR,SIAR}=D-B,
\]
\[
h_{SIAR,ASI}=D\{(D/B)^J-1\}.
\]

For a phase requiring `h` human-years, progress `u` obeys

\[
du/dt=v_0(v_1/v_0)^{u/h}.
\]

The upstream implementation uses one-day forward Euler steps and a 1,000-calendar-year cap **per phase**. Its speedups have no sampled uncertainty. My exact continuous-time integral is

\[
\Delta t=h\frac{v_0^{-1}-v_1^{-1}}{\ln(v_1/v_0)}.
\]

This allows large Monte Carlo replications without integrating every daily step. It is an analytic reproduction of the interpolation rule, not an empirical fit.

## Independent numerical reproduction

`reproduce_original.py` uses one million draws with seed 20261002. It implements the probability model independently and extracts only the upstream phase integrator with Python's AST for spot comparisons. Representative continuous versus original daily results are 145.144 versus 146 days for a 4-human-year SC→SAR gap, and 106.999 versus 109 days for an 18.75-human-year SAR→SIAR gap. Such numerical differences are immaterial to this task.

| Quantity | 10th percentile | Median | 90th percentile |
|---|---:|---:|---:|
| Human-only SC→SAR years, including zero atom | 0 | 3.287 | 9.338 |
| Human-only SAR→SIAR years | 2.315 | 18.720 | 393.736 |
| Human-only SIAR→ASI years | 2.534 | 96.523 | 1,080,815 |
| Calendar SC→SAR years | 0 | 0.327 | 0.928 |
| Calendar SAR→SIAR years | 0.036 | 0.293 | 6.156 |
| Calendar SIAR→ASI years, uncapped | 0.0043 | 0.162 | 1,819 |
| Calendar SC→ASI years, uncapped | 0.181 | 1.043 | 1,879 |

Adding the upstream cap gives SC→ASI 90th percentile about 1,001 years. Approximately 10.8% of SIAR→ASI draws hit that cap. Thus the code's distant calendar tail is numerically censored, and cannot be repurposed as an independently determined ultimate technological plateau. The saved HTML's summary table displays `0.04 to 56` for SAR→SIAR; the pinned equations yield about 0.036–6.156 years. This may be a formatting/transcription issue in the page. The computation is explicit in `original_replication.json`.

Setting every uncertain **input** to its central value gives about 0.813 calendar years for the full chain. The median of the joint simulated **output** is 1.043 years. These are different operations; using the former as the forecast median would be incorrect.

## What the apparent research return of about four means

An illustrative 5-fold labor-value gain while cumulative human research stock rises from 10 to 15 implies

\[
r=\frac{\ln 5}{\ln(15/10)}=3.96936.
\]

Changing the required extra research to 10 years instead of 5 gives `r=2.32193`. This is arithmetic on chosen capability distances and research stocks. It is not a regression estimating an invariant exponent of universal output per FLOP.

Likewise, assuming tenfold less experiment compute retains 40% of progress gives a local compute elasticity `ln(0.4)/ln(0.1)=0.39794`. Under a constant-elasticity extension, 30-fold faster researchers at fixed experiment compute produce `30^(1−0.39794)=7.75` times the progress. This calculation explains why a large cognitive-labor multiplier need not equal the progress multiplier. It also identifies the extra assumption required: the separate experiment input is held fixed.

## Translation to the requested toy model

For comparison only, suppose a cumulative-effective-research law really were

\[
a(F)=(1+F/F_0)^r,\qquad dF/dx=a,\qquad F_0=r/k_0.
\]

Then

\[
k(x)=\frac{k_0}{1+[(1-r)/r]k_0x}.
\]

For `0<r<1`, optimal research is exactly

\[
x_* = r(N-1/k_0)\simeq rN.
\]

For `r>1`, the law instead diverges at

\[
x_{sing}=\frac{r}{(r-1)k_0}.
\]

Inserting 3.96936 and `k0=10^-29` gives `x_sing≈1.337×10^29` raw FLOPs. That is a failure of an unlimited superlinear law to describe finite technology; it is **not** a forecast of physically infinite computation. A saturation rule is required before any stopping number can be obtained. The original model does not supply that rule.

Keeping its fixed experiment bottleneck while claiming to apply the user's common multiplier would change the problem: by assumption, the same multiplier improves all research operations and valuable consumption. A useful real-world bottleneck must be explicitly introduced as a model revision. An AI R&D progress multiplier of 2,000 cannot simply be used as `a=2,000`, and AI 2027's roughly one-year takeoff does not constrain the location of a `10^-120` marginal return.

## Reproduce

From the project root:

```sh
python research_oct2026/takeoff/reproduce_original.py
```

This requires NumPy and SciPy already present in that environment, makes no network calls, and overwrites only `original_replication.json` inside this assigned folder. Source copies are preserved without modification.
