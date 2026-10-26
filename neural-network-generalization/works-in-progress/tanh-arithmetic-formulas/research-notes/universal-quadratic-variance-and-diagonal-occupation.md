# Quadratic variance and diagonal-spread occupation for arbitrary entropy controls

26 October 2026. Scratch scalar estimates for exact tanh. These bounds
hold for arbitrary finite-relative-entropy row controls; they do not
construct scalar feature formulas or prove a new posterior theorem.

Let F(a)=E_gamma tanh²(sqrt(a)Z). Fix a universal compact variance
interval 0<a<=Q and a compact prefactor interval 1<=t<=1+delta0.
Constants below depend only on these fixed upper bounds.

## 1. Entropy controls the relative output variance

Let rho be any probability law on R with KL(rho||gamma)<=D, and put
Y_a(z)=tanh²(sqrt(a)z), m=E_rho Y_a. Then

    |log(m/F(a))|<=C(sqrt(D)+D).                         (1)

The same conclusion applies to a scalar marginal of a full row law
whose full entropy is at most D, by data processing.

For the upper bound and the small-D lower bound, observe 0<=Y_a<=aZ².
Consequently its centered Gaussian moments obey

    E_gamma |Y_a-F(a)|^k <=k! (Ca)^k,       k>=2.

Thus, for |lambda|<=c/a,

    log E_gamma exp[lambda(Y_a-F(a))]<=C lambda²a².

The entropy variational inequality, optimized over positive and negative
lambda, gives

    |m-F(a)|<=Ca(sqrt(D)+D).                            (2)

Since c_Q a<=F(a)<=a on the fixed compact interval, (2) gives the
logarithmic comparison C sqrt(D) for D below a fixed positive threshold.
It also gives the upper logarithmic bound C(sqrt(D)+D) for every D.

For the remaining lower bound, there is c_Q>0 such that

    Y_a(z)/a>=c_Q min(z²,1).

For lambda>=1 this implies

    E_gamma exp[-lambda Y_a/a]
        <=(1+2c_Q lambda)^(-1/2)+exp(-c_Q lambda)
        <=C_Q lambda^(-1/2).

Writing u=m/a>0, entropy duality gives

    D>=-lambda u+(1/2)log lambda-log C_Q.

If u<=1/2, take lambda=1/(2u) to obtain u>=c_Q exp(-2D).
If u>1/2 the same lower bound follows after decreasing c_Q.
Since F(a)<=a, m/F(a)>=c_Q exp(-2D). For D above the fixed small-D
threshold the additive constant in its negative logarithm is absorbed
by C D. This proves (1). Positivity follows as well, since finite KL
cannot concentrate at the unique zero of Y_a.

## 2. A dimension-free quadratic occupation bound

Consider a finite-witness controlled tanh covariance path Q_j. At step j,
its full row law has entropy D_j relative to N(0,t²Q_(j-1)), with
q_j=max_x Q_j(x,x). Assume q_0<=2; then q_j<=1 for j>=1.

The stronger additive upper bound (2), applied to each marginal, and
monotonicity of F imply

    q_j<=F(t² q_(j-1))
           +C q_(j-1)(sqrt(D_j)+D_j).                  (3)

On the relevant fixed compact interval, F(a)<=a-c a². With delta=t-1,

    q_j-q_(j-1)
      <=C delta q_(j-1)-c q_(j-1)²
          +C q_(j-1)sqrt(D_j)+C q_(j-1)D_j
      <=C delta²+C D_j-c' q_(j-1)².                    (4)

Here Young's inequality absorbs the delta and sqrt(D_j) products, and
q_(j-1)<=2 absorbs the last term. Summing and using q_H>=0 gives

    sum_(j=1)^H q_(j-1)²
        <=C[1+delta²H+sum_j D_j].                      (5)

No Gaussian-control restriction, monotonic variance sequence, finite
coordinate dimension, or inverse variance bound is used.

## 3. Diagonal-spread occupation with arbitrary controls

Assume q_min,0=min_x Q_0(x,x)>0 and all D_j finite. Define

    s_j=q_min,j/q_j in (0,1],   Delta_j=1-s_j,
    eta_j=C(sqrt(D_j)+D_j).

Equation (1) gives

    q_min,j>=e^(-eta_j)F(t²q_min,j-1),
    q_j<=e^(eta_j)F(t²q_(j-1)).

Thus

    s_j>=e^(-2eta_j) F(t²q_(j-1)s_(j-1))
                              /F(t²q_(j-1)).

The elementary scalar telescope in
`gaussian-diagonal-defect-quadratic-occupation.md`, Section 1, says

    log[F(a s)/(s F(a))]>=c_Q a(1-s),   0<a<=Q.

For completeness, g(a)=F(a)/a has -g'/g bounded below by a positive
constant on [0,Q]: tanh²(sqrt(y)) is strictly concave, and the limit at
zero is2. Integration from as to a gives the displayed inequality.
Since t>=1, we obtain

    log s_j-log s_(j-1)
       >=c q_(j-1)Delta_(j-1)-2eta_j.

Summation, with log s_H<=0, yields

    sum_(j=1)^H q_(j-1)Delta_(j-1)
       <=C[log(1/s_0)+sum_j sqrt(D_j)+sum_j D_j].        (6)

This bound allows each controlled layer to worsen the diagonal spread;
its entropy pays for the possible logarithmic loss. For the original
augmented cube input, s_0=1 exactly.

## 4. Meaning and limits

At critical prefactor t=1, bounded total row entropy implies uniformly
bounded quadratic maximum-variance occupation (5), even for arbitrary
non-Gaussian controls. Near criticality its additional free contribution
is only delta²H. Equation (6) controls the extra diagonal-defect work
appearing in a Gaussian scalar-formula compiler.

These scalar budgets alone do not turn an arbitrary row tilt into
cheap scalar coordinate formulas. That infinite-dimensional feature
representation problem remains open. In particular no actual posterior
sample bound with delta²H, nor a solution of the original all-target
canonical Boolean tanh depth question, is inferred here.
