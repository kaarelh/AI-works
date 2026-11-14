# Independent review: sharp expected oracle for the final Gibbs posterior mean

Date: 2026-11-14. Reviewer task: critically check the proposed final-posterior-mean theorem, independently of its proposer.

## Verdict

The proposed theorem is correct. The replace-one/variance-cancellation proof is valid for arbitrary measurable priors on jointly measurable predictors taking values in `[-1,1]`, arbitrary iid laws of inputs and labels in `[-1,1]`, and sufficiently small fixed inverse temperature. It gives a coefficient-one expected oracle, without a realizability or Bernstein assumption.

A shorter leave-one-out proof below improves the original proposed constant from 64 to 20 and replaces the denominator `n` by `n+1`. This is **not a new general statistical phenomenon**: Høgsgaard, Rebeschini, and Wegel proved the finite-dictionary version in July 2026, with the better squared-loss constant 16. Their paper must be cited. Our version supplies a self-contained arbitrary-prior statement suitable for continuous network priors.

Reference checked against the actual primary text:

- Mikael Møller Høgsgaard, Patrick Rebeschini, and Tobias Wegel, *Aggregation with Exponential Weights is Optimal in Expectation*, arXiv:2607.02247 (2026), Theorem 1, Proposition 3, and Lemmas 1–2.
- https://arxiv.org/abs/2607.02247
- https://arxiv.org/html/2607.02247v1

Their Theorem 1 gives temperature `T >= 4 b^2` for squared loss on `[0,b]`; translation to `[-1,1]` gives `T >= 16`. The theorem explicitly concerns random design and expectation. Their discussion and cited Lecué–Mendelson lower bound explain that the final aggregate need not have the corresponding fast bound in probability.

## Full arbitrary-prior statement

Let `(Theta,A,pi)` be a probability space and let `(theta,x) -> f_theta(x)` be jointly measurable with `f_theta(x) in [-1,1]`. Let `Z_i=(X_i,Y_i)` be iid from an arbitrary probability law `D`, with `Y_i in [-1,1]`. Set

`R(f) = E_D (f(X)-Y)^2`.

For `0 < eta <= 1/20` define

`pi_S(dtheta) = exp(-eta sum_i (f_theta(X_i)-Y_i)^2) pi(dtheta) / Z_S`,

and the final posterior mean

`m_S(x) = integral f_theta(x) pi_S(dtheta)`.

Then for every integer `n >= 0` and every sample-independent probability measure `Q` on `Theta`,

`E_{S~D^n} R(m_S) <= integral R(f_theta) Q(dtheta) + KL(Q||pi)/(eta (n+1))`.

Thus the infimum over all such `Q` may be taken on the right. Infinite relative entropy makes the comparison vacuous. The measure `Q` may depend on `D`; it must not depend on the observed sample. The risk, posterior, and posterior mean are measurable by bounded joint measurability and Tonelli. No network parameter compactness is required for this statistical theorem.

## Proof by a continuous tilting lemma

Fix a probability measure `p` on an arbitrary parameter space, values `a_theta in [-1,1]`, and a label `y in [-1,1]`. Write

`ell(theta) = (a_theta-y)^2 in [0,4]`,

`q_t(dtheta) = exp(t eta ell(theta)) p(dtheta) / integral exp(t eta ell) dp`, for `0 <= t <= 1`, and `q=q_1`.

All functions under differentiation are bounded, so dominated differentiation gives

`d/dt E_{q_t} ell = eta Var_{q_t}(ell)`.

For any probability measure `r`, the 4-Lipschitz property of `a -> (a-y)^2` on `[-1,1]` and the independent-copy identity for variance give

`Var_r(ell) <= 16 Var_r(a)`.

Moreover

`dq_t/dq = exp(-(1-t) eta ell) Z_1/Z_t <= exp(4 eta (1-t))`.

Using `Var_r(a)=inf_c E_r(a-c)^2`, this implies

`Var_{q_t}(a) <= exp(4 eta (1-t)) Var_q(a)`.

Consequently

`E_q ell - E_p ell`
`= eta integral_0^1 Var_{q_t}(ell) dt`
`<= 16 eta integral_0^1 exp(4 eta (1-t)) dt Var_q(a)`
`= 4(exp(4 eta)-1) Var_q(a)`.

At `eta <= 1/20`, `4 eta <= 1/5`, and `exp(u) <= 1/(1-u)` for `0 <= u < 1` gives `4(exp(4 eta)-1) <= 1`. The exact variance identity therefore yields

`(E_q a-y)^2 = E_q ell - Var_q(a) <= E_p ell`.

This is the required deterministic tilting inequality. The permissible range from this proof is actually `eta <= log(5/4)/4`, but the simpler `1/20` is convenient.

Now take an arbitrary deterministic sample of size `N=n+1`. Let `p` be its full Gibbs posterior. Deleting observation `i` gives

`q_i(dtheta) proportional to exp(eta ell_i(theta)) p(dtheta)`.

Apply the tilting inequality at `(x_i,y_i)` and average over `i`:

`(1/N) sum_i (m_{S without i}(x_i)-y_i)^2 <= integral empirical_R_S(f_theta) p(dtheta)`.

The Gibbs variational identity gives, for every `Q`,

`integral empirical_R_S dp + KL(p||pi)/(eta N)`
`<= integral empirical_R_S dQ + KL(Q||pi)/(eta N)`.

Discard the nonnegative posterior KL term. Finally take expectation over `N` iid observations. Each leave-one-out sample is independent of its held-out observation and has the same law as an `n`-point sample. Thus the expected left side is exactly `E R(m_{S_n})`. Since `Q` is fixed independently of the sample, its expected empirical risk is its population risk. This proves the theorem.

## Cross-check of the original replacement proof

The original proposed proof is also valid. Put `S=(T,z)`, let `z'` be fresh, write `p=pi_(T,z)`, `r=pi_(T,z')`, and `Delta=ell_z'-ell_z`. The expected Gibbs generalization gap is

`A = (eta/2) E integral_0^1 Var_{p_t}(Delta) dt`,

where `p_t proportional to r exp(t eta Delta)`. The loss Lipschitz inequality gives

`Var_{p_t}(Delta) <= 32 (Var_{p_t} f(X) + Var_{p_t} f(X'))`.

Compare the first variance to `r`, for which `X` is fresh, and the second to `p`, for which `X'` is fresh. The endpoint density bounds are respectively `exp(8 eta t)` and `exp(8 eta (1-t))`. If `V=E Var_{pi_S} f(X_fresh)`, integration gives

`A <= 4(exp(8 eta)-1) V`.

The exact identity `R(m_S)=integral R(f) dpi_S - Var_{pi_S} f(X_fresh)` cancels this gap at sufficiently small `eta`. The Gibbs variational identity then produces the claimed oracle. This supplies an independent cross-check of the central statistical idea, although the leave-one-out proof has better constants.

## Scope and potential misstatements to avoid

1. **Final posterior mean, not a posterior draw.** Posterior averaging is essential to the variance cancellation. Do not state the same fast coefficient-one oracle for Gibbs draws.
2. **Clipped likelihood and clipped predictions.** Network application takes `f_theta=clip(z_theta)` in BOTH the squared-loss likelihood and posterior mean. The proof does not apply to unbounded raw network loss merely because predictions are clipped afterward.
3. **Expectation, not a high-probability fast oracle.** General exponential-weight aggregates are deviation-suboptimal. A fast logarithmic-confidence conclusion requires an additional argument or a modified learner.
4. **No direct Markov conversion on comparator excess.** `R(m_S)-inf_g R(g)` can be negative because a mixture may beat every individual comparator. Markov cannot be applied to that signed random variable. Applying it relative to the Bayes regression function instead generally multiplies the approximation error by `1/delta` and loses the desired leading constant.
5. **An arbitrary prior is allowed, but a useful network rate still requires a small-KL comparison measure.** This theorem by itself does not repair the width-dependent prior mass of the original fixed-width independent Gaussian prior. Hierarchical active-width/spike-and-slab priors can repair it, at the cost of changing the prior.
6. **The coefficient-one comparator is randomized `Q`.** Passing to a single continuously parametrized network requires a positive-prior neighborhood and an approximation estimate; a point mass has infinite KL under a non-atomic prior.
7. **Finite temperature.** This result is particularly natural for a fixed Gaussian noise variance `1/(2 eta)` after clipping. It is different from a strong-prior zero-temperature or exact-interpolation limit.
8. **Literature attribution.** The broad final-aggregate phenomenon is already in HRW2026. The note should present the NN application and any refined prior construction as the new contribution, while proving the needed statistical lemma self-containedly with attribution.

## Remaining uncertainty

No logical gap found in either statistical proof. This review does not certify the separate network perturbation/KL construction or the same-Gaussian strong-prior absorption improvement; those need their own checks. No Lean formalization was performed.
