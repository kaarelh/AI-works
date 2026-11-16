# Second check of the part `assumptions`

Reader: the second checker of this part. Object: `proofs/assumptions.md` (the final proof file, Section 12 "Checking"), the section source `research/sections/assumptions.md` and the corresponding text of `note.md` (the paragraph "Caveats on the assumptions" at the end of Section 1, Section 9 and Section 10). I compared the three blocks of `note.md` with the section source by `diff`: they agree word for word (`research/orchestration/patches.py` changes nothing in them). Labels and letters are those of `research/outline.md`, Addendum 3 (k tolerated faults, ℓ bits of a seed, θ, δ, N8, I1, E1, E2, R7, H1, H2).

Script of this check: `verification/code/assumptions_second_checks.py`, output `verification/code/assumptions_second_checks.out`. It was written from the statements of the proof file, without reusing the code of `proofs/code/assumptions_*.py`. No literature was read in this session; no web search was made.

## 1. Statements examined, with verdicts

### 1.1 How the list was formed

From Section 12.2 of the proof file I took every statement that (a) the section text uses or mentions and (b) was seen by its author and one checker at most, or by the editor only, or was written or changed by the editor after the verification. The task names four of them for special attention (Proposition 6.4, Example 3.3a, Remark 3.2a, Proposition 1.9a). Proposition 1.9a is marked "not in the section text"; the section text uses Theorem 1.9 ("only weaker forms hold"), whose consequence for nested episodes Proposition 1.9a is, so I checked both. I added Remark 6.6, which no verifier had seen: the section text does not cite it, but objection O3, whose class the note prints in Section 9.5 ("long episodes"), rests on it in the proof file. I also checked every number of Section 9.1 and the statements behind the verdicts of Section 10 and "What survives".

| id | statement | who had seen it | verdict |
|---|---|---|---|
| Rem1.1a | Remark 1.1a (one person, or a pool) | attack report, editor | CORRECT (an observation, not a theorem) |
| Thm1.9 | Theorem 1.9 (whole runs, episodic human not deterministic) | check report; attack report conditionally | CORRECT |
| Prop1.9a | Proposition 1.9a (cut and paste for episodes) | check report, editor | CORRECT |
| Ex2.3 | Example 2.3 and its unequal-weights paragraph (editor-added) | both; second half check report and editor | CORRECT |
| Cor3.2' | Corollary 3.2′ | check report | CORRECT |
| Rem3.2a | Remark 3.2a (i)–(iii) | (i) attack, (ii) check, (iii) attack; editor | CORRECT as a remark; the note's reading of it needs a qualifier (finding N14) |
| Ex3.2b | Example 3.2b (last mixture on a chain) | check report, editor | CORRECT |
| Ex3.3 | Example 3.3 (numbers) | both, editor | CORRECT |
| Ex3.3a | Example 3.3a (generator with a short seed) | attack report, editor | CORRECT; MINOR in the proof file (the masks must be named) |
| Prop6.4 | Proposition 6.4 (additive work) | attack report, editor | CORRECT |
| Prop6.5 | Proposition 6.5 (one batch when inputs do not depend on answers) | check report, attack report argued, editor | CORRECT |
| Rem6.6 | Remark 6.6 (a chain needs as many batches as links) | editor only | CORRECT |
| Thm6.1 | Theorem 6.1 = N8, as restated in the note | both, editor | CORRECT; MINOR in the note's wording (finding N3) |
| Prop2.5d | Proposition 2.5(d) and the paragraph after it (editor-added) | both reports asked for it; editor | CORRECT |
| Sec6.2 | Numbers of Sections 6.2, 6.3 used in Section 9.1 | both, editor | CORRECT; one sentence of the note overstates (finding N1) |
| Sec5 | The verdicts on the seven tests (editor's merge) | no verifier | MINOR: six verdict paragraphs need a qualifier (findings N12 to N17) |
| Sec8 | The classes of the objections and "What survives" (editor's merge) | no verifier | MINOR, and one bullet WRONG as worded (findings N8 to N11; N9 is the wrong one) |

### 1.2 Reasons, statement by statement

**Rem1.1a. CORRECT (observation).** The remark says that A1 is also an assumption about the n questions of rehearsal, that one person who answers them violates it by the design of the protocol on the first closed system of Section 4.2, that Theorem 1.11 is what remains for one person, and that a pool is the design that makes A1 true, at the price of imitating a pool. Each step follows from the definitions: A1 asks that the answer to question t be a draw from P given everything before it, which a person who remembers questions 1 to t − 1 does not satisfy; Lemma 0.2 and Theorem 1.11 allow P_t to depend on everything before round t; with a fresh member of a pool per question the conditional law of an answer given the past is the pool's kernel. It is not a theorem, and the note cites it as a remark. Nothing to fix.

**Thm1.9. CORRECT.** (a) For sequential episodes the answers of episode i, given the earlier episodes, have kernels c_i and p_i, because no call of another episode intervenes; Theorem 2.1(c) of `proofs/hellinger-runs.md` (which I looked up: H²(P, Q) ≤ 4·E_P Σ_i h_i for sequential experiments) and H² ≤ KL/2 give H² ≤ 2·Σ_i KL(Q_{C[i←P]} ‖ Q_C), and with Theorem 1.7 and averaging over t, E H² ≤ 2L_e·K ln 2/n; TV ≤ √(2H²) gives 2·√(L_e·K ln 2/n). (b) I followed the one-step inequality 1 − H²(𝐏_k, 𝐂_k) = ∫√(d𝐏_{k−1} d𝐂_{k−1})·(1 − h_k) ≤ 1 − ½E_𝐏 h_k − ½E_𝐂 h_k: it holds because, given X_0 and X_{<k}, the input v_k is fixed and the two conditional laws of X_k are P(·|v_k) and C(·|v_k), and X_0 (which contains the coins of the other episodes) has the same law under both. Then E_𝐂 h_k ≤ 2H²(𝐏_k, 𝐂_k) ≤ 2H²(𝐏, 𝐂) ≤ KL(𝐏 ‖ 𝐂), summed over at most m_e calls; L4 at the level of calls gives the factor 4m_e; TV ≤ √(8m_e·L_e·K ln 2/n). The constants agree with the statement. I did not re-check Theorem 2.1(c) of `proofs/hellinger-runs.md` itself (it has its own second check).

**Prop1.9a. CORRECT.** (1) The density of a run under Q_S factorises as Π_{i∈S} p_i·Π_{i∉S} c_i although the episode numbers depend on the history, because the answerer of call j is determined by e_j(h_j). Then √(q_S q_T) depends on (S, T) only through S ∩ T and S Δ T, which (S ∩ T, S ∪ T) share. (2) √H² is a metric (1/√2 times the L₂ distance of root densities), and for disjoint A, B part (1) with S = A, T = B gives d(Q_∅, Q_{A∪B}) = d(Q_A, Q_B); induction gives subadditivity. (3) Cauchy–Schwarz and H² ≤ KL/2 give H² ≤ (L_e/2)·Σ_i KL_i, and for L_e = 2, H² ≤ Σ_i KL_i. The consequences (factor min(4m_e, L_e/2); E H² ≤ 2K ln 2/n for two episodes; E TV ≤ L_e·√(K ln 2/n) by Jensen) follow. Numerical test (script, last block): on 400 random scaffolds of depth 3 to 6 with 2 to 4 episode numbers assigned by the history in order of first appearance, and with arbitrary kernels on histories (more general than the statement), the identity of part (1) holds for every pair of sets to 1.1·10⁻¹⁶, subadditivity holds with largest excess 0, H² − (L_e/2)ΣKL is at most −4.4·10⁻³, and for L_e = 2 H² − ΣKL is at most −5.7·10⁻². The note does not use this proposition; `research/sections/open.md`, item 10, should quote it as the proof file says (that is another part's text).

**Ex2.3. CORRECT.** Product Π_{k≥0} 2/(2 + ω_k) with ω_k = 1/(1 + 2^k): 0.556481, so ν₁ is refuted with probability 0.443519; a direct simulation of Protocol R on the example (not of the product), 2·10⁵ runs of 60 rounds, gives 0.4424 ± 0.0022 (truncation at 60 rounds loses a little). Limit failure probability 0.2218. Unequal weights: exact values 0.4435, 0.6556, 0.9037, 0.9874, 0.9998 for K₁ = 1, 2, 5, 10, 20, all above 1 − (4/5)^(K₁); the argument (ω_k ≥ 1/2 for k ≤ K₁ − 1, so each of the first K₁ factors is at most 4/5) is right. The note's "refuted with probability 0.44, at an input that only wrong answers reach, and the imitator then fails half the time for ever" is what the example shows.

**Cor3.2′. CORRECT.** Union bound over Theorem 3.2(a); by Kraft's inequality a prefix-free language has at most 2^k descriptions of length at most k. The note uses only "N properties cost the factor N".

**Rem3.2a. CORRECT as stated in the proof file.** (i) I recomputed the illustration with the normalisation c = (1 − 2^(−K))/(1 + 1/(2N))^N (the one the editor's script uses; the proof file says only "proportional to"; see the minor point below): 0.9993 and 0.6654 at s = 8, 9 for K = 100; 0.9995 and 0.9985 at s = 81, 90 for K = 1000; 0.0010 at s = 10 and below 10⁻⁴ from s = 11 (K = 100) and from s = 100 (K = 1000). (ii) log₂ C(2²⁰, 1000) = 11469.9; probability that 1000 uniform inputs are distinct 0.621; K ln 2/n at K = 11 500 is 7.97. (iii) E[w(ν_D)ν_D(D)/P(D)] = Σ_D c(D)·w(ν_D)·ν_D(D) ≤ max_D c(D), since Pr[D] = c(D)·P(D), ν_D(D) ≤ 1 and Σ_D w(ν_D) ≤ 1 for an injective family with fixed weights: correct. *Minor (proof file only):* in (i) state the constant: "with weight c·(2N)^(−|A|), c := (1 − 2^(−K))/(1 + 1/(2N))^N, so that the weights sum to 1 (the member with A = X coincides with f; its weight (2N)^(−N) is negligible)". *What the remark does and does not show:* that tables outweigh the human until n·b exceeds K *for a prior that charges a table about b bits per recorded question*; for other priors it shows nothing. See finding N14 on the note's test 3.

**Ex3.2b. CORRECT.** In the limiting class every round learns the next link with probability 1/L independently of the state, so the event "the run of M^(n+1) reaches x_L and no question lay in {x_L}" is "exactly L − 1 successes in n Bernoulli(1/L) trials". Maximising C(n, L−1)L^(−(L−1))(1 − 1/L)^(n−L+1)·(n + 1)/L over n gives 1.319 (n = 98), 2.550 (n = 1599), 5.059 (n = 25 598) for L = 10, 40, 160; 0.4·√L is 1.26, 2.53, 5.06. A simulation of the limiting chain (L = 10, n = 100, 10⁵ runs) gives 0.1298 against the binomial 0.1304. The note uses it in one clause ("A last mixture kept for good is not covered in general"), which is right.

**Ex3.3. CORRECT.** With the seed, |A_t| = 1 + Bin(2^k − 1, L^(−(t−1))); without, Bin(2^k, L^(−(t−1))); per-round expectation (L − 1)·E[|A|/(2^k + |A|)]. For k = 3, L = 4: seeded 0.3506 (n = 100) and 0.3351 (n = 1000), limit 1/3 = (L − 1)/(2^k + 1); fresh 0.0228 and 0.0023 against the R1 bounds 0.0277 and 0.0028. The note's sentence ("at least (L−1)/(2^ℓ+1) unfaithful calls in expectation for every n, in a class with K = 1") is the statement, with ℓ for the proof file's k.

**Ex3.3a. CORRECT; MINOR in the proof file.** I rebuilt the instance (X = {0, …, 63}; A_σ = inputs whose bits under mask m_σ have even parity; pairwise intersections all 16; under the generator of seed s every other g_σ survives a question with probability 1/2; g_s never dies). The floor: with a ≥ 1 live functions the deployed error is (a/32)/(1/2 + a/16) ≥ 1/18 = 0.0556 = (1/2)/(2^k + 1). Exact values by a Markov chain on live sets, with the masks 1, 2, 4, 8, 16, 32, 3, 5: 0.1005, 0.0601, 0.0560 (generator) and 0.0611, 0.0061, 0.0006 (fresh) for n = 10, 100, 1000, against the R1 bounds 0.0693, 0.0069, 0.0007; all as stated. Under an approximation that treats survivals as independent the first value is 0.1013: the survival events are correlated (mask 3 is the sum of masks 1 and 2), so the exact values depend on the masks. *Fix in the proof file:* after "for eight distinct nonzero masks" add "(1, 2, 4, 8, 16, 32, 3, 5; the exact values below depend on this choice, the floor does not)". Checked also: A3(i) is void for L = 1; A3(ii) to (iv) and (C1), (C3) hold; only A3(v) fails. The note's sentence "Rehearsal runs taken from a generator leave a like floor (Example 3.3a)" is right.

**Prop6.4. CORRECT.** Tolerance: a rule that replaces at most k answers leaves at most k wrong answers. Lower bound: with f uniform on all functions on [K] and independent of the coins, the values at unasked inputs are independent fair bits given the transcript; the deployed answerer never sees a value of f (the run contains only its own answers, and the inputs are uniform and independent of the answers), so every call at an unasked input is wrong with conditional probability at least 1/2, also when that input recurs in the run; the expected number of distinct asked inputs is at most n; so E[wrong answers] ≥ L(K − n)/(2K), while a run good with probability 1 − δ for every member has E[wrong answers] ≤ k + δL. Hence n ≥ K(1 − 2k/L − 2δ). At θ = δ = 0.1 the factor is 0.6, and 50 answers serve at most 2^83 candidates (83.3). The note's sentence omits the averaging and the failure criterion; see finding N4.

**Prop6.5. CORRECT.** With all n questions fixed in advance and put into 𝓖_1, Lemma 0.1 applies in the order t (A1 for parallel answers means that each answer is a draw from P(·|x_t) given the questions and the other answers, which the proof states). Because the inputs of a run do not depend on who answers, E[a_t·g(x_t)] = (1/L)·E_{Q_B} Σ_j g(x_j) for every answerer B; with B = M_t this gives Λ(M_t)/L. Hypotheses as stated.

**Rem6.6. CORRECT** (first independent reading). The revealed strings form an initial segment (a correct list also confirms its entries). Without a lucky guess a batch reveals at most one new string. Before a batch, fewer than s·b wrong lists have been seen, each excluding an event of conditional probability at most 2^(−ℓ) for the unrevealed strings, so c_{i+1} takes any value with conditional probability at most 1/(2^ℓ − s·b); a lucky guess must contain c_{i+1} at position i + 1, and the b questions of a batch are fixed before its answers; the union bound over s·b questions gives s·b/(2^ℓ − s·b). The note does not cite it; Section 12.3 of the proof file is right that nothing in the section text rests on it directly, and objection O3 may now rest on it as checked by one reader besides the editor.

**Thm6.1 (N8). CORRECT.** I followed the proof. (2): E[N_j] ≥ k − k(k − 1)/(2N) ≥ k/2 needs N ≥ k − 1, which holds; the failure count uses that S (the cells asked in the j-silent interaction) does not depend on z; the indicator 1[N − k ≥ 2B] is absorbed by 1 − κ_j − 2B/N ≤ 0 otherwise. (3): p ≥ (B/N)(1 − B/(2N)) = 2δ(1 − δ), δ/p ≤ 1/(2(1 − δ)) ≤ 1/2 + δ for δ ≤ 1/2, hence n ≥ (1 − 10δ)·m_b·B/(8δ); checked on a grid of B ∈ {1, …, 400}, δ ∈ (0, 0.1) (largest ratio of the claimed bound to the derived one 0.999). (4): L/(k + 1) < 2B. Numbers: with g = 5, δ = 0.05 the constant is 1.1074, so 50 answers serve at most 2^45 and 10⁴ at most 2^9030; the gap factor 16 ln 2·log₂(g/(2δ))/(1 − 10δ) is 125.2 at (5, 0.05). The note's restatement says "draws a block and g of its cells", where the proof draws g cells independently with repetition; the theorem holds either way (for g distinct cells p = g/N = 2δ, which only helps), so this is wording (finding N3).

**Prop2.5d. CORRECT.** For the exact imitator the mismatch probability at a call is 1 − Σ_y P(y|x)²; for the two-answer human it is 2e(1 − e); (1 − 2e(1 − e))^300 = 1, 0.549, 0.00248, 1.39·10⁻²⁶ for e = 0, 0.001, 0.01, 0.1, as stated. The note uses this in tests 2 and 5 (test 2: "can be issued for a deterministic human only"); see finding N13.

**Sec6.2 (numbers of Section 9.1). CORRECT, with one overstatement in the note.** n·θδ/ln 2 at θ = δ = 0.1: 1443 bits (10⁵ answers), 0.72 bits (50), 2.885·10⁷ bits (2·10⁹); K = 10⁹ gives 6.93·10¹⁰ answers, 3.47·10⁷ working years of 2000 hours (7.9·10⁶ calendar years); the certificate needs ⌈ln 20/(θδ)⌉ = 300 answers. The formulas n = K ln 2/(θδ) and K ln 2/(2θ²δ²) follow from R3 with k + 1 ≥ θL and the bounds L·K ln 2/n and L·√(K ln 2/(2n)) for β. The sentence "With a year per answer … every bound here is empty: a certificate alone takes 300 years" is too strong: see finding N1.

**Sec5 and Sec8.** These are not theorems; the proof file says no verifier re-read the editor's merge. I read every verdict and every printed class against the statements; the findings are N8 to N17 below. Apart from those, each verdict and class printed in the note is supported by the statement it cites.

## 2. Findings on the note's text

Each finding quotes the sentence of `note.md` (identical in `research/sections/assumptions.md`) and gives the replacement. The caveats of Section 1 need no change: each of their sentences is a statement of the proof file with its hypotheses (Example 1.1, E1, Remark 1.1a, Proposition 1.15(a), Theorem 2.1(a) with ln(1/w(ν)) ≥ ln(W/w(ν)), Example 2.3, Example 3.3, Example 3.3a, Example 3.6). The status words of the labelled statements (N8, I1, E1, E2 "proved here"; Propositions 7.7 and 7.9 "standard" with source) agree with Section 12 of the proof file. Every pointer in the three blocks (Theorem 1.11, Corollary 1.12, Proposition 1.14, Theorems 1.7, 1.8, 1.9, Example 1.10, Theorem 2.1, Example 2.3, Examples 3.3, 3.3a, 3.6, Proposition 1.15, Remark 1.1a, Theorem 6.1, Propositions 6.3, 6.4, 6.5, 7.1, 7.5, 7.7, 7.8, 7.9, 7.10, Theorem 7.4, Theorem 3.2, Remark 3.2a) exists in the proof file and says what the note says it says, except where a finding below says otherwise.

### Section 9.1

**N1 (MINOR; overstatement).** "With a year per answer, which the researcher thinks research may need, every bound here is empty: a certificate alone takes 300 years."
The certificate's 300 validation questions are independent runs of a frozen imitator, so they can be answered in parallel: it takes 300 human-years, not 300 years. And the proof file's own table (Section 6.2) has 144 bits for 10⁴ people answering for one year, which is not empty on scaffolds whose questions do not depend on the answers (Proposition 6.5).
Replace by: "With a year per answer, which the researcher thinks research may need, one person's working life pays for less than one bit, and a certificate alone takes 300 human-years. A pool of 10⁴ people for one year pays for about 144 bits, and only on scaffolds whose questions do not depend on the answers."
(The next sentence, "More people help little: …", can stay.)

**N2 (MINOR; missing parameters).** "At K = 10⁹ and an hour per answer the count is 3.5·10⁷ working years."
Replace by: "At K = 10⁹, an hour per answer and θ = δ = 0.1 the count is 3.5·10⁷ working years of 2000 hours."

**N3 (MINOR; wording of N8).** "The scaffold draws a block and g of its cells, asks every copy …"
The proof (Definition 6.0) draws the g cells independently and uniformly, with repetition; the theorem also holds for g distinct cells (then p = g/N = 2δ), so this is only wording.
Replace by: "The scaffold draws a block and g of its cells independently and uniformly, asks every copy …"

**N4 (MINOR; Proposition 6.4 without its quantifiers).** "For additive work (L calls at uniform inputs, any k errors harmless) every protocol needs (1−2k/L−2δ)·K answers on the class of all functions on K inputs (Proposition 6.4)."
Replace by: "For additive work (L calls at independent uniform inputs; a run is good if at most k of its answers are wrong) every protocol whose run is good with probability at least 1 − δ for every member needs, in expectation over a uniform member, at least (1−2k/L−2δ)·K answers on the class of all functions on K inputs, and K answers suffice (Proposition 6.4)."

### Section 9.2

**N5 (MINOR; the price of I1).** "*The price* (Proposition 7.5): a human who is an isolated member patched where runs go with probability ε is imitated wrongly with probability at least ε per run for every n; the posterior shows no doubt until a question lands on the patch."
Proposition 7.5(a) gives the floor ε† = inf over members h of D(f†, h), the run distance from the human to the *nearest* member, which can be smaller than the distance ε to the patched member if another member is closer. The second clause is Example 7.6; Proposition 7.5(b) says only that the marginal likelihood falls.
Replace by: "*The price* (Proposition 7.5): a human whose runs differ, with probability at least ε, from those of every member of the class (for instance an isolated member patched where runs go with probability ε, if no member is closer) is imitated wrongly with probability at least ε per run for every n; in Example 7.6 the posterior shows no doubt until a question lands on the patch."

### Section 9.3

**N6 (MINOR; K misnamed).** In E1: "With L_e the largest number of episodes of a run and K the weight of that function, …"
Replace by: "With L_e the largest number of episodes of a run and K := log₂(1/w(f)) for that function f, which is in H, …"

**N7 (MINOR; hypotheses of E2 and the reading of Corollary 1.12).** Section 9 opens with "A closed deployment and A1 to A3 are assumed unless stated otherwise", and E2 drops A1 and A2. Also, Corollary 1.12 shows that the *bound* grows with n; that the error grows is the numerical example of the proof file (Section 9, part 7, recomputed by the attack report), which I did not recompute.
Replace "Let the human P_t of round t depend on the past in any way." by "Without A1 and A2, let the human P_t of round t depend on the past in any way."
Replace "and under steady drift the last term grows with n, so that longer rehearsal can be worse (Corollary 1.12)." by "and under steady drift the last term grows with n (Corollary 1.12); in an example of the proof file the error grows too, so longer rehearsal can be worse."

### Section 9.5

**N8 (MINOR; class of O3 without its condition).** "*long episodes:* on the researcher's numbers, unless scaffolds of short calls do research;"
The proof file classes O3 as fatal "for scaffolds whose questions depend on earlier answers".
Replace by: "*long episodes:* on the researcher's numbers, for scaffolds whose questions depend on earlier answers, unless scaffolds of short calls do research;"

**N9 (WRONG as worded).** "*the human is a sampler:* no certificate free of K then bounds the unfaithful calls (V1)."
This contradicts Section 8.7 of the note itself ("with at most q possible answers it bounds the expected number of unfaithful calls of a run, at the slow rate m^(−1/4)", `proofs/property-batch.md`, Proposition 6.4) and `proofs/rehearsal-core.md`, Proposition 13.5 (a K-free bound on β(A)/L from questions put r times, for a set of s answers). The proof file's O18 has the exception and states the fatal part as "works as a certificate" for a human whose two answers to one question differ with probability above about θδ/ln(1/δ_c).
Replace by: "*the human is a sampler:* to "works as a certificate": no certificate free of K then bounds the unfaithful calls (V1), except, for a small set of answers, one from questions put many times, at a cost that grows as 1/ε⁴ (Section 8.7);"

**N10 (MINOR; the other classes).** "The others are answerable at a price (a pool of people; a late random round; physical coins) or lie outside the theorems: whether the human system does anything, and whether it tolerates faults, which R3 assumes and the protocol never tests."
Five of the fifteen are classed "answered" in the proof file (O11, O14, O16, O21, O22).
Replace by: "Of the others, five are answered by the theory, eight are answerable at a price (a pool of people; a late random round; physical coins), and two lie outside the theorems: whether the human system does anything, and whether it tolerates faults, which R3 assumes and the protocol never tests."

**N11 (MINOR; "What survives").** Three sentences.
(a) "For some scaffolds and classes of 2^K candidates every protocol needs a constant times K·L/(δ·log₂(L/δ)) answers." δ is not defined in the paragraph, and the hypothesis δ ≤ 1/20 of N2b is missing. Replace by: "For some scaffolds and classes of 2^K candidates every protocol whose run fails with probability at most δ ≤ 1/20 for every candidate needs at least K·L/(16δ·log₂(L/δ)) answers (N2b), and a constant times K·g/(δ·log₂(g/δ)) when faults are tolerated by replication (N8)." (From (1 − 10δ)/8 ≥ 1/16 for δ ≤ 1/20 and log₂(L/(2δ)) ≤ log₂(L/δ).)
(b) "An imitator of a deterministic human can be certified at a cost without K." Replace by: "A given imitator of a deterministic human can be certified at a cost without K, if it is already good enough to pass."
(c) "Nothing is offered outside that computation, at rates below about 1/n, or for a human other than the one who answered." Sections 6 and 7 of the note offer things outside a closed deployment (the human on call; Ab2 on any input, at its price). Replace by: "Outside that computation rehearsal offers nothing unless the human stays on call or a price of Sections 6 and 7 is paid; and nothing is offered at rates below about 1/n, or for a human other than the one who answered."

### Section 10

**N12 (MINOR; test 1).** "Decomposition creates none, since rehearsal runs go to full depth."
Read literally this says that decomposition creates no property that no training input has, which is not what R7 gives. Replace by: "Decomposition creates no property that escapes this bound, since rehearsal runs go to full depth."

**N13 (MINOR; test 2, correction 1 of the outline).** "nor does the certificate V1(a), which can be issued for a deterministic human only."
Replace by: "nor does the certificate V1(a), which can be issued only for a human who is nearly deterministic on the inputs visited."

**N14 (MINOR; test 3 claims more than Remark 3.2a).** "That weight must be set against the human's 2^(−K): tables of the data outweigh the human until the questions carry more than K bits, and until then the imitator answers unasked inputs as the tables do (Remark 3.2a). So the test is passed exactly as far as R1 is not empty."
Remark 3.2a shows the domination for a prior that charges a table about the bits of its questions (an exact instance, and an instance with a prior fixed in advance); it is not a theorem for every prior. And "exactly" asserts failure wherever R1 is empty, which is shown only in examples.
Replace by: "That weight must be set against the human's 2^(−K): under a prior that charges a table of the data about the bits of its questions, tables outweigh the human until the questions carry more than K bits, and until then the imitator can answer unasked inputs as the tables do (Remark 3.2a). So the test is passed as far as R1 is not empty, and where R1 is empty it can fail."

**N15 (MINOR; test 5).** Three clauses.
"Of the order of K/(θδ) single calls on the imitator's own runs, …" Replace by: "Of the order of K/(θδ) single calls on the imitator's own runs for a deterministic human, and K/(θδ)² otherwise, …"
"and for a person is out of reach at any length of answer (Section 9.1)" Replace by: "and for a person, under a prior that knows nothing of the individual, is out of reach at any length of answer (Section 9.1)" (Section 9.1 itself says that K for a person is unknown).
"For a human who varies no such certificate exists, and a certificate does not produce an imitator." Replace by: "For a human who varies no such certificate exists (with a small set of answers and questions put many times there is a slower one, Section 8.7), and a certificate does not produce an imitator."

**N16 (MINOR; test 6).** "the minimum rule (Ab2) fails only visibly on any input, and where it is sound without an assumption it refuses every input of a new simple kind;"
Dominance (Ab2(a)) needs the human in the plausible set; and the inputs refused are those that a test of about log₂(1/α) ≥ K bits separates from the asked ones, which for a person is not "simple".
Replace by: "the minimum rule (Ab2) fails only visibly on any input if the human is in its plausible set, and where that holds without an assumption it refuses every input that a test of about K bits separates from the asked ones;"

**N17 (MINOR; test 7).** "Where that tolerance comes from replication it buys no amplification (N8)."
N8 (with Corollary 6.2) says that replication does not lower the number of answers per critical unit; compared with the replicated human system it can be favourable (Corollary 6.2(c)). Replace by: "Where that tolerance comes from replication it does not lower the number of answers needed per critical unit (N8)."

## 3. What I did not check

* The statements of other parts that this part quotes (R1, R3, R7, V1 and Propositions 13.4, 13.5 of `proofs/rehearsal-core.md`; Theorem 2.1(c) and Corollary 2.3 of `proofs/hellinger-runs.md`; N1, N2, N2b and Example 5.5 of `proofs/lower-bounds.md`; Ab2 and Theorems 5.3, 5.6 of `proofs/shift-abstain.md`; Proposition 6.4 of `proofs/property-batch.md`). I looked up only that they exist and say what is quoted.
* Statements of this part that the note uses and that both verifiers and the editor had checked, which I read only as far as the note's wording required: Example 1.1, Lemmas 1.3 and 1.6, Theorems 1.7, 1.8 (E1), 1.11 (E2), Corollary 1.12 and its numerical example (Section 9, part 7), Propositions 1.14, 1.15, Theorem 2.1, Theorem 3.2, Example 3.6, Propositions 7.1, 7.5, 7.7 to 7.10, Theorem 7.4 (I1), Lemma 7.3. I found nothing wrong in them, but I did not referee them line by line.
* The literature: Landauer (1986), Barron and Cover (1991), Thompson (1933), Ville (1939), `ultranatural/note.md` Theorem 9, and Paper 1, Proposition 8.2. None was read in this session.
* Objections O1 to O22 in the proof file beyond the classes printed in the note's Section 9.5; Examples 3.4, 3.5, 7.6 and Remark 2.1a (not used in the note).
* The number of words of the three blocks against the limits of the outline.
