# Independent audit: polynomial coefficient-bit depth barrier

26 October 2026. **PASS** for §§1–3 of
`polynomial-bit-weight-depth-barrier.md`, SHA256
`1e7ce6de3d5a73c5d7835f43c72a99ea5f377825adda243f74454506cf96796c`.

The finite-description lemma depends polynomially on the logarithm of
the maximum coefficient magnitude, rather than the magnitude itself.
Its forward-error recurrence is valid even with large affine
cancellations: write the perturbation as
`W(h-h_tilde)+(W-W_tilde)h_tilde`, and use the exact bound
`|h_tilde|<=1` from clipped nearest-grid rounding. The stated precision
`p=(D+3)(b+q+4)+10` makes the final error less than `1/16`, so the
strict global output margin preserves all Boolean signs. No
computability assumption on the original real coefficients is used;
their finite approximations are nonuniform circuit constants.

The saturation test prevents an exponentially large Taylor domain.
In the nonsaturated range `|u|<=p+10`, Taylor degree
`16(p+10)^2` has more than sufficient uniform error slack. All terms
can be represented over denominator `2^(2pJ) J!`, with `O(p^3)` bits.
Ordinary rational arithmetic and final nearest-grid rounding are
polynomial-size Boolean computations. The nearest-grid clarification
in the audited version ensures the final rounding contributes at most
`rho/2`; the Taylor error is smaller than the remaining budget.

For the conditional lower-bound barrier, finite-domain consistency
forces `d=Omega(L^alpha)` from a fixed-accuracy lower bound
`exp(c L^alpha)`. Together with `d+C+log(2+B)<=L^b0`, this gives a
nonuniform family in P/poly. An NC^k representation would have
polylogarithmic threshold depth and polynomial resources. The uniform
target theorem then applies at the same learner depths, scales, and
realizable widths, because its logarithmic padding requirement is
eventually satisfied. Its `exp(polylog L)` sample upper contradicts
the assumed stretched-exponential lower. The width argument correctly
uses the all-realizable-width theorem and does not impose `N>=B`.

This establishes a conditional circuit-separation implication, not a
generic sample upper bound or an unconditional separation. It does not
transfer to an activation whose own high-precision evaluation can
encode arbitrary hard tables. Section 4 is a publication recommendation
and is not part of this mathematical audit.

## Quantitative refinement, same-day follow-up

**PASS** also for the added §3a in the updated note, SHA256
`f5b9a57ef429db8f72f9ec65f0a5c5ef07c443094e7cbbf617ba0670a13f8ed1`.
The previously audited §§1–3 are unchanged in substance.

For `0<alpha<=1`, a threshold implementation of width `L^a` and
depth `h` is converted by the established weight-independent compiler
to depth `O(h)`, polynomial width, and polynomially bounded normalized
gate norms. Therefore the uniform target upper needs
`exp(C_a(h+1)log L)` samples when `L>=C_a(h+1)log L`.
Taking `h+1<=kappa L^alpha/log L` with sufficiently small fixed kappa
satisfies padding and puts the upper exponent strictly below the
assumed `c L^alpha`. Widths and scales remain exactly those of the
purported posterior lower bound. The stated necessary threshold-depth
bound `Omega_a(L^alpha/log L)` follows, with the additive one harmless
eventually. Arbitrary original real threshold coefficients are covered
by the explicitly cited weight-independent compiler; this numerical
independence is not silently assumed for real tanh states.

Final scope clarification checked: the note now explicitly says the
teachers have the same depths as the learners and places the fixed
statistical parameters in `(0,1)`. Final note SHA256:
`384bca523db4f6391bef133efe9f4150e777601bd29125d610ebc31cde3f8667`.
The corresponding proposed TeX replacement and two corollaries in
`polynomial-bit-weight-depth-barrier-patch.tex` were also read in full
and **PASS** with those same hypotheses and conclusions (source hash
`589c8f6da3fec65380622ae9d70560f62ad7d858dc4cf8b9a4ab1209e7e74dc5`). The scope clarification
does not change the audited argument.

The authorized integration into
`works-in-progress/boolean-depth-barriers/source/paper.tex` was checked
against the complete git diff and the audited patch. **PASS**: it replaces
only the finite-description lemma/proof and adds the two audited
corollaries and scope paragraph after the existing all-prefactor barrier.
The original bounded-weight admissibility theorem is unchanged. Audited
integrated-source SHA256:
`9089bf74ea31fd2cfd99efad11a821b6e66db54494f85ba67aed814f54dc6c4a`.
