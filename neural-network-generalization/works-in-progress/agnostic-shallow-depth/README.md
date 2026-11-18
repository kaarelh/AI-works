# Shallow comparison oracles for deep Bayesian networks

[Paper](paper.pdf) · [LaTeX source](source/paper.tex) · [Verification record](verification/)

At **every learner depth and every realizable learner width**, a finite Bayesian tanh network with Gaussian or suitable smooth non-Gaussian independent weights can compete with a shallow comparison network using a sample count polynomial in comparison width. At canonical mean field, the dependence on learner depth is `exp(O(sqrt(H)))`.

Fix input dimension, a bound on the comparison coefficients, accuracy, and confidence. For shallow comparison width `C`, learner hidden depth `H`, and prior variance prefactor `0 < nu <= 1`, the sufficient sample bound is

```text
n >= (2+C)^c * exp(c*(sqrt(H) + (1-nu)*H)).
```

It holds for **all `H >= 1` and all learner widths `N >= C`**, with the specified Gaussian-likelihood calibration. There is no additional bound on the comparison function's output independent of `C`. The conclusion has leading coefficient one on the best comparison risk and bounds both posterior-average squared risk and the ordinary raw posterior mean.

The Gaussian theorem extends to any fixed standardized smooth strongly log-concave coordinate density `p(x) ∝ exp(-V(x))` with `0 < m <= V''(x) <= M < infinity`. Each coordinate is an independent copy of this one law, scaled by its layer standard deviation. The law may be asymmetric. The extension keeps the actual non-Gaussian prior, raw likelihood, and raw prediction rule. A further corollary covers any fixed standardized finite Gaussian mixture with common positive component variance, including strongly bimodal non-log-concave laws. These are mixtures for each scalar weight coordinate, not mixtures over architectures.

The prior variances are `nu/d` in the first layer, `nu/N` internally, and `nu/N^2` in the readout. Thus `nu=1` is canonical mean field. The depth factor remains `exp(O(sqrt(H)))` when `1-nu=O(1/sqrt(H))`; a fixed smaller prefactor gives an exponential depth factor. The prior has no robustness restriction and no mixture over architectures.

Inputs have any distribution on the unit sphere. Labels may have any bounded IID distribution, including approximation error and label noise. A corollary allows a fixed sub-Gaussian label envelope, including Gaussian noise. It retains the actual labels, raw Gaussian likelihood, and raw prediction rule.

A further corollary chooses the eligible comparison-width cap directly from sample count and known model quantities. This gives one calibrated learner competing with width `poly(n)` shallow networks at fixed dimension and depth, until that cap reaches the learner width. It changes only the likelihood calibration; it introduces no prior over network sizes.

For Gaussian weights, a separate dimension-explicit corollary fixes comparison width and a Euclidean norm bound on each comparison row. For `1 <= d <= H`, it gives sufficient sample count `exp(A*d*(sqrt(H)+(1-nu)*H))`, with `A` independent of `d,H,nu`. This does not match a varying-dimension `exp(Omega(sqrt(H)))` lower: when `d` is of order `sqrt(H)`, the displayed continuous-domain upper is `exp(O(H))`.

The polynomial degree and constants depend on input dimension, coefficient cap, accuracy, and confidence. This is **not** a bound polynomial jointly in all those resources, and its comparison networks have one hidden layer. It complements the dimension-polynomial oracle bounds for more general comparison MLPs.

The proof combines a Gaussian Jacobian-moment estimate with a covariance construction that carries a weak feature through many layers and then amplifies it. Large teacher outputs need only be attenuated toward zero to obtain a squared-loss comparison. A global nonexpansive state map controls finite-width errors. Stronger short-depth gains, a same-width relay construction, and finite parameter covers handle the remaining depth and width ranges.

The non-Gaussian extension uses rank-one transports with controlled relative entropy, a conditional central limit estimate along delocalized directions, and matrix moments that retain the exact isotropic baseline. Gaussian features appear only in a comparison law used in the proof.

Authors: ChatGPT-6 Astra, Claude Opus 5.5, Kaarel Hänni, and Dmitry Vaintrob, in alphabetical order. The proofs have undergone independent AI-agent mathematical review; they have not been formalized in Lean. The verification directory records the exact reviewed sources and scope.

Run `bash build.sh` to rebuild the PDF with `pdflatex`.
