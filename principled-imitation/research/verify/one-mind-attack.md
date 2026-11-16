# Adversarial verification of part one-mind (research/prove-c/one-mind.md)

Role: adversary. Key: one-mind. Status: COMPLETE.

Scripts: research/verify/code/one-mind_attack_*.py with outputs .out next to them.

## Findings (ordered by severity; filled in as found)

### F1 (MAJOR). The negative claims about "one member kept for good" for a stochastic human are not supported by the examples given

Where: one-mind.md Section 5.2 ("for a stochastic human no version holds (Section 3)"), Section 6 table, row "stochastic human", column "one member for good" ("none either: a member s of F in Example 3.1 has TV(Q_s, Q_P) >= 1 - (1 - eps)^3"), Section 8.2 item 4 ("for R4 and R6(b) the answer is negative") and item 5 ("Example 3.1 answers it in the negative for members of the class, whether drawn per run or kept for good").

Evidence. Example 3.1 and Proposition 3.2 refute every rule that draws a member from the posterior (per run, or once at the end). They do not refute a rule that selects one member deterministically by weight or by posterior probability, which is what R6(b) is about ("a single consistent program is selected only at the end"; Theorem 5.5 holds for the highest-weight consistent member). In Example 3.1, for any data whose asked inputs are distinct, the posterior weight of P is w(P)·P(D) = ½·Π_i P(y_i|z_i), while a member s of F consistent with the data has w(s)·s(D) = ½·Π_i P(y_i|z_i)·Π_{z fresh} P(s(z)|z), strictly smaller as soon as one input is fresh. So the maximum-a-posteriori member, and the highest-weight member with positive likelihood, is P itself, and its run law equals Q_P exactly (TV = 0) in every round. The same holds in Proposition 3.2 (w(s) = 1/(2|F|) < ½ = w(P), equal likelihoods up to the factor 2 per confirming round, and |F_z| = R·2·4^(R-1) is huge). Checked numerically in research/verify/code/one-mind_attack_map.py (output .out): with N_z = 10, eps = 0.1, exact Bayes over all 1024 functions and P, the MAP member is P in 100% of 2000 simulated data sets of every size up to 8 distinct questions.

The deeper reason. A single stateless hypothesis nu answers the calls of a run by independent draws given the inputs (Definition 1.2), exactly as the human does (A1). The dependence that breaks R4 in Example 3.1 is created only by mixing over hypotheses with a per-run draw. A single member kept for good cannot produce it; for such a member the run law differs from Q_P only through its single-call kernels, and the hybrid inequality TV(Q_nu, Q_P) <= E_{Q_P}[Σ_{j<=T} TV(nu(.|x_j), P(.|x_j))] (replace the human by nu one call at a time along the human system's run) reduces the question to single-call accuracy on the human system's inputs, which is the kind of quantity a likelihood-based Occam bound controls (with a square root via Hellinger). I have not proved a stochastic R6(b), but the examples in the file give no reason to believe it fails, and the obvious candidate (penalised-likelihood selection) succeeds on both of them.

Required change. Restrict the negative statements to members drawn from the posterior; state the stochastic version of R6(b) (single member selected by weight or penalised likelihood) as OPEN; change the Section 6 table cell to "posterior draw: none (Example 3.1); deterministic selection: open; the MAP member is the human in Examples 3.1 and 3.2"; change Section 8.2 items 4 and 5 accordingly. Conclusion 3 of Section 6 ("The committee is needed for a stochastic human") is overstated for the same reason: what the examples show is that the posterior draw per run is not enough; a well-chosen single member may be.

### F2 (MINOR). Corollary 4.4(b) does not name the set G of good runs for class B

Corollary 4.4(b) concludes that a member of class B "needs n >= L/(8 delta) questions". Theorem R3 (note.md, Definition before it) is relative to a set G of good runs, and a lower bound on Pr[more than m unfaithful calls] gives a lower bound on the failure probability only if runs with that many unfaithful calls are outside G. For class A the file names G (runs with fewer than L/4 answers 1). For class B it does not, and the natural choice is not available: a run of a wrong member g_â is, call for call, the run that the human g_â would produce, so no G defined from the run alone separates it. A G that works is "fewer than L/4 calls whose answer differs from g_{a*} at its input", which depends on the human and is tolerated trivially with m = ceil(L/4) - 1 and failure 0. Then the conclusion holds, but only for this rather artificial G. Required change: state G for class B, or state 4.4(b) only for class A (where it is clean) and keep class B as a statement about the number of unfaithful calls.

### F3 (MINOR). Example 3.1, conclusion about the mixture: "at most eta/n in every one of these rounds" holds on the event D_t, not unconditionally

The bound TV(Q_{M^(t)}, Q_P) <= (t-1)/N_z <= eta/n is proved on D_t (distinct asked inputs). Off D_t the posterior of P is not ½ and the bound is not shown. The sentence should say "on the event that the asked inputs are distinct, which has probability at least 1 - eta/2". The lower bound for the posterior draw is correctly stated in expectation.

### F4 (MINOR). Proposition 2.5: the closing sentence "the bound (2.2) cannot be improved by more than the factor (1 - 1/L)(1 - 1/K)" is empty for K <= 1

For K <= 1 the lower bound (2L(L-1)/(L+1))(K-1) ln 2 is <= 0. The series S(L, K) itself is still a valid lower bound (my independent evaluation: S(3, 1) = 2.202 against the upper bound 3.119), so the claim should be restricted to K > 1 or stated through S(L, K). Also the example needs N_z >= n^3/eta top-level inputs and a class of L^(N_z) + 1 members; this is legitimate for a lower bound with K fixed, but the note should say that the extremal class is huge.

### F5 (WORDING). Remark 3.4 is a heuristic presented with a definite conclusion

"Marking by a tilt is paid for at the linear rate" is derived from the mean drift of the log-odds only (no concentration, no handling of the case where the tilt hypothesis's deviations after a marked answer are themselves stochastic and the human is stochastic). The file labels it "a computation, not a theorem", which is honest, but Section 6 and the summary use it as settled. It should be called a heuristic in the summary table and kept out of the note's claims. Also the phrase "its total contribution to Σ_t TV is of order L times the nats it can lose" is not what the computation gives: with odds decaying like exp(-eta t/L), Σ_t eta·w_t(nu) is of order L·w_0(nu) (or L·ln(1/w_0) after the odds reach 1), not L times the nats lost; the order is right only up to this logarithm.

### F6 (WORDING). Section 6, conclusion 2 ("The committee is needed for low stakes") says more than Propositions 4.2 and 4.3 show

The lower bounds are for rules that deploy a member of the class chosen before the run's input is seen. Remark 4.5 itself shows that in class B a single deterministic program outside the class, the posterior's plurality vote (there g_0 ≡ 0), uses fault tolerance as well as the mixture. My simulation agrees (research/verify/code/one-mind_attack_r5.out: n = 30, N = 60, L = 12, Pr[at least 3 unfaithful calls] = 0.0005 for the vote, 0.0955 for the first consistent member, 0.0067 for the mixture). Since the researcher's wish is "one program", the honest reading is: one member of the class is not enough for low stakes; one program computed from the committee (its vote) is enough in the examples, and whether it is enough in general is open (the file's 8.1 item 6). The table of Section 6 should add this column or footnote; otherwise the reader takes "committee needed" as "no single program works".

## Checks that found nothing wrong

* **Theorem 2.1 (R4), line by line.** Steps 1 to 4 are correct for runs of variable length, stochastic hypotheses and semimeasures, with a deterministic human. The only places where variable length matters (the question at call J is asked only if the run has a J-th call; Pr[σ >= j] uses j <= T^f) are handled by Lemma 1.4(a). The one-round inequality E[m_t | D] >= E_z[ψ_L(u(z))]/L, which carries the whole proof, was tested exactly (enumeration of all runs) on 2912 random instances with 1 to 5 calls, random STOPs, 2 to 9 hypotheses of which about 60% stochastic or semimeasures: the largest ratio of right side to left side was 1.000000 (equality at L = 1, as it must be), never above 1 (research/verify/code/one-mind_attack_r4.py, .out). On the path family of Example 2.4 the one-round inequality is attained with equality (uniform deviation positions, w(f) -> 0), so Step 3 cannot be improved. The candidate's symmetry proof (Remark 2.3) is also correct; its constant 2L follows from u/2.
* **Proposition 2.5.** Independent evaluation of S(L, K) and of the chain bound reproduces the file's numbers (S = 13523.3 for L = K = 100, ratio 1.951 to L K ln 2) and the ordering lower <= integral <= S <= upper in all cases tried; a direct Monte Carlo of the protocol at fresh inputs (4000 rehearsals) gives Σ E[u_t] = 2.202, 23.004, 39.176 against S = 2.202, 23.017, 39.202 (research/verify/code/one-mind_attack_sharp.py, .out). The chain transition probability 1 - u(L-1)/(2L) is correct.
* **Example 3.1 and Proposition 3.2** (as refutations of a stochastic R4 for the posterior draw per run): the total-variation values (3/2)ε(1-ε) and ½, the posterior odds 1 (Example 3.1) and the update rules ×1, ×2, ×0 (Proposition 3.2), and the loss rate 1/(2R) were re-derived by hand and are correct. The refutation is valid: the class may depend on n, and K = 1 bit is fixed. See F1 for what they do not refute.
* **Proposition 4.2.** The formula Pr[C >= c] = (k/(N+k))(1-(1-1/N)^(L-c+1)) agrees with 3 × 400000 independent simulated runs (N = 10, L = 6, k = 4) within sampling error; the mixture's frequencies are below C(L, c)/N^c (research/verify/code/one-mind_attack_r5.out). The numerical constant 0.11 (actually 0.117) re-derived: E[k/(N+k)] >= ½(1-1.1/N)^N >= 0.165, Bonferroni factor >= 0.95, and L - ceil(L/4) + 1 >= 3L/4.
* **Proposition 4.3(a).** The adaptive argument (each question tests one index; the set tested along the all-zero path has at most n elements) is correct; the arithmetic (15/32)(9/32) = 0.132 >= 1/8 for n >= 16, L <= n is correct. The condition that the member is chosen before the run's top-level input is necessary, and the file says so. (b): the event Dm and the per-call bound 1/N + 1/n = 3/(2n) are correct; the conditioning on the complement of Dm is handled informally but correctly (count calls that are unfaithful while Dm has not yet occurred).
* **Proposition 5.1, Example 5.2, Example 5.3.** Re-derived; correct. Example 5.2 needs equal weights with f last or the ι-perturbation, which the file gives.
* **Theorem 5.5 and Corollary 5.6.** Re-derived: the supermartingale (1-B_t)e^(r_t), the martingale Π(1-m_t)/(1-β_t/L) (well defined because β_t/L <= 1 - w_t(f)), Step 3 (if the mixture's run is faithful it visits the first deviation input of g), and the posterior-mass argument of 5.6 (E[w(Bad_c)] <= e^(-c), divided by w(V) >= w(f)) are correct, with the stated constants and confidence 1 - 2δ.

## Citations

* M. Strens, "A Bayesian framework for reinforcement learning", Proceedings of the 17th International Conference on Machine Learning (ICML 2000), pp. 943-950: authors, title, venue and year confirmed by web search in this session (dblp and mlanthology entries); the content (sample one model per trial from the posterior and act on it) confirmed from abstract-level sources, full text not opened.
* I. Osband, D. Russo, B. Van Roy, "(More) efficient reinforcement learning via posterior sampling", Advances in Neural Information Processing Systems 26 (NIPS 2013), pp. 3003-3011, arXiv:1306.0940: confirmed by web search in this session (abstract): one posterior sample per episode, regret bound Õ(τS√(AT)). The file uses no statement of it; the attribution is correct.
* S. Ross, G. Gordon, J. A. Bagnell, "A reduction of imitation learning and structured prediction to no-regret online learning", AISTATS 2011: correct from my memory; not opened.
* The file uses no literature result as a black box. Correct as far as I can check: all proofs are self-contained.

## What is not new

* Lemma 1.5 is the standard telescoping identity for Bayes mixtures (the potential of the halving / weighted-majority analyses).
* Theorem 2.1 is the deterministic-target analogue of posterior sampling per episode (Strens 2000; Osband, Russo and Van Roy 2013); its sharp constant 2L²/(L+1) and Proposition 2.5 are, as far as I know, new but elementary.
* Proposition 5.1 and Example 5.2 are the scaffold version of a classical fact of online learning: a learner that predicts with an arbitrary consistent hypothesis can make |H| - 1 mistakes, while the halving algorithm makes at most log2 |H| (N. Littlestone, "Learning quickly when irrelevant attributes abound: a new linear-threshold algorithm", Machine Learning 2 (1988) 285-318; the halving bound log2|C| confirmed from abstract-level sources by web search in this session; the |H| - 1 example for consistent learners is folklore, quoted from memory). The file should cite this; the new element is only that deviations hide one another along a run.
* Step 1 of Theorem 5.5 is the standard Occam bound for a countable class with prior weights, in its adaptive (supermartingale) form (cf. Blumer, Ehrenfeucht, Haussler, Warmuth, "Occam's razor", Information Processing Letters 24 (1987) 377-380, for the i.i.d. version; quoted from memory). Proposition 4.3(a) is a needle-in-a-haystack lower bound.

## The researcher's tests (notes.md Section 5)

* **Guard.** R4 to R6 bound averages over the closed system's own top-level distribution; a property that the scaffold produces with small probability gets a correspondingly small share of the guarantee. Nothing in this part addresses inputs with a property absent from training beyond what the closed system induces. Not a defect of the part, but Section 5.1 of the note should not suggest more.
* **Machine.** Every bound is linear in K = log2(1/w(f)). For a real human under a universal prior K is astronomically large, so 2L·K ln 2/n is vacuous at any feasible n; the comparative statements (factor 2L/(L+1), factor 2, failure of the first-consistent driver, failure of members for low stakes) survive the change of machine, the absolute bounds do not.
* **Referent.** Under A1 a hypothesis cannot tell rehearsal inputs from deployment inputs, so it cannot model the data-collection process; the theorems hold whatever the hypothesis does. Passed, given A1.
* **Copy.** The part says correctly (Section 6, item 4) that nothing distinguishes the human's program from another member with the same closed-system behaviour. F1 adds: in Examples 3.1 and 3.2 the MAP member is the human itself, so the copy test is less hopeless than Section 6 suggests for deterministic selection.
* **Budget.** n single-call questions; one question per round; short tasks. Passed, except that Proposition 3.2 and Remark 3.3(ii) show that a single program per run for a stochastic human by posterior draw needs whole recorded runs (N·L answers).
* **Rock.** No abstention in this part; not applicable.
* **Horizon.** Outside the part; Corollary 4.4 makes the dependence on fault tolerance explicit, which is the right place.

## Verdicts

| statement | verdict | note |
|---|---|---|
| Lemma 1.4 | HOLDS | re-derived |
| Lemma 1.5 | HOLDS | standard |
| Theorem 2.1 (R4), constant 2L²/(L+1), stochastic hypotheses, variable length | HOLDS | one-round inequality tested exactly on 2912 instances, max ratio 1.000000 |
| Corollary 2.2 | HOLDS | |
| Remark 2.3 (candidate's proof correct) | HOLDS | |
| Proposition 2.5 (sharpness) | HOLDS WITH CHANGE | restrict the "(1-1/L)(1-1/K)" sentence to K > 1 (F4); numbers reproduced |
| Example 3.1 (stochastic R4 refuted for posterior draw per run) | HOLDS WITH CHANGE | valid for posterior draws; does not refute deterministic selection (F1); mixture bound only on D_t (F3) |
| Proposition 3.2 | HOLDS | re-derived |
| Remark 3.3 | HOLDS | (ii), (iii) quote other files, not re-checked |
| Remark 3.4 | NOT VERIFIED | heuristic; the "order L times nats" step is loose (F5) |
| Proposition 4.2 (R5, class A) | HOLDS | formula confirmed by simulation |
| Proposition 4.3 (R5, class B) | HOLDS | |
| Corollary 4.4 | HOLDS WITH CHANGE | (b) needs a named G (F2) |
| Remark 4.5 | HOLDS | vote confirmed by simulation |
| Proposition 5.1 (R6(a) upper) | HOLDS | not new (Littlestone 1988 analogue) |
| Example 5.2 | HOLDS | |
| Example 5.3 | HOLDS | |
| Remark 5.4 | (OPEN) | |
| Theorem 5.5 (R6(b)) | HOLDS | re-derived with constants |
| Corollary 5.6 | HOLDS | |
| Section 6 (implications) | HOLDS WITH CHANGE | stochastic "member for good: none" and "committee needed" overstated (F1, F6) |
| Section 8.2 items 4, 5 (R6(b) negative for stochastic human) | BROKEN | Examples 3.1/3.2 do not refute deterministic selection; MAP picks P (F1) |

Status: COMPLETE.
