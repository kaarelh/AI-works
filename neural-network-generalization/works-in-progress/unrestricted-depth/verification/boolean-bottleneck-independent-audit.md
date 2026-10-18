# Independent audit of the finite-state Boolean bottleneck theorem

Date: 18 October 2026. Auditor: independent research agent `depth_counter_audit`.

## Verdict and scope

The mathematical arguments in Sections 3 and 5 of `boolean-transfer.md` are sound with the qualifications below. They yield polynomial sample complexity for the original globally margined Boolean Gaussian posterior, with no added restriction on the prior support, at every admissible learner width, in the strong-prior regime and for each fixed exponent gap `gamma >= 1 + zeta`, `zeta > 0`.

The first-layer theorem requires tanh, or another injective scalar activation, at that layer. The current draft's phrase “any feedforward network” should state this explicitly. The fixed-prefix theorem requires the prefix depth `j` to be a fixed constant: both the degree of its polynomial and the depth of the simulating threshold circuit can depend on `j`. Neither argument presently proves the corresponding critical mean-field statement at `gamma = 1`.

This report audits the new reduction and its interface with the existing unrestricted-depth learning theorem. It is an independent mathematical check, not Lean verification. A frozen-manuscript hash can be appended after the source is assembled.

## 1. A finite first-layer state set

Let the first hidden state be `h(x) = tanh(A(1,x))` with `C` coordinates and at most `K` attainable vectors on the Boolean cube. Each attainable scalar coordinate corresponds to a unique preactivation because tanh is injective. An interval with endpoints strictly between successive attainable preactivations isolates that coordinate exactly on the cube. There are at most two affine threshold tests per coordinate. Their conjunction recognizes one attainable vector, and a disjunction over positive vectors computes the target.

This gives depth three and `O(K C (d+1))` wires, including constant wires. The intervals need not have quantitatively large gaps. Their endpoints and the original affine coefficients may be arbitrary real numbers. Constant predicates handle extreme intervals and constant targets. The target label is well-defined on the state set because its remaining computation is deterministic.

The existing coefficient-independent threshold-to-majority construction therefore applies. It produces a polynomial-size, bounded-weight tanh implementation at fixed intrinsic depth at most six. This is exactly the hypothesis needed by the existing fixed-intrinsic-depth learning theorem; no precision bound or stability bound on the original suffix has been smuggled into the deduction.

The draft's lattice and repeated-column examples are correct. In particular, common denominator `Q` yields a dependence on the numerical value of `Q`, not its bit length. A fixed affine bias only translates the possible preactivation values and does not increase their number.

## 2. Opposite-label separation after a fixed prefix

Write `D` for teacher depth, `L` for learner depth, and fix a prefix depth `j < D`. The teacher's hidden width is at most `C`, all physical weights have absolute value at most `B >= 1`, and the output has signed margin at least `1/2`.

In the infinity norm a width-`C` affine map followed by tanh has Lipschitz constant at most `C B`; the final readout has the same bound. Consequently the suffix from state `h^j` has Lipschitz constant at most `(C B)^(D-j)`. Opposite target labels have real outputs separated by at least one. Their attained prefix states are therefore separated by at least

`Delta = (C B)^(-(D-j))`.

Choose `eta = 2^(-p)` with `8 eta < Delta`. One can take `p = O(1 + D log(2 C B))`. This is a polynomial number of bits even though `Delta` can be exponentially small in teacher depth. No lower bound is needed for distances between states with the same label.

## 3. Fixed-depth tanh evaluation by threshold circuits

Rounded weights and activation values suffice. If weights are rounded with absolute error at most `2^(-q)` and each tanh evaluation has absolute error at most `2^(-q)`, clamping intermediate approximations to `[-1,1]` cannot increase their error. A first-layer error estimate is `(d+2) 2^(-q)`. At each subsequent hidden layer an error `e` becomes at most

`C B e + (C+1) 2^(-q)`.

Thus `q = p + O_j(log((d+C+2)(B+1)))` gives final prefix error at most `eta`. The number of rounded parameters and their total bit length are polynomial in `d,C,p,log(B+1)` for fixed `j`. They are nonuniform advice: the argument does not claim an efficient way to discover or recover them from the original real parameters.

Here is an explicit way to avoid an unproved real-arithmetic gate. For a dyadic preactivation `t = a / 2^q`, `|t| <= R`, use a Taylor polynomial for `exp(2t)`. Put `r = 2R`. If `n = m+1 >= 10(r+p+5)`, then the remainder obeys

`exp(r) r^n/n! <= exp(r) (e r/n)^n <= exp(r-n) < 2^(-p-4)`.

The middle inequality uses `n! >= (n/e)^n` and `e/10 < e^(-1)`. The case `r=0` is immediate. The degree is `O(R+p+1)`.

All Taylor terms can be combined over the exact common denominator `2^(q m) m!` (replace `a` by `2a` for `exp(2t)`). Term numerators involve powers and integer factors of polynomial bit length `O(m(q + log(R+1) + log(m+1)))`. Polynomially many iterated multiplications, signed additions, and one division evaluate the polynomial to the desired precision in constant threshold depth. In particular, the powers are computed in parallel, not through a sequential chain of `m` multiplications. The factorial factors can also simply be hardcoded in this nonuniform construction.

If `E` is the resulting exact rational exponential approximation, then `E >= -1/4`, so `E+1 >= 3/4`. The map `(E-1)/(E+1)` has derivative at most `32/9 < 4` on this domain. The exponential error and a constant number of guard bits therefore give a tanh approximation with the required error. Negative arguments and cancellation in the Taylor numerator cause no loss because these integer calculations are exact before the final rounding.

The preactivation range is polynomial in `d,C,B`; hence the subcircuit size is polynomial in these parameters and `p`. Composing only the fixed number `j` of stages preserves constant depth. No assertion of constant depth for a growing number of stages is justified or used.

One optional improvement is to clip preactivations outside `[-(p+3),p+3]` before Taylor evaluation and use saturated signs there. That would allow dependence on `log B` instead of `B` in the arithmetic portion. It is unnecessary for the stated polynomial-in-`B` theorem and is not part of this audit's claimed result.

## 4. Lookup of the attained states

For each of the at most `K` attained prefix states `v`, hardcode a dyadic center `v_hat` with infinity error at most `eta` and its label. Let `h_hat(x)` be the approximate prefix with the same error bound. Output positive exactly when some positive center is within `3 eta` of `h_hat(x)` in every coordinate.

If the actual state is positive, its own center is within `2 eta`. If it is negative, every positive state is at least `Delta` away, so its positive centers are at least `Delta-2 eta > 6 eta` away from `h_hat(x)`. The output is therefore exactly correct. Subtraction and integer comparison, an AND over coordinates, and an OR over the at most `K` centers are all constant-depth polynomial-size threshold operations.

There is no enumeration of the entire `p`-bit state grid. Only the `K` attained centers are needed; this distinction is essential to the polynomial-size conclusion.

## 5. Transfer to learning and quantifiers

The resulting target has a threshold circuit of polynomial size in `d,C,B,K,D`, at constant depth depending on the fixed `j`. The repository's `unrestricted-primary-threshold-circuits.tex`, Corollary `threshold-circuit-learning`, then supplies a polynomial sample guarantee for learner depths at least the fixed compiled depth, simultaneously at every width `N >= C_L(f)` and every `0 < sigma^2 <= N^(-(1+zeta))`, for fixed `zeta > 0`.

It is correct to extend this to every learner depth `L >= D` by a bounded-depth fallback: if `D` is smaller than that fixed compiled-depth threshold, the original teacher itself has depth bounded by a constant depending only on `j`. Double its readout to give unit margin and apply the existing fixed-intrinsic-depth theorem. There are only finitely many such depths; take the maximum of their polynomial bounds. This does not identify the teacher's width with `C_L(f)`; the existing learning theorem handles actual admissible smaller learner widths separately.

The strong-prior assertion follows by fixing any gap, for example `zeta=1`, and then letting the prior scale tend to zero. No uniform assertion as `zeta` tends to zero, and no `gamma=1` theorem, follows from this transfer.

The fixed-prefix statement removes exponential dependence on the teacher's suffix depth. It does not remove every dependence on that depth: the required precision, hence the polynomial circuit size, still depends on `D`. The first-layer exact threshold-lookup statement is stronger in this respect and need not depend on the suffix at all.

## 6. External arithmetic reference, checked

William Hesse, Eric Allender, and David A. Mix Barrington, “Uniform constant-depth threshold circuits for division and iterated multiplication,” *Journal of Computer and System Sciences* 65(4), 695–716 (2002), DOI [10.1016/S0022-0000(02)00025-9](https://doi.org/10.1016/S0022-0000(02)00025-9). [Author PDF](https://www.cs.rutgers.edu/~allender/papers/division.pdf).

The paper proves DLOGTIME-uniform TC0 integer division and iterated multiplication. Corollary 6.3 states the corresponding FOM result, and Corollary 6.5 develops power-series approximations in the same framework. Only the integer arithmetic theorem is needed above; the analytic approximation and rational bit-length bounds have been supplied explicitly. The nonuniform theorem needed here is weaker than the stated uniform result.

There is a 2014 corrigendum, JCSS 80(2), 496–497, DOI [10.1016/j.jcss.2013.09.002](https://doi.org/10.1016/j.jcss.2013.09.002). Its stated correction concerns part of the proof-theoretic Corollary 6.6, not the division or iterated-multiplication theorem used here. The existence of that corrigendum therefore does not invalidate this use of the reference.

## 7. Frozen source review

I read the complete proposed source `unrestricted-primary-finite-bottleneck.tex`, SHA256 `8dc2b4caf78cf04fde9bed83d01b45c3a35c23e9f854d1a0a935ec3e735c9a9e`.

The proof passes. Its larger Taylor degree `ceil(40(R+p+2))` comfortably implies the error estimate above; its explicit prefix rounding precision bounds the error recurrence; its `eta <= 1/(32S)` supplies the claimed lookup gap; and the all-`L >= D` fallback keeps every intrinsic depth in the exceptional case bounded solely in terms of fixed `j`.

The additional covering-number observation is also valid: if attained states are covered by `K` balls of radius `eta` centered at attained states, a positive input is within `3 eta` of its rounded center after evaluation error, whereas a negative input is at least `30 eta` from a positive rounded center. Lookup radius `4 eta` therefore works. The cover radius depends on the suffix and may be exponentially small, so the paragraph does not establish that arbitrary teachers have polynomial-size covers.

One editorial correction was requested: the section heading should say that the general theorem removes *exponential* teacher-depth dependence, since the fixed-prefix theorem still has polynomial dependence on `D`. The first-layer proposition itself is independent of suffix depth. No mathematical corrections to this frozen source were needed.

The author made only that title change, to “Finite hidden-state bottlenecks give polynomial depth bounds.” Final reviewed SHA256: `15d033cbbad9a1fcc00e1b7055ed09e6942e14ede636dc1681544b45d306134c`. This is the source approved by this audit.
