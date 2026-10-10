# Referee report (proof theory): `short-derivations/notes.md`

*Adversarial referee of `notes.md`, which builds on `../time-followup/notes.md`. Focus: proof theory. That means the subformula lemma (S2) for the paper's calculus K and its exact bound, and the readings (S1) of "derivations from short axioms" in each setting (two-sorted schema, one-sorted bounded repair, reflection sentence, templates). I did not edit `notes.md`.*

*My checks are in `referee_logic/`. Each is seeded and writes `<name>.out` next to itself. `rk.py` is a second implementation of K, written for this report. It does not import the notes' `checks/kcore.py`, and it uses a different A4 recogniser: it reads the substituted term off the first occurrence, substitutes, and compares. I re-ran the notes' `c1`–`c5` on copies, and all five outputs are byte-identical to the committed `.out` files.*

## Verdict

**No fatal issue.** The subformula lemma (S2) is correct, and so is its use for reading (b).

* *Confirmed claims.* Lemmas 1.1, 2.1, 2.2, Corollary 2.3 and Proposition 2.4 are correct as proved. I checked them line by line and also by an independent exhaustive search with a matching computation (`r1`).
* *A sharper bound.* The bound of Lemma 2.2(iii) can be halved, and the halved bound is attained (m3).

**One major issue (M1).**

* *The gap.* A parameter p_N counts as one symbol whatever its index N. But Definition 1.2 lets a hypothesis be any decider, and a decider can make membership depend on the index. So an index can carry a certificate that no size measure charges.
* *Where the notes guard against it.* They assume closure of the axiom set under renaming the parameters, but only in Lemma 4.1, Theorem 4.2 and Theorem 5.2(c).
* *Where they then drop it.* The assumption is dropped in:
  * Theorem 4.2(iv);
  * Corollary 4.4(i) "⊆", (ii) and (v);
  * Theorem 3.1(iii), through time-followup Theorem 4.2(a);
  * Remark 5.5;
  * the §0.1 answer and the §4.3 table.
* *Effect on those claims.* With all deciders allowed, Corollary 4.4(v) and Theorem 3.1(iii) would imply open inclusions of NP ∩ coNP in fixed exponential classes. So they cannot be proved as stated.
* *Fix.* A one-line restriction in Definition 1.2 repairs everything: B ∪ A_p must be closed under permutations of the parameters. Every construction in the notes satisfies it.
* *Upstream.* The same gap is in the proof of the paper's `thm:time:ntime` and in time-followup Theorem 4.2(a).

**Twelve minor issues.** In summary:
* The proof of Proposition 4.7's last sentence does not give it.
* Reading (a2) is vacuous for every finite theory, which the notes do not say.
* There is an exact constant 1/2 in Corollary 2.3.
* Prop 6.1's coding needs an unstated normal form, and `c5` does not exercise left moves.
* The rest are scope, wording and references.

---

## Issues

### Fatal

None found.

### Major

**M1. Parameter indices are an unpriced channel. The (a1) clock 2^{O(h log h)}, Theorem 3.1(iii) and the fit-class upper bounds are proved only for axiom sets closed under renaming parameters, but Definition 1.2 admits every decider.**

* *Claims.*
  * Theorem 4.2(iv) (line 249): "Hence the fit class of AI^{a1}[t, h] on literal sequences … is contained in DTIME(2^{O(H log H)}·(t(H) + 1)^{O(1)})".
  * Corollary 4.4(i) "⊆", (ii) and (v) (lines 292–296). In particular (v): "the fit class of AI^{a1}[poly, h] is contained in DTIME(2^{O(h log h)})".
  * Theorem 3.1(iii) (line 194): W_{AI^b[t,g]}(D) ≤ 2^c·W_{FIcert[t⁺, G']}(D) with G' = βG log₂(G + 2).
  * Remark 5.5, third bullet.
  * §0.1: "So up to renaming parameters only 2^{O(h log h)} formulas can occur".
  * The (a1) and (b) columns of the §4.3 table, as statements about the inducers.
* *Problem.* The size convention gives a parameter p_N size 1 whatever N is (§1.1; `app-time.tex`). The bit code of Definition 5.1 does pay for N (an Elias-γ code), and the notes know this: Lemma 4.1, Theorem 4.2 and Theorem 5.2(c) assume that Ax is closed under permutations of the parameters. But Definition 1.2 (line 77) and time-followup Definition 1.3 let a hypothesis be any decider p of any A_p ⊆ S, and nothing makes A_p closed under renaming.
  * *Where the assumption is used.* Theorem 4.2's algorithm needs it to test "χ ∈ Ax iff can(χ) ∈ Ax".
  * *Where it is silently dropped.* Theorem 4.2(iv) concludes about all hypotheses of AI^{a1}[t, h]. Theorem 3.1(iii) inherits time-followup Theorem 4.2(a), whose step "a derivation of symbol size s has a bit code of length at most β·s·log₂(s + 2)" is false when parameter indices are unbounded.
* *Counterexample hypothesis.* Let V be any verifier with time t_V and certificates of length L(m). Put

  A^par_V := {¬φ → ¬(p_N = p_N) : V(φ, cert(N)) = acc} ∪ {¬¬φ → ¬(p_N = p_N) : V(φ, cert(N)) = rej},

  where cert(N) is the binary of N without its leading 1.
  * *Consistency.* The closure of a member is ∀x(¬φ^b → ¬x = x), which is logically equivalent to φ^b. So Cn(A^par_V) = Cn(Γ_{f_V}), which is consistent whenever f_V is.
  * *Membership time.* Membership is decided in time polynomial in the node count, with degree depending on t_V and L. In preorder φ comes before the index: parse φ, read at most L(|φ|) + 2 bits of N, then run V.
  * *Derivation.* Every datum has a 9-line K-derivation: reflexivity, then A4 with t = p_N, then MP, A1, MP, the member, A3, MP, MP.
  * *Sizes.* The derivation has symbol size 9|φ^b| + 54, material 5|φ^b| + 40 and largest instance 3|φ^b| + 13. All three are exact and independent of the certificate length. The bit code grows linearly with the certificate.
* *Evidence.* `referee_logic/r2_parameter_channel.out`, for a toy verifier whose certificates must have length |w|² or |w|³:
  * Both the notes' `kcore.check_derivation` and `rk.check` accept the derivations.
  * The size formulas hold with 0 deviations.
  * Every renaming of the parameter to p_0, …, p_5 is rejected (0 of 72 accepted).
  * The decider's work is below 0.04·|χ|^{deg+1}.
  * Code length / (β·d·log₂(d + 2)) grows to 5.8 at |w| = 12 with β = 8 (generous) and keeps growing.
* *Consequences.*
  1. *Node-count reading.* This is the notes' reading: time_p(χ) = O(t(|χ|)) with |χ| the node count.
     * Take any X ∈ NP ∩ coNP. A^par_V for verifiers of X and of its complement is (a1)-compatible with all of D^X with h(m) = 3m + 16, and has polynomial membership time.
     * If Corollary 4.4(v) held for all deciders, it would give X ∈ DTIME(2^{O(m log m)}), so NP ∩ coNP ⊆ ⋃_c DTIME(2^{c·m log m}).
     * Likewise, Theorem 3.1(iii) with g(m) = 5m + 45 gives G' = O(m² log m). By Fact 1.4 a single FIcert[t⁺, G'] verifier would then fit D^X, so NP ∩ coNP ⊆ ⋃_c DTIME(2^{c·m² log m}). Time-followup Theorem 4.2(a) gives the same with m log m.
     * These inclusions are open. They are not known to hold or to fail. So the claims cannot be proved as stated, and they are false if the inclusions fail.
     * Theorem 4.2(iv)'s explicit bound fails in the same way. Corollary 4.4(ii), the unconditional separation, rests on (iv).
  2. *Bit-length reading.* Suppose membership time were measured in the bit length of the input, which includes log N. Then A^par_V with the trace of a 2^{2^m}-time decider as certificate puts some X ∈ DTIME(2^{2^m}) ∖ DTIME(2^{poly}) into the fit class of AI^b[poly, linear] and AI^{a1}[poly, linear]. That refutes Corollary 3.2 and Corollary 4.4(i) "⊆" unconditionally, and with them the paper's `thm:time:ntime`. The notes avoid this only through the node-count convention, which should therefore be stated as essential.
* *What survives.* In the node-count reading, the coarse fit classes (EXPTIME for (a1), NP ∩ coNP for (b), at polynomial budgets) are very probably still right. This is my proof sketch, not in the notes.
  * A decider with time C·t(n) reads at most C·t(n) input cells. So two indices that agree on their first C·t(H) bits, and are both longer, are indistinguishable to it.
  * Within each such class, an injective renaming preserves every membership answer.
  * Hence D_H can be computed over parameters with O(t(H) + log(#lines))-bit indices, in time 2^{O(H·t(H))}-ish.
  * The guess-and-check of `thm:time:ntime` can likewise guess truncated indices.
  * The deterministic clock 2^{O(h log h)} of Corollary 4.4(v) and the budget relation of Theorem 3.1(iii) do not survive.
* *Fix.*
  * **(F1), recommended.** Add to Definition 1.2 (and propose for time-followup Definition 1.3 and `def:time:inducers`) that B ∪ A_p is closed under permutations of the parameters. The parameter-free case is included, and so is any set read under universal closure. Every construction in the notes satisfies this: A_f, A^bd_f, A^tr_f, A_M, A_V (θ_c), Craig sets on parameter-free data, PA + ρ_{f,n}, and template instance sets. Theorem 4.2, Corollary 4.4, Theorem 3.1(iii) and Remark 5.5 then stand as written. State in one sentence why: the semantics of a parameter is its closure, so its name should carry no information.
  * **(F2), alternative.** Price p_N at 1 + ⌈log₂(N + 1)⌉ symbols in sizes, in budgets and in the membership-time argument. This needs rework. Lemma 2.2(i) then bounds a Gen line by H·(1 + the largest index length in I), not by H, because abstracted parameters are priced in the line but not in the instance. Theorem 4.2's count also changes.
  * Flag upstream as well: the proof of the paper's `thm:time:ntime` ("guess a derivation of symbol size at most ℓ") must bound the guessed indices, and time-followup Theorem 4.2(a) needs (F1) or a certificate length of order d·log d + d·t(d).
  * Note on (F1): for data that contain parameters, a renaming-closed Craig set needs all renamings of f's labels. Its membership is decidable only if f is renaming-invariant. Nothing in the notes uses such data.

### Minor

**m1. Proposition 4.7, last sentence: the proof does not give it.**
* *Claim* (line 344). "On literal sequences, with h(m) ≥ a'm + b″ and any polynomial membership time, the fit class of (a2) and of (b2) is every decidable X." The proof says: "add the finitely many short data, those whose budget is below a|f| + …, to the axioms as themselves".
* *Problem.* In Hänni's schema the index of f sits in every member Acc_f(⌜φ⌝) → φ, so every member has size a|f| + a'|φ| + b′. With h(m) = a'm + b″ of the same slope, the deficit a|f| + b′ − b″ is the same for every m. If it is positive, every datum is over budget, not finitely many. Only finitely many programs f have a|f| ≤ b″ − b′, so the construction fits only finitely many X, up to finite variants.
* *Fix.* Either assume h(m) − a'm → ∞, as at polynomial budgets of degree ≥ 2, or change the construction. Two changed constructions work:
  * Put f's code into one separate constant-size axiom, as the trace schema could. That axiom is then over budget only on finitely many short data.
  * Use the finite theory of m2.
  The statement is true, but the given proof does not prove it.

**m2. Readings (a2) and (b2) are vacuous for every finite theory. This is the simplest reason they are no time limit, and the template setting under (a2) is not addressed.**
* *Claims.*
  * §0.2, S1 row: "Confirmed for (a2) in two sorts, and in one sort with B ⊇ Q and a relation symbol unused by B and the data".
  * §4.3 table, last row: "all decidable (two sorts, or fresh C)".
  * §6 treats only (a1) and derivation size inside the template class (Cor 6.2, 6.3).
* *Problem.* A finite axiom set has nonlogical instances of constant size, so (a2) with h ≥ that constant, and (b2) with g ≥ its total size, constrain it not at all. On literal sequences:
  * Take the Horn theory T_M of Proposition 6.1 for a decider of X (Cor 6.3's machine), with each template universally closed: one ground DT template per sentence.
  * It fits every decidable X with B = ∅ and no arithmetic, because the model of Prop 6.1(ii) satisfies every closed instance and hence the closures.
  * It uses fresh symbols (C, pr, s2), as Prop 4.8 does.
  So the qualifiers "two sorts" and "B ⊇ Q" are not needed for the literal fit class. Props 4.7 and 4.8 are needed only for the full equivalence with FIcons on arbitrary sentences. Inside the template class, (a2) is likewise no time limit, through ground universal templates.
* *Evidence.* `referee_logic/r4_a2_finite_theory.out`. The 57 templates of `c5` were turned into 57 universal sentences, the largest of size 49. On 8 runs (|w| ≤ 15, accept and reject):
  * every derivation is valid for kcore and for rk;
  * the largest nonlogical instance is ≤ 49 and the nonlogical material ≤ 320 throughout;
  * the logical A4 instances grow, up to 202.
* *Fix.* State this observation in the S1 row, under Remark 3.3, and in §6 (templates under (a2)). Keep Props 4.7 and 4.8 for arbitrary data.

**m3. Lemma 2.2(iii), Corollary 2.3 and Proposition 2.4: the exact constant is 1/2, and the extremal family is a vacuous Gen chain.**
* *Claims.*
  * "size(π) ≤ Σ_{α ∈ J} F(α) ≤ Σ_{α ∈ J} |α|² ≤ (M(π) + |φ|)²" (line 109).
  * Prop 2.4: "the exponent 2 cannot be lowered", with size/(M + |φ|)² → 1/(2(|a| + 1)) ≤ 1/4.
* *Problem.* The bound is not wrong, but it is loose by a factor of 2.
  * F(α) = Σ_u (number of formula-node ancestors of u, u included) ≤ |α|(|α| + 1)/2: the i-th node in breadth-first order has depth at most i. So size(π) ≤ Σ_J |α|(|α| + 1)/2 ≤ (M + |φ|)(M + |φ| + 1)/2.
  * This is attained with M ≫ |φ|. Take r (axiom), ∀r, …, ∀^k r (vacuous Gens), β := ∀^k r → b (axiom), and b (MP). This derivation is normal, and size/(M + |b|)² → 1/2.
* *Evidence.* `referee_logic/r3_sharp_constant.out`.
  * F ≤ |α|(|α| + 1)/2 holds for all 51485 closed formulas of size ≤ 9 in the test signature (511 equality cases) and for 20000 random ones.
  * For the family, size/(M + |b|)² = 0.4843 and size/ΣF = 1.0000 at k = 400.
* *Fix.* State the sharp form. Add the family as a candidate for open problem 5 (least-size tightness). I did not prove that ℓ_min is of order k² for it.

**m4. Remark 2.5 and the §0.2 S2 row: "Repeated lines matter only for the line count (ii)."**
* Repeated lines also break the size bound (iii): size is a sum over lines. The notes' own `c1` example shows this: P(0) cited 40 times and then a vacuous Gen gives 41 lines of total size 83, while ΣF over J is 7.
* *Fix.* "Repeated lines matter for (ii) and (iii); the per-line bound (i) needs only pruning."

**m5. Corollary 4.4(v) and open problem 2: a scope slip and a misattributed log factor.**
* *Scope slip.* "every X ∈ DTIME(2^{h}) is in the fit class of AI^{a1}[poly, c_X·h]", justified by "DTIME(2^{h}) ⊆ ASPACE(O(h)) for h ≥ log m". This fails for sublinear h. Every derivation of φ_w contains an axiom instance of size ≥ |φ_w|: the datum itself, or an instance containing the major premise of the last MP (Lemma 2.1; an atomic datum is not a Gen conclusion). Prop 4.3 also needs s(m) ≥ m. *Fix:* assume h(m) ≥ m and that h is space-constructible.
* *Misattributed log factor.* "Closing the log factor is [open]; it comes from counting a parameter as one symbol". Open problem 2 adds: "Counting parameters by their bit length should remove the log". But de Bruijn indices alone already give 2^{Θ(H log H)} parameter-free formulas of size H. For example, H/3 atoms Q(#i, #j) under H/2 quantifiers carry about (2H/3)·log H bits. Pricing parameters does not remove that. *Fix:* attribute the factor to indices and parameters, and drop the proposed remedy, or price indices too.

**m6. Corollary 4.4(iv): the stated relation is weaker than the truth.**
* *Claim.* "The two readings have different fit classes iff NP ∩ coNP ≠ EXPTIME, which is [open] (it follows from NP ≠ EXPTIME)".
* *Problem.* NP ∩ coNP = EXPTIME iff EXPTIME ⊆ NP iff NP = EXPTIME. The middle step holds because EXPTIME is closed under complement and NP ⊆ EXPTIME. So the condition is *equivalent* to NP ≠ EXPTIME.
* *Fix.* Say "iff NP ≠ EXPTIME".

**m7. Proposition 4.6(ii) omits the hypothesis that f is a literal assigner.**
* Part (i) restricts to literal assigners and explains why. Part (ii)'s proof says "The side condition of Prop 2.5(c) holds on literal data with B = Q". That is true only if f decides nothing else: a quickly accepted ∀x R(x) would break it.
* *Fix.* Repeat the hypothesis in (ii) and in the §4.3 table row.

**m8. Proposition 6.1 and its check.**
* *An unstated normal form.* A tape is (l, r) with cells over s0, s1, s2 and e for "blank and end". A blank cell left of the head cannot be represented. So M must never move right from a blank cell without writing a non-blank symbol. `c5` asserts exactly this ("machine moves right on a blank"). This is harmless (write 2 and let M treat 2 as blank), but Prop 6.1 should state it.
* *Line count.* (iii) says "2τ + 4 lines". The derivation has 1 + 2τ + 2 = 2τ + 3 lines, as `c5` itself computes: (len − 1)//2 − 1 = τ.
* *What `c5` tests.* The verifier in `c5` never moves left (`NotImplementedError("left moves are not used by this M")`) and never uses the work tape. So "computed for one verifier" covers only right-moving reads. The left-neighbour templates, writing, and the left-end case are untested. *Fix:* say so, or add a verifier that moves left and writes.
* *Certificate alphabet.* X_acc quantifies over certificates over {0, 1, 2}, while Cor 6.2(ii) uses a binary alphabet. *Fix:* say that V outputs ⊥ on certificates containing 2.

**m9. Corollary 6.2(iii): "Z_T ≤ 1" for the graded score needs κ ≥ 1.**
* `rem:model:graded` proves Z_T ≤ 1 only for κ ≥ 1 (Kraft over a prefix code). For κ < 1 the sum can diverge.
* *Fix.* State κ ≥ 1, as in the paper.

**m10. Remark 2.7: "Proposition 2.6 applies to them verbatim [proved]".**
* The lower bound chooses X outside NTIME(s^{c}), where c depends on the checking degree of the proof system. So X has to be re-chosen for natural deduction or sequent calculus. Also, "material" changes meaning there (nonlogical premises only).
* *Fix.* "applies, with X depending on the proof system".

**m11. Remark 5.5 omits Theorem 5.2(c)'s closure hypothesis.**
* "With symbol cost, as in L1^σ, (a) holds only up to the factor β log₂(ℓ + 2) in the exponent (Theorem 5.2(c))." Without closure under renaming, the factor is unbounded: `r2`'s hypothesis has symbol cost linear in |φ| and unbounded bit cost.
* *Fix.* Add "for axiom sets closed under renaming parameters". (F1) of M1 makes this automatic.

**m12. References and labels.**
* *Missing references.* Theorem 3.1 rests on time-followup Theorem 4.2(a), which is the standard fact that bounded-size provability from a polynomial-time axiom set is an NP predicate. Cite Cook and Reckhow, *JSL* 44 (1979) 36–50, as the time-followup referee asked (its m19). Lemma 2.2 is a form of the folklore subformula property of Hilbert-style derivations. Saying so costs nothing.
* *Notation.* "DT°" (Cor 6.2, 6.3) is not the paper's notation, which is `\DTF`, written DT with a superscript F. Use the paper's symbol or define DT°.
* *Chapter references.* The Mendelson, Smith and Hájek–Pudlák chapter references remain unchecked, as the notes say. The time-followup referee's m16 (Δ₀, not Δ₁, definability of computations, probably Ch. V of Hájek–Pudlák) applies to Prop 4.8's "Δ₀ definition of the step relation" as well.

---

## Claims I confirmed

I checked each item line by line. Where a script supports it, the script is named.

**Lemma 1.1 (normal form).** De-duplication keeps first occurrences, so every redirected citation points to an earlier line. Cutting at φ and keeping its ancestors gives a normal derivation with I(π') ⊆ I(π) and no larger size. `r1`: 2400 normalisations, none invalid or non-normal, and none enlarges I or the size.

**Lemma 2.1.** MP's major premise has root →, and a Gen conclusion has root ∀. So by induction every axiom or MP line is a literal subformula of an axiom line at or before it. No hypothesis on the derivation is needed. `r1`: 30132 raw axiom and MP lines, 0 exceptions.

**Lemma 2.2, every step.**
* *Chain existence.* In a normal derivation every non-last line is used later. A Gen line cannot be a major premise. So the forward chain through Gen steps ends in an MP minor premise or in the last line.
* *The observation.* If λ sits at v and the subtree at v has no dangling index, then λ equals that subtree, because every abstracted occurrence becomes an index pointing above v.
* *Injectivity, all three cases.* In the Gen–Gen case, γ'_k sits at the node u that lies k levels above v, with k' − k abstractions. This holds by the definition of "sits", composed along the chain. The subtree at u is the line e, so γ'_k = e = γ_k. Unique justifications then walk both chains back down to γ = γ'.
* *Bounds.* |λ| = |α_{o(λ)}|, since abstraction replaces parameter nodes by index nodes one for one.
* *Evidence* (`r1`), on 2400 normal derivations (Gen chains up to length 5, vacuous Gens, Gen lines as minor premises, A2/A3/A5/substitutivity instances, nonlogical axioms with parameters) plus 12 targeted derivations in which one Gen line is used both as a Gen premise and as a minor premise (the random generator never kept such a line after normalisation):
  * The proof's map o, built exactly as in the proof with random chain choices, satisfies "sits" in every case and is injective in every case.
  * *Independently of the proof's construction:* an exhaustive search for the nodes of J at which each line sits, followed by a maximum bipartite matching, saturates every line. So the existence claim holds without reference to the construction.
  * Bounds (i), (ii), (iii) and (M + |φ|)²: 0 violations.
  * Without normality, 2079 of 5589 raw Gen lines sit nowhere.

**Remark 2.5's Gen-chain example.** It is valid and normal. The middle line ∀Q(#0, p1) is a literal subformula of nothing in I ∪ {φ}, and sits at exactly one node with 1 abstraction (`r1`). The named-variable variant gives k = 0 everywhere, by the same proof.

**Corollary 2.3.** M_min ≤ ℓ_min ≤ (M_min + |φ|)² (sharp form in m3).

**Proposition 2.4.** The closed forms of size and M are reproduced exactly for k ≤ 200 (`r1`), and size/ΣF → 1.

**Proposition 2.6.** The order of choices is sound:
* the degree e of A^tr_f's membership does not depend on f;
* then c_e is fixed, and X ∉ NTIME(s^{c_e}) is chosen;
* then f := a decider of X.
The square-root lower bound on material follows from Corollary 2.3. Q ∪ A^tr_f is parameter-free, so M1 does not touch this proposition.

**Theorem 3.1(i), (ii).** Both nesting inequalities hold, hypothesis by hypothesis. Part (iii) needs M1's (F1).

**Corollary 3.2.** It holds under (F1), and in the node-count reading also without it, given the repaired proof of `thm:time:ntime` sketched in M1.

**Lemma 4.1 (renaming; canonical closure).**
* Part (a) is correct for injective renamings. That includes the vacuous-Gen parameter, which `c3` found the hard way.
* In part (b), both inclusions hold by the stated inductions. MP works through can(σA) = can(A); Gen works through Gen_{σp}(σλ) = σ Gen_p(λ).

**Theorem 4.2 (i)–(iii)** under its stated hypothesis:
* the count of canonical formulas;
* the closure in N rounds of O(N·poly(H)) each;
* that normalisation plus Lemma 2.2(i) puts every line within H(φ);
* that g_p labels consistently.
Part (iv) holds under (F1) of M1.

**Proposition 4.3.** Membership is a local transition check.
* *Consistency.* In the free term algebra, take least fixed points C and C' and R := X. The output axioms hold because M decides X, and all paths from init(w) halt.
* *Derivation and sizes.* An MP-only derivation over the accepting (or rejecting) subtree has lines of size O(s) and 2^{O(s)} lines.
`c3` Parts B and C reproduce.

**Corollary 4.4** (i) "⊇" (CKS with a clock, then Prop 4.3), (iii) and (iv). Parts (i) "⊆", (ii) and (v) hold under (F1) of M1, with (v) also needing m5.

**Proposition 4.5.**
* X ∈ DTIME(2^{O(m)}), since n < 2^{m+1}.
* The loss bound is the computation of time-followup Theorem 3.2(c).
* The CKS route gives (a1) with a linear budget through a parameter-free A_M.
* The premise about S matches Hänni's description (`hanni-polytime-solomonoff.md`, lines 5, 18 and 43): p(n)·log n per step with state reuse, so replaying j steps costs Σ_{i ≤ j} p(i) log i.

**Proposition 4.6.**
* (i): a consistent set of literal powers not containing a power of φ_w^b does not imply it. Use a term-algebra model, in which distinct words give distinct terms.
* (ii): proved, given time-followup Prop 2.5(c), the coding assumption, and m7.
* The verdict "A^bd_f is blocked under every reading" is right: its bound k is Craig's padding at log k symbols.

**Proposition 4.7** (two sorts, B = Q ∪ B_L): consistency, and derivations whose nonlogical instances are Q1–Q7 plus one member. The fit-class sentence is as in m1.

**Proposition 4.8**, checked in detail:
* *Q-provable uniqueness.* Q ⊢ Next(c̄, y') ↔ y' = (next c)‾ for non-halting c, and Q ⊢ ¬Next(c̄, y') for halting c. This uses Q ⊢ t(c̄) = k̄, the bounded lemma, and Δ₀-decidedness of each N₀(c̄, j̄). The orientation z + y' is the one the time-followup referee's `r2_q_models` confirmed; the other orientation fails.
* *The expansion.* C^M contains only pairs of standard numerals. It is well defined in any M ⊨ B, nonstandard models and models of ¬Con(PA) included, because distinct numerals denote distinct elements.
* *The axioms hold.* S holds by uniqueness. A_φ and R_φ hold because AccC and RejC on standard codes are decided by Q.
* *Derivation.* Three A4 steps and two MPs per computation step. The nonlogical instances are Q1–Q7, S, I_φ and A_φ (R_φ), of total size a|f| + a'|φ| + b.
* *The remark on C-induction* (proof sketch) is right. Induction along the run in PA(L) puts C at a nonstandard accepting configuration, and then A_{Con(PA)} yields Con(PA).

**Corollary 4.9** and **Remark 4.11.** Both correct as stated.

**Remark 4.10.**
* (a1) and (b) are correct. PA + ρ_{f,n} is closed under renaming, so M1 does not touch them.
* (a2) is a plausible proof sketch. The fixed finite set of PA-theorems behind the Tarski biconditional is the standard compositional truth-and-substitution machinery. The uniformity in φ is the part not written out, as the notes say.

**Theorem 5.2, Proposition 5.3, Corollary 5.4** (arithmetic only; outside my focus):
* the code-length identity, e_1 = 31b_s + 24, and r := max(2b_s, 2 + e_1);
* the joint-rate argument of Prop 5.3(i), (ii);
* the statement-term lower bound (iii).
`c4` reproduces. Part (c) needs closure, which is stated there; see m11.

**Proposition 6.1 (ii), (iii)** (with m8):
* *Model 1.* The least Herbrand model of the definite part, with R on words := X_acc and R on junk := "some run accepts".
* *Junk inputs.* A run on a junk term stalls exactly where M would read the junk cell, so decided runs agree with M on the word prefixes. Consistency of f_V excludes both an accepting and a rejecting run.
* *Model 2* gives the converse.
`c5` reproduces, and `r4` re-derives its runs from the universally closed theory.

**Corollary 6.2 (i), (ii)**, and (iii) with κ ≥ 1. **Corollary 6.3**, deterministic case.

**Paper labels.** Every paper label cited in the notes exists in `time.tex`, `app-time.tex`, `model.tex` or `app-model.tex`.

## References

I checked these from memory against the standard bibliographic data, not against the sources in this session:
* Craig 1953 (*JSL* 18: 30–32);
* Chandra–Kozen–Stockmeyer 1981 (*J. ACM* 28: 114–133; ASPACE(s) = ⋃_c DTIME(c^s) for space-constructible s ≥ log n);
* Hartmanis–Stearns 1965 (*Trans. AMS* 117: 285–306);
* Hennie–Stearns 1966 (*J. ACM* 13: 533–546);
* Cook 1972/1973 (STOC'72; *JCSS* 7);
* Seiferas–Fischer–Meyer 1978 (*J. ACM* 25: 146–167);
* Žák 1983 (*TCS* 26: 327–333);
* Pratt 1975 (*SIAM J. Comput.* 4: 214–220);
* Mendelson, 4th ed., 1997 (K's A1–A5, with equality axioms A6, A7 later in Ch. 2; numbering not checked);
* Smith 2013;
* Hájek–Pudlák 1993;
* Prawitz 1965;
* Gentzen 1935 (*Math. Z.* 39).

These are consistent with the notes. Missing: Cook–Reckhow 1979 (m12).

## Scripts written for this report

| script | what it checks | result |
|---|---|---|
| `referee_logic/rk.py` | an independent implementation of K (de Bruijn indices and parameters, A1–A5, reflexivity, substitutivity, MP, Gen), normalisation, "sits at" by its definition, F and N, and the Def 5.1 code | module |
| `referee_logic/r1_subformula_independent.py` (seed 8675309) | Lemmas 1.1, 2.1, 2.2, Cor 2.3, Prop 2.4, Rem 2.5: the proof's map o; an independent exhaustive "sits" search with maximum matching; the bounds; targeted Gen lines with two uses; Prop 2.4's closed forms | all claims hold; 0 failures |
| `referee_logic/r2_parameter_channel.py` (seed 31337) | M1: A^par_V checked with kcore and rk; exact sizes 9\|φ^b\| + 54, 5\|φ^b\| + 40, 3\|φ^b\| + 13; renamings rejected; decider work; code length against β·d·log d | the channel is confirmed; the ratio grows to 5.8 at \|w\| = 12 |
| `referee_logic/r3_sharp_constant.py` (seed 2024) | m3: F ≤ \|α\|(\|α\|+1)/2, exhaustively to size 9 and randomly; the vacuous-Gen family | 0 violations; ratio 0.4843 → 1/2 |
| `referee_logic/r4_a2_finite_theory.py` | m2: T_M of `c5` universally closed; derivations by A4 + MP checked with kcore and rk; instance sizes | valid; largest nonlogical instance ≤ 49 throughout, A4 instances up to 202 |
