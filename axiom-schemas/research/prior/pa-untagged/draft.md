# Draft: noise-free, untagged PA. "What do you have for that case?"

## Setting
Data: i.i.d. (or a text of) axiom instances used by the community, with no name attached and no mistakes. So every datum is a genuine axiom instance; F = ∅.
For PA: the target is Q's seven axioms (ground sentences, each one "schema" with no metavariables) plus induction in its Sub-encoded form, Sub(φ,x,0,a), Sub(φ,x,Sx,b) ⊢ a ∧ ∀x(φ→b) → ∀xφ (the only genuine schema), possibly plus ground extras like Con(PA). So k' = 8 (or more with extras).
Hypothesis class: H_k = unions of at most k schemas, with a known bound k ≥ k'.

## The learner
The cautious (version-space) verifier: accept a step iff every union of ≤ k schemas that covers all the data contains it.

## What is proved (from the paper, applied to PA)
1. Soundness, deterministic, at all times, against every adaptive prover — needs only realizability (target ∈ H_k) and the bound k. No probability, no coherence, no world. (lem:imitation:cautious(a); thm:caution:vs(a).) Truth-soundness follows if the target axioms are true.
2. A bound k is necessary: with unbounded k the class is superfinite and the cautious verifier accepts exactly the data, never generalizing (Gold). (§imitation untagged, opening paragraph.)
3. Exactness: the verifier becomes exact iff the data contain an anchor; anchors exist because H_k has finite elasticity (Wright 1989, corrected by Motoki–Shinohara–Wright 1991). Sufficient (thm:imitation:untagged(a)): one instance of each ground axiom, and for induction, a set of instances whose substitutions are not covered by any k "failure sets" (a failure set fixes the root symbol of one metavariable, or identifies two metavariables). In particular k+1 pairwise-generic instances of induction suffice. After that, exactness holds for derivations of any size (cor:imitation:ood).
4. Sample complexity (thm:imitation:untagged(b)): with diversity ζ (the least probability mass of induction instances escaping any k failure sets) > 0, enough is n ≥ (8d/ζ) log₂(13/ζ) + (4/ζ) log₂(2k'/δ) induction samples, d = 2k log₂(4k(v²+1)), v = number of metavariables, plus one sample of each ground axiom. Compare tagged: ln(kc/δ)/(πρ) total. Untagged is an ε-net bound: linear in k up to logs, and inversely proportional to diversity.
5. Diversity is necessary (prop:imitation:diversity(a)): if the induction data are covered by k−k'+1 specializations of the induction schema (e.g., induction only ever applied to formulas φ with one of a few root symbols) and some instance lies outside them, the verifier is never exact. So "no names" turns "two generic examples" into "examples more varied than the spare slots can absorb". Exact threshold for k' ≥ 2 is open.
6. The cost of staying sound while a prover queries beyond the data (escalations to a human): tagged ≤ k(N+1) on steps of size ≤ N; untagged ≥ ⌊(N−1)/k⌋^k even for a one-rule target (thm:caution:untagged(i), proved over a signature with a k-ary symbol, a unary symbol and a constant); upper bound (k^{N+1}−1)/(k−1); conjecturally ≤ C(N+k, k) (conj:caution:binomial, the paper's conjecture — this is where it would matter).
7. What a non-cautious learner does: the simplest consistent hypothesis (MDL over schemas) is the single metavariable, "anything from anything" (prop:search:mdl). Least generality, not simplicity, is the right bias.
8. Coherence and the world play no role for the cautious learner: it never sees a contradiction (prop:coherence:caution). They would only matter for a bold learner that guesses a k-union before the data force it; the sandbox/halving bound log₂(1/w*) applies to such guesses, subject to the Popperian limits (an over-general guess whose false instances are all unrefutable is never caught).

## PA-specific remarks
- Q's axioms are ground: one occurrence each suffices; they are never over-generalized by the cautious verifier.
- Hypotheses in the version space may merge all of Q's axioms into one over-general schema (e.g. their lgg, "∀x Z") to free slots; that only affects completeness on induction, never soundness.
- Induction steps have Sub premises; ground axiom steps don't. So shape separates them, but this does not make the problem tagged: the learner still doesn't know how many schemas the induction data come from.
- Without the Sub encoding, realizability fails (induction is not a pattern), and the cautious verifier's soundness guarantee no longer applies.
- TTL's main theorem is stated for tagged data; with F = ∅ its audit is idle, so in the noise-free untagged case everything reduces to the cautious verifier over H_k.

## What we don't have
- An end-to-end untagged theorem with noise or fallacies (the "mis-cited fallacies" case): costs would run through the binomial conjecture.
- Exact escalation bounds for PA's own signature.
- The data-as-theorems version (learning an axiomatization from theorems without names): only Gold-style results (Turing-chain impossibility; Shinohara's length-bounded EFS mention).
