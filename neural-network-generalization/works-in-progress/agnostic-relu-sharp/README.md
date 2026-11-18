# A sharp comparator-growth threshold for Gaussian Bayesian ReLU networks

**[Paper (PDF)](paper.pdf) · [Source](source/paper.tex) · [Verification](verification/README.md)**

Authors: ChatGPT-6 Astra, Claude Opus 5.5, Kaarel Hänni, Dmitry Vaintrob. Authors are listed in alphabetical order.

A Bayesian ReLU network with a fixed dense Gaussian architecture can compete in squared loss with smaller approximating networks, but the allowed growth of their width and weights has a sharp boundary in substantial prior regimes. Above that boundary, one noisy distribution defeats every likelihood temperature and even arbitrary data-dependent mixtures of temperatures, prior scales, and sufficiently large learner widths.

## The threshold

Let `H≥1` count hidden layers, with total depth `L=H+1` including the linear readout. Compare with teachers of width `n^a` and coefficient cap `n^b`.

| Comparison class | Result |
|---|---|
| `H a + (H+1)b < 1/2` | An explicit likelihood calibration gives a coefficient-one oracle bound for the ordinary raw posterior mean, with excess `Õ(n^(-(1−2Ha−2(H+1)b)/(H+1)))`. This holds at every eligible width for actual finite `γ≥2`, and at every `γ≥1` with one hidden layer. A strong-prior version also holds. |
| `H a + (H+1)b > 1/2`, `a>0` | One law forces positive constant excess for **every mixture** of the allowed raw posterior means. The conclusion is simultaneous for all widths above `O(n^a+n log n)`, every finite prior base variance `0<σ²≤1/N`, and every positive likelihood temperature. |

The negative scale range includes all canonical exponents `γ≥1` and any additional stronger prefactor. It requires no width or prior-strength limit. The mixture may depend on the training sample, validation data, or the data law. It may also contain components whose raw posterior means are clipped to `[-1,1]` before mixing. Clipping only after mixing, and averaging clipped posterior draws, are distinct conventions; the mixture theorem does not cover those. Individual posteriors satisfy stronger constant lower bounds for those clipped-draw conventions too.

At a fixed coefficient cap the critical width exponent is `a=1/(2H)`. If width and cap both grow as `n^a`, it is `a=1/(4H+2)`. Equality remains open. For multiple hidden layers, the matching positive boundary at finite `1≤γ<2` remains open; weaker positive results throughout that interval are available in the [joint activation paper](../agnostic-lipschitz-oracles/).

The positive bounds have polynomial dimension dependence. The lower bound uses `d=ceil(log2 n)+2`, and therefore concerns a guarantee uniform over dimensions and input laws, rather than a lower bound at one fixed dimension. Input covariance eigenvalues lie between `1/20` and one.

## What the lower bound rules out

The counterexample's conditional mean is exactly a globally bounded small ReLU teacher. At every sufficiently large integer sample count, its Bayes squared risk is `9/10`, and every allowed mixture has excess at least `1/300000` with probability tending to one. A separate variant confines label noise to any fixed input mass `p∈(0,9/10]`, with Bayes risk `p` and mixture excess at least `p³ exp(−2p)/600000`. This is localized regression noise, not independent Boolean label flips.

A width-four teacher already suffices if its coefficient cap grows as `n^b` with `b>1/(2(H+1))`. Thus width alone cannot support a distribution-uniform oracle guarantee for this learner family. With unit-bounded coefficients, the growing-width result rules out one sample polynomial jointly in teacher width, depth, and input dimension, even when prior scale and temperature are selected or mixed after seeing the data. It does not establish an exponential-depth lower bound at one fixed teacher width or settle the Boolean-classification depth question.

## Model and proof

The prior has independent Gaussian coordinates with variances `Nσ²/d`, `σ²`, and `σ²/N` in the first layer, internal layers, and readout. The likelihood has observation variance `nλσ²` and uses raw squared error. Internal layers have no biases; a constant input supplies first-layer biases. Ordinary biased comparison MLPs compile exactly using one extra constant neuron per hidden layer, at unchanged depth and coefficient cap. No distribution over architectures is used in the positive results.

Positive homogeneity gives a balanced teacher implementation with energy proportional to `m^(2H/(H+1)) B²`. A norm-capacity estimate and a Gaussian comparison law give the positive result.

The negative construction combines a steep bounded tent signal with a cheap noisy component. Its memorizer has many first-layer features but only two active neurons in each later hidden layer. Narrowing Gaussian noise only in rows entering those active neurons controls approximation error at a cost independent of learner width; the rest of the dense Gaussian network remains present. This gives the full finite mean-field-or-stronger scale range at width `O(n log n)`.

For mixtures, the key identity is specific to the Gaussian readout and likelihood. If `y` is the training-label vector and `f` the raw posterior mean's training predictions, then `y·f≥||f||²`. Empirical failure against the conditional mean therefore gives a common linear population witness for all temperatures and scales. Averaging cannot cancel that witness.

These are information-theoretic results for exact inference. They do not supply an efficient sampler. The papers have conventional mathematical proofs and independent AI-agent checks; they are not Lean verified or externally peer reviewed. Run `./build.sh` for a clean three-pass PDF build.
