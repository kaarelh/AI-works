# A sharp comparator-growth threshold for Gaussian Bayesian ReLU networks

**[Paper (PDF)](paper.pdf) · [Source](source/paper.tex) · [Verification](verification/README.md)**

Authors: ChatGPT-6 Astra, Claude Opus 5.5, Kaarel Hänni, Dmitry Vaintrob. Authors are listed in alphabetical order.

This paper gives matching strict exponent thresholds for a dense Gaussian Bayesian ReLU network to compete in squared loss with the best smaller network. The positive result covers arbitrary bounded labels and ordinary raw-output posterior means. The negative result uses one data law that defeats **every** likelihood temperature, including a temperature chosen after seeing the data.

## Main result

Let `H≥1` be the number of hidden layers and `L=H+1` the depth including the linear readout. Compare with teachers of width at most `n^a` and coefficient bound `n^b`.

| Growth condition | Result |
|---|---|
| `H a + (H+1)b < 1/2` | An explicit likelihood calibration gives a coefficient-one oracle bound at every learner width above the teacher width. At fixed dimension and depth, the excess is `Õ(n^(-(1−2Ha−2(H+1)b)/(H+1)))`. |
| `H a + (H+1)b > 1/2`, with `a>0` | A single law forces excess MSE at least `1/100`, with high probability, simultaneously for every temperature and every learner width above `O(n^a+n log n)`. Its conditional mean is a globally bounded teacher in the comparator class. |

Both directions hold for **actual finite Gaussian posteriors at every canonical exponent `γ≥2`**. With one hidden layer they hold at every `γ≥1`. Corresponding strong-prior results also hold. The equality case remains open.

A separate fixed-width corollary uses a width-4 teacher with coefficient cap `n^b`, where `b>1/(2(H+1))`. Thus the literal width-only oracle guarantee, without coefficient restrictions, fails for this learner family.

With a fixed coefficient cap, the critical width power is `a=1/(2H)`. If width and coefficient cap both grow as `n^a`, it is `a=1/(4H+2)`.

The positive bounds have polynomial dimension dependence. The lower bound uses `d=Θ(log n)`, so “sharp” concerns guarantees uniform over input laws and dimensions; this is not a lower bound at one fixed dimension. The negative law is discrete, lies in the real input cube, and has covariance eigenvalues in `[1/20,1]`.

## Model and proof ideas

Each learner has a specified fully connected architecture with independent centered Gaussian weights, first-layer biases supplied by a constant input, and no internal biases. Teachers with biases at every layer are included by an exact constant-neuron construction that adds one neuron per hidden layer, at unchanged depth and coefficient cap `B≥1`. The Gaussian observation likelihood is calibrated jointly with the prior. There is no distribution over network sizes and no all-input margin conditioning.

Positive homogeneity allows an exact teacher implementation with energy proportional to `m^(2H/(H+1)) B²`, up to the displayed depth and dimension factors. A product-of-layer-norm capacity bound then gives the oracle inequality. A Gaussian comparison distribution around that implementation extends it to finite priors.

For the lower bound, an exact Boolean-coordinate memorizer is cheap in energy, while a narrow bounded tent function supplies an expensive signal. Putting noise and that signal in one distribution forces a tradeoff that no temperature resolves. The posterior-mean argument controls residuals or prediction differences directly.

A further corollary confines all label noise to an input event of any fixed probability `p∈(0,0.9]`. Its Bayes MSE is `p`, and the same all-temperature failure has excess at least `p² exp(−p)/256`. Noisy labels and the difficult signal keep unit amplitude; the difficult signal occupies less input mass as `p` decreases. This is localized regression noise, not independent label flips, and the input-conditioning constant may depend on `p`.

## Scope

These are results for noisy real-valued regression. They do not settle the Boolean-classification depth question. They imply that this unrestricted learner family has no universal sample polynomial jointly in teacher width, teacher depth, and dimension, even with unit-bounded teacher coefficients and data-dependent temperature selection. They do not prove exponential depth dependence at one fixed teacher width.

For multiple hidden layers, the canonical finite interval `1≤γ<2` remains outside these matching results. A mixture of posteriors over temperatures followed by raw averaging is also outside the negative theorem.

The arguments have independent AI-agent mathematical review and reproducible source builds. They are not Lean verified or externally peer reviewed. Run `./build.sh` to rebuild the PDF.
