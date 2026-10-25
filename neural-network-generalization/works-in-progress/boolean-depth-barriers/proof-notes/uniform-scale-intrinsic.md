# A uniform finite-width entropy/energy interpolation bound

Supporting proof, 24 October 2026; curated 25 October 2026. Conventionally reviewed, not Lean verified. The current all-scale statements are in the companion `uniform-target-classes.pdf`; the package README gives the dependency map.

## Statement

Use the original Gaussian variances t^2/d, t^2/N, t^2/N^2 with any 0<t<=1, and H=L-1>=1. The prior is conditioned only on the global strict output margin and exact noiseless training signs. At a realizable width define

    a=a_(N,t)(f)=-(1/N) log mu_(N,t)(A_(N,f)).

For D>=0, let R(D)>=1 solve

    R(D)-1-log R(D)=2D,

and put

    P_t(A,H)=max{1,t^H R(A/H)^(H/2)}.

Intrinsic theorem: there are universal C,c such that, simultaneously for all 0<t<=1 and all realizable N, a sufficient sample size for the strict posterior-confidence >2/3 criterion outside epsilon test mass, with training probability at least 1-delta, is

    n >= C/epsilon * {
       [(d+L+t^2 a+2) P_t(a+t^(-2),H)
                         (1+log(1/epsilon))]^c
       +log(1/delta)
    }.

The sample bound depends on the actual width only through its raw target cost a. In particular, it contains no separate inverse power of t or |log t|.

## Population compression normalized by t^2 A

Consider any exact covariance path, not necessarily globally margined, with hidden costs D_j, readout action r=(2t^2)^(-1)z^TQ_H^+z, and total action at most A. Define

    alpha_j=t sqrt(R(D_j)),
    q*_0=2, q*_j=2 product_(i<=j) alpha_i^2,
    G=sqrt(2) P_t(A,H).

The exact Gaussian second-moment entropy inequality gives max_x Q_j(x,x)<=q*_j and exact anchor-propagation factor alpha_j. Concavity of log R gives q*_H<=G^2. These are the same facts proved in `fixed-t-compression.md`.

The following two adjustments remove the unnormalized A from compression width.

First, choose a separate anchor conditional-entropy threshold

    delta_j=epsilon_0^2 R(D_j)/8

at each layer. There is no need for delta_j<=1: conditional Gaussian transport is valid for every nonnegative conditional entropy bound. Use the anchor-selection potential sum_j I_j(T)/delta_j plus the usual terminal readout projection potential. Since

    D/R(D)=(R(D)-1-log R(D))/(2R(D)) <=1/2,

the number of anchors is at most

    sum_j D_j/delta_j + 512t^2 r
       <=4H/epsilon_0^2+512t^2 A.

The Rao--Blackwell approximation error, divided by sqrt(q*_j), is at most

    sqrt[2 t^2 q*_(j-1) delta_j/q*_j]
       =sqrt[2 delta_j/R(D_j)] <=epsilon_0/2.

Second, the Gaussian maximum inequality and tilted-row entropy give

    M_j:=E max_x |h_j(x)|^2
       <=C t^2 q*_(j-1) (d+D_j+1)
       = C q*_j (d+D_j+1)/R(D_j)
       <= C q*_j(d+2).

This also holds for the approximate preceding kernel while its normalized error is at most one, after changing C. Importance quadrature with density proportional to

    1+||whitened anchor vector||^2+max_x |h_j(x)|^2/M_j

therefore yields normalized covariance error at most epsilon_0/2 at width polynomial in the anchor count,d,epsilon_0^(-1), independently of A,t,q*_j. The proof is the scaled bounded-sample concentration argument in `fixed-t-compression.md`.

Take

    epsilon_0=[256 H sqrt(max(2t^2 A,1)) G]^(-1).

The relative-error recursion accumulates at most H epsilon_0, and terminal readout norm is sqrt(2t^2r). The reconstructed ordinary tanh network approximates the original output uniformly to 3/32 with width

    M <= poly(d,H,1+t^2 A,P_t(A,H)),

with universal polynomial degree. It has the same depth and no new biases. The proof approximates arbitrary z; no initial 1/2-margin assumption is used until drawing a sign conclusion. Thus it also applies directly to a transferred path whose margin is only 7/16, without rescaling its output or action.

## The dual certificate with an arbitrary action slack

The proof in `finite-width-dual-certificate.md` extends from 0<tau<=1 to every tau>0. Replace its choices by

    s=tau/[16(A+tau)],
    eta=tau/(64Hk),
    B=(A+tau)/Delta, k=m(m+1)/2.

Its bounded-Gibbs-box identity and exponential-moment proof require neither eta<=1 nor B fixed. Indeed eta<B, so the displayed grid count remains applicable. The same numerical budget gives total path action <=A+tau and absolute moment error <=Delta provided

    N >= C/tau * {
        Hk log[1+C(A/tau+1)Hk/Delta]
        +m log[C(A/tau+1)]+1
    }.

This statement is valid for a witness of m inputs, with the original t-scaled row Gaussian references and readout action (2t^2)^(-1)z^TQ_H^+z. No row-permutation invariance assumption on the event is required.

## Uniform finite-witness extraction and reconstruction

Suppose a witness event E has raw mass at least exp(-N A), with margin at least 1/2 on a chosen m-input set. Apply the dual certificate with tau=t^(-2)/4, or any fixed positive multiple of t^(-2).

Let A'=A+tau. Transfer the extracted approximate path to a consistent path by Gaussian coupling. The exact entropy inflation gives

    e_j <=alpha_j e_(j-1)+m sqrt(Delta).

Since R(D_j)>=1,

    q*_j>=2t^(2H),

and therefore the absolute tolerance

    Delta <= t^(2H) /
       [C H^2(m+1)^2(1+t^2 A') P_t(A',H)^2]

makes the transferred readout error at most 1/16. Its readout norm is sqrt(2t^2r), so the denominator only needs 1+t^2 A', not 1+A'. The consistent path retains action <=A' and margin >=7/16. Apply the normalized population compression to preserve all witness signs.

The required inverse tolerance has logarithm at most

    2H log(1/t)+
      O[log(H+m+2)+log(1+t^2A')+log P_t(A',H)].

In the dual certificate, 1/tau=4t^2 multiplies this expression. Since

    sup_(0<t<=1) t^2 log(1/t)=1/(2e),

the extraction threshold is polynomial in

    d,H,m,1+t^2A',P_t(A',H),

with universal coefficients and degree. There is no remaining t dependence. A large q*_H is already represented by P_t, while arbitrarily tiny intermediate q*_j cost only their logarithm in the dual grid.

## Posterior and all-width completion

At the actual target cost a, take an event action budget A=a+t^(-2)/2 and extraction slack tau=t^(-2)/4. Every compressed path has budget below a+t^(-2). Its width and the finite-witness threshold are universal polynomials in

    d,H,1+t^2a,P_t(a+t^(-2),H).

Choose witnesses of size one more than the VC dimension of this compressed network class. The standard finite-witness construction produces a sample-independent class G_A of polynomial VC dimension. Outside it, raw globally margined mass is at most

    exp(d m log2-N A).

Divide by true target mass exp(-N a). Exceptional posterior mass is at most

    exp(d m log2-N/(2t^2)) <=exp(d m log2-N/2).

Thus a polynomial width threshold makes the exceptional mass <=epsilon/6. A finite-class consistency bound on G_A controls Gibbs error, hence the posterior confidence criterion. All smaller widths are bounded by the same polynomial, so the ordinary polynomial tanh-network VC bound handles their whole support. This proves the stated sufficient sample expression after enlarging C,c.

## Relation to the energy and critical endpoints

If t tends to zero while a behaves like kappa/(2t^2), then

    P_t(a+t^(-2),H) -> max{1,[(kappa+2)/H]^(H/2)}.

This is the expected energy/product-norm factor. At t=1 the factor is exp(O(sqrt(H a))) for A/H small. The sharper critical theorem removes its terminal scalar baseline using the separate occupation argument; that refinement is not supplied here.

For fixed t<1, put c_t=(t^(-2)-1+2log t)/2. If E=A-Hc_t>=0 and u=log P_t(A,H), then

    E>= (t^(-2)-1)u+t^(-2)u^2/H.

This exact inequality interpolates between a linear cost for log amplification away from criticality and a quadratic cost at t=1.

