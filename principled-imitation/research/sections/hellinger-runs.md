<!-- Part hellinger-runs. Two blocks for the note, marked BLOCK (i) and BLOCK (ii). The editor's notes after the second block are not text of the note. -->

<!-- ================= BLOCK (i): subsection "Whole runs" of Section 3 (after "Each call", before "Low stakes") ================= -->

### 3.2 Whole runs

For a deterministic human Theorem R1 settles whole runs: the run of M^(T) is the human system's run on the same (z, ρ), except with probability L·K ln 2/n. For a human who varies, the laws of the runs are compared.

**Lemma L4 (from calls to runs).** Let A and B be answerers on a scaffold, let h_j be the squared Hellinger distance between the distributions from which they draw the answer of call j, given the run so far, and σ := E_{Q_A}[Σ_j h_j]. Then

(a) H²(Q_A, Q_B) ≤ 4σ;
(b) TV(Q_A, Q_B) ≤ σ + √(σ² + 2σ) ≤ 2√σ;
(c) Q_A(G) ≤ 2·Q_B(G) + 4σ for every set G of runs, and Q_A(G) ≤ 2σ if Q_B(G) = 0.

Proved here; (a) is standard with the constant 7 (Foster, Han, Qian and Rakhlin 2024, Lemma D.2; Foster, Kakade, Qian and Rakhlin 2021, Lemma A.13, have 10²·log n). *Idea.* Along a run of A, a quadratic function of the root likelihood ratio of B to A rises by at most a constant times h_j at call j, in expectation. Proof: `proofs/hellinger-runs.md`, Theorem 2.1 and Lemma 2.10, with Corollaries 2.3 and 2.11 for scaffolds. In (a) the constant can be 2.9642 and cannot be below 2.9639 (Theorem 2.7 and Example 2.8 there). Parts (b) and (c) have the constants of a single call. Close runs do not make single calls close, except with a factor L.

**Theorem R2 (whole runs; proved here).** Assume A1 to A3 and put s := L·K ln 2/(2n). In expectation over the rehearsal and T:

(a) H²(Q_{M^(T)}, Q_P) ≤ 2·L·K ln 2/n;
(b) TV(Q_{M^(T)}, Q_P) ≤ s + √(s² + 2s) ≤ √(2·L·K ln 2/n), which is at most ε after (1 + ε)·L·K ln 2/ε² rounds;
(c) Q_{M^(T)}(G) ≤ 2·Q_P(G) + 2·L·K ln 2/n for each set G of runs fixed in advance, and Q_{M^(T)}(G) ≤ L·K ln 2/n if the human system never produces a run in G.

If neither the questions of the scaffold nor their number depend on the answers, then, in the same expectation, KL(Q_P ‖ Q_{M^(T)}) ≤ L·K ln 2/n and TV(Q_{M^(T)}, Q_P) ≤ √(L·K ln 2/(2n)).

*Proof.* By Theorem R1 and H² ≤ KL/2, the σ of Lemma L4 with A = M^(T) and B = P has expectation at most s. In the last case the questions have the same law under every answerer; use the chain rule for KL and Pinsker's inequality. Details: `proofs/hellinger-runs.md`, Theorem 3.1.

R2 bounds expectations: for one imitator kept for good, confidence 1 − δ costs the factor 1/δ. It concerns one run; r independent runs of one imitator M^(T) are, in expected total variation, within √(2r·L·K ln 2/n) of r runs of the human system. For a person, with K near 10⁹ bits, it is empty.

**The factor L under the root is necessary** (proved here; Theorem N6 of Section 4 is a bound of the same kind on another scaffold, with a better constant). Let K ≥ 8, L a multiple of K with L ≥ 4K, and ε ≤ 1/65. For some class of 2^K samplers with equal weights and some scaffold of L calls, every protocol needs more than L·K/(8·10⁴·ε²) answers before the expected total variation between the run law of its imitator and Q_P is below ε for every member; for a class of two samplers it needs more than L/(740·ε²) (L ≥ 3 odd, ε ≤ 1/12). A run of L calls is a sample of size L from the human and shows a difference of order 1/√L per call. Proof: `proofs/hellinger-runs.md`, Propositions 3.4 and 3.5.

<!-- ================= BLOCK (ii): Section 5.2 ================= -->

### 5.2 Recorded runs of the human system

If the human can carry out whole runs, N independent runs of the human system can be recorded; the posterior given the runs is the posterior given their question–answer pairs.

**Theorem H1 (a posterior draw for each run; standard).** Let the recorded runs be independent with a common law Q*; under A1, Q* = Q_P. To imitate a run, draw t uniformly from {1, …, N}, draw ν from the posterior given the first t − 1 runs, and let ν answer every call. Let Q̂ be the law of this run given the records. Then, for every ν in H,

  E[KL(Q* ‖ Q̂)] ≤ ln(1/w(ν))/N + KL(Q* ‖ Q_ν).

Under A1 and A2, E[KL(Q_P ‖ Q̂)] ≤ K ln 2/N and E[TV(Q̂, Q_P)] ≤ √(K ln 2/(2N)), and a set of runs that the human system never produces has expected probability at most K ln 2/N under Q̂.

This is the progressive mixture rule (Catoni 1997; Yang 2000) applied to runs: for M densities and n observations its expected divergence exceeds the best density's by at most (log M)/n (Juditsky, Rigollet and Tsybakov 2008, Corollary 5.4). The proof is the regret bound behind Theorem R1 with runs in place of pairs, then convexity and Pinsker's inequality: `proofs/hellinger-runs.md`, Theorem 4.2.

The imitator is not a sampler: one hypothesis answers every call of a run, so the calls must share a seed. The bound is for the random t. For the last posterior alone, Grünwald and Kotłowski (2011) pose such a bound as an open problem; a brief search found no solution.

**The per-call mixture fails here** (proved here). If every call is answered by a fresh posterior draw, the statement of H1 is false. Let z be uniform on 2N values and let the L calls of a run be (z, 1), …, (z, L). The human is f ≡ 0, with weight ½; for each value of z, the function that answers 1 at its L calls only has weight 1/(4N): K = 1, and whatever the records, the divergence of Q_P from the imitator's run law is at least L/(8N), against ln 2/N. A hypothesis that is wrong on a whole run spoils few runs when it is drawn once for the run, and up to L times as many when it is drawn afresh at each call. The loss is at most the factor L for a deterministic human and when the questions do not depend on the answers; otherwise it is open (`proofs/hellinger-runs.md`, Section 4.3).

**Theorem H2 (one program for good; proved here).** Assume A1 and A2, let λ > 1, and compute the posterior from the N recorded runs with the weights w(ν)^λ. For 0 < ε ≤ 1 and every s in [1/λ, 1), the expected posterior weight of the hypotheses ν with H²(Q_ν, Q_P) ≥ ε² is at most

  2^(λsK)·(1 − ε²)^(2·min(s, 1−s)·N),

and so is the probability that such a ν has at least the posterior weight of P. With λ = 2 and s = ½: after (K ln 2 + ln(1/δ))/ε² runs, a program drawn once from the posterior, or the one of largest posterior weight, has TV(Q_ν, Q_P) < √2·ε with probability at least 1 − δ.

The proof bounds the posterior weight of ν by the s-th power of its odds against P and uses Hölder's inequality (`proofs/hellinger-runs.md`, Theorem 5.1). A rate in probability for λ > 1 is due to Barron and Cover (1991, Theorem 4, as Zhang 2006 reports it); for a finite class with equal weights this proof, at λ = 1, gives Proposition 2.1 of Foster, Block and Misra (2024) for maximum likelihood.

H2 makes the law of each single run on this scaffold close, and no more: single calls are close only up to the factor L, inputs that the human system never visits are free, and many runs together drift apart.

**At λ = 1 the statement fails.** Let the human be a fair coin with weight ½, let the class contain every table from {0,1}^d to {0,1} with weight 2^(−2^d−1), and let the scaffold ask one uniform input. Until an input repeats, the tables that fit the records together have the posterior weight of the coin; so a posterior draw is a table, at H² = 0.29 from the coin, with probability at least ¼ for all N ≤ 2^(d/2) (`proofs/hellinger-runs.md`, Example 5.4). A table is the human with the coins filled in. The phenomenon is known (Zhang 2006, Section 4.4, after Barron, Schervish and Wasserman 1999); H1 is not affected. Two forms hold in expectation, also outside the class: with the weights w and the likelihood raised to the power ½ (Zhang 2006, Theorem 5.1), or with the weights w² and the program of largest posterior weight (his Theorem 4.1), E[H²] ≤ ln(1/w(ν))/N + ½·KL(Q* ‖ Q_ν) for every ν (`proofs/hellinger-runs.md`, Theorems 5.5 and 5.7).

**Cost.** This route needs N whole runs carried out by the human: it suits small scaffolds only, and none when one answer is a year of work. It saves no answers beyond a constant factor: Theorem R2 with n = N·L rounds has the same bound when the questions do not depend on the answers, and twice it otherwise; the lower bound of Section 3.2 covers recorded runs. For a person both theorems are empty.

<!-- ================= END OF THE TEXT OF THE NOTE. Editor's notes follow. ================= -->

## Editor's notes for the assembly (not text of the note)

**Placement and labels.** Block (i) is the subsection on whole runs of Section 3; it follows "Each call" (R1) and comes before "Low stakes", so its number is 3.2 if the lead's draft order is kept. Block (ii) is Section 5.2. Labels used: L4 (the lemma, a label of the candidate theory that the outline's list does not contain), R2, H1 (was Theorem A), H2 (was Theorem B), and N6 by reference only: the lower bounds stated in block (i) are Propositions 3.4 and 3.5 of the proof file and carry no label, and Theorem N6 of the part `lower-bounds` is named as a bound of the same kind on another scaffold. No new label is introduced. The two sharper facts that the text mentions without a label are in the proof file: the substitutes at λ = 1 and outside the class (Theorems 5.5 and 5.7 there; "Theorem B′" in the prover's file), and the lower bound for the number of unfaithful calls (Proposition 3.6 there), which the low-stakes paragraph of Section 3 can cite as the matching lower bound for L·√(K ln 2/(2n)): for the K coins every deployed sampler has at least (√3/32)·L·√(K/n) unfaithful calls in expectation for some member (n ≥ 3K/4).

**Letters.** The text follows Addendum 3 of the outline: ε is the accuracy in total variation, δ a failure probability, r a number of runs (k is kept for tolerated faults). It does not use η, α, ℓ, Λ or m; the proof file keeps its own letters.

**Length.** After the second round block (i) has 411 words and 605 whitespace-separated tokens (the difference is symbols of formulas); block (ii) has 700 words and 898 tokens. The limits are 500 and 700 words. (A word is counted as a token that contains two letters in a row; before the second round the counts were 384 and 682.) Block (ii) is at its limit: any further addition there needs a cut.

**What changed relative to the lead's draft and the candidate theory.**

1. *R2 has smaller constants.* The candidate theory had E TV ≤ √(c₀·L·K ln 2/n) with c₀ = 7 from a sketch; the prover's file had 2·√(L·K ln 2/n); the final bound is s + √(s² + 2s) ≤ √(2·L·K ln 2/n) with s = L·K ln 2/(2n), and for runs that the human system never produces L·K ln 2/n in place of 4·L·K ln 2/n. The sentence in `research/sections/intro.md`, answer 1, "within 2√(L·K ln 2/n) of the human system's in total variation", is true and can now read "within √(2·L·K ln 2/n)". Addendum 1 of the outline quotes the old constants.
2. *R2 no longer rests on the subadditivity of H² alone.* Lemma L4 has three parts; the bounds on the total variation and on events come from parts (b) and (c), which were found by the second verifier during verification. The constant 2.9642 for part (a) is kept as a remark.
3. *L4, attribution.* The constant 7 is Lemma D.2 of Foster, Han, Qian and Rakhlin (2024), as Addendum 2, item 7, says; the candidate theory named the wrong paper.
4. *Theorem A (now H1) is called standard* (the progressive mixture rule), and is stated also for a human outside the class and for events of probability zero.
5. *Theorem B (now H2)* is stated with the free exponent s; for λ > 2 the choice s = ½ is better than the candidate's 1/λ. Its relation to Barron and Cover (1991) and to Zhang (2006) is stated; the failure at λ = 1 is called a known phenomenon.
6. *New in the text:* the sharpened form of R2 when the questions do not depend on the answers (first verifier); "the per-call mixture fails here" with the size of the loss; the cost paragraph.
7. *The draft `note.md`* has no subsection on whole runs and no Section 5.2; its sentence in Section 3.1 on the deterministic human is the first sentence of block (i), and its Section 8.1 ("Theorems R1 and R2 give this at the price K") stands.

**Who checked what** (details in `proofs/hellinger-runs.md`, section "Checking", with its subsection "Second check"). Checked by both verifiers: L4(a) with the constants 4 and 2.9642, R2(a), the lower bounds, H1, the failure of the per-call mixture, H2, the example at λ = 1. Found during verification by one verifier, checked by the editor, and then verified by the second check (`verification/hellinger-runs-second.md`): L4(b), (c) and with them R2(b), (c) in the final form (second verifier); the form of R2 for questions that do not depend on the answers (first verifier); the bound of H1 for runs that the human system never produces (second verifier); the oracle inequality behind the last sentence of the paragraph on λ = 1 (second verifier; for the program of largest posterior weight it is Zhang's Theorem 4.1). The sentence on r runs was the editor's and has been verified by the second check as well. No statement of the text is unchecked, and after the second check none rests on its author and the editor alone; the text therefore carries no remark on checking.

**Second round (16 November 2026): what changed in the text.** The second check found no statement wrong. Its findings N1 to N9 on the wording were decided as follows (reasons in the proof file, "Second check"). Block (i): the remark that L4(b), (c) were "added during verification and checked by the editor" is removed (N1); the last case of R2 says "in the same expectation" (N2); the pointer for L4 names Corollaries 2.3 and 2.11 (N3); the sentence on r runs says that the runs are independent runs of M^(T) and that the bound is for the expected total variation (N4); the paragraph on the factor L no longer carries the label N6, says "below ε", "more than" and "L ≥ 3 odd" (N5). Block (ii): for the last posterior the text now says that Grünwald and Kotłowski "pose such a bound as an open problem; a brief search found no solution" (N6; the editor read the paper and made three web searches); the counterexample names the human and says "up to L times" (N7); the sentence on Foster, Block and Misra says that it is the proof at λ = 1, for maximum likelihood (N8); "It saves no answers beyond a constant factor", with the lower bound of Section 3.2 in place of N6 (N9). Not taken from the proposals: the citation of the second check in the note's text (N1), the clause "so H1 fails once L ≥ 6" (N7) and the pointer to Remark 5.3 (N8), the last two for length. No sentence that `research/orchestration/patches.py` replaces was changed.

**References to add to the list of Section 12** (each with how it was read).

* Zhang, T. (2006). "From ε-entropy to KL-entropy: analysis of minimum information complexity density estimation." *Annals of Statistics* 34(5):2180–2210. arXiv:math/0702653. Theorems 4.1, 4.3, 5.1 and Sections 4.3, 4.4 read in the arXiv text by the second verifier and by the editor; in the second round the editor read again, in the arXiv PDF, the definitions of the two divergences, Theorems 4.1 and 5.1, the remark after Theorem 4.1 on a finite family with the uniform prior, and the openings of Sections 4.3 and 4.4.
* Juditsky, A., Rigollet, P. and Tsybakov, A. B. (2008). "Learning by mirror averaging." *Annals of Statistics* 36(5):2183–2206. arXiv:math/0511468. Corollary 5.4 and the sentence that attributes its oracle inequality to Catoni and Yang read in the arXiv text by the second verifier and by the editor.
* Catoni, O. (1997). "A mixture approach to universal model selection." Preprint LMENS-97-30, École Normale Supérieure, Paris. Not opened; cited as Juditsky, Rigollet and Tsybakov cite it. (They also cite Catoni's preprint of 1999 and his lecture notes, Springer Lecture Notes in Mathematics 1851, 2004.)
* Yang, Y. (2000). "Mixing strategies for density estimation." *Annals of Statistics* 28(1):75–87. Not opened; cited as Juditsky, Rigollet and Tsybakov cite it.
* Barron, A. R. and Cover, T. M. (1991). "Minimum complexity density estimation." *IEEE Transactions on Information Theory* 37(4):1034–1054. Not opened; its Theorem 4 as Zhang (2006) reports it.
* Barron, A., Schervish, M. J. and Wasserman, L. (1999). "The consistency of posterior distributions in nonparametric problems." *Annals of Statistics* 27(2):536–561. Not opened; cited as Zhang (2006) and Bhattacharya, Pati and Yang (arXiv:1611.01125) describe its counterexample.
* Grünwald, P. D. and Kotłowski, W. (2011). "Bounds on individual risk for log-loss predictors." *Proceedings of the 24th Annual Conference on Learning Theory*, PMLR 19:813–816. Abstract read on the proceedings' page by the editor; in the second round the editor read the paper (four pages) in the PDF of the proceedings. Its second question is the one of the note: for a countable model, a bound of the form −log W(P*)/n^γ on the individual risk of the Bayesian predictive distribution. Three web searches on 16 November 2026 found no solution; they were not exhaustive.
* Already in the list: Foster, Han, Qian and Rakhlin (2024); Foster, Kakade, Qian and Rakhlin (2021); Foster, Block and Misra (2024). The two lemmas were read again in the TeX sources by both verifiers and by the editor. In the second round the editor read Proposition 2.1 of Foster, Block and Misra in the TeX source of arXiv:2407.15007 (files dated 3 December 2024): it is the first proposition of Section 2, for a finite class that contains the expert and the maximum-likelihood policy, with D²_H ≤ 2·log(|Π|/δ)/n in the convention D²_H = 2H².

**Open points for the lead.**

1. The sentence of `research/sections/related-work.md` on the subadditivity of H² should be brought in line: constants 4 and 2.9642 (not 2.9641, which rounds an upper bound down), example 2.9639 confirmed in 30-digit arithmetic, and "no published constant below 7" confined to the inequality with H² on the left. A bound of the total variation by the same sum is, from a verifier's memory, classical (Kabanov, Liptser and Shiryaev 1986; Jacod and Shiryaev, Chapter V); nobody could open the source, so the note should not relate L4(b) to it before that is done. Duchi's notes and the Yale course note are unopened as well.
2. The word limits are met in words and exceeded in tokens (see "Length").
3. Other parts quote this part with the earlier constants and should be brought in line at assembly: `proofs/one-mind.md` (R2 as "E TV ≤ 2·√(L·K ln 2/n)", and "the constant 2.9641 of Theorem 2.7"), `research/sections/intro.md` (answer 1) and `research/sections/related-work.md`. The earlier statements are true but weaker (2·√ in place of √2·√), except that 2.9641 rounds the constant c* = 2.964147… down.
4. Open mathematical questions of the part are listed in `proofs/hellinger-runs.md`, Section 8.1: whether the best constant in L4(a) equals c*; the last round in place of the random round; the per-call mixture after recorded runs on adaptive scaffolds; whether E TV ≤ √(L·K ln 2/(2n))·(1 + o(1)) holds when the questions depend on the answers; the best constant in R2(a).
5. *Second round, state of points 1 and 3.* `research/sections/related-work-final.md`, which the assembly uses for Section 12 when it exists, has the paragraph "Whole runs (Section 3.2)" with 2.9642, without "computed in floating point" and without the claim that R2 uses the inequality, and it uses the labels H1 and H2; so the findings N10 and N11 of the second check, which quote `related-work.md`, need no further change if that file is used. `intro.md` has √(2·L·K ln 2/n). Still with the earlier constants: `proofs/one-mind.md` ("the constant 2.9641 of Theorem 2.7", which rounds c* down, and "E TV ≤ 2·√(L·K ln 2/n)") and `proofs/lower-bounds.md` ("Err ≤ 2·√(L·K ln 2/n)", "4·L·K ln 2/ε² questions"). All of these but "2.9641" are true and weaker than the final statements.
6. *Second round, one sentence of Section 12 that the lead may want to make exact* (`related-work-final.md`, paragraph "One program; recorded runs", as it stood on 16 November at 04:06). "Whether the last predictive density alone has such a bound is the open problem of Grünwald and Kotłowski (2011)": they posed it in 2011 (their second question, for a countable model), and that it is still open rests on three web searches only; "is a problem that Grünwald and Kotłowski (2011) posed as open" claims no more than was checked. The sentence of the same paragraph on Foster, Block and Misra ("the proof of H2 gives Proposition 2.1 …") agrees with the text of Section 5.2 and with Remark 5.3 of the proof file.
