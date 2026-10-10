# Referee report (complexity): `short-derivations/notes.md`

*Adversarial referee of `notes.md`, which builds on `../time-followup/notes.md`. Focus: the soft version (S3) and its overheads, the template question (S4), and every consequence drawn from time-followup Theorem 4.2 and Corollary 4.3, checked against the hypotheses those results carry. I did not edit `notes.md`. A parallel proof-theory referee report exists (`referee-logic.md`, "RLg" below). Where I agree with it I say so and do not repeat its argument. "RP" and "RL" are the time-followup referees (`../time-followup/referee-penalty.md`, `../time-followup/referee-logic.md`).*

*My scripts are in `referee_complexity/`. Each is deterministic or seeded and writes `<name>.out` next to itself. They import the notes' `checks/kcore.py` only to cross-check it, and they also use RLg's independent implementation `referee_logic/rk.py`. The formula code, the template generator, the template matcher and the Turing-machine simulator in my scripts are my own.*

**Status tags** are as in the notes: [proved], [proof sketch], [known] (with reference; "not checked" means recalled), [computed] (script and output named), [conjecture], [open], [refuted].

---

## Verdict

**No fatal issue.** The theorems of §5 and §6 are correct as stated, apart from one wrong status and the scope slips listed below. I re-derived their constants by hand and checked them by script.

**Three major issues.**

* **M1 (new).** "Whether r can be 1 is open" (§0.1, §0.2, Prop 5.3, §8 problem 1, §9) is **refuted**, by bookkeeping the notes almost contain.
  * The certificate of Thm 5.2(a) is 2 bits shorter than the notes count, and a negative datum carries b_s more bits for its ¬.
  * So, on **every** sequence, soft AI pays at least κ(2 + b_s·[b = 0]) per datum more than FIcert^σ_{κ,κ}.
  * On all-negative literal sequences the excess is exactly κ(b_s + 4) per datum, up to O(1).
  * No pair of rates gives a two-sided constant-regret equivalence.
* **M2 (inherited).** The polynomial-budget dichotomy "stronger if NP ∩ coNP ≠ P, not stronger if P = NP" (§0.1, Cor 3.2) reuses time-followup Cor 4.3(e) in its pre-referee form. RP-M4 transfers verbatim to AI^b[poly, poly] and AI^{a1}[poly, poly]. These mixtures do not charge the degree of membership time, so FIcons_poly fails to dominate them **unconditionally**, whatever the truth of P = NP. "Not stronger" holds only per sequence. The notes cite RL-m6 from the same round of referee reports but do not take up RP-M4 or RP-m7.
* **M3 (concurrence with RLg-M1).** Parameter indices are an unpriced channel. Theorem 3.1(iii) applies time-followup Theorem 4.2(a) outside its valid hypotheses, and Thm 4.2(iv) and Cor 4.4(i) ⊆, (ii), (v) need closure under renaming. One addition from the complexity side: the soft results (Thm 5.2(a), (b), Prop 5.3, Cor 5.4) are **immune** to this channel, because bit cost pays for indices.

**Fourteen minor issues.** In summary:
* the S3 overheads are stated against two different certificate rates;
* "the same picture" in §0.1 overreaches for the soft version;
* Theorem 3.1 omits hypotheses of time-followup Thm 4.2;
* a "[standard]" verifier step in Cor 6.2(ii) is not standard as stated;
* Cor 6.2's tightness claim for `cor:time:hard` needs a one-sided variant;
* the open status of S against reading (b) is too broad;
* the rest are wording, an output column of `c2`, and references.

**Confirmed.** Thm 5.2(a) and (b) with their exact constants; Prop 5.3(i)–(iii); Cor 5.4's three inequalities; Thm 3.1(i), (ii); Cor 3.2's fit class (given (F1) of RLg-M1); Cor 4.4(iii), (iv); Prop 4.5, including the running-time reading of Hänni's note; Prop 6.1, extended by my check to machines that move left and overwrite cells (`rc2`); Cor 6.2(i), (iii); Cor 6.3 for deterministic machines. Details are in the last section.

---

## Issues

### Fatal

None found.

### Major

**M1. Theorem 5.2(b) cannot hold with r = 1. "Whether r can be 1 is open" is refuted, and so is the reading of Prop 5.3 that κ is a candidate rate.**

* *Claims.*
  * §0.1: "Whether r can be 1 is open".
  * §0.2, S3 row: "**Open**: r = 1".
  * Prop 5.3, last paragraph (line 478): "So κ is the only joint rate for which a two-sided constant-regret equivalence could hold. … Whether (b) holds at κ is **[open]**."
  * §8 problem 1: "Is ℓ_{AI^σ_κ}(D) ≤ ℓ_{FIcert^σ_{κ,κ}}(D) + O(1) for all D? … Proposition 5.3 shows κ is the only candidate."
  * §9: "Prop 5.3 | proved; r = 1 open".
* *Problem.* The answer is no, for every κ > 0, and no pair of rates works.

  **Proposition R1 [proved].** Use the code Code_K and the inducers of Definition 5.1, with B = ∅ and literal data.
  * (i) For every hypothesis p and sentence ψ, ℓ^bit_p(ψ) ≥ |ψ|_bit + 4. Hence ℓ_{AI^σ_κ}(D) ≥ κ Σ_i (|φ_i^{b_i}|_bit + 4) for every D. This sharpens Prop 5.3(iii).
  * (ii) Let D^∅ be the all-negative literal sequence of Prop 5.3, and κ_c, κ_s ≥ 0 any rates. Then

    ℓ_{AI^σ_κ}(D^∅_n) − ℓ_{FIcert^σ_{κ_c,κ_s}}(D^∅_n) = (κ − κ_s)·Σ_{i≤n} |φ_{w_i}|_bit + κ(b_s + 4)·n + O(1).

    The O(1) lies between −|V_∅| and |p_∅|.
  * (iii) Hence ℓ_{AI^σ_κ} − ℓ_{FIcert^σ_{κ,κ}} → ∞ on D^∅, so Theorem 5.2(b) fails with r = 1. No pair (κ_c, κ_s) gives a two-sided constant-regret equivalence with AI^σ_κ. On the all-positive sequence (X = {0,1}*) the gap at κ_s = κ is 4κn + O(1).
  * (iv) In fact the gap at rate κ is linear on **every** sequence: for every D, with c′ the constant of Thm 5.2(a),

    ℓ_{AI^σ_κ}(D) − ℓ_{FIcert^σ_{κ,κ}}(D) ≥ κ Σ_i (2 + b_s·[b_i = 0]) − c′ ≥ 2κ|D| − c′.

    So (b) at r = 1 fails on every infinite sequence, not only on D^∅.

  *Proof.*
  * (i) A code in Code_K lists at least one line. The last line contributes its 2-bit tag and the code of its formula, and the 2-bit end tag follows. So |Code(π)| ≥ |ψ|_bit + 4 for every derivation π of ψ. Every factor of W_{AI^σ_κ}(D) is then at most 2^{−κ(|φ_i^{b_i}|_bit + 4)}, so W(D) ≤ W(∅)·2^{−κΣ(|φ_i^{b_i}|_bit + 4)}.
  * (ii), AI side.
    * Lower bound: (i) together with |¬φ|_bit = |φ|_bit + b_s (one ¬ token).
    * Upper bound: the polynomial-time decider p_∅ of {¬φ_w} derives each datum in one line of code length |φ_w|_bit + b_s + 4 (Prop 5.3(i)'s own computation). With W(∅) ≤ 1 this gives ℓ_AI(D^∅_n) ≤ |p_∅| + κΣ(|φ_{w_i}|_bit + b_s + 4).
  * (ii), FIcert side.
    * Lower bound: every hypothesis's factor is at most 2^{−κ_s|φ_i|_bit}, so ℓ_FI ≥ κ_s Σ|φ_{w_i}|_bit.
    * Upper bound: V_∅(φ_w, ε) = rej is consistent with B = ∅ and has λ = 0, so ℓ_FI ≤ |V_∅| + κ_s Σ|φ_{w_i}|_bit.
  * (iii)
    * At κ_s = κ the difference is κ(b_s + 4)n + O(1).
    * At κ_s ≠ κ, the term (κ − κ_s)Σ|φ_{w_i}|_bit = Θ(n log n) dominates (Prop 5.3(i)'s sum bound), with either sign.
    * On X = {0,1}* there is no ¬, which leaves 4κn.
  * (iv) The certificate in the proof of Thm 5.2(a) is Code(π) with the last formula and the 2-bit end tag removed. So λ_{V_p}(φ^b) ≤ ℓ^bit_p(φ^b) − |φ^b|_bit − 2 exactly; the notes drop the −2. `c4` measures exactly this length on 480 derivations: "certificate length = code length − |φ|_bit − 2", with 0 exceptions.
    * The FIcert^σ_{κ,κ} factor of V_p is therefore at least 2^{−κℓ^bit_p(φ^b) + κ(2 + |φ^b|_bit − |φ|_bit)}, and |φ^b|_bit − |φ|_bit = b_s·[b = 0].
    * Summing over p as in (a) gives W_{FIcert^σ_{κ,κ}}(D) ≥ 2^{−c}·2^{κΣ_i(2 + b_s[b_i = 0])}·W_{AI^σ_κ}(D).
    * Take logarithms, using W_{FIcert}(∅) ≤ 1. ∎

  The notes' own proof of Prop 5.3(ii), run at κ' = κ, already gives a gap of κ b_s n on D^∅. It is lost only because the proof weakens |φ^{b}|_bit to |φ|_bit.
* *Evidence.* **[computed: `referee_complexity/rc1_rate_one.out`]**
  * My implementation of |χ|_bit agrees with `kcore.formula_bits` and `rk.fbits` on 2249 formulas, those with indices and large parameter numbers included.
  * One-line derivations of ¬φ_w from {¬φ_v}, for |w| ≤ 8, are accepted by both kcore and rk. Their code length is exactly |φ_w|_bit + b_s + 4, so the bound in (i) is attained.
  * For the literal language (b_s = 4) and κ = 1, the gap per datum tends to 8.0 = κ(b_s + 4) on D^∅ (7.998 at n = 2^17). On the all-positive sequence it tends to 4.0 = 4κ (3.998). At κ = 0.1 the limits are 0.8 and 0.4.
* *What survives.*
  * Theorem 5.2(a) holds. R1(iv) is its sharpened form: at a common rate κ, AI pays at least κ(2 + b_s·[b = 0]) more per datum than FIcert^σ_{κ,κ}, on every sequence.
  * Upward, (b)'s first inequality bounds AI's extra cost per datum by κ(2|φ|_bit + e_1), at the doubled certificate rate 2b_sκ.
  * The notes' theorems are right. Only the status of "r = 1" is wrong, and Prop 5.3(ii)'s own proof at κ' = κ, or the −2 that the notes drop in (a), already decides it.
* *Fix.*
  * Mark "r = 1" **[refuted]** in §0.1, §0.2, Prop 5.3, §8 and §9. State R1. Replace "κ is the only joint rate …" by "no joint rate gives a two-sided constant-regret equivalence (R1)".
  * The meaningful open question allows an additive per-datum overhead: is there a constant K with ℓ_{AI^σ_κ}(D) ≤ ℓ_{FIcert^σ_{κ,κ}}(D) + κKn + O(1) for all D? Equivalently, can the certificate rate 2b_sκ and the statement rate 2κ of (b)'s first inequality be lowered to κ, keeping an additive O(κ) per datum?
  * One obstacle should be recorded with it (my remark, not proved as an impossibility). A datum that is not itself an axiom of the hypothesis needs symbol size ≥ 2|φ^b| − 1, which is Cor 5.4's last sentence. So the statement rate is effectively 2κ on such data. A positive answer would need hypotheses that take most data as axioms, and that requires their membership test to decide those data quickly.

**M2. The polynomial-budget dichotomy is inherited from the pre-referee Cor 4.3(e). FIcons_poly does not dominate AI^b[poly, poly] or AI^{a1}[poly, poly], unconditionally.**

* *Claims.*
  * §0.1: "At polynomial budgets it is stronger if NP ∩ coNP ≠ P and not stronger if P = NP; the intermediate case is open (time-followup Cor 4.3)."
  * Cor 3.2: "Mix over budgets as in time-followup Cor 4.3(e) … at polynomial budgets, stronger if NP ∩ coNP ≠ P and not stronger if P = NP".
  * Cor 4.4: AI^{a1}[poly, poly] is "weighted as in time-followup Cor 4.3(e)".
* *Problem.* The time-followup penalty referee showed (RP-M4) that the two mixtures of Cor 4.3(e) are asymmetric. FIcons_poly pays about 2 log₂ k bits for its clock degree k, while AI[poly, poly] pays nothing for the degree of p's membership time. Its argument transfers word for word to the readings here.

  **Proposition R2 [proved, given the deterministic time hierarchy theorem, as in RP-M4].** With the mixtures as defined in the notes, sup_D (ℓ_{FIcons_poly}(D) − ℓ_{AI^b[poly,poly]}(D)) = ∞. The same holds with AI^{a1}[poly, poly] in place of AI^b[poly, poly]. This holds whether or not P = NP.

  *Proof.*
  * *The languages.* For r ≥ 1 let N := 2^{2^r}, and let X_N be RP's hierarchy language: X_N ∈ DTIME(m^N), and X_N ∉ DTIME(q((m + 2)^k)) for every k < N/b. Given r, X_N is computed by a fixed program, so the decider p_N of {φ_w : w ∈ X_N} ∪ {¬φ_w : w ∉ X_N} has |p_N| ≤ c₀ + O(log r) and membership time O(m^{N+1}). This is polynomial, and its degree is not charged.
  * *The AI side.* Each datum is an axiom of p_N, so it has a one-line derivation. Its material, and its only instance, has size |φ_w^b| ≤ (|φ_w| + 2)^1. So (p_N, 1) is compatible with every prefix of D^{X_N}, under reading (b) and under (a1). Hence ℓ ≤ c₀ + O(log r) for every n.
  * *The FI side.* An FIcons_poly hypothesis (f, k) that fits all of D^{X_N} gives X_N ∈ DTIME(q(C_f(m + 2)^k)), so k ≥ N/b. By dominated convergence, ℓ_{FIcons_poly}(D^{X_N}_n) tends to at least log₂ N − O(1) = 2^r − O(1). This is RP's computation, confirmed by `../time-followup/referee_penalty/r3_degree.out`.
  * The regret is therefore ≥ 2^r − O(log r), for every r. ∎

  So, in the domination sense the notes themselves use in §0.1 ("dominated, with constant regret"), "not stronger if P = NP" is false. What Cor 4.3(e) proves under P = NP is weaker: every hypothesis of one inductor has a hypothesis of the other with the same labels, at a hypothesis-dependent cost. Equivalently, the two have bounded loss on the same sequences. This per-sequence statement transfers correctly to reading (b) through Thm 3.1(ii), and I confirm it.
* *Evidence.* The proof above, which is RP-M4's with the one observation that (p_N, 1) is also a (b) and an (a1) hypothesis. The notes cite "referee m6 there" (Cor 3.2), so the time-followup referee reports were available when they were written.
* *Fix.*
  * Adopt RP's degree charge for both mixtures: triples (p, i, j) with membership clock (m + 2)^i and weight 2^{−|p|−2⌈log₂(i+1)⌉−2⌈log₂(j+1)⌉−2}.
  * State the dichotomy per sequence: "there is a sequence on which one has bounded loss and the other does not", or "no single-sequence separation if P = NP".
  * Whether domination holds under P = NP with matched degree charges is open, as RP says.
  * Apply the same per-sequence wording to Cor 4.4's comparison with FIcons_poly. (iii) there is per-sequence and correct.

**M3. Parameter indices (concurrence with RLg-M1, with two additions).**

* *Concurrence.* I agree with RLg-M1, and I re-derived its counterexample independently before reading it.
  * Sizes count a parameter p_N as one node, but Definition 1.2 admits every decider.
  * So an axiom (p_N = p_N) → φ_w, decided by checking a certificate written in N's binary expansion, gives (a1)- and (b)-short derivations of φ_w, with no budget charged for the certificate.
  * This invalidates, for unrestricted deciders, the following: Thm 4.2(iv); Cor 4.4(i) "⊆", (ii) and (v), in particular "nondeterminism plays no role" and the clock 2^{O(h log h)}; Thm 3.1(iii); and the corresponding cells of the §4.3 table.
  * RLg's fix (F1), closure of B ∪ A_p under permutations of the parameters in Definition 1.2, repairs all of them. Every construction in the notes satisfies it.
* *Addition 1: Theorem 3.1(iii) is exactly a hypothesis misapplication of time-followup Theorem 4.2(a).*
  * That theorem's step "a derivation of symbol size s has a bit code of length at most β·s·log₂(s + 2)" needs closure under renaming. The notes themselves assume closure for exactly this bound (ℓ^bit ≤ βℓ^sym log₂(ℓ^sym + 2), Thm 5.2(c)) and in Lemma 4.1. The step also needs a finite L (RP-m7).
  * The notes impose closure exactly where they prove such a bound themselves (Thm 5.2(c)), and drop it where they import it (Thm 3.1(iii)).
* *Addition 2: the soft results are immune [proved].*
  * Theorem 5.2(a) maps a derivation to its own bit code, which includes Elias-γ codes of every parameter number. So λ_{V_p}(φ^b) ≤ ℓ^bit_p(φ^b) − |φ^b|_bit holds for every decider, with no closure.
  * Theorem 5.2(b), Prop 5.3 and Cor 5.4 use θ_c, which is parameter-free, or one-line derivations.
  * So §5 in bit cost needs no restriction. Only Thm 5.2(c) and Remark 5.5 (symbol cost) need closure (RLg-m11).
  * This is worth stating: bit cost is the measure under which the soft sandwich is robust.

### Minor

**m1. Corollary 5.4 and the S3 row compare against two different certificate rates and understate the constants.**
* *Claims.*
  * "against certificate-only charging, soft AI pays a per-datum overhead between κ|φ^b|_bit and κ(2|φ|_bit + e_1), with the certificate rate doubled per symbol (2b_s bits per certificate bit)".
  * §0.1 and §0.2: "up to a constant factor in the rate".
* *Problem.*
  * The lower end is an absolute bound on ℓ_AI (third bullet). As a regret it holds against FIcert^σ_{κ,0} (first bullet). The upper end holds against FIcert^σ_{2b_sκ,0}. The two ends refer to different comparison inducers.
  * The certificate factor is 2b_s ≥ 6, not "doubled".
  * The rate factor of Thm 5.2(b) is r = 31b_s + 26. That is 150 for the literal language and at least 119 for any L (`rc1`, part 5). It comes from absorbing the additive e_1 into |φ|_bit.
* *Fix.*
  * Say "against FIcert^σ_{κ,0} the regret is at least κΣ(|φ_i^{b_i}|_bit + 2) − c′, by R1(iv) and the identity ℓ_{FIcert^σ_{κ,0}} = ℓ_{FIcert^σ_{κ,κ}} − κΣ|φ_i|_bit; against FIcert^σ_{2b_sκ,0} it is at most κΣ(2|φ_i|_bit + e_1) + c″". (R1(i)'s κΣ(|φ_i^{b_i}|_bit + 4) is an absolute lower bound on ℓ_AI, not a regret.)
  * State r's size where "constant factor" is claimed, and present (b)'s first inequality, with rates (2b_sκ, 2κ) and an additive κe_1 per datum, as the informative form.

**m2. §0.1: "A soft charge … gives the same picture up to a constant factor in the rate."**
* *Problem.*
  * §5 proves only the AI ↔ FIcert correspondence. It proves no soft analogue of the separations from deterministic function induction (Cor 3.2, time-followup Cor 4.3(d), (e)), nor of the fit classes.
  * Under any soft charge every loss diverges on every infinite sequence (Prop 5.3(iii)). So "bounded loss" statements, and with them Fact 1.4, have no soft counterpart. A separation would have to be stated as regret growth.
  * Whether soft AI beats soft deterministic FI at all is not clear. Soft AI pays a per-datum certificate charge of order κ·2b_s|c|, which can exceed the per-datum loss of a deterministic mixture that fits long prefixes.
* *Fix.* Restrict the sentence to the correspondence, and list "soft separations from deterministic FI" as open.

**m3. Theorem 3.1 omits hypotheses of time-followup Theorem 4.2.**
* *Problem.* Thm 4.2 assumes:
  * B decidable in polynomial time. §1.2 here says only "a decidable background".
  * d, t time-constructible and nondecreasing. Here g, and hence G and G′, must be.
  * L finite, for d′ (RP-m7). §1.1 makes L finite only "in §4", and Def 5.1's b_s = ⌈log₂(σ_L + 6)⌉ also presupposes a finite L.
* *Fix.* State these hypotheses in Thm 3.1, Cor 3.2 and Def 5.1, together with (F1) for (iii).

**m4. Corollary 6.2(ii): the "[standard]" verifier step is not standard as stated.**
* *Claim.* "The verifier follows the guesses of the two nondeterministic machines, with a tag bit, in time O(τ) and with certificates of length ≤ τ + 1, over a binary alphabet [standard]."
* *Problem.*
  * Prop 6.1's M has one work tape.
  * With only the τ choice bits of a k-tape machine, the direct simulation on one work tape costs O(τ²) in general. I know of no O(τ) simulation.
  * The standard O(τ) route guesses the whole transcript: the transitions and the symbols read on every tape. The verifier then checks each tape separately in O(τ) [known: Book, Greibach, Wegbreit, "Time- and tape-bounded Turing acceptors and AFLs", J. Comput. System Sci. 4 (1970) 606–621 (not checked)]. Its certificate has length O(τ), not τ + 1.
* *Effect.* None on the conclusion with the transcript certificate: |c| = O(τ) still gives size c(τ + |w|)². With τ + 1 choice bits and the direct simulation, the bound would be c(τ² + |w|)².
* *Fix.* Replace "τ + 1" by "O(τ) (the guessed transcript)" and cite Book–Greibach–Wegbreit.

**m5. Corollary 6.2: "the lower bounds of `cor:time:hard` … are therefore tight up to polynomials" does not follow from (ii) as stated.**
* *Problem.*
  * (ii) needs X **and its complement** in NTIME(τ).
  * `cor:time:hard`'s X comes from the nondeterministic hierarchy theorem. It lies in NTIME(s^{c_1+1}), but its complement is not known to lie in NTIME(poly(s)).
  * `cor:time:hard` concerns only positive data (derivations of φ_w for w ∈ X, theories consistent with Γ_{f_X}).
* *What is true [proved].* The one-sided variant follows from Prop 6.1 unchanged.
  * Use a verifier that only accepts. Then X_rej = ∅, and Model 1 of Prop 6.1 sets R to X on words. So T_M ∪ Γ_{f_X} is consistent.
  * Every φ_w with w ∈ X has a derivation of size O((τ + |w|)²), with τ = s^{c_1+1}.
  * This gives tightness up to polynomials for `cor:time:hard` and for `prop:time:sigma`(b), (c).
* *Fix.* Add the one-sided statement and derive the tightness sentence from it.

**m6. Prop 4.5 discussion (line 318) and §8 problem 7: "Under reading (b), the comparison with S … still [open]" is too broad.**
* *Problem.* It is open only at polynomial material budgets. For budgets g(m) = 2^{O(m)} it is settled unconditionally **[proved, given Prop 4.5's construction, time-followup Cor 4.3(a) and Thm 3.1(ii)]**.
  * Prop 4.5's X ∈ DTIME(2^{O(m)}) defeats S: S loses n − O(1).
  * The Craig hypothesis A^C_{f_X} has polynomial membership (`prop:time:cheap`) and derivations, hence material, of size ≤ γ(τ + 1)(m + 4) with τ = 2^{O(m)}.
  * So AI^b[poly, 2^{O(m)}] has bounded loss on that sequence.
  * (Under (a1) the notes already settle it at linear budgets, by Prop 4.5.)
* *Fix.* Say "open at polynomial budgets".

**m7. Remark 6.4, item 1: "ρ_{f,n} realises Σ_n-sound assigners but with unbounded derivation size (`rem:time:upper`)".** `rem:time:upper` says only that the size "is not bounded here". Unboundedness is not established. *Fix.* Write "with derivation size not bounded (`rem:time:upper`)".

**m8. §0.1: "Restricting to finite template theories loses nothing on literal data."**
* *Problem.*
  * By Remark 6.4(2) the description length grows linearly: ℓ(T_V) ≤ ℓ(T_{U₀}) + a|V| bits, not |V| + c.
  * "Nothing" is true for the fit classes and for derivation size up to polynomials (Cor 6.2), and for literal consequences.
* *Fix.* Say so.

**m9. Remark 6.4, item 3, understates Prop 6.1.**
* *Problem.* Prop 6.1 needs only a verifier that halts on every input. Every consistent computable literal assigner f is f_V for V(w, c) := "c is a halting computation of f on w, with its output".
  * So the literal-consequence variant of model §10 problem 15 is answered positively for **all** consistent computable literal assigners.
  * Derivation size is then polynomial in f's running time.
  * The restriction "with polynomial-time certificate verification" matters only for polynomial derivation size.
  * This also sharpens §0.2's S4 row: on literal data, finite Horn templates carry the unpenalised collapse, as well as the certificate version.
* *Fix.* State the general form.

**m10. Remark 5.5: "It is necessary for codes that encode every derivation."**
* *Problem.* This is asserted without status or proof. It is presumably a counting argument: there are ℓ^{Θ(ℓ)} derivations of symbol size ℓ up to renaming, through index and line-number choices. RLg-m11 already notes that the remark needs the closure hypothesis.
* *Fix.* Give the count and mark the sentence [proof sketch], or drop it.

**m11. Example 5.6 and `c2`.**
* *Wording.* "The deterministic route (trial division …) needs up to 1.9·10⁹ steps". Trial division is one deterministic route, not "the" route. Factoring has much faster deterministic algorithms, so "needs" reads as a lower bound that is not claimed. *Fix.* Write "trial division needs".
* *The `c2` output column "trial-div steps".* It is computed as (lpf + 1)/2 (`c2_lpf_certificates.py`, line 161). When N is prime, as some "random" cases are, trial division needs only about √N/2 steps.
  * The 80-bit "random" row reports 5.652·10²³, about 2^79. That is the count for a prime N, where the correct figure is below 2^40 ≈ 1.1·10¹².
  * The notes quote only the semiprime rows, which are right because lpf ≤ √N there.
  * *Fix.* Use min(lpf, ⌊√N⌋)/2 in `c2`.

**m12. Theorem 5.2: the constant c″ is not defined in the statement.** It is c + log₂(1/W_{FIcert^σ}(∅)). Since W(∅) does not depend on the rates, the same c″ serves in Cor 5.4. *Fix.* Define it once.

**m13. Proposition 6.1(iii): the line count is 2τ + 3, not 2τ + 4.** I agree with RLg-m8. My check confirms it for machines that move left and write (`rc2`). RLg-m8 also notes that `c5` never exercises left moves or writing. `rc2` closes that gap; see the confirmations.

**m14. References.**
* *Missing.*
  * Book–Greibach–Wegbreit (1970), for m4.
  * P. Elias, "Universal codeword sets and representations of the integers", *IEEE Trans. Inform. Theory* 21 (1975) 194–203, for the γ code of Def 5.1 [known].
  * Cook–Reckhow, *JSL* 44 (1979) 36–50, for Thm 3.1, as RLg-m12 and RP-m19 ask.
* *Checked from memory, bibliographic data correct as far as I recall (not checked against the sources).*
  * Chandra–Kozen–Stockmeyer, *J. ACM* 28(1) (1981) 114–133. The form used, ASPACE(s) = ⋃_c DTIME(2^{cs}) for s ≥ log n, is the paper's main theorem on alternating space.
  * Pratt, *SIAM J. Comput.* 4 (1975) 214–220.
  * Craig, *JSL* 18 (1953) 30–32.
  * Hartmanis–Stearns, *Trans. AMS* 117 (1965) 285–306.
  * Hennie–Stearns, *J. ACM* 13 (1966) 533–546.
  * Seiferas–Fischer–Meyer, *J. ACM* 25 (1978) 146–167.
  * Žák, *Theoret. Comput. Sci.* 26 (1983) 327–333.
* *Hänni's note.* Prop 4.5's reading of `hanni-polytime-solomonoff.md` is accurate. The note states per-step time p(n)·log n with state reuse ("S … needs to be doing predictions in sequence, reusing some stuff calculated when predicting bit n"), and a RAM-model caveat for the apples-to-apples version. Replaying from scratch is therefore Σ_{i≤j} p(i) log i = poly(j). The notes correctly mark this as Hänni's claim, not checked.

---

## Claims I confirmed

I checked each item line by line. Where a script supports it, the script is named.

**§5, the soft version (S3).**
* *Definition 5.1, semimeasure property.* For a consistent hypothesis at most one of φ, ¬φ has finite cost, and every factor is ≤ 1. W(∅) does not depend on κ or μ.
* *Theorem 5.2(a).*
  * V_p decodes c followed by Code(φ) and the end tag. It is consistent and injective, and |V_p| ≤ |p| + c.
  * λ ≤ ℓ^bit − |φ^b|_bit (in fact ≤ ℓ^bit − |φ^b|_bit − 2, M1).
  * The time bound t⁺ (polynomial line checks and t on axiom lines) holds.
  * This holds for every decider, with no closure (M3, addition 2).
* *Theorem 5.2(b).*
  * θ_c = Z → (C_c → Z) is an A1 instance of size |c| + 14, and c is read off uniquely, since |C_c| = |c| + 4.
  * Cn(B ∪ A_V) = Cn(B ∪ Γ_{f_V}).
  * Symbol size 2|c| + 2|φ^b| + 29. I recomputed the code length by hand:
    * tokens 2(|c| + 14)b_s + b_s + 2|φ^b|_bit;
    * twelve index bits (six index nodes per θ_c, θ_c written twice);
    * tags 2 + 2 + 2;
    * MP premises γ(1) + γ(2) = 1 + 3;
    * end tag 2.
    * Total: 2b_s|c| + 29b_s + 2|φ^b|_bit + 24, as stated and as `c4` measures.
  * e_1 = 31b_s + 24 and r = max(2b_s, 2 + e_1) = 31b_s + 26 make both inequalities of (b) correct.
* *Theorem 5.2(c)*, given closure (RLg-m11).
* *Proposition 5.3(i)–(iii).*
  * The sum bound Σ_{i≤n}|w_i| ≥ (n/2)(log₂ n − 3) holds with no violation for n < 5000 and at the sampled n up to about 8·10¹¹. In fact n(log₂ n − 2) holds for n < 5000 (`rc1`, part 4).
  * (iii) is correct, and is sharpened by R1(i).
* *Corollary 5.4.* The three inequalities, by the algebra W_{FIcert^σ_{κ,0}}(D) = 2^{κΣ|φ_i|_bit}·W_{FIcert^σ_{κ,κ}}(D) and (b)'s first inequality. The interpretation is corrected in m1.
  * The remark that a datum which is not an axiom needs symbol size ≥ 2|φ^b| − 1 is correct: the last line together with its major premise or its Gen premise.
* *Example 5.6.* The certificate and work figures match `c2_lpf_certificates.out` (0.941·b² bits, 0.0681·b³ multiplications). The Pratt reference is correct. See m11 for the trial-division column.

**§3, reading (b), consequences of time-followup Thm 4.2 and Cor 4.3.**
* *Theorem 3.1(i), (ii).* Material ≤ size; size ≤ (M + |φ^b|)² by Cor 2.3; |φ^b| ≤ |φ| + 1. The compatibility relations are nested hypothesis by hypothesis.
* *Theorem 3.1(iii)*, given (F1), a finite L and a polynomial-time B (M3, m3). The composition with Thm 4.2(a), (b) is otherwise correct. In particular, the derivations of Thm 4.2(b) have material ≤ size ≤ d^#.
* *Corollary 3.2, fit class NP ∩ coNP at polynomial budgets*, given (F1) or RLg's truncation sketch.
  * ⊆ by `thm:time:ntime` for X and for its complement, after Thm 3.1(i).
  * ⊇ by Thm 4.2(b), with a tagged verifier for X and its complement and polynomial (m + 2)^j ≥ d^#.
  * The separation from FIcons_τ at a hierarchy gap holds with the slack of RL-m6 and RP-m8, as the notes say.
  * The polynomial-budget dichotomy holds per sequence (M2).
* *Corollary 4.4(iii).* For X ∈ EXPTIME ∖ P, every (f, k) of FIcons_poly eventually mislabels, so by dominated convergence its loss → ∞. AI^{a1}[poly, poly] fits X by (i) ⊇, which rests only on Prop 4.3 and CKS and is not touched by M3. This is a per-sequence separation, and it is unconditional.
* *Corollary 4.4(iv).* Material ≤ g implies that every instance is ≤ g. RLg-m6 sharpens the iff to NP ≠ EXPTIME, and I agree.
* *Fact 1.4.* Dominated convergence needs summable weights and that compatibility is inherited by prefixes. Both hold for every hard inducer here; time-followup `notes-final.md`, Lemma 1.6, states it so.

**§4.1, Proposition 4.5.**
* β_j for j ≤ n is computed in Σ poly(j) steps, and n(w) < 2^{|w|+1}. So X ∈ DTIME(2^{O(m)}) ⊆ ASPACE(O(m)) [CKS].
* Clocked alternating machines halt on all paths. Prop 4.3 then gives a linear budget, with no logical axioms used.
* The loss bound uses only the choice rule of time-followup Thm 3.2(c).
* The application to Hänni's S is accurate to his note (m14).
* The converse, through `prop:time:fiall`, holds for every reading, since it uses only consistency.

**§6, templates (S4).**
* *Proposition 6.1 (i)–(iii)*, under the normal form of RLg-m8. **[computed: `referee_complexity/rc2_templates_left.out`]**
  * I wrote the template theory from the text of Prop 6.1, not from `c5`: Start; one template per (state, read triple, left neighbour or left end of each left-moving tape); Accept; Reject.
  * I used two verifiers that `c5` cannot represent:
    * PAL (palindromes): it copies the input behind a marker, rewinds the work tape with left moves, and compares while moving left on the input, down to its left end.
    * POW2 (|w| a power of 2): it keeps a binary counter and overwrites 0 ↔ 1 in the middle of the work tape.
  * Results:
    * *PAL.* 456 transition templates for 7 states. Of 4092 (word, certificate) pairs with |w| ≤ 9, 1023 are decided (93 accept, 930 reject). The runs make 11526 left moves, 93 of them at the left end of the input tape.
    * *POW2.* 580 transition templates for 9 states. 1023 pairs are decided (278 accept, 745 reject). The runs make 14494 left moves and 10676 overwrites of non-blank cells.
    * *Both machines.*
      * Every derivation is valid for kcore and for rk.
      * Verdicts and last lines are right.
      * The template run equals the array simulation at every step, in state and in the decoded tapes.
      * No configuration matches two templates.
      * The line count is 2τ + 3 in every case.
      * Max size/(τ + |w| + |c| + 1)² is 10.92 (PAL) and 14.25 (POW2).
      * Junk inputs: 6000 runs per machine, with 0 decided runs that disagree with M on the word prefixes and 0 junk inputs with both verdicts.
    * *Template count.* The counts are linear in |Q| (about 64 per state, from the read triples), as (i) says.
    * *A refinement of RLg-m8.* Templates are generated for every (state, read triple) at which δ is defined, reachable or not. So the normal form must hold for every defined transition, not only along runs. My generator rejected one unreachable POW2 transition, a right move of the input head on a blank, until δ was restricted there.
* *Proposition 6.1(ii), the models.*
  * Model 1 (R = X_acc on words; on junk, R iff some run accepts) satisfies Accept, Reject and Γ_{f_V}. On junk the reason is that V outputs ⊥ outside {0,1}* and that f_V is consistent.
  * Model 2 gives the converse for rejections.
  * Determinism holds because distinct templates have disjoint patterns. `rc2` found no configuration matching two templates.
* *Corollary 6.2(i)*, by `thm:time:ntime` for X and for its complement, given (F1), which template instance sets satisfy.
* *Corollary 6.2(ii)*, with the transcript certificate (m4).
* *Corollary 6.2(iii)*, with κ ≥ 1 for the graded score (RLg-m9).
  * For L1^σ: P^σ_T ≥ Pr(π)e^{−κ|π|}, because Z^σ_T ≤ Z_T ≤ 1.
  * The tree has τ + 2 citations whose bodies have size O(τ + |w| + |c|), and each body node costs at most ln(1/q_min). So −ln P^σ_T = O((τ + |w|)²).
* *Corollary 6.3*, for deterministic machines: the same models, and lines of size O(s + |w|). The upper bound needs Thm 4.2 and (F1), which template instance sets satisfy.

---

## Scripts written for this report

| script | what it checks | result |
|---|---|---|
| `referee_complexity/rc1_rate_one.py` → `.out` (deterministic) | M1: own \|χ\|_bit against kcore and rk (2249 formulas); one-line derivations of ¬φ_w checked in kcore and rk, code length = \|φ_w\|_bit + b_s + 4; the gap ℓ_AI − ℓ_FIcert_{κ,κ} on D^∅ and D^all up to n = 2^17 for κ = 1, 0.1; Prop 5.3(i)'s sum bound; the constants e_1, r | 0 mismatches; gap per datum → κ(b_s + 4) = 8.0 (D^∅) and 4κ = 4.0 (D^all) at κ = 1; sum bound holds; r = 31b_s + 26 |
| `referee_complexity/rc2_templates_left.py` → `.out` (seed 314159) | Prop 6.1 from its text, for two machines with left moves, left-end moves and overwrites: K-validity (kcore and rk), verdicts, run = array simulation, line count, size ratio, determinism, junk inputs | all checks pass for both machines: 0 invalid derivations (kcore, rk), 0 verdict or simulation mismatches, 0 configurations matching two templates, 0 junk disagreements; lines = 2τ + 3; size/(τ + \|w\| + \|c\| + 1)² ≤ 14.25; 26020 left moves (93 at the left end), 10676 overwrites |
