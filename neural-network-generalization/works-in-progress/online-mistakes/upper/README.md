# Polynomially many total mistakes for NNBayes

[Read the paper](paper.pdf) · [LaTeX source](source/paper.tex)

The strong-prior, fixed `gamma > 1`, and mean-field (`gamma = 1`) main learning results extend to **polynomially many mistakes in total** when Boolean inputs arrive uniformly at random. This covers either an infinite iid stream or one uniformly random permutation of the entire cube. Labels are revealed after every prediction, and the learner conditions exactly on them. The original neural priors retain the all-input absolute margin `|z(x)| > 1/2`.

For a finite relevant class with log cardinality at most `h`, and a posterior tail at most `beta` on every training history, the expected total number of posterior-sampling mistakes is at most

`1 + 2(h + 1) H_(m-1) + m beta`,

where `m` is the number of possible inputs and `H` is the harmonic sum. A confidence failure at correct-label probability at most `2/3` costs at most three times cumulative posterior error; majority mistakes cost at most twice. The paper also proves high-probability bounds with logarithmic dependence on the inverse failure probability.

On the Boolean cube, take `m = 2^d` and `beta = 2^-d`. The existing exact-function compression theorems have description bounds polynomial in `log(1/beta)`, so the resulting cumulative bound is polynomial in target complexity and input dimension. The smaller-width branches use the direct Bayesian log-prior bound. Width-independent constants apply at every admissible width, with the original qualification that the strong-prior variance threshold can depend on that width.

The new ReLU results also transfer: there is a strong-prior cumulative bound at every width, and a specified finite-variance bound for every `gamma >= 2`. For one hidden layer, the latter includes every `gamma >= 1`. These use the independently reviewed product-norm and Gaussian-energy lemmas of the ReLU manuscript; the deeper range `1 <= gamma < 2` remains undecided there.

The new statistical argument handles arbitrary posterior mixtures. It does not choose one minimum-energy function or assume tied minimizers disappear. For the neuron-merging support restrictions, a finite ramp-loss class also gives polynomial dependence on depth for layered Boolean-circuit teachers, with constant wires and compilation overhead counted. The weaker internal-noise restriction's existing approximate-coupling proof does not yet give that polynomial-depth cumulative conclusion.

Uniform input order is substantive. The paper gives simple finite-class examples with exponentially many mistakes in a prescribed order, and under sufficiently nonuniform iid distributions. These examples show that a finite relevant-class count alone cannot prove an arbitrary-order theorem; they are not counterexamples established for the particular Gaussian NN priors. A positive nonuniform extension depends on the logarithm of the smallest positive input probability.

The online statistical proof is self-contained. The neural-network applications explicitly import and list the structural compression and target-mass results from the three main papers. No new Gaussian-compression theorem is claimed. The cumulative results are not Lean verified.

Build with `./build.sh`. See the [independent mathematical review](verification/mathematical-review.md) and [publication record](verification/publication-build.json).

Cumulative high-probability statements hold for each fixed learner, with width-independent constants; they do not assert one common event for the sampled predictions of every width.
