# Track "cases" — final record: learning ∀xφ from its instances (Q1) and learning the ZF(C) schemas (Q2)

Revised after the adversarial referee report (`referee.md`). This file supersedes `notes.md` and is
self-contained: every statement of `notes.md` is restated here, corrected where the referee found a problem;
material added in the revision is marked **[new]** or **[revised]**. The section *Verification log* at the end
lists every referee point and its resolution. Nothing from `notes.md` has been dropped.

Status labels: **proved** (complete proof here), **computed** (script run here; command and output file named),
**known** (literature; citations I am unsure of are marked "(I believe)" or "unverified"), **conjecture**, **open**.
All scripts are in this directory and are run as `cd research/tracks/cases && python3 <script> [args]`; outputs
are the `.out` files named in §4. Library files: `st_core.py` (set-theory templates, de Bruijn terms, plugging,
SO°-matching, subsumption, the two first-order encodings, the n-ary higher-order pattern lgg), `st_enum.py`
(covering-template enumerators), `st_pool.py` (bodies φ), `dt_search.py` **[new]** (bounded search for covering
second-order templates that miss a probe instance). The first-order lgg is always the parent report's T1 code
(`inferential-learning/research/theory/T1-code/terms.py`, `lgg_list`).

References to the parent report use its labels (lem:setting:recover = Plotkin's witness lemma, thm:setting:lgg,
lem:setting:guard = most specific guards, lem:imitation:cautious, thm:imitation:anchor, thm:imitation:coupon);
"prior C2(a), C4, C6.1, C7, C9" refer to `prior/induction/second-order-notes.md`.

---------------------------------------------------------------------------------------------------------------

## 0. Answers in brief

**Q1 (∀xφ from sentences φ(t)).**

1. *What is learned is the instance schema; first-order anti-unification learns it, provided metavariables cannot
   take bound variables* **[revised]**. The target σ_φ = φ(z₁,…,z_k) (term metavariables at the free occurrences
   of the x_i) is a first-order pattern. D = {φ(t̄_j)} is an anchor iff lgg(D) ≡ σ_φ iff Plotkin's witness events
   hold: (R_i) the closed terms substituted for x_i do not all have the same root symbol, and (D_{ii′}) for i ≠ i′
   some datum substitutes different terms for x_i and x_{i′} (Thm A2, proved; computed on 141 736 data sets, and by
   the referee on 36 000 random formulas with binders). Repeated occurrences are tied automatically; closed
   subterms of φ that coincide with data terms are harmless; one datum is never an anchor, two suffice. The same
   events characterize anchors in the determinate class DT° (Prop A2′, proved; **now also computed**, 99/99 pairs
   on five formulas, three with binders); in SO° they do not (explicit counterexamples, also with binders). Rates:
   P[no anchor after N] = Σ_f p_f^N for one variable, exact formulas for two, ≤ (2k + C(k,2))·e^{−Nρ} in general
   with ρ defined as in the parent report (Thm A3).
   **Variable convention.** Under the λ/locally-nameless convention of the brief (metavariable values contain no
   bound variables, only parameters), inst(σ_φ) is exactly the closed-instance schema (or, with parameters, the
   open-instance schema). In the *named* or *de Bruijn first-order* syntax, where a term metavariable may take a
   bound-variable name or an index, inst(σ_φ) also contains **capture instances** whenever some free x_i lies under
   a binder, e.g. ∃y¬(y = y) from φ(x) = ∃y¬(y = x); these can be false in every structure (Prop A4′, proved;
   computed). Then the unguarded cautious verifier is unsound outright, not merely ω-incomplete. A guard
   "nobound(z)" (no bound variable in the value of z) is learned from genuine data by the most-specific-guard rule
   and restores exactness.
2. *The instance schema is not the sentence ∀xφ (the ω-gap).* For a structure M with closed-term substructure
   M₀: "M ⊨ ∀xφ iff M ⊨ φ(t) for all closed t, for every φ" holds iff M₀ ≼ M (Tarski–Vaught; Prop A5). It holds
   in term-generated structures such as (ℕ;0,S,+,·), and fails in ℝ as an ordered field (φ(x) = ¬(x·x = 1+1)), in
   V with closed terms ∅,{·,·},∪ (φ(x) = "x is not inductive", refuted by Infinity), and in nonstandard models of
   PA. Derivability: Q ⊢ 0+n̄ = n̄ for every n, but Q ⊬ ∀x(0+x = x) (explicit model, Ex. A8, proved + computed).
3. *Consequences for a learner (Prop A10, A11).* From closed instances the sound target is the closed-instance
   schema. Whether the cautious learner silently takes the ω-step depends on whether parameters are allowed as
   instances: if they are, the learned schema contains φ(p̄), whose universal closure is ∀x̄φ, so the learner
   commits the ω-rule step after the first anchor; with a guard "closed(z)" the most-specific-guard learner learns
   closedness from closed data and never commits it; one datum at a parameter drops the guard, and then ∀x̄φ is
   derivable by trusted Gen. **[revised]** In the named/de Bruijn first-order syntax the unguarded learner in
   addition accepts capture instances (point 1), which a refutation channel may never catch if they are only
   false outside the intended model, and which are false everywhere in the worst case. The ω-step is truth-safe
   exactly when M₀ ≼ M. A false ∀xφ whose closed instances are all true is never refuted by evaluating closed
   instances; it is refuted by the coherence channel iff it is inconsistent with the designated truths.

**Q2 (ZF(C) schemas).**

4. *All ZF schemas are higher-order (Miller) patterns, hence in DT°* — Separation, Collection, Replacement
   (∃! as a primitive binder, ∃! spelled out, Jech's image form), ∈-induction. Foundation and every other ZFC axiom
   except the two schemas is a single sentence, its own anchor **[new remark]**. The language {∈,=} has no function
   symbols, so schema instances only *rename* variables; this is the structural difference from PA induction.
5. *Anchors (Thm E, proved; computed):* for a pattern target with one metavariable P of arity n, D is an anchor
   in any class between the pattern templates and SO° iff (R) the bodies' main symbols are not all equal and (N_i)
   for each argument i of P some body has argument i free. Two instances suffice. The higher-order pattern lgg
   (Pfenning 1991; Baumgartner–Kutsia–Levy–Villaret 2017) recovers every ZF schema from any anchor and is sound
   before (Cor F). Rates: exact inclusion–exclusion formula (Thm G).
   **[new] Several metavariables (Thm E′, proved; computed).** For pattern targets with several metavariables a
   third, Plotkin-(D)-type event is needed, and *it depends on the class*: in PAT it says that no bijective
   renaming of arguments turns one metavariable's bodies into another's in all data; in DT° no map at all (also
   non-injective, also into parameters) may do so; in SO° root-level distinctness suffices and the DT° event is
   necessary. All three classes have different anchors (explicit separating examples). ZF does not need this, but
   untagged mixtures (Q3) will.
6. *Whether first-order lgg works depends on the formulation and the encoding (Thm B1).* A pattern template is a
   (guarded) first-order pattern in the **named** encoding with textbook names iff P has the same argument *names*
   at every occurrence, and in the **de Bruijn** encoding iff P has the same argument *indices* at every occurrence.
   Results (table §2.2): Separation first-order in both, but with a freshness guard in both (Russell instance);
   ∈-induction not first-order named, first-order de Bruijn; Collection and ∃!-Replacement first-order named (guard
   Y ∉ FV(φ)), not de Bruijn; spelled-out Replacement (Kunen-style) first-order in neither, but its named lgg is a
   truth-sound over-generalization (Prop C3); Jech's Replacement first-order in neither, with ZF-refutable lgg
   instances. For the non-first-order cases no finite union of first-order schemas (with freshness guards) covers
   the schema without a false member (Thm C2).
   **[new] α-variation (Prop B1α).** If the community α-renames the frame's bound variables, the named criterion
   becomes "P is applied to the same *binders* at every occurrence": only Separation (both forms) survives;
   Collection, ∃!-Replacement and spelled-out Replacement become non-first-order in the named encoding, Thm C2
   extends to them, and the truth-sound over-generalization of Prop C3 disappears (the lgg acquires ZF-refutable
   instances).
7. *Corrections to the brief's §5 proposal:* ∈-induction is a de Bruijn first-order pattern; freshness is automatic
   only in the λ/pattern encoding, not in the de Bruijn *first-order* encoding (Separation needs "#1 not loose";
   Collection without A needs "#2 not loose"); Collection with A in φ is not a de Bruijn first-order pattern;
   spelled-out Replacement in Kunen's form gives a truth-sound (not false) first-order lgg with textbook names. The
   brief's main claim — all ZF schemas are in the pattern fragment, pattern anti-unification and the DT° learner
   both work — is confirmed (and confirmed independently by the referee).
8. **[new]** *C3 sharpened (Prop C3′, proved):* over any base theory B, all guarded instances of that named lgg are
   B-theorems iff B proves the Collection schema. So its truth-soundness over ZF without Foundation is exactly the
   question whether ZF − Foundation proves Collection (status unknown to me).

---------------------------------------------------------------------------------------------------------------

## 1. Conventions and the encodings

* Sentences are trees. A *schema* in the first-order sense is a tree with metavariables at some leaves (parent
  report, def:setting:schema); inst(σ) its ground instances, ⪰ "at least as general".
* **Named encoding.** Object variables are constants of the step signature; binders are `all(x, body)`. A schema
  is formed textually; freshness/substitutability side conditions are *guards* (lem:setting:guard), here from the
  family Φ = {fresh(v, Z): v a variable name of the frame, Z a formula metavariable}. Unless said otherwise, data
  use the textbook names for the frame's variables (Part 2); §2.2a drops this assumption.
* **de Bruijn first-order encoding.** Bound variables are indices #k (constants); a first-order metavariable at
  depth d may be instantiated by a de Bruijn term whose loose indices refer to the d enclosing binders. Only
  well-formed (closed) results are steps; guards "loose(Z) ⊆ I" when needed.
* **λ / pattern encoding (DT°).** As in the brief §3 and prior §1: metavariables of type ι^n→o or ι^n→ι are applied
  to metavariable-free argument terms, values are closed λ-bodies λz̄.β whose free names are parameters only,
  instances are obtained by one-step plugging. A *pattern occurrence* applies the metavariable to pairwise
  distinct bound variables. PAT = templates all of whose occurrences are pattern occurrences (Miller 1991),
  DT° = every metavariable has a rigid pattern occurrence, SO° = all occurrences rigid with metavariable-free
  arguments (no determinacy). PAT ⊆ DT° ⊆ SO°.
* **Closure-normal form.** Data are formulas whose free names are parameters, read under universal closure; the
  outer parameter prefix ∀w̄ of a schema instance is dropped. The frame's own variables (Separation's z,
  Replacement's A) stay bound in the frame (§2.1).
* **[revised] Variable convention for Part 1.** The default is the λ convention (term metavariables take terms
  whose only variables are parameters). The named (N) and de Bruijn first-order (dB) syntaxes for Q1 are treated
  explicitly in §1.5 (Prop A4′); there a term metavariable may take any term of the step language, including
  bound-variable names or indices.

---------------------------------------------------------------------------------------------------------------

## PART 1. Q1: learning ∀xφ from instances φ(t)

### 1.1 Formalization [revised]

Fix a first-order language L with at least one constant and a formula φ(x₁,…,x_k), each x_i free in φ (a variable
that does not occur free can be dropped; if none occurs, the target is the single sentence φ). Let
σ_φ := φ[z₁/x₁,…,z_k/x_k] with term metavariables z_i placed at the *free* occurrences of x_i (bound occurrences of
the same name are untouched; in the named encoding they are constants).

* closed-instance schema: inst_c(φ) = {φ(t̄): t̄ closed (variable-free) L-terms};
* open-instance schema: inst_o(φ) = {φ(t̄): t̄ terms over L ∪ Par, the substitution capture-free}, with parameters
  Par (closure-normal form).

**Convention-dependence (proved).** Under the λ convention, inst(σ_φ) = inst_c(φ) if the step language has no
parameters and inst(σ_φ) = inst_o(φ) if it has: the admissible values are exactly the terms over L (resp. L ∪ Par),
and such terms contain no variable that a binder of φ could capture. In the named first-order syntax, by contrast,
a metavariable may take a bound-variable name: φ(x) = ∃y¬(y = x) and z := y give ∃y¬(y = y). In the de Bruijn
*first-order* syntax capture happens by index: ∃¬(#0 = z) with z := #0. (The sentence "in de Bruijn syntax no capture
is possible" of `notes.md` was true only of the λ/locally-nameless convention, in which metavariable values have
no loose indices; Part 2 shows index capture for Separation and Collection, §2.4(7).) Prop A4′ (§1.5) gives the exact
extent of capture.

Metavariables are sorted (term positions only); the lgg of sorted data is sorted. Throughout, (H) denotes the
richness assumption: for every k there are closed terms t₁…t_k pairwise distinct and t′₁…t′_k pairwise distinct with
root(t_i) ≠ root(t′_i). It holds for the PA language (t_i = S^i0, t′_i = 0+S^i0) and the ordered-field language
(t_i = 1+(…), t′_i = 1·(…)).

### 1.2 Prop A1 (instance sets determine schemas) — proved

Under (H), for first-order schemas σ (metavariables at term positions) and τ: inst(σ) ⊆ inst(τ) iff σ ⪯ τ. Only
closed instances of σ are used, so the statement and proof hold in all three syntaxes.

*Proof.* (⇐) trivial. (⇒) Put θ₀(z_i) = t_i and θ₁(z_i) = t′_i. The roots of θ₀z_i, θ₁z_i differ, and θ₀z_i ≠ θ₀z_{i′}
for i ≠ i′, so both witness events of lem:setting:recover hold and lgg(σθ₀, σθ₁) ≡ σ. Both instances lie in inst(τ),
so τ ⪰ lgg(σθ₀, σθ₁) ≡ σ by thm:setting:lgg. ∎

(computed: `q1_lgg.py` (2) — for all six test formulas the lgg of the two generic instances equals σ_φ.)

### 1.3 Thm A2 (anchors for the instance schema) — proved; computed

Let D = {φ(t̄₁),…,φ(t̄_N)} ⊆ inst_c(φ), N ≥ 1, (H). Then TFAE:
(i) D is an anchor for inst_c(φ) in H₁ (single first-order schemas): every τ ∈ H₁ with D ⊆ inst(τ) has
inst(τ) ⊇ inst_c(φ);
(ii) lgg(D) ≡ σ_φ;
(iii) (R_i) for each i, the roots of t_{1,i},…,t_{N,i} are not all equal; and (D_{ii′}) for each i < i′ there is j with
t_{j,i} ≠ t_{j,i′}.
The theorem holds in all three syntaxes (λ, N, dB): anchor-hood only asks for inst(τ) ⊇ inst_c(φ), and all
instances used in the proof are closed.

*Proof.* (ii)⇔(iii) is lem:setting:recover with θ_j(z_i) = t_{j,i}; every z_i occurs in σ_φ. (ii)⇒(i): every τ with
D ⊆ inst(τ) has τ ⪰ lgg(D) ≡ σ_φ, so inst(τ) ⊇ inst(σ_φ) ⊇ inst_c(φ). (i)⇒(ii): lgg(D) ∈ H₁ covers D, so
inst(lgg D) ⊇ inst_c(φ), which contains the two closed (H)-instances of A1's proof; hence lgg(D) ⪰ σ_φ; and
lgg(D) ⪯ σ_φ since σ_φ covers D. ∎

Corner cases, all covered by the theorem:
* *Tied positions.* If x_i occurs m times, σ_φ has z_i m times; Reynolds' table assigns one variable per column, and
  all m columns equal (t_{1,i},…,t_{N,i}). No witness event beyond (R_i) is needed.
* *Several variables.* (D_{ii′}) is needed: on diagonal data φ(t,t) the lgg of x+y=y+x is z+z=z+z, a sound
  specialization (computed).
* *Closed subterms of φ equal to data terms.* Columns at non-x positions are constant, so they never merge with an
  x-column unless all data terms equal that constant, which is already a failure of (R_i). Example computed:
  φ = (x+S0 = Sx) with data terms S0 and 0 recovers σ_φ; with S0 and SS0 (both root S) the lgg is
  S(z)+S0 = SS(z), the (R)-failure.
* *Bound occurrences of the same name* (named encoding, φ = x=0 ∧ ∀x(x=x)): constant columns; recovered.
* *Anchor size.* One datum is never an anchor (R fails); two data t̄, t̄′ with pairwise distinct components and
  componentwise different roots are an anchor.

*Evidence.* `q1_lgg.py` (1) → `q1_lgg.out`: closed-term pool of size ≤ 4 (12 terms); all pairs and triples for four
one-variable formulas (286 data sets each) and 70 296 data sets each for two two-variable formulas: "lgg ≡ σ_φ ⟺
(R)∧(D)" on all of them (re-run in this revision: identical output). Independent: the referee's own lgg on 600 random
PA formulas with binders, up to three variables, repeated occurrences and closed subterms from the data pool:
36 000/36 000 (`referee_code/r1_q1.out` (1)).

**Prop A2′ (the same events in DT°; not in SO°) — proved; computed [evidence extended].** If the hypothesis class is
enlarged to the determinate second-order templates DT° (λ convention; metavariables of any arity, each with a rigid
pattern occurrence, other occurrences applied to metavariable-free argument terms, which in the PA language include
closed terms such as S0), D ⊆ inst_c(φ) is still an anchor iff (R) and (D). In SO° (no pattern occurrence required)
this fails for the PA language, with and without binders in φ.

*Proof (DT°).* (⇒ fails if (R) or (D) fails) the first-order witnesses of A2 lie in DT°. (⇐) Let T ∈ DT° cover D. By
(R) every x-position is a disagreement position, so T's rigid skeleton is a prefix of φ's skeleton (prior C2(a)).
Let M have a pattern occurrence M(ū¹) at c₁ (ū¹ distinct bound variables) and further occurrences M(ū^s) at c_s; in
datum j its body β_j is unique on the used holes: D_j|c₁ with the variables ū¹ abstracted (other context variables
cannot occur, as β_j has no free bound variables). Let κ(c) := σ_φ|c. At a z_i-position p of κ(c₁), D_j|c₁ has the
closed term t_{j,i}; holes of β_j sit only at occurrences of the variables ū¹, so β_j|p = t_{j,i} and
D_j|c_s = β_j[ū^s] also has t_{j,i} at p. Positions of κ(c₁) and κ(c_s) agree off hole positions; if κ(c_s) had a rigid
symbol at p, all t_{j,i} would share its root (contradicting (R_i)), and if κ(c_s) had z_{i′} at a position where κ(c₁)
is rigid, all t_{j,i′} would share that root, or (if the position is a hole of β_j) all t_{j,i′} would equal the same
argument term of M(ū^s) — a bound variable (impossible: t_{j,i′} closed) or one closed term (contradicting (R_{i′})).
So κ(c_s)|p = z_{i′} with t_{j,i′} = t_{j,i} for all j, whence i′ = i by (D_{ii′}). Let B_M be κ(c₁) with its
context-variable leaves replaced by the corresponding holes; then B_M[ū^s] = κ(c_s) for all s, and σ(M) := λh̄.B_M
gives Tσ↓ = σ_φ, i.e. T ⪰ σ_φ. ∎

*SO° counterexample (computed, `q1_lgg.py` (5); referee brute force over 2278 bodies, `referee_code/r1_q1.out` (3)).*
For φ(x) = (x+0 = x), T := f(S0) + f(0) = f(S0) (f a unary term metavariable with ground arguments only, so T ∉ DT°)
covers 0+0=0 (f := λh.0) and S0+0=S0 (f := λh.h), a pair with (R), but misses SS0+0 = SS0: a body β with β[0] = 0 is
h or 0, and then β[S0] ∈ {S0, 0}. This is the Q1 analogue of the prior C7 "shielding" phenomenon; determinacy
removes it.

*Evidence for the DT° half and SO° failures with binders* **[new]** (`q1_dt.py` → `q1_dt.out`, 7 s). Bounded search
`dt_search.search` over single-group templates (one shared metavariable at up to 3 pairwise incomparable positions,
arguments from the bound variables in scope and the closed terms 0, S0, arity ≤ 2 (≤ 1 for groups of size 3); fresh
fully applied metavariables elsewhere), probes = 9 genuine instances; a pair is "non-anchor" iff some covering
template misses a probe. (Why one shared group is the relevant search space: in the proof above a covering T fails to
be ⪰ σ_φ only through one metavariable whose occurrences cannot be reconciled; replacing all other metavariables by
fresh fully applied single occurrences keeps coverage. The search is bounded, so a "no witness" verdict is evidence.)

| φ | pairs | DT°: anchor ⟺ prediction | DT° covering templates seen | SO°: anchors / pairs with the DT° events |
|---|---|---|---|---|
| x+0=x | 21 | 21/21 | 110 | 16/17 |
| ∀y(x+y=y+x) | 21 | 21/21 | 301 | 16/17 |
| ∀y(y=x → x=y) ∧ x=x | 21 | 21/21 | 1130 | 16/17 |
| ∃y(y=Sx) | 21 | 21/21 | 131 | 16/17 |
| x+y=y+x (two variables; (R₁),(R₂),(D₁₂)) | 15 | 15/15 | 78 | 5/6 |

SO° non-anchors with the DT° events, from data terms 0 and S0 (each misses the instance at SS0 or SSS0; templates
as printed in `q1_dt.out`): ∀y(G(0,S0) + G(y,y) = y + F(y)); ∀y(G(y,y) → F(y) = y) ∧ G(0,S0) (G formula-valued:
λh₁h₂.(h₁ = 0) on the first datum, λh₁h₂.(h₂ = S0) on the second); ∃y(G(y,y) = S G(0,S0)); and, for two variables,
G(0,S0) = G(S0,0) on data (0,S0),(S0,0). In each, G uses its first argument on one datum and its second on the other;
without a pattern occurrence nothing forces the two choices to agree. (The referee found the same phenomenon independently, `referee_code/r5_q1_dt.out`.)

### 1.4 Thm A3 (rates) — proved; computed [statement completed]

Data i.i.d.: t̄ ~ Λ. Let p_{i,f} = Λ(root t_i = f) and c_{ii′} = Λ(t_i = t_{i′}).
(a) k = 1: P[D_N is not an anchor] = Σ_f p_f^N exactly.
(b) k = 2: P = Σ_f a_f^N + Σ_g b_g^N + c^N − Σ_{f,g} d_{fg}^N − Σ_f e_f^N, with a_f = Λ(root t₁ = f),
b_g = Λ(root t₂ = g), c = Λ(t₁ = t₂), d_{fg} = Λ(root t₁ = f, root t₂ = g), e_f = Λ(root t₁ = f, t₁ = t₂). For i.i.d.
components with root law p and term law μ: P = 2S − S² + c^N − C, S = Σ_f p_f^N, C = Σ_f c_f^N,
c_f = Σ_{root t = f} μ(t)².
(c) In general P ≤ Σ_i Σ_f p_{i,f}^N + Σ_{i<i′} c_{ii′}^N ≤ (2k + C(k,2))(1−ρ)^N ≤ (2k + C(k,2)) e^{−Nρ}, where, as
in thm:imitation:coupon (with π = 1, one schema), ρ_i := max_{G} min(Λ(root t_i ∈ G), Λ(root t_i ∉ G)) (the best root
split), r_{ii′} := Λ(t_i ≠ t_{i′}), and ρ := min(min_i ρ_i, min_{i<i′} r_{ii′}).

*Proof.* "Not an anchor" = ⋃_i ¬R_i ∪ ⋃ ¬D_{ii′} (A2). (a) ¬R = disjoint union of A_f = "all roots f". (b)
Inclusion–exclusion over A = ⋃_f A_f, B = ⋃_g B_g, E = ¬D: A_f ∩ A_{f′} = ∅ for f ≠ f′, P(A_f ∩ B_g) = d_{fg}^N,
P(A_f ∩ E) = P(B_f ∩ E) = e_f^N, and A_f ∩ B_g ∩ E = ∅ unless f = g, when it is A_f ∩ E. (c) Union bound; for each
i, the events "all roots = f" (f ∈ G) are disjoint subsets of "all roots in G" for the best split G, so
Σ_f p_{i,f}^N ≤ Λ(root ∈ G)^N + Λ(root ∉ G)^N ≤ 2(1−ρ_i)^N; and c_{ii′}^N = (1 − r_{ii′})^N; finally 1−ρ ≤ e^{−ρ}. ∎

*Evidence (computed, `q1_lgg.py` (4)).* Root law 0:.4, S:.3, +:.2, ·:.1 (Galton–Watson, depth ≤ 4), 20 000 trials:

| N | exact k=1 | MC k=1 | exact k=2 | MC k=2 | bound k=1 | bound k=2 |
|---|---|---|---|---|---|---|
| 2 | .3000 | .2979 | .5157 | .5173 | .736 | 1 |
| 4 | .0354 | .0341 | .0699 | .0684 | .271 | .677 |
| 6 | .0049 | .0046 | .0098 | .0096 | .100 | .249 |
| 10 | .00011 | .00010 | .00022 | .00025 | .013 | .034 |

The exact values agree with Monte Carlo and lie below the bound of (c). N for δ = 0.01: exact 6 (k = 1) and 6
(k = 2); the bound's sufficient N: 11 and 13 (ρ = 0.5) — a factor of about 2. The referee re-derived (b) and checked
it against Monte Carlo for a non-i.i.d. joint law (P[t₂ = t₁ forced] = 0.3; `referee_code/r1_q1.out` (5)).

### 1.5 Open-term data, guards, capture and the hidden ω-step — Prop A4, A4′

**Prop A4 [revised] — proved; computed.**
(a) inst_o(φ) contains φ(p̄) with distinct parameters, whose universal closure is (α-equivalent to) ∀x̄φ; every member
of inst_o(φ) is FOL-derivable from ∀x̄φ, and ∀x̄φ from φ(p̄) by Gen. So, with trusted first-order logic, inst_o(φ) and
∀x̄φ are interderivable.
(b) *Under the λ convention*, if the step language contains parameters, inst_c(φ) is not H₁-closed:
cl_{H₁}(inst_c φ) := ⋂{inst τ: τ ∈ H₁, inst τ ⊇ inst_c φ} = inst(σ_φ) = inst_o(φ) ⊋ inst_c(φ). Hence (prior C6.1) once the
closed data contain an anchor, the cautious H₁-verifier accepts φ(p̄), i.e. it takes the ω-rule step "all closed
instances ⇒ ∀x̄φ" although no datum licenses it. *In the named/de Bruijn first-order syntax*,
cl_{H₁}(inst_c φ) = inst(σ_φ) is larger still: it contains the capture instances of Prop A4′.
*Proof.* Every τ ⊇ inst_c(φ) contains an anchor (two closed (H)-instances), hence τ ⪰ σ_φ (A2); σ_φ itself contains
inst_c(φ). So cl = inst(σ_φ), which is inst_o(φ) under the λ convention (§1.1). ∎
(c) With the guard family Φ ∋ closed(z_i) ("the value of z_i contains no variable or parameter"),
inst_c(φ) = inst(σ_φ, {closed(z_i)}) is realizable in every syntax; by lem:setting:guard the learned guard set is the
set of guards true on all data, so closed data teach closedness and the learner never accepts φ(p̄) (nor any capture
instance, since closed values contain no variables); one datum with a parameter at z_i deletes closed(z_i).

*Evidence.* `q1_lgg.py` (3): data 0+0=0, 0+S0=S0 → lgg 0+z=z with learned guard closed(z): accepts 0+SS0=SS0, rejects
0+p₂=p₂ and 0+p₁·p₂ = p₁·p₂; after adding 0+(p₁+S0) = p₁+S0 the guard is gone and 0+p₂=p₂ (≡ ∀x(0+x=x)) is accepted.

**Prop A4′ (capture in the named and de Bruijn first-order syntax) [new] — proved; computed.** Work in syntax (N) or
(dB) (§1). Say that a value θ(z_i) is *captured* if it contains a variable bound at some free occurrence of x_i in φ
(N: a name y such that the occurrence lies in the scope of a binder of y; dB: an index that, read at the occurrence,
refers to an enclosing binder). Let Cap(φ) be the set of steps σ_φθ in which some θ(z_i) is captured.
(a) inst(σ_φ) = inst_c(φ) ∪ inst_o(φ) ∪ Cap(φ) (the middle term only when parameters are steps), and Cap(φ) is
disjoint from inst_o(φ).
(b) Cap(φ) ≠ ∅ exactly in these cases: (N), steps = sentences: some x_i has a variable name bound at *every* free
occurrence of x_i; (N), free names read as parameters: some free occurrence of some x_i lies in the scope of a binder;
(dB): for some i every free occurrence of x_i lies under at least one binder.
(c) Capture instances can be false in every structure although every genuine instance is true in every structure
with at least two elements: φ(x) = ∃y¬(y = x), capture ∃y¬(y = y). They can be false in the intended model although
∀xφ is logically valid: φ(x) = ∃y(y = Sx), capture ∃y(y = Sy), false in ℕ.
(d) Consequently, whenever Cap(φ) ≠ ∅, the unguarded cautious H₁ verifier, once the data contain an anchor, accepts
sentences outside inst_o(φ), some of which (for suitable φ) are false in every structure: it is unsound outright,
not merely ω-incomplete.
(e) Guards: let Φ ⊇ {closed(z_i), nocap(z_i)}, where nocap(z_i) says that θ(z_i) is captured at no free occurrence of
x_i (the free-for condition; with parameter names disjoint from bound-variable names it is "θ(z_i) contains no
bound-variable name / no index", i.e. the λ convention as a guard). Most specific guards: on closed data both are
learned, and the accepted set is inst_c(φ); after a parameter datum at z_i, closed(z_i) is dropped but nocap(z_i) is
kept (genuine data are capture-free), and the accepted set is inst_o(φ). Capture instances are never accepted.

*Proof.* (a) Let σ_φθ be a step. If no θ(z_i) is captured, then in (N) the substitution is free for every x_i and
σ_φθ = φ(θ̄) is a genuine instance — closed if the values are variable-free, otherwise an instance at terms whose
names are not bound at any occurrence, i.e. parameters (or, if steps are sentences, impossible); in (dB) a
non-captured value has no index below the depth of any occurrence, and none at or above it either (the step is well
formed), so it has no index at all and σ_φθ is a closed or parameter instance. Otherwise σ_φθ ∈ Cap(φ). The reverse
inclusions are by definition. Disjointness: every z_i occurs in σ_φ, so the text σ_φθ determines each θ(z_i) (the
subtree at an occurrence of z_i), and whether θ(z_i) is captured is a property of that text.
(b) (N), sentences: if y is bound at every free occurrence of x_i, then θ(z_i) := y (other values closed) gives a
sentence in Cap. Conversely, if σ_φθ ∈ Cap is a sentence and θ(z_i) contains the captured name y, then every copy of
θ(z_i), one at each free occurrence of x_i, contains y, and y must be bound at each (the result has no free names),
so y is bound at every free occurrence. (N), parameters: θ(z_i) := y with y bound above some occurrence is a step
(free copies of y elsewhere read as a parameter); conversely capture needs a binder above an occurrence. (dB): if
every free occurrence of x_i has depth ≥ 1, θ(z_i) := #0 is well formed at all of them and captured; conversely a
captured value contains some #k, and well-formedness at each occurrence o requires k < depth(o), so every depth ≥ 1.
(c) ∃y¬(y=y) is false in every structure; ∃y¬(y=t) holds in every structure with ≥ 2 elements whatever t denotes.
∀x∃y(y = Sx) is logically valid (take y := Sx); ∃y(y = Sy) is false in ℕ since S has no fixed point.
(d) By A4(b), cl_{H₁}(inst_c φ) = inst(σ_φ) ⊇ Cap(φ) (A2's anchor argument uses closed instances only, so it holds in
(N) and (dB)); prior C6.1 then says that the cautious verifier accepts all of it after an anchor. With φ as in (c) the
accepted capture instance is false in every structure.
(e) Closed values satisfy both guards, so closed data teach both; inst(σ_φ, {closed, nocap}) = inst_c(φ) since
closedness implies nocap. A genuine parameter instance satisfies nocap and violates closed, so only closed(z_i) is
deleted; inst(σ_φ, {nocap(z_i)} ∪ …) consists of the steps with no captured value, which by (a) are the genuine
instances. ∎

*Evidence.* `q1_capture.py` → `q1_capture.out` (< 1 s):
(1) lgg(φ(0), φ(S0)) = ∃y¬(y=z) for φ = ∃y¬(y=x); ∃y¬(y=y) is an instance of it, a sentence, not a closed instance, and
false in all pure-equality structures of sizes 1–5, while every closed instance is true in sizes 2–5; for
φ = ∃y(y = Sx), the capture ∃y(y = Sy) is an instance of the lgg.
(2) Decomposition of inst(σ_φ) over all 40 substituted terms of size ≤ 3 over {0, S, +, x, y, p, q} for seven φ:
closed 4, parameter 14, capture 0 or 12; the capture sentences exist exactly as (b) predicts (e.g. none for
x=x ∧ ∀y(x=y), where y is not bound at every free occurrence of x; capture formulas exist there when free names
read as parameters). The script asserts the prediction for every φ.
(3) Guards {closed, nobound}: closed data → both learned; accepts SS0, rejects the parameter q and the captures y,
y+p. After a datum at p+S0: only nobound learned; accepts q, still rejects y and y+p. The unguarded verifier accepts
∃y¬(y=y) in both cases.
(4) de Bruijn: lgg ∃¬(#0 = z), capture ∃¬(#0 = #0) is an instance; the learned guard "no loose index in z" rejects it.

### 1.6 The ω-gap

**Prop A5 (when closed instances decide universals) — proved; known in substance (Tarski–Vaught test).** Let M be an
L-structure (L with a constant) and M₀ = {t^M : t closed} the closed-term substructure. TFAE:
(i) for every L-formula φ(x̄): M ⊨ ∀x̄φ iff M ⊨ φ(t̄) for all closed t̄;
(ii) M₀ ≼ M.
In particular (i) holds when M is term-generated (M₀ = M), e.g. (ℕ; 0, S, +, ·), and in every model of true arithmetic
(ℕ ≼ M).
*Proof.* (ii)⇒(i): if M ⊨ φ(t̄) for all closed t̄ then M₀ ⊨ ∀x̄φ (elementarity, every element of M₀ is some t^M), so
M ⊨ ∀x̄φ; the converse direction of (i) is ∀-elimination. (i)⇒(ii): Tarski–Vaught criterion. Let M ⊨ ∃xψ(x, ā) with
ā = s̄^M ∈ M₀. If no b ∈ M₀ had M ⊨ ψ(b, ā), then M ⊨ ¬ψ(t, s̄) for all closed t, and (i) with φ := ¬ψ(x, s̄) gives
M ⊨ ∀x¬ψ(x, s̄), a contradiction. ∎ (Tarski–Vaught 1957, Compositio Math. 13, for the criterion.)

**Ex. A6 (ℝ as an ordered field) — proved.** L = {0,1,+,−,·,<}. Every closed term denotes an integer (induction on
terms). With φ(x) := ¬(x·x = 1+1): ℝ ⊨ φ(t) for every closed t (n² ≠ 2 for n ∈ ℤ), but ℝ ⊭ ∀xφ (√2). RCF
⊢ ∃x(x·x = 1+1) (positive elements have square roots), so the false universal is refutable from the designated theory
RCF; it is not refutable from the ordered-field axioms OF, since ℚ ⊨ OF + ∀x¬(x·x = 1+1).

**Ex. A7 (set theory with closed-term-forming symbols) — proved.** L = {∈, ∅, p, u} with p(a,b) = {a,b},
u(a,b) = a∪b. Closed terms denote exactly the hereditarily finite sets. Let Ind(x) := ∅ ∈ x ∧ ∀y∈x u(y, p(y,y)) ∈ x and
φ(x) := ¬Ind(x). Every closed term denotes a finite set, and an inductive set is infinite, so V ⊨ φ(t) for all closed
t; ZF ⊢ ∃x Ind(x) (Infinity), so ∀xφ is false and refuted by Infinity. (Each closed instance is a true Δ₀ sentence
about HF sets; I believe each is provable already in very weak set theories, but only truth is used.) The brief's
variant φ(x) := "x is finite" behaves the same way: all closed instances are true, ∀x finite(x) is refuted by
Infinity; ¬Ind is used here because it is Δ₀ in L.

**Ex. A7′ (nonstandard models of PA) — proved.** If M ⊨ PA + ¬Con(PA) and Prf is a Δ₀ proof predicate, all closed
instances ¬Prf(n̄, ⌜⊥⌝) hold in M (true Δ₀ sentences hold in every model of Q: Σ₁-completeness), while
M ⊨ ∃x Prf(x, ⌜⊥⌝). So even within arithmetic the ω-step is truth-safe only in the right model.

**Ex. A8 (derivability: Q) — proved; computed.** Q ⊢ 0 + n̄ = n̄ for every n (n = 0: axiom x+0 = x; step:
0 + S n̄ = S(0 + n̄) = S n̄ by x+Sy = S(x+y) and the induction hypothesis). Q ⊬ ∀x(0+x = x): take the domain ℕ ∪ {a, b},
standard on ℕ, with
- S a = a, S b = b;
- n + a = n + b = b; a + n = a, b + n = b; a+a = a+b = a; b+a = b+b = b;
- x·0 = 0; a·n = b·n = b (n ≥ 1); n·a = n·b = a (n ≥ 1), 0·a = 0·b = 0; a·a = a·b = b·a = b·b = a.

Check of Q1–Q7 by cases: S is injective with 0 ∉ ran S and every x ≠ 0 a successor (a = Sa, b = Sb). Q4: x+0 = x. Q5
x+Sy = S(x+y): y standard — for x ∈ {a,b}, x+n = x and S x = x; y ∈ {a,b} — Sy = y and every x+y ∈ {a,b} is a fixed
point of S. Q6 holds. Q7 x·Sy = x·y + x: y standard — a·(n+1) = b = a·n + a (0+a = b, b+a = b), b similarly
(0+b = b, b+b = b); y ∈ {a,b} — need z + x = z for z = x·y: x = 0 trivial; x = n ≥ 1, z = a: a+n = a; x = a, z = a:
a+a = a; x = b, z = a: a+b = a. In this model 0+a = b ≠ a. So Q + {all closed instances of 0+x=x} ⊬ ∀x(0+x = x). (That Q
does not prove 0+x = x is a textbook fact — unverified location, I believe Boolos–Burgess–Jeffrey, *Computability and
Logic*, ch. 16 exercises; the model here is my own.)
*Evidence.* `q1_qmodel.py` → `q1_qmodel.out` (re-run: identical): all seven axioms hold on all tuples from
{0..40} ∪ {a, b}; 0+a = b. Independently the referee checked {0..60} ∪ {a,b} (`referee_code/r1_q1.out` (4)).

**Prop A9 (parameters + Gen) — proved (trivial).** In closure-normal form the datum φ(p) at a parameter p *is* ∀xφ (its
universal closure); with trusted Gen, ∀xφ is derivable from it in one step. So with open-term data the ω-gap
disappears (A4(a)).

### 1.7 Consequences for a learner — Prop A10, A11 — proved [A10 revised]

**A10 (what is soundly learnable).**
1. From closed instances, the soundly learnable object is inst_c(φ), with anchor (R)+(D) and the rates of A3. The
   learner must carry a closedness guard (A4(c)), otherwise it commits the ω-step (A4(b)); and in the named or de
   Bruijn first-order syntax it must in addition carry the nocap/λ restriction (A4′(e)) — otherwise, whenever some
   free x_i lies under a binder, it accepts capture instances, which can be false in every structure (A4′(c,d)).
   Under the λ convention the second requirement is automatic.
2. The ω-step (accept ∀x̄φ, equivalently φ(p̄)) is *truth-safe for all genuine closed-instance schemas* iff the
   intended structure M satisfies M₀ ≼ M (this is Prop A5): yes for ℕ, no for ℝ, V, or a nonstandard model of PA.
3. It is *derivable* from the instances only via an ω-rule; first-order theories are ω-incomplete in general (A8: Q
   plus all closed instances does not prove ∀x(0+x=x)).
4. If the community itself uses instances at parameters (as in Lean/Coq practice, where `∀x, φ x` is applied to
   variables), the open-instance schema is the target and ∀x̄φ is obtained soundly (A9); the nocap guard (or the λ
   convention) is still needed in the named/de Bruijn first-order syntax.

**A11 (refutation).** Let ∀xφ be false in the intended M while every closed instance is true.
(a) No refutation that ends in evaluating closed instances φ(t) (the parent's "∀E then W" singleton-blame pattern)
ever condemns ∀xφ, since every such evaluation returns true.
(b) A coherence refutation from designated true premises Γ exists iff Γ ∪ {∀xφ} is inconsistent (completeness):
Γ = RCF refutes ∀x¬(x·x = 1+1); Γ = OF does not (ℚ). ZF refutes ∀x¬Ind(x) (Infinity).
(c) In a term-generated M (ℕ) the situation cannot arise: by A5 a false ∀xφ has a false closed instance; if the
evaluation channel decides φ's closed instances (φ ∈ Δ₀), search finds it — the parent's "arithmetic is Popperian"
for Π₁.
So where the bold step is safe (M₀ ≼ M) a false universal always has a false closed instance; elsewhere (ℝ, V) a
wrong ω-step can only be caught through the designated theory, and sometimes not at all.
(d) **[new]** Capture instances (A4′) are refutable by pure logic when they are logically false (∃y¬(y=y)); when they
are false only in the intended model (∃y(y=Sy) in ℕ: a Σ₁ sentence whose negation is a true Π₁ sentence), a
refutation needs a designated theory proving the negation: Q does not prove ∀y¬(y = Sy) (in the model of Ex. A8,
Sa = a), PA does (induction). No closed-instance evaluation bears on a capture instance, which is not an instance of
anything the evaluation channel tests. So the world channel alone does not protect an unguarded learner against
capture; the guard (or the λ convention) does.

---------------------------------------------------------------------------------------------------------------

## PART 2. Q2: the ZF(C) schemas

### 2.1 Formulations — known (citations hedged)

* **Kunen** (*Set Theory: An Introduction to Independence Proofs*, 1980, Ch. I; I believe also in the 2011 edition):
  Comprehension ∀z∀w̄∃y∀x(x∈y ↔ x∈z ∧ φ), FV(φ) ⊆ {x, z, w̄} (so y ∉ FV(φ)); Replacement
  ∀A∀w̄(∀x∈A ∃!y φ → ∃Y∀x∈A ∃y∈Y φ), FV(φ) ⊆ {x, y, A, w̄} (Y ∉ FV(φ)); Foundation
  ∀x(∃y(y∈x) → ∃y(y∈x ∧ ¬∃z(z∈x ∧ z∈y))). (Wording from memory, not re-checked against the book; the referee's
  recollection agrees.) **[revised]** Kunen treats ∃! as an abbreviation (I believe); treating ∃! as a primitive
  binder (template ReplU below) is *our encoding choice*, not Kunen's. Both readings are analysed: ReplU (∃!
  primitive) and ReplS (∃! spelled out as ∃y(φ(x,y) ∧ ∀u(φ(x,u) → u = y))).
* **Jech** (*Set Theory*, 3rd millennium ed., 2003, Ch. 1, axioms 1.1–1.9; I believe): Separation
  ∀X∀p∃Y∀u(u∈Y ↔ u∈X ∧ φ(u,p)); Replacement ∀x∀y∀z(φ(x,y,p) ∧ φ(x,z,p) → y = z) → ∀X∃Y∀y(y∈Y ↔ ∃x∈X φ(x,y,p));
  Regularity ∀S(S ≠ ∅ → ∃x∈S S∩x = ∅). (Unverified wording; the referee's recollection agrees.)
* **Collection** ∀A∀w̄(∀x∈A ∃y φ → ∃Y∀x∈A ∃y∈Y φ) and **∈-induction** ∀x(∀y∈x φ(y) → φ(x)) → ∀xφ(x) are not axioms of
  ZFC but theorem schemas of ZF (Collection via ranks/reflection, e.g. Lévy 1979, *Basic Set Theory* — I believe;
  ∈-induction via transitive closures and Foundation) — known. Conversely ∈-induction with parameter S proves
  Foundation: for φ(x) := x ∉ S, if S had no ∈-minimal element then ∀y∈x (y ∉ S) → x ∉ S holds for all x, so
  ∀x(x ∉ S) and S = ∅ (proved, two lines).
* **ZFC proper:** Extensionality, Pairing, Union, Power set, Infinity, Separation (schema), Replacement (schema),
  Foundation (one sentence), Choice; plus Empty set / Set existence depending on the text.
* **[new] Ground axioms.** Every ZFC axiom other than the two schemas — Extensionality, Empty set (where included),
  Pairing, Union, Power set, Infinity, Foundation, Choice — is a single sentence s. Its target is {s}, a
  metavariable-free template; every class contains it; the only datum is s itself, and one occurrence of it is an
  anchor in every class (the only template that covers {s} and is contained in every covering template is s, and
  every covering template contains s). Matching is equality. (Proved, trivial. In an untagged mixture these
  sentences raise the union problem of Q3, which is not this track's subject.)

**Closure-normal forms used here** (parameters w̄ dropped; frame variables stay bound; P is the template's metavariable,
written with the textbook argument names; `st_core.SCHEMAS`):

| name | template T* | P's arguments |
|---|---|---|
| Sep (Kunen) | ∀z∃y∀x(x∈y ↔ x∈z ∧ P(x,z)) | (x, z) |
| SepJ (Jech) | ∀X∃Y∀u(u∈Y ↔ u∈X ∧ P(u)) | (u) |
| EInd | ∀x(∀y(y∈x → P(y)) → P(x)) → ∀xP(x) | (y), (x), (x) |
| Coll | ∀A(∀x(x∈A → ∃y P(x,y,A)) → ∃Y∀x(x∈A → ∃y(y∈Y ∧ P(x,y,A)))) | (x,y,A) twice |
| ReplU (∃! primitive; our reading of Kunen) | ∀A(∀x(x∈A → ∃!y P(x,y,A)) → ∃Y∀x(x∈A → ∃y(y∈Y ∧ P(x,y,A)))) | (x,y,A) twice |
| ReplS (∃! spelled out) | ∀A(∀x(x∈A → ∃y(P(x,y,A) ∧ ∀u(P(x,u,A) → u=y))) → ∃Y∀x(x∈A → ∃y(y∈Y ∧ P(x,y,A)))) | (x,y,A), (x,u,A), (x,y,A) |
| ReplJ (Jech) | ∀x∀y∀u(P(x,y) ∧ P(x,u) → y=u) → ∀X∃Y∀y(y∈Y ↔ ∃x(x∈X ∧ P(x,y))) | (x,y), (x,u), (x,y) |
| Found | ∀S(∃x x∈S → ∃x(x∈S ∧ ∀y(y∈x → ¬y∈S))) | — (ground) |

All are sentences after plugging any body λz̄.φ (φ closed except holes and parameters).

### 2.2 Thm B1 (classification of encodings) — proved; computed

Let T* be a pattern template with one metavariable P of arity n and occurrences P(ā₁),…,P(ā_m), ā_k pairwise distinct
bound variables in scope. In the named encoding (textbook names) let N_k be the *names* of ā_k; in the de Bruijn
encoding let I_k be the *indices* of ā_k at occurrence k.
(a) T* ∈ PAT ⊆ DT° (a Miller pattern).
(b) inst(T*) equals the instance set of a single first-order schema with freshness guards in the named encoding iff
N₁ = … = N_m. Then the schema is F[A,…,A] (the frame with one formula metavariable A at every P-position) with guards
{fresh(v, A): v a frame-bound name, v ∉ N₁}.
(c) the same holds in the de Bruijn encoding iff I₁ = … = I_m, with guard loose(A) ⊆ I₁; this guard is implied by
well-formedness iff I₁ = {0,…,d−1} where d is the least binder depth of an occurrence.

*Proof.* (a) by inspection. (b)/(c) "if": an instance of the guarded first-order schema assigns A a formula ψ whose
free frame names lie in N (named) or whose loose indices lie in I (dB). Let β := ψ with the names/indices of N (resp.
I) replaced by the holes in argument order. At every occurrence the arguments have the same names (resp. indices), so
β[ā_k] = ψ for all k and the instance is T*[P := λz̄.β]. Conversely T*[P := λz̄.β] gives β[ā_k], the same text for all
k, satisfying the guard. "Only if": suppose N_k ≠ N_l (resp. I_k ≠ I_l) and σ is a guarded first-order schema with
inst(σ, G) = inst(T*). Take the genuine data s₁, s₂ with bodies φ₁ = ⋀_i (z_i = z_i) and φ₂ = ¬φ₁. Their lgg L has a
metavariable at every P-position (roots ∧ vs ¬ differ) and the columns at occurrences k, l differ (φ₁ mentions every
argument), so L has distinct metavariables A_k ≠ A_l. Since s₁, s₂ ∈ inst(σ), σ ⪰ L, say L = σρ. Let s₃ := L with A_k's
block := ⊤ = ∀w(w=w) and all other blocks := ⊥ = ¬⊤. Then s₃ = σ(ρθ₃) and every guard satisfied by s₁ is satisfied by
s₃: the value ρθ₃(Z) of each σ-metavariable has as free names (loose indices) only those of the rigid part of ρ(Z),
which are also free in ρθ_{s₁}(Z). So s₃ ∈ inst(σ, G). But s₃ ∉ inst(T*): a body giving the closed ⊤ at occurrence k
must be ⊤ itself (plugging variables into a body with holes leaves variables), so occurrence l would also be ⊤, not ⊥. ∎

*Evidence.* `z1_encodings.py` (1) computes the criterion from the frames; (5) builds s₃ for every non-first-order
case: an instance of the lgg, not a schema instance (all 7 cases). (4): for EInd in de Bruijn, of 3000 random A with
loose indices ⊆ {#0,#1}, the 1051 well-formed instances of the first-order pattern are all EInd instances and the rest
are ill-formed. Re-run in this revision: identical output. Independently recomputed by the referee
(`referee_code/r2_zf.out` (1), (4)).

**Table (proved by B1; criterion computed in `z1_encodings.out` (1)).**

| schema | PAT / DT° | named first-order (textbook names) | de Bruijn first-order | named, α-varied (§2.2a) |
|---|---|---|---|---|
| Sep | yes | yes, guard fresh(y, A) | yes, guard "#1 not loose" (not implied) | yes |
| SepJ | yes | yes, guards fresh(X, A), fresh(Y, A) | yes, guard loose(A) ⊆ {#0} | yes |
| EInd | yes | **no** (y vs x) | **yes**, guard implied by well-formedness | no |
| Coll | yes | yes, guard fresh(Y, A) | **no** (A is #2 vs #3) | **no** |
| ReplU | yes | yes, guard fresh(Y, A) | **no** | **no** |
| ReplS | yes | no (y vs u) | no | no |
| ReplJ | yes | no | no | no |
| Coll/ReplU with φ(x,y) only | yes | yes, guards fresh(Y), fresh(A) | yes, guard loose ⊆ {#0,#1} (not implied: #2 is A in the antecedent, Y in the consequent) | no |
| Found and the other ground axioms | ground | ground | ground | ground |

The table answers "is it a first-order pattern, with what guards, is it a Miller pattern, is it determinate" for each
schema. Without its guard every guarded entry has a false instance (§2.4).

### 2.2a Prop B1α (named encoding under α-variation) [new] — proved; computed

`notes.md` assumed that the community writes every instance with the textbook names for the frame's variables. Drop
this: *α-varied data* are α-variants of schema instances in which the frame's binders get arbitrary names, pairwise
distinct and distinct from the instance's parameters. inst_α(T*) is the set of all such α-variants. The
hypothesis class is now the first-order schemas over the named signature whose metavariables have formula sort or
*name sort* (name metavariables stand at binder-name positions and variable leaves), with guards from
Φ_α = {fresh(v, A), distinct(v, w)}.

**Prop B1α.** inst_α(T*) is the instance set of a single guarded first-order schema iff all occurrences of P are applied
to the same tuple of *binders* (the same binder nodes of the frame, in the same order). Among the ZF templates this
holds for Sep and SepJ (one occurrence) and fails for EInd, Coll, ReplU, ReplS, ReplJ.

*Proof.* "If": let b₁,…,b_K be the frame's binders. σ := the frame with the name of b_k (at the binder and at every leaf
it binds) replaced by a name metavariable v_k, and every P-occurrence replaced by one formula metavariable A; guards
distinct(v_k, v_l) for k ≠ l and fresh(v_k, A) for every b_k that is not one of P's argument binders. An instance
assigns distinct names to the binders and a formula ψ to A whose free names are argument-binder names or names not
used by the frame. Let β := ψ with the argument names replaced by holes in argument order. Every occurrence applies P
to the same binders, hence to the same names, so every slot reads β[names] = ψ and the instance is an α-variant of
T*[P := λz̄.β]. Conversely an element of inst_α(T*) has distinct frame names, one slot text ψ (same binders, same
names), and ψ's free names are argument names or non-frame names; so it is an instance satisfying the guards.
"Only if": let occurrences k and l differ at argument position i (binders b ≠ b′). Suppose inst(σ, G) = inst_α(T*).
Fix one naming with all frame binders distinct and take the genuine data s₁, s₂ (same naming) with bodies
φ₁ = ⋀_i z_i = z_i and φ₂ = ¬φ₁. In their lgg L the frame names are common (constants), every slot is a disagreement
position, and the slot texts at k and l differ in s₁ (one mentions name(b), the other name(b′)), so L has distinct
slot metavariables A_k ≠ A_l. As in B1, σ ⪰ L, L = σρ, and s₃ := L with A_k's block := ⊤ and the other blocks := ⊥ is
in inst(σ, G): distinct-guards involve only name positions, whose values in s₃ equal those in s₁; fresh-guards hold
because the free names of ρθ₃(Z) are among those of ρθ_{s₁}(Z). But s₃ ∉ inst_α(T*): a body yielding the closed ⊤ at k is
⊤ itself, so slot l would be ⊤ too. The ZF classification: Sep and SepJ have one occurrence; EInd applies P to the
binders ∀y, ∀x (first), ∀x (second); in Coll and ReplU the antecedent's x, y are bound by ∀x, ∃y (resp. ∃!y) of the
antecedent and the consequent's by the consequent's ∀x, ∃y; ReplS and ReplJ already differ in names. ∎

*Consequences* (proved; computed): (1) Coll and ReplU, first-order in the named encoding with textbook names, are not
first-order once names vary; the named lgg of α-varied anchor data decouples their two occurrences and has the false
instance ∀A(∀x(x∈A → ∃y(y=x)) → ∃Y∀x(x∈A → ∃y(y∈Y ∧ ⊥))) ≡ ∀A¬∃x(x∈A) (and its ∃! analogue), which satisfies the
learned fresh/distinct guards. (2) ReplS: the named lgg of α-varied data decouples all three occurrences and has the
false instance with blocks (y = x), ⊥, ⊥ — so the truth-sound over-generalization of Prop C3 is an artefact of
textbook naming. (3) Thm C2 extends to Coll, ReplU, ReplS in the α-varied named encoding (§2.5, case (iv)).
(4) De Bruijn is α-invariant, so the de Bruijn column is unaffected.

*Evidence.* `z8_alpha.py` → `z8_alpha.out` (1 s). (1) On all pool anchor pairs: textbook-name blocks vs α-varied
blocks — Sep (1) / (1); SepJ (1) / (1); EInd (1),(2,3) / (1),(2),(3); Coll and ReplU (1,2) / (1),(2); ReplS and ReplJ
(1,3),(2) / (1),(2),(3). (2) For Coll, ReplU, ReplS: the stated instance is an instance of the α-varied lgg, satisfies
the most specific fresh/distinct guards learned from the two data, is a sentence, and is not a schema instance.
(3) Sep, SepJ: 1236 resp. 720 random guard-satisfying instances of the α-varied guarded lgg (random distinct names,
random slot formulas over the frame names, parameters and fresh internal binders) are all genuine.

### 2.3 What the first-order lgg does — Prop B2 — proved; computed

For data D ⊆ inst(T*) with (R), the first-order lgg (either encoding, textbook names) is the frame with a metavariable
at each P-position, and positions k, l carry the same metavariable iff φ_j[ā_k] = φ_j[ā_l] (as text in that encoding)
for all j, iff every argument position i at which ā_k and ā_l differ is unused by all φ_j.
*Proof.* Frame positions are common columns; by (R) every P-position is a disagreement column; Reynolds' table merges
equal columns. φ[ā_k] = φ[ā_l] iff the substitutions agree on FV(φ) (substitution injectivity: at a free occurrence of
z_i the two results carry a_{k,i} and a_{l,i}). ∎

`z1_encodings.out` (2) tabulates the blocks for all 110/107/106 pool pairs with (R), keyed by (N_i). Summary:
* EInd: named blocks {1},{2,3} iff N; de Bruijn always {1,2,3}.
* Coll, ReplU: named always {1,2}; de Bruijn {1},{2} iff N_A.
* ReplS: named {1,3},{2} iff N_y; de Bruijn three blocks when N_x and N_A.
* ReplJ: named {1,3},{2} iff N_y; de Bruijn three blocks when N_x and N_y.

So on anchor data (R + all N_i) the first-order lgg decouples exactly the non-first-order cases of the table; when it
ties everything (some N_i fails), it is a sound but incomplete specialization. (Referee: 2417 random pairs, 7 schemas ×
2 encodings, block structure = prediction in every case, `referee_code/r2_zf.out` (2).)

### 2.4 Two instances suffice for a false lgg instance — proved; computed

For each non-first-order case, two genuine instances (two atoms with different roots) and an instance of their lgg
that is false, with the falsity proof. All are checked to be instances of the computed lgg and not schema instances in
`z1_encodings.out` (3) (and by the referee, `referee_code/r2_zf.out` (3)). ⊤ := ∀w(w=w), ⊥ := ¬⊤.

1. **EInd, named.** Data EInd(x = x), EInd(¬x ∈ a). lgg: ∀x(∀y(y∈x → A) → B) → ∀xB. Instance
   F₁ := ∀x(∀y(y∈x → ¬y=y) → ∀w¬w∈x) → ∀x∀w¬w∈x. The antecedent is valid (∀y(y∈x → ⊥) is ∀w¬w∈x), so F₁ is logically
   equivalent to the Π₁ sentence ∀x∀w¬(w∈x), whose Δ₀ matrix fails at the HF sets x = {∅}, w = ∅; by Δ₀-absoluteness
   (HF is transitive) F₁ is false in V. ZF refutes it from "some set has an element".
2. **ReplJ, named.** Data ReplJ(x∈y), ReplJ(¬x=a). lgg: ∀x∀y∀u(A ∧ B → y=u) → ∀X∃Y∀y(y∈Y ↔ ∃x(x∈X ∧ A)). Instance
   A := y=y, B := ¬u=u: the antecedent is valid and the consequent says, at X = {∅}, that there is a set of all sets.
   ZF refutes it: Y ∈ Y contradicts Foundation (or Separation yields Russell's set).
3. **ReplJ, de Bruijn** (three blocks): A₁ := ⊥, A₂ := ⊥, A₃ := (y = y): the same false sentence up to the antecedent's
   form.
4. **Coll, de Bruijn.** Data Coll(y = x), Coll(¬x = A). lgg decouples occurrences 1, 2. Instance A₁ := y=y, A₂ := ⊥:
   ∀A(∀x∈A ∃y(y=y) → ∃Y∀x∈A ∃y(y∈Y ∧ ⊥)), logically equivalent to ∀A¬∃x(x∈A); refuted by the HF witness A = {∅}
   (Σ₁ negation, Δ₀-absolute).
5. **ReplU, de Bruijn.** Same data; A₁ := (y = x) (∃!y(y = x) is valid), A₂ := ⊥: equivalent to ∀A¬∃x(x∈A).
6. **ReplS, de Bruijn.** Same data; A₁ := (y = x), A₂ := ⊥, A₃ := ⊥: the antecedent ∀x∈A∃y(y=x ∧ ∀u(⊥ → u=y)) is valid,
   the instance is equivalent to ∀A¬∃x(x∈A).
7. **Guard violations** (the guarded first-order patterns of the table):
   - Sep without fresh(y): Russell's instance ∀z∃y∀x(x∈y ↔ x∈z ∧ ¬x∈y) — both encodings (§2.7).
   - Coll / ReplU / ReplS, named, without fresh(Y): φ := (y = Y) gives ∀A(∀x∈A ∃y(y = Y) → ∃Y∀x∈A∃y(y∈Y ∧ y=Y)): the
     antecedent holds (Y is a parameter there), the consequent forces Y ∈ Y for A ≠ ∅; ZF refutes it by Foundation
     (ReplS: add B := ¬u=u for the uniqueness clause).
   - Coll with φ(x,y) only, de Bruijn, without "#2 not loose": A := (#0 = #2) reads y = A in the antecedent and y = Y in
     the consequent: ∀A(∀x∈A∃y(y=A) → ∃Y∀x∈A∃y(y∈Y ∧ y=Y)), false as before (`z1_encodings.out` (3b)).
8. **[new] Named, α-varied** (§2.2a): Coll, ReplU (blocks (y = x), ⊥) and ReplS (blocks (y = x), ⊥, ⊥): each equivalent
   to ∀A¬∃x(x∈A) (`z8_alpha.out` (2)).

### 2.5 No finite union of first-order schemas — Lemma C1, Thm C2 — proved; computed

**Lemma C1 (deep leaf).** Let s be a sentence tree, ℓ a leaf of s, and τ a first-order schema with s ∈ inst(τ) and
|τ| < depth(ℓ). Then τ has a metavariable occurrence Z at a proper prefix q of ℓ with depth(q) < |τ|. If moreover s|q
occurs in s only at q, then Z occurs in τ only at q, and s[q ← v] ∈ inst(τ) for every closed formula v; with freshness
guards (named), loose-index guards (de Bruijn), and also distinct-guards on name metavariables (α-varied named), s[q ← v]
satisfies them.
*Proof.* Follow the path to ℓ in τ: τ has fewer than |τ| nodes, so the path leaves τ's tree at depth < |τ| at a leaf of
τ. That leaf is not a constant, since s continues below it; so it is a metavariable Z at a proper prefix q of ℓ. In the
language {∈, =} every proper prefix of a variable leaf is a formula position (binder-name children are not on the path
to ℓ), so Z is a formula metavariable. If Z also occurred at q′, then s|q′ = θ(Z) = s|q, so q′ = q by uniqueness.
Changing θ(Z) to v changes s at q only. Guards on Z: v is closed, so it has no free names and no loose indices; other
metavariables (including name metavariables) keep their values. ∎

**Thm C2.** In each case below, every finite set {τ₁,…,τ_r} of first-order schemas (with the guards of the respective
encoding) whose union contains all instances of the schema contains a false sentence (indeed one refutable in ZF from
"some set has an element", Foundation, and Separation/Pairing):
(i) EInd in the named encoding; (ii) ReplJ in both encodings; (iii) Coll, ReplU and ReplS in the de Bruijn encoding;
(iv) **[new]** Coll, ReplU and ReplS in the named encoding under α-variation (§2.2a).
With textbook names, the list (i)–(iii) is exactly the non-first-order cases of the table except ReplS in the named
encoding, and that exception is necessary: there a single guarded first-order schema covers ReplS without false
members (Prop C3). Every finite union still contains non-instances there (Lemma C1 applies verbatim; only falsity
fails).

*Proof.* Take n with 2n > max|τ_i|, the genuine instance s_n below, and τ_i covering it. By Lemma C1 (uniqueness is
checked below) τ_i contains s_n[q ← v] for the prefix q determined by τ_i and *each* closed v; it suffices that for every
proper prefix q of the designated leaf one of v ∈ {⊤, ⊥} makes s_n[q ← v] false. Below, "make the slot false" means
choosing v with ¬^{e}v ≡ ⊥ where e is the number of negations between q and the slot root (positions on the path inside
the slot are reached through ¬, ∀ and ∧ only, and ∀w v ≡ v).
(i) φ_n(x) := ¬^{2n}∀w¬(w∈x) ("x is empty"); s_n = EInd(φ_n), named; leaf: the y in occurrence 1 (φ_n(y)). q = root:
  v := ⊥. q = antecedent or its ∀x-body: v := ⊤; then s ≡ ∀xφ_n(x) ≡ "every set is empty", false. q = ∀y(y∈x → φ_n(y))
  or its body: v := ⊥; the antecedent becomes ∀x(⊥ → φ_n(x)), true; conclusion false. q inside φ_n(y): make the slot
  false; then ∀y(y∈x → ⊥) says "x is empty", the antecedent reads ∀x(x empty → x empty), true, the conclusion is false.
(ii) φ_n(x,y) := ¬^{2n}(x ∈ y); leaf: u in occurrence 2 (φ_n(x,u)). The consequent C := ∀X∃Y∀y(y∈Y ↔ ∃x∈X x∈y) is false:
  at X = {∅}, Y would contain every y with ∅ ∈ y; y₀ := {∅, Y} gives Y ∈ y₀ ∈ Y, contradicting Foundation (or, without
  Foundation, R := {y ∈ Y: y ∉ y} and y₁ := R ∪ {∅} give y₁ ∈ y₁ ↔ y₁ ∉ y₁). q = root: ⊥. q = the antecedent, its ∀y, ∀u
  levels or its implication: ⊤ (antecedent true, C false). q = the conjunction: ⊥ ((⊥ → y=u) is true). q inside
  φ_n(x,u): make the slot false (the conjunction becomes ⊥).
(iii) φ_n(x,y,A) := ¬^{2n}(y = x ∧ x ∈ A); leaf: the A in the consequent occurrence (occurrence 2 for Coll/ReplU, 3 for
  ReplS). The antecedent is true for every A (y := x is the unique witness). Every proper prefix q on the path is the
  root (v := ⊥), the ∀A body (v := ⊥: ∀A⊥), or a subformula of the consequent containing the leaf; there v := ⊥ above the
  slot (∃Y⊥, ∃Y∀x⊥, ∀x(x∈A → ⊥), ∃y⊥, (y∈Y ∧ φ) := ⊥) and "make the slot false" inside it (including
  (y=x ∧ x∈A) := ⊥ and x∈A := ⊥ under the even chain) make the consequent false whenever A ≠ ∅, so
  ∀A(true → false-for-nonempty-A) is false.
(iv) Same φ_n and the same case analysis as (iii), with s_n an α-variant of S(φ_n) in which all frame binders have
  distinct names, and with designated leaf the y of the atom (y = x) in the consequent occurrence (the A-leaf of (iii)
  is not usable here: in the named encoding the atom x∈A of the slot also occurs as a frame atom of the consequent).
  The only new prefix is the atom (y = x) itself, where v := ⊥ makes the slot false.
Uniqueness of s_n|q along the path: in (i) the path subterms contain y and occurrences 2, 3 contain x; in (ii) and (iii)
the argument tuples of the designated occurrence differ from all others (de Bruijn: (#2,#0) vs (#2,#1), (#0,#1);
(#1,#0,#3) vs (#1,#0,#2), (#2,#0,#3)), and the frame subterms on the path are distinct; in (iv) every path subterm inside
the slot contains the consequent's own names for x and y, which occur nowhere outside the consequent, and inside the
consequent the frame atoms are x∈A and y∈Y, never y = x. ∎

*Evidence.* `z5_deepleaf.py` → `z5_deepleaf.out` (re-run: identical): for n ≤ 10 every subterm along each designated path
of (i)–(iii) is unique in s_n; for 2 136 random first-order generalizations τ of s_n with |τ| < depth(leaf) (n = 2, 4, 8),
τ contains both s_n[q ← ⊤] and s_n[q ← ⊥] at the metavariable q on the path (Lemma C1's conclusion). Referee
(`referee_code/r2_zf.out` (7)): for every prefix in (i)–(iii), n = 1, 2, one of ⊤/⊥ makes s_n[q←v] imply the stated
false sentence in all ∈-structures of size ≤ 3. **[new]** `z8_alpha.out` (4) for (iv): path uniqueness for n = 0..6; for
n = 0, 1 and every one of the 20 prefixes per schema, one of ⊤/⊥ makes s_n[q ← v] imply "every set is empty" in all
530 ∈-structures of size ≤ 3.

This is the ZF analogue of the prior result for PA induction (family 0+(…(0+x)) = x).

### 2.6 Prop C3 (spelled-out Replacement, named, textbook names: a truth-sound over-generalization) — proved; computed

Let L_S := ∀A(∀x(x∈A → ∃y(B₁ ∧ ∀u(B₂ → u=y))) → ∃Y∀x(x∈A → ∃y(y∈Y ∧ B₁))) with guard fresh(Y, B₁) — the named first-order
lgg of ReplS data with (R) and N_y (`z1_encodings.out` (2)); the most specific guards learned from anchor data are
fresh(Y, B₁), fresh(u, B₁), fresh(Y, B₂), fresh(y, B₂) (`referee_code/r2_zf.out` (5)). Every guarded instance of L_S is a ZF
theorem; inst(L_S) ⊋ inst(ReplS).
*Proof.* The antecedent implies ∀x∈A ∃y B₁ (drop the second conjunct). B₁ may mention x, y, A and other parameters, but
not Y (guard); u is not bound at either occurrence of B₁, so any free u would be a parameter at both. Collection with
these parameters gives ∃Y∀x∈A∃y∈Y B₁, and ZF ⊢ Collection. Strictness: B₂ := ⊥ gives a non-instance. ∎
So in the named encoding with textbook names the first-order learner on spelled-out Replacement data is *truth-sound
but not exact*, and no refutation (world or coherence) can ever detect the over-generalization. Without the guard the
capture instance of §2.4(7) is false. Contrast: in Jech's image form the decoupling yields false instances (§2.4(2)),
because the consequent "Y is exactly the image" is not implied by the antecedent's existence part. Under α-variation
the phenomenon disappears (§2.2a).

**Prop C3′ (exact reduction to Collection) [new] — proved.** Let B be any theory (containing first-order logic).
Every guarded instance of L_S (guards as learned from anchor data, listed above) is a theorem of B iff B proves every
instance of the Collection schema.
*Proof.* (⇐) is the proof of C3, which uses only Collection. (⇒) Let Coll(φ) be a Collection instance,
φ = φ(x, y, A, w̄) with Y not free (Collection's own side condition). Renaming parameters gives an equivalent universal
closure, so assume u ∉ FV(φ). Then B₁ := φ, B₂ := ⊥ satisfy the guards (⊥ is closed), and the resulting instance
∀A(∀x(x∈A → ∃y(φ ∧ ∀u(⊥ → u=y))) → ∃Y∀x(x∈A → ∃y(y∈Y ∧ φ))) is logically equivalent to Coll(φ), because ∀u(⊥ → u=y) is
valid. So B ⊢ Coll(φ). ∎
Consequence: whether this lgg is truth-sound over ZF without Foundation is *exactly* the question whether ZF − Foundation
(with Replacement) proves Collection. I do not know the answer and have no reliable reference (open; flagged by the
referee as well).

### 2.7 Separation without the freshness guard; guard learning — Prop D1 — proved; computed

(a) The unguarded lgg of Sep data (named: ∀z∃y∀x(x∈y ↔ x∈z ∧ A); de Bruijn: the same with A at depth 3) has the
instance φ := ¬(x∈y): R := ∀z∃y∀x(x∈y ↔ x∈z ∧ ¬x∈y). From the designated true axiom ∃z∃x(x∈z): fix such z, x₀ and the y
given by R; then x₀∈y ↔ ¬x₀∈y. So R is refuted in pure logic from "some set has an element" (which ZF proves, e.g. {∅}).
(b) Most specific guards (lem:setting:guard, Φ = {fresh(v, A): v ∈ {x, y, z}}): genuine data never have y free, so
fresh(y, A) is always learned and R is never accepted. The learned guard set equals the target {fresh(y, A)} iff some
datum has x free and some has z free, i.e. iff (N_x) and (N_z) — the same events as the DT° anchor (Thm E). For
Coll/ReplU (named) the target guard is fresh(Y, A); exact iff N_x, N_y, N_A.
*Evidence.* `z4_guards.py` → `z4_guards.out` (re-run: identical): on all pool pairs with (R) (107 Sep, 106 Coll, 106
ReplU): "learned = target" ⟺ all N_i on 107/107, 106/106, 106/106; the capture instance (Russell for Sep, y = Y for
Coll/ReplU) is an instance of the lgg and rejected by the learned guards in every case. Referee: 1537/1537 random pairs
(`referee_code/r2_zf.out` (6)).

### 2.8 Thm E (anchors for pattern targets with one metavariable; all ZF schemas) — proved; computed

Let T* = F[P(ā₁),…,P(ā_m)] be a pattern template over {∈,=} with one metavariable P of arity n (metavariable-free,
parameter-free frame F, ā_k distinct bound variables), D = {T*[P := λz̄.φ_j]: j ≤ N} finite. For every class H with
PAT ⊆ H ⊆ SO°, D is an anchor for inst(T*) in H iff
(R) the main symbols of φ₁,…,φ_N are not all equal, and (N_i) for each i ≤ n some φ_j has z_i free.

Thm E is the one-metavariable case of Thm E′ (§2.9), where the (D)-type conditions are vacuous; the proof of "if" given
here is the SO° proof, and it is also the core of Thm E′'s proof.

*Proof of "if" (for H = SO°, hence for all smaller H).* Let T ∈ SO° cover D: D_j = Tη_j↓. Read bound variables in
locally nameless style (a bound variable is identified by its binder), so "x is bound above c" and "x is bound inside c"
are well defined.
Step 1 (skeleton). The root of φ_j[ā_k] is root(φ_j); by (R) every slot position p_k is a disagreement position, and
frame positions are common. By the rigid-prefix lemma (prior C2(a)) T's rigid skeleton is a prefix of F, and its
metavariable occurrences sit at frame positions or at slot roots, never strictly inside a slot. For such a position c
put κ(c) := T*|c, so D_j|c = κ(c)[P := φ_j].
Step 2 (one body-template per metavariable) **[proof text amended, referee F3]**. Let M have occurrences M(ū¹) at c₁,
…, M(ū^r) at c_r. In closure-normal form the arguments ū^s are metavariable-free terms of {∈,=}, i.e. bound variables in
scope *or parameters*, and they may repeat. Let β_j be the body of η_j(M); β_j is closed except holes and parameters, and
β_j[ū^s] = D_j|c_s for every s. Plugging leaves for holes does not change tree shape.
  (2a) *Shape.* D_j|c₁ and D_j|c_s agree with β_j at every non-hole position of β_j. At a slot root p of κ(c₁),
    D_j|c₁ has root(φ_j), a formula symbol, so p is a non-hole position and D_j|c_s has root(φ_j) at p too. If κ(c_s)
    had a frame symbol at p, all φ_j would share it; if p were strictly inside a slot of κ(c_s) with root p′, the frame
    symbol of κ(c₁) at p′ would be root(φ_j) for all j; both contradict (R). Symmetrically for slot roots of κ(c_s). So
    κ(c₁) and κ(c_s) have slots at the same positions and the same frame symbols at all non-leaf frame positions;
    frame *leaves* may differ.
  (2b) *Frame leaves.* Let q be a frame-leaf position of κ(c₁) carrying the variable v. If v is bound inside κ(c₁), then
    β₁|q is that same bound variable (holes become ū¹, which are bound above c₁ or parameters, not v), so κ(c_s)|q is
    the variable bound at the same relative binder; keep v. If v is bound above c₁, then β₁|q is a hole h_m with
    u¹_m = v (β₁ has no free bound variables; a parameter is not v); if ū¹ has repetitions, m is whichever hole β₁ uses.
    Record m. By (2a), q is a frame-leaf position of κ(c_s) too (its ancestors are non-leaf frame positions there, and
    it is neither a slot root nor a non-leaf frame position, by the symmetric argument), so κ(c_s)|q = D₁|c_s|q = u^s_m.
  (2c) *Slot arguments.* Let κ(c₁) have the slot P(ā) at p and κ(c_s) the slot P(b̄) at p (one metavariable, so the
    slots carry the same P). For the i-th argument: by (N_i) choose j_i with z_i free in φ_{j_i} and a free occurrence
    q′ of z_i. At p·q′, D_{j_i}|c₁ has a_i. If a_i is bound inside κ(c₁), β_{j_i}|(p·q′) is that bound variable, so
    b_i is the variable bound at the same relative binder of κ(c_s); keep a_i. Otherwise β_{j_i}|(p·q′) = h_m with
    u¹_m = a_i; record m. Since D_{j_i}|c_s|p = φ_{j_i}[b̄] has b_i at q′, b_i = u^s_m.
  Let B_M be κ(c₁) with every recorded leaf or argument replaced by its recorded hole. B_M is closed except holes and
  T*'s metavariable P (every variable bound above c₁ was replaced). B_M[ū¹] = κ(c₁) because u¹_m is the replaced
  variable, and B_M[ū^s] = κ(c_s) for every s by (2a)–(2c). In particular every recorded u^s_m is a bound variable — it
  equals a frame variable of κ(c_s) — even though ū^s may contain parameters or repeated entries; any valid choice of
  β₁ and β_{j_i} works. (Term metavariables at frame leaves are the special case κ(c) = a variable.) The earlier text
  said "occurrence arguments are bound variables — true for templates over {∈,=}, which have no closed terms"; that
  sentence was inaccurate (parameters are closed terms in closure-normal form, and arguments may repeat), but the
  argument never used it beyond what (2b), (2c) establish.
Step 3. σ(M) := λh̄.B_M for every metavariable gives Tσ↓ = T*: each M-occurrence at c_s becomes B_M[ū^s] = κ(c_s), and
T's rigid part is F's. So T ⪰ T*, and inst(T) ⊇ inst(T*): for an instance T*θ, (Tσ)θ = T(σθ), where σθ(M) = λh̄.B_Mθ is a
closed λ-term, and plugging the leaves ū^s commutes with substituting P's closed body. ∎

*Proof of "only if" (witnesses in PAT, hence in every H ⊇ PAT).*
* (R) fails, all roots f: replace each P(ā_k) by Φ_f(ā_k) with Φ_∈(ā) = g₁(ā) ∈ g₂(ā), Φ_=(ā) = g₁(ā) = g₂(ā) (function
  metavariables; values projections or parameters), Φ_¬(ā) = ¬Q(ā), Φ_∘(ā) = Q₁(ā) ∘ Q₂(ā) for binary ∘,
  Φ_Q(ā) = Qw.R(ā, w) for Q ∈ {∀, ∃, ∃!}. Every occurrence is a pattern occurrence; the template covers D (atoms of the
  language have variables or parameters as arguments) and misses T*[P := λz̄.ψ] for ψ with another root.
* (N_i) fails: replace each P(ā_k) by P′(ā_k minus its i-th entry); this covers D and misses T*[P := λz̄.(z_i = z_i)],
  whose content at a slot has the deleted variable free. ∎

**Per schema** (anchor events; two instances suffice in every case):

| schema | anchor iff | minimal anchor example (bodies) |
|---|---|---|
| Sep | (R), N_x, N_z | x∈z, ¬(x=a) |
| SepJ | (R), N_u | u∈a, ¬(u=u) |
| EInd | (R), N_x | x∈x, ¬(x=x) |
| Coll, ReplU, ReplS | (R), N_x, N_y, N_A | y=x, ¬(x=A) |
| ReplJ | (R), N_x, N_y | x∈y, ¬(x=a) |
| Found and every other ground ZFC axiom | the sentence itself | one instance |

If the community never lets φ mention the bounding set z (resp. the domain A), the learner stays at the sound
specialization with P(x) (resp. P(x,y)) — e.g. Jech's Separation instead of Kunen's.

*Remarks.* (1) Two instances suffice; one never does. (2) In {∈,=} there are no function symbols, so the "shielding"
phenomenon that separates SO° from DT° for PA induction (prior C7, condition (B)) and for Q1 in the PA language
(Prop A2′) cannot occur *for one metavariable*: DT° and SO° have the same anchors here. With several metavariables they
differ even in {∈,=} (Thm E′(c)). (3) With (R) + all (N_i) the cautious DT° verifier accepts exactly inst(T*), and before
that it is sound (T* ∈ DT° covers D; lem:imitation:cautious(a)).

**Lemmas for the enumeration (E1–E4) — proved.** Every covering template T is ⪰ one produced by the reduced enumerator
`st_enum.enumerate_dt_reduced`, so D is an anchor iff all produced templates are ⪰ T*: E1 rigid-prefix lemma (prior
C2(a)); E2 term metavariables at common positions can be replaced by their (forced, datum-independent) value, which
specializes T and keeps coverage; E3 in DT° an argument whose hole is unused by the (unique) bodies of all data can be
deleted at all occurrences (a specialization that keeps coverage and determinacy), so the own pattern occurrence's
arguments are exactly the free context variables of its column, in canonical order (argument permutation = renaming);
E4 every other occurrence of the metavariable has its arguments forced by the data (each hole is used in some datum).

*Evidence.*
* `z2_anchors.py` → `z2_anchors.out` (430 s on 4 cores; not re-run in this revision). Phase A, all 7 schemas, all 16
  singletons and all 120 pairs of each pool: no singleton is an anchor; for pairs with (R) the reduced DT° enumeration
  (complete for anchor-hood by E1–E4) gives anchor ⟺ all (N_i); for pairs without (R) the most specific covering DT°
  template on the maximal common prefix (`st_enum.most_specific_own`, root-specialized, e.g.
  ∀z∃y∀x(x∈y ↔ x∈z ∧ f₀(x,z) ∈ f₁(x,z)) for bodies x∈z, z∈x) is not ⪰ T*. Agreement "anchor ⟺ (R) ∧ all (N_i)": 120/120
  for every schema (anchors: Sep 97, SepJ 104, EInd 104, Coll/ReplU/ReplS 62, ReplJ 97). Typical non-anchor witness with
  (R) but not N_A (ReplU, bodies y=x, x∈y): ∀A(P₀(A) → ∃Y∀x(P₁(x,A) → P₂(x,Y))). Phase B, Sep, SepJ, EInd, all pairs with
  (R) (107, 110, 110): the full data-directed enumeration in DT° and in SO° (arity ≤ 3; every run finished within its
  10 s limit) agrees with (R) ∧ (N) on every pair. Every anchor pair has the *same* number of covering templates (Sep:
  DT° 986, SO° 4078; SepJ: 1325, 7103; EInd: 77, 2459) — consistent with the fact that for an anchor the covering
  templates are exactly the generalizations of T* (the analogue of prior C4's 26 generalizations of T_ind).
* `z2b_fullcheck.py` → `z2b_fullcheck.out` (stopped by a 20-minute budget): the full DT° enumeration on the large Coll
  frame finished for 2 anchor pairs (64 943 covering templates each, all ⪰ T*) and for 3 non-anchor pairs; all agree.
  The three ReplJ anchor pairs did not finish and are not counted.
* **[new]** `z9_anchor_search.py SCHEMA 10 3 2 1` → `z9_<SCHEMA>.out` (bounded single-group search of `dt_search.py`,
  group size ≤ 3, arity ≤ 2 (≤ 1 for groups of size 3), arguments: bound variables in scope and the parameter a,
  12 genuine probes; 10 anchor and 10 non-anchor pairs per schema, in DT° and SO°): DT° agreement with (R) ∧ (N) 20/20
  for each of the seven schemas, SO° verdicts identical to DT° verdicts on all 140 pairs; and
  `z9_anchor_search.py ReplJ 3 3 2 2` → `z9_ReplJ_deep.out` (arity ≤ 2 also for groups of size 3, i.e. including the
  group of all three ReplJ slots). See §4 for the numbers. This closes the ReplJ gap of `z2b` at the level of evidence;
  the referee's independent search covers 35 ReplJ anchor pairs with 0 disagreements
  (`referee_code/r3_anchor_A_ReplJ_big.out`), and the proof covers all cases.

### 2.9 Thm E′ (several metavariables) [new] — proved; computed

Let T* be a pattern template over {∈,=} (with parameters) with metavariables P, Q, … (arities n_P, …), every
occurrence a pattern occurrence, frame metavariable-free and parameter-free. Data D_j = T*θ_j with θ_j(P) = λz̄.φ_{P,j}.
For an ordered pair (P, Q) of distinct metavariables and a map π: [n_P] → [n_Q] ∪ Par write φ∘π for φ with each hole
z_i replaced by z_{π(i)} (resp. by the parameter π(i)). Events:
* (R_P): the roots of φ_{P,1},…,φ_{P,N} are not all equal; (N_{P,i}): some φ_{P,j} has z_i free;
* (D^PAT_{PQ}): there is no bijection π: [n_P] → [n_Q] with φ_{Q,j} = φ_{P,j}∘π for all j (vacuous if n_P ≠ n_Q; symmetric);
* (D^DT_{P→Q}): there is no map π: [n_P] → [n_Q] ∪ Par with φ_{Q,j} = φ_{P,j}∘π for all j;
* (D⁺_{PQ}): some j has root(φ_{P,j}) ≠ root(φ_{Q,j}).
D⁺ ⇒ D^DT (both directions) ⇒ D^PAT. Assume (R_P) and all (N_{P,i}) throughout. Then:
(a) D is an anchor in PAT iff (D^PAT_{PQ}) for all P ≠ Q;
(b) D is an anchor in DT° iff (D^DT_{P→Q}) for all ordered pairs P ≠ Q;
(c) in SO°: (D⁺_{PQ}) for all P ≠ Q ⇒ anchor ⇒ (D^DT_{P→Q}) for all ordered pairs; and the second implication cannot be
reversed: there are DT° anchors that are not SO° anchors.
Without (R_P) or (N_{P,i}), D is an anchor in no class between PAT and SO° (Thm E's witnesses, applied to P).
(This supersedes the "Remark (several metavariables)" of `notes.md` §2.8, which sketched one (D)-type event — "no
datum-independent argument renaming makes φ_{P,j}[ā_k] = φ_{Q,j}[b̄_l] for all j" — without fixing the class; the
renamings allowed are exactly what distinguishes PAT, DT° and SO°.)

**Facing lemma.** Let T ∈ SO° cover D, let M be a metavariable of T with occurrences M(ū^s) at c_s and bodies β_j, and
assume (R_P) for all P. (1) κ(c₁) and κ(c_s) have slots at the same positions and the same frame symbols at non-leaf
frame positions. (2) If κ(c₁) has a P-slot P(ā) at p and κ(c_s) a Q-slot Q(b̄) at p, then root(φ_{P,j}) = root(φ_{Q,j})
for all j. If moreover ū¹ is a pattern tuple and (N_P) holds, there is a map π: [n_P] → [n_Q] ∪ Par, independent of j,
with φ_{Q,j} = φ_{P,j}∘π for all j; if also ū^s is a pattern tuple and (N_Q) holds, π is a bijection onto [n_Q].
*Proof.* (1) is Step 2a of Thm E with (R_P) for the metavariable at each slot. (2) The root claim is the first sentence
of 2a. Let γ_j := β_j|p, so φ_{P,j}[ā] = γ_j with holes ↦ ū¹ and φ_{Q,j}[b̄] = γ_j with holes ↦ ū^s (relative binders
kept). Define π(i) for i ∈ [n_P]: by (N_P) pick j with a free occurrence q′ of z_i in φ_{P,j}; the leaf of
φ_{P,j}[ā] at q′ is a_i. (α) If a_i is bound above c₁, then γ_j|q′ = h_m with u¹_m = a_i, m unique because ū¹ is a
pattern tuple; the leaf of φ_{Q,j}[b̄] at q′ is u^s_m, which is free relative to p, hence equals some b_{i′} or is a
parameter; put π(i) := i′, resp. that parameter. (β) If a_i is bound by the binder at relative position r between c₁ and
p, then γ_j|q′ is the variable bound at r, and the leaf of φ_{Q,j}[b̄] at q′ is the variable bound at r in κ(c_s), which
lies above p, hence is some b_{i′}; put π(i) := i′. In both cases π(i) depends only on a_i (through m or r), not on j or q′.
Now compare φ_{P,j}[ā] and φ_{Q,j}[b̄] leaf by leaf through γ_j: constants, parameters and variables bound inside γ_j
below p are the same in both; a hole h_m gives u¹_m = a_i (a free leaf of the slot, hence an argument, as ū¹ consists of
bound variables) and u^s_m = (b_{π(i)} or π(i)); a variable bound between c₁ and p gives a_i and b_{π(i)}. Hence
φ_{Q,j} = φ_{P,j}∘π. If ū^s is also a pattern tuple, u^s_m is a bound variable, so π maps into [n_Q]; π is injective
(distinct a_i give distinct m or distinct r, hence distinct u^s_m or distinct binders, and the two cases give variables
bound above resp. below c_s); and every b_{i′} free in some φ_{Q,j}[b̄] arises from a hole or a binder between c_s and p,
hence from some a_i, so under (N_Q) π is onto [n_Q]. ∎

*Proof of the theorem.* "If" parts: let T in the class cover D. Step 1 of Thm E holds verbatim (using (R_P) for every
P). For each metavariable M of T choose c₁ as follows: in PAT and DT° a pattern occurrence of M; in SO° any. Every slot
of κ(c₁) faces, in each κ(c_s), a slot of the *same* metavariable: in SO° by (D⁺) and the root claim of (2); in DT° by
(D^DT) and the map of (2); in PAT by (D^PAT) and the bijection of (2). Then Steps 2b, 2c, 3 of Thm E apply slot by slot
(with (N_{P,i}) for the metavariable of each slot) and give T ⪰ T*.
"Only if": if (D^PAT_{PQ}) fails via the bijection π, let T′ := T* with every Q(b̄) replaced by P(b_{π(1)},…,b_{π(n_P)}) —
a pattern occurrence (b̄ distinct, π bijective). Then T′[P := λz̄.φ_{P,j}] = D_j, since φ_{P,j}∘π plugged with b̄ is
φ_{Q,j}[b̄]; and T′ misses every instance of T* whose P- and Q-bodies have different roots (in T′ the roots at the P-slots
and the former Q-slots coincide), which exist. So D is not a PAT anchor, nor an anchor in any larger class. If
(D^DT_{P→Q}) fails via π, the same construction with arguments w_i := b_{π(i)} or the parameter π(i) gives T′ ∈ DT° (P
keeps its pattern occurrences; the new occurrences have metavariable-free arguments), which covers D and misses the
same instances; so D is not a DT° (or SO°) anchor. The separation in (c) is the computed example below: there the SO°
template ∀x∀y(G(x,y,x) → G(x,x,y)) covers D and misses a genuine instance, while (D^DT) holds, so D is a DT° anchor
by (b). ∎

**Cor F′ (pattern lgg with several metavariables) — proved.** The least general pattern generalization L_pat(D) is ≡ T*
iff (R), (N) and (D^PAT) hold; otherwise it is a strict specialization of T* (sound). *Proof.* As Cor F (§2.10), with
Thm E′(a) in place of Thm E. ∎

*Separating examples (computed).* (i) PAT anchor, not a DT° anchor: T_B := ∀x∀y(P(x,y) → Q(x)), data
(P, Q) = (x∈y, x∈x) and (¬x=y, ¬x=x). (R), (N), (D^PAT) hold (arities differ), so the pattern lgg returns T_B; but
Q's bodies are P's bodies with π = (1,1) (diagonal), and the DT° template ∀x∀y(P(x,y) → P(x,x)) covers both data and
misses ∀x∀y(x∈y → ¬x=x). A parameter variant: Q-bodies x∈a, ¬a=x against P-bodies x∈y, ¬y=x, witness
∀x∀y(P(x,y) → P(x,a)). (ii) DT° anchor, not an SO° anchor: T_A := ∀x∀y(P(x,y) → Q(x,y)), data (x∈y, y∈x) and
(¬x=y, ¬x=x): (R), (N), (D^PAT), (D^DT) hold, (D⁺) fails; the SO° template ∀x∀y(G(x,y,x) → G(x,x,y)) covers both data
(G := λh₁h₂h₃.h₃∈h₂, resp. λh₁h₂h₃.¬h₁=h₂) and misses ∀x∀y(x∈y → ¬x=x).

*Evidence.* `z7_multi.py` → `z7_multi.out` (12 s). (1) PAT: for T_A, T_B and T_C := ∀x(P(x) → Q(x)) → (∀xP(x) → ∀xQ(x)),
1500 random data sets each (pairs and triples, 35 % drawn with a planted coincidence map): "pattern lgg ≡ T*" ⟺
(R) ∧ (N) ∧ (D^PAT) on 1500/1500 for each; for T_B, 402 of these PAT anchors violate (D^DT). (2) DT°: bounded
single-group search on 150 random pairs with (R) ∧ (N) for T_B and for T_A: anchor ⟺ (D^DT) on 150/150 each (1404 and
1235 covering templates examined). (3) The two separating examples, verified by matching (the SO° template is not
determinate; the bounded DT° search finds no covering template missing a probe). (4) SO°: on 120 random pairs per
template, every pair with (D⁺) is an SO° anchor (70/70, 43/43) and every pair violating (D^DT) is not (0/46, 0/74); the
few random pairs with (D^DT) but not (D⁺) (4 and 3) happened to be SO° anchors, so whether (D⁺) is necessary in SO° is
not settled by this evidence (conjecture: no — the exact SO° condition is data-dependent, as example (ii) shows).

### 2.10 Cor F (pattern anti-unification recovers every ZF schema) — proved; computed

Let L_pat(D) be the least general pattern generalization (exists and is unique: Pfenning 1991; Baumgartner, Kutsia,
Levy, Villaret 2017, J. Autom. Reasoning 58 — known). For D ⊆ inst(T*) (T* a pattern template as in Thm E):
L_pat(D) ⪯ T*, and L_pat(D) ≡ T* iff (R) ∧ all (N_i).
*Proof.* T* ∈ PAT covers D, so L_pat ⪯ T*. If (R) ∧ (N), Thm E's proof (H = PAT) gives L_pat ⪰ T* (it constructs σ with
L_pat σ↓ = T*). Otherwise the PAT witnesses of Thm E cover D and do not contain inst(T*), and they are ⪰ L_pat, so
L_pat ≢ T*. ∎

*Evidence.* `z3_pattern_lgg.py` → `z3_pattern_lgg.out` (re-run: identical): own n-ary implementation (common prefix;
generalization variable applied to the bound variables free in the column; merge of columns equal up to a permutation of
the arguments — BKLV's merge rule). On all 120 pairs and 400 random triples per schema: the result is a pattern template,
covers the data, is ⪯ T*, and is ≡ T* iff (R) ∧ (N) (120/120 and 400/400 for all 7 schemas). Example: from Coll(y = x)
and Coll(¬x = A) it returns Coll's template verbatim. The same code style on PA induction (prior so_core) returns the
unsound T12 = (A ∧ ∀x(P(x) → Q(x))) → ∀xP(x) — the prior C9 contrast. The permutation merge matters: Replacement's P(x,y)
and P(x,u) columns are equal only up to renaming y ↔ u. Referee: own BKLV-style implementation, 3500/3500 data sets, and
10 500 random instances of the lgg all genuine (`referee_code/r3_anchor_B.out`).

### 2.11 Thm G (rates for the ZF learners) — proved; computed

Bodies i.i.d. from μ. With C_{F,I} := {φ: (F = * or root(φ) = F) and no z_i, i ∈ I, free in φ},
P[D_N is not an anchor] = Σ_{(F,I) ≠ (*,∅)} (−1)^{[F≠*] + |I| + 1} μ(C_{F,I})^N
(sum over F ∈ {*} ∪ roots, I ⊆ {1..n}), ≤ Σ_f p_f^N + Σ_i (1−q_i)^N, where p_f = μ(root f), q_i = μ(z_i free).
*Proof.* "Not an anchor" = ⋃_f A_f ∪ ⋃_i B_i (Thm E), A_f = all roots f, B_i = z_i never free. The A_f are pairwise
disjoint, and ⋂ of A_f (or none) with B_i, i ∈ I, is "all samples in C_{F,I}"; inclusion–exclusion. ∎
*Evidence.* `z6_rates.py` → `z6_rates.out`: uniform and atom-skewed laws on the 16-body pools, 3000 Monte-Carlo trials
with the pattern lgg: exact and MC agree within sampling error for all N ∈ {2,…,12}. N needed for δ = 0.01: Sep 5 / 9
(uniform / skewed), EInd 4 / 6, Coll and ReplS 10 / 16 (three (N_i) events), ReplJ 5 / 9. Referee: own inclusion–exclusion
against own Monte Carlo, 7 schemas, 2 laws, N = 2..8 (`referee_code/r4_rates.out`).

---------------------------------------------------------------------------------------------------------------

## 3. Relation to the brief's proposed answers (§5)

* **Q1: confirmed, with precision.** Anchor = Plotkin's events specialized (Thm A2), the same in DT° but not in SO° (A2′);
  the ω-gap is characterized exactly by M₀ ≼ M (A5); the hidden ω-step occurs in the *cautious* learner whenever
  parameters are instances and no closedness guard is in the class (A4(b)) — a point the brief does not make.
  **[revised]** The brief's claim "φ(z) is a first-order pattern: plain lgg works" needs the brief's own λ convention
  (§3 of the brief: metavariable values have no bound variables): in the named or de Bruijn first-order syntax the
  instance schema is not H₁-closed when some free x lies under a binder, because of capture instances (A4′); a
  "nocap" guard learned from data repairs it.
* **Q2: confirmed** — all ZF schemas are in the pattern fragment, pattern anti-unification and the DT° learner work,
  anchors are (R) + argument-use events (Thm E, Cor F); every ground ZFC axiom is its own anchor.
* **Q2: corrected** (Thm B1, Prop B2, C2, C3): ∈-induction is a first-order pattern in de Bruijn syntax; freshness is not
  automatic in the de Bruijn *first-order* encoding (Separation; Collection without A); Collection/∃!-Replacement with A
  in φ are first-order only in the named encoding *with textbook names* (B1α); spelled-out Replacement yields a
  truth-sound first-order lgg in the named encoding with textbook names (exactly as sound as Collection, C3′) and false
  lgg instances in de Bruijn and under α-variation; Jech's Replacement yields false instances in both. The robust
  statement is Thm B1/B1α: *first-order iff P's argument tuple is literally the same at every occurrence in the chosen
  syntax* (same names, same indices, or — when names vary — same binders).
* **For the method question (Q3, not this track):** ZF and Q1 data are pattern targets, so any learner whose class
  contains PAT and whose anchors are Thm E's applies to single schemas; DT° is needed only for PA-style schemas.
  **[new]** For targets with several metavariables — and an untagged mixture of schemas behaves like one — the anchor
  condition acquires a Plotkin-(D)-type event that *depends on the hypothesis class* (Thm E′): a learner using DT°
  needs more data diversity (D^DT) than one using PAT (D^PAT), and SO° needs still more in some cases. A method track
  should state its anchor theorem relative to its class.

## 4. Files, commands, outputs

All commands: `cd research/tracks/cases && python3 <script> [args]`. "Re-run" = re-run in this revision with output
identical to the recorded one (diff empty).

| script | claims | output | time |
|---|---|---|---|
| `q1_lgg.py` | A1, A2 (computed), A4(c), A3 rates vs MC, A2′ SO° counterexample | `q1_lgg.out` (re-run) | ~85 s |
| `q1_qmodel.py` | Ex. A8 model of Q | `q1_qmodel.out` (re-run) | <1 s |
| `q1_capture.py` **[new]** | A4′: capture examples, decomposition of inst(σ_φ) with the predicted criterion asserted, guard learning, de Bruijn capture | `q1_capture.out` | <1 s |
| `q1_dt.py` **[new]** (uses `dt_search.py`) | A2′ DT° half (99/99) and SO° non-anchors with binders | `q1_dt.out` | 7 s |
| `z1_encodings.py` | B1 criterion, B2 blocks, §2.4 false instances, (3b) dB capture, (4) EInd-dB, (5) only-if | `z1_encodings.out` (re-run) | ~5 s |
| `z2_anchors.py` | Thm E (reduced DT°; full DT°/SO° on small frames) | `z2_anchors.out` | ~7 min (4 cores) |
| `z2b_fullcheck.py` | Thm E, full DT° on the large frames (5 of 8 pairs finished) | `z2b_fullcheck.out` | 20 min budget |
| `z3_pattern_lgg.py` | Cor F; PA contrast | `z3_pattern_lgg.out` (re-run) | ~10 s |
| `z4_guards.py` | Prop D1 | `z4_guards.out` (re-run) | ~2 s |
| `z5_deepleaf.py` | Lemma C1 hypotheses and conclusion on random τ | `z5_deepleaf.out` (re-run) | ~5 s |
| `z6_rates.py` | Thm G | `z6_rates.out` | ~3 min |
| `z7_multi.py` **[new]** | Thm E′: PAT via pattern lgg (4500 data sets), DT° via bounded search (300 pairs), separating examples, SO° | `z7_multi.out` | 12 s |
| `z8_alpha.py` **[new]** | Prop B1α, §2.4(8), Thm C2(iv) | `z8_alpha.out` | 1 s |
| `z9_anchor_search.py S 10 3 2 1` **[new]** | Thm E, bounded single-group search, 7 schemas × 20 pairs, DT° and SO° | `z9_<S>.out` | 2–186 s each |
| `z9_anchor_search.py ReplJ 3 3 2 2` **[new]** | Thm E on ReplJ including the 3-slot groups of arity 2 | `z9_ReplJ_deep.out` | 757 s |

`z9` summary (DT° agreement with (R) ∧ (N); SO° verdict = DT° verdict on every pair; covering single-group templates
examined DT° / SO°): Sep 20/20 (2034 / 2722); SepJ 20/20 (2090 / 2820); EInd 20/20 (515 / 1155); Coll 20/20 (4548 / 6010);
ReplU 20/20 (4548 / 6010); ReplS 20/20 (9458 / 11890); ReplJ 20/20 (5450 / 6834). ReplJ deep run (arity ≤ 2 for all group sizes, so the
group of all three ReplJ slots is included): 3 anchor + 3 non-anchor pairs, DT° agreement 6/6, SO° verdict = DT°
verdict on all 6; each anchor pair has 3456 (DT°) / 3891 (SO°) covering single-group templates, none missing a probe;
757 s.

## 5. Caveats and uncertain citations

* Computations cover pools of 16 bodies per arity (atoms, connectives, one internal quantifier, parameters) and random
  bodies for Thm E′; the theorems are proved for all bodies. The SO° enumeration is bounded to arity ≤ 3 (DT° needs no
  bound by E3). The new searches (`dt_search.py`) are bounded (group size, arity, argument pool); "no covering template
  misses a probe" is evidence, not proof, and the probes are finitely many genuine instances.
* "False" claims are proved by short ZF arguments or by Δ₀-absoluteness from HF witnesses; no general truth evaluator for
  set theory is used. The finite-structure checks (sizes ≤ 3, or ≤ 5 for pure equality) only test the pure-logic steps.
* The named encoding of Part 2 assumes textbook names unless §2.2a (α-variation) is invoked. Data that α-rename only
  *some* binders lie between the two analyses; Prop B1α's "only if" needs data in which the two binders at a differing
  argument position get different names.
* Citations: Kunen 1980 axiom wording and numbering, and that Kunen treats ∃! as an abbreviation (I believe); Jech 2003
  axiom wording (1.3, 1.7, 1.8; unverified); the location in Boolos–Burgess–Jeffrey of "Q ⊬ ∀x(0+x=x)" (unverified); the
  provability of Collection in ZF is standard (via ranks, e.g. Lévy 1979, *Basic Set Theory* — I believe); Tarski–Vaught
  1957 (Compositio Math. 13) for the elementary-substructure test; Pfenning 1991 (LICS) and Baumgartner–Kutsia–Levy–
  Villaret 2017 (J. Autom. Reasoning 58(2), as far as I know) for pattern anti-unification — I have not run their
  implementation; mine is n-ary with a permutation merge.

## 6. Open problems (for the paper / other tracks)

* **SO° anchors with several metavariables.** Thm E′ gives the exact condition in PAT and DT° and a sandwich in SO°
  ((D⁺) sufficient, (D^DT) necessary, the latter not sufficient). The exact SO° condition is data-dependent (example (ii)
  of §2.9); whether (D⁺) is necessary is open (conjecture: no).
* **SO° anchors for Q1 in languages with closed terms** (an analogue of prior C7's condition (B)); only counterexamples
  are given (A2′).
* Escalation counts of the DT° verifier on ZF data before an anchor (prior C11 is open for PA as well).
* **Prop C3′:** does ZF − Foundation prove Collection? By C3′ this decides whether the named spelled-out-Replacement lgg
  (textbook names) is truth-sound without Foundation. Status unknown to me.
* α-variation: Prop B1α settles the full-renaming case; communities that rename only some frame variables, or rename
  inconsistently across a corpus, are not analysed beyond the remark in §5.
* Untagged mixtures of ZF schemas and of instance schemas φ(z) (Q3) belong to the method tracks; this track supplies the
  per-schema anchors, the several-metavariable anchor theorem (E′), the encoding classification and the capture analysis.

---------------------------------------------------------------------------------------------------------------

## Verification log

Each referee verdict, finding and "missing" item, with its resolution. "Re-run" means the script was run again in this
revision and its output is identical to the recorded one.

### Verdicts

| id | referee verdict | resolution |
|---|---|---|
| A1 | holds | Kept. Added the remark that A1 uses closed instances only, so it holds in all three syntaxes (§1.2). `q1_lgg.py` re-run. |
| A2 | holds | Kept (§1.3). Added: anchor-hood concerns only inst(τ) ⊇ inst_c(φ), so A2 is convention-independent; the claim inst_c(φ) = inst(σ_φ) is now made only under the λ convention (§1.1), as the referee required. Referee's 36 000/36 000 cited. |
| A2′ | holds (DT° half not computed) | DT° half now computed: `q1_dt.py` → `q1_dt.out`, anchor ⟺ prediction on 99/99 pairs over 5 formulas (3 with binders, 1 two-variable). SO° non-anchors with binders exhibited (§1.3). The proof text was made explicit for hole positions that receive closed-term arguments at non-pattern occurrences (the case the referee checked). |
| A3 | holds (ρ undefined) | ρ defined in the statement (ρ_i = best root split, r_{ii′} = P[t_i ≠ t_{i′}], ρ = min), and the (1−ρ)^N → e^{−Nρ} step written out (§1.4). "Match the bound" replaced by "lie below the bound (about a factor 2 in N)". |
| A4 | holds-with-fix | Fixed. A4(b) now says cl = inst(σ_φ) = inst_o(φ) *under the λ convention*; in the named/de Bruijn first-order syntax cl = inst(σ_φ) ⊋ inst_c ∪ inst_o (capture). New Prop A4′ characterizes capture exactly (when it occurs in each syntax; examples false in every structure, or false in ℕ although ∀xφ is valid), shows that the unguarded verifier is unsound outright, and shows that the guard nocap(z) is learned from data and restores exactness. Computed: `q1_capture.out`. |
| A5 | holds | Kept; citation Tarski–Vaught 1957 added. |
| A6-A7 | holds | Kept unchanged. |
| A8 | holds | Kept; `q1_qmodel.py` re-run; referee's {0..60} check cited; BBJ location still marked unverified. |
| A10-A11 | holds-with-fix | Fixed: A10.1 and A10.4 now name capture alongside the ω-step and require the nocap guard or the λ convention in the named/de Bruijn syntax; §0 items 1 and 3 likewise. A10.2 now says it *is* Prop A5. New A11(d): the world channel does not protect against capture (∃y(y=Sy) is refutable from PA, not from Q). |
| ZF-form | holds (∃! attribution) | Fixed: "ReplU (Kunen, ∃! primitive)" now reads "∃! as a primitive binder — our encoding choice; Kunen treats ∃! as an abbreviation (I believe)". Hedges kept (§2.1). |
| B1 | holds | Kept; `z1_encodings.py` re-run. Extended by Prop B1α (α-variation, §2.2a). |
| B2 | holds | Kept; referee's 2417 random pairs cited. |
| C-ex | holds | Kept; new item 8 (α-varied named encoding) added, computed in `z8_alpha.out` (2). |
| C2 | holds | Kept; `z5_deepleaf.py` re-run. Extended by case (iv) (Coll, ReplU, ReplS under α-variation), with a different designated leaf because the de Bruijn leaf is not unique in the named encoding; hypothesis and pure-logic steps computed in `z8_alpha.out` (4). Lemma C1 now also covers name metavariables and distinct-guards. |
| C3 | holds | Kept, with the learned guards listed. Sharpened by Prop C3′: truth-soundness over a base B ⟺ B ⊢ Collection, so the open question is exactly "ZF − Foundation ⊢ Collection?". Noted that C3 depends on textbook names (fails under α-variation). |
| D1 | holds | Kept; `z4_guards.py` re-run; referee's 1537/1537 cited. |
| E | holds (one inaccurate sentence) | Fixed: Step 2 rewritten (2a–2c) for arguments that are bound variables *or parameters*, possibly repeated; it records holes only at frame variables and shows that each recorded u^s_m is a bound variable; the old sentence is quoted and retracted. New evidence `z9_*` (7 schemas × 20 pairs, DT° and SO°, all agree), including ReplJ anchor pairs; the referee's 35 ReplJ anchors cited. |
| F | holds | Kept; `z3_pattern_lgg.py` re-run; referee's BKLV-style check cited. Extended by Cor F′ (several metavariables). |
| G | holds | Kept; referee's check cited. |

### Findings

| finding | resolution |
|---|---|
| F1 (capture in Q1) | Accepted. Variable convention fixed explicitly (§1, §1.1); A4(b) corrected; Prop A4′ added (proof + `q1_capture.out`); §0 items 1, 3, A10, A11(d), §3 revised. |
| F2 (de Bruijn capture, Part 1 vs Part 2) | Accepted. The Part 1 sentence now restricts "no capture" to the λ/locally-nameless convention and points to de Bruijn index capture (§1.1, A4′(b), §2.4(7)). |
| F3 (Thm E argument sentence) | Accepted; Step 2 rewritten (§2.8). |
| F4 (coverage of evidence) | ReplJ: own bounded search on 10 anchor + 10 non-anchor pairs, plus the deep run with 3-slot groups (`z9_ReplJ*.out`); referee's 35 anchors cited. A2′: DT° half computed (`q1_dt.out`); SO° failures with binders shown. |
| F5 (hygiene) | ρ defined (A3(c)); "match the bound" → "lie below the bound"; A10.2 cites A5 as its proof. |
| F6 (citations) | Kunen ∃! attribution corrected; Tarski–Vaught 1957, BKLV 2017 (JAR 58(2)), Pfenning 1991 kept as cited; Jech, BBJ, Lévy remain marked unverified/"I believe". |

### Missing or under-treated

| item | resolution |
|---|---|
| 1. Capture for Q1 | Done (F1): §1.1, Prop A4′, A10, A11(d). |
| 2. DT° half of A2′ not computed | Done: `q1_dt.out`, 99/99. |
| 3. Several metavariables only sketched | Done: Thm E′ (proved) with the facing lemma; exact anchor conditions in PAT and DT°, sandwich in SO°, separating examples showing that the three classes have different anchors; Cor F′; computed in `z7_multi.out`. The old "Remark (several metavariables)" is superseded (its (D)-type event is now D^PAT / D^DT, and it is class-dependent). |
| 4. Ground axioms | Done: §2.1 remark and the per-schema table (§2.8). |
| 5. Renaming of frame variables (named encoding) | Done for full α-variation: Prop B1α (proved), consequences for Coll/ReplU/ReplS, C2(iv), C3; computed in `z8_alpha.out`. Partial renaming remains a caveat (§5). |
| 6. C3 without Foundation | Reduced exactly to "ZF − Foundation ⊢ Collection?" (Prop C3′, proved); the latter remains open here (§6). |

Nothing from `notes.md` was withdrawn; every statement there is restated above, corrected where indicated.
