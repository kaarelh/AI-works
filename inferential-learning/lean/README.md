# InfLearn: Lean 4 formalization of the inferential-learning theory

This directory contains a Lean 4 / Mathlib formalization of selected theorems from the
theory notes in `../research/theory/T1-…T7-*.md`. The paper (`../paper/`) is built from
those notes. The formalization has

* no `sorry`, no `axiom` declarations, no `native_decide`, no `admit`, no `opaque` or
  `implemented_by`;
* 0 errors and 0 warnings in `lake build`;
* every audited declaration depends only on Lean's standard axioms `propext`,
  `Classical.choice` and `Quot.sound`. See `audit-output.txt`.

About 14,600 lines of Lean in 17 modules, plus `Audit.lean`.

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
including the foundations and every theorem listed in the tables below. It is a separate
`lean_lib` target named `Audit`. Its output, from `lake build Audit` with a header and a
computed summary added, is in `audit-output.txt`. Summary:

| axioms reported | declarations |
|---|---|
| `propext, Classical.choice, Quot.sound` | 429 |
| `propext, Quot.sound` | 42 |
| `propext` | 10 |
| none | 2 |
| `sorryAx` or any non-standard axiom | **0** |

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
  every interactive lower bound (T1 Thms 3.1(b), 3.2, 3.9; T4 Thm 4.4; T3 Thms 4.4–4.6) is
  proved against deterministic agents only.
* **Real analysis.** Derivatives and `ContDiff` are outside the compiled Mathlib subset. So
  `Export` replaces the paper's smooth bumps by Lipschitz tents `max 0 (r - dist x c)`, and
  takes the link between derivative jets and polynomial coefficients as a hypothesis (T3
  Thm 3.3(b),(c)). Polynomials (`Mathlib.Algebra.Polynomial`), metric spaces, `Real.log`, the
  product topology and `ENNReal` are available.

## Theorem map

Faithfulness legend:

* **exact**: the paper statement, possibly in a slightly more general form.
* **special case**: a strict special case of the paper statement, as described in the notes
  column.
* **weaker**: a weaker conclusion than the paper claims.
* **variant**: a closely related statement whose hypothesis is neither stronger nor weaker
  than the paper's (used once, for T3 Thm 3.3(b), where tents replace smooth bumps).
* **—**: not formalized.

The *paper* column gives the LaTeX label in `../paper/sections/*.tex` and the number that
label currently gets in the draft. Numbers are computed from the section order in
`paper/main.tex` and from the current drafts, so they will change as the paper evolves; the
labels are the stable reference. The computation counts the numbered environments (theorem,
lemma, proposition, corollary, conjecture, definition, example, assumption and remark share
one counter per section) in each section file. Each `\input` in `main.tex` counts as one
section, including files not yet written (`intro` = §1, `experiments` = §12, `open` = §14).
In this numbering the sections are: setting §2, search §3, caution §4, imitation §5,
coherence §6, two-tier §7, simplicity §8, existence §9, informal §10, physics §11 and
philosophy §13. The paper's source tags (`\src{T… …}`) were used to match notes to labels.
Numbers were last recomputed on 2026-10-03, after the coherence, two-tier, simplicity and
existence sections were drafted.

### Foundations (paper §2)

| source | paper | Lean | file | faithfulness | notes |
|---|---|---|---|---|---|
| T1 §1.1 closure facts | `lem:setting:closure` (Lemma 2.3) | `InfLearn.Derivable`, `Cl_eq_sInter`, `ClOp`, `ClOp_finitary`, `Cl_mono_rules`, `subset_Sound`, `Cl_subset_Cl_iff_subset_Sound` | Steps | exact | `Cl_{Sound R} = Cl_R` follows at once from `Cl_subset_Cl_iff_subset_Sound` with `subset_Sound`, but is not stated as its own lemma. |
| compactness of CPC | used throughout | `InfLearn.compactness`, `Cn2_finitary` | Prop/Basic | exact | Proved from scratch. Not assumed. |

### T1: soundness under search (paper §3 "search" and §4 "caution")

| T1 result | paper | Lean | file | faithfulness | notes |
|---|---|---|---|---|---|
| Lemma 1.1 (reasoner soundness = stepwise soundness) | `lem:search:stepwise` (Lemma 3.1) | `StepSoundness.lemma_1_1`, `concl_not_derivable_of_not_mem_Sound`, `reasoner_sound_of_subset` | StepSoundness | exact | Any judgment type `J`. The paper cites the underlying `Cl_subset_Cl_iff_subset_Sound` via `\leanok`. |
| Thm 2.1(i) (tonk beyond the horizon) | `thm:search:tonk` (Thm 3.2) | `thm_2_1_i`, `thm_2_1_i_univ`, `thm_2_1_i_derivation`, `thm_2_1_unsound`, `T_not_subset_Sound` | StepSoundness | exact | Explicit linear derivation of exactly `j+2` steps; only the last step is in `T_j`, and it is unsound for every non-tautologous `C`. Holds for every `R ⊇ {⊤I, ∧I, ∨I₂}`. Convention: `T 0 = T 1`. |
| Thm 2.1(ii) (`Q(T_j) → 0`) and the concluding sentence | `thm:search:tonk` | `thm_2_1_ii`, `T_disjoint`, `thm_2_1_error_and_trivial` | StepSoundness | exact | `Q` is any non-negative summable weight on the countable step set, which covers every probability distribution on it. Finitely additive set functions are not treated. |
| Thm 2.1, last sentence (finitely many pure schemas) | `thm:search:tonk` | `Rstar_sound`, `Rstar_eq_substClosure`, `T_eq_substClosure`, `Rstar_union_T_eq_substClosure` | StepSoundness | exact | |
| Cor 2.2 (PAC learners can be maximally unsound) | `cor:search:pac` (Cor 3.3) | `cor_2_2_trivializes` | StepSoundness | weaker | Only the deterministic core: every output `L ∪ Rbase ∪ T_j` trivializes. The bound `Pr[Q(T_ĵ) > ε] ≤ (1−ε)^m` is not formalized. |
| Prop 2.3 (every unsound pure schema is a tonk) | `prop:search:post` (Prop 3.5) | — | — | — | Not stated as such. Its consequence-operator core is T2 Thm 3.1 (`Post.eq_Cn2_or_eq_trivial`). |
| Thm 3.1(a) (VS verifier is 0-sound, uniformly) | `thm:caution:vs` (Thm 4.2) | `thm_3_1_a`, `target_mem_VSh`, `vsVerifier_acc_iff/rej_iff/esc_iff`, `thm_3_1_a_reasoner`, `vsVerifier_reasoner_sound`, `thm_3_1_a_static` | StepSoundness | exact | The interactive protocol is modelled explicitly: histories, the escalation oracle, and adaptive provers `History → Step` that may depend on `R*`. |
| Thm 3.1(b) (optimality) | `thm:caution:vs` (Thm 4.2) | `thm_3_1_b`, `vsVerifier_optimal`, `thm_3_1_b_closure`, `vsVerifierSound_optimal` | StepSoundness | special case | Deterministic verifiers only. This is the paper's explicit deterministic corollary. The randomized joint-probability bound `p ≤ δ` and the reckless-mode counterexample are not formalized. |
| Thm 3.1, static form; positive-data lemma | `lem:imitation:cautious` (Lemma 5.2) (a), (b) | `thm_3_1_a_static`, `thm_3_1_b_static`, `subset_sInter_VS_iff`, `reasoner_sound_for_all_VS_iff` | StepSoundness | exact for (a), (b) | Parts (c) (monotonicity in `D`) and (d) (lgg) of the paper lemma are not formalized. |
| Lemmas 1.2–1.3, Thm 3.2–Cor 6.5, Props 2.4, 3.3, 3.5, 6.6 (anti-unification, escalation dimension, Bayes/Ville, anchors, noise) | §2, §4, §5 | — | — | — | Not formalized. |

### T2: coherence as negative data (paper §3, §6 "coherence" [not yet drafted], §11)

| T2 result | paper | Lean | file | faithfulness | notes |
|---|---|---|---|---|---|
| Lemma 2.1 (negative bag), bullets 1–2 | §6 (planned) | `CoherenceGames.negative_bag`, `refuted_of_superset` | CoherenceGames | exact | Any judgment type. Bullet 3 (logical vs. witness refutation) is not formalized. |
| Thm 2.2(i),(ii) (oligarchic halving: target survives, `D ≤ log₂ 1/w(R*)`) | §6 (planned) | `thm_2_2`, `thm_2_2_of_derivations`, `thm_2_2_uniform`, `oligarchic_halving`, `halving_bound*`, `weight_le_pow_mul` | CoherenceGames | special case | Finite hypothesis class (`Fintype ι`) with non-negative, unnormalized weights; the bound has the form `2^D·w(R*) ≤ w(𝓗)`. The paper allows countable classes. `thm_2_2_of_derivations` derives legality of (N)-rounds from genuine ⊥-derivations, via Lemma 2.1. |
| Thm 2.2(iii),(iv) | §6 (planned) | `thm_2_2_iii_iv` | CoherenceGames | exact | |
| Prop 2.3 (per-round halving ⇔ coalition) | §6 (planned) | `prop_2_3` | CoherenceGames | special case | Finite version space only. The countable / σ-additive case is not formalized. |
| Thm 2.4 (doctrinal paradox) + Claim + Caveat | `thm:search:doctrinal` (Thm 3.12) | `thm_2_4`, `thm_2_4_memberships`, `mem_majority_three`, `thm_2_4_environment`, `thm_2_4_constant_environment`, `thm_2_4_caveat`, `Sound_hyp` | CoherenceGames | exact | The second caveat bullet (complete texts eventually refute every wrong hypothesis) is not formalized. |
| Thm 2.5 (robust version, Littlestone–Warmuth) | §6 (planned) | `thm_2_5` | CoherenceGames | special case | Finite class. The coalition may be any index set. |
| Thm 3.1 (Post completeness: structural `C ⊇ 𝐂₂` is `𝐂₂` or trivial) | §6 (planned) | `Post.eq_Cn2_or_eq_trivial`, `structural_extensions_Cn2`; fragments: `frag_eq_Cn2F_or_eq_trivial`, `frag_postComplete_neg`, `impFrag_postComplete` | PostCompleteness | exact (connectives ⊆ {⊥,⊤,¬,∧,∨,→}) | No finitarity is assumed. The fragment theorem covers every `L` that contains → or contains ¬ together with ∧ or ∨; this includes the paper's `{→}` case. Extra Boolean connectives are not representable. |
| Prop 3.2 (theorem-free fragment, `C_ai`) | §6 (planned) | — | — | — | Not formalized. |
| Thm 3.3 (coherence pins CPC), core step | §6 (planned) | `eq_Cn2_of_coherent`, `eq_Cn2_of_consistent`, `eq_Cn2_of_satisfiable_coherent`, `eq_Cn2_iff_exists_coherent` | PostCompleteness | exact | |
| Thm 3.3(a) (finite collapse) | §6 (planned) | `versionSpace_eq_singleton_iff` | PostCompleteness | weaker | `S(D,A₀) = {𝐂₂} ⇔ ⟨D⟩ = 𝐂₂` is proved for arbitrary `D` and arbitrary (also infinitary) hypotheses. The claim "a finite `D` suffices" (Łukasiewicz / Tarski–Bernays bases + MP generate `𝐂₂`) needs a Kalmár-style completeness proof and is **not** formalized. |
| Thm 3.3(b) (identification without bias, ≤ i* mind changes) | §6 (planned) | `learner_identifies`, `learner_mindChanges_le` | PostCompleteness | exact (computability not formalized) | Holds for every ordering of the family and every text. The learner is defined classically (`Nat.find`), so the "uniformly decidable" hypothesis is dropped and computability of `M` is not shown. |
| Thm 3.3(c) bullets 1–2 (structurality and a coherence datum are needed) | §6 (planned) | `Cn2Add_not_structural`, `Cn2_le_Cn2Add`, `Cn2Add_validates`, `Cn2Add_consistent`, `Cn2Add_ne_Cn2`, `trivial_validates`, `trivial_ne_Cn2` | PostCompleteness | exact | Bullet 3 (`C_ai`) is not formalized. |
| Prop 3.5(a), consequence ("largest structural `C` with theorems Taut is `𝐂₂`") | §6 (planned) | `le_Cn2_of_empty_eq_Taut` | PostCompleteness | special case | `C_adm` (Prop 3.4) is not defined. Only the stated corollary is proved. |
| Lemma 4.1(a) (`Val(⊨ᵐ_V) = closure V`) | §6 (planned) | `Carnap.Val_mrel`, `mrel_closure`, `mrel_eq_iff_closure_eq`, `eq_of_mrel_eq` | Carnap | exact | Uses Mathlib's product topology on `Formula → Bool`. |
| Lemma 4.1(b) (`C_V` finitary; single-conclusion valuations = `V^∩`) | §6 (planned) | `lemma_4_1_b`, `SVal_eq_intClosure`, `isClosed_CV_iff`, `SValS_srel`, `SCons_eq_of_subset_intClosure` | Carnap | exact | Finitarity via Tychonoff compactness. `SVal_eq_intClosure` is an infinite-premise version that needs no closedness hypothesis. |
| Lemma 4.1(c) (`BV^∩` = CPC theories) | §6 (planned) | `mem_intClosure_BV_iff`, `intClosure_BV_eq` | Carnap | exact | |
| Thm 4.2 (Carnap 1943, learning form) + bullets | §6 (planned) | `carnap_single`, `carnap_single_vtop`, `carnap_single_vTaut`, `carnap_problem`, `carnap_vtop`, `carnap_vTaut`, `mem_intClosure_BV_diff_BV_iff`, `intClosure_BV_and`, `consistent_nonBoolean_violates`, `isClosed_intClosure_BV`, `intClosure_BV_structural` | Carnap | exact | `v_⊤` is separated by `p,¬p ▷ ∅`, not by `∅ ▷ p,¬p` (`MCons_vtop_excludedMiddle`), in line with verification note C2. |
| Thm 4.2, "no learner…" | §6 (planned) | `carnap_not_learnable_single` | Carnap | special case | Stated for texts of the single-conclusion relation. Other presentations are covered only because the relations are equal. The local reading of ND metarules (→I excludes `v_Taut`) is not formalized. |
| Thm 4.3 (denial-rank trichotomy) | §6 (planned) | `denialRank_eq_zero_iff`, `_one_iff`, `_two_iff`, `_top_iff`, `denialRank_le_two_of_not_mem_BV`, `denialRank_vtop`, `denialRank_vTaut` | Carnap | exact | |
| Thm 4.4(a) (`Val(TT) = BV`) | §6 (planned) | `Val_TTall`, `isClosed_BV`, `mrel_eq_mrel_BV_iff` | Carnap | exact (adapted) | TT has 13 schemata, the paper's 11 plus `⊥ ▷` and `▷ ⊤`, because the language contains the constants ⊥ and ⊤. |
| Thm 4.4(b),(c) (finite tell-tale among structural meanings; finite identification) | §6 (planned) | `structural_eq_BV`, `finite_telltale_structural`, `empty_survives`, `ttLearner_finite_identification` | Carnap | exact (adapted) | The tell-tale has 13+1 data rather than 11+1, for the same reason. Necessity of each individual datum is not formalized. |
| Thm 4.4(d) (no tell-tale; BV not BC-learnable; density) | §6 (planned) | `no_finite_telltale`, `not_BCIdentifies_of_no_telltale`, `exists_locking`, `BV_not_BC_learnable`, `BV_not_BC_learnable_meaning`, `BV_not_determined_nonstructural` | Carnap | exact | Includes a full Blum–Blum locking-sequence argument. Learners are noncomputable and texts may contain pauses. |
| Props 4.5, 4.6; Thms 2.6, 3.6–3.10; Props 2.7–2.9, 3.4, 3.11; §5; §6 | §6 (planned) | — | — | — | Not formalized. |
| Prop 7.1 (mis-designation forces global sub-classicality) | `prop:physics:misdesignation` (Prop 11.10) | `Contexts.not_Cn2_le_of_consistent_unsat`, `not_Cn2_le_of_coherent_unsat`, `misdesignation_not_Cn2_le`, `closure_eq_univ_of_unsat`, `exists_invalid_step`, `exists_invalid_schema`, `atomic_paraconsistent`, `atomic_nontrivial` | Contexts | exact | Part (a) needs no structurality, so it is slightly more general than the paper. |

### T3: contexts, idealization, export (paper §11 "physics")

All T3 results are formalized in a **propositional toy model**: parameter points are Boolean
valuations, sentences are propositional formulas, `dom` is the set of all valuations, and a
context is an arbitrary filter on valuations. The first-order deformation frames over real
parameters (T3 Def 1.1) are not formalized. Thm 2.1's argument uses only filter structure and
properness, and it is proved for arbitrary proper filters.

| T3 result | paper | Lean | file | faithfulness | notes |
|---|---|---|---|---|---|
| Prop 1.4(a),(b) (Th(c) is `𝐂₂`-closed; consistent iff proper) | `prop:physics:los` (Prop 11.3) | `cn2_closed_ThIn`, `consistent_ThIn_iff`, `satisfiable_ThIn_iff` | Contexts | special case | Propositional. Part (c) (Łoś, ultraproducts) is not formalized. |
| Prop 1.5 (SUP is exact discharge) | `prop:physics:sup` (Prop 11.4) | `holdsIn_sup_iff`, `sup_not_proper_iff` | Contexts | special case | Propositional. |
| Prop 1.6(a) (contradicting the root) | `prop:physics:idealized` (Prop 11.5) | `patm_example` | Contexts | special case | A concrete propositional DEF child that deforms atom 0. Parts (b),(c) (rope, germ vs. limit) are not formalized. |
| Lemma 1.8(a) (import soundness) | `lem:physics:import` (Lemma 11.7) | `import_sound`, `defFilter_pure_pure`, `dStable_of_disjoint` | Contexts | special case | Propositional. Part (b) and the scope remark are not formalized. |
| Thm 1.9(a),(b),(c),(d) (reductio hygiene) | `thm:physics:hygiene` (Thm 11.18) | `refutation_sound_in_context`, `proper_not_both_refuted`, `refutes_of_inconsistent`, `hygiene_*`, `derivation_local_test_accepts_both`, `certificate_refutes_false`, `certificate_not_both`, `certificate_rules_needed` | Contexts | exact for (b)–(d); special case for (a) | (a) is in filter semantics. (c): the satisfiability facts are for distinct atoms `A = p_a`, `q = p_b`; they fail for arbitrary formulas (e.g. `A = ⊤`). (e) is informal and not formalized. |
| Thm 2.1 (no truth-functional eternal reading) | `thm:physics:eternalism` (Thm 11.8) | `not_exists_truthFunctional_reading`, `no_truthFunctional_eternal_reading`, `eternal_reading_witnesses`, `stripping_fails`, `conditionalizing_fails`, `tracksAt_conditional_of_not_proper`, `no_eternal_reading_pure`, `no_eternal_reading_modelClass` | Contexts | special case | Arbitrary proper context filter over propositional valuations. `tracksAt_conditional_of_not_proper` shows that the properness hypothesis is needed. |
| Prop 1.10, Cor 2.2, Thm 2.4, Thm 2.5, Cor 2.6, Prop 2.7, §3–§6 | §11 | — | — | — | Not formalized. |

### T4: informal mathematics (paper §10 "informal", §8 "simplicity" [not yet drafted])

| T4 result | paper | Lean | file | faithfulness | notes |
|---|---|---|---|---|---|
| Lemma 4.1 (descent along false lines) | `lem:informal:descent` (Lemma 10.20) | `Blame.ArgTree.descend_spec`, `ArgTree.descent_tree`, `ArgTree.moves_lt_depth`, `ArgTree.evals_le_maxPathFanIn`, `ArgTree.descent_tree_not_mem`, `ArgTree.descent_tree_not_semSound`; `LineArg.descent`, `LineArg.descent_depth`, `LineArg.descent_not_mem` | Blame | exact | Tree form (`ArgTree`) and line-list/DAG form (`LineArg`). "h-admissible ⇒ h-invalid" is abstracted as "every valid step preserves v-truth", with the classical instance given. The evaluation bound counts all antecedents of each visited line, so it is an upper bound. The link condition `str(y_i)=str(y_j)` is omitted because descent does not use it. Related to T7 Lemma 2.5, but the (WS) form is not formalized. |
| Thm 4.3(a) (object game, weighted halving) | `thm:informal:objects` (Thm 10.22) | `CoherenceGames.thm_4_3_a`, `thm_4_3_a_uniform`, `majority_pos_halving`, `majority_obj_halving` | CoherenceGames | exact for (a) | Finite class, as in Def 4.2. Parts (b), (c) (`M_obj ≤ M_bag`, `M_obj = Ldim`) and the merging refinement are not formalized. |
| Thm 4.5 (bags of size ≤ r, super-majority learner) | `thm:informal:bags` (Thm 10.24) | `thm_4_5`, `thm_4_5_uniform`, `supermajority_bag`, `sum_not_subset_le` | CoherenceGames | exact (upper bound) | |
| Prop 7.1 (= T5 Thm 3.2, second bullet: rate threshold) | §8 (planned) | `RateThreshold.rate_threshold`, `isMinimizer_iff`, `isUniqueMinimizer_iff`, `ties_arbitrary` | RateThreshold | exact | Holds for every real `c` and needs neither `k > 0` nor `r ≥ 0`. |
| Cor 7.2 (selectability criterion) | §8 (planned) | `selectable_iff`, `selectable_iff_fold`, `selectable_iff_sup'_lt_inf'`, `weakly_selectable_iff`, `exists_Sstar_eq_iff` | RateThreshold | exact | |
| Prop 7.3 (rate inversion; "no κ selects the true rule set") | §8 (planned) | `valid_not_minimizer`, `not_selectable`, `rate_inversion`, `Sstar_low/mid/high/top`, `pareto_dominated`, `no_monotone_criterion` | RateThreshold | exact | Stronger than stated: holds for every real `c`, and `{A,B}` is not even a weak minimizer. |
| Prop 7.3 ("adding hypotheses cannot make `{A,B}` a vertex") | §8 (planned) | `valid_never_vertex`, `valid_not_hullVertex` | RateThreshold | weaker | Proved via Pareto dominance by `{A,F}`. The claims that `{A,B}` lies strictly inside the hull of the other subsets and the list of full-hull vertices are not formalized. |
| §2, §3, §5, §6; Thm 4.4, Props 4.6, 4.6′, 4.7 | §10 | — | — | — | Not formalized. |

### T5: simplicity and normativity from imitation (paper §8 "simplicity" [not yet drafted])

| T5 result | paper | Lean | file | faithfulness | notes |
|---|---|---|---|---|---|
| Lemma 3.1(i) (hull⁻ ⇔ minimizes `J_c` for some `c > 0`) | §8 (planned) | `onLowerHull_iff`, `isMinAt_le_of_inHull` | RateThreshold | special case | Finite hypothesis class. Convex hulls are encoded with finite convex weights (`InHull`), because Mathlib's `Convex` library is outside the compiled subset. Stated for points of `A`. |
| Lemma 3.1(ii) (monotonicity in `c`) | §8 (planned) | `lemma_3_1_ii` | RateThreshold | exact | Assumes `0 ≤ c`, which is implicit in the paper. |
| Lemma 3.1(iii) (unique minimizer on an interval ⇔ hull vertex) | §8 (planned) | `lemma_3_1_iii`, `lemma_3_1_iii_hyp`, `uniquePoint_iff_rates`, `chord_iff_extreme`, `chord_iff_notInOthersHull`, `isHullVertex_iff_extreme` | RateThreshold | special case | Finite class. The hypothesis-level version includes the "no other hypothesis at the same point" condition added after verification (B6). |
| Thm 3.2, first bullet (product classes) | §8 (planned) | `prod_isMin_iff`, `prod_isUniqueMin_iff` | RateThreshold | exact | Arbitrary region types. |
| Thm 3.2, second bullet (rate threshold, ties arbitrary) | §8 (planned) | `rate_threshold`, `isMinimizer_iff`, `thm_3_2`, `thm_3_2_unique`, `thm_3_2_unique'` | RateThreshold | exact | |
| Thm 4.1(ii) (rate blindness) | §8 (planned) | `rate_blindness` | RateThreshold | special case | Only the Thm 3.2 setting. The idealized (Kolmogorov) Thm 3.3 setting is not formalized. |
| §2 (Thms 2.1, 2.4, 2.5, …), Thm 3.3, Cor 3.4, Thm 3.5, Thm 4.3, Props 4.2–4.5, §5 | §8 (planned) | — | — | — | Not formalized. |

### T6: philosophical completeness

Not formalized.

### T7: the two-tier coherent inferential learner (paper §7 "twotier" [not yet drafted])

| T7 result | paper | Lean | file | faithfulness | notes |
|---|---|---|---|---|---|
| Lemma 2.3(a) (maximal clean sets = complements of minimal transversals) | §7 (planned) | `Blame.isMaxClean_iff`, `isMinTransversal_iff`, `setOf_isMaxClean_eq_image`, `isClean_iff_isTransversal_sdiff`, `isClean_iff_forall_not_subset` | Blame | exact | Finite universe `U`. `K` only needs to be upward closed inside `U`. |
| Lemma 2.3(b) (blame set = ⋃ minimal conflicts = ⋃ minimal transversals; ⋂ maximal clean sets = `U \ ⋃𝒞`, which is clean) | §7 (planned) | `exists_minTransversal_mem_iff`, `exists_minTransversal_mem_iff_of_antichain`, `coe_blameSet_eq_iUnion_minTransversal`, `mem_inter_maxClean_iff`, `iInter_maxClean_eq`, `isClean_sdiff_blameSet`, `isClean_iInter_maxClean`, `mem_blameSet_iff_exists_maxClean` | Blame | exact | `∅ ∉ K` is used only for the intersection claims. The first claim holds for any antichain. |
| Lemma 2.3(c) (unique minimal transversal ⇔ all conflicts singletons) | §7 (planned) | `existsUnique_minTransversal_iff` | Blame | exact | |
| Lemma 6.1 (closed-instance refutability; ≤ 2^v candidates of size \|τ\|) | §7 (planned) | `Post.schema_invalid_iff_closedRefutation`, `exists_invalid_instance_iff_closedRefutation`, `size_subst_ofVal`, `stepSize_closedInstance_le`, `card_candidates_le`, `mem_candidates`, `mem_SemSound_iff_candidates` | PostCompleteness | exact | Each formula keeps its size exactly. At the level of whole steps the size is only `≤`, because premises form a `Finset` and can merge after substitution. |
| Lemma 2.5, Thm 4.1 (main theorem), Props 2.2, 2.4, 3.2–3.3, 5.1–5.8, Thms 5.5–5.7, Cor 6.2, 6.5, Thm 6.6 | §7 (planned) | — | — | — | Not formalized. Only the combinatorial identity behind Prop 2.4(c), `⋂{maximal candidates} = Σ^P \ ⋃𝒞_d`, is covered (`iInter_maxClean_eq`, `mem_blameSet_iff_exists_maxClean`). |

## Honest summary of what is *not* formalized

* **Probability and randomness.** The randomized forms of T1 Thm 3.1(b) and T1 Cor 2.2, and
  all of T1 §4 (Bayes/Ville), are not formalized. T1 Thm 2.1(ii) uses the pmf form of a
  distribution.
* **Countable classes.** T2 Thm 2.2, Prop 2.3 and Thm 2.5, and T5 Lemma 3.1, are proved for
  finite hypothesis classes only.
* **Finite axiomatizability.** "A finite `D` suffices" in T2 Thm 3.3(a), i.e. Kalmár-style
  completeness of the Łukasiewicz / Tarski–Bernays systems, is not formalized.
* **Computability.** Learners are defined classically. No computability or uniform-decidability
  claims are formalized.
* **First-order and real-parameter semantics.** T3 is formalized only in a propositional toy
  model: no Łoś, no deformation frames over ℝ, no export or certification results (§3–§6).
* **Language.** Only the connectives {⊥, ⊤, ¬, ∧, ∨, →} are available. As a consequence the
  truth-table tell-tale in T2 Thm 4.4 has 13+1 data instead of 11+1.
* **Not touched at all:** T1 §§3.2–6, T2 §§2.6–3.11 except the items above, T2 §§5–6,
  T3 §§3–6, T4 §§2, 3, 5, 6, T5 §§2, 4–5, all of T6, and T7's main theorem and lower bounds.
* **Not machine-checked:** the Python checks under `research/theory/*-checks/`. Where a Lean
  theorem covers the same claim in general (e.g. T2 §4's enumeration of the denial rank),
  the Lean proof supersedes them.
