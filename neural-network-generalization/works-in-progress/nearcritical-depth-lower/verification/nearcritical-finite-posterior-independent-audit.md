# Independent end-to-end audit: nearcritical finite-width posterior

25 October 2026. Finite-N audit agent. This is a mathematical audit record, not a Lean verification.

**Verdict: PASS.** I independently checked the complete assembly in `nearcritical-finite-posterior-assembly.md`, including the parameter order, quality budget, occupation-to-transport exponent, actual full-label probability lower bound, and rare-margin readout comparison. No unresolved gap was found. The substantive conclusion is for `t=1+epsilon>1`; the canonical `t<=1` question remains open.

The initial audited assembly had SHA256 `75f17cb761ae139553a8f04b6adc73857537fee0f2469e526bacb88eca58a642`. I also confirmed the subsequent editorial update, SHA256 `9cf4fadfac036a887debfb04ed9a5aff74e801ab7c3a98cd834a9ea45d04b47c`, which removes the unnecessary late-adjustment phrase about b and updates the audit-status paragraph without changing the mathematics. Its component inputs were also read and checked in this audit chain:

- `nearcritical-normalized-empirical-quality.md`, audited separately in `nearcritical-normalized-empirical-independent-audit.md`;
- `nearcritical-normalized-coupling.md`, including the precise distinction between population Hermite factors and same-array empirical coupling;
- `nearcritical-occupation-transport-independent-audit.md`, SHA256 `74164d442117e9998194599dd7a200b070897fde9075158c4336266614e52d14`;
- `nearcritical-cheap-all-label-mass.md`, SHA256 `f2cd22253a9f3fffa40e4228653402860d10c709116c19d23828442e343f643d`, and the earlier optimized-mass audit;
- `nearcritical-bures-free-prefix.md`, SHA256 `5fcf7bb1f29e59334e9af91555c5418e1968a36c6b7312828f53556b12bad59e`.

## Quantified theorem being checked

With absolute constants chosen once, let

`D=d+1+log(1/epsilon)`, `B0=1+epsilon^2 D`,

`H=ceil(K epsilon^-4 B0)`, `N=ceil(exp(A D))`.

The finite-width tanh network has variances `t^2/d`, `t^2/N`, and `t^2/N^2` in the input, intermediate, and readout layers respectively. For every Boolean truth table `f`, write `w_f` for its raw probability with margin greater than one half at every cube input. The claimed result is

`max_f w_f / min_f w_f <= 1+exp(-cD)`.

This is an actual finite-N probability statement under the global margin convention. It is not inferred from an NNGP limit or from typical hidden states alone.

## Occupation and normalized transport

I checked the scalar/pair/spectral occupation derivation. In particular, free spectral monotonicity follows from a positive unital Schur multiplier even with unequal coordinate variances; it does not assume the covariance is already white. The first Hermite component supplies the spectral lower comparison required in the logarithmic potential perturbation estimate.

The composite potential avoids charging a fresh inverse-gap recovery time at every irregular step. Its free increment is nonpositive, and its regular bad-state drift is a constant times `epsilon^2`. The empirical increment is `O(sqrt(v)+v)`. The high-variance cooling bound correctly uses `3 epsilon q`, including the quadratic term in `(1+epsilon)^2`, and controls the sum of squared high variances by `C(1+B+epsilon Z)`.

These facts, with the independently checked global and local normalized empirical couplings, give

`log(Dist_H/Dist_0) <= -c epsilon^2 H+C(D+B+Z+1)`.

The initial distance of any two sign-gauged cube covariances is `O(sqrt(m))`, so its logarithm costs only `O(D)`. The final conversion to physical covariance costs at most one because every final tanh diagonal is at most one.

## Width and constant order

On `B<=b1 B0`,

`Z<=sqrt(H b1 B0)+b1 B0 <= C sqrt(K b1)(epsilon^-2+D)+C b1 B0`.

Meanwhile `epsilon^2 H>=K(epsilon^-2+D)`. Thus K can force the distance below `exp[-L(epsilon^-2+D)]` for any previously prescribed constant L.

There is no circular dependence in taking A first. In detail,

`H tau/B0 <= C K epsilon^-4 m^4 log(eN)/N`,

and `H/(N B0)<=C K epsilon^-4 exp(-AD)`. Since `log(1/epsilon)<=D` and `log m=d log 2`, both ratios tend uniformly to zero as D grows once A has fixed sufficient slack. The mass-witness condition `N>=exp(Cwidth D)log(H+2)` also holds because `log H=O(D+log K)`. Choosing the final dimension threshold after K absorbs all fixed multiplicative constants and ceilings.

The chosen exponential-moment bound for quality yields `exp(CH-c'NbB0)`. Taking `c'b>=2M` and then `CH<=(M/2)NB0` already gives the desired `exp(-MNB0)` bound. No later change of b is needed. I suggested deleting the phrase “after adjusting b once if necessary” merely to make this fixed order completely explicit.

## Actual all-label mass

The comparison uses the optimized bound `w_f>=exp(-Cmass N B0)` for every f. The same B0 controls the quality budget and readout cutoff. The witness's free prefix is covered at the stated exponential-in-D width by the checked nearcritical Bures stability argument and the invariant white box, rather than a crude fixed expansion raised to the full depth.

The weak rank-one amplification cost is `O(epsilon^2 D)` per row; the final amplification and readout cost are `O(1)` per row. The relative Frobenius correction in the empirical covariance control is small enough to preserve those KL costs. This is the needed rare-event lower bound; a typical-state or merely positive-probability witness would not suffice.

## Readout likelihood comparison

For final feature matrices F,G, feature Procrustes gives an orthogonal O with

`||F-GO||_F=sqrt(N) d_B(Q,Q')`.

For readout `v~N(0,t^2 N^-2 I)` on `N||v||^2/(2t^2)<=R=kB0`, the output discrepancy is at most `t sqrt(2R) delta`. With `a=1/2` and `s=a/(a-e_out)`, the map `v -> s O v` sends a strict positive-margin F readout into a strict positive-margin G readout.

The exact Gaussian exponent loss is at most `N R(s^2-1)`. The Jacobian `s^N` is favorable and may be discarded. Hence the multiplicative cost is at most `C N B0^(3/2) delta`, while the discarded hidden-quality and readout-tail probabilities are at most `2exp(-MNB0)`.

Dividing these additive errors by the actual lower bound on every w_f is legitimate. Choosing `M>Cmass+3` makes the relative error exponentially smaller still. Choosing `L>A+10` makes the multiplicative cost at most `exp(-cD)`, since `log N<=AD+O(1)` and `log B0<=D+O(1)`. Reverse the pair f,g to conclude the uniform ratio estimate. This is a deterministic comparison for each pair and uses no union bound over all truth tables.

The hidden coupling need not be invertible: it is used only to put two exact hidden marginals on one probability space. The orthogonal readout map depends solely on those hidden features, independently of the fresh isotropic Gaussian readout. There is therefore no omitted hidden-state Jacobian.

## Learning consequence and limits

Pairing truth tables that differ at one unseen input gives posterior label probabilities in `[1/(2+rho),(1+rho)/(2+rho)]`. Consequently every unseen point is a confidence error at any fixed threshold greater than one half, once D is large enough. The constant target is implemented by width two with bounded weights at every depth, so this lower bound does not rely on a complicated teacher.

The theorem concerns the specified widths, the global margin conditioning, and `t>1`. Near-half posterior probabilities alone do not prove failure of deterministic majority prediction at exactly one half. Nor does the theorem extend to exact canonical `t=1` by taking a limit: the depth and width conditions depend essentially on epsilon.
