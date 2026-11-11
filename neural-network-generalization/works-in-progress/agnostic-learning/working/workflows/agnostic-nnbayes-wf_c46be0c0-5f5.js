export const meta = {
  name: 'agnostic-nnbayes',
  description: 'Prove or refute agnostic versions of the NNBayes generalization conjecture, with adversarial verification and repair',
  phases: [
    { title: 'Prove', detail: 'independent rigorous proof/refutation per claim, plus red team and literature' },
    { title: 'Verify', detail: 'adversarial verifiers with distinct lenses per proof' },
    { title: 'Repair', detail: 'fix verified issues and re-verify' },
  ],
}

const S = '/tmp/claude-0/-workspace/e8ce7448-1256-507d-9f63-d716a14ba11f/scratchpad/agnostic'
const BRIEF = S + '/BRIEF.md'
const OUT = S + '/out'

const COMMON = `Read the brief ${BRIEF} in full before anything else, then read the repo sources it cites that you need (confirm every cited statement in the source before using it). Work only inside ${OUT} for files you create (use a subfolder for scripts). Do not modify, commit or push anything in the git repository. Python3 with numpy/scipy/sympy is available for sanity checks. Write mathematics in Markdown with $...$ and $$...$$ LaTeX. Be fully rigorous: every inequality justified, quantifier and limit order explicit (sigma -> 0 after fixing sample and width), constants explicit where feasible. If a step cannot be proved, say so plainly and weaken the claim rather than paper over it.`

const PROVER_SCHEMA = {
  type: 'object',
  properties: {
    status: { type: 'string', enum: ['proved', 'partially_proved', 'refuted', 'failed'] },
    claim_as_proved: { type: 'string', description: 'precise final statement(s) actually proved, with all hypotheses' },
    file: { type: 'string', description: 'absolute path of the Markdown proof file' },
    gaps: { type: 'array', items: { type: 'string' }, description: 'remaining gaps or unproved steps' },
    numerical_checks: { type: 'string', description: 'what was checked numerically and the results' },
    summary: { type: 'string' },
  },
  required: ['status', 'claim_as_proved', 'file', 'gaps', 'summary'],
}

const VERDICT_SCHEMA = {
  type: 'object',
  properties: {
    verdict: { type: 'string', enum: ['correct', 'minor_fixes', 'major_flaw', 'wrong'] },
    issues: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          severity: { type: 'string', enum: ['critical', 'major', 'minor'] },
          location: { type: 'string' },
          description: { type: 'string' },
          suggested_fix: { type: 'string' },
        },
        required: ['severity', 'location', 'description'],
      },
    },
    summary: { type: 'string' },
  },
  required: ['verdict', 'issues', 'summary'],
}

const ITEMS = [
  {
    key: 'A',
    title: 'Negative: tightly conditioned learners interpolate noise and fail (Claims A, A-prime, TUBE variants)',
    task: `Prove Claims A and A' of the brief, and the TUBE_rho variants, as a self-contained Markdown research section written to ${OUT}/A.md. Required components:
(1) A real-valued memorization lemma for depth L = H+1 with H >= 2: for any r: {-1,1}^d -> [-1,1] supported on a set T with |T| = s, and accuracy a in (0,1], a network of depth L at every width N >= N_0(d,s,a) (explicit, polynomial) with sup over the cube |z - r| <= a and energy kappa_N <= K_mem(d,s,a,H) explicit, of order d^4 + (d s)^{1/H} plus lower-order terms in 1/a. Adapt NNG/works-in-progress/noisy-interpolation/README.md Sections 2-3 carefully (Fourier l1 bound, exact parity representation by tanh features, Hoeffding sampling at accuracy a, the depth chain with |t - tanh t| <= |t|^3/3), re-deriving every constant. Note the learner here has NO global margin conditioning.
(2) A strong-prior concentration lemma for SP_c: as sigma -> 0 at fixed N, n, sample, the posterior mass of {F_c > inf F_c + t} tends to 0 for every t > 0; consequences for the Gibbs predictor and for the posterior mean of z_w (control the tail contribution of large outputs).
(3) The excess-risk lower bound for D_d (uniform cube, fair +-1 labels independent of x) at n = lambda 2^d: with probability -> 1 every near-minimizer, the Gibbs draw, and the posterior mean have test MSE >= 1 + E[1/K; K >= 1] - o(1), K ~ Bin(n, 2^{-d}), with an explicit high-probability concentration argument for sum over seen atoms of ybar_x^2 and explicit o(1) terms. State the result for c = c(n) with c(n) K_mem = o(n), and for general label laws with Var(y|x) >= v_0.
(4) Explain precisely why this refutes every polynomial sample bound of the form in brief Section 1 (n = 2^d exceeds any polynomial in d; the competitor is the zero network).
(5) Variants: sampling without replacement; TUBE_rho with replacement (rho <= 1 infeasible with conflicting labels; rho > 1 in the strong-prior limit picks a minimum-energy feasible function: construct a label law, e.g. non-centred noise, with constant excess) and without replacement (interpolation within rho gives excess at seen atoms; handle the dependence on rho).
(6) Claim A': continuous input law with deterministic labels via tiny clusters (radius r(n)) carrying a balanced fine-scale label pattern; show every near-minimizer has energy O(n), hence Lipschitz at most poly(n) (use the energy-Lipschitz bound), so for small enough r(n) clusters act as atoms and the same excess follows. Give explicit choices of r(n) and pattern.
(7) Stretch: is the memorization exponent 1/H optimal? Either a cheaper construction or a lower bound on the energy needed to memorize s points (e.g. via capacity bounds) — report what you can prove.
Run numerical sanity checks of the key constants and of the parity/tanh representation identity for small d.`,
    lenses: ['logic', 'computation', 'scope'],
  },
  {
    key: 'B',
    title: 'Positive: tempered co-scaled Gaussian likelihood gives an agnostic oracle inequality at every width (Claim B, positive side of D)',
    task: `Prove Claim B of the brief as a self-contained Markdown research section written to ${OUT}/B.md. Learner: SP_c with c = c(n) = n^{1-theta}. Required components:
(1) Precise theorem: for fixed depth L, an explicit admissible range of theta and an explicit polynomial sample bound, for every compact X in [-1,1]^d (or unit ball), every distribution D on X x [-1,1], every competitor g of depth L, width m, weights <= B, every learner width N >= m, and every eps, delta: with probability >= 1-delta over the sample, the sigma -> 0 limit of the posterior is supported (asymptotically) on parameters whose clipped outputs have L_D <= L_D(g) + eps; deduce the same for the Gibbs predictor, and for the posterior mean (handle tails). Also treat unclipped outputs if possible (output bound from energy).
(2) Proof via: strong-prior concentration on {F_c <= inf F_c + 1} (Laplace bounds from NNG/side-results/continuous-domains/source/paper.tex proof of Theorem strong); the cloning energy bound E_*; the bounds kappa <= kappa(g) + 1 + n U^2/c and Lhat(z) <= Lhat(g) + c (E_* + 1)/n; uniform convergence over the width-independent energy cover (Proposition energy-cover; compute the explicit degree of log|H_{K,a}| in K and 1/a from Lemma compression and the rounding step) with Hoeffding plus a union bound; concentration of Lhat(g).
(3) Sharpening (positive side of Claim D): try to replace the cover by a norm-based capacity bound for energy-bounded tanh networks (e.g. layer-peeling Rademacher bounds with Ledoux-Talagrand contraction, giving dependence like K^{L/2}/sqrt(n) via AM-GM on the energy terms, or better), and determine the largest theta for which the argument works. Compare with the memorization threshold c ~ n^{1-1/H} of Claim A (memorization energy (dn)^{1/H}) and state the remaining gap precisely. If you can prove a matching bound (theta up to 1/H), that would be a sharp phase transition: say so only with a complete proof.
(4) State the final result in the user's language: test loss <= min over depth-L MLPs with width and weights <= n^alpha, plus O(n^{-beta}), with explicit alpha, beta.
(5) Discuss the role of the competitor's weight bound (show by an example that competitor energy much larger than n^theta cannot be matched by this learner, e.g. a steep 1D step realized only with huge weights on a two-point law).
Include numerical sanity checks where useful.`,
    lenses: ['logic', 'computation', 'scope'],
  },
  {
    key: 'C',
    title: 'Positive at polynomial width for ordinary tempered Bayes; failure at arbitrary width (Claim C)',
    task: `Prove Claim C of the brief as a self-contained Markdown section written to ${OUT}/C.md. Required:
(1) State and prove (or cite precisely with a full proof sketch that is checkable) the exp-concave aggregation / progressive-mixture oracle inequality for the posterior with likelihood exp(-eta sum (clip z_w(x_i) - y_i)^2), eta <= 1/8, under an arbitrary prior on parameters: E L_D(fhat_n) <= inf_Q [E_Q L_D(clip z_w) + KL(Q||mu)/(eta (n+1))], where fhat_n is the average over t = 0..n of posterior means of clipped outputs after t samples. Verify exp-concavity of squared loss on [-1,1] for eta <= 1/8 explicitly.
(2) Combine with the finite-scale teacher-tube mass bound (Proposition tube of NNG/side-results/continuous-domains/source/paper.tex) to get E L_D(fhat_n) <= L_D(g) + 4 rho + A_L(d,m,B,rho) N^gamma / (eta (n+1)) for every competitor g (depth L, width m <= N, weights <= B), with A_L's explicit form; deduce a polynomial agnostic bound when learner width N is polynomially bounded, and give it in the user's language (test loss <= min over width/weights <= n^alpha MLPs + o(1)).
(3) Also give the corresponding statement for the strong-prior family at fixed width with a fixed tempered likelihood (what happens as sigma -> 0 with eta fixed? Use NNG/works-in-progress/slt-likelihood/README.md Section 3) and for the standard fan-in (NNGP-scaling) prior if easy.
(4) Prove the necessity of width dependence for this learner in the finite-scale family: as N -> infinity with fixed eta and n, the posterior approaches the prior in total variation and the predictor tends to 0, so constant targets give a constant excess (adapt slt-likelihood Section 3). Also note that gamma < 1 / Gaussian-process-like regimes fail even realizably on parities (cite main result 4 precisely).
(5) A high-probability (rather than in-expectation) variant if available with moderate effort, or state that it is not proved.`,
    lenses: ['logic', 'computation'],
  },
  {
    key: 'E',
    title: 'Finite exponent gamma >= 1 (no sigma limit, every width): do A and B transfer? (Claim E)',
    task: `Investigate Claim E of the brief and write ${OUT}/E.md. The learner is the finite-scale prior mu_{N,gamma}, gamma >= 1, with Gaussian likelihood of variance c N^{-gamma}, i.e. posterior density proportional to exp(-N^gamma F_c(w)/2) relative to Lebesgue measure on parameters (check this identity against the prior's normalisation). Tasks:
(1) Positive: adapt the finite-scale proof in NNG/works-in-progress/slt-likelihood/README.md Section 2 ("Finite scales: every gamma >= 1 and every width", including its small-width argument) to agnostic data with c = c(n) = n^{1-theta}, proving an agnostic oracle inequality at every width N >= m with polynomial sample complexity; or identify exactly where it breaks and prove a weaker statement (e.g. for gamma large, or N polynomially bounded).
(2) Negative: decide whether the memorization counterexample (Claim A) transfers to c = 1 at finite gamma. This needs a lower bound mu_{N,gamma}(tube around a memorizing network) >= exp(-N^gamma A_mem) with A_mem = o(n); the repo's A_L grows with teacher width, so look for an energy-based tube estimate (e.g. via the translation inequality and a product-cylinder event exploiting that the memorizing network is a clone of a small number of distinct neuron types, or via large-deviation reasoning for gamma > 2 where energy dominates parameter-volume entropy). Prove what you can for some range of gamma (e.g. gamma large), and state clearly what remains open.
Be explicit about which statements are fully proved.`,
    lenses: ['logic', 'computation'],
  },
]

const LENS_TEXT = {
  logic: 'LENS = logic and definitions: check every quantifier, limit order, case split, and definition against the brief and the cited repo sources (open the sources and compare statements exactly). Look for circularity, misapplied lemmas, missing hypotheses (widths, weight bounds, clipping, measurability, existence of minimizers), and steps that silently assume what is to be proved.',
  computation: 'LENS = computation: recompute every constant, exponent, energy bound, probability estimate and concentration inequality. Re-derive the key inequalities yourself and run numerical checks in Python (in a scratch subfolder of the output folder) where possible. Report any arithmetic or exponent error, even if it does not change the conclusion.',
  scope: 'LENS = scope and adversarial interpretation: does the proved statement actually establish (or refute) the intended version of the conjecture in brief Section 1? Would a skeptical expert (the user, who proposed the conjecture) accept it, or object that it addresses a different learner, a degenerate distribution, a different loss, or the wrong order of limits? Try to construct a scenario where the stated theorem is false. Check consistency with existing repo theorems (e.g. the noisy-interpolation theorem, the slt-likelihood theorems, the continuous-domain exact-interpolation result) - any apparent contradiction is a red flag.',
}

function proverPrompt(it) {
  return `You are a research mathematician working on Bayesian neural-network learning theory.\n\n${COMMON}\n\nYOUR TASK (${it.title}):\n${it.task}\n\nWhen finished, return the structured result. The file must contain the complete argument (not a summary).`
}

function verifierPrompt(it, file, lens) {
  return `You are an adversarial referee. Your job is to REFUTE or find flaws in a claimed proof; do not fix it yourself beyond suggesting fixes. Default to reporting an issue when uncertain.\n\n${COMMON}\n\nThe claimed proof for "${it.title}" is in ${file}. Read it completely.\n${LENS_TEXT[lens]}\n\nWrite your full referee report to ${OUT}/verify-${it.key}-${lens}.md and return the structured verdict. Use 'correct' only if you checked every step; 'minor_fixes' if only presentational or harmless issues; 'major_flaw' if a step is wrong or unjustified but the claim may survive with repair; 'wrong' if the main claim is false or unsalvageable as stated.`
}

function repairPrompt(it, file, issues, round) {
  return `You are the author revising a proof after referee reports.\n\n${COMMON}\n\nThe current proof for "${it.title}" is ${file}. Referees raised these issues (JSON):\n${JSON.stringify(issues, null, 1)}\n\nAlso read the full referee reports in ${OUT}/verify-${it.key}-*.md. For each issue: if valid, fix the proof; if invalid, explain briefly why in an appendix "Response to referees". If a main claim cannot be rescued, weaken it explicitly. Write the complete revised proof (not a diff) to ${OUT}/${it.key}.r${round}.md and return the structured result with file set to that path.`
}

const blocking = (v) => v && (v.verdict === 'major_flaw' || v.verdict === 'wrong' || (v.issues || []).some(i => i.severity === 'critical' || i.severity === 'major'))

async function verifyAll(it, file, lenses, phaseName) {
  const vs = await parallel(lenses.map(lens => () =>
    agent(verifierPrompt(it, file, lens), { label: `verify:${it.key}:${lens}`, phase: phaseName, schema: VERDICT_SCHEMA })))
  return vs.filter(Boolean)
}

phase('Prove')
const redP = agent(`You are a skeptical senior learning theorist acting as a red team. ${COMMON}\n\nRead the brief's draft claims A-E critically and independently. Write ${OUT}/redteam.md covering: (1) any flaw you can find in the lead's analysis of A (memorization -> double-descent excess at seen atoms) and B (tempered co-scaling + energy cover); (2) consistency with existing repo theorems, especially NNG/works-in-progress/noisy-interpolation/README.md (does its clean-error bound at n ~ 2^d with many flips contradict A? check its quantifiers and whether it evaluates clean error on the whole cube), NNG/works-in-progress/slt-likelihood/README.md, and the exact-interpolation proposition in NNG/side-results/continuous-domains/source/paper.tex; (3) the depth-two case L = 2 with c = 1: does the clean-label-scaled learner still memorize, and is there a counterexample or a positive argument?; (4) whether any natural version of the user's "condition closely on training outputs" conjecture survives - e.g. deterministic labels with high-dimensional continuous inputs (benign overfitting), or excluding training inputs from the test distribution - and what is known; (5) what the results imply for the user's motivating scenario (complex real input-output maps approximated by small networks). Be concrete and quantitative; prove small lemmas where you make claims. Return a concise summary (under 400 words) of your most important findings.`, { label: 'redteam', phase: 'Prove' })
const litP = agent(`You are a careful research librarian and learning theorist. ${COMMON}\n\nCompile verified references (use web search; give exact authors, title, venue, year, and an arXiv or DOI link; mark each as verified only if you actually found it) relevant to: exp-concave aggregation and progressive mixture rules (Vovk; Kivinen-Warmuth 1999; Juditsky-Rigollet-Tsybakov 2008; Audibert 2009), Gibbs posteriors / PAC-Bayes for agnostic learning (Catoni 2007; Zhang 2006 'Information-theoretic upper and lower bounds for statistical estimation'; Alquier's survey), misspecified Bayes and SafeBayes (Grunwald 2012; Grunwald-van Ommen 2017), power/tempered/cold posteriors in Bayesian deep learning (e.g. Wenzel et al. 2020), structural risk minimization and penalized least squares, norm-based capacity of neural networks (Neyshabur-Tomioka-Srebro 2015; Bartlett-Foster-Telgarsky 2017; Golowich-Rakhlin-Shamir 2018), benign/tempered/catastrophic overfitting and double descent (Belkin-Hsu-Ma-Mandal 2019; Nakkiran et al. 2019; Bartlett-Long-Lugosi-Tsigler 2020; Mallinar et al. 2022; Joshi-Vardi-Srebro 2024; Kornowski-Yehudai-Shamir 2023; Wang-Donhauser-Yang on minimum-l1 interpolation), and Bayesian/GP analogues of double descent. For each, one sentence on its relevance to: (a) agnostic oracle inequalities for tempered Bayesian neural posteriors, (b) failure of interpolating learners under label noise on finite domains. Write ${OUT}/literature.md and return a short summary.`, { label: 'literature', phase: 'Prove' })

const results = await pipeline(
  ITEMS,
  (it) => agent(proverPrompt(it), { label: `prove:${it.key}`, phase: 'Prove', schema: PROVER_SCHEMA }),
  async (proof, it) => {
    if (!proof) return { key: it.key, proof: null, verdicts: [], rounds: [] }
    let cur = proof
    let verdicts = await verifyAll(it, cur.file, it.lenses, 'Verify')
    const rounds = [{ file: cur.file, verdicts }]
    let round = 1
    while (verdicts.some(blocking) && round <= 2) {
      const issues = verdicts.flatMap(v => (v.issues || []).filter(i => i.severity !== 'minor'))
      log(`${it.key}: ${issues.length} blocking issue(s); repair round ${round}`)
      const fixed = await agent(repairPrompt(it, cur.file, issues, round), { label: `repair:${it.key}:r${round}`, phase: 'Repair', schema: PROVER_SCHEMA })
      if (!fixed) break
      cur = fixed
      const relenses = round === 1 ? it.lenses : it.lenses.slice(0, 2)
      verdicts = await verifyAll(it, cur.file, relenses, 'Repair')
      rounds.push({ file: cur.file, verdicts })
      round++
    }
    return { key: it.key, final: cur, finalVerdicts: verdicts.map(v => ({ verdict: v.verdict, issues: v.issues, summary: v.summary })), roundsCount: rounds.length, firstProof: { status: proof.status, file: proof.file } }
  }
)

const red = await redP
const lit = await litP
return { results, redteam: red, literature: lit }
