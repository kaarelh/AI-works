# Track C: learning raw induction instances with second-order templates

Scope. The data are raw sentences of first-order arithmetic

    Ind(phi) := phi(0) & Ax (phi(x) -> phi(Sx)) -> Ax phi(x),     FV(phi) ⊆ {x},

used by a community without mistakes (noise in C10). Classical first-order logic is trusted. Track B showed that no
first-order schema, and no finite union of them, covers these data soundly; the obstruction is the meta-level substitution
in phi(0) and phi(Sx). Here the hypotheses are *second-order templates*: predicate metavariables may be applied to terms,
and instances are obtained by substituting lambda-terms and beta-reducing. The question is which learner to use, what it
needs from the data, and what can be proved.

Status labels: **proved** (full proof here), **computed** (script run, output file named), **known** (literature),
**conjecture**. All scripts are in this directory. The two library files are `so_core.py` (representation, instantiation,
matching, subsumption) and `so_enum.py` (template enumerators). The motive pool is in `so_pool.py`.

---------------------------------------------------------------------------------------------------------------------------

## 0. Answers in brief

1. **Algorithm.** Use a cautious version-space verifier over *determinate* second-order templates (class DT, §1). A template
   is determinate if every metavariable has at least one occurrence, at a rigid position, applied to distinct bound
   variables (a Miller-pattern occurrence). The learner works as follows.
   - Compute the common prefix of the data.
   - At each disagreement slot, either read a metavariable off a pattern occurrence or explain the slot as a *derived*
     occurrence M(u) of another slot's metavariable.
   - Keep the minimal covering templates and accept a sentence iff every one of them matches it.

   On induction data the version space collapses to the single template

       T_ind = P(0) & Ax (P(x) -> P(Sx)) -> Ax P(x)

   as soon as the data contain two motives with different main symbols, at least one with x free (C3, C4). Verifying a step
   then means reading P off the conclusion and checking the other two occurrences. This takes linear time (C1). Soundness
   holds at all times (C6).

2. **Matching** (C1). For a determinate template, matching a sentence has at most one solution, and the solution can be
   computed in time O(|T|·|s|). The pattern occurrence fixes each metavariable, and the other occurrences are checked by
   evaluation. Without determinacy, matching is still polynomial when arguments contain no metavariables, but there can be
   exponentially many matchers (P(0) against a sentence with k zeros has 2^k). General second-order matching is decidable
   with finitely many matchers (Huet–Lang 1978).

3. **Anchors.** Two conditions on the motives in D matter:
   - **(R)**: the motives do not all have the same main symbol;
   - **(N)**: some motive has x free.

   *Theorem C3:* a finite D ⊆ Ind is an anchor in DT iff (R) and (N) hold, at any template size. So two instances suffice and
   one never does. These are exactly the conditions under which the first-order lgg of the Sub-encoded data recovers the
   Sub-induction schema (C5). The raw second-order learner is therefore exactly as data-efficient as the first-order learner
   on Sub-annotated data, at the same coupon-collector rate.

   Determinacy matters. In the wider class SO° (no pattern occurrence required), the anchors are exactly (R) plus
   - **(B)**: some motive has an *unshielded* free occurrence of x, i.e. one that lies inside no proper term t ≠ x with
     FV(t) ⊆ {x}.

   For example, {Ind(Sx=S0), Ind(~Sx=0)} satisfies (R) and (N) but not (B). It is covered by
   T_S = P(S0) & Ax(P(Sx) -> P(SSx)) -> Ax P(Sx), and by the 6-symbol template B -> Ax P(Sx). Both miss Ind(x=x) (C7).

4. **Lgg.**
   - DT is **not unitary**: there is a two-element D with two incomparable minimal covering templates and no least one (C8).
     For non-anchor induction data the minimal set can also have several elements: 8 for {Ind(x=x), Ind(0=x)} (computed).
   - For every anchor, T_ind is the lgg (C4).
   - The pattern-restricted lgg of Pfenning 1991 and Baumgartner–Kutsia–Levy–Villaret 2017 is unsound on raw induction
     data. It is A & Ax(P(x) -> Q(x)) -> Ax P(x), which has false instances (C9). T_ind lies outside the pattern fragment,
     because P(0) and P(Sx) are not pattern occurrences. DT is the pattern fragment plus *derived* non-pattern occurrences.

5. **Size bounds** (C6).
   - General lemma: with an anchor, the cautious verifier over H is sound iff the target equals the intersection of the
     members of H that contain it ("H-closed"). Realizability is sufficient but not necessary.
   - With |T_ind| = 14, Ind is DT_s-closed **iff s ≥ 12**.
   - For 7 ≤ s ≤ 11, (R)+(N) still characterize anchors, but the cautious verifier accepts the false sentence
     s* = (0=0 & Ax(x=x -> Sx=Sx)) -> Ax(x=0).

6. **Proof assistants** record the motive explicitly, as in Nat.rec (motive := fun x => phi). In DT terms, this tags each
   datum with the unique matcher that C1 recovers anyway. Recording it is harmless redundancy, not information the learner
   lacks (C12).

---------------------------------------------------------------------------------------------------------------------------

## 1. Setting and definitions

**Object language.** Terms are built from 0, S, +, · and variables. Formulas are built from =, ¬, ∧, ∨, →, ∀, ∃.
- Formulas are taken modulo alpha. The scripts use de Bruijn indices; the printer names bound variables x, y, u, ... by
  binder depth.
- A *motive* is a formula phi with FV(phi) ⊆ {x}. Ind = {Ind(phi) : phi a motive}; all its members are theorems of PA.
- root(phi) is the main symbol of phi: =, ¬, ∧, ∨, →, ∀ or ∃. It is never a variable.
- ℓ(phi), the *logical size*, is the number of formula-level nodes: atoms, connectives and quantifiers.

**Templates.**
- Types: ι (terms) and o (formulas). A metavariable has type ι^n→ι (function metavariable; a term metavariable when n=0) or
  ι^n→o (predicate metavariable; a formula metavariable when n=0).
- A *template* T is a formula of the object language in which subterms F(t_1..t_n) and subformulas M(t_1..t_n) may occur.
  Here F and M are metavariables and the t_i are terms, which may themselves contain metavariables. T has no free object
  variables.
- In Church's encoding, with ∀ : (ι→o)→o, a template is a β-normal η-long simply typed λ-term with free metavariables.
- A ground substitution θ maps each metavariable to a closed λ-term λz_1..z_n.β, where β is a metavariable-free term or
  formula with FV(β) ⊆ {z_1..z_n}.
- The instance Tθ↓ is the β-normal form of Tθ. inst(T) is the set of these instances; each is a sentence.
- Bodies are first-order: only ι-variables are λ-bound. So β-reducing (λz̄.β)(ū) = β[ū/z̄] creates no new redex, and
  normalization is "substitute and plug", innermost first.

**Generality and size.**
- T ≥ T' (T is at least as general as T') iff T' = Tσ↓ for some substitution σ of λ-terms, which may contain T''s
  metavariables. T ≥ T' implies inst(T) ⊇ inst(T').
- The scripts test T ≥ T' by *freezing*: replace the metavariables of T' by fresh rigid symbols, then match
  (`so_core.subsumes`).
- |T| counts symbol occurrences:
  - each bound-variable occurrence counts 1;
  - each quantifier counts 1;
  - an occurrence M(t_1..t_n) counts 1 + Σ|t_i|.

  For example |T_ind| = 14 and |Ind(x=x)| = 19.

**Rigid positions, patterns, classes.**
- A position of T is *rigid* if no proper prefix of it is a metavariable occurrence, i.e. it is not inside a metavariable's
  arguments.
- A *pattern occurrence* of M is a rigid occurrence M(y_1..y_n) whose arguments are pairwise distinct variables bound in T
  above the occurrence. For n=0, any rigid occurrence counts.
- **DT** is the class of *determinate* templates: every metavariable has a pattern occurrence. DT_s = {T ∈ DT : |T| ≤ s}.
- **SO°** is the class of templates in which every metavariable occurrence is rigid and has metavariable-free arguments. No
  determinacy is required.
- DT° = DT ∩ SO°.
- T_ind ∈ DT°: its pattern occurrence is P(x) under the conclusion's ∀x. P(0) and P(Sx) are non-pattern occurrences, so T_ind
  is **not** a higher-order pattern in Miller's sense.

**The frame.** Every Ind(phi) has the shape

    R = imp( U = and( a , s = ∀x W ) , V = ∀x d ),   W = imp(b, c),

with slot contents

| slot | content | free variables |
|---|---|---|
| a | phi[0/x] | closed |
| b | phi | depth 1 (x in scope) |
| c | phi[Sx/x] | depth 1 |
| d | phi | depth 1 |
| W | phi → phi[Sx/x] | depth 1 |
| s | ∀x(phi → phi[Sx/x]) | closed |
| V | ∀x phi | closed |
| U | a ∧ s | closed |
| R | the whole sentence | closed |

With L = ℓ(phi) ≥ 1, the logical sizes are:
- a, b, c, d: L
- W: 2L+1
- s: 2L+2
- V: L+1
- U: 3L+3
- R: 4L+5

These six classes are pairwise distinct for L ≥ 1.

**Data conditions** for a finite D ⊆ Ind with motives phi_1..phi_N:
- (R): the roots of the phi_j are not all equal.
- (N): some phi_j has x free.
- (B): some phi_j has an *unshielded* free occurrence of x. An occurrence of x is unshielded if it lies inside no proper
  term t ≠ x with FV(t) ⊆ {x}. Equivalently, its parent is a predicate symbol, or its parent term contains a variable bound
  inside phi.
  - Examples: x=x and 0+x=x (the right-hand x) are unshielded. Ay(y+x=x+y) is unshielded, because the parent y+x contains
    y. In Sx=S0 and x+0=0 every occurrence is shielded.
  - (B) implies (N).

**Anchors and the cautious verifier.** These follow the paper (def:imitation:anchor, lem:imitation:cautious).
- VS_H(D) = {h ∈ H : D ⊆ h}. The cautious verifier accepts Acc_H(D) = ∩VS_H(D).
- D ⊆ Ind is an *anchor* for Ind in H if every h ∈ H with D ⊆ h contains Ind.
- With H a class of templates, h = inst(T).

---------------------------------------------------------------------------------------------------------------------------

## 2. The proposed learning algorithm

**SOCL: second-order cautious learner** (hypothesis class DT, or DT_s with s ≥ 12).

*Input.* A finite multiset D of sentences: the induction-tagged data, or all data in the untagged variant.

1. *Common prefix.* Compute C(D), the set of positions on which all data agree, top-down, on de Bruijn trees. This is
   Plotkin–Reynolds anti-unification with the disagreement positions kept as *slots*; each slot σ has a content column
   (c_1(σ), …, c_N(σ)).
2. *Pattern fillers.* Each slot σ gets an own metavariable M_σ applied to the bound variables ȳ_σ that occur in its column.
   This is a Miller pattern occurrence, with θ_i(M_σ) = λȳ.c_i(σ).
3. *Derived fillers.* For each ordered pair of slots (σ, π), look for terms ū such that c_i(σ) = c_i(π)[ū/ȳ_π] for every i.
   Each component of ū is forced by any datum in which the corresponding variable occurs free: substitution into a formula
   with a free occurrence is injective (Lemma A(ii)). Each solution gives a possible filler M_π(ū) at σ.
4. *Version space.* The covering templates are the prefixes of C(D) with fillers from {fresh 0-ary (closed columns), own
   pattern, derived occurrence}. This follows from Lemma C2. Keep the minimal ones under ≥ (the set Min(D)); there may be
   several (C8). For bounded s, enumerate within the size bound.
5. *Verification.* Accept a step q iff q ∈ inst(T) for every T ∈ Min(D). Each test is a determinate match (C1).

*Specialization to induction data.* When D ⊆ Ind satisfies (R) and (N), C3 and C4 give Min(D) = {T_ind}. The verifier is then:
- read P := λx.phi off the conclusion Ax phi;
- check that the antecedent is phi[0/x] & Ax(phi -> phi[Sx/x]).

Before that point the verifier is still sound (C6), but it accepts only a specialization of Ind. For example, with
D = {Ind(x=x), Ind(x+0=x)} it accepts exactly the induction instances with motives of the form t(x) = x (computed, C8).

*Noise.* Use the trimmed version space, accepting ∩{inst(T) : T ∈ DT, |D \ inst(T)| ≤ e}. It is sound with at most e
mistakes, and exact once the clean data are e-robustly diverse (C10).

*Why not simpler alternatives.*
- First-order lgg on raw data is unsound (Track B).
- Pattern anti-unification is unsound (C9).
- Unrestricted second-order templates (SO°) need the stronger condition (B), and their matching is ambiguous (C1, C7).
- Determinacy is what makes matching unique and anchors small.

---------------------------------------------------------------------------------------------------------------------------

## 3. Propositions

### C1. Matching. (proved; computed)

**Statement.**
(a) Let T ∈ DT and let s be a sentence.
- There is at most one θ, on the metavariables of T, with Tθ↓ = s.
- The following algorithm decides whether one exists and returns it:
  1. Walk the rigid part of T against s and fail on a symbol clash.
  2. For each metavariable M, take one pattern occurrence M(ȳ) at rigid position p and set θ(M) := λz̄.(s|p)[z̄/ȳ]. Fail if
     s|p has a free variable outside ȳ.
  3. Check Tθ↓ = s.
- It runs in time O(|T|·|s|) when step 3 is done lazily with closures; it is linear for T_ind.

(b) For T ∈ SO°, deciding s ∈ inst(T) takes polynomial time. The number of matchers can be 2^Ω(|s|).

(c) For T_ind the algorithm is: P := λx.phi from the conclusion Ax phi; then check the antecedent against phi[0/x] and
Ax(phi -> phi[Sx/x]).

**Lemma (preservation).** Let p be a rigid position of T.
- If T has a non-metavariable symbol f at p, so does Tθ↓.
- If T has a metavariable occurrence M(t_1..t_n) at p and θ(M) = λz̄.β, then (Tθ↓)|p = β[t_1θ↓,…,t_nθ↓ / z̄], with
  capture-avoiding substitution.

*Proof.* The β-redexes of Tθ are exactly the subterms (λz̄.β)(t̄θ) at metavariable occurrences. Normalize innermost first:
- the arguments normalize to first-order terms ū;
- β[ū/z̄] substitutes ι-terms for ι-variables in a first-order body, which creates no redex.

So Tθ↓ is T with each maximal (rigid) occurrence replaced by its plugged body. The rigid part is untouched. Capture: β is
closed except for z̄, so its internal binders can be renamed away from FV(ū). ∎

*Proof of (a).*

Uniqueness.
- Let Tθ↓ = s, and let M(ȳ) be a pattern occurrence at rigid p.
- By preservation, s|p = β_M[ȳ/z̄]. The ȳ are distinct variables and β_M is closed except for z̄, so β_M = (s|p)[z̄/ȳ].
- This forces FV(s|p) ⊆ ȳ among the variables bound above p. So θ(M) is determined by s.

Correctness.
- If any matcher exists, step 2 computes it.
- If step 3 succeeds, θ is a matcher.

Complexity.
- Steps 1 and 2 are a single walk.
- Step 3 compares Tθ↓ with s without building Tθ↓. It traverses T and, on reaching M(t̄), jumps into β_M with the
  environment z_i ↦ (t_i, current environment).
- Every rigid symbol consumed is a symbol of s.
- Between two consumptions there are at most |T| non-consuming jumps: body → hole → argument, each into a strictly smaller
  argument of T.
- Hence O(|T|·|s|). For T ∈ DT° the arguments are ground and the bound is O(|s|·max|t_i|). ∎

*Proof of (b).*
- In SO° every occurrence contains exactly one metavariable, and its arguments are ground terms.
- So s ∈ inst(T) iff the rigid part agrees and, for each metavariable M with occurrences M(t̄_1) at p_1, …, M(t̄_k) at p_k,
  there is a closed body β with β[t̄_j/z̄] = s|p_j for all j. Distinct metavariables do not interact.
- Let E(c̄) mean that a body solving the column c̄ = (s|p_1, …, s|p_k) exists. It satisfies

      E(c̄) ⟺ (∃m ∀j: c_j = t_{j,m}↑) ∨ (all c_j have the same head h, h is a constant or a variable bound inside β, and E
      holds for every argument column).

  Here ↑ shifts the argument under the binders of β that have been passed.
- The equivalence holds because a body is either a hole z_m or has a head symbol and independent argument bodies; the
  argument subproblems share no unknowns. This is the projection/imitation analysis of Huet–Lang, restricted to ground
  arguments.
- The recursion visits each common position of the c_j once, so the time is polynomial.
- The number of solutions satisfies N(c̄) = #{m : projection works} + [imitation works]·Π N(argument columns). For P(0)
  against a sentence with k occurrences of 0, every 0 can be abstracted or not, which gives 2^k. ∎

**Evidence.** `c1_matching.py` → `c1_matching.out`.
- All 27 pool instances (`so_pool.py`) match T_ind with exactly one solution, and P is recovered as the motive.
- s*, Track B's I*_1 and Track B's L_inf instance are all rejected. All three are false.
- P(0) alone gives 4, 16, …, 4096 matchers for 2, 4, …, 12 zeros (= 2^k).
- (P(0) & B) -> C against Ind(0+x=x) gives 8 matchers for P.
- T_S (non-determinate) matches Ind(Sx=S0) and Ind(~Sx=0) uniquely, and rejects Ind(x=x) and Ind(Sx=x).
- Timing is linear: instances of size 108 / 918 / 9 018 / 90 018 / 900 018 take 0.0001 / 0.0005 / 0.0047 / 0.057 / 0.51 s.

**Known context.**
- Second-order matching is decidable and has a finite complete set of matchers (Huet & Lang 1978, Acta Informatica 11).
- Second-order *unification* is undecidable (Goldfarb 1981).
- Second-order matching is NP-complete; I believe this is due to Baxter's 1977 thesis, but I am unsure of the attribution.
- Higher-order matching is decidable (Stirling 2009, LMCS).
- Miller (1991) patterns have decidable, unitary unification.

Part (a) is the trivial matching case of Miller's result, applied to one occurrence per metavariable, followed by
evaluation of the rest.

### C2. Rigid-prefix lemma; complete data-directed enumeration. (proved; computed)

**Statement.**
(a) If D ⊆ inst(T), then at every rigid position of T that carries a non-metavariable symbol, every d ∈ D carries the same
symbol. So the rigid skeleton of T is a prefix of C(D), and the maximal metavariable occurrences of T sit at cut points of
that prefix.

(b) Fix bounds on arity and argument size. The covering templates in SO° of size ≤ s are exactly what the following
enumeration produces:
- choose a prefix of C(D);
- place fillers M(t̄) at its cut points;
- choose the sharing of metavariables, with coverage pruning.

This is `so_enum.enumerate_covering`.

*Proof.* (a) is the preservation lemma applied to each datum. (b) In SO° all occurrences are rigid, so a template is its
rigid skeleton plus fillers at the cut points. By (a) the skeleton is a prefix of C(D). The enumerator ranges over all
prefixes, all fillers within the bounds and all sharings, and discards non-covering partial assignments. Discarding is
sound because adding occurrences only adds constraints. ∎

**Evidence.** `c0_crossval.py 10` → `c0_crossval.out`.
- A data-independent brute force over all SO° templates of size ≤ 10 (arguments of size ≤ 2, arity ≤ 2, quantifier depth
  ≤ 2) is compared with the data-directed enumerator on seven data sets.
- The data sets: the anchor pair; a same-root pair; an x-under-S pair; a vacuous pair; a quantified pair; a singleton; and
  the C8 example.
- The two sets of covering templates are identical on all seven, at size ≤ 9 (449 599 brute-force templates) and at size
  ≤ 10 (2 706 069 brute-force templates).
- The size-10 covering counts are 341, 451, 409, 847, 341, 548 and 348.

### C3. Anchor theorem for determinate templates. (proved; computed)

**Theorem.** Let D ⊆ Ind be finite. D is an anchor for Ind in DT iff (R) and (N) hold. Equivalently: every determinate
template, of any size, that covers D contains every induction instance iff (R) and (N) hold.

The same holds in DT_s for every s ≥ 7. Consequences:
- one instance is never an anchor in DT_s for s ≥ 7;
- two instances are an anchor iff their motives have different main symbols and at least one has x free.

**Lemma A (substitution).** Let phi be a motive and u, v terms with FV ⊆ {x}.
- (i) root(phi[u/x]) = root(phi) and ℓ(phi[u/x]) = ℓ(phi). This holds for any formula with FV ⊆ {x}, e.g. the W-content.
- (ii) If x ∈ FV(phi) and phi[u/x] = phi[v/x], then u = v.
- (iii) For any term t: St ≠ x, St ≠ 0 and St ≠ t.

*Proof.* (i) Substitution replaces term leaves by terms. It is capture-free here because u contains only x, and free
occurrences of x are not under a binder of x. (ii) By induction on phi. If phi = f(phi_1, …) and some argument has x free,
then phi[u/x] = phi[v/x] forces phi_i[u/x] = phi_i[v/x] for that argument; apply induction. The base case is phi_i = x,
i.e. a term leaf, which gives u = v. (iii) Compare roots and sizes. ∎

*Proof of "if".* Fix a motive phi° ∈ D with x free (by (N)), and let T ∈ DT cover D.

Step 1 (skeleton).
- By (R) there are motives with different roots. By Lemma A(i) the four motive slots a, b, c, d then have different roots
  in different data.
- So C(D) ∩ (motive slots) = ∅, and by C2(a) the rigid skeleton of T is a prefix of the five-node frame. The maximal
  occurrences of T sit at some of the slots R, U, V, s, a, W, b, c, d, at most one per slot.

Step 2 (types).
- Every metavariable needs a rigid pattern occurrence, and all slots have formula type, so every metavariable is
  formula-valued.
- A term cannot contain a formula-valued metavariable, so all arguments are metavariable-free terms. They are closed at
  R, U, V, s, a, and terms over x at W, b, c, d.
- A pattern occurrence with n ≥ 1 needs n distinct bound variables in scope, and only x is in scope at W, b, c, d. So every
  metavariable is either 0-ary, or unary with a pattern occurrence M(x) at W, b, c or d.

Step 3 (forced arguments, from phi° alone). Let κ(σ) be the content of slot σ in Ind(phi°), and θ° the unique matcher (C1).
- *0-ary A at slot σ.* κ(σ) must be closed. That excludes W, b, c, d, whose contents contain x free. If A occurred at
  σ ≠ σ' among R, U, V, s, a, then κ(σ) = κ(σ'). But these slots have pairwise different ℓ (§1), so each 0-ary metavariable
  occurs exactly once.
- *Unary M with a pattern occurrence at π.* Then θ°(M) = λx.κ(π), and every occurrence M(t) at a slot σ needs
  κ(π)[t/x] = κ(σ). By Lemma A(i), σ lies in π's ℓ-class: either π = σ = W, or π, σ ∈ {a, b, c, d}.
  - *If M has a pattern occurrence at b or d*, take π there, so κ(π) = phi°. By Lemma A(ii):
    - σ ∈ {b, d} forces t = x;
    - σ = c forces t = Sx, from phi°[t/x] = phi°[Sx/x];
    - σ = a forces t = 0.
  - *Otherwise* M's pattern occurrences are at c or W.
    - If at W, M occurs only there, as M(x).
    - If at c, then κ(c) = phi°[Sx/x] and κ(c)[t/x] = phi°[St/x]. At σ ∈ {b, d} this would need St = x, and at σ = a it
      would need St = 0. Both are impossible by Lemma A(iii). So M occurs only at c, as M(x).

Step 4 (T ≥ T_ind). Define σ on the metavariables of T:
- a 0-ary metavariable at slot ρ ↦ T_ind|ρ, the closed subformula of T_ind at ρ, e.g. P(0) at a and Ax P(x) at V;
- M with a pattern occurrence at b or d ↦ λy.P(y);
- M with pattern occurrences only at c ↦ λy.P(Sy);
- M_W ↦ λy.(P(y) → P(Sy)).

By Step 3, every filler of T becomes T_ind's subformula at that slot:
- M(0) ↦ P(0);
- M(x) at b or d ↦ P(x);
- M(Sx) or M_c(x) at c ↦ P(Sx);
- and so on for the other slots.

T's rigid prefix agrees with T_ind. So Tσ↓ = T_ind, hence T ≥ T_ind and inst(T) ⊇ inst(T_ind) = Ind. The last equality
holds because the closed λ-terms of type ι→o are exactly λx.phi for motives phi. ∎

*Proof of "only if", with explicit witnesses of size ≤ 7.*
- **(N) fails** (all motives closed). T_vac := B → Ax A, with A and B 0-ary, has size 4 and lies in DT. It covers Ind(phi)
  for closed phi, via A := phi and B := antecedent. It misses Ind(x=x), whose conclusion Ax(x=x) is not of the form Ax A
  with A closed.
- **(R) fails** (all roots equal to f). Use (Φ_f & B) → C, with Φ_f a filler of the a-slot:

  | root f | Φ_f | size of (Φ_f & B) → C |
  |---|---|---|
  | = | z_1 = z_2 (0-ary term metavariables at rigid positions) | 7 |
  | ¬ | ¬A | 6 |
  | ∧, ∨, → | A_1 ∘ A_2 | 7 |
  | ∀ or ∃ | Qy K(y), with K(y) a pattern occurrence at depth 1 | 7 |

  - Each covers every Ind(phi) with root(phi) = f, since phi[0/x] has root f.
  - Each misses an instance with a different root: Ind(~x=0) for f = '=', and Ind(x=x) otherwise.
  - Each is determinate.

So for every s ≥ 7, failure of (R) or (N) is witnessed inside DT_s. Combined with DT_s ⊆ DT and the "if" part, the
characterization holds in DT_s. ∎

**Remarks.**
- The proof uses only one non-vacuous datum, for the forced arguments, and one root-diverse pair, for the skeleton.
- The ℓ-argument replaces size bookkeeping and works for any motives, including quantified ones and motives that rebind x.
- Template size plays no role. The theorem covers templates with nested metavariable arguments, because under (R) no
  term-valued metavariable can be determinate.

**Evidence.** `c3_anchors.py 14` → `c3_anchors.out` (226 s, 4 cores).
- Setup: all 27 singletons and all 351 pairs of pool motives. For each, the script enumerates every SO° template of size
  ≤ 14 covering the data (arguments of size ≤ 3, arity ≤ 2; 4 645 193 covering templates in total). Each template is
  classified as ≥ T_ind (good), or as missing a held-out genuine instance from the 27 (bad).
- No template was undetermined.
- **DT-anchor ⟺ (R)∧(N) on 351/351 pairs.** No singleton is an anchor. The smallest determinate counterexamples to
  singleton anchors have size 4–7, e.g. B → Ax(x=x) for {Ind(x=x)}, and (~A & B) → C for {Ind(~x=0)}.
- Breakdown of (R, N, B; DT-anchor, SO°-anchor), with pair counts:

  | R | N | B | DT-anchor | SO°-anchor | pairs |
  |---|---|---|---|---|---|
  | F | F | F | no | no | 1 |
  | F | T | F | no | no | 13 |
  | F | T | T | no | no | 76 |
  | T | F | F | no | no | 9 |
  | T | T | F | yes | no | 32 |
  | T | T | T | yes | yes | 220 |

- `c2_generalizations.out` adds the following for the anchor pair {Ind(x=x), Ind(~x=0)}:
  - all 26 determinate covering templates are ≥ T_ind;
  - all 7777 non-determinate SO° covering templates of size ≤ 14 are also ≥ T_ind, as C7 predicts, since (B) holds.

### C4. The generalizations of T_ind; T_ind is the lgg of every anchor. (proved; computed)

**Statement.**
(a) Up to renaming, the templates T ∈ DT with Ind ⊆ inst(T) are exactly the 26 *frame generalizations* listed below. Each
one is obtained as follows:
- choose a prefix of the five-node frame (9 choices);
- put fresh 0-ary metavariables at the cut slots R, U, V, s and a fresh M_W(x) at W;
- partition the present motive slots among a, b, c, d into metavariables, where a class may contain a or c only together
  with b or d, or else be a singleton;
- give the arguments b, d ↦ x, c ↦ Sx (or x if c is alone), a ↦ 0. A lone a gets a fresh 0-ary metavariable.

(b) For every anchor D, i.e. one with (R) and (N), the covering templates in DT are exactly these 26. T_ind is the least of
them, so lgg_DT(D) = T_ind.

*Proof.* (a) "⊇": each frame generalization is ≥ T_ind by the substitution of C3 Step 4. "⊆": Ind contains anchors, and C3
Steps 1–3 show that every determinate template covering an anchor has exactly this form. (b) Covering D is equivalent to
being one of the 26, by C3 and (a). T_ind is one of them, and every other is ≥ T_ind. ∎

**The list** (sizes 1–14), from `c2_generalizations.out`:

    1  P0                                         10  (P0(0) & Ax.P1(x)) -> Ax.P0(x)
    3  P0 -> P1                                   11  (P0 & Ax.(P1(x) -> P1(Sx))) -> P2
    5  (P0 & P1) -> P2                            11  (P0(0) & Ax.(P0(x) -> P1(x))) -> P2
    5  P0 -> Ax.P1(x)                             12  (P0 & Ax.(P1(x) -> P2(x))) -> Ax.P1(x)          [= pattern lgg, C9]
    7  (P0 & Ax.P1(x)) -> P2                      12  (P0 & Ax.(P1(x) -> P2(x))) -> Ax.P3(x)
    7  (P0 & P1) -> Ax.P2(x)                      12  (P0(0) & Ax.(P0(x) -> P0(Sx))) -> P1
    8  (P0(0) & P1) -> Ax.P0(x)                   13  (six templates)
    9  (P0 & Ax.P1(x)) -> Ax.P2(x)                14  T_ind and four variants
   10  (P0 & Ax.(P1(x) -> P2(x))) -> P3

**Evidence.** `c2_generalizations.py`: the predicted 26 templates are identical, as a set, to the enumerated determinate
covering templates of {Ind(x=x), Ind(~x=0)} at size ≤ 14. All 26 are ≥ T_ind by the subsumption check.

### C5. Same anchors as the Sub-encoded first-order learner; rates. (proved; computed)

**Statement.**
(a) For D ⊆ Ind, the following are equivalent:
- D is an anchor in DT;
- the first-order lgg of the Sub-encoded data recovers σ_Sub = st(Sub(P,x,0,A), Sub(P,x,Sx,B), A & Ax(P->B) -> Ax P), with
  x a constant (`ind_sub_lgg.py`);
- (R) and (N) hold.

(b) Let the motives be i.i.d. from μ, with p_f = μ(root = f), q = μ(x ∈ FV) and r_f = μ(root = f, x ∉ FV). Then

    P[D_N is not an anchor] = Σ_f p_f^N + (1−q)^N − Σ_f r_f^N  ≤  p_max^(N−1) + (1−q)^N,

and it is at least max(p_max^N, (1−q)^N). By thm:imitation:anchor, the DT cautious verifier is sound at every N and exact
from the first anchor on.

*Proof.* (a) Apply lem:setting:recover to σ_Sub, whose metavariables P, A, B receive phi, phi[0/x], phi[Sx/x].
- (R) for each of P, A, B says "roots not all equal". By Lemma A(i) this is the same condition for all three, namely (R).
- (D) for each pair says "differ in some instance":
  - phi ≠ phi[0/x] iff x ∈ FV(phi);
  - phi ≠ phi[Sx/x] iff x ∈ FV(phi);
  - phi[0/x] ≠ phi[Sx/x] iff x ∈ FV(phi), by Lemma A(ii) since 0 ≠ Sx.

  So all three (D) events are (N). Combine with C3.

(b) "Not an anchor" is the union of A = "all roots equal" and B = "all closed". A is the disjoint union over f of A_f =
"all roots f", and A ∩ B is the disjoint union of "all roots f and all closed". Inclusion–exclusion gives the identity. The
bound uses Σ_f p_f^N ≤ p_max^(N−1). The lower bound holds because each of A and B alone is a failure. ∎

**Evidence.** `c5_sub_equiv.py` → `c5_sub_equiv.out`, using the paper's T1-code lgg.
- All 351 pairs agree: Sub-lgg recovery ⟺ (R)∧(N), with 252 recovering.
- All 2925 triples agree, with 2674 recovering.
- Together with C3's 351/351, the three conditions coincide on all pool pairs.

*Reading.* Sub premises spell out the two non-pattern occurrences P(0) and P(Sx) as first-order data. A second-order learner
that only sees raw sentences recovers them by matching, and loses no data efficiency. The witness events are literally the
same.

### C6. When is the cautious verifier sound without realizability? The size threshold 12. (proved; one step computed)

**Lemma C6.1** (general, any H ⊆ 2^S, any target h*). Let cl_H(h*) := ∩{h ∈ H : h ⊇ h*}.
- (a) If cl_H(h*) = h* ("h* is H-closed"), then Acc_H(D) ⊆ h* for every D ⊆ h*. Realizability, h* ∈ H, is a special case.
- (b) If D ⊆ h* contains an anchor for h* in H, then Acc_H(D) = cl_H(h*).

  So, once data contain an anchor, the verifier is sound iff h* is H-closed, and then it is exact.

*Proof.* (a) For D ⊆ h*, VS(D) ⊇ {h ∈ H : h ⊇ h*}, so ∩VS(D) ⊆ cl_H(h*) = h*. (b) An anchor gives
VS(D) = {h ∈ H : h ⊇ h*}. ∎

This sharpens lem:imitation:cautious(a), which assumes h* ∈ H. In paper terms, the proof of (a) is
prop:caution:closure's closure argument, without intersection-closedness.

**Proposition C6.2** (bounded template size).
(a) For s ≥ 7, D ⊆ Ind is an anchor in DT_s iff (R) and (N) hold (this is C3).

(b) cl_{DT_s}(Ind) = Ind iff s ≥ 12. Note that T_ind ∈ DT_s only for s ≥ 14.

(c) Consequently:
- For s ≥ 12, the cautious verifier over DT_s is sound for every D ⊆ Ind, and exact once (R)∧(N) hold.
- For 7 ≤ s ≤ 11 it reaches cl_{DT_s}(Ind) ⊋ Ind on anchors, so it accepts the false sentences

      s*  = (0=0 & Ax(x=x -> Sx=Sx)) -> Ax(x=0)
      s0* = (0=0 & Ax(0=0 -> 0=0)) -> Ax(x=0)

  These are not induction instances, and the verifier is unsound however much data it gets.

*Proof.* (a) is C3.

(b) "If": the three frame generalizations

    T8  = (P(0) & B) -> Ax P(x)                     |T8|  = 8    (a = d[0/x])
    T11 = (A & Ax(P(x) -> P(Sx))) -> C              |T11| = 11   (c = b[Sx/x])
    T12 = (A & Ax(P(x) -> Q(x))) -> Ax P(x)         |T12| = 12   (b = d)

contain Ind (C4), and their intersection is Ind:
- a sentence in inst(T12) has the form α & Ax(beta -> gamma) -> Ax beta, with beta a motive;
- T11 adds gamma = beta[Sx/x];
- T8 adds α = beta[0/x];
- so the sentence is Ind(beta).

"Only if" (s ≤ 11). By C4, the members of DT_s that contain Ind are the frame generalizations of size ≤ s.
- Sharing a metavariable between d and b needs W and V rigid (5 rigid nodes) plus fillers a ≥ 1, b = 2, c ≥ 2, d = 2. That
  is ≥ 12.
- Sharing between d and c needs c = M(Sx) as well. That is ≥ 13.
- So templates of size ≤ 11 impose at most the equations a = d[0/x], a = b[0/x] and c = b[Sx/x], plus a frame prefix.
- s* has the full frame and satisfies all three: α = (0=0) = δ[0/x] = β[0/x], and γ = (Sx=Sx) = β[Sx/x]. The same holds for
  s0*.
- So both lie in every such template. Neither is an induction instance, since β ≠ δ, and both are false: the premise holds
  and Ax(x=0) fails at x = 1.

(c) follows from (a), (b) and Lemma C6.1. ∎

**Evidence.** `c2_generalizations.out`.
- 2406 candidate non-induction frame sentences were built from the pool.
- Number surviving in all DT_s members that contain Ind, by s:

  | s | survivors | of which false |
  |---|---|---|
  | ≤ 7 | 2406 | 427 |
  | 8–10 | 924 | 137 |
  | 11 | 36 | 10 |
  | ≥ 12 | 0 | 0 |

- s* survives exactly for s ≤ 11.
- Of the 1329 non-determinate SO° templates of size ≤ 11 (args ≤ 3, arity ≤ 2) that cover all held-out instances, every
  one contains s*. So the threshold is not an artifact of determinacy (computed, within those bounds).

*Reading.* The bounded learner's soundness depends on the class being rich enough for the target to be an intersection of
its members. It need not contain the target. Here that richness threshold, 12, sits two symbols below the target, 14.

### C7. Determinacy matters: anchors in SO° are (R) and (B). (proved; computed)

**Theorem.** In SO° (all occurrences rigid, metavariable-free arguments, any arities, no pattern occurrence required), a
finite D ⊆ Ind is an anchor iff (R) and (B) hold.

*Proof of "only if".*
- (R) fails: the root-specialized templates of C3 lie in DT° ⊆ SO°.
- (B) fails: let Θ be the set of *shielding terms*: the parent terms of all free x-occurrences in the motives of D. Each has
  FV ⊆ {x} and is ≠ x. Write Θ = {θ_1..θ_k} and T_Θ := B → Ax P(θ_1, …, θ_k), with P of arity k.
  - *T_Θ covers D.* For a motive phi with x free, replace each maximal occurrence of a shielding term by the corresponding
    hole. This yields a closed body β with β[Θ] = phi; for closed phi take β = phi. Then B := the antecedent.
  - *T_Θ misses Ind(x=x).* In any instance, every free x in the conclusion's body comes from a plugged θ_i ≠ x, so it lies
    inside a proper term. But x=x has bare x's.
  - In particular {Ind(Sx=S0), Ind(~Sx=0)} has (R) and (N) but not (B). It is covered by B → Ax P(Sx) (size 6) and by
    T_S = P(S0) & Ax(P(Sx) -> P(SSx)) -> Ax P(Sx). Both miss Ind(x=x). ∎

*Proof of "if".* Let phi° ∈ D have an unshielded occurrence of x at position q, and let T ∈ SO° cover D.
- By (R) and C2, the skeleton of T is a frame prefix. Every metavariable is formula-valued, since SO° occurrences are rigid
  and all slots have formula type.
- Let β°_M be a body for M solving all of M's occurrences for Ind(phi°); one exists because T covers Ind(phi°).
- For any argument tuple ū, ℓ(β°_M[ū]) = ℓ(β°_M), since holes are terms. So M occurs only within one ℓ-class: one of
  {a, b, c, d}, {W}, or a single depth-0 slot.

Key fact: if M occurs at b or d with arguments t̄, then β°_M has a hole z_m exactly at q, and t_m = x.
- The x at q in phi° must come from a plugged argument t_m at some position p ≤ q, because β°_M is closed.
- If p ≠ q, then phi°|p would be a proper term containing that occurrence with FV ⊆ {x}. That contradicts unshieldedness.
- The same argument applies at W, at position 1·q.

At c, position q holds Sx. So β°_M|q is either z_m with t_m = Sx, or S(z_m) with t_m = x.
- The hole cannot sit higher. If q's parent is "=", the parent position is a formula, and holes are terms. If the parent is
  a function symbol, its subterm contains a variable bound inside phi°, and arguments contain no such variable.

At a, position q holds 0: either z_m with t_m = 0, or the constant 0.

Now define σ:
- (i) M occurring at b or d, with hole z_m at q: M ↦ λz̄.P(z_m). Any other occurrence M(ū) at σ ∈ {a, b, c, d} has
  β°_M[ū]|q = u_m equal to κ(σ)|q ∈ {0, x, Sx}. That is exactly T_ind's argument at σ, so it becomes P(0), P(x) or P(Sx).
- (ii) M occurring at c but not at b or d.
  - With z_m at q: M ↦ λz̄.P(z_m). Its occurrences at a and c get u_m = 0 and Sx respectively.
  - With S(z_m) at q: M ↦ λz̄.P(S z_m). It cannot also occur at a, since S(u_m) = 0 is impossible, nor at b or d, since
    S(u_m) = x is impossible.
- (iii) M only at W, where 1·q holds z_m with t_m = x: M ↦ λz̄.(P(z_m) → P(S z_m)).
- (iv) M only at a: M ↦ λz̄.P(0).
- (v) M only at one depth-0 slot ρ: M ↦ λz̄.T_ind|ρ.

Then Tσ↓ = T_ind, so T ⊇ Ind. ∎

**Evidence.** `c3_anchors.out`.
- **SO°-anchor ⟺ (R)∧(B) on 351/351 pairs.**
- All 32 pairs with (R)∧(N) but not (B) are non-anchors in SO°. Their smallest bad templates are:
  - B → Ax P(Sx), size 6;
  - B → Ax P(x+0), size 7;
  - B → Ax P(x+0, Sx), size 9, the two-argument T_Θ, e.g. for {Ind(Sx=S0), Ind(~x+0=S0)}.

  Each misses Ind(x=x).
- `c1_matching.out` shows the T_S matches.

*Reading.* Without the pattern requirement, a template can encode "x occurs only inside Sx", and data that happen to have
this property cannot rule it out. Determinacy forbids this, because a metavariable's pattern occurrence must see the whole
motive. Requiring (B) is a weak condition on realistic data. Determinacy costs nothing, since T_ind ∈ DT, and buys the
weaker anchor condition (N) and unique matching.

### C8. DT is not unitary; the version space before an anchor. (proved; computed; conjecture)

**Proposition C8.1** (non-unitary).
Let s_1 = Ax(x=0) & (Ax(x=x) & 0=0) and s_2 = Ax(~x=0) & (Ax(~x=x) & ~0=0). Define

    G1 = Ax P(x) & (Ax Q(x) & P(0)),     G2 = Ax P(x) & (Ax Q(x) & Q(0)).

Then:
- every T ∈ DT covering {s_1, s_2} is ≥ G1 or ≥ G2;
- G1 and G2 are incomparable;
- no T ∈ DT has inst(T) = inst(G1) ∩ inst(G2) or covers D below both;
- hence D has no lgg in DT, and Acc_DT(D) = inst(G1) ∩ inst(G2) is not the instance set of any template.

*Proof.* This is the C3 slot analysis on the frame and(∀□_α, and(∀□_β, □_γ)), where roots differ between the data in all
three slots. All metavariables are formula-valued. Pattern occurrences are M(x) at α or β, 0-ary metavariables occur once
each, and depth-0 contents are pairwise distinct.
- From s_1:
  - M with pattern at α (λx.x=0) can also occur only at γ, with t = 0, because (t=0) = (0=0).
  - N with pattern at β (λx.x=x) can also occur only at γ, with t = 0, because (t=t) = (0=0).
  - α ≠ β[t/x], since (t=t) ≠ (x=0), and β ≠ α[t/x], since (t=0) ≠ (x=x).
- So γ holds a fresh 0-ary metavariable, M(0) or N(0), or is cut away above. In the first and last cases T ≥ G1 and T ≥ G2;
  with M(0), T ≥ G1; with N(0), T ≥ G2.
- Incomparability: w1 = Ax(x=0) & (Ax(x=S0) & 0=0) ∈ G1 \ G2 and w2 = Ax(x=S0) & (Ax(x=0) & 0=0) ∈ G2 \ G1.
- If T covered D with inst(T) ⊆ inst(G1) ∩ inst(G2), then T ≥ G1, say, so w1 ∈ inst(T) ⊆ inst(G2), a contradiction. ∎

**Evidence.** `c4_nonunitary.out`.
- 11 determinate covering templates; the minimal ones are exactly G1 and G2; all 11 are ≥ G1 or ≥ G2; w1 and w2 separate
  G1 from G2.
- In SO° the non-determinate template Ax P(0,x) & (Ax P(x,x) & P(0,0)) covers D and lies strictly below both G1 and G2. It
  is the unique minimal SO° covering template up to swapping P's arguments (mutual subsumption checked).
- So the wider class happens to have a least generalization here. Non-unitarity is a property of DT, the price of
  determinacy.

**Computed C8.2** (non-anchor induction data; `c6_nonanchor_min.out`). The search covers determinate templates up to the
stated size, with arguments of size ≤ 2. Counts are of minimal covering templates up to equivalence; "⊆ Ind?" says whether
some minimal template is a specialization of T_ind.

| D | size bound | minimal | ⊆ Ind? |
|---|---|---|---|
| {Ind(x=x), Ind(x+0=x)} | 23 | 1: T_ind[P := λx. f(x)=x] | yes |
| {Ind(x=x), Ind(0=x)} | 23 | 8 | one of the 8 |
| {Ind(x=0), Ind(Sx=0)} | 23 | 2: T_ind[P := λx. f(x)=0] and a variant | one of the 2 |
| {Ind(0=0), Ind(~0=S0)} (vacuous) | 16 | 1: (A & Ax(A->A)) -> Ax A | yes |
| {Ind(Ay.y+x=x+y), Ind(Ay.(x=y->y=x))} | 22 | 1: T_ind[P := λx. Ay Q(x,y)] | yes |
| {Ind(x=x)} | 19 | 1: the sentence itself | yes |

Notes on the two non-unique cases:
- For {Ind(x=0), Ind(Sx=0)}, the variant writes c as S(f(x))=0 instead of f(Sx)=0. The data have f ∈ {id, S}, which
  commute with S.
- For {Ind(x=x), Ind(0=x)}, several of the eight exploit the coincidence phi_1(0) = phi_2(0) = (0=0). Examples:
  (0=0 & Ax(f(x)=x -> f(Sx)=Sx)) -> Ax f(x)=x, and (f(0)=f(0) & Ax(f(x)=x -> P(Sx))) -> Ax P(x).

*Reading.*
- Before an anchor, the version space need not have a least element, even on induction data. Non-uniqueness comes from
  accidental equations that the data happen to satisfy.
- In every case, one minimal template is a specialization of T_ind, i.e. T_ind[P := motive-pattern]. So the intersection is
  ⊆ Ind, and the verifier is sound, as C6.1 guarantees.
- With unique minimal templates, the verifier accepts exactly the induction instances whose motives fit the common motive
  pattern. For example, after {Ind(x=x), Ind(x+0=x)} it accepts Ind(t(x)=x) for every term t, and nothing else (computed,
  within the bounds).

**Conjecture C8.3** (finitary). For every finite D, DT has finitely many minimal covering templates up to equivalence, and
every covering template is above one of them.

*Sketch.*
- Any covering T can be specialized until its skeleton is the maximal C(D): substitute each metavariable by its common
  structure in all data. Determinacy is preserved, because new pattern occurrences appear at the new slots.
- The fillers on the maximal skeleton come from a finite set: an own pattern with minimal arguments, a derived occurrence
  with forced arguments, or a fresh 0-ary metavariable.
- The step I have not checked is that specialization does not get stuck on term-type slots whose content is a bare variable
  in some datum.

### C9. Pattern anti-unification is unsound on raw induction data. (proved)

**Proposition.** Let PAT be the class of templates all of whose metavariable occurrences are pattern occurrences: Miller
patterns, the generalization language of Pfenning (LICS 1991) and Baumgartner–Kutsia–Levy–Villaret (JAR 2017). For D ⊆ Ind
with (R) and (N), the least general pattern generalization is

    T12 = A & Ax(P(x) -> Q(x)) -> Ax P(x).

Its false instance (0=0) & Ax(x=0 -> x=0) -> Ax(x=0) is not an induction instance.

*Proof.* PAT ⊆ DT, so by C4 the covering pattern templates are the frame generalizations with no non-pattern occurrence:
no P(0) at a and no P(Sx) at c. Among these, the full-prefix one with maximal sharing is T12.
- a gets a 0-ary metavariable.
- b and d share P(x).
- c gets its own Q(x): it cannot share with b or d as a pattern occurrence, because its content differs.

Every other pattern frame generalization is ≥ T12. The displayed instance has a true premise and a false conclusion. ∎

*Caveat.* I believe the BKLV algorithm computes exactly this lgg here: equal anti-unification problems at b and d are
merged, and a and c are generalized by fresh pattern variables. I have not run their implementation.

*Reading.* Patterns are the fragment where higher-order lggs are unique. Raw induction lies just outside it. DT keeps the
uniqueness of *matching* by requiring one pattern occurrence per metavariable. It allows the non-pattern occurrences P(0),
P(Sx) as derived equations, and gives up unitarity of generalization in general (C8). For anchors, unitarity holds anyway
(C4).

### C10. Noise. (proved)

Suppose D contains at most e mistakes (non-induction sentences), and the clean part is *e-robustly diverse*:
- for every symbol f, more than e clean motives have root ≠ f;
- more than e clean motives have x free.

Then the trimmed DT verifier, Acc_e(D) = ∩{inst(T) : T ∈ DT, |D \ inst(T)| ≤ e}, accepts exactly Ind.

*Proof.*
- Soundness: T_ind misses at most the e mistakes, so it is in the trimmed version space and Acc_e(D) ⊆ Ind.
- Completeness: any T in the trimmed version space covers all clean data except at most e.
  - The remaining clean data are nonempty and contain a motive with x free.
  - Whatever the root f of one remaining motive, some remaining motive has root ≠ f.
  - So (R)∧(N) hold for the remainder, and T ⊇ Ind by C3.

This is thm:imitation:trimmed(b) with the witness events of C5. With a single global budget the same proof works for the
induction tag alone. ∎

*Remark.* Untrimmed, one mistake usually destroys exactness without destroying soundness of the *class*. For example, a
datum with a wrong step clause makes T_ind inconsistent, and the version space then contains only generalizations such as
T12, which have false instances. This is the second-order analogue of prop:imitation:collapse.

### C11. Escalations. (conjecture)

Run the cautious DT verifier against an adversarial prover, escalating every step it does not yet accept. I conjecture
that the number of escalations before exactness is finite and at most linear in the size of the first escalated datum.
The idea is that each escalation should remove at least one rigid symbol, or one derived equation, from every minimal
template.

I have no proof. DT is not intersection-closed (C8.1), so Acc(D) is an intersection of several minimal templates. I do not
know that this intersection grows monotonically in any rank-like measure, and the single-schema bound thm:caution:single
does not apply directly. What is proved is the end point: once an anchor has been escalated (at most two well-chosen steps),
no further escalation occurs (C3).

### C12. Relation to the literature and to proof assistants. (known, with my reading)

- **Higher-order anti-unification.**
  - Pfenning (LICS 1991) and Baumgartner–Kutsia–Levy–Villaret (JAR 58, 2017, linear time) give unique lggs for higher-order
    patterns.
  - Cerna & Kutsia (FSCD 2019, "A generic framework for higher-order generalizations", I believe) study generalization
    classes beyond patterns, some unitary and some not.
  - Hirata, Ogawa & Harao (ILP 2004) study second-order generalization.
  - Feng & Muggleton (1992) study higher-order generalization for ILP. I am unsure of the exact formalism.
  - The induction template sits exactly at the boundary. Its conclusion is a pattern occurrence, and its other occurrences
    are not. C9 shows the pattern lgg is the wrong hypothesis; C8 shows the natural determinate extension is not unitary.
- **Higher-order matching.** Huet & Lang (1978) for second order; Stirling (2009) for all orders; Miller (1991) for
  patterns. Libal & Miller's "functions-as-constructors" fragment (FSCD 2016, I believe) allows arguments like S(x). I have
  not checked whether P(0), whose argument contains no bound variable, falls inside it.
- **Schematic axiomatizability.** Vaught (1967) axiomatizes theories "by a schema" with a schematic relation symbol; the
  induction schema is the paradigm. DT is a learnable version of this notion with a uniqueness condition.
- **ILP metarules.** Metagol's metarules (Muggleton, Lin, Tamaddoni-Nezhad 2015; Cropper & Tourret 2020) are second-order
  templates in which predicate variables are applied to first-order variables, i.e. pattern-like. Learning metarules from
  instances is close to the present problem, though their setting is Horn clauses.
- **Proof assistants.**
  - In CIC-based systems (Coq/Rocq, Lean) an induction step is an application of a recursor, e.g. `Nat.rec`, whose first
    explicit argument is the **motive** λx.phi. The proof term thus records the second-order matcher.
  - The tactics compute it the way C1 does: they abstract the occurrences of the induction variable in the goal, i.e.
    match the conclusion's pattern occurrence. Lean 4's `induction` tactic and `elab_as_elim` do this, I believe via
    kabstract. Coq's "motive is not well-typed" errors arise when this abstraction fails.
  - Isabelle applies `nat.induct` by higher-order unification of ?P ?n with the goal. That is a non-pattern problem with
    several unifiers, which the `induct` method avoids by instantiating ?n explicitly.
  - Metamath's set.mm states induction with implicit-substitution hypotheses (x = y → (phi ↔ psi)), the analogue of the
    Sub premises.
  - In all cases the motive is recorded or recomputed. C1 says recomputing it is unique and linear for DT. C5 says that
    recording it, as in the Sub encoding, changes nothing about anchors or rates.

---------------------------------------------------------------------------------------------------------------------------

## 4. Scripts and outputs (this directory)

| script | claims | output |
|---|---|---|
| `so_core.py` | representation (de Bruijn), instantiation, Ind, T_ind, determinate/SO° matching, matcher counts, subsumption by freezing, exact truth (via Track B's `raw_common.truth`) | (library) |
| `so_enum.py` | data-directed enumeration of covering SO° templates (C2); brute-force enumeration | (library) |
| `so_pool.py` | 27 test motives; predicates (R), (N), (B) | (library) |
| `c0_crossval.py 10` | C2: brute force = data-directed on 7 data sets | `c0_crossval.out` |
| `c1_matching.py` | C1 | `c1_matching.out` |
| `c2_generalizations.py` | C4 (26 generalizations = prediction), C6.2 threshold, s*, C3/C7 for the anchor pair | `c2_generalizations.out` |
| `c3_anchors.py 14` | C3, C7: all singletons and 351 pairs | `c3_anchors.out` |
| `c4_nonunitary.py` | C8.1 | `c4_nonunitary.out` |
| `c5_sub_equiv.py` | C5(a) | `c5_sub_equiv.out` |
| `c6_nonanchor_min.py` | C8.2 | `c6_nonanchor_min.out` |

Re-run: `cd` to this directory, then `python3 <script>`. Running times:
- c3: about 4 minutes on 4 cores;
- c2: 30 s;
- c0 at size 10: a few minutes;
- c6: several minutes;
- the others: seconds.

## 5. Caveats

- **Scope of the computations.** The enumerations cover the fragment 0, S, +, =, ¬, ∧, →, ∀, with argument terms of size
  ≤ 3 (≤ 2 in c0 and c6), arity ≤ 2 and template size ≤ 14 (≤ 10 in c0). The theorems (C3, C4, C6, C7, C8.1, C9) are proved
  for the full language and all sizes. The computations corroborate them; they do not prove them. The exception is the
  "only if" of C6.2(b), where the hand proof is complete and the computation is a check.
- **Parameters.** Ind is parameter-free here. With parameters, Ind_p(phi) = Ap̄ Ind(phi(x,p̄)), the frame gains binders and
  the pattern occurrence becomes P(x, p̄). I expect C3 to go through with (R), (N) unchanged, but have not checked it.
- **Semantics.** Instances are sentences, and θ assigns closed λ-terms. This is the λ-calculus convention, in which a 0-ary
  metavariable under ∀x cannot capture x; dependence must be explicit, as in B(x). Track B's first-order schemas allow
  capture, which is one reason their lggs are unsound.
- **"Size".** Thresholds (7, 12, 14) refer to the size measure of §1. Under another measure the numbers change but not the
  phenomenon: the threshold is the size of the cheapest template expressing the b = d link.
- **Untagged unions.** With ground axioms G plus induction, untagged, in unions of ≤ k templates, I expect the earlier
  session's result to transfer. The failure sets "all motive roots equal f" and "all motives closed" are the DT failure
  events of C5. This is not re-proved for DT unions: a union might cover Ind by other routes, e.g. one root-specialized
  template per root (7 roots).
- **Citations I am less sure of:**
  - Baxter 1977 (NP-completeness of second-order matching);
  - the exact statements of Cerna–Kutsia 2019, Hirata–Ogawa–Harao 2004, Feng–Muggleton 1992 and Libal–Miller 2016;
  - whether BKLV's implementation outputs T12 verbatim;
  - Lean's `elab_as_elim` and `kabstract` details.
