export const meta = {
  name: 'experiments-core',
  description: 'Build symbolic toolkit and core experiments: rule learning from positive steps, coherence, adversarial provers',
  phases: [
    { title: 'Infra+Algebra', detail: 'terms, anti-unification, rule schemas with guards; algebra domain with fallacies' },
    { title: 'Domains', detail: 'propositional ND domain; statistical baseline verifier + adversarial prover' },
    { title: 'Review', detail: 'independent code review and reproducibility check' },
  ],
}

const ROOT = '/home/user/AI-works/inferential-learning'
const CODE = ROOT + '/code'
const CTX = `Project context: read ${ROOT}/research/00-brief.md and ${ROOT}/research/01-orchestrator-ideas.md first. We are investigating whether a learner that learns INFERENCE RULES from positive examples of human inference steps, plus COHERENCE (contradiction detection) and sparse WORLD FEEDBACK (truth values), yields a reasoner that is sound (even against an adversarial proof-search process) and productive. Experiments must be small, CPU-only (4 cores, keep any single run under ~10 minutes), deterministic (fixed seeds), pure Python 3.11 with numpy/sympy/scikit-learn allowed (pip install if missing). Code lives in ${CODE} as a package 'cil' (code/cil/...), experiments in code/experiments/, results (JSON + short markdown reports + optional matplotlib PNGs) in code/results/. Write clean, well-documented code with unit tests (pytest) in code/tests/. Every experimental claim in a report must be backed by a script that regenerates it.`

const SUM = { type: 'object', properties: {
  files_created: { type: 'array', items: { type: 'string' } },
  how_to_run: { type: 'string' },
  key_results: { type: 'array', items: { type: 'string' } },
  caveats: { type: 'array', items: { type: 'string' } },
  api_notes: { type: 'string' } }, required: ['files_created', 'how_to_run', 'key_results', 'caveats', 'api_notes'] }

phase('Infra+Algebra')
const infra = await agent(`${CTX}

TASK A (foundation + algebra domain). Build:
1. cil/terms.py: first-order terms (variables, function applications incl. constants and integer literals), parser and pretty-printer for a simple infix syntax (+, -, *, /, ^, unary -, function calls like sqrt(x)), substitution, one-way matching, syntactic unification, Plotkin anti-unification (least general generalization) for terms AND for tuples of terms with a CONSISTENT variable map across the tuple, term size, positions/subterm replacement (contexts C[.]).
2. cil/rules.py: rule schemas = (premise terms..., conclusion term, guard) where for the equational domain a rule is an oriented rewrite schema l -> r with an optional GUARD from a finite guard language (e.g. 'nonzero(x)', 'nonneg(x)', conjunctions thereof). A STEP is (term_before, term_after) where term_after = term_before with one subterm rewritten by an instance of a rule; implement: does rule R license step s (find position + matching substitution + guard satisfied given the context's known facts), extracting the 'rewrite core' (the instantiated l, r) of a step by diffing the two terms at the unique changed position (handle ambiguity carefully), and anti-unification of rewrite cores to induce a schema.
3. cil/domains/algebra.py: a TARGET calculus for field/ring algebra (commutativity, associativity, distributivity, identities, inverses, power rules, x/x -> 1 GUARDED by nonzero(x), sqrt(x^2) -> x GUARDED by nonneg(x), etc.), a generator of synthetic 'human' derivations (simplification/expansion exercises on random expressions) whose steps are instances of target rules, plus a configurable NOISE model: sporadic random invalid steps at rate eta, and SYSTEMATIC FALLACIES applied with some probability when applicable: freshman's dream (a+b)^2 -> a^2+b^2, unguarded cancellation x/x -> 1, sqrt(x^2) -> x unguarded, (a+b)/(c+d) -> a/c+b/d, -(a+b) -> -a+b. WORLD FEEDBACK oracle: random numerical evaluation (Schwartz-Zippel style, over rationals with exact arithmetic via fractions; evaluation where denominators vanish => 'undefined', which matters for guards).
4. cil/learners.py: (a) VersionSpace/LGG learner: from positive steps (rule-tagged variant: humans name the rule; untagged variant: cluster cores by shape/head symbols and anti-unify), output a set of learned schemas; CONSERVATIVE verifier: accept a step iff it is licensed by a learned schema that is supported by >= m instances (m configurable) — document the exact acceptance criterion; (b) COHERENCE pruning: for each learned schema, search for a NEGATIVE BAG: a short derivation using learned schemas that, under world feedback (numerical evaluation), equates two terms that evaluate differently (a contradiction like 2 = 4), and then either delete the offending schema or REPAIR it by adding the minimal guard from the guard language that blocks all found counterexample instances while keeping the human positive instances (Lakatos lemma-incorporation / monster-barring); credit assignment: when a bad derivation uses several schemas, test each schema's instances individually with numerical evaluation (single-step world feedback) — implement both 'bag-level' (only knows the derivation is bad) and 'step-level' feedback and compare.
5. experiments/exp_algebra_learning.py: measure, as a function of the number of human derivations N (e.g. 5..500) and noise settings: (i) exact recovery of target schemas (up to variable renaming), (ii) whether fallacy schemas are learned, then (iii) whether coherence/world feedback removes or repairs them (does unguarded x/x->1 get repaired into the guarded rule? does freshman's dream get deleted?), (iv) soundness of the resulting verifier on a held-out set of VALID and INVALID steps including adversarially constructed ones (out-of-distribution: much larger terms than humans used), (v) completeness on held-out valid steps (systematic generalization to larger terms). Produce results/algebra_learning.json and results/algebra_learning.md.
6. tests for terms/rules/learners.
Return the structured summary, including api_notes describing the public API so the next agents can build on it.`, { label: 'infra+algebra', phase: 'Infra+Algebra', schema: SUM })

phase('Domains')
const domains = await parallel([
  () => agent(`${CTX}

The foundation package already exists (read the code in ${CODE}/cil first). API notes from its author:
${infra ? infra.api_notes : '(not available: read the code)'}

TASK B (propositional natural-deduction domain + Post-completeness/coherence experiment). Build cil/domains/prop.py and experiments/exp_prop_learning.py:
1. Formulas over atoms p,q,r,... with ->, &, |, ~, bottom. Steps are sequent-style: from premise sequents Gamma |- A ... infer Gamma' |- B (natural deduction in sequent form, with assumption discharge), so that CONTEXTS (assumption sets) are explicit. Target calculus: standard classical ND (intro/elim rules + RAA or excluded middle). Represent rules as schemas over sequents with metavariables for formulas and for context multisets/sets; learn them from positive examples via anti-unification (reuse cil.terms where sensible; extend as needed).
2. Synthetic human proofs of tautologies (generated by a backward/forward proof search over the target calculus with some randomness), plus systematic fallacies: affirming the consequent (A->B, B / A), denying the antecedent, illegitimate discharge (discharging an assumption still used elsewhere — context bookkeeping error), and a tonk-like overgeneralization arising from anti-unifying too aggressively.
3. Coherence oracle: the learner knows the empty context is consistent (it should not be able to derive |- bottom) and that some contingent premise sets are satisfiable (positions [assert Gamma] that are coherent), and gets truth-table world feedback only on SOME atoms-valuations (sparse). Implement coherence pruning: forward-chain/prove with learned rules from coherent premise sets to search for |- bottom (negative bags), then remove the minimal set of rules (minimal hitting set over bags, preferring removal of rarely-supported rules).
4. POST-COMPLETENESS EXPERIMENT: implement a 'bold' learner that adds schematic rules as long as they remain coherent (no derivation of bottom from the empty context within a search budget) and check empirically that any schematic rule/axiom not derivable in classical logic makes the empty context derive bottom (or at least makes everything derivable) — exhibit the derivations found for several candidate extra schemas (e.g. p -> q, ((p->q)->p)->p already derivable so harmless, p | q -> p, etc.). Contrast with an intuitionistic target: show that adding excluded middle to intuitionistic ND is coherent but changes the logic (so coherence cannot pin down IPC from above).
5. Measure soundness against an ADVERSARIAL prover (a search that tries to derive non-tautologies or bottom using the learned verifier) and completeness (fraction of random tautologies up to size k proved within a budget) for: version-space learner, + coherence pruning, as functions of #human proofs and noise. Results to results/prop_learning.json/.md.
Return the structured summary.`, { label: 'prop-domain', phase: 'Domains', schema: SUM }),
  () => agent(`${CTX}

The foundation package already exists (read the code in ${CODE}/cil first). API notes from its author:
${infra ? infra.api_notes : '(not available: read the code)'}

TASK C (the central negative experiment: average-case-accurate learned verifiers get exploited by search; conservative rule-learned verifiers do not). Use the ALGEBRA domain. Build experiments/exp_adversarial_prover.py (+ any cil modules needed, e.g. cil/baselines.py, cil/provers.py):
1. A STATISTICAL baseline verifier mimicking a process reward model: features of a step (e.g. bag of subterm-shape n-grams of before/after, size changes, symbol counts, tree-edit features), trained on human positive steps vs. negatives made by random perturbations (and optionally vs. a sample of known fallacies), using logistic regression and gradient boosting / random forest (scikit-learn). Report its in-distribution accuracy on held-out human-like valid/invalid steps (should be high).
2. An ADVERSARIAL PROVER: best-first / beam search over rewrite steps (generated from a broad proposal distribution: target rules, fallacy rules, random rewrites) where a step is allowed iff the verifier under test accepts it (for the statistical verifier: score above a threshold calibrated to e.g. 99% precision in-distribution). Goals: derive FALSE equations (e.g. 1 = 2, x = x+1, (a+b)^2 = a^2+b^2 for a target that does not license it), and TRUE target identities.
3. Compare verifiers: (a) statistical baseline at several thresholds, (b) conservative version-space/LGG verifier from cil.learners, (c) the same plus coherence/world-feedback pruning, (d) ground-truth target calculus. Metrics: number of false equations derived per search budget, time-to-first-false-proof, true identities proved. Show that the baseline, despite high in-distribution accuracy, lets the adversarial prover reach false conclusions, while the conservative learned calculus does not (and quantify productivity).
4. Also a 'Goodhart curve': in-distribution precision of the baseline vs. probability that a search of budget B finds a false proof, as B grows.
Results: results/adversarial_prover.json/.md (+ PNG plots if helpful). Return the structured summary.`, { label: 'adversarial-prover', phase: 'Domains', schema: SUM }),
])

phase('Review')
const review = await agent(`${CTX}

TASK D (independent review). Review all code in ${CODE} written by previous agents. (1) Run the full test suite and every experiment script from scratch; confirm results regenerate and match the reports in code/results/. (2) Look adversarially for bugs that would invalidate the reported conclusions: leakage of ground truth into learners, verifiers that accidentally consult the target calculus, wrong soundness checks (e.g. numerical evaluation errors, guard handling, undefined values treated as equal), cherry-picked seeds, unfair baselines (e.g. a statistical verifier made deliberately weak), and claims in reports that the numbers do not support. (3) Fix real bugs you find (minimal, well-commented fixes), re-run, and update the reports. (4) Write code/README.md documenting the package, how to run everything, and a table of the main results with honest caveats. Return a structured summary listing bugs found/fixed and the final key results.`, { label: 'review', phase: 'Review', schema: SUM })

return { infra, domains, review }
