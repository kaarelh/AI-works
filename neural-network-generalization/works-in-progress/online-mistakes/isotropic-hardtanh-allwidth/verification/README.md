# Build and proof status

The paper uses conventional analytic proofs and is **not Lean formalized**. Independent AI-agent component and integrated-manuscript reviews passed. They covered the sharp atom norm and support stability, retained-code geometry, scalar cost ordering, teacher resources, and the actual posterior at every sufficiently large fixed width.

The proof uses exact inequalities and algebraic cost separation. Numerical optimization is not a premise. The build record gives source/PDF checksums and the clean rebuild and visual inspection results.

The activation is hardtanh, `max(-1,min(1,t))`. The theorem has a very long calibration prefix and concerns arbitrary online input order. See the [ordinary-tanh paper](../../isotropic-tanh-allwidth/README.md) for the corresponding smooth-activation theorem.
