# Uniform intrinsic learning after subtracting the scalar baseline

Supporting proof, 24 October 2026; curated 25 October 2026. Conventionally reviewed, not Lean verified. The current all-scale statements are in the companion `uniform-target-classes.pdf`; the package README gives the dependency map.

## Theorem

Use the original Gaussian variances t^2/d, t^2/N, t^2/N^2, with any 0<t<=1, H=L-1>=1, global strict output-margin conditioning, and exact noiseless training labels. At a realizable width let

    a_N=-(1/N) log mu_(N,t)(A_(N,f)),
    b_t=t^(-2)-1,
    c_t=(b_t-log(1+b_t))/2,
    B=a_N+4/(H t^2),
    E=(B-H c_t-V_*+b_t)_+,
    J=min{sqrt(H E), E/b_t}.

When b_t=0, define J=sqrt(H E). Here V_* is the same critical scalar baseline in the existing paper. There are universal constants C,c such that the sufficient sample bound

    n >= C/epsilon * {
       [(d+L+t^2 a_N+2)(1+log(1/epsilon))]^c exp(C J)
       +log(1/delta)
    }

ensures that the correct-label posterior probability is strictly greater than 2/3 outside a set of test-distribution mass at most epsilon, with training probability at least 1-delta. This holds at every actual realizable width and uniformly over all 0<t<=1. Width enters only through the actual normalized raw target cost a_N.

## Inputs already checked

1. `finite-width-dual-certificate.md`: a bounded box of exponential-family parameters supplies approximate feature moments at action cost A+tau. Its width requirement is logarithmic in inverse moment tolerance. The argument works for arbitrary positive tau, as recorded in `uniform-scale-intrinsic.md`.
2. `uniform-scale-intrinsic.md`: exact entropy inflation and scale-sensitive importance quadrature approximate a controlled path by an ordinary network of the same depth. For any exact path with total action A, its width depends polynomially on d,H,1+t^2 A and its full gain product, with universal degree.
3. `uniform-baseline-gain.md`: if the path has output margin 1/2 at even one witness input, then its logarithmic full gain is at most

       C log(H+2)+C min{sqrt(H E_A), E_A/b_t},
       E_A=(A-Hc_t-V_*+b_t)_+.

   The one-input reduction uses its original normalized input variance in [1,2], so it applies on every nonempty finite witness. The proof has been independently audited by the critical-depth and complexity-barrier agents.

## Population representation bound

For completeness, let R(D)>=1 solve R-1-log R=2D and put alpha_j=t sqrt(R(D_j)). The true feature variances are bounded by q*_j=2 product_(i<=j) alpha_i^2. The normalized importance proof has width polynomial in d,H,1+t^2A and max(1,product alpha_j), and output error at most 3/32.

Its improvements over ordinary bounded-feature quadrature are important: the anchor conditional-entropy threshold is proportional to R(D_j), so the total anchor count uses sum D_j/R(D_j)<=H/2; the Gaussian maximum moment divided by R(D_j) is O(d+1), so arbitrarily small intermediate variances cause no sampling penalty. The final readout Hilbert norm is sqrt(2t^2r), hence only t^2A appears.

Applying the gain lemma therefore gives a same-depth finite representation of all signs on a globally margined witness, with width

    poly(d,H,1+t^2A) exp(C J_A).

The compression itself approximates arbitrary outputs and needs no initial margin until this sign conclusion.

## Finite-width witness reconstruction with negligible margin repair

Take any m-input witness Z and any raw event E0 of probability at least exp(-N A0), on which every output on Z has absolute margin at least 1/2. Write

    eta0=1/(H t^2).

The bounded-dual certificate with slack eta0 produces an approximate controlled path of action at most A0+eta0. To make it consistent, transfer controls recursively by the full Gaussian coupling argument. This does not increase hidden entropy, and has exact one-layer amplification alpha_j.

A deliberately coarse bound is sufficient to choose the required moment tolerance. Since R(D)<=C(1+D),

    alpha_j <= sqrt(C(1+t^2(A0+eta0))).

If moments are accurate entrywise to Delta, then each covariance coupling contributes at most m sqrt(Delta), so the final Gaussian coupling error is at most Hm sqrt(Delta) times the Hth power of that coarse factor. Choose Delta to make the transferred output error at most

    rho=1/[1000 H(1+t^2(A0+eta0))].

Its inverse logarithm is only

    O[H log(2+t^2A0)+log(H+m+2)].

The transferred outputs have signed margin at least 1/2-rho. Multiply the readout by (1-2rho)^(-1). This restores margin at least 1/2 and increases action by at most

    8rho(A0+eta0) <= 1/(100 Ht^2).

Thus the exact margined path has action at most A0+2eta0. This is a vanishing relative repair; a constant output rescaling would destroy the scalar-baseline cancellation and is not used.

The dual certificate's arbitrary-slack threshold uses 1/eta0=Ht^2<=H and A0/eta0=Ht^2A0. Consequently the width needed for this exponentially accurate transfer is a universal polynomial in m,H,1+t^2A0. In particular, it does not pay an exponential factor in H or any inverse power of t. A coarse propagation bound may be exponentially large; only its logarithm enters the dual grid.

Apply the sharp population representation bound to the repaired exact path. The initial margin is now exactly the one used to define V_*, so the baseline is preserved.

## Exceptional mass and posterior learning

At the true target cost a_N, use A0=a_N+eta0. The preceding exact path then has action at most a_N+3eta0<=B, and its representation width is at most a universal polynomial in

    K=d+H+1+t^2a_N

times exp(CJ), with J as in the theorem.

Take witness size one more than the polynomial VC bound for this representing class. The finite-witness argument from the current critical paper supplies a sample-independent class G of polynomial VC dimension. For N above a polynomial in K and exp(CJ), raw globally margined mass outside G is at most

    exp(d m log2-N A0).

Dividing by the target mass exp(-N a_N) gives exceptional posterior mass

    <=exp(d m log2-N/(H t^2)).

A width polynomial in K,exp(CJ),log(1/epsilon) makes this at most epsilon/6, uniformly in t. A consistency union bound over the finite-cube traces of G controls all supported functions in G, and therefore the posterior Gibbs error. The standard Markov step converts Gibbs error epsilon/3 to the stated strict posterior-confidence criterion.

All smaller widths are bounded by that same polynomial. The whole class of their depth-L tanh sign networks has polynomial VC dimension, so the same sample form controls its entire posterior support. This completes the every-width theorem.

## Endpoint checks

At t=1, b_t=c_t=0 and B=a_N+4/H. Thus J is at most sqrt(H(a_N-V_*)_+)+2. The theorem recovers the current critical intrinsic sample dependence, up to universal constants and H versus L.

As t tends to zero with t^2a_N approximately kappa/2, the linear term E/b_t tends to

    (kappa-H)/2+1+4/H

up to the positive-part convention. The bound therefore has the expected polynomial dependence on normalized energy and exponential dependence on excess above the depth baseline. It agrees with the energy/product-norm picture in the strong-prior regime.

## Target-mass consequence

Suppose a finite-width target construction supplies, for S>=1+log(H+2),

    a_(N,t)(f) <= Hc_t+V_*+C[b_t S+S^2/H]

at every N above exp(CS), with the width threshold and constants uniform in t. Then E<=C'[b_t S+S^2/H], since the extra b_t and 4/(Ht^2)=4(1+b_t)/H are absorbed by those terms. If b_t>=S/H, use E/b_t=O(S); otherwise use sqrt(H E)=O(S). Hence J=O(S).

The theorem then gives sample dependence exp(O(S)) times polynomial statistical factors at every realizable width, uniformly over all 0<t<=1. For a fixed-depth threshold teacher, S=O(log resources), so this is jointly polynomial in learner depth and the remaining resources, uniformly over all original good Gaussian prefactors. For polylog-depth Boolean circuits it is exp(polylog resources), enough for the strengthened P/poly-versus-NC barrier against exponential-in-depth counterexamples.

The target-mass estimate is provided in `nearcritical-target-reuse.md` and the companion structured-target manuscript. This consequence concerns fixed or controlled threshold depth; it does not identify polynomial-size arbitrary deep circuits with polynomial sample complexity.
