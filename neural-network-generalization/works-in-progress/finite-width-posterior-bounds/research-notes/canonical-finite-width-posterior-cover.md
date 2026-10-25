# A quadratic-in-width sample upper bound for the actual canonical posterior

25 October 2026. Scratch result. This is an actual finite-width posterior
bound at every common Gaussian prefactor 0<t<=1. It sharpens the generic
finite-architecture count for bounded-weight, globally margined teachers.
It does not give a width-independent or polynomial-in-depth learning theorem.

## 1. Statement

Let d>=1, L>=2, and N>=C>=1. There are L matrices: L-1 tanh hidden
layers of width N and a linear readout. The input is augmented by a
constant coordinate. The independent Gaussian prior variances are

    t^2/d,   t^2/N,   t^2/N^2,

in the first matrix, internal matrices, and readout, respectively, with
0<t<=1. Condition this prior on |z(x)|>1/2 at every Boolean input and
then on exact training labels from a Boolean target f.

Assume f has a width-C teacher at the same matrix depth L whose physical
weights have magnitude at most B>=1 and whose signed output is at least
one at every Boolean input. A teacher with margin at least 1/2 is reduced
to this convention by doubling its readout and replacing B by 2B.

Set

    p = N(d+2)+(L-2)N^2,
    S = d+C+L+B+2.

For every input distribution, 0<epsilon<1, and 0<delta<1, a sufficient
sample size for posterior confidence-failure mass at most epsilon with
probability at least 1-delta is

    n >= (C0/epsilon) [p L log(S+N+epsilon^(-1)) + log(1/delta)],   (1)

where C0 is universal. Here confidence fails at x when the posterior
probability of the correct sign is at most 2/3. The bound is uniform in
t, including schedules depending on d,L,N and all strong-prior limits.

For fixed accuracy and confidence, this is

    O([Nd+LN^2] L log(d+C+L+B+N+2)).                              (2)

The only dependence on the physical teacher weight bound is logarithmic.
No Pfaffian/VC estimate or limiting-width theorem is used.

## 2. Isotropic energy coordinates and a cloned teacher

Write

    A_1=sqrt(d/N) W_1,  A_j=W_j (2<=j<L),  A_L=sqrt(N) v.

The concatenated parameter A belongs to R^p, with independent coordinates
N(0,sigma^2), where sigma^2=t^2/N<=1/N. Its energy is

    kappa(A)=sum_j ||A_j||_F^2=||A||_2^2.

In normalized hidden coordinates, the network takes input
u_0(x)=(1,x)/sqrt(d), of norm at most sqrt(2), and applies each A_j
followed by phi_N(s)=tanh(sqrt(N)s)/sqrt(N). This activation fixes zero
and is 1-Lipschitz. The last layer is linear.

Pad the teacher to width C, then clone each hidden neuron into either
floor(N/C) or ceil(N/C) copies. Incoming weights to copies are retained;
weights from a copied source neuron are divided by its number of copies.
This preserves every output exactly. The weighted first-layer energy,
internal Frobenius energies, and weighted readout energy each increase
by at most a factor two, since ratios of the replication counts are at
most two. Thus the cloned teacher A_* has energy at most

    K0 = 2 B^2 [d(d+1)+(L-1) C^2].                              (3)

In particular K0 has no dependence on learner width N.

## 3. A uniform parameter Lipschitz bound

On the energy ball kappa(A)<=R, the output at every Boolean input is
Lipschitz as a function of A, with constant

    Lambda_R = sqrt(2L) max(1,R/(L-1))^((L-1)/2).                (4)

Indeed the Frobenius norm of the derivative with respect to block j
is at most sqrt(2) times the product of the other L-1 block norms.
The arithmetic-geometric mean inequality bounds each such product by
(R/(L-1))^((L-1)/2). Sum the squared block derivative bounds and
integrate on the line segment between two parameters. Energy balls
are convex, so the same R applies throughout the segment. The max with
one only enlarges the bound and avoids irrelevant small-R cases.

Let

    K=2K0+2,   r=1/(4 Lambda_K).

Then r<=1. The Euclidean r-ball around A_* lies in the energy K-ball,
and every parameter in it has signed output at least 3/4 everywhere.
It therefore belongs to the global clean-margin event and fits every
possible sample labeled by f.

## 4. A posterior energy bound without a width threshold

Let E_S be the intersection of the global clean-margin event with the
training-sign constraints. Conditioning first on global margin and then
on the labels is exactly conditioning the raw Gaussian on E_S.

Inside the r-ball around A_*, take the coordinate cube of half-side

    h=min(r/sqrt(p),sigma).

The Gaussian density on this cube is at least
(2 pi sigma^2)^(-p/2) exp(-K/(2 sigma^2)). Hence, uniformly over all
samples labeled by f,

    P(E_S) >= exp[-K/(2 sigma^2)-pT],                            (5)

where the scale-independent quantity

    T = log[sqrt(pi/2) max(1,sqrt(p/N)/r)]                       (6)

is sufficient, because sigma sqrt(p)<=sqrt(p/N). The clipping at sigma
is important: no extra log(1/t) loss enters the uniform bound.

For an unconditioned isotropic Gaussian, the elementary chi-square
Chernoff bound is

    P(kappa(A)>R) <= 2^(p/2) exp[-R/(4 sigma^2)].                 (7)

For 0<beta<1 define

    R_beta = 2K + (4/N)[p(T+(log 2)/2)+log(1/beta)].              (8)

Divide (7) by (5) and use sigma^2<=1/N. Since R_beta is at least
2K+4 sigma^2[p(T+(log 2)/2)+log(1/beta)], one gets

    P(kappa(A)>R_beta | E_S) <= beta                             (9)

for every sample S. This is a statement about the actual conditional
posterior, with both conditioning events retained.

The constants in (8) are deliberately conservative. In particular no
optimal-energy or exact zero-temperature concentration claim is needed.

From (3)--(6),

    T <= C [L log S+log(d+LN+2)],
    R_beta <= C [K+(d+LN)(L log S+log(d+LN+2))
                    +N^(-1)log(1/beta)].                        (10)

Consequently R_beta is polynomial in the ordinary resources and N,
with only a logarithmic dependence on beta^(-1), uniformly in t.

## 5. A finite class of margin-stable sign patterns

Cover the energy R_beta-ball by a Euclidean net of radius
rho=1/(8 Lambda_{R_beta}), with centers in the ball. It has at most

    M <= (1+16 sqrt(R_beta) Lambda_{R_beta})^p                   (11)

centers. Every globally clean-margin parameter in the ball has exactly
the same signs on the entire cube as its selected center: the uniform
output perturbation is at most 1/8, while its original absolute margin
exceeds 1/2. Thus the corresponding truth tables form a subclass of a
fixed class F_beta of size at most M. The net and this class are fixed
before the sample and the input distribution. Centers not corresponding
to a clean-margin parameter can be kept harmlessly, with any convention
for a zero output.

Equations (4), (10), and (11) imply

    log M <= C p L log(S+N+beta^(-1)).                           (12)

This counting bound uses bounded posterior energy and global margin,
not an assertion that all arbitrary-real networks have this many signs.
It also does not claim PNC1 evaluation of these possibly deep net centers.

## 6. From consistency to posterior confidence

For a fixed class of M classifiers, a union bound shows that after n iid
examples, with probability at least 1-delta, every member fitting the
sample has population error at most alpha whenever

    n >= [log M+log(1/delta)]/alpha.

Apply this to F_beta. On that sample event, every clean-margin posterior
parameter of energy at most R_beta has error at most alpha, since its
net-center signs agree everywhere and fit the same sample. Equation (9)
then bounds posterior Gibbs error by alpha+beta. A point with correct
posterior probability at most 2/3 contributes at least 1/3 to Gibbs error,
so its total probability mass is at most 3(alpha+beta).

Set alpha=beta=epsilon/6 and use (12). This proves (1).

## 7. Consequence for an exponential-depth lower bound

Suppose d,C,B are polynomially bounded in L and fixed positive accuracy
and confidence require at least exp(cL) examples along some canonical
finite-width sequence. Then (2) forces

    log N >= cL/2-O(log L).                                    (13)

To see the displayed form, if log N already exceeds cL there is nothing
to prove; otherwise log(S+N)=O(L), and (2) is at most N^2 times a fixed
polynomial in L. This improves the earlier N^8 finite-architecture
obstruction to a quadratic-in-width obstruction for the actual Gaussian
posterior and the bounded-weight teacher class.

It still leaves an exponential-width regime. The known all-width
quasipolynomial sample upper bounds for NC targets also continue to
apply there. Thus this lemma does not evade the existing implication
that an exponential-depth counterexample would separate P/poly from NC.
It gives no width-independent upper bound and no unconditional lower
bound for a bounded-weight deep teacher.
