# Fresh publication audit: isotropic subexponential paper

Verdict: **PASS — no blocking mathematical issue found.**

Audited independently from the publication source on 2026-11-06, without relying on the earlier audit notes. Scope: `isotropic-subexponential/source/paper.tex`, all three included `upper-moment-*.tex` files, and the leaf README.

## Main fixed-width result

The stated theorem is justified for every **fixed** hidden width `n`, at one hidden layer, when the target has a width-one depth-two implementation with every weight of absolute value at most one and strict signed output margin `>1/2`. This is the repository's `C_2(f)=1` target class. No uniform statement for growing `n` follows.

I checked the following potentially fragile steps.

1. **Energy compactness and symmetries.** Coercivity plus the closed weak-margin cell gives a minimum-energy weak representative; scaling the readout shows equality with the strict-event infimum. The full augmented cube representation is legitimate because the network is odd. Signed permutations of augmented columns preserve both the actual Gaussian law and the margin event, so they imply exact function-mass equality, including at positive scale.
2. **Column clustering.** A within-group coordinate swap changes output by at most `4 B rho <= 1/2`, whereas opposite labels at weak margin require a difference at least one. The resulting symmetry is exact. Energy-controlled packing gives `r <= C_n[1+(E_0 rho^-2)^(n/(n+2))]` as claimed.
3. **Permutation concentration and Taylor error.** The without-replacement MGF comparison is valid. The displayed constants in the moment bound are loose enough, including odd moment orders. The derivative coefficient-norm induction gives `|tanh^(s)| <= 2^s s!`, hence the stated Taylor error and radius ensure a uniform `1/8` approximation error over all inputs.
4. **Finite descriptors and quantization.** The subset-moment identity and partition-lattice inclusion–exclusion recover moments through order `q` from rowwise group power sums. Cross-row mixed moments are unnecessary because the readout is a sum of scalar activations. The descriptor polynomial degree and term bounds justify the uniform Lipschitz estimate on the enlarged box. Quantization leaves a positive margin and therefore retains the exact Boolean function. Shared descriptors indeed identify a common canonical function, giving an injection from function orbits into allowed descriptions.
5. **Growing Taylor order.** The claim `C_{n,q} <= C_n exp(O(q log(q+1)))` is sufficient and supported by the combinatorics. For a group degree `h_g`, the product of factorial factors in a partition is bounded by `h_g!`, not `(q!)^q`; summing degrees across groups gives `sum h_g log(h_g+1) <= q log(q+1)`. Ordered group assignments account for the separate `r^q` factor. Taking `q = ceil(log(p+1))`, `K=2d+1`, and fixed `n` then gives `rho^-2=O_n(p log p)`, `log H=O_n(log p)`, and `log M=O_n(log^2 p)`. The descriptor count yields `log J=O_n(p^(n/(n+2)) log^(3+n/(n+2)) p)`, which is bounded by the published `log^4` expression. No hidden factor exponential in `q^2 log q` is needed.
6. **Target energy.** The scalar bounded-weight premise forces an augmented signed majority. Scaling its unit-margin affine representative by `1/sqrt(d)` gives energy at most `2d+1`; cloning all hidden units and dividing readouts by `n` preserves the exact canonical energy. This supplies the required `K=O(d)` uniformly over the stated target class.
7. **Posterior and online conversion.** The finite Boolean hypothesis class and strict energy gap outside the target energy sublevel give one scale threshold uniform over all target-consistent histories. Uniform surviving orbit members have cumulative deletion cost at most `1+log m` even when orbit weights vary arbitrarily. Repeated inputs contribute zero. The posterior-error, majority, confidence, expected-sampling, and high-probability-sampling deductions are valid.

## Scalar part

The scalar energy is a strictly increasing function of affine unit-margin cost at every fixed scalar depth. The separation proof for distinct optimal coefficient magnitudes, the low-dimensional orbit packing, and the equal-orbit-mass online elimination all check out. The bounded-weight target reduction and explicit AND cost also check out. The scalar theorem does not silently require integer energies or equal masses across different orbits.

## Scope and presentation

The theorem, abstract, limitations paragraph, and leaf README correctly retain the fixed-width, shallow, bounded-weight-one target restrictions. The README's `C_2=1` shorthand agrees with the repository definition (smallest width bound that also bounds every weight). It explicitly distinguishes subexponential bounds from polynomial bounds and does not claim a growing-width result.

One optional wording improvement: in `upper-moment-section.tex` lines 28–30, say explicitly that the alternative exponent `O_{n,epsilon}(d^(n/(n+2)+epsilon) log(d+2))` applies to the theorem's bounded-weight target class (`K=O(d)`). Its position immediately after the general-`K` assertion is mildly ambiguous on a quick reading. The subsequent proof makes the intended scope clear, so this is not a mathematical blocker.

No repository files were edited by this audit.
