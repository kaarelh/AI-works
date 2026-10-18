# Independent audit: input editing and product closure

Auditor: `depth_counter_audit`. Date: 2026-10-19.

Reviewed frozen source `source/unrestricted-primary-input-editing.tex`.
SHA-256: `57746ca529162af976774348e98e1e46c5eb77adca3d0b6eec53c3bce1710c21`.

**Verdict: all statements and proofs pass.** No mathematical correction requested.

The bias-free extension to the complete augmented input is odd and has Lipschitz constant at most the matrix Frobenius product. Vector-output cloning gives the stated variation bound, and merging the prefix's linear output into the old first matrix adds exactly one hidden layer.

For finite label editing, the vector identity `h(x)(1,x)=(1,x)-2 sum_e (1,e) 1_{x=e}` is exact; no multiplication neuron is required. The point detector has integer margin one on the cube. The tanh error, accumulated vector error, old-network Lipschitz loss, and final rescaling leave the stated margin. The constant and identity neurons implement the entire vector map on the Boolean cube. The variation bound uses the valid inequality `sqrt((d-1)^2+d)<=d` for `d>=1`.

The explicit finite cloning choice makes the incoming squared norm at most `2tV` and the outgoing squared norm at most `V/t`, hence product at most `sqrt(2)V`. All nonzero input/output norm ratios in this construction are polynomial in the claimed parameters. The intrinsic-infimum conclusion uses an approximate representation and does not presume attainment.

The vector Fourier lemma follows by scalar parity approximations and summing outgoing vector norms. Its error choice is valid whether the variation is above or below the requested tolerance. Composition uses the global Lipschitz property of the old network, so the approximation need not remain exactly on the Boolean cube.

Predicate modulation uses vector Fourier variation at most `(d+1)H`; parity is the special case `H=1`. The AND/OR selector maps send inputs to the original input or a fixed witness with the appropriate label. Their vector Fourier variation has the stated bound. Constant-target cases and the lack of an efficient witness-finding algorithm are properly separated.

This establishes the specified closures, not arbitrary majority closure or a noisy-label learning theorem. The final limitations are accurate.
