# Critical target mass and the analytic-activation posterior lower bound

24 October 2026. Self-contained theorem chain in research scratch form.
This changes the activation; it does not prove a lower bound for exact tanh.
The canonical structural proof is in `critical-activation-structural.md`.
The scalar estimates below were independently developed with the upper-bound
agent; the finite-channel argument is also expanded in `phi-finite-channel.md`.

## 1. Precise activation assumptions and conclusion

Fix one activation phi satisfying all the following assumptions, with constants
allowed to depend on phi:

* phi is odd, strictly increasing, bounded in (-1,1), globally 1-Lipschitz,
  and C^5 with bounded derivatives through order five.
* phi'(0)=1, phi'''(0)<0, and phi is concave on the positive half-line.
* phi'(z)>=c0 sech^2(z) for all real z, for some c0>0.
* Writing beta=lim_(z to infinity) phi(z)>0, one has
  beta-phi(z)<=C(1+z)^(-a) for z>=0 and fixed a>0.
* The strict scalar potential holds:

      log E exp(phi(sqrt(q)Z)^2) <= q-c q^2,  0<=q<=2.   (1)

The exact-slope analytic activation in `analytic-monotone-activation.md`,
sections 8--9, satisfies these assumptions. Its weighted derivative bounds
give the concavity, derivative lower bound, exponential saturation, and (1).
The construction's decay exponent can be increased to ensure any fixed finite
number of bounded derivatives; order five is already covered by its stated
choice of exponent.

Let V(q) be the scalar control value with activation phi and terminal cost
1/(8q_final), and let V*=lim_(q downarrow 0) V(q). For a Boolean function f,
let AF(f)=sum_S |fhat(S)| and put

    R=(d+L+2) AF(f),    H=L-1,    S=1+log R.

There are fixed constants C0,C1,C2 such that, whenever H>=C0 S, the original
critical Gaussian network with activation phi satisfies, at EVERY integer
width N>=R^C1,

    mu_N{ f(x) z_w(x)>1/2 for every cube input x }
           >= exp{-N[V*+C2 S^2/H]}.                    (2)

The prior in (2) has exactly the original independent weight variances
1/d, 1/N and 1/N^2. There is no support restriction and no limiting-width
interpretation in this assertion.

## 2. Scalar facts with proofs

The argument in `critical-activation-structural.md` gives

    V finite and nonincreasing,
    0<=V*-V(q)<=Cq  (0<q<=1),
    D(eta||N(0,q)) >= q_next-q+cq^2.                   (3)

Here are the main ingredients, to make the dependency explicit. Rescaling a
preactivation law when its reference variance increases preserves KL and
increases its phi-square moment. Odd C^3 regularity with phi'(0)=1 gives
F(u):=E phi(sqrt(u)Z)^2>=u-Cu^2 for small u. Inflating variance by 1+Kq,
with fixed large K, therefore increases q by between c q^2 and C q^2 at
Gaussian KL cost at most C q^2. Continuous adjustment hits any small endpoint
p exactly. Telescoping the cost/increment ratio gives a bridge from arbitrarily
small q to p costing at most Cp. Appending a fixed direct readout proves
V*<infinity and the bridge bound. Entropy duality applied to (1) gives the
last inequality in (3). Also V*>0 since, for starting q<=1, all final
variances are at most one, including a length-zero path.

Deleting a nonincreasing transition and rescaling its subsequent controls
does not increase the cost. Hence, for every sufficiently small p>0, there is
a strictly increasing scalar path from p with total cost at most V(p)+p.
Its length can be taken at most C/p and it satisfies

    sum q_j <= C log(2/p),
    sum sqrt(D_j) <= C log(2/p).                       (4)

For the quantitative claim, a near-optimal path has total cost at most a fixed
constant B. Every transition satisfies q_next/q<=Gain(B), where
Gain(B)-1-log Gain(B)=2B, by Gaussian entropy duality and phi(z)^2<=z^2.
The Bellman suffix inequality bounds the entropy spent before a state q by
p+Cq. In a dyadic band u<=q<2u, the expenditure is consequently O(u),
including its exit transition, since the exit state is at most 2 Gain(B)u.
Summed dissipation in (3) bounds the number of transitions by O(1/u), apart
from at most one exit transition. Thus that band contributes O(1) both to
sum q and to sum sqrt(D), by Cauchy--Schwarz. Summing the geometric length
bounds and the logarithmically many bands proves (4). Large states occupy
only a bounded number of transitions by the same dissipation inequality.

## 3. A polynomial-cost exact Fourier seed

For a centered Gaussian G with variance at most two, saturation gives

    beta-E phi(M+G) <= C M^(-a)+C exp(-M^2/16).         (5)

Split at G=-M/2: the complementary event uses the saturation hypothesis and
the exceptional event uses boundedness and a Gaussian tail. Thus polynomial
M in a requested inverse accuracy gives a saturated signed detector.

A parity on k input coordinates is a signed linear combination of at most
k threshold steps in their Hamming sum and a constant, with coefficient
magnitudes at most one. Each step has an affine argument separated from zero
by one on the cube. Use shifted first-row Gaussians with means equal to M
times these affine coefficients. Their noise variance is (d+1)/d<=2.
Taking detector errors O(1/(k+1)) and mixing their laws with signs implemented
by reflecting the row gives a mean g(x) whose parity-signed margin is at least
c/(k+1). The Gaussian KL of every component is at most D*=poly_phi(d), since
the first-row variance is 1/d and all shift coordinates are polynomial in d.
Convexity bounds the mixture KL by the same D*.

Average this law over cube translations x -> s*x and reflect its output row
by the parity chi_T(s). The resulting mean is EXACTLY c_T chi_T(x), where
c_T=E_x chi_T(x)g(x)>=c/(d+1). Its second-moment diagonal is constant.
Row reflections and coordinate sign changes preserve the Gaussian reference,
so the symmetrization has the same KL bound. There is no 2^d factor in KL.

Mix these laws, reflected by sign(fhat(T)), with probabilities proportional
to |fhat(T)|/c_T. This gives exact mean f/Z_f, constant second-moment diagonal,
and KL at most D*, where

    Z_f=sum_T |fhat(T)|/c_T <= C(d+1) AF(f).

Mix this law into the free first-row Gaussian with probability
theta=1/(H D*), increasing D*>=1 if necessary. Retain its Bernoulli tag Btag
and use score b_1=Btag/sqrt(theta). Then

    E b_1^2=1,
    E[b_1 h(x)]=sqrt(v_1) f(x),
    v_1=theta/Z_f^2 >= exp(-C S),
    D_1<=1/H,    |b_1|<=exp(C S).                     (6)

The reference law uses the same Bernoulli tag but free Gaussian weights in
each branch, so its weight marginal is exactly the original Gaussian and
the joint KL is theta times the active-branch KL. This is the first layer of
a scalar-channel program, not merely a population covariance inequality.

## 4. Gaussian cooling, holding, growth, and purification

For a state with component v ff^T and residual covariance of constant diagonal
r, write q=v+r. Let b(u)=E phi'(sqrt(u)Z). Taylor expansion gives

    F(u)=u+phi'''(0)u^2+O(u^3),
    b(u)=1+phi'''(0)u/2+O(u^2),
    u b(u)^2/F(u)=1+O(u^2).                            (7)

All remainders are uniform on a sufficiently small fixed interval. Bounded
derivatives and Gaussian tails justify the expansions. Moreover (1) implies
F(u)<=u-cu^2. The local lower expansion gives F(u)>=u-Cu^2.

Under a free Gaussian layer the first Hermite projection gives component at
least v b(q)^2. The total diagonal becomes F(q). Consequently the component
to diagonal ratio loses a product of factors q b(q)^2/F(q). Its logarithm is
O(q^2) near zero; on a fixed compact interval the factors have a positive
lower bound since phi'>0. Free dissipation bounds sum q^2 by a constant.
If an initial constant diagonal in (0,1] exceeds delta, cooling to its first
value <=delta takes O(1/delta) stages, ends at diagonal comparable to delta,
and retains component at least c delta times the original component. If the
initial diagonal is already <=delta, skip cooling; its diagonal remains
<=delta and the same component lower bound is automatic. All cooling stages
have zero entropy cost.

The elementary derivative bound

    1-phi'(z) <= C phi(z)^2                            (8)

holds near zero by odd C^3 regularity and away from zero by positivity of phi.
Inflate just the target Gaussian coordinate by variance factor 1+e. Its KL is
[(1+e)-1-log(1+e)]/2<=e^2/4. The next full conditional-mean component satisfies

    v_next >= (1+e)v b(q+ev)^2
            >= (1+e)v[1-C(q+ev)]                     (9)

at small q+ev, using (8) and F(u)<=u. Conditional Gaussian Poincare gives
r_next<=r. The component is continuous and increasing as a function of e;
at e=0 it is at most v by the 1-Lipschitz property.

Choose fixed large K. If q<=delta, some e in [0,Kdelta] holds v exactly,
at cost O(delta^2), preserving q<=delta. If r<=delta and v<=p with p small,
some e<=K(delta+v) realizes the prescribed next component

    v_next=min{p, v[1+c1(delta+v)]},                   (10)

for fixed sufficiently small c1>0. The growth sequence, and therefore its
length, is fixed in advance independently of the residual. Its KL is at most
C(delta+v)^2. Starting at v_0=delta exp(-C S), its length and total cost are

    number of stages <= C S/delta,
    total growth cost <= C[p+delta log(delta/v_0)].     (11)

For full steps, (delta+v)^2 is a constant multiple of
Delta v+delta Delta v/v; sum this and handle the final partial step separately.
The growth square-root cost is at most C sum(delta+v)<=C log(p/v_0)+C=O(S)
when p/delta is a fixed constant.

For purification hold v=p while r<=delta<=p. The required inflation is O(p),
at KL O(p^2), and the total Gaussian preactivation variance u is between p
and Cp. Another local expansion gives

    E phi'(sqrt(u)Z)^2=1+phi'''(0)u+O(u^2)<=1-cp.       (12)

Conditional Poincare in its derivative form yields
r_next<=r E phi'(sqrt(u)Z)^2<=(1-cp)r.
Thus C log(H+2)/p such stages leave r<=delta H^-4. Their cost is
O(p log(H+2)), and their square-root cost is O(log(H+2)).

## 5. Stable lifting of the near-optimal scalar suffix

There is a constant C with |phi''(z)|<=C phi(z) for z>0: use oddness and C^3
regularity near zero, strict positivity on a compact interval, and bounded
phi'' away from zero. If P_r is Gaussian heat convolution, then for z>=0

    e^(-Cr/2) phi(z) <= P_r phi(z) <= phi(z).           (13)

For the lower bound, g=phi''+Cphi is odd and nonnegative on the positive
half-line. Pairing the Gaussian density at y and -y gives P_s g(z)>=0 for
z>=0, so d/ds[e^(Cs/2)P_s phi(z)]>=0. For the upper bound use the same pairing
with the odd function phi'', nonpositive on the positive half-line. Bounded
derivatives justify differentiation under the semigroup. Concavity also gives
phi(alpha z)>=alpha phi(z) when z>=0 and 0<=alpha<=1.

Let a nominal scalar transition from reference variance q use law eta and
produce q_next=E_eta phi(X)^2. For an actual target component v and residual
diagonal r, use scalar physical preactivation sqrt(v/q) X and independent
residual Gaussian noise of variance r. Rescaling preserves the scalar KL.
Its conditional-mean component obeys

    v_next/q_next >= e^(-Cr) min{1,v/q}.                (14)

If v<=q, (13) and monotonicity also give v_next<=q_next. The residual remains
at most r by conditional Poincare. Starting with v=q=p, lift the increasing
near-optimal scalar path of (4). Its length is m<=C/p; purification supplied
r_0<=delta H^-4 with delta<=p. Thus

    e^(-Cm r_0) q_j <= v_j <= q_j,
    m r_0<=C H^-4.

All tracked components are at least p/2 after increasing the depth constant.
The terminal readout cost 1/(8v_m) exceeds the nominal 1/(8q_m) by at most
C H^-4, because the nominal readout cost is bounded by V(p)+p. Hidden charged
costs are exactly the scalar KL costs. In particular their square-root sum
is O(log(2/p)) by (4).

For every step the full conditional-mean score is the odd scalar function
P_r phi(physical scalar)/sqrt(v_next), of L^2 norm one and absolute value at
most v_next^-1/2. Any smaller prescribed component v' is obtained by combining
that score with an independent random sign:

    b=sqrt(v'/v_next) b_full + sqrt(1-v'/v_next) U.

It has unit second moment, coefficient sqrt(v') f, and absolute bound
1+(v')^-1/2. The reference has the same independent sign, so this costs no
entropy. This implements every deliberate component reduction above.

## 6. Exact-depth program and its quantitative resources

Take delta=B1 S/H and p=B2 S/H with fixed B2>=B1 large enough. Increase the
constant in H>=C0 S so these scales lie in the small-variance ranges of all
preceding estimates. Cool the seed (6) to delta and reduce its component to
v_0=delta exp(-C3 S), with fixed C3 sufficiently large. Its residual is at
most delta. Run the prescribed growth to p, the fixed number of purification
steps, and a fixed chosen increasing near-optimal scalar suffix.

Cooling takes C/delta stages, growth C S/delta, purification C log(H+2)/p,
and the suffix C/p. Choosing B1 and then B2 large makes their sum at most
H-1. Insert exactly the remaining number of holding stages at v_0 before
growth. The prescribed growth length is independent of this holding time,
so the total depth is exactly H, including the first seed layer.

The program's charged action A and square-root cost K satisfy

    A <= 1/H+V(p)+p
           +C[H delta^2+p+S delta+p log(H+2)+H^-4]
      <= V*+C S^2/H,
    K:=sum_(j=2)^H sqrt(D_j) <= C S.                  (15)

For K, free cooling costs zero; holding contributes O(Hdelta)=O(S); growth
contributes O(S) by (11); purification contributes O(log H); the nominal
suffix contributes O(log(2/p)) by (4). This direct calculation avoids any
inference from smaller actual feature entropies to larger charged costs.

Every positive tracked component is at least exp(-C S): this holds for (6),
for v_0, throughout growth and purification, and for the suffix by (14).
All scores consequently satisfy

    |b_j|<=B<=exp(C S).                               (16)

At every layer the ideal score/feature moments are

    E b_j^2=1,  E[b_j h_j(x)]=sqrt(v_j) f(x),
    E h_j(x)^2=v_j+r_j<=1.

The full Gaussian residual correlations may be arbitrary; only their constant
diagonal enters these one-input formulas. The conditional scalar controls and
scores define a valid full-cube controlled process by using an independent
Gaussian residual vector with the actual residual covariance at each stage.

## 7. Finite-width probability: explicit scalar-channel lemma

For clarity the following argument applies to ANY bounded 1-Lipschitz
activation and any program with the moment identities above, hidden charged
costs D_j, action A=sum D_j+1/(8v_H), distortion K=sum_(j>=2)sqrt(D_j), and
score bound B>=1. For tau>0 it gives raw mass at least e^(-N(A+tau)) whenever

    N >= C B^4 H^4 e^(4K) (A+1)^6 (1+tau^-1)^4
            [log(2m)+log(H+A+tau^-1+3)],              (17)

where m=2^d. All constants here are numerical.

For N iid score/feature rows define

    M=N^-1 sum b_i^2,
    c_hat(x)=(N^-1 sum b_i h_i(x))/sqrt(M),
    q_hat(x)=N^-1 sum h_i(x)^2,
    s_hat(x)=sqrt(q_hat(x)-c_hat(x)^2).

If their raw moments are within alpha<=1/4 of their expectations, direct
Cauchy--Schwarz and |sqrt(u)-sqrt(v)|<=sqrt(|u-v|) give component-metric error
at most 8 sqrt(alpha). The coefficients a_i=b_i/(N sqrt(M)) have norm squared
1/N, and the empirical kernel has the EXACT decomposition

    K_emp=c_hat c_hat^T+R_emp,    R_emp positive semidefinite.

For a subsequent row put u=sqrt(N)a and draw

    w=[Z u+(I-u u^T)xi]/sqrt(N),                      (18)

where (Z,auxiliaries) has the prescribed scalar control and xi is independent
standard Gaussian. Under the reference scalar law Z is standard Gaussian,
so the incoming weight marginal in (18) is exactly N(0,I/N), even conditional
on the entire preceding history. The controlled row KL is at most D_j by
data processing. Its preactivation at input x has the one-query law
c_hat(x)Z+s_hat(x)G with independent standard G.

Couple it with the ideal sqrt(v)f(x)Z+sqrt(r)G. Gaussian entropy duality gives
E Z^2<=exp(2sqrt(D_j)), hence preactivation and feature RMS error at most
exp(sqrt(D_j)) times the previous component-metric error. Projection onto
the common unit score and the reverse triangle inequality for orthogonal
residual norms preserve this same bound. Fresh empirical sampling therefore
gives recursively

    e_H <= 8H e^K sqrt(alpha).                        (19)

These are one-query comparisons; the actual network always has its usual
joint Gaussian residual law on the full cube. No simultaneous matching of
ideal residual correlations is being assumed.

Conditional on previous layers, the fresh observables b^2, b h(x), h(x)^2 are
bounded by B^2, B and one. Hoeffding and successive conditioning give all
required moment estimates with probability at least 1-kappa/2 whenever

    N >= C B^4 alpha^-2 log[8H(2m+1)/kappa].           (20)

Stop controlling and use the original prior if M falls outside [1/2,3/2].
This makes the process defined on all histories; the good event never stops.

Choose

    kappa=min{1/4, tau/[32(A+1)]},
    alpha=[kappa sqrt(v_H)/(64H e^K)]^2.

Then (19) gives final coefficient signed margin at least
sqrt(v_H)(1-kappa/8). On this good event shift the readout mean to t a, where
t=(1+kappa)/(2sqrt(v_H)); otherwise leave its mean zero. The mean output
exceeds 1/2+kappa/4 everywhere. Its remaining Gaussian noise has variance at
most 1/N at each input, so N>=C kappa^-2 log(4m/kappa) makes its maximum less
than kappa/8 with probability at least 1-kappa/2. The controlled law Q_N thus
has strict global target margin with probability at least 1-kappa.

Conditional chain rule, the exact Gaussian reference in (18), and the initial
tag reference from (6) give

    KL(Q_N||mu_N) <= N[sum D_j+(1+kappa)^2/(8v_H)]
                  <= N(A+3A kappa).

Discarding auxiliaries only decreases KL. Binary entropy for the target event
then gives

    -N^-1 log mu_N(E_f)
       <= [A+3A kappa+N^-1 log 2]/(1-kappa)
       <= A+tau,

using N>=8/tau. Finally v_H^-1<=8A shows that (17) implies (20), the Gaussian
readout bound, and N>=8/tau. This proves the finite-width lemma.

Apply it with (15)--(16), tau=1/H, and m=2^d. Every factor in (17) is bounded
by exp(C S), since H,d<=exp(S), K<=CS, B<=exp(CS), and A+1<=C(1+S).
The extra 1/H cost is absorbed by C S^2/H. This proves the actual raw mass
theorem (2) at every N>=R^C.

## 8. Complete critical posterior consequence for the contrived activation

The scalar assumptions (1), (3) imply the occupation and entropy budgets,
and hence the canonical TC^1 theorem, exactly as proved in
`critical-activation-structural.md`. The bounded-dual finite-event certificate
uses bounded products of features; its proof is unchanged for phi. Consistent
path transfer uses only its 1-Lipschitz property and Gaussian entropy duality.
Thus `critical-parallel-converse.md`'s full-cube ceiling applies with V_phi,*:
at widths N>=2^(Cd)(d+n+L)^C, the actual critical posterior puts mass at least
31/32 on functions represented by Boolean circuits of size poly(d+n+L),
provided L>=C log(d+n+L). The denominator comes from (2), since the memorizer
1-2 sum_(negative sample points p) 1_{x=p} has Fourier variation at most 1+2n.
This ceiling is uniform over every consistent sample of at most n inputs.

The hard tables f_d in `analytic-monotone-activation.md` have uniform error
at least 7/16 against EVERY Boolean circuit of size at most 2^(d/4).
The fixed analytic activation encodes these tables, and its bounded-weight
teachers have depth L_d=Dd+O(1), width and weight bound polynomial in d.
Choose c>0 sufficiently small that, for n<=exp(cd), both

    poly(d+n+L_d) <= 2^(d/4),
    L_d >= C log(d+n+L_d)

hold eventually. Then at every N>=exp(C' d), for every such sample, posterior
Gibbs error under the uniform input law is at least

    (31/32)(7/16)=217/512.

If p is the fraction of inputs where correct-label posterior confidence fails
to exceed 2/3, Gibbs error is at most 1/3+(2/3)p. Consequently

    p >= (3/2)(217/512-1/3)=139/1024>1/8.

This is a genuine exponential-in-depth sample lower bound for this ONE fixed
odd, strictly increasing, strictly concave-on-positive-inputs, bounded,
real-analytic, 1-Lipschitz activation, arbitrarily C^r-close to tanh, at the
critical exponent gamma=1. Together with the separately proved fixed-gap
gamma>1 result, it gives the proposed all-gamma>=1 activation counterexample.
The construction changes the activation and therefore leaves the original
exact-tanh joint-depth question unresolved.
