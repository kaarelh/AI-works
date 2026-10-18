# Independent audit: critical parity at nearly logarithmic depth

Auditor: `depth_counter_audit`, 18 October 2026.

Reviewed SHA256 hashes:

- `critical-logarithmic-depth-parity.md`: `45825f5e5b939a60a81b2f4f4a6b869426ec98449919e089a175a3513f806c20`.
- `critical-nearly-logarithmic-depth.tex`: `9100f3265a7899fce4a706e05662f433d3e8ac1b04ab49c61590a0e89af052c5`.

## Verdict

The proposed proof in `critical-logarithmic-depth-parity.md` and the complete TeX section `critical-nearly-logarithmic-depth.tex` pass independent mathematical review. No mathematical correction was requested. The result concerns the actual original globally margin-conditioned critical posterior, including mixtures of tied minimizers, in the stated width-first order. It is not Lean verified.

The review checked the new analytic estimates and their interface with the existing oriented-majority interpolation lemma, exact-budget transport inequality, and finite-domain posterior rate theorem. Those existing ingredients were read in the repository's critical-depth source.

## 1. Sharp mean amplification

The scalar estimates are valid. In particular `(tanh²)''<=2`, Gaussian differentiation and pointwise variance monotonicity give `0<=F'<=1`. Compactness and the expansion `F(v)=v-2v²+O(v³)` give the uniform quadratic cooling estimate on `[0,2]`. Taylor's upper bound for a shifted Gaussian square and integration of `sech²(t)>=1-t²` give the two displayed shifted moment estimates.

For the first mixture, `theta D=q/2`, its second moment dominates `theta h h^T`, and its diagonal is at most `u_1+theta`. The mixture parameter can be made at most one by the displayed condition with constants depending on fixed `a`.

The factors `c_s` have a universal positive lower bound because `u_1<1`. Both `-log(c_s)` and `c_s^(-2)-1` are bounded by a universal multiple of `u_(s-1)+epsilon`. Consequently their product has only polynomial loss in `L`, and their sum has only additive `O(log L)` overhead.

At each shifted layer, domination of the tracked vector's outer product by the reference second moment puts the shift in the covariance range and bounds its Gaussian KL cost by `q/(2c_s²)`, also for singular covariances. The unconditional mean upper bound implies

`max |m_s| <= L^A/(sqrt(2)a) q^(-(L-s)/2)`.

Its squared geometric sum, including the initial mixture perturbation, is `O_a(L^(2A)/q)`. Thus a sufficiently large fixed polynomial lower bound on `q` makes the whole perturbation at most `epsilon`. The one-Lipschitz variance map then justifies the variance induction without assuming constant diagonals.

The signed mean grows by at least `sqrt(q)` per shifted layer and ends with margin at least `1/sqrt(2q)`. If `Q>=b b^T` and this is the signed margin of `b`, the output `b/(2t)` has margin `1/2` and readout rate at most `1/(8t²)=q/4`. This verifies the important readout constant, including the separate `L=2` case. The summed cost is at most `(q/2)(L+C log L)`.

## 2. Joint transport optimization

The inequality `(1+sqrt(2D))² <= (2+1/t)(D+t)` follows exactly from `D/t+2t>=2sqrt(2D)`. Arithmetic-geometric mean applies to the `L-1` nonnegative quantities consisting of the readout cost and the `L-2` shifted layer budgets. Dropping the nonnegative first-layer cost only enlarges their sum. The first-layer transport factor is at most `exp(2sqrt(2A/d))` because every original coordinate is relevant.

For `t=sqrt(q)` and `A<=(q/2)(L+C log L)`, direct factorization gives the upper bound

`4 q^(L-1) exp(1+C log L+(5/2)(L-2)/sqrt(q)+2sqrt(2A/d))`.

The stated `C'` form follows by absorbing the constant one into `log L` for `L>=2`. Thus there is no hidden exponential-in-`L` numerical constant in this comparison.

## 3. Interpolation and strict rate gap

The chosen odd `m` satisfies `m<=50n log M` for large `d`, and `m/M<=50 M^(-eta) log M ->0`. Hence enough coordinate columns exist for the existing oriented-majority lemma. Its actual failure bound obeys

`n exp(-m/(6n)) <= n/[4M²(n+1)²] <= 1/(16M²) <= 1/(2M)`.

The supplied first-feature entropy `D=dm` and signed mean `a=1/100` therefore meet the new amplification lemma. When `L=o(log d/loglog d)`, `log q>=log d/L` dominates `loglog d`, so `q` exceeds every required fixed power of `L`.

The lower-gap calculation is correct:

`log[d/q^(L-1)] >= eta log d/L - log(500000 log M)`.

The leading term dominates the logarithmic errors. Also `L/sqrt(q)->0`. For `L>=3`, the bound `q<=(10000d²)^(1/L)` makes `U/d->0` uniformly in this depth range; for `L=2`, use `m<=50d^(1-eta)log d`. Taking a sequence of paths approaching the infimum is legitimate: apply the first continuous budget bound, pass to its limit, and then increase the limiting budget to `U`.

For the quantitative range `L<=c eta log d/loglog d`, a universal sufficiently small `c` makes both the fixed-polynomial amplification requirement and the strict logarithmic comparison hold. The constants may require very large `d` depending on `eta`; no explicit numerical value of `c` is claimed.

## 4. Posterior and confidence conclusions

For each fixed `d,L,n`, there are only finitely many Boolean functions. Since every function retaining all original coordinates has rate strictly above the consistent competitor's rate ceiling, their minimum rate gap is positive. The finite-domain posterior rate principle therefore sends their total posterior mass to zero.

Every other Boolean function omits a full-parity coordinate and has exactly one-half error under uniform inputs. Arbitrary mixtures of these functions have the same Gibbs error. Thus posterior Gibbs error tends to `1/2`, without selecting a particular minimizer.

Writing `p_N(x)` for the posterior correct-label probability gives `E_x p_N(x)->1/2`. Since `Pr(p_N>=2/3)<=(3/2)E p_N`, the confidence-error mass has liminf at least `1/4`. The strict `<2/3` convention is respected. The theorem correctly fixes `d,L,n` before sending width to infinity.

The proved range is nearly logarithmic in ambient dimension. The result does not reach learner depths of order `log² d`, and it does not establish an exponential-in-teacher-depth sample lower bound.
