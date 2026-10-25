# A simpler exponential-depth lower bound when training conditions only on signs

25 October 2026. Research note. This variant uses the raw Gaussian tanh prior, **without imposing a global output margin**, and conditions training only on the signs of outputs. It concerns a fixed hidden variance prefactor `t>1`, not the unresolved exact coefficient-one tanh prior. Unlike the [globally margined theorem](../paper.pdf), this statement follows from sufficiently accurate typical covariance whitening; no rare-event change of measure is needed.

## 1. Model and theorem

Inputs are the augmented Boolean vectors `(1,x)`, with `x in {-1,1}^d`, and `m=2^d`. There are H tanh hidden layers, each of width N, no internal biases, and an independent isotropic Gaussian linear readout. The first-layer and subsequent hidden variances are

    t^2/d,    t^2/N,

for a fixed t>1. The readout coordinate variance can be **any positive scalar** `s_(d,N,H)^2`; it may depend arbitrarily on dimension, width and depth. Since only signs are used, its scale is irrelevant. This includes both `t^2/N^2` and the more usual GP readout scale `1/N`.

Define the raw function probability

    w_f = Pr{sign z(x)=f(x) for every cube input x}.

Each fixed output is nonzero almost surely, so the finite truth table is well-defined almost surely. No global absolute-margin event is imposed. For a training sample S, the posterior conditions only on `sign z(x_i)=f(x_i)`.

**Theorem.** For every fixed t>1 there exist constants `K_t,p_t,c_t>0` and `d0(t)` such that, for every d>=d0(t), at

    H=ceil(K_t(d+1)),    N>=ceil(2^(p_t d)),

one has

    max_f w_f/min_f w_f <= 1+exp(-c_t d).               (1)

Consequently, for any consistent training sample and any unseen input, the posterior probability of either label lies within `O(exp(-c_t d))` of one half. Under the uniform cube test law, confidence failure at threshold `>2/3` is at least

    1 - (# distinct observed inputs)/2^d.

Reducing it below one half requires more than `2^(d-1)=exp(Omega_t(H))` examples. This holds for every target, including the constant target, which has a width-two implementation with all coefficients at most one and output margin greater than one at every depth.

It does not imply a lower bound for deterministic posterior-majority error at the exact 1/2 threshold.

## 2. A Gaussian orthant comparison

Let K be positive definite with

    ||K/q-I||op <= epsilon < 1

for some q>0. For any coordinate orthant O in R^m,

    2^-m [(1-epsilon)/(1+epsilon)]^(m/2)
       <= Pr{N(0,K) in O}
       <= 2^-m [(1+epsilon)/(1-epsilon)]^(m/2).        (2)

**Proof.** The inverse quadratic form is bounded between
`||y||^2/[q(1+epsilon)]` and `||y||^2/[q(1-epsilon)]`, while
`q^m(1-epsilon)^m <= det K <= q^m(1+epsilon)^m`.
Use these bounds pointwise in the Gaussian density. The resulting lower and upper integrals are scalar multiples of isotropic Gaussian probabilities of O. Every orthant has isotropic probability `2^-m` at every positive scale. This gives (2) exactly. No radial truncation or tail estimate is needed.

For epsilon<=1/2, the logarithmic error exponent in (2) is at most `2m epsilon`.

This lemma also applies to any fixed cone with its isotropic Gaussian probability in place of `2^-m`, but only orthants are needed here.

## 3. Free covariance whitening with sufficiently small exceptional probability

Let Q_j be the actual empirical hidden Gram, normalized by N, and let

    T(Q)=E tanh(t Q^(1/2)G)tanh(t Q^(1/2)G)^T,
    Q0(x,y)=(1+x.y)/d.

The empirical transition is exact: conditional on past layers, Q_j is the average of N independent outer products, with mean `T(Q_(j-1))` and entries bounded by one in absolute value. Thus

    Pr{||Q_j-T(Q_(j-1))||max > eta | past}
        <= 2m^2 exp(-N eta^2/2).                       (3)

For fixed t>1, let q_*>0 be the positive scalar fixed point. The free covariance facts proved in the main paper give constants `rho_t>0`, `r_t<1`, `A_t=3t^2`, and an integer `h0<=C_t(d+1)` with

    ||T^h0(Q0)-q_*I||F <= rho_t/8,                     (4)
    ||T(Q)-q_*I||F <= r_t ||Q-q_*I||F
                 whenever ||Q-q_*I||F <= rho_t.       (5)

The map is globally entrywise Lipschitz with constant A_t. For completeness, (4) follows because free diagonals converge geometrically to q_*, and distinct initial absolute correlations are at most `1-2/(d+1)`. Their normalized odd-Hermite recursion first moves them below one half in `O_t(log(d+1))` layers and then contracts geometrically. Frobenius accuracy costs `O_t(log m)=O_t(d)` layers. For (5), at q_*I the diagonal and off-diagonal covariance derivative multipliers are strictly less than one. Near q_*I, the diagonal-to-off-diagonal derivative terms have coefficients `O_t(|Q_ij|)`, giving a dimension-independent Frobenius derivative estimate. Gaussian differentiation with bounded tanh derivatives gives the global constant A_t. These are the same free-dynamics facts used by the main finite-width margin theorem.

Choose rho_t small enough that rho_t<q_*/4. In the first h0 layers impose per-layer max-entry error at most

    eta0 = rho_t/[16 m h0 A_t^h0].

The global error recurrence and (4) give

    ||Q_h0-q_*I||F <= rho_t/4.                         (6)

There is a constant a_t such that, for all sufficiently large d,

    eta0^2 >= m^(-a_t).                               (7)

This merely uses h0=O_t(d), A_t fixed, and m=2^d. Any polynomial factor in d is absorbed by increasing a_t.

For the remaining layers set the desired final absolute accuracy

    delta=m^-3,
    eta1=(1-r_t)delta/(4m).

On the event that every remaining empirical max-entry error is at most eta1, the local recurrence (5) stays in its radius and gives, for J=H-h0,

    ||Q_H-q_*I||F <= r_t^J rho_t/4 + delta/4.          (8)

Taking J>=C_t(d+1) makes the first term at most delta/2. Thus H=ceil(K_t(d+1)) for a sufficiently large constant K_t suffices, and

    ||Q_H-q_*I||F <= delta.                           (9)

Use (3), a conditional union bound, and (7). The probability beta that either stage fails is at most

    beta <= 2H m^2 [exp(-N m^(-a_t)/2)
                         + exp(-c_t N m^-8)].         (10)

Now choose p_t **after K_t**, sufficiently large that
`p_t>max(a_t+3,11)`. At every N>=ceil(m^p_t), for all sufficiently large d,

    beta <= exp(-m^2).                               (11)

The bad probability only improves as N increases, while the final orthant comparison is independent of the readout scale and of N. Thus the conclusion holds at **all widths above this exponential threshold**, unlike the finite window in the globally margined theorem. Only the existence of a finite exponent p_t matters. The simple requirement p>9 handles the final fine-concentration stage, but by itself need not pay for the first burn-in; the additional t-dependent threshold a_t is retained explicitly. Here there is no restriction opposing a large p_t, because sign probabilities do not have the `exp(-Theta(Nd))` rarity of globally margined events.

## 4. From typical whitening to all truth-table probabilities

Conditional on the final hidden matrix X, the readout outputs are centered Gaussian with covariance

    s_(d,N,H)^2 X X^T = s_(d,N,H)^2 N Q_H.

Its positive scalar factor does not affect signs. On the good event (9), apply (2) with covariance Q_H, q=q_*, and

    epsilon=delta/q_* = m^-3/q_*.

For large d, epsilon<=1/2. With `a=2m epsilon=O_t(m^-2)`, every truth table has conditional probability between `2^-m e^-a` and `2^-m e^a`. Integrating over the hidden features and using the trivial upper bound one on the bad event yields

    (1-beta) 2^-m e^-a <= w_f <= 2^-m e^a+beta.        (12)

Therefore

    max_f w_f/min_f w_f
       <= [e^a+2^m beta]/[(1-beta)e^-a]
       <= 1+C_t m^-2                                (13)

for large d, since beta<=exp(-m^2). Enlarging d0 and reducing c_t converts this to (1).

The comparison is uniform over all truth tables without a union bound over their number: the single good-covariance event controls every orthant at once, and (12) is an inequality between their numerical probabilities.

For an unseen point, pair every sample-consistent truth table with the consistent table obtained by flipping that one point. Equation (1) bounds the paired weights, giving posterior probabilities between `1/(2+exp(-c_t d))` and `(1+exp(-c_t d))/(2+exp(-c_t d))`. Counting unseen inputs proves the theorem.

### Larger depths

The same argument gives a useful uniform variant. For every H>=K_t(d+1), it suffices to take

    N >= m^p_t log(H+2).

After burn-in, the fine-error recurrence (8) stays contractive for arbitrarily many additional layers. The factor log(H+2) in width pays for the union bound (10), retaining beta<=exp(-m^2). The all-truth-table ratio (13) follows unchanged. The exponential-in-depth sample conclusion is drawn along H=Theta_t(d), since the finite cube itself has only 2^d points.

## 5. What changed, and what did not

This is a simpler theorem than the globally margined main paper because raw sign truth tables have mass about `2^-m`. Typical covariance concentration can be made exceptional on a probability much smaller than that. In the main model, the full-domain fixed-margin events have mass on the scale `exp(-Theta(Nd))`; the corresponding comparison requires the much stronger empirical quality budget and controlled all-label mass argument.

The present note conditions training **only on output signs**. It does not automatically cover conditioning on fixed nonzero real margins at the training inputs, still less exact real-valued outputs. Those events can be much rarer under the shrinking readout, and (11) need not be negligible relative to them. The main paper separately covers the original global-margin-plus-exact-label setup, but neither argument should be silently transferred to an intermediate likelihood.

The result uses fixed t>1 and augmented inputs. It does not resolve exact canonical t=1. It does show that the exponential-depth confidence obstruction at a supercritical hidden prefactor is not an artifact of imposing a margin at all unobserved inputs.

## Status

An independent finite-width mathematical audit passed on 25 October 2026. It is not Lean formalized. Its free-dynamics ingredients are already checked in the main paper; the new steps are the direct orthant-density comparison and the stronger ordinary covariance concentration needed relative to `2^-m`.
