# Canonical logistic and softplus priors order before label conditioning

25 October 2026. Scratch proof. This concerns the standard uncentered
logistic and softplus activations, not a centered or rescaled tanh.
It gives an actual-posterior constant-target result. It does not address
the posterior after the sample contains both labels.

## 1. Statement

Use augmented Boolean inputs, H>=1 hidden layers of width N>=1, no
internal biases, a linear readout, and Gaussian variances t^2/d,
t^2/N, t^2/N^2, with 0<t<=1. Let the hidden activation be either

    logistic(s)=1/(1+exp(-s)),
    softplus(s)=log(1+exp(s)).

Condition the prior on |z(x)|>1/2 for every cube input, then on one
correctly labeled example of a constant target. There is a universal
C (different for the two activations) such that, whenever

    H >= C [1+d t^2/N],                                      (1)

the posterior probability of the correct constant label exceeds 2/3
at EVERY cube input. The input distribution and the observed point are
arbitrary. Any further correctly labeled constant-target examples preserve
the same conclusion, because the denominator bound below still applies.

The proof actually makes posterior mass on the correct constant truth
table tend to one exponentially in NH/t^2, after paying the cube-size
factor and a constant multiple of N/t^2. This is the opposite direction
from the supercritical tanh white-sign-prior construction.

## 2. Logistic pair moments at finite width

For a pair of inputs let D_j=||h_j(x)-h_j(y)||^2/N, with
D_0=||x-y||^2/d<=4. The derivative of logistic is at most 1/4.
Conditionally on the preceding layer, its Gaussian preactivation
differences have independent coordinates of variance t^2 D_(j-1).
Therefore, for every integer p>=1,

    E[D_j^p | preceding layer]
      <= [(t^2/16)^p E(chi_N^2/N)^p] D_(j-1)^p.

The elementary moment product gives

    E(chi_N^2/N)^p = product_(r=0)^(p-1)(1+2r/N)
                   <= (1+2p/N)^p.

The final readout difference has conditional variance t^2 D_H/N.
Using E|Z|^(2p)<=(2p)^p yields

    E|z(x)-z(y)|^(2p)
      <= [8p t^2/N ((t^2+2p t^2/N)/16)^H]^p.                (2)

Choose p=ceil(N/t^2). Then 1<=p t^2/N<=2, and

    E|z(x)-z(y)|^(2p) <= [16 (5/16)^H]^p.                 (3)

This uses exact conditional Gaussian rows, not a mean-field limit.

## 3. Softplus has a stricter averaged contraction than its Lipschitz bound

Write

    softplus(s)=s/2+psi(s),    psi(s)=log(2 cosh(s/2)).

The function psi is even and 1/2-Lipschitz. For any jointly centered
Gaussian pair (G_1,G_2), the cross term between G_1-G_2 and
psi(G_1)-psi(G_2) vanishes by simultaneous sign reversal. Thus

    E[softplus(G_1)-softplus(G_2)]^2
       <= (1/2) E(G_1-G_2)^2.                              (4)

Let v=E(G_1-G_2)^2>0 and
Y=[softplus(G_1)-softplus(G_2)]^2/v. Under the same coupling,

    0<=Y<=(G_1-G_2)^2/v=Z^2,   EY<=1/2.

In particular E exp(Y/4)<=sqrt(2), so Y-EY has a uniform centered
subexponential moment bound. For iid rows Y_1,...,Y_N, Bernstein's
inequality and tail integration give, for every p>=1,

    ||N^(-1) sum_i Y_i||_p
      <= 1/2+C sqrt(p/N)+Cp/N.                              (5)

One direct derivation starts from
E exp[lambda(Y-EY)]<=exp(C lambda^2) for 0<=lambda<=c,
obtains P(N^(-1)sum_i Y_i-1/2>u)
<=exp[-cN min(u^2,u)], then integrates p u^(p-1) times this
tail and uses Minkowski. All constants are universal. The case v=0
has identically zero difference and needs no normalization.

Choose a sufficiently small universal a>0 and put

    p=max(1,floor(aN/t^2)).

When p>=2, multiplying (5) by t^2 bounds the p-moment contraction
factor by 1/2+C sqrt(a)+Ca<=3/4. When p=1, use the exact mean bound
(4), giving factor at most 1/2. In all cases

    p >= (a/2)N/t^2,  p t^2/N<=1,
    E[D_H^p] <= 4^p (3/4)^(Hp).

The same Gaussian readout calculation therefore gives

    E|z(x)-z(y)|^(2p) <= [8 (3/4)^H]^p.                    (6)

The softplus moment step was independently checked by the occupation
audit agent. Only centered conditional Gaussian rows are used; the
hidden feature vectors themselves need not be centered.

## 4. A depth-independent lower bound for one positive output

Fix an input x_0. Conditionally on all preceding layers, the last hidden
preactivations are independent centered Gaussians. Every logistic
coordinate is at least 1/2 with probability 1/2; every softplus coordinate
is at least log 2>1/2 with probability 1/2. If the variance vanishes,
all coordinates are at their positive activation-at-zero value and the
following bound is only easier.

A binomial Paley--Zygmund bound gives probability at least 1/8 that
at least N/4 coordinates exceed 1/2. On that event,

    ||h_H(x_0)||^2 >= N/16.

The independent linear readout then has variance at least t^2/(16N).
For u>=4, the elementary Gaussian-tail estimate P(Z>u)>=exp(-u^2)
gives

    P(z(x_0)>1) >= (1/8) exp(-16N/t^2)
                 >= exp(-20N/t^2).                         (7)

This lower bound holds at every depth. It pays for one output exceeding
one; it has not yet imposed all-cube margin.

## 5. The actual constant-target posterior

Equations (3) and (6) have a common form

    E|z(x)-z(y)|^(2p) <= [A rho^H]^p,
    p>=a_0 N/t^2,   rho<1,                                (8)

with universal constants (activation-dependent). Markov and a union
bound over x give

    P(max_x |z(x)-z(x_0)|>1/2)
       <= 2^d [4A rho^H]^p.                               (9)

For H>=C[1+d t^2/N], with C sufficiently large, this is at most
one half the right side of (7). Hence the event

    E_+ = { z(x)>1/2 for every cube input }

has probability at least (1/2)exp(-20N/t^2).

Let E_mix be the globally absolute-margined event with both output signs.
On E_mix some input has output differing from z(x_0) by more than one.
Thus

    P(E_mix) <= 2^d [A rho^H]^p.                            (10)

After any nonempty sample labeled constantly +1, the conditioning event
contains E_+, excludes the all-negative event, and otherwise is a subset
of E_mix. Consequently

    posterior(nonconstant truth table)
       <= P(E_mix)/P(E_+)
       <= 2 exp(20N/t^2) 2^d [A rho^H]^p.                  (11)

Increasing C in (1) makes (11) strictly less than 1/3. Posterior mass on
the constant-positive function is then greater than 2/3, simultaneously
at every input. Readout sign symmetry handles the constant-negative target.

This proof retains the actual global-margin normalization. Unlike a raw
output-collapse observation, (7)--(11) compare its numerator and denominator.

## 6. Why this does not settle the nonconstant case

After a sample contains both labels, E_+ and E_- are both excluded.
The denominator can then be as small as the mixed-sign numerator in
(10); dividing by (7) is no longer legitimate. Raw ordering alone gives
no confidence lower or upper bound in that posterior.

For logistic there is an exact complementary-rail identity

    logistic(2s)-logistic(-2s)=tanh(s),
    logistic(2s)+logistic(-2s)=1.

Thus a Boolean feature computed early can in principle be transported
through paired positive hidden coordinates using signed weights. Such
a construction has some per-layer Gaussian cost. A useful comparison
must determine whether that cost matches the OPTIMAL nonconstant depth
baseline, up to a controlled excess, uniformly over label partitions.
Merely exhibiting a Theta(H)-cost path does not prove that its posterior
mass is competitive with other Theta(H)-cost paths.

No exponential-depth lower bound for a nonconstant logistic or softplus
teacher is established here. That conditional comparison remains open.
