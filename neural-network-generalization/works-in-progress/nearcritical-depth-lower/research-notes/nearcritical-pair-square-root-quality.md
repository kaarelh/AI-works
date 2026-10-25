# Square-root empirical lower control for two tanh features

25 October 2026. Research note. This sharpens the small-quality lower bound in `supercritical-empirical-scalar-pair-quality.md` from a fourth root to a square root. It does not change the large-quality estimates in that note. Constants are uniform for the feature-norm bound L in a fixed compact interval, so in particular for 1<t<=2.

## 1. Statement

Let G_1,...,G_N be independent standard Gaussian vectors in R^m, m>=2, and let P and P_N denote Gaussian and empirical integration. For ||u||,||w||<=L, write F_u(g)=tanh(u.g), and let Gamma(u,w) and Gamma_N(u,w) be the population and empirical 2-by-2 second-moment matrices of (F_u,F_w).

There are constants C,c,v_0>0 depending only on L such that, whenever N>=Cm and

    C m log(eN)/N <= v <= v_0,

one has

    P{there exist u,w: Gamma_N(u,w) not >= (1-C sqrt(v)) Gamma(u,w)}
        <= C exp(-cNv).                                      (1)

The order is the PSD order. Null population directions impose no condition. The same result holds for m=1 by using just the collinear two-function family below.

Combined with the scalar upper bound and large-quality estimates in the earlier note, this yields a nested, rotation-invariant quality V with the previously retained conservative threshold

    tau = C m^4 log(eN)/N,
    P{V>tau+s} <= 2 exp(-cNs),

for which the small-quality pair-gap loss is C sqrt(V), and the all-quality loss function can be taken to be

    zeta(v) = sqrt(v)+v.                                    (2)

No positive exponential moment of the square of a cubic Gaussian polynomial is claimed or used.

## 2. Compactification of every two-feature direction

For v,w in [0,L^2], define

    f_v(z)=tanh(sqrt(v)z)/sqrt(v),     f_0(z)=z,
    h_(v,w)(z)=integral_0^1 partial_v f_(v+r(w-v))(z) dr.

For theta in [0,pi/2], define, with D=u-tan(theta/2)z,

    k_(w,theta)(z,u)
       =integral_0^1 f'_w(z+r sin(theta)D) D dr.              (3)

Thus h=(f_w-f_v)/(w-v) off the diagonal, and k is the divided difference of f_w under an angular displacement. Formula (3) defines it continuously at theta=0.

Let B=(f_v,h_(v,w),k_(w,theta)). Its 3-by-3 L2 Gram matrix under independent standard Gaussians (Z,U) is uniformly positive definite, and its entries have uniformly bounded fourth moments. Here is a proof of the lower eigenvalue statement. The Taylor coefficients of f_v at z and z^3 are 1,-v/3, and those of h at the same powers are 0,-1/3. Hence f_v and h are linearly independent for every v,w, including their boundary values. Continuity and compactness give a uniform lower Gram eigenvalue for this pair. Gaussian integration by parts gives

    E[U k_(w,theta)(Z,U)] = E sech^2(sqrt(w)Z) >= c_L>0.

The other two basis functions are orthogonal to U. This controls the third coefficient of a linear combination by its L2 norm; subtracting the third contribution and using the 2-by-2 bound controls the first two coefficients. Uniform upper L2 and L4 bounds follow either from (3) and the analogous integral for h, or from the polynomial bounds in the next section.

Choose an orthonormal frame (e_1,e_2) in R^m and a coefficient vector a in the unit sphere S^2. Set

    g_p(G)=a.B(G.e_1,G.e_2),
    Y_p(G)=g_p(G)/sigma(p),    sigma(p)^2=P g_p^2.           (4)

The compact parameter p consists of the frame, v,w,theta,a. The preceding bounds give

    c_L <= sigma(p) <= C_L,
    P Y_p^2=1,     P Y_p^4<=C_L.                            (5)

Every population-normalized nonzero linear combination of two tanh features belongs to this class. Indeed, change one feature's sign if necessary to make the input correlation nonnegative, then use an orthonormal frame in their span. Writing their lengths as sqrt(v),sqrt(w), and putting A,B for the original coefficients times these lengths gives

    A f_v(Z)+B f_w(cos(theta)Z+sin(theta)U)
       =(A+B)f_v(Z)+B(w-v)h_(v,w)(Z)
                              +B sin(theta)k_(w,theta)(Z,U).

Normalize the resulting coefficient vector, then normalize in population L2. Collinear pairs have theta=0 and the k coefficient vanishes. Identically zero features can be omitted.

## 3. Quantitative parameter continuity

Equip the parameter set with its ambient Euclidean distance: the Frobenius distance on the frame, usual distances on v,w,theta, and Euclidean distance on a. There are fixed constants C,M (M=10 is sufficient) such that

    |Y_p(G)^2-Y_(p')(G)^2|
       <= C (1+||G||^M) ||p-p'||.                          (6)

The bound is uniform through coincident norms, collinear directions, and zero feature scales. For completeness, put b(s)=tanh(sqrt(s))/sqrt(s), continuously extended at zero. The functions b,b',b'' are bounded on [0,infinity): at zero this follows from the convergent Taylor series and at infinity from differentiation of tanh(sqrt(s))/sqrt(s). Therefore

    |f_v(z)|<=|z|,
    |partial_v f_v(z)|<=C|z|^3,
    |partial_v^2 f_v(z)|<=C|z|^5,
    |partial_z f_v(z)|<=1,
    |partial_z partial_v f_v(z)|<=C(|z|^2+|z|^4).

The integral defining h consequently has a cubic size envelope and degree-five first-parameter-derivative envelopes. For k, formula (3), the boundedness of tan(theta/2) and its derivative on [0,pi/2], and

    |f'_w(z)|<=1,
    |partial_z f'_w(z)|<=2L,
    |partial_w f'_w(z)|<=C z^2

give first-parameter-derivative envelopes of degree at most three in |z|+|u|. Differentiating a frame replaces one projected variable by a scalar product with G, so the full unnormalized family has a size envelope C(1+||G||^3) and a first-parameter-derivative envelope C(1+||G||^5). Integrate derivatives along straight segments of the frame coordinates and the other parameters; the intermediate frame columns have norm at most one, which is enough for these bounds even when they are no longer orthogonal.

Furthermore

    ||g_p-g_(p')||_(L2(P)) <= C ||p-p'||.                   (7)

For the orientation terms this follows from Gaussian Holder inequalities: every derivative is a bounded-degree polynomial envelope in projections onto at most three vectors of norm at most one, one of which has norm proportional to the frame displacement. Thus all necessary Gaussian moments are dimension independent. The scalar parameters obey the same estimate directly. The reverse triangle inequality for L2 norms gives |sigma(p)-sigma(p')|<=C||p-p'||. Dividing by the uniform lower bound in (5) gives a degree-five pointwise difference envelope for Y, and multiplying by the cubic size envelope gives (6), with the harmless conservative exponent M=10.

The compact parameter set has ambient dimension at most 2m+6 and bounded diameter. A maximal eta-separated subset, with its points in the parameter set, therefore has size at most

    (C/eta)^(2m+6),                                        (8)

and is an eta-net. This conclusion does not require following paths inside the Stiefel manifold or extending the normalization outside the parameter set.

## 4. A fixed-feature lower-tail inequality from only fourth moments

Fix any p. Let W=Y_p^2. It is nonnegative, EW=1 and EW^2<=C. For 0<=lambda<=lambda_0,

    E exp[-lambda(W-1)]
      <= exp(lambda)(1-lambda+(lambda^2/2)EW^2)
      <= exp(C lambda^2).                                 (9)

The first inequality uses exp(-x)<=1-x+x^2/2 for x>=0. Chernoff's method, with lambda a sufficiently small multiple of a, gives

    P{P_N Y_p^2 < 1-a} <= exp(-c N a^2),   0<a<a_0.        (10)

This is a lower-tail statement. Positive-MGF or two-sided Bernstein arguments would be unjustified for the full normalized secant family, whose limits include cubic Gaussian polynomials.

## 5. Uniformization by a finite metric net

Fix a v in the range of (1), choosing v_0 small enough. Let

    T^2 = C[m+log(2N)+Nv].

A standard Gaussian radial tail and a union bound show

    P{max_j ||G_j||>T} <= exp(-cNv),                       (11)

after increasing the absolute constant in T. On this event, (6) bounds empirical squared-feature differences by C(1+T^M)||p-p'||. Choose

    eta = sqrt(v)/[C(1+T^M)],                             (12)

so that passing from a parameter to its net point changes its empirical second moment by at most sqrt(v). Population moments are exactly one at every net point, so no population approximation error is needed here.

Because v<=v_0, N>=Cm, and v>=C m log(eN)/N, one has T^2<=CN and log(1/v)<=C log(eN). Thus the logarithm of the net size in (8) is at most C m log(eN). Apply (10) at every net point with a=A sqrt(v), where A is a fixed large constant. The probability of any failure is bounded by

    exp[C m log(eN)-c A^2Nv].                             (13)

Choose the constant in the lower constraint on v and then choose v_0 small enough that A sqrt(v_0)<a_0. Combining (11)--(13) proves, simultaneously for every p,

    P_NY_p^2 >= 1-C sqrt(v)

outside an event of probability C exp(-cNv). Testing all original two-feature linear combinations gives (1).

## 6. Pair gaps and the single quality statistic

Intersect the event in (1) with the scalar upper estimate

    P_NF_u^2 <= (1+C sqrt(v)) PF_u^2,

which follows independently from the normalized matrix-quality lemma or from the usual scalar subexponential net. If c_N and c_free are the empirical and population normalized pair correlations, respectively, test the PSD estimate against the difference of the two features normalized by their actual empirical standard deviations. Exactly as in the earlier note, this gives

    1-|c_N| >= [(1-C sqrt(v))/(1+C sqrt(v))](1-|c_free|)
             >= exp(-C sqrt(v))(1-|c_free|).               (14)

The lower and upper diagonal estimates also give

    |log(P_NF_u^2/PF_u^2)| <= C sqrt(v).                   (15)

For v>=v_0 use the earlier rare-strip and covariance estimates, which give logarithmic scalar loss Cv and pair-gap loss Cv relative to the entering correlation. Define the nested event using (1), the scalar upper estimate and these all-quality estimates; drop the small-quality constraints at v_0. All these events are rotation invariant and separable by the compact parameter net/continuity and the earlier strip argument. Taking the infimum quality parameter and enlarging the baseline tau=Cm^4log(eN)/N yields the quality variable claimed in (2).

Independent arrays still give independent quality variables, and a fixed total quality budget B now incurs the cumulative loss

    sum_j zeta(V_j) <= sqrt(HB)+B,                         (16)

rather than H^(3/4)B^(1/4)+B. This note alone does not establish a nearcritical posterior transport theorem: the epsilon-dependent occupation and covariance-coupling estimates must also be proved.
