# Independent audit: leverage sampling and exact whitening

Research audit, 22 October 2026 (UTC). The completed review covers the reconstruction lemma, assembled theorem, and final standalone sources; see the concluding sections. Earlier sections record the local checks leading to that conclusion. This is independent AI-agent mathematical review, not Lean verification.

Published paper: [PDF](../original-support-all-scales/paper.pdf) · [sources](../original-support-all-scales/source/paper.tex). Source hashes below refer to the audited research copy; publication changes its author line, PDF metadata, reference-link formatting, and trailing whitespace only.

## Source lemma

Let the source index set have size N. Write E_0 for its uniform average.
Let u_j be vectors in R^k with E_0 u_j u_j^T = I_k, where k is the
**actual** active rank. Let h_j(x) be arbitrary bounded source activations,
|h_j(x)| <= 1. Define

    psi(x) = E_0 u h(x),
    K(x,y) = E_0 h(x)h(y),
    C(x,y) = K(x,y) - psi(x)^T psi(y).

For k >= 1 take

    p_j = [1 + ||u_j||^2/k]/(2N),
    a_j = 1/(N p_j) = 2/[1 + ||u_j||^2/k].

These probabilities normalize because E_0 ||u||^2 = k. They obey

    a_j <= 2,       a_j ||u_j||^2 <= 2k,
    ||a_j u_j|| <= sqrt(k).

The rank-zero case must be treated separately by uniform sampling and no
active projection. Substituting a rank cap for k in the displayed formula
without changing its normalization would be incorrect.

Draw m independent source indices. Define sample averages

    G = (1/m) sum a_j u_j u_j^T,
    vhat(x) = (1/m) sum a_j u_j h_j(x),
    Khat(x,y) = (1/m) sum a_j h_j(x)h_j(y).

Each Gram summand is positive semidefinite, has operator norm at most 2k,
and has mean I_k. A matrix Chernoff lower-tail inequality consequently
gives a good event G >= I_k/2 with failure probability bounded by
`k exp(-m/(16k))`; the constant 16 is conservative. The good event is
independent of the input x.

### Active mean error

For any fixed matrix H, independent of the fresh source draws conditional
on the retained variables,

    E ||H(vhat(x)-psi(x))||^2 <= 2 ||H||_F^2 / m.

Indeed the source cross-vector has second moment

    E_p [a^2 u u^T h^2] = E_0 [a u u^T h^2] <= 2 I_k.

Subtracting its mean only decreases its covariance. No bound by the
largest row norm of H is needed. The same upper bound holds with the
indicator of the Gram-good event, because the squared error is nonnegative.

### Exact covariance reconstruction

On the Gram-good event, form an m-by-k matrix D with rows

    sqrt(a_j/m) u_j^T G^(-1/2).

Then D^T D = I_k, so I_m-DD^T is positive semidefinite. For each target
row i draw xi_i ~ N(0,I_m-DD^T), independently across target rows. The
physical row on the m stored source neurons is

    w_hat[i,j] = (a_j/m) H_i u_j + t sqrt(a_j/m) xi_i[j].

Its conditional mean at input x is H_i vhat(x), and its Gaussian residual
covariance is exactly

    t^2 Chat(x,y),
    Chat = Khat - vhat^T G^(-1) vhat.

This is equivalently the construction using active factor H G^(1/2) in
the whitened basis. Omitting that factor would give the wrong mean.

### Scalar Gaussian transport error

Fix x and write

    r_j = h_j(x) - u_j^T psi(x),
    C = E_0 r^2 <= 1,
    chat = (1/m) sum a_j r_j^2,
    b = (1/m) sum a_j u_j r_j.

Orthogonality gives E_0 u r = 0. Direct expansion proves the useful identity

    Chat(x,x) = chat - b^T G^(-1) b.

Since ||psi(x)|| <= 1, the pointwise bound

    a_j r_j^2 <= 4k

follows from r_j^2 <= 2(1+||u_j||^2). Consequently

    Var(chat) <= 4k C/m,
    E ||b||^2 <= 2k C/m.

When C > 0,

    E (sqrt(chat)-sqrt(C))^2 <= Var(chat)/C <= 4k/m.

On G >= I/2, b^T G^(-1)b <= 2||b||^2 and

    (sqrt(chat)-sqrt(Chat))^2 <= chat-Chat = b^T G^(-1)b.

Using the squared triangle inequality therefore gives

    E[(sqrt(Chat)-sqrt(C))^2 ; Gram good] <= 16k/m.

If C=0, then every r_j is zero (the source set is finite with positive
uniform weights). Thus chat=b=Chat=0 exactly, and the same inequality
holds without division by zero.

Coupling the scalar Gaussian evaluations with a common standard normal
therefore gives mean-square reconstruction error, averaged over target
rows, at most

    [2 ||H||_F^2/N + 16 t^2 k]/m

on the good Gram event. The mean difference and Gaussian difference have
zero cross term under this scalar coupling. This is a pointwise coupling
claim; it does not require a single coupling to be accurate at all inputs.

## Conditional dependence and entropy bookkeeping

The intended application has a current virtual prefix A, a finite active
query list J, a current original Gaussian-reference matrix X, and future
original weights Y. The active basis U is a measurable function of A,J.
Although selection of J may inspect the conditional law given A,Y, it
reveals only a finite message, whose entropy is already budgeted.

The actual active matrix H=t X U is a function of A,J,X. Conditional on
the retained variables, the new source indices are sampled from p(A,J).
The Gram matrix, whitening transform, and source rows then depend only on
A,J and these fresh indices. Gaussian reconstruction coefficients are
generated from a covariance depending only on those same variables.
Therefore the canonical outgoing prefix is a randomized function of
(A,J,H), with fresh randomness conditionally independent of Y. The
published future-entropy lemma applies unchanged: there is no additional
entropy charge for the importance-sampled indices or the whitening map.

The scalar comparison coupling can depend on x and correlate the new
Gaussian coefficients with the discarded original block. It must preserve
the canonical joint marginal of (new prefix,Y), rather than assert fresh
independence inside that comparison coupling. The existing disintegration
invariant then preserves the complete original network marginal Q. This
is the same distinction already made explicitly in the published proof.

Abort on failure of the Gram event is also legitimate: its event depends
only on A,J and fresh source indices, and so introduces no new revelation
of future weights. Abort on active-rank overflow is part of the finite
message J and must remain included in its entropy count.

## Finite coefficient bounds

Keeping the existing active-row clipping is compatible with this sharper
error calculation. The average clipped active energy is at most the
unclipped energy, so the reconstruction bound still uses its expectation,
not the worst-row clipping threshold.

If active rows have norm at most B_H, their sampled mean coefficients
have magnitude at most B_H sqrt(k)/m. Since the diagonal variances of xi
are at most one, the existing coordinatewise Gaussian clipping argument
also applies. The weights sqrt(a_j) are at most sqrt(2), giving at most
an extra factor two in the old mean-square clipping bound; for example,
`6m exp(-B_G^2/4)` is a safe analogue of the earlier bound. Choosing the
Gaussian clipping threshold with `log(6m/e)` covers this.

## Readout sampling

The old uniform-in-x Hoeffding bound for the final readout is unnecessary
when the final theorem only needs pointwise couplings with a common law.
Conditional on the virtual prefix and original readout, fresh uniform
source indices give readout estimator variance at most E_v/m. The original
readout marginal remains Q under the canonical construction, so the
published entropy-moment estimate bounds its unconditional expectation
by O(K)/m.

One can retain the existing readout-energy truncation and coefficient
clipping to obtain bounded final parameters. The deterministic clipping
bias and pointwise sampling error should then be included separately in
the final noise budget. This replacement is needed to avoid having the
old readout Hoeffding sample size dominate the improved internal sampler.

## Review of the assembled sextic theorem

The subsequently completed draft
`../energy/sextic-compressor.md` has now also been reviewed. Its explicit
budget and theorem assembly pass the checks below. It uses the previously
published entropy-of-unprocessed-weights lemma, active-direction selection,
Gaussian target cylinder, and statistical bridge. Those reused hypotheses
and conventions match the new proof. The theorem is not Lean formalized.

1. **Rank and entropy budgets.** The active rank is capped at
   `q=ceil(2K/(e eta))`, while reconstruction sampling uses the actual rank
   `ell`, including its rank-zero branch. The finite query message costs
   `D0=[(d+1)q+2]log 2`. Taking `N0 >= LD0/K` keeps the original future
   relative entropy at most `2NK/t^2` in the large-width case. The active
   energy expectation is consequently at most `V=8K+2q` as required.
2. **Reconstruction width.** The term `10000(V+q+1)/e` makes the expected
   reconstruction error at most `e/8` using the reviewed local lemma.
   The term `64(q+1)log(4(q+1)/eta)` makes the Gram failure probability
   at most `eta`, uniformly over actual ranks `ell <= q`.
3. **Clipping.** The stated active-row threshold costs at most `e` expected
   squared RMS activation error. The weighted Gaussian clipping estimate
   is bounded by `6m exp(-BG^2/4) <= e`. These operations are performed on
   every virtual row before any later selection, so future-dependent
   selection cannot circumvent the coefficient bound. Combining the four
   stage errors by the squared-sum inequality gives less than `20e`.
4. **Final readout importance sampling.** This final version samples with
   probabilities `|v_i|/sum|v|`. Conditional on the virtual prefix and
   original readout, the sampled contributions lie in
   `[-sqrt(K0),sqrt(K0)]` after the readout-energy truncation. Hoeffding at
   tolerance `r/16` gives exponent `-mr^2/(512K0)`. The third width term
   makes a union bound over all Boolean inputs cost at most `eta`. The
   zero-readout case is handled explicitly. No future weights remain at
   this step, so readout-dependent sampling incurs no further entropy
   bookkeeping obligation.
5. **Total disturbances.** The expected hidden squared disturbance off
   aborts is at most `20Le`. Markov at hidden norm `r/4` costs at most
   `320Le/r^2 = .32 alpha`. Rank, Gram, and readout aborts cost at most
   `3L eta = .03 alpha`. On the good event, the final readout error is
   at most `r/16`, giving total disturbance norm at most
   `sqrt(17)r/16 < r/2`. Thus the complete exceptional probability is
   strictly less than `alpha`.
6. **Small widths and finite code.** The original entropy-moment estimate
   bounds all physical weights by `Bsmall` outside probability
   `alpha/4`. Large-width candidates have the stated coefficient bound.
   Padding to `M=N0` and using the proposed grid mesh changes output by
   at most `r/8`. The grid cardinality bound and its independence of
   learner width, scale, and training sample are valid.
7. **Actual posterior theorem.** Readout truncation gives discarded mass
   `beta=epsilon/4` and retained KL at most `N(D_*+1)/t^2`. The common
   robustness radius in the draft is valid on that retained law.
   Taking `alpha=epsilon/12` and the stated sample budget leaves risk
   `beta+3alpha+8(log|H|+log(1/delta))/n <= epsilon` on the single
   finite-class generalization event. This event applies simultaneously
   to every width `N >= C` and every `0<t<=1`.
8. **Teacher-width exponent.** At fixed remaining parameters,
   `D_*`, `K`, and `r^-2` are `O(C log^2 C)`. Therefore
   `q=O(C^2 log^4 C)`, `m,M=O(C^3 log^6 C)`, and the grid coefficient
   bound is at most `O(C^3 log^6 C)`. The dense parameter count supplies
   `C^6 log^12 C`, and the precision logarithm adds one further
   logarithm. The advertised `O(C^6 log^13 C)` sufficient sample bound
   follows.

**Conclusion:** the assembled proof supports the claimed sextic bound,
up to the displayed logarithms, under the unchanged original robustness
restriction and throughout the finite-scale regime `gamma >= 1`. This
conclusion is an independent mathematical audit, not machine verification.

## Final standalone TeX source audit

The final standalone sources in `../energy/paper/` were compared against
the reviewed derivation and checked directly:

- `paper.tex`: title, abstract, introduction, and verification/scope claims;
- `learning-theorem.tex`: model, exact posterior conventions, main
  quantifiers, target cylinder, and statistical proof;
- `compression-proof.tex`: full new lemma, unchanged entropy arguments,
  explicit construction, failure budget, coupling invariant, and coding;
- `explicit-budget.tex`: sample formula, width exponent, and universal
  polynomial envelope.

All four sources pass this audit. The standalone presentation preserves
the reviewed theorem's scope, including finite mean-field scaling,
simultaneity over learner width and scale, and the distinction from
arbitrary analog teacher networks. The text explicitly says that the new
rate is not certified by the earlier Lean proof.

The new degree-46 envelope also checks independently. For
`S=2+d+L+C+c+c^-1+epsilon^-1+log(1/delta)`, the respective powers are:

    D_*, K, B_v: 3
    r^-2: 6
    e^-1, eta^-1: 8, 2
    q, V: 13
    D0: 14
    m, M: 21
    P: 43
    Bsmall^2, B: 44, 22

The target gain squared is `O(log^2 S)=O(S)`, giving the stated target
cost exponent. The maximum in the sample-width budget contributes powers
21, 14, and 12 respectively. The small-width cutoff is no larger than
the stated power 21, even bounding its denominator only by `K>=1`.
The grid precision contributes `O(S log S)` bits per parameter. Thus
`J=O(S^44 log S)`, the sample bound is `O(S^45 log S)`, and the conservative
`O(S^46)` envelope follows.

No undefined references, overfull boxes, or warning lines were found in
the supplied build logs. This log inspection is supplementary; the
mathematical audit concerns the source text rather than compilation alone.

SHA-256 hashes of the reviewed final sources:

```
e78c55d4791c82d4a10a3a0c7543e8a77a6603594035320696aaed825f3b991c  paper.tex
4445004ebb54fde621d74c26c1c6c67d420047fcd34203cb3236e0f30a76d354  explicit-budget.tex
c024ca45275c025337788534f5a5c1892a43a05e6e03436b799d08dcf10c4c07  compression-proof.tex
3d2f64524c0bf0f5368559443cfe526e57853c564c2efab2607a37d892ac6c13  learning-theorem.tex
```
