# Honesty review: overclaiming, scope and novelty

Reviewer lens: overclaiming, scope and novelty across the whole paper. Sources checked: every section and the Lean
appendix in `paper/sections/`, the abstract and introduction line by line, the theory files T1–T7 (with their
novelty assessments and verification logs), `research/verification/reverification-round2.md`, the L9 memo (§5.2),
`code/README.md`, `code/results/{algebra_learning,prop_learning,prop_learning_quick,adversarial_prover}.md`,
`lean/README.md` and `lean/audit-output.txt`, and `paper/bib/all.bib`.

## Overall verdict

The body of the paper is unusually careful. Most sections say which results are "trivial once set up", "known in
substance" or "standard", and they credit Plotkin–Reynolds, Natarajan, Helmbold–Sloan–Warmuth, Rivest–Sloan, KWIK,
El-Yaniv–Wiener, Waudby-Smith–Ramdas, Post/Pogorzelski, Glivenko, Littlestone, Reiter, Shapiro, Scott,
Shoesmith–Smiley, Brown–Priest, information-based complexity, de Finetti, Gaifman and others where the results are
proved. The experiments section explicitly says the experiments are not evidence of scale. The physics section
ends with an honest "what is and is not established" paragraph. The checking-first framing ("we build a checker,
not a solver"; "we have deliberately not built a strong prover") is consistent across §1, §11, §12 and §14. Lean
claims match `lean/README.md` and `audit-output.txt`: no `sorry`, 17 modules, about 14.6k lines, 483 audited
declarations, and 49 rows in the map table, of which about 15 are special cases, weaker results or variants.
Experimental numbers quoted in §§3, 5 and 12 match the result reports. I checked AUC 0.995, 16.3/23,
32.3/33, 900,305 queries, the retraining figures, 96.5% meadow-sound, 67/92/100% shape recovery, 102±11 and
18.5±3.6 spurious schemas, and the B table.

The honesty problems are concentrated in the **abstract, the introduction (answers in brief and the
success-criteria table) and the philosophy section**. Several of these summaries are stronger than the theorems
in the body they summarize. One of them (identification "up to informal-validity equivalence" for the bounded-gap
verifier) re-asserts, in unqualified form, a statement that verification found **false** (T4 Thm 3.4(d), fatal
item A1). Some novelty claims omit credit that the project's own source files give (T6 on LMS completeness), or
that a specialist would expect (Ville tightness; the marginal problem). Two places in §6 report a **single
quick-run smoke test** in place of the full-grid numbers that §12 reports, which overstates what coherence
achieved. And the intro misstates the verification record ("one theorem needed a second repair round").

Counts: 1 fatal, 18 major, 13 minor.

---

## Fatal

### F1. "Identifies validity exactly up to informal-validity equivalence" is false for the bounded-gap verifier

* **Files and locations:** `abstract.tex` line 10; `intro.tex` lines 66 and 102 (table); `philosophy.tex` line 168
  (table) and the "More than role is not identifiable" bullet (§14.5).
* **Problem.** The abstract says "A bounded-gap verifier is sound against adaptive provers and identifies validity
  exactly up to informal-validity equivalence". The body (Thm `thm:informal:identify`) says something different.
  (c) Exact identification up to ≈ on D\* holds only for closure-level complete presentation, with unanimity on
  ⊨_h, a finite class and realizability. (d) Under bounded-gap data, the survivors are S^g, V^g accepts exactly
  St^g_{h\*}, and meaning is only *bracketed*. It is identified only under step-expressiveness, and
  `ex:informal:weaker` gives a strictly weaker rival that survives. This is exactly the original T4 Thm 3.4(d),
  which the T4 verification log classifies as **fatal** (A1: 527 mismatches out of 2604). The abstract, the
  intro and the philosophy tables restate the refuted version. The informal section's own intro paragraph and its
  "answer to success criterion 2" state it correctly.
* **Fix.**
  * Abstract: "A bounded-gap verifier is sound against adaptive provers, relative to realizability of the latent
    formalization. Under complete closure-level data the practice's validity relation is identified exactly up to
    informal-validity equivalence and no finer. Bounded-gap data identify only the short-step relation and bracket
    meaning, exactly so when long inferences decompose into short steps through the practice's own sentences."
  * `intro.tex` line 66: "Under complete closure-level presentation, validity is identified exactly up to
    informal-validity equivalence, and no finer. Bounded-gap data identify the g-step relation and only bracket
    meaning, which is pinned under step-expressiveness (`thm:informal:identify`(c),(d), `ex:informal:weaker`)."
  * `intro.tex` line 102 and `philosophy.tex` line 168: "…is sound and, for a finite class under complete
    presentation, identifies the practice's step relation and brackets its meaning (exactly up to
    informal-validity equivalence under step-expressiveness)".
  * `philosophy.tex` §14.5: "Under complete closure-level data, practice, coherence and object data identify…".

---

## Major

### M1. "Exactly convergent for complete decidable theories" is conditional on an unestablished hypothesis

* **Files and locations:** `intro.tex` line 101 (success table); `philosophy.tex` line 167.
* **Problem.** `cor:twotier:decidable` is titled "conditional on realizability". The text right after it says
  "*The realizability hypothesis is not established for the listed theories*": ∀E and induction are not
  first-order patterns, and without the hypothesis "exactness fails". The intro table nonetheless says "sound and
  exactly convergent for classical propositional logic and complete decidable theories". The philosophy table says
  "Yes for classical propositional logic and complete decidable theories".
* **Fix.**
  * Intro table: "…sound, and exactly convergent for classical propositional logic (`cor:twotier:cpc`). For
    complete decidable theories exactness holds conditional on a realizability hypothesis that is not established
    for any standard axiomatization, since ∀E and induction are not first-order patterns (`cor:twotier:decidable`).
    Without it the learner stays sound but loses those rules."
  * Philosophy table: "Yes for classical propositional logic. For complete decidable theories, only conditionally
    on an unestablished realizability hypothesis…".

### M2. Success criterion 3 is answered "Yes", but the body says only one toy checker run exists

* **Files and locations:** `intro.tex` line 103 (table), line 78 (EuPhO bullet); `philosophy.tex` table row "Can
  physics olympiad solutions be checked in a principled way?".
* **Problem.** The physics section's own summary says: "Not established: … a checker beyond one worked problem. The
  mini-checker … is not a system, and its own soundness is argued, not proved." It also says the EuPhO setup "has
  not been checked against the official text". Further, `thm:physics:relative` needs solutions written in the
  formal SPS calculus, and it needs the trusted base (TB1)–(TB3): kernel, law catalogue and a catalogue of
  *proved* bridge schemas. The intro answers "a principled system for checking physics olympiad solutions" with
  "**Yes**", and calls the example worked "end to end".
* **Fix.** Intro table, row 3: "**Partly: a checker design with a relative soundness theorem.** Solutions written
  in the Structured Physics Solution format are checked soundly against adversarial solvers, relative to a trusted
  base (kernel, law and bridge catalogues), the reading of the problem and the top model (`thm:physics:relative`).
  The reading and top-model layer is provably ineliminable (`thm:physics:judgment`). The design is illustrated on
  one EuPhO problem, whose setup was reconstructed and not checked against the official text, by a
  problem-specific prototype. No general checker has been built. We deliberately built a checker, not a solver."
  Add the same caveat to the philosophy table row.

### M3. The end-to-end theorem's key idealizations are missing from the abstract and intro

* **Files and locations:** `abstract.tex` line 9; `intro.tex` line 59; `twotier.tex` line 386 (Reading after
  `cor:twotier:cpc`).
* **Problem.** `thm:twotier:main` assumes the following:
  * realizability with fallacy tags "latent but distinct", i.e. each systematic fallacy is cited under its own
    rule name;
  * known floor constants (Floor);
  * (WS) for every designated position;
  * an exact depth-d refutation oracle, with cost exp(O(d)).

  Completeness modulo the residue holds only under (SB_d) or when no descent is blocked. Otherwise genuine
  collateral rules are lost. Twotier Remark (2) says that if fallacies are cited under genuine names, the class
  must be unions of schemas, and the theorem then does not apply as stated. Experiments A and B cite fallacies
  under genuine names ("each … cited as →E"). The intro says, without qualification, that the learner "is sound
  against every adaptive prover and red team, and it converges to the target modulo an explicit residue". The
  Reading in §7 says "From imitation of human proofs containing systematic fallacies…".
* **Fix.**
  * Intro line 59: "Assuming realizability (each systematic fallacy used under its own latent rule tag), a known
    frequency floor, truthful designation and an exact depth-d refutation oracle, it is sound against every
    adaptive prover and red team. Its asserted calculus is the target plus the depth-d residue, minus a set of
    collateral genuine rules when blame is ambiguous (`thm:twotier:main`). If fallacies are cited under genuine
    rules' names the theorem does not apply as stated."
  * Abstract line 9: append "under realizability with distinct fallacy tags and an exact refutation oracle".
  * `twotier.tex` line 386: "…human proofs containing systematic fallacies, each used under its own latent tag,
    and sporadic slips…".

### M4. The abstract never states the realizability and truthful-data conditions

* **File and location:** `abstract.tex` lines 6–10.
* **Problem.** The abstract says "Cautious acceptance over schematic hypotheses is sound against every adaptive
  prover" and "Positive examples identify a schematic calculus exactly". The paper calls realizability
  "load-bearing" (caution §4.5; twotier Remark 2; open problem 1), and truthful or well-specified data are
  hypotheses of every soundness theorem. The intro (line 136) states this. The abstract does not.
* **Fix.** Replace the sentence in line 6 with: "If the target is realizable in the hypothesis class and the data
  are truthful, cautious acceptance over schematic hypotheses is sound against every adaptive prover." Add before
  "Every main result…": "All guarantees are relative to stated assumptions, chiefly realizability of the target in
  a structured hypothesis class and truthful data and designations."

### M5. The robust-core *hypothesis* is presented as an established explanation or historical fact

* **Files and locations:** `intro.tex` line 69; `philosophy.tex` lines 132 and 174.
* **Problem.** `thm:informal:robust` is conditional on RCH_g, the user's hypothesis, which the paper never tests: "a
  corpus test of RCH" is listed as open. The informal section says correctly: "*if* pre-formal practice used only
  steps valid under every admissible sharpening, its proofs survive". Three places overstate this:
  * The intro says "A robust-core theorem explains why informal mathematics survived formalization".
  * The philosophy section says "It *was* a bounded-gap practice over a latent calculus" and "paradoxes were rare
    and uninformative". The second contradicts §10, where Russell's paradox "is a bag of size one".
  * The philosophy table states "Practice used only the robust core of its vague concepts" as fact. It also omits
    that `prop:informal:emergence` needs an idealized complete monster presentation and an extra, unproved
    hypothesis (3) for a bounded gap.
* **Fix.**
  * Intro: "A robust-core theorem shows that *if* pre-formal practice used only steps valid under every admissible
    sharpening of its vague concepts (the user's robust-core hypothesis, untested here), its proofs survive every
    formalization (`thm:informal:robust`)."
  * Philosophy line 132: "In our model it is a bounded-gap practice over a latent calculus. If the robust-core
    hypothesis holds, its proofs survive every admissible formalization. In the episodes of `tab:informal:history`
    the corrective work was done mostly by counterexample objects, and the few paradoxes were the set-theoretic
    antinomies (`sec:informal`)."
  * Philosophy line 174: "In the model, under an idealized complete presentation of monsters, monster pressure
    leaves exactly the steps valid in every model of the theory, and Gödel completeness turns those into
    derivations. A bounded gap needs a further, unproved hypothesis (`prop:informal:emergence`(c)). If practice
    used only the robust core of its vague concepts, its proofs survive every formalization
    (`thm:informal:robust`)."

### M6. "Counterexample objects are exponentially more informative than paradoxes": the body says "can be"

* **Files and locations:** `abstract.tex` line 10; `philosophy.tex` line 168.
* **Problem.** The theorems give M_obj ≤ log2|H| and M_obj ≤ M_bag, and they show M_bag = |H|−1 on specific classes
  (single culprit, sorites). They do not show an exponential gap for every class: at r = 1 the two are equal, and
  §10 notes that "'Paradoxes are worthless' … is false in general". §10's own summary says "*can be* exponentially
  more informative".
* **Fix.** "Counterexample objects can be exponentially more informative than paradoxes: at most log2|H|
  corrections, against up to |H|−1 on some classes (the sorites is the tight case)."

### M7. "Carnap's problem turns out to be Gold's problem", but the body says "only in part"

* **Files and locations:** `abstract.tex` line 8; `intro.tex` line 52.
* **Problem.** The body (`coherence.tex` line 352 and `tab:coherence:goldcarnap`) says: "Carnap's problem is a
  semantic twin of Gold's *only in part*". Gold's failure is learnability and Carnap's is identifiability, and the
  remedies differ. The abstract and intro assert identity.
* **Fix.**
  * Abstract: "Carnap's categoricity problem can be read, in part, as Gold's problem in the dual space of
    valuations."
  * Intro: "Carnap's categoricity problem is, in part, Gold's problem in the dual space of valuations
    (`tab:coherence:goldcarnap`): single-conclusion data cannot fix…".

### M8. "Eternalism is provably impossible" overstates `thm:physics:eternalism`

* **Files and locations:** `abstract.tex` line 11; `intro.tex` line 74.
* **Problem.** The theorem rules out only *truth-functional* readings τ(c,φ) = f(S_c^w, φ^w), and T3 lists it as
  trivial once set up. Non-truth-functional context-free readings are not excluded. McCarthy's ist(c,φ), which the
  paper adopts, is itself a context-independent proposition.
* **Fix.**
  * Abstract: "Contexts are given a filter semantics; no truth-functional eternal reading of in-context claims
    tracks truth in an idealized context."
  * Intro line 74: "No truth-functional eternal reading tracks truth in an idealized context
    (`thm:physics:eternalism`, an observation once set up)."

### M9. The verification record is misstated

* **Files and locations:** `intro.tex` line 118; `abstract.tex` line 15.
* **Problem.** The intro says "One theorem needed a second repair round". The record says otherwise:
  * `reverification-round2.md` lists two round-2 *major* problems in T7, Thm 5.5 (burn-in) and Thm 6.6(e)
    (whose bound was false), plus a size-convention issue.
  * It lists two round-2 majors in L3. L3's verification log has no round-2 section.
  * `twotier.tex` line 46 says that three second-round repairs "were checked by their author and by computation,
    not by a further independent referee".

  "Every main result passed adversarial verification" is therefore too strong for `thm:twotier:burnin` and
  `thm:twotier:arith`(e) in their final form.
* **Fix.**
  * Intro: "…Each was repaired, weakened or retracted, and fresh referees re-checked the repairs. That second
    round found two further major problems in §7 (`thm:twotier:burnin`, `thm:twotier:arith`(e)) and two in glosses
    of literature memo L3. The §7 repairs, and the size convention of `def:twotier:refutation`, were checked by
    their author and by computation only, not by a further referee."
  * Abstract: "Every main result was attacked by independent referees and repaired where needed; a few
    second-round repairs (§7) were checked only by their author and by computation."

### M10. Section 6 reports a single quick smoke-test run instead of the full Experiment B grid

* **File and locations:** `coherence.tex` lines 171, 421; also 191 and 367 and the header comment.
* **Problem.** Line 171 says "accepted all 13 valid and refuted all 44 invalid structural candidate schemas
  (computed; quick run)". The full run reported in §12 and `prop_learning.md` has 177 candidates: 59 valid, 118
  invalid. Line 421 reports one quick run (N=50) in which coherence "removed every unsound rule … the adversary
  proved none of its goals". The full grid shows something weaker:
  * for noise `both` with N ∈ {50,100,200}, 1.2±0.9 unsound rules remain and there are 1.7±4.1 exploits;
  * over 72 runs, 19 end with an unsound rule after coherence;
  * `prop_learning.md` §3 reports 15 of 36 error runs with N≥20.

  Reporting the smoke test overstates coherence's effect and is inconsistent with §§7 and 12.
* **Fix.**
  * Line 171: "…a bold learner over classical natural deduction accepted all 59 valid and refuted all 118 invalid
    structural candidate schemas (of 177), each by an explicit derivation of ⊢⊥ (median 2.5 steps for
    generalizations of target rules, 6 for random schemas), while the non-structural ⊢p survived all eight
    designated contexts (computed)."
  * Line 421: "Experiment B shows the negative-data role end to end (computed; `tab:experiments:prop`). With
    systematic fallacies (AC, DA and an illegitimate discharge, all cited as →E) and 5% corrupted steps, at
    N ∈ {50,100,200}, imitation ends with 45.6±19.3 unsound active rules, and the adversary derives ⊢⊥ in 9 of 9
    runs. Coherence pruning on five designated contexts, with blame by a minimum-weight hitting set, leaves
    1.2±0.9 unsound rules, closes every route to ⊢⊥ and keeps all 13 target rules. Over all 72 runs (N from 5 to
    200), 19 still end with an unsound rule after coherence. Most survivors are non-structural (38 of the 45
    mention specific atoms). At N≤10, AC itself can survive, because a small learned calculus cannot derive the
    contradiction."
  * Lines 191 and 367: drop "quick run". The same facts are in the full report.
  * Header comment: cite `prop_learning.md`.

### M11. A "testable prediction" that the theorem does not imply

* **File and location:** `coherence.tex` line 312.
* **Problem.** The text says: "A testable prediction for language-model training: imitation plus a contradiction
  penalty yields consistent but noncommittal reasoners." The theorems show only that such data do not *exclude*
  gappy valuations, which is a non-identifiability result. They say nothing about which valuation a trained model
  will settle on.
* **Fix.** "A conjecture for language-model training, not implied by the theorem (which concerns identifiability,
  not training dynamics): imitation plus a contradiction penalty does not by itself push a learner toward committal
  (Boolean) valuations, so it may leave consistent but noncommittal reasoners."

### M12. "Proofs that it relies on nothing else" and "dropping each assumption breaks the guarantee"

* **File and location:** `philosophy.tex` line 32.
* **Problem.** The paragraph lists three assumptions: realizability, truthful designation and a world channel. It
  claims "for each assumption there is a matching impossibility result showing that dropping it breaks the
  guarantee" and "proofs that it relies on nothing else". Neither claim holds:
  * Realizability has no impossibility theorem. It is shown load-bearing only by example.
  * Dropping the world channel does not break soundness, since TTL with coherence alone is sound
    (`prop:twotier:coherenceonly`(a)). The world is needed only for completeness under ambiguous blame.
  * The guarantees also rely on (Floor), distinct fallacy tags and an exact refutation oracle.
* **Fix.** "For several of these assumptions there is a matching impossibility result (`tab:twotier:necessary`).
  Realizability is shown to be load-bearing by example rather than by a theorem, and the world channel is needed
  for completeness under ambiguous blame, not for soundness (`thm:twotier:blame`, `prop:twotier:coherenceonly`).
  … What they provide is an explicit list of what the stated guarantees rely on (the three items above, together
  with the technical hypotheses of `thm:twotier:main`: a known frequency floor, fallacies used under their own
  latent tags, and an exact depth-d refutation oracle), with proofs that the guarantees hold under them."

### M13. "This undercuts … Dummett's acquisition argument" is philosophical overreach

* **File and location:** `philosophy.tex` line 91.
* **Problem.** The identifiable rules (`thm:coherence:telltale`) are for the *propositional* connectives. The
  undecidable truths are arithmetic Σ2 sentences, which involve different vocabulary (quantifiers over ℕ). The
  manifestation and acquisition argument targets *truth-conditional* (bivalent) meaning. Dummett grants that rules
  of use are manifestable, and the paper's own Carnap results show that single-conclusion rules do not fix
  classical truth conditions.
* **Fix.** "This bears on, but does not refute, Dummett's acquisition argument. The argument targets
  truth-conditional meaning. What the learner acquires is the rules (for the propositional connectives,
  `thm:coherence:telltale`), which Dummett agrees are manifestable. The theorems show only that acquiring rules
  exactly is compatible with truth values, here of arithmetic Σ2 sentences, staying beyond computable reach."

### M14. Novelty claim for "tightness of the Ville constant"

* **File and locations:** `caution.tex` lines 33 and 257.
* **Problem.** Ville's inequality is known to be essentially tight: equality holds for continuous-path test
  martingales, and near-equality holds for small increments. `prop:caution:tight` is a worked instance in this
  protocol (0.989δ′). Calling it one of four new results, and "New here is only the tightness of the constant",
  claims novelty for a known phenomenon.
* **Fix.**
  * Line 33: "As far as we know, three are new: the exact single-schema budget, the tagged/untagged separation and
    the Bell-number bound…. `prop:caution:tight` checks that Ville's constant cannot be improved in this protocol,
    as expected since Ville's inequality is essentially tight for test martingales with small increments
    (`ramdas2023game`)."
  * Line 257: "New here is only the check that the constant is tight in this protocol (`prop:caution:tight`), an
    instance of the known near-tightness of Ville's inequality."

### M15. Existence section novelty claims omit known results, including one the source file credits

* **File and location:** `existence.tex` line 42.
* **Problem.** Two claims need qualification.
  * (a) The "strictness results for CCS-style constraints" are listed as new. The arity part, that locally
    consistent marginals need not have a joint distribution, is the classical marginal problem (Vorob'ev 1962;
    Boole's "conditions of possible experience" and Pitowsky's correlation polytopes). The paper already
    connects it to Specker and contextuality. NP-hardness of probabilistic coherence (probabilistic
    satisfiability) is Georgakopoulos, Kavvadias and Papadimitriou (1988). Only the threshold hierarchy
    (`thm:existence:threshold`) looks new.
  * (b) "The multi-context completeness theorem in exactly this form" is listed as new. T6 (line 785) itself says
    "LMS completeness results exist (Ghidini & Giunchiglia 2001; Serafini & Bouquet 2004); mine is the simplest
    monotone case". The paper omits this.
* **Fix.** Replace the two clauses with: "…the threshold hierarchy for counting-sequent constraints
  (`thm:existence:threshold`; the arity result `thm:existence:arity` is an instance of the classical fact that
  locally consistent marginals need not admit a joint distribution, cf. the marginal problem of Vorob'ev 1962 and
  Pitowsky's correlation polytopes, and NP-hardness of probabilistic satisfiability is due to Georgakopoulos,
  Kavvadias and Papadimitriou 1988), and the simplest monotone case of multi-context completeness, fitted to L7's
  calculus (`thm:existence:mcs`; completeness results for local-models semantics already exist, `ghidini2001local`;
  Serafini and Bouquet 2004)". Add the bibliography entries and mark the details as to be checked.

### M16. The intro's "answers in brief" present classical results without attribution

* **File and locations:** `intro.tex` items (2), (4), (6), (7) and the credit list at line 135.
* **Problem.** Several bullets state classical results as findings, with credit given only deep in the body:
  * "Every structural extension of classical consequence is classical or trivial" is Post 1921, and in
    consequence form Pogorzelski 1971 and Wójcicki.
  * "Coherence is blind among intermediate logics" is Glivenko.
  * "At most log2(1/w\*) detections" and "objects need at most log2|H| corrections" are Barzdin–Freivalds and
    Littlestone halving and mistake bounds.
  * "Time-uniformly sound via Ville's inequality" is the prior–posterior-ratio martingale of Waudby-Smith and
    Ramdas.
  * "No free export" is the adversary argument of information-based complexity.

  The credit list at line 135 also omits Littlestone, Reiter, Shapiro, Wright–Motoki, Lange–Zeugmann, Scott,
  Putnam/Gold/Kelly and Helmbold–Sloan–Warmuth, and it does not name Waudby-Smith–Ramdas, Brown–Priest or
  Traub–Wasilkowski–Woźniakowski.
* **Fix.**
  * Add short parenthetical credits in the bullets: "(Post 1921; Pogorzelski 1971)", "(Glivenko)", "(halving:
    Barzdin–Freivalds, Littlestone)", "(the prior–posterior-ratio martingale of Waudby-Smith and Ramdas)", "(the
    adversary argument of information-based complexity, Traub–Wasilkowski–Woźniakowski)".
  * Extend line 135 to: "Gold, Angluin, Plotkin and Reynolds, Natarajan and Helmbold–Sloan–Warmuth, Wright and
    Motoki–Shinohara, Lange–Zeugmann, Rivest–Sloan, El-Yaniv–Wiener, KWIK, Ville and Waudby-Smith–Ramdas,
    Barzdin–Freivalds and Littlestone, Post and Pogorzelski, Glivenko, Carnap, Shoesmith–Smiley, Rumfitt, Restall
    and Scott, Reiter and Shapiro, Putnam, Gold and Kelly, chunk-and-permeate (Brown–Priest), information-based
    complexity (Traub–Wasilkowski–Woźniakowski), de Finetti and Gaifman."

### M17. The kink is claimed in general but proved only for parity teachers

* **Files and locations:** `intro.tex` line 83; `simplicity.tex` §8.7 ("so the product frontier kinks").
* **Problem.** `thm:simplicity:kink` is proved for a parity teacher with a random error set. §8.1 says "(proved for
  parity models)", and open problem 6 asks about "kinks beyond parities". The intro says the penalty "does produce
  the hoped-for kink at the simple model" with no qualifier.
* **Fix.**
  * Intro: "…does produce the hoped-for kink at the simple model, proved for parity teachers
    (`thm:simplicity:kink`); kinks beyond parities are open."
  * Verdict paragraph: "…so the product frontier kinks for parity teachers (`thm:simplicity:kink`)".

### M18. An external empirical claim is cited only to an internal memo

* **File and location:** `physics.tex` line 48.
* **Problem.** "Gold-level solving of IPhO-style problems under rubric grading has been reported for current AI
  systems (L9 §5.2)" has no published citation. L9 gives HiPhO (arXiv 2509.07894) and Physics Supernova (arXiv
  2509.01659). It also records that the best model scored *below* gold on EuPhO 2025, the problem set the paper
  uses.
* **Fix.** "Gold-level scores on IPhO 2025 theory under rubric grading have been reported for current AI systems
  (the HiPhO benchmark, Yu et al. 2025, arXiv:2509.07894; Physics Supernova, Qiu et al. 2025, arXiv:2509.01659),
  but not on the modelling-heavy EuPhO 2025, where the best model scored below the gold threshold." Add the two
  entries to `bib/physics.bib`.

---

## Minor

1. **`intro.tex` line 38** says "For rule schemas learned by anti-unification this cost is linear in step size".
   This holds only for rules cited by name. Fix: "For rules cited by name this cost is linear in step size. Without
   citations it is at least ⌊(N−1)/k⌋^k even for one rule. Unstructured classes cost exponentially."
2. **`abstract.tex` line 7** says "Positive examples identify a schematic calculus exactly, at coupon-collector
   rates". Fix: "For rules cited by name, positive examples identify…".
3. **`abstract.tex` line 8 and `intro.tex` line 47** use the slogan "Its power is exactly Post-completeness".
   Coherence also works on non-Post-complete targets: it refutes incoherent errors and is Popperian for
   arithmetic. Fix: "It pins the target down exactly when the target has no coherent proper extension, as
   classical logic has none by Post-completeness".
4. **`intro.tex` line 32** says "Accuracy on human steps … is therefore the wrong target". Fix: "…is therefore not
   a soundness certificate. In a small closed algebra domain, a boosted-tree step classifier with in-distribution
   AUC 0.995 is exploited by search to prove most of a set of false equations."
5. **`intro.tex` line 130** says "school algebra with real systematic errors". Readers may take this to mean real
   student data. Fix: "school algebra with simulated derivations containing well-known systematic student
   errors".
6. **`search.tex` line 85** says "This is the mechanism behind reward-model overoptimization". Fix: "This is one
   mechanism that can produce reward-model overoptimization".
7. **`search.tex` line 86** uses `rivest1988reliable`, `elyaniv2010selective` and `li2008kwik`, which duplicate
   `rivest1988learning`, `elyaniv2010foundations` and `li2008knows`. Each paper appears twice in the PDF
   bibliography (`main.txt` lines 8238/8241, 8448/8452, 8611/8615). Fix: use the latter keys, and delete the
   duplicates from `bib/search.bib`.
8. **`coherence.tex` line 204** says "Whether a fixed finite family of contexts suffices for RCF is open". A
   round-2 referee (`reverification-round2.md`, T2) reports that a short argument settles it negatively. Fix:
   "(A second-round referee sketched a negative answer, that no fixed finite family suffices without ∃-closure; we
   have not checked it.)" Alternatively, verify the argument and state it.
9. **`coherence.tex` line 321(d)** says BV "is not identifiable in the limit at all, even with the coherence datum".
   A round-2 referee notes the argument covers text plus the single datum only, and that with the full stream of
   certified positions one has an informant. Fix: "…not identifiable in the limit from text plus the single
   coherence datum…".
10. **`experiments.tex` line 17** says "no stored result changed". README review item 1 changed the fallacy-fate
    counts in B's report. Fix: "…the fallacy-fate counts in B's report changed (e.g. AC at N=10); no other number
    changed".
11. **`experiments.tex` line 55 and `philosophy.tex` line 87** say "the convention of Lean's Mathlib". Mathlib
    shares only x/0 = 0. Real.sqrt of a negative number is 0 there, not a complex root. Fix: "its x/0 := 0 is the
    convention of Lean's Mathlib". Also qualify "converged" as "up to 11 of 315 surviving schemas, 10 of them
    non-structural".
12. **`philosophy.tex` lines 24 and 138.**
    * Line 24 says "Daniels' independence constraint is, formally, the conditional-independence assumption…".
      Fix: "can be read as".
    * Line 138 calls the anchor result "a precise … answer to the rule-following question". Add "relative to the
      hypothesis class and its vocabulary, which the data do not fix (Goodman's point; `sec:imitation`
      qualification (i))".
13. **Simplicity, and three smaller items.**
    * **`simplicity.tex` line 249** says "every near-optimal hypothesis … correlates strongly with f_a" for c well
      inside the window. The bound of `cor:simplicity:example`(i) is vacuous unless 2^{1−H(p)} − 1 > 2p, which
      fails from about p ≈ 0.15. Add "and p small".
    * **`simplicity.tex` line 296** says fallacies "common in student algebra and in Euler-style manipulation"
      without a citation. Cite or hedge.
    * **`abstract.tex` line 13** says "We also settle two questions…". Fix: "We also answer, in part, two
      questions…".
    * **`intro.tex` line 120** describes the Lean coverage. Add "(about a third of the 49 mapped results in a
      special-case, weaker or variant form)".

---

## Checked and found honest (no action)

* The checking-first framing: physics §11 ("We build a checker, not a solver"), the intro table, and open problem 8
  ("deliberately not built a strong prover").
* The experiments section's limits paragraph ("not evidence that the methods scale").
* "Trivial once set up" labels in §§3, 4, 5, 6, 7, 10 and 11.
* Credits to Plotkin–Reynolds, Natarajan, Helmbold–Sloan–Warmuth, Rivest–Sloan, KWIK, El-Yaniv–Wiener,
  Waudby-Smith–Ramdas, Post/Pogorzelski, Glivenko, Kornhauser–Sager/List–Pettit, Littlestone, Reiter, Shapiro,
  Brown–Priest, Traub–Wasilkowski–Woźniakowski, Scott, Shoesmith–Smiley, de Finetti, Gaifman and Specker *where the
  results are proved*.
* Status tags (computed, proof sketch, conjecture).
* Lean claims, and every quoted number of experiments A, C, D, E and F.
