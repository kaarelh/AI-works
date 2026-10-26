# Fresh stress test of the exact-tanh Boolean-depth barriers

26 October 2026. This revisits the logical and quantitative implications, rather than claiming a new proof of every imported analytic theorem. The original unrestricted exact-tanh depth question remains open.

## Outcome

No counterexample to the published conditional barriers was found. The coefficient-size hypothesis can be weakened: polynomial bit length of the magnitude bound suffices, even for original uncomputable real weights. That sharpening and the quantitative threshold-depth consequence were independently checked and integrated into `boolean-depth-barriers` (source `9089bf74ea31fd2cfd99efad11a821b6e66db54494f85ba67aed814f54dc6c4a`).

## Quantifiers that were challenged

* **Same architecture.** The threshold-target upper is used at the same learner depth and actual realizable width as a purported lower bound. For a polylogarithmic-depth representation, its extra logarithmic padding requirement is eventually smaller than the given learner depth. No increase of learner width or depth is silently allowed in the contradiction.
* **Dimension and subsequences.** On the finite cube, exact fit bounds sample demand by O(2^d) at fixed accuracy/confidence. A stretched-exponential lower in depth therefore forces `d=Omega(L^alpha)`. Together with the resource upper bounds in L, this makes the teacher's rounded description polynomial in d. Passing to distinct increasing dimensions is legitimate in nonuniform circuit classes. A nonexplicit target sequence does not evade the separation consequence.
* **Large real coefficients.** Forward precision needs only O(L(log C+log B)) fractional bits. Saturation-aware tanh evaluation handles large affine values without work proportional to B. Thus polynomially many relevant bits, not polynomial coefficient magnitude or coefficient computability, are the meaningful resource bound. The engineered activation example does not invalidate this step because its activation lacks the corresponding efficient numerical evaluator.
* **Width before distribution.** For polynomial-learning-to-circuit converses, the hypothetical width-independent sample budget is fixed first. One then selects a sufficiently large actual width, fixes its scale, and only afterward quantifies over input laws. This is a legitimate use of an every-width guarantee. A guarantee polynomial in learner width would not support that argument.
* **Prior scale.** The canonical all-scale circuit-target upper is uniform for `0<t<=1`, so a schedule approaching one or zero cannot evade the negative barrier. The hot-prefactor constructions have `t>1` and lie outside it, even when t tends to one. The fixed-exponent-above-one arithmetic converse uses its own explicit finite-width threshold; the critical all-scale converse remains the weaker TC¹ ceiling.
* **Posterior mixtures.** The polynomial-learning converse uses two majority constructions and finite minimax, not a unique minimizer. Its fixed gap above one half is necessary for that argument. In contrast, a stretched-exponential lower even for ordinary majority prediction would still imply the same NC separation: the stronger 2/3-confidence upper already gives a majority upper. Thus weakening the prediction criterion cannot provide a way around the negative barrier.

## Direct finite-width avenues checked

The scale-uniform energy-net upper forces genuinely exponential sample hardness, with polynomial teacher resources, to occur at exponentially large learner width. The newly independently audited mean-shift witness strengthens this for layered Boolean-circuit targets: its sufficient sample term is `N^gamma poly(resources)` at exponent gamma, versus the generic `N² poly(resources)` term. At fixed gamma>=1, an `exp(cL)` lower for that digital target class requires

`log N >= [c/min(gamma,2)] L-O(log L)`.

This is a necessary-width observation, not a lower bound. It does not apply to an arbitrary narrow tanh teacher whose hidden real values store analog information.

Dimension inflation alone can make a logarithmic-in-d lower look exponential in L, but then d is itself much larger than polynomial in L and the claimed effect is not a depth lower beyond polynomial dependence on all input resources. Rare test atoms cannot force fixed constant test error after their total mass has become small. A lower relying on removing the global margin, changing the prior scaling to `t>1`, restricting to noisy exact-fit samples, or replacing the Boolean domain changes a substantive hypothesis of the current question.

## What remains

The results leave a broad interval between a universal polynomial bound and a fixed stretched-exponential lower. The conditional implications do not prove either endpoint impossible. A generic subexponential teacher/witness construction would be relevant to the upper side; a compiler for low-action posterior paths only strengthens a converse and does not itself supply that construction. No new unconditional original-model exponential sample lower or general subexponential upper was obtained in this stress test.
