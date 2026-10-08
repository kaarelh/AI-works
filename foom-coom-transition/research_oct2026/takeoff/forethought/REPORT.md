# Forethought audit for the foom–coom model

Evidence cutoff: 2 October 2026. Research and numerical reconstruction by GPT-6/Codex. Scope: Forethought methodology, above-brain headroom, relevant public 2026 updates, and explicit translations into the user's model. All new files are confined to this folder.

**Forethought does not establish a low brain-based ceiling, and it does not identify the return of the last useful research FLOP.** Its most useful contribution is a transparent decomposition of near-term research feedback, plus a deliberately speculative headroom calculation. The long-run stopping answer changes radically when its numerical ceiling is interpreted differently. My reproduction matches its near-term probability calculations, but a literal finite-step ceiling stops around 10^54.4 FLOPs while a smooth continuation of the same diminishing-return rule stops around 10^114.1. These are my conditional translations, not Forethought forecasts.

## 1. Source and version inventory

| Primary source | Date/version used | Role |
|---|---|---|
| [Eth & Davidson, Will AI R&D Automation Cause a Software Intelligence Explosion?](https://www.forethought.org/research/will-ai-r-and-d-automation-cause-a-software-intelligence-explosion) | 26 March 2025 | Research-production framework and empirical precursor |
| [Davidson, Hadshar & MacAskill, How Far Can AI Progress Before Hitting Effective Physical Limits?](https://www.forethought.org/research/how-far-can-ai-progress-before-hitting-effective-physical-limits) | 17 March 2025, current public page | Software, chip efficiency, and production headroom |
| [Davidson, Will Compute Bottlenecks Prevent a Software Intelligence Explosion?](https://www.forethought.org/research/will-compute-bottlenecks-prevent-a-software-intelligence-explosion) | 4 April, updated 18 May 2025 | CES objection and explicit judgment about substitutability |
| [Davidson & Houlden, How quick and big would a software intelligence explosion be?](https://www.forethought.org/research/how-quick-and-big-would-a-software-intelligence-explosion-be) | 4 August 2025 | Quantitative simulation, elicited parameters, saturation rule |
| [Public simulator source](https://github.com/thoulden/Accelerated_AI_Progress/tree/a7b1a79d7965aa6b439ecd45c1488d166acb3f96) | Commit a7b1a79d7965aa6b439ecd45c1488d166acb3f96, 15 July 2026 | Python and JavaScript implementation |
| [Ord, The Dynamics of Intelligence Explosions](https://www.forethought.org/research/the-dynamics-of-intelligence-explosions) | 28 August 2026 | Functional-form and generation-time critique |
| [Davidson, Data bottlenecks won’t prevent an intelligence explosion (but they will slow it down)](https://www.forethought.org/research/data-bottlenecks) | 8 September 2026 | Learning, research taste, data coverage, transfer |
| [Chan et al., What if automating AI R&D triggers an intelligence explosion?](https://arxiv.org/abs/2609.36054) | v1, 28 September 2026 | Updated research-return calibration and caveats |
| [Hoffmann et al., Training Compute-Optimal Large Language Models](https://arxiv.org/html/2203.15556) | 2022, eq. 10 | Independent reconstruction of the brain-undertraining analogy |

Downloaded originals, hashes and retrieval metadata are in `sources/download_manifest.json`. Forethought webpages lack a pinned public revision history here, so their dates do not prove every sentence was present on original publication. The current source code commit predates the cutoff. The paper's published forecast should be distinguished from the current website implementation.

## 2. Equations and parameter provenance

I rename Forethought's constant `a` to `A0` to avoid confusing it with the user's efficiency multiplier. The model is

\[
\dot S=A_0 R(L,C)^\lambda S^{1-\beta},\qquad
R(L,C)=(bL)^\alpha(cC)^{1-\alpha},\qquad L=dS.
\]

Here `C` is **experimental compute flow**, held fixed, while `L` is cognitive labor. Thus

\[
g_S\equiv\dot S/S=K C^{\lambda(1-\alpha)}S^{\lambda\alpha-\beta},
\quad p=\lambda\alpha,
\quad r=\lambda\alpha/\beta.
\]

For constant parameters the ratio of consecutive doubling durations is

\[
D(2S)/D(S)=2^{p(1/r-1)}.
\]

These equations are a semi-endogenous production model, not direct fits of a universal autonomous research algorithm. `S` aggregates inference efficiency, capability, and speed in units of equivalent parallel researchers. Training efficiency is one input to that aggregation. The initial empirical anchor was computer-vision training efficiency versus researcher counts: r≈1.4 with a reported 5th–95th range 0.8–2.4. Other domain point estimates were chess 0.8, RL data efficiency 1.6, SAT 3.5, and linear programming 1.1. None measures a 91-order decline in marginal research returns. [Eth & Davidson](https://www.forethought.org/research/will-ai-r-and-d-automation-cause-a-software-intelligence-explosion).

The later model's parameter ledger is:

| Parameter | Distribution | Provenance |
|---|---:|---|
| Initial ASARA software speedup f | log-uniform 2–32; median 8 | Surveys and thought experiments, then judgment |
| r at ASARA | log-uniform 0.4–3.6; median 1.2 | Empirical 1.4 anchor plus subjective adjustments |
| p | log-uniform .15–.6; median .3 | Median alpha=.5, lambda=.6 |
| Remaining progress Y | uniform 6–16; median 11 | Headroom elicitation; not log-uniform |
| Recent S doubling time | 3 months | Training efficiency plus post-training/capability conversion |
| Software share of overall progress | .5 | Conversion assumption |
| Saturation | r decreases linearly in log S, reaching zero at ceiling | Chosen functional form |

The r adjustment chain is approximately 1.4 → 2.8 (capabilities) → 4 (post-training) → 3 (fixed experimental compute) → 1.7 (fixed hardware scale, 9/16 adjustment) → 1.2 (prospective saturation). Median alpha=.5, lambda=.6 implies beta=.25. These are not independent empirical estimates; p and r are sampled independently, and beta is implicit. [Davidson & Houlden](https://www.forethought.org/research/how-quick-and-big-would-a-software-intelligence-explosion-be).

The exact discrete recurrence, following the implementation's update order, is

\[
S_{i+1}=2S_i,\quad t_{i+1}=t_i+D_i,\quad
r_{i+1}=r_i-r_0/M,\quad
D_{i+1}=D_i2^{p(1/r_{i+1}-1)},
\]

where M is doublings to the ceiling. Published pseudocode uses r_i in the last equation instead. For the base Monte Carlo, D0=3/f months and M=8Y. The single-simulation widget instead initializes D0=3/(1+f), producing a 12.5% faster start at f=8. The retraining option also differs between the single and multiple versions: `z/(1+abs(z))` versus `z/abs(1+z)`, z=p(1/r−1). The base reproduction does not use that option. [Pinned single code](https://github.com/thoulden/Accelerated_AI_Progress/blob/a7b1a79d7965aa6b439ecd45c1488d166acb3f96/single_sim.py), [pinned Monte Carlo code](https://github.com/thoulden/Accelerated_AI_Progress/blob/a7b1a79d7965aa6b439ecd45c1488d166acb3f96/multiple_sims.py).

Our seed-20261002, 50,000-draw base replication gives 56.8%, 41.2%, 17.2%, 12.7%, close to the published 57%, 41%, 18%, 12%. The events are respectively 3 years in 12 months, the code's approximately 3-year event in 4 months, 10 years in 12 months, and 10 years in 4 months. The second code event is actually 26 S doublings, or 3.25 years; it uses `floor((4/12)*8*10)`, not exactly 3 years. This small mismatch does not affect the cosmic-tail argument.

## 3. What the headroom numbers mean

The March physical-limits note assumes 10^29 training FLOPs for a hypothetical future system versus 10^24 for human lifetime learning, giving five orders before human parity. It adds 4–10 beyond human learning: total 9–15, midpoint 12. Separately it estimates about 6.5 orders in irreversible-chip FLOP/J (3×10^19 divided by 10^13), approximately 5.5 orders from terrestrial energy/production scaling (100×3000), and another nine from solar-system energy. Reversible computation is explicitly allowed to exceed the irreversible estimate. These are different quantities; hardware and production improvements cannot be added to a software multiplier when the model already fixes an available raw-FLOP budget. [Physical-limits note](https://www.forethought.org/research/how-far-can-ai-progress-before-hitting-effective-physical-limits).

The later ASARA calculation uses 10^28 training FLOPs, estimates 2–6 orders to human learning, and retains 4–10 above it. The factors underlying the above-human estimate are numerical judgments:

| Mechanism | Assumed multiplier range |
|---|---:|
| More compute-optimal learning allocation | 10–100,000 |
| Relevant learning data | 3–10 |
| Better quality data | 3–300 |
| Relax biological algorithm constraints | 3–100 |
| Exploit favorable human variation | 3–10 |
| Better fundamental learning algorithms | 3–30 |
| Better coordination | 3–10 |

Multiplying the low endpoints gives 7,290 (3.86 orders); high endpoints give 9×10^13 (13.95 orders). The authors reduce the upper aggregate to ten orders because of overlap. This is not a confidence interval or physical theorem. Crucially, the article interprets headroom **upward**, as higher capabilities at fixed training compute, rather than **downward**, as lower cost for a fixed human task. [Headroom discussion](https://www.forethought.org/research/how-quick-and-big-would-a-software-intelligence-explosion-be).

### Independent assessment of the brain comparison

The user's skepticism about a low brain ceiling is justified. A brain is an existence proof of one capable system under biological restrictions, not a proof that optimum algorithms are nearby. But the positive claim “many orders above the brain” also needs explicit task units and accounting. The following distinctions matter:

- **Learning efficiency:** FLOPs to learn a specified competence from specified information. Human learning includes embodied data and inherited structure; comparing lifetime FLOPs alone to an AI training run does not equate those starting conditions. Hard-coding knowledge may shift cost into research or preparation rather than eliminate it.
- **Sample efficiency:** required observations, not required FLOPs. Generating synthetic observations can improve real-world sample efficiency while increasing compute. The two efficiencies need not share one factor.
- **Inference efficiency:** FLOPs per successful fixed task. Training savings transfer only through a model of architecture, training allocation, task, and deployment volume. Amortized one-time learning savings cannot automatically multiply every future consumption FLOP.
- **Research taste/capability:** quality of problem selection and invention is not simply researcher count or tokens per second. More inexpensive mediocre attempts may not substitute for a qualitatively better idea. Conversely, a capability breakthrough may change which tasks can be solved at all.
- **Hardware:** neural speed, energy, memory and communication constraints affect physical execution. Faster electronics or improved FLOP/J do not by themselves establish more thought per raw FLOP.

Several items in the factor table can plausibly overlap. Relevant-data filtering and data quality both change the curriculum; coordination can raise research-team productivity without changing individual learning efficiency; biological restrictions partly concern execution hardware. Multiplication therefore should be a scenario construction with dependencies, not a chain of independently established lower bounds. Nor does “at least three” in each judgment establish a theorem that all seven factors multiply.

### Reconstructing the undertraining analogy

Using Hoffmann et al.'s fitted loss

\[
\ell(P,D)=1.69+406.4P^{-.34}+410.7D^{-.28},\quad C=6PD,
\]

the minimum compute achieving an excess loss B is obtained by allocating parameter and data terms in ratio .28/.34. Put P=10^14 and D=10^9 into that **language-model** formula, then optimize P and D at equal loss. My result is Popt=2.55×10^8, Dopt=8.38×10^9, a 46,829-fold compute saving (4.67 orders), close to Forethought's approximately 4.5-order informal calculation. This is an independent alternate-input reconstruction. The accompanying [brain audit](../brain_audit/REPORT.md) recovered the [public Colab notebook](https://colab.research.google.com/drive/1kpl6B9MHkYUwLSSleOk02pAnpSGxE25H) and reproduces its exact 4.46015-order result. That notebook instead infers D=1.6667×10^9 from C=10^24 and P=10^14, and uses Besiroglu replication coefficients. The difference here is due to declared inputs and coefficients, not a failed replication. [Hoffmann et al., equation 10](https://arxiv.org/html/2203.15556#A4.SS2).

Holding P fixed while changing assumed lifetime data counts from 10^8 to 10^12 changes the apparent saving from 5.49 to 2.29 orders. The analogy identifies neither a brain loss function nor a meaningful mapping of sensory events to LM tokens. Its useful content is that severe undertraining can in principle waste large amounts of compute—not that brains actually sit 4.5 orders from an optimum. A future forecasting distribution should not put a sharp cutoff at the upper end of this calculation.

## 4. Experimental compute, substitution and the toy model

Forethought's CES diagnostic writes

\[
Y=[\alpha K^\rho+(1-\alpha)L^\rho]^{1/\rho}.
\]

With alpha=.5, K=1, rho<0, the maximum as L tends to infinity is .5^(1/rho): 2 at rho=−1, 5.66 at −.4, 32 at −.2, 101.6 at −.15, and 1024 at −.1. Davidson's suggested range −.2<rho<0 is a judgment informed by alternate research methods, better experiments, and smarter/faster labor—not an estimate from a frontier-lab experiment. A cap on research **speed at fixed experimental compute** is not a cap on attainable software. [Compute-bottleneck note](https://www.forethought.org/research/will-compute-bottlenecks-prevent-a-software-intelligence-explosion).

In the user's model there is no separately fixed experimental-compute factor: raw research spending is x, effective research is F, and dF/dx=a. Importing the CES bottleneck unchanged would add a third input and change the problem. If experiments and researcher cognition both benefit from the same a, the original Cobb–Douglas research aggregate scales as a, and its lambda power scales as a^lambda, rather than a^(alpha lambda). That suggests a feedback exponent .6 rather than .3 under the median parameters, **if** all other analogies are retained. It does not justify refitting beta to an unrelated unit.

Additionally, calendar feedback lags do not automatically alter the undiscounted FLOP allocation. A delay with no additional operation cost changes calendar time, but not U=a(N−x). A delay requiring extra computation must be charged to x; one requiring an external deadline changes the stated toy assumptions.

## 5. An explicit continuous translation and its limits

This section is **our new model judgment**, not a published empirical conclusion. Identify S with the common multiplier a, normalize a(0)=1, set k0=10^−29 per raw FLOP, and let H be a chosen headroom. Holding raw compute flow fixed allows doubling-time ratios to be interpreted as reciprocal raw-input growth rates. Extend the discrete recurrence smoothly by

\[
\frac{d\ln D}{d\ln a}=p\left(\frac1{r(a)}-1\right),\qquad
r(a)=r_0\left(1-\frac{\ln a}{\ln H}\right).
\]

Writing h=ln H, z=1−ln(a)/h, and nu=ph/r0 gives the exact integrated law

\[
k(a)=\frac{d\ln a}{dx}=k_0a^p z^\nu.
\]

This is an integration of the varying doubling-time rule. Simply substituting a varying beta into the original constant-parameter power law would be a different model. Near H,

\[
\frac{dz}{dF}=-\frac{k_0}{h}a^{p-1}z^\nu.
\]

Therefore, for nu>1, both z and the inverse-efficiency gap 1/a−1/H eventually decline as F^(−1/(nu−1)). For nu=1 the approach is exponential in F; for nu<1 it reaches the cap in finite F under this law. This provides a transparent mapping to the previous report's cost-gap families; **Forethought's p is not that report's gap exponent**.

At median source parameters Y=11, p=.3, r0=1.2, the simulator's software ceiling is

\[
H_S=2^{8Y}=256^{11}=10^{26.4906},
\]

because S doubles four times/year and software accounts for half of historical overall progress. It is not 10^11. This gives nu=15.2492 and cost-gap exponent .07018.

I evaluate raw expenditure without subtracting nearly equal floating-point numbers. With w=−ln z,

\[
x(w)=\frac{h}{k_0}\int_0^w
 \exp\{-ph(1-e^{-v})+(\nu-1)v\}\,dv,
\]

\[
\ln(k/k_0)=ph(1-e^{-w})-\nu w.
\]

The solver imposes k(x)(N−x)=1, N=10^120, in logarithmic arithmetic. Independent positive-term series integration agrees with quadrature to below 3×10^−14 in ln x on the tested grid. Results:

| Explicit scenario | log10 x* | x*/N |
|---|---:|---:|
| S=a, Y=6, p=.3, r0=1.2 | 109.196 | 1.57×10^−11 |
| S=a, Y=11, p=.3, r0=1.2 | **114.143** | 1.39×10^−6 |
| S=a, Y=16, p=.3, r0=1.2 | 115.998 | 9.96×10^−5 |
| S=a, Y=11, p=.15, r0=1.2 | 108.508 | 3.22×10^−12 |
| S=a, Y=11, p=.6, r0=1.2 | 116.811 | .000647 |
| S=a, Y=11, p=.3, r0=.4 | 117.970 | .00934 |
| S=a, Y=11, p=.3, r0=3.6 | 101.708 | 5.11×10^−19 |
| Source-range extreme Y=16, p=.6, r0=.4 | 118.979 | **.0953** |

At the final extreme, stopping at k=1/N would instead use about .1052N (log10 x=119.022). The exact opportunity cost is material there. The table is a sensitivity grid, not a posterior distribution.

A common units error would replace H by 10^11 while leaving p=.3 and r0=1.2, obtaining log10 x*=105.784. That is a **different law**, not just a unit conversion. For a proper power-coordinate conversion a=S^eta, eta=ln(10)/(8 ln2)=.41524, the exponent changes to p/eta=.72247 and nu stays 15.249. After resetting the starting rate to the same k0, that calculation gives log10 x*=113.761. Even this does not prove effective training compute equals the user's universal multiplier; it merely makes the coordinate conversion honest.

If both experiments and labor receive a, preserve the original fishing-out schedule nu but replace the a^.3 factor by a^.6. This illustrative variant gives log10 x*=113.622. Its similarity to the previous result reflects a shared imposed tail exponent. It is not evidence that experiment bottlenecks are irrelevant in reality.

The chosen k0 also needs care: the original source starts at a future automation milestone, while the user's k0 is today's calibration. Resetting both models to the same initial rate isolates their shapes; it is not an empirical calibration of ASARA's marginal productivity.

## 6. A ceiling implementation can dominate the answer

Extend the literal published recurrence beyond its 48/72-month display horizon and normalize the initial raw step to ln(2)/k0. At the median parameters, it reaches its last finite doubling and then hard-stops at H after approximately 10^54.421 FLOPs. All those steps are worth buying given N=10^120. But repeat the same recurrence with smaller fractional doublings and the completion cost changes:

| Step size in software doublings | log10 raw FLOPs to hard cap |
|---|---:|
| 1 | 54.421 |
| .1 | 68.623 |
| .01 | 82.867 |
| .001 | 97.116 |
| Continuous approach, optimal economic stop | **114.143** |

The smooth model never actually reaches H at finite input when nu>1. A coarse recurrence treats the last sizeable jump to H as available at a finite cost; a smaller step discovers ever slower marginal refinements. Near-term curves can be similar while this last-step convention produces many orders of difference in optimal cosmic expenditure.

This is the strongest reason **not** to mechanically read a stopping distribution out of the published simulator. It was designed for a few years of capability progress, not the last 10^−120 proportional gain. Its statement that further progress is impossible at effective limits defines an endpoint; it does not measure the shape with which the real world approaches that endpoint.

## 7. Public updates through the cutoff

Ord's August 2026 analysis makes functional-form dependence explicit. For dA/dt=f(A), finite-time divergence requires the integral of 1/f(A) to infinity to converge. For discrete generations with durations Tn, infinitely many generations require sum(Tn)<infinity; a strictly positive minimum duration rules that out. He separates a lower bound on generation time from an upper bound on capability. Our inference: these results constrain calendar singularity claims, but do not imply any particular tail exponent for d ln(a)/dx under an undiscounted operation budget. [Ord](https://www.forethought.org/research/the-dynamics-of-intelligence-explosions).

Davidson's September 8 note distinguishes data quantity, quality and coverage, and distinguishes automation of AI R&D from deployment in other fields. It expects early AI to have weaker sample efficiency than humans despite matching their aggregate research contribution. New discoveries make inherited human data less relevant; the proposed slowdown is modest, with more than a factor two judged surprising. This is an argument, not a fitted saturation parameter or an upper bound on intelligence. Our inference: its acknowledged heterogeneity is another reason to question identifying research capability and valuable consumption with one empirically measured factor. [Data-bottleneck update](https://www.forethought.org/research/data-bottlenecks).

Chan et al.'s September 28 supplementary calculation uses dA/dt=A^(1−beta)E^lambda and E∝A, explicitly setting compute/data bottlenecks aside. Averages from three Ho–Whitfill subfields give lambda=1.40, beta=1.01. Thus a doubling multiplies the growth rate by 2^.39=1.3104. Starting with a 4.5-month doubling, nine doublings take 17.33 months, reproducing its approximate 17-month calculation. It explicitly flags uncertainty in translating training efficiency into researcher equivalents, scale confounding, omitted post-training, and finite-domain validity. There is no revised measured cosmic ceiling or remote convergence exponent in this update. [September paper, supplement](https://arxiv.org/pdf/2609.36054).

## 8. Implications for the revised forecast

1. **Retire “human efficiency implies little remaining headroom” as an evidential argument.** Forethought explicitly includes multiple orders beyond humans. However, its numerical range remains an elicitation with uncertain conversion and overlaps; it should widen the considered headroom scenarios, not establish a replacement hard ceiling.
2. **Do not interpret H≤10^12 as a literature-established upper bound on the common multiplier.** The old prior cuts off around the March note's midpoint, while later headroom is 6–16 orders in a different training metric and 14–39 orders in the simulator's labor-equivalent metric. Larger H is reasonable to include, but exact probabilities remain judgment.
3. **Separate source evidence from the extrapolation prior.** Historical research-return estimates bear on early SIE acceleration. The decline of r to zero, the translation of S into a, the final-step rule, and the extension for 91 orders of marginal-return decline are additional assumptions. A mixture weight for the continuous scenario above should be labeled a model judgment.
4. **Retain substantial tail uncertainty even after choosing a ceiling.** The finite-step/smooth contrast gives a reproducible demonstration: approximately 10^54 versus 10^114 at the same nominal source medians. A definite median near 10^110 can remain a stated judgment, but these methodologies do not empirically select it.
5. **A practical appendix should teach the measurement operation.** Fit performance versus training/inference compute; estimate research-input growth separately; distinguish flow from cumulative input and capability from fixed-task efficiency; then show every translation and stopping law. Forethought is particularly useful as a worked example of that distinction.

## Reproduce

From the project root:

```sh
python research_oct2026/takeoff/forethought/reproduce.py
```

Dependencies: Python, numpy, scipy. This reads no external input and recreates `results.json`. `reproduce.py` contains deterministic arithmetic, the base Monte Carlo, a stable exact stopping solver with an independent series check, step-resolution sensitivities, and the Chinchilla analogy. `source_crosscheck.js` provides an additional independent execution check against the archived official JavaScript: 81 parameter combinations matched with zero relative discrepancy. Run it with Node.js; it recreates `source_crosscheck.json`.
