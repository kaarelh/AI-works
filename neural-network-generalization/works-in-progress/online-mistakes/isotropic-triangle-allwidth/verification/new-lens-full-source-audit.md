# Independent final-source review of the triangle-wave online lower bound

Reviewed 7 November 2026 by the `new_lens` research agent. Source: `../fresh_full/paper/source/paper.tex`, read after integration of the atomic, quantitative-fiber, weighted-latent, and finite-width arguments.

**Verdict: PASS mathematically.** This is an independent AI mathematical review, not human peer review or formal verification. It establishes confidence in the displayed conventional proof for the fixed triangle-wave activation; it does not establish the analogous theorem for ReLU, tanh, GELU, or hardtanh.

The atomic inequality and quantitative fiber reduction were checked in separate detailed audits. This final-source review additionally checked the complete chain:

1. The unchanged Gaussian model has exactly the displayed energy, with the bias included in the same isotropic first-layer law.
2. `q_i=2m+2i-1`, `r_i=2q_i` gives `D=6m²`; the chosen core is odd, exceeds the squarefree-separation threshold, and satisfies every atomic and off-code constant.
3. The calibration contains exactly `15·2^(d-4)` distinct physical inputs. Averaging `chi_C F` preserves its calibrated margins, and the flat Fourier-L1 dual gives `L_0=3/2-4/M` without placing any restriction on unknown latent values.
4. The uniform non-code penalty exceeds every star's upper excess. Once a sign completion is code-invariant and core-odd, projection preserves the entire global margin and reduces the optimization legitimately.
5. The Bernstein square-root integral makes every nonconstant weight Walsh coefficient strictly negative. The subgroup dual has strict correct signs everywhere and certifies the Boolean subgroup score as the unique optimized real score.
6. The non-subgroup bound `61/38` applies to variable-margin scores, and exceeds every star cost under the specified core size. A subgroup contained in `{0}∪U` has at most two elements.
7. The interval squarefree argument is valid. The odd numbers `q_i` need not be prime: their nondivisibility and odd-order cyclotomic factors make all coefficient polynomials distinct. Rational independence of the corresponding radicals gives strict star ordering.
8. Only one physical query per star is needed after calibration. Initial calibration continues to exclude non-code low-cost signs, while each such query eliminates the corresponding coded star. The fixed sorted sequence is independent of width and variance.
9. Integer cloning converges along every sufficiently large width, with total allocation fraction below one. The strict finite list of variation gaps therefore yields one finite `N_0(m)` for all designated rounds. No quantitative radical-separation bound is needed.
10. Strict readout amplification gives open wrong-label parameter neighborhoods without losing the energy gap. The Gaussian exponential-moment bound controls the entire correct-label event. The pre-data global-margin normalizer cancels, and the result concerns actual posterior mixtures.
11. The teacher has exactly `2m-1` units with weights bounded by one and margin at least one. Every physical coordinate is essential, so the fan-in-two circuit size is `Theta(d)`. The mistake exponent is correctly stated as exponential in the displayed teacher width and `exp(Omega(d^(1/6)))` in dimension/circuit size.

Two nonmathematical edits were requested from the author: a missing backslash in `\qquad` in the free-coset display, and writing the positive variation gap explicitly as the minimum competing cost minus the selected star cost. Neither changes the proof.

Both edits were subsequently verified in the source. The added definition of `C_2`, bound `C_2(f_m)<=2m-1`, and explicit-width corollary were also checked. The reviewed source at that point had SHA-256 `e3154c0600429d3b19db291ca9506d67f518b5f33683f5691e462ef9f88ef22d`.

The appendix's relaxed logarithmic localization inequality was checked directly. With `u=1-a<=0.15`, the supplied bounds reduce it to

    0.05(u+u²/2) >= 1.05·0.273 u²/(1-u),

which holds throughout the interval. All strict-gap constants have adequate room.
