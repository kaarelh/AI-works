# L11 — Justification, reflective equilibrium and coherence: what a learned-inference setup can justify

*Literature memo for the inferential-learning project, strand L11. Covers:*
- *Goodman's mutual-adjustment account of the justification of rules; Rawls's narrow and wide reflective equilibrium; Daniels; recent formal models of reflective equilibrium (RE).*
- *Stich & Nisbett and Stich on RE endorsing fallacies; L. J. Cohen on competence and performance.*
- *Coherentism (BonJour, Thagard, Haack's foundherentism) and the probabilistic impossibility results (Klein–Warfield, Bovens–Hartmann, Olsson), with what escapes them.*
- *Lewis Carroll's regress, Quine's "Truth by convention", Boghossian on blind reasoning; rule-circularity (Dummett, Haack).*
- *Peirce, Reichenbach, Dummett, Carnap and Quine on truth, vindication and tolerance.*

*Overlap policy.* L4 already covers inferentialism, harmony, tonk, categoricity and Kripkenstein. T2 already proves the formal coherence results: coherence as negative data, the residue Alt of coherent alternatives, survival criteria for fallacies, and Post-completeness. L10 digests the user's notes. This memo cites those results by number and does not re-derive them. Its job is the *epistemology*: what kind of justification the setup instantiates, and what a theorem about it would be evidence for.

**Verification legend.**
- **[v]**: bibliographic data and gist confirmed this session by web search. Search snippets only; every full-text fetch was blocked by the egress proxy.
- **[mem]**: standard reference recalled from memory; confident, but not re-checked.
- **[unverified]**: details (pages, exact formulation) uncertain.
- **(ours)**: arguments or lemmas made for this memo.
- **[script k]**: checked by item *k* of `research/lit/L11-scripts/coherence_checks.py`. All checks are exact or brute force, and all pass.

---

## 0. Bottom line

1. **The user's setup is Goodman's account of justification, almost verbatim.** "Rules and particular inferences alike are justified by being brought into agreement with each other. A rule is amended if it yields an inference we are unwilling to accept; an inference is rejected if it violates a rule we are unwilling to amend" [v].
   * Imitation plus coherence is **narrow** reflective equilibrium (RE).
   * Adding world feedback from a channel whose errors are independent of human errors makes it **wide** RE. Daniels' "independence constraint" [v] is, formally, the conditional-independence assumption that the coherence impossibility theorems show to be necessary.
2. **Stich & Nisbett's objection becomes a theorem** (Lemma 2.1, ours). Take a fallacy that humans use systematically, that is coherent with the target on all designated contexts, and that world feedback does not expose. Every δ-sound learner must abstain on its instances, *including in worlds where they are valid*. Moreover, imitation-MDL with any fixed simplicity weight eventually absorbs every systematic error of positive frequency [script 12]. Imitation converges to Cohen's "competence", not to validity. This corrects the asymptotic reading of L10's T5.
3. **The coherence impossibility theorems (Bovens–Hartmann 2003; Olsson 2005) do not bite against *eliminative* coherence**, i.e. "⊥ from a context certified consistent, so some rule is invalid". They **do** bite against coherence used as *confirmation*: human consensus, annotator agreement, self-consistency of samples. Agreement amplifies only for individually credible **and** conditionally independent sources [script 3, 4]. Even then, the posterior ranking of information sets depends on reliability, not on content alone [script 2].
4. **What escapes those theorems:**
   * eliminative use;
   * channels independent of human error (computation, measurement);
   * known reliabilities;
   * structural uniqueness of the coherent extension (Post-completeness; T2 Thm 3.1).
   
   Haack's **foundherentism** (crossword: clues plus crossings) [v] fits the combined setup better than coherentism or narrow RE.
5. **Carroll's regress, formalized (§4).**
   * Without a built-in rule, conditional premises are inert.
   * One built-in rule simulates single-instance rules, but the premise versions are strictly stronger.
   * Schematic generality always needs a rule (Quine 1936).
   * Rules *of proof* differ from their internalized conditionals: necessitation versus p→□p [script 10]; the reflection rule versus the Löb-explosive reflection axiom.
   
   A learned rule is a projectible schema whose validity is a Π-claim: refutable by feedback, never verified by it. Its justification cannot come from more premises. It must come from a guarantee about the learning process, plus a small trusted kernel.
6. **What a theorem about the setup is evidence for.**
   * It is *not* a non-circular foundation for logic; Dummett's point that such a justification is explanatory, not suasive, applies [v].
   * It *is* a **conditional reliabilist meta-justification of wide RE** under explicit channel assumptions. This is what BonJour's metajustification attempted and could not deliver in general.
   * Limit theorems are merely Reichenbachian vindications and fall to Salmon's objection. Anytime bounds discriminate between methods.
7. **Peirce, Dummett, Carnap and Quine disagree only about T2's residue Alt.**
   * Outside Alt, all of them count the learner as correct.
   * Inside Alt, the realist sees undetectable error, the Peircean or Dummettian sees no fact, Carnap sees tolerance, and Quine sees pragmatic choice.
   
   Payoff: **rules can be identifiable when truths are not** (T2 Thm 4.4 versus Thm 3.10). This undercuts the simple form of Dummett's acquisition argument (§6.3).

---

## 1. Goodman's circle, Rawls's equilibrium, and the user's setup

### 1.1 Goodman (1954/55), *Fact, Fiction, and Forecast*, ch. III

Ch. III ("The New Riddle of Induction"), §2 ("The Dissolution of the Old Problem"), around pp. 63–66 of the 4th edition [mem for pages]. The lectures date from 1953 [v]. The first edition is Athlone 1954 / Harvard 1955 [mem].

The argument, reconstructed:
1. **Deduction is the model.** "Principles of deductive inference are justified by their conformity with accepted deductive practice. Their validity depends upon accordance with the particular deductive inferences we actually make and sanction. If a rule yields inacceptable inferences, we drop it as invalid" [mem; the next sentence is v].
2. **The circle is virtuous.** Rules and particular inferences "alike are justified by being brought into agreement with each other … The process of justification is the delicate one of making mutual adjustments between rules and accepted inferences; and in the agreement achieved lies the only justification needed for either" [v].
3. **The same goes for induction.** So the "problem of induction is not a problem of demonstration but a problem of defining the difference between valid and invalid predictions" [mem].
   * This is the *constructive* task of codifying practice. The new riddle (grue) then shows that codification needs more than syntactic form: it needs *projectibility*, which Goodman grounds in *entrenchment* (L4 §7).

**Mapping onto the setup (ours).**

| Goodman | Our setup |
|---|---|
| particular inferences "we actually make and sanction" | human proof steps (positive data) |
| rules | learned schemas (anti-unification / MDL over a schema language) |
| "a rule is amended if it yields an inference we are unwilling to accept" | a rule is deleted or guarded when it participates in a negative bag (⊥ from a designated context), or yields a conclusion the world oracle rejects |
| "an inference is rejected if it violates a rule we are unwilling to amend" | a human step is treated as noise when it falls outside a highly-entrenched rule set (MDL noise term; Lakatosian monster-barring) |
| "the agreement achieved" | a fixed point: rules cover the retained steps, and no retained step or rule participates in a detected contradiction |
| entrenchment / projectibility | the prior over schemas (vocabulary-relative simplicity), i.e. *which* generalizations of the instances count as the rule |

Two consequences follow directly.
- **Goodman's reframing is the user's reframing.** "Defining the difference between valid and invalid" inferences is the user's goal, "learn which inferences are valid". On Goodman's view nothing further, such as a demonstration, is needed for justification.
- **Grue shows that the circle underdetermines the rules.** Mutual adjustment works on *instances*. Which schema an instance set "agrees with" depends on the generalization operator 𝒢. In T2's terms, uniformity is what converts instance-level errors into schemas that coherence can refute (T2 Cor 6.2, Prop 6.3). Goodman's entrenchment is one answer to "which 𝒢"; MDL with a fixed reference language is another. Both are vocabulary-relative, which is Goodman's point.

### 1.2 Rawls; narrow versus wide; Daniels' independence constraint

- **Origin of the term.** Rawls coined "reflective equilibrium" in *A Theory of Justice* (1971), §4 and §9, crediting Goodman [mem]. The idea goes back to "Outline of a decision procedure for ethics", *Phil. Rev.* 60 (1951) 177–197 [mem].
- **Narrow versus wide.** Rawls draws the distinction explicitly in "The independence of moral theory", *Proc. APA* 48 (1974) 5–22 [v]. Narrow RE adjusts principles to judgments with only minor changes.
- **Daniels' development.** Daniels, "Wide reflective equilibrium and theory acceptance in ethics", *J. Phil.* 76 (1979) 256–282 [v]. Wide RE brings three things into coherence: considered judgments, principles, and *background theories*.
- **The independence constraint** [v]. Daniels requires that "some nontrivial interesting portions of the set of considered moral judgments that constrains the background theories and of the set that constrains the moral principles should be disjoint". Background theories must not be mere reformulations of the same judgments.

**Mapping (ours).**
- *Narrow RE* = human steps plus learned rules plus coherence among them. Every input to the equilibrium comes from one channel: human inferential practice.
- *Wide RE* adds "background theories" with *independent* support: computation (exact evaluation; Schwartz–Zippel identity testing, orchestrator idea 3), measurement (world truth values), and accepted background mathematics whose acceptance does not rest on the same step-judgments.
- *The independence constraint is a conditional-independence assumption.* The errors of the background channel must not be driven by the same causes as the human step-judgments. §3.3 shows this is exactly the hypothesis without which probabilistic coherence cannot be truth-conducive. So Daniels' constraint is not decoration: it is what makes wide RE do more than narrow RE (§2.3).

### 1.3 Formal models of RE

* **Beisbart, Betz & Brun**, "Making reflective equilibrium precise: a formal model", *Ergo* 8 (2021) 441–472 [v]. Commitments and a systematizing theory are adjusted alternately, and states are scored by an achievement function Z. Its components include *account*, *faithfulness* to the initial commitments, and *systematicity* [v; mem for the exact linear form].
* **Freivogel**, "Does reflective equilibrium help us converge?", *Synthese* 202 (2023) art. 171 [v]. Simulations of this model: outputs are *not unique*, but RE "boosts agreement", and "anything goes" is blocked at the level of positions.

**Correspondence (ours).** Our MDL-plus-coherence objective is a special case of the BBB achievement function:
* account ↔ coverage of human steps by the rules;
* faithfulness ↔ the cost of declaring human steps to be noise;
* systematicity ↔ description length of the rule set;
* BBB's consistency requirement ↔ the coherence loss.

Freivogel's non-uniqueness is the simulation-level shadow of T2's residue Alt. This literature gives philosophers a vocabulary for the learner, but it contains no truth-conduciveness theorem. The missing piece is exactly Stich's gap (§2).

### 1.4 Two refinements worth adopting

**Elgin's "true enough".** Elgin, *Considered Judgment* (Princeton 1996) [mem]; *True Enough* (MIT 2017) [v].
- Epistemic acceptability is RE-based: "An account is tenable just in case it is, or is rationally reconstructible as, a result of a process of adjudication that brings a collection of initially tenable commitments into reflective equilibrium" [v].
- Science ineliminably uses "felicitous falsehoods" such as idealizations, models and ceteris paribus claims [v].

This is the user's "true enough in the context at hand" (L10 §2.1, J4). It is the natural philosophical home for idealized contexts plus export rules (H6, L7). An idealization is accepted as *true enough* relative to a purpose and a precision, which is exactly an export certificate.

**Haack's foundherentism.** *Evidence and Inquiry* (Blackwell 1993) [v].
- In a crossword, each entry is supported by its *clue* (experiential evidence) and by its *intersections* with other entries (coherence) [v].
- Haack's dimensions of evidential quality are supportiveness, independent security of the supporting reasons, and comprehensiveness [mem].
- Read formally, a crossword is a constraint-satisfaction problem with *unary* anchoring constraints (clues) and *binary* consistency constraints (crossings). Clues and crossings are distinct channels.

This is a better description of positive data plus world feedback plus a coherence loss than either pure coherentism (no unary constraints; §3.2) or narrow RE (only one channel).

---

## 2. Stich versus Cohen, mapped onto learning from human inferences

### 2.1 The positions

**Stich & Nisbett.** "Justification and the psychology of human reasoning", *Phil. Sci.* 47 (1980) 188–202 [v].
- Target: Goodman's account.
- Claim: being in RE with inductive practice is "neither necessary nor sufficient" for a rule's justification [v].
- Lead example: the gambler's fallacy. Subjects hold the rule, and on reflection they keep it [v].
- Their proposed repair is to relativize RE to the *experts* of a society. Stich later rejects that too: experts "could end up endorsing a nutty set of rules" [v].
- Later work:
  - Stich, "Could man be an irrational animal?", *Synthese* 64 (1985) 115–135 [mem];
  - Stich, "Reflective equilibrium, analytic epistemology and the problem of cognitive diversity", *Synthese* 74 (1988) 391–413 [v];
  - Stich, *The Fragmentation of Reason* (MIT 1990) [v]. Here he rejects truth-based, RE-based and conceptual-analysis accounts of good reasoning in favour of a pragmatic, relativist account on which reasoning is a tool [v].

**Cohen.** "Can human irrationality be experimentally demonstrated?", *BBS* 4 (1981) 317–370, with commentaries [v].
- Normative criteria for reasoning "ultimately derive their own credentials from a systematisation of the intuitions that agree with them" [v]. That systematization is narrow RE.
- A competence theory must predict those same intuitions. So it "must ascribe rationality to ordinary people" [v].
- Apparent fallacies fall into four categories [v]:
  - genuine *cognitive illusions* (performance);
  - mathematical or scientific *ignorance* (education, not competence);
  - experimenters applying normative criteria *inappropriately*;
  - experimenters applying *inappropriate* criteria.

**A modern twist relevant to Cohen's third and fourth categories.** Miller & Sanjurjo, "Surprised by the hot hand fallacy? A truth in the law of small numbers", *Econometrica* 86 (2018) 2019–2047 [v].
- They prove that in finite sequences the proportion of successes following a success is biased downward.
- For n = 4 fair flips the expected proportion of H after H is 17/42 < 1/2 [script 9].
- Correcting for the bias reverses the canonical hot-hand study's conclusion [v]. That study is Gilovich, Vallone & Tversky, *Cogn. Psych.* 17 (1985) 295–314 [mem].

So for the finite-sample *statistic*, the "gambler's" direction is right, and the experts' benchmark of 1/2 was the error. The lesson for us: whether a human inference is fallacious depends on the *reading map* ρ, i.e. which proposition the step is taken to be about (H5). Error attribution is itself fallible.

### 2.2 Formalization (ours)

Setting:
* There are steps s and a target validity relation v*.
* Human steps are generated by a process whose law depends on situations and on a human *competence* c (a rule set), and **not otherwise on v***. That is what "systematic error" means: humans use F whether or not F is valid.
* The learner also sees a coherence oracle on designated contexts 𝒜, and a world oracle W on a fragment D.

**Lemma 2.1 (Stich indistinguishability) (ours; essentially orchestrator idea 4(d)).** Let v₁ and v₂ be validity relations such that:
* (i) both are coherent on every A ∈ 𝒜;
* (ii) W's answers on D are the same under both;
* (iii) the human process law is the same under both.

Then every learner's input stream has the same law under v₁ and under v₂. So for every step s with v₁(s) = 1 and v₂(s) = 0, the learner accepts s with the same probability p_s in both worlds. If the learner is sound with probability ≥ 1−δ under v₂, then p_s ≤ δ. It therefore abstains on, or rejects, s with probability ≥ 1−δ under v₁ as well.

*Proof.* The inputs are measurable functions of (human stream, coherence reports, W-answers), and all three have identical laws by (i)–(iii). Coherence reports are identical because a ⊥-derivation from A ∈ 𝒜 exists under neither. ∎

*Reading.* Stich & Nisbett's claim that narrow RE is not sufficient is the case W = ∅. Take v₁ = R* ∪ {F} and v₂ = R* (when R* ∪ {F} is coherent; when it is not, coherence separates them, by T2 Thm 6.1). Then:
* the disagreement region is the set of F-instances;
* a sound learner must abstain on all of them, *in the world where they are valid too*.

This is the soundness-for-completeness trade that KWIK and selective classification price (L2).

**Proposition 2.2 (imitation converges to competence; a heuristic MDL calculation) (ours).** Let a two-part-code learner choose between:
* H₀ = R* + noise;
* H₁ = R* ∪ {F}, where humans use F on a fraction φ of steps and each step has M alternatives.

H₀ must code the F-steps as noise. Its per-step excess is about H(φ) + φ·log₂M bits, where H is binary entropy. H₁ pays λ·K(F) once. So H₁ wins once

  n ≳ λ·K(F) / (H(φ) + φ log₂ M)   [script 12]. Example: λ = 10, K(F) = 200 bits, φ = 1%, M = 50 gives about 1.5·10⁴ steps.

*Assumption, to be made precise:* F fires deterministically in a situation type the hypothesis can name.

Consequences:
* For any *fixed* λ, every compressible systematic error of positive frequency is eventually learned.
* A λ that grows with n blocks *true* rules with the same (frequency, complexity) profile equally.

The human channel cannot tell a valid rule from a systematic error with the same profile (Lemma 2.1). This is the precise content of Cohen's thesis for a learner: **imitation identifies competence, not validity.**

*Correction to L10 T5.* The user's "steeper simplicity coefficient" can separate intended rules from systematic error only on a finite-sample window, n < n*. It cannot do so asymptotically. Asymptotic separation needs a validity-sensitive channel.

### 2.3 Who wins, for us

**Cohen's move, in our setting, is to define the target as competence** (v* := c). That makes the learner correct by fiat. The project cannot accept this.
- Soundness against search (H1) is about truth-preservation.
- A competence that includes a coherent fallacy F is exploitable by a prover who routes through F-instances outside the human distribution.

One part of Cohen's position survives: for informal mathematics *before* formalization there is no external standard. The norm itself is extracted from practice, which is Kreisel's informal rigour (L6). Then the only correctives available are (a) coherence and (b) independent channels such as computation and later formalization. That is wide RE, not narrow RE.

**Stich wins against narrow RE, exactly.** Lemma 2.1 plus Prop 2.2. Which fallacies survive is computed in T2 §6:
- Every structural propositional fallacy dies under coherence, quickly (T2 Cor 6.2).
- The gambler's fallacy, conditional perfection and the quantifier swap survive unless the designated contexts are *substantive*: independence accepted, two distinct objects, exclusive laws.

So the gambler's fallacy, Stich & Nisbett's own example, is a *coherent alternative meaning*: "the process is anti-persistent" [script 8; T2 §6]. Narrow RE cannot remove it. It dies only by:
- (i) entrenching an independence premise, i.e. a background theory in Daniels' sense; or
- (ii) frequency feedback from the world.

**Stich & Nisbett's expert repair** corresponds to reweighting annotators. In a latent-class model (Dawid & Skene, *Applied Statistics* 28 (1979) 20–28 [mem]), annotator reliabilities are identifiable when annotators err *conditionally independently* given the true label. Shared systematic errors are not identifiable from annotations alone. So expert weighting helps against idiosyncratic noise, and is useless against an error shared by all experts. This is Stich's "nutty rules" worry, made formal by Lemma 2.1 applied to the expert channel.

**Mathematical history gives both kinds of case** [mem; details in L6]:
* *Divergent-series manipulations* produced explicit contradictions. That is coherence feedback, and it led Abel and Cauchy to restrict the rules. Later summation theories restored coherent, regimented versions (Hardy, *Divergent Series*, 1949), which is tolerance at work.
* *Cauchy's 1821 sum theorem* was a systematic error that survived coherence. It was exposed by counterexamples, an independent channel, not by internal contradiction (Lakatos, *Proofs and Refutations*, 1976).

---

## 3. Coherentism and the impossibility results

### 3.1 BonJour's coherentism and its three objections, mapped

BonJour, *The Structure of Empirical Knowledge* (Harvard 1985) [v].
- Coherence is built from logical consistency, probabilistic consistency, inferential interconnection, and the absence of anomalies [mem].
- The **Observation Requirement**: the system must contain beliefs attributed to spontaneous, involuntary cognitive input [v].
- The **metajustification**: a system that "(a) remains coherent (and stable) over the long run and (b) continues to satisfy the Observation Requirement is likely, to a degree which is proportional to this degree of coherence (and stability) and the longness of the run, to correspond closely to independent reality" [v].
- Critics argued that the Observation Requirement either fails to guarantee input or abandons coherentism [v]. BonJour later moved to foundationalism [v].

The three classic objections map onto proved results:

| Objection | Formal counterpart for a rule learner |
|---|---|
| **Alternative coherent systems**: many incompatible systems are equally coherent | T2 Thm 6.4: the residue Alt(h*, 𝒜) of coherent uniform alternatives. It is empty of rivals for CPC, includes all intermediate logics for IPC, and includes all consistent extensions (e.g. PA + ¬Con(PA)) for arithmetic. |
| **Input / isolation**: coherence alone floats free of the world | Coherence alone is maximized by accepting *nothing*: the empty rule set satisfies every negative bag. A noncommittal position is coherent (T2 §4: gappy valuations; the CCS degenerate solution). The Observation Requirement is the positive-data term. |
| **Truth**: why should coherence indicate truth? | §3.3: in general it does not. It does under eliminative use, with independent credible channels, or with coherence-pinning structure. |

### 3.2 Thagard: coherence as constraint satisfaction

Thagard & Verbeurgt, "Coherence as constraint satisfaction", *Cognitive Science* 22 (1998) 1–24 [v].
- A set E of elements; weighted positive constraints C⁺ and negative constraints C⁻ (pairs).
- Partition E into accepted A and rejected R to maximize the total weight of satisfied constraints:
  - a positive constraint is satisfied iff both elements are on the same side;
  - a negative constraint is satisfied iff they are on opposite sides.
- Five algorithms are compared [v]. The problem is NP-hard by reduction from MAX-CUT [mem].
- Three variants [v]:
  - *pure* coherence favours no elements;
  - *foundational* coherence fixes some elements as accepted;
  - *discriminating* coherence favours some elements without guaranteeing them.
- Thagard's explanatory-coherence theory (*BBS* 12 (1989) 435–467 [mem]) adds a **data-priority** principle, which makes it a form of weak foundationalism [v].

**Observation (ours) [script 7].** The pure objective is invariant under swapping A and R. So pure coherence can never determine *which* side is accepted. This is the isolation objection as a symmetry fact.

Our coherence data have a different and *asymmetric* shape:
- A negative bag B says *not all of B is acceptable*: a hyperedge clause ⋁_{r∈B} ¬r.
- Positive data say *this step should be derivable*: a soft clause ⋁_{rules deriving s} r.
- The learner's problem is weighted MAX-SAT with MDL costs, i.e. a weighted hitting-set problem (NP-hard).

Since rejecting everything satisfies every negative clause, coherence alone pushes toward scepticism. The positive term (discriminating coherence, or data priority) is what makes the optimum informative. *Coherence alone is maximized by ignorance; data alone, by over-generalization (Gold).* The loss needs both.

### 3.3 The impossibility results, stated precisely

**The Lewis witness scenario** (C. I. Lewis, *An Analysis of Knowledge and Valuation*, 1946 [mem]).
- Propositions R₁,…,R_n; reports E₁,…,E_n.
- *Conditional independence*: each E_i depends only on R_i.
- *Individual credibility*: p = P(E_i | R_i) > q = P(E_i | ¬R_i).
- With equal p and q for all witnesses, x = q/p, and a_k = the prior probability that exactly k of the R_i are false:

  P(R₁∧…∧R_n | E₁∧…∧E_n) = a₀ / Σ_k a_k x^k   [script 1: brute force on 200 random cases].

Facts that follow:
- **No credibility, no boost.** If p = q (x = 1), the posterior equals the prior a₀, however coherent the set [script 3]. Olsson [v]: "coherence cannot generate credibility from scratch".
- **No independence, no amplification.** m witnesses who copy one source give the one-witness posterior for every m. Independent witnesses drive the posterior to 1 [script 4: with prior 0.3, p = 0.8, q = 0.4, the values at m = 20 are 1.000 and 0.4615].
- **Klein & Warfield**, "What price coherence?", *Analysis* 54 (1994) 129–132 [v]. Adding a proposition can raise coherence but never raises the probability of the conjunction [script 6].

**Bovens & Hartmann.** "Solving the riddle of coherence", *Mind* 112 (2003) 601–633 [v]; *Bayesian Epistemology* (OUP 2003) [mem]. In the model above, hold fixed the prior probability a₀ of the conjunction and the witnesses' reliability. Then the posterior ranking of two information sets still depends on the reliability parameter.
- Concrete instance [script 2]. Exchangeable weight vectors A = (.1, .3, .3, .3) and B = (.1, .2, .6, .1), both with a₀ = 0.1.
  - B has the higher posterior for x < ½; A has it for x > ½.
  - The difference of denominators is −0.1·x(2x−1)(x−1).
  - The Shogenji and Olsson–Glass measures do not depend on reliability, and both rank A above B. Yet B has the higher posterior whenever x < ½.
- So *no* ordering of information sets by their prior distribution alone can track posterior probability across reliabilities.
- Their remedy is a reliability-indexed measure and a **quasi-ordering**: S is at least as coherent as S′ iff this holds for *every* reliability value [v].
- Their 2006 paper ("An impossibility result for coherence rankings", *Phil. Studies* 128, 77–91 [v]) shows that Holism, Probabilism and Separability cannot all hold for a coherence ordering [v].

**Olsson.** *Against Coherence* (OUP 2005) [v]; "The impossibility of coherence", *Erkenntnis* 63 (2005) 387–412 [v].
- Theorem: there is no *informative* coherence measure that is truth-conducive ceteris paribus in a basic Lewis scenario, *given* independence and individual credibility [v].
  - "Informative" means the measure does not assign the same coherence to every probability assignment [v].
  - The counterexample is built by a strategic choice of the prior probability that the witnesses are reliable [v]. In Olsson's model, reliability is uncertain and witnesses are either reliable or randomizing [mem for the exact model].
- **Responses that delimit the result.**
  * Meijs & Douven, *Synthese* 157 (2007) 347–360 [v].
  * Schupbach, *Phil. Studies* (2008) [v].
  * Wheeler, *SJP* 50 (2012) 136–150 [v]. He questions the independence assumption and the "Content Determination Thesis", and proposes *reliability-conduciveness* as the target [v].
  * Wheeler & Scheines, *Mind* 122 (2013) 135–170 [v]. Causal structure decides whether coherence boosts, leaves unchanged, or lowers confirmation. Ceteris paribus, what matters is the coherence of the evidence relative to its coherence conditional on the hypothesis [v].

### 3.4 Do they bite against a coherence loss? Three uses of coherence (ours)

The brief's "coherence loss" covers three different things. They must be kept apart.

**(U1) Eliminative coherence.** "Hypothesis h derives ⊥ from a designated context A. A is certified consistent. So h contains an invalid rule."
- This is deductive refutation (modus tollens), not a coherence *measure*.
- In Bayesian terms, conditioning on "h is coherent on 𝒜" multiplies the posterior of every coherent hypothesis by the same factor 1/P(Coh). The truth never loses, and odds among coherent rivals are unchanged [script 5].
- **The impossibility theorems do not apply.** They concern degrees of coherence of *consistent* information sets.
- Two prices remain:
  - (a) U1 never discriminates among coherent rivals (Alt; T2 Thm 2.6);
  - (b) U1 is valid only if designation is truthful. Mis-designating an inconsistent idealized context forces global sub-classicality (T2 Prop 7.1).

**(U2) Probabilistic coherence of credences.** Examples: P(φ) + P(¬φ) = 1, and CCS-style constraints in the user's DLK work.
- These are de Finetti constraints, not BonJour coherence. They define the set of probability functions.
- The impossibility theorems do not apply. But the isolation objection does: the uniform or noncommittal assignment satisfies them. The user already knows this from CCS, which needs a confidence term.

**(U3) Coherence as positive evidence.** Examples:
- "many human proofs use this step";
- "annotators agree";
- "sampled derivations agree on the answer" (self-consistency decoding);
- "the rule set is highly interconnected, so it is probably right".

**This is the Lewis scenario, and the impossibility results bite in full.**
- Agreement among human steps is *not* conditionally independent given validity when errors are systematic: shared heuristics, shared textbooks, cultural transmission. So consensus does not amplify [script 4].
- Agreement among samples from one model shares the model's errors in the same way.
- Coverage-rewarding "explanatory coherence" of a rule set trades against the probability that *every* rule is valid (Klein–Warfield [script 6]). But soundness against search needs exactly that: a union bound Σ_r P(r invalid) ≤ δ over accepted rules (H1).

**What escapes, and what to use (ours).**
1. Use coherence *eliminatively* (U1), with truthful designation, for over-acceptance (L10 T2: coherence removes over-acceptance; positive data remove over-rejection).
2. Get positive corroboration only from channels whose errors are conditionally independent of the human-error process given the truth: computation, randomized evaluation, measurement. This is Daniels' independence constraint and Wheeler–Scheines' causal-structure condition, made operational.
3. Where reliabilities are estimable (Dawid–Skene with *independent* annotators, or calibration against the world oracle), coherence rankings become reliability-relative and therefore meaningful (Bovens–Hartmann).
4. Exploit structure. In coherence-pinned targets (CPC, RCF, Presburger arithmetic; T2 Thm 3.3, Prop 3.11), the uniqueness of the coherent extension, not truth-conduciveness of coherence, does the work.

---

## 4. Rules versus premises: Carroll's regress, for learners

### 4.1 The sources

**Carroll.** "What the Tortoise said to Achilles", *Mind* 4 (1895) 278–280 [mem].
- The Tortoise accepts A and B, and "if A and B then Z", but not Z. So Achilles adds C = "if A, B and C then Z" as a premise, and so on without end.
- The moral: a rule of inference cannot be replaced by a premise.

**Quine.** "Truth by convention" (1936), in O. H. Lee (ed.), *Philosophical Essays for A. N. Whitehead*, 90–124 [v].
- Each convention "is general, announcing the truth of every one of an infinity of statements … derivation of the truth of any specific statement from the general convention thus requires a logical inference, and this involves us in an infinite regress" [v].
- "If logic is to proceed mediately from conventions, logic is needed for inferring logic from the conventions" [v].
- Modern defence of conventionalism via implicit rules: Warren, *J. Phil. Logic* 46 (2017) [v]; *Shadows of Syntax* (OUP 2020) [mem].

**Boghossian.**
- "What is inference?", *Phil. Studies* 169 (2014) 1–18 [v]. The *Taking Condition* says inferring involves taking the premises to support the conclusion and concluding *because* of that. Construed doxastically, the taking regenerates Carroll's regress [v].
- "Blind reasoning", *Proc. Arist. Soc. Supp.* 77 (2003) 225–248 [v]. Basic deductive reasoning must justify as "blind but blameless" reasoning [v].
- Williamson's companion paper rejects inferentialist possession conditions, using pejoratives such as 'Boche' [v].

### 4.2 Formal statements (ours; elementary, but they are what the project needs)

**Definitions.**
- A *rule* r is a set of pairs (Γ, ψ).
- An *engine* E is a set of rules.
- A *store* S is a set of sentences.
- Cl_E(S) is the least superset of S closed under E.

**(C1) Regress.** Cl_∅(S ∪ C) = S ∪ C for every set C of conditionals. With no built-in rule, conditional premises are inert, however many are added [script 11].

**(C2) One rule suffices, but premises are stronger.** Let E ∋ MP. For a single-instance rule r = {({φ₁,…,φ_k}, ψ)}, let c_r = φ₁→(…→(φ_k→ψ)). Then Cl_{E∪{r}}(S) ⊆ Cl_E(S ∪ {c_r}): replace each r-application by k MP steps.
- The inclusion is strict in general. Example: if S contains (c_r → C), the premise version derives C and the rule version does not [script 11].
- A premise is an *object*. It can be embedded, contraposed, used under suppositions, and denied. A rule is only a closure condition.
- *Corollary:* rule-hood as such *reduces* exposure. The danger of a learned rule lies in its *schematic generality*, not in its being a rule.

**(C3) Generality cannot be moved into the store.** For a schematic rule (closed under substitution σ), internalization needs one of:
- infinitely many premises {c_{σr}};
- an axiom *schema*, which is a zero-premise schematic rule;
- a universally quantified premise plus a built-in instantiation rule.

In every case the projection from instances to new instances is carried by a rule. This is Quine's 1936 point. For a learner it means: **the inductive leap in rule learning (instances → schema) is always a change to the engine**, never just an addition to the store. That is why Goodman's projectibility problem attaches to rules.

**(C4) Rules of proof versus their conditionals** (Smiley, "Relative necessity", *JSL* 28 (1963) 113–134 [v]; Humberstone 2010, "Smiley's distinction between rules of inference and rules of proof" [v]).
- *Necessitation.* From ⊢φ infer ⊢□φ. This is sound on every Kripke frame. The schema p→□p is valid on a frame iff R ⊆ Id [script 10: all 530 frames with ≤ 3 worlds]. With T, it yields the collapse □φ↔φ.
- *Self-trust.* If T ⊇ PA is Σ₁-sound, T is closed under the rule "from ⊢_T Prov_T(⌜φ⌝) infer φ". A provable Σ₁ sentence is true, so T ⊢ φ. But no consistent T ⊇ PA proves Prov_T(⌜φ⌝) → φ for all φ: take φ = ⊥ and apply Löb's theorem (Löb, *JSL* 20 (1955) 115–118 [mem]).
- *Reading for the learner.* "Trust your own verifier" is harmless as a *rule* when the verifier is in fact sound. It is explosive as a *premise*. This sharpens L10 T10 and the user's Löb notes: reflection must be implemented as rules, or stratified, never as self-referential axioms.

**(C5) What differs, for a learner, between learning a rule and learning a conditional premise.**

| | conditional premise A→B (ground) | rule (schematic) |
|---|---|---|
| what is learned | one sentence in the store | a closure condition: a schema plus a commitment to instantiate it |
| verification by feedback | possible when A and B are decidable | impossible from finitely many instances (validity is Π over instances) |
| refutation | one observation (A, ¬B), or a derivation of ¬(A→B) | a counterexample instance, or a negative bag implicating its applications |
| use | embedded, contraposed, used under suppositions, denied | applies to accepted or derived sentences; inference/proof distinction matters |
| damage under adversarial search | bounded by Cl(S ∪ {A→B}) | iterated, schematic, can trivialize (tonk) |
| self-application | Löb-explosive as an axiom | admissible as a rule (for Σ₁-sound systems) |
| justification | can be another premise | cannot be another premise without regress; needs something external to the store |

*Consequence for the export rule (orchestrator idea 1).* The move from "inside [suppose Γ], Q = q" to the assertion "Q ≈ q ± ε" is a **rule**, not a premise. Its validity is a universal claim over situations, so world feedback can refute it but never verify it (Popperian asymmetry; T2 Thm 3.10(c)). Its justification has the same shape as any learned rule's.

### 4.3 Blind reasoning, meaning-constitution, and what a coherence check can catch

**Boghossian's two proposals.**
- "Knowledge of logic", in Boghossian & Peacocke (eds), *New Essays on the A Priori* (OUP 2000) [v]. *Rule-circular* justification of MP can be legitimate.
- *Meaning-constitution.* If a disposition to infer by MP partly constitutes possessing *if*, then the possessor is entitled to infer by MP blindly [v].

**The "bad company" problem.** Tonk shows that meaning-constitutive rules need not confer entitlement [v] (Prior, "The runabout inference-ticket", *Analysis* 21 (1960) 38–39 [mem]). Dummett's 'Boche' (*Frege: Philosophy of Language*, 1973, p. 454 [v]) has two rules:
- introduction: German ⟹ Boche;
- elimination: Boche ⟹ cruel.

Together they non-conservatively license German ⟹ cruel [v].

**Mapping (ours).** The two defective concepts separate the two corrective channels.
- **Tonk is caught by coherence.** It trivializes, so it derives ⊥ in any non-empty designated context (T2 Prop 5.1).
- **Boche is *coherent*.** It is consistent with any context not containing a kind German. It is caught only by *conservativity checks* or by *world feedback* (a kind German).

T2 Thm 5.3 shows conservativity is not even decidable in the limit, whereas coherence is. Hence: **for meaning-constitutive but materially false rules (Boche-type), world feedback is not optional.** "Learning meanings" (rules that constitute concepts) and "learning valid rules" come apart exactly here. L4 §6 discusses constitutive versus collateral rules; this adds the observation that the two defect types are caught by different channels.

---

## 5. The justification of deduction: rule-circularity and self-certifying verifiers

**Dummett**, "The justification of deduction", *Proc. British Academy* 59 (1973) [v].
- A *suasive* argument aims to persuade someone of its conclusion. An *explanatory* argument aims to explain why the conclusion holds.
- Circularity destroys suasive force but is compatible with explanatory value. Justifying deduction needs only explanation [v].

**Haack**, "The justification of deduction", *Mind* 85 (1976) 112–119 [v].
- Any justification of MP uses MP.
- A parallel rule-circular "justification" is available for *modus morons* (affirming the consequent) [v].
- So rule-circular arguments are *indiscriminating* [v], and deduction is in the same boat as induction.
- See also Haack, "Dummett's justification of deduction", *Mind* 91 (1982) 216–239 [mem].

**Consequences for a learned verifier V̂ (ours).**

1. **Self-certification is evidentially null.** Suppose V̂ "checks" a proof that V̂'s rules are sound, and the proof uses V̂'s rules. An unsound V̂′ that contains modus morons, or tonk, certifies itself just as easily. If P(self-certifies | sound) ≈ P(self-certifies | unsound), the likelihood ratio is ≈ 1, and nothing is learned. The trivial case is tonk: a trivial V̂ certifies every claim, its own soundness included.

2. **Self-certification of consistency is evidence of *inconsistency*.** If V̂'s accepted theory T ⊇ PA is r.e. and T ⊢ Con(T), then T is inconsistent (Gödel II). A strong learned calculus that "proves its own consistency" has revealed a negative bag.

3. **What a soundness theorem about V̂ supplies is Dummett's explanatory justification**, carried out in a stronger metatheory with independently accepted logic. It does not answer a Tortoise who doubts the metatheory's logic, and no theorem could. That is Carroll's regress again (§4).
   - It is also not a certificate V̂ can use internally (C4; Löb).
   - The irreducible residue is a **trusted kernel**: the engine that applies rules, as in the de Bruijn criterion for proof assistants. It must be small enough to be accepted on other grounds (inspection, multiple independent implementations, and "blind but blameless" use in Boghossian's sense).

---

## 6. Truth, convergence, vindication, tolerance

### 6.1 Peirce: truth as the limit of inquiry

Peirce, "How to make our ideas clear", *Popular Science Monthly* 12 (1878) 286–302 [mem]: "The opinion which is fated to be ultimately agreed to by all who investigate, is what we mean by the truth, and the object represented in this opinion is the real" [mem; standard quotation]. See also "The fixation of belief" (1877) [mem].

**Formal reading (ours, building on Kelly, *The Logic of Reliable Inquiry*, OUP 1996 [mem]; Gold 1965 and Putnam 1965 on limiting recursion, *JSL* 30 [mem]).**
- Peircean truth for a class of sentences, relative to an evidence channel, is "what reliable methods converge to".
- With computable evidence, the sentences decidable in the limit are exactly the Δ₂ ones.
- For the learner, the validity of a schematic rule whose instances are decidable is a Π₁ claim. It is refutable with certainty, and decidable in the limit with at most one mind change.
- So **rule validity in formal mathematics is Peirce-determinate**, while arithmetic truth beyond Δ₂ is not (T2 Thm 3.10: no learner decides Σ₂ truth in the limit).

**Quine's objection** (*Word and Object*, 1960, §6 [mem]) is that the "limit" of theories is a faulty numerical analogy, because the ideal limit need not be unique. This is precisely T2's residue: where Alt has several members, there is no *unique* end of inquiry. A Peircean must then say either that truth is indeterminate there, or that the community of inquiry includes more than the channels we gave the learner.

### 6.2 Reichenbach: pragmatic vindication, and why limit theorems are weak evidence

Reichenbach, *Experience and Prediction* (Chicago 1938), §§38–43 [mem]; *The Theory of Probability* (1949), §91 [mem]; Feigl's distinction between *validation* and *vindication* (1950) [mem].
- The *straight rule* posits that the limiting relative frequency equals the observed frequency so far.
- *Vindication:* if the limit exists, the straight rule converges to it. "If any method succeeds, induction does."
- *Salmon's objection* [mem]: every asymptotic rule (observed frequency + c_n, with c_n → 0) is equally vindicated, while disagreeing arbitrarily at every finite stage.

**Transposed (ours).** If learner L identifies the valid rules in the limit, then so does any L′ that agrees with L after a finite stage, even if L′ accepts arbitrary unsound steps before then. So **a limit theorem cannot certify the reasoner at any actual time**. The user's distrust of limit framings (L10 §2.4) is Salmon's objection.

What discriminates:
- anytime, uniform guarantees (Ville-type time-uniform soundness, KWIK, mistake bounds; L2);
- efficiency criteria: Kelly's retraction-efficiency justification of Ockham's razor (*TCS* 383 (2007) 270–289 [mem]); Schulte, "Means-ends epistemology" (*BJPS* 50 (1999) 1–31 [mem]).

Schurz, *Hume's Problem Solved: The Optimality of Meta-Induction* (MIT 2019) [v], is the modern Reichenbachian. Attractivity-weighted meta-induction has finite regret bounds relative to all *accessible* methods, proved a priori, using prediction-with-expert-advice results [v]. This is the template for a non-limit vindication of the learner's *aggregation* layer: an MDL/Bayes mixture over hypotheses has regret ≤ log(1/prior(h*)) against the best hypothesis.

### 6.3 Dummett's anti-realism, read as a learnability thesis

Sources: Dummett, "Truth" (*Proc. Arist. Soc.* 59, 1959) [mem]; "What is a theory of meaning? (II)" (1976) [mem]; *The Logical Basis of Metaphysics* (Harvard 1991) [mem].

The **acquisition argument**: meaning is learned from manifest use, and use manifests only recognizable conditions, so knowledge of verification-transcendent truth-conditions cannot be acquired. For a learner this is literally a learnability claim.

**Observation (ours).** Learnability of *rules* and learnability of *truths* come apart:
- Classical propositional rules are identifiable from a finite tell-tale of bilateral data plus one coherence datum (T2 Thm 4.4).
- Finitely axiomatized schema systems such as PA are identifiable in the limit from positive data under bounded-elasticity hypothesis classes (L1).
- But Σ₂ arithmetic truth is not decidable in the limit (T2 Thm 3.10).

So a learner can *acquire* classical meanings, as rules, that commit it to bivalence for sentences whose truth-values it can never acquire. That undercuts the simple form of the acquisition argument. Meaning-as-rules can be fully manifested while outrunning decidable truth.

Dummett's real fight is therefore over whether classical rules are *justified* (harmony and the fundamental assumption; L4 §4.2), not over whether they are *learnable*. The bilateral (Rumfitt, Restall) presentations in which classical rules are harmonious (L4 §2.5) are the natural reply. This is a modest but clean philosophical output the project can claim. *Caveat:* it presupposes the hypothesis-class restrictions under which identification holds.

### 6.4 Carnap's tolerance, and Gödel's objection

Carnap, *Logical Syntax of Language* (1934/1937), §17 [mem]: "In logic, there are no morals. Everyone is at liberty to build up his own logic, i.e. his own form of language, as he wishes. All that is required of him is that, if he wishes to discuss it, he must state his methods clearly, and give syntactical rules instead of philosophical arguments."

"Empiricism, semantics, and ontology" (1950) [mem] distinguishes *internal* questions, answered by a framework's rules, from *external* questions about which framework to adopt. External questions are practical: expedience, fruitfulness, simplicity.

**Mapping.**
- Contexts and calculi are frameworks.
- The learner's in-context rules settle internal questions.
- Choosing a calculus or idealization, and the export rule, are external questions, settled by practical success, i.e. world feedback.
- On Carnap's view, the residue Alt is not error but *tolerance*: there is nothing to get right among coherent alternatives, only better or worse tools.

This matches the user's phenomenology of accepting an axiom as "adopting a conception" (L10 §1.1).

**Gödel's objection** ("Is mathematics syntax of language?", drafts 1953–59, *Collected Works* III, OUP 1995 [v]).
- Syntactic rules count as admissible conventions only if they are *consistent*. Otherwise they imply every empirical statement.
- Consistency cannot be established on the syntactical interpretation without the mathematics it was meant to replace (Gödel II). Gödel: "there exists no rational justification of our precritical beliefs concerning the applicability and consistency of classical mathematics … on the basis of the syntactical interpretation" [v].

*For us:* tolerance holds only among *coherent* frameworks. Coherence is Π₁, so it is refutable but not certifiable from inside (T2 Thm 5.3). The coherence loss is the mechanized search for the inconsistency that would disqualify a "convention". This is Gödel's objection turned into a training signal, and it inherits his limit: passing the search never proves consistency.

### 6.5 Quine, "Two dogmas"

Quine, *Phil. Rev.* 60 (1951) 20–43 [mem]. He denies any principled analytic/synthetic line, holds that "no statement is immune to revision" [mem], and later proposes minimum mutilation (*Philosophy of Logic*, 1970 [mem]). L4 §6 covers entrenchment. Two additions here:

**(a) Holism makes negative bags ambiguous between rules and premises.** A ⊥-derivation uses rules *and* background premises K_A. Revising K_A and revising a rule are both consistent repairs. Without a prior asymmetry (designation, entrenchment, data priority) the evidence cannot choose between them; this is the Duhem–Quine analogue of the Thagard symmetry (§3.2).
* So contexts must be *designated* (T2 Prop 7.1).
* The user's "piecemeal revision" needs an entrenchment prior; coherence does not supply one.

**(b) Revision of logic is built in.** T2's Post-completeness results say when this is harmless (CPC) and when it is not (intermediate logics).

---

## 7. Answers to the four key questions

**(1) Principled justification beyond proof.** The proposal (ours) is **vindicated wide reflective equilibrium (VWRE)**, a synthesis of Goodman, Daniels, Haack and reliabilism. A rule set is justified relative to explicit assumptions 𝒜 when three conditions hold:
* **(i) Equilibrium.** It is the output of mutual adjustment between particular judgments, general rules, and channels with *independent* support (Daniels' constraint; Haack's clues).
* **(ii) Local checkability.** Every accepted step is checkable by the rules alone, and failures localize to negative bags (the user's J1–J3; L10 §2.1).
* **(iii) Vindication.** A theorem shows that, under 𝒜, the procedure is sound against every adaptive prover with probability ≥ 1−δ, with bounded abstention or mistake cost, ideally anytime.

A theorem of type (iii) is evidence for three things:
* **(a) Conditional reliability of RE.** Goodman's circle becomes *provably* virtuous relative to 𝒜. This is what BonJour's metajustification could not deliver in general.
* **(b) Necessity of each ingredient**, through the matching impossibility results (Lemma 2.1; T2 Thm 2.6 and §6).
* **(c) A fact about the domain.** Coherence pins down CPC and RCF but not arithmetic or physics, which is why physics needs export certificates and world feedback.

It is not a non-circular foundation (Carroll, Haack). It is not usable by the reasoner to certify itself (Löb). It is the designer's externalist guarantee, in the sense of Goldman's reliabilism and Boghossian's "blind but blameless" [v].

**(2) Stich versus Cohen.**
* Imitation instantiates Cohen: it converges to competence, systematic errors included (Prop 2.2).
* Narrow RE cannot remove *coherent* systematic errors, which vindicates Stich (Lemma 2.1). Which errors these are is computed in T2 §6.
* The remedy is wide RE with an independent channel. Expert weighting helps only against non-shared errors (Dawid–Skene).
* Error attribution is itself fallible (Miller–Sanjurjo).

**(3) Coherence impossibility.** The results do not apply to eliminative coherence (U1), and fully apply to coherence-as-confirmation (U3). The escapes are listed in §3.4.

**(4) Carroll for learners.** The formal content is (C1)–(C5) in §4.2. Its upshot: the justification of the engine cannot come from the store.

---

## 8. Theorem candidates

* **TC1 (Stich lemma plus residue).** Under (i)–(iii) of Lemma 2.1, every δ-sound learner abstains on the instances of every human-systematic fallacy in Alt(R*, 𝒜) ∩ {F : W does not expose F}. With a world channel that exposes F with per-query probability μ_F > 0, F is eliminated after O(log(1/δ)/μ_F) queries. This is the finite-sample form of orchestrator idea 4(d).
* **TC2 (imitation-MDL absorbs systematic errors).** For fixed λ, absorption occurs at n* ≈ λK(F)/(H(φ) + φ log M). Any λ schedule that prevents absorption of F also prevents learning valid rules with the same (φ, K) profile. To be made rigorous with a proper two-part code over situation types; the heuristic is in script 12.
* **TC3 (consensus does not amplify under common cause).** Suppose that with probability π > 0 all annotators copy one shared judgment, and that this judgment is wrong with positive probability. Then the posterior odds from m agreeing annotators are bounded by a constant independent of m. If they are conditionally independent with p > q, the odds grow as (p/q)^m. Corollary: self-consistency across samples of one model certifies nothing against that model's systematic errors.
* **TC4 (eliminative coherence is never truth-adverse).** Conditioning a prior over hypotheses on coherence over a truthfully designated 𝒜 weakly increases the posterior of h*, and leaves all odds among coherent hypotheses unchanged [script 5]. With mis-designation, the damage is bounded as in T2 Thm 2.5. Pair this with an explicit statement that no degree-of-coherence *bonus* term can have this property for every reliability (Bovens–Hartmann).
* **TC5 (asymmetric coherence clause structure).** The learner's objective is weighted MAX-SAT, with negative-bag clauses, positive-data clauses and MDL costs. Pure-coherence objectives (Thagard) are complement-symmetric. Negative-bag-only objectives are minimized by the empty rule set. Only the mixed objective has informative optima. This is the formal version of BonJour's isolation objection, and it is the reason the loss needs a positive-data term.
* **TC6 (rule versus premise separations).** C2 (strictness), C3 (schemas need instantiation), C4 (necessitation; reflection rule versus Löb). Include the learner reading: an export rule is a Π-claim, and the safe policy is Popperian.
* **TC7 (self-certification).** Rule-circular self-certification has likelihood ratio 1 between sound and unsound hypotheses that share the certifying rule. A self-proof of Con by an r.e. extension of PA is a proof of inconsistency. Hence self-checking must never feed back into acceptance.
* **TC8 (rules learnable, truths not).** There is a hypothesis class in which the target calculus (classical logic plus PA axioms) is identifiable in the limit from positive and coherence data, while no learner using the same channels plus computable feedback decides Σ₂ truth in the limit. This is the formal reply to the acquisition argument. Combine T2 Thms 3.10 and 4.4 with L1 finite elasticity.
* **TC9 (limit theorems do not discriminate).** For any learner that identifies in the limit, there is another that identifies in the limit and is unsound at every stage before an arbitrary finite time. Trivial, but worth stating to justify demanding anytime bounds.

---

## 9. Corrections and refinements to the brief

1. **"Coherence loss" names three different things.** (U1) eliminative refutation, (U2) probabilistic consistency of credences, (U3) agreement as confirmation. Only U1 is immune to the Bovens–Hartmann and Olsson theorems. U3 is subject to them and fails under common-cause human error. Any design that uses human or sample *agreement* as a confidence signal needs an independence argument.
2. **"Conditioned on coherence *or* practical success" should be "and".** Imitation plus coherence is narrow RE. It provably cannot remove coherent systematic fallacies (Lemma 2.1), except in coherence-pinned domains (CPC, RCF). World feedback, from a channel independent of human error, is a necessary conjunct for any guarantee beyond those domains.
3. **H7's "community practice" cannot certify validity.** Community agreement is not independent testimony. It fixes the *target of imitation* (Cohen), not validity (Stich). Expert weighting removes only non-shared errors.
4. **L10's T5 (steeper simplicity coefficient) holds only on a finite-sample window.** For fixed λ, every compressible systematic error of positive frequency is eventually learned (Prop 2.2). Asymptotic separation of errors from rules needs a validity-sensitive channel.
5. **Export rules are rules, not premises (Carroll).** Their validity is universal over situations, so world feedback can only refute them. The learner should treat exports with Popperian caution. Their justification has to be a guarantee about the process that accepts them, not more premises.
6. **"Learning inference rules ≈ learning meanings" needs the Boche caveat.** Meaning-constitutive rules can be coherent yet materially false. Coherence catches tonk-type defects but not Boche-type defects, which need world feedback or a conservativity check (not even limit-decidable; T2 Thm 5.3). So "learning meanings" and "learning valid rules" come apart exactly at non-conservative, consistent material rules.
7. **Self-trust must be implemented as a rule, never as an axiom** (Löb). Self-certification of soundness by the learned verifier must never feed into acceptance (Haack's indiscriminacy; Gödel II).
8. **Present the theorems as vindications relative to explicit assumptions, not as foundations.** The right gloss is "conditional reliabilist metajustification of wide RE". Limit theorems are Reichenbachian and weak (Salmon); anytime bounds are what discriminate. This matches the user's own preferences (L10 §2.4).

---

## 10. References

Flags as in the legend: [v] confirmed this session by web search (gist plus bibliographic data); [mem] from memory.

- BonJour, L. (1985). *The Structure of Empirical Knowledge*. Harvard UP. [v]
- Beisbart, C., Betz, G., Brun, G. (2021). Making reflective equilibrium precise: a formal model. *Ergo* 8:441–472. [v]
- Boghossian, P. (2000). Knowledge of logic. In Boghossian & Peacocke (eds.), *New Essays on the A Priori*, OUP. [v]
- Boghossian, P. (2003). Blind reasoning. *Proc. Arist. Soc. Supp.* 77:225–248. [v]
- Boghossian, P. (2014). What is inference? *Phil. Studies* 169:1–18. [v]
- Bovens, L., Hartmann, S. (2003). Solving the riddle of coherence. *Mind* 112:601–633. [v]
- Bovens, L., Hartmann, S. (2003). *Bayesian Epistemology*. OUP. [mem]
- Bovens, L., Hartmann, S. (2006). An impossibility result for coherence rankings. *Phil. Studies* 128:77–91. [v]
- Carnap, R. (1934/1937). *Logische Syntax der Sprache* / *The Logical Syntax of Language*, §17. [mem]
- Carnap, R. (1950). Empiricism, semantics, and ontology. *Rev. Int. de Philosophie* 4:20–40. [mem]
- Carroll, L. (1895). What the Tortoise said to Achilles. *Mind* 4:278–280. [mem]
- Cohen, L. J. (1981). Can human irrationality be experimentally demonstrated? *BBS* 4:317–370. [v]
- Daniels, N. (1979). Wide reflective equilibrium and theory acceptance in ethics. *J. Phil.* 76:256–282. [v]
- Dawid, A. P., Skene, A. M. (1979). Maximum likelihood estimation of observer error-rates using the EM algorithm. *Applied Statistics* 28:20–28. [mem]
- Dummett, M. (1959). Truth. *Proc. Arist. Soc.* 59:141–162. [mem]
- Dummett, M. (1973). *Frege: Philosophy of Language*. Duckworth. (Boche, p. 454.) [v]
- Dummett, M. (1973). The justification of deduction. *Proc. British Academy* 59. [v]
- Dummett, M. (1991). *The Logical Basis of Metaphysics*. Harvard UP. [mem]
- Elgin, C. Z. (1996). *Considered Judgment*. Princeton UP. [mem]
- Elgin, C. Z. (2017). *True Enough*. MIT Press. [v]
- Freivogel, A. (2023). Does reflective equilibrium help us converge? *Synthese* 202:171. [v]
- Gilovich, T., Vallone, R., Tversky, A. (1985). The hot hand in basketball. *Cogn. Psych.* 17:295–314. [mem]
- Gödel, K. (1953–59/1995). Is mathematics syntax of language? In *Collected Works* III, OUP. [v]
- Gold, E. M. (1965). Limiting recursion. *JSL* 30:28–48. [mem]
- Goldman, A. (1979). What is justified belief? In G. Pappas (ed.), *Justification and Knowledge*. Reidel. [mem]
- Goodman, N. (1954/1955; 4th ed. 1983). *Fact, Fiction, and Forecast*, ch. III. Harvard UP. [v for quotation; mem for pages]
- Haack, S. (1976). The justification of deduction. *Mind* 85:112–119. [v]
- Haack, S. (1982). Dummett's justification of deduction. *Mind* 91:216–239. [mem]
- Haack, S. (1993). *Evidence and Inquiry*. Blackwell. [v]
- Humberstone, L. (2010). Smiley's distinction between rules of inference and rules of proof. In J. Lear & A. Oliver (eds.), *The Force of Argument*. Routledge. [v for title; mem for volume]
- Kelly, K. (1996). *The Logic of Reliable Inquiry*. OUP. [mem]
- Kelly, K. (2007). Ockham's razor, empirical complexity, and truth-finding efficiency. *TCS* 383:270–289. [mem]
- Klein, P., Warfield, T. (1994). What price coherence? *Analysis* 54:129–132. [v]
- Lakatos, I. (1976). *Proofs and Refutations*. CUP. [mem]
- Lewis, C. I. (1946). *An Analysis of Knowledge and Valuation*. Open Court. [mem]
- Löb, M. H. (1955). Solution of a problem of Leon Henkin. *JSL* 20:115–118. [mem]
- Meijs, W., Douven, I. (2007). On the alleged impossibility of coherence. *Synthese* 157:347–360. [v]
- Miller, J. B., Sanjurjo, A. (2018). Surprised by the hot hand fallacy? A truth in the law of small numbers. *Econometrica* 86:2019–2047. [v]
- Olsson, E. J. (2002). What is the problem of coherence and truth? *J. Phil.* 99:246–272. [mem]
- Olsson, E. J. (2005). *Against Coherence: Truth, Probability, and Justification*. OUP. [v]
- Olsson, E. J. (2005). The impossibility of coherence. *Erkenntnis* 63:387–412. [v]
- Peirce, C. S. (1878). How to make our ideas clear. *Popular Science Monthly* 12:286–302. [mem]
- Prior, A. N. (1960). The runabout inference-ticket. *Analysis* 21:38–39. [mem]
- Putnam, H. (1965). Trial and error predicates and the solution to a problem of Mostowski. *JSL* 30:49–57. [mem]
- Quine, W. V. (1936). Truth by convention. In O. H. Lee (ed.), *Philosophical Essays for A. N. Whitehead*, 90–124. [v]
- Quine, W. V. (1951). Two dogmas of empiricism. *Phil. Rev.* 60:20–43. [mem]
- Quine, W. V. (1960). *Word and Object*. MIT. [mem]
- Rawls, J. (1951). Outline of a decision procedure for ethics. *Phil. Rev.* 60:177–197. [mem]
- Rawls, J. (1971). *A Theory of Justice*. Harvard UP, §§4, 9. [mem]
- Rawls, J. (1974). The independence of moral theory. *Proc. APA* 48:5–22. [v]
- Reichenbach, H. (1938). *Experience and Prediction*. U. Chicago Press. [mem]
- Schupbach, J. (2008). On the alleged impossibility of Bayesian coherentism. *Phil. Studies* 141. [v for title and venue; mem for volume]
- Schurz, G. (2019). *Hume's Problem Solved: The Optimality of Meta-Induction*. MIT Press. [v]
- Shogenji, T. (1999). Is coherence truth conducive? *Analysis* 59:338–345. [v]
- Smiley, T. (1963). Relative necessity. *JSL* 28:113–134. [v]
- Stich, S. (1988). Reflective equilibrium, analytic epistemology and the problem of cognitive diversity. *Synthese* 74:391–413. [v]
- Stich, S. (1990). *The Fragmentation of Reason*. MIT Press. [v]
- Stich, S., Nisbett, R. (1980). Justification and the psychology of human reasoning. *Phil. Sci.* 47:188–202. [v]
- Thagard, P. (1989). Explanatory coherence. *BBS* 12:435–467. [mem]
- Thagard, P., Verbeurgt, K. (1998). Coherence as constraint satisfaction. *Cognitive Science* 22:1–24. [v]
- Warren, J. (2017). Revisiting Quine on truth by convention. *J. Phil. Logic* 46. [v for title and venue]
- Warren, J. (2020). *Shadows of Syntax*. OUP. [mem]
- Wheeler, G. (2012). Explaining the limits of Olsson's impossibility result. *SJP* 50:136–150. [v]
- Wheeler, G., Scheines, R. (2013). Coherence and confirmation through causation. *Mind* 122:135–170. [v]
- Williamson, T. (2003). Blind reasoning (companion paper). *Proc. Arist. Soc. Supp.* 77. [v]
