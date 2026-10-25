# A cheaper nearcritical all-label mass witness

25 October 2026. New proof for independent review. Let `t=1+epsilon`, with `0<epsilon<=epsilon0`, for a sufficiently small absolute epsilon0. Put

    m=2^d,   D=d+1+log(1/epsilon).

This improves the **action/mass** part of the supercritical lower-bound program. It does not by itself prove the desired sharp depth `O(epsilon^-2 D)` posterior-flattening theorem.

## Theorem

There are absolute constants C0,C1,C2 such that, for every Boolean table f, if

    H >= C0 epsilon^-2 D,
    N >= exp(C1 D) log(H+2),

then the actual finite Gaussian tanh network with variances `t^2/d,t^2/N,t^2/N^2` satisfies

    Pr{f(x)z(x)>1/2 for every x}
        >= exp[-C2 N(1+epsilon^2 D)].                  (1)

The depth-dependent constant in the exponent has improved from order D to `1+epsilon^2 D`. The width exponent is O(D), using the separately derived and independently checked free-prefix Bures estimate in `nearcritical-bures-free-prefix.md`.

## 1. Uniform scalar facts

Let `q_*>0` solve `q_*=F(t^2 q_*)`, where `F(s)=E tanh^2(sqrt(s)Z)`. Uniformly near epsilon=0,

    q_*=epsilon+O(epsilon^2),
    T'(q_*)=1-2epsilon+O(epsilon^2),
    h(q_*):=t^2 [E sech^2(t sqrt(q_*)Z)]^2
                  =1-(2/3)epsilon^2+O(epsilon^3).     (2)

The function h is Lipschitz with an absolute constant on a fixed bounded q interval. On `q in [q_*,q_*+B epsilon^2]`, for any fixed B, the scalar map `T(q)=F(t^2 q)` has derivative at most `1-c epsilon`, after reducing epsilon0 depending on B. Constants B used below are fixed once, before epsilon is varied.

All target covariances have compound-symmetric form

    Q=r I+w f f^T,    r>0, w>=0, q=r+w.

Use centered Gaussian preactivation covariance

    C=t^2[r I+a w f f^T],    a>=1.                     (3)

The following bounds hold for the next target `(r',w')`:

    q'=T(q+(a-1)w),
    w'>=a h(q+(a-1)w) w,
    r'>=h(q+(a-1)w) r,
    r'<=t^2 r,     w'<=a t^2 w.                       (4)

The lower bounds are first Hermite projections onto the shared and independent Gaussian coordinates, followed by Jensen. The upper bounds are Gaussian Poincare, respectively in the independent coordinate conditionally on the shared one, and in the shared coordinate for its conditional mean. Relative to the prior preactivation law `N(0,t^2 Q)`, the covariance ratio changes only one eigenvalue, by at most a. Thus, for `0<=a-1<=1`, its row KL is at most `C(a-1)^2`.

## 2. A weak seed with cost O(epsilon^2)

Starting at `q_* I`, use one seed preactivation covariance

    t^2[q_* I+(epsilon q_*/m) f f^T].                  (5)

Its covariance-ratio eigenvalue is `1+epsilon`, so its row KL is `O(epsilon^2)`. The output has

    c epsilon^2/m <= w_seed <= C epsilon^2/m,
    0<=q_seed-q_*<=C epsilon^2/m,
    r_seed>=c epsilon.                               (6)

The lower common component follows from the first Hermite projection; the upper bounds use monotonicity/Lipschitz continuity of F. This deliberately weaker seed avoids a diagonal deviation of order epsilon/m, which would be too large for the next near-equilibrium phase when epsilon is very small.

## 3. Amplify to w=Theta(epsilon) at total cost O(epsilon^2 D)

Choose fixed constants A>0 and c0>0 in the following order. First take A sufficiently large compared with the absolute constants in (2) and (6). Then take c0 sufficiently small, depending on A and those constants. While w<c0 epsilon, use

    a=1+A epsilon^2.                                 (7)

There is a fixed B such that throughout this phase

    q_* <= q <= q_*+B epsilon^2,
    w' >= (1+c epsilon^2)w.                          (8)

Here is the invariant argument, including the dependence of B on A,c0. The injection in the scalar variance is `(a-1)w<=A c0 epsilon^3`. Scalar contraction gives

    q'-q_* <= (1-c1 epsilon)(q-q_*)
                              +C A c0 epsilon^3.

Thus one can take `B=C_seed+C' A c0`, with fixed absolute C_seed,C'. From (2) and Lipschitz continuity of h,

    h(q+(a-1)w)
       >=1-[C_h+C'' B+o(1)]epsilon^2.

Choose A so `A>=8(C_h+C'' C_seed+1)`, then c0 so `C'' C' A c0<=A/8`; reduce epsilon0 to absorb the o(1). Multiplying by `a=1+A epsilon^2` yields the growth in (8). The output at the stopping time is at most `2c0 epsilon`, by the upper w bound in (4).

Starting from (6), the number of layers is at most

    J1 <= C epsilon^-2 log(m/epsilon)
        <= C epsilon^-2 D.                          (9)

Each row costs O(epsilon^4) KL, so the phase costs at most `C epsilon^2 D` per row.

The residual eigenvalue obeys `r'>=(1-C epsilon^2)r` in this phase, by (4) and the invariant. Therefore after the phase

    r >= c epsilon exp(-C epsilon^2 J1)
      >= exp(-C D).                                 (10)

## 4. Amplify the common component to a fixed constant at O(1) cost

At this point `w>=c0 epsilon`, `q=O(epsilon)`, and `r=O(epsilon)`. Choose a fixed large A2, and then a fixed sufficiently small target p>0. While w<p, use

    a=1+A2 q.                                       (11)

For all q below a small absolute threshold, with p sufficiently small, the elementary bound `E sech^2(sqrt(s)Z)>=1-s` gives

    h(q+(a-1)w)>=1-Cq,
    w'>=(1+c2 q)w.                                 (12)

One may, for example, choose A2 large enough to dominate the fixed C, and then p small enough that the quadratic remainder in `(1+A2q)(1-Cq)` is at most half its linear gain. Constants are independent of epsilon.

The required small-q range is preserved for sufficiently small epsilon0. Indeed q>=w, so (12) gives `w'-w>=c2 w^2`, implying at most `C/w_start<=C'/epsilon` phase steps. The residual upper bound in (4) gives

    r_j<=t^(2J2) r_start<=C epsilon.

Consequently `q_j=w_j+r_j<=w_j+C epsilon`. Before stopping, w<p; the one-step overshoot is at most a fixed factor, so choosing p first and epsilon0 sufficiently small keeps q below the required threshold throughout. This is a bootstrap: before any hypothetical exit, the reciprocal-w bound already controls the number of elapsed steps and hence r, excluding that exit.

Since w>=c0 epsilon, one has q<=Cw along this phase. Hence

    (a-1)^2=A2^2 q^2 <= C(w'-w).

Summing shows total row KL is O(1). The terminal common component is at least p, so the readout will also have O(1) normalized KL cost.

For residual eigenvalues, (12) also gives

    log(w'/w)>=c3 q,
    sum_phase q <= C log(1/epsilon).

Together with `r'>=(1-Cq)r` and (10), this proves a uniform target-eigenvalue floor

    r_j >= ell:=exp(-C D)                            (13)

throughout the full target schedule. The number of phase-two steps is O(epsilon^-1), absorbed by the depth in (9).

## 5. Finite-N covariance correction must also be cheap

A constant relative covariance accuracy would cost O(1) KL **per layer** and destroy the improvement. Instead impose the sharper empirical accuracy

    ||Qhat-Q||F <= c epsilon^2 ell,                  (14)

at every controlled stage. Then
`B=Q^(-1/2)Qhat Q^(-1/2)=I+E` has `||E||F<=c epsilon^2`.

For each desired covariance let

    S=Q^(-1/2)(C/t^2)Q^(-1/2)=I+U,

where U is positive semidefinite of rank at most one. During either amplification phase, `||U||op<=delta:=a-1`. The exact empirical-span Gaussian correction has twice its row KL equal to

    [tr S-m-log det S]
    +[tr(B^-1-I)+log det B]+tr[(B^-1-I)U].

For delta<=1, this is bounded by

    C[delta^2+||E||F^2+delta||E||op]
        <=C(delta^2+epsilon^4).                     (15)

Thus phase one still costs O(epsilon^4) per row, and phase two costs O(q^2) per row because q>=c epsilon. The seed has U norm epsilon, costing O(epsilon^2); the reset has U=0 and costs O(epsilon^4).

Implement these controls exactly on the actual empirical feature span, and revert all future weights to the original prior if any check (14) fails. The decisions are past measurable, and (15) gives a deterministic entropy bound on surviving histories; failures add no future cost. Conditional Hoeffding at each controlled stage shows failure probability at most

    2m^2 exp[-c N epsilon^4 ell^2/m^2]

per stage. The width displayed in the theorem more than pays for this, even after a union bound over O(epsilon^-2 D) controlled stages.

## 6. Free prefix, readout, and actual probability

Use all excess depth as an unchanged free prefix. The uniform nearcritical whitening lemma in `nearcritical-bures-free-prefix.md` puts its final empirical Gram within absolute Frobenius radius `c epsilon^3` of `q_*I`, with probability at least 15/16, under

    prefix length >= C epsilon^-2 D,
    N>=exp(C D) log(H+2).

Since q_*=Theta(epsilon), this is relative Frobenius error O(epsilon^2), so the reset bound (15) applies. Choose the total depth constant to leave enough layers for that prefix and both amplification phases. Controlled-check failures have total probability at most 1/16 after increasing the width constant.

At the endpoint, (14) gives `Qhat>=Q/2>=p ff^T/2`. Shift the independent readout mean to produce mean output f, retaining its original covariance. Its entropy is

    [N/(2t^2)] f^T Qhat^-1 f <= N/(t^2 p)=O(N).

Bounded tanh outputs give noise variance at most t^2/N per input; all absolute noise values are below one half with probability at least 15/16 at the stated width. Thus the changed law gives the strict full-margin event probability at least 3/4, while its total KL is bounded by

    C N[epsilon^2+epsilon^2 D+1]
        <=C N(1+epsilon^2 D).

Binary relative entropy proves (1). This is an actual finite-width probability bound, not just a formal rate witness.

## Consequence and remaining tasks

A relative-probability transport proof now only needs a quality budget comparable to `1+epsilon^2 D`, rather than D. At depth `H=K epsilon^-2 D` and when epsilon^2 D is at least a constant, the average available quality is of order epsilon^4/K. Its square root is of the same order as the free off-diagonal contraction gap epsilon^2, with a small constant for large K. This removes one apparent budget obstruction to the natural depth scale.

It does not complete that program. The following still need improvement:

1. `nearcritical-pair-square-root-quality.md` gives a proposed sharpening of the uniform empirical pair error from v^(1/4) to sqrt(v), using normalized-secant nets and one-sided exponential concentration; independent review is pending.
2. The present white-neighborhood occupation argument loses large inverse powers of epsilon.
3. The free-prefix width has now been sharpened to `exp(CD) log(H+2)` in `nearcritical-bures-free-prefix.md` and independently checked. This removes the previous width/depth circularity, but the final transport still needs covariance distance sufficiently smaller than 1/N.
4. When epsilon^2 D is small, the unavoidable O(1) readout/energy baseline must be treated separately from the entropy budget that disrupts hidden mixing. Charging it wholesale to arbitrary hidden array errors may be too crude.

No improved posterior lower-bound depth is claimed yet.
