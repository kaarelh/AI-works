# InfLearn: Lean 4 formalization of the inferential-learning theory

This directory contains a Lean 4 / Mathlib formalization of selected theorems from the
theory notes in `../research/theory/T1-…T7-*.md`. The paper (`../paper/`) is built from
those notes. The formalization has

* no `sorry`, no `axiom` declarations, no `native_decide`, no `admit`, no `opaque` or
  `implemented_by`;
* 0 errors and 0 warnings in `lake build`;
* every audited declaration depends only on Lean's standard axioms `propext`,
  `Classical.choice` and `Quot.sound`. See `audit-output.txt`.

14,571 lines of Lean in 17 modules (`wc -l InfLearn/*.lean InfLearn/*/*.lean`), plus the root
module `InfLearn.lean` and `Audit.lean`.

## Building

Toolchain: `leanprover/lean4:v4.32.0` (see `lean-toolchain`); Mathlib tag `v4.32.0`
(see `lakefile.toml` and `lake-manifest.json`).

```bash
export PATH=$HOME/.elan/bin:$PATH      # if elan is not already on PATH
cd lean
lake exe cache get    # download prebuilt Mathlib .olean files (needs network access to the cache)
lake build            # builds the InfLearn library (default target)
lake build Audit      # prints `#print axioms` for every main theorem (see below)
```

**Note on the Mathlib cache.** This formalization was developed in a sandbox where Mathlib's
binary cache (`lake exe cache get`) was blocked. Mathlib was therefore compiled from source,
but only the part that is needed. Lake builds just the modules transitively imported by the
project. All of Mathlib enters through `InfLearn/Prelude.lean`, which imports
`Finset`/`Fintype`/`Set.Finite`, `Order.Closure`, `CompleteLattice`, `Real.Basic`,
`Analysis.SpecialFunctions.Log.Basic`, and the tactics `linarith`, `positivity`,
`fin_cases` and `Mathlib.Tactic.Common`. That is about 1,700 Mathlib modules (1,671 `.olean`
files under `Mathlib/`), not the whole library. The six wave-2 modules (`Bilateral`,
`Specker`, `ParadoxLowerBound`, `Unstructured`, `Export`, `NoAdaptation`) also import only
`InfLearn.Prelude` or project modules, so they did not enlarge this subset.

* **Where the cache is reachable:** run `lake exe cache get` first, then `lake build` only
  compiles the 17 project modules, which takes a few minutes. Each of the larger modules
  needs 10–30 s.
* **Without the cache:** `lake build` compiles that Mathlib subset from source, which takes
  a long time (hours on a small machine).

Rule for contributors: import `InfLearn.Prelude`, or the project's own modules, rather than
adding new Mathlib imports. A new Mathlib import outside the compiled subset would force a
much larger from-source build wherever the cache is unavailable.

The module files themselves contain `#print axioms` lines, so `lake build` prints `info:`
messages. These messages are expected and are not warnings.

### Axiom audit

`Audit.lean` imports the whole library and runs `#print axioms` on 483 main declarations,
including the foundations and every theorem named in the *Lean* column of the tables below.
It is a separate `lean_lib` target named `Audit`. Its output, from `lake build Audit` with a
four-line header added, is in `audit-output.txt`. The same file also contains the 357
`#print axioms` checks embedded in the module files, which Lake replays first. Counts below are
taken from `audit-output.txt`; a message whose axiom list wraps onto several lines counts once.

| axioms reported | `Audit.lean` (483) | module files (357) |
|---|---|---|
| `propext, Classical.choice, Quot.sound` | 429 | 323 |
| `propext, Quot.sound` | 42 | 26 |
| `propext` | 10 | 8 |
| none | 2 | 0 |
| `sorryAx` or any non-standard axiom | **0** | **0** |

A case-insensitive `grep` for `sorry`, `axiom`, `native_decide`, `admit`, `opaque`,
`implemented_by`, `unsafe` and `extern` over `InfLearn/` and `InfLearn.lean` matches only the
`#print axioms` audit lines and English words in comments and docstrings ("axiom ⊳ p",
"the axioms of the reading `h_j`", "group axioms", "admitted", "admits", and section headings
such as "Axiom audit").

## Layout

| file | contents |
|---|---|
| `InfLearn/Prelude.lean` | The single entry point for Mathlib imports. |
| `InfLearn/ConsOp.lean` | Tarski consequence operators `ConsOp S` (extensive, monotone, idempotent; finitarity is **not** assumed); `Coherent`, `Finitary`, the trivial operator, `Mod`/`Th`. |
| `InfLearn/Prop/Basic.lean` | Propositional formulas over `{⊥, ⊤, ¬, ∧, ∨, →}` with atoms `ℕ`; evaluation, substitution, fragments `InFrag L`; `SemCons`; classical consequence `Cn2` (𝐂₂); `Structural`; the compactness theorem (proved, not assumed). |
| `InfLearn/Steps.lean` | Steps `(Π, j)` with finite premise sets; derivability `Cl A B`; `Sound R`; `ClOp`; substitution closure `⟨D⟩`; `SemSound` (classically valid steps). |
| `InfLearn/StepSoundness.lean` | T1 Lemma 1.1, Thm 2.1, Thm 3.1. |
| `InfLearn/PostCompleteness.lean` | T2 Thm 3.1, Thm 3.3, Prop 3.5(a) (partial); T7 Lemma 6.1. |
| `InfLearn/Carnap.lean` | T2 Lemma 4.1, Thms 4.2–4.4 (Carnap's problem, denial rank, tell-tales, non-learnability). |
| `InfLearn/CoherenceGames.lean` | T2 Lemma 2.1, Thm 2.2, Prop 2.3, Thm 2.4, Thm 2.5; T4 Thm 4.3(a), Thm 4.5. |
| `InfLearn/Blame.lean` | T7 Lemma 2.3 (hitting-set duality); T4 Lemma 4.1 (descent). |
| `InfLearn/RateThreshold.lean` | T5 Lemma 3.1, Thm 3.2, Thm 4.1(ii) (partial); T4 Prop 7.1, Cor 7.2, Prop 7.3. |
| `InfLearn/Contexts.lean` | T3 Props 1.4, 1.5, 1.6(a), Lemma 1.8(a), Thm 1.9, Thm 2.1 (propositional toy model); T2 Prop 7.1. |
| `InfLearn/Unstructured.lean` | T1 Thm 3.2 (escalation dimension = positive elasticity, deterministic verifiers) and Thm 3.9 (unstructured classes, KWIK bound, the co-singleton class). Builds on `StepSoundness`. |
| `InfLearn/Export.lean` | T3 Lemma 3.2, Thm 3.3(b)–(d), Prop 3.4 (no free export, radius of information); T3 Thm 4.1, Thm 4.4, Thm 4.5, Thm 4.6 (coherence cannot calibrate; certification of validity regions). Real-valued, over arbitrary parameter types or `[0,1]^d`. |
| `InfLearn/ParadoxLowerBound.lean` | T4 Thm 4.3(b) and Thm 4.4(b),(c): the correction game of Def 4.2 with deterministic learners, the single-culprit class, and the chain (sorites) paradox with its CPC hypotheses. Builds on `CoherenceGames`. |
| `InfLearn/NoAdaptation.lean` | T5 Thm 2.1(i) (no adaptation with private randomness): Gibbs' inequality, the entropy lower bound, the uniform hypothesis, the group condition, and the paper's counterexample. |
| `InfLearn/Bilateral.lean` | T6 §2: Scott relations, bilateral Lindenbaum (Thm 2.2), strong bilateral completeness (Cor 2.3), the duality with closed sets of valuations (Thm 2.4), structural relations and Lindenbaum matrices (Thm 2.6). Builds on `Carnap`. |
| `InfLearn/Specker.lean` | T6 Thm 3.4 (no bounded-arity family of coherence constraints suffices), the remark after it, Specker's parable, and the probabilistic half of T6 Prop 4.7 (frustrated triangle). |
| `InfLearn.lean` | Root module; imports everything. |
| `Audit.lean` | Axiom audit (`lake build Audit`). |

Each module has its own namespace (`InfLearn.StepSoundness`, `InfLearn.Post`,
`InfLearn.Carnap`, `InfLearn.CoherenceGames`, `InfLearn.Blame`, `InfLearn.RateThreshold`,
`InfLearn.Contexts`, `InfLearn.Unstructured`, `InfLearn.Export`,
`InfLearn.ParadoxLowerBound`, `InfLearn.NoAdaptation`, `InfLearn.Bilateral`,
`InfLearn.Specker`), so names do not clash. Integrating the six wave-2 modules needed no
renaming: `lake build` of the full root module succeeded unchanged. Inside `Unstructured`,
`StepSoundness.Consistent` is written qualified because `InfLearn.Consistent` (consistency
of a consequence operator, from `Prop/Basic`) is also in scope.

### Modelling conventions shared by all modules

* **Language.** The object language is fixed: atoms `p₀, p₁, …` and the connectives ⊥, ⊤, ¬,
  ∧, ∨, →. Results stated in the notes for "any language with Boolean connectives" are proved
  for every *fragment* of this connective set (`FragFm L`). Other Boolean connectives, such as
  XOR or NAND, are not representable. Exception: T6 Thms 2.2–2.4 (`Bilateral`) are proved for
  sequents over an *arbitrary* type of formulas, as in the notes ("fix a set Fm"). T6 Thm 2.6
  (term algebras) is proved only for this fixed language.
* **Consequence operators** are arbitrary closure operators on `Set Formula`, possibly
  infinitary. "Structural" means `σ(C X) ⊆ C(σ X)` for every substitution σ.
* **Steps** have finite premise sets (`Finset`). Derivations are the inductive closure `Cl`.
* **Learners and verifiers** are arbitrary (noncomputable) functions. Computability claims
  are not formalized.
* **Probability.** T1 Thm 2.1(ii) models a distribution on the countable step set as a
  non-negative summable weight function. `Specker` and `NoAdaptation` use finite distributions:
  non-negative real weight vectors summing to 1, on the `2^k` Boolean worlds or on a finite
  class `F` of labelers. Randomized verifiers, learners and certifiers are **not** modelled:
  every interactive lower bound (T1 Thms 3.1(b), 3.2, 3.9; T4 Thms 4.3(b), 4.4; T3 Thms
  4.4–4.6) is proved against deterministic agents only.
* **Real analysis.** Derivatives and `ContDiff` are outside the compiled Mathlib subset. So
  `Export` replaces the paper's smooth bumps by Lipschitz tents `max 0 (r - dist x c)` (T3
  Thm 3.3(b) and Thm 4.4), and takes the link between derivative jets and polynomial
  coefficients as a hypothesis (T3 Thm 3.3(c)). Polynomials (`Mathlib.Algebra.Polynomial`),
  metric spaces, `Real.log`, the product topology and `ENNReal` are available.

## Theorem map

Faithfulness legend:

* **exact**: the paper statement, possibly in a slightly more general form.
* **special case**: a strict special case of the paper statement, as described in the notes
  column.
* **weaker**: a weaker conclusion than the paper claims.
* **variant**: a closely related statement whose hypothesis is neither stronger nor weaker
  than the paper's (used for T3 Thm 3.3(b), where tents replace smooth bumps, and T3
  Thm 3.3(c), where polynomial coefficients replace derivative jets).
* **—**: not formalized.

The *source* column names the result in the theory notes `../research/theory/T*.md`. The
*paper* column gives the LaTeX label of the matching result in `../paper/sections/*.tex`. The
middle part of a label names the paper section: `thm:caution:vs` is in `caution.tex`, and a
few labels (e.g. `prop:physics:propagation`, `prop:app:caution:conj23`) are in the matching
appendix file `app-*.tex`. A label `sec:…` stands for a whole (sub)section. Notes were matched to labels through the
paper's source tags (`\src{T… …}`). Printed theorem numbers are deliberately not given: they
change whenever a section is added or edited, and the labels are the stable reference. A
result without a label of its own is marked as such. Names in the *Lean* column after the
first one share its namespace prefix. Appendix `app:lean` of the paper (`app-lean.tex`, table
`tab:lean:map`) is a condensed version of this map.

### Foundations (paper: `setting.tex`)

| source | paper | Lean | file | faithfulness | notes |
|---|---|---|---|---|---|
| T1 §1.1 closure facts | `lem:setting:closure` | `InfLearn.Derivable`, `Cl_eq_sInter`, `ClOp`, `ClOp_finitary`, `Cl_mono_rules`, `subset_Sound`, `Cl_subset_Cl_iff_subset_Sound` | Steps | exact | `Cl_{Sound R} = Cl_R` follows at once from `Cl_subset_Cl_iff_subset_Sound` with `subset_Sound`, but is not stated as its own lemma. |
| compactness of CPC | used throughout | `InfLearn.compactness`, `Cn2_finitary` | Prop/Basic | exact | Proved from scratch. Not assumed. |

### T1: soundness under search (paper: `search.tex`, `caution.tex`, `imitation.tex`)

| T1 result | paper | Lean | file | faithfulness | notes |
|---|---|---|---|---|---|
| Lemma 1.1 (reasoner soundness = stepwise soundness) | `lem:search:stepwise` | `StepSoundness.lemma_1_1`, `concl_not_derivable_of_not_mem_Sound`, `reasoner_sound_of_subset` | StepSoundness | exact | Any judgment type `J`. The paper cites the underlying `Cl_subset_Cl_iff_subset_Sound` via `\leanok`. |
| Thm 2.1(i) (tonk beyond the horizon) | `thm:search:tonk` | `thm_2_1_i`, `thm_2_1_i_univ`, `thm_2_1_i_derivation`, `thm_2_1_unsound`, `T_not_subset_Sound` | StepSoundness | exact | Explicit linear derivation of exactly `j+2` steps; only the last step is in `T_j`, and it is unsound for every non-tautologous `C`. Holds for every `R ⊇ {⊤I, ∧I, ∨I₂}`. Convention: `T 0 = T 1`. |
| Thm 2.1(ii) (`Q(T_j) → 0`) and the concluding sentence | `thm:search:tonk` | `thm_2_1_ii`, `T_disjoint`, `thm_2_1_error_and_trivial` | StepSoundness | exact | `Q` is any non-negative summable weight on the countable step set, which covers every probability distribution on it. Finitely additive set functions are not treated. |
| Thm 2.1, last sentence (finitely many pure schemas) | `thm:search:tonk` | `Rstar_sound`, `Rstar_eq_substClosure`, `T_eq_substClosure`, `Rstar_union_T_eq_substClosure` | StepSoundness | exact | |
| Cor 2.2 (PAC learners can be maximally unsound) | `cor:search:pac` | `cor_2_2_trivializes` | StepSoundness | weaker | Only the deterministic core: every output `L ∪ Rbase ∪ T_j` trivializes. The bound `Pr[Q(T_ĵ) > ε] ≤ (1−ε)^m` is not formalized. |
| Prop 2.3 (every unsound pure schema is a tonk) and its repair | `prop:search:post`, `lem:search:purify`, `cor:search:purify` | — | — | — | Not stated as such. Its consequence-operator core is T2 Thm 3.1 (`Post.eq_Cn2_or_eq_trivial`). |
| Thm 3.1(a) (VS verifier is 0-sound, uniformly) | `thm:caution:vs` | `thm_3_1_a`, `target_mem_VSh`, `vsVerifier_acc_iff/rej_iff/esc_iff`, `thm_3_1_a_reasoner`, `vsVerifier_reasoner_sound`, `thm_3_1_a_static` | StepSoundness | exact | The interactive protocol is modelled explicitly: histories, the escalation oracle, and adaptive provers `History → Step` that may depend on `R*`. |
| Thm 3.1(b) (optimality) | `thm:caution:vs` | `thm_3_1_b`, `vsVerifier_optimal`, `thm_3_1_b_closure`, `vsVerifierSound_optimal` | StepSoundness | special case | Deterministic verifiers only. This is the paper's explicit deterministic corollary. The randomized joint-probability bound `p ≤ δ` and the reckless-mode counterexample are not formalized. |
| Thm 3.1, static form; positive-data lemma | `lem:imitation:cautious` (a), (b) | `thm_3_1_a_static`, `thm_3_1_b_static`, `subset_sInter_VS_iff`, `reasoner_sound_for_all_VS_iff` | StepSoundness | exact for (a), (b) | Parts (c) (monotonicity in `D`) and (d) (lgg) of the paper lemma are not formalized. |
| Def 1.3 (escalation cost) and Thm 3.2 (escalation dimension = positive elasticity) | `def:setting:cost`, `def:caution:elastic`, `thm:caution:esc` | `Unstructured.thm_3_2`, `vsVerifier_attains`, `thm_3_2_lower`, `thm_3_2_upper`, `chain_not_acc`, `elasticChain_iff`, `vsVerifier_escQueries_chain`, `vsVerifier_cost_eq_escCount` | Unstructured | special case | Deterministic 0-sound verifiers only: `Esc H P0` is the infimum, over deterministic 0-sound verifiers, of the worst one-sided cost on honest runs. The randomized half ("expected cost `≥ (1−δ)m` for δ-sound verifiers") is not formalized, and neither is the restriction to steps of size `≤ N`. `H` is arbitrary, possibly infinite. The lower bound holds for every prover that issues the elastic chain in its first `m` rounds and is arbitrary afterwards. |
| Thm 3.9 (unstructured classes) | `thm:caution:unstructured` | `Unstructured.vsVerifier_escCount_le`, `thm_3_9_upper`, `thm_3_9_upper_honest`, `thm_3_9_Esc_le`, `thm_3_9_Esc_le_card`, `card_coSingleton`, `thm_3_9_coSingleton_lower`, `exists_honest_prover_coSingleton`, `thm_3_9_coSingleton_forces`, `thm_3_9_coSingleton`, `exists_class_Esc_eq` | Unstructured | special case | Upper bound: against every prover, honest or not, the VS verifier escalates at most `\|{R ∈ H : P0 ⊆ R}\| − 1 ≤ \|H\| − 1` times. This is relative to human data `P0`, so slightly more general than the paper. Lower bound for `{U \ {u}}`: one honest, non-adaptive prover forces cost `\|U\| − 1` on every *deterministic* 0-sound verifier; randomized verifiers are not covered. `exists_class_Esc_eq` gives "`2^L` hypotheses can need `2^L − 1` escalations" for every class size. The remark on single schemas (at most `N + 1`) is T1 Thm 3.4 and is not formalized. |
| Lemmas 1.2–1.3 and the lgg (anti-unification); Prop 2.4; Prop 3.3, Thm 3.4, Prop 3.5, Thms 3.6–3.7, Conj 3.8; §4 (Thms 4.1, 4.2, 4.4, Prop 4.3, Cors 4.5–4.6: Bayes-conservative verification, Ville); §5 (anchors, rates); §6 (noise) | `thm:setting:lgg`, `lem:setting:rank`, `lem:setting:recover`, `prop:search:mdl`, `prop:caution:closure`, `lem:caution:h1`, `thm:caution:single`, `prop:caution:bell`, `thm:caution:tagged`, `thm:caution:untagged`, `conj:caution:binomial`, `prop:app:caution:conj23`, `sec:caution:bayes`, `sec:imitation` (all of it except `lem:imitation:cautious` (a), (b)) | — | — | — | Not formalized. |

### T2: coherence as negative data (paper: `coherence.tex`; Thm 2.4 in `search.tex`, Prop 7.1 in `physics.tex`)

| T2 result | paper | Lean | file | faithfulness | notes |
|---|---|---|---|---|---|
| Lemma 2.1 (negative bag), bullets 1–2 | `lem:coherence:bag` | `CoherenceGames.negative_bag`, `refuted_of_superset` | CoherenceGames | exact | Any judgment type. Bullet 3 (logical vs. witness refutation) is not formalized. |
| Thm 2.2(i),(ii) (oligarchic halving: target survives, `D ≤ log₂ 1/w(R*)`) | `thm:coherence:halving` | `thm_2_2`, `thm_2_2_of_derivations`, `thm_2_2_uniform`, `oligarchic_halving`, `halving_bound*`, `weight_le_pow_mul` | CoherenceGames | special case | Finite hypothesis class (`Fintype ι`) with non-negative, unnormalized weights; the bound has the form `2^D·w(R*) ≤ w(𝓗)`. The paper allows countable classes. `thm_2_2_of_derivations` derives legality of (N)-rounds from genuine ⊥-derivations, via Lemma 2.1. |
| Thm 2.2(iii),(iv) | `thm:coherence:halving` | `thm_2_2_iii_iv` | CoherenceGames | exact | |
| Prop 2.3 (per-round halving ⇔ coalition) | `prop:coherence:oligarchy` | `prop_2_3` | CoherenceGames | special case | Finite version space only. The countable / σ-additive case is not formalized. |
| Thm 2.4 (doctrinal paradox) + Claim + Caveat | `thm:search:doctrinal` | `thm_2_4`, `thm_2_4_memberships`, `mem_majority_three`, `thm_2_4_environment`, `thm_2_4_constant_environment`, `thm_2_4_caveat`, `Sound_hyp` | CoherenceGames | exact | The second caveat bullet (complete texts eventually refute every wrong hypothesis) is not formalized. |
| Thm 2.5 (robust version, Littlestone–Warmuth) | `thm:coherence:robust` | `thm_2_5` | CoherenceGames | special case | Finite class. The coalition may be any index set. |
| Thm 3.1 (Post completeness: structural `C ⊇ 𝐂₂` is `𝐂₂` or trivial) | `thm:coherence:post` | `Post.eq_Cn2_or_eq_trivial`, `structural_extensions_Cn2`; fragments: `frag_eq_Cn2F_or_eq_trivial`, `frag_postComplete_neg`, `impFrag_postComplete` | PostCompleteness | exact (connectives ⊆ {⊥,⊤,¬,∧,∨,→}) | No finitarity is assumed. The fragment theorem covers every `L` that contains → or contains ¬ together with ∧ or ∨; this includes the paper's `{→}` case. Extra Boolean connectives are not representable. |
| Prop 3.2 (theorem-free fragment, `C_ai`) | `prop:coherence:almost` | — | — | — | Not formalized. |
| Thm 3.3 (coherence pins CPC), core step | `thm:coherence:cpc` | `eq_Cn2_of_coherent`, `eq_Cn2_of_consistent`, `eq_Cn2_of_satisfiable_coherent`, `eq_Cn2_iff_exists_coherent` | PostCompleteness | exact | |
| Thm 3.3(a) (finite collapse) | `thm:coherence:cpc` (a) | `versionSpace_eq_singleton_iff` | PostCompleteness | weaker | `S(D,A₀) = {𝐂₂} ⇔ ⟨D⟩ = 𝐂₂` is proved for arbitrary `D` and arbitrary (also infinitary) hypotheses. The claim "a finite `D` suffices" (Łukasiewicz / Tarski–Bernays bases + MP generate `𝐂₂`) needs a Kalmár-style completeness proof and is **not** formalized. |
| Thm 3.3(b) (identification without bias, ≤ i* mind changes) | `thm:coherence:cpc` (b) | `learner_identifies`, `learner_mindChanges_le` | PostCompleteness | exact (computability not formalized) | Holds for every ordering of the family and every text. The learner is defined classically (`Nat.find`), so the "uniformly decidable" hypothesis is dropped and computability of `M` is not shown. |
| Thm 3.3(c) bullets 1–2 (structurality and a coherence datum are needed) | `thm:coherence:cpc` (c) | `Cn2Add_not_structural`, `Cn2_le_Cn2Add`, `Cn2Add_validates`, `Cn2Add_consistent`, `Cn2Add_ne_Cn2`, `trivial_validates`, `trivial_ne_Cn2` | PostCompleteness | exact | Bullet 3 (`C_ai`) is not formalized. |
| Prop 3.5(a), consequence ("largest structural `C` with theorems Taut is `𝐂₂`") | `prop:coherence:adm` (b), first clause | `le_Cn2_of_empty_eq_Taut` | PostCompleteness | special case | `C_adm` (Prop 3.4) is not defined. Only the stated corollary is proved. |
| Lemma 4.1(a) (`Val(⊨ᵐ_V) = closure V`) | `lem:coherence:duality` (a) | `Carnap.Val_mrel`, `mrel_closure`, `mrel_eq_iff_closure_eq`, `eq_of_mrel_eq` | Carnap | exact | Uses Mathlib's product topology on `Formula → Bool`. `Bilateral.Val_Th` proves the same for sequents over an arbitrary type (T6 Thm 2.4). |
| Lemma 4.1(b) (`C_V` finitary; single-conclusion valuations = `V^∩`) | `lem:coherence:duality` (b) | `lemma_4_1_b`, `SVal_eq_intClosure`, `isClosed_CV_iff`, `SValS_srel`, `SCons_eq_of_subset_intClosure` | Carnap | exact | Finitarity via Tychonoff compactness. `SVal_eq_intClosure` is an infinite-premise version that needs no closedness hypothesis. |
| Lemma 4.1(c) (`BV^∩` = CPC theories) | `lem:coherence:duality` (c) | `mem_intClosure_BV_iff`, `intClosure_BV_eq` | Carnap | exact | |
| Thm 4.2 (Carnap 1943, learning form) + bullets | `thm:coherence:carnap` | `carnap_single`, `carnap_single_vtop`, `carnap_single_vTaut`, `carnap_problem`, `carnap_vtop`, `carnap_vTaut`, `mem_intClosure_BV_diff_BV_iff`, `intClosure_BV_and`, `consistent_nonBoolean_violates`, `isClosed_intClosure_BV`, `intClosure_BV_structural` | Carnap | exact | `v_⊤` is separated by `p,¬p ▷ ∅`, not by `∅ ▷ p,¬p` (`MCons_vtop_excludedMiddle`), in line with verification note C2. |
| Thm 4.2, "no learner…" | `thm:coherence:carnap` | `carnap_not_learnable_single` | Carnap | special case | Stated for texts of the single-conclusion relation. Other presentations are covered only because the relations are equal. The local reading of ND metarules (→I excludes `v_Taut`) is not formalized. |
| Thm 4.3 (denial-rank trichotomy) | `thm:coherence:rank` | `denialRank_eq_zero_iff`, `_one_iff`, `_two_iff`, `_top_iff`, `denialRank_le_two_of_not_mem_BV`, `denialRank_vtop`, `denialRank_vTaut` | Carnap | exact | |
| Thm 4.4(a) (`Val(TT) = BV`) | `thm:coherence:telltale` | `Val_TTall`, `isClosed_BV`, `mrel_eq_mrel_BV_iff` | Carnap | exact (adapted) | TT has 13 schemata, the paper's 11 plus `⊥ ▷` and `▷ ⊤`, because the language contains the constants ⊥ and ⊤. `Bilateral.Val_gen_TT` restates it as `Val ⟨TT⟩ = BV` for the generated Scott relation. |
| Thm 4.4(b),(c) (finite tell-tale among structural meanings; finite identification) | `thm:coherence:telltale` | `structural_eq_BV`, `finite_telltale_structural`, `empty_survives`, `ttLearner_finite_identification` | Carnap | exact (adapted) | The tell-tale has 13+1 data rather than 11+1, for the same reason. Necessity of each individual datum is not formalized. |
| Thm 4.4(d) (no tell-tale; BV not BC-learnable; density) | `thm:coherence:telltale` | `no_finite_telltale`, `not_BCIdentifies_of_no_telltale`, `exists_locking`, `BV_not_BC_learnable`, `BV_not_BC_learnable_meaning`, `BV_not_determined_nonstructural` | Carnap | exact | Includes a full Blum–Blum locking-sequence argument. Learners are noncomputable and texts may contain pauses. |
| Thm 2.6, Prop 2.7, Cor 2.8, Prop 2.8′, Prop 2.9; Prop 3.4 and the rest of Prop 3.5; Thm 3.6, Lemma 3.7, Thms 3.8–3.10, Prop 3.11 (arithmetic); Props 4.5, 4.6; §5 (tonk, conservativity, complexity); §6 (fallacies, residue) | `thm:coherence:silent`, `prop:coherence:chains`, `cor:coherence:limitpoints`, `prop:coherence:informant`, `prop:coherence:caution`, `prop:coherence:tradeoff`, `prop:coherence:adm`, `thm:coherence:ipc`, `sec:coherence:arith`, `prop:coherence:compositional`, `sec:coherence:tonk`, `sec:coherence:fallacies` | — | — | — | Not formalized. Prop 4.6 (world feedback) has no label of its own; it is a sentence in `sec:coherence:carnap`. |
| Prop 7.1 (mis-designation forces global sub-classicality) | `prop:physics:misdesignation` | `Contexts.not_Cn2_le_of_consistent_unsat`, `not_Cn2_le_of_coherent_unsat`, `misdesignation_not_Cn2_le`, `closure_eq_univ_of_unsat`, `exists_invalid_step`, `exists_invalid_schema`, `atomic_paraconsistent`, `atomic_nontrivial` | Contexts | exact | Part (a) needs no structurality, so it is slightly more general than the paper. |

### T3: contexts, idealization, export (paper: `physics.tex`)

T3 §1–§2 are formalized in `Contexts` in a **propositional toy model**: parameter points are
Boolean valuations, sentences are propositional formulas, `dom` is the set of all valuations,
and a context is an arbitrary filter on valuations. The first-order deformation frames over
real parameters (T3 Def 1.1) are not formalized. Thm 2.1's argument uses only filter structure
and properness, and it is proved for arbitrary proper filters.

T3 §3.1 and §4 are formalized in `Export` for **real-valued** families: a family is its query
function `Q : D → ℝ` on an arbitrary parameter type `D` (or `ℝ`, `[0, Λ]`, a metric space,
`[0,1]^d`), an information map is any `I : (D → ℝ) → α`, and an export rule returns either
"abstain" or an interval `[q − ε, q + ε]`. Certifiers are deterministic.

| T3 result | paper | Lean | file | faithfulness | notes |
|---|---|---|---|---|---|
| Prop 1.4(a),(b) (Th(c) is `𝐂₂`-closed; consistent iff proper) | `prop:physics:los` | `cn2_closed_ThIn`, `consistent_ThIn_iff`, `satisfiable_ThIn_iff` | Contexts | special case | Propositional. Part (c) (Łoś, ultraproducts) is not formalized. |
| Prop 1.5 (SUP is exact discharge) | `prop:physics:sup` | `holdsIn_sup_iff`, `sup_not_proper_iff` | Contexts | special case | Propositional. |
| Prop 1.6(a) (contradicting the root) | `prop:physics:idealized` | `patm_example` | Contexts | special case | A concrete propositional DEF child that deforms atom 0. Parts (b),(c) (rope, germ vs. limit) are not formalized. |
| Lemma 1.8(a) (import soundness) | `lem:physics:import` | `import_sound`, `defFilter_pure_pure`, `dStable_of_disjoint` | Contexts | special case | Propositional. Part (b) and the scope remark are not formalized. |
| Thm 1.9(a),(b),(c),(d) (reductio hygiene) | `thm:physics:hygiene` | `refutation_sound_in_context`, `proper_not_both_refuted`, `refutes_of_inconsistent`, `hygiene_*`, `derivation_local_test_accepts_both`, `certificate_refutes_false`, `certificate_not_both`, `certificate_rules_needed` | Contexts | exact for (b)–(d); special case for (a) | (a) is in filter semantics. (c): the satisfiability facts are for distinct atoms `A = p_a`, `q = p_b`; they fail for arbitrary formulas (e.g. `A = ⊤`). (e) is informal and not formalized. |
| Thm 2.1 (no truth-functional eternal reading) | `thm:physics:eternalism` | `not_exists_truthFunctional_reading`, `no_truthFunctional_eternal_reading`, `eternal_reading_witnesses`, `stripping_fails`, `conditionalizing_fails`, `tracksAt_conditional_of_not_proper`, `no_eternal_reading_pure`, `no_eternal_reading_modelClass` | Contexts | special case | Arbitrary proper context filter over propositional valuations. `tracksAt_conditional_of_not_proper` shows that the properness hypothesis is needed. |
| Lemma 3.2 (invisible perturbation) | `lem:physics:invisible` | `Export.invisible_perturbation` | Export | exact | Verbatim, for any parameter type, information map and export rule. |
| Thm 3.3(d) (no free export from finitely many samples) | `thm:physics:nofree` (d) | `Export.no_free_export_samples`, `no_free_export_samples_everywhere`, `no_free_export_samples_emb`, `no_free_export_samples_Icc`, `no_free_export_from_samples`, `no_sound_committing_rule`, `nodeClosed_of_addPolyClosed`, `samples_do_not_determine`, `no_free_export_perturbation` | Export | exact | The class is assumed closed under adding real multiples of the node polynomial `∏_{s∈S}(λ − s)`. That is implied by the paper's `𝓒 + C^∞ ⊆ 𝓒` and by closure under adding polynomials (`nodeClosed_of_addPolyClosed`), so the Lean hypothesis is weaker. Parameters in `ℝ`, `[0, Λ]` (`_Icc`) or any type embedded in `ℝ` (`_emb`); `λ*` is any point outside the sample set. |
| Thm 3.3, closing remark, for case (d) | `thm:physics:nofree` | `no_free_export_samples_of_poly_subset`, `exists_poly_interp` | Export | exact (stronger) | If `𝓒` merely contains the polynomials (so in particular if `𝓒 ⊇ C^∞`), the conclusion of (d) holds for **every** `Q ∈ 𝓒`, not only for smooth `Q`, via polynomial interpolation. So "can fail outside `C^∞`" does not apply to (d). The `√λ` counterexample concerns (b) and is not formalized. |
| Thm 3.3(c) (finite jets) | `thm:physics:nofree` (c) | `no_free_export_finite_jet`, `no_free_export_finite_jet'` | Export | variant | Abstract form without derivatives: `𝓒` contains every polynomial function, and `I` depends on a polynomial only through its coefficients `0..N`; the perturbation is `λ^{N+1}` and `λ*` is any non-zero point. The facts that an `N`-jet at 0 is determined by Taylor coefficients, and that every `Q ∈ 𝓒` shares its jet with a polynomial, are not proved (no calculus in the compiled subset). They enter as the hypotheses `hjet`, `hrep`; the primed version, for the normalized coefficient jet, needs only `hjet`. |
| Thm 3.3(b) (germ at 0; samples on a set whose closure omits `λ*`) | `thm:physics:nofree` (b) | `no_free_export_away`, `no_free_export_germ` | Export | variant | The paper assumes `𝓒 + C^∞ ⊆ 𝓒` and uses a smooth bump. Here `𝓒` is assumed closed under adding multiples of Lipschitz tents `max 0 (r − dist x c)` instead, because `ContDiff` is outside the compiled subset; neither hypothesis implies the other. Any metric parameter space; germ at any point `x₀ ≠ λ*`. |
| Prop 3.4 (minimax export = radius of information) | `prop:physics:radius` | `exists_interval_iff_radius_le`, `midrange_sound`, `optimalRule_sound`, `radius_le_of_sound`, `no_interval_of_unbounded` | Export | exact | Includes the unbounded case: an unbounded fibre admits no sound finite interval. |
| Thm 4.1 (coherence cannot calibrate tolerances) | `thm:physics:coherencetol` | `coherence_cannot_calibrate`, `coherence_cannot_calibrate_unbounded` | Export | exact | Arbitrary index types for schemas and instances. |
| Thm 4.4 (no certification without regularity) | `thm:physics:noreg` | `no_certification_without_regularity` | Export | weaker | Only the deterministic clause, in any metric space, with tents as the continuous bumps (closure under adding tents is weaker than closure under all continuous bumps, so this clause is slightly more general). The certifier is abstract (`LocalCertifier`: its output depends on `e` only through `e` on the queried set); adaptive certifiers are an instance (`AdaptiveCertifier.toLocal`). The almost-sure clause for randomized certifiers is not formalized. |
| Thm 4.5(a) (conservative Lipschitz certifier: soundness) | `thm:physics:lipschitz` (a) | `lip_cert_sound_point`, `lip_cert_sound_indexed`, `lip_cert_sound`, `lip_cert_sound_noisy` | Export | exact | In any pseudometric space. On `[0,1]^d` the sup norm is Mathlib's metric on `Fin d → ℝ` (`dist_le_iff_sup`). |
| Thm 4.5(b) (completeness, `⌈L/(γ−η)⌉^d` calls) | `thm:physics:lipschitz` (b) | `lip_cert_complete_of_net`, `lip_cert_complete`, `lip_cert_complete'` | Export | exact | On `[0,1]^d`, with the grid of `⌈1/h⌉^d` cell centres. |
| Thm 4.5(c) (lower bound `⌊L/(2γ')⌋^d`) | `thm:physics:lipschitz` (c) | `lip_lower_bound_of_packing`, `lip_lower_bound_cube`, `lip_lower_bound_cube_adaptive`, `lip_lower_bound_interval` | Export | exact | Deterministic certifiers with an exact oracle, as in the paper, abstract (`LocalCertifier`) or adaptive with a fixed budget. Soundness and completeness are required only on points of the cube; the class is the globally `L`-Lipschitz functions on `ℝ^d`. The randomized remark after T3 Thm 4.5 is not formalized. |
| Thm 4.6(a)–(c) (monotone certifier: lazy bisection; `⌈log₂(1/h)⌉` queries) | `thm:physics:monotone` (a)–(c) | `lazy_bisection_sound`, `lazy_bisection_miss`, `lazy_bisection_resolution`, `mono_lower_bound`, `mono_lower_bound_ceil` | Export | exact | One dimension. "Misses at most length `h`" is formalized as "the missed set contains no interval `[a, b)` with `b − a > h`", which "measure `≤ h`" implies, so the lower bound also covers the measure reading. Lower bound for deterministic adaptive certifiers with an exact oracle. Part (d) (down-sets in `d ≥ 2`, a proof sketch in the paper) and the endpoint-querying variant are not formalized. |
| Prop 1.4(c), Prop 1.6(b),(c), Lemma 1.8(b), Thm 1.9(e), Prop 1.10; Cor 2.2, Thm 2.4 and its corollaries, Thm 2.5, Cor 2.6, Prop 2.7; Thm 3.3(a), Thms 3.5–3.9; Prop 4.2, Thm 4.3, Thm 4.6(d), Prop 4.7; §5 (SPS checker); §6 (worked bridges) | `prop:physics:continuity`, `cor:physics:eternalist`, `thm:physics:realizability`, `cor:physics:immunity`, `thm:physics:soundness`, `cor:physics:blame`, `prop:physics:propagation`, `prop:physics:framerealizability`, `thm:physics:nofree` (a), `thm:physics:neighbourhood`, `thm:physics:gronwall`, `thm:physics:projectile`, `thm:physics:chains`, `thm:physics:stipulation`, `lem:physics:asymptotic`, `thm:physics:conformal`, `thm:physics:monotone` (d), `prop:physics:laymon`, `sec:physics:checker`, `prop:physics:legexact`, `prop:physics:thinleg`, `prop:physics:finitesun` | — | — | — | Not formalized. Prop 4.2 (minimal-repair drift) has no label of its own. |

### T4: informal mathematics (paper: `informal.tex`; §7 in `simplicity.tex`)

| T4 result | paper | Lean | file | faithfulness | notes |
|---|---|---|---|---|---|
| Lemma 4.1 (descent along false lines) | `lem:informal:descent` | `Blame.ArgTree.descend_spec`, `ArgTree.descent_tree`, `ArgTree.moves_lt_depth`, `ArgTree.evals_le_maxPathFanIn`, `ArgTree.descent_tree_not_mem`, `ArgTree.descent_tree_not_semSound`; `LineArg.descent`, `LineArg.descent_depth`, `LineArg.descent_not_mem` | Blame | exact | Tree form (`ArgTree`) and line-list/DAG form (`LineArg`). "h-admissible ⇒ h-invalid" is abstracted as "every valid step preserves v-truth", with the classical instance given. The evaluation bound counts all antecedents of each visited line, so it is an upper bound. The link condition `str(y_i)=str(y_j)` is omitted because descent does not use it. Related to T7 Lemma 2.5, but the (WS) form is not formalized. |
| Thm 4.3(a) (object game, weighted halving) | `thm:informal:objects` (a) | `CoherenceGames.thm_4_3_a`, `thm_4_3_a_uniform`, `majority_pos_halving`, `majority_obj_halving` | CoherenceGames | exact | Finite class, as in Def 4.2 (`def:informal:game`). Part (b) is in the next row. Part (c) (`M_obj = Ldim`) and the merging refinement are not formalized. |
| Thm 4.3(b) (`M_obj ≤ M^{(r)}_bag`, equality at `r = 1`) | `thm:informal:objects` (b) | `ParadoxLowerBound.thm_4_3_b`, `thm_4_3_b_eq` | ParadoxLowerBound | exact | In the correction game of `ParadoxLowerBound`: a deterministic learner is any function from the feedback history to an announcement, and `IsValue Bags H m` says that the optimal worst-case number of corrections is `m`. Arbitrary step types and classes. The inequality is stated for the two values when they exist; their existence is not proved separately. At `r = 1` the two games coincide. |
| Thm 4.4(b) (single-culprit class: `M_obj = 1`, `M^{(r)}_bag = min(r, n−1)`) | `thm:informal:paradoxes` (b) | `ParadoxLowerBound.thm_4_4_b`, `thm_4_4_b_bag_lower`, `thm_4_4_b_bag_upper`, `thm_4_4_b_bag_value`, `thm_4_4_b_unbounded`, `thm_4_4_b_obj_lower`, `thm_4_4_b_obj_upper`, `thm_4_4_b_obj_value`, `card_class`, `forces_of_adversary`, `achieves_of_potential`, `nonSilent_iff` | ParadoxLowerBound | exact | Deterministic learners only; the lower bounds hold against arbitrary history-dependent learners, which is more general than the paper's version-space learners. With unbounded bags (`r = n`), `M_bag = n − 1 = \|𝓗_n\| − 1`. Randomized learners are not treated. |
| Thm 4.4(c) (the chain paradox) | `thm:informal:paradoxes` (c) | `ParadoxLowerBound.thm_4_4_c`, `thm_4_4_c_lower`, `thm_4_4_c_upper`, `thm_4_4_c_value`, `thm_4_4_c_obj_value`, `hypC_coherent`, `chainStep_mem_hypC`, `SemSound_subset_hypC`, `paradox_derivation`, `essential_bag`, `chainBags_eq`, `object_descent`, `object_refutes_iff`, `exists_object` | ParadoxLowerBound | exact | `h_j = Cn_CPC({q_i → q_{i+1} : i ≠ j})` with `q_k = p_k`, read as a set of steps. Every `h_j` is coherent on `{q₀, ¬q_n}`. `essential_bag`: every ⊥-derivation from the context by chain steps and certified steps uses all chain steps, so the only paradox bag is the whole chain. With paradox feedback the value is `n − 1`; with object feedback it is 1, and every admissible object refutes exactly the culprit. Deterministic learners. A generic "chain of obvious lemmas" is covered only through this instance. |
| Thm 4.5 (bags of size ≤ r, super-majority learner) | `thm:informal:bags` | `CoherenceGames.thm_4_5`, `thm_4_5_uniform`, `supermajority_bag`, `sum_not_subset_le` | CoherenceGames | exact (upper bound) | |
| Prop 7.1 (= T5 Thm 3.2, second bullet: rate threshold) | `thm:simplicity:separable` | `RateThreshold.rate_threshold`, `isMinimizer_iff`, `isUniqueMinimizer_iff`, `ties_arbitrary` | RateThreshold | exact | Holds for every real `c` and needs neither `k > 0` nor `r ≥ 0`. |
| Cor 7.2 (selectability criterion) | `cor:simplicity:selectable` | `selectable_iff`, `selectable_iff_fold`, `selectable_iff_sup'_lt_inf'`, `weakly_selectable_iff`, `exists_Sstar_eq_iff` | RateThreshold | exact | |
| Prop 7.3 (rate inversion; "no κ selects the true rule set") | `prop:simplicity:inversion` | `valid_not_minimizer`, `not_selectable`, `rate_inversion`, `Sstar_low/mid/high/top`, `pareto_dominated`, `no_monotone_criterion` | RateThreshold | exact | Stronger than stated: holds for every real `c`, and `{A,B}` is not even a weak minimizer. |
| Prop 7.3 ("adding hypotheses cannot make `{A,B}` a vertex") | `prop:simplicity:inversion` | `valid_never_vertex`, `valid_not_hullVertex` | RateThreshold | weaker | Proved via Pareto dominance by `{A,F}`. The claims that `{A,B}` lies strictly inside the hull of the other subsets and the list of full-hull vertices are not formalized. |
| §2 (sound bounded-gap verification); §3 (identification); Thm 4.3(c), Thm 4.4(a), Props 4.6, 4.6′, the bag-price conjecture, Prop 4.7; §5 (Frege → Russell → Zermelo); §6 (robust core, sorites tightness, emergence of proof) | `sec:informal:verify`, `sec:informal:identify`, `thm:informal:objects` (c), `thm:informal:paradoxes` (a), `prop:informal:products`, `prop:informal:ldim1`, `conj:informal:bagprice`, `prop:informal:barring`, `sec:informal:frz`, `sec:informal:robust` | — | — | — | Not formalized. |

### T5: simplicity and normativity from imitation (paper: `simplicity.tex`)

| T5 result | paper | Lean | file | faithfulness | notes |
|---|---|---|---|---|---|
| Thm 2.1(i), the inequality `max_f ∑_i −log h(f(x_i)\|x_i) ≥ ∑_i H(Q_{x_i})` | `thm:simplicity:pricing` (i) | `NoAdaptation.thm_2_1_i_ennreal`, `thm_2_1_i_ennreal_maxF`, `thm_2_1_i`, `thm_2_1_i_maxF`, `thm_2_1_i_exists`, `gibbs`, `gibbs_eq`, `expLoss_eq_sum_marg`, `margHyp_expLoss` | NoAdaptation | exact | Finite class of labelers on an arbitrary input type, finite label type, inputs `x : I → X` with repeats allowed, natural logarithm. The `[0,∞]`-valued form (`-log 0 = ∞`) is the paper statement verbatim. The real-valued form needs `h` positive on the labels of `supp Q`, because Mathlib's `Real.log 0 = 0`. Also gives the intermediate bound via `E_{f∼Q}` and a witness `f ∈ supp Q`. |
| Thm 2.1(i), the value: upper bound `∑_i log\|C(x_i)\|`, equality criterion, group condition, the example | `thm:simplicity:pricing` (i) | `unifHyp_loss`, `sum_entropy_le_sum_log_card`, `sum_entropy_of_uniform`, `minimax_of_uniform_marginals`, `minimax_of_uniform_marginals_ennreal`, `uniform_marginals_of_transitive`, `minimax_of_transitive`, `Example.no_uniform_marginals`, `Example.value_lt_sum_log_card` | NoAdaptation | weaker | Proved: the uniform hypothesis pays exactly `∑_i log\|C(x_i)\|` against every labeler; if some `Q` has uniform marginals, the minimax value is `∑_i log\|C(x_i)\|`; the group condition gives uniform marginals (no group axioms are needed). For the paper's example, no `Q` has uniform marginals and the value is `< log 3 + log 2`; only the strict bound `log(35/6) < log 6` is proved, not the exact 2.5431 bits. Not formalized: the exact value `max_Q ∑_i H(Q_{x_i})` (needs Sion's minimax theorem), the "only if" direction of the equality criterion, and the parity example. |
| Lemma 3.1(i) (hull⁻ ⇔ minimizes `J_c` for some `c > 0`) | `lem:simplicity:hull` | `RateThreshold.onLowerHull_iff`, `isMinAt_le_of_inHull` | RateThreshold | special case | Finite hypothesis class. Convex hulls are encoded with finite convex weights (`InHull`), because Mathlib's `Convex` library is outside the compiled subset. Stated for points of `A`. |
| Lemma 3.1(ii) (monotonicity in `c`) | `lem:simplicity:hull` | `lemma_3_1_ii` | RateThreshold | exact | Assumes `0 ≤ c`, which is implicit in the paper. |
| Lemma 3.1(iii) (unique minimizer on an interval ⇔ hull vertex) | `lem:simplicity:hull` | `lemma_3_1_iii`, `lemma_3_1_iii_hyp`, `uniquePoint_iff_rates`, `chord_iff_extreme`, `chord_iff_notInOthersHull`, `isHullVertex_iff_extreme` | RateThreshold | special case | Finite class. The hypothesis-level version includes the "no other hypothesis at the same point" condition added after verification (B6). |
| Thm 3.2, first bullet (product classes) | `thm:simplicity:separable` | `prod_isMin_iff`, `prod_isUniqueMin_iff` | RateThreshold | exact | Arbitrary region types. |
| Thm 3.2, second bullet (rate threshold, ties arbitrary) | `thm:simplicity:separable` | `rate_threshold`, `isMinimizer_iff`, `thm_3_2`, `thm_3_2_unique`, `thm_3_2_unique'` | RateThreshold | exact | |
| Thm 4.1(ii) (rate blindness) | `thm:simplicity:blind` | `rate_blindness` | RateThreshold | special case | Only the Thm 3.2 setting. The idealized (Kolmogorov) Thm 3.3 setting is not formalized. |
| Lemma 1.2; Thm 2.1(ii) (Shtarkov), Prop 2.2 (mixtures); Props 2.3, 2.6, Thm 2.4, Lemmas 2.5a–c, Thm 2.5 (the kink); Thm 3.3, Cor 3.4, Thm 3.5, Cor 3.5a; Thm 4.1(i),(iv), Prop 4.2, Thm 4.3, Props 4.4, 4.5; §5 (division of labour) | `lem:simplicity:empirical`, `thm:simplicity:pricing` (ii), (iii), `prop:simplicity:sequence`, `prop:simplicity:block`, `lem:simplicity:listdecode`, `lem:simplicity:corr`, `lem:simplicity:random`, `thm:simplicity:kink`, `thm:simplicity:idealized`, `cor:simplicity:shapes`, `thm:simplicity:example`, `cor:simplicity:example`, `thm:simplicity:blind`, `thm:simplicity:validation`, `prop:simplicity:guard`, `sec:simplicity:division` | — | — | — | Not formalized. Thm 2.4 and Props 4.2, 4.5 have no label of their own (they are cited inline in `sec:simplicity:universal` and `sec:simplicity:pathologies`). Thm 4.1(iii) restates Lemma 3.1. |

### T6: philosophical completeness (paper: `existence.tex`)

`Bilateral` formalizes T6 §2 (positions). Thms 2.2–2.4 are proved for sequents over an
arbitrary type of formulas, as in the notes; Thm 2.6 for the project's term algebra
`Formula`. `Specker` formalizes Thm 3.4 and the probabilistic clause of Prop 4.7, with finite
distributions on the `2^k` Boolean worlds.

| T6 result | paper | Lean | file | faithfulness | notes |
|---|---|---|---|---|---|
| Def 2.1 (Scott relations; `⟨S⟩`; intersections) | no label (text of `sec:existence:positions`) | `Bilateral.isScott_sInter`, `isScott_gen`, `gen_subset`, `gen_eq_derives`, `mem_gen_empty` | Bilateral | exact | Sequents `Γ ▷ Δ` have `Finset` sides over an arbitrary type `α`. `gen_eq_derives`: `⟨S⟩` is the inductive closure under (Ov), (Wk), (Cut). |
| Thm 2.2 (bilateral Lindenbaum) | `thm:existence:bilindenbaum` | `Bilateral.exists_maxCoherent`, `Coherent.disjoint`, `MaxCoherent.exhaustive`, `MaxCoherent.charFn_mem_Val`, `thm_2_2_a`, `thm_2_2_a_max`, `thm_2_2_b`, `coherent_iff_realizable` | Bilateral | exact | Valuations are arbitrary maps `α → Bool`, not necessarily compositional. The Zorn step `exists_maxCoherent` holds for every set of finite sequents; (Ov) and (Cut) are used only to make the maximal position disjoint and exhaustive. |
| Cor 2.3 (strong bilateral completeness `Th(Mod S) = ⟨S⟩`) | `cor:existence:bilateral` | `Bilateral.cor_2_3`, `gen_subset_Th_Val`, `cor_2_3_consOp`, `Val_gen`, `mem_gen_iff`, `isScott_iff_Th_Val_eq`, `isScott_iff_exists_Th` | Bilateral | exact | For every set `S` of sequents. `isScott_iff_Th_Val_eq` is the instance of Prop 1.3 (`prop:existence:image`) for this frame: the Galois-closed sets of sequents are exactly the Scott relations. The generic Galois connection of Fact 1.2 (`lem:existence:galois`) and the closure operator `Th ∘ Mod` are basic facts in `ConsOp` (`ConsOp.subset_Mod_iff_subset_Th`, `ConsOp.ofSat`), not audited separately. |
| Thm 2.4 (the duality, with both closure operators) | `thm:existence:duality` | `Bilateral.Val_Th`, `isClosed_Val`, `Val_Th_of_isClosed`, `Val_subset_Val_iff`, `scottClosedIso` | Bilateral | exact | Syntactic closure: `cor_2_3`. Semantic closure: `Val (Th V) = closure V` in the product topology on `α → Bool`. `scottClosedIso : {R // IsScott R} ≃o {V // IsClosed V}ᵒᵈ`. Remark 2.5 (Stone duality with the filters of the free Boolean algebra) is not formalized. |
| Thm 2.6(a) (structural ⇔ `Val` substitution-invariant) | `thm:existence:structural` (a) | `Bilateral.thm_2_6_a`, `thm_2_6_a_closed`, `structural_gen`, `structuralClosedIso` | Bilateral | special case | Fixed signature: only for the project's term algebra `Formula` (atoms `ℕ`, connectives ⊥ ⊤ ¬ ∧ ∨ →), not for an arbitrary term algebra. Includes the restricted dual isomorphism between structural Scott relations and closed substitution-invariant sets of valuations. |
| Thm 2.6(b) (Lindenbaum matrices `L_v`) | `thm:existence:structural` (b) | `Bilateral.lindenbaum_interp`, `thm_2_6_b_validates`, `thm_2_6_b_eq`, `thm_2_6_b_realize` | Bilateral | special case | Same fixed signature; `LogicalMatrix` is a matrix for exactly this signature, and `lindenbaum v = ⟨Fm, v⁻¹(1)⟩`. |
| §2, link to T2 §4 (truth-table sequents give `BV`) | `lem:coherence:duality`, `thm:coherence:telltale` | `Bilateral.carnap_Val_eq`, `carnap_mrel_eq`, `cor_2_3_mseq`, `Val_gen_TT`, `coherent_TT_iff` | Bilateral | exact | Identifies the multiple-conclusion sequents of `Carnap` with those of `Bilateral`. `Val ⟨TT⟩ = BV`, so a position is coherent for the truth-table sequents iff a Boolean valuation realizes it. |
| Thm 3.4 (no bounded-arity family of coherence constraints suffices) | `thm:existence:arity` | `Specker.thm_3_4`, `not_matchesOn_univ`, `exists_matchesOn`, `thm_3_4_a`, `thm_3_4_b`, `thm_3_4_hence` | Specker | exact | Both a world-level form (`thm_3_4`, `k ≥ 3`) and the formula-level form over the literal agenda `F_k ⊆ Formula`. Part (a) needs no hypothesis on `k`; (b) holds for `k ≥ 2`. `thm_3_4_hence` is the "Hence" clause for an arbitrary family of necessary constraints, each depending only on a sub-agenda over `≤ k − 1` atoms. |
| Remark after Thm 3.4 ("pairwise coherent in the strongest sense") | `thm:existence:arity` (remark after it) | `Specker.Qk_eq_Pk`, `exists_prF_eq_Qk`, `Qk_incoherent`, `two_atom_coherent` | Specker | exact | Stronger than stated: one credence `Qk` on all formulas extends `P_k`, and for every set of `≤ k − 1` atoms a single probability induces `Qk` on every formula over those atoms; `Qk` is still incoherent on `F_k`. |
| Specker's parable (`k = 3`) | `thm:existence:arity` (remark after it) | `Specker.specker_parable` | Specker | exact | The `k = 3` instance, with `P(A_i) = 1/2`. |
| Prop 4.7, probabilistic clause (frustrated triangle) | `prop:existence:triangle` | `Specker.frustrated_triangle` | Specker | exact for this clause | Pair marginals uniform on `{10, 01}` are realized on every sub-agenda over at most two of the three atoms, but by no joint distribution. The logical clause (the theories `Cn₂(a ↔ ¬b)`, `Cn₂(b ↔ ¬c)`, `Cn₂(c ↔ ¬a)` are consistent and pairwise conservative, with inconsistent union) is not formalized. |
| §1 (Prop 1.3 in general, Thms 1.4–1.5, Prop 1.6; of Fact 1.2 only the Galois connection and `Th ∘ Mod` are in `ConsOp`); Remark 2.5; Thm 3.1, Prop 3.2, Ex 3.3, Thm 3.5, Prop 3.6, Thms 3.7–3.8, Cor 3.9, Prop 3.10; §4 except the probabilistic clause of Prop 4.7 (Thm 4.1, Cor 4.2, Props 4.3–4.4, Thms 4.5–4.6); §5 | `sec:existence:galois`, `thm:existence:definetti`, `ex:existence:mp`, `thm:existence:threshold`, `prop:existence:closed`, `thm:existence:gaifman`, `thm:existence:omega`, `cor:existence:inductors`, `prop:existence:vnm`, `sec:existence:contexts`, `sec:existence:learned` | — | — | — | Not formalized. |

### T7: the two-tier coherent inferential learner (paper: `twotier.tex`)

| T7 result | paper | Lean | file | faithfulness | notes |
|---|---|---|---|---|---|
| Lemma 2.3(a) (maximal clean sets = complements of minimal transversals) | `lem:twotier:reiter` | `Blame.isMaxClean_iff`, `isMinTransversal_iff`, `setOf_isMaxClean_eq_image`, `isClean_iff_isTransversal_sdiff`, `isClean_iff_forall_not_subset` | Blame | exact | Finite universe `U`. `K` only needs to be upward closed inside `U`. |
| Lemma 2.3(b) (blame set = ⋃ minimal conflicts = ⋃ minimal transversals; ⋂ maximal clean sets = `U \ ⋃𝒞`, which is clean) | `lem:twotier:reiter` | `exists_minTransversal_mem_iff`, `exists_minTransversal_mem_iff_of_antichain`, `coe_blameSet_eq_iUnion_minTransversal`, `mem_inter_maxClean_iff`, `iInter_maxClean_eq`, `isClean_sdiff_blameSet`, `isClean_iInter_maxClean`, `mem_blameSet_iff_exists_maxClean` | Blame | exact | `∅ ∉ K` is used only for the intersection claims. The first claim holds for any antichain. |
| Lemma 2.3(c) (unique minimal transversal ⇔ all conflicts singletons) | `lem:twotier:reiter` | `existsUnique_minTransversal_iff` | Blame | exact | |
| Lemma 6.1 (closed-instance refutability; ≤ 2^v candidates of size \|τ\|) | `lem:twotier:post` | `Post.schema_invalid_iff_closedRefutation`, `exists_invalid_instance_iff_closedRefutation`, `size_subst_ofVal`, `stepSize_closedInstance_le`, `card_candidates_le`, `mem_candidates`, `mem_SemSound_iff_candidates` | PostCompleteness | exact | Each formula keeps its size exactly. At the level of whole steps the size is only `≤`, because premises form a `Finset` and can merge after substitution. |
| Lemma 2.1, Prop 2.2, Prop 2.4, Remark 2.4′, Lemma 2.5; Lemma 3.1, Props 3.2–3.3; Thm 4.1 (main theorem), Cor 4.2; §5 (Props 5.1–5.4, Thms 5.5–5.7, Prop 5.8); Cor 6.2, Prop 6.3, Lemma 6.4, Cor 6.5, Thm 6.6 | `lem:twotier:onesided`, `prop:twotier:practice`, `prop:twotier:dilemma`, `rem:twotier:bayes`, `lem:twotier:descent`, `lem:twotier:audit`, `prop:twotier:voting`, `prop:twotier:sandbox`, `thm:twotier:main`, `cor:twotier:truth`, `sec:twotier:lower`, `cor:twotier:cpc`, `prop:twotier:coherenceonly`, `lem:twotier:complete`, `cor:twotier:decidable`, `thm:twotier:arith` | — | — | — | Not formalized. Only the combinatorial identity behind Prop 2.4(c), `⋂{maximal candidates} = Σ^P \ ⋃𝒞_d`, is covered (`iInter_maxClean_eq`, `mem_blameSet_iff_exists_maxClean`). Prop 5.8 cites T2 Prop 7.1, which is formalized (`Contexts`, T2 table above). |

## Honest summary of what is *not* formalized

* **Randomized agents.** Randomized verifiers, learners and certifiers are not modelled. Every
  interactive lower bound and minimax value is proved against deterministic agents only: T1 Thm 3.1(b) (without
  the randomized bound `p ≤ δ`), Thm 3.2 (without the `(1−δ)m` bound for δ-sound verifiers) and
  Thm 3.9; T4 Thms 4.3(b) and 4.4(b),(c); T3 Thm 4.4 (without the almost-sure clause), Thm
  4.5(c) and Thm 4.6(c).
* **Probability.** The bound `(1−ε)^m` of T1 Cor 2.2, all of T1 §4 (Bayes-conservative
  verifiers, Ville's inequality) and T4's time-uniform soundness (Thm 2.5) are not
  formalized. Probability appears only as non-negative summable weights on a countable step
  set (T1 Thm 2.1(ii)) and as finite distributions (T5 Thm 2.1(i); T6 Thm 3.4 and Prop 4.7).
* **Minimax theorems.** The exact minimax value `max_Q ∑_i H(Q_{x_i})` in T5 Thm 2.1(i) and the
  "only if" half of its uniform-marginal criterion need Sion's theorem and are not formalized;
  nor are T5 Thm 2.1(ii) (Shtarkov) and Prop 2.2.
* **Countable classes.** T2 Thm 2.2, Prop 2.3 and Thm 2.5, and T5 Lemma 3.1, are proved for
  finite hypothesis classes only. (T1 Thm 3.2 holds for arbitrary classes.)
* **Finite axiomatizability.** "A finite `D` suffices" in T2 Thm 3.3(a), i.e. Kalmár-style
  completeness of the Łukasiewicz / Tarski–Bernays systems, is not formalized.
* **Computability.** Learners are defined classically. No computability or uniform-decidability
  claims are formalized.
* **Real analysis.** No derivatives: smooth bumps are replaced by Lipschitz tents (T3 Thm
  3.3(b), a variant; Thm 4.4), and the link between derivative jets and Taylor coefficients is
  a hypothesis (T3 Thm 3.3(c), a variant). T3 Thm 3.3(a) (the flat function `e^{-1/λ²}`), Thm
  4.6(d) (dimension `d ≥ 2`), the analytic export results (Thms 3.5–3.9: certified
  neighbourhoods, Gronwall, the projectile certificate, error chains) and split-conformal
  calibration (Thm 4.3) are not formalized.
* **First-order semantics.** T3 §1–§2 are formalized only in a propositional toy model: no
  Łoś, no deformation frames over ℝ, no realizability criterion (Thm 2.4), no soundness of the
  context calculus (Thm 2.5, Cor 2.6). The SPS checker (T3 §5) and the worked bridges (§6) are
  not formalized.
* **Language and signature.** Only the connectives {⊥, ⊤, ¬, ∧, ∨, →} are available. As a
  consequence the truth-table tell-tale in T2 Thm 4.4 has 13+1 data instead of 11+1, and T6
  Thm 2.6 is proved for this one term algebra only. T6 Thms 2.2–2.4 are proved for an
  arbitrary type of formulas.
* **Not touched at all:** T1 §1.3 (anti-unification), Props 2.3–2.4, Prop 3.3, Thm 3.4,
  Prop 3.5, Thms 3.6–3.7, Conj 3.8, §4, and §§5–6 except the positive-data lemma; T2 Thm 2.6,
  Props 2.7–2.9, Prop 3.2, Prop 3.4, Thms 3.6–3.10, Prop 3.11, Props 4.5–4.6, §§5–6; T3 Prop
  1.10, §2 except Thm 2.1, Thms 3.5–3.9, Props 4.2, 4.7, Thm 4.3, §§5–6; T4 §§2–3, Thm 4.3(c),
  Thm 4.4(a), Props 4.6, 4.6′, 4.7, §§5–6; T5 Lemma 1.2, §2 except Thm 2.1(i), Thm 3.3, Cor
  3.4, Thm 3.5, Cor 3.5a, §4 except Thm 4.1(ii), §5; T6 §1 except the Galois connection and
  the bilateral instance of Prop 1.3, Remark 2.5, §3 except Thm 3.4, §4 except the
  probabilistic clause of Prop 4.7, §5; T7 everything except Lemmas 2.3 and 6.1, in
  particular the main theorem (Thm 4.1) and the necessity results of §5.
* **Not machine-checked:** the Python checks under `research/theory/*-checks/`. Where a Lean
  theorem covers the same claim in general (e.g. T2 §4's enumeration of the denial rank), the
  Lean proof supersedes them.
