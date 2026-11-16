# Referee report: the mathematics of `note.md` as printed

Role: referee of the mathematics of the note as it is printed. The object is `note.md` as assembled on 16 November 2026 at 03:11 (719 lines). The report has these sections: method; verdict; findings; the printed arguments one by one; upper bounds against lower bounds; worked numbers; edge cases; definitions; what was not checked; the state of the section sources.

## 0. Method

* I read `note.md` (719 lines, Sections 0 to 13) from beginning to end before opening any other file, and checked every printed proof and proof idea against the statement it stands under: hypotheses, constants, quantifiers.
* Where the note prints an idea and not a proof, I tried to complete the idea into a proof myself. Section 3 says for each statement whether I succeeded, and gives the argument where it is short, so that it can be compared with the proof file.
* I opened a proof file only to settle a doubt, and each such use is named in Section 3. I read no proof file from beginning to end. I did read line by line, in the proof files, the proofs of Lemma L4 (b), (c) and the constant 4 of (a), of N2b, N5, N8, of the two versions of N6, of Theorem 9.2 and Proposition 9.3 of `proofs/rehearsal-core.md`, of N7(a), of rows 3 and 4 of Ab4, and of R6(c). R6(c) is the statement that the note marks "not independently checked"; I found its proof correct (Section 3.4).
* Numbers were recomputed by `verification/code/referee-math_checks.py`. Its output is `verification/code/referee-math_checks.out`: 137 tests of statements of the note, all passed, and 14 numerical demonstrations of defects that are listed below. The script takes ten seconds. It contains exact enumerations of the rehearsal protocol on small random instances (R1, R7, R4, I1, R6(a), R6(b), the oracle inequality), simulations and an exhaustive search for Rule NH (Pr5), a dynamic programme for N7(a), and exact rational or binomial computations for V1, Pr3 and Pr7(b).
* I read no literature in this session. Every statement that the note marks as standard or attributes to a source was checked for internal consistency only.
* I did not re-run the three toy computations of Section 11. I compared the numbers of the note with the saved outputs in `results/` and recomputed the closed-form quantities (bounds, K, weights).
* While I worked, other people edited the section sources and some proof files (the time stamps run from 03:47 to 04:16). After my own pass was complete I assembled the sources as they stood at 04:19 into a scratch copy and compared it with the printed note. Section 9 says which of my findings the sources had already corrected. The comparison also showed me eight defects of the printed note that I had missed; I verified each of them independently and list them as F29 to F36, marked as found in this way. I then read the printed note a second time, which gave F37 to F39. Statement numbers of proof files are those of the versions I read.

## 1. Verdict

Every printed proof is a proof of the statement it stands under, with the printed hypotheses and constants. This holds for R1, R2, R7, R3, V1(a) and (b), N1, N2, S4, S1(a), Ab1, Ab3, Pr3 and Pr6. Two printed proofs leave out a step that the statement needs: the proof of V1 does not cover part (c), and the proof of R2 does not say why a bound in σ passes to expectations in part (b). Both steps are two lines and are given below (findings F5, F15).

Every printed proof idea that I tried to complete can be completed, and so can the statements printed without an idea that I tried to derive: R4, R3a, H2, Pr4, Pr5, Ab2(a) to (c), N2c, I1, E2, Pr2(a), Pr2(b), "What holds" after Pr2(b), S1(b), S5, N3, N2a, N2d, N7(b), H1 and the two counterexamples of Section 5. For L4 I did not complete the idea myself; I read the proof in the proof file and found it correct.

With the hypotheses and ranges of the numbered statements, no lower bound exceeds its matching upper bound at any parameter value that I tried (Section 4). Two sentences that restate N7(a) without its range do put a lower bound above the upper bound N7(b) (findings F30 and F37). Every worked number that I recomputed agrees with the note, with one exception: the constant 2.9641 in Section 12 (finding F2).

Six statements are false as printed. One is a contradiction between the summary and Section 5 (F1). One is a rounding in the wrong direction (F2). Three are inequalities printed without the range in which they hold (F3, F30, F37). One is a hypothesis stated too weakly for a human who varies (F29). In all six the theorem behind the sentence is correct and the correction is a change of wording. There are three gaps: two objects that statements use and the note never defines (F4, F6), and the missing argument for V1(c) (F5). The remaining findings are missing ranges and conventions, undefined labels and wording. I found F1 to F28 in my first reading of the printed note. F29 to F36 I found only by the comparison with the section sources described in Section 0; they include two of the six false statements. F37 to F39 I found in a second reading of the printed note after that comparison, which had shown me the table-row half of F37.

## 2. Findings

Grades: WRONG (a false statement as printed), GAP (something that a statement or proof needs is missing from the note), MINOR, WORDING. Line numbers are those of `note.md`. The text of the note is generated, so each correction has to be made in the section source named in brackets.

### WRONG

**F1. Section 0, item 6 (line 28) [`intro.md`].**
Sentence: "One program in place of the mixture is possible for a deterministic human: a single posterior draw at the end has an unfaithful run with probability below 2L(K ln 2 + ln(1/δ))/n (R6). It is not possible for a human who varies, unless whole runs of the human system are recorded (R4, H1)."
What is wrong: the second sentence contradicts Proposition R6(c), the third row of the table in Section 5.1 ("squared weights: R6c") and item 7 of Section 13. By R6(c), after rehearsal alone the member that maximises w(ν)²·ν(D) has H²(Q_ν̂, Q_P) < L·(28·K ln 2 + 40·ln(1/δ))/n with probability at least 1 − 2δ, for any human in the class. I checked the proof of R6(c) (`proofs/one-mind.md`, Theorem 3.8) line by line and found it correct. What fails for a human who varies is a posterior draw, and the citation is also off: with recorded runs H1 draws a new program for each run, and one program for good needs the weights w^λ with λ > 1 (H2; at λ = 1 "the statement fails").
Correction: replace the second sentence by "For a human who varies a posterior draw does not do (example after R4), unless whole runs of the human system are recorded: then a draw for each run does (H1), and a draw kept for good does if the weights are w^λ with λ > 1 (H2). After rehearsal alone, the member that maximises w(ν)²·ν(D) can still be kept for good (R6(c))."

**F2. Section 12, last paragraph (line 689) [`related-work.md`].**
Sentence: "The note proves c₀ = 4 and, by a longer argument, c₀ = 2.9641, and gives an example with ratio 2.9639, computed in floating point."
What is wrong: the constant that the longer argument proves is c* with 2.96414712 < c* < 2.96414723 (`proofs/hellinger-runs.md`, Theorem 2.7; I recomputed c* = 2.96414716 from the equation stated there). 2.9641 is below c*, so the inequality with c₀ = 2.9641 is not proved. Sections 3.2 and 13 say 2.9642, which is correct.
Correction: "c₀ = 2.9642".

**F3. Section 3.4 (line 144) [`rehearsal-core.md`].**
Sentence: "The rate is right: every protocol has at least 0.088·L·√(K/n) unfaithful calls in expectation for some member of a class of K bits (Theorem 9.2), and in an example failure γ ≤ ½ needs K·(1 − 2γ)²/(32θ²) questions (Proposition 9.3)."
What is wrong: the first half is printed for every n. For n < 0.0078·K the right side exceeds L, the largest number of calls of a run (K = 1000, L = 10, n = 5 gives 12.4 > 10). Theorem 9.2 of the proof file assumes n ≥ K/2, and its class depends on n. The theorem itself is correct; I read its proof.
Correction: "every protocol with n ≥ K/2 questions has at least 0.088·L·√(K/n) unfaithful calls in expectation for some member of a class of K bits that depends on n (Theorem 9.2)".

**F37. Section 0, item 4, last bullet (line 24) [`intro.md`], and Theorem Ab4, row 1 (line 424) [`shift-abstain.md`].**
Sentences: "In an open system the human cannot leave early: on a class of 2^K thresholds, the expected number of silent errors and abstentions, multiplied by the number of questions plus one, is at least 3·2^K/16; a deterministic human can leave after about 2^K questions (N7)." and "2^K thresholds: E[Sil + Abs]·(questions + 1) ≥ 3·2^K/16 (N7)".
What is wrong: N7(a) is for learners with at most Q ≤ 2^(K−1) − 1 questions, and Abs counts abstentions that nobody answers. Without that range the inequality is false, and the second half of the first sentence is the counterexample: with 2^K − 1 questions (enumeration, N7(b)) there is no silent error and no unanswered abstention, so the product is 0.
Correction for the bullet: "… on a class of 2^K thresholds, for every learner with at most 2^(K−1) − 1 questions, the expected number of silent errors and unanswered abstentions, multiplied by the number of questions plus one, is at least 3·2^K/16; a deterministic human can leave after at most 2^K − 1 questions (N7)." The table row is already corrected in the section source ("inputs in order, at most Q ≤ 2^(K−1) − 1 questions: E[Sil + Abs]·(Q + 1) ≥ 3·2^K/16, Abs counting unanswered abstentions").

### GAP

**F4. `sep(x; A)` is never defined (lines 400, 412, 431, the table of Section 7.4, line 587) [`shift-abstain.md`, `assumptions.md`].**
Statements Ab2(c), Ab3(a) to (c), the table "Rocks and whitelists" and Section 9.2 use sep(x; A); the printed proof of Ab3 speaks of a "test of fewer than s bits" that "separates x from A". The note defines neither. The same holds for K(Q) in Section 4.1 (line 188) and K(R) in Pr2(a) (line 543), the complexity of a set.
Correction: add to the first paragraph of Section 7, after "c denotes constants of the reference machine": "K(Q) is the length of a shortest program that decides the set Q, and sep(x; A) is the least K(Q) over the decidable sets Q that contain x and no element of A." In Section 4.1 add "(K(Q): the length of a shortest program deciding Q)" at the first use. With this definition the printed proof of Ab3 is correct, and the count 2^s − 1 in (a) is the number of programs of fewer than s bits.

**F5. Theorem V1(c) has no printed argument (lines 162, 164) [`rehearsal-core.md`].**
The printed proof reads "*Proof.* Theorem 13.1. For (a): … For (b): Hoeffding's inequality and a union bound. ∎". Part (c) does not follow from (b) as stated: (b) is two-sided with ln(2/δ) and is about a family fixed in advance; (c) has ln(1/δ), the weights of the class and the identity β(A)/L = Δ(B).
Correction: add "For (c): for a sampler A and B_ν := {(x, y) : A(y|x) > ν(y|x)} we have TV(A(·|x), ν(·|x)) = A(B_ν|x) − ν(B_ν|x) at every x, so β(A)/L = Δ(B_P). Give B_ν the weight w(ν) for the ν with w(ν) ≥ 2^(−K₀). The one-sided Hoeffding inequality with failure probability w(ν)·δ and a union bound give, for all these ν at once, Δ(B_ν) ≤ recorded difference + √(2·(ln(1/w(ν)) + ln(1/δ))/m); under A2 and K ≤ K₀, P is one of them." I checked this argument; it gives (c) exactly as printed.

**F6. The squared Hellinger distance is not defined (line 102; used in L4, R2, R6(c), H2, the example at λ = 1, Section 12) [`hellinger-runs.md`].**
Two normalisations are in use in the literature and they differ by the factor 2. The printed constants hold for H²(p, q) := 1 − Σ_y √(p(y)·q(y)): only then is H² ≤ KL/2 (proof of R2), H² = 0.29 for a table against a fair coin (Section 5.2), and TV < √2·ε from H² < ε² (H2). With H² = Σ(√p − √q)² the inequality L4(a) is unchanged, but L4(b) and (c), R2(a), R6(c), H2 and the 0.29 are not.
Correction: in Lemma L4 add "Here and below H²(p, q) := 1 − Σ_y √(p(y)·q(y)), so that 0 ≤ H² ≤ 1, H² ≤ KL/2 and TV ≤ √(2·H²)."

### MINOR

**F7. Section 3.2 (line 122): two different statements are called N6 [`hellinger-runs.md`, `lower-bounds.md`].**
Sentence: "**The factor L under the root is necessary** (N6, Section 4; proved here). Let K ≥ 8, L a multiple of K with L ≥ 4K, and ε ≤ 1/65. … more than L·K/(8·10⁴·ε²) answers …"
What is wrong: Theorem N6 in Section 4.5 is another statement: another scaffold (one uniform input asked L times, against each of K inputs asked L/K times), other hypotheses (ε ≤ 1/64, no condition on K and L) and another constant (8192). A reader who follows the reference finds neither the hypotheses nor the constant. Both statements are correct (I read both proofs).
Correction: "(proved here; a variant of N6, Section 4.5, for a scaffold that asks each of K inputs L/K times)".

**F8. Corollary N2d(a), (b) (lines 242, 243): ranges missing [`lower-bounds.md`].**
Sentences: "(a) Class of N2 with L/(2δ) cells, every protocol: r·L/n ≤ 4F/(1−4δ)." and "(b) Class of N2b, every protocol: r·L/n ≤ 8F·log₂(L/(2δ))/((1−10δ)·K)."
What is wrong: δ is defined in the corollary as F/r and is not restricted. For δ > 1/4 the right side of (a) is negative, for δ ≥ 1/10 that of (b) is negative or undefined, and both need L/(2δ) to be an integer. The proof file has "δ ≤ 1/4 and L/(2δ) an integer" and "δ ≤ 1/20 and L/(2δ) an integer".
Correction: "(a) Class of N2 with L/(2δ) cells (an integer; δ < 1/4), every protocol: …" and "(b) Class of N2b (δ ≤ 1/20, L/(2δ) an integer), every protocol: …".

**F9. Theorem R7 (line 126): the mixture can be undefined [`rehearsal-core.md`].**
Sentence: "Nothing is assumed about the human or the class; of A3 only (i), (ii) and (v) are used."
What is wrong: without A2 the recorded answers can have probability zero under every hypothesis, and then M^(t) is not defined by Section 1. The proof uses only that the imitator of round t is computed from the data of rounds 1, …, t − 1.
Correction: "Nothing is assumed about the human or the class (where the recorded answers have probability zero under every hypothesis, let M^(t) be any sampler computed from the earlier data); of A3 only (i), (ii) and (v) are used."

**F10. Theorem N5 (line 226): the horizon needs a cut-off, and n is not said to be counted under f₀ [`lower-bounds.md`].**
Sentence: "The scaffold draws g regions, asks each region's inputs in turn until k+1 answers agree, and outputs 1 if some region gave 1; L = g·(k+1)+k."
What is wrong: with an arbitrary answerer the scaffold as described makes up to g·(2k+1) calls, which is more than g·(k+1)+k when g ≥ 2 and k ≥ 1. Section 1 defines the horizon as a bound on every run, and R1 and R3 are applied with this L in the next paragraph. The proof file stops a run that would need a further call, with outcome 0. Also N2, N2b, N3 and N8 say under which human n is counted; N5 does not (it is f₀).
Correction: "… asks each region's inputs in turn until k+1 answers agree, stops with output 0 if that would take more than L := g·(k+1)+k calls in all, and otherwise outputs 1 if some region gave 1." and "… needs, counting n under f₀, n ≥ (1−4δ)·(L−k)/(4·(k+1)·δ)."

**F11. Section 4.1 (line 188): the sentence on partners contradicts the convention of Section 1 [`lower-bounds.md`].**
Sentence: "A human who may answer any string at x has no partner with a disjoint answer law, only partners at total variation 1−1/N, for a further log₂N + 2·log₂log₂N bits (N ≥ 2)."
What is wrong: Section 1 says "A hypothesis may be a program that sometimes gives no answer; that counts as one more answer", and the sentence begins "Among all programs". Among all programs the hypothesis "as P outside Q, no answer on Q" is a partner at K(Q) + c bits whose answer law at x is disjoint from that of a human who always answers. The sentence is true only for hypotheses that answer with probability one (`proofs/lower-bounds.md`, Proposition 1.8, parts 2 to 4).
Correction: "Among programs that always answer, a human who gives every string positive probability at x has no partner with a disjoint answer law, only partners at total variation 1−1/N, for a further log₂N + 2·log₂log₂N bits (N ≥ 2); a program that gives no answer on Q is a partner at total variation 1 − P(no answer | x), for K(Q)+c bits."

**F12. Section 2, "Compute" (line 70): a trial need not end [the paragraph is supplied by `patches.py`].**
Sentence: "If the hypotheses are programs that always halt, for instance programs that carry their own time bound, and the weights are 2^(−length) in a decidable prefix-free code, a posterior draw can be made by rejection: read a program from coin flips, run it with fresh coins on the recorded questions, and keep it if it reproduces the recorded answers."
What is wrong: if the code is not complete, the coin flips spell no code word with probability 1 − Σ 2^(−length) > 0, and "read a program" then never ends; that a string has no extension in a decidable prefix-free set is not decidable in general. The two claims that follow (the kept program has the posterior law; at most 2^K/P(recorded answers) trials in expectation) are correct: a trial is kept with probability Σ_ν w(ν)·ν(D) ≥ 2^(−K)·P(D).
Correction: "… in a decidable prefix-free code in which it is also decidable whether a string begins a code word (a trial whose flips cannot be continued to a program is abandoned) …".

**F13. Section 5.1, first paragraph (line 252) [`one-mind.md`].**
Sentence: "Every upper bound below is linear in K, hence empty for a person (K of the order of 10⁹ bits, Section 9); the content is the comparison."
What is wrong: R6(a) is L·(2^K − 1), exponential in K, and the bounds of R5 for the committee do not contain K.
Correction: "Every upper bound below that contains K is at least linear in K, hence empty for a person".

**F14. Pr2(b) (line 545): the total weight of the memorisers is not stated [`property-batch.md`].**
Sentence: "… and all memorisers (a table on some inputs, the answer b elsewhere) with weights proportional to (4u)^(−size)."
What is wrong: the printed formula, with (4u + 2)^n/(2^K − 1), holds when the memorisers have total weight 1 − 2^(−K). Section 1 allows weights of total less than 1, and then the value is smaller. (With total weight 1 − 2^(−K) I confirmed the formula by enumeration of all memorisers for u = 5, 6, 7.)
Correction: "… with weights proportional to (4u)^(−size) and of total 1 − 2^(−K)."

**F15. Proof of R2 (line 118): the step to expectations in (b) [`hellinger-runs.md`].**
Sentence: "By Theorem R1 and H² ≤ KL/2, the σ of Lemma L4 with A = M^(T) and B = P has expectation at most s."
What is missing: (b) is not linear in σ, and the statement is "in expectation"; the proof does not say why the bound of L4(b) may be taken at the expectation of σ.
Correction: add "(a) and (c) are linear in σ; for (b), u ↦ min{1, u + √(u² + 2u)} is increasing and concave, so Jensen's inequality applies." (The second derivative of u + √(u² + 2u) is −(u² + 2u)^(−3/2).)

**F16. Labels and names that the note uses and does not introduce.**
* "Protocol R" (lines 328, 402, 679): Section 2 never names the protocol. Correction: in Section 2 write "**Rehearse** (Protocol R)."
* "Theorem A" and "Theorem B" (line 679, Section 12): "Theorem B is Proposition 2.1 for a countable class, and Theorem A its Bayes form." The note has no statements with these names; they are H1 and H2. Correction: "Theorem H2 is Proposition 2.1 for a countable class, and Theorem H1 its Bayes form."
* "Rule Ab2" (line 681): Ab2 is a theorem; the rule is Min_𝒞. Correction: "The rule Min of Ab2".
* "S2" (lines 22, 332, 356): cited three times, but no statement carries the label; the paragraph "What S2 needs" contains it. Correction: begin that paragraph with "**Proposition S2 (a mixture of task laws).** If rehearsal draws z from a mixture …".
* "a needle class" (line 427, Ab4, row 4): the class of N2 with (1 − a)·L/(2σ) cells (an integer). Correction: "the class of N2 with (1 − a)·L/(2σ) cells".
* "outcome" of a run (line 176): Section 1 gives a scaffold no output. Correction: add to Section 1 "A scaffold may also compute an outcome from the run."
* "unfaithful run" (lines 28, 95, 218 and others): not defined; it means a run with at least one unfaithful call.
* "Paper 1", "Paper 2" (lines 88, 188, 639, 677, 683): not identified; the reference list is empty.

**F28. Section 4.3 (line 220): the range of ε is missing [`lower-bounds.md`].**
Sentence: "Random questions cannot match this everywhere: on a class with K rare informative inputs, random calls of runs need n ≥ 0.1·K·L/ε−0.4 for failure ε, a seventh of what R1 guarantees, where K chosen questions suffice".
What is wrong: Proposition 3.7 of the proof file has 0 < ε ≤ 1/8, and its class depends on ε (each call meets a rare input with probability 4ε/L). Outside that range the inequality fails on that class: for K = L = 40 and ε = 1/2, failure at most ε is reached with 288 random questions, and 0.1·K·L/ε − 0.4 = 319.6 (exact computation of the best deployed system; script, D17). Inside the range the same computation confirms the bound (for example 250 questions against 160 at K = 20, L = 10, ε = 1/8).
Correction: "… random calls of runs need n ≥ 0.1·K·L/ε−0.4 for failure ε ≤ 1/8 …".

**F38. Section 9.5, seventh item (line 617) [`assumptions.md`].**
Sentence: "*the human is a sampler:* no certificate free of K then bounds the unfaithful calls (V1)."
What is wrong: it contradicts the last sentence of Section 8.7. If questions are put twice and there are at most q possible answers, the collision statistic bounds the expected number of unfaithful calls of a run of a sampler without any class: TV ≤ (√q/2)·√(Σ_y (P(y|x) − A(y|x))²) at each input, and the mean of the squared distance is estimated at the rate m^(−1/2). What V1 excludes is a certificate from one answer per input. Section 0, item 2, has it right. The same overstatement is in Section 10, item 2 ("the certificate V1(a), which can be issued for a deterministic human only": it can be issued for a human who is nearly deterministic on the inputs visited).
Correction: "*the human is a sampler:* no certificate free of K from one answer per input then bounds the unfaithful calls (V1); with questions put twice and few possible answers there is one, at the rate m^(−1/4) (Section 8.7)."

### WORDING

**F17. R2(b) (line 113) [`hellinger-runs.md` and `patches.py`].** "TV(Q_{M^(T)}, Q_P) ≤ min{1, s + √(s² + 2s)} ≤ √(2·L·K ln 2/n), which is at most ε after (1 + ε)·L·K ln 2/ε² rounds". The relative clause is true of the middle expression, which then equals ε exactly, and false of the last one, which then equals ε·√(2/(1 + ε)) > ε. Correction: "…; the middle expression is ε after (1 + ε)·L·K ln 2/ε² rounds".

**F18. Idea of the proof of Pr5 (line 506).** "the other half doubles at each non-zero increment while all have one sign, giving (ii)". With the slope as printed (the term σ·2^(V−2) only if V ≥ 1) the second half of the potential is ½ before and after the first non-zero increment and 2^(V−2) after V ≥ 1 increments of one sign: it doubles from the second increment on. That is what gives "log₂(1/π(B)) + 2"; doubling from the first increment would need a sign before any increment has occurred and would give "+ 1". Correction: "the other half stays at ½ at the first non-zero increment and doubles at each later one while all have one sign, giving (ii)".

**F19. Section 0, item 6 (line 28).** "a single posterior draw at the end has an unfaithful run with probability below 2L(K ln 2 + ln(1/δ))/n (R6)" has a free δ. Correction: "with probability at least 1 − 2δ over the rehearsal and the draw, a single posterior draw at the end has …".

**F20. Section 13, item 3 (line 699).** "the imitator built from tests pays K + 3 disagreements if the human is in the class and log₂(1/π(B)) + 2 violations of each property otherwise". Both numbers hold for one imitator only with the halved weights of Section 8.4, and then the second is log₂(1/π(B)) + 3 in the original weights. Correction: "… and log₂(1/π(B)) + 3 violations …".

**F21. Section 3.1 (line 90).** "It is empty for n below L·K ln 2". As a bound on the expected number of unfaithful calls it is below the trivial bound L as soon as n > K ln 2; it is empty for n below L·K ln 2 only as a bound on the probability that a run has an unfaithful call. Correction: "As a bound on the probability of an unfaithful run it is empty for n below L·K ln 2".

**F22. Section 0, item 4, second bullet (line 21).** "a class of candidates of log₂(L/2δ) bits for which every protocol needs at least L/(4δ) − L questions … For one such run it is cheaper to let the human make the L calls." The class has L/(2δ) + 1 members; the bound with − L needs L/(2δ) to be an integer and δ ≤ 1/6; and L/(4δ) − L ≥ L only for δ ≤ 1/8 (at δ = 1/6 the bound is L/2). Correction: "… a class of L/(2δ) + 1 candidates for which every protocol needs at least L/(4δ) − 3L/2 questions … (N2; δ ≤ 1/6). For δ ≤ 1/10 that is no fewer than the L calls of one run".

**F23. Theorem E1 (line 595).** "K the weight of that function". Correction: "K := log₂(1/w) for the weight w of that function".

**F24. V1(a), (b) (lines 158, 160).** "the recorded rate of disagreement" and "the two recorded frequencies" must be counted over all m rounds: a round whose run has fewer than J calls records nothing and counts as zero. Counted over the recorded pairs only, (b) fails when runs can be shorter than L: the difference then estimates Δ(B) multiplied by m over the number of recorded pairs. (The bound of (a) stays true under that reading, because it increases with ρ̂, but it is not the one proved.) Correction: add "(counted over all m rounds)".

**F25. Notation used twice in one section.** ρ is the scaffold's random bits (Sections 1, 3.2, 3.4, 4) and the probability of a recorded disagreement in V1(a); s is L·K ln 2/(2n) in R2 and the noise of the human in V1(a); σ is the sum of Hellinger distances in L4 and the allowed loss in R3a. Correction: in V1(a) write other letters for the probability of a recorded disagreement and for the noise of the human (the proof file has s_P for the second), and in R3a write ζ for σ, as the section source now does.

**F26. Section 4.4 (line 230).** "The example repeats one question to a deterministic human". The scaffold asks 2k+1 different inputs of a region, on which every member is constant. Correction: "The example asks 2k+1 inputs on which every member is constant".

**F27. Section 0, item 7 (line 30).** "Every bound is in K". The bounds of R7, V1(a), V1(b), Pr5 and Pr6 are not, as item 2 and item 5 say. Correction: "Every bound on imitation is in K".

### Found by comparing the printed note with the section sources (F29 to F36)

I had passed over these eight sentences in my own reading. Each is a defect of the note as printed; each verification below is mine. In every case the section source, as it stood at 04:19, already has a corrected sentence, which I quote or paraphrase as the correction.

**F29. WRONG. Section 3.4 (line 142): the hypothesis of the recoverable form [`rehearsal-core.md`].**
Sentence: "In the recoverable form (standard: Ross, Gordon and Bagnell 2011, Theorem 2.2), one replaced answer followed by the human raises the expected cost by at most μ, and the run of A then costs, in expectation, at most μ·β(A) more than the human system's (Theorem 8.6)."
What is wrong: "raises the expected cost by at most μ" reads as a comparison with the expected cost when the human answers. For a human who varies the conclusion is then false, because the replacing rule sees the human's answer and can replace exactly the cheap ones. Example: one call; the human answers 1 or 0 with probability ½; the cost is 0 after 1 and 1 after 0. A replaced answer raises the expected cost by at most ½, so μ = ½; the imitator that always answers 0 has β = ½ and costs ½ more than the human system, which is more than μ·β = ¼. Theorem 8.6 of the proof file compares the replaced answer with every answer that the human gives with positive probability (μ = 1 in the example, and ½ ≤ 1·½). For a deterministic human the two readings agree.
Correction (as in the source): "one replaced answer followed by the human costs, in expectation and from every history, at most μ more than any answer the human might have given there; the run of A then costs …".

**F30. WRONG. Section 6.2 (line 372): the reading of N7 [`shift-abstain.md`].**
Sentence: "So a deterministic human can leave an open system: never later than after 2^b − 1 questions, but with 2^K equally weighted thresholds not before about 3·2^K/(16j) if j silent mistakes and unanswered abstentions are tolerated in expectation."
What is wrong: N7(a) holds for Q ≤ N/2 − 1 only, so it gives "not before min{2^K/2, 3·2^K/(16j)} − 1 questions". For j < 3/16 the printed number exceeds the 2^K − 1 inputs of the sequence and the 2^K − 1 questions of the first half of the same sentence (b = K). Script, part E: for 2^K = 32 and j = 0.05 the printed number is 120; the least number of questions with which E[Sil + Abs] ≤ j can be had is 30; the correct bound is 15. The first half also needs a known bound b ≥ K.
Correction (as in the source): "… never later than after 2^b − 1 questions, if a bound b ≥ K is known; but for 2^K equally weighted thresholds as in (a), not before 2^K·min{1/2, 3/(16j)} − 1 questions on some run, if j silent mistakes and unanswered abstentions are tolerated in expectation."

**F31. MINOR. Section 7.5 (line 446) [`shift-abstain.md`].**
Sentence: "The counts of Ab1 hold in expectation only if the human has everywhere a preferred answer of probability above 1 − η, and the rule then imitates that answer, not the distribution."
What is wrong: the sentence is read as saying that under this condition the counts of Ab1 hold in expectation. They do not. Example (script, part E): a human who answers 1 with probability 0.7, and one other hypothesis that always answers 0, weights ½ (K = 1), η = 0.4. Thr_η answers 0 until the human first answers 1: 1/0.7 = 1.43 wrong rounds in expectation, against K/log₂(1/η) = 0.76. The counts that hold have the divergence between coins in the place of the logarithms (Proposition 4.7 of the proof file): K ln 2/kl(1 − ε₀ ‖ η) wrong rounds, here 3.77.
Correction (as in the source): "If the human has everywhere a preferred answer of probability at least 1 − ε₀ > 1 − η, then in expectation Thr_η gives another answer in at most K ln 2/kl(1 − ε₀ ‖ η) asked rounds and abstains in at most K ln 2/kl(ε₀ ‖ η) …; it imitates that answer, not the distribution."

**F32. MINOR. Section 7.4 (line 442) [`shift-abstain.md`].** "For the class of all programs no row is computable." Row 1 is: the rule that repeats the recorded answers at the asked inputs and refuses every other input is computable and never silently wrong. Correction: "rows 2 to 6 are not computable".

**F33. MINOR. Section 7.4 (line 442) [`shift-abstain.md`].** "If the calls of a decomposition share a property of fewer than r − c bits that no asked input has, every abstaining row refuses them all". Row 2 (enumeration with budget b) has no parameter r; by the table it refuses sep ≤ b − K_D − c, so it refuses such calls only if b − K_D ≥ r. Correction: "rows 1 and 3 to 5 refuse them all, and row 2 does if b − K_D ≥ r". (I did not track the constants c.)

**F34. WORDING. Ab1(a) (line 382) [`shift-abstain.md`].** "So u ≤ K/log₂(1/η) and v ≤ K ln 2/η; examples attain both up to rounding." By the displayed inequality v ≤ K/log₂(1/(1 − η)), which is below K ln 2/η by a factor up to 1.39 (K = 20, η = 0.49: 20.6 against 28.3). So no example attains v = K ln 2/η up to rounding unless η is small. Correction: "So u ≤ K/log₂(1/η) and v ≤ K/log₂(1/(1 − η)) ≤ K ln 2/η; examples attain the first two bounds up to rounding."

**F35. MINOR. Proposition S3 (line 350) [`shift-abstain.md`].** "for some scaffold and class, failure probability at most δ ≤ 1/4 on Γ for every member needs n ≥ (L/(4δ) − L)/p." The term − L is the integer case of N2; it needs L/(2δ) to be an integer, as in finding F8. Correction: "if δ ≤ 1/4 and L/(2δ) is an integer, there are a scaffold and a class for which …". (I did not check the proof of this lower bound.)

**F36. WORDING. Five sentences.**
* Section 5.2 (line 320): "It saves no answers: Theorem R2 with n = N·L rounds has the same bound when the questions do not depend on the answers, and twice it otherwise". Twice the bound is four times the answers for the same guarantee. Correction: "It saves no answers beyond a constant factor".
* Section 3.2 (line 122): "needs more than L·K/(8·10⁴·ε²) answers before the run law of its imitator is within ε of Q_P". The proposition gives expected total variation at least ε for n up to that number, so the complement is "below ε", not "within ε".
* Section 3.2 (line 120): "r runs of one imitator are within √(2r·L·K ln 2/n) of r runs of the human system": the runs are independent runs of M^(T), and the bound is on the expected total variation.
* Theorem R2, last sentence (line 116): "If neither the questions of the scaffold nor their number depend on the answers, then KL(Q_P ‖ Q_{M^(T)}) ≤ L·K ln 2/n and TV(Q_{M^(T)}, Q_P) ≤ √(L·K ln 2/(2n))." The words "In expectation over the rehearsal and T" govern the list (a) to (c) only; this sentence needs them as well.
* Section 3.2 (line 122): "two samplers need L/(740·ε²) (L odd, ε ≤ 1/12)". Proposition 3.5 of the proof file is for odd L ≥ 3; L = 1 is not covered by its proof.

### Three further remarks on wording, from the printed note

**F39. WORDING.**
* "What S2 needs" (line 356): "No sampler that halts with probability one dominates every law that such samplers produce". "such samplers" follows the example of the programs under a fixed time bound, which a halting sampler does dominate (the mixture with the weights π_p). The sentence must mean the laws of all samplers that halt with probability one. I did not check the claim.
* Section 11 (line 665): "against the bound of Proposition R6(a), L times the number of functions heavier than f (6, 30, 126)". R6(a) as printed has L·(2^K − 1), which is 38, 191 and 801 here. The sharper form is what the proof gives, and the enumeration of the script confirms it; R6(a) should state it: "at most L times the number of members at least as heavy as f, hence at most L·(2^K − 1)".
* Status of R6(c): line 274 says "(c) not independently checked", Section 13, item 7 (line 707) says "checked by one reader besides its author". After this report the second is true: I checked the proof (Section 3.4).

## 3. The printed arguments, statement by statement

For each statement: what the note prints, the verdict, and how I checked. "Own argument" means that I completed the printed idea, or derived the statement, without the proof file. "Read in the proof file" names the place. "Script" refers to `referee-math_checks.py`, part D unless another part is named.

### 3.1 Sections 1 and 2

* **Unfaithful calls, β(A).** The coupling is well defined, and the sentence "The run of A is thus a run of the human system in which a rule that sees the human's answer has replaced the answers at the unfaithful calls" is correct: given the history the shadow answer has the law P(·|x_j), and the rule draws A's answer from the conditional law of the coupling. β(A) = E_{Q_A} Σ_j TV(A_j(·|h_j), P(·|x_j)).
* **Caveat on A1.** "at total variation 1/2 from the real one": correct for Example 1.1 of `proofs/assumptions.md`, which I read (run (U, U) against two independent fair bits).
* **Caveat on A2.** The oracle inequality is correct: own argument (the regret identity with ν in the place of P), and exact enumeration with a human outside the class on 16 random instances (script). "refuted with probability 0.44": I re-derived the recursion of Example 2.3 (the member is refuted before the k-th question at a with probability ω_k/(2 + ω_k), ω_k = 1/(1 + 2^k)) and computed 1 − Π_k 2/(2 + ω_k) = 0.4435.
* **Caveat on A3.** "(L−1)/(2^ℓ+1) unfaithful calls … K = 1": correct for Example 3.3, which I read and re-derived (each live seed has posterior weight 1/(2^ℓ + |live|) and answers wrongly at L − 1 calls; the seed that the protocol uses is always live). Examples 3.3a and 3.6: not checked.
* **Compute.** Own argument: a trial is kept with probability Σ_ν w(ν)·ν(D) ≥ 2^(−K)·P(D), and a kept program has the posterior law. The reading step has the gap of finding F12.

### 3.2 Section 3

* **R1.** The printed proof is complete and correct, line by line. The telescoping uses ξ₀ ≤ 1; the conditional mean of the summand of an asked round is KL_t(x_t) by A1; the factor 1/L is exact because J is uniform and independent of the run, and a round whose run is shorter than J contributes nothing on both sides; the last step is e ≤ −ln(1 − e). Integrability is delegated to Lemma 4.1 of the proof file, which I did not read; the argument is standard (the negative part of each summand has conditional mean at most 1/e, and the partial sums are bounded above). Script: exact enumeration of the protocol on 36 random instances with L ≤ 3 and n ≤ 5, including weights of total 0.6, one-member classes (K = 0), K < 1 and runs with 0 to L calls; the largest ratio of the sum to L·K ln 2 was 0.76.
* **Bullets after R1.** "Equality is attained": read (two functions, weights w and 1 − w, L fixed calls: the sum is L·ln(1/w)). "exceeds the bound by the factor 1/δ with probability at most δ": Markov. "a factor 0.45/δ is needed": read the example of Proposition 5.2(d) and recomputed (Pr = δ·(1 − e^(−1/δ)) ≥ 0.632·δ; 0.63/(2 ln 2) = 0.454). "at most L·(K ln 2 + 1)/n" for the last round on a scaffold whose questions do not depend on the answers: own argument (the expected posterior mass of the hypotheses with error above s is at most min{1, 2^K·e^(−sn)}; integrate over s). "at most L times as often" for a new round at every call: own argument (1 − Π(1 − e_j) lies between max_j e_j and Σ_j e_j). "at least (L − 1)/8 times L·K ln 2/n" for the last round: I took the example from Proposition 6.2 of the proof file (three samplers) and computed both sides exactly for seven pairs (L, n) with L ≤ 4 (script, D18): the mixture after all n answers has between 1.6 and 1.8 times the claimed amount, and the mixture of a random round stays below L·K ln 2/n. Not checked: Propositions 5.5(b) and 5.3 (the factor L/4, and "more questions per run").
* **Lemma L4.** The note prints an idea. I read the proof in `proofs/hellinger-runs.md` (Lemma 2.2 with m = 2, γ = 1, and Lemma 2.10) and checked it line by line: the one-step inequality E U(Λr) ≤ U(Λ) + γm²·(1 − E r) for U(x) = (γ/2)·((m − x)₊)² and E r² ≤ 1; then U(x) − ½ ≥ 1 − x for (a) with the constant 4, U ≥ 1 − (1+η)x² for (c), U ≥ (1 − x²)₊ with γ = 2/(m² − 1) for (b). All three parts are correct as printed, with H² = 1 − Σ√(pq) (finding F6). Script: 4000 random pairs of history-dependent answerers, exact; the one-step inequality on 20000 random cases. Constants: "can be 2.9642" I recomputed from the equation of Theorem 2.7 (c* = 2.964147) and did not read its proof; "cannot be below 2.9639" I did not recompute (the example needs functions defined in that proof). I did recompute two explicit pairs, with ratios 1.707 (two calls) and 2.0997 (a lattice walk), so the best constant is above 2.
* **R2.** The printed proof is correct with the one-line addition of finding F15. (b): min{1, s + √(s² + 2s)} ≤ 2√s holds for all s, with equality of the two branches at s = ¼. "at most ε after (1 + ε)·L·K ln 2/ε² rounds": exact for the middle expression (finding F17). The last case (questions that do not depend on the answers): chain rule and Pinsker, correct. "r runs of one imitator are within √(2r·L·K ln 2/n)": correct (r runs are one scaffold of horizon rL with σ multiplied by r).
* **"The factor L under the root is necessary" (line 122).** Read Propositions 3.4 and 3.5 of `proofs/hellinger-runs.md` and checked every step of the arithmetic ((1/7)·(1/2)·√(3/64) ≥ 1/65; (7/8)/(16·65²) ≥ 1/(8·10⁴); 183·n·ε²/L ≤ ¼ for n ≤ L/(740ε²)). The two-coin inequality of Lemma 3.4a I checked numerically only (script, D16). Label: finding F7.
* **R7.** The printed proof is complete and correct. Script: exact enumeration, also with a human outside the class; the bound L on the sum over the rounds is attained (ratio 1.000 in one instance).
* **R3.** The printed proof is complete and correct: the stopped rule replaces at most k answers and its run equals the run of A unless A's run has more than k unfaithful calls. The consequence for M^(T) is arithmetic.
* **"survive 399 blindly replaced answers …" (line 140).** Recomputed for Example 8.5(d): (1 − 0.002)^3601 = 0.00074, β/(k + 1) = 0.02, sum 0.021, and Pr[Bin(4000, 0.002) ≤ 399] = 1.
* **The recoverable form (line 142).** Finding F29. With the hypothesis of Theorem 8.6 of the proof file (a replaced answer costs at most μ more than any answer of the human) the statement is correct; own argument: the expected cost of the corrupted run minus that of the human system is the sum over the calls of E[v(h_j, passed answer) − v(h_j, human's answer)], and each term is at most μ times the probability of a replacement at that call.
* **Human who is not deterministic (line 144).** "E[β(M^(T))] ≤ L·√(K ln 2/(2n))": own argument (Pinsker at each call, then Cauchy–Schwarz over at most L calls and Jensen). Theorem 9.2 and Proposition 9.3: read in the proof file, correct; range missing in the note (finding F3).
* **R3a.** The printed argument is a sketch; own completion: with X_j the step that the human's answer would have caused at call j, the rise of Φ is at least Σ_j X_j − k·(1 + D); Σ_j (X_j − E[X_j | past]) is a sum of martingale differences with conditional ranges of length 2, so it is below −√(2L·ln(1/δ)) with probability at most δ. Correct as printed, also the deterministic case and the consequence K ln 2·(1 + D)/(σ·a·δ′).
* **V1.** (a): the printed proof is correct (Σ a(y)p(y) ≤ Σ min(a, p), and Σ p(y)(p(y) − a(y)) ≤ TV(a, p)); the certificate and the bound with ρ̂ follow from (1 − ρ)^m and from the Chernoff bound in divergence form. Script: 20000 random pairs of laws; exact binomial sums for the bound with ρ̂ (largest probability 0.26·δ). (b): correct (range of length 2; the widths are exact). (c): finding F5; correct with the argument given there. "issued with probability at most exp(−m·s/2)": own argument (1 − Σ a p ≥ 1 − max p ≥ (1 − Σ p²)/2). "at least 1 − m·K ln 2/n": own argument (for a function ρ = β(A)/L). "300 rounds": recomputed; 300 is the least m. Proposition 13.4: not checked.
* **Section 3.6.** Follows from S5 (Section 3.4 below).

### 3.3 Section 4

* **N1.** The printed proof is complete and correct. The remark on all programs: finding F11; I read Proposition 1.8 for it and did not check its constants.
* **N2.** The printed proof is complete and correct. I checked the step "the bounds follow" by hand (with N = L/(2δ) the inequality reduces to N ≥ 2L(L − 1)/(L + 1), which holds for δ ≤ 1/4; with the ceiling the proof file's chain needs δ ≤ 1/6) and on a grid of 1845 pairs (L, δ) (script, part B). The converse, the bound on K and the two remarks after the proof are correct.
* **N2a.** No argument is printed. Own argument: the weighted average of N2 with U := the distinct cells of z that were not asked gives δ ≥ (N·p − n)/(N + L); with N = ⌈L/√(2δ)⌉ this is n ≥ L·(1 − √(2δ) − δ) − δ. It agrees with Proposition 2.5 of the proof file.
* **N2b.** Read the proof of Theorem 3.1 of `proofs/lower-bounds.md` (Steps 1 to 4) line by line; correct. The lower bound needs no condition on δ beyond N being an integer (it is negative for δ > 1/10). "⌈d/2⌉·(L/(4δ)+1/2) suffice": own argument (search ⌈d/2⌉ blocks completely; expected (N + 1)/2 questions each; failure at most p/2 ≤ δ). VC dimension d: correct.
* **N2c.** Own argument for all three claims: each question of the first kind multiplies the posterior weight of f by at least 1/(1 − γ) and each audited disagreement by more than 1/γ, with γ = ε·log₂(L/ε)/L; the vote's run follows the human system's run up to its first disagreement, whose input occurs in a run answered by a member; so the sum over the audited runs of Pr[the run is unfaithful] is at most L·K/log₂(1/γ); and (u/(u − log₂u) + ln 2) ≤ 2.7 for u ≥ 4. Correct as printed.
* **"Random questions cannot match this" (line 220).** Statements read; arithmetic recomputed (0.1/ln 2 is 1/6.9). The proof of Proposition 3.7 was not checked; the short proof of Proposition 3.10 was read and is correct (the factor is 16/(1 − 10δ)).
* **N5.** Read Proposition 5.6(b) of the proof file; correct. It is N2 with g in the place of L, and the tolerance is immediate (k + 1 agreeing answers of which at most k are replaced contain a true one). Finding F10.
* **N6 (Section 4.5).** Read Theorems 6.1 and 6.3 of `proofs/lower-bounds.md`; the arithmetic of both consequences is correct, and the two-point step is the one of Theorem 9.2, which I checked. Lemma 6.2 (two coins) was checked numerically only (script, D16).
* **N2d.** Own argument for (a), (b), (c) and the two consequences ("F < 1/4 − δ", "breaks even"). Ranges: finding F8.

### 3.4 Sections 5 and 6

* **R4.** The note prints an idea. Own completion for a class of functions: fix (z, ρ), let a_j be the posterior mass of the hypotheses whose first error on the human system's run is at call j, and u = Σ a_j. The asked call lies on the common part of the two runs with probability at least (1/L)·(1 − Σ_{i<j} a_i) for each j, and removes mass at least a_j; and Σ_j a_j·(1 − Σ_{i<j} a_i) ≥ u − u²·(L − 1)/(2L) ≥ u·(L + 1)/(2L). So the question removes mass at least u·(L + 1)/(2L²) in expectation, and −ln(1 − e) ≥ e sums to at most K ln 2. The same computation goes through when the hypotheses are samplers that answer each call with fresh coins: let a_j be the posterior probability that the drawn hypothesis gives its first wrong answer at call j of the human system's run; the mixture is then wrong at that call with probability at least a_j. Script: exact enumeration on 60 random classes of functions (largest ratio to the bound 0.71), and the inequality of the idea in every reachable posterior. The sharpness claim (Proposition 2.5): not checked.
* **Example after R4.** Own argument and script: on a question not asked before the posterior is ½ human, ½ functions, and the total variation is exactly (3/2)·ε(1 − ε). Proposition 3.2: not checked.
* **R5.** The statements agree with Propositions 4.2 and 4.3 of the proof file, which I read. For (a) I recomputed the constants of the proof (½·0.989^100 ≥ 0.165; 0.165·0.95·¾ ≥ 0.117) and simulated the rehearsal (script: between 0.20 and 0.26 times L/n, against the claimed 0.11). For (b) I checked the arithmetic of the proof ((15/32)·(9/32) ≥ 1/8). Proposition 4.6 ((9/32)·L/n): not checked.
* **R6.** (a): own argument (a wrong driver is refuted with probability at least 1/L in each failed run, and at most 2^K − 1 members other than f are at least as heavy as f); script: exact on 60 random classes, and exactly L² on the path scaffold with L + 1 functions. (b): the proof was not read; the exact enumeration on 60 random classes never produced the bad event, so that test is not sharp. (c): I read the proof of Theorem 3.8 of `proofs/one-mind.md` line by line. Step 1 (a supermartingale for each member), Step 2 (Π₂(A) ≤ min(1, S²) ≤ S with E S ≤ δ), Step 3 (the mixture's own supermartingale), Step 4 (H² is the square of a metric, and L4(a) with the mixture in the first place) and Step 5 (16 + 12 = 28, 16 + 24 = 40) are correct. So R6(c) has now been checked by one person other than its author.
* **H1.** Own argument (regret bound for runs, convexity, Pinsker, and KL ≥ −ln(1 − Q̂(G)) when Q_P(G) = 0). Correct as printed.
* **"The per-call mixture fails here".** Own argument and script: the exact divergence is at least 1.49·L/(8N) on the grid. Correct. The last two sentences of the paragraph: not checked.
* **H2.** Own completion of the printed sketch: the posterior weight of ν is at most the s-th power of its odds against P; E_P[(Q_ν/Q_P)^s] ≤ (1 − H²)^(2·min(s, 1−s)) per run by Hölder; Σ_ν w(ν)^(λs) ≤ 1 for λs ≥ 1. The consequence for λ = 2, s = ½ is arithmetic. Correct as printed. Script: the Hölder step on 20000 random pairs.
* **"At λ = 1 the statement fails".** Own argument: equal posterior weights until an input repeats; no repeat with probability at least ½ for N ≤ 2^(d/2) (script, d ≤ 25); H² = 1 − 1/√2. The two forms "in expectation" after Zhang: not checked.
* **S4, S1(a).** The printed proofs are complete and correct.
* **S1(b).** Own argument: for samplers C_u, C_t, ∫ TV(P, C_u) dd_{C_t} ≤ L·β(C_u) + (L − 1)·β(C_t) (two runs coincide up to the first unfaithful call, and at most L − 1 calls follow); average over u = T and t. Script: 300 random cases. The example: I read Example 2.2 and recomputed 0.4975, B = 1.005, 0.0463 and L/(2 ln L) = 10.86 (the actual ratio is 10.75).
* **S3.** Upper bound: S1(a) with B = 1/p. Lower bound and the last remark: not checked.
* **N3.** Own argument for both directions (R_i(0) + R′_i(1) ≤ 1 + γ_i and Σ γ_i ≤ n; a random set of 2aN regions and a coin elsewhere). The sentence on description lengths and Theorem 4.3: not checked.
* **"What S2 needs".** Domination and Σ_p 2^(−2|p|−1) = 1: correct. The statements on what can be sampled: not checked.
* **S5.** Own argument (the coin is independent of x_t and of M^(t)). "within the factor 2 ln 2": read Example 3.2(ii) (K(1 − q)/(2q) expected errors).
* **N7.** (a): I read the proof of Theorem 3.3(a) of `proofs/shift-abstain.md` (Steps 0 to 4) and found it correct: along the path on which every answer is 1 the learner's questions cut the thresholds into at most Q + 1 blocks; a block of b thresholds costs at least ⌊b²/4⌋ mistakes summed over its members; and Σ b_j² ≥ N²/(Q + 1). Script: by dynamic programming the least E[Sil + Abs] with at most Q questions satisfies the inequality for every N from 2 to 40 and N = 48, 64, 96 and every Q ≤ N/2 − 1; the least value of E[Sil + Abs]·(Q + 1)/N found is 0.222 against 3/16; for N = 48, Q = 3 the optimum is 216/48, the value that the proof file quotes. "a learner attains less than N/2" means E[Sil + Abs]·(Q + 1) < N/2; confirmed by the same computation. (b): own argument (at most ⌊2^b⌋ hypotheses are kept and each question removes one). The paragraph after the theorem: finding F30.

### 3.5 Sections 7 to 9

* **Ab1.** The printed proof is complete and correct. Script: 400 random classes (largest ratio to K 0.996), and "never wrong at any input if η < w(f)". "examples attain both": finding F34.
* **Ab2.** (a): own argument from the printed idea (keep the human's answer with probability min/P ≤ 1). (b): own argument (the posterior weight of P is w(P) over a supermartingale that starts at most at 1; Ville). (c): own argument for both directions, without tracking the constants c. If Q is a decidable set of sep(x; A) bits that contains x and no asked input, the two patches of the heaviest consistent hypothesis that give two different fixed answers on Q fit the data as well as it does, weigh at least 2^(−sep(x; A)−c) times as much, and have disjoint answer laws at x; so both are in the ratio set and the minimum is 0 for every answer. In the other direction, a member of the ratio set that differs from f at x gives the separating set {g ≠ f} of at most K + K_D + log₂(1/α) + c bits. (d): not checked.
* **Ab3.** The printed proof is complete and correct once sep is defined (finding F4).
* **N4.** Own argument (it is N1 for functions with γ = 0).
* **Ab4.** Row 1: own argument (Ab1(a) over the asked rounds; an unaudited wrong round is (1 − q)/q times as likely as an audited one). Row 2: N7(b) and N4. Row 3: read Proposition 4.6 of `proofs/shift-abstain.md` (induction with F(k, m) = F(k, m − 1) + F(k − 1, m − 1) + 1); correct. Row 4: read Theorem 4.5 there; correct, for the class of N2 with (1 − a)·L/(2σ) cells. Example 4.5a: not checked.
* **Rocks and whitelists.** The rows for enumeration, Min and Nov follow from two facts: a hypothesis patched on a set of s bits costs s + c more bits, and the set where two programs of at most b bits differ has at most 2b + c bits. The row for Thr_η and the sentence "the mixture errs at each with probability at least 2^(−r−c)" follow from the first fact in the same way (every consistent hypothesis has a patched twin of at least 2^(−sep−c) times its weight that answers otherwise at x); I did not track the constants. Proposition 7.5 was not checked.
* **Section 7.5.** First sentence after "Dominance": finding F31. The counts with the divergence between coins are correct, by own argument: at a wrong round the mixture gives the preferred answer at most η and the human gives it at least 1 − ε₀, so the round has divergence at least kl(1 − ε₀ ‖ η); at an abstention round, at least kl(ε₀ ‖ η); and the divergences at the asked rounds sum to at most K ln 2 in expectation. Last sentence: own argument: against a uniformly random function every answer at a new input is wrong with probability ½, and the coin produces the same data; so (N − E Abs)/2 ≤ (N + 1)/4 gives E Abs ≥ (N − 1)/2.
* **Pr1.** Correct.
* **Pr3.** The printed proof is complete and correct. Script: exact binomial sums (largest ratio to 2e^(−Na) 0.82).
* **"The coin", "The same question twice".** Own argument (Hoeffding over the u independent values of a random function). Correct.
* **Pr4.** The note prints an idea. Own proof: the right side does not depend on the data, so it suffices to prove the bound for the ν* that minimises it. Two families of one-sided events, Q(A_ν*ν′) − Q̂(A_ν*ν′) ≤ r(ν′) and Q̂(A_ν′ν*) − Q(A_ν′ν*) ≤ r(ν′) for all ν′, each fail with probability at most Σ_ν′ w(ν′)·δ/2. On them the score of ν* is at most r(ν*) + TV(Q_ν*, Q), and TV(Q_ν̂, Q_ν*) ≤ score(ν̂) + r(ν*) + TV(Q_ν*, Q); together TV(Q_ν̂, Q) ≤ 3·TV(Q_ν*, Q) + 2r(ν*), and 2r(ν*) is the printed square root. A minimiser of the score exists because the score is at least r(ν). Correct as printed. Script: simulation of the estimate (failure rate 0 in 12 random cases; 0.003 against δ = 0.1 for two hypotheses at distance 2.04·r). "at distance at least √2 − 1": confirmed numerically for samplers with one or two answer laws.
* **Pr5.** The note prints an idea. Own proof: with u(B) := ½·G_V(S) + (½ if V = 0; 2^(V−2) if V ≥ 1 and all increments had one sign; 0 otherwise), a round changes u(B) by at most c_t(B)·g_t(B): for the first half this is ½·(G_{V+1}(S+1) + G_{V+1}(S−1)) ≤ G_V(S), which holds because G_V(S) is the mean over a standard normal θ of exp(θS − θ²V/2) and cosh θ ≤ e^(θ²/2); for the second half it is an equality or a drop to 0. Since the rule minimises the score and the human's answer is one of the candidates, Σ_B π(B)·u(B) never grows, so u(B) ≤ 1/π(B); (i) follows from the first half with 2 ln 2 ≤ 1.39, (ii) from 2^(V−2) ≤ 1/π(B). The sum converges absolutely because G_{V+1}(S ± 1) ≤ e·G_V(S) for |S| ≤ V. Correct as printed; wording: finding F18. Script: Rule NH as printed, 135 games of 300 rounds against random, greedy and "never in B" humans, and exhaustively all sequences of 7 rounds (2 questions, 2 answers, 3 tests, 6 families) and of 9 rounds (one test of weight 1): no violation of (i) or (ii), and the weighted potential never increased.
* **Lower bounds after Pr5.** "r answers": own argument (the human who answers the opposite of the rule on r questions; script). The others ((√2 − 1)·√n; Proposition 3.9; Examples 2.3 and 2.5): not checked. "One rate": own proof (the potential Σ π(B)·cosh(η·S(B)) grows by at most the factor cosh η); script.
* **Pr6.** The printed proof is complete and correct; a round that asks nothing leaves every book unchanged, and the bounds of Pr5 increase with n.
* **Section 8.5.** "wrong in every round", "answers twice alike": own argument and script. "(1 − p)/2 at each of the first (K − 1)/log₂(A/p) new questions": own argument, for the class that consists of the human with weight 2^(−K) and the tables with total weight ½ and nothing else (this is the class of Proposition 8.1 of the proof file; the note's words "give half its weight to tables" leave the rest open). Theorem 7.6, Propositions 6.7, 4.2, 4.4: not checked.
* **Pr2.** (a): own proof (Σ_ν w(ν)·ν^R(D) ≤ C_R·ξ(D); Jensen for the ln C_R; the same inequality summed over the abiding answers at a new input gives the 1/C_R). The value of C_R for all programs: not checked, as the note says. (b): own derivation of the closed form, and enumeration of all memorisers for u = 5, 6, 7 (script, part A); "above 0.51": ¾·(10/11)·¾ = 0.5114 in the worst case, and on the whole grid; finding F14. "What holds": own proof (the process Σ_ν w(ν)·(ν(D_n)/P(D_n))·(1 − v_ν)^(−n) is a supermartingale; Ville; then Jensen for v ↦ (1 − v)^(−n) under the posterior); the second sentence is R1 with KL ≥ −ln(1 − violation probability). (c): not checked.
* **Pr7.** (a): own argument. (b), which the note marks "not independently checked": for one input I computed the total variation between m answers of the two humans exactly, in rationals, for s ≤ 50 and m ≤ 8; it is at most 0.67·m²/(2s). For several inputs the bounds add. The collision statistic: correct. Proposition 6.4: not checked.
* **Section 9.1.** All numbers recomputed (Section 5 below). **N8:** read Theorem 6.1 of `proofs/assumptions.md`; it is the argument of N2b with cells for inputs, and correct; "2g·K ln 2/δ + 1" is R3 with L/(k + 1) < 2g. Additive work: own argument (half of the calls at unasked inputs are wrong; at most k + δL may be), which gives (1 − 2k/L − 2δ)·K.
* **I1.** No argument is printed. Own proof: let W be the prior mass of the surviving members whose runs differ from the human's. If the driver's run is the human's, each such g is refuted with probability at least δ/L. If the driver ν is itself such a member, then for every pair (ν, g) of them, on every (z, ρ) on which one of the two errs, the question at the earlier first error refutes g when ν drives or ν when g drives; so the mass removed, averaged over the driver, is at least W·δ/(2L). Hence E W_n ≤ (1 − δ/(2L))^n, and the posterior weight is at most W_n/w(f). Correct as printed. Script: exact on 59 random instances.
* **E1.** First claim: own sketch (it is R1 with the episode as the unit: up to its first deviation the imitator's episode has the human's visible history, so the mixture gives the human's transcript of the asked episode a probability of at most 1 minus the probability that its own episode is unfaithful). The claims about R3, V1(a) and Theorem 1.9: not checked. **E2:** own argument (as for the caveat on A2, with P_t in the place of P). Corollary 1.12 and Proposition 1.14: not checked.
* **Sections 9.4, 9.5, 10.** Not checked beyond consistency with the statements they cite. The list in 9.5 has seven items, as it says.

## 4. Upper bounds against lower bounds

Each row was evaluated on a grid in the stated ranges (script, part B). "Ratio" is the least value of upper/lower found where the lower bound is positive.

| quantity | upper bound | lower bound | result |
|---|---|---|---|
| questions for failure δ, class of N2 | R1: L·K ln 2/δ, K = log₂(N + 1); also ⌈N/2⌉ ("a random half") | N2: N − δ(N + L)/p, hence L/(4δ) − 3L/2 (and − L in the integer case) | consistent; ratio 8.3 for R1; the random half is within 3L/2 + 1 questions of the bound |
| the same, a protocol that sees z | L (ask the calls) | N2a: L·(1 − √(2δ) − δ) − δ | consistent |
| questions for failure δ, class of N2b | ⌈d/2⌉·(L/(4δ) + ½); R1: L·K ln 2/δ; N2c: 1 + 2.7·K·L/(δ·log₂(L/δ)); Prop. 3.10: 2dL/δ | N2b: (1 − 10δ)·d·L/(8δ) | consistent; ratios 1.000, 32, 20, 16 |
| low stakes, class of N5 | R3: L·K ln 2/((k + 1)·δ) | N5: (1 − 4δ)·(L − k)/(4(k + 1)δ) | consistent; ratio 12 |
| low stakes, class of N8 | R3: 2g·K ln 2/δ + 1 | N8: (1 − 10δ)·K·g/(8δ·log₂(g/(2δ))) | consistent; ratio 70 |
| additive work | K (ask every input); R3: L·K ln 2/((k + 1)δ) | (1 − 2k/L − 2δ)·K | consistent |
| questions for total variation ε, one call | R2: K ln 2/(2ε²) | N6: K/(512ε²) | consistent; ratio 177 |
| the same, runs of L calls | R2: (1 + ε)·L·K ln 2/ε² | N6: L·K/(8192ε²) (Section 4.5); L·K/(8·10⁴ε²) (Section 3.2); two samplers L/(740ε²) | consistent; ratios 5.7·10³ and 5.5·10⁴ |
| recorded runs for total variation ε | H1: K ln 2/(2ε²) runs | N6: K/(8192ε²) runs | consistent |
| unfaithful calls, human who varies | L·√(K ln 2/(2n)) = 0.589·L·√(K/n) | 0.088·L·√(K/n) (n ≥ K/2) | consistent; ratio 6.7 |
| low stakes, human who varies | failure δ + √(K ln 2/(2n))/θ | failure γ needs K(1 − 2γ)²/(32θ²) | consistent: at that n the upper bound is 3.3/(1 − 2γ) > γ |
| amplification r·L/n | (a) 4F/(1 − 4δ); (b) 8F·log₂(L/(2δ))/((1 − 10δ)K) | (c) F/(K ln 2 + δ/L) | (c) ≤ (a) and (c) ≤ (b) on their classes |
| a property of tasks | S3: L·K ln 2/(p·δ) | (L/(4δ) − L)/p | consistent |
| N shifts | 2aN questions suffice | N3: 2aN | equal |
| open system, questions against errors | S5: (1 − q)·K ln 2/q errors with questions at rate q | N7(a): E[Sil + Abs]·(Q + 1) ≥ 3N/16 | consistent for the learner that asks at rate q until Q questions are used and then abstains (288 cases); also with the form for expected questions of the proof file |
| the same with Thr_η and audits (Ab4, row 1) | E[Sil] ≤ ((1 − q)/q)·K/log₂(1/η), at most K ln 2/η abstentions | N7(a) | consistent, same construction |
| no silent error (Ab4, row 2) | N7(b): 2^b − 1 questions, b ≥ K | N4: every new input, 2^d for the point functions | consistent (b = d + 1) |
| leaving an open system, as restated in Section 0 (line 24) and Section 6.2 (line 372) | N7(b): 2^K − 1 questions, no error | "at least 3·2^K/16" for the product without a range; "not before about 3·2^K/(16j)" | not consistent as printed: the product is 0 at 2^K − 1 questions, and 3·2^K/(16j) > 2^K − 1 for j < 3/16 (F37, F30). With the range Q ≤ 2^(K−1) − 1 of N7(a) they are consistent. |
| at most k wrong, all answers shown (Ab4, row 3) | Ab1(a): K/log₂(1/(1 − 2^(−K/(k+1)))) ≤ K ln 2·2^(K/(k+1)) | (k + 1)·2^(K/(k+1))/e − k − 1 | consistent; ratio 8 |
| closed system with aborts (Ab4, row 4) | Ab1(b): n ≥ max{L·K/(σ·log₂(1/η)), L·K ln 2/(a·η)}, best η | (1 − a)²·L/(4σ) − L | consistent; ratio 8 |
| a test under Rule NH | Pr5(i): √((n + 1)(2Λ + 1.39 + ln(n + 1))) | (√2 − 1)·√n for √n tests | consistent |
| a never-satisfied test | Pr5(ii): log₂(1/π) + 2 | r for 2^r tests of weight 2^(−r) | consistent (r against r + 2) |
| the one-rate rule | √n·(ln(2/π) + ½) | ½·√n·ln n for a test of weight 1/(2n) | consistent |
| one draw per run | R4: 2L²·K ln 2/((L + 1)n); R6(b) | R5(a): 0.11·L/n; R5(b): L/(8n) | consistent |
| driver = heaviest consistent | R6(a): L·(2^K − 1) | exactly L² for L + 1 functions | equal |
| L4(a), best constant | 4; 2.9642 | 2.9639 (not recomputed); 2.0997 and 1.707 (recomputed) | consistent |
| S1(b), factor | 2L − 1 | L/2 | consistent |
| one T kept for good | 1/δ (Markov) | 0.45/δ for δ ≤ 0.63 | consistent |
| S5, wrong answers | (1 − q)·K ln 2/q | K(1 − q)/(2q) in the example | factor 2 ln 2 |
| Pr2 | "What holds": (K ln 2 + ln(1/δ))/n | (b): above 0.51 for n ≤ (K − 2)/log₂(4u + 2) | consistent: the upper bound exceeds 1 in that range |

## 5. Worked numbers and "within a factor" sentences

All recomputed by the script, part A, unless marked.

| place | sentence | recomputed |
|---|---|---|
| 3.1 | "0.1 unfaithful calls per run cost 350 years already for K = 10⁴" | 6.93·10⁵ hours = 347 years of 2000 hours. The unit is the working year of 9.1; in calendar years it is 79. |
| 3.1 | "a factor 0.45/δ is needed" | 0.454/δ |
| 3.4 | "399 … 0.0007 … 0.021" | 0.00074; 0.0207 |
| 3.4 | "0.088" | 1/(8√2) = 0.0884 |
| 3.5 | "300 rounds certify an excess failure 0.1 under θ = 0.1 at δ = 0.05" | 0.0999; 300 is the least such m |
| 4.2 | "the factor 4·K ln 2 is left" | exact |
| 4.3 | "2.7"; "a seventh" | 2.693 at L/ε = 16; ln 2/0.1 = 6.93 |
| 4.6 | "F < 1/4 − δ"; "millions of failed runs" | exact; 7.2·10⁶ for L = 1000, δ = 0.01, K = 10⁹ |
| 1 | "refuted with probability 0.44" | 0.4435 |
| 5.1 | "(3/2)·ε(1 − ε)" | exact |
| 5.2 | "at least L/(8N), against ln 2/N" | exact divergence ≥ 1.49·L/(8N) |
| 5.2 | "H² = 0.29"; "at least ¼ for all N ≤ 2^(d/2)" | 0.2929; confirmed for d ≤ 25 |
| 5.2 | "the same bound … and twice it otherwise" | exact |
| 6.1 | "0.4975 … 0.0463 … L/(2 ln L)" | 0.49749; 0.04628; 10.86 (actual ratio 10.75) |
| 6.1 | "π_p = 2^(−2|p|−1)" | sums to 1 |
| 6.2 | "within the factor 2 ln 2" | 1.386 |
| 7.5 | "(N + 1)/4 … (N − 1)/2" | exact |
| 8.3 | "√2 − 1 … 3·(√2 − 1) > 1" | 0.41421; 1.243 |
| 8.4 | "K + 3", "log₂ n + 3", "√n·(ln(2/π(B)) + 1/2)" | exact |
| 8.6 | "0.71, 0.18, 0.11" | (4/5)(8/9), (1/5)(8/9), 1/9; the class itself was not re-enumerated |
| 8.6 | the formula of Pr2(b); "above 0.51" | exact; lowest value on the grid 0.58, worst case of the proof 0.5114 |
| 9.1 | "1443", "0.72", "2.9·10⁷"; "3.5·10⁷ working years"; "300 years" | 1442.7; 0.721; 2.885·10⁷; 3.47·10⁷; 300 answers |
| 0 | "about 1.4·10³ bits"; "less than one bit" | 1443; 0.72 |
| 3.2, 13 | "2.9642" | c* = 2.964147 |
| 12 | "2.9641" | finding F2 |
| 13 | "about 10⁴ away" | 177 (one call), 5.7·10³ and 5.5·10⁴ (runs) |
| 11 | "1117 functions", "K = 3.78" | 1 + 2 + 90 + 1024; 3.778 |
| 11 | "0.59 … 0.30 … 0.07" | 0.594, 0.297, 0.074 (posterior after all 16 pairs below 4) |
| 11 | bounds "7.9, 39.3, 165.0", "11.8, 73.7, 325", "6, 30, 126" | 7.86, 39.28, 164.98; 11.78, 73.65, 324.81; two functions are heavier than f (the bound L·(2^K − 1) of R6(a) as printed would be 38, 191, 801; see F39) |
| 11 | "0.82%"; "ln(20)/1000 = 0.003"; "48%"; "0.024" | 0.818%; 0.00300; 0.9⁷ = 0.478; 0.0241 |
| 11 | every simulated number (35%, 98%, 100%; the table; 1.6, 15.4, 22.3; 3.3, 21.1, 27.2; 0.1%, 1.2%, 11.9%; 0.11%, 0.03%, 0.03%; 140 of 160; 0.00014; 0.90; 0.0003; 62%; 57%) | agrees with `results/toy.out`, `results/toy_stakes.out`, `results/toy_property.out` and `proofs/code/property-online_rehearsal.out`. The simulations were not re-run. |

## 6. Edge cases

* **L = 1.** R1, R7, R2: nothing special. R4: the constant 2L²/(L + 1) is 1, the constant of R1, as it must be (one call per run). S1(b): the factor 2L − 1 is 1. N2 at L = 1, δ = 1/6 (N = 3): the three lower bounds are 0, 0.5 and 1; a mixture of one and two questions reaches failure 1/6 with 1.5 questions in expectation. N5 with g = 1 needs no cut-off (L = 2k + 1).
* **n = 1.** R1: the bound L·K ln 2 for the prior mixture is correct (each call has divergence at most ln(1/w(P))); included in the enumeration. R7: the bound L/n is at least 1. R4 with n = 1 and L = 1: Pr[the prior draw errs] ≤ 1 − w(f) ≤ ln(1/w(f)). H1 with N = 1: the same. Pr4 with small N: the bound exceeds 1.
* **K = 0 and K < 1.** K = 0 means H = {P}; all bounds of Section 3 are 0 and correct (one-member classes are in the enumeration). K < 1: R6(a) gives fewer than one failed run times L, correct because no other member is as heavy as f. Ab1 with K < log₂(1/η): u = 0. The lower bounds have K ≥ 1 by construction.
* **δ at the ends.** N2 at δ = 1/6: correct; the bound L/(4δ) − 3L/2 is then 0. N2d: finding F8. N2b at δ = 1/20 and N8 as δ → 1/10: the bounds tend to half their size and to 0; no error. The hypotheses "δ ≤ 1/20" of N2b and "δ < 1/10" of N8 differ although the proof is the same; both are correct, because the lower bound holds for every δ. V1(a) with m ≤ ln(1/δ): the certified bound is at least L, true and empty. H2 at ε = 1: the bound is 0, correct (a singular hypothesis has likelihood 0 after one run). Theorem 9.2: finding F3. Ab1 needs η < ½ strictly; at η = ½ two answers can both reach 1 − η.
* **Runs with no call, or with fewer than L calls.** R1, R7, V1, Pr6, Ab1(b) and S4(i) are correct for such runs, because the asked index is uniform on {1, …, L} and a round with J beyond the end of the run asks nothing; the printed proofs say so. V1(b): finding F24. R3a needs "exactly L calls", as the note says. N5: finding F10 (runs can be longer than L without a cut-off).
* **A human with one possible answer.** Then the human is deterministic; V1(a) has s = 0, the certificate can be issued, and Pr5 has g_t = 0 if Y has one element. Nothing fails. If hypotheses may give no answer, the mixture has two possible answers; the statements cover this.
* **N7(a) at N = 2 and N = 3.** Q = 0 is the only admissible value; the optimum of E[Sil + Abs] is ½ and ⅔, above 3N/16.
* **Pr5(ii) at π(B) = 1.** The bound is 2 rounds. One round is the most that can occur: after one round with the imitator's answer in B and the human's outside, the slope of B is positive, and the rule avoids B wherever an answer outside B exists. The exhaustive search over all sequences of 9 rounds found no violation.

## 7. Definitions

Defined in the note and used in the sense defined: sampler, hypothesis, mixture, K, scaffold, horizon, run, call, answerer, Q_A, human system, unfaithful call and β(A), A1 to A3, closed deployment (C1 to C3), tolerates k faults with failure δ, frozen (in "Validate"), protocol and fails (Section 4), amplification, committee and member, visit measure, abstain, aborted, silent error, Thr_η, Min_𝒞, top set and ratio set, K_D, Nov_s, enumeration, Sil and Abs, price Λ(B), kl, book, slope, memoriser, ν^R and C_R, separated and isolated.

* **test.** Defined three times: a set of pairs (V1(b), Section 8.4, Section 0) and a set of runs (Section 8.2, "a set of pairs (x, y), for a one-call scaffold"). Each section says which, and each statement uses its own. No error.
* **top set.** "at least α times the total weight of those ranked no lower" is a prefix of the ranking (if a member qualifies, every heavier one does), it has at most 1/α members, and it is contained in the ratio set. Correct.
* **tolerates k faults.** The rule may see z, ρ and the human's answer. R3 uses exactly this class of rules, and the remark after R3 (blind replacement) shows that a smaller class would not do. N5, N8 and R5 use the definition with failure 0; R5 omits the words "with failure 0".
* **closed deployment.** Defined. "closed system" (Sections 3.6, 6, 7, 8.5, 10, 11) is used for a scaffold in a closed deployment and is not defined separately.
* **Not defined:** sep(x; A), K(Q), K(R) (finding F4); the squared Hellinger distance (finding F6); Protocol R, Theorem A, Theorem B, Rule Ab2, S2, needle class, outcome, unfaithful run, Paper 1, Paper 2 (finding F16).
* **Half defined:** episode (caveat on A1 and E1: "reset between episodes and remembers inside them"); driver (R6(a), from the context); trap (R5).
* **Symbols with two meanings:** finding F25. K(ν) := log₂(1/w(ν)) in Section 8.3 against K(Q) as complexity in Sections 4.1 and 8.6; Γ is a number in Ab2(d) and a set of tasks in S3; β is the number of unfaithful calls, "a bound β" in the paragraph on S2 and the strength of the tilt in Section 8.5.

## 8. Not checked

The following statements of the note were not verified by me. For each, the note gives a statement and a reference to a proof file, and no proof.

* Section 1: Examples 3.3a and 3.6, Remark 1.1a, Proposition 1.15.
* Section 3: integrability in R1 (Lemma 4.1); Propositions 5.3 and 5.5(b) (the factor L/4); the proof of Proposition 6.2 for general L and n (checked by exact computation for seven pairs); the proof of Theorem 2.7 (the constant 2.9642) and Example 2.8(ii) (the constant 2.9639); Proposition 13.4; the two-coin lemmas behind N6 beyond a numerical check.
* Section 4: the constants of the remark on all programs (Proposition 1.8); the proof of Proposition 3.7.
* Section 5: the sharpness of R4 (Proposition 2.5); Propositions 3.2, 3.5, 4.6; Example 3.6; the proof of R6(b); the two forms of H2 in expectation; the last two sentences of the paragraph on the per-call mixture.
* Section 6: the lower bound of S3; the complexity remark and Theorem 4.3 after N3; what can be sampled ("What S2 needs").
* Section 7: the constants c of Ab2(c) and of the table of Section 7.4; Ab2(d); Example 4.5a; Proposition 7.5 (and with it the sentence "The second column is forced", which the section source now restricts to rows 1, 2 and 4); the comparison with Cohen, Hutter and Nanda.
* Section 8: the lower bound (√2 − 1)·√n, Proposition 3.9, Examples 2.3 and 2.5; Theorem 7.6; Propositions 6.7, 4.2, 4.4 of `proofs/property-online.md`; the value of C_R for all programs; the example with C_R = 5 beyond its arithmetic; Pr2(c); Proposition 6.4 of `proofs/property-batch.md`.
* Section 9: Propositions 6.3, 6.5, 7.1, 7.5, 7.8 to 7.10; E1 beyond a sketch of its first claim; Corollary 1.12; Proposition 1.14.
* Section 10: the verdicts, beyond their agreement with the statements they cite.
* Section 11: the simulations were not re-run.
* Section 12: every statement about the literature. I read no source in this session.

## 9. The state of the section sources

The printed note was assembled at 03:11. By 04:19 four section sources had been edited again (`rehearsal-core.md`, `hellinger-runs.md`, `shift-abstain.md`, `property-batch.md`), Section 12 and the references had been rewritten in two new files, and `patches.py` was unchanged. The other sources (`intro.md`, `lower-bounds.md`, `one-mind.md`, `property-online.md`, `assumptions.md`, `open.md`, `toy.md`) were as printed. I assembled the sources of 04:19 into a scratch copy; I changed no source and did not touch `note.md`.

| finding | in the sources of 04:19 |
|---|---|
| F2 (2.9641), F3 (range n ≥ K/2), F7 (label N6 in 3.2), F14 (total weight in Pr2(b)) | corrected, in the sense of my correction |
| F16: "Theorem A", "Theorem B", "Rule Ab2"; the needle class; "Paper 1", "Paper 2" | corrected (Section 12 rewritten; the class now has "(1 − a)·L/(2σ) an integer"; the references name both papers) |
| F16: "Protocol R", "S2", "outcome", "unfaithful run" | unchanged |
| F25 | the σ of R3a is renamed ζ; ρ and s in V1(a) are unchanged |
| F29 to F36 | corrected; that is how I found them |
| F37 | the table row is corrected; the bullet of Section 0 is unchanged |
| F1, F4, F5, F6, F8, F9, F10, F11, F12, F13, F15, F17 to F24, F26, F27, F28, F38, F39 | unchanged |

F12 and F17 are in text that `patches.py` supplies (the paragraph "Compute" and R2(b)), so their corrections belong there.

## 10. Files

* `verification/referee-math.md`: this report.
* `verification/code/referee-math_checks.py`: the script (Python 3 with numpy; it imports `code/toy.py` and `code/toy_property.py` to recompute K, the weights and the bound of one test, and reads the saved outputs in `results/`). Parts A to D test the note; part E demonstrates F29 to F31, F34 and F37.
* `verification/code/referee-math_checks.out`: its output; 137 tests passed, none failed, 14 defects shown.
