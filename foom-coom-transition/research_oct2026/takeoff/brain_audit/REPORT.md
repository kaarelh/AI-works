# Human-brain efficiency is evidence of possibilities, not a low universal ceiling

Independent research audit, 2 October 2026. All calculations below distinguish observations, source judgments, and this audit's conditional extrapolations. Scope: the common-multiplier model with raw research expenditure x, effective research F, dF/dx=a, N=10^120 raw FLOPs, and current k0=10^-29 per FLOP.

The brain does **not** provide an empirically established low ceiling on a universal efficiency multiplier. It provides evidence that certain capabilities are achievable with particular resources, while leaving the best achievable resource requirements unknown. There are credible routes to substantial improvement above biological cognition; their combined magnitude and rate of discovery are poorly measured. Forethought's large numbers above human efficiency are structured judgments, not established physical bounds. None of the brain evidence identifies the tail needed to decide when k=d ln a/dx falls from 10^-29 to roughly 10^-120.

## 1. The direction of the bound matters

Fix a task distribution, performance level, inference protocol, and machine model. Let c_now be the cost of the present implementation and c_min the minimum possible cost. Maximum speedup is H=c_now/c_min. A demonstration that a brain-like implementation works at cost c_brain establishes c_min <= c_brain and therefore H >= c_now/c_brain. It supplies a **lower bound on possible improvement**, conditional on reproducing that implementation. An upper bound on H requires a lower bound on c_min. Merely observing a relatively efficient brain does not supply one.

Carlsmith's primary investigation explicitly estimates *sufficient* compute for brain-level task performance, not minimum possible compute. His mechanistic estimates regard 10^13–10^17 FLOP/s as plausible, with a roughly 10^15 FLOP/s median for one model class and less than 10% subjective probability of requiring above 10^21. These are expert-informed judgments about models, not directly measured brain FLOPs. His discussion also separates runtime requirements from the difficulty of creating the software. [Carlsmith, 2020](https://coefficientgiving.org/research/how-much-computational-power-does-it-take-to-match-the-human-brain/).

Independent arithmetic: thirty years at 10^13, 10^15, or 10^17 FLOP/s is 9.47×10^21, 9.47×10^23, or 9.47×10^25 FLOP equivalents. A hypothetical 10^29-FLOP training run divided by these totals gives gaps of 7.02, 5.02, or 3.02 OOM. This ratio alone is not a matched-performance efficiency comparison. The reference model might have different breadth, expertise, memory, or runtime compute; the brain's evolutionary and cultural preparation is also not included.

## 2. What Forethought's headroom numbers actually are

The current physical-limits page estimates approximately 12 OOM of software headroom: a hypothetical 5-OOM training gap to human learning plus a judgmental 4–10 OOM beyond humans. The page is dated March 2025; its content was checked on 2 October 2026. [Forethought physical limits](https://www.forethought.org/research/how-far-can-ai-progress-before-hitting-effective-physical-limits).

The detailed software-explosion paper uses 2–6 OOM between its ASARA milestone and human learning, then 4–10 beyond humans. Its component judgments are:

| Proposed improvement above human learning | Assumed factor |
|---|---:|
| Different parameter/data allocation | 10–100,000 |
| More task-relevant experience | 3–10 |
| Better data quality | 3–300 |
| Relax biological implementation constraints | 3–100 |
| Extend within-human variation | 3–10 |
| Improve the learning algorithm | 3–30 |
| Improve coordination | 3–10 |

The authors reduce their combined upper estimate because of possible overlap. They interpret the resulting headroom mainly as equivalent training-compute gains *upward* toward greater capabilities at fixed compute, rather than cost reductions at a fixed capability. [Forethought, Davidson and Houlden](https://www.forethought.org/research/how-quick-and-big-would-a-software-intelligence-explosion-be).

Assessment: these are sensible hypotheses to investigate, but the endpoints are not separately measured efficiency factors, independent random variables, confidence intervals, or demonstrated hard limits. Task-relevance and coordination improvements particularly need a task-specific accounting. Spending less time learning poetry may improve an AI-research specialist without supplying the same gain to a consumer who values poetry. Multiplying every row into the user's common a would assume exactly the generality that needs justification.

## 3. Reproducing the undertraining calculation

The linked [public notebook](https://colab.research.google.com/drive/1kpl6B9MHkYUwLSSleOk02pAnpSGxE25H), attributed to Tamay Besiroglu and lightly edited by Tom Davidson, was downloaded intact. It sets P=10^14 putative brain parameters, C=10^24 training FLOPs, and D=C/(6P)=1.6667×10^9 putative data points. It searches for the minimum 6PD attaining the same fitted language-model loss. The notebook uses the Besiroglu replication coefficients, not the original rounded Hoffmann coefficients.

The underlying empirical work is language-model scaling. Hoffmann et al. trained over 400 transformers across parameter counts and token budgets, then fit loss as E+A/P^alpha+B/D^beta and approximated training cost by 6PD. Their result concerned transformer training, not human brains. [Hoffmann et al., 2022, equations 2–4 and appendix D](https://arxiv.org/html/2203.15556v1).

Besiroglu et al. reconstructed 240 data points from the published figure and refit that law. Their coefficients are E=1.8172, A=482.01, B=2085.43, alpha=0.3478, beta=0.3658. [Besiroglu et al., 2024, table 1](https://arxiv.org/html/2404.10102v2).

Here is an independent analytic reproduction. Define the target excess loss ell=L−E and u=A/P^alpha, v=B/D^beta. Minimizing ln P+ln D subject to u+v=ell gives alpha*u=beta*v. Therefore

    P* = [A(alpha+beta)/(beta*ell)]^(1/alpha)
    D* = [B(alpha+beta)/(alpha*ell)]^(1/beta).

The result is P*=4.9581×10^8, D*=1.1652×10^10, C*=3.4662×10^19. That is a 28,849.98-fold training-compute reduction, or **4.46015 OOM**. The independent 300-point grid reproduces the notebook within 0.001 OOM. Using the original rounded Hoffmann fit gives 4.49028 OOM; the more precise original coefficients reported in the replication give 4.35533. Thus coefficient choice is not the main uncertainty for this particular extrapolation.

Three different questions should not be confused:

| Optimization question, using the notebook analogy | Result |
|---|---|
| Same predicted loss, minimize training compute | ~7× more data, ~201,690× fewer parameters, ~28,850× less training compute |
| Same 10^24 compute budget, minimize predicted loss | P*=9.586×10^10, D*=1.739×10^12; ~1,043× more data |
| Keep 10^14 parameters, use the rough 20-tokens-per-parameter heuristic | 2×10^15 data points; ~1.2 million times the original data and compute |

The same-loss result is not a claim that an unchanged human brain needs 29,000 times more experience. It replaces the brain with a vastly smaller hypothetical model. Nor does 29,000-fold cheaper *training* imply the same runtime or research-productivity gain.

The analogy's decisive assumptions remain unvalidated:

1. A synapse counts as a trainable dense-transformer parameter, despite different dynamics, sparsity, reuse, and learning rules.
2. A human experience “data point” is commensurate with a language-model token. A second of multisensory experience is not intrinsically one token.
3. Brain-level performance can be represented by the loss predicted by an extrapolated text-model law at the chosen P,D.
4. Lifetime cognitive operation counts obey the dense training identity C=6PD. In the notebook D is *inferred* from this identity, rather than independently measured.
5. The computation that makes a particular lifetime learner possible is available without charging its discovery cost. That is reasonable for some steady-state comparisons, but does not price the research needed to obtain it.

The provided sensitivity table varies the analogical quantities, not measured neurological parameters. For P=10^14, changing D produces:

| Putative lifetime data points D | Conditional same-loss saving, OOM |
|---:|---:|
| 10^7 | 6.782 |
| 10^9 | 4.690 |
| 10^11 | 2.651 |
| 10^13 | 0.867 |
| 10^15 | 0.0026 |

In this table C changes consistently as 6PD. It must not be read as holding the independently specified brain-compute budget fixed. It shows why tokenization and accounting choices can dominate the result.

## 4. Weight sharing does not establish a large universal penalty

The cited Ott et al. paper calls exact spatial weight sharing biologically implausible, then finds that Free Convolutional Networks without imposed sharing can match standard architectures when trained on appropriately translated data. The networks learn approximately shared representations. [Ott et al., 2019/2020](https://arxiv.org/abs/1909.11483).

This supports a difference in available implementation strategies, but not a measured fixed multiplier for brain inefficiency. Exact sharing can reduce parameter storage and impose a useful inductive bias; a convolution still applies its filter at each location, so parameter-count savings do not automatically equal inference-FLOP savings. Spatial sharing across different physical synapses also differs from repeatedly using the same biological circuit through time. The strong categorical statement that brains cannot implement weight sharing needs these qualifications.

## 5. Keep five comparisons separate

| Quantity | Relevant experiment | What it does not identify |
|---|---|---|
| Sample efficiency | Matched task performance versus fresh examples or interactions | Total training FLOPs, or inference FLOPs |
| Training efficiency | Minimum total training compute to a fixed target, charging relevant data/teacher compute | Runtime cost after training, or universal quality |
| Inference efficiency | Compute per successful output at fixed accuracy, context, latency, and task mix | Cost to discover or train the implementation |
| Research taste | Progress from a fixed experimental budget, with labor skill and time controlled | Equivalent benefit to consumption, or all computational tasks |
| Hardware efficiency | Useful operations or benchmark output per joule, at specified hardware/precision | Algorithmic output per already-counted raw FLOP |

Empirical language/brain comparisons also illustrate endpoint dependence. One study found GPT-2 models trained on developmentally plausible amounts of text achieved nearly maximal prediction of an fMRI sentence-response benchmark. That does not show that those models equal humans across language tasks; equally, a model's much larger full training corpus does not establish the ratio needed for that narrow neural-prediction endpoint. [Hosseini et al., 2024](https://doi.org/10.1162/nol_a_00137).

Evolutionary preparation complicates lifetime comparisons. Zador argues that structured innate connectivity supplies inductive biases and that biological learning cannot simply be compared with a tabula-rasa model trained from scratch. This is a methodological argument, not a quantitative correction factor. [Zador, 2019](https://www.nature.com/articles/s41467-019-11786-6). Discovery and cultural preparation can be sunk costs for deployment while still mattering to a forecast of how much research is needed to discover better algorithms.

AI2027's original research-taste discussion uses a small elicitation: replacing median lab researchers with the best was assigned a median 6.5× overall progress gain, or 3.25× when focusing on taste. Its extrapolation beyond the human range is judgmental. [AI2027 takeoff forecast](https://ai-2027.com/research/takeoff-forecast). This is relevant evidence about research production, but not a biological or information-theoretic ceiling. A cross-sectional labor-quality difference does not determine the slope of future algorithmic discovery.

## 6. Hardware and thermodynamics

Levy and Calvert's energy-accounting model assigns about 0.1 W of ATP consumption to cortical computation and 3.5 W to long-distance communication, versus the commonly cited 20-W glucose budget of the brain. Their specific biological-versus-ideal computational-efficiency comparison differs by 10^8. These quantities depend on how neural computation is defined and are not a measured 10^8-fold software opportunity. [Levy and Calvert, 2021](https://arxiv.org/abs/2102.06273).

Independent arithmetic for irreversible bit erasure at 300 K gives k_B T ln 2 = 2.871×10^-21 J per bit, or 3.48×10^20 bit erasures/J. Turning that into FLOPs/J requires an operation/precision/erasure mapping. Reversible computation further changes the relationship. Fundamental computing limits constrain rates and storage; they do not directly specify valuable output per operation. [Lloyd, 2000](https://arxiv.org/abs/quant-ph/9908043).

For the user's stipulated budget, an additional FLOPs/J improvement ordinarily increases the amount of raw compute that an energy endowment can buy. It should not also multiply a after N has already been stipulated in raw FLOPs. A fixed-raw-FLOP software scenario must account for this separately to avoid double counting hardware progress.

## 7. Implication for a 10^-120 marginal threshold

When dF/dx=a, the chain rule gives

    k(x) = d ln a/dx = da/dF.

Brain comparisons concern candidate levels of a, or the cost of specific capabilities. The stopping condition concerns a *derivative with respect to cumulative research*. Neither a large nor a small headroom estimate fixes that derivative's very remote tail. With k0=10^-29, the target requires approximately **91 orders of decline** in this marginal quantity when x is small relative to N.

As an independent arithmetic check, take identical a(0)=1, identical k0, and identical ceiling H=10^12. The following illustrative, unfitted raw-return laws all integrate to ln H:

    Exponential: k(x)=k0 exp(−x/tau), tau=ln(H)/k0.
    Power tail:  k(x)=k0(1+x/tau)^−q, tau=(q−1)ln(H)/k0, q>1.

Each is consistent with the common-multiplier premise: define a(x)=exp(integral k dx), then F(x)=integral a dx and invert the increasing F. Because k decreases, the known-law optimum is unique. Solving the exact condition k(x)=1/(N−x) yields:

| Shape with the same 12-OOM ceiling | log10 optimal raw FLOPs |
|---|---:|
| Exponential | 32.762654 |
| q=2 | 75.941397 |
| q=1.1 | 112.168670 |
| q=1.01 | 118.525732 |

These are **sensitivity examples, not Forethought predictions or prior probabilities**. They independently agree with the parent audit's calculation. The last row spends approximately 3.36% of N, so using 10^-120 instead of the exact stopping threshold makes a discernible difference.

Even assuming monotone decreasing k and finite H gives only x*/N <= ln H/(1+ln H). At H=10^12 this bound is approximately 0.965. It cannot justify stopping many orders below the cosmic budget.

The forecast should therefore treat human efficiency as an uncertain reference point, remove any brain-derived hard cap on universal a, and keep explicitly judgmental headroom scenarios separate from tail-shape scenarios. This audit supplies no defensible probability weights for those scenarios and no new empirical median stopping expenditure.

## Reproducibility and provenance

Run from any directory:

    python3 research_oct2026/takeoff/brain_audit/reproduce.py

The program uses Python's standard library. It generates `results.json` and `undertraining_sensitivity.csv`; checks loss matching, the first-order condition, and agreement with the notebook's grid search; and independently solves the illustrative stopping equations. `sources/forethought_undertraining.ipynb` is the intact public notebook; `sources/forethought_undertraining.py` extracts only its code. The notebook SHA256 is `2948bd4e347fd3862ea1b458dc6089822efdaaabceb656e21a7c130a628445e6`. The source notebook itself was not executed; its calculation was independently reimplemented.

This audit read the earlier ceiling and human-calibration memos without modifying them. No outputs were written outside the assigned `research_oct2026/takeoff/brain_audit/` directory.
