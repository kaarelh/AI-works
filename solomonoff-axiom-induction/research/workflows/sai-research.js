export const meta = {
  name: 'sai-research',
  description: 'Research for a paper on Solomonoff axiom induction: six scouts (fundamentals, SFI relation, philosophy, literature, two on new directions), a lead selects 5-7 threads, each developed, refereed twice and revised; synthesis with a paper plan; fresh final check',
  phases: [
    { title: 'Explore', detail: 'six scouts: fundamentals, sfi, philosophy, literature, novel-logic, novel-science' },
    { title: 'Select', detail: 'lead picks 5-7 threads, writes their briefs, shared notation and a preliminary outline' },
    { title: 'Develop', detail: 'one developer per thread' },
    { title: 'Referee', detail: 'two adversarial referees per thread (proofs + code, or philosophy + formal accuracy)' },
    { title: 'Revise', detail: 'final records with cross-thread consistency' },
    { title: 'Synthesis', detail: 'headline results, philosophy argument map, SFI table, paper plan; fresh final check' },
  ],
}
const ROOT = '/home/user/AI-works/solomonoff-axiom-induction'
const R = `${ROOT}/research`
const SC = `${R}/scouts`
const TR = `${R}/tracks`
const COMMON = `Research project in ${ROOT}: a paper on Solomonoff axiom induction (working name; the final name is undecided, so never build an argument on the name). Read the brief ${R}/00-brief.md in full first: it quotes the author's request verbatim and lists the sources: the author's notes (copies in ${R}/prior/, including hanni-condensation-concepts.md; the full notes repository is at /home/user/kaarelh/notes), the earlier report ../axiom-induction (paper/main.pdf and paper/sections, refereed records research/tracks/*/notes-final.md), ../axiom-schemas, and the two Solomonoff function induction (SFI) papers ../solomonoff-function-induction/paper and ../solomonoff-function-induction/paper-steeper (notation: ../solomonoff-function-induction/paper/NOTATION.md). Paths starting with ../ are relative to ${ROOT}. Conventions (from the brief): a status on every claim (proved, with a full proof; computed, with script and saved output; known, with an exact verified reference; proof sketch; conjecture; refuted, kept with its counterexample), seeded code with outputs saved next to each script, plain precise prose, a Verification log at the end of each record, no git commands that change repository state. Write only in your folder (given below). WebSearch works; arxiv.org, Google Docs and lesswrong.com cannot be fetched directly (search results and other mirrors are fine).`
const SCOUTS = [
  { key: 'fundamentals', prompt: `You are SCOUT F (fundamentals); folder ${SC}/fundamentals. Goal: the definitions and basic theorems the paper needs, in a form parallel to SFI Paper 1.
(1) Inventory what the earlier report ../axiom-induction and its track records already define and prove that the new paper needs (exact pointers: theorem numbers in ../axiom-induction/paper and sections of the track records), and the definitions in the author's note ${R}/prior/hanni-solomonoff-axiom-induction.md (proof-requiring and consistency-requiring variants; the true / false / independent trichotomy).
(2) Propose a primary definition analogous to SFI's one-tape definition: a universal machine reads one random tape and enumerates a set of axioms in a fixed first-order language, giving a random r.e. theory; data are sentences labelled true or false; condition on the theory proving the true ones and refuting the false ones (proof-requiring), or on consistency with them (consistency-requiring). Also its coin-free version (2^{-|p|} on programs enumerating axioms) and a Kolmogorov version (shortest axiomatisation compatible with the data). State precisely what the predictive probabilities of "φ is true", "φ is false" and "independent" are, and how the generative (derivation-likelihood) variant of the earlier report fits.
(3) For each basic property give a first-pass proof, sketch, counterexample or quick computation: well-definedness and the semimeasure deficit; dominance over every computable "theory machine"; invariance under change of universal machine; relations among the versions (does Paper 1's log d gap between the Kolmogorov and semimeasure versions recur for axioms, or does a coding theorem hold here?); loss bounds for predicting the truth values of an arbitrary (adversarial) sequence of sentences relative to a theory that decides them (the analogue of SFI's K(ν) bound; which complexity appears: of the axiom set, of the theory up to equivalence?); behaviour in the limit on data from a fixed r.e. theory, from a complete theory such as Th(N) or the theory of a computable structure, and from an incomplete theory; what is identified (the theory up to deductive equivalence?) and what is not; how the trichotomy behaves.
(4) A ranked list of candidate fundamentals theorems with assessments (true? hard? new?), and a recommended set of definitions with notation. Deliverable ${SC}/fundamentals/notes.md.` },
  { key: 'sfi', prompt: `You are SCOUT S (relation to SFI and time bounds); folder ${SC}/sfi.
(1) Inventory precisely the relation results in ../axiom-induction (its Section 6 and the track records universal, time-followup and short-derivations): the Craig-trick equivalence of proof-requiring axiom induction with consistent function induction; the one-sided equivalence under time penalties on checking or generating axioms; the diagonal separation with free deduction; charging deduction (short certificates: NP ∩ coNP; per-instance: EXPTIME; only the theory's own axioms: no limit). Give exact statements, constants and hypotheses.
(2) Map them onto the SFI papers' current definitions (M_F with one shared random tape, the coin-free W, K_F; consistent labellers; time-bounded and circuit SFI in Paper 1 Section 9). Which equivalence holds for which pair of versions (one-tape random axiom enumerations versus M_F restricted to consistent labellers? W-type versus W-type?), with what overhead; where the earlier report's statements need restating; whether anything breaks (shared randomness across sentences; partial functions versus r.e. theories; the "independent" label).
(3) The theoretician's-dilemma reading: Craig's theorem and Hempel's dilemma say theoretical vocabulary is eliminable in principle, and the classical reply is that Craigian axiomatisations are useless in practice. The time-bounded separations may make that reply precise. Work out what exactly can be proved: a clean statement and a first-pass proof or sketch.
(4) Candidate new results on the relation, ranked, with first-pass attempts, and a clean draft table of the equivalences and separations for the paper. Deliverable ${SC}/sfi/notes.md.` },
  { key: 'philosophy', prompt: `You are SCOUT P (philosophy); folder ${SC}/philosophy. Read every note in ${R}/prior/, including hanni-condensation-concepts.md (the author's essay on what concepts are), and browse /home/user/kaarelh/notes (philosophy/philosophy of science, philosophy/prediction, philosophy/concepting, ai/learning/solomonoff induction). Produce:
(1) An argument map for the paper's philosophy section. The problems axiom induction tries to make progress on: what a scientific theory is and what it does. The axiom view: a theory answers questions stated in an existing language; it explains propositions; it is a logical theory, not an arbitrary program. Why this is progress over raw-data prediction, both in what a theory does (answering questions versus pixel prediction) and in what a theory is (a logical theory versus a program).
(2) A worked toy example with Kepler's laws: a concrete first-order language (bodies, times, positions or orbital elements, periods), the axioms, which sentences are the data, what is explained and how, where only approximate truth holds and by how much, and what Newton adds. Make it concrete enough to serve as a running example, and say which parts could be computed.
(3) The limitations, each stated sharply with its source in the notes. They include: written theories are far from sufficient for a simple reasoner (the textbook point; "our science is very human software"); approximate truth and domains of applicability; science predicts only very particular things; the condensation essay's list of what concepts do (recognizers, purposes, softness and meaning change, methods, concepts built from pointers, ...), and how much of it the axiom view misses; others you find. For each, say whether it is partially addressable formally (a candidate research question) or a genuine limit.
(4) The philosophy-of-science literature the section must engage: the syntactic versus semantic view of theories; deductive-nomological explanation and unification (Friedman, Kitcher); Craig's theorem, Ramsey sentences and Hempel's theoretician's dilemma; the Mill–Ramsey–Lewis best-system account of laws (simplicity versus strength); verisimilitude and approximate truth; Cartwright; tacit knowledge (Polanyi) and Kuhn's exemplars; Carnap; anything else relevant. Give exact bibliographic data verified by WebSearch and one or two sentences each on the relation.
(5) A ranked list of formal questions the philosophy suggests.
Write in your own words; this is research material, not paper text. Deliverables ${SC}/philosophy/notes.md and ${SC}/philosophy/refs.bib.` },
  { key: 'literature', prompt: `You are SCOUT L (formal literature and novelty check); folder ${SC}/literature. Using WebSearch, verify exact bibliographic data and read at least the abstracts of the formal neighbours of axiom induction; for each, write what it does and the precise difference from the axiom inducers of the brief. Cover: Solomonoff, Levin, Hutter (universal induction; Rathmanner and Hutter 2011); probabilities on sentences (Gaifman 1964; Gaifman and Snir 1982; Hutter, Lloyd, Ng and Uther 2013; Demski 2012 on logical prior probability; Christiano 2014 on non-omniscience; Garrabrant et al. on logical induction); formal learning theory of theories and inquiry (Gold 1967; Putnam 1965 on trial-and-error predicates; Shapiro 1981 on model inference; Osherson, Stob and Weinstein; Martin and Osherson 1998; Kelly 1996); inductive logic programming (Muggleton; Plotkin's least general generalisation; Muggleton and De Raedt 1994; compression and MDL for logic programs); Bayesian theory learning in cognitive science (Kemp, Goodman and Tenenbaum; Ullman, Goodman and Tenenbaum 2012 on theory learning as stochastic search in a language of thought); program synthesis of theories (DreamCoder, AI Feynman), briefly; Chaitin's information-theoretic incompleteness and the Kolmogorov complexity of theories; Craig 1953 and 1956; anything else close (search for "Solomonoff" together with "axioms", "theories", "first-order", "logical sentences").
Then a NOVELTY CHECK: for each candidate result in the brief's seed ideas and each main theorem of ../axiom-induction, say whether it, or something close, is already known, with references.
Also check whether the names "Solomonoff axiom induction", "Solomonoff function induction", "universal axiom induction", "universal theory induction" and "Solomonoff theory induction" are already used in the literature, and for what.
Deliverables ${SC}/literature/notes.md and ${SC}/literature/refs.bib (only verified entries, each with a comment saying how it was verified).` },
  { key: 'novel-logic', prompt: `You are SCOUT N1 (new directions: logic and computability); folder ${SC}/novel-logic. Brainstorm at least ten candidate directions for new results about axiom induction. Start from, but do not stop at, the brief's seed ideas:
* theoretical terms and succinctness: can a simplicity prior over theories in an extended language, with data only in the observational language, provably prefer theories with theoretical terms because they compress? Consider succinctness of definitional or conservative extensions, Ramsey sentences, and known speed-up and succinctness results;
* randomised axiom systems, and whether SFI's Kolmogorov/semimeasure gaps recur;
* learning first-order theories in the limit: what the posterior does on data from Th(N), from a computable structure, from an incomplete theory;
* the Bayesian ω-gap of the earlier report, and whether it disappears in some version;
* Gödel phenomena: what is the posterior on a Gödel sentence or on Con(T) given data from T?;
* the proof-requiring versus consistency-requiring variants: when do they differ?;
* question-answering power versus predictive power as formal notions;
* anything else you find.
For each: a precise statement; a first-pass attempt (proof sketch, counterexample, or small computation); an assessment of truth, difficulty, novelty, and how cool it is for this paper. Then push the four most promising as far as you can, with full proofs where feasible. Deliverable ${SC}/novel-logic/notes.md, with a ranked list at the top.` },
  { key: 'novel-science', prompt: `You are SCOUT N2 (new directions: formalising the philosophy of science); folder ${SC}/novel-science. Brainstorm at least ten candidate directions for theorems that make the paper's philosophical claims precise. Start from, but do not stop at, the brief's seed ideas:
* approximate theories: data as approximate propositions, intervals or tolerances. Look for a precision-dependent selection theorem: the simpler approximate theory (Kepler) is preferred until the data's precision exceeds its error, and the more exact one (Newton) after that. Also domains of applicability;
* laws versus initial conditions: transfer SFI Paper 2's model–randomness split and kink geometry. A steeper prior should separate laws, reused across many data, from contingent facts such as orbital elements;
* theories for bounded reasoners: with a derivation-length or time budget, the induced theory must contain lemmas or know-how, not only the physical picture. Quantify the trade-off between axiom compression and usability, and relate it to the earlier report's short-derivations results;
* explanation: deductive-nomological explanation as derivation from the induced axioms; unification; an explanatory-power measure, such as bits of data explained per bit of axiom, or the kink slope;
* the best-system account of laws (Lewis: a balance of simplicity and strength) as the steeper-prior MAP;
* a formal separation showing that answering questions in a fixed language is a different task from predicting raw data. For example, a family of worlds where the raw-data predictor needs many more bits than the theory, or where the theory's answers cannot be extracted from a good raw-data predictor without extra search;
* the trichotomy as the source of humility: a theory that is silent on questions it cannot answer;
* anything else.
For each: a precise statement; a first-pass attempt (proof sketch, counterexample, or small computation with seeded code); an assessment of truth, difficulty, novelty, coolness and relevance to the philosophical aims. Then push the four most promising as far as you can. Deliverable ${SC}/novel-science/notes.md, with a ranked list at the top.` },
]
const SCOUT = { type: 'object', properties: { summary: { type: 'string' }, top_candidates: { type: 'array', items: { type: 'object', properties: { name: { type: 'string' }, statement: { type: 'string' }, status: { type: 'string' }, assessment: { type: 'string' } }, required: ['name', 'statement', 'status'] } } }, required: ['summary'] }
const SEL = { type: 'object', properties: { rationale: { type: 'string' }, threads: { type: 'array', items: { type: 'object', properties: { key: { type: 'string' }, title: { type: 'string' }, kind: { type: 'string', enum: ['math', 'phil'] } }, required: ['key', 'title', 'kind'] } } }, required: ['rationale', 'threads'] }
const DEV = { type: 'object', properties: { summary: { type: 'string' }, claims: { type: 'array', items: { type: 'object', properties: { id: { type: 'string' }, statement: { type: 'string' }, status: { type: 'string' } }, required: ['id', 'statement', 'status'] } }, open_problems: { type: 'array', items: { type: 'string' } } }, required: ['summary', 'claims'] }
const REF = { type: 'object', properties: { verdict: { type: 'string' }, issues: { type: 'array', items: { type: 'object', properties: { severity: { type: 'string' }, claim: { type: 'string' }, problem: { type: 'string' } }, required: ['severity', 'claim', 'problem'] } } }, required: ['verdict', 'issues'] }
const REV = { type: 'object', properties: { summary: { type: 'string' }, key_results: { type: 'array', items: { type: 'string' } }, unresolved: { type: 'array', items: { type: 'string' } } }, required: ['summary', 'key_results'] }

phase('Explore')
const RESUMED = ['sfi', 'philosophy']
const scouts = await parallel(SCOUTS.map(s => () => agent(`${COMMON}\n\n${s.prompt}${RESUMED.includes(s.key) ? `\n\nAn earlier run of this task was interrupted. Partial records may already be in ${SC}/${s.key}/ (notes, scripts, outputs): read them first, check them, keep what is sound, and complete the task; re-run any script whose saved output is missing or incomplete.` : ''}\n\nReturn a short summary and your top candidates with statuses.`, { label: `scout:${s.key}`, phase: 'Explore', schema: SCOUT })))
const missing = SCOUTS.filter((s, i) => !scouts[i]).map(s => s.key)
if (missing.length) log(`Scouts that returned nothing: ${missing.join(', ')}`)

phase('Select')
const sel = await agent(`${COMMON}\n\nYou are the LEAD RESEARCHER selecting the research threads. Read the six scout records ${SC}/{fundamentals,sfi,philosophy,literature,novel-logic,novel-science}/notes.md in full${missing.length ? ` (these scouts failed and may have partial or no records: ${missing.join(', ')})` : ''}, and their sources as needed. Choose 5 to 7 research threads for the paper.
Required threads:
* "fundamentals" (kind math): definitions and basic theorems;
* "sfi" (kind math): the relation to SFI, including the time-bounded equivalences and separations restated and re-verified in the paper's notation, plus whatever is new;
* "philosophy" (kind phil): the argument map, the worked Kepler example and the limitations analysis, with any formal results that support them.
Add 2 to 4 threads for the most promising new directions. Prefer results that are (a) likely true and provable in one development round, (b) new according to the literature scout, (c) illuminating for the paper's philosophical aims (what a theory is and does; the limitations), and (d) cool. Merge closely related ideas into one thread.
For each thread write ${TR}/<key>/00-brief.md: the goal; the target statements T1, T2, ... as precisely as possible, with the scouts' first-pass attempts and pointers; what is known (references); what to verify computationally; the deliverable ${TR}/<key>/notes.md; and what the thread must NOT do (overlap with other threads).
Also write ${R}/NOTATION-draft.md: a shared notation for all threads, compatible with ../solomonoff-function-induction/paper/NOTATION.md where the objects coincide, with the inducers' names written as macros because the name is undecided. And write ${R}/select.md: the threads chosen and why; the ideas rejected and why; a preliminary outline of the paper.
Keys are short lowercase words matching [a-z][a-z0-9-]* (e.g. fundamentals, sfi, philosophy, approx, laws). Return the list of threads with keys, titles and kinds.`, { label: 'select', phase: 'Select', schema: SEL })
let threads = (sel && sel.threads ? sel.threads : []).filter(t => /^[a-z][a-z0-9-]{0,24}$/.test(t.key))
if (threads.length > 7) { log(`Lead returned ${threads.length} threads; keeping the first 7: dropped ${threads.slice(7).map(t => t.key).join(', ')}`); threads = threads.slice(0, 7) }
log(`Threads: ${threads.map(t => `${t.key} (${t.kind})`).join(', ')}`)

const refPrompts = t => t.kind === 'phil' ? [
  `ADVERSARIAL REFEREE A (philosophy) for thread "${t.key}" (${TR}/${t.key}/notes.md and its scripts). As a critical philosopher of science, attack every argument:
* steelman the objections: from the semantic view of theories, from Bayesian confirmation theory, from the best-system debate, and from the practice of physics;
* check that every characterisation of a cited author's view is accurate (verify by WebSearch);
* check that the Kepler example is correct as physics and as logic: orbital mechanics, which statements are only approximately true and by how much;
* check that limitations are not understated, and that formal results are not overclaimed as settling philosophical questions.
Write ${TR}/${t.key}/referee-A.md with a verdict and numbered issues (fatal / major / minor) with concrete fixes.`,
  `REFEREE B (formal accuracy and references) for thread "${t.key}" (${TR}/${t.key}/notes.md and its scripts):
* check every formal statement in the thread: prove or refute it, with INDEPENDENT seeded code in ${TR}/${t.key}/referee_code/ wherever something is computed (outputs saved next to each script);
* re-verify every bibliographic entry by WebSearch;
* check consistency with the shared notation ${R}/NOTATION-draft.md and with the other threads' records in ${TR}/.
Write ${TR}/${t.key}/referee-B.md with a verdict and numbered issues (fatal / major / minor) with concrete fixes.`,
] : [
  `ADVERSARIAL REFEREE A (proofs) for thread "${t.key}" (${TR}/${t.key}/notes.md and its scripts). Try to refute every claim marked proved. Check each proof line by line, for:
* hidden hypotheses and quantifier order;
* semimeasure versus measure, and the normaliser;
* r.e. versus decidable axiom sets, and the consistency of the induced theory;
* whether "proves" and "refutes" refer to the right theory;
* first-order details: languages, equality, constants, the deduction theorem, compactness;
* additive constants and logarithmic terms silently dropped;
* whether results of the earlier report and the SFI papers are used with their hypotheses.
Check that statements are no stronger than their proofs, and that each novelty claim agrees with the literature scout's record ${SC}/literature/notes.md. Write ${TR}/${t.key}/referee-A.md with a verdict and numbered issues (fatal / major / minor) with concrete fixes.`,
  `ADVERSARIAL REFEREE B (computation and counterexamples) for thread "${t.key}" (${TR}/${t.key}/notes.md and its scripts):
* write INDEPENDENT seeded code in ${TR}/${t.key}/referee_code/ (outputs saved next to each script) that tests the claims on small exactly enumerable cases: propositional or finite-signature fragments where provability is decidable; small enumerated classes of theories with explicit code lengths; exact posteriors and MAPs;
* search for counterexamples to every claim;
* re-run the developer's scripts and compare outputs.
Write ${TR}/${t.key}/referee-B.md with a verdict and numbered issues (fatal / major / minor) with concrete fixes and the evidence.`,
]

const results = await pipeline(threads,
  t => agent(`${COMMON}\n\nYou develop research thread "${t.key}" (${t.title}; kind ${t.kind}); folder ${TR}/${t.key}, with scripts in checks/. First read its brief ${TR}/${t.key}/00-brief.md, the shared notation ${R}/NOTATION-draft.md, ${R}/select.md, and the scout records the brief points to.
* Prove the strongest true statements you can for the targets, with full proofs.
* Check small cases numerically where possible (seeded code, saved outputs).
* Keep refuted claims, with their counterexamples.
${t.kind === 'phil' ? '* Make every philosophical claim precise, attach the formal results that support it, and say which claims are arguments rather than theorems. Verify every reference by WebSearch.\n' : ''}Deliverable ${TR}/${t.key}/notes.md, ending with a Verification log. Return a structured summary of your claims with statuses.`, { label: `develop:${t.key}`, phase: 'Develop', schema: DEV }),
  (d, t) => parallel(refPrompts(t).map((p, i) => () => agent(`${COMMON}\n\nYou are ${p}`, { label: `referee${'AB'[i]}:${t.key}`, phase: 'Referee', schema: REF }))),
  (r, t) => agent(`${COMMON}\n\nRevise research thread "${t.key}" (folder ${TR}/${t.key}) after its referee reports referee-A.md and referee-B.md.
* Fix every fatal and major issue, or show with evidence why the referee is wrong. Handle the minor issues.
* Keep refuted claims, marked refuted, with their counterexamples.
* Read the other threads' current records (${TR}/*/notes-final.md if present, else notes.md) and ${R}/NOTATION-draft.md. Align definitions and notation, and add a "Cross-thread consistency" section.
Write ${TR}/${t.key}/notes-final.md: complete and self-contained, ending with a Verification log (what was checked, how, and with what result, including the referees' code). Do not delete notes.md.`, { label: `revise:${t.key}`, phase: 'Revise', schema: REV }),
)

phase('Synthesis')
const keys = threads.map(t => t.key)
const syn = await agent(`${COMMON}\n\nYou are the SYNTHESIS editor. Read ${R}/select.md, ${R}/NOTATION-draft.md, the scout records in ${SC}/, and every thread's ${TR}/<key>/notes-final.md with its referee reports (threads: ${keys.join(', ')}). Write ${R}/notes-final.md with:
1. The headline results, ranked by importance and coolness, each stated exactly as proved (with pointers) and with its status.
2. The philosophy: the argument map with the Kepler example and the limitations, with the formal results attached where they support a claim, and an honest account of which claims remain arguments.
3. The relation to SFI, as a clean table of equivalences and separations.
4. What of ../axiom-induction is reused, restated or superseded.
5. A concrete paper plan:
   * title options;
   * the sections with their contents and the labels each will define;
   * which statements go in the main text and which proofs go in appendices;
   * page budgets (main text about 35–45 pages, appendices as needed);
   * the running example;
   * the related-work coverage, with the verified bibliography merged into ${R}/refs.bib (only entries verified by a scout or referee).
6. Open problems.
7. A consolidated Verification log.
Do not overstate anything relative to the thread records.`, { label: 'synthesis', phase: 'Synthesis', schema: REV })
const fin = await agent(`${COMMON}\n\nYou are a FRESH final checker.
* Compare ${R}/notes-final.md against the thread records ${TR}/{${keys.join(',')}}/notes-final.md and their referee reports. For every headline statement, check that it matches the thread statement exactly (hypotheses, constants, quantifiers, status) and that the cited proof exists and survived the referees.
* Check that every entry of ${R}/refs.bib was verified by a scout or referee.
* Re-run three of the most important scripts and compare them with the saved outputs.
Fix any mismatch in ${R}/notes-final.md minimally, and record what you changed in ${R}/final-check.md.`, { label: 'final-check', phase: 'Synthesis', schema: REV })
return { scouts: scouts.map((s, i) => ({ scout: SCOUTS[i].key, summary: s && s.summary })), selection: sel, threads: results.map((x, i) => ({ thread: threads[i].key, result: x })), synthesis: syn, final: fin }
