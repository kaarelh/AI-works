# Exact-stage formula compilation and the posterior depth boundary

26 October 2026. Supporting refinement of the structural Boolean-depth
paper. The paper itself retains the weaker condition `L>=C(r+1)`; this
separate note proves the exact boundary stated below. The unrestricted
Boolean-depth question remains open.

## Posterior statement

Let f be a Boolean function represented by a size-s unary/binary Boolean
formula of Horton--Strahler rank r. Set `R=d+s+L+3`. There are universal
constants A,c such that, for every

    L>=max{2,r+1},

it suffices to use

    n >= A/epsilon [R^{c(r+1)^2}(1+log(1/epsilon))^c
                    +log(1/delta)]

samples in the original Gaussian tanh posterior, at every actual
realizable width and every `0<t<=1`. Here the Gaussian variances are
`t^2/d`, `t^2/N`, and `t^2/N^2`, the input is `(1,x)`, and conditioning
uses only strict absolute output margin greater than 1/2 throughout the
Boolean cube together with exact noiseless training labels. The conclusion
bounds, with probability at least `1-delta`, the test mass on which the
correct-label posterior probability is at most 2/3 by epsilon. The input
law is arbitrary and common to training and test. Both statistical
parameters lie in `(0,1)`.

In particular every fixed-rank family has polynomial samples at every
learner depth at least its rank plus one; rank zero starts at depth two.
The rank uses arbitrary unary/binary Boolean gates. This remains a target
representation condition, not a restriction on the prior architecture.

## Deterministic statement

A Boolean formula with s nodes over arbitrary unary and binary Boolean
gates and Horton--Strahler rank r>=1 admits a network with exactly r hidden
layers of threshold features, a linear final readout, width polynomial in
d+s, and integer coefficients of magnitude polynomial in d+s, where the
polynomial degrees are universal. Its final readout is exactly a signed
Boolean output. Replacing each threshold by a sufficiently steep tanh gives
a globally unit-margined tanh realization with r hidden layers, polynomial
width, and Frobenius product (d+s+2)^{O(r+1)}. A rank-zero formula is a literal
or constant and needs at most one tanh hidden layer.

The threshold features themselves need not be designated intermediate
formula values. Each already evaluated formula component is represented
by an explicit small linear combination of stored threshold features.
This distinction removes the separate threshold stage that would normally
decode the path's final parity.

## 1. Flattening a chain of unary Boolean maps

Consider an m-step chain, indexed bottom to top by i=1,...,m. At each step
a fixed binary gate combines the incoming bit with one side bit z_i, or
a fixed unary gate acts on the incoming bit. For each side-bit value this
induces a unary Boolean map. Let

- R_i be its reset indicator: the map is constant iff R_i=1;
- A_i be the value of that map at zero;
- F_i be one iff the map is the negation map, and zero otherwise.

Each of R_i,A_i,F_i is a unary Boolean function of z_i, or a constant.
Consequently each is affine in z_i, with integer coefficients of magnitude
at most one (and an intercept in {0,1}). No threshold evaluation is needed
to obtain these quantities as affine expressions.

If a reset occurs, let j be its largest index. The final output bit is

    A_j XOR (XOR over i>j of F_i).

If there is no reset, it is the starting bit XOR all the F_i.

For any integer S<=m+1 define the threshold-feature expression

    G(S)=1[S>=0]+2 sum_{k=1}^{m+1} (-1)^k 1[S>=k].

It is zero when S<0 and equals (-1)^S when 0<=S<=m+1.
All thresholds are implemented at half-integers, so their affine
integer scores have a fixed gap of 1/2 from zero.

For each candidate last reset j=1,...,m put

    V_j=(1-R_j)+sum_{i>j} R_i,
    S_j=A_j+sum_{i>j} F_i-(m+2)V_j.

When j is the actual last reset, V_j=0 and G(S_j) is the final signed
output (-1)^{output}. For every other candidate V_j>=1, while
A_j+sum F_i<=m+1, so S_j<=-1 and G(S_j)=0.

At the bottom of a same-rank formula path the starting bit can be a
binary gate g(y_1,y_2) of lower-rank outputs. Avoid evaluating that gate
in a separate stage. For each b=(b_1,b_2) in {0,1}^2 put

    V_b=sum_i R_i + |y_1-b_1|+|y_2-b_2|,
    S_b=g(b)+sum_i F_i-(m+2)V_b.

Each absolute-value expression is an affine function of its Boolean bit.
Exactly one such term survives iff there is no reset, namely b=(y_1,y_2).
In that case it equals (-1)^{g(y_1,y_2)+sum F_i}. All others vanish.
Unary/constant bottoms require only two/one assignments, respectively.
Thus the exact output identity is

    (-1)^{output}=sum_{j=1}^m G(S_j)+sum_{b in {0,1}^2} G(S_b).

This is a linear combination of O((m+1)^2) threshold features of affine
forms in the side bits and bottom input bits. Each output coefficient is
in {1,-2,2}. Each affine score has polynomial coefficient l1 norm in m.
The identity remains valid for m=0, repeated variables, and dependent
side bits; it is pointwise and uses no independence.

## 2. Scheduling by Horton--Strahler rank

At most one child of a formula node can have the same rank as the node.
Every maximal component of equal positive rank is therefore a path. Its
side subtrees and the children of its bottom node have strictly smaller
rank. Rank-zero components compute literals or constants, available as
affine forms in the raw input bits.

At stage k, evaluate all components of rank k using the one-stage feature
construction above. The signed output of each completed component is
retained as a linear form in its newly created features, with coefficients
in {1,-2,2}; conversion to a 0/1 side bit adds a factor 1/2 and an intercept.
Substitute these stored linear forms into each new affine score. This
does not recurse through old coefficient expansions: the actual old
features, rather than their formulas in the original input, are available
as physical neuron outputs. Multiplying all scores by two clears the only
denominators arising from the signed-to-bit conversion.

Copy all previously required features and input bits through subsequent
stages. A copied Boolean feature is itself one threshold gate. An explicit
constant feature supplies every intercept after the first stage. The sum
of path lengths is at most s, so the sum of their squared lengths is at
most s^2. There are O(s^2) newly created features in total and at most
O(d+s^2) simultaneously retained features. Each substituted score has
coefficient l1 norm bounded by one fixed polynomial in d+s, independent
of r. No exponentially growing coefficient product is introduced.

The output component's signed linear form is the final readout. There
are exactly r feature stages; inserting copies keeps the architecture
layered. All threshold margins are bounded below by a universal positive
constant after clearing the bounded denominators.

## 3. Passing to tanh without accumulating numerical error

Use signed threshold outputs H=2*1[score>=0]-1. The preceding conversion
between signed and bit variables only changes universal polynomial
coefficient bounds. Let B be a universal polynomial bound on every row's
coefficient l1 norm and on the final readout's coefficient l1 norm.
Normalize scores so their exact signed values have absolute value at
least one. Set eta<=1/(4B) and choose a common gain

    a >= 2 log(4/eta).

If incoming features are eta-close to their intended signs, each new
score changes by at most B eta<=1/4. Its sign is preserved and its
absolute value is at least 3/4. The tanh output differs from the intended
sign by at most 2 exp(-3a/2)<=eta. This is an induction with a uniform
error bound at every depth, rather than an error multiplied across all
layers. First-layer raw inputs are exact, and constant/copy gates satisfy
the same estimate. The final signed linear readout is within B eta<=1/4
of its exact value, so multiplication by two yields global unit margin.

Since a=O(log(d+s+2)), every hidden matrix and the final row have
Frobenius norm polynomial in d+s. Their product is
(d+s+2)^{O(r+1)}. Hidden-layer biases are realized by the explicitly
counted constant feature; no hidden affine parameter is assumed for free.

## 4. Statistical transfer at the boundary depth

First take r>=1 and L=r+1. The deterministic construction supplies a
same-depth tanh teacher of width and coefficient bound polynomial in
`d+s+2`, with universal polynomial degrees, and signed margin at least
one. Pad its hidden layers by zero neurons to a common integer width C
that also bounds every coefficient. Thus `C<=(d+s+2)^c` for a universal
c.

We use the explicit proof of the fixed-depth uniform-prefactor lemma in
`boolean-depth-barriers/source/paper.tex`, labeled
`lem:fixed-depth-uniform`, together with Proposition 2.1 of
`boolean-depth-barriers/source/uniform-target-classes.tex`. The proof
actually yields a quantitative bound jointly in the depth. To make that
extraction checkable, its cloning cylinder gives, for every N>=C and
all canonical t, normalized target action

    t^2 a_(N,t)(f) <= Q_L(d,C),
    Q_L=B_0+M log(e sqrt(2pi)/(2rho))+log 2,
    B_0=d(d+1)C^2+2(L-2)C^4+36C^4,
    M=d+2+(L-2)C,
    rho=[2+9C^2(d+L+1)A_0^(L-2)]^(-1),
    A_0=2+3C^2+sqrt(16log9+8log(4L)).

In particular

    log(1/rho)=O(log(d+C+L)+L log(C+L)),

so Q_L is bounded by a polynomial in d,C,L with one universal degree.
There is no polynomial degree depending on L in this estimate. Let
`H=L-1`. The imported intrinsic theorem has universal polynomial degrees
in d,L, `1+t^2 a`, and

    P_t=max{1,t^H Rcal((a+t^(-2))/H)^(H/2)},

where `Rcal(D)-1-log Rcal(D)=2D` and `Rcal(D)<=4D+2`.
Consequently

    P_t <= [C_0(1+Q_L)]^(H/2),

with a universal C_0, and its sample upper is
`(d+C+L)^{O(L)}` apart from the displayed statistical factors. At
`L=r+1`, substitution of the constructed C yields `R^{O(r+1)}`.
This is stronger than the stated `R^{O((r+1)^2)}` at this boundary.

For realizable learner widths N<C, the VC dimension of the entire
fixed-architecture tanh class is bounded by a universal polynomial in
d,L,N (the same finite-width completion used in the imported theorem).
Since N<C is polynomial in d+s, realizable uniform convergence bounds
every training-consistent function's population error by epsilon/3 with
a polynomial number of samples. Averaging over the actual posterior
then bounds its confidence-failure mass by epsilon: each point in that
set contributes at least 1/3 to posterior-averaged classification error.
This handles all smaller actual realizable widths without requiring the
compiled teacher to fit them.

## 5. All remaining depths

For L>=r+2, append one threshold gate to the exact signed linear output
of the r-stage threshold-feature construction. The result is a threshold
circuit of hidden depth `h=r+1`, polynomial width and coefficients, and
unit threshold margins, computing f exactly. The uniform threshold-target
Theorem 1.1 in `boolean-depth-barriers/source/uniform-target-classes.tex`
applies whenever `L>=h+1`. Its short-padding bound is polynomial-resource
to exponent `O((h+1)^2)`, hence gives precisely
`R^{O((r+1)^2)}` with universal constants for every L>=r+2. Its statement
already includes every actual realizable width and every canonical scale.

Rank-zero formulas are literals or constants; their Fourier variation is
one. The uniform Fourier-target Theorem 1.2 in the same source applies
at every L>=2. This completes the posterior statement in all cases.

## Scope

This result removes the constant-factor hidden-depth overhead in the
fixed-rank positive theorem. It does not make the exponent independent
of r. Arbitrary balanced formulas can have r=Theta(log s), so the
polynomial-sample question for all polynomial-size Boolean formulas
remains open. The separate rank-two inner-product note shows that an
exact one-hidden-layer polynomial-product compiler cannot prove the
same result at depth L=2 for all rank-two formulas. That representation
obstruction is not a Bayesian sample lower bound.

The 10-page main structural paper has not been rebuilt to incorporate
this supporting refinement. Its weaker theorem remains correct. No
new Gaussian-prefix or final-linear-code extension is required here;
the boundary argument uses the published cloning cylinder and universal
intrinsic theorem directly.

## Finite algebra check

A direct exhaustive check tested every sequence of zero through five
unary Boolean maps, every two-input bottom truth table, and all bottom
input assignments: 87,360 cases. The gated-parity identity held in every
case. This checks a finite range only; Sections 1--3 supply the general
proof. No statistical experiment or posterior simulation was performed.
