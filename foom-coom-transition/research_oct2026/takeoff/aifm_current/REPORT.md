# AI Futures Model audit and reproduction, 2 October 2026

**The current AI Futures Model does not establish a low ceiling on the user's common efficiency multiplier, and it does not identify a stopping input at marginal return 10^-120/FLOP.** It provides an explicit near-term model of software research, with empirically informed but substantially elicited parameters. Its research-taste ceiling is not a ceiling on software efficiency. Applying its software-production law to the user's common-multiplier model without its separate experimental and training bottlenecks instead produces a finite-input mathematical singularity under all three central parameter configurations. That is a reason to reject a literal cosmic extrapolation, not a prediction that research should stop at the singularity.

This appendix independently reproduces calibrations, extracts the implemented equations, distinguishes evidence from judgment, and identifies documentation/code inconsistencies. It supplements the parent task's original AI 2027 and Forethought reviews.

## Source and version boundary

The latest relevant author update found through 2 October is [Q2.5 2026 Timelines Update: Uplift and Revenue, 16 August 2026](https://blog.aifutures.org/p/q25-2026-timelines-update-uplift). It adds coding-uplift and revenue anchors alongside task horizons, incorporates training time, and revises taste estimates. The public site labels itself the August 2026 model. The repository's only public commit at retrieval is **1c40ecdb246c25980515441a66571931c5604e11**, authored and committed **9 September 2026, 13:00:40−07:00**, with message “Initial release.” Thus the source release date is later than the forecast vintage. These are not interchangeable dates.

Primary artifacts:

- [Pinned model guide](https://github.com/AI-Futures-Project/aifm-public/blob/1c40ecdb246c25980515441a66571931c5604e11/progress_model/README.md), [implementation](https://github.com/AI-Futures-Project/aifm-public/blob/1c40ecdb246c25980515441a66571931c5604e11/progress_model/_impl.py), and [public explanatory HTML](https://github.com/AI-Futures-Project/aifm-public/blob/1c40ecdb246c25980515441a66571931c5604e11/public/explanations.html).
- [Authors' supplementary parameter rationales](https://docs.google.com/document/d/1ru6Okbxb6XuH18Cz8439sdQJazMV39hNxsWDokh97r0/edit), archived as `supplementary_materials.txt`. This is a live document retrieved 2 October; its individual passages have mixed dates.
- [July training-flow explanation](https://ai-2040.com/supplements/takeoff-forecast?hide=none), which explicitly changes effective compute from a stock product to an integral of software-adjusted training flows.

Repository files are MIT-licensed. The checkout is unmodified. File hashes, runtime versions and commit metadata are in `provenance.json`. The original research archived a downloaded page shell and text extracted from the pinned repository HTML. Those article snapshots are omitted from this public package; their provenance hashes are retained.

## What the model actually computes

Use R for research stock, S for software efficiency, E for cumulative effective training compute, C_tr for raw training-compute flow, C_exp for experiment compute capacity, and L for serial coding labor. The model integrates

\[
S=(R/R_0)^r,\quad r=1/\beta,\qquad
\dot E=C_{tr}(t)S,\qquad
\dot R=X(C_{exp},L)\,\overline T(E).
\]

The implementation stores log10 E and evaluates

\[
\frac{d\log_{10}E}{dt}=\frac{C_{tr}(t)S}{E\ln10},\qquad
\frac{d\log_{10}S}{dt}=\frac{r\dot R}{R\ln10}.
\]

The research-effort CES is

\[
X=\left[\alpha(C_{exp}^{\zeta})^{\rho_X}+(1-\alpha)L^{\rho_X}\right]^{1/\rho_X}.
\]

Here rho_X is negative, so experiment compute and coding labor are complements. At fixed experiment compute, unlimited coding labor has a finite throughput benefit. The serial coding input is a parallel coding quantity raised to p, with central p=0.5. The current default uses an optimization over task automation efficiencies, rather than merely a two-input CES. A task's automation efficiency grows as eta_init(E/E_i)^eta_slope after it becomes efficiently automatable; coding and taste are separate functions of E. These details are in [progress_rate.py](https://github.com/AI-Futures-Project/aifm-public/blob/1c40ecdb246c25980515441a66571931c5604e11/progress_model/progress_rate.py), [ces_functions.py](https://github.com/AI-Futures-Project/aifm-public/blob/1c40ecdb246c25980515441a66571931c5604e11/progress_model/ces_functions.py), and [automation_model.py](https://github.com/AI-Futures-Project/aifm-public/blob/1c40ecdb246c25980515441a66571931c5604e11/progress_model/automation_model.py).

**S has no modeled finite ceiling.** Taste and some coding quantities have ceilings. At fixed external resources, bounded taste and bounded coding imply bounded research-effort flow; research stock still accumulates, and S continues increasing as a power. Hardware manufacture and hardware R&D feedback are outside the core equations: their resource trajectories are supplied externally.

The July update explicitly introduced the flow equation to avoid retroactively applying newly discovered algorithms to past training FLOPs. It treats frontier development as one continuous training process, still an approximation to discrete retraining. This training delay matters to calendar takeoff. It is not licensed by the user's two-action model, where an improvement changes the common multiplier directly. [Author explanation](https://ai-2040.com/supplements/takeoff-forecast?hide=none).

## Taste distribution, saturation and exact equations

Let b be the top-to-median human taste ratio, u the additional median-to-top gaps beyond the top human, and A=b^(1+u) the imposed absolute taste cap. “Top” is fixed at the 99.9th percentile, z_top=Phi^-1(.999)=3.090232306. AI position in the underlying normal distribution is

\[
z(E)=z_{AC}+s(\log_{10}E-\log_{10}E_{AC}),
\qquad s=T_{rate}/g_{anchor}.
\]

T_rate is elicited in SDs per anchor-progress-year; g_anchor converts it to SDs per effective-compute OOM. It must not be read directly as SDs/OOM.

The implementation sets y=mu+sigma z and, for smoothing parameter L_s other than 0.5, uses

\[
\rho_T=\frac{2\ln(1/L_s-1)}{\ln A},\quad
v=\frac1{1-A^{\rho_T}},\qquad
T(y)=\left[A^{\rho_T}+(1-A^{\rho_T})e^{\rho_Tvy}\right]^{1/\rho_T}.
\]

For L_s=0.5 the exact continuous limit implemented is

\[
T(y)=\exp\{\ln A[1-e^{-y/\ln A}]\}.
\]

mu and sigma are **numerically solved**, conditional on the assumed transform, to make E[T(mu+sigma Z)]=1 and T(mu+sigma z_top)/T(mu)=b for Z standard normal. They are not fitted to a researcher-level outcome dataset. Human mean, rather than human median, is normalized to 1 in code. Aggregate taste is E[max(T_human,T_AI)], with numerical interpolation. See [taste_distribution.py, especially lines 90–94, 122–142 and the constraint solver](https://github.com/AI-Futures-Project/aifm-public/blob/1c40ecdb246c25980515441a66571931c5604e11/progress_model/taste_distribution.py#L90).

At L_s=0.5, a finite taste cap does **not** imply fast convergence. Substituting the schedule gives

\[
T(E)=A\exp(-D E^{-\lambda}),\quad D>0,\qquad
\lambda=\frac{\sigma s}{\ln A\ln10}.
\]

Thus A−T(E) is asymptotically proportional to E^-lambda. Our independently calculated central values are:

| Case | A | lambda | Additional log10 E after AC to reach 0.99 A |
|---|---:|---:|---:|
| Daniel Q2 configuration | 1.489×10^10 | 0.01584 | 212.7 |
| Eli Q2 configuration | 262,144 | 0.02396 | 128.9 |
| Brendan Q2 configuration | 553,839 | 0.02781 | 112.0 |

These are properties of the imposed tail, not measured forecasts of attainable effective compute. **E is effective training compute, not the user's accumulated effective research F.** The exponents cannot be copied into the prior report's C(F) tail without an additional translation model.

## Parameters: measured, fitted, elicited, or assumed?

The distinctions below are important: a numerical calibration can be exact conditional on assumptions while those assumptions remain judgmental.

| Quantity | Central values / sampling specification | Epistemic status |
|---|---|---|
| Software efficiency progress in early 2024 | 1.0 OOM/year; lognormal central 80% input interval 0.4–2.5 | Elicited synthesis informed by capability-versus-training-compute/time regressions; not a direct operation-count measurement |
| beta / r | beta about 0.318; r about 3.14 after running calibration | Derived from the software-rate target and reconstructed research inputs; **not an independently estimated universal tail exponent** |
| Top/median taste b | Daniel 3.9665, Eli 4, Brendan 4.3466 | Expert judgments informed by surveys; Brendan configuration additionally conditioned on preliminary task evaluation |
| Taste rate T_rate | Daniel 3 [1,9], Eli 2.3 [0.8,6.6125], Brendan 2.6926 [1.25,5.8] SD/anchor-progress-year | Cross-task calibration and elicited transfer to AI research; not a long-run fitted law |
| Taste at AC | Daniel 0 SD; Eli/Brendan 0.5 SD | Elicited capability relationship |
| Top quantile | .999 | Assumption motivated by about 1,000 researchers; fixed in sampling |
| Extra gaps u | Daniel 16 [4,64]; Eli/Brendan 8 [2,32] | Judgment informed by chess/Go analogies and adjustment for research's wider action space |
| Smoothing L_s | .5; Beta(2,2) across draws | Subjective shape choice and behavior check, not a tail fit |
| Parallel penalty | .5; Beta(3,3) | Structural judgment |
| Unlimited-coding throughput benefit | about 15; shifted lognormal 1+Lognormal(ci80=[1,200]) | Elicited bottleneck judgment |
| Unlimited-experiment-compute benefit | about 1000; 1+Lognormal(ci80=[25,40000]) | Elicited bottleneck judgment |
| Slowdown from 10× less experiment compute | 2.7944; 1+Lognormal(ci80=[.7,4.6]) | Survey-informed estimate |
| rho_X, alpha, zeta | approximately −.15475, .81352, .65411 after central configuration calibration | Numerically derived CES coefficients conditional on the preceding anchors and resource series |
| Exogenous training/experiment/inference capacity and human labor | `inputs/input_data.csv` | Estimates plus forecasts, not controlled observations; no endogenous industrial acceleration |

Intervals in brackets are elicited central 80% **input** intervals, not confidence intervals from our reproduction. Source definitions and inheritance: [base configuration](https://github.com/AI-Futures-Project/aifm-public/blob/1c40ecdb246c25980515441a66571931c5604e11/config/sampling_config.yaml), [Daniel](https://github.com/AI-Futures-Project/aifm-public/blob/1c40ecdb246c25980515441a66571931c5604e11/config/sampling_config_daniel.yaml), [Eli Q2](https://github.com/AI-Futures-Project/aifm-public/blob/1c40ecdb246c25980515441a66571931c5604e11/config/sampling_config_q2_eli.yaml), [Brendan Q2](https://github.com/AI-Futures-Project/aifm-public/blob/1c40ecdb246c25980515441a66571931c5604e11/config/sampling_config_q2_brendan.yaml), and [parameter provenance labels](https://github.com/AI-Futures-Project/aifm-public/blob/1c40ecdb246c25980515441a66571931c5604e11/components/ParameterHoverContext.tsx).

The supplement explains that taste-spread surveys involved small groups, including eight frontier technical staff in 2024 and ten in the 2025 technical-staff subset. The slope methodology maps progress on several tasks into a standardized human range, adjusts that range to frontier researchers, and combines task estimates with judgmental analogy weights. Daniel explicitly expects a heavier upper tail than Eli because research has a much wider action space than chess or Go. These are useful grounds for uncertainty, not a physical brain-efficiency ceiling. [Supplementary rationale](https://docs.google.com/document/d/1ru6Okbxb6XuH18Cz8439sdQJazMV39hNxsWDokh97r0/edit).

Brendan's YAML records a shape-only update using preliminary TastEval results, a reasoning-era effective-compute-multiplier doubling time of 4.45 months, hierarchical errors including task resampling, and a −0.40 dependence between taste slope and spread. It explicitly says the absolute performance reference is an AI proxy rather than a human. Eli's slope/spread correlation is −0.20. Those comments document the claimed conditioning; this reproduction does not independently reproduce that posterior because the underlying evaluation artifact/conditioning analysis was not recovered. It would be double counting to treat the updated parameters and the same evaluation as independent evidence.

## Calibration reproduction and sensitivities

`reproduce.py` reads the inherited YAML configurations, substitutes their marginal central values, chooses the highest-weight AC mode (uplift-solved), runs the unmodified model over 2017–2060, and saves diagnostics. **A trajectory at central input values is not the median Monte Carlo trajectory.** No probability of a singularity is inferred from this small set of deterministic runs.

Calibration reconstructs historical serial coding uplift as

\[
M(t)=1+(M_* -1)2^{(t-t_*)/D},
\]

with consistent year units and a cap. It recalculates research effort/stock on this path, then rescales r until the reconstructed 2024 software rate equals the input target. In natural-log units beta=g_R/g_S, with g_S=ln(10)×the OOM/year input. The resulting beta approximately .318 corresponds to g_R about .732/year at the reference point. A default `r_software=2.4` is only an initial value and is overwritten. The reconstruction and anchor correction are not iterated to full self-consistency. [Implemented calibration, lines 1217–1240](https://github.com/AI-Futures-Project/aifm-public/blob/1c40ecdb246c25980515441a66571931c5604e11/progress_model/_impl.py#L1217).

Near the human range the documented taste elasticity diagnostic is

\[
m=s\frac{\log_{10}b}{z_{top}},\qquad m/\beta=mr.
\]

| Deterministic case | r | beta | m | m/beta | Legacy taste-uplift doubling ratio |
|---|---:|---:|---:|---:|---:|
| Daniel Q2 central | 3.14465 | .31800 | .36157 | 1.13702 | .91986 |
| Eli Q2 central | 3.13775 | .31870 | .28452 | .89275 | 1.08684 |
| Brendan Q2 central | 3.14326 | .31814 | .35017 | 1.10067 | .93857 |
| Eli, substituting older frontend taste values | 3.13775 | .31870 | .24507 | .76898 | 1.23150 |
| Daniel, software rate .4 OOM/year | 1.25786 | .79500 | .59179 | .74439 | 1.26873 |
| Daniel, software rate 2.5 OOM/year | 7.86164 | .12720 | .18162 | 1.42781 | .81246 |

Changing the software-rate anchor also changes the anchor effective-compute growth rate, hence the SD/OOM conversion. Holding m fixed while varying beta would therefore not reproduce the model's elicitation conventions. The central Daniel, Eli and Brendan AC-to-ASI times in these runs are 1.14, 1.88 and 1.24 years. Those are calendar outputs of this model, not cosmic stopping inputs.

The 1 OOM/year software anchor is **2.302585 natural-log units/year**, rather than the prior report's rounded 1 natural-log unit/year. It would imply k_path≈2.3×10^-29 at a research denominator of 10^29 FLOPs/year if all bridges were accepted. Since AIFM's quantity is training efficiency and the earlier report uses a broader common-multiplier proxy, that is a sensitivity, not a replacement estimate.

At b=4, changing the elicited extra-gap limit u from 2, 4, 8, 16, 32 to 64 changes log10 A from 1.81, 3.01, 5.42, 10.24, 19.87 to 39.13. This wide variation is generated by uncertain exponentiation of a human-spread analogy. `headroom_sensitivity.json` records the grid. None of these values is a measured upper bound on universal algorithmic efficiency.

## Taste-only singularity: what survives the training-flow update

Ignoring taste limits and assuming fixed experimental/coding throughput, the older instantaneous-training approximation gives T proportional to S^m. Then

\[
\dot S\propto S^{1-\beta+m},\qquad g_S\propto S^{m-\beta}.
\]

Hence m>beta gives accelerating proportional progress, and successive taste-uplift doubling times have ratio 2^(beta/m−1). The code still reports this legacy ratio. [Diagnostic, lines 1785–1804](https://github.com/AI-Futures-Project/aifm-public/blob/1c40ecdb246c25980515441a66571931c5604e11/progress_model/_impl.py#L1785).

**Independent derivation for the current continuous-training equations:** with constants suppressed,

\[
\dot E=C R^r,\qquad\dot R=K E^m.
\]

Dividing and integrating gives R^(r+1) proportional to E^(m+1), up to an integration constant. The large-state dynamics are

\[
\dot E\propto E^{r(m+1)/(r+1)}.
\]

The condition rm>1, equivalently m>beta, therefore survives as an idealized asymptotic singularity condition. But successive **taste-uplift** doubling times now have asymptotic ratio

\[
2^{(\beta/m-1)/(\beta+1)},
\]

not the old diagnostic. The Daniel and Brendan central ratios become .93859 and .95304. `lag_doubling_check.json` independently verifies the formula by quadrature on four exact invariant trajectories to better than 10^-10. This is our analysis, not a claimed correction published by the authors. Actual finite trajectories also have saturation, changing resources, human contributions and coding gains; neither diagnostic is their exact observed doubling ratio. This distinction does not invalidate the integrated model, but it limits literal interpretation of its displayed summary.

## Documentation/code audit

1. **Stock product versus flow integral.** Public explanatory HTML still states E=C_train S; current code and the July supplement use E'=C_tr S. The latter is used in all our reproductions.
2. **Calibration assumption.** Explanatory HTML and supplementary prose still describe no historical AI uplift through 2024 and a 2012 starting year. Current production configurations start in 2017 and calibration reconstructs historical coding assistance. Public prose's beta≈.31 is nevertheless close to reproduced beta≈.318.
3. **Plain Python default differs from the advertised Daniel default.** `Parameters()` obtains taste slope 2.1 from `TASTE_SLOPE_DEFAULTS`, despite `DEFAULT_PARAMETERS` specifying 3.0. It gives m/beta=.79494 and AC-to-ASI 2.005 years, compared with 1.13702 and 1.140 years for the Daniel central configuration. [parameters.py line 53](https://github.com/AI-Futures-Project/aifm-public/blob/1c40ecdb246c25980515441a66571931c5604e11/progress_model/parameters.py#L53), [config.py](https://github.com/AI-Futures-Project/aifm-public/blob/1c40ecdb246c25980515441a66571931c5604e11/progress_model/config.py).
4. **Eli preset is stale relative to the August taste update.** The named frontend preset keeps slope 2.1 and b=3.698, while the Q2 Monte Carlo configuration uses 2.3 and 4. In a matched substitution, the older values delay ASI by .608 years. This comparison changes only the taste pair, not every frontend convention. [constants/parameters.ts, Eli preset](https://github.com/AI-Futures-Project/aifm-public/blob/1c40ecdb246c25980515441a66571931c5604e11/constants/parameters.ts#L348), [Q2 update configuration](https://github.com/AI-Futures-Project/aifm-public/blob/1c40ecdb246c25980515441a66571931c5604e11/config/sampling_config_q2_eli.yaml#L103).
5. **Taste normalization and rounded SDs.** Explanatory prose uses a median-one lognormal and often rounds the top to 3 SD. Code fits a bounded transformed normal with mean one and top at 3.090232 SD. The table above uses code definitions.
6. **Not every historical rationale can be rebuilt from this public repository.** The input-series provenance document references an upstream workbook and earlier commits that were removed before this single-commit public release. The present CSV can be hashed and used, but those private-history commands do not independently reconstruct its sources from this public checkout. [Input-series provenance](https://github.com/AI-Futures-Project/aifm-public/blob/1c40ecdb246c25980515441a66571931c5604e11/docs/input-series-provenance.md).
7. Numerical clamps such as 10^30 research effort or maximum SD are engineering safeguards. They are not physical bounds or evidence for stopping.

## Translation to the user's common-multiplier model

The user fixes dF/dx=a, a(0)=1, k0=10^-29/FLOP, N=10^120, and the known-law stopping condition k=d ln a/dx=1/(N−x).

One possible mathematical transplant is to retain only the AIFM power relation, identifying its research stock increment with F and S with a:

\[
a(F)=(1+F/F_0)^r,\qquad F_0=r/k_0.
\]

Imposing the user's common multiplier then gives

\[
k(x)=\frac{k_0}{1+(1-r)k_0x/r}.
\]

- If 0<r<1, the exact optimum is x*=r(N−1/k0), essentially fraction r of the cosmic budget.
- If r=1, k stays equal to k0; the optimum is N−1/k0.
- If r>1, the law diverges at x_sing=r/[(r−1)k0]. All central AIFM configurations give about **1.47×10^29 raw FLOPs**. Utility has no finite maximum before this divergence. Marginal returns never decline to 10^-120.

This is not an empirical prediction of an infinite intelligence explosion. It is the mathematical failure of extending that power law without a new limiting mechanism in this toy model. In particular, copying AIFM's fixed-experiment-compute bottleneck into F'=a would contradict the stipulated common multiplier. Conversely, mapping raw x directly to its fixed-resource calendar time would yield a raw power law a∝x^r and stop near [r/(1+r)]N≈.759N; that is another incompatible research-throughput assumption, not corroborating evidence for a stopping distribution.

| AIFM quantity | What it measures | Why it is not automatically the user's a |
|---|---|---|
| S | Training efficiency at an equal capability level | Does not assert equal improvement of inference, research and valuable consumption |
| Task automation efficiency | Coding labor per inference resource | Task-specific and constrained by automation scope/parallelism |
| T | Value of experiments selected/interpreted at a prescribed resource allowance | Skill/quality dimension, not a count of generic useful thoughts per FLOP |
| C_tr, C_exp, C_aut | Hardware capacities and allocation | Exogenous inputs; hardware growth is not a software multiplier |
| A | Maximum research taste under its assumed transform | Caps a research-quality component; it does not cap S or universal efficiency |

Nothing here estimates maximum brain algorithmic efficiency. Human research variability calibrates one local quality axis. It gives neither the compute lower bound for learning nor the minimum inference cost of all valuable tasks. A brain-sized system is an existence proof of some human performance at some cost, not a proof that algorithms are close to optimal. The distinction is already visible inside this model: it allows taste far beyond humans, separates training and inference, and does not constrain software headroom by a neuron count.

The strongest usable update is therefore methodological: the toy forecast should allow substantial headroom beyond human cognition, distinguish common-multiplier assumptions from experiment bottlenecks, and expose uncertainty in saturation shape. The current evidence can inform starting slopes and near-human feedback; it supplies no likelihood over the roughly **91 orders of decline in k** between 10^-29 and 10^-120. A numerical reweighting of the prior forecast still requires explicit model judgment. Treating AIFM's taste cap, model-implied takeoff distribution, or central beta as a posterior over cosmic stopping would falsely add precision.

## Reproduce and inspect

Package folder: `research_oct2026/takeoff/aifm_current/`. Obtain the pinned upstream checkout and dependencies using [the reproduction guide](../REPRODUCE.md) first.

Run from the package root:

```sh
python research_oct2026/takeoff/aifm_current/reproduce.py
```

The environment uses Python 3.13.2, NumPy 2.4.1, SciPy 1.17.0, and PyYAML 6.0.3. The source README recommends Python 3.14; pinned numerical package versions matched and all reproduction checks passed here. The script checks independent human-mean and top/median quadrature constraints, recomputes m/beta, and verifies the training-lag doubling relation. It does not claim to reproduce the full production Monte Carlo or the unrecovered TastEval update.

Outputs are `calibrations.json` (full diagnostics and parameter overrides), `calibrations.csv` (compact results), `headroom_sensitivity.json`, `lag_doubling_check.json`, `provenance.json`, and `reproduce.py`. The model's source and input data must be retrieved into `aifm-public/` at the pinned commit; the full third-party checkout is omitted from this package.
