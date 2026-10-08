# What takeoff and headroom estimates can constrain in the common-multiplier model

This appendix contains independent mathematical sensitivity calculations. It does not infer a probability distribution from the number of scenarios. The starting values are the user's `N=10^120`, `a(0)=1`, `k0=10^-29`, with `dF/dx=a` and objective `a(x)(N−x)`.

## The variables must be kept distinct

| Source variable | Meaning | Why it is not automatically the toy multiplier |
|---|---|---|
| Training software efficiency | Training compute-equivalent gain in some capability | Does not necessarily save the same fraction of inference operations or improve all valuable output |
| Fixed-performance inference efficiency | Fewer operations per output of specified quality | Does not measure the learning or discovery algorithm's efficiency |
| Research taste | Value per experiment or a research judgment score | May change experiment selection without accelerating the experiment itself |
| R&D uplift | Counterfactual speed of research with AI vs without | Includes input complementarities and constraints particular to the modeled organization |
| Parallel-labor-equivalent software | Extra human-like cognitive labor that would give comparable performance | Its numerical scale depends on assumed production elasticities |
| Hardware efficiency | Operations per joule, dollar, second, or unit of matter | The toy budget is already expressed as raw FLOPs; increasing attainable FLOPs revises `N` |
| Common multiplier `a` | Output per raw FLOP for both research and valuable consumption | This is the deliberately stronger assumption of the user's problem |

One can make a **conditional identification**, such as `a=S` for a source's software variable. That choice needs its own justification and should remain visible. A bottleneck caused by fixed experiment compute can be retained in a separate real-world model, but not silently while also asserting that every research FLOP gets the full common multiplier.

## A bigger ceiling does not uniquely imply a later stop

Consider the previously used effective-research cost law

\[
C(F)=H^{-1}+(1-H^{-1})(1+F/F_0)^{-p},\quad a=1/C,
\quad F_0=p(1-H^{-1})/k_0.
\]

Here `H` is final common-multiplier headroom and `p` is the effective-research cost-gap exponent. It is not a raw-input progress exponent or an experiment-compute elasticity. Set `t=ln(1+F/F0)`. The exact expressions used in the code are

\[
k(t)=k_0 e^{-(p+1)t}/C(t)^2,
\]
\[
x(t)=F_0\left[H^{-1}(e^t-1)+(1-H^{-1})\frac{e^{(1-p)t}-1}{1-p}\right],
\]

with the final quotient replaced by `t` at `p=1`. We solve `k(t)[N−x(t)]=1`, using logarithms throughout. The residual in log optimality is below `10^-8` in every reported row. The following numbers are `log10(x*)`:

| Assumed `log10 H` | `p=.05` | `p=.1` | `p=.25` | `p=.5` | `p=1` | `p=2` |
|---:|---:|---:|---:|---:|---:|---:|
| 3 | 117.07 | 113.18 | 103.00 | 90.37 | 74.50 | 58.63 |
| 12 | 118.70 | 118.99 | 108.40 | 93.37 | 74.50 | 55.63 |
| 26.49 | 118.70 | 119.00 | 117.09 | 98.20 | 74.50 | 50.80 |
| 60 | 118.70 | 119.00 | 119.40 | 109.37 | 74.50 | 39.63 |
| 120 | 118.70 | 119.00 | 119.40 | 119.70 | 74.50 | 29.30 |

These are illustrative headrooms, not estimates of their probabilities or demonstrations that `H=10^120` is physically meaningful. The 26.49 row is included because of the labor-equivalent coordinate appearing in the Forethought code; equating that coordinate with the common multiplier is an additional assumption.

The nonmonotonic behavior in `H` at `p>1` is real within this family. Before saturation, effective research feeds back superlinearly; raising the ceiling lets most improvement happen near the finite raw-input singularity of the uncapped model. At `p=1`, the leading optimum is approximately `sqrt(N/k0)`, nearly independent of `H`. At small `p` and sufficiently high `H`, saturation has little effect before stopping and `x*/N≈p`. Thus simply moving an upper cutoff on `H` is not a coherent general answer to uncertainty about the stopping distribution.

## Identical headroom and initial slope, radically different stopping

There is a simpler constructive demonstration. Define `k(x)=d ln(a)/dx` directly. Each of these laws starts at `a=1`, has exactly the same `k0`, and integrates to the same total log gain `ln H`:

\[
k_{exp}(x)=k_0e^{-x/L},\qquad L=\ln H/k_0;
\]
\[
k_s(x)=k_0(1+x/L_s)^{-s},\qquad L_s=(s-1)\ln H/k_0,\quad s>1.
\]

They are valid common-multiplier laws: define `a(x)=exp(∫_0^x k(u)du)` and `F(x)=∫_0^x a(u)du`; then `dF/dx=a` holds identically. No experiment bottleneck has been introduced.

For the same `H=10^12` in every row, exact optimal stopping gives:

| Marginal-return tail | `log10 x*` | Research share of budget |
|---|---:|---:|
| Exponential | 32.763 | `5.79×10^-88` |
| Power, `s=3` | 61.076 | `1.19×10^-59` |
| Power, `s=2` | 75.941 | `8.74×10^-45` |
| Power, `s=1.5` | 90.807 | `6.41×10^-30` |
| Power, `s=1.25` | 102.639 | `4.36×10^-18` |
| Power, `s=1.1` | 112.169 | `1.47×10^-8` |
| Power, `s=1.01` | 118.526 | 0.03355 |

The one-sided threshold `k=10^-120` and the exact optimum differ in the last row because `x/N` is no longer negligible. The code uses the exact remaining budget throughout.

These laws do not match all existing historical observations by construction, but they can be joined smoothly to the same locally fitted history after its observed range. The late tail then receives no new likelihood information from that common early history. Matching more present-day derivatives only delays where the splice occurs. Historical calibration and a headroom estimate cannot resolve this freedom without a substantive prior over future research technology.

## Implications for the distribution

1. Treat present productivity, headroom, and the approach to the ceiling as separate uncertainties. The existing `k0` calibration covers the first; the takeoff literature mainly informs nearby feedback and the plausibility of substantial headroom.
2. Do not turn a research-taste cap into a cap on every beneficial computation. Do not multiply learning, inference and hardware numbers unless the target quantity and independence assumptions justify the product.
3. Make the late-tail functional choice explicit. A finite-doubling terminal convention in a near-term simulator is not evidence of a sharply reachable ultimate ceiling.
4. Current sources do not provide a likelihood that ranks `10^75`, `10^110` and `10^118` stopping against each other robustly. They can motivate revised scenarios, not replace judgment with an empirically identified cosmic posterior.
5. Any reported distribution here remains a distribution over known-law optima. Bayesian adaptive research under uncertain laws also depends on learning and option value; these sources do not identify that decision problem.

## Reproduce

```sh
python research_oct2026/takeoff/headroom_sensitivity.py
```

Outputs are `headroom_sensitivity.json` and `headroom_sensitivity.csv`, both in this directory. NumPy and SciPy are the only nonstandard dependencies. All calculations are local and deterministic.
