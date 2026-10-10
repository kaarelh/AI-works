# Track "short-derivations": derivations from short axioms — final record

*Follow-up to paper Section 6 (`../../../paper/sections/time.tex`, `app-time.tex`), to the model track's §6, §9.3 and §10 (`../model/notes-final.md`), and to the time-followup track in its final form (`../time-followup/notes-final.md`, cited as "TF" with its final numbering). This file is the complete, self-contained final record of the track. It was written after two referee reports: `referee-logic.md` ("RLg", proof theory; its code is in `referee_logic/`) and `referee-complexity.md` ("RC", complexity; its code is in `referee_complexity/`). It supersedes `notes.md`, which is kept unchanged as the pre-referee version. Item numbers follow `notes.md`. Items added in the revision have new numbers: Remark 1.5, Definition 1.6, Proposition 3.4, Propositions 4.12 and 4.13, Remarks 5.8 and 5.9, and all of §7. Scripts are in `checks/`; each is seeded or deterministic and writes `<name>.out` next to itself; `checks/kcore.py` is the shared implementation of K.*

*The question.* Kaarel Hänni's proposal, verbatim:

> "hmm interesting point. but perhaps we can make AI actually interestingly time-limited by requiring that given statements have derivations from short axioms?"

The answer, with exact scopes, is the last section (§13).

**Status tags** (as in the model and time-followup tracks).
* **[proved]**: full proof here. "Proved, given X": the proof uses the cited result X.
* **[proved, conditional on H]**: full proof from the stated complexity hypothesis H.
* **[proof sketch]**: the argument is given; the steps not written out are named.
* **[known]**: published, with reference; **(not checked)** means recalled, not checked against the source in this session.
* **[computed]**: checked by a script; the output file is named.
* **[conjecture]**, **[open]**.
* **[refuted]**: a claim shown false, kept with its counterexample.

**Labels.** Paper labels are cited as in the paper: `def:time:inducers`, `thm:time:equiv`, `prop:time:fiall`, `prop:time:cheap`, `prop:time:twosorted`, `prop:time:single`, `prop:time:collapse`, `prop:time:notemplate`, `thm:time:ntime`, `cor:time:hard`, `prop:time:sigma`, `rem:time:upper`, `conj:time:polytime`, `def:model:calculus`, `def:model:variants`, `def:model:lone`, `def:model:prior`, `rem:model:graded`. "DT°" is the paper's template class `\DT` (`paper/preamble.tex`, line 57: `\newcommand{\DT}{\mathrm{DT}^{\circ}}`); "FO" is its first-order-pattern subclass. "AS Thm 2.5" is the matching theorem the paper cites. "TF Thm 4.2" etc. refer to `../time-followup/notes-final.md`; "Hänni's S" is the predictor of `../../prior/hanni-polytime-solomonoff.md`.

**What changed after the referees.** Neither referee found a fatal issue. RLg found 1 major and 12 minor issues; RC found 3 major (one shared with RLg) and 14 minor issues. Every one is resolved; the map is the verification log (§12). The main changes:
* **Parameter indices (RLg-M1, RC-M3).** A parameter p_N counts as one symbol whatever N is, and a decider can read N. So an index can carry a certificate that no size measure charges (Prop 7.1). Definition 1.2 now requires that B ∪ A_p be closed under permutations of the parameters (F1). Every construction here satisfies (F1), and every theorem stands under it. New in this revision: without (F1), in the paper's convention (membership time measured in symbols), `thm:time:ntime` and the coarse fit classes still hold, by a truncation lemma (Lemma 7.2, Thm 7.4). The fine bounds (the clock 2^{O(h log h)}, Theorem 3.1(iii)) need (F1). With membership time measured in bits, the fit classes fail without (F1).
* **The soft rate (RC-M1).** "Whether r can be 1 is open" is **[refuted]**. At a common rate κ, soft certificate function induction beats soft axiom induction by at least κ(2 + b_s·[b = 0]) bits per datum on every sequence, and no pair of rates gives a two-sided constant-regret equivalence (Thm 5.2(a), Prop 5.3).
* **Polynomial budgets (RC-M2).** The mixtures now charge the degree of membership time, as TF Cor 4.3(e) does, and the NP ∩ coNP / P = NP dichotomy is stated per sequence (Cor 3.2). Without the degree charge, FIcons_poly fails to dominate them unconditionally (Prop 3.4).
* **Readings (a2), (b2) (RLg-m1, m2).** A finite set of universally closed Horn sentences fits every decidable language sequence under these readings, with B = ∅ (Prop 4.12). The fit-class sentence of Prop 4.7 is corrected.
* **The subformula bound (RLg-m3).** The constant is 1/2: size ≤ (M + |φ|)(M + |φ| + 1)/2, attained by a vacuous Gen chain (Lemma 2.2, Prop 2.4(b)).
* **Self-checks.** The coding assumption behind Prop 4.6(ii) is withdrawn and replaced by an NTIME argument; Cor 4.9 now gives the same consequences, not only consistency; numerals ⌜φ⌝ are O(|φ|_bit), not O(|φ|), for sentences with indices. §12.4 lists them.

---

## 0. Results at a glance

| hypothesis (orchestrator's) | verdict | where |
|---|---|---|
| **S1(a)** short instances block Craig padding | **confirmed** for literal assigners under every reading: a derivation of φ_w^b from A^C_f contains (φ_w^b)^{∧(k+1)}, k = time_f(φ_w) | Prop 4.6(i) |
| **S1(a)** … but not Hänni's two-sorted schema, A^bd_f, or the reflection sentence ρ_{f,n} | **split by reading.** Under (a2) (only the theory's instances bounded), Hänni's two-sorted schema is not blocked [proved], and ρ_{f,n} is not blocked [proof sketch]. Under (a1) (logical instances bounded too), all three are blocked beyond deterministic time 2^{O(h log h)} [proved, under (F1)]. **A^bd_f is blocked under every reading** for hard languages [proved]: the hypothesis that it is not blocked is **refuted**. A one-sorted trace schema with a fresh relation symbol is not blocked under (a2) [proved] | Props 4.6–4.8, Rem 4.10, Thm 4.2 |
| **S1(a)** the computation moves into the number of proof steps | **confirmed, and bounded**: at most 2^{O(h log h)} distinct lines up to renaming; attained up to the log factor | Lemma 2.2, Thm 4.2, Prop 4.3 |
| **S1(a)** so AI with short axioms and unbounded derivations is still equivalent to unpenalised FIcons | **refuted for (a1)** with polynomial-time membership: at polynomial budgets the fit class is EXPTIME. **Confirmed for (a2)**: on literal sequences a finite Horn theory fits every decidable X; on arbitrary sentences, in two sorts and in one sort with a fresh relation symbol. Without a membership-time bound no reading imposes a time limit | Cor 4.4, Props 4.7, 4.8, 4.12, Rem 4.11 |
| **S1(b)** total material of the distinct instances, logical included, is a derivation-size bound | **confirmed**: M_min ≤ ℓ_min ≤ (M_min + \|φ\|)(M_min + \|φ\| + 1)/2, so axiom induction under (b) is certificate function induction (TF Thm 4.2; Thm 3.1 here). **Refuted** if the logical instances are free | Cor 2.3, Thm 3.1, Prop 2.6 |
| **S2** every line other than the conclusion and its Gen chain is a subformula of an instance used; size ≤ (M + \|φ\|)² | **confirmed, with corrections.** Axiom and MP lines are literal subformulas of instances used, for every derivation. Every Gen line, not only those on the conclusion's chain, is a subformula only up to abstracting parameters, and only in a derivation pruned to the conclusion's ancestors. Exact bound: size ≤ Σ F(α) ≤ (M + \|φ\|)(M + \|φ\| + 1)/2 over normal derivations; the constant 1/2 is attained. Repeated lines matter for the line count and the size bound, not for the per-line bound. Fails without counted logical axioms | Lemmas 2.1, 2.2, Cor 2.3, Prop 2.4, Rem 2.5, Prop 2.6, Rem 2.7 |
| **S3** soft version | **a correspondence up to a constant factor in the rate, not an equivalence.** Soft FIcert at the joint rate κ has loss ≤ soft AI's − κΣ(2 + b_s[b_i = 0]) + O(1); soft AI has loss ≤ soft FIcert's at rates (2b_sκ, 2κ) + κe_1 per datum + O(1), hence ≤ soft FIcert's at rate rκ = (31b_s + 26)κ + O(1). r = 1 is **refuted**: no pair of rates gives two-sided constant regret. No soft fit classes or separations are claimed | Thm 5.2, Prop 5.3, Cor 5.4, Rems 5.8, 5.9 |
| **S4** templates | **positive on literal data**: finite FO-pattern Horn theories realise every certificate verifier with derivations quadratic in its running time, and every consistent computable literal assigner; `cor:time:hard` is tight up to polynomials. **Gap**: non-literal data, linear (not additive) description length, conservativity | Prop 6.1, Cors 6.2, 6.3, Rem 6.4 |
| **(new)** parameter indices | (F1) is needed for the fine bounds and harmless for every construction. Without it, in the symbol-count convention, the coarse classes survive; in the bit-length convention they fail | §7 |

---

## 1. Setting

### 1.1 Syntax, K, sizes, encodings, normal derivations

The syntax is the paper's (`def:model:calculus`): formulas in closure-normal form with de Bruijn indices; parameters p_0, p_1, … are free names, read under universal closure; the connectives are ¬ and →, the quantifier is ∀; the signature L is **finite** and has equality. A *sentence* is a formula with no parameter and no dangling index; data and assigners concern sentences. A *line* is a formula with no dangling index (it may contain parameters).

**Sizes.** The *size* |χ| is the number of nodes (a quantifier, a connective, a function or relation symbol, =, a constant, an index and a parameter each count one; `app-time.tex`). A *formula node* of χ is a node of formula sort. N(χ) is the number of formula nodes, and F(χ) := Σ over formula nodes v of |χ_v|, where χ_v is the subtree at v.

**Encodings.** Programs read a formula as a string of cells: its preorder tokens, one cell each, except that an index #k (a parameter p_N) is a marker cell, the binary expansion of k + 1 (of N + 1), one bit per cell, and an end cell. So the bit length of a formula exceeds its size by the lengths of its index and parameter numerals. **Membership time is measured against the node size |χ|** (the paper's convention: `thm:time:ntime` bounds membership time by O(n^e) in the size). This is the *node-count reading*; §7 also treats the *bit-length reading*.

**Gen and abstraction.** abs_p(χ) replaces each occurrence of the parameter p at binder depth d by the index d. Gen_p(χ) := ∀ abs_p(χ). If p does not occur in χ, Gen_p(χ) = ∀χ (vacuous). |Gen_p(χ)| = |χ| + 1.

**K** (`def:model:calculus`; `checks/kcore.py`). Logical axioms:
* A1–A3 (propositional; A3 is (¬C → ¬B) → ((¬C → B) → C));
* A4: ∀B → B[t], with t index-free (so t is always free for the variable);
* A5: ∀(B → C) → (B → ∀C), with B closed;
* reflexivity: ∀(#0 = #0);
* substitutivity: p = q → (B → B'), where B' arises from B by replacing some occurrences of the parameter p by q.

Rules: MP (from A and A → B infer B) and Gen (from χ infer Gen_p(χ)). A *derivation* from a set Ax of nonlogical axioms is a sequence of lines, each with one justification: axiom (logical, or in Ax), MP(i, j) (line j is line i → this line), or Gen(i, p). Gen has no side condition: there are no hypotheses, only axioms read under closure.
* size(π) := Σ |lines|, axioms included, as in `def:model:calculus`.
* I(π) := the set of distinct formulas of the lines justified as axioms (logical and nonlogical).
* M(π) := Σ_{α ∈ I(π)} |α|, the *material*; M_nl(π) := the same sum over the distinct nonlogical instances.

**Sits at.** Let α be a formula and v a formula node of α. A line λ *sits at v with k abstractions* if the k nodes directly above v are quantifier nodes, the topmost being u, and there are parameters q_1, …, q_k with α_u = Gen_{q_k}(⋯Gen_{q_1}(λ)⋯). Then α_v is λ with the occurrences of q_1, …, q_k replaced by indices pointing above v, and |λ| = |α_v|. With k = 0, λ = α_v is a literal subformula.

**Normal derivations.** A derivation is *normal* if its lines are pairwise distinct formulas and every line except the last is a premise of a later line. Following uses forward from any line then reaches the last line.

**Lemma 1.1 (normal form) [proved; computed: `c1`; `referee_logic/r1`].** Every derivation π from Ax containing a line φ can be turned into a normal derivation π' from Ax whose last line is φ, whose lines are lines of π, with I(π') ⊆ I(π) and size(π') ≤ size(π).

*Proof.*
* Delete every line whose formula occurred earlier, and redirect each citation of it to the first occurrence. The first occurrence is earlier, so all justifications stay valid.
* Cut after the (now unique) line φ, and keep only the ancestors of φ, in order. A kept line other than φ is a premise of a kept line, which is later.
* Nothing is added, and no justification changes. ∎

### 1.2 The inducers and the readings of Hänni's proposal

The background is as in `def:time:inducers` and TF §1.1, §1.5: data D = ((φ_1, b_1), …, (φ_n, b_n)) of sentences, φ^1 := φ, φ^0 := ¬φ. B is a decidable background (decidable in polynomial time where §3 says so). A hypothesis is a program p (a word of the prefix code of TF §1.2) that decides a set A_p within time O(t(|χ|)); Ax_p := B ∪ A_p. Its weight is 2^{−|p|}, and losses are in the semimeasure convention: ℓ_X(D) := −log₂ W_X(D) + log₂ W_X(∅). AI[t, d] ("derivation size ≤ d(|φ_i|)") and FIcert[t', d'] (certificate function induction) are TF Def 1.3, transcribed to the syntax of §1.1, with (F1) below added to AI[t, d].

**Definition 1.2 (readings of "derivations from short axioms").** In each reading a hypothesis p must satisfy

> **(F1)** B ∪ A_p is closed under permutations of the parameters,

and p is compatible with D if B ∪ A_p is consistent and each φ_i^{b_i} has a K-derivation π_i from Ax_p with the stated property:
* **(a1)** every line of π_i justified as an axiom, logical or nonlogical, has size ≤ h(|φ_i|);
* **(a2)** every line of π_i justified as a member of Ax_p has size ≤ h(|φ_i|); logical instances are free;
* **(b)** M(π_i) ≤ g(|φ_i|);
* **(b2)** M_nl(π_i) ≤ g(|φ_i|).

The inducers are AI^{a1}[t, h], AI^{a2}[t, h], AI^{b}[t, g], AI^{b2}[t, g]. Where a reading needs no membership-time bound, t is omitted. Budgets h, g are nondecreasing; where a result needs them time-constructible it says so.

**Definition 1.3 (literal language sequences).** L contains a constant e, unary function symbols s0, s1 and a unary relation symbol R; t_w := s_{w_1}(⋯ s_{w_k}(e) ⋯) and φ_w := R(t_w), so |φ_w| = |w| + 2. For X ⊆ {0,1}*, D^X is the infinite sequence of the data (φ_w, [w ∈ X]) over all words w in length-lexicographic order, D^X_n its first n data, and f_X the assigner that accepts φ_w iff w ∈ X, rejects it otherwise, and abstains elsewhere. B = ∅ unless stated; Γ_{f_X} is consistent (the term algebra with R := {t_w : w ∈ X}).
* *Other encodings.* The paper's φ_w := R(num(w)) and TF Convention 1.5's φ_w := R(ν(w)), ν(w) := bin(1w), are other injective encodings computable and invertible in polynomial time.
  * The upper bounds on fit classes and the lower bounds on losses here hold for every such encoding: their proofs compute φ_w from w.
  * Constructions in which a membership-deciding program reads the word (Prop 4.3, Thm 3.1(iii), Prop 4.5) work for every such encoding, since the program decodes.
  * The template constructions of §6 and Prop 4.12 read the word off the term and need word terms; for numerals they need a conversion phase (Rem 6.4(4), proof sketch).

**Fact 1.4 (cited: TF Lemma 1.6) [proved there].** Let X be a mixture W_X(D) = Σ_h v(h)·[h compatible with D] with Σ_h v(h) < ∞, in which compatibility is inherited by prefixes. Then sup_n ℓ_X(D_n) < ∞ on an infinite sequence iff a single hypothesis with v(h) > 0 is compatible with every prefix. All hard inducers here are such mixtures. Call the set of X for which ℓ(D^X_n) is bounded the *fit class*. (For the soft inducers of §5 every loss diverges on every infinite sequence (Prop 5.3(i)), so they have no fit classes.)

**Remark 1.5 (hypothesis (F1)) [proved].**
* *Why.* A parameter is read under universal closure, so a renaming of parameters does not change the content of a formula; (F1) says that the theory does not depend on parameter names either. Without it, the index N of a parameter p_N, which costs one symbol, can carry a certificate of any length (Prop 7.1).
* *An equivalent convention.* One may instead let every decider see only can(χ), the formula with its parameters renamed to p_0, p_1, … in order of first occurrence. Since can(σχ) = can(χ) for every injective renaming σ, every hypothesis then satisfies (F1), and the decider's input has bit length O(|χ| log |χ|).
* *Every construction here satisfies (F1).* The parameter-free sets: A^C_f for literal f, A_f, A^bd_f, A^tr_f, A_M, the certificate sets A_V, Q, PA, PA + ρ_{f,n}, finite sets of sentences, Γ_f for assigners of sentences. Template instance sets: in the paper a body is a λ-term whose only free names are parameters, and whether parameters are admissible is fixed at each use (`model.tex`, the paragraph on templates). If they are, a renaming of an instance τθ is the instance τ(σ∘θ) with renamed bodies; if not, the instances of a template without parameters are parameter-free.
* *Where (F1) is used.* Lemma 4.1 and Theorem 4.2 (canonical closure), Corollary 4.4(v), Theorem 3.1(iii)(a), Theorem 5.2(c) and Remark 5.5. Theorem 3.1(iii)(a) uses it through the bit-code bound that TF Thm 4.2(a) takes for granted (RC-M3, addition 1). §7 says what survives without it.

**Definition 1.6 (polynomial budgets; degrees charged) [definition, following TF Cor 4.3(e)].**
* **AI^b[poly, poly]** mixes over triples (p, i, j), p a string. A_{p,i} := {χ : U_0(p, χ) = yes within (|χ| + 2)^i steps}, with U_0 the plain universal machine of TF §1.2. (p, i, j) is a hypothesis if B ∪ A_{p,i} satisfies (F1). It is compatible with D if B ∪ A_{p,i} is consistent and each datum has a K-derivation from B ∪ A_{p,i} of material at most (|φ_i| + 2)^j. Weight w(p)·2^{−2⌈log₂(i+1)⌉ − 2⌈log₂(j+1)⌉ − 2}, with w(p) := 2^{−|E(p)|} the Elias-coded weight of TF §1.2.
* **AI^{a1}[poly, poly]** is the same with "every axiom instance of size at most (|φ_i| + 2)^j".
* **FIcons_poly** is TF Cor 4.3(e): pairs (f, k), f clocked at (|φ| + 2)^k on U_0, B ∪ Γ consistent, weight w(f)·2^{−2⌈log₂(k+1)⌉ − 1}.

A constant factor in a running time is absorbed by raising the exponent, since |χ| + 2 ≥ 2. All three are mixtures as in Fact 1.4. `notes.md` mixed over pairs (p, j) without charging the membership degree; Prop 3.4 shows what that does.

---

## 2. The subformula lemma for K (S2)

Lemmas 2.1 and 2.2 are a form of the folklore subformula property of Hilbert-style derivations (no reference checked); the exact bounds and the treatment of Gen with de Bruijn indices are what is needed here.

**Lemma 2.1 (axiom and MP lines) [proved; computed: `c1`, `r1`].** In every derivation π (normal or not), every line justified as an axiom or by MP is a literal subformula of a line justified as an axiom, at or before it.

*Proof.* Induction on the line number.
* An axiom line is its own literal subformula.
* An MP line B has a major premise A → B, an earlier line with root →. Gen conclusions have root ∀, so the major premise is justified as an axiom or by MP. By induction it sits literally at a node u of an axiom line, and B is the right child of u. ∎

**Lemma 2.2 (normal derivations) [proved; computed: `c1`, `r1`, `r3`].** Let π be normal with last line φ, and J := I(π) ∪ {φ}, a set of distinct formulas. There is an injective map o from the lines of π to the formula nodes of the members of J (nodes of different members counted separately) such that:
* every axiom and MP line λ sits at o(λ) with 0 abstractions;
* every Gen line γ sits at o(γ) with k ≥ 0 abstractions, where q_1, …, q_k are the parameters abstracted along a chain of Gen steps that starts at γ.

Consequently:
* (i) every line has size ≤ max_{α ∈ J} |α|;
* (ii) #lines ≤ Σ_{α ∈ J} N(α) ≤ Σ_{α ∈ J} |α|;
* (iii) size(π) ≤ Σ_{α ∈ J} F(α) ≤ Σ_{α ∈ J} |α|(|α| + 1)/2 ≤ (M(π) + |φ|)(M(π) + |φ| + 1)/2, where the term |φ| can be dropped if φ ∈ I(π).

*Proof.*
* *Axiom and MP lines.* Define o by induction on the line number.
  * o(an axiom line α) := the root of α ∈ I(π).
  * o(an MP line B with major premise A → B) := the right child of o(A → B).
  * As in Lemma 2.1, the major premise is not a Gen line, so o(A → B) is already defined, and the subtree at o(λ) is λ itself.
* *Gen lines.* For a Gen line γ choose a forward chain γ = γ_0, γ_1, …, γ_k: γ_{i+1} is a line justified by Gen with premise γ_i, abstracting q_{i+1}, and the endpoint e := γ_k is the minor premise of some MP line or is the last line.
  * Such a chain exists. γ_i is used later unless it is the last line (normality). It cannot be a major premise (root ∀ against root →). If it is a minor premise, stop; otherwise it is a Gen premise, and continue. The line numbers increase, so the chain ends.
  * If e is the minor premise A of an MP line with major premise A → B, let o_e be the left child of o(A → B), a literal occurrence of e. If e = φ, let o_e be the root of φ ∈ J (here φ is a Gen line, so φ ∉ I(π)).
  * e = Gen_{q_k}(⋯Gen_{q_1}(γ)⋯), so from o_e one can descend through k quantifier nodes. Let o(γ) be the node reached. γ sits at o(γ) with k abstractions.
* *An observation.* If λ sits at v and the subtree at v has no dangling index, then λ equals that subtree: an abstracted parameter that occurred in λ would leave an index pointing above v.
* *Injectivity.* Suppose λ ≠ λ' and o(λ) = o(λ') =: v.
  * Both are axiom or MP lines. The subtree at v equals both, so λ = λ', against normality.
  * λ is an axiom or MP line, and λ' = γ is a Gen line. The subtree at v is λ, which has no dangling index. By the observation γ = λ, a contradiction.
  * Both are Gen lines, γ and γ', with chains of lengths k ≤ k' and endpoints e, e'.
    * The node u that lies k levels above v is o_e, and the subtree there is e.
    * γ'_k, the k-th line of γ'’s chain, sits at u (with k' − k abstractions). By the observation γ'_k = e = γ_k, so they are the same line.
    * Each line has one justification, so γ_{k−1} = γ'_{k−1} (the premise of their common Gen step), and so on down to γ = γ'. Contradiction.
* *Bounds.*
  * |λ| = |subtree at o(λ)|, which gives (i). Injectivity gives (ii).
  * Σ_λ |λ| ≤ Σ_{α ∈ J} Σ_{v formula node of α} |α_v| = Σ_{α ∈ J} F(α).
  * F(α) ≤ |α|(|α| + 1)/2 (RLg-m3). Each node u of α lies in the subtree of each of its formula-node ancestors, u included, so F(α) = Σ_u #{formula nodes that are ancestors of u or u itself} ≤ Σ_u (depth(u) + 1). List the nodes in breadth-first order u_1, …, u_n, n = |α|. The parent of a node of depth d ≥ 1 comes earlier and has depth d − 1, so the i-th node has depth at most i − 1. Hence F(α) ≤ Σ_{i ≤ n} i = n(n + 1)/2.
  * x ↦ x(x + 1)/2 is superadditive on nonnegative integers, so Σ_{α ∈ J} |α|(|α| + 1)/2 ≤ S(S + 1)/2 with S := Σ_{α ∈ J} |α| ≤ M(π) + |φ|. ∎

**Corollary 2.3 (material ≈ derivation size) [proved].** For every φ and Ax, let M_min(φ) and ℓ_min(φ) be the least material and the least size of a K-derivation of φ from Ax. Then

  M_min(φ) ≤ ℓ_min(φ) ≤ (M_min(φ) + |φ|)(M_min(φ) + |φ| + 1)/2.

More precisely, every derivation π of φ can be replaced by one with axiom instances among I(π) and size ≤ Σ_{α ∈ I(π) ∪ {φ}} F(α).

*Proof.*
* M(π) ≤ size(π), since every member of I(π) is a line of π.
* Conversely, normalise π (Lemma 1.1) and apply Lemma 2.2(iii); F is summed over I(π') ∪ {φ} ⊆ I(π) ∪ {φ}. ∎

**Proposition 2.4 (tightness for normal derivations) [proved; computed: `c1`, `r1`, `r3`].**
* (a) *An MP chain.* Let a, b be sentences and α_j := a → (a → ⋯ (a → b)) with j copies of a. The normal derivation a, α_k, α_{k−1}, …, α_0 = b has size |a| + (|a| + 1)k(k + 1)/2 + (k + 1)|b| and M = |a| + k(|a| + 1) + |b|. As k → ∞, size / Σ_{α ∈ J} F(α) → 1 and size / (M + |b|)² → 1/(2(|a| + 1)).
* (b) *A vacuous Gen chain* (RLg-m3). Let r, b be sentences with b ≠ r and the root of b not ∀, and β := ∀^k r → b. The derivation r (axiom), ∀r, …, ∀^k r (vacuous Gens), β (axiom), b (MP) is normal. Its size is (k + 1)|r| + k(k + 1)/2 + |β| + |b|, with |β| = |r| + k + 1 + |b|, and M = |r| + |β|. As k → ∞, size / Σ_{α ∈ J} F(α) → 1 and size / ((M + |b|)(M + |b| + 1)/2) → 1.

So the bound Σ F of Lemma 2.2 is attained up to 1 + o(1), and the constant 1/2 of Lemma 2.2(iii) cannot be lowered.

*Proof.* (a) is the arithmetic of the lines α_k, …, α_0 (sizes |b| + j(|a| + 1)). (b) The lines are distinct and each is used by the next, so the derivation is normal. J = {r, β, b} and F(β) = |β| + Σ_{j=1}^{k}(|r| + j) + F(r) + F(b), so Σ_J F − size = 2F(r) + 2F(b) − |r| − |b|, a constant. Both size and (M + |b|)(M + |b| + 1)/2 are k²/2 + O(k). ∎

* *Computed.* (a) `c1_subformula.out` (a = P(0), b = Q(0,0)): at k = 1000, size 1504505, Σ F = 1506508, ratio 0.9987, and size/(M + |φ|)² = 0.1663 against 1/6; `r1` reproduces the closed forms for k ≤ 200. (b) `referee_logic/r3_sharp_constant.out` (r = a, b = Q(a, a)): at k = 400, size/ΣF = 1.0000 and size/((M + |b|)(M + |b| + 1)/2) = 0.9662 → 1; and F ≤ |α|(|α| + 1)/2 holds on all 51485 closed formulas of size ≤ 9 and on 20000 random ones.
* Whether ℓ_min can be of order (M_min + |φ|)² for some family, which would make Corollary 2.3 tight for least sizes, is **[open]** and not needed. The family (b) is a candidate; that its least size is of order k² is not shown.

**Remark 2.5 (each hypothesis, checked) [proved; computed: `c1`, `r1`].**
* *MP order.* Only one property of MP is used: the conclusion is the right child of the major premise. The order of the premises in the derivation is irrelevant.
* *Gen chains.* Gen chains matter everywhere, not only at the conclusion. A Gen line that is the premise of another Gen line sits only with abstractions. Example: Q(p0, p1) ⊢ ∀Q(#0, p1) ⊢ ∀∀Q(#0, #1), the last used as an MP minor premise. The middle line contains p1 where the major premise has #1, so it is a subformula of nothing literally (`r1`: it sits at exactly one node, with one abstraction).
  * `c1` (1800 normal derivations from 300 random raw ones): 2992 Gen lines; 1537 chains end at once in an MP minor premise; 182 derivations have a chain of length ≥ 2 (the longest is 6). `r1` adds 2400 normal derivations and 12 targeted ones with a Gen line used twice; an independent exhaustive "sits" search with a maximum matching saturates every line.
* *Normality.* Lemma 2.1 needs no hypothesis (`c1`: 38760 raw axiom and MP lines; `r1`: 30132; no exception).
  * Without pruning to the ancestors of the last line, nothing holds for Gen lines: vacuous Gen chains can be arbitrarily long and unused (`c1`: 3103 of 9555 raw Gen lines sit nowhere; `r1`: 2079 of 5589).
  * Repeated lines matter for the line count (ii) **and for the size bound (iii)**, since size sums over lines; for example, P(0) cited 40 times and then one vacuous Gen gives 41 lines of total size 83, while ΣF over J is 7 (RLg-m4). The per-line bound (i) needs only that every line be an ancestor of the last.
* *The size measure.* With Mendelson's named variables (Gen: from B infer ∀xB) every Gen premise is a literal subformula of its conclusion. The same proof then gives k = 0 everywhere and the same bounds, with sizes in the named-variable measure.
* *A4.* A4 plays no special role in the proof. Its instances count in M with their full size |∀B| + |B[t]| + 1, every copy of the substituted term included. This is why material bounds derivation size.
  * In a calculus with ∀E as a rule (the paper's L1 trees, `def:model:lone`), the proof fails at ∀E, whose conclusion is not a subformula of its premise.
  * The translation in `prop:time:sigma`(b) turns each ∀E into an A4 instance and MP. It restores the bound if the ∀E conclusions are counted.

**Proposition 2.6 (logical axioms free: material does not bound size) [proved, given `thm:time:ntime`, Prop 4.8, `cor:time:hard`, Prop 6.1, and the deterministic time hierarchy (known)].** Let s(m) ≥ m be time-constructible.
* (i) Let L ⊇ L_A ∪ {e, s0, s1, R, C}, C a binary relation symbol, B = Q. There are a decidable X and an axiom set A such that:
  * A is parameter-free, and membership in A is decidable in polynomial time, of a degree independent of X;
  * Q ∪ A ∪ Γ_{f_X} is consistent;
  * every datum φ_w^{[w∈X]} has a K-derivation from Q ∪ A with M_nl ≤ a|φ_w| + b;
  * for infinitely many m some w ∈ X of length m has no K-derivation from Q ∪ A of size ≤ s(m).
* (ii) The same holds with B = ∅ and A a **finite** set of sentences, with M_nl bounded by a constant c_A, provided s(m + 1)^{c_1} = o(s(m)^{c_1 + 1}) as in `cor:time:hard`(a).

By Corollary 2.3, every derivation of such a φ_w has total material M with (M + |φ_w|)(M + |φ_w| + 1)/2 > s(m), so M > √(2s(m)) − |φ_w| − 1; the derivations of the third item have logical material at least that minus the nonlogical bound.

*Proof.*
* (i) Take A := A^tr_f of Prop 4.8 for a decider f of X. Prop 4.8 gives the polynomial membership (degree e independent of f), the consistency (B = Q ⊆ Th(ℕ), R interpreted as X) and the material bound (|φ_w|_bit = O(|φ_w|) for literals). `thm:time:ntime`, applied to T := Q ∪ A, shows: if all but finitely many w ∈ X had derivations of size ≤ s(|w|), then X ∈ NTIME(s^{c_e}) (exceptions in a table). Choose X decidable outside NTIME(s^{c_e}): NTIME(T) ⊆ DTIME(2^{O(T)}), and the deterministic hierarchy gives decidable sets outside DTIME(2^{s^{c_e + 1}}) [known]. The order of choices is sound: e does not depend on f, then c_e is fixed, then X, then f (RLg).
* (ii) Let X be the set of `cor:time:hard`(a) and A := T^∀_M of Prop 4.12 for a decider of X: a finite set of sentences, hence a finite ground DT° theory, consistent with Γ_{f_X}, with nonlogical instances of bounded size. `cor:time:hard`(a) applies to it. (The paper states it for num(w); its proof, guess and check, works for word terms.) ∎

**Remark 2.7 (natural deduction, sequent calculus, ∀E as a rule).**
* *Natural deduction and sequent calculus with cut* have no logical axioms. Their rules (→I, ∧I, ∀E with an arbitrary term, cut with an arbitrary cut formula) create formulas that are subformulas of no axiom used.
  * In these calculi "material" can only mean the nonlogical axioms used.
  * Proposition 2.6 applies to them, **with X re-chosen for each proof system** (RLg-m10): its lower bound holds for any proof system with polynomial-time proof checking, by guessing and checking, with c_e depending on the checking degree; its upper bound holds because the nonlogical axioms used are the same finite set, by completeness [proved].
* *Cut-free sequent calculus.* Every formula is a subformula of the end sequent up to the terms substituted by ∀L and ∃R, but lines are sequents, so the line count of Lemma 2.2(ii) has no direct analogue. Not pursued [not checked].
* *∀E as a rule*: see Remark 2.5. Whether material still bounds size polynomially in such a calculus is not settled here [open].

---

## 3. Reading (b): total material (S1(b))

**Theorem 3.1 (material ≡ derivation size ≡ certificates).** Assume L finite and B decidable in polynomial time and closed under permutations of the parameters; let t, g, d' be time-constructible and nondecreasing. Put G(m) := (g(m) + m + 1)(g(m) + m + 2)/2.
* (i) **[proved]** For every p and every φ^b: a derivation from Ax_p of size ≤ d has material ≤ d; a derivation with material ≤ g gives one of size ≤ (g + |φ^b|)(g + |φ^b| + 1)/2 ≤ G(|φ|).
* (ii) **[proved]** Hence, for every D, hypothesis by hypothesis and with the same weights,

  W_{AI[t, g]}(D) ≤ W_{AI^b[t, g]}(D) ≤ W_{AI[t, G]}(D).

* (iii) **[proved, under (F1)]** There are a constant c, a constant β (depending only on L) and a fixed polynomial k_0 such that for every D:
  * (a) W_{AI^b[t, g]}(D) ≤ 2^c·W_{FIcert[t⁺, G']}(D), with t⁺(m) := m^{k_0}·(t(m) + 1) and G'(m) := β·G(m)·log₂(G(m) + 2);
  * (b) W_{FIcert[t', d']}(D) ≤ 2^c·W_{AI^b[t'^#, g^#]}(D) and ≤ 2^c·W_{AI^{a1}[t'^#, h^#]}(D), with t'^#(m) := m^{k_0} + t'(m), g^#(m) := 2d'(m) + m + 31 and h^#(m) := d'(m) + m + 16.

This is a form of the correspondence between proof systems and NP [known: Cook and Reckhow 1979]: (a) is the fact that bounded-size provability from a polynomial-time axiom set is an NP predicate, and (b) is Craig's trick with certificates in place of padding. It is TF Thm 4.2 transcribed to this syntax, with the bit-code step made explicit and the material budget of (b) made linear.

*Proof.*
* (i) is Corollary 2.3 with |φ^b| ≤ |φ| + 1. (ii): the compatibility relations are nested, so the sums are.
* (iii)(a). Let Code_K be the prefix code of Definition 5.1 (2-bit line tags, Elias-γ codes of line, index and parameter numbers, b_s := ⌈log₂(σ_L + 6)⌉ bits per token). For a hypothesis p let V_p(φ, c) be: acc if c decodes to a K-derivation of φ from Ax_p with material ≤ g(|φ|); rej if it decodes to one of ¬φ with material ≤ g(|φ|); ⊥ otherwise.
  * *Short certificates exist.* Let p be compatible and φ_i^{b_i} have a derivation with material ≤ g. By Corollary 2.3 there is one, π, with instances among the old ones (so material ≤ g) and size s ≤ G(|φ_i|). π has at most s distinct parameters, Gen parameters included. By Lemma 4.1(a) an injective renaming maps them to p_0, …, p_{s−1} and gives a derivation with the same sizes; its axiom lines are in Ax_p **by (F1)**. Indices are < s and line numbers < s, so each token costs at most b_s + 2⌊log₂ s⌋ + 1 bits and each line at most 3(2⌊log₂ s⌋ + 1) + 2 more. Hence |Code(π)| ≤ β·s·log₂(s + 2) ≤ G'(|φ_i|) for a constant β depending on b_s.
  * *Time.* Decoding and checking a line takes polynomial time for the logical axioms (A4 by matching), for MP and Gen, and O(t(|χ|)) for membership via p (and polynomial time for B). So V_p runs in time O(t⁺(|φ| + |c|)).
  * *Consistency and weights.* B ∪ A_p is consistent, so no φ has both an acc and a rej certificate, and Γ_{f_{V_p}} ⊆ Cn(B ∪ A_p) is consistent with B. Every datum has a certificate of length ≤ G'(|φ_i|), so f_{V_p} labels it correctly. |V_p| ≤ |p| + c, and p ↦ V_p is injective.
  * *Without (F1)* the bit-code bound fails: Prop 7.1 gives a hypothesis whose shortest derivations have constant-factor symbol size and unbounded bit length (RLg-M1, `r2`).
* (iii)(b). Let Z := ∀(#0 = #0) (size 4), C_c := ν_{c_1}(⋯ν_{c_k}(Z)⋯) with ν_0 := ¬ and ν_1 := ∀ (vacuous), and θ_c := Z → (C_c → Z), an instance of A1 of size |c| + 14; c is read off θ_c uniquely (strip ¬ and ∀ until Z remains). For a hypothesis V of FIcert[t', d'] put
  A_V := {θ_c → φ : V(φ, c) = acc, |c| ≤ d'(|φ|)} ∪ {θ_c → ¬φ : V(φ, c) = rej, |c| ≤ d'(|φ|)}.
  * A_V is parameter-free, so (F1) holds. Membership: parse χ = θ → ψ, read c off θ, and accept iff (|c| ≤ d'(|ψ|) and V(ψ, c) = acc) or (ψ = ¬φ, |c| ≤ d'(|φ|) and V(φ, c) = rej). d' is time-constructible, so the length test stops after |c| + 1 steps. Time O(t'^#(|χ|)); the decider p_V has |p_V| ≤ |V| + c.
  * θ_c is valid, so each member is logically equivalent to its member of Γ_{f_V}, and each member of Γ_{f_V} has one. So Cn(B ∪ A_V) = Cn(B ∪ Γ_{f_V}), which is consistent.
  * The derivation θ_c (A1), θ_c → φ^b (axiom), φ^b (MP) has material |θ_c| + |θ_c → φ^b| = 2|c| + 29 + |φ^b| ≤ g^#(|φ|) and largest instance |c| + 15 + |φ^b| ≤ h^#(|φ|). ∎

**Corollary 3.2 (reading (b) at polynomial budgets, and against clocked FI).** Use Definition 1.6.
* (a) **[proved, under (F1)]** On literal language sequences the fit class of AI^b[poly, poly] is NP ∩ coNP.
  * ⊆: if (p, i, j) fits all of D^X, then V_p of Theorem 3.1(iii)(a) is a polynomial-time verifier with polynomial certificates, accepting exactly on X and rejecting exactly on its complement; so X ∈ NP ∩ coNP. (This is `thm:time:ntime` for X and its complement; §7 shows it holds without (F1) in the node-count reading.)
  * ⊇: combine verifiers for X and its complement into one V with a tag bit; f_V = f_X is consistent. Theorem 3.1(iii)(b) gives (p_V, i, j) with material ≤ 2d'(m) + m + 31 ≤ (m + 2)^j.
* (b) **[proved, conditional on NP ∩ coNP ≠ P]** For X ∈ (NP ∩ coNP) ∖ P, AI^b[poly, poly] has bounded loss on D^X, and ℓ_{FIcons_poly}(D^X_n) → ∞ (an (f, k) fitting all of D^X would put X in P, TF Cor 4.3(c)(i)).
* (c) **[proved, conditional on P = NP, under (F1)]** On every infinite labelled sequence of sentences, AI^b[poly, poly] has bounded loss iff FIcons_poly has.
  * *AI → FI.* If (p, i, j) fits all of D, then "∃c (|c| ≤ G'(|φ|) ∧ V_p(φ, c) = acc)" is an NP predicate of φ, and so is rejection. Under P = NP both are decided in polynomial time, which gives (f, k) with f = f_{V_p}; Γ_{f_{V_p}} ⊆ Cn(B ∪ A_{p,i}) is consistent, and f labels every datum.
  * *FI → AI.* If (f, k) fits all of D, Craig's decider for f clocked at (|φ| + 2)^k (TF Cor 4.3(a)) fits all of D: its set is parameter-free, its membership degree is fixed up to a constant that the exponent absorbs, and its derivations (cite (φ^b)^{∧(k'+1)}, then a substitution instance of a fixed propositional derivation of (B ∧ C) → B, then MP) have material ≤ size ≤ γ((|φ| + 2)^k + 1)(|φ| + 4) ≤ (|φ| + 2)^{j}, j = k + O(1). Those derivations are propositional apart from the cited axiom, so they transfer from TF's syntax to this one unchanged.
  * Then apply Fact 1.4 in both directions.
* (d) **[open]** The intermediate case (P ≠ NP but NP ∩ coNP = P), and uniform domination in either direction at polynomial budgets, even under P = NP (TF Cor 4.3(e3)).
* (e) **[proved, under (S) of TF §1.2, given the deterministic time hierarchy theorem (known)]** *Unconditional separation from clocked FI.* For every time-constructible τ there is a decidable X with ℓ_{FIcons_τ}(D^X_n) → ∞ while AI^b[t_C, d_{τ₃}] has bounded loss on D^X, for a fixed polynomial t_C and d_{τ₃}(m) := γ(τ₃(m) + 1)(m + 4), τ₃ a time-constructible bound slightly above a polynomial of τ (TF Cor 4.3(d), with the overheads made explicit there). The AI hypothesis is Craig's decider, whose derivations have material ≤ size ≤ d_{τ₃}.

So the separations of TF Cor 4.3 hold for reading (b), and in the same per-sequence form. "Not stronger if P = NP" means (c): the two inductors have bounded loss on the same sequences. It does not mean domination; with the membership degree uncharged, domination fails unconditionally (Prop 3.4).

**Remark 3.3 (reading (b2)).** If only the nonlogical material is bounded, reading (b2) is no time limit: a finite theory fits every decidable literal sequence (Prop 4.12), Props 4.7 and 4.8 give the equivalence with FIcons on arbitrary sentences, and Prop 2.6 shows that derivation size is then unbounded.

**Proposition 3.4 (uncharged degrees: FIcons_poly does not dominate) [proved, given the deterministic time hierarchy theorem (known) and the overhead polynomial q of TF Convention 1.5 (assumed there); RC-M2, TF Cor 4.3(e4)].** Let AI^b_unch[poly, poly] be `notes.md`'s mixture: pairs (p, j), p a decider satisfying (F1) with membership time O(|χ|^i) for some i (not charged), weight 2^{−|p|−2⌈log₂(j+1)⌉−1}, compatible if consistent and each datum has a derivation of material ≤ (|φ| + 2)^j. Let AI^{a1}_unch[poly, poly] be the same with every instance ≤ (|φ| + 2)^j. Then

  sup_D (ℓ_{FIcons_poly}(D) − ℓ_{AI^b_unch[poly,poly]}(D)) = ∞,

and the same for AI^{a1}_unch, whether or not P = NP.

*Proof.*
* *The languages.* For r ≥ 1 let N := 2^{2^r}. By the hierarchy theorem take X_N ∈ DTIME(m^N) ∖ DTIME(m^{N/2}) (m^{N/2}·log m^{N/2} = o(m^N)), decided by a program of length c₀ + O(log r) (the diagonal construction with N computed from r).
* *The AI side.* The decider p_N of {φ_w : w ∈ X_N} ∪ {¬φ_w : w ∉ X_N} is parameter-free, has polynomial membership time (degree about N, uncharged) and length c₀' + O(log r). Every datum is an axiom, so it has a one-line derivation whose material and only instance have size |φ_w^b| ≤ |φ_w| + 1 ≤ (|φ_w| + 2)^1. So (p_N, 1), of weight 2^{−|p_N|−3}, fits all of D^{X_N} under (b) and under (a1), and ℓ(D^{X_N}_n) ≤ |p_N| + 3 = c₀' + O(log r) for all n (the total weight is ≤ 1).
* *The FI side.* Fix b, depending only on q, such that q(C(m + 4)^k + m) ≤ m^{bk} for all k ≥ 1 and m ≥ m(C). If (f, k) fitted all of D^{X_N}, then X_N ∈ DTIME(m^{bk}) after a table for small m (TF Cor 4.3(c)(i), with |φ_w| = m + 2), so bk > N/2. By Fact 1.4's argument, W_{FIcons_poly}(D^{X_N}_n) tends to at most Σ_{k > N/(2b)} 2^{−2⌈log₂(k+1)⌉−1} ≤ b/N (TF Cor 4.3(e4); `../time-followup/checks/c4_revision.out`, Part C), while W_{FIcons_poly}(∅) is at least the weight of the always-abstaining clocked string. So ℓ_{FIcons_poly}(D^{X_N}_n) ≥ log₂(N/b) − O(1) = 2^r − O(1) for large n.
* The regret is at least 2^r − O(log r), unbounded in r. ∎

With degrees charged (Definition 1.6), (p_N, N + 1, 1) has weight about 2^{−|p_N| − 2·2^r}, and the argument gives nothing.

---

## 4. Reading (a): every instance short (S1(a))

### 4.1 Logical instances counted (a1): deterministic exponential time

**Lemma 4.1 (renaming; the canonical closure) [proved; computed: `c3`].**
* (a) For every injective renaming ρ of the parameters and every derivation π, ρ(π) is a derivation with the same sizes, in which every logical axiom line, MP step and Gen step stays valid; its nonlogical axiom lines are the ρ-images of those of π. Here ρ(π) applies ρ to every line and to the parameter named by every Gen step, vacuous ones included. So if Ax is closed under permutations of the parameters, ρ(π) is a derivation from Ax.
* (b) Let Ax be closed under permutations of the parameters. Let D_H be the set of formulas that have a derivation from Ax all of whose lines have size ≤ H, and let can(χ) rename the parameters of χ to p_0, p_1, … in order of first occurrence. Then can(D_H) is the least set S of canonical formulas of size ≤ H such that:
  * S contains can(α) for every axiom instance α of size ≤ H, logical or in Ax;
  * (MP) if X ∈ S has the form A → B and can(A) ∈ S, then can(B) ∈ S;
  * (Gen) if X ∈ S, p occurs in X or is one fixed parameter not in X, and |Gen_p(X)| ≤ H, then can(Gen_p(X)) ∈ S.

*Proof.*
* (a)
  * MP is preserved, since ρ(A → B) = ρA → ρB.
  * Gen: ρ(Gen_p(χ)) = Gen_{ρp}(ρχ), because ρ is injective, so no other parameter of χ goes to ρp. The parameter of a vacuous Gen must be renamed too; `c3` found that a reconstruction which forgets it breaks.
  * Logical schemas are closed under injective renaming. A1–A3 trivially; A4: ρ(∀B → B[t]) = ∀ρB → (ρB)[ρt]; A5: the side condition is about indices; reflexivity has no parameter; substitutivity: ρB' arises from ρB by replacing some occurrences of ρp by ρq.
  * A non-injective renaming can break Gen (`c3`, expected and found).
* (b) A finite injective renaming extends to a permutation, so by (a) D_H is closed under injective renamings, and χ ∈ D_H iff can(χ) ∈ D_H.
  * *S ⊆ can(D_H).* Induction on the construction of S. Axiom: one line. MP: X ∈ D_H and A ∈ D_H; concatenate their derivations and add B (|B| < |X| ≤ H). Gen: one more line.
  * *can(D_H) ⊆ S.* Induction on a derivation with all lines ≤ H. An MP line B from A and A → B: can(A → B) = σA → σB for the canonicalising renaming σ, and can(σA) = can(A) ∈ S, so can(σB) = can(B) ∈ S. A Gen line Gen_p(λ): can(λ) = σλ, Gen_{σp}(σλ) = σ Gen_p(λ) has the same canonical form, and all vacuous Gens give the same formula. ∎

**Theorem 4.2 ((a1) is decidable in deterministic time 2^{O(h log h)}) [proved, under (F1); computed: `c3`].** Let L have σ_L symbols, and let Ax := B ∪ A_p satisfy (F1), with membership decidable in time t_Ax.
* (i) There are at most (σ_L + 2H + 4)^{H+1} canonical formulas of size ≤ H.
* (ii) can(D_H) is computable in time 2^{O(H log H)}·(1 + t_Ax(H))^{O(1)}.
* (iii) Put H(φ) := max(h(|φ|), |φ| + 1), and let g_p(φ) := acc if φ ∈ D_{H(φ)}; rej if ¬φ ∈ D_{H(φ)} and φ ∉ D_{H(φ)}; abstain otherwise. Then:
  * g_p is a total assigner, |g_p| ≤ |p| + c, and Γ_{g_p} ⊆ Cn(Ax);
  * g_p runs in time 2^{O(H log H)}·(1 + t_Ax(H))^{O(1)};
  * g_p is FIcons-compatible with every D with which p is (a1)-compatible with budget h.
* (iv) Hence the fit class of AI^{a1}[t, h] on literal sequences (Fact 1.4) is contained in ⋃_{C} DTIME(2^{C·H log H}·(t(H) + 1)^{C}), with H = H(m) := h(m + 2) + m + 3.

*Proof.*
* (i) A canonical formula of size n is a preorder sequence of n tokens. Each token is a symbol of L, ¬, →, ∀, =, one of < H indices, or one of < H parameters. So there are ≤ (σ_L + 2H + 4)^n of size n; sum over n ≤ H.
* (ii) Let N be the bound of (i). Enumerate the N canonical formulas and test each against the logical schemas (polynomial; A4 by matching) and against Ax; since Ax is closed under permutations, χ ∈ Ax iff can(χ) ∈ Ax. Then close under the two rules of Lemma 4.1(b): at most N rounds, each O(N·poly(H)). The total is N^{O(1)}·(1 + t_Ax(H)) = 2^{O(H log H)}·(1 + t_Ax(H)). Running p inside a fixed wrapper costs a polynomial (TF (S), or any reasonable machine model).
* (iii) If p is (a1)-compatible, each φ_i^{b_i} has a derivation whose instances have size ≤ h(|φ_i|). Normalise it (Lemma 1.1, which does not enlarge I). By Lemma 2.2(i) every line then has size ≤ max(h(|φ_i|), |φ_i^{b_i}|) ≤ H(φ_i), so φ_i^{b_i} ∈ D_{H(φ_i)}. B ∪ A_p is consistent, so φ_i^{1−b_i} ∉ D_{H(φ_i)}, and g_p labels φ_i with b_i. Γ_{g_p} ⊆ Cn(Ax) is consistent with B.
* (iv) By Fact 1.4 and (iii), with |φ_w| = m + 2. ∎

*Computed* (`c3_short_axioms.out`, Part A): the closure in a language {a/0, P/1, c, =} at H = 9 has 901 members among 59055 canonical formulas. All 901 rebuilt derivations validate with lines ≤ H, and all 12698 lines of 400 independently generated short-line derivations are in the closure.

**Proposition 4.3 (ground axioms simulate alternating space) [proved; computed (deterministic counter and QBF illustrations): `c3`].** Let L ⊇ {e, s0, s1, R, C, C'} with C, C' binary relation symbols, and B = ∅. Let M be an alternating Turing machine that decides X in space s(m) ≥ m, has branching ≤ 2, and halts on every computation path. Encode configurations of M on w (state, input-head position, work tape with head) as words of length ≤ c_M(s(|w|) + 1), written as terms t_c. Let A_M consist of the ground sentences
* C(t_w, t_c) for accepting halting c, and C'(t_w, t_c) for rejecting halting c;
* C(t_w, t_{c'}) → C(t_w, t_c) for an existential c with successor c';
* C(t_w, t_{c_1}) → (C(t_w, t_{c_2}) → C(t_w, t_c)) for a universal c with successors c_1, c_2;
* the duals for C', with the roles of existential and universal exchanged;
* C(t_w, t_{init(w)}) → R(t_w) and C'(t_w, t_{init(w)}) → ¬R(t_w).

Then:
* membership in A_M is decidable in time polynomial in |χ|, by a decider of length |M| + c; A_M is parameter-free;
* A_M ∪ Γ_{f_X} is consistent;
* every datum φ_w^{[w ∈ X]} has a K-derivation from A_M that uses only MP, has at most 2^{c'_M(s(|w|)+1)} lines, and has every line of size ≤ c''_M(s(|w|) + 1).

*Proof.*
* *Membership.* Parse the shape, decode the configurations, and check the local transition relation of M on w, read off the input head position. This is polynomial.
* *Consistency.* Take the free term algebra on L's function symbols, with C := {(t_w, t_c) : c is accepting for M on w}, the least fixed point of the alternating acceptance condition, C' the same for rejecting, and R := {t_w : w ∈ X}. The axioms are exactly the closure conditions of these fixed points, together with the two output axioms, which hold because M decides X. On paths that all halt, every configuration is accepting or rejecting and not both (induction on rank).
* *Derivation.* For w ∈ X, list the accepting configurations of an accepting computation tree from init(w) in order of fixed-point rank. Derive C(t_w, t_c) for each: a halting fact is cited; an existential or universal step is cited, followed by one or two MP steps. Finish with the output axiom and MP. The case w ∉ X is dual.
* *Sizes.* Every line is an atom or a subformula of an axiom instance, of size O(s(|w|)). There are at most #configurations·O(1) = 2^{O(s)} lines. No logical axiom is used. ∎

The construction works for any encoding of Definition 1.3, with t_w replaced by the encoding term: the decider decodes. *Computed* (`c3_short_axioms.out`): Part B, a k-bit counter as ground axioms, 2^k − 1 MP steps with every instance of size 2k + 5 (k ≤ 10); Part C, QBF evaluation by existential and universal ground axioms and the dual C', 80 random QBFs with n ≤ 8, all verdicts correct, up to 255 lines with instances of size ≤ 31.

**Corollary 4.4 ((a1) at polynomial budgets is EXPTIME).** Use AI^{a1}[poly, poly] of Definition 1.6.
* (i) **[proved, under (F1), given Chandra–Kozen–Stockmeyer (known)]** On literal sequences its fit class is exactly EXPTIME.
  * ⊆: Theorem 4.2(iv) with polynomial h and t.
  * ⊇: EXPTIME = APSPACE = ⋃_k ASPACE(m^k) [known: Chandra, Kozen, Stockmeyer 1981 (not checked)]; with a clock, all computation paths halt. Prop 4.3 with s = m^k gives a parameter-free hypothesis with membership clocked at (|χ| + 2)^i for some i and instances of size ≤ (|φ_w| + 2)^j for some j.
* (ii) **[proved, under (F1), given the time hierarchy (known)]** (a1) is a genuine time limit. For all computable h, t there is a decidable X such that ℓ_{AI^{a1}[t,h]}(D^X_n) → ∞, while unpenalised FIcons has bounded loss (the hypothesis f_X). *Proof.* Let T(m) := 2^{H²}·(t(H) + 1)^H with H = h(m + 2) + m + 3. T is computable and eventually exceeds 2^{CH log H}·(t(H) + 1)^C for every C. Choose a decidable X ∉ DTIME(T) (diagonalisation against T-clocked machines). By Theorem 4.2(iv) no single hypothesis fits D^X, so by Fact 1.4 the loss tends to ∞.
* (iii) **[proved, given CKS and the hierarchy theorem]** Unconditionally, AI^{a1}[poly, poly] has bounded loss on some D^X on which FIcons_poly does not: take X ∈ EXPTIME ∖ P. This is a per-sequence separation (RC-M2).
* (iv) **[proved; the condition itself open]** W_{AI^b[t,g]}(D) ≤ W_{AI^{a1}[t,g]}(D) for every D, and likewise for the mixtures of Definition 1.6, since material ≤ g implies that every instance is ≤ g. So NP ∩ coNP ⊆ EXPTIME, as it must be. The two readings have different fit classes at polynomial budgets **iff NP ≠ EXPTIME** (RLg-m6): NP ∩ coNP = EXPTIME iff EXPTIME ⊆ NP (EXPTIME is closed under complement and contains NP) iff NP = EXPTIME. Whether NP ≠ EXPTIME is **[open]**. Theorem 3.1(iii)(b) also puts FIcert[t', d'] inside AI^{a1}[t'^#, d' + m + 16].
* (v) **[proved, under (F1), given CKS]** *The deterministic clock.* Let h be space-constructible, nondecreasing, with h(m) ≥ m (RLg-m5: every derivation of φ_w contains an instance of size ≥ |φ_w|, the datum itself or an instance containing the major premise of the last MP, and Prop 4.3 needs s ≥ m). Every X ∈ DTIME(2^{h(m)}) is in the fit class of AI^{a1}[poly, c_X·h] for a constant c_X, since DTIME(2^h) ⊆ ASPACE(h) [CKS] and Prop 4.3 applies. The fit class of AI^{a1}[poly, h] is contained in ⋃_C DTIME(2^{C·H log H}), H = h(m + 2) + m + 3 (Theorem 4.2). So reading (a1) is deterministic function induction with an exponential clock.
  * *The log factor* is **[open]**. It comes from the number of formulas of size H, not from the pricing of parameters: already the parameter-free formulas ∀^k(P(#i_1) → (P(#i_2) → ⋯ → P(#i_k))), of size 4k, number k^k = 2^{Θ(H log H)} (RLg-m5). Pricing parameters by their bit length would not remove it; `notes.md`'s suggested remedy is withdrawn.

**Proposition 4.5 (time-bounded predictors, Hänni's S among them, lose to (a1)) [proved, given CKS (known) and the loss computation of TF Thm 3.2(c); for S, given Hänni's description of its running time (his claim, not checked)].** Let P be a predictor that may use the history. Suppose that on a history of j literal data and a next datum, its predictive pair can be approximated within 2^{−k} in time polynomial in j + k. Then there are X ∈ DTIME(2^{O(m)}) and constants c_P, c'_P such that:
* ℓ_P(D^X_n) ≥ n − 1/(4 ln 2) ≥ n − 0.361 for every n;
* a single parameter-free AI hypothesis with polynomial-time membership is (a1)-compatible with all of D^X under the budget h(m) = c_P·m + c'_P, so ℓ_{AI^{a1}}(D^X_n) is bounded.

*Proof.*
* Let w_j be the j-th word. Define β_j := 0 iff a_0 ≤ a_1, where (a_0, a_1) approximate P's pair within 2^{−j−3} on the history ((φ_{w_1}, β_1), …, (φ_{w_{j−1}}, β_{j−1})) and the next datum φ_{w_j}. Put X := {w_j : β_j = 1}. No self-reference is needed, because the sequence is literal.
* *Loss.* With q_b := P's probability of label b at step j and ε := 2^{−j−3}: the tie rule gives q_{β_j} ≤ a_{β_j} + ε ≤ a_{1−β_j} + ε ≤ q_{1−β_j} + 2ε, and q_0 + q_1 ≤ 1, so q_{β_j} ≤ 1/2 + 2^{−j−3} and −log₂ q_{β_j} ≥ 1 − log₂(1 + 2^{−j−2}). Summing, Σ_j log₂(1 + 2^{−j−2}) ≤ 1/(4 ln 2). This is TF Thm 3.2(c); `notes.md` had the weaker n − 1/(2 ln 2).
* *Time.* Computing β_1, …, β_n takes Σ_{j ≤ n} poly(j) = poly(n) steps. For |w_n| = m, n < 2^{m+1}, so X ∈ DTIME(2^{am}) for some a.
* *AI.* By CKS, X ∈ ASPACE(O(am)); a clock makes all paths halt. Proposition 4.3 then gives the hypothesis A_M with instances of size O(m).
* *Hänni's S* (`hanni-polytime-solomonoff.md`, read on labelled sentences as in TF Def 1.2). Its per-step time is p(n)·log n given the state of the previous step (his note, lines 5, 18 and 43). Replaying its first j steps from scratch costs Σ_{i ≤ j} p(i) log i = poly(j). That premise is his claim, not checked here. ∎

The converse fails. On the coin-flip sequences of `prop:time:fiall`, S and FIall_τ have bounded loss while every reading of AI loses at least n bits in expectation, since compatible hypotheses are consistent. So under (a1), AI and S are incomparable, as in TF Prop 3.4. A history-free predictor cannot have bounded loss on both D^∅ and D^{all} (TF Rem 4.6), so only history-using predictors are of interest here. For S against reading (b) see Prop 4.13.

### 4.2 What each construction pays

**Proposition 4.6 (Craig padding and the bounded schema are blocked under every reading).**

(i) **[proved]** Literal data, B = ∅, f a *literal assigner* (it abstains on every sentence other than the φ_w, like f_X), and A^C_f its Craig set (`thm:time:equiv`). Every K-derivation of φ_w^b from A^C_f contains (φ_w^b)^{∧(k+1)}, k = time_f(φ_w), a line of size ≥ (k + 1)|φ_w^b|. So the Craig hypothesis is compatible with φ_w under (a1), (a2), (b) or (b2) only if (time_f(φ_w) + 1)|φ_w^b| is within the budget. For assigners that also label other sentences, a quickly accepted sentence can imply a slowly decided literal, and the statement can fail.

*Proof.*
* Let F be the set of Craig axioms used. Each is a power of a literal ±φ_{w'}, logically equivalent to that literal.
* If F contained no power of φ_w^b, take the term algebra with R chosen to satisfy F's literals and to falsify φ_w^b (distinct words give distinct terms). Then F ⊬ φ_w^b.
* The only power of φ_w^b in A^C_f has k + 1 factors, and ψ^{∧(k+1)} contains k + 1 copies of ψ. ∎

(ii) **[proved, given TF Prop 2.5, TF Lemma 1.4(a) (MRDP, known) and the deterministic time hierarchy (known)]** One sort, L ⊇ L_A ∪ {e, s0, s1, R}, B = Q, and f a **literal assigner** (RLg-m7) that decides every φ_w; X_f := {w : f accepts φ_w}. A^bd_f, Acc^{≤k}_f and the witness w_f are as in TF Prop 2.5 (Diophantine form, numeral bounds bin(k)).
* (a) Every K-derivation of φ_w^b (b the label f gives) from Q ∪ A^bd_f contains a nonlogical axiom line with k ≥ w_f(φ_w), whose numeral bin(k) has at least log₂ w_f(φ_w) symbols.
* (b) Let s(m) ≥ m be time-constructible. If log₂ w_f(φ_w) ≤ s(|w|) for all w, then X_f ∈ NTIME(C_f·s(m)^{d_E}) ∩ coNTIME(C_f·s(m)^{d_E}), with d_E depending only on the fixed polynomials E, E' of TF Lemma 1.4(a).
* (c) Hence for every time-constructible s there is a decidable X such that for every literal assigner f deciding every φ_w with X_f = X, log₂ w_f(φ_w) > s(|w|) for infinitely many w. With s(m) := h(m + 2), the decider of A^bd_f is then not (a1)-, (a2)-, (b)- or (b2)-compatible with all of D^X under budget h (with g := h for (b) and (b2)).

*Proof.*
* (a) TF Prop 2.5(c) applies: its side condition holds, since Q together with f's decisions on other words does not prove φ_w^b. Expand ℕ by e ↦ 1 and s_c(x) ↦ 2x + c, so t_w ↦ the number with binary expansion 1w, distinct for distinct w, and choose R to satisfy the other literals and falsify φ_w^b. So the derivation's finite set of nonlogical axioms contains one with k ≥ w_f(φ_w). bin(k) has at least 4⌊log₂ k⌋ + 2 ≥ log₂ k symbols.
* (b) To accept w: compute bin⌜φ_w⌝, guess ȳ with entries < 2^{s(m)+1}, and accept iff P_f(bin⌜φ_w⌝, ȳ) = P'_f(bin⌜φ_w⌝, ȳ), the acceptance equation of TF Prop 2.5. Evaluating these fixed polynomials (E, E' with f's index substituted) on numbers of O(|f| + m + s(m)) bits takes time C_f·s(m)^{d_E}. If w ∈ X_f, a solution with entries ≤ w_f(φ_w) ≤ 2^{s(m)} exists; if the equation has any solution, f accepts φ_w (TF Lemma 1.4(a)). The complement uses the rejection equation, since f decides every φ_w.
* (c) Choose X decidable outside DTIME(2^{s(m)^{d_E + 2}}) [hierarchy]. NTIME(T) ⊆ DTIME(2^{O(T)}), so X ∉ NTIME(C·s^{d_E}) for any C, even after a finite table. By (b), the bound fails for infinitely many w, and by (a) each such datum needs a nonlogical instance (hence material) of more than h(|φ_w|) symbols. ∎

The orchestrator's hypothesis that A^bd_f is not blocked is **[refuted]**: its bound k plays the role of Craig's padding, at a cost of log k symbols (TF Prop 2.5, framing). Under (a1) and (b) A^bd_f is moreover a parameter-free set with polynomial membership, so Theorem 4.2 and Corollary 3.2 constrain it as they constrain every hypothesis. `notes.md` stated (ii) as "log₂ w_f(φ_w) ≥ time_f(φ_w)" under an assumption on the coding of computations; that assumption concerned the T-predicate form of Acc^{≤k}_f and is not established for the Diophantine form TF now uses, so the statement is **withdrawn** and replaced by (b) and (c).

**Proposition 4.7 (Hänni's two-sorted schema under (a2) and (b2)) [proved, given TF Prop 2.4(b1) and Σ₁-completeness of Q for <-free sentences (known)].** Work in two sorts with B = B_A ∪ B_L as in TF Prop 2.4(b): B_A a decidable set of arithmetic-sort sentences with Q ⊆ B_A ⊆ Th(ℕ), B_L a decidable set of L-sort sentences, no mixed-sort axioms. Let f be an assigner with B_L ∪ Γ_f consistent. Then:
* B ∪ A_f is consistent, and Cn(B ∪ A_f) ∩ Sent_L = Cn(B_L ∪ Γ_f) ∩ Sent_L (TF Prop 2.4(b1));
* every φ that f labels has a K-derivation whose nonlogical instances are Q1–Q7 and one member Acc_f(⌜φ⌝) → φ (or Rej_f(⌜φ⌝) → ¬φ), of size ≤ a|f| + a'|φ|_bit + b′.

Here |φ|_bit is the length of φ's code (Def 5.1), and ⌜φ⌝ is taken to be that code read as a binary number with a leading 1, so bin⌜φ⌝ has O(|φ|_bit) symbols. |φ|_bit is O(|φ|) for sentences without indices, such as literals, and O(|φ| log |φ|) in general (`notes.md` wrote a'|φ|, which holds only in the first case).
* If h(|φ|) ≥ a'|φ|_bit + b′ + a|f| for every sentence φ, the decider of A_f (|p_f| ≤ |f| + c, polynomial membership by `prop:time:cheap`(a), parameter-free) is (a2)-compatible wherever f is, and (b2)-compatible when g(|φ|) is larger by the size of Q.
* If h(m) ≥ m + 1 and h(m) − a'·max_{|φ| = m}|φ|_bit → ∞, then for every f the decider of A_f ∪ {φ^b : f labels φ with b, h(|φ|) < a'|φ|_bit + b′ + a|f|} (a finite table, since L is finite) is (a2)-compatible wherever f is. Consistency: ℕ ⊕ M with M ⊨ B_L ∪ Γ_f satisfies everything.
* With h(m) = a'm + b″ of the same slope as the members, the deficit a|f| + b′ − b″ is the same at every length, and the construction fits only the finitely many f with a|f| ≤ b″ − b′ (RLg-m1). `notes.md`'s claim that it gives every decidable X in the fit class did not follow from its proof. The claim itself holds for literal sequences, by a different hypothesis (Prop 4.12).

*Proof.* The derivation proves the true Σ₁ sentence Acc_f(⌜φ⌝) in Q, using Q1–Q7 and logical axioms (whose A4 instances may be large; they are logical), then applies MP. The member contains f's index, O(|f|) symbols, and the binary numeral ⌜φ⌝, O(|φ|_bit) symbols. ∎

**Proposition 4.8 (a one-sorted trace schema, short axioms, any consistent assigner) [proved, given Σ₁- and Δ₀-completeness of Q (known), the bounded lemma TF Lemma 1.4(d) (proved there), and a Δ₀ definition of the step relation (known; Bennett 1962, Hájek–Pudlák 1993 Ch. V; not checked)].**

*Setting.* One sort, L ⊇ L_A ∪ {C} with C a binary relation symbol. B is decidable, B ⊇ Q, and C does not occur in B (for example B = PA with induction for L_A-formulas only). f is an assigner that abstains on every sentence containing C, with B ∪ Γ_f consistent.

*Formulas.* Configurations of f's computation are coded by numbers. The following Δ₀ formulas (bounded quantifiers written ∃z(z + x = y)) are needed:
* AccC(y) and RejC(y): "y codes a halting configuration with output acc (respectively rej)";
* Next(y, y') := ∃z (z + y' = t(y)) ∧ N₀(y, y'), where N₀ is Δ₀ and defines the step relation, and t is a term with next(c) ≤ t(c).

For each configuration c, with ȳ the binary numeral of the code of c:
* Q ⊢ Next(ȳ, y') ↔ y' = (next c)‾ if c is not halting, and Q ⊢ ¬Next(ȳ, y') if it is halting. This uses Q ⊢ t(ȳ) = k̄ (TF Lemma 1.4(b)), the bounded lemma Q ⊢ ∃z(z + y' = k̄) → ⋁_{j ≤ k} y' = j̄ (TF Lemma 1.4(d)), and Q's decision of each N₀(ȳ, j̄).
* Q decides AccC(ȳ) and RejC(ȳ).

*The schema.* A^tr_f consists of:
* S := ∀x∀y∀y' (C(x, y) → (Next(y, y') → C(x, y'))), one sentence;
* I_φ := C(⌜φ⌝‾, c̄₀(φ)), for each C-free sentence φ, with c₀(φ) the initial configuration of f on φ;
* A_φ := ∀y (C(⌜φ⌝‾, y) → (AccC(y) → φ)) and R_φ := ∀y (C(⌜φ⌝‾, y) → (RejC(y) → ¬φ)).

Then:
* (a) membership in A^tr_f is decidable in time polynomial in |χ|; A^tr_f is parameter-free;
* (b) B ∪ A^tr_f ∪ Γ_f is consistent;
* (c) if f accepts φ (rejects φ), φ (¬φ) has a K-derivation from B ∪ A^tr_f whose nonlogical instances are Q1–Q7, S, I_φ and A_φ (R_φ), of total size ≤ a|f| + a'|φ|_bit + b;
* (d) (new) Cn(B ∪ A^tr_f) and Cn(B ∪ Γ_f) contain the same C-free sentences.

*Proof.*
* (a) Parse; compare the numeral with ⌜φ⌝; compute c₀(φ), which is linear.
* (b) Take any M ⊨ B ∪ Γ_f, an (L ∖ {C})-structure, and expand it by
  C^M := {(⌜φ⌝‾^M, c̄^M) : φ is C-free and c is a configuration of f's run on φ}.
  This is well defined, since M ⊨ Q makes distinct numerals denote distinct elements. Check each axiom:
  * I_φ holds.
  * S: if C^M(a, b), then a and b are denotations of numerals, b = c̄ for a reachable c. If M ⊨ Next(c̄, b'), then b' = (next c)‾^M by the Q-provable uniqueness, and next(c) is reachable. So C^M(a, b').
  * A_φ: C^M(⌜φ⌝‾, b) forces b = c̄ with c reachable on φ. M ⊨ AccC(c̄) iff ℕ does (Δ₀, decided by Q), and then f accepts φ, so φ ∈ Γ_f and M ⊨ φ. R_φ likewise.
  * Γ_f and B are C-free, so they still hold.
* (c) Let c₀, …, c_T be the run. Cite I_φ. For each j, prove Next(c̄_j, c̄_{j+1}) in Q, instantiate S three times by A4, and apply MP twice to get C(⌜φ⌝, c̄_{j+1}). Finally prove AccC(c̄_T) in Q, instantiate A_φ, and apply MP twice. c₀(φ) contains f's code, which gives the term a|f|, and ⌜φ⌝ gives a'|φ|_bit.
* (d) ⊇ by (c). ⊆: the expansion in (b) works for **every** model M of B ∪ Γ_f, so a C-free sentence provable from B ∪ A^tr_f holds in every model of B ∪ Γ_f, and by completeness it lies in Cn(B ∪ Γ_f). ∎

Two remarks on the hypotheses.
* *B must not contain C-induction* [proof sketch]. With B = PA(L) and the f of `prop:time:single`, induction along the run makes B ∪ A^tr_f prove C at nonstandard configurations, which reach a nonstandard proof of ⊥. Then A_{Con(PA)} yields Con(PA), a contradiction, as in `prop:time:single`. So "C not in B" is needed.
* *The fresh symbol is what one sort lacks.* C is interpreted on standard elements only, which no L_A-formula can define. Whether L = L_A admits a short-axiom repair is open (§9).

**Corollary 4.9 (TF open problem 1, with a fresh relation symbol) [proved, given Prop 4.8].** Take the setting of TF Prop 2.4(d) (one sort, B a decidable set with Q ⊆ B, assigners with B ∪ Γ_f consistent and Th(ℕ) ∪ Γ_f possibly inconsistent), and suppose L has a binary relation symbol C that occurs neither in B nor in the sentences f decides. Then the content-relative penalty P3 of TF Def 1.1 is vacuous for f:
* G_f(φ) := {I_φ, S, A_φ, R_φ} is computable in time polynomial in |φ| for fixed f;
* B ∪ G_f(φ) ⊢ φ^b for each decision of f;
* B ∪ ⋃_φ G_f(φ) is consistent and has the same C-free consequences as B ∪ Γ_f (Prop 4.8(d)).

So TF's open problem 1 (TF Prop 2.4(d), Rem 5.3) has a positive answer when a spare relation symbol is available. For L = L_A with no extra symbol it stays **[open]**.

**Remark 4.10 (the reflection sentence ρ_{f,n} of `prop:time:collapse`) [(a1), (b): proved; (a2), (b2): proof sketch].**
* (a1) and (b): PA + ρ_{f,n} is parameter-free and has polynomial-time membership. By Theorem 4.2 and Corollary 3.2, only assigners in DTIME(2^{O(h log h)}) under (a1), and certificate labellers (NP ∩ coNP at polynomial budgets) under (b), are realised.
* (a2) and (b2): the derivation of φ from PA + ρ_{f,n} (f Σ_n-sound, φ ∈ Σ_n) proves Acc_f(⌜φ⌝) and Sent_{Σ_n}(⌜φ⌝) in Q, applies ρ_{f,n}, and then uses the Tarski biconditional Tr_n(⌜φ⌝) → φ. The biconditional is assembled by meta-induction on φ from a fixed finite set of PA-theorems (the compositional clauses of Tr_n and the substitution properties of the coding), instantiated by logic, plus Q-facts about specific numerals. So the nonlogical instances used are Q1–Q7, the finitely many induction instances behind those fixed theorems, and ρ_{f,n}: a constant set for fixed f and n. *Not written out*: that the fixed finite set suffices for every Σ_n sentence φ.

**Remark 4.11 (no membership-time bound: no time limit) [proved].** For a total consistent assigner f (it halts on every sentence), the set A := Γ_f is decidable and parameter-free, and every datum that f labels is derived by citing itself: one line of size ≤ |φ| + 1. So with h(m), g(m) ≥ m + 1 and no bound on membership time, every reading contains every total consistent assigner, and every decidable X is in the fit class. The time limit of (a1) and (b) comes from the budget together with the membership-time bound, as in `thm:time:ntime` and TF Def 1.3.

**Proposition 4.12 (finite theories make (a2) and (b2) vacuous on literal data) [proved, given Prop 6.1; computed: `referee_logic/r4`; RLg-m2].** Let X be decidable. Let M be a deterministic three-tape machine in the normal form of Prop 6.1 that computes V(w, c) := (acc if w ∈ X, rej if w ∉ X) for w ∈ {0,1}* and every certificate c ∈ {0,1}*, and ⊥ otherwise. Let T^∀_M be the set of universal closures of the templates of T_M (Prop 6.1): a finite set of sentences, of largest size c_M and total size Σ_M. Then, with B = ∅:
* T^∀_M ∪ Γ_{f_X} is consistent;
* every datum φ_w^{[w∈X]} has a K-derivation from T^∀_M whose nonlogical instances are members of T^∀_M;
* hence, for every unbounded nondecreasing h with h(m) ≥ m + 1, the decider of T^∀_M ∪ {φ_w^{[w∈X]} : h(|φ_w|) < c_M} (a finite set of sentences, membership in linear time) is (a2)-compatible with all of D^X; for (b2), the same holds for every unbounded nondecreasing g with g(m) ≥ m + 1, with the table listing the data with g(|φ_w|) < Σ_M. So the fit class of AI^{a2}[t, h] and of AI^{b2}[t, g] on literal sequences is every decidable X, for every t ≥ linear.

*Proof.*
* Model 1 of Prop 6.1(ii) is the free term algebra H with equality the identity. Its elements are closed terms, so a universal closure holds in H iff all its closed instances hold, and Prop 6.1(ii) shows they do. R on words is X, so Γ_{f_X} holds.
* The derivation of Prop 6.1(iii) with c = ε cites template instances. Replace each citation of τθ by its closure ∀^k τ' ∈ T^∀_M followed by k A4 instances and k MPs, which are logical. The nonlogical instances are members of T^∀_M, of size ≤ c_M; their total is ≤ Σ_M.
* The finitely many short data are cited as themselves, of size ≤ |φ_w| + 1 ≤ h(|φ_w|). ∎

So the qualifiers "two sorts" and "B ⊇ Q" in `notes.md`'s S1 row are not needed for the literal fit class; Props 4.7 and 4.8 are needed only for arbitrary sentences and for the full equivalence with FIcons. *Computed* (`r4_a2_finite_theory.out`): `c5`'s 57 templates as 57 universal sentences, the largest of size 49; on 8 runs with |w| ≤ 15 every derivation is valid for both K checkers, the largest nonlogical instance is ≤ 49 and the nonlogical material ≤ 320 throughout, while the logical A4 instances grow to size 202.

**Proposition 4.13 (Hänni's S against reading (b) at exponential budgets) [proved under (S) of TF §1.2, given Prop 4.5 and TF Cor 4.3(a); RC-m6].** Let P satisfy the hypothesis of Prop 4.5 (S does, given Hänni's description), and let X ∈ DTIME(2^{am}) be its set from Prop 4.5. Then ℓ_P(D^X_n) ≥ n − 0.361, while AI^b[t_C, d] with d(m) := γ(2^{a'm} + 1)(m + 4), for a suitable a', has bounded loss on D^X.

*Proof.* f_X clocked at τ(m) := 2^{a'm} (on U_0) labels every φ_w correctly for suitable a'. TF Cor 4.3(a) maps it to Craig's decider, which is parameter-free, has membership in a fixed polynomial time t_C, and derives each datum with size, hence material, ≤ γ(τ(|φ_w|) + 1)(|φ_w| + 4). ∎

At polynomial material budgets the comparison of S with reading (b) on literal sequences stays **[open]** (TF Rem 4.5(iii), open problem 6).

### 4.3 Summary table

Literal data unless stated; "blocked" means the construction fails the budget on infinitely many data of a hard language.

| construction | (a1) all instances ≤ h | (a2) nonlogical instances ≤ h | (b) total material ≤ g | (b2) nonlogical material ≤ g |
|---|---|---|---|---|
| Craig A^C_f, literal f | blocked unless (time_f + 1)\|φ^b\| ≤ h (4.6(i)) | same | same | same |
| bounded schema A^bd_f (one sort, literal f) | blocked: an instance of > h symbols for hard X (4.6(ii)) | same | same | same |
| Hänni's A_f, two sorts, true B_A | only DTIME(2^{O(h log h)}) assigners (4.2) | **not blocked** for a\|f\| + a'\|φ\|_bit + b′ ≤ h (4.7) | only certificate labellers (3.1, 3.2) | **not blocked** (4.7) |
| trace schema A^tr_f, one sort, fresh C, B ⊇ Q | only DTIME(2^{O(h log h)}) (4.2) | **not blocked** (4.8) | only certificate labellers | **not blocked** (4.8) |
| ρ_{f,n} over PA, Σ_n-sound f | only DTIME(2^{O(h log h)}) (4.2) | not blocked (sketch, 4.10) | only certificate labellers | not blocked (sketch) |
| finite Horn theory T_M (instances) or T^∀_M (closures), B = ∅ | realises DSPACE(h/c) (6.3) | **not blocked** (4.12) | realises certificate labellers (6.2) | **not blocked** (4.12) |
| ground alternating axioms A_M | realise ASPACE(h/c) (4.3) | same | material exponential | material exponential |
| certificate axioms A_V (θ_c) | realise FIcert, h = d' + m + 16 (3.1(iii)(b)) | same | realise FIcert, g = 2d' + m + 31 (3.1) | same |
| A^par_V (violates (F1)) | excluded by (F1); without it, realises FIcert at h linear (7.1) | same | excluded; same | same |
| **fit class, polynomial budgets and membership** | **EXPTIME** (4.4) | **all decidable** (4.12) | **NP ∩ coNP** (3.2) | **all decidable** (4.12) |

---

## 5. Soft charges (S3)

**Definition 5.1 (the soft inducers).**
* *The code.* Code_K is the prefix code for derivations of `checks/kcore.py` and `c4`. Each line is coded as a 2-bit tag (axiom, MP, Gen), then the Elias-γ codes [Elias 1975] of its premise line numbers + 1 and, for Gen, of its parameter number + 1, then its formula. A formula is coded in preorder, b_s := ⌈log₂(σ_L + 6)⌉ bits per token, with the escapes IDX and PAR followed by Elias-γ of the number + 1. A 2-bit end tag closes the derivation.
  * |χ|_bit is the length of a formula's code, so |χ| ≤ |χ|_bit, and |¬χ|_bit = |χ|_bit + b_s.
  * ℓ^bit_p(ψ) is the least |Code(π)| over derivations π of ψ from Ax_p, and ℓ^sym_p(ψ) the least symbol size; both are ∞ if no derivation exists.
* *Soft AI*, AI^σ_κ[t] (bit cost):

  W(D) := Σ_{p: time O(t), B ∪ A_p consistent} 2^{−|p|}·Π_i 2^{−κ ℓ^bit_p(φ_i^{b_i})}.

  This is Hänni's graded score with g(ℓ) = 2^{−κℓ} and g_∞ = 0 (`rem:model:graded`), applied to both polarities and not normalised. AI^{σ,sym}_κ uses ℓ^sym. (F1) is not required in bit cost (Rem 5.8).
* *Soft certificate FI*, FIcert^σ_{κ,μ}[t']: the hypotheses are verifiers V with time_V(φ, c) = O(t'(|φ| + |c|)) and B ∪ Γ_{f_V} consistent, where f_V uses certificates of any length. With λ_V(φ^1) := min{|c| : V(φ, c) = acc} and λ_V(φ^0) := min{|c| : V(φ, c) = rej} (∞ if none),

  W(D) := Σ_V 2^{−|V|}·Π_i 2^{−κ λ_V(φ_i^{b_i}) − μ |φ_i|_bit}.

  With μ = κ the charge is κ per bit of statement plus certificate (the *joint* charge). With μ = 0 it is the certificate-only charge.
* *Semimeasures* [proved]. For a consistent hypothesis at most one of φ, ¬φ has finite cost, and every factor is ≤ 1. So W(D + (φ, 1)) + W(D + (φ, 0)) ≤ W(D), as in `def:time:inducers`. W(∅) is the total weight of the consistent hypotheses; it does not depend on κ or μ. It is positive: it is at least the weight of the empty axiom set (when B is consistent), or of the always-⊥ verifier. Losses are ℓ(D) = −log₂ W(D) + log₂ W(∅).
* *Constants.* c is a constant with |V_p| ≤ |p| + c and |p_V| ≤ |V| + c for the maps below; c′ := c + log₂(1/W_{AI^σ}(∅)) and c″ := c + log₂(1/W_{FIcert^σ}(∅)) (RC-m12); neither W(∅) depends on the rates.

**Theorem 5.2 (the soft correspondence) [(a), (b) proved for every decider, with no (F1); (c) proved under (F1); computed: `c4`, `referee_complexity/rc1`].** Let e_1 := 31b_s + 24 and r := max(2b_s, 2 + e_1) = 31b_s + 26 (r = 150 for the literal language, b_s = 4; r ≥ 119 for every L, `rc1` part 5). For every D:

(a) W_{FIcert^σ_{κ,κ}[t⁺]}(D) ≥ 2^{−c}·2^{κ Σ_i (2 + b_s·[b_i = 0])}·W_{AI^σ_κ[t]}(D). Hence

  ℓ_{FIcert^σ_{κ,κ}}(D) ≤ ℓ_{AI^σ_κ}(D) − κ Σ_i (2 + b_s·[b_i = 0]) + c′.

(b) W_{AI^σ_κ[t'^#]}(D) ≥ 2^{−c}·2^{−κ e_1 n}·W_{FIcert^σ_{2b_sκ, 2κ}[t']}(D), and W_{AI^σ_κ[t'^#]}(D) ≥ 2^{−c}·W_{FIcert^σ_{rκ, rκ}[t']}(D). Hence

  ℓ_{AI^σ_κ}(D) ≤ ℓ_{FIcert^σ_{2b_sκ,2κ}}(D) + κ e_1 n + c″  and  ℓ_{AI^σ_κ}(D) ≤ ℓ_{FIcert^σ_{rκ,rκ}}(D) + c″.

(c) *Symbol cost, under (F1).* λ_{V_p}(φ^b) ≤ ℓ^bit_p(φ^b) − |φ^b|_bit − 2 and ℓ^bit_p ≤ β ℓ^sym_p log₂(ℓ^sym_p + 2); and ℓ^sym_{p_V}(φ^b) ≤ 2λ_V(φ^b) + 2|φ^b| + 29 ≤ 2λ_V(φ^b) + 2|φ| + 31.

*Proof.*
* (a) For a hypothesis p let V_p(φ, c) be: acc if c followed by Code(φ) and the end tag decodes as a derivation of φ from Ax_p; rej if this holds with ¬φ in place of φ; ⊥ otherwise.
  * The certificate for φ^b is Code(π) with the last line's formula **and the 2-bit end tag** removed, so λ_{V_p}(φ^b) ≤ ℓ^bit_p(φ^b) − |φ^b|_bit − 2 (RC-M1; `c4` measures exactly this length on 480 derivations).
  * So the FIcert^σ_{κ,κ} factor of V_p is 2^{−κλ − κ|φ|_bit} ≥ 2^{−κℓ^bit_p(φ^b) + κ(2 + |φ^b|_bit − |φ|_bit)}, and |φ^b|_bit − |φ|_bit = b_s·[b = 0].
  * Checking a decoded derivation takes time t⁺ (polynomial line checks, and t on axiom lines). The certificate contains the bit codes of all parameter numbers, so no closure hypothesis is needed (RC-M3, addition 2).
  * Γ_{f_{V_p}} ⊆ Cn(Ax_p) is consistent with B, and p ↦ V_p is injective.
  * Sum over p, then take logarithms, using W_{FIcert^σ}(∅) ≤ 1.
* (b) With Z, C_c and θ_c as in the proof of Theorem 3.1(iii)(b), let A_V := {θ_c → φ : V(φ, c) = acc} ∪ {θ_c → ¬φ : V(φ, c) = rej}, with no length bound on c.
  * Membership: χ is a member iff χ = θ → ψ with θ = θ_c and either V(ψ, c) = acc, or ψ = ¬φ and V(φ, c) = rej. Time t'^#; decider p_V. Cn(B ∪ A_V) = Cn(B ∪ Γ_{f_V}), which is consistent.
  * The derivation θ_c (A1), θ_c → φ^b (axiom), φ^b (MP) has symbol size 2|c| + 2|φ^b| + 29, and code length 2b_s|c| + 2|φ^b|_bit + 29b_s + 24 (θ_c has six index nodes of 1 + b_s bits each; tags, γ codes of the premises 1 + 3, end tag 2). With |φ^b|_bit ≤ |φ|_bit + b_s this is ≤ 2b_s|c| + 2|φ|_bit + e_1.
  * Since |φ|_bit ≥ 1, 2|φ|_bit + e_1 ≤ (2 + e_1)|φ|_bit, so the code length is ≤ r(|c| + |φ|_bit).
  * Sum over V, and use W_{AI^σ}(∅) ≤ 1.
* (c) By Lemma 4.1(a) and (F1), rename the parameters of a shortest derivation to p_0, p_1, …, all < ℓ^sym. Indices and line numbers are < ℓ^sym too. Each symbol then costs ≤ b_s + 2 log₂(ℓ^sym + 1) + 1 bits, and each line adds O(log ℓ^sym). This gives β. The second item is (b) in symbols. ∎

*Computed* (`c4_cert_embedding.out`): 3000 random (φ, c, polarity) give the exact symbol size 2|c| + 2|φ^b| + 29 and code length 2b_s|c| + 2|φ^b|_bit + 29b_s + 24; θ_c decodes uniquely and is an A1 instance for the independent recogniser. For 480 normal derivations an encoder and decoder recovers each derivation from (φ, certificate), and the certificate length is the code length − |φ^b|_bit − 2.

**Proposition 5.3 (no rate gives an equivalence; the statement term) [proved; computed: `referee_complexity/rc1`; RC-M1].**
* (i) For every hypothesis p and sentence ψ, ℓ^bit_p(ψ) ≥ |ψ|_bit + 4. Hence ℓ_{AI^σ_κ}(D) ≥ κ Σ_i (|φ_i^{b_i}|_bit + 4) for every D, and every soft loss diverges on every infinite sequence.
* (ii) Let D^∅ be the all-negative literal sequence (X = ∅, B = ∅), and κ_c, κ_s ≥ 0 any rates. Then

  ℓ_{AI^σ_κ}(D^∅_n) − ℓ_{FIcert^σ_{κ_c,κ_s}}(D^∅_n) = (κ − κ_s)·Σ_{i≤n} |φ_{w_i}|_bit + κ(b_s + 4)·n + O(1),

  with the O(1) between −|V_∅| and |p_∅|.
* (iii) Hence no pair (κ_c, κ_s) gives a two-sided constant-regret equivalence with AI^σ_κ. In particular Theorem 5.2(b) **fails with r = 1**: `notes.md`'s "whether r can be 1 is open" is **[refuted]**, and so is its reading of this proposition, "κ is the only joint rate for which a two-sided equivalence could hold". On the all-positive sequence the gap at κ_s = κ is 4κn + O(1).
* (iv) At the common rate κ the gap is linear on **every** sequence: ℓ_{AI^σ_κ}(D) − ℓ_{FIcert^σ_{κ,κ}}(D) ≥ κ Σ_i (2 + b_s·[b_i = 0]) − c′ ≥ 2κ|D| − c′ (Theorem 5.2(a)).

*Proof.*
* (i) A code lists at least one line. The last line contributes its 2-bit tag and its formula, and the 2-bit end tag follows. So every factor of W_{AI^σ_κ}(D) is at most 2^{−κ(|φ_i^{b_i}|_bit + 4)}, and W(D) ≤ W(∅)·2^{−κΣ(|φ_i^{b_i}|_bit + 4)}.
* (ii) *AI.* Lower bound: (i) with |¬φ|_bit = |φ|_bit + b_s. Upper bound: the polynomial-time decider p_∅ of {¬φ_w : w} (consistent, parameter-free) derives each datum in one line of code length |φ_w|_bit + b_s + 4, and W_{AI^σ}(∅) ≤ 1. *FIcert.* Lower bound: every factor is at most 2^{−κ_s|φ_i|_bit}. Upper bound: V_∅(φ_w, ε) := rej is consistent with B = ∅ and has λ = 0, and W_{FIcert^σ}(∅) ≤ 1.
* (iii) At κ_s = κ the difference is κ(b_s + 4)n + O(1) → +∞, so ℓ_AI ≤ ℓ_FI + O(1) fails. At κ_s < κ it tends to +∞ as well. At κ_s > κ the term (κ − κ_s)Σ|φ_{w_i}|_bit = −Θ(n log n) dominates (Σ_{i≤n} |w_i| ≥ (n/2)(log₂ n − 3) in length-lexicographic order; `rc1` part 4), so ℓ_FI ≤ ℓ_AI + O(1) fails. On X = {0,1}* there is no ¬, which leaves 4κn.
* (iv) is Theorem 5.2(a). ∎

*Computed* (`rc1_rate_one.out`): three implementations of |χ|_bit agree on 2249 formulas; the one-line derivations of ¬φ_w (|w| ≤ 8) are accepted by both K checkers and have code length exactly |φ_w|_bit + b_s + 4; at κ = 1 the gap per datum is 7.998 on D^∅ and 3.998 on D^{all} at n = 2^17, against κ(b_s + 4) = 8 and 4κ = 4.

**Corollary 5.4 (certificate-only charging: the per-datum overheads) [proved; RC-m1].** The statement factor of FIcert^σ does not depend on the hypothesis, and W_{FIcert^σ}(∅) does not depend on the rates, so ℓ_{FIcert^σ_{κ,0}}(D) = ℓ_{FIcert^σ_{κ,κ}}(D) − κ Σ_i |φ_i|_bit. Hence, for every D:
* ℓ_{FIcert^σ_{κ,0}}(D) ≤ ℓ_{AI^σ_κ}(D) − κ Σ_i (|φ_i^{b_i}|_bit + 2) + c′ (Theorem 5.2(a));
* ℓ_{AI^σ_κ}(D) ≤ ℓ_{FIcert^σ_{2b_sκ,0}}(D) + κ Σ_i (2|φ_i|_bit + e_1) + c″ (Theorem 5.2(b), first form);
* ℓ_{AI^σ_κ}(D) ≥ κ Σ_i (|φ_i^{b_i}|_bit + 4) (Prop 5.3(i); an absolute bound, not a regret).

So against FIcert^σ_{κ,0} soft AI's regret is at least κ Σ_i (|φ_i^{b_i}|_bit + 2) − c′. Against FIcert^σ_{2b_sκ,0}, which charges 2b_s ≥ 6 times as much per certificate bit, it is at most κ Σ_i (2|φ_i|_bit + e_1) + c″. The two ends concern different comparison inducers. Constant regret against FIcert^σ_{κ',0} is impossible on every sequence on which FIcert^σ_{κ',0} has bounded loss. The lower end is attained on data the hypothesis takes as axioms (one line). On data it does not take as axioms, a derivation has symbol size ≥ 2|φ^b| − 1: the last line together with its major premise, or its Gen premise.

**Remark 5.5 (relation to the hard version and to `prop:time:sigma`).**
* The hard correspondence (Theorem 3.1, TF Thm 4.2) distorts budgets polynomially. The soft one distorts the rate by the factor r, or, in the form of Theorem 5.2(b)'s first inequality, doubles the statement rate, multiplies the certificate rate by 2b_s and adds κe_1 per datum. In the other direction it gains κ(2 + b_s[b = 0]) per datum. `notes.md`'s "or nothing, with the joint charge" is withdrawn (Prop 5.3(iv)).
* Theorem 5.2(a) is the soft form of `thm:time:ntime`: a soft-AI hypothesis is a soft certificate labeller at the same rate.
* With symbol cost, as in L1^σ, (a) holds only up to the factor β log₂(ℓ + 2) in the exponent, under (F1) (Theorem 5.2(c); RLg-m11). Without (F1) no such factor exists: the hypothesis of Prop 7.1 has symbol cost linear in |φ| and unbounded bit cost. Whether the log factor is necessary under (F1) is **[open]**; `notes.md`'s unsupported "it is necessary for codes that encode every derivation" is dropped (RC-m10).

**Example 5.6 (least prime factor) [computed: `c2`; Pratt certificates known (Pratt 1975)].**
* The data are "bit i of the least prime factor of N is 1". The certificate is the factorisation of N with a Pratt certificate for each prime factor; the same certificate serves both labels.
* `c2_lpf_certificates.out`: certificates of at most 0.94·b² bits for b-bit N (b ≤ 128, 192 cases), and verifier work ≤ 0.07·b³ modular multiplications. All honest certificates are accepted; tampered ones are rejected, including Carmichael numbers presented as primes.
* So by Theorem 5.2(b) the soft-AI charge per datum is O(b²) bits times κ. For contrast, trial division, one deterministic route (as a Craig set or a computation-trace certificate), needs up to 1.9·10⁹ divisions at 64 bits and 8.3·10¹⁸ at 128 bits on the semiprime cases. This is not a lower bound for deterministic algorithms (RC-m11). The `c2` column now counts min(lpf(N), ⌊√N⌋)/2 divisions; it previously counted lpf(N)/2, which overstated prime N (80-bit row: 5.65·10²³ before, 5.32·10¹¹ after).

**Remark 5.7 (not covered) [open].** The generative versions (L1^σ on positive data with normaliser Z^σ_T, and the graded score divided by Z_T, `rem:model:graded`) are not covered. Their per-datum factor 1/Z_p depends on the hypothesis, so the comparisons acquire factors Π_i Z_V/Z_p, which do not telescope.

**Remark 5.8 (bit cost needs no (F1)) [proved; RC-M3, addition 2].** Theorem 5.2(a) maps a derivation to its own bit code, which includes the Elias-γ codes of all parameter numbers. Theorem 5.2(b), Prop 5.3 and Cor 5.4 use θ_c, which is parameter-free, or one-line derivations of sentences. So §5 in bit cost holds for every decider; only Theorem 5.2(c) and Remark 5.5 (symbol cost) need (F1). Bit cost is the measure under which the soft correspondence is robust.

**Remark 5.9 (what §5 does not show) [RC-m2].** §5 proves only the correspondence between soft AI and soft certificate FI. It proves no soft analogue of the separations from deterministic function induction (Cor 3.2(b), (e), TF Cor 4.3(d), (e)) and no fit classes: every soft loss diverges on every infinite sequence (Prop 5.3(i)), so a soft separation would have to be stated as growth of regret. Soft AI pays a per-datum certificate charge of order κ·2b_s|c|, which can exceed the per-datum loss of a deterministic mixture that fits long prefixes, so whether soft AI beats soft deterministic function induction at all is **[open]**.

---

## 6. Templates (S4)

**Proposition 6.1 (Horn templates simulate a verifier on literal data) [proved; computed: `c5` (one verifier, right moves only), `referee_complexity/rc2` (two machines with left moves, left-end moves and overwrites)].**

*Setting.* M is a deterministic three-tape Turing machine (tapes: input, certificate, work; tape alphabet Γ ∪ {blank} with {0, 1} ⊆ Γ). L ⊇ {e, pr, R, C} ∪ {s_a : a ∈ Γ}: pr a binary function symbol, C a binary relation symbol. B = ∅; literal data φ_w = R(t_w).

*Machine.* M computes a verifier V(w, c) ∈ {acc, rej, ⊥}, halts on every input, and outputs ⊥ unless w and c are words over {0, 1} (RLg-m8: certificates are binary). f_V is consistent: no w has both an acc and a rej certificate. X_acc := {w : ∃c ∈ {0,1}* V(w, c) = acc}, X_rej likewise. M is in the **normal form (NF)** (RLg-m8, refined by RC): no transition writes a blank, and no transition moves a head right from a cell that is blank after the step; this holds for every transition of M, reachable or not, since every transition becomes a template. (NF) costs nothing: add a symbol □' to Γ that M treats exactly as blank, and write □' wherever M would leave a blank. Under (NF) the non-blank cells of each tape form an initial segment.

*Coding.* A tape with its head is the pair (l, r): the cells left of the head, nearest first, and the cells from the head on, as terms over the s_a ending in e (e is the left end in l, and "blank from here on" in r). A configuration with state q is conf(q, …) := pr(t_q, pr(l_0, pr(r_0, …))), with t_q the binary word term of q's index.

*The theory T_M.* All metavariables are 0-ary term metavariables, so T_M ⊆ FO ⊆ DT° (the paper's DT°_F).
* Start: C(x, conf(q₀, (e, x), (e, z), (e, e))).
* One template per transition (state, three read symbols, and, for each tape whose head moves left, the left neighbour or the left end): C(x, pattern) → C(x, result).
* Accept: C(x, pr(t_{q_acc}, y)) → R(x). Reject: C(x, pr(t_{q_rej}, y)) → ¬R(x).

Then:
* (i) T_M has O(|Q_M|) templates (for fixed Γ), each of size O(log |Q_M|).
* (ii) T_M ∪ Γ_{f_V} is consistent. For words, T_M ⊢ R(t_w) iff w ∈ X_acc, and T_M ⊢ ¬R(t_w) iff w ∈ X_rej.
* (iii) If V(w, c) ∈ {acc, rej} after τ steps, the corresponding literal has a K-derivation from ⋃inst(T_M) by MP only, with **2τ + 3** lines (RLg-m8, RC-m13), each of size ≤ c_M(τ + |w| + |c| + 1). Its size is therefore ≤ c'_M(τ + |w| + |c| + 1)².

*Proof.*
* (iii) Cite the Start instance with x := t_w and z := t_c. Then, τ times, cite the transition instance at the current configuration and apply MP. Finally cite the Accept or Reject instance and apply MP: 1 + 2τ + 2 lines. Configuration terms have size O(τ + |w| + |c| + log |Q_M|).
* (ii) Take the free term algebra H on L's function symbols, with equality the identity. Let C^H be the closure of the Start instances under the transition templates, the least Herbrand model of the definite part.
  * *Determinism.* Distinct templates have disjoint patterns, so the C-facts derived from Start(x, z) form a single run of configuration terms.
  * *Word inputs.* For x = t_w and z = t_c the run is the run of M on (w, c), by (NF).
  * *Junk.* If x or z has a node that is not some s_a or e, the run follows M on the word prefixes (wp(x), wp(z)), the longest prefixes over the s_a. It gets stuck when a head reaches the junk node, where M would read a blank. If it halts first, M on (wp(x), wp(z)) makes the same run, because the junk cell is never read.
  * *Model 1.* R^H := {t_w : w ∈ X_acc} ∪ {non-word x : some run from x accepts}. Accept holds by construction. Reject holds on words, since X_acc ∩ X_rej = ∅. Reject holds on junk x: accepting and rejecting runs from x would give V(wp(x), ·) = acc and = rej on binary certificates; then wp(x) is a binary word, since V outputs ⊥ on other inputs, and this contradicts the consistency of f_V. Γ_{f_V} holds. This gives consistency, and T_M ⊢ R(t_w) ⇒ w ∈ X_acc.
  * *Model 2.* R on words := the complement of X_rej, the same rule on junk. It gives T_M ⊢ ¬R(t_w) ⇒ w ∈ X_rej.
  * The converses are (iii). Template instances with parameters are read under closure; in H a closure holds iff all its closed instances do, and those are instances again.
* (i) Count. ∎

*Universal version.* For V given as a U-program, take for M a fixed universal 4-tape machine, with V's code written on the fourth tape by the Start template. Then ℓ(T_V) ≤ ℓ(T_{U₀}) + a|V| bits in the template code (`def:model:prior`), and τ is polynomial in V's running time (a universal simulation with polynomial overhead, as TF's (S); standard, not checked for a particular U).

*Computed.*
* `c5_templates.out`: a 3-tape verifier for "w contains 11" (acceptance certificate 0^i, rejection certificate 1); T_M has 57 templates. 66901 (word, certificate) pairs with |w| ≤ 9: every derivation is valid in K, with axioms recognised by an independent pattern matcher, and has the right last line; the template run equals a direct simulation; size ≤ 15·(τ + |w| + |c| + 1)²; 4800 runs on junk terms with no disagreement; no configuration matches two templates. This verifier never moves left and never writes, so `c5` alone does not test the left-neighbour templates (RLg-m8).
* `rc2_templates_left.out` (RC, templates generated from the text of Prop 6.1, not from `c5`): PAL (palindromes; 456 transition templates) and POW2 (|w| a power of 2; 580 templates), 4092 pairs each. Every derivation valid for both K checkers, verdicts right, the template run equal to the array simulation at every step, no configuration matching two templates, lines = 2τ + 3 in every case, size/(τ + |w| + |c| + 1)² ≤ 14.25, 6000 junk runs per machine with no disagreement; 26020 left moves (93 at the left end) and 10676 overwrites in all.

**Corollary 6.2 (`cor:time:hard` is tight up to polynomials on literal data) [proved, given `thm:time:ntime`, Prop 6.1 and the transcript method of Book, Greibach and Wegbreit (known; not checked)].** On literal sequences, with word terms and B = ∅:
* (i) If a finite DT° theory T with T ∪ Γ_{f_X} consistent derives every datum within size ℓ(|w|) (ℓ ≥ m time-constructible), then X ∈ NTIME(ℓ^{c_1}) ∩ coNTIME(ℓ^{c_1}). This is `thm:time:ntime` for X and for its complement; template instance sets satisfy (F1).
* (ii) If X and its complement are in NTIME(τ), τ(m) ≥ m time-constructible, then some finite FO-pattern theory T with T ∪ Γ_{f_X} consistent derives every datum within size c_X(τ(|w|) + |w|)².
  * The verifier reads a tag bit and a guessed *transcript* of a run of the nondeterministic machine for X (tag 1) or its complement (tag 0): the sequence of transitions taken, with the symbols read and written. It checks the transcript tape by tape on its single work tape, in time O(τ + |w|), with a binary certificate of length O(τ) [known: R. Book, S. Greibach, B. Wegbreit 1970 (not checked)]. Then apply Prop 6.1. (`notes.md` said "certificates of length τ + 1, [standard]"; with only the choice bits a one-work-tape verifier needs time O(τ²) in general, RC-m4.)
* (iii) *One-sided* (RC-m5). If X ∈ NTIME(τ), then some finite FO-pattern theory T with T ∪ Γ_{f_X} consistent derives φ_w for every w ∈ X within size c_X(τ(|w|) + |w|)². Use a verifier that only accepts: X_rej = ∅, and Model 1 of Prop 6.1 sets R to X on words, so the negative literals of Γ_{f_X} hold too.
* (iv) *Tightness.* The X of `cor:time:hard`(a) lies in NTIME(s^{c_1+1}). By (iii) some finite FO-pattern theory consistent with Γ_{f_X} derives every φ_w (w ∈ X) within size c(s(m)^{c_1+1} + m)², while every finite DT° theory consistent with Γ_{f_X} needs size > s(m) infinitely often. So `cor:time:hard`, and the lower bounds of `prop:time:sigma`(b), (c), are tight up to polynomials on such data. This is the matching upper bound that TF Rem 4.4(ii) left open, for literal data.
* (v) The soft charges are polynomial in τ on these data:
  * the graded score with **κ ≥ 1** (RLg-m9; `rem:model:graded` proves Z_T ≤ 1 only then): −log₂ P^g_T(φ_w) = κ ℓ_T(φ_w) + log₂ Z_T ≤ κ·c'(τ + |w|)², since the explicit code has no indices or parameters;
  * L1^σ: −ln P^σ_T(φ_w) ≤ −ln Pr(π) + κ|π| ≤ C_T(τ + |w|)², with π the MP chain read as an L1 tree, each body node costing at most ln(1/q_min) under the full-support grammar, and Z^σ_T ≤ Z_T ≤ 1.

So on literal data the derivation size that finite DT° theories need is polynomially related to the NTIME ∩ coNTIME complexity of the language, and at polynomial derivation size their fit class is NP ∩ coNP, as for all polynomial-time axiom sets (Cor 3.2).

**Corollary 6.3 ((a1) inside the template class) [proved for deterministic machines; proof sketch for alternating ones].** For a deterministic M deciding X in space s(m) ≥ m (and halting with ⊥ on inputs outside {0,1}*), the construction of Prop 6.1 without the certificate tape gives a finite FO-pattern theory, consistent with Γ_{f_X} by the same model. Its derivation of each datum has every line of size ≤ c_M(s(|w|) + 1). So under (a1) finite DT° theories fit DSPACE(h/c), and by Theorem 4.2 (membership by linear-time matching, AS Thm 2.5, `thm:setting:matching` in the axiom-schemas paper; template instance sets satisfy (F1)) at most DTIME(2^{O(h log h)}). For alternating machines, universal steps need two premises, C(x, c_1) → (C(x, c_2) → C(x, c)), with c_1 and c_2 computed by patterns. Not written out.

**Remark 6.4 (the gap).**
1. *Non-literal data* **[open]**. The device works because the datum's argument term is the verifier's input. For a datum that is an arbitrary sentence, a template has to produce φ itself from a term that codes φ. Code to formula is not a template operation, and `prop:time:notemplate` shows that the Hänni-style link Acc_f(⌜φ⌝) → φ has no non-ground DT° template. Open: do finite DT° theories realise certificate labellers on non-literal data with polynomial derivations, for example over PA with L = L_A, where `prop:time:collapse`'s ρ_{f,n} realises Σ_n-sound assigners with derivation size **not bounded here** (`rem:time:upper`; RC-m7)?
2. *Description length* **[open]**. ℓ(T_V) ≤ a|V| + b is linear, not |V| + c, like ρ_{f,n} (`prop:time:collapse`). An additive version is not shown. So "nothing is lost" holds for fit classes, for derivation size up to polynomials, and for literal consequences, not for description length (RC-m8).
3. *Literal consequences, for every consistent computable literal assigner* **[proved; RC-m9]**. Prop 6.1 needs only a verifier that halts on every input. Every consistent computable literal assigner f is f_V for V(w, c) := "if w, c are binary words and c is a halting computation of f on φ_w, output its output (acc or rej); otherwise ⊥". So for every such f a finite Horn template theory T, consistent with Γ_f, proves exactly f's decisions among the word literals, with derivations polynomial in f's running time. This answers the literal-consequence variant of model §10 problem 15 positively for all consistent computable literal assigners: on literal data finite Horn templates carry the unpenalised collapse, as well as the certificate version. *Conservativity* over Γ_f for all sentences without C, pr and the extra s_a is **[open]**. (A first candidate counterexample, ∀x R(s1(s1(x))) for a verifier that looks for 11 at the start, fails: V must output ⊥ on non-binary words, so it reads its whole input before any verdict; in Model 1 of Prop 6.1 the run on the junk term s1(s1(pr(e, e))) stops at pr(e, e) with no verdict, so R is false there, and T_M does not prove the sentence.)
4. *The paper's encoding* **[proof sketch]**. φ_w = R(num(w)) (or TF's R(ν(w))) needs a conversion phase from binary numerals to word terms by templates: templates that match ((SS0)·x) + 0 and ((SS0)·x) + S0 peel off one bit each.
5. *Readings (a2), (b2) inside the template class.* Universally closed templates make them vacuous (Prop 4.12).

---

## 7. Parameter indices without (F1)

This section answers RLg-M1 and RC-M3 in full: what goes wrong without (F1), and what survives.

**Proposition 7.1 (the parameter channel) [proved; computed: `referee_logic/r2`].** Let V be a verifier with time t_V and a time-constructible certificate bound L_V(m). For a number N let cert(N) be the binary expansion of N + 1 without its leading 1 (every binary string is cert(N) for exactly one N). Let

  A^par_V := {¬φ → ¬(p_N = p_N) : V(φ, cert(N)) = acc, |cert(N)| ≤ L_V(|φ|)} ∪ {¬¬φ → ¬(p_N = p_N) : V(φ, cert(N)) = rej, |cert(N)| ≤ L_V(|φ|)},

with φ ranging over sentences.
* (a) Cn(B ∪ A^par_V) = Cn(B ∪ Γ_{f_V}), where f_V uses certificates within L_V. A^par_V violates (F1).
* (b) In the node-count reading, membership is decidable in time O(|χ|² + L_V(|χ|) + t_V(|χ| + L_V(|χ|))): parse χ, reject if the part φ contains a parameter, read at most L_V(|φ|) + 2 bits of each occurrence of N + 1, and run V.
* (c) Every datum φ^b with f_V(φ) = b has a 9-line K-derivation (reflexivity, A4 with t = p_N, MP, A1, MP, the member, A3, MP, MP) of symbol size 9|φ^b| + 54, material 5|φ^b| + 40 and largest instance 3|φ^b| + 13, whatever the certificate. Its bit code grows linearly with the certificate.
* (d) Hence, in the node-count reading, for every X ∈ NP ∩ coNP the decider of A^par_V, for a verifier of X and its complement, has polynomial membership time and is (a1)-compatible with all of D^X with h(m) = 3m + 16 and (b)-compatible with g(m) = 5m + 45. Without (F1), Theorem 4.2(iv) and Cor 4.4(v) would give NP ∩ coNP ⊆ ⋃_c DTIME(2^{c·m log m}), and Theorem 3.1(iii)(a) with Fact 1.4 would give NP ∩ coNP ⊆ ⋃_c DTIME(2^{c·m² log m}). These inclusions are open, so those statements cannot be proved without (F1) unless they are.
* (e) In the bit-length reading (membership time measured against the bit length of the encoding), let X be any decidable set, M_X a deterministic machine deciding it, and V(φ_w, c) := acc (rej) iff c is the binary transcript of an accepting (rejecting) run of M_X on w. V runs in time polynomial in |c| + |w| with a degree independent of X. Then the decider of A^par_V (no certificate bound) has membership time polynomial in the bit length, of fixed degree, and is (a1)- and (b)-compatible with all of D^X at linear budgets. So without (F1) every decidable X is in the fit class of AI^{a1}[t_0, linear] and AI^b[t_0, linear] for a fixed polynomial t_0. With X ∉ EXPTIME this refutes Cor 3.2(a) "⊆" and Cor 4.4(i) "⊆" for that reading without (F1), and also `thm:time:ntime` read with bit-length membership time.

*Proof.*
* (a) The closure of a member is ∀x(¬φ → ¬x = x), equivalent to ¬φ → ⊥, i.e. to φ; for rejections, to ¬φ. Every member of Γ_{f_V} has a member (some N). Renaming p_N to p_0 gives a formula that is in A^par_V only if V accepts φ with the empty certificate cert(0) = ε, so (F1) fails as soon as some φ is accepted only with non-empty certificates (`r2`: 0 of 72 renamings to p_0, …, p_5 accepted).
* (b) In preorder φ comes before the parameter. A sentence φ has only indices bounded by its depth, so its encoding has O(|φ| log |φ|) cells.
* (c) With ψ := φ^b and E := (p_N = p_N): ∀(#0 = #0) (4); ∀(#0 = #0) → E (8); E (3); E → (¬ψ → E) (|ψ| + 9); ¬ψ → E (|ψ| + 5); ¬ψ → ¬E (|ψ| + 6); (¬ψ → ¬E) → ((¬ψ → E) → ψ) (3|ψ| + 13), an instance of A3; (¬ψ → E) → ψ (2|ψ| + 6); ψ (|ψ|). The sums are 9|ψ| + 54 and, over the five axiom lines, 5|ψ| + 40.
* (d) With m := |φ| and |φ^b| ≤ m + 1: 3(m + 1) + 13 = 3m + 16 and 5(m + 1) + 40 = 5m + 45. The two inclusions follow by Fact 1.4, as in RLg-M1.
* (e) Membership reads all of N; its time is polynomial in the bit length, which includes |c|. The node sizes are as in (c). EXPTIME ⊊ decidable sets (hierarchy). `thm:time:ntime` with membership time O(n^e) in the bit length would put X in NTIME(poly). ∎

*Computed* (`r2_parameter_channel.out`): for a toy verifier with certificates of length |w|² or |w|³ carried in the index, both K checkers accept the derivations, the three size formulas hold with 0 deviations, the decider's work is below 0.04·|χ|^{deg+1}, and code length / (β·d·log₂(d + 2)) grows to 5.8 at |w| = 12 with β = 8.

**Lemma 7.2 (truncating parameter indices) [proved; computed: `checks/c6_parameters`, Part A].** Let a machine decide membership in Ax (B included) within T(|χ|) steps in the node-count reading, reading its input sequentially from the first cell (a multitape Turing machine's input head moves at most one cell per step). Let π be a derivation from Ax whose nonlogical axiom lines have size ≤ H, with T nondecreasing, and put K := T(H). Let q_0, …, q_{r−1} be the parameters of π (Gen parameters included) whose numbers N have more than K bits in bin(N + 1), and w := ⌈log₂(r + 1)⌉. Let ρ fix every other parameter and map q_j to the parameter whose number N_j has bin(N_j + 1) = (the first K bits of bin(N + 1)) 1 (j in w bits). Then ρ is injective, ρ(π) is a derivation from Ax with the same line sizes, and every parameter number in ρ(π) has at most K + 1 + w bits. Also r ≤ size(π).

*Proof.*
* *Injective.* Images of the q_j have exactly K + 1 + w bits and distinct serials; the fixed parameters have at most K bits.
* *Logical axioms, MP, Gen.* Lemma 4.1(a); it needs only injectivity.
* *Nonlogical axiom lines.* enc(χ) and enc(ρχ) agree on their first K + 1 cells. Before the first parameter of χ with more than K bits, the cells are equal. That parameter's bits start at some cell s ≥ 2, after its marker, and its first K bits are kept, so the strings agree up to cell s + K − 1 ≥ K + 1. (If enc(χ) is shorter, χ has no such parameter and ρχ = χ.) The machine halts within T(|χ|) ≤ K steps on both inputs, since |ρχ| = |χ|, and in that time it reads only cells 1, …, K + 1. So it gives the same answer.
* *r.* Every such parameter occurs in a line or names a Gen step. ∎

**Lemma 7.3 (closure by index classes) [proved; computed: `checks/c6_parameters`, Part B].** Let Ax and K be as in Lemma 7.2, for lines of size ≤ H. Call a parameter number *short* if bin(N + 1) has at most K bits, and give each other number the *class* of its first K bits. A renaming is *class-preserving* if it is injective, fixes the short parameters, and maps each other parameter into its own class.
* (a) For |χ| ≤ H and class-preserving σ: χ ∈ Ax iff σχ ∈ Ax.
* (b) Let can~(χ) rename the non-short parameters of χ, in order of first occurrence, to the numbers with bits (class) 1 (serial, ⌈log₂(H + 1)⌉ bits). Then can~(D_H) is the least set S of can~-canonical formulas of size ≤ H closed under the three rules of Lemma 4.1(b), with can~ in place of can.
* (c) There are at most (σ_L + H + 4 + 2^{K+1} + 2^K(H + 1))^{H+1} = 2^{O(H(K + log H))} can~-canonical formulas of size ≤ H, and S is computable in time 2^{O(H(K + log H))}·(1 + T(H)).

*Proof.*
* (a) As in Lemma 7.2: σ keeps the first K bits of every non-short number and leaves the rest of the string before it unchanged, so the first K + 1 cells agree.
* (b) A finite class-preserving injection extends to a class-preserving permutation (each class is infinite). By Lemma 4.1(a) and (a), D_H is closed under class-preserving permutations. can~(χ) is the image of χ under such a renaming, and can~(σχ) = can~(χ) for every class-preserving σ (short parameters are fixed, classes and the order of first occurrence are preserved). With these two facts the proof of Lemma 4.1(b) goes through word for word: MP uses can~(A → B) = σA → σB and can~(σA) = can~(A); Gen uses Gen_{σp}(σλ) = σ Gen_p(λ).
* (c) A token is a symbol of L, ¬, →, ∀, =, one of ≤ H indices, one of < 2^K short parameters, or one of 2^K(H + 1) canonical non-short parameters. The closure runs as in Theorem 4.2(ii); a membership test runs the decider on can~(χ), in time T(H). ∎

**Theorem 7.4 (the node-count reading without (F1)) [proved, given Lemmas 7.2, 7.3].** Drop (F1) from Definitions 1.2 and 1.6, and keep the node-count reading.
* (a) `thm:time:ntime` holds as stated: if T has membership time O(n^e), T ∪ Γ_{f_X} is consistent, and every φ_w (w ∈ X) has a derivation from T of size ≤ ℓ(|w|), then X ∈ NTIME(ℓ(m)^{c'_e}) with c'_e depending only on e and the calculus's checking overhead. *Proof.* Guess a derivation of size ≤ ℓ whose parameter numbers have at most C·ℓ^e + 1 + ⌈log₂(ℓ + 1)⌉ bits; one exists by Lemma 7.2 if any derivation of size ≤ ℓ exists. Its bit length is O(ℓ^{e+1}). Check it. Soundness is as in the paper.
* (b) Hence Cor 3.2(a) "⊆" holds without (F1): the fit class of AI^b[poly, poly] on literal sequences is still contained in NP ∩ coNP (Cor 2.3 turns material ≤ g into size ≤ G).
* (c) The fit class of AI^{a1}[t, h] on literal sequences is contained in ⋃_C DTIME(2^{C·H·(C·t(H) + log H)}), H = h(m + 2) + m + 3: Theorem 4.2(iii) with Lemma 7.3 in place of Lemma 4.1(b), K = C_p·t(H). So Cor 4.4(i), (ii) and (iii) hold without (F1): at polynomial budgets the fit class is still EXPTIME.
* (d) What needs (F1): the clock 2^{O(h log h)} of Theorem 4.2 and Cor 4.4(v), the uniform inequality of Theorem 3.1(iii)(a) with G' = βG log G (without (F1) a certificate length O(G·(t(G) + log G)) with a p-dependent constant is what Lemma 7.2 gives), and the symbol-cost statements Theorem 5.2(c) and Remark 5.5. Prop 7.1(d) shows that, without (F1), each of these implies an inclusion that is open. ∎

**Remark 7.5 (upstream consequences) [proved for the syntax here; proof sketch for named variables].**
* *The paper.* The proof idea of `thm:time:ntime` ("guess a derivation of size at most ℓ(|w|) and check it") must bound the guessed parameter indices. In the paper's convention (membership time in symbols) Theorem 7.4(a) supplies the bound, so the theorem is correct as stated. Read with membership time in bits, it is false for axiom sets that violate (F1) (Prop 7.1(e)). Stating (F1), or the symbol-count convention, in `def:time:inducers` would remove the ambiguity.
* *The time-followup track.* TF Thm 4.2(a) says "a derivation of symbol size s has a bit code of length at most β·s·log₂(s + 2) (variables numbered in binary)". In Mendelson's named-variable syntax a variable name x_N counts one symbol, so the same channel exists (with a bound or free variable in place of p_N). The step needs the axiom set closed under renaming variables, the analogue of (F1). TF Thm 4.2(a)'s per-sequence consequences (TF Cor 4.3(c)(ii), (e1), (e2)) survive by the argument of Lemma 7.2 (for TF's AI[poly, poly] the membership clock (|χ| + 2)^i gives K directly). Its uniform inequality needs the closure hypothesis or a p-dependent certificate length. The transfer of Lemma 7.2 to named variables is a proof sketch: it needs that an injective renaming of variable names preserves K-derivations, which holds for Mendelson's side conditions ("x not free in B", "t free for x").

---

## 8. Checks

All scripts are seeded or deterministic and write `<name>.out` next to themselves. In this revision every script below was rerun from scratch copies (`checks/`, `referee_logic/`, `referee_complexity/` copied to a scratch directory, outputs regenerated and compared byte for byte). All outputs are byte-identical to the committed ones, except `c2` (changed on purpose, RC-m11) and the new `c6`.

| script | what it checks | result |
|---|---|---|
| `checks/kcore.py` | shared implementation of K (de Bruijn indices, parameters), independent axiom recognisers (A4 by matching), derivation checker, normalisation, the prefix code | module |
| `checks/c1_subformula.py` (seed 20261010) | Lemmas 1.1, 2.1, 2.2, Prop 2.4(a): 300 random raw derivations, 1800 normal ones; occurrence map, independent sits-at search, injectivity, bounds; necessity; tightness | no failure; max size/ΣF = 0.85 on random derivations, 0.9987 on the tightness family; size/(M + \|φ\|)² → 0.1663 (1/6). Rerun: byte-identical |
| `checks/c2_lpf_certificates.py` (seed 1009) | Example 5.6: Pratt-certificate verifier for least-prime-factor data; sizes, work, tampering; trial-division count | all pass; cert bits ≤ 0.94 b², work ≤ 0.07 b³. **Changed in this revision:** the trial-division column counts min(lpf, ⌊√N⌋)/2 (RC-m11); only the four "random" rows with a prime N change (80 bits: 5.652·10²³ → 5.316·10¹¹); all other columns identical |
| `checks/c3_short_axioms.py` (seed 4711) | Lemma 4.1, Thm 4.2 (closure at H = 9, soundness by rebuilding, completeness against random short derivations, renaming); Prop 4.3 (counter, QBF) | all pass. Rerun: byte-identical |
| `checks/c4_cert_embedding.py` (seed 99) | Thm 5.2(b): θ_c, exact symbol and bit sizes; Thm 5.2(a): encoder/decoder, verifier recovers derivations, certificate length = code − \|φ^b\|_bit − 2 | all pass. Rerun: byte-identical |
| `checks/c5_templates.py` (seed 271828) | Prop 6.1 for a 3-tape verifier with right moves only: validity, verdicts, run = simulation, size bound, junk soundness, determinism | all pass. Rerun: byte-identical |
| `checks/c6_parameters.py` (seed 6061; **new**) | §7. Part A: Lemma 7.2 on 300 random derivations with long parameter numbers (up to 40 bits) and a decider that reads the first K = 6 cells; injectivity, unchanged prefixes, validity after truncation, index bound; control: naive renaming. Part B: Lemma 7.3, the class closure at H = 8 with short numbers ≤ 2 bits and classes 10, 11, for an axiom set closed under class-preserving renamings but not under permutations; soundness by rebuilding with class-preserving renamings, completeness against 400 random derivations with long numbers; control: plain canonical forms | Part A: 15473 lines, 3543 nonlogical axiom lines; 0 injectivity failures, 0 changed prefixes, 0 invalid derivations after truncation; largest number 40 → 12 bits; control: naive renaming changes membership on 1534 of 3543 lines. Part B: 76364 class-canonical formulas, closure 2067; 0 of 2067 rebuilt derivations fail; 0 of 10234 random lines missing; control: plain canonical forms change membership on 200 of 250 renamed axioms |
| `referee_logic/rk.py` (RLg) | independent implementation of K, normalisation, "sits at", F and N, the Def 5.1 code | module |
| `referee_logic/r1_subformula_independent.py` (seed 8675309) | Lemmas 1.1, 2.1, 2.2, Cor 2.3, Prop 2.4(a), Rem 2.5: the proof's map o; exhaustive "sits" search with maximum matching; bounds; Gen lines with two uses | 0 failures. Rerun: byte-identical |
| `referee_logic/r2_parameter_channel.py` (seed 31337) | Prop 7.1: A^par_V in both checkers; sizes 9\|φ^b\| + 54, 5\|φ^b\| + 40, 3\|φ^b\| + 13; renamings rejected; decider work; code length against β·d·log d | channel confirmed; ratio 5.8 at \|w\| = 12. Rerun: byte-identical |
| `referee_logic/r3_sharp_constant.py` (seed 2024) | Lemma 2.2(iii) (F ≤ \|α\|(\|α\| + 1)/2, exhaustively to size 9 and randomly), Prop 2.4(b) | 0 violations; ratio → 1/2. Rerun: byte-identical |
| `referee_logic/r4_a2_finite_theory.py` | Prop 4.12: `c5`'s T_M universally closed; A4 + MP derivations in both checkers; instance sizes | valid; largest nonlogical instance ≤ 49. Rerun: byte-identical |
| `referee_complexity/rc1_rate_one.py` (deterministic) | Prop 5.3: \|χ\|_bit in three implementations; one-line derivations of ¬φ_w; the gap on D^∅ and D^{all} to n = 2^17; Prop 5.3's sum bound; the constants e_1, r | 0 mismatches; gap per datum → 8.0 and 4.0 at κ = 1. Rerun: byte-identical |
| `referee_complexity/rc2_templates_left.py` (seed 314159) | Prop 6.1 from its text, for two machines with left moves, left-end moves and overwrites | all pass; lines = 2τ + 3. Rerun: byte-identical |

The scripts check constructions, bounds and arithmetic on finite instances. The theorems are proved in the text.

---

## 9. Open problems

1. **Soft rates with an additive overhead.** Theorem 5.2(b) fails at r = 1 (Prop 5.3). Is there a constant K with ℓ_{AI^σ_κ}(D) ≤ ℓ_{FIcert^σ_{κ,κ}}(D) + κK|D| + O(1) for all D? Equivalently, can the rates (2b_sκ, 2κ) of Theorem 5.2(b)'s first inequality be lowered to κ, keeping an additive O(κ) per datum? One obstacle (RC-M1; not proved to be an impossibility): a datum that is not itself an axiom of the hypothesis needs symbol size ≥ 2|φ^b| − 1 (Cor 5.4), so a positive answer needs hypotheses that take most data as axioms, which requires their membership test to decide those data quickly. Also open: the generative and normalised versions (Rem 5.7) and soft separations from deterministic function induction (Rem 5.9).
2. **The log factor in (a1).** The fit class contains DTIME(2^h) up to a constant factor in the budget and is contained in DTIME(2^{O(h log h)}) (Cor 4.4(v)). An upper bound that counts formulas cannot close the gap: already 2^{Θ(H log H)} parameter-free formulas of size H exist.
3. **One sort without a spare symbol** (L = L_A, B = PA, consistent unsound f): readings (a2) and (b2) for arbitrary sentences, and TF open problem 1 (Cor 4.9).
4. **Templates on non-literal data**; an additive description length; conservativity of T_V over Γ_f (Rem 6.4).
5. **Least-size tightness of Corollary 2.3**: is ℓ_min of order (M_min + |φ|)² for some family? The families of Prop 2.4 are candidates.
6. **Material in other calculi**: which material measure is polynomially equivalent to proof size in natural deduction or sequent calculus (Rem 2.7), and in a Hilbert calculus with ∀E as a rule (Rem 2.5)?
7. **Hänni's S against reading (b) at polynomial material budgets** on literal sequences (TF Rem 4.5(iii), open problem 6). At budgets 2^{O(m)} it is settled (Prop 4.13); under (a1) at linear budgets too (Prop 4.5).
8. **Polynomial budgets**: the intermediate case (P ≠ NP but NP ∩ coNP = P) and uniform domination in either direction (Cor 3.2(d)); for (a1), whether AI^{a1}[poly, poly] dominates FIcons_poly uniformly.
9. **Without (F1)**, in the node-count reading: can the clock 2^{O(H(t(H) + log H))} of Theorem 7.4(c) be improved? Under (F1): is the log factor of Theorem 5.2(c) necessary (Rem 5.5)?

---

## 10. Status of every claim

| claim | status |
|---|---|
| §13 answer; §0 table | summary of the results below |
| Lemma 1.1 | proved; computed (`c1`, `r1`) |
| Def 1.2 with (F1); Rem 1.5 | definition; Rem 1.5 proved |
| Def 1.3 (encodings) | definition; the transfer remarks proved |
| Fact 1.4 | cited: TF Lemma 1.6 (proved there) |
| Def 1.6 | definition (following TF Cor 4.3(e)) |
| Lemma 2.1 | proved; computed (`c1`, `r1`) |
| Lemma 2.2 | proved, with the constant 1/2; computed (`c1`, `r1`, `r3`) |
| `notes.md` Lemma 2.2(iii) "≤ (M + \|φ\|)²" | true but not sharp; superseded by the 1/2 form |
| Cor 2.3 | proved |
| Prop 2.4 (a), (b) | proved; computed (`c1`, `r1`, `r3`); least-size tightness open |
| Rem 2.5 | proved; computed (`c1`, `r1`); "repeated lines matter only for (ii)" corrected |
| Prop 2.6 (i), (ii) | proved, given `thm:time:ntime`, Prop 4.8, `cor:time:hard`, Prop 6.1 and the time hierarchy (known) |
| Rem 2.7 | first part proved (X depends on the proof system); cut-free remark not checked; ∀E open |
| Thm 3.1 (i), (ii) | proved |
| Thm 3.1 (iii) | proved under (F1) (Cook–Reckhow correspondence, known) |
| Cor 3.2 (a) | proved under (F1); "⊆" also without (F1) in the node-count reading (Thm 7.4(b)) |
| Cor 3.2 (b) | proved, conditional on NP ∩ coNP ≠ P |
| Cor 3.2 (c) | proved, conditional on P = NP, under (F1) |
| Cor 3.2 (d) | open |
| Cor 3.2 (e) | proved under TF (S), given the time hierarchy (known) |
| `notes.md` Cor 3.2 / §0.1 "not stronger if P = NP" in the domination sense | refuted for `notes.md`'s mixture (Prop 3.4); holds per sequence (Cor 3.2(c)) |
| Rem 3.3 | proved (by Props 2.6, 4.7, 4.8, 4.12) |
| Prop 3.4 | proved, given the time hierarchy (known) and TF's overhead q (assumed there) |
| Lemma 4.1 | proved; computed (`c3`) |
| Thm 4.2 | proved under (F1); computed (`c3`) |
| Prop 4.3 | proved; computed (`c3`) |
| Cor 4.4 (i), (ii) | proved under (F1), given CKS and the time hierarchy (known); also without (F1) in the node-count reading (Thm 7.4(c)) |
| Cor 4.4 (iii) | proved, given CKS and the time hierarchy (per sequence) |
| Cor 4.4 (iv) | proved; "different fit classes iff NP ≠ EXPTIME" proved, the condition open |
| Cor 4.4 (v) | proved under (F1), for space-constructible h ≥ m; log factor open; `notes.md`'s remedy withdrawn |
| Prop 4.5 | proved, given CKS and TF Thm 3.2(c)'s computation; for S, given Hänni's running-time claim (his, not checked) |
| Prop 4.6 (i) | proved |
| Prop 4.6 (ii) | proved, given TF Prop 2.5, MRDP (known) and the time hierarchy (known) |
| `notes.md` Prop 4.6(ii) "log₂ w_f ≥ time_f" | withdrawn (rested on a coding assumption not established for TF's Diophantine form) |
| orchestrator: "A^bd_f is not blocked" | refuted (Prop 4.6(ii)) |
| Prop 4.7 | proved, given TF Prop 2.4(b1) and Σ₁-completeness of Q (known) |
| `notes.md` Prop 4.7 last sentence (fit class every decidable X with h = a'm + b″) | proof did not give it (RLg-m1); the claim holds by Prop 4.12 |
| Prop 4.8 (a)–(d) | proved, given Σ₁/Δ₀-completeness of Q (known), TF Lemma 1.4(d), and a Δ₀ step relation (known; reference not checked); C-induction remark: proof sketch |
| Cor 4.9 | proved, given Prop 4.8; L = L_A open |
| Rem 4.10 | (a1), (b) proved; (a2), (b2) proof sketch |
| Rem 4.11 | proved |
| Prop 4.12 | proved, given Prop 6.1; computed (`r4`) |
| Prop 4.13 | proved under TF (S), given Prop 4.5 and TF Cor 4.3(a); polynomial budgets open |
| Thm 5.2 (a), (b) | proved (every decider); computed (`c4`, `rc1`) |
| Thm 5.2 (c) | proved under (F1) |
| Prop 5.3 (i)–(iv) | proved; computed (`rc1`) |
| `notes.md` "whether r can be 1 is open"; "κ is the only candidate joint rate" | refuted (Prop 5.3(iii)) |
| Cor 5.4 | proved |
| Rem 5.5 | first two bullets proved; symbol cost under (F1) proved; necessity of the log factor open; `notes.md`'s "or nothing, with the joint charge" withdrawn |
| Example 5.6 | computed (`c2`, column corrected); Pratt's bound known |
| Rem 5.7 | open |
| Rem 5.8 | proved |
| Rem 5.9 | open (soft separations) |
| Prop 6.1 | proved; computed (`c5`, `rc2`); universal version given a polynomial universal simulation (standard, not checked) |
| Cor 6.2 (i), (iii)–(v) | proved, given `thm:time:ntime` and Prop 6.1; (v) for the graded score with κ ≥ 1 |
| Cor 6.2 (ii) | proved, given Book–Greibach–Wegbreit (known; not checked) |
| Cor 6.3 | proved for deterministic machines; proof sketch for alternating ones |
| Rem 6.4 | items 1, 2 open; item 3 proved (literal consequences), conservativity open; item 4 proof sketch; item 5 by Prop 4.12 |
| Prop 7.1 (a)–(e) | proved, given the time hierarchy for (e); computed (`r2`) |
| Lemma 7.2 | proved; computed (`c6` A) |
| Lemma 7.3 | proved; computed (`c6` B) |
| Thm 7.4 | proved, given Lemmas 7.2, 7.3 |
| Rem 7.5 | proved for the syntax here; proof sketch for named variables |

---

## 11. References

* E. Mendelson, *Introduction to Mathematical Logic*, 4th ed., 1997: the calculus K [known (chapter and numbering not checked)].
* W. Craig, "On axiomatizability within a system", *J. Symbolic Logic* 18 (1953) 30–32 [known].
* S. Cook, R. Reckhow, "The relative efficiency of propositional proof systems", *J. Symbolic Logic* 44 (1979) 36–50: proof systems and NP, for Theorem 3.1 [known].
* A. K. Chandra, D. C. Kozen, L. J. Stockmeyer, "Alternation", *J. ACM* 28 (1981) 114–133: ASPACE(s) = ⋃_c DTIME(c^s) for s ≥ log n [known (not checked)].
* J. Hartmanis, R. Stearns, *Trans. AMS* 117 (1965) 285–306; F. Hennie, R. Stearns, *J. ACM* 13 (1966) 533–546: the deterministic time hierarchy [known (exact form not checked)]. S. Cook (STOC 1972; *JCSS* 7, 1973); J. Seiferas, M. Fischer, A. Meyer, *J. ACM* 25 (1978) 146–167; S. Žák, *TCS* 26 (1983) 327–333: the nondeterministic hierarchy, as cited in the paper [known (not checked)].
* R. Book, S. Greibach, B. Wegbreit, "Time- and tape-bounded Turing acceptors and AFLs", *J. Comput. System Sci.* 4 (1970) 606–621: guessed transcripts checked tape by tape in linear time, for Cor 6.2(ii) [known (not checked)].
* P. Elias, "Universal codeword sets and representations of the integers", *IEEE Trans. Inform. Theory* 21 (1975) 194–203: the γ code of Definition 5.1 [known].
* V. Pratt, "Every prime has a succinct certificate", *SIAM J. Comput.* 4 (1975) 214–220 [known].
* Y. Matiyasevich (1970), M. Davis (1973): the MRDP theorem, as cited in TF Lemma 1.4(a) [known (not checked)].
* P. Smith, *An Introduction to Gödel's Theorems*, 2nd ed., 2013: Σ₁- and Δ₀-completeness of Q and the bounded lemma [known (numbering not checked)].
* J. H. Bennett, *On Spectra*, PhD thesis, Princeton, 1962 (Δ₀-definability of exponentiation); P. Hájek, P. Pudlák, *Metamathematics of First-Order Arithmetic*, 1993, Ch. V: Δ₀ definitions of computations, for Prop 4.8 [known (not checked)].
* D. Prawitz, *Natural Deduction*, 1965; G. Gentzen, *Math. Z.* 39 (1935): normalisation and cut elimination with the subformula property, for Remark 2.7 [known (not checked)].
* K. Hänni, `../../prior/hanni-solomonoff-axiom-induction.md`, `../../prior/hanni-polytime-solomonoff.md` (working notes).

---

## 12. Verification log

All checks were done in this track, in two sessions. The first produced `notes.md`; the second, after the two referee reports and the final time-followup record, produced this file. Nothing is checked in a proof assistant. No git command that changes repository state was run.

### 12.1 Logic referee (`referee-logic.md`): issues and resolutions

| issue | referee's point | resolution | where |
|---|---|---|---|
| **M1** | parameter indices are an unpriced channel; Thm 4.2(iv), Cor 4.4(i) ⊆, (ii), (v), Thm 3.1(iii), Rem 5.5, §0.1 and the §4.3 table need closure under renaming, which Def 1.2 does not impose; the same gap is upstream | **Accepted.** (F1) added to Def 1.2 and Def 1.6, with its rationale and the equivalent canonical-input convention (Rem 1.5); every construction satisfies it. The counterexample is Prop 7.1, proved, with the referee's `r2` as evidence, and extended to the bit-length reading (7.1(e)), where the fit classes fail without (F1). The referee's "what survives" sketch is now proved: Lemma 7.2 (truncation), Lemma 7.3 (class closure), Thm 7.4 (`thm:time:ntime`, NP ∩ coNP and EXPTIME survive in the node-count reading; the fine bounds need (F1)); checked by the new `c6`. Upstream consequences in Rem 7.5 | Def 1.2, Rem 1.5, Def 1.6, Thm 3.1, Thm 4.2, Cor 4.4, Rem 5.5, §7 |
| m1 | Prop 4.7's last sentence does not follow from its proof (constant deficit at equal slope) | **Accepted.** Restated: the construction works if h(m) − a'·max\|φ\|_bit → ∞ (finite table); at equal slope it fits finitely many f. The literal fit-class claim is proved by Prop 4.12 instead | Prop 4.7, Prop 4.12 |
| m2 | (a2), (b2) are vacuous for every finite theory; templates under (a2) not addressed | **Accepted** as Prop 4.12 (universally closed T_M, B = ∅, every decidable X), with `r4`; S1 row, Rem 3.3, Rem 6.4(5), table and §13 updated; Prop 2.6(ii) uses it too | Prop 4.12, §0, §4.3 |
| m3 | the exact constant is 1/2, attained by a vacuous Gen chain | **Accepted** and proved: F(α) ≤ \|α\|(\|α\| + 1)/2 (breadth-first depths) and superadditivity; the family is Prop 2.4(b), with `r3`; least-size tightness for it left open | Lemma 2.2, Cor 2.3, Prop 2.4 |
| m4 | repeated lines also break the size bound (iii) | **Accepted** | Rem 2.5, §0 |
| m5 | Cor 4.4(v) fails for sublinear h; the log factor is from indices too, so pricing parameters would not remove it | **Accepted.** h space-constructible with h(m) ≥ m; the log factor attributed to the count of formulas (2^{Θ(H log H)} parameter-free ones), the remedy withdrawn | Cor 4.4(v), §9 item 2 |
| m6 | "iff NP ∩ coNP ≠ EXPTIME" is "iff NP ≠ EXPTIME" | **Accepted**, with the two-line proof | Cor 4.4(iv) |
| m7 | Prop 4.6(ii) omits "f literal" | **Accepted**; Prop 4.6(ii) rewritten (see §12.4 item 2) | Prop 4.6(ii), §4.3 |
| m8 | Prop 6.1 needs an unstated normal form; the line count is 2τ + 3; `c5` does not test left moves; certificates must be binary | **Accepted.** (NF) stated (no blank written, no right move from a blank), for every transition, with the free conversion; 2τ + 3; `c5`'s coverage stated and `rc2` (RC) cited for left moves and overwrites; V outputs ⊥ on non-binary certificates | Prop 6.1, Cor 6.2 |
| m9 | Cor 6.2(iii) needs κ ≥ 1 for Z_T ≤ 1 | **Accepted** | Cor 6.2(v) |
| m10 | Rem 2.7: X must be re-chosen per proof system | **Accepted** | Rem 2.7 |
| m11 | Rem 5.5 omits Thm 5.2(c)'s closure hypothesis | **Accepted**; without (F1) no factor exists (Prop 7.1) | Rem 5.5 |
| m12 | missing Cook–Reckhow; folklore subformula property; "DT°" not the paper's notation; unchecked chapters; Δ₀ reference | **Accepted in part.** Cook–Reckhow cited (Thm 3.1); folklore attribution added (§2); chapter references stay marked unchecked; the Δ₀ reference is now Bennett 1962 and Hájek–Pudlák Ch. V (not checked). **Rejected with evidence:** "DT°" is the paper's notation, `\DT` = DT° (`paper/preamble.tex`, line 57); the implemented class `\DTF` is DT°_F, and T_M lies in both | §2, §3, Prop 4.8, §6, §11 |
| — | (confirmed) every paper label cited exists | Rechecked. All paper labels cited here exist in `paper/sections/`; `thm:setting:matching` (Cor 6.3) is a label of the axiom-schemas paper (`axiom-schemas/paper/sections/setting.tex`, line 84), AS Thm 2.5, as `notes.md` said ("of AS"); the citation now names both | Cor 6.3 |

### 12.2 Complexity referee (`referee-complexity.md`): issues and resolutions

| issue | referee's point | resolution | where |
|---|---|---|---|
| **M1** | "whether r can be 1 is open" is refuted: the certificate of Thm 5.2(a) is 2 bits shorter and a negative datum carries b_s more bits; the gap is linear on every sequence; no pair of rates works | **Accepted.** Thm 5.2(a) restated with 2^{κΣ(2 + b_s[b_i=0])}; Prop 5.3 restated with R1's four parts and proved; r = 1 marked **refuted** in §0, Prop 5.3, §9, §10; "κ is the only candidate" withdrawn; the open question replaced by the additive-overhead question with its obstacle (§9 item 1). Checked by `rc1` and `c4` | Thm 5.2, Prop 5.3, Cor 5.4, §9 |
| **M2** | the polynomial-budget dichotomy uses the pre-referee TF Cor 4.3(e); FIcons_poly does not dominate the uncharged mixtures, unconditionally | **Accepted.** Def 1.6 charges degrees as TF Cor 4.3(e) now does; Cor 3.2(a)–(e) per sequence; the non-domination for `notes.md`'s mixtures is Prop 3.4 (proved, for (b) and (a1)); Cor 4.4(iii) is per sequence; §13 says "per sequence" | Def 1.6, Cor 3.2, Prop 3.4, Cor 4.4 |
| **M3** | concurs with RLg-M1; Thm 3.1(iii) misapplies TF Thm 4.2(a); the soft results are immune | **Accepted.** Thm 3.1(iii)(a) now proves the bit-code step from (F1) and Lemma 4.1(a); Rem 5.8 records the immunity of bit cost; Rem 7.5 flags TF Thm 4.2(a) | Thm 3.1, Rem 5.8, Rem 7.5 |
| m1 | Cor 5.4 compares against two different certificate rates; r is large | **Accepted.** Both ends stated with their comparison inducers; r = 31b_s + 26 (150 for the literal language) stated; (b)'s first inequality presented as the informative form | Thm 5.2, Cor 5.4, Rem 5.5 |
| m2 | "the same picture" overreaches for the soft version | **Accepted.** §13 restricts to the correspondence; Rem 5.9 lists soft separations as open | Rem 5.9, §13 |
| m3 | Thm 3.1 omits TF Thm 4.2's hypotheses (B poly-time, budgets time-constructible, L finite) | **Accepted.** Stated in Thm 3.1; L finite throughout (§1.1) | Thm 3.1, §1.1 |
| m4 | Cor 6.2(ii)'s O(τ) verifier with τ + 1 choice bits is not standard | **Accepted.** Transcript certificates of length O(τ) checked tape by tape (Book–Greibach–Wegbreit) | Cor 6.2(ii) |
| m5 | Cor 6.2's tightness claim needs a one-sided variant | **Accepted** and proved as Cor 6.2(iii); tightness derived from it in (iv) | Cor 6.2 |
| m6 | S against (b) is settled at 2^{O(m)} budgets | **Accepted** and proved as Prop 4.13; open only at polynomial budgets | Prop 4.13, §9 item 7 |
| m7 | "unbounded derivation size" for ρ_{f,n} is not established | **Accepted**: "not bounded here" | Rem 6.4(1) |
| m8 | "loses nothing" overreaches (description length is linear) | **Accepted** | Rem 6.4(2), §13 |
| m9 | Prop 6.1 covers every consistent computable literal assigner | **Accepted** and proved (trace verifier) | Rem 6.4(3), §0 |
| m10 | Rem 5.5's "necessary for codes that encode every derivation" is unsupported | **Accepted**; dropped; necessity listed as open | Rem 5.5, §9 item 9 |
| m11 | Ex 5.6: "trial division needs"; `c2`'s column wrong for prime N | **Accepted.** Wording fixed; `c2` now counts min(lpf, ⌊√N⌋)/2 and was rerun (only the four affected rows changed) | Ex 5.6, `c2` |
| m12 | c″ undefined | **Accepted**: defined once in Def 5.1 | Def 5.1 |
| m13 | 2τ + 3, not 2τ + 4 | **Accepted** (= RLg-m8) | Prop 6.1 |
| m14 | missing references (BGW, Elias, Cook–Reckhow); the reading of Hänni's note is accurate | **Accepted** | §11, Prop 4.5 |

Both referees confirmed every other claim of `notes.md`; those claims are carried over with the scopes above.

### 12.3 Checks and their results

* All eleven scripts of `notes.md` and of both referees were rerun from scratch copies: outputs byte-identical (c1, c3, c4, c5, r1–r4, rc1, rc2), except `c2`, which was changed on purpose (RC-m11). Its new output differs from the old in the trial-division column of the four "random" rows with a prime N (16, 24, 32 and 80 bits) and nowhere else.
* `c6_parameters` (new): Lemma 7.2 and Lemma 7.3 hold on all tested cases (numbers in §8); the controls confirm that the naive renaming and the plain canonical form do not preserve membership when (F1) fails, so the tests are not vacuous.

### 12.4 Self-checks that changed this file

1. **What survives without (F1) is proved, not sketched.** RLg's sketch ("a decider with time C·t reads at most C·t cells") needed care about where the cells are: truncating one long index shifts every later cell. The proofs use that a sequential machine reads only a prefix of its input of length at most its running time, and that the first long index starts at cell ≥ 2, so keeping its first K bits keeps the first K + 1 cells (Lemmas 7.2, 7.3). Checked in `c6`.
2. **Prop 4.6(ii) without a coding assumption.** `notes.md` derived "log₂ w_f ≥ time_f" from an assumption about T-predicate codes. TF's final Prop 2.5 uses the Diophantine form (MRDP), for which the assumption is not established. The statement is withdrawn and replaced by an NTIME argument: small witnesses would put the language in NTIME(poly(h)) ∩ coNTIME (Prop 4.6(ii)(b), (c)).
3. **Cor 4.9 gives the same consequences.** The model expansion of Prop 4.8(b) works for every model of B ∪ Γ_f, so B ∪ A^tr_f is conservative over B ∪ Γ_f for C-free sentences (Prop 4.8(d)). This is what TF Prop 2.4(d) asks for; `notes.md` claimed only consistency.
4. **Numerals of sentences.** ⌜φ⌝ has O(|φ|_bit) symbols, which is O(|φ| log |φ|) for sentences with indices; `notes.md` wrote O(|φ|) (Props 4.7, 4.8). Literal data are unaffected.
5. **Theorem 3.1(iii) is self-contained.** (a) proves the bit-code step from (F1); (b) uses the parameter-free θ_c axioms of §5, which give linear material budgets (2d' + m + 31) and also an (a1) version (d' + m + 16).
6. **Prop 2.6(ii)** with a finite theory (B = ∅, constant nonlogical material), from Prop 4.12 and `cor:time:hard`.
7. **Prop 4.5's bound** updated to n − 1/(4 ln 2), as in TF Thm 3.2(c).
8. **The normal form of Prop 6.1** stated as "no blank written, no right move from a blank": the old informal condition (right moves only) would not exclude writing a blank inside the tape and then moving left, which is also unrepresentable.
9. **Conservativity of T_V** (Rem 6.4(3)): a candidate counterexample, ∀x R(s1(s1(x))), was considered and found blocked by the requirement that V output ⊥ on non-binary words. The question stays open.
10. **Prop 3.4's constant**: (p_N, 1) has weight 2^{−|p_N|−3}, so the AI loss is at most |p_N| + 3.
11. **The label `thm:setting:matching`** is not in this paper; it is the axiom-schemas paper's matching theorem (AS Thm 2.5), which `notes.md` meant. The citation is kept and now also gives the paper's name for it.

---

## 13. Answer to Hänni's proposal

Requiring derivations from short axioms makes axiom induction time-limited under one reading and not under another, and where it does, the limit is exponential deterministic time or nondeterministic (certificate) time, never a deterministic polynomial clock. Throughout, hypotheses are deciders of axiom sets closed under renaming parameters, with membership decidable in polynomial time in symbol size, data are labelled sentences, and losses are in the semimeasure convention. (1) If only the theory's own axioms must be short and the logical axioms are free (every nonlogical instance at most h(|φ|) symbols, or their total at most g(|φ|)), nothing is time-limited: on literal language sequences every decidable language is fitted by a finite set of universally closed Horn sentences, with B = ∅ (Prop 4.12), and on arbitrary sentences Hänni's two-sorted schema (arithmetic background true in ℕ) and, in one sort, a trace schema with a spare relation symbol keep the theories of unpenalised consistent function induction (Props 4.7, 4.8, Cor 4.9). Only Craig's padding and the bounded schema A^bd_f are blocked, the latter because its witness bound must grow for hard languages (Prop 4.6). (2) If every axiom instance used, logical ones included, must have at most h(|φ|) symbols, the limit is deterministic exponential time. In a derivation pruned to the conclusion's ancestors every line is, up to abstracting parameters, a subformula of an instance used or of φ (Lemma 2.2), so derivability is a closure over 2^{O(h log h)} formulas (Thm 4.2), while ground axioms of size O(h) simulate alternating space O(h) (Prop 4.3). At polynomial budgets the fit class is exactly EXPTIME (Cor 4.4), so this axiom induction has bounded loss on some sequence on which polynomial-time consistent function induction does not, unconditionally, and every predictor whose predictions are computable in time polynomial in the number of data (Hänni's S among them, given his running-time description) loses at least n − 0.361 bits on some literal sequence on which this axiom induction, at a linear budget, loses O(1) (Prop 4.5). The computation does move into the number of proof steps, as Hänni suspected, but there are at most exponentially many. (3) If the distinct axiom instances used, logical ones included, must be short in total, the proposal bounds derivation size up to squaring, M_min ≤ ℓ_min ≤ (M_min + |φ|)(M_min + |φ| + 1)/2 with the constant 1/2 attained (Cor 2.3, Prop 2.4), and axiom induction becomes certificate function induction: consistent assigners whose decisions are checked in polynomial time against certificates of polynomial length (Thm 3.1). This is the interesting time limit: the free resource is proof search, that is, guessing a certificate. At polynomial budgets with membership and budget degrees charged, its fit class is NP ∩ coNP; per sequence it beats polynomial-time consistent function induction if NP ∩ coNP ≠ P and has bounded loss on exactly the same sequences if P = NP, while the intermediate case and uniform domination are open, and without the degree charge function induction fails to dominate it unconditionally (Cor 3.2, Prop 3.4). Against clocked consistent function induction it wins unconditionally once the budget exceeds the clock by a hierarchy gap (Cor 3.2(e)). (4) A soft charge of 2^{−κ} per bit of each datum's shortest derivation corresponds to soft certificate function induction only up to a constant factor in the rate: at the common rate κ the certificate side is better by at least κ(2 + b_s·[label false]) bits per datum on every sequence, soft axiom induction is within a constant of certificate induction at rate (31b_s + 26)κ, and no pair of rates gives a two-sided constant-regret equivalence (Thm 5.2, Prop 5.3); no soft fit classes or separations are claimed. (5) Restricting to finite template theories loses nothing on literal data in fit classes, in derivation size up to polynomials, or in literal consequences: Horn templates simulate any certificate verifier with derivations quadratic in its running time, so `cor:time:hard` is tight up to polynomials (Prop 6.1, Cor 6.2); description length grows linearly rather than additively, and non-literal data are open. (6) The renaming hypothesis matters: without it a parameter's index, which costs one symbol, can carry an unpriced certificate (Prop 7.1); in the paper's symbol-count convention the coarse results (`thm:time:ntime`, NP ∩ coNP and EXPTIME) survive, but the 2^{O(h log h)} clock and the budget relation of Theorem 3.1 need the hypothesis (Thm 7.4).
