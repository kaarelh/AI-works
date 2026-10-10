# Referee report on `time-followup/notes.md`: the time-penalty definitions

*Adversarial referee. The focus is the penalty definitions (Defs 1.1–1.3) and the claims that rest on them: the vacuity of axiom-side penalties (§2), AI ≥ FIcons_τ and the diagonal separation (§3), the claims about Hänni's S, and charged deduction (§4). I did not edit `notes.md`. My independent checks are in `referee_penalty/`. Each one is deterministic and writes `<name>.out` next to itself. I also reran the notes' own three scripts from copies in `referee_penalty/repro/`, and they reproduce `checks/*.out` byte for byte.*

My own claims carry the notes' status tags: **[proved]**, **[proof sketch]** (the steps not written out are named), **[computed]** (script and output named), **[known]** (with reference; *(not checked)* means recalled, not checked against the source).

---

## 0. Verdict

**No fatal issue.** I tried to refute each of these and could not, and the three scripts reproduce:
* Lemma 2.1, Theorem 2.2, Proposition 2.5, Theorem 3.1, Theorem 3.2, Corollary 3.3 and Theorem 4.2 are correct as proved.
* The answer to Hänni stands. FI → AI survives every axiom-side penalty defined, AI → FI_τ fails, and the separation comes from free deduction.

**Five major issues.** All five concern what the definitions measure, or what the summaries conclude from the theorems:
* **M1.** The strict form of P2 is a sparsity condition, not a generation-time penalty. It excludes every schema, including the paper's own template theories, and admits the padded Craig sets.
* **M2.** "The paper's A^C_f is not cheap to enumerate [proved]" is proved only for the dovetailing enumerator. For the cumulative form it is false as a property of the set, for the notes' own example.
* **M3.** Cor 4.3(f) holds unconditionally, by the deterministic time hierarchy. The "NP ∩ coNP barrier" that Rem 4.5(ii) and the H-c verdict draw from it is misattributed.
* **M4.** At polynomial budgets AI[poly, poly] does not charge the degree of membership time, but FIcons_poly charges its clock degree. As a result FIcons_poly fails to dominate AI[poly, poly] unconditionally. So "absent if P = NP" holds only in a weaker, per-sequence sense.
* **M5.** The headline "axiom induction becomes strictly stronger than every time-bounded function inductor" contradicts the notes' own Prop 3.4. It holds only for *consistent* time-bounded function inductors.

**Twenty minor issues** (§3). Among them:
* Prop 2.3's use of W_{AI^Kt}(∅) ≤ 1 is false; the correct bound is t(m_0).
* The remark that measuring against t(|χ| + |p|) "removes both charges" makes the prior non-normalisable.
* The Kt charge can be sharpened from a'·log₂|f| to log₂|f| + O(1). After that, AI^Kt_t is equivalent, up to a constant, to FIcons with weights 2^(−|f|)/|f|.
* P3 can exclude the natural representation of PA while admitting Hänni's disguised schema.

---

## 1. The brief's questions, answered

1. **Are the penalty notions natural and precisely defined?**
   * P1a (polynomial-time membership, class version): natural and precise.
   * P1b (Kt): precise. Prop 2.3 slips on its normalisation (m1), and the suggested variant measured against t(|χ| + |p|) is improper (m3).
   * P2 cumulative is essentially *incremental polynomial time* from enumeration complexity, which is natural.
   * P2 strict is not natural (M1). The standard notion that admits schemas is *polynomial delay*, and Lemma 2.1's padding already meets it.
   * P3 is precise. Its "axioms produced from the datum" requirement can exclude the natural axiomatisation of a genuine schematic theory (m16).
   * Defs 1.2 and 1.3 are precise, apart from the degree asymmetry at polynomial budgets (M4) and the finite-language assumption behind the certificate length (m7).
2. **Is the axiom-side penalty vacuous under each definition, and at what cost?**
   * P1a: within a constant c that depends on U, the coding and B. Even the unpadded Craig decider meets P1a.
   * P2, both forms: within a constant, via Lemma 2.1's padding (confirmed, §4).
   * P1b: the notes' bound is a'·log₂|f| bits above the unpenalised weight. A better decider gives log₂|f| + O(1), which is exactly the charge that Prop 2.3(i) puts on every program (m2).
   * The default bound t = m^{a*}, with a* depending on U, is an artefact. The vacuity holds for every time-constructible t(m) ≥ m (m4).
   * P3: vacuous in two sorts, and in one sort for assigners consistent with Th(ℕ). Open in one sort otherwise. It bites on Craig-type sets (confirmed).
3. **Is AI ≥ FIcons_τ correct?** Yes (Theorem 3.1, confirmed). One hypothesis is misstated: Γ_{g_h} = Γ_h does not imply that g_h and h label the same (m5). The examples used satisfy the corrected hypothesis.
4. **Is the claim about Hänni's polytime S correct?**
   * Yes: S is a computable predictor, so Theorem 3.2 defeats it, and S contains a constant predictor, so it beats AI on coin flips. Hence S and AI are incomparable (Prop 3.4).
   * Two caveats. The notes never fix how S, a bit-sequence predictor, reads labelled sentences. And Prop 3.4 needs only the structure of S (a late-started mixture containing the constant predictor), not Hänni's theorem (m14).
   * The headline contradicts Prop 3.4 (M5).
5. **Does charging deduction restore a two-sided equivalence?**
   * With certificate function induction: yes, in the hard-cutoff, labelled-data form, with budgets changed by Õ(d) and polynomial factors (Theorem 4.2, confirmed). It is a form of the standard proof-systems/NP correspondence, which should be cited (m19).
   * With deterministic FIcons_τ: one-sided. FIcons_τ ≤ AI[t_C, d_τ]. The converse needs an exponential clock (Cor 4.3(b)).
   * At polynomial budgets the conditional dichotomy (separation if NP ∩ coNP ≠ P, none if P = NP) holds only per sequence, as bounded versus unbounded loss on a single sequence. In the domination sense of §1.1, FIcons_poly fails to dominate AI[poly, poly] unconditionally, for a definitional reason (M4).
   * Soft penalties: open, as the notes say.
   * `conj:time:polytime` remains a conjecture. The obstacle exhibited by Cor 4.3(f) is a hierarchy effect, not an NP ∩ coNP barrier (M3).

---

## 2. Major issues

### M1. The strict form of P2 is a sparsity condition and excludes every schema

* **Claim.** Def 1.1 P2: "*Strict form*: e_i = O(t(|a_i|))." Theorem 2.2(b) is stated "for the strict and the cumulative form alike". H-a calls P2 "vacuous up to a constant". H-d says axiom-side penalties "do not favour genuine systems".
* **Problem.**
  * By step N an enumerator has completed at most N outputs. The strict form requires every member of length ≤ L to be completed by step C·t(L).
  * So a set with more than C·t(L) members of length ≤ L for infinitely many L has **no** strict-form enumerator, in any order. **[proved]** (counting, above).
  * Every schema with a formula metavariable has 2^{Ω(L)} instances of length ≤ L. This covers PA's induction schema, the instance set of every DT° template with a metavariable (the paper's hypothesis class), and the unpadded Craig set of a fast total assigner (2^{Ω(√L)} members).
  * Under P2-strict the admissible hypotheses are exactly the polynomially sparse sets: the padded sets Pad(q) of Lemma 2.1 (at most L members of length ≤ L) and finite sets.
  * Theorem 2.2(b) stays true, because every r.e. theory has a sparse padded axiomatisation. But the "penalty" does not measure generation time; it measures density.
  * At the level of representations it removes every genuine schema and keeps only the disguised ones. This is the opposite of what H-d is about, and the notes do not mention it.
* **Evidence.** **[computed: `referee_penalty/r2_enumeration.out`, Part A]**
  * The fast-f Craig set exceeds C·L^{a*} members of length ≤ L from L = 1113 (C = 1, a* = 3) to L = 7674 (C = 10⁶, a* = 5).
  * The one-metavariable template {R(w) → R(w)} exceeds it from L = 39 to L = 117.
  * Pad(q) never exceeds L.
* **Fix.**
  * Replace the strict form by **polynomial delay**: e_i − e_{i−1} = O(t(|a_i|)) (Johnson, Yannakakis, Papadimitriou, *IPL* 27 (1988) 119–123 [known]).
  * Pad(q) meets it, with the proof of Lemma 2.1(c): the delay is at most α(T_i + 1)^a + α|a_i| ≤ 2α|a_i|^a, since |a_i| ≥ T_i + 1 **[proved under (S)]**. It is measured in the c2 cost model **[computed: `r2_enumeration.out`, Part B: delay/|a_i| ≤ 1.14 for all four assigners with padding; up to 1437 without]**.
  * Polynomial delay admits template theories: enumerate bodies, and each body gives a distinct instance.
  * Alternatively keep the strict form but state that it admits only sparse sets, and add this to H-d.

### M2. "A^C_f is not cheap to enumerate [proved]" holds only for the dovetailing enumerator

* **Claim.**
  * H-a row: "the paper's A^C_f is not cheap to enumerate ([proved], Rem 2.6; [computed] `c2`)".
  * Rem 2.6(2): "It is **not** correct for an enumerator of A^C_f, which has to dovetail [refuted for the enumeration reading; proved below]".
  * §8: "refuted for unpadded A^C_f (proved; …)".
* **Problem.**
  * *Strict form.* The argument given ("cannot be completed before stage s") is about the dovetailing schedule. Another enumerator may emit axioms in any order. The conclusion is still true for every enumerator, by the counting argument of M1, which the notes do not give. (By M1 the strict form is also the unnatural reading.)
  * *Cumulative form.* The notes' example is f that decides φ_s within |φ_s| steps when s is a power of 2 and loops otherwise. For it, the claim is **false as a property of the set**.
    * The enumerator "for j = 0, 1, 2, …: run f on φ_{2^j} and write its axiom" is a constant-size wrapper around f.
    * It completes the j-th axiom within a bounded multiple of the cumulative output length.
    * What the example shows is that the *generic* dovetailing enumerator e_f, the one obtained uniformly from f, is not cheap.
  * Whether some f has a Craig set with no cheap cumulative enumerator of length |f| + O(1) is a search-versus-decision question: members are linear-time decidable but may be hard to find. The notes do not settle it, and I do not know an unconditional answer.
* **Evidence.** **[computed: `r2_enumeration.out`, Part C]** For the notes' example:
  * the dovetailing enumerator's completion time over cumulative length grows to 1.0·10⁸ at j = 20, like 4^j/j³;
  * the wrapper's ratio decreases to 1.10.
* **Fix.**
  * Restate the claim as one about the uniform map f ↦ (enumerator of A^C_f obtained by dovetailing), which is what Theorem 2.2 needs.
  * For the strict form, add the counting argument.
  * Change "[refuted … proved]" to "the paper's justification is incomplete for the enumeration reading. Its conclusion (a generation penalty does not block the collapse) is correct, by Lemma 2.1".

### M3. Cor 4.3(f) is unconditional, so the "NP ∩ coNP barrier" is misattributed

* **Claim.**
  * Cor 4.3(f) **[proved, conditional on NP ∩ coNP ≠ P]**: "No predictor whose prediction on φ is a function of φ alone, with rational outputs computable in time polynomial in |φ|, has bounded regret against AI[poly, poly] on every consistent labelled sequence."
  * Rem 4.5(ii): "deciding derivability within budget d … by (f), not achievable by a history-free poly-time predictor if NP ∩ coNP ≠ P."
  * H-c row: "its time-bounded part meets the NP ∩ coNP barrier for history-free predictors."
* **Problem.** The statement holds **unconditionally**. **[proved, given the deterministic time hierarchy theorem (known)]**
  * Let the predictor's outputs on sentences of length m be computable in time C·m^s.
  * By the hierarchy theorem take X ∈ DTIME(m^{s+3}) ∖ DTIME(m^{s+1}). The gap absorbs |φ_w| = Θ(|w|) and the constant factors.
  * AI[poly, poly] has bounded loss on D^X:
    * the decider of {φ_w : w ∈ X} ∪ {¬φ_w : w ∉ X} has polynomial membership time;
    * each datum is itself an axiom, so it has a one-line derivation of size |φ_w| ≤ (|φ_w| + 2)^1, i.e. j = 1;
    * the literals are consistent (interpret R as X).
  * If the predictor had bounded regret, the notes' own argument would make "q_1(φ_w) > 1/2" decide X in time O(m^s) up to a finite table, which is a contradiction.
  * The same proof works with deterministic FIcons_poly in place of AI[poly, poly].
  * So (f) says nothing about derivability, NTIME, or NP ∩ coNP. It says that a predictor of one fixed polynomial degree cannot compete with a class that contains every polynomial degree. AI[poly, poly] mixes over every degree of membership time, uncharged, and every derivation degree j.
* **Evidence.** The proof above. The hierarchy theorem is the one the notes cite in Cor 4.3(d).
* **Fix.**
  * Drop the condition from (f), or replace (f) by a budget-matched statement: a predictor of degree s against AI[m^e, m^j] with e, j fixed.
  * There a separation does need a complexity hypothesis. NP ∩ coNP ≠ P supplies one for *some* fixed budgets (those of a witness X₀ ∈ NP ∩ coNP ∖ P), and a fine-grained one (NTIME ∩ coNTIME(m^c) ⊄ DTIME(m^s)) would be needed for budgets chosen in advance.
  * Rewrite Rem 4.5(ii) and the H-c row to match.
  * Note that Hänni's S is itself defined per polynomial and compared only with predictors of the same time.

### M4. Polynomial budgets: the dichotomy is per sequence, not about domination

* **Claim.**
  * §0.1: "At polynomial budgets it is stronger if NP ∩ coNP ≠ P, and not stronger if P = NP (Corollary 4.3)."
  * H-c row: "unconditional for d ≫ τ, conditional on NP ∩ coNP ≠ P at polynomial budgets, absent if P = NP."
  * Cor 4.3(e), definitions:
    * FIcons_poly mixes (f, k) with weight w(f)·2^(−2⌈log₂(k+1)⌉−1);
    * AI[poly, poly] mixes (p, j), "p of polynomial membership time", with weight 2^(−|p|−2⌈log₂(j+1)⌉−1).
* **Problem.** The two mixtures are asymmetric. FIcons_poly pays about 2 log₂ k bits for its clock degree k. AI[poly, poly] pays nothing for the degree of p's membership time. Consequently:
  * **FIcons_poly does not dominate AI[poly, poly], unconditionally.** **[proved, given the deterministic time hierarchy theorem]**
    * For N = 2^(2^r) let X_N be a hierarchy language: in DTIME(m^N), outside DTIME(q((m + 2)^k)) for every k < N/b, where b is the polynomial overhead exponent of the clocked simulation.
    * X_N is given by a program of length c₀ + O(log r).
    * On D^{X_N}, AI[poly, poly] has the hypothesis (p, 1), with p the literal decider of membership time m^{N+1}. So ℓ_AI ≤ c₀ + O(log r) for every n.
    * Every FIcons_poly hypothesis that fits all of D^{X_N} has k ≥ N/b. So, by the dominated-convergence argument of Cor 4.3(c), ℓ_FIcons_poly tends to at least −log₂ Σ_{k ≥ N/b} 2^(−2⌈log₂(k+1)⌉−1) − c_⊥ = log₂ N − O(1) = 2^r − O(1).
    * The regret is therefore at least 2^r − O(log r), which is unbounded in r.
  * This holds whatever the truth of P vs NP. So in the domination sense of §1.1 ("X dominates Y if sup_D(ℓ_X − ℓ_Y) < ∞"), "absent if P = NP" is false.
  * What Cor 4.3(e) proves under P = NP is weaker, and the notes state it correctly there: "each inductor has bounded regret against each hypothesis of the other, with hypothesis-dependent constants". Equivalently, on a single sequence one has bounded loss iff the other has.
  * The FI → AI embedding at polynomial budgets is also only hypothesis-wise. The Craig decider for f^{(m+2)^k} must contain k, at a cost of about log₂ k extra bits, while the AI weight charges only j.
* **Evidence.** The proof above. **[computed: `r3_degree.out`]** −log₂ of the FIcons_poly weight with clock exponent ≥ K is log₂(K + 1) + 2 − o(1). The regret lower bound grows like 2^r once r ≥ 9 (with placeholder constants c₀ = 300 bits and b = 4).
* **Fix.**
  * Charge membership degree too: AI[poly, poly] over triples (p, i, j) with membership clock (m + 2)^i and weight 2^(−|p|−2⌈log₂(i+1)⌉−2⌈log₂(j+1)⌉−2).
  * State the polynomial-budget dichotomy explicitly in the per-sequence sense: there is a sequence on which one inductor has bounded loss and the other unbounded loss.
  * In §0.1 and the H-c row replace "not stronger" / "absent" by "no single-sequence separation". Whether domination holds under P = NP with matched degree charges is open: the factors are polynomial in |p|, i and j.

### M5. The headline overstates: "strictly stronger than every time-bounded function inductor"

* **Claim.** §0.1: "In that sense the penalty helps: axiom induction becomes strictly stronger than every time-bounded function inductor." The sentence before it names "Hänni's polytime S or a clocked function-induction mixture".
* **Problem.**
  * AI is not stronger than S. Prop 3.4: S and AI are incomparable.
  * AI is not stronger than FIall_τ either. "Always accept" is a τ-clocked program, so on the coin-flip sequences of `prop:time:fiall`, FIall_τ has bounded loss while AI's expected loss is at least n.
  * Theorem 3.1 gives domination only over *consistent* time-penalised function induction.
* **Evidence.** Prop 3.4 and `prop:time:fiall`, both in the notes and the paper.
* **Fix.** Write "strictly stronger than every time-penalised *consistent* function inductor (FIcons_τ, Kt- or speed-weighted FIcons). Against time-bounded predictors that may be inconsistent, such as S or FIall_τ, it is incomparable." This sentence is the one Hänni will read first.

---

## 3. Minor issues

**m1. Prop 2.3(ii): W_{AI^Kt}(∅) ≤ 1 is false.**
* *Problem.* c_p = sup time_p/t can be below 1, so a weight 2^(−|p|)/c_p can exceed 2^(−|p|).
* *Evidence.* **[computed: `r1_kt_prior.out`, Part A]** A family of empty-set deciders W⌢δ(n) has total weight 3.45 for |W| = 4 and m₀ = 10.
* *What is true.* W(∅) ≤ t(m₀), since c_p ≥ |p|/t(m₀) ≥ 1/t(m₀) **[proved]**. The error is a constant absorbed into c, but it recurs where Theorem 3.2(d) and Cor 3.3(c) are applied to AI^Kt_t ("W(∅) ≤ 1").
* *Fix.* Add log₂ t(m₀) in those places, or use weight 2^(−|p|)/max(1, c_p).

**m2. The Kt charge is log₂|f| + O(1), not a'·log₂|f|. "A charge every program pays" is accurate only after this sharpening.**
* *Problem.* The bound a'·log₂(|f| + 2) exceeds the floor log₂|p| − log₂ t(m₀) of Prop 2.3(i) by (a' − 1)·log₂|f|, which is not constant.
* *The sharper decider.* An early-exit decider parses χ, then reads q while counting down from m, copying q to a work tape. It rejects if m − 1 < |q|, since every member of Pad(q) has m ≥ |q| + 1, and otherwise simulates as in Lemma 2.1(b). Its time is at most β|q| + poly(|χ|), so c_{d_q} ≤ β|q|/t(m₀) + β'.
* *Consequence.* Together with the upper direction (weights ≤ t(m₀)·2^(−|p|)/|p| and p ↦ f_p), **W_{AI^Kt_t}(D) is within constant factors of Σ_{f compatible} 2^(−|f|)/|f|**. So AI^Kt_t is equivalent, up to a constant in loss, to FIcons with weights 2^(−|f|)/|f|. **[proof sketch; uses (S) for a simulation that reads q from a work tape]**
* *Evidence.* **[computed: `r1_kt_prior.out`, Part C]** The notes' bound sits 5.8 to 29 bits above the floor and grows with |q|. The early-exit decider sits 0 to 0.8 bits above it.
* *Fix.* State Prop 2.3 in this sharper form. Prop 2.3(ii), as written, compares with the best single f, not with the FI mixture.

**m3. The remark after Prop 2.3, "measuring the time against t(|χ| + |p|) … removes both charges", gives an improper prior.**
* *Problem.* With that c_p, a fast decider has c_p ≈ (|p| + m₀)^(1−a*) < 1 and weight about 2^(−|p|)·|p|^(a*−1).
* *Evidence.* **[computed: `r1_kt_prior.out`, Part B]** Over the family W⌢δ(n) the total diverges: it grows linearly in log₂ n for a* = 3 (6563 at 10⁵ groups) and like log log n for a* = 2.
* *Fix.* Use weight 2^(−|p|)/max(1, c_p). With the cap the remark is right.

**m4. Theorem 2.2 is stated only for the default t = m^{a*}, with a* depending on U.**
* *Problem.* This makes the vacuity look machine-dependent, and a reader with a fixed t (say m², or m) cannot apply it.
* *What is true.* For every time-constructible t(m) ≥ m, P1a and P2 are vacuous within a constant. Pad by the simulation cost instead of the counter: emit χ^(m) with m ≥ α(T + 1)^a, and, for the strict or polynomial-delay forms, m ≥ twice the output so far. The decider then replays at cost at most m ≤ |χ|, and completion is linear in |a_i|. **[proof sketch]**
* *Evidence.* The notes' own c2 'all' rows (padding by elapsed time) show end/|a_i| ≤ 1.14 and a linear-cost decider in the a = 1 cost model.
* *Fix.* State Theorem 2.2 for all t ≥ linear, with this padding.

**m5. Theorem 3.1's hypothesis "Γ_{g_h} = Γ_h" does not imply the same labelling.**
* *Counterexample.* h rejects ψ; g accepts ¬ψ and abstains on ψ. Then Γ_g = Γ_h, but on the datum (ψ, 0) h is compatible and g is not.
* *Fix.* Require "g_h computes the same partial map as h". All three examples satisfy it (g_f runs f^τ).

**m6. Cor 4.3(b) and (e): weight overheads.**
* *Problem.* The clocked classes weight f by 2^(−|E(f)|) = 2^(−|f| − O(log |f|)). So "AI[t, d] ≤ 2^c·FIcons_{τ_d} hypothesis by hypothesis" holds with 2^(c + O(log |p|)), not 2^c. In (e), "of length |p| + O(log(the degrees)) + c" likewise omits O(log |p|).
* *Fix.* Add O(log |p|). The conclusions, which are hypothesis-wise, survive.

**m7. Theorem 4.2(a): the bit bound β·s·log₂(s + 2) for a derivation of symbol size s assumes finitely many non-logical symbols.** In a countable L one symbol can need an arbitrarily long code. *Fix.* Assume L finite, as in the language-sequence setting, or count symbol-code lengths in "size".

**m8. Re-indexing between |w| and |φ_w|.**
* *Problem.* In Prop 2.4(a) and Cor 4.3(c)(i), (d) the clocks act on |φ_w| = Θ(|w|), but the conclusions are stated as DTIME(q(τ)) in |w|. For super-polynomial τ, say 2^m, the constant inside matters.
* *Problem.* In Cor 4.3(d), f_X is called "the τ₂-time assigner", but the FIcons clock is on a fixed plain universal machine, so the budget needed is about q′(τ₂).
* *Fix.* State the classes in terms of |φ_w|, and apply the hierarchy theorem with the composed bounds.

**m9. Wording slips.**
* H-b(ii) row: "Q ∪ {DET} … decides every sentence" should be "decides every s_n". Q ∪ {DET} is incomplete.
* Cor 3.3(b): "the regret of FIcons_τ against AI is bounded above uniformly" should be "bounded below" (equivalently, AI's regret against FIcons_τ is bounded above).
* §0.1: "when d exceeds τ by a polynomial factor" does not match Cor 4.3(d)'s condition q(τ)·log q(τ) = o(τ₂), which is a polynomial *of* τ, not τ times a polynomial.

**m10. H-a row: "So `thm:time:equiv` survives: AI_pen ≡ unpenalised FIcons".**
* *Problem.* For P3 in one sort this is open (Prop 2.4(d)).
* *Problem.* The upper inequality W_{AI^cont_t} ≤ 2^c·W_FI, needed for "≡" in Prop 2.4(b), is not written. It is one line: G ↦ proof search from B ∪ A_G, with A_G r.e.
* *Fix.* Restrict the sentence to P1, P2, and P3 in two sorts, and add the line.

**m11. Prop 2.4(b) and Prop 5.1(b) use `prop:time:twosorted` with "B ⊇ Q on the arithmetic sort".** The model ℕ ⊕ M works only if B = Q ∪ B_L with B_L pure L-sort; mixed-sort sentences in B break it. *Fix.* State this.

**m12. Theorem 3.2 uses Σ₁- and Δ₀-completeness of Q for T and Out.** In L_A these hold for <-free formulas, as the paper notes in §6.2. *Fix.* Require T and Out to be written with bounded quantifiers as ∃z(z + x = y), as Prop 2.5 does.

**m13. Theorem 3.1's examples include "speed-prior-weighted FIcons" with weights 2^(−|f|)/(total time on the data).**
* *Problem.* These weights depend on D, which the theorem's form W_Y(D) = Σ v(h) does not allow. The proof still goes through if v(h, D) ≤ K·2^(−|g_h|) for all D.
* *Problem.* This is not Schmidhuber's speed prior, which is uncited (J. Schmidhuber, "The Speed Prior", COLT 2002, LNAI 2375 [known (not checked)]).
* *Fix.* Allow D-dependent weights in the statement, and rename or cite.

**m14. Hänni's S on labelled sentences.**
* *Problem.* S is defined on bit sequences. The notes never fix how it reads (history, sentence) pairs, or what "time p(n) per step" means when sentences are longer than p(n).
* *What is true.* The claims hold for any adaptation that is a computable predictor and contains a constant predictor. Prop 3.4 uses only the late-start mixture structure, not Hänni's regret theorem.
* *Fix.* Say so, and change Prop 3.4's status to "proved".

**m15. Rem 5.4: "Among axiom-side measures, only content-relative ones (P3), and only in logics too weak to carry computations, price it."**
* *Problem.* P3 in one sort for assigners inconsistent with Th(ℕ) is open (Rem 5.3), so "only in logics too weak" is not established.
* *Problem.* "Only" ranges over the four measures defined, not over all axiom-side measures.
* *Fix.* Restrict the claim.

**m16. P3 can exclude the natural representation of a genuine schematic theory while admitting Hänni's disguised one.** **[proof sketch]**
* *Setting.* One sort, B = Q, binary numerals, data (Con(IΣ_n), 1) for n = 1, 2, …. Each datum has size O(log n) and is a PA-theorem [known: IΣ_{n+1} ⊢ Con(IΣ_n); Hájek–Pudlák 1993, Ch. I (not checked)].
* *The genuine representation fails.* Take a P3 hypothesis G whose axioms are PA axioms. G(φ_n) has total size O(t(c·log n)) < n for large n. Every axiom of size < n is either a Q axiom or an induction instance for a formula with fewer than n quantifiers. Such a formula is logically equivalent to a Σ_n formula, so its instance is provable in IΣ_n. So Q ∪ G(φ_n) ⊆ Cn(IΣ_n), which does not prove Con(IΣ_n) (Gödel II).
* *The disguised representation fits.* G_f(φ) := Q ∪ {Acc_f(⌜φ⌝) → φ, Rej_f(⌜φ⌝) → ¬φ}, with f = PA-proof search, is sound, compatible with every datum, and runs in polynomial time (as in Prop 2.4(c), with Q in G).
* *What is not written out.* The exact formalisation of Con(IΣ_n) with a binary numeral for n.
* *Consequence.* P3 can price genuine axiom systems while leaving the disguised ones free, a caveat that H-d and Rem 5.4 omit.

**m17. Inherited prefix-machine detail.** W⌢q is a valid U-program, and (S)'s counter "plus |q|" is computable, only if q's end can be found, i.e. hypotheses come from a self-delimiting code. For partial programs U may read past q on non-halting runs. *Fix.* Say that hypotheses are taken from a prefix-free code, as `def:time:inducers` implicitly assumes.

**m18. The scripts.**
* *Stale theorem numbers in the docstrings.* c1 says "Theorem 4.2" (now Thm 3.2), c2 says "Lemma 3.1" (now Lemma 2.1), c3 says "Theorem 5.2(b)" (now Thm 4.2(b)).
* *c2's "dec/|chi|" column is implied by the cost model, not measured.* It is (|χ| + m)/|χ| ≤ 2, since m ≤ |χ|. Only the 30-sample from-scratch rerun ("rerun" column) measures the decider.
* *Fix.* Update the docstrings and describe the column accurately in §6.

**m19. Novelty and references for Theorem 4.2 and Prop 2.5.**
* Theorem 4.2(a) is the standard fact that bounded-size provability from a polynomial-time axiom set is an NP predicate. Part (b) is Craig's trick with certificates in place of padding. Cite Cook and Reckhow, "The relative efficiency of propositional proof systems", *JSL* 44 (1979) 36–50 [known; checked bibliographically], and temper "new".
* Prop 2.5 is Craig's trick with a binary-numeral witness bound in place of unary padding. It is a good answer to model problem 14, but "short of Craig's trick" is a matter of framing.

**m20. Rem 4.4(ii): "The certificate sets A_V are not finite unions of DT° templates" is asserted without proof.** For particular V it can fail. *Fix.* Write "need not be", or prove it for a stated V.

---

## 4. Claims confirmed

| claim | what was checked | result |
|---|---|---|
| Lemma 2.1 (a)–(d) | every step under (S): unique two-candidate parse; at most one detection per counter value; Σ_{j≤i}\|a_j\| ≤ 4(T_i + 1)³ ≤ 4\|a_i\|³; both completion bounds; injectivity | **confirmed** (under (S)); c2 reproduces |
| Thm 2.2 (a), (b) | lower bounds via q_f and Pad(q_f); upper bound via proof search from B ∪ A_g; loss telescoping | **confirmed** for the default t (see m4 for the general t; M1 for what the strict form means) |
| Prop 2.3 (i) | time_p ≥ \|p\| | **confirmed**; (ii) correct up to the constant of m1, and loose (m2) |
| Prop 2.4 (a) | literal-set models in ℕ; decision by scanning G(φ_w) | **confirmed** (m8 on re-indexing) |
| Prop 2.4 (b), (c) | Σ₁-completeness + MP; the model of Th(ℕ) ∪ Γ_f | **confirmed** (m10, m11) |
| Prop 2.5 (a)–(c) | Q ⊢ true Σ₁, Q refutes false Δ₀, Q ⊢ ∃z(z + y = k̄) → ⋁_{j≤k} y = j̄ (Smith's ≤ is ∃v(v + x = y)); the counterexample of `prop:time:single` | **confirmed**. A correct one-sorted repair, with membership syntactic |
| Thm 3.1 | the chain W_X ≥ 2^(−c)W_FI ≥ 2^(−c)K^(−1)W_Y; κ; the FIcons_τ wrapper | **confirmed** (m5) |
| Thm 3.2 (a)–(d) | recursion-theorem construction; DET is true Π₁; refutation of s_n when e(n) = 0; the precision bound q_{b_j} ≤ 1/2 + 2^(−j−2) and Σ log₂(1 + 2^(−j−1)) ≤ 1/(2 ln 2) | **confirmed**; c1 reproduces (min ℓ_n − n = −0.313 ≥ −0.7213) |
| Cor 3.3 (a)–(c) | P(D) computable and ≥ 2^(−\|D\|−1); W_{FIcons_τ} ≤ 2P; the incomputability induction | **confirmed** (m1 for AI^Kt) |
| Prop 3.4 | S contains a constant predictor; `prop:time:fiall` | **confirmed** (m14) |
| Rem 3.5 | f_D; the Rosser variant (Q ⊢ x ≤ n̄ ∨ n̄ ≤ x) | **confirmed** |
| Prop 4.1 (a), (b) | Γ_u ⊆ Th(ℕ); u's running time ≥ P's total time | **confirmed**; (c) a reasonable sketch |
| Thm 4.2 (a), (b) | V_p's time (with the clock trick for d); θ_c unique and valid; \|θ_c\| ≤ 12\|c\| + 17 in c3's syntax; the linear derivation of (B ∧ C) → B | **confirmed** (m7, m19); c3 reproduces |
| Cor 4.3 (a), (c), (d) | Craig derivation size; dominated convergence; hierarchy | **confirmed** (m8) |
| Cor 4.3 (b) | brute force over certificates | **confirmed** up to O(log \|p\|) (m6) |
| Cor 4.3 (e) | NP ∩ coNP ≠ P bullet; P = NP bullet as hypothesis-wise bounded regret | **confirmed** as stated in (e); not as summarised (M4) |
| Cor 4.3 (f) | the argument | **confirmed**, and true unconditionally (M3) |
| Prop 5.1 (a), (b) | theory-preserving injective maps with constant overhead; the ratio of ratios | **confirmed**, at the level of theories (M1 and m16 concern representations) |
| Rem 5.2 | small-model decision for monadic logic | a reasonable sketch |
| `c1`, `c2`, `c3` | rerun from copies in `referee_penalty/repro/` | **byte-identical** to `checks/*.out` |

---

## 5. References checked

* Bibliographically confirmed in this session:
  * S. Legg, ALT 2006, LNCS 4264, 274–287 (arXiv cs/0606070).
  * Cook and Reckhow, *JSL* 44 (1979) 36–50.
  * Johnson, Yannakakis and Papadimitriou, *IPL* 27 (1988) 119–123.
* Recalled and consistent with the notes (not checked against the sources):
  * Craig, *JSL* 18 (1953) 30–32.
  * Hartmanis and Stearns, *Trans. AMS* 117 (1965).
  * Hennie and Stearns, *JACM* 13 (1966).
  * Seiferas, Fischer and Meyer, *JACM* 25 (1978).
  * Žák, *TCS* 26 (1983).
  * Lewis, *JCSS* 21 (1980) (monadic satisfiability NEXPTIME-complete).
  * Hájek and Pudlák 1993.
  * Smith, 2nd ed. 2013.
  * Li and Vitányi, 3rd ed. 2008.
  * Cook's NTIME hierarchy: STOC 1972, journal version *JCSS* 7 (1973).
* Missing:
  * Schmidhuber's speed prior (m13).
  * Levin 1973 for Kt (the notes cite Li–Vitányi, which is acceptable).
  * Cook–Reckhow for Theorem 4.2 (m19).
  * Johnson–Yannakakis–Papadimitriou, if polynomial delay is adopted (M1).

---

## 6. Referee checks

| script | what it checks | result |
|---|---|---|
| `referee_penalty/r1_kt_prior.py` → `.out` | P1b: (A) W_{AI^Kt}(∅) ≤ 1 fails; (B) the t(\|χ\| + \|p\|) variant diverges, and capping at c_p ≥ 1 fixes it; (C) Kt charge of the padded decider under the notes' bound and under early exit, against the floor log₂(\|q\|/t(m₀)) | (A) family weight 3.45 > 1; (B) 6563 at 10⁵ groups (a* = 3), still growing (a* = 2), capped 0.0625; (C) notes' bound 5.8 → 29 bits above the floor, early exit 0.8 → 0 |
| `referee_penalty/r2_enumeration.py` → `.out` | P2: (A) counting against C·L^{a*}; (B) polynomial delay of Pad(q) in the c2 cost model; (C) Rem 2.6's cumulative example: dovetailing enumerator vs constant-size wrapper | (A) Craig set of a fast f and the template {R(w) → R(w)} exceed every tested C·L^{a*}, Pad(q) never; (B) delay/\|a_i\| ≤ 1.14 padded, up to 1437 unpadded; (C) dovetail ratio 1.0·10⁸ at j = 20, wrapper 1.10 |
| `referee_penalty/r3_degree.py` → `.out` | Cor 4.3(e): FIcons_poly weight of clock exponents ≥ K; regret lower bound on D^{X_N} | −log₂ T(K) = log₂(K + 1) + 2 − o(1); regret bound grows like 2^r |
| `referee_penalty/repro/` | the notes' c1, c2, c3 rerun | identical outputs |

The scripts check counting and arithmetic. The claims they support are proved, or proof-sketched, in the text above.
