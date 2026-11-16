### 8.3 An imitator built from tests alone

Tests are here sets B of pairs (question, answer), in a countable family 𝓑 fixed in advance, with weights π(B) > 0 of total at most 1 and prices Λ(B) = ln(1/π(B)) as in Section 8.2. In round t the imitator fixes a rule a_t: X → Y; then a question x_t and the human's answer y_t arrive, depending in any way on the past and on a_t. Let g_t(B) := 1[(x_t, a_t(x_t)) ∈ B] − 1[(x_t, y_t) ∈ B], let S_n(B) := Σ_{t≤n} g_t(B) be the *book* of B, and V_n(B) ≤ n the number of rounds t ≤ n with g_t(B) ≠ 0.

**Rule NH.** With G_v(s) := (v + 1)^(−1/2)·exp(s²/(2(v + 1))), a test with book S and count V before round t has the *slope* c_t(B) := ¼·(G_{V+1}(S + 1) − G_{V+1}(S − 1)) + σ·2^(V−2), the last term only if V ≥ 1 and all its non-zero increments had one sign σ. The rule a_t(x) is an answer y that minimises Σ_B π(B)·c_t(B)·1[(x, y) ∈ B].

**Theorem Pr5 (matching all tests on any sequence; proved here).** Let Y be finite. Under Rule NH, on every sequence, for every n and every test B:

(i) S_n(B)² ≤ (V_n(B) + 1)·(2Λ(B) + 1.39 + ln(V_n(B) + 1)), hence |S_n(B)| ≤ √((n + 1)·(2Λ(B) + 1.39 + ln(n + 1)));

(ii) if the human's answer was never in B, the imitator's was in B in at most log₂(1/π(B)) + 2 rounds; if it was always in B, the imitator's was outside B in at most as many.

*Idea of the proof.* Each test has a potential u ≥ 0, starting at 1, that grows in a round by at most slope times increment. The rule minimises the slope-weighted score over all answers, the human's among them; so Σ_B π(B)·u (absolutely convergent) never grows, and u ≤ 1/π(B). Half of u is G_V(S), giving (i); the other half doubles at each non-zero increment while all have one sign, giving (ii). Proof: `proofs/property-online.md`, Lemmas 1.3 and 1.4, Theorem 3.3.

Nothing is assumed about the human (not A1, not A2); no randomness is used. Nothing is said about tests outside the family, or about any single answer.

*Lower bounds (proved here).* (ii) is optimal up to the 2: among 2^r tests of weight 2^(−r), every rule gives, against some human, r answers in a test this human never satisfies (Proposition 3.5; standard). In (i), √n is forced in general: for some family of √n tests every rule lets a book reach (√2 − 1)·√n within n rounds (Proposition 3.6). For a fixed finite family it is not: another rule keeps the books bounded, exponentially in the family's size (Proposition 3.9). Whether the logarithms are needed is open.

*A class as tests.* Halve the weights and add, with weights w(ν)/2, the tests "the answer is not ν(x)" for the functions ν of a weighted class. If the human is one of them, (ii) gives at most K + 3 rounds with an answer other than the human's (Corollary 3.4). This is the halving algorithm (Littlestone 1988; standard); for a person the bound is empty, like that of Theorem R1.

*One rate.* The simplest instance minimises Σ_B π(B)·sinh(η·S_{t−1}(B))·1[(x, y) ∈ B] and has |S_n(B)| ≤ ln(2/π(B))/η + n·η/2 (potential cosh(η·S); Theorem 2.1), that is √n·(ln(2/π(B)) + 1/2) for η = 1/√n with n fixed in advance. It has no fast one-sided rate: however its ties are broken, some human never satisfies a test of weight 1/(2n) in which the rule gives at least ½·√n·ln n answers (Examples 2.3 and 2.5); Rule NH gives at most log₂ n + 3.

**Theorem Pr6 (rehearsal with this imitator; proved here).** Rehearse as in Section 2 with a_t of Rule NH in place of the mixture, and deploy, for each run afresh, the rule of a uniformly drawn round. Assume A3, and A1 at the asked calls. Let d_B(a) be the expected number of calls of a run of the rule a with answer in B, minus the expected number of those calls at which the human's answer would be in B; Δ_n(B) := (1/n)·Σ_{t≤n} d_B(a_t) is this difference for a deployed run, given the rehearsal. For every test B:

(a) |E Δ_n(B)| ≤ L·√((1 + 1/n)·(2Λ(B) + 1.39 + ln(n + 1))/n);

(b) if the human never gives an answer in B, a deployed run has in expectation at most L·(log₂(1/π(B)) + 2)/n calls with an answer in B;

(c) with probability at least 1 − δ, for all tests at once, |Δ_n(B)| ≤ (L/n)·(|S_n(B)| + √(2n·ln(2/(π(B)·δ)))), which can be read off the record.

*Proof.* The asked call is the J-th, with J uniform on {1, …, L} (a shorter run asks nothing), so it is each of the L positions with probability 1/L, and by A1 its answer is a draw from P; so E[g_t(B) | past] = d_B(a_t)/L and E S_n(B) = (n/L)·E Δ_n(B); (a) and (b) follow from Pr5. For (c), S_n(B) − (n/L)·Δ_n(B) is a martingale with increments in intervals of length 2; apply the Azuma–Hoeffding inequality (standard; Hoeffding 1963) with failure probability π(B)·δ and sum over B (Theorems 6.2 and 6.3). ∎

So if "y is a correct solution of x" is a test, the deployed answers are correct as often as the human's would be on the same questions, up to (a). A2 is not used; the comparison is on the imitator's own questions, not with the human system. To bring the bounds below γ calls per run takes n of order L²·(2Λ(B) + ln n)/γ² in (a) and L·(log₂(1/π(B)) + 2)/γ in (b). The bounds average over the rounds: against a fair coin every single rule, kept for good, is off by 1/2 (Example 6.5).

### 8.4 What this does not give

* **Tests outside the family.** With the single test "the answer is 1", the human f(x) = x mod 2 and the questions 1, 2, 3, …, the rule (ties to the least answer) keeps its book within 1 and is wrong in every round (Example 7.1).
* **Runs.** If a scaffold puts one question twice to a fair coin, every rule answers twice alike: total variation at least 1/2 from the human system for every n, with all tests matched (Proposition 7.3). In the toy problem of Section 11 the rule with one rate has an exact root in 62% of the runs, against 48% in the human system.
* **A choice, not a sample.** The answer balances books; at a fixed question it need not resemble a draw from P(·|x). A randomised version tilts a base sampler, such as the mixture, by exp(−Σ_B λ_t(B)·1[(x, y) ∈ B]), with λ_t computed from the books; against answers drawn from P its expected books obey the one-rate bound plus the base's cumulative divergence from the human divided by β·η, β being the strength of the tilt (Theorem 7.6). Open: one imitator with the mixture's bound under A2 and the test bounds without it, for a human who varies.
* **Against the mixture.** Let the class contain the human at K bits and give half its weight to tables that hold each question with probability p, with one of A good answers, and answer badly elsewhere. The mixture gives the bad answer, which the human never gives, with probability at least (1 − p)/2 at each of the first (K − 1)/log₂(A/p) new questions; Rule NH with this test at weight 1/2 gives it at most 3 times, against every human who never gives it (Proposition 8.1). The mixture is better for tests nobody listed (in Example 7.1, with a class of two, it errs in half a round in expectation), for whole runs (Theorem R2), and as a sampler. For a human who varies, both match frequencies at order 1/√n, which no imitator built from n answers can beat (Proposition 6.7; Le Cam's two-point argument, standard); K ln 2/n is the mixture's rate for the divergence.
* **Computation.** The rule is computable for decidable tests, computable weights with a computable tail bound, and a known finite set of candidate answers for each question, such as answers of bounded length (Proposition 4.2); with an unbounded answer set no rule that always halts works, even for one decidable test (Proposition 4.4). Enumerable weights were not examined.
* **Outside the closed system** nothing (Theorem N1).

*Attribution.* The method is not new: the step is Blackwell's approachability condition (1956) with an exponential potential, and with two answers the game is Spencer's balancing game (1977). The nearest published forms are online multivalid prediction (Gupta et al. 2022, Theorem 3.2; its tests see the forecast), defensive forecasting (Vovk et al. 2005, Theorem 1) and, for finitely many tests and one rate, Lee et al. (2022, Theorem 2.1). Rule NH's potentials are of the kind used by expert algorithms without a learning rate (Chernov and Vovk 2010; Luo and Schapire 2015) and by halving. Sandroni et al. (2003) is asymptotic and its rules see the forecast; for rules that do not, the asymptotic statement is Lehrer's (2001). Blackwell, Spencer, Lehrer and Sandroni et al. are cited through Abernethy et al. (2011), Bárány (2024) and Perchet (2013, Theorem 3.2, Proposition 3.2), Littlestone from memory; the other statements were read in the sources. We found no published statement of Pr5 in this form.

---

*For the assembly (not part of the section text).*

References of this section that are not in the list of `research/sections/related-work.md` (bibliographic data as given in `proofs/property-online.md`, Section 5, where each entry says who read what):

* Bárány, I. (2024). "A special balancing game, Victor Grinberg's question." arXiv:2412.08238.
* Chernov, A. and Vovk, V. (2010). "Prediction with advice of unknown number of experts." arXiv:1006.0475 (UAI 2010).
* Lee, D., Noarov, G., Pai, M. and Roth, A. (2022). "Online minimax multiobjective optimization: multicalibeating and other applications." arXiv:2108.03837 (NeurIPS 2022).
* Hoeffding, W. (1963). "Probability inequalities for sums of bounded random variables." *Journal of the American Statistical Association* 58:13–30. (From memory; standard.)
* Le Cam, L. (1973). "Convergence of estimates under dimensionality restrictions." *Annals of Statistics* 1:38–53. (From memory; the two-point argument is proved in full in `proofs/property-online.md`, Proposition 6.7.)
* Lehrer, E. (2001). "Any inspection is manipulable." *Econometrica* 69:1333–1347.
* Littlestone, N. (1988). "Learning quickly when irrelevant attributes abound: a new linear-threshold algorithm." *Machine Learning* 2:285–318.
* Luo, H. and Schapire, R. (2015). "Achieving all with no parameters: adaptive NormalHedge." arXiv:1502.05934 (COLT 2015).
* Perchet, V. (2013). "Approachability, regret and calibration; implications and equivalences." arXiv:1301.2663.
* Spencer, J. (1977). "Balancing games." *Journal of Combinatorial Theory, Series B* 23:68–74.

Already in that list: Abernethy, Bartlett and Hazan (2011); Blackwell (1956); Gupta, Jung, Noarov, Pai and Roth (2022); Sandroni, Smorodinsky and Vohra (2003); Vovk, Takemura and Shafer (2005).

Labels: Pr5 and Pr6 as fixed in `research/outline.md`, Addendum 3; no new label. Symbols used beyond the fixed list: γ (a number of calls per run), r (an exponent in the lower bound), p and A (parameters of the class of tables), G, c_t, S_n, V_n, g_t, d_B, Δ_n (defined where used).
