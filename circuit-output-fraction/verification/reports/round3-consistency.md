# Consistency referee (abstract, introduction, experiments, discussion, README)

**Verdict.** Mostly consistent. Every experiment-derived number I checked in the abstract, introduction, experiments section, body sections and README matches the results files exactly. Regenerating all six generated tables from experiments/results/*.json with a copy of make_tables.py gives files byte-identical to paper/tables/*.tex. The hand-written tab:local and tab:affine also match local.json and affine.json, and the figures match their captions. The test step passes (327 passed in 84 s). The problems are about scope and wording, not arithmetic. There are 3 major findings: (1) the README, and the intro's first sentence, never say that D must be a product distribution; (2) the intro and README overstate the reach of the sampling version of the certified-independence procedure; (3) the trigger family is described as having a 16-variable body that is also called an atom (atoms have at most 12 variables). There are 23 minor findings: missing hypotheses (uniform D, unit weights, uniform pivots, opaque gates, conditions on the parity barrier), small inaccuracies in captions and the experiments text, one anachronistic citation, one loose paraphrase of an ARC conjecture, and README notation and status issues.

**What was checked.** Read in full: main.tex (abstract), sec-intro, sec-setting, sec-limits, sec-envelopes, all p1-* and p2-* sections, sec-experiments, sec-discussion and README.md; skimmed the appendices and the verification README.

Numbers. Copied make_tables.py to the scratchpad with its output pointed at a scratch folder and regenerated all six tables (coverage, speedup, arguments, ctx, janson, cftp); the diff against paper/tables is empty. Checked every number in the text against speedup, coverage, surprise, arguments, ctx, janson, cftp, local (and its log), affine (and its log), independence_numbers and second_order_check:
- coverage counts: total 2,250, 750 dishonest, 600 affine and 16 local runs;
- ratios 22, 187 and 1.96;
- K from 4.73 to 16.6;
- run times;
- the tab:local rows (samples 72,560 and 81,280, intervals, MC counts, Rao–Blackwell factors 2.7–4.8 and 1.5–2.4, row sums);
- every tab:affine row;
- the CFTP window factors 25 and 2.6·10^4 and ratios 1.29–1.61;
- the DNNF/|C| ratio range 1.5–2.6;
- the independence-section numbers;
- the Chernoff example K=2^{25.7} (recomputed: 25.74).
The cycle-threshold densities 0.32 and 0.059 are correct (computed by hand from binomial sums). The c/p extrapolation of Monte Carlo cost does favour Monte Carlo.

Reproductions:
- Re-ran the DNF and trigger parts of exp_speedup with seed 2026, without writing any results file. The DNF costs reproduce exactly. The trigger bodies depend on only 4–9 of their 16 variables.
- Built an E5-like XPT argument: it has 7 nodes, of which the checker visits 6.

Figures: rendered the three PDFs and compared them with their captions.

README:
- Every listed file exists, including verification/summary.json; module descriptions match the code. The reproduce commands name existing scripts, and each results file has a script that writes it.
- Test step: `python3 -m pytest -q -p no:cacheprovider tests` → 327 passed.
- `git status` shows many uncommitted changes and one untracked test file.

Citations: confirmed by web search that Meel–de Colnet "#CFG and #DNNF admit FPRAS" (SODA 2026, pp. 5978–6010), the ARC post "Competing with sampling" (Neyman, Lecomte, Wu, Winer, Hilton, Robinson, Nov 2025; the matching-sampling principle is average-case) and Neyman's no-coincidence post (Feb 2025) are as cited. Checked the other intro attributions from my own knowledge. WebFetch and arXiv could not be reached, so full texts were not opened. No files were edited.

## Findings

### 1. [major] README.md 'Question' and 'Short answer'; sec-intro.tex l.3 and the Results paragraphs

**Problem.** The README poses the problem for 'an input distribution D' and never says that every result assumes a product distribution with rational marginals (sec-setting l.27–35; thm:dfsb, thm:pcis-sound, thm:certenv). Under a correlated D, rule (D) of DFSB and the PROD/SPLIT rules of PCIS are not valid identities, so 'sound on every circuit' is false. The intro's first sentence also says 'a distribution on its inputs' and never restates the restriction.

**Proposed fix.** README Question: write 'an input distribution D (a product distribution with rational marginals; a distribution given by a sampler circuit reduces to the uniform one)'. Add to the first Short-answer bullet: 'Throughout, D is a product distribution with rational marginals.' In sec-intro.tex l.3 write 'and $D$ a product distribution on its inputs (\cref{sec:setting})'.

### 2. [major] sec-intro.tex l.96–104; README.md 'presumption of independence' bullet

**Problem.** Both say that Harris and Janson pin p within e^{Δ/(1−max b_i)} of ∏D(A_i) 'at a sampling cost linear in Σb_i ≤ log(1/p)+Δ/(1−max b_i)'. The sampling procedure of thm:janson-general does no such thing for general Δ:
- it outputs [0,1] unless the estimated Δ is at most ε'/16 and every estimated b_i is at most 1/3;
- it is complete only when Δ ≤ ε'/64 and max b_i ≤ 1/4;
- its cost has an extra deg_G(i)·ε^{-1}log(1/δ) term per dependent pair.
The e^{Δ/(1−max b)} window is computed only for unate CNFs (thm:janson, deterministic).

**Proposed fix.** Replace with: 'Harris and Janson inequalities give M ≤ p ≤ M e^{Δ/(1−max_i b_i)}, M=∏_i D(A_i). For unate CNFs both ends are computed exactly. For unate ∧'s of arbitrary sub-circuits, a sampling procedure certifies p to ratio 1+ε whenever Δ ≤ ε'/64 and max_i b_i ≤ 1/4, using samples linear in Σ_i b_i ≤ log(1/p)+Δ/(1−max_i b_i) plus O(ε^{-1}log(1/δ)) per dependent pair, independent of 1/p.' Make the same change in the README.

### 3. [major] sec-experiments.tex l.67–71 (trigger family); also fig:speedup caption 'triggers with an atom body'

**Problem.** The text says 'R a dense random 40-gate circuit on 16 body variables … the restricted body is an atom', but atoms have at most a=12 variables. The bodies built by families.trigger_circuit depend on only 4–9 of the 16 variables (reproduced with seed 2026: supports 9, 4, 6, 5, 4, 7 for k=10…80). That is why they are atoms, why DFSB uses 0 samples, and why p is 'exact down to 4·10^-25'. A real 16-variable dense body would have to be sampled, as trigger-cycle20 shows.

**Proposed fix.** Write 'R a random 40-gate circuit drawn on 16 body variables, whose output depends on 4 to 9 of them, so that after forcing the body is an atom (a=12)'. Alternatively, regenerate the bodies with full 16-variable support and report the sampled costs.

### 4. [minor] sec-intro.tex l.120–123; README.md affine bullet ('remove the parity-check part of the surprise exactly')

**Problem.** prop:presolve gives the exact factor 2^{-k}, and lets any sound method run on R̃, only when the pivots are uniform coordinates (P⊆U). With biased pivots the factor is ∏max(q,1−q), and each pivot costs up to ρ=(1+2η)/(1−2η) in samples. In E6a the biased-pivot presolve only certifies p≤1.3·10^-22 against p=2.6·10^-31.

**Proposed fix.** Add 'when the pivots can be chosen on uniform coordinates (under biased marginals each pivot costs a factor up to (1+2η)/(1−2η) in samples)'.

### 5. [minor] sec-intro.tex l.132–134; README.md last affine sub-bullet ('thresholds of independent blocks (exponential tilting, K≤4/3(2√k+1))')

**Problem.** prop:tilting needs unit weights and E_D S ≤ t < k_+. For integer weights the best tilt can be loose by p^{-Θ(1)} (sec-envelopes l.284–287: K=2^{25.7} at p=2^{-40}).

**Proposed fix.** Write 'thresholds of unit-weight independent blocks (exponential tilting with K≤4/3(2√k+1) for E_D S ≤ t < k_+, prop:tilting)'.

### 6. [minor] sec-intro.tex l.43–46 and l.152–157; sec-discussion.tex l.21–23 and l.36–40; README.md 'With a prover' bullet

**Problem.** thm:surprise is proved only under the uniform distribution. Part (a) is a worst case over planted subcube circuits; part (b) covers envelopes E=E(y) on coordinates disjoint from the planted ones. The summaries drop the uniform-distribution hypothesis, and (a) reads as a universal statement.

**Proposed fix.** Add 'under the uniform distribution' to each summary, and for (a) write 'in the worst case (planted subcubes), each bit of argument reduces the number of evaluations needed for a lower bound by at most a factor 2'.

### 7. [minor] sec-discussion.tex l.11–13

**Problem.** 'random parity checks … cost the decomposition-based methods Monte Carlo's price up to polynomial factors'. cor:barrier-methods needs m≤n/6 random checks, events that fill at least a 1/poly(n) fraction of the solution set, and holds with high probability. For the #DNNF route it proves only the square root.

**Proposed fix.** Write 'for events that fill a 1/poly(n) fraction of the solution set of m≤n/6 random parity checks, with high probability, envelopes with small leaves, context-width compilation and DFSB's completeness guarantee cost Monte Carlo's price up to polynomial factors, and any use of a DNNF envelope at least its square root'.

### 8. [minor] main.tex abstract l.29–31

**Problem.** 'on random parity checks decomposable envelopes with small leaves cost at least the square root of Monte Carlo's price' leaves out the hypotheses of cor:random-parity and cor:barrier-methods (m≤n/6, events of conditional density ≥1/poly(n), with high probability over the checks, up to polynomial factors).

**Proposed fix.** Write 'yet for events of polynomial density in the solution set of m≤n/6 random parity checks, decomposable envelopes with small leaves cost, with high probability, at least the square root of Monte Carlo's price up to polynomial factors'.

### 9. [minor] sec-discussion.tex l.16–17

**Problem.** 'anything a propositional proof system can certify about where the rare inputs live (thm:certenv)' is too broad. thm:certenv covers proofs of confinement to a union of tractable pieces (decomposable products of subcubes, checked-deterministic circuits and uniform-coordinate affine atoms, or DNNFs) with total mass at most Kp.

**Proposed fix.** Write 'any confinement of the rare inputs to a union of tractable pieces (subcubes, checked-deterministic circuits, affine atoms, DNNFs) of small total mass that a propositional proof system can certify (\cref{thm:certenv})'.

### 10. [minor] sec-discussion.tex l.50–51

**Problem.** 'Overlapping constraints are certified only where an exact sampler or a locally checkable mixing certificate exists' contradicts the paper itself. It certifies overlapping constraints without samplers via the Janson sandwich with small Δ (thm:janson, thm:janson-general), the cluster expansion (prop:kp), interface dynamic programming and the local-lemma FPRAS module.

**Proposed fix.** Write 'Strongly overlapping constraints (large Δ, outside the local-lemma and cluster-expansion regimes) are certified here only where an exact sampler or a locally checkable mixing certificate exists'.

### 11. [minor] sec-discussion.tex l.20–21

**Problem.** 'the cost has the same shape, polynomial in the explained surprise and exponential in the unexplained surprise'. The cost is polynomial in the size of the explanation (|π|, or the tree or envelope found), not in σ_e.

**Proposed fix.** Write 'polynomial in the size of the explanation and exponential in the unexplained surprise'.

### 12. [minor] README.md Experiments bullet ('the solver's DRUP proofs grow exponentially with the trigger length even for linear hashes')

**Problem.** This is stated as fact from four data points. The paper (p2-pcis l.373–375, sec-experiments l.211–214) calls it evidence, not a resolution lower bound.

**Proposed fix.** Write 'the solver's DRUP proofs grew from 329 to 32,910 steps as k went from 12 to 24, even for linear hashes (evidence, not a lower bound)'.

### 13. [minor] main.tex abstract l.23 ('backdoor triggers'); sec-intro.tex l.76; README.md DFSB bullet ('backdoor-style triggers')

**Problem.** Triggers are listed as a DFSB class without qualification. cor:dfsb(b) needs (F) (unit propagation, plus probing and Gaussian elimination at the root) to derive the trigger, and the paper's own SPN-hidden triggers defeat Part 1.

**Proposed fix.** Write 'triggers that propagation or Gaussian elimination exposes' (abstract: 'propagation-visible triggers').

### 14. [minor] main.tex abstract l.25–27; README.md context-width bullet ('every circuit whose AND gates are bracketed with logarithmic context width')

**Problem.** thm:cw needs an NNF without opaque gates. Threshold gates whose integer weights have super-polynomial total W are covered only as frontier gates (p1-ctx l.31–32). The intro states this condition; the abstract and README do not.

**Proposed fix.** Add 'whose NNF has no opaque gates (thresholds with polynomially bounded integer weights)'.

### 15. [minor] sec-intro.tex l.92–95; README.md modules bullet

**Problem.** 'the log-ratios of the quotient estimates add, up to lower-order terms'. The body (p1-ctx l.217–220) gives exactly the sum S only when the third rule is never needed, and e^{O(dS)}S in general, for dS below a constant, with d the depth of the module tree.

**Proposed fix.** Write 'add when the parent is monotone or antitone in each input (or each used polarity has probability ≤1/2), and otherwise up to a factor e^{O(dS)}, d the module-tree depth'.

### 16. [minor] sec-experiments.tex l.25–26; README.md Contents ('make_figures.py and make_tables.py regenerate the paper's figures and tables')

**Problem.** tab:local (p1-local.tex l.374–389) and tab:affine (p1-affine.tex l.481–513) are typed by hand; make_tables.py does not generate them. Their numbers currently match local.json and affine.json.

**Proposed fix.** Write 'Tables \ref{tab:coverage}–\ref{tab:cftp} and the figures are generated by make_tables.py and make_figures.py; Tables \ref{tab:local} and \ref{tab:affine} are transcribed from results/local.json and results/affine.json'. Alternatively, add both tables to make_tables.py.

### 17. [minor] sec-experiments.tex l.115–118 (tab:speedup caption)

**Problem.** The caption says 'Cost counts all circuit evaluations' and 'speed-up is Monte Carlo's requirement divided by the cost'. The exact rows have cost 0 because tabulating atoms in (T′) and (R8) is not counted, and make_tables.py divides by max(cost,1), so their speed-up column just repeats Monte Carlo's requirement.

**Proposed fix.** Write '"Cost" counts sampled circuit evaluations (pilots, leaf and box sampling); exact tabulation of atoms is not counted. For the exact rows (cost 0) the speed-up column shows Monte Carlo's requirement.'

### 18. [minor] sec-experiments.tex l.65–66

**Problem.** 'At w=8 … the pilots make DFSB 22 times costlier than Monte Carlo.' The dense leaf is run to ratio 1+ε/3 (interval ratio 1.033). At that accuracy the leaf alone needs about 4.3·10^5 samples, 8.5 times Monte Carlo's 5.0·10^4 at ratio 1.1. The pilots and batch doubling make up the rest of the 1.10·10^6.

**Proposed fix.** Write 'the accuracy split (the leaf is run to ratio 1+ε/3) and the pilots make DFSB 22 times costlier than Monte Carlo'.

### 19. [minor] sec-experiments.tex l.86–87

**Problem.** 'the curves cross at d=4 (speed-up 1.96)'. The crossing is between d=3 (speed-up 0.31) and d=4.

**Proposed fix.** Write 'the curves cross between d=3 and d=4 (speed-up 1.96 at d=4)'.

### 20. [minor] sec-experiments.tex l.59–61 (obfuscated DNF)

**Problem.** 'each literal routed through two (x⊕r)⊕r gadgets with random helper inputs r'. In families.obfuscated_dnf_circuit, r is a random one of the 64 circuit inputs, not a fresh helper input, and the gadget is skipped when r=i.

**Proposed fix.** Write 'through up to two (x⊕r)⊕r gadgets, r a random other input variable'.

### 21. [minor] tab:arguments caption (sec-experiments.tex l.223–224); p2-pcis.tex l.378–379

**Problem.** '"check" is the time to check the proof', but exp_arguments.py records verify_seconds over the whole verify() call: proof check plus sampling.

**Proposed fix.** Write '"check" is the verifier's time (proof check and sampling)'.

### 22. [minor] sec-intro.tex l.198–199 (related work)

**Problem.** 'd-DNNF, OBDD, SDD and bounded treewidth admit exact counting [darwiche2002map, samer2010]' cites a source that predates SDDs. The 2002 knowledge-compilation map has no SDDs; they were introduced in Darwiche, 'SDD: A new canonical representation of propositional knowledge bases', IJCAI 2011.

**Proposed fix.** Add the Darwiche 2011 IJCAI reference for SDD, or drop SDD from the list.

### 23. [minor] sec-intro.tex l.222–224 (neyman2025nocoincidence)

**Problem.** The paraphrase 'conjectures that structure in random reversible circuits always has short explanations checkable by a verifier' misstates the conjecture. In Neyman's Feb 2025 ARC post, for reversible circuits on 3n bits with property P (no input ending in n zeros maps to an output ending in n zeros), a polynomial-time verifier accepts some polynomial-size advice for every circuit with P, while for 99% of random reversible circuits no advice is accepted.

**Proposed fix.** Write 'conjectures that a polynomial-time verifier given short advice can certify a specific property of reversible circuits whenever it holds, a property that random circuits almost never have, while accepting no advice for 99% of random reversible circuits'.

### 24. [minor] README.md Question (2)

**Problem.** 'must never be convinced of a falsehood (beyond probability ε)'. The paper uses δ for failure probability and ε for relative error.

**Proposed fix.** Replace ε with δ.

### 25. [minor] README.md Status, last line ('holds the full working state; everything in this folder is published')

**Problem.** git status shows many modified tracked files (README, code, experiments, results, paper sources, figures and tables) and an untracked code/tests/test_final_callers.py, which the test step runs. So the branch does not yet hold the working state. CLAUDE.md also requires adding a new project to its branch table at first publication, and circuit-output-fraction is not listed there.

**Proposed fix.** Before publishing, commit the working tree to claude/circuit-output-fraction-xixj34, including tests/test_final_callers.py. At first publication add the row '`circuit-output-fraction/` | `claude/circuit-output-fraction-xixj34`' to the CLAUDE.md table.

### 26. [minor] p2-xpt.tex l.83 and tab:affine E5 ('7-node argument') vs results/affine.json E5.xpt.nodes = 6 and affine_log.txt

**Problem.** The paper counts 7 nodes in the argument; the results file and log report 6, because xpt_check counts visited nodes and counts the refuted grandchild only as 'closed'. The paper is right, but a reader checking it against the results sees a mismatch.

**Proposed fix.** Either rename the counter in xpt_check and the log to 'visited', or add to the text: '7 nodes (the checker visits 6; the fourth leaf is refuted by propagation)'.


## Fixes

I checked all 26 consistency findings against the paper, code and results; all 26 are correct. I made the text fixes for 25 of them. The one left open (README status / git state) needs a commit and a CLAUDE.md row, and this step was told to make no state-changing git commands. No experiment had to be rerun and no results, tables or figures changed. The only code edits are two docstrings in /home/user/AI-works/circuit-output-fraction/code/rareprob/families.py, now accurate about the obfuscation gadget and the trigger body.

Checks behind the larger findings:
- **Trigger bodies:** I reran the DNF and trigger parts of exp_speedup (seed 2026) in scratch. The body supports are 9, 4, 6, 5, 4, 7, both syntactic and semantic, and Pr[R] is 0.5 to 0.78.
- **Monte Carlo at w=8:** at ratio 1+eps/3 it needs 424,448 samples, 8.4 times the 50,240 it needs at ratio 1.1.
- **d=3 speed-up:** 0.31.
- **E5 XPT argument:** xpt_honest splits on two gates, which gives 7 nodes. xpt_check only counts as closed (not as a node) a child refuted when its split is applied.
- **verify_seconds:** it times the whole verify() call (proof check plus sampling).
- **Darwiche SDD paper:** IJCAI 2011, pp. 819–826, confirmed by web search (https://mlanthology.org/ijcai/2011/darwiche2011ijcai-sdd, https://www.ijcai.org/Abstract/11/143).

For consistency I also made three small edits the referee did not ask for:
- "with high probability" added to the barrier summaries in p1-tail.tex and README.md;
- "and Gaussian elimination" added to the intro's description of DFSB's forcing rule;
- one intro sentence reworded to remove an overfull box caused by the reflow.

The paper builds in a scratch copy (/tmp/claude-0/-home-user-AI-works/02f29707-9759-5ff3-9757-46e1f8b0fdfe/scratchpad/consist/build) with:
- no undefined references or citations;
- no BibTeX warnings;
- no overfull boxes.

The only warnings are font-shape substitutions and hyperref bookmark warnings, which were there before. The PDF (86 pages) is copied to /home/user/AI-works/circuit-output-fraction/paper/main.pdf.

Edited files (all under /home/user/AI-works/circuit-output-fraction/):
- paper/main.tex
- paper/sec-intro.tex
- paper/sec-discussion.tex
- paper/sec-experiments.tex
- paper/p2-pcis.tex
- paper/p2-xpt.tex
- paper/p1-tail.tex
- paper/refs.bib
- README.md
- code/rareprob/families.py

- (1, major) README and intro never say D must be a product distribution: Confirmed. README Question now says D is a product distribution with rational marginals (a sampler-circuit distribution reduces to the uniform one). The first Short-answer bullet starts 'Throughout, D is a product distribution with rational marginals.' sec-intro l.3 now reads 'D a product distribution on its inputs (\cref{sec:setting})'.
- (2, major) Intro and README overstate the sampling version of certified independence: Confirmed against thm:janson-general (it outputs [0,1] unless the estimated Delta <= eps'/16 and all estimated b_i <= 1/3; it is complete only for Delta <= eps'/64 and max b <= 1/4; it has an extra per-edge term). Both now say: M <= p <= M e^{Delta/(1-max b)}; for unate CNFs both ends are computed exactly; for unate ANDs of arbitrary sub-circuits a sampling procedure certifies ratio 1+eps whenever Delta <= ln(1+eps)/64 and max b_i <= 1/4, with samples linear in sum b_i plus O(eps^-1 log(1/delta)) per dependent pair, independent of 1/p. The intro now cites thm:janson and thm:janson-general.
- (3, major) Trigger family body called a dense 16-variable circuit and an atom: Confirmed by reproduction (seed 2026): body supports 9, 4, 6, 5, 4, 7, Pr[R] from 0.5 to 0.78. sec-experiments now says R is a random 40-gate circuit drawn on 16 body variables (probability 0.5 to 0.78) whose output depends on only 4 to 9 of them, so after forcing the body is an atom (at most 12 variables). The fig:speedup caption ('atom body') is now consistent. The trigger_circuit docstring is corrected.
- (4) Presolve stated without the uniform-pivot condition: Intro and README now say the presolve removes the parity-check part exactly when the pivots can be chosen on uniform coordinates. They add that a pivot of bias at most eta costs a factor up to (1+2eta)/(1-2eta) in samples.
- (5) Tilting bound stated without its hypotheses: Intro and README now say 'thresholds of unit-weight independent blocks (K <= 4/3(2 sqrt k+1) for E_D S <= t < k_+, k_+ the number of blocks that can be 1)'.
- (6) thm:surprise summaries drop the uniform-distribution hypothesis, and (a) reads as universal: Added 'under the uniform distribution' in intro l.43-46, the intro prover paragraph, discussion 'What the answers are', the discussion surprise-accounting bullet and the README prover bullet. Part (a) is now phrased 'in the worst case (planted subcubes)' and part (b) 'on some circuits'.
- (7) Discussion barrier statement omits hypotheses: Rewritten with m <= n/6, events filling a 1/poly(n) fraction of the solution set, 'with high probability', and 'any use of a DNNF envelope at least its square root'.
- (8) Abstract barrier statement omits hypotheses: Abstract now says: for events of polynomial density in the solution set of m <= n/6 random parity checks, decomposable envelopes with small leaves cost, with high probability, at least the square root of Monte Carlo's price up to polynomial factors.
- (9) Discussion overstates thm:certenv: Now: 'any confinement of the rare inputs to a union of tractable pieces (subcubes, checked-deterministic circuits, affine atoms, DNNFs) of small total mass that a propositional proof system can certify'.
- (10) Discussion says overlapping constraints are certified only with samplers or mixing certificates: Now: strongly overlapping constraints (large Delta, outside the local-lemma and cluster-expansion regimes) are certified only where an exact sampler or a locally checkable mixing certificate exists. Weakly overlapping ones are certified by the Harris-Janson sandwich, the cluster expansion and the local-lemma FPRASs (citing thm:janson, thm:janson-general, prop:kp, sec:modules). The following sentence's pronoun is fixed.
- (11) Discussion says cost is polynomial in the explained surprise: Now 'polynomial in the size of the explanation and exponential in the unexplained surprise'.
- (12) README states DRUP growth as fact: Now 'grew from 329 to 32,910 steps as the trigger length went from 12 to 24, even for linear hashes (evidence, not a lower bound)'.
- (13) Triggers listed as a DFSB class without qualification: Abstract: 'propagation-visible triggers'. Intro and README: 'triggers that propagation or Gaussian elimination exposes'. The intro's description of forcing now also mentions Gaussian elimination.
- (14) Abstract and README omit the no-opaque-gates condition for context width: Abstract: 'Circuits whose threshold gates have polynomially bounded integer weights and whose AND-gates are bracketed with logarithmic context width'. README: 'whose NNF has no opaque gates (thresholds with polynomially bounded integer weights)'.
- (15) 'Log-ratios add up to lower-order terms' for modules is loose: Intro and README now state the precise bound from p1-ctx. The log-ratio is at most the sum S (in the polarities the parents use) when each parent is monotone or antitone in each input, or the interval for the used polarity lies in [0,1/2]. Otherwise it is at most e^{O(dS)} S for dS = O(1), d the module-tree depth. I used the body's exact condition (the interval lies in [0,1/2]) rather than the referee's 'probability <= 1/2'.
- (16) tab:local and tab:affine are hand-typed, not generated: Verified. sec-experiments now says tables coverage, speedup, ctx, janson, cftp and arguments and the figures are generated by make_tables.py and make_figures.py, while tab:local and tab:affine are transcribed from results/local.json and results/affine.json. The README Contents says the same.
- (17) tab:speedup caption wrong for exact rows: Caption now: 'Cost' counts sampled circuit evaluations (pilots, leaf and box sampling); exact tabulation of atoms and small cones is not counted; for the exact rows (cost 0) the speed-up column shows Monte Carlo's requirement.
- (18) w=8 cost attributed to pilots only: Verified (Monte Carlo at ratio 1+eps/3 needs 424,448 samples, 8.4 times 50,240). Text now says 'the accuracy split (the leaf is run to ratio 1+eps/3) and the pilots make DFSB 22 times costlier'.
- (19) Wrong crossing point: Verified (speed-up 0.31 at d=3, 1.96 at d=4). Now 'the curves cross between d=3 and d=4 (speed-up 1.96 at d=4)'.
- (20) Obfuscated-DNF gadget misdescribed: Verified in families.py. Now 'through up to two (x xor r) xor r gadgets, r a random other input variable'. The docstring is fixed to match.
- (21) 'check' time described as proof check only: Verified (verify_seconds times the whole verify()). The tab:arguments caption now says 'the verifier's time (proof check and sampling)'. The sec-experiments sentence and p2-pcis l.378 now say the verifier checks the proof and samples in 39.5 s in all.
- (22) SDD cited to a source that predates SDDs: Added darwiche2011sdd (Darwiche, IJCAI 2011, pp. 819-826; pages confirmed by web search) to refs.bib and the related-work citation.
- (23) Loose paraphrase of Neyman's no-coincidence conjecture: Now: a polynomial-time verifier can check short advice certifying a certain property of reversible circuits whenever the property holds, while accepting no advice for 99% of random reversible circuits, which almost never have it.
- (24) README uses epsilon for failure probability: Replaced with delta.
- (26) E5 '7-node argument' vs 6 nodes in results: Verified the paper is right: xpt_honest builds 7 nodes, and xpt_check counts a child refuted when its split is applied as closed but not as a visited node. p2-xpt now adds 'the checker visits 6 of the nodes, as propagation refutes the closed leaf when its split is applied'. No code or result change.
- not done: (25) README Status: branch does not yet hold the working state, and CLAUDE.md has no row for circuit-output-fraction: The finding is correct, but fixing it means committing the working tree (including code/tests/test_final_callers.py) to claude/circuit-output-fraction-xixj34. That is a state-changing git command, which this step was told not to run. The CLAUDE.md row is to be added at first publication to main, and CLAUDE.md is a shared root file. Both belong to the commit/publish step. The README status line describes the intended post-commit state, so I left it unchanged.

## Experiment rerun on the final code

I applied every external edit that falls under code/ or experiments/, reran all ten experiments on the final code, and regenerated the tables and figures. All 327 tests pass (`cd code && python3 -m pytest -q tests`, 75 s). Every interval contains its exact value wherever one is known, and every coverage row has 0 misses. All containment checks are now exact comparisons against Fractions, with no slack.

**Code edits (checked against the current files):**
- `ctxwidth.py`: the docstring now says `to_nnf(C, flatten=False)` builds the NNF gate by gate. Distinct gates stay distinct nodes even when structurally equal, so cw is measured on the circuit's own bracketing. Only literals and the nodes inside small cones and XOR/threshold expansions are shared.
- `stats.sequential_mean`: this was already done. It raises ValueError on any sample outside [0,1] or not finite, and never clips. No change.
- `kl_interval` callers: three of them did not allow for the rounding of their floating-point mean. These are `localthr.ti_interval` (window exceedance mean, now `rel_err=sum_rel_err(L)`), `tilting.proposal_lower_bound` (now `sum_rel_err(N)`) and the DFSB box pilot in `dfsb.py` (0/1 sums, so only the division rounds: now `sum_rel_err(0)`).
- New test file `code/tests/test_final_callers.py` (5 tests):
  - every `kl_interval` call outside `stats.py` passes `rel_err` (an AST check);
  - `ti_interval` passes it;
  - `rel_err` only widens the interval;
  - `proposal_lower_bound` is sound against exact rational p, and untrusted proposals give [0,1];
  - the new exact reference functions match brute force.
- Not-done items: every one listed by the code owners was either already fixed by another owner, a paper-only issue, or a deliberate sound relaxation (CNF encoding of threshold gates). I also confirmed that `meta_estimate` handles thresholds of ±inf and rejects NaN.

**Experiment edits:**
- `exp_coverage` and `exp_speedup` used floating-point reference values for the block products, Poisson-binomial tails, DNFs and cycle thresholds. They now use exact Fractions. For this I added `dnf_prob_rational` and `poisson_binomial_tail_rational` to `exact.py`.
- `exp_janson` checks its small instances against exact rational enumeration with no slack, and writes `janson_log.txt` itself.
- `exp_cftp` computes exact p as a Fraction by a transfer matrix (cross-checked against variable elimination), records whether the Harris–Janson window contains p, and writes `cftp_log.txt`. Both logs now match their JSON.
- `exp_affine` compares exact Fractions in E5, E6a, E6b and E7 (E7 now enumerates in rational arithmetic).
- `exp_arguments` records |C| and p for the row where the prover timed out, and whether the Part 1 interval contains p.
- `make_tables.py`:
  - every certified-interval endpoint is printed with exact decimal rounding outwards (lower down, upper up);
  - other numbers round half up;
  - the old 10.00·10^e mantissa bug is fixed;
  - the ctx table's broken `$p=$0.393$$` is fixed;
  - the Part 1 column is kept for the row where the prover timed out (SPN k=16 now shows |C|=609, p=6.68e-6, Part 1 ratio 1, and 'no proof within 1200 s' spans only the Part 2 columns).
- `make_figures.py`: the surprise figure's x-axis reads 'unrevealed trigger bits $k-j$' and the reference line '$\propto 2^{k-j}$'. I also applied the optional panel title 'obfuscated DNF (envelope leaf; $w=8$ dense)'; the rerun confirms that the w=8 point is a single Monte Carlo leaf.

A scratch build of the paper with the new tables compiles with no errors.

Values are from the regenerated JSON files. Timings were measured with three experiments running at once on 4 cores.

**Tests:** 327 passed.

**Coverage:** 2,250 trials over 11 rows, 0 misses, against exact Fractions with no slack. This includes 750 dishonest-argument trials (300 with malformed envelopes), 200 tilting trials (now with exact rational tails) and 100 box trials (exact products).

**Speedup:** all 31 intervals contain the exact p.
- Obfuscated DNF:
  - w=56: p=2.22e-16, ratio 1.004, cost 1.65e5 against Monte Carlo 1.46e19 (8.9e13 times cheaper).
  - w=8 is a dense Monte Carlo leaf: cost 1.10e6 against Monte Carlo 5.0e4.
- Trigger k=10..80: exact with 0 evaluations (k=80: p=4.14e-25).
- Trigger with a 20-variable dense body: ratio 1.029–1.033 at 1.8e5 evaluations (k=80: p=2.68e-25, Monte Carlo 1.21e28).
- Blocks of 6 variables: exact with 0 evaluations.
- Dense 16-variable blocks: cost 1.69e7 to 4.03e8 for d=2..6. Monte Carlo is cheaper for d≤3; speed-up 1.96 at d=4 and 187 at d=6. Times 8.9 to 528 s; every other run took at most 1.2 s.
- Threshold of blocks: ratios 1.075–1.093; kb=800 has p=1.87e-26 at cost 1.31e5 against Monte Carlo 1.74e29.

**Arguments:** every Part 1 and Part 2 interval contains p.
- Linear hash k=12/16/20/24: Part 1 exact. Proofs have 329/1269/5717/32910 steps, checked in 0.0/0.2/2.1/81.4 s. Part 2 ratios 1.088/1.079/1.093/1.085.
- SPN with 2 rounds, k=8/12: Part 1 exact. Proofs 278/697 steps, Part 2 ratios 1.027/1.074.
- SPN with 3 rounds, k=16 (|C|=609, p=6.68e-6): no proof within 1200 s. Part 1 exact after 1.09e8 pilot evaluations in 659 s.
- SPN with 3 rounds, k=20 (|C|=756, p=9.54e-7): Part 1 gave no answer within 900 s. Proof of 25,944 steps, checked in 39.5 s, Part 2 ratio 1.004 with 1024 samples.

**Surprise:** samples grow from 16,384 at k−j=0 to 16.8M at k−j=10 (ratio ≤1.2). At k−j=12 the 2e7 cap is hit (ratio 1.42). All 7 intervals contain p=1.137e-13.

**Context width:** cw=w (3 or 5) in all 7 rows. The n=20 and n=24 rows contain their exact p (0.393 and 0.215). n=800, t=8: p in [3.93, 3.95]e-46 (ratio 1.004), DNNF size 33,927, 1024 samples, 11.1 s.

**Janson:** 0/200 violations against exact rational enumeration. Certified intervals:

| n | interval | ratio | time |
|---|---|---|---|
| 1e4 | [0.141, 0.148] | 1.039 | 0.8 s |
| 1e5 | [7.57, 7.84]e-3 | 1.035 | 11.0 s |
| 2e5 | [4.33, 5.07]e-7 | 1.167 | 50.3 s |
| 1e6 | [4.99, 5.15]e-6 | 1.030 | 194 s |
| 2e6 | [6.18, 7.35]e-22 | 1.187 | 71.0 s |

For the 2e6 row, Monte Carlo would need 1.62e24 evaluations for the same ratio.

**CFTP:** exact p (Fraction) is contained in every certified interval and every Harris–Janson window.

| L | p | certified interval | ratio | runs | time |
|---|---|---|---|---|---|
| 20 | 0.0231 | [0.0207, 0.0269] | 1.29 | 2.34e5 | 22 s |
| 40 | 4.90e-4 | [4.15e-4, 6.06e-4] | 1.46 | 4.42e5 | 103 s |
| 60 | 1.04e-5 | [8.36e-6, 1.35e-5] | 1.61 | 6.76e5 | 294 s |

The Harris–Janson window spans a factor 25 to 2.6e4. The bias is at most 0.015, below e^0.02.

**Local thresholds:**
- Chain, m=1600: log10 p = −20.188, certified [−20.305, −20.083], ratio 1.664, contains p, point estimate −1.2% off, Monte Carlo 1.76e22, 441 s.
- Cubic graph, N=1500: certified [−23.879, −23.614], ratio 1.842, Monte Carlo 3.27e25, 618 s.
- Cubic graph, N=100: [−3.050, −2.959], ratio 1.234, overlaps the 1e7-sample Monte Carlo interval.
- CFTP at θ=1.5 and 2.5: ratios 2.13 and 2.88 at log10 p = −71.80 and −169.76, both contain p.
- Coverage: 16 runs, 0 misses, median ratio 2.05.

**Affine:** all 15 intervals in E1–E6 contain the exact value, and E7 has 0 misses in 600 runs (148/150 tight in each of its four groups).
- E1: ratio 1.045 with presolve, 1.042 with the affine envelope (K=1.39), against Monte Carlo 1.16e18.
- E2: p=4.30e-31, K=1.38, against Monte Carlo 4.1e34.
- E3: DFSB gave ratio 28.7 in 79 s; presolve gave 1.08 in 0.02 s.
- E4: ratio 1.042. E5: XPT ratio 1.040.
- E6a: ratio 1.041 in 0.24 s. E6b: cap 16 gives ratio 1.006.
- Total 111 s.

**Second-order check:** 382 trials, 0 violations, median E3 0.0637.

**Independence numbers:** chain log p = −263.71, independence gap 63.89. Every certified interval contains log p; maximum widths are 7.30 at N=1e5 and 0.073 at N=1e9.
