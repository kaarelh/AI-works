# Linear-in-width sample bounds from a Gaussian mean-shift circuit witness

26 October 2026. An actual finite-width posterior bound for the original
canonical tanh prior. No robustness restriction is imposed on the prior.
The target hypothesis is a bounded-fan-in layered Boolean circuit; it is
not an arbitrary soft-intermediate-value tanh teacher.

## 1. Model and statement

Inputs are x in {-1,1}^d, augmented by a constant input coordinate. There
are H hidden tanh layers, each of width N, followed by a linear readout.
All weights are independent, with variances

    first layer: t²/d,
    later hidden layers: t²/N,
    readout: t²/N²,                   0<t<=1.

Let P be this prior. The learner first conditions on

    A={|z_w(x)|>1/2 for every cube input x},

then on the exact training signs, as in the original convention.
Let f have a layered Boolean circuit of hidden depth at most H and
width at most C. Count a constant +1 wire in C. Allowed gates are
AND, OR, NOT and COPY; constant gates are supplied by the constant wire.
Padding shorter circuits uses COPY gates and introduces no new width.

There is a universal constant K0 such that if

    N >= 1600 C [d log 2+log(8CH)],                       (1)

then the raw prior probability of the globally correct margin event is

    P{ f(x)z_w(x)>1/2 for all x }
      >= exp[-K0 N(d+CH)/t²].                           (2)

One can take K0=2002 with the deliberately loose estimates below.
Consequently, for iid data from any distribution on the cube, with
probability at least 1-delta over the training sample, the exact posterior
has correct-label probability greater than 2/3 except on input mass
at most epsilon whenever

    n >= (6/epsilon) [
            K0 N(d+CH)/t² + log(6/(epsilon delta)) ].     (3)

The dependence on learner depth H is polynomial and that on width N is
linear. The bound is not width independent, and does not settle the
unrestricted depth question. It improves the generic quadratic-in-N
finite-architecture bound in the indicated width range.

## 2. A comparison law with unchanged variances

Partition the N neurons at every hidden layer into C groups, with sizes
n_g equal to floor(N/C) or ceil(N/C). Thus

    n_min >= N/(2C).

Pad the Boolean circuit to C wires at each level. A signal group will
represent one Boolean wire by its average activation. Reserve one group
for the constant +1 wire at each layer.

Use gain a=10. The Boolean formulas

    AND(u,v): u+v-1,      OR(u,v): u+v+1,
    NOT(u): -u,           COPY(u): u

have the intended signs. For internal layers the constant term is an
ordinary connection to the previous constant group, not an uncharged
bias. At the first layer use the prescribed constant input coordinate.
Repeated inputs or coincidences with the constant wire may be combined;
the sum of absolute coefficients is always at most three.

Define a product Gaussian comparison law Q with exactly the same
coordinate variances as P. For a row in signal group g:

* at the first layer, set its mean weights to a times the coefficients
  of the corresponding Boolean formula on the augmented input;
* at later layers, give every coordinate in predecessor group j the
  mean weight a c_j/n_j, where c_j is the formula coefficient.

The constant group uses the mean formula +a on the constant input or
+a times the previous constant-group average. Zero-mean weights remain
present on every other connection. Thus the original fully connected
network architecture and all of its random weights are retained.

At the readout, put mean 1/n_out on the target output group and zero on
all other coordinates. Its variances are still t²/N².

Every comparison mean is deterministic. In particular Q is a genuine
Gaussian mean shift, not a law adapted to realized preceding layers.

## 3. Noise-tolerant Boolean propagation

Put alpha=9/10. Suppose every predecessor group average has the correct
sign and signed magnitude at least alpha. Since every tanh value lies
in [-1,1], the signed Boolean preactivation before gain a is at least
2alpha-1=4/5 for AND and OR. For COPY and NOT it is at least alpha.
The constant wire obeys the same bound. At the first layer, the
unscaled signed margin is at least one.

For a fixed input, condition on all preceding layers. Each row in a
given group is independent under Q and has the indicated mean. Its
preactivation variance is at most t²<=1 internally, and at most
t²(d+1)/d<=2 initially. Its signed mean is at least eight.

If Z is centered Gaussian with variance at most two and mu>=8, then

    E tanh(mu+Z)
      >=1-2 exp(-4)-2 exp(-8)>0.95.                      (4)

Indeed on Z>=-4 the tanh value is at least 1-2exp(-8), and the
complement has probability at most exp(-4). Symmetry gives the same
signed expectation for a negative Boolean label.

Hoeffding's inequality for independent variables in [-1,1] therefore
gives, for each fixed group and input,

    Q{ signed group average<0.9 | preceding good event }
       <=exp(-n_g/800).

A union bound over the C groups, H layers and 2^d inputs, performed
successively through the layers, gives hidden propagation failure
probability at most

    CH 2^d exp[-N/(1600C)] <=1/8                         (5)

under (1). No independence between distinct inputs is used.

Conditional on all hidden layers, the centered readout noise at each
input is Gaussian with variance at most t²/N. The probability that its
absolute value exceeds 1/4 at any cube input is at most

    2^(d+1) exp[-N/(32t²)] <=1/8.                       (6)

The last inequality follows from (1), d,C,H>=1 and t<=1.
On the intersection of the good events, every signed output is at
least 0.9-0.25=0.65>1/2. Consequently

    Q(E_f)>=3/4,
    E_f={ f(x) z_w(x)>1/2 for all x }.                   (7)

The estimates are uniform in the full depth. They use constant-margin
digital propagation, not a product of layer Lipschitz constants.

## 4. Relative entropy and target mass

The sum of absolute coefficients of each gate formula is at most
three, so its squared coefficient norm is at most nine.
The first-layer KL contribution is therefore at most

    (9a²/2) dN/t².

For an internal row the squared mean norm is at most

    a² sum_j c_j²/n_j <=18 a² C/N.

Its KL contribution is at most 9a² C/t². There are N(H-1) such rows.
The readout squared mean norm is 1/n_out<=2C/N, so its KL contribution
is at most NC/t². Thus

    K:=KL(Q||P)
       <= N/t² [450d+900C(H-1)+C]
       <=1000 N(d+CH)/t².                              (8)

For any event E, binary relative entropy yields

    KL(Q||P) >= Q(E) log(1/P(E))-log2.

With (7), it is enough to use Q(E_f)>=1/2, obtaining

    P(E_f)>=exp[-2(K+log2)]
           >=exp[-2002 N(d+CH)/t²].

This proves (2). In particular the all-margin conditioning event has
positive probability. Since E_f is contained in A, conditioning on A
can only improve this lower bound on the target truth table's mass.

## 5. From target mass to the actual posterior confidence error

Let pi=P(.|A), and let p_*=exp[-K0N(d+CH)/t²].
The prior pi gives f mass at least p_*. For every sample from f, its
version-space normalizer is therefore at least p_*.

For a classifier h, let err(h) be its population sign error. The
expected prior mass of consistent classifiers with err(h)>epsilon/6
is at most exp(-n epsilon/6). Markov's inequality consequently gives

    P_S{ posterior mass(err>epsilon/6)>epsilon/6 }
       <=6 exp(-n epsilon/6)/(epsilon p_*).

Under (3), this is at most delta. On the complementary sample event
the posterior Gibbs sign error is at most epsilon/3. Every input at
which the correct sign has posterior probability at most 2/3 contributes
at least 1/3 to that Gibbs error. Its total mass is therefore at most
epsilon, proving (3) for the exact posterior mixture.

There is no choice of a preferred minimizer and no width-first limiting
argument in this proof.

## 6. Scope and relation to the open problem

The result applies to the original finite-width Gaussian learner at
the canonical prefactor t=1, and uniformly to every 0<t<=1 with the
explicit 1/t² factor. It requires the width threshold (1); ordinary
finite-architecture bounds cover smaller eligible widths, but that
combination is not needed for the displayed theorem.

It gives polynomial dependence on Boolean circuit depth without any
restriction on the learner prior's support. It does not give the desired
width-independent polynomial bound. In particular widths exponential
in depth still allow an exponential sample bound in (3).

The target hypothesis matters: a bounded-fan-in Boolean circuit has
constant-margin digital gates. An arbitrary bounded-weight tanh teacher
with soft intermediate values need not have this representation at
comparable width and depth. No claim about such a teacher is inferred
from the construction.

## 7. Layerwise widths and comparison with the generic finite-width bound

If the circuit has widths C_1,...,C_H, including one constant wire at
each level, put C_max=max C_j and G=sum C_j. Use separate balanced
partitions at each layer. The hidden contribution at layer j>=2 is
bounded by 900 N C_(j-1)/t², and the readout contributes N C_H/t².
Thus every occurrence of CH in the KL/sample bound can be replaced by
G, while the width threshold becomes

    N >=1600 C_max [d log2+log(8G)].

This counts all padding COPY/constant wires in G.

For unit prior scaling with exponent gamma>=1, the original variances
have t=N^((1-gamma)/2). Hence the width factor N/t² is exactly N^gamma.
At widths above the displayed threshold, take the smaller of this
bound and the existing uniform-scale finite-width bound from
canonical-finite-width-posterior-cover.md. Up to the displayed
confidence factors and logarithms, the two complexity terms are

    N^gamma (d+G)

and

    [Nd+H N²] H log(d+C_max+H+N+epsilon^(-1)+2).

In particular the new width exponent is one at gamma=1 and improves
the generic exponent two whenever 1<=gamma<2. Below the threshold,
the generic finite-width bound applies directly for N>=C_max, where
the displayed Boolean circuit supplies a same-width tanh teacher.
Here and in the next sentence, eligible widths mean N>=C_max.
Since that threshold
is polynomial in the circuit resources, combining the two gives an
all-eligible-width bound linear in N times a (larger) polynomial in
those resources at gamma=1. This last coarse formulation does not
assert the sharper coefficient d+G below the threshold.
