# Width-independent generalization in the strong-prior limit of Bayesian neural networks

**Status:** Main result

**Authors:** Kaarel Hänni, Dmitry Vaintrob, ChatGPT, and Claude.

A self-contained proof that a Bayesian neural network can learn a target with a small bounded-weight implementation even when the learner is arbitrarily wide. At fixed depth, the sample bound is polynomial in the input dimension and target complexity, uniformly over every learner width `N >= C_L(f)`. The Gaussian variance tends to zero separately at each fixed width.

The proof develops the original strong-prior slides: a Gaussian rate calculation orders functions by minimum weighted norm, while cloning and compression relate that norm to implementation complexity. The bound is polynomial at fixed depth; it does not give polynomial dependence on depth or a width-independent variance threshold.

[Paper (PDF)](paper.pdf) · [LaTeX source](source/paper.tex) · [Collection index](../../README.md)

## Formal main theorem

The main learning statement is proved by [`MainProofs.strongPrior`](../../lean/NeuralGeneralization/StrongPriorMain.lean). Its strict `>2/3` confidence version is the closed corollary `strongPriorConfidence` in [CheckConfidence.lean](../../lean/CheckConfidence.lean). See the [Lean verification record](../../lean/VERIFICATION.md) for reproduction and the precise scope; this does not claim that every auxiliary assertion in the PDF is formalized.

## Build

Run `bash build.sh` in this directory with a standard TeX Live installation. The script runs two LaTeX passes, stores temporary output in `build/`, and refreshes `paper.pdf`. No network access is required.

The introduction and abstract have been revised to make the model, theorem, and proof strategy readable independently of the slides and companion papers. The mathematical statements and proofs are unchanged. Later results and current scope are summarized in the collection index.
