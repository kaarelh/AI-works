# Polynomial-depth Bayesian learning with continuous neuron gates

[Paper](paper.pdf) · [Source](source/paper.tex) · [Verification record](verification/README.md)

This paper studies one fixed dense network architecture with a continuous hierarchical prior. Each hidden neuron has a positive Gamma(κ/N, 1) gate shared by all its outgoing weights; edge and bias factors are independent Student variables. The actual outgoing weights are dependent. This is an explicit group-shrinkage prior, a substantive change from independent Gaussian weights, and not a result for the latter.

For ReLU, positive homogeneity makes the same function prior exactly equivalent to scaling each neuron’s incoming row and bias by its gate. Standard Gaussian factors are also allowed: they add a polynomial coefficient-cap cost, while the Boolean-circuit bounds are unchanged. Shared-node-scale neural priors and their wide limits have established precedents, notably [Lee et al. (JMLR, 2023)](https://jmlr.org/papers/v24/22-0537.html); the paper does not claim to introduce that model family.

For any globally Lipschitz hidden activation, biases at every layer, a bounded Lipschitz output link, and conditionally sub-Gaussian labels, the ordinary final posterior mean under a fixed Gaussian likelihood competes with every smaller same-depth network:

- **Expected risk, coefficient exactly one:** comparison risk plus a nearly 1/n remainder, using all observations.
- **High probability:** the noise floor plus (1+η) times comparison approximation error, with a nearly 1/(ηn) remainder.
- **Every finite learner width N≥C:** the constants have no learner-width penalty.

For a width-C, depth-H comparator with coefficient bound B, the general complexity cost is approximately

`[(d+1)C + H C²] · [H log((d+C+2)(B+2)) + log(Hn)]`.

It is polynomial jointly in teacher width and depth and only logarithmic in coefficient magnitude. No robustness condition is placed on the prior or on the general comparator. If the comparator's internal rows are contractive, the cost improves to roughly `[(d+1)C + HC²] log(dCBHn)`, with the same unrestricted prior.

For bounded-fan-in Boolean circuits, explicit restoring ReLU/tanh/sigmoid implementations also achieve the sharper `[(d+1)C + HC²] log(nCHd)` cost, without a contractivity assumption. ReLU uses at most twice the circuit width and depth; tanh/sigmoid use the same width and depth, with final clipping.

A lower-depth teacher can also be used in an arbitrarily deeper learner. For ReLU and tanh with Student factors, a scalar relay gives a cost of roughly [(d+1)C + hC²] · h log(CB) + H, up to the displayed logarithms, where **h is teacher depth and H is learner depth**. This holds at every N≥C. ReLU uses the exact width-one clipping reset clip(z)=1−ReLU(2−ReLU(z+1)); tanh uses a weak scalar relay. The latter fast refinement relies on Student tails and is not asserted for fully Gaussian factors.

The paper also proves actual function-prior statements. Small implementations have uniformly positive neighborhood mass, with a polynomial complexity cost. Conversely, typical prior draws compress to rational networks of polynomial depth and description complexity, giving a converse from function-prior mass to approximate circuit complexity. For a target with a margin implementation, these imply polynomial total online confidence/majority mistake bounds on arbitrary input sequences. The positive online bound starts from the unconditioned prior; initial all-input margin conditioning is optional. The stated exact-sign complexity converse uses that margin convention. A gamma-process infinite-width limit retains shared neurons, and the width-uniform expected-risk oracles pass to that limit.

The sharp oracle is an **expectation** statement. The high-probability theorem has the stated approximation slack. The learner performs exact Bayesian inference; no efficient inference algorithm is claimed. The bounded output link is part of the likelihood and prediction rule.

The proofs have undergone independent AI-agent mathematical review, but have not been formalized in Lean. Run `bash build.sh` to rebuild the PDF with pdfLaTeX.
