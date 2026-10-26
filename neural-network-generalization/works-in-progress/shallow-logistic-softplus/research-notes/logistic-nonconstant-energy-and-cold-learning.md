# Logistic complementary rails match the nonconstant cold-energy baseline

25 October 2026. Scratch derivation for the STANDARD logistic activation
s(z)=1/(1+exp(-z)), no internal biases, augmented Boolean inputs, linear
readout, and the original all-cube absolute-margin/exact-label posterior.
Sections 1--5 give a strong-prior result. Sections 6--8 extend it to
each fixed exponent gamma>1 by a finite-width Gaussian-distance argument.
The exact critical exponent and arbitrary fixed positive prefactors remain
outside the result. No step divides a both-label posterior by the
constant-sign normalization from the separate ordering note.

## 1. The deterministic nonconstant baseline is 16L

Use the isotropic energy coordinates of the finite-width note,

    A1=sqrt(d/N) W1,  Aj=Wj internally,  AL=sqrt(N) v,
    kappa=sum_j ||Aj||_F^2.

The normalized hidden activation is s(sqrt(N)u)/sqrt(N), which has
Lipschitz constant 1/4. A globally absolute-margined nonconstant truth
table has opposite labels on some cube edge x,y. Their normalized
input distance is 2/sqrt(d), while |z(x)-z(y)|>1. Therefore

    product_j ||Aj||_F > 4^(L-1) sqrt(d)/2,
    kappa >= 16 L exp[(log d-log 64)/L].                       (1)

In particular kappa>=16L-16log64. This is a deterministic minimum-energy
lower bound. It is not a Gaussian path-rate statement at finite t.

## 2. An exact scalar transmission lemma with the matching coefficient

Take any one-hidden-layer logistic network g(x)=u·h1(x), of global signed
margin at least one. Let its first energy be E1 and weighted readout
energy D=N||u||^2. Assume N>=2 and L>=3.

There is a depth-L logistic network with the same target signs, global
signed margin at least one, and energy at most

    E1+16(L+12) max(1,D/16)^(1/(L-1)).                         (2)

Proof. Use M=2floor(N/2) active units in every new hidden layer; any
unused unit has zero incoming and outgoing weights. Split the active
units into two equal groups. The identity

    s(2z)-s(-2z)=tanh z

realizes a scalar tanh state r as the difference of the two group averages.
Let a have entries +2/M and -2/M in the two groups, and zero elsewhere.
Then ||a||^2=4/M, and a·h=r.

Set m=L-1. The existing elementary scalar-transmission lemma supplies
positive alpha,b2,...,b_(m-1),c with

    r1=tanh(alpha),  rj=tanh(bj r_(j-1)),  c r_(m-1)=1/2,
    (D/4)alpha^2+sum bj^2+c^2 <= (m+12)q^2,
    c^2=q^2,  q^2=max(1,D/16)^(1/m).

Here the lemma is used with its first coefficient D/4. It is proved in
the existing scalar-transmission source
`works-in-progress/unrestricted-depth/source/unrestricted-background-productnorm.tex`,
Lemma `scalar-transmission`; it is a finite scalar construction, not a
posterior theorem.

For the first added logistic layer use M rows +/-2 alpha u. Its energy is
4M alpha^2||u||^2<=4D alpha^2. For a subsequent layer use M rows
+/-2 bj a^T. Its Frobenius energy is exactly 16 bj^2. The final readout
is 2c a, of weighted energy

    N||2c a||^2=16(N/M)c^2<=32c^2.

Thus total energy is at most

    E1+16[(D/4)alpha^2+sum bj^2+c^2]+16c^2
      <= E1+16(m+13)q^2,

which is (2). Monotonicity of the scalar tanh chain gives signed output
at least one whenever |g(x)|>=1. Odd learner widths do not alter the
coefficient 16: ignoring their one surplus unit avoids a per-layer
rounding loss.

## 3. Polynomial first-layer resources give only logarithmic excess

Suppose the shallow teacher has width C and physical weights bounded by
B, with unit signed margin. Zero-pad it first to an integer

    M0 >= max{C,2,d C(d+1)B^2}.

Its first energy is at most one and weighted readout at most M0 C B^2.
Balanced cloning from M0 to any N>=M0 gives E1<=2 and D<=2M0 C B^2.
Consequently (2) supplies a common polynomial T=T(d,C,B)>=1 such that

    kappa <= K_L:=2+16(L+12)T^(1/(L-1)).                        (3)

For L-1>=log T this is 16L+O(log T+1). More importantly, without that
depth restriction,

    4[(K_L+1)/(16L)]^(L/2) <= 4 exp(13/2) T^(3/4),    L>=3.    (4)

The L=2 teacher itself has polynomial energy and gives the analogous
polynomial bound directly.

The coefficient of L in (3) matches (1). Hence early computation followed
by complementary logistic rails does not impose a larger linear-in-depth
cold-energy penalty on shallow targets such as parity.

## 4. Centering an arbitrary logistic network yields a small-product class

Fix one cube anchor x0. In normalized hidden coordinates let
u_j(x)=h_j(x)/sqrt(N), and subtract the anchor at every stage:

    delta u_j(x)=u_j(x)-u_j(x0).

Writing b_i=(Aj u_(j-1)(x0))_i, one has

    delta u_(j,i)(x)=a_(b_i,N)((Aj/4) delta u_(j-1)(x)),
    a_(b,N)(r)=[s(sqrt(N)(b+4r))-s(sqrt(N)b)]/sqrt(N).

Each a_(b,N) fixes zero and is 1-Lipschitz. Thus the centered computation
has product norm

    P=4^(-(L-1)) product_j ||Aj||_F
      <= 4 [kappa/(16L)]^(L/2).                              (5)

The input difference has norm at most two. The output is

    z(x)=z(x0)+AL delta u_(L-1)(x).

If the truth table is nonconstant and globally absolute-margined, some
point has the opposite output sign to x0. Therefore

    |z(x0)| <= |z(x0)-z(y)| <= 2P.                           (6)

Constant functions can be treated separately. No original bias or
activation-shift precision is assumed in (5)--(6).

We use the already proved universal zero-preserving 1-Lipschitz
product-cover result in `logarithmic-prefix-cover.md`: globally margined
Boolean classifiers of product at most P admit descriptions of bit length
polynomial in d+P, independently of original width and depth, when
individual neuron activations may be arbitrary zero-preserving
1-Lipschitz maps. Its proof compresses the first O(log P) layers and
stores finite-resolution activation tables. A bounded final scalar
offset as in (6) costs only an additional polynomial description; the
constant truth tables are added separately. The fixed affine input shift
by x0 also costs only polynomial resources: retain all d coordinates and
use input radius two, without invoking a junta reduction for shifted inputs.
Double an absolute-margin-1/2 output before applying the cover's unit-margin
convention; this changes the product and offset bounds by fixed factors.

Thus the sign functions in the energy range kappa<=K_L+1 form a finite
class with log-cardinality polynomial in d+C+B, uniformly in N and L,
by (4)--(6). This is a finite Boolean class bound, not an assertion that
the original logistic parameters themselves have bounded precision.

## 5. What follows for the strong-prior posterior

At any fixed finite architecture, an actual positive-margin witness of
energy at most K has the following elementary cold property:

    posterior{kappa>K+eta} -> 0  as sigma^2->0               (7)

for every eta>0, uniformly over samples labeled by its target. Take a
small neighborhood of the witness retaining its margin and energy at
most K+eta/2. Its Gaussian mass is bounded below by a constant times
sigma^(-p) exp[-(K+eta/2)/(2sigma^2)]. The Gaussian energy tail above
K+eta is at most a polynomial in sigma^(-1) times
exp[-(K+eta)/(2sigma^2)]. Their ratio tends to zero. A direct Chernoff
choice lambda=(1-sigma^2)/(2sigma^2) also gives this with the same
sigma^(-p) prefactor. Both conditioning events remain in the denominator.

Apply (7) to (3), with eta=1. Every limiting sign posterior is supported
on the common finite class from Section 4 and remains sample consistent.
Finite-class consistency and the Gibbs-to-confidence conversion therefore
give a sample bound polynomial in d+C+B and the usual accuracy/confidence
parameters, uniformly over N>=M0 and L>=3. The same argument covers
L=2 using its direct polynomial energy bound.

For C<=N<M0, the ordinary finite-architecture tanh counting bound may not
be imported verbatim for logistic, but logistic is a fixed sigmoid
Pfaffian activation and has the same polynomial-in-parameter-count VC
bound. Alternatively, its bounded output and bounded derivatives give
an elementary parameter-neighborhood/energy-net proof as in the new
finite-width posterior cover: normalized hidden state norms are at most
one, so the log of the parameter Lipschitz constant is O(L log(2+K)).
Cap the teacher-neighborhood cube's half-side at sigma, exactly as in
the finite-width posterior cover, so its conditional energy estimate
introduces no log(1/t) divergence at small positive scales.
The paired witness has physical weights polynomial in the shallow
teacher resources, and N<M0 is polynomial in those resources. Either
route gives a polynomial sample upper in d,C,B,L for these remaining
widths. The energy-net route avoids any new Pfaffian dependence.
If N=1, the target is necessarily constant because the final hidden
activation is positive; one example then determines the readout sign
and the entire truth table. The paired construction is needed only for
N>=2.

Conclusion, subject only to the previously proved universal Lipschitz
cover input stated explicitly in Section 4: every bounded-weight
one-hidden-layer logistic teacher has polynomial strong-prior sample
complexity at every eligible finite learner width and depth. A parity
on d input bits has a one-hidden-layer logistic realization with
O(d) neurons and polynomial weights, by thresholding the integer-valued
sum of its bits and alternating the output step coefficients. Thus
parity cannot provide an exponential-depth counterexample in this
strong-prior logistic setting.

## 6. Polynomial operator stability of the planted paired witness

Fix an upper bound D0>=D and use this upper bound in the scalar construction.
Write D'=max(D0/4,4), T=D'/4>=1, m=L-1. The explicit scalar-transmission
construction has

    q=T^(1/(2m)),  k_s=min(s,m-s),
    r_s=q^s/(sqrt(D') k_s),
    b_s=q (k_(s-1)/k_s) [atanh(r_s)/r_s].

It satisfies r_s<=1/(2q k_s), sum_s r_s^2<=1, and q^m=sqrt(T).
Thus every consecutive product of the b_s is at most

    C m q^m <= C L sqrt(T),                                  (8)

by telescoping the k-ratios and using atanh(r)/r<=exp(r^2/2).
The first added layer's normalized Lipschitz gain is
||A_2^*||_op/4<=Cq, and the final readout norm is at most Cq.
Including either endpoint preserves a bound polynomial in L,T.

Now perturb EVERY energy-coordinate matrix by a matrix of operator norm
at most eta (Euclidean norm for the readout). All normalized logistic
hidden states, including those of the perturbed network, have norm at
most one. If e_j is the state difference, the exact decomposition

    (A_j^*+B_j)u_j^pert-A_j^*u_j^* = A_j^*e_j+B_j u_j^pert

and derivative<=1/4 give, with the obvious preceding-state indices,

    ||e_j|| <= (||A_j^*||_op/4)||e_(j-1)|| + eta/4.

For the first layer the forcing is at most sqrt(2)eta/4. Iteration and
(8), followed by the final readout, prove the GLOBAL perturbation bound

    sup_x |z_(A^*+B)(x)-z_(A^*)(x)| <= C L^2 T eta.             (9)

The constant can be enlarged for L=2, where the shallow witness itself
has first energy<=2 and readout energy<=D0. This proof uses the explicit
wire's partial products, not a false claim that its total energy controls
all partial products polynomially. It also does not need to track a
perturbed anchor or preserve exact complementary pairs after perturbation.

## 7. Actual finite-scale posterior subtraction with frozen anchor maps

Use the same Gaussian set Tcal as in the existing Gaussian-distance
posterior theorem: in isotropic parameter coordinates, it is closed,
convex and centrally symmetric, has raw Gaussian probability at least
1/2, and each matrix block has operator norm at most t b, where

    b^2=max{2(d+1)log2+4log8, 16log9+8log(8L)}.

This Gaussian statement is independent of the activation. Assume

    t b <= xi := c/(L^2 T)                                  (10)

for a sufficiently small universal c. By (9), the shift A_*+Tcal
lies inside global clean margin with the target's signs. Its Gaussian
mass is at least (1/2)exp[-K_L/(2sigma^2)], by symmetry of Tcal and
the Gaussian shift identity. This is a lower bound for EVERY sample
conditioning event labeled by the target.

Gaussian isoperimetry then gives

    Q_S{dist(A,Tcal)^2>K_L+1} <= 2exp[-1/(2sigma^2)].           (11)

On the complementary event take the Euclidean metric projection B of
A onto Tcal and put U=A-B. Thus kappa(U)<=K_L+1 and every B-block has
operator norm at most t b.

Here the surrogate construction deliberately enlarges the representation
class. Center the REALIZED network A at the fixed input anchor, and
freeze all its exact scalar maps a_(b_i,N) from Section 4. Its centered
linear blocks are A_j/4. Replace those linear blocks by U_j/4, retaining
the frozen zero-preserving 1-Lipschitz scalar maps. Retain the actual
final anchor output as an additive constant. This surrogate need not be
a native logistic network with internally consistent biases; it only
needs to belong to the universal Lipschitz representation class used
for counting. The original activation shifts are NOT recomputed after
the matrix subtraction.

The usual zero-preserving Lipschitz perturbation estimate now applies
uniformly to this centered representation. To see the bound explicitly,
divide all U-blocks, including the readout, by four and put a factor four
outside the final scalar network. Their total energy is at most
Knorm=(K_L+1)/16. The input difference norm is at most two and block
perturbations have norm at most eta=t b/4. Telescoping gives output error
at most

    8 L eta [(sqrt(Knorm)+sqrt(L)eta)^2/(L-1)]^((L-1)/2).      (12)

For eta satisfying (10), the bracketed power is at most C sqrt(T):
Knorm<= (L+13) T^(1/(L-1)), and the perturbation adds at most a
constant to this energy. The remaining ratio has the form
(1+C/(L-1))^((L-1)/2) T^(1/2). Thus (12) is at most 1/8 after
decreasing c. For L=2 use its direct polynomial K bound and the same
conservative condition (10).

The surrogate has exactly the posterior network's signs everywhere,
with absolute margin greater than 3/8. Its product is polynomial in T
by (4)--(5). If its truth table is nonconstant, its retained anchor
offset is automatically bounded by twice that product; constants are
included separately. The universal Lipschitz cover therefore supplies
ONE finite Boolean class of log-cardinality polynomial in d+C+B,
independent of N,L and the realized sample, containing posterior mass
at least 1-2exp[-1/(2sigma^2)].
The margin greater than 3/8 is converted to unit margin by multiplying
the final output by 8/3, again only a fixed factor in the product bound.

This supplies the finite-scale normalization missing from a mere energy
comparison. The centering trick avoids an unnecessary requirement that
the Gaussian-subtracted surrogate remain a native logistic network.

## 8. Fixed exponents gamma>1 and the remaining critical case

Fix zeta>0 and take sigma^2<=N^(-(1+zeta)), so t<=N^(-zeta/2).
Conditions N>=M0, (10), and 2exp[-1/(2sigma^2)]<=beta are satisfied
above a threshold polynomial in

    d,C,B,L,log(2/beta),

whose degree depends only on zeta. On those widths, finite-class
consistency plus (11) gives polynomial sample complexity for the shallow
teacher, with the same Gibbs-to-confidence conversion as before. For
example take finite-class error and posterior exceptional mass both at
most epsilon/12; the confidence-failure mass is then at most epsilon/2,
leaving slack at the inclusive 2/3 threshold. At
widths below this threshold, the elementary bounded-output energy/net
argument from Section 5 gives a polynomial sample bound because N
itself is polynomial in the displayed resources. This proves an
all-width polynomial sample upper for each fixed exponent gamma>1,
as well as the cold statement.

The conclusion covers one-hidden-layer bounded-weight logistic targets,
including parity. It does NOT prove the corresponding theorem at gamma=1
or uniformly over arbitrary positive fixed prefactors t<=1: then t b
need not be polynomially small, and (10) fails. Nor does it give an
all-depth-teacher polynomial bound. Those are the remaining regimes in
which a standard-logistic exponential-depth counterexample could still
be sought; raw output ordering alone does not resolve them.
