# A scalar profile factory for square-integrable Gaussian tilts

26 October 2026. Exact scalar integration interface, not a positive
feature factorization or posterior theorem.

Let G be the isonormal Gaussian over a separable real Hilbert space H.
Use the normalized Wiener-chaos isometry: each h in L²(gamma) has
symmetric tensors R_k in H^(tensor k) with

    h(G)=sum_(k>=0) I_k(R_k),
    sum_k ||R_k||HS²=||h||L²(gamma)²,
    I_k(u^(tensor k))=H_k(G·u) for ||u||=1.

Suppose u(x) has norm one and coordinate oracles of pointwise trace
second moment at most V<=2 and common expected formula size at most
T>=2. Let a scalar profile psi(z)=sum a_k H_k(z) satisfy

    sum_(k>=1) k² a_k²<infinity.

Then the scalar function

    f(x)=E_gamma[h(G) psi(G·u(x))]
        =a_0 R_0+sum_(k>=1) <a_k R_k,u(x)^(tensor k)>    (1)

has an exact unbiased real arithmetic-formula oracle. Apart from its
constant term, its expected size is at most T after choosing a universal
thinning constant, and its second moment is at most

    C [sum_(k>=1) k ||a_k R_k||HS]²
       <=C ||h||2² sum_(k>=1) k² a_k².                 (2)

A constant term adds only constant size and its squared magnitude.
Countable coordinates and unbounded chaos degree are allowed. No
algorithmic access to the real tensors R_k is asserted.

## Factory and proof

Put B_k=a_k R_k and A=sum_(k>=1) k||B_k||HS. Cauchy--Schwarz makes
A finite. If A=0, return zero for the nonconstant part. Otherwise choose
a positive integer k with probability

    p_k=||B_k||HS/(C_* k A),                            (3)

and return zero with the remaining probability. Since k>=1,
sum p_k<=1/C_*. Conditional on k with B_k nonzero, choose an ordered
coordinate word I=(i_1,...,i_k) with probability

    p_(I|k)=B_(k,I)²/||B_k||HS².

Average m_k=ceil(kV) independent copies of every coordinate child;
different tensor legs are independent even when their indices coincide.
Return

    B_(k,I)/(p_k p_(I|k)) * product_(a=1)^k Xbar_(i_a).  (4)

The mean is (1)'s nonconstant part. The averaged trace obeys
sum_i E Xbar_i²<=1+(V-1)/m_k, so its kth power is at most e.
Summing second moments over I therefore bounds the conditional readout
variance before division by p_k by e||B_k||HS². Hence the total second
moment is at most

    e sum_k ||B_k||HS²/p_k=e C_* A².

All variance sums are nonnegative, and the mean identity follows from
absolute Cauchy--Schwarz convergence of the chaos pairing. The nonzero
branch costs at most C0 k m_k T<=C1 k² V T. Thus total expected size is
at most

    1+sum_k p_k C1 k² V T
       =1+(C1 V/C_*)T<=T

for a sufficiently large universal C_* and T>=2. Every selected degree
and averaging count is finite almost surely. This proves the claim.

## Two consequences

First, let r=d rho/d gamma be a density in L²(gamma), and take h=r-1.
For the normalized variance profile

    psi_q(z)=tanh²(sqrt(q)z)/q,       0<q<=Q,

fixed Gaussian Sobolev estimates give sum k²a_k(q)²<=C_Q.
Consequently E_rho psi_q(G·u)-E_gamma psi_q(G·u) has an exact scalar
oracle of second moment at most C_Q||r-1||2² and constant expected work
relative to the input coordinate bound. No dimension factor occurs.
If the density has the same uncentered second moment as the reference
Gaussian, its degree-two tensor vanishes;
the higher-degree profile has weighted Sobolev norm O(q), because
psi_q(z)=z²+O(q) in every fixed Gaussian Sobolev norm. The variance
correction then has second moment O(q²||r-1||2²). For a density ratio bounded above by a fixed M,
||r-1||2²<=C_M KL(r gamma||gamma); no positive lower bound is needed.
Indeed (r-1)²/[r log r-r+1] is bounded on [0,M], with its removable
value at r=1 and finite value at r=0.

Second, for any scalar readout lambda in L²(rho), if r<=M, the function
h=lambda r lies in L²(gamma) with ||h||2²<=M||lambda||L²(rho)².
Taking psi_q(z)=tanh(sqrt(q)z)/sqrt(F(q)) gives
sum_(k>=1)k²a_k(q)²<=1+6q². Therefore one bounded-density Gaussian
feature layer followed by a fixed scalar readout can be integrated with
second moment O(M(1+q²)||lambda||²) and constant expected coordinate work.
This is a scalar last-layer statement, not a coordinate-trace statement.

## The remaining feature-factorization gap

The factory supplies a chosen scalar functional. Applying it separately
to every output basis coordinate does not preserve a finite trace budget:
the sum of the corresponding L²(gamma) readout norms can be infinite.
A full recursive feature compiler needs coordinate oracles whose SUM of
second moments stays bounded, not merely an operator-norm bound for each
chosen readout. That positive factorization/trace issue remains open.

This distinction explains why the scalar variance oracle is easier than
the two-input kernel factorization, and why the method does not contradict
the separate Wick-term obstruction. Here the density is paired directly
with ONE scalar Gaussian profile; no product of two separately expanded
Hermite features is decomposed into Wick terms. General finite entropy
does not imply r in L², so the stated density hypothesis is also genuine.
No original canonical learning or arbitrary-tilt formula theorem is
inferred from this partial interface.
