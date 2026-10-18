# Independent audit of finite-precision compilation of Boolean tanh teachers

The representation claim is correct: a width-C, depth-D tanh network with coefficients bounded by B >= 1 and signed output at least 1/2 on the entire d-dimensional Boolean cube has a layered Boolean majority circuit of depth O(D), and size and integer gate coefficients bounded by a polynomial in d,C,B,D with a universal degree. This is a circuit representation fact, not a polynomial sample-complexity theorem.

## Independent error calculation

Let delta=2^{-q}. Round every real coefficient to error at most delta, evaluate every hidden tanh to error at most delta, and clamp approximate hidden coordinates to [-1,1]. Clamping does not increase error. If E_s is the maximum error after hidden layer s, then

- E_1 <= (d+2) delta;
- E_s <= CB E_{s-1} + (C+1) delta;
- final linear-readout error <= CB E_{D-1} + C delta.

For example q=ceil(log_2(16 D(d+C+2)(CB+1)^D)) is sufficient for final output error below 1/8. The original 1/2 margin then makes the computed sign exact. This q is O(log(d+C+D) + D log(2CB)), so precision is polynomial even when the needed numerical accuracy is exponentially fine in D. The case D=1 is directly handled by rounded affine evaluation.

## Arithmetic and gate weights

Every rounded preactivation is a dyadic number with polynomial bit length and magnitude at most R=(d+C+1)(B+1). For dyadic t=a/2^b with |t|<=R, the degree m=ceil(40(R+q+2)) Taylor polynomial for exp(2t) has error below 2^{-q-4}. It is the exact rational U/V, where

V=2^{bm}m!,
U=sum_{k=0}^m (2a)^k 2^{b(m-k)} m!/k!.

All integers have polynomial bit length in b,R,q; signed cancellation is exact. The denominator in (U-V)/(U+V) is bounded below relative to V, because U/V is close to exp(2t)>=0. Rational division and rounding give a q-bit approximation to tanh(t). The Hesse–Allender–Barrington theorem supplies constant-depth polynomial-size majority circuits for iterated multiplication and division; addition, signed arithmetic, comparison and clamping are also in TC0. Fixed real parameters enter only as finitely many hardcoded advice bits.

The same fixed arithmetic constructions are used at every teacher layer. Their polynomial degree is universal. Stacking D copies multiplies circuit size by D and increases circuit depth by O(D); it does not raise the polynomial degree with D. Converting to a layered circuit by identity gates increases size by at most another polynomial factor.

Crucially, the construction uses majority/AND/OR/NOT arithmetic circuits. It does not interpret a p-bit number by putting weights 2^j directly on its bits. Majority gates have unit literal coefficients and polynomial thresholds. In the signed-input convention, double the integer score and use an odd threshold to avoid ties; coefficient magnitudes are still polynomial in fan-in, and the signed preactivation has absolute value at least one. Constant rails and identity gates preserve these properties. Thus all gate coefficient norms needed by the critical circuit-rate theorem are polynomial, rather than exponentially large in the required precision.

Reference: W. Hesse, E. Allender and D. A. Mix Barrington, “Uniform constant-depth threshold circuits for division and iterated multiplication,” JCSS 65(4), 695–716 (2002), DOI 10.1016/S0022-0000(02)00025-9. Only the nonuniform consequence of the arithmetic theorem is required.

## Frozen source status

The author's final source is pending review. The preceding independent derivation is not a claim to have reviewed an unseen version.

## Source review

The complete compiler and critical-rate corollary in `source/analog-teacher-circuit-rate.tex`, SHA256 `719f5f813543a3720b4477f12f43021027be89d368e4bc6f42ef9d855c3296ed`, have been independently read. All mathematical claims pass. This source uses the even simpler nonnegative Taylor argument t=2|u|, avoiding signed cancellation, and the conservative precision p=ceil((D+3)log_2 K0)+5 with K0=4(d+C+1)(B+1). The induction bound K0^{j+1}2^{-p} is valid, including optional biases and the final linear readout. Its final error is at most 1/(32K0^2)<1/16.

The arithmetic circuit size has one universal polynomial degree because the scalar construction is fixed, the intermediate integer bit lengths are polynomial in R and p, and D serial stages add size rather than multiplying polynomial degrees. Exact finite-precision signs at the final readout remain stable under the 1/2 teacher margin. Conversion from majority gates to signed unit-margin threshold gates gives polynomial Euclidean coefficient norms. The rate corollary follows from h=O(D+1), W and gate norms bounded by K^a, and therefore T=O((D+1)log(K+L)). A sufficiently large universal depth constant ensures both L-h>=L/2 and the existing steering condition. The stated fixed-budget depth is also valid by the preceding circuit-rate theorem's squared-logarithm comparison.

Only optional wording improvements were suggested to the author: omit undefined 'normalized' before the gate coefficient norm, clarify the half-integer threshold sentence, and explicitly identify parameter bits as nonuniform advice. No mathematical revision is required.

The three editorial clarifications were then applied and checked. Final frozen source SHA256 `3e61a6986b389a5288c7184013d7b4377f49a72ab5d96816c1ea3559a14be18f` is independently approved. This supersedes the earlier source hash for integration.
