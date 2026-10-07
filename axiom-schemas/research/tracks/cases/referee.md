# Referee report on track "cases" (Q1: ∀xφ from instances; Q2: the ZF(C) schemas)

Referee (adversarial). I read `notes.md` in full and checked every proof marked "proved" step by step. I
re-implemented the machinery from scratch for every check that matters. That covers first-order
anti-unification and matching, the named and de Bruijn encodings of the seven ZF templates, λ-plugging,
the schema-instance test, most-specific guards, a second-order coverage search with shared metavariables,
a BKLV-style higher-order pattern anti-unifier, a model of Q, and a brute-force evaluator on finite
∈-structures. Nothing is imported from the author's `st_core`/`st_enum`/`q1_*` files, from the T1 code
or from the prior `so_core`.

All referee code and outputs are in `referee_code/` (run as `cd research/tracks/cases/referee_code &&
python3 <script>`):

| script | checks | output | result |
|---|---|---|---|
| `r1_q1.py` | A2 on random formulas with binders; capture; A2′ SO° counterexample (brute force); A8 model; A3(b) with a non-i.i.d. law | `r1_q1.out` (12 s) | all claims reproduced; **capture gap found** (F1) |
| `zf_lib.py` | library: frames, encodings, plugging, own lgg/matching, guards, instance test | – | – |
| `r2_zf.py` | B1 criterion and only-if witness, B2 blocks, §2.4 false instances, Russell/capture guards, C3, D1, deep-leaf uniqueness and the pure-logic part of C2's case analysis | `r2_zf.out` (5 s) | all reproduced |
| `r3_anchor.py B` | Cor F with own pattern lgg (exactness ⇔ (R)∧(N); soundness by random instances) | `r3_anchor_B.out` (3 s) | 3500/3500; 10 500/10 500 instances genuine |
| `r3_anchor.py A [schema AMAX GMAX NPAIRS]` | Thm E: own counterexample search in SO° (shared metavariables, repeated and parameter arguments) | `r3_anchor_A*.out` (≤ 3 min each) | 0 disagreements on 460 runs, incl. 35 ReplJ anchor pairs |
| `r3_diag.py` | the search in r3 is not vacuous | `r3_diag.out` | 326 / 5163 / 102 covering groups on anchor pairs, all contain every probe |
| `r4_rates.py` | Thm G: own inclusion–exclusion vs Monte Carlo with own pattern lgg | `r4_rates.out` (45 s) | agree within sampling error |
| `r5_q1_dt.py` | Prop A2′: DT° anchors ⇔ (R); SO° failures (own SO matcher with closed-term arguments) | `r5_q1_dt.out` (22 s) | 60/60 in DT°; SO° non-anchors found (also with binders) |

## Overall

The track is careful and, with one exception, correct. Every theorem I could test survived independent
proof checking and independent computation. That includes the central ones: the anchor theorem for ZF
pattern targets in every class between PAT and SO° (Thm E), the pattern-lgg corollary (F), the encoding
classification (B1, B2), the explicit false lgg instances (§2.4), the deep-leaf impossibility (C2), the
truth-sound over-generalization (C3) and the ω-gap results (A5–A8).

The exception is the Q1 statement that plain first-order anti-unification learns the closed-instance
schema. It is not true in the named encoding (or a first-order de Bruijn encoding) when x occurs free under
a binder of φ. The schema's metavariable can then be instantiated by a bound-variable name, which gives
capture instances that are false in every structure (F1). The fix is a sort restriction (metavariables
range over variable-free terms, as in the brief's λ convention) or the closedness/free-for guard that the
author already introduces in A4(c). The anchor characterization itself (A2) is unaffected.

The rest are minor issues of wording and scope (F2–F6). The brief's main claim is confirmed, and the
author's corrections to the brief are right (I checked each one).

## Verdicts

| id | verdict | one-line reason |
|---|---|---|
| A1 | holds | proof correct: two (H)-instances satisfy Plotkin's (R),(D), so the lgg is σ, then thm:setting:lgg |
| A2 | holds | proof correct; own lgg on 600 random formulas (binders, up to 3 variables, repeated occurrences, closed subterms from the data pool): 36 000/36 000 |
| A2′ | holds | DT° proof checked line by line; own DT°/SO° search 60/60; SO° counterexample re-verified by brute force over 2278 bodies |
| A3 | holds | (a),(b) re-derived by inclusion–exclusion; (b) checked for a non-i.i.d. joint law; (c) is the parent bound, but ρ is not defined in the notes (F5) |
| A4 | holds-with-fix | (b)'s "cl = inst(σ_φ) = inst_o(φ)" is false in the named/de Bruijn first-order encodings when x is under a binder: cl also contains capture instances, e.g. ∃y¬(y=y) (F1) |
| A5 | holds | Tarski–Vaught argument correct in both directions; correctly credited |
| A6-A7 | holds | ℝ, V (∅, pairing, union; ¬Ind) and PA + ¬Con(PA) examples checked |
| A8 | holds | model of Q checked by hand case by case and by own code on {0..60} ∪ {a,b}; 0+a = b |
| A10-A11 | holds-with-fix | correct once F1 is fixed: without a guard the unguarded learner commits not only the ω-step but also capture errors (false in every model) |
| ZF-form | holds | formulations match Kunen 1980 and Jech 2003 as far as I recall them too; the hedges are appropriate (F6) |
| B1 | holds | criterion recomputed in own encodings; the only-if witness s₃ recomputed for all 7 non-first-order cases (instance of the guarded lgg, not a schema instance) |
| B2 | holds | 2417 random pairs with (R) across 7 schemas × 2 encodings: block structure = prediction in every case |
| C-ex | holds | all six false lgg instances and four guard-violation instances recomputed; falsity proofs checked by hand |
| C2 | holds | Lemma C1 proof correct; path uniqueness and the pure-logic part of every case (each s_n[q←v] implies the stated false sentence) checked on all ∈-structures of size ≤ 3, n = 1, 2, all six cases |
| C3 | holds | proof via Collection correct; learned guards recomputed (B₁: fresh(Y), fresh(u)); non-instance with B₂ := ⊥ confirmed |
| D1 | holds | Russell refutation is pure logic from ∃z∃x(x∈z); guard exactness ⇔ (N) on 1537 random pairs |
| E | holds | proof checked line by line (one inaccurate sentence, F3); own SO° search: 0 disagreements, incl. repeated and parameter arguments and 35 ReplJ anchors the author's full check left open |
| F | holds | own BKLV-style pattern lgg (one permutation shared by all data): ≡ T* ⇔ (R)∧(N) on 3500/3500 data sets; 10 500 random lgg instances all genuine |
| G | holds | formula re-derived; own exact values vs own MC agree for all 7 schemas, two laws, N = 2..8 |

## Findings

### F1 (moderate). Capture in Q1: the closed-instance schema is not H₁-closed in the named encoding

§1.1 says inst_c(φ) = inst(σ_φ) "when the step language has no parameters". But in the named encoding the
author adopts (§1: "object variables are constants of the step signature"), a term metavariable can be
instantiated by a bound-variable name. If some x_i occurs free in the scope of a binder of φ, inst(σ_φ)
then contains capture instances that are not closed instances.

*Counterexample (computed, `r1_q1.out` (2)).* φ(x) = ∃y¬(y = x). Every closed instance is true in any
structure with two elements. lgg(φ(0), φ(S0)) = ∃y¬(y = z), and z := y gives ∃y¬(y = y), which is false in
every structure. The same happens in a de Bruijn first-order encoding: ∃¬(#0 = z) with z := #0.

Consequences:
- A2 is unaffected. Anchor-hood only asks for inst(τ) ⊇ inst_c(φ), and A1's proof uses two closed
  instances only.
- A4(b) is wrong as stated. cl_{H₁}(inst_c φ) = inst(σ_φ) is correct, but "= inst_o(φ)" is not. It
  contains capture instances, and these are not in inst_o(φ) either, since §1.1 itself puts a free-for
  guard on inst_o.
- §0 item 1 says "plain first-order anti-unification learns it", and §0 item 3 and A10.1 say that without
  a closedness guard the learner "commits the ω-rule step". Both understate the problem. Without a guard,
  the cautious H₁ verifier, once it has an anchor, also accepts sentences that are false in every model.
  In that case it is not sound at all, which is worse than being ω-incomplete.

*Fix.* Do one of the following:
- state that term metavariables range over variable-free terms (the brief's λ convention, where values
  have no free bound variables), or
- restrict A2/A10 to φ in which no free x_i lies in the scope of a binder, or
- note that the closedness guard of A4(c) also excludes variable names. The author's code (`q1_lgg.py`,
  `is_closed`) already treats x, y as non-closed. Then mention capture in A4(b) and A10.1. Once a
  parameter datum deletes closed(z), the free-for guard is needed as well (the code's comment names it
  but does not implement it).

### F2 (minor). An inconsistency between Parts 1 and 2 about de Bruijn capture

§1.1 says "in de Bruijn/locally nameless syntax no capture is possible". Part 2 then shows, correctly, that
in the de Bruijn *first-order* encoding capture happens by index shift (Sep needs "#1 not loose"; §2.4(7);
`r2_zf.out` (3): Coll with tied slots accepts #0 = #2, read as y = A in the antecedent and y = Y in the
consequent). The Part 1 sentence is true only of the λ/locally nameless convention, in which metavariable
values have no loose indices. Say so.

### F3 (minor). Thm E proof: "occurrence arguments are bound variables"

The proof of "if" (Step 2) says occurrence arguments are bound variables, "true for templates over {∈,=},
which have no closed terms". In closure-normal form, parameters are closed terms, so an SO° template may
apply a metavariable to a parameter, M(a). Arguments may also repeat, M(x, x). The proof still goes
through:
- every hole recorded in B_M is matched, in some datum, to a frame bound variable at every occurrence (by
  (N_i) or a frame leaf), so the corresponding u^s_m are bound variables for all s;
- with repeated arguments, any valid choice of β₁ and β_{j_i} works.

So the sentence should be amended, not the theorem. My search (`r3_anchor.py A`) explicitly includes
repeated arguments and the parameter arguments a, b. On 460 runs it found no counterexample, and on anchor
pairs it visited hundreds of covering groups with repeated or parameter arguments (`r3_diag.out`).

### F4 (minor). Coverage of the computational evidence for Thm E and A2′

- `z2b_fullcheck.out` did not finish the three ReplJ anchor pairs (the author says so). My independent
  search covers 35 ReplJ anchor pairs (arity ≤ 3, groups of up to 3 shared positions) and 45 non-anchor
  pairs with 0 disagreements (`r3_anchor_A_ReplJ_big.out`). The gap is closed at the level of evidence;
  the proof covers it anyway.
- Prop A2′ is labelled "proved; computed", but only the SO° counterexample was computed. I computed the
  DT° half (`r5_q1_dt.out`): on 4 formulas (two with binders) × 15 pairs, DT° anchor ⇔ (R) 60/60. The SO°
  failure is not special to binder-free φ: with closed-term arguments, ∀y(x+y = y+x) and ∀y(y=x → x=y) ∧ x=x
  also have SO° non-anchors with (R), e.g. M(0, S0) at x and M(y, y) at y.

### F5 (minor). Statement hygiene

- A3(c) uses ρ without defining it. It is the parent's ρ (thm:imitation:coupon: the best root split and
  P[Θx ≠ Θy]), and e^{−Nρ} replaces (1−ρ)^N. Say so in the statement.
- The summary's "Rates come with exact formulas; computed values match Monte Carlo and the parent report's
  bound": "match the bound" means "lie under the bound". The exact N = 6 against the bound's 11–13 is a
  factor of about 2 (correctly reported in §1.4).
- A10.2 and A5 are the same statement. Fine, but A10.2 should cite A5 as its proof.

### F6 (citations)

- **Kunen 1980** (Ch. I): Comprehension and Replacement with the stated free-variable conditions, and
  Foundation as written. This agrees with my recollection (Axioms 3, 6 and 2 there; not re-checked against the book).
  As I recall, Kunen treats ∃! as an abbreviation, so "ReplU (Kunen, ∃! primitive)" is the author's choice
  of encoding, not Kunen's. Harmless, since both forms are treated.
- **Jech 2003** 1.3, 1.7, 1.8: the wording agrees with my recollection.
- **Boolos–Burgess–Jeffrey** for Q ⊬ ∀x(0+x=x): unverified, correctly hedged. The claim itself is
  standard, and the model given is verified.
- **Tarski–Vaught 1957** (Compositio Math. 13) and **Pfenning 1991** (LICS) are correct as far as I know.
- **Baumgartner–Kutsia–Levy–Villaret 2017**: J. Autom. Reasoning 58(2), 293–310, as far as I know.
- **Lévy 1979** for Collection in ZF: plausible, hedged.

## Per-claim notes (what I checked)

**A1/A2.** I checked (i)⇔(ii)⇔(iii) against lem:setting:recover and thm:setting:lgg (read in
`paper/sections/setting.tex`). (i)⇒(ii) needs A1 only for the two (H)-instances, which are closed. The
corner cases are right:
- tied occurrences give equal columns;
- constant columns at closed subterms of φ never merge with an x-column unless (R_i) fails;
- bound occurrences of the same name stay constant.

`r1_q1.py` (1) generates random φ with ∀/∃ binders, x under binders, up to three variables and closed
subterms drawn from the data pool, with data biased to collisions: 36 000 data sets, 0 disagreements.

**A2′.** In the DT° proof:
- at a z_i-position the body is forced to the closed t_{j,i}, because holes sit only at the bound
  variables ū¹;
- the converse direction (a z-position of κ(c_s) must be a z-position of κ(c₁)) also holds when DT°
  allows closed-term arguments at non-pattern occurrences. A hole would then produce the same closed term
  for every datum, contradicting (R).

The SO° counterexample is verified by brute force: no body of size ≤ 7 solves β[S0] = SS0, β[0] = 0.

**A3.** (b): P(A∩E) = P(B∩E) = Σ e_f^N, and A_f∩B_g∩E = ∅ for f ≠ g. This gives the stated formula. It
is checked against MC for a joint law with P[t₁ = t₂ forced] = 0.3 (`r1_q1.out` (5)).

**A5–A8.**
- A5 (ii)⇒(i) needs M₀ to be a substructure (L has a constant), which is assumed.
- A6: closed terms denote integers; RCF ⊢ ∃x x² = 2; ℚ ⊨ OF + ∀x x² ≠ 2.
- A7: closed terms denote exactly the HF sets (∅, {a}, unions); ¬Ind is Δ₀ in the extended language.
- A7′: Σ₁-completeness of Q.
- A8: I verified Q1–Q7 by hand in all cases, including Q7 at y ∈ {a,b} (needs z + x = z for
  z = x·y ∈ {0, a}), and by code.

**ZF formulations.** I agree with the classification of which schemas are in ZFC proper, and with
∈-induction ⊢ Foundation (the two-line proof is correct).

**B1.**
- "if": checked; the free names of ψ are among N ∪ parameters under the guards.
- "only if": checked. The step "every guard satisfied by s₁ is satisfied by s₃" is right, because
  FV(ρθ₃(Z)) = FV(rigid part of ρ(Z)) ⊆ FV(ρθ_{s₁}(Z)).
- (c): implied iff I₁ = {0..d_min−1}; checked.
- Table row by row in `r2_zf.out` (1): EInd is first-order in de Bruijn (all occurrences #0), while Coll,
  ReplU, ReplS and ReplJ are not ((1,0,2) vs (1,0,3), and so on). The correction to the brief that
  "∈-induction is a de Bruijn first-order pattern" is right.

**§2.4.** Each listed instance matches the lgg I computed from the stated data, satisfies the most
specific guards learned from that data, and is not a schema instance (`r2_zf.out` (3)). I checked each
falsity argument by hand:
- F₁ ≡ ∀x∀w¬w∈x;
- ReplJ: the consequent gives a universal set at X = {∅};
- Coll/ReplU/ReplS (dB): each instance is ≡ ∀A¬∃x x∈A.

The guard violations (Russell instance; y = Y under the consequent's ∃Y; dB #0 = #2) are instances of the
unguarded lgg and are rejected by the learned guards.

**C2.**
- Lemma C1: the τ-path leaves τ at depth < |τ| at a metavariable. Uniqueness of s|q makes the
  replacement local. Closed v satisfy freshness and loose-index guards. Every proper prefix of a leaf in
  {∈,=} is a formula position, so v ∈ {⊤, ⊥} has the right sort.
- Case analysis: I verified every case by hand. As a mechanical cross-check, for every proper prefix q on
  the designated path, one of ⊤/⊥ makes s_n[q←v] imply the stated false sentence ("every set is empty",
  resp. the universal-image sentence C) in all ∈-structures of size ≤ 3 (`r2_zf.out` (7)). The
  set-theoretic falsity of the targets (Foundation / Russell for C; {∅} for emptiness) is correct.

**C3.** Correct. The antecedent's first conjunct gives ∀x∈A∃y B₁, and B₁ has the same free names at both
occurrences (u is a parameter at both; Y is excluded by the guard), so Collection applies. The
undetectability claim follows because ZF ⊢ every instance.

**D1.** (a) is pure logic from ∃z∃x x∈z. (b) holds: learned = target iff (N_x ∧ N_z) for Sep and iff all
(N) for Coll/ReplU; 1537/1537 random pairs.

**E.**
- Step 1: by (R), slot roots are disagreement positions, so by the rigid-prefix lemma (prior C2(a), which
  I re-read) the metavariables sit at frame or slot positions.
- Step 2:
  - slot structure is the same at all occurrences (an (R) argument);
  - frame leaves are recovered from β₁;
  - P-arguments are recovered from β_{j_i} (the (N_i) argument);
  - B_M[ū^s] = κ(c_s);
  - σ(M) = λh̄.B_M gives Tσ↓ = T*.
- The "only if" witnesses are pattern templates that cover D, and each misses a named instance.

Independent search (r3): for each data pair, every covering template is reduced to one shared group plus
fresh fully applied metavariables. This reduction is complete, for the reason given in the script header.
I enumerated all groups of up to 3–4 pairwise incomparable positions in the common prefix region (frame,
slot and leaf positions, and positions inside slots when the data agree there), with argument tuples drawn
from in-scope bound variables and parameters, repeats allowed, arity up to 3. A pair is classed
non-anchor iff some group covers the data and misses one of about 10 genuine probe instances.

| schema | pairs | anchors predicted | non-anchors | disagreements |
|---|---|---|---|---|
| Sep | 60 | 26 | 34 | 0 |
| SepJ | 45 | 38 | 7 | 0 |
| EInd | 45 | 38 | 7 | 0 |
| ReplJ | 80 | 35 | 45 | 0 |
| Coll | 40 | 11 | 29 | 0 |
| ReplU | 30 | 10 | 20 | 0 |
| ReplS | 30 | 10 | 20 | 0 |

**F.** My implementation generalizes each disagreement column to X(ȳ), with ȳ the bound variables loose
in the column, and merges two columns iff one argument permutation maps one to the other in all data
(BKLV's merge). The pattern lgg is ≡ T* iff (R) ∧ (N), with no exceptions, and every random instance of
it is a genuine schema instance. This confirms soundness before the anchor.

**G.** The inclusion–exclusion over {A_f} (pairwise disjoint) and {B_i} is correct. I recomputed it on my
own pool against MC (`r4_rates.out`).

## Missing or under-treated

1. **Capture for Q1** (F1). This is the one substantive gap. The paper should state the variable
   convention for Q1 explicitly, since the same issue drives half of Part 2.
2. **Several variables in DT° for Q1** are covered by A2′. Several *metavariables* for pattern targets
   are only sketched (the author lists this as open). ZF does not need it, but Q3 (untagged mixtures)
   will.
3. **Ground axioms.** Choice, Infinity, Pairing and so on are ground: each is its own anchor, and one
   instance suffices. This is said only for Foundation; one sentence would cover all of them.
4. **The variable-naming assumption in the named encoding** (textbook names in every datum) is
   acknowledged as open. Whether B1's "named" column survives communities that rename frame variables is
   untested. If names vary, they become metavariables with distinctness guards, and the guard family has
   to grow.
5. **C3 without Foundation** (whether Collection follows from Replacement over ZF − Foundation) is
   correctly flagged as open. I do not know a definitive reference either.

## Bottom line

Q1 and Q2 are answered, with complete proofs that I could verify and evidence that I reproduced
independently. Required change: F1 (state the variable convention or the guard for Q1; amend A4(b) and
A10.1). Recommended: F2–F5 wording fixes. With these, everything in the track can go into the paper as
stated.
