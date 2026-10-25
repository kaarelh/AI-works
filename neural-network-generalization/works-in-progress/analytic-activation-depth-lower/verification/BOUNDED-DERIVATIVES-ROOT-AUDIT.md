# Independent root audit: every derivative bounded, exponential depth lower bound

25 October 2026. **PASS.** Conventional mathematical audit, not Lean verification. This record presents the final conclusion of the root-agent audit; its scratch development also checked an earlier weight-two amplifier variant.

The audited final research note has SHA256 `69f1571343261f309097c0ee85db9c326f88490e2cde07ff102418bab8838895` and is reproduced at [all-derivatives-bounded-counterexample.md](../research-notes/all-derivatives-bounded-counterexample.md).

The amplitude formula is exact: with `m=M0+ceil(log2(d+2))`, `r=2^(-d-4)/2^(m+10)`, the amplitude is `delta=tau 2^[-(m-2)d-m-14]`. For each fixed derivative order j, the Gaussian lattice derivative majorant is summable. This proves a finite global bound for each derivative, not a uniform analytic or finite-order Gevrey bound. Normal convergence on complex compact sets gives the entire perturbation. Weighted first and second derivative bounds, together with the cubic zeros at the origin, preserve the original shape conditions and any prescribed finite C^r closeness.

For the growing finite-difference decoder, the tanh background relative error is exactly bounded by `C/tau * 2^(-2d-3m+14) m^(-m) exp(-8d)`. Same-band leakage is dominated by the offset-to-bandwidth ratio `2^(m+9)/m`, even after the O(d) coefficient sum. Cross-band Gaussian suppression dominates the inverse encoded amplitude, including the finitely many low-index bands. The decoded signs are therefore uniform over the entire cube.

The decisive amplifier gain is `a_d=2^(m_d-2)=Theta(d)`. The identity `delta_d a_d^(d+1)=tau 2^-16=:rho` is exact. The ideal preactivation amplitudes form a geometric sequence whose sum is O(rho), uniformly in d. The local relative error bound for phi therefore accumulates to O(rho), regardless of the growing gain. A fixed small tau and fixed readout give global unit margin. Counting layers gives `L=d+4`; active width is O(log d), coefficient magnitudes are O(d), and O(d log d) parameter bits suffice. Padding to width O(d) is available if weights are required to be bounded by width.

Because teacher depth is again linear, the original memorizer uses fixed q>1 and fixed alpha>0. Its energy overhead, cold comparison, and fixed-gap perturbation estimates are unchanged, yielding the same exponential-in-d learner-width thresholds. The critical branch requires only the fixed activation's shape and finite derivative bounds; its logarithmic depth condition follows after shrinking the sample exponent. All three posterior regimes therefore retain sample lower bound exp(c d)=exp(Omega(L)).

The activation still encodes computationally difficult tables. It has no polynomial-size fine-precision evaluator or uniform finite-order Gevrey bound. The result gives no corresponding lower bound for tanh, ReLU, GELU, logistic, or softplus.
