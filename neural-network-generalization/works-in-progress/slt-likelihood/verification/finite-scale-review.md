# Independent review of the finite-scale Gaussian-likelihood transfer

19 October 2026. Reviewer: separate Codex agent `/root/slt_positive`.

**Verdict: the finite-scale every-width theorem and proof are correct.** This is a conventional mathematical review, not a Lean formalization.

The root agent and the obstruction agent independently identified the transfer argument. The obstruction agent wrote the explicit transfer lemma in `finite-scale-transfer.md`; this reviewer independently derived the same posterior and statistical bounds, checked that manuscript, and integrated the proof into the supporting note. This review concerns the likelihood transfer and checks its dependencies against the already published continuous-domain statements; it is not a new full audit of every proof inside that paper.

The source dependencies checked directly were:

- [Continuous-domain source](../../../side-results/continuous-domains/source/paper.tex), proposition “A uniform teacher tube at every width”: tube mass at least `exp[-A_L(rho) N^gamma]`, with polynomial dependence on `log(1/rho)` at fixed depth.
- The same source, lemma “Spectral truncation at gamma>1,” the continuous-domain energy-cover proposition, and the subsequent all-width proof: a width-independent cover with exceptional probability at most `L exp[-K N^gamma/8]` in the Gaussian case, above a polynomial width threshold at each fixed gamma>1.
- [Mean-field source](../../../side-results/continuous-domains/source/meanfield.tex), proposition “Mean-field output cover”: corresponding probability at most `2L exp[-c K N]`, and polynomial width threshold and entropy at gamma=1.

For likelihood `exp[-s RSS/2]`, `s=N^gamma`, the tube radius `rho=n^(-1/2)` gives the deterministic normalizer bound `Z>=exp[-s(A+1/2)]`. This choice is made using sample size, not the realized sample. Both the posterior residual-budget tail and the exceptional-cover mass are consequently small once their exponents exceed `A+1/2` by the specified logarithmic accuracy terms. No bounded total parameter-energy assertion is being made at critical scaling.

For covered parameters with residual budget B, output precision tau/8 makes each training point in `{|h-f|>tau/2}` contribute more than `(3tau/8)^2` to residual sum. The stated constants 96 and 48 then follow from the multiplicative Chernoff bound and a finite union bound. Cover centers need only be Borel; the published statement supplies this. All sets and cover budgets are fixed before observing the sample.

Below the cover threshold T, the independent-input likelihood expectation for test risk exceeding r is at most `exp[-n c_tau r]`, with `c_tau=1-exp(-tau^2/2)` because s>=1. Integrated Markov and the deterministic normalizer give the stated bound with `T^gamma(A+1/2)`. There is no need for the extra condition `beta rho^2<=c r/2` used in a differently parameterized prior-mass lemma: here the full `n beta rho^2=s/2` is charged explicitly.

For fixed gamma, raising a polynomial threshold to gamma retains a polynomial majorant. Every quantity depends polynomially on resources and log n; the displayed inequality `(1+log n)^q<=c_q sqrt(n)` gives a polynomial sufficient sample threshold, uniformly over every N>=C. This establishes a genuine finite-width result, rather than an invalid substitution into the unquantified strong-prior limit.

The theorem assumes clean labels but uses a Gaussian statistical likelihood with observation variance N^(-gamma). It is ordinary Bayes at each width. It must not be relabeled as a fixed-observation-variance theorem or as learning from actual Gaussian-corrupted labels. The confidence loss concerns the latent output. Fixed-depth constants may deteriorate as gamma approaches one from above; the critical endpoint has its separate published cover proof.

The one-added-layer Boolean extension also transfers: approximate the Boolean target within `1/(2sqrt(n))`, and use a tube of that same radius around the approximating teacher, so residual sum throughout the tube is at most one. Teacher resources gain only polynomial factors in log n, which the same final sample-threshold argument absorbs.
