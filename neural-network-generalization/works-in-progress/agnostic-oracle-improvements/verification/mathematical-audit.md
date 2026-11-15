# Independent audit of the uploaded tempered-likelihood theorem

Audited 2026-11-14 against repository HEAD `9da5020d04cb60a5fe0caf6da96fb162b956f91d`. This is a mathematical review, not Lean verification.

## Verdict

The positive result in the uploaded `tempered-learner-short.pdf` follows from the actual proof in `research-notes/B-tempered-likelihood.md`. I found no substantive gap in its core proof. I checked the network cloning estimate, the finite-dimensional Laplace argument, the clip-mixture representation, the width-uniform Rademacher argument, the uniform-deviation event, the oracle comparison, and the growing-width-and-weight corollary directly, rather than relying on the earlier review reports.

There is a provenance issue: the PDF cites `statement/tempered-learner.pdf` and its Corollary 3, but the entire `statement/` directory is absent from the current repository main. The unspecified polynomial bounds can nevertheless be obtained directly as follows.

## An explicit safe polynomial prefactor

Set H=L−1, s=log(1/δ),

E*=d(d+1) B² + 2H m²B²,

P_a=2(E*+1)+16(d+1)+8H+[4+(mB+1)²](1+s).

Then the uploaded part (a) is true with P_a in place of `poly(...)`. Indeed, (2/H)^(H/2)≤sqrt(2), log(n+1)≥log 2, and the confidence term has n^(−1/2)≤n^(−1/(L+1)). The constants above safely dominate the factors needed to put all terms over sqrt(log(n+1)).

For part (b), set

P_b=2d(d+1)+4L+16(d+1)+8H+8(1+s).

This safely dominates the coefficient Xi_n in B Corollary 8.1 after factoring out sqrt(log(n+1)). Neither polynomial depends on α. For H≥2 and 0<α<1/(4H), the exponent β=(1−4Hα)/(H+2) is positive and θ=(1+8α)/(H+2)<1/H. The extra comparator Hoeffding term is dominated because α≤H/16; the latter follows from α<1/(4H) for H≥2.

## Precise scope

- Data are IID from an arbitrary Borel law on a compact domain X⊂[−1,1]^d and labels in [−1,1]. The positive Rademacher proof actually does not use the input bound, but the stated assumptions suffice.
- The comparison network has the same fixed depth and tanh activation. All its weights are bounded in magnitude by B. Its risk on the right is the risk of its **unclipped** real output.
- The learner predicts with clipped output. The posterior-mean claim concerns E[clip z], not clip(E[z]). The latter has a separate weaker bound in B Theorem 6.4.
- Internal biases are absent except for a constant input coordinate. A standard biased network can be implemented with one additional constant unit per layer and a constant factor in the weight bound (B Remark 8.2).
- The probability event really is one event for **all** learner widths N≥m (or all N≥n^α). It comes from the countable union of energy-bounded classes across widths and the single fixed competitor function. There is no width union-bound penalty.
- The strong-prior limit is taken for each **fixed** N, n, and sample. The convergence scale σ0 can depend on N. The theorem does not establish a simultaneous N→∞, σ→0 limit or uniform convergence in N.
- In part (b), the population minimizer over the compact bounded parameter class exists and is chosen before drawing the sample. Applying a one-competitor Hoeffding event to it is legitimate. The theorem is an oracle bound and does not require a simultaneous Hoeffding bound for all competitors.
- The error prefactor is polynomial in depth, but the sample-size exponent depends on depth. The claim is not a polynomial-depth sample complexity theorem. Even the compressed rate requires n approximately ε^{−(L+1)}, ignoring the logarithm and the prefactor.
- A zero-additive-error finite-n oracle, as literally suggested in the original research question, is not established. The additive approximation/statistical term is essential in general.

## Why the unusual Rademacher step is valid

The first layer is bounded tanh and is represented as a convex mixture of affine threshold functions; their growth function is at most (n+1)^(d+1). Subsequent normalized tanh layers are mixtures of symmetric clipping maps with nonnegative weights totaling one. Taking convex hulls and one clipping parameter per layer adds at most 1/(2 sqrt n) to Rademacher complexity per hidden layer. The path-norm bound is

P(w)≤sqrt(N)||v||₂ ∏_{ℓ=2}^H ||W^ℓ||F ≤ (κ/H)^(H/2).

The first-layer energy is not charged in that product, since the first-layer feature class has already been controlled by VC dimension. This yields Rad(Z_K)≤(K/H)^(H/2)[sqrt(2(d+1)log(n+1))+(H−1)/2]/sqrt n. The all-width bound is not an accidental cancellation of N in a fixed-width entropy estimate.

## Supplemental general obstruction: weight-free oracle claims for fixed proper continuous priors

Fix any finite sample size n, any finite inverse temperature η>0, and any proper prior on continuous real predictors. Use clipped outputs both for evaluation and the squared-loss likelihood. Keep the domain fixed at X=[−1,1] and the prior fixed independently of a and of the sample. Let D_a be uniform on (−a,−1),(a,+1). A width-one tanh network with sufficiently large weights fits D_a exactly.

For every sample, the posterior density relative to its prior is at most exp(4ηn), since every training loss is in [0,4]. By continuity and dominated convergence,

E_prior |clip f(a)−clip f(−a)|→0 as a↓0.

Hence the posterior expectation of this difference tends to zero uniformly over samples. For any clipped predictor h, writing Δ=h(a)−h(−a),

R_Da(h) = [(h(a)−1)²+(h(−a)+1)²]/2 ≥ (1−Δ/2)² ≥ 1−|Δ|.

Therefore the clipped Gibbs risk tends to at least 1, and so does the risk of the mean of clipped posterior outputs. This prevents a distribution-uniform, width-only oracle with vanishing excess for any fixed proper continuous-function prior of this form, not just the Gaussian strong-prior learner.

For a Gaussian likelihood on **unclipped** output the same conclusion holds: each sample is one of finitely many ± label patterns. For each pattern, its likelihood converges pointwise as a↓0, is bounded by one, and has a strictly positive limiting normalizer. Apply dominated convergence to the bounded clipped output difference times that likelihood. Finitely many patterns give uniformity over samples. A temperature depending on n remains covered at each fixed n. This argument concerns proper finite-temperature posteriors; it does not by itself exchange an additional zero-temperature or strong-prior limit.


## Independent audit of the improved absorption theorem

I reviewed `/workspace/agnostic-next/capacity/absorption-oracle.md` after completing the preceding audit. Its clipped theorem and all displayed constants pass independent mathematical review. Specifically:

- With r=H/2≥1, a=8(2/H)^r D_n/sqrt(n), and λ=a^(1/r), exact minimizers have energy q≤1/λ. Therefore a q^r≤a λ^(1−r)q=λq. This is the central valid cancellation.
- The dyadic energy event is shared by all widths because each imported energy-class bound is. J=max(0,ceil(log₂(1/λ))) also handles λ>1 correctly: all relevant energies are then below the first threshold 1.
- The posterior extension uses exact minimizers and bounded continuous risk; it does not incorrectly assert the absorption inequality for a fixed positive near-minimizer tolerance.
- The fixed-teacher Bernstein correction is valid with its safe 2/3 linear coefficient. The growing-class population minimizer has risk≤1 because the class contains zero.
- For H=1, the Young inequality sup_q≥0 [a sqrt(q)−λq]=a²/(4λ) is exact, and λ=a/[2sqrt(E0+1)] gives penalty sum at most a sqrt(E0+1).
- The rates n^(−1/H) for H≥2, and the known-energy one-hidden-layer rate n^(−1/2), follow. The stronger growing-class rate is 1/H−4α for H≥2 and 1/2−2α for H=1 with energy-cap tuning. These are substantial improvements using the same Gaussian prior family and raw squared-loss likelihood.
- The optional removal of the first-layer log n by VC entropy/chaining is reasonable but is not proved by the self-contained displayed argument; a precise cited entropy theorem is needed if included as a theorem.

No substantive gap was found in this improved result.

## Optional additional result: raw-output absorption

The same reasoning also improves the raw, unclipped predictors, allowing the usual posterior mean E[z] and its clip. Here is a fully specified version to be independently checked by the capacity agent.

Let H≥1, L=H+1, r=H/2, p=L/2, and J=ceil(log₂ n). Write

t=sqrt(log(2(J+1)/δ)/(2n)),
A=4(sqrt(2)+1)(2/H)^r D_n/sqrt(n),
B=(sqrt(2)+1)²t,
λ=max{(2A)^(1/p), 2B, 1/n},
e=8H^(−r)D_n/sqrt(n)+4t.

Apply B Lemma 5.3(b) to thresholds 2^j for j=0,...,J, with each failure probability δ/[2(J+1)]. Exact minimizers obey q≤1/λ≤n. For q≤1, the raw population-minus-empirical loss is at most e. For q>1, choose K=2^j<2q. Then sqrt(K)+1≤(sqrt(2)+1)sqrt(q), so the deviation is at most A q^p+Bq. Since p≥1,

A q^p+Bq≤[A λ^(1−p)+B]q≤λq.

Consequently every exact minimizer satisfies

R(z_w)≤Rhat(g)+λE+e,

simultaneously at every N≥m. Concentrate the one fixed comparator as before, and apply B Corollary 3.2 to continuous raw risk R(z_w)≤2F+2. This proves the bound for the limiting raw Gibbs risk, raw posterior-mean risk, and its clipped version. The rate at fixed depth is O(E n^(−1/L)) up to logarithms, plus comparator concentration. It improves the original raw-output rate n^(−1/(L+2)), though it is weaker than the clipped-prediction exponent n^(−1/(L−1)).


## Independent audit of the smooth-loss raw-output improvement

I critically checked `/workspace/agnostic-next/fast/unclipped-smooth-oracle.md`, including its external dependency, by opening the actual 21-page October 29, 2010 version of Srebro–Sridharan–Tewari, *Smoothness, Low-Noise and Fast Rates*, at https://www.cs.cornell.edu/~sridharan/smoothness.pdf. The relevant statement is Theorem 1, page 4 (PDF index 3); the worst-case Rademacher definition is on page 3 (PDF index 2).

Verdict: the improvement is valid as a theorem relying on this published smooth-loss result. It strengthens the preceding optional elementary raw-output exponent from 1/L to 1/(L−1), matching the clipped result up to extra logarithms.

Checks performed:

1. SST requires nonnegative smooth loss on the real line, and bounded loss on the evaluated hypothesis class. It does not require the square loss to be globally bounded on all real inputs. For energy class Z_K, |z|≤sqrt(K) and |y|≤1 give b_K=(sqrt(K)+1)²; the raw square loss is globally nonnegative and 2-smooth. Thus the hypotheses match exactly.
2. SST uses the supremum over deterministic input samples of the Rademacher expectation with an absolute value. B's estimate holds for every deterministic sample, and Z_K is symmetric under reversal of readout signs, so the absolute-value and non-absolute suprema coincide.
3. SST Theorem 1 is uniform over all hypotheses, not merely a theorem about unregularized ERM. It therefore applies to the penalized empirical minimizers. Such minimizers have empirical raw risk≤1, because their penalized objective is at most that of zero.
4. The displayed smooth-loss formula in the scratch proof is exactly the theorem's first (uniform) assertion. Replacing log n by log(2n) only increases its right side. The published theorem supplies a universal numerical constant below 10^5; taking C=10^5 makes the use fully explicit.
5. The dyadic peeling event uses finitely many width-uniform energy classes. The resulting event is shared by all learner widths. Measurability follows as in B by taking rational parameters at all integer widths.
6. For the high-energy case, the four terms are correctly bounded by fractions of λκ plus 8C²q/λ: 1/8 from the linear Rad term, at most 1/64 from squared Rad, 1/4 from the confidence-linear term, and 1/4 plus the residual from Young's inequality. Their sum is less than λκ. The small-energy residual and H=1 Young inequality are also correct.
7. The comparator Bernstein bound with linear coefficient 1/3 is valid if obtained from the centered bounded-variable sub-gamma mgf. In detail, log E exp(t(Z−EZ))≤v t²/[2(1−bt/3)] implies deviation sqrt(2v s)+bs/3. The weaker familiar rational-tail inversion may instead yield 2bs/3; either conservative choice is valid.
8. Raw risk is continuous in network parameters and at most 2κ+2. Consequently the existing energy-weighted Laplace tail lemma supplies uniform integrability at each fixed width. Concentration on exact minimizers transfers the raw-risk bound to the limiting raw Gibbs risk. Jensen/Tonelli then give the ordinary posterior-mean bound and clipping can only improve it. There is no unsupported uniform-in-width strong-prior limit.

An optional simplification: λ≤1 is unnecessary for validity. If λ>1, minimizer energy is below 1, so the first dyadic class alone controls every minimizer. The theorem can be stated for all n≥2, with rates understood asymptotically.

This review verifies the application and the subsequent proof. It does not re-prove SST's local-Rademacher theorem or imply Lean verification of the new result.


## Unit-sphere form of the weight-bound obstruction

The steep-pair impossibility is not removed by normalizing every input to norm one. Keep X=S¹⊂R² and place probability 1/2 at each labeled point

x_±(a)=(±a,sqrt(1−a²)),  y_±=±1.

As a↓0 the two inputs converge to the same point (0,1). The continuity and dominated-convergence proof above is unchanged. For one hidden layer, the width-one target g_a(x)=tanh(x₁/a)/tanh(1) fits both labels exactly. For any fixed H≥1 hidden layers, use first-layer weight 1/a on x₁, scalar internal weights 1, and readout 1/tanh^{∘H}(1). This remains a width-one network and fits the same two labels exactly. Therefore even a fixed compact unit-sphere domain admits the obstruction; bounding the input norm does not replace teacher weight or slope control.


## Independent audit of the finite-scale Gaussian extension, gamma≥2

I reviewed `/workspace/agnostic-next/fast/finite-scale-gamma-two.md` in full. Verdict: valid, with the stated bounded-input assumption and clipped prediction convention. There is no strong-prior limit in this theorem.

The following checks cover its potentially delicate steps:

- Global deviation: for 1<κ≤8/λ, the dyadic capacity term is at most A 2^p (8/λ)^(p−1)κ. It is ≤(λ/2)κ exactly when λ^p≥2^(4p−2)A. For κ>8/λ the clipped loss cap 4 proves the same inequality immediately. Thus the all-energy assertion is valid, not an unjustified restriction to posterior typical energy.
- Gaussian entropy: N^γ κ is χ² with P=N(d+2)+(H−1)N² coordinates under the prior. Its mgf at 1/4 is 2^(P/2), giving KL(Q||μ)≥N^γ E_Qκ/4−(P/2)log2. The posterior has finite KL and energy moments because its density is bounded relative to the Gaussian prior and its expected likelihood loss is finite.
- Variational cancellation: multiplying the entropy lower bound by 2λN^(−γ) supplies exactly (λ/2)E_Πκ−λ(P/N^γ)log2. The finite posterior's Gibbs variational principle then gives equation F4 with the stated constants and direction.
- Gaussian comparison: Q=N(w_*,r0²Σ) has exact KL N^γκ(w_*)/2+P(r0²−1−2log r0)/2. For r0≤1 this is bounded by N^γE/2+P log(1/r0).
- Cloning and perturbations: each deterministic cloned internal matrix has operator norm at most sqrt(2)mB, and sqrt(N)||v_*||₂ has the same bound. Each Gaussian noise block is independent of all preceding random activations. Conditional second moments therefore give the hidden noise RMS r0 N^((1−γ)/2) and readout noise RMS r0 N^(−γ/2). Correlations among cloned teacher units do not invalidate either calculation. The deterministic teacher matrix acting on the preceding error is bounded using its operator norm, not an independence assumption.
- First-layer noise uses ||(1,x)||²/d≤2, which explains the bounded-input cube requirement and the initial sqrt(2) factor. It should not be silently replaced by the arbitrary-input-law assumption of the strong-prior section.
- The displayed K_g is the exact solution of the upper-bound recurrence. Taking r0=λ/[4(U+1)K_g] gives output RMS at most ρ=λ/[4(U+1)] and comparison empirical risk at most Rhat(g)+λ/2+λ²/[16(U+1)²]≤Rhat(g)+λ for 0<λ≤1.
- P/N^γ≤d+H+1 holds uniformly in N≥1 and γ≥2. The comparison distribution varies with N and γ, but its risk and KL estimates hold deterministically for every sample. Hence the one capacity event and one fixed-teacher concentration event are simultaneously valid for every N≥m and every γ≥2.

The final result is a coefficient-one oracle for the finite posterior's clipped Gibbs risk and mean of clipped outputs, with the same n^(−1/H) exponent up to logarithms. It does not automatically cover raw posterior means, nor γ in [1,2). Its proof is fully elementary relative to the energy-class bound already re-proved in the Gaussian section; it needs no teacher-tube lemma or width-dependent small-temperature cutoff.


The matching `fast/finite-section.tex` was subsequently checked end to end against the Markdown proof. No transcription error was found. Its additional H=1 paragraph is also valid: the shell estimate A sqrt(2κ)≤(λ/2)κ+A²/λ is exact by Young's inequality, so the rest of the finite-posterior proof carries through, and λ=max{A,1/n} gives the claimed fixed-teacher n^(−1/2) rate up to logarithms. The added normalized-clone operator-norm explanation is correct.


### Stronger scaling range at one hidden layer

A further independent check confirms that the finite-scale H=1 result extends to all γ≥1, simultaneously in γ and N. At H=1 the parameter count is P_N=(d+2)N, so P_N/N^γ≤d+2 for γ≥1. The first-layer perturbation factor N^((1−γ)/2) and readout factor N^(−γ/2) are both at most one in this range. All remaining Gaussian entropy, KL, clipping, and cloning steps are independent of this threshold. Thus γ≥2 is needed by the current argument only when there are at least two hidden layers.
