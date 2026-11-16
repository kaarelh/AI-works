# Referee report: the note read by the reader for whom it is written

Role: the researcher who asked the question. He is mathematically trained, at home with Solomonoff induction and regret bounds, not with the imitation-learning literature, sceptical, and reads the note cold.

Object: `note.md` as generated on 16 November 2026 at 03:11 (719 lines, about 20,000 words). Line numbers below refer to that file; the 99 sentences quoted from it in Parts D to I were compared with the file by a script and all occur in it word for word. The note is generated; every proposed change names the section source in `research/sections/` that has to be edited.

How this file was written. Part A is the log of the first, cold reading and was written before any other file of the project was opened. Parts B to J were written afterwards. The graded findings F1 to F34 are listed in Part J; their full text, with the exact sentences and the replacements, is in Parts D to I.

## Summary

The note answers the question honestly. Its theorems are stated with their hypotheses, what is standard is called standard, and it says with numbers, in his own manner, that every bound on imitation is empty for a person. Read cold, Sections 2, 3.1 and 3.3 to 3.5 can be followed without the proof files; Sections 0, 4.3, 7 and 8.6 cannot.

Six findings are major. All can be repaired in the section sources; F4 may also need new mathematics. Together the replacements proposed for Section 0 add about 700 words to it; if that is too long, answers 2 and 3 can be shortened, since Sections 3.3 to 3.5 repeat their content.

* F1. Section 0 presents the imitator built from tests (Pr5) as if it worked on any sequence of questions without the human; in Pr5 the human answers every question.
* F2. Section 0 says that one program in the place of the mixture is impossible for a human who varies; R6(c) proves the contrary. The answer on "mind upload or clever predictor" is half a sentence, although the sections show that his own steeper prior does what he hoped (H2, R6(c)).
* F3. On "fails only obviously" Section 0 has one sentence, which cannot be read cold; the plain verdict stands in Section 10.
* F4. On the same question the note asks for rules that are never silently wrong, which is more than he asked, and sets aside in one sentence the published theorem of the kind he asked for (a small rate of silent errors on arbitrary inputs, at polynomial cost).
* F5. "The human reads what the prior wrote", which the note itself calls fatal and which is a failure of the kind he calls insane (harm to the reader), is stated once, in one line of a list, in Section 9.5.
* F6. The "faster route" of Section 0 (I1) keeps the factor K, and the note does not say so.

Of the 28 further findings, the ones that matter most to this reader are: the bottom line comes in the seventh answer and the bets are never listed (F7); two headings and two summary sentences of Section 0 say more than their sections (F8 to F11); the guard, S4(i), S5 and N2d are missing from Section 0 (F9, F11, F12); two attributions to the reader himself are wrong (F14); sep(x; A) is never defined (F17); the verdicts "passed" of tests 1 and 3 say more than he would accept (F27, F28); and there is no list of references (F26).

## Part A. Log of the cold reading (note.md only, first line to last, once, in order)

This log records what I noticed while reading, in the order of the note, before I had seen the researcher's notes, the outline, the proofs or the reports (I had only listed the folders). It is kept as evidence of what a cold reader meets. The graded findings are in Part J.

### A.1 What I could verify from the note alone

I redid the following arguments and numbers on paper while reading. "Verified" means that the step follows from what the note itself states.

* Theorem R1, proof (line 86): the telescoping of the mixture, the conditional mean of the log ratio, the factor 1/L from the uniform index J, the average over T, and KL ≥ e for a deterministic human. Verified. The integrability claim is referred to Lemma 4.1 of the proof file and was not checked.
* Theorem R2 from Lemma L4 (lines 110 to 118): with s = L·K ln 2/(2n), (a) 4s = 2·L·K ln 2/n, (b) 2√s = √(2·L·K ln 2/n), the round count (1 + ε)·L·K ln 2/ε² (solved s + √(s² + 2s) ≤ ε, which gives s ≤ ε²/(2(1 + ε))), (c) 4s and 2s. Verified, given L4 and given the normalisation H² = 1 − Σ√(pq), which the note does not state. Lemma L4 itself was not checked.
* Theorem R7, proof (line 128). Verified.
* Theorem R3, proof (line 138). Verified. The bound L·√(K ln 2/(2n)) for a human who varies (line 144) follows from Pinsker and Cauchy–Schwarz. Verified.
* Theorem V1(a): ρ ≥ β(A)/L, the certificate rule, the inequality 1 − Σ a·p ≤ TV(a, p) + 1 − Σ p², and "issued with probability at most exp(−m·s/2)" (which needs 1 − Σ a·p ≥ (1 − Σ p²)/2; true because 1 − Σ a·p ≥ 1 − max p and 1 − Σ p² ≤ 2(1 − max p)). Verified. V1(b): Hoeffding with range 2 and a union bound over π(B)·δ gives the stated width. Verified. V1(c): verified in outline (the test for ν = P has Δ = β(A)/L).
* Theorem N1, proof (line 186). Verified.
* Theorem N2, proof (line 200): with N = L/(2δ) the display n ≥ N − δ(N + L)/p gives n ≥ L(1 − 4δ)/(4δ(1 − δ)) ≥ L/(4δ) − L. Verified for the integer case. The case with the ceiling was not checked.
* Corollary N2d(c): L·K ln 2/n = F/r gives r·L/n = F/(K ln 2). Verified up to the rounding term δ/L.
* Theorem Ab1 (lines 380 to 386). Verified.
* Proposition Ab3, proof (line 414). Verified, reading sep(x; A) as the least number of bits of a test that contains x and no asked input (the note does not define it).
* Theorem Pr3: the width from the Chernoff bound. Verified in outline.
* Pr5, idea of the proof (line 506): the one-step inequality Σ_B π(B)·c_t(B)·g_t(B) ≤ 0 holds because the human's answer is among the candidates. Verified. The potential calculations behind (i) and (ii) were not checked.
* Pr6, proof (line 524). Verified given Pr5.
* The collision statistic of line 559 has mean Σ_y (P − A)². Verified.
* Section 9.1, table: 10⁵·0.01/ln 2 = 1443; 50·0.01/ln 2 = 0.72; 2·10⁹·0.01/ln 2 = 2.9·10⁷; K = 10⁹ gives 6.9·10¹⁰ answers, 3.5·10⁷ working years of 2000 hours. Verified.
* Section 3.1, "350 years already for K = 10⁴": n = 10·10⁴·ln 2/0.1 = 6.9·10⁵ hours, which is 347 working years of 2000 hours and 79 calendar years. Verified, with the remark that "years" must mean working years.
* Section 3.5, "300 rounds certify an excess failure 0.1 under θ = 0.1 at δ = 0.05": L·ln 20/300 = 0.01·L, divided by θL gives 0.1. Verified.
* N8, "2g·K ln 2/δ + 1 questions suffice": L/(k + 1) = g(2k + 1)/(k + 1) ≤ 2g. Verified.
* Section 11: bounds L·K ln 2 = 7.9, 39.3, 165.0 for K = 3.78; (2L²/(L + 1))·K ln 2 = 11.8, 73.7, 325; K ln 2/(θn) = 0.82% for θ = 0.05, n = 6400; ln 20/1000 = 0.003; 0.9⁷ = 0.478. Verified. The 35% at depth 2 is consistent with a rough count of mine (probability 0.609 that an input of the root call is at least 4, times the posterior weight 0.59, gives 0.36). The computations themselves were not rerun.

Everything else in the note is reported in this file as read, not as checked.

### A.2 Places where I stopped, in the order of the note

Section 0.
* Line 13. "human system's" is used before Section 1 defines the human system. "the class" appears without having been introduced.
* Line 15. "unfaithful calls" is used before its definition (Section 1). "the frequency of each test from a weighted family" is used before "test" is defined (answer 5). I read the last two sentences twice. Coverage (R7) is called a check, but nobody performs it: it is a property of how rehearsal samples.
* Line 23. The bullet on abstention. I read it three times and did not understand it until Section 7.4. "The abstaining rules" have not been introduced, "a parameter that makes their soundness a theorem" names nothing, and "whitelists" is not explained.
* Line 24. "open system" is used before "closed" is defined. The clause "a deterministic human can leave after about 2^K questions" follows a statement about a class of thresholds, which are deterministic already.
* Line 26. The Pr5 sentence reads as a guarantee for an imitator that works without the human. Section 8.4 shows that in Pr5 the human answers every round. "for about K divided by the bits per pair questions" had to be read twice.
* Line 28. The δ in "2L(K ln 2 + ln(1/δ))/n" is not explained. The last sentence ("It is not possible for a human who varies, unless whole runs ... are recorded") is contradicted by R6(c) in Section 5.1.
* Line 30. "Every bound is in K" contradicts answers 2 and 5. "a class without patches" is not explained. "A faster route is a bet" reads as a way round the factor K; Theorem I1 (line 589) still needs n above 2L·K ln 2/δ.
* The fact that the bounds are empty for a person comes in the seventh answer; the first answer opens with "A protocol with a theorem exists".

Section 1.
* Line 38. "only the human's answers to inputs that the scaffold can produce count towards it": read twice; I take it to mean that K may be replaced by the bits of the set of hypotheses that agree with the human on reachable inputs.
* Lines 48 to 54. The caveats on A1 to A3 refer to R1, R3, V1(a), E1 and to "the asked call" before the protocol and the theorems have been stated.
* "the run that counts" (line 44, 46) is used for the deployed run without being introduced.

Section 2.
* Line 64. "Freeze an imitator A": which one is not said (any; in Section 3.5 "however obtained").
* Line 72. "None of this is new." Clear and welcome.

Section 3.
* Line 88. "Paper 1 of this repository": which paper, which folder?
* Line 96. "More questions per run do not improve the bound": per question asked, presumably.
* Line 102. The normalisation of H² is not stated (the proof of R2 uses H² ≤ KL/2, so H² = 1 − Σ√(pq)).
* Line 108. The idea of L4 ("a quadratic function of the root likelihood ratio ... rises by at most a constant times h_j") did not tell me why the claim is true. "have 10²·log n" is not a sentence I could parse at first. "Close runs do not make single calls close, except with a factor L" is unclear.
* Line 122 and line 234. Two different statements carry the label N6, with different constants (L·K/(8·10⁴·ε²) and L·K/(8192·ε²)) and different conditions.
* Line 126. Q is a set of inputs here and the law of a run elsewhere.
* Line 146 to 152. R3a: its purpose (a checkable sufficient condition for tolerance of faults) is not stated. σ and a are reused.
* Line 158. ρ (random bits of the scaffold in Section 1) and s (L·K ln 2/(2n) in R2) are reused with new meanings.
* Line 172. Section 3.6 is the researcher's own suggestion in its online form. It has four lines and is absent from Section 0.

Section 4.
* Line 188. K(Q) (complexity) next to K (bits of the human); "Paper 2"; the sentence about a human "who may answer any string" was read twice and seems dispensable.
* Line 204. "it counts the places they fall on that the class can change one at a time": read twice.
* Line 206. N2a: "a protocol that sees z before asking": what z is in this class is not said.
* Line 218. N2c: "while some input occurring in a run answered by a member has no answer of posterior weight above ...": read three times. "With their number chosen from K": whose number? "AB" is not explained.
* Line 220. Random calls of runs can need about K·L/ε questions where K chosen questions suffice. This qualifies the heading of answer 4 ("In general nothing does better").
* Line 240 to 246. N2d is the clearest statement of the trade-off in the note (amplification at most 4F; rehearsal breaks even once K ln 2 failed runs are allowed). It is not in Section 0.

Section 5.
* Lines 248 and 250. The same heading twice.
* Line 262. The example and "Asking every call of the rehearsal runs does not help" seem to clash: if the same question is put three times and all three answers are recorded, differing answers refute every function. Not resolved from the note.
* Line 264. "traps that answer 1 at one input and at every later call": a hypothesis was a function of the input alone.
* Line 280. R6(c): one program for a human who varies, after rehearsal. This contradicts answer 6 of Section 0.
* Lines 286 to 290. Table: "no gain in the examples", "the same", "no bound" are unclear cells.

Section 6.
* Line 328. "Protocol R" is used for the first time, undefined.
* Line 330. S4(i) is the direct answer to the question about the shift that decomposition produces. Good.
* Line 344. S1(b) and its example: read twice; the reason for the factor 2L − 1 is not conveyed.
* Line 356. "What S2 needs": S2 is never stated.
* Line 362. S5: the researcher's idea in its online form, with a strong and simple bound. Not in Section 0.
* Line 364. Q is now a number of questions.

Section 7.
* Line 376. A is now the set of asked inputs; before it was an answerer.
* Line 392. "at least α times the total weight of those ranked no lower": read twice.
* Line 400 and after. sep(x; A) is used throughout Section 7 and in 9.2 and is never defined.
* Line 402. Γ, S, α, δ in one formula; Γ is a set of tasks in S3.
* Lines 422 to 427. Table of Ab4: the row labels are compressed ("audits at rate q, abstentions answered"; "every answer shown").
* Line 442. "the rocks the researcher rejects", "the whitelists he accepts": neither word is defined in the note.
* Line 647 (Section 10) has the sentence I was looking for here: "Nothing here acts on new inputs, fails only visibly and needs no assumption."

Section 8.
* Lines 454 to 476. Labels change from "What it does not say" to "Not said".
* Line 462. "Langford 2005, quoted from memory".
* Line 470. "The researcher's conflict is thereby confined, not removed": read twice.
* Line 473. The coin example is for all but a fraction δ of all functions, that is, for a typical random function. Section 0 says "a deterministic human".
* Lines 478 to 492. Why the minimum-distance estimate belongs to the property idea is not said.
* Line 496. In Pr5 the human's answer arrives in every round. The setting is online; Section 0 does not say so.
* Line 498. "Rule NH": the name is not explained. σ is a sign here.
* Line 531. "the toy problem of Section 11", "exact root": forward reference.
* Line 532. β is the strength of a tilt here and the expected number of unfaithful calls elsewhere.
* Line 533. A is the number of good answers here.
* Line 537. The attribution of Pr5 (Blackwell's approachability; "We found no published statement of Pr5 in this form") is careful. Section 0 does not say that the method is standard.
* Line 541. "a set of pairs that the human never violates": R is a property that is kept, while a test B in 8.4 is the set that is never entered. Read twice.
* Line 543. Pr2(a): read three times.

Section 9.
* Line 575. Clear. "Landauer ... (1986; from secondary sources)".
* Line 587 to 591. I1: the bound 2^K·(1 − δ/(2L))^n says nothing before n exceeds 2L·K ln 2/δ. The text does not say so. "sep" again. "`ultranatural/note.md`": I do not know this file. "no data decide between the two bets": which two?
* Line 595. "K the weight of that function": K is a number of bits.
* Line 605. Section 9.4 is the whole answer to "mind upload or clever predictor": four sentences. "a better predictor is assumed away, not excluded" needed a second reading.
* Line 616. "the human reads what the prior wrote": one of seven objections called fatal, mentioned here for the first and only time, in one line of a list.
* Line 621. "What survives" is the plain bottom line. It stands at the end of Section 9 and omits the property guarantee.

Section 10. See Part H.

Section 11.
* Line 665. The bound of R6(a) is used as "L times the number of functions heavier than f"; Section 5.1 states it as L·(2^K − 1).
* Line 667. For L = 16 the system with 5% tolerance tolerates no fault (0.05·16 < 1), so its 0.11% is the first system's 0.1%.

Section 12.
* Line 679. "Theorem B" and "Theorem A" are labels that the note does not have.
* Line 681. PQ-learning: "The note has no counterpart." As the reader I want to know why, since it is a positive result on arbitrary test distributions with rejection.
* Line 689. c₀ = 2.9641 here, 2.9642 in Sections 3.2 and 13.

Section 13.
* Line 695. "Every positive result is in K": not R7, V1, Pr5, Pr6.
* Line 695. Open question 1 states the main bet more plainly than Section 0 or Section 9 does.

References.
* Line 719. "(The list is being consolidated.)" There is no list of references.

## Part B. What was read after the cold reading, and what this report rests on

After the cold reading I read, in this order:

* `research/understand/notes.md`: the summary and Sections 1, 2.1 to 2.5, 2.10 to 2.15, 3, 5 and 6. This file is a digest of the researcher's notes. I did not read his notes themselves; every statement below about what he wrote is taken from the digest's quotations.
* `research/outline.md` (all), `research/literature-checks.md` (all), `README.md` and `verification/README.md`.
* Sections 0, 9 and 10 of the note, a second time.
* Single statements of the proof files, to settle doubts from the cold reading: `proofs/assumptions.md`, Section 5 (the seven tests), Proposition 2.4 with its reading, the objections O4, O8, O19 to O22 of Section 8 and the statement of Theorem 7.4; `proofs/rehearsal-core.md`, Remark 4.4; `proofs/one-mind.md`, the summary lines of Example 3.1, Proposition 3.2, Remark 3.7 and Theorem 3.8; `proofs/hellinger-runs.md`, Theorem 2.1 with its proof. I also looked at the first sixty lines of `verification/referee-consistency.md` and at the lines of `verification/one-mind-second.md` that concern Theorem 3.8, to avoid repeating work and to learn the present status of R6(c).

Literature. I read one source in this session: S. Goldwasser, A. T. Kalai, Y. T. Kalai and O. Montasser, "Beyond Perturbations: Learning Guarantees with Arbitrary Adversarial Test Examples", arXiv:2007.05145v3, pages 1 to 10 (Definition 1.1, Lemma 4.1, the statements of Theorems 5.2 to 5.5). Finding F4 rests on it. Every other statement about the literature in this report is taken from the note, the outline or `research/literature-checks.md` and was not checked by me.

Not checked. Lemma L4; every lower bound except N1 and the integer case of N2; the statements of Sections 5 to 9 beyond the steps listed in A.1; the attributions of Section 12; the computations of Section 11, which I did not rerun. Where a finding below says that a sentence of the note disagrees with a theorem of the note, I compared the two texts; I did not check which of them is true, except where stated.

The reader's requirements, as the digest gives them, against which I read Sections 0, 9 and 10 the second time:

* What "insane" covers. The digest (Section 3) takes the word to cover four groups of failures, each documented with his own words; the grouping is the digest author's. They are: behaviour off the training inputs that follows an if-statement on an unseen simple property ("the guard"), in particular a property that task decomposition supplies; a hypothesis that explains how the data were made in place of the human; a predictor of the human that is not like the human, or the sampler with its coins filled in; and harm to the reader ("If we look at the output, do we get hacked when looking at it?").
* What he does not accept: a guarantee bought by worst-case caution ("it just turns you into a rock"), a difficulty moved into an unexamined step, the human in the loop for ever, long human work per datum.
* What he accepts: whitelists; a toy theorem with honest scope; and he writes down himself when a constant makes a statement empty.
* His ideal theorem on the copy question: "some sort of robustness of recovering the sampler, at least in a toy setting".

## Part C. Question (1): does Section 0 answer his question, in his terms?

Summary of the judgement. Section 0 answers four of the eight things he asked for clearly (a scheme, a theorem, the property idea, the re-querying idea), two partly (distribution shift; why Solomonoff induction is not enough), and two inadequately (failing only obviously; mind upload against clever predictor). One answer is stronger than the section it cites (the property imitator, F1), one is weaker and contradicts its section (one program for a human who varies, F2), and one names a "faster route" that does not do what the context suggests (F6).

| what he asked for | where Section 0 answers | judgement |
|---|---|---|
| a scheme that works | answers 1 and 3 | Answered. The scheme is stated in three lines and can be understood cold. The restriction to a computation that can be run in advance is in the heading. That the bound is empty for a person is not said here but in answer 7 (F7). |
| a theorem | answer 1 (R1, R2) | Answered, with constants. Hypotheses that the answer does not name: A3 (fresh coins, a prior fixed first, the human cannot tell a question of the protocol), and that A1 for one person who answers n questions needs a fresh person for each question (Section 1, caveat on A1). |
| distribution shift | answer 1 (implicitly), answer 4, bullets 3 and 5 | Partly. The direct answer to the shift that decomposition produces is S4(i), "The shift that the system makes itself costs nothing", and it is not in Section 0 (F12). His own obstruction, the guard, is never named in Section 0. Shifts from outside are answered in telegraphic form. The positive result for open systems, S5, is missing (F11). |
| failing only obviously | answer 2 (certificate), answer 4, bullet 4 | Not answered in a form that can be read cold (F3). The plain verdict is in Section 10, test 6. The note's criterion (never silently wrong) is stricter than his ("basically"), and the published positive result of the kind he asked for is mentioned once, in Section 12, as having no counterpart (F4). |
| mind upload against clever predictor | answer 7, half a sentence ("it is not a copy of the person"); answer 6, two sentences on one program | Inadequate. The answer in Section 0 is thinner than Sections 5, 8.7 and 9.4, and one of its sentences contradicts R6(c) (F2). His own device for this question, the steeper prior, is proved to work in H2 and R6(c), and the note does not tell him. |
| the property idea | answer 5 | Answered, and this is the best part of Section 0 for him: the exact sense in which the idea works, its price, and that it is not imitation. Three defects: the sentence on Pr5 hides that the human answers every question (F1); two qualifiers are missing (F24); and the note never says in plain words what becomes of his own objection that properties contradict one another at a new input (F23). |
| why Solomonoff induction is not enough | answer 6, first two sentences; answer 5, last sentence; answer 4, bullet 1 | Partly. The answer "it is the data, not the inductor: no protocol is constrained where nothing was asked (N1), and on rehearsal questions the same mixture has R1" is correct and is what the sections state, but Section 0 gives it in three places and under a heading that points to the wrong section (F2). |
| the re-querying idea | answer 1, one sentence | Answered: "This is the idea of asking the human again, with some probability, on the inputs that task decomposition produces." What he may have meant, asking during deployment, is S5, and it is not in Section 0 (F11). |

## Part D. The six major findings

Each finding gives the place, the exact sentence, what is wrong for this reader, and a replacement. The section source to edit is named in brackets.

### F1 (MAJOR). Section 0, answer 5, hides that in Pr5 the human answers every question [intro.md]

Line 26: "An imitator can be built from the tests alone, with no class of hypotheses (Theorem Pr5): on every sequence of questions, whatever the human is, its count of answers in each test B stays within √((n + 1)(2 ln(1/π(B)) + ln(n + 1) + 1.39)) of the human's, and a kind of answer that the human never gives is given at most log₂(1/π(B)) + 2 times in total."

In Section 8.4 the setting of Pr5 is: "In round t the imitator fixes a rule a_t: X → Y; then a question x_t and the human's answer y_t arrive". The human answers all n questions, and the bound compares the imitator's answers with the human's answers to the same questions. The sentence in Section 0 does not say this. "On every sequence of questions, whatever the human is" then reads as a guarantee under any shift, with no assumption, for an imitator that stands alone. That is the one thing the question excludes ("not modulo keeping the human in the loop producing data forever"). The form without the human is Pr6. It holds for the rehearsed system only, has the factor L, and assumes A3 and A1 at the asked calls. So the later sentence "This is the exact sense in which 'the imitator keeps the properties the data had' can be had with no assumption about the human" is also too strong for the deployed form.

Replacement for the two sentences on Pr5 and Pr6 and the sentence after them: "An imitator can be built from the tests alone, with no class of hypotheses. While the human still answers every question, and the imitator commits to its answer first, the following holds on every sequence of questions, whatever the human is: the number of the imitator's answers in each test B stays within √((n + 1)(2 ln(1/π(B)) + ln(n + 1) + 1.39)) of the number of the human's, and a kind of answer that the human never gives is given at most log₂(1/π(B)) + 2 times in total (Theorem Pr5; the method is Blackwell's approachability and is not new). A property costs its own complexity, not the human's. Once the human has left, the guarantee is for the rehearsed system only: a property that the human always satisfies is violated at no more than L·(log₂(1/π(B)) + 2)/n calls of a deployed run, in expectation (Pr6; it assumes A3 and A1 at the asked calls). This is the exact sense in which 'the imitator keeps the properties the data had' can be had without assuming that the human belongs to a class."

The same correction is needed in `README.md`, answer 5.

### F2 (MAJOR). Section 0, answer 6, contradicts R6(c); the answer on "mind upload or clever predictor" is half a sentence [intro.md; assumptions.md for test 4]

Line 28: "One program in place of the mixture is possible for a deterministic human: a single posterior draw at the end has an unfaithful run with probability below 2L(K ln 2 + ln(1/δ))/n (R6). It is not possible for a human who varies, unless whole runs of the human system are recorded (R4, H1)." Line 30: "it is not a copy of the person."

(a) Proposition R6(c) (line 280) states, for "any class, P ∈ H" and with the rehearsal of Section 2 and no recorded runs: "let ν̂ maximise w(ν)²·ν(D). With probability at least 1 − 2δ, H²(Q_ν̂, Q_P) < L·(28·K ln 2 + 40·ln(1/δ))/n." The table in Section 5.1 (line 290) lists it: "squared weights: R6c". So one program for a human who varies is possible after rehearsal, by the note's own statement. What fails is a posterior draw, not every single program (the example after R4; H2 at λ = 1; `proofs/one-mind.md`, Remark 3.7, says the same). The second check of that part reports Theorem 3.8, which is R6(c), as correct (`verification/one-mind-second.md`, Section 1.1); I did not check it myself.

(b) In the first sentence the δ is not explained and "with probability at least 1 − 2δ" is missing.

(c) The answer mixes two subjects, ordinary questions and one program, under a heading that names only the first, and it sends the reader to Section 5 for the first, where it is not treated (it is in Sections 4.1, 6.1 and 11).

(d) He asked whether the imitator can be "more like a mind upload" and less like a predictor that also thinks about the state of the world. Section 0 answers with "it is not a copy of the person". The sections contain a fuller answer in three parts, each of which he would want up front. First, a single program can replace the committee (R6(b), R6(c), H2). Second, the sampler is told from "the sampler with coins filled in" only by weights w^λ with λ > 1: at λ = 1 "a posterior draw is a table ... A table is the human with the coins filled in" (line 318), and with one answer per input the two cannot be told apart at all (Pr7). The weights w^λ are the steeper prior that, according to the digest (Section 2.4), he proposed himself for exactly this purpose; the note does not say so in Section 0, in Section 5 or in test 4. Third, nothing distinguishes a copy from another program with the same behaviour on the closed system, and under A1 "a better predictor is assumed away, not excluded" (Section 9.4). A fourth point is against the upload picture and is worth one sentence: under low stakes a single member can be worse than the committee, whose errors are independent from call to call (R5).

Replacement: split answer 6 into two answers.

"6. **Solomonoff induction on ordinary questions has no guarantee where it matters; on rehearsal questions it has R1** (Sections 4.1, 6.1 and 11). With questions drawn from a fixed law, the data do not constrain the mixture, or any other protocol, on the inputs that only decomposition produces (N1). In the toy system of Section 11 the mixture is wrong in 35% to 100% of the runs after 10,000 such questions, while 6400 rehearsal questions bring the rate below half a percent."

"7. **Copy or predictor** (Sections 5, 8.7 and 9.4). The imitator of answer 1 is a committee: a fresh posterior draw at every call. One program can take its place. For a deterministic human, with probability at least 1 − 2δ a single posterior draw made at the end has an unfaithful run with probability below 2L(K ln 2 + ln(1/δ))/n (R6(b)). For a human who varies a posterior draw fails, because single answers cannot tell the human from the human with coins filled in (the example after R4; Pr7); the program of largest posterior weight under squared prior weights does not fail (R6(c); from recorded runs, H2 for every exponent above 1, and the statement is false at exponent 1). This is the steeper prior of the researcher's notes. None of this makes the program a copy of the person: the data fix the human's behaviour on the inputs of the closed system and nothing else, and under A1 no predictor can beat the human's own kernel, so that a cleverer predictor is assumed away and not excluded (Section 9.4). Under low stakes a single program can be worse than the committee (R5)."

The question paragraph of Section 0 should also carry his wish, which it now omits: add "Ideally the imitator would be a copy of the human, and not a predictor of the human that also reasons about the world." Test 4 in Section 10 should name R6(c), H2 and Pr7 and say that the robustness of recovering the sampler that he called the ideal theorem is obtained only in the sense of H2, for the laws of runs on one scaffold.

### F3 (MAJOR). Section 0 has no readable answer on "fails only obviously" [intro.md]

Line 23: "The abstaining rules, with a parameter that makes their soundness a theorem, refuse every new input that a test of fewer than about K bits separates from the asked ones; with a milder parameter the same rules are whitelists, sound under an assumption that the data cannot confirm (Section 7)."

At this point of the note no abstaining rule has been introduced, and "a parameter", "soundness", "a test ... separates" and "whitelists" are undefined. I understood the sentence only after Section 7.4. Section 0 also never says that the failures of the rehearsed mixture itself are silent. The verdict that he needs is in the note, in Section 10 (line 647): "It acts everywhere in the closed system; its unfaithful calls are unmarked and must be taken as an adversary's." and "Nothing here acts on new inputs, fails only visibly and needs no assumption." The two positive results of Section 7 are not in Section 0 at all: Ab1(b), which trades silent errors for aborts on the rehearsed system at a price polynomial in K, and Ab2(a), exact domination on any inputs when the human is in the plausible set.

Replacement: take the fourth bullet out of answer 4 and give the subject its own answer.

"**Failing only obviously costs more than failing rarely** (Section 7). The rehearsed mixture answers everywhere, and its wrong answers are not marked. A rule that may abstain can do better in two ways. On the system that it rehearsed, for a deterministic human and when it answers the rehearsal runs itself, the rule 'answer only when the mixture gives one answer probability at least 1 − η' has at most L·K/(n·log₂(1/η)) wrong answers per run in expectation and aborts a run with probability at most L·K ln 2/(n·η) (Ab1): silent errors fall by the factor log₂(1/η), aborts rise by the factor 1/η. On any inputs, the rule 'give each answer with the least probability that a plausible hypothesis gives it, and abstain with the rest' produces the human's run or a beginning of it followed by an abort, provided that the human is among the plausible hypotheses (Ab2). That proviso is a theorem only if the plausible set reaches down to the human's weight 2^(−K). The rule then refuses every unasked input that a test of fewer than about K bits separates from the asked ones, and it needs of the order of 2^K questions not to abort on the rehearsed system. With a smaller plausible set the rule is a whitelist whose soundness is an assumption that the data cannot confirm. And a rule that is never silently wrong for a class that can change one input at a time must ask or abstain at every new input (N4). So nothing in this note acts on new inputs, is never silently wrong and needs no assumption."

(The last sentence is changed against line 647 for the reason given in F4.)

### F4 (MAJOR). "Basically only fails obviously": the note uses a stricter criterion than the question, and sets aside the one published result of the kind he asked for [shift-abstain.md; intro.md; assumptions.md; related-work.md]

Line 681: "PQ-learning (Goldwasser et al. 2020, Theorem 5.2) gives, for deterministic binary labels and test inputs known in advance, error on an arbitrary test distribution and rejection rate on the training distribution of order √(d·ln n/n) for VC dimension d. The note has no counterpart." Line 647: "with a moderate plausible set it is a whitelist whose soundness the data cannot confirm. Nothing here acts on new inputs, fails only visibly and needs no assumption."

He asked for an imitator that "basically only fails obviously", without further questions to the human. Section 7 studies rules that are never silently wrong (N4, Ab2, Ab3, enumeration), or whose silent errors are counted on asked or rehearsed inputs only (Ab1), and concludes that a sound rule is a rock and a whitelist is a bet. The theorem quoted in Section 12 is of the kind he asked for, and it lies between the two. I read its statement in the source in this session. Theorem 5.2 there: for every class C of VC dimension d, every f in C and all distributions P and Q, from n labelled examples drawn from P and n unlabelled examples drawn from Q, the selective classifier has, with probability at least 1 − δ, error at most 2ε* on Q and rejection probability at most ε* on P, where ε* = √(8d·ln(2n)/n) + 8·ln(16/δ)/n. Theorem 5.3 gives the same for an arbitrary test set chosen by an adversary, and Theorem 5.4 shows that the order √(d/n) cannot be improved. The authors recall (page 5) that a guarantee of zero test errors with few rejections needs exponentially many examples already for rectangles (Kivinen 1990, as they cite it); this agrees with what Section 7 of the note finds for its own rules.

For this reader the consequences are these. A class of at most 2^b functions has VC dimension at most b. So for a deterministic human with two possible answers among at most 2^b candidates, with b at least K, such a rule would be silently wrong on at most a fraction ε of any batch of deployment inputs known in advance, would refuse at most a fraction ε of inputs drawn from the training law, would ask the human nothing at deployment, and would cost of the order of b/ε² answers, up to a logarithm, where Ab2(d) needs of the order of 2^K. It is a whitelist in his sense, since off the training law it may refuse everything, and its soundness up to the rate ε is a theorem and not "an assumption that the data cannot confirm". This is my reading of the cited theorem, not a checked transfer to the note's setting. Its limits are visible: the guarantee is a frequency over a batch that must be known in advance, so it fits top-level inputs and scaffolds whose questions do not depend on the answers, and not adaptive scaffolds as they stand; labels are binary and deterministic; and the one input that matters may be the one that is silently wrong.

So the note's answer on this point may be more negative than what is known, and the reason is a choice of criterion that the note does not announce. Either the counterpart should be worked out, or Sections 0, 7.4 and 10 should say what is known and that it was not developed here.

Proposed paragraph for Section 7.4, after Ab4: "*Between the rock and the bet.* The rules above are never silently wrong, or count their silent errors on asked inputs. If a small rate of silent errors on new inputs is accepted, more is known for a deterministic human with two possible answers. Let the class have VC dimension d, and let the deployment inputs be known as a batch in advance. The rule of Goldwasser, Kalai, Kalai and Montasser (2020, Theorems 5.2 and 5.3) is then silently wrong on at most a fraction 2ε of the batch, whatever the batch is, and refuses at most a fraction ε of inputs drawn from the training law, with ε of order √(d·ln n/n) after n answers to questions drawn independently from one law; no rule has a better order (their Theorem 5.4). It needs no further question and no assumption beyond A2 with a known bound on K. It is a whitelist whose soundness, up to the rate ε, is a theorem; off the training law it may refuse everything. This note has no counterpart: whether the result extends to scaffolds whose questions depend on the answers, to more than two answers and to a human who varies is open here."

Line 647 should then read: "with a moderate plausible set it is a whitelist whose soundness the data cannot confirm; a whitelist that is sound up to a small rate of silent errors is known for a deterministic human with two answers and deployment inputs known in advance (Section 7.4). Nothing here acts on new inputs, is never silently wrong and needs no assumption." The open question on abstention (Section 13, question 8) should name this as its first item.

### F5 (MAJOR). "The human reads what the prior wrote" is called fatal and is stated once, in a list, and not in Section 0 [assumptions.md; intro.md]

Line 616: "*the human reads what the prior wrote:* to a class of all programs with a large scaffold and a reader who must not be harmed;"

This is the only place in the note where the matter is mentioned. A cold reader cannot tell from it what happens. What happens, as `proofs/assumptions.md` (Section 8, O8) explains: a rehearsal question is a call of a run that the current mixture answered, so its text is built from the mixture's earlier answers; in the early rounds these are the prior's. With the class of all programs, any program may have written the text that the human must read. For a deterministic human at most L·K ln 2 questions in expectation follow an unfaithful call (Proposition 1.16 there, not checked by me), which for K of a person does not exclude that every question of an affordable rehearsal is of that kind. The proof file draws the two consequences: "If reading such text can change the human, A1 fails; if it can harm the reader, the protocol is not safe".

For this reader the point is central, not a detail. His question begins with "a protocol that does not do something insane", and harm to the person who looks at the output is one of the four groups of failures that the digest takes this word to cover (Section 3, group D, F19, with his words "If we look at the output, do we get hacked when looking at it?"; his desideratum D11). The note itself counts the objection among the seven that are "fatal to part of" its claim. A limit of that weight belongs in Section 0 and needs a paragraph in Section 9. It also explains two phrases that are otherwise cryptic: "those of the early rounds being the prior's" in test 5 (line 645), and the remark that the early questions may be nonsense (his F27, "asking stupid questions").

Proposed paragraph for Section 9.5, before "The others are answerable": "**The human reads what the imitator wrote.** A rehearsal question is a call of a run that the current mixture answered, so its text is built from the mixture's earlier answers, and in the early rounds these are the prior's. For a deterministic human at most L·K ln 2 questions in expectation follow an unfaithful call (Proposition 1.16); for K of the size of Section 9.1 this allows every question of an affordable rehearsal to be of that kind. Such questions may be nonsense, which wastes answers. With the class of all programs they may be written by any program, and nothing here bounds what reading them does to the human: if it changes the human, A1 fails, and if it can harm the reader, the protocol is not safe. The remedies are a restricted class, which strengthens A2, and for small scaffolds recorded runs of the human system (H1), in which the human reads only what the human wrote."

Proposed sentence for Section 0, in the answer on what the protocol does not give: "In rehearsal the human reads questions that the imitator's own runs wrote, in the early rounds those of the prior; with the class of all programs nothing here bounds what such text contains or what reading it does (Section 9.5)."

### F6 (MAJOR). The "faster route" of Section 0 keeps the factor K, and neither Section 0 nor Section 9.2 says so [intro.md; assumptions.md; open.md]

Line 30: "A faster route is a bet: if the human is separated from every other member of a class without patches, the posterior concentrates exponentially fast (I1), and if the human is not in such a class the error is silent." Line 589: "After n rounds the expected posterior weight of the members whose runs differ from the human's is at most 2^K·(1−δ/(2L))^n."

The bound of I1 is below 1 only when n exceeds 2L·K ln 2/δ. The bet therefore replaces the factor 1/ε of R1 by ln(1/ε) and keeps the factor L·K. For a person it is as empty as R1. In Section 0 the sentence follows "Every bound is in K ... There the bounds are empty" and "The factor K cannot be removed in general", and "A faster route" then reads as a way out of that. Open question 2 (line 697) adds "the lower bounds of Section 4 do not apply", which strengthens the impression. The outline (correction 5) requires that a bound which is empty for a person be called so in its place; I1 is not. "A class without patches" is also used here before anything explains it.

Replacements. Section 0: "One bet changes the rate and leaves the factor K: if the human is separated from every other member of a class without patches, that is, a class in which no member is another member altered on a small set of inputs, then the error falls exponentially in n once n exceeds 2L·K ln 2/δ, δ being the separation (I1). If the human is not in such a class the error is silent." Section 9.2, after the statement of I1: "The bound says nothing before n exceeds 2L·K ln 2/δ. The bet buys ln(1/ε) in the place of 1/ε. It does not buy a smaller K, and for a person it is as empty as R1." Section 13, question 2, after "one place at a time": "The factor K remains: I1 needs more than 2L·K ln 2/δ rounds."

## Part E. Question (2): further overclaims and underclaims

Apart from F1, F2, F4 and F6, the note states its theorems with their hypotheses, and it is careful about what is standard: "None of this is new" in Section 2 and "Most statements of this note are instances or variants of published results" in Section 12 are plain. The overclaims that remain are almost all in the headings and summary sentences of Section 0. The underclaims are results that sit in Sections 4.6, 6 and 9 and that this reader would want in Section 0.

### F8 (MINOR). Answer 4, heading: "In general nothing does better" [intro.md]

Line 19: "**In general nothing does better, and these are theorems as well** (Sections 4, 6 and 7)."

The sections state less. The lower bounds are for particular classes. On those classes rehearsal is within the factor 4·K ln 2 (line 202) or a factor of order log₂(L/δ) (lines 212 and 216). Chosen questions save the logarithm in the worst case (N2c). On a class with K rare informative inputs, random calls of runs need 0.1·K·L/ε − 0.4 questions "where K chosen questions suffice" (line 220). For work with bounded damage "the only lower bound that contains K is n ≥ (1 − 2θ − 2δ)·K" against K ln 2/(θδ) for R3 (line 701). For a human who varies the constants are "about 10⁴ away" (line 715). The proof file calls the wording "exactly as far as any protocol can" false in five ways (`proofs/assumptions.md`, O7).

Replacement: "4. **In the worst case over classes no protocol does much better, and these are theorems as well** (Sections 4, 6, 7 and 9.1). On the classes built for the lower bounds, rehearsal is within a constant or a factor of order log₂(L/δ) of the least possible number of questions. On other classes it is not: chosen questions can save a factor of order L/ε (Section 4.3), and for work in which no answer is critical the only lower bound is about K questions (Section 9.1)."

### F9 (MINOR). Answer 4, second bullet: the quantifier of N2, and "reuse" without its price [intro.md]

Line 21: "If each of L calls can decide the outcome, there is a class of candidates of log₂(L/2δ) bits for which every protocol needs at least L/(4δ) − L questions to keep the failure probability of a run below δ (N2). For one such run it is cheaper to let the human make the L calls. What imitation buys is reuse: the questions are paid once, and the imitator can then be run any number of times."

(a) N2 is a statement about one scaffold and one class. Section 4.2 says so (line 204: "Nor does it count critical calls ... Asking one input L times costs one question"), and the outline (correction 3) asks for the class and the quantifier. The sentence reads as if every scaffold with L critical calls had such a class. (b) The bound L/(4δ) − L needs L/(2δ) to be an integer (line 196). (c) "Reuse" is given without its price. Section 4.6 has the price: on that class every protocol replaces at most 4F/(1 − 4δ) human answers per answer spent, F being the expected number of failed runs allowed in all; "a guarantee for every member saves no human work unless failed runs are allowed"; rehearsal "breaks even once K ln 2 failed runs are allowed"; "For a person ... that is millions of failed runs". Corollary N2d is the clearest statement in the note of what imitation can amplify, and Section 0 does not have it.

Replacement: "There are a scaffold in which each of L calls can decide the outcome and a class of candidates of about log₂(L/2δ) bits for which every protocol needs at least L/(4δ) − 3L/2 questions to keep the failure probability of a run below δ for every candidate (N2). For one such run it is cheaper to let the human make the L calls. Imitation saves human work only across many runs, and only if failed runs are accepted: on this class the number of human answers replaced for each answer spent is at most about four times the expected number of failed runs allowed in all, and rehearsal breaks even once about K ln 2 failed runs are allowed (N2d)."

### F10 (MINOR). Answer 3, heading: "the price does not grow with the computation" [intro.md]

Line 17: "**When no single answer is critical, the price does not grow with the computation** (Section 3)."

The statement holds for a fixed fraction θ. The tolerance is assumed, against a rule that sees the human's answer, and the protocol never tests it (line 619: "which R3 assumes and the protocol never tests"). Where the tolerance comes from replication, 1/θ counts the critical units: "'whatever L' in R3 does not amplify such work" (line 583). The heading advertises; the outline says not to.

Replacement of the heading: "**When a fixed fraction of the answers may be replaced without harm, the price does not grow with the length of the computation**". Sentence to add at the end of the answer: "That the human system has this tolerance is assumed and never tested by the protocol; where the tolerance comes from replication, 1/θ counts the independent critical units and nothing is gained for each of them (N8)."

### F11 (MINOR). Answer 4, last bullet: a general claim from one class; and S5, his own idea in its plain form, is missing from Section 0 [intro.md; rehearsal-core.md]

Line 24: "In an open system the human cannot leave early: on a class of 2^K thresholds, the expected number of silent errors and abstentions, multiplied by the number of questions plus one, is at least 3·2^K/16; a deterministic human can leave after about 2^K questions (N7)."

(a) N7(a) is "a worst case over one class and one sequence" (line 372), for a learner that may ask only at the input shown. The opening clause states it for open systems in general. (b) "Open system" has not been defined at this point. (c) "A deterministic human can leave" follows a statement about thresholds, which are deterministic; I could not tell what the contrast was until I had read N7(b). (d) Proposition S5 (line 362) is the re-querying idea as he may have meant it, during deployment, and it is the strongest statement on shift in the note: inputs may arrive in any way, and the expected divergence summed over an unbounded run is at most K ln 2/q. Section 0 does not mention it, and Section 3.6 gives it four lines.

Replacement: "In an open system, where inputs arrive in any way and nothing can be rehearsed, the idea works as it stands, and the human never leaves: if each arriving input is put to the human with probability q, the imitator of a deterministic human gives at most (1 − q)·K ln 2/q wrong answers in expectation over the whole unbounded run, whatever the inputs are (S5). The asking cannot always stop early: for a class of 2^K thresholds and one sequence of inputs, the expected number of silent errors and abstentions, multiplied by the number of questions plus one, is at least 3·2^K/16, while about 2^K questions suffice for every class of functions (N7)."

### F12 (MINOR). The direct answer on the shift that decomposition produces, and the guard, are missing from Section 0 [intro.md]

Line 330: "(i) *The shift that the system makes itself costs nothing.* For every set S of inputs, the probability that the question of round T lies in S is 1/L times the expected number of calls of the deployed run in S, whatever the scaffold does with the answers. So Theorem R1 needs no factor for shift."

This is the answer to "the shift produced by task decomposition, where the imitator's inputs are written by other imitator calls". In Section 0 it is contained only in the words "along the mixture's own run". The obstruction that he returns to most, according to the digest ("if input has property P, then output 0. else, do the program"; "there will be a simple property distinguishing test from train if you want to do task decomposition"), is not named in Section 0; the word "guard" first occurs in Section 10.

Sentences to add to answer 1, after the sentence on R1: "The shift that decomposition produces costs nothing: the asked call is an unbiased sample of the calls that a deployed run makes, whatever the scaffold does with the answers (S4(i)). In the researcher's terms: the guard 'if the input has a property that no training input had, answer otherwise' has little to hold on to. For each property fixed in advance, a deployed run meets it without the human having been asked about it with probability at most L/n (R7); what the imitator does then is the prior's choice (N1)."

### F13 (MINOR). R7: its meaning in bits, what it does not say, and where its argument comes from [rehearsal-core.md; intro.md]

Line 126: "The probability that the deployed run of M^(T) makes a call in Q although no question of rounds 1, …, T − 1 lay in Q is at most L/n; for N such sets it is at most N·L/n." Line 130: "*What it does not say.* It holds for each fixed set, not for all sets at once".

(a) In his units the statement is: with probability at least 1 − δ the deployed run meets no property that has a program of fewer than log₂(δn/L) bits without the human having been asked about it. (There are fewer than 2^b programs of fewer than b bits; the proof file has this as Corollary 3.2′, according to its Section 5.) For n = 10⁵ and L = 10 that is 13 bits less log₂(1/δ). The number shows how far the guarantee reaches, and the note should give it. (b) "What it does not say" should add: "That a region was asked once says nothing about the answers in it: the question refutes only the hypotheses that are wrong at the asked input." Without this a reader takes coverage for more than it is. (c) Section 0 calls coverage one of "Two checks" (line 15). Nobody performs it; it is a guarantee. (d) `proofs/assumptions.md`, Section 11, says: "Theorem 3.2(a) is the random-stopping lemma of `research/understand/notes.md` (Q14) applied to the protocol", and the digest quotes the researcher's own argument for a random stopping time. The note says "(coverage; proved here)". He will recognise his argument; the note should say: "The argument is the random-stopping argument of the researcher's notes, applied to the protocol."

### F14 (MINOR). Two attributions to the reader are wrong [assumptions.md; shift-abstain.md]

(a) Line 625: "The tests are those that the researcher's notes apply to any proposal." The digest marks them as its author's: "The tests he is likely to apply to any proposal [my own derivation, from the pattern of his objections to his own schemes]". He did not write seven tests. Replacement: "The seven tests are our summary of the objections that the researcher's notes raise against his own schemes; the wording is ours." (`README.md` has the same claim.)

(b) Line 412: "**Proposition Ab3** (proved here; Observation B of the researcher's notes)." Observation B is in Section 6.2 of the digest, which opens: "Everything in this section is [my own derivation] unless tagged otherwise". It is the digest author's remark, not the researcher's. Replacement: "(proved here; first noted in the project's digest of the researcher's notes, as a remark of its author)".

The attribution in line 543 ("as the researcher's notes claim") agrees with the digest (summary, point 9) and can stay. The missing attributions to him are in F2 (the steeper prior) and F13 (random stopping).

### F15 (MINOR). "Every bound is in K", and "What survives" leaves out what has no K [intro.md; open.md; assumptions.md]

Line 30: "Every bound is in K". Line 695: "Every positive result is in K". The bounds of R7, V1(a), V1(b), Pr3, Pr5 and Pr6 contain no K, and the same answer 7 lists two of them as what works ("or for properties, at their own price; or as a check"). Replacements: "Every bound on imitation is in K"; "Every positive result on imitating the human's answers is in K".

Line 621, "*What survives.*", lists R1, the lower bound and the certificate, and omits the two guarantees without K. Sentence to add: "With no assumption that the human is among the candidates, each property that the human always keeps is violated at no more than L·(log₂(1/π(B)) + 2)/n calls of a deployed run of the imitator built from tests (Pr6), and a region of inputs fixed in advance is entered unasked with probability at most L/n (R7)."

### F16 (MINOR). What K is, and what a better prior can buy, is said plainly only in the proof files [rehearsal-core.md; assumptions.md]

Line 38: "We write K := log₂(1/w(P)); in Sections 3.1 to 3.4 only the human's answers to inputs that the scaffold can produce count towards it (`proofs/rehearsal-core.md`, Remark 4.4)." I read the second clause twice and understood it only from the proof file. Replacement: "We write K := log₂(1/w(P)). In Sections 3.1 to 3.4, K may be read as log₂(1/w([P])), where [P] is the set of hypotheses that answer as the human does on every input that the scaffold can produce: the number of bits that the prior needs to single out the human's behaviour on those inputs. This is less than K when those inputs are few, and not when the scaffold can pose arbitrary questions (`proofs/rehearsal-core.md`, Remark 4.4)."

The digest (Section 6.1, constraint 6) records his own idea for a smaller constant, a "simplicity prior defined in terms of existing understanding". The note answers it in one clause of test 2 ("a prior built from knowledge") and in open question 1. The proof file has the sentence he needs (`proofs/assumptions.md`, Proposition 2.4 and its reading; read in this session). Sentences to add to Section 9.1, after the table: "A prior built from knowledge can make K small only for few candidates: under every prior at most 2^k candidates have K ≤ k (Proposition 2.4). So K may be read as the logarithm of the number of humans that the prior, with all knowledge built in, cannot tell apart on the inputs of the closed system, and in the worst case over classes as nothing smaller."

## Part F. Question (3): clarity

The outline says of this reader: "He reads cold: every symbol and every coined term must be defined where it is first used." Sections 2 and 3.1 meet this; R1 with its proof and "What it does not say" is the model for the rest. Sections 0, 4.3, 7 and 8.6 do not meet it.

### F17 (MINOR). sep(x; A) is never defined [shift-abstain.md]

First use, line 400: "Min over the ratio set abstains with certainty wherever sep(x; A) ≤ log₂(1/α) − c." The symbol then carries Ab2(c), Ab3, the table of rocks and whitelists and a sentence of Section 9.2 (line 587). The outline's notation list has the definition; the note does not. Section 7 is the note's answer to one of his questions, and its main statements cannot be read without it. Sentence to add at the head of Section 7: "sep(x; A) is the length of a shortest program for a decidable set that contains x and no element of A: the number of bits needed to separate x from the asked inputs."

### F18 (MINOR). Terms and symbols used before they are defined, or never defined

| line | term | what to do [source] |
|---|---|---|
| 13 | "the class" | Introduce it: "a countable class of candidate samplers with prior weights". [intro.md] |
| 13 | "the human system's" | Defined in line 40. Write "of the law of the run that the human would produce (the human system)". [intro.md] |
| 15 | "unfaithful calls" | Defined in line 42. Write "calls at which its answer differs from the answer that the human would have given (unfaithful calls)". [intro.md] |
| 15 | "each test from a weighted family" | "Test" is defined in answer 5. Write "how often answers have each of a weighted list of properties". [intro.md] |
| 23 | "the abstaining rules", "whitelists" | See F3. |
| 24 | "open system" | "Closed" is defined in line 46, "open" nowhere. See F11. |
| 26 | "memorisers" | Defined in line 545. Write "hypotheses that are a table of the answers seen and answer badly elsewhere (memorisers)". [intro.md] |
| 30, 587, 697 | "a class without patches", "patch-free prior", "isolated" | "Patch" is used in lines 404 and 591 and explained only for the toy (line 655); "isolated" is defined after the theorem that uses it. Define all three before I1. [assumptions.md; intro.md] |
| 44, 46 | "the run that counts" | Write "the deployed run". [rehearsal-core.md] |
| 95 | "the ladder" | A name for an example that is not shown and not used again. Drop it. [rehearsal-core.md] |
| 102 | "squared Hellinger distance" | The normalisation is not stated; the constants depend on it. Add "H²(p, q) := 1 − Σ_y √(p(y)·q(y))". [hellinger-runs.md] |
| 188 | K(Q) | Complexity, next to K for the human's bits. Say "the length K(Q) of a shortest program for Q". [lower-bounds.md] |
| 88, 188, 639, 677, 683 | "Paper 1", "Paper 2" | Not identified anywhere. Give title and folder at first use. [rehearsal-core.md; lower-bounds.md; assumptions.md; related-work.md] |
| 218 | "Protocol AB" | The letters are not explained. [lower-bounds.md] |
| 264 | "traps" | A hypothesis was a function of the input alone (line 36); a trap "answers 1 at one input and at every later call". Say how the later calls carry the history. [one-mind.md] |
| 276, 282 | "the driver" | Write "the hypothesis that answers the rehearsal runs (the driver)". [one-mind.md] |
| 328, 402, 679 | "Protocol R" | Never introduced. Add to Section 2: "We call the three steps Protocol R." [rehearsal-core.md] |
| 332, 356 | S2 | Cited twice, stated nowhere; line 356 says "What S2 needs". State it (see F20). [lower-bounds.md] |
| 392 | "those ranked no lower" | See F20. |
| 416, 442 | "rocks" | His word, not defined in the note. Add: "A rock, in the researcher's words, is a rule that is safe because it does nothing: here, one that refuses every new input. A whitelist refuses what differs in a simple way from what was asked, and acts elsewhere." [shift-abstain.md] |
| 424, 218 | "audits" | Write "questions put to the human at random". [shift-abstain.md; lower-bounds.md] |
| 427 | "a needle class" | Write "the class of N2". [shift-abstain.md] |
| 498 | "Rule NH" | The letters are not explained. [property-online.md] |
| 605 | "the human's kernel" | The word is used once. Write "the human's answer distributions P(·|x)". [assumptions.md] |
| 679 | "Theorem B", "Theorem A" | The note has no such labels; they are H2 and H1. [related-work.md] |

### F19 (MINOR). Letters with several meanings

The outline fixes the letters, but the sections reuse them. The ones that stopped me:

* A: an answerer (line 40), the set asked under f₀ (200), the set of asked inputs (376 and all of Section 7), the number of good answers (533), a class of tests (687).
* Q: the law Q_A of a run (40), a set of inputs (126, 180), the sets Q_i of shifts (352), the number of questions (366), the law of recorded runs (462).
* ρ: the scaffold's random bits (40), the probability of a recorded disagreement (158).
* s: L·K ln 2/(2n) (110), a spread of the human's answers (158), an exponent (308), the novelty threshold (412), a number of answers (555).
* σ: a sum of Hellinger distances (102), a slack (146), a silent failure probability (427), a sign (498).
* a: a drift (146), a margin (352), an abort probability (427), a width a(B) (462), a rule a_t (496).
* δ: a failure probability throughout, the separation in I1 (589). β: unfaithful calls (42), a bound (356), the strength of a tilt (532). N: cells, regions, laws, recorded runs, inputs. Γ: a set of tasks (350), a logarithm (402). η: a threshold (380), a rate (514).

The worst are A and Q, because Q_A and "the set A of asked inputs" and "a set Q of inputs" occur within a few pages of one another. Proposal: write the set of asked inputs as 𝒜 or "Asked", the region of R7 and N1 as a letter other than Q, the number of questions in N7 as n, and ρ and s in V1 as r and v.

### F20 (MINOR). Passages that I read twice or more, with replacements

Replacements marked (*) restate my reading of the passage and must be checked against the proof file by the editor.

1. Line 15: "Such a certificate can only be obtained when the human is nearly deterministic on those inputs. For a human who varies, what can be certified without assumptions is the frequency of each test from a weighted family and, with questions put twice, a squared distance between answer distributions (Pr7, Section 8.7)." Replacement: "Such a certificate can be obtained only if the human nearly always gives the same answer on those inputs. For a human who varies, what can be certified without assuming a class is weaker: how often answers have each of a weighted list of properties and, if questions are put twice, a squared distance between the answer distributions (Pr7, Section 8.7)." [intro.md]
2. Line 26: "for about K divided by the bits per pair questions". Replacement: "for the first K/b questions, where b is the number of bits that a memoriser spends on one question–answer pair". [intro.md]
3. Lines 48 to 54, the caveats on A1 to A3. They refer to R1, R3, V1(a), E1 and "the asked call" before the protocol has been stated. Proposal: leave one sentence for each assumption in Section 1 and move the three paragraphs behind Section 3.1, or into Section 9. In line 50, "every theorem holds for the system of such humans, which can be at total variation 1/2 from the real one" should read: "The protocol then imitates the scaffold answered by a human without memory, and every theorem holds for that system; its runs can be at total variation 1/2 from the runs of the real human (Example 1.1)." [assumptions.md, block A]
4. Line 90: "cost 350 years". Write "350 working years of 2000 hours". [rehearsal-core.md]
5. Line 96: "*More questions per run* do not improve the bound". Replacement: "*Asking several calls of each run* does not improve the bound for a given number of questions". [rehearsal-core.md]
6. Line 108: "Close runs do not make single calls close, except with a factor L." Replacement: "Conversely σ ≤ 2L·H²(Q_A, Q_B), and the factor L cannot be removed (Proposition 2.5): run laws that are close do not make the single calls close." (Checked against the summary line of Proposition 2.5 in `proofs/hellinger-runs.md`.) [hellinger-runs.md]
7. Line 188: "A human who may answer any string at x has no partner with a disjoint answer law, only partners at total variation 1−1/N, for a further log₂N + 2·log₂log₂N bits (N ≥ 2)." I could not tell why this is here. Either say what it is for ("For a human who varies, N1 is weaker by the factor 1 − 1/N: ...") or leave it to the proof file. [lower-bounds.md]
8. Line 204: "it counts the places they fall on that the class can change one at a time." Replacement: "It counts the inputs on which critical calls can fall and which the class can change one at a time: a scaffold that asks one input L times has L critical calls and needs one question." [lower-bounds.md]
9. Line 206: "even a protocol that sees z before asking". What z is in this class is not said. Replacement (*): "even a protocol that is shown the L inputs of the run before it asks needs n ≥ L·(1−√(2δ)−δ)−δ questions, nearly one for each call". [lower-bounds.md]
10. Line 218, Protocol AB: "while some input occurring in a run answered by a member has no answer of posterior weight above 1−ε·log₂(L/ε)/L, ask it. Otherwise let the weighted vote of the unrefuted members answer a rehearsal run, and ask one random call of it. Deploy the vote of a random such run. With their number chosen from K, ..." Replacement (*): "The protocol has two phases. *Ask where the class is split:* as long as there is an input that some run can reach under some member and on which no answer has more than 1 − ε·log₂(L/ε)/L of the posterior weight, ask that input; each such question refutes at least the fraction ε·log₂(L/ε)/L of the weight. *Audit:* when no such input is left, let the weighted vote of the unrefuted members answer a rehearsal run, and put one random call of that run to the human. Deploy the vote that answered a uniformly chosen audit run. With the number of audit runs chosen suitably from K, L and ε, ..." [lower-bounds.md]
11. Line 262: "Asking every call of the rehearsal runs does not help (Proposition 3.2)". In the example just given the same question is put three times, and three recorded answers that differ would refute every function. The summary of Proposition 3.2 in `proofs/one-mind.md` shows that it concerns another example, in which "no input is repeated in a run". Replacement: "Nor does it help to ask every call of the rehearsal runs: in a variant of the example in which no run repeats an input the same happens (Proposition 3.2)." [one-mind.md]
12. Lines 344 to 348, S1(b) and its example. The reason for the factor 2L − 1 is not conveyed. Sentence to put before the formula: "A bound for inputs that are dominated by the visits of the rehearsal runs, and not by the visits of the deployed imitator itself, loses a factor of order L, because the imitator of one round is then judged on inputs that the imitators of other rounds visit." [shift-abstain.md]
13. Line 356, "**What S2 needs**". S2 has not been stated. Replacement of the first sentence: "**Proposition S2 (all simple shifts at once; standard domination).** If rehearsal draws the task from a mixture Σ_i π_i·D_i of task laws, a bound β on the expectation over the task of a non-negative quantity becomes β/π_i under D_i. For N disjoint laws the factor N is necessary (N3). *What S2 needs.* The mixture must be sampled, ..." [lower-bounds.md]
14. Line 372: "Only in that sense can the asking not stop." Replacement: "So the asking can stop, but in the worst case only after a number of questions that is exponential in K." [shift-abstain.md]
15. Line 392: "The *top set* keeps those whose weight is at least α times the total weight of those ranked no lower". Replacement: "The *top set* keeps a hypothesis if its posterior weight is at least α times the total weight of the hypotheses that are at least as heavy, itself included". [shift-abstain.md]
16. Line 543, Pr2(a). Replacement (*): "Suppose that with each hypothesis ν the class contains ν^R, which answers as ν does but redraws until the answer does not violate R (no answer counts as no violation), and that the hypotheses which this operation sends to one member weigh together at most C_R times that member. For all programs and decidable R, C_R = 2^(K(R)+c). Take any data without a violation of R, and for each hypothesis let p_ν be the probability that it gave to not violating R at the inputs seen. Then the posterior mean of 1/p_ν is at most C_R. Two consequences: if the inputs seen are asked again, the mixture violates R at most ln C_R times in expectation; and at every input the mixture violates R with probability at most 1 − 1/C_R, as the researcher's notes claim." [property-batch.md]
17. Line 541: "Let R be a set of pairs that the human never violates." In Sections 8.2 to 8.5 a test B is the set that is entered or not; here R is the set that must not be left. Say so: "Let R be a property, that is, a set of pairs (x, y), and say that an answer y to x violates R if (x, y) is not in R." [property-batch.md]
18. Line 575: "the bound credits sequential batches, not answers, unless questions do not depend on answers". Replacement: "questions that are answered at the same time are all drawn with the same mixture, and the bound then counts batches in the place of answers, unless the questions do not depend on the answers". [assumptions.md]
19. Line 587: "Averaged over the prior, a posterior draw per run is exact with no question asked (Proposition 7.7; standard, Thompson 1933): the theorems are about a human who is not typical of the prior, and a rare situation is a bet on the prior." Replacement: "If the human were drawn from the prior, a draw from the prior would have exactly the human system's law of runs, with no question asked (Proposition 7.7; standard, Thompson 1933). The theorems hold for every human in the class, also for one whom the prior thinks unlikely; what the imitator does in a situation that rehearsal never met is the prior's guess." [assumptions.md]
20. Line 591: "no data decide between the two bets". Replacement: "no data decide between the universal prior, which keeps a doubt at every new kind of input, and the patch-free prior, which has none and is wrong on a patch". [assumptions.md]

### F21 (MINOR). Proof ideas that do not convey the idea

1. L4, line 108: "*Idea.* Along a run of A, a quadratic function of the root likelihood ratio of B to A rises by at most a constant times h_j at call j, in expectation." This does not say which function, nor why the distance of the run laws follows. The proof in `proofs/hellinger-runs.md` (Theorem 2.1(c) with Lemma 2.2; read in this session) is ten lines and the outline allows it in full. If only an idea is given: "*Idea.* Along a run of A let Λ be the square root of the likelihood ratio of B to A. Its mean at the end of the run is 1 − H²(Q_A, Q_B), and at call j its conditional mean is multiplied by 1 − h_j. The function U(x) := ½·max(2 − x, 0)² lies above the line 3/2 − x, and the conditional mean of U(Λ) rises by at most 4·h_j at call j. So ½ + H²(Q_A, Q_B) ≤ E U(Λ) ≤ ½ + 4σ." [hellinger-runs.md]
2. R4, line 260: "the round's question removes posterior mass at least u·(L + 1)/(2L²) in expectation, and at most K ln 2 can be removed in all." Mass is at most 1 and K ln 2 is a logarithm; the two do not compare. Replacement (*): "the round's question refutes, in expectation, at least the fraction u·(L + 1)/(2L²) of the posterior weight that is not yet refuted. The human's weight 2^(−K) is never refuted, so these fractions add up to at most K ln 2." [one-mind.md]
3. R6, line 282: "(b) An Occam bound in martingale form. (c) The same in Hellinger distance, ...". These name techniques. One sentence each on why a heavy member that survives must be close would help; I cannot supply it without the proof. [one-mind.md]
4. I1, line 591: only "Proof: Theorem 7.4." Proposed idea (*): "A member whose runs differ from the human's with probability at least δ is refuted by the question of a round with probability at least δ/(2L). So each round removes, in expectation, at least the fraction δ/(2L) of the weight of such members, and the human's weight 2^(−K) is never removed." [assumptions.md]
5. The ideas of R1 (full proof), R7 (full proof), R3 (full proof), Ab1 (full proof), Ab2, Pr5, Pr7 and N8 convey the idea. Pr5's is the best in the note.

### F22 (MINOR). Tables whose cells are unclear

1. Section 5.1, lines 286 to 290. Column heads "member per run" and "member for good" need one line of explanation under the table. Cells: "no gain in the examples (R5)" should say against what: "tolerance of faults is not used: failure at least 0.11·L/n in the example (R5)". "the same (R5)": "likewise (R5)". "no bound; with recorded runs, H1": "no bound in K, L and n is possible (example after R4); with recorded runs √(K ln 2/(2N)) (H1)". "squared weights: R6c; otherwise no bound; with recorded runs, H2": "H² < L·(28·K ln 2 + 40·ln(1/δ))/n with squared weights (R6(c)); a posterior draw or the member of largest posterior weight: no bound (Examples 3.1, 3.6); with recorded runs, H2". [one-mind.md]
2. Section 7.4, Ab4, lines 422 to 427. Column heads "can be had", "cannot be had": write "upper bound (a rule that achieves it)" and "lower bound (for every rule)". Row labels are fragments: "open system; Thr_η, audits at rate q, abstentions answered" should be "open system; the human is asked with probability q and answers every abstention; rule Thr_η"; "every answer shown, at most k wrong" should be "the human's answer is shown after every prediction; at most k wrong predictions". The last row uses σ and a for probabilities that have other meanings elsewhere. [shift-abstain.md]
3. Section 7.4, rocks and whitelists, lines 433 to 440. "refuses at least", "refuses at most": write "refuses every x with" and "refuses only x with". One cell is empty and one says "unknown"; say "all inputs (no bound)" and "not known". [shift-abstain.md]
4. Section 11, line 659. Last column head "runs with an unfaithful call, average over 6400 rounds": write "fraction of the 6400 rehearsal runs with an unfaithful call (the failure rate of the deployed imitator)". [toy.md]
5. The tables of Sections 9.1 and 10 are clear.

### F23 (MINOR). The note does not say in plain words what becomes of his own objection to the property idea [property-online.md; property-batch.md]

Line 450: "The researcher proposed that a good imitator keeps the properties the answers had so far, and objected: at a new input some such property must break. This section says what survives." Line 470: "The researcher's conflict is thereby confined, not removed: two tests that held on all data and clash on a new kind of input need only keep the human's frequencies, as the human system does."

Line 470 is about recorded runs, and I read it twice. For Pr5 and Pr6, which are the answer that he will look for, nothing is said. Paragraph to add after Pr5: "The researcher's objection was that at a new input two properties that held so far can contradict each other. Here that costs one unit. The rule gives the answer that the weighted books prefer; the human's answer then shows which of the two properties the human breaks; and a book records only differences between the imitator and the human. A property that the human keeps for ever is broken by the imitator at most log₂(1/π(B)) + 2 times in all. A property that the human breaks at the new input was not one to keep, and only its frequency is matched."

Section 8.3 (the batch estimator) does not say why it belongs to the property idea. Sentence to add: "The estimate keeps the frequencies of the tests A_νν′, one for each pair of hypotheses, and this is enough for closeness in total variation to the best hypothesis."

A second objection of his is not addressed. According to the digest (Section 2.5) he calls the case of a computable criterion in hand "mathematically silly" and holds that the interesting properties "often cannot be explicitly defined". Pr5 answers the first half: the family can contain every decidable property at once, each at the price of its program, so the criterion need not be chosen in advance. For the second half the note should say what follows from its own Section 8.5: "The guarantee reaches as far as the family. A property that no short program decides has no cheap test; the test that always fits, 'the answer is what this human would give', costs K again (Section 8.4, a class as tests)."

### F24 (MINOR). Answer 5: two qualifiers and a pointer [intro.md]

Line 26: "It is not imitation: a fair coin matches every test frequency that a sample can resolve and is far from a deterministic human; tests of single answers do not control whole runs; properties outside the family are not kept (Section 8.5). And Solomonoff induction on ordinary data need not keep even a simple property: in a class with memorisers the mixture violates one with probability above 1/2 for about K divided by the bits per pair questions (Pr2)."

(a) The coin example (line 473) holds "For all but a fraction δ of the functions", that is, for a typical function on u inputs. Write: "for most deterministic humans, in the sense of most functions on a large set of inputs, a fair coin matches every test frequency that a sample can resolve, and it differs from the human at half of the calls". (b) The coin example is in Section 8.2, not 8.5; write "(Sections 8.2 and 8.5)". (c) Pr2(b) is for a class built with memorisers and Pr2(c) for some universal machines; open question 9 says that the matter is "open for any fixed one that would be called natural". Write: "And the mixture need not keep even a simple property at its own price: in a class with memorisers, and on some universal machines, it violates one with probability above 1/2 for the first K/b questions (Pr2); for a fixed natural machine this is open."

### F25 (MINOR). Labels that confuse a reader who follows them [hellinger-runs.md; lower-bounds.md; related-work.md; toy.md]

The consistency report covers labels; I list only what stopped me. (a) Two different statements are called N6: line 122 (more than L·K/(8·10⁴·ε²) answers, K ≥ 8, L a multiple of K, ε ≤ 1/65) and line 234 (n ≥ L·K/(8192·ε²), ε ≤ 1/64). (b) S2 is cited and never stated (F20, item 13). (c) "Theorem B" and "Theorem A" in line 679. (d) Section 11 (line 665) uses "the bound of Proposition R6(a), L times the number of functions heavier than f"; R6(a) is stated as L·(2^K − 1). (e) R6(c) is "not independently checked" in line 274 and "checked by one reader besides its author" in line 707.

### F26 (MINOR). There is no list of references [assemble.py; related-work.md]

Line 719: "(The list is being consolidated.)" The note cites about seventy works by author and year. For a reader who does not know the imitation-learning literature, "Li and Zhang (2025)", "Christiano 2016a", "Xu 2020" or "Farina and Perdomo 2026" cannot be found. The outline requires "a full citation". `README.md` names a file `references.md` that does not exist in the folder. `ultranatural/note.md` is given relative to the root of the repository, all other paths relative to the project folder.

## Part G. Question (4): is the honest bottom line stated plainly and early enough?

Plainly: yes, in most places. Early enough: not quite. Completely: no.

*Where the theorems are empty.* The note says it in his own manner, with numbers, and does not soften it: answer 7 ("There the bounds are empty: at an hour per answer a working life pays for about 1.4·10³ bits at θ = δ = 0.1, and if one answer is a year of work it pays for less than one bit"), Section 3.1 ("It is empty for n below L·K ln 2"), and again in Sections 3.2, 5.1, 5.2, 6, 7.2, 8.1, 8.4 and 9.1. This is the strongest feature of the note for this reader. The outline (correction 5) asks that it be said in each place where a bound is stated. It is missing in five: answer 1 of Section 0, where the theorem is announced; R3 (line 136); Ab1 (line 384); I1 (F6); and E1 (line 595).

*What is merely standard.* Section 2 ("None of this is new") and the first sentence of Section 12 are plain. Section 0 says it for answer 1 only. It does not say it for answer 5 (the method of Pr5 is Blackwell's approachability, line 537) nor for the limits of answer 4 (N1 is "the standard two-point argument", N4 is standard, the core of N2 is the star-number argument).

*What remains a bet.* Section 9 has this title and no list of the bets. In Section 0 the word "bet" occurs once, for I1, which is the bet that leaves K where it is (F6). The main bet, that a prior can be had under which the human costs an affordable K, is stated plainly only in Section 13, question 1: "Nothing here says how to obtain a prior that puts weight 2^(−K) on a given person with K in the thousands and not in the billions, nor how to tell that one has it."

### F7 (MINOR). The bottom line comes in the seventh answer and is incomplete [intro.md; assumptions.md]

Line 13 opens the answers: "**A protocol with a theorem exists for computations that can be run in advance**". That the bound is empty for a person follows six answers later. A reader who reads the whole page is not misled, but the order puts the offer first and the price last, and the outline says "do not advertise". Five limits that the note establishes are not in answer 7: the human reads what the imitator wrote (F5); the failures of the rehearsed mixture are silent (F3); the tolerance of faults is assumed and never tested (line 619); one person who answers n questions remembers them, so that "A1 for the rehearsal then needs a fresh person per question, and what is imitated is a pool" (line 50); and nothing says how to obtain a prior with an affordable K (line 695).

Proposed paragraph between "**The answers.**" and answer 1: "*In short.* Asking the human again on the inputs that the imitator's own runs produce works, with a theorem, for a computation that can be run in advance, and all the asking can be done beforehand; in its core this is a known algorithm. The price is of the order of L·K/δ answers, where 2^(−K) is the prior weight of the human, and in the worst case no protocol does much better. For a person, under a prior that does not already know the person, K is of the order of 10⁹ bits, and every bound on imitation in this note is empty. What can be afforded is a guarantee for each simple property that the human keeps, a check of a given imitator of a human who is nearly deterministic, and imitation under a prior that already holds the human within a few thousand bits; nothing here says how to obtain such a prior. The imitator is not a copy of the person, and its failures are not marked. Most statements are instances or variants of published results; Section 12 says which."

Sentence to add to answer 1, after the bound of R2: "For a person under a generic prior both bounds are empty (answer 7)."

Sentences to add to the answer on what the protocol does not give: "One person who answers n questions remembers them; rehearsal then needs a fresh person for each question, and what is imitated is a pool of people (Section 1). That the human system tolerates replaced answers is assumed and never tested (Section 9.5)." (For the other three limits see F3, F5 and F16.)

Proposed opening of Section 9, after line 563: "Four things are bets: the theorems assume them, and no data of the protocol can confirm them. (1) That a prior can be had under which the human costs an affordable K; nothing here says how to obtain one, or how to tell that one has it (Section 13, question 1). (2) That the human system tolerates replaced answers, which R3 assumes and the protocol never tests. (3) That what the prior says is acceptable on inputs that rehearsal met less often than about once in n rounds (Section 9.2). (4) That the human answers without memory, as A1 says. A fifth bet, on a class without patches, changes the rate and not K (Section 9.2)."

## Part H. Question (5): the seven tests

The verdicts of Section 10 are honest. Two are "not passed" and one is "outside the theorems", and the table says so. I asked two questions of each verdict: is it justified by what the note proves, and would he accept it.

| test | verdict in the note | what supports it | would he accept it? |
|---|---|---|---|
| 1 guard | "passed for each property fixed in advance; for all at once only at the price K" | R7, with a full proof in the note; R1; N1 | The paragraph, yes. The word "passed", no (F27). |
| 2 machine | "the rates are the scheme's; K, rare inputs and every route to a small K are the machine's" | R7 and V1(a) mention no machine (in the note); the behaviour at rare inputs by pointer to "Paper 1, Proposition 8.2" and Proposition 7.1 | Yes. It agrees with his own remark that some programming language gives the bad behaviour the better constant. |
| 3 referent | "passed under A3, as far as R1 is not empty" | Theorem 3.2(b), (c) and Remark 3.2a of the proof file, by pointer only; the note states only part (a), as R7 | The paragraph, yes. The cell, no: for a person R1 is empty (F28). |
| 4 copy | "not passed" | Section 9.4, four sentences; Propositions 7.8 to 7.10 by pointer | Yes. But the paragraph has two sentences and leaves out what the note proves on the second half of the test (F29). |
| 5 budget | "not passed" | Section 9.1 with its table; N2b; N8; V1 | Yes. |
| 6 rock | "not a rock; its failures are silent" | Section 7 | Yes; this paragraph is the clearest statement in the note on failing obviously. One sentence changes with F4. |
| 7 horizon | "outside the theorems" | N8; the assumption of R3 | Yes. The digest says of this test that it is outside a theorem about the learner "and he knows it". |

### F27 (MINOR). Test 1: "passed" says more than R7 gives [assumptions.md]

Line 629: "| 1 guard | passed for each property fixed in advance; for all at once only at the price K |". Line 637: "Decomposition creates none, since rehearsal runs go to full depth."

The test asks what the scheme does at an input with a property that no training input has, and with what probability. R7 bounds how often a deployed run meets a property fixed in advance without the human having been asked about it. What the scheme does there is, as the paragraph says, "the prior's". So the test is met in frequency, for properties of up to about log₂(δn/L) bits (F13), and not at the input. Two more points. "Decomposition creates none" is too absolute: a kind of call that runs make less often than about once in n rounds is created by decomposition and is probably never asked (the note says this in line 338). And the proof file's verdict (`proofs/assumptions.md`, Section 5, table) ends "not passed outside a closed deployment", which the note dropped; his exception "now" (digest, F4) is excluded by condition C3 and not answered, and the note should say so.

Proposed cell: "met in frequency: a property fixed in advance is met unasked with probability at most L/n, and what is done there is the prior's choice; all properties at once only at the price K; not met outside a closed deployment". Replacement for the sentence of line 637: "Decomposition creates no property that separates the calls of a deployed run from the asked calls in distribution, since rehearsal runs go to full depth (S4(i)); a kind of call that runs make less often than about once in n rounds is still probably never asked." Sentence to add at the end of the paragraph: "Outside a closed deployment the test is failed: a date in the inputs, or a task that is not a draw from the rehearsed law, leaves the guard unrefuted (Examples 3.4, 3.5). The exception 'now' of the researcher's notes is excluded by C3, not answered." (Examples 3.4 and 3.5 are cited from the summary in O10 of the proof file; I did not read them.)

### F28 (MINOR). Test 3: for a person the verdict is "not passed", and the two facts behind it are not stated in the note [assumptions.md]

Line 631: "| 3 referent | passed under A3, as far as R1 is not empty |". Line 641: "tables of the data outweigh the human until the questions carry more than K bits, and until then the imitator answers unasked inputs as the tables do (Remark 3.2a). So the test is passed exactly as far as R1 is not empty."

The paragraph is right, and its last two sentences are the plainest account in the note of why n below K is empty; they deserve a place in Section 3.1 as well. But for the person about whom he asked, R1 is empty, and the cell should say what follows: "passed under A3 where R1 is not empty; for a person R1 is empty and the test is not passed". The verdict rests on two statements that the note gives only inside this paragraph, by pointer: a hypothesis that deviates from the human on the mixtures' runs loses weight at the rate of its deviation there, and a prior fixed first gives the hypothesis that knows the realised coins at most the probability of guessing them (Theorem 3.2(b), (c) of the proof file). A test that he applies to every proposal should rest on statements made in the note; two sentences in Section 9, with their status, would do.

Hypotheses that act with intent (the digest's F11, which stands in the group of this test, and F14, "a deceptive outer loop") are treated in Section 12 only ("the reason to treat unfaithful calls as adversarial"). Sentence to add to this paragraph, after the proof file's O11: "Hypotheses that act with intent cannot break R1 and cannot aim at the calls that are not asked, because the asked call is drawn after the run; they can choose what the unfaithful calls say, which is why R3 counts those calls as an adversary's."

### F29 (MINOR). Tests 4, 5 and 6, and what the tests are applied to [assumptions.md]

(a) Test 4, line 643: "No (Section 9.4). The deployed object is the Bayes predictor of the human." The verdict stands. The paragraph should add what the note proves about the second half of the test: with one answer per input the sampler and the sampler with coins filled in cannot be told apart (Pr7); a posterior draw is then such a filled-in sampler with constant probability (the example after R4; H2 at λ = 1); the weights w^λ with λ > 1 select the sampler, for the laws of runs on one scaffold (H2, R6(c)). It should also say that the robustness of recovering the sampler, which according to the digest he called "the ideal theorem", is not obtained beyond that. See F2.

(b) Test 5, line 645: "those of the early rounds being the prior's" cannot be understood without F5. The proof file (O22) has a number that would serve him better than any sentence: at θ = δ = 0.1, with the certificate, rehearsal costs fewer answers than one run by the human only if L exceeds 2.4·10³ for K = 30 bits and 7.0·10⁴ for K = 10³. (I recomputed both: (K ln 2 + ln 20)/(θδ).) Section 9.1 could carry this as a fourth column of its table.

(c) Test 6: see F4 for the one sentence that changes.

(d) Line 625: "Verdicts are for the protocol of Section 2 in a closed deployment." The imitator built from tests (Pr6) is his own idea made exact, and it is not put to the tests. Its verdicts differ: the budget is affordable for properties of low price; the guard is met for each property at its price; it is not a copy and not even a sampler ("A choice, not a sample", line 532); it acts everywhere. Three sentences, or a third column, would answer the question he will ask.

(e) For the attribution of the tests see F14.

## Part I. Question (6): the style rules of the outline

The note follows most of the rules. It has no decoration, it uses tables for comparisons, it states what is assumed, and "What it does not say" after each main statement is the best habit of the text. The worst violations:

### F30 (MINOR). Fragments in the place of sentences, where the reader most needs sentences [intro.md; assumptions.md; one-mind.md; property-online.md]

The outline: "Plain words. ... Full sentences."

1. Line 22: "Inputs from outside the rehearsed law cost the density ratio; N possible shifts cost a factor N; all shifts describable in ℓ bits cost 2^ℓ (S1 to S3, N3)." Replacement: "If the tasks of deployment are drawn from another law than the tasks of rehearsal, every bound is multiplied by the largest ratio of the two laws (S1). To be prepared for N possible laws costs a factor N in the worst case, and for all laws that a program of ℓ bits can sample about 2^ℓ (S2, S3, N3)."
2. Lines 611 to 617, the seven objections. Each is a fragment that depends on a quotation eight lines above: "*K* (9.1): to "works from a reasonable number of answers", for a person;", "*long episodes:* on the researcher's numbers, unless scaffolds of short calls do research;". Replacement: "*K.* For a person the number of answers is not reasonable (Section 9.1). *Critical steps.* For some scaffolds and classes no protocol amplifies work whose single steps decide the result, whether the steps are replicated or not (N2, N8). *Long episodes.* If an episode that can do research takes a year, as the researcher expects, the budget is not met; it is met only if scaffolds of short calls can do research. *Not a person.* The protocol imitates one computation fixed in advance; it is not an upload. *Silent failures.* An imitator that fails only obviously cannot be had at an affordable price without a further assumption (Section 7). *The human reads what the imitator wrote.* (The paragraph of F5.) *The human is a sampler.* For a human who varies, no certificate without K bounds the number of unfaithful calls (V1)."
3. Line 619: "(a pool of people; a late random round; physical coins)". Each item answers an objection that the note has not stated. Replacement (*, my reading of O10, O12 and O19 of the proof file): "A pool of people answers the objection that one person remembers the questions. A deployed round drawn from the later rounds answers the objection that a uniformly chosen round is often an early one. Physical coins answer the objection that a hypothesis could compute the coins of the protocol."
4. Line 284: "*What it does not say.* Which member is selected (Section 9)." Line 535: "**Outside the closed system** nothing (Theorem N1)." Line 282: "(b) An Occam bound in martingale form." Each should be a sentence.
5. Line 609: "Section 8 of the proof file classes twenty-two objections". The reader is told the number and shown seven; say in one sentence what the other fifteen are about, or drop the number.

### F31 (WORDING). "Lead with the result" and "one main statement per numbered theorem"

1. One number, several statements: R6 has three statements with different hypotheses and different checking status (line 274); Ab2 has four (lines 396 to 402); V1 three; N7 a lower bound and an algorithm; Pr2 is three labelled paragraphs and an unlabelled "What holds". A reader who is told "by R6" cannot know which statement is meant; Section 0 cites "(R6)" for (b) only.
2. Statements that begin with a construction and reach the result late: N2, N2b, N5, N8, R5, Pr2(b), Pr2(c), and Rule NH before Pr5. The result can come first: "**Theorem N2.** For some scaffold of L calls and some class of ⌈L/(2δ)⌉ + 1 functions, every protocol whose deployed run fails with probability at most δ for every member asks at least L/(4δ) − 3L/2 questions. *The class and the scaffold.* ...". For Pr5: state the theorem "for the rule given below", then the rule.
3. Section 1 gives the caveats on the assumptions before the protocol and the theorems (F20, item 3).

### F32 (WORDING). Hedges and flat statements

1. Line 108: "In (a) the constant can be 2.9642 and cannot be below 2.9639". Section 12 (line 689) says that the lower value comes from "an example with ratio 2.9639, computed in floating point", and gives the upper value as 2.9641; line 715 has 2.9642. State one upper value, and put the hedge where the uncertainty is: "an example, computed in floating point, has the ratio 2.9639".
2. The order of K for a person is given in four forms: "of the order of 10⁹ bits or more" (line 30), "of the order of 10⁹ bits" (90, 252, 454), "K near 10⁹ bits" (120, 246), "in the thousands and not in the billions" (695). Use one form; the hedge belongs in Section 9.1, where the source is given.
3. Marks of unfinished checking stand in the text: "Langford 2005, quoted from memory" (462), "Littlestone from memory" (537), "from secondary sources" (575), "standard facts, not proved here, not independently checked" (543). They are honest. Use one formula for all ("not read in the source"), or check the sources.

### F33 (WORDING). Small points

1. Lines 248 and 250: the headings of Section 5 and of Section 5.1 are the same.
2. The label after a statement is "What it does not say" in Sections 3 to 7 and 9, "Not said" in Section 8, and "What S1 does not say" once; the sketch is "Idea", "Ideas" or "Idea of the proof".
3. Line 595: "K the weight of that function" should be "2^(−K) the weight of that function".
4. Line 28: "the mixture stays free on the inputs that decomposition produces" should be "the data do not constrain the mixture on the inputs that only decomposition produces". The heading "Solomonoff induction is enough only together with rehearsal" says "enough" of a bound that is empty for a person; see F2 for a replacement.
5. Line 108: "Foster, Kakade, Qian and Rakhlin 2021, Lemma A.13, have 10²·log n" should be "prove it with the constant 100·log n".
6. Line 667: for L = 16 the second system tolerates no fault, since 5% of 16 is less than 1; its 0.11% is the first system's 0.1%. Say so, or start the comparison at L = 256.
7. Line 5: "Every numbered statement says whether it is proved here, standard, or open." S2 has no statement, and Pr1 is "(a definition)".

### F34 (WORDING). README.md repeats the summary sentences of Section 0

`README.md`, "Answers in brief", has the sentences of F1 (answer 5, without the human in the loop), F8 ("In general nothing does better"), F10, F14(a) ("the tests that the researcher applies to any such scheme") and F15 ("Every bound is in K"), and announces `references.md` (F26). It is not generated from the section sources and needs the same corrections by hand.

## Part J. List of findings

Grades: MAJOR (misleads the reader, or leaves his question unanswered), MINOR, WORDING. "Where" gives the lines of `note.md` and the section source to edit. The full text of each finding, with the exact sentences and the replacements, is in Parts D to I.

| no. | grade | where | finding | fix |
|---|---|---|---|---|
| F1 | MAJOR | Section 0, answer 5, line 26 [intro.md]; README | The sentence on Pr5 reads as a guarantee on any sequence of questions with no human present; in Pr5 the human answers every round. "No assumption about the human" is too strong for the deployed form Pr6, which needs A3 and A1 at the asked calls. | Say that Pr5 holds while the human answers every question, and that after the human has left the guarantee is Pr6, for the rehearsed system; replace "no assumption about the human" by "without assuming that the human belongs to a class"; name the method as Blackwell's approachability. Text in Part D. |
| F2 | MAJOR | Section 0, answer 6, line 28, and line 30 [intro.md]; Section 10, test 4 [assumptions.md] | "It is not possible for a human who varies, unless whole runs ... are recorded" contradicts R6(c) (line 280). The δ is unexplained; the pointer to Section 5 is wrong for the first claim; the answer on copy or predictor is half a sentence although Sections 5, 8.7 and 9.4 have a three-part answer, including that his own steeper prior works (H2, R6(c)). | Split answer 6 into "Solomonoff induction on ordinary questions" and "Copy or predictor"; texts in Part D. Add his wish to the question paragraph. Extend test 4. |
| F3 | MAJOR | Section 0, answer 4, fourth bullet, line 23 [intro.md] | The only sentence of Section 0 on failing obviously uses four undefined terms and cannot be read cold. The plain verdict is in Section 10, test 6. Ab1(b) and Ab2(a) are not in Section 0. | Give the subject its own answer; text in Part D. |
| F4 | MAJOR | Section 7.4; line 647; line 681; Section 13, question 8 [shift-abstain.md; assumptions.md; related-work.md; intro.md; open.md] | He asked for "basically only fails obviously". Section 7 studies rules that are never silently wrong and concludes that sound rules are rocks and whitelists are bets. The theorem quoted in Section 12 (Goldwasser et al. 2020, Theorems 5.2, 5.3; read in the source in this session) gives a small rate of silent errors on arbitrary inputs, rejections bounded on the training law, no further questions, at a cost polynomial in the VC dimension, for binary deterministic labels and test inputs known in advance. The note says only "The note has no counterpart". | Work out the counterpart, or add the paragraph "Between the rock and the bet" to Section 7.4 and change line 647 and Section 0 accordingly; texts in Part D. |
| F5 | MAJOR | Section 9.5, line 616; Section 0 [assumptions.md; intro.md] | "The human reads what the prior wrote" is one of seven objections called fatal, is stated once, in one line of a list, and is not in Section 0. In rehearsal the human reads questions written by the mixture's runs, in the early rounds the prior's; harm to the reader is a failure of the kind he calls insane. | Add the paragraph "The human reads what the imitator wrote" to Section 9.5 and one sentence to Section 0; texts in Part D. |
| F6 | MAJOR | Section 0, answer 7, line 30; Section 9.2, line 589; Section 13, question 2 [intro.md; assumptions.md; open.md] | "A faster route is a bet" follows the statement that the bounds are empty and reads as a way out. I1's bound 2^K·(1−δ/(2L))^n says nothing before n exceeds 2L·K ln 2/δ: it changes the rate and keeps K. The note does not say so, against correction 5 of the outline. | Texts in Part D: say that the bet buys ln(1/ε) in the place of 1/ε and no smaller K, in all three places. |
| F7 | MINOR | Section 0, lines 11 to 30; Section 9, line 563 [intro.md; assumptions.md] | The answers open with "A protocol with a theorem exists"; emptiness for a person comes in the seventh answer. Five limits are missing from answer 7. Section 9 does not list the bets; the main bet is stated plainly only in Section 13, question 1. | Add the paragraph "In short" before answer 1, one sentence to answer 1, two to answer 7, and a list of the bets at the head of Section 9; texts in Part G. |
| F8 | MINOR | Section 0, answer 4, heading, line 19 [intro.md] | "In general nothing does better" overstates: a logarithm is saved by chosen questions (N2c), a factor of order L/ε on one class (line 220), and for work without critical answers the only lower bound is about K (line 701). | "In the worst case over classes no protocol does much better", with two sentences; text in Part E. |
| F9 | MINOR | Section 0, answer 4, second bullet, line 21 [intro.md] | The quantifier of N2 is wrong (one scaffold and one class, not every scaffold with L critical calls); L/(4δ) − L needs an integer L/(2δ); "reuse" is given without the price that N2d states (Section 4.6), and N2d is not in Section 0. | Text in Part E. |
| F10 | MINOR | Section 0, answer 3, heading, line 17 [intro.md] | "The price does not grow with the computation" holds for a fixed fraction θ of replaceable answers; the tolerance is assumed and never tested, and under replication 1/θ counts the critical units (N8). | New heading and one sentence; text in Part E. |
| F11 | MINOR | Section 0, answer 4, last bullet, line 24; Section 3.6 [intro.md; rehearsal-core.md] | "In an open system the human cannot leave early" is a general claim from one class and one sequence. S5, the re-querying idea in its online form and the strongest statement on shift, is not in Section 0. | Text in Part E. |
| F12 | MINOR | Section 0, answer 1 [intro.md] | The direct answer on the shift that decomposition produces, S4(i), and his main obstruction, the guard, are not named in Section 0. | Three sentences for answer 1; text in Part E. |
| F13 | MINOR | Section 3.3, lines 126 to 130; Section 0, line 15 [rehearsal-core.md; intro.md] | R7 is not given in bits (all properties of fewer than log₂(δn/L) bits at once); "What it does not say" omits that one question in a region says nothing about the answers there; coverage is called a check; the argument is his own random-stopping argument and is not credited. | Four additions; texts in Part E. |
| F14 | MINOR | Section 10, line 625; Section 7.3, line 412 [assumptions.md; shift-abstain.md]; README | The seven tests and "Observation B" are attributed to the researcher's notes; the digest marks both as its author's derivation. | Replacements in Part E. |
| F15 | MINOR | lines 30, 695, 621 [intro.md; open.md; assumptions.md] | "Every bound is in K" and "Every positive result is in K" contradict R7, V1, Pr5, Pr6; "What survives" omits the guarantees without K. | "Every bound on imitation is in K"; one sentence for "What survives"; text in Part E. |
| F16 | MINOR | Section 1, line 38; Section 9.1 [rehearsal-core.md; assumptions.md] | What K is on the inputs of the scaffold, and what a prior built from knowledge can buy, is plain only in the proof files (Remark 4.4(d); Proposition 2.4). | Replacement for line 38 and two sentences for Section 9.1; texts in Part E. |
| F17 | MINOR | Section 7, first use line 400 [shift-abstain.md] | sep(x; A) is never defined. | One sentence at the head of Section 7; text in Part F. |
| F18 | MINOR | 25 terms, listed in Part F | Terms and symbols used before definition or never defined: human system, unfaithful calls, test, open system, memorisers, patches, Protocol R, Protocol AB, Rule NH, rocks, needle class, driver, the normalisation of H², K(Q), Paper 1 and 2, Theorem A and B, S2, and others. | One line each; table in Part F. |
| F19 | MINOR | throughout | Letters with several meanings: A, Q, ρ, s, σ, a, δ, β, N, Γ, η. A and Q are the worst. | Rename four; proposal in Part F. |
| F20 | MINOR | 20 passages, listed in Part F | Passages read twice or more, among them: the caveats of Section 1 placed before the protocol; Protocol AB (line 218); "Asking every call ... does not help" after an example for which it is false (line 262); S1(b); "What S2 needs"; the top set; Pr2(a); "sequential batches"; "the two bets". | Replacements in Part F. |
| F21 | MINOR | lines 108, 260, 282, 591 [hellinger-runs.md; one-mind.md; assumptions.md] | The ideas of L4, R4, R6(b), (c) and I1 do not convey the idea, or give none. | Replacements in Part F; for L4 the ten-line proof can be printed. |
| F22 | MINOR | lines 286 to 290, 422 to 427, 433 to 440, 659 | Unclear cells and heads in the tables of Sections 5.1, 7.4 (two tables) and 11. | Replacements in Part F. |
| F23 | MINOR | Section 8, lines 450, 470; Sections 8.3, 8.4 [property-online.md; property-batch.md] | The note does not say what becomes of his objection that properties contradict one another at a new input, nor of his objection that the interesting properties cannot be defined; Section 8.3 does not say why it belongs to the property idea. | Two paragraphs and one sentence; texts in Part F. |
| F24 | MINOR | Section 0, answer 5, line 26 [intro.md] | The coin example holds for most functions, not for "a deterministic human"; the pointer should include Section 8.2; "Solomonoff induction ... need not keep even a simple property" holds in a built class and on some universal machines and is open for a natural one. | Text in Part F. |
| F25 | MINOR | lines 122 and 234; 356; 679; 665; 274 and 707 | N6 names two statements; S2 is never stated; Theorem A and B; R6(a) used in a sharper form; the status of R6(c) differs. | As the consistency report directs. |
| F26 | MINOR | line 719 [assemble.py; related-work.md]; README | No list of references; README names a file that does not exist. | Print the list. |
| F27 | MINOR | Section 10, lines 629, 637 [assumptions.md] | Test 1: "passed" says more than R7 gives; "Decomposition creates none" is too absolute; the clause "not passed outside a closed deployment" of the proof file was dropped, and his exception "now" is excluded by C3, not answered. | New cell and two sentences; texts in Part H. |
| F28 | MINOR | Section 10, lines 631, 641 [assumptions.md] | Test 3: for a person R1 is empty and the verdict is "not passed"; the two facts behind the verdict are stated only by pointer; hypotheses that act with intent are in Section 12 only. | New cell, two sentences in Section 9, one sentence in the paragraph; texts in Part H. |
| F29 | MINOR | Section 10, lines 625, 643, 645 [assumptions.md] | Test 4 has two sentences and omits Pr7, H2, R6(c); test 5 has a cryptic clause and could give the break-even numbers; the imitator built from tests is not put to the tests. | Additions in Part H. |
| F30 | MINOR | lines 22, 611 to 619, 284, 535, 282, 609 | Fragments in the place of sentences, worst in the list of the seven fatal objections. | Replacements in Part I. |
| F31 | WORDING | R6, Ab2, V1, N7, Pr2; N2, N2b, N5, N8, R5, Pr5 | Several statements under one number; statements that begin with a construction. | Put the result first; one statement for each number. |
| F32 | WORDING | lines 108, 689, 715; 30, 90, 120; 462, 537, 543, 575 | The constant of L4 has two values and its lower limit is stated flatly although computed in floating point; the order of K has four forms; marks of unfinished checking in the text. | Part I. |
| F33 | WORDING | lines 248 and 250, 595, 28, 108, 667, 5 | Duplicate heading; changing labels; "K the weight"; "stays free"; "have 10²·log n"; the case L = 16 in Section 11; the claim of the status line. | Part I. |
| F34 | WORDING | README.md | The answers in brief repeat the sentences of F1, F8, F10, F14 and F15. | Correct by hand. |
