# A matched positive-channel wire for standard softplus

25 October 2026. Scratch proof for F(z)=log(1+exp(z)), augmented Boolean
inputs, no internal biases, linear readout, and the original Gaussian
width powers. This gives a quasipolynomial, hence subexponential-in-depth,
upper for shallow softplus targets in strong-prior limits and at each
fixed exponent gamma>1. The exact critical prefactor remains open for
samples containing both labels.

## 1. Setup and the energy baseline

Use the isotropic coordinates A1=sqrt(d/N)W1, Aj=Wj internally,
AL=sqrt(N)v, with kappa=sum||Aj||_F^2. Since F is 1-Lipschitz, any
globally absolute-margined nonconstant classifier has, on an opposite-label
cube edge,

    product||Aj||_F > sqrt(d)/2,
    kappa >= L exp[(log d-log4)/L] >= L-log4.                    (1)

This is a deterministic energy statement. At finite variance it is not
by itself a posterior rate formula.

Let g=u·h1 be a one-hidden-layer softplus teacher with global signed margin
at least one. Its first-layer energy can be made <=2 at a learner width
above a polynomial threshold in its width/weight/input resources, while
its weighted readout D=N||u||^2 stays polynomial. We also reserve at least
N/4 first-layer coordinates with zero incoming weights, hence exact value
q0=log2, on which u is zero. This allocation costs no first-layer energy.

For precision: take M0>=max(C,2,d C(d+1)B^2), N>=4M0, allocate about
N/(2M0) copies to each of the C teacher rows, divide their outgoing
weights by the replication counts, and use the remaining coordinates
as constants. The first energy is <=2, D<=4M0 C B^2, and at least N/4
constant coordinates remain. All outputs of g are unchanged.

## 2. Explicit near-identity transmission above a positive anchor

Let m=L-1>=2, D'=max(D,4), T=D'/4>=1, and set

    q=T^(1/(2m)),   k_j=min(j,m-j),
    r_j=q^j/(sqrt(D') k_j),        1<=j<=m-1.

Then q^m=sqrt(T), r_j<=1/(2q k_j)<=1/2, and
r_(m-1)=1/(2q). Put

    A=4+3log(m+2)+log(T+2),
    a_j=r_j/r_(j-1)=q k_(j-1)/k_j     (2<=j<=m-1).

The first new hidden signal is

    h_1^new=F(A+r_1 g).

Every subsequent hidden signal is

    h_j^new=F(A+a_j(h_(j-1)^new-A)).                            (2)

Alongside it carry an exact constant coordinate q0 by giving that neuron
zero incoming weights. Thus each affine expression in (2) is implemented
without an internal bias: its incoming coefficients are a_j on the signal
average and A(1-a_j)/q0 on the constant average. Use two equal groups of
M/2 neurons, where M=2floor(N/2), and ignore any surplus neuron.

At either endpoint g=+1 or g=-1, compare (2) with the ideal linear value
A+r_j g. The errors e_j are nonnegative, because F(z)>=z. All corresponding
preactivations are at least A-1/2, so the additive softplus error per stage
is at most exp(-A+1/2). Consecutive ideal gains telescope:

    product_(l=i+1)^j a_l=q^(j-i) k_i/k_j <= m sqrt(T).

It follows that

    0<=e_(m-1)<=m^2 sqrt(T) exp(-A+1/2)<=1/(8q)=r_(m-1)/4.

Take final readout

    z=4q(h_(m-1)^new-A).

At g=1 this is at least two; at g=-1 it is at most -3/2. Every hidden
map and the final readout are increasing functions of g. Thus the full
network has global signed margin at least one for EVERY input with
|g(x)|>=1, even if g is large in magnitude. Positivity of all intermediate
preactivations is needed only for the two endpoint calculations, not for
every input.

## 3. Energy of the wire

First-layer teacher energy remains <=2. At the first new signal layer,
orthogonality between u and the reserved constant coordinates gives energy
at most

    (D/2)r_1^2+2A^2/q0^2 <= q^2/2+2A^2/q0^2.

Each subsequent signal/constant layer has Frobenius energy exactly

    a_j^2+(A^2/q0^2)(1-a_j)^2.

The final weighted readout energy is at most

    64 q^2(1+A^2/q0^2).

The elementary reciprocal-pair estimates for k_j give

    sum_j a_j^2 <= (m+5)q^2,
    sum_j(1-a_j)^2 <= C[m(q-1)^2+q^2].

Consequently the whole network has

    kappa <= m q^2+Cq^2+C A^2[1+q^2+m(q-1)^2].                 (3)

If m>=C log^2(T+2), then q is bounded, m(q-1)^2<=C, and
m q^2<=m+C log(T+2). Therefore

    kappa <= L+C log^2(LT+2).                                (4)

The coefficient of L matches (1). The excess includes the cost of
subtracting the positive anchor in the final readout; it is not an
uncharged internal bias. This construction is better asymptotically
than the exact complementary identity F(s)-F(-s)=s, whose direct
paired wire has internal Frobenius energy four per stage.

## 4. A polynomial operator-stability bound for the planted wire

The wire also has polynomial robustness, despite the A-dependent bias
weights. In each new hidden layer its witness matrix has identical
signal rows and zero constant rows. Let s,c denote the two group
indicator vectors, each of squared norm n=M/2. The matrix is

    W_j=s w_j^T,    w_j=(a_j/n)s+[A(1-a_j)/(q0 n)]c.

For arbitrary diagonal contractions D_j (entries in [0,1]),

    w_(j+1)^T D_j s = (a_(j+1)/n) sum_(i in signal) (D_j)_(ii)
                      in [0,a_(j+1)].

Thus every consecutive product of matrices D_j W_j has operator norm
at most

    sqrt(a_i^2+[A(1-a_i)/q0]^2) product_(l=i+1)^j a_l,

which is polynomial in L,T,A by telescoping. The first injection and
readout add only polynomial factors. This argument holds for arbitrary
diagonal contractions, not only derivatives at the unperturbed state.

The witness's normalized hidden norms are polynomially bounded on the
whole cube. The shallow g has polynomial range in d,C,B, and

    |F(A+y)-A| <= |y|+log2       (A>=0)

propagates such a bound through the telescoping gains. Denote a uniform
bound by Q and the preceding propagator bound by P0; both are polynomial
in the shallow resources, L and T.

Now perturb all energy-coordinate matrices by operator norm at most eta.
The mean-value formula gives

    e_j=D_j A_j^* e_(j-1)+D_j B_j(u_(j-1)^*+e_(j-1)),

with diagonal contractions D_j, because F' is in (0,1). Variation of
constants therefore bounds the maximum hidden-state error E by

    E <= eta P0 L(Q+E).

For eta<=1/(2P0L), E<=2eta P0LQ. The last linear readout also has
polynomial norm. Hence a polynomially small operator perturbation
preserves the witness's global signed margin. No product bound for
arbitrary energy-bounded networks is inferred from this special wire.

## 5. Centering and the actual posterior

Center an arbitrary realized softplus network at one fixed cube input x0.
Its centered scalar activations are

    a_(b,N)(s)=[F(sqrt(N)(b+s))-F(sqrt(N)b)]/sqrt(N),

which fix zero and are 1-Lipschitz. The centered linear matrices remain
Aj, so their product is at most (kappa/L)^(L/2). A nonconstant globally
margined output has anchor offset at most twice that product, by using
an opposite-sign point. Constants are included separately.

The zero-preserving Lipschitz product-cover theorem, or its elementary
all-layer compression version, gives a finite Boolean class with
log-cardinality polynomial in d,L,P for product P. At the energy in (4),

    P <= exp[C log^2(LT+2)],                                  (5)

so this class has quasipolynomial log-cardinality in the ordinary resources.
For every fixed architecture, a strict-margin witness gives the usual
cold posterior energy ceiling at kappa<=K+1 by the Gaussian small-ball
and tail ratio. Equations (4)--(5), consistency, and the Gibbs-to-confidence
inequality therefore give quasipolynomial strong-prior sample bounds.

For each fixed gamma=1+zeta>1 the actual finite-scale extension is the
same frozen-anchor construction as for logistic. A typical symmetric
Gaussian convex set has block operator norms <=t b. The planted wire's
stability proves that its shift lies in the conditioning event, giving
mass >=(1/2)exp[-K/(2sigma^2)]. Gaussian isoperimetry puts posterior mass
1-2exp[-1/(2sigma^2)] at Euclidean distance squared <=K+1 from this set.
Subtract that Gaussian part only from the centered linear matrices,
while freezing the realized zero-preserving scalar maps and anchor offset.
The resulting surrogate need not be a native softplus network.

The zero-preserving perturbation estimate requires only

    t b <= exp[-C log^2(LT+d+2)].                              (6)

Indeed the energy is L+O(log^2(LT)), so the other-block product entering
that estimate is exp[O(log^2(LT))]. Since t<=N^(-zeta/2), (6) holds
above a quasipolynomial width threshold in the shallow resources and L.
The posterior surrogate then lies in the common class from (5), with
the same signs and a fixed positive margin.

Below this width threshold, the ordinary Gaussian energy/neighborhood
net yields a quasipolynomial sample bound because N is quasipolynomial.
For softplus this elementary proof uses |F(z)|<=log2+|z|: on an energy
ball the logarithm of all state norms and the parameter Lipschitz bound
is O(L log(2+K)). Clip the teacher-neighborhood cube half-side at sigma
to retain uniformity in 0<t<=1. A bounded-weight same-width deep witness
always exists at N>=max(C,2) using the EXACT complementary identity
F(g)-F(-g)=g, whose energy is only polynomial in L and the shallow
resources: balance-clone the initial teacher rows to width N, divide
their outgoing weights by the replication counts, and split each relay
into two groups of size floor(N/2), ignoring an odd surplus neuron.
Each internal paired relay then has Frobenius energy four, and the first
and last relay energies stay polynomial in the shallow resources,
independently of N. If N=1 every represented truth table is constant and one
label determines the readout sign. Thus no width gap is omitted.

## 6. Scope of the conclusion

For a one-hidden-layer softplus target with resources polynomial in L,
the condition L>=C log^2(T+2) eventually holds. At every eligible finite
learner width, both strong-prior limits and each fixed exponent gamma>1
then have sufficient samples exp[O(log^2(L+d+C+B+2))], with constants
depending on the fixed exponent and the usual statistical factors.
An explicit polynomial-size one-hidden-layer softplus parity witness
can be obtained from the integer-valued coordinate sum using softplus
approximations to piecewise-linear ramps, so parity is included.

This rules out an exponential-depth counterexample of this shallow form
in those regimes. It does not cover gamma=1, arbitrary fixed positive
prefactors, or unrestricted deep teachers. In particular the both-label
critical posterior cannot be analyzed by dividing by the constant-target
normalization from the separate raw-ordering result.
