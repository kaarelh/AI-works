# Scale-sensitive compression for a fixed Gaussian prefactor

Supporting proof, 24 October 2026; curated 25 October 2026. Conventionally reviewed, not Lean verified. The current all-scale statements are in the companion `uniform-target-classes.pdf`; the package README gives the dependency map.

## Model and claim

Fix 0<t<1. Raw Gaussian entry variances are t^2/d, t^2/N, t^2/N^2 in the first, internal, and readout blocks. At speed N the hidden transition reference is N(0,t^2 Q_{j-1}), followed by tanh. The readout action is r=(2t^2)^(-1) z^T Q_H^+ z. Put H=L-1, total action A=sum_j D_j+r, and

    r_t=t^(-2), c_t=(r_t-1-log r_t)/2.

Claim: every such variational path with f(x)z(x)>=1/2 on the cube has an ordinary depth-L finite tanh realization of f with width

    poly(d,L,1+A) exp[C (A-H c_t)_+/(r_t-1)],

where the polynomial degree and C are universal. The physical weights may be arbitrary finite real numbers. The reconstruction approximates z uniformly to 3/32, so its signed margin is at least 13/32. Constants can be enlarged harmlessly as t varies, but t is fixed here.

The proof modifies the existing anchor-preserving compression proof. It does not require a near-critical scalar-control theorem. A learning conclusion additionally needs finite-width path extraction and a target mass estimate near H c_t.

## Exact entropy-to-variance inflation

Let R(D)>=1 be defined by

    (R(D)-1-log R(D))/2 = D.

If a law rho has entropy at most D relative to a centered Gaussian law G, then every scalar Gaussian linear functional B satisfies

    E_rho B^2 <= R(D) E_G B^2.

Indeed one-dimensional entropy data processing followed by the Gaussian exponential-moment variational inequality gives D>=(v-1-log v)/2 for v=E_rho B^2/E_G B^2; if v<=1 the upper bound is automatic. This argument includes nonzero tilted means, because it uses second moments.

Define

    alpha_j=t sqrt(R(D_j)),
    q*_0=2, q*_j=q*_0 product_{i<=j} alpha_i^2.

The actual feature covariance satisfies max_x Q_j(x,x)<=q*_j by tanh's 1-Lipschitz, zero-preserving property and the displayed moment bound. No lower bound on q*_j is required.

In the exact-anchor propagation lemma, couple the two reference Gaussian anchor vectors identically, then couple a queried conditional Gaussian residual optimally. The query difference is a scalar linear Gaussian functional under this coupling. Tilting by a density on the anchors of entropy at most D_j gives exact propagation

    d_T(F_w(K),F_w(K')) <= alpha_j d_T(K,K').

Here the input reference covariance is t^2 K, so the factor t is essential. The anchor density normalizes under both laws because their anchor blocks agree.

Write u(D)=log R(D). It is increasing and concave: for D>0,

    u'(D)=2/(exp(u(D))-1).

The tangent line at D=c_t, where R(c_t)=r_t, gives

    u(D) <= log r_t + 2(D-c_t)/(r_t-1).

Consequently

    q*_H <= 2 exp[2(sum D_j-H c_t)/(r_t-1)]
           <= G^2,
    G=sqrt(2) exp[(A-H c_t)_+/(r_t-1)].

Unlike a bound on sum sqrt(D_j), this has no exponential dependence on H when A-H c_t is logarithmic in the resources.

## A Gaussian maximum bound under an entropy tilt

For m=2^d centered jointly Gaussian coordinates with marginal variances at most v, a union bound gives

    Pr[max_x |G_x|^2>u] <= 2m exp[-u/(2v)].

Thus, for a universal constant C,

    log E exp[max_x |G_x|^2/(4v)] <= C(d+1).

For any tilt of entropy at most D, the variational entropy inequality yields

    E_tilt max_x |G_x|^2 <= C v(d+D+1).

The same bound holds with tanh(G_x)^2 in place of G_x^2. It requires no higher moment of the tilted law. In a zero-variance case all coordinates vanish and no approximation is needed.

## Scale-sensitive exact-anchor quadrature

Let nu be a feature law on real vectors indexed by the finite cube, with M>=E_nu max_x |h_x|^2>0. Let T have q anchors, anchor covariance rank s<=q, and normalized anchor vector a(h), so E aa^T=I_s. Use importance density

    p(h)=[1+||a(h)||^2+max_x |h_x|^2/M]/Z,
    Z=1+s+E max_x |h_x|^2/M <= s+2.

Then both ||a(h)||^2/p(h)<=s+2 and max_x |h_x|^2/p(h)<=(s+2)M. The existing Gram/cross/diagonal concentration proof applies after scaling all features by M^(-1/2). For eta in (0,1/8], it yields finite importance samples and the same exact Gram correction B, with

    n <= C(q+2)^4 eta^(-2)[d+log(q+2)+1],
    K'_{TT}=K_{TT}, ||B||op<=2,
    d_T(K,K') <= 6 sqrt(M eta).

The anchor-whitening vectors are unchanged when features are uniformly scaled; therefore this is literally the previous quadrature argument with a different importance density. All selected samples and coefficients are finite almost surely. This statement only uses a first moment of max_x |h_x|^2.

## Anchor selection

Select anchors exactly as in the current theorem. Let I_j(T) be marginal entropy of preactivations on T relative to the t-scaled Gaussian reference. Adjoin a query if any conditional entropy increment exceeds delta or if the terminal readout projection error exceeds tau=1/16.

The terminal Hilbert readout vector u has ||u||^2=2t^2 r<=2A, while terminal feature variances are at most one. Hence

    |T| <= (sum D_j)/delta + 2t^2 r/tau^2
          <= A/delta+512A.

At every query, replacing the original law by its Rao--Blackwellization given the anchors costs at most

    sqrt[2 t^2 q*_{j-1} delta] <= sqrt[2 q*_j delta]

in d_T. This follows from conditional Gaussian quadratic transport and R(D_j)>=1.

## Recursive error estimate

Suppose e_{j-1}=d_T(Q_{j-1},Qhat_{j-1})<=E_{j-1} sqrt(q*_{j-1}), with E_{j-1}<=1. Exact anchors imply, by the query coupling interpretation of d_T,

    max_x Qhat_{j-1}(x,x) <= (sqrt(q*_{j-1})+e_{j-1})^2
                           <=4q*_{j-1}.

The reference preactivation covariance of the next finite-law construction has diagonal at most 4t^2 q*_{j-1}. Its anchor tilt entropy is I_j(T)<=D_j<=A. The Gaussian maximum bound therefore supplies a valid quadrature bound

    M_j <= C t^2 q*_{j-1}(d+A+1)
         <= C q*_j(d+A+1).

Choose one small epsilon_0 and set

    delta <= epsilon_0^2/8,
    eta <= epsilon_0^2/[C(d+A+1)]

with C large enough that Rao--Blackwellization plus quadrature contributes at most epsilon_0 sqrt(q*_j). Exact propagation then gives

    e_j <= alpha_j e_{j-1}+epsilon_0 sqrt(q*_j),
    E_j=e_j/sqrt(q*_j) <= E_{j-1}+epsilon_0 <= j epsilon_0.

Take

    epsilon_0=[256 H sqrt(max(2A,1)) G]^(-1).

Then E_j<=1 throughout, validating the diagonal bound inductively. At the output,

    ||z_T-zhat||infty <= sqrt(2t^2 r) e_H
                      <= sqrt(2A) H epsilon_0 G <=1/32.

Together with the 1/16 anchor-supported readout approximation this gives total uniform error <=3/32.

The anchor count, eta^(-1), and the quadrature width are each polynomial in d,L,1+A,G. Substituting the displayed G gives the claimed width bound. The changing importance weights and covariance corrections are absorbed into each next affine matrix as in the existing proof, so depth does not increase and no new biases are introduced.

## Scalar baseline check

The constant c_t is not invented solely for compression: it gives a universal scalar lower bound. Choose the same signed input pair used in the critical paper; its initial normalized variance is q_0=1/d. Let q_j denote its controlled feature variance. If v_j=E B_j^2/(t^2 q_{j-1}), then q_j<=E B_j^2, and scalar entropy gives

    D_j >= g_+(log(q_j/q_{j-1})),
    g_+(u)=g(max(1,exp(u)/t^2)), g(r)=(r-1-log r)/2.

This is a convex function of u, with tangent at u=0 equal to c_t+a_t u, where a_t=(r_t-1)/2. Therefore

    sum D_j >= H c_t+a_t log(d q_H).

The readout costs at least 1/(8t^2 q_H), giving

    A >= H c_t+a_t log d+b_t,
    b_t=inf_{0<q<=1}[a_t log q+1/(8t^2 q)] > -infinity.

This lower bound supports H c_t as the leading depth baseline. It does not alone prove a matching target-mass upper bound or posterior learning result.

## A sharper exact factor

The tangent bound is convenient in the long-depth regime, but Jensen gives the sharper bound

    q*_H <= 2 t^(2H) R(A/H)^H.

Define

    P_t(A,H)=max{1, t^H R(A/H)^(H/2)}.

Every use of G in the proof can therefore be replaced by sqrt(2) P_t(A,H). The resulting population width is polynomial in d,L,1+A,P_t(A,H), with universal degree. This assertion is valid for every 0<t<=1; at t=1 it supplies an ordinary entropy-length bound rather than the sharper critical-baseline bound already in the current paper. The exact factor is useful when the number of padding layers is small and A-Hc_t is large but A itself is only polynomial in the target resources.

There is an explicit uniform linear/quadratic interpolation. If E=A-Hc_t>=0 and u=log P_t(A,H), then

    E=H/2 [r_t(exp(2u/H)-1)-2u/H]
      >= (r_t-1)u+r_t u^2/H.

Consequently

    u <= H/(2r_t) [sqrt((r_t-1)^2+4r_t E/H)-(r_t-1)].

At fixed t<1 this is at most E/(r_t-1), while at t=1 it is at most sqrt(H E). Thus the intrinsic estimate itself has no discontinuity at t=1. The unresolved uniform-target issue is subtracting the unavoidable nonlinear terminal scalar cost, which the current critical occupation lemma accomplishes only at t=1.

## Finite-width extension

The earlier exchangeable entropy-decrement certificate would pay an inverse power of an exponentially small covariance tolerance. The new bounded-dual certificate in `finite-width-dual-certificate.md` pays only log(1/Delta), resolving that difficulty. Its exact Gibbs-box identity and conditional exponential-moment proof were checked independently by the critical-depth and complexity-barrier agents.

Let Z be any m-point input witness, E any event of raw probability at least exp(-N A), and suppose every output on Z has margin at least 1/2 on E. Apply that certificate with total action slack tau=1/4 and absolute covariance tolerance Delta. It supplies a realized empirical path Q_j and controls whose total action is at most A+tau and whose feature second moments differ from Q_j entrywise by at most Delta.

Transfer those controls successively to a consistent covariance path, using the standard Gaussian coupling transfer. If e_j is the maximum-coordinate Gaussian RMS distance between the empirical and consistent kernels, exact entropy-to-variance inflation gives

    e_j <= alpha_j e_(j-1)+m sqrt(Delta), e_0=0.

Here alpha_j=t sqrt(R(D_j)) and q*_j=2 product_(i<=j) alpha_i^2 as before, with D_j the extracted control cost. Since R(D_j)>=1,

    q*_j >= 2t^(2H)                 (0<t<=1, j<=H).

Hence

    e_H <= sqrt(2) P_t(A+tau,H) Hm sqrt(Delta)/(sqrt(2)t^H).

The harmless sqrt(2) factors may be suppressed. Taking

    Delta <= t^(2H) /
             [C H^2(m+1)^2(A+1) P_t(A+tau,H)^2]

ensures that the transferred readout changes by at most 1/16, has action no larger than the extracted action, and preserves margin at least 7/16 on Z. The logarithm of the required inverse tolerance is at most

    O[H|log t|+log(H+m+A+2)+log P_t(A+tau,H)].

The bounded-dual certificate therefore needs only a polynomial width in m,H,A+1,1+|log t|,1+log P_t(A+tau,H). Apply the population compression argument on Z, where log|Z|<=d. Its further output error 3/32 preserves every sign. The resulting representing width is

    M <= poly(d,L,A+1,P_t(A+tau,H)).

In particular, after enlarging one universal polynomial, a width threshold polynomial in d,L,A+1,m,1+|log t|,P_t(A+tau,H) guarantees that some realization in E has its sign restriction to Z represented by an ordinary depth-L, width-M tanh network.

## An intrinsic learning theorem at every actual width

Write

    a=a_(N,t)(f)=-(1/N) log mu_(N,t)(A_(N,f)),
    H=L-1,
    K=d+L+a+2+|log t|,
    P=P_t(a+1,H).

For 0<t<=1 and every realizable width N, the preceding witness theorem gives the sufficient sample bound

    n >= (C/epsilon) {
            [K P (1+log(1/epsilon))]^c + log(1/delta)
         },

for universal C,c, by precisely the finite-witness/VC argument in the current critical paper. This is an intrinsic bound through the actual raw target cost, not yet a teacher-resource bound.

Details: choose the action budget A=a+1/2 and extraction slack tau=1/4, so the compressed-path budget is below a+1. Let M be the witness-compression width and v a polynomial upper bound on the VC dimension of depth-L, width-M tanh networks. On witnesses of size m=floor(v)+1, the preceding extraction theorem has a polynomial threshold in K,P. Define G_A to contain functions representable on every such witness. Its VC dimension is below m. An event of globally margined functions outside G_A has raw mass at most exp(d m log 2-N A), at widths above that polynomial threshold. Dividing by the true target mass exp(-N a) gives posterior exceptional mass at most exp(d m log 2-N/2). Large enough polynomial widths make this <=epsilon/6. A finite-class consistency bound on G_A and the Gibbs-to-confidence inequality finish the large-width case. All remaining widths are themselves bounded by a polynomial in K,P and log(1/epsilon), so the whole-network polynomial VC bound finishes the small-width case. Monotonicity of P_t in its first argument bounds every factor by P_t(a+1,H).

For fixed t<1, the tangent estimate supplies the simpler sufficient form

    poly_t(d,L,a+2,epsilon^(-1),log(2/delta))
       exp[C_t (a-Hc_t)_+].

The extra unit in a+1 only changes the t-dependent constant in the exponential. The exact P_t form is stronger for short-depth schedules.

The theorem's pointwise-in-N statement does not claim that a_N is bounded uniformly in N. A uniform teacher-based target-mass bound above a polynomial N threshold, combined with VC below that threshold, gives the requested every-width teacher theorem. The same sample-independent G_A can be used if the teacher supplies one common action budget, so the standard common-event interpretation across admissible widths is also available.

