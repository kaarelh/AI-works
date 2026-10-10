# Track "time-followup": the time penalty, after Hänni's objection — final record

*Follow-up to paper Section 6 (`../../../paper/sections/time.tex`, `app-time.tex`) and to the model track's §6 and §9.3 (`../model/notes-final.md`). This file is the complete, self-contained final record of the track. It was written after two referee reports: `referee-logic.md` (logic and computability; its code is in `referee_logic/`) and `referee-penalty.md` (the penalty definitions; its code is in `referee_penalty/`). It supersedes `notes.md`, which is kept unchanged as the pre-referee version. Numbering follows `notes.md`. Items added in the revision have new numbers (Lemmas 1.4 and 1.6, Convention 1.5, Prop 2.7, Rems 2.2a, 2.3a, 4.6, 5.5, 5.6). Scripts are in `checks/`. Each is deterministic or seeded and writes `<name>.out` next to itself.*

*The question.* Kaarel Hänni replied to the sentence "The time penalty doesn't block your collapse argument. The collapse into function induction (with Craig's trick) survives a penalty on checking or generating axioms." His objection, verbatim: "if we penalize time on the function induction side and in the axiom generator but crucially NOT in the proof search from axioms, then intuitively i disagree with this: i think the time penalty should help? like the function induction guy that runs the proof search from axioms will be extremely slow; there's nothing comparably slow on the axiom induction side". The answer, with exact scopes, is the last section (§11).

**Status tags.**
* **[proved]**: full proof here. "Proved under (S)" means: given the machine assumption (S) of §1.2.
* **[proved, conditional on H]**: full proof from the stated complexity hypothesis H.
* **[proof sketch]**: the argument is given; the steps not written out are named.
* **[known]**: published, with reference. **(not checked)** means recalled, not checked against the source in this session.
* **[computed]**: checked by a script; the output file is named.
* **[conjecture]**, **[open]**.
* **[refuted]**: a claim shown false, kept with its counterexample.

**Labels.** Paper labels are cited as in the paper: `def:time:inducers`, `thm:time:equiv`, `prop:time:fiall`, `prop:time:twosorted`, `prop:time:single`, `prop:time:notemplate`, `prop:time:collapse`, `prop:time:cheap`, `rem:time:summary`, `thm:time:ntime`, `cor:time:hard`, `prop:time:sigma`, `cor:time:log`, `rem:time:upper`, `conj:time:polytime`. "Model §k" is `../model/notes-final.md`. "Hänni's S" is the predictor of `../../prior/hanni-polytime-solomonoff.md`. "RL" is the logic referee (`referee-logic.md`), "RP" the penalty referee (`referee-penalty.md`). RL's scripts are `referee_logic/r1–r3`, RP's are `referee_penalty/r1–r3`.

**What changed after the referees.** Neither referee found a fatal issue. RL found 2 major and 18 minor issues; RP found 5 major and 20 minor issues. Every one is resolved; the map is the verification log (§10). The main changes:
* **The summary was too broad (RL-M1, RP-M5).** "Axiom induction becomes strictly stronger than every time-bounded function inductor" is **refuted**: Hänni's S and the clocked FIall_τ are time-bounded and incomparable with AI (Prop 3.4). It holds against time-penalised *consistent* function induction. Each scope in the summary now matches a theorem.
* **The two-sorted content-relative penalty (RL-M2).** Prop 2.4(b) is **refuted** for "B ⊇ Q on the arithmetic sort" (counterexample with B ⊇ PA + ¬Con(PA)). It is restated, and proved, for backgrounds B_A ∪ B_L with B_A true in ℕ and no mixed-sort axioms.
* **The generation penalty (RP-M1, RP-M2, RL-m1).** The strict form of P2 is a sparsity condition: it admits only polynomially sparse axiom sets and excludes every schema (new Prop 2.7). Polynomial delay is added as the default form. The claims about enumerating A^C_f are restated for the generic enumerator; for the set itself they are open.
* **The "NP ∩ coNP barrier" (RP-M3).** The notes' Cor 4.3(f) holds unconditionally. RP proved this with the time hierarchy theorem. This revision finds a simpler reason: no history-free predictor, of any complexity, can have bounded loss on both the all-0 and the all-1 label sequence (Rem 4.6). So the statement says nothing about NP ∩ coNP, and the barrier claim is withdrawn.
* **Polynomial budgets (RP-M4).** The mixture AI[poly, poly] now charges the degree of membership time, as FIcons_poly charges its clock degree. The NP ∩ coNP / P = NP dichotomy is stated per sequence (Cor 4.3(e)). Without the degree charge, FIcons_poly fails to dominate AI[poly, poly] unconditionally (Cor 4.3(e4), RP's argument with explicit constants).
* **The Kt penalty (RP-m1, m2, m3; RL-m12).** W_{AI^Kt}(∅) ≤ 1 is **refuted**; the bound is t(m_0). The Kt charge is log₂(|f| + 1) + O(1): AI^Kt_t is equivalent, up to a constant, to consistent function induction with weights 2^(−|f|)/(|f| + 1) (Prop 2.3, now proved).
* **The diagonal (RL's observation, RL-m16, RP-m12).** The loss bound is sharpened to n − 1/(4 ln 2), and it is attained (c4). Arithmetic now goes through a Diophantine (MRDP) output formula. Only Q's evaluation of closed terms is then needed, and it is proved here (Lemma 1.4).

---

## 0. Results at a glance

| hypothesis (orchestrator's) | verdict | where |
|---|---|---|
| **H-a** FI → AI survives an axiom-side penalty | **confirmed for P1a and P2, with corrections.** Membership class (P1a) and generation time (P2, strict, delay and cumulative forms): within a constant of unpenalised FIcons, via a padded Craig set. P2-strict is a density condition (Prop 2.7). Kt on membership (P1b): equivalent to FIcons with weights 2^(−\|f\|)/(\|f\|+1). Content-relative (P3): vacuous in two sorts with a true arithmetic background, and in one sort for assigners consistent with Th(ℕ). It bites on Craig-type sets, in decidable logics and on the genuine axioms of PA. Open in one sort otherwise | Lemma 2.1, Thm 2.2, Props 2.3, 2.4, 2.7, Rem 2.6 |
| **H-b (i)** AI ≥ FIcons_τ | **confirmed** for AI, AI^chk_t, AI^gen_t and two-sorted AI^cont_t (true B_A), against every FI-side penalty that only shrinks the weights of consistent deterministic assigners. AI^Kt_t only against classes with weights O(2^(−\|f\|)/\|f\|). **Not** against S or FIall_τ: incomparable | Thm 3.1, Prop 3.4, Rem 5.2 |
| **H-b (ii)** diagonal separation | **confirmed.** Every computable predictor loses ≥ n − 1/(4 ln 2) bits on a computable sequence of sentences s_n, each decided by Q ∪ {DET}; AI loses a constant independent of the predictor | Thm 3.2, Cor 3.3 |
| **H-c** the separation comes from free deduction | **confirmed.** Unpenalised FIcons wins on the same sequences through a constant-size evaluator. With deduction charged, AI[t, d] ≡ FIcert (certificate function induction). Against FIcons_τ: domination once d ≥ γ(τ + 1)(m + 4); unconditional separation for larger d. At polynomial budgets, per sequence: separation if NP ∩ coNP ≠ P, none if P = NP. `conj:time:polytime` stays a conjecture. There is no NP ∩ coNP barrier for history-free predictors (Rem 4.6) | Prop 4.1, Thm 4.2, Cor 4.3, Rems 4.4–4.6 |
| **H-d** axiom-side penalties do not favour genuine systems | **confirmed** for P1a, P2 and two-sorted P3 (true B_A): posterior odds between any two classes of theories move by at most a constant factor. At the level of representations, P2-strict excludes every genuine schema, and P3 can exclude the natural axiomatisation of PA while it admits Hänni's disguised schema | Prop 5.1, Rems 5.2–5.6 |
| **H-e** the answer | §11 | |

---

## 1. Setting and definitions

### 1.1 Data, inductors, losses

As in `def:time:inducers`. L is a countable first-order language, B a decidable background, and data D = ((φ_1, b_1), …, (φ_n, b_n)) with b_i ∈ {1 (true), 0 (false)}. Write φ^1 := φ and φ^0 := ¬φ.

* **AI.** A hypothesis is a decider p of a set A_p ⊆ Sent_L. It is compatible with D if B ∪ A_p is consistent and B ∪ A_p ⊢ φ_i^{b_i} for every i. W_AI(D) := Σ_{p compatible} 2^(−|p|).
* **FIcons.** A hypothesis is a program f computing a partial map Sent_L → {acc, rej}, with B ∪ Γ_f consistent, where Γ_f := {φ : f(φ) = acc} ∪ {¬φ : f(φ) = rej}. It is compatible with D if it labels every φ_i with b_i. W_FI(D) := Σ_{f compatible} 2^(−|f|). **FIall** drops the consistency requirement.
* **Loss, semimeasure convention.** ℓ_X(D) := −log₂ W_X(D) + log₂ W_X(∅). It is the sum of the per-step losses −log₂(W_X(D_j)/W_X(D_{j−1})), and it depends on D only as a set.
* **Predictors.** A predictor P maps a history D_{j−1} and the next sentence φ_j to (q_0, q_1) with q_b ≥ 0 and q_0 + q_1 ≤ 1. Its loss is ℓ_P(D_n) := Σ_j −log₂ q_{b_j}(D_{j−1}, φ_j). For a mixture in the semimeasure convention the two definitions agree, by telescoping.
  * P is a **computable predictor** if a total computable function maps (D, φ, k) to rationals a_0, a_1 with |a_b − q_b(D, φ)| ≤ 2^(−k). Exact rational outputs are a special case.
  * P is **history-free** if q_b(D, φ) depends on φ alone.
* **Regret and domination.** The regret of X against Y on D is ℓ_X(D) − ℓ_Y(D). X *dominates* Y if sup_D (ℓ_X(D) − ℓ_Y(D)) < ∞, over all finite D in any order.

### 1.2 Machines and weights; assumption (S)

**Programs.** U is a universal prefix machine. Its programs are the words of a prefix-free, self-delimiting code. U reads a program p to its end before it reads its input, so time_p(x) ≥ |p|, where time_p(x) is the number of steps U takes on (p, x) before it halts. For a fixed wrapper W and a program q, W⌢q is again a program, and W can find the end of q. All hypotheses of AI, FIcons and their variants are programs in this sense, so their weights 2^(−|p|) satisfy Kraft's inequality. (This makes explicit what `def:time:inducers` assumes; RP-m17.)

**Assumption (S) (efficient self-simulation)** [standard for multitape machines; assumed, not checked for a particular U]. There are constants α, a ≥ 1, depending only on U, with the following properties, for every program q and the fixed wrappers W used below.
* W can read q to its end, copy it to a work tape and compute |q| within α(|q| + 1) steps.
* Parsing a sentence, and comparing or copying strings of total length L, takes at most α(L + 1)² steps.
* W⌢q can run the *dovetailing schedule* on q. At stage s it starts q on the s-th sentence, and it advances every unfinished run by one simulated step. Along the way it maintains a *work counter* T: the number of simulated steps, plus the lengths of the sentences started, plus |q|. Up to work T it spends at most α(T + 1)^a steps of U, not counting the steps spent writing output. Writing a string of length L costs at most αL steps.

The counter starts at |q| and increases with every simulated step, so different detections happen at different counter values.

**(S_lin)** is (S) with a = 1 and with linear-time parsing, comparing and copying. It is used only in the proof sketch of Remark 2.2a.

**Clocked classes.** U_0 is a fixed plain universal machine. For a time-constructible τ and a string f, the τ-clocked version is f^τ(φ) := U_0(f, φ) if U_0 halts within τ(|φ|) steps with acc or rej, and "abstain" otherwise. Clocked classes weight f by w(f) := 2^(−|E(f)|), where E(f) := δ(|f| + 1)⌢f and δ is the Elias delta code. E is a complete prefix code on strings: Σ_f w(f) = 1, and |E(f)| = |f| + log₂|f| + O(log log |f|). These weights have computable tails.

### 1.3 Axiom-side penalties

**Definition 1.1 (axiom-side penalties).** Let t be time-constructible, nondecreasing and superadditive (t(x) + t(y) ≤ t(x + y)), with t(m) ≥ m; for example t(m) = m^k with k ≥ 1. The default is t(m) := m^{a*} with a* := max(a, 3), a from (S). Compatibility is as for AI unless stated.
* **P1a (membership time, class version).** AI^chk_t: hypotheses are deciders p with time_p(χ) = O(t(|χ|)). The asymptotic constant may depend on p. Weight 2^(−|p|).
* **P1b (membership time, Kt version).** AI^Kt_t: weight 2^(−|p|)/c_p, where c_p := sup_χ time_p(χ)/t(|χ|) (weight 0 if c_p = ∞). This is Levin's Kt applied to the decider, as in model §1.3 and `rem:model:priors`(iii). The weights are not normalised; Prop 2.3(i) bounds their sum.
* **P2 (generation time).** AI^gen_t: hypotheses are *enumerators* g, programs without input that write a sequence a_1, a_2, …; A_g := {a_i}. Let e_i be the step at which a_i is completely written, and e_0 := 0. Weight 2^(−|g|) if g meets the chosen form:
  * *strict form*: e_i = O(t(|a_i|));
  * *delay form* (the default; polynomial delay, Johnson, Yannakakis and Papadimitriou 1988): e_i − e_{i−1} = O(t(|a_i|));
  * *cumulative form* (close to incremental polynomial time, ibid.): e_i = O(t(|a_1| + … + |a_i|)).

  Strict implies delay, since e_i − e_{i−1} ≤ e_i. Delay implies cumulative, since e_i = Σ_{j≤i}(e_j − e_{j−1}) ≤ C·Σ_{j≤i} t(|a_j|) ≤ C·t(|a_1| + … + |a_i|) by superadditivity.
* **P3 (content-relative generation time).** AI^cont_t: a hypothesis is a program G that maps each sentence φ to a finite set G(φ) of sentences in time O(t(|φ|)); A_G := ∪_φ G(φ). G is compatible with D if B ∪ A_G is consistent and B ∪ G(φ_i) ⊢ φ_i^{b_i} for each i: the axioms needed for a datum are produced from the datum quickly. Weight 2^(−|G|).

P1 and P2 measure time against the length of the *axiom*. P3 measures it against the length of the *content*, the datum. All of them leave deduction free.

### 1.4 FI-side penalties

**Definition 1.2 (FI-side penalties).**
* **FIcons_τ** (clocked): hypotheses are strings f with B ∪ Γ_{f^τ} consistent, with weight w(f). f is compatible if f^τ labels every datum correctly. **FIall_τ** is the same without consistency. Both use clocks in the *sentence length*, so their hypotheses are assigners of bounded time, as in a complexity class.
* **Kt-weighted FIcons**: weights 2^(−|f|)/max(1, c_f), with c_f := sup time_f(φ)/τ(|φ|) over the φ on which f halts.
* **Time-weighted FIcons**: weights v(f, D) := 2^(−|f|)/(1 + Σ_i time_f(φ_i)), which depend on the data. It is in the spirit of Schmidhuber's speed prior (COLT 2002) but is not that prior (RP-m13). The "1 +" makes the weight defined at D = ∅ (RL-m11).
* **Hänni's S, read on labelled sentences.** Hänni defines S for bit sequences: a Bayes mixture of all predictors with time p(n) per step, in which each component is counted as predicting 1/2 before its late start and whenever it exceeds its budget. On labelled sentences, the components receive the labelled history and the next sentence and output a probability for the label 1. Every statement below about S uses only two properties of this reading:
  * (i) S is a computable predictor;
  * (ii) one component is the constant predictor "label 1 with probability 1". It runs within every budget, has prior weight π_1 > 0, and is tracked from a finite step ℓ_1 on.

  Any adaptation with (i) and (ii) will do. Hänni's regret theorem is not used anywhere (RP-m14).

### 1.5 Deduction charged

**Definition 1.3 (deduction charged).** Let L be finite (RP-m7), B decidable in polynomial time, and d, t, t' time-constructible and nondecreasing. K is Mendelson's calculus (`model.tex` line 35), with primitive connectives ¬ and →. Sentences are written in Polish notation over these primitives, and sizes count symbols.
* **AI[t, d]**: hypotheses are deciders p with time_p(χ) = O(t(|χ|)). p is compatible with D if B ∪ A_p is consistent and each φ_i^{b_i} has a K-derivation from B ∪ A_p of symbol size at most d(|φ_i|). Weight 2^(−|p|).
* **FIcert[t', d']** (consistent assigners with certificates): a hypothesis is a program V with time_V(φ, c) = O(t'(|φ| + |c|)) on all inputs, with outputs in {acc, rej, ⊥}.
  * Put f_V(φ) := acc if some c with |c| ≤ d'(|φ|) has V(φ, c) = acc; rej if some such c has V(φ, c) = rej; and undefined otherwise.
  * Require B ∪ Γ_{f_V} consistent; this also rules out both labels for one φ.
  * V is compatible if f_V labels every datum correctly. Weight 2^(−|V|).

### 1.6 Arithmetic facts used

L_A := {0, S, +, ·}. Robinson's Q has the axioms Q1 Sx ≠ 0; Q2 Sx = Sy → x = y; Q3 x = 0 ∨ ∃y x = Sy; Q4 x + 0 = x; Q5 x + Sy = S(x + y); Q6 x·0 = 0; Q7 x·Sy = x·y + x. S^k0 is the unary numeral. bin(k) is a binary numeral term, a closed term of value k and size O(log k), e.g. bin(0) := 0, bin(1) := S0, and for k ≥ 1, bin(2k) := SS0·bin(k) and bin(2k+1) := SS0·bin(k) + S0. "y ≤ s" abbreviates ∃z (z + y = s), the convention of the paper and of Smith.

**Lemma 1.4.**
(a) **[known: the MRDP theorem; Matiyasevich 1970; Davis 1973 (not checked)]** Every r.e. relation R ⊆ ℕ^k is Diophantine: there are polynomials P, P' with natural-number coefficients such that R(x̄) holds iff ∃ȳ P(x̄, ȳ) = P'(x̄, ȳ). In particular there are such polynomials E, E' with: program e on input x halts with output y iff ℕ ⊨ ∃c̄ E(e, x, y, c̄) = E'(e, x, y, c̄).
(b) **[proved]** For every closed L_A-term t with value k, Q ⊢ t = S^k0.
(c) **[proved]** For a ≠ b, Q ⊢ S^a0 ≠ S^b0. Hence Q proves every true closed equation and refutes every false one, and Q proves every true sentence of the form ∃ȳ (s(ȳ) = s'(ȳ)).
(d) **[proved]** For every k, Q ⊢ ∀y (∃z (z + y = S^k0) → y = 0 ∨ y = S0 ∨ … ∨ y = S^k0).

*Proof.*
* (b) Induction on t. For 0 there is nothing to prove; St' follows from t' by the equality axioms. For t₁ + t₂ with values a, b: Q ⊢ S^a0 + S^b0 = S^{a+b}0 by b uses of Q5 and one of Q4. For t₁·t₂: Q ⊢ S^a0·S^b0 = S^{ab}0 by induction on b with Q6, Q7 and the + case.
* (c) Let a < b. From S^a0 = S^b0, a uses of Q2 give 0 = S^{b−a}0, against Q1. For a closed equation s = s', (b) gives Q ⊢ s = S^u0 and s' = S^v0, so Q proves it if u = v and refutes it otherwise. For ∃ȳ(s = s') true, instantiate ȳ by the numerals of a witness.
* (d) Induction on k. For k = 0: if y = Sy' (Q3), then z + Sy' = S(z + y') ≠ 0 by Q5 and Q1, so y = 0. From k to k + 1: if y ≠ 0, then y = Sy' (Q3), z + Sy' = S(z + y') = S(S^k0) by Q5, so z + y' = S^k0 by Q2. By the induction hypothesis y' is one of 0, …, S^k0, so y is one of S0, …, S^{k+1}0. ∎

(d) is the bounded lemma; RL checked it, and the orientation of ≤, in 576 nonstandard Q-structures (`r2_q_models.out`, rows L1, D1, D2).

**The output formula.** Out(e, x, y) := ∃c̄ (E(e, x, y, c̄) = E'(e, x, y, c̄)). It is Σ₁, written without < and without bounded quantifiers. Theorem 3.2 and Proposition 2.5 use Out. For them, only Lemma 1.4(b)–(d) is needed about Q (RL-m16, RP-m12). Proposition 2.4 uses the paper's formulas Acc_f, Rej_f (Kleene's T predicate, written without <) together with the Σ₁-completeness of Q that the paper cites. Wherever a PA-provable property of computations is used (Prop 2.4(b4), (d)), that is the standard formalisation, as in `prop:time:single`.

### 1.7 Language sequences

**Convention 1.5.**
* *The language.* L ⊇ {0, S, +, ·, R}, R unary, B = ∅. For a word w ∈ {0,1}*, ν(w) := bin(the number with binary expansion 1w) and φ_w := R(ν(w)). Distinct words give distinct values.
* *Lengths.* λ(m) := max_{|w| = m} |φ_w|. There are constants β, β' with m ≤ λ(m) ≤ βm + β'.
* *The sequences.* For X ⊆ {0,1}*, D^X is the infinite labelled sequence of the data (φ_w, [w ∈ X]) over all words w in length-lexicographic order, and D^X_n is its first n data. f_X is the assigner with these labels. Γ_{f_X} is consistent: interpret R as the set of values of ν(w) with w ∈ X.
* *Overhead.* q is a fixed nondecreasing polynomial with nonnegative coefficients and three properties [standard polynomial-overhead simulations; assumed, as (S)].
  * If a string f labels every φ_w correctly within T(|φ_w|) steps of U_0 (or a U-program within T steps of U), then a multitape machine decides X in time q(C_f·T(λ(m)) + m), with C_f depending on f.
  * If a multitape machine decides X within T(|w|) steps for every w, then some string labels each φ_w correctly within q(T(|w|) + |φ_w|) steps of U_0.
  * U_0 runs a U-program p for T steps within q(C_p·T) steps, with C_p depending on p.

  Since q has nonnegative coefficients, q(C·x) ≤ C^{deg q}·q(x) for C ≥ 1. So m·q(x) ≥ q(C·x) once m ≥ C^{deg q}: a growing factor m absorbs every constant from some length on.
* *Classes.* DTIME, NTIME refer to multitape machines, with the input length m = |w|.

**Lemma 1.6 (bounded loss on an infinite sequence) [proved].** Let X be a mixture W_X(D) = Σ_h v(h)·[h compatible with D] over countably many hypotheses, with Σ_h v(h) < ∞, in which compatibility is inherited by prefixes. Let D_∞ be an infinite labelled sequence with prefixes D_n. Then sup_n ℓ_X(D_n) < ∞ iff some h with v(h) > 0 is compatible with every D_n.

*Proof.* If h is, then W_X(D_n) ≥ v(h), so ℓ_X(D_n) ≤ log₂(W_X(∅)/v(h)). If none is, each indicator [h compatible with D_n] is eventually 0, so W_X(D_n) → 0 by dominated convergence, and ℓ_X(D_n) → ∞. ∎

All the inductors of this file are such mixtures: AI and its variants, FIcons_τ, FIcons_poly, AI[t, d], AI[poly, poly].

---

## 2. FI → AI under axiom-side penalties (H-a)

**Lemma 2.1 (padded sets) [proved under (S)].** Let q be a program, and S_q the set of sentences on which q halts with output "yes". The padded enumerator e_q := W_enum⌢q runs the dovetailing schedule on q. When it first detects that q says yes on χ, at work counter T, it writes χ^(T+1), the (T+1)-fold right-nested conjunction. Let Pad(q) be the set of written sentences. Then:

(a) Cn(B ∪ Pad(q)) = Cn(B ∪ S_q).

(b) The decider d_q := W_dec⌢q decides Pad(q), with time_{d_q}(χ) ≤ α(|q| + 1) + α'(|χ| + 1)^{a'} for every χ, where a' := max(a, 2) and α' := 3α.

(c) e_q writes each member of Pad(q) exactly once. If a_i is written at counter T_i, then |a_i| ≥ T_i + 1, and
  * e_i ≤ 5α·|a_i|^{a''} with a'' := max(a, 3) (strict form);
  * e_i − e_{i−1} ≤ 2α·|a_i|^a (delay form);
  * e_i ≤ 2α·(|a_1| + … + |a_i|)^a (cumulative form).

(d) |d_q|, |e_q| ≤ |q| + c, and the maps q ↦ d_q and q ↦ e_q are injective.

So Pad(q) meets P1a and all three forms of P2 for the default t (a* = max(a, 3) ≥ a', a'').

*Proof.*
* (a) χ^m is logically equivalent to χ. Each χ ∈ S_q is detected exactly once, so it has exactly one padded copy, and every member of Pad(q) is a padded copy of a member of S_q.
* (b) The decider does three things.
  * It reads q, copies it and computes |q|: at most α(|q| + 1) steps.
  * It parses χ. If χ = ψ^m with m ≥ 2, then ψ is the left immediate subformula of χ, and m is then fixed by |χ|. The only other candidate is m = 1, ψ = χ. So there are at most two candidates, found and compared within α(|χ| + 1)² steps.
  * For each candidate (ψ, m), if m − 1 < |q| it rejects the candidate: the counter starts at |q|, so every member has m ≥ |q| + 1. Otherwise it runs the schedule, without writing, until the counter exceeds m − 1, and accepts iff q is detected saying yes on ψ exactly at counter m − 1. Since m ≤ |χ|, this costs at most α(|χ| + 1)^a steps by (S).

  The run is bounded by the counter, so the decider halts on every input, also when q is partial. The three costs add up to the bound.
* (c) Writing happens once per detection, and detections are of distinct sentences. Let T_i be the counter at the emission of a_i = χ_i^(T_i+1).
  * *Length.* |a_i| ≥ T_i + 1, since |ψ^m| ≥ m.
  * *Strict.* Before a_i is complete, the schedule has cost at most α(T_i + 1)^a, and writing a_1, …, a_i has cost at most α(|a_1| + … + |a_i|). At most T_i + 1 axioms were written up to a_i, at distinct counter values T_j ≤ T_i. Each is χ_j^(T_j+1) with |χ_j| ≤ T_j, since the length of χ_j is part of the counter. In Polish primitive syntax |ψ^m| = m|ψ| + 3(m − 1), so |a_j| ≤ (T_i + 1)(T_i + 3) and Σ_{j≤i}|a_j| ≤ (T_i + 1)²(T_i + 3) ≤ 4(T_i + 1)³ ≤ 4|a_i|³. Hence e_i ≤ α|a_i|^a + 4α|a_i|³ ≤ 5α|a_i|^{a''}.
  * *Delay.* Between the completions of a_{i−1} and a_i, the schedule costs at most α(T_i + 1)^a and writing a_i costs at most α|a_i|. So e_i − e_{i−1} ≤ α|a_i|^a + α|a_i| ≤ 2α|a_i|^a.
  * *Cumulative.* e_i ≤ α(T_i + 1)^a + α(|a_1| + … + |a_i|) ≤ 2α(|a_1| + … + |a_i|)^a, as T_i + 1 ≤ |a_i|.
* (d) d_q and e_q are fixed wrappers followed by q. ∎

**[computed: `checks/c2_padding.out`; `referee_penalty/r2_enumeration.out`, Part B]** c2 uses five toy assigners, whose own running time ranges from below |φ| to 4^{|w|} steps.
* *Membership.* Decider work stays below 1.15·|χ|. The `dec/|chi|` column of c2 is computed from the cost model, as (|χ| + m)/|χ|. The decider itself is run only in the 30-query from-scratch check (column `rerun`), which agrees with the event log (RP-m18).
* *Completion, work padding.* Below 1.14·(cumulative length), and below 0.016·|a_i|².
* *Completion, elapsed-time padding.* Below 1.14·|a_i|, at the price of geometrically growing axiom lengths.
* *Delay (RP's r2 Part B).* delay/|a_i| ≤ 1.14 with padding for four assigners; up to 1437 without padding.
* *Unpadded Craig set A^C_f.* Membership work is also below 2|χ|. But completion over |a_i| reaches 1.1·10⁴, and completion over cumulative length reaches 10.0 for the slowest assigner. The dovetailing delay is what the padding absorbs.

**Theorem 2.2 (axiom-side penalties P1a and P2 are vacuous up to a constant) [proved under (S)].** Let t be time-constructible with t(m) ≥ m^{a*} for all m ≥ 1, for example the default. There is a constant c, depending only on U, the coding and B, such that for every finite D:

(a) 2^(−c)·W_FI(D) ≤ W_{AI^chk_t}(D) ≤ W_AI(D) ≤ 2^c·W_FI(D);

(b) 2^(−c)·W_FI(D) ≤ W_{AI^gen_t}(D) ≤ 2^c·W_FI(D), for the strict, the delay and the cumulative form alike.

Hence the semimeasure losses of AI, AI^chk_t and AI^gen_t each differ from the loss of *unpenalised* FIcons by at most 2c, on every D in every order. `thm:time:equiv` survives these penalties.

*Proof.*
* *Lower bounds.* For an FIcons hypothesis f, let q_f answer yes on φ if f(φ) = acc, and on ¬φ if f(φ) = rej. Then S_{q_f} = Γ_f and |q_f| ≤ |f| + c.
  * By Lemma 2.1(a), Cn(B ∪ Pad(q_f)) = Cn(B ∪ Γ_f). This is consistent, and it decides each datum as f does. So d_{q_f} (respectively e_{q_f}) is compatible whenever f is.
  * By Lemma 2.1(b), (c), d_{q_f} meets P1a and e_{q_f} meets each form of P2, for the default t and so for every larger t.
  * The maps are injective and add at most a constant to the length.
* *Upper bounds.* AI^chk_t has a subset of AI's hypotheses with the same weights. For (b), map an enumerator g to f_g := "search for proofs of φ and of ¬φ from B ∪ A_g" (A_g is r.e.). Then |f_g| ≤ |g| + c. If g is compatible, B ∪ A_g is consistent and proves each φ_i^{b_i}, so f_g labels each datum correctly and Γ_{f_g} ⊆ Cn(B ∪ A_g) is consistent with B.
* *Losses.* Each of the two terms of ℓ changes by at most c. ∎

**Remark 2.2a (slower reference bounds) [proof sketch].** The exponent a* is a property of U's self-simulation, not of the penalty (RP-m4). Under (S_lin), the vacuity holds for every time-constructible t with t(m) ≥ m.
* Pad by the counter, with χ^(M) and M := max(T + 1, 2·(total length written so far)).
* The decider parses in linear time and replays the schedule up to counter M − 1, including the lengths of earlier emissions, at cost O(M) ⊆ O(|χ|).
* Completion is then e_i ≤ α|a_i| + α(|a_i|/2 + |a_i|) ≤ 3α|a_i|, which meets the strict form, hence all three.
* *Not written out:* (S_lin) for a concrete U, and the linear-time replay.

**Proposition 2.3 (the Kt version: a log charge, the same order as every program's) [proved under (S)].** Let t be time-constructible with t(m) ≥ m^{a*}, and let m_0 be the least length of a sentence. Put W_{FI^1}(D) := Σ_{f FIcons, compatible with D} 2^(−|f|)/(|f| + 1).

(i) For every decider p, c_p ≥ |p|/t(m_0). So the AI^Kt_t weight of p is at most t(m_0)·2^(−|p|)/|p|, and W_{AI^Kt_t}(∅) ≤ t(m_0).

(ii) There is a constant c such that for every finite D,
  2^(−c)·W_{FI^1}(D) ≤ W_{AI^Kt_t}(D) ≤ 2^c·t(m_0)·W_{FI^1}(D).

(iii) Hence |ℓ_{AI^Kt_t}(D) − ℓ_{FI^1}(D)| ≤ 2c + 2·log₂ t(m_0) for every D. Under P1b an assigner f pays log₂(|f| + 1) + O(1) bits beyond its unpenalised weight. By (i), every hypothesis of length L pays at least log₂ L − log₂ t(m_0).

*Proof.*
* (i) time_p(χ) ≥ |p| for every χ; take χ of length m_0. Sum the weights, using Kraft and |p| ≥ 1.
* (ii), lower bound. For an FIcons hypothesis f, let d := d_{q_f} as in Theorem 2.2. By Lemma 2.1(b), and since (|χ| + 1)^{a'} ≤ 2^{a'}|χ|^{a*} ≤ 2^{a'}t(|χ|) and t(m_0) ≥ 1,
  c_d ≤ α(|q_f| + 1) + α'·2^{a'} ≤ β·(|f| + 1),
  with β depending only on U and the coding. So d has weight at least 2^(−|f|−2c)/(β(|f| + 1)). It is compatible when f is, and f ↦ d is injective.
* (ii), upper bound. For a compatible p, the proof-search assigner f_p has |p| ≤ |f_p| ≤ |p| + c (`thm:time:equiv`), and it is compatible. By (i), p has weight at most t(m_0)·2^(−|p|)/|p| ≤ t(m_0)·(c + 2)·2^c·2^(−|f_p|)/(|f_p| + 1). The map p ↦ f_p is injective.
* (iii) Apply (ii) to D and to ∅. ∎

**[computed: `referee_penalty/r1_kt_prior.out`, Parts A and C]**
* Part A: a family of empty-set deciders has total weight 3.45 > 1, refuting `notes.md`'s use of W_{AI^Kt}(∅) ≤ 1.
* Part C: the padded decider's Kt charge sits 0 to 0.8 bits above the floor log₂(|q|/t(m_0)) under the accounting of Lemma 2.1(b). It sits 5.8 to 29 bits above it under `notes.md`'s cruder bound a'·log₂(|f| + 2).

`notes.md` stated (ii) only as an upper bound on the loss, with a'·log₂(|f| + 2) in place of log₂(|f| + 1), and assumed W_{AI^Kt}(∅) ≤ 1 **[refuted]**: c_p < 1 is possible, as Part A shows. RL-m12 and RP-m2 pointed out that the phrase "a charge every program pays" was accurate only after this sharpening. It is now accurate up to a constant.

**Remark 2.3a (measuring time against t(|χ| + |p|)).** `notes.md` said this variant "removes both charges".
* **[refuted]** Without a cap, the prior is not normalisable. Let p_n := W_0⌢δ(n), where W_0 reads its argument and rejects. Then time_{p_n}(χ) ≤ α(|p_n| + 1), and the variant c'_{p_n} := sup_χ time/t(|χ| + |p_n|) is at most 2α·|p_n|^{1−a*}. So the weight is at least 2^(−|p_n|)·|p_n|^{a*−1}/(2α). Since |δ(n)| = log₂ n + O(log log n) and a* ≥ 2, the sum over n diverges. **[proved under (S); computed: `referee_penalty/r1_kt_prior.out`, Part B: 6563 at 10⁵ groups for a* = 3, still growing]**
* **[proved under (S)]** With weight 2^(−|p|)/max(1, c'_p), the variant is vacuous up to a constant. By Lemma 2.1(b), c'_{d_{q_f}} ≤ α + α'·2^{a'}, and the weights are at most 2^(−|p|).

**Proposition 2.4 (the content-relative penalty P3).**

(a) **It bites on Craig-type sets [proved, given the deterministic time hierarchy theorem (known)].** Take the language sequences of Convention 1.5. Suppose an AI^cont_t hypothesis G is compatible with every D^X_n, and every member of every G(φ) has the form ψ^(m) with ψ a literal ±φ_{w'}. Then X ∈ DTIME(q(C_G·t(λ(m)) + m)) for a constant C_G.
* *Proof.* B ∪ A_G is consistent, so G(φ_w) is equivalent to a consistent set of literals. A consistent set of literals not containing a power of φ_w (respectively ¬φ_w) does not imply φ_w (respectively ¬φ_w): take ℕ with R the set of values of the positive literals, which falsifies φ_w (respectively satisfies it), since distinct words have distinct values. So w ∈ X iff G(φ_w) contains a power of φ_w. Computing G(φ_w) and scanning it takes time O(t(|φ_w|)) on U, hence q(C_G·t(λ(m)) + m) on a multitape machine. ∎
* *Consequence.* Let T₁(m) := m·q(m·t(λ(m)) + m), and let T₂ be time-constructible with T₁·log T₁ = o(T₂). By the hierarchy theorem there is a decidable X ∈ DTIME(T₂) ∖ DTIME(T₁) [known; Hartmanis–Stearns 1965 with the Hennie–Stearns simulation (exact form not checked)]. Since q(C_G·t(λ(m)) + m) ≤ T₁(m) for m ≥ C_G, no Craig-type AI^cont_t hypothesis fits all of D^X, while FIcons has the constant-size f_X. (The re-indexing between |w| and |φ_w| and the overhead q are explicit here; RL-m6, RP-m8.)

(b) **Two sorts: vacuous for a true arithmetic background (corrected; RL-M2).** Let L-sentences live in a sort σ and arithmetic in a sort ν. Let B = B_A ∪ B_L, where:
* B_A is a decidable set of ν-sentences with Q ⊆ B_A ⊆ Th(ℕ);
* B_L is a decidable set of σ-sentences;
* B has no mixed-sort axioms.

Data and assigners concern σ-sentences. Then B ∪ Γ_f is consistent iff B_L ∪ Γ_f is: take ℕ ⊕ M with M ⊨ B_L ∪ Γ_f. Let G_f(φ) := {Acc_f(⌜φ⌝) → φ, Rej_f(⌜φ⌝) → ¬φ}.
* (b1) **[proved; Σ₁-completeness of Q for <-free sentences known, as cited in the paper]** If B_L ∪ Γ_f is consistent, then B ∪ A_f is consistent and Cn(B ∪ A_f) ∩ Sent_L = Cn(B_L ∪ Γ_f) ∩ Sent_L. This generalises `prop:time:twosorted` (B_A = Q, B_L = ∅).
  * *Consistency.* In ℕ ⊕ M with M ⊨ B_L ∪ Γ_f, Acc_f(⌜φ⌝) holds iff f accepts φ, and then φ ∈ Γ_f holds in M; rejections likewise. ℕ ⊨ B_A.
  * *⊇.* If f accepts φ, Acc_f(⌜φ⌝) is a true Σ₁ sentence, so Q ⊆ B_A proves it, and MP gives φ. Rejections likewise.
  * *⊆.* An L-sentence provable from B ∪ A_f holds in every ℕ ⊕ M with M ⊨ B_L ∪ Γ_f. Its truth there depends only on M, so by completeness it lies in Cn(B_L ∪ Γ_f).
* (b2) **[proved]** W_{AI^cont_t}(D) ≥ 2^(−c)·W_FI(D) for a fixed polynomial t.
  * G_f runs in time O(|f| + poly(|φ|)), i.e. O(t(|φ|)) with a constant that depends on G_f. A_{G_f} = A_f, and |G_f| ≤ |f| + c.
  * If f is compatible with D, B ∪ A_f is consistent by (b1). If f(φ_i) = acc, then B ∪ G_f(φ_i) ⊢ φ_i by Σ₁-completeness and MP; rejections likewise.
* (b3) **[proved]** W_{AI^cont_t}(D) ≤ 2^c·W_FI(D) for every t, in one sort or two (RP-m10). Map G to f_G := "search for proofs of φ and of ¬φ from B ∪ A_G"; A_G is r.e. If G is compatible, B ∪ A_G is consistent and B ∪ A_G ⊇ B ∪ G(φ_i) proves φ_i^{b_i}, so f_G is a compatible FIcons hypothesis, with |f_G| ≤ |G| + c.
* Hence, under these hypotheses, AI^cont_t ≡ FIcons up to a constant.
* (b4) **[refuted: `notes.md`'s version for "B ⊇ Q on the arithmetic sort"; counterexample by RL, checked here; assumes Con(PA) and the standard formalisation of computations]**
  * Let B_A := PA ∪ {¬Con(PA)} and B_L := ∅. B_A is decidable, contains Q, and is consistent by Gödel II.
  * Let ψ_0 be a satisfiable L-sentence. Let f accept ψ_0 at once, and on every other input search for a PA-proof of ⊥ and accept if it finds one. Since Con(PA) holds, Γ_f = {ψ_0}, and B ∪ Γ_f is consistent. So f is compatible with ((ψ_0, 1)).
  * But PA ⊢ ¬Con(PA) → Acc_f(⌜ψ⌝) for every L-sentence ψ ≠ ψ_0, the formalisation step of `prop:time:single`, already in IΣ₁. So B ⊢ Acc_f(⌜¬ψ_0⌝), and B ∪ A_f proves ¬ψ_0 as well as ψ_0. G_f is compatible with no data.
  * So the map f ↦ G_f fails for such B. Whether AI^cont_t ≡ FIcons holds for such B by another map is **[open]**; it falls under (d).

(c) **One sort, assigners consistent with true arithmetic [proved].** Let L ⊇ L_A, and let B be a decidable set of L_A-sentences with Q ⊆ B ⊆ Th(ℕ). For example, B = Q, or PA with induction for L_A-formulas only (RL-m8). Let f be an assigner with Th(ℕ) ∪ Γ_f consistent. Then B ∪ A_f is consistent, and G_f is compatible with D whenever f is.
* *Proof.* Take an L-structure M ⊨ Th(ℕ) ∪ Γ_f. Its L_A-reduct is elementarily equivalent to ℕ. So M ⊨ B, and for every sentence φ, M ⊨ Acc_f(⌜φ⌝) iff ℕ ⊨ Acc_f(⌜φ⌝) iff f accepts φ. If f accepts φ, then φ ∈ Γ_f and M ⊨ φ; rejections likewise. So M ⊨ B ∪ A_f. Derivations are as in (b2). ∎
* If B contains induction for formulas with symbols outside L_A, the hypothesis must be that Th(ℕ) ∪ B ∪ Γ_f is consistent.
* So W_{AI^cont_t}(D) ≥ 2^(−c)·W_{FI^ℕ}(D), where FI^ℕ is FIcons restricted to such f. Together with (b3), AI^cont_t lies between FI^ℕ and FIcons.

(d) **[open]** One sort, with assigners for which B ∪ Γ_f is consistent but Th(ℕ) ∪ Γ_f is not: does some AI^cont_t hypothesis, t polynomial, have the consequences of B ∪ Γ_f? Two corrections to `notes.md` (RL-m2):
* *Hänni's schema* "is then inconsistent" is **[refuted]** as a general claim. It *can* be inconsistent: the f of `prop:time:single`. It can also be consistent **[proved, given the standard formalisation of computations in PA]**: let f accept exactly ¬Con(PA), at once, and loop on every other input by a loop that PA proves endless. Then PA ⊢ ∀x (Acc_f(x) → x = ⌜¬Con(PA)⌝) and PA ⊢ ∀x ¬Rej_f(x), so every other member of A_f is a PA-theorem, and PA ∪ A_f is equivalent to PA + ¬Con(PA), which is consistent.
* *P3 on the known one-sorted encodings.* It bites on Craig-type hypotheses (part (a)). For the bounded schema A^bd_f of Proposition 2.5, only the per-axiom lower bound of Proposition 2.5(c) is proved. No analogue of part (a) for A^bd-type hypotheses is proved here.

**Proposition 2.5 (a one-sorted repair in the form of Hänni's schema: Craig's idea with a binary witness bound) [proved, given the MRDP theorem (known)].** Let L ⊇ L_A (one sort) and let B ⊇ Q be any decidable set of L-sentences, true or not.
* *The formulas.* By Lemma 1.4(a) write Acc^D_f(x) := Out(bin⌜f⌝, x, bin⌜acc⌝) = ∃ȳ (P_f(x, ȳ) = P'_f(x, ȳ)), with ȳ = (y_1, …, y_r). Then ℕ ⊨ Acc^D_f(bin⌜φ⌝) iff f accepts φ. Define Rej^D_f likewise.
* *The bounded formula.* Acc_f^{≤k}(x) := ∃ȳ (y_1 ≤ bin(k) ∧ … ∧ y_r ≤ bin(k) ∧ P_f(x, ȳ) = P'_f(x, ȳ)), with y ≤ s written as ∃z (z + y = s).
* *The schema.* A^bd_f := {Acc_f^{≤k}(bin⌜φ⌝) → φ : φ ∈ Sent_L, k ∈ ℕ} ∪ {Rej_f^{≤k}(bin⌜φ⌝) → ¬φ : φ ∈ Sent_L, k ∈ ℕ}.
* *The witness.* If f decides φ, w_f(φ) is the least k such that the equation for that decision has a solution ȳ ∈ {0, …, k}^r.

Then:

(a) Cn(B ∪ A^bd_f) = Cn(B ∪ Γ_f). In particular, B ∪ A^bd_f is consistent iff B ∪ Γ_f is, for sound and unsound assigners alike.

(b) Membership in A^bd_f is decidable in time polynomial in |χ| without running f: parse χ against the fixed formula with two numeral slots, and compare one slot with bin⌜φ⌝.

(c) Let f decide φ with label b. Suppose B, together with the decisions of f whose witnesses are below w_f(φ), does not prove φ^b. Then every finite F ⊆ A^bd_f with B ∪ F ⊢ φ^b contains an axiom with k ≥ w_f(φ), so with a numeral of about log₂ w_f(φ) symbols.

*Proof.*
* (a) Fix φ and k.
  * If f accepts φ with w_f(φ) ≤ k, Acc_f^{≤k}(bin⌜φ⌝) is provable in Q. Instantiate ȳ by the numerals of a solution in {0, …, k}^r, and z_i by the numeral of k − y_i; every conjunct is then a true closed equation (Lemma 1.4(c)). The axiom is then Q-equivalent to φ ∈ Γ_f.
  * Otherwise Q refutes the antecedent. Reason in Q: from the antecedent, Lemma 1.4(b), (d) give y_i ∈ {0, S0, …, S^k0} for each i. Each of the (k + 1)^r cases makes P_f(bin⌜φ⌝, ȳ) = P'_f(bin⌜φ⌝, ȳ) a false closed equation, which Q refutes (Lemma 1.4(c)). So the axiom is a Q-theorem.
  * Rejections are the same.
  * So every axiom is, over Q ⊆ B, equivalent to a member of Γ_f or to a theorem, and every member of Γ_f has its axiom (take k = w_f(φ)). Hence the claim.
* (b) Immediate; f is never run.
* (c) By (a), B ∪ F is contained in Cn(B ∪ {the decisions whose witnesses are at most the largest k in F}). ∎

*The counterexample of `prop:time:single`.* Every axiom Acc_f^{≤k}(bin⌜Con(PA)⌝) → Con(PA) has an antecedent with no solution at all, so Q refutes the antecedent and the axiom is a Q-theorem. Hence PA ∪ A^bd_f ≡ PA + ¬Con(PA), which is consistent. The nonstandard proofs of ⊥ that break Hänni's schema are out of reach, because the schema mentions only standard bounds.

*Framing (RL-m10, RP-m19).* The bound k plays the role of Craig's padding, written in binary inside Hänni's syntax. This answers model §10 problem 14 in a precise sense: a repair *in the form of Hänni's schema* that works for every consistent assigner in one sort, with syntactic membership. It is not a repair "short of Craig's trick" in substance. **[computed: `referee_logic/r2_q_models.out`]** In 576 nonstandard Q-structures, the bounded lemma holds in all; the false Σ₁ sentence ∃c (S0 + c = c) is true in 432; its numeral-bounded form is true in none. This is the mechanism by which A^bd_f escapes the nonstandard witnesses.

**Remark 2.6 (what `rem:time:summary`(1) and §6.4 of the paper say, made precise).**
1. *"Penalties on the time to check or generate axioms … do not block the collapse."* This is true of the FI → AI half: constant cost for P1a and for every form of P2 (Theorem 2.2), and a log₂(|f| + 1) + O(1) charge for P1b (Proposition 2.3). The paper's remark said "no bound on how much it changes `thm:time:equiv` is claimed"; these are the bounds.
2. *"Penalising the time to generate axioms fails too: φ^(k+1) ∈ A^C_f comes from k steps of f and is longer than k."*
   * *Per-axiom reading.* Correct: from φ, the Craig axiom is produced in about k steps and is longer than k.
   * *Enumeration reading, strict form.* No enumerator of A^C_f meets it once A^C_f is not polynomially sparse, for example when f is fast and total **[proved: Proposition 2.7]**. `notes.md`'s argument covered only the dovetailing enumerator (RL-m1, RP-M2).
   * *Enumeration reading, delay and cumulative forms, generic enumerator.* The FI → AI map produces the generic enumerator: the dovetailing wrapper of length |f| + c. **[refuted: "the generic enumerator of A^C_f is cheap"]** Let f_pow2 decide the s-th sentence within |φ_s| steps when s is a power of 2, and loop otherwise. At stage s at least s − 1 − log₂ s runs are unfinished, and each advance costs at least one step. So the axiom of sentence 2^j is completed after at least Σ_{s ≤ 2^j}(s − 1 − log₂ s) ≥ 4^j/2 − 2^j(1 + j) ≥ 4^j/4 steps (j ≥ 5). The j + 1 axioms written by then have total length O(j³), since |φ_s| = O(log s) and k ≤ |φ_s|. So the cumulative form fails for every polynomial t, and so does the delay form, which implies it. **[proved; computed: `referee_penalty/r2_enumeration.out`, Part C (ratio 1.0·10⁸ at j = 20); `referee_logic/r3_enum_parse_derive.out`, Part A (7.7·10⁶ at s = 2^18)]**
   * *Enumeration reading, the set.* For f_pow2 the *set* A^C_{f_pow2} has a cheap enumerator of length |f| + O(1): for j = 0, 1, 2, …, generate sentence 2^j directly, run f on it and write the axiom. **[proof sketch: generating the 2^j-th sentence in time polynomial in j is not written out; computed: r2 Part C, ratio ≤ 1.25; r3 Part A, ratio ≤ 1.22]** Whether some f has a Craig set with no cheap cumulative enumerator of length |f| + O(1) is a search-versus-decision question **[open]**.
   * So the paper's justification is incomplete for the enumeration reading. Its conclusion, that a generation penalty does not block the collapse, is correct by Lemma 2.1 and Theorem 2.2.
3. Measured against the content instead (P3), the penalty does bite on Craig-type sets (Proposition 2.4(a)). It is vacuous through Hänni's schema with a true arithmetic background (Proposition 2.4(b), (c)).
4. None of this concerns the AI → FI half, which is §3.

**Proposition 2.7 (the strict form of P2 is a sparsity condition) [proved].** Let t be nondecreasing.
(a) If an enumerator g meets the strict form, there are C, i_0 with #{χ ∈ A_g : |χ| ≤ L} ≤ i_0 + C·t(L) for every L.
(b) Pad(q) has at most L members of length at most L.
(c) The following sets have more than C·L^k members of length at most L, for every C, k and all large L. So for polynomial t, none of them has a strict-form enumerator, in any order:
  * (i) the instance set of a template with a formula metavariable (for instance PA's induction schema), in any language with equality (the sentences θ_c below use only =, ∀, ¬ and →);
  * (ii) the unpadded Craig set A^C_f of an assigner f that decides every sentence φ within |φ| steps.

*Proof.*
* (a) Let e_i ≤ C·t(|a_i|) for i ≥ i_0. The steps e_1 < e_2 < … are distinct, so e_i ≥ i. A member of length at most L is some a_i with |a_i| ≤ L. If i ≥ i_0, then i ≤ e_i ≤ C·t(L).
* (b) A member written at counter T has length at least T + 1, and different members have different counters (§1.2).
* (c) Let θ_c (c ∈ {0,1}^k) be the valid sentences of Theorem 4.2(b). There are 2^k distinct ones, of size at most 10k + 11.
  * (i) Substituting the closed bodies θ_c gives 2^k distinct instances (θ ↦ τθ is injective, AS Thm 2.5(a)) of size at most c_τ·k + c'_τ.
  * (ii) A^C_f contains, for each φ = θ_c, the axiom φ^(k'+1) or (¬φ)^(k'+1) with k' ≤ |φ|, of size at most 2(|φ| + 3)². Distinct φ give distinct axioms. So there are 2^k members of size O(k²). ∎

**[computed: `referee_penalty/r2_enumeration.out`, Part A; `referee_logic/r3_enum_parse_derive.out`, Part B]** The fast-f Craig set exceeds C·L^{a*} from L = 1113 (C = 1, a* = 3) to L = 7674 (C = 10⁶, a* = 5). The one-metavariable template {R(w) → R(w)} (term metavariable, binary function symbol) exceeds it from L = 39 to L = 117. Pad(q) never does. RL's counts exceed C·L^p at L = 2504, 5912, 13947 for (C, p) = (10³, 3), (10⁶, 4), (10⁹, 6).

So P2-strict, with polynomial t, admits only polynomially sparse axiom sets (the padded sets and the finite sets among them), and no template theory with a formula metavariable. It measures density, not generation time. This is why the delay form is the default (RP-M1). Theorem 2.2(b) holds for all three forms, because every r.e. theory has a sparse padded axiomatisation. Remark 5.6 draws the consequence for H-d.

---

## 3. AI → FI under an FI-side penalty: the equivalence becomes one-sided (H-b)

**Theorem 3.1 (axiom induction dominates time-penalised consistent function induction) [proved; under (S) for the penalised AI variants].** Let u be a weight function on FIcons hypotheses. Let X be an inductor with
  W_X(D) ≥ 2^(−c_X)·Σ_{g FIcons, compatible with D} u(g) for every finite D,  and  W_X(∅) ≤ Ω_X.
Let Y be an inductor with W_Y(D) = Σ_{h compatible with D} v(h, D), where the weights may depend on D. Suppose that:
* each hypothesis h of Y is mapped injectively to an FIcons hypothesis g_h that computes the same partial map as h;
* v(h, D) ≤ K·u(g_h) for every D;
* W_Y(∅) ≥ κ > 0.

Then for every D,
  ℓ_X(D) ≤ ℓ_Y(D) + c_X + log₂(K·Ω_X/κ).

*Proof.*
* h is compatible with D iff g_h is, since they label every sentence alike. So W_X(D) ≥ 2^(−c_X)·Σ_{h compatible} u(g_h) ≥ 2^(−c_X)·K^(−1)·W_Y(D), using injectivity.
* Hence ℓ_X(D) = −log₂ W_X(D) + log₂ W_X(∅) ≤ −log₂ W_Y(D) + c_X + log₂ K + log₂ Ω_X.
* And −log₂ W_Y(D) = ℓ_Y(D) − log₂ W_Y(∅) ≤ ℓ_Y(D) + log₂(1/κ). ∎

*Instances of X.*
* AI, AI^chk_t, and AI^gen_t in each form (t ≥ m^{a*}), with u(g) = 2^(−|g|) and Ω_X = 1: Theorem 2.2, and `thm:time:equiv` for AI.
* FIcons itself, with u(g) = 2^(−|g|).
* AI^cont_t in two sorts with B = B_A ∪ B_L, B_A true in ℕ (Proposition 2.4(b)), with u(g) = 2^(−|g|).
* AI^Kt_t, with u(g) = 2^(−|g|)/(|g| + 1) and Ω_X = t(m_0) (Proposition 2.3).

*Instances of Y, for u(g) = 2^(−|g|).*
* FIcons_τ. Let g_h be a fixed wrapper that runs h^τ, followed by E(h). Then |g_h| = |E(h)| + c_τ and w(h) = 2^{c_τ}·2^(−|g_h|), so K = 2^{c_τ}. κ is at least the weight of the always-abstain string.
* Kt-weighted FIcons (g_h = h, K = 1), and time-weighted FIcons (v(f, D) ≤ 2^(−|f|), K = 1).
* The consistent part of any time-bounded mixture of deterministic assigners whose weights are at most K·2^(−|g_h|).

*AI^Kt_t.* The theorem applies against Y with v(h, D) ≤ K·2^(−|g_h|)/(|g_h| + 1), for example FIcons with weights 2^(−|f|)/(|f| + 1), clocked or not. Against FIcons_τ it gives only ℓ_{AI^Kt_t}(D) ≤ −log₂ Σ_{h compatible} w(h)/(|E(h)| + c) + O(1). Whether AI^Kt_t has uniformly bounded regret against FIcons_τ is **[open]** (RL-M1(2)).

*Not covered.*
* P3 in one sort: Proposition 2.4(c) gives the lower bound only against FI^ℕ.
* P3 in a decidable logic: there the conclusion fails (Remark 5.2).

*A corrected hypothesis (RL-m5, RP-m5).* `notes.md` required only Γ_{g_h} = Γ_h. **[refuted as sufficient]** Let h reject ψ, and let g accept ¬ψ and abstain on ψ. Then Γ_g = Γ_h = {¬ψ}, but on the datum (ψ, 0) h is compatible and g is not. All the instances above satisfy the corrected hypothesis.

**Theorem 3.2 (diagonal separation) [proved, given Kleene's recursion theorem and the MRDP theorem (known)].** Let L ⊇ L_A (one sort), and let B be decidable and true in some expansion of ℕ to L (B = ∅ is allowed). Let E, E' be as in Lemma 1.4(a). Let
  DET := ∀e ∀x ∀y ∀y' ∀c̄ ∀c̄' (E(e, x, y, c̄) = E'(e, x, y, c̄) ∧ E(e, x, y', c̄') = E'(e, x, y', c̄') → y = y').
DET is a true Π₁ sentence: a program has at most one output on a given input. Put H_0 := Q ∪ {DET}, a finite set of true sentences. For every computable predictor P there is a program e such that, with
  s_n := Out(bin(e), bin(n), S0)  and  b_n := 1 if ℕ ⊨ s_n, else 0,
the following hold.

(a) e computes a total function, and e(n) = b_n ∈ {0, 1} for every n.

(b) H_0 ⊢ s_n if b_n = 1, and H_0 ⊢ ¬s_n if b_n = 0. So H_0 decides every s_n. It is not complete (RL-m13, RP-m9).

(c) For every n, ℓ_P(D_n) ≥ n − Σ_{j≤n} log₂(1 + 2^(−j−2)) ≥ n − 1/(4 ln 2) ≥ n − 0.361. If P's outputs are exact, ℓ_P(D_n) ≥ n. The first bound is attained up to rounding (c4, Part A).

(d) Let a variant of AI admit H_0 as a hypothesis of weight ω > 0, with W(∅) ≤ Ω. Then ℓ(D_n) ≤ log₂(Ω/ω) for all n.
* This covers AI, AI^chk_t and AI^gen_t in all forms, with Ω = 1: H_0 is finite, so its decider and enumerator are cheap.
* It covers AI^Kt_t with Ω = t(m_0) (RP-m1), and AI^cont_t with G(φ) := H_0.
* If B ⊇ H_0, the empty hypothesis serves instead.
* The bound does not depend on P.

*Proof.*
* *The construction.* Let G(e', n) be the program that, for j = 1, …, n:
  * forms σ_j := ⌜Out(bin(e'), bin(j), S0)⌝;
  * asks P for approximations (a_0, a_1), within 2^(−j−3), of its predictive pair on the history ((σ_1, β_1), …, (σ_{j−1}, β_{j−1})) and the sentence σ_j;
  * sets β_j := 0 if a_0 ≤ a_1, and β_j := 1 otherwise;

  and then outputs β_n. G is total computable, because P is total and G makes finitely many calls.
* *The recursion theorem* [known; Kleene; Rogers 1967, §11.2 (not checked)]. There is e with e(n) = G(e, n) for all n.
* (a) The values β_1, …, β_j computed inside G(e, n) do not depend on n. So e(j) = β_j, and σ_j = ⌜s_j⌝. Since e(n) ∈ {0, 1}, Lemma 1.4(a) gives ℕ ⊨ s_n iff e(n) = 1, so b_n = β_n. In particular, P is asked only about the true histories D_{j−1}.
* (b) If b_n = 1, then s_n is a true sentence of the form ∃c̄ (E = E'), so Q proves it (Lemma 1.4(c)). If b_n = 0, then e(n) = 0, so Out(bin(e), bin(n), 0) is a true existential equation, and Q proves it. Together with s_n, DET gives S0 = 0, against Q1. So H_0 ⊢ ¬s_n. Only the truth of DET is used, to make B ∪ H_0 consistent in (d); that PA proves it is not needed (RL-m14).
* (c) Let q_b := q_b(D_{j−1}, s_j), and ε := 2^(−j−3).
  * The tie rule gives a_{b_j} ≤ a_{1−b_j}. So q_{b_j} ≤ a_{b_j} + ε ≤ a_{1−b_j} + ε ≤ q_{1−b_j} + 2ε.
  * With q_0 + q_1 ≤ 1 this gives 2q_{b_j} ≤ 1 + 2ε, i.e. q_{b_j} ≤ 1/2 + 2^(−j−3). So −log₂ q_{b_j} ≥ 1 − log₂(1 + 2^(−j−2)).
  * Summing, Σ_{j≥1} log₂(1 + 2^(−j−2)) ≤ Σ_{j≥1} 2^(−j−2)/ln 2 = 1/(4 ln 2). Numerically the infinite sum is 0.3466.
  * With exact outputs, q_{b_j} ≤ q_{1−b_j}, so q_{b_j} ≤ 1/2. If q_{b_j} = 0 the loss is infinite.
  * `notes.md` used q_{b_j} ≤ (q_0 + q_1)/2 + 2ε, which gives n − 1/(2 ln 2). The sharper form is RL's observation.
* (d) H_0 is true in ℕ and B in an expansion of ℕ, so B ∪ H_0 is consistent, and by (b) H_0 is compatible with every D_n. So W(D_n) ≥ ω, and W(∅) ≤ Ω. ∎

**[computed: `checks/c1_diagonal.out`, `checks/c4_revision.out` Part A, `referee_logic/r1_quine_diagonal.out`]**
* *c1.* Eight predictors: KT, Laplace, a Markov mixture, a toy clocked FIall mixture with partial hypotheses (q_0 + q_1 < 1), a late-start mixture in the style of S, a deficient semimeasure, a predictor within the approximation error of 1/2, and one that reads the sentence index. Exact, seeded-random and adversarial approximations; N = 2000. Every case satisfies `notes.md`'s bound ℓ_n ≥ n − 0.7213 at every n, and ℓ_n ≥ n in exact mode. The minimum of ℓ_n − n is −0.313. Part B rebuilds D(n) from scratch for n ≤ 150 and finds the labels consistent. Its predictor (KT) ignores the sentences, so Part B does not exercise the self-reference (RL-m15).
* *c4, Part A.* Predictors of the same kinds against the sharpened bound: all cases hold. The sharp adversary (q_1 = 1/2 ± (1 − 10⁻⁹)·2^(−j−3), approximations pushed the wrong way) reaches ℓ_n − n = −0.3466, within 1.6·10⁻¹⁰ of the bound.
* *r1 (RL).* Here e is a genuine quine whose sentences s_j contain its own source. Five predictors read those sentences; one of them parses e out of s_j and runs it with a budget. The fixed point holds, the histories recomputed from scratch agree, and the sentences agree with s_j computed outside e. The near-1/2 adversary reaches −0.343.

**Corollary 3.3 [proved].**

(a) **Hänni's S and the clocked FIall_τ.**
* S, read as in §1.4, is a computable predictor. On its diagonal sequence ℓ_S(D_n) ≥ n − 0.37, while ℓ_AI(D_n) ≤ log₂(1/ω).
* The same holds for FIall_τ after mixing in a uniform component. Put P(D) := (W_{FIall_τ}(D) + 2^(−|D|))/(W_{FIall_τ}(∅) + 1), with predictive pair q_b(D, φ) := P(D + (φ, b))/P(D).
  * q_0 + q_1 ≤ 1, because FIall_τ is a semimeasure and the uniform part halves at each step.
  * P is computable: clocked compatibility is decidable and the weight tails are computable (§1.2), so W_{FIall_τ}(D) is a computable real, and P(D) ≥ 2^(−|D|−1) > 0.
  * P(∅) = 1, so ℓ_P(D_n) = −log₂ P(D_n).

(b) **FIcons_τ.** Its weights involve the consistency of B ∪ Γ_{f^τ}, a co-r.e. condition, so it is not given as a computable predictor, and Theorem 3.2(c) does not apply to it directly. But W_{FIcons_τ}(D) ≤ W_{FIall_τ}(D) ≤ (W_{FIall_τ}(∅) + 1)·P(D) ≤ 2P(D). Hence, on P's diagonal sequence,
  ℓ_{FIcons_τ}(D_n) ≥ ℓ_P(D_n) − 1 + log₂ W_{FIcons_τ}(∅) ≥ n − 1.37 − c_⊥,
with c_⊥ := −log₂ w(always abstain). Together with Theorem 3.1: AI's regret against FIcons_τ is bounded above uniformly, and FIcons_τ's regret against AI is at least n − O(1) on some computable sequence (RL-m7, RP-m9).

(c) **Incomputability.** No partial computable function gives approximations of the predictive probabilities of AI on every pair (D, φ) with W_AI(D) > 0. The same holds for AI^chk_t, AI^Kt_t, AI^gen_t, AI^cont_t and FIcons.
* *Proof.* Suppose one did. Run the construction of Theorem 3.2 with it in place of P; the recursion theorem applies to partial computable G.
* By induction on j, G(e, n) halts. If β_1, …, β_{j−1} have been computed, they are the true labels of s_1, …, s_{j−1}. Then H_0 is compatible with D_{j−1}, so W(D_{j−1}) ≥ ω > 0, and the query on (D_{j−1}, s_j) returns.
* The per-step losses of this predictor telescope to ℓ_AI. So (c) and (d) of Theorem 3.2 give n − 0.37 ≤ log₂(Ω/ω) for all n, a contradiction.
* For FIcons, use the constant-size assigner u of Proposition 4.1 in place of H_0. ∎

**Proposition 3.4 (S, FIall_τ and AI are incomparable) [proved].**
* (a) On the sequences of `prop:time:fiall` (the literals R(w_i) or ¬R(w_i) by independent fair coins, all labelled true), ℓ_S ≤ log₂(1/π_1) + ℓ_1.
  * S's probability of a label sequence is at least Σ_i π_i·P̃_i(b_1 … b_n), where P̃_i is component i as counted: 1/2 before its start and when over budget.
  * The term of the constant predictor of §1.4(ii) is at least π_1·2^(−ℓ_1).
  * FIall_τ likewise has loss at most −log₂ w(always accept), for τ at least the constant time of "always accept" on U_0.
* (b) On the same sequences, AI's expected loss is at least n, and so is FIcons's (`prop:time:fiall`).
* (c) On their diagonal sequences, S and FIall_τ lose at least n − 0.37 and n − 1.37, while AI loses a constant (Corollary 3.3(a)).

So neither of S and AI dominates the other, and likewise for FIall_τ and AI. This uses only the structure of S, not Hänni's regret theorem (RL-m14, RP-m14).

**[refuted: `notes.md` §0.1, "axiom induction becomes strictly stronger than every time-bounded function inductor"]** S and FIall_τ are time-bounded function inductors, and part (a) is the counterexample (RL-M1, RP-M5). What is proved is strict superiority over time-penalised *consistent* function induction: Theorem 3.1 with Corollary 3.3(b). That is the fair comparison, as the paper argued for the unpenalised case.

**Remark 3.5 (what the arithmetic buys; other languages).**
* In any language with infinitely many logically independent sentences (e.g. atoms R(c_n)), the same diagonal labels are fitted by the consistent assigner f_D ("run the construction"). Its length is |P| + c, so FIcons, and AI by `thm:time:equiv`, still lose at most |P| + c. Arithmetic makes the constant independent of P (the hypothesis H_0, or u in Proposition 4.1). **[proved]**
* The recursion theorem can be avoided with a fresh predicate R and the hypothesis H_0 ∪ {∀x (R(x) ↔ Out(bin(g), x, S0))}, at a cost of |P| + c bits. **[proved]**
* *Bounded sentences in Q.* The orchestrator's variant "decided by Q if written as bounded sentences" does not work as stated. **[conjecture]** It cannot be repaired without a computable bound on P's running time. The heuristic reason: a numeral bound inside s_n would have to exceed the length of e's computation on n, which includes the query on s_n itself. RL-m3 noted that `notes.md` stated this negative claim without proof. Two alternatives do work:
  * Q ∪ {DET} (Theorem 3.2);
  * the Rosser form ∃c (T(ē, n̄, c) ∧ Out(c, 1̄) ∧ ∀c' ≤ c ¬(T(ē, n̄, c') ∧ Out(c', 0̄))), **[proof sketch]**. It needs T and Out as Δ₀ formulas with bounded quantifiers written as ∃z (z + x = y). The Δ₀ formalisation is known, but its reference was not checked (RL-m16). It also needs Q ⊢ ∀x (x ≤ n̄ ∨ n̄ ≤ x) for this orientation of ≤ [known; Smith 2013 (numbering not checked); computed: `r2_q_models.out`, row D1 in all 576 structures; the other orientation fails in 288]. The Rosser form is not used elsewhere.

---

## 4. Where the separation comes from (H-c)

**Proposition 4.1 (the universal evaluator; a time-hierarchy effect) [(a), (b) proved; (c) proof sketch].**

(a) Let u be the assigner that, on an input of the form Out(bin(e), bin(n), S0), runs e on n, and outputs acc if the result is 1 and rej if it is anything else (looping if e loops). On all other inputs it abstains. Then Γ_u ⊆ Th(ℕ), so u is consistent with every B true in an expansion of ℕ. |u| is a constant.

(b) On every diagonal sequence of Theorem 3.2, u labels every datum correctly, since e is total with values in {0, 1}. So *unpenalised* FIcons (and FIall) has ℓ(D_n) ≤ |u| there, and it beats every computable predictor by n − O(1), exactly as AI does. The running time of u on s_n is at least that of e on n, which includes the total time P spends on its first n predictions. The proof-search assigner f_{H_0}, which AI's hypothesis H_0 becomes under `thm:time:equiv`, is slower still.

(c) **[proof sketch, resting on Hänni's construction and his theorem for S]** Let S_p have per-step time p(n)·log n, with state reuse. The diagonal labels against S_p are produced by a predictor with per-step time O(p(n)·log n) and state reuse, which predicts its own labels with certainty. So S_{p'}, for a slightly larger p' (for example n·p(n)), has bounded loss on the sequence that defeats S_p. Not written out: Hänni's apples-to-apples version, and the RAM-model caveat he names.

*Proof of (a), (b).* u's decisions are correct in ℕ. The rest is Theorem 3.2(a). ∎

So the separation of §3 does not come from axioms as such. Unbounded consistent function induction has it too, through the single constant-size hypothesis u. Free proof search in AI is free evaluation of u in FI. Under a time bound, the separation is a hierarchy effect: whatever the bound, the sequence that defeats it is computable with a slightly larger one.

**Theorem 4.2 (charged deduction: axiom induction ≡ certificate function induction) [proved, given the propositional derivation fact cited (known; computed)].** Assume the setting of Definition 1.3 (L finite, B decidable in polynomial time, d and t time-constructible and nondecreasing). There are a constant c and fixed polynomials, depending only on U, K, the codings and B, such that for every finite D:

(a) W_{AI[t, d]}(D) ≤ 2^c·W_{FIcert[t⁺, d']}(D), with t⁺(m) := m^{k_0}·(t(m) + 1) and d'(m) := β·d(m)·log₂(d(m) + 2);

(b) W_{FIcert[t', d']}(D) ≤ 2^c·W_{AI[t'^#, d^#]}(D), with t'^#(m) := m^{k_1} + t'(m) and d^#(m) := γ(m + d'(m) + 1).

This is a form of the standard correspondence between proof systems and NP [known: Cook and Reckhow 1979]. Part (a) is the fact that bounded-size provability from a polynomial-time axiom set is an NP predicate. Part (b) is Craig's trick with certificates in place of padding. `notes.md` called it new; that is withdrawn (RP-m19).

*Proof of (a).*
* *The map.* For a decider p let V_p(φ, c) := "if c codes a K-derivation of φ (respectively ¬φ) from B ∪ A_p of symbol size at most d(|φ|), output acc (respectively rej); otherwise output ⊥".
  * L is finite, so a derivation of symbol size s has a bit code of length at most β·s·log₂(s + 2) (variables numbered in binary), whence d' (RP-m7).
  * Checking a line takes polynomial time for the logical axioms (A4 included, by first-order matching), for B, for MP and for Gen. It takes O(t(|c|)) for membership in A_p via p. So V_p runs in time O(t⁺(|φ| + |c|)) on all inputs.
* *Compatibility.* Let p be compatible with D. Then B ∪ A_p is consistent, so no φ has both an acc and a rej certificate, and Γ_{f_{V_p}} ⊆ Cn(B ∪ A_p) is consistent with B. Each datum φ_i^{b_i} has a derivation within d(|φ_i|), which is a certificate. So f_{V_p}(φ_i) = b_i, and V_p is compatible.
* *Weights.* |V_p| ≤ |p| + c, and p ↦ V_p is injective. ∎

*Proof of (b).*
* *Syntax.* Sentences are in K's primitive Polish syntax: ∧ abbreviates B ∧ C := ¬(B → ¬C) (RL-m18).
* *The certificate sentences.* Let τ_0 := ∀x (x = x) (5 symbols), τ_1 := ¬¬∀x (x = x) (7 symbols) and τ_E := ∀x (x = x) → ∀x (x = x) (11 symbols). Put θ_ε := τ_E and θ_{bc} := (τ_b ∧ θ_c).
  * Each θ_c is logically valid.
  * c is read off θ_c uniquely: the root symbol separates τ_E from a conjunction, and τ_0 from τ_1.
  * |θ_c| ≤ 10|c| + 11.
* *The axiom set.* For a hypothesis V let A_V := {φ ∧ θ_c : V(φ, c) = acc, |c| ≤ d'(|φ|)} ∪ {¬φ ∧ θ_c : V(φ, c) = rej, |c| ≤ d'(|φ|)}.
* *Membership.* Given χ, parse it as ¬(ψ → ¬θ). This is unique by unique readability, since ψ is the left immediate subformula of the implication. Read c off θ. Accept iff V(ψ, c) = acc and |c| ≤ d'(|ψ|), or ψ = ¬φ, V(φ, c) = rej and |c| ≤ d'(|φ|). d' is time-constructible, so the comparison can stop after |c| + 1 steps. Time O(t'^#(|χ|)), and the decider p_V has |p_V| ≤ |V| + c.
* *Consequences.* Each axiom is logically equivalent to its member of Γ_{f_V}, and each member of Γ_{f_V} has at least one certificate axiom. So Cn(B ∪ A_V) = Cn(B ∪ Γ_{f_V}), which is consistent.
* *Derivations.* For a datum with f_V(φ_i) = b_i, take a certificate c with |c| ≤ d'(|φ_i|). The derivation cites φ_i^{b_i} ∧ θ_c, then the substitution instance B := φ_i^{b_i}, C := θ_c of a fixed K-derivation of the tautology (B ∧ C) → B, then MP.
  * Substitution instances of derivations are derivations, and the propositional fragment of K is complete [known]. So the size is linear in |B| + |C|.
  * Hence the derivation has size at most γ(|φ_i| + |c| + 1) ≤ d^#(|φ_i|). ∎

**[computed: `checks/c3_certificate.out`; `referee_logic/r3_enum_parse_derive.out`, Parts C and D]**
* *c3.* The construction was run for X := {n : the least prime factor of n is 1 mod 4}, which is in NP ∩ coNP via factorisations checked by deterministic Miller–Rabin. It uses an infix syntax with an "&" token, in which |θ_c| ≤ 12|c| + 17.
  * Unique parsing holds on 3000 random (ψ, c).
  * The decider accepts the right polarity, and rejects the wrong one and tampered or over-long certificates.
  * |χ| ≤ |ψ| + 12|c| + 20 and |c| ≤ 3|φ| + 8 hold on 210 cases up to 60-bit n.
  * Decider work stays below |χ|³ and never factors.
  * By contrast, trial division, a deterministic assigner, needs up to 1.0·10⁹ steps on the 60-bit semiprimes. Its unpadded Craig axioms would be about 7·10¹⁰ symbols long, against about 1350 for the certificate axioms.
* *r3, Part C (RL).* Unique parsing in K's primitive Polish syntax on 4000 cases, with |θ_c| ≤ 10|c| + 11.
* *r3, Part D (RL).* A 287-line K-derivation of (P ∧ Q) → P from A1–A3 and MP, built with the deduction-theorem algorithm and checked by an independent checker. Its substitution instances have size exactly 3725|B| + 1559|C| + const. This covers Theorem 4.2(b) and the Craig derivations of Corollary 4.3(a).

**Corollary 4.3 (what is left of the asymmetry when deduction is charged).**

(a) **[proved under (S)]** FIcons_τ is dominated by AI[t_C, d_τ]: W_{AI[t_C, d_τ]}(D) ≥ 2^(−c)·W_{FIcons_τ}(D). Here t_C is a fixed polynomial and d_τ(m) := γ(τ(m) + 1)(m + 4).
* *The map* is Craig's: a τ-clocked string f goes to a decider of A^C_{f^τ}, of length at most |E(f)| + c, injectively.
* *Membership.* There are at most two candidates χ = ψ^(m). Check m − 1 ≤ τ(|φ|) by running the constructor of τ for at most m steps, and simulate f on U_0 for m − 1 steps. This is time polynomial in |χ|, of a degree independent of f.
* *Consequences* are those of Γ_{f^τ}, which is consistent.
* *Derivations.* Cite (φ^{b})^(k+1) with k ≤ τ(|φ|), then the instance B := φ^b, C := (φ^b)^(k) of the derivation of (B ∧ C) → B, then MP. The size is linear in (k + 1)(|φ| + 1) + 3k ≤ (τ(m) + 1)(m + 4).

Alternatively, Theorem 4.2(b) with f's computation trace as the certificate gives membership in polynomial time and d ≈ τ·log τ.

(b) **[proved; per hypothesis]** For each decider p of AI[t, d], let f_p be the brute-force assigner: on φ, run V_p (Theorem 4.2(a)) on every certificate of length at most d'(|φ|). Then |f_p| ≤ |p| + c.
* Put τ_d(m) := m·q(2^{d'(m)+1}·t⁺(m + d'(m))), with q from Convention 1.5. By its third property, f_p^{τ_d} agrees with f_{V_p} on every sentence of length at least some m_p.
* Adding a table for the finitely many shorter sentences gives a hypothesis of FIcons_{τ_d} with the same labels as f_{V_p}, at a cost that depends on p.
* So, on every infinite labelled sequence, bounded loss of AI[t, d] implies bounded loss of FIcons_{τ_d} (Lemma 1.6).
* No uniform constant is claimed. FIcons_τ's clock has no asymptotic constant (RL-m6), and its weights are 2^(−|E(f)|) = 2^(−|f| − O(log |f|)) (RP-m6). `notes.md` stated (b) with a uniform 2^c.
* τ_d is deterministic exponential time.

(c) **Language sequences [proved].** Use Convention 1.5.
* (i) ℓ_{FIcons_τ}(D^X_n) is bounded iff some τ-clocked f labels every φ_w correctly (Lemma 1.6). If so, X ∈ DTIME(q(C_f·τ(λ(m)) + m)). Conversely, suppose some multitape machine decides X within T(|w|) steps for every w, and τ(|φ_w|) ≥ q(T(|w|) + |φ_w|) for every w. Then the loss is bounded.
* (ii) ℓ_{AI[t,d]}(D^X_n) is bounded iff some single p gives every datum a derivation within d (Lemma 1.6). Then X ∈ NTIME(T_p) ∩ coNTIME(T_p) with T_p(m) := C_p·poly(d(λ(m)))·t(d(λ(m))): apply `thm:time:ntime` to X and to its complement, with membership checks costing O(t) per line. Conversely, if X and its complement have verifiers in time t' with certificates of length at most d', then AI[t'^#, d^#] has bounded loss (Theorem 4.2(b); the literals are consistent).

(d) **Unconditional separation [proved, given the deterministic time hierarchy theorem (known; Hartmanis–Stearns 1965 with the Hennie–Stearns simulation, exact form not checked)].** Let τ be time-constructible.
* Let T₁(m) := m·q(m·τ(λ(m)) + m), and let T₂ be time-constructible and nondecreasing with T₁·log T₁ = o(T₂). Take a decidable X ∈ DTIME(T₂) ∖ DTIME(T₁).
* *FIcons_τ fails.* If a τ-clocked f labelled every φ_w correctly, then X ∈ DTIME(q(C_f·τ(λ(m)) + m)) by (c)(i), and q(C_f·τ(λ(m)) + m) ≤ T₁(m) for m ≥ C_f. A table handles the finitely many shorter words, so X ∈ DTIME(T₁), a contradiction. Hence ℓ_{FIcons_τ}(D^X_n) → ∞.
* *AI succeeds.* Let τ₃ be time-constructible with τ₃(m) ≥ q(C_X·T₂(m) + m), where C_X is the constant of a machine for X. By (c)(i), some τ₃-clocked string labels every φ_w correctly. By (a), AI[t_C, d_{τ₃}] has a hypothesis compatible with every D^X_n, so its loss is bounded.
* So the separation needs a derivation budget d_{τ₃}(m) = γ(τ₃(m) + 1)(m + 4), a polynomial of T₂, where T₂ is slightly more than a polynomial of τ∘λ. This corrects `notes.md` §0.1, which said "when d exceeds τ by a polynomial factor" (RP-m9). The overhead q and the re-indexing λ are now explicit (RL-m6, RP-m8).

(e) **Polynomial budgets.** Both mixtures charge their degrees (RP-M4).
* **FIcons_poly** mixes over pairs (f, k), f a string and k ≥ 1. The assigner is f clocked at (|φ| + 2)^k, and B ∪ Γ of it must be consistent. Weight w(f)·2^(−2⌈log₂(k+1)⌉−1).
* **AI[poly, poly]** mixes over triples (p, i, j), p a string.
  * A_{p,i} := {χ : U_0(p, χ) = yes within (|χ| + 2)^i steps}.
  * (p, i, j) is compatible with D if B ∪ A_{p,i} is consistent and each datum has a K-derivation from B ∪ A_{p,i} of size at most (|φ_i| + 2)^j.
  * Weight w(p)·2^(−2⌈log₂(i+1)⌉ − 2⌈log₂(j+1)⌉ − 2).

Both are mixtures as in Lemma 1.6. A constant factor in a running time is absorbed by raising the exponent, since |φ| + 2 ≥ 2.
* (e1) **[proved, conditional on NP ∩ coNP ≠ P]** Let X ∈ (NP ∩ coNP) ∖ P. Then AI[poly, poly] has bounded loss on D^X, and ℓ_{FIcons_poly}(D^X_n) → ∞.
  * *AI.* Verifiers for X and its complement give, by Theorem 4.2(b), a string p_V whose membership time on U_0 is at most C·(|χ| + 1)^{i_0}. So A_{p_V, i} = A_V for i ≥ i_0 + log₂ C. Its derivations have size at most γ(m + d'(m) + 1) ≤ (m + 2)^j for some j. So (p_V, i, j) fits all of D^X.
  * *FIcons_poly.* If some (f, k) fitted all of D^X, then X ∈ DTIME(q(C_f·(λ(m) + 2)^k + m)) ⊆ P. So none does, and Lemma 1.6 gives ℓ → ∞.
* (e2) **[proved, conditional on P = NP]** On every infinite labelled sequence, AI[poly, poly] has bounded loss iff FIcons_poly has.
  * *From AI to FI.* Let (p, i, j) fit all of D. Let V be the verifier of Theorem 4.2(a) for A_{p,i}; it runs in polynomial time, because membership in A_{p,i} is clocked. Acceptance, "∃c (|c| ≤ d'(|φ|) ∧ V(φ, c) = acc)", is an NP predicate of φ, and so is rejection. If P = NP, both are decided in polynomial time, which gives (f, k) with f clocked at (|φ| + 2)^k equal to f_V. Γ_{f_V} ⊆ Cn(B ∪ A_{p,i}) is consistent, and f_V labels every datum of D.
  * *From FI to AI.* If (f, k) fits all of D, the Craig decider of (a) for f clocked at (|φ| + 2)^k fits all of D. Its membership degree i is fixed up to a constant that the exponent absorbs, and j = k + O(1).
  * Then apply Lemma 1.6 in both directions.
* (e3) **[open]**
  * *The intermediate case* (P ≠ NP but NP ∩ coNP = P). The relevant notion is separability, by consistent polynomial-time assigners, of the disjoint NP pairs (provable, refutable) of AI hypotheses.
  * *Uniform domination* in either direction is not established even under P = NP. The hypothesis-wise factors are polynomial in |p|, i and j: the map of (e2) changes the degrees polynomially and needs O(log) bits to name them.
* (e4) **[proved, given the deterministic time hierarchy theorem; RP-M4]** With the membership degree *uncharged*, FIcons_poly does not dominate AI[poly, poly], unconditionally. This is `notes.md`'s definition: pairs (p, j), with p a decider of membership time O(|χ|^i) for some i, and weight 2^(−|p|−2⌈log₂(j+1)⌉−1).
  * *Setup.* Fix b, depending only on q, β and β', such that q(C·(λ(m) + 2)^k + m) ≤ m^{bk} for all k ≥ 1 and m ≥ m(C). For r ≥ 1 let N := 2^(2^r), and take X_N ∈ DTIME(m^N) ∖ DTIME(m^{N/2}) (hierarchy theorem; m^{N/2}·log(m^{N/2}) = o(m^N)). X_N is decided by a program of length c₀ + O(log r), the diagonal construction with N computed from r.
  * *AI side.* The decider p_N of {φ_w : w ∈ X_N} ∪ {¬φ_w : w ∉ X_N} has polynomial membership time (degree about N, uncharged) and length c₀' + O(log r). Every datum is an axiom, so its derivation has size at most |φ_w| + 1 ≤ (|φ_w| + 2)^1. So (p_N, 1) fits all of D^{X_N}, and ℓ_AI(D^{X_N}_n) ≤ c₀' + O(log r) + 3 for all n.
  * *FI side.* If (f, k) fits all of D^{X_N}, then X_N ∈ DTIME(m^{bk}) after a table for small m, so bk > N/2. By the argument of Lemma 1.6, W_{FIcons_poly}(D^{X_N}_n) tends to at most Σ_{k > N/(2b)} 2^(−2⌈log₂(k+1)⌉−1) ≤ b/N, using T(K) ≤ 1/(2K) **[proved; computed: `c4_revision.out`, Part C]**. So ℓ_{FIcons_poly}(D^{X_N}_n) ≥ log₂(N/b) − O(1) = 2^r − O(1) for large n.
  * *Conclusion.* The regret is at least 2^r − O(log r), which is unbounded in r. **[computed: `referee_penalty/r3_degree.out`, with placeholder constants]**
  * So `notes.md`'s "absent if P = NP", read in the domination sense of §1.1, is **[refuted]** for its own definition. What (e2) proves is the per-sequence statement.

(f) `notes.md`'s Cor 4.3(f), on history-free predictors, is replaced by Remark 4.6.

**Remark 4.4 (relation to the paper's results on derivation size).**
* **Theorem 4.2(a) is the general form of `thm:time:ntime`.** An axiom set with polynomial membership that proves the data within symbol size d is a certificate system for its assigner. Theorem 4.2(b) shows that the bound is attained up to polynomials: what the derivation-size charge prices is the assigner's **nondeterministic** time.
  * This sharpens `rem:time:upper`, whose collapse constructions (A^C_f, the two-sorted A_f) pay the deterministic time.
  * It answers model §10 problem 13, and the open problem in the paper's discussion ("whether a symbol-size penalty makes axiom induction equal, up to polynomial factors, to function induction over assigners with short certificates"), **affirmatively, in the hard-cutoff, labelled-data form**: AI[poly, d] ≡ FIcert[poly, Õ(d)] up to constant description length. It is a form of the Cook–Reckhow correspondence (RP-m19).
* **Not shown.**
  * (i) **[open]** The same for soft penalties, as in L1^σ or the graded score, with weights 2^(−κ·size) per datum. The maps change the per-datum size by an additive O(|φ_i|) and a log factor, so the constants no longer telescope.
  * (ii) **[open]** The matching upper bound for *finite DT° template theories* (`cor:time:hard`, `prop:time:sigma`). The certificate sets A_V *need not* be finite unions of DT° templates (RP-m20; `notes.md` said "are not", without proof). Whether some equivalent set is relates to model §10 problem 15.
* **The diagonal sequence under charged deduction.** The derivations of s_n from H_0 obtained from the computation have size at least the length of e's computation on n, which is at least n. That is exponential in |s_n| = O(log n + |e|). **[open]** Whether H_0, or any single hypothesis, proves all s_n within budgets polynomial in the sentence length, through shorter proofs, is not settled here. `notes.md` said "H_0 no longer wins"; that is not proved (RL-m4). In general AI[t, d] has bounded loss on a sequence only if a single hypothesis proves all of its data within d (Lemma 1.6).

**Remark 4.5 (relation to `conj:time:polytime`).** The conjecture concerns the generative likelihood L2 on positive data with a growing depth budget, not labelled data, so these results neither prove nor refute it. In the labelled analogue (RL-m17):
* (i) **[proved]** *Constant regret is trivial for a mixture.* AI[poly, poly]'s loss is at most −log₂ of the weight of any hypothesis compatible with all the data, in the semimeasure convention. The content of Hänni's theorem for S is that his mixture runs in bounded time.
* (ii) *An obstacle to a time-bounded version.* The consistency filter of AI is co-r.e., and AI's predictions are incomputable (Corollary 3.3(c)). `notes.md` named a second obstacle, an "NP ∩ coNP barrier for history-free predictors". It is withdrawn (Remark 4.6).
* (iii) **[open]** Does S_p have bounded regret against AI[poly, d] on language sequences? S_p uses the history, and its time is polynomial in n, which can be exponential in the sentence length there. The arguments here do not reach it.
* `conj:time:polytime` therefore stays a conjecture. Its comparison class, transferred to labelled data, would be certificate function induction (Theorem 4.2), not deterministic time-bounded function induction.

**Remark 4.6 (history-free predictors; `notes.md`'s Cor 4.3(f)) [proved].** `notes.md` claimed, conditional on NP ∩ coNP ≠ P, that no history-free predictor with rational outputs computable in polynomial time has bounded regret against AI[poly, poly] on every consistent labelled sequence. It drew an "NP ∩ coNP barrier" from this. RP showed that the claim holds unconditionally, by the time hierarchy theorem (RP-M3). It holds for a simpler reason, for every history-free predictor, with no bound on its complexity:
* *Two sequences.* Let D^∅ and D^all be the language sequences of X = ∅ and X = {0,1}*: the same sentences φ_w, all labelled 0, respectively all labelled 1. Both labellings are consistent.
* *The inductors win on both.* AI[poly, poly] (either definition), AI, FIcons and FIcons_poly have bounded loss on both sequences. The deciders of {¬φ_w : w} and {φ_w : w} run in polynomial time, every datum is an axiom, and the constant assigners are cheap.
* *A history-free predictor cannot.* It gives the same pair (q_0(φ_w), q_1(φ_w)) on both sequences. Since q_0 + q_1 ≤ 1, q_0·q_1 ≤ 1/4, so −log₂ q_0 − log₂ q_1 ≥ 2. Summing over the first n words, ℓ(D^∅_n) + ℓ(D^all_n) ≥ 2n. So on one of the two sequences its loss is at least n. **[computed: `c4_revision.out`, Part B]**

So the statement says nothing about NP ∩ coNP, derivability or time: a history-free predictor cannot learn at all. The same argument defeats RP's budget-matched replacement for history-free predictors, since the two constant deciders lie in AI[m^{i_0}, m^{j_0}] for small fixed i_0, j_0. **[refuted: the "NP ∩ coNP barrier" of `notes.md` Rem 4.5(ii) and of its H-c row]** The informative question concerns predictors that use the history, such as S (Remark 4.5(iii)).

---

## 5. Disguised assigners inside AI (H-d)

**Proposition 5.1 (axiom-side penalties move the posterior over theories by at most a constant factor) [proved under (S); (b) given Proposition 2.4(b1)].**

(a) Let X be AI^chk_t, or AI^gen_t in any form, with t ≥ m^{a*}. For a class Θ of deductively closed theories, let W(Θ, D) be the weight of the compatible hypotheses p with Cn(B ∪ A_p) ∈ Θ. There is a constant c such that for every Θ and every D,
  2^(−c)·W_AI(Θ, D) ≤ W_X(Θ, D) ≤ 2^c·W_AI(Θ, D).
* Hence W_X(Θ, D) = 0 iff W_AI(Θ, D) = 0.
* If W_AI(Θ, D) > 0, then 2^(−2c) ≤ π_X(Θ | D)/π_AI(Θ | D) ≤ 2^{2c}, with π(Θ | D) := W(Θ, D)/W(D). The ratio is undefined when W_AI(Θ, D) = 0 (RL-m9).
* Posterior odds between two classes of theories with positive weight, "genuine" and "disguised" alike, differ between X and AI by a factor of at most 2^{2c}.

(b) The same holds for AI^cont_t, with t the fixed polynomial of Proposition 2.4(b2), in the two-sorted setting of Proposition 2.4(b) (B = B_A ∪ B_L, B_A true in ℕ, no mixed-sort axioms). Theories are compared on the L-sort: Θ is a class of sets of L-sentences, and W(Θ, D) counts the compatible hypotheses p with Cn(B ∪ A_p) ∩ Sent_L ∈ Θ.

*Proof.*
* (a), lower bound. Every AI hypothesis p semi-decides A_p, via q_p := "yes iff p accepts". Lemma 2.1 gives d_{q_p} (respectively e_{q_p}) with Cn(B ∪ Pad(q_p)) = Cn(B ∪ A_p), of length at most |p| + c, which meets P1a (respectively each form of P2). Compatibility depends only on the theory, so it is preserved.
* (a), upper bound. For AI^chk_t, W_X(Θ, D) ≤ W_AI(Θ, D): same hypotheses, same weights. For AI^gen_t, map g to d_{q_g} with q_g := "yes iff g writes the input". By Lemma 2.1 this preserves the theory and adds at most c to the length.
* (a), the ratios. Divide, using W(D) = W(all theories, D).
* (b), lower bound. For a compatible AI hypothesis p, let f_p be the proof-search assigner of B ∪ A_p.
  * Γ_{f_p} ⊆ Cn(B ∪ A_p), so B_L ∪ Γ_{f_p} is consistent, and Cn(B_L ∪ Γ_{f_p}) ∩ Sent_L = Cn(B ∪ A_p) ∩ Sent_L.
  * By Proposition 2.4(b1), B ∪ A_{f_p} is consistent and has the same L-sentences as theorems.
  * So G_{f_p} is compatible, it represents the same L-theory, and |G_{f_p}| ≤ |p| + c.
* (b), upper bound. Map G to d_{q_G}, with q_G := "yes iff χ ∈ G(φ) for some φ", which semi-decides A_G. Then Cn(B ∪ Pad(q_G)) = Cn(B ∪ A_G), the hypothesis is compatible, and its length is at most |G| + c. Proposition 2.4(b3) is the same idea at the level of FI. ∎

*One sort.* No analogue of (b) is claimed for one sort, even for assigners consistent with Th(ℕ) (RL-m9; `notes.md`'s H-d row claimed one). Proposition 2.4(c) shows that B ∪ A_f is consistent. It does not show Cn(B ∪ A_f) = Cn(B ∪ Γ_f), so the map need not preserve the theory.

So, under P1a, P2 and two-sorted P3 with a true arithmetic background, a slow consistent assigner f keeps prior weight 2^(−|f|−c), and its posterior share stays within a constant factor of its unpenalised share. This holds whether it appears as a padded Craig set (its computation in the axioms' length) or as Hänni's schema (its computation in the proofs of Acc_f(⌜φ⌝)). Under these penalties the posterior does not come to prefer genuine axiom systems.

**Remark 5.2 (counterpoint: decidable logics) [proof sketch].**
* *Setting.* Let L be monadic: one unary predicate R, constants c_w for words w, equality, and no function symbols. Let B = ∅ and φ_w := R(c_w). First-order validity in this class is decidable [known: Löwenheim 1915; the satisfiability problem is NEXPTIME-complete, Lewis 1980 (not checked)].
* *A decision procedure.* An AI^cont_t hypothesis compatible with every datum of D^X yields a deterministic decision procedure for X: compute G(φ_w) in time O(t(|φ_w|)), then decide whether G(φ_w) ⊢ ±φ_w by checking all models up to the size bound of the monadic class. That takes time at most 2^{2^{O(t(λ(m)))}}.
* *Consequence.* By the time hierarchy theorem, for X ∉ DTIME(2^{2^{c·t(λ(m))}}) with c large enough, AI^cont_t has unbounded loss on D^X. FIcons has the constant-size f_X there, and so do AI^chk_t and AI^gen_t (Theorem 2.2), and FIcons_τ once τ is large enough to compute X.
* So the conclusion of Theorem 3.1 fails for X = AI^cont_t in this logic, against Y = FIcons_τ (RL-M1(2)). When deduction cannot carry an arbitrary computation, a *content-relative* axiom-side penalty does separate axiom systems from disguised assigners.
* *Not written out:* the exact model-size bound for the monadic class with equality and constants, and the cost of the model search.
* P1 and P2 remain vacuous there: Lemma 2.1 needs only ∧.

**Remark 5.3 (one sort, assigners inconsistent with true arithmetic) [open].** This is Proposition 2.4(d).
* P3 bites on Craig-type hypotheses (Proposition 2.4(a)).
* For the bounded schema A^bd_f, every axiom set that proves φ contains an axiom whose numeral has about log₂ w_f(φ) symbols, under the side condition of Proposition 2.5(c). This is not shown to make P3 bite on A^bd-type hypotheses (RL-m2).
* Whether every content-relative-cheap encoding must carry the computation is open.

**Remark 5.4 (what does discriminate).** The following are known to price a disguised assigner:
* derivation size in written symbols: `thm:time:ntime`, `cor:time:hard`, `prop:time:sigma`, and Theorem 4.2 here, where the price is exactly nondeterministic time up to polynomials;
* the grammar code length of plain L1, logarithmically (`cor:time:log`);
* restriction to finite DT° template theories, which blocks Hänni's schema (`prop:time:notemplate`) but not a reflection sentence for Σ_n-sound assigners (`prop:time:collapse`).

Among the axiom-side measures defined here (§1.3):
* P1a, P2 (every form) and, up to the log charge, P1b are vacuous at the level of theories (Theorem 2.2, Proposition 2.3, Proposition 5.1).
* P3 prices Craig-type hypotheses in arithmetic (Proposition 2.4(a)). In a decidable logic it prices every hypothesis (Remark 5.2). It can price the genuine axioms of PA while leaving Hänni's schema free (Remark 5.5).
* P3 is vacuous through Hänni's schema with a true arithmetic background (Proposition 2.4(b), (c)). Its one-sorted status otherwise is open.

**[refuted: `notes.md` Rem 5.4, "Among axiom-side measures, only content-relative ones (P3), and only in logics too weak to carry computations, price it"]** Proposition 2.4(a) and Remark 5.5 price in arithmetic. Also, the "only" ranged over four measures, not over all axiom-side measures (RL-m2, RP-m15).

**Remark 5.5 (P3 can exclude the genuine axioms of PA and admit the disguised schema) [proof sketch; RP-m16].**
* *Setting.* One sort, B = Q, binary numerals. The data are (Con(IΣ_n), 1) for n = 1, 2, …, where Con(IΣ_n) is a fixed formula Con_{IΣ}(x) with x := bin(n). So each datum has size O(log n). Each is a PA-theorem [known: PA ⊢ Con(IΣ_n) for each n; Hájek and Pudlák 1993, Ch. I (not checked)].
* *The genuine representation fails.* Let G be an AI^cont_t hypothesis, t polynomial, all of whose axioms are PA axioms (Q1–Q7 and induction instances).
  * G(φ_n) has total size O(t(c·log n)), which is below n for large n.
  * An axiom of size below n is a Q axiom or an induction instance for a formula with fewer than n quantifiers. Such a formula is logically equivalent to a Σ_n formula, so the instance is provable in IΣ_n.
  * So Q ∪ G(φ_n) ⊆ Cn(IΣ_n), which does not contain Con(IΣ_n) (Gödel II).
  * Hence every such G fails on some datum, and AI^cont_t restricted to PA's own axioms has unbounded loss.
* *The disguised representation fits.* Let f be PA-proof search, and G_f(φ) := Q ∪ {Acc_f(⌜φ⌝) → φ, Rej_f(⌜φ⌝) → ¬φ}.
  * f is sound, so Th(ℕ) ∪ Γ_f is consistent, and Proposition 2.4(c) applies.
  * G_f runs in polynomial time and is compatible with every datum.
* *Not written out:* the exact formalisation of Con(IΣ_n) with a binary numeral for n.
* *Consequence.* At the level of representations, P3 can price genuine axiom systems while leaving the disguised ones free.

**Remark 5.6 (P2-strict at the level of representations) [proved from Proposition 2.7; the delay-form enumeration of template instances is a proof sketch].**
* With polynomial t, P2-strict admits no template theory with a formula metavariable: not PA's induction schema, and no DT° template with such a metavariable. It admits every padded set Pad(q).
* At the level of theories it is vacuous (Theorem 2.2, Proposition 5.1). At the level of representations it removes the genuine schemas and keeps the disguised ones (RP-M1).
* The delay form, the default, admits template theories. Enumerate the bodies by size; each body gives a distinct instance, written with delay polynomial in its length. Not written out: the polynomial-delay enumeration of bodies in size order.

---

## 6. Checks

All scripts are deterministic or seeded and write `<name>.out` next to themselves. In this revision, c1–c3 were rerun after their docstrings were updated to the current numbering (RL-m15, RP-m18). Their outputs are byte-identical to the committed ones. Both referees' scripts were rerun from scratch copies, and their outputs are byte-identical too.

| script | what it checks | result |
|---|---|---|
| `checks/c1_diagonal.py` → `.out` (seed 4242) | Thm 3.2(a), (c): the diagonal against 8 computable predictors, in exact, random and adversarial approximation modes, N = 2000; from-scratch recomputation of D(n), n ≤ 150; tail sum Σ log₂(1 + 2^(−j−1)) | `notes.md`'s bound holds everywhere; min(ℓ_n − n) = −0.313 (also within the sharpened bound −0.361); D(n) consistent; tail sum 0.6686 |
| `checks/c2_padding.py` → `.out` (seed 777) | Lemma 2.1, Rem 2.6: padded and unpadded Craig sets for 5 toy assigners under a cost model; decider and enumerator correctness; P1 and P2 ratios. The `dec/\|chi\|` column is computed from the cost model; the decider is run in the 30-query `rerun` check | P1 ≤ 1.15·\|χ\|; work padding: completion ≤ 1.14·cumulative length and ≤ 0.016·\|a_i\|²; elapsed-time padding ≤ 1.14·\|a_i\|; unpadded: completion/\|a_i\| up to 1.1·10⁴, completion/cumulative up to 10.0 |
| `checks/c3_certificate.py` → `.out` (seed 31337) | Thm 4.2(b) in an infix syntax: certificate axioms for a toy NP ∩ coNP language; unique parsing; decider correctness against tampering; length and work bounds; contrast with Craig for trial division | all pass; \|χ\|/\|φ\| ≈ 19–21.5; decider work ≤ 2.1·10⁻⁵·\|χ\|³; trial-division Craig axioms up to ≈ 6.6·10¹⁰ symbols at \|φ\| = 63 |
| `checks/c4_revision.py` → `.out` (new; Part B seed 2026) | (A) Thm 3.2(c), sharpened bound, 8 predictors × 3 modes, N = 2000, including a sharp adversary; (B) Rem 4.6: history-free predictors on D^∅ and D^all (5 kinds × 200 predictors × 500 words); (C) Cor 4.3(e4): 1/(8(K+1)) ≤ T(K) ≤ 1/(2K) | (A) all hold; the sharp adversary is within 1.6·10⁻¹⁰ of the bound (ℓ_n − n = −0.3466); (B) ℓ_0 + ℓ_1 ≥ 2n and max ≥ n in every case (minimum ratios 2.73 and 1.40); (C) holds for K from 1 to 10¹² |
| `referee_logic/r1_quine_diagonal.py` (RL) | Thm 3.2 with e a genuine quine; 5 predictors that read the sentences, one a budgeted self-evaluator; 2 modes | fixed point, history and sentences consistent; bounds hold; near-1/2 adversary at −0.343 |
| `referee_logic/r2_q_models.py` (RL) | Lemma 1.4(d) and the ≤-dichotomy in both orientations; a false Σ₁ sentence and its bounded form; 576 nonstandard Q-structures | bounded lemma and left dichotomy in all; right dichotomy fails in 288; false Σ₁ true in 432; bounded form true in none |
| `referee_logic/r3_enum_parse_derive.py` (RL, seed 2718) | Rem 2.6 (generic and specialised enumerators); Prop 2.7 (counting); Thm 4.2(b) primitive-syntax parsing; a K-derivation of (B ∧ C) → B | generic ratio 7.7·10⁶ at s = 2^18, specialised ≤ 1.22; counts exceed C·L^p; parsing unique with \|θ_c\| ≤ 10\|c\| + 11; derivation checks, size 3725\|B\| + 1559\|C\| + const |
| `referee_penalty/r1_kt_prior.py` (RP) | Prop 2.3, Rem 2.3a: W_{AI^Kt}(∅) can exceed 1; the uncapped t(\|χ\| + \|p\|) variant diverges; Kt charge against the floor | family weight 3.45; partial sums 6563 at 10⁵ groups (a* = 3), capped 0.0625; Lemma 2.1(b)'s accounting 0–0.8 bits above the floor |
| `referee_penalty/r2_enumeration.py` (RP) | Prop 2.7 (counting); Lemma 2.1(c) delay; Rem 2.6 cumulative example | Craig set of a fast f and a one-metavariable template exceed every tested C·L^{a*}, Pad(q) never; delay/\|a_i\| ≤ 1.14 padded, up to 1437 unpadded; dovetail ratio 1.0·10⁸ at j = 20, wrapper 1.10 |
| `referee_penalty/r3_degree.py` (RP) | Cor 4.3(e4): FIcons_poly weight of clock exponents ≥ K; regret lower bound on D^{X_N} | −log₂ T(K) = log₂(K + 1) + 2 − o(1); regret bound grows like 2^r (placeholder constants) |
| `referee_penalty/repro/` (RP) | c1, c2, c3 rerun by RP | byte-identical |

The scripts check constructions and arithmetic. The theorems are logical and asymptotic, and are proved in the text.

---

## 7. Open problems

1. **P3 in one sort for consistent assigners inconsistent with Th(ℕ)** (Proposition 2.4(d), Remark 5.3), and in two sorts with an arithmetic background false in ℕ (Proposition 2.4(b4)). Is there a content-relative-cheap encoding, or must the axiom needed for φ carry the computation?
2. **Search versus decision for Craig sets** (Remark 2.6). Does some f have a Craig set A^C_f with no cheap delay or cumulative enumerator of length |f| + O(1)?
3. **AI^Kt_t against FIcons_τ** (Theorem 3.1): is the regret uniformly bounded?
4. **Soft derivation penalties.** Theorem 4.2 for weights 2^(−κ·size) per datum (L1^σ, the graded score), and for finite DT° template theories (Remark 4.4).
5. **The intermediate complexity case, and uniform domination,** at polynomial budgets (Corollary 4.3(e3)).
6. **History-using time-bounded predictors** (Hänni's S) against AI[poly, d] on language sequences (Remark 4.5(iii)). Remark 4.6 shows that history-free predictors are the wrong class.
7. **A computable consistency filter.** Replace "B ∪ A_p consistent" by "no refutation of a datum within the budget", and ask what survives of Theorems 3.1 and 4.2 and of `prop:time:fiall`.
8. **Rates.** On hierarchy sequences (Corollary 4.3(d)), only ℓ_{FIcons_τ} → ∞ is shown. A linear rate needs a diagonal against a mixture that is computable within slightly more than τ.
9. **The diagonal sentences under charged deduction** (Remark 4.4): does a single hypothesis prove all s_n within budgets polynomial in |s_n|?
10. **Machine dependence** (Remark 2.2a): (S_lin) for a concrete U, and the vacuity of P1a and P2 for every t ≥ linear.

---

## 8. Status of every claim

| claim | status |
|---|---|
| (S), (S_lin), the overhead q of Convention 1.5 | assumptions (standard; not checked for a particular machine) |
| Lemma 1.4(a) | known (MRDP; not checked) |
| Lemma 1.4(b)–(d) | proved; (d) computed (`r2`) |
| Lemma 1.6 | proved |
| Lemma 2.1 | proved under (S); computed (`c2`; `r2` Part B) |
| Thm 2.2 | proved under (S), for every t ≥ m^{a*}, all three forms of P2 |
| Rem 2.2a (slower t) | proof sketch, under (S_lin) |
| Prop 2.3 (i)–(iii) | proved under (S); computed (`r1_kt` Part C) |
| `notes.md` Prop 2.3(ii)'s use of W_{AI^Kt}(∅) ≤ 1 | refuted (`r1_kt` Part A) |
| Rem 2.3a | uncapped variant: refuted (improper; proof, `r1_kt` Part B); capped variant: proved |
| Prop 2.4(a) | proved, given the deterministic time hierarchy theorem (known) |
| Prop 2.4(b1)–(b3) | proved (Σ₁-completeness of Q known) |
| Prop 2.4(b4): `notes.md`'s (b) for B ⊇ Q | refuted (counterexample; assumes Con(PA) and the standard formalisation) |
| Prop 2.4(c) | proved |
| Prop 2.4(d) | open; "Hänni's schema is then inconsistent" refuted (consistent example, given the standard formalisation) |
| Prop 2.5 | proved, given MRDP (known); computed (`r2`) |
| Rem 2.6 | per-axiom reading proved; "the generic enumerator of A^C_f is cheap" refuted (proved; computed `r2` C, `r3` A); strict form: no enumerator (Prop 2.7); specialised enumerator: proof sketch, computed; the set-level question: open |
| Prop 2.7 | proved; computed (`r2` A, `r3` B) |
| Thm 3.1 | proved (under (S) for the penalised AI variants); for P1b relative to weights 2^(−\|g\|)/(\|g\|+1); for P3 in two sorts with B_A true |
| `notes.md` Thm 3.1 hypothesis Γ_{g_h} = Γ_h | refuted as sufficient (counterexample) |
| Thm 3.2 | proved, given the recursion theorem and MRDP (known); computed (`c1`, `c4` A, `r1`) |
| Cor 3.3 (a)–(c) | proved |
| Prop 3.4 | proved (does not use Hänni's regret theorem) |
| `notes.md` §0.1 "strictly stronger than every time-bounded function inductor" | refuted (S, FIall_τ; Prop 3.4) |
| Rem 3.5 | bullets 1–2 proved; "cannot be repaired without a running-time bound": conjecture; Rosser form: proof sketch |
| Prop 4.1 (a), (b) | proved |
| Prop 4.1 (c) | proof sketch (rests on Hänni's construction and theorem) |
| Thm 4.2 | proved, given the propositional derivation fact (known); computed (`c3`; `r3` C, D) |
| Cor 4.3 (a) | proved under (S) |
| Cor 4.3 (b) | proved, per hypothesis (p-dependent constants); `notes.md`'s uniform 2^c withdrawn |
| Cor 4.3 (c) | proved |
| Cor 4.3 (d) | proved, given the deterministic time hierarchy theorem |
| Cor 4.3 (e1) | proved, conditional on NP ∩ coNP ≠ P |
| Cor 4.3 (e2) | proved, conditional on P = NP |
| Cor 4.3 (e3) | open |
| Cor 4.3 (e4) | proved, given the deterministic time hierarchy theorem; computed (`r3_degree`, `c4` C) |
| `notes.md` "absent if P = NP" in the domination sense | refuted for its own definition (Cor 4.3(e4)) |
| Rem 4.4 | soft penalties: open; DT° upper bound: open; the diagonal under charged deduction: open |
| Rem 4.5 | (i) proved; (ii) by Cor 3.3(c); (iii) open; `conj:time:polytime` remains a conjecture |
| Rem 4.6 (`notes.md` Cor 4.3(f)) | proved unconditionally, for every history-free predictor; computed (`c4` B); the conditional status and the "NP ∩ coNP barrier": refuted |
| Prop 5.1 (a) | proved under (S) |
| Prop 5.1 (b) | proved, given Prop 2.4(b1) |
| Rem 5.2 | proof sketch |
| Rem 5.3 | open |
| Rem 5.4 | summary of the above; `notes.md`'s "only content-relative ones, only in weak logics": refuted |
| Rem 5.5 | proof sketch |
| Rem 5.6 | proved from Prop 2.7; the delay-form enumeration of templates: proof sketch |

---

## 9. References

* W. Craig, "On axiomatizability within a system", *J. Symbolic Logic* 18 (1953) 30–32 [known].
* S. C. Kleene, the second recursion theorem; H. Rogers, *Theory of Recursive Functions and Effective Computability*, 1967, §11.2 [known (section not checked)].
* Y. Matiyasevich, "Enumerable sets are Diophantine", *Soviet Math. Doklady* 11 (1970) 354–358; M. Davis, "Hilbert's tenth problem is unsolvable", *Amer. Math. Monthly* 80 (1973) 233–269 [known (not checked)].
* J. Hartmanis, R. Stearns, "On the computational complexity of algorithms", *Trans. AMS* 117 (1965); F. Hennie, R. Stearns, "Two-tape simulation of multitape Turing machines", *JACM* 13 (1966) [known (exact form of the hierarchy theorem not checked)].
* S. Cook (STOC 1972; *JCSS* 7, 1973); J. Seiferas, M. Fischer, A. Meyer, *JACM* 25 (1978); S. Žák, *TCS* 26 (1983): the nondeterministic time hierarchy, as cited in the paper [known (not checked)].
* S. Cook, R. Reckhow, "The relative efficiency of propositional proof systems", *J. Symbolic Logic* 44 (1979) 36–50 [known; bibliographic data confirmed by RP].
* D. S. Johnson, M. Yannakakis, C. H. Papadimitriou, "On generating all maximal independent sets", *Inform. Process. Lett.* 27 (1988) 119–123: polynomial delay [known; bibliographic data confirmed by RP].
* L. Levin, "Universal sequential search problems", *Problems Inform. Transmission* 9 (1973) 265–266: Kt [known (not checked)]; M. Li, P. Vitányi, *An Introduction to Kolmogorov Complexity and Its Applications*, 3rd ed., 2008 [known].
* J. Schmidhuber, "The Speed Prior: a new simplicity measure yielding near-optimal computable predictions", COLT 2002, LNAI 2375 [known (not checked)].
* S. Legg, "Is there an elegant universal theory of prediction?", ALT 2006, LNCS 4264, 274–287: every computable predictor fails on some computable sequence [known; bibliographic data confirmed by RP]. Theorem 3.2 is a log-loss, labelled-sentence version with approximate outputs and a predictor-independent axiom hypothesis.
* P. Smith, *An Introduction to Gödel's Theorems*, 2nd ed., 2013: Robinson's Q, its Σ₁-completeness, the properties of ≤ [known (numbering not checked)].
* P. Hájek, P. Pudlák, *Metamathematics of First-Order Arithmetic*, 1993: formalised computations; PA ⊢ Con(IΣ_n) [known (not checked)].
* E. Mendelson, *Introduction to Mathematical Logic*: the calculus K [known].
* L. Löwenheim, *Math. Ann.* 76 (1915); H. Lewis, "Complexity results for classes of quantificational formulas", *JCSS* 21 (1980): monadic logic [known (not checked)].
* K. Hänni, `../../prior/hanni-solomonoff-axiom-induction.md` and `../../prior/hanni-polytime-solomonoff.md` (working notes).

---

## 10. Verification log

All checks were done in this track, in two sessions. The first produced `notes.md`; the second, after the two referee reports, produced this file. Nothing is checked in a proof assistant. No git command that changes repository state was run.

### 10.1 Logic referee (`referee-logic.md`): issues and resolutions

| issue | referee's point | resolution | where |
|---|---|---|---|
| **M1** | §0.1 overstates three results: (1) "strictly stronger than every time-bounded function inductor" contradicts Prop 3.4; (2) Thm 3.1 does not cover P1b, one-sorted P3, or monadic P3; (3) the constant equivalence holds only for P1a and P2 | **Accepted.** (1) kept as **refuted**, with S and FIall_τ as counterexamples; the true statement is about consistent time-penalised FI. (2) Thm 3.1 restated in general form, with its instances listed. AI^Kt_t is covered relative to weights 2^(−\|g\|)/(\|g\|+1), and against FIcons_τ it is open. One-sorted P3 is not covered. Monadic P3 makes the conclusion fail (Rem 5.2). (3) scoped: constant for P1a and P2, a log charge for P1b, P3 by case. The H-b and H-e rows and §11 rewritten | §0, Thm 3.1, Prop 3.4, Rem 5.2, §11 |
| **M2** | Prop 2.4(b) false for "B ⊇ Q on the arithmetic sort"; counterexample with B ⊇ PA + ¬Con(PA) | **Accepted.** Counterexample checked and kept as (b4), **refuted**. Restated for B = B_A ∪ B_L with Q ⊆ B_A ⊆ Th(ℕ), B_L pure L-sort, no mixed axioms; (b1) generalises `prop:time:twosorted` and is proved. Carried into Thm 3.1, Prop 5.1(b) and the H-a, H-d rows. Whether another map works for false B_A: open | Prop 2.4(b), Thm 3.1, Prop 5.1(b) |
| m1 | Rem 2.6: strict form, no enumerator (counting); cumulative form, only the generic wrapper fails; "which has to dovetail" is false | **Accepted.** New Prop 2.7 (counting, proved). Rem 2.6 distinguishes the per-axiom reading (correct), the strict form (no enumerator), and the generic enumerator (refuted as cheap; proved for f_pow2) from the set (a cheap specialised enumerator, proof sketch; the general set-level question open) | Rem 2.6, Prop 2.7 |
| m2 | Prop 2.4(d) "Hänni's schema is then inconsistent" false in general; "P3 bites on both" not proved for A^bd_f; Rem 5.4 contradicts Prop 2.4(a) | **Accepted.** "Can be inconsistent", with RL's consistent example (f accepts only ¬Con(PA)) proved given the standard formalisation; P3 on A^bd: only the per-axiom bound; Rem 5.4 rewritten and the old sentence marked refuted | Prop 2.4(d), Rems 5.3, 5.4 |
| m3 | Rem 3.5: "works only if P's running time has a known computable bound" is unproved | **Accepted.** Marked as a conjecture, with the heuristic reason stated as such | Rem 3.5 |
| m4 | Rem 4.4: "H_0 no longer wins" not proved | **Accepted.** Now: the derivations obtained from the computation exceed such budgets; whether H_0 or any hypothesis wins is open | Rem 4.4, §7 item 9 |
| m5 | Thm 3.1: Γ_{g_h} = Γ_h does not imply the same labels | **Accepted.** The hypothesis is now "computes the same partial map"; the counterexample is kept | Thm 3.1 |
| m6 | Cor 4.3(b), (d), Prop 2.4(a): exact clocks with no slack | **Accepted.** Overhead q made explicit (Convention 1.5, third property added). (b) stated per hypothesis, with clock m·q(…) and a p-dependent table; (d) with T₁ := m·q(m·τ(λ(m)) + m) and τ₃ ≥ q(C_X·T₂(m) + m); Prop 2.4(a) with q(C_G·t(λ(m)) + m) | Conv 1.5, Prop 2.4(a), Cor 4.3(b), (d) |
| m7 | Cor 3.3(b): direction of regret reversed | **Accepted.** "AI's regret against FIcons_τ is bounded; FIcons_τ's regret against AI is at least n − O(1) on some computable sequence" | Cor 3.3(b) |
| m8 | Prop 2.4(c): which PA? | **Accepted.** B a decidable set of L_A-sentences with Q ⊆ B ⊆ Th(ℕ); with induction for wider formulas, the hypothesis is Th(ℕ) ∪ B ∪ Γ_f consistent | Prop 2.4(c) |
| m9 | Prop 5.1(b): only one direction; the ratio is undefined when W_AI(Θ, D) = 0; the H-d row claims a one-sort case | **Accepted.** Converse written (G ↦ d_{q_G}); W_X(Θ, D) = 0 iff W_AI(Θ, D) = 0, and the ratio is stated only when positive; the one-sort claim removed, with the reason (the theory need not be preserved) | Prop 5.1 |
| m10 | Prop 2.5 framed as answering problem 14 "affirmatively, short of Craig's trick" | **Accepted.** Reframed as "Craig's idea with a binary witness bound, in the form of Hänni's schema" | Prop 2.5 |
| m11 | speed-prior weight undefined at D = ∅ | **Accepted.** 1 + total time; renamed time-weighted FIcons (see RP-m13) | Def 1.2 |
| m12 | "a charge every program pays" loose | **Accepted.** Resolved by sharpening the charge to log₂(\|f\| + 1) + O(1) (Prop 2.3(ii), (iii); RP-m2). The phrase is now accurate up to a constant | Prop 2.3 |
| m13 | "Q ∪ {DET} decides every sentence" | **Accepted.** "Decides every s_n; it is not complete" | Thm 3.2(b), §0 |
| m14 | Thm 3.2 needs only that DET is true; Prop 3.4 does not need Hänni's theorem | **Accepted.** Both: Prop 3.4 is now proved from the structure of S (§1.4(ii)) | Thm 3.2(b), Prop 3.4 |
| m15 | stale numbering in script docstrings; c1 Part B does not exercise the self-reference | **Accepted.** Docstrings updated to Thm 3.2, Lemma 2.1, Thm 4.2(b); c1's docstring names r1 for the self-reference. Outputs rerun: byte-identical | `checks/c1–c3`, §6 |
| m16 | the reference for Δ₀-definability of T and Out is doubtful; Δ₀ is needed for the label-0 case | **Accepted, resolved differently.** Thm 3.2 and Prop 2.5 now use the Diophantine output formula from MRDP (Lemma 1.4(a), known). The label-0 case then needs only that Q proves a true existential equation, and the bounded schema needs only Lemma 1.4(b)–(d), proved here. Δ₀ formulas remain only in the Rosser variant of Rem 3.5, which is a proof sketch and is not used | Lemma 1.4, Thm 3.2, Prop 2.5, Rem 3.5 |
| m17 | "constant regret is trivial for a mixture" is shown only in the labelled analogue | **Accepted.** Said in Rem 4.5 and in the H-c row | Rem 4.5, §0 |
| m18 | Thm 4.2(b): say which syntax the size bound refers to | **Accepted.** K's primitive Polish syntax, \|θ_c\| ≤ 10\|c\| + 11 (r3 Part C); c3's infix syntax gives 12\|c\| + 17 | Thm 4.2(b) |
| obs. | the diagonal bound can be sharpened to n − 1/(4 ln 2) | **Adopted**, with a tightness check (c4 Part A) | Thm 3.2(c) |

### 10.2 Penalty referee (`referee-penalty.md`): issues and resolutions

| issue | referee's point | resolution | where |
|---|---|---|---|
| **M1** | P2-strict is a sparsity condition: it excludes every schema and admits the padded sets | **Accepted.** Proved as Prop 2.7. The delay form (polynomial delay) is added and made the default; Lemma 2.1(c) proves the delay bound for Pad(q); Thm 2.2(b) covers all three forms. The consequence for representations is Rem 5.6, and H-d is qualified | Def 1.1, Lemma 2.1(c), Prop 2.7, Rem 5.6 |
| **M2** | "A^C_f is not cheap to enumerate [proved]" holds only for the dovetailing enumerator; false as a property of the set for the notes' cumulative example | **Accepted** (with RL-m1). Restated for the generic enumerator, refuted as cheap for f_pow2 (proved). The set has a cheap specialised enumerator (proof sketch, computed). The paper's justification is called incomplete for the enumeration reading, and its conclusion is proved by Lemma 2.1 | Rem 2.6 |
| **M3** | Cor 4.3(f) holds unconditionally, by the time hierarchy, so the "NP ∩ coNP barrier" is misattributed | **Accepted and strengthened.** (f) holds for *every* history-free predictor, with no complexity bound, by the two constant-label sequences (Rem 4.6, proved; c4 Part B). RP's budget-matched replacement is vacuous for history-free predictors for the same reason. The barrier claim is marked refuted, and Rem 4.5(ii) and the H-c row are rewritten. The informative question (history-using predictors) is open problem 6 | Rem 4.6, Rem 4.5, §0, §7 |
| **M4** | at polynomial budgets AI[poly, poly] does not charge its membership degree; FIcons_poly fails to dominate it unconditionally; "absent if P = NP" holds only per sequence | **Accepted.** AI[poly, poly] redefined with a membership clock (\|χ\| + 2)^i and a degree charge (Cor 4.3(e)). (e1) and (e2) proved in the per-sequence form (Lemma 1.6). (e4) is RP's non-domination for the uncharged definition, proved with explicit slack (X_N ∉ DTIME(m^{N/2}), T(K) ≤ 1/(2K)). (e3): uniform domination open even under P = NP. §0 and §11 say "per sequence" | Cor 4.3(e), Lemma 1.6 |
| **M5** | the headline "strictly stronger than every time-bounded function inductor" contradicts Prop 3.4 | **Accepted** (= RL-M1(1)) | Prop 3.4, §0, §11 |
| m1 | Prop 2.3(ii) uses W_{AI^Kt}(∅) ≤ 1, which is false; the bound is t(m_0) | **Accepted.** Prop 2.3(i) proves W(∅) ≤ t(m_0); Thm 3.2(d) and Cor 3.3(c) carry Ω = t(m_0); the old use is marked refuted | Prop 2.3, Thm 3.2(d) |
| m2 | the Kt charge is log₂\|f\| + O(1); AI^Kt_t ≡ FIcons with weights 2^(−\|f\|)/\|f\| (proof sketch) | **Accepted, proved under (S).** (S) now includes the cost of reading q. Lemma 2.1(b) gives the additive bound α(\|q\| + 1) + α'(\|χ\| + 1)^{a'} (the early exit is the rejection when m − 1 < \|q\|). Prop 2.3(ii), (iii) prove both directions | Lemma 2.1(b), Prop 2.3 |
| m3 | measuring against t(\|χ\| + \|p\|) gives an improper prior | **Accepted.** Uncapped: refuted, with a proof (divergent family). Capped: proved vacuous up to a constant | Rem 2.3a |
| m4 | Thm 2.2 is stated only for t = m^{a*}; the vacuity holds for every t ≥ linear | **Accepted in part.** Thm 2.2 is proved for every t ≥ m^{a*}. Below that, a proof sketch under (S_lin), with the missing steps named; a* reflects U's self-simulation overhead | Thm 2.2, Rem 2.2a |
| m5 | = RL-m5 | **Accepted** | Thm 3.1 |
| m6 | Cor 4.3(b), (e): the O(log \|p\|) weight overhead is omitted | **Accepted.** (b) per hypothesis, with p-dependent constants, no uniform 2^c; (e) uses E-coded strings on both sides, so both pay alike | Cor 4.3(b), (e) |
| m7 | Thm 4.2(a): the bit bound β·s·log s assumes finitely many symbols | **Accepted.** L finite in Def 1.3 | Def 1.3 |
| m8 | re-indexing between \|w\| and \|φ_w\| | **Accepted.** λ and q in Convention 1.5; Prop 2.4(a) and Cor 4.3(c), (d) use them | Conv 1.5 |
| m9 | wording: "every sentence"; Cor 3.3(b) direction; "d exceeds τ by a polynomial factor" | **Accepted.** All three corrected | Thm 3.2(b), Cor 3.3(b), Cor 4.3(d) |
| m10 | H-a "AI_pen ≡ unpenalised FIcons" is open for one-sorted P3; the upper inequality for P3 is not written | **Accepted.** H-a scoped; (b3) proves the upper inequality in any setting | Prop 2.4(b3), §0 |
| m11 | = RL-M2 | **Accepted** | Prop 2.4(b) |
| m12 | Σ₁- and Δ₀-completeness in L_A need <-free formulas | **Accepted.** The Diophantine formulas have no bounded quantifiers; where bounded quantifiers occur (Prop 2.5, Rem 3.5) they are ∃z(z + y = s) | Lemma 1.4, Prop 2.5 |
| m13 | speed-prior weights depend on D, which Thm 3.1 does not allow; it is not Schmidhuber's speed prior, which is uncited | **Accepted.** Thm 3.1 allows D-dependent weights; renamed time-weighted FIcons; Schmidhuber cited | Def 1.2, Thm 3.1, §9 |
| m14 | how S reads labelled sentences; Prop 3.4 does not need Hänni's theorem | **Accepted.** §1.4 fixes the reading and the two properties used; Prop 3.4 proved | Def 1.2, Prop 3.4 |
| m15 | Rem 5.4: "only content-relative, only in weak logics" | **Accepted** (with RL-m2). Rewritten; the old sentence is marked refuted | Rem 5.4 |
| m16 | P3 can exclude the natural representation of PA while admitting Hänni's schema (proof sketch) | **Accepted** as Rem 5.5 (proof sketch, with the missing step named) and added to H-d | Rem 5.5, §0 |
| m17 | prefix-machine detail: hypotheses from a self-delimiting code | **Accepted** | §1.2 |
| m18 | stale docstrings; c2's dec/\|chi\| column is computed from the cost model | **Accepted.** Docstrings updated; c2's docstring and §2 and §6 describe the column; outputs byte-identical | `checks/`, §2, §6 |
| m19 | Thm 4.2 is the Cook–Reckhow correspondence; temper "new"; Prop 2.5's framing | **Accepted** | Thm 4.2, Rem 4.4, Prop 2.5 |
| m20 | Rem 4.4(ii) "are not" should be "need not be" | **Accepted** | Rem 4.4 |

Both referees confirmed every other claim of `notes.md`. Those claims are carried over with the scopes above.

### 10.3 Checks and their results

* `c1_diagonal` (rerun): all bounds of `notes.md`'s Thm 3.2(c) hold for 8 predictors × 3 modes, N = 2000. The minimum of ℓ_n − n is −0.313, which is also within the sharpened bound −0.361. D(n) is consistent for n ≤ 150. The tail sum is 0.6686 ≤ 0.7213. Output byte-identical.
* `c2_padding` (rerun): P1 ≤ 1.15·|χ| in every row. Work padding: completion ≤ 1.14·cumulative length and ≤ 0.016·|a_i|². Elapsed-time padding: completion ≤ 1.14·|a_i|. Unpadded: completion/|a_i| up to 1.1·10⁴, completion/cumulative up to 10.0. Decider correctness and the from-scratch reruns pass. Output byte-identical.
* `c3_certificate` (rerun): parsing unique on 3000 cases; the decider is correct against tampering; the length bounds hold on 210 cases; work ≤ |χ|³. Output byte-identical.
* `c4_revision` (new): (A) the sharpened diagonal bound holds in 24 runs, and the sharp adversary is within 1.6·10⁻¹⁰ of it; (B) ℓ(D^∅_n) + ℓ(D^all_n) ≥ 2n for 1000 history-free predictors; (C) 1/(8(K+1)) ≤ T(K) ≤ 1/(2K) for K from 1 to 10¹².
* RL's `r1_quine_diagonal`, `r2_q_models`, `r3_enum_parse_derive` and RP's `r1_kt_prior`, `r2_enumeration`, `r3_degree`: rerun from scratch copies, all byte-identical. Their results are in §6 and support Thm 3.2, Lemma 1.4(d), Prop 2.5, Rem 2.6, Prop 2.7, Thm 4.2(b), Prop 2.3, Rem 2.3a, Lemma 2.1(c) and Cor 4.3(e4).

### 10.4 Self-checks that changed this file

1. **Cor 4.3(f) is trivial.** While checking RP-M3, it turned out that history-free predictors fail against the two constant-label sequences, whatever their complexity. This made the conditional statement, and also RP's budget-matched replacement, uninformative (Rem 4.6). Checked numerically in c4 Part B.
2. **The tail constant.** RL's r1 reports −0.3433 for a near-1/2 adversary at 0.99 of the error bound. This lies between the exact infinite sum −0.3466 and −1/(4 ln 2) = −0.3607, so it is consistent. c4 Part A reaches −0.3466 with the factor 1 − 10⁻⁹.
3. **Prop 2.4(b4) refutes a map, not an equivalence.** RL's counterexample shows that f ↦ G_f fails for a false arithmetic background. It does not show that AI^cont_t and FIcons differ there, so that question is recorded as open rather than as refuted.
4. **Lemma 2.1(b) in additive form.** Rejecting candidates with m − 1 < |q| before simulating makes the decider's cost additive in |q|. This proves RP-m2's sharpening, which RP gave as a sketch, from (S) once (S) includes the cost of reading q.
5. **Cor 4.3(b) cannot have a uniform constant** with exact clocks: the asymptotic constant of p's membership time cannot be absorbed at short sentences. It is therefore stated per hypothesis, and used only per sequence.
6. **Prop 5.1 in one sort.** The H-d row of `notes.md` claimed a one-sorted case for assigners consistent with Th(ℕ). The map p ↦ G_{f_p} need not preserve the theory there, so the claim was removed rather than proved.
7. **The f_pow2 bound.** The analytic bound Σ_{s ≤ 2^j}(s − 1 − log₂ s) ≥ 4^j/4 was first stated for j ≥ 4. The crude estimate 4^j/2 − 2^j(1 + j) proves it only for j ≥ 5, so the statement says j ≥ 5. Numerically the sum exceeds 4^j/4 from j = 4 on.

---

## 11. Answer to Hänni's objection

Hänni is right that the sentence was too coarse, and right that the time penalty helps in one sense. The sentence holds for the half it was about. Craig's sets, padded by the enumerator's own work counter, turn every consistent assigner f, however slow, into an axiom set of description length |f| + c whose membership is decidable, and whose members are enumerable, in polynomial time. So a membership-time class penalty or a generation-time penalty (in the strict, polynomial-delay or cumulative form, for reference bounds t ≥ m^{a*} with a* fixed by the machine) leaves axiom induction within a constant of unpenalised consistent function induction on every data sequence (Thm 2.2). A Kt penalty on membership only replaces 2^(−|f|) by 2^(−|f|)/(|f| + 1) (Prop 2.3). His point concerns the other half. With proof search free, the assigner "search for a proof" has no time bound, so once function induction is time-penalised the equivalence becomes one-sided. Axiom induction, unpenalised or with a membership-class or generation penalty, has regret bounded by a constant against every time-penalised consistent deterministic function inductor whose weights are at most a constant times a wrapped program's weight: clocked FIcons_τ, and Kt-capped or time-weighted FIcons (Thm 3.1). Conversely, for every computable predictor (Hänni's polytime S, the clocked FIall_τ, and FIcons_τ through a computable dominating mixture) there is a computable sequence of arithmetic sentences, each decided by Q plus one true Π₁ sentence, on which the predictor loses at least n − 0.37 bits (FIcons_τ: n − 1.37 − c_⊥) while axiom induction loses a constant independent of the predictor (Thm 3.2, Cor 3.3). In that sense the penalty helps: axiom induction becomes strictly stronger than time-penalised consistent function induction. It does not become stronger than time-bounded predictors that may be inconsistent. S and FIall_τ have bounded loss on fair-coin literals labelled true, where axiom induction loses n bits in expectation, so they are incomparable with it (Prop 3.4). Three qualifications follow. First, the advantage is the free deduction, not the axioms: unpenalised consistent function induction has the same advantage through a constant-size evaluator (Prop 4.1). Second, the penalty does not make the posterior prefer genuine axiom systems. Under the membership-class and generation penalties, and under a content-relative penalty in two sorts with an arithmetic background true in ℕ, every slow consistent assigner keeps weight 2^(−|f|−c), and posterior odds between any two classes of theories move by at most a constant factor (Prop 5.1). A content-relative penalty does bite on Craig-type sets (Prop 2.4(a)), and, by proof sketches, in decidable logics and on the genuine axioms of PA (Rems 5.2, 5.5). In one sort it is open for assigners inconsistent with true arithmetic. Third, when deduction is charged too (derivations of at most d symbols, membership in time t), axiom induction becomes equivalent, up to constant description length and polynomial changes of the budgets, to function induction over consistent assigners with certificates of length about d·log d (Thm 4.2). His asymmetry then becomes guessing proofs against computing answers. Axiom induction dominates FIcons_τ once d ≥ γ(τ + 1)(m + 4) (Cor 4.3(a)). It beats FIcons_τ outright on a decidable language sequence when d is a fixed polynomial of a time bound T₂ that outgrows T₁·log T₁, with T₁ a fixed polynomial of τ (Cor 4.3(d), unconditional, given the time hierarchy theorem). At polynomial budgets with degrees charged, there is a sequence on which axiom induction has bounded and FIcons_poly unbounded loss if NP ∩ coNP ≠ P, and there is no such sequence if P = NP (Cor 4.3(e)). Without the degree charge, FIcons_poly fails to dominate axiom induction unconditionally. The intermediate case, and uniform domination at polynomial budgets, are open.
