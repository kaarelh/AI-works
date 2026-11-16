# Adversary's report on `research/prove-c/property-online.md` (part property-online: Theorem Pr5, Rules N and NH, the rehearsal corollary, the limits, the randomised version, the comparisons with the Bayes mixture) and, against it, on Sections 8.3 and 8.4 of `note.md`

Role: adversary. Status: complete.

The file under attack is `research/prove-c/property-online.md` (Sections 0 to 10; "the file"). The earlier stub of this report (1.7 KB, written by an interrupted verifier) was a list of intentions; per the instructions it was overwritten. Two scripts that interrupted verifier left in `verification/code/` (`property-online_attack_finite.py` with its output, and `property-online_attack_game.py`, whose output is empty) were inspected. I re-ran parts (B) and (C) of the first (part (A) had complete saved output, which I checked against the script); I did not re-run the second (an exhaustive search with up to 1.5 million states per instance) and replaced it by my own smaller exhaustive search, `property-online_attack_core.py`.

## Hand check of the proofs (this session)

I re-derived, line by line: Lemma 1.3; Lemma 1.4 (a)-(f) (for (c) both the mixture route and the direct convexity route, including the identity G_v(s) = ∫ e^(ηs − vη²/2) φ(η) dη); Theorem 2.1 and the five-step check of the lead's proof; Example 2.3 (both phases of the claim, the tie-breaking, and N* ≥ √n·arcsinh(√n) for η = 1/√n, δ = 1/2, β = 1/(2n)); Proposition 2.4; Theorem 3.1; Corollary 3.2 (a)-(c), including the inequality e(2Λ+4) > 2Λ+3+ln(2Λ+4); Theorem 3.3 and Corollary 3.4 (weight w(f)/2 gives K+1 bits, hence K+3); Proposition 3.5; Proposition 3.6 (a) and (b), including the closed forms √n/(√(1+n/d²)+√n/d) and √n/(√(2+n/d²)+√n/d); Proposition 3.7 (grid; the constants 3/√2 and 2√2); Proposition 3.8 (ln(1+u) ≥ u − u² on [−1/2, ∞)); Propositions 4.1, 4.3, 4.4; Propositions 5.1, 5.2; Lemma 6.1; Theorem 6.2 (a)-(d); Theorem 6.3 including (6.2) and the constant e/(e−1); Example 6.5; Proposition 6.6 (steps (1)-(5), including ϱ = 1 − μ₀²/(8e) and C(μ₀)); Example 7.1; Proposition 7.3; Proposition 7.4 (performance-difference telescoping); Lemma 7.5; Theorem 7.6 (identity (7.1), the supermartingale and Ville's inequality); Corollary 7.7; Theorem 7.8; Proposition 8.1 (posterior weights of the memorisers, μ_k ≥ 1/2 iff k·log₂(A/p) ≤ K − 1); Proposition 8.2.

No arithmetic or logical error was found in these proofs. The findings below concern hypotheses, scope of the prose, and the literature.


## Computations of this report (all run in this session)

* `code/property-online_attack_core.py` -> `code/property-online_attack_core.out`. (1) Exhaustive game search: for 11 small families of set tests (|X| <= 3, |Y| <= 3, up to 8 tests, depth 8 to 14), every question, every human answer and every tie-break among minimisers, all reachable states. Largest S^2/RHS of (3.1) for Rule N: 0.344; of Theorem 3.3(i) for Rule NH: 0.254; largest V/(K(B)+2) over pure histories (Theorem 3.3(ii)): 0.60, reached on the 2^m-table family of Proposition 3.5 with m = 3 (V = 3 = m, the lower bound of Proposition 3.5 attained). No counterexample. (2) Example 2.3 re-simulated: count = min(n/2, N*) exactly for n = 100, 400, 2500, 10^4. (3) Rehearsal, exact enumeration of all coins (scaffold with L = 2, adaptive second question, 4 questions, 3 answers, 3 tests, n = 1..8, Rules N and NH): E Delta_n(B) = (L/n) E S_n(B) to all printed digits for every test (Theorem 6.2(a), Lemma 6.1), and the one-sided bound (c) holds (max N_n = 1 against K(B)+2 = 3.58). (4) Proposition 8.1(a): brute-force posterior over all memorisers (N = 4, A = 2, p = 0.4, K = 3) equals (1-p)·mu_k to 10 digits for k = 0..3. (5) The ledger rule (Finding m1). (6) Condition (I) (Finding m3).
* `code/property-online_attack_finite.py` (written by the interrupted verifier; part (A) output already saved; parts (B), (C) re-run by me) -> `code/property-online_attack_finite.out` and `code/property-online_attack_finite_BC.out`. (A) exact safety game on small finite families; (B) two tests with values in [0, 1]; (C) Proposition 2.4.
* `code/property-online_attack_ex23rehearsal.py` -> `.out`: Example 2.3 carried over to rehearsal (L = 1, random parity of the question): the deployed rate of the never-given answer under the rule of Pr5 is 0.0299 at n = 40000, i.e. 1197/n, against ½·√n·ln n = 1060 and the Rule NH bound K(B)+2 = 18.3. So the file's sentence in Section 6.2 that the lead's rule "can come within a factor 2" of its own bound also holds in rehearsal, not only on adversarial sequences (the file proves it only for sequences).

## Findings, ordered by severity

No FATAL finding. No MAJOR finding: I could not break any numbered statement, and every proof I re-derived is correct. The findings concern hypotheses stated too strongly, prose that claims more than the theorems, one loose bound, and one computability gap.

### MINOR

**m1. For every fixed finite family of set tests and finite Y, bounded books (O(1) for all n, on every sequence) are achievable; the order √n is forced only for families that grow with n (set tests) or for tests with values in [0, 1].** The ledger rule: classify questions by their type tau(x) = (the sections B_x)_B (finitely many types when the family and Y are finite); for each type keep D_tau(y) = (times the imitator gave y) − (times the human gave y) at questions of that type, and answer with argmin_y D_tau(y). Since Σ_y D_tau(y) = 0 and the imitator always raises a minimal entry, max_y D_tau(y) <= 1 and min_y D_tau(y) >= −(|Y| − 1) for ever, and S_n(B) = Σ_tau Σ_{y ∈ B_tau} D_tau(y), so |S_n(B)| <= (#types)·(|Y| − 1) for all n. Computed: three families (6, 10, 30 tests), 200000 adversarial rounds, largest book 4, 10, 17 against the bounds 10, 60, 50, where (3.2) gives 1777 to 1950. The exact safety game of `property-online_attack_finite.out` part (A) gives least guaranteed bounds c* in {1, 2} on 20 small instances, while the adversary pushes Rule N's books to 5 or 6 within 20 to 40 rounds. The bound is exponential in the size of the family, so this does not compete with Theorem 3.1 for large or countable families, and it does not contradict Proposition 3.6 (whose family has d >= √n tests). But the prose overstates: the heading of Section 3.3 "The two-sided rate cannot be improved beyond the logarithm" and the first sentence of Section 6.5 "Proposition 3.6 shows that they cannot be improved much there" should say "uniformly over families of about √n tests" (or "for tests with values in [0, 1]", see m2). The note's editor should not write that √n is optimal for a given family.

**m2. For tests with values in [0, 1], two tests already force √(n/2): Proposition 3.6 can be strengthened, and the relevant literature statement is Spencer's lower bound as reported by Bárány.** Take questions x = v in [−1, 1]^2, answers {0, 1}, b_k(v, 1) = max(v_k, 0), b_k(v, 0) = max(−v_k, 0), and a human who gives the answer the imitator does not give; the increment vector is ±v, and the adversary plays v orthogonal to the current books with max-norm 1, so ‖S_t‖_2^2 grows by at least 1 per round and max_k |S_n(B_k)| >= √(n/2) for every rule. Computed (`property-online_attack_finite_BC.out` (B)): 315 at n = 10^5 against √(n/2) = 224, for Rule N and the rule of Pr5. Bárány (arXiv:2412.08238v1, Section 1; I read it in this session via the arXiv HTML) reports Spencer's value of the max-norm game in R^d as between √(1 − 1/d)·√n and √(2 log 2d)·√n; the file quotes this correctly (its uncertainty about the typesetting of √(1 − 1/d) is resolved: that is what the source shows). So "√n is forced once there are about √n tests" is a statement about set tests only.

**m3. Condition (I) of Proposition 6.6 is stated for every vector S, and then fails for every family that contains a test together with its complement (more generally, whenever some non-zero combination Σ_B π(B)·S(B)·b_B(x, ·) is constant in y at every question).** With the family {B, complement of B}, Y = {0, 1}, the direction S = (1, 1) gives m_x(S) = 0 with ‖S‖_π = 1 (`attack_core.out` (6)). Families closed under complement are the natural ones ("correct" and "incorrect"). The proof uses (I) only at the books actually reached (S_{t−1}), and reachable books of such a pair satisfy S(B) = −S(complement), on which line the ratio is 1/2; so the proposition holds with (I) required only on the linear span of the reachable book vectors (or on the set of vectors S that are signed sums of increment vectors). The file's Reading (i) names one-sided tests as the case where (I) fails; this second, more common failure is not mentioned. Verdict: HOLDS WITH CHANGE.

**m4. Proposition 2.4 is correct but loose: the factor (1 + ln n) on the test-independent term is an artefact of the proof.** By Proposition 5.2, the rule of Proposition 2.4 is exponential weights on the signed tests with the decreasing rate η_t = c/√t, and the standard analysis of exponential weights with a non-increasing rate (the potential (1/η)·ln Σ π·e^(η·...) is monotone in η) gives |S_n(B)| <= ln(2/π(B))/η_n + ½·Σ_{t<=n} η_t <= √n·(ln(2/π(B))/c + c), with no ln n. (Source: N. Cesa-Bianchi and G. Lugosi, Prediction, Learning, and Games, Cambridge University Press 2006, Section 2.3, the time-varying-rate theorem for the exponentially weighted forecaster; from memory, not checked in this session, and stated there for losses in [0, 1] and N experts; the extension to countably many experts with a prior and losses in [−1, 1] is routine but I have not written it out.) Exhaustive check (`property-online_attack_finite_BC.out` (C)): on 15 small instances and on long runs with d up to 100 tests, the largest ratio |S_t(B)|/(the ln-free bound) is 0.84. Consequence for the prose: the sentence after Proposition 2.4, "Mixing over rates (Section 3) is better in both respects", is true for the complexity term but overstated for the horizon term. Verdict: HOLDS (the stated bound is true; a sharper one exists).

**m5. Proposition 4.2 claims computability for Rule N (and the potentials (b), (c) of Lemma 1.4) for tests with values in [0, 1], but the clock v counts non-zero increments, and "g = 0" is undecidable for computable reals.** Under hypothesis (i) a value b_B(x, y) is a computable real; whether b_B(x_t, a_t(x_t)) − b_B(x_t, y_t) is exactly 0 cannot be decided in general, and the slope c^N(s, v) jumps with v. So the rule is computable for set tests (as for Rule NH) and for tests with rational values (or with decidable equality), not under (i) alone. Repair: either restrict (i) to rational-valued tests, or use the clock of Lemma 1.4(a) (rounds) or a clock Σ_t |g_t| (which is continuous; I have not checked that the potential with that clock is a balancing potential). Verdict: HOLDS WITH CHANGE.

**m6. "Obtained without a posterior" (Section 6.2, after Theorem 6.2; also Corollary 3.4's "tests alone give the halving bound").** With the tests B_ν = "the answer is not ν's" of a class in the family, the halving part of Rule NH puts the slope 2^(V−1) exactly on the B_ν that are still pure, that is, on the hypotheses ν that agreed with the human every time the imitator and the human differed at a pair separating ν; the score is then a weighted vote of the hypotheses still consistent on those rounds. This is the halving / weighted-majority algorithm over the class, which is a posterior over deterministic hypotheses in all but name. The statement is correct; the contrast drawn with the mixture ("without a posterior") should be stated as "with the halving algorithm's weights in place of the Bayes posterior". Verdict: Corollary 3.4 HOLDS; wording.

**m7. The rehearsal one-sided and two-sided bounds are per run; the budget in human answers carries a factor L².** Theorem 6.2(a) bounds the per-run discrepancy by L·√((2Λ(B) + 1.39 + ln(n+1))/n) (up to the factor (1 + 1/n)); to make it at most ε needs n of order L²·(2Λ(B) + ln n)/ε² asked calls. The file states the rates "per call slot", which divides by L and hides this. Under the researcher's budget test the number of human answers needed for a per-run guarantee is therefore L²·Λ/ε², and for the one-sided bound (c) it is L·(K(B)+2)/ε. Neither is wrong in the file; the editor should state the per-run form.

### WORDING

**w1.** Example 2.3 and "What (c) and (d) say": the factor-2 comparison is proved for a sequence chosen in advance; in rehearsal it is only simulated here (see the computations above), so "his rule can come within a factor 2 of this" should say "on adversarial sequences (Example 2.3); in a simulated rehearsal also".

**w2.** Proposition 3.7: its bound (3/√2)·√(V·Λ₂) + O(√(V/Λ₂)·ln ln V) has a larger leading constant than (3.2)'s √2·√(V·Λ) and is smaller only for astronomically large V; the summary's "Proposition 3.7 reduces it to order ln ln n at the cost of the constant" is accurate, but the editor should not present Proposition 3.7 as an improvement for any practical n.

**w3.** Section 5.4: Perchet's Theorem 3.2 is for λ-almost every checking rule and its proof is stated almost surely ("P_{σ,τ}-as"), with a one-sided conclusion (lim sup of the difference <= 0, two-sided by applying it to complements). The file's "weights in place of 'almost every'" is right; it could add that Perchet's statement is asymptotic, with no rate.

**w4.** Corollary 7.7(b) needs the questions of rehearsal to be functions of the past and of randomness independent of the human's coins for the regret bound Σ E κ_t <= K·ln 2; the file says so in the proof but not in the statement.

## Citations checked

| Cited work, as the file cites it | Bibliographic data | Does it state what is attributed? | How checked |
|---|---|---|---|
| Bárány, "A special balancing game, Victor Grinberg's question", arXiv:2412.08238v1, Section 1 | correct | yes: "Balancing games were introduced by Joel Spencer"; max-norm game in R^d has value between √(1 − 1/d)·√n and √(2 log 2d)·√n | read in source this session (arXiv HTML) |
| Lee, Noarov, Pai, Roth, arXiv:2108.03837v3, Theorem 2.1 and Theorem 5.1 | correct | yes: "For any T >= ln d, Algorithm 1 ... AMF regret bounded by R_T <= 4C√(T ln d)"; Theorem 5.1 has t >= 64 ln|H|/ε²; "It is equivalent to the results of Perchet [2015]" | read in source (PDF text) |
| Gupta, Jung, Noarov, Pai, Roth, arXiv:2101.01739v1, Theorem 3.2 | correct (ITCS 2022, DOI 10.4230/LIPIcs.ITCS.2022.82) | yes: η = √(ln(2|G|n)/(2T)), E[α] <= 1/(rn) + 2√(2 ln(2|G|n)/T) | read in source |
| Vovk, Takemura, Shafer, "Defensive forecasting", arXiv:cs/0505083, Theorem 1 and closing section | correct | yes: Theorem 1 ("ensures K_0 >= K_1 >= ..."), the proof's three cases, the remark for S_n not depending on p, and the open directions "multi-label classification" and "(a) Hoeffding's inequality, (b) the central limit theorem, (c) the law of the iterated logarithm" | read in source |
| Perchet, arXiv:1301.2663v1, Theorem 3.2, Proposition 3.2, remarks on Lehrer, Oakes and Dawid, SSV | correct | yes, quotations verbatim (see w3 for the asymptotic, almost-sure form) | read in source |
| Sandroni, Smorodinsky, Vohra, "Calibration with many checking rules", Math. Oper. Res. 28 (2003) 141-153 | correct (vol. 28, no. 1; DOI 10.1287/moor.28.1.141.14264) | the file relies on Perchet's description (checking rules depending on the current forecast), which I confirmed in Perchet; the paper itself not read by me | bibliographic data by web search (INFORMS, DBLP) |
| Chernov, Vovk, arXiv:1006.0475v1, Theorems 8, 9 | correct | Theorem 8 is the integral bound with dη/(η ln²(1/η)) on [0, 1/e]; Theorem 9: L_T <= L_T^ε + 2√(T ln(1/ε)) + 7√T | read in source (PDF text) |
| Farina, Perdomo, "Defensive generation", arXiv:2602.21390v1 (Feb 2026) | correct (submitted 24 Feb 2026) | abstract consistent with the file's description (online outcome indistinguishability, T^(−1/2) rate); Definition 1 and Theorem 1 not checked | abstract read |
| Spencer 1977, Blackwell 1956, Hart and Mas-Colell 2001, Cesa-Bianchi and Lugosi 2003, Lehrer 2001, Littlestone 1988, Littlestone and Warmuth 1994, Kivinen and Warmuth 1997, Robbins 1970, Kakade and Langford 2002, Dwork et al. 2022, Hoeffding 1963, Foster et al. 2011, Foster and Kakade 2006, Luo and Schapire 2015, Koolen and van Erven 2015, Abernethy et al. 2011 | not checked by me | the file marks each as "not read" / "memory" / "read" honestly; none of them is used in a proof (Section 5 opening: every proof is self-contained) | not checked |

No citation was found to misattribute. Section 10.1, item 1 ("the true order is √(n·ln n) if the value of Spencer's game has that order, which I believe (memory)"): Bárány's report gives Spencer's lower bound for the max-norm game as √(1 − 1/d)·√n, without a logarithm; I found no source in this session for a lower bound with the logarithm, so the item should stay OPEN and should not lean on that belief.

## The researcher's seven tests (research/understand/notes.md, Section 5)

1. *Guard.* For a property R in the family that the human always has (one-sided), Theorem 3.3(ii) bounds the violations by K(R) + 2 in total, at inputs of every kind, including inputs that a guard makes new: this passes the guard test for one-sided properties in the family, and it is the part of the work that does what the researcher asked ("outputs keep meeting the criterion, where those of SI might not"; Proposition 8.1 is his requested "concrete example where SI keeps taking Ls"). For two-sided properties restricted to a new kind Q, the book moves only when questions of kind Q are asked; at a single new input the rule's answer is whatever balances the other books (Example 7.1). The test catches: the guarantee is about frequencies on the imitator's own inputs, not about any one new input.
2. *Machine.* The price K(B) = log₂(1/π(B)) is relative to the chosen weights on tests, so a reference-machine constant; it is a constant of the property, not of the human. Passes in the sense he asks for (the constant is not K(P)), with the usual machine dependence.
3. *Referent.* Tests see only pairs (x, y) of the asked human; there is no hypothesis about how the data were made. Passes. (With the tests B_ν of a class, Corollary 3.4, the referent problem of the class returns.)
4. *Copy.* Fails, as the file says (Section 7.4, Proposition 7.3): the deployed object is a book-balancing rule; at a question its answers are a mixture over rounds of point masses that matches rates of tests and nothing else. The tilt (Theorem 7.6) is a sampler but still not a copy.
5. *Budget.* n single-call questions, each a call of the scaffold of ordinary length; per-run accuracy ε needs n of order L²·(2Λ(B) + ln n)/ε² (finding m7); one-sided rate ε per run needs L·(K(B) + 2)/ε. The human is not needed after rehearsal. Passes, with the L² made explicit.
6. *Rock.* The rule always answers; no abstention. Passes.
7. *Horizon.* Per-call frequencies do not control runs (Proposition 7.3, total variation >= 1/2 for every n; the toy: root exact 0.57-0.63 against 0.48). Proposition 7.4 covers outcomes whose continuation value is a test of the family. The test catches what the file already states.

## What is not new

* Lemma 1.3 is the potential-based approachability step / defensive forecasting with a forecast that the tests do not see (Hart and Mas-Colell 2001; Cesa-Bianchi and Lugosi 2003; Vovk, Takemura, Shafer 2005), as the file says.
* Theorem 2.1 (Pr5) for finitely many tests is a special case of Lee, Noarov, Pai, Roth (2022), Theorem 2.1 (constant 4 in place of √2 at the best rate), and its potential is Spencer's hyperbolic cosine for balancing games; for countably many weighted tests it is exponential weights over signed tests with a prior, via the reduction of Proposition 5.2 (Abernethy, Bartlett, Hazan 2011). The digest and the file found no published statement of exactly this form; I found none either.
* Theorem 3.1 is a NormalHedge-type parameter-free bound (Luo and Schapire 2015; Chernov and Vovk 2010) transferred by the same reduction; Proposition 3.8 is iProd (Koolen and van Erven 2015).
* Theorem 3.3(ii), Corollary 3.4 and Proposition 3.5 are the halving algorithm and the standard mistake-bound lower bound (Littlestone 1988).
* Proposition 3.6 is the Pusher's strategy of Spencer's balancing game (finding m2: the version for real vectors needs only two coordinates).
* Proposition 5.1 is Blackwell's quadratic potential; Theorem 6.3 is Azuma-Hoeffding plus a multiplicative (Freedman-type) supermartingale; Proposition 6.6 is a standard negative-drift argument (of the kind of B. Hajek, Adv. Appl. Probab. 14 (1982) 502-525; from memory); Proposition 7.4 is the performance-difference lemma; Lemma 7.5 and Theorem 7.6 are exponential tilts driven by exponentiated gradient (Kivinen and Warmuth 1997), the online form of multiaccuracy-by-tilting (Dwork et al. 2022, as the file says, not read by me); Proposition 4.4 is a direct reduction from the halting problem.
* New, as far as I can tell: the combination in one deterministic rule of the two-sided bound with the complexity under the root for countable weighted families and the sharp one-sided count (Rule NH); Example 2.3 (the single-rate rule has no fast one-sided rate); the rehearsal corollary with its one-sided form and Example 6.5; Proposition 8.1 as an instance of the researcher's request.

## Sections 8.3 and 8.4 of note.md, checked against the file

* Theorem Pr5 and its proof: correct (my check agrees with the file's five-step check; the absolute convergence of the sum for an infinite family is not said in the note and is needed).
* The sentence "the argument is the one behind Blackwell's approachability theorem and behind forecasting that passes countably many checking rules": must be made exact as in the file's Section 5.4 (checking rules independent of the current prediction: Lehrer 2001; Perchet's survey, Theorem 3.2; not Sandroni, Smorodinsky and Vohra, whose rules see the forecast). Confirmed in Perchet's text this session.
* The corollary: correct as an expectation over the rehearsal (Theorem 6.2(a)); the note does not state its assumptions (A3 for the protocol's coins, A1 at the asked calls, the asked call uniform over the L positions with void rounds), and the comparison is with the human on the imitator's own questions.
* "For a bad kind of answer that the human never gives, the imitator gives it at most (ln(2/π(B)) + 1/2)/√n of the time per call": true for the single-rate rule, which really comes near it (Example 2.3; also in rehearsal, computed above). With Rule NH the bound is (K(B) + 2)/n per call slot. The note should state the second.
* 8.4 bullet "a property of complexity k is matched to within about k/√n": true for Pr5; with Rule N √((2k ln 2 + ln n)/n). "Being the answers of this particular human is a property of complexity about K": true only for a deterministic human.
* 8.4 bullet "The rate": as the file says (Section 8.2, MODIFIED), K/n is the mixture's rate for divergence; for test frequencies of a stochastic human both are 1/√n; for one-sided tests and a deterministic human Rule NH has (K(B)+2)/n. I agree with the modification.
* 8.4 bullet "Single calls, not runs": root exact 0.62 in the note; the file reports 0.57 to 0.63 over its runs; consistent.
* 8.4 bullet "A fresh rule for each run": Example 6.5 makes it exact.

## Verdicts

| Statement | Verdict | Note |
|---|---|---|
| Lemma 1.3 | HOLDS | re-derived |
| Lemma 1.4 (a)-(f) | HOLDS | re-derived; (c) by two routes |
| Theorem 2.1 = Pr5 (note 8.3) | HOLDS | lead's proof correct; absolute convergence to be said for infinite families |
| Example 2.3 | HOLDS | proof re-derived; simulation exact; also carries over to rehearsal (simulated) |
| Proposition 2.4 | HOLDS | correct but loose by (1 + ln n) on the second term (m4) |
| Theorem 3.1 | HOLDS | re-derived; exhaustive search max ratio 0.344 |
| Corollary 3.2 | HOLDS | re-derived |
| Theorem 3.3 | HOLDS | re-derived; exhaustive search: 0.254 (i), 0.60 (ii) |
| Corollary 3.4 | HOLDS | "without a posterior" is wording (m6) |
| Proposition 3.5 | HOLDS | standard; attained in exhaustive search |
| Proposition 3.6 | HOLDS | correct; the surrounding prose overstates optimality for fixed families (m1); for [0,1]-valued tests two tests suffice (m2) |
| Proposition 3.7 | HOLDS | re-derived; not better in practice (w2) |
| Proposition 3.8 | HOLDS | re-derived |
| Proposition 4.1 | HOLDS | |
| Proposition 4.2 | HOLDS WITH CHANGE | Rule N's clock is not computable for real-valued tests (m5) |
| Proposition 4.3 | HOLDS | |
| Proposition 4.4 | HOLDS | |
| Proposition 5.1 | HOLDS | Blackwell's potential |
| Proposition 5.2 | HOLDS | |
| Section 5 (literature relations) | HOLDS | all checked citations accurate; Section 10.1 item 1 should not rely on the remembered √(n ln n) |
| Lemma 6.1 | HOLDS | exact enumeration agrees |
| Theorem 6.2 (rehearsal corollary, note 8.3) | HOLDS | exact enumeration agrees; state the per-run budget L² (m7) and the assumptions in the note |
| Theorem 6.3 | HOLDS | re-derived |
| Remarks 6.4, Example 6.5 | HOLDS | |
| Proposition 6.6 | HOLDS WITH CHANGE | (I) as stated fails for complement-closed families; require it only on reachable books (m3) |
| Example 7.1, Example 7.2 | HOLDS | |
| Proposition 7.3 | HOLDS | |
| Proposition 7.4 | HOLDS | re-derived (telescoping) |
| Lemma 7.5 | HOLDS | re-derived |
| Theorem 7.6 | HOLDS | re-derived |
| Corollary 7.7 | HOLDS | independence of the questions from the human's coins should be in the statement of (b) (w4) |
| Theorem 7.8 | HOLDS | exact identity re-derived |
| Proposition 8.1 | HOLDS | brute force agrees to 10 digits |
| Proposition 8.2 | HOLDS | |
| Section 8.2 "What remains of K ln 2/n against 1/√n" (MODIFIED) | HOLDS | agree with the modification of the note's bullet |
| note 8.4 bullets | HOLDS WITH CHANGE | as listed in the previous section |
