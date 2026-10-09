export const meta = {
  name: 'axiom-induction-applied',
  description: 'Bayesian axiom induction: PA/ZF and experiments tracks, each developed, adversarially refereed and revised',
  phases: [
    { title: 'Develop', detail: 'one researcher per track writes notes, code and checks' },
    { title: 'Referee', detail: 'adversarial referee with independent code' },
    { title: 'Revise', detail: 'fix issues, align with other tracks, final record' },
  ],
}

const ROOT = '/home/user/AI-works/axiom-induction'
const COMMON = `You are working on a research project in ${ROOT}. First read ${ROOT}/research/00-brief.md in full, and the notes it points to (Hänni's notes in ${ROOT}/research/prior/, and the relevant parts of ../axiom-schemas and ../inferential-learning that the brief names). Rules: write only inside your track folder (given below; the experiments track also owns ${ROOT}/code); do not run git commands that change repository state (no add/commit/checkout/stash/reset); use python3 (seeded, outputs saved next to scripts); mark every claim proved / computed / conjecture / known (with exact reference) / proof sketch / refuted; give full proofs for "proved"; never claim more than you establish; plain, precise prose, short sentences. Other tracks run in parallel: model (${ROOT}/research/tracks/model), universal (${ROOT}/research/tracks/universal), pa (${ROOT}/research/tracks/pa), experiments (${ROOT}/research/tracks/experiments and ${ROOT}/code).`

const TRACKS = [
  { key: 'pa', prompt: `Track "pa" (folder ${ROOT}/research/tracks/pa; scripts in its checks/ subfolder). Deliverable: notes.md. Brief H7: PA, ZF and "the axioms we actually have". Use the likelihood family of the brief (H1: L0 citation, L1 derivation grammar, bounded derivations); define precisely what you use.
1. Equivalent axiomatisations under a derivation likelihood: which does the posterior favour, and why? Work out concrete comparisons with explicit likelihood or code-length computations (small scripts welcome): (a) Q + induction vs Q + strong (course-of-values) induction vs Q + the least number principle — check the exact base theory over which they are equivalent (cite, e.g., Kaye 1991 or Hájek–Pudlák; verify); (b) ZF: Replacement vs Collection (equivalent over ZF, not over weaker bases — check and cite), Foundation vs ∈-induction (check exactly what is needed), Separation as derivable from Replacement. For each, state when "the textbook axioms" win and when another axiomatisation wins, as a function of the data distribution.
2. Revisit the MDL finding of ../axiom-schemas (paper/sections/many.tex sec:many:mdl and its appendix in app-many.tex): "MDL tracks the statistics of usage, not the logical boundaries of schemas" (a naive code splits T_Ind by the main connective of the motive). Does a derivation likelihood or a well-specified instantiation grammar change this? Exact code-length comparisons.
3. Data from Th(ℕ) (true sentences under some distribution): no r.e. theory is well specified. Show what the posterior does (drift toward stronger theories?) and relate to the IΣₙ chain discussed earlier (../axiom-schemas/research/conversation.md §§7–10; ../axiom-schemas/research/prior/pa-untagged/). What is the right notion of success then?
4. Unlabelled mixtures: a Bayesian version of DTRC (posterior over finite unions of templates). Spare slots, fragmentation, sound merges (∀xφ as a merge), and the role of negative data / refutation (likelihood 0 for theories deriving a refuted sentence; Hänni's "does not contradict" variant). Does the posterior recover Q + Ind (or a deductive equivalent) from unlabelled data, and with how much mass?
5. Robust failures: where does the method fail, and is the failure fixable?` },
  { key: 'experiments', prompt: `Track "experiments" (notes in ${ROOT}/research/tracks/experiments/notes.md; code in ${ROOT}/code). Implement a Bayesian template-theory inducer and test the brief's hypotheses empirically.
Code: a Python package ${ROOT}/code/bai ("Bayesian axiom induction") reusing ../axiom-schemas/code/dtrc via sys.path (read its README; do not modify that package — copy a module if you must change it). Components: (1) a theory = list of DT°_F templates and sentences; prior = description length in bits under an explicit code, optional time factor. (2) Likelihoods: L0 citation — because DT° matching is unique, P(σθ = d) = Q(θ) is exactly computable from a probabilistic grammar Q over terms and formulas; mixture weights Dirichlet-integrated; L1 a bounded derivation grammar: cite an axiom, ∀-elim with a term from Q, MP with a cited conditional, Gen — exact sum over derivations up to a fixed depth (say which). (3) A candidate pool generated from the data (Min/lgg of data subsets and of DTRC clusters) plus hand-specified alternatives (H_∀, H_sch, H_open, memorisation, over-general, over-specific, fragmented, spare-slot theories). (4) The posterior by exact enumeration over the pool — state this restriction honestly. (5) The threshold verifier: accept s iff Σ_{T ⊢ s} π(T|D) ≥ 1−δ with bounded derivability.
Experiments (seeded; results in ${ROOT}/code/results/*.md and *.json; figures optional): E1 ∀xφ posterior dynamics for several φ, with data from an H_sch generator, an H_∀ generator, and a generator that also emits quantified theorems; report posterior masses vs n and P(T ⊢ ∀xφ | D). E2 PA mixture (Q axioms + induction instances), unlabelled: posterior over the pool (true, fragmented, over-general, spare-slot, equivalent); mass on the true or a deductively equivalent theory vs n. E3 misspecification: the data generator differs from the model (heavy-tailed term sizes, selected theorems, a different instantiation grammar): robustness. E4 adaptive prover vs threshold verifier: empirical soundness against the Ville bound, well-specified vs misspecified. E5 Gold: spare-slot / L∞-vs-L₅ curves. E6 (optional) equivalent axiomatisations under L1. Write unit tests (code/tests). Notes: tables, exact commands, seeds, honest limitations.` },
]

const DEV_SCHEMA = { type: 'object', properties: {
  summary: { type: 'string' },
  claims: { type: 'array', items: { type: 'object', properties: { id: { type: 'string' }, statement: { type: 'string' }, status: { type: 'string' } }, required: ['id', 'statement', 'status'] } },
  open_problems: { type: 'array', items: { type: 'string' } },
}, required: ['summary', 'claims'] }

const REF_SCHEMA = { type: 'object', properties: {
  verdict: { type: 'string' },
  fatal: { type: 'number' }, major: { type: 'number' }, minor: { type: 'number' },
  issues: { type: 'array', items: { type: 'object', properties: { id: { type: 'string' }, severity: { type: 'string' }, claim: { type: 'string' }, problem: { type: 'string' } }, required: ['severity', 'claim', 'problem'] } },
}, required: ['verdict', 'issues'] }

const REV_SCHEMA = { type: 'object', properties: {
  summary: { type: 'string' },
  resolved: { type: 'array', items: { type: 'string' } },
  unresolved: { type: 'array', items: { type: 'string' } },
  key_results: { type: 'array', items: { type: 'string' } },
}, required: ['summary', 'key_results'] }

const notesPath = k => k === 'experiments' ? `${ROOT}/research/tracks/experiments` : `${ROOT}/research/tracks/${k}`

const results = await pipeline(
  TRACKS,
  t => agent(`${COMMON}\n\n${t.prompt}\n\nReturn a structured summary: what you established (claims with status) and the open problems.`, { label: `develop:${t.key}`, phase: 'Develop', schema: DEV_SCHEMA }),
  (dev, t) => agent(`${COMMON}\n\nYou are an ADVERSARIAL REFEREE for track "${t.key}" (notes in ${notesPath(t.key)}${t.key === 'experiments' ? `, code in ${ROOT}/code` : ''}). Read the brief, then the track's notes.md and code/scripts. Try to refute every claim marked proved or computed: check proofs line by line; ${t.key === 'experiments' ? 're-run the experiments and tests; check that the implemented likelihoods and priors are the ones described and correctly normalised (write independent reimplementations of the key probability computations and compare); check for bugs, leakage between training and held-out data, cherry-picked seeds, and conclusions stronger than the numbers;' : 'check equivalence claims against the literature and by explicit derivations; check code-length computations with independent code;'} write INDEPENDENT code in ${notesPath(t.key)}/referee_code/; check that every cited reference exists and says what is claimed (use web search if you can load it via ToolSearch; otherwise flag as unverified). Also say what important questions from the brief the track missed. Write ${notesPath(t.key)}/referee.md: issues with severity fatal / major / minor, the claim, the problem, the evidence (counterexample, script and output), a suggested fix; and a list of claims you checked and confirmed. Be strict: default to skepticism. Do not edit the track's notes or code.`, { label: `referee:${t.key}`, phase: 'Referee', schema: REF_SCHEMA }),
  (ref, t) => agent(`${COMMON}\n\nRevise track "${t.key}" (notes in ${notesPath(t.key)}${t.key === 'experiments' ? `, code in ${ROOT}/code` : ''}) after the referee. Read notes.md and referee.md (and the referee's code). Fix every fatal and major issue (in notes and${t.key === 'experiments' ? ' code, re-running affected experiments and tests' : ' scripts'}), or show precisely, with evidence, why the referee is wrong; handle minor issues. Keep refuted claims, marked refuted, with the counterexample. Then read the other tracks' current notes (notes-final.md if it exists, else notes.md) in ${ROOT}/research/tracks/{model,universal,pa,experiments} and align definitions and notation where you can; add a section "Cross-track consistency" listing remaining differences. Write ${notesPath(t.key)}/notes-final.md: the complete, self-contained final record (do not just list changes), ending with a "Verification log" mapping each referee issue to its resolution and listing every check with its result. Do not delete notes.md.`, { label: `revise:${t.key}`, phase: 'Revise', schema: REV_SCHEMA }),
)
return results.map((r, i) => ({ track: TRACKS[i].key, result: r }))
