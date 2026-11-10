# Referee report 4 on "A toy malign-prior question with an answer": critical uses, the honest twin, reach and fate

Date: 2026-11-10. Version refereed: `paper/` and `README.md` as committed in "restate the claim as takeover among critical uses; reach versus fate" (`b87b7291`), with `main.pdf` built at 23:04 UTC (24 pages). I had not seen the note before.

**Scope.** The material added after round 3.

- Definition 6 (critical use) and Definition 8 (malign prior hypotheses), with the text around them.
- Section 3.5: Theorem 13 (critical uses), Proposition 14 (the honest twin), and the paragraphs "What one seeker reaches" and "What happens to most uses".
- The summaries of this material in the abstract, Section 1, Section 7 and the README.

Sections 1 to 3 and 7 were read in full. Theorem 12(b), (c) and their proofs were taken as verified by report 3.

**Conventions.** Numbering is that of the PDF. Up to the searching theorem it is one higher than in report 3 (searching is now Theorem 12). Line numbers refer to the source files. `e(j)` is the code written with a bar, `H` is `H_C`, and "the largest `j`" is `j = floor(log2(1/H)) + 1`. I write

- `a = |v| + |e(j)|` for the length of the seeker of Theorem 13(a), and `h = |v_h| + |e(j)|` for that of the honest twin;
- `S(x) = 2^(-a) 2^(j-1) C(x)` for the mass of the seeker's programs whose search finds a use at `x`, and `T(x) = 2^(-h) 2^(j-1) C(x)` for the same mass of the twin.

**Method.** Pencil and paper. I wrote and ran no programs, and changed no file except this report.

**Bottom line.**

1. No inequality in a numbered statement is wrong.
   - Definition 6 is well formed once it says that a calling program has one context. `kappa <= 1`. A test is the special case claimed, without resource bounds.
   - The inequalities of Theorem 13 (a), (b), (c) are correct as stated, constants included, also when contexts are comparable. One sentence inside (b) says "outweigh" for a factor that can be below 1 (B7).
   - Proposition 14 is correct. Its conclusions need "if the rule is closed under search", which the statement leaves to the reader (B8).
2. The step from Proposition 14 to the fate of the uses is missing. The proposition compares masses. What a use receives is a sample from `pi_m`, which is normalised by the programs that print `m` more bits, and a calling program need not print anything after its context. So "seekers hold the majority only if ..." does not follow for what the predictor returns (B1). A corrected statement is available, and it needs no closure assumption.
3. "About its own prior weight, however rare critical uses are" is not what Theorem 13(a) gives. It is false when uses are rarer than the seeker is long: the reach is at most `H`, and (a) itself forces `kappa < 2^(a+1) H` at every use (B2). The phrase stands in the abstract, Section 1, Section 3.5, Section 7 and twice in the README.
4. "Critical uses are about as rare as the honest twin is long" is not the condition that is proved. Proved is `H < 2^(-a)`, with the seeker's length, next to `H > 2^(-h-1)` (B3).
5. The upper bound is for one seeker and one search. Masses of different seekers add, and the concentrating seeker of the same section is outside the bound (B4). The bound against "genuine users" is a bound against the seeker's own twin, which is a user by assumption (B5).
6. Two sentences claim more than the inequality behind them: "a seeker can hold the majority where it chooses to" (B6) and "the self-reproducing continuations outweigh ... by the factor" (B7).
7. No summary says outright that question (2) is settled. Three passages drop the closure assumption or can be read as a full reduction of the question: Section 1 lines 30-34, Section 7 lines 43-44, README line 33 (section C).
8. Nothing refers to the removed remark. Six passages elsewhere are stale (D).

---

## (A) Verdicts

| Item | Verdict |
|---|---|
| 1. Definition 6, well formed | CORRECT BUT GAP: one context per calling program (B9) |
| 1. `kappa(x) <= 1` | CORRECT AS STATED |
| 1. A test as the special case | CORRECT, with "minimal program" read as in the proof of Theorem 12(b), and without resource bounds (B9) |
| 1. Definition 8 | CORRECT BUT GAP: three small omissions (B9) |
| 2. Theorem 13, preamble | CORRECT AS STATED |
| 2. (a), inequality and share | CORRECT AS STATED |
| 2. (a), probability statement | CORRECT AS STATED |
| 2. Proof, "those proofs use only ..." | CORRECT AS STATED |
| 2. Comparable contexts | the lower bounds survive; nothing is counted twice |
| 2. (b), inequality, `C*`, membership in `SR_m` | CORRECT AS STATED |
| 2. (b), hypothesis on `m` | harmless, and not needed |
| 2. (b), "outweigh ... by the factor" | WRONG as worded (B7) |
| 2. (c) | CORRECT AS STATED |
| 3. `R^h` well defined; "and nothing else"; form of calling programs | CORRECT AS STATED |
| 3. `2^(j-1) <= 2^h`, `H > 2^(-h-1)`, the display | CORRECT BUT GAP: true under the closure assumption, which the statement does not put as a hypothesis (B8) |
| 3. "A rule given by a test is closed under search" | CORRECT AS STATED |
| 4. "worlds of total prior probability more than `2^(-a-1) E[kappa(X)]`" | CORRECT AS STATED, derived |
| 4. "Rarity of critical uses does not reduce this" | WRONG as stated (B2) |
| 4. Majority condition for a part `W` | CORRECT, derived; its `a` is not the `a` of the first half (B6) |
| 4. Closing sentence | the condition restated: CORRECT. "Can hold the majority where it chooses to": CORRECT BUT GAP, not shown (B6) |
| 5. Share of uses = average posterior share; seekers add up | CORRECT (the share is the one under `pi_m`; seekers with disjoint sets of programs) |
| 5. Use of the proposition (lines 354-356) | CORRECT under closure, for the programs whose search finds a use at that context |
| 5. "covers all seekers of this kind at once" | CORRECT BUT GAP: true of one machine's family, not of seekers coded separately (B4) |
| 5. Two-sided statement for the self-reproducing seeker | CORRECT, same reading |
| 5. "only if": the two inequalities | CORRECT |
| 5. "only if": the words attached to the second inequality | WRONG (B3) |
| 5. "more than a fraction `2^(a-h)` ... are honest twins" | CORRECT AS STATED |
| 5. "much more common ... far below 1" | CORRECT for one seeker and for its share of `M_U(x)`, with "that" read as the seeker's length |
| 5. The paragraph as an answer to question (2) | CORRECT BUT GAP (B1, B4, B5) |
| 6. Summaries | section C |
| 7. Consistency | no dangling reference; stale passages in D |

### Item 1. Definitions 6 and 8 (`sec2-toy.tex` 108-124, 140-164)

**A1. Well formed.** CORRECT BUT GAP. `C(x)`, `H` and "makes a critical use at the context `x_p`" need each calling program to occur in exactly one pair. The notation `x_p` suggests it; the definition does not say it. Without it, a program with two contexts (which are then comparable) is counted in two `C(x)`, and the probabilities `C(x)/H` of Theorem 13 sum to more than 1. Everything else is in place: enumerable pairs, prefix-free programs, and "prints `x_p` having read no more than `p`", which makes `[p]` a set of worlds that print `x_p`.

**A2. `kappa(x) <= 1`.** CORRECT. The cylinders of the calling programs with context `x` are disjoint and lie in `{omega : x is a prefix of out_U(omega)}`, so `C(x) <= M_U(x)`. At a context `M_U(x) >= C(x) > 0`, so kappa is defined there. `H <= 1` by Kraft, and `H` is the probability that a world begins with a calling program.

**A3. A test as the special case** (121-123). CORRECT, with two readings fixed (B9).

- "Minimal programs for first hits" is not defined in the note. It has to mean the handing-over programs of the proof of Theorem 12(b): `U` prints a first hit on every input beginning with `p` and has read exactly `p` when the hit is complete. For these, report 3 (A4) gives: prefix-free, enumerable, weights that sum to `M_U(x)` at each first hit and to `H_G` in all. So `C(x) = M_U(x)` and `kappa = 1` at first hits, and `H_C = H_G`.
- The claim is about Definition 5 without resource bounds. Definition 5 requires `omega in E(x)`; Definition 6 has no bounds.

**A4. What later results need from the definition.** Theorem 13 needs only: one context per program, an enumeration, and the Kraft sum `H`. Proposition 14 needs the form "prints `x_p` having read no more than `p`", which is there. Definition 8 needs three things that are not there (B9): the own continuation of a world that makes a critical use, `H > 0`, and a predictor that is defined at the context.

### Item 2. Theorem 13 (`sec3-floor.tex` 267-307)

**A5. Preamble.** CORRECT AS STATED. `2^(j-1) H <= 1` and `> 1/2` for the largest `j`, because `floor(t) > t - 1`. `Pr[X = x] = C(x)/H`, given A1. The sampling predictor for `M_U` is defined at every context, because `M_U(xy) > 0` for a universal `U`.

**A6. (a), inequality.** CORRECT AS STATED. The machine reads `e(j)`, gives the enumerated programs consecutive intervals of length `2^(j-1-|p|)` (total `2^(j-1) H <= 1`), reads its point by the rule of Theorem 12(b), and prints `x_p P(x_p)`. Inputs whose point falls on the interval of a `p` with `x_p = x` have measure `2^(j-1) C(x)` and print `x P(x)`. With a prefix word `v`, which does not depend on `j`, this is the inequality. The share follows from `M_U(xy)/M_U(x) <= pi_m(y | x)`.

**A7. (a), probability statement.** CORRECT AS STATED. The probability is `sum_x C(x) pi_m(P(x)_{1:m} | x) >= 2^(-a) 2^(j-1) sum_x C(x) kappa(x) = 2^(-a) 2^(j-1) H E[kappa(X)]`, and `2^(j-1) H > 1/2`. "More than" is strict because `kappa > 0` at every context. It is a joint probability over the world and the predictor's sample.

**A8. "Those proofs use only ..."** (299-300). CORRECT AS STATED. I went through the proofs of Theorem 12(b) and (c) with this in mind. They use the enumeration of the pairs, the lengths `|p_i|` and the bound on their Kraft sum. They do not use what `U` does on `p_i`, and prefix-freeness enters only through the sum. The property "U prints `x_p` on `p`" is used elsewhere: for `C(x) <= M_U(x)` and for reading `C(x)` as a mass of worlds. The two places where first hits were used, "those with `x_{p_i} = x` sum to `M_U(x)`" and "prints `x` followed by `P(x)` with probability exactly ...", become `C(x)` and "at least", as the proof says.

**A9. Comparable contexts.**

- *The lower bounds survive.* At a context `x`, (a) and (b) count only inputs whose point falls on the interval of a `p` with `x_p = x`. Each of them prints `x P(x)`, respectively `x y` with `y` in `SR_m(x)`.
- *Nothing is counted twice.* A world begins with at most one calling program, and that program has one context. So the events "critical use at `x`" are disjoint over `x` and have probabilities `C(x)`. Each is multiplied by a conditional probability that is bounded separately, and each interval is used at one context.
- *What changes.* The seeker's programs found at a proper extension `x'` of `x` also print `x`, and then the rest of `x'`. They add to `M_U(x)` and not to the payload at `x`. So "exactly" becomes "at least"; the upper bound of Theorem 12(a) is not available; and Proposition 14 bounds only the programs found at `x` itself (A16).
- *A check of report 3 that no longer holds.* `j - 1 <= |q| + |e(j)|` (D3 there) used that the seeker's own programs hand over. For a call rule `j` can be larger. Then the threshold `m - 4 - |q| - |e(j)| + j` of `C*` exceeds `m - 3`, and can exceed `m`. Part (b) stays true: what has to fit into the block is the seeker's name `q e(j) omega_{1:r} 1` for the calling program, and `omega_{1:r}` is shorter than the program by about `j` bits.

**A10. (b), inequality and `C*`.** CORRECT AS STATED. With `r_0 = m - 1 - |q| - |e(j)|`: the points of `I_i` read with at most `r_0` bits have measure at least `|I_i|/2` when `|p_i| <= r_0 + j - 3 = m - 4 - |q| - |e(j)| + j`. Summing over the `p_i` with context `x` gives `2^(-|q|-|e(j)|) * (1/2) * 2^(j-1) * C*(x)`, which is the right-hand side. The inputs counted lie in the disjoint union, over `y` in `SR_m(x)`, of the sets of inputs that print `xy`. `2^j > 1/H` for the largest `j`.

**A11. (b), membership in `SR_m(x)`.** CORRECT AS STATED. The argument never uses what `p_i` is. `R_q` reads `e(j)` and `omega_{1:r}` and nothing more, so on `y 0^infinity = q e(j) omega_{1:r} 1 0^infinity` the machine `U` prints `x_{p_i} y 0^infinity`. That is the definition of Section 2 without bounds. What changes is the meaning. Under a test the world `y 0^infinity` hands over at `x` again (Proposition 15(b)). Under a call rule it prints `x` and `y` again, and makes a critical use only if it begins with a calling program. The string `q e(j) omega_{1:r}` has the form required of one; whether it is one is up to the rule (D4).

**A12. (b), hypothesis on `m`.** Harmless and not needed. Every calling program has at least `j - 1` bits, because `2^(-|p|) <= H <= 2^(1-j)`. At `m = |q| + |e(j)| + 2` the threshold is `j - 2`, so `C* = 0`; for smaller `m` likewise. The statement is true for every `m` and has content from `m = |q| + |e(j)| + 3` on (as report 3, D2). Also `C*(x) > 0` at no more than `2^(m-3-|q|-|e(j)|)` contexts, because at most `2^(r_0 - 2)` disjoint intervals have length `2^(2-r_0)` or more. The note makes this caveat after Theorem 12 and should repeat it here: "at every context" in (b) and the expectation in (c) have content on fewer than `2^(m-2)` contexts.

**A13. (c).** CORRECT AS STATED. `Pr[Y in SR_m(X)] = sum_x (C(x)/H) pi_m(SR_m(x) | x)`, and `pi_m(SR_m(x) | x) >= sum_{y in SR_m(x)} M_U(xy) / M_U(x)`.

### Item 3. Proposition 14 (`sec3-floor.tex` 309-331)

**A14. The machine and the form of its programs.** CORRECT AS STATED.

- *Well defined.* After the search, `R^h` simulates `U` on a virtual input: first `p`, which it holds, then its own unread input. It reads a real bit only when the simulated `U` reads beyond `p`.
- *"And nothing else".* The search reads exactly `e(j) omega_{1:r}` (report 3, A6). Nothing is printed during the search. `U` prints `x_p` on `p` without reading beyond `p`.
- *Form.* Every input beginning with `e(j) omega_{1:r}` leads to the same search result, because the reading rule is deterministic. So `U`, on every input beginning with `v_h e(j) omega_{1:r}`, prints `x_p`, and by Definition 3 it has read `|v_h| + |e(j)| + r` bits when `x_p` is complete: exactly the program.

**A15. The inequalities.** CORRECT, under the assumption (B8).

- The strings `omega_{1:r}` are the maximal dyadic intervals inside the `I_i`. They are pairwise incomparable, with total measure `2^(j-1) H`. So the twin's programs weigh `2^(-h) 2^(j-1) H`. If they are calling programs, this is at most `H`, hence `2^(j-1) <= 2^h`.
- For the largest `j`: `H > 2^(-j) >= 2^(-h-1)`.
- The display: the equality holds for every seeker of Theorem 13(a) with the same `j`, whatever the order of its enumeration. The inequality is `2^(j-1) <= 2^h`.
- The assumption depends on `j`, on the enumeration and on the prefix word chosen for `R^h`. `v_h` does not depend on `j`.

**A16. What the display bounds.** The programs whose search finds a use at `x`. It does not bound the seeker's programs found at an extension of `x`, which also print `x` (A9), and it does not bound `M_U(x P(x)_{1:m})`. The paragraph's "a seeker's mass at a context" (354-355) should keep the proposition's wording, or assume pairwise incomparable contexts.

**A17. "A rule given by a test is closed under search."** CORRECT AS STATED. The twin's programs print what `U` prints on `p`, whose first hit is `x_p`, and have read exactly themselves when it is complete (A14). So they are handing-over programs with context `x_p`, for every `j` and every prefix word.

### Item 4. "What one seeker reaches" (`sec3-floor.tex` 333-347)

- **Reach** (334-336). CORRECT, derived from (a). "The source of the continuation" is right in this sense: the seeker's programs found at `x` have at least the share `2^(-a) 2^(j-1) kappa(x)` of `Z_m(x)`.
- **"Rarity of critical uses does not reduce this, apart from the bits that name `j`"** (336-339). WRONG as stated (B2).
- **"What does reduce it is kappa"** (339-340). CORRECT.
- **The part `W`** (340-345). CORRECT, derived. `W` is itself a call rule, so (a) applies with `j` the largest for `H_W`. Because the contexts of `W` are pairwise incomparable, the family's programs that print `x` are exactly those found at `x`, and all of them print the payload. So `M_U(x) = S_W(x) + O(x)`, where `O(x)` is the mass of the programs outside the family that print `x`, and `S_W(x) > 2^(-a) C_W(x)/(2 H_W) >= O(x)` gives a strict majority for the payload. The hypothesis on the contexts is used and is needed.
- **Closing sentence** (345-347). The condition for all contexts of `W` reads `H_W <= 2^(-a-1) min_x C_W(x)/O(x)`, and `C_W(x)/O(x) <= 1` when the users are outside the family. So "up to about `2^(-a)` times the fraction ..." restates the condition correctly. "A seeker can hold the majority where it chooses to" is not shown (B6).

### Item 5. "What happens to most uses" (`sec3-floor.tex` 349-367)

- **"By definition, the average over uses of the posterior share"** (350-351). CORRECT by Definition 8. The share meant is `pi_m(A(x) | x)`: mass divided by `Z_m(x)`. In the rest of the paragraph "share" and "mass" are relative to `M_U(x)` or `C(x)` (B1).
- **"Different seekers add up"** (352). CORRECT, asserted. It needs seekers with disjoint sets of programs, for instance incomparable prefix words.
- **Use of the proposition** (352-356). CORRECT under closure (A15, A16). "Proposition 14 says that ... this honest twin is then itself one of the worlds that make the use" turns the assumption into a result: the proposition shows that the twin's programs have the form of calling programs, and assumes that they are calling programs, except for a test.
- **"Covers all seekers of this kind at once"** (356-358). CORRECT BUT GAP (B4).
- **Two-sided statement** (358-360). CORRECT for the programs whose search finds a use at `x`. Lower bound: (b). Upper bound: these programs have mass `2^(-|q|-|e(j)|) 2^(j-1) C(x)`, and `2^(j-1) <= 2^h`. The proposition is stated for the seeker of (a); the same line covers this one.
- **"Only if"** (360-363). The inequalities are CORRECT. `S(x) > C(x)` is the same as `2^(j-1) > 2^a`, with or without closure, and with `2^(j-1) <= 2^h` it gives `|v| < |v_h|`. The words attached to the second inequality are WRONG (B3).
- **Fraction of twins** (363-364). CORRECT. The twins are the fraction `2^(-h) 2^(j-1) > 2^(a-h)` of the users, at every context.
- **"Much more common ... far below 1"** (364-365). CORRECT for the one seeker `q` ("the seekers' share" should be singular). Its programs found at `x` have the share `2^(-|q|-|e(j)|) 2^(j-1) kappa(x)` of `M_U(x)`, between half of the stated value and the stated value. "That" has to be the seeker's length (B3).
- **Last sentence** (365-367). CORRECT; B4 lists what else is not covered.
- **Does the proposition bear on question (2)?** In a limited way. It bounds the mass of one seeker, with one search, against the mass of the users at the same context, if the twin is a user. Three steps separate this from the share of uses that end in a takeover: from mass to what the predictor returns (B1), from one seeker to all (B4), and the assumption itself (B5). The comparison that does bear on question (2) is the one in the posterior, between the seeker's programs and the twin's; it is stated in B1.

### Item 7. Consistency

No reference to the removed remark is left, and the log has no undefined reference. The forms for one world are coherent with "makes a critical use": for a test this is "hands over", and for a call rule the own continuation needs one sentence (B9). Stale passages are in D.

---

## (B) Errors and gaps, most serious first

### B1. From masses to the fate of the uses

**Where.** `sec3-floor.tex` 352-365; `main.tex` 58-60; `sec1-intro.tex` 30-34; `sec7-answers.tex` 31-38; `README.md` 21-22.

**What is missing.** By Definition 8 the share of uses that end in a takeover is the average of `pi_m(A(x) | x)`, and `pi_m` divides by `Z_m(x)`, the mass of the programs that print `x` and `m` more bits. Proposition 14 bounds `S(x)` by a multiple of `C(x)`. Definition 6 puts no condition on what a calling program prints after its context, and a program that calls the predictor and waits prints nothing. The twin behaves as the user it found, so it prints nothing either.

- In that case neither users nor twins are in `Z_m(x)`. The predictor returns the seeker's payload with probability at least `S(x)/Z_m(x)`, and this exceeds 1/2 as soon as the other programs that print `x` and go on weigh less than `S(x)`, whatever `a - h` and `H` are.
- So "search-type seekers hold the majority only if they are shorter than the honest twin and ..." is proved for masses ("outweigh the worlds that make the use", line 360) and not for what the predictor returns. The same holds for "far below 1" (365): it is a share of `M_U(x)`.
- The note knows the point: the text after Theorem 9 has the factor `xi(x)/Z_m(x)` for worlds that stall.

**What is true, and it needs no closure assumption.** Let `C^m(x)` be the mass of the worlds that make the use at `x` and go on to print `m` more bits, and `phi(x) = C^m(x)/C(x)`.

- The twin's programs that find a use at `x` print `x` and then what the user they found prints. They are in the posterior at `x` whether or not the rule counts them as uses, and those that print `m` more bits have mass `2^(-h) 2^(j-1) C^m(x)`.
- For incomparable `v`, `v_h` therefore `Z_m(x) >= S(x) + 2^(-h) 2^(j-1) C^m(x)`. The predictor returns a block supplied by the seeker's programs found at `x` with probability at most `1/(1 + 2^(a-h) phi(x))`.
- If no calling program is comparable with a program `v e(j) omega_{1:r}` of the seeker, also `Z_m(x) >= S(x) + C^m(x)`, and the probability is at most `1/(1 + 2^(a+1-j) phi(x))`.
- So that probability exceeds 1/2 only if `2^(a-h) phi(x) < 1` and `2^(a+1-j) phi(x) < 1`. When all users go on (`phi = 1`) these are the note's two conditions: the seeker is shorter than the twin, and uses are rarer than the seeker is long.

**Fix.** State the upper bound in this form in Section 3.5, with `phi`, and say in each summary "if the worlds that make the use go on to print the block themselves". The closure assumption is then needed only for `H > 2^(-h-1)`.

### B2. "About its own prior weight, however rare critical uses are"

**Where.** `main.tex` 51-52; `sec1-intro.tex` 27-29; `sec3-floor.tex` 336-339 and 349; `sec7-answers.tex` 14 and 21; `README.md` 18 and 33.

**What is wrong.** Theorem 13(a) gives a probability of more than `2^(-a-1) E[kappa(X)]`. Two facts stand against the gloss.

- The probability that a world makes a critical use and is handed the payload is at most the probability `H` of a critical use.
- (a) itself bounds kappa: the payload's share is at most 1, so `kappa(x) <= 2^(a+1-j) < 2^(a+1) H` at every context. Once uses are rarer than the seeker is long, the seeker's own programs outweigh the users at their contexts, and kappa is small for that reason.

So for `H < 2^(-a-1)` the reach is below `H`, which is below half the seeker's weight. Rarity does reduce it. The seeker may then be the source of what happens at nearly all uses, which is a different statement. The bound is of the order of the program's weight only where `E[kappa]` is of order 1, and that requires `H > 2^(-a-1) E[kappa]`. For a test `kappa = 1`, and indeed `H > 2^(-a-1)` there.

**A second point on the same sentence.** The probability statement is the average of the pointwise one. Like the average in Theorem 12(a), it does not need the search: a program of length `a'` that prints one fixed context `x_0` of a use and then the payload has its payload handed to worlds of probability at least `2^(-a') kappa(x_0)`, since `M_U(x_0 P(x_0)_{1:m}) >= 2^(-a')`. What the search buys is the share at every use, as the third bullet after Theorem 12 says. If question (1) asks for "such-and-such a fraction of the prior by such-and-such a strategy", the fraction is `2^(-a)` times an average of kappa for any program whose output begins with the context of a use, and the strategy matters for the pointwise share.

**Fix.** Abstract: "Its continuation is run in worlds of total prior probability more than `2^(-a-1)` times the average of kappa over uses, and at most `H`. This is of the order of its own prior weight where the worlds that make the use are most of what prints their contexts; since `kappa < 2^(a+1) H`, that requires uses that are not rarer than the seeker is long." Section 3.5, 336-339: "Rarity of critical uses enters through kappa: by (a), `kappa(x) < 2^(a+1) H`, so once uses are rarer than the seeker is long its own programs outweigh the users at their contexts, and the probability is below `H`." The other places accordingly.

### B3. "Critical uses are about as rare as the honest twin is long"

**Where.** `sec3-floor.tex` 362-365; `main.tex` 59-60; `sec7-answers.tex` 35-37; `README.md` 22.

**What is wrong.** The inequality at line 362 is `2^(j-1) > 2^(|v|+|e(j)|)`: uses are rarer than the *seeker* is long, `H < 2^(-a)`. The proposition adds `H > 2^(-h-1)`. So what is proved is the window `2^(-h-1) < H < 2^(-a)`. It is "about as rare as the twin is long" only when `a` is close to `h`. With `a = 100` and `h = 1000`, every `H` between `2^(-1000)` and `2^(-100)` is in the window; at `H = 2^(-200)` the seeker outweighs the users by a factor of about `2^100`, and uses are `2^800` times more common than the twin is long. The summaries carry only the words, not the inequality.

Two sentences depend on the same reading.

- "Where critical uses are much more common than that" (364): the share is small when `H` is much larger than `2^(-a)`, not when it is much larger than `2^(-h)`.
- "In which case the users are themselves in good part honest twins" (`sec7-answers.tex` 36-37, `README.md` 22). The twins are the fraction `2^(-h) 2^(j-1)` of the users. This is more than `2^(a-h)`, as Section 3.5 says, and at most 1/2 (B5). "In good part" is right only when `a` is close to `h`.

**Fix.** "... only if it is shorter than the honest twin and critical uses are rarer than the seeker is long; by the proposition they are not rarer than the twin is long. More than a fraction `2^(a-h)` of the users are then honest twins."

### B4. The upper bound is for one seeker and one search

**Where.** `sec3-floor.tex` 352-367; `main.tex` 58-60; `sec1-intro.tex` 30-34.

- **One seeker at a time.** The lower bound adds seekers up (352). The upper bound is per prefix word. Seekers with incomparable words `v_i` have together the mass `sum_i 2^(-a_i) 2^(j-1) C(x)` at `x`. They outweigh the users only if `sum_i 2^(-a_i) > 2^(-h)`, which does not require any one of them to be shorter than the twin. The abstract's plural, "search-type seekers hold the majority only if they are shorter than the honest twin", should be about their total weight.
- **"Covers all seekers of this kind at once"** (356-358). The machine with the payload "run the rest of my input as a program" is not a seeker of Theorem 13(a): what it prints after the context is not a function of the context. The argument of the proposition applies to it all the same. It gives: the programs of this machine that find a use at `x`, whatever they print afterwards, have mass at most `2^(|v_h|-|v_u|) C(x)`, with `v_u` its prefix word. That bounds one family, in which every payload appears with the weight of a program for it. It does not bound a seeker with its own prefix word, which can be shorter than `v_u` followed by a program for its payload.
- **One search.** The proposition is for the search that spreads the mass over all calling programs in proportion to their weight, with the same `j`. The seeker that concentrates on a part `W` (340-347) has the gain `2^(j_W - 1) > 1/(2 H_W)`, which Proposition 14 does not bound. The same argument works with the twin of that search, if the rule counts it as a user (a test does), and then has `h_W` and `H_W` in place of `h` and `H`. So "critical uses are rare" in the summaries would have to read "the uses it searches for are rare". In the limit of a single context the concentrated seeker is "print `x`, then the payload", the case that the last sentence of the paragraph excludes.
- **Not covered at all:** programs that print a context of a use without going through a calling program (the paragraph says so); the seeker's programs found at an extension of the context (A16); the other programs that print the context, that is, their mass (kappa) and what they continue with; and every resource bound. Both the seeker and the twin have the long start-up of the search.

**Fix.** Lines 356-358: "The same argument bounds, for the machine that runs the rest of its input after the search, all continuations that this one machine supplies. Seekers with their own prefix words are bounded one at a time, and their masses add." In the summaries: "a seeker of this kind", and "by the same search over all uses".

### B5. What the closure assumption does

**Where.** Proposition 14; `main.tex` 56-58; `sec1-intro.tex` 31-34; `sec7-answers.tex` 31-35; `README.md` 21 and 33.

There is no logical circle, but the wording hides how much the assumption carries.

- **The bound is against the seeker's own twin.** The proof is the identity `S(x) = 2^(h-a) T(x)`. The twins are users by assumption, so `T(x) <= C(x)`. "At most `2^(h-a)` times the mass of the genuine users" is the seeker compared with a population that contains, by assumption, the programs that came to the use by the same search. "Genuine" is not defined in the note and suggests the opposite.
- **`H > 2^(-h-1)` is the twins' own weight.** Uses cannot be rarer than the twin is long because the twin is counted as a use. The statement gives no lower bound on the probability of uses that are not reached by a search, and none on kappa.
- **The assumption is strong.** If some context is nonempty, not every calling program is a twin program: a chain of twins of twins prints nothing. So the inequality is strict: `2^(j-1) <= 2^(h-1)`, `H > 2^(-h)`, and the twins are at most half of the users at every context. Two consequences. First, `S(x)` is at most `2^(h-a)` times the mass of the users at `x` that are *not* twins, which is the statement the word "genuine" promises and could be made. Second, users other than these twins have probability more than `2^(-h-1)`: a rule that consists of a rarer population of users and their twins is not closed under the search with the largest `j`.
- **Where closure is proved, the comparison is not between two populations.** Under a test the seeker's own programs are handing-over programs too (first bullet after Theorem 12). A seeker never outweighs the users there, and its share at a first hit is exactly `2^(-a) 2^(j-1) <= 1/2`. The "only if" sentence has content only for rules that count the twin and not the seeker, and the note gives no example of one. For a rule such as "the computation executes a call", the twin only simulates the call. Whether a simulated use is a use is the modelling decision that the assumption makes; the note should say so.
- **Two summaries state the assumption as a fact.** `sec1-intro.tex` 31-33: "the same search followed by simply being the user that was found is itself a way of making a critical use, so ...". `README.md` 33 builds on the bound without naming the assumption.

**What bears on question (2) without the assumption** is the comparison in the posterior of B1: seeker and twin both print the contexts of uses, with masses in the ratio `2^(h-a)`, whether or not the twin is a user.

### B6. "A seeker can hold the majority where it chooses to"

**Where.** `sec3-floor.tex` 345-347; `sec7-answers.tex` 24-26; `README.md` 18.

A sufficient condition is derived (item 4), and it is correct. Three things stand between it and the sentence.

- The `a` of the condition is the length of the seeker *for `W`*, which contains a description of `W`. It is not the `a` of the first half of the paragraph, and it changes with the choice.
- The condition is on the other programs that print the contexts of `W`. They include the users, and the twin of the concentrated search, which has mass `2^(-h_W) 2^(j_W - 1) C_W(x)`. So the condition fails at every context of `W` unless `a_W < h_W`.
- No rule and part are exhibited for which the condition holds.

The README states the ability without any condition.

**Fix.** "Applied to a part `W` ..., (a) gives a seeker for `W` the majority of the posterior at every use in `W` at which the other programs that print the context weigh at most `2^(-a_W) C_W(x)/(2 H_W)`, with `a_W` its own length." README: "A seeker for a part of the uses holds the majority there if the other programs that print those contexts are light enough."

### B7. "Outweigh ... by the factor" in Theorem 13(b)

**Where.** `sec3-floor.tex` 288-290; `sec1-intro.tex` 75-77.

The inequality says that the self-reproducing continuations weigh at least `2^(-|q|-|e(j)|-2) 2^j` times `C*(x)`. For a rule given by a test this factor is at most 1/2 (report 3, D3), so nothing is outweighed. For a call rule it exceeds 1 only if `j >= |q| + |e(j)| + 3`.

**Fix.** "So at every context the self-reproducing continuations have at least `2^(-|q|-|e(j)|-2) 2^j` times the mass of the worlds that make the critical use there with programs of that length." Section 1, item 7: "has at least `2^(-c')/H` times the mass of".

### B8. Proposition 14 does not state its hypothesis

**Where.** `sec3-floor.tex` 312-320.

"Call the rule closed under search if ... Then `2^(j-1) <= 2^(|v_h|+|e(j)|)`" reads as an unconditional claim. Without closure it is false: a rule made of one program padded to length `N` has `H = 2^(-N)` and `j - 1 = N`, while `h` grows only with the length of a description of `N`. The equality in the display needs no assumption; the inequality does. The conclusion for the largest `j` needs closure under the search with the largest `j`.

**Fix.** "If the rule is closed under search, then ...".

### B9. Definitions 6 and 8: what to add

**Where.** `sec2-toy.tex` 108-124 and 140-153.

- **One context per program** (A1): "a set of pairs `(p, x_p)`, one for each calling program `p`".
- **"Minimal programs for first hits"** (121). Write "the handing-over programs of the proof of Theorem 12(b)", or define the term. The other usual meaning, a shortest `p` all of whose extensions print the first hit, does not satisfy the definition, because `U` may read beyond such a `p` before the hit is complete.
- **Bounds.** Definition 6 is without bounds, Definition 5 is within them. Say "without resource bounds" at line 121. If the critical-use form is meant for finite `T`, `L` as well, require that the calling programs are `(T,L)`-programs for their contexts.
- **Definition 8.** The critical-use form needs `H > 0` and a predictor that is defined at the context (`Z_m(X) > 0`). The forms for one world use "own continuation", which Definition 5 defines only for a handover; add "defined as in Definition 5".
- **Definition 8, the population form does not exclude the own continuation.** The forms for one world require `d` outside `A`. The critical-use form counts `Y in A(X)` also when the world's own continuation is in `A(X)`. Under a test it then holds, by Theorem 9, at the level at which the users are themselves such programs, so it is a statement of malignity only for a population that the prior describes badly. One sentence would say this.

---

## (C) Summaries

Which qualification each passage carries:

| Passage | without resource bounds | closure assumption | kappa | block | constants |
|---|---|---|---|---|---|
| Abstract, Reach | yes | not applicable | yes, then dropped by "about its own prior weight" | "an explanation of the context that fits" | `a` includes the bits for `j`: not said |
| Abstract, Fate | not repeated | "where that holds"; not carried into the last sentence | not applicable | not applicable | `h` likewise |
| Section 1, lines 25-34 | no | no, stated as a fact | no | not applicable | none |
| Section 1, item 7 | yes | yes | yes | "programs that fit into a block" | `c'` is item 3's constant, for another program |
| Section 7, lines 14-41 | yes | yes | yes; not in the headline | "whose programs fit into a block" | `a` defined with the bits for `j` |
| README, Reach and Fate | yes (Reach) | yes | yes; not in the headline | same | `a` not explained |
| README, line 33 | no | no | no | not applicable | none |

"Fits into a block" in all four: `C*(x)` counts calling programs of at most `m - 4 - |q| - |e(j)| + j` bits. It is the user's program that has to be short, not any explanation of the context, and the threshold is not `m` (A9). "A user whose program is short enough for the block" would do.

**C1. Abstract, opening** (`main.tex` 39-45). The first sentence is the claim as restated by the commissioner. "The argument says" is stronger than Section 1's "we take the claim in the following form", and the note could not open the posts. The predictor is called time- and length-bounded here, while both bullets below are for `M_U`.

**C2. Abstract, Reach** (47-53).

- "Posterior share more than `2^(-a-1) kappa/H` at every use": exactly Theorem 13(a) for the largest `j`. It should say that there is such a program for each continuation, and that `a` contains the bits that name `j`.
- "Total prior probability more than `2^(-a-1)` times the average of kappa": exactly (a).
- "About its own prior weight, however rare critical uses are": says more, and is false for `H < 2^(-a-1)` (B2).
- "Costs a constant more and needs an explanation of the context that fits into the block": the constant is the length of another program, `q`, plus two bits. The bound then has `C*` in place of `C`. See the note on "fits" above.

**C3. Abstract, Fate** (54-60).

- "That does not make takeover the fate of most uses": right as "does not show that it is". It can be read as a denial; write "does not show".
- "The share of uses that end in one is the posterior share of such programs at the contexts of uses: at least the sum of the above over seekers": correct, as an average over uses.
- "... is itself a way of making a critical use; where that holds": the first clause asserts what the second makes a condition. Write "may itself count as a critical use (it does when uses can be read off the data); where it does".
- "At most `2^(h-a)` times the mass of the genuine users at any context": Proposition 14, for the seeker of the Reach bullet with the same search and for its programs that find a use at that context. "Genuine users" include the twins (B5).
- "`H > 2^(-h-1)`": correct under the assumption, for the largest `j`.
- Last sentence: says more in four ways. "Hold the majority" is proved for masses and not for what the predictor returns (B1). The condition on rarity is about the seeker's length (B3). It is one seeker at a time and one search (B4). "Where that holds" is not repeated.
- *Fix for the last sentence.* "Where that holds and the users go on to print the block themselves, a seeker of this kind supplies the majority of what the predictor returns at a use only if it is shorter than the honest twin and uses are rarer than the seeker is long."

**C4. Section 1, first paragraph** (`sec1-intro.tex` 3-12). No objection. "We take the claim in the following form" is the right register.

**C5. Section 1, "Read in the toy ..."** (25-34). The split into the two questions is faithful to the commissioner's. "That does not answer the second, which is the one the claim is about" is right. Three sentences say more.

- "Each such program is the source ... about its own prior weight, however rare critical uses are": no kappa, no "without resource bounds" (under a tight schedule the seeker has no mass), "each such program" where the theorem gives one program for each continuation, and B2.
- "An upper bound for programs that find their uses by search": it is an upper bound on the mass of one seeker relative to the users, not on the share of uses that end in a takeover (B1, B4).
- "... is itself a way of making a critical use, so such seekers outweigh genuine users at a context only by a constant": the assumption as a fact (B5).
- *Fix.* "The first has a clean answer without resource bounds: for each continuation there is such a program that is the source of the continuation run in worlds of total prior probability more than half its own weight times the average share kappa of the users among the programs that print their contexts. ... and, if the same search followed by being the user that was found counts as a critical use, an upper bound on the mass of one such seeker: at most a constant times that of the users at the same context, the constant comparing the lengths of two programs."

**C6. Section 1, item 7** (71-79). The first, second and last sentences say exactly what Theorem 13(a) and Proposition 14 prove, with the assumption stated. The third has the wording of B7, and its `c'` is the constant of item 3, which belongs to a different program; write "with `c'` its own length plus two bits".

**C7. Section 1, "What the toy does not settle"** (106-118). The new sentence on kappa is right as far as it goes: nothing bounds kappa from below. (a) bounds it from above (B2). Missing from the list: whether the notion of use one has in mind is closed under search, and whether users go on.

**C8. Section 7** (`sec7-answers.tex` 10-55).

- *Lines 14-26.* "As far as its own prior weight" and "Rarity of critical uses does not reduce this": B2. The sentences between them are exact. "A seeker can also concentrate ... and hold the majority there": B6.
- *Lines 28-41.* "That does not follow, and it is the question the argument is about" is right, and the lower bound is right. The upper bound is stated with its assumption. "So such seekers are the majority at the contexts of uses only if ... about as rare as the twin is long, in which case the users are themselves in good part honest twins": B1, B3, B4. "A seeker's share is about `2^(-a) kappa/H`, which is small" is right when `H` is much larger than `2^(-a)`.
- *Lines 43-44.* "Whether the shares are decent is thus a question about constants on the machine in use: the length of a seeker against the length of the honest twin, and both against the base rate of uses." This reads as a reduction of question (2). It presupposes the closure assumption, seekers of this one kind, and users that go on. It leaves out kappa, which is not a constant of the machine. Write "For seekers of this kind, and where a search followed by being the user counts as a use, ...".
- *Lines 52-55.* "Once a self-reproducing one runs, it meets the same context again and stays for `s/(1-s)` further generations": Proposition 15(b) is for a test. Under a call rule the world prints the context again and makes a use again only if it begins with a calling program (A11).

**C9. README, question and opening** (`README.md` 5, 14, 16). No objection to lines 14 and 16; "kappa = 1 when uses can be read off the data" is right without resource bounds. Line 5 has the "says" of C1.

**C10. README, Reach** (18). "As far as its own prior weight" and "however rare critical uses are": B2. "A seeker can also concentrate on a part of the uses and hold the majority there": unconditional (B6). The rest is exact.

**C11. README, Fate** (19-22). As C8, lines 28-41. The assumption is stated. "Are the majority ... about as rare as the twin is long ... in good part programs that came to the use by search": B1, B3, B4.

**C12. README, closing paragraph** (33).

- "Each seeker provably breaks out in worlds of about its own prior weight": B2; "each" as in C5; no "without resource bounds".
- "And that is cheap for it": not supported. The search costs the few bits that name `j`, and a start-up that gives it no mass under a tight schedule, as the README's own bullet on time bounds says.
- "Whether most critical uses end that way is a comparison of constants ... plus the question whether contexts of uses have cheaper explanations that are not uses. The toy proves the frame ...": this is the passage that comes closest to saying that question (2) is settled up to constants. What is proved is a lower bound from each seeker, and an upper bound on the mass of one seeker of one kind under an assumption on what counts as a use. That these are the only quantities is not proved (B1, B4, B5).
- *Fix.* "So in the toy, without resource bounds: for each continuation there is a seeker that breaks out in worlds of total probability more than half its own weight times the average share of users among the programs printing their contexts. Whether most critical uses end that way is not settled. For one seeker that searches, the toy bounds its part by comparing its weight with that of the honest twin and with the base rate of uses, if the users go on to print the block themselves. What the other programs printing the same contexts continue with is not bounded."

---

## (D) Minor points

1. **Stale passages.**
   - `sec1-intro.tex` 84-85: "The statements on obedient and contrarian worlds in the abstract." The new abstract has no statement on contrarian worlds.
   - `sec7-answers.tex` 3-8: the first answer still describes Definition 8 as three statements about one world, fixed by "the test that marks the handover". Definition 8 now begins with the critical-use form, which Section 2 calls the claim of the argument and which is not a statement about finitely many rationals.
   - `sec2-toy.tex` 65-66: the list of theorems that use universality omits Theorem 13 and Proposition 14, so "the others hold for any machine" is now wrong for them.
   - `sec3-floor.tex` 216: "Part (c) is the direct answer to Hänni's second question." Section 7 now says that two questions are in this one; Theorem 12(c) answers the first, for uses that a test recognises.
   - `sec3-floor.tex` 28-30: "the forms of Definition 8 ... hold to the extent that the worlds are unpredictable" is about the forms for one world, not about the critical-use form (B9, last point).
   - `main.tex` 61-63, "Without search": the bullet lost "under resource bounds it is multiplied by the share of explanations with room to spare", which round 1 had put in. For the bounded predictor that the abstract describes, the share is `2^(-c) rho(x)`, and `rho` can be 0.
2. **"Bounds" where a lower bound is meant.** `sec2-toy.tex` 157: "Theorem 13 bounds it" should be "from below". `sec3-floor.tex` 264-265: "They answer two different questions"; the second is bounded from below only.
3. **Notation.** `a` is the seeker's length and, at line 342, the length of the seeker for `W`. `c'` is used for two programs (C6). `H` is `H_G` in item 3 of Section 1 and `H_C` in item 7. "Genuine users" and "the largest `j`" are used without definition.
4. **Self-reproduction under a call rule.** The gloss after Definition 7 ("recreates the situation with itself in the world's place") and Proposition 15(b) are for a test. For Theorem 13(b), (c) one sentence should say that the world `y 0^infinity` prints the context and `y` again, and makes a critical use again only if the rule contains the seeker's programs (A11).
5. **Proposition 14 can be sharpened** to `2^(j-1) <= 2^(h-1)` and `H > 2^(-h)` when some context is nonempty (B5, third point).
6. **`sec2-toy.tex` 100-106.** "Both of Hänni's suggestions fit" is followed two sentences later by "in Hänni's second formulation only some programs call the predictor". Say that the second fits a test only when every program with the given output calls.
7. **`verification/README.md` 83** ends with "see below", and nothing is below yet.

**Not checked.** Any resource-bounded version of Theorem 13 or Proposition 14 (none is claimed); Sections 4 to 6; the computation.
