# Track "experiments": implementing DTRC and testing it — final record (v2)

This is the complete, corrected record of the experiments track, revised after the adversarial referee's report
(`referee.md`; independent checks in `referee_checks/`). It supersedes `notes.md` (v1), which is kept unchanged. The
verification log (§8) lists every referee point and its resolution.

Status labels:
- **proved**: complete proof given here;
- **computed**: a script was run; the command and output file are named;
- **known**: literature or the prior work in `research/prior/`;
- **conjecture**.

Code: `axiom-schemas/code/` (package `dtrc/`, tests `tests/`, experiments `experiments/`, results `results/`; v1
results in `results_v1/`). Every number below comes from `sh run_all.sh` (593 s wall time on 4 shared cores) plus
`python3 experiments/e10_pairtable.py 100` and `python3 experiments/e9b_nosimplify.py` (a few seconds) and the re-run
of the referee's oracle checks
(`sh experiments/recheck/run_recheck.sh`). Unit tests: `python3 -m pytest -q tests` gives 43 passed.

Independence from the other tracks: I depend on no unfinished result. Overlaps, proved here independently for my
formulation: Prop E1-lit/E1-al with the single track's Thm B; Prop E6 with the cases track's Thm B1; Thm E4, Cor E8.3
and the cross-merge tables of Prop E8 with the untagged track's §5.2 and §7 (its separation condition RS_d and its
computed tables u1/u4, for a closure-normal formulation that strips leading ∀); the UnionW/PowerW pair of Prop E9 is
taken from the untagged track's Prop 7.1.

---------------------------------------------------------------------------------------------------------

## 0. Findings in brief

1. **Q1 (∀xφ from instances φ(t))** (computed, E1; proved, Prop E7).
   - First-order lgg and the DT°_F cautious verifier both learn the *instance schema* φ(?t) and agree run by run.
     Exact iff the substituted terms do not all share a head symbol (Plotkin's (R)); observed mean number of instances
     3.27 vs predicted 3.25 (numerals, closed terms, parameters) and 8.42 vs 8.11 (numerals only; one sample, 1.85 SE).
   - In closure-normal form the learned schema accepts φ(w) with w a parameter, i.e. ∀xφ in parameter form. Leading
     ∀ are not stripped, so the string ∀x(x+0=x) is a different datum (the axiom Q4), not an instance of ?t+0=?t (§1.1).
   - From numerals alone, x+0=x and 0+x=x both need the same anchor 0+0=0 (Prop E7, Prop E4-share).
2. **Q2 (each ZF schema from its instances)** (computed, E2).
   - The DT°_F learner is exact on Separation, Replacement (∃! spelled out) and ∈-induction from 2–3 instances
     (23–27/30 runs at N=2, 30/30 at N=8) and on PA induction (25/30 at N=2, 30/30 from N=3); 0 non-target sentences
     in 927 probes.
   - The genuine (term-level) pattern lgg is also sound and exact on the three ZF schemas (EInd slightly later: 24/30
     at N=2 vs 27/30), and never exact on PA induction (prior C9: T12; here 224 of 229 probes non-target, 58 refuted).
   - First-order lgg is unsound on Separation (capture of b), Replacement and induction in both encodings, and on
     ∈-induction in the named encoding; it is sound and complete on ∈-induction in de Bruijn indices (Prop E6).
3. **Q3 (many schemas, no labels: DTRC)** (computed, E3–E5, E9, E10; proved, Thm E4, Props E4-share, E8).
   - **Theory.** Under refutation separation (S), DTRC returns the true partition and is target-sound, and exact per
     target whenever the target's data contain an anchor (Thm E4). For the PA-mix and ZF-mix targets, (S) holds with an
     ideal refuter for all unambiguous data: every cross pair has only minimal templates with an explicit false instance
     (Prop E8, Cor E8.2; this proves v1's conjecture for the mixes). A sharing pass extends this to ambiguous data and
     makes DTRC as good as the tagged learner with membership labels (Prop E4-share).
   - **Experiments (5 seeds each).** ARI 1.0 on PA-mix and ZF-mix in every run; 0 non-target probes. Schema-level
     exactness, numerals-only PA (the task's regime): DTRC 13/20 = tagged with gold labels 13/20; DTRC+share 17/20 =
     tagged with membership labels 17/20. v1 distribution: 19/20, 20/20, 20/20. ZF-mix: 15/15 for all. Single axioms
     35/35 and 30/30 (they stay singletons). The examples-to-exactness curves of DTRC+share and the membership-tagged
     learner coincide (E5).
   - **Evidence for separation is narrow.** Thousands of sampled cross merges reduce to 15 (PA-mix) and 5 (ZF-mix)
     distinct minimal templates, refuted by ⊥, ∀x̄⊥, ⊤→⊥ or a comprehension instance (E9). That is what Prop E8
     proves; it is no evidence for similar targets.
4. **What fails** (computed, E4, E9; proved, Props E9, E10, Lemma V).
   - **A false sentence is accepted.** With injected mistakes (PA-mix seed 0) two mistakes merge into a false
     template, and DTRC accepts the false sentence q_F at refuter budgets 80 and 400 (Prop E10, found by the referee;
     v1's claim "PA mistakes merge only into valid templates" is withdrawn). The v2 oracle refutes q_F (case split), and
     at budget 2000 the merge is refuted. Probes never caught it: the probe count is a lower bound on unsoundness.
   - **Valid residual merges** that no world-based method can separate: n+?t = Sⁿ?t (near-miss U_add0/U_add1), nested
     targets, templates whose antecedent is false or whose conclusion is true (Lemma V), and some EInd/EInd2 and Sep/SepU pairs
     (Prop E9). DTRC is then truth-sound but not target-sound.
   - **Hard ZF pairs.** UnionW/PowerW merge into the universal-set schema, which no HF-plus-logic oracle refutes; ours
     refutes it through Foundation for generic objects (Prop E9a). EInd/EInd2 merge into a false template whose
     refutation needed v2's constant propagation; one merge type still needs budget 400 (E9).
   - **Ambiguous data** (0+0=0) can cost a target its only anchor under a partition; the sharing pass repairs this.
   - **Rare targets** (one instance) are never generalised; ground axioms and singleton mistakes are indistinguishable.
   - **Full DT°** (positive-arity term metavariables) blows Min up (up to 64 minimal templates for a PA pair, timeouts
     on ZF pairs; E7); hence DT°_F.
5. **Corrections relative to v1.** (i) v1's Prop E1 is false for templates with rigid parameters; restated as E1-lit,
   and the general case is Prop E1-al with an alignment-complete Min, now DTRC's default (referee F2). (ii) The C-stress
   claim about PA mistakes was false (Prop E10). (iii) E3 now uses the numerals-only regime, reports schema-level
   exactness separately, and de-duplicates held-out sets. (iv) The pattern-lgg baseline was formula-level; the genuine
   one is implemented. (v) E9 now reports distinct templates; hard ZF pairs added. (vi) Thm E4's last clause is per
   cluster, and equality with the tagged learner needs history-independent refuter verdicts (H-ref).

---------------------------------------------------------------------------------------------------------

## 1. Setting and what was built

### 1.1 Representation and the normal form

- **Terms and formulas.** Two languages: arithmetic {0, S, +, *, =, <} and set theory {∈, =}. Connectives ¬ ∧ ∨ → ↔,
  quantifiers ∀ ∃; bounded quantifiers are abbreviations (∀y<t.φ := ∀y(y<t → φ), ∃y∈t.φ := ∃y(y∈t ∧ φ)). Bound
  variables are de Bruijn indices; free variables are named *parameters*.
- **Normal form of a datum (stated explicitly in v2; referee C-Q1, F7).** A datum is a formula whose free variables
  are parameters, read under universal closure (the brief's closure-normal form). Each datum is canonicalised on its
  own: parameters are renamed w0, w1, … in order of first occurrence (`canon_params`). **Leading universal
  quantifiers are not stripped.** Consequences:
  1. The axiom Q4 is the datum `∀x(x+0=x)`; the instance-schema datum `w0+0=w0` is a different datum for the same
     proposition. The learned schema ?t+0=?t accepts `w0+0=w0` (∀xφ in parameter form) but not the string
     `∀x(x+0=x)`.
  2. With this choice the PA-mix targets have pairwise disjoint instance sets except for the single sentence
     0+0=0 ∈ inst(U_add0) ∩ inst(U_0add), and the ZF-mix targets are pairwise disjoint (the case analysis of Prop E8
     shows a rigid clash for every pair). Under full stripping (leading ∀ → fresh parameters) Q4 ∈ inst(U_add0) and
     Q6 ∈ inst(U_mul0), and stripped targets have rigid parameters.
  3. The referee re-ran DTRC v1 with all data and targets fully stripped (`referee_checks/r13_strip.out`): ARI 1.0 on
     unambiguous data in PA-mix seeds 0–4 and ZF-mix seeds 0–2, Q4 and Q6 absorbed into the U_add0/U_mul0 clusters
     (semantically right, scored "not exact"), all other targets exact, 0 non-target probes (computed by the referee).
     With rigid parameters in the targets, the theory needs Min^al (Prop E1-al), which v2 uses.

### 1.2 Templates, instances, generality

- **DT° templates** (brief §3). A metavariable M has a sort (formula or term) and an arity n; an occurrence M(t̄) has
  metavariable-free argument terms t̄; every metavariable has at least one *pattern occurrence* (arguments pairwise
  distinct bound variables in scope; any occurrence if n = 0). **DT°_F** is DT° with 0-ary term metavariables
  (formula metavariables keep any arity).
- **Substitutions and instances.** A substitution θ maps each M to a body: a term or formula over holes h_0..h_{n-1}
  whose free variables are parameters only (no loose de Bruijn index). T[θ] replaces each occurrence M(t̄) by
  plug(θ(M), t̄) (one-step β-reduction; arguments are shifted under the body's binders).
- **Literal instances.** d ∈ inst_lit(T) iff d = T[θ] for some θ (template parameters matched by identity).
- **Instances.** d ∈ inst(T) iff d = (ρT)[θ] for some θ and some injective renaming ρ of the parameters of T. This is
  what the matcher `templates.match` decides, and it is the right notion for closure-normal data, which are
  canonicalised per datum. For a parameter-free T, inst(T) = inst_lit(T).
- **Generality.** T1 ≥ T2 iff freeze(T2) ∈ inst(T1), where freeze turns metavariable occurrences into rigid constants;
  T1 ≥_lit T2 likewise with inst_lit. Both are preorders, ≥_lit ⊆ ≥, and T1 ≥ T2 implies inst(T2) ⊆ inst(T1) (compose
  the substitutions; the renamings compose to an injective renaming). T1 ≡ T2 iff ≥ both ways.
- **Covering.** T covers D iff D ⊆ inst(T); T covers D literally iff D ⊆ inst_lit(T).
- **Matching** (known from the prior work; single track Thm A): read each metavariable's body off one pattern
  occurrence (abstract the datum's subterm over the argument variables), check every other occurrence by plugging;
  template parameters are matched injectively. The matcher is unique and linear for DT° templates.

### 1.3 Common-prefix tree, normal configurations, Min_lit and Min^al

Notation (unchanged from v1):
- C(D) is the common-prefix tree of D. A *slot* is a maximal disagreement position (the data disagree on the head
  symbol or arity there; parameters count as head symbols, compared literally).
- 𝒯(D) is C(D) in which every atom node whose subtree contains a slot with a free bound variable in its column is made
  a leaf slot (an *F-slot*). In 𝒯(D) every term slot has a closed column.
- For a slot σ, ȳ_σ is the set of bound variables free in some datum's column at σ; the *own* occurrence is M_σ(ȳ_σ),
  with bodies β_d(σ) obtained by abstracting d|σ over ȳ_σ.
- σ → π (π derivable from σ) iff there are metavariable-free terms t̄ = t̄(σ,π) with β_d(σ)[t̄] = d|π for all d ∈ D.
- A **normal configuration**: a set S' of slots (own slots), no member derivable from another member; an antichain
  A ⊇ S' of nodes of 𝒯(D) covering every slot; for each π ∈ A \ S' a choice of ρ ∈ S' with ρ → π, giving the
  occurrence M_ρ(t̄(ρ,π)). Rigid symbols of C(D) fill the rest.
- **Min_lit(D)** := the ≥-minimal elements (up to ≡) among the normal configurations. This is what `MinCover`
  computes (v1's "Min(D)"); parameters are compared literally when building C(D).
- **Alignments (v2).** Let r be the datum with fewest parameters. An alignment α = (G, (ι_d)_{d≠r}) is a set
  G ⊆ par(d_r) together with injections ι_d : G → par(d). α(D) renames, in each datum, ι_d(q) (resp. q in d_r) to a
  common global name g_q for q ∈ G, and every other parameter to a name of its own. Align(D) is finite.
- **Min^al(D)** := the ≥-minimal elements (up to ≡) of ⋃_{α ∈ Align(D)} Min_lit(α(D)) (`mincover.aligned_min`). If
  some datum is parameter-free there is a single alignment and Min^al(D) = Min_lit(D). The code caps the number of
  alignments at 4096 and reports a truncation; no truncation occurred in any experiment.

### 1.4 World oracles (v2 changes marked)

Three-valued evaluators; a verdict True/False is certified, None is "unknown".
- **PA (truth in ℕ).** Numerals evaluated exactly; symbolic variables decided by polynomial normal forms over ℕ;
  bounded quantifiers with numeral bounds exact; one-point forms by substitution; numeral counterexample/witness
  search; Kleene connectives with supervaluation over unknown atoms and quantified subformulas; vacuous quantifiers
  stripped. **v2:** after the symbolic attempt and the numeral search, an unbounded ∀x/∃x is decided, if possible, by a
  **case split** x ∈ {0, …, K−1} ∪ {x′+K} (K = 2, x′ a fresh symbol), under a local step budget whose overrun yields
  None instead of aborting the evaluation.
- **ZF (truth in V, V ⊨ ZF assumed).** HF sets of rank ≤ 3 plus *generic objects*; for an unbounded quantifier the
  universe is split into x ∈ E (transitive closure of the concrete values in scope), x = an in-scope generic, and a
  fresh generic. This is the brief's finite case analysis over how an arbitrary set relates to the transitive closure
  of the parameters, for any quantifier prefix.
- **Both, v2: constant propagation.** Before evaluation the sentence is simplified by propositional equivalences
  valid in every structure with a nonempty domain (A∧⊤ = A, A→⊥ = ¬A, ¬¬A = A, Qx.⊤ = ⊤, …), after replacing atoms
  decided independently of the variables' values by ⊤/⊥: t = t (both), closed atoms evaluated exactly and t < t
  (PA), x ∈ x false (ZF; Foundation). Effect: `∀y(y∈x → ⊥)` and `∀y ¬y∈x` become the same supervaluation leaf.

### 1.5 Template refuter (v2 search order)

`TemplateRefuter.refuted(T, data)` searches instances of T and asks the oracle; it returns True as soon as an instance
is refuted, and caches per canonical template. Within one budget (default 80 instances) it tries, in order:
1. **top/bot** (v2): every assignment of ⊤/⊥ to the formula metavariables (at most 16), term metavariables at the
   first pool element;
2. **one-hot** (v2; at most half the budget): one metavariable runs through its body pool while all other formula
   metavariables are ⊤ (resp. ⊥);
3. **parallel** assignments and the **diagonal** enumeration of index tuples by increasing index sum over per-sort,
   per-arity body pools (v2 adds the PA bodies h=2 and 1<h);
4. **data-guided** bodies read off different data by matching (up to 20 more instances).
The refuter is sound (it only reports oracle refutations), budgeted, and history-dependent (cached data-guided tries).

### 1.6 DTRC

1. Canonicalise the data; discard data the oracle refutes.
2. Agglomerate from singletons, trying pairs in decreasing order of common-prefix size; a merge A ∪ B succeeds iff
   some member of Min(A ∪ B) is not refuted. A failed pair stays failed for super-clusters. **v2:** Min = Min^al
   (option `align`, default on).
3. **Optional sharing pass (v2, option `share`):** for each final cluster C and each kept datum d ∉ C, in data
   order, add d to C if the merge test on C ∪ {d} succeeds (C grows greedily). Clusters may then overlap.
4. Per cluster, the cautious verifier: accept q iff q is an instance of every unrefuted member of Min(C). A cluster
   with no unrefuted member accepts exactly its data.
5. Assert the union.

### 1.7 Baselines

- First-order lgg (Plotkin/Reynolds) per tag, in the named-level encoding (binders carry their level name) and the de
  Bruijn-index encoding; instantiation may capture, as first-order substitution permits.
- **Higher-order pattern lgg, two versions (v2; referee F6).** Both take the rigid common prefix and put at each slot a
  fresh variable applied to the bound variables free in the slot's column, sharing the variable between slots whose
  problems coincide up to a permutation of those variables (my reading of the merge rule of
  Baumgartner–Kutsia–Levy–Villaret 2017; I did not run their implementation).
  - *genuine (term-level)*: built on C(D); a term disagreement containing a bound variable gets a term variable
    f(x,…) of positive arity. This is the pattern-fragment lgg; it lies in DT° but not in DT°_F.
  - *formula-level (v1 baseline)*: built on 𝒯(D); such an atom becomes a formula variable ?P(x,…). Example: on
    {Sep(x∈a), Sep(a∈x)} the formula-level version returns T_SEP, the genuine one the strictly more specific
    `∀a∃b∀x(x∈b ↔ x∈a ∧ f(x,a) ∈ f(a,x))` (tests/test_v2.py).
- Cautious k-union verifier over DT°_F (set partitions), with and without refutation negatives (small cases).
- Skeleton clustering: DTRC without refutation, stopped at the true number of targets k.
- References (v2): the tagged refutation-filtered verifier with **gold labels** (the label each datum was generated
  from) and with **membership labels** (each datum under every target it instantiates).

### 1.8 Datasets

- **PA-mix(seed):** Q1–Q7 (closed sentences), 30 induction instances with random motives (parameters allowed), and
  8/6/4 instances of U_add0 = ?t+0=?t, U_mul0 = ?t*0=0, U_0add = 0+?t=?t. **Regime `numerals` (v2 main, as the task
  specifies):** the universal axioms are observed through numeral instances n+0=n, n*0=0, 0+n=n, n uniform in 0..7.
  **Regime `mixed` (v1):** a numeral w.p. 0.6, a random closed term w.p. 0.25, the parameter form w0+0=w0 (the axiom
  itself in closure-normal form) w.p. 0.15.
- **ZF-mix(seed):** Ext, Pair, Union, Power, Inf, Found; 12 Separation, 10 Replacement (∃! spelled out), 10
  ∈-induction instances with random small formulas (bounded quantifiers, parameters).
- **Stress sets:** near-miss PA and ZF targets (E4a); injected mistakes (E4b); unequal frequencies (E4c); v2 adds the
  **hard ZF set** (E9): Sep, SepU (separation from ⋃a), Rep, Coll (Collection), EInd, EInd2 (induction along z∈y∈x),
  FoundS (minimal-element schema), UnionW and PowerW (bounding forms of Union and Power; the pair is from the untagged
  track, its Prop 7.1).
- **Held-out sets (v2):** schema instances only, disjoint from the training data (`datasets._fresh`). For the
  ?t-targets the held-out distribution is broad: numerals 0..39, closed terms of depth ≤ 3, and the parameter form.
  Ground axioms have no held-out instances; their "exactness" means "kept as a singleton that accepts exactly the
  axiom", and v2 reports it separately from schema-level exactness.

---------------------------------------------------------------------------------------------------------

## 2. Design decisions

### 2.1 The hypothesis class DT°_F

DT°_F is DT° with 0-ary term metavariables.
1. **All targets lie in DT°_F** (Q's axioms, the induction template, the ?t-instance schemas, all ZF axioms and
   schemas, all near-miss and hard targets). So the cautious verifier remains sound: a target in the class is closed in
   the class (prior Lemma C6.1).
2. **Positive-arity term metavariables blow up Min** (computed, E7): in {∈,=} a term metavariable f(ȳ) can only denote
   a projection or a parameter, and any variable column can be derived from any other with suitable arguments.
3. **Cost.** DT°_F ⊆ DT°, so every DT° anchor is a DT°_F anchor; the classes differ only before an anchor. Example:
   {Ind(x=x), Ind(0=x)} has 4 minimal templates in DT° and 2 in DT°_F (tests). The prior count of 8 in DT (C8.2) was
   taken within a size bound of 23, which cut off the 24-symbol template f(0)=f(0) ∧ ∀x(f(x)=x → f(Sx)=Sx) → ∀x f(x)=x
   that lies below two of the 8.

### 2.2 Budgeted refutation

With an ideal refuter (one that refutes every template having a false instance) failure inheritance is exact
(Prop E3(a)). With a budget it is a heuristic, and every "refuted" count in the experiments is a lower bound on what an
ideal refuter would refute; every "not refuted" is no evidence of truth (§3, Prop E10).

---------------------------------------------------------------------------------------------------------

## 3. Propositions

### 3.1 Normal form and Min

**Prop E1-lit (normal form for literal covering). Proved; computed (E0, E0b).** Let D be finite.
(a) Every normal configuration is in DT°_F and covers D literally.
(b) If T ∈ DT°_F covers D literally, then N ≤_lit T for some normal configuration N.
(c) Hence Min_lit(D) is finite; every T ∈ DT°_F covering D literally is ≥ some member of Min_lit(D); every member is
≥-minimal among the templates covering D literally; and if D ⊆ inst_lit(T*) with T* ∈ DT°_F, some member is ≤ T*.

*Proof.* (a) Own occurrences M_σ(ȳ_σ) are pattern occurrences and θ(M_σ) := β_d(σ) produces d|σ; β_d(σ) has no
loose index because ȳ_σ contains every bound variable free in the column. Derived occurrences produce β_d(ρ)[t̄] = d|π
by the definition of →. The rigid part is the common prefix, which every datum contains literally. Arguments are
subterms of the data, hence metavariable-free. Every metavariable has its pattern occurrence at its own slot. Term
metavariables are own only at term slots of 𝒯(D), whose columns are closed, so they are 0-ary.

(b) Let d = T[θ_d] for every d ∈ D.

*Step 0 (where occurrences sit).* Plugging does not change the part of T above its metavariable occurrences
(preservation lemma: prior second-order notes; single track Thm A), so every rigid symbol of T — parameter names
included, as the covering is literal — occurs at the same position in every datum. Hence the rigid skeleton of T lies
in C(D), and every maximal occurrence sits at a node of C(D) or at a slot, never strictly below a slot. No occurrence
lies strictly below an F-slot ν: such an occurrence sits at a term position π inside an atom, so it is a 0-ary term
metavariable with a closed value; but ν contains a slot σ with an open column; σ cannot carry a rigid symbol of T, so
some occurrence sits at a term position π with ν < π ≤ σ; then d|π contains d|σ, which has a variable bound above ν
(atoms contain no binders), so d|π is not closed, a contradiction.

*Step 1 (push down).* Let M have a pattern occurrence M(z̄) at a node p of 𝒯(D) that is not a slot, so the data
agree on the head h at p. Specialise M := λz̄.B with B chosen by h:
- h a connective or quantifier: B = h(N_1(z̄), …) with new metavariables (one more bound variable among the arguments
  under a quantifier);
- h an atom that is not an F-slot: the slots below p have closed columns; B is the common part of the bodies with fresh
  0-ary term metavariables at those slots, and the bodies agree with B;
- h a leaf: B is the leaf (0 or a parameter, the same name in all data) or the hole z_k for a common bound variable,
  which must be among z̄; M disappears;
- 0-ary term metavariables at interior term nodes are pushed down in the same way.
The new metavariables have pattern occurrences at p's children. At M's other occurrences M(t̄) the datum content is
β_d[t̄], which agrees with B[t̄] on the common part, and on the closed parts the values coincide. So the result covers
D literally, lies in DT°_F, and is ≤_lit T. Each step adds a rigid symbol inside the finite tree 𝒯(D), so the process
terminates, and afterwards every pattern occurrence sits at a slot.

*Step 2 (canonical arguments).* If a pattern occurrence M(ȳ) at slot σ has an argument not free in any datum's
column, M's values do not use that hole; specialise M := λz̄.M′(z̄ minus the unused holes) (≤, still covers).
Reorder arguments canonically (≡). Then M is M_σ up to renaming; further pattern occurrences of M at other slots count
as derived occurrences.

*Step 3 (forced arguments).* For an occurrence M_σ(ū) at π, β_d(σ)[ū] = d|π for all d. Every hole of M_σ occurs free
in some β_d(σ), and substitution into a body with a free occurrence of the hole is injective in the substituted term
(with unshifting under binders). So ū = t̄(σ,π), and T is a configuration, possibly with a non-independent own set.

*Step 4 (independence).* If σ ∈ S′ is derivable from ρ ∈ S′ \ {σ} via t̄, specialise M_σ := λȳ_σ.M_ρ(t̄). This is a
legitimate body: the free bound variables of t̄ occur in σ's column, so they lie in ȳ_σ. The other occurrences
M_σ(ū) become M_ρ(t̄[ū]) = M_ρ(t̄(ρ,π)) by forcedness; M_ρ keeps its pattern occurrence. The result is ≤_lit T, covers
D literally, and |S′| drops by one. Iterating gives a normal configuration N ≤_lit T.

(c) There are finitely many own sets, antichains and choices, so finitely many normal configurations and Min_lit(D)
is finite. A literally covering T is ≥_lit some normal N (by (b)), and N ≥ some member of Min_lit(D) (finite preorder).
Minimality: if T′ < M ∈ Min_lit(D) covers D literally, then by (b) T′ ≥ N₁ for a normal N₁, and N₁ ≤ T′ < M
contradicts the minimality of M among the normal configurations. The last clause is (b) applied to T*. ∎

**Corollary E1-pf. Proved.** If T* ∈ DT°_F is parameter-free, then D ⊆ inst(T*) implies that some member of
Min_lit(D) is ≤ T*, and a parameter-free T covering D is ≥ some member of Min_lit(D). (For parameter-free templates
inst = inst_lit.)

**Remark (v1's E1 is false as stated; referee F2).** v1 stated E1 for "covering" and proved it for literal covering.
For a template with a rigid parameter the two differ. Counterexample (referee R1; `tests/test_v2.py`):
D = {0=0 ∧ w0=w0, w0=0 ∧ w1=w1}. Min_lit(D) = {?f0=0 ∧ ?f1=?f1}, but ?f=0 ∧ w0=w0 covers D (w0 ↦ w1 in the second
datum) and is strictly below. Computed (E0b): for random generating templates T* with a rigid parameter, no member of
Min_lit(D) is ≤ T* in 17/200 (PA) and 36/200 (ZF) data sets; for parameter-free T*, 0/200 in both languages.

**Prop E1-al (alignment-complete Min). Proved; computed (E0b).** Let D be finite.
(a) Every member of Min^al(D) is in DT°_F and covers D.
(b) Every T ∈ DT°_F covering D is ≥ some member of Min^al(D).
(c) Min^al(D) is finite; its members are ≥-minimal among all DT°_F templates covering D; and if D ⊆ inst(T*) with
T* ∈ DT°_F (rigid parameters allowed), some member is ≤ T*.

*Proof.* (a) Let M ∈ Min_lit(α(D)). By E1-lit(a), M covers α(D) literally: α_d(d) = M[θ_d], where α_d is the
bijective renaming that α applies to d's parameters. Then d = α_d⁻¹(M[θ_d]) = (α_d⁻¹M)[α_d⁻¹θ_d], and α_d⁻¹ is
injective on par(M); so d ∈ inst(M).
(b) Let d = (ρ_d T)[θ_d] with ρ_d injective, for every d. Put G := ρ_r(par(T)) ⊆ par(d_r) and
ι_d := ρ_d ∘ ρ_r⁻¹ : G → par(d), injective; α := (G, (ι_d)) ∈ Align(D) (|G| = |par(T)| ≤ |par(d_r)|). Let T′ rename
each parameter p of T to g_{ρ_r(p)}; T′ ≡ T. For every d, α_d ρ_d(p) = α_d(ι_d(ρ_r(p))) = g_{ρ_r(p)}, so
α_d(d) = (α_d ρ_d T)[α_d θ_d] = T′[α_d θ_d]: T′ covers α(D) literally. By E1-lit(c), T′ ≥ some M′ ∈ Min_lit(α(D)),
and M′ ≥ some minimal element M of the finite union. So T ≡ T′ ≥ M ∈ Min^al(D).
(c) Finiteness: Align(D) is finite and each Min_lit is finite. Minimality: if T covers D and T < M ∈ Min^al(D), then
by (b) T ≥ M″ ∈ Min^al(D), so M″ < M with M″ in the union, contradicting the minimality of M there. The last clause is
(b) applied to T*. ∎

*Computed.* `aligned_min` implements exactly Align(D) (reference datum r = fewest parameters). E0b: 0 failures of
(a), (b) and of the specialisation-walk checks in all eight cells, including 0/200 failures of "some member ≤ T*" for
T* with a rigid parameter in both languages. On the experiment data Min^al rarely differs from Min_lit: 0 of the 720 E2
data sets (the referee's R6 found 0 of 360 with his own implementation), 0 Min calls in E3's DTRC runs on PA and 1 on ZF.

### 3.2 Oracles

**Prop E2 (soundness of the oracles, v2). Proved; computed (recheck).** A verdict True (False) of the PA evaluator
implies that the universal closure is true (false) in ℕ. Assume V ⊨ ZF. A verdict True (False) of the ZF evaluator
implies that the universal closure is true (false) in V, under every realisation ν of the generics (ν maps each generic
G to a set outside E_G that differs from the generics created before G).

*Proof.* Induction on the formula with the environment fixed; the v1 argument, plus three v2 components.

*PA atoms.* At numerals the evaluation is exact. With symbolic variables the terms denote polynomials with
nonnegative integer coefficients; s = t holds identically on ℕ^k iff the polynomials are equal; if p_s − p_t has all
coefficients ≥ 0 and a positive constant term then s > t everywhere; the other classifications are symmetric.

*ZF atoms.* E_G is transitive and ν(G) ∉ E_G. G ∈ c is False when c ∈ E_G, or when every element of c lies in E_G
(otherwise ν(G) ∈ c ⊆ E_G). G = c is False when c ∈ E_G. G ∈ G is False by Foundation. G = H is False for distinct
generics (the later one was created fresh). Every other mixed atom is unknown.

*Connectives.* Kleene's strong tables are monotone, so known values stay correct. Supervaluation: the actual truth
values of the unknown leaves under ν form one of the enumerated assignments; leaves with known values agree under every
ν by the induction hypothesis.

*Quantifiers.* A bounded quantifier over a concrete set or numeral bound is enumerated exactly. PA symbolic step: a
verdict for a fresh symbol holds for every value; the numeral search finds genuine counterexamples or witnesses. ZF
unbounded ∀x: given ν and any set a, either a ∈ E (evaluated), or a = ν(G) for an in-scope generic G (evaluated), or ν
extended by H ↦ a is a realisation (case H); so all cases True gives True, and one case False gives a counterexample
(for H such an a exists, since V is not E ∪ {finitely many sets}). Extra HF search values are concrete counterexamples.
∃ is dual. Memoisation keys on (formula, environment values), so a verdict is reused only for the same environment.
Stripping vacuous quantifiers is valid in nonempty domains.

*v2 (i), PA case split.* Every natural number is one of 0, …, K−1 or x′+K for some x′ ∈ ℕ. A verdict for the case
x = x′+K (x′ fresh) holds for all values of x′ and of the other symbols. So all cases True implies ∀x true; one case
False exhibits a counterexample (for the symbolic case: any value of x′). ∃ is dual.
*v2 (ii), constant propagation.* The rewrite rules are logical equivalences in every structure with a nonempty domain;
t = t is logically true; closed PA atoms are evaluated exactly and t < t is false in ℕ; x ∈ x is false in V by
Foundation. So the simplified sentence is equivalent to the original in ℕ (resp. V).
*v2 (iii), local budgets.* An overrun returns None, which is always sound.

Which ZF axioms the argument uses: Foundation, Extensionality (equality of HF sets), the existence of HF sets, and that
no set contains all sets; not Infinity. ∎

*Computed (v2 re-verification with the referee's independent evaluators; `experiments/recheck/`, scripts copied
unchanged from the referee).* 0 contradictions in all checks: R3 (verdicts logged during DTRC runs on mixes with
mistakes and near-miss sets: PA 2197 verdicts, ZF 413 of quantifier depth ≤ 4 plus 179 of depth 5–6, against a bounded
PA evaluator and exact evaluation in finite structures V_4 ∪ {extra objects} satisfying exactly the proof's
assumptions); R4 (3000 random PA and 600 random ZF sentences). The mutation test R11 still detects injected bugs in the
generic case analysis (39/600 and 292/600 contradictions). Unit tests: no refutation of random genuine instances of
every target; refutation of the listed false sentences (`tests/test_oracles.py`, `tests/test_v2.py`).

### 3.3 DTRC

Throughout, "Min" is Min^al, or Min_lit when every template the statement quantifies over (targets T*) is
parameter-free. The experiments use Min^al and parameter-free targets, so both readings apply.

**Prop E3 (merge monotonicity; within-target merges succeed). Proved.**
(a) Let D ⊆ D′ and let the refuter be ideal. If every member of Min(D) is refuted, so is every member of Min(D′).
(b) If A ∪ B ⊆ inst(T*) with T* ∈ DT°_F and every instance of T* true, then for every sound refuter, whatever its
budget, the merge test on A ∪ B succeeds.

*Proof.* (a) T′ ∈ Min(D′) covers D (literally, for Min_lit); by E1-al(b) (resp. E1-lit(c)) T′ ≥ some T ∈ Min(D), so
inst(T) ⊆ inst(T′) and T's false instance lies in inst(T′). (b) By E1-al(c) (resp. Cor E1-pf) some T₀ ∈ Min(A ∪ B) is
≤ T*. Its instances are true, so no sound refuter refutes it. ∎

**Thm E4 (DTRC under refutation separation; v2 statement). Proved.** Hypotheses:
- (T) targets T_1, …, T_k ∈ DT°_F (parameter-free if Min = Min_lit), every instance true in the world (ℕ or V);
- (D) data D = ⊔ D_i with D_i ⊆ inst(T_i), each datum an instance of exactly one target;
- (R) the refuter is sound;
- (S) for all i ≠ j and nonempty A ⊆ D_i, B ⊆ D_j, every member of Min(A ∪ B) is refuted when the merge test
  examines it.
Then DTRC (without the sharing pass) discards no datum and its final clusters are exactly the nonempty D_i. For each i,
Acc_i = ⋂{inst(T) : T ∈ Min(D_i), T not refuted at the final verification} satisfies Acc_i ⊆ inst(T_i), so the
asserted union is target-sound. **Per cluster**, Acc_i = inst(T_i) whenever D_i contains a DT°_F anchor of T_i (a subset
every covering template of which is ≥ T_i). (H-ref) If moreover the refuter's verdict on a template does not depend on
the call history (true of an ideal refuter; false in general for the implemented one, which caches data-guided tries),
Acc_i is exactly the tagged refutation-filtered verifier's acceptance set on D_i.

*Proof.* Genuine data are true and a sound refuter does not refute them, so none is discarded. Invariant: every
cluster is contained in some D_i. It holds for singletons; a merge of clusters from different D_i fails by (S); a merge
within one D_i succeeds by E3(b) and preserves the invariant. Failed pairs are therefore cross-label, inheritance keeps
them cross-label, and it never blocks a same-label merge. Every pair of current clusters is pushed onto the queue
(minimum score 0) and removed only when tested or dead, so the loop ends only when no two clusters share a label: the
final clusters are the D_i. Acc_i ⊆ inst(T₀) ⊆ inst(T_i) for the never-refuted T₀ of E3(b), which is one of the
intersected templates. If D_i contains an anchor, every member of Min(D_i) covers it and is ≥ T_i, and the set of
unrefuted members is nonempty (it contains T₀), so Acc_i ⊇ inst(T_i). Under (H-ref) the verdicts are those the tagged
learner sees. ∎

*Remarks.* (1) v1 also claimed that the union "contains inst(T_i) exactly for those i where the tagged verifier is
exact"; the "only if" half fails when instance sets overlap (other clusters can cover inst(T_i) \ Acc_i), so v2 states
exactness per cluster (referee F8a). (2) (S) quantifies over all subsets; the algorithm only needs it for the subsets
that arise. (3) With an ideal refuter, (S) reduces to pairs of single data (Cor E8.3), the reduction the referee
pointed out; the untagged track states the same reduction for its separation condition RS_d (its §5.2).

**Prop E4-share (the sharing pass; v2). Proved.** Assume (T), (R), data D ⊆ ⋃_l inst(T_l), and
- (S+) every merge or sharing test on a set X ⊆ D that is contained in no inst(T_l) fails;
- every final cluster C of the agglomeration phase is contained in exactly one inst(T_l), written l(C).
Data may be ambiguous (instances of several targets). Then: (i) l is injective on the phase-1 clusters; (ii) after the
sharing pass the cluster C of target l is C⁺ = D ∩ inst(T_l), whatever the order; (iii) Acc(C⁺) ⊆ inst(T_l), and
Acc(C⁺) = inst(T_l) whenever D ∩ inst(T_l) contains an anchor of T_l. So DTRC+share is target-sound and exact whenever
the tagged learner with *membership* labels is; under (H-ref) the acceptance sets are equal.

*Proof.* Purity at all times: a merge of two pure clusters whose union lies in no inst(T_l) fails by (S+); a merge whose
union lies in some inst(T_l) keeps purity. Inheritance of failed pairs is correct: if A ∪ X failed then, by E3(b),
A ∪ X lies in no inst(T_l), hence neither does A ∪ B ∪ X. (i) If C ≠ C′ had l(C) = l(C′) = l, then C ∪ C′ ⊆ inst(T_l)
would pass by E3(b) and the phase would not have ended (the pair is never marked failed, by the inheritance remark).
(ii) Let C′ be the growing cluster, initially C ⊆ inst(T_l). For d ∈ D ∩ inst(T_l), C′ ∪ {d} ⊆ inst(T_l) passes
(E3(b)). For d ∉ inst(T_l), C′ ∪ {d} lies in no inst(T_j): not in inst(T_l) as d ∉ inst(T_l), and not in inst(T_j),
j ≠ l, since C ⊆ C′ is contained in exactly one target's instance set; so it fails by (S+). By induction C′ stays in
inst(T_l) and ends as C ∪ (D ∩ inst(T_l)) = D ∩ inst(T_l) (genuine data are never discarded). (iii) Prop E5 below and
the anchor argument of Thm E4. ∎

*Why it matters.* In the numerals-only regime the only datum whose substituted term has head 0 is 0+0=0 for both
U_add0 and U_0add (0*0=0 for U_mul0), so 0+0=0 is the only possible anchor of either target (Prop E7), and a partition
gives it to at most one of them. With gold labels the tagged learner gives it to the label it was generated under.
The sharing pass gives it to both (E3, E5).

**Prop E5 (per-cluster soundness does not depend on the budget). Proved.** If a cluster C ⊆ inst(T*), with T* ∈ DT°_F
(parameter-free if Min = Min_lit) and all instances of T* true, then Acc(C) ⊆ inst(T*) for every sound refuter; more
refutations only enlarge Acc(C), toward exactness.

*Proof.* T₀ of E3(b) is never refuted, so it is one of the intersected templates, and Acc(C) ⊆ inst(T₀) ⊆ inst(T*). ∎

*Consequence.* A budgeted refuter can harm DTRC only through clustering: a merge across targets (or with a mistake)
that is not refuted. Such a mixed cluster is truth-sound if one of its unrefuted minimal templates is valid, and may
accept false sentences otherwise (Prop E10).

### 3.4 Encodings and anchors (unchanged from v1; referee: holds)

**Prop E6 (∈-induction is a first-order pattern in de Bruijn indices, not in the named or level encoding). Proved;
computed (E2).** Let Z be a first-order metavariable and L = ∀(∀(#0∈#1 → Z) → Z) → ∀Z (de Bruijn indices). The
sentences matching L are exactly the instances of ∈-induction.

*Proof.* An instance Z := ψ is a sentence iff ψ's loose indices are ⊆ {0}, because of the occurrences at depth 1. With
β := ψ[hole/#0], all three occurrences read β[#0] in their own context (y under ∀x∀y, x under ∀x), so the instance is
EInd(λz.β). Conversely EInd(φ) = L[Z := φ(#0)]. In the level encoding the first occurrence uses level 1 and the others
level 0, so the first-order lgg has independent Z₁, Z₂; Z₁ := (y ∉ w), Z₂ := (x ∉ w) gives a false instance; a refuted
example from E2: `(Ax.(Ay.y in x -> y in w0) -> ~x in w0) -> (Ax.~x in w0)` (false with w0 = {{∅}}; referee checked
by hand). ∎ Separation is not a first-order pattern in either encoding without a freshness guard (exhibit
`Ax.Ey.Az.z in y <-> (z in x & ~w0 in y)`), Replacement in neither. Credit: the cases track's Thm B1 table.

**Prop E7 (anchors for one-variable universal targets = Plotkin's (R)). Proved; computed (E1).** Let T* contain one
0-ary term metavariable t at rigid positions, no other metavariable and no parameter, and D ⊆ inst(T*). (Min = Min_lit;
in E1 and E3 at most one datum per target has a parameter, so for N ≥ 2 some datum is parameter-free and
Min^al = Min_lit.) Then Min(D) = {T*} iff the
substituted terms do not all have the same head symbol (0 and each parameter count as heads). Hence for i.i.d. terms,
P(not exact after N) = Σ_h p_h^N.

*Proof.* (⇐) The t-positions are slots with identical closed columns and there are no other slots; an interior derived
occurrence of t at π would need d|π = t_d for all d, impossible since the heads of the t_d differ; so the unique normal
configuration is T*. (⇒) If all heads equal h, C(D) contains h below every t-position, and every covering template
obtained by E1 is strictly below T*: it misses the instances whose term has another head. ∎

### 3.5 Refutation separation: the mixes, the near-miss and hard sets

**Lemma E8.1 (heads). Proved.** In 𝒯(D) of DT°_F, if σ → π then for every d ∈ D: d|π = d|σ when σ is a term slot, and
head(d|π) = head(d|σ) when σ is a formula slot. Consequently a slot σ at which two data have different heads (a *clash
slot*) can derive only nodes π at which those data have the same two different heads, i.e. only other clash slots with
the same head pair; it derives no interior node.

*Proof.* Term slots of 𝒯(D) have closed columns, so β_d(σ) = d|σ has no hole and β_d(σ)[t̄] = d|σ. A formula body is
never a hole, and plugging preserves the head of a body; abstraction replaces only bound-variable leaves. ∎

**Prop E8 (pairwise separation for the mix targets; resolves v1's Conj-S for the mixes). Proved; computed (E9,
E10).** Let T_i ≠ T_j both be PA-mix targets (Q1–Q7, Ind, U_add0, U_mul0, U_0add) or both ZF-mix targets (Ext, Pair,
Union, Power, Inf, Found, Sep, Rep, EInd), a ∈ inst(T_i) \ inst(T_j) and b ∈ inst(T_j) \ inst(T_i). Then Min({a,b})
(Min^al or Min_lit) consists of templates of the forms below, and each has the false instance shown.

| case | target pairs | Min({a,b}) | false instance |
|---|---|---|---|
| A root clash | PA: Q_i–Ind, Q_i–U, Ind–U (31); ZF: Inf–any, EInd–any (15) | {?P} | ⊥ |
| B clash right below a common ∀-prefix | PA: all Q_i–Q_j (21); ZF: the other 17 pairs among Ext, Pair, Union, Power, Found, Sep, Rep | {∀x ?P(x)} or {∀x∀y ?P(x,y)} | ∀x̄ ⊥ |
| C comprehension clash | ZF: Union–Power, Union–Sep, Power–Sep | {∀x∃y∀z(z∈y ↔ ?P(z,x))} | ?P := ¬z∈z (Russell) |
| D | ZF: Found–Rep | {∀x(?A(x) → ∃y ?B(y,x))} | ?A := ⊤, ?B := ⊥ |
| E two ?t-schemas | PA: U_add0–U_mul0, U_mul0–U_0add, U_add0–U_0add | ?f = ?g, ?f = 0, or ?f + ?g = R with ?f, ?g occurring nowhere else | 1 = 0; S(r)+0 = r |

*Proof.* Cases A–D. In every listed pair the two targets have different rigid symbols at a position p above all of
their metavariable positions (the roots in A; the node below the shared prefix ∀x or ∀x∀y in B — for Q4–Q6 and
Q5–Q7 the two atoms have open term disagreements, so p is an F-slot; the right-hand side of ↔ in C, where the targets
read ∃w(…), ∀w(…), z∈x ∧ φ; in D the antecedent (∃ vs ∀) and the body under the consequent's ∃ (∧ vs ∀)). Every
position not below p agrees in a and b, rigidly. So 𝒯({a,b}) is the shared prefix with one slot (two in D), and every
slot is a clash slot (or, in B, an F-slot below quantifiers only). By Lemma E8.1 no slot derives an interior node or
another slot (in D the head pairs (∃,∀) and (∧,∀) differ; an F-slot has an atom head and the interior nodes are
quantifiers). So the only normal configuration puts an own metavariable at each slot, applied to the bound variables
free in its column. These are the listed templates (in C the columns mention z and x but not y; in D the antecedent
column mentions x, the consequent column y and x). The false instances: ⊥ and ∀x̄⊥ are false; Russell's instance
∀x∃y∀z(z∈y ↔ z∉z) is false (y∈y ↔ y∉y); ∀x(⊤ → ∃y⊥) is false. Alignments only rename parameters and change none of these
shapes, so the same holds for Min^al.

Case E (closed term slots; derivation between them requires identical columns by Lemma E8.1).
- U_add0–U_mul0: a = t+0=t, b = s*0=0. The left sides clash (+ vs *); the right sides are t and 0, a slot unless t = 0
  (then rigid 0). No identical columns, no derivations: Min = {?f = ?g} or {?f = 0}; false instance 1 = 0 (?f := 1).
- U_mul0–U_0add: symmetric (b ∉ inst(U_add0) and a ∉ inst(U_0add) always): {?f = ?g} or {?f = 0}.
- U_add0–U_0add: a = t+0=t with t ≠ 0 (else a ∈ inst(U_0add)), b = 0+u=u with u ≠ 0. The left sides agree on +; their
  children give slots σ1 = (t, 0) and σ2 = (0, u). A node π with column (t, 0) would need a|π = t, so π is σ1 or the
  root of the right side, where b has u ≠ 0; similarly for (0, u). So σ1, σ2 neither derive nor are derived from any
  node, and every normal configuration is ?f + ?g = R with ?f, ?g occurring only there and R built from the common
  prefix of t and u. Set every metavariable of R to 0, giving a term r, and ?f := S(r), ?g := 0: the instance
  S(r)+0 = r is false in ℕ under every assignment to its parameters. ∎

**Corollary E8.2 (separation of the mixes). Proved.** With an ideal refuter, hypothesis (S) of Thm E4 holds for
PA-mix and ZF-mix data in which no datum is an instance of two targets. The only ambiguous sentence among the mix
targets is 0+0=0.

*Proof.* For A ⊆ D_i, B ⊆ D_j pick a ∈ A, b ∈ B; then a ∉ inst(T_j), b ∉ inst(T_i), every member of Min({a,b}) is
refuted by Prop E8, hence every member of Min(A ∪ B) by Prop E3(a). ∎

**Corollary E8.3 (reduction to pairs). Proved.** For any targets and an ideal refuter, (S) holds iff every member of
Min({a,b}) is refuted for every cross pair a ∈ D_i, b ∈ D_j. (⇐ by E3(a); ⇒ is the case |A| = |B| = 1.)

*Computed.* With the implemented refuter (budget 80) every sampled cross pair and every sampled cross set of the mix
targets was refuted: 2200 PA-mix and 540 ZF-mix pair merges, involving only 15 and 5 distinct minimal templates — the
shapes of the table — all refuted in the top/bot or one-hot pass (E9). E10 checks the table itself: for 100 random data
pairs per target pair, the computed Min^al has the predicted shape and the explicit false instance is certified false
by the oracle, with no mismatch. *Caveat (referee F3):* thousands of sampled merges reduce to a handful of templates,
refuted by ⊥, ∀x̄⊥, ⊤→⊥ or a comprehension instance; this is evidence for separation only between structurally different
targets.

**(S) fails for similar targets (computed, E4a, E9; proved, Lemma V).** For the PA near-miss pair U_add0/U_add1, the data
5+0=5 and 5+1=6 have the minimal template 5+?t = S⁵?t, which is valid (Lemma V). For nested targets (U_add00 ⊆ U_add0)
and pairs sharing an instance of a third target, merges are valid as well. Refutation can never separate these; DTRC is
then truth-sound but not target-sound.

**Prop E9 (two hard ZF pairs; v2). Proved; computed (E9).**
(a) *UnionW–PowerW* (bounding forms ∀a∃b∀x(∃y(y∈a ∧ x∈y) → x∈b) and ∀a∃b∀x(∀y(y∈x → y∈a) → x∈b)). The unique minimal
covering template is the universal-set schema U = ∀a∃b∀x(?P(x,a) → x∈b) (one clash slot, ∃ vs ∀). Its instance
?P := ⊤ is ∀a∃b∀x(x∈b), false in V (x := b gives b∈b, against Foundation; or Russell's subset of b). The untagged track
(its Prop 7.1) shows that no oracle sound for the structure HF ∪ {u} with y ∈ u for all y refutes any instance of U; our
ZF oracle refutes the ⊤-instance because generic objects obey Foundation: after simplification the sentence is
∃b∀x(x∈b); the case analysis for ∃b has the single case "b a fresh generic G" (nothing concrete is in scope), and
∀x(x∈G) fails at x := G because G∈G is False. (Computed: E9, top/bot pass.)
(b) *EInd–EInd2* (EInd2(φ) = ∀x(∀y∈x ∀z∈y φ(z) → φ(x)) → ∀xφ(x), true because z∈y∈x is well-founded). In the most
frequent case (the motives' heads differ and the EInd motive does not begin with ∀) the slots are the EInd motive's
position under ∀y∈x (clash with ∀z), the step conclusion and the final conclusion; the last two have identical
columns, and nothing else is derivable (Lemma E8.1; when the head pairs of the first two slots coincide, i.e. the
EInd2 motive begins with ∀, a size argument: φ(t) is shorter than ∀z(z∈y → φ(z))), so the minimal template is
T_EE = (∀x(∀y(y∈x → ?P0(y)) → ?P1(x))) → ∀x ?P1(x). Its instance
?P0 := ⊥, ?P1 := "x is empty" (∀z ¬z∈x) is false: the premise is ∀x(x=∅ → x=∅), the conclusion fails at {∅}. The v1
oracle could not certify the premise, because ∀y(y∈x → ⊥) and ∀z ¬z∈x were different supervaluation leaves; with v2's
constant propagation they coincide, and the one-hot pass finds the instance in 8 oracle calls (ablation E9b: 0 of 12
random EInd/EInd2 pair merges refuted without constant propagation, 10 of 12 with it). EInd–EInd2 merges can
also be *valid*: for EInd(x=x) and EInd2(x=x) the minimal template is (∀x(∀y(y∈x → ?P(y)) → x=x)) → ∀x(x=x), whose
conclusion is true. When the EInd motive begins with ∀z∈y, the template is
(∀x(∀y∈x ∀z∈y ?P0(z,y) → ?P1(x))) → ∀x ?P1(x); it is false (?P0 := ⊥ and ?P1(x) := ∀y∈x ∀z∈y ⊥, "every element of x
is empty", make the premise A → A, and the conclusion fails at {{∅}}; the oracle certifies this instance false), but the
refuter needs budget 400 to find a refutation (E9). So (S) fails for this pair in general, and residual merges of this
pair are truth-sound only when valid. ∎ (Similarly Sep(x∈a) and SepU(x∈a) merge into
∀a∃b∀x(x∈b ↔ (?P(x,a) ∧ x∈a)), which is Separation with the conjuncts swapped, hence valid.)

### 3.6 The false merge of E4(b) and the residual merges

**Prop E10 (the referee's exhibit: DTRC accepted a false sentence; v1 claim withdrawn). Proved; computed.**
In E4(b), PA-mix seed 0 with mistakes (both instance regimes), the mistakes ind_wrong_step and ind_wrong_concl merge
at refuter budgets 80 and 400 — in v1 and still in v2 — into a cluster whose only accepted template is

T_F = ((∃x(?P0(x,0) ∧ ¬?P1(x,0))) ∧ ∀x((∃y(?P0(y,x) ∧ ¬?P1(y,x))) → ∃y(y<Sx ∧ ¬?P1(y,Sx)))) → ∀x∃y(y<Sx ∧ ¬?P1(y,Sx)).

T_F is false: with ?P0(y,x) := (x=0) and ?P1(y,z) := (z=2) the instance

q_F = ((∃x(0=0 ∧ ¬0=2)) ∧ ∀x((∃y(x=0 ∧ ¬x=2)) → ∃y(y<Sx ∧ ¬Sx=2))) → ∀x∃y(y<Sx ∧ ¬Sx=2)

is false in ℕ: the first premise is true; the second is true (at x = 0 the consequent holds with y = 0, as 1 ≠ 2; at
x ≥ 1 the antecedent is false); the conclusion fails at x = 1, where Sx = 2. q_F is an instance of no PA-mix target, and
DTRC accepts it. (Proof by hand; the referee found the exhibit.) Refuting q_F needs a certificate for the Π1 premise,
i.e. a case split on x = 0; the v1 oracle returns unknown, the v2 oracle (case split) returns False. In v2 DTRC still
accepts q_F at budgets 80 and 400 — the refuter does not reach this instance in time — and no longer at budget 2000,
where the merge is refuted (E4b; `experiments/recheck/r15_pafalse.out`). The probes of E4 never sampled q_F and
reported "0 refuted": **the probe count is a lower bound on unsoundness, not a certificate of truth-soundness.** v1's
claim "PA mistakes merge only into valid templates" is withdrawn.

**Lemma V (validity of the residual templates observed in E4). Proved (each by hand).** Every instance of each of
the following templates is true (in ℕ, resp. V):
1. S^n0 + ?t = S^n ?t (n ≥ 0): n + t = t + n = S^n(t) in ℕ.
2. ?t+1 = S?t, ?t+0 = ?t, 0+?t = ?t: these are targets (instances true in ℕ).
3. (?t<0 ∧ …) → …, (0 = S?t ∧ …) → …, ((∃x(x<0 ∧ …)) ∧ …) → … (also with x < 0+0 and x < 0·0): the first conjunct of
   the antecedent is false in ℕ.
4. (?P(0) ∧ ∀x(?P(x) → ?P(Sx))) → ∀x ?P(Sx): by induction ∀x ?P(x), hence ∀x ?P(Sx).
5. (ZF) (∀x(?P(x) → x=x)) → ∀x(x=x), and (∀x(∀y(y∈x → ?P(y)) → x=x)) → ∀x(x=x): the conclusion is true.

The false templates met in E4(b) at budget 80 and their hand-checked false instances (all found by the post-hoc refuter):
- PA/numerals seed 0: ((∀x(?P0(x,0) → ?P1(x,0))) ∧ ∀x(∀y(?P0(y,x) → ?P1(y,x)) → ∀y(?P0(y,Sx) → ?P2(y,x)))) →
  ∀x∀y(?P0(y,x) → ?P1(y,x)); instance ?P0 := ⊤, ?P1(y,x) := (x=0), ?P2 := ⊤: the premises are ∀x(⊤ → 0=0) and
  ∀x(… → ⊤), both true; the conclusion ∀x(x=0) is false.
- PA/numerals seed 1: ((∀x(?P0(x,0) → ?P1(x,1))) ∧ ∀x(∀y(?P0(y,x) → ?P1(y,x)) → ∀y(?P0(y,Sx) → ?P1(y,Sx)))) →
  ∀x∀y(?P0(y,x) → ?P1(y,x)); instance ?P0 := ⊤, ?P1(y,x) := x≠0: premises 1≠0 and ∀x(x≠0 → Sx≠0) true, conclusion
  ∀x(x≠0) false at 0.
- ZF budget 80, five Separation-capture merges, e.g. ∀a∃b∀x(x∈b ↔ x∈a ∧ ∀u ?P(u,x,b,a)) with instance ?P := ¬x∈b:
  then x∈b ↔ (x∈a ∧ x∉b), contradictory for any x ∈ a, so the sentence fails at a = {∅}. The post-hoc witnesses of the
  other four reduce in the same way to x∈b ↔ (x∈a ∧ x∉b), or to x∈b ↔ (x∈a ∧ w0∉b), which fails at a = {∅}, w0 = ∅
  (if ∅∈b the right side is false at x = ∅, if ∅∉b it is true).
- PA: T_F of Prop E10 (seed 0, both regimes, budgets 80 and 400).

---------------------------------------------------------------------------------------------------------

## 4. Experiments: protocols and final numbers

All commands from `code/` (`sh run_all.sh`) or `code/experiments/`. Every random choice is seeded; seeds are listed in
each results file. Timing columns are machine-dependent; everything else reproduces exactly.

| id | command | output | what it shows |
|---|---|---|---|
| tests | `python3 -m pytest -q tests` | `results/pytest.txt` | 43 passed (31 v1 + 12 v2) |
| E0 | `python3 experiments/e0_crossval.py 14 40 F`, `… 13 40 full` | `results/e0_crossval_*.txt` | Prop E1-lit vs an independent enumerator (arithmetic) |
| E0b | `python3 e0b_property.py 200` | `results/e0b_property.md` | Props E1-lit / E1-al, both languages, rigid parameters |
| E1 | `python3 e1_universal.py` | `results/e1_universal.md`, `e1_anchor_cdf.png` | Q1 rates; Gen form |
| E2 | `python3 e2_schemas.py` | `results/e2_schemas.md`, `e2_exactness.png` | Q2: each schema from tagged instances |
| E3 | `python3 e3_mix.py` | `results/e3_mix.md` | Q3: DTRC on PA-mix (two regimes) and ZF-mix |
| E4 | `python3 e4_stress.py` | `results/e4_stress.md` | near-miss, mistakes (budgets 80/400/2000), unequal frequencies |
| E5 | `python3 e5_curves.py` | `results/e5_curves.md`, `e5_curves.png` | examples to exactness |
| E6 | `python3 e6_kunion.py` | `results/e6_kunion.md` | k-union verifier with and without negatives |
| E7 | `python3 e7_blowup.py` | `results/e7_blowup.md` | Min blow-up, DT° vs DT°_F |
| E9 | `python3 e9_separation.py` | `results/e9_separation.md` | refutation separation, distinct templates, hard ZF set |
| E10 | `python3 e10_pairtable.py 100` | `results/e10_pairtable.md` | the case table of Prop E8 |
| E9b | `python3 e9b_nosimplify.py` | `results/e9b_nosimplify.md` | EInd/EInd2 merges with and without constant propagation |
| recheck | `sh experiments/recheck/run_recheck.sh` | `experiments/recheck/*.out` | the referee's independent oracle checks, against v2 |

`sh run_all.sh` (tests, E0–E9; E10 and E9b were added to it afterwards and take 1.5 s and 2 s): 593 s wall time on 4
shared cores (`results/run_all_time.txt`). v1 results: `code/results_v1/`.

### E0 and E0b (Min)

- **E0** (unchanged, reproduced): the prior referee C's bounded enumerator (`rc_enum.enum_covering`, de Bruijn levels,
  imported read-only) on 48 arithmetic data sets — 40 pairs of induction instances from the referee's 52-motive pool and
  8 others (C8.1, numerals, Q-axiom pairs, swapped variables). It enumerates 3703 covering DT°_F templates (size ≤ 14)
  and 2515 DT° templates (size ≤ 13); every enumerated template is ≥ a computed minimum (by both matchers), every
  computed minimum within the bounds is enumerated, none is strictly below a computed minimum: 0 failures. *Coverage
  (referee):* arithmetic only, no `<`, `in`, `<->`, no parameters; 41 of 48 sets have |Min| = 1.
- **E0b** (v2): random generating templates T* from the referee's generator, 2–3 data each, 200 data sets per cell;
  checks (a) minima cover, are DT°_F and pairwise incomparable, (b) some minimum ≤ T*, (c) random specialisation walks
  from T* (≤ 8 steps): every covering template reached is ≥ a minimum and none is strictly below one.

| language | rigid parameter in T* | Min | minima | (a) fail | (b) fail | walk templates | (c) fail |
|---|---|---|---|---|---|---|---|
| PA | no | Min_lit | 200 | 0 | 0 | 380 | 0 |
| PA | no | Min^al | 200 | 0 | 0 | 380 | 0 |
| PA | yes | Min_lit | 200 | 0 | **17** | 317 | **6** |
| PA | yes | Min^al | 203 | 0 | 0 | 320 | 0 |
| ZF | no | Min_lit | 200 | 0 | 0 | 408 | 0 |
| ZF | no | Min^al | 206 | 0 | 0 | 408 | 0 |
| ZF | yes | Min_lit | 204 | 0 | **36** | 381 | **27** |
| ZF | yes | Min^al | 220 | 0 | 0 | 419 | 0 |

  Exactly as Props E1-lit, E1-pf and E1-al predict. (Min^al differs from Min_lit in 38/200 and 72/200 parameter-free
  cells too: the data's bodies carry parameters, and Min^al finds the more specific templates with rigid parameters.)

### E1 (Q1: ∀xφ from instances φ(t))

Per target 2000 runs, run r seeded by `random.Random(1000*1000003 + 7919*r)`, N capped at 40.

| data | targets | DT°_F mean N | median | 95% | fo-lgg mean N | predicted |
|---|---|---|---|---|---|---|
| mixed | x+0=x, x*0=0, 0+x=x, ¬Sx=0, x<Sx | 3.27 | 2 | 7 | 3.27 | 3.25 |
| mixed | x+y=y+x | 4.18 | 3 | 9 | 4.18 | – |
| numerals | (same five) | 8.42 | 6 | 24 | 8.42 | 8.11 |
| numerals | x+y=y+x | 11.85 | 10 | 28 | 11.85 | – |

- The five one-variable rows use the same seeds and exactness depends only on heads, so they are **one sample, not five
  replicates** (referee F8c). 8.42 vs 8.11 is 1.85 standard errors in that single sample; the referee's 200 000-run
  simulation of the head process gives 8.117 (`referee_checks/r2_e7.out`), and R2 found 0 violations of the head
  criterion in 3000 random data sets over 9 one-variable templates.
- First-order lgg and the DT°_F verifier agree run by run (2000/2000 for every row).
- Gen form: on two instances the learned schema accepts φ(w0) (e.g. w0+0=w0), i.e. ∀xφ in closure-normal parameter
  form; not the string ∀x(x+0=x) (§1.1). Non-anchor: {1+0=1, 2+0=2, 3+0=3} gives S?f+0=S?f, which rejects 0+0=0.

### E2 (Q2: each schema from tagged instances)

30 seeds per N for exactness; 8 seeds × 30 probes for soundness. Min = Min^al (equal to Min_lit on all 720 data sets).

| schema | N | DT°_F exact | + refutation | pattern lgg genuine | pattern lgg formula-level (v1) | fo-lgg named complete | fo-lgg de Bruijn complete |
|---|---|---|---|---|---|---|---|
| Sep | 2 / 3 / 8 | 23 / 27 / 30 | 23 / 27 / 30 | 23 / 27 / 30 | 23 / 27 / 30 | 25 / 28 / 30 | 25 / 28 / 30 |
| Rep | 2 / 3 / 8 | 23 / 24 / 30 | 23 / 24 / 30 | 23 / 24 / 30 | 23 / 24 / 30 | 28 / 28 / 30 | 28 / 28 / 30 |
| EInd | 2 / 3 / 8 | 27 / 29 / 30 | 27 / 29 / 30 | **24** / 29 / 30 | 27 / 29 / 30 | 24 / 29 / 30 | 24 / 29 / 30 |
| Ind | 2 / 3 / 8 | 25 / 30 / 30 | 27 / 30 / 30 | 0 / 0 / 0 | 0 / 0 / 0 | 25 / 30 / 30 | 25 / 30 / 30 |

(out of 30; full table for N = 1, 2, 3, 4, 6, 8 in `results/e2_schemas.md`.)

Soundness probes (accepted sentences that are instances of no target / of those, refuted by the oracle):
- DT°_F: 0 non-target in 927 probes (all four schemas, N = 2 and 6).
- Pattern lgg (genuine and formula-level): 0 non-target on Sep, Rep, EInd; on induction 224/229 (N=2) non-target with 58
  refuted (genuine), 213/220 with 46 refuted (formula-level) — the prior result that pattern anti-unification yields
  T12 on induction (prior C9).
- First-order lgg: unsound on Sep (capture of b), Rep and Ind in both encodings, and on EInd in the named encoding; sound
  and complete on EInd in de Bruijn indices (0 non-target in 182 probes; Prop E6). Exhibits certified false by the
  oracle, e.g. Sep, fo-de Bruijn: `Ax.Ey.Az.z in y <-> (z in x & ~w0 in y)`; EInd, fo-named:
  `(Ax.(Ay.y in x -> y in w0) -> ~x in w0) -> (Ax.~x in w0)`.

Reading: all three ZF schemas are learned exactly from 2–3 instances by DT°_F and by the genuine pattern lgg (the ZF
schemas are Miller patterns in de Bruijn form; brief Q2), slightly later by the genuine pattern lgg on EInd (its
term-level generalisation keeps atoms that DT°_F lifts to formula variables). v1's sentence "the pattern lgg equals
DT°_F on the three ZF schemas" was partly by construction and is withdrawn (referee F6).

### E3 (Q3: DTRC on untagged mixtures), 5 seeds each

Totals over seeds 0–4 (schema targets: Ind + 3 ?t-schemas, or Sep, Rep, EInd; single axioms: Q1–Q7 or the six ZF
axioms; held-out: schema instances disjoint from training; probes: 20 per cluster/tag).

**PA-mix, universal axioms through numerals only (main regime).**

| learner | mean ARI | schema targets exact | single axioms exact | held-out accepted | probes / non-target / refuted |
|---|---|---|---|---|---|
| DTRC | 1.000 | 13/20 | 35/35 | 451/500 | 226 / 0 / 0 |
| DTRC+share | 1.000 | 17/20 | 35/35 | 474/500 | 227 / 0 / 0 |
| skeleton clustering (k known) | 0.993 | 9/20 | 29/35 | 425/500 | 282 / 68 / 64 |
| tagged, gold labels | – | 13/20 | 35/35 | – | – |
| tagged, membership labels | – | 17/20 | 35/35 | – | – |
| fo-lgg per tag (named = de Bruijn) | – | – | – | 453/500 | 180 / 100 / 28 |
| pattern lgg per tag (genuine = formula-level) | – | 8/20 | – | 453/500 | 221 / 99 / 33 |

Per target (E = exact, seeds 0–4): Ind EEEEE for every learner; U_add0: DTRC ----E, DTRC+share EEE-E, tagged gold
-EE-E, tagged membership EEE-E; U_mul0 -EEEE for all; U_0add: DTRC EEE--, DTRC+share EEE-E, tagged gold E----, tagged
membership EEE-E. Seed 3 has no 0+0=0 and so no anchor for U_add0 or U_0add (Prop E7); seed 0 has no 0*0=0.

**PA-mix, v1 instance distribution.** DTRC 19/20 schema targets (U_add0 missed in seed 3, as in v1), DTRC+share 20/20,
tagged (both labelings) 20/20, single axioms 35/35, 0 non-target probes for DTRC; skeleton clustering 17/20 and 23/35
with 197 non-target probes, 185 refuted.

**ZF-mix.** DTRC, DTRC+share, skeleton clustering and both tagged references: ARI 1.0, 15/15 schema targets, 30/30
axioms, 450/450 held-out, 0 non-target probes. Pattern lgg per tag 15/15, 0 non-target; fo-lgg named 223 and de Bruijn
128 non-target probes (18 and 12 refuted).

**Cost.** DTRC: PA 584–975 oracle calls, 0.4–0.8 s; ZF 660–804 calls, 3.6–6.0 s per run. Min^al differed from Min_lit in
1 Min call (ZF seed 0) over all runs; no alignment or MinCover truncation.

Reading:
- In every regime DTRC recovers the labels (ARI 1 on unambiguous data). Its schema-level exactness differs from the
  gold-labelled tagged learner's only on U_add0/U_0add, through the ambiguous datum 0+0=0, which a partition gives to
  one cluster only (in the numerals regime the totals happen to coincide, 13/20, with different targets exact). With
  the sharing pass DTRC equals the tagged learner with membership labels target by target and seed by seed, as Prop
  E4-share predicts, and exceeds the gold-label tagged learner (17 vs 13, numerals only).
- In the numerals-only regime the ?t-targets are often not exact for any learner: by Prop E7 a numeral sample is an
  anchor only if it contains 0+0=0 (resp. 0*0=0), probability 1 − (7/8)^n for n instances.
- The headline v1 numbers (54/55, 45/45) counted ground axioms: 35 of 55 and 30 of 45. Schema-level numbers are the ones
  above.
- Skeleton clustering told the true k is unsound on PA (lumps Q4+Q6 into ∀x?P(x), etc.) and perfect on ZF, whose
  targets have distinct skeletons: refutation is needed on ZF-mix only when k is unknown.

### E4 (stress)

**(a) Near-miss targets** (PA: U_add0, U_add1, U_mul1, U_0add, U_add00 (nested in U_add0), Ind, IndSwap, IndCurry;
ZF: Sep, SepSwap, Rep, EInd, FoundS, Found; 3 seeds; PA ?t-instances from the v1 distribution).
- ZF: ARI 1, 6/6 exact in all seeds.
- PA: Ind, IndSwap, IndCurry always separated; U_add00 always merges into U_add0 (nested; valid); ambiguous numerals
  (0+1=1 ∈ U_0add ∩ U_add1, 0+0=0) join one cluster; seed 0 has two valid cross merges 5+?t = S⁵?t and 4+?t = S⁴?t
  (U_add0/U_add1). Every accepted template of every mixed cluster is valid (Lemma V 1–2); probes: 4 non-target, 0
  refuted (seed 0).

**(b) Injected mistakes** (PA: 8 mistakes — wrong step φ(x)→φ(x), wrong base φ(S0), conclusion ∀xφ(Sx) (true,
non-instance), n+0=0 — plus 3 true non-targets; ZF: 6 mistakes — Separation with b free in φ, ∀x(φ→φ)→∀xφ, complement
comprehension). Clean targets: PA 11/11 (v1 distribution) and 9–10/11 (numerals; the missing ones lack an anchor), ZF
9/9, in every run. Fate of the mixed clusters, with the post-hoc refuter (PA budget 4000, ZF 1500) and Lemma V:

| data | budget | seeds with a **false** accepted template | false templates | valid residual templates (Lemma V) |
|---|---|---|---|---|
| PA, v1 distribution | 80 | 0 | T_F (Prop E10) | (?t<0 ∧ …) → …, (0=S?t ∧ …) → … |
| PA, v1 distribution | 400 | 0 | T_F | same |
| PA, v1 distribution | 2000 | none | – | the same two, and (?P(0) ∧ ∀x(?P(x)→?P(Sx))) → ∀x?P(Sx) |
| PA, numerals | 80 | 0, 1 | T_F; two induction-step templates (§3.6) | (∃x(x<0+0 ∧ …) ∧ …) → …, (∃x(x<0·0 ∧ …) ∧ …) → …, (0=S?t ∧ …) → …, ∀x?P(Sx)-form, 0+?t=?t |
| PA, numerals | 400 | 0 | T_F | same |
| PA, numerals | 2000 | none | – | same, and (∃x(x<0 ∧ …) ∧ …) → … |
| ZF | 80 | 0, 1, 2 | five Separation-capture templates (§3.6) | (∀x(?P(x) → x=x)) → ∀x(x=x) |
| ZF | 400 | none | – | (∀x(?P(x) → x=x)) → ∀x(x=x) |

- **The false sentence q_F is accepted at budgets 80 and 400** (seed 0, both regimes) and not at 2000 (column "F1
  exhibit accepted" in `results/e4_stress.md`). The probes reported 0 refuted in every row, including those where q_F
  is accepted: the probe count is a lower bound (Prop E10).
- Refuted mistakes (2–3 per run) are discarded; unrefuted ones become singletons (each accepting itself: target-unsound,
  and false if the mistake is false) or merge as above. Ground axioms are singletons too, so without labels or
  frequencies a singleton mistake cannot be told from an axiom.
- Cost: PA 714–1217 oracle calls at budget 80 (0.6–1.2 s), 1624–3848 at 400 (0.9–3.6 s), 3048–10684 at 2000
  (3.4–7.2 s); ZF 795–874 at 80 (4.9–5.5 s), 2004–2445 at 400 (10.8–13.3 s).

**(c) Unequal frequencies** (PA: Ind 60, U_add0 20, U_mul0 3, U_0add 1 (numerals); ZF: Sep 30, Rep 4, EInd 1).
Targets with many instances are exact (Ind 3/3, Sep 3/3; U_add0 1/3 for DTRC and 2/3 with the sharing pass, because
0+0=0 is the only anchor); Rep (4 instances) 2/3; U_mul0 (3) 2/3; targets with one instance are never generalised
(EInd 0/30 held-out, U_0add 0/20): one instance is never an anchor (prior C3). Probes: 0 non-target.

### E5 (examples to exactness)

Streams drawn i.i.d. from a mixture (PA: each Q axiom 0.02, Ind 0.50, U_add0 0.16, U_mul0 0.12, U_0add 0.08; ZF: each
axiom 0.03, Sep 0.30, Rep 0.27, EInd 0.25); learners run on the first N items; mean number of exact targets over seeds
0–4. The rows of one stream share seeds (not independent replicates).

| stream | learner | N=5 | 10 | 20 | 30 | 50 | 80 | 120 |
|---|---|---|---|---|---|---|---|---|
| PA, numerals (main; 11 targets) | DTRC | 1.2 | 1.6 | 3.8 | 4.2 | 5.6 | 8.0 | 9.4 |
| | DTRC+share | 1.2 | 1.6 | 4.2 | 5.0 | 6.6 | 9.0 | 10.4 |
| | tagged + refutation (gold) | 1.2 | 1.4 | 3.6 | 4.4 | 6.0 | 8.8 | 10.2 |
| | tagged (gold) | 1.2 | 1.4 | 3.6 | 4.4 | 6.0 | 8.8 | 10.2 |
| | tagged + refutation (membership) | 1.2 | 1.6 | 4.2 | 5.0 | 6.6 | 9.0 | 10.4 |
| PA, v1 distribution | DTRC | 2.0 | 3.4 | 5.2 | 6.2 | 8.4 | 10.0 | 10.8 |
| | DTRC+share | 2.0 | 3.6 | 5.6 | 6.6 | 9.0 | 10.0 | 11.0 |
| | tagged (gold, ±refutation) | 2.0 | 3.2 | 5.2 | 6.2 | 8.6 | 10.0 | 11.0 |
| | tagged (membership) | 2.0 | 3.6 | 5.6 | 6.6 | 9.0 | 10.0 | 11.0 |
| ZF (9 targets) | all five | 1.8 | 3.6 | 5.2 | 6.8 | 7.8 | 9.0 | 9.0 |

- DTRC+share coincides with the membership-labelled tagged learner in every stream, both in the means at every grid
  point and in the first-exact N per target and seed; all differences between
  DTRC and the gold-labelled tagged learner are on U_add0/U_0add and come from the ambiguous 0+0=0 (in both directions;
  the referee's R9 shows the 13 v1 disagreements vanish when the 16 ambiguous items are removed).
- The curves are dominated by when each single axiom first appears (p = 0.02–0.03 per item); the schemas are exact
  after 5–20 examples (Ind, Sep, Rep, EInd), the ?t-targets after their 0-instance appears.
- DTRC cost: PA ≤ 1.4 s, ZF ≤ 7.2 s at N = 120.

### E6 (cautious k-union verifier, no clustering; Q + induction)

Unchanged from v1 (re-run with the v2 refuter; identical): without negatives, k = 8 and k = 9 accept 0/8 held-out
induction instances (witness union [∀x?P(x)] + one singleton slot per induction datum); with refutation negatives,
k = 8 accepts 8/8 from the anchor pair alone; k = 9 accepts 0/8 from two induction instances and 8/8 from three
(third motive x+0=x or ∃y.x<y): any 2-block split has an anchor block. 0/2 false non-instances accepted throughout.
(Prior pa-untagged result, reproduced in DT°_F.)

### E7 (Min blow-up, pairs from the mixes)

| mix | class | pairs | \|Min\|>16 | timeouts (>2 s) | max \|Min\| |
|---|---|---|---|---|---|
| PA | DT° | 1176 | 3 | 0 | 64 |
| PA | DT°_F | 1176 | 0 | 0 | 4 |
| ZF | DT° | 666 | 3 | 3 | 32 |
| ZF | DT°_F | 666 | 0 | 0 | 8 |

(PA pairs: 1176 in v2 vs 1378 in v1 because the numerals-only PA-mix has fewer distinct data.) The timeout counts are
machine-dependent (the referee's machine gave the same counts). Consistent with the single track's 4^n lower bound for
DT°.

### E9 (refutation separation; v2 protocol)

Refuter budget 80; Min^al; data that instantiate both targets of a pair excluded.

| target set | protocol | merges | refuted | distinct minimal templates | distinct unrefuted | refuting pass (distinct templates) |
|---|---|---|---|---|---|---|
| PA-mix | pairs / sets | 2200 / 2200 | 2200 / 2200 | 15 / 13 | 0 / 0 | top/bot 11, one-hot 4 / top/bot 10, one-hot 3 |
| ZF-mix | pairs / sets | 540 / 540 | 540 / 540 | 5 / 5 | 0 / 0 | top/bot 5 |
| PA near-miss | pairs / sets | 1080 / 1080 | 1073 / 1080 | 61 / 36 | 5 / 0 | top/bot 44, one-hot 12 |
| ZF near-miss | pairs / sets | 225 / 225 | 225 / 225 | 5 / 5 | 0 / 0 | top/bot 5 |
| ZF hard (v2) | pairs / sets | 432 / 432 | 431 / 430 | 14 / 15 | 1 / 2 | top/bot 10, one-hot 3 |

- Mix targets: the 15 + 5 templates are exactly the shapes of Prop E8's table (E10: 9100 random data pairs, predicted
  shape and refuted explicit false instance in every case, 0 mismatches).
- PA near-miss: the unrefuted merges are the valid n+?t = Sⁿ?t (U_add0/U_add1, n = 1, 2, 5, 7) and ?t+0 = ?t
  (U_0add/U_add00 through the ambiguous 0+0=0) — valid (Lemma V), which no world-based refuter can separate.
- ZF hard: UnionW/PowerW (universal-set schema) refuted in the top/bot pass (Prop E9a); Rep/Coll, Sep/SepU, FoundS pairs
  by ⊤/⊥ assignments or comprehension instances; EInd/EInd2: 11 of 12 pair merges refuted (one-hot pass, after v2's
  constant propagation). Ablation (E9b, `python3 e9b_nosimplify.py`, another sample of 12 pairs): with constant
  propagation switched off, as in v1's oracle, 0 of 12 are refuted; with it, 10 of 12. The surviving template
  (∀x(∀y∈x ∀z∈y ?P0(z,y) → ?P1(x))) → ∀x?P1(x) is false (?P0 := ⊥, ?P1(x) := ∀y∈x ∀z∈y ⊥, "every element of x is
  empty": premise A → A, conclusion fails at {{∅}}); the oracle certifies that instance false, and the refuter finds a
  refutation at budget 400 (44 oracle calls; the one-hot pass is capped at half the budget), not at 80.
- Caveat (referee F3): most of these merges reduce to a handful of templates refuted by ⊥, ∀x̄⊥, ⊤→⊥ or a comprehension
  instance; they are evidence for separation between structurally different targets, which Prop E8 proves for the mixes.

### Recheck (the referee's oracle checks against v2)

`experiments/recheck/` (scripts copied unchanged from `referee_checks/`, outputs v2): R3 (logged verdicts during DTRC
runs on PA-mix and ZF-mix with mistakes and the near-miss sets): PA 2197 verdicts, 0 contradictions; ZF 413 verdicts of
quantifier depth ≤ 4 and 179 of depth 5–6, 0 contradictions. R4 (random sentences): PA 3000, ZF 600, 0
contradictions. R11 (mutation test): dropping the in-scope-generic case is detected 39/600 times, dropping the
fresh-generic case 292/600; mutations of the generic-vs-HF atom rules are not detected (they rarely decide a verdict;
the referee verified them by hand). R15: v2 oracle refutes q_F (unknown without the case split); DTRC v2 accepts q_F at
budgets 80 and 400 and not at 2000, in both PA regimes.

---------------------------------------------------------------------------------------------------------

## 5. What fails, and limitations

1. **Budgeted refutation accepts false sentences.** A merge whose minimal templates are false but whose false
   instances the refuter does not reach makes DTRC accept false sentences (Prop E10: q_F at budgets 80 and 400). Every
   "refuted" count is a lower bound; "not refuted" is no certificate of truth. Pools and search order are heuristic;
   the v2 top/bot and one-hot passes and the PA case split fix the cases met here, at budget 400 (ZF) or 2000 (PA).
2. **Valid residual merges.** Refutation can never separate targets when a merged minimal template has no false
   instance: n+?t = Sⁿ?t; nested targets; templates whose antecedent is false (?t<0, 0=S?t, ∃x(x<0 ∧ …)) or whose
   conclusion is true; some EInd/EInd2 and Sep/SepU pairs (Lemma V, Prop E9). DTRC is then truth-sound but not
   target-sound, and no world-based method can do better: the merged set is true.
3. **Ambiguous data.** A datum in two targets' instance sets (0+0=0) goes to one cluster under a partition and can
   cost the other target its only anchor; the sharing pass (Prop E4-share) gives it to both. Its guarantee needs (S+)
   and the "exactly one target per phase-1 cluster" hypothesis.
4. **Oracle limits.** The ZF evaluator cannot refute sentences whose refutation needs a witness *constructed* from a
   generic, e.g. ∀a∃b∀x(x∈b ↔ a∈x) ({x : a∈x} is a proper class). The PA evaluator constructs no witnesses from terms:
   ∀x(x=0 ∨ ∃y x=Sy) stays undecided (`tests/test_v2.py`). Both are truth oracles (ℕ, V), not provability oracles.
5. **Singletons.** A one-instance target is never generalised (one instance is never an anchor, prior C3). An
   unrefuted mistake becomes a singleton that the union accepts; without labels or frequencies it cannot be told from a
   ground axiom.
6. **The class.** DT°_F excludes positive-arity term metavariables (§2.1). Targets that need them need full DT°, where
   Min can be exponential (E7; single track: 4^n); the single track's feature test is the way out and is not
   implemented here.
7. **Greedy order.** Without (S) the final partition can depend on the merge order; no theorem for that case. The
   sharing pass is greedy in data order.
8. **Skeleton clustering** told the true k is perfect on ZF-mix (distinct skeletons), so there refutation is needed only
   when k is unknown; on PA-mix it is unsound.
9. **Scale.** Pure Python; the ZF oracle dominates the run time (largest single run: ZF mistakes at budget 400, 13 s).

## 6. Open problems and conjectures

- **Separation for similar targets.** Characterise, in terms of the targets alone, when two targets admit only
  refutable cross merges. The observed failures are coincidences of a false antecedent, a true conclusion, a shared
  instance of a third target, or nesting (Lemma V); EInd/EInd2 and Sep/SepU show that genuine schema pairs can have
  both refutable and valid merges depending on the instances.
- **Budget.** Is there a natural refuter (search order and pools) that refutes every false minimal template of a cross
  pair of PA-mix or ZF-mix data within a budget polynomial in the data size? Prop E8 shows that for the mixes a single
  instance shape per case suffices; the mistake merges of E4 needed up to 2000 PA instances.
- **Constructed witnesses.** Extending the generics with term-like constructions ({G}, G ∪ {c}) would refute
  comprehension failures such as ∀a∃b∀x(x∈b ↔ a∈x).
- **Sharing without the purity hypothesis.** A guarantee for the sharing pass when phase-1 clusters can be contained in
  several targets' instance sets (e.g. a singleton {0+0=0}).

## 7. Credits (known results used)

Plotkin 1970 and Reynolds 1970 (lgg); Gold 1967 and Angluin 1980 (identification in the limit, tell-tales; the anchor
notion); Huet 1975/76 and Huet–Lang 1978 (higher-order unification and second-order matching); Miller 1991 (patterns);
Pfenning 1991 and Baumgartner–Kutsia–Levy–Villaret 2017 (higher-order pattern anti-unification; the merge rule as I
read it — I did not consult their implementation); Wright 1989 / Motoki–Shinohara–Wright 1991 (unions); Δ0-absoluteness
for HF counterexamples (standard). Prior work of this project: matching, preservation lemma, anchors and T12 for
induction, Lemma C6.1, C8.x counts, the untagged PA k-union results (`research/prior/`). The referee of this track
found the R1 counterexample, the q_F exhibit (F1) and the hard-pair suggestion, and wrote the generator used in E0b and
the oracle checks re-run in `experiments/recheck/`. The untagged track supplied the UnionW/PowerW pair.

---------------------------------------------------------------------------------------------------------

## 8. Verification log

Each referee verdict (`referee.md`, JSON summary) and each "missing" item, with its resolution in v2. "v1" = `notes.md`
and `code/results_v1/`; "v2" = this record and `code/results/`.

| id | referee verdict | resolution | evidence |
|---|---|---|---|
| E1 | holds-with-fix: false for templates with rigid parameters (parameter names compared literally; counterexample R1; 21/300 ZF failures of E1(c)) | **Referee right; repaired in proof and code.** v1's E1 is restated as Prop E1-lit (literal covering), which is what the v1 proof proves; Cor E1-pf gives the parameter-free case used by every experiment. New Prop E1-al proves the general statement for the alignment-complete Min^al (minimal elements over all per-datum parameter alignments), implemented as `mincover.aligned_min` and now DTRC's default. The R1 counterexample is a unit test. | §3.1; `tests/test_v2.py::test_aligned_min_counterexample_R1`; E0b (Min_lit: 17/200 PA and 36/200 ZF failures with a rigid parameter, 0 without; Min^al: 0 in all cells) |
| E1-comp | holds; coverage narrow (arithmetic only, no parameters, 41/48 sets have \|Min\|=1) | **Accepted; coverage extended.** E0 (unchanged, reproduced) is now described as covering arithmetic without `<`, `in`, `<->` and parameters. New E0b adds property-based checks in both languages with `<`, `in`, `<->`, and with and without rigid parameters, using the referee's generator: 800 data sets per Min procedure, 0 failures for Min^al. | §4 E0, E0b; `results/e0b_property.md` |
| E2 | holds | No change needed for v1. The oracle was **extended in v2** (PA case split, constant propagation, local budgets); the soundness proof covers the extensions, and the referee's independent checks were re-run against v2: 0 contradictions (R3: PA 2197, ZF 413 + 179 deep verdicts; R4: 3000 PA + 600 ZF random sentences); mutation test still detects 39/600 and 292/600. | Prop E2; `experiments/recheck/*.out` |
| E3 | holds-with-fix: (b) needs targets without rigid parameters | **Repaired.** E3 is stated for Min^al (any DT°_F target) or Min_lit with parameter-free targets. | Prop E3 |
| E4 | holds-with-fix: (1) parameter-free targets; (2) "only if" of the last clause fails with overlapping instance sets; (3) "same refuter verdicts" is an assumption | **Repaired.** (1) Hypothesis (T) + Min^al. (2) Exactness is stated per cluster (anchor in D_i ⇒ Acc_i = inst(T_i)); the global "exactly those i" clause is withdrawn. (3) Equality with the tagged learner is stated under the explicit hypothesis (H-ref) of history-independent verdicts; without it, Acc_i ⊆ inst(T_i) and anchor-exactness still hold. | Thm E4 and remarks |
| E5 | holds-with-fix: parameter-free hypothesis | **Repaired** as for E3. | Prop E5 |
| E6 | holds | Unchanged. | Prop E6 |
| E7 | holds; note the five rows are one sample, not replicates | **Noted.** The E1 table now says that the five one-variable rows share seeds and exactness depends only on heads, so they are one sample; 8.42 vs predicted 8.11 is 1.85 SE in that single sample, and the referee's 200k-run simulation gives 8.117. Prop E7 is stated for Min_lit; on E1's data (at most one datum with a parameter) Min^al = Min_lit. | §4 E1; `referee_checks/r2_e7.out` |
| C-Q1 | holds; accepts φ(w) but not the sentence ∀xφ as written | **Accepted.** The normal form is stated explicitly (§1.1): leading ∀ are kept, so ∀xφ is accepted in parameter form only; the Q4/U_add0 and Q6/U_mul0 overlaps that full stripping would create are discussed, with the referee's stripping check R13. | §1.1, §0 item 1 |
| C-Q2 | holds-with-fix: the pattern-lgg baseline generalises atoms with open term disagreements to formula metavariables | **Repaired in code.** `baselines.pattern_lgg` is now the genuine (term-level) pattern lgg; the v1 baseline is kept as `pattern_lgg_formula` and labelled "formula-level". Both are reported in E2/E3. The difference: EInd at N=2 is exact in 24/30 runs (genuine) vs 27/30 (formula-level), matching the referee's 3/30; Sep, Rep and induction are unaffected. "Pattern lgg = DT°_F on the ZF schemas" is withdrawn; the correct statement: the genuine pattern lgg is sound on the three ZF schemas (0 non-target probes) and exact slightly later than DT°_F on EInd. | E2 table; `tests/test_v2.py::test_genuine_pattern_lgg_sep_example` |
| C-Q3 | holds-with-fix: (1) not the numerals-only regime; (2) most "exact" counts are ground axioms; (3) held-out overlaps training; (4) mix targets have distinct skeletons | **Repaired.** (1) The numerals-only regime is now E3's main PA regime (v1's distribution kept as a second regime). (2) Exactness is reported separately for schema targets and single axioms. (3) Held-out sets are disjoint from training (`datasets._fresh`, tested). (4) Stated; see C-separation. Numerals-only result: DTRC 13/20 schema targets exact = tagged with gold labels 13/20; DTRC+share 17/20 = tagged with membership labels 17/20; v1 regime: DTRC 19/20, DTRC+share 20/20, tagged 20/20; ZF 15/15 for all. | §4 E3; `results/e3_mix.md` |
| C-curves | holds; DTRC is sometimes better than tagged because of ambiguous data | **Noted**, and E5 now includes DTRC+share and the membership-labelled tagged learner, which explain the differences. | §4 E5 |
| C-separation | holds-with-fix: only 12/5/42/5 distinct templates; missed the valid near-miss merge 5+?t=S⁵?t | **Repaired.** E9 v2 reports distinct-template counts and the refuter pass that found each refutation; it uses pairs of single data (the case to which (S) reduces) as well as v1's small sets; the near-miss valid merges (n+?t=Sⁿ?t) now appear; a hard ZF set was added. The claim is restated: E9 is evidence of separation only between structurally different targets, which Prop E8 now proves for the mixes. | §3.5, §4 E9; `results/e9_separation.md` |
| C-kunion | holds | Unchanged (re-run with the v2 refuter). | §4 E6 |
| C-blowup | holds; timeouts machine-dependent | **Noted** in E7. | §4 E7 |
| C-stress | **false**: "PA mistakes merge only into valid templates" is false (seed 0 merges into a false template; DTRC accepts a false sentence) | **Referee right; claim withdrawn.** Prop E10 gives the exhibit with a hand proof of falsity. The v2 oracle (case split) refutes the exhibit; the refuter finds it at budget 2000 (E4b now runs PA at 80/400/2000): at 80 and 400 DTRC v2 still accepts q_F, at 2000 it does not. E4 now lists every mixed cluster with its accepted templates and a post-hoc refutation at a large budget; Lemma V proves validity of every residual template not refuted post hoc, and the false ones are listed with hand-checked false instances. The probe metric is labelled a lower bound throughout. | Prop E10, Lemma V; `results/e4_stress.md`; `experiments/recheck/r15_pafalse.out` |
| Conj-S | unclear: open; evidence weak; reduction to pairs; looks provable for the mixes | **Proved for the mixes** (Prop E8 + Cor E8.2: every cross pair of PA-mix or ZF-mix targets has only minimal templates with a false instance; with E3(a), (S) follows for all unambiguous data). Reduction to pairs is Cor E8.3. Near-miss pairs are excluded explicitly ((S) fails for U_add0/U_add1, nested targets, and some EInd/EInd2 and Sep/SepU pairs, all through valid merges). | §3.5; E10 check (0 mismatches) |
| F8(b) | "same refuter verdicts" is an assumption | Hypothesis (H-ref) in Thm E4 and Prop E4-share. | Thm E4 |
| F8(e) | budget-400 ZF residual merges are false; suggested top/bot pass | **Implemented** (top/bot and one-hot passes). The two ZF budget-400 residual merges of v1 are refuted by the v2 refuter at budget 400 (unit test); in E4b v2 at budget 400 no false ZF merge remains; at budget 80 five do (all refuted post hoc). | `tests/test_v2.py::test_refuter_topbot_pass_refutes_zf_residual_merges`; E4b |

**Missing items.**

| # | missing (referee) | resolution |
|---|---|---|
| 1 | numerals-only regime for the PA-mix universal axioms not run in E3/E5 | Done: main regime of E3 and E5 (`pa_mix(..., univ_dist='numerals')` is now the default). |
| 2 | held-out sets not de-duplicated | Done: held-out sets are disjoint from training (unit test); schema-only. |
| 3 | no genuine pattern anti-unification baseline | Done: `pattern_lgg` (term-level); v1's kept as `pattern_lgg_formula`. |
| 4 | no hard ZF near-miss pairs | Done: hard ZF set in E9 (Sep/SepU, Rep/Coll, EInd/EInd2, FoundS, UnionW/PowerW). Prop E9 proves the two hardest: UnionW/PowerW (universal-set schema, not refutable by HF + logic, refuted by the generic oracle through Foundation) and EInd/EInd2 (false template whose refutation needed the v2 constant propagation; also valid merges). |
| 5 | E1 and dependent theorems ignore parameter alignment; no alignment-complete Min | Done: Prop E1-al, `aligned_min`, DTRC default; E0b. |
| 6 | no hand-verified false instance for merged templates claimed valid | Done: Lemma V (validity proofs) and the hand-checked false instances in §3.6 / E4. |
| 7 | no proof of Conj-S; reduction to pairs not noted | Done: Prop E8, Cor E8.2, Cor E8.3. |
| 8 | E0 has no ZF or parameter data sets | Done: E0b. |
| 9 | the normal form keeps leading ∀; not stated | Done: §1.1. |

**Points where I keep the v1 position.** None of the referee's verdicts was contested; every "holds" verdict is kept,
and every "holds-with-fix" and "false" verdict was acted on as above.
