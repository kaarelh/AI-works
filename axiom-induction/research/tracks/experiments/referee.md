# Referee report: track "experiments"

*Adversarial referee for `notes.md` of this track and the code in `../../../code` (package `bai`, experiments E1–E7,
unit tests, results). All referee scripts are in `referee_code/`; each writes a `.out` file next to it. The referee
did not edit the track's notes, code or results. Experiments were re-run with outputs redirected to
`referee_code/repro/`, with `PYTHONDONTWRITEBYTECODE=1`, so that nothing was written into `code/`.*

**Status tags used here.** *proved* (full argument given here), *computed* (script and output named), *known*
(published, with reference), *checked* (I re-derived or re-ran it and it holds).

---

## 0. Verdict

The computational core is sound. I reimplemented the instantiation grammar Q, a DT° matcher, the prior code, the
Dirichlet-integrated marginal and the L1 chain coefficients (K ≤ 2) from the notes' descriptions, without reading
the track's code for them. They agree with `bai` to about 10⁻¹³ on every case tried. All seven experiments
reproduce bit for bit, apart from wall-time lines. Props X1–X4, X6, X7(a), X8 and X9 hold.

The problems are in what the numbers are taken to show.

1. **E2's headline about unsound lumping is inflated by the candidate pool** (major, M1). The pool lacks the
   obvious sound theory "T_Ind plus the Q axioms seen so far". Adding it changes how often a δ = 0.05 verifier
   accepts a false sentence:
   * at n = 8: from 18/25 seeds to 1/25;
   * at some n ≤ 64: from 19/25 seeds to 4/25.

   The effect is real but rarer than reported. It happens at n ≈ 16, not at n = 8.
2. **E6 calls three theories "logically equivalent" to ∀x∀y(x+y = y+x) that are strictly weaker** (major, M2).
   Only A_xy and A_yx are equivalent.
3. **The summary's soundness promise drops a hypothesis** (major, M3). Prop X8(a) needs data drawn from the
   Dirichlet-averaged law. At a fixed weight vector, the case of E2, E3 and E4-C1, a constant threshold fails. An
   independent simulation (R9) gives acceptance 0.86–1.00 against a nominal bound of 0.02.
4. **"Robust at the level of theorems" in PA is refuted for a natural misspecification** (major, M4). With atomic
   induction motives (every datum still a theorem of T*), the posterior goes to Q + {T_=, T_<} with mass 1.000 in
   5/5 seeds. That theory is strictly weaker than T*.
5. **Two of E3's named winners are artefacts of where the hand-built families stop** (minor, m12): N_4, and the
   depth-1 S-nesting.
6. **Several brief questions are not addressed** (§3). The most important: whether a derivation likelihood changes
   the MDL fragmentation finding in PA. The brief asks this explicitly, and the track runs PA only under L0.

No fatal issue was found. No reported number is miscomputed, and no proof has a gap that breaks its stated
conclusion. The errors are in interpretation and in generalisations from hand-built pools.

---

## 1. What was checked, and how (summary)

| check | script / output | result |
|---|---|---|
| unit tests | `python3 -m pytest -q tests` in `code/` | 18/18 pass (17.9 s) |
| reproduction of E1, E2, E5, E6, E7 | `repro_run.py`; `repro/*.md` diffed against `code/results/*.md` | identical apart from wall time |
| reproduction of E3, E4 | same (`repro/run2.log`: 817 s, 1270 s) | identical apart from wall time |
| Q log-probabilities, independent sampler | `r1_core_compare.py` (a) | 18000 samples, max difference 1.1·10⁻¹³; out-of-support cases agree |
| Q is proper | `r1_core_compare.py` (b), exact size distributions | P(size ≤ 400) = 1 − 10⁻⁹ (terms), 0.99987 (formulas); subcritical |
| DT° matcher and L0 coefficient | `r1_core_compare.py` (c, e), own matcher | 29700 (template, sentence) pairs, 0 disagreements, max L0 difference 2.3·10⁻¹³ |
| prior code lengths | `r1_core_compare.py` (d), own code from notes §1.3 | identical to 4 decimals (T* 226.1624, Q-lumped 77.4139, …) |
| Dirichlet marginal (Prop X2) | `r1_core_compare.py` (f), own count-vector sum and literal sum over assignments | 400 cases, up to 5 overlapping components, max difference 1.4·10⁻¹⁴ |
| L1 chain coefficients (Prop X4) | `r1_core_compare.py` (g), own brute-force backward recursion | 904 (theory, datum, component) triples, K = 1, 2, open and closed elim terms, incl. ?P and ∀x?P(x) closed forms and MP: max difference 2.1·10⁻¹⁴ |
| L1 forward law | `r1_core_compare.py` (g), own sampler against own exact values | χ² ≈ df in 4 settings (18.6/20, 27.0/27, 25.3/25, 17.6/20) |
| E1 table and Prop X6 | `r4_e1_table.py` | every number in the notes' E1 table re-derived from the json; X6 holds against independently computed prior bits to 1.1·10⁻¹¹ |
| E2 pool | `r2_e2_seenq.py` (25 seeds) | see M1 |
| E7 with the extended pool | `r3_e7_seenq.py` (25 seeds) | see M1 |
| E3 pool edges and an atomic motive law | `r6_e3_extensions.py` | see M4, m12 |
| E4(A), E5(a), (a2), (b), (c) | `r5_e4_e5.py`, own formulas | all reproduced (details in §4) |
| E6 claims, leakage, E4 checkpoints | `r7_misc.py` | see M2, m5, m6 |
| derivability oracle exactness in E1 | `r8_deriver_inexact.py` | see m13 |
| Mem(D_n) maximality claim | `r10_mem_not_max.py` | see m4 |
| fixed-weight soundness | `r9_fixed_weight_ville.py` | see M3 |

---

## 2. Issues

### Fatal

None.

### Major

**M1. E2's early unsound lumping is largely a pool artefact; its frequency is misreported.**

* *Claim* (summary item 2; §4 finding 2; §12 problem 4; E7 table). "In 3 of 5 seeds an *unsound* lump of the rarely
  used Q axioms has mass ≥ 0.997 at some n ≤ 32." "A threshold verifier with δ = 0.05 then accepts a false
  sentence." MAP at n = 8: "DTRC(n=16) ×3, Q-lumped ×2".
* *Problem.*
  * **The pool is missing the natural competitor.** The hand pool has T* minus *one* Q axiom (7 theories). At
    n = 8 typically 3–5 axioms are unseen. The pool lacks SeenQ(D_n) := {Q axioms occurring in D_n} + T_Ind. Like
    Mem(D_n), this theory depends only on data already seen, and it is sound.
  * **Its sound stand-ins use data the learner has not seen.** DTRC(n=16), skel4/6/8 (first 40 data) and Q+min
    (first 64) are built from data later than n (notes §1.8 says so). DTRC(n=16) is the n = 8 MAP in 3 seeds, so
    the posterior at n = 8 is over theories that use data 9–16. Worse for soundness, these stand-ins often contain
    axioms not yet seen, so they pay prior bits that SeenQ does not. That makes the lump look better than it is.
* *Evidence* (`r2_e2_seenq.py`, `.out`). Data are the track's E2 streams and the pool posterior comes from the
  track's pipeline. SeenQ and Q-lumped are scored independently with `ref_core`; the Q-lumped score agrees with
  the track's to 6.8·10⁻¹³. A duplicate is not added when SeenQ equals a pool theory.
  * **Seeds 0–4.**
    * n = 8, seed 1: SeenQ beats Q-lumped by 19.1 bits. Unsound mass goes from 1.000 to 3.5·10⁻⁶.
    * n = 8, seed 4: SeenQ beats Q-lumped by 0.7 bits. Unsound mass goes from 1.000 to 0.554.
    * n = 16, seeds 1 and 4: Q-lumped genuinely beats SeenQ, by 7.3 and 12.7 bits. Unsound mass is 0.997 and 1.0
      with or without SeenQ.
    * n = 32, seed 2: skel4 drops from 1.000 to 0.848, which is below the δ = 0.05 acceptance level.
    * So the δ = 0.05 verifier accepts a false probe in **2 of 5** seeds (1, 4), not 3.
    * Where SeenQ is not already in the pool, it beats the best sound pool theory by 17.6, 66.0, 16.6 and 29.4 bits
      (seeds 0, 1, 3, 4 at n = 8). The sound stand-ins were that far from the best sound explanation.
  * **Seeds 0–24.**

    | n | seeds accepting a false probe at δ = 0.05, track pool | with SeenQ added |
    |---|---|---|
    | 8 | 18/25 | 1/25 |
    | 16 | 3/25 | 3/25 |
    | 32 | 2/25 | 0/25 |
    | at some n ∈ {8, 16, 32, 64} | 19/25 | 4/25 |

    Under the track's own pool, seeds 5–24 lump far more often at n = 8 (16/20) than seeds 0–4 (2/5). So the
    reported "3 of 5" is also not representative of the track's own pool.
  * **E7 (`r3_e7_seenq.py`).** With SeenQ added, the mean unsound mass at n = 8 for (λ, τ) = (1, 0) falls:
    * seeds 0–4: 0.401 → 0.111;
    * seeds 0–24: 0.720 → 0.115.

    The λ = 2 finding survives in direction. With SeenQ, the MAP at n = 8 is unsound in 19/25 seeds (track pool:
    25/25) and in 4/5 of seeds 0–4 (track: 5/5).
* *Fix.*
  1. Add SeenQ(D_n) (and, generally, "seen axioms + seen schemas") to the pool.
  2. Build data-derived theories from D_n only. If that is too costly, at least report results with and without
     future-built theories.
  3. Report frequencies over ≥ 25 seeds.
  4. Restate finding 2. Unsound lumping of rarely used Q axioms occurs at n ≈ 16 in about 4/25 streams under this
     prior, when about five axioms have each been cited once. It is not the n = 8 norm.
  5. Re-run E7 with the extended pool.

**M2. E6 mislabels strictly weaker theories as "logically equivalent".**

* *Claim* (§8 setup and finding 1; summary item 6; e6 docstring). "L1 identifies the generating axiomatisation among
  logically equivalent ones (∀x∀y against ∀y∀x, the schema, and mixed forms)". The docstring adds: "with Gen and
  open elim terms all five generate the same theorems".
* *Problem.* S_ab = {?a+?b = ?b+?a}, M_x = {∀x x+?b = ?b+x} and M_y have *closed* guards (the `Component` default;
  `e6_equivalent.theories()`). So their axioms are closed instances. They do not prove A_xy = ∀x∀y x+y = y+x.

  **[proved] S_ab ∪ M_x ∪ M_y ⊬ A_xy.**

  *Proof.*
  1. Take the domain ℕ ⊔ {α, β}, with 0, S, +, · standard on ℕ.
  2. Set S(α) = α and S(β) = β.
  3. For n ∈ ℕ set α+n = n+α = α and β+n = n+β = β.
  4. Set α+α = α, β+β = β, α+β = α and β+α = β.
  5. Define · arbitrarily on the new elements.
  6. Every closed term denotes a natural number, so every instance of S_ab holds.
  7. Every instance ∀x(x+t = t+x) of M_x, with t closed and denoting some n, holds: for x ∈ ℕ by ℕ, and for
     x ∈ {α, β} by step 3. The same goes for M_y.
  8. α+β = α ≠ β = β+α, so A_xy fails.

  By soundness of first-order logic, A_xy is not derivable. ∎

  Gen cannot help: closed-guard bodies never contain w0. Even with open guards, the single-parameter convention
  cannot reach ∀x∀y. Only A_xy and A_yx are logically equivalent.
* *Consequences.*
  * Finding 1 is about telling apart *non-equivalent* theories with the same closed instances (an ω-gap
    situation, as in E1), except for A_xy against A_yx.
  * Finding 2 ("the method cannot prefer the textbook axiom to its variants") mixes equivalent variants with
    strictly weaker ones.
  * Under L1sel, the mass on theories proving commutativity is only 0.044 + 0.044 = 0.088 (A_xy, A_yx; `r7_misc.out`).
    This is the Bayesian ω-gap of E1 again, not a tie among equivalents.
* *Fix.*
  * Relabel: A_xy ≡ A_yx; S_ab, M_x, M_y are instance-equivalent (same closed instances) but strictly weaker.
  * Report P(T ⊢ A_xy | D) under L1sel (0.088).
  * To test genuinely equivalent axiomatisations, use pairs such as A_xy/A_yx, the pa track's Ind/IndSwap under
    L1, or Q5 written as x+Sy = S(x+y) against Sy+x = S(y+x) together with commutativity.

**M3. The summary's soundness promise omits the hypothesis that makes it true.**

* *Claim* (summary, "What can be promised"). "If the data are i.i.d. from a theory in the pool … The threshold
  verifier is time-uniformly sound with probability 1 − δ′ for δ ≤ 2^(−bits(T*))·δ′, for any pool containing T*."
  §4 finding 2 adds that the E2 failures do not contradict this because "its guarantee needs δ ≤ 2^(−226)·δ′".
* *Problem.*
  * Prop X8(a) is correct, but only for data drawn from the Dirichlet-averaged law M_{T*}: first w ~ Dir, then
    i.i.d.
  * E2, E3(b) and E4-C1 use *fixed* weights (0.05×7, 0.65). For fixed weights only X8(c) applies, with a threshold
    shrinking like R(n, m) ≍ n^(−(m−1)/2); for T*, m = 8, so n^(−3.5).
  * A constant threshold at a fixed weight vector can fail outright. The parallel model track found this
    (`../model/notes-final.md`, Example 4.9).
  * X5 has the same blind spot. Doob's theorem gives consistency only for prior-almost-every parameter, so it says
    nothing about the fixed w of E2 and E3. [known: Doob 1949, *Le Calcul des Probabilités et ses Applications*,
    Colloques Internationaux du CNRS 13, pp. 23–27; the a.e. qualification is standard, e.g. Miller, "A detailed
    treatment of Doob's theorem", arXiv:1801.03122.]
* *Evidence* (`r9_fixed_weight_ville.py`, `.out`). This is independent code in this track's setting: L0, Dir(½, ½)
  weights, T* = {0+0=0, S?z+0=S?z} against T′ = {?z+0=?z}, root law (0.5, 0.5−ε, ε/2, ε/2), prior ½ each, δ = 0.01,
  nominal bound δ/π(T*) = 0.02. The table gives the probability of ever accepting the underivable (0·0)+0 = 0·0,
  checked on a grid of n ≤ 2·10⁶ (a lower bound), 300 runs each.

  | ε | fixed w*, constant δ | w* ~ Dir(½, ½), constant δ | fixed w*, shrinking δ_n (X8(c)) |
  |---|---|---|---|
  | 10⁻⁵ | 0.860 | 0.007 | 0.000 |
  | 10⁻⁶ | 1.000 | 0.013 | 0.000 |

* *Fix.*
  * State in the summary: "data drawn from the Dirichlet-averaged law of T* (weights drawn from the prior); at a
    fixed weight vector the threshold must shrink like n^(−(|T*|−1)/2) (X8(c))".
  * Correct §4 finding 2 accordingly.
  * Restrict X5 to prior-a.e. weights, or cite a result valid at every interior w (e.g. Schwartz 1965, as the
    model track does).
  * X8(c) can be upgraded from "proof sketch" to "proved": the argument given is complete, and it is the model
    track's Thm 4.8 with Lemma 4.6.

**M4. "Robust at the level of theorems" in PA rests on motive laws that use connective roots.**

* *Claim* (summary item 3; §5 finding 5). "In PA, when T* loses, the winners are fragments of induction that are
  deductively equivalent to T* (Prop X9). So the result is robust at the level of theorems but not of axioms."
  Finding 5: "theorem-level identification survives".
* *Problem.* The three motive laws tested (dtrc-motive, root-skew, deep) all use connective roots. Prop X9(b) makes
  a connective fragment equivalent to T_Ind; X9(c) says nothing for atomic roots. Induction instances in human
  practice often have atomic motives (0+x = x, x+y = y+x with y fixed, …). Under such data the posterior should go
  to atomic fragments, which are weaker.
* *Evidence* (`r6_e3_extensions.py`, part (c); `.out`).
  * **Setup.** E3(b) as published (same weights, the same pool including T* + T_f for every root f, L0), but with
    motives drawn as a(x) = b(x) (probability 0.6) or a(x) < b(x) (0.4), with a and b from Q with one hole. Every
    datum is still a theorem of T*.
  * **Result.** At n = 1024 the MAP is frag-observed64 = Q + {T_=, T_<} with mass 1.000 in all 5 seeds. (Here it
    coincides with frag-atoms, which the pool's dedupe removed.) The mass on theories tagged equivalent to T* is
    0.000 in all 5 seeds. At n = 64, T* had 0.988 in 4 seeds, so the posterior moves *away* from T* as data
    accumulate.

  **[proved, given two known facts] Q + {T_=, T_<} is strictly weaker than T*.**
  1. **T* proves the parametrised induction schema.** For a motive φ(x, w), take the parameter-free motive
     ψ(x) := ∀w[(φ(0, w) ∧ ∀y(φ(y, w) → φ(Sy, w))) → φ(x, w)]. Then ψ(0) is a tautology, and ψ(x) → ψ(Sx) follows
     by applying the step to φ(x, w). So T* ⊢ ∀xψ(x), which gives induction for φ. Hence T* ⊇ Q + full induction =
     PA.
  2. **PA proves that √2 is irrational**, i.e. ¬∃x∃y(¬y = 0 ∧ x·x = (SS0·y)·y). [known; standard]
  3. **Open induction does not prove it.** Q + {T_=, T_<} is contained in Q + open induction, and that theory has
     a model in which x² = 2y² has a solution with y ≠ 0. [known: Shepherdson 1964, *Bull. Acad. Polon. Sci.* 12,
     79–86, "A non-standard model for a free variable fragment of number theory". I checked the bibliographic
     record and later summaries, not the paper. Its model is an integer part of a real closed field, which
     satisfies Q's seven axioms with Sx := x+1.]

  So the posterior concentrates on a sound but strictly weaker theory. It does not keep T*'s theorems:
  * it fails to prove some PA theorems, for example the irrationality of √2;
  * it cites no induction instance with a non-atomic motive.
* *Fix.* Restate summary item 3 and finding 5: theorem-level robustness held for the three motive laws tried, all
  of which use connective roots. Under an atomic motive law the posterior moves at a linear rate to atomic induction
  fragments, which are strictly weaker. Add this generator to E3(b).

**M5. The brief's explicit question on derivation likelihoods and MDL fragmentation is not addressed.**

* *Claim/omission.* The brief asks the track to engage with `AS:sec:many:mdl` and to "say whether a
  derivation-based likelihood changes it".
* *Problem.* Every PA experiment (E2, E3(b), E7) uses L0 (citation). E3(a) runs L1 only on single-schema instance
  data, where L1 adds just the X6 factor, and its MAPs coincide with L0's. Notes §10 points to track pa §2 for the
  question. So the track itself provides no evidence either way.
* *Fix.* Run E2/E3(b) under L1 with an MP major premise for induction (A → B with A the base and step). The
  current chain grammar cannot use a derived conditional, so this needs the tree grammar of open problem 2. If the
  question is left to the pa track, say so in the summary.

### Minor

* **m1. The "brute force" in the tests is not independent.** `test_l1_guided_equals_bruteforce_*` compares the same
  `Chain` class with `guided=False`: it shares Q, `rules()`, the recursion and the stop factors, and differs only
  in the predecessor enumeration. `checks/check_x6.py` compares L1 output with L1sel output from the same code, not
  with the prior. *Evidence:* my independent reimplementation agrees (R1(g), R4), so no bug follows. *Fix:* keep an
  independent reference, such as `referee_code/ref_core.py`.

* **m2. X5's wording is imprecise.** "Concentrates on the theories whose marginal law equals that of T*" needs the
  de Finetti mixing measures of the other theories to be mutually singular with that of T* (true generically, not
  argued). It also needs the a.e. qualification (M3). *Fix:* state the hypotheses, or cite the model track's
  Corollary 2.3 / Theorem 5.1 by exact number.

* **m3. Cross-references point to superseded drafts.** The notes cite `../model/notes.md`, `../universal/notes.md`
  and `../pa/notes.md`. The model and universal tracks now have `notes-final.md`, with Thm 4.1 re-scoped to fixed
  weights and new Thm 4.7/4.8 that are exactly X8(a)/(c). *Fix:* update the references.

* **m4. The reason given for using Mem(D_n) alone is wrong under L1.** §1.8 says Mem(D_n) has the largest
  posterior among memorising theories "(any extra sentence costs prior bits and a Dirichlet factor)". Under L1 an
  extra ground sentence such as ∀xφ can also *raise* the likelihood, because it derives other data. *Evidence*
  (`r10_mem_not_max.out`): on E1 sch data the claim still held, with Mem + {∀x x+0=x} 11–16 bits worse. But the
  margin shrinks with n (−14.4 → −11.2 bits from n = 16 to 256, seed 0). *Fix:* restrict the claim to L0, or add
  Mem(D_n) + {each ground ∀-sentence in the pool}.

* **m5. Held-out PA instances are not held out.** In E2, held-out induction instances also occur in the training
  stream:
  * seed 0 at data 39, 184, 341;
  * seed 1 at 79, 486;
  * seed 2 at 25;
  * seed 4 at 91 (`r7_misc.out`).

  At citation depth this is harmless, because every theory with T_Ind cites them anyway. *Fix:* draw held-out
  sentences from outside the training stream.

* **m6. E4(B, C) checks the verifier at 88 of the 256 values of n.** These are every n ≤ 64, then every 8th. "No
  wins" and "first win" are claims about these checkpoints only (`r7_misc.out`). *Fix:* check every n, or say so.

* **m7. The E7 time-factor result holds by construction.** "The time factor does not bite inside DT°" follows from
  the chosen factor τ·log₂(1+|T|), which differs by at most a few bits between any two pool theories. The
  experiment cannot falsify H6. *Fix:* call it a consequence of the definition. The informative test is a time
  penalty on derivation search, or against non-template axiom sets (§3).

* **m8. The L1sel description is ambiguous.** L1sel is per-citation rejection ("each citation of component i is
  repeated until …"). This is not the same law as filtering the output stream of a multi-component theory, which
  gives Σ_i w_i a_i(d)/Σ_i w_i c_i instead of Σ_i w_i a_i(d)/c_i. The E6 generators have one component, so the
  data match the model there. For multi-component pool members (A_xy+A_yx, A_xy+S_ab, Mem) the likelihood is a
  modelling choice. *Fix:* one sentence in §1.7.

* **m9. Wording in summary item 1.** "Stays at the prior share of H_∀ (0.48 or 0.27, L1sel)" should read "the prior
  share of the ∀xφ-provers among the likelihood-tied theories (H_∀, H_sch, H_∀+sch, …)". The numbers are right
  (`r4_e1_table.out`: 0.484, 0.269).

* **m10. Wording in E5(c).** "The sequence is a text for L_∞" holds only if every stage ends. That is shown for 14
  stages. *Fix:* "the first 14 stages of a sequence which, if every stage ends, is a text for L_∞".

* **m11. E3(a)'s gains are compared across likelihoods.** "The gains double when n doubles (heavy: 74–79 bits at
  n = 512 under L1, 140–178 at n = 1024 under L0)" compares L1 at 512 with L0 at 1024. The L0 means are 76.3
  (n = 512) and 165.5 (n = 1024), so the claim holds within L0. *Fix:* compare within one likelihood.

* **m12. E3(a)'s named winners sit at the edge of hand-built families, so they are artefacts.**
  * *Claim.* E3 table: numerals → "N_4 (from n = 128)"; heavy → "{φ(?t), φ(S?z)} (from n = 128)".
  * *Problem.* N_m is in the pool only for m ≤ 4, and nested S-chains only to depth 1. Both winners are the largest
    members of their families.
  * *Evidence* (`r6_e3_extensions.out` (a), (b)).
    * With N_5…N_16 added, the numerals MAP is N_9 or N_10 at n = 512, and N_11 or N_12 at n = 1024 (mass 0.61–0.996).
      The optimum keeps growing with n.
    * With C_2 = {φ(?t), φ(S?z), φ(SS?z)} added, C_2 is the heavy-data MAP at n = 512 and 1024 in all seeds (mass
      1.000). Deeper chains would need more than 3 overlapping components, which is beyond the track's exact DP.
  * *What survives.* The qualitative findings hold and are, if anything, strengthened: an over-specific theory wins
    on numerals; a theory with the same instance set wins on heavy tails.
  * *Fix.* Name winners as "a member of the N_m family (the largest available)", or extend the families until the
    MAP is interior.

* **m13. The derivability oracle's fallback counter is not reported.** `posterior.Deriver` has its own `Chain`.
  When a term has more than `max_occ` occurrences, the oracle drops predecessors (TooManyOccurrences), which can
  make "derives" falsely "does not derive". E1 reports only the likelihood chains' `inexact` counters.
  *Evidence* (`r8_deriver_inexact.out`). I re-ran all 75 E1 jobs with the oracles recorded: 5896 derivability
  queries, and the fallback was never triggered. So no E1 number is affected. I did not check E3(a) and E4, which
  use the same oracle on similar data. *Fix:* report the oracle's counter as well.

* **m14. Small sample sizes behind rate claims.** The E5(a2) slope (−0.259 against the conjectured −0.25) uses 200
  draws per n. My independent exact Beta-moment sum (`r5_e4_e5.out`) gives −0.233 over n = 10²…10⁷ with 40 draws,
  and per-decade slopes fluctuate. Both bracket −α/2 = −0.25, so the support for Prop X7(b) is real but loose.
  *Fix:* report a standard error for the fitted slope.

---

## 3. Questions from the brief that the track did not address

1. **Derivation likelihood and the MDL fragmentation finding in PA** (brief, "MDL subsection"). See M5.
2. **The time penalty against Hänni's collapse** (H6). The brief asks whether templates plus a time penalty block
   the collapse construction "T(⌜φ⌝) = accept → φ". The track tests only a log-size factor inside DT° (m7) and
   defers to model §6. No experiment prices the running time of a non-template assigner.
3. **The "do not contradict" variant** from Hänni's note, listed in the brief among the likelihoods to compare, is
   not implemented.
4. **H7 beyond E2.** None of these is tested in this track:
   * data from Th(ℕ) and the IΣₙ chain;
   * Q+Ind against Q+LNP or strong induction under a derivation likelihood;
   * Replacement against Collection.

   E6 was meant to cover equivalent axiomatisations but mostly compares non-equivalent ones (M2).
5. **H3's relation to the cautious verifier** (the δ → 0 limit) is not discussed. It is in model `notes-final.md`
   Prop 4.3.
6. **A derivation-length prior on data "given without proof"** is represented only by the geometric stop of the
   chain, with K ≤ 2. It has no tree derivations and no MP with a derived major premise. Induction followed by
   ∀-elimination, the PA case the brief has in mind, is therefore outside L1 (acknowledged in §11 and open problem 2).
7. **Human-written data.** Every "well-specified" run uses the model's own generator, and the misspecified ones
   perturb its term or motive law. No run uses a list of textbook theorems, which is what "the axioms we actually
   have" would be learned from.
8. **Search beyond a pool** (open problem 1). M1 and m12 show that the reported winners depend on pool contents.
   That makes this the main missing piece for the user's question "does it robustly pick up the actual axioms?".

---

## 4. Claims checked and confirmed

**Proofs read line by line, and confirmed.**

* **X1 (L0 exact)**: correct, given unique DT° matching.
* **X2 (Dirichlet sum)**:
  * (a) and (b) are correct.
  * (c) is correct: the concavity bound f(w*) ≤ f(w) + max_i ∇_i f(w) − n uses w·∇f = n.
* **X3 (L1 proper)**: correct.
* **X4 (exact backward recursion)**:
  * (a) holds: x occurs only at rigid positions, so (Bθ)[t/x] = Dθ′ and the matcher is unique.
  * (b) holds: the product form and the sum over nonempty S are correct. Two distinct terms cannot give the same
    predecessor, since x occurs.
  * (c), (d) and (e) hold.
* **X6**: correct.
* **X7(a)**: correct. The ratio Γ((m+1)α)Γ(mα+n)/(Γ(mα)Γ((m+1)α+n)) does not depend on the assignment.
* **X8 (a), (b)**:
  * Prior normalisation is correct: Σ_m 2^(−γ(m))(Σ_c 2^(−bits(c)))^m ≤ 1. Guard bits are counted once per
    metavariable, so the Kraft sum over (template, guards) pairs equals that of the structure code.
  * The supermartingale and the pathwise inequality π_R(T*|D_n) ≥ 2^(−bits(T*))/Z_n hold for any R_n ⊆ F, even
    one built from future data.
* **X8 (c)**: correct as written. The termwise bound DirMom(c) ≥ R(n, m)·Π w_i^{c_i} holds because
  Π(c_i/n)^{c_i} = max_w Π w_i^{c_i}. The argument is complete; see M3 for the label.
* **X9 (fragments of induction)**:
  * (a) holds: every motive body has one of the 9 roots.
  * (b) holds: each chosen ψ is logically equivalent to φ, including ∃y φ(x) ↔ φ(x) on nonempty domains, and
    Ind(ψ) ↔ Ind(φ) by substitution of equivalents.
  * The claim in E2 finding 3 that frag-complete contains T*'s law (weights w_Ind·q(f)) is exact under §1.2's
    grammar. Holes and bound variables are counted alike, so a body in context (nh = 2, nb = 0) and one in
    (nh = 1, nb = 1) have the same probability.

**Computations re-derived independently.**

* **E1** (`r4_e1_table.out`):
  * every entry of the notes' table: generator masses at n = 4, 8, 32, 256; MAPs; P(⊢∀xφ); worst first n;
  * Mem ≤ 2.4·10⁻¹² and over-general ≤ 7·10⁻⁵ at n = 8 on sch data;
  * P(⊢ held-out) ≥ 0.999 from n = 8, except open/L0 (0.0);
  * L1sel limits 0.484 and 0.269;
  * no held-out instance occurs in any E1 training stream (`r7_misc.out`).
* **E2**:
  * the track's numbers reproduce, including first-appearance indices 64, 37, 65, 54, 26;
  * spare-false: 7.8 bits at n = 512, predicted −log₂ of the Dirichlet factor plus 4.2 prior bits gives 7.75;
  * growth rates 0.45 and 0.27 bits per doubling.
* **E3**: reproduces exactly (`repro/e3_misspec.md`).
* **E4**:
  * (A): t* = 150, 680, 10, 47, 17; P(win) = 0.00046, 0.00108, 0.00098, 0.00707, 0.02252; ratio to the bound
    22.0, 46.5, 10.2, 14.1, 8.9 ("9–46 times below": confirmed). Source: `r5_e4_e5.out`.
  * (C1): 200/200 wins over both likelihoods, first win at n = 1–39 (median 7), queries 0+0=1 (196) and 2+0=3 (4)
    (`repro/e4_ville.json`).
* **E5**:
  * (a): unused-spare factor −1.00, −2.84, −4.83, −6.83 bits.
  * (a2): the track's quadrature agrees with an exact Beta-moment sum to 3·10⁻⁴ bits at n up to 10⁶.
  * (b): prior bits 10.9 / 89.4 / 187.9 / 17.1; the L_5 switch between n = 64 (2.4·10⁻⁶) and 128 (0.66).
  * (c): identical stage lengths 1, 24, 81, 115, 104, 83, 68, 55, 45, 39, 33, 33, 32, 27 (740 data).
* **E6** (`r7_misc.out`):
  * L1 generator mass ≥ 0.99 from n = 4 (A_xy, M_x) and n = 16 (S_ab), every seed;
  * L1sel masses equal the prior shares (0.044, 0.044, 0.128, 0.392, 0.392), with spread over seeds and n ≥ 8 of
    9·10⁻¹⁴;
  * redundant pairs ≤ 1.1·10⁻⁹.
* **E7**: the track's pool numbers reproduce (0.401 / 0.399 / 0.203 unsound at n = 8 / 16 / 32).
* **Prop X8(c) regret slopes** (`checks/kt_regret.out`) are consistent with the KT rate (also model track
  Lemma 4.6(c)).

**References.**

| reference | status |
|---|---|
| Krichevsky and Trofimov 1981, "The performance of universal encoding", IEEE Trans. Inform. Theory 27(2):199–207 | exists. The (m−1)/2·log n regret of the KT mixture is the standard result attributed to it; I did not read the paper itself. |
| Doob 1949 | exists (CNRS Colloques 13, pp. 23–27). States prior-a.e. consistency (see M3). |
| Harris 1963, *The Theory of Branching Processes* | exists (Springer Grundlehren 119). The notes also give a direct argument, which I checked. |
| `AS:` labels `thm:setting:matching`, `sec:setting:syntax`, `sec:many:mdl`, `app:many:mdl`, `prop:many:mdlwell` | all exist. `many.tex` l. 365–366 says what the notes attribute ("MDL tracks the statistics of usage …; errs towards unsoundness for rarely used ground axioms"). |
| `IL:` labels `thm:caution:ville`, `lem:app:caution:ville`, `prop:caution:tight` | all exist. The tight value 0.989δ′ matches the notes' "reaches 0.99δ′". |
| cross-track numbers (universal Thm U2, U10, Prop U6, Thm B; model Prop 2.5, Thm 4.1, Prop 4.2, Prop 5.2, Prop 5.5; pa §2, §4) | exist in the drafts cited. See m3 for renumbering in the final versions. |

---

## 5. Severity count

* **Fatal:** 0.
* **Major:** 5.
  * M1: E2 pool artefact.
  * M2: E6 non-equivalent theories called equivalent.
  * M3: the summary's soundness promise lacks the Dirichlet-averaged hypothesis; constant thresholds fail at fixed
    weights.
  * M4: theorem-level robustness refuted for atomic motives.
  * M5: the derivation-likelihood MDL question is unanswered.
* **Minor:** 14 (m1–m14).

The implementation is trustworthy. Every core probability was reproduced independently, and every result file
reproduces exactly. The interpretive claims built on hand-made pools (E2, E3) and the E6 framing need revision as
described above.
