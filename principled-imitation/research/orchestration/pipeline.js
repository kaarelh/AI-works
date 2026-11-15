export const meta = {
  name: 'imitation-pipeline',
  description: 'For each selected part of the imitation note: complete the proofs, verify them twice (line-by-line check and adversarial attack), and write the final section',
  phases: [
    { title: 'Prove', detail: 'complete the proof file of the part (skipped for parts already proved)' },
    { title: 'Verify', detail: 'two independent verifiers per part: a line-by-line checker and an adversary' },
    { title: 'Finalize', detail: 'apply the verified corrections; write the checked proof file and the section text' },
  ],
}

const ROOT = '/home/user/AI-works/principled-imitation'

const CONTEXT = `PROJECT. Repository /home/user/AI-works, project folder principled-imitation/. A researcher asked for a human-imitation protocol with a theorem. A human is modelled as a probabilistic program P that maps an input string x to a random answer y ~ P(.|x). From a reasonable number of question-answer pairs we want a sampler that behaves like P, also under the distribution shift produced by task decomposition (the imitator's inputs are written by other imitator calls), or that at least fails only obviously; unlimited compute is allowed; the human must not stay in the loop for ever. He hopes that either 'preserving the properties the data had' or 're-asking the human with some probability on the induced deployment distribution' can be made to work.

STATE OF THE WORK (all paths under ${ROOT}/).
- research/outline.md : outline of the note, its fixed notation, its style rules, and (in the addendum) how the note is assembled from parts, with the letter labels of the statements. Binding. Read it first.
- research/candidate-theory.md : the lead's list of claims (version 2 and Section 13), tagged [P] believed proved, [S] sketch, [?] conjecture. Unchecked; one earlier error is recorded in its Section 12.
- note.md : the lead's draft of the note: Sections 1-3 (model; the protocol 'rehearse, validate, deploy'; Theorems R1 and R3, Proposition R3a, Theorem V1), Section 4 (N1, N2), Section 8 (the property idea, Theorem Pr5 and its corollary). Unchecked.
- research/prove/lower-bounds.md and research/prove-b/hellinger-runs.md : two complete proof files by earlier workers. research/prove/rehearsal-core.md and research/prove-b/property-batch.md : partial proof files (those workers were interrupted). Scripts in research/prove/code/ and research/prove-b/code/.
- research/prove-c/ : proof files written in this round. research/verify/ : verification reports. research/sections/ and proofs/ : final texts.
- research/understand/*.md : background digests. notes.md digests the researcher's own notes (its Section 5 lists seven tests he applies to any proposal; its Section 6 has four observations); repo.md lists what the repository's earlier papers prove; ask-for-help.md, abstention-shift.md, imitation-theory.md, indistinguishability.md, alignment-proposals.md and active-queries.md digest the literature. They are long: read only the parts you need.
- code/ and results/ : toy computations by the lead (toy.py, toy_stakes.py, toy_property.py and their outputs).

GENERAL RULES. Do not commit. Do not delegate to subagents. Write files in pieces as you go, so that nothing is lost if you are interrupted. When you use a result from the literature, give the exact statement and a full citation, and say whether you read it in the source in this session or quote it from memory or from a digest. You may search the web for the literature; do not put the researcher's name, the repository's name or text of the project into web queries. Write plainly and precisely, in full sentences, defining every symbol; no filler. Your final message is read by a program: return the structured result asked for.
`

const PROVE_RULES = `YOUR ROLE: PROVER. For your part:
(a) State each result precisely, with all hypotheses, in the notation of research/outline.md.
(b) Give complete, rigorous proofs: every step justified, including integrability, runs of variable length, infinite divergences and semimeasures where they matter. Or refute the claim by an explicit counterexample with the calculation shown, and then find and prove the strongest true replacement you can.
(c) Improve constants and remove unnecessary hypotheses where you can; say which hypotheses are needed and why (an example for each needed hypothesis is best).
(d) Check small cases numerically where this is cheap: put scripts in research/prove-c/code/ with file names starting with your key, run them, save and quote their output.
(e) List what remains open in your part, and anything elsewhere in the project's files that you noticed to be wrong.
OUTPUT: research/prove-c/KEY.md (KEY = your key): self-contained mathematics that a referee can check line by line: numbered definitions, statements and proofs; each statement tagged PROVED, REFUTED (with the counterexample), MODIFIED (say how), NEW or OPEN; a summary table of the statements and tags at the top (keep it true to what the file actually contains).
RETURN: the path of your file, a summary of at most 300 words, and the list of statements with their tags.
`

const CHECK_RULES = `YOUR ROLE: REFEREE, LINE BY LINE. Check the proofs of the part named below. For every numbered statement give a verdict: CORRECT; MINOR (correct after a small fix: give the fix exactly); GAP (a step is missing: say exactly which, and fill it if you can); WRONG (give the failing step and, if you can, a counterexample and the strongest true replacement). Recompute every constant. Check that each hypothesis is used and that none is missing, and the edge cases (horizon 1, one question, runs with no calls, events of probability zero, infinite divergences, semimeasures, ties). Check that the statement in words says no more than what is proved. Where a numerical check is cheap, write and run one (scripts in research/verify/code/, names starting with your key). Do not rewrite the file; report.
OUTPUT: research/verify/KEY-check.md (KEY = the part's key): one entry per statement with the verdict and the reason, then a list of the corrections that must be made, ordered by importance.
RETURN: the path of your report, a summary of at most 250 words, and the list of verdicts.
`

const ATTACK_RULES = `YOUR ROLE: ADVERSARY. Try to break the part named below. (1) Look for counterexamples to each statement by exact computation or brute force on small instances (write and run scripts in research/verify/code/, names starting with your key and the word attack). (2) Look for hidden assumptions and for places where the prose claims more than the theorem. (3) Check every citation of the literature that the part relies on: authors, title, venue, year, and above all whether the cited work states what is attributed to it (open the source on the web where you can; say when you could not). (4) Apply the researcher's own tests (research/understand/notes.md, Section 5: guard, machine, referent, copy, budget, rock, horizon) to the part's claims and report what they catch. (5) Say what is not new: results that are standard, with the source. Default to doubt: a statement you could not break and could not fully follow is reported as NOT VERIFIED, not as correct.
OUTPUT: research/verify/KEY-attack.md (KEY = the part's key): findings ordered by severity (FATAL, MAJOR, MINOR, WORDING), each with the evidence, then the list of statements with a verdict (HOLDS, HOLDS WITH CHANGE, BROKEN, NOT VERIFIED).
RETURN: the path of your report, a summary of at most 250 words, and the list of verdicts.
`

const FINAL_RULES = `YOUR ROLE: EDITOR OF ONE PART. The proofs of your part have been written and then examined by two verifiers. Read the proof file(s) and both reports (research/verify/KEY-check.md and research/verify/KEY-attack.md, KEY = your key; if one is missing, say so and proceed with what exists). Decide every finding: accept and fix it, or reject it with a reason (verify the finding yourself before accepting or rejecting; a verifier can be wrong). Then produce two files.
1. proofs/KEY.md : the full proofs of your part, corrected. Start from the proof file, apply every accepted correction in place, remove statements that turned out false (or keep them as recorded refutations where that is instructive), and make the summary table at the top true to the final content. Add a last section 'Checking' that lists, in a table, each finding of the two reports and what was done about it. If the proofs of your part are spread over several files, merge them into this one.
2. research/sections/KEY.md : the text of your part as it will stand in the note, following research/outline.md exactly (notation, style, labels, length). State every result with its hypotheses and final constants. Give a proof in full if it takes up to about fifteen lines; otherwise give the idea in a few sentences and the pointer 'Proof: proofs/KEY.md, Theorem x.y'. After each main statement say in one or two sentences what it does not say. Say plainly which results are standard, with the source. Where the lead's draft in note.md already covers your part, revise that draft and keep what is correct in it; do not start again. Do not edit note.md itself.
RETURN: the paths of the two files, a summary of at most 300 words (the final statements with constants; what changed relative to the lead's draft and the candidate theory), the list of corrections made, and the list of open points.
`

const PARTS = {
  'rehearsal-core': {
    prove: true,
    proofFiles: 'research/prove-c/rehearsal-core.md',
    task: `PART rehearsal-core: the core of the rehearsal protocol (note Sections 1 to 3; labels L1-L3, R1, R2 for a deterministic human, R3, R3a, V1).
The earlier worker's file research/prove/rehearsal-core.md has Sections 0-4 complete (setting, L1, L2, L3, high-probability forms). Its summary table lists the statements planned for Sections 5-11 that were never written: R1 and what deploying the mixture of a uniformly random round guarantees (5.1-5.4, including the counterexample for re-drawing the round at every call), the last round (6.1 a bound for non-adaptive scaffolds and deterministic humans; 6.2 an example where the last round is worse by a factor of order L), R2 for a function (7.1), R3 with the robustness curve, with budgeted stateless replacement rules, tightness of the Markov step, and a recoverable form without the Markov step (8.3-8.6), the stochastic human (9.1-9.3), the online form in which each call is put to the human with probability q (10.1-10.3), and the remarks (11). Its scripts are research/prove/code/rehearsal-core_*.py.
PROVER: copy that file to research/prove-c/rehearsal-core.md and complete it: write Sections 5-11 with complete proofs (run the scripts and save their output; if a planned statement is false, say so and prove what is true). Then add: Proposition R3a of note.md (bounded damage implies tolerance of faults: check the martingale argument, the role of the adversary seeing the human's answer, and the constant) and Theorem V1 of note.md (validation certificate, parts (a) and (b): independence of validation rounds, runs shorter than the drawn index, a randomised frozen imitator, what exactly is certified for a stochastic human, and the remark that the tests may be any family fixed before validation, so that the price is the logarithm of the number of tests and not their complexity).
VERIFIERS: check research/prove-c/rehearsal-core.md and, against it, Sections 1-3 of note.md.
EDITOR: your section file revises Sections 1, 2 and 3 of note.md (model; protocol; guarantees: R1 with its remarks, the last round and the online form in brief, low stakes R3 and R3a, the certificate V1). The subsection on whole runs for a stochastic human is supplied by part hellinger-runs; leave a marked placeholder for it.`,
  },
  'lower-bounds': {
    prove: false,
    proofFiles: 'research/prove/lower-bounds.md',
    task: `PART lower-bounds: what no protocol can do (note Section 4 and the lower bounds of Section 6; labels N1-N5, S2).
The proof file research/prove/lower-bounds.md is complete (scripts research/prove/code/lower-bounds_*.py). Its main claims: N1 for randomised adaptive protocols and abstaining answerers; N2 with n >= L/(4 delta) - L and tightness; a lower bound with the factor K in VC dimension (Theorem 3.1) and a new protocol with targeted questions (Theorem 3.3, 'Protocol AB') that makes the deployed run of a function faithful with about 2.7 K L/(eps log(L/eps)) questions, so that rehearsal with random questions is not optimal in K measured in bits; N3 in the exact form n >= 2 eta N; S2 and the impossibility of a halting sampler that dominates all samplable laws; N5 (a scaffold that tolerates m faults still needs about L/((2m+1) delta) questions); lower bounds for a stochastic human; a concluding theorem on what imitation does and does not amplify.
VERIFIERS: check that file; give special attention to Theorem 3.3 (is the protocol well defined when only single calls on chosen inputs can be asked, and does the count of questions hold?), to the claim that part of the candidate theory's 'sharper form' of R3 is false, and to the concluding theorem. Compare with Section 4 of note.md (the lead's own N1 and N2).
EDITOR: your section file is Section 4 of the note (revise the lead's draft in note.md: N1, N2 with the best constants, the factor K, what targeted questions gain, N5, the stochastic bounds, and the conclusion on amplification stated carefully) and a separate block, clearly marked, with the lower bounds for Section 6 (N3 in its exact form; what S2 needs).`,
  },
  'hellinger-runs': {
    prove: false,
    proofFiles: 'research/prove-b/hellinger-runs.md',
    task: `PART hellinger-runs: whole-run closeness for a stochastic human, and recorded runs of the human system (labels L4, R2, A, B).
The proof file research/prove-b/hellinger-runs.md is complete (scripts and outputs research/prove-b/code/hellinger-runs_*). Its main claims: subadditivity of the squared Hellinger distance for sequentially generated runs with constant 4 by a short potential argument, and 2.9641 by a second potential, with an example of ratio 2.96399; R2 in general (E H^2 <= 2 L K ln 2 / n, E TV <= 2 sqrt(L K ln 2 / n), a bound for events of probability zero under the human system); lower bounds showing that sqrt(L) is necessary; Theorem A (recorded runs, one posterior draw per run), also for a human outside the class; the failure of Theorem A for the per-call mixture; Theorem B for weights 2^(-lambda length), lambda > 1, its failure at lambda = 1 and a substitute.
VERIFIERS: check that file; give special attention to the potential arguments for the Hellinger lemma (verify the potentials numerically and symbolically), to the attribution of the constant 7 to Foster, Han, Qian and Rakhlin (arXiv 2404.10122) and of 100 log n to Foster, Kakade, Qian and Rakhlin, and to the counterexample for the per-call mixture.
EDITOR: your section file has two blocks, clearly marked: (i) the subsection 'whole runs' for Section 3 of the note (R2 for a deterministic human in one sentence, R2 in general with the lemma it rests on, and the lower bounds that show the factor sqrt(L) is needed); (ii) Section 5.2, 'recorded runs of the human system' (Theorems A and B, why the per-call mixture fails there, what happens at lambda = 1, and the remark that this route needs runs of the human system and so only suits small scaffolds).`,
  },
  'one-mind': {
    prove: true,
    proofFiles: 'research/prove-c/one-mind.md',
    task: `PART one-mind: one hypothesis per run against a fresh posterior draw at every call (note Section 5.1; labels R4, R5, R6 of research/candidate-theory.md).
PROVER:
1. R4 (variant of rehearsal in which one posterior draw answers a whole run; deterministic hypotheses; the sum over rounds of the probability that the run differs from the human system's is at most 2 L K ln 2): check the symmetry proof line by line, write it out with runs of variable length, improve the constant if possible, and give an example showing that the order L K is attained.
2. Does R4 extend to stochastic hypotheses, with 'unfaithful' defined through a coupling, perhaps with a square root? Prove a version or give a counterexample (think of a hypothesis that marks its own runs by a small tilt of its answer distribution and deviates only on marked runs).
3. R5: construct explicitly a class, a scaffold and a human for which the per-call mixture after n rehearsal questions has few unfaithful calls per run, while one hypothesis per run (a posterior draw, or any rule that selects a single hypothesis) has runs with order L unfaithful calls with probability of order L/n; compute both; state the consequence for a scaffold that tolerates theta L faults (Theorem R3). Check the example by exact computation or simulation on a small instance.
4. R6: (a) an explicit example in which rehearsal driven by the current simplest consistent hypothesis has exponentially many (in K) unfaithful rounds; (b) a martingale Occam bound for selecting a single consistent program at the end of mixture-driven rehearsal, and the resulting bound on the probability that its own run is unfaithful (deterministic hypotheses).
5. What this implies for the wish that the imitator be one program like the human and not a mixture: which guarantees survive for a single program and which need the committee. (The lead's toy code/toy.py compares the three drivers on one class; see results/toy.out.)
VERIFIERS: check research/prove-c/one-mind.md.
EDITOR: your section file is Section 5.1 of the note, 'one program or a committee'.`,
  },
  'property-online': {
    prove: true,
    proofFiles: 'research/prove-c/property-online.md',
    task: `PART property-online: an imitator built from tests alone (note Sections 8.3 and 8.4; label Pr5).
The lead's statement and proof of Theorem Pr5 (matching the frequencies of all tests of a weighted family on any sequence, by the rule that minimises a sinh-weighted score) and of its rehearsal corollary are in note.md, Section 8.3; a toy computation is code/toy_property.py with output results/toy_property.out.
PROVER:
1. Check the lead's proof. Then prove the best version: a bound for all n at once without knowing n (time-varying step size or a mixture over step sizes) of the form |S_n(B)| <= C sqrt(n (ln(1/pi(B)) + lower-order terms)); infinite answer sets (near-minimisers; or answers of bounded length); infinitely many tests (convergence of the sums; what must be computable). Relate it exactly to Blackwell approachability, to calibration with checking rules (Sandroni, Smorodinsky and Vohra 2003), to Vovk's defensive forecasting and to online multiaccuracy or multivalid prediction (Gupta, Jung, Noarov, Pai and Roth), with exact citations of what is used and what is merely analogous (research/understand/indistinguishability.md may help).
2. One-sided fast rates: for tests the human never satisfies, can the number of rounds at which the imitator's answer lies in the test be bounded by O(ln(1/pi(B))) in total, together with the two-sided guarantee? Prove, or exhibit the obstruction.
3. The rehearsal corollary: exact statement and proof (one asked call per rehearsal run; deployment with the rule of a uniformly random round, drawn afresh for each run). What is assumed about the human? What fails if one rule is kept for good (give an example)? A high-probability version.
4. Limits, each with an example: tests outside the family or too complex for n; joint behaviour across the calls of a run (the toy shows a whole-run rate that differs from the human system's); the rule is a deterministic book-balancing choice and not a sample from a model of the human. Is there a randomised version (a tilt of a base sampler, for instance of the Bayes mixture, with online mirror descent on the tilt) with the same guarantee against answers drawn from P? Prove what you can.
5. Two comparisons with the Bayes mixture, with proofs: a setting where this imitator preserves a simple property and the mixture provably does not (a human outside the class, or weights that favour memorisers), and one where the mixture is far better (a human in the class: K ln 2 / n against 1/sqrt(n)).
VERIFIERS: check research/prove-c/property-online.md and, against it, Sections 8.3-8.4 of note.md.
EDITOR: your section file is Sections 8.3 and 8.4 of the note (revise the lead's draft).`,
  },
  'property-batch': {
    prove: true,
    proofFiles: 'research/prove-c/property-batch.md',
    task: `PART property-batch: the property idea in batch form, and what the Bayes mixture does with a simple property (note Sections 8.1, 8.2, 8.5; labels Pr1-Pr4).
The earlier worker's file research/prove-b/property-batch.md has Sections 1-2 complete (setting; Pr1 and Pr3: uniform convergence over a weighted family of tests of runs, the one-sided bound for tests that never occurred, remarks). Its scripts are research/prove-b/code/property-batch_*.py (run them; no output was saved).
PROVER: copy that file to research/prove-c/property-batch.md and complete it.
1. Pr4: the highest-weight sampler that matches all tests, when the family contains the sets {Q_nu > Q_nu'} for pairs of hypotheses with weight w(nu) w(nu'): the bound in total variation when the human is in the class, with constants; then the case of a human outside the class: design the estimator properly (minimum-distance estimation with weighted Yatracos sets; Devroye and Lugosi, Combinatorial Methods in Density Estimation, 2001; Yatracos 1985) and prove an oracle inequality of the form TV(Q_{P'}, Q_P) <= 3 TV(Q_nu, Q_P) + C sqrt((K(nu) + ln(1/delta))/N) for every hypothesis nu, in the exact form you can prove. What must be computable for the estimator to be defined?
2. Pr2: (a) the bound in hindsight (on data that abide by a decidable property R, the posterior expectation of the inverse of the probability the hypothesis gave to abiding so far is at most 2^(K(R)+c), for a class closed under conditioning each hypothesis on R; make the closure assumption exact). (b) A countable class with weights, a human in it, a simple decidable property R of pairs that the human never violates, and an input law, such that the Bayes mixture's probability of violating R at a fresh input from that law stays above 1/2 for all n up to order K divided by the bits per pair (memorisers: the table of the data and a fixed bad answer elsewhere); compute it exactly. (c) Whether this can happen in the class of all programs with a natural reference machine; say what can be proved.
3. The two prices side by side: sqrt(K/N) for all properties (Theorem A, research/prove-b/hellinger-runs.md) against sqrt(K(R)/N) for each simple property; what an imitator that satisfies only the second can still get wrong, with an example.
4. The validation certificate V1(b) of note.md (frequencies of tests on the imitator's own inputs, single calls) as the form of Pr3 that needs no runs of the human system; and the remark that for a human who is not deterministic, frequencies of tests are all that single answers at non-repeating inputs can certify (state and prove a precise version: two humans with equal test frequencies for a family but far apart in total variation at every input, indistinguishable by m such samples).
VERIFIERS: check research/prove-c/property-batch.md and, against it, Sections 8.1, 8.2 and 8.5 of note.md.
EDITOR: your section file is Sections 8.1, 8.2 and 8.5 of the note together with a short subsection on the batch estimator Pr4 (revise the lead's draft).`,
  },
  'shift-abstain': {
    prove: true,
    proofFiles: 'research/prove-c/shift-abstain.md',
    task: `PART shift-abstain: inputs from outside the closed system, and failing obviously (note Sections 6 and 7; labels S1-S3, Ab1-Ab3 of research/candidate-theory.md; N3, S2 and N4).
research/prove/lower-bounds.md, Section 4, already treats N3 and S2 (use it; do not redo it). The digests research/understand/ask-for-help.md (its Section 3 has derivations: weighted enumeration; a frozen top set gives exact domination and the total variation to the human system equals the abort probability; the bounds of Cohen, Hutter and Nanda after a training phase; silent mistakes times queries is at least the horizon over 32 for thresholds; a prior-averaged top set) and research/understand/abstention-shift.md contain statements to check and use.
PROVER:
1. S1 and S3 with proofs (density ratio of top-level task laws; a property of tasks with rehearsal probability beta costs 1/beta), and the three kinds of shift stated as one proposition: produced by the system itself (removed by rehearsal), a shift to a described law (factor from S2 and N3), anything else (N1).
2. Open systems: the online form in which each call is put to the human with probability q for ever (expected total divergence at most K ln 2 / q), and the lower bound on silent mistakes times questions (check the derivation in the digest and prove it).
3. Ab1: both counts for the threshold rule on any sequence of asked inputs (deterministic human), then the rehearsal version in which the threshold rule itself answers the calls and the run halts at the first abstention; per-run bounds. A version for a stochastic human if one can be proved.
4. Ab2: the dominance property of the minimum over a set of hypotheses that contains the human; Ville's bound for the set of hypotheses of posterior weight at least alpha times the maximum; then coverage as a theorem: in the class of all programs, on which inputs does the rule abstain, in terms of the separation complexity of the input from the asked inputs and of the gap between the posterior weight of the human and the maximum? What is guaranteed for a moderate alpha, under the assumption that the human is within log(1/alpha) bits of the best explanation of the data? Compare with Cohen, Hutter and Nanda, Fully General Online Imitation Learning (JMLR 2022): their exact statements, and what in Ab2 is theirs.
5. Ab3 (research/understand/notes.md, Observation B): check both claims and the constant; what the rule does when nobody answers the abstentions.
6. The trade-off as one statement: silent errors against abstentions against questions, with the lower bound N4 (research/understand/repo.md, items C3 and X2). The researcher rejects rules that abstain on everything new ('turns you into a rock') and accepts whitelists: say precisely which of these rules are which.
VERIFIERS: check research/prove-c/shift-abstain.md.
EDITOR: your section file is Sections 6 and 7 of the note (the lower bounds of Section 6 are supplied by part lower-bounds; refer to them by label).`,
  },
  'assumptions': {
    prove: true,
    proofFiles: 'research/prove-c/assumptions.md',
    task: `PART assumptions: the framing, attacked (note Sections 9 and 10 and the caveats on A1-A3). The prover of this part is the sceptic. Read research/understand/notes.md Sections 3, 5 and 6 with care (what the researcher counts as 'insane'; the seven tests he applies).
PROVER:
1. A1 (stateless human, fresh coins). What fails for a human with memory; the right episodic statement (if the unit that is asked is a whole episode after which the human is reset, which of R1, R3, V1 hold with 'call' replaced by 'episode'); a human who changes over the weeks of rehearsal (state and prove the bound against the best fixed sampler); a human who answers rehearsal questions differently because they know no run depends on the answer (is the human system then still the right object?).
2. A2 (the human is in the class). The versions of L3 and R1 without it (regret against any member nu plus the summed divergence from P to nu on the asked inputs); what they do and do not give; why the factor K cannot be avoided and what replaces it when the prior is built from existing knowledge (the theorems hold for every prior). Note that the certificate V1 needs no A2.
3. A3 (fresh coins of the protocol). Formalise the referent test: a hypothesis that models how the data set was made. Prove that under A3 it is covered by R1, and give explicit examples of failure when the protocol's choices can be computed by a hypothesis (a pseudo-random generator with a short seed) and when deployed inputs can be told from rehearsed ones (the top-level task of the real run differs from the rehearsed ones; a time stamp).
4. 'Closed system': the cleanest definition; examples on both sides; exactly what the theory offers for systems that are not closed.
5. The seven tests of research/understand/notes.md Section 5, applied to the protocol with Theorems R1, R3, V1 and the limits N1, N2: for each, passed or not, with the argument; where Section 10 of research/candidate-theory.md overclaims.
6. The budget with the researcher's own numbers (research/understand/notes.md, Sections 2.13 and 6.1): what the bounds say when one question costs hours and when it costs a year; where K ln 2/(theta delta) is hopeless; the lower bounds (research/prove/lower-bounds.md) that say this cannot be improved in general.
7. What remains a bet (Section 13, V2 and V3, of research/candidate-theory.md): rare situations; isolation and patch-free induction (ultranatural/note.md in the repository, Theorem 9); state precisely a version for the present setting and what it costs when the human is not isolated. Copy or predictor: what the data can and cannot decide (research/understand/repo.md, group F).
8. The strongest objections to the claim 'rehearsal is a human-imitation protocol that works exactly as far as any protocol can', each classed as answered, answerable or fatal. Be concrete and unsparing.
VERIFIERS: check research/prove-c/assumptions.md; the adversary should in particular try to strengthen the objections of item 8.
EDITOR: your section file has three blocks, clearly marked: caveats on A1, A2, A3 for Section 1 (short); Section 9 (what remains a bet; copy or predictor); Section 10 (the seven tests, as a table with one paragraph each).`,
  },
}

const PROVE_SCHEMA = {
  type: 'object',
  properties: {
    file: { type: 'string' },
    summary: { type: 'string' },
    statements: { type: 'array', items: { type: 'object', properties: { id: { type: 'string' }, tag: { type: 'string' }, text: { type: 'string' } }, required: ['id', 'tag', 'text'] } },
  },
  required: ['file', 'summary', 'statements'],
}
const VERDICT_SCHEMA = {
  type: 'object',
  properties: {
    report: { type: 'string' },
    summary: { type: 'string' },
    verdicts: { type: 'array', items: { type: 'object', properties: { id: { type: 'string' }, verdict: { type: 'string' }, note: { type: 'string' } }, required: ['id', 'verdict', 'note'] } },
  },
  required: ['report', 'summary', 'verdicts'],
}
const FINAL_SCHEMA = {
  type: 'object',
  properties: {
    section_file: { type: 'string' },
    proofs_file: { type: 'string' },
    summary: { type: 'string' },
    corrections: { type: 'array', items: { type: 'string' } },
    open: { type: 'array', items: { type: 'string' } },
  },
  required: ['section_file', 'proofs_file', 'summary', 'corrections', 'open'],
}

const keys = Array.isArray(args) ? args : Object.keys(PARTS)
const items = keys.filter(k => PARTS[k]).map(k => ({ key: k, ...PARTS[k] }))
const head = p => CONTEXT + '\nYour key is: ' + p.key + '. The proof file(s) of your part: ' + p.proofFiles + '.\n\n'
const opts = (label, phaseName, schema) => ({ label, phase: phaseName, schema, agentType: 'general-purpose' })

const results = await pipeline(
  items,
  async p => {
    if (!p.prove) return { file: p.proofFiles, summary: 'proved in an earlier round', statements: [] }
    const r = await agent(head(p) + PROVE_RULES + '\n' + p.task, opts('prove:' + p.key, 'Prove', PROVE_SCHEMA))
    if (!r) throw new Error('prover failed for ' + p.key)
    return r
  },
  async (proved, p) => {
    const v = await parallel([
      () => agent(head(p) + CHECK_RULES + '\n' + p.task, opts('check:' + p.key, 'Verify', VERDICT_SCHEMA)),
      () => agent(head(p) + ATTACK_RULES + '\n' + p.task, opts('attack:' + p.key, 'Verify', VERDICT_SCHEMA)),
    ])
    return { proved, verdicts: v }
  },
  async (prev, p) => {
    const f = await agent(head(p) + FINAL_RULES + '\n' + p.task, opts('final:' + p.key, 'Finalize', FINAL_SCHEMA))
    return { key: p.key, proved: prev.proved, verdicts: prev.verdicts, final: f }
  }
)
return { parts: results }
