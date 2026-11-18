# Depth bounds for finite Gaussian Bayesian learning

[Paper](paper.pdf) · [LaTeX source](source/paper.tex) · [Verification record](verification/)

For tanh networks with raw Gaussian likelihood, exponentially many samples in hidden depth suffice to compete with a bounded-width, bounded-weight comparison network. This holds at every learner width above the comparison width and every prior scale `0 < tau <= 1`, including canonical mean field. The labels may have any bounded IID noise or approximation error. The conclusion covers posterior-average squared risk and the ordinary raw posterior mean.

A second theorem gives the same depth bound for ReLU hidden layers with a bounded final readout, such as clipping or tanh, used in both likelihood and prediction. All results use one fixed dense Gaussian prior at each width, without a robustness restriction or a mixture over architectures.

For comparison width `C`, coefficient cap `B`, accuracy and confidence held fixed, the sufficient sample counts are:

| Prior scales and activations | Dependence on input dimension `d` and hidden depth `H` |
| --- | --- |
| Every `gamma >= 1`; bounded Lipschitz hidden activation with `phi(0)=0`, raw outputs | `exp(O(H))` at fixed `d` |
| Every `gamma >= 1`; ReLU hidden layers and a bounded Lipschitz final readout in both likelihood and prediction | `exp(O(H))` at fixed `d` |
| Every fixed `gamma > 1`; bounded Lipschitz hidden activation, allowing `phi(0) != 0`, raw outputs | `exp(O(H))` at fixed `d` |
| Same strictly-above-mean-field case; first-layer comparison rows have bounded Euclidean norm | `exp(O(H))`, uniformly for `d <= H` |
| All `gamma >= 1`; any bounded Lipschitz hidden activation, raw outputs | `(d+H+2)^(O((d+1)H))` |
| All `gamma >= 1`; bounded twice differentiable hidden activation with bounded second derivative, raw outputs | `(d+H+2)^(O(H^2))` |

The rows covering all `gamma >= 1` in fact cover every scale `0 < tau <= 1`, beyond fixed power laws. The last two bounds remain useful without the centering assumption, and the last is polynomial in dimension at every fixed depth. The paper also gives a raw-output exponential-depth bound for noncentered bounded activations under the depth-dependent scale restriction `tau^2 <= 1/H`.

These are upper bounds at fixed comparison resources. They do not give polynomial dependence on depth. The likelihood calibration depends on the requested accuracy and, in the exponential-depth theorems, on which side of an explicit width threshold the learner lies. The ReLU theorem concerns the mean of the bounded final outputs; it does not claim a bound for raw-output prediction or a raw-output likelihood.

The tanh construction uses geometrically increasing groups of active clones. Only first-layer Gaussian noise is suppressed; the normalized relative-entropy cost is linear in depth. At smaller learner widths, a finite parameter cover suffices. For ReLU, positive homogeneity instead allows a translated full Gaussian prior to approximate the comparison network at large width without shrinking its noise. A bound on the sum of layer operator energies controls both spatial covers. The growing-dimension extension uses a separate spectral argument.

Authors: ChatGPT-6 Astra, Claude Opus 5.5, Kaarel Hänni, and Dmitry Vaintrob, in alphabetical order. The conventional proofs have undergone an independent AI-agent mathematical review; they have not been formalized in Lean. The verification directory records the reviewed sources and precise scope.

To rebuild, run `bash build.sh` from this directory or with its absolute path. A TeX installation with `pdflatex` is required.
