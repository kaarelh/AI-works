# Depth lower bounds with subexponential teacher resources

26 October 2026. A quantitative extension of the established exact-tanh circuit-complexity implication. No new statistical lower bound is proved. All circuit classes below are nonuniform.

## Setup and imported upper

Let L_j tend to infinity. The target f_j on d_j Boolean inputs has an exact-tanh teacher with signed output margin greater than 1/2 everywhere at depth L_j, hidden widths at most C_j, and real coefficients of magnitude at most B_j. Put

    R_j=d_j+C_j+L_j+log(2+B_j)+4.

The original coefficients may be arbitrary real numbers. The saturation-aware finite-description lemma gives an exact Boolean circuit for f_j of size polynomial in R_j, with one universal polynomial degree. Only the fixed positive output margin is used; the original coefficients need not be computable.

Assume the original canonical learner at the same depth L_j has an actual sample lower bound exp(c L_j^alpha), for some fixed c,alpha>0 and fixed accuracy/confidence constants in (0,1). The adversary may choose the actual finite realizable width N_j, canonical prefactor 0<t_j<=1, and common input distribution. Global absolute-margin conditioning and exact noiseless labels are retained. A lower bound for ordinary majority prediction also suffices, since the imported positive theorem supplies the stronger >2/3 confidence conclusion.

The imported uniform target theorem says that a target with threshold depth h and threshold width W has sufficient sample count

    exp[C(h+1)log(d+W+h+L+2)]

when L>=C(h+1)log(d+W+h+L+2), at every actual realizable learner width and every canonical prefactor. There is no coefficient-size assumption on the original threshold circuit: the established weight-independent compiler replaces arbitrary real threshold gates by polynomial-width, polynomial-coefficient threshold circuits with constant depth overhead. See `critical-depth/source/critical-all-width-target-learning.tex`, Corollary `cor:critical-all-width-real-threshold-learning`, and the uniform-scale extension in `boolean-depth-barriers/source/uniform-target-classes.tex`. For standard TC0 circuits one can simply use ordinary majority gates, whose coefficients and margins already meet these requirements. The short-padding part also gives a polynomial resource bound at any fixed h as soon as L>=h+1.

## Complexity-only padding

Choose a subsequence for which M_j=ceil(R_j) is strictly increasing. Define a family F_M on M input bits as follows: at M=M_j, ignore the M_j-d_j dummy inputs and apply f_j to the first d_j inputs; at other lengths output a fixed constant. Since the finite-description circuits have size polynomial in M_j, this family belongs to P/poly.

This operation pads only the family used in the circuit-complexity argument. It does not change the Bayesian learner's input dimension, Gaussian covariance, depth, width, scale, or input law. An alternative circuit for F_(M_j) can have its dummy inputs fixed to constants, leaving a circuit for f_j on its original inputs. Constants are charged as ordinary wires in the target compiler.

## Constant-depth consequence

For 0<alpha<=1, suppose

    log R_j=o(L_j^alpha).

Then the proposed lower bound implies

    P/poly != TC0.

Indeed, if the padded family were in TC0, it would have one fixed majority depth h and a polynomial size bound M^a. Fixing dummy inputs gives constant-depth threshold implementations of f_j with resources polynomial in R_j. The uniform target theorem then gives sample count R_j^{O(1)}=exp(o(L_j^alpha)) at the exact original learner architecture and distribution. Its long-padding condition holds because log R_j=o(L_j); alternatively its fixed-depth short-padding theorem applies directly. This contradicts the assumed lower bound. Thus the constructed P/poly family lies outside TC0.

In particular, an exponential-in-depth lower bound whose entire teacher resource R is exp(o(L)) would imply this circuit separation. Polynomial-in-L resource bounds are unnecessary for this weaker conclusion.

## Full parallel-circuit consequence

Suppose instead that

    log R_j=L_j^{o(1)},

meaning that log R_j is eventually bounded by L_j^eta for every fixed eta>0. For any fixed alpha>0, the proposed exp(c L_j^alpha) sample lower implies

    P/poly != NC.

If the padded P/poly family belonged to NC^k, it would have size M^{O(1)} and Boolean depth O(log^k M), for one fixed k. Restricting the dummy bits and applying the target upper yields sufficient samples

    exp[O(log^(k+1) R_j)]=exp(L_j^{o(1)}).

The required learner-depth padding holds because log^(k+1)R_j=o(L_j). The upper is smaller than exp(c L_j^alpha), contradicting the same lower-bound instance. Hence the padded family lies outside every fixed NC^k.

This includes all polynomial and quasipolynomial teacher resources in L. It is a logical consequence of the proved positive theorem, not an assertion that circuit methods are the only possible way to prove the negative result.

## Limits

The TC0 conclusion does not become an NC conclusion merely from R=exp(o(L)); powers of log R can still exceed L. Conversely, this note does not rule out an exponential depth lower bound or prove any complexity separation unconditionally. The same-width completion is essential: sufficiently large widths use the target witness, while smaller realizable widths use the complete finite-width class. No requirement that the alternative threshold circuit fit that actual learner width is introduced.
