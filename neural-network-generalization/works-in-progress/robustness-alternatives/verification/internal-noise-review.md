# Independent audit of the internal-noise and noisy-activity theorem

Reviewer: `fresh_final_review`, 2026-10-22. This audit read the complete derivation and independently checked the compressor, finite coding, robust circuit witnesses, uniform-width target ball, and posterior comparison. No author or repository source was edited.

## Verdict and exact versions

**No substantive mathematical gap found.** The derivation supports polynomial-depth, width-independent learning for the stated robustness-plus-noisy-RMS support restriction, for ReLU and exact GELU, in the fixed-width strong-prior regime and simultaneously for every `N>=2C` and `0<sigma^2<=N^(-2)`. It does not establish the mean-field or intermediate finite-scale cases `1<=gamma<2`, and correctly says so.

The reviewed files, hashes checked at 2026-10-22 13:49:04 UTC, are:

| File | SHA-256 |
| --- | --- |
| `amplification.md` | `c0f38c2ff57b74c4848fe2dd65ab47cae7290fab8c002b2b1d4ac7e2b419b5ea` |
| `robust-witnesses.md` | `9ee0f042789075c2578f2f2e2e56bc7ce14b9d7ceaa90b26d147e66025415043` |

One expository correction was requested and applied before this final hash: the reciprocal precision `eta^(-1)` can be exponentially large in depth; only its logarithm is needed in the code size. Width, energy, coefficient-size bounds, and logarithmic precision costs have polynomial resource bounds. This correction does not change the theorem or proof.

## 1. Clipping and the adaptive virtual computation

The noisy-RMS hypothesis is on the hidden states **after** injection. For an admissible disturbance, Cauchy–Schwarz therefore bounds the next preactivation by `R sqrt(N)` times its row norm. The deterministic neuronwise clipping envelope consequently leaves every allowed noisy computation unchanged, by induction. The first layer uses the separate input bound `sqrt(d+1)`.

This use of clipping is not circular. The virtual sampled computation is first defined using the clipped activations, so all its normalized coordinates are bounded regardless of whether it already corresponds to a small disturbance. The concentration event then produces a complete postactivation disturbance tuple of total norm at most `r/4`, by subtracting the unsampled clipped-layer output at the preceding virtual state. Only after this estimate is established does one invoke equality of the clipped and original networks on the allowed disturbance ball.

Zero-envelope neurons have zero rows and zero pre-disturbance activations. They may be omitted from sampling; their constructed virtual disturbance is zero. Other allowed disturbances can excite them, but that does not invalidate the clipping-equivalence statement. Global clean margin prevents an entire layer envelope from vanishing.

## 2. Importance probabilities, pruning, and concentration

With `p_i=a_i^2/(N A^2)`, the discarded weighted row mass satisfies

`sum_discarded |W_ji| a_i <= ||W_j||^2 / threshold_j`.

The displayed threshold therefore gives the claimed normalized pruning error `q A sqrt(k_s/S)/8`.

For a single fresh source sample,

`Y_j = Wbar_{j,I} a_I g_I / p_I`,

the bounds `|g_I|<=1` and the importance probabilities give

`E||Y-EY||^2 <= N A^2 ||W_s||_F^2`.

The pruning threshold gives `||Y|| <= 8 sqrt(N) A sqrt(S k_s)/q`, so centering gives the factor 16 in the draft. At averaging tolerance `q sqrt(N) A sqrt(k_s/S)/8`, the Bernstein denominator is at most `(10/3) N A^2 k_s`, giving exponent

`3 m q^2/(640 S) >= m q^2/(256 S)`.

Thus the stated width makes the union bound over `2^d` inputs and at most `L` stages smaller than `1/200`. The logarithmic input-set cost is correct.

The needed conditional independence is also correct: the full virtual hidden state at layer `s-1` depends on source lists only through layer `s-2`, while the list sampling layer `s-1` is fresh. Choosing stored destination coordinates does not change the full virtual computation. The same argument handles the final readout.

The allocation by `A_{s-1}^2 k_s` is valid. After applying the activation Lipschitz constant and treating the readout separately, the sum of squared disturbance costs is at most `r^2/16`. The leading 1 in `S` and the choice `q=r/lambda` supply sufficient slack.

## 3. Expected compressed energy and absence of hidden width factors

For destination `j` and source `i`, the stored normalized coefficient is

`Wbar_ji a_i/(a_j m p_i)`.

Independent adjacent source lists give expected internal Frobenius energy

`sum_{j,i} [p_j/a_j^2] Wbar_ji^2 [a_i^2/p_i] = (A_{s-1}^2/A_s^2)||Wbar_s||_F^2`.

The first-layer energy is `k_1/A_1^2<=1`; the normalized readout energy is `A_H^2 E_v`. Since `A_s^2=lambda^2 R^2 k_s` internally and the first-layer envelope satisfies the corresponding inequality, the total expectation is at most `Q=1+K+S`. The factors of original width `N` cancel exactly. Markov's inequality and the concentration event have a positive intersection.

Sampling with replacement is valid even when the proposed compressed width exceeds the original width. Thus the proof needs no unstated lower bound on learner width beyond the target's compiled width.

The bound `S<=1+lambda^2 R^2 K^2` is valid. The resulting `m_0` grows as a polynomial of order `L K^3` in the principal resources; there is no depth-dependent exponent of `K` here.

## 4. ReLU/GELU coding

For ReLU, normalizing by the clipping envelope gives the single activation `min(1,max(0,t))`, exactly as asserted.

For GELU, it gives `clip(t Phi(a t),-1,1)`. The small-`a` linear limit and large-`a` ReLU limit are uniform on the specified interval. On the intervening log-parameter interval, the derivative bound by `U` is valid, and a mesh of size `eta/(4U)` produces a cover of size `O((U/eta)log(2+U/eta))`. Its logarithm, rather than its size, enters the finite code. This handles arbitrary small or large envelopes independently of learner width.

All cover centers remain bounded, zero-at-zero, and uniformly Lipschitz. They are auxiliary counting activations, not modifications of the original Gaussian learner. The preactivation bound `U` applies to both the original compressed network and the rounded network because all hidden coordinates are bounded by one.

Clipped-output approximation within `1/16` to a globally margin-separated original gives compressed signed output at least `7/16`. Doubling the readout and then rounding leaves ample strict margin. The displayed coefficient bound `B=8 sqrt(m_0 Q_0)` is conservative even after readout doubling. The layerwise rounding recurrence is dominated by the displayed `A`, and its final error is at most `1/128`.

Consequently the finite code is common to every original width. Its logarithmic size is polynomial in depth and the energy cutoff, with the stated `K^6` type leading dependence up to logarithms. A completely numerical sample bound would require choosing the absolute constants in the elementary activation-cover count; that is routine explicitization, not a missing argument.

## 5. Circuit witnesses and support interior

The paired ReLU construction was checked independently, including balanced nondivisible cloning. The decoded pair noise bound is `sqrt(8C) r_s`, the constant drift is at most `sqrt(8CH) r`, and the bit error relative to the current constant resets each stage. The radius `1/(64 sqrt(CH))` leaves all gate inputs in their plateau regions and final signed output above `3/4`. The noisy hidden RMS bound is uniform even though individual clone injections can be large.

The first-layer energy bound is correctly the conservative `16d`, allowing constant wires as gate inputs. Internal row and readout estimates give the stated `160(H-1)C+40C`, with `E_v>=2C`.

For GELU, the exact constant identity and the uniform restoring-gate approximation prevent approximation errors from accumulating with depth. The fixed choice `k=1000`, the stated radius, energy, and RMS envelopes have substantial slack. Internal physical weights remain bounded because the incoming gain cancels the previous decoder normalization. The readout-reference radius lies inside the certified witness radius for both activations.

The support conditions are Borel by finite input space, compact rescaled disturbance balls, and continuity. More importantly, the witnesses have strict clean/noisy output and activity slack. They are interior points of the support at every fixed width. The stronger explicit target ball in the next step supplies a uniform quantitative version.

## 6. Uniform-width weighted target ball

A weighted parameter perturbation of Euclidean norm at most `rho` changes the first-layer output RMS by at most `lambda sqrt(2) rho`, each internal operator by at most `rho`, and the scaled readout by at most `rho`.

From `sqrt(E_v^*)>=sqrt(2C)/k_0` and `rho<=1/(4k_0)`, the perturbed readout energy is at least `C/k_0^2`. Therefore its reference noise radius is at most `.01 k_0/sqrt(CH)` and at most `.01`; this is inside the corresponding witness-certified noise ball. The comparison under the same arbitrary allowed disturbance is therefore legitimate.

The hidden error recurrence stated in the draft follows by adding and subtracting the perturbed matrix applied to the witness state. The proposed `E_b` dominates all layer errors. The selected `rho` then gives output error at most `1/32` and leaves every hidden RMS strictly below `R`. Both the clean and noisy outputs remain above signed margin `1/2`, so their clipped predictions agree exactly. Thus the whole weighted ball belongs to the support and realizes the target, with radius independent of `N`.

Although `rho` is exponentially small in depth, `log(1/rho)` is polynomial in the resources. That is sufficient for the Gaussian mass calculation.

## 7. Gaussian mass, posterior comparison, and scope

The weighted coordinates are independent Gaussians of common variance `sigma^2`. For `sigma^2<=N^(-2)`, their dimension satisfies `p sigma^2<=d+L=V`.

For scalar half-width `sigma h`, `h<=1`, the elementary bound

`P{|Z-a|<=sigma h} >= [2/(e sqrt(2pi))] h exp(-a^2/sigma^2)`

is valid. Taking `h=min(1,rho/(sigma sqrt(p)))` puts the coordinate box inside the weighted ball and gives exactly the displayed `D_mass`. Both uses of `p sigma^2<=V` are monotone and valid; no dependence on `log N` remains.

The chi-square exponential moment gives the stated energy-tail/target-mass ratio. The choice of cutoff `K` makes it at most `epsilon/2` uniformly in all admissible widths and variances. Global support normalization cancels, and the target remains in every noiseless posterior denominator. One finite-class consistency event therefore works for the entire set of widths and scales simultaneously.

For the strong-prior statement, fixed parameter dimension and an open target neighborhood suffice for the raw energy tail above `2D_teacher+1` to be negligible relative to target mass. The variance threshold may depend on width; the finite function class and sample event do not.

The full-ball method genuinely stops short of the mean-field/intermediate regime: `p sigma^2` can grow with width when `1<=gamma<2`. No conclusion for that regime was smuggled into the audited theorem. No claim that ordinary training satisfies the support condition is needed or established.

This audit is not a formal proof-assistant verification, but all substantive displayed steps of the derivation were checked directly.
