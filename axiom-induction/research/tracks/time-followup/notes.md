# Track "time-followup": the time penalty, after Hänni's objection

*Follow-up to paper Section 6 (`../../../paper/sections/time.tex`, `app-time.tex`) and model track §6, §9.3 (`../model/notes-final.md`). It answers Kaarel Hänni's objection to the sentence "The time penalty doesn't block your collapse argument. The collapse into function induction (with Craig's trick) survives a penalty on checking or generating axioms." His objection, verbatim: "if we penalize time on the function induction side and in the axiom generator but crucially NOT in the proof search from axioms, then intuitively i disagree with this: i think the time penalty should help? like the function induction guy that runs the proof search from axioms will be extremely slow; there's nothing comparably slow on the axiom induction side". Scripts are in `checks/`; each is seeded and writes `<name>.out` next to itself.*

**Status tags** (as in the model track).
* **[proved]**: full proof here. "Proved under (S)" means: given the machine assumption (S) of §1.2.
* **[proved, conditional on H]**: full proof from the stated complexity hypothesis H.
* **[proof sketch]**: the argument is given; the steps not written out are named.
* **[known]**: published, with reference; **(not checked)** means recalled, not checked against the source in this session.
* **[computed]**: checked by a script in `checks/`; the output file is named.
* **[conjecture]**, **[open]**, **[refuted]**.

**Paper labels** are cited as in the paper: `def:time:inducers`, `thm:time:equiv`, `prop:time:cheap`, `rem:time:summary`, `prop:time:fiall`, `prop:time:twosorted`, `prop:time:single`, `thm:time:ntime`, `cor:time:hard`, `prop:time:sigma`, `rem:time:upper`, `conj:time:polytime`. "Model §k" is `../model/notes-final.md`. "Hänni's S" is the predictor of `../../prior/hanni-polytime-solomonoff.md`.

---

## 0. The answer

### 0.1 One paragraph (H-e)

Hänni is right, and the sentence he replied to was too coarse. Hänni's equivalence (`thm:time:equiv`) has two halves, and a time penalty acts on them differently. The sentence was about the half FI → AI: every consistent assigner f, however slow, becomes an axiom system of description length |f| + c whose axioms are cheap to check and to enumerate (Craig's trick, padded by the enumerator's own running time). A penalty on checking or generating axioms therefore costs that half only a constant (O(log |f|) bits under a plain Kt penalty, a charge every program pays). Hänni points at the other half, AI → FI: an axiom system becomes the assigner "search for a proof", and no time bound admits that assigner. So if function induction is time-penalised and deduction is free, the equivalence becomes one-sided. Axiom induction, with or without an axiom-side penalty, has bounded regret against time-penalised consistent function induction (Theorem 3.1). The other way round, there is a computable sequence of arithmetic sentences, each decided by Q plus one true sentence, on which a given computable predictor loses at least n − 1 bits in n steps while axiom induction loses a constant. The predictor can be Hänni's polytime S or a clocked function-induction mixture, and every computable predictor has such a sequence (Theorem 3.2). In that sense the penalty helps: axiom induction becomes strictly stronger than every time-bounded function inductor. But this is not the help he wanted. With deduction free, axiom induction under an axiom-side penalty is equivalent, up to a constant, to *unpenalised* consistent function induction, and it is incomputable. The slow assigners the penalty was meant to remove are still in its posterior at weight 2^(−|f|−c). Their computation has moved into long padded axioms, or into the proofs of Acc_f(⌜φ⌝), and the posterior over theories moves by at most a constant factor (Proposition 5.1). The advantage of axiom induction over time-bounded function induction is exactly its free proof search, and the same advantage separates unbounded from time-bounded function induction (Proposition 4.1). Charge deduction too (derivations of at most d symbols, axiom membership in polynomial time), and axiom induction becomes equivalent to function induction over consistent assigners with certificates of length about d (Theorem 4.2). What is then left of his asymmetry is guessing proofs versus computing answers. Axiom induction is unconditionally stronger than FI_τ when d exceeds τ by a polynomial factor. At polynomial budgets it is stronger if NP ∩ coNP ≠ P, and not stronger if P = NP (Corollary 4.3).

### 0.2 Verdicts on the orchestrator's hypotheses

| hypothesis | verdict | where |
|---|---|---|
| **H-a** (FI → AI survives an axiom-side penalty) | **confirmed, with corrections.** Membership time (class version P1a) and enumeration time (P2): vacuous up to a constant. Generation time needs a *padded* Craig set; the paper's A^C_f is not cheap to enumerate ([proved], Rem 2.6; [computed] `c2`). Plain Kt (P1b): vacuous up to O(log \|f\|), a charge every program pays. Content-relative penalty (P3): bites on Craig-type sets, vacuous through Hänni's schema in two sorts, or in one sort for assigners consistent with true arithmetic; **open** in one sort for the rest. So `thm:time:equiv` survives: AI_pen ≡ unpenalised FIcons. A new one-sorted schema with numeral-bounded witnesses repairs Hänni's schema for every consistent assigner (model §10 problem 14) | Lemma 2.1, Thm 2.2, Props 2.3–2.5, Rem 2.6 |
| **H-b (i)** (AI ≥ FIcons_τ) | **confirmed** for every FI-side penalty that only shrinks the weights of consistent deterministic assigners. **Not** for Hänni's S, which is not restricted to consistent assigners: S beats AI by about n bits on the coin-flip sequences of `prop:time:fiall` | Thm 3.1, Prop 3.4 |
| **H-b (ii)** (diagonal separation) | **confirmed, with corrections.** For every computable predictor P (total on the histories it is asked about; approximate outputs allowed), P loses ≥ n − 1/(2 ln 2) bits and AI loses ≤ a constant independent of P. Q ∪ {DET} (one true Π₁ sentence) decides every sentence, so neither PA nor a background is needed. "Bounded sentences in Q" does not work as stated; the Rosser form or DET does. FIcons_τ is not given as a computable predictor (its consistency filter is co-r.e.), so it is handled by domination by the computable clocked FIall_τ mixture | Thm 3.2, Cor 3.3, Rem 3.5 |
| **H-c** (the separation comes from free deduction) | **confirmed.** The constant-size universal evaluator u wins on every diagonal sequence for unpenalised FI as well; the separation is a time-hierarchy effect. With deduction charged: AI[poly, d] ≡ FIcert[poly, Õ(d)] (new; answers model §10 problem 13 in the hard-cutoff form). The separation from FI_τ is then DTIME versus NTIME: unconditional for d ≫ τ, conditional on NP ∩ coNP ≠ P at polynomial budgets, absent if P = NP. `conj:time:polytime` stays a conjecture: its constant-regret part is trivial for a mixture, and its time-bounded part meets the NP ∩ coNP barrier for history-free predictors | Prop 4.1, Thm 4.2, Cor 4.3, Rems 4.4, 4.5 |
| **H-d** (axiom-side penalties do not favour genuine systems) | **confirmed** wherever deduction can verify computations (two sorts; one sort with assigners consistent with true arithmetic). Posterior odds between any two classes of theories move by at most 2^(2c). Counterpoint: in a decidable logic (monadic), a content-relative axiom penalty does bite [proof sketch]. In one sort, for assigners inconsistent with true arithmetic, P3 is **open** | Prop 5.1, Rems 5.2–5.4 |
| **H-e** | §0.1 | |

---

## 1. Setting and definitions

### 1.1 Data, inductors, losses

As in `def:time:inducers`. L is a countable first-order language, B a decidable background, data D = ((φ_1, b_1), …, (φ_n, b_n)) with b_i ∈ {1 (true), 0 (false)}. Write φ^1 := φ and φ^0 := ¬φ.

* **AI.** A hypothesis is a decider p of A_p ⊆ Sent_L. It is compatible with D if B ∪ A_p is consistent and B ∪ A_p ⊢ φ_i^{b_i} for every i. W_AI(D) := Σ_{p compatible} 2^{−|p|}.
* **FIcons.** A hypothesis is a program f computing a partial map Sent_L → {acc, rej}, with B ∪ Γ_f consistent, where Γ_f := {φ : f(φ) = acc} ∪ {¬φ : f(φ) = rej}. It is compatible with D if it labels every φ_i with b_i. W_FI(D) := Σ_{f compatible} 2^{−|f|}. **FIall** drops the consistency requirement.
* **Loss, semimeasure convention.** ℓ_X(D) := −log₂ W_X(D) + log₂ W_X(∅). It is the sum of the per-step losses −log₂(W_X(D_j)/W_X(D_{j−1})), and it depends on D only as a set.
* **Predictors.** A predictor P maps a history D_{j−1} and the next sentence φ_j to (q_0, q_1) with q_b ≥ 0 and q_0 + q_1 ≤ 1. Its loss is ℓ_P(D_n) := Σ_j −log₂ q_{b_j}(D_{j−1}, φ_j). For a mixture in the semimeasure convention the two definitions agree, by telescoping. P is a **computable predictor** if a total computable function maps (D, φ, k) to rationals a_0, a_1 with |a_b − q_b(D, φ)| ≤ 2^(−k). Exact rational outputs are a special case.
* **Regret and domination.** X *dominates* Y if sup_D (ℓ_X(D) − ℓ_Y(D)) < ∞, over all finite D in any order.

### 1.2 Machines and weights; assumption (S)

U is a universal prefix machine. time_p(x) is the number of steps U takes on (p, x) before it halts, having read exactly p. In particular time_p(x) ≥ |p|.

**Assumption (S) (efficient self-simulation)** [standard for multitape machines; assumed, not checked for a particular U]. There are fixed program prefixes and constants α, a ≥ 1, depending only on U, with the following property. For every program q, the program W⌢q (W fixed, followed by q) can run the *dovetailing schedule* on q: at stage s it starts q on the s-th sentence, and it advances every unfinished run by one simulated step. Along the way it maintains exactly a *work counter* T: the number of simulated steps, plus the lengths of the sentences started, plus |q|. Up to work T it spends at most α(T + 1)^a steps of U, not counting the steps spent writing output; writing a string of length L costs at most αL steps.

(S) is what lets one count simulated steps exactly, and it bounds the cost of simulation by a polynomial independent of q. All bounds below that mention α, a or t hold under (S).

**Clocked classes.** For a time-constructible τ, the τ-clocked version of a string f is f^τ(φ) := the output of a fixed plain universal machine on (f, φ) if it halts within τ(|φ|) steps with acc or rej, and "abstain" otherwise. Clocked classes weight f by w(f) := 2^(−|E(f)|), where E is a complete prefix code on strings (Elias δ, say; Σ_f w(f) = 1 and |E(f)| = |f| + O(log |f|)). Such weights have computable tails.

### 1.3 Penalty schemes

**Definition 1.1 (axiom-side penalties).** Fix a time-constructible reference bound t, by default t(m) = m^{a*}, with a* depending only on U, from Lemma 2.1. Compatibility is as for AI unless stated.
* **P1a (membership time, class version).** AI^chk_t: hypotheses are deciders p with time_p(χ) = O(t(|χ|)), with an asymptotic constant that may depend on p. Weight 2^(−|p|).
* **P1b (membership time, Kt version).** AI^Kt_t: weight 2^(−|p|)/c_p, where c_p := sup_χ time_p(χ)/t(|χ|) (weight 0 if c_p = ∞). This is Levin's Kt applied to the decider, as in model §1.3 and `rem:model:priors`(iii).
* **P2 (generation time).** AI^gen_t: hypotheses are *enumerators* g, programs without input that write a sequence a_1, a_2, …; A_g := {a_i}. Let e_i be the step at which a_i is completely written. *Strict form*: e_i = O(t(|a_i|)). *Cumulative form*: e_i = O(t(|a_1| + … + |a_i|)). Weight 2^(−|g|) if g meets the chosen form.
* **P3 (content-relative generation time).** AI^cont_t: a hypothesis is a program G that maps each sentence φ to a finite set G(φ) of sentences in time O(t(|φ|)); A_G := ∪_φ G(φ). G is compatible with D if B ∪ A_G is consistent and B ∪ G(φ_i) ⊢ φ_i^{b_i} for each i: the axioms needed for a datum are produced from the datum quickly. Weight 2^(−|G|).

P1 and P2 measure time against the length of the *axiom*. P3 measures it against the length of the *content*, the datum. All three leave deduction free.

**Definition 1.2 (FI-side penalties).**
* **FIcons_τ** (clocked): hypotheses are strings f with B ∪ Γ_{f^τ} consistent, weight w(f); compatible if f^τ labels every datum correctly. **FIall_τ**: the same without consistency. Both use clocks in the *sentence length*, so their hypotheses are assigners of bounded time, like a complexity class.
* **Kt- or speed-prior-weighted FIcons**: weights 2^(−|f|)/c_f, or 2^(−|f|)/(total time on the data). All that is used below is that each weight is at most a constant times 2^(−|f|).
* **Hänni's S** (`hanni-polytime-solomonoff.md`): a mixture over *all* predictors (probabilistic ones included) with time p(n) per step, n the number of labels seen, and a late start. It is computable and is not restricted to consistent assigners.

**Definition 1.3 (deduction charged).** Let B be decidable in polynomial time, and let d, t, t' be time-constructible.
* **AI[t, d]**: hypotheses are deciders p with time_p(χ) = O(t(|χ|)). p is compatible with D if B ∪ A_p is consistent and each φ_i^{b_i} has a K-derivation from B ∪ A_p of symbol size at most d(|φ_i|) (K is Mendelson's calculus, `model.tex` line 35). Weight 2^(−|p|).
* **FIcert[t', d']** (consistent assigners with certificates): a hypothesis is a program V with time_V(φ, c) = O(t'(|φ| + |c|)) on all inputs, with outputs in {acc, rej, ⊥}. Put f_V(φ) := acc if some c with |c| ≤ d'(|φ|) has V(φ, c) = acc, rej if some such c has V(φ, c) = rej, and undefined otherwise. Require B ∪ Γ_{f_V} consistent; this also rules out both labels for one φ. V is compatible if f_V labels every datum correctly. Weight 2^(−|V|).

---

## 2. FI → AI under axiom-side penalties (H-a)

**Lemma 2.1 (padded sets) [proved under (S)].** Let q be a program, and S_q the set of sentences on which q halts with output "yes". Run the dovetailing schedule on q. When it first detects that q says yes on χ, at work counter T, emit χ^(T+1), the (T+1)-fold right-nested conjunction. Let Pad(q) be the set of emitted sentences. Then:

(a) Cn(B ∪ Pad(q)) = Cn(B ∪ S_q).

(b) A decider d_q = W_dec⌢q decides Pad(q) with time_{d_q}(χ) ≤ α'(|χ| + |q| + 1)^{a'}. Hence time_{d_q}(χ) = O(|χ|^{a'}) for fixed q, and c_{d_q} ≤ α'(|q| + 2)^{a'} for t(m) := m^{a'}.

(c) An enumerator e_q = W_enum⌢q writes Pad(q). Its i-th output is completely written by step α''·|a_i|^{a''} (strict form), and by step 2α(|a_1| + … + |a_i|)^a (cumulative form).

(d) |d_q|, |e_q| ≤ |q| + c, and q ↦ d_q, q ↦ e_q are injective.

Here α', a', α'', a'' depend only on U. The default t of Definition 1.1 has a* := max(a', a'', a, 3).

*Proof.*
* (a) χ^m is logically equivalent to χ. Each χ ∈ S_q is detected exactly once, so it has exactly one padded copy. Every member of Pad(q) is a padded copy of a member of S_q.
* (b) If χ' = ψ^m with m ≥ 2, then ψ is the left immediate subformula of χ', and m is then fixed by |χ'|. The only other candidate is m = 1, ψ = χ'. So there are at most two candidates, found and compared in O(|χ'|²) steps. For a candidate (ψ, m), run the dovetailing schedule, without writing, until the work counter passes m − 1. Accept iff q is detected saying yes on ψ exactly when the counter equals m − 1. Since m ≤ |χ'|, this costs at most α(|χ'| + 1)^a steps by (S), plus |q| to finish reading the program. The decider halts on every input, also when q is partial, because the run is bounded by the counter.
* (c) Let T_i be the counter when a_i is emitted. Before writing, the time is at most α(T_i + 1)^a. Writing a_1, …, a_i costs at most α(|a_1| + … + |a_i|). Now |a_i| ≥ T_i + 1. At most T_i axioms were emitted before a_i, each of the form χ_j^{m_j} with m_j ≤ T_i + 1 and |χ_j| ≤ T_i (the length of χ_j is part of the counter). So Σ_{j≤i} |a_j| ≤ 4(T_i + 1)³ ≤ 4|a_i|³. Both forms follow.
* (d) d_q and e_q are fixed wrappers followed by q. ∎

**[computed: `checks/c2_padding.out`]** On five toy assigners, whose own running time ranges from below |φ| to 4^{|w|}, membership work stays below 2|χ|. Completion time stays below 2·(cumulative length), and below |a_i|² ("work" padding). With padding by total elapsed time (writing included), completion stays below 2|a_i|, at the price of geometrically growing axiom lengths. For the *unpadded* Craig set A^C_f, membership work is also below 2|χ|, but completion time over |a_i| reaches 1.1·10⁴, and over cumulative length 10.0 for the slowest assigner. The dovetailing delay is what the padding absorbs.

**Theorem 2.2 (axiom-side penalties are vacuous up to a constant) [proved under (S)].** Let t be the default bound. There is a constant c, depending only on U, the coding and B, such that for every finite D:

(a) 2^(−c)·W_FI(D) ≤ W_{AI^chk_t}(D) ≤ W_AI(D) ≤ 2^c·W_FI(D);

(b) 2^(−c)·W_FI(D) ≤ W_{AI^gen_t}(D) ≤ 2^c·W_FI(D), for the strict and the cumulative form alike.

Hence the semimeasure losses of AI, AI^chk_t, AI^gen_t and *unpenalised* FIcons differ pairwise by at most a constant, on every D in every order. `thm:time:equiv` survives these penalties.

*Proof.*
* *Lower bounds.* For an FIcons hypothesis f, let q_f answer yes on φ if f(φ) = acc, and on ¬φ if f(φ) = rej. Then S_{q_f} = Γ_f and |q_f| ≤ |f| + c.
  * By Lemma 2.1(a), Cn(B ∪ Pad(q_f)) = Cn(B ∪ Γ_f). This is consistent, and it decides each datum as f does. So d_{q_f} (respectively e_{q_f}) is compatible whenever f is.
  * By Lemma 2.1(b), (c), it meets P1a (respectively P2).
  * The maps are injective and add at most a constant to the length.
* *Upper bounds.* AI^chk_t has a subset of AI's hypotheses with the same weights. For (b), map an enumerator g to f_g := "search for proofs of φ and of ¬φ from B ∪ A_g" (A_g is r.e.). Then |f_g| ≤ |g| + c, and f_g is compatible when g is (argument of `thm:time:equiv`).
* *Losses.* Each of the two terms of ℓ changes by at most c. ∎

**Proposition 2.3 (the Kt version: O(log |f|), a charge every program pays) [proved under (S)].**
(i) For every decider p, c_p ≥ |p|/t(m_0), with m_0 the least length of a sentence. So the weight of p in AI^Kt_t is at most 2^(−|p| − log₂|p| + log₂ t(m_0)).
(ii) For every D, ℓ_{AI^Kt_t}(D) ≤ min_{f ∈ FIcons compatible with D} (|f| + a'·log₂(|f| + 2)) + c.

*Proof.*
* (i) time_p(χ) ≥ |p| for every χ, so the supremum is at least |p|/t(m_0).
* (ii) By Lemma 2.1(b), c_{d_{q_f}} ≤ α'(|f| + c + 2)^{a'}. So d_{q_f} has weight at least 2^(−|f| − c − a'·log₂(|f|+2) − log₂ α'), and W_{AI^Kt}(∅) ≤ 1. ∎

So under P1b a slow assigner loses at most a'·log₂(|f| + 2) + c bits against its unpenalised weight, while every hypothesis of length L already pays log₂ L − O(1). Measuring the time against t(|χ| + |p|) instead of t(|χ|) removes both charges.

**Proposition 2.4 (the content-relative penalty P3).**

(a) **It bites on Craig-type sets [proved, given the deterministic time hierarchy theorem (known)].** Below, q is the fixed polynomial overhead of running U-programs on a Turing machine. Let L ⊇ {0, S, +, ·, R}, B = ∅, φ_w := R(ν(w)) as in `thm:time:ntime`, and D^X the data (φ_w, [w ∈ X]) for all words w in length-lexicographic order. Suppose an AI^cont_t hypothesis G is compatible with every prefix of D^X, and every member of every G(φ) has the form ψ^m with ψ a literal ±φ_{w'}. Then X ∈ DTIME(q(t)).
* *Proof.* B ∪ A_G is consistent, so G(φ_w) is a consistent set of literals on atoms. A consistent set of literals not containing a power of φ_w (respectively ¬φ_w) does not imply φ_w (respectively ¬φ_w): take ℕ with R chosen to satisfy the set and to falsify φ_w (respectively satisfy it). So w ∈ X iff G(φ_w) contains some φ_w^m (numerals for distinct words denote distinct numbers). Computing G(φ_w) and scanning it takes O(q(t(|φ_w|))) time. ∎
* By the time hierarchy theorem there is a decidable X ∉ DTIME(q(t)). For such X, no Craig-type AI^cont_t hypothesis fits D^X, while FIcons has f_X.

(b) **It is vacuous in two sorts [proved, given `prop:time:twosorted`].** In the two-sorted setting of `prop:time:twosorted` (B ⊇ Q on the arithmetic sort), let G_f(φ) := {Acc_f(⌜φ⌝) → φ, Rej_f(⌜φ⌝) → ¬φ}.
* G_f runs in time polynomial in |φ| (with |f| additive), A_{G_f} = A_f, and |G_f| ≤ |f| + c.
* If f is compatible with D, then B ∪ A_f is consistent (`prop:time:twosorted`). If f(φ_i) = acc, Q ⊢ Acc_f(⌜φ_i⌝) (Σ₁-completeness), so B ∪ G_f(φ_i) ⊢ φ_i by MP; rejections likewise.
* Hence W_{AI^cont_t}(D) ≥ 2^(−c)·W_FI(D) for a fixed polynomial t, and AI^cont_t ≡ FIcons up to a constant.

(c) **It is vacuous in one sort for assigners consistent with true arithmetic [proved].** Let L ⊇ L_A (one sort), B = PA, and let f be an assigner with Th(ℕ) ∪ Γ_f consistent. Then PA ∪ A_f is consistent, and G_f is compatible with D whenever f is.
* *Proof.* Take M ⊨ Th(ℕ) ∪ Γ_f. Its L_A-reduct is elementarily equivalent to ℕ, so for every standard sentence φ, M ⊨ Acc_f(⌜φ⌝) iff f accepts φ.
* If f accepts φ, then φ ∈ Γ_f and M ⊨ φ. So M satisfies every member of A_f, and M ⊨ PA.
* Derivations are as in (b). ∎

(d) **[open]** In one sort, for assigners with PA ∪ Γ_f consistent but Th(ℕ) ∪ Γ_f inconsistent (the f of `prop:time:single`, say), it is open whether some AI^cont_t hypothesis with polynomial t has the consequences of Γ_f.
* Hänni's schema is then inconsistent (`prop:time:single`).
* The two repairs available, Craig's and Proposition 2.5's, both carry at least log₂ of a computation witness in the axiom needed for φ, so P3 bites on both (part (a), and Proposition 2.5(c)).

**Proposition 2.5 (a one-sorted repair of Hänni's schema for every consistent assigner) [proved, given the known facts about Q cited].** Let L ⊇ L_A (one sort) and B ⊇ Q.
* *The formulas.* Write Acc_f(x) = ∃y θ_f(x, y) with θ_f Δ₀ (every r.e. relation is Σ₁, i.e. ∃ followed by Δ₀ [known]), so that ℕ ⊨ ∃y θ_f(⌜φ⌝, y) iff f accepts φ; Rej_f likewise with η_f. Bounded quantifiers are written without <, as in the paper.
* *The bounded formula.* Acc_f^{≤k}(x) := ∃y (∃z (z + y = k̄) ∧ θ_f(x, y)), with k̄ a binary numeral.
* *The schema.* A^bd_f := {Acc_f^{≤k}(⌜φ⌝) → φ : φ ∈ Sent_L, k ∈ ℕ} ∪ {Rej_f^{≤k}(⌜φ⌝) → ¬φ : φ ∈ Sent_L, k ∈ ℕ}.

Then:

(a) Cn(B ∪ A^bd_f) = Cn(B ∪ Γ_f). In particular B ∪ A^bd_f is consistent iff B ∪ Γ_f is, for sound and unsound assigners alike.

(b) Membership in A^bd_f is decidable in time polynomial in |χ| without running f: parse χ against the fixed formula with two numeral slots, and compare one slot with ⌜φ⌝.

(c) Let w_f(φ) be the least witness of f's decision on φ, and suppose B together with the decisions whose witnesses are below w_f(φ) does not prove φ^{b}. Then every finite F ⊆ A^bd_f with B ∪ F ⊢ φ^{b} contains an axiom with k ≥ w_f(φ), so with a numeral of at least log₂ w_f(φ) symbols.

*Proof.*
* (a) Fix φ and k.
  * If f accepts φ with least witness w ≤ k, the sentence Acc_f^{≤k}(⌜φ⌝) is true and Σ₁, so Q proves it [Σ₁-completeness; known]. The axiom is then Q-equivalent to φ ∈ Γ_f.
  * Otherwise θ_f(⌜φ⌝, j̄) is a false Δ₀ sentence for every j ≤ k, and Q refutes each [Δ₀-completeness of Q; known]. Also Q ⊢ ∃z(z + y = k̄) → y = 0̄ ∨ … ∨ y = k̄ [known; P. Smith, *An Introduction to Gödel's Theorems*, the list of properties of Q (numbering not checked)]. So Q ⊢ ¬Acc_f^{≤k}(⌜φ⌝), and the axiom is a Q-theorem.
  * Rejections are the same.
  * So every axiom is, over Q ⊆ B, equivalent to a member of Γ_f or to a theorem, and every member of Γ_f has its axiom (take k = w). Hence the claim.
* (b) Immediate.
* (c) By (a), B ∪ F is equivalent to B together with the decisions whose witnesses are at most the largest k in F. ∎

In the counterexample of `prop:time:single`, every axiom Acc_f^{≤k}(⌜Con(PA)⌝) → Con(PA) has a false Δ₀ antecedent and is a Q-theorem. The nonstandard proofs of ⊥ that break Hänni's schema are out of reach, because the schema mentions only standard bounds. This answers model §10 problem 14 ("a single-sorted repair … short of Craig's trick") affirmatively. Membership is syntactic and f is never run. The bound k plays the role of Craig's padding, but carries only log k symbols.

**Remark 2.6 (what `rem:time:summary`(1) and §6.4 of the paper say, made precise).**
1. "The collapse … survives a penalty on checking or generating axioms." This is true of the FI → AI half, with a constant cost for P1a and P2 (Theorem 2.2) and O(log |f|) for P1b (Proposition 2.3). The paper's remark said "no bound on how much it changes `thm:time:equiv` is claimed"; these are the bounds.
2. "Penalising the time to generate axioms fails too: φ^(k+1) ∈ A^C_f comes from k steps of f and is longer than k." This is correct per axiom given its content: from φ, the Craig axiom is produced in about k steps and is longer than k.
   It is **not** correct for an enumerator of A^C_f, which has to dovetail [refuted for the enumeration reading; proved below, illustrated by `c2`, rows "none"].
   * *Strict form.* If f decides every sentence within |φ| steps, the axiom for the s-th sentence has length O(log² s) but cannot be completed before stage s.
   * *Cumulative form.* Let f decide the s-th sentence within |φ_s| steps when s is a power of 2, and loop otherwise. At stage s = 2^j about s runs are active, so the j-th axiom is completed after at least about s²/4 steps, while the j axioms written so far have total length O(j³) = O(log³ s).
   * *Fix.* Lemma 2.1's padding by the enumerator's own counter.

   Measured against the content instead (P3), the penalty does bite on Craig sets (Proposition 2.4(a)). It is vacuous only through a schema that moves f's computation into deduction (Proposition 2.4(b), (c)).
3. None of this concerns the AI → FI half, which is §3.

---

## 3. AI → FI under an FI-side penalty: the equivalence becomes one-sided (H-b)

**Theorem 3.1 (axiom induction dominates time-penalised consistent function induction) [proved; under (S) for the penalised AI variants].** Let Y be an inductor with W_Y(D) = Σ_{h compatible with D} v(h). Suppose each hypothesis h is a consistent assigner, maps injectively to an FIcons hypothesis g_h with Γ_{g_h} = Γ_h, and has v(h) ≤ K·2^(−|g_h|); and suppose W_Y(∅) ≥ κ > 0. Let X be any of AI, AI^chk_t, AI^gen_t, FIcons, and, in two sorts, AI^cont_t. Then for every D,

  ℓ_X(D) ≤ ℓ_Y(D) + log₂(K/κ) + c.

Examples of Y:
* FIcons_τ: g_f := a wrapper running f^τ followed by E(f), so |g_f| = |E(f)| + c_τ and K = 2^{c_τ}. κ is the weight of the always-abstain string.
* Kt- or speed-prior-weighted FIcons.
* The consistent part of any time-bounded mixture of deterministic assigners.

*Proof.*
* By Theorem 2.2 (or `thm:time:equiv` for X = AI; Proposition 2.4(b) for AI^cont), W_X(D) ≥ 2^(−c)·W_FI(D) ≥ 2^(−c)·K^(−1)·W_Y(D).
* So ℓ_X(D) = −log₂ W_X(D) + log₂ W_X(∅) ≤ −log₂ W_Y(D) + log₂ K + c, using W_X(∅) ≤ 1 (Kraft).
* And −log₂ W_Y(D) = ℓ_Y(D) − log₂ W_Y(∅) ≤ ℓ_Y(D) + log₂(1/κ). ∎

**Theorem 3.2 (diagonal separation) [proved].** Let L ⊇ L_A (one sort) and let B be decidable and true in some expansion of ℕ to L (B = ∅ is allowed). Fix Kleene's T predicate T(e, x, c) and an output relation Out(c, y), both Δ₀ under a standard coding [known; Hájek–Pudlák 1993, Ch. I (not checked)]. Let DET be the true Π₁ sentence

  ∀e ∀x ∀c ∀c' ∀y ∀y' (T(e,x,c) ∧ T(e,x,c') ∧ Out(c,y) ∧ Out(c',y') → y = y'),

a theorem of PA [known; determinism of computations]. Put H_0 := Q ∪ {DET}, a finite set of true sentences. For every computable predictor P there is a program e such that, with

  s_n := ∃c (T(ē, n̄, c) ∧ Out(c, 1̄))   and   b_n := 1 if ℕ ⊨ s_n, else 0,

the following hold.

(a) e computes a total function, and e(n) = b_n ∈ {0, 1} for every n.

(b) H_0 ⊢ s_n if b_n = 1, and H_0 ⊢ ¬s_n if b_n = 0.

(c) For every n, ℓ_P(D_n) ≥ n − 1/(2 ln 2) ≥ n − 0.73, and ℓ_P(D_n) ≥ n if P's outputs are exact.

(d) Every variant of AI in which H_0 is an admissible hypothesis of weight ω > 0 has ℓ(D_n) ≤ log₂(1/ω) for all n. This covers AI, AI^chk_t, AI^Kt_t and AI^gen_t (H_0 is finite, so its decider and enumerator are cheap), and AI^cont_t (G(φ) := H_0). If B ⊇ H_0, the empty hypothesis serves instead. The bound does not depend on P.

*Proof.*
* *The construction.* Let G(e', n) be the program that, for j = 1, …, n:
  * forms σ_j := ⌜∃c (T(ē', j̄, c) ∧ Out(c, 1̄))⌝;
  * asks P for approximations (a_0, a_1), within 2^(−j−3), of its predictive pair on the history ((σ_1, β_1), …, (σ_{j−1}, β_{j−1})) and the sentence σ_j;
  * sets β_j := 0 if a_0 ≤ a_1, and β_j := 1 otherwise;

  and then outputs β_n. G is total computable, because P is total and G makes finitely many calls.
* *The recursion theorem.* By Kleene's second recursion theorem [known; Rogers 1967, §11.2 (not checked)] there is e with e(n) = G(e, n) for all n.
* (a) The values β_1, …, β_j computed inside G(e, n) do not depend on n. So e(j) = β_j, and σ_j = s_j. Since e(n) ∈ {0, 1}, ℕ ⊨ s_n iff e(n) = 1, so b_n = β_n. In particular the histories that P is asked about are the true D_{j−1}. [computed: `c1_diagonal.out`, Part B, rebuilds D(n) from scratch for n ≤ 150 and finds the labels consistent.]
* (b)
  * If b_n = 1, s_n is a true Σ₁ sentence, so Q proves it [Σ₁-completeness; known].
  * If b_n = 0, let c_0 code the halting computation of e on n. Then T(ē, n̄, c̄_0) ∧ Out(c̄_0, 0̄) is a true Δ₀ sentence and Q proves it. From s_n, DET and this sentence, H_0 derives 1̄ = 0̄, while Q ⊢ 1̄ ≠ 0̄ (axiom Sx ≠ 0). So H_0 ⊢ ¬s_n.
* (c) Let q_b := q_b(D_{j−1}, s_j). Then
  q_{b_j} ≤ a_{b_j} + 2^(−j−3) ≤ (a_0 + a_1)/2 + 2^(−j−3) ≤ (q_0 + q_1)/2 + 2^(−j−2) ≤ 1/2 + 2^(−j−2).
  * So −log₂ q_{b_j} ≥ 1 − log₂(1 + 2^(−j−1)) ≥ 1 − 2^(−j−1)/ln 2.
  * Summing over j ≤ n gives at least n − 1/(2 ln 2).
  * With exact outputs, q_{b_j} ≤ 1/2 at every step.
  * If q_{b_j} = 0, the loss is infinite.
* (d) H_0 is true in ℕ and B in an expansion of ℕ, so B ∪ H_0 is consistent, and by (b) H_0 is compatible with every D_n. So W(D_n) ≥ ω, and W(∅) ≤ 1. ∎

**[computed: `checks/c1_diagonal.out`]** The construction was run against eight predictors: KT, Laplace, a Markov-mixture, a toy clocked FIall mixture with partial hypotheses (q_0 + q_1 < 1), a late-start mixture in the style of S, a deficient semimeasure, a predictor sitting within the approximation error of 1/2, and one that reads the sentence index. Approximations were exact, seeded-random and adversarial. Over 2000 steps every case satisfies ℓ_n ≥ n − 0.7213 at every n, and ℓ_n ≥ n in exact mode. The adversarial near-1/2 case reaches ℓ_n − n = −0.313, which exercises the precision bound.

**Corollary 3.3 [proved].**

(a) **Hänni's S** is a computable predictor (an explicit algorithm). On its diagonal sequence, ℓ_S(D_n) ≥ n − 0.73 while ℓ_AI(D_n) ≤ log₂(1/ω). The same holds for the clocked FIall_τ, after mixing in a uniform component. Put P(D) := (W_{FIall_τ}(D) + 2^(−|D|))/(W_{FIall_τ}(∅) + 1). Its weights are computable reals, since clocked compatibility is decidable and the weight tails are computable (§1.2), and P(D) ≥ 2^(−|D|−1) > 0, so its ratios are computable.

(b) **FIcons_τ.** Its weights involve the consistency of B ∪ Γ_{f^τ}, a co-r.e. condition, so it is not given as a computable predictor and (c) of Theorem 3.2 does not apply to it directly. But W_{FIcons_τ}(D) ≤ W_{FIall_τ}(D) ≤ (W_{FIall_τ}(∅) + 1)·P(D) ≤ 2P(D). Hence ℓ_{FIcons_τ}(D_n) ≥ ℓ_P(D_n) − 1 + log₂ W_{FIcons_τ}(∅) ≥ n − 1.73 − c_⊥ on P's diagonal sequence, where c_⊥ := −log₂ w(always abstain). Together with Theorem 3.1, the regret of FIcons_τ against AI is bounded above uniformly and is at least n − O(1) on some computable sequence.

(c) **Incomputability.** No partial computable function gives approximations of the predictive probabilities of AI on every pair (D, φ) with W_AI(D) > 0. The same holds for AI^chk_t, AI^Kt_t, AI^gen_t, AI^cont_t and FIcons.
* *Proof.* If one did, run the construction of Theorem 3.2 with it in place of P; the recursion theorem applies to partial computable G. By induction on j, G(e, n) halts. If β_1, …, β_{j−1} have been computed, they are the true labels of s_1, …, s_{j−1}, so H_0 is compatible with D_{j−1} and W(D_{j−1}) ≥ ω > 0, and the query on (D_{j−1}, s_j) returns. The per-step losses of this predictor telescope to ℓ_AI. So (c) and (d) give n − 0.73 ≤ log₂(1/ω) for all n, a contradiction.
* For FIcons, use the constant-size assigner u of Proposition 4.1 instead of H_0. ∎

**Proposition 3.4 (S and AI are incomparable) [proved, given Hänni's theorem for S (his proof; he marks it "not checked completely carefully")].**
* On the sequences of `prop:time:fiall` (literals R(w_i) or ¬R(w_i) by fair coins, all labelled true), S sees the label bits 1, 1, 1, …. It contains a constant predictor of 1, so its loss is bounded by Hänni's theorem.
* On the same sequences, AI's expected loss is at least n (`prop:time:fiall`).
* On the diagonal sequences, S loses n − O(1) and AI a constant.

So "AI ≥ S" is false. The fair comparison is with the consistent class FIcons_τ, as the paper argued for the unpenalised case.

**Remark 3.5 (what the arithmetic buys; other languages).**
* In any language with infinitely many logically independent sentences (e.g. atoms R(c_n)), the same diagonal labels are fitted by the consistent assigner f_D ("run D"). Its length is |P| + c, so FIcons, and AI by `thm:time:equiv`, still lose at most |P| + c. Arithmetic makes the constant independent of P (the hypothesis H_0, or u in Proposition 4.1).
* The recursion theorem can be avoided with a fresh predicate R and the hypothesis H_0 ∪ {∀x (R(x) ↔ ∃c (T(ḡ, x, c) ∧ Out(c, 1̄)))}, at a cost of |P| + c bits.
* The orchestrator's variant "decided by Q if written as bounded sentences" fails as stated. A bound in s_n would have to exceed the length of D's own computation on n, which includes the query on s_n. It works only if P's running time has a known computable bound. Two alternatives work: Q ∪ {DET}, or the Rosser form ∃c (T ∧ Out(c,1̄) ∧ ∀c' ≤ c ¬(T(ē,n̄,c') ∧ Out(c',0̄))), which Q decides using Q ⊢ ∀x (x ≤ n̄ ∨ n̄ ≤ x) [known; Smith, properties of Q (not checked)].

---

## 4. Where the separation comes from (H-c)

**Proposition 4.1 (the universal evaluator; a time-hierarchy effect) [proved; (c) proof sketch].**

(a) Let u be the assigner that, on input ∃c (T(ē, n̄, c) ∧ Out(c, 1̄)), runs e on n and outputs acc if the result is 1 and rej if it is anything else (looping if e loops), and that abstains on all other inputs. Γ_u ⊆ Th(ℕ), so u is consistent with every B ⊆ Th(ℕ). |u| is a constant.

(b) On every diagonal sequence of Theorem 3.2, u labels every datum correctly. So *unpenalised* FIcons (and FIall) has ℓ ≤ |u| + c there, and beats every computable predictor by n − O(1), exactly as AI does. Its running time on s_n is at least that of D on n, i.e. at least the total time P spends on the first n predictions. The proof-search assigner f_{H_0}, which AI's hypothesis H_0 becomes under `thm:time:equiv`, is slower still.

(c) [proof sketch, resting on Hänni's theorem] Against Hänni's S_p (per-step time p(n) log n, with state reuse), the diagonal labels are produced by a predictor with per-step time O(p(n) log n) and state reuse. That predictor predicts its own labels with certainty. So S_{p'} for a slightly larger p' has bounded loss on the sequence that defeats S_p. Not written out: Hänni's apples-to-apples version, and the RAM-model caveat he names.

*Proof of (a), (b).* u's decisions are correct in ℕ. The rest is Theorem 3.2(a). ∎

So the separation of §3 does not come from axioms as such. Unbounded consistent function induction has it too, through the single constant-size hypothesis u. Free proof search in AI is free evaluation of u in FI. Under a time bound, the separation is a hierarchy effect: whatever the bound, the sequence that defeats it is computable with a slightly larger one.

**Theorem 4.2 (charged deduction: axiom induction ≡ certificate function induction) [proved].** Let B be decidable in polynomial time, and d, t time-constructible and nondecreasing. There are a constant c and fixed polynomials, depending only on U, K, the codings and B, such that for every finite D:

(a) W_{AI[t, d]}(D) ≤ 2^c · W_{FIcert[t⁺, d']}(D), with t⁺(m) := m^{k_0}·(t(m) + 1) and d'(m) := β·d(m)·log₂(d(m) + 2);

(b) W_{FIcert[t', d']}(D) ≤ 2^c · W_{AI[t'^#, d^#]}(D), with t'^#(m) := m^{k_1} + t'(m) and d^#(m) := γ(m + d'(m) + 1).

*Proof of (a).*
* *The map.* For a decider p let V_p(φ, c) := "if c codes a K-derivation of φ (respectively ¬φ) from B ∪ A_p of symbol size at most d(|φ|), output acc (respectively rej); otherwise ⊥".
  * A derivation of symbol size s has a bit code of length at most β·s·log₂(s + 2) (de Bruijn indices or variable numbers), whence d'.
  * Checking a line takes polynomial time for logical axioms (A4 included, by first-order matching), for B, for MP and for Gen, and O(t(|c|)) for membership in A_p via p. So V_p runs in time O(t⁺(|φ| + |c|)) on all inputs.
* *Compatibility.* Let p be compatible with D. Then B ∪ A_p is consistent, so no φ has both an acc and a rej certificate, and Γ_{f_{V_p}} ⊆ Cn(B ∪ A_p) is consistent with B. Each datum φ_i^{b_i} has a derivation within d(|φ_i|), which is a certificate. So f_{V_p}(φ_i) = b_i, and V_p is compatible.
* *Weights.* |V_p| ≤ |p| + c and p ↦ V_p is injective. ∎

*Proof of (b).*
* *The certificate sentences.* Let τ_0 := ∀x (x = x), τ_1 := ¬¬∀x (x = x), τ_E := ∀x (x = x) → ∀x (x = x). Put θ_ε := τ_E and θ_{bc} := (τ_b ∧ θ_c). Each θ_c is logically valid, and c is read off θ_c uniquely.
* *The axiom set.* For a hypothesis V let A_V := {φ ∧ θ_c : V(φ, c) = acc, |c| ≤ d'(|φ|)} ∪ {¬φ ∧ θ_c : V(φ, c) = rej, |c| ≤ d'(|φ|)}.
* *Membership.* Given χ, parse it as ψ ∧ θ. This is unique by unique readability, since ψ is the left immediate subformula. Read c off θ and check |c| ≤ d'(|·|); d' is time-constructible, so the comparison can stop after |c| + 1 steps. Accept iff V(ψ, c) = acc, or ψ = ¬φ and V(φ, c) = rej. Time O(t'^#(|χ|)), and the decider p_V has |p_V| ≤ |V| + c.
* *Consequences.* Each axiom is logically equivalent to its member of Γ_{f_V}, and each member of Γ_{f_V} has at least one certificate axiom. So Cn(B ∪ A_V) = Cn(B ∪ Γ_{f_V}), which is consistent.
* *Derivations.* For a datum with f_V(φ_i) = b_i, take a certificate c with |c| ≤ d'(|φ_i|). The derivation cites φ_i^{b_i} ∧ θ_c, then an instance of a fixed K-derivation of the tautology (B ∧ C) → B with B := φ_i^{b_i} and C := θ_c, then MP.
  * Here ∧ abbreviates ¬(B → ¬C), as K's connectives are ¬ and →.
  * Substituting into a fixed propositional derivation gives a derivation whose size is linear in |B| + |C| [known: completeness of the propositional fragment; substitution instances of derivations are derivations].
  * |θ_c| ≤ 12|c| + 17 in the string syntax of `c3`. So the size is at most γ(|φ_i| + |c| + 1) ≤ d^#(|φ_i|). ∎

**[computed: `checks/c3_certificate.out`]** The construction (b) was run for X := {n : the least prime factor of n is 1 mod 4}, which is in NP ∩ coNP via factorisations checked by deterministic Miller–Rabin.
* Unique parsing holds on 3000 random (ψ, c), including ψ built from the τ tokens.
* The decider accepts the right polarity and rejects the wrong one, as well as tampered certificates: composite factor, unsorted, wrong product, over-long.
* |χ| ≤ |ψ| + 12|c| + 20 and |c| ≤ 3|φ| + 8 on 210 cases up to 60-bit n (|φ| up to 63).
* Decider work stays below |χ|³ and never factors.
* By contrast, trial division, a deterministic assigner, needs up to 1.0·10⁹ steps on the 60-bit semiprimes. Its unpadded Craig axioms would be about 7·10¹⁰ symbols long, against about 1350 for the certificate axioms.

**Corollary 4.3 (what is left of the asymmetry when deduction is charged).**

(a) **[proved under (S)]** FIcons_τ is dominated by AI[t_C, d_τ], with t_C a fixed polynomial and d_τ(m) := γ(τ(m) + 1)(m + 4). The map is Craig's: membership in A^C_{f^τ} as in `prop:time:cheap`(b); derivation by citing φ^(k+1) with k ≤ τ(|φ|), then (B ∧ C) → B, then MP. Alternatively, Theorem 4.2(b) with f's computation trace as certificate gives membership time poly(m) and d ≈ τ log τ.

(b) **[proved]** AI[t, d] ≤ 2^c·FIcons_{τ_d} hypothesis by hypothesis, with τ_d(m) := 2^{d'(m)+1}·t⁺(m + d'(m)), by brute force over certificates in Theorem 4.2(a). This is deterministic exponential time.

(c) **Language sequences [proved].** For X ⊆ {0,1}*, let D^X be the sequence of (φ_w, [w ∈ X]) over all words w in length-lexicographic order, with φ_w as in `thm:time:ntime` and B = ∅.
* (i) ℓ_{FIcons_τ}(D^X_n) stays bounded iff some τ-clocked f labels every φ_w correctly; otherwise it tends to ∞. So bounded loss implies X ∈ DTIME(q(τ)), q the clocked-simulation overhead, and a decision procedure for X that fits the clock τ gives bounded loss.
* (ii) ℓ_{AI[t,d]}(D^X_n) stays bounded iff some single p gives every datum a derivation within d. Then X ∈ NTIME ∩ coNTIME(poly(d)·t(d)) (`thm:time:ntime`, applied to X and its complement). Conversely, if X and its complement have verifiers in time t' with certificates of length at most d', then AI[t'^#, d^#] has bounded loss (Theorem 4.2(b); the literals are consistent: interpret R as X).
* *Proof.* "If" is immediate: W(D_n) is at least the weight of that hypothesis, and W(∅) ≤ 1. "Only if": if no hypothesis fits all of D^X, each compatible-set indicator falls to 0 at some finite n. Since Σ weights ≤ 1, W(D^X_n) → 0 by dominated convergence, so ℓ → ∞. A hypothesis that fits all of D^X gives the stated algorithm. ∎

(d) **Unconditional separation [proved, given the deterministic time hierarchy theorem (known; Hartmanis–Stearns 1965 with the Hennie–Stearns simulation, exact form not checked)].** For time-constructible τ and τ₂ with q(τ)·log q(τ) = o(τ₂), there is a decidable X ∈ DTIME(τ₂) ∖ DTIME(O(q(τ))). Then ℓ_{FIcons_τ}(D^X_n) → ∞, while AI[t_C, d_{τ₂}] has bounded loss on D^X, by (a) applied to the τ₂-time assigner f_X.

(e) **Polynomial budgets [proved, conditional on the stated hypothesis].** Let FIcons_poly mix over pairs (f, k) with clock (m+2)^k and weight w(f)·2^(−2⌈log₂(k+1)⌉−1). Let AI[poly, poly] mix over pairs (p, j), with p of polynomial membership time, derivation budget (m+2)^j and weight 2^(−|p|−2⌈log₂(j+1)⌉−1).
* If NP ∩ coNP ≠ P, then for X ∈ (NP ∩ coNP) ∖ P, AI[poly, poly] has bounded loss on D^X and ℓ_{FIcons_poly}(D^X_n) → ∞. Every (f, k) eventually mislabels a datum, since otherwise X ∈ P, and the dominated-convergence argument of (c) applies to the mixture. AI[poly, poly] has bounded loss by (c)(ii) with the verifiers of X and its complement.
* If P = NP, then for every AI[poly, poly] hypothesis (p, j) there is an FIcons_poly hypothesis with the same Γ, of length |p| + O(log(the degrees)) + c.
  * f_{V_p}'s acceptance is an NP predicate of φ. A fixed polynomial-time SAT algorithm, which exists if P = NP, composed with the Cook–Levin reduction for V_p, decides it, and likewise rejection.
  * Conversely, (a) embeds FIcons_poly in AI[poly, poly].
  * So each inductor has bounded regret against each hypothesis of the other, with hypothesis-dependent constants.
* The intermediate case (P ≠ NP but NP ∩ coNP = P) is not settled here. The relevant notion is P-separability, by *consistent* poly-time assigners, of the disjoint NP pairs (provable, refutable) of AI hypotheses.

(f) **History-free predictors [proved, conditional on NP ∩ coNP ≠ P].** No predictor whose prediction on φ is a function of φ alone, with rational outputs computable in time polynomial in |φ|, has bounded regret against AI[poly, poly] on every consistent labelled sequence.
* *Proof.* Take D^X with X ∈ (NP ∩ coNP) ∖ P. AI[poly, poly] has bounded loss (e), so the predictor's loss is at most some C.
* Each step with q_{b} ≤ 3/4 costs at least log₂(4/3) bits. So all but at most C/0.415 words get q_{[w∈X]} > 3/4.
* Then "q_1(φ_w) > 1/2" decides X in polynomial time up to a finite table, a contradiction. ∎

**Remark 4.4 (relation to the paper's results on derivation size).**
* **Theorem 4.2(a) is the general form of `thm:time:ntime`.** An axiom set with polynomial membership that proves the data within symbol size d is a certificate system for its assigner. Theorem 4.2(b) shows the bound is attained up to polynomials: what the derivation-size charge prices is the assigner's **nondeterministic** time.
  * This sharpens `rem:time:upper`, whose collapse constructions (A^C_f, two-sorted A_f) pay the deterministic time.
  * It answers model §10 problem 13, and the open problem in the paper's discussion ("whether a symbol-size penalty makes axiom induction equal, up to polynomial factors, to function induction over assigners with short certificates"), **affirmatively, in the hard-cutoff, labelled-data form**: AI[poly, d] ≡ FIcert[poly, Õ(d)] up to constant description length.
* **Not shown.**
  * (i) The same for soft penalties, as in L1^σ or the graded score: weights 2^(−κ·size) per datum. The maps change the per-datum size by an additive O(|φ_i|) and a log factor, so the constants no longer telescope. [open]
  * (ii) The matching upper bound for *finite DT° template theories* (`cor:time:hard`, `prop:time:sigma`). The certificate sets A_V are not finite unions of DT° templates, and whether any equivalent set is relates to model §10 problem 15. [open]
* **The diagonal sequence under charged deduction.** The derivations of s_n from H_0 obtained from the computation have size at least the length of D's computation on n, which is at least n. That is exponential in |s_n| ≈ log₂ n + |e|. So with budgets polynomial in the sentence length, H_0 no longer wins on the diagonal sequence against S. Shorter PA-proofs of these particular sentences are not ruled out here. More generally, AI[t, d] has bounded loss on a sequence only if a single hypothesis proves all of its data within d (the argument of (c)), in line with (c)–(e).

**Remark 4.5 (relation to `conj:time:polytime`).** The conjecture concerns the generative likelihood L2 on positive data, not labelled data, so these results neither prove nor refute it. In the labelled setting they locate it:
* (i) *Constant regret is trivial for a mixture.* The mixture over (p, j) of AI[poly, poly] has loss at most −log₂ w(p, j) against each compatible hypothesis, in the semimeasure convention. The content of Hänni's theorem for S is that his mixture runs in bounded time.
* (ii) *Two obstacles to a time-bounded version for axiom systems.* First, the consistency filter (co-r.e.). Second, deciding derivability within budget d, which is NTIME(poly(d)) and, by (f), not achievable by a history-free poly-time predictor if NP ∩ coNP ≠ P.
* (iii) A predictor that uses the history, like S, has time polynomial in n, where n can be exponential in the sentence length (all words in order). (f) does not reach it. **[open]**: does S_p have bounded regret against AI[poly, d] on language sequences?
* `conj:time:polytime` therefore stays a conjecture. Its comparison class, if transferred to labelled data, would be certificate function induction (Theorem 4.2), not deterministic time-bounded function induction.

---

## 5. Disguised assigners inside AI (H-d)

**Proposition 5.1 (axiom-side penalties do not change the posterior over theories by more than a constant factor) [proved under (S); (b) given `prop:time:twosorted`].**

(a) Let X be AI^chk_t, or AI^gen_t in either form, with the default t. There is a constant c such that, for every class Θ of deductively closed theories and every D with W(D) > 0,

  2^(−c) ≤ π_X(Θ | D) / π_AI(Θ | D) ≤ 2^c,   with π(Θ | D) := W(Θ, D)/W(D),

where W(Θ, D) is the weight of the compatible hypotheses p with Cn(B ∪ A_p) ∈ Θ. So posterior odds between any two classes of theories, "genuine" and "disguised" alike, move by at most 2^(2c).

(b) In the two-sorted setting the same holds for AI^cont_t (theories compared on the L-sort).

*Proof.*
* (a) Every AI hypothesis p semi-decides A_p (q := "yes iff p accepts"). Lemma 2.1 gives d_q (respectively e_q) with Cn(B ∪ Pad(q)) = Cn(B ∪ A_p), length at most |p| + c, cheap in the sense of P1a and P2.
  * Compatibility depends only on the theory, so it is preserved.
  * Hence W_X(Θ, D) ≥ 2^(−c)·W_AI(Θ, D).
  * Conversely, W_X(Θ, D) ≤ W_AI(Θ, D) for AI^chk_t (same hypotheses, same weights). For AI^gen_t, use g ↦ d_{q_g} with q_g := "yes iff g writes the input": by Lemma 2.1 it preserves the theory and adds at most c to the length. So W_X(Θ, D) ≤ 2^c·W_AI(Θ, D).
  * Divide, using W_X(D) = W_X(all, D).
* (b) For a compatible p, put f_p := proof search from B ∪ A_p and G := G_{f_p} (Proposition 2.4(b)). Then Cn(Γ_{f_p}) = Cn(B ∪ A_p) on the L-sort, by `prop:time:twosorted`, and |G| ≤ |p| + c. ∎

So a slow consistent assigner f keeps prior weight 2^(−|f|−c) and posterior share within a constant factor of its unpenalised share, whether it appears as a padded Craig set (its computation in the axioms' length) or as Hänni's schema (its computation in the proofs of Acc_f(⌜φ⌝)). An axiom-side penalty does not make the posterior prefer genuine axiom systems.

**Remark 5.2 (counterpoint: decidable logics) [proof sketch].**
* Let L be monadic (unary predicates, constants, equality, no function symbols), B = ∅, and data literals R(c_w). First-order validity is then decidable [known: Löwenheim 1915; the satisfiability problem is NEXPTIME-complete, Lewis 1980 (not checked)].
* An AI^cont_t hypothesis compatible with every datum of D^X yields a deterministic decision procedure for X: compute G(φ_w) in time t, then decide B ∪ G(φ_w) ⊢ ±φ_w. That takes time at most 2^{2^{O(t)}}, by checking models up to the size bound.
* By the time hierarchy, for X ∉ DTIME(2^{2^{c·t}}), AI^cont_t has unbounded loss on D^X, while FIcons has the constant-size f_X (and so does AI^chk_t, by Theorem 2.2).
* So when deduction cannot carry an arbitrary computation, a *content-relative* axiom-side penalty does separate axiom systems from disguised assigners. Not written out: the exact model-size bound and the encoding of t-time outputs.
* P1 and P2 remain vacuous there (Lemma 2.1 needs only ∧).

**Remark 5.3 (one sort, assigners inconsistent with true arithmetic) [open].** This is Proposition 2.4(d). Both known one-sorted encodings put at least log₂ of a witness into the axiom needed for φ (Craig; Proposition 2.5(c)), so P3 bites on them. Whether every encoding must is open.

**Remark 5.4 (what does discriminate).** The following measures are known to price a disguised assigner:
* derivation size in written symbols: `thm:time:ntime`, `cor:time:hard`, `prop:time:sigma`, and Theorem 4.2 here, where the price is exactly nondeterministic time up to polynomials;
* the grammar code length of plain L1, logarithmically (`cor:time:log`);
* restriction to finite DT° template theories, which blocks Hänni's schema (`prop:time:notemplate`) but not a reflection sentence for Σ_n-sound assigners (`prop:time:collapse`).

Among axiom-side measures, only content-relative ones (P3), and only in logics too weak to carry computations, price it.

---

## 6. Checks

| script | what it checks | result |
|---|---|---|
| `checks/c1_diagonal.py` → `.out` (seed 4242) | Thm 3.2(c) and (a): diagonal against 8 computable predictors (incl. toy clocked FIall with partial hypotheses, a late-start mixture in the style of S, semimeasure deficit, near-1/2 adversary), exact / random / adversarial approximations, N = 2000; from-scratch recomputation of D(n), n ≤ 150; the tail bound Σ log₂(1 + 2^(−j−1)) ≤ 1/(2 ln 2) | all bounds hold; min (ℓ_n − n) = −0.313 (adversarial near-1/2) ≥ −0.7213; D(n) consistent; tail sum 0.6686 |
| `checks/c2_padding.py` → `.out` (seed 777) | Lemma 2.1 and Remark 2.6: padded and unpadded Craig sets for 5 toy assigners (speed from below \|φ\| to 4^{\|w\|} steps; one partial) under a cost model; correctness of decider and enumerator; P1 and P2 ratios | P1 ≤ 1.15·\|χ\|; 'work' padding: completion ≤ 1.14·cumulative length and ≤ 0.016·\|a_i\|²; 'all' padding ≤ 1.14·\|a_i\|; unpadded: completion/\|a_i\| up to 1.1·10⁴ and completion/cumulative up to 10.0 |
| `checks/c3_certificate.py` → `.out` (seed 31337) | Thm 4.2(b): certificate axioms φ ∧ θ_c for a toy NP ∩ coNP language; unique parsing; decider correctness against tampering; length and work bounds; contrast with Craig for a deterministic assigner | all pass; \|χ\|/\|φ\| ≈ 19–21.5; decider work ≤ 2.1·10⁻⁵·\|χ\|³; trial-division Craig axioms up to ≈ 6.6·10¹⁰ symbols at \|φ\| = 63 |

The scripts check constructions and arithmetic. The theorems are logical and asymptotic, and are proved in the text.

---

## 7. Open problems

1. **P3 in one sort for consistent assigners inconsistent with Th(ℕ)** (Prop 2.4(d), Rem 5.3): is there a content-relative-cheap encoding, or must the axiom needed for φ carry the computation?
2. **Soft derivation penalties.** Theorem 4.2 for weights 2^(−κ·size) per datum (L1^σ, graded score), and for finite DT° template theories (Rem 4.4).
3. **The intermediate complexity case** of Cor 4.3(e). When exactly is AI[poly, poly] equivalent to FIcons_poly? The relevant notion is separability of the NP pairs (provable, refutable) by consistent polynomial-time assigners.
4. **History-using time-bounded predictors** (Hänni's S) against AI[poly, d] on language sequences (Rem 4.5(iii)).
5. **A computable consistency filter.** Replace "B ∪ A_p consistent" by "no refutation of a datum within the budget", and ask what survives of Theorems 3.1, 4.2 and of `prop:time:fiall`.
6. **Rates.** On hierarchy sequences (Cor 4.3(d)), only ℓ_{FIcons_τ} → ∞ is shown. A linear rate needs a diagonal against a mixture that is computable within slightly more than τ.

---

## 8. Status of every claim

| claim | status |
|---|---|
| §0.1 answer | summary of the results below |
| (S) | assumption (standard for multitape machines; not checked for a particular U) |
| Lemma 2.1 | proved under (S); computed (`c2`) |
| Thm 2.2 | proved under (S) |
| Prop 2.3 | proved under (S) |
| Prop 2.4 (a) | proved, given the deterministic time hierarchy theorem (known) |
| Prop 2.4 (b) | proved, given `prop:time:twosorted` |
| Prop 2.4 (c) | proved |
| Prop 2.4 (d) | open |
| Prop 2.5 | proved, given the known Q facts (Σ₁- and Δ₀-completeness, the bounded-quantifier lemma) |
| Rem 2.6 (paper's generation sentence, enumeration reading) | refuted for unpadded A^C_f (proved; illustrated by `c2`); corrected by Lemma 2.1 |
| Thm 3.1 | proved (under (S) for the penalised AI variants) |
| Thm 3.2 | proved, given the recursion theorem, Σ₁/Δ₀-completeness of Q and PA ⊢ DET (known); computed (`c1`) |
| Cor 3.3 (a), (b), (c) | proved |
| Prop 3.4 | proved, given Hänni's theorem for S (his proof, which he has not fully checked) |
| Rem 3.5 | proved (the Rosser variant: known Q fact, not checked) |
| Prop 4.1 (a), (b) | proved |
| Prop 4.1 (c) | proof sketch (rests on Hänni's theorem) |
| Thm 4.2 | proved, given the propositional derivation-schema fact (known); (b) computed (`c3`) |
| Cor 4.3 (a) | proved under (S) |
| Cor 4.3 (b), (c) | proved |
| Cor 4.3 (d) | proved, given the deterministic time hierarchy theorem (known) |
| Cor 4.3 (e) | proved, conditional on NP ∩ coNP ≠ P (separation) or on P = NP (equivalence); intermediate case open |
| Cor 4.3 (f) | proved, conditional on NP ∩ coNP ≠ P |
| Rem 4.4 (soft penalties; DT° upper bound) | open |
| Rem 4.4 (diagonal under charged deduction) | proved for the construction; shorter proofs not ruled out |
| Rem 4.5 | (i) proved; (ii) by Cor 4.3(f); (iii) open; `conj:time:polytime` remains a conjecture |
| Prop 5.1 (a) | proved under (S) |
| Prop 5.1 (b) | proved, given `prop:time:twosorted` |
| Rem 5.2 | proof sketch |
| Rem 5.3 | open |

---

## References

* W. Craig, "On axiomatizability within a system", *J. Symbolic Logic* 18 (1953) 30–32 [known].
* S. C. Kleene, second recursion theorem; H. Rogers, *Theory of Recursive Functions and Effective Computability*, 1967, §11.2 [known (section not checked)].
* J. Hartmanis, R. Stearns, "On the computational complexity of algorithms", *Trans. AMS* 117 (1965); F. Hennie, R. Stearns, "Two-tape simulation of multitape Turing machines", *JACM* 13 (1966) [known (exact form of the hierarchy theorem not checked)].
* S. Cook (1972); J. Seiferas, M. Fischer, A. Meyer (1978); S. Žák (1983): the nondeterministic time hierarchy, as cited in the paper [known (not checked)].
* P. Smith, *An Introduction to Gödel's Theorems*, 2nd ed., 2013: Robinson's Q, its Σ₁- and Δ₀-completeness and the properties of ≤ [known (numbering not checked)].
* P. Hájek, P. Pudlák, *Metamathematics of First-Order Arithmetic*, 1993: formalised computations, determinism in PA [known (not checked)].
* S. Legg, "Is there an elegant universal theory of prediction?", ALT 2006: every computable predictor fails on some computable sequence [known (not checked)]; Theorem 3.2 is a log-loss, labelled-sentence version with approximate outputs.
* H. Lewis, "Complexity results for classes of quantificational formulas", *JCSS* 21 (1980): monadic satisfiability [known (not checked)].
* M. Li, P. Vitányi, *An Introduction to Kolmogorov Complexity and Its Applications*, 3rd ed., 2008: prefix machines, Kt [known].
* K. Hänni, `../../prior/hanni-solomonoff-axiom-induction.md`, `../../prior/hanni-polytime-solomonoff.md` (working notes).
