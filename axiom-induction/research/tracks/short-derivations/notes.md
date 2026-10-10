# Track "short-derivations": derivations from short axioms

*Follow-up to paper Section 6 (`../../../paper/sections/time.tex`, `app-time.tex`), to model track §6, §9.3, §10 (`../model/notes-final.md`), and to the draft `../time-followup/notes.md` (unrefereed, being refereed in parallel). It answers Kaarel Hänni's proposal, verbatim:*

> "hmm interesting point. but perhaps we can make AI actually interestingly time-limited by requiring that given statements have derivations from short axioms?"

*Scripts are in `checks/`; each is seeded and writes `<name>.out` next to itself. `checks/kcore.py` is the shared implementation of the calculus K used by c1, c3, c4 and c5.*

**Status tags** (as in the model and time-followup tracks).
* **[proved]**: full proof here. "Proved, given X": the proof uses the cited result X.
* **[proof sketch]**: the argument is given; the steps not written out are named.
* **[known]**: published, with reference; **(not checked)** means recalled, not checked against the source in this session.
* **[computed]**: checked by a script in `checks/`; the output file is named.
* **[conjecture]**, **[open]**, **[refuted]**.

**Labels.** Paper labels as in the paper (`def:time:inducers`, `thm:time:equiv`, `prop:time:cheap`, `prop:time:twosorted`, `prop:time:single`, `prop:time:collapse`, `prop:time:notemplate`, `thm:time:ntime`, `cor:time:hard`, `prop:time:sigma`, `rem:time:upper`, `prop:time:fiall`, `rem:model:graded`, `def:model:variants`, `def:model:calculus`). "time-followup Thm 4.2" etc. refer to `../time-followup/notes.md`; "model §10" to `../model/notes-final.md`.

---

## 0. The answer

### 0.1 One paragraph (S5)

Hänni's proposal time-limits axiom induction under one reading and not under another. Read as "every axiom instance used is short" (each at most h(|φ|) symbols, the logical axioms of K included, with axiom membership decidable in polynomial time), it does limit time, but only to deterministic exponential time. In a K-derivation without redundant lines, every line is, up to abstracting parameters, a subformula of an axiom instance used or of φ (Lemma 2.2). So up to renaming parameters only 2^{O(h log h)} formulas can occur, and derivability within the budget is a closure computation of that length (Theorem 4.2). Conversely, ground axioms of size O(h) simulate any alternating machine in space O(h) (Proposition 4.3). At polynomial budgets this axiom induction has bounded loss on exactly the EXPTIME language sequences: unconditionally more than polynomial-time function induction. For every predictor that runs in time polynomial in the number of data (and, given Hänni's description of its running time, for his S) there is a length-lexicographic language sequence on which that predictor loses n − O(1) bits while this axiom induction loses O(1) (Proposition 4.5). The computation does move into the number of proof steps, as suspected, but that number is at most exponential. If only the theory's own axioms must be short and the logical axioms are free, nothing is time-limited. Hänni's schema in two sorts, and in one sort a trace schema with a fresh relation symbol, keep axiom induction equivalent to unpenalised consistent function induction (Propositions 4.7, 4.8), although Craig's padding and the bounded schema A^bd_f are blocked (Proposition 4.6). Read instead as "the distinct axiom instances used, logical ones included, are short in total", the proposal is a bound on derivation size up to squaring (Corollary 2.3). Axiom induction then becomes certificate function induction: consistent assigners whose decisions are checked in polynomial time against certificates of polynomial length (time-followup Thm 4.2; Theorem 3.1 here). The free resource is proof search, that is, guessing a certificate, so axiom induction becomes a nondeterministic time-bounded function inductor. That is the interesting time limit. Against deterministic time-bounded function induction it is stronger unconditionally when the derivation budget exceeds the clock by a hierarchy gap. At polynomial budgets it is stronger if NP ∩ coNP ≠ P and not stronger if P = NP; the intermediate case is open (time-followup Cor 4.3). A soft charge of 2^{−κ} per bit of each datum's shortest derivation gives the same picture up to a constant factor in the rate. Soft axiom induction is dominated, with constant regret, by soft certificate function induction that charges κ per bit of statement and certificate, and it dominates the version that charges rκ, r a coding constant. Whether r can be 1 is open, and the statement term, Θ(κ|φ|) per datum, cannot be dropped (Theorem 5.2, Proposition 5.3). Restricting to finite template theories loses nothing on literal data. Horn templates simulate any certificate verifier with derivations quadratic in its running time, so `cor:time:hard` is tight up to polynomials there (Proposition 6.1, Corollary 6.2). For data that are not literals this is open.

### 0.2 Verdicts on the orchestrator's hypotheses

| hypothesis | verdict | where |
|---|---|---|
| **S1(a)** short instances block Craig padding | **confirmed** under every reading (on literal data; in general for data not implied by quickly decided ones) | Prop 4.6(i) |
| **S1(a)** … but not Hänni's two-sorted schema, A^bd_f, or the reflection sentence ρ_{f,n} | **split by reading.** (a2) (only the theory's instances bounded): Hänni's two-sorted schema not blocked [proved]; ρ_{f,n} not blocked [proof sketch]. (a1) (logical instances bounded too): all three blocked beyond deterministic time 2^{O(h log h)} [proved]. **A^bd_f is blocked under every reading** [proved, given time-followup Prop 2.5(c)]; **refuted** for it. A different one-sorted schema, with a fresh relation symbol, is not blocked under (a2) [proved] | Props 4.6–4.8, Rem 4.10, Thm 4.2 |
| **S1(a)** the computation moves into the number of proof steps | **confirmed, and bounded**: at most 2^{O(h log h)} distinct lines up to renaming; attained up to the log factor | Lemma 2.2, Thm 4.2, Prop 4.3 |
| **S1(a)** so AI with short axioms and unbounded derivations is still equivalent to unpenalised FIcons | **refuted for (a1)** with time-bounded membership: at polynomial budgets the fit class is EXPTIME. **Confirmed for (a2)** in two sorts, and in one sort with B ⊇ Q and a relation symbol unused by B and the data. Without a membership-time bound no reading imposes a time limit | Cor 4.4, Props 4.7, 4.8, Rem 4.11 |
| **S1(b)** total material of the distinct instances, logical included, is a derivation-size bound | **confirmed**: M_min ≤ ℓ_min ≤ (M_min + \|φ\|)², so time-followup Thm 4.2 applies. **Refuted** if the logical instances are free | Cor 2.3, Thm 3.1, Prop 2.6 |
| **S2** every line other than the conclusion and its Gen chain is a subformula of an instance used; size ≤ (M + \|φ\|)² | **confirmed, with corrections.** Axiom and MP lines are literal subformulas of instances used, with no hypothesis on the derivation. Every Gen line, not only those on the conclusion's Gen chain, is a subformula of an instance or of φ only up to abstracting parameters; this needs a normal derivation. Exact bounds: #lines ≤ Σ N(α), size ≤ Σ F(α) ≤ (M + \|φ\|)², over α ∈ I ∪ {φ}; tight for normal derivations. Repeated lines matter only for the line count. Fails without counted logical axioms, and has no analogue in natural deduction or in sequent calculus with cut | Lemmas 2.1, 2.2, Cor 2.3, Prop 2.4, Rem 2.5, Prop 2.6, Rem 2.7 |
| **S3** soft version | **constant-regret sandwich up to a constant factor in the rate** (bit cost): FIcert^σ_{κ,κ} has loss ≤ AI^σ_κ's + O(1), and AI^σ_κ has loss ≤ FIcert^σ_{rκ,rκ}'s + O(1). Per datum, against certificate-only charging, the overhead lies between κ\|φ^b\|_bit and κ(2\|φ\|_bit + e_1), with certificate rate 2b_sκ. With symbol cost there is a log factor in one direction. **Open**: r = 1; normalised and generative versions | Thm 5.2, Prop 5.3, Cor 5.4, Rem 5.7 |
| **S4** templates | **positive on literal data**: finite first-order-pattern Horn theories realise every certificate verifier, with derivations quadratic in its running time; `cor:time:hard` is tight up to polynomials there. **Gap**: non-literal data, linear (not additive) description overhead, conservativity | Prop 6.1, Cors 6.2, 6.3, Rem 6.4 |

---

## 1. Setting

### 1.1 Syntax, K, sizes, normal derivations

The syntax is the paper's (`def:model:calculus`): formulas in closure-normal form with de Bruijn indices; parameters p_0, p_1, … are free names, read under universal closure; the connectives are ¬ and →, the quantifier is ∀; the signature L has equality. In §4 the signature is finite. A *line* is a formula with no dangling index. Its *size* |χ| is its number of nodes (a quantifier, a connective, a function or relation symbol, =, a constant, an index and a parameter each count one; `app-time.tex`). A *formula node* of χ is a node of formula sort. N(χ) is the number of formula nodes, and F(χ) := Σ over formula nodes v of |χ_v|, where χ_v is the subtree at v. So N(χ) ≤ |χ| and F(χ) ≤ |χ|·N(χ) ≤ |χ|².

**Gen and abstraction.** abs_p(χ) replaces each occurrence of the parameter p at binder depth d by the index d. Gen_p(χ) := ∀ abs_p(χ). If p does not occur in χ, then Gen_p(χ) = ∀χ (vacuous). |Gen_p(χ)| = |χ| + 1, since abstraction replaces parameter nodes by index nodes one for one.

**K** (`def:model:calculus`; `checks/kcore.py`). Logical axioms:
* A1–A3 (propositional);
* A4: ∀B → B[t], with t index-free (so t is always free for the variable);
* A5: ∀(B → C) → (B → ∀C), with B closed;
* reflexivity: ∀(#0 = #0);
* substitutivity: p = q → (B → B'), where B' arises from B by replacing some occurrences of the parameter p by q.

Rules: MP (from A and A → B infer B) and Gen (from χ infer Gen_p(χ)). A *derivation* from a set Ax of nonlogical axioms is a sequence of lines, each with one justification: axiom (logical, or in Ax), MP(i, j) (line j is line i → this line), or Gen(i, p).
* size(π) := Σ |lines|, axioms included, as in `def:model:calculus`.
* I(π) := the set of distinct formulas of the lines justified as axioms (logical and nonlogical).
* M(π) := Σ_{α ∈ I(π)} |α|, the *material*.
* M_nl(π) := the same sum over the distinct nonlogical instances.

**Sits at.** Let α be a formula and v a formula node of α. A line λ *sits at v with k abstractions* if the k nodes directly above v are quantifier nodes, the topmost being u, and there are parameters q_1, …, q_k with α_u = Gen_{q_k}(⋯Gen_{q_1}(λ)⋯). Then α_v is λ with the occurrences of q_1, …, q_k replaced by indices pointing above v, and |λ| = |α_v|. With k = 0, λ = α_v is a literal subformula.

**Normal derivations.** A derivation is *normal* if its lines are pairwise distinct formulas and every line except the last is a premise of a later line. Following uses forward from any line then reaches the last line, so every line is an ancestor of the last.

**Lemma 1.1 (normal form) [proved; computed: `c1`].** Every derivation π from Ax containing a line φ can be turned into a normal derivation π' from Ax whose last line is φ, whose lines are lines of π, with I(π') ⊆ I(π) and size(π') ≤ size(π).

*Proof.*
* Delete every line whose formula occurred earlier, and redirect each citation of it to the first occurrence. The first occurrence is earlier, so all justifications stay valid.
* Cut after the (now unique) line φ, and keep only the ancestors of φ, in order. A kept line other than φ is a premise of a kept line, which is later.
* Nothing is added, and no justification changes. ∎

### 1.2 The inducers and the readings of Hänni's proposal

The background is as in `def:time:inducers` and time-followup Def 1.3: data D = ((φ_1, b_1), …, (φ_n, b_n)), φ^1 := φ, φ^0 := ¬φ. B is a decidable background, and p is a decider of A_p with time_p(χ) = O(t(|χ|)). Put Ax_p := B ∪ A_p. The weight of p is 2^{−|p|}, and losses are in the semimeasure convention: ℓ_X(D) := −log₂ W_X(D) + log₂ W_X(∅). AI[t, d] is "derivation size ≤ d(|φ_i|)" and FIcert[t', d'] is certificate function induction, both from time-followup Def 1.3.

**Definition 1.2 (readings of "derivations from short axioms").** In each reading p is compatible with D if B ∪ A_p is consistent and each φ_i^{b_i} has a K-derivation π_i from Ax_p with the stated property:
* **(a1)** every line of π_i justified as an axiom, logical or nonlogical, has size ≤ h(|φ_i|);
* **(a2)** every line of π_i justified as a member of Ax_p has size ≤ h(|φ_i|); logical instances are free;
* **(b)** M(π_i) ≤ g(|φ_i|);
* **(b2)** M_nl(π_i) ≤ g(|φ_i|).

The inducers are written AI^{a1}[t, h], AI^{a2}[t, h], AI^{b}[t, g], AI^{b2}[t, g]. Where a reading needs no membership-time bound, t is omitted.

**Definition 1.3 (literal language sequences).** L contains a constant e, unary function symbols s0, s1 and a unary relation symbol R; t_w := s_{w_1}(⋯ s_{w_k}(e) ⋯) and φ_w := R(t_w). For X ⊆ {0,1}*, D^X is the sequence of (φ_w, [w ∈ X]) over all words w in length-lexicographic order, and f_X is the assigner that accepts φ_w iff w ∈ X, rejects it otherwise, and abstains elsewhere. B = ∅ unless stated.
* The paper's φ_w := R(num(w)) (`thm:time:ntime`) is another polynomial-time injective encoding.
* The lower-bound arguments (`thm:time:ntime`, time-followup Cor 4.3) do not depend on the encoding.
* The constructions of §4 and §6 read the word off the term. For num(w) they need a conversion phase, which is not written out.

**Fact 1.4 (cited).** For any of these inducers, ℓ_X(D^X_n) stays bounded iff a single hypothesis is compatible with every prefix of D^X: the dominated-convergence argument of time-followup Cor 4.3(c), which uses only that the weights sum to at most 1. Call the set of X with bounded loss the *fit class*.

---

## 2. The subformula lemma for K (S2)

**Lemma 2.1 (axiom and MP lines) [proved; computed: `c1`].** In every derivation π (normal or not), every line justified as an axiom or by MP is a literal subformula of a line justified as an axiom, at or before it.

*Proof.* Induction on the line number.
* An axiom line is its own literal subformula.
* An MP line B has a major premise A → B, an earlier line with root →. Gen conclusions have root ∀, so the major premise is justified as an axiom or by MP. By induction it sits literally at a node u of an axiom line, and B is the right child of u. ∎

**Lemma 2.2 (normal derivations) [proved; computed: `c1`].** Let π be normal with last line φ, and J := I(π) ∪ {φ}, a set of distinct formulas. There is an injective map o from the lines of π to the formula nodes of the members of J (nodes of different members counted separately) such that:
* every axiom and MP line λ sits at o(λ) with 0 abstractions;
* every Gen line γ sits at o(γ) with k ≥ 0 abstractions, where q_1, …, q_k are the parameters abstracted along a chain of Gen steps that starts at γ.

Consequently:
* (i) every line has size ≤ max_{α ∈ J} |α|;
* (ii) #lines ≤ Σ_{α ∈ J} N(α) ≤ Σ_{α ∈ J} |α|;
* (iii) size(π) ≤ Σ_{α ∈ J} F(α) ≤ Σ_{α ∈ J} |α|² ≤ (M(π) + |φ|)², where the term |φ| can be dropped if φ ∈ I(π).

*Proof.*
* *Axiom and MP lines.* Define o by induction on the line number.
  * o(an axiom line α) := the root of α ∈ I(π).
  * o(an MP line B with major premise A → B) := the right child of o(A → B).
  * As in Lemma 2.1, the major premise is not a Gen line, so o(A → B) is already defined, and the subtree at o(λ) is λ itself.
* *Gen lines.* For a Gen line γ choose a forward chain γ = γ_0, γ_1, …, γ_k: γ_{i+1} is a line justified by Gen with premise γ_i, abstracting q_{i+1}, and the endpoint e := γ_k is the minor premise of some MP line or is the last line.
  * Such a chain exists. γ_i is used later unless it is the last line (normality). It cannot be a major premise (root ∀ against root →). If it is a minor premise, stop; otherwise it is a Gen premise, and continue. The line numbers increase, so the chain ends.
  * If e is the minor premise A of an MP line with major premise A → B, let o_e be the left child of o(A → B), a literal occurrence of e. If e = φ, let o_e be the root of φ ∈ J (here φ is a Gen line, so φ ∉ I(π)).
  * e = Gen_{q_k}(⋯Gen_{q_1}(γ)⋯), so from o_e one can descend through k quantifier nodes. Let o(γ) be the node reached. γ sits at o(γ) with k abstractions.
* *An observation.* If λ sits at v and the subtree at v has no dangling index, then λ equals that subtree. An abstracted parameter that occurred in λ would leave an index pointing above v.
* *Injectivity.* Suppose λ ≠ λ' and o(λ) = o(λ') =: v.
  * Both are axiom or MP lines. The subtree at v equals both, so λ = λ'. This contradicts normality (distinct lines are distinct formulas).
  * λ is an axiom or MP line, and λ' = γ is a Gen line. The subtree at v is λ, which has no dangling index. By the observation γ = λ, a contradiction.
  * Both are Gen lines, γ and γ', with chains of lengths k ≤ k' and endpoints e, e'.
    * The node u that lies k levels above v is o_e, and the subtree there is e (a line, no dangling index).
    * γ'_k, the k-th line of γ'’s chain, sits at u (with k' − k abstractions). By the observation γ'_k = e = γ_k, so they are the same line.
    * Each line has one justification, so γ_{k−1} = γ'_{k−1} (the premise of their common Gen step), and so on down to γ = γ'. Contradiction.
* *Bounds.*
  * |λ| = |subtree at o(λ)|, which gives (i).
  * Injectivity gives (ii).
  * Σ_λ |λ| ≤ Σ_{α ∈ J} Σ_{v formula node of α} |α_v| = Σ_{α ∈ J} F(α), and F(α) ≤ |α|², which gives (iii). ∎

**Corollary 2.3 (material ≈ derivation size) [proved].** For every φ and Ax, let M_min(φ) and ℓ_min(φ) be the least material and the least size of a K-derivation of φ from Ax. Then M_min(φ) ≤ ℓ_min(φ) ≤ (M_min(φ) + |φ|)². More precisely, every derivation π of φ can be replaced by one with axiom instances among I(π) and size ≤ Σ_{α ∈ I(π) ∪ {φ}} F(α).

*Proof.*
* M(π) ≤ size(π), since every member of I(π) is a line of π.
* Conversely, normalise π (Lemma 1.1) and apply Lemma 2.2(iii). F is summed over I(π') ∪ {φ} ⊆ I(π) ∪ {φ}. ∎

**Proposition 2.4 (tightness for normal derivations) [proved; computed: `c1`].** Let a, b be sentences and α_j := a → (a → ⋯ (a → b)) with j copies of a. The normal derivation a, α_k, α_{k−1}, …, α_0 = b has
* size |a| + (|a| + 1)k(k + 1)/2 + (k + 1)|b|, with M = |a| + k(|a| + 1) + |b|;
* size / Σ_{α ∈ J} F(α) → 1 and size / (M + |b|)² → 1/(2(|a| + 1)) as k → ∞.

So the bound Σ F of Lemma 2.2 is attained up to 1 + o(1), and the exponent 2 cannot be lowered.

* *Computed* (`c1_subformula.out`, a = P(0), b = Q(0,0)): at k = 1000, size 1504505, Σ F = 1506508, ratio 0.9987, and size/(M + |φ|)² = 0.1663 against 1/6.
* Whether ℓ_min can be of order (M_min + |φ|)² for some family, which would make Corollary 2.3 tight for least sizes, is **[open]** and not needed.

**Remark 2.5 (each hypothesis, checked) [proved; computed: `c1`].**
* *MP order.* Only one property of MP is used: the conclusion is the right child of the major premise. The order of the premises in the derivation is irrelevant.
* *Gen chains.* Gen chains matter everywhere, not only at the conclusion. A Gen line that is the premise of another Gen line sits only with abstractions. Example: Q(p0, p1) ⊢ ∀Q(#0, p1) ⊢ ∀∀Q(#0, #1), the last used as an MP minor premise. The middle line contains p1 where the major premise has #1, so it is a subformula of nothing literally.
  * `c1` (1800 normal derivations from 300 random raw ones): 2992 Gen lines; 1537 chains end at once in an MP minor premise; 182 derivations have a chain of length ≥ 2 (the longest is 6); 1521 A4 lines. No failure of (L1)–(L5).
* *Normality.* Lemma 2.1 needs no hypothesis (`c1`: 38760 raw axiom and MP lines, no exception).
  * Without pruning, nothing holds for Gen lines. Vacuous Gen chains can be arbitrarily long and unused. `c1`: 3103 of 9555 raw Gen lines sit nowhere in I ∪ {last line}.
  * Repeated lines matter only for the line count (ii). The per-line bound (i) needs only pruning.
* *The size measure.* With Mendelson's named variables (Gen: from B infer ∀xB) every Gen premise is a literal subformula of its conclusion. The same proof then gives k = 0 everywhere and the same bounds, with sizes in the named-variable measure.
* *A4.* A4 plays no special role in the proof. Its instances count in M with their full size |∀B| + |B[t]| + 1, every copy of the substituted term included. This is why material bounds derivation size.
  * In a calculus with ∀E as a rule (the paper's L1 trees, `def:model:lone`), the proof fails at ∀E, whose conclusion is not a subformula of its premise.
  * The translation in `prop:time:sigma`(b) turns each ∀E into an A4 instance and MP. It restores the bound if the ∀E conclusions are counted.

**Proposition 2.6 (logical axioms free: material does not bound size) [proved, given `thm:time:ntime`, Prop 4.8, and the existence of decidable languages outside any given NTIME class (known)].** Let L ⊇ L_A ∪ {e, s0, s1, R, C}, C a binary relation symbol, B = Q, and s(m) ≥ m time-constructible. There are a decidable X and an axiom set A with the following properties:
* membership in A is decidable in polynomial time, of a degree independent of X;
* Q ∪ A ∪ Γ_{f_X} is consistent;
* every datum φ_w^{[w∈X]} has a K-derivation from Q ∪ A with M_nl ≤ a|φ_w| + b;
* for infinitely many m some w ∈ X of length m has no K-derivation from Q ∪ A of size ≤ s(m).

By Corollary 2.3, every derivation of such a φ_w has total material > √(s(m)) − |φ_w|. In particular the derivation of the third item has logical material > √(s(m)) − (a + 1)|φ_w| − b.

*Proof.*
* Take A := A^tr_{f} of Prop 4.8 for a decider f of X. Prop 4.8 gives the polynomial membership, the consistency (with B = Q ⊆ Th(ℕ) and R interpreted as X) and the material bound.
* `thm:time:ntime`, applied to T := Q ∪ A (membership in time O(n^e), e fixed), shows the following. If all but finitely many w ∈ X had derivations of size ≤ s(|w|), then X ∈ NTIME(s^{c_e}) (finitely many exceptions go in a table).
* A decidable X ∉ NTIME(s^{c_e}) exists. NTIME(T) ⊆ DTIME(2^{O(T)}), and the deterministic time hierarchy gives decidable sets outside DTIME(2^{O(s^{c_e})}) [known].
* The last sentence: if some derivation had total material ≤ g, a derivation of size ≤ (g + |φ_w|)² would exist. ∎

**Remark 2.7 (natural deduction, sequent calculus, ∀E as a rule).**
* *Natural deduction and sequent calculus with cut* have no logical axioms. Their rules (→I, ∧I, ∀E with an arbitrary term, cut with an arbitrary cut formula) create formulas that are subformulas of no axiom used.
  * In these calculi "material" can only mean the nonlogical axioms used.
  * Proposition 2.6 applies to them verbatim [proved]. Its lower bound holds for any proof system with polynomial-time proof checking, by guessing and checking. Its upper bound holds because the nonlogical axioms used are the same finite set, by completeness.
* *Cut-free sequent calculus.* Every formula is a subformula of the end sequent up to the terms substituted by ∀L and ∃R, but lines are sequents, sets of formulas, so the line count of Lemma 2.2(ii) has no analogue. Not pursued [not checked].
* *∀E as a rule*: see Remark 2.5. Whether material still bounds size polynomially in such a calculus is not settled here.

---

## 3. Reading (b): total material (S1(b))

**Theorem 3.1 (material ≡ derivation size ≡ certificates) [proved, given time-followup Thm 4.2].**
* (i) For every p and every φ^b: a derivation from Ax_p of size ≤ d has material ≤ d; a derivation with material ≤ g gives one of size ≤ (g + |φ^b|)².
* (ii) Hence, with G(m) := (g(m) + m + 1)², for every D:

  W_{AI[t, g]}(D) ≤ W_{AI^b[t, g]}(D) ≤ W_{AI[t, G]}(D),

  hypothesis by hypothesis, with the same weights.
* (iii) With time-followup Thm 4.2 (constants c and the polynomials t⁺, t'^#, d^# there):

  W_{AI^b[t, g]}(D) ≤ 2^c·W_{FIcert[t⁺, G']}(D), with G'(m) := β G(m) log₂(G(m) + 2), and

  W_{FIcert[t', d']}(D) ≤ 2^c·W_{AI^b[t'^#, d^#]}(D).

*Proof.*
* (i) is Corollary 2.3 with |φ^b| ≤ |φ| + 1.
* (ii): the compatibility relations are nested, so the sums are.
* (iii): compose with Thm 4.2(a) and (b). The derivation of time-followup Thm 4.2(b) has size ≤ d^#, hence material ≤ d^#. ∎

**Corollary 3.2 (separations carry over) [proved, given time-followup Cor 4.3].** Mix over budgets as in time-followup Cor 4.3(e), and denote the mixture AI^b[poly, poly]. On literal language sequences its fit class is NP ∩ coNP:
* bounded loss implies X ∈ NTIME ∩ coNTIME(poly), by `thm:time:ntime` applied to X and its complement;
* polynomial verifiers for X and its complement give bounded loss (time-followup Thm 4.2(b)).

So the separations of time-followup Cor 4.3 hold for reading (b) verbatim:
* unconditional against FIcons_τ when g exceeds τ by a hierarchy gap (with the slack of referee m6 there);
* at polynomial budgets, stronger if NP ∩ coNP ≠ P and not stronger if P = NP; the intermediate case open.

**Remark 3.3 (reading (b2)).** If only the nonlogical material is bounded, Proposition 2.6 and Propositions 4.7 and 4.8 apply: reading (b2) is not a time limit (see §4.3).

---

## 4. Reading (a): every instance short (S1(a))

### 4.1 Logical instances counted (a1): deterministic exponential time

**Lemma 4.1 (renaming; the canonical closure) [proved; computed: `c3`].** Let Ax be closed under permutations of the parameters (true when its members are parameter-free, and for the instance sets of parameter-free templates).
* (a) For every permutation ρ of the parameters and every derivation π from Ax, ρ(π) is a derivation from Ax with the same sizes. Here ρ(π) applies ρ to every line and to the parameter named by every Gen step, vacuous ones included.
* (b) Let D_H be the set of formulas that have a derivation from Ax all of whose lines have size ≤ H, and let can(χ) rename the parameters of χ to p_0, p_1, … in order of first occurrence. Then can(D_H) is the least set S of canonical formulas of size ≤ H such that:
  * S contains can(α) for every axiom instance α of size ≤ H, logical or in Ax;
  * (MP) if X ∈ S has the form A → B and can(A) ∈ S, then can(B) ∈ S;
  * (Gen) if X ∈ S, p occurs in X or is one fixed parameter not in X, and |Gen_p(X)| ≤ H, then can(Gen_p(X)) ∈ S.

*Proof.*
* (a)
  * MP is preserved, since ρ(A → B) = ρA → ρB.
  * Gen: ρ(Gen_p(χ)) = Gen_{ρp}(ρχ), because ρ is injective, so no other parameter of χ goes to ρp. The parameter of a vacuous Gen must be renamed too; `c3` found that a reconstruction which forgets it breaks.
  * Logical schemas are closed under renaming. A1–A3 trivially; A4: ρ(∀B → B[t]) = ∀ρB → (ρB)[ρt]; A5: the side condition is about indices; reflexivity has no parameter; substitutivity: ρB' arises from ρB by replacing some occurrences of ρp by ρq.
  * Ax is closed by assumption.
  * A non-injective renaming can break Gen (`c3`, expected and found).
* (b) By (a), D_H is closed under permutations, so χ ∈ D_H iff can(χ) ∈ D_H.
  * *S ⊆ can(D_H).* Induction on the construction of S.
    * Axiom: one line.
    * MP: X ∈ D_H and A ∈ D_H. Concatenate their derivations and add B (|B| < |X| ≤ H).
    * Gen: one more line.
  * *can(D_H) ⊆ S.* Induction on a derivation with all lines ≤ H.
    * An MP line B from A and A → B: can(A → B) = σA → σB for the canonicalising permutation σ, and can(σA) = can(A) ∈ S. So can(σB) = can(B) ∈ S.
    * A Gen line Gen_p(λ): can(λ) = σλ. Gen_{σp}(σλ) = σ Gen_p(λ) has the same canonical form, and all vacuous Gens give the same formula. ∎

**Theorem 4.2 ((a1) is decidable in deterministic time 2^{O(h log h)}) [proved; computed: `c3`].** Let L be finite with σ_L symbols, and let Ax := B ∪ A_p be closed under permutations of the parameters with membership decidable in time t_Ax.
* (i) There are at most (σ_L + 2H + 4)^{H+1} canonical formulas of size ≤ H.
* (ii) can(D_H) is computable in time 2^{O(H log H)}·(1 + t_Ax(H))^{O(1)}.
* (iii) Put H(φ) := max(h(|φ|), |φ| + 1), and let g_p(φ) := acc if φ ∈ D_{H(φ)}; rej if ¬φ ∈ D_{H(φ)} and φ ∉ D_{H(φ)}; abstain otherwise. Then:
  * g_p is a total assigner, |g_p| ≤ |p| + c, and Γ_{g_p} ⊆ Cn(Ax);
  * g_p runs in time 2^{O(H log H)}·(1 + t_Ax(H))^{O(1)};
  * g_p is FIcons-compatible with every D with which p is (a1)-compatible with budget h.
* (iv) Hence the fit class of AI^{a1}[t, h] on literal sequences (Fact 1.4) is contained in DTIME(2^{O(H log H)}·(t(H) + 1)^{O(1)}), with H = h(|φ_w|) + |φ_w| + 1.

*Proof.*
* (i) A canonical formula of size n is a preorder sequence of n tokens. Each token is a symbol of L, ¬, →, ∀, =, one of < H indices, or one of < H parameters (canonical numbering). So there are ≤ (σ_L + 2H + 4)^n of size n; sum over n ≤ H.
* (ii) Let N be the bound of (i).
  * Enumerate the N canonical formulas and test each against the logical schemas (polynomial; A4 by matching) and against Ax. Since Ax is closed under permutations, χ ∈ Ax iff can(χ) ∈ Ax.
  * Then close under the two rules of Lemma 4.1(b). There are at most N rounds, each O(N·poly(H)). The total is N^{O(1)}·(1 + t_Ax(H)) = 2^{O(H log H)}·(1 + t_Ax(H)).
  * Running p inside a fixed wrapper costs a polynomial (time-followup (S), or any reasonable machine model).
* (iii)
  * If p is (a1)-compatible, each φ_i^{b_i} has a derivation whose instances have size ≤ h(|φ_i|).
  * Normalise it (Lemma 1.1, which does not enlarge I). By Lemma 2.2(i) every line then has size ≤ max(h(|φ_i|), |φ_i^{b_i}|) ≤ H(φ_i), so φ_i^{b_i} ∈ D_{H(φ_i)}.
  * B ∪ A_p is consistent, so φ_i^{1−b_i} ∉ D_{H(φ_i)}, and g_p labels φ_i with b_i.
  * Γ_{g_p} ⊆ Cn(Ax) is consistent with B.
* (iv) By Fact 1.4 and (iii). ∎

**Proposition 4.3 (ground axioms simulate alternating space) [proved; computed (deterministic counter and QBF illustrations): `c3`].** Let L ⊇ {e, s0, s1, R, C, C'} with C, C' binary relation symbols, and B = ∅. Let M be an alternating Turing machine that decides X in space s(m) ≥ m, has branching ≤ 2, and halts on every computation path. Encode configurations of M on w (state, input-head position, work tape with head) as words of length ≤ c_M(s(|w|) + 1), written as terms t_c. Let A_M consist of the ground sentences
* C(t_w, t_c) for accepting halting c, and C'(t_w, t_c) for rejecting halting c;
* C(t_w, t_{c'}) → C(t_w, t_c) for an existential c with successor c';
* C(t_w, t_{c_1}) → (C(t_w, t_{c_2}) → C(t_w, t_c)) for a universal c with successors c_1, c_2;
* the duals for C', with the roles of existential and universal exchanged;
* C(t_w, t_{init(w)}) → R(t_w) and C'(t_w, t_{init(w)}) → ¬R(t_w).

Then:
* membership in A_M is decidable in time polynomial in |χ|, by a decider of length |M| + c;
* A_M ∪ Γ_{f_X} is consistent;
* every datum φ_w^{[w ∈ X]} has a K-derivation from A_M that uses only MP, has at most 2^{c'_M(s(|w|)+1)} lines, and has every line of size ≤ c''_M(s(|w|) + 1).

*Proof.*
* *Membership.* Parse the shape, decode the configurations, and check the local transition relation of M on w, read off the input head position. This is polynomial.
* *Consistency.* Take the free term algebra on L's function symbols, with:
  * C := {(t_w, t_c) : c is accepting for M on w}, the least fixed point of the alternating acceptance condition;
  * C' := the same for rejecting;
  * R := {t_w : w ∈ X}.
  The axioms are exactly the closure conditions of these fixed points, together with the two output axioms. The output axioms hold because M decides X. On paths that all halt, every configuration is accepting or rejecting and not both (induction on rank).
* *Derivation.* For w ∈ X, list the accepting configurations of an accepting computation tree from init(w) in order of fixed-point rank. Derive C(t_w, t_c) for each: a halting fact is cited; an existential or universal step is cited, followed by one or two MP steps. Finish with the output axiom and MP. The case w ∉ X is dual.
* *Sizes.* Every line is an atom or a subformula of an axiom instance, of size O(s(|w|)). There are at most #configurations·O(1) = 2^{O(s)} lines. No logical axiom is used. ∎

*Computed* (`c3_short_axioms.out`).
* Part B: a k-bit counter as ground axioms C(t_v) → C(t_{v+1}). 2^k − 1 MP steps, every instance of size 2k + 5, valid for k ≤ 10 (2047 lines).
* Part C: QBF evaluation by existential and universal ground axioms and the dual C'. 80 random QBFs with n ≤ 8, verdicts all correct, up to 201 lines with instances of size ≤ 31.
* Part A: the closure of Lemma 4.1 in a language {a/0, P/1, c, =} at H = 9. 59055 canonical formulas, closure 901. All 901 rebuilt derivations validate, with lines ≤ H. All 12698 lines of 400 independently generated short-line derivations are in the closure.

**Corollary 4.4 ((a1) at polynomial budgets is EXPTIME) [proved, given Chandra–Kozen–Stockmeyer and the deterministic time hierarchy (known)].** Let AI^{a1}[poly, poly] be the mixture over pairs (p, j), with polynomial membership time and budget h = (m + 2)^j, weighted as in time-followup Cor 4.3(e).
* (i) On literal sequences its fit class is exactly EXPTIME.
* (ii) (a1) is a genuine time limit. For all computable h, t there is a decidable X such that ℓ_{AI^{a1}[t,h]}(D^X_n) → ∞, while unpenalised FIcons has bounded loss (the hypothesis f_X).
* (iii) Unconditionally, AI^{a1}[poly, poly] has bounded loss on some D^X on which FIcons_poly does not (P ≠ EXPTIME).
* (iv) W_{AI^b[t,g]}(D) ≤ W_{AI^{a1}[t,g]}(D) for every D, so the fit class NP ∩ coNP of reading (b) is contained in EXPTIME. The two readings have different fit classes iff NP ∩ coNP ≠ EXPTIME, which is **[open]** (it follows from NP ≠ EXPTIME).
* (v) In terms of the deterministic clock: every X ∈ DTIME(2^{h}) is in the fit class of AI^{a1}[poly, c_X·h] for some constant c_X, and the fit class of AI^{a1}[poly, h] is contained in DTIME(2^{O(h log h)}). So reading (a1) is deterministic function induction with an exponential clock, and nondeterminism plays no role. Closing the log factor is **[open]**; it comes from counting a parameter as one symbol.

*Proof.*
* (i)
  * ⊆: Theorem 4.2(iv) with polynomial h and t.
  * ⊇: EXPTIME = APSPACE = ⋃_k ASPACE(m^k) [known: Chandra, Kozen, Stockmeyer 1981 (not checked)]. With a clock, all computation paths halt [known]. Then use Proposition 4.3 with s = m^k.
* (ii) Let T(m) := 2^{H²}·(t(H) + 1)^H with H = h(m + 2) + m + 3. T is computable and eventually exceeds 2^{cH log H}·(t(H) + 1)^c for every c. Choose a decidable X ∉ DTIME(T) [deterministic time hierarchy, known]. By Theorem 4.2(iv) no single hypothesis fits D^X, so by Fact 1.4 the loss tends to ∞.
* (iii) Take X ∈ EXPTIME ∖ P, which exists by the time hierarchy. FIcons_poly has unbounded loss on D^X (time-followup Cor 4.3(e), first bullet, with P in place of NP ∩ coNP).
* (iv) Material ≤ g implies every instance ≤ g.
* (v) DTIME(2^{h}) ⊆ ASPACE(O(h)) for h ≥ log m [CKS], then Proposition 4.3. The upper bound is Theorem 4.2. ∎

**Proposition 4.5 (time-bounded predictors, Hänni's S among them, lose to (a1)) [proved, given CKS (known) and the loss argument of time-followup Thm 3.2(c); for S, given Hänni's description of its running time].** Let P be a predictor that may use the history. Suppose that on a history of j literal data and a next datum, its predictive pair can be approximated within 2^{−k} in time polynomial in j + k. Then there are X ∈ DTIME(2^{O(m)}) and constants c_P, c'_P such that:
* ℓ_P(D^X_n) ≥ n − 1/(2 ln 2) for every n;
* a single AI hypothesis with polynomial-time membership is (a1)-compatible with all of D^X under the budget h(m) = c_P·m + c'_P, so ℓ_{AI^{a1}}(D^X_n) is bounded.

*Proof.*
* Define β_j as in time-followup Thm 3.2: β_j := 0 iff a_0 ≤ a_1, where (a_0, a_1) approximate P's pair within 2^{−j−3} on the history D_{j−1} and the next datum φ_{w_j}. Put X := {w_j : β_j = 1}.
* Computing β_1, …, β_n takes Σ_{j ≤ n} poly(j) = poly(n) steps. For |w_n| = m, n < 2^{m+1}, so X ∈ DTIME(2^{am}) for some a.
* The loss bound is the computation of time-followup Thm 3.2(c), which uses only the choice rule for β_j. No self-reference is needed, because the sequence is literal.
* By CKS, X ∈ ASPACE(O(am)); a clock makes all paths halt. Proposition 4.3 then gives the hypothesis.
* For Hänni's S_p (`hanni-polytime-solomonoff.md`): replaying its first j steps from scratch costs Σ_{i ≤ j} p(i) log i = poly(j), given his per-step bound p(n) log n with state reuse (not checked). ∎

The converse fails. On the coin-flip sequences of `prop:time:fiall`, S and FIall_τ have bounded loss while every reading of AI loses at least n bits in expectation. That argument uses only that compatible hypotheses are consistent. So under (a1), AI and S are incomparable, as in time-followup Prop 3.4. Under reading (b), the comparison with S on literal sequences is time-followup Rem 4.5(iii), still **[open]**.

### 4.2 What each construction pays

**Proposition 4.6 (Craig padding and the bounded schema are blocked under every reading).**

(i) **[proved]** Literal data, B = ∅, f a *literal assigner* (it abstains on every sentence other than the φ_w, like f_X) and A^C_f its Craig set (`thm:time:equiv`). For assigners that also label other sentences, a quickly accepted sentence can imply a slowly decided literal, and the statement can fail. Every K-derivation of φ_w^b from A^C_f contains (φ_w^b)^{∧(k+1)}, k = time_f(φ_w), a line of size ≥ (k + 1)|φ_w^b|. So the Craig hypothesis is compatible with φ_w under (a1), (a2), (b) or (b2) only if (time_f(φ_w) + 1)|φ_w^b| is within the budget.

*Proof.*
* Let F be the set of Craig axioms used. Each is a power of a literal ±φ_{w'}, logically equivalent to that literal.
* If F contained no power of φ_w^b, take the term algebra with R chosen to satisfy F's literals and to falsify φ_w^b (distinct words give distinct terms). Then F ⊬ φ_w^b.
* The only power of φ_w^b in A^C_f has k + 1 factors, k = time_f(φ_w), and ψ^{∧(k+1)} contains k + 1 copies of ψ. ∎

(ii) **[proved, given time-followup Prop 2.5(c) and a coding assumption]** Assume one sort, L ⊇ L_A ∪ {e, s0, s1, R}, B = Q, and a coding of computations in which the code of a halting computation of length T is ≥ 2^T (true for the usual sequence codings). Then every K-derivation of φ_w^b from B ∪ A^bd_f contains an axiom whose numeral k̄ has k ≥ w_f(φ_w), hence at least log₂ w_f(φ_w) ≥ time_f(φ_w) symbols.

*Proof.*
* The side condition of Prop 2.5(c) holds on literal data with B = Q. Interpret e, s0, s1 injectively on ℕ; then Q together with literals on other words does not decide R(t_w).
* Prop 2.5(c) then gives the axiom with k ≥ w_f(φ_w).
* A binary numeral for k has at least ⌊log₂ k⌋ + 1 symbols. ∎

So the orchestrator's hypothesis that A^bd_f is not blocked is **refuted**: its bound k plays the role of Craig's padding, at a cost of log k symbols (time-followup m10's reading of it).

**Proposition 4.7 (Hänni's two-sorted schema under (a2) and (b2)) [proved, given `prop:time:twosorted` with B = Q ∪ B_L].** Work in two sorts with B = Q on the arithmetic sort and B_L pure L-sort sentences (the hypothesis as corrected by the time-followup referee, M2). Let f be an FIcons hypothesis, that is, B ∪ Γ_f is consistent. Then:
* B ∪ A_f is consistent;
* every φ that f labels has a K-derivation whose nonlogical instances are Q1–Q7 and one member Acc_f(⌜φ⌝) → φ (or Rej_f(⌜φ⌝) → ¬φ) of size ≤ a|f| + a'|φ| + b′.

Hence, for every budget h(m) ≥ a'm + b′ + a|f| on the data, the decider of A_f (|p_f| ≤ |f| + c) is (a2)- and (b2)-compatible wherever f is compatible. On literal sequences, with h(m) ≥ a'm + b″ and any polynomial membership time, the fit class of (a2) and of (b2) is every decidable X.

*Proof.*
* Consistency is `prop:time:twosorted`.
* The derivation proves the true Σ₁ sentence Acc_f(⌜φ⌝) in Q, using Q1–Q7 and logical axioms, then applies MP. The Q-proof's A4 instances may be large; they are logical.
* The binary numeral ⌜φ⌝ has O(|φ|) symbols, and f enters through its index, O(|f|) symbols.
* For the fit class: add the finitely many short data, those whose budget is below a|f| + …, to the axioms as themselves. They are cited by one line of size |φ_w^b| ≤ h(|φ_w|). Membership stays polynomial, and consistency is kept because these literals are in Γ_{f_X}. ∎

**Proposition 4.8 (a one-sorted trace schema, short axioms, any consistent assigner) [proved, given Σ₁- and Δ₀-completeness of Q, the bounded lemma used in time-followup Prop 2.5 (confirmed by its referee), and a Δ₀ definition of the step relation (known, as assumed in time-followup Thm 3.2; reference not checked, see referee m16 there)].**

*Setting.* One sort, L ⊇ L_A ∪ {C} with C a binary relation symbol. B is decidable, B ⊇ Q, and C does not occur in B (for example B = PA with induction for L_A-formulas only). f is an assigner that abstains on every sentence containing C, with B ∪ Γ_f consistent.

*Formulas.* Configurations of f's computation are coded by numbers. The following Δ₀ formulas are needed:
* AccC(y) and RejC(y): "y codes a halting configuration with output acc (respectively rej)";
* Next(y, y') := ∃z (z + y' = t(y)) ∧ N₀(y, y'), where N₀ is Δ₀ and defines the step relation, and t is a term with next(c) ≤ t(c).

For each configuration c, with ȳ the binary numeral of the code of c:
* Q ⊢ Next(ȳ, y') ↔ y' = (next c)‾ if c is not halting, and Q ⊢ ¬Next(ȳ, y') if it is halting. This uses Q ⊢ t(ȳ) = k̄, the bounded lemma Q ⊢ ∃z(z + y' = k̄) → ⋁_{j ≤ k} y' = j̄, and Q's decision of each N₀(ȳ, j̄).
* Q decides AccC(ȳ) and RejC(ȳ).

*The schema.* A^tr_f consists of:
* S := ∀x∀y∀y' (C(x, y) → (Next(y, y') → C(x, y'))), one sentence;
* I_φ := C(⌜φ⌝‾, c̄₀(φ)), for each C-free sentence φ, with c₀(φ) the initial configuration of f on φ;
* A_φ := ∀y (C(⌜φ⌝‾, y) → (AccC(y) → φ)) and R_φ := ∀y (C(⌜φ⌝‾, y) → (RejC(y) → ¬φ)).

Then:
* (a) membership in A^tr_f is decidable in time polynomial in |χ|;
* (b) B ∪ A^tr_f ∪ Γ_f is consistent;
* (c) if f accepts φ (rejects φ), φ (¬φ) has a K-derivation from B ∪ A^tr_f whose nonlogical instances are Q1–Q7, S, I_φ and A_φ (R_φ), of total size ≤ a|f| + a'|φ| + b.

*Proof.*
* (a) Parse; compare the numeral with ⌜φ⌝; compute c₀(φ), which is linear.
* (b) Take M ⊨ B ∪ Γ_f, an L ∖ {C}-structure, and expand it by
  C^M := {(⌜φ⌝‾^M, c̄^M) : φ is C-free and c is a configuration of f's run on φ}.
  This is well defined, since M ⊨ Q makes distinct numerals denote distinct elements. Check each axiom:
  * I_φ holds.
  * S: if C^M(a, b), then a and b are denotations of numerals, b = c̄ for a reachable c. If M ⊨ Next(c̄, b'), then b' = (next c)‾^M by the Q-provable uniqueness, and next(c) is reachable. So C^M(a, b').
  * A_φ: C^M(⌜φ⌝‾, b) forces b = c̄ with c reachable on φ. M ⊨ AccC(c̄) iff ℕ does (Δ₀, decided by Q), and then f accepts φ, so φ ∈ Γ_f and M ⊨ φ.
  * R_φ likewise.
  * Γ_f is C-free, so it still holds.
* (c) Let c₀, …, c_T be the run.
  * Cite I_φ.
  * For each j, prove Next(c̄_j, c̄_{j+1}) in Q, instantiate S three times by A4, and apply MP twice to get C(⌜φ⌝, c̄_{j+1}).
  * Finally prove AccC(c̄_T) in Q, instantiate A_φ, and apply MP twice.
  * The nonlogical instances are as stated. c₀(φ) contains f's code, which gives the term a|f|. ∎

Two remarks on the hypotheses.
* *B must not contain C-induction* [proof sketch]. With B = PA(L) and the f of `prop:time:single`, induction along the run makes B ∪ A^tr_f prove C at nonstandard configurations, which reach a nonstandard proof of ⊥. Then A_{Con(PA)} yields Con(PA), a contradiction, as in `prop:time:single`. So "C not in B" is needed.
* *The fresh symbol is what one sort lacks.* C is interpreted on standard elements only, which no L_A-formula can define. Whether L = L_A admits a short-axiom repair is the open problem below.

**Corollary 4.9 (time-followup's open problem 1, with a fresh relation symbol) [proved, given Prop 4.8].** Take the setting of time-followup Prop 2.4(d) (one sort, B = PA in L_A), extended by a binary relation symbol C not in B. Then the content-relative penalty P3 is vacuous for every consistent assigner that abstains on sentences containing C:
* G_f(φ) := {I_φ, S, A_φ, R_φ} is computable in time polynomial in |φ| for fixed f;
* B ∪ G_f(φ) ⊢ φ^b for each decision of f;
* B ∪ ⋃_φ G_f(φ) is consistent.

For L = L_A with no extra symbol the question stays **[open]** (time-followup Prop 2.4(d), Rem 5.3, open problem 1).

**Remark 4.10 (the reflection sentence ρ_{f,n} of `prop:time:collapse`) [(a1): proved; (a2), (b2): proof sketch].**
* (a1) and (b): PA + ρ_{f,n} has polynomial-time membership. By Theorem 4.2 and Corollary 3.2, only assigners in DTIME(2^{O(h log h)}) under (a1), and in NP ∩ coNP-type classes under (b), are realised.
* (a2) and (b2): the derivation of φ from PA + ρ_{f,n} (f Σ_n-sound, φ ∈ Σ_n) proves Acc_f(⌜φ⌝) and Sent_{Σ_n}(⌜φ⌝) in Q, applies ρ_{f,n}, and then uses the Tarski biconditional Tr_n(⌜φ⌝) → φ. The biconditional is assembled by meta-induction on φ from a fixed finite set of PA-theorems (the compositional clauses of Tr_n and the substitution properties of the coding), instantiated by logic, plus Q-facts about specific numerals.
  * So the nonlogical instances used are Q1–Q7, the finitely many induction instances behind those fixed theorems, and ρ_{f,n}: a constant set for fixed f and n.
  * *Not written out*: that the fixed finite set suffices for every Σ_n sentence φ.

**Remark 4.11 (no membership-time bound: no time limit) [proved].** For a total consistent assigner f, the set A := Γ_f is decidable, and every datum that f labels is derived by citing itself: one line of size ≤ |φ| + 1. So with h(m), g(m) ≥ m + 1 and no bound on membership time, every reading contains every total consistent assigner, and every decidable X is in the fit class. The time limit of (a1) and (b) comes from the budget together with the membership-time bound, as in `thm:time:ntime` and time-followup Def 1.3.

### 4.3 Summary table

| construction | (a1) all instances ≤ h | (a2) nonlogical instances ≤ h | (b) total material ≤ g | (b2) nonlogical material ≤ g |
|---|---|---|---|---|
| Craig A^C_f | blocked unless (time_f + 1)\|φ\| ≤ h (4.6(i)) | same | same | same |
| bounded schema A^bd_f (one sort) | blocked unless log₂ w_f(φ) ≤ h (4.6(ii)) | same | same | same |
| Hänni's A_f, two sorts | only DTIME(2^{O(h log h)}) assigners (4.2) | **not blocked** (4.7) | only NP ∩ coNP-type (3.1, 3.2) | **not blocked** (4.7) |
| trace schema A^tr_f, one sort, fresh C, B ⊇ Q | only DTIME(2^{O(h log h)}) (4.2) | **not blocked** (4.8) | only NP ∩ coNP-type | **not blocked** (4.8) |
| ρ_{f,n} over PA, Σ_n-sound f | only DTIME(2^{O(h log h)}) (4.2) | not blocked (sketch, 4.10) | only NP ∩ coNP-type | not blocked (sketch) |
| ground alternating axioms A_M | realise ASPACE(h/c) (4.3) | same | material exponential: not useful | same |
| certificate axioms A_V (time-followup Thm 4.2(b)) | realise FIcert | same | realise FIcert (3.1) | same |
| **fit class, polynomial budgets and membership** | **EXPTIME** (4.4) | **all decidable** (two sorts, or fresh C) | **NP ∩ coNP** (3.2) | **all decidable** |

---

## 5. Soft charges (S3)

**Definition 5.1 (the soft inducers).**
* *The code.* Fix the prefix code Code_K for derivations of `checks/kcore.py` and `c4`. Each line is coded as a 2-bit tag (axiom, MP, Gen), then the Elias-γ codes of its premise line numbers + 1 and, for Gen, of its parameter number + 1, then its formula. A formula is coded in preorder, b_s := ⌈log₂(σ_L + 6)⌉ bits per token, with the escapes IDX and PAR followed by Elias-γ of the number + 1. A 2-bit end tag closes the derivation.
  * |χ|_bit is the length of a formula's code, so |χ| ≤ |χ|_bit.
  * ℓ^bit_p(ψ) is the least |Code(π)| over derivations π of ψ from Ax_p, and ℓ^sym_p(ψ) the least symbol size; both are ∞ if no derivation exists.
* *Soft AI*, AI^σ_κ[t] (bit cost):

  W(D) := Σ_{p: time O(t), B ∪ A_p consistent} 2^{−|p|}·Π_i 2^{−κ ℓ^bit_p(φ_i^{b_i})}.

  This is Hänni's graded score with g(ℓ) = 2^{−κℓ} and g_∞ = 0 (`rem:model:graded`), applied to both polarities and not normalised. AI^{σ,sym}_κ uses ℓ^sym.
* *Soft certificate FI*, FIcert^σ_{κ,μ}[t']: the hypotheses are verifiers V with time_V(φ, c) = O(t'(|φ| + |c|)) and B ∪ Γ_{f_V} consistent, where f_V uses certificates of any length. With λ_V(φ^1) := min{|c| : V(φ, c) = acc}, λ_V(φ^0) := min{|c| : V(φ, c) = rej} (∞ if none),

  W(D) := Σ_V 2^{−|V|}·Π_i 2^{−κ λ_V(φ_i^{b_i}) − μ |φ_i|_bit}.

  With μ = κ the charge is κ per bit of statement plus certificate (the *joint* charge). With μ = 0 it is the certificate-only charge of the orchestrator's formulation.
* *Semimeasures* [proved]. For a consistent hypothesis at most one of φ, ¬φ has finite cost, and every factor is ≤ 1. So W(D + (φ, 1)) + W(D + (φ, 0)) ≤ W(D), as in `def:time:inducers`. W(∅) is the total weight of the consistent hypotheses: at least the weight of the empty axiom set (when B is consistent), or of the always-⊥ verifier. Losses are ℓ(D) = −log₂ W(D) + log₂ W(∅).

**Theorem 5.2 (the soft sandwich) [proved; computed: `c4`].** Let e_1 := 31b_s + 24 and r := max(2b_s, 2 + e_1). For every D:

(a) W_{FIcert^σ_{κ,κ}[t⁺]}(D) ≥ 2^{−c}·W_{AI^σ_κ[t]}(D). Hence ℓ_{FIcert^σ_{κ,κ}}(D) ≤ ℓ_{AI^σ_κ}(D) + c′, with c′ := c + log₂(1/W_{AI^σ_κ}(∅)).

(b) W_{AI^σ_κ[t'^#]}(D) ≥ 2^{−c}·2^{−κ e_1 n}·W_{FIcert^σ_{2b_sκ, 2κ}[t']}(D), and W_{AI^σ_κ[t'^#]}(D) ≥ 2^{−c}·W_{FIcert^σ_{rκ, rκ}[t']}(D). Hence ℓ_{AI^σ_κ}(D) ≤ ℓ_{FIcert^σ_{rκ, rκ}}(D) + c″.

(c) *Symbol cost.* Assume Ax_p is closed under permutations of the parameters. Then:
* λ_{V_p}(φ^b) ≤ ℓ^bit_p(φ^b) − |φ^b|_bit, and ℓ^bit_p ≤ β ℓ^sym_p log₂(ℓ^sym_p + 2);
* ℓ^sym_{p_V}(φ^b) ≤ 2λ_V(φ^b) + 2|φ^b| + 29 ≤ 2λ_V(φ^b) + 2|φ| + 31.

*Proof.*
* (a) For a hypothesis p let V_p(φ, c) be: acc if c followed by Code(φ) and the end tag decodes as a derivation of φ from Ax_p; rej if this holds with ¬φ in place of φ; ⊥ otherwise.
  * The certificate for φ^b is Code(π) with the last line's formula and the end tag removed, so λ_{V_p}(φ^b) ≤ ℓ^bit_p(φ^b) − |φ^b|_bit.
  * Then κλ + κ|φ|_bit ≤ κ ℓ^bit_p, because |φ|_bit ≤ |φ^b|_bit.
  * Checking a decoded derivation takes time t⁺ (time-followup Thm 4.2(a)).
  * Γ_{f_{V_p}} ⊆ Cn(Ax_p) is consistent with B, |V_p| ≤ |p| + c, and p ↦ V_p is injective.
  * Sum over p, and use W_{FIcert}(∅) ≤ 1.
* (b) Let Z := ∀(#0 = #0), of size 4. C_c := ν_{c_1}(⋯ν_{c_k}(Z)⋯) with ν_0 := ¬ and ν_1 := ∀ (vacuous), and θ_c := Z → (C_c → Z).
  * θ_c is an instance of A1 of size |c| + 14, and c is read off θ_c uniquely: strip ¬ and ∀ until the remainder is Z.
  * Let A_V := {θ_c → φ : V(φ, c) = acc} ∪ {θ_c → ¬φ : V(φ, c) = rej}. A formula χ is a member iff χ = θ → ψ with θ = θ_c and either V(ψ, c) = acc, or ψ = ¬φ and V(φ, c) = rej. This is decidable in time t'^#, by a decider p_V with |p_V| ≤ |V| + c.
  * Every member is logically equivalent to a member of Γ_{f_V}, and every member of Γ_{f_V} has one. So Cn(B ∪ A_V) = Cn(B ∪ Γ_{f_V}), which is consistent.
  * The derivation θ_c (A1), θ_c → φ^b (axiom), φ^b (MP) has symbol size 2|c| + 2|φ^b| + 29.
  * Its code has length 2b_s|c| + 2|φ^b|_bit + 29b_s + 24, since θ_c has six index nodes of 1 + b_s bits each. With |φ^b|_bit ≤ |φ|_bit + b_s this is ≤ 2b_s|c| + 2|φ|_bit + e_1.
  * Since |φ|_bit ≥ 1, this is ≤ r(|c| + |φ|_bit).
  * Sum over V.
* (c)
  * By Lemma 4.1(a), rename the parameters of a shortest derivation to p_0, p_1, …, all < ℓ^sym. Indices are < ℓ^sym, and so are line numbers. Each symbol then costs ≤ b_s + 2 log₂(ℓ^sym + 1) + 1 bits, and each line adds O(log ℓ^sym). This gives β.
  * The second item is (b) in symbols. ∎

*Computed* (`c4_cert_embedding.out`): 3000 random (φ, c, polarity). Exact symbol size 2|c| + 2|φ^b| + 29 and exact code length 2b_s|c| + 2|φ^b|_bit + 29b_s + 24; θ_c decodes uniquely, and every θ_c is an A1 instance for the independent recogniser. For 480 normal derivations a real encoder and decoder recovers each derivation from (φ, certificate), and the certificate length is the code length − |φ|_bit − 2.

**Proposition 5.3 (the rates cannot be swapped; the statement term is needed) [proved].** Take X = ∅, so the data are (φ_w, 0) for all words w, and B = ∅.
* (i) If κ' > κ, then ℓ_{FIcert^σ_{κ',κ'}}(D^∅_n) − ℓ_{AI^σ_κ}(D^∅_n) → ∞.
* (ii) If κ' < κ, then ℓ_{AI^σ_κ}(D^∅_n) − ℓ_{FIcert^σ_{κ',κ'}}(D^∅_n) → ∞.
* (iii) For every D, ℓ_{AI^σ_κ}(D) ≥ κ Σ_i |φ_i^{b_i}|_bit.

So κ is the only joint rate for which a two-sided constant-regret equivalence could hold. (a) of Theorem 5.2 holds at κ and (b) at rκ. Whether (b) holds at κ is **[open]**.

*Proof.*
* (iii) Every code contains the last line's formula, so ℓ^bit_p(ψ) ≥ |ψ|_bit. Then W(D) ≤ W(∅)·2^{−κ Σ|φ_i^{b_i}|_bit}.
* (i) The decider p_∅ of {¬φ_w} runs in polynomial time and derives each datum by one line of code length |φ_w|_bit + b_s + 4. So ℓ_{AI}(D_n) ≤ |p_∅| + κ Σ_i (|φ_{w_i}|_bit + b_s + 4).
  * Every FIcert hypothesis pays ≥ κ'|φ_i|_bit per datum, so ℓ_{FI}(D_n) ≥ κ' Σ_i |φ_{w_i}|_bit.
  * The difference is ≥ (κ' − κ) Σ_{i ≤ n} |φ_{w_i}|_bit − O(n), and Σ_{i≤n} |w_i| ≥ (n/2)(log₂ n − 3) in length-lexicographic order.
* (ii) The verifier V_∅(φ_w, ε) = rej has λ = 0, so ℓ_{FI}(D_n) ≤ |V_∅| + κ' Σ|φ_i|_bit. With (iii), ℓ_{AI}(D_n) ≥ κ Σ|φ_i|_bit. ∎

**Corollary 5.4 (certificate-only charge: the exact per-datum overheads) [proved].** The statement factor of FIcert^σ does not depend on the hypothesis, so W_{FIcert^σ_{κ,0}}(D) = 2^{κ Σ|φ_i|_bit}·W_{FIcert^σ_{κ,κ}}(D). Hence, for every D:
* ℓ_{FIcert^σ_{κ,0}}(D) ≤ ℓ_{AI^σ_κ}(D) − κ Σ_i |φ_i|_bit + c′;
* ℓ_{AI^σ_κ}(D) ≤ ℓ_{FIcert^σ_{2b_sκ,0}}(D) + κ Σ_i (2|φ_i|_bit + e_1) + c″;
* ℓ_{AI^σ_κ}(D) ≥ κ Σ_i |φ_i^{b_i}|_bit.

So against certificate-only charging, soft AI pays a per-datum overhead between κ|φ^b|_bit and κ(2|φ|_bit + e_1), with the certificate rate doubled per symbol (2b_s bits per certificate bit). Constant regret against FIcert^σ_{κ',0} is impossible on every sequence on which FIcert^σ_{κ',0} has bounded loss. The lower end is tight on data the hypothesis takes as axioms (one line). On data it does not take as axioms, a derivation has symbol size ≥ 2|φ^b| − 1: the last line and its major premise, or its Gen premise.

**Remark 5.5 (relation to the hard version and to `prop:time:sigma`).**
* The hard sandwich (Theorem 3.1, time-followup Thm 4.2) distorts budgets polynomially. The soft one distorts the rate by a constant factor and adds Θ(κ|φ|) per datum, or nothing, with the joint charge.
* Theorem 5.2(a) is the soft form of `thm:time:ntime`: a soft-AI hypothesis is a soft certificate labeller at the same rate.
* With symbol cost, as in L1^σ, (a) holds only up to the factor β log₂(ℓ + 2) in the exponent (Theorem 5.2(c)). Whether this log factor is necessary is not settled. It is necessary for codes that encode every derivation, but a verifier may use other certificates.

**Example 5.6 (least prime factor) [computed: `c2`; Pratt certificates known (Pratt 1975)].**
* The data are "bit i of the least prime factor of N is 1". The certificate is the factorisation of N with a Pratt certificate for each prime factor; the same certificate serves both labels.
* `c2_lpf_certificates.out`: certificates of at most 0.94·b² bits for b-bit N (b ≤ 128, 192 cases), and verifier work ≤ 0.07·b³ modular multiplications. All honest certificates are accepted; tampered ones are rejected, including Carmichael numbers presented as primes.
* So by Theorem 5.2(b) the soft-AI charge per datum is O(b²) bits times κ. The deterministic route (trial division, as a Craig set or as a computation-trace certificate) needs up to 1.9·10⁹ steps at 64 bits and 8.3·10¹⁸ at 128 bits.

**Remark 5.7 (not covered) [open].** The generative versions (L1^σ on positive data with normaliser Z^σ_T, and the graded score divided by Z_T, `rem:model:graded`) are not covered. Their per-datum factor 1/Z_p depends on the hypothesis, so the comparisons acquire factors Π_i Z_V/Z_p, which do not telescope. Comparisons there need control of the normalisers.

---

## 6. Templates (S4)

**Proposition 6.1 (Horn templates simulate a verifier on literal data) [proved; computed for one verifier: `c5`].**

*Setting.* L ⊇ {e, s0, s1, s2, pr, R, C}: pr a binary function symbol, C a binary relation symbol. B = ∅; literal data φ_w = R(t_w).

*Machine.* M is a deterministic 3-tape Turing machine (tapes: input, certificate, work; tape alphabet {0, 1, 2} and blank) computing a verifier V(w, c) ∈ {acc, rej, ⊥} that halts on every input and outputs ⊥ unless w is a word over {0, 1}. f_V is consistent: no w has both an acc and a rej certificate. Let X_acc := {w : ∃c V(w, c) = acc} and X_rej := {w : ∃c V(w, c) = rej}.

*Coding.* A tape with its head is the pair (l, r): the cells left of the head, nearest first, and the cells from the head on, as terms over s0, s1, s2 ending in e (blank). A configuration with state q is conf(q, …) := pr(t_q, pr(l_0, pr(r_0, …))), with t_q the binary word term of q's index.

*The theory T_M.* All metavariables are 0-ary term metavariables, so T_M ⊆ FO ⊆ DT°.
* Start: C(x, conf(q₀, (e, x), (e, z), (e, e))).
* One template per transition (state, three read symbols, and, for each tape whose head moves left, the left neighbour or the left end): C(x, pattern) → C(x, result).
* Accept: C(x, pr(t_{q_acc}, y)) → R(x). Reject: C(x, pr(t_{q_rej}, y)) → ¬R(x).

Then:
* (i) T_M has O(|Q_M|) templates, each of size O(log |Q_M|).
* (ii) T_M ∪ Γ_{f_V} is consistent. For words, T_M ⊢ R(t_w) iff w ∈ X_acc, and T_M ⊢ ¬R(t_w) iff w ∈ X_rej.
* (iii) If V(w, c) ∈ {acc, rej} after τ steps, the corresponding literal has a K-derivation from ⋃inst(T_M) by MP only, with 2τ + 4 lines, each of size ≤ c_M(τ + |w| + |c| + 1). Its size is therefore ≤ c'_M(τ + |w| + |c| + 1)².

*Proof.*
* (iii) Cite the Start instance with x := t_w and z := t_c. Then, τ times, cite the transition instance at the current configuration and apply MP. Finally cite the Accept or Reject instance and apply MP. Configuration terms have size O(τ + |w| + |c| + log |Q_M|).
* (ii) Take the free term algebra H on L's function symbols, with equality the identity. Let C^H be the closure of the Start instances under the transition templates, the least Herbrand model of the definite part.
  * *Determinism.* Distinct templates have disjoint patterns, so the C-facts derived from Start(x, z) form a single run of configuration terms.
  * *Word inputs.* For x = t_w and z = t_c it is the run of M on (w, c).
  * *Junk.* If x or z has a node that is not s0, s1, s2 or e, the run follows M on the word prefixes (wp(x), wp(z)), the longest prefixes over s0, s1, s2. It gets stuck when a head reaches the junk node, where M would read a blank. If it halts first, M on (wp(x), wp(z)) makes the same run, because the junk cell is never read.
  * *Model 1.* R^H := {t_w : w ∈ X_acc} ∪ {non-word x : some run from x accepts}.
    * Accept holds by construction.
    * Reject holds on words, since X_acc ∩ X_rej = ∅.
    * Reject holds on junk x: accepting and rejecting runs from x would give V(wp(x), ·) = acc and = rej. Then wp(x) is a word over {0, 1}, since V outputs ⊥ on other inputs, and this contradicts the consistency of f_V.
    * Γ_{f_V} holds.
  * This gives consistency, and T_M ⊢ R(t_w) ⇒ w ∈ X_acc.
  * *Model 2.* R on words := the complement of X_rej, the same rule on junk. It gives T_M ⊢ ¬R(t_w) ⇒ w ∈ X_rej.
  * The converses are (iii).
  * Template instances with parameters are read under closure; in H a closure holds iff all its closed instances do, and those are instances again.
* (i) Count. ∎

*Universal version.* For V given as a U-program, take for M a fixed universal 4-tape machine, with V's code written on the fourth tape by the Start template. Then ℓ(T_V) ≤ ℓ(T_{U₀}) + a|V| bits in the template code (`def:model:prior`), and τ is polynomial in V's running time (a universal simulation with polynomial overhead, as time-followup's (S); standard, not checked for a particular U).

*Computed* (`c5_templates.out`). A 3-tape verifier for "w contains 11": acceptance certificate 0^i, rejection certificate 1. T_M has 57 templates.
* 66901 (word, certificate) pairs with |w| ≤ 9: every derivation is valid in K, with axioms recognised by an independent pattern matcher, and has the right last line. The template run equals a direct simulation of M. size ≤ 15·(τ + |w| + |c| + 1)².
* 4800 runs on junk terms: no decided run disagrees with M on the word prefixes, and no junk input has both an accepting and a rejecting run.
* No configuration matches two templates.

**Corollary 6.2 (`cor:time:hard` is tight up to polynomials on literal data) [proved, given `thm:time:ntime` and Prop 6.1].** On literal sequences, with word terms and B = ∅:
* (i) If a finite DT° theory T with T ∪ Γ_{f_X} consistent derives every datum within size ℓ(|w|) (ℓ ≥ m time-constructible), then X ∈ NTIME(ℓ^{c_1}) ∩ coNTIME(ℓ^{c_1}). This is `thm:time:ntime` for X and for its complement.
* (ii) If X and its complement are in NTIME(τ), τ(m) ≥ m, then some finite FO-pattern theory T with T ∪ Γ_{f_X} consistent derives every datum within size c(τ(|w|) + |w|)². The verifier follows the guesses of the two nondeterministic machines, with a tag bit, in time O(τ) and with certificates of length ≤ τ + 1, over a binary alphabet [standard].
* (iii) The soft charges are polynomial in τ on these data:
  * the graded score: −log₂ P^g_T(φ_w) = κ ℓ_T(φ_w) + log₂ Z_T ≤ κ·c'(τ + |w|)², since the explicit code has no indices or parameters and Z_T ≤ 1;
  * L1^σ: −ln P^σ_T(φ_w) ≤ −ln Pr(π) + κ|π| ≤ C_T(τ + |w|)². Here π is the MP chain read as an L1 tree, each body node costs at most ln(1/q_min) under the full-support grammar, and Z^σ_T ≤ 1.

So the derivation size that finite DT° theories need on D^X is polynomially related to the NTIME ∩ coNTIME complexity of X. The lower bounds of `cor:time:hard` and `prop:time:sigma`(b), (c) are therefore tight up to polynomials on such data. This is the matching upper bound that time-followup Rem 4.4(ii) left open, for literal data.

**Corollary 6.3 ((a1) inside the template class) [proved for deterministic machines; proof sketch for alternating ones].** For a deterministic M deciding X in space s(m) ≥ m (and halting without a verdict on inputs outside {0,1}*), the same construction without the certificate tape gives a finite FO-pattern theory, consistent with Γ_{f_X} by the same model. Its derivation of each datum has every line of size ≤ c_M(s(|w|) + 1). So under (a1) finite DT° theories fit DSPACE(h/c), and by Theorem 4.2 (linear-time matching, `thm:setting:matching` of AS) at most DTIME(2^{O(h log h)}). For alternating machines, universal steps need two premises, C(x, c_1) → (C(x, c_2) → C(x, c)), with c_1 and c_2 computed by patterns. Not written out.

**Remark 6.4 (the gap) [open unless marked].**
1. *Non-literal data.* The device works because the datum's argument term is the verifier's input. For a datum that is an arbitrary sentence, a template has to produce φ itself from a term that codes φ. Code to formula is not a template operation, and `prop:time:notemplate` shows that the Hänni-style link Acc_f(⌜φ⌝) → φ has no non-ground DT° template. Open: do finite DT° theories realise certificate labellers on non-literal data with polynomial derivations, for example over PA with L = L_A, where `prop:time:collapse`'s ρ_{f,n} realises Σ_n-sound assigners but with unbounded derivation size (`rem:time:upper`)?
2. *Description length.* ℓ(T_V) ≤ a|V| + b is linear, not |V| + c, like ρ_{f,n} (`prop:time:collapse`). An additive version is not shown.
3. *Conservativity.* T_M proves exactly Γ_{f_V} among the word literals (proved). Whether it is conservative over Γ_{f_V} for all C-free sentences is not shown. Model §10 problem 15 asks for a set "with the same consequences"; Prop 6.1 answers its literal-consequence variant positively, for assigners with polynomial-time certificate verification.
4. *The paper's encoding.* The paper's φ_w = R(num(w)) needs a conversion phase from binary numerals to word terms by templates. **[proof sketch]**: templates that match ((SS0)·x) + 0 and ((SS0)·x) + S0 peel off one bit each.

---

## 7. Checks

| script | what it checks | result |
|---|---|---|
| `checks/kcore.py` | shared implementation of K (de Bruijn, parameters), independent axiom recognisers (A4 by matching), derivation checker, normalisation, the prefix code | module |
| `checks/c1_subformula.py` → `.out` (seed 20261010) | Lemmas 1.1, 2.1, 2.2, Prop 2.4: 300 random raw derivations, 1800 normal ones; occurrence map, independent sits-at search, injectivity, bounds; necessity; tightness | no failure; max size/ΣF = 0.85 on random derivations, → 0.9987 on the tightness family; size/(M + \|φ\|)² → 0.1663 (1/6) |
| `checks/c2_lpf_certificates.py` → `.out` (seed 1009) | Example 5.6: Pratt-certificate verifier for least-prime-factor data; sizes, work, tampering | all pass; cert bits ≤ 0.94 b², work ≤ 0.07 b³ |
| `checks/c3_short_axioms.py` → `.out` (seed 4711) | Lemma 4.1, Thm 4.2 (closure at H = 9, soundness by rebuilding, completeness against random short derivations, renaming); Prop 4.3 (counter, QBF) | all pass after fixing a vacuous-Gen renaming bug in the rebuilder (Lemma 4.1(a) states the point) |
| `checks/c4_cert_embedding.py` → `.out` (seed 99) | Thm 5.2 (b): θ_c, exact symbol and bit sizes; (a): encoder/decoder, verifier recovers derivations | all pass |
| `checks/c5_templates.py` → `.out` (seed 271828) | Prop 6.1 for a 3-tape verifier: validity, verdicts, run = simulation, size bound, junk soundness, determinism | all pass |

The scripts check constructions, bounds and arithmetic on finite instances. The theorems are proved in the text.

---

## 8. Open problems

1. **Soft equivalence at one rate.** Is ℓ_{AI^σ_κ}(D) ≤ ℓ_{FIcert^σ_{κ,κ}}(D) + O(1) for all D (r = 1 in Theorem 5.2(b))? Proposition 5.3 shows κ is the only candidate. The generative and normalised versions (Remark 5.7) are open as well.
2. **The log factor in (a1).** The fit class contains DTIME(2^{h}) up to a constant factor in the budget and is contained in DTIME(2^{O(h log h)}) (Cor 4.4(v)). Counting parameters by their bit length should remove the log; this is not checked.
3. **(a2) in one sort without a fresh symbol** (L = L_A, B = PA, consistent unsound f): the same as time-followup open problem 1 (Cor 4.9).
4. **Templates on non-literal data**; additive description length; conservativity (Remark 6.4).
5. **Least-size tightness of Corollary 2.3**: is ℓ_min of order (M_min + |φ|)² for some family?
6. **Material in other calculi**: which material measure is polynomially equivalent to proof size in natural deduction or sequent calculus (Remark 2.7), and in a Hilbert calculus with ∀E as a rule (Remark 2.5)?
7. **Hänni's S against reading (b)** on literal sequences: time-followup Rem 4.5(iii), unchanged. Against (a1), Proposition 4.5 settles it.

---

## 9. Status of every claim

| claim | status |
|---|---|
| §0.1 answer | summary of the results below |
| Lemma 1.1 | proved; computed (`c1`) |
| Fact 1.4 | cited (time-followup Cor 4.3(c), proof) |
| Lemma 2.1 | proved; computed (`c1`) |
| Lemma 2.2 | proved; computed (`c1`) |
| Cor 2.3 | proved |
| Prop 2.4 | proved; computed (`c1`); least-size tightness open |
| Rem 2.5 | proved; computed (`c1`) |
| Prop 2.6 | proved, given `thm:time:ntime`, Prop 4.8, and the time hierarchy (known) |
| Rem 2.7 | first part proved (Prop 2.6's argument); cut-free remark not checked |
| Thm 3.1 | proved, given time-followup Thm 4.2 |
| Cor 3.2 | proved, given time-followup Cor 4.3 |
| Lemma 4.1 | proved; computed (`c3`) |
| Thm 4.2 | proved; computed (`c3`, Part A) |
| Prop 4.3 | proved; computed (`c3`, Parts B, C, illustrations) |
| Cor 4.4 | proved, given Chandra–Kozen–Stockmeyer and the time hierarchy (known); (iv) second part open |
| Prop 4.5 | proved, given CKS and time-followup Thm 3.2(c); for S, given Hänni's running-time claim (his, not checked) |
| Prop 4.6 (i) | proved |
| Prop 4.6 (ii) | proved, given time-followup Prop 2.5(c) and the coding assumption stated |
| Prop 4.7 | proved, given `prop:time:twosorted` (with B = Q ∪ B_L) |
| Prop 4.8 | proved, given the Q facts and a Δ₀ step relation (known; reference not checked) |
| Cor 4.9 | proved, given Prop 4.8; L = L_A open |
| Rem 4.10 | (a1), (b) proved (Thm 4.2, Cor 3.2); (a2), (b2) proof sketch |
| Rem 4.11 | proved |
| Thm 5.2 | proved; computed (`c4`) |
| Prop 5.3 | proved; r = 1 open |
| Cor 5.4 | proved |
| Rem 5.5 | (a) as stated proved; necessity of the log factor not settled |
| Example 5.6 | computed (`c2`); Pratt's bound known |
| Rem 5.7 | open |
| Prop 6.1 | proved; computed for one verifier (`c5`); universal version given a polynomial universal simulation (standard) |
| Cor 6.2 | proved, given `thm:time:ntime` and Prop 6.1; (iii) given the paper's definitions of L1^σ and the graded score |
| Cor 6.3 | proved for deterministic machines; proof sketch for alternating ones |
| Rem 6.4 | open, except item 3's literal-consequence statement (proved) and item 4 (proof sketch) |

---

## References

* E. Mendelson, *Introduction to Mathematical Logic*, 4th ed., 1997: the calculus K [known (chapter and numbering not checked)].
* W. Craig, "On axiomatizability within a system", *J. Symbolic Logic* 18 (1953) 30–32 [known].
* A. K. Chandra, D. C. Kozen, L. J. Stockmeyer, "Alternation", *J. ACM* 28 (1981) 114–133: ASPACE(s) = ⋃_c DTIME(2^{cs}) for s ≥ log n [known (not checked)].
* J. Hartmanis, R. Stearns (1965); F. Hennie, R. Stearns (1966): the deterministic time hierarchy [known (exact form not checked)]; S. Cook (1972), J. Seiferas, M. Fischer, A. Meyer (1978), S. Žák (1983): the nondeterministic hierarchy, as cited in the paper [known (not checked)].
* V. Pratt, "Every prime has a succinct certificate", *SIAM J. Comput.* 4 (1975) 214–220 [known].
* P. Smith, *An Introduction to Gödel's Theorems*, 2nd ed., 2013: Σ₁- and Δ₀-completeness of Q and the bounded lemma [known (numbering not checked)]; P. Hájek, P. Pudlák, *Metamathematics of First-Order Arithmetic*, 1993: Δ₀ definitions of computations [known (not checked)].
* D. Prawitz, *Natural Deduction*, 1965; G. Gentzen (1935): normalisation and cut elimination with the subformula property, for Remark 2.7 [known (not checked)].
* K. Hänni, `../../prior/hanni-solomonoff-axiom-induction.md`, `../../prior/hanni-polytime-solomonoff.md` (working notes).
