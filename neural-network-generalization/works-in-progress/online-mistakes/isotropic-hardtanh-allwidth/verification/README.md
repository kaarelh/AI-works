# Build and proof status

For hardtanh, `max(-1,min(1,t))`, the paper proves `exp(Ω(C^(1/3)))` designated online mistakes, where `C` is the width of the displayed bounded-weight teacher. The actual correct-label posterior probability tends to zero on those rounds at every sufficiently large fixed learner width, as the prior scale tends to zero.

The paper uses conventional analytic proofs and is **not Lean formalized**. Independent AI-agent component and integrated-manuscript reviews passed. They covered the sharp atom norm and support stability, retained-code geometry, scalar cost ordering, teacher resources, and the actual posterior at every sufficiently large fixed width.

The proof uses exact inequalities and algebraic cost separation. Numerical optimization is not a premise. The build record gives source/PDF checksums and the clean rebuild and visual inspection results.

The theorem has a very long calibration prefix and concerns arbitrary online input order. See the [ordinary-tanh paper](../../isotropic-tanh-allwidth/README.md) for the corresponding smooth-activation theorem.
