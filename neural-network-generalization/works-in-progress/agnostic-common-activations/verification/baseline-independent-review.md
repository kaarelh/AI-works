# Independent review of the baseline common-activation theorem

Reviewed the five source modules on 18 November 2026. No substantive gap was found. This is a conventional mathematical audit, not a Lean formalization. This snapshot records the conservative finite-grid/Hoeffding baseline before the proposed localized statistical improvement.

Independently checked the residual Gaussian operator bound, uniform Stiefel-projector residual standard-deviation bound, and exact joint-state contraction. The importance-sampling/ridge-Gram lemma preserves the residual norm and its added empirical input-Gram constraints control propagation without rank multipliers. Arbitrary Lipschitz perspective functions are covered by bounded-slope scalar nets; the diagonal entropy distinction is correctly maintained. Rank, sample-count, parameter-count, activation-net, and finite-effective-width bookkeeping support q_H=4H-2 for H>=2 and q_1=3.

The Gaussian teacher cylinder works for globally Lipschitz activations with nonzero offsets because cloning covers every learner neuron and the residual perturbation annihilates the clone's group-constant states. The stated uniform perturbation and Gaussian-translation mass estimates were checked, including first-layer and readout scaling and biases compiled with one constant neuron.

The fixed dictionary is sample-independent; the exceptional parameter set may depend on the combined population/empirical input measure, with a valid pointwise prior tail. The proof intersects it with the norm event, so actual good outputs also have the claimed amplitude bound. The posterior tail calculation uses native fourth moments, not bounded outputs. One statistical event covers every finite width, all allowed prior scales, and the specified finite temperature grid. The free-energy selection and fixed population-risk-minimizing comparator preserve leading coefficient one.

The conservative fixed-teacher rate denominators 4H(H+2) for H>=2 and 15 for H1 follow from the stated certificate. They are not claimed optimal. No architecture prior, support restriction, differentiability, bounded activation, or phi(0)=0 assumption is used.
