# What the supercritical depth lower bound says about majority prediction

25 October 2026. Research follow-up. The completed fixed-`t>1` theorem bounds
ratios of full-margin function weights by `1+rho_d`, with `rho_d=exp(-c_t d)`.
This note separates consequences of that theorem from the still-open exact
majority question for the actual neural-network prior.

## 1. Exact posterior majority remains unresolved

At an unseen point, pairing truth tables gives

    1/(2+rho_d) <= p(correct) <= (1+rho_d)/(2+rho_d).

Thus `|p(correct)-1/2| <= rho_d/[2(2+rho_d)] <= rho_d/4`.
This does not determine which side of one half the probability lies on.
An arbitrarily small bias could still have the correct sign everywhere.
Neither the near-uniform mass ratio nor the ordinary cube symmetries excludes
this possibility.

Here is an explicit counterexample to any such deduction. It is a prior on
Boolean functions, not a claim about the actual Gaussian neural prior.

Let `d>=2`, `X=F_2^d`, `m=2^d`, and let `A` be the `2^(d+1)` affine parity functions
`f_(a,b)(x)=(-1)^(a.x+b)`. For any `rho>0`, assign prior weight

    w(f) = 1 + rho 1{f in A}

and normalize over all `2^m` truth tables. Its largest-to-smallest mass ratio
is exactly `1+rho`, however small rho is. It is invariant under cube coordinate
permutations, input bit flips, and global label reversal.

After any distinct, consistent labeled observations, the uniform component
contributes exactly equal mass to both labels at an unseen point. Therefore

    sign[p(+1|S)-1/2]
      = sign[# consistent affine parities predicting +1
              - # consistent affine parities predicting -1].

Exact posterior majority is precisely the majority prediction of uniform
Bayesian affine-parity learning, regardless of how small rho is. Once the
sample determines a unique affine parity, this predictor is correct everywhere.

For iid uniform inputs, the augmented sample matrix has full rank with
probability at least `1-2^(d+1-n)`: union bound over every nonzero affine form,
whose probability of vanishing on all n samples is either zero (the nonzero
constant form) or `2^-n`. Thus `d+1+ceil(log_2(1/delta))` examples suffice for
perfect majority generalization with probability at least `1-delta`.

In particular, even the joint statements "all function probabilities are
exponentially close to uniform" and "the prior has the usual cube symmetries"
are compatible with polynomial majority learning of all affine parities. The
probability gap carrying this information can be far smaller than the already
tiny upper bound rho/4.

The actual neural prior might still have exponentially poor majority learning,
but proving it requires information about the sign and structure of the
residual biases. Current Bures transport only bounds their magnitude.

## 2. A rigorous lower bound for finite posterior ensembles

There is nevertheless a consequence beyond the fixed-confidence criterion.
Suppose prediction at an unseen point is the majority of r independent draws
from the exact posterior, with independent fair tie breaking. Let
`delta_x=p(correct)-1/2`, so `|delta_x|<=rho_d/4`.

The r correctness indicators are iid Bernoulli `(1/2+delta_x)`. Under the fair
Bernoulli law their randomized majority is correct with probability one half.
Pinsker and the elementary bound

    KL(Bernoulli(1/2+u) || Bernoulli(1/2))
       <= chi_squared(Bernoulli(1/2+u), Bernoulli(1/2))
       = 4u^2

give

    Pr{posterior ensemble majority is correct at x}
       <= 1/2 + sqrt(2r)|delta_x|
       <= 1/2 + rho_d sqrt(r/8).

This bound is valid for either target label, for every realized consistent
training sample, and for every unseen point. Posterior draws may be complete
functions; only their independence across draws is used pointwise.

Under the uniform cube law, letting U(S) be the observed inputs, the expected
test-error rate of this ensemble is therefore at least

    (1-|U(S)|/2^d) [1/2 - rho_d sqrt(r/8)].

For example, if `|S|<=2^(d-1)` and `r<=rho_d^(-2)/2`, the expected error is
at least `1/8`. Thus extracting a constant prediction advantage from the
posterior by ordinary independent posterior-vote ensembles requires
`r=exp(Omega_t(d))=exp(Omega_t(H))` draws, even if the exact infinite-ensemble
majority were well aligned with the target.

This is a posterior-sampling complexity statement, not a training-sample lower
bound for an algorithm with exact access to the posterior majority sign.
It does not cover arbitrary algorithms that inspect sampled network weights
and use additional computation, or non-iid sampling schemes designed to
estimate a tiny bias more efficiently.

## 3. Directions that would be needed for the exact-majority question

The actual model has more structure than near-uniform truth-table weights.
Its input and output symmetries can be expressed as sign-gauge sectors of the
finite-width covariance transition. A plausible route would identify the
leading nonconstant sector in the depth asymptotics and show that it gives a
kernel-like prediction rule, with higher-order label interactions negligible
relative to that leading bias. The current theorem bounds every sector in
absolute magnitude, but does not compare their magnitudes or signs. Its rare
full-margin conditioning also makes an ordinary free-NNGP expansion
insufficient without a relative-probability argument.

No exact-majority theorem or counterexample for the actual fixed-`t>1`
Gaussian neural prior is proved here. The original canonical `t<=1` depth
question likewise remains separate and open.
