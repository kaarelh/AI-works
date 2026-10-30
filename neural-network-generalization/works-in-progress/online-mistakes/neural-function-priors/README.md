# Online mistake bounds for Gaussian neural networks and priors preserving their function rankings

[Paper (PDF)](paper.pdf) · [LaTeX source](source/paper.tex) · [verification](verification/README.md)

The circuit result based on fresh uniform ties does not directly transfer to NNBayes. Neural energies can have many distinct values below the target's energy, and equal leading Gaussian rates do not imply equal function probabilities. This paper gives two positive results with their different priors explicit.

**The original Gaussian learner under structured shifts.** Inputs may come from any of `K` fixed distributions, each uniform on an arbitrary subset of the Boolean cube. The subsets may be disjoint; switches or mixture weights may depend on the entire past, with no limit on their number. In the strong-prior, each fixed `gamma>1`, and mean-field tanh regimes, total mistakes are polynomial in input dimension, target complexity, and `K`, independently of learner width, at fixed depth. Expectation and logarithmic-confidence bounds cover posterior sampling, posterior majority, and failures to give the correct label probability strictly greater than `2/3`.

The proof allows arbitrary mass ratios inside a finite relevant function class. Its posterior tail is charged only on first appearances, contributing at most `beta·2^d` over the entire stream. Existing neural estimates permit `beta=2^(-d)` at polynomial cost. Fixed finite pools and nonuniform sources with controlled positive disagreement probabilities also work. The sources themselves must be fixed before the process; an unrestricted adversary cannot introduce a new source for free.

**A changed prior for arbitrary input orders.** Rank the distinct neural functions by their original Gaussian function probability, before observing any labels. Replace the probability of rank `r` by a normalized weight proportional to `1/[r(r+1)]`; average these weights within exact tie groups. Then perform ordinary Bayesian conditioning using this fixed new prior. This preserves every strict ordering and every tie of the Gaussian function prior, while changing its probability ratios.

If `R_f` counts all functions ranked at least as highly as the target, total expected posterior-sampling mistakes are at most `log[R_f(R_f+1)]`. Majority and confidence-failure counts have corresponding deterministic bounds. Existing neural mass and compression estimates give `log R_f=poly(d,C)` at fixed depth in all three regimes, uniformly in every eligible learner width. The construction does not need the target or its complexity as input.

This is a prior on the same neural parameter space, obtained by reweighting each function event while preserving the conditional parameter law inside that event. It is generally **not Gaussian or independent across coordinates**. It is not ordinary temperature adjustment. The transformation is made once before training, not reapplied to the current posterior after each observation. Since function rankings are preserved, function-MAP choices also stay unchanged: the improved guarantee concerns posterior sampling and majority, not selecting one MAP function.

**A closer analogue of uniform minimum-circuit sampling.** Group minimum neural function energies into geometric budgets, then uniformly sample a distinct consistent function from the least nonempty budget. Functions need not have exactly tied energies. At fixed depth, the number and sizes of relevant budgets give a width-independent polynomial mistake bound. This also changes the learner and is not uniform sampling of parameter vectors.

All neural statements retain the global absolute-output-margin support condition and exact noiseless feedback. Strong-prior variance thresholds may depend on width; finite `gamma>1` polynomial degrees may depend on the fixed exponent. Mean field is proved separately. Polynomial depth dependence and removal of global-margin conditioning are not claimed here.

**What remains open:** a width-independent polynomial total-mistake bound for the unchanged large-width Gaussian NNBayes learner on every adaptive input order. Neither the circuit counterexample nor the abstract unequal-energy example is a proved counterexample for that neural learner.

The new results have conventional proofs and independent AI-agent mathematical reviews. They are **not Lean formalized**. Run `bash build.sh` to rebuild the PDF; generated `build/` files are not published.
