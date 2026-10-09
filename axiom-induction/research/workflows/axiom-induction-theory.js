export const meta = {
  name: 'axiom-induction-theory',
  description: 'Bayesian axiom induction: model and ∀xφ tracks, each developed, adversarially refereed and revised',
  phases: [
    { title: 'Develop', detail: 'one researcher per track writes notes and checks' },
    { title: 'Referee', detail: 'adversarial referee with independent code' },
    { title: 'Revise', detail: 'fix issues, align with other tracks, final record' },
  ],
}

const ROOT = '/home/user/AI-works/axiom-induction'
const COMMON = `You are working on a research project in ${ROOT}. First read ${ROOT}/research/00-brief.md in full, and the notes it points to (Hänni's notes in ${ROOT}/research/prior/, and the relevant parts of ../axiom-schemas and ../inferential-learning that the brief names). Rules: write only inside your track folder (given below); do not run git commands that change repository state (no add/commit/checkout/stash/reset); use python3 for checks (seeded, outputs saved next to scripts); mark every claim proved / computed / conjecture / known (with exact reference) / proof sketch / refuted; give full proofs for "proved"; never claim more than you establish; plain, precise prose, short sentences. Other tracks run in parallel: model (${ROOT}/research/tracks/model), universal (${ROOT}/research/tracks/universal), pa (${ROOT}/research/tracks/pa), experiments (${ROOT}/research/tracks/experiments and ${ROOT}/code).`

const TRACKS = [
  { key: 'model', prompt: `Track "model" (folder ${ROOT}/research/tracks/model; scripts in its checks/ subfolder). Deliverable: notes.md. Develop the general theory of a good Bayesian/Solomonoff-style axiom inducer (brief H1, H2, H3, H5, H6, and the relations to Hänni's note).
1. Definitions. (a) Theory class: finite sets of templates from DT° (and the subclasses FO, PAT); a sentence is a template without metavariables. Fix a background calculus (say which: Hilbert-style with MP and Gen, or rules MP, ∀-elim, Gen) and its relation to the closure-normal form of ../axiom-schemas. (b) Prior: description length of templates under an explicit prefix code, with an optional time factor (Levin Kt style). (c) Likelihood family, each with an explicit formula and normalisation: L0 pure axiom citation with per-template instantiation distributions from a probabilistic grammar Q and mixture weights (Dirichlet-integrated); L1 a derivation grammar (branching process: cite an axiom or apply a rule; give the subcriticality condition for a proper distribution); L2 bounded-depth derivations; and the two variants in Hänni's note ("proves the givens" and "does not contradict") expressed as scores. Say which give the size principle and why (normalisation independent of the data).
2. Consistency and identification. Exact theorem: i.i.d. data from P_{T*}, countable class, π(T*)>0 ⇒ posterior concentrates on {T : P_T = P_{T*}} a.s. (Doob, or a direct proof). Rates via KL where possible. Identification is of the generator: give two deductively equivalent theories with different P_T under L1, and characterise when P_T = P_{T'} under L0 (e.g. same template set up to renaming and same weights?).
3. Misspecification: the KL-projection result (Berk 1966; Kleijn & van der Vaart 2006 — verify) and an explicit example where all data are theorems of T* yet the KL-minimiser is not deductively equivalent to T*.
4. Soundness against adaptive provers: adapt the Ville argument of ../inferential-learning (paper/sections/app-caution.tex, thm:caution:ville and lem:app:caution:ville; cite exact labels, reuse, don't re-derive more than needed) to the thresholded verifier "accept s iff Σ_{T ⊢ s} π(T|D) ≥ 1−δ" (bounded derivability allowed). State exact hypotheses (well-specification!), prove, and give a misspecified counterexample in which an adaptive prover gets a non-T* sentence accepted with high probability. Relate to the cautious verifier (δ→0 limit) and to anchors.
5. Positive data and Gold: identification in the limit with probability 1 for finite unions of DT° templates under L0/L1 (exact conditions); spare slots: marginal-likelihood penalty with Dirichlet weights (≈ ½ log n bits?) plus prior bits; why the Bayesian needs no bound on the number of schemas while ../axiom-schemas proves a bound necessary for the cautious learner, and what it gives up. Relate to L∞ vs L₅ (conversation §9 in ../axiom-schemas/research/conversation.md).
6. Time penalty and Hänni's collapse: state his equivalence precisely (axiom induction requiring proofs over decidable axiom sets ≈ Solomonoff function induction over consistent assigners, via the schema "A(⌜φ⌝)=accept → φ"); check it (what background theory is needed? is the constant overhead right? does consistency hold as he argues?). Then: what do templates do (can a DT° template or finite union encode an arbitrary assigner? prove a limitation), and what does a time penalty on axiom-membership checking do to the collapse schema. Aim for a clean theorem, or say precisely why none holds.
7. The trichotomy true/false/independent: define P(T ⊢ s | D), P(T ⊢ ¬s | D), P(independent | D); which probability axioms they satisfy; Hänni's renormalise vs 50/50 question.
8. A short general statement of the predictive-versus-deductive gap (track "universal" does the ∀xφ details; keep yours general).
Write small scripts to sanity-check formulas numerically.` },
  { key: 'universal', prompt: `Track "universal" (folder ${ROOT}/research/tracks/universal; scripts in its checks/ subfolder). Deliverable: notes.md. The ∀xφ case in depth (brief H4) — this is the heart of the user's question.
1. Setup: arithmetic language, φ(x) quantifier-free first (examples: 0+x=x, x+0=x, x·0=0, Sx≠0, x<Sx), then general φ. Hypotheses: H_∀ = {∀xφ}; H_sch = instance schema φ(z) with z ranging over closed terms; H_open = φ(z) with z also ranging over open terms/parameters (with Gen in the calculus); memorisation of the data; over-specific templates (e.g. the first-order lgg of numeral instances, φ(Sz)); over-general templates (formula metavariables, templates identifying fewer positions); and these combined with other axioms (e.g. Q). Likelihood variants: L0 citation only; L1 derivation grammar where ∀-elim with a term from Q has probability c; bounded derivations; "statements given without proof should be easily derivable".
2. For each variant compute the posterior odds between hypotheses as functions of n, the data distribution and the prior; exact closed forms where possible; rates.
3. Prove or refute: (a) mass leaves memorisation and over-general templates exponentially fast (size principle); (b) instance-only data do not move the odds H_∀ : H_sch toward H_∀ (constant under L0-type, or moving toward H_sch by c^{-n} under L1) — formalise; (c) predictive confirmation: P(next datum is a φ-instance | D) → 1 and P(all future data are φ-instances | D) → 1 — compare Hutter (2007), "On universal prediction and Bayesian confirmation" (verify the reference and what it proves); (d) yet P(T ⊢ ∀xφ | D) need not → 1: a Bayesian ω-gap, exact statement; (e) with open instances and Gen, H_open ⊢ ∀xφ, and conditions under which P(T ⊢ ∀xφ | D) → 1; (f) data containing quantified theorems whose short derivations use ∀xφ shift mass to theories proving ∀xφ — quantify.
4. Truth vs derivability: ../axiom-schemas Question 1 (universal.tex, app-universal.tex): the ω-gap, M₀ ≼ M, Q ⊬ ∀x(0+x=x) though every closed instance is Q-provable. What should a Bayesian believe about ∀xφ when the data are true closed instances? What do Hänni's two variants ("proves the givens" / "does not contradict") do here?
5. The user's intuition ("∀xφ is a simple law which implies all the other statements, so once we see them we should up its probability; still entertain other hypotheses"): say precisely in what sense it is right and where it needs refinement.
6. Numerical checks with scripts (exact posterior computations for small hypothesis sets).` },
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

const results = await pipeline(
  TRACKS,
  t => agent(`${COMMON}\n\n${t.prompt}\n\nReturn a structured summary: what you established (claims with status) and the open problems.`, { label: `develop:${t.key}`, phase: 'Develop', schema: DEV_SCHEMA }),
  (dev, t) => agent(`${COMMON}\n\nYou are an ADVERSARIAL REFEREE for track "${t.key}" (folder ${ROOT}/research/tracks/${t.key}). Read the brief, then ${ROOT}/research/tracks/${t.key}/notes.md and its scripts. Try to refute every claim marked proved or computed: check each proof line by line; look for hidden hypotheses, wrong normalisations, wrong limits, quantifier errors, and claims stronger than the proof; write INDEPENDENT code in ${ROOT}/research/tracks/${t.key}/referee_code/ to test claims numerically and to search for counterexamples; check that every cited reference exists and says what is claimed (use web search if you can load it via ToolSearch; otherwise flag as unverified). Also say what important questions from the brief the track missed. Write ${ROOT}/research/tracks/${t.key}/referee.md: issues with severity fatal / major / minor, the claim, the problem, the evidence (counterexample, script and output), a suggested fix; and a list of claims you checked and confirmed. Be strict: default to skepticism. Do not edit notes.md.`, { label: `referee:${t.key}`, phase: 'Referee', schema: REF_SCHEMA }),
  (ref, t) => agent(`${COMMON}\n\nRevise track "${t.key}" (folder ${ROOT}/research/tracks/${t.key}) after the referee. Read notes.md and referee.md (and the referee's code). Fix every fatal and major issue, or show precisely, with evidence, why the referee is wrong; handle minor issues. Keep refuted claims, marked refuted, with the counterexample. Then read the other tracks' current notes (notes-final.md if it exists, else notes.md) in ${ROOT}/research/tracks/{model,universal,pa,experiments} and align definitions and notation where you can; add a section "Cross-track consistency" listing remaining differences. Write ${ROOT}/research/tracks/${t.key}/notes-final.md: the complete, self-contained final record (do not just list changes), ending with a "Verification log" mapping each referee issue to its resolution and listing every check with its result. Do not delete notes.md.`, { label: `revise:${t.key}`, phase: 'Revise', schema: REV_SCHEMA }),
)
return results.map((r, i) => ({ track: TRACKS[i].key, result: r }))
