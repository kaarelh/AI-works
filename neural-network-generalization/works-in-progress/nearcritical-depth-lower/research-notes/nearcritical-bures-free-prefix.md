# Nearcritical free-prefix whitening with width exp(O(D))

25 October 2026. New derivation for independent audit. Let t=1+epsilon with
0<epsilon<=epsilon0, m=2^d, D=d+1+log(1/epsilon). Constants below are absolute,
with epsilon0 a sufficiently small fixed number.

## Claim

For any h>=K epsilon^-2 D free hidden layers of the ordinary finite Gaussian
tanh network on the augmented Boolean cube, if

    N>=exp(A D) log(h+2),

then with probability at least15/16 its final empirical feature Gram satisfies

    ||Qhat_h-q_* I_m||F <=c epsilon^3.                (1)

Here q_*>0 is the free scalar fixed point and c can be any sufficiently small
fixed constant, at the expense of K,A. This improves the previous width
exp(O(epsilon^-2 D)). The result concerns an unchanged free prefix, not the
full posterior conditioned on a rare global-margin event.

## 1. Population diagonal and correlation estimates

Let G_t(Q) be the covariance after componentwise tanh of a Gaussian row with
covariance t^2 Q. Population Q_j=G_t(Q_(j-1)) has a common diagonal q_j,
starting at q_0=(d+1)/d in[1,2]. Thus q_j>=q_* and q_j decreases to q_*.
The usual uniform scalar expansion gives

    q_*=epsilon+O(epsilon^2),
    T'(q_*)=1-2epsilon+O(epsilon^2),
    chi(q_*):=t^2 E sech^4(t sqrt(q_*)Z)=1+O(epsilon^2),
    h(q_*):=t^2(E sech^2(t sqrt(q_*)Z))^2
                           <=1-c0 epsilon^2.        (2)

The functions chi and h have uniformly bounded derivatives for q in[0,3].

For completeness, population correlation contraction can be made uniform
without assuming stationarity. For phi_q(Z)=tanh(t sqrt(q)Z), use its normalized
Hermite-square coefficients b_l(q). Oddness gives b_l=0 for even l, b_l>=0,
and sum b_l=1. For 0<=rho<=1,

    rho-G_q(rho) >= b_3(q) rho(1-rho^2).              (3)

There is c>0 such that b_3(q)>=c q^2 for q in(0,2]. Indeed the cubic Hermite
coefficient is

    a_3(q)=(t sqrt(q)/sqrt6)
                  E[(Z^2-1) sech^2(t sqrt(q)Z)].

The expectation is strictly negative by negative covariance of Z^2 with a
strictly decreasing function of |Z|. The ratio a_3(q)/q^(3/2) has a nonzero
limit at zero and is continuous elsewhere on the compact interval. The
variance of phi_q is at most Cq. This proves the b_3 lower bound uniformly
for t in a fixed neighborhood of1.

Hence b_3(q_j)>=c epsilon^2. Every distinct cube pair starts with
|rho_0|<=1-2/(d+1), and the absolute correlation is nonincreasing. Applying
(3), first grow the gap to1 geometrically until |rho|<=1/2, and then shrink
|rho| geometrically. Together with scalar attraction after O(epsilon^-1)
burn-in, this proves that for

    h0=ceil(K epsilon^-2 D),

all population entries satisfy

    |(Q_h0)ij-q_* 1_(i=j)| <=r/4,
    r=c1 epsilon^3/m.                               (4)

The scalar estimate uses O(epsilon^-1 log(1/r)) steps after entering a fixed
relative neighborhood of q_*, which is absorbed in h0. The same population
bounds continue afterwards. Initial d=1 off-diagonal correlation is zero
and causes no endpoint issue.

## 2. A local Bures Lipschitz bound with gain 1+O(epsilon^2)

For positive semidefinite matrices define Bures distance by

    b(Q,R)=min ||A-B||F over AA^T=Q, BB^T=R,

with orthogonal alignment of square factors. It equals the least L2 distance
between centered jointly Gaussian vectors with those covariances.

Suppose R has every diagonal at least q_*, and e=b(Q,R)<=c2 epsilon^(3/2).
Choose optimally aligned Gaussian factors, and write row variables
U_i=A_i Z, V_i=B_i Z, Delta_i=U_i-V_i. For s in[0,1], W_s=V_i+s Delta_i has
variance at least

    (sqrt(R_ii)-e)^2 >=(sqrt(q_*)-e)^2
                         >=q_*-C epsilon^2.         (5)

The first inequality follows from the row norm triangle inequality. The
second uses e<sqrt(q_*), and the third uses the chosen e cutoff.

For any centered jointly Gaussian pair (Delta,W), and any nonnegative even
function psi decreasing in |W|, Gaussian conditional regression gives

    E[Delta^2 psi(W)] <= E Delta^2 E psi(W).          (6)

To verify (6), write E[Delta^2|W] as a constant plus a nonnegative multiple of
W^2. The covariance between W^2 and psi(W) is nonpositive, as follows by
comparing two independent copies. Degenerate W is handled by continuity.

The fundamental theorem of calculus and Cauchy--Schwarz in s give

    E|tanh(tU_i)-tanh(tV_i)|^2
       <=t^2 int_0^1 E[Delta_i^2 sech^4(tW_s)]ds
       <=(1+C epsilon^2) E Delta_i^2,                (7)

using (2), (5), (6), and monotonicity of E sech^4(t sqrt(q)Z) in q. Summing
rows and using this coupling as a candidate coupling of the transformed
feature covariances yields

    b(G_t(Q),G_t(R)) <=(1+C epsilon^2) b(Q,R).        (8)

The transformed random vectors need not be Gaussian; their cross-covariance
still supplies a valid factor/coupling upper bound for covariance Bures
distance. Equivalently, Bures distance between covariances is at most the L2
cost of every coupling with those covariances. This step is not an assertion
that tanh outputs themselves are Gaussian.

## 3. Sampling noise in Bures distance

Given the previous actual empirical Gram, the N new neuron rows are iid.
Every product of two tanh outputs lies in[-1,1]. Thus each next empirical
covariance differs entrywise from G_t(Qhat) by at most u except with
conditional probability at most

    2m^2 exp(-N u^2/2).                              (9)

An entrywise error u has operator norm at most m u. The square-root matrix
inequality gives

    b(Qhat_new,G_t(Qhat))
       <=||sqrt(Qhat_new)-sqrt(G_t(Qhat))||F
       <=m sqrt(u).                                 (10)

For example, use operator square-root monotonicity to get
||sqrt(A)-sqrt(B)||op<=sqrt(||A-B||op), then multiply by sqrt(m).
No lower eigenvalue bound is needed.

Let Lambda=exp(C epsilon^2 h0)<=exp(C' D), and choose

    e_goal=r/32,
    u=min{(e_goal/(2m h0 Lambda))^2, c3 epsilon^2 r}.

All inverse powers of u are at most exp(C''D): m=2^d, h0 is polynomial in
D and epsilon^-1, and log(1/epsilon)<=D. On the event (9) holds at all first
h0 stages, (8)--(10) give by induction

    b(Qhat_j,Q_j)<=h0 Lambda m sqrt(u)<=e_goal/2

for every j<=h0. This stays below c2 epsilon^(3/2), so the use of the local
bound (8) is justified throughout. At the start Qhat_0=Q_0 is deterministic.
A covariance entry differs by at most C e_goal, since the population row
norms are at most sqrt2 and coupled row errors at most e_goal. Adjusting the
constant32 if necessary, (4) yields

    max_ij |(Qhat_h0)ij-q_*1_(i=j)| <=r/2.            (11)

The integer h0 is harmless; enlarge constants if necessary.

## 4. Preserve whitening for arbitrarily longer free prefixes

Bures expansion must not be accumulated for all h when h is arbitrarily
large. After (11), switch to a small invariant entrywise box.

If every entry is within r of q_*I, each diagonal has scalar contraction
factor at most1-c epsilon by (2). For an off-diagonal entry rho, write
R(q_i,q_j,rho)=G_t(Q)_ij. Gaussian covariance differentiation gives

    partial_rho R(q_i,q_j,0)
       =t^2 E sech^2(t sqrt(q_i)Z) E sech^2(t sqrt(q_j)Z).

Its derivatives in q_i,q_j and rho are uniformly bounded near this box,
since the relevant tanh derivatives are bounded. Consequently, because
r=c1 epsilon^3/m is much smaller than epsilon^2,

    |R(q_i,q_j,rho)| <=(1-c epsilon^2)|rho|.          (12)

The independent-coordinate value at rho=0 is zero. Thus the population map
contracts the entrywise box by at least1-c epsilon^2. Choosing c3 small,
the sampling perturbation u in Section3 preserves that box at every further
stage. This proves (1) on the event that all h sampling checks pass, since
Frobenius error is at most m r=c1 epsilon^3.

Finally, (9) and a conditional union bound show failure probability at most
2h m^2 exp(-N u^2/2). Since u^-2<=exp(CD), the width
N>=exp(A D) log(h+2), with A sufficiently large, makes this at most1/16.
This proves the claim.

## Consequence for the cheap all-label witness

Combine (1) with `nearcritical-cheap-all-label-mass.md`. The reset covariance
has relative Frobenius error O(epsilon^2), costing O(epsilon^4) row KL.
Controlled-stage accuracy is ensured by N at least exp(CD) times the logarithm
of the number of stages, because its eigenvalue floor is exp(-CD). Therefore the
all-label mass statement can use the improved width condition

    H>=C epsilon^-2 D,
    N>=exp(CD) log(H+2),
    Pr{f(x)z(x)>1/2 for all x}
       >=exp[-C N(1+epsilon^2 D)].

This remains only a prior-mass/whitening result. It does not alone establish
posterior flatness at the sharp nearcritical depth scale.
