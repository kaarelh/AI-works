# Exact online mean-field structural budgets

Checked 22 October 2026. These modules recover the literal `T_L` and `G_L`
formulas in the appendix of `works-in-progress/online-mistakes/upper`, without
rounding its real parameter `K` up to a natural number.

Lean uses `r` for the number of internal hidden matrices: manuscript depth
`L = r + 2`, with `r + 1` hidden layers.

| Manuscript quantity | Lean definition in `BatchTwoOnlineMeanFieldExact` |
| --- | --- |
| Backward `g_s`, with terminal `32(L-1)K²` | `layerBudget r K s` |
| Largest tilt `g_1` | `maxTilt r K` |
| `q = ceil(g_1²/2)` | `sparseCount r K` |
| `log(2*2^(2d)+1)` | `testEntropy d` |
| `T_L(d,K)` | `learnerThreshold d r K` |
| Covariance tolerance `eta` | `covariancePrecision r K` |
| Width `u_*` | `compressedWidth d r K` |
| Hidden parameter count `D_*` | `hiddenParameterCount d u r` |
| Real weight bound `B_*` | `compressedBound d r K` |
| Sensitivity `Lambda_*` | `sensitivity d u r B` |
| `G_L(d,K)` | `capacity d r K` |

The maximum defining `B_*` is associated as `max (max 1 sqrtTerm) readoutTerm`,
which is exactly the three-term maximum in the manuscript. The parameter
count is `D_* + u_*`.

## Completed actual analytic statements

- `good_network_mem_functions` (module `BatchTwoOnlineMeanFieldExactCompression`)
  puts every actual globally half-margin network with the actual recursive
  covariance good event and readout energy at most `K` in `functions d r K`.
  The finite representative has precisely width `u_*` and weight bound `B_*`.
  The good event is a raw weight-space event; it is not an assumed approximation
  or capacity conclusion.
- `functions_card_le_exp` proves cardinality at most `exp(G_L(d,K))` by an
  actual parameter-grid injection. Both the bound and grid scale are real:
  no inflated integer weight bound enters the depth-dependent sensitivity.
- `aggregate_tail` (module `BatchTwoOnlineMeanFieldExactTail`) proves
  the actual raw total mass outside this class is at most
  `(r+2)*exp(-N*K/8)`, for every real `K >= 4`, positive input dimension,
  and `N >= learnerThreshold d r K`. This uses the original power prior
  at exponent one, actual full-margin sign-function masses, conditional
  layer independence, and the exact sparse covariance-coordinate entropy.
- `readout_bad_tail` supplies the rate `exp(-N*K/8)` already at `K >= 4`.
  It improves the older helper's unnecessary `K >= 8` premise.

No Gaussian or covariance theorem is left as an additional hypothesis in
these structural endpoints. `BatchTwoOnlineMeanFieldExactAudit` checks them;
their only axioms are `propext`, `Classical.choice`, and `Quot.sound`.

## Completed actual statistical endpoints

`BatchTwoOnlineMeanFieldExactBridge` uses the manuscript's exact
`K = 4*A + 8*log(L*2^d)` from `BatchTwoOnlineSharp.onlineEnergy`.
`meanField_large_online_of_mass` gives both uniform input protocols and
actual independent posterior-sampling tails with the exact `h=G_L(d,K)`.
`meanField_small_prior_cost` and `meanField_small_total_of_mass` give the
exact direct cost `J=A*T_L(d,K)/2` (the latter for any input sequence).
These generic bridges retain the raw target-mass premise explicitly.

That premise is now discharged by
`BatchTwoOnlineSharpTargetMass.powerPrior_target_mass_sharp`, with
`A=BatchTwoOnlineSharp.targetCost d C r` exactly equal to the appendix's
`A_L(d,C)`. The actual standalone endpoints in
`BatchTwoOnlineSharpNeuralMain` are:

- `meanField_large_online_paper`: actual both-protocol online conclusions
  with the exact `G_L` above the exact `T_L`;
- `meanField_small_total_paper`: exact direct `J` for every infinite query
  stream below `T_L`;
- `meanField_online_paper`: actual all-width branch combination, including
  independent posterior draws and high-probability conclusions.

These main endpoints do not assume a target-mass, compression, or Gaussian-tail
conclusion. The older larger cylinder polynomial is not substituted for the
appendix's specified constant.

The existing development also proves a polynomial majorant and actual
all-width online theorem using larger structural budgets. A formal
polynomial majorant of these exact real-parameter formulas is a separate
arithmetic endpoint; it is not asserted here merely from the definitions.
