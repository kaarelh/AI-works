# Referee report 5 on "A toy malign-prior question with an answer": final check of the last revision

Date: 2026-11-11. Version refereed: `paper/`, `README.md` and `verification/README.md` as committed in "correct the reach and fate claims; add seekers that are not written down" (`f29bd9f8`), with `main.pdf` built at 23:50 UTC on 10 November (25 pages). I had not seen the note before.

**Scope.** Only what changed after round 4.

1. Proposition 14 (the honest twin) as restated, with its proof.
2. The reworded sentence and the parenthesis in Theorem 13(b).
3. The paragraph "What one seeker reaches".
4. The paragraphs "What happens to most uses" and "Three limits of this bound".
5. The paragraph "Seekers that are not written down" with its three bullets.
6. The summaries of this material in the abstract, Section 1, Section 7 and the README.

I report statements that are wrong or that claim more than is proved. Theorems 12 and 13 were taken as verified by reports 3 and 4.

**Method.** Pencil and paper. I wrote and ran no programs, and changed no file except this report.

**Conventions.** Numbering is that of the PDF: Theorem 10 is the floor, Theorem 12 searching, Theorem 13 critical uses, Proposition 14 the honest twin. Line numbers refer to the source files. As in the note, `a = |v| + |e(j)|` is the seeker's length and `h = |v_h| + |e(j)|` the twin's, `S(x) = 2^(-a) 2^(j-1) C(x)` is the mass of the seeker's programs whose search finds a use at `x`, and `phi(x) = C^m(x)/C(x)`. I write `T(x) = 2^(-h) 2^(j-1) C(x)` for the mass of the twin's programs whose search finds a use at `x`, and `H` for `H_C`. "The largest `j`" is `floor(log2(1/H)) + 1`.

**Bottom line.**

1. Every inequality of Proposition 14 is correct, in all three parts, and so is its proof. Its probability sentence needs its reading stated (A4). The one-line lemma of the last paragraph is correct.
2. Two sentences are wrong as written, and both concern the ratio of twin to seeker.
   - "The twin is in the posterior with `2^(h-a)` times the seeker's mass" has the exponent inverted. It stands in Section 3.5, the abstract, Section 1, Section 7, the README and the verification log (A1).
   - "More than a fraction `2^(a-h)` of the worlds making uses are twins" is false in general, and false under a test (A2).
3. The two paragraphs that state the note's answer ("So the answer depends on the regime") claim more than is proved, in three sentences (A3).
4. Four groups of sentences need rewording. They are the bound read as a bound on the seeker's block (A4), "only time stands against it" (A5), "a class of uses in rich worlds therefore has small total mass" (A6), and the scope of the time-bound claim (A7).
5. The rest is correct. Minor points are in A8 and A9.

---

## (A) Findings

### A1. The mass of the twin relative to the seeker is inverted. WRONG

**Where.** `paper/sec3-floor.tex` 373-375; `paper/main.tex` 58-59; `paper/sec1-intro.tex` 80-82; `paper/sec7-answers.tex` 33-35; `README.md` 21; also the log, `verification/README.md` 91.

**Sentence** (Section 3.5; the other five places have the same clause). "Whether or not one counts the twin as making a use itself, it is in the posterior at the context of every use the search finds, with `2^(h-a)` times the seeker's mass, and what it predicts is the continuation of a world that makes the use."

**What is wrong.** By the proposition, `S(x) = 2^(-a) 2^(j-1) C(x)` and `T(x) = 2^(-h) 2^(j-1) C(x)`. So `T(x) = 2^(a-h) S(x)`: the twin has `2^(a-h)` times the seeker's mass, and the seeker has `2^(h-a)` times the twin's. Report 4 wrote it as `S(x) = 2^(h-a) T(x)`.

Each passage contradicts its own next sentence. The bound `1/(1 + 2^(a-h) phi)` and "only if it is shorter than its twin" follow from the ratio `2^(a-h)`. With `2^(h-a)` both would be reversed. The bound is the correct one.

**Replacement.** "`2^(a-h)` times the seeker's mass" in all six places. For Section 3.5:

> ... it is in the posterior at the context of every use the search finds, with $2^{a-h}$ times the seeker's mass, and what it predicts is the continuation of a world that makes the use.

### A2. "More than a fraction `2^(a-h)` of the worlds making uses are twins". WRONG

**Where.** `paper/sec3-floor.tex` 388-390.

**Sentence.** "Second, part (c) of the proposition, which says that uses cannot be rarer than the twin is long and that more than a fraction `2^(a-h)` of the worlds making uses are twins, rests on counting the twin as a use."

**What is wrong.** Part (c) does not say this, and it is false in general. Under closure the twin's programs are the fraction `2^(j-1-h)` of the worlds that make uses, in total and at each context. This exceeds `2^(a-h)` exactly when `2^(j-1) > 2^a`, that is, when the seeker's programs outweigh the users.

Under a test, the one case in which the note proves closure, the claim fails. The seeker's programs and the twin's are disjoint sets of calling programs, so `2^(j-1) (2^(-a) + 2^(-h)) <= 1`. Hence `2^(j-1) <= 2^(a-1)`, and the twins are at most the fraction `2^(a-h-1)`.

Report 4 confirmed the clause for the case in which the seeker outweighs the users, `2^(j-1) > 2^a`, and proposed it with "then" after that condition. Without the condition it does not hold.

**Replacement.**

> Second, part (c) of the proposition, which says that uses cannot be rarer than the twin is long and that the seeker's programs found at a use weigh at most $2^{h-a}$ times the worlds that make it, rests on counting the twin as a use.

### A3. The regime paragraphs claim more than is proved

**Where.** `paper/sec7-answers.tex` 55-58; `README.md` 33. These are the passages that state the note's answer.

**Sentence (i).** "For seekers that are written down, on a machine where the search-then-continue program is no longer than the search-then-defect program, takeover is not the fate of most uses."

*What is wrong.* Proposition 14 gives, for `h <= a` and `phi = 1`: the programs of that one seeker are at most half of what prints the context and the block. Three things separate this from the sentence.

- The masses of seekers add (Section 3.5, lines 384-386). Together they exceed the twin when `sum_i 2^(-a_i) > 2^(-h)`, and this can hold with every `a_i >= h`. Two seekers of the twin's length with incomparable words are enough.
- The condition "where the users go on to print the block themselves" is missing.
- Programs that reach the contexts without this search are not bounded (lines 392-394).

**Sentence (ii).** "If short programs exist whose inhabitants do this, then without a time bound the uses they aim at are mostly taken over once those uses are rarer than the program is heavy."

*What is wrong.* The lemma gives: the program's inputs that print `x y_x` outweigh the worlds that make the uses of the class at `x`. "Mostly taken over" is, by Definition 8, more than half of `Z_m(x)`. Besides the users of the class, `Z_m(x)` contains the following, and the toy bounds none of them.

- Users at `x` outside the class.
- Programs that print `x` without making a use. Section 1 says that kappa is not bounded from below.
- With comparable contexts, the program's own inputs aimed at a longer context.

Also, the condition can hold only under a rule that does not count the program's own inputs as uses (A9d).

**Sentence (iii).** "With a tight time bound they are not."

*What is wrong.* Proved is that these programs have no mass under a schedule shorter than their start-up. Theorem 13 and the lemma are without resource bounds, and nothing is proved about what the uses receive under a schedule.

**Replacement** (Section 7; the README likewise, in its notation).

> So the answer depends on the regime, and on a premise the toy cannot check. For a seeker that is written down, on a machine where the search-then-continue program is no longer than it, and where the users go on to print the block themselves, that seeker's programs supply at most half of what the predictor returns at a use. The masses of different seekers add, so this does not show that takeover is not the fate of most uses. If short programs exist whose inhabitants do this, then without a time bound such a program outweighs the worlds that make the uses it aims at once those uses are together rarer than half its weight. It supplies the majority of what the predictor returns there if, in addition, the other programs that print those contexts and go on weigh less than its own. Under a schedule that its start-up exceeds, it has no mass.

The README's last sentence should then say that the toy turns the premise into inequalities, not into one inequality.

### A4. The bound is on the programs that supply the block, not on the block

**Where.** Proposition 14(a), `paper/sec3-floor.tex` 324-325, and "that probability" in (b), line 327; `sec3-floor.tex` 375-378; `main.tex` 59-60; `sec1-intro.tex` 82-83; `sec7-answers.tex` 35-36; `README.md` 21.

**Sentences.**

- Proposition: "the sampling predictor returns a block supplied by the seeker's programs counted in `S(x)` with probability at most `1/(1 + 2^(a-h) phi(x))`".
- Section 3.5: "So the predictor returns the block of one seeker of this kind with probability at most ...".
- Summaries: "the predictor returns that seeker's block with probability at most `1/(1 + 2^(a-h))`".

**What is wrong.** Proved is `S(x)/Z_m(x) <= 1/(1 + 2^(a-h) phi(x))`: the seeker's programs counted in `S(x)` are at most this fraction of the programs that print `x` and `m` more bits. Read as a probability, it is about the program. Suppose the sample is produced by drawing a program from the prior, conditioned on printing `x` and `m` more bits, and returning the block it prints. Then the program drawn is one of the seeker's with probability `S(x)/Z_m(x)`.

The predictor of Section 2 returns a block with no program attached, so this reading has to be stated. The proposition's wording allows it. The wording of Section 3.5 and of the summaries does not.

The probability that the block returned is the seeker's block `y = P(x)_{1:m}` is `M_U(xy)/Z_m(x)`, and `M_U(xy)` counts every program that prints `xy`:

- the same seeker under another prefix word (if `w` is a prefix word of "skip one input bit, then behave as the seeker", then `w0` and `w1` are two incomparable prefix words of the seeker, of equal length);
- other seekers with the same continuation;
- the seeker's own programs found at a comparable context, where they print `xy`;
- the twin's programs and the users, whenever a user continues with `y`.

With two prefix words of equal length, the argument bounds the programs that supply `y` only by `2/(2 + 2^(a-h) phi)`, which is larger than `1/(1 + 2^(a-h) phi)`. So the bound on the block is not proved. The note's "only if" sentence already has the right form: "supplies the majority of what the predictor returns".

The phrase comes from report 4, B1, and needs the same qualification there.

**Replacement.**

- Proposition 14(a):

  > Hence $Z_m(x)\ge S(x)+2^{-h}2^{j-1}C^m(x)$, and the seeker's programs counted in $S(x)$ are at most the fraction $1/\bigl(1+2^{a-h}\varphi(x)\bigr)$ of the programs that print $x$ and $m$ more bits: if the predictor's sample is produced by drawing such a program and returning its block, the program drawn is one of them with at most this probability.

- Section 3.5, lines 375-378: "So the programs of one seeker of this kind supply what the predictor returns with probability at most ...".
- Abstract, Section 1, Section 7, README: "... that seeker's programs supply what the predictor returns with probability at most `1/(1 + 2^(a-h))`".

### A5. "Only time stands against it"

**Where.** `paper/sec3-floor.tex` 415-418 (second bullet); `paper/sec7-answers.tex` 41 and 49-51; `paper/sec1-intro.tex` 36-37.

**Sentences.**

- "For the inhabitants of a world there is no such step ... The toy gives no bound on `p` against these."
- "Then the upper bound is gone and the reach statement remains."
- "The honest twin has no counterpart here ... What stands against such a program in the toy is only time."
- "... and a time bound as the only obstacle."

**What is wrong.** Proposition 14 does not apply to `p`; that much is right. "No counterpart" and "only" are not proved, and a counterpart exists. The step "and then continue as the program found" can be added to any program from outside, by the wrapper of Theorem 10.

- Let uses be given by a test `G`. Let `P(x)` be what the first handing-over program found for `x` prints after `x` when followed by zeros. This is a user's own continuation.
- Let `w` be a prefix word of `Tw[G,P]`, of length `c`. For every word `p` incomparable with `w` and every first hit `x` with `|P(x)| >= m`, the inputs `w p omega` print `x P(x)` whenever `p omega` prints `x`.
- So these inputs have `2^(-c)` times the mass of the inputs `p omega` that print `x`, and they are disjoint from them. The programs beginning with `p` are therefore at most the fraction `1/(1 + 2^(-c))` of the programs that print `x` and `m` more bits.

This is the twin bound with `c` in place of `h - a`. Because `c > 0`, it never excludes a majority. That is the real difference from a written seeker, whose twin can be the shorter of the two.

Two more things in the toy stand against `p`: the mass of the other programs that print the contexts (the reach has the factor kappa), and the modelling decision of A9(d).

**Replacement.**

- Section 3.5, second bullet:

  > \emph{The honest twin does not answer it.} The twin was obtained by following a search that is written down with ``and then continue as the program found''. The text of $p$ has no such step. It can be added from outside: the wrapper of \cref{thm:twin} around $p$, with a user's continuation as its payload, is an honest counterpart of length $|p|+c$, with $c$ the wrapper's length. Where uses are recognised by a test and that user goes on, the programs of $p$ therefore supply at most $1/(1+2^{-c})$ of what the predictor returns. This never excludes a majority, and the toy gives no better bound on $p$.

- Section 7, line 41: "Then the twin bound of Proposition 14 does not apply, and the reach statement remains."
- Section 7, lines 49-51: "The honest twin has no counterpart of comparable length here: a faithful version would be another world whose inhabitants choose otherwise, a costly readout from inside their simulation, or a wrapper around the whole program, which limits its part only to `1/(1 + 2^(-c))`. What is shown to exclude such a program in the toy is only time."
- Section 1, lines 36-37: "... and a time bound as the only thing shown to exclude it."

### A6. "A class of uses in rich worlds ... therefore has small total mass"

**Where.** `paper/sec3-floor.tex` 410-412 (first bullet); `paper/sec7-answers.tex` 47-49; `README.md` 22.

**Sentences.**

- "A class of uses in rich worlds, read at unremarkable places, therefore has small total mass."
- "... is rare for exactly the reason the original argument gives, since each use pays for its world and for the place of the context in it."
- "... uses in rich worlds read at unremarkable places are rare, because each pays ...".

**What is wrong.** That each use pays for its world and its place makes each use light. The inequality `H_W < 2^(-|p|-1)` is about the total mass of the class, which is the sum over its members. A class of many light uses need not be light: the class of all uses in rich worlds may carry most of `H`. So "therefore" does not follow, and the toy has no result on the mass of such a class.

The two requirements also pull against each other. The narrower the class, the lighter it is, and the more of its output `p` has to put on it, since `p` must give each context half its share of the class. That the two can be met together by a short `p` is the premise of the original argument. It is not a consequence of the toy.

Also, in Definition 6 the weight of a use is that of its calling program. "A program which names a world and the place" is the picture of Section 4.2, not part of the definition.

**Replacement.**

- Section 3.5, first bullet:

  > Think of a use as a program which names a world and the place in it where the context is read. Each use in a rich world, read at an unremarkable place, is then light. The inequality needs more: that the whole class of uses at which $p$ aims has total mass below half the weight of $p$, while $p$ gives each context at least half its share of that class. The readout of $p$ is cheap by its inhabitants' choice.

- Section 7: "... each use in a rich world, read at an unremarkable place, is light for the reason the original argument gives, since it pays for its world and for the place of the context in it; that a class of such uses is rarer than the program is heavy is part of the premise."
- README: "Each use in a rich world read at an unremarkable place is light, because it pays for its world and for the place of the context in it; that a whole class of them is rarer than the program is heavy is part of the argument's premise."

### A7. The time bound: scope, and a predictor that is not defined

**Where.** `paper/main.tex` 65-66; `paper/sec3-floor.tex` 419-423 (third bullet). The clause "a schedule not far above the cost of the honest explanation" is also in `paper/sec7-answers.tex` 51-53 and `README.md` 22.

**Sentence** (abstract). "The twin bound does not apply to it. A time bound does: such programs print nothing for a long time, and a tight schedule gives them no mass."

**What is wrong.** "It" and "such programs" are "any program of length `a` whose output puts enough mass on the contexts of a class of uses". Both statements are false of that class.

- The written seeker for the class is such a program, and the twin bound applies to it.
- Not every such program has a long start-up. "Print `x_0`, then the continuation" meets the hypothesis for the uses at `x_0` and prints at once. Section 3.4 says so: "no search is needed: print it".

The long start-up is a feature of the example. It does not follow from the hypothesis of the lemma.

**Sentence** (third bullet). "... a schedule not far above the cost of the honest explanation excludes them, and a predictor that charges for time in bits charges them the logarithm of the ratio."

**What is wrong.** The definitional part is correct (B3). Two additions go beyond it.

- What decides is the first deadline `T(1)` against the start-up of `p omega`. That the start-up exceeds the time at which the honest explanation prints its first bit is an assumption about the example, and the toy does not prove it. It holds if simulating a world is not faster than running it.
- No predictor that charges for time in bits is defined in the note, and nothing is proved about one.

**Replacement.**

- Abstract:

  > The twin bound does not apply to a program that is not a written search followed by a continuation. A time bound does where, as in this example, the program prints nothing until a long computation has run: a schedule shorter than that start-up gives it no mass.

- Third bullet:

  > \emph{A time bound does answer it.} The programs $p\omega$ of this example print nothing before the world has run long enough for its inhabitants to arise and to simulate the worlds they aim at. Under a schedule $T$ they have mass only if $T(1)$ allows that start-up (\cref{sec:time}). A schedule whose first deadline is below it excludes them, and it still admits the honest explanation if that prints its first bit sooner.

  Delete the clause on the predictor that charges for time in bits, or add "(such a predictor is not defined or analysed in this note)".

### A8. Theorem 13(b), the parenthesis: "only if the rule contains the seeker's programs"

**Where.** `paper/sec3-floor.tex` 292-294.

**Sentence.** "The world `y 0^infinity` prints the context and `y` again; it makes a critical use again only if the rule contains the seeker's programs, as a rule given by a test does."

**What is wrong.** A minor point. By Definition 6 the world makes a critical use exactly if it begins with a calling program. For the blocks built in the proof, `y 0^infinity = q e(j) omega_{1:r} 1 0^infinity`. The seeker's program `q e(j) omega_{1:r}` is one prefix that can be a calling program, but not the only one. A rule can instead contain `q e(j) omega_{1:r} 1` with context `x`, and then it cannot contain the seeker's program, because calling programs are prefix-free. `SR_m(x)` may also contain blocks that this seeker did not supply. So the condition is sufficient, not necessary.

The reworded sentence before it and "It exceeds 1 only if uses are rarer than the seeker is long" are correct. The factor exceeds 1 only if `j >= |q| + |e(j)| + 3`, and then `H <= 2^(1-j) <= 2^(-|q|-|e(j)|-2)`.

**Replacement.**

> The world $y0^\infty$ prints the context and $y$ again; it makes a critical use again exactly if it begins with a calling program, as it does for the blocks built in the proof when the rule contains the seeker's programs, which a rule given by a test does.

### A9. Small points

**(a) "Rarer than the seeker is long" is one bit off.** `paper/sec3-floor.tex` 356-357; `main.tex` 53-54; `sec7-answers.tex` 24-25; `README.md` 18. `S(x) > C(x)` holds exactly when `2^(j-1) > 2^a`, which for the largest `j` is `H <= 2^(-a-1)`. For `2^(-a-1) < H < 2^(-a)` uses are rarer than the seeker is long, `j = a + 1`, and `S(x) = C(x)`. Line 380 gives the exact condition. Replacement: "once critical uses are rarer than half the seeker's weight, `H <= 2^(-a-1)`, the seeker's own programs outweigh the users at their contexts".

**(b) The second "only if" condition needs the hypothesis of part (b).** `paper/sec3-floor.tex` 378-380; `sec7-answers.tex` 37; `README.md` 21. "Shorter than its twin" follows from part (a). "`2^(j-1) > 2^a`" follows from part (b), which assumes that no calling program is comparable with a program of the seeker. Without that, `Z_m >= max(S, C^m)` gives only `2^(j-1) >= 2^a`. Replacement: "... only if it is shorter than its honest twin and, when the users' programs are not among the seeker's, critical uses are rarer than the seeker is long, `2^(j-1) > 2^a`".

**(c) `C(x)` in place of `C_W(x)`.** `paper/sec1-intro.tex` 84; `sec7-answers.tex` 42; `README.md` 22. Section 3.5 has `C_W(x)/(2 H_W)`, and these demands sum to 1/2. With `C(x)` they sum to more than 1 when the class holds less than half of the users at its contexts, and the hypothesis then cannot be met when the contexts are incomparable. Replacement: "puts on each context of a class `W` of uses at least half that context's share `C_W(x)/H_W` of the class".

**(d) The regime `H_W < 2^(-|p|-1)` needs a rule that does not count the inputs of `p` as uses.** `paper/sec3-floor.tex` 406-408, and the summaries of it. If the inputs `p omega` that print `x y_x` are themselves worlds that make a use of the class at `x`, then `C_W(x) >= 2^(-|p|) Q(x) >= 2^(-|p|) C_W(x)/(2 H_W)`, so `H_W >= 2^(-|p|-1)`. Under a test this is the case. The note says the corresponding thing for written seekers (lines 390-392). Add after line 408: "This requires that the rule does not count the programs of $p$ as making these uses; under a test it does, and then $H_{\mathcal W}\ge2^{-|p|-1}$."

**(e) Not an error.** In the last sentence of "What one seeker reaches" (lines 364-366), "where the users go on" is not needed. The condition is about the programs that print the context, and the twin's programs found at `x` print `x` whether or not the user goes on.

---

## (B) Answers to the questions put

**B1. Is "`v_h` incomparable with `v`" sufficient for the disjointness used in (a)?** Yes. The two sets of inputs lie in the cylinders of `v` and `v_h`, which are disjoint. Nothing else is used. The hypothesis is stronger than needed: it would be enough that `v e(j)` and `v_h e(j)` are incomparable.

**B2. Is "`Q(x) >= C_W(x)/(2 H_W)` on `W`" satisfiable by one program?** Yes, and no extra condition is needed for the lemma.

- Each calling program has one context, so `sum_x C_W(x) = H_W` and the demands sum to exactly 1/2. When the strings `x y_x` are pairwise incomparable the events are disjoint, and the budget is 1.
- If `W` can be enumerated, the seeker of Theorem 13(a) built for `W` meets the hypothesis, since it prints `x P(x)` with probability at least `2^(j_W - 1) C_W(x) > C_W(x)/(2 H_W)`. Its length contains a description of `W`.
- Comparable contexts do no harm. The events are then nested or disjoint, and the lemma only bounds masses from below.

Three conditions are needed for what is built on the lemma.

- **Existence.** For a `W` that cannot be enumerated, or a `p` that does not contain a description of `W`, existence is the premise, not a result.
- **Random input.** A `p` on which `U` reads nothing more prints one stream. It meets the hypothesis only for contexts along that stream, in effect for one use. To aim at a class with incomparable contexts, the world must take the rest of the input as its randomness.
- **From "outweighs the users" to a majority.** This needs pairwise incomparable contexts in `W`, and that everything else printing `x` and `m` more bits weighs less than the inputs of `p` that print `x y_x`. This is the sufficient condition of "What one seeker reaches", and A3(ii) is where it is missing. A9(d) applies as well.

**B3. Do programs `p omega` that print nothing before step `sigma` have no mass under a schedule with `T(1) < sigma`?** Yes, by Definition 1. Membership in `E(x)` for nonempty `x` requires `t_U(omega, 1) <= T(1)`. If the first output bit is written at step `sigma` or later, the input lies in no `E(x)` with nonempty `x`, and it contributes nothing to `xi(x)`, `Z_m(x)` or `pi_m`. This is the second observation of Section 4.4. The statement covers exactly the inputs with that property (A7).

**B4. Derivations of what was found correct.**

- *Proposition 14(a).* After `e(j)`, the inputs of the twin whose point falls on the interval of `p` have measure `2^(j-1-|p|)`. The search reads exactly the bits that fix `p`, so the rest of the input is fresh. The part that prints `m` more bits therefore has measure `2^(j-1-|p|)` times the probability that the world `p omega'` goes on. Summing over the `p` with context `x` gives `2^(j-1) C^m(x)`. The seeker's programs counted in `S(x)` print `x P(x)` with `|P(x)| >= m`. So `Z_m >= S + 2^(-h) 2^(j-1) C^m`, and `S/Z_m <= 1/(1 + 2^(a-h) phi)`.
- *Proposition 14(b).* The hypothesis makes the worlds that make uses disjoint from the seeker's inputs that find one. So `Z_m >= S + C^m`, and `S/(S + C^m) = 1/(1 + 2^(a+1-j) phi)`.
- *Proposition 14(c).* The twin's programs are pairwise incomparable, with weights that sum to `2^(-h) 2^(j-1) H`. If they are calling programs this is at most `H`, so `2^(j-1) <= 2^h`. For the largest `j`, `H > 2^(-j) >= 2^(-h-1)`. Then `S(x) <= 2^(h-a) C(x)`. Under a test the twin's programs are handing-over programs.
- *"At most `H`".* The event is contained in "the world makes a critical use".
- *"`kappa(x) < 2^(a+1) H`".* `2^(-a) 2^(j-1) C(x) <= M_U(x P(x)_{1:m}) <= M_U(x)`, and `2^(-j) < H`.
- *The fixed-context program.* If every input beginning with a word of length `a'` prints `x_0 y`, then `M_U(x_0 y) >= 2^(-a')`, and the reach is at least `C(x_0) 2^(-a')/M_U(x_0)`.
- *The sufficient condition for `W`.* With pairwise incomparable contexts, the seeker's programs that print `x` are those found at `x`, and all of them print the payload. Their mass exceeds `2^(-a_W) C_W(x)/(2 H_W)`.
- *Its last sentence.* The twin's programs found at `x` are other programs that print `x`, of mass `2^(-h_W) 2^(j_W - 1) C_W(x)`. The condition then forces `2^(-h_W) < 2^(-a_W)`.
- *"Together they exceed the twin when `sum_i 2^(-a_i) > 2^(-h)`".* The masses at `x` are `2^(-a_i) 2^(j-1) C(x)` and `2^(-h) 2^(j-1) C(x)`.
- *"Exactly `2^(-a) 2^(j-1) <= 1/2`" under a test.* First hits are incomparable, so the seeker's programs that print `x` are those found at `x`. The inequality is the one derived in A2.
- *The lemma.* `M_U(x y_x) >= 2^(-|p|) Q(x)`, and `2^(-|p|) C_W(x)/(2 H_W) > C_W(x)` exactly when `H_W < 2^(-|p|-1)`.

---

## (C) Verdicts

| Item | Verdict |
|---|---|
| 1. Proposition 14, parts (a), (b), (c) and proof | CORRECT BUT GAP. Every inequality is correct and the incomparability hypothesis is sufficient. The probability sentence is correct only as a statement about the program that supplies the sample (A4). |
| 2. Theorem 13(b), reworded sentence and parenthesis | CORRECT BUT GAP. The reworded sentence and "exceeds 1 only if" are correct. "Only if the rule contains the seeker's programs" is a sufficient condition, not a necessary one (A8). |
| 3. "What one seeker reaches" | CORRECT. Every claim checked holds. "Rarer than the seeker is long" must be read as `2^(j-1) > 2^a` (A9a). |
| 4. "What happens to most uses" and "Three limits of this bound" | WRONG in two sentences: "`2^(h-a)` times the seeker's mass" (A1) and "more than a fraction `2^(a-h)` ... are twins" (A2). The two probability bounds, the "only if" sentence under the hypothesis of part (b) (A9b), the sentence on small `phi`, "`sum_i 2^(-a_i) > 2^(-h)`" and "exactly `2^(-a) 2^(j-1) <= 1/2`" are correct. "Returns the block of one seeker" needs the reading of A4. |
| 5. "Seekers that are not written down" | CORRECT BUT GAP. The lemma and "outweighs ... as soon as `H_W < 2^(-|p|-1)`" are correct, and the hypothesis is satisfiable (B2). First bullet: "therefore has small total mass" is not proved (A6). Second bullet: a weak bound does exist (A5). Third bullet: correct by Definition 1, but the start-up is an assumption and the predictor that charges for time is not defined (A7). The regime needs A9(d). |
| 6. Summaries | WRONG. The inverted ratio stands in the abstract, Section 1, Section 7 and the README (A1). The regime paragraphs of Section 7 and the README claim more than is proved (A3). Also "returns that seeker's block" (A4), "only time" and "only obstacle" (A5), "is rare for exactly the reason" (A6), the abstract's "such programs" (A7), and `C(x)` for `C_W(x)` (A9c). The Reach bullets (apart from A9a), the first half of "Read in the toy" and "What the toy does not settle" say no more than is proved. The inverted ratio is also in the log, `verification/README.md` 91. |

**Not checked.** Theorems 12 and 13 beyond what items 1 to 5 use; any resource-bounded version of Theorem 13 or Proposition 14 (none is claimed); Sections 4 to 6; the computation.
