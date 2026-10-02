# L10: Digest of the user's own notes (kaarelh/notes), for the inferential-learning project

**Scope.** This is a close reading of `/home/user/kaarelh/notes` (a clone of github.com/kaarelh/notes, ~950 markdown files plus a few PDFs). It covers everything I found that bears on the project: learning inference rules from human examples, coherence, sparse world feedback, contexts, and "principled justification beyond proof". All paths below are relative to the repo root. Quotes are verbatim, including the user's lowercase style and profanity. Dates are inferred from pasted-image filenames or explicit dates in the notes and are approximate.

**Method.** I read in full every note in these directories:
* `philosophy/philosophy of language/meaning and truth/`
* `ai/verification and generation/` (including the PDF `formalizing philosophy.pdf`)
* `ai/learning/solomonoff induction/` and `ai/learning/circuit solomonoff/`
* `philosophy/prediction/`
* `philosophy/philosophy of thinking/gödel/`
* `logic/`, except the routine incompleteness expositions
* `philosophy/philosophy of mathematics/`
* `introspection/`

I also read the relevant notes in `philosophy/concepting/`, `philosophy/philosophy of thinking/`, `philosophy/metaphilosophy/`, `philosophy/epistemology/`, `philosophy/philosophy of science/`, `philosophy/philosophy of physics/`, `ai/DLK/` and `advice on thinking and research/`, plus the top-level `questions.md` and `uncategorized ideas.md`. I grepped the whole repo for: justification, inferentialism (and its authors), olympiad, idealization, context, coherence and positive-example learning.

Literature claims are kept minimal here. Where they appear, they are marked [mem] (from memory, not re-checked this session; web access was unavailable) or deferred to the sibling memos L1, L2, L6, L7 and L8.

---

## 0. Executive summary (the ten things the write-up must engage with)

1. **The user's goal is verification.** Generation is secondary. Physics-olympiad checking matters to him because it is "plausibly a really simple case in the class of cases we do not understand yet" (`ai/verification and generation/verification of physics olympiad solutions/for and against…`). Verification itself matters as a possible route to safely using an *untrusted* generator (`formalizing philosophy.pdf`; `ai/alignment general/…/some good questions in conceptual alignment.md`).
   * So worst-case soundness against an adversarial arguer (H1) is not a technicality to him. It is the whole point.
   * He explicitly worries that defeasible argument systems lose "all the safety" against an untrusted prover.
2. **He already has the formal-math half of the idea, in Solomonoff language.** The pieces:
   * "Solomonoff axiom induction" (spring 2026).
   * His own Craig-style proof that it is equivalent to Solomonoff *function* induction restricted to consistent labelers.
   * The observation that a total computable separator of provable from refutable sentences cannot exist (the consistent-guessing problem).
   * The guess that the simplest program labelling human-proved and human-refuted statements is proof search.
   * A counter-observation of his own: function induction fails when "there is a simple property distinguishing test from train". This is exactly the mechanism behind H1.
   
   The project should present itself as answering *his* open questions about these objects (§3.3).
3. **He has an explicit proposal for getting *valid* rules out of *imitation* of fallible humans.** Use a steeper simplicity penalty in function induction, so that the MAP hypothesis is "simple model + noise" rather than "model + memorized human errors". He gives a convex-hull argument and says he has not looked for a proof or a pathology (`philosophy/philosophy of thinking/beating solomonoff induction at grokking a notion.md`). This is a natural theorem target (§4, T5).
4. **His picture of how humans acquire a mathematical structure is the coherence-driven rule learner.** "they discard ones that cause 'collapses'/'contradictions' … if a desirable relation causes incoherence, this prompts the physicists to revise some of the previously tentatively (implicitly) accepted relations … there is some kind of associated categoricity result" (`philosophy/philosophy of thinking/how categoricity (or universal properties) relate to the implementation of mental structures.md`). H2 remedy 2 and H5 are his own view, stated informally.
5. **Coherence implies existence: his "philosophical completeness theorem".** "'a mode of talking makes sense (is coherent) iff there is something it could be talking about' … is a generalization of the completeness thm available that justifies this philosophical proposition more broadly?" (`logic/a 'philosophical version' of gödel's completeness theorem.md`). He also knows the caveat: coherence only guarantees non-standard existence, as with the "proof" of the Gödel sentence in a non-standard model (`…/3f math, thinking, and technology are equi-infinite.md`, footnote 5). H3 and H4 should be framed as answers to his question.
6. **Contexts.** He has posed the question sharply and has partial answers:
   * "check that a claim is true in the context at hand. but wtf is that???" (`verification from truth.md`);
   * "a dance with many clear setups … contradictions being provable from stuff … there's a local setting up of a clear thing" (`the structure of physics olympiad solutions.md`);
   * the flat-earth "100 = 99.9" example of catastrophic cross-context reasoning, and doubt that "any nice 'formal criterion' is going to be right" (`philosophy/philosophy of science/the domain of applicability of a scientific mode(l).md`);
   * a warning that **proofs by contradiction inside a known-inadequate framework are suspect**, because they may "really involve subverting the background framework" (`philosophy/epistemology/probabilities/assigning probabilities in a conception of the world you know to be inadequate.md`).
   
   That last point directly qualifies H6's "deriving ⊥ inside a hypothetical context is legitimate (reductio)".
7. **His own physics-olympiad introspection already exhibits the export criterion of robustness/invariance.** "the angle from horizontal turns out not to matter for the answer"; "a lot of these choices are equivalent for our purposes, so basically it doesn't matter". It also exhibits the role of the *intended* idealization: "i peeked at the solution and it seems to assume that's not the case. nice i guess. sad if you're at the competition?" (`introspection/…/introspect-solving eupho 2025-T1.md`). This supports L7's supervaluational criterion ("correct iff invariant across admissible completions of the intended model").
8. **He has a model of informal mathematics.** Pre-formal mathematicians used only the robust core of their concepts, so their proofs survive formalization: "the 'rest of the concept' … was untrustworthy/messy … and for this reason unusable whenever people were proving things" (`philosophy/metaphilosophy/why is it a good idea to make vague notions precise?.md`).
   * Formalization was "a language in which formal proofs can be written", not word-by-word translation (`…/verification of physics olympiad solutions — general principles.md`).
   * He asks: "how come mathematicians ended up with such a nice notion of proof? … this nice structure of a formal proof is sorta there in their activities. how did it come to be there?" (`philosophy/emergence of structures/how come mathematicians ended up with such a nice notion of proof?.md`).
   
   This is success criterion 2 in his own words.
9. **His meta-view: thinking, mathematics and justification are "infinite endeavors" with no final formula** (Advent-of-thought notes 1f–3f; `philosophy/metaphilosophy/big things are infinitely inadequate.md`). He also rejects deflations such as "accepting an axiom is accepting a string-game rule" ("you want to be done here way too hastily"). Consequences for the write-up:
   * Present results as "a nice thing shadowed in" practice, not as *the* theory of meaning or justification.
   * Do not claim that "learning inferential roles = learning meanings" without qualification. His own "compositional inference warranting" is explicitly one aspect of meaning among several.
10. **Two cautions.**
    * (a) In a July 2024 draft he writes: "(This is not to say that it is fine to publish insightful research on AI theorem-provers — in my opinion, publishing such research is omnicidal.)" (`formalizing philosophy.pdf`, §2). The deliverable should therefore lean toward *checking and justification*, and should let him decide what to publish. Capability-flavoured artifacts, such as a strong prover, are the risky part.
    * (b) The C-model/L-model note is headed "text below now disendorsed probably". Treat that distinction as vocabulary he has worked with, not as a settled view.

---

## 1. Note-by-note digest

Format: **path**, then a summary, then key quotes.

### 1.1 Meaning and truth (`philosophy/philosophy of language/meaning and truth/`)

**`compositional inference warranting (a view of meaning).md`**
* Proposes that one aspect of a sentence's meaning is the inferences it warrants, determined compositionally by its parts.
* Shared structure across inferences (e.g. "across the road") is evidence of a shared mental component.
* Montague semantics is respected but not taken to be the whole story.
* The to-do: study "how new inferential skills are gained … what it looks like to gain a new concept".

Quotes:
* "there are learned inference rules; there is logic (also? or in other words?)"
* "there's an (imperfect) inference from 'there's a building across the road' to 'there's a door within 100 meters'"
* "the valid inferences to draw from a sentence are somehow determined by its parts"

Project relevance: this is the user's own inferentialism. Note that the inferences are *imperfect* (defeasible), so the inferences are not purely deductive even here.

**`between verificationism and holism.md`**
* Against straw verificationism: sentences can't be given standalone observational translations.
* Against straw holism: language has fine structure, and is revised piecemeal ("an inadequacy in our understanding of a part of the world then immediately suggests a part of our language for revision").
* Predictions should be produced "cheaply … using only a few concepts".
* He objects to holism's tendency to judge theories "from some external standpoint — e.g., solomonoff induction — whereas really we judge and amend our understanding from 'inside' that understanding."

Project relevance: blame assignment for contradictions (negative bags) is *piecemeal revision*. That is the structure he wants. Sparse activation of concepts is "cheap prediction".

**`the correct theory of semantics.md`** (tongue-in-cheek title)
* Mental models are like theories; "the real thing is kind of like a model-in-the-sense-of-model-theory of your model".
* Worked example: reasoning about a program via ZFC with "bridge laws" translating empirical queries (runtime, list contents) into ZFC statements, with "thinking" as bounded proof search.
* "there is a dance where you have a way of thinking, you have some things it helps you with but also some failures …, then better ways of thinking".

Project relevance: this is a concrete template for an export/bridge map, with formal inside and empirical outside.

**`what is it to accept an axiom or an inference rule?.md`**
* Accepting extensionality "feels like a convention … specifying the manner in which we mean to conceive of a set".
* "there's something phenomenologically wrong about saying 'you're just accepting a rule in a string game'"
* "it feels more like saying: 'ahh, i'm considering this sort of thing now'. or maybe 'ahh okay this is how i'm looking at things'."

Project relevance: on his view, accepting a rule ≈ *adopting a conception/context*. This matters for the framing of contexts.

**`meaning.md`, `some considerations with an eye toward specifying a picture of meaning.md`**
* Candidate meanings: possible-world partitions, verification conditions, role in action, translation.
* Each is "very much not grasped — they can take hard work to determine".
* His target is "the structures that have been created in your head when you have understood a sentence", understood as a data structure: "what sorts of operations does your sentence representation support? … how does a sentence representation support inferences?"
* Also: cheap vs expensive inferences from a scene; concepts as questions one can ask ("is this a dog?") rather than classifiers. "it's fundamentally an open/moving thing".

**`a helpful picture…`, `individual sentences being meaningful.md`**
* From a God's-eye view one can judge each of a speaker's sentences individually: "each sentence is individually meaningful in the context of his language/model — it's not that his model only relates to reality holistically".
* But he immediately asks: "does this look like checking that their axioms are true and their inference rules are truth-preserving? wait but we don't already understand what it is for their axioms to be true, do we?"
* Open questions: "what is the structure of the hooking of a model onto the world? … how does one originally find good models+hookings? how does one improve and repair one's models+hookings?"

**`propositions fit into a context of action.md`**
* Meaning may be fixed "action-facingly"; perhaps "once the meaning is determined, its truth-value should be determined non-action-facingly".

### 1.2 Concepts (`philosophy/concepting/`, plus related notes)

**`good concepts are concepts that support inferences.md`** (also reproduced in `gaining concepts/some ways one gets new concepts.md`)
* A concept is good when many inferences flow into and out of it (continuity).
* **Concept invention as factoring a biclique:** "there is a new useful concept to be invented/discovered when one notices that one's graph of allowed inferences has a complete bipartite subgraph which is not already explained by a concept … 'factored through' a new property X like A_i ⟹ X ⟹ B_j".
* The trivial choices X = ∨A_i or ∧B_j always work, "But I think one would like to have a new concept X that is simple and/or easy to work with."
* Multiple equivalent definitions plus "the fundamental theorem supporting the dimension notion" (TFAE).
* Concepts upgrade a "cheap symbolic engine" (AlphaGeometry).

Project relevance: this is a concrete predicate-invention operator for the rule learner, with an MDL rationale. A biclique of n·m rules becomes n+m rules. Compare inverse-resolution "intra-construction" (Muggleton & Buntine 1988 [mem]).

**`gaining concepts/gaining the integral notion.md`**
* "in the presence of certain kinds of broader mental context, the integral notion is basically uniquely determined in any of a variety of ways … by specifying that it satisfies certain [inference rules]/axioms/properties".
* Theorems like Riemann = Lebesgue = antiderivative are "a sort of rigid version of the softer thing".
* "there could be an interesting field of study about the robustness of such notion-sharing processes".
* The historical puzzle: "we hypothesized an object with some properties and these properties turned out to be those of a real thing … how did we identify this set of properties as important?" (from `beating solomonoff…`).

**`philosophy of thinking/how categoricity (or universal properties) relate to the implementation of mental structures.md`**: the key note for H2, H4 and H5.
* Humans gain command of a structure by adding relations to an inventory, with no sharp axiom/theorem distinction. Then:
  * "they might (implicitly) try out different new relations. they discard ones that cause 'collapses'/'contradictions'";
  * "if a desirable relation causes incoherence, this prompts the physicists to revise some of the previously tentatively (implicitly) accepted relations";
  * "relations can be made more precise, or have their domain of applicability more precisely delimited";
  * "after playing around enough, you might have an (implicit) set of manipulation rules which pin down the structure uniquely — there is some kind of associated categoricity result."
* He proposes a complexity measure for structures: "the ease of finding it in some relation-search … the length of the smallest set of conditions determining it (ie the sum of lengths of the assumptions in the smallest categoricity result …)".
* Worry: "categoricity results are usually in second-order logic, which is sorta fucked".

**`metaphilosophy/why nice objects with shit definitions?.md`, `math/meta/…/why concepts? (in math).md`**
* Objects like integrals and homology are used via a few characterizing properties, often "the unique things satisfying these properties".
* On truth: "there's nothing that could be called a truth algorithm … in a kolmogorov sense maybe truth and provability wouldn't be considered simple properties at all! but there is obviously a sense in which they are simple!"
* "concepts can be thought of in large part as carrying information in associated lemmas which compress certain repeating steps in proofs".

Project relevance: the simplicity that matters is that of the *rules* generating the practice, not of the extension (the set of truths). This is an argument for learning generators of the practice (rules and schemas) over learning a truth classifier.

**`philosophy of thinking/beating solomonoff induction at grokking a notion.md`**: central to the project.
* A Solomonoff predictor of a teacher learns the teacher's mistakes. Humans instead learn *what the teacher means*. His proposals:
  * (i) "an even stronger simplicity prior than solomonoff … the simple model that doesn't predict the mistakes … penalize the likelihood term less". He argues this avoids a pathology in function induction, though not in sequence induction, if each input gets private randomness. He gives a worked example: a 100-bit model, plus rare errors that cost 10000 bits to specify, versus a coin-flip model. He conjectures the good model is "a vertex of the convex hull of the set of attainable (hypothesis complexity, expected neg log likelihood) tuples". He adds: "I haven't spent that much time trying to come up with other pathological constructions or searching for a proof".
  * (ii) a "simplicity prior defined in terms of existing understanding";
  * (iii) specifying properties of the notion (e.g. 1+1=2 rules out a bad mapping);
  * (iv) asking "what is it that this person is trying to teach me".
* Normativity: "we understand 'is this a chair?' as clearly separate from 'would the person who taught me the chair notion consider it a chair?'. it is much closer to 'should the person who taught me … consider it a chair?'"
* "important basic point here: our dog thing is NOT a classifier."
* **The project's question in his words:** "pinning down the notion of a proof might be a good example to study in detail. like, how does one become able to tell whether something is a good proof? a valid reasoning step? how does one start to reason validly? … analogous to: how does one become able to tell what's good".
* On truth versus provability: by completeness, "a fine notion of truth, ie one which has a model, is precisely one which assigns 0/1 to all sentences and is coherent under proving". (The note contains an evident slip, "exactly one of a sentence and its negation is provable", where "true" is meant.)

**`research/a framework for understanding conceptual revision.md`**
* "Conceptual revision is when you have a set of propositional statements and you are redefining individual terms one at a time to try to make the whole set of propositional statements as true as possible … like coordinate descent in idea-space".
* "This turns it all into a semi-empirical question of what conceptual revision method is best".

### 1.3 Philosophy of thinking

**`cheap inferences.md`**
* AlphaGeometry has a brute-force cheap deduction engine plus learned auxiliary constructions. Generalizing this, "your conception of the situation" ≈ the propositions you see very easily.
* Hints in olympiads supply "auxiliary points" (Putnam 2025 A3: "perfect matching").
* "there isn't really a correct cheap inference engine, like there is in alphageometry — this inference engine needs to be learned."
* Questions: "what is the core inference engine, ie the thing present in all contexts? … there cannot be an inference engine for each context that gets learned separately … what's the type signature of such a component / what data is it tracking?"
* "we could consider the cheap inferences 'analytic' and the expensive ones 'synthetic' … an interesting nonstandard precisification of the analytic/synthetic distinction".

Project relevance: this is the two-tier architecture of a learned cheap step relation (closure) plus expensive search. Per-concept rule components composed per context is exactly a compositional, context-indexed rule learner.

**`propositionality of thought/why is thought propositional?.md`**
* Hypothesis: propositional representations are good because "one can learn inference rules 'on these representations', and this turns out to be really efficient". The alternative is "a shitmess of inference rules" from pictures to actions.
* Also listed: "supporting setting up a model of some stuff … prove the ideal gas law 'in' this model".

**`analogy/logical models as distinct from mental models.md`** (headed "text below now disendorsed probably")
* Distinguishes **L-models**: semantic, external, static, fully developed.
* From **C-models** ("models-as-conceptions-of-situations"): reasoning tools, roughly syntactic, dynamic, "like a mental context/arena where certain moves are made available/salient, like a game".
* Crucially: "we could maybe even imagine a case where a C-model is given with some 'axioms and inference rules' such that if one tried to construct a mathematical object 'wrt which all these axioms and inference rules would be valid', one would not be able to construct anything … Maybe physicists handling infinities gracefully when calculating integrals in QFT is a fun example".
* Employing a C-model ≈ making an analogy.
* The counterargument section notes that one often *selects* a C-model as an object satisfying given properties, as with an L-model.

Project relevance: our "contexts" are C-models. An inconsistent but useful physics context is a C-model without an L-model, in his own terms.

**`analogy/likening a situation to a mathematical situation.md`**
* "we liken real-world … situations to formal/mathematical/abstract situations. this seems like a central mental move".
* Method: "list some properties and try to just find the simplest thing which satisfies these properties". He proposes a math problem: given p₁, p₂, p₃, weight all objects satisfying them and estimate P(p₄).
* Open: "how is a mathematical setup modified when it is found to be inadequate; eg what kinds of 'bridging laws' between the situation of interest and the formal situation need to be provided".

**`a few notes on frames.md`**
* "claims are always in some background context … there are many different background contexts, not one, and it is very useful that this is so. what's more, these different frames needn't be easily reconcilable."
* "frames are machines letting you do things. i think it can totally be right for one person to think what looks like P … and for it to be right for another person to think what looks like not P."
* "there can be a lot of alpha in reconciliation" (wave/particle → QM; reference frames → SR).

**`notions of coherence.md`, `advent…/16 coherence isn't even there in the limit of large time.md`**
* Lists many notions of coherence (parts fitting together, efficiency, no arbitrage, regret bounds…).
* "Coherence/efficiency is characteristic of a very big mind/optimization meeting a very small problem/world."

Project relevance: he does not treat "coherence" as a single primitive. Our coherence should be stated narrowly: logical non-contradiction of asserted positions.

**`how do i resolve contradictions, tensions?.md`**
* A lived example: "one way to resolve a tension/contradiction is to go back to what caused one (or each) of the contradicting views/predictions/claims". This is blame assignment along the derivation.

**`what does reflection-done-systematically look like?.md`**
* "you see a thought-pattern; you put it in the list of allowed thought-moves … with the requirement that the move always needs to be absolutely truth-preserving (ie excluding heuristic moves), this just looks like mathematics?"

**`philosophy of understanding/model-thinking in mathematics.md`**
* On analogical reasoning between mathematical objects (random model of primes; expanders as Erdős–Rényi graphs): "can we say something about this sort of thinking being trustworthy? … my guess is that one can't build a robust verifier for this … one probably just can construct an object that has whatever 10 properties of the first object but gets property 11 wrong".
* Open: "in circuit induction, how to trade between simplicity and accuracy?"

**`philosophy of understanding/induction in mathematics.md`**: a small positive result of his own.
* Commit to checking P up to a *random* stopping index N, then infer P(N+1). Then "having fixed P, there is at most a unique such n, so the probability of this is at most the max over n of the stopping probability at n". This is an arbitrarily large odds boost.
* On reference classes: "one can in principle always cook up classes in an adversarial fashion … maybe this mostly goes away once one starts to prefer simpler classes?"

Project relevance: this is a template for a *defeasible rule justified by the reasoner's own randomization*, worst-case over a P fixed in advance. It is cousin to Schwartz–Zippel spot checks (orchestrator idea 3).

### 1.4 Gödel, Löb and self-trust (`philosophy/philosophy of thinking/gödel/`, `philosophy of mathematics/`)

**`reasoning system self.md`, `seeing (meta)ethics clearer via mathematical logic.md`, `gödelian obstacles writeup (plan).md`**
* A thought experiment: an uploaded reasoner given its own source code writes accepted statements to a list. If it accepts "such-and-such-a-process will never come to accept 0=1", it derives 0=1.
* He plans to justify Hilbert–Bernays–Löb conditions for realistic acceptance predicates, including **defeasible/probabilistic ones**: "i-will-accept-P-at-most-times or i-will-assign-probability-greater-than-2/3-to-P-at-a-set-of-times-of-limiting-density-1".
* "if one, inside a system of reasoning, starts to trust one's own reasoning as providing truths, then one is in trouble."
* The calculator analogy: a calculator computes 2+3, not "what I would output".
* "there is some outside view in which it is fair to describe me as starting to think x is good when i have reason to do so … one even endorses this process, from the outside … but one can't endorse this process from the inside".

**`gödel for defeasible reasoning.md`**
* "maybe the ans here is that your eventual probability in any löb sentence prv P implies P (for a sentence P for which you have no proof or disproof) will be 0? … (the defeasible antirealist must come to abandon their antirealism)".

**`philosophy of mathematics/does a consistency proof give us reason to believe a system is consistent?.md`**
* "the existence of a proof that the weaker system is sound in a stronger system should make us update toward thinking that the weaker system is more likely to be inconsistent". But human-found relative consistency proofs plausibly do raise confidence. This is unresolved.

Project relevance (constraint):
* The learner must not add reflection rules over its *own* learned acceptance relation ("if V̂ accepts φ then φ"), or treat its own acceptance as evidence inside the object calculus.
* Self-trust must be stratified (trust weaker fragments) or probabilistic.
* A coherence objective must not reward the learner for "proving its own soundness".

### 1.5 Logic

**`logic/a 'philosophical version' of gödel's completeness theorem.md`**
* "'a mode of talking makes sense (is coherent) iff there is something it could be talking about' … as long as the 'mode of talking' is a first-order theory and 'something' is a model of it, then this is literally the completeness theorem. is a generalization of the completeness thm available that justifies this philosophical proposition more broadly?"
* Further examples: "probabilities describe world iff coherent" (citing MIRI's DefinabilityTruthDraft), VNM. From Sam Eisenstat: "completeness is an adjunction between sentences and models"; closed theories are the fixed points of the round trip.

**`ai/DLK/logic.md`**
* "any assignment of truth-values to sentences which does not violate inference rules can be extended to a full model".

**`advent…/3f…`, footnote 5**
* "if you squint, Gödel's completeness theorem says that anything which can be talked about coherently exists … unfortunately, in general, there might only be such a thing in the same sense that there is a 'proof' of the Gödel sentence G".

**`logic/a look at russell's paradox.md`, `confusions/ways to fix russell's paradox.md`**
* A careful informal walk through naive comprehension and Russell's paradox.
* His preferred resolution: "you can make arbitrary collections of mathematical objects … but there is no totality of mathematical objects — any collection is missing some mathematical objects" (indefinite extensibility). He adds: "i still feel somewhat weird about this...".
* See also `philosophy of mathematics/the iterative conception of set as iterated sublation.md`, which reads the cumulative hierarchy as Hegelian Aufhebung.

**`logic/confusions/soundness.md` etc.**
* He worries that "soundness simpliciter" hides a privileged model. He mostly resolves the worry ("the regular natural numbers … are just the very natural numbers of the meta-syntax").

**`logic/logical induction.md`**
* One question: why probabilities on sentences rather than joint distributions?

### 1.6 Philosophy of mathematics and the history of rigor

**`philosophy of mathematics/ZFC as a making-precise of our 'intuitions'?.md`**
* ZFC is "such a data structure made explicit".
* The intuitions can be mutually inconsistent (Bona: "The Axiom of Choice is obviously true, the well-ordering principle obviously false, and who can tell about Zorn's lemma"), "so, we make choices along the way, to coherently extrapolate our (mathematical) intuitions into a system that isn't fucked".
* In math "we are okay with making arbitrary-ish choices … as long as you don't create contradictions"; in ethics not.

**`metaphilosophy/why is it a good idea to make vague notions precise?.md`**
* "people proved a bunch of cool theorems about functions without defining them, but these theorems are right and their proofs still make sense wrt the modern definition".
* Explanation: the modern definition was already a fact in their concept, and "the 'rest of the concept' … was untrustworthy/messy/sth and for this reason unusable whenever people were proving things, so people just ended up using the eventual definition in any proofs".
* Concepts as lists of desiderata: "Maybe we've just listed a bunch of properties that are not obviously contradictory, and there then often indeed is some formal object".

**`metaphilosophy/why are there insights in things so fundamentally confused?.md`**
* Complex numbers; Stillwell on rigor lost and regained; Archimedes' *Method*: discovery by "dubious infinitary arguments", later rigorous proof.

**`emergence of structures/how come mathematicians ended up with such a nice notion of proof?.md`**
* "you see that this nice structure of a formal proof is sorta there in their activities. how did it come to be there? could maybe just look at euclidean geometry. note euclid didn't have a full set of axioms lol!"

**`philosophy of mathematics/why do different kinds of mathematics feel different…`, `system-relativity done well?.md`**
* Translations between branches exist, but they map into weird, out-of-distribution sub-branches. Hence the value of Langlands-style translations whose image is "in-distribution".

**`advent…/15f human math and alien math are pretty orthogonal.md`**
* Expects radically different mathematical developments from different starting points: "two trees growing into the same very infinite space … the size of the intersection of the trees is tiny".
* Asks whether suboptimal components get locked in.

### 1.7 Verification and generation (`ai/verification and generation/`)

**`verification from truth.md`** (in full)
* "here's a 0 iq idea for verification: just check if all the claims are true! the 1 iq response is that arguments have plenty of claims that are literally false but that are true enough for the context at hand? … the 2 iq response is that ok maybe you just check that a claim is true in the context at hand. but wtf is that???"

**`cases of verification.md`**
* Well-understood verification is basically "give me an x such that M(x)" for a Turing machine M you hold.
* For physics olympiads, φ is informal. "maybe a solution is actually more like a proof that φ(x) implies x = something … maybe it's best to think of most problems as asking one to determine the value of some variable?"
* Also listed as not well understood: arguing for imprecise P, probabilistic settings ("logical induction … doesn't really involve any kind of verification"), philosophy, technologies, plans.

**`is verification really easier than solving the problem yourself?.md`**
* Halting example: verification becomes easy once a *proof* of non-halting is requested.
* For physics, other solvers "are just more fine with treating some bigger steps as primitives, in a way that can make it hard for someone who doesn't already have those primitives to trust them … if you can interact … ask them to explain/justify/derive those".

**`x verification is easy; only x verification is hard?.md`, `why verification is tough, 2025 version.md`**
* Verifying "does F" is NP-like. Verifying "does only F" is coNP-like and cursed.
* `for and against working on verifying physics olympiad solutions.md` notes that physics olympiads lack the only-x issue.

**`examples of verifiers getting hacked.md`, `why verification is sorta tough…`**
* "reasoning models totally try to bullshit you all the time, eg giving fake mathematical proofs".
* "training against a verifier, if it works, probably completely fucks everything."

**`examples of problems where verification is as hard as generation.md`**
* Some computational answers have no proof shorter than the computation.

**`Herbert Simon on verification and generation and plato.md`**
* Simon: state descriptions versus process descriptions; "problem solving requires continual translation between the state and process descriptions".

**`formalizing philosophy.pdf`** (July 2024 draft essay)
* Formal proof checking is what makes superhuman math work potentially safe to obtain. Formalizing philosophy, which "plausibly cannot be done without formalizing everything", would be the analogue.
* Obstacles:
  * breadth;
  * the system must contain much information about human concepts and purposes;
  * "a confused question cannot be translated — it only makes sense in the language in which it was asked";
  * defeasibility. Here he writes: "one issue with a defeasible reasoning system in particular being used in the context of an untrusted prover is that we might have lost all the safety, because, if it, say, wanted to convince us of something, it could plausibly provide lots of arguments in favor of that thing";
  * a need for native reflection and redefinition.
* He distinguishes the *structure in which arguments live* from the *reasoning process that finds them*. Most mathematical reasoning (Pólya's plausible reasoning) is not formal, yet a formal proof structure still suffices.
* Also the publication caution quoted in §0.

**`verification of physics olympiad solutions/the structure of physics olympiad solutions.md`** (in full; July 2025)
* "they aren't quite math problems … could one just have a step of turning it into a clear (math) problem, and then have a solution to the clear math problem?"
* "at least existing solutions from the wild often do not look like that. there's more of a dance with many clear setups, with some relations to the physical problem of interest"
* "there's also the issue of contradictions being provable from stuff..."
* "how would we verify a suggested way to turn the problem into a clear math problem?"
* "we shouldn't be happy with restatements that make some part of the solution go away"
* "hypothesis: there's a local setting up of a clear thing"

**`… — general principles.md`**
* In math "we created a language in which formal proofs can be written. there is a way to turn informal proofs into formal proofs, but it is actually fairly complicated".
* Existing solutions may fail as proper solutions because they omit or misstate things.
* "it obviously makes sense to actually look at physics olympiad solutions, to try to identify some nice thing that is shadowed in them".

**`…/example solutions/ipho 2012 T1-A.md`**
* Only an image and an empty "# solution" header. It is a stub.

### 1.8 Physics olympiad practice and the philosophy of physics models

**`introspection/introspect-solving physics olympiad problems/introspect-solving eupho 2025-T1.md`** (September 2025; the copy in `examining myself…` is byte-identical)

A real-time transcript of solving a reflection/illuminance problem. Features relevant to us:
* **Choosing idealizations by reading the text and figure:** mirror vs diffuse reflection ("we just learn from it that the leg is really reflecting not diffuse"), "do we say the sun is infinitely far away? do we say it is a point?", "there's defo no modeling the cursed hair inside".
* **Invariance as a key step:** "ok maybe it is independent of the angle"; "the angle from horizontal turns out not to matter for the answer. i suspected this but then i messed up a calculation and spent a while thinking that it does matter".
* **Equivalence of modelling choices:** "a lot of these choices are equivalent for our purposes, so basically it doesn't matter".
* **The intended model is partly conventional:** "is the finger horizontal? … ok i peeked at the solution and it seems to assume that's not the case. nice i guess. sad if you're at the competition?"
* **Model-building as question-asking:** "it's like i'm improving a model of the situation by figuring out some stuff". Propositions come as answers to prior questions. "when calculating some quantities, i guess i'm tracking which quantities are already given and which are not given … constantly trying to expand the set of variables which are known".

**`…/what do i want to get from … solving physics olympiad problems.md`**
* One goal: "understanding what it is for a piece of text to be a solution to a physics olympiad problem … since gödel etc, we could code a verifier for formal math olympiad problem solutions. what are the obstacles to doing the same thing for physics problems? could we imagine coding such a thing at least in restricted cases?"

**`philosophy/philosophy of science/the domain of applicability of a scientific mode(l).md`** (in full)
* The flat-earth example: derive 100 m flat, 99.9 m spherical, "then we use 100 = 99.9 in some algebraic manipulations to do some nonsense. this is clearly bad. how come we usually avoid this sort of catastrophic reasoning? i don't think any nice 'formal criterion' is going to be right?"
* Option: "pick some precise mathematical model, and then stick to that". Problem: "often, one wants multiple models. consider the eupho disk problem". Also "kinetic theory of gases — you can probably derive a contradiction from the Stosszahlansatz and newtonian mechanics?"
* "the vibe of physics is imo more like: oh here's a way of talking that works. these bad things? don't do them, silly!"

**`philosophy/epistemology/probabilities/assigning probabilities in a conception of the world you know to be inadequate.md`**: important for contexts.
* "One option would be to treat every sentence as implicitly ANDing the entire background framework always, but this leads to just assigning probability 0 to everything — in particular, for each sentence, to both it and to its 'naive negation' in the language".
* "we should be careful about proofs by contradiction for the naive negation of a statement, because they might start from assuming the negation of a statement but really involve subverting the background framework to reach a contradiction, and there's a chance such an argument could equally be provided starting from the statement itself. maybe this is some argument in favor of trusting 'constructive' reasoning more than 'non-constructive' reasoning, at least in messy domains".
* He also argues for softer-than-Bayes updating in messy domains.
* He cites the "bio olympiad maxim" that all universally quantified positive statements are strictly false once terms are made precise. Elsewhere: "it might be that all universally quantified statements are false, but the ones that are nearly true are worth their weight in gold" (`advent…/2f`).

**`philosophy of physics/a scientific theory touching reality patch-wise.md`**
* "only a patch of your understanding becomes active … the bipartite graph connecting situations to the concepts they invoke is sparse". Refactoring is patch-local. Patch selection is not a separate classifier step.

**`physics/symmetry.md`**
* "in olympiad problems, symmetry of problem is used to imply symmetry of solution, but of course really it only implies symmetry of the set of solutions. symmetry of a single solution is implied if we make the further assumption that there is a unique solution."

Project relevance: a ready-made example of a widely used physics inference rule that is valid only under a side condition (uniqueness). It is a test case for guard learning.

**`philosophy of science/scientific theories are not for generating or predicting arbitrary data.md`, `some disanalogies between solomonoff induction and science.md`, `science predicts only very particularly.md`, `our science is very human software.md`**
* "A scientific theory is much less like a program that prints (or predicts) an observation sequence than it is like a theory in the sense used in logic". It is a system of talking with questions and relations between answers.
* Theories are incomplete without tacit skill. Science "predicts only very particular things, in very particular contexts", and we build contexts in which we can predict.
* "Imo the bayesian conception basically completely fails to model gaining scientific understanding."

**`philosophy of physics/a mathematical hypothesis that would imply there is not much of an underdetermination issue…`**
* A conjecture: most small circuits are unique up to local function-preserving modifications. The philosophical version: "all reasonable true theories are pretty much the same … 'two theories will need to make sense to each other'".

### 1.9 Learning and induction (`ai/learning/`, `philosophy/prediction/`, `philosophy/epistemology/induction/`)

**`ai/learning/solomonoff induction/solomonoff axiom induction.md`** (around May 2026; the most directly on-target learning note)
* Given labelled true and false mathematical statements, weight axiom systems that prove the trues and not their negations by complexity (variants: weight also by coverage, penalize proof length).
* This yields "p(true/false/independent)", a three-valued output. Alternatively, do function induction with accept/reject TMs (non-halting gives the third value).
* **His equivalence:** with consistent assigners only, and using an axiom schema "T(⌜φ⌝) = accept ⟹ φ" (decidable membership), "solomonoff function induction with consistent assigners only is equivalent to the version of solomonoff axiom induction that requires proofs".
* He then worries that arbitrary decidable axiom sets are too permissive: "i wonder what the restrictions are on how one ought to specify which things are allowed to be substituted in … maybe we just say we have to have second-order substitution schemas of a specific kind … seems kinda hard to reason about?"
* "other ideas for how to fix axiom induction":
  * "we should be fine with only generating a very small subset of observations";
  * "we should be fine with making some mistakes";
  * "we should have a metric on values" for numerical answers.

Project relevance:
* His equivalence is essentially Craig's trick [mem]. That is precisely why unrestricted axiom induction gives no *step-level* structure.
* The answer to his "restrictions" question is the length-bounded elementary formal systems and pattern-language schemas of L1 (Shinohara/Wright). These are learnable from positive data and are naturally step-checkable.
* His three "fixes" anticipate partial coverage, noise tolerance and approximate physics answers.

**`ai/learning/solomonoff induction/solomonoff function induction.md`** (and its PDF, September 2025)
* Theorem-1-type dominance holds against predictors that don't see past data. It *fails* for predictors that see the revealed data under adversarial reveal orders. A version with regret ≤ C_Δ + C_P holds when the reveal distribution Δ is simple.
* Added later: "solomonoff function induction doesn't work that well when there is a simple property distinguishing test from train — in that case we can just have an if statement checking the property followed by output 0 if it is in the test setting … this sorta makes me sad about various concrete proposals for the riemann hypothesis proof problem, because there will be a simple property distinguishing test from train if you want to do task decomposition".

**`philosophy/prediction/solomonoff function induction gives at least some const probability to bad behavior on ood inputs.md`**
* "Proposition. suppose there is some simple property such that no input with that property showed up in training. then you have at least corresponding const probability of just outputting 0 on all inputs with that property", with weight loss of about 2^{−C(P)}.

**`philosophy/prediction/a predictive model assigning truth-values to sentences.md`**
* "there is no hypothesis which assigns 1 to each provable statement and 0 to each disprovable statement … equivalent to the unsolvability of the consistent guessing problem".
* "if you make a data set by giving 1000 formal math statements humans have proved the label 1 and 1000 disproven statements the label 0 and then find the shortest program with this input-output behavior, it seems pretty likely that this program will be assigning 1 to all provables and 0 to all disprovables (and not halting on some independents)".
* He also quotes the ELK report's *worst-case* standard as the bar a solution should meet.

**`some examples where function solomonoff generalizes well ood.md`, `playing t-complexity against k-complexity.md`, `a tension in trying to get good generalization from easy cases.md`, `does solomonoff generalize well out of distribution?.md`**
* Optimism for the proof-search case. Labels from 1-hour human proving might generalize beyond the human time bound because the simplest consistent program has higher t-complexity but lower K-complexity.
* Tension: "your ideal (bounded) solomonoff-style predictor will learn to do whatever is the simplest-easiest thing that works on the cases it is presented … but doing that thing probably doesn't work on the hard cases".
* Hypothesis: "for solomonoff, ood generalization is a thing, but easy-to-hard generalization is not … there is 'fake ood generalization', which is where you've already seen many 'ood generalizations' of the same kind".

**`which input-output pairs does solomonoff function induction need to see to generalize correctly?.md`**
* "you can always learn f by showing the function value on K(f) inputs (like, if you choose well)". The proof is a halving argument on the posterior of f.

**`ai/learning/circuit solomonoff/*.md`**
* "Occam circuit learning" (guess with the simplest consistent circuit) is PAC in-distribution.
* He asks whether the online mistake bound is O(C(f)) for arbitrary or "generic" orders. He has a "physicist's proof" and a counterexample with a bizarre circuit language and an adversarial order.
* He proves (sketch) that expected regret and circuit complexity are polynomially related under i.i.d. inputs.

**`ai/learning/solomonoff induction/solomonoff induction sequence meta.md`**
* A planned sequence of "ideal inductions": functional, **positive example induction**, axiom induction, **property induction**, circuit induction, time-bounded universal induction.

**`philosophy/prediction/scientific reports…/could one do science with solomonoff on text?.md`, `ai/learning/good paper generator given math oracle?.md`**
* He computes the positive-example posterior for a property G from samples E ⊆ G: "The likelihood which the actual G gets is then |G|^{−|E|}, whereas the likelihood of any other G′ containing all of E is |G′|^{−|E|}". This is the size principle.
* Negative examples are the problem for the classifier route: "the obvious question here is how one is supposed to get negative examples. tentatively: the generative model case makes more sense".

**`philosophy/prediction/solomonoff induction is weird.md`, `one can predict right without having "the correct structure".md`, `philosophy/epistemology/induction/grue-bleen and UTMs.md`, `…/the complexity of 'now'.md`, `philosophy/epistemology/priors/the right relational prior.md`**
* Solomonoff can be "trolled" by simple universes containing broadcasting agents.
* Grue has three answers: language-relative complexity; "a meta-pattern that lets us point at good patterns"; mechanistic understanding.
* An exception for "the next moment" must cost more than O(1) bits.
* Rather than seek the right universal prior, "understand how a human gets something like a prior in practice".

**`ai/learning/a learning theory.md`**
* Gradient descent finds structures that have incremental paths into them. "you might find the right definition in mathematics by looking for a thing satisfying certain constraints … and many such definitions will not be findable by doing sth like gradient descent on definitions".

### 1.10 DLK (consistency-based truth probing) (`ai/DLK/`)

* `DLK notes.md` contains his framework tables for CCS. Their main entries:
  * negation coherence, plausibility(¬Q) = 1 − plausibility(Q);
  * confidence, min(p(Q), p(¬Q)) = 0;
  * a proposed modus-ponens constraint, "think of modus ponens as [(neg P) or (neg (P->Q)) or Q]".
  
  He also suggests that "a superhuman model's beliefs will presumably be more consistent", so that coherence could discriminate true beliefs from modelled human beliefs.
* `is CCS getting at the truth?.md` lists alternative coherent targets, among them "what's true within the story currently presented", what the writer believes, and "how well the sentence hangs together".
* `main DLK framework open questions.md`: "can we think about this in model-theoretic terms? i.e. ML model has a model attached to it?" There is also the story experiment "Sun is blue": truth versus truth-in-context.

Project relevance: he has first-hand experience that coherence losses admit many coherent non-truth solutions. On the CCS critique see L8. He also met the context problem empirically ("truth in the story").

### 1.11 Meta-level views (Advent of thought 2024, metaphilosophy, advice)

* `1f thinking can only be infinitesimally understood.md`: "understanding how thinking works is not a problem to be solved". There is "no 'grand theorem/formula of mathematics'". Progress is still substantive.
* `3f …` (item 5.1): "(almost all) clear human mathematical statements and clear mathematical proofs … have formal counterparts in ZFC — there's a very real 'near-isomorphism' of an important thing in human mathematical (thinking-)activities with a nice formal thing … there are very many nice things shadowed in thinking".
* `99n one shouldn't conceive of development as convergence to a point.md`, together with 15f and 16: he distrusts limit and convergence framings.
* `advice…/annoying things about academic fields.md`:
  * "most papers/talks don't explain how the proofs/definitions/claims were invented/discovered. it would be very helpful for papers/talks to explain that!"
  * For philosophy, he would trade some "secured against all objections" for more "substantive".
  * For physics: "careless".
* `philosophy plans/a list of paper ideas.md`:
  * "just coming up with any concrete version of quine's holism that isn't catastrophically bad. it would be nice for language to latch on to the world not just along the boundary, to be changeable in small chunks";
  * "better understanding obstacles to a full formalization of scientific or ethical reasoning … perhaps this needn't include a specification of the reasoning process, just a specification of the structure in which this reasoning occurs".

### 1.12 Top-level question lists

* `questions.md` (2025): "so why can't all questions be asked precisely? … maybe this is sort of kind of mathematical after loading some implicit context? like we have a 'formal system' in which these questions fit"; "why must any precise question be a mathematical question?"
* `philosophy/questions.md`: "instead of bayesian updating with full world-models, we update on patterns. write down a formal model of that. does logical induction or infrabayesianism help one make sense of that stuff?"
* `philosophy/questions/how are the natural numbers pinned down?.md`: "is there a way they are the 'lowest-complexity-structure' which satisfy some axioms??"
* `uncategorized ideas.md`:
  * "maybe minds are sort of good at arguing for x, but not naturally good at figuring out whether x or not x in a non-partisan, fair way. write about methods for turning partisan reasoning into non-partisan reasoning (e.g. debate+evaluation, including internal debate)";
  * "mathematics can see far because each thing super rigorous, physics needs new model each time, can't see very far in model because 99% confidence breaks down after few steps? idk maybe doesn't actually capture".
* `ai/alignment general/…/some good questions in conceptual alignment.md`, item 4: "Can one characterize the problems such that we already understand how to verify solutions to them? Is it basically just math …? … can we build a formal system in which one can write physics olympiad problem solutions such that answers become much easier to verify than to generate?"
* `ai/research from hypercomputer/what are the approaches to getting novel research papers given a lot of compute?.md`: "something with verification: you could try to just use solomonoff on human labels to get a verifier; you can do some sort of debate". He adds that he doesn't "think we actually have anything here that works". His frame of a program that would work given unbounded compute matches the request's "fine with a huge amount of compute".

---

## 2. Synthesis

### 2.1 What "principled justification" means to him, and what he finds unsatisfying

**Positive core.** Pieced together from the notes, a principled justification is:
* **(J1)** an object living in a *precisely specified structure*, such that whether it justifies its conclusion is checkable. This is the formal-proof paradigm, and it explicitly does *not* need to specify the reasoning process that found it (`formalizing philosophy.pdf`; paper-ideas list).
* **(J2)** checkable *in a way that survives an untrusted or adversarial arguer*. This is his motivating use case ("lost all the safety"; "verifiers getting hacked"; "training against a verifier … fucks everything").
* **(J3)** compositional and piecemeal: individual steps and sentences are assessable "in the context of his language/model", and failures localize to parts ("go back to what caused" the contradiction).
* **(J4)** context-relative in the right way: claims are "true enough for the context at hand", and contexts are "local setting[s] up of a clear thing".
* **(J5)** not dependent on the reasoner's self-endorsement (the Löbian notes): justification cannot bottom out in "I would come to accept it".

**What he finds unsatisfying.**
* Verificationism: claims cannot be translated into standalone observation reports.
* Undifferentiated holism, and evaluation from an external standpoint such as Solomonoff.
* "just check the claims are true", because almost all claims are literally false.
* "turn it into a math problem", because that offloads the work. A restatement must not "make some part of the solution go away", and verifying the restatement is itself the open problem.
* Bayesian or Solomonoff updating as a model of scientific understanding.
* "string game" deflations of accepting a rule.
* Intuitions taken as reasons from the inside (`rough thinking/on intuitions.md`: "x being an 'intuition' isn't really a reason to think x").
* Any claim to a finished, definitive theory.

**Where he is undecided.**
* Whether a "nice formal criterion" for domain-of-applicability exists (he leans no).
* Whether analogical (model-) reasoning can have a robust verifier (he leans no).
* Whether coherence-only existence is "real" existence (he knows about non-standard models).

### 2.2 His views, by topic

**Meaning.** He is pluralist. He accepts model-theoretic semantics (Montague) as one good theory, but his own interest is in "structures in your head" that support operations, especially inferences ("compositional inference warranting"). Concepts are questions with criteria and supported activities, not classifiers.
* Meanings are open and moving, and are refined to fit purposes (sandwich debate, conceptual revision as coordinate descent).
* Inferential role is central but not exhaustive. There is also the "hooking of a model onto the world", which he regards as unexplained.
* C-models (conceptions, contexts, analogies) are reasoning tools that may lack L-models. He treats "aboutness" as the same in math and physics (`math is a mere string game iff everything is.md`).
* He is drawn to categoricity: rules plus background pin down structures, and he proposes "smallest categoricity result" as a complexity measure.

**Verification versus generation.** Verification is easier where the verifier can demand a certificate, i.e. φ(x) checkable. It is hard for "only x" claims and for soft domains. Physics olympiads are a good intermediate case: answers are values of variables, and there is no only-x issue.

**Induction.** He is fluent in, and fond of, ideal inductions, and he is also their sharpest critic:
* Solomonoff is "weird";
* trollable;
* fails when test is simply distinguishable from train;
* fails at easy-to-hard generalization;
* learns teachers' mistakes.

He wants "other ideal inductions … closer to human thinking in terms of their type signature" (`some ideal inductions.md`): induction from similar cases and reference classes, property induction, positive-example induction, and a prior "defined in terms of existing understanding".

**Contexts and idealization.** Many frames, often irreconcilable, each a "machine". Physics reasoning uses several models at once. Catastrophe (100 = 99.9) is avoided by know-how, not by a formal rule. Inconsistent backgrounds threaten explosion and make reductio suspect. Formalizing everything as "AND the framework" trivializes.

**Structure of physics olympiad solutions.** A "dance" of many clear setups, each locally formal, with relations to the physical problem. Model-building is question-driven. Invariance and equivalence of modelling choices carry real weight. The *intended* idealization is partly conventional and inferred from text and figures. Symmetry and uniqueness are a typical guarded inference. Formalization should be by a new language into which solutions can be reconstructed, not by translation.

### 2.3 Open questions in the notes that the project could answer or partly answer

| # | Question (paraphrased, with source) | What we can offer |
|---|---|---|
| Q1 | "check that a claim is true in the context at hand … wtf is that?" (`verification from truth.md`) | A precise semantics: context-indexed judgments; export rules with certificates; supervaluational truth over admissible completions of the intended model (L7). |
| Q2 | "how would we verify a suggested way to turn the problem into a clear math problem?" (`the structure of physics olympiad solutions.md`) | Verify the *bridge* (the reading plus idealization) separately from the in-chunk math. The checkable part is invariance or robustness across admissible readings, plus world or simulation feedback. |
| Q3 | "can we build a formal system in which one can write physics olympiad problem solutions such that answers become much easier to verify than to generate?" (conceptual alignment questions) | Chunks + bridges + error propagation + coherence checks (H6), with a soundness theorem relative to certified bridges. |
| Q4 | "how come mathematicians ended up with such a nice notion of proof? … how did it come to be there?" | H5's latent-formalization model plus his own robust-core hypothesis (§1.6). A theorem that coherence-pruned, conservative rule learning on practice converges to a calculus in which practice's accepted steps are short derivations. |
| Q5 | "how does one become able to tell whether something is a good proof? a valid reasoning step? how does one start to reason validly?" (`beating solomonoff…`) | The core learning theorem: positive data + coherence + conservative acceptance ⇒ a sound and eventually complete step checker. |
| Q6 | "is a generalization of the completeness thm available that justifies [coherent ⇔ about something] more broadly?" | Coherence–model correspondences for learned bilateral rule systems; probabilistic versions; the non-standard caveat made precise (H3/H4). |
| Q7 | Solomonoff axiom induction: what restrictions on schemas? how to fix it (partial coverage, mistakes, metrics)? | Restricted schema classes (EFS, patterns) with finite elasticity; a noise-tolerant MDL variant; metric losses for numerical answers. |
| Q8 | Is online Occam (simplest-consistent) circuit learning O(C(f))-mistake for generic orders? | In general no; his own counterexample generalizes. Mixture or halving achieves log(1/prior) for *all* orders [mem]. For soundness use unanimity or KWIK (L2), where the price is abstentions, not mistakes. |
| Q9 | Does the steeper-simplicity-prior proposal have a pathology? Can it be proved? | T5 below. |
| Q10 | Which inputs must function induction see to generalize correctly? (K(f) teaching bound) | Teaching sets for rule calculi: curated worked examples, i.e. textbooks, as near-optimal teaching sets; contrast with the abstention cost for *soundness*. |
| Q11 | "how come we usually avoid this sort of catastrophic reasoning [100 = 99.9]?" | Context-tagged judgments forbid cross-context substitution without an export certificate. Errors are tracked as intervals, so "100 = 99.9" becomes "100 ∈ 99.9 ± 0.2", which does not support exact algebra. |
| Q12 | "can we say something about [model-thinking] being trustworthy? … could we have some sort of solomonoff-like result here?" | Reliability only relative to a class with a simplicity prior, and only average-case. Worst-case trust requires a certificate (a bridge proof). This sharpens his pessimism. |
| Q13 | "instead of bayesian updating with full world-models, we update on patterns. write down a formal model of that" | Learned inference rules *are* patterns. Coherence-pruned rule learning is updating on patterns without a full world model. |
| Q14 | "methods for turning partisan reasoning into non-partisan reasoning (debate+evaluation)" | The coherence loss literally penalizes having good arguments for both P and ¬P. A debate between arguers for P and ¬P under a shared checker is the natural protocol. |
| Q15 | "what is the core inference engine … how is it learned? … type signature of a [per-concept] component" (`cheap inferences.md`) | Rule sets indexed by concept or vocabulary, composed per context: rules = schemas over the concepts they mention; the context selects a fragment K_Γ. |
| Q16 | "just coming up with any concrete version of quine's holism that isn't catastrophically bad … changeable in small chunks" | Contradiction → negative bag → minimal blame set is exactly piecemeal revision with sparse activation. |
| Q17 | "how are the natural numbers pinned down? lowest-complexity structure?" | Coherence cannot pin them down (non-standard models); simplicity and world feedback (computation on Π₁/Σ₁ facts) do part of the work (H4). |
| Q18 | "your eventual probability in any löb sentence … will be 0?" (defeasible Gödel) | Possibly testable in a logical-inductor-style learner; at least a constraint on reflective rules. |
| Q19 | "what sort of loss function would give such a [lemma/scene] structure?" (`how should one structure a proof?.md`) | MDL over proofs with lemma reuse (library learning). Lemma = compressed repeated steps, matching his own "concepts … compress certain repeating steps in proofs". |
| Q20 | "there could be an interesting field of study about the robustness of such notion-sharing processes" (integral note) | Stability of identification: how many taught rules, against how much background, pin down a notion categorically, and how robust this is to teacher noise. |

### 2.4 Vocabulary and framings

**Use** (his terms, so the write-up meets him where he is):
* "inference rules";
* "compositional inference warranting";
* "cheap inference engine" / cheap vs expensive inferences;
* "conception";
* "C-model" (sparingly, given the disendorsement header);
* "likening";
* "bridging laws";
* "hooking of a model onto the world";
* "a local setting up of a clear thing";
* "a dance with many clear setups";
* "true (enough) in the context at hand";
* "domain of applicability";
* "patch";
* "frames";
* "nice things shadowed in thinking" / "near-isomorphism";
* "solomonoff function induction", "axiom induction", "positive example induction", "property induction";
* "ideal induction";
* "the fundamental theorem of the notion" / TFAE;
* "verification vs generation", "x and only x";
* "untrusted prover";
* "infinite endeavor".

He used "eternalism" himself in the request.

**Explain, rather than assume.** The inferentialist and bilateralist literature (Brandom, Restall, Rumfitt, Prawitz, Dummett) and Carnap's categoricity problem. His notes mention Brandom only once (a link in `research/conceptual abstractions.md`) and Dummett only as an author of a reading. He will read them as useful only if they solve one of his problems: Q5, Q6 or Q16.

**Avoid or hedge:**
* "*The* theory of meaning"; "meaning = inferential role" without qualification. Present it as one aspect of meaning, with the hooking-to-world and C-model aspects left open.
* "Just a string game" deflations.
* "Converges to the truth" or "in the limit, intelligence…". He distrusts limit framings, so state finite-sample and anytime results where possible.
* "Bayesian updating is how science works".
* "World model predicts raw data". He insists science predicts "very particular" things, so frame world feedback as answers to particular questions (truth values or measured quantities), as the request already does.
* Excessive security at the expense of substance. He wants substantive claims, and wants to know how the ideas were found. The write-up should include the discovery story.

### 2.5 The orchestrator's hypotheses through the lens of the notes

**H1 (worst-case soundness): likely the most compelling to him.** It is the formal shadow of his central worry ("lost all the safety"; hacked verifiers; ELK's worst-case standard). He has the mechanism in his own Solomonoff notes: a simple property distinguishes test from train, so exception hypotheses keep constant weight. Refinements suggested by the notes:
* (a) His constant-probability proposition, read correctly, gives *soundness with abstention* under conservative acceptance, not unsoundness. See T2: the exception hypotheses ("if P then reject") cause abstentions; the dangerous ones ("if P then accept") are exactly those coherence can kill.
* (b) The validity relation must be *partial* (accept/reject/abstain). He already derived the three-valuedness from the consistent-guessing obstruction and from non-halting labelers. KWIK's ⊥ is natural to him.
* (c) Present Bayesian-conservative acceptance as a tool, not as an epistemology.

**H2 (Gold; remedies): compelling, and partly his own.**
* Remedy 2 (coherence as negative data) matches his categoricity and contradiction-resolution notes almost verbatim.
* For Remedy 1, his own variant is the *size principle* (his |G|^{−|E|} computation) and "positive example induction". L1 notes that the size principle requires strong sampling, which goal-directed human step choice violates. That is worth stating to him as a precise reason his computation may not transfer to proofs.
* A **third remedy appears in his notes and is missing from the brief**: the steeper simplicity coefficient, which separates intended rules from systematic human error (T5).

**H3 (Carnap's categoricity ↔ Gold): interesting to him, but the framing is foreign.**
* What will resonate is that his "fine notion of truth … assigns 0/1 to all sentences and is coherent under proving", together with his CCS losses (negation coherence plus confidence), *is* the bilateral fix in his own vocabulary.
* His question Q6 is a better entry point than Restall.
* Expect pushback on any claim that bilateral rules "fix meaning". He will ask what fixes the *hooking*.

**H4 (Post-completeness; arithmetic): compelling, and he already knows the non-standard caveat (3f, fn. 5).**
* His optimism that the shortest labeler of human-proved and human-refuted sentences is proof search is in tension with his own test/train-distinguishability observation. Resolving that tension precisely would interest him.
* Probable resolution: proof search is the MAP hypothesis, but OOD exception hypotheses keep non-negligible weight. A *step checker* with conservative acceptance is the robust object, not a theorem labeler.
* World feedback via computation, which refutes false Π₁ claims, fits his "something with verification" programme.

**H5 (informal math as latent formalization): compelling, provided it is not oversold.** It matches:
* "a language in which formal proofs can be written";
* "near-isomorphism";
* "how did it come to be there?";
* his robust-core story for pre-1900 functions;
* ZFC as coherent extrapolation of inconsistent intuitions.

Refinements:
* (a) He stresses that the hard historical step was identifying *which properties matter*. MDL over calculi given a reading map does not explain that.
* (b) "Separation is the minimal repair" is too quick. His Russell note prefers indefinite extensibility and the iterative conception, and minimal repairs are not unique (stratified comprehension, NF, is an incomparable repair [mem]). This matches his "alien math is orthogonal" view: different repairs yield different unfoldings.
* (c) Present this as "a nice thing shadowed in practice", not as an account of what Frege, Hilbert and Zermelo "really did".

**H6 (contexts as chunks): compelling in outline. It is the part he has thought hardest about, and where he is most sceptical of formal criteria.**
* Contexts = C-models.
* Export rules = bridging laws / hooking.
* "Local setting up of a clear thing" = chunk.

Refinements:
* (a) **Reductio inside a technically inconsistent context is not automatically legitimate.** His warning about proofs by contradiction that "subvert the background framework" applies. If the idealized context Γ (e.g. "air pressure = 0" plus imported background) is itself inconsistent, then ⊥ derived under a further supposition A is no evidence against A. A legitimate reductio must use A essentially and use only Γ-licensed moves, a relevance-style condition. Alternatively Γ's import filter must be shown consistent, for example by exhibiting a model. This is his "constructive reasoning in messy domains" point.
* (b) For olympiads, the target is the intended model (his "peeked at the solution" episode; L7).
* (c) Invariance under admissible choices is a first-class export certificate in his practice (the angle-independence episode). Robustness should come before refinement towers in the presentation.
* (d) His symmetry/uniqueness note is a canonical guarded rule.
* (e) He doubts "any nice formal criterion" exists. Present our criterion as sufficient conditions with certificates, not as a definition of "true in the context at hand".

**H7 (rule-following / non-identifiability): he will find this natural. His answer set differs from the brief's.**
* His grue note gives (i) language-relative complexity, (ii) "meta-patterns on patterns", (iii) mechanism. His frames and purposes notes add (iv) the purposes or activities a concept supports.
* His "alien math is orthogonal" view and his underdetermination conjecture ("two theories will need to make sense to each other") suggest the right success notion: **identification up to translation / mutual interpretability**, plus an honest acknowledgment that the residual choice is path-dependent and possibly value-laden.

**Least compelling to him, overall.** Any statement of the result as *the* account of meaning or justification. And any reliance on "community practice" as a magic fixer. He thinks humans learn what a teacher *should* say, not what the community says ("should the person who taught me … consider it a chair?").

---

## 3. Theorem candidates and design ideas suggested by the notes

**T1 (Philosophical completeness for learned bilateral calculi; answers Q6).**
* For a learned rule set R over a language with assertion and denial, the R-coherent maximal positions correspond exactly to valuations of a semantics determined by R, when R includes bilateral negation rules.
* Quantitative version: probability assignments satisfying R-coherence constraints (his CCS-style losses, including the modus-ponens constraint) are exactly the mixtures of R-models.
* Plus a precise "non-standard caveat" theorem: in arithmetic, coherent extensions include ¬Con, so existence is only in his "proof of G in a non-standard model" sense.

**T2 (Exception-hypothesis asymmetry; makes his OOD proposition into a soundness theorem).** Let V̂ be δ-conservative acceptance under a Solomonoff/MDL posterior over step-checkers. On a simple region P with no training data:
* exception hypotheses of the form "if P then reject" cost about 2^{−C(P)} and cause at most a constant-rate **abstention**, not false acceptance;
* hypotheses "if P then accept" cause false acceptance only if they hold more than 1−δ of the posterior.
* Every "accept-on-P" exception that over-accepts can be *refuted by coherence*, since accepting all of P yields ⊥ from accepted premises. "Reject-on-P" exceptions can only be refuted by *positive* data in P.

The slogan: **coherence removes over-acceptance; positive data removes over-rejection.** This is H2's Gold point in his own formalism.

**T3 (Axiom induction with restricted schemas; answers Q7).**
* His Craig-style equivalence shows that unrestricted axiom induction collapses to consistent function induction, which is why step structure is lost.
* With schema classes of bounded elasticity (length-bounded EFS, pattern schemas), axiom/rule induction from positive data is identifiable in the limit, and its accepted steps are locally checkable.
* With a noise-tolerant MDL objective and a metric loss on numerical outputs, it implements his three "fixes".

**T4 (Teaching versus soundness; answers Q10 and refines Q8).**
* His K(f) teaching bound transfers to rule calculi: K(R*) well-chosen worked examples make R* the top hypothesis.
* But *sound* conservative acceptance can require far more: KWIK bound |H|−1 for enumeration (L2).
* Separation theorem: the gap between "top hypothesis correct" and "unanimity on all steps" is exactly what coherence and adversarial step queries must close.
* This also answers his circuit-occam question: Occam can incur many mistakes under adversarial orders; mixtures do not.

**T5 (Normativity from imitation; answers Q9, his explicit open question).** Function induction with loss λ·K(h) + Σ NLL, per-input private randomness, and human steps generated as "R* + systematic error E + noise".
* Claim: for λ in an explicit window, depending on the description length of E relative to its frequency, the MAP hypothesis is R* + noise, not R* ∪ E. Errors are learned exactly when they are cheap to describe relative to how often they occur.
* This is the condition under which systematic fallacies (the freshman's dream) are learned versus rejected.
* Combined with coherence (T2), fallacies that are cheap to describe yet incoherent are removed anyway.

**T6 (Randomized-commitment justification; generalizes his induction-in-math result).** A defeasible rule whose reliability is guaranteed by the reasoner's own randomization, worst-case over the target fixed in advance. Instances: his random-stopping induction, Schwartz–Zippel identity checks, randomized limiting-case checks in physics.
* This is a clean, non-proof form of "principled justification": guaranteed error probability δ against every non-adaptive adversary.
* Note the failure against adaptive adversaries, who can choose P after seeing the random seed. That is a sharp boundary for H1.

**T7 (Reductio hygiene in inconsistent contexts; refines H6 via his warning).**
* Define "A is refuted in context Γ" only when Γ ⊬ ⊥ is certified (e.g. by a model of the imported fragment K_Γ) and the derivation of ⊥ uses A.
* Show that without the first condition, the coherence loss assigns penalties symmetrically to A and ¬A: his "could equally be provided starting from the statement itself".

**T8 (Robustness as export certificate; formalizes his olympiad practice).**
* An exported answer is justified iff it is invariant, to the stated precision, across the admissible completions of the intended model.
* Learning the admissible class from (problem, official-solution) pairs is the residual imitation task.

**T9 (Biclique concept invention; formalizes his concept-invention note).**
* Introducing X for an n×m biclique of accepted rules saves (nm − n − m) rule-lengths.
* Under MDL the learner invents predicates exactly at such bicliques, preferring X with short proofs of A_i ⟹ X and X ⟹ B_j, which is his "easy to work with" criterion.

**T10 (Löbian constraint on self-trusting learners).**
* A rule learner that is allowed to adopt "if V̂ accepts φ then φ" as a rule, and that can represent V̂, derives ⊥ (his `reasoning system self.md` argument).
* Hence reflection must be stratified or probabilistic.
* Conjecture to test, from his defeasible-Gödel note: a coherence-trained probabilistic learner drives credence in its own Löb sentences to 0.

**Design ideas, short list:**
* Make the checker *interactive*. When V̂ abstains, the prover must expand the step into smaller steps. This is his "ask them to explain/justify/derive those [primitives]" and gives completeness relative to the base calculus.
* Use the error intervals of the "100 = 99.9" note as the type discipline for exports: no exact equational reasoning across contexts.
* Use his symmetry/uniqueness rule and the eupho illuminance problem as physics test cases. The latter has a clean invariance step.
* Report how each idea was found. He explicitly wants this.

---

## 4. Corrections and refinements to the brief

1. **H6's "deriving ⊥ inside a hypothetical context is legitimate (reductio)" needs a hygiene condition.** If the context's imported fragment is itself inconsistent (the user's own worry: "contradictions being provable from stuff"; "proofs by contradiction … subverting the background framework"), ⊥ under A is not evidence against A. Require a consistency certificate for K_Γ and essential use of A (T7).
2. **H5's "Separation is the minimal repair" overstates uniqueness.** The user's own Russell note prefers indefinite extensibility and the iterative conception. Incomparable repairs exist, e.g. stratified comprehension (NF) [mem]. Minimal repair is not unique, and which repair is chosen is part of the H7 non-identifiability.
3. **H2 is missing a third remedy present in the user's notes:** the steeper simplicity coefficient for separating intended rules from systematic error (T5). Also, the size principle (the user's |G|^{−|E|} computation) requires strong sampling, and human proofs are goal-directed (L1). Say this to the user explicitly, since it is his computation.
4. **H1 should be connected to the user's own result.** "Solomonoff function induction … const probability of bad behavior on OOD inputs" is the H1 mechanism. Under conservative acceptance it becomes abstention, not unsoundness (T2). This connection is likely to land.
5. **H3: lead with the user's question.** "Is a generalization of the completeness thm available…?" plus his CCS losses work better than Restall. And note the user already knows the non-standard-model caveat.
6. **H7's three answers should be extended.** Add "purposes/activities supported" and "meta-patterns", and use identification *up to translation/interpretability* as the success notion (the user's underdetermination conjecture).
7. **Framing.**
   * "Under an inferentialist picture, learning inference rules ≈ learning meanings" is the user's own rough phrasing, but his notes are explicitly pluralist about meaning. The write-up should claim only the inferential-role aspect, and flag the hooking-to-world and C-model aspects as not captured.
   * The notes also suggest leading with *verification/justification*, not with building a reasoner. His motivating use is checking untrusted work, and in a 2024 draft he calls publishing insightful AI-theorem-prover research "omnicidal".
8. **Physics success criterion.** His notes support (with L7) making the graded target the *intended* model of the problem, not the actual world. His own "assume the finger is horizontal" episode shows that the intended idealization is partly conventional and must be read off the problem.
9. **The C-model/L-model note carries the header "text below now disendorsed probably".** Use it as vocabulary, not as his settled view.
10. **The physics-olympiad "example solutions" folder is a stub** (one image, empty "# solution"). There is no worked solution analysis to mine there. The richest physics material is the EuPhO 2025-T1 introspection and the domain-of-applicability note.
