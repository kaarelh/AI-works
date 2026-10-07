# Referee report: track "untagged" (learning many axioms and schemas from unlabelled instances)

Referee: Claude (Anthropic), adversarial referee for the project brief `../../00-brief.md`.
Object of review: `notes.md` (801 lines) and `code/` in this directory, with the author's summary U1–U16.
Default verdict when a claim could not be confirmed: *unclear*.

## 0. What I did

1. Read the brief and `notes.md` in full and checked every proof marked "proved" line by line (§2 below).
2. Read every library (`dtlib.py`, `refuters.py`, `dtrc.py`, `practice.py`) and every experiment script. I paid
   particular attention to refuter soundness, matching, `mincov` completeness, train/test leakage and the metrics.
3. Re-ran all eleven scripts in a scratch copy and diffed against the author's `.out` files.
4. Wrote independent checks, saved in `referee_code/` with their outputs (§4):
   - `ref_enum.py`: a data-directed DT° enumerator written independently of `dtlib.mincov`, with its own
     abstraction, plugging and covering test;
   - `ref1`–`ref2d`: separation and `mincov` completeness on PA/ZF cross pairs and on the within-target sets
     the verifier relies on;
   - `ref3`: self-consistency audit of the refutation oracle in the actual DTRC runs;
   - `ref4`: clean-data fragmentation, and failure families after parameter canonicalization;
   - `ref5`: soundness fuzz of the refuters;
   - `ref6`: merge-order independence;
   - `ref7`: sensitivity of `mincov` to its silent caps.

**Reproduction.** All outputs reproduce exactly. The exceptions are wall-clock times (u0, u5, u5b) and the
printing order of elements inside one u8 cluster, which comes from Python set iteration (hash seed); the
clusters are identical.

## 1. Verdicts in brief

| id | verdict | one-line reason |
|---|---|---|
| U1 | holds | Proof of Thm 2.1 and Cor 2.2 correct under (W); finite negative set and its generation correctly specified |
| U1-PA | holds | Reproduced. An independent enumeration (all covering DT° templates of size ≤ 14 for all 49 PA cross pairs) finds every one above `mincov`'s template and refuted |
| U2 | holds-with-fix | Thms 3.1, 3.2 correct. Cor 3.3(b) silently needs cross-separation. The "Caveat" that Plotkin failure families are m-noncovering for all m is false once parameters are canonicalized, as the code does |
| U3 | holds | Thm 4.1 and Cor 4.2 proofs correct; c = 4 / 7 / 7 reproduced; argument for (Abs) checked by hand |
| U3-comp | holds | Reproduced 24/24. Note: given (Abs) and prior C3, κ = c + χ holds by construction, so this is a consistency check, not independent evidence |
| U4 | holds | Correct (Gold) |
| U5 | holds-with-fix | Theory correct under W, OS, Dec; merge-order independence confirmed on PA (8 orders) and ZF (4 orders), 1 partition each. Fix: "cost O(n²)" counts tests only, and one test can need \|Min(X)\| = 4^Θ(n) templates. The implemented refutation is template-specific and not monotone in ≼, unlike the fixed Ref_d of the theory (harmless in the reported runs, see §3.5) |
| U6 | holds-with-fix | Thm 5.4 correct; (d) is illustrated only by a *noisy* example although stated for clean D. A clean example exists (ref4) |
| U7 | holds-with-fix | Lemma 5.5 proof correct. Prop 5.6(e) overstates: "no instance refuted ⇒ φ(t) true for all closed t" needs an oracle complete on closed instances (true for quantifier-free φ, false for the notes' own R-Δ₀) and refers to Ref_∞, not budget d |
| U8 | holds-with-fix | Reduction correct. Gap: the §1 oracle R-Δ₀ verifies universals only via EUF, so it need not refute ¬H_e(c̄) when H_e has bounded universals. Fix: choose H_e with only bounded existentials (MRDP), or assume full Δ₀ evaluation |
| U9 | holds | Reproduced; trivial caveat: refutable singletons are incoherent clusters |
| U10 | holds | Prop 5.9 proofs correct; u8 reproduced; edge case E′ = C is trivial |
| U11a | holds | Proof checked (chain rule for the index code; body saving λ per datum) |
| U11b | holds | Correct modulo the standard regret and no-hypercompression facts the author flags |
| U11c | holds | Reproduced exactly; code reviewed, no bug found; the interpretation is appropriately hedged |
| U12 | holds | Reproduced; global separation of Q1–Q7 + T_ind follows from a short structural argument (§3.8); held-out/near-miss design has no leakage |
| U13 | holds | Reproduced; independent enumeration over 63 ZF cross pairs (2 samples per schema, size ≤ 14) finds no covering template outside `mincov`. The u5 comment promises "Replacement without uniqueness" near misses that are never generated (cosmetic) |
| U14 | holds | Prop 7.1 proof (model HF ∪ {u}) correct and matches what the HF refuter code actually does; computed part reproduced |
| U15 | holds | Reproduced; the K₀ pair's two minimal templates confirmed by independent enumeration (6258 covering templates of size ≤ 24, none outside `mincov`) |
| U16 | holds | Reproduced (0 counterexamples at size 20); extended by my checks to PA/ZF cross pairs, Sep/EInd/Rep pairs and the J*₀ clusters (§4) |

No result is refuted. The fixes needed are local; none changes a headline conclusion.

## 2. Proof checks (line by line)

**Lemma 1.1, Lemma 1.2.** Correct. In 1.2 "assign each datum to the first covering slot" gives a partition into at
most k nonempty blocks, (W) supplies T_B ∈ Min(B) below the slot, and N-avoidance is inherited downward.

**Theorem 2.1 (pigeonhole).** Correct. L_i ≠ ∅ because A_i ≠ ∅. The L_i are pairwise disjoint by (X). With
k = k′ slots each L_i is a singleton, so one slot covers all of A_i and is ≽ σ_i. Remarks (1)–(4) correct.

**Corollary 2.2.** (a) correct by (W) plus monotonicity of "meets N". (b) correct. Pedantic point: picking the
"first d-refuted instance" needs Ref_d membership to be decidable and inst(T) to be enumerable. (Dec) as
written gives only the existence test, but the author's example of (Dec), a finite Ref_d, gives both.

**Example 2.3, Cor 4.2(3).** I re-derived the cross-pair minimal templates by hand. At top level there are no
bound variables in scope, so every DT° metavariable there is 0-ary and covering templates of quantifier-free
pairs are first-order patterns (Plotkin lgg). The Q2/Q7–Ind templates must be F0 → F1 because the antecedent
pair ('=' or '¬' vs '∧') and the consequent pair ('=' or '∃' vs '∀') differ at their heads. (Abs) therefore
holds for every motive, not only the four sampled. "Three negatives suffice at k = 8" correctly uses that
F0 → F1 is absorbing.

**Theorem 3.1, 3.2.** Correct; (b) uses exactly m + k′ − 1 = k slots.

**Corollary 3.3.** (a) correct. (b): the proof's "if exactness fails, some N-avoiding family of ≤ m templates
covers D_i and misses q" is the contrapositive of Thm 3.2(a), which needs **cross-separation**.
Target-separation as stated does not imply it, because a template ≽ σ_i that also covers a D_j datum is not
incomparable with σ_i. State cross-separation as a hypothesis of (b). Rest correct.

**Caveat after Cor 3.3 (error).** "Plotkin's failure family for a first-order pattern is m-noncovering for every
m when … parameters are infinitely many names." The setting reads formulas under universal closure, and the code
canonicalizes parameters to a1, a2, … So φ(a7) and φ(a1) are the same datum and the same query, and the head
classes of a term metavariable are finite. For arithmetic they are 0, S, +, ·, a fresh parameter, plus the
template's own parameters. Five failure templates σ[z↦0], σ[z↦Sz′], σ[z↦z′+z″], σ[z↦z′·z″], σ[z↦a1] cover
every instance of z+0=z: 500/500 random canonicalized instances (`ref4_misc.out`). So first-order instance
schemas over a finite signature have the same "root family covers everything" problem as T_ind once
m ≥ 5. Open problem 2 should cover them too. The claim is only syntactically true, by counting renamed copies
as different sentences. The same paragraph says the seven root specializations (=, ¬, ∧, ∨, →, ∀, ∃) of T_ind
cover Ind, but §1 lists ↔ as a connective; with ↔ there are eight.

**Theorem 4.1.** Correct, including the degenerate case k ≤ c_i, where the conclusion follows because some
slot of every h ∈ VS must contain inst(σ_i). Cor 4.2(1),(2) correct. (2) uses disjointness to show that the
σ_l, l ≠ i, do not contain inst(σ_i).

**Proposition 4.3.** Correct. With a fixed oracle the learner is a function of the text, and Gold's
locking-sequence argument does not need computability.

**Theorem 5.2.** (i) correct via (W′) and (OS). (ii) correct: purity is invariant, and termination plus (i)
give one cluster per nonempty D_i. (iii) correct: the T₀ of (i) lies in Min_d^+(D_i), and an anchor forces
every member of Min(D_i) to be ≽ σ_i. (iv) correct as an inequality; DTRC can even beat the tagged learner,
because refuted non-target minimal templates drop out. (v) as a count of tests: n(n−1)/2 initial pairs plus
≤ n per merge. The online bound is n·k′ plus k′(k′−1)/2 for the final pairwise pass. **Fix:** the
summary's "cost O(n²)" must read "O(n²) coherence tests". Track 'single' (Prop G.2) shows |Min(D)| can be
4^Θ(n), and a coherence test as defined ("some T ∈ Min(X) not d-refuted") may have to enumerate Min(X). No
polynomial per-test bound is given, and track single's polynomial feature verifier decides membership in
Acc, not the existence of an unrefuted minimal template.

**Remark 5.3.** Correct.

**Theorem 5.4.** (a)–(c) correct. (d) is stated for clean D ⊆ R* but illustrated only by the noisy u8
example. A clean example exists. Take targets σ₁ = (t+0=t), σ₂ = (0+t=t) with D₁ = {0+0=0, S0+0=S0} (an
anchor) and D₂ = {0+S0=S0, 0+SS0=SS0, 0+(0+0)=0+0}. If 0+S0=S0 comes first, DTRC returns
{0+0=0} ∪ D₂ and {S0+0=S0}, and rejects a1+0=a1 (`ref4_misc.out`). A version with disjoint instance sets:
σ₁ = t+0=t, ground target g = 0+S0=S0, order g, 0+0=0, S0+0=S0.

**Lemma 5.5 (two-point anchors).** Checked in detail; correct. The key steps hold:
- t_j are closed, so the bound variables free in φ(t)|_p are those of φ(z)|_p, and the bodies θ_t(M) are
  legal;
- G(z) = (λȳ.φ(z)|_p)(ū) contains z only as a leaf, because ū is metavariable-free;
- the two-point identity is a correct induction;
- T's rigid skeleton cannot reach a z-position, since the two data differ in head there.

It agrees with track 'single's anchor condition: for a 0-ary metavariable whose two values differ in head,
their (U) "no coincidence" condition holds automatically.

**Proposition 5.6.** (a)–(d) correct; in (b) the parameter must be fresh for φ. **(e) overstated.** "If the
oracle refutes only closed instances (R-Δ₀ without logic), then 'no instance refuted' means 'φ(t) true for
every closed t'." That requires an oracle that refutes *every* false closed instance at some depth. Closed
evaluation does this for quantifier-free (or fully evaluated Δ₀) φ. The notes' R-Δ₀ (§1, `refuters.Arith`)
verifies universals only by EUF + Diag(ℕ). A false closed instance whose refutation needs a universal verified
in ℕ is never refuted, for example a wrong-base induction variant needing Q1 (u8 M2). The ω-rule reading is
also about Ref_∞; at a finite budget d DTRC can merge instances of a false universal whose least
counterexample lies beyond d (Thm 5.4 covers this, but (e) should say so). The ℝ example is correct.

**Theorem 5.7.** The reduction is correct:
- P_e and P′_e have the same data law, so the learner cannot tell them apart;
- for e ∉ K, (b) on P_e forces acceptance of q_e with probability > ½ at some time (continuity from below
  over the increasing events);
- for e ∈ K, (a) on P′_e, where Res_∞ = ∅, forbids it;
- so co-K would be Σ₁. The argument survives randomized learners: "P > ½" is then still Σ₁.

**Gap:** fact (4) needs ¬H_e(c̄) to be refuted at some finite depth. With the oracle "R-Δ₀" as defined in §1
(existentials by witnesses, universals only via EUF + Diag(ℕ)), refuting ¬H_e(c̄) means *verifying* H_e(c̄).
That needs evaluating the bounded universals of a Kleene-T formula, which this oracle cannot do. **Fix:**
either take the oracle to be full evaluation of closed Δ₀ sentences with bounded quantifiers as primitive
(still sound and decidable per depth), or choose H_e(z) with bounded existentials only. The latter is possible
by MRDP: "z codes a solution of the Diophantine equation for e ∈ K". Keep codes 0 and 1 invalid and z
occurring. With either fix the theorem holds as stated.

**Proposition 5.8.** Correct. (b) needs the trivial exception that a refutable singleton is an incoherent
cluster.

**Proposition 5.9.** Correct. In (d) the equality of the two forms of Acc^e_d follows by (W) in both
directions. Edge case: E′ = C, possible when |C| ≤ e, leaves Min(∅) undefined; restrict to |E′| < |C|. The
Robust-DTRC guarantee follows from (a)–(d) under the stated assumptions.

**Proposition 6.1.** Correct. **Proposition 6.2.** Correct. Under T_f the bodies have total size |φ| − 1 for
every root, ∀/∃ included. The index term follows from the chain rule for empirical entropy plus the KT
parametric term. **Proposition 6.3.** Correct given pointwise regret ≤ (p/2)log n + C for the mixture
(true for finite-alphabet KT/Jeffreys mixtures) and Barron's inequality. The author correctly says this
does not show that MDL selects H_true.

**Proposition 7.1.** Correct. I checked that `refuters.HF` only does steps sound in any structure containing
HF as a transitive part:
- atoms between HF constants;
- bounded quantifiers over HF members;
- unbounded ∀ refuted by HF witnesses;
- unbounded ∃ verified by HF witnesses;
- ∃y(y∈t) refuted only for t = ∅.

HF ∪ {u} satisfies every instance of the universal-set schema (take x = u), so no instance is HF- or
logic-refutable at any depth. The positive part (coherence with Russell's Separation instance or with
∀x¬x∈x) is a two-line derivation, found by the DPLL refuter (reproduced).

## 3. Code review findings

**3.1 Refuter soundness (critical for every "refuted" claim): no bug found.**
- `Arith.refute`/`verify` are sound: closed atoms are evaluated; ∀ is refuted only by a numeral
  counterexample; ∃ is verified only by a witness; ∀ is verified, and ∃ refuted, only through `euf_valid`,
  whose "unsat" answers come from congruence closure with true closed equations of ℕ. That is sound for
  every assignment of the generic element. Bodies with nested quantifiers or extra bound variables are
  rejected conservatively.
- `HF` is sound as above.
- `logic_unsat` is sound:
  - NNF handles ↔ by expansion;
  - Skolem indices are distinct across formulas (offset `len(clauses)*1000`);
  - variable names are globally unique, so pulling universals out of ∨ is safe;
  - truncating the Herbrand terms or instances only weakens the refuter;
  - an exhausted budget returns "no refutation";
  - equality uses reflexivity only.
- Fuzz (`ref5`): 3000 true arithmetic sentences (induction instances with parameters, Q-axioms, tautologies)
  and 1206 true set-theoretic sentences (Sep/Rep/∈-induction instances, ZF axioms, tautologies) were never
  refuted.

**3.2 Matching.** `dtlib.match` takes the body from the first pattern occurrence by abstraction, then checks
every occurrence by plugging. That is correct for DT°. Non-determinate templates fall back to an existence
check that returns `{}` as a flag, which is fine as a covering test. Templates are matched literally, not
modulo renaming of template parameters. This can only under-accept a canonicalized query whose parameter
order differs from the template's; it is conservative and I found no case in the experiments where it matters.

**3.3 `mincov` completeness (critical for every separation claim and for the verifier).** The author
cross-validated it only on arithmetic induction pairs (u0). The ZF results (U13, U14) and the within-target
ZF anchors depend on it in a language with ∈, parameters and binder-rich data. My independent enumerator
found **zero** covering templates outside `mincov` on:
- all 49 PA cross pairs (size ≤ 14, 68 covering templates);
- 63 ZF cross pairs, 2 samples per schema (size ≤ 14, 598 templates);
- the UnionW–PowerW pair (91);
- 3 Sep and 3 EInd within-target pairs (size ≤ 16, up to 1527 each);
- 2 Rep within-target pairs (size ≤ 20, 4657 and 3731);
- the K₀ pair (size ≤ 24, 6258);
- {Ind(0+x=x), J*₀} (size ≤ 20, 3377);
- the 4-element absorption cluster {Ind(Sⁿ0+x=Sⁿx), n<3} ∪ {J*₀} (size ≤ 20, 999).

The silent caps of `mincov` (`max_antichain`, `max_templates`) never changed a result: in 382 calls of the
PA and ZF DTRC runs, 10× larger caps gave the same output (`ref7`).

**3.4 No leakage, sound metrics.**
- Held-out instances come from different seeds and are accepted by template matching, so 200/200 and 180/180
  only confirm that the cluster template *is* the schema, which is also checked directly via subsumption.
- Near misses are checked for genuineness: 13 vacuous-motive "near misses" are genuine and correctly
  excluded from the false-accept count.
- "pure" uses the generating labels.

Cosmetic: the u5 comment announces "Replacement without uniqueness clause" near misses, but none are
generated, and the notes do not claim them.

**3.5 Theory and implementation disagree on the refutation oracle (minor; no effect found).** The theory
assumes a fixed set Ref_d, so "T is d-refuted" is monotone in ≼ and d-coherence is downward closed
(Lemma 5.1). `World.refute_template` instead samples instances from template-specific pools with a per-template
logic budget of 60. Templates above a refuted one can therefore be reported unrefuted. Example: on the
Union–Power, Union–Sep and Power–Sep pairs, all 72 enumerated covering templates of size ≤ 14 that the
budgeted search leaves unrefuted contain Russell's logically false instance (`ref1`, plus a direct check
reported in §4). The implemented "d" is therefore not a d in the sense of (Dec), and the implemented
coherence need not be downward closed.

DTRC only tests Min(X), so this did not matter in the reported runs. My audit (`ref3`) of the PA (3 seeds),
ZF (3 seeds) and noisy-PA runs found:
- no asserted template covers any sentence refuted elsewhere in the same run;
- no asserted template is refuted by a search with 10× budget, B = 4, and 10× logic budget.

**Recommended fix:** keep a global set N of refuted sentences and call T refuted if it covers any n ∈ N.
This is exactly N(D,d) of Cor 2.2 and makes the implementation match the theory.

**3.6 MDL code (u7).** Reviewed:
- the split templates are determinate (quantifier roots use F1(x, y));
- matching succeeds for every datum;
- depth offsets agree between H_true and H_root under DPC;
- the KT index alphabet is 14 vs 8 symbols, adding about 3 log₂ n bits against splitting, which is
  negligible.

G2 is indeed well specified for DPC: formula symbols depend only on depth, term symbols on (parent, index,
depth ≥ 4), and these are within DPC's context. Numbers reproduced exactly.

**3.7 Noise demo (u8).** Reproduced:
- the three M1 mistakes are refuted and stay incoherent singletons;
- J*₀ and the wrong-base variant are unrefuted (as expected, R1 and Q1-dependence);
- absorption into the non-diverse cluster gives the K₀-shaped template as the only unrefuted minimal one,
  which `ref2d` confirms is the unique minimal template;
- the trimmed verifier with e = 1 rejects J*₀ and J*₁;
- fragmentation depends on order.

**3.8 PA global separation (U12) beyond the samples.** For Q1–Q7 + T_ind the separation claim is not just
empirical. Every Q–Ind pair has minimal template F0 or F0 → F1 *for every motive* (head argument above),
and the 21 Q–Q pairs are fixed. So RS_d holds globally at small d (given W). For the instance schemas
Q1s–Q7s, global separation is supported only by samples (4 pairs per schema pair); the notes say so.

**3.9 Merge-order independence (Thm 5.2(ii)).** On one PA data set (31 distinct data), 8 random orders gave a
single final partition, {T_ind cluster of 25, six singletons} (`ref6`). On one ZF data set (30 data, 24
distinct), 4 random orders gave a single, pure partition into 9 clusters (`ref6b_order_zf.out`; the 8-order
45-datum version timed out).

## 4. Independent checks: commands and outputs (directory `referee_code/`)

| script | command | output | result |
|---|---|---|---|
| `ref_enum.py` | library | | own data-directed DT° enumerator (prefix of common prefix; metavariable occurrences with args from bound variables, data parameters and 0 (arith); arity ≤ 2; own abstraction/plugging; determinacy and covering checked) |
| `ref1_cross_enum.py 14` | `python3 ref1_cross_enum.py 14` | `ref1_cross_enum.out` | PA: 49 pairs, 0 unrefuted, 0 outside `mincov`. ZF: 63 pairs, 0 outside `mincov`; 120 budget-unrefuted templates, all above refuted naive comprehension. UnionW–PowerW: 81 unrefuted (the universal-set schema and its generalizations, as Prop 7.1 predicts) |
| (direct check) | inline in session | — | the 24 + 24 + 24 budget-unrefuted templates on Union–Power, Union–Sep0, Power–Sep1 all cover Russell's instance ∃x∀y(y∈x ↔ ¬y∈y), which `logic_unsat` refutes |
| `ref2_within_enum.py 16`, `ref2b.py 24`, `ref2c.py 20`, `ref2d.py 20` | as named | `.out` files | Sep ×3, EInd ×3 (size ≤ 16), K₀ pair (≤ 24), Rep pairs ×2 (≤ 20), {Ind(0+x=x), J*₀} and J*₀ + 3 inductions (≤ 20): 0 covering templates outside `mincov` in every case. (The Rep part of `ref2_within_enum.py` at size 30 timed out and was replaced by `ref2c.py`.) |
| `ref3_consistency.py` | | `ref3_consistency.out` | PA ×3, ZF ×3, noisy PA: 0 asserted templates covering a refuted sentence; 0 refuted at 10× budget |
| `ref4_misc.py` | | `ref4_misc.out` | clean fragmentation example (Thm 5.4(d)); 5 head-class failure templates cover 500/500 canonicalized instances of z+0=z (against the Cor 3.3 caveat) |
| `ref5_fuzz.py` | | `ref5_fuzz.out` | 0 of 3000 + 1206 true sentences refuted |
| `ref6_order.py`, `ref6b_order_zf.py` | | `ref6_order.out`, `ref6b_order_zf.out` | PA: 1 partition over 8 orders; ZF: 1 pure partition over 4 orders |
| `ref7_caps.py` | | `ref7_caps.out` | 382 `mincov` calls, 0 results changed by 10× larger caps |
| author's scripts | `run_all.sh` equivalent in a scratch copy | — | all `.out` reproduced (timings and one set-print order excepted) |

## 5. Assessment of the track against its task

The task items are covered:
- (a) setting;
- (b) pigeonhole theorem with a finite generated negative set, the spare-slot theorems, slot accounting, and
  the necessity of a bound;
- (c)(i)–(vi): DTRC soundness, separation theorem, residue, ∀xφ, the depth impossibility, whole-cluster
  tests, and noise with a robust variant;
- (d) slot counting and MDL, with an honest negative result;
- (e) PA and ZF with natural separation failures: the universal-set merge, K₀, and sound merges.

Hypotheses imported from track 'single' (W, A) are stated explicitly. Track 'single' now claims W as its
Theorem B and an anchor theorem (R*)+(N)+(U), still unrefereed; the uses here are consistent with both.

**Missing or weak:**
1. The spare-slot threshold for T_ind and, per the error above, for first-order instance schemas over a
   finite signature, at m ≥ 5–8. This is open; the notes list only the T_ind half.
2. No natural permanent (Σ₁/Π₂-type) residue from a merge was constructed. The notes say so.
3. The per-test cost of coherence is unanalysed (§2, Thm 5.2(v)).
4. Choice is not discussed. It is a single ground axiom and trivial for the method, but the user asked about
   ZFC.

## 6. Required changes (all minor)

1. Cor 3.3(b): add cross-separation as a hypothesis.
2. Caveat after Cor 3.3: replace with the finite-head-class observation (failure families of arithmetic
   first-order patterns cover after canonicalization once m ≥ 5 + #template parameters). Fix "seven roots"
   vs ↔.
3. Thm 5.2(v) and the summary: "O(n²) coherence tests", with a remark that one test may cost |Min(X)| up to
   4^Θ(n).
4. Thm 5.4(d): give a clean-data fragmentation example (§2).
5. Prop 5.6(e): restrict to oracles complete on closed instances (quantifier-free φ under evaluation) and to
   Ref_∞.
6. Thm 5.7: specify the oracle (full closed-Δ₀ evaluation) or choose H_e with bounded existentials only (MRDP).
7. Implementation: make refutation monotone with a global negative cache. Remove the stale u5 comment.
