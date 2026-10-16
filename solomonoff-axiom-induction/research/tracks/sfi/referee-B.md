# Referee B (computation and counterexamples): thread `sfi`

*Referee report on `notes.md` (development round, 2026-10-15) and its scripts in `checks/`. The independent code is in `referee_code/`. Each script is seeded or deterministic and writes `<name>.out` next to itself. No git command that changes repository state was run. The name "Solomonoff axiom induction" is a working name; nothing below depends on it.*

## Verdict

**Sound, with one major and seven minor issues. No fatal issue.**

* **Developer's computations:** every computed claim in the record reproduces. All four developer scripts re-run from scratch to byte-identical outputs.
* **Citations:** every printed-number citation of P1 and of the AI-paper resolves to the item the record describes.
* **Independent finite analogues:** every theorem with one survived my independent code with 0 violations, exactly, with the stated constants. This covers:
  * Lemma 1.3; Thm 3.1(a) and (b), including the empty data set and the program-less tape mass; Cor 3.2.
  * Prop 6.1(a) and (b); Prop 6.5's density step; Prop 6.8(c); Thm 5.1.
  * Rem 5.4 (with AI-paper Prop E.1).
  * Thm 10.1(i), the exception gadget of Cor 10.2, and the diagonal constant of Thm 7.4.
* **The major issue (Issue 1):** a clause of Prop 9.4 extends a doubly exponential lower bound to reading (a1) of charged deduction. That does not follow: under (a1), derivation size is not polynomial in the budget.
* **The minor issues:**
  * an imprecise computability claim for the closed versions (Prop 6.7(c));
  * a script whose stated "conservative" estimate is not conservative (c3);
  * two weak or circular computed checks (c1 item (4), c2's density check);
  * small presentation points.

## What was run

| script | what it tests | result |
|---|---|---|
| developer `checks/c1`–`c4`, re-run on scratch copies | reproducibility | all four outputs byte-identical to the saved ones (c1 36.5 s, c2 0.6 s, c3 0.1 s, c4 12.9 s) |
| `rb0_xref.py` | every "P1 …" and "AI-paper …" citation in `notes.md`, resolved against the two papers' `main.aux` (cleveref lines); the backtick labels; the first column of the transfer table (§5.5) | 16 P1 and 25 AI-paper (type, number) pairs (as parsed, with plural forms counted separately) and the items of all 29 table rows resolve, to labels whose names match the record's descriptions (e.g. P1 Thm 4.9 = `thm:versions:nocoding`, AI-paper Prop E.17 = `prop:time:bounded`, P1 Rem 4.12 = `rem:versions:answer` = `rem:versions:prediction`, one environment). The only "unresolved" hit, "Thm F11", is a parsing artefact (scout F's item F11). |
| `rb1_onetape_exact.py` | independent exact (Fraction) finite analogue (details below the table) | 0 violations of everything tested, in both backgrounds; details below |
| `rb2_independence_density.py` | Prop 6.5(b): the density step **and** the displayed bound ν^{3,cons}(σ,ι) ≤ ε Σ_W 2^{-\|w\|} + U(C∖⋃[w]) ≤ 2ε, on three machine families: mostly consistent; consistency scattered by tape parity; consistent only on one cylinder. Coin-free diagonal and Prop 6.4(b) bracket | 0 violations in 117 (machine, ε) cases (7285 dense prefixes). The check is non-vacuous: 119 sentences outside every J_w carry positive consistent ι-mass, largest ν/ε = 1.0 (bound 2). Coin-free: 0 violations |
| `rb3_literals_transfer.py` | AI-paper Prop E.1 / Rem 5.4: exact expected loss on fair-coin literals, n = 1..8, random priors over consistent theories (coin-free, with lookup tables) and random tape-reading theory machines; FIall with the inconsistent "accept all"; Thm 5.1 on positive literals incl. three-way weights | expected loss − n ≥ +0.33 for every prior (never < n); a + a′ ≤ 1 at every step; FIall bounded; transfer: 0 violations in 1950 data sets |
| `rb4_arith.py` | (A) Thm 7.4's constant, with adversarial approximation errors against 5 predictors; (B) Cor 10.2's verifier exception gadget, built and brute-forced (d ≤ 4, k ≤ 2), and its weight ratio against Γ_N; (C) c3's thresholds recomputed exactly (mpmath, 60 digits); (D) Prop 9.4's constants, size reading against (a1) | (A) Σ_{j≥1} log₂(1+2^{−j−2}) = 0.34663 < 0.361; every simulated loss ≥ n − 0.361. (B) 0 failures in 7200 cases; built γ = d+1 (3 for d = 1) ≤ 2d+2; −log₂(w(V′)/w(V)) ≤ Γ_N(s) everywhere (d ≤ 64, s ≤ 400, k ∈ {0,s,2s}). (C) **8 of 144 c3 rows have m₀ too small** (Issue 3). (D) Issues 1, 2 |
| `rb5_circuit_sat.py` | Thm 10.1(i) by a different method from c4: entailment as propositional UNSAT of ground instances (own DPLL) | entailment proved for 294/294 data of 54 consistent verifiers; a non-witness certificate never entails (135/135); inconsistent verifiers make the ground instances UNSAT (32/32: the consistency hypothesis is needed); finite fragment + Γ_f SAT for 54/54; undefined points stay open (210/210). Sizes: \|T_V\|/((s+d+k)log₂(s+d+k+2)) falls from 16.8 to 12.6 for s = 10…1100; derivation material /(s(log₂(s+2)+d+k)+(d+k)³) falls from 11.8 to 1.05 |
| `rb6_c2_vacuity.py` | instruments an in-memory copy of developer c2 (file unchanged, md5 checked) to count the non-vacuous instances of its density check | only 42 of 261,542 (w,σ) pairs could have failed (e2); 2380 of its 4174 dense prefixes are full tapes (Issue 6) |

**rb1 in detail.**
* **Construction:**
  * 3 atoms; ASTs, so the Craig decider parses real right-nested padded conjunctions;
  * halting steps are separate from tape prefixes;
  * the "universal" families are closed under PS, EM and CR to depth 2;
  * the mixtures carry the program-less mass 1 − Ω_V.
* **Checks:**
  * the tape-wise inclusions of Lemma 1.3;
  * PS closed;
  * the Craig decider is determined by the bits it reads, has exactly the brute-force decompositions (at most 2), and Cn(B + Craig set) = Cn(B + Γ_f);
  * Thm 3.1(a) with the constant 2^{c_ps} + 2^{c_B}, and (b);
  * D = ∅;
  * Cor 3.2 three-way weights at mixture level;
  * Prop 6.1(a),(b);
  * the Prop 6.8(c) filter, with an independent event order: valid function machine, consistent on every tape, equal to F on F's consistent tapes, outputs an initial segment, ν_{F′} ≥ ν^cons_F.
* **Results:**
  * 0 violations in 845,856 PS triples per background, and in all other checks.
  * The 2^{c_B} term of Thm 3.1(a)'s constant is actually used: ratio 47 > 2^{c_ps} = 4 under the nontrivial background, from the program-less tapes.

Re-run: every referee script was re-run from scratch on scratch copies; all seven outputs are byte-identical to the saved ones (rb1 14 s, rb4 24 s, the others under 7 s).

## Issues

### 1. [major] Prop 9.4's clause "the same holds under reading (a1)" is not supported

**Claim (§9, Prop 9.4).** If a hypothesis with membership time O(m^e) fits D^Pres with derivation budget d, then d(m) > 2^{2^{c″m}} infinitely often. "The same holds under readings (a1), (b) (Thm 8.1(a): size ≤ a polynomial of the material)."

**Problem.** Thm 8.1(a) bounds derivation size by a polynomial of the *material*, which is reading (b). Reading (a1) bounds the size of *each* axiom instance, not their number. The proof's step "guess a derivation of size ≤ d(m) and check it in poly(d(m))" therefore has no polynomial bound under (a1).

The record's own sources say so:
* SD Thm 4.2 (under (F1)): a derivation whose instances have size ≤ h has at most 2^{O(h log h)} distinct lines.
* SD Cor 4.4(v): "reading (a1) is deterministic function induction with an exponential clock". Its fit class lies between DTIME(2^h) and DTIME(2^{O(h log h)}).
* Rem 8.4 of the record itself: "the fine bounds (2^{O(h log h)} for (a1) …)".

**What the argument does give.** With derivations of size up to 2^{β h log h}, Fischer–Rabin's bound gives only β h log₂ h > 2^{cm}/c_e, i.e. h(m) > 2^{c″m}: a singly exponential lower bound.

`rb4_arith.out` (D) tabulates the two forced budgets (c = 0.2, c_e = 10, β = 4):

| m | size reading: log₂ log₂ d > | (a1): log₂ h > |
|---|---|---|
| 160 | 28.7 | 22.2 |
| 320 | 60.7 | 53.0 |

The (a1) column grows linearly in m: h is singly exponential, d doubly exponential.

**Is the doubly exponential (a1) bound simply true?** Not from the tools cited.
* Secondary sources found by web search state Berman's (1980) result: Presburger arithmetic is complete for alternating doubly exponential time with linearly many alternations. They give a doubly exponential *space* upper bound and Fischer–Rabin's *nondeterministic* doubly exponential lower bound. Haase, arXiv 1401.5266, gives the alternating-time completeness and the space bound; Klaedtke, arXiv cs/0506008, gives the alternating-time completeness and Fischer–Rabin's lower bound.
* None of them settles whether PrA is in *deterministic* doubly exponential time. That is what a doubly exponential (a1) bound would interact with, since (a1) is a deterministic exponential clock (SD Cor 4.4(v)), at least on literal data.

**Fix.**
* State Prop 9.4 for the size reading W_A[t,d] and for reading (b) only (there, g ≥ √d up to lower-order terms).
* Add a separate statement for (a1): under (F1), h(m) > 2^{c″m} for all large m [proved, by SD Thm 4.2 and F_FR]. Whether a doubly exponential (a1) budget is needed is [open].
* Change §0 item 9(ii), "derivation-charged SAI with any budget below doubly exponential fails too", to "with any derivation-size or material budget below doubly exponential". Change the closing sentence of §9 the same way.
* Table row 30 is already stated for W_A[t,d] only and can stay.

### 2. [minor] Prop 9.4: the constant c″ does not depend on e, and the bound holds for all large m

**Claim.** "d(m) > 2^{2^{c″m}} for infinitely many m, with c″ > 0 depending only on e." Table row 30: "unbounded unless d(m) > 2^{2^{c″m}} infinitely often".

**Observation.** From d(m)^{c_e} > 2^{2^{cm}}:
* d(m) > 2^{2^{cm}/c_e} ≥ 2^{2^{cm/2}} as soon as 2^{cm/2} ≥ c_e;
* so c″ = c/2 works for every e, and only the threshold m ≥ (2/c) log₂ c_e depends on e (computed: `rb4_arith.out` (D)(i), 9 parameter pairs).

Also, Fischer–Rabin as the record states it (F_FR) gives a hard sentence of every large length. So the conclusion holds for all large m, not just infinitely often.

**Why it matters.** Row 30 is a statement about the mixture over all degrees e. With c″ depending on e it would need "for some c″ > 0"; with c″ = c/2 it holds uniformly.

**Fix.** State "with c″ = c/2, for all m ≥ m_e".

### 3. [minor] c3's "conservative" estimate is not conservative; 8 of 144 thresholds are too small

**Claim** (c3 docstring; notes §13: "conservative estimates log₂(C2^a + m) ≤ a + log₂C + 1").

**Problem.** The estimate needs m ≤ C·2^a. With a small clock exponent (c′m small) and C = 10, it fails. `rb4_arith.out` (C) recomputes all 144 thresholds exactly. In 8 rows c3's m₀ is below the exact one, by 1 to 6:
* (A): c = 0.05, c′ = 0.0125, C = 10, k = 2: printed 73, exact 76;
* (B): c = 0.05, c′ = 0.0125, C = 10, k = 2: printed 73, exact 79;
* the other six are in the output.

In every affected row the condition m ≤ C·2^a fails at m₀ − 1. Elsewhere c3 is conservative (by up to 4).

**Effect.** None of the thresholds quoted in notes §9 is affected: they use c′ = 0.9c, and the affected rows have c′ ∈ {0.25c, 0.5c} with c = 0.05. The table is illustrative.

**Fix.** Use log₂(C2^a + m) ≤ max(a + log₂C, log₂m) + 1, or compute exactly as rb4 does; correct the docstring and the §13 entry.

### 4. [minor] Prop 6.7(c) does not cover the closed versions; (a) needs the closure map for them

**Claim.** "(c) All of them [W_A, W_A^dec, W^cons, W^cl, M_A, M_A^dec, M_F^cons, M_F^cl] are computable relative to ∅′ … Each object is a sum of Δ₂ indicators (support conditions are Σ₁, consistency is Π₁)."

**Problem.** Closedness is not Δ₂. "f closed" says: for all φ and b, if B ∪ Γ_f ⊢ φ^b then f(φ) = b. That is ∀(Σ₁ → Σ₁), a Π₂ condition. It is Π₂-complete for coin-free labellers, by this reduction:
* let χ_0, χ_1, … be an injective enumeration of the sentences that B decides (an r.e. set);
* let f_e label χ_n with B's decision of χ_n once program e halts on n;
* then Γ_{f_e} ⊆ Cn(B) ∪ {¬χ : B ⊢ ¬χ}, so B ∪ Γ_{f_e} is equivalent to B; and f_e is closed iff it labels every B-decided sentence, i.e. iff e is total.

So the stated proof gives the closed objects only relative to ∅″. For one tape, the measure of a Π₂ class of tapes is right-c.e. relative to ∅′, hence ∅″-computable.

**A smaller point in (a).** The support argument cites "the lookup table of a consistent D" for every object. The lookup table is never closed (Issue 7). For W^cl and M_F^cl the positive-weight witness is its closure under map (CL), which is closed, consistent and extends D. The conclusion of (a) stands.

**Fix.** In (c), either restrict to the six non-closed objects, or state "W^cl and M_F^cl are computable relative to ∅″ (closedness is Π₂)". In (a), cite (CL) for the closed versions.

### 5. [minor] Two of c1's computed items are tautological given the construction

**Item (4) (Prop 6.1(c), the abstention bound).**
* c1 puts abstention variants of every machine into the family with weight 2^{−k}, and then checks "⊥-mass ≥ 2^{−k} × (weight of the base machines extending D consistently)".
* The check can fail only if an abstention variant were inconsistent or failed to extend D. Removing a label makes neither happen, by construction.
* So the "computed" status of Prop 6.1(c) (§0 item 5; §15) adds no evidence beyond the one-line proof.

**Items (3a), (3b).** These are the tape-wise inclusions (1), (2) summed with the same weights. They are consequences, not independent checks.

**Fix.** Mark Prop 6.1(c) as "proved"; describe c1 (4) as a sanity check of the map. For the mixture-level inequalities of Thm 3.1, cite rb1 (2) as a test between families closed under the maps. Or extend c1 the same way: closure to depth 2, program-less mass, D = ∅.

### 6. [minor] c2's density-lemma check is weakly informative and omits the bound that the proof uses

**Claim** (§6.2, after Prop 6.5): "the finite analogue of the lemma ($J_w\subseteq\mathrm{Ind}$, and consistent ι-mass ≤ ε in [w] off J_w) holds in all 4174 dense prefixes".

**Problem.**
* **c2's machines are rarely consistent.** They are consistent on a median 5.1% of tapes, and 2380 of the 4174 dense prefixes are full tapes. On a full consistent tape every ι-labelled sentence is in J_w automatically.
* **Few instances can fail.** Instrumented (`rb6_c2_vacuity.out`), only 42 of 261,542 tested (w,σ) pairs had σ outside J_w with positive consistent ι-mass, i.e. could have failed (e2).
* **The summed bound is never tested.** c2 never checks the displayed inequality of the proof: ν^{3,cons}(σ,ι) ≤ ε Σ_W 2^{−|w|} + U(C∖⋃[w]) ≤ 2ε.

**Fix.** Use a mostly consistent machine family and test the summed bound, as rb2 does: 0 violations, 119 non-vacuous instances, largest ν/ε = 1.0. Or cite rb2.

### 7. [minor] Lemma 1.2: the bracket "[the empty labeller is closed]" is always 0

**Claim.** "(for ν^cl: add (1−Ω_V)·[the empty labeller is closed])".

**Observation.** B proves every tautology of Sent_𝓛, so the empty labeller, which labels nothing, is never closed. The bracket is identically 0 and the clause can read "add nothing". It is nonzero only in finite analogues whose sentence set contains no B-decided sentence: `rb1_onetape_exact.out` (7) shows it true for B = ⊤ and false for the other background.

**Fix.** Replace the clause, or keep it with "(this is 0: B decides every tautology)".

### 8. [minor] Thm 3.4 needs no restriction to D ≠ ∅

**Observation.** For D = ∅, every penalised version contains the polynomial-time decider of ∅, so M_A^{chk,t}(∅), M_A^{gen,t}(∅) ≥ 2^{−c} ≥ 2^{−c}M_F^cons(∅). The upper bounds hold for every D. Prop 3.5 is already stated for all D; Thm 3.4 and table row 7 say "D ≠ ∅".

**Fix.** Drop the restriction or note why it is harmless.

## Claims checked and found correct (no issue)

The following were attacked by counterexample search, independent computation or line-by-line re-derivation, and survived.
* **Lemma 1.3 and Thm 3.1.** Lemma 1.3 (PS, EM, CR, CL) and Thm 3.1(a)–(c) with the stated constant 2^{|r_ps|} + 2^{c_B}, including D = ∅ (rb1).
* **Strictness of PS (Rem 1.4).** The PS inclusion is often strict: rb1 counts 60,557 and 83,134 strict triples, in line with c1.
* **Cor 3.2 and Prop 6.1.** Cor 3.2 at mixture level, with the program-less tapes matched by the proof-search labeller of B (rb1 (4)). Prop 6.1(a),(b) (rb1 (5)); the proof of (c) re-derived.
* **Prop 6.3, Lemma 6.3′, Prop 6.4.** Re-derived: the recursion-theorem argument uses only Σ₁-soundness, Q ⊆ Cn(B) and decidability of B, as the record says. The finite mechanism checked in rb2.
* **Prop 6.5(b).** The density argument re-derived: J_w is r.e. (lower semicomputable measure of an open set), J_w ⊆ Ind_B, and the three-way split of C_p gives ≤ 2ε. Finite form in rb2.
* **Prop 6.8(c).** The global-schedule filter is a valid function machine (rb1 (6)). The events up to a stage are determined by the bits read by then, because a run started at stage i has read at most s − i bits at stage s.
* **Cor 4.2.** Consistent with the `logic` record, which re-proves the lottery (its Thm 2.2) and has G_lot consistent on every tape. Its Prop 2.3 covers plain SOI (bounded arity), matching Cor 4.2(c).
* **The P1 items behind the transfer.** Prop 5.3 and Cor 5.2 constants match P1 Prop 4.6(b), Thm 4.9, Cor 4.10 and Rem 4.12(2) as printed. The transfer-table classifications (binary versus string labels) match P1's statements, e.g. Exs 7.27/7.28 and §7's cyclic permutation have non-binary labels.
* **Rem 5.4 / AI-paper Prop E.1.** The expected loss is ≥ n for every consistent prior tested (rb3).
* **Thm 7.4's constant.** The tie rule gives q ≤ ½ + ε_j (from q_b ≤ q_{1−b} + 2ε and q_0 + q_1 ≤ 1). The sum starts at j = 1 and equals 0.3466 < 1/(4 ln 2) (rb4 (A)). Starting at j = 0 would give 0.669, so the indexing matters and is transcribed correctly.
* **Cor 10.2.** P1's proof adapts as stated:
  * the tail bound needs only total weight 2^{−S} above size S;
  * the "no active output" verifier makes the tail inequality strict;
  * L − ℓ_∅ replaces L because W_N(∅) < 1;
  * the gadget and Γ_N were checked in rb4 (B).
* **Thm 10.1(i).** Checked in rb5 (entailment by UNSAT; sizes). The intended model in the consistency proof was re-checked: index terms n_i and gate terms g_j coincide as terms but sit in different predicates, so no clash.
* **Prop 9.2's derandomisation.** Majority over the extensions of u decides each sentence, because the correct-answer set ⊇ G ∩ [u] has conditional measure > ¾. Prop 9.3 is correctly marked conditional.

## Verification log

**Read.**
* The project brief, the thread brief, `notes.md` in full (629 lines), and the developer scripts c1–c4 in full.
* The P1 statements of Thm 3.21, Props 3.24, 4.5, 4.6, 4.7, 5.6, 9.4, Thm 4.9, Cor 4.10, Rem 4.12, Defs 9.1, 9.7, Thm 9.8 and its proof (`app-comp.tex`), Exs 7.25–7.28, Defs 7.2, 7.11, Props 7.24, 7.29.
* The AI-paper's proof of Thm 6.15 (`app-time.tex`, construction and loss computation).
* SD `notes-final.md` on reading (a1): Thm 4.2, Cor 4.4, Rem 8.4's sources.
* The `logic` record's lottery section: claims table and §2.1–2.7.

**Ran.**
* Developer c1–c4 from scratch on scratch copies: byte-identical outputs.
* rb0–rb6 (this folder), then all seven again from scratch on scratch copies: byte-identical outputs.
* Seeds: rb1, rb2, rb3, rb5 use 20261016; rb4 B(i) uses 20261016; rb0 and rb6 are deterministic; rb6 runs c2 with c2's own seed in memory and leaves c2's files unchanged (md5 of `c2_independent_label.out` checked before and after).

**Self-corrections during this review.**
1. **rb2, first run, was vacuous.** Random machines were mostly inconsistent, so every sentence with consistent ι-mass fell into some J_w. I redesigned the base family to be mostly consistent; the check is now non-vacuous (119 instances). This led to Issue 6.
2. **rb3, first run, had infinite coin-free loss on most priors.** The family was too small. I added the 2^n lookup-table theories; W_A's loss is now finite and ≥ n.
3. **rb3's re-encoding check (3) is automatic** in a semantic representation. It is labelled so in the script and not counted as evidence.
4. **I first misderived the tie-rule bound** as ½ + 2ε. The source's ½ + ε is right (q_b ≤ q_{1−b} + 2ε together with q_0 + q_1 ≤ 1).
5. **rb0's number pattern first missed appendix numbers** (E.17, A.10); fixed and re-run.
6. **Issue 1: I first considered asserting** that a doubly exponential (a1) bound would contradict an open problem. I could not establish that for sentence data (SD's (a1) fit classes are stated for literal sequences), so the issue says only that the bound is not supported and that the available tools give a singly exponential bound.

**Web.**
* WebSearch on Berman 1980 and on Presburger complexity. Secondary sources (Haase, arXiv 1401.5266; Klaedtke, arXiv cs/0506008; the Utah TCS bibliography entry for TCS 11(1) 71–77) state Berman's completeness for alternating doubly exponential time with linearly many alternations and Fischer–Rabin's nondeterministic lower bound.
* This supports the recalled form behind (B*) of Prop 9.3 at the level of secondary sources. The exact Σ₂ form (B*) still needs the primary source.
* No source found settles whether PrA is in deterministic doubly exponential time.

**Not done.**
* No check of (S_tape) for a concrete machine; it is an assumption in the record too.
* No primary-source check of Fischer–Rabin or Berman.
* No computation for Cor 4.2 beyond reading the `logic` record.
* The open questions of §6 were not attacked computationally: whether W_A can be lsc with decidable consistency, and whether M_F^cons / M_F^C is bounded in general.
