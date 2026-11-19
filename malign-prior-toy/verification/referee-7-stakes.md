# Referee report 7 on Section 3.7, "Concentration where the most is at stake": the repairs after round 6, and the summaries

Date: 2026-11-14. Written by an AI referee that had not seen the note before; not reviewed by a human.

**Version refereed.** The working tree at commit `d0060fdf` ("apply the sixth referee round to the summaries") on `claude/lucid-hypatia-j4jg12`.

**Scope.** A narrow final check, in three parts.

1. The parts of `paper/sec3b-stakes.tex` that were added or rewritten after round 6: part (A3) of the lump theorem and its proof; the example `ex:stakes`, its title, items (d), (e), (f) and the proof; the proposition `prop:repeat` and the text after it; the sentence on rules given by a test after `prop:twin-stakes`; the remark on the lineage; the closing paragraph. I compared the file with the version of round 6 (`6b534400`) sentence by sentence and also read every other sentence that changed.
2. Every sentence of the summary passages on this topic: the abstract bullet "Aiming at high stakes" (`paper/main.tex` 78-93); in `paper/sec1-intro.tex` the paragraph "Two further questions" (46-49), the results item 8 (112-137) and the sentences on Section 3.7 under "What is new and what is not" (196-206) and "What the toy does not settle" (229-231); in `paper/sec8-answers.tex` lines 94-149 and the seventh open item (278-281); in `README.md` lines 28-35, 64 and 93-96; in `verification/README.md` the rows on stakes of the Round 6 table (140-146).
3. The sentence of `paper/sec2-toy.tex` (65-68) that lists the results which use universality.

Statements that round 6 confirmed and that have not changed were not checked again.

**Method.** Each statement in scope was derived by hand before its proof was read. Four Python scripts, run in a scratch directory and not part of the repository, checked what can be computed (listed at the end). The "machines" in them are lookup tables of weights and output strings, or closed-form masses; no script executes a string as a program.

**Names.** (W1), (W2), (W3) are the three meanings of "they win" of the section; (INC) is "the contexts are pairwise incomparable"; "the rest" of an attacker at a context is everything else that prints the context and $m$ more bits.

## Verdict

Nothing in the repaired mathematics is wrong. Part (A3) of the lump theorem and its proof are correct, also when $k_F=\infty$. Items (d), (e) and (f) of the example and the new printed proof hold with every constant, and (e) is in fact slightly stronger than what round 6 proposed ((W3) needs $|v_A|<|v_D|$, not only $|v_A|\le|v_D|$). Both parts of `prop:repeat` hold, the two-class formulas of the third reading hold with $n\varrho_1$ in place of $\varrho_1$, and the sentence on tests and the remark on the lineage are now right. The sentence of Section 2 on universality is complete.

The errors are again in the summaries, and they are of the kinds found before. The most serious is new with the repair: three summaries state the new condition for "most uses of a class end in a takeover" without the hypothesis that the contexts are pairwise incomparable, and without it the sentence is false (finding 1, with a counterexample). Four passages say that "enough weight wins" is proved in the allocation model without the condition that the follow ratio is below one, although the theorem they cite says that no weight wins otherwise, and although the toy's own lower bound puts a written seeker in exactly that case when its twin is no longer than it (finding 3). "Without resource bounds" was restored for the sentences on aiming only (finding 4). The README brings back "the picture fails" (finding 5), and its Status section does not list the verdict among the things that are argued (finding 6). Section 1 says that everything new in the research file was refereed, which holds only for the items the paper uses (finding 7). Three rows of the Round 6 table in `verification/README.md` say slightly more than happened (finding 8). The rest is small (findings 2, 9 to 14).

There are 14 findings: 3 overclaims, 3 gaps, 3 unclear sentences and 5 minor points.

---

## Findings

Severity: **overclaim** (more is said than is proved), **gap** (a hypothesis or an item is missing), **unclear**, **minor**.

### 1. The condition for "most uses end in a takeover" is stated without "pairwise incomparable", and is false without it. Overclaim

**Where.** `paper/main.tex` 84-85; `paper/sec8-answers.tex` 107-108; `README.md` 30. The same hypothesis is missing in `paper/sec1-intro.tex` 119-121 (see finding 2) and in the row of `verification/README.md` 142.

**Sentence.** "Most uses of a class end in a takeover only if the takeover programs at its contexts weigh more than half its users, where the users go on without taking over."

**Problem.** This is (A3) of `thm:lump` for $F$ the set of inputs that print a context of the class followed by a takeover block. (A3) is stated for "a class whose contexts lie in $\mathcal M$", where the strings $xy$ ($x\in\mathcal M$, $y\in A(x)$) are pairwise incomparable, and its proof uses conservation, $\sum_x\mu_F(x)\le B$, which can fail for contexts nested through a takeover block (`prop:stakes-basic`(b)). The section's closing paragraph keeps the hypothesis ("a class of such uses", line 493). The three summaries drop it. In each of them the preceding sentence has "a set of pairwise incomparable uses", but this sentence starts afresh with "a class".

Without the hypothesis the sentence is false. Take $m=1$, the takeover block $1$ at every context, and the contexts $x_1=0$, $x_{i+1}=x_i10$ for $i<128$. Let the calling program of user 1 be $0$, of weight $\frac12$, and those of users $2,\dots,128$ be the strings $1b$ with $b$ of seven bits, each of weight $2^{-8}$; user $i$ prints $x_i$ and then $0^\infty$. Every user goes on with the block $0$, which is not a takeover. But users $i+1,\dots,128$ print $x_i1$. So
$$\theta(x_1)=\tfrac{127}{255},\qquad\theta(x_i)=\tfrac{128-i}{129-i}\quad(i\ge2),$$
the users have mass $H=\frac{255}{256}$, all inputs that print a context followed by a takeover block have mass $B=\frac{127}{256}<\frac{255}{512}=H/2$, and the average of $\theta$ over the uses is $0.727$. Most uses end in a takeover although the takeover programs weigh less than half the users. (Computed exactly. The same holds on a universal machine: with 509 users of weight $2^{-10}$ and a universal branch of weight $2^{-10}$, $B\le\frac{255}{512}<\frac{1021}{2048}=H/2$ and the average is at least $0.736$ wherever the branch puts its mass.)

**Corrected text.** In all three places: "Most uses of a class of such uses end in a takeover only if the takeover programs at its contexts weigh more than half its users, where the users go on without taking over." In `verification/README.md` 142: "... of the theorem: for a class with pairwise incomparable contexts, the takeover programs ...".

### 2. In Section 1 the condition for most uses is stated for "programs of total weight $B$", which are not said to be the takeover programs. Unclear

**Where.** `paper/sec1-intro.tex` 117-121.

**Sentence.** "Programs of total weight $B$ supply the majority of the samples at every one of a set of pairwise incomparable uses only if $B$ exceeds the mass of everything else that prints those contexts and $m$ more bits, and most uses of a class end in a takeover only if $B$ exceeds half the mass of the users of the class divided by the largest number of users per unit of that rest."

**Problem.** In the first half $B$ is the weight of an arbitrary set of programs, and the statement is about what those programs supply. The second half keeps this $B$ and speaks of the block returned ("end in a takeover"). For an arbitrary set of programs that is not (A3): with the empty set, $B=0$, and most uses can end in a takeover all the same. (A3) says that most uses of the class receive their block *from $F$* only if $B>H_{\mathcal W}/(2k_F)$; it is a statement about takeovers when $F$ is the set of takeover programs at the contexts of the class. The class must also have pairwise incomparable contexts (finding 1).

**Corrected text.** "Programs of total weight $B$ supply the majority of the samples at every one of a set of pairwise incomparable uses only if $B$ exceeds the mass of everything else that prints those contexts and $m$ more bits. They supply the sample at most uses of a class of such uses only if $B$ exceeds half the mass of the users of the class divided by the largest number of users per unit of that rest. For the takeover programs at the contexts of the class this is a condition for most of its uses to end in a takeover: where the users go on without taking over, these programs must weigh more than half the users (\cref{thm:lump})."

### 3. "Enough weight wins is proved in the allocation model": only for a follow ratio below one. Gap

**Where.** `paper/sec3b-stakes.tex` 495-496 and 516-518 ("sufficient in the model"); `paper/sec1-intro.tex` 129-131; `paper/sec8-answers.tex` 125-126.

**Sentence (section).** "The other half, that enough weight wins, is proved only in the allocation model, where the passive rest and the follow ratio do not depend on the allocation (Part B, \cref{prop:allocation})."

**Problem.** (B1) of `thm:lump` says: an allocation with the majority at every $x\in\mathcal M$ exists iff $\tau<1$ on $\mathcal M$ and $B>\sum_{\mathcal M}O_0/(1-\tau)$; "where $\tau\ge1$ no weight gives the majority". So in the model as described in these four passages, with a follow ratio that is fixed and otherwise arbitrary, it is not true that enough weight wins. The condition matters for the reading of the section. By `prop:twin-stakes`(a) the rest of a written seeker follows it at a ratio of at least $2^{a-h}\varphi_g$, and this is at least one when the twin is no longer than the seeker and the users go on, which is the case the same paragraph discusses. The abstract (89-90) and `README.md` 33 say "a model in which the rest does not depend on the attacker's allocation", which is the passive case and is correct.

**Corrected text.**

* `sec3b-stakes.tex` 495-496: "The other half, that enough weight wins, is proved only in the allocation model, where the passive rest and the follow ratio do not depend on the allocation, and there only for a follow ratio below one; where the rest follows at a ratio of one or more, no weight gives the majority (Part~B, \cref{prop:allocation})."
* `sec3b-stakes.tex` 516-518: "... the picture is \cref{thm:lump}: necessary in the toy for pairwise incomparable uses, sufficient in the model for a follow ratio below one."
* `sec1-intro.tex` 129-131: "The converse, that enough weight wins, is proved only in an allocation model in which the passive rest and the follow ratio do not depend on the allocation, and there only for a follow ratio below one; ..."
* `sec8-answers.tex` 125-126: "That enough weight wins is proved only in the allocation model, in which the passive rest and the follow ratio do not depend on the allocation, and only where that ratio is below one."

### 4. "Without resource bounds" covers the sentences on aiming only. Gap

**Where.** `paper/sec1-intro.tex` 112-129; `README.md` 28; `paper/main.tex` 85-89; `paper/sec8-answers.tex` 110-123.

**Problem.** The section says at its head that resources are unbounded unless a statement says otherwise. Round 6 asked for this in the summaries, and it was added in front of the sentences on aiming. The sentences on the wrapper, on the twin and on the example are without bounds too, and are not marked.

* Section 1 states its convention in line 51: "Unless said otherwise, statements are for ... the mixture $\xi$ of its programs of length at most $L$ that keep to a time schedule $T$". Item 8 says "Without resource bounds" once, in the sentence on aiming (113). The sentences "a wrapper puts $2^{-c}$ of every program's mass at a context on another block, so no takeover probability exceeds $1-2^{-c}$" (121-123), "the honest twin ... with $2^{a-h}$ times its mass" (123-125) and the example (125-129) are then, by the convention, claims about the bounded mixture. They are not proved there, and the first is false in general: under bounds the wrapper has $2^{-c}\rho(x)$ (`thm:twin`), and $\rho\equiv0$ when $T(1)<c$. Item 2 of the same list states the floor with its slack factor.
* `README.md` 28: "The statements on aiming are without resource bounds." The ceiling $1-2^{-c}$, the twin ratio and the example in the following sub-bullets are without bounds as well.
* Abstract 85-89 and Section 8, 110-123: the same sentences, unmarked. The abstract's next bullet states the wrapper with "under resource bounds this is multiplied by ...".

What does hold under any bounds: the two lump statements (A2) and (A3), by `prop:stakes-basic`(b), and the statement on uses in sequence, `prop:repeat`(b).

**Corrected text.**

* `sec1-intro.tex` 112-113: "... nothing connects it to what the world does after the use. Resources are unbounded throughout this item. A seeker can weight its search ..."
* `README.md` 28: "The statements of this item are without resource bounds."
* `main.tex` 87: "and, still without resource bounds, where the contexts are pairwise incomparable and ..."
* `sec8-answers.tex` 110: "The other half is not a theorem of the toy. What follows is again without resource bounds. That rest is not the users, ..."

### 5. "That the picture fails 'as stated'" returns in the README. Overclaim

**Where.** `README.md` 35, last sentence of the bullet.

**Sentence.** "That the picture fails "as stated" is an argument from these results, not a theorem."

**Problem.** Round 6 found "the other half fails as stated" in Section 8 and noted that no result shows that enough weight fails to win. Section 8 was changed to "Not shown; and not as stated, if the channel is taken to be the users of the high-stake class", and the section says "the answer is 'not as stated'" for that reading only, with the other reading beside it (516-519). The README keeps "fails" and drops the reading to which the verdict belongs. Calling the sentence an argument does not change what it asserts.

**Corrected text.** "That the answer is "not as stated", if the channel is taken to be the users of the high-stake class, is an argument from these results and not a theorem. If the channel is everything that prints those contexts and goes on, the picture is the lump statement: necessary in the toy, sufficient in the model for a rest that does not follow."

### 6. The Status section does not list the verdict of Section 3.7 among the things argued. Gap

**Where.** `README.md` 96.

**Sentence.** "**Argued or guessed, and marked so in the paper**: the order in which the program-side effects return under recurrence; the overall view on circuits."

**Problem.** The paper marks the answer to question 3 as "an argument and not a theorem" in two places (`sec3b-stakes.tex` 516, `sec8-answers.tex` 95-96), and the README's own bullet says so. The Status list is the place where a reader looks for what is not proved, and it omits this item.

**Corrected text.** "**Argued or guessed, and marked so in the paper**: the answer to question 3 ("not as stated", if the channel is taken to be the users); the order in which the program-side effects return under recurrence; the overall view on circuits."

### 7. "What was new in those two files ... were refereed afterwards": for the stakes file, only the items the paper uses. Overclaim

**Where.** `paper/sec1-intro.tex` 205-206.

**Sentence.** "What was new in those two files, and the two sections as printed here, were refereed afterwards (`verification/referee-6-*.md`)."

**Problem.** Two things.

* The Provenance section of `research/stakes-final.md` lists nine statements or proofs that no referee had seen. Round 6 checked the four that the paper uses. `referee-6-stakes-proofs.md` says of the other five (the bound $0.43\,B$, Theorem 10(B5), the following-rest clauses of Proposition 12(4), Theorem 15(4), the last sentence of Proposition 25(5)) that they "are not used in the paper and were not checked". `verification/README.md` and the errata of the research file say this correctly ("that the paper uses").
* "The two sections as printed here" were not refereed in round 6. Part (A3), the items and the proof of the example and several paragraphs were written after it. They are checked in the present report.

**Corrected text.** "The items that were new in those two files and are used here, and the two sections as they then stood, were refereed afterwards (\texttt{verification/referee-6-*.md}); the repairs made after that round were checked once more (\texttt{verification/referee-7-*.md}). The Provenance section of \texttt{stakes-final.md} lists five further items, not used here, that no referee has read."

### 8. Three rows of the Round 6 table say more than happened. Minor

**Where.** `verification/README.md` 144, 145, 146; also 142 and the table as a whole.

**Problem.**

* **144**, "hypotheses dropped ... Restored or corrected at each place." Restored in the section. In the summaries the following are still missing: "without resource bounds" outside the sentences on aiming (finding 4); the hypothesis that a program can enumerate the stakes, in three summaries (finding 9a); pairwise incomparable contexts in several sentences (findings 1, 9c, 9d, 9e).
* **145**, "Section 8 and the README now say that the verdict is an argument from the results". Section 8 does. The README says that "the picture fails 'as stated'" is an argument (finding 5).
* **146**, "both referees say that no statement is made ambiguous". `referee-6-stakes-claims.md` says so (its finding 16). `referee-6-stakes-proofs.md` lists the clashes under "small points" (its finding 16) and gives no such judgement.
* **142** describes (A3) without the hypothesis on the contexts (finding 1).
* The file says in its first paragraph that it "lists what each round found". Four accepted findings on Section 3.7 have no row: that "the one reading under which repetition lowers the bar" was true of the weight and not of the share; that the pointer statement on what one word can realise was proved in one direction only; that the open items were narrower than those of the research file; and the sentence on what was refereed (finding 7 above). All four were acted on.

**Corrected text.** 144: "Restored or corrected in the section; the residues in the summaries are listed under round 7." 145: "Section 8 now says that the verdict is an argument from the results and states the model result beside it; for the README see round 7." 146: "Not changed: they are the symbols of the corrected account; one referee says that no statement is made ambiguous, and the other lists the clashes as small points." Add a row "Stakes: further prose" for the four findings.

### 9. Smaller conditions dropped in the summaries. Minor

* **(a) Stakes that a program can enumerate.** `paper/sec1-intro.tex` 113-115, `paper/sec8-answers.tex` 99-101, `README.md` 29: "aiming at the uses with stake at least $n$ costs about $2\log_2n$ bits". `prop:aim-cost` assumes that the pairs $(p,n)$ with $r(p)\ge n$ can be enumerated; for an arbitrary labelling the class need not be enumerable and cannot be aimed at. The abstract ("a label that a program can recognise from below") and the closing paragraph of the section ("for stakes that a program can enumerate") have the hypothesis. *Corrected:* "aiming at the uses with stake at least $n$, for stakes that a program can enumerate, costs about ...".
* **(b) The twin's part of the rest.** `paper/main.tex` 85-87: "Part of the rest follows the seeker: its honest twin, at a ratio set by the two lengths in which neither the aim nor the stake occurs". The rest consists of what goes on printing. The twin's programs that go on have $2^{a-h}\varphi_g(x)$ times the seeker's mass (`prop:twin-stakes`(a)), and by part (b) of that proposition the aim enters through $\varphi_g$: an aim that prefers users which stop printing weakens its own twin (section, 281-283). *Corrected:* "its honest twin, which is in the posterior at each use with $2^{a-h}$ times the seeker's mass, a factor in which neither the aim nor the stake occurs for seeker and twin built in the same way, and which belongs to the rest where the users go on printing".
* **(c) Pairwise incomparable contexts for the twin bound.** `paper/sec1-intro.tex` 123-125; `README.md` 31 and 35; `paper/sec8-answers.tex` 145-147. `prop:twin-stakes`(a) bounds the seeker's share under (INC); without it the bound is for the seeker's programs whose search finds a user at that context, as the section says (284-285). Section 8 has the hypothesis at 111-112 and not at 145-147. *Corrected:* add "for pairwise incomparable contexts" to "where the users go on printing, it supplies the majority only if it is shorter than its honest twin" (README 35, Section 8, 146), and to the twin sentence in Section 1 and README 31.
* **(d) "By a factor of up to $2^{-a}/H_{\mathcal W}$, which is unbounded as the class gets rarer."** `paper/sec8-answers.tex` 102-104. The upper bound is `thm:weighted`(b), which is under (INC). And $a$ grows with the class: it contains the description of the class and the bits that name its scale. For the classes "stake at least $n$" and the seeker of `prop:aim-cost`(a) the factor is, under (INC), below $2^{-|v'|-2}/(n^2j_n^2\,C(\mathcal W_n))$, so it grows without bound only if the classes are rarer than about $n^{-2}$; for classes of mass about $n^{-3/2}$ it tends to $0$ as they get rarer. *Corrected:* "by a factor which for pairwise incomparable contexts is at most $2^{-a}/H_{\mathcal W}$, and which is large only for classes that are rare compared with the bits that describe them (it is of order $2^n/n^2$ in \cref{ex:stakes})".
* **(e) "It must outweigh the whole rest of the uses at which it supplies the majority."** `paper/sec8-answers.tex` 141-143. The sum needs conservation; the section has "on a set $\mathcal M$ of pairwise incomparable contexts" (471). In the sentence of Section 8 the condition comes only after the second clause. *Corrected:* "What is proved for it, for pairwise incomparable contexts, is that it must outweigh the whole rest of the uses at which it supplies the majority, and that its share is at most $1/(1+2^{-c})$ if some computable block is not a takeover."
* **(f) "A context that is cheap to aim at is also cheap to print without a takeover."** `paper/sec8-answers.tex` 110-111. In the section this is a remark on the example and has its mirror image beside it ("and cheap to print with one", 342-344). In general it is `prop:stakes-basic`(c), under (INC) and for a computable block that is not a takeover, and by the same proposition the reverse holds with a payload that is a takeover. Each side keeps $2^{-c}$ of the other; that supports "open" and not one side. Round 6 made this point (claims report, finding 8). *Corrected:* "A context that is cheap to aim at is also cheap to print without a takeover, and cheap to print with one (\cref{ex:stakes})."

### 10. "Its word is shorter than that of a program that prints the same contexts." Unclear

**Where.** `paper/sec8-answers.tex` 119-121; `README.md` 32.

**Problem.** The seeker's word is $v_A\,\bar e(n)$, and its length contains $n$. What `ex:stakes`(e) compares is $|v_A|$ with $|v_D|$, the prefix words of the two machines $\mathsf{At}$ and $\mathsf{Ho}$; the codes of $n$ cancel at $x_n$ and are bounded against each other elsewhere. A program of $\mathsf{Ho}$, $v_D\,\bar e(k)$, prints one context, not "the same contexts". The sentence then says that $n$ does not occur in the comparison, which is true of the two machine words and not of "its word".

**Corrected text.** Section 8: "It has the majority at most of the class only if the prefix word of its machine is shorter than that of a machine which prints the same contexts without taking over, by more than one bit for the context that carries half the class." README: the same without the last clause.

### 11. "'Run more than $n$ times' helps in the toy in one way." Minor

**Where.** `paper/sec3b-stakes.tex` 510-512.

**Problem.** Two things, both of which the section says correctly a page earlier. The reading with $n$ samples at one context is a protocol outside `def:call` (443-444), so "in the toy" needs that qualification; round 6 had the words "in the toy" removed from the heading of `prop:repeat`(a) for this reason. And along one world the shares at the uses accumulate in the same way (441-442); what falls in the first reading only is the weight. Section 1 (131-135) and Section 8 (133) have it right ("lower the weight that is needed").

**Corrected text.** "``Run more than $n$ times'' lowers the weight that is needed in one reading, which is a protocol outside \cref{def:call}: if one context is sampled $n$ times and one takeover sample suffices, a share of about $\ln2/n$ per sample gives a takeover with probability above $\frac12$, with or without aiming. Along one world the shares at successive uses add up in the same way, and the weight needed does not fall."

### 12. The abstract attaches the price $2\log_2n$ to "any class of uses that a computation can recognise". Unclear

**Where.** `paper/main.tex` 79-81.

**Sentence.** "... a seeker can aim at any class of uses that a computation can recognise, for instance those with stake at least $n$, for about $2\log_2n$ bits and the bits that name the scale of the class."

**Problem.** The price of an arbitrary class is a description of the class and the bits that name its scale (`thm:weighted`(a)). The $2\log_2n$ bits are the description of the classes "stake at least $n$" (`prop:aim-cost`(a)). Section 1 separates the two.

**Corrected text.** "... a seeker can aim at any class of uses that a computation can recognise, at the price of a description of the class and of the bits that name its scale; for the uses with stake at least $n$ the description costs about $2\log_2n$ bits."

### 13. The title of the example, "the outcome is open". Minor

**Where.** `paper/sec3b-stakes.tex` 292.

**Problem.** The section keeps three meanings of "win" apart, and the example decides one of them: (W1) fails for $F_n$ for every $n$ (item (d)). It also decides (W2) by prior mass and (W3) for $F_n$ on every machine with $|v_A|\ge|v_D|$ (item (e)). What is open is most uses on machines where the necessary conditions hold, and the block returned.

**Corrected text.** "A class of mass $2^{-n}$, aimed at with $2\log_2n$ bits: no majority at every use, and most uses are not decided".

### 14. Outside the listed scope: the summary of Section 3.7 inside Section 7. Minor

**Where.** `paper/sec7-circuits.tex` 822-824.

**Problem.** "a seeker for a rare class is repaid for the rarity among the users" is the wording that round 6 found unclear in Section 3.7 and that was replaced there by "measured by its users alone" (the factor is $1/C(\mathcal W)$, not $H_{\mathcal C}/C(\mathcal W)$). "Without resource bounds" is missing.

**Corrected text.** "In the program toy, without resource bounds, a seeker for a rare class is repaid for the rarity of the class measured by its users alone, and ..."

---

## Passages found correct

**Section 3.7, repaired parts.**

* **`thm:lump`(A3) and its proof** (101-106, 118-121). $w_F\le\mu_F/O_F$, so $\sum_xC_{\mathcal W}(x)w_F(x)\le k_F\sum_x\mu_F(x)\le k_FB$ by conservation on $\mathcal M$; (W3) for $F$ then needs $B>H_{\mathcal W}/(2k_F)$, strictly. A user that goes on with a block outside $A(x)$ lies in $E(xd)$ for some $d\notin A(x)$, which is disjoint from every $E(xy)$ with $y\in A(x)$, so it is in the rest of every $F$; hence $k_F\le1/\underline\varphi$. With $k_F=\infty$ the statement is empty and true. No violation on random table machines (4000 draws, 367 of them with (W3) for $F$).
* **The text after the theorem** (127-136): $w_F=\theta$ and $B$ the total mass of the takeover programs for $F$ the inputs that print a context of $\mathcal M$ followed by a takeover block; the conditional form of $O_F\ge\varphi C$; the reading of (A3).
* **The sentence after `prop:stakes-basic`** (72-75) and the three sentences on (M1), (M2) and the benchmark (85-93).
* **`prop:twin-stakes`(d) and the sentence on tests** (259-261, 276-277, 288-291). Both sides are averages of $\theta$ with the weights $Z_m(x)$; (W3) for the class of all users at those first hits has the weights $M_U(x)$.
* **The paragraph after `prop:twin-stakes`** (280-287): the seeker has $2^{h-a}/\varphi_g$ times its twin's mass; the aim enters through $\varphi_g$ only; the bound needs (INC) and is for one seeker's supply.
* **`ex:stakes`, items (a) to (f) and the proof** (292-336). Every constant re-derived. (d): $B_n/O(\mathcal W_n)<2^{\delta+2}/n$; the bound for every attacker of weight at most $2^{-|v_D|-3}/n$; $\mu_{F_n}(x_k)/O_{F_n}(x_k)<2^{\delta+2}(k/n)^2\,2^{-(k-n+1)}$; the share $2^{-(k-n)}$ of the uses from $x_k$ on. (e): $|\bar e(k)|-|\bar e(n)|\le k-n+1$ for $k\ge n$ (also checked for all $n<1500$ and $k<n+1500$); $O/\mu\ge2^{-\delta}$ at every use and $\ge2^{1-\delta}$ at $x_n$; $x_n$ carries exactly half the prior mass, so (W2) by prior mass needs $\delta>1$, and any majority at all needs $\delta>0$, so (W3) and also (W2) by stake need $\delta>0$. (f): $s(x_k)/O_F(x_k)\le2^{|v_D|-|u|+3}k^3\,2^{-k}$ for every $F$; with $\varrho(x_k)\to0$ and $\eta_B>0$ only finitely many contexts are attacked. Exact arithmetic for eight choices of $(|u|,|v_A|,|v_D|)$ and six values of $n$: no assertion failed. With $\delta=1$ the proved rest still allows an average share of $0.545$ (at $|u|=30$, $|v_A|=10$, $|v_D|=11$, $n=1$), so "(W3) requires $|v_A|<|v_D|$" cannot be sharpened from what is proved.
* **The paragraph after the example** (338-345), including "$\theta(x_k)>\frac12$ requires $M_U(x_k1^m)>2^{-|v_D|-|\bar e(k)|}$".
* **`prop:allocation`**, the changed sentences only (361, 377, 398-399): the convention $w^*=0$ where $\varrho=0$; $\beta(\eta)\le S/(4\eta)$; allocations of infinite value when $\sup_xs(x)=\infty$ and $O_0\le1$.
* **`prop:repeat`(a), (b) and the proof** (400-432). (a): the threshold $\theta>1-2^{-1/n}$ and $1-2^{-1/n}\le\ln2/n$. (b): $\prod_ia_i\ge\xi(z)/\xi(x_1)$; the sum of the takeover probabilities; $\prod_i(1-w_i)\ge e^{-B/\xi(z)}$ from $R_i\ge\xi(z)$ and $\sum_i\mu_i\le B$; $R_i\ge2^{n-i}\xi(z)$ and $B>(2^n-1)\,\xi(z)$. No violation on 6000 random table mixtures (200 with the majority at all uses; smallest $B/((2^n-1)\xi(z))$ found $1.27$).
* **The text after `prop:repeat`** (434-456). The passive condition $B>(2^{1/n}-1)\,O(\mathcal M)$ with $2^{1/n}-1\le1/n$. The third reading: with $\zeta'=\sqrt{\varrho_2/(n\varrho_1)}$ the whole weight goes to $\mathcal X_1$ while $B\le O_1(1/\zeta'-1)$, the optimiser has the majority on $\mathcal X_1$ iff $B>O_1+O_2(2\zeta'-1)_+$, and this is $B>O_1$ once $n\ge4\varrho_2/\varrho_1$; I re-derived the two-class formulas and compared them with water-filling by bisection on 2621 random instances, without a mismatch. "Moves weight towards the class" holds beyond the two-class case: if the stakes of a class are multiplied, the price cannot fall, so the weight elsewhere cannot rise; on random instances with arbitrary stakes (2000 draws) the weight on the class never fell as $n$ grew. The remark on the lineage: by `prop:lineage`(b) the context is $x$ in every generation that follows a self-reproducing block, so the samples come from one law and no weight is divided.
* **The closing paragraph** (488-519), except for findings 3 and 11. In particular: the two necessary conditions with their hypotheses (491-495); "which requires that its programs are not counted as users" (if they were counted, $H_{\mathcal W}\ge2^{-a}2^{j-1}H_{\mathcal W}$ would give $H_{\mathcal W}>2^{-a-1}$); the wrapper and the twin with (INC); "by `thm:machine` which block has the majority at the first hits of a test depends on the choice of machine" (part (i) with $k\ge1$ gives any payload a share of at least $\frac23$).
* **Other changed sentences** that I read: the statement taken from Propositions 16 and 18 of the research file (229-235), which now has the one direction that is proved; the three variants (458-486), with the two constant payloads for the ceiling of a program whose aim is not written.

**Summaries.**

* **Abstract** (78-93): the stake as a label a program can recognise; "once the class is rarer than half the seeker's weight"; the necessary condition for the majority at every use; the wrapper with both hypotheses; "a model in which the rest does not depend on the attacker's allocation" and the square-root law; the sentence on $n$ samples. (Findings 1, 4, 9b, 12 for the rest.)
* **Section 1**: "Two further questions" (46-49); in item 8 the factor $2^{-a-1}/H_{\mathcal W}$, the wrapper sentence with its two hypotheses, the example ("lacks the majority at some use ... for every $n$, possibly only at uses that carry a small share"; "only if a condition on two constants ...; whether it has is not decided"), the square-root law, and the three readings of repetition (131-137); the sentence under "What the toy does not settle" (229-231). (Findings 2, 3, 4, 7, 9a, 9c for the rest.)
* **Section 8** (94-149): the opening verdict and its status; "once the class is rarer than half its weight"; "at most $2^{h-a}$" under closure; the necessary condition for the majority at every use; the twin sentence at 111-115 with all its hypotheses; the wrapper sentence; the example, with "necessary and not sufficient"; $b/(1+b)$ for a rest that does not follow and a weight spread in proportion; the order by stake per unit of rest and "this optimum leaves the highest stakes alone"; the paragraph on the readings of repetition; the seventh open item (278-281), which now names the open points of the research file that round 6 asked for. (Findings 1, 3, 4, 9, 10 for the rest.)
* **README**: the sub-bullets on aiming, on the example, on the model (with "has the majority where $\varrho>4\eta$", passive case) and on "run more than $n$ times"; the line under "What is not settled" (64); in the Status section the list under "Proved here", each item of which has a proof printed in the paper (the example now has one, and "two readings of repetition" is right), and the statement that the paper says at each place where a statement is taken from `research/` (it does, at 229-230, 389-390 and 458-459 of the section). (Findings 1, 4, 5, 6, 9, 10 for the rest.)
* **`verification/README.md`**, Round 6 table: the rows on the reversed condition (140), on the example (141), on the missing condition for most uses (142, apart from the hypothesis named in finding 1) and on the third reading (143) describe the findings and the resolutions truthfully. The verdict paragraph is accurate for Section 3.7, including "that the paper uses".
* **Directions of ratios.** Twin over seeker $2^{a-h}$, seeker over users at most $2^{h-a}$ under closure, seeker over users up to $2^{-a}/H_{\mathcal W}$, attacker over rest in the example below $2^{\delta+2}/n$: all the right way round in every passage in scope.
* **Dropped claims.** I compared the summaries with the list "Claimed in the derivations and dropped or narrowed" and with the errata of `research/stakes-final.md`. None of the listed claims has returned, apart from the word "fails" in the README (finding 5).

**Section 2** (65-68). The list is complete: in Section 3.7 exactly `prop:stakes-basic`(c), `thm:weighted`, `prop:aim-cost`, `prop:twin-stakes` and `ex:stakes` use universality. `thm:lump` Part A, `prop:stakes-basic`(a) and (b) and `prop:repeat`(b) hold for any machine, `prop:allocation` and Part B have no machine, and the one clause of `prop:repeat`(a) that needs a universal machine imports the hypotheses of `prop:stakes-basic`(c) by name.

## Scripts

Run in a scratch directory; not part of the repository. All ran without a failed assertion.

* `check_example.py`: the example in exact rational arithmetic (items (b) to (f), the two inequalities on $|\bar e(\cdot)|$, the upper bound on the average share that the proved rest allows).
* `check_A3.py`: (A3) on random table machines; the nested counterexample of finding 1, exactly.
* `check_third_reading.py`: the two-class formulas with $n\varrho_1$ against water-filling by bisection; monotonicity of the weight on the class in $n$; the arithmetic of the example that separates (W2) from (W3).
* `check_repeat.py`: `prop:repeat`(b) on random table mixtures.
