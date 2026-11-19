# Referee report 2 on "A toy malign-prior question with an answer"

Date: 2026-11-10. Version refereed: the sources in `paper/` with `main.pdf` built at 11:27 UTC (19 pages), and `README.md`, `code/`, `experiments/` and `verification/README.md` as committed in "revise after the first referee round". I had not seen the note before.

Numbering is that of the current PDF: Thm 8 (calibration), Thm 9 (floor), Thm 10 (self-reproducing floor), Thm 11 (searching), Remark 12 (callers), Prop. 13 (repetition), Thm 14 (budget), Thm 15 (capture), Thm 16 (machine dependence), Thm 17 (feedback), Thm 18 (contrarian). From Thm 11 on these are one higher than in report 1.

**Bottom line.** No numbered statement is wrong. The new and changed theorems are correct as stated, apart from a missing hypothesis `|P(x)| >= m` in two places. What is still wrong is in the prose that interprets the new material, and in the summaries:

1. Thm 11(b) is an average, and every machine whose output always passes the test attains it, whether it searches or not. For the searcher built in the proof, the gain at a given handover can be below 1. The pointwise statement that the prose relies on is true up to a factor 2 and a few bits, but it needs a different machine (B1).
2. Section 4.2 says the cap of Thm 15(c) holds "however large N is". In the situation of Thm 15(b) the cap applies to one of the N placements only. Section 1 and the README present the cap as limiting the factor-N gain (B2).
3. In the bullets after Thm 11, the example of a rare test is not rare, and two claims about the bounded search are wrong as stated (B3, B4).
4. Six summary sentences still say more than is proved (D1 to D6). The two that matter most: "a tight time or length bound removes the gain", and "with a copy at a simpler place the odds are against the truth, by the difference in code lengths".
5. The first-round findings are resolved. Two residues: the README repeats the two-sided claim of B7, and Section 7 restates the calibration theorem without its condition (B9) (section C).
6. The computation is clean: every number in Section 6, the three tables and the README matches the results file and fresh runs of the enumerator (section E).

What I ran: `python3 test_bf8.py` (prints `ok`); a rebuild of `bf8enum.c` in a scratch directory (same md5 as the committed binary); the existing binary at 3 to 11 commands with `T(k) = 24k`, at 9 and 10 commands with `T(k) = 3k`, and at 3 and 5 commands with schedules of 20000 and 2000 steps per bit; arithmetic on its output files and on `profiles.json`. I did not rerun `run_profiles.py`. I wrote no code that executes BF8 programs; my scripts only read the enumerator's output files, the JSON and the generated tables. No file in the repository was changed except this report.

---

## (A) Verdict on each new or changed result

| Item | Verdict |
|---|---|
| Section 3.4, identity for the posterior share of the programs beginning with a prefix word `v` | CORRECT AS STATED. It uses only `out_U(v omega) = out_V(omega)`. It holds for every word `v`, with `V` the machine `omega -> U(v omega)`, so "a machine V with prefix word v" is no restriction. |
| Thm 11(a), and "the sum over first hits of `M_V(x)` is the probability that the output of V has a prefix in G" | CORRECT AS STATED. First hits are prefix-free, so the events are disjoint, and an output has a prefix in `G` exactly when its shortest such prefix is a first hit. First hits with `M_U(x) = 0` drop out consistently, because `M_V(x) > 0` implies `M_U(x) > 0`. |
| Thm 11(b), the machine `S` and the claim that its output is with probability 1 a first hit followed by the payload | CORRECT AS STATED. Each bit `S` reads is a fresh fair coin, given to a simulation that is chosen from what was read before. So the joint behaviour has the law of independent inputs under a fixed dovetailing. A simulation that hits does so after finitely many of its own steps, and the probability that none of infinitely many hits is 0. |
| Thm 11(b), the displayed inequality, and whether `M_S(x P(x)_{1:m}) = M_S(x)` for a first hit `x` | CORRECT BUT GAP. The equality holds: the output of `S` is empty or `x' P(x')` with `x'` a first hit; if a first hit `x` is a prefix of `x' P(x')` then `x` and `x'` are comparable, hence equal. Missing: the hypothesis that `P(x)` has at least `m` bits at every first hit, as in Thm 9 and Thm 16(i). |
| Text after Thm 11 ("gains the factor `1/H_G` on average", "no family ... can gain more") | CORRECT as statements about the average. What the average does not show is in B1. |
| First bullet after Thm 11 | The lower bound on `H_G` by the weight of the searcher: derived in one line, CORRECT (directly: almost every program `s omega` hands over). "Tests about as rare as they are complex": asserted; the conditional is correct arithmetic; the example is WRONG (B3). |
| Second bullet after Thm 11 | The factor `g` and its lower bound: derived in a phrase, CORRECT. "Reads at most `k tau` input bits": CORRECT. "Starts printing after a number of steps of order `k tau`": worst case only. "It has mass only if `L` and `T(1)` allow about `k tau` bits and steps": WRONG. The term `L/tau` in the last bound: not supported (B4). "A test whose hits can be generated directly ... does not need the search": asserted, true, and it undercuts the reading of (b) (B1). |
| Remark 12, twin share at least `2^{-c} kappa(x)` | CORRECT BUT GAP (B5): follows from the proof of Thm 9 if a simulator can detect the stopping rule; `c` then contains the rule. |
| Remark 12, the searcher's expected share, with `kappa-bar / H` in place of `1/H_G` | CORRECT BUT GAP (B5): exact for the programs that stop at the context, a lower bound for the programs that print it, because contexts are no longer prefix-free. |
| Remark 12, law of the own continuation among callers | CORRECT, with a clash of notation and a dropped condition (B5). |
| Thm 10 as stated with `rho°` | CORRECT AS STATED. `L° = min(L, m-1) - c` gives `c + r + 1 <= m` and `c + r <= L`, which is all the proof uses. |
| Paragraph after Thm 10 | "At most `2^m` sequences any prefix of which ...": correct in substance, wrong as written. "Exactly 0 at all but `2^m` of the `2^n` possible contexts": CORRECT (at most `2^m`). "`rho°` is close to 1 exactly when ...": NOT PROVED (B6). |
| Paragraph after Thm 9, `T(1) < c` | CORRECT. By Def. 3, `r_U(v omega, 1) >= c`, and `r <= t`, so `t_U(v omega, 1) >= c`. If some `T°` satisfied (2) and some `omega` were in `E^{T°,L-c}(x)`, then `t_U(v omega, 1) <= gamma(a(T°(1),1)) <= T(1) < c`, a contradiction. So `rho(x) = 0` for every admissible `T°`. |
| Thm 14(iv), the count "at most `m log_2(...)`" with its proof, and the two bullets | CORRECT AS STATED. `tau_m(k) >= 1/2` is `sum_{j<m} b_{k+j} >= 1`, and summing block sums counts each index at most `m` times. The majority form gives `tau_m > 1/2`, and the window average is `m l ln 2 / N`. |
| Thm 15(a), (b), (c) | CORRECT AS STATED under the standing assumption that the programs named are within the bounds. |
| Thm 15(d), the flagged reader | CORRECT BUT GAP: needs the hypothesis that `P(x)` has at least `m` bits. The construction and the constant are right. |
| Prose after Thm 15 | On (b): correct. On (c): "however large N is" is WRONG in the situation of (b) (B2). On (d): correct, including "a share of that one explanation and not of the whole posterior". |
| Thm 16(i), (ii) | CORRECT AS STATED (for a first hit with `M_U(x) > 0`). |
| Sentence after Thm 16 on self-reproducing continuations | CORRECT. I checked it: if the branch `0 omega` prints `x 0 omega_{1:r} 1 0^infinity`, then `y = 0 omega_{1:r} 1 0^{m-r-2}` is self-reproducing on the new machine for every explanation `omega` of `x` with `r <= m-2`. These blocks have mass at least `(1/2) xi_U^{infinity,m-2}(x)`, and `x` has mass `(1/2 + 2^{-k-1}) M_U(x)`. |
| Section 4.4, three observations | First: CORRECT. Second: the displayed fact is CORRECT; "and with it the repayment of the base rate" holds for the searcher of the proof only (D1). Third: CORRECT; for finite `L` the set of inputs that print all of `z` within the bounds is a union of cylinders `[p]` with `p` of length at most `L`, each of them a program for `z`. |
| Thm 17(c) with the added condition | CORRECT AS STATED. |
| Section 5, "after at most `L+1` rounds" | CORRECT for the predictor of Thm 18, which returns the more probable next bit. It fails for the sampling predictor (D4). |
| Section 2, added conventions and the paragraph after Def. 7 | CORRECT. One convention of the first round is still missing: the value of `a(infinity,k)` in (2), needed when `T°` is infinite (section F). |

---

## (B) Errors and gaps, most serious first

### B1. Thm 11(b) is attained without searching, and at a given handover the searcher of the proof can gain less than 1

**Where.** `sec3-floor.tex` 155-161 and 172-176; `main.tex` 51-53; `sec1-intro.tex` 36-37; `sec7-answers.tex` 19-22 and 33-34; `README.md` 17 and 20.

**What the theorem shows.** The proof of (b) uses one property of `S`: its output starts with a first hit with probability 1. So almost every program `s omega` hands over, and these programs are the fraction `2^{-|s|}/H_G` of the worlds that hand over. That is the whole content of (b), and it holds for every machine with this property.

**What follows from that.**

1. A machine that prints one fixed first hit `x_0` and then `P(x_0)` also attains `2^{-|v|}/H_G`. All of it comes from the single context `x_0`. At every other handover its share is 0. So "a hypothesis that searches the space of programs for a handover attains this" (Section 1) and "the searcher is optimal among families of its length" (Section 7) do not separate searching from not searching. The note's own sentence at line 190-191 ("A test whose hits can be generated directly ... does not need the search") says the same.
2. The share of `S` at a first hit `x` is `2^{-|s|} Q(x)/M_U(x)`, where `Q(x)` is the probability that the first simulation to succeed, in the order of the dovetailing, succeeds at `x`. Nothing is proved about `Q(x)/M_U(x)` at a given `x`, and it is not `1/H_G`. Take the dovetailing in which stage `n` starts simulation `n` and gives every started simulation one step. Suppose a fraction `h` of worlds reaches a first hit within `t_0` steps, and every explanation of `x` needs more than `t` steps. Simulation `i` can then print `x` at stage `i+t` at the earliest, and by then `i+t-t_0-1` other simulations have had `t_0` steps. So `Q(x)/M_U(x) <= (1-h)^{t-t_0}/h`. This is below 1 once `t - t_0` exceeds about `(1/h) ln(1/h)`. At such a context the searcher has a smaller share than a twin with a prefix word of the same length. The average `1/H_G` is carried by handovers that are reached quickly.
3. "Is repaid the `log_2(1/H_G)` bits by which handovers are rare" (line 176) is true of the arithmetic mean of the share. The mean of the logarithm of the gain is `log_2(1/H_G) - KL(M_U/H_G || Q)`, which is smaller unless `Q = M_U/H_G`.

**The pointwise statement is true, with another machine.** Fix `j` with `2^{j-1} H_G <= 1`. Let `V_j` enumerate the minimal programs `p` of `U` whose output reaches a first hit `x_p`. They form a prefix-free set of measure `H_G`. `V_j` gives them, in the order found, consecutive intervals of `[0,1)` of length `2^{j-1-|p|}`. On input `omega` it reads bits until the cylinder read so far lies inside the interval of some `p`, and then prints `x_p` and `P(x_p)`. Then `M_{V_j}(x) = 2^{j-1} M_U(x)` for every first hit `x`. With `j = floor(log_2(1/H_G)) + 1` and `v_j` a prefix word, `M_U(x P(x)_{1:m}) >= 2^{-|v_j|-1} M_U(x)/H_G` at every first hit. If `j` is read from the input, `|v_j| <= c + |e(j)|`, which is `2 log_2 log_2(1/H_G) + O(1)` bits more than a constant. By (a), no family with a prefix of length `a` has share above `2^{-a}/H_G` at every first hit. So the gain at every handover is `1/H_G` up to a factor 2 and these bits. This machine also has a long start-up, so the remarks on time bounds carry over.

**Fix.** Either replace (b) by the pointwise statement, or keep (b) and add three things: that it holds for every machine whose output always passes the test; that the share at `x` is `2^{-|s|} Q(x)/M_U(x)`; and that for the time-bounded search of the second bullet the gain is the same at every first hit, since there `Q(x) = g M^(tau)(x)` with `M^(tau)(x)` the mass of worlds that reach `x` within `tau` steps.

### B2. The cap of Thm 15(c) does not limit the factor N of Thm 15(b)

**Where.** `sec4-limits.tex` 106-108 ("so a copy gains at most the difference between this cost and its own, however large N is"); `sec1-intro.tex` 43-47; `README.md` 24.

**What is wrong.** (c) assumes that the sensor's location `i*` is the least location other than `i_0` whose record agrees with that of `i_0` on the first `n_1` bits. In the situation of (b), `N` locations show `x`. For `n_1 <= n` they all agree with `i_0` on the first `n_1` bits, so the assumption holds for one of them at most, the one with the least index. So (c) caps the odds against that one placement, which for large `N` is one of the "at most `delta N`" exceptions of (b). For the `j`-th placement in index order the same argument needs the description "the `j`-th other place that shows the same data", which costs `|e(j)| <= 2 log_2(j+1) + 3` more bits. For a typical one of `N` placements the cap is therefore larger by a factor of order `N^2`, and it grows with `N`. Read as a limit on (b), the sentence contradicts (b): odds above `delta N` times a constant for most placements, and below a constant for all. The same paragraph says, two sentences later, that a copier can "raise the cost of matching by making decoys ... which is the situation of (b)"; that is right, and it is the opposite of "however large N is".

**Fix.** In Section 4.2: "(c) caps the odds against the first other place that shows the origin's record, whatever else shows it; against the `j`-th such place the cap is larger by the cost of naming `j`." In Section 1 item 5 and in the README, separate the two cases. With one other place that shows the data, and a generous schedule, the odds are capped by the cost of "the other place that shows the same data". With `N` such places the factor of order `N` applies and that cap does not.

### B3. The example of a test "about as rare as it is complex" is not rare

**Where.** `sec3-floor.tex` 179-182: "for tests that are about as rare as they are complex (a long marker in the transcript, say) the repayment cancels the description of the test".

**What is wrong.** Let `v_0` be a prefix word of the machine that ignores its input and prints all binary strings one after another. Every world `v_0 omega` has every marker `w` in its transcript. So for the test "the transcript ends with the first occurrence of `w`", `H_G >= 2^{-|v_0|}` whatever `w` is. A long marker is as common as a short one. There are at most `|v_0|` bits to repay, so the description of `w` is not cancelled: the searcher's expected share is at most `2^{-|s|+|v_0|}`, and `s`, built from a description of `G`, contains `w`, which takes about `|w|` bits for a typical marker.

**What is right.** The conditional is correct arithmetic. If `S` is built from self-delimiting descriptions `d_G`, `d_P`, then `|s| <= |d_G| + |d_P| + c_0`, and if `H_G <= 2^{-|d_G|+O(1)}` the expected share is at least `2^{-|d_P|-O(1)}`. The first premise is stated only for the twin (after Thm 9) and should be stated for `S`.

**Fix.** Use a test that fits, for example a marker at a fixed place: `G = {w}`, "the transcript begins with `w`", where `H_G = M_U(w)`. Say that this test needs no search. Say that a marker anywhere in the transcript has a base rate bounded below by a constant of `U`, so there is nothing to repay. Section 7 (lines 23-25) and the README repeat the conditional without an example; they are correct as conditionals if "the share is" becomes "the expected share is at least".

### B4. The bounded search: two claims are wrong as stated

**Where.** `sec3-floor.tex` 185-190.

- **Correct:** the factor `g`. The machine with `k` tries prints the first hit `x` with probability `sum_{j<=k} (1-H^(tau))^{j-1} M^(tau)(x) = g M^(tau)(x)`. The lower bound follows from `1-(1-H)^k >= 1-e^{-kH}` and `1-e^{-u} >= (1-e^{-1}) min(u,1)`. "Reads at most `k tau` input bits" follows from `r <= t`.
- **Worst case only:** "starts printing after a number of steps of order `k tau`". A program whose `j`-th try succeeds starts printing after its `j` tries.
- **Wrong:** "Under bounds `(T,L)` it has mass only if `L` and `T(1)` allow about `k tau` bits and steps." The programs whose first try succeeds read at most `|s'| + tau` bits and print after one try. They have mass as soon as the bounds allow one try. The machine is then a twin restricted to worlds that hit within `tau` steps, with no gain.
- **Not supported:** the term `L/tau` in "at most about `min(1/H, T(1)/tau, L/tau)`". "At most `tau` bits per try" shows that `L` bits are enough for at least `(L-|s'|)/tau` tries. It gives no upper bound: a failed try can read far fewer than `tau` bits (a world that loops without output after a few bits), so many more tries can fit. The term `T(1)/tau` is right when a failed try runs its full `tau` steps.

**Fix.** "The programs that succeed at the `j`-th try need the time of `j-1` failed tries before their first bit and have read the bits of those tries. Under bounds `(T,L)` only the tries that fit count, and the gain is `g` with `k` replaced by their number: about `T(1)/tau` under the schedule, and `L` divided by the number of bits a failed try reads under the length bound."

### B5. Remark 12: what is missing to make the three claims precise

**Where.** `sec3-floor.tex` 194-208.

- **Stopping rule.** "Decided by the computation of `U` on `omega` up to the `n`-th output bit" does not cover the example, an instruction executed after the `n`-th bit is printed. Write "before the `(n+1)`-th output bit". The twin of the first claim needs the rule to be decidable from the computation history by a simulator. Its constant then contains the rule. "Contains no description of a test" is right only for a rule built into `U`, as in the example.
- **Second claim.** The contexts of a stopping rule are not prefix-free: one world can hand over at `x` and another at a proper extension `xu`. So "all its programs that print `x` continue with `P(x)`" (proof of Thm 11) fails. With `Q(x)` the probability that the searcher stops at `x`, the programs that stop at `x` have expected share `(2^{-|s|}/H) sum_x Q(x) kappa(x)`, which is the claim. The programs beginning with `s` that print `x`, which is how "share" is defined before Thm 11, have at least that. Define `kappa-bar = sum_x Q(x) kappa(x)` and say which of the two is meant.
- **Third claim.** `C(xd)` is used for "worlds that hand over at `x` and go on to print `d`", two lines after `C(.)` was defined as the mass of worlds that hand over at its argument. By that definition `C(xd)` is the mass of worlds that hand over at `xd`. Use another symbol. The law is among callers that print `m` more bits, the qualification the note makes for Thm 8.
- `H` is here `sum_x C(x)`; it is `H_G` in the theorem, `H^(tau)` in the bullet, and `H_m` is an event in Thm 8.

### B6. Paragraph after Thm 10: one sentence wrong as written, one not proved

**Where.** `sec3-floor.tex` 127-133.

- "A block in `SR_m(x)` determines `x`, so for fixed `m` there are at most `2^m` sequences any prefix of which has a self-reproducing continuation at all." A block determines `x` only together with `|x|`. Read literally, the set of sequences with some prefix that has a self-reproducing continuation contains every extension of such a prefix and is uncountable. What is true and what is used: every context with `SR_m(x)` nonempty is a prefix of `out_U(y 0^infinity)` for some `y` in `B^m`, so at most `2^m` contexts of each length have one. `verification/README.md` (row B1) has the same wording.
- "`rho°(x)` is close to 1 exactly when the context has explanations much shorter than the block and the bounds have room." Not proved, and not what `rho°` measures. `rho°(x)` is close to 1 when nearly all of the posterior at `x` is on explanations that read at most `m-1-c` bits. Without bounds it tends to 1 as `m` grows for a fixed context, but the rate is not controlled by the length of the shortest explanation. The note's own data illustrate this on BF8: the four-command programs for `1^48` hold 14% of its mass at 11 commands (`3/1024` of `0.0212`), and the eleventh command still adds 9%. Section 7 line 17 ("near 1 when the block is much longer than the shortest explanations") has the same problem. **Fix:** "`rho°(x)` tends to 1 as the block grows, for a fixed context and without bounds; it is 0 when no explanation fits."

### B7. Missing hypotheses in the new statements

- Thm 11(b) and Thm 15(d): `|P(x)| >= m`.
- Thm 16(i): `M_U(x) > 0`.
- Thm 17(c): the product is undefined once a context with `Z_m = 0` is reached; read it as 0.

---

## (C) Status of each first-round finding

Rows follow `verification/README.md`.

| Finding | Status |
|---|---|
| B1 (self-reproducing floor misreported) | RESOLVED. Thm 10 names `rho°`; abstract, Section 1 item 2, Section 7 and README state the right factor. The new paragraph after the theorem has the two problems of B6 above. |
| B2 (wrong programs in Section 6) | RESOLVED. The four programs, the restart rule, six commands, one mechanism, "it has no wrappers". I confirmed the lengths with the enumerator (section E). A comment in `code/test_bf8.py` line 40 still speaks of "the two programs behind the capture example of the paper" before one program. |
| B3 (dependence on the 10-command limit) | RESOLVED. Table 2, the paragraph on it, the abstract and the README are consistent with the data, and no claim goes beyond 11 commands. |
| B4 (the searcher remark) | RESOLVED as to the finding. The remark is replaced by a correct theorem, and Sections 1, 2 and 7 say that in the main definition a handover can be read off the data. The replacement has its own problems: B1, B3, B4 and B5 above. |
| B5 (factor `m` in the abstract) | RESOLVED. |
| B6 (summary sentences claiming upper bounds or necessity) | RESOLVED for the six sentences named. Sentences of the same kind remain: D1 and D2 below. |
| B7 (machine dependence) | PARTLY. The paper is fixed, and the new sentence on the self-reproduction form is correct. `README.md` line 23 still says "at most k+1 bits away from U in description lengths", which is the two-sided claim again. |
| B8 (capture) | RESOLVED as to the three points raised: the reading of (b), the full factor, and the remark that the matcher needs a generous schedule are all there. A different error in the same paragraph, not raised in round 1, remains: the prose presents (c) as a cap on the gain of (b) "however large N is" (B2). |
| B9 (sentences after the calibration theorem) | PARTLY. Section 3.1, Section 1 item 1, abstract and README are right. `sec7-answers.tex` 32-33 restates the theorem without "that go on within the bounds". The sentence "A malign prior hypothesis with content is therefore ..." is now a gloss, which I accept. |
| B10 (smaller errors) | RESOLVED, all five. `T(1) < c` is treated correctly, and `L+1` is used throughout. |
| B11 (proof gaps) | RESOLVED, all four. |
| B12 (classification in Section 4.4) | RESOLVED. |
| C16 (posts cited as if read) | RESOLVED. |
| C18, C19, C20 | RESOLVED. |
| C21 (reading the deployment off the simulation) | RESOLVED. Thm 15(d) is correct, and the text says that the weight is a share of one explanation. Residue: `sec7-answers.tex` 48-51 and `sec1-intro.tex` 47-49 state it without the theorem's standing assumption that the program is within the bounds. In the regime that Section 4.4 calls usual, the reader it wraps has no mass. |
| C23, C24, C25 | RESOLVED. |
| D3, D4 (description of BF8) | RESOLVED. |
| D6 (wording in Section 6, figure, table) | RESOLVED. I checked each point, and rendered the figure: the exact zeros are visible. |
| E (citations) | RESOLVED. Both rewordings agree with the literature survey, and all 14 bibliography items are cited. |
| F (conventions, count, notation) | RESOLVED. New clashes are listed in section F below. |

`verification/README.md` describes accurately what was changed. It should say that the theorem numbers of report 1 are one lower than the current PDF from Thm 11 on. Its entry for round 2 points to "the end of `referee-2.md`"; the summary of this report is at its top.

---

## (D) Summaries and README

Sentences that state more than is proved, or that conflict with another part of the note. Everything not listed I found consistent with Sections 2 to 6.

**D1. "A tight time or length bound removes the gain."** `main.tex` 53-54; `sec7-answers.tex` 25-26 ("the repayment is lost and the wrapper's `2^{-c}` remains"); `README.md` 17; `sec4-limits.tex` 169-170 ("and with it the repayment of the base rate"). What is proved is that the programs of this searcher whose search outlasts the bounds have no mass. That the gain is lost would need an upper bound under `(T,L)`, and there is none. The identity of Thm 11(a) holds under bounds as well, with the probability of a handover within the bounds in place of `H_G`, and every family whose programs all hand over within the bounds gains that factor. For the test "the length is n", a machine that copies its input hands over on time with no start-up beyond its prefix word `v` (it needs `L >= n + |v|`), and one that prints a fixed string needs neither time nor input. The note's own sentence at `sec3-floor.tex` 190-191 says this. *Fix:* "so a tight time or length bound removes this searcher; a test whose hits can be generated directly needs no search".

**D2. "With a copy at a simpler place the odds are against the truth, by the difference in code lengths."** `sec7-answers.tex` 63; `README.md` 29. Thm 15(a) bounds `xi(xy)` from below. An upper bound on `xi(xd)` is given only for most of `N` placements, in (b). For the sensor's own placement nothing bounds `xi(xd)` by `2^{-c_X-|e(i*)|}`, and (c) shows the opposite under a generous schedule: the truth has an explanation of cost `c_match + |e(i_0)| + |e(n_1)|`, which does not contain `|e(i*)|`. So the odds are not the difference of the two location codes, and their direction is not proved. *Fix:* "With a copy at a simpler place the odds against the truth are at least `2^{-c_X-|e(i_0)|}/xi(xd)`; for a typical one of N placements this exceeds `delta N` times the copy reader's share of the context."

**D3. The cap and the factor N.** `sec1-intro.tex` 43-47; `README.md` 24. See B2. Also, "beats all but a few by a factor of order N" trades one against the other: all but a fraction `delta` are beaten by `delta N` times the share.

**D4. "A world that does the opposite of what is predicted leaves a length-L predictor without any hypothesis after at most `L+1` rounds."** `main.tex` 65-66; `sec7-answers.tex` 77-78; `README.md` 26. True for the predictor of Thm 18, which returns the more probable next bit. The summaries do not say so, and the predictor of the same bullets is the sampling one. For it the bound fails. Example with `L = 2`: a machine reads two bits and prints `0^infinity` on `00`, `001^infinity` on `01`, `01^infinity` on `10`, `1^infinity` on `11`. With probability `(1/4)(1/3)(1/2)` the three samples are 1, the record is `000`, and `xi(000) = 1/4` after `L+1` rounds. *Fix:* add "that returns the more probable bit".

**D5. README, machine dependence.** Line 23: "at most k+1 bits away from U in description lengths". The machines raise description lengths by at most `k+1` bits and lower some without bound (first-round B7). Write "whose description lengths exceed those of U by at most k+1 bits", as Section 1 does. In the same line, "a given world" should be "a given computable world".

**D6. Calibration in Section 7.** `sec7-answers.tex` 32-33: "on worlds drawn from the predictor's prior, what the predictor hands over is distributed like what the worlds would have printed themselves". Add "that go on within the bounds".

**D7. "The only hypotheses we can exhibit."** `sec7-answers.tex` 61-62 says "wrappers"; `README.md` 29 says "wrappers and searchers"; the bullet just before (lines 48-51) exhibits the flagged reader. `sec1-intro.tex` 83-84 says the toy exhibits "only programs ... which are longer than what they wrap", while Thm 15(a) and Section 6 exhibit programs shorter than the honest explanation that have the effect: the reader at a simpler location, and the three-command programs. The intended claim is narrower: on an arbitrary world and a universal machine, for a continuation chosen in advance. Say that, and use one list.

**D8. Smaller wording.**
- `sec7-answers.tex` 95: "none of the bounds apply". The budget does not apply. The floor does, wherever the context has explanations within the bounds.
- `sec7-answers.tex` 75 ("it stays on the default when the default is cheap and well learned") and the same clause in `README.md` 26, each next to "with certainty" for leaving. Staying holds with probability at least `xi(x d_1 d_2 ...)/xi(x)`, not with certainty.
- `README.md` 17: "has expected share `2^(-|s|)/H`" needs "without resource bounds", which Section 1 has.
- `README.md` 3: "checked by an AI referee" is now two.

**D9. The question combines two things that the note answers separately.** The second question is about hypotheses that both look for handovers and hand over their own code (`README.md` 8; `sec7-answers.tex` 10-12). Thm 10 has no search. Thm 11(b) has a payload that is a function of the context, while the block of Thm 10 depends on the input bits of the explanation. No sentence claims the combination, so this is a gap and not an error. It follows by the same proofs if the searcher prints the block of Thm 10 for the explanation it found; the factor is then the probability that this explanation fits into the block.

**README numbers.** All match `profiles.json` and the tables: 20.5%; 29.4% against 45.7%; 15 or 16 bits; four and six commands; 0.27 to 0.42 for 7 to 11 commands (0.273, 0.416); 79.1% to 54.4% and 29.4% to 14.1%; the nine-command stream whose true 15th bit has probability 0.

---

## (E) Computation and numbers

**No problem found.**

- `python3 test_bf8.py` prints `ok`. A rebuild of `bf8enum.c` has the same md5 as the committed binary.
- A fresh run at 10 commands, `T(k) = 24k`: 855,587,944 branches and 839,072 strings, matching "`8.6e8`" and "`8.4e5`". No string violates `xi(x0) + xi(x1) <= xi(x)`.
- Every profile entry of the JSON for `T(k) = 24k` and `3k` (4 streams, 48 positions, three shares) equals my recomputation from the fresh runs.
- Table 1: all 36 cells match. Table 3: all 16 cells match. Table 2: all 25 cells match the JSON, and I reproduced the JSON rows for 4 to 11 commands with the binary, including the 11-command row.
- Text of Section 6: `0.00554` (`2974919/2^29`) and 70% (0.705); `0.00682` (`57181/2^23`) and 57% (0.573); 0.205 and 0.037; "below 0.01 from position 10 on except at 15-17 and 31" (0.016, 0.209, 0.023, 0.037); 0.294, 0.457, 0.249 and 0.392; 0.273 to 0.416; 0.080, 0.105, 0.054; 0.022 to 0.038; median 0.0014; the three falls and the one rise under `3k`; `1593 * 2^-25`, `2^-26`, 0 and `2^-26` in the nine-command example. All match.
- "By no shorter one." With at most 3 commands, 63 strings have positive mass and none is longer than 16 bits, under `T(k) = 24k` and under `T(k) = 20000k`. So no program of at most 3 commands prints `1^48`, and exactly `2 * 8^-3` of mass is on `1^15 0` and on the first 16 alternating bits. With at most 5 commands no alternating prefix longer than 17 bits has mass, under `24k` and under `2000k`. With 4 commands `1^48` has mass `3/1024` (12 programs), and with 6 commands the alternating stream has `17/131072` (34 programs).

Three remarks, none of them an error.

- The JSON has rows for 4 to 11 commands. The claim "by no shorter one" for `1^48` rests on a 3-command run that is not in it. Add that row.
- "Printed forever" is by inspection of `+[:]` and `++[:.]`. The JSON shows 48 bits on schedule.
- `experiments/run_profiles.py` line 11 says "about a minute"; the README says eight.

---

## (F) Minor points

1. Notation. `S` is the searcher (Thm 11), a set of locations (Thm 15(b)) and a number of steps (Section 4.4). `tau` is the length of a try (Section 3.4) and `tau_m(k)` the mass off the truth (Thm 14). `a` is a time bound (Section 3.2) and the length of a prefix (Section 1 item 3). `H`: see B5. `min(1/H, ...)` at `sec3-floor.tex` 190 has an undecorated `H`.
2. `sec3-floor.tex` 85-86: "The floor survives a time bound exactly when the schedule leaves room ...". Condition (2) is sufficient. The functions `a`, `eta`, `gamma` are upper bounds, so the wrapper can be on schedule when (2) fails. Write "when".
3. `sec3-floor.tex` 130: "all but `2^m`" should be "all but at most `2^m`".
4. `sec2-toy.tex` 102: "every world whose transcript passes the test hands over" needs "within the bounds", since Def. 5 requires `omega` in `E(x)`.
5. `sec4-limits.tex` 50-58: `X^i` is an infinite sequence, and it is described as the record "up to the moment the predictor's output is acted on". "Computing them does not involve running the predictor" holds only if the `m` record bits after the switch-on do not depend on the predictor's own computation. That is an assumption about the world; say so.
6. `sec4-limits.tex` 116: "any cell that changes when the predictor is switched on". Thm 15(d) needs a location whose record shows its first 1 at the step of the handover.
7. `sec4-limits.tex` 173-174: "which cost no more time than the honest reader" is an assumption about the stream family, not a consequence of the definitions.
8. `sec6-computation.tex` 15-16: of the two reasons given, only the first concerns Def. 3. The second ("one of its steps can read several commands") means that BF8 does not satisfy `r <= t` of Section 2. The results listed as holding for BF8 do not use `r <= t`.
9. Thm 14: "For all `n`" means `n >= 0`.
10. Condition (2) with `T°(k)` infinite, as in the unbounded case, needs `a(infinity,k) = infinity`. Section 2 now gives `gamma(infinity)` and the role of `r` when `t` is infinite, but not this.
11. One overfull line of 1.1pt remains (`sec3-floor.tex` 114-123). All cross-references in the PDF resolve to the right results.
