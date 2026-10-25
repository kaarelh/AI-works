# Nearcritical occupation and transport: independent derivation

25 October 2026. Scratch mathematical audit and proof, not a public manuscript
or Lean verification. This note supplies a direct spectral Lyapunov argument,
checks the high-variance cooling estimate, and derives the proposed transport
exponent. The finite-array quality estimates remain explicit inputs from the
companion empirical-quality construction.

Write t=1+e with 0<e<=e0, where e0 is a sufficiently small absolute constant.
Let m=2^d, D=d+1+log(1/e), and let a finite empirical covariance path have
positive diagonals q_i and correlation matrix C. Put

    q=max_i q_i, X=lambda_max(C)-1, Y=1-lambda_min(C),
    v_j=the array quality, z_j=sqrt(v_j)+v_j,
    B=sum_j v_j, Z=sum_j z_j.

The entering augmented-cube covariance has q<=2; every later tanh covariance
has q<=1. All constants below are independent of e,m,H. Fixed thresholds and
the constants defining the variance band may affect them.

## 1. Empirical inputs being used

Let T(q)=E tanh^2(t sqrt(q)G). For a population transition write C_f for its
normalized covariance. The needed quality estimates are:

1. Scalar logarithmic error is at most C z_j, simultaneously in coordinates.
2. The pair-gap logarithmic loss is at most C z_j relative to the free next
   gap at small quality, and relative to the entering gap at large quality.
3. At small absolute quality,

       ||C_new-C_f||op <= C(1+X) z_j.

4. At large quality, lambda_max(C_new)<=exp(C z_j)lambda_max(C).

The first two are the square-root quality improvement. The last two are the
normalized matrix-quality bounds. A single rotation-invariant quality can be
used. These hypotheses, including the uniform all-quality lower-normalization
bound, are essential: scalar or entrywise covariance concentration alone is
not enough for the conclusions below.

## 2. Exact unital-Schur monotonicity and the spectral lower comparison

For each q_i>0, let a_k(q_i) be the Hermite coefficients of

    phi_q(G)=tanh(t sqrt(q)G)/sqrt(T(q)).

Only odd k occur, and sum_k a_k(q_i)^2=1. With diagonal A_k formed from these
coefficients,

    C_f=sum_(k odd) A_k C^(Hadamard k) A_k
       = C Hadamard M,
    M=sum_(k odd) A_k C^(Hadamard (k-1)) A_k.

Each summand defining M is PSD, even if some Hermite coefficients have
different signs. The zero-th Hadamard power is the all-ones matrix. Also
diag(M)=1. Its Schur multiplier is therefore positive and unital. Applying it
to lambda_min(C)I<=C<=lambda_max(C)I gives, at every free step,

    X_f<=X,       Y_f<=Y.                              (1)

No variance-band or pair-correlation assumption is required.

A useful additional detail is needed when comparing empirical errors to the
free state. On q_i in(0,2], the positive first Hermite coefficient is bounded
away from zero uniformly for t in[1,1+e0], including its limit one at q=0.
Consequently

    C_f >= A_1 C A_1,
    lambda_max(C_f) >= c lambda_max(C).                (2)

For example, the second inequality follows from the operator norm of
C^(1/2) A_1 and min_i a_1(q_i)>=sqrt(c). Thus 1+X_f and 1+X are comparable.
This closes a small implicit step in a logarithmic potential argument: the
quality error is bounded by C(1+X)z, whereas the derivative of the potential
is evaluated near X_f. One cannot omit this comparison without explanation.

## 3. Spectral contraction on regular steps

Fix constants 0<a<A. A regular entering state has q_i in[a e,A e] and all
off-diagonal |C_ij|<=rho, where rho>0 is a sufficiently small fixed constant.
The Hermite expansion gives

    c e^2 <= beta_i:=1-a_1(q_i)^2 <= C e^2.

For every correlation matrix,

    sum_(j!=i) C_ij^2=(C^2)_ii-1<=X.

Writing C_f-I=A_1(C-I)A_1+R, the nonlinear remainder satisfies

    |R_ij| <= sqrt(beta_i beta_j)|C_ij|^3,
    ||R||op <= C e^2 rho X.

Choose rho small enough. Then

    X_f <= (1-c e^2)X.                                (3)

When X<=1, the same row-square identity gives max|C_ij|<=sqrt(X), so

    Y_f <= (1-c e^2)Y+C e^2 X^(3/2).                  (4)

For (4), the small pair threshold is unnecessary. These statements agree
with Sections 1–3 of nearcritical-spectral-occupation.md.

## 4. A composite potential avoids repeated recovery costs

Fix a desired lower spectral threshold y0>0 and choose b>0 sufficiently
small, with b<1, so that C(b/2)^(3/2)<=c y0/2 in (4). Define

    P_b(X)=log(1+X/b),
    g(X)=1                     if 0<=X<=b/2,
         2-2X/b                if b/2<X<b,
         0                     if X>=b,
    W(X,Y)=8 P_b(X)+g(X)Y.

The particular coefficient eight can be replaced by any number greater than
four. Since -g'(X)<=4 P_b'(X) wherever the derivatives exist,

    g(X_f)-g(X)<=4[P_b(X)-P_b(X_f)]    whenever X_f<=X.

Using (1) and 0<=Y<=1,

    W(X_f,Y_f)-W(X,Y)
       <= -4[P_b(X)-P_b(X_f)] <=0.                    (5)

Thus every free transition is nonincreasing for W, including all scalar- or
pair-irregular transitions. On a regular step with X>=b/2, (3) gives

    P_b(X)-P_b(X_f)
       >= c e^2 X/(b+X)>=c e^2/3.

If X<b/2 and Y>=y0, g(X)=g(X_f)=1 and (4) gives a decrease of at least
c y0 e^2/2. Therefore, for a universal c1>0 depending on the fixed thresholds,

    W(X_f,Y_f)-W(X,Y)
       <= -c1 e^2 1_{regular and (X>=b/2 or Y>=y0)}.   (6)

### Perturbation of the composite potential

At small quality, (2) and the operator error in Section 1 give

    |P_b(X_new)-P_b(X_f)|<=C_b z.

The cutoff term also changes by at most C_b z. To see this uniformly in
dimension and X, first take z below a sufficiently small fixed cutoff. If
X is larger than a fixed constant depending on b and (2), both X_f and
X_new exceed b, so both cutoff terms vanish. Otherwise X is bounded, and
the operator error bounds both |X_new-X_f| and |Y_new-Y_f| by C_b z.
Since g has Lipschitz constant 2/b, the conclusion follows. If z lies
between this smaller cutoff and the original fixed quality cutoff, the
bounded cutoff term is absorbed in C_b z, and the logarithmic bound follows
from the corresponding multiplicative upper bound. This gives

    W(X_new,Y_new)<=W(X_f,Y_f)+C_b z

at small quality, after fixing universal cutoffs.

At large quality, Section 1 gives P_b(X_new)-P_b(X)<=C_b z, and the cutoff
term changes by at most one, also at most C_b z. The missing negative term
in (6) is at most c1 e^2 and is absorbed because z is then bounded below by
a fixed positive constant. Combining cases,

    W_new-W <= -c1 e^2 1_{regular and spectrally bad}+C_b z.  (7)

Initially X<=m-1 and Y<=1, so W_0<=C(1+log m). Since W>=0, summation yields

    #{regular entering states with X>=b/2 or Y>=y0}
       <= C e^-2(1+log m+Z).                         (8)

This proof needs no restart charge per scalar-bad step, high-X step, or
high-X episode. Hysteresis gives another valid proof, but (7) is a single
Lyapunov inequality that displays why a second inverse spectral-gap factor
does not occur.

## 5. Scalar and pair occupation with explicit epsilon powers

For completeness, the familiar scalar and pair potentials give the needed
regular-state occupation at the same scale. Put q_*=e+O(e^2), and

    V_scalar=max_i |log(q_i/q_*)|.

The free scalar map is increasing, fixes q_*, and has T(q)/q decreasing.
Uniformly for 0<q<=2,

    |log(T(q)/q_*)|
      <= |log(q/q_*)|-c e min(|log(q/q_*)|,1).        (9)

Near q_* this follows from logarithmic derivative 1-c e. Below or above a
fixed relative neighborhood, the logarithmic displacement is at least c e;
as q approaches zero its limit is 2 log t. Taylor estimates on q=O(e) and
compactness/cooling on larger q give uniform constants. The scalar quality
error adds C z. The right side of (9) is increasing as a function of the
entering potential when c is reduced. Taking the maximum and summing gives

    #{variance-band-bad entering states}<=C e^-1(D+Z). (10)

Let U=max_(i!=j) -log(1-|C_ij|). Free transitions never increase U. In the
variance band, the first Hermite coefficients and the nonlinear mass give

    |C_f,ij| <= lambda |C_ij|+(1-lambda)|C_ij|^3,
    lambda<=1-c e^2.

This uses Cauchy–Schwarz on the higher coefficients; unequal variances do
not change the estimate. When the maximum pair correlation exceeds the
fixed rho, U decreases by at least c_rho e^2. The quality pair-gap bound
adds C z, with missing free decrements at large quality absorbed in the
same term. Initially U_0<=log(d+1). Therefore

    #{variance-good, pair-bad states}<=C e^-2(D+Z).

Adding (10), then (8), proves

    #{states outside a fixed relative white operator ball
       and the band q_i in[a e,A e]}
       <= C e^-2(D+Z).                              (11)

The spectral thresholds b/2,y0 can be chosen inside any prescribed
sufficiently small fixed operator ball used by the local coupling lemma.

## 6. High-variance square-sum cooling

The correct elementary bound for t=1+e is

    T(q)<=q+3e q-c q^2,       0<=q<=2,              (12)

after reducing e0 and c. The coefficient 2e alone would be incorrect at
arbitrarily small q because T'(0)=(1+e)^2. To prove (12), use
F(u)<=u-c0 u^2 on the compact relevant interval, with its positive limiting
quadratic coefficient at zero, and t^2<=1+3e.

Choose a=A0 e with A0 a sufficiently large fixed constant, and put
E(q)=(q-a)_+. The scalar quality bound and monotonicity give

    q_new<=min(1,exp(C z)T(q))

after the first step. At small quality z<=C sqrt(v), expansion of (12)
at q=a+u gives

    T(a+u)-a
       <=u-c u^2-(2cA0-3)e u-(cA0^2-3A0)e^2.

Take A0 so the last two coefficients are positive. The empirical increase
is at most Cq sqrt(v). Split it into Cu sqrt(v)+CA0 e sqrt(v), and use
Young's inequality to absorb the first term into half the negative u^2
term plus Cv. For q<=a, monotonicity and T(a)<=a give directly
E(q_new)<=C e sqrt(v)+Cv. Reducing a fixed c1 if necessary makes
u-c1 u^2-c1 e u nonnegative throughout the bounded q range. Hence positive
parts can be removed to obtain

    E(q_new)<=E(q)-c1 E(q)^2-c1 e E(q)
                     +C[v+e sqrt(v)].              (13)

At large quality, q_new<=1 and E(q) is bounded; the same inequality follows
by increasing C because v is bounded below. The first entering q<=2
contributes only another absolute constant. Summation gives

    sum_j E(q_j)^2+e sum_j E(q_j)
       <=C[1+B+e sum_j sqrt(v_j)].                 (14)

In particular, q>2A0 e implies E(q)>q/2, so

    sum_{j:q_j>2A0 e} q_j^2<=C(1+B+e Z).            (15)

All sums here are over entering states of the corresponding transitions.
For two transported paths, apply (15) to each and use that the square of
their maximum is bounded by the sum of their squares on the relevant
high-variance sets, adjusting the threshold if necessary.

## 7. Global normalized gain and the resulting exponent

The joint distance used in the companion coupling note is

    dist^2=d_B(C,C')^2+sum_i log(q_i/q'_i)^2.

Its population global estimate extends from q=O(e) to the entire compact
range q<=2:

    dist(next free states)<=exp(C qmax^2)dist(states), (16)

where qmax=max_i(q_i,q'_i). Indeed the Hermite derivative weight J(q)
satisfies J(q)<=1+Cq^2, and ||partial_q phi_q||L2<=C on[0,2]. These follow
from the cancellation at zero and compactness elsewhere. In the optimal
rowwise Gaussian coupling, Hermite orthogonality separates the coefficient
difference from the angular term. The coefficient difference is at most
C(q-q')^2<=C qmax^2 log(q/q')^2. The log-variance map has derivative at most
one, so no uncharged radial cross term arises.

With the companion uniform mixed-secant, matrix-derivative, and
lower-normalization quality bounds, the global log gain is

    C qmax^2+C z_j,

and on common fixed white operator balls with variances in[a e,A e] the
local log gain is -c e^2+C z_j. The latter follows from the population
contraction at scale e^2 and empirical derivative error C z_j. If only a
small-quality local theorem is stated, steps above its quality cutoff can
instead use the global bound; the lost e^2 decrement is absorbed by C z_j.

Apply occupation (11) to both paths. On nonwhite steps with qmax<=2A0 e,
the total loss relative to -c e^2 per step is at most C e^2 times the number
of such steps, bounded by C(D+Z). High-variance steps cost at most their
square sum (15), plus the already bounded missing local decrements. Thus

    log(total metric gain)
       <=-c e^2 H+C(D+B+Z+1).                     (17)

This is the claimed sharper exponent. Since Z<=sqrt(HB)+B and the new
all-label mass witness gives B<=C0(1+e^2D), take

    H>=K(e^-4+e^-2D)=K e^-4(1+e^2D).

For K sufficiently large compared with fixed constants, the positive
square-root term is absorbed and (17) is at most -c' e^2H. The initial
joint distance of sign-conjugate cube covariances is at most C sqrt(m),
which adds only O(D) to an absolute-error exponent.

## 8. Verdict and remaining interface

The occupation, high-variance cooling, and deterministic gain summation
pass this independent audit. No counterexample to the proposed sharpening
was found. Two details should be explicit in a final proof: use 3e rather
than 2e in (12), and include the first-Hermite spectral comparability (2)
when bounding empirical logarithmic potential increments.

This note does not independently reprove the entire finite-array empirical
quality construction, the optimized all-label mass lower bound, or the
finite-width readout likelihood comparison. Those are separate inputs.
Accordingly, (17) is a proved deterministic transport conclusion from the
listed quality hypotheses, not by itself a finished finite-N posterior
flatness or sample-complexity theorem.
