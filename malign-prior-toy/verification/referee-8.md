# Referee report 8: the corrections of round 7

Date: 2026-11-19. Written by an AI referee that had not seen the note before; not reviewed by a human.

**Version refereed.** Commit `1fd77e82` on `claude/lucid-hypatia-j4jg12`, working tree clean.

**Scope.** Every hunk of `git diff d0060fdf 1fd77e82 -- malign-prior-toy` in `README.md`, `paper/main.tex` (abstract), `paper/sec1-intro.tex`, `paper/sec8-answers.tex`, `paper/sec3b-stakes.tex`, `paper/sec7-circuits.tex`, `paper/sec2-toy.tex`, `verification/README.md` (the changed rows of round 6 and the new Round 7 section) and `research/circuits-final.md`. Hunks that only re-wrap lines were identified with `git diff --word-diff` and skipped. All of `sec2-toy.tex` is re-wrapping, and so are the first hunks of `sec1-intro.tex` and `sec8-answers.tex` and the hunk in `prop:allocation`. No blank line was added or removed, so no paragraph changed. For each changed sentence I found the round-7 finding it answers, checked the new text against the numbered result as the files now stand, and checked every number it quotes against `experiments/results/circuits.json` and `experiments/results/circuits_extra.json`. I used Python only to read those two files, to recompute ranges and complements from their exact fractions, and to re-check the arithmetic of the nested counterexample of `referee-7-stakes.md`, finding 1 (average 0.7268, B = 127/256 < H/2 = 255/512). I changed no file except this report. Line numbers are those of the files at `1fd77e82`.

## Verdict

The round-7 corrections were carried out, almost all of them along the proposed replacements, and the mathematics was not touched. I checked each corrected sentence against `thm:lump`, `prop:twin-stakes`, `prop:stakes-basic`, `thm:weighted`, `prop:aim-cost`, `ex:stakes`, `prop:allocation`, `prop:repeat`, `thm:c-transfer`, `thm:c-floor`, `thm:c-minimum`, `thm:c-ceiling`, `prop:c-gadget` and `thm:c-refund`, and each one holds, apart from the points below. Every number quoted in a changed sentence agrees with the two results files. The hypotheses that round 7 found dropped are back in the places it named. The remaining problems are of the kinds named in the brief, and all are small:

* One new sentence of Section 7 is false as written: "every case computed has s_D at most 2". The AND family is computed at k = 4 with s_D = 3 (finding 1).
* "One minus that" ties the second range to "2 to 29 per cent with gates to spare", but the ranges printed after it include the least size (finding 2).
* The README's new parenthesis on the follow ratio contradicts the clause it qualifies (finding 3).
* Two summary sentences still state a result without "pairwise incomparable" where the other summaries now have it (findings 4 and 5).
* The new title of the example has an ambiguous scope (finding 6).
* Four items are in the record: Section 1's sentence on refereeing, the Round 7 table, one round-6 row and one erratum (findings 7 to 10).

There are 10 findings: 1 small error, 3 unclear sentences, 2 dropped hypotheses and 4 points in the record.

---

## Findings

### 1. "Every case computed has s_D at most 2" is false: the AND family is computed with s_D = 3. Error (small)

**Where.** `paper/sec7-circuits.tex` 1104-1105, paragraph "Guessed" (answers `referee-7-circuits.md`, finding 1).

**Problem.** `circuits.json`, `and_family`, entry `k=4`, has `s_D: 3`. The count is quoted in Section 7.10 ("exactly 1/2 at the least size for k = 3, 4") and in `thm:c-capture`(d) ("no fitting circuit has fewer than three gates", 4608 minimum-size circuits). Round 7 stated its point as "No computed case *with a never-varied bit* has s_D above 2", and that is true. Its proposed wording dropped the qualifier, and the paper copied it. The qualified statement holds: in both tables, the triggered variants, the floors against exact values, the capture example, the exception count and the count of separable triggers, s_D is 1 or 2. The AND family has no never-varied bit, and its number of inputs grows with s_D.

**Corrected text.** "No computation bears on that: every case computed at a never-varied bit has $s_D$ at most $2$, and the one family computed with a larger $s_D$, the AND family of \cref{thm:c-minimum}(e) at $k=4$ ($s_D=3$), has no never-varied bit."

### 2. "By one minus that ... 81 to 100 per cent; 68 to 100 per cent": the ranges after the colon include the least size, while "that" is the range with gates to spare. Unclear (numbers)

**Where.** `paper/main.tex` 126-129; `paper/sec8-answers.tex` 166-170; `README.md` 48; the round-7 row "Ranges" of `verification/README.md` (172). This answers `referee-7-circuits.md`, finding 10.

**Problem.** The sentence first gives "about 2 to 29 per cent when the predictor has gates to spare and the world ignores the bit". With gates to spare, `circuits.json` gives 1/53 = 0.0189 to 0.2894 (constant world, n = 8, s = 2). "One minus that" is therefore 71 to 98 per cent. The figures printed after the colon are ranges over all sizes:

* 81 to 100 in the two tabulated cases. The 100 is the least size, where the deviation is 1. With gates to spare the range is 0.8104 to 0.9794.
* 68 to 100 over all data sets counted. The 68 is 1 − 0.32, which is the least size in the exception of `thm:c-minimum`. The 100 is the least size outside it. With gates to spare the range is 0.7106 to 0.9811.

So a reader who computes "one minus that" gets 71 to 98 and finds two ranges that disagree with it at both ends. Section 7.10 (944-949) is correct, because it states the least size and slack separately and calls the ranges "over the cases computed". The record row says that "the summaries ... give both ranges", but the abstract gives only the first.

**Corrected text.**

* `main.tex` 126-129: "... the posterior is off the world's answer by about 2 to 29 per cent when the predictor has gates to spare and the world ignores the bit, and by one minus that when the world's answer changes with the bit: 81 to 98 per cent in the two such cases tabulated."
* `sec8-answers.tex` 166-170: "... by about 2 to 29 per cent when the predictor has gates to spare and the world ignores the bit, and by one minus that when the world's answer changes with the bit: with gates to spare, 81 to 98 per cent in the two such cases tabulated and 71 to 98 per cent over all the data sets counted, and 100 per cent at the least size outside the exception of \cref{thm:c-minimum} (\cref{tab:circuits-query,tab:circuits-seq})."
* `README.md` 48: the same as Section 8, with "the exception of Theorem `thm:c-minimum`" written as "the exception for one-gate data".
* `verification/README.md` 172, resolution: "The summaries say 'one minus that' and give the complement with gates to spare; Section 8 and the README also give it over all data sets counted; the paragraph gives the three cases."

### 3. README: "proved only in a model in which the rest does not depend on the allocation (if the rest follows the attacker at a fixed ratio, only for a ratio below one)". Unclear

**Where.** `README.md` 33. This answers `referee-7-stakes.md`, finding 3. Round 7 had found this line correct, and the parenthesis is not a replacement it proposed.

**Problem.** The main clause names the passive model, in which the rest does not depend on the allocation. The parenthesis then admits a rest that follows the attacker, and such a rest does depend on the allocation ($O=O_0+\tau\mu$). The next sentence begins "There", and gives the share $1-\sqrt{\eta/\varrho}$ and the majority condition $\varrho>4\eta$. These hold only in the passive case. With a follow ratio, `prop:allocation`(b) gives the share $(1-\sqrt{\eta_B/\varrho})/(1+\tau)$ and the condition $\varrho>4\eta_B/(1-\tau)^2$. After the parenthesis, "There" can be read as covering the following case too.

**Corrected text.** "*That enough weight wins* is proved only in an allocation model in which the passive rest and the follow ratio do not depend on the attacker's allocation, and there only for a follow ratio below one. Where the rest does not follow, an attacker that maximises the stake it captures attacks only where the stake per unit of rest, ϱ, exceeds a price η, with share 1 − √(η/ϱ), and has the majority where ϱ > 4η. The order is by stake per unit of rest and not by stake; in the example this optimum leaves the highest stakes alone."

### 4. README: "necessary in the toy" without "for pairwise incomparable uses". Gap (minor)

**Where.** `README.md` 35, last sentence. This answers `referee-7-stakes.md`, finding 5; its proposed text has the same omission.

**Problem.** Round 7 restored the hypothesis in the corresponding sentence of the section, which now reads "necessary in the toy for pairwise incomparable uses, sufficient in the model for a follow ratio below one" (`sec3b-stakes.tex` 521-522). Without it, the necessity is false, as shown by the nested counterexample of `referee-7-stakes.md`, finding 1. The README states the lump with the hypothesis on line 30, but this sentence makes a new claim and drops it. Its "sufficient in the model for a rest that does not follow" is true, but narrower than the section's statement.

**Corrected text.** "If the channel is everything that prints those contexts and goes on, the picture is the lump statement: necessary in the toy for pairwise incomparable uses, sufficient in the model for a follow ratio below one."

### 5. Abstract: the twin sentence has no "pairwise incomparable". Gap (minor)

**Where.** `paper/main.tex` 78-80. This answers `referee-7-stakes.md`, findings 4 and 9b.

**Problem.** "Its honest twin is in the posterior at each use with $2^{a-h}$ times the seeker's mass". This holds for the seeker's whole mass at the use only under (INC): `prop:twin-stakes`(a) together with `thm:weighted`(b). Without (INC) it holds only for the seeker's programs whose search finds a user at that context (`sec3b-stakes.tex` 283-285). Section 1 (107), the README (31) and Section 8 (95-96) now begin this sentence with "For pairwise incomparable contexts". The abstract does not. The next sentence of the abstract restates (INC) for the wrapper, which suggests that the twin sentence is not under it. The phrase "Part of the rest follows the seeker, still without resource bounds" also attaches "without resource bounds" to "follows" rather than to the statements.

**Corrected text.** "Still without resource bounds, part of the rest follows the seeker. For pairwise incomparable contexts its honest twin is in the posterior at each use with $2^{a-h}$ times the seeker's mass, a factor in which neither the aim nor the stake occurs for seeker and twin built in the same way, and it belongs to the rest where the users go on printing."

### 6. Title of the example: "no majority at every use". Unclear (minor)

**Where.** `paper/sec3b-stakes.tex` 292-293. This answers `referee-7-stakes.md`, finding 13, whose proposed title it follows.

**Problem.** "No majority at every use" can be read as "at every use, no majority", which is a bound at all uses. What `ex:stakes`(d) proves is that (W1) fails: the attacker lacks the majority at some use, possibly only at uses that carry a small share of the class. Item (e) leaves the majority at $x_n$ open whenever $|v_A|+1<|v_D|$. Every summary words this correctly ("lacks the majority at some use"). The title is the one place where the scope can be misread.

**Corrected text.** "\begin{example}[A class of mass $2^{-n}$ aimed at with $2\log_2n$ bits: the majority fails at some use, and most uses are not decided]\label{ex:stakes}"

### 7. Section 1: "the repairs made after that round, and the summaries, were checked once more (referee-7)". Record (minor)

**Where.** `paper/sec1-intro.tex` 188-192. This answers `referee-7-stakes.md`, finding 7, and `referee-7-circuits.md`, finding 16.

**Problem.** The sentence is true of the summaries as they stood at `d0060fdf`. The summaries now printed contain the round-7 corrections, which no referee had read before this report. This is the same point that round 7 made about "the two sections as printed here". The count "five further items" is right: the Provenance section of `stakes-final.md` lists nine items, and `referee-6-stakes-proofs.md` checked the four that the paper uses.

**Corrected text.** "... were refereed afterwards (\texttt{verification/referee-6-*.md}); the repairs made after that round, and the summaries as they then stood, were checked once more (\texttt{verification/referee-7-*.md}), and the corrections made after that check were re-read (\texttt{verification/referee-8.md}). The Provenance section of \texttt{stakes-final.md} lists five further items, not used here, that no referee has read."

### 8. The Round 7 table leaves out twelve of the 34 findings. Record

**Where.** `verification/README.md` 163-174, in particular the row "Small points" (173).

**Problem.** The file says it "lists what each round found". Round 7 criticised the round-6 table for leaving out four accepted findings. The Round 7 table repeats the pattern. These findings have no row and are not named in "Small points":

* `referee-7-stakes.md`: findings 7, 9 (a)-(f), 11, 12, 13 and 14.
* `referee-7-circuits.md`: findings 5, 7, 8, 16, 17 and 19.

I checked that all of them were carried out. Only finding 13 needs a further change (finding 6 above).

**Corrected text.** Append to the finding cell of row 173: "; further, without rows of their own: the hypothesis that stakes can be enumerated, the twin's part of the rest, (INC) for the twin bound, for the factor $2^{-a}/H_{\mathcal W}$ and for programs whose aim is not written, and 'cheap to print with one' (stakes 9); 'run more than n times' said to help 'in the toy' (stakes 11); the price 2·log₂n attached to any class in the abstract (stakes 12); the title of the example (stakes 13); the summary of Section 3.7 inside Section 7 (stakes 14); which parts of the seed theorem apply to circuits with a fixed gate-list prefix (circuits 5); a dropped condition and 'large data' in the paragraph 'Open' (circuits 7); two wordings in Sections 7.10 and 7.12 (circuits 8); Section 1's sentence on what was refereed (stakes 7, circuits 16); the facts cited for circuits (circuits 17); three statements of the README's Status (circuits 19)."

### 9. The new round-6 row "Stakes: further prose" misdescribes the first of its four findings. Record (minor)

**Where.** `verification/README.md` 142. This answers `referee-7-stakes.md`, finding 8.

**Problem.** The round-6 finding (`referee-6-stakes-claims.md`, finding 7) was this: "the one reading under which repetition lowers the bar" is false of the share, because along one world the shares at successive uses add up too. Only the weight falls only in the reading with $n$ samples at one context. The row says instead that "the reading of repetition with n samples lowers the weight needed and not only the share". That describes the reading correctly, but not what was wrong. The resolution, "Corrected in the section and the summaries", also passes over the residues that round 7 found (`referee-7-stakes.md`, findings 7 and 11).

**Corrected text.** "| **Stakes: further prose.** 'The one reading under which repetition lowers the bar' holds for the weight and not for the share: along one world the shares at successive uses add up as well. A statement taken from the corrected account was a one-directional statement worded as a characterisation; the open items were too narrow; the sentence on what had been refereed overstated. | Corrected in the section and the summaries; two residues (the closing paragraph of Section 3.7 on repetition, and the sentence on what was refereed) are listed under round 7. |"

### 10. The corrected erratum of `circuits-final.md` no longer covers item 12 of its Section 4. Record (minor)

**Where.** `research/circuits-final.md` 568 (the erratum "Computation 22"), and 505.

**Problem.** The erratum now quotes line 383 exactly ("Between 2 and 32 per cent in every case computed with slack or in the exception"), as round 7 asked. The old, looser quotation ("between 2 and 32 per cent with slack") also covered item 12 of the plain answer, line 505: "off the world's answer by 2 to 32 per cent when the predictor has slack". That statement is wrong at the upper end, since 0.32 is at the least size. The new erratum no longer covers it, and no other erratum does.

**Corrected text.** Append to the erratum: "The same range is in item 12 of Section 4 ('2 to 32 per cent when the predictor has slack'); with slack it is 1.9 to 29 per cent."

---

## Outside the changed hunks

Neither point is in a changed sentence, but each is next to one.

* `paper/sec7-circuits.tex` 196-199 says that a world outside the class is "the generic case unless the size bound is exponential in k". The corrected item in "Open" (1133-1134) says "for a prior with a size bound well below $2^k/k$", and that is the right threshold. With a bound of $2^{k/2}$, which is exponential in $k$, $\log_2(2N_s)\approx2^{k/2}(k+4)\ll2^k$, so most functions are still outside the class. Suggested: "... this is the generic case unless the size bound is of order $2^k/k$."
* `paper/sec7-circuits.tex` 1109-1111: the source bases its conjecture on "five sizes at k=3 and three at k=4" (`circuits-final.md` 520; `circuits-B.md` 463). The paper names only the first. This understates the evidence and is harmless.

## Changed passages found correct

**Abstract (`main.tex`).**
* 69-73: the price of aiming at a class (its description and the bits that name its scale) and $2\log_2n$ for stake at least $n$, under "a label that a program can recognise from below" (`thm:weighted`, `prop:aim-cost`(a)).
* 76-77: "a class of such uses"; this is (A3) with $\underline\varphi=1$ for F the takeover programs (`thm:lump`).
* 79-80: the twin factor, with "built in the same way" and "belongs to the rest where the users go on printing" (`prop:twin-stakes`(a), (b)); for (INC) see finding 5.
* 81-82: the wrapper with both hypotheses (`prop:stakes-basic`(c)).
* 105-106: the contrarian world: "only under a finite size bound" and "shown ... when the horizon is long enough" (`thm:c-transfer`(e)).
* 108: (A2) in full (`thm:c-refund`(d)).

**Section 1.**
* 94-96: "Resources are unbounded throughout this item"; stakes that a program can enumerate (`prop:aim-cost`).
* 99-105: the two halves of `thm:lump`(A2), (A3). $H_{\mathcal W}/(2k_F)$ is worded as "half the mass of the users divided by the largest number of users per unit of that rest". The sentence says that it concerns takeovers only for F the takeover programs.
* 107-109: (INC) for the twin (`prop:twin-stakes`).
* 113-116: "the passive rest and the follow ratio do not depend on the allocation, and there only for a follow ratio below one" (`thm:lump`(B1), `prop:allocation`).
* 133-135: the contrarian world (`thm:c-transfer`(e)).
* 135-136: "Every prior considered, uniform on the circuits of one size or a mixture over sizes" (`thm:c-core`(a)).
* 145-148: the ceiling is "small when the data need a large circuit and proportional to the number of triggers" (`thm:c-ceiling`(c)).
* 181-182: the cited facts (frandsen05, burghart26, bera08, allender02 and filan16 are all cited in Section 7).
* 188-192: "five further items" is right; see finding 7.

**Section 8.**
* 80-87: enumerable stakes; "at most $2^{-a}/H_{\mathcal W}$ for pairwise incomparable contexts" (`thm:weighted`(b), a bound uniform over the uses); order $2^n/n^2$ in `ex:stakes`(b).
* 88-91: the lump with "a class of such uses" (`thm:lump` Part A).
* 93: "What follows is again without resource bounds."
* 94-95: "and cheap to print with one" (the paragraph after `ex:stakes`).
* 103-105: prefix words of the two machines, and "by more than one bit for the context that carries half the class" (`ex:stakes`(e): (W2) by prior mass needs $|v_A|+1<|v_D|$).
* 110-111: the follow ratio below one (`thm:lump`(B1)).
* 127-129: (INC) for a program whose aim is not written (`sec3b-stakes.tex` 467-474; `prop:stakes-basic`(c)).
* 132-133: (INC) and users that go on: the seeker supplies the majority only if $a<h$ (`prop:twin-stakes`(a) with $\varphi_g=1$).
* 141-143: the contrarian world.
* 146-150: (A2) in full; $k$ defined.
* 160-161: $s_0\le\lceil\ell_D\rceil+1\le s_D+\log_2N_{s_D}+2$, the description length of a smallest fitting circuit under the length prior plus at most two (`thm:c-floor`(d)).
* 172-177: (A1) for gadgets and templates (`prop:c-gadget`, `thm:c-refund`(e), which needs (A1) only); the trigger ceiling for every prior of the family (`thm:c-ceiling`).
* 183-190: "uses that are new in something the data never varied", the closing sentence of `sec:c-view`; "when the data need a large circuit"; "For the smallest circuit" (`sec:c-minimal`).
* 264-266: self-reproduction at contexts whose smallest circuit is large is added to the open list.

**Section 3.7.**
* 495-498: "only for a follow ratio below one; where the rest follows at a ratio of one or more, no weight gives the majority" ((B1)).
* 512-516: the reading with $n$ samples is a protocol outside `def:call`, and along one world the weight needed does not fall (`prop:repeat`(a), (b), including $B>(2^n-1)\xi(z)$).
* 520-522: "necessary in the toy for pairwise incomparable uses, sufficient in the model for a follow ratio below one".

**Section 7.**
* 191-193: "can become empty only under a prior with $s_{\max}<\infty$ ... empty for certain once more than $\log_2(1/q_{\min})$ rounds fit ... can be empty earlier" (`thm:c-transfer`(e)).
* 519-520 and the title of (v): the numbers agree with `circuits_extra.json`: $2^{-14.63}$; $8.31\cdot10^{-4}$ and $1.24\cdot10^{-3}$; 0.1387; above 1 first at $g=28$ singly and at $g=25$ summed, increasing beyond.
* 697-702: (d), (e), (f) and (i) do not apply to circuits with a fixed gate-list prefix; (c) does; (a) and (g) hold for each member (`thm:c-refund`).
* 826-829: the summary of Section 3.7, with "without resource bounds" and "measured by its users alone" (`prop:aim-cost`).
* 952-953: "a single input, which never varied in the data".
* 966-976: the list of numbers not in `circuits.json` matches the items of `circuits_extra.json`. "Exact except two": the two gate prices are enclosed in intervals of width about $10^{-12}$ (13.001 and 14.123 bits), and the active part is a simulation with mean 3.01. Every quoted value agrees with the file: 0.0017 against 0.065; at most $2\cdot10^{-8}$ against 0.057 to 0.95; 16 of 48; 8512 of 29 824, of which 8128 are triggered by the frozen input; 2 of 76; 4 of 14.
* 1059-1060: "a share of at most a bound" (`thm:c-ceiling`).
* 1098-1099: "when the data need a large circuit".
* 1109-1114: the conjecture concerns a fixed task as $s$ grows. The ranges agree with `circuits.json`: 0 at the least size outside the exception; 0.0189 to 0.2894 with slack; 0.270, 0.2857 and 0.320 at the least size in the exception.
* 1117: "in (i) to (iv)".
* 1131-1134: the paragraph "Open".

**Section 2.** Re-wrapping only.

**README.**
* 28: the whole item is without resource bounds.
* 29: enumerable stakes.
* 30: "a class of such uses".
* 31: (INC) for the twin.
* 32: prefix words, as a necessary condition.
* 35: (INC) and users that go on, and the verdict as an argument for the reading in which the channel is the users; see finding 4 for the last clause.
* 45-47 and 49: as in Section 8.
* 52: the overall view.
* 65: the open list.
* 70, 77, 78, 87: Contents and Reproduce. The scripts and files named exist. Both corrected accounts end with their errata. `research/circuit_count.py` exists.
* 93: what is taken without proof. Each item named for Section 3.7 or Section 7 is marked so at its place in the paper.
* 95: "exact except for one seeded simulation and two series enclosed in intervals".
* 96: the four items argued are marked so in the paper (`sec3b-stakes.tex` 520; `sec7-circuits.tex` 722-724 and 847).

**`verification/README.md`.**
* Round-6 verdict (136): the blog posts and "carried out only in part".
* Rows 143, 145, 146, 147, 152, 154 and 155. Row 143 now has (INC).
* Round 7: the introduction and the verdict (159, 161; 34 = 14 + 20).
* Rows 165-171 and 174 describe the findings and what was done truthfully, apart from findings 2, 3 and 8.
* "The paper's theorems were not changed": no statement of a theorem, proposition or example changed; only the title of the example.

**`research/circuits-final.md`.** The erratum "Computation 22" now quotes line 383 exactly, and its corrected ranges agree with `circuits.json`; see finding 10.
