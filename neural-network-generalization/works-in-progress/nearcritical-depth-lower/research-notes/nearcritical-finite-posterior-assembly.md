# Quantified nearcritical finite-width posterior flattening

25 October 2026. Research assembly for fresh independent audit. The parameter is t=1+epsilon>1; the activation is ordinary tanh. This improves the previously established epsilon^-50 depth overhead. It does not address the exact canonical t<=1 question.

## 1. The theorem and exact conventions

There are absolute constants epsilon0>0, A,K,c>0 and an integer d0>=1 with the following property. For every d>=d0 and 0<epsilon<=epsilon0, put

    D=d+1+log(1/epsilon),
    B0=1+epsilon^2 D,
    H=ceil[K(epsilon^-4+epsilon^-2 D)]=ceil(K epsilon^-4 B0),
    N=ceil exp(A D),
    m=2^d,   t=1+epsilon.

Consider H hidden tanh layers, each of width N, augmented cube input (1,x), no internal biases, and a linear readout. All weights are independent centered Gaussians, with variances

    t^2/d in the first hidden layer,
    t^2/N in every subsequent hidden layer,
    t^2/N^2 in the readout.

For every Boolean truth table f on the cube, let

    w_f=Pr{f(x)z(x)>1/2 for every cube input x}.

Then

    max_f w_f/min_f w_f <=1+exp(-cD).                  (1)

Consequently, after conditioning on |z(x)|>1/2 at every cube input and on any consistent training labels, the posterior probability of either label at every unseen input belongs to

    [1/(2+rho),(1+rho)/(2+rho)],   rho=exp(-cD).       (2)

For the >2/3 confidence criterion, every unseen point is therefore counted as an error after increasing d0 if necessary. Under the uniform cube distribution, confidence error is at least 1-n/2^d after n distinct labeled examples. Reducing this error below one half requires n>2^(d-1). This holds even for the constant target, which has width two and bounded weights at every depth.

When D>=epsilon^-2, H=Theta(epsilon^-2D). In the regime d>=C epsilon^-2, one has D=Theta(d), so the sample lower bound is exp(Omega(epsilon^2 H)). The additional epsilon^-4 term is retained when D is smaller. No sharp epsilon^-2D result is asserted uniformly in that smaller-D regime. The width is polynomial in epsilon^-1 times exp(O(d)), rather than exp(O(d/epsilon^2)). The theorem is at these specified widths, not all larger widths, and is not a deterministic-majority lower bound at the exact 1/2 threshold.

## 2. Exact covariance chains and gauge couplings

The empirical Gram chain has initial matrix

    Q0(x,y)=(1+x.y)/d.

Given Q, choose a factor R with RR^T=Q. If G is an m-by-N array of independent standard Gaussians, the next empirical Gram is exactly

    Q_new=(1/N)tanh(t R G)tanh(t R G)^T.               (3)

This is the actual finite-width conditional law, including singular Q and the first layer; only its Gaussian pushforward covariance is relevant. Gauge f replaces Q0 by D_f Q0 D_f. Oddness of tanh makes w_f the all-positive-margin probability for this gauged chain.

Write Q=diag(sqrt(q)) C diag(sqrt(q)), where C is a correlation matrix. Every diagonal q_i is positive on the quality events; initially q_i=(d+1)/d<=2, and afterwards q_i<=1. Define the joint distance

    Dist((C,q),(C',p))^2
       =d_B(C,C')^2+sum_i log(q_i/p_i)^2,             (4)

with unnormalized covariance Bures distance. For the two gauged initial states, the diagonal term is zero and Dist_0<=C sqrt(m).

At every step use the same fresh standard Gaussian array for the two paths. Outside a common local white ball choose optimal Bures factors of their correlation matrices. Inside the common local ball choose their canonical correlation square roots. Multiply their rows by sqrt(q_i) or sqrt(p_i) for the physical preactivation covariance. Each factor choice depends only on the coupled past, so both marginals are exact chains of the form (3). Measurable choices exist by the finite-dimensional Procrustes minimization; no invertibility of the hidden coupling is required.

## 3. One uniform empirical quality, with constants uniform near criticality

There are constants C,c,v0>0, uniform for 1<t<=1+epsilon0, and a measurable rotation-invariant array quality V with

    tau=C m^4 log(eN)/N,
    V>=tau,
    Pr{V>tau+s}<=C exp(-cNs),    s>=0.                (5)

Take an arbitrarily small fixed inflation of the infimum-based quality, or replace it by twice that infimum plus tau, to avoid endpoint issues. All subsequent constants absorb this change. Independent arrays yield independent qualities. Set zeta(v)=sqrt(v)+v.

The quality controls, uniformly over all factors, scales and direction choices:

* scalar logarithmic error |log(q_new/T(q))|<=C zeta(v), with T(q)=E tanh²(t sqrt(q)Z);
* pair-gap loss exp[-C zeta(v)] relative to the free gap at small quality, and relative to the entering gap at large quality;
* normalized covariance error ||C_new-C_free||op<=C lambda_max(C) zeta(v) at small quality, and lambda_max(C_new)<=exp(C zeta(v))lambda_max(C) at large quality;
* global joint-metric log gain at most C qmax²+C zeta(v), where qmax is the largest entering variance of either path;
* local joint-metric log gain at most -c epsilon²+C zeta(v), whenever both correlation matrices lie in a sufficiently small fixed operator ball about I and all variances lie in [a epsilon,b epsilon], for fixed positive a,b.

The last inequality uses the local coupling only at small fixed absolute quality. At larger quality the global bound suffices, since the missing epsilon² decrement is paid by C zeta(v).

These are empirical statements, not assumptions restricting network support. Their proofs are in `nearcritical-pair-square-root-quality.md`, `nearcritical-normalized-empirical-quality.md`, and `nearcritical-normalized-coupling.md`, with the large-quality strip argument inherited from the earlier scalar/pair note. The crucial refinements are as follows.

The population normalized feature has Hermite expansion phi_q=sum a_k(q)H_k, with sum a_k²=1, sum k a_k²=1+O(q²), ||partial_q phi_q||L2<=C, and 1-a_1(q)²=Theta(q²). The exact row coupling identity splits coefficient differences from angular differences, giving global gain 1+Cqmax² without a radial cross term. On a fixed white operator ball, the k=1 Hermite term contracts by 1-c epsilon²; Hadamard powers k>=3 have an additional small operator-radius factor. Independent optimal factors for the Hermite components give population local contraction even with unequal variances. Only the empirical error uses canonical-root comparison, so no fixed norm-equivalence constant destroys this nearidentity contraction.

For empirical pair lower bounds, the compactified two-tanh secant family has uniform fourth moments. A negative-MGF lower-tail inequality and an explicit parameter net give PSD lower loss C sqrt(v); no false positive-MGF claim for cubic limits is used. For normalized mixed empirical errors, angular and log-radial derivatives have direct linear Gaussian envelopes. Products are subexponential; compact cutoff nets and path integration give the global estimates. Local covariance derivatives are handled with Frobenius-dual products of dimension-free subGaussian vector norms. Empirical diagonal normalization preserves the derivative error. These classes have O(m²) parameters; the retained m^4 threshold covers them and the all-quality rare-strip estimates.

## 4. Deterministic occupation and transport

For a path with qualities v_j, write

    B=sum_j v_j,    Z=sum_j zeta(v_j)<=sqrt(HB)+B.

The independent derivation `nearcritical-occupation-transport-independent-audit.md` gives

    number of entering states outside the local white/variance region
       <=C epsilon^-2(D+Z),                          (6)

and the high-variance cooling estimate

    sum_{j:qmax_j>2A0 epsilon} qmax_j²
       <=C(1+B+epsilon Z).                           (7)

For clarity, the main points preventing extra inverse-epsilon losses are included here.

The scalar maximum potential max_i|log(q_i/q_*)| has free drift c epsilon times its capped size, with q_*=epsilon+O(epsilon²), and incurs only C zeta(v) noise. Normalized pair gaps never shrink under the free map; in the variance band, higher Hermite mass Theta(epsilon²) gives a fixed-fraction-gap improvement at rate epsilon². Max potentials incur no dimension union bound.

For spectra set X=lambda_max(C)-1 and Y=1-lambda_min(C). The free normalized map is exactly C->C Hadamard M, where M is PSD with diagonal one. Therefore X and Y never increase at any free step, regardless of variance quality. In the variance band, once pair correlations are below a fixed threshold,

    X_free<=(1-c epsilon²)X,
    Y_free<=(1-c epsilon²)Y+C epsilon² X^(3/2)

(the second inequality only needs X<=1). The composite potential

    W=8 log(1+X/b)+g(X)Y,

where g equals one below b/2, decreases linearly to zero at b, and then vanishes, is nonincreasing at every free step and drops c epsilon² on regular spectrally bad steps. Its empirical increment is only C zeta(v). The logarithmic comparison uses lambda_max(C_free)>=c lambda_max(C), supplied by the first Hermite component. This gives the spectral occupation count without charging a full recovery time at each irregular step.

Finally T(q)<=q+3epsilon q-cq² on [0,2]. Apply the excess potential (q-A0epsilon)_+ to the largest variance, use the scalar multiplicative error, and absorb q sqrt(v) by Young's inequality. Summation gives (7). The coefficient 3epsilon, rather than 2epsilon, includes the epsilon² term in t².

Apply (6),(7) to both coupled paths. At common good states use local log gain -c epsilon²+C zeta(v). Moderate-variance exceptional states cost only C epsilon² each; high-variance states cost their square sum. Thus

    Dist_H <=Dist_0 exp[-c epsilon² H+C(D+B+Z+1)].      (8)

Physical covariance Bures distance is at most sqrt(qmax)Dist, so the same bound applies at the final layer, where qmax<=1.

## 5. Actual full-label mass and width requirement

The optimized finite-N witness in `nearcritical-cheap-all-label-mass.md` proves uniformly for every truth table f that

    w_f>=exp(-Cmass N B0),                            (9)

provided H>=Cmass epsilon^-2D and

    N>=exp(Cwidth D)log(H+2).                         (10)

Its total cost does not grow with excess depth. The witness uses a free prefix, a weak shared-mode seed of row KL O(epsilon²), amplification at multiplier 1+Aepsilon² for O(epsilon^-2D) layers at total row KL O(epsilon²D), then amplification to a fixed shared component at O(1) row KL and an O(N) readout mean shift. Target eigenvalues stay above exp(-CD), and empirical relative Frobenius errors O(epsilon²) preserve the cheap per-layer KL. Hoeffding controls the finite-N covariance corrections. Binary relative entropy converts the changed-law success probability bounded away from zero into (9).

The unchanged prefix whitens within Frobenius O(epsilon³) after O(epsilon^-2D) layers at width exp(CD)log(H+2), by `nearcritical-bures-free-prefix.md`. Its Bures stability gain during burn is 1+O(epsilon²), and an entrywise invariant white box handles arbitrary excess prefix length. Thus (10) has no hidden epsilon^-2 factor in its exponent.

## 6. Quality budget and explicit constant order

The exponential tail (5) gives a uniform constant M0 with

    E exp[cN(V_j-tau)/2]<=M0.

Therefore

    Pr{sum_j V_j>Htau+bB0}
       <=exp[C H-c' N bB0].                          (11)

Choose constants in the following noncircular order.

1. Choose A larger than Cwidth and all fixed exponents needed for the empirical thresholds, with fixed slack. In particular choose it large enough to dominate the factors epsilon^-4 m^4 D; this requires only an absolute A because log(m)=d log2 and log(epsilon^-1)<=D.
2. Choose a quality-tail exponent M>Cmass+3, and b large enough that c'b>=2M.
3. Choose a readout cutoff coefficient k so large that, with R=kB0, the chi-square bound gives

       Pr{chi_N²>2NR}<=exp(-MNB0).                  (12)

   Since B0>=1, a single absolute k works uniformly.
4. Choose K sufficiently large, depending on these already fixed constants, so that the negative term in (8) dominates the correction under B<=b1B0, b1=b+1. Specifically,

       H=ceil(K epsilon^-4B0),
       sqrt(H b1B0)<=C sqrt(Kb1)(epsilon^-2+D),
       epsilon²H>=K(epsilon^-2+D).

   Thus, increasing K, the final physical covariance distance on the quality event satisfies

       delta:=d_B(Q_H,Q'_H)
           <=exp[-L(epsilon^-2+D)]                  (13)

   for any prescribed absolute L, including L>A+10. The initial factor C sqrt(m) is absorbed into the D term. K also exceeds the finite-mass depth constant.
5. Finally increase d0 (or reduce epsilon0) to absorb all fixed K-dependent prefactors and integer roundings. Then uniformly for d>=d0 and epsilon<=epsilon0,

       Htau<=B0,
       C H <=(M/2)N B0,
       N>=exp(Cwidth D)log(H+2),

   and all sample-size requirements hold. The first inequality follows from

       Htau/B0 <= C K epsilon^-4 m^4 log(eN)/N,

   which tends to zero uniformly as D grows when A has the slack chosen in step1. The second follows from H/(NB0)<=C K epsilon^-4 exp(-AD). The logarithmic factor in (10) is at most C(D+log K), absorbed by the exponential slack in A.

With the constants fixed in this order, (11) yields a bad-quality probability

    beta<=exp(-MNB0),                               (14)

and on its complement B<=b1B0. Crucially A is fixed before K; the last thresholds absorb K through D rather than changing the width exponent. No circular width/depth requirement remains.

## 7. Exact rare-margin readout comparison

For final feature matrices F,G of the coupled gauged chains, choose an N-dimensional orthogonal matrix O so

    ||F-GO||F=sqrt(N)d_B(Q_H,Q'_H).

This is the feature Procrustes identity. A fresh readout vector v has law N(0,t²N^-2 I_N). On the cutoff

    N||v||²/(2t²)<=R=kB0,

the coordinatewise output discrepancy is at most

    e_out=t sqrt(2R) delta.                          (15)

For a=1/2 and s=a/(a-e_out), the map v->sOv carries a strict positive-margin readout for F, within the cutoff, into a strict positive-margin readout for G. A conditional Gaussian density comparison gives

    w_g>=exp(-Lambda)(w_f-beta-tail),
    Lambda=N R(s²-1)<=C N B0^(3/2)delta,              (16)

as soon as e_out<a/2. The favorable Jacobian s^N is discarded. There is no Jacobian for the hidden coupling and no need for it to be invertible. The rotation O depends only on hidden features, independently of the fresh readout.

Equations (9),(12),(14) imply

    (beta+tail)/min_f w_f <=2exp[-(M-Cmass)NB0].        (17)

By (13), log N<=AD+O(1), and log B0<=D+O(1), the multiplicative cost in (16) is at most exp(-cD) after the prescribed choice L>A+10 and the final thresholds. Reverse f,g to obtain

    max(w_f,w_g)/min(w_f,w_g)
       <=exp(Lambda)/[1-(beta+tail)/min_h w_h]
       <=1+exp(-cD).

The constants are uniform in the truth-table pair. This is a deterministic probability comparison for each pair, so no union bound over 2^m truth tables is used. It proves (1).

## 8. Posterior consequence and target complexity

Pair every truth table consistent with the observed labels with the table obtained by flipping one unseen input. The raw weights have ratio at most 1+rho. Summing paired weights proves (2), after conditioning on the full absolute-margin event. Distinct training points are sufficient for the displayed error count; repetitions cannot improve it.

For the constant target, use two neurons in every hidden layer. Each first-layer neuron reads the constant input with coefficient one, producing tanh(1). Give every later 2-by-2 hidden matrix all entries one; the activation remains at least tanh(1)>1/2. Read out the sum of the two last neurons with coefficients one, giving a constant output above one. This supplies a width-two, bounded-weight teacher at the same depth, without internal biases.

## 9. Scope and verification status

This is a sharpened theorem for the natural mean-field width powers with a fixed prefactor t=1+epsilon above one. It is not an answer for exact tanh with canonical prefactor t<=1. The sample lower bound concerns the user's full-cube-margin convention and any confidence threshold strictly above one half; it also yields a Gibbs-error bound, but not an exact deterministic-majority lower bound.

All component arguments have been written explicitly in the named scratch notes. The scalar/pair square-root lemma, optimized mass, free-prefix estimate, population/local metric geometry, and occupation/cooling calculation have separate independent AI-agent audits. The full normalized empirical-quality proof has also passed a fresh independent audit, recorded in `nearcritical-normalized-empirical-independent-audit.md`. This complete assembly has passed a fresh independent finite-N audit; a second independent occupation/assembly review is in progress. No Lean verification is claimed, and no public manuscript update is made by this scratch assembly.
