# The exact-tanh depth barrier only needs polynomial coefficient bit length

26 October 2026. Supporting proof for the polynomial-bit coefficient and quantitative threshold-depth corollaries. Independently audited; not Lean verified.

## 1. Quantitative finite-description lemma

Let a tanh teacher on the Boolean cube have weighted depth `D >= 2`, hidden widths at most `C >= 1`, physical parameter magnitudes at most `B >= 1`, and signed linear output greater than `1/2` everywhere. Its Boolean function has a Boolean circuit of size polynomial in

`d + C + D + log(2+B)`.

There is no computability or precision assumption on its original real parameters. In particular, `B` itself may be exponentially large in polynomially bounded resources.

Here are explicit finite-precision bounds. Put

`m=max(d+1,C,2)`, `b=ceil(log_2(B+2))`, `q=ceil(log_2 m)`,

`p=(D+3)(b+q+4)+10`, and `rho=2^(-p)`.

Round every weight to a multiple of `rho`, within absolute error `rho`. Every rounded parameter uses at most `b+p+O(1)` bits. Evaluate affine forms exactly on dyadic hidden states, and round each tanh output to the `rho` grid in `[-1,1]` with absolute error at most `rho`. The initial input is exact. If `e_j` denotes maximum coordinate error, then

`e_j <= m B e_(j-1) + (m+1) rho <= A e_(j-1)+A rho`,

where `A=4m(B+1)`. The final linear layer obeys the same upper bound. The rounded hidden states remain bounded by one, so no bound on a perturbed state is being assumed. Consequently

`e_D <= 2 rho A^D < 1/16`.

Indeed `log_2 A <= b+q+2`, and the displayed choice of `p` has ample slack. All output signs are preserved. Exact intermediate affine forms have at most `O(b+q+p)` integer and fractional bits: their common denominator is `2^(2p)` and their magnitude is at most `m(B+1)`.

### Saturation-aware evaluation

For any such dyadic preactivation `u`, first inspect its sign and compare its absolute value with `p+10`. This comparison takes polynomially many Boolean gates in `b+q+p`. If `|u| >= p+10`, use the corresponding value `+1` or `-1`. Its error is at most

`2 exp(-2(p+10)) < rho`.

Otherwise use oddness and assume `0 <= u <= p+10`. Put

`J=ceil(16(p+10)^2)` and `E_J=sum_(k=0)^J (2u)^k/k!`.

The exponential-series tail is at most

`exp(2u) (2e u/(J+1))^(J+1) < 2^(-p-4)`.

The factorial bound and `J >= 16(p+10)^2` prove the final inequality uniformly for the displayed `p`; one may also use the geometric tail after the first omitted term. Compute `(E_J-1)/(E_J+1)` and round it to the nearest `rho`-grid point, clipped to `[-1,1]`. The final rounding error is at most `rho/2`. Because `E_J >= 1`, the derivative of this quotient as a function of `E_J` is at most `1/2`, so the exponential approximation plus final rounding gives error less than `rho`.

If the input has denominator `2^(2p)`, all terms can be put over the common denominator `2^(2pJ) J!`. This denominator and the numerators have `O(p^3+p^2 log p)` bits. Grade-school arithmetic evaluates the whole truncated series and quotient in polynomial time and therefore by a polynomial-size Boolean circuit. Saturation is essential: the computation never attempts a Taylor expansion on a range of length `B`.

For example, a conservative bound is

`O((C(d+1)+D(C+1)^2) (b+q+p+1)^10)`

Boolean gates, after enlarging one universal constant. The precise exponent is not needed. The approximation algorithm is uniform on the rounded parameter strings; the strings themselves may be chosen nonuniformly from the original real teacher.

## 2. Strengthened stretched-exponential sample barrier

Fix positive constants `alpha,c,b0` and fixed accuracy/confidence parameters in `(0,1)`. Suppose targets `f_j` have exact-tanh teachers of the same weighted depths `L_j -> infinity` as their learners, hidden widths `C_j`, coefficient bounds `B_j >= 1`, global signed margin greater than `1/2`, and

`d_j + C_j + log(2+B_j) <= L_j^b0`.

Suppose that at some actual realizable widths `N_j` and canonical prefactors `0<t_j<=1`, the original globally margined, exact-fit posterior requires at least `exp(c L_j^alpha)` examples for the fixed distribution-free confidence guarantee. The same hypothesis can instead concern the guarantee uniform over all realizable widths or any specified width range containing these counterexamples. Then

`P/poly != nonuniform NC`.

Proof: sample consistency on a domain of `2^d_j` points supplies the universal `O(2^d_j)` sample upper bound at the fixed accuracy and confidence. Hence `d_j >= (c/log 2)L_j^alpha-O(1)` and `L_j=O(d_j^(1/alpha))`. The finite-description lemma above gives circuits of size polynomial in `d_j`, since the teacher width and coefficient bit length are polynomial in `L_j`. Pass to distinct increasing input dimensions and complete this subsequence by constants to obtain a family `F` in `P/poly`.

If `F` belonged to some fixed nonuniform `NC^k`, the selected targets would have Boolean circuits of polynomial size in `d_j` and depth `O(log^k d_j)`. The published uniform-scale threshold-target learning theorem then applies at the same `L_j,N_j,t_j`: its depth requirement is eventually satisfied, and it needs only

`exp(O(log^(k+1) L_j)) = exp(o(L_j^alpha))`

examples. This contradicts the assumed lower bound. The upper theorem holds at every realizable width, so no bound `N_j >= B_j` or bounded-weight-width admissibility convention is required here.

## 3. Scope

This is a strengthening of the conditional barrier, not a learning upper bound for arbitrary teachers and not a proof of either circuit-class separation. It shows that very large teacher coefficients with polynomially many relevant bits do not evade the barrier. Infinite-precision coefficients also do not evade it when their magnitudes satisfy the displayed bound, because the global output margin allows rounding.

It is distinct from the engineered analytic-activation counterexample. The latter encodes hard tables in the activation itself, whose high-precision evaluation is not known to have polynomial-size circuits. Exact tanh has the saturation-aware polynomial-time evaluator proved above. Merely making the coefficients of a tanh teacher large does not replicate that activation-level lookup mechanism.

## 3a. Quantitative threshold-depth obstruction

Under the sample-lower-bound hypotheses of Section 2, suppose additionally `0<alpha<=1`. Fix any `a>0`. Every real threshold implementation of a selected target with width at most `L_j^a` must have depth

`h_j >= c_a L_j^alpha/log(L_j+2)`

for all sufficiently large j, where `c_a>0` depends on the fixed lower-bound constant, resource exponents, and accuracy/confidence parameters. No bound on the threshold implementation's original coefficient magnitudes is required.

To prove this, it suffices to consider `h_j<=L_j`; otherwise the conclusion is immediate. The weight-independent real-threshold compiler and the existing uniform-scale target upper give universal constants (with the statistical parameters fixed) such that the sufficient sample count is at most

`exp(C(h_j+1) log R_j)` provided `L_j>=C(h_j+1)log R_j`,

where `R_j=d_j+L_j^a+h_j+L_j+2`, after changing the universal C to absorb the polynomial compiler overhead. Thus `log R_j <= B_a log(L_j+2)`. If `h_j+1<=kappa L_j^alpha/log(L_j+2)`, choosing

`kappa <= min(1,c)/(2 C B_a)`

makes the padding condition hold, since `L_j^alpha<=L_j`, while the sample upper is at most `exp(c L_j^alpha/2)`. This contradicts the assumed lower. Since `L_j^alpha/log(L_j+2)` tends to infinity, the additive one in `h_j+1` can be absorbed by decreasing `c_a`.

In particular an exponential-in-depth lower bound would require threshold depth `Omega(L/log L)` at every fixed polynomial width. This quantitative necessary condition is stronger than merely saying that the family is outside every fixed polylogarithmic-depth class. It remains a conditional implication, not a theorem that such a hard target exists.
