# Independent audit of the softplus shallow-target manuscript

26 October 2026. Auditor: the finite-width audit research agent.

**Verdict: PASS**, for the theorem stated in the manuscript. This is an independent mathematical audit, not a Lean verification.

Audited source: `manuscripts/softplus-shallow-posterior.tex`, final SHA256 `5e4c97a56bd22fa82babe99fd807f660e8e7e4cc80f8f926d8e25dc843554ade`. The final snapshot corrects only the mathematical-spacing typo identified below; the preceding fully read snapshot was `3a1bc2573f8d6cab4f21cc3593745f2e0cfcc00a9ccac639ca54693aad693055`.

The theorem concerns standard softplus, shallow bounded-weight globally margined teachers, depth at least a universal constant times the squared logarithm of the teacher resource, all widths at least the teacher width, and either fixed-architecture cold limits or actual scales `t <= N^(-zeta/2)` for fixed positive zeta. It does not include the critical exponent one or arbitrary deep teachers.

## Checks

1. The first-layer cloning reserves at least half the neurons as exact constant outputs `log 2`, keeps first energy at most two, and gives weighted readout energy at most `4T`. The first injection uses disjoint signal and constant supports; its energy has no missing cross term.
2. The scalar positive-channel recurrence uses `m-1` new hidden layers after the teacher hidden layer, hence the asserted total depth. The telescoping gains, lower preactivation bound, cumulative positive softplus error, and final margins at target outputs plus or minus one are correct. Monotonicity extends these margins to arbitrarily large teacher output magnitude.
3. Internal energy is exactly `a_j^2 + (A/log 2)^2(1-a_j)^2`; reciprocal-pair summation yields leading coefficient one. The depth assumption makes both `q` and `m(q-1)^2` bounded. All constant injection and final subtraction costs fit `L + C log^2(LT+2)`, including odd widths.
4. The rank-one matrix propagator estimate permits arbitrary intervening diagonal contractions. The constant input to the next signal channel does not create another factor of the anchor at every depth. Polynomial state bounds and variation of constants therefore justify the polynomial operator perturbation radius.
5. Gaussian symmetry gives the translated witness mass with the stated exponent; Gaussian isoperimetry then bounds distance from the bulk set. Dividing by the actual global-margin-plus-sample denominator gives exactly the asserted posterior tail. No informal replacement of the posterior by energy minimization is used at positive scale.
6. After centering the realized network, its zero-fixing Lipschitz scalar maps are frozen. Subtracting bulk matrices creates a surrogate in the larger representation class. Telescoping gives the displayed error bound, while any nonconstant surrogate has anchor offset bounded by twice its product. The finite sign class is independent of the training sample and original width.
7. The complementary relay for the low-width fallback implements the identity exactly. For softplus, normalized states obey `||u_j|| <= log 2 + sqrt(R)||u_{j-1}||`; this bounds the logarithm of the parameter Lipschitz constant polynomially without assuming bounded hidden activations. The clipped Gaussian cube removes any `log(1/t)` divergence, so the finite-width posterior net covers the entire interval below the large-width threshold.
8. The cold-limit concentration argument is at fixed finite dimension and passes Gibbs error on the finite truth-table simplex. It does not incorrectly pass a strict confidence event through a limit.
9. The parity hinge identity, the softplus hinge approximation, the exact complementary linear term, and the number `d+2` of hidden neurons all check.

## Minor presentation observations

The displayed definition of `a_j` contained literal `quad` where `\quad` was intended. The author corrected it in the final audited snapshot.

The proof is distribution-free: only the number of points in the cube enters the representation lemma, and the final finite-class argument works under every input law. Thus the statement can replace uniform cube test and training inputs by an arbitrary common input law without changing the proof. The weaker uniform-input statement as audited is correct.
