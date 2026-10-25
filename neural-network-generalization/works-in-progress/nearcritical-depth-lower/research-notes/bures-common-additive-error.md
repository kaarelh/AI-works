# Dimension-free Bures comparison under a common covariance error

25 October 2026. Complete finite-dimensional proof for the empirical transfer in `nearcritical-normalized-coupling.md`. The errors below may be indefinite. No assertion about geodesic convexity of correlation matrices is needed.

## Theorem

Let A,B be real symmetric positive definite m-by-m matrices satisfying

    ||A-I||op<=1/4, ||B-I||op<=1/4.

Let E,F be symmetric with ||E||op,||F||op<=eta<=1/10. Then

    d_B(A+E,B+F)
       <=(1+3eta)d_B(A,B)+||E-F||F.                  (1)

In particular, if ||E-F||F<=eta d_B(A,B),

    d_B(A+E,B+F)<=(1+4eta)d_B(A,B).                 (2)

All constants are independent of m. Both translated endpoints are positive definite automatically.

More generally, if aI<=A,B<=bI with 0<a<=b and eta<a²/b, the proof gives

    d_B(A+E,B+F)
      <=(1-eta b/a²)^(-1/2)d_B(A,B)
          +||E-F||F/[2sqrt(a-eta)].                 (3)

## 1. Bures norm and an explicit optimal path

For positive definite covariances define

    d_B(A,B)=min ||X-Y||F over XX^T=A, YY^T=B.

Square factors suffice, with an orthogonal alignment. Equivalently,

    d_B(A,B)²=tr A+tr B-2tr[(A^(1/2) B A^(1/2))^(1/2)].

The identity follows from the orthogonal Procrustes formula: the largest possible cross trace is the nuclear norm of B^(1/2)A^(1/2), equal to the displayed square-root trace.

Set

    T=A^(-1/2)(A^(1/2) B A^(1/2))^(1/2)A^(-1/2).

Then T is symmetric positive definite, TAT=B, and the factors
X_0=A^(1/2), X_1=T A^(1/2) are optimally aligned. Define

    R_s=(1-s)I+sT,
    X_s=R_s A^(1/2), Q_s=X_s X_s^T, 0<=s<=1.

The factor velocity is constant and

    ||dot X_s||F=||(T-I)A^(1/2)||F=d_B(A,B).          (4)

If aI<=A,B<=bI, the relation TAT=B implies

    sqrt(a/b) I<=T<=sqrt(b/a) I.

Indeed B=TAT<=bT² and B>=aI give T²>=a/b I; the other inequality follows from B>=aT² and B<=bI. Therefore

    a²/b I<=Q_s<=b²/a I                             (5)

for every s. These bounds do not require A and T to commute.

## 2. A path-length bound derived from factor lifts

On the real symmetric-matrix Hilbert space with Frobenius inner product, let

    L_Q(S)=QS+SQ.

For Q positive definite, L_Q is a positive definite self-adjoint linear operator. Define for a symmetric tangent H

    g_Q(H)=1/2 <H,L_Q^(-1)H>F.                       (6)

Every continuously differentiable positive-definite path Q_s satisfies

    d_B(Q_0,Q_1)<=integral_0^1 sqrt(g_(Q_s)(dot Q_s)) ds. (7)

Here is a direct proof, avoiding any appeal to a geodesic theorem. Put
S_s=L_(Q_s)^(-1)(dot Q_s), and solve the finite-dimensional linear ODE

    dot Y_s=S_s Y_s, Y_0=Q_0^(1/2).

The matrix Y_sY_s^T and Q_s solve the same linear covariance ODE, with the same initial value, so Y_sY_s^T=Q_s. Moreover

    ||dot Y_s||F²=tr(S_s Q_s S_s)
                =1/2 tr(dot Q_s S_s)=g_(Q_s)(dot Q_s).

The two endpoints of Y_s are valid covariance factors. Their Frobenius distance is bounded by the integral of their speed, proving(7).

For the particular path in Section1, its existing factor lift X_s is already minimizing at every tangent. In fact

    S_s=(T-I)R_s^(-1)

is symmetric because R_s is a polynomial in T. It satisfies dot X_s=S_sX_s and dot Q_s=S_sQ_s+Q_sS_s. Hence, by uniqueness of the Sylvester solution,

    g_(Q_s)(dot Q_s)=||dot X_s||F²=d_B(A,B)².         (8)

## 3. Translating by one common error

Write a0=a²/b. By(5), Q_s>=a0 I. A symmetric E with ||E||op<=eta<a0 satisfies

    Q_s+E >=(1-eta/a0)Q_s.

Let alpha=1-eta/a0>0. This Loewner inequality implies the corresponding operator inequality on symmetric matrices,

    L_(Q_s+E)>=alpha L_(Q_s).                        (9)

To check it, put C=Q_s+E-alpha Q_s>=0. For every symmetric U,

    <U,L_C(U)>F=2tr(C U²)>=0.

Inverting positive definite operator inequalities reverses their direction, so

    L_(Q_s+E)^(-1)<=alpha^(-1)L_(Q_s)^(-1).

The tangent of the translated path Q_s+E is still dot Q_s. By(6)--(8), its Bures length is at most alpha^(-1/2)d_B(A,B). Applying(7) gives

    d_B(A+E,B+E)<=alpha^(-1/2)d_B(A,B).              (10)

This is the crucial point: the multiplicative loss depends on the *added error eta*, not on the radius of the original white ball. The original ball contributes only the fixed positive lower bound a0.

## 4. Changing the error at the second endpoint

Both U=B+E and V=B+F have eigenvalues at least a-eta. If Z=sqrt(U)-sqrt(V), then

    sqrt(U)Z+Z sqrt(V)=U-V=E-F.

Taking the Frobenius inner product with Z and using positive definiteness gives

    2sqrt(a-eta)||Z||F²<=<Z,E-F>F
                           <=||Z||F ||E-F||F.

Thus

    d_B(B+E,B+F)<=||sqrt(U)-sqrt(V)||F
                  <=||E-F||F/[2sqrt(a-eta)].        (11)

Combining(10)--(11) by the triangle inequality proves(3).

For the stated white ball take a=3/4, b=5/4, so a0=9/20. Since eta<=1/10, x=eta/a0<=2/9. The elementary bound (1-x)^(-1/2)<=1+x for 0<=x<=1/2 gives

    alpha^(-1/2)<=1+(20/9)eta<=1+3eta.

Also a-eta>=13/20, so 1/[2sqrt(a-eta)]<1. This proves(1), and(2) follows immediately.

## Use in normalized empirical covariance transport

If the population endpoint covariances are P,P' in this fixed ball, and their empirical errors satisfy

    ||E||op,||E'||op<=eta,
    ||E-E'||F<=eta D(input states),

then(1) gives

    d_B(P+E,P'+E')
      <=d_B(P,P')+Ceta D(input states),

provided the population map itself has a bounded Lipschitz constant in D. Combining this with an exact population contraction1-c epsilon² and the corresponding logarithmic-diagonal error bound gives empirical contraction1-c epsilon²+Ceta. In particular eta=O(sqrt(v)) requires v<=c epsilon^4. The common-additive comparison supplies this statement without multiplying the population contraction by an unwanted1+O(white-ball-radius) constant.
