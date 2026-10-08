# Referee report: track "pa" (PA, ZF and "the axioms we actually have")

Referee: adversarial referee for track "pa". Date: 2026-10-08.
Object: `notes.md` and `checks/` in this folder, read in full, together with the brief, Hänni's notes in
`../../prior/`, and the cited parts of `../axiom-schemas` (`many.tex`, `app-many.tex`, `zfc.tex`,
`research/conversation.md` §§7–9).
Referee code: `referee_code/` (8 scripts; each writes its `.out` next to itself; all deterministic or seeded).
The track's files were not modified. Track scripts were re-run only on a copy in the scratchpad.

## Verdict

**No fatal issues.** The checked derivations are correct: an independent re-checker accepts all 20, and it rejects
all 173 corrupted variants of them. All numbers I recomputed by independent methods agree with the saved outputs:
* the cost table;
* the toy tower;
* the Euler computation;
* Prop. 4.1.

**Five major issues.**
* **M1.** One table in the notes does not match the track's own output.
* **M2.** The overall answer claims robustness that the computations do not test.
* **M3.** The track never treats data that are theorems given without proof, which is the user's own proposal.
  Under the track's own code, memorising such theorems beats deriving them.
* **M4.** Prop. 3.5(c) and F8 ("in DT° the posterior lands on the PA side") are refuted by a counterexample. The
  track's own code then prefers the weaker theory.
* **M5.** The exponential rate claimed in 4.5 for H4 comes from a fixed rule code. A learned rule code gives
  polynomial odds.

**Eleven minor issues.** They are listed below.

Severity counts: fatal 0, major 5, minor 11.

---

## Issues

### M1 (major). The section-4 table does not match `checks/c4_bdtrc.out`

* **Claim.** notes.md §4, table "Computed: Q + Ind practice", rows *memorise*, *over-general*, *lump* and *bare F₀*.
  The verification log says these are "as quoted".
* **Problem.** At n = 1000 and n = 3000 these eight entries differ from the saved output. The saved output is
  reproducible: I re-ran `c4_bdtrc.py` on a copy, and the result was byte-identical. The *lump* row is off by a factor
  of 2.
* **Evidence.** `referee_code/r7_table_vs_output.py` → `.out`. Values are notes.md, then `.out`:

  | row | n=1000 (notes / output) | n=3000 (notes / output) |
  |---|---|---|
  | mem | 133905 / 133845.4 | 399840 / 399693.6 |
  | over | 27257 / 27876.8 | 82196 / 82717.0 |
  | lump | 6440 / 3205.5 | 19412 / 8929.8 |
  | bare | 46311 / 46251.0 | 137534 / 137387.5 |

  The other 22 entries match.
* **Effect.** No conclusion changes: all four candidates still lose at a linear rate. The log's claim is false,
  though.
* **Fix.** Regenerate the table from `c4_bdtrc.out`, and check every quoted number against the outputs
  mechanically.

### M2 (major). "Robustly gets a theory deductively equivalent to PA, with nearly all posterior mass" is not tested

* **Claim.** §5 "Overall answer" lists four cases: clean Q+Ind usage data; any usage mix of Ind, CVI, LNP; either
  recursion convention; splits by main connective. §4 "Answer to question 4" adds: "Fragmentations and spare slots are
  the only competitors that survive."
* **Problem.** In three of the four cases, every candidate scored is PA-equivalent by construction:
  * §1.2 compares only T_S for S ⊆ {Ind, CVI, LNP};
  * §1.3 compares T_left and T_right;
  * §2 compares T_Ind and its splits.

  So "nearly all mass on PA-equivalents" is automatic there. Only the c4 run has non-equivalent competitors, and its
  candidate set is hand-picked. The notes say so in §4, but the overall answer drops the qualifier.
* **Counterexamples.** Two non-equivalent competitors that the candidate sets omit, and that win:
  * the memorising theory on theorem data (M3);
  * a syntactically narrow theory on narrow practice (M4).
* **Fix.** Restate the answer: "within the hand-picked candidate sets, and only for axiom-instance data". Name the
  competitors that were not scored.

### M3 (major; also a missed question). Theorem data: under the track's own code, memorisation beats derivation

* **Claim.** §1 (data are i.i.d. *uses* (f, φ), each datum an instance f(φ)) and the overall answer ("it picks up the
  axioms that are used"). F9 says "a deep theorem with no short proof is cheaper to add as an axiom" only for bounded
  search, and marks it "Not computed".
* **Problem.** The user's proposal is that "statements given without proof in our data set should be fairly easily
  derived from axioms". The data are then theorems, not axiom instances, and the track never computes this case. Under
  the track's own L1 code, even one-induction theorems cost far more to derive than to adopt as axioms.
* **Evidence.** `referee_code/r6_theorem_data.py` → `.out`. The derivations are the track's own, plus one written
  here; all pass the independent checker. The code is the track's: log₂23 bits per symbol, both for proof text and for
  the prior.

  | theorem | derive in Q+Ind | memorise (prior + citation) | memorising is cheaper at the first occurrence | derivation wins only if the prior exceeds |
  |---|---:|---:|---|---:|
  | ∀x 0+x=x | 220.1 | 31.7 + 6.5 | yes | 30.5 bits/symbol |
  | ∀x∀y Sx+y=S(x+y) | 551.4 | 58.8 + 6.5 | yes | 41.9 bits/symbol |
  | ∀x x+0=x (in T_left) | 220.1 | 31.7 + 6.5 | yes | 30.5 bits/symbol |
  | ∀x∀y x+Sy=S(x+y) (in T_left) | 599.8 | 58.8 + 6.5 | yes | 45.6 bits/symbol |

* **Consequence.** On distinct theorems that each need induction, "Q + the theorems as axioms" beats Q+Ind on every
  datum. That theory is strictly weaker than PA.
* **Exceptions.** Q+Ind is preferred only in three situations:
  * the data come from Q+Ind's own derivation process (well-specified, Doob);
  * derivations are much shorter than in this library;
  * the axiom prior is about 7–10 times steeper than the track's β.
* **What does transfer.** The usage effect of §1 carries over roughly. Deriving ∀x(0+x=x) directly in T_CVI costs
  652 bits more than in T_Ind (37 lines against 11). The per-use overhead in §1 is 880 bits.
* **Fix.** Add a theorem-data section. State the memorisation threshold β\* = (derivation bits − citation) / |θ|.
  Discuss which prior or which data law (well-specified, or repeated lemmas) makes Q+Ind win. This is the central
  quantitative question behind the user's "derivation length prior".

### M4 (major). Prop. 3.5(c) and F8 are refuted

* **Claim.** §3, Prop. 3.5(c) (marked proof sketch): "if the community uses only Σₙ motives, every DT° theory that
  covers its practice as citations (L0) contains PA-strength induction … so in DT° the posterior lands on the L∞ side".
  The Summary ("Inside DT° the posterior lands on the L∞ (PA) side") and F8 ("DT° forces the L∞ (PA) choice") repeat
  it as established.
* **Problem 1: the statement fails.** The anchor theorem `thm:zf:indanchor` is about a *single* covering template, and
  it is stated for parameter-free motives. For unions the sketch relies on the wrappers of Prop. 2.2. Those need a
  *formula* metavariable under the connective. A split whose bodies use only term metavariables has no wrappers.
* **Counterexample.** `referee_code/r8_narrow_practice.py` → `.out`.
  * *Practice.* Q, plus induction on motives of two shapes only: ∃z(s=t), which is Σ₁, and ¬(s=t), which is open.
    There are two main connectives and x is free, so the premise of the sketch holds.
  * *Theory.* H_narrow = Q + T_E + T_N, with T_E = Ind(λx.∃z(A(x,z)=B(x,z))) and T_N = Ind(λx.¬(C(x)=D(x))). A, B, C
    and D are term metavariables.
  * *Covering.* H_narrow covers every datum as a citation.
  * *Strength.* Every instance of T_E is Σ₁-induction and every instance of T_N is open induction. So
    Q + H_narrow ⊆ IΣ₁. IΣ₁ ⊬ Con(IΣ₁) by Gödel II, while PA ⊢ Con(IΣ₁). So H_narrow is strictly weaker than PA.
* **Problem 2: the posterior goes the other way.** Under the track's positional grammar, H_narrow gains 11.5 bits per
  doubling of n. The reason is the never-used-parts mechanism of the track's own §2.3 and F3: H_true pays
  (9−1)/2·log₂n in each of the three formula contexts that H_narrow fixes. H_narrow overtakes Q+T_Ind near n ≈ 2²⁷.
  * *Validation.* My closed form equals the track's `c4_bdtrc.codelength` difference at every size tested
    (+230.8, +212.5, +192.5 and +181.4 bits at n = 100, 300, 1000 and 2000).
  * So on this practice the posterior ends on the *weaker* side, not the L∞ side.
* **What survives.** For practices whose motives force a covering template with a formula metavariable in a
  wrapper-admitting position, the sketch is plausible. G1 is such a case.
* **Fix.** Restrict (c) to that case, and state it as a conjecture or prove it. Remove "DT° forces the L∞ choice"
  from F8 and from the Summary.

### M5 (major). §4.5: "posterior odds fall like 2^(−3.3n). This is H4's prediction" holds only for the rule code used

* **Claim.** §4.5, the L1 row "∀x(x+0=x) plus one ∀E step per datum", and its reading.
* **Problem.** The 3.3 bits per datum is log₂10: a fixed, uniform code over the 10 rules. §2 of the track concludes
  that preferences between templates are driven by the code ("the finding is about Q"). The same holds for the
  derivation grammar.
* **Evidence.** `referee_code/r3_forall_rulecode.py` → `.out`. The table gives L(H_∀) − L(H_sch) in bits; term
  costs cancel.

  | n | fixed log₂10 | learned, one shared context | learned, context = depth in the derivation |
  |---:|---:|---:|---:|
  | 10³ | 3321.9 | 2004.0 | 41.1 |
  | 10⁶ | 3321928 | 2000004 | 85.9 |

  With a depth-conditioned rule distribution the penalty is ≈ (R−1)/2·log₂n = 4.5·log₂n. The posterior odds are then
  polynomial, not exponential.
* **What survives.** The direction (H_sch favoured) survives. The rate is a property of the rule code.
* **Fix.** Report the rate together with the rule code. Say that with a learned, position-aware rule grammar the data
  separate H_∀ from H_sch only logarithmically, like the template splits of §2.

### m1 (minor). Prior bookkeeping in `c2_mdl.py`, inherited from u7: H_root is not charged for its unused templates

* **Claim.** §0 and §2.2: code-length differences "are log₂ posterior odds, exactly". §2.3: "the full split H_root
  stays at +300…+292 bits".
* **Problem.** `codelength` charges prior only for templates that some datum uses (`used`). The KT index code still
  ranges over all 7 split templates. So the hypothesis scored is neither the full split nor the used-roots split.
* **Evidence.** `referee_code/r2_accounting.py` → `.out`.
  * Under G1 all 7 roots occur, so nothing changes there.
  * Under G2, three split templates are never used (or, ∀, ∃), and 355 prior bits are missing.
  * Under G3, four are never used, and 470 bits are missing.
* **Corrected margins.**
  * G3 full split: SDPC +300…+292 → +770…+762.
  * G2: SDPC +415 → +770; DPC +1428 → +1783.
  * CF, G2, n=4000: −300 → +55, so the sign flips.

  No asymptotic conclusion changes. The G2 rows of `../axiom-schemas` `tab:many:mdl` have the same undercount
  (u7_mdl.py line 99).
* **Fix.** Charge all templates of the hypothesis, or define H_root as the used-roots split and restrict the index
  alphabet to match.

### m2 (minor). The SDPC margin is not constant

* **Claim.** "+762 to +770 bits, constant from n=10³ to 2.56·10⁵". Also Prop. 2.1's remark that the log-marginal
  difference "converges to a constant".
* **Evidence.** `r2_accounting.out`(b): the slope is exactly −1.00 bit per doubling under both G1 and G2.
* **Reason.** ⊤ and ⊥ never occur at the motive-root context, so H_true pays ½·log₂n for each. The notes explain this
  mechanism in §2.3 and §4, but call the §2.2 margin constant.
* **Effect.** Extrapolated, the split overtakes T_Ind at n ≈ 2⁷⁸⁰. This is harmless in practice, but "constant" is
  wrong. The constant-limit claim needs every alphabet symbol to occur.

### m3 (minor). The break-even "iff" ratios are code- and library-specific

* **Claim.** Summary and §1.2: "T_Ind beats T_CVI iff p_CVI/p_Ind < 0.60", and similarly 0.757 and 1.172.
* **Problem.** The constants are upper bounds from one derivation library, so no "iff" follows. The ratio is robust to
  completing the code: 0.600 → 0.608 (`r1_recheck.out`). But under the track's own L1-naive code the same ratio is
  0.671, 0.777, 0.900 and 1.052 at |φ| = 5, 10, 20 and 40.
* **Fix.** In the Summary, write "for L1-sch with this library".

### m4 (minor). The proof-text code is not decodable

* **What is missing.** `nd.Proof.bits` does not code:
  * the variable z of a `subst` line;
  * the bound variable of an `exI` line;
  * the number of premises of a `tc` line;
  * the number of lines.
* **Effect.** Adding these raises the derivation costs by about 3–7% (`r1_recheck.out`, column "bits+dec"). No
  conclusion changes.

### m5 (minor). The "trivial lower bound" in §1.2 is argued incorrectly

* **Claim.** "Every T_Ind-derivation has at least two lines and costs at least log₂10 + β bits more than a citation."
* **Problem.** A citation itself writes the motive P(x), which costs 2β. So "two lines, one written symbol" does not
  exceed a citation by log₂10 + β.
* **Correct argument.** The last line of a derivation of CVI(P) must be `tc`, `impI` or `subst` writing ≥13 symbols
  of CVI(P), or an `exE` passing such a line through. So the overhead is positive by a wide margin. The conclusion
  stands; the argument should be replaced.

### m6 (minor). Model specification: Prop. 3.2 conflicts with §4.6

* **Claim.** Prop. 3.2: "Inconsistent theories derive every sentence, so under 0/1 support they are never refuted."
  §4.6: "Each true datum d refutes every theory that derives ¬d."
* **Problem.** With the §4.6 rule at unbounded depth, every inconsistent theory is refuted by the first datum. So
  Prop. 3.2, F6 and Remark 3.4 hold only for the bare 0/1 likelihood without that rule, or with the rule at bounded
  depth.
* **Fix.** State once which refutation rule is in force, and at what depth. The "consistency filter" of Prop. 3.2 is
  then the same mechanism as §4.6's rule.

### m7 (minor). Prop. 3.5(a): eliminating each IΣₙ is not concentration on PA

* **Claim.** "Stochastic data thus separate the chain from its limit."
* **Problem.** Each fixed IΣₙ is eventually refuted, but at any time the tail {IΣₘ : m > N} could hold mass.
* **Fix.** One line suffices: the class is countable, π(PA) > 0, and P_T ≠ P_PA for T ≠ PA, so Doob's theorem gives
  π(PA | Dₙ) → 1, P_PA-a.s.

### m8 (minor). `thm:many:depth` is cited too loosely

* **Where.** Prop. 3.2 ("the filter is necessary …"), F4 and F6.
* **Problem.** The theorem concerns DTRC-type accept sets on a uniformly computable family of practices with oracle
  R-Δ₀. It does not directly speak about consistency filters on a posterior. The relevant fact is simpler: consistency
  of r.e. theories is Π₁-complete, hence undecidable.

### m9 (minor). Euler: m occurs three times in Prime(m), not twice

* **Where.** `c5_euler.py`, `datum_size`.
* **Problem.** In ¬m=0 ∧ ¬m=S0 ∧ ∀a∀b(a·b=m → …), m occurs three times. Counting three occurrences raises the false
  schema's lead by about 50%. For example, at ρ=0.9 and n=10⁶ it goes from 2.09·10⁵ to 3.14·10⁵ bits
  (`r4_euler_closed_form.out`).
* **Effect.** The conclusion is strengthened, not weakened.

### m10 (minor). The toy tower covers only the provable part of the data

* **Problem.** Under a full-support μ on Th(ℕ), a positive fraction of the data is unprovable in every T_k (T_ω is
  r.e.). The toy omits these data. The code comment says so; §3 of the notes does not.
* **Fix.** Add one sentence to §3.

### m11 (minor). Wording and smaller points

* "The brief's context-free Q (CF)." The brief does not fix one nonterminal per sort. A PCFG whose nonterminals carry
  (depth, parent, index) is SDPC. Say "a one-nonterminal-per-sort PCFG".
* Posterior masses for candidates whose templates overlap (lump, bare F₀) are two-part bounds. With 2 covering
  templates the exact marginal is at most n bits larger. At n=100 the lump would still be ≥ +219 bits behind, so the
  mass claims survive. Say this.
* §3.5(c) also uses the anchor theorem outside its stated scope (parameter-free motives).

---

## Claims checked and confirmed

| claim (notes.md) | how checked | result |
|---|---|---|
| Prop. 1.1 (A), (B), (C1), (C2); composite derivations T_Ind→LNP, T_LNP→Ind | independent re-checker `r1_recheck.py`: own substitution, alpha-normal form, truth tables, rule semantics, hypothesis bookkeeping, and own statements of Q1–Q7, Dlt, Ind, CVI, LNP. The track's stored hypothesis sets are recomputed, not trusted | all accepted; base axioms cited as stated |
| the re-checker is not vacuous | 173 mutants (negated conclusion per line; bad eigenvariable) of (A), (B), (C2) and SepJ←ReplJ | 173/173 rejected |
| Remark 1.2 (CVI, LNP ∈ PAT; Ind ∉ PAT) | by inspection against `zfc.tex` §PA and the pattern definition | correct |
| Prop. 1.4 (recursion conventions) | `r1_recheck.py` | 4/4 accepted |
| ZF: SepJ←ReplJ, Found←EInd, ReplK←Coll, ReplJ←Coll+SepJ | `r1_recheck.py`, with own statements of SepJ, ReplJ, ReplK, Coll, EInd, Found | 4/4 accepted |
| Prop. 2.2 wrapper derivations (6 roots) | `r1_recheck.py` | 6/6 accepted |
| cost table, template sizes, break-even ratios, phase-diagram statements, T_all thresholds | independent bit accounting in `r1_recheck.py`; arithmetic by hand | match to 0.1 bit |
| u7 reproduction (−223/+2325/+2701; −915/+1141/+1428) | compared with `tab:many:mdl`; re-ran `c2_mdl.py` for n ≤ 16000 on a copy | identical |
| Prop. 2.1 (chain rule) | proof read | correct for fixed parameters |
| Prop. 3.1, 3.3, Remark 3.4 | proofs read line by line | correct |
| Prop. 3.2 | proof read | correct for the bare 0/1 likelihood (see m6) |
| Prop. 3.5(a) | proof read; IΣₙ₊₁ ⊢ Con(IΣₙ) traced to Hájek–Pudlák Cor. I.4.34 via arXiv:2101.03384 (secondary) | correct given known facts (see m7) |
| toy tower (all 4 settings, all 5 checkpoints) | independent log-space re-implementation `r5_tower.py` | identical; also, mass above the largest level seen is ≤ 10⁻¹⁵ |
| Prop. 4.1 (spare slot) | exact closed form `r2_accounting.py`(a) at n = 10 … 3000 | matches the c4 row (15.9 … 19.8) |
| Prop. 4.2, 4.3 | proofs read | correct for the stated models |
| c4 posterior masses at n ≤ 100, with negatives, and the §4.5 table | read off a byte-identical re-run | as quoted |
| F4 Euler numbers (both ρ, all n) | independent closed-form Dirichlet recomputation on the same draws, `r4_euler_closed_form.py` | identical |
| reproducibility of `test_nd`, `c1_costs`, `c2_detour`, `c3_tower`, `c4_bdtrc`, `c5_euler` | re-run on a copy, `cmp` against saved outputs | byte-identical (`c2b_cf` not re-run) |

**References checked** (web search; abstracts and catalogue records, not full texts):
* *Confirmed:*
  * Zarach, *Replacement ↛ Collection*, Gödel '96, LNL 6, pp. 307–322;
  * Gitman–Hamkins–Johnstone, MLQ 62(4–5):391–406 (2016), doi 10.1002/malq.201500019;
  * Kaye–Wong, NDJFL 48(4):497–510 (2007), with transitive containment ⇔ ∈-induction singled out;
  * Shepherdson, Bull. Acad. Polon. Sci. 12 (1964) 79–86. That IOpen ⊬ "√2 is irrational" is credited to it in Kaye's
    1993 survey.
* *Exists, but the track should cite it:* Kaye–Paris–Dimitracopoulos, *On parameter free induction schemas*, JSL
  53(4):1082–1097 (1988). It is the primary source for the parameter-free remark the track cites via slides.
* *Existence and content checked via secondary sources:* Paris–Kirby 1978 (Logic Colloquium '77).
* *Not verified:* the Shoenfield substitution-lemma location; the Lévy and Jech locations; Turing 1939; Feferman 1962;
  Clarke–Barron 1990.
* *Collection from Replacement in ZF without Foundation (with Power Set):* my search also did not settle it. The track's
  "unknown" stands.

---

## Important questions from the brief that the track missed or left thin

1. **Theorem data** (user's "statements given without proof should be easily derived"). This is not computed (M3).
   It is the question that decides whether a derivation-length likelihood finds PA at all. It needs:
   * the memorisation threshold β\*;
   * the well-specified case (data from PA's own derivation process);
   * the effect of lemmas reused across data.
2. **The posterior over all finite template unions.** Only hand-picked candidates were scored (acknowledged). M4 shows
   that this matters: narrow, weaker theories are natural competitors, and they win logarithmically when practice is
   syntactically narrow.
3. **H6 (time penalty) in PA terms.** Not addressed. The natural PA case is 3.5(b): IΣₙ as Q plus one sentence through a
   partial truth predicate, against the schema. A Kt-style or derivation-time penalty decides between them. It was not
   quantified.
4. **H3 (the δ-verifier) on PA data.** Not computed. Examples: what the verifier accepts after Q+Ind usage data, and
   after theorem data. Accepting Con(IΣₙ) is one test.
5. **H2 misspecification with human data.** Apart from Euler (F4), the track has no mixed axiom-and-theorem data and no
   identification of the KL-minimiser.

---

## Referee code (all in `referee_code/`)

| script | what it checks | output |
|---|---|---|
| `r1_recheck.py` | independent line-by-line re-check of all 20 derivations; own statements of the axioms and schemas; bit accounting; decodable-code variant; break-even sensitivity; mutation test | `r1_recheck.out` |
| `r2_accounting.py` | Prop. 4.1 exact; SDPC slope; roots used under G1/G2/G3 and the missing prior bits | `r2_accounting.out` |
| `r3_forall_rulecode.py` | H_∀ against H_sch under fixed, shared and depth-conditioned rule codes | `r3_forall_rulecode.out` |
| `r4_euler_closed_form.py` | Euler numbers by closed-form Dirichlet marginals; the three-occurrence correction | `r4_euler_closed_form.out` |
| `r5_tower.py` | independent log-space toy tower | `r5_tower.out` |
| `r6_theorem_data.py` | theorem data: T_CVI against T_Ind on ∀x(0+x=x); derive against memorise | `r6_theorem_data.out` |
| `r7_table_vs_output.py` | notes §4 table against `c4_bdtrc.out` | `r7_table_vs_output.out` |
| `r8_narrow_practice.py` | counterexample to Prop. 3.5(c), validated against the track's own `codelength` | `r8_narrow_practice.out` |

**Run order.** `r6` imports `r1` (and re-runs it). The others are independent. `r2` and `r5` take about a minute
each. The scripts import the track's modules with bytecode writing disabled, so no files are created in `checks/`.
