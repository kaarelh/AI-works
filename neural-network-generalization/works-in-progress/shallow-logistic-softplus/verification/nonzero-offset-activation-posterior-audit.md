# Independent audit of the logistic/softplus constant-target posterior

25 October 2026. Finite-N audit agent. Conventional mathematical audit, not Lean verification.

**PASS.** Source `nonzero-offset-activation-ordering.md`, SHA256 `14469b7893420f85e640705f0c40af5f07eddb0ddf6e0b2d6a763eabb57b61be`.

I checked the actual finite-width conditioning and the displayed constants throughout. The logistic conditional difference moment follows from its global derivative bound 1/4 and the exact Gaussian chi-square moment product. With `p=ceil(N/t^2)`, the factors `p t^2/N<=2` and `t^2+2p t^2/N<=5` give the stated contraction. For softplus I also checked the symmetry identity, domination by a squared standard Gaussian, and the choice of integer p. The occupation agent separately audited its Bernstein/tail-integration moment estimate. The case p=1 correctly uses the exact mean contraction rather than a loose high-moment bound.

The depth-independent positive-output mass is valid even when a conditional hidden variance vanishes. Otherwise the last hidden row signs are independent fair signs, and Paley–Zygmund gives probability at least 1/8 of at least N/4 coordinates being at least 1/2. The readout variance is then at least `t^2/(16N)`; the Gaussian tail yields the displayed `exp(-20N/t^2)` bound for an output exceeding one.

The union bound controlling all differences from the observed point is strong enough, once `H>=C(1+d t^2/N)`, to subtract less than half this output-mass lower bound. It therefore lower-bounds the mass of the actual all-positive globally margined truth table, not just a one-point output event. A globally margined mixed-sign output has a difference greater than one from the reference output, so its raw mass is bounded by the same moment argument. Dividing this numerator by the all-positive denominator proves posterior nonconstant mass less than 1/3 after any nonempty positive constant-labeled sample. Additional constant-labeled observations retain the denominator. Readout sign symmetry gives the negative target.

No independence between the positive-output event and the output-difference event is used. Both global margin and training-label conditioning are retained. The theorem is correctly restricted to constant targets: once both labels occur, its denominator witness is excluded, and the proof supplies no analogous posterior conclusion.
