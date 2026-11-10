# Referee report 3 on "A toy malign-prior question with an answer": Theorem 11 (searching) and its surroundings

Date: 2026-11-10. Version refereed: `paper/` and `README.md` as committed in "add the three-command row to the results file" (`d5af5226`), with `main.pdf` built at 12:13 UTC. I had not seen the note before.

**Scope.** Section 3.4 of the PDF: Theorem 11 (a), (b), (c) with its proof, the paragraph and the four bullets after it, and Remark 12. Also the four summaries of this theorem: the abstract, Section 1 item 3, Section 7, and the README. Sections 2 and 3.1 to 3.3 were read for the definitions and for the fixed point of Theorem 10. Numbering is that of the PDF. `e(j)` is the code written with a bar in the paper. Line numbers refer to the source files.

**Method.** Pencil and paper. I wrote and ran no programs, and changed no file except this report.

**Bottom line.**

1. Theorem 11 (a), (b) and (c) are correct as stated, constants included. This covers part (c), which no referee had seen. The proof of (b) leaves two points of the machine `R` unspecified; with the reading the proof needs, it is complete (B3).
2. Two sentences in the bullets after the theorem are wrong as written.
   - The test "the transcript begins with w" is "as rare as its description is long" only for some `w`. For `w = 0^n` both the premise and the conclusion of the conditional fail (B1).
   - "Where first hits can be generated directly, as for a fixed prefix or a fixed length, no search is needed" is right for a fixed prefix. For a fixed length, direct generation gives only the average of (a), which the third bullet says is not the point (B2).
3. Remark 12: the three items are correct.
4. No summary contradicts the theorem. They are loose in these places (section C): the abstract omits "without resource bounds", compares with "the wrapper" where a wrapper of the same length is meant, and says "gets more" where "more than `2^(-a)/H`" is proved; the abstract, Section 1 and the README write `2^(-c)` for a constant that is not the wrapper's `c`; Section 7 describes `c_1`, `c_2` one and two bits too small and says the share "does not depend on how rare handovers are"; the README repeats the exception of B2.

---

## (A) Verdicts

Overview. Details follow.

| Item | Verdict |
|---|---|
| Theorem 11(a), identity, inequality, "in particular" | CORRECT AS STATED |
| Theorem 11(b), statement | CORRECT AS STATED |
| Theorem 11(b), proof | CORRECT BUT GAP: reading rule and the set `D` (B3) |
| Theorem 11(c), statement and proof | CORRECT AS STATED, given B3 |
| Paragraph after the theorem | CORRECT, one sentence with a missing qualifier (B4) |
| Bullet 1, "on the prior it is no excess" | CORRECT AS STATED |
| Bullet 2, inequality, conditional, marker anywhere | CORRECT AS STATED |
| Bullet 2, the example "begins with w" | WRONG for general `w` (B1) |
| Bullet 3, "the average alone would not show it" | CORRECT AS STATED |
| Bullet 4, start-up of `R`, the search by tries | CORRECT; the count of tries is a heuristic (D5) |
| Bullet 4, last sentence | CORRECT for a fixed prefix, WRONG as reasoned for a fixed length (B2) |
| Remark 12, items 1, 2, 3 | CORRECT AS STATED |

### Theorem 11

**A1. Text before the theorem** (`sec3-floor.tex` 139-147). CORRECT AS STATED. First hits are pairwise incomparable, so the events "`x` is a prefix of `out_U(omega)`" are disjoint, and an output has a prefix in `G` exactly when its shortest such prefix, which is a first hit, is a prefix. Since `U` is universal, `M_U(x) >= 2^(-|v0|-|x|) > 0` for every `x`, with `v0` a prefix word of the copying machine. So `sh_v(x)` is defined at every first hit, and `H_G > 0` only says that `G` is not empty.

**A2. (a), identity and inequality.** CORRECT AS STATED. `M_U(x) sh_v(x) = 2^(-|v|) lambda{omega : x is a prefix of out_U(v omega)}`. Over first hits these events are disjoint, and their union is the event that `out_U(v omega)` has a prefix in `G`.

**A3. (a), "In particular no word v has `sh_v(x) > 2^(-|v|)/H_G` at every first hit".** CORRECT AS STATED. The weights `M_U(x)/H_G` are positive and sum to 1, so a strict inequality at every first hit would be a strict inequality for the average. First hits with `M_U(x) = 0` do not exist for a universal `U` (A1). For a machine that is not universal the sentence is still true if the terms with `M_U(x) = 0` are read as `lambda{v omega : x is a prefix of out_U(v omega)}/H_G = 0` and "every first hit" as "every first hit with `M_U(x) > 0`"; at a first hit of mass 0, `sh_v` is 0/0.

**A4. (b), the handing-over programs.** CORRECT AS STATED.
- *Well defined.* If the output of `omega` has a first hit `x`, then `p(omega) = omega_{1:r}` with `r = r_U(omega,|x|)` is a handing-over program, because what happens up to step `t_U(omega,|x|)` depends only on these bits (Section 2).
- *Prefix-free.* If `p` were a proper prefix of `p'`, an input beginning with `p'` would have `x_p` and `x_p'` as prefixes of its output; two first hits that are comparable are equal; and this one hit would be complete after exactly `|p|` and after exactly `|p'|` bits.
- *Enumerable.* Run `U` on `p` with reads beyond `p` blocked, test every output prefix for membership in `G`, and accept if at the first member exactly `|p|` bits have been read.
- *Weights.* The cylinders `[p]` partition `{omega : out_U(omega) has a prefix in G}`, and those with `x_p = x` partition `{omega : x is a prefix of out_U(omega)}`.

**A5. (b), the intervals.** CORRECT AS STATED. Their total length is `2^(j-1) H_G <= 1`, and their end points `a_1 < a_2 < ...` are dyadic rationals that `R` can compute.

**A6. (b), the reading rule, "every omega in the interior of `I_i` ends in this way", and whether `R` is a well-defined monotone machine.** CORRECT BUT GAP (B3). Read the rule as "reads the next bit exactly when", and let `D_n = [0.omega_{1:n}, 0.omega_{1:n} + 2^(-n))`, half-open. Let `omega` be in the interior of `I_i = [a,b)` and `n_1` the least `n` with `D_n` inside `I_i`.
- For `n < n_1`: `D_n = [l,u)` contains `omega` and is not inside `I_i`, so `l < a` or `u > b`. In the first case `a` lies in `(l,u)`, in the second `b` does. So an end point of `I_i` lies in the interior of `D_n`, and the next bit is read once `I_i` is assigned at the latest. `D_n` meets `I_i`, so it lies in no other interval and `R` does not stop early.
- For `n = n_1`: the interior of `D_n` lies in the interior of `I_i`, which contains no end point of any interval, assigned or not. So no further bit is read at any stage of the enumeration, and `R` stops once `I_i` has been assigned.
- Hence `R` reads exactly `n_1` bits, whatever the interleaving of enumeration and reading. There is no deadlock on the interiors of the intervals.
- `R` reads no bit it should not: if an end point lies in the interior of `D`, then `D` lies in no interval, since no interval has an end point in its interior.
- Off the intervals `R` prints nothing. At the accumulation point of the end points it may read forever. Both are harmless.

**A7. (b), the probability `2^(j-1) M_U(x)` and the displayed inequality.** CORRECT AS STATED. The probability is exact: off the intervals `R` prints nothing, and on `I_l` it prints `x_{p_l} P(x_{p_l})`, which has the first hit `x` as a prefix only if `x = x_{p_l}`. So the programs `v e(j) omega` have share exactly `2^(-|v|-|e(j)|) 2^(j-1)` at every first hit. The prose after the theorem uses this exact value, which the theorem does not state. `v` does not depend on `j`.

**A8. (b), last claim.** CORRECT AS STATED. With `j = floor(log2(1/H_G)) + 1`: `j >= 1`; `2^(j-1) <= 1/H_G`; and `2^(j-1) > 1/(2 H_G)` because `floor(t) > t - 1`.

**A9. (c), the fixed point.** CORRECT AS STATED. Let `W'` read `e(u)`, set `s = u e(u)`, and then run `R_s` on the rest; let `w` be a prefix word of `W'` and `q = w e(w)`. Then `out_U(q e(j) omega) = out_W'(e(w) e(j) omega) = out_{R_q}(e(j) omega)`. `R_q` has read `e(j)` and can print it again, so what it prints after `x` is the part of `U`'s input consumed so far, `q e(j) omega_{1:r}`, followed by `1 0^infinity`. The analogy with Theorem 10 is sound. `q` does not depend on `j`, because `j` is part of the input that `R_s` reads and not of the machine `W'`.

**A10. (c), "r is the least number ...; it is the same for omega and omega'".** CORRECT AS STATED, given B3. Minimality is A6. For `omega'` less is needed: `R_q` never reads beyond `e(j) omega_{1:r}`, so every input beginning with `q e(j) omega_{1:r}` gives the same output. (`omega'` is the midpoint of `D_r`, an interior point of `I_i`.) Minimality of `r` is what the measure estimate uses.

**A11. (c), the block is in `SR_m(x)`.** CORRECT AS STATED. `y 0^infinity = q e(j) omega'`, and `out_U(q e(j) omega') = x q e(j) omega_{1:r} 1 0^infinity = x y 0^infinity`.

**A12. (c), the measure estimate.** CORRECT AS STATED. `r(omega) <= r_0` exactly when `D_{r_0}(omega)` is inside `I_i`. The dyadic intervals of length `2^(-r_0)` that meet `I_i = [a,b)` without lying in it are the one containing `a` (if `a` is not its left end) and the one containing `b` in its interior: at most two. And `2^(1-r_0) <= |I_i|/2 = 2^(j-2-|p_i|)` exactly when `|p_i| <= r_0 + j - 3`.

**A13. (c), the mass bound, `rho*`, the hypothesis on `m`, the last sentence.** CORRECT AS STATED.
- `r <= r_0 = m-1-|q|-|e(j)|` is the condition `|q|+|e(j)|+r+1 <= m`.
- The mass is `2^(-|q|-|e(j)|) * (1/2) * 2^(j-1) * sum{2^(-|p_i|) : x_{p_i} = x, |p_i| <= r_0+j-3}`. Here `r_0+j-3 = m-4-|q|-|e(j)|+j`, and the sum is `rho*(x) M_U(x)` by A4. This matches the statement.
- The step from this mass to the share of the blocks is the comparison of Theorem 10: the programs counted lie in the union over `y` in `SR_m(x)` of the sets of inputs that print `xy`, which are disjoint. The proof leaves it to the reader; one clause would say it.
- Last sentence: `2^j > 1/H_G`.
- The hypothesis `m >= |q|+|e(j)|+2` is not needed for the truth of the statement, and at equality the statement is empty (D2).

**A14. Are distinct inputs mapped to distinct blocks where the argument needs it?** Not needed. The bound is on the measure of a set of inputs of `U`, each of which prints `x` and then some block of `SR_m(x)`. Two inputs with the same block lie in the same set and are both counted by `lambda`. (The map from stopped prefixes `omega_{1:r}` to blocks is injective, because of the final 1, but nothing uses it.)

### Paragraph after the theorem (`sec3-floor.tex` 201-212)

- **"The twin of Theorem 9 has share exactly `2^(-c)` at every first hit: its output passes the test only with probability `H_G`"** (201-202). TRUE, asserted. It does not follow from Theorem 11. It follows from (1): for a first hit `x` the twin prints `x` exactly when `U` does, as the proof of Theorem 16(i) notes. The clause after the colon gives, through (a), only the average.
- **"The machine of (b) enumerates ... in proportion to their prior weight"** (202-203). TRUE, a description of the proof.
- **"Its share is larger by the factor `2^(j-1) > 1/(2H_G)` at every handover"** (203-204). CORRECT BUT GAP (B4). Follows from A7 for `j = floor(log2(1/H_G)) + 1`; the comparison is with a twin whose prefix word has the same length.
- **"By (a) no family ... exceeds `2^(-|v|-|e(j)|)/H_G` at every handover"** (204-205). CORRECT AS STATED, follows from (a).
- **"Repaid the `log2(1/H_G)` bits ..., up to one bit and the `|e(j)| <= 2 log2 j + 3` bits"** (205-208). CORRECT AS STATED, follows: `j - 1` lies in `(log2(1/H_G) - 1, log2(1/H_G)]`, and `|e(j)| = 2 floor(log2 j) + 3` with the code of Section 4.2 (D1).
- **"Part (c) ... at least `2^(-c') rho*(x)/H_G`, with `c' = |q|+|e(j)|+2`"** (208-210). CORRECT AS STATED, restates (c).
- **"The block can hold explanations that much longer"** (210-211). CORRECT as "about". It follows from the threshold of `rho*`, `m-4-|q|-|e(j)|+j`, against `m-1-c` in Theorem 10. The threshold never exceeds `m-3` (D3).

### The four bullets

**Bullet 1** (214-217). CORRECT AS STATED for `j = floor(log2(1/H_G)) + 1`; for other admissible `j` the fraction `2^(j-1) H_G` need not exceed 1/2. All three sentences follow from A7. "In accordance with Theorem 8" is a gloss and a fair one.

**Bullet 2** (218-225).
- `H_G > 2^(-|v|-|e(j)|-1)`: CORRECT AS STATED, follows from (b) and "a share is at most 1".
- "The word `v` contains a description of `G`": asserted, informal, unobjectionable.
- The conditional: CORRECT AS STATED as arithmetic, with "built from" meaning `|v| <= d_G + d_P + O(1)`. Then `2^(-|v|-|e(j)|-1)/H_G >= 2^(-d_P-|e(j)|-O(1))`. "However rare handovers are" is right only because `|e(j)|` stands in the bound; the bound still falls like `(log(1/H_G))^(-2)`.
- The example "the transcript begins with w": `H_G = M_U(w)` is correct. As an example of the premise it is WRONG for general `w` and right for self-delimiting markers (B1).
- "No search is needed: print w": CORRECT.
- A marker anywhere: CORRECT, asserted with its one-line proof.

**Bullet 3** (226-228). CORRECT AS STATED. Equality in (a) holds exactly when almost every program `v omega` hands over. A word that prints one first hit `x_0` has `sh_v(x_0) = 2^(-|v|)/M_U(x_0)`, share 0 elsewhere, and average `2^(-|v|)/H_G`.

**Bullet 4** (229-240).
- The start-up of `R` and "a tight schedule gives it no mass": CORRECT, qualitative. Precisely: a program whose point falls in `I_i` prints its first bit only after the enumeration has run `U` on `p_i` until `x_{p_i}` is complete.
- `g M^(t0)(x)` and the lower bound on `g`: CORRECT, asserted. Derivation: each try uses a fresh stretch of coin flips ended by a stopping rule, so the tries are independent; the probability is `sum_{i<=k} (1-H)^(i-1) M^(t0)(x)`; and `1-(1-H)^k >= 1-e^(-kH) >= (1-1/e) min(kH,1)`.
- "A run that succeeds at its i-th try has spent the time of i-1 failed tries before its first bit and has read their bits": CORRECT.
- "About `T(1)/t_0` of them under the schedule, and the gain is `g` with `k` replaced by their number": asserted, a heuristic, acceptable as "about" (D5).
- Last sentence: CORRECT for a fixed prefix; WRONG as reasoned for a fixed length (B2).

### Remark 12 (`sec3-floor.tex` 243-265)

- **Item 1.** CORRECT AS STATED. The twin's programs `v omega` with `omega` handing over at `x` print `x P(x)`; their mass is `2^(-c) C(x)`, which is `2^(-c) kappa(x)` of `M_U(x)`. "At least", because other programs of the twin may print `x` too.
- **Item 2.** CORRECT AS STATED. `sh_s(x) >= 2^(-|s|) Q(x)/M_U(x)`; it is an inequality because a program that prints a longer context also prints `x`. Averaging with the weights `C(x)/H_C` gives `2^(-|s|) sum_x Q(x) kappa(x) / H_C`.
- **Item 3.** CORRECT AS STATED, by the definitions; the sets are disjoint over `d`.
- The two closing sentences describe these quantities correctly. Two remarks on wording are in D6.

---

## (B) Errors and gaps

### B1. The test "the transcript begins with w" is as rare as its description is long only for some w

**Where.** `sec3-floor.tex` 222-223.

**What is wrong.** For this test `H_G = M_U(w)`. The premise `H_G <= 2^(-d_G+O(1))` asks for `d_G <= log2(1/M_U(w)) + O(1)`. A description of the test from which the search machine is built yields `w`, so `d_G >= K(w) - O(1)`. `K(w)` can exceed `log2(1/M_U(w))` by about `K(|w|)`: a program for `U` need not say where `w` ends, and a description of the test must.

- *`w = 0^n`.* `M_U(0^n) >= 2^(-c_0)` for all `n`, with `c_0` the length of a program that prints zeros forever. So this test is not rare, while `d_G >= K(n) - O(1)`. The conclusion fails together with the premise. Here `j <= c_0 + 1`, so the bullet's bound would be `2^(-d_P-O(1))`. But for the payload `1 0^infinity` the share at `0^n` is at most `M_U(0^n 1)/M_U(0^n) <= 2^(-K(n)+O(1))`: the strings `0^n 1` are pairwise incomparable, so `sum_n M_U(0^n 1) <= 1`, and the coding theorem applies.
- *A typical `w` of length `n`.* `log2(1/M_U(w)) <= n + O(1)` by the copying machine, and `K(w) >= n + K(n) - O(1)`. The premise fails by `K(n)` bits.

**What is right.** If `w` ranges over a fixed decidable prefix-free set (a self-delimiting marker, for instance `w = e(u)`), then `M_U` restricted to that set is a lower semicomputable semimeasure and the coding theorem gives `K(w) <= log2(1/M_U(w)) + O(1)`. With a shortest description the premise holds. For arbitrary `w`, `K(w) <= log2(1/M_U(w)) + K(|w|) + O(1)`, and "print w, then the payload" has share at least `2^(-d_P-K(|w|)-O(1))`.

**Fix.** "An example is the test 'the transcript begins with w' for `w` from a fixed prefix-free set of markers, for which `H_G = M_U(w) <= 2^(-K(w)+O(1))` (and no search is needed: print `w`). For arbitrary `w` the premise can fail by the `K(|w|)` bits that say where `w` ends; `w = 0^n` is not rare at all."

### B2. "Where first hits can be generated directly, as for a fixed prefix or a fixed length, no search is needed"

**Where.** `sec3-floor.tex` 239-240. The same exception is in `sec4-limits.tex` 175-176 and `README.md` 17.

**What is wrong.** A machine that generates first hits attains the average of (a). The third bullet says that the average is not the content of the theorem. Such a machine has the gain at every handover only if it prints each first hit `x` with probability at least a constant times `M_U(x)/H_G`.

- *Fixed prefix.* There is one first hit, so the average is the pointwise statement. Correct.
- *Fixed length `n`.* The direct generator copies `n` input bits and then prints the payload. With prefix word `v` its share at `x` is `2^(-|v|-n)/M_U(x)`. At `x = 0^n` this is at most `2^(-|v|-n+c_0)`. A twin of the same length has `2^(-|v|)` there, and the searcher of (b) has `2^(j-1)` times that. So the generator is below the twin by the factor `2^(c_0-n)`.

What is true for a fixed length is something else: `H_G >= 2^(-c_0)`, so there are at most `c_0` bits to collect, and the twin itself is within the factor `2^(c_0)` of the bound of (a). This is the situation of the marker anywhere in the second bullet.

**Fix.** In Section 3.4: "Where there is a single first hit, as for a fixed prefix, no search is needed: print it. A generator of first hits whose probabilities are not proportional to their prior weights attains only the average of (a)." In Section 4.4 and the README: "except where there is only one handover point, or handover points can be generated in proportion to their prior weight".

### B3. The machine R: two points the proof of (b) leaves open

**Where.** `sec3-floor.tex` 179-183.

- **"Reads a further bit only when."** This says when `R` may read. The next sentence, "every omega in the interior of `I_i` ends in this way", needs that it does read then. A machine that never reads satisfies the rule as written.
- **The set `D`.** "The set of points that begin with the bits read so far" has to be the half-open interval `[0.omega_{1:n}, 0.omega_{1:n} + 2^(-n))`. Inputs are sequences, and the image of a cylinder is the closed interval. With closed `D` the machine hangs on a part of positive measure of every interval. Let `[b - 2^(-n), b)` be the last piece of the dyadic decomposition of `I_i = [a,b)`. For `omega` in that piece the closed `D` contains `b`, so it is not inside `I_i`, and its interior contains no end point: `R` neither stops nor reads. The simplest instance is `I_1 = [0,1/2)` and an input that begins with 0, where `D = [0,1/2]`.

With both settled, the claims of (b) and (c) hold; the argument is A6. It also shows that the number of bits read does not depend on how enumeration and reading are interleaved, which the measure estimate of (c) needs.

**Fix.** "Let `D` be the half-open dyadic interval of the bits read so far. Between steps of the enumeration: if `D` lies in an assigned `I_i`, the machine stops reading and prints `x_{p_i}` and `P(x_{p_i})`; otherwise, if an end point of an assigned interval lies in the interior of `D`, it reads one more bit; otherwise it reads nothing. For `omega` in the interior of `I_i`, the machine reads exactly `r` bits, where `r` is least with `D` inside `I_i`: before that an end point of `I_i` lies in the interior of `D`, and from then on no end point does."

### B4. "Its share is larger by the factor `2^(j-1)`": larger than what

**Where.** `sec3-floor.tex` 203-204. The abstract has the same comparison (C1).

**What is missing.** The sentence follows one about the twin of Theorem 9, whose share is `2^(-c)`. The searcher's share is `2^(-|v|-|e(j)|) 2^(j-1)`, and `|v|+|e(j)|` is not `c`: `R` has to decide `G`, compute `P`, and enumerate the programs of `U`. The factor is over a twin whose prefix word has the same length, as Section 1 and the README say. Against the twin of Theorem 9 the ratio is `2^(j-1-(|v|+|e(j)|-c))`, and nothing is proved about its size.

**Fix.** "The programs `v e(j) omega` have share exactly `2^(-|v|-|e(j)|) 2^(j-1)` at every first hit, since `R` prints nothing off the intervals. This is larger than the share of a twin with a prefix word of the same length by the factor `2^(j-1)`, which for `j = floor(log2(1/H_G)) + 1` is more than `1/(2H_G)`."

---

## (C) Summaries

**C1. Abstract, second bullet** (`main.tex` 51-56). It says more than (a), (b), (c) in four respects.
- *No "without resource bounds".* Theorem 11 is for unbounded resources only. The first bullet of the abstract separates the two cases; this one does not, and its last sentence excludes only a tight schedule.
- *"About `1/H` times the wrapper's share."* Proved: a factor in `(1/(2H), 1/H]` over a wrapper of the same length (B4).
- *"About `2^(-c)/H` times the share of explanations that fit into a block."* In the abstract `c` is "the length of the wrapper". The constant of (c) is `|q|+|e(j)|+2` for a different and longer program, and it grows with `1/H` like `2 log2 log2(1/H)`. "About" stands for "at least".
- *"No family of programs with a common prefix of the same length gets more at every handover."* (a) says: not more than `2^(-a)/H`. The searcher has `2^(-a) 2^(j-1)`, which can be below that by a factor up to 2, so "more than this hypothesis" is not what is proved. The other three summaries state the bound itself.
- *Fix.* "Without resource bounds, a hypothesis that enumerates the programs that hand over and spreads its mass over them in proportion to their prior weight gets, at every recognisable handover, more than `1/(2H)` times the share of a wrapper of the same length, where `H` is the prior probability of a handover; if it then supplies its own code, it gets at least `2^(-c')/H` times a share of the explanations that fit into a block, with `c'` its own length. No family of programs with a common prefix of length `a` gets more than `2^(-a)/H` at every handover."

**C2. Section 1, item 3** (`sec1-intro.tex` 34-40). Says what (a), (b), (c) prove, with "without resource bounds", "at every first hit", "a wrapper of the same length", "more than `1/(2H)`" and "`2^(-a)/H`". One point: in "`2^(-c)/H`" the letter `c` is the constant of item 2, the wrapper's. Write `c'`, the length of this hypothesis plus two bits.

**C3. Section 7, bullet "Looking"** (`sec7-answers.tex` 19-27). Says what is proved, with "without resource bounds"; "at every handover" is "at every first hit" by the sentence before the bullets. Two points.
- *`c_1`, `c_2`.* They are `|v|+|e(j)|+1` and `|q|+|e(j)|+2`. The text gives "the lengths of the two programs plus the few bits that name `floor(log2(1/H))`", which omits one and two bits. With `c_1 = |v|+|e(j)|` the claim "more than `2^(-c_1)/H`" is not proved: the searcher's own programs have at most that.
- *"The share does not depend on how rare handovers are."* The bound is `2^(-d_P-|e(j)|-O(1))`, and `|e(j)|` is about `2 log2 log2(1/H)`. Section 3.4 has the term. Write "depends on how rare handovers are only through the bits that name `j`".

**C4. Section 7, the paragraph after the bullets** (`sec7-answers.tex` 29-46). The sentences on Theorem 11 are correct: no mass under a tight schedule (bullet 4); "a search by a bounded number of tries collects the base rate only up to the number of tries that fit" (from `g <= min(k, 1/H^(t0))`, with the caveat of D5); "the searching programs are exactly their own fraction of the worlds that hand over" (bullet 1); "the bound `2^(-a)/H`" and "none of the three is an upper bound at a given handover".

**C5. README, bullet "Looking for opportunities ..."** (`README.md` 17). Says what is proved, with "without resource bounds", "at every handover the test recognises", "a wrapper of the same length", "more than 1/(2H)" and "`2^(-a)/H`". Two points: "`2^(-c)/H`" as in C2 (in the README's first bullet `c` is the wrapper's length); and "except where handover points can be generated directly" (B2).

**C6. "The share of explanations that fit into a block", in all four.** `rho*(x)` is the share of explanations of at most `m-4-|q|-|e(j)|+j` bits. This threshold is at most `m-3` (D3), so all of them do fit into a block, and "a share of explanations that fit into a block" (Section 7) is exact. "The share of explanations that fit into a block" (abstract, Section 1, README) says more if read as "all explanations of at most `m` bits". Since `rho*` is the one new quantity of (c), one of the summaries could give the threshold.

---

## (D) Minor points

1. **`e(j)` for a number.** Theorem 11 and the text after it use `e(j)` and `|e(j)| <= 2 log2 j + 3` for a number `j`. The code is defined for strings in the proof of Theorem 10 and for numbers only in Section 4.2. Define it at first use.
2. **The hypothesis `m >= |q|+|e(j)|+2` in (c).** Every handing-over program has at least `j-1` bits, since `2^(-|p|) <= H_G <= 2^(-(j-1))`. At `m = |q|+|e(j)|+2` the threshold of `rho*` is `j-2`, so `rho* = 0` and the statement is empty. For smaller `m` it is empty for the same reason. So the statement is true for every `m` and has content from `m = |q|+|e(j)|+3` on.
3. **A consistency check that could be stated.** The programs `q e(j) omega` that hand over have mass `2^(-|q|-|e(j)|) 2^(j-1) H_G <= H_G`, so `j-1 <= |q|+|e(j)|`. Hence the threshold of `rho*` is at most `m-3`; `rho*(x) > 0` at fewer than `2^(m-2)` first hits; and the bound of (c) is at most `rho*/2`. "At every handover" for (c) means that the inequality holds everywhere; it is nontrivial at fewer than `2^(m-2)` contexts. The note makes this caveat for Theorem 10 and could repeat it here.
4. **Second bullet, a shorter and stronger bound on `H_G`.** The machine that prints the first element of `G` in length-lexicographic order hands over with probability 1, because a shortest element of `G` is a first hit. So `H_G >= 2^(-d_G-O(1))`, without `e(j)` and without the payload. This is what the bullet's title says ("bounded by the cost of the test"); the bullet's own inequality bounds the repayment by the cost of the search.
5. **Fourth bullet, the search by tries.** `g` multiplies `M^(t0)(x)`, not `M_U(x)`: it is the gain over a single try, that is over a twin restricted to worlds that complete the first hit within `t_0` steps. Under a schedule every try, the successful one included, must end before the first bit is due. So `t_0` is at most about `T(1)`, and the search has mass only at first hits that some world completes within about `T(1)` steps. "About `T(1)/t_0`" assumes that a failed try runs its full `t_0` steps.
6. **Remark 12.** "The proofs above give" fits item 1. Item 2 is the computation of (a), run as an inequality, and item 3 is a definition. Item 1 needs the rule to be decided at a finite stage of the simulation, which the example satisfies.
7. **Which `j`.** From "`2^(j-1) > 1/(2H_G)`" on, the paragraph and the bullets mean `j = floor(log2(1/H_G)) + 1`. Say so once.

**Not checked.** Any resource-bounded version of Theorem 11 (none is claimed), and Sections 4 to 6 beyond the sentences of Section 4.4 quoted above.
