# Exponential cancellation in bounded-density Hermite covariance expansions

26 October 2026. A method obstruction for separate Wick-term sampling.
It is not a lower bound for scalar formulas, neural networks, or learning.

Let H_n=He_n/sqrt(n!) be the orthonormal probabilists' Hermite polynomial
under gamma=N(0,1). Fix 0<epsilon<=1/2 and an integer K>=1. Define

    a_K=E_gamma sign H_(2K)(Z),
    r_K(z)=1+(epsilon/2)[sign H_(2K)(z)-a_K].             (1)

The value assigned to sign at a polynomial zero is irrelevant. Then
E r_K=1 and 1-epsilon<=r_K<=1+epsilon. In particular

    KL(r_K gamma || gamma)<=C epsilon².                 (2)

Indeed x log x-(x-1)<=C(x-1)² on [1/2,3/2], and the centered density
perturbation has absolute value at most epsilon.

The degree-K covariance perturbation obeys the trivial but sharp uniform
operator bound

    |E_gamma[(r_K-1)H_K²]|<=epsilon,                     (3)

since E H_K²=1. Nevertheless its individual Hermite-product terms can
be exponentially larger.

## 1. The top product term

The normalized Hermite product identity is

    H_K²=sum_(r=0)^K C_(K,r) H_(2K-2r),
    C_(K,r)=r! binom(K,r)² sqrt((2K-2r)!)/K!.

In particular C_(K,0)=sqrt((2K)!)/K!=sqrt(binom(2K,K)).
Since E H_(2K)=0, (1) gives

    E[(r_K-1)H_(2K)]
       =(epsilon/2)E|H_(2K)|.

Thus the r=0 contribution to (3) is positive and equals

    T_(K,0)=(epsilon/2)sqrt(binom(2K,K)) E|H_(2K)|.      (4)

## 2. An elementary polynomial lower bound on the Hermite L1 norm

At zero,

    |H_(2K)(0)|=sqrt((2K)!)/(2^K K!)>=c K^(-1/4).

The exact Taylor polynomial divided by its constant term is

    H_(2K)(x)/H_(2K)(0)
       =sum_(j=0)^K (-1)^j 2^j (K)_j x^(2j)/(2j)!.

If |x|<=c0/sqrt(K), then

    |H_(2K)(x)/H_(2K)(0)-1|
       <=sum_(j>=1)(2Kx²)^j/(2j)!
       =cosh(sqrt(2K)|x|)-1<=1/2

for a sufficiently small fixed c0. The Gaussian density is bounded
below on that interval, hence

    E|H_(2K)(Z)|>=c K^(-3/4).                            (5)

Stirling's bounds give sqrt(binom(2K,K))>=c2^K K^(-1/4).
Combining (4)--(5),

    T_(K,0)>=c epsilon 2^K/K.                            (6)

Thus the remaining product terms cancel a contribution of exponentially
large magnitude, leaving the bounded value in (3). This phenomenon
already occurs in one scalar Gaussian coordinate and with a uniformly
bounded density ratio; neither large KL nor high dimension causes it.

## 3. Consequence for separate-term unbiased estimators

Let T_(K,r)=C_(K,r)E[(r_K-1)H_(2K-2r)]. Any estimator that chooses one
term r with probability p_r>0 and returns T_(K,r)/p_r has second moment

    sum_r T_(K,r)²/p_r >= (sum_r |T_(K,r)|)²
                       >=c epsilon² 4^K/K².            (7)

Allowing an unbiased internal estimator of T_(K,r) cannot lower this
bound: conditional Jensen gives the same right-hand side. Therefore no
uniform polynomial-in-K second-moment estimate is possible for this
termwise importance-sampling strategy, even under (1)--(2).

The obstruction is narrowly stated. Computing or factoring the full
contracted covariance coefficient before sampling retains its
cancellation and can avoid (7). In this one-dimensional example that
aggregation is particularly simple. The construction does not prove
that every fixed-degree feature factory requires exponential work; it
shows why a bound based on absolute separate Wick terms cannot close
an all-degree tanh argument without another cancellation mechanism.
The density r_K depends on K, which is sufficient to rule out a uniform
polynomial bound over all bounded densities and all degrees. No claim
about divergence for one fixed smooth density is needed.

## 4. Stronger example with a bounded analytic density

The same obstruction already holds for a bounded real-analytic density,
with a slightly stronger estimate. Put omega=sqrt(2K) and replace (1) by

    r_K(z)=1+(epsilon/2)[cos(omega z)-exp(-K)].             (8)

Again E r_K=1, 1-epsilon<=r_K<=1+epsilon, KL<=Cepsilon²,
and the actual covariance perturbation in (3) has magnitude at most
epsilon. The Gaussian Hermite--Fourier identity gives

    E[e^(i omega Z)H_n(Z)]
       =(i omega)^n exp(-omega²/2)/sqrt(n!).

For n=2K this implies

    E[(r_K-1)H_(2K)]
       =(epsilon/2)(-1)^K exp(-K)(2K)^K/sqrt((2K)!).

Therefore the absolute top product term is exactly

    |T_(K,0)|=(epsilon/2)exp(-K)(2K)^K/K!
               >=c epsilon 2^K/sqrt(K).                 (9)

The separate-term estimator's second moment is consequently at least
c epsilon²4^K/K. No Hermite L1 estimate is needed for this example.
The density and all its derivatives are bounded for each fixed K,
although no derivative bound uniform in K is asserted. Thus nonsmooth
controls are not needed for the obstruction. The density still depends
on K, and aggregation of the full covariance coefficient can still
avoid this specific termwise loss.

## 5. One fixed analytic density, even with matched first two moments

The degree dependence of the example can also be removed. Fix a>0 and
positive coefficients a_n=c exp(-a n), n>=2, with c so small that
sum_(n>=2) a_n<=1/4. Set

    b_1=-sum_(n>=2) a_n n² exp(-(n²-1)/2),
    c_1=b_1,  c_n=a_n for n>=2,
    r(z)=1+epsilon sum_(n>=1)c_n[cos(nz)-exp(-n²/2)].     (10)

For n>=2, n² exp(-(n²-1)/2)<=1, so sum|c_n|<=1/2. Thus
1-epsilon<=r<=1+epsilon, E r=1, and KL(r gamma||gamma)<=Cepsilon².
The series is analytic in the strip |Im z|<a, and every fixed-order
real derivative is bounded. The density is even, so its mean is zero.
The choice of b_1 gives

    sum_n c_n n² exp(-n²/2)=0,

hence E[(r-1)H_2]=0 and E_r Z²=1. Thus matching the linear covariance
does not remove the following obstruction.

For any K, the positive-frequency part n>=2 contributes the same sign
(-1)^K to E[(r-1)H_(2K)]. The n=1 term has opposite sign but fixed
magnitude before division by sqrt((2K)!). Take the ODD subsequence

    K=2j²+1,   n=2j,   n²=2K-2.

The selected positive term gives absolute top product contribution

    epsilon a_n exp(-(K-1))(2K-2)^K/K!
       >=c epsilon exp(-a sqrt(2K)) 2^K/sqrt(K),          (11)

using Stirling and (1-1/K)^K bounded below for K>=2. The negative n=1
contribution has magnitude epsilon |b_1| exp(-1/2)/K!, negligible
compared with (11). Hence for all large j, the complete top term has
at least half the lower bound in (11). The actual covariance correction
is still bounded by epsilon. This is one fixed bounded analytic density
with matched mean and variance, exhibiting exponential termwise
cancellation along infinitely many odd feature degrees.

## 6. An exact-tanh separate-term expansion has infinite second moment

Fix any q>0 and expand tanh(sqrt(q)Z)=sum_(k odd) a_k(q)H_k(Z).
Every odd coefficient has a useful explicit lower bound. The Fourier
identity

    tanh x=integral_0^infinity sin(omega x)/sinh(pi omega/2) d omega

and Gaussian integration give, for odd k,

    |a_k(q)|=q^(k/2)/sqrt(k!)
       integral_0^infinity omega^k exp(-q omega²/2)
                                  /sinh(pi omega/2) d omega.

This interchange is absolutely justified for each fixed k. Substituting
t=sqrt(q)omega and restricting the integral to [sqrt(k),sqrt(k)+1]
gives, by Stirling,

    |a_k(q)|>=c_q k^(-1/4) exp(-C_q sqrt(k)).             (12)

Indeed t^k exp(-t²/2) is at least e^(-1)k^(k/2)exp(-k/2)
on that interval, and 1/sinh(pi t/(2sqrt(q))) is at least
2exp[-pi t/(2sqrt(q))]. Constants in (12) may depend on the fixed q.
The same estimate holds for normalized coefficients b_k=a_k/sqrt(F(q)).

Consider formally expanding the normalized kernel correction

    E[(r-1) (tanh(sqrt(q)Z)/sqrt(F(q)))²]

first into its two Hermite feature degrees k,l and then each product
H_k H_l into individual Wick/Hermite terms. With the fixed density (10),
the diagonal pair k=l=K and its top product term have magnitude at least

    b_K(q)² |T_(K,0)|
       >=c_(q,a) epsilon (2^K/K) exp(-C_(q,a) sqrt(K))

along the odd subsequence above. These terms do not even tend to zero.
Thus the absolute sum of the fully separated expansion diverges.
Any unbiased estimator selecting one such individual indexed term and
reweighting it by its selection probability necessarily has infinite
second moment, by the finite-subset version of (7) and monotone limits.

The actual kernel correction is bounded by epsilon. Its meaning is the
limit of the grouped finite-Hermite polynomial covariances, which does
converge because r is bounded and the activation expansion converges in
Gaussian L². It is the fully separated sampling scheme that fails.
Aggregating contractions before sampling, or a different factorization,
can preserve the cancellations. No impossibility for those approaches,
for scalar formulas in general, or for learning is proved here.
