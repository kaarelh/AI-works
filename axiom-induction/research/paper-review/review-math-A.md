# Mathematical review A: sections model, ident, sound and their appendices

Reviewer scope: `paper/sections/{model,app-model,ident,app-ident,sound,app-sound}.tex`, checked line by line against `research/tracks/model/notes-final.md` (and its `referee.md`, `checks/`, `referee_code/`), `research/tracks/experiments/notes-final.md` (Props X2–X8, X13, E2, E4–E6, E8), `research/tracks/universal/notes-final.md` (S_nc,β, Prop U6, Lemma U7), `research/tracks/pa/notes-final.md` (Def 0.3, Prop 2.3, §5.4), `code/results/e{5,6,8}_*.md`, and the cited parts of `inferential-learning` (IL Lemma C.4, Prop C.5, Thms 4.14–4.16, 10.9). I did not edit the paper and ran no git command that changes state. Independent code is in `research/paper-review/scratch/` (scripts `a1`–`a5`, each seeded, each with its `.out`).

Severity follows the brief exactly: **fatal** = a false or unsupported mathematical claim, or a claim stronger than the sources; **major** = a missing hypothesis, a wrong number, an inconsistency, misleading framing, or a step a reader cannot follow; **minor** = local wording or formatting.

## 1. Verdict

The mathematical core of the three sections is sound. Every main theorem I re-derived holds as stated:

* Doob/generator-class consistency (Thm `ident:doob`) and its corollaries;
* the rates of Prop `ident:rates`;
* the separation, split and identification results (Props `ident:sep`, `ident:splits`; Thm `ident:limit`(a), (b));
* the Occam expansions (Props `ident:splitlzero`, `ident:splitlone`(a)–(c));
* the size principle (Lemma `model:size`, Prop `model:whichsize`);
* all three soundness theorems (Thms `sound:fixed`, `sound:avg`, `sound:shrink`) with the regret lemma `sound:regret`;
* the trichotomy results (Props `sound:laws`, `sound:belief`, `sound:bracket`, `sound:fiftyfifty`).

The Dirichlet/fixed-weight split is respected in every theorem statement. All numbers I recomputed agree with the paper except the misspecified prediction row of Table `tab:ident:c2` (issue 9).

The problems are at the edges, in three groups:

* **Two fatal items, both local.**
  * A remark claims a theorem covers a verifier that it does not cover. The E4 constant-threshold verifier is said to be "covered by Thm `sound:shrink`" (issue 1).
  * A definition asserts a false identity between pa's L_ε at ε = 1 and Hänni's S_nc (issue 2).

  Neither feeds a main result. Each needs a one-sentence fix.
* **Seven major items.** Four are missing hypotheses:
  * the spare-slot rate of Prop `ident:spare`(c) needs finite χ²; without it the rate is wrong, as shown by a counterexample computed here (issue 4);
  * the vacuity remark `sound:vacuous` needs a likelihood affine in w (issue 5);
  * the tightness remark `sound:tight` is false under L1 at finite d (issue 6);
  * the "Thm `ident:doob` covers the experiments" remark does not meet the theorem's hypotheses (issue 7).

  One is an inconsistent counterexample: the numbers quoted in Remark `model:graded` violate that remark's own Kraft bound (issue 3). One is a pool-version gap: Remark `sound:lumps` uses Thm `sound:shrink` on data-dependent pools, but no pool version of that theorem is stated (issue 8). One is the wrong prediction row and caption of Table `tab:ident:c2` (issue 9).
* **Minor items.** Local wording, scope and transparency (issues 10–27).

Statuses (proved / computed / sketch / conjecture) are deserved throughout, with three exceptions:
* Prop `ident:spare`(c), whose statement needs an extra hypothesis (issue 4);
* Remark `sound:indep` and the "slow rejection" sentence of Remark `ident:sparetotal`, both marked proved although they rest on the sketch (b) of Prop `ident:spare` (issues 15, 25);
* Remark `sound:tight`, marked proved although its L1 clause is false at finite d (issue 6).

## 2. What was checked, and how

### 2.1 Section model and its appendix

* **Kraft, prior, time factor** (Lemma `model:kraft`, Remark `model:priors`): re-derived.
  * The γ(k+1) change for the empty theory is harmless.
  * The experiments' set code sums to at most 1, by the ordered-tuple argument.
* **Instantiation grammar** (Def `model:grammar`, Lemma `model:grammar`): re-derived (a)–(d).
  * Base case: N_0 = 1 ≤ Λh_min.
  * Step: x = ζΛH ≤ 1/(Λbh_max) ≤ ½; then e^x ≤ 1+x+x²; then 1 + ζΛ²b²h²_max ≤ 2 ≤ Λ(1−ρ)h(j).
  * Remark `model:subcrit`: the telescoping product 2(k+1)/(k+2) and 6.1·10⁻⁹² at k = 2000 are correct. The domination counterexample (mean ≥ 1.35) is correct.
  * Example `model:qa`: the exact mean body size from a formula root at k = 0 is 14.667 (computed here). The paper's empirical 14.62 ± 0.04 is consistent with it (`a1`).
* **Likelihoods.**
  * Lemma `model:dirsum` (Dirichlet moments, KT predictive rule): correct.
  * Lemma `model:lone`(a)–(c): correct. GW mean 1/(1−m); the extinction root q = 0.75 at (0.4, 0.3) is recomputed in `a1`. The ⊆/⊇ argument needs parameters admissible, as stated.
  * Lemma `model:lsig`: correct.
  * Remark `model:sel`: correct (L_selc is normalised: Σ_i w_i Σ_{s∈S} a_i(s)/c_i = 1).
* **Universal track's chain factors** (Table `tab:model:calculi`, appendix): re-derived by solving the chain fixed-point equations.
  * C_open gives c(1−ρ)/(1+c) and (1−ρ)/(1+gρ).
  * C_min gives c and c/(1+c).
* **Size principle** (Lemma `model:size`, Prop `model:whichsize`): re-derived.
  * KL = H(Q) = 3.8943 nats for the untruncated grammar (`a1`).
  * Note that the truncated KL in c1 is 2.618, not 3.894 (issue 18).
  * Prop (b): the monotonicities of S_nc, S_prove and S_g hold under the stated hypotheses.
  * Prop (c) needs the weight-scaling convention (issue 14).
* **Prop `model:compute`, Prop `model:max`**: correct. The T = ∅ caveat is issue 27.
* **Remark `model:graded`**:
  * The normalisation argument is correct.
  * The quoted counterexample is not in the remark's setting (issue 3).
  * The refutation itself survives in the proper setting, by a two-line prefix-code bound (`a1`).
* **Definition `model:scores`**: the L_ε identification is false (issue 2). The S_nc,β identification needs β > 1 (issue 26).

### 2.2 Section ident and its appendix

* **Thm `ident:doob`.** Each of Steps 1–4 (Lévy, SLLN over countably many s, the countable decomposition, transfer via M ≥ π(T*)P^∞) is correct. So is the new TV identity Σ|π_n − q| = 2(1 − π_n(C*)).
* **Cor `ident:prior`, Cor `ident:deductive`, Prop `ident:rates`(a)–(c), Thm `ident:predded`**: correct.
  * The negative part of the log-ratio is integrable.
  * The Bhattacharyya/Markov bound holds, with C < ∞ for λ ≥ 2.
  * ρ_T ≥ (1−ε)^{1/2} for spares.
* **Prop `ident:sep`**:
  * Correct. No logical axiom has root ¬, and Z_{T2} ≥ 1 − α_r.
  * The proved region and the boundary setting are recomputed in `a1`.
  * The c6 ranges (P_{T1}(b) 0.16–0.35, P_{T2}(b) 0.007–0.04, TV 0.16–0.35) match `c6_L1_ident.out`.
* **Prop `ident:splits`(a)–(c)**: correct. The τ_r are in DT°, the instance sets are disjoint, and Q(θ) = p_r Q_{τ_r}(s) under L0, L1 and L2.
* **Thm `ident:limit`**:
  * (a): correct.
  * (b): correct. The support functional takes countably many values, and Lévy's theorem is applied per A_ν; the transfer to Lebesgue-a.e. w* is valid.
  * (b′): a sketch, as labelled.
  * Remark `ident:exact`: correct for likelihoods affine in w.
* **Prop `ident:gold`**:
  * (a)–(c) correct; conditioning on a positive-probability prefix is legitimate.
  * The E5 numbers check: L_5 gains 0.678 bits per datum against a prior difference of 72.3 bits.
* **Prop `ident:splitlzero`**:
  * I re-derived the Stirling expansion and c_{4,1/2} = 0.4674.
  * The well-specified predictions in Table `tab:ident:c2` are correct.
  * The misspecified prediction row omits +(K−1)/2 (issue 9). An independent Monte Carlo with 20 000 runs agrees with the corrected values, not the printed ones.
* **Prop `ident:splitlone`(a)–(c)**: correct, including the continuity lemma.
  * Jensen gives μ_{p′} ≥ μ_r·ρ^{E[L|x]}.
  * Z_{p′} ≤ E_r[ρ′^L; valid].
  * Dominated convergence applies via the exponential moment of the GW size.
  * The lower bound uses Jensen on U_γ and the SLLN with E Y ≥ −γ.
* **Prop `ident:spare`**:
  * (a) and (d1) re-derived exactly. The limits 0.1050, 0, −0.4055 and pa's 19.03/19.82 bits are recomputed in `a1`; the exact values are 19.031 and 19.821.
  * (c) is false without a finite-information hypothesis (issue 4, counterexample `a4`).
  * The case "in the span but not in the hull" is uncovered (issue 16).
* **Thm `ident:kl`, Example `ident:weaker`, Lemma `ident:zerosum` (all five cases), Example `ident:escape`, Example `ident:lonedq`**:
  * The proofs are correct.
  * The c16 per-size log-likelihoods and the 5-of-8 / 16-of-16 counts match `c16_L1_robust.out`.
  * The odds drift is 2.854 nats per datum.
* **Prop `ident:proofs`**: correct. Wording issue 20.
* **Remark `ident:nearmiss`**: correct, but the "size principle holds" clause is vacuous (issue 11).

### 2.3 Section sound and its appendix

* **Thm `sound:fixed`**: Steps 1–4 correct. The event G is data-only, so a prover that foresees the data is covered, as in IL Thm 4.15(b).
* **Remark `sound:tight`**: correct under L0. The construction attains (1−u)^{t*} exactly, and the inequalities [(1−u)/θ, 1/θ) are as in IL Prop C.5. The L1 clause fails at finite d (issue 6).
* **Remark `sound:hyp`**: correct. The truncation counterexample 0.09 against 0.90 is right; issue 23 concerns scope.
* **Prop `sound:misspec`, Prop `sound:cautious`**:
  * Correct.
  * The strictness example {c, a∧b} against {c, b∧a} is right.
  * In (c) the memoriser argument is right.
* **Prop `sound:complete`**: correct for L0 (any d), for L1 (d = ∞) and for Dirichlet weights at a.e. w*.
* **Lemma `sound:regret`**:
  * (a), (b) and (d) re-derived. The simplex volume η^{K−1}/(K−1)! and the bound (1+1/n)^{−n} ≥ e^{−1} are right.
  * Checked by exhaustive minimisation over count vectors (`a3`).
  * (b) holds with margin ≥ 1 nat in every case tried: α ∈ {0.2, 0.3, 0.5, 0.7, 1}, K ≤ 4.
  * (d) is attained in some cases.
  * (a) holds on 200 random overlapping-component cases × 21 weight vectors.
  * The slopes are −0.499 (α = ½), −0.500 (α = 0.3) and −0.995 (α = 1), matching −(K−1)max(½, α).
* **Thms `sound:avg` and `sound:shrink`**:
  * Correct. M/P^Dir_{T*} is a supermartingale under P^Dir_{T*}, and M/P_{T*,w*} is one under P_{T*,w*}.
  * The pathwise bound π_t(C) ≥ π(C)R(n,K)/Z′_n holds.
  * The pool-version proof is correct; issue 12 concerns its wording.
* **Example `sound:constant`** (Ex 4.9): reproduced independently (`a2`), checking every n ≤ 4·10⁵ with 300 runs per cell.

  | ε | fixed w*, constant δ | median first n | w* ∼ Beta(½,½), constant δ | shrinking δ_n |
  |---|---|---|---|---|
  | 10⁻⁵ | 0.967 | 8907 | 0.013 | 0 |
  | 10⁻⁶ | 1.000 | 7644 | 0.010 | 0 |

  * This agrees with Table `tab:sound:constant`; my horizon is shorter than the paper's 2·10⁶.
  * The countermodel for T* ⊬ q is right.
  * So is the identity P_{T′} = (1−ε)P_{T*,w*} on the data's support, and the mechanism with KT constant ½ln(π/2) = 0.226.
  * The deterministic crossing is near n = 6240, in line with the medians.
  * Issue 24 concerns the dependence on ε.
* **Trichotomy** (Props `sound:laws`, `sound:belief`, `sound:bracket`, `sound:fiftyfifty`; Examples `sound:renorm`, `sound:fifty`): all re-derived.
  * In the case analysis of Prop `sound:fiftyfifty`, D_T = −½ when both v, v′ are models and there are at least 3 models; D_T = 0 otherwise.
  * Checked independently in `a5` with an additivity test instead of LP: 0 violations of 2-, 3- and 4-monotonicity and 0 bracketing failures on 1500 random posteriors over 2 atoms and 300 over 3 atoms. The 50/50 criterion agrees in 1800 of 1800.
  * One addition would justify the word "coherent" in Hänni's question (3): attainment Bel(s) = min_P P(s) follows by choosing, for each T ⊬ s, a completion containing ¬s. This is optional.

## 3. Numbered issue list

### Fatal

**1. [fatal] sound.tex line 131 (after Remark `sound:e4`). E4's constant-threshold verifier is said to be covered by Thm `sound:shrink`.**
* *Problem.* The sentence reads: "In (C1) the verifier is sound for the data's actual generator (a two-schema theory with fixed weights, covered by Thm `sound:shrink`)". Thm `sound:shrink` covers only a verifier whose threshold shrinks, δ_n ≤ π(C^Dir_d)δ′R(n,K). The E4 verifier uses a constant threshold δ = 0.05w*.
* *Evidence.*
  * The source, experiments notes §6 finding 2, says: "Prop X8(c) applies to it (with its shrinking threshold)". The paper drops the qualifier, so it claims more than the source.
  * Example `sound:constant` in the same section shows that a constant threshold at fixed weights can fail.
  * Empirically, the queries first accepted in (C1) are instances of the mistake schema (0+0=1, 2+0=3), which the generator proves. That is an observation, not a theorem.
* *Fix.* Replace the parenthesis by: "a two-schema theory with fixed weights (0.9, 0.1); Thm `sound:shrink` would cover a verifier with its shrinking threshold, not the constant-threshold verifier used in E4, and the queries it accepted, 0+0=1 and 2+0=3, are theorems of that generator".

**2. [fatal] model.tex line 191 (Definition `model:scores`). The claimed identity between L_ε at ε = 1 and S_nc is false.**
* *Problem.* The definition says: "Track pa's L_ε is the noisy form: ε = 1 gives S_nc up to the factor μ₀(D), common to all theories". At ε = 1, L_ε(T; D) = μ₀(D)·Π_{d∈D}[T ⊬_k ¬d]. This is a per-datum test with a bounded refutation search. S_nc(T; D) = 1[T ∪ D consistent] is a joint test with unbounded consistency.
* *Evidence.* Two counterexamples:
  * With atoms d₁, d₂, T = {¬(d₁∧d₂)} and D = {d₁, d₂}: T ⊬ ¬d₁ and T ⊬ ¬d₂, so L_ε = μ₀(D) > 0, but S_nc = 0.
  * If T refutes a datum only by a derivation longer than k, again S_nc = 0 while L_ε > 0.

  The sentence is inherited from pa notes Def 0.3, so the source states it too, but it is false. No later result depends on it. Footnote § of Table `tab:model:likelihoods` and Prop `pa:nc` use only the per-datum form.
* *Fix.* "ε = 1 gives a per-datum, bounded-search relaxation of S_nc, Π_d[T ⊬_k ¬d], up to the factor μ₀(D); it equals S_nc only when joint consistency reduces to non-refutation of each datum within k steps." Also soften "ε → 0 moves towards S_prove" to "ε → 0 gives the generative likelihood P_T, whose support (L1, parameters admissible) is Th(T)".

### Major

**3. [major] model.tex line 216 (Remark `model:graded`) and app-model.tex line 135. The counterexample's numbers violate the remark's own Kraft bound.**
* *Problem.* The remark fixes a setting: ℓ_T(s) in bits of a prefix-free derivation code, κ ≥ 1, hence Z_T ≤ 1. It then quotes the referee's counterexample (κ = 1: P_T(b) = 0.032, P_{T′}(b) = 0.346; also κ = ½) as if computed in that setting. It was not. In `r6_stronger_theory.py`, ℓ is "least tree size (sum of formula sizes)" over a finite universe of 570 formulas. That is a symbol count, with ℓ_{T′}(b) = 1, and the normalisation runs over that universe.
* *Evidence.* Recomputed in `a1`:
  * The quoted values imply Z_{T′} = 2^{−1}/0.3456 = 1.447 > 1 at κ = 1, contradicting "Z_T ≤ 1" two sentences earlier.
  * At κ = ½ they imply Z = 4.10 and 4.74; κ = ½ is outside the stated κ ≥ 1 anyway.
  * The refutation itself is true in the stated setting. With γ(#lines), a 2-bit rule tag and 2 bits per symbol: ℓ_{T′}(b) = 5, ℓ_T(b) ≥ 23 (MP through a and a→b) and ℓ_T(a) = 5. Hence P_T(b) ≤ 2^{−23}/Z_T ≤ 2^{−18} while P_{T′}(b) ≥ 2^{−5}.
* *Fix.* Either label the r6 numbers as computed for "ℓ = symbol size, normalised over a finite universe (Z need not be ≤ 1)", or replace them by the prefix-code bound above. Drop the κ = ½ values.

**4. [major] ident.tex line 140 (Prop `ident:spare`(c)) and app-ident.tex line 160. The rate n^{−α_σ/2} needs a finite-information hypothesis.**
* *Problem.* Case (c) assumes only that inst(σ) ⊆ supp P* and that Q_σ is outside the span of T*'s components. The sketch expands the log-likelihood in u as −nIu²/2 + √n Zu. That needs I = E[(Q_σ/P* − 1)²] = χ²(Q_σ‖P*) < ∞. If χ² = ∞, E ln(1 + u(Y−1)) ≈ −cu^β with 1 < β < 2, and the rate becomes n^{−α_σ/β}.
* *Evidence.* Computed in `a4_spare_heavy.py` / `.out`, by exact quadrature in u with 60 runs per n and n = 10²…10⁶. P*(k) ∝ k^{−3}, Q_σ(k) ∝ k^{−γ} on k ≥ 1, one-component T*, α = ½.
  * γ = 2.6 (finite χ²): slope −0.269 over 10²–10⁶ and −0.228 over 10⁴–10⁶, consistent with the claimed −0.25.
  * γ = 1.5 (χ² = ∞, tail exponent β = 4/3): slope −0.389 and −0.412. The heuristic −α/β is −0.375; the claimed −0.25 is clearly off.

  The E5 nested-spare case has bounded Y = 1/q_S, so its agreement with −0.25 is unaffected.
* *Fix.* Add "and Σ_s Q_σ(s)²/P*(s) < ∞" to (c). Remark that without it the decay is faster, between n^{−α_σ} and n^{−α_σ/2}. Add the same condition to model §10 open problem 2.

**5. [major] sound.tex lines 84–86 (Remark `sound:vacuous`) and app-sound.tex line 80. The vacuity proof needs a likelihood affine in w.**
* *Problem.* The remark is stated for "Dirichlet weights" in general, whereas Thm `sound:avg` is stated for L0, L1 and L2. The proof uses that w ↦ P_{T,w} is affine, so that W_T is an affine slice and is either null or the whole simplex. Under L1 (and L2), P_{T,w} = μ_{T,w}/Z_{T,w} is a ratio of power series in w, not affine. The remark also uses "linear independence allows at most one w*", which needs affinity. The source (model Rem 4.5, via Thm 5.1(b″)) is likewise implicitly L0.
* *Evidence.* app-sound proof: "The map w ↦ P_{T,w} is affine". Remark `ident:exact` has the same implicit scope.
* *Fix.* State "under L0, or any likelihood affine in w (the experiments' chain C_ch(J))". Add that under L1 vacuity is plausible (real-analyticity gives the null-or-everything dichotomy) but the countability step is not proved.

**6. [major] sound.tex line 41 (Remark `sound:tight`) and app-sound.tex line 35. The L1 clause is false at finite d.**
* *Problem.* The remark and its proof claim that "supp P_{T′} ⊆ supp P_{T*} gives Th_d(T′) ⊆ Th_d(T*) ... under L1 with parameters admissible". Under L1, supp P_T = Th(T), so the premise gives only Th(T′) ⊆ Th(T*). For finite d (symbol size), Th_d is not monotone in that sense.
* *Evidence.* Take T* = {a, a→b} and T′ = T* ∪ {b}, both ground. Then supp P_{T′} = Th(T′) = Th(T*) = supp P_{T*}, but b ∈ Th_{|b|}(T′) ∖ Th_{|b|}(T*). So under L1 at finite d, a T′ that generates only T*'s theorems and still "proves" a sentence T* does not prove at level d does exist in the template model. The L0 clause is correct, since Th_d depends only on the instance union.
* *Fix.* Restrict the L1 clause to d = ∞, in the remark and in the appendix proof. The status "proved" then stands.

**7. [major] ident.tex line 87 (Remark `ident:x5`). The experiments' posteriors do not meet the hypotheses of Thm `ident:doob`.**
* *Problem.* The remark says "Thm `ident:doob` covers the experiments' Dirichlet posteriors only for one-component generators (E1, E4, E6)". Thm `ident:doob` assumes setting W: a fixed countable class in which every T carries a fixed i.i.d. law. In E1, E4 and E6 the generator has one component, but the competitors have Dirichlet-integrated marginals, which are exchangeable and not i.i.d. The pools also contain data-dependent members: Mem(D_n) in E4 and E6, and causal-pool theories in E1. So the theorem as stated does not apply.
* *Evidence.*
  * Definition `ident:W` versus experiments §1.5.
  * E4 setup ("Pool: ... plus Mem(D_n)"); E6 setup ("also ... Mem(D_n)"); experiments §2 on causal pools.
  * The conclusion is still true for a fixed class. Run the (T,w) argument of the proof of Thm `ident:limit`(b) with the frequency functional: the one-component law P* is an atom of the prior on laws, so π_n({(T,w): P_{T,w} = P*}) → 1, P*-a.s. Data-dependent pools are covered by no consistency theorem in the paper.
* *Fix.* Write: "The argument of Thm `ident:doob`, run on (T, w) as in the proof of Thm `ident:limit`(b), gives concentration on {(T,w): P_{T,w} = P_{T*}} for one-component generators and a fixed pool. The experiments' data-dependent pools (Mem(D_n), causal pools) are covered by no consistency theorem here; they are covered only by the soundness bound of Thm `sound:avg` (pool version)." Status: "proved (extension) / not covered".

**8. [major] sound.tex line 134 (Remark `sound:lumps`). Thm `sound:shrink` is applied to data-dependent pools, but no pool version of it is stated.**
* *Problem.* The remark argues "No contradiction with Thm `sound:shrink`" for E2. E2 uses causal pools containing SeenQ(D_n) and trimmed theories, so the pool depends on the data. Thm `sound:shrink` is stated for a fixed countable class; only Thm `sound:avg` has a pool version, and E2's data have fixed weights, so Thm `sound:avg` does not apply. The source, experiments Prop X8(c), does state the fixed-weight result for any pool R_n ∋ T*.
* *Evidence.* Thm `sound:shrink` statement; the pool version in Thm `sound:avg` only; experiments Prop X8(c) ("Let R_n ⊆ F be any pool, possibly chosen by looking at the data").
* *Fix.* Add a pool version to Thm `sound:shrink`: "the conclusion holds with the posterior restricted to any R_n ∋ T*, δ_n ≤ 2^{−bits(T*)}R(n,K)δ′". The pathwise argument of the pool version of Thm `sound:avg` goes through verbatim with Z′_n. Then cite it in Remark `sound:lumps`.

**9. [major] app-ident.tex line 106 (Table `tab:ident:c2`, caption and "misspecified prediction" row). The prediction omits a term, and the caption misdiagnoses the gap.**
* *Problem.* The misspecified predictions (−1.50, 39.5, 480.4, 4920.4, 49351.8) omit +(K−1)/2 = 1.5. The well-specified row includes it. The caption explains the gap at n = 100 as "the misspecified expansion is not yet accurate".
* *Evidence.*
  * E[nKL(r̂‖p)] = nKL(r‖p) + E[nKL(r̂‖r)] ≈ nKL(r‖p) + (K−1)/2, so the same term belongs in both rows.
  * The corrected predictions are −0.003, 40.98, 481.87, 4921.9 and 49353.3 (`a1`).
  * An independent Monte Carlo (20 000 runs each) gives 0.003 ± 0.026, 40.970 ± 0.076 and 481.60 ± 0.24 at n = 10², 10³, 10⁴. That matches the corrected values, not the printed ones.
  * The c2 means in the table (−0.06, 39.7, ...) are consistent with the corrected predictions, within their 400-run errors, except n = 10³ at 2.4 standard errors.
  * The source script `c2_split.py` line 100 adds (K−1)/2 only "if kl == 0".
* *Fix.* Add (K−1)/2 to the misspecified predictions: −0.00, 41.0, 481.9, 4921.9, 49353.3. Replace the caption sentence by "both predictions include the mean (K−1)/2 of nKL(r̂‖r)". Optionally report the standard errors.

### Minor

**10. [minor] ident.tex line 17 (section intro). "At best decay polynomially" holds only under Dirichlet weights.**
* *Problem.* "spare templates are never refuted and at best decay polynomially" is true only for Dirichlet weights. With fixed weights they decay exponentially, (1−w_σ)^n, as Remark `ident:sparetotal` itself says. Section 4.1 (setting W) is fixed-weight.
* *Fix.* Write "with Dirichlet weights, spare templates ... decay at best polynomially (exponentially with fixed weights)".

**11. [minor] app-model.tex line 86 (Table `tab:model:likelihoods`, row P^η_T "yes†") and ident.tex line 238 (Remark `ident:nearmiss`). The size principle is vacuous under full-support noise.**
* *Problem.* With full-support noise N (or a full-support channel K), supp P^η_{T*} = S. Then ε = P(S ∖ supp P*) = 0 for every competitor, and Lemma `model:size` gives nothing. The mark "yes" and the clause "the size principle hold[s]" are vacuously true and mislead. Over-general theories are still penalised through KL, but not through support.
* *Fix.* Mark the row "vacuous (full-support noise)", and say so in Remark `ident:nearmiss`.

**12. [minor] sound.tex line 105 (Thm `sound:avg`, pool version) and app-sound.tex line 115. The "may be divided" clause reads as an improvement but is a weakening.**
* *Problem.* The clause "for a fixed pool H plus all memorisers, 2^{−bits(T*)} may be divided by Σ_{T∈H}2^{−bits(T)} + 1" divides by a number ≥ 1, so it is a weakening. It is a necessity only when the memorisers are coded outside the experiments' Kraft code, in which case the proof's premise "C ≤ 1 (Kraft)" fails for that F. As written, a reader cannot tell which case is meant.
* *Fix.* State: "If the memorisers' codes lie outside the template code, C ≤ Σ_H 2^{−bits} + 1 may exceed 1, and the threshold must be δ ≤ 2^{−bits(T*)}δ′/(Σ_H 2^{−bits} + 1)".

**13. [minor] ident.tex line 98 (Remark `ident:memo`). Hypotheses of the cited result are dropped.**
* *Problem.* "The memoriser class can keep mass exp(−O(ln²n))" drops the hypotheses of universal Prop U6: Laplace-weighted memorisers, under geometric numerals.
* *Fix.* Add "(Laplace-weighted memorisers, geometric numerals)".

**14. [minor] model.tex line 209 (Prop `model:whichsize`(c)). The exact factor needs a weight convention that is not stated.**
* *Problem.* "exactly by (1−w_ψ)^n under L0 with fixed weights" needs T*'s weights to be scaled by 1−w_ψ in T′. The appendix proof uses this; the statement and the notes' bullet name it, the paper's statement does not.
* *Fix.* Add "(T*'s weights scaled by 1−w_ψ)".

**15. [minor] sound.tex line 184 (Remark `sound:indep`). Two statements are imprecise, and the status is too strong.**
* *Problem.*
  * "Bel of a sentence ψ independent of the data stays at its prior level forever" is not what Prop `model:whichsize`(b) gives. That proposition gives prior odds between T* ∪ {ψ} and T*. Bel(ψ) is still renormalised as data eliminate theories.
  * "So Indep(ψ) grows" does not follow: the lost mass may move to theories that refute ψ.
  * The status "proved" rests partly on Prop `ident:spare`(b), which is a sketch, when ψ is generated by a schema rather than cited as a ground sentence.
* *Fix.*
  * Say "the posterior odds of T* ∪ {ψ} against T* stay at their prior value".
  * Say "Bel(ψ) falls; Indep(ψ) grows if the mass goes to theories that do not refute ψ".
  * Change the status to "proved for ground ψ; proof sketch otherwise".

**16. [minor] ident.tex lines 140–142 (Prop `ident:spare`). One case is not covered.**
* *Problem.* Case (c) assumes Q_σ is outside the span of T*'s components; case (d2) assumes it is in their convex hull. The case "in the span but outside the hull" is covered by neither. If w* is interior there, the families coincide locally, so R_n presumably behaves as in (d2).
* *Fix.* Extend (d2) to "in the span, with w* such that the reparametrised family has positive density at P*", or list the case as open.

**17. [minor] sound.tex line 56. "Never accepts" is too strong.**
* *Problem.* "in `ex:ident:weaker` it never accepts ∀x(0+x=x)" is too strong. The corollary gives only that the deriving mass tends to 0, so the sentence is not accepted from some n on; at small n the prior may make it accepted.
* *Fix.* Write "it accepts ∀x(0+x=x) at most finitely often (never, from some n on)".

**18. [minor] model.tex line 201 (Lemma `model:size`, "Computed"). Two computations are conflated.**
* *Problem.* The sentence conflates two computations. The identity (a) was checked on a truncated universe (30 901 terms, KL = 2.618), while 3.894 is the untruncated KL estimated by simulation. The value 3.94 is quoted only at n = 10⁴; the values at 10² and 10³ are 3.81 and 4.19, with no standard error.
* *Fix.* Write "(a) holds to 10⁻⁹ on the truncated grammar; the simulated per-datum log-ratio of the untruncated grammar is 3.81, 4.19, 3.94 at n = 10², 10³, 10⁴, against KL = H(Q) = 3.894".

**19. [minor] sound.tex line 38. The escalation-bound transfer is asserted without proof.**
* *Problem.* "IL's escalation bound (IL Thm 4.16) transfers with C*_d as the target" is not argued anywhere. IL's bound on escalations of invalid queries needs a REJECT threshold δ_r, which the protocol of Def `sound:protocol` lacks. Only the bound on valid escalations, ≤ (ln(1/W*_d) + ln(1/δ″))/δ, transfers directly.
* *Fix.* State the transferred bound for valid escalations, add the one-line argument (members of C*_d pass every constraint, so Z_t = W*_d/π_t(C*_d) and each valid escalation multiplies it by ≤ 1−δ), and note the absence of δ_r.

**20. [minor] ident.tex line 234 (Prop `ident:proofs`(c)). The citation supports the opposite point.**
* *Problem.* "finer than the Th(T*) that conclusions identify (Prop `ident:sep`)" cites the proposition that shows conclusions already separate deductively equivalent theories. What is true: proof data guarantee identification of the L0 generator class, which is contained in the L1 conclusion class. Conclusions guarantee only Th(T*), though they often give more.
* *Fix.* Write "(c) The proof-data generator class is contained in the conclusion-data generator class; proofs guarantee ∪inst(T*), conclusions only Th(T*) (though they often separate more, Prop `ident:sep`)".

**21. [minor] app-sound.tex (whole appendix, opening). Missing refereeing disclosure.**
* *Problem.* Unlike app-ident line 11, it does not say which results were refereed. Lemma `sound:regret`, Thms `sound:avg` and `sound:shrink`, Remark `sound:vacuous`, Example `sound:constant`'s mechanism and Prop `sound:fiftyfifty` were added after the model referee (model notes, "What changed after the referee"; §7 "new").
* *Fix.* Add the same sentence as in app-ident: refereed by the model referee were Thm `sound:fixed`, Props `sound:cautious`, `sound:complete`, `sound:laws`–`sound:bracket`; added afterwards and checked by the track only were the items listed above.

**22. [minor] ident.tex line 61 (Prop `ident:splits`(c)). A hypothesis of the cited result is missing in the main text.**
* *Problem.* The main text omits "under its richness condition" for AS Prop C.1. The appendix has it.
* *Fix.* Add "(under AS's richness condition)".

**23. [minor] sound.tex line 45 (Remark `sound:hyp`). Scope of the computable verifier.**
* *Problem.* The computable-verifier clause needs a finite class and d < ∞, so that Th_d is decidable and the likelihoods are computable. These conditions appear only in the appendix.
* *Fix.* Add "for a finite class and d < ∞".

**24. [minor] sound.tex lines 118–122 (Example `sound:constant`). The failure needs ε small, and the text does not say so.**
* *Problem.* The example and its mechanism do not say that the failure needs ε small enough for the window 1 ≪ n ≪ 1/ε to reach ln 99.
* *Evidence.*
  * The referee's r3 found 0 acceptances at ε = 10⁻³ and 10⁻⁴.
  * Drift alone gives max_n[½ln n + ½ln(π/2) − nε] = 2.83 and 3.98 < ln 99 = 4.60 there (`a2`).
* *Fix.* Add "for ε = 10⁻³, 10⁻⁴ no acceptance occurred (r3); the constant threshold fails when T′ is close enough to T*'s law that the window 1 ≪ n ≪ 1/ε is long".

**25. [minor] ident.tex line 148 (Remark `ident:sparetotal`). The status is too strong for one sentence.**
* *Problem.* The status "proved (the sum)" covers the sentence "about (prior ratio/δ_r)^{1/α} data ... in case (b)", which rests on the sketch of Prop `ident:spare`(b).
* *Fix.* Mark that sentence "(from the sketch (b))".

**26. [minor] model.tex line 191 (Definition `model:scores`). The S_nc,β identification needs β > 1.**
* *Problem.* "S_nc,β equals β^n S_g with g ≡ 1 on provable data and g_∞ = 1/β" needs β > 1, because the definition requires g_∞ < 1. Universal allows β ≥ 1, and S_nc,1 = S_nc.
* *Fix.* Write "for β > 1 (β = 1 is S_nc)".

**27. [minor] model.tex line 152 (Lemma `model:lone`(b)). The bound fails for the empty theory.**
* *Problem.* "Z_T ≥ 1−α_r" is false for T = ∅ if a theory citation from the empty theory is read as invalid; the appendix's "Implicit in the notes" paragraph then gives only Z_∅ ≥ α_lg. Prop `model:compute`(b) uses T = ∅.
* *Fix.* State (b) for T ≠ ∅ and add "Z_∅ ≥ α_lg" to the lemma itself.

## 4. Independent code (research/paper-review/scratch/)

| script | checks | result |
|---|---|---|
| `a1_numbers.py` | c_{4,½}, Table `tab:ident:c2` (with Monte Carlo), spare (a)/(d1)/pa numbers, 1/(eπ), the KT constant, the subcrit bound, exact Q_A mean, GW numbers, H(Q), the Prop `ident:sep` region, c16 drift, E5 gain, the implied Z in r6, the prefix-code refutation | all paper numbers confirmed except issues 3 and 9 |
| `a2_example49.py` | Example `sound:constant`, every n ≤ 4·10⁵, 300 runs per cell | 0.967 / 1.000 (fixed w*), 0.013 / 0.010 (prior w*), 0 / 0 (shrinking δ_n); ε-window values |
| `a3_regret.py` | Lemma `sound:regret`(a), (b), (d), slopes | all hold; slopes −0.499, −0.500, −0.995 |
| `a4_spare_heavy.py` | Prop `ident:spare`(c) with finite and infinite χ² | −0.27/−0.23 against −0.39/−0.41: issue 4 |
| `a5_trichotomy.py` | k-monotonicity, bracketing, 50/50 criterion, Examples `sound:renorm`/`sound:fifty` | 0 violations; criterion 1800/1800 |
