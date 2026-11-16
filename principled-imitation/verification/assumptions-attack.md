# Adversary's report on `research/prove-c/assumptions.md` (key: assumptions)

The part under attack is the sceptic's own: the caveats on A1 to A3, the definition of a closed system, the seven tests, the budget, what remains a bet, and the objections to the claim "rehearsal is a human-imitation protocol that works exactly as far as any protocol can". My task was to break its statements, to find what its prose says beyond its theorems, to check its citations, to apply the researcher's tests to it, and to make its objections stronger.

## 0. What was done, and the result

**Method.** I read the whole file and followed every proof. I compared every quotation of another file of the project with that file (`research/prove/lower-bounds.md`: Lemma 1.5, Theorems 1.6, 3.1, 3.3, 4.1, Corollaries 1.7, 2.2, Proposition 3.2; `verification/lower-bounds-check.md`: Propositions A1, A2; `research/prove-b/hellinger-runs.md`: Theorem 3.1; `ultranatural/note.md`: Proposition 8, Theorem 9 and the remarks after it; `research/understand/repo.md`: A9, D1, D2, E5, E8, E9, E11, F5, F8; `research/understand/notes.md`: Sections 1.2, 2.10, 2.13, 2.14, 3, 5, 6). I wrote three scripts that enumerate small instances exactly from the definitions; they share no code with the prover's scripts, and where a formula of the file is evaluated it is the thing compared:

* `verification/code/assumptions_attack_core.py` (output `assumptions_attack_core.out`, 28 seconds): Protocol R enumerated from first principles (the exact law of the data after every round, of every round's run, of the human's answers);
* `verification/code/assumptions_attack_episodes.py` (output `.out`, 34 seconds): a nested episodic scaffold enumerated exactly;
* `verification/code/assumptions_attack_lower.py` (output `.out`, 19 seconds): the lower bound of Section 6 against exactly optimal protocols, the patch-free theorem on every surviving set, the parts of A3, the budget.

The prover's two scripts were re-run; their outputs are reproduced to the last digit. Sources from the literature were opened where the session's network allowed (Section 5 says which). A second report on this part, `verification/assumptions-check.md`, appeared while I worked; I read its summary and its list of corrections after my scripts were finished and my findings M1 to M4 and most of the minor ones were fixed, and I say in Section 8 where the two reports agree and which two points I took up after reading it.

**Notation.** As in the file and in `research/outline.md`: L is the horizon of the scaffold, n the number of rehearsal rounds, K = log₂(1/w(P)) the weight of the human in bits, M^(t) the mixture of round t and T a uniformly chosen round. β(A) is the expected number of unfaithful calls of a run of the answerer A, and Λ(A) the expected sum over the calls of such a run of KL(P ‖ A). In the low-stakes statements θ is the fraction of the calls of a run that may be replaced (m = θL faults tolerated), δ the failure probability that is asked for, and δ_c the error probability of a certificate (0.05 where a number is given). ρ′ is the probability that the human's answer to the asked call differs from the answer the imitator gave there (Proposition 2.5). In m5, b is the number of bits that a table needs per recorded question.

**Result.** I could not break any numbered lemma, theorem, proposition or example by computation, and I found no error in a proof. What I found is in the layer above the proofs, and four findings change what the note may print:

1. **The certificate does not exist for the human of the problem statement.** The file concludes that "the theorem that carries the weight is V1 with R3" and that the budget test is "passed by the certificate". The certificate of Proposition 2.5 is passed by an imitator, the exact one included, with a probability that falls geometrically in the number of validation rounds, unless the human's answer is almost determined by the question. For a human who errs independently with probability 0.01 per call the exact imitator passes the 300 rounds of the file's budget table with probability 0.0025.
2. **Theorem 3.2(a) is a statement for each property, and the table of the seven tests says "for every property at once".** The simultaneous statement is false: the probability is above 0.9 in examples where L/n is 0.1 or less.
3. **The file's list of what A3 must contain is incomplete.** With rehearsal runs taken from a pseudo-random generator, parts (i) to (iv) hold as worded, the deployment is closed by Definition 4.1, and the conclusion of R1 fails with a floor that does not depend on n. The remedy list of objection O10 ("physical randomness for J_t") has the same gap.
4. **The closing statement "What survives of the claim" is not a theorem as worded.** It drops the hypothesis of a deterministic human twice, and its sentence on optimality holds for particular classes only.

Besides these there are thirteen minor findings and six of wording. Section 2 re-examines the seventeen objections and adds five. Among the additions, proved here and checked by computation: a lower bound that contains K for additive work, which the file lists as open (every protocol needs at least (1 − 2θ − 2δ)·K answers); and the exact cost of deploying the mixture of a uniformly random round (in an additive example 31 356 answers against 790 for a round drawn from the second half of the rehearsal).

## 1. Findings, by severity

### FATAL

None. Attempts that failed: counterexamples by exact enumeration to Lemma 0.2 (140 pairs of instance and member, with a human in the class, outside it, and changing after every answer), to the identity of Theorem 2.1(b), to Theorem 3.2(a) on every subset Q of X in 40 instances, to the supermartingale of Theorem 3.2(b), to Propositions 2.2, 2.5, 4.2, 4.3, to Lemma 1.6 and Theorems 1.7 and 1.8 on a nested scaffold with a human who is not deterministic, to the one-round inequality of Theorem 7.4(a) on every set of surviving members, to Proposition 7.5(b), and to Theorem 6.1 against the exactly optimal protocol of one block for all N ≤ 40, B ≤ 6. All hold; the numbers are in Section 6.

### MAJOR

**M1. The certificate (Proposition 2.5, V1(a)) is a result about a human whose answers are determined by the question; the conclusions drawn from it are stated without that hypothesis.**

*Where.* "In brief" (2) and (5); the table of Section 5, rows 2 and 5 ("passed by the certificate"); the paragraph on test 5 ("The certificate costs ln(1/δ_c)/(θδ) answers whatever K is: 300"); the last column of the first table of Section 6.2; Section 6.5 ("the affordable protocol is therefore: obtain an imitator by any means … and certify it; the theorem that carries the weight is V1 with R3, not R1"); O1 (ii); O9; O12; "What survives".

*Evidence.* The file's own Proposition 2.5(c) says that the mismatch rate ρ′ is at least (1/L)·E Σ_j (1 − max_y P(y|x_j)) whatever A is. For the exact imitator A = P the rate is ρ′ = (1/L)·E Σ_j (1 − Σ_y P(y|x_j)²), the probability that two independent answers of the human to the asked input differ. So:

* certificate (a), "no mismatch in m rounds", is passed by the exact imitator with probability (1 − ρ′)^m. For a human who gives the answer f(x) with probability 1 − e and one other answer with probability e, ρ′ = 2e(1 − e). With m = 300 (θ = δ = 0.1, confidence 95%): probability 0.55 for e = 0.001, 0.0025 for e = 0.01, 1.4·10⁻²⁶ for e = 0.1 (`assumptions_attack_core.out`, part G). With m = 29 958 (θ = δ = 0.01) the exact imitator of a human with self-agreement 0.999 passes with probability 10⁻¹³ (`assumptions_attack_lower.out`, part F);
* certificate (b) certifies β(A)/L ≤ V̄ + √(ln(1/δ)/(2m)), and V̄ tends to ρ′. Theorem R3 needs β/(θL) < 1. For e = 0.1, which is the human of the lead's toy computation (`results/toy_property.out`), ρ′ = 0.18 > θ = 0.1: the exact imitator certifies nothing, for every m;
* answers that are sentences have a self-agreement close to zero, and then ρ′ is close to 1 for every imitator.

The problem statement models the human as a probabilistic program. For that human the file offers, in other places, three things, none of which is the 300-answer certificate: frequencies of tests fixed in advance (V1(b)), at about 2·ln(2/(π·δ_c))/ε² answers for accuracy ε on a test of weight π (7.4·10⁴ answers for ε = 0.01 and π = 1; `assumptions_attack_lower.out`, part F), which say nothing about runs (`note.md`, Section 8.4, "single calls, not runs"); the L₂ distance of Remark 2.6, which bounds β only through β/L ≤ ½·√(|Y|·E_x Σ_y (A − P)²) and therefore costs about |Y|²·ln(2/δ_c)/(2ε⁴) chosen calls with two answers each (7.4·10⁸ calls for two possible answers and ε = 0.01, by Hoeffding's inequality for an estimator with values in [−2, 2]), and nothing for long answers; and the learning bound β ≤ L·√(K ln 2/(2n)), which needs A2 and contains K.

*Consequence.* Section 6.5 and sentence (5) of "In brief" must be split. For a deterministic human: checking costs ln(1/δ_c)/(θδ) answers and does not contain K. For the human of the problem statement there is no certificate of the number of unfaithful calls at a cost that does not contain K or |Y|; the budget test is then not passed by anything in the theory. Objection O9 ("answerable: the certificate") and the answer to O12 ("any single imitator, the last one included, can be certified by validation") hold for a deterministic human only. The part `research/prove-c/rehearsal-core.md` says this correctly in point (6) of its summary ("for other humans it certifies frequencies of tests, and under A2 also the number of unfaithful calls, at the rate √(K/m)"); the two parts should agree in the note.

**M2. "For every property at once" (table of Section 5, test 1) is false; Theorem 3.2(a) holds for each property fixed before the protocol's coins are drawn.**

*Evidence.* The theorem is correct as stated (for every set Q the probability is at most L/n; confirmed on all subsets of X in 40 random instances, where the largest ratio of the exact probability to L/n is 1.0000). The event "for some Q of a family" is not bounded by L/n: let X = [N], L = 1, the input uniform. The run of round T meets a singleton {x} that no earlier question met exactly if its input was never asked before, which has probability (1/n)·Σ_t (1 − 1/N)^(t−1): 0.915 for N = 50, n = 10 (L/n = 0.1); 0.954 for N = 200, n = 20; 0.976 for N = 1000, n = 50 (`assumptions_attack_core.out`, part C). A union bound gives 2^k·L/n for the 2^k properties of at most k bits, which is empty for k above log₂(n/L).

*Why it matters.* The researcher's guard F3 is a property chosen after the data ("a choice of variable such that it never triggers in train"). Theorem 3.2(a) does not cover a property that depends on the realised questions. What covers all guards at once is R1, at the price K (and at the rate √(K/n) per call for a human who is not deterministic). The table cell should read: "for each property fixed in advance, with probability at least 1 − L/n; for all properties together, as far as R1 reaches".

**M3. A3 "as the proofs use it" has a fifth part, which the file omits: the coins of every rehearsal run are fresh.**

*Where.* Section 0.2 ("parts (i) to (iv) are what a proof needs"); "In brief" (3) ("under them every guard and every hypothesis about the experiment is covered"); Section 3.1, last paragraph; Definition 4.1; O10.

*Evidence.* Inequality (0.4) of Lemma 0.2 is a statement about the calls of the realised runs τ_t and needs (i) and (iv) only. Theorem R1 is the statement Σ_t E Λ(M^(t)) ≤ L·K ln 2 about the functional Λ(M^(t)), an expectation over a fresh run of M^(t). The step from one to the other uses that, given 𝓕_{t−1}, the run τ_t has the law Q_{M^(t)}: fresh (z_t, ρ_t) and fresh draws of the imitator. The file places this in the words "a run of Π is generated" of Protocol R and not among the parts of A3. The note's own A3 does name "the bits of each run".

Counterexample (`assumptions_attack_lower.py`, part D). X = [64], L = 1, the human is f ≡ 0. A generator with a seed of k = 3 bits outputs, for seed σ, points of a set A_σ of 32 inputs. The class contains f with weight 1/2 and, for every σ, the function that is 0 on A_σ and 1 elsewhere, with weight 2^(−k−1). Rehearsal takes its inputs from the generator with one seed s; the deployed input is uniform on X and fresh. Then: (i) is void because L = 1; (ii), (iii), (iv) hold as worded; (C1) and (C3) of Definition 4.1 hold, and (C2) holds because (C2) asks only that fresh runs *can* be generated. The function of seed s is never refuted, and the deployed answer is wrong with probability at least 0.0497, 0.0550, 0.0555 for n = 10, 100, 1000 (floor (1/2)/(2^k + 1) = 0.0556), while with fresh rehearsal inputs it is 0.0610, 0.0061, 0.0006 and the bound of R1 is 0.0693, 0.0069, 0.0007.

*Consequence.* Add to A3: "(0) the coins of every rehearsal and validation run (the top-level input, the scaffold's randomness, the imitator's draws) are fresh: given the past, the run of round t has the law Q_{M^(t)}." Change (C2) from an ability to a fact about the runs that were used. In O10 the remedy "physical randomness for J_t" must read "physical randomness for every coin of the protocol". Example 3.3 shows the failure of (i); this example shows that (i) is not the only place where a seed hurts, and it does not need inputs that quote their run. The scale is that of Example 3.3: the floor is 2^(−k) times a constant, so for a long seed and a prior that does not favour the seed it is negligible. The finding is that the list of what the proofs use is incomplete, and the list of remedies with it.

**M4. "What survives of the claim" (end of Section 8) is not a theorem as worded.**

The paragraph says: "for a computation that we can run in advance and a human who answers its calls without memory, n answers … give an imitator whose run has at most L·K ln 2/n unfaithful calls in expectation; in the worst case over 2^K candidate humans no protocol needs fewer answers by more than a logarithmic factor; a given imitator can be certified at a cost that does not depend on K". Missing:

1. *the human is deterministic.* For the sampler of the problem statement the first number is L·√(K ln 2/(2n)) and the third clause fails (M1);
2. *A2 and the round.* The first clause is about the mixture of a uniformly random round under A2 and the five parts of A3;
3. *the quantifier of the second clause.* "No protocol needs fewer answers by more than a logarithmic factor" is proved for the block classes of `lower-bounds.md`, Theorem 3.1, and of Theorem 6.1 (critical calls, tolerance by replication). It is false of other classes: on the class of all functions on K inputs with additive work, the best protocol needs at most K answers and Protocol R with a random round needs between 16 and 173 times as many as the best protocol in the cases computed (findings m1 and m2); on the rare-points class of the referee of `lower-bounds.md` the factor is L/(10ε). The same quantifier is missing in the reading of Proposition 2.4 ("when 2^K candidates remain possible, some of them cost of the order of K·L/(δ·log(L/δ)) questions under every protocol"): a class of 2^K functions that differ at one input costs one question.

A version that is true: *for a computation that we can run in advance, a human who answers its calls without memory and is one of the weighted candidates, and fresh coins throughout, n answers to single calls drawn from the imitator's own runs give, for the mixture of a uniformly random round, a run with at most L·K ln 2/n unfaithful calls in expectation if the human is deterministic and at most L·√(K ln 2/(2n)) otherwise; there are classes of 2^K candidates and scaffolds for which every protocol needs at least a constant times K·L/(δ·log(L/δ)) answers; an imitator of a deterministic human can be certified at a cost that does not contain K; nothing is offered outside that computation, at rates below about 1/n, or for a human other than the one that answered.*

### MINOR

**m1. A lower bound with K for additive work exists and is elementary; the file lists it as open (end of Section 6.1; Section 10.1, item 4; O7 (iii) "for additive work there is no lower bound at all").**

*Proposition (adversary).* Let X = [K], let the class be all 2^K functions from X to {0, 1} with equal weights, let the scaffold make L calls at independent uniform inputs, and call a run good if at most m of its answers differ from the human's. The human system tolerates m faults with failure 0. For every protocol (questions anywhere, adaptive, randomised, n questions in expectation when the human is uniform on the class) and every deployed answerer (which may decline): if the run is good with probability at least 1 − δ for every member, then

  n ≥ K·(1 − 2m/L − 2δ).

*Proof.* Let the human f be uniform on the class and independent of all coins. The transcript is a function of the seed and of the values of f at the asked inputs, so given the transcript the values of f at the inputs that were not asked are independent fair bits. The inputs of the deployed run are independent of f and of the transcript, and the deployed answer at a call is a function of the transcript, of coins and of the run so far. So at every call whose input was not asked the answer differs from f with conditional probability at least 1/2 (exactly 1/2 for an answer in {0, 1}, and 1 for a refusal). The input of a call was not asked with probability (K − a)/K given the number a of asked inputs, and E[a] ≤ n. Hence E[number of wrong answers of the run] ≥ L·(K − n)/(2K). A good run has at most m wrong answers and every run at most L, so the same expectation is at most m + δL. ∎

K questions suffice (ask every input). The bound of R3 for this class is L·K ln 2/((m + 1)δ). With θ := m/L = 0.1 and δ = 0.1 the necessary number is 0.6·K and the bound of R3 is 69·K. Check: `assumptions_attack_lower.out`, part B (six cases; the least number of questions of the best protocol is between 1.16 and 1.5 times the lower bound).

*Consequence.* The sentence "The factor K is forced, also under low stakes (Theorem 6.1)" ("In brief" (2); test 5) is true for tolerance by replication with the factor B/(δ·log(B/δ)), and true for additive work in the weaker form n ≥ c·K. Whether the factor 1/(θδ) of R3 is ever needed for additive work stays open; in this class it is not. For O1 this closes an escape: also in the most favourable kind of work, fifty answers cannot serve a class of more than 2^83 candidates at θ = δ = 0.1.

**m2. The uniformly random round is the dominant cost in benign cases; O12 is not "answered" by Markov's inequality.** In the class of m1 Protocol R asks a uniform input in every round. Exact numbers of answers needed for failure δ (`assumptions_attack_lower.out`, part B):

| K | L | m | δ | lower bound | best protocol | Protocol R, mixture of a uniform round | round uniform in the second half | last mixture | bound of R3 |
|---|---|---|---|---|---|---|---|---|---|
| 200 | 100 | 10 | 0.10 | 120 | 172 | 3 136 | 606 | 395 | 12 603 |
| 200 | 100 | 10 | 0.01 | 156 | 181 | 31 356 | 790 | 482 | 126 027 |
| 400 | 1000 | 100 | 0.05 | 280 | 332 | 12 850 | 1 244 | 726 | 54 903 |

With probability t₀/n the uniform round lies among the first t₀ rounds, in which the mixture is not yet trained; so the factor 1/δ in the number of answers is here the price of the random round alone. Drawing T uniformly from the second half of the rounds keeps every guarantee of the file up to a factor 2 (Σ_{t > n/2} E Λ(M^(t)) ≤ L·K ln 2 gives E Λ(M^(T)) ≤ 2L·K ln 2/n, and the L/n of Theorem 3.2(a) becomes 2L/n) and removes the factor in this example (790 against 31 356). The file's own reply, "with probability 1 − η … its bound is 1/η times the average", restates the cost; its second reply, the certificate, is for a deterministic human (M1). The objection is answerable, by a late round.

**m3. Proposition 4.4 is tagged PROVED, and its claim of completeness ("the following and nothing else") is not a mathematical statement that the file proves.** Each of its five items holds. The list leaves out what other parts of this project offer on arbitrary inputs: the abstaining rules (the candidate's Ab1 to Ab3; a rule that takes the least probability over a set of weighty hypotheses is, when the human is in that set, dominated by the human on every input and fails visibly, at the price of abstaining at every new kind of input) and the mixture over all simple task laws (S2, at the price 2^k). Item 4 ("a top-level input outside the support of D₀ can be recognised by computation") needs a decidable support: for a D₀ given as a sampler, membership in the support is only semi-decidable, and for the stock of Proposition 4.2 the law is unknown.

**m4. The reading of Proposition 1.15 says more than its part (b).** "No other human system is available to any protocol that takes the human out of the loop" is proved for protocols all of whose questions are answered in the context of rehearsal. A protocol can make the other context occur: let the human's answers be used in runs that count during a first phase, or do not tell the human which runs count. Part (c) is offered as "one honest design in which a run does depend on every answer"; the run in question is a rehearsal run whose outcome is used for nothing, so a human who answers differently when nothing depends on the answer is not helped by it.

**m5. The referent test is passed only where R1 is not empty (Theorem 3.2(c), test 3, O11).** Theorem 3.2(c) bounds the prior weight of the hypothesis that knows the realised coins by the probability of guessing them. What matters is that weight against the human's, 2^(−K). The comparison is: the table of the data ("answer as recorded on the asked inputs, anything elsewhere") costs about b bits per recorded question, the human K bits, so the tables outweigh the human until n·b exceeds K. Exact illustration (`assumptions_attack_lower.out`, part G): X = [1024], the human f ≡ 0 with weight 2^(−K), tables with weights proportional to (2N)^(−|A|) (b = 11 bits). The mixture gives the table's answer at an input that was not asked with probability above 0.999 up to 8 questions for K = 100 and up to 81 questions for K = 1000, and with probability below 10⁻⁴ from 11 and from 101 questions on. This does not contradict the file (R1 holds, and spends its K ln 2 exactly there), but "passed under A3" should carry the proviso. In the regime of O1 (K larger than n times the bits of a question) the imitator is the table's, which is the researcher's F9 as he states it. For a human who is not deterministic there is a second point: a hypothesis that knows the realised *answers* is repaid by its likelihood, and what protects is the probability of the *questions* only: for an injective family D ↦ ν_D, E[w(ν_D)·ν_D(D)/P(D)] = Σ_D c(D)·w(ν_D)·ν_D(D) ≤ max_D c(D), where c(D) is the probability that the protocol asks the questions of D given its answers.

**m6. Objection O8 is classed "answerable by variants, each at a price"; no variant on the list keeps what the claim needs.** The three variants are: recorded runs of the human system (the human carries out whole runs, so small scaffolds only, by the file's own O3); runs driven by a rule that answers only where the weighty hypotheses agree (a price polynomial in 1/w(P), that is exponential in K, and the cited theorem bounds the sum of the cubes of the query probabilities, not the number of questions: see Section 5); a class restricted to hypotheses that cannot write harmful text (not a construction). So for a class of all programs, a large scaffold and one person who reads the questions, the objection stands as far as the researcher's requirement that the output must not harm the reader (D11 of the digest) is part of the claim. The class should be "fatal to that combination; answerable by restricting the class, which strengthens A2". Proposition 1.16 is an upper bound; "nearly all questions of any affordable rehearsal" reads it as a lower bound.

**m7. O6 and the first row of the table of Section 4.2: the human cannot be reset between rehearsal questions.** A1 for rehearsal means that the answer to question t does not depend on questions 1 to t − 1. With D₀ the point mass at the real task, one person answers n questions about the same task, each containing work of the imitator on it. Theorem 1.11 then applies with a second term that nothing makes small. The design that makes A1 true is one fresh person per question, which the researcher's rules allow ("a vast quantity of current humans to do fairly short monitoring tasks", digest of the notes, Section 1.1(c)). The file says in one sentence under the budget table what follows: the sampler is "a member of the pool, drawn afresh at every call" and the human system is a system of strangers. That sentence belongs in the caveat on A1.

**m8. Theorem 2.1(b), reading.** "The bound L·K ln 2 is attained in the limit exactly when the posterior weight of P tends to 1" needs W = 1 and a class in which no second member has the kernel of P on the asked inputs; in general the limit of the price is L·(ln(W/w(P)) − lim E ln(1/w_{D_n}(P))). The identity itself holds to 7·10⁻¹⁵ in 30 instances.

**m9. Units of the budget.** Section 6.2 converts answers to "human-years" at 8765.82 hours per year, which is every hour of the calendar, and in the next table counts a career as 10⁵ working hours. At 2000 working hours per year the figures of the paragraph "Human time" are 4.4 times larger: 6.9·10⁴ one-hour answers are 34.5 working years, not 7.9; the 300 answers of the certificate are 37.5 working days of eight hours, not 12.5 days. One slip of arithmetic in the same section: with 10⁴ answers the lower bound n ≥ 1.1074·K excludes classes of more than 2^9030 humans, not 2^9033.

**m10. Section 6.3, the size of K.** Landauer's figure is an estimate of learned memory content and the figure of Bartol and co-authors a measurement on synapses in a small volume of hippocampal tissue; neither "bounds K from above". They indicate orders of magnitude. The sentence is hedged in the file; the verb should change.

**m11. Theorem 1.9(b) and Section 9, part 10.** The file reports that a search found no ratio H²/Σ_i KL_i above 1/2. In a nested scaffold with a parent episode of three messages and two child episodes (m_e = 3) hill climbing finds 0.566 (`assumptions_attack_episodes.out`, part D). This is far below the proved 4m_e = 12 and below the constant 2 of sequential episodes; it only shows that 1/2 is not the right conjecture.

**m12. Two statements are made without proof.** (i) "V1(b) holds for tests of whole episodes … by the proof of V1(b) with episodes as calls; I do not state it separately" (Section 1.2): the pair (environment, transcript) of an episode inside a run with nested sub-episodes is not defined in the file. (ii) The chain remark after Proposition 6.3 ("every batch, of any size, learns at most one new link") is said to be immediate for strings that cannot be guessed; it is plausible and I did not prove it. Both are NOT VERIFIED.

**m13. Proposition 6.3, its reading, and O3: parallel answers are not always uncredited.** The proposition is correct. Its reading ("answers given in parallel are not credited by the bound") and O3 ("twenty years give twenty rounds whatever the number of people") are true of chains. If the inputs of the scaffold do not depend on the answers, the question of round t is a function of (z_t, ρ_t, J_t) alone, so all n questions can be drawn before any answer is given, and the answers can be collected in parallel; the data then have the law they have under Protocol R, and R1 holds as it stands for the mixture of the first T − 1 answers in a fixed order, T uniform. Task decomposition is not of this kind (its inputs are written by earlier calls), so the objection keeps its force there; it should be stated for scaffolds whose questions depend on earlier answers, and it is graded by the depth of that dependence. (The other report makes the same point in its Section 5.3.)

### WORDING

**w1. Example 3.5.** With the weights as written (1/2 for the human, 1/2 for the guards, 0.01 for the special guard) the total is 1.01. The numbers 0.0194 and 0.0196 are those of the prover's script, which gives the ordinary guards 0.49/(θ(θ + 1)).

**w2. Two lists disagree.** The summary table and Section 5 say that Section 10 of the candidate theory overclaims on tests 1, 3, 4, 5, 6; Section 10.2, item 8, says items 1, 2, 3, 5, 6.

**w3. Test 1 (ii) and the last mixture.** "Nothing of the kind is proved … `rehearsal-core.md` announces" refers to an earlier state of that file. Its present Propositions 6.1 to 6.4 give a bound for the last mixture on scaffolds whose inputs do not depend on the answers and examples in which it is worse.

**w4. Remark 2.6** is the collision estimator of the ℓ₂ distance from the literature on testing distributions (Section 4, item 9); it should be attributed, with its known weakness, which the remark states.

**w5. Proposition 1.15(c), "related to the mixed roll-outs" of Ross, Gordon and Bagnell.** Their mixture π_i = β_i·π* + (1 − β_i)·π̂_i lets the expert act at random steps of a roll-out (read in the source). The variant of (c) puts the human's one answer into the run. The relation is loose; "compare" is enough.

**w6. O15.** The researcher's own setting sometimes grants more than computation ("if you had a hypercomputer", digest of the notes, Section 1.1(c)); with that grant the objection is answered, without it answerable as the file says.

## 2. The objections of Section 8, attacked

The claim: *rehearsal is a human-imitation protocol that works exactly as far as any protocol can.* The file classes seventeen objections. I agree with the direction of every one. The table gives my class where it differs, and the paragraphs below give the evidence; "fatal" always names the part of the claim that goes.

| no. | objection | file's class | my class | reason for the change |
|---|---|---|---|---|
| O1 | K for a person | fatal to "reasonable number of answers" | the same, and wider | additive work is not an escape (m1); below K/b questions the imitator is the table of the data (m5) |
| O2 | critical steps | fatal to amplification of such work | the same | "reuse" is per run: the expected number of unfaithful calls grows with the number of later runs (S4) |
| O3 | short calls, few rounds | fatal on the researcher's numbers | the same for scaffolds whose questions depend on earlier answers | where the inputs do not depend on the answers, parallel answers are credited in full (m13); "twenty rounds whatever the number of people" is about chains |
| O4 | a fixed computation, not a person | fatal to "upload" | the same | |
| O5 | silent failures | fatal to "fails only obviously" | the same at a polynomial budget | abstaining rules give visible failure on any input at a price exponential in K; the file says so in half a sentence |
| O6 | A1 is false of people | answerable | answerable only by changing what is imitated | no reset between rehearsal questions; the design that makes A1 true is one fresh person per question (m7, S2) |
| O7 | "as far as any protocol can" | answerable by rewording | the same | the gap is larger than a logarithm on particular classes (m1, m2, M4) |
| O8 | the human reads what the prior wrote | answerable by variants | fatal to the combination: all programs, large scaffold, one reader | no listed variant keeps the three (m6) |
| O9 | A2 fails silently | answerable: the certificate | answerable for a deterministic human; otherwise only for discrepancies that a test of the family shows | M1 |
| O10 | A3 in practice | answerable by design | the same, with one more item | fresh coins for the runs, not only for J_t (M3) |
| O11 | hypotheses that model the experiment | answered | answered where R1 is not empty | m5 |
| O12 | a random round | answered | answerable, by a late random round | m2 |
| O13 | the human of rehearsal | answerable by design | the same | the variant of Proposition 1.15(c) is not such a design (m4) |
| O14 | the runs that matter | answered | the same | |
| O15 | not a computation | answerable | the same | w6 |
| O16 | additive slack | answered | the same | |
| O17 | the human system | outside the theorems | outside, and it is the premise of the only affordable regime | S3 |

Five objections that the file does not make, or makes in a subordinate clause.

**S1. The human of the problem statement is a sampler, and for a sampler the protocol has no certificate.** This is M1 as an objection. Without the certificate the affordable protocol of Section 6.5 ("obtain an imitator by any means … and certify it") does not exist: what an imitator obtained by other means does on its own runs can be compared with the human only test by test, and a test-by-test comparison of single calls says nothing about a run (`note.md`, Section 8.4). A learning guarantee then rests on R1, that is on A2 and on K. *Class: fatal to "works as a certificate" for a human whose two answers to one question differ with a probability above about θδ/ln(1/δ_c); answerable for answers from a small set at a cost of the order |Y|²/(θδ)⁴; answered for a deterministic human.*

**S2. Rehearsal on the real task puts one person to work on that task n times.** The closed system that the file lists first is one fixed research question with rehearsal runs on the question itself. Then every rehearsal question is a piece of work on the real task, written in part by the imitator, and the person who answers question t has answered t − 1 such questions. A1 fails by the design of the protocol and not by an accident of psychology, and the human learns the task from the questions; in the regime without low stakes, where n exceeds L, the person answers more calls than the human system has. The repair is a pool: one fresh person per question. The researcher's rules allow it. Its price is that the imitated object is a system of strangers who pass notes, which is the "bureaucracy" he doubts (digest of the notes, F23), and that K is the complexity of the pool's kernel. *Class: answerable by a pool, at that price.*

**S3. The premise of R3 is never tested, and R3 is needed exactly when the premise cannot be tested.** The low-stakes theorem assumes that the human system tolerates m arbitrarily replaced answers. The protocol never observes a run of the human system. A test of tolerance would need whole runs carried out by the human with answers replaced by every rule, which the budget excludes and no finite sample covers. There are two cases. If membership of a run in the good set G can be decided by computation, the probability that the imitator's run is good can be estimated by running the imitator, with no human answer and no theorem about imitation; R3 then predicts and does not certify. If it cannot be decided, the guarantee of R3 inherits δ₀ and m from an assumption about the human on inputs that the human system reaches only after faults. Proposition R3a of the note has the same form: "from every state, a call answered by the human raises φ" is a statement about the human at states that only wrong answers produce. *Class: outside the theorems, as O17, but it is the premise of the one regime in which the budget is not hopeless, and the note should say that it is assumed.*

**S4. Reuse does not amplify what must not fail.** The file names reuse as what survives O2: "the same answers serve every later run". A deployed imitator used for R runs has R·β unfaithful calls in expectation, each to be taken as written by an adversary (the file's O11). By R1 the guarantee for a deterministic human is one expected unfaithful call per n/(K ln 2) calls of the imitator, which is fewer calls than the human answered as soon as K exceeds 1.44 bits; and on the needle classes of N2 no protocol guarantees more than about 4n calls per failure (`lower-bounds.md`, Theorem 2.1, with N₀ = 2n). Reuse pays when every single run is low stakes and the runs' failures are separately tolerable; it does not pay when one bad output among the R can do the harm (the researcher's F19). `lower-bounds.md`, Theorem 7.1, has the matching lower bound for "all r runs correct". The same holds for selection: if the user keeps the best-looking of R runs, the kept run is unfaithful with probability up to 1 − (1 − β′)^R, where β′ is the probability that a run is unfaithful; the file's O14 covers this in the form E[N | S] ≤ E[N]/q. *Class: answered by the theory; it limits what "reuse" may be said to rescue.*

**S5. Break-even.** For one run and a deterministic human, rehearsal with the bound of R3 costs K ln 2/(θδ) answers plus the ln(1/δ_c)/(θδ) of the certificate, and the human system costs L answers. Rehearsal is cheaper only if L exceeds 2.4·10³ for K = 30 bits, 7·10⁴ for K = 10³, 7·10⁷ for K = 10⁶ and 7·10¹⁰ for K = 10⁹, at θ = δ = 0.1 (`assumptions_attack_lower.out`, part F), and only for a human system that tolerates the arbitrary replacement of a tenth of its calls. The rounds are sequential in the worst case, while a human system that is a tree can be run by many people in a time proportional to its depth. *Class: answered as arithmetic; it turns O1 to O3 into one inequality that a reader can check.*

**The claim, after the attack.** "Human-imitation": of the kernel of a pool of answerers of single calls (or of whole episodes), inside one computation fixed in advance. "Works": for a deterministic human, as a certificate at a cost without K, on the unverified premise of fault tolerance; for a sampler, only as the learning bound L·√(K ln 2/(2n)) under A2, which is a bet on the prior. "As far as any protocol can": on the block classes, up to a logarithm; on other classes the mixture of a uniform round loses a factor of order 1/δ to a late round (m2), and questions drawn from the runs lose a factor of order L/ε to chosen questions (Proposition A1 of the referee report on `lower-bounds.md`).

## 3. The researcher's seven tests, applied to the part

The tests are those of `research/understand/notes.md`, Section 5. The second column is the verdict of the file's Section 5; the third is what the test catches when it is applied to the file's own claims; the fourth is the verdict I would print.

| test | file's verdict | what the test catches | verdict to print |
|---|---|---|---|
| 1 guard | passed for a closed deployment of M^(T), "for every property at once", with probability 1 − L/n | the quantifier (M2); a property chosen after the data (his F3) is covered only by R1, at the price K; at an input of a new kind the behaviour is the prior's | passed for each property fixed in advance; for all properties together only as far as R1 reaches; not at single inputs; not for a kept last mixture in general; not outside a closed deployment |
| 2 machine | passed by the certificate and by Theorem 3.2(a) | the certificate exists for a deterministic human only (M1); "K small under an informed prior" (O1 (i)) and isolation (Theorem 7.4) are choices of machine, which the digest of the notes already says of the first (Section 6.1, constraint 6) | the rate 1/n and Theorem 3.2(a) are facts about the scheme; the constant K, the behaviour at rare inputs, and every route to a small K are the machine's |
| 3 referent | passed under A3 (i) to (iv); each part is needed | a fifth part is needed (M3); "negligible weight" is relative to 2^(−K), and below K/b questions the table of the data outweighs the human (m5), which is his F9 | passed under five conditions and where R1 is not empty |
| 4 copy | not passed | the deployed object of R1 is the Bayes predictor of the human, the object that he contrasts with a copy ("a probabilistic turing machine vs the bayesian thing you'd need to do to optimally predict it", digest, D3) | not passed |
| 5 budget | not passed by the learning theorems; passed by the certificate when calls are short and stakes are low | no certificate for a sampler (M1); the questions of the early rounds are the prior's garbage, which is his F27 ("asking stupid questions"), and by Proposition 1.16 up to L·K ln 2 questions may be of this kind; calendar years (m9); K is forced also for additive work (m1) | not passed; for a deterministic human, short calls and an assumed fault tolerance the check of a given imitator is affordable |
| 6 rock | passed: no abstention inside the closed system | at the top level the scheme is a whitelist of one task law (Proposition 4.4, item 4), which is the conservatism he accepts; the patch-free prior of Theorem 7.4 errs on the other side (certain and wrong on a patch) | passed inside, at the price of silent failures; a whitelist outside |
| 7 horizon | outside the theorems; R3 and the budget make it harder | the premise of R3 is assumed (S3); with A1 nothing is learned from call to call except through messages, which is his F24 ("it cannot learn") | outside the theorems, and against the scheme on his own numbers |

Three items of his list of failures (digest, Section 3) are not among the seven tests and bear on the part. *F29, hiding the difficulty in a step:* the framing moves the difficulty into three steps that no theorem examines, namely the prior (K), the scaffold (usefulness and fault tolerance) and closure. The file says each of these somewhere; the note should say them together. *F19 and D11, harm to the reader:* O8, with the class of m6. *F28, a scheme tuned to its example:* the scheme is general, the trained imitator is tuned to one scaffold and one task law (O4).

## 4. What is not new

Statements tagged NEW or PROVED in the file that are standard, with the source and with what I checked. "Read" means opened in this session; "search" means bibliographic data or an abstract seen in a search result of this session; "memory" means neither.

1. **Lemma 0.1 and Theorem 2.1(a)** (regret of the mixture against any member; the oracle inequality). The inequality −ln ξ(D) ≤ ln(1/w(ν)) − ln ν(D) and its expectation are the standard bound for Bayes mixtures (in this project: the attributions of `research/outline.md`, Addendum 2, item 2). The trade-off form min_ν {complexity/n + divergence} is the index of resolvability of A. R. Barron and T. M. Cover, "Minimum complexity density estimation", *IEEE Transactions on Information Theory* 37(4):1034–1054, 1991 (search: the definition R_n(p) = min_q [L(q)/n + D(p‖q)] is quoted in a correction notice; the paper was not opened). The form relative to the learner's own input distribution is the ε_N of Ross, Gordon and Bagnell (read; Section 5).
2. **Theorem 2.1(b)** (tagged NEW). The cumulative risk of the Bayes predictive distribution equals the divergence between the law of the data under the truth and under the mixture: the chain rule for KL, used in this form at least since B. S. Clarke and A. R. Barron, "Information-theoretic asymptotics of Bayes methods", *IEEE Transactions on Information Theory* 36(3):453–471, 1990 (memory). Writing it as the prior surprise minus the expected posterior surprise is one line.
3. **The uniformly random round.** Ross, Gordon and Bagnell state it in a footnote: "the same guarantee holds for the policy which uniformly randomly picks one policy in the sequence π̂_{1:N} and executes that policy for T steps" (read).
4. **Theorem 3.2(a)** (tagged NEW). The conversion of a bound summed over rounds into a bound for a random round, applied to one guard, which can be "hit for the first time" once; the file names the researcher's random-stopping note as its source. Nothing here is beyond that note and item 3.
5. **Theorem 3.2(b) and Proposition 7.9.** Likelihood ratios are supermartingales under the truth; the square-root version with the Hellinger affinity and Ville's inequality is standard (in this repository: E9(iv) and F1 of `repo.md`).
6. **Proposition 4.3** (the human asked with probability q). This is label-efficient prediction: N. Cesa-Bianchi, G. Lugosi and G. Stoltz, "Minimizing regret with label efficient prediction", *IEEE Transactions on Information Theory* 51(6):2152–2162, 2005 (search: bibliographic data and abstract). The file credits the digest of the notes; the digest names this paper.
7. **Proposition 6.3** (batches). Prediction with feedback delayed by b steps costs b times the regret, by running the predictor on b subsampled sequences: M. J. Weinberger and E. Ordentlich, "On delayed prediction of individual sequences", *IEEE Transactions on Information Theory* 48(7):1959–1976, 2002 (search: the abstract states that "the prediction strategy that minimizes the worst case regret … is obtained through subsampling of the sequence of observations" and mentions an extension to logarithmic loss; the paper was not opened). The proof of Proposition 6.3 keeps one term per batch, which is the same subsampling.
8. **Theorem 1.11 and Corollary 1.12** (a moving human against the best fixed sampler). The statement is the regret bound read for a moving target. The standard tool for a moving target is a prior over sequences that switch: M. Herbster and M. K. Warmuth, "Tracking the best expert", *Machine Learning* 32:151–178, 1998 (memory). The file does not use it; with it the comparison would be with the best human that changes a few times, at a cost of the order of the logarithm of n times the size of the class per change. "A human who changes is tracked only as well as the best fixed sampler" is therefore a property of Protocol R with a static class, not of every protocol.
9. **Remark 2.6.** The identity Σ(A − P)² = ΣA² − 2ΣAP + ΣP² with collision statistics is the ℓ₂ estimator of T. Batu, L. Fortnow, R. Rubinfeld, W. D. Smith and P. White, "Testing closeness of discrete distributions", *Journal of the ACM* 60(1), Article 4, 2013 (search: the arXiv preprint 1009.5397 says that the ℓ₂ distance is easy to test with a number of samples independent of the size of the domain, and that a small ℓ₂ distance does not give closeness in ℓ₁).
10. **Lemmas 1.3 and 1.6 and the episode as the unit.** Kuhn's theorem, as the file says. In this repository the same step is recorded for a person with latent state: `repo.md`, F8, last item ("Ville's bound survives for every chronological class with the person's predictive law given the observable history. With i.i.d. episodes and a class of predictors that restart at episode boundaries, E5 holds per episode (n = number of episodes)", E5 being that repository's theorem on the recovery of the model). The file does not cite it.
11. **Proposition 7.7.** The defining property of posterior sampling: given the data, the sampled model and the true model have the same law (W. R. Thompson, 1933; memory).
12. **Theorem 7.4(b).** The Occam bound of Blumer, Ehrenfeucht, Haussler and Warmuth (1987) with run distance; it is Theorem 9 of `ultranatural/note.md` (read), as the file says. Part (a) adds the symmetrisation of the candidate's R4.
13. **Example 2.3.** Under misspecification the posterior settles on the member nearest in divergence under the law of the data (R. H. Berk, 1966; memory); here the law of the data is made by the learner. The example is new as an example.
14. **Propositions 1.14, 1.15(b), 7.1(b), 7.8.** Two-point arguments.
15. **Proposition 2.5(a), (b).** The zero-failure binomial bound and Hoeffding's inequality; the observation that the mismatch rate dominates the total variation is elementary and, as far as I know, not in the cited literature in this form.
16. **Theorem 6.1** is new in this project as the combination of two constructions of `lower-bounds.md` (its Theorems 3.1 and 5.3); the file says so.

New, as far as I can tell: Example 1.1 and Example 1.10 as statements about this protocol, Theorem 1.7 to 1.9 in this form, Example 3.3, Definition 4.1, Theorem 6.1, Proposition 7.5.

## 5. Citations checked

| work | where the file uses it | what the file attributes to it | how checked | result |
|---|---|---|---|---|
| S. Ross, G. J. Gordon, J. A. Bagnell, "A Reduction of Imitation Learning and Structured Prediction to No-Regret Online Learning", AISTATS 2011 (arXiv:1011.0686v3) | after Theorem 2.1; Section 11; Proposition 1.15(c) | the guarantee is relative to ε_N := min_π (1/N)·Σ_i E_{s∼d_{π_i}}[ℓ(s, π)], "the true loss of the best policy in hindsight", an average over the state distributions of the learner's iterates | read: the PDF of the arXiv version, text extracted in this session | correct. The definition is verbatim. Theorem 3.1: "For DAGGER, if N is Õ(T) there exists a policy π̂ ∈ π̂_{1:N} s.t. E_{s∼d_π̂}[ℓ(s, π̂)] ≤ ε_N + O(1/T)". Theorem 4.1 has ε_N + γ_N + (2ℓ_max/N)·[n_β + T·Σ_{i > n_β} β_i]. The page range PMLR 15:627–635 is not on the arXiv page (memory) |
| H. W. Kuhn, "Extensive games and the problem of information", *Contributions to the Theory of Games II*, 1953 | Lemma 1.6; Section 11 | equivalence of mixed and behaviour strategies | not opened (memory: the theorem needs perfect recall; pages 193–216, Annals of Mathematics Studies 28) | the attribution fits; the lemma is proved directly in the file, so nothing rests on it |
| T. K. Landauer, "How Much Do People Remember? Some Estimates of the Quantity of Learned Information in Long-term Memory", *Cognitive Science* 10(4):477–493, 1986 | Section 6.3 | about 10⁹ bits of learned content | search: bibliographic data (dblp) and summaries that give "around 10⁹ bits"; the paper was not opened | bibliographic data correct; the figure is as reported; the file's use needs the change of m10 |
| T. M. Bartol, C. Bromer, J. Kinney, M. A. Chirillo, J. N. Bourne, K. M. Harris, T. J. Sejnowski, "Nanoconnectomic upper bound on the variability of synaptic plasticity", *eLife* 4:e10778, 2015 | Section 6.3 | at least 4.7 bits per synapse | search: title, authors, year, and "at least 26 distinguishable synaptic strengths, corresponding to about 4.7 bits"; the publisher's host could not be reached from this session | bibliographic data correct; the measurement is on hippocampal synapses, and the product with a synapse count of the brain is the file's own step, marked there as from memory |
| W. Hoeffding (1963); J. Ville (1939) | Section 11 | the two inequalities | not opened; standard | no objection |
| M. K. Cohen, M. Hutter, N. Nanda, "Fully General Online Imitation Learning", *Journal of Machine Learning Research* 23 (2022) 1–30 | O8, through two digests | a rule that answers only where the weighty hypotheses agree costs "a number of questions polynomial in 1/w(P)" | read: the PDF of arXiv:2102.08686v2, whose header carries the journal data | to be made exact. Theorem 1 (Limited Querying): E Σ_t θ_q(h_<t)³ ≤ \|A\|·α⁻³·(24·w(π^d)⁻¹ + 12). Theorem 2: the demonstrator stays in the top set for all t with probability at least 1 − α·w(π^d)⁻¹. The bound is on the sum of the cubes of the query probabilities; with α < w(π^d) it is of order w⁻⁴. It bounds a number of questions only when the query probabilities are 0 or 1 |
| Y. Li, C. Zhang (arXiv:2412.07057) | not cited in the file; `research/outline.md`, Addendum 2, makes it the source of the protocol on which this part comments | Stagger: one state per rollout put to the expert | read: the arXiv abstract page | title "Interactive and Hybrid Imitation Learning: Provably Beating Behavior Cloning"; comment "Accepted by NeurIPS 2025"; the abstract calls Stagger a "one-sample-per-round variant of DAgger". Log loss and deterministic experts are not in the abstract; I did not open the paper |
| results of this repository quoted through `repo.md` (D1, D2, E5, E8, E9, E11, F5, F8, A9) | Sections 5, 7, 8 | as stated in the file | compared with `repo.md`; the papers were not opened | the quotations agree with the digest |
| `ultranatural/note.md`, Proposition 8, Theorem 9, remarks | Section 7.2 | expected posterior mass off an isolated f at most 2^(K(f))·(1 − δ)^n; a machine sep(x; A) bits away sees the patch as isolated | read | correct |
| `research/prove/lower-bounds.md`; `verification/lower-bounds-check.md`; `research/prove-b/hellinger-runs.md` | Sections 2, 4, 6, 8 | Lemma 1.5; Theorems 1.6, 3.1, 3.3, 4.1; Corollaries 1.7, 2.2; Proposition 3.2; Propositions A1, A2; Theorem 3.1(c) | each statement compared with the quotation | the quotations agree, constants included |

Not checked by me: Theorem 2.1(c) and Corollary 2.3 of `hellinger-runs.md` (the constant 4 of the subadditivity of H²), on which Theorem 1.9 rests; Lemmas 2.1 and 3.2 of `rehearsal-core.md` (chain rule; coupling). The file relies on the referee reports of those parts for them, and so do I.

## 6. Numerical evidence

All numbers are copied from the three output files in `verification/code/`. Seeds: 20261116, 20261117, 20261118.

**`assumptions_attack_core.out`.**

* A. Inequality (0.4) of Lemma 0.2: 60 random instances (2 to 3 inputs, horizon up to 3, 2 to 4 rounds, classes of 2 to 4 samplers with weights of total below 1, some kernels with zeros; the human in the class, outside it, or changing after every answer), 140 pairs (instance, member) with a finite right side: the smallest value of right side minus left side is 0.0127.
* B. Theorem 2.1(b): 30 instances, the two sides differ by at most 7·10⁻¹⁵.
* C. Theorem 3.2(a): 40 instances, every subset Q, any human process: the largest ratio of the exact probability to L/n is 1.0000. The event for some singleton: 0.9146, 0.9539, 0.9759 (M2).
* D. Theorem 3.2(b): all paths of 4 rounds in 12 instances: the largest E[G_n] is 0.99997.
* E. A floor that the file does not state. For a deterministic human f and functions g in the class, Σ_t E[number of unfaithful calls of the run of round t] ≥ L·Σ_g w(g)·Pr[g is refuted within n rounds]. (Proof: while g is unrefuted its posterior weight is at least w(g); the calls of the run of round t at which g differs from f are answered as g would with probability at least w(g) each; and by identity (0.5) the expected number of such calls, on the event that g is unrefuted, summed over the rounds, is L times the probability that g is refuted within n rounds.) In 30 instances the floor is below the exact sum, which is below L·K ln 2; in the first instance the three numbers are 1.0652, 1.0654, 1.5211. So for classes of functions the sum bounded by R1 is at least L times the weight of the members that rehearsal refutes: the unfaithful calls are draws from the refutable part of the prior, and R1 is tight up to the ratio of K ln 2 to that weight.
* F. Proposition 2.2 (the human outside the class, two members equal to it on the reachable inputs): 20 instances, smallest slack 0.0177.
* G. Proposition 2.5: mismatch probability minus total variation at least 1.4·10⁻¹² in 200 pairs; the numbers of M1.
* H. Example 2.3 from the engine: Pr[ν₁ refuted] = 0.354367 after 5 rounds and 0.432608 after 12, equal to the file's recursion; limit 0.443519.
* I. Example 3.3 from the engine (k = 1): for L = 2, n = 6 the sum over the rounds of the expected number of unfaithful calls is 2.328125 with the seeded index (the file's formula gives 2.328125) and 1.090332 with a fresh index (bound 1.386294); for L = 3, n = 6: 4.499314 and 1.622257 (bound 2.079442).
* J. Proposition 4.2 with a stock of 4 tasks used without replacement, n = 3: 6 instances, smallest slack 0.0878.
* K. Proposition 4.3, any rule for the next call, 6 calls: 20 instances, smallest slack 0.2545.
* L. The inequality in the proof of Corollary 1.12: 200 000 random cases, smallest slack 3·10⁻⁷. Part 7 of the prover's script recomputed without sampling (the number of ones is Poisson-binomial): distance to the human of round 1 equal to 0.1121, 0.0932, 0.0631, 0.0436, 0.0587, 0.1043 for n = 10, 30, 100, 300, 1000, 2000, against the file's simulated 0.1119, 0.0947, 0.0631, 0.0433, 0.0593, 0.1035. The minimum near n = 300 is confirmed. The rise afterwards is the distance γ·T/2 between the human of round 1 and the average human of the rounds before T, as one would expect.

**`assumptions_attack_episodes.out`** (a parent episode of two messages, a child episode between them).

* A. Lemma 1.6: the run law of the episodic mixture and the run law of one posterior draw per episode differ by at most 6·10⁻¹⁷ in 20 instances.
* B. Theorem 1.7 for a human who is not deterministic, Protocol R^ep enumerated for 3 rounds: 10 instances, smallest slack 0.2785.
* C. Theorems 1.7(b) and 1.8(a): 200 pairs (f, C): Σ_i KL_i − E[N_ep] at least 7·10⁻⁵; the probability of a mismatch in a validation round equals E[N_ep]/L_e to 4·10⁻¹⁶.
* D. The ratio of m11: 0.5662.

**`assumptions_attack_lower.out`.**

* A. Theorem 6.1(2) for one block against the exact frontier of the plans "ask k cells, stop when the needle is found, then answer by the Bayes rule": for all N from 2 to 40, B from 1 to 6 and all k, the exact average failure is at least the bound; the smallest difference is 0.00125. Item (3): the least expected number of questions on the frontier is 1.96, 1.93, 1.24, 1.10 times the bound (1 − 10δ)·B/(8δ) for (B, δ) = (5, 0.05), (10, 0.05), (4, 0.02), (20, 0.01). The theorem is tight up to a factor 2, as the file says.
* B. The table of m2 and three more rows.
* C. Theorem 7.4(a): for every set S of surviving members that contains f, in 12 instances with runs of different lengths, the expected weight removed from S ∖ [f] in one round is at least δ·R/(2L) (equality only when R = 0); the exact posterior weight off [f] after 1 to 12 rounds is below the bound by at least 0.51. Proposition 7.5(b): smallest slack 0.0278.
* D. The counterexample of M3. E. The weights of w1. F. The numbers of M1, S5 and m9. G. The numbers of m5.

One error of my own, found and corrected during the work: in part C of the episodes script the two indicators of an unfaithful episode were added as numpy booleans, which is a logical "or"; the first run reported a false discrepancy of 0.42 in the identity of Theorem 1.8(a). With integers the identity holds to 4·10⁻¹⁶.

## 7. Verdicts

HOLDS: I followed the proof and could not break the statement. HOLDS WITH CHANGE: the statement or its reading needs the change named. BROKEN: false as worded. NOT VERIFIED: I could not break it and did not follow or find a full proof.

| statement | verdict | note |
|---|---|---|
| Lemma 0.1 | HOLDS | standard; exact check through Lemma 0.2 |
| Lemma 0.2 | HOLDS | exact check A |
| A3 in four parts (Section 0.2) | HOLDS WITH CHANGE | add the freshness of the runs (M3) |
| Example 1.1 | HOLDS | |
| Lemma 1.3 | HOLDS | |
| Lemma 1.6 | HOLDS | exact check |
| Theorem 1.7 | HOLDS | exact check, nested episodes, human not deterministic |
| Theorem 1.8 | HOLDS | exact check of (a) |
| Theorem 1.9 | HOLDS, given the subadditivity of H² of `hellinger-runs.md`, which I did not re-check | the remark on the value 1/2 needs the change of m11 |
| "V1(b) for whole episodes" (Section 1.2) | NOT VERIFIED | not stated, not proved (m12) |
| Example 1.10 | HOLDS | |
| Theorem 1.11 | HOLDS | a statement about Protocol R with a static class (Section 4, item 8) |
| Corollary 1.12 | HOLDS | exact recomputation of the example |
| Example 1.13, Proposition 1.14 | HOLDS | |
| Proposition 1.15 | HOLDS WITH CHANGE | (a) to (c) hold; the reading claims more than (b), and (c) is not a design that meets the objection (m4) |
| Proposition 1.16 | HOLDS | an upper bound; O8 reads it as a lower bound (m6) |
| Theorem 2.1 | HOLDS | (b) is standard; its reading needs W = 1 (m8) |
| Proposition 2.2 | HOLDS | exact check |
| Example 2.3 | HOLDS | reproduced from first principles |
| Proposition 2.4 | HOLDS WITH CHANGE | the statement holds; the reading turns "there are classes" into "when 2^K candidates remain" (M4, item 3) |
| Proposition 2.5 | HOLDS | its use as "the affordable protocol" is BROKEN for a human who is not deterministic (M1) |
| Remark 2.6 | HOLDS | standard estimator (w4) |
| Theorem 3.2(a) | HOLDS | for each fixed Q; "for every property at once" in the table of Section 5 is BROKEN (M2) |
| Theorem 3.2(b), (c) | HOLDS | the reading of (c) needs the comparison with 2^(−K) (m5) |
| Example 3.3 | HOLDS | reproduced from first principles |
| Example 3.4 | HOLDS | |
| Example 3.5 | HOLDS WITH CHANGE | weights (w1) |
| Example 3.6 | HOLDS | |
| Definition 4.1 | HOLDS WITH CHANGE | (C2) must be a fact about the runs used, not an ability (M3) |
| Proposition 4.2 | HOLDS | exact check |
| Proposition 4.3 | HOLDS | label-efficient prediction |
| Proposition 4.4 | HOLDS WITH CHANGE | each item holds; the completeness is not proved, the abstaining rules are missing, item 4 needs a decidable support (m3) |
| Section 5, the seven tests | HOLDS WITH CHANGE | rows 1, 2, 3, 5 as in the table of Section 3 above |
| Theorem 6.1 | HOLDS | exact frontier check |
| Corollary 6.2, Remark 6.2a | HOLDS | 6.2a rests on Proposition A2 of a referee report, which I read and found correct, and which has no report of its own |
| Proposition 6.3 | HOLDS | standard; the chain remark in its reading is NOT VERIFIED (m12); the reading is too general (m13) |
| Sections 6.2, 6.3 (numbers) | HOLDS WITH CHANGE | units (m9); the certificate column is for a deterministic human (M1); the verb of m10 |
| Section 6.5 ("the theorem that carries the weight is V1 with R3") | BROKEN for the human of the problem statement | M1 |
| "The factor K is forced, also under low stakes" | HOLDS WITH CHANGE | by Theorem 6.1 for replication; for additive work by the proposition of m1, in the form n ≥ (1 − 2θ − 2δ)·K |
| Proposition 7.1 | HOLDS | |
| Lemma 7.3, Theorem 7.4 | HOLDS | one-round inequality checked on every surviving set |
| Proposition 7.5, Example 7.6 | HOLDS | 7.5(b) checked on every subset |
| Proposition 7.7 | HOLDS | standard |
| Propositions 7.8, 7.9, 7.10 | HOLDS | |
| Section 8, classes of the objections | HOLDS WITH CHANGE | O3, O6, O8, O9, O11, O12, O17 as in Section 2; five objections to add |
| "What survives of the claim" | BROKEN as worded | corrected version in M4 |
| Section 10.1, item 4 (open) | settled in part | m1 |
| the claim under attack ("works exactly as far as any protocol can") | BROKEN as worded | the file says so; after this report less survives than the file states |

## 8. Agreement with the other report, and what I did not do

I read the summary and the list of corrections of `verification/assumptions-check.md`, not its body. That list contains, found independently, the findings M1 (with the same places), M2, the first and third items of M4, m3, m8, m9, m10, m11, w1, w2, w3, the remark of m6 that Proposition 1.16 is an upper bound, and, in one line each, the objections S1 and S3. It also contains the points of m5 and m13. I had both in my notes (the comparison of L^(−n) with 2^(−K); the independence of the questions from the answers on such scaffolds), and I decided to report them after reading that summary; the arguments and computations given here are mine. Not in that list, as far as I read it: M3 (the fifth part of A3, with the counterexample), the lower bound of m1, the cost of the random round and the late round of m2, the floor of Section 6 (part E), m4 on the reading of Proposition 1.15, the class of O8, m7, S2, S4, S5, and the attributions of Section 4. That report states additions of its own (on the factor m_e, on a simultaneous form of Theorem 3.2(a) for 2^k properties, on Example 2.3 with unequal weights) that I did not check.

Not done: I did not open the papers of Landauer, of Bartol and co-authors, of Kuhn, of Barron and Cover, of Weinberger and Ordentlich, of Cesa-Bianchi, Lugosi and Stoltz, of Herbster and Warmuth, of Batu and co-authors, or of Li and Zhang beyond the abstract page; what I say of them is marked. I did not re-derive the constant 4 in the subadditivity of H². I did not search for an additive scaffold on which the factor 1/(θδ) of R3 is necessary; that question is open.
