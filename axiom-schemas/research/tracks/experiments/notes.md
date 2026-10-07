# Track "experiments": implementing DTRC and testing it

Status labels:
- **proved**: complete proof given here.
- **computed**: a script was run; the command and output file are named.
- **known**: literature or the prior work in `research/prior/`.
- **conjecture**.

Code is in `axiom-schemas/code/`; see the README there for the package map. Every number below comes from
`sh run_all.sh` (total wall time 583 s, 4 shared cores). Results are in `code/results/*.md`, with JSON data
and PNG figures alongside. All random choices are seeded, and the seeds are listed in each results file.
Unit tests: `python3 -m pytest -q tests` gives 31 passed (`results/pytest.txt`).

I depend on no unfinished result of the other tracks. Two of my statements overlap with theirs and are
proved here independently:
- Prop E1 overlaps the single track's Thm B.
- Prop E6 overlaps the cases track's Thm B1.

---------------------------------------------------------------------------------------------------------

## 0. Findings in brief

1. **Q1 (∀xφ from instances φ(t))** (computed, E1; proved, Prop E7).
   - Both first-order lgg and the DT°_F cautious verifier learn the instance schema φ(?t). They agree run
     by run (2000/2000 runs for each of 6 targets and 2 instance distributions).
   - The learner is exact once the substituted terms do not all share a head symbol (Plotkin's (R)). The
     observed mean number of instances matches the prediction 1 + Σ_N Σ_h p_h^N:
     - 3.27 observed vs 3.25 predicted (mixed numerals, terms and parameters);
     - 8.42 vs 8.11 for numerals only (within about 2 standard errors; figure `e1_anchor_cdf.png`).
   - In closure-normal form the learned schema accepts φ(w) with w a parameter, i.e. the sentence ∀xφ.
   - Numerals sharing the head S are never an anchor: {1+0=1, 2+0=2, 3+0=3} gives S?f+0=S?f.

2. **Q2 (each ZF schema from its instances)**, with PA induction for comparison (computed, E2).
   - **Learners that work.**
     - The DT°_F learner is exact on Separation, Replacement (∃! spelled out) and ∈-induction:
       23–27/30 runs exact at N=2 and 30/30 at N=8. On PA induction it is 25/30 at N=2 and 30/30 from N=3.
     - It never accepted a non-target probe (0 in 932 probes).
     - Refutation filtering helps before an anchor: induction at N=2 rises from 25/30 to 27/30.
     - The higher-order pattern lgg equals the DT°_F learner on the three ZF schemas.
   - **Learners that fail.**
     - The pattern lgg is never exact on PA induction (0/30 at every N). It gives T12, and 53 of 229 probes
       are refuted.
     - First-order lgg is unsound on Separation (capture of b), Replacement and induction in both
       encodings, and on ∈-induction in the named encoding. Each case has an exhibited accepted sentence
       that the oracle certifies false.
   - **Exception: ∈-induction in de Bruijn indices.** First-order lgg is sound and complete there: 0 of
     183 probes were non-target (Prop E6). This agrees with the cases track's Thm B1.

3. **Q3 (many schemas, no labels: DTRC)** (computed, E3–E5, E9; proved, Thm E4).
   - **E3: recovery on the mixes.** DTRC recovers the labels exactly (ARI 1.0) on 5/5 seeds of PA-mix
     (11 targets) and 5/5 of ZF-mix (9 targets).
     - It is exact on 54/55 PA targets and 45/45 ZF targets.
     - It accepted 0 non-target probes.
     - It needs about 650–1200 oracle calls per run, taking 0.4–0.7 s on PA and 5.6–7.9 s on ZF.
   - **E3: baselines.**
     - Skeleton clustering told the true k (no refutation) fails on PA: ARI 0.966–0.993, and 16–56 accepted
       sentences refuted per seed. It lumps Q4+Q6 into ∀xP(x) and Q5+Q7 into ∀x∀yP(y,x), then merges
       x+0=x with 0+x=x into ?f0+?f1=6.
     - On ZF it is perfect, because the ZF targets have distinct skeletons.
   - **E5: examples to exactness.** DTRC needs essentially as many examples as the tagged learner:
     - PA: 10.8 vs 11.0 targets exact at N=120 (curves in `e5_curves.png`);
     - ZF: the curves coincide.
   - **Thm E4.** If every cross-target merge is refuted ("refutation separation"), DTRC returns the true
     partition and per-target acceptance sets equal to the tagged learner's.
   - **E9.** Separation held in 100% of 2190 (PA) and 540 (ZF) random cross-target merges.

4. **What fails** (computed, E4, E7; §5).
   - **Residual merges.** Some merges that refutation cannot separate are *valid*:
     - 5+?t = S⁵?t;
     - (?t<0 ∧ …) → …;
     - (∀x(P(x)→x=x)) → ∀x(x=x).

     These are truth-sound but not target-sound. A nested target (?t+0+0=?t+0 inside ?t+0=?t) always merges.
   - **Ambiguous data.** A datum such as 0+0=0, which instantiates two targets, can cost a target its anchor.
   - **Mistakes.** Unrefuted mistakes become singleton clusters, which accept the mistake itself, or merge.
     - At refuter budget 80, 5 Separation-capture mistakes (over 3 seeds) merged into Separation clusters
       through false but unrefuted templates.
     - At budget 400, 2 such merges remain (seeds 0 and 1; seed 2 is clean), at about 3–4× the cost.
     - Clean targets stay exact in every case: a pure cluster per target remains.
   - **Rare targets.** A target seen only once cannot be generalized.
   - **Full DT° blow-up.** In full DT° (term metavariables of positive arity), Min(D) blows up:
     - up to 64 minimal templates for a PA pair, and timeouts for ZF pairs;
     - hence the class DT°_F (§2.1).

---------------------------------------------------------------------------------------------------------

## 1. What was built

The implementation follows brief items (1)–(6); module names are in `code/README.md`.

**(1) Representation.**
- Formulas use de Bruijn bound variables and named parameters (closure-normal form, renamed canonically
  w0, w1, …). Two languages: arithmetic {0,S,+,*,=,<} and set theory {∈,=}.
- Connectives: ¬ ∧ ∨ → ↔. Quantifiers ∀, ∃, with bounded quantifiers as abbreviations. There is a parser
  and a printer (round trip tested).

**(2) DT° templates.**
- Metavariables: `?P` is a formula, `?f` a term; arguments are metavariable-free.
- Instantiation is one-step plugging.
- Matching is the unique determinate matcher: read each metavariable off a pattern occurrence, check the
  rest by plugging, and match template parameters up to injective renaming.
- Generality is tested by freezing.

**(3) Minimal covering templates Min(D).**
- They are computed through *normal configurations* (Prop E1). This is SOCL from the prior work,
  restricted to metavariable-free arguments as the referee required, with three refinements:
  1. own metavariables sit only at slots;
  2. an independence condition on own slots;
  3. derived occurrences may sit at interior nodes of the common prefix as well as at slots (prior C8.2's
     P(0) at an agreeing a-slot).
- Minimal elements are filtered by pairwise subsumption. Caps (4096 own-sets, 4000 configurations) are
  never hit in DT°_F on the experiment data.

**(4) Refutation oracles** (Prop E2).
- **PA.** A three-valued evaluator in N:
  - numerals are evaluated exactly;
  - symbolic variables are decided by polynomial normal forms over N;
  - bounded quantifiers are exact;
  - a numeral counterexample search;
  - Kleene connectives plus supervaluation over unknown atoms and quantified subformulas;
  - vacuous quantifiers are stripped.

  It is sound for closed Π1 sentences with Δ0 matrices, the brief's minimal requirement, and also for many
  sentences with unbounded inner quantifiers.
- **ZF.** A three-valued evaluator in V:
  - HF sets of rank ≤ 3;
  - *generic objects* for unbounded quantifiers. The universe is split into x ∈ E (the transitive closure
    of the concrete values in scope), x = an in-scope generic, and x = a fresh generic, which stands for
    every other set.

  This is the brief's "finite case analysis over how an arbitrary b relates to the transitive closure of
  a", for any quantifier prefix, not only Π2. For Δ0 matrices with HF arguments it reduces to the
  Δ0-absoluteness refuter. It refutes Π2 sentences such as:
  - naive comprehension instances ∀a∃b∀x(x∈b ↔ x=x) and ∀a∃b∀x(x∈b ↔ x∉x);
  - the captured Separation instance ∀a∃b∀x(x∈b ↔ x∈a ∧ x∉b).

  It does not refute Infinity, which is true and has no HF witness.
- **Template refuter.** It tries:
  - parallel assignments from per-sort, per-arity body pools;
  - all body-index tuples in order of increasing index sum;
  - bodies read off different data by matching ("cross-filled").

  The budget defaults to 80 instances, with a per-sentence evaluation budget of 30 000 steps (PA) or 4000
  (ZF). Results are cached per canonical template.

**(5) DTRC.**
- Normalize the data and discard data the oracle refutes.
- Greedy agglomeration: try merges in decreasing order of common-prefix size. A merge A ∪ B succeeds iff
  some member of Min(A ∪ B) survives the refuter. A failed pair stays failed for super-clusters (Prop E3).
- Per cluster, the cautious verifier accepts q iff q is an instance of every *unrefuted* member of Min.
- Assert the union.

**(6) Baselines.**
- First-order lgg in the named-level encoding (binders carry their level name) and the de Bruijn-index
  encoding. Capture is allowed when instantiating, as first-order substitution permits.
- Higher-order pattern lgg: own metavariable per slot, sharing when problems coincide up to a pattern
  renaming. This is BKLV-style; I did not run BKLV's own implementation.
- Cautious k-union verifier over DT°_F, by enumerating set partitions, with and without refutation
  negatives.
- Skeleton clustering: the same agglomeration with no refutation, stopped at the true k.

---------------------------------------------------------------------------------------------------------

## 2. Design decisions that refine the brief

### 2.1 The hypothesis class DT°_F

DT°_F is DT° in which term-valued metavariables are 0-ary ("term variables t"). Formula metavariables keep
any arity. Reasons:

1. **All targets lie in DT°_F.** These are Q's axioms, the induction template, ?t+0=?t and the other
   universal targets, and all ZF axioms and schemas. So the cautious verifier remains sound: target ∈ class
   implies closed in the class (prior Lemma C6.1).
2. **Positive-arity term metavariables cause Min(D) blow-up.** In the language {∈,=} a term metavariable
   f(ȳ) can only denote a projection or a parameter, and any variable column can be "derived" from any
   other with suitable arguments. The number of incomparable minimal templates explodes (computed, E7):

   | mix | class | pairs | \|Min\|>16 | timeouts (>2 s) | max \|Min\| |
   |---|---|---|---|---|---|
   | PA | DT° | 1378 | 3 | 0 | 64 |
   | PA | DT°_F | 1378 | 0 | 0 | 4 |
   | ZF | DT° | 666 | 3 | 3 | 32 |
   | ZF | DT°_F | 666 | 0 | 0 | 8 |

   This matches the single track's remark that |Min(D)| can be 4^n in DT°.
3. **Cost of the restriction.** DT°_F ⊆ DT°, so every DT° anchor is a DT°_F anchor. The difference lies
   only before an anchor. Example: {Ind(x=x), Ind(0=x)} has 4 minimal templates in DT° and 2 in DT°_F
   (`tests/test_core.py::test_coincidence_counts`). The prior count of 8 in DT (C8.2) was taken within a
   size bound of 23, which cut off the 24-symbol template f(0)=f(0) ∧ ∀x(f(x)=x → f(Sx)=Sx) → ∀x f(x)=x
   that is below two of the 8.

The code supports both classes (`term_arity0`); all experiments use DT°_F unless E0 or E7 say otherwise.

### 2.2 Refutation is budgeted; failure inheritance is a heuristic for budgeted refuters

With an ideal refuter, which refutes every template having a false instance, inheriting failed pairs is
exact (Prop E3). With a budget it is the natural approximation.

---------------------------------------------------------------------------------------------------------

## 3. Propositions

Notation:
- D is a finite set of sentences in closure-normal form.
- C(D) is its common-prefix tree. A *slot* is a disagreement position.
- 𝒯(D) is C(D) in which every atom node whose subtree contains a slot with a free bound variable in its
  column is made a leaf (an *F-slot*).
- For a slot σ, ȳ_σ is the set of bound variables free in some datum's column at σ. The *own* occurrence is
  M_σ(ȳ_σ), with bodies β_d(σ) obtained by abstracting d|σ over ȳ_σ.
- σ → π ("π derivable from σ") iff there are metavariable-free terms t̄ with β_d(σ)[t̄] = d|π for all d.
- A **normal configuration** consists of:
  - a set S' of slots (own slots) such that no σ ∈ S' is derivable from another member of S';
  - an antichain A ⊇ S' of nodes of 𝒯(D) covering every slot;
  - for each π ∈ A \ S', a choice of ρ ∈ S' with ρ → π, giving the occurrence M_ρ(t̄(ρ,π)).

  Rigid symbols of C(D) fill the rest.

**Prop E1 (normal form; finiteness and well-foundedness of Min in DT°_F). Proved; computed (E0).**
(a) Every normal configuration is a covering DT°_F template.
(b) Every covering DT°_F template T is ≥ some normal configuration.
(c) Hence:
- Min(D) (up to equivalence) is the set of minimal normal configurations, and it is finite;
- every covering template is above a member of Min(D);
- if D ⊆ inst(T*) with T* ∈ DT°_F, some member of Min(D) is ≤ T*.

*Proof.*
(a) By construction:
- own occurrences are patterns whose bodies are β_d(σ);
- derived occurrences hold on every datum by the definition of →;
- the arguments are subterms of the data, so they are metavariable-free;
- every metavariable has its pattern occurrence at its own slot;
- term metavariables are own only at slots with closed columns, so they are 0-ary.

(b) Let T cover D.

*Step 0 (where occurrences sit).*
- By the preservation lemma (prior C1; single track Thm A), rigid symbols of T agree with every datum.
  So the rigid skeleton lies in C(D), and maximal occurrences sit at nodes of C(D) or at slots.
- No occurrence lies strictly below an F-slot ν. Such an occurrence sits at a term position π inside an
  atom, so it is a 0-ary term metavariable with a closed value. But ν contains a slot σ with an open column.
  - σ cannot carry a rigid symbol of T.
  - So some occurrence sits at a position π with ν < π ≤ σ, and π is a term position.
  - Then d|π contains d|σ, which has a variable bound above ν (atoms contain no binders), so d|π is not
    closed: a contradiction.

*Step 1 (push down).* Let M have a pattern occurrence M(z̄) at a node p of 𝒯(D) that is not a slot, so the
data agree on the head h at p. Specialize M := λz̄.B, where B is chosen by the head:
- h a connective or quantifier: B = h(N_1(z̄), …), with a new bound variable added to the arguments under
  a quantifier;
- h an atom that is not an F-slot: the slots below p have closed columns. B is the common part of the
  bodies, with fresh 0-ary term metavariables at those slots, and the bodies agree with this.
- h a leaf: B is the leaf (0, a parameter) or the hole z_k for a common bound variable, which must be among
  z̄. In this case M disappears.
- 0-ary term metavariables at interior term nodes: push down in the same way.

What the specialization preserves:
- The new metavariables have pattern occurrences at p's children.
- At M's other occurrences M(t̄), the datum content is β_d[t̄]. It agrees with B[t̄] on the common part, and
  on the closed parts the values coincide.
- So the result covers D, lies in DT°_F, and is ≤ T.

Each step adds a rigid symbol inside the finite tree 𝒯(D), so the process terminates. Afterwards every
pattern occurrence sits at a slot.

*Step 2 (canonical arguments).*
- If a pattern occurrence M(ȳ) at slot σ has an argument not free in any datum's column, M's values do not
  use that hole. Specialize M := λz̄.M'(z̄ minus the unused holes); this is ≤ and still covers.
- Reorder arguments canonically (equivalence).
- Then M is M_σ up to renaming. Further pattern occurrences of M at other slots count as derived
  occurrences.

*Step 3 (forced arguments).*
- For any occurrence M_σ(ū) at π, β_d(σ)[ū] = d|π for all d.
- Every hole of M_σ occurs free in some β_d(σ), and substitution into a body with a free occurrence of the
  hole is injective in the substituted term.
- So ū = t̄(σ,π). Thus T is a configuration, possibly with a non-independent own set.

*Step 4 (independence).*
- If σ ∈ S' is derivable from ρ ∈ S' \ {σ} via t̄, specialize M_σ := λȳ_σ.M_ρ(t̄).
- This is a legitimate λ-term: the free bound variables of t̄ occur in σ's column, so they lie in ȳ_σ.
- The other occurrences M_σ(ū) become M_ρ(t̄[ū]) = M_ρ(t̄(ρ,π)) by forcedness. M_ρ keeps its pattern
  occurrence.
- The result is ≤ T and covers D, and |S'| decreases by one. Iterating gives a normal configuration ≤ T.

(c) Normal configurations are finitely many: finitely many own sets, antichains and choices.
- Every covering T is ≥ some normal configuration, hence ≥ a minimal one, N₀ say.
- N₀ is minimal among all covering templates. Suppose T' < N₀ covers D. By (b), T' ≥ some normal N₁, so
  N₁ ≤ T' < N₀, contradicting the minimality of N₀ among normal configurations.
- The last clause applies (b) to T*. ∎

For full DT° the same proof works with 𝒯 = C(D). Push-down at atoms then uses term metavariables N_j(z̄) of
full arity. The code implements this as `term_arity0=False`; it is consistent with the single track's Thm B.

*Evidence* (computed): `python3 experiments/e0_crossval.py 14 40 F` and `… 13 40 full`, outputs in
`results/e0_crossval_{F,full}.txt`.
- The independent bounded enumerator is the prior referee C's `rc_enum.enum_covering`, written from scratch
  in de Bruijn levels and imported read-only.
- It ran on 48 data sets: 40 pairs of induction instances from the referee's 52-motive pool, plus 8 others
  (C8.1, numerals, Q-axiom pairs, swapped variables).
- It enumerated 3703 covering DT°_F templates (size ≤ 14) and 2515 covering DT° templates (size ≤ 13).
- Results:
  - every enumerated template is ≥ a computed minimal template, by our matcher and by the referee's;
  - every computed minimal template within the bounds is enumerated;
  - no enumerated template is strictly below a computed minimal one;
  - 0 failures in all four checks.

**Prop E2 (soundness of the oracles). Proved.** Write the evaluator's verdict as True/False/unknown.
- **PA.** A verdict True (False) implies that the universal closure is true (false) in N.
- **ZF.** Assume V ⊨ ZF. A verdict True (False) implies that the universal closure is true (false) in V,
  under every realization ν of the generics. A realization maps each generic G to a set outside E_G that
  differs from the generics created before G.

*Proof.* Induction on the formula, with the environment fixed.

*PA atoms.*
- At numerals the evaluation is exact.
- With symbolic variables, the terms denote polynomials with nonnegative integer coefficients.
- s = t holds identically on N^k iff the polynomials are equal.
- If p_s − p_t has all coefficients ≥ 0 and a positive constant term, then s > t everywhere. The other
  three classifications are symmetric.

*ZF atoms.* E_G is transitive and ν(G) ∉ E_G.
- G ∈ c is False when c ∈ E_G, or when every element of c lies in E_G: otherwise ν(G) ∈ c ⊆ E_G.
- G = c is False when c ∈ E_G.
- G ∈ G is False by Foundation.
- G = H is False for distinct generics, because the later one was created fresh with respect to the
  earlier.
- Every other mixed atom is unknown.

*Connectives.*
- Kleene's strong tables are monotone, so known values stay correct.
- Supervaluation: the actual truth values of the unknown leaves under ν form one of the enumerated
  assignments. Leaves with known values agree under every ν by the induction hypothesis.

*Quantifiers.*
- A bounded quantifier over a concrete set or numeral bound is enumerated exactly.
- PA symbolic step: a verdict for a fresh symbol holds for every value. The numeral search finds genuine
  counterexamples or witnesses.
- ZF unbounded ∀x: given ν and any set a, exactly one of the following holds.
  - a ∈ E (that case was evaluated);
  - a = ν(G) for an in-scope generic G (that case was evaluated);
  - otherwise ν extended by H ↦ a is a realization (case H).

  So all cases True implies True. One case False gives a counterexample. Such an a exists for H, since V
  is not E ∪ {finitely many sets}. Extra HF search values are concrete counterexamples. ∃ is dual.
- Memoization keys on (formula, environment values), so it reuses a verdict only for the same environment.
- Stripping vacuous quantifiers is valid in nonempty domains.

Which ZF axioms the argument uses:
- Foundation, Extensionality (equality of HF sets) and the existence of HF sets;
- that no set contains all sets;
- not Infinity. ∎

*Evidence* (computed, `tests/test_oracles.py`):
- No refutation of 400 random induction instances, 150 universal-axiom instances, Q's axioms, the ZF
  axioms (Infinity included), 120 Separation, 120 ∈-induction and 40 Replacement instances.
- Refutation of the listed false sentences, including the three Π2 comprehension failures above.
- No refutation of any genuine datum in any experiment: E3 "discarded" is 0 for clean data.

**Prop E3 (merge monotonicity; within-schema merges succeed). Proved, given E1.**
(a) Let D ⊆ D', and let the refuter be ideal. If every member of Min(D) is refuted, then every member of
Min(D') is refuted.
(b) If A ∪ B ⊆ inst(T*), with T* ∈ DT°_F and every instance of T* true, then for every *sound* refuter,
whatever its budget, the merge test on A ∪ B succeeds.

*Proof.*
(a) Every T' ∈ Min(D') covers D. By E1(c), T' ≥ some T ∈ Min(D), so inst(T) ⊆ inst(T'), and T's false
instance lies in inst(T').
(b) By E1(c) some T₀ ∈ Min(A ∪ B) has T₀ ≤ T*. Its instances are true, so no sound refuter refutes it. ∎

**Thm E4 (DTRC correctness under refutation separation). Proved.**

Hypotheses:
- Targets T_1..T_k ∈ DT°_F, with every instance true in the world (N or V).
- Data D = ⊔ D_i with D_i ⊆ inst(T_i), each datum an instance of exactly one target.
- The refuter is sound.
- *(S) refutation separation:* for all i ≠ j and all nonempty A ⊆ D_i and B ⊆ D_j, every member of
  Min(A ∪ B) is refuted when the merge test examines it.

Then:
- DTRC discards no datum.
- Its final clusters are exactly the nonempty D_i.
- Each cluster's acceptance set is ∩{inst(T) : T ∈ Min(D_i), T not refuted}. This is the tagged
  refutation-filtered verifier on D_i, with the same refuter verdicts.
- The asserted union satisfies Acc ⊆ ∪_i inst(T_i) (target-soundness). It contains inst(T_i) exactly for
  those i at which the tagged refutation-filtered verifier is exact.

*Proof.*
- Discarding: genuine data are true, and a sound refuter does not refute them.
- Invariant: every cluster is contained in some D_i.
  - It holds for singletons.
  - A merge of clusters from different D_i fails by (S).
  - A merge within one D_i succeeds by E3(b), so it preserves the invariant.
  - Failed pairs are cross-label, and inheritance keeps them cross-label, so inheritance never blocks a
    same-label merge.
- Every pair of current clusters is pushed onto the queue (minimum score 0). Pairs are removed only when
  tested or dead. So the loop ends only when no two clusters share a label.
- The final clusters are therefore the D_i. Per-cluster acceptance then follows by definition, and
  target-soundness by Prop E5. ∎

*Remark.*
- (S) quantifies over all subsets; the algorithm only needs it for the subsets that arise.
- E9 (computed) samples |A|,|B| ∈ {1,2}: 2190/2190 PA-mix and 540/540 ZF-mix cross-target merges were
  refuted.
- The only unrefuted near-miss case (1/1052) is between U_0add data and nested U_add00 data. They share an
  instance of a third target, ?t+0=?t.

**Prop E5 (per-cluster soundness does not depend on the refutation budget). Proved.**
- If a cluster C ⊆ inst(T*), with T* ∈ DT°_F and all instances of T* true, then Acc(C) ⊆ inst(T*) for any
  sound refuter.
- More refutations only make Acc larger, toward exactness.

*Proof.* T₀ from E3(b) is never refuted, so it is one of the intersected templates, and Acc(C) ⊆ inst(T₀) ⊆
inst(T*). ∎

*Consequence.*
- A budgeted refuter can only harm DTRC through *clustering*: a false merge that is not refuted.
- It cannot harm a pure cluster.
- Truth-soundness of a mixed cluster holds whenever one of its surviving minimal templates is valid. This
  is what happens in the residual merges of §5.

**Prop E6 (∈-induction is a first-order pattern in de Bruijn indices, not in the named or level encoding).
Proved; computed (E2).**

Let Z be a first-order metavariable and L = ∀(∀(#0∈#1 → Z) → Z) → ∀Z (de Bruijn indices). Then the
*sentences* matching L are exactly the instances of ∈-induction.

*Proof.*
- An instance Z := ψ is a sentence iff ψ's loose indices are ⊆ {0}, because of the occurrences at depth 1.
- With β := ψ[hole/#0], all three occurrences read β[#0] in their own context: y under ∀x∀y, and x under
  ∀x. So the instance is EInd(λz.β).
- Conversely, EInd(φ) = L[Z := φ(#0)].
- In the level encoding, the first occurrence uses level 1 and the others level 0, so the first-order lgg
  has independent Z₁, Z₂. Then Z₁ := (y ∉ w), Z₂ := (x ∉ w) is a false instance. A refuted example from
  E2: `(Ax.(Ay.y in x -> y in w0) -> ~x in w0) -> (Ax.~x in w0)`. ∎

Status of the other schemas:
- Separation is not first-order in either encoding without a freshness guard: Z at depth 3 may mention b.
  Exhibit: `Ax.Ey.Az.z in y <-> (z in x & ~w0 in y)`.
- Replacement is not first-order in either encoding.

Credit: this is the cases track's Thm B1 table, which also states the guards; I reprove the EInd row here.

**Prop E7 (anchors for one-variable universal targets; = Plotkin's (R)). Proved; computed (E1).**

Let T* contain one 0-ary term metavariable t at rigid positions and no other metavariable, and let
D ⊆ inst(T*). Then Min(D) = {T*} iff the substituted terms do not all have the same head symbol. Leaves (0,
a parameter) count as their own heads. Hence for i.i.d. terms P(not exact after N) = Σ_h p_h^N.

*Proof.*
- (⇐) The t-positions are slots with identical closed columns, and there are no other slots. An interior
  derived occurrence of t at π would need d|π = t_d for all d, impossible since the heads of the t_d
  differ. So the unique normal configuration is T*.
- (⇒) If all heads equal h, C(D) contains h below every t-position. Every covering template obtained by
  E1 is then strictly below T*: it misses instances whose term has another head. ∎

**Known context** (prior work, re-observed here):
- Pattern anti-unification yields T12 on induction (prior C9). Computed here: 0/30 exact; refuted probes in
  E2 and E3.
- The k-union verifier lumps Q's axioms when k−1 slots suffice (prior pa-untagged), and two refutations
  restore the tagged anchor. E6 (computed) reproduces this in DT°_F:
  - **Without negatives:** for every data set, k=8 and k=9 accept 0/8 held-out induction instances. The
    witness union is [∀x?P(x)] + one singleton slot per induction datum.
  - **With negatives, k=8** (one slot left for induction): 8/8, from the anchor pair alone.
  - **With negatives, k=9** (two slots for induction): 0/8 from two induction instances. From three
    instances it is 8/8, whether the third motive is x+0=x or ∃y.x<y: any 2-block split has an anchor
    block.

---------------------------------------------------------------------------------------------------------

## 4. Experiments (commands and outputs)

All commands are run from `code/experiments/` unless noted.

| id | command | output | what it shows |
|---|---|---|---|
| tests | `python3 -m pytest -q tests` (from `code/`) | `results/pytest.txt` | 31 passed: parser round trip; matcher recovers motives (300 PA, 300 ZF); rejects non-instances (incl. captured Separation); anchor → T_ind; non-unitary C8.1 → {G1,G2}; coincidence counts; universal from numerals; Min properties on 60 random sets; oracle soundness samples; refuter; DTRC on small mixes (ARI 1) |
| E0 | `python3 e0_crossval.py 14 40 F`, `… 13 40 full` | `results/e0_crossval_*.txt` | Prop E1 cross-check, 0 failures |
| E1 | `python3 e1_universal.py` | `results/e1_universal.md`, `e1_anchor_cdf.png` | Q1 rates; Gen form accepted |
| E2 | `python3 e2_schemas.py` | `results/e2_schemas.md`, `e2_exactness.png` | Q2 per-schema learners, probes, exhibits |
| E3 | `python3 e3_mix.py` | `results/e3_mix.md` | DTRC vs baselines on PA-mix and ZF-mix, 5 seeds |
| E4 | `python3 e4_stress.py` | `results/e4_stress.md` | near-miss, mistakes (budgets 80/400), unequal frequencies |
| E5 | `python3 e5_curves.py` | `results/e5_curves.md`, `e5_curves.png` | examples to exactness, DTRC vs tagged |
| E6 | `python3 e6_kunion.py` | `results/e6_kunion.md` | k-union verifier with/without negatives |
| E7 | `python3 e7_blowup.py` | `results/e7_blowup.md` | Min blow-up DT° vs DT°_F |
| E9 | `python3 e9_separation.py` | `results/e9_separation.md` | refutation separation rates |

### E1 (Q1)

Per target: 2000 runs, with run r seeded by `random.Random(1000*1000003 + 7919*r)`; N is capped at 40.

| data | targets | DT°_F mean N | median | 95% | fo-lgg mean N | predicted |
|---|---|---|---|---|---|---|
| mixed | x+0=x, x*0=0, 0+x=x, ¬Sx=0, x<Sx | 3.27 | 2 | 7 | 3.27 | 3.25 |
| mixed | x+y=y+x | 4.18 | 3 | 9 | 4.18 | – |
| numerals | (same five) | 8.42 | 6 | 24 | 8.42 | 8.11 |
| numerals | x+y=y+x | 11.85 | 10 | 28 | 11.85 | – |

- The five one-variable targets give identical numbers: the same seeds give the same terms, and exactness
  depends only on heads.
- Two-variable commutativity needs (R) for both variables and (D) (t ≠ u in some datum). This explains the
  extra cost.

### E2 (Q2)

The table is in §0, item 2, and `results/e2_schemas.md`. Further observations:
- The first-order lgg is *complete* earlier than DT°_F (Replacement: 28/30 vs 23/30 at N=2), but unsound.
- The pattern lgg = DT°_F on the three ZF schemas, consistent with "all ZF schemas are Miller patterns"
  (brief Q2; cases Cor F).

### E3 (Q3)

- **PA-mix, 5 seeds.**
  - DTRC: ARI 1.0 every seed; 11/11 exact in 4 seeds and 10/11 in seed 3; held-out 107/107 (98/107 in
    seed 3); 0 non-target probes; 653–1206 oracle calls; 0.4–0.7 s.
  - In seed 3 all x+0=x data except 0+0=0 are successor numerals. 0+0=0 is ambiguous (also an instance of
    0+x=x) and joined the 0+x=x cluster, so x+0=x has no anchor. The tagged learner keeps 0+0=0 under its
    generating label and is exact.
- **ZF-mix, 5 seeds.** DTRC: ARI 1.0, 9/9 exact, 96/96 held-out, 0 non-target, 766–946 calls, 5.6–7.9 s.
- **Baselines per gold tag.** The first-order lgg has 20 non-target probes of 36 (PA; all from induction)
  and 25–45 of 51–62 (ZF), of which 1–7 are refuted. The pattern lgg has 20 non-target probes (PA,
  induction = T12) with 3–8 refuted, and 0 non-target probes on ZF.

### E4 (stress)

**(a) Near-miss targets.**
- PA targets:
  - ?t+0=?t;
  - ?t+1=S?t;
  - ?t*1=?t;
  - 0+?t=?t;
  - (?t+0)+0=?t+0, nested in the first;
  - Ind;
  - IndSwap, the conjuncts swapped;
  - IndCurry, the curried form.
- ZF targets: Sep, SepSwap (φ ∧ x∈a), Rep, EInd, the foundation schema, and the Foundation axiom.
- ZF: all 3 seeds perfect (6/6 exact, ARI 1).
- PA: Ind, IndSwap and IndCurry are always separated.
  - The nested pair always merges, which is truth-sound.
  - Ambiguous numerals such as 0+1=1 (an instance of both 0+?t=?t and ?t+1=S?t) go to one cluster.
  - In seed 0 two pairs merged into the *valid* template 5+?t=S⁵?t (resp. 4+…). This gave 4 non-target
    probes, 0 refuted.
- E9 likewise finds no unrefuted cross-target merge among random small samples of the 8 near-miss targets,
  except the nested/ambiguous one.

**(b) Mistakes.**
- PA: 8 mistakes plus 3 true non-targets per seed:
  - wrong step φ(x)→φ(x);
  - wrong base φ(S0);
  - conclusion ∀xφ(Sx), a true non-instance;
  - n+0=0.
- ZF: 6 mistakes:
  - Separation with b free in φ;
  - ∀x(φ→φ)→∀xφ;
  - complement comprehension.
- Refuted mistakes (2–3 per seed) are discarded. The rest become singletons, accepting themselves:
  target-unsound, and false if the mistake is false but unrefuted. Or they merge.
- PA merges are always into *valid* templates. Example: (?t<0 ∧ ∀x(P(x)→P(Sx))) → ∀xQ(x) from data with
  false base clauses. 0 refuted probes.
- ZF at budget 80: Separation-capture mistakes merge into Separation clusters in all 3 seeds. The merged templates were false in every case inspected (refuted at budget 400), for example
  ∀a∃b∀x(x∈b ↔ x∈a ∧ (P(x,b) → Q(x,a))). The probes found no refuted sentence. At budget 400:
  - seed 2 is clean (ARI 1.0, mistakes discarded or singletons);
  - seeds 0 and 1 keep one Separation-capture merge each;
  - the cost is about 4× (about 30 s vs 10 s per run).
- Exactness of the clean targets is unaffected (11/11, 9/9): contaminated clusters split off, and a pure
  cluster per target remains.

**(c) Unequal frequencies.**
- Targets with ≥ 4 instances are learned exactly in most seeds.
- Rep with 4 instances: exact 2/3. x*0=0 with 3 instances: exact 2/3.
- Targets with one instance are not generalized: EInd 0/30 held-out, 0+x=x 4/20. The exception is when an
  ambiguous datum supplies the anchor (0+2=2 together with 0+0=0, seed 2).

### E5 (examples to exactness)

| mix | learner | N=5 | 10 | 20 | 30 | 50 | 80 | 120 |
|---|---|---|---|---|---|---|---|---|
| PA (11) | DTRC | 2.0 | 3.4 | 5.2 | 6.2 | 8.4 | 10.0 | 10.8 |
| PA | tagged + refutation | 2.0 | 3.2 | 5.2 | 6.2 | 8.6 | 10.0 | 11.0 |
| PA | tagged | 2.0 | 3.2 | 5.2 | 6.2 | 8.6 | 10.0 | 11.0 |
| ZF (9) | all three | 1.8 | 3.6 | 5.2 | 6.8 | 7.8 | 9.0 | 9.0 |

- The curves are dominated by when each single axiom first appears (p = 0.02 or 0.03 per item). The schemas
  themselves are exact after about 5–20 examples.
- The DTRC–tagged differences are all on x+0=x / 0+x=x and come from ambiguous data (0+0=0).
- DTRC cost per run: PA ≤ 1.3 s; ZF ≤ 17 s at N=120.

---------------------------------------------------------------------------------------------------------

## 5. What fails, and limitations (honest list)

1. **Valid residual merges.** Refutation can never separate two targets when the merged minimal template
   has no false instance (computed, E4). Observed:
   - 5+?t=S⁵?t;
   - (?t<0 ∧ …) → …;
   - (∀x(P(x)→x=x)) → ∀x(x=x);
   - nested targets.

   DTRC is then truth-sound but not target-sound. No world-based method can do better: the merged set is
   true.
2. **Ambiguous data.** Data in two targets' instance sets make the label partition ill-defined. They can
   move a target's only anchor into another cluster (E3 seed 3) or supply one (E4c seed 2).
3. **Budgeted refutation.** Mistakes whose merges are false but hard to refute survive at budget 80, and
   some at 400 (E4b). Pools and enumeration order are heuristic.

   The ZF evaluator cannot refute sentences whose refutation needs a witness *constructed* from a generic,
   e.g. ∀a∃b∀x(x∈b ↔ a∈x) (proper class {x : a∈x}). The PA evaluator certifies no Π1 truth beyond
   polynomial identities and Kleene/supervaluation reasoning. It is a truth-in-N oracle, not a PA-provability
   oracle.
4. **Singletons.** A one-instance target is never generalized: one instance is never an anchor (prior C3).
   An unrefuted mistake becomes a singleton that the union accepts.

   Ground axioms (Q's, ZF's) are also singletons, so without labels or frequencies a singleton mistake
   cannot be told apart from an axiom.
5. **The class.** DT°_F excludes positive-arity term metavariables (§2.1). Targets that need them would
   need full DT°, where Min(D) can be exponential (E7; single track: 4^n). The single track's
   polynomial feature test is the way out and is not implemented here.
6. **Greedy order.** Without (S), the final partition can depend on the merge order. I have no theorem
   for that case.
7. **Skeleton clustering.** Skeleton clustering with the true k is perfect on ZF-mix, whose targets have
   distinct skeletons. So in ZF-mix refutation is needed only when k is unknown, or for soundness on PA.
8. **Scale.** Pure Python; the ZF oracle dominates the run time. Largest run: ZF stream N=120, 17 s.

## 6. Open problems / conjectures

- *Conjecture.* With the ideal refuter, (S) holds for every pair of distinct targets among the PA-mix and
  ZF-mix targets. That is, every minimal covering template of a cross-target set has a false instance.
  E9 supports this on small samples. A proof would go target pair by target pair, as in the prior
  pa-untagged checks.
- Characterize when a cross-target merge is *valid* (unrefutable) in terms of the targets alone. In E4
  these come from coincidences such as a false base clause or a literal ∀x(x=x).
- Refuting Π2 comprehension failures that need constructed witnesses ({x : a∈x}) requires extending
  generics with term-like constructions ({G}, G∪{c}).
