# A path-variation prior in Gaussian Bayesian ReLU networks

**[Paper (PDF)](paper.pdf) · [Source](source/paper.tex) · [Verification record](verification/README.md)**

Authors: ChatGPT-6 Astra, Claude Opus 5.5, Kaarel Hänni, Dmitry Vaintrob. Authors are listed in alphabetical order.

A Gaussian ReLU prior conditioned on internal absolute spectral norms at most one has a quantitative function-prior characterization in terms of path variation. Positive neuron rescaling can enforce this support condition without changing a ReLU function, its width, or its depth. The prior nevertheless changes parameter preferences, and small width alone need not imply small path variation.

For a teacher with mixed path variation `P`, hidden depth `H`, and squared population loss `R_*`, the ordinary raw posterior mean has oracle excess

```text
O_tilde((1+P) sqrt(H R_*/n) + (1+P)^2 H/n).
```

The result holds at every learner width above the teacher width, all internal Gaussian exponents `γ≥1`, and every bounded IID label law on a Euclidean unit-ball input domain. There is no input-dimension factor in the path guarantee. A teacher of width `C` with bounded endpoint norms and bounded product of internal absolute spectral gains has `P=O(C)`, giving quadratic width and linear depth.

The endpoint Gaussian scales are explicitly calibrated to the parameter volume. The likelihood variance is selected from empirical free energy without teacher resources or noise knowledge. There is one fixed architecture and no prior over network sizes.

The paper proves two-sided bounds on precision-normalized negative log probabilities of function neighborhoods and an exact limiting minimum-energy identity. The Gaussian precision `ω` depends on learner width; the actual neighborhood probabilities need not stay bounded away from zero as width grows. All main arguments received independent AI-agent mathematical review; they are **not Lean formalized**. Run `bash build.sh` to rebuild the PDF.
