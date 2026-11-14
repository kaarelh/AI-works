# Referee report 7 on Section 7, "Circuits in place of programs": the repairs after round 6, and the summaries

Date: 2026-11-14. Version refereed: the working tree at commit `d0060fdf` ("apply the sixth referee round to the summaries"), clean. Written by an AI referee that had not seen the note before; not reviewed by a human.

**Under review.**

1. The material of `paper/sec7-circuits.tex` that was added or rewritten after round 6: the extended prior for seeded circuits (583-595) and the parts of `thm:c-refund` that depend on it; the remark on circuits that begin with a fixed gate list (689-695); the one-gate example of a self-reproducing block after `thm:c-self` (785-804); the count "4 of 2k+8" (462-467); the sums of the ceiling over triggers (528-537); the one-gate floor against exact values (377-383); the paragraph "Open" (1112-1119); the subsection "Small cases, computed" (906-972). I read every other sentence that the diff against `6b534400` shows as changed, and report on those where I found something.
2. The summaries: in `paper/main.tex` the abstract bullet "Circuits in place of programs" (111-126) and the last two sentences of the abstract (130-135); in `paper/sec1-intro.tex` the item "Circuits" (149-171) and the sentences on Section 7 under "What is new and what is not" (199-206) and "What the toy does not settle" (231-235); in `paper/sec8-answers.tex` lines 151-202 and the eighth open item (281-286); in `README.md` the bullet "Circuits in place of programs" (44-52), the line under "What is not settled" (65), "Contents" (68-89) and "Status" (91-96); in `verification/README.md` the rows of the Round 6 table on circuits and on the computation (147-154).

**Method.** Each sentence in scope was checked against a numbered result of the section as it now stands, or against `experiments/results/circuits.json`. The one-gate example was checked by hand: I wrote out the literal code of the circuit from the definition in the section, evaluated the gate at the eighteen positions, and counted the one-gate circuits against the two fixed strings; a short script repeats the evaluation and the count. Numbers were recomputed with my own counter of circuits by function (it shares no code with `code/circuit_count.py`). No script decodes a block into a circuit, searches for blocks, or executes strings. I changed no file except this report.

## Verdict

No numbered statement in the new material is wrong. The extended prior is consistent, and parts (c), (d), (e), (f) and (h) of `thm:c-refund` hold for it, and with the unseeded mixture in place of ξ where the text says so. The one-gate example is correct in every detail: the code, the decoding, the eighteen bits, the equality in `thm:c-self`(b), and the share 1/55. "4 of 2k+8" is correct for every k ≥ 2. The corrected sums over triggers are correct (about 10^-3 for each g ≤ 5, at most 0.14 for g ≤ 19, above 1 from g = 28 for one g and from g = 25 for the sum). The one-gate floor 0.0017 against 0.065 is correct. Every number of the subsection on small cases, both tables and both captions agree with `circuits.json`, and I reproduced all 56 entries of that file exactly, the five-gate entries included.

The findings are in the prose around these results and in the summaries. Five matter for what a reader takes away. (1) The paragraph "Guessed" supports its guess by a conjecture "for large data" whose only evidence is five sizes of the predictor at fixed data; the conjecture that the step needs, a deviating mass of constant order as the data need larger circuits, has no computation behind it. (2) Section 8 and the README still say that "deviation at uses off the data is not" priced out, the wording that round 6 had narrowed in the section. (3) "The posterior becomes empty only for … a horizon with 2^k − n > log2(1/q_min)" reports a sufficient condition as necessary; it fails in an example with four inputs. (4) Item (v) after `thm:c-ceiling` still stands under "It says nothing about the following", although with the corrected count the bound says a good deal about it. (5) The record is not closed: the README says that `run_circuits.py` computes the numbers of the section, the section says that some are not produced by it, the row of `verification/README.md` on this says "See round 7" and that file has no such section, and Section 1 says that the sections "as printed here" were refereed in round 6. The other findings are small: conditions cut short in summaries, undefined symbols, two ranges.

---

## Findings

Severity: **error** (false as written), **overclaim**, **gap**, **unclear**, **minor**. Each finding is marked **[section]**, **[summary]** or **[record]**. Line numbers are those of the file named.

### 1. The conjecture behind the guess is about a growing size bound; the text states it for large data. overclaim [section]

**Where.** `paper/sec7-circuits.tex` 1091-1093 and 1096-1099.

**Sentences.** "For a fixed number of inputs the bound of `thm:c-ceiling` falls like 1/s_D, so these cores become a small part of the deviating mass if that mass stays of constant order, which is the conjecture below." "That c stays of constant order for large data is conjectured from five sizes at k=3 and not proved."

**Problem.** The five sizes are s = 1,…,5 of the predictor's circuits for three fixed tasks with k = 3, each with four data points and s_D = 1 (first three rows of Table 4). What they suggest is a limit as the size bound grows at fixed data. That is also what the source conjectures (`research/circuits-final.md` 5.1, item 5: "a limit strictly between 0 and 1 under μ_s as s→∞"; `research/circuits-B.md`, CB13: "for a fixed task"). The step in 1091-1093 needs something else: that the deviating mass stays of constant order as s_D grows, because the ceiling falls like 1/s_D. No computed case with a never-varied bit has s_D above 2, and the source has only a heuristic "for larger targets". A statement about one limit is read as a statement about another, and the guess "a small part … when the data are large" loses the one support the paragraph gives it.

**Corrected text.** "…so these cores become a small part of the deviating mass if that mass stays of constant order as s_D grows. No computation bears on that: every case computed has s_D at most 2." And: "For a fixed task, that c tends to a limit strictly between 0 and 1 as the size s of the predictor's circuits grows is conjectured in the source from five sizes at k=3 and not proved. That c stays of constant order when the data need larger circuits is a further guess."

### 2. "c is between 0.02 and 0.32 in the cases computed". minor [section]

**Where.** `paper/sec7-circuits.tex` 1098-1099.

**Problem.** For a world that ignores the bit, c is 0 at the least size outside the exception of `thm:c-minimum` (six of the nine data sets). This is the omission that round 6 corrected in the subsection on small cases (931-937), and it returns here. The lower end is 1/53, which the subsection now gives as 1.9 per cent.

**Corrected text.** "In the cases computed c is 0 at the least size outside the exception of `thm:c-minimum`, between 0.019 and 0.29 with slack, and 0.27 to 0.32 at the least size in the exception."

### 3. "The posterior becomes empty only for … a horizon with 2^k − n > log2(1/q_min)": a sufficient condition reported as necessary. error (small) [section]; unclear [summary]

**Where.** `paper/sec7-circuits.tex` 191-192. Summaries: `paper/main.tex` 112-114; `paper/sec1-intro.tex` 150-152; `paper/sec8-answers.tex` 154-156; `README.md` 45.

**Problem.** `thm:c-transfer`(e) proves that the posterior is empty after more than log2(1/q_min) rounds. A finite size bound is necessary, since otherwise every function has positive mass. The condition on the horizon is sufficient and not necessary: the mass can fall by more than half in a round. Example (exact count): k = 4 and the mixture with w_1 = w_2 = 1/2. Then log2(1/q_min) = log2(2 N_2) = 17.6, which exceeds the whole horizon 2^k = 16. The contrarian record from the empty context is 10010010, and no circuit with at most two gates prints it, so the posterior is empty after 8 rounds. Under μ_1 with k = 3 (log2 N_1 = 7.2) it is empty after 5 rounds from the empty context, and after 2 rounds from the context 011, where only 5 positions are left. The sentence was written after round 6 along a wording proposed there, so no referee had checked it.

**Corrected text.** Section: "The posterior can become empty only under a prior with s_max < ∞. It is empty for certain once more than log2(1/q_min) rounds fit into the horizon, and it can be empty earlier." Summaries: "the contrarian world can empty the posterior only under a prior with a finite size bound, and is shown to do so when the horizon is long enough".

### 4. Item (v) still stands under "It says nothing about the following". unclear [section]

**Where.** `paper/sec7-circuits.tex` 518 and 528-537; also 1102 ("the classes that the ceilings do not reach, listed after `thm:c-ceiling`").

**Problem.** With the count of round 6 the bound summed over triggers exceeded 1 at five gates, and "says nothing about the sum over many triggers" was apt. With the corrected count the item itself says that all separate triggers of at most 19 gates have together at most 14 per cent for k = 20 and s_D = 1000, and that the sum is void only from 25 gates on. The lead sentence now contradicts the item, and the later reference to "the classes … listed after `thm:c-ceiling`" counts (v) among classes the ceiling does not reach.

**Corrected text.** "The bound is on one syntactic class. It says nothing about (i) to (iv). Summed over triggers it reaches as far as (v) says." In (v), begin: "*How far the sum over triggers reaches.*" Line 1102: "listed in (i) to (iv) after `thm:c-ceiling`".

### 5. "Only (c) and (g) apply to this family", then "each statement of the theorem is about one description". minor [section]

**Where.** `paper/sec7-circuits.tex` 694-698.

**Problem.** The two sentences disagree. Part (c) is about an arbitrary set of circuits, which is why it applies to the family; it bounds only the average over first hits, as `thm:search`(a) does for programs. Parts (a) and (g) are about every single circuit. Only (d), (e), (f) and (i) are about one description or the instances of one template. The mass Σ_j w_{s+j}/N_s, the value 2q(V) under the length prior and "V cannot interpret what follows it" are correct.

**Corrected text.** "Of the bounds of the theorem, (d), (e), (f) and (i) do not apply to this family; (c) does, and (a) and (g) hold for each of its members. Parts (d) to (f) and (i) are about one description, or about the instances of one template. Part (c) holds for every set of circuits and bounds only the average over first hits. None is the negation of `thm:search`(b) for arbitrary sets of circuits."

### 6. The list of numbers that no committed script produces is incomplete. gap [section]

**Where.** `paper/sec7-circuits.tex` 960-966.

**Problem.** The corrected item (v) after `thm:c-ceiling` rests on the numbers R_g of reduced circuits for k = 20 up to g = 28 (the values 8.3·10^-4, 1.2·10^-3, 0.14 and the thresholds 28 and 25). They need the recursion of line 531 and are produced by no script in the repository. They are missing from the list. I reproduced them (R_1,…,R_5 = 6400, 4 198 400, 4 199 219 200, 5 691 067 596 800, 9 796 247 879 680 000; the recursion agrees with a direct enumeration of reduced circuits for k = 2, 3 and g ≤ 4). The other numbers of the list I also reproduced; see the last section.

**Corrected text.** Add to the list: "the numbers R_g and the sums of the ceiling over triggers after `thm:c-ceiling`". Better: add the recursion, about ten lines, and the other listed quantities to `experiments/run_circuits.py`.

### 7. The paragraph "Open": a condition dropped, and "large data". minor [section]

**Where.** `paper/sec7-circuits.tex` 1115-1116.

**Problem.** (i) "A world outside the class, which is the generic case for arbitrary sequences" drops the condition of lines 195-198, "unless the size bound is exponential in k". Under the length prior, the prior of the main floors, no world is outside the class (line 193). (ii) "The size of the deviation at a never-varied bit for large data": the source has "for large targets". What is meant is data that need a large circuit, under the length prior for the floor; see findings 1 and 11.

**Corrected text.** "A world outside the class, which for a prior with a size bound well below 2^k/k is the generic case for arbitrary sequences." "The size of the deviation at a never-varied bit when the data need a large circuit: under the length prior, between the polynomial floor and a constant."

### 8. Two small wordings in rewritten sentences. minor [section]

* **947-948**, "a single input, the never-varied one". In the two rows of Table 5 with the cut n = 4 two index bits never varied, b_2 and b_3; the query differs from a data point in b_2. Write "a single input, which never varied in the data". The inference that follows is correct.
* **1049-1050**, "separate triggers for single-bit answers have a share proportional to the number of triggers and to 1/s_D". It is an upper bound. Write "have a share at most a bound that is proportional to …".

### 9. "Deviation at uses off the data is not" priced out: the wording corrected in the section is still in two summaries. overclaim [summary]

**Where.** `paper/sec8-answers.tex` 192-193; `README.md` 52 ("deviation off the data is not").

**Problem.** Round 6 (claims report, findings 16 and 26) found that "uses off the data" reads reach as fate: by `thm:c-transfer`(c) the deviation masses along any sequence of queries off the data sum to at most ln(1/μ(f*)). The closing sentence of Section 7 now reads "deviation at uses that are new in something the data never varied is not priced out" (1122-1123). The two summaries of that sentence kept the old scope.

**Corrected text.** Section 8: "…and deviation at uses that are new in something the data never varied is not." README: "…the seeker mechanism is priced out for single descriptions, and deviation at uses that are new in something the data never varied is not."

### 10. "81 to 100 per cent in the computed cases where the world's answer changes with the bit". unclear [summary]

**Where.** `paper/main.tex` 133-135; `paper/sec8-answers.tex` 178-179; `README.md` 48.

**Problem.** The section says of these two rows: "These rows are not a second measurement", and "for the other data sets of the two tables the same complement … lies between 0.68 and 1" (940-944). The summaries give the range as a second result, and its lower end 81 is set by which two worlds were tabulated. Literally the sentence is true. Round 6 (claims report, finding 3) asked for the complement; "in the computed cases" was added and the figure was kept.

**Corrected text.** "…and by one minus that when the world's answer changes with the bit: 81 to 100 per cent in the two such cases tabulated, 68 to 100 per cent over all the data sets counted."

### 11. "Small for large data". unclear [summary], and once [section]

**Where.** `paper/sec1-intro.tex` 161; `paper/sec8-answers.tex` 183 and 195; `README.md` 49 and 52; `paper/sec7-circuits.tex` 1087-1088.

**Problem.** The bound of `thm:c-ceiling` is proportional to 1/s_D, the size of the smallest circuit that fits the data. It does not fall with the amount of data: the data set of x_1∧x_2 on all inputs has s_D = 1. In the same section "as n grows" (835) means more data points, so "large data" will be read that way. Item 4 of "Proved" has it right ("to 1/s_D").

**Corrected text.** "a bound that is small when the data need a large circuit, and is proportional to the number of triggers"; in the guess, "when the data need a large circuit".

### 12. Conditions cut short in the summaries of `thm:c-refund` and of the ceilings. gap [summary]

**Where.** `paper/main.tex` 115; `paper/sec8-answers.tex` 159-160 and 184-186; `README.md` 46 and 49.

**Problem.** (i) Assumption (A2) is "no more weight than the unseeded format of the same size". The abstract, Section 8 and the README say "no more weight than unseeded ones"; Section 1 (163-164) has it in full. (ii) The second and third ceiling need (A1), a size weight that does not increase (`prop:c-gadget`; `thm:c-refund`(e)). Item 4 of "Proved" says so; Section 8 and the README do not.

**Corrected text.** (i) "If a seeded format gets no more weight than the unseeded format of the same size, …". (ii) Add "under a prior whose weights do not increase with the size" to the sentence on gadgets and templates.

### 13. Symbols without definition. minor [summary]

**Where.** `paper/sec8-answers.tex` 162 and 172 (k, s_0); `README.md` 46 and 47 (k, s₀); `paper/sec1-intro.tex` 152 ("Every prior of the family").

**Problem.** Round 6 (claims report, finding 27) asked for these. Section 1 now explains s_0 and k; Section 8 and the README print 1/(32(k+s_0)²+2) and σ+3 ≤ 2^k with neither symbol introduced, and "prior of the family" is still used in Section 1 before the family is defined.

**Corrected text.** Section 8 and README: "with k the number of inputs and s_0 at most two more than the description length, under that prior, of a smallest circuit for the data". Section 1: "Every prior considered (uniform on the circuits of one size, or a mixture over sizes) is a prior on the active part of a circuit".

### 14. "The smallest or the typical circuit … is stated as an open problem". minor [summary]

**Where.** `paper/sec8-answers.tex` 196-198; `README.md` 52.

**Problem.** The open problem of `sec:c-minimal` is about the set of minimum-size circuits that fit the data. Nothing in it concerns the typical circuit. The abstract (122-123) has "the smallest circuit" only.

**Corrected text.** "…is a general solver whose behaviour off the data the data do not fix. For the smallest circuit this is stated in `sec:c-minimal` as an open problem, two of whose three conditions are formal."

### 15. The open lists of the summaries leave out the item that round 6 narrowed. gap [summary]

**Where.** `paper/sec8-answers.tex` 281-286; `README.md` 65.

**Problem.** The paragraph "Open" of Section 7 has seven items. The two summaries have six: "self-reproduction at contexts whose smallest circuit is large" is missing, although both summaries state the one-gate example. Without it a reader takes the question of self-reproduction for circuits as settled.

**Corrected text.** Add "self-reproduction at contexts whose smallest circuit is large;" before "the minimal-circuit question".

### 16. "The two sections as printed here were refereed afterwards (`referee-6-*.md`)". error (small) [summary]

**Where.** `paper/sec1-intro.tex` 205-206.

**Problem.** Round 6 refereed the sections as committed in `6b534400`. The sections as printed contain the repairs: the extended prior, the one-gate example, the remark on gate-list prefixes, the corrected sums, new sentences in the overall view. No referee of round 6 saw them; they are the subject of this report.

**Corrected text.** "What was new in those two files, and the two sections as first printed, were refereed afterwards (`verification/referee-6-*.md`); the repairs and the summaries were checked once more (`verification/referee-7-*.md`)."

### 17. "Known facts on the number of circuits". minor [summary]

**Where.** `paper/sec1-intro.tex` 199-200.

**Problem.** The fact cited is the circuit size of the hardest functions (`frandsen05`); the count "fewer than 2N_s functions" is the note's own. The section also uses a limit law for random recursive graphs, the relation between circuit size and KT, and the speed priors, all cited there.

**Corrected text.** "`sec:circuits` uses known facts on the circuit size of the hardest functions, on random recursive graphs, on universal circuits and on time-bounded complexity, cited there."

### 18. README, "Contents": two statements that the repository contradicts. error (small) [summary]

**Where.** `README.md` 70 and 77; also 78.

**Problem.** (i) Line 77: "`run_circuits.py` computes the numbers of the circuit section". Section 7.10 (960-966) says that five groups of numbers are not in the results file and were computed with scripts that are not in the repository; with finding 6 there are six. Round 6 asked for this line to be changed (claims report, finding 28). (ii) Line 70: "`table-*.tex` are generated by `experiments/make_table.py`". That script writes `table-profiles.tex`, `table-budget.tex` and `table-length.tex`. The two circuit tables are written by `make_circuit_table.py`, as line 77 says. (iii) Line 78 does not mention `research/circuit_count.py`, nor that the two corrected accounts now end with errata.

**Corrected text.** (i) "`run_circuits.py` computes the two tables and the numbers of Section 7.10 and writes `results/circuits.json`. Some further numbers of Section 7, listed at the end of Section 7.10, were computed with scripts that are not in the repository." (ii) "`table-*.tex` are generated by `experiments/make_table.py` and, for the two circuit tables, by `experiments/make_circuit_table.py`." (iii) "…and what is open; each ends with the errata of the sixth referee round."

### 19. README, "Status": three loose statements. minor [summary]

**Where.** `README.md` 93, 95, 96.

**Problem.** (i) "Some secondary statements … are taken without proof." For Section 7 these are the AND family (`thm:c-minimum`(e)), the gadget ceiling (`prop:c-gadget`), capture (`thm:c-capture`), self-reproduction (`thm:c-self`), the paragraphs on encoding and on stakes, recurrence (`prop:c-recurrence`) and universal circuits. The gadget ceiling is one of the "three syntactic classes" of every summary, and the recurrence statement is in the abstract. (ii) "The circuit counts (`circuits.json`), exact" does not cover the numbers of finding 18(i), one of which is a simulation. (iii) "Argued or guessed" omits two things that Section 7 marks as argued: that the circuit toy is harsher on computation than a speed prior (718), and "exactly to the extent" in the paragraph on stakes (842).

**Corrected text.** (i) "For circuits the statements on capture, self-reproduction, self-contained gadgets, recurrence, universal circuits and the AND family are taken without proof from `research/circuits-final.md`, where they are proved; the paper says so at each place." (ii) Add "; some further numbers of Section 7 come from scripts outside the repository and were reproduced by the referees". (iii) Add "the comparison with a speed prior; that a hypothesis singles out high-stake uses exactly to the extent that they are cheap to recognise".

### 20. `verification/README.md`: the rows of round 6 on circuits and on the computation. gap [record]

**Where.** `verification/README.md` 136 and 151-154.

**Problem.** The rows on the miscount, the seeded prior, the settled open question, the two dropped claims and the label "deviation that nothing aimed" describe the findings and what was done truthfully; I checked each against the reports and the present text. Four points do not.

* **Line 154**, resolution "See round 7". The file has no section on a seventh round, so the row records no resolution. What was done: nothing was added to `run_circuits.py` or to the results file; Section 7.10 now lists the numbers concerned and says that they were recomputed with scripts outside the repository; the README line was not changed (finding 18).
* **Line 151**, "Corrected in the section and in all summaries". The range returns, without the zeros, in the paragraph "Guessed" (finding 2), and the second range is still given as a second result (finding 10).
* **Line 153**, "two citations whose attributed statements were inexact". The claims report has three (findings 19, 20, 21: a post that nobody opened cited for what it argues, "black-box" dropped, a formula attributed to both of two papers) and a fourth attribution in Section 1 (finding 22). All four were corrected in the text.
* **Line 136**, "All but one were accepted", and "two blog posts … cited as known from memory or through another paper". Of the accepted findings on circuits, four were carried out only in part: claims 3 (finding 10 here), claims 16 and 26 in the summaries (finding 9), claims 27 (finding 13) and claims 28 with computation 7 (findings 6 and 18). The second post is now cited as "not consulted; title and author as returned by a search engine", not from memory.

One erratum in `research/circuits-final.md` (line 568) misquotes its own text: the source has "between 2 and 32 per cent in every case computed with slack or in the exception", for which only the lower end was wrong; the erratum quotes it as "with slack".

**Corrected text.** Line 154: "Not added to the script. Section 7.10 lists these numbers and says that they are not in the results file; the referees of rounds 6 and 7 reproduced them with their own code." Line 153: "three citations whose attributed statements were inexact or unsupported, and one attribution in Section 1". Line 136: "…two blog posts could not be opened; one is cited through another paper and one by its title only." Add after the table: "The repairs were checked in round 7."

---

## Passages found correct

**Section 7, new material.**

* **Extended prior (583-595).** Consistent: the weights sum to 1 over all formats, ξ is a measure, and Σ_s w_s ≤ 1. "Parts (c) to (f) remain true with the unseeded mixture" holds: in (c) ξ cancels, in (d) it enters through ξ(x_i) ≥ w_s/N_s, and (e), (f) contain no ξ.
* **`thm:c-refund`(c), (d), (e), (f), (h) and their proofs (604-638, 651-666).** Re-derived under the extended prior. In (d): N ≤ 2^min(r,s+1) from (a), q(S) ≤ w_s/N_s^(k+r) from (A2), share at most ϖ_i. In (e): the chain to 2^(2σ−(s−σ)(2+2log2(k+σ))) and the threshold. In (f): s below the size of every W_i, and the last claim. In (h): both forms; the unseeded form uses (A2) and one instance.
* **"What is excluded and what is not" (669-687).** Each sentence carries its assumption and its part. The table of 2^k seed bits with 3(2^k−1) gates is universal for every size and has fewer than (σ+1)/2 gates once σ ≥ 6·2^k.
* **Gate-list prefixes (689-694).** Count N_{s+j}/N_s, mass Σ_j w_{s+j}/N_s, 2q(V) under the length prior: correct. See finding 5 for the two sentences after it.
* **One-gate example (785-804).** By hand: ē(1) = 101 by the code of `sec:floor`; pointer width ⌈log2 22⌉ = 5; l(1) = 3+4+10 = 17; the fields 10101 = 21, read as wire 1+(21 mod 21) = 1, and 01010 = 10, read as wire 11, which carries b_10; table and both fields are palindromes. For t−1 = 1019,…,1023 the gate gives 1,0,1,0,1, and for t−1 = 1024,…,1036 it gives 1,0,1,0,1,0,1,0,1,0,1,0,1; together 101011010101010101 = y. x = (01)^509 0 has 1019 bits, n+m = 1037 ≤ 2^21, m = l(1)+1. One-gate circuits that print x: 4 (both pointers on wire 1) + 2·9 (projection, other pointer on b_1,…,b_9) + 8·11 (other pointer on b_10,…,b_20) = 110, none without a pointer on wire 1; of these, the two with ⊕ on wires 1 and 11 print xy. Share 2/110 = 1/55 under μ_1. The script gives the same string and the counts 110 and 2.
* **"4 of 2k+8" (462-467).** 4 + 2(k−2) + 8 fitting circuits, of which 4 deviate at each query with v = 1; confirmed by count for k = 2,…,8 and every position of v.
* **Sums over triggers (528-537).** 2^-14.63 for one input; with R_g: 8.31·10^-4, 8.97·10^-4, 9.83·10^-4, 1.10·10^-3, 1.24·10^-3 for g = 1,…,5; 0.138 for the sum over g ≤ 19 (0.139 with all 20 inputs at g = 0); a single g exceeds 1 first at g = 28 (1.24), the sum first at g = 25 (1.06). The figures quoted from the source (0.0096, 0.082, 0.57, 3.5) are the same bound with N_g for R_g.
* **Floor against exact values (377-383).** For k = 3 and the world b_0∧b_1: three-gate floors 1.50·10^-8 to 1.94·10^-8 at s = 4 and 5.1·10^-9 to 6.1·10^-9 at s = 5 over the cuts 3 to 7; flipped-bit probabilities 0.0570 to 0.9489; a three-gate wrapper exists at each of these cuts. At n = 4, s = 4: 214 336/124 490 240 = 0.00172 against 8 101 888/124 490 240 = 0.0651.
* **Separably triggered cores (539-543).** 16 of 48 at s = 2; 8512 of 29 824 at s = 3, of which 8128 by the frozen input and 384 by a one-gate trigger (own enumeration of all cores of at most three gates).
* **`thm:c-capture`(d) (747-752).** 2 of 76; 0.02712, 0.02760, 0.02790; 4608 circuits, a quarter at each input with three 0s.
* **Worked numbers (369-375, 566-568).** 24.0 and 25.0 bits; about 500 bits for 20 gates; about 1600 for 64 gates; s_0 = 22 326 and 2^-33.9; 1744 and 12 080; 19+13+3 = 35.
* **"Small cases, computed" (906-972).** Both tables and both captions against `circuits.json`: all 23 and 18 entries, and the values at s = 1. 0 at the least size outside the exception; 27 to 32 per cent in the exception; 1/53 and 0.289 as the ends with slack; grows or falls as stated; 1 and 0.81 to 0.98 for worlds that depend on the bit; the two complements; 0.68 to 1 for the other data sets; 0.0255, 0.0310, 0.1013; the second variant agrees with the target at the query; 13.5 and 53.4 per cent of the deviating mass; one half, 0.468, 0.446, 0.429; one quarter and one eighth. The argument that every deviating circuit has a pointer to the never-varied input in its core is correct (with finding 8). The list of differences from the source (968-972) agrees with the source and its errata.
* **"Open" (1112-1119).** Items 1, 2, 5, 6 and 7 agree with the section. Items 3 and 4: finding 7.
* **Other rewritten sentences read.** The test at n = 2^k−1 needs k−1 gates by `thm:c-refund`(a) (366-367); the conjunction test with one gate fewer than n has ones (297-299); the family of wrappers and its prior mass (385-395); "about 3 active gates at k = s = 1000" (simulation: 3.00); the list "Proved" items 1 to 7 with their priors, apart from finding 8.

**Summaries.** Apart from the findings, every sentence agrees with a numbered result.

* **Abstract, bullet (111-126).** Reading; `thm:c-transfer`; "not available to a single description"; `thm:c-core`(b); (A2) and the instance, with the sentence that this limits the description and not what is returned; (σ+1)/2 with σ+3 ≤ 2^k; the floor and one gate at a never-varied bit; three classes; the minimal-circuit problem with two formal conditions; recurrence with w(2^w−3) gates. "A few to a few tens of per cent carried by the circuits that read the bit" is right for worlds that ignore the bit, which the last sentence says.
* **Abstract, last two sentences (130-135).** Prior, four inputs, four gates of slack, "2 to 29" with gates to spare: correct. "81 to 100": finding 10.
* **Section 1, item "Circuits" (149-171).** log2(16a(k−1)); "exists at the price of", with the lower bound for separate triggers only; 1/(32(k+s_0)²+2) with s_0 as described; s_D ≥ 2 kept; (A2) in full; "not available to one description", with the question for sets open; recurrence.
* **Section 1, "does not settle" (231-235).** Agrees with "Open".
* **Section 8, 151-202.** Paragraphs 1 to 4 agree with `thm:c-readings`, `thm:c-transfer`, `thm:c-core`, `thm:c-refund`, `thm:c-floor`, `thm:c-minimum`, the tables, the three ceilings and `thm:c-self`. Paragraph 5: the guess is marked as supported by no result, "three tenths" is 16/48 and 28.5 per cent, recurrence is stated with its cell; findings 9 and 14.
* **README, bullet (44-52).** As Section 8. "Up to k gates at the positions hardest to name" is k−1 gates for the test and one for a constant answer. The two claims that round 6 found returned ("no refund for the rarity of uses", "no simple world with a long history") are gone; I compared the summaries with every row of the source's list of dropped claims and found none restated.
* **README, "Contents".** `test_circuit_count.py` covers the sizes stated. The commands under "Reproduce" work: the test passes, and `run_circuits.py` with `make_circuit_table.py`, run in a copy, reproduce `circuits.json` and both tables byte for byte (19 s).
* **README, "Status".** The list of what is proved in the paper for circuits is right, with the universal-circuit bound attributed to the research file; finding 19 for the rest.
* **`verification/README.md`.** "107 in all" is the sum of the six reports (28+18+17+12+16+16). Rows 147-150 and 152 are accurate.

## What I recomputed, and how

Scripts are in the scratch directory `/tmp/claude-0/-home-user-AI-works/6274030e-7ece-5c94-928b-387c437d466d/scratchpad/ref7-circuits/`, outside the repository; it may have been cleared since.

* `mycount.py`, `build.py`: own counter of circuits by function (a dynamic programme over multisets of wire functions, checked against own direct enumeration for k = 2, 3 up to three gates and k = 4 up to two). Counts for k = 3 up to five gates and k = 4 up to four gates; each sums to N_s.
* `check_json.py`: all 56 entries of `circuits.json` (query form, triggered variants, AND family, sequence form) from my own definitions of data, query and index reading. No mismatch, as exact integers and fractions.
* `floor.py`: the floors and flipped-bit probabilities of 377-383.
* `rg.py`: R_g by the recursion, checked against direct enumeration; the sums of finding 6.
* `onegate.py`: the exception count for k = 2,…,8; for the example, the literal code written out from the definition, the gate b_0⊕b_10 evaluated at positions 1020 to 1037, and the one-gate circuits counted against x and xy.
* `contr.py`: the contrarian record under small mixtures (finding 3).
* `septrig.py`: separably triggered cores by enumeration of all reduced circuits of at most three gates on three inputs.
* `misc.py`, `active.py`: capture example, gate prices 13.00 and 14.12 bits, s_0, the bit prices, the gadget thresholds, the simulation of the active part.

**Two files that appeared while I worked.** Findings 6, 18(i), 19(ii) and the first point of 20 describe the commit named at the top. During this round two untracked files appeared in the working tree, written by another job: `experiments/run_circuits_extra.py` and `experiments/results/circuits_extra.json`. They are not part of the version refereed, and I did not write or change them. I ran the script in a scratch copy: it reproduces the JSON file (24 s). Every quantity that the file and my own scripts both contain agrees: the two gate prices (13.001 and 14.123 bits); the floors and flipped-bit shares for all ten pairs of cut and size; 16 of 48 and 8128 + 384 = 8512 of 29 824; R_1 to R_5, the sums 0.1380 and 0.1387 up to g = 19, and the thresholds 28 and 25; the capture example; the exception for k = 3,…,7; a mean of 3.01 active gates. If the two files are committed, the numbers of finding 6 have a script, and what remains is to name the script and the file in Section 7.10 (960-966), in `README.md` (77 and 95) and in the row of `verification/README.md` (154). None of these texts mentions them yet.

**Not checked.** Statements of Section 7 that round 6 confirmed and that have not changed. The citations. Section 3.7 and its summaries, which another report of this round covers.
