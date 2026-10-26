# A positive intrinsic crossover just above the canonical tanh prefactor

26 October 2026. Scratch theorem for exact tanh, unchanged Gaussian width
powers, global absolute margin, and exact labels. The prefactor in this
note is t>=1, so its noncritical part is adjacent to, not inside, the
original canonical range. No teacher target-mass theorem is claimed here.

## 1. Uniform path gain bound

Fix a sufficiently small universal delta0>0. Let 1<=t<=1+delta0 and
delta=t-1. Consider any controlled tanh path with H hidden layers on a
finite witness containing one input x0 with initial variance q0 in [1,2].
Let D_j be its FULL row relative entropies with respect to the original
Gaussian references N(0,t² Q_(j-1)). Let

    r_t=(2t²)^(-1) z^T Q_H^dagger z,
    A=sum_j D_j+r_t.

Assume |z(x0)|>=1/2. Define R(D)>=1 by R-1-log R=2D and the full
entropy-to-variance gain

    Gamma=product_(j=1)^H t sqrt(R(D_j)).

If A<=V_*+epsilon, epsilon>=0, then

    sum_j sqrt(D_j)
       <= C[log(H+2)+sqrt(H epsilon)+delta H],                (1)
    log Gamma
       <= C[log(H+2)+sqrt(H epsilon)+delta H].                (2)

The constants are universal for 0<=delta<=delta0. Here V_* is the
unrestricted CRITICAL scalar Bellman baseline, not a Gaussian-restricted
baseline and not a new supercritical baseline. No dimension-dependent
change of Gaussian reference is made.

### Proof

All scalar variances q_j=Q_j(x0,x0) are positive; a zero variance cannot
revive at finite entropy and would contradict the final margin. Let eta_j
be the scalar preactivation marginal at x0, put p=q_(j-1), and write

    d_j=KL(eta_j||N(0,t²p))<=D_j,
    M_j=E_eta G²/p,
    d1_j=KL(eta_j||N(0,p)).

Let b=1-t^(-2)>=0 and c_t=(t^(-2)-1+2log t)/2>=0. The exact scalar
reference identity is

    d1_j=d_j-c_t+(b/2)(M_j-1).                               (3)

Entropy duality for the standardized second moment gives

    M_j/t²<=R(d_j)<=R(D_j),
    R(D)-1<=C[sqrt(D)+D].

Consequently, since b<=C delta,

    d1_j <= (1+C delta)D_j+C delta sqrt(D_j)+C delta².         (4)

Choose a single universal constant C0 sufficiently large and define
the NONNEGATIVE overcosts

    e_j=(1+C0 delta)D_j+C0 delta sqrt(D_j)+C0 delta².

Then e_j>=D_j and e_j>=d1_j. Thus the same scalar variance sequence,
with costs e_j, satisfies all critical scalar Bellman and dissipation
inequalities. Its terminal critical readout overcost is
r1=t² r_t>=1/(8q_H). Write Z=sum_j sqrt(D_j). Since t²<=1+C delta,

    sum_j e_j+r1
       <= (1+C delta)A+C delta Z+C H delta²
       <= V_*+C[epsilon+delta(1+epsilon)+delta Z+H delta²].     (5)

Apply the established critical scalar square-root occupation theorem
to these overcosts and this terminal cost. Its hypotheses are only
nonnegative costs dominating the actual one-input critical entropy,
the associated scalar variance sequence, q0 in [1,2], and the terminal
inverse-variance bound. It gives

    Z<=sum_j sqrt(e_j)
      <=C log(H+2)
         +C sqrt{H epsilon+H delta(1+epsilon)
                         +H delta Z+H² delta²}.               (6)

This is a self-consistent inequality, not a circular assumption on Z.
Put Y=log(H+2)+sqrt(H epsilon)+H delta. Since delta<=delta0,

    H epsilon+H delta(1+epsilon)+H²delta²<=C Y².

Hence Z<=C Y+C sqrt(H delta Z). Young's inequality absorbs the final
term into Z/2+C H delta, proving (1). Finally log R(D)<=2sqrt(D), since
e^u-1-u>=u²/2 for u=log R(D)>=0. Thus

    log Gamma<=H log t+Z<=delta H+Z,

which proves (2).

This bootstrap is stronger than applying Cauchy--Schwarz immediately
to the reference-change term delta sum sqrt(D_j). The latter would
introduce a spurious delta sqrt(H A) action loss before the baseline
occupation estimate has been used.

## 2. Actual finite-width intrinsic consequence

At an actual realizable width N define the raw globally correct target
cost

    a_N,t(f)=-(1/N)log mu_N,t{f(x)z_W(x)>1/2 for every x}.

The finite-width dual certificate and normalized importance-compression
arguments of finite-width-dual-certificate.md and
uniform-sharp-intrinsic.md continue to hold for t in the compact interval
[1,1+delta0]. Their population parts use only the exact gains
t sqrt(R(D_j)); none requires t<=1. The dual certificate itself permits
arbitrary Gaussian reference covariances. In the transfer step, one may
use a coarse layer gain sqrt(C(1+t²A)); the inverse required moment
tolerance has logarithm O[H log(2+t²A)+log(H+m+2)]. Since t is bounded,
slack 1/(Ht²) remains comparable to 1/H and all finite-width thresholds
remain polynomial in the displayed resources and the resulting gain.

Apply (2) after the same vanishing readout repair, which produces an exact
margined path of action at most

    B=a_N,t(f)+4/(Ht²).

Set E=(B-V_*)_+. The actual posterior therefore has sufficient sample
size of the form

    n >= C/epsilon_stat * {
      [(d+H+t²a_N,t(f)+2)(1+log(1/epsilon_stat))]^c
          exp(C[sqrt(H E)+delta H])
      +log(1/delta_stat) },                                  (7)

uniformly for every realizable finite width and 1<=t<=1+delta0.
As in the cited intrinsic proof, large widths are handled by the
finite-witness certificate and division by the actual target mass;
smaller widths use the ordinary tanh parameter-count VC bound. The
confidence failure event is the original inclusive <=2/3 event, handled
through posterior Gibbs error. Equation (7) imports those already-audited
finite-width components; it is not a stand-alone reproof of them.

## 3. What a positive teacher crossover would additionally require

If a target class has a finite-width construction, above widths exp(CS),
with S>=1+log(d+H+2),

    a_N,t(f)<=V_*+C(S+delta H)²/H,                            (8)

then (7) immediately gives exp[O(S+delta H)] sufficient samples times
polynomial statistical factors at all widths. In particular delta H=O(S)
would preserve the critical polynomial bound for fixed-depth target
classes whose S is logarithmic in their ordinary resources.

This note has NOT proved (8). Reusing the subcritical target program
verbatim is invalid: its argument relies on smaller residual Gaussian
noise, whereas t>1 increases that noise. One must control the resulting
signal loss and compensate it within the stated scalar entropy budget.
No global Gaussian change of measure, with cost proportional to the
number of weight coordinates, can substitute for that construction.

The stronger proposed regime delta²H=O(S) does not follow from (1)--(7):
the proved gain budget contains delta H. A sharper normalized feature
argument would be needed to exploit the quadratic free-correlation
decorrelation scale. The original all-target canonical tanh problem
also remains open.
