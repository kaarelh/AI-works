# Independent audit: finite-width deterministic rare gate groups

Reviewed by the critical-depth agent, 2026-10-19.

Source note: `finite-width-rare-gate-prefix.md` in this round8 directory.

SHA256: `6ccf064fb2fafa68c5dfc52d3f78db70530e6dc55431eef0da856cbeaf06b8e7`.

The construction passes this audit. In particular:

- The Gaussian mean shifts are well-defined on every history (indeed their weight-space means are deterministic). The per-row KL bound depends on group counts and circuit coefficients, not on successful earlier gate approximation.
- The ceiling in k_j=ceil(N p_j) costs at most a factor two because N p_h>=1 and p_j is decreasing. The groups fit in width N, and the exact recursion gives total prefix entropy at most N/(8L).
- Spreading a gate coefficient over the entire preceding group reproduces its empirical group mean exactly. The norm estimate B sqrt(W) eta controls every incoming gate score error, including the constant rail.
- The saturation inequalities hold without truncating Gaussian fluctuations: the Gaussian moment of exp(-2V) yields the displayed constants when variance<=2. Hence the gate approximation resets at each layer; no exponential error accumulation is hidden.
- The conditional independence required for group Hoeffding and full diagonal Hoeffding is valid. The prescribed N bound dominates the union over all gates, layers and 2^d inputs. Only d appears in its logarithm.
- The derivative formula for F has absolute value at most one, so the diagonal error accumulates at most linearly in h. Its comparison sequence uses the actual rounded deterministic group fraction theta_j, avoiding a rounding drift.
- The final normalized indicator u is an actual unit vector in neuron-coordinate space. Thus the empirical projection yields an exact rank-one component, not merely an entrywise approximate covariance decomposition. Its residual is positive semidefinite, and the independent scalar/residual Gaussian decomposition follows by orthogonal projection of the next raw weight row.
- The self-consistency choice is polynomial in the final capacity scale: log(1/p_h)=O(h log R), and choosing A=K h log R with sufficiently large universal K can dominate the required fixed multiple of that expression. The extra 2h log K term is absorbed since K eventually dominates log K. This does not introduce an h^2 exponent.

No mathematical correction requested. The target event probability bound still needs the scalar continuation and likelihood-to-event conversion, as the source explicitly states.

## Final TeX conversion

The complete source `source/critical-finite-width-circuit-prefix.tex`, SHA256 `d1de2b5c93b839f21821f3d3461bbe7979f90f2459f63694dbdc10e3160d8ecd`, was checked after conversion and passes without correction. The extra scalar-channel metric bound follows from p eta^2<eta and the square-root inequality for residual variances, yielding squared error at most (2h+4)eta. The statement correctly calls the prefix law a product Gaussian with deterministic row means. All lemma and remark constants agree with the audited note.

## Sharpened depth parameter and final layout

The final source SHA256 is `4de365738a40063f994336c130d703533ba6c43429cd0c91af4c9486ef21a628`. Relative to the conversion above, the mathematical change is confined to the seed-relative accuracy remark; the last edit only splits a display for layout. The strengthened parameter

`T = log(d+2) + h log(C+B+h+L+2)`

is valid. Since T >= h log(h+2), both h log h and h log(T/h) are at most T. Thus h log T <= 2T and, with a=K T, the exact rarity recursion satisfies log(1/p_h) <= C(1+log K)T. Also log R <= C T and the initial gate-margin constraint is absorbed. Choosing a fixed sufficiently large K therefore makes eta=8 exp(4-KT) smaller than any prescribed fixed power of R^{-1}p_h and any prescribed exp(-c T). The explicit group concentration width then has logarithm O(T); arbitrary smaller failure probabilities add only the stated factor 1+log(1/delta). The sharper remark and final source pass without correction.
