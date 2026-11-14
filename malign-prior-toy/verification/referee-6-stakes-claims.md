# Referee report 6 (claims) on Section 3.7, "Concentration where the most is at stake", and its summaries

Date: 2026-11-14. Version refereed: the working tree at commit `6b534400` ("circuit tables; the paper builds with both new sections"). I had not seen the note before.

**Under review.**

1. `paper/sec3b-stakes.tex` (Section 3.7 of the PDF, Proposition 16 to Proposition 23).
2. The passages that summarise it: the abstract bullet "Aiming at high stakes" (`paper/main.tex` 78-90); in `paper/sec1-intro.tex` the paragraph "Two further questions" (46-49), the results item "Concentration at high stakes" (112-130), and the sentences on Section 3.7 under "What is new and what is not" (184-191) and "What the toy does not settle" (214-216); in `paper/sec8-answers.tex` the paragraph "If the seekers concentrate ..." (94-127) and the seventh open item (239-241); in `README.md` the bullet "Concentration on high stakes" (28-34) and the line under "What is not settled" (62).

The source of the section is `research/stakes-final.md`.

**Lens.** What is claimed. For every sentence that states a conclusion I asked four things: which numbered result proves it; whether the scope is right (one seeker or all, mass of programs or block returned, reach or fate, toy or model or argument); whether the source lists it as dropped, narrowed or open; and whether it agrees with the rest of the note.

**Method.** Pencil and paper for every inequality. Python for arithmetic only: exact rational arithmetic for the constants of Example 21, a numerical optimiser against the closed forms of Proposition 22, and the small numerical illustrations quoted below. I ran no program that executes generated strings as programs. I changed no file except this report. Line numbers refer to the source files; (W1), (W2), (W3) are the three meanings of "they win" defined in the section.

## Verdict

The numbered statements of Section 3.7 are correct as stated, constants and directions of all ratios included, and the section keeps toy, model and argument apart in its statements. The errors are in what the prose and the summaries say the statements show. Three sentences are wrong as written: the abstract says that an aimed seeker outweighs the users of a class "however rare the class is", which reverses the condition (finding 1); the sentence on a test after Proposition 20 drops the conditioning on worlds that go on printing (finding 2); and the third reading of "run more than n times" is answered for a multiplier applied to every use, while the question is about a multiplier at some uses, where the optimal allocation does change (finding 3). The central overclaim is the use made of Example 21. What is proved there is that one attacker does not have the majority at *every* use of the class, and that fails in the far tail of the class for every n; for most of the class, which is what was asked, the example proves only a necessary condition on two constants, and for the block returned it proves nothing (findings 4 and 5). Two summary sentences read a bound on one seeker as the criterion for all written seekers (finding 6), and the verdict "not as stated", which the section and the source mark as an argument, is given flatly in Section 8 together with "the other half fails", which no result shows (finding 8). All four summaries drop "without resource bounds" (finding 9). With these corrected, the answer the note gives is the one its results support: aiming is cheap and beats the users; a lump heavier than everything else on those contexts is necessary; whether it is there is not decided by the toy.

---

## Findings

Severity: **error** (false as written), **overclaim**, **gap** (an assumption or an open point is missing), **unclear**, **minor**. Each finding is marked **[section]** or **[summary]**.

### 1. "However rare the class is" reverses the condition. error [summary]

**Where.** `paper/main.tex` 80.

**Sentence.** "It then outweighs the *users* of the class, however rare the class is."

**Problem.** By Theorem 18, at a use of the class the programs of a seeker of length `a` have at least `2^(-a) 2^(j-1)` times the mass of the users of the class, a factor in `(2^(-a-1)/H_W, 2^(-a)/H_W]`; under (INC) they have exactly that (Theorem 18(b)). So the seeker outweighs the users if `H_W <= 2^(-a-1)` and, under (INC), never if `H_W >= 2^(-a)`. It outweighs the users only of a class that is rare enough, and the sentence asserts it for every class. For the stake classes the length grows with n: by Proposition 19(a) and the exactness, the factor lies between `2^(-|v'|-7)/(n^2 j_n^2 C(W_n))` and `2^(-|v'|-2)/(n^2 j_n^2 C(W_n))`. A family of stake classes with `C(W_n)` of order `n^(-3/2)`, which has finite expected stake, is therefore never outweighed by this seeker (with `|v'| = 0` and `C(W_n) = n^(-3/2)/4` the factor stays below 0.004). With `C(W_n) = 2^(-n)` and `|v'| = 20` it is below 1 up to n = 46. Under a rule given by a test the seeker's programs are users and the factor is at most 1; if a simulated use counts as a use it is at most `2^(h-a)` (Proposition 20(c)). The README (29) and Section 8 (98-99) have the right form.

**Corrected text.** "It then outweighs the *users* of the class once the class is rarer than half the seeker's weight, and by more the rarer the class is; for the classes 'stake at least n' this needs a class rarer than about `n^(-2)`."

### 2. The reading of part (d) drops "that go on for m more bits". error [section]

**Where.** `paper/sec3b-stakes.tex` 277-278.

**Sentence.** "Under a test, by (d), 'most high-stake uses end in a takeover' says that most high-stake users are takeover programs."

**Problem.** Proposition 20(d) is for a world conditioned on handing over *and going on for m more bits*. Its two sides are averages of `theta(x)` with the weights `Z_m(x)`. "Most high-stake uses end in a takeover" is (W3), an average with the weights `C(x) = M_U(x)` (Definition 8, and the definition of (W3) in the section). The two differ wherever the share `Z_m(x)/M_U(x)` of users that go on varies with the context. Users that hand over and then print fewer than m bits receive a block all the same and have no own continuation; this is the first qualification after Theorem 9, and its omission was finding B9 of round 1. As arithmetic of the two weightings: with `M_U = (0.1, 0.9)`, `Z_m = (0.1, 0.009)` and `theta = (0.01, 0.99)` at two first hits, 89% of the uses end in a takeover and 9% of the users that go on are takeover programs.

**Corrected text.** "Under a test, by (d), among the high-stake users that go on for m more bits the share of uses that end in a takeover equals the share of users whose own continuation is a takeover block. Users that stop after the use receive a block all the same and are not covered: weighted by all users, as in (W3), the two shares differ by the factors `M_U(x)/Z_m(x)`."

### 3. The third reading is answered for a multiplier at every use; the question is about a multiplier at some uses. error [section], and through it [summary]

**Where.** `paper/sec3b-stakes.tex` 417-419. It is the basis of "only" in `paper/sec1-intro.tex` 129-130 and of "in one reading" in `README.md` 33 and `paper/sec8-answers.tex` 117-118.

**Sentence.** "A third reading, in which the block is run n times, multiplies stakes by n in the model and changes neither the optimal allocation (Proposition 22(b)) nor the conditions of Theorem 17."

**Problem.** The last sentence of Proposition 22(b) is for *every* stake multiplied by the same n. The question describes places at which the block is run more than n times, as against the other places. Then the stake per unit of rest of that class is multiplied by n, and the optimal allocation changes. By the two-class formulas quoted after Proposition 22, with `rho_1 = n rho_W` for the class and `rho_2 = rho_R` for the remainder, the whole weight goes to the class as long as `B <= O(W)(sqrt(n rho_W/rho_R) - 1)`, and the optimiser has the majority on the class iff `B > O(W) + O(R)(2 sqrt(rho_R/(n rho_W)) - 1)_+`, which is `B > O(W)` once `n >= 4 rho_R/rho_W`. This is Proposition 14(2) of the source, and the paper leaves it out. Numbers: `O(W) = 0.1`, `O(R) = 1`, equal stake per unit of rest before, `B = 0.3`. For n = 1 the share is 0.21 everywhere; for n = 4 it is 0.57 on the class; for n >= 16 it is 0.75 on the class and 0 elsewhere. What does not change is the second half of the sentence: the weight a majority on the class costs is its rest, whatever n. So in the model this reading is the one in which the picture of the question is right: more runs at a class draw the stake-maximiser's weight to it, and it has the majority there iff its weight exceeds the rest of the class.

**Corrected text.** "A third reading, in which the block is run n times, changes stakes only, and is a statement of the model. If every stake is multiplied by n, the optimal allocation and all shares are unchanged (Proposition 22(b)). If only the uses of a class W are multiplied, the stake per unit of rest of W is multiplied by n and the optimal allocation moves to W: in the two-class case above, with `rho_1 = n rho_W`, the whole weight goes to W while `B <= O(W)(sqrt(n rho_W/rho_R) - 1)`, and the optimiser has the majority on W iff `B > O(W) + O(R)(2 sqrt(rho_R/(n rho_W)) - 1)_+`, which is `B > O(W)` for `n >= 4 rho_R/rho_W`. The conditions of Theorem 17 do not contain the stake: n changes where a stake-maximiser puts its weight, not the weight a majority costs."

The summaries should then say: "running the block n times at a class changes where a stake-maximiser puts its weight (in the model), not the weight a majority there costs."

### 4. Example 21 is "not won" only in the sense (W1), for one attacker; the question is about most cases and about the block returned. overclaim [section] and [summary]

**Where.** `paper/sec3b-stakes.tex` 279 (title "... and not won"), 301-306, 313-318, 462-464; `paper/sec1-intro.tex` 125-127; `paper/sec8-answers.tex` 109-111; `README.md` 31.

**What is proved.** Item (e): for `n >= 2^(|v_D|-|v_A|+2)` the weight of `F_n` is below the rest of the class, so `F_n` does not have the majority at every use of `W_n`. I confirm the constants of (a) to (f).

**Problem.** Three things limit what this shows, and the text states none of them.

* *(W1) fails for every n, in the far tail, and the lump plays no part.* At `x_(n+i)` the attacker has `2^(-|v_A|-|e(n)|-i-1)` and the programs of `Ho` have `2^(-|v_D|-|e(n+i)|)`. The first falls like `2^(-i)`, the second like `i^(-2)`. So for every n the attacker is below `Ho` at all `x_(n+i)` beyond some i (for `|v_D|-|v_A| = 18` and n = 2: from i = 23 on, where (e) would need `n >= 2^20`). These uses carry a share `2^(-i)` of the class. "For large n" is therefore not where the content of (e) lies, and "cannot have the majority at every use" is true of this attacker however much it outweighs the users.
* *For most of the class nothing is decided.* Take `(|u|, |v_A|, |v_D|, n) = (10, 12, 20, 1024)`, to which (e) applies. If the rest were equal to the lower bound of (d), which is all that is proved, `F_n` would have the share 0.992 at `x_n`, the majority at uses that carry 99.2% of the class, and an average share of 0.97. So the proved statements of the example are compatible with (W2) and (W3) holding. What the example proves about most of the class is the last sentence of (e) alone: since `x_n` carries exactly half the class, `F_n` has the majority at uses that make up more than half of `W_n` only if `|v_A|+1 < |v_D|`.
* *It is about one attacker's supply, not about the block.* The machine that reads `e(k)` and prints `x_k 1^infinity` has weight `2^(-c'-|e(k)|)` at `x_k`, of the same order as `Ho`. So takeover programs and honest printers are each polynomially heavy at every context of the class, these two families differ at every `x_k` by a constant factor only, and the example does not show that the uses of `W_n` are not taken over. The paragraph after the example draws the right conclusion ("the hypothesis does not decide who supplies the block"); the title and the summaries say more.

**Corrected text.** Title: "A class of mass `2^(-n)`, aimed at with `2 log_2 n` bits: outweighing the users decides nothing". Add after (e) or in the paragraph after the example: "Item (e) refutes (W1) only, and for this attacker it fails for every n, at the uses `x_(n+i)` with large i, which carry a share `2^(-i)` of the class. The attacker has the majority at more than half of the class only if `|v_A|+1 < |v_D|`; (W2) and (W3) are otherwise not decided, and nothing is shown about the block returned, since the machine that reads `e(k)` and prints `x_k 1^infinity` is as heavy as `Ho` up to a constant." In the closing paragraph (462-464) and in the three summaries replace "still cannot have the majority at every use" by: "and it has the majority at most of the class only if a condition on two constants of the machine holds, in which n does not occur; whether it has is not decided."

### 5. "Decided by two constants in which n does not occur" is a necessary condition, and n does occur in the rest. overclaim [summary]

**Where.** `README.md` 31; `paper/sec8-answers.tex` 111-112. (The source has the same wording in item 3 of its plain answer.)

**Sentence.** "... who supplies the block at the main context is decided by two constants of the machine in which n does not occur."

**Problem.** Item (e) says "only if `|v_A|+1 < |v_D|`", and the paragraph after the example says that only a lower bound on the rest is proved. The summaries turn the necessary condition into the criterion. It is not the criterion. For `n = 2^k`, a machine that reads `e(k)` and prints `x_n 0^infinity` has weight `2^(-c''-|e(k)|)` at `x_n`, against the attacker's `2^(-|v_A|-|e(n)|-1)`, and `|e(n)|-|e(k)| = 2k - 2 floor(log_2 k)` is unbounded (14 bits at n = 1024). For all large n of this form the attacker loses at `x_n` whatever `|v_D|` is.

**Corrected text.** "... at the context that carries half the class the seeker has the majority only if `|v_A|+1 < |v_D|`, a condition on two constants of the machine in which n does not occur. The condition is necessary and not sufficient: only a lower bound on the rest is proved."

### 6. A necessary condition for one seeker is read as the criterion for written seekers. overclaim [summary] and [section]

**Where.** `README.md` 34; `paper/sec8-answers.tex` 125-127; `paper/sec3b-stakes.tex` 473-476.

**Sentences.** README and Section 8: "... the comparison that decides the outcome: the takeover programs against everything else that prints those contexts and goes on. For written seekers that is a comparison of description lengths in which no stake occurs." Section: "For a seeker that is written down this is a comparison of description lengths in which no stake occurs: ..."

**Problem.** Proposition 20(a) gives, for one seeker and where the users go on, `w_F <= 1/(1+2^(a-h))`. So "shorter than its twin" is necessary for that seeker's majority, and by 20(b) the difference `h-a` does not contain the aim for one uniform pair of constructions. Three things are not proved.

* *Sufficiency.* The seeker must outweigh its whole rest: the twin, the users, the wrapped copies, and everything else that prints the context. In the last of these the class does occur (finding 5).
* *All written seekers.* Seekers with the same search and different payloads have one twin between them, and their masses add; the note says so itself in "Three limits of this bound" in Section 3.5. The bound is on supply and not on the block.
* *Other constructions.* For arbitrary prefix words `h-a` is whatever it is; a special-purpose seeker for one class that is shorter than its twin is not excluded (limit (iii) after Proposition 20 of the source).

**Corrected text.** README and Section 8: "For one written seeker the toy gives a necessary condition in which no stake occurs: where the users go on printing, it supplies the majority only if it is shorter than its honest twin. The rest beyond the twin, and the sum over seekers, are not bounded." Section 473: "For a seeker that is written down the toy has one necessary condition, in which no stake occurs: if its twin is no longer than it and the users go on printing, it supplies at most half of the samples, however narrow the class and however high the stake."

### 7. "The one reading under which repetition lowers the bar": the share falls in reading (b) too; what falls only in (a) is the weight. overclaim [section] and [summary]

**Where.** `paper/sec3b-stakes.tex` 409-410; `paper/sec1-intro.tex` 129-130 ("only ... lower the share that is needed"); `README.md` 33; `paper/sec8-answers.tex` 117-118.

**Problem.** Along one world the shares at successive uses accumulate exactly as in (a). Let `xi(x_1) = 1`, `xi(z) = 0.4`, and let mass 0.2 leave for a takeover block at each of three cut points. The takeover shares are 0.2, 0.25 and 0.33, none above one half, and the chance of a takeover is 0.6. So "only n independent samples at one context lower the share that is needed" is false for the share per use. What does not fall in (b) is the *weight*: the masses at different cut points belong to different programs and add up. An attacker of weight B spread evenly over n cut points of a world of mass 1, with nothing else present, has the chance `B/(1+B)` for every n. In (a) the same programs are drawn n times, and the weight needed falls to `2^(1/n)-1` times the rest. The source kept the comparison of many uses in sequence with a single use only as a comparison of two upper bounds (its Section 5.2, "narrowed"), so "only" is not a theorem.

**Corrected text.** Section 409-410: "Part (a) is Proposition 15(a) at a single context. It is the reading in which the same programs are drawn n times, so that the weight needed falls, to a share of `ln 2/n` per sample." Section 1: "Of three readings of 'run n times', n independent samples at one context lower the weight that is needed, to about `ln 2/n` of the rest; for n uses in sequence along one world the shares at the uses add up in the same way but belong to different programs, and the chance over all of them is bounded in terms of the weight and the world's mass, whatever n; running the block n times changes stakes only (finding 3)."

### 8. The verdict is an argument, "the other half fails" is not shown, and "channel" is read as "the users". overclaim [summary]

**Where.** `paper/sec8-answers.tex` 94-95 and 103; `README.md` 28.

**Problem.**

* The section (479-481) and the source (item 14 of its plain answer) mark "not as stated" as "an argument and not a theorem". Section 8 opens with "Not as stated" as the answer, and the README with "The picture is half right", without that mark.
* "The other half fails as stated" (Section 8, 103). No result shows that enough weight fails to win. What is shown: it is not a theorem of the toy; outweighing the *users* is not the condition; one written seeker that is no shorter than its twin supplies at most half where the users go on. In the model it is a theorem also for a rest that follows at a fixed ratio below 1 (Theorem 17(B1)).
* The sentence offered as the reason, "a context that is cheap to aim at is also cheap to print without taking over", has a mirror image by the same proposition: a context that is cheap to print is cheap to print with a takeover block (the floor of Proposition 16(c)). Each side holds `2^(-c)` of the other. That supports "open", not "fails".
* The question does not say that the channel is the users. If the channel is everything that prints those contexts, the picture is Theorem 17: necessary in the toy, sufficient in the model. "Not as stated" answers the other reading, and the text should say which.

**Corrected text.** Section 8, opening: "Not shown; and not as stated, if the channel is taken to be the users of the high-stake class. This verdict is an argument from the results of Section 3.7 and not a theorem." Line 103: "The other half is not a theorem of the toy: that rest is not the users, and part of it follows the seeker." Add: "If the channel is everything that prints those contexts, the picture is Theorem 17: a lump heavier than the channel is necessary in the toy and sufficient in a model whose rest does not react; how heavy the rest of a high-stake class is the toy does not evaluate." README 28: "The picture is half proved."

### 9. All four summaries drop "without resource bounds"; they also drop what a stake is and the assumption (INC). gap [summary]

**Where.** `paper/main.tex` 78-90; `paper/sec1-intro.tex` 112-130; `paper/sec8-answers.tex` 94-127; `README.md` 28-34; also `paper/sec7-circuits.tex` 830-831.

**Problem.**

* *Resources.* The Results paragraph of Section 1 (51-52) says that statements are for the bounded mixture unless said otherwise, and items 3 and 7 say "without resource bounds". Item 8 does not, so by the note's own convention it claims Theorem 18 and Propositions 19 and 20 for the bounded predictor. They are for `M_U`. Under a schedule shorter than its start-up the weighted seeker has no mass, like the seeker of Theorem 12, and neither has its twin (Section 3.2 of the source); the bounded versions are open (its Section 5.1, item 5). The abstract's bullets on reach say "without resource bounds"; the bullet on stakes does not.
* *The stake.* It is a label on calling programs that no result connects to what a world does after the use (section, 15-16). To be aimed at it must be recognisable from the calling program: Proposition 19 assumes that the pairs (p, n) with `r(p) >= n` can be enumerated, and the source lists this among the premises outside the toy (its Section 5.3). A stake that depends on input beyond the calling program, or on the block returned, is not covered. No summary says either thing; the abstract uses "stake" without saying what it is. Section 7 (830-831) says that a seeker "can compute the stakes by simulation at no cost in bits": the stakes are assumed enumerable, not computed by simulation, and naming n costs `2 log_2 n` bits; only a tilt costs no bits for n.
* *(INC).* The ceiling `1-2^(-c)` of Proposition 16(c) assumes that the contexts of the whole rule are pairwise incomparable. The summaries state only the other condition.

**Corrected text.** Abstract: "Attach a stake to each use, a label that a program can recognise from below. Without resource bounds, a seeker can aim at ...". Section 1, item 8: "... Attach a stake to each use, as a label; nothing connects it to what the world does after the use. Without resource bounds, a seeker can weight its search ...". Section 8 and README: the same two insertions, and "where the contexts are pairwise incomparable and some block that can be computed from the context is not a takeover, a wrapper keeps ...". Section 7: "In the program toy a seeker for a rare class is repaid for the rarity, and can aim at stakes that a program can recognise for about `2 log_2 n` bits."

### 10. "Checked by AI referees, in the files": the referees checked the derivations, not the corrected account. overclaim [summary]

**Where.** `paper/sec1-intro.tex` 189-191; `README.md` 91.

**Problem.** `research/stakes-final.md` was written by an editor after the two referee reports. Its Provenance section lists statements and proofs "not seen by the referees". Four of them are in the paper: the proof of Theorem 17(B1) for a rest that follows; the last claim of Proposition 23(b), `B > (2^n - 1) xi(z)`; Example 21(f); and the proof of Theorem 18 through maximal dyadic intervals, which is the proof the paper prints. I re-derived these four and found them correct, so the status is now "checked once, in this round". The README (91) lists "the example" under "Proved here (short proofs in the paper)"; the paper states Example 21 without proof, and it is the main support of the answer, not a secondary statement.

**Corrected text.** Section 1: "The longer proofs of Sections 3.7 and 7 were written out in the files ...; the derivations behind them were checked by AI referees, and the corrected accounts were written afterwards. The Provenance section of `stakes-final.md` lists the items that no referee had read; those used here were checked in `verification/referee-6-stakes-claims.md`." README 91: move "the example" to the sentence on statements taken from `research/`, or print the proof, which is ten lines.

### 11. "Leaves the deciding comparison where it was"; "holds only in". unclear [section]

**Where.** `paper/sec3b-stakes.tex` 479-481 and 464-465.

**Problem.**

* "Leaves the deciding comparison where it was" reads as: focusing does not change the attacker's position in that comparison. This is not shown. Focusing changes the set of contexts and with it the rest: in the passive model a weight B with share `B/(B+O(X))` when spread over everything has `B/(B+O(W))` on a class. What is shown is that the two parts of the rest that follow, the wrapped copies and the twin, keep their ratio. Section 8 and the README have the better wording, "leaves open".
* "The other half ... holds only in the allocation model with a rest that does not react." "Holds only" should be "is proved only". And (B1) proves it for a rest that follows at a fixed ratio below 1; "does not react" is (M2). The formulas that follow, `b/(1+b)` and the square-root law, are those of the passive case.

**Corrected text.** 479-481: "... because focusing on high stakes makes the lump outweigh the users and leaves the deciding comparison open." 464-465: "The other half, that enough weight wins, is proved only in the allocation model, where the passive rest and the follow ratio do not depend on the allocation; the following formulas are for a rest that does not follow at all."

### 12. The closing paragraph does not answer "run more than n times", and does not say when the lump outweighs the users. gap [section]

**Where.** `paper/sec3b-stakes.tex` 456-481.

**Problem.** The question has a second clause ("maybe they will be run more than n times there"). The closing paragraph is silent on it, so a reader of that paragraph alone gets no answer to it. "Where the lump outweighs the users" (472) is not preceded by the condition.

**Corrected text.** Before "Where the lump outweighs the users": "The lump outweighs the users of a class when the class is rarer than half the seeker's weight and the seeker's own programs are not counted as users." Before the last sentence: "'Run more than n times' helps in the toy in one way: if the same context is sampled n times and one takeover sample suffices, a share of about `ln 2/n` is enough for a takeover with probability above one half, with or without aiming. If the block is run n times at a class, a stake-maximiser in the model moves its weight there, and the weight a majority there costs is unchanged."

### 13. The open items are narrower than the source's. gap [summary]

**Where.** `paper/sec8-answers.tex` 239-241; `README.md` 62.

**Problem.** Both name only the size of the rest and of the part that follows. The source's Section 5.1 has further open items that bear on the answer and that the section itself mentions or implies.

* The bounded versions of Theorem 18 and Propositions 19 and 20 (finding 9).
* Nested contexts and the lineage of Proposition 15(b), which the section calls "the one repetition native to the toy" and of which it says "nothing here covers it" (420-422).
* The self-reproducing weighted seeker. Theorem 18 supplies a payload that is a fixed computable function of the context, not the seeker's own code, which is the note's reading of "quining out"; the source lists the analogue of Theorem 12(c) as not done.
* A stake inside the toy.

**Corrected text.** "Seventh, for seekers that concentrate on high-stake uses: the size of the rest of a class of such uses and of the part of it that follows an attacker (only lower bounds on that part are proved); the versions under resource bounds; the aimed seeker that supplies its own code; contexts nested through a takeover block, as in a lineage; and any connection between the stake and what a world does after the use."

### 14. Smaller points in the section. minor [section]

* **72-74.** "No takeover probability and no attacker's share tends to one" is stated without the hypotheses of part (c). With `A(x)` all blocks the takeover probability is 1. *Corrected:* "and, under (INC), where some block that can be computed from the context is not a takeover, no takeover probability exceeds `1-2^(-c)` and no attacker's share exceeds `1/(1+2^(-c))`."
* **85-86.** "(M1) ... fails on nested ones." Proposition 16(b) shows that it holds for cut points of one sequence, which are nested. *Corrected:* "and can fail for contexts nested through an attack block."
* **118-119.** "For F the set of all inputs, where `w_F = theta`, it concerns all takeover programs together." For that F the weight is 1 and (A2) reads `1 > sum O_F`, which holds under (INC) for any assignment. *Corrected:* "For F the set of inputs that print a context of M followed by a takeover block, where `w_F = theta` and B is the total mass of the takeover programs on M, it is the statement for all takeover programs together; there it is the definition of a majority, summed."
* **271-272.** "Its mass relative to its own twin, `2^(h-a)/phi_g(x)`, does not change." `phi_g` depends on the aim where the users at one context differ in whether they go on; a weight that prefers users that stop printing weakens its own twin (limit (iv) in the source). *Corrected:* "... changes only through `phi_g(x)`, and not at all where the users at x go on with the same probability." The summaries' "a ratio in which neither the aim nor the stake occurs" (`main.tex` 84-85, `sec8-answers.tex` 105-106, `README.md` 31) is 20(b), which is for one uniform pair of constructions; add "for seeker and twin built in the same way".
* **377.** Part (a) of Proposition 23 is headed "in the toy". A use that draws n samples and acts when one is a takeover is a protocol outside Definition 6, as the text says of (b) at 416-417; the source's ledger calls it "a property of the world's protocol". *Corrected:* add at 409: "Like (b), it describes a protocol outside Definition 6, where a use receives one block." At 411-413, "takeover probability" in the passive model is the chance that one of the n samples is supplied by the attacker.
* **458-459.** "A stake that the context does not show is shared with everything else that prints the context." Programs that are not users have no stake. *Corrected:* "a user whose stake the context does not show cannot be separated from the other users, and the other programs, that share its context: all of them meet the same `theta(x)` (Proposition 16(a))."
* **477-479.** "Each depends on the machine (Theorem 26)." That theorem says that the share of a payload can be set by the choice of machine; it says nothing about `h-a`, `c` or `phi_g`. *Corrected:* "and by Theorem 26 none of the majority statements is invariant under the choice of machine."

### 15. Smaller points in the summaries. minor [summary]

* **`sec8-answers.tex` 99-100.** "Nothing limits by how much unless a simulated use counts as a use." Theorem 18(b) limits it, under (INC), to `2^(-a)/H_W`. *Corrected:* "by a factor of up to `2^(-a)/H_W`, which is unbounded as the class gets rarer, unless a simulated use counts as a use, when it is at most `2^(h-a)`."
* **`sec8-answers.tex` 113-114.** "A weight of b times the rest of a class has the share `b/(1+b)` at each of its uses": add "spread in proportion to that rest", as the section has it.
* **`sec8-answers.tex` 115-116.** `rho` for the stake per unit of rest clashes with the slack factor `rho` of Theorem 10, which the same section uses at 170. The section writes `varrho`.
* **`main.tex` 85-86, 89-90.** The constant c is used one bullet before it is explained. "A share of about `ln 2/n` per sample is enough" does not say for what: for a takeover with probability above one half at that use. The same in `README.md` 33.
* **`sec1-intro.tex` 46, `README.md` 10.** "Sections of their own": the first of the two is Subsection 3.7 of the section "Calibration, the floor, and searching", whose title does not cover it.
* **`sec1-intro.tex` 183-184.** "Every proof in Sections 2, 3, 4 and 5 up to Section 3.6 is short" is garbled by the insertion. *Corrected:* "Every proof in Sections 2, 3.1 to 3.6, 4 and 5 is short."

### 16. Consistency with the rest of the note. minor [other files]

* **`paper/sec2-toy.tex` 65-67.** "The results that use universality are [seven results]; the others hold for any machine." Proposition 16(c), Theorem 18, Propositions 19 and 20 and Example 21 use universality and are not in the list.
* **Notation.** `r(p)` is the stake, while `r_U(omega,k)` and `r` are numbers of input bits read (Section 2, Theorem 11), and `r_t(p)` appears in the proof of Proposition 19. In Proposition 20, `D(sigma)` is a dyadic interval in (c) and `D` the own continuation in (d). `w` is a prefix word in the proof of Proposition 16 and a share elsewhere. `H_W` and `C(W_n)` denote the same quantity. `S` is the total stake, (S) an assumption and `S_g(x)` a seeker's mass. `c` is a length, `c_s` and `c_h` are words. None of these makes a statement ambiguous.
* **Labels.** Every label referred to in the section and in the summary passages exists, none is defined twice, and the proposition numbers of the source quoted in the section (16, 18, 19; 23; 6 to 9; 11, 25, 26 to 28) are the right ones.

---

## What a careful reader would take from the text, and whether that was proved

**From the section, read in full.**

| What the reader takes | Proved? |
|---|---|
| Aiming at a recognisable class is cheap, and what is repaid is the rarity of the class among the users. | Yes: Theorem 18, Proposition 19. Without resource bounds, for stakes that a program can enumerate. |
| A lump is necessary, and what it must outweigh is the rest and not the users. | Yes: Theorem 17(A), for the majority at every use of a set with pairwise incomparable contexts. |
| Part of the rest follows the attacker. | Yes, as lower bounds: `2^(-c)` for every attacker under (INC), `2^(a-h) phi_g` for one written seeker. No upper bound. |
| A seeker that outweighs the users of a class by `2^n/n^2` still does not win the class. | Only in the sense (W1), for that attacker, and for a reason that does not involve n (finding 4). For most of the class: a necessary condition on two constants. For the block returned: nothing. |
| Enough weight wins only in a model. | Yes, with the wording of finding 11. |
| Repetition helps in one reading only; running the block n times changes nothing. | The first with "weight" in place of "share" (finding 7). The second only when every use is multiplied (finding 3). |
| The answer is "not as stated", as an argument. | The status is stated correctly in the section. |

**From the closing paragraph alone.** The reader gets the right structure: cheap redirection, a necessary lump, the rest is not the users, the model, one written seeker bounded by its twin, the premise for the others, nothing evaluated. Three things come out wrong or missing: the example reads as a refutation of the picture (finding 4), "where it was" reads as "focusing does not help" (finding 11), and there is no answer to "run more than n times" (finding 12).

**From the summary passages alone.**

* *Abstract.* The reader takes a false sentence (finding 1) and is not told that the results are without resource bounds. The rest is right; "that does not make it win there" is the right strength.
* *Section 1, item 8.* The reader takes the example as showing that the class is not won, and "only" one reading of repetition; both are stronger than what is proved (findings 4 and 7).
* *Section 8.* The reader takes the answer to be "no": "Not as stated ... the other half fails as stated". The last sentence of the paragraph ("leaves open the comparison that decides the outcome") is what was proved, and the opening should be brought into line with it (finding 8).
* *README.* The closest to what was proved. The exceptions are the two sentences of findings 5 and 6.

**Is the question answered correctly?** The answer that the results support is this. In the toy it is neither proved nor refuted that seekers which concentrate on high-stake uses take over in most cases there. Proved in the toy, without resource bounds: redirecting is cheap and beats the *users* of a rare enough class; a lump heavier than everything else that prints those contexts is necessary; one written seeker that is no shorter than its honest twin supplies at most half where the users go on, however narrow the class. Proved in a model whose rest does not react: a lump heavier than the rest of the class wins it, and more runs at a class draw a stake-maximiser to it. For programs whose aim is not written in their text the question is the premise of the original argument. The section's closing paragraph gives this answer once findings 4, 11 and 12 are met; Section 8 gives a stronger "no" than the results support; the abstract contains one false sentence.

## What I checked and found correct

* Proposition 16 (a), (b), (c), with the constant c depending on U, the rule and P' only under (INC).
* Theorem 17, (A1), (A2), (B1), (B2), and the example separating (W2) from (W3) (shares 0.538 and 0.323).
* Theorem 18: the claim on maximal dyadic intervals, the mass `2^(j-1-|p|) g(p)` per calling program, (a), and the exactness and the bound of (b).
* Proposition 19: `a_n <= |v'| + 2 log_2 n + 2 log_2 j_n + 6`, the factor `2^(-|v'|-7)/(n^2 j_n^2 C(W_n))`, and (b).
* Proposition 20 (a) to (d). The direction of every ratio is right: the twin has `2^(a-h)` times the seeker's mass, the seeker `2^(h-a)/phi_g` times its twin's among programs that go on, and under closure the seeker has at most `2^(h-a)` times the users'.
* Example 21 (a) to (f) by hand, and the constants of (b), (d) and (e) also by exact rational arithmetic for four choices of `(|u|, |v_A|, |v_D|, n)`.
* Proposition 22 (a) and (b), and the two-class formulas: the stated optimum against 400 random feasible allocations on each of 300 random instances with a follow ratio (no improvement found beyond rounding), and the closed forms on 2000 random two-class instances.
* Proposition 23 (a) and (b), including `B > (2^n - 1) xi(z)`.
* The three variants: the statements on the most-probable-block predictor, on programs whose aim is not written in their text, and the first sentence on several attackers. I read the source's proofs of the equilibrium statements (its Propositions 26(3), 27 and 28) and did not re-derive them line by line.
* The three statements taken from the source's Propositions 16, 18 and 19: I followed the proofs there, including the recursion-theorem argument of Proposition 18.
