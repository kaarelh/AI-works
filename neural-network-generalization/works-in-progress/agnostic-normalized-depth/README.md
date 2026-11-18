# An exponential-depth sample bound for Gaussian Bayesian ReLU networks

[Paper](paper.pdf) · [Source](source/paper.tex) · [Independent review](verification/)

For independent Gaussian priors with exponent gamma >= 2, hidden ReLU activations, and a bounded final output used in both likelihood and prediction, exp(O(H)) samples suffice at hidden depth H. The other fixed parameters are teacher width, coefficient bound, accuracy, confidence, and either fixed input dimension or an upper bound on d/(H+1). The guarantee holds at every learner width above the teacher width.

The prior is unrestricted and unchanged. One positive Gaussian likelihood variance is selected by comparing an energy certificate with a finite-parameter certificate. There is no prior over network sizes.

The proof retains the product of layer energies and normalizes total quadratic energy by depth. It also keeps the Gaussian scale when choosing the weighted-tail cutoff. These avoid an unnecessary H^H loss. The result is exponential in depth, not polynomial. Its small-width argument uses bounded outputs in the likelihood. A separately proved raw-readout extension gives the same exp(O(H)) sample scale when N^(gamma-1) >= H+1, in addition to N >= C; it uses the ordinary unbounded-readout Gaussian likelihood and raw posterior mean.

The core proof, d=O(H) refinement, and raw-readout extension passed independent mathematical review. This work has not been Lean formalized. Run `bash build.sh` to rebuild.
