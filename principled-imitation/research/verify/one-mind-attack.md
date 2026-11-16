# Adversarial verification of part one-mind (research/prove-c/one-mind.md)

Role: adversary. Key: one-mind. Status: IN PROGRESS (written in pieces).

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

