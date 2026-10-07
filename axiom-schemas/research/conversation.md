# Conversation log

The questions Kaarel Hänni asked in the session that produced `inferential-learning/` and `axiom-schemas/`, each followed by Claude's final answer to it, verbatim.

* **Omitted:** the intermediate tool work and progress messages.
* **Where the supporting work is:**
  * The answers on Peano arithmetic were checked by separate referee runs. Their records are in `research/prior/` (`pa-answer-draft.md`, `pa-answer/`, `pa-untagged/`, `induction/`).
  * The last question led to the paper in this directory.
* **File paths** in the answers refer to the repository as it was at the time.
* **Checking.** These are chat replies, kept as they were. Before sending, answers 3, 7 and 10 were checked by separate referee runs, whose records are listed above; the others were not. The two papers are the reviewed versions.

## 1. The original request (→ inferential-learning/) (2026-10-02)

**Question:**

> i'd like to better understand the following setup:
>
> * we have a learning process that learns inference rules, that learns which inferences are valid, that learns to make valid inferences
>    * under an inferentialist picture of meaning, this is roughly the same as having a learning process that learns the meanings of terms and propositions
> * we could start this off with imitation of human inferences. for instance, obtained from a bunch of formal or informal human mathematical proofs, or from physics olympiad solutions
> * we can think of an argument considered valid as a sequence of inferences considered valid
> * we could then try to condition this learner on either coherence, ie using some loss to push away from having good arguments for P and not-P both, or from some sort of more practical success. maybe we could imagine that the learner gets occasional feedback about some truth values from the real world
>    * i'm not sure how to handle contexts here. one could go with "eternalism" where a proposition stands alone independently of context as true or false, but we probably want to allow one to set up contexts and argue in those (think about physics problems!). but then it's fine to have arguments for P and not-P both in contradictory contexts, and that's not something we want to push away from. i'm not sure how to deal with that, especially given that many reasonable contexts are technically contradictory (eg imagine a physics problem where you are told to assume that air pressure is 0 but you can prove that it actually technically isn't or whatever)
>
>
> basically i'd really like to know if anything of this sort works well, does sth cool. i'm totally fine with having sth like this that only works with a huge amount of compute, as long as it would probably in fact work if we could run it. by working, i mean that this gives rise to a good reasoner that derives lots of correct conclusions. here's are some slightly more concrete questions i have about this sort of thing, copying a goal note i wrote for myself:
> * give appropriate learning algorithm for inference rules. maybe some sort of learning from positive examples?
> * see if that + some coherence thing gets math working well. first formal then informal. and then physics
>
> can you come up with a good setup and prove something about it? eg if you get sth of this shape provably working for formal math, i think that's already cool. if you get a setup that would have worked for mathematical proofs before we knew how to formalize them, that's very cool indeed. if you produce a principled system for solving physics olympiad problems or for checking physics olympiad problem solutions, that's amazing
>
> the reason i'm asking is that i'm interested in what principled justification looks like, trying to get beyond mathematical proof. you might be able to get a better sense of why i'm interested in this from https://github.com/kaarelh/notes
>
> anyway feel free to spend a huge amount of time and effort on this investigation. be liberal with launching lots of agents. try not to stop until you have something great

**Answer:**

Your setup works, provably, in one specific shape, and the investigation pins down exactly which job each signal does. It's written up as a 274-page report (about 133 pages of main text plus proof appendices), with a Lean formalization and experiment code. Everything is pushed to `claude/sleepy-gauss-u4kem1` under `inferential-learning/`; start with `README.md` and `paper/main.pdf`.

**What each signal does:**
- **Search forces worst-case soundness.** A reasoner searches over whatever its learned checker accepts, so accuracy on human steps is worthless as a guarantee. One tonk-like rule carrying arbitrarily little probability mass makes everything derivable. What works is cautious acceptance over rule schemas: accept a step only if every hypothesis still consistent with the data accepts it. That is sound against any adaptive prover. The cost in human escalations is linear in step size when rules are cited by name, and exponential for unstructured classes.
- **Imitation identifies rules but not norms.** Least generalization over schemas recovers a calculus exactly, at coupon-collector rates, and generalizes to derivations of any size. It cannot tell a systematic human error from a rule.
- **Coherence acts as eliminative negative data.** It pins the target down exactly when the target has no coherent uniform extension. Classical propositional logic qualifies (Post-completeness), so one coherence datum fixes it; this is machine-checked. Coherence is blind among intermediate logics and only "Popperian" for arithmetic: it catches false Π₁ claims, not false Σ₁ ones. What survives everything is a precise residue of coherent alternative meanings, a formal version of Kripke's "quus". In the algebra experiment, coherence alone converged to the semantics where 1/0 = 0.
- **Carnap's categoricity problem is partly Gold's problem in disguise.** Single-conclusion inference data cannot fix the classical meanings of the connectives. Data that includes denials, plus one coherence datum, can, at least among structural meanings.

**Your three success criteria:**
- **Formal math:** yes for propositional logic, via an end-to-end theorem for a two-tier learner (audit, then assert; bold conjectures in a sandbox), with lower bounds showing each ingredient is needed. For complete decidable theories it holds only conditionally on a realizability hypothesis that isn't established. Arithmetic has sharp limits at Σ₂.
- **Before formalization:** conditionally. If the practice's hidden formalization lies in the learner's hypothesis class, a verifier that accepts only short-gap steps is sound and identifies validity as finely as practice allows, and no finer. Counterexample objects can be exponentially more informative than paradoxes. Frege → Russell → Zermelo comes out as constrained repair. But history broke that condition at its decisive steps (ε–δ, uniform convergence), and affordable soundness when the learner must invent language is the main open problem.
- **Physics:** a principled checker design, not yet a system.
  - Contexts get a semantics in which "air pressure = 0" may contradict the background without explosion.
  - Coherence is enforced only where it belongs, and exporting a conclusion from an idealized context needs a certificate.
  - The checker is sound against adversarial solvers relative to the reading of the problem and the adequacy of the physical model, and I prove those two judgments can't be eliminated.
  - "True in the context at hand" becomes "true in every admissible completion of the intended model".
  - It's illustrated on one EuPhO problem, whose setup I reconstructed from your notes rather than the official text.

**Your two side questions:**
- **Steeper simplicity penalty:** your kink intuition is proved, but only for parity teachers. Selection is then a rate threshold: rare valid rules get dropped, cheap fallacies get kept, and held-out imitation data provably prefers the error-memorizing model, so the threshold can't be tuned from data.
- **"Philosophical completeness theorem":** it holds in the generalized sense you asked for, for positions, credences and context systems. Coherence can't certify that the intended (standard) model exists. Pairwise or bounded-arity coherence constraints of the consistency-probing kind provably don't characterize coherence.

On justification beyond proof: every learning signal is one-sided, so principled justification is a set of signals that together cover every direction of error, plus an explicitly declared residue. Mathematical and physical justification then differ in the size of that residue, not in kind.

**How much to trust it:**
- **Verification:** each theory document was split among two or three referees told to refute it, so each result had one first-round referee. Round one found 4 false statements and 20 major problems, all repaired or retracted. A second round caught two more in the two-tier theorem, and a third referee confirmed those repairs.
- **Lean:** about 50 results are machine-checked in Lean 4 (about 14,600 lines, no `sorry`, standard axioms only). About a third are formalized only as special cases or weaker forms; the probabilistic and Kolmogorov-complexity results aren't formalized.
- **Experiments:** these are small symbolic illustrations, not evidence that anything scales.
- **Scope of the guarantees:** they assume the target is realizable in the hypothesis class and that data and designated contexts are truthful, and they mostly ignore computational cost.

Consistent with your notes, I built checkers, not provers, and the paper makes no recommendations for prover development. I've listed Claude as author with a note that authorship and publication are your call.

If it would help, I can also put the main results on a private web page that's easier to skim or share than the PDF.

---

## 2. Results web page (2026-10-03)

**Question:**

> yep could you put the results on a private web page?

**Answer:**

The results page is up, and it's private: (private link, omitted; the page is `inferential-learning/web/what-follows.html`)

Only you can open it until you share it from the page's Share menu.

The page covers:
- **The three success criteria**, each with a status label:
  - formal mathematics: "Yes for classical propositional logic; conditional beyond";
  - before formalization: "Conditionally";
  - physics: "A principled design with a soundness theorem, not yet a system".
- **The division-of-labour table.** For each of the six signals it shows what the signal provably fixes and the residue it leaves.
- **The theorems by area:** search, caution, imitation, coherence, the two-tier learner, informal mathematics and physics. Results that are machine-checked carry the name of their Lean declaration.
- **Your two questions from the notes:** the steeper simplicity penalty and the philosophical completeness theorem.
- **The experiments**, led by a bar chart from Experiment C. The boosted-tree checker scores AUC 0.995 on held-out human-like steps, yet the prover still proves 16 of 23 false goals at the 0.99-precision threshold. The calculus repaired with world feedback proves none.
- **How the work was checked:** the referee rounds with their fatal and major counts, the Lean axiom audit, and the code and paper reviews.
- **Justification beyond proof, the open problems, and where each file is in the repository.**

Every claim on the page comes from the paper's corrected statements, with the same caveats. The page leads with checking rather than proving, and says no strong prover was built.

The full PDF is attached to the page, so it works on its own for anyone you share it with. The "Repository folder" link only works for people who have access to `kaarelh/AI-works`.

Nothing changed in the repository. The page source is in my session scratchpad, not on the branch.

---

## 3. Peano arithmetic: what is conditional on what (2026-10-03)

**Question:**

> i'd like to better understand your proposal for formal math. let's do peano arithmetic for example. are you saying you have a result conditional on some unproven conjecture? or what is what conditional on. and then could you tell me what your proposal is and what result you have about it

**Answer:**

**Short answers**

1. **Is there an unproven conjecture?** No. The PA results are theorems about an explicitly stated model. They depend on modelling assumptions about the data, listed below, and on a search depth d that appears in the conclusion. The word "conditionally" in my summary was about RCF and Presburger-type theories, not PA.
2. **The proposal ("audit, then assert").** First-order logic is fixed. The learner works out which non-logical axioms the community uses from the axioms it cites. Before asserting anything, it searches up to size d for derivations from certified-true premises to ⊥, or to a Δ0 sentence that computes false. It traces each such derivation back to the axiom at fault and drops it. When the trace gets stuck, it drops every axiom in a minimal conflicting set. It then asserts exactly what survived.
3. **The result.** With probability ≥ 1−δ, at every time and against every adversary, the asserted axioms are the community's true axioms plus those false axioms that no derivation of size ≤ d exposes.
   - False Π1 axioms are removed one at a time without touching PA.
   - False Σ1 axioms consistent with PA, such as ¬Con(PA), survive. A witness requirement or a designation of Con(PA) removes them.
   - For false Σ2 axioms, no computable learner with this information succeeds, even in the limit.

#### 1. What is conditional on what

**Met by construction for PA:**
- First-order logic is trusted rather than learned. This is what avoids the problem in the RCF case.
- Q's axioms, each Con(T_j) and ¬Con(PA) are single sentences, which are trivially learnable.
- Induction is not a first-order pattern. The least general generalization (lgg) of induction instances is over-general and has false instances; I computed this. The audit would then delete induction and leave Q rather than PA. So induction is rewritten as a rule with two decidable premises:
  - Sub(φ,x,0,a), meaning a is φ[0/x];
  - Sub(φ,x,Sx,b), meaning b is φ[Sx/x];
  - conclusion: a ∧ ∀x(φ→b) → ∀xφ.
- Refutation search up to size d is brute-force computable, at cost exp(O(d)). So the "exact oracle" hypothesis is a cost, not an assumption.

**Real assumptions about the data:**
- Citations are i.i.d. with a known frequency floor. Every axiom name, false ones included, is cited often enough, and slips are rarer than a known bound.
- Each false axiom is cited under its own name, never under a true axiom's name. The learner is not told which names are false.
- Every axiom in use, false ones included, is a learnable pattern.
- When humans use induction, they write down the two Sub facts. This is a substantive data-format assumption. It tells the learner where the substitution happens, which is exactly what anti-unification cannot learn. A proof assistant could log these facts; human mathematicians don't write them.
- Designated premises are true. Only one designation in the PA results has mathematical content: (f) below designates Con(PA), which PA cannot prove and ZFC can.

**Part of the conclusion, not an assumption:** every guarantee holds only up to the search depth d. A theorem in the paper shows that no computable learner can drop this qualifier. The depth at which the output stops changing is not computable either; if it were, you could decide Π1 truth.

**Conjectures:** the paper states two, a binomial bound on escalations and a "bag-price" bound for informal proofs. The PA results use neither. One clause, about randomized learners at the Σ2 barrier, is only a proof sketch.

**The "conditionally" in the summary** was about complete decidable theories (RCF, Presburger, ACF_p, DLO), where the logic is learned too. There ∀E is not a first-order pattern. The lgg of three ∀E instances is ∀x(z0+z1=z2) / z3+z4=z5, which has the invalid instance ∀x(0+0=0) / 0+0=S0. The same Sub re-encoding or a new identification theorem would repair this, and neither has been carried out. That is unbuilt machinery, not a conjecture. Without it, the learner becomes sound only once the audit is deep enough to remove the over-general rule, and it then lacks that rule.

#### 2. The proposal for PA

**Ingredients:**
- **Data:** citations of axioms ("Q3", or "induction, with these Sub facts"). Logical steps are not data.
- **World:** computation decides Δ0 sentences.
- **Designated positions ⟨A : D⟩:** sentences certified true (A) and false (D). The default is ⟨∅ : ∅⟩.
- **d-refutation of a set B of axioms:** a derivation of at most d symbols. It starts from certified-true premises (A, true Δ0 sentences, true Sub facts) and uses B plus logic. It ends in ⊥, in a sentence in D, or in a Δ0 sentence that computes false.
- **Minimal conflict:** a set of axioms that has a d-refutation when none of its proper subsets does.

**The learner TTL(d, δ):**
1. **Burn-in.** Assert nothing for N1 = ⌈ln((1+c)K/δ) / (2Δ²)⌉ citations. Here K bounds the number of axiom names, Δ is the floor margin and c is a small constant per name. For scale: Q's 7 axioms plus induction, cited equally often with no slips, give Δ ≤ 1/32 and N1 ≈ 4,600 at δ = 0.01.
2. **Identify.** For each name, take the most specific schema that covers all but a budgeted number of its citations. This is Plotkin's anti-unification with outliers trimmed.
3. **Audit.**
   - Find a d-refutation and label its lines true or false where possible: certified premises, Δ0 computation, then forward and backward through its logic steps.
   - Walk back from the false conclusion along false lines until you reach an axiom use with true premises and a false conclusion. This is Shapiro's contradiction backtracing. Delete that axiom and repeat.
   - If the walk gets stuck, delete every axiom in some minimal conflict (Reiter's diagnosis) and stop.
4. **Freeze.** From then on, assert exactly the surviving axioms plus logic.
5. **Sandbox.** Conjectures live in a separate sandbox. They enter the asserted tier only as abbreviations of derivations from it.

**What the audit actually computes** has a simple closed form. One of the checkers spotted this and I verified it; it is not in the paper.
- Drop every cited axiom that is d-refutable on its own.
- If the rest is still refutable, drop every axiom in any of its minimal conflicts.

The output depends only on which sets are d-refutable, not on which refutation the oracle returns.

#### 3. What is proved for PA

**The general theorem, for PA.** There is an event of probability ≥ 1−δ, fixed by the first N1 citations. On that event, at every time and against every adaptive prover, the asserted axioms form a d-clean subset of the cited ones. They lie within the true axioms plus the depth-d residue: the false axioms that are d-clean even together with all the true ones. If every refutation traces to a single culprit, all true axioms are kept.

**"Popperian"** means: one computed counterexample refutes a false universal claim, while an existential claim can be verified by a witness but never refuted that way.

**(a) False Π1 axioms are removed on their own.** Suppose the community uses a false ∀x̄θ with θ ∈ Δ0. The refutation "⊢∀x̄θ, then ⊢θ(n̄) by ∀E", with θ(n̄) computing false, traces to that axiom alone, and no PA axiom is touched. It is caught once d ≥ 2|θ| + m(n+1) + O(1), with unary numerals, n the least counterexample and m the number of occurrences of x.
- Example (mine): Euler observed that n²+n+41 is prime for n = 0…39. A community generalizes this and uses ∀n Prime(n²+n+41) as an axiom.
- Primality is Δ0, and at n = 40 the value is 1681 = 41², so the axiom falls to one computation.
- The refutation is about 900 symbols long, so this is the idealized brute-force search, not a feasible one.

**(a′) Errors that only PA can refute cost you PA axioms.** This is not in the paper; it follows from the paper's lemmas, and I checked it.
- Suppose the community also uses τ = ∃x(Sx = x).
- Q + τ is consistent: take ℕ plus one point ω with Sω = ω, absorbing for + and ·. So τ is consistent with every true Δ0 sentence, and no computation exposes it on its own.
- PA + τ is inconsistent, because induction proves ∀x(Sx ≠ x). So every refutation gets stuck in the trace-back, and the audit withholds induction together with τ.
- This is forced. Δ0 computation cannot tell "Q plus a number that is its own successor, with induction as the error" apart from "PA, with τ as the error". It is the arithmetic twin of the paper's modus ponens versus affirming-the-consequent example.
- Every learner that must be sound under either diagnosis has to refuse the induction instance that proves ∀x(Sx≠x). This is the paper's blame theorem, at stable depth.
- Designating ∀x(Sx≠x), or denying τ, restores single-culprit blame.

So the clean story "PA survives untouched" holds specifically for false Π1 axioms.

**(b) False Σ1 axioms consistent with PA survive.** Take designated positions that assert and deny only Δ0 sentences.
- PA + ¬Con(PA) is consistent, by Gödel II.
- It proves no false Δ0 sentence, because it contains Q, which decides Δ0 correctly.
- So nothing refutes it at any depth, and ¬Con(PA) is asserted forever. TTL as defined already fails at Σ1.

**(c) Σ1-caution.** This is an optional add-on outside the main theorem: assert an axiom with prenex form ∃x̄θ only after computing a witness.
- False ones are then never asserted. True ones are asserted after an unbounded search.
- It is syntactic. ∀y∃p(Prf_PA(p,⌜⊥⌝) ∨ y≠y) is equivalent to ¬Con(PA) but Π2 in prenex form, so it escapes the policy and survives.

**(d) The Σ2 barrier.** Take a false Π2 or Σ2 axiom consistent with PA and with every designated position.
- It is never refuted.
- No computable learner using the citations, refutation search at every depth and Δ0 computation sorts true from false Σ2 axioms, even in the limit. The proof uses Shoenfield's limit lemma and Post's hierarchy theorem.
- This is what "sharp limits at Σ2" meant: the barrier no learner crosses. The Σ1 failure in (b) is TTL's own failure, and it is fixable.

**(e) Going beyond PA from usage alone.** Take a practice with no false axioms.
- T_k = PA + Con(PA) + … + Con(T_{k−1}) is identified from citations, for each k the floor allows (at most 1/(2Δ) names). This is the one place where positive data take the learner past anything refutation could certify.
- Without a floor there is no uniform sample bound. If Con(T_{k−1}) is cited with frequency π, accepting it needs t ≥ ln((1−δ)/δ′) / ln(1/(1−π)) citations, and this bound is tight.

**(f) Reflection as designation.** Designating Con(PA) as true makes ¬Con(PA) a single-culprit conflict. Reflection then enters as an explicit premise rather than as a learned rule.

**Truth-soundness.** In PA every "fallacy" is false by definition. So the reasoner proves only truths exactly when the depth-d residue is empty. That happens, for example, when the only false axioms in use are Π1 axioms with small enough counterexamples. With ¬Con(PA) in the practice, the reasoner proves ¬Con(PA).

#### 4. Why not just accept PA?

If you know the community's theory is PA, just accept PA; TTL adds nothing. The setting is a theory you don't know, seen only through citations, such as PA + Con(PA) + … for some unknown k, possibly with false extras.
- With logic trusted, what is learned is a short list of axioms plus induction, and which of them bounded search condemns.
- Computation decides only Δ0 sentences, so induction and Con(PA) can enter only through usage.
- In PA, computation refutes nothing that coherence with Q does not already refute. Its job is to say which axiom is to blame.

The PA case is mostly classical logic put into a learning model: Gödel II, Δ0-completeness of Q, the limit lemma, Reiter and Shapiro. The paper itself says none of it is deep. What is new is the setup, the explicit constants, and lower bounds showing that each ingredient is needed. Because logic is trusted, errors in reasoning itself, such as a quantifier swap, are outside the PA result; only false axioms are in scope.

Four independent checkers reviewed this against the paper and caught several errors in my first draft. (a′) and the closed form came out of that check.

Two of these points correct or extend the paper:
- (a′) is missing from the paper.
- A remark in the proof appendix credits PA's protection in (a) to the oracle's tie-breaking rule. The closed form shows the output does not depend on that rule.

Should I add both to the paper?

---

## 4. Rules versus axioms (2026-10-03)

**Question:**

> ok so we're not really learning inference rules in this setting? just axioms? i guess it might be generally fine to just do this because as long as we are given modus ponens as a background inference rule, then any decidable inference rule corresponds to a decidable axiom schema. is that how you're thinking about it?

**Answer:**

**Short answer.** For PA, yes. Logic is fixed, and what is learned is the non-logical axioms, plus induction as a rule whose extra premises are decidable substitution facts. That isn't the general setting, though. In the propositional case the learner learns the inference rules themselves, modus ponens included, with nothing trusted.

I wasn't explicitly using your reduction. FOL was trusted for a technical reason: the quantifier rules aren't patterns that the identification theorem covers. But your reduction is the right explanation of why the restriction costs little. In the paper's semantics it is exact for rules whose premises are sentences, with four caveats below.

#### Why your reduction works here

- **Translation.** A rule instance φ₁,…,φₙ / ψ becomes the axiom instance ⊢ φ₁∧…∧φₙ → ψ. With ∧I and MP trusted, the axiom gives back the rule.
- **Validity is preserved.** The paper counts a step as valid iff its conclusion is *derivable* from its premises in the target calculus, not merely admissible. For sentences, the deduction theorem makes this equivalent to the axiom being a theorem. So the rule is genuine iff the axiom is.
- **Learning is unchanged.** The translation wraps every instance in the same fixed context. So the least general generalization of the translated instances is the translation of the original lgg, and the sample bounds are the same.
- **Blame is unchanged.** Suppose ψ is false and ∧Π is true. Backward propagation through the trusted MP marks the axiom instance false, so descent blames the same culprit as before.
- **The paper makes your point for the propositional case.** Learning the theorems is enough there, because classical logic is structurally complete: the largest structural consequence relation with the tautologies as theorems is classical consequence.

One refinement to your wording. Decidability isn't what matters for learning; the hypothesis class is. Arbitrary decidable rule sets can't be identified from positive data (Gold). What you need is that the translation takes patterns to patterns, and it does.

#### Where the reduction isn't free

**1. It stops at MP, and trusting MP is not neutral.** This is Carroll's tortoise: every rule can be turned into a premise except the rule that uses premises.

Trusting MP also fixes the meaning of →. When MP itself is learned, take a practice that uses both MP and affirming the consequent. Coherence alone can't decide which one is the error, because reading "→" as "←" gives a coherent rival. Only world feedback or a denial settles it; this is the paper's blame theorem. With MP trusted, AC becomes the axiom (q ∧ (p→q)) → p, which one closed instance refutes. The problem disappears only because the answer was assumed.

**2. Rules with free variables or discharge don't translate.**
- Generalization φ(x) / ∀xφ(x) is valid, but φ(x) → ∀xφ(x) is not.
- →I and ∀I change the context, so they have no axiom counterpart either.
- For FOL you would trust MP and Gen, as in a Hilbert system.
- In the PA setting judgments are sentences, so this doesn't bite there.

**3. Admissible rules have no axiom counterpart, and translating one changes the theory.** The paper's semantics counts only derivable rules as valid, so the translation is exact in its own terms. The cost is that it can't represent admissible rules, which practice does use.
- **Reflection over PA.**
  - As a rule on theorems (from ⊢ Prov_PA(⌜φ⌝) infer ⊢ φ), it is admissible because PA is Σ₁-sound, and it adds nothing.
  - As the axiom schema Prov_PA(⌜φ⌝) → φ, it is true but not PA-provable (Löb). Its instance for φ = ⊥ is Con(PA). So the rule adds nothing and the axiom is a real strengthening.
- **Harrop's rule in IPC.**
  - The rule ¬p → q∨r / (¬p→q)∨(¬p→r) is admissible but not derivable.
  - As an axiom it gives the Kreisel–Putnam logic, a proper intermediate logic.
  - The paper proves that no learner given theorems and coherence data can tell IPC-derivability from IPC-admissibility ("Theorems versus consequence", coherence appendix).
  - Classical logic is structurally complete, so this distinction vanishes there.

**4. It doesn't touch the real obstacle in FOL.** The obstacle was never rules versus axioms. It is schemas whose instances involve substitution. The Hilbert axiom ∀xφ → φ[t/x] has exactly the same problem as the rule ∀E. Induction has it too, which is why induction needed the Sub encoding even though it is an axiom.

#### What "learning inference rules" means across the work

- **Propositional logic:** genuine inference rules. Experiment B learns 13 natural-deduction rules, including →I with discharge. The Post-completeness and Carnap results are about consequence relations, i.e. about rules.
- **Algebra:** rewrite rules. These are conditional equations with congruence and transitivity trusted, which is your reduction again.
- **PA:** axioms over trusted logic.

The full version for PA would learn first-order logic and the axioms together. ∀E would be encoded as ∀xφ, Sub(φ,x,t,ψ) / ψ, and Gen would carry its eigenvariable condition as a decidable side condition. Nobody has done this. The interesting question is whether quantifier rules have their own →/← style blame symmetries that only world feedback or a denial can break. I can work that out if you want.

---

## 5. Generalization and Hilbert-style systems (2026-10-03)

**Question:**

> hmm wait so going from phi(x) to forall x phi(x) is valid as an inference rule, but couldn't be written as an axiom? so you're saying in general one can't replace some inference rules with axioms even in the presence of MP? but i thought that in hilbert-style systems we only have MP and axioms, so now i'm confused

**Answer:**

You're right, and my last answer was imprecise. Hilbert systems for first-order logic come in two styles, and both are standard:

- **Mendelson, Kleene:** the rules are MP and Gen (from φ infer ∀xφ).
- **Enderton:** MP is the only rule, and generalization is built into the axioms.

What I should have said is narrower: Gen can't be replaced by *its own conditional* φ(x) → ∀xφ(x). It can be replaced by axioms, just not by that one.

#### Two ways to eliminate a rule

**(a) Add the rule's conditional.** Replace φ/ψ by the axiom φ → ψ. This works exactly when the rule is **locally sound**: under every assignment in every model, if the premises are true then the conclusion is. Gen fails this test. With φ(x) := x = 0 in ℕ and x assigned 0, the premise is true and ∀x(x = 0) is false. So φ(x) → ∀xφ(x) is not valid.

**(b) Close the axiom set under the rule.** This works for rules that are only **globally sound**, meaning they preserve validity or theoremhood. Gen is such a rule: if φ(x) holds for every x, so does ∀xφ(x). Enderton's system does exactly this:
- every generalization ∀x₁…∀xₙ A of an axiom A is itself an axiom;
- he adds the axioms ∀x(α→β) → (∀xα → ∀xβ), and α → ∀xα when x is not free in α.

Gen then becomes a metatheorem: if Γ ⊢ φ and x is not free in Γ, then Γ ⊢ ∀xφ.

Necessitation in modal logic is the same case. The logic K can be axiomatized with MP alone by taking every □ⁿ-prefixed instance of its axioms.

#### So can every rule be replaced, given MP?

For theorems, yes, and trivially so. Take all theorems as axioms, then use Craig's trick to make the axiom set decidable: list φ ∧ … ∧ φ, with n conjuncts, where n is the stage at which φ is enumerated. In that sense your original claim holds.

But route (b) costs two things that the learning setup cares about.

1. **It changes what follows from hypotheses, while keeping the theorems.**
   - In Mendelson's system φ(x) ⊢ ∀xφ(x), because Gen may be applied to hypotheses. In exchange, his deduction theorem is restricted.
   - In Enderton's system φ(x) ⊬ ∀xφ(x), and his deduction theorem is unrestricted.
   - The two systems have the same theorems but different consequence relations.
   - The paper judges a step with premises by whether its conclusion is derivable from those premises. So which convention you adopt changes which steps count as valid.

2. **It destroys the schema structure the learner relies on.**
   - Route (a) maps a single pattern to a single pattern, so identification and blame carry over unchanged. That was my earlier point.
   - Route (b) does not. "Every generalization of an instance of A" is a family with an unbounded quantifier prefix, not a single first-order pattern. It is the same kind of obstacle as the degree-indexed families in RCF.
   - Craig's axiom set has no structure at all.
   - So for theorem-preserving rules like Gen and necessitation, the learnable presentation keeps them as rules.

#### Where this leaves the earlier answer

The reduction is exact for **sentences**. With no free variables, local and global soundness coincide, the deduction theorem holds without restriction, and every valid rule corresponds to its conditional. The PA instantiation uses only sentences, so it isn't affected. Gen matters only once open formulas enter, for example if you try to learn the first-order logic itself.

The cleanest way to see it: **a rule is replaceable by its own conditional iff it is locally sound.** Rules that are only globally sound, such as Gen, necessitation, and the admissible rules from before (reflection, Harrop's rule), can still be eliminated in favor of axioms. But that requires re-engineering the axiom set, and the re-engineering either changes the consequence relation or loses the pattern structure.

---

## 6. Statements without context (2026-10-03)

**Question:**

> ok so in your setup for PA, you are just given a bunch of examples of making statements without context, and trying to guess axiom schemas that yield these statements but not too many others?

**Answer:**

Nearly, with three corrections.

**1. The data are axiom citations, not statements in general.** Each datum is one instance of an axiom, labelled with the axiom's name: "this is an instance of induction", "this is Q3". Data arrive i.i.d. with some noise. The learner never sees theorems or the proofs the axioms were used in, and logical steps aren't data, since logic is trusted. The learner is also not told which names are fallacies.

**2. One schema per name, and "not too many others" means the least general generalization.** For each name, the learner takes the most specific pattern that covers that name's instances (Plotkin anti-unification), after discarding a budgeted number of noisy ones. The theorem says that with enough varied instances this is exactly the community's schema, at a coupon-collector rate. Erring toward the specific side is deliberate: an over-general guess would accept instances nobody ever used.

**3. Guessing is only half of it.** Once the schemas are identified, the audit decides which ones get asserted, and it uses refutation search, not fit to the data. Every identified schema fits the data equally well. What separates them is whether some derivation of bounded size exposes them, either by deriving ⊥ or by deriving a Δ0 sentence that computes false.

**For PA, the learning-from-examples part is close to trivial.**
- Q's axioms, Con(T_j) and ¬Con(PA) are single sentences. "Learning" them just means recording which sentences get cited.
- Induction is the only genuine schema, and it is learnable only because the data carry the Sub facts. Those facts tell the learner where the substitution is, which is precisely what anti-unification couldn't work out alone.

So in PA the substance is the audit and the limits at Π1, Σ1 and Σ2, not the induction from examples. The setting where learning from examples does real work is the propositional one. There, rules with premises are induced from proof steps, including MP itself, and the MP/AC blame problem shows up.

**What a more natural PA setup would look like.** The data would be theorems, or whole proofs, without axiom names, and the learner would have to find an axiomatization. That is learning a theory from text, and Gold-style limits apply; the paper's Turing-chain impossibility is one of them. Without names, identification also needs a diversity condition, and cautious verification gets much more expensive. The paper doesn't attempt this for PA.

---

## 7. Untagged axioms, no mistakes in the data (2026-10-03)

**Question:**

> ok can we for now consider the setting where there are no mistakes in the data, but where we are not giving labels to the axioms. what do you have for that case

**Answer:**

**Short version.** Soundness is free, and Q's axioms are learned by rote. Dropping the labels changes one thing: the learner has to allow for the induction data coming from several narrower schemas. In PA this bites hard. At the smallest workable bound, induction ends up learned separately for each main connective. Two world refutations undo that and bring you back to the labelled case. At the level of theorems the whole case is nearly trivial. If the data are theorems rather than axiom instances, PA isn't learnable even in the limit.

Most of this is new. Checkers and I worked it out this session, with short proofs plus brute-force computations over all hypotheses consistent with the data (the version space). None of it is in the paper, and none of it has been refereed.

#### Setting

- **Data:** clean axiom instances, with no names attached.
- **Target:** Q's 7 axioms, each a single sentence, plus induction in its Sub-encoded form. Induction is the only real schema.
- **Hypotheses:** unions of at most k schemas, where the learner must know a bound k ≥ 8. Without a bound, every finite set is a hypothesis, and the cautious learner never generalizes beyond the data (Gold).
- **Learner:** the cautious one. It accepts a step iff every union of at most k schemas that covers the data contains it.

#### What holds for free (in the paper)

- **Soundness.** It is deterministic, holds at all times, and holds against every prover. It needs only that the true axiom set is such a union and that the bound is right. No probability, coherence or world feedback is involved.
- **Q's axioms.** One occurrence of each suffices, and single sentences are never over-generalized.

#### What changes without labels: counting slots (new)

**Proposition.** Let the target be finitely many single-sentence axioms G plus induction, with all of G appearing in the data. The learner accepts every well-formed induction instance iff the induction data can't be covered by k−1 failure sets.

A failure set is a narrower version of induction: either "φ has main connective f", or "two of the schema's metavariables are equal". I restrict to well-formed instances because the schema's instance set also contains junk, such as φ replaced by a term.

**Proof sketch.**
- The adversary's best move is to lump all of Q into one over-general schema. The least general generalization of Q's axioms is ⊢∀x Z, which covers no induction step. That leaves k−1 slots for splitting the induction data.
- A slot holding both a Q axiom and an induction step is a bare metavariable, because the two have different numbers of premises. Such a slot covers everything.
- So if k−1 narrower schemas can't cover the induction data, some slot must generalize to full induction.

The proof is short. 300 random small cases matched its prediction in every case.

**Consequences for PA:**
- A PA formula has one of about seven main connectives: =, ¬, ∧, ∨, →, ∀, ∃. So seven failure sets cover every real induction instance. With k = 8 there are k−1 = 7 slots, and the adversary can always split induction by main connective.
- So at k = 8, induction is effectively learned as seven separate rules, one per connective. The learner accepts induction on an f-formula exactly when it is an instance of the generalization of the observed f-inductions. Induction on a connective the community never used is never accepted.
- If the learner only knows a looser bound k > 8, the spare slots allow finer splits, and the data must be varied a level deeper inside each connective class.
- If the induction variable is a metavariable, variable names count the same way: induction on a never-used variable name is not accepted.
- **This makes the paper's general unlabelled theorem vacuous for PA.** Its sufficient conditions are "k+1 instances with pairwise different shapes", or a positive diversity mass. PA data have only about seven top-level shapes, so they can never meet those conditions. The proposition above replaces that theorem for PA.

#### Negative information does the labels' job (new)

The world refutes ⊢∀x(0=S0) and ⊢∀x∀y(0=S0), each with one ∀-instantiation and one computation.
- Every lumping of two or more Q axioms has one of these two sentences as an instance. I checked all 120 subsets of Q's axioms independently.
- So these two refutations forbid lumping. Q then needs seven slots and induction gets one. Two induction instances with different main connectives then suffice, which is exactly the labelled case.
- A brute-force check at k = 8 confirms this. With the 7 Q axioms plus an =-induction and a <-induction, an ∃-induction is rejected without the two negatives and accepted with them.

A cautious learner never sees a contradiction among its own accepted steps. Refuted candidate steps still prune its hypotheses, and in the clean unlabelled case that pruning provides what the labels provided.

#### At the level of theorems, it's nearly trivial

The reasoner chains accepted steps with trusted logic. Classically, induction for φ is equivalent to induction for ¬¬φ, or for φ∧φ, ∀z φ, and so on. So once one connective class such as ¬ is learned in full generality, the reasoner proves every theorem of PA. For ¬ that takes two ¬-inductions with different inner connectives.

The per-connective incompleteness is about which steps get certified, not about what can be proved. Variable names work the same way, by renaming. The expensive notion is certifying individual steps, which is the one the paper uses.

#### If the data are theorems rather than axiom instances

Then PA isn't learnable even in the limit. The argument uses standard facts that I haven't machine-checked:
- IΣₙ is finitely axiomatizable for n ≥ 1.
- The chain IΣ₁ ⊂ IΣ₂ ⊂ … is strict, since IΣₙ₊₁ proves Con(IΣₙ).
- The union of the chain is PA.

So a class containing all the IΣₙ and PA has a limit point, and by Gold no learner identifies it from a text of theorems. Coherence with true designations and Δ0 computation don't help, because every member is true and so they answer identically for all of them.

A cautious verifier at the level of theorems is never complete. Every finite set of PA theorems lies in some IΣₙ, so Con(IΣₙ) is never accepted. **So PA is learnable from how its axioms are used, but not from its theorems.**

Whole proofs without rule citations sit roughly in between. With trusted decidable logic you can mostly tell which lines are axiom uses, and that reduces to the axiom-instance case.

#### Status

Not in the paper or refereed, but proved and checked as described:
- the slot proposition;
- the per-connective description;
- the fix by negative evidence;
- the theorem-level remark.

One more easy remedy: if the learner is told only that at most one axiom has premises, the premise count acts as a label. The problem then reduces exactly to the labelled case.

If you want, I'll write these up as a section on unlabelled data, with the scripts.

---

## 8. Gold's theorem (2026-10-04)

**Question:**

> what's the gold result you're mentioning?

**Answer:**

It's Gold's 1967 paper, "Language identification in the limit" (Information and Control 10).

#### The setting

- **Class:** a class of languages, i.e. sets of strings. For us these are sets of steps or sets of theorems.
- **Text for L:** an infinite sequence that lists every element of L and nothing outside it, in any order, with repetitions allowed. It contains only positive examples.
- **Learner:** it reads longer and longer prefixes of a text and outputs a guess, an index for a language, after each one.
- **Identification in the limit:** the learner identifies L if, on every text for L, its guesses eventually settle on a correct index forever. It never has to know that it has settled. It identifies a class if it does this for every member.

#### The theorem (limit-point form)

If a class contains an infinite strictly increasing chain L₁ ⊊ L₂ ⊊ … together with its union L∞, then no learner identifies the class from text. This holds even for learners that aren't computable. Gold's original special case is a "superfinite" class, one that contains every finite language plus at least one infinite language.

**Proof.** An adversary builds a text for L∞ in stages.
- At stage i, it presents elements of Lᵢ: the elements among the first i of a fixed enumeration of L∞ that lie in Lᵢ, followed by repeated elements of Lᵢ.
- The prefix so far, continued with a text for Lᵢ, is a text for Lᵢ. So the learner must eventually guess Lᵢ, and at that point stage i ends.
- Every element of L∞ lies in some Lᵢ, so the full sequence is a text for L∞.
- The learner changes its guess at every stage, so it never settles on L∞.

The underlying point is that with positive data only, the data at every finite time are also consistent with a smaller hypothesis. A learner that never bets on the smaller hypothesis fails when the smaller one is true.

**Angluin's refinement (1980).** For indexed families, a class is identifiable from text iff each L has a finite **tell-tale**: a finite T ⊆ L such that no member L′ of the class satisfies T ⊆ L′ ⊊ L. L∞ has no tell-tale, because every finite subset of it lies in some Lᵢ. The paper's "anchors" are the version of this that matters for the cautious verifier.

**The contrast that matters.** With an **informant**, which gives positive and negative examples, Gold showed that every recursively enumerable class of decidable languages is identifiable by enumeration. Negative examples rule out over-general guesses. That is why the two world refutations did so much in the unlabelled PA case.

#### How I used it

1. **Unlabelled data with no bound on the number of schemas.** Every finite set of steps is a union of finitely many single-step schemas. So the class contains every finite language plus the infinite target, which makes it superfinite. In that case the cautious learner accepts exactly the data and never generalizes.

2. **Theorems as data.**
   - Take Lₙ = the theorems of IΣₙ and L∞ = the theorems of PA.
   - The chain is strict (IΣₙ₊₁ proves Con(IΣₙ)), and its union is PA.
   - So no learner identifies PA from a list of its theorems if its hypotheses include the IΣₙ. That happens as soon as the hypothesis space is something natural like "Q plus finitely many axioms or schemas".
   - Coherence with true designations and Δ0 computation don't break the tie. Every theory in the chain is true, so these give the same answers whichever one is the target, and the adversary's text stays legitimate. In the paper this is the corollary on limit points (the one behind the Turing-chain result).
   - This is a statement about the class. A learner that assumes "the answer is PA" succeeds trivially. The impossibility appears once the hypotheses are rich enough to contain the chain.

---

## 9. Preferring L∞ to L5 (2026-10-04)

**Question:**

> hmm but i guess in principle you could have a learner that alway prefers L_infty to L_5, even if all the examples are from L_5? i guess this theorem holds under some assumption that it is possible to force the learner to prefer L_5 to L_infty?

**Answer:**

Yes. A learner that always prefers L∞ is allowed, and it is exactly the learner the theorem says must fail somewhere. There's no hidden assumption; what "forces" it is the success criterion.

**The criterion.** The learner is graded on every member of the class. On every text for L₅ it must eventually guess L₅ and stay there. A learner that keeps preferring L∞ on L₅-texts never does that, so it has already failed on L₅.

**What the adversary actually uses.** It never forces a switch. It waits for one.
- By the success criterion, the learner eventually says Lᵢ on every Lᵢ-text. That includes texts that begin with whatever prefix the adversary has built so far.
- So the adversary feeds elements of Lᵢ until the switch happens, then moves on to Lᵢ₊₁.
- If the switch never happens, the learner has failed on Lᵢ.
- Either way, the learner fails on something.

**The precise trade-off.** You can identify L∞ together with finitely many chain members, but not infinitely many.
- **Finitely many:** pick L_{i₁} ⊊ … ⊊ L_{iₘ}. Guess the smallest of them that contains the data so far, and guess L∞ if none does. On an L∞-text, some element outside L_{iₘ} eventually appears, and the learner switches to L∞ for good.
- **Infinitely many:** any infinite subchain still has union L∞. So the limit-point argument applies to the subchain as before.

So the theorem forces a choice between the limit and all but finitely many members of the chain.

**This is the paper's caution/boldness split.**
- The cautious verifier is the learner that prefers the smallest consistent hypothesis. It handles every Lᵢ and is never complete on L∞.
- Preferring L∞ is boldness. It handles the limit and gives up the chain.
- No single preference handles both ends of a limit point.

**For PA, preferring PA over the IΣₙ is a reasonable bias, and in this chain it is even truth-safe.**
- Every IΣₙ is true, and so is PA.
- A learner that bets on PA when the community actually uses IΣ₅ asserts only true sentences the community doesn't use.
- That is unsound relative to the community's calculus, but not relative to truth. It is the same distinction as in the earlier floor bound, where accepting the true Con(T_{k−1}) counted as unsound.

So the impossibility bites only if you want to recover exactly which IΣₙ the community uses.

**Preferring the bigger hypothesis goes wrong when bigger hypotheses can be false.**
- Over PA there is no largest consistent recursively axiomatizable extension to prefer. By Gödel–Rosser, every one has an undecidable sentence ρ, so both T+ρ and T+¬ρ are consistent. This is the paper's "no maximal r.e. hypothesis".
- A learner that adds whatever stays consistent ends up at a completion that depends on the order in which sentences arrive. On some orders that completion contains ¬Con(PA), so it proves a false Σ₁ sentence.

For the IΣₙ chain your bias is fine. It is above PA, where "prefer the more general theory" stops being well defined, that you need something like the paper's designations, such as asserting Con(PA).

---

## 10. Learning the induction schema from positive examples (2026-10-04)

**Question:**

> ok maybe let's focus on learning the induction scheme specifically, from a bunch of positive examples. can you tell me what learning algorithm you'd propose for this and what propositions you have about it?

**Answer:**

**Proposal in one line.** Treat induction as a second-order template, P(0) ∧ ∀x(P(x)→P(Sx)) → ∀x P(x). Read the predicate P off the conclusion ∀x P(x), check that the other two occurrences match, and learn cautiously in the class of templates that have such a "read-off" occurrence. Equivalently, read the motive off each example, rewrite the example into a first-order form, and use ordinary anti-unification.

Below, Ind(φ) is φ(0) ∧ ∀x(φ→φ[Sx/x]) → ∀x φ, the motive is φ, and its "main connective" is its top symbol (=, ¬, ∧, →, ∀, …).

Everything here was worked out today. Each track had an independent referee who re-implemented the code and attacked the claims. None of it is in the paper, and it has had one round of refereeing, not the paper's multi-round process. The referees found and fixed several defects, listed at the end.

#### Why plain first-order anti-unification fails

1. **Two examples already force unsoundness.** The lgg of Ind(x+0=x) and Ind(0+x=x) is (0+0=0) ∧ ∀x(z₁+z₂=x → z₃+z₄=Sx) → ∀x(z₁+z₂=x). It has the false instance (0+0=0) ∧ ∀x(0+0=x → 0+S0=Sx) → ∀x(0+0=x). Every first-order schema covering both examples is at least as general as their lgg, so every such schema has this false instance. One example never forces unsoundness.

2. **No finite union of first-order schemas covers induction soundly.** Take φₙ = (0+(0+…+(0+x))…) = x, with n zeros. Any first-order schema covering two of the Ind(φₙ) has a false instance that Q refutes. So k sound schemas cover at most k of them. The obstacle is the syntax of substitution, not deductive strength. This is a different fact from Ryll-Nardzewski's result that PA is not finitely axiomatizable.

3. **The cautious first-order learner is unsound on such data, and the world doesn't reliably rescue it.**
   - Often an over-general lgg is refuted with blame on that single schema. You then end up with no induction at all.
   - But lgg(Ind(0+x=x), Ind(S0+x=Sx)) has a false instance and is consistent with every true quantifier-free sentence. A referee proved this. So it is never refuted. Or, if Q's axioms are learned alongside it, Q's recursion axiom x+Sy = S(x+y) is lost as collateral.

4. **Higher-order pattern anti-unification doesn't fix it** (Pfenning 1991; Baumgartner, Kutsia, Levy and Villaret 2017). Induction sits just outside the pattern fragment, because P(0) and P(Sx) are not pattern occurrences. On induction data its lgg is A ∧ ∀x(P(x)→Q(x)) → ∀x P(x), which has the false instance (0=0) ∧ ∀x(x=0→x=0) → ∀x(x=0).

#### The algorithm

**Class.** Second-order templates over the arithmetic language whose metavariables are applied only to metavariable-free arguments. Each metavariable must have at least one **pattern occurrence**: an application to distinct bound variables, such as P(x) under ∀x. I'll call these determinate templates. The induction template is one: P(x) under the final ∀x is its pattern occurrence.

**Matching.** Read each metavariable off its pattern occurrence, then check the other occurrences by substitution. For induction: set P := λx.φ from the conclusion ∀x φ, then check that the antecedent is φ[0/x] ∧ ∀x(φ → φ[Sx/x]).

**Learning and verifying.** The verifier is cautious: it accepts a sentence iff every template in the class that covers all the examples has it as an instance. The class has no lggs in general, so this is an intersection over the minimal covering templates. Those are found from the positions on which all the examples agree.

**With noise.** If at most e examples may be wrong, take the intersection over templates that miss at most e examples.

#### Propositions (proved, then refereed)

1. **Matching.** For a determinate template and a sentence there is at most one match, found in time O(|template|·|sentence|). It is linear for induction. Without determinacy, matching can have exponentially many solutions.

2. **Anchor theorem.** A finite set D of induction instances pins down the schema, i.e. every determinate template covering D contains every induction instance, iff both of these hold:
   - **(R)** the motives in D don't all share one main connective;
   - **(N)** some motive in D has x free.

   So two examples suffice, for instance Ind(x=x) and Ind(¬x=0), and one never does. Given such a D, the induction template is the least template covering it, out of exactly 26 templates that generalize it.

3. **Soundness and exactness.**
   - The verifier is sound at all times, against any prover, for motives of any size.
   - Before the anchor appears it accepts only a sub-family of induction. For example, from Ind(x=x) and Ind(x+0=x) it accepts induction for motives of the form t(x)=x.
   - After the anchor it accepts exactly the induction instances.

4. **Rate.** For i.i.d. motives:
   - P[no anchor after N] = Σ_f p_fᴺ + (1−q)ᴺ − Σ_f r_fᴺ ≤ p_maxᴺ⁻¹ + (1−q)ᴺ.
   - Here p_f is the share of motives with main connective f, q the share with x free, and r_f the share with connective f and x not free.
   - Example: 60% equations, 20% implications, 10% ∀ and 10% other, with almost all motives non-vacuous. Then about 10 examples give an anchor with probability 99%; at q = 0.4 it is 11.

5. **When the cautious verifier is sound, in general.** Given an anchor, the cautious verifier is sound iff the target equals the intersection of the hypotheses that contain it. Realizability, meaning the target is itself a hypothesis, is sufficient but not necessary.
   - Consequence: if you cap template size below 12 (in our size measure, where the induction template has size 14), the learner accepts false non-induction sentences. One example is (0=0 ∧ ∀x(x=x → Sx=Sx)) → ∀x(x=0).

6. **Without the read-off requirement the anchor condition gets stronger.** Some motive must contain x outside any closed-up subterm. For example, the data {Ind(Sx=S0), Ind(¬Sx=0)} are also covered by P(S0) ∧ ∀x(P(Sx)→P(SSx)) → ∀x P(Sx), which misses Ind(x=x).

7. **Noise.** With at most e wrong examples, the trimmed verifier accepts exactly the induction instances once more than e correct examples avoid each connective and more than e have x free.

#### An equivalent first-order route

You can instead read off φ and rewrite each example. Both rewrites below have exactly the same anchors (R) and (N):

- **The paper's encoding.** Add the premises Sub(φ,x,0,a) and Sub(φ,x,Sx,b), where Sub(φ,x,t,ψ) means ψ is φ[t/x], and run plain lgg.
- **Tarski-style form.** IndEq(P) = ∀x(x=0→P) ∧ ∀y(∀x(x=y→P) → ∀x(x=Sy→P)) → ∀x P.
  - It is equivalent to Ind(P) in first-order logic when y is not free in P.
  - It is a first-order pattern with the single metavariable P.
  - Its lgg is IndEq of the lgg of the motives, and its anchor needs only (R).
  - Q together with all instances of IndEq axiomatizes PA, so PA is seven sentences plus one first-order pattern.

This connects to your earlier rules-versus-axioms question. Equality hypotheses do what substitution did. Metamath's set.mm states induction this way (its theorem `finds` has hypotheses x = ∅ → (φ ↔ ψ) and so on). Lean's induction tactic computes the motive by abstracting the goal, which is the matching in Proposition 1.

#### With mistakes

Take a systematic "step by 2" induction, with step φ → φ[SSx/x], cited under its own name. It is learned exactly as easily. It is unsound: with motive ¬(x=S0) the antecedent is true and the conclusion false. The audit can't pin it down alone: with only computation and no designated premises, it has no refutation at any depth. Only the set {step-by-2, Q1, Q2} is refuted, so Q1 and Q2 are lost as collateral unless Q's axioms are designated as true.

#### What the referees changed, and what's open

**Corrections the referees made:**
- The Lean-style encoding with a named binder admits variable capture and is unsound. A nameless binder or a freshness guard fixes it.
- The class had to be restricted to metavariable-free arguments. With nested arguments the algorithm was unsound for some targets, and the set of minimal templates could be infinite.
- My "about 10 examples" holds for q ≳ 0.43. At q = 0.4 it is 11.
- Lean's `Nat.rec` takes the motive as an implicit argument, though the elaborated term records it.

**Open:**
- whether the set of minimal templates is always finite in the restricted class;
- a polynomial bound on how often the learner must consult a human before an anchor appears;
- induction with parameters (motives with free variables other than x).

The notes and scripts are in my scratchpad and will be lost when this session's container is reclaimed. Should I add them to the repository and write a short section of the paper on learning induction from raw examples? The section would include the correction that the audit doesn't always remove an over-general raw lgg.

---

## 11. Universal axioms, ZFC schemas, many schemas at once (→ axiom-schemas/) (2026-10-07)

**Question:**

> * does the same thing work for learning an axiom of the form forall x phi(x) from a bunch of sentences of the form phi(x)?
> * does the same thing work for learning each axiom schema of ZFC from a bunch of instances?
> * anyway can you try to come up with a method that works for all these? ideally, your method would also work for learning many axiom( scheme)s at once, even if they do not come with labels for instances of which axiom scheme they are
> * if you succeed please write this up as a separate standalone paper and give me a pdf

**Answer:**

The standalone paper is attached: "Learning Axioms and Axiom Schemas from Their Instances", 135 pages. The main text is about 50 pages; the rest is proofs and an appendix listing every correction and every result that wasn't independently refereed. All the refereeing and checking was done by separate Claude instances: no human checked the mathematics, and nothing was verified in a proof assistant.

**1. Learning ∀xφ from instances φ(t): yes for the instance schema φ(z), but not for the sentence ∀xφ.**
- φ(z) is an ordinary first-order pattern, so plain anti-unification learns it. With one variable, two instances whose terms have different head symbols are enough to pin it down.
- Going from all closed instances to ∀xφ is an extra ω-rule step. It is truth-safe exactly when the substructure of closed terms is elementary (Tarski–Vaught). That holds in ℕ and in every model of true arithmetic, but fails in ℝ: ¬(x·x = 1+1) is true at every closed term but false at √2.
- That step is also not derivable in general: Q proves 0+n̄ = n̄ for every n but not ∀x(0+x=x).
- A cautious learner can take the step silently if parameters are allowed as values. A closedness guard learned from closed data prevents this.

**2. ZFC schemas: yes, and more easily than PA induction.**
- Every ZF schema, in each formulation I considered, is a higher-order (Miller) pattern. Instances pin a schema down iff the main symbols of their bodies vary and every argument place gets used, so two instances can suffice.
- Plain first-order anti-unification only works for some formulations and variable encodings. Separation needs a freshness guard, without which Russell's paradox appears as an instance. For most of the remaining cases no finite union of first-order schemas is sound.
- One exception: for spelled-out Replacement, the first-order generalization of data that pin the schema down over-generalizes, yet stays truth-sound. Over a base theory this holds exactly when that theory proves Collection.
- PA induction is the contrast: it is not a pattern, and only the determinate-template learner gets it.

**3. One method for many schemas without labels: DTRC.** It clusters examples by trying to refute the generalization that would merge two clusters, then checks each cluster cautiously.
- **When it works:** if every merge across different schemas is refutable ("refutation separation"), it recovers the hidden labels, never accepts a false instance, and needs no more data than a learner given the labels.
- **Supporting results:** without refutations a bound on the number of schemas is necessary. With an exact bound, refuting the cross-schema merges makes the unlabelled learner exactly as good as the labelled one. Learning ∀xφ from instances becomes the special case where the merge is sound and never refuted.
- **When separation fails:** DTRC is sound only up to the merges it failed to refute. No computable learner can avoid depending on how deep it searches for refutations.
- **Cost:** some steps are hard. The cautious check over unions of k ≥ 3 schemas is coNP-complete, and the refutation test is NP-complete in general.
- **Where separation holds:** it is proved for Q's axioms with induction, and only checked on sampled ZF and ZFC data.

**Experiments.** On unlabelled mixtures of PA and ZF(C) instances, DTRC recovered every cluster in every run and matched the labelled learner. With mistaken examples injected, it accepted a false sentence at the two lower refutation budgets; the paper reports this.

**Problems found during review and fixed:**
- **Parameter-renaming result:** the proposition about matching up to renaming of parameters was false in general. It is now restricted, with the counterexample in the paper.
- **Sharing-pass guarantee:** it was overstated. It is now weakened, and the reviewer's counterexample is included.
- **Earlier conjecture C11:** the induction work conjectured that the checker consults a human at most linearly often before it is exact. That is refuted; the right bound is quadratic.

Everything is committed and pushed to `claude/sleepy-gauss-u4kem1` under `axiom-schemas/`: the paper, the code with 43 tests and experiments, the research records with referee reports, and the review reports. Publication is your call.

---
