# Held-out suite 6 (`h6_00` ... `h6_11`): family statement

Sections 1-6 were written **before any target was drawn**. Section 7 (the drawn
targets and redraw counts) and section 8 (the verification output) were appended
after the single generation run.

The author of this suite did not see the learner's design, the study's
documents, results, or `study/boolfuncs.py`. The only inputs were the
pre-registered one-line description of the suite, the format example (the
three-target development suite) and the constraints in the request.

## 1. Conventions

* Inputs are `x` in {-1,+1}^30, uniformly random. A target outputs +1/-1. In
  every gate +1 means true. A **literal** is `x_j` or `-x_j`, where `-x_j`
  means NOT x_j.
* Each target uses columns `0..k-1` (named `x1..xk` in the descriptions,
  1-indexed), with 5 <= k <= 14. The fn reads no other column.
* A **signed block** of size m on columns C is a sign vector eps in {+-1}^m,
  with signed sum `s = sum_i eps_i x_{C_i}` and count `B = #{i : eps_i x_{C_i} = +1} = (s + m)/2`,
  so B is in {0..m}. **Signs:** with probability 1/2 all signs are +1 (a plain
  symmetric function); otherwise each sign is i.i.d. uniform.
* A **literal** in a gate draws its sign uniformly at random.

## 2. ACCEPT(m): the accept set of a block statistic

The function of a block is `g = [B in A]`. One of five types is chosen, each
with probability 1/5:

| type | rule | parameter draw |
|---|---|---|
| threshold | `[B >= t]` or `[B <= t]` (direction uniform) | for `>=`, t ~ U{1..m}; for `<=`, t ~ U{0..m-1} |
| centered band | `[abs(s) <= w]` or its complement `[abs(s) > w]` (uniform) | w ~ U over the achievable values of abs(s) below m: {m mod 2, m mod 2 + 2, ..., m-2} |
| interval | `[lo <= B <= hi]` | (lo, hi) uniform over all pairs 0 <= lo <= hi <= m except (0, m) |
| modular | `[B mod q == r]` or `[B mod q != r]` (uniform) | q ~ U{3,4}, r ~ U{0..q-1} |
| arbitrary | `[B in A]` | A uniform over all 2^(m+1) - 2 non-empty proper subsets of {0..m} (one integer drawn uniformly from 1..2^(m+1)-2; its bits give A) |

Every ACCEPT draw is non-constant by construction. A non-constant function of a
signed count depends on every variable of its block. MOD-2 (parity of the block)
is left out of the modular type because parities enter the family as the
separate mixing component (section 3, S2). The arbitrary type can still produce
parity, with probability 2/(2^(m+1)-2).

## 3. Strata: the 12 slots

The pre-registered description fixes the counts at 9 structured and 3 controls.
The suite is small, so the sub-families are **stratified**: each gets a fixed
number of slots. The order of the 12 slots, and so which name `h6_NN` gets which
stratum, is a uniformly random permutation drawn first.

**Structured slots (9).**

* **S1, pure symmetric / signed-sum, 3 slots.** `f = g(s)`, with m ~ U{5..14}
  and g = ACCEPT(m). k = m.
* **S2, symmetric XOR parity, 2 slots.** `f = g(s) * x_{m+1} * ... * x_{m+p}`,
  with p ~ U{1,2,3}, m ~ U{5..14-p} and g = ACCEPT(m). k = m + p.
* **S3, symmetric with a gate, 2 slots.** One of three forms, each with
  probability 1/3:
  * (a) `f = OP(g(s), h)`, with OP ~ U{AND, OR}. h is a gate on q ~ U{1,2} fresh
    variables: a literal if q = 1; if q = 2, AND or OR (uniform) of two
    literals. m ~ U{5..14-q}. k = m + q.
  * (b) `f = MAJ(g(s), l1, l2)`, with two fresh literals and m ~ U{5..12}.
    k = m + 2.
  * (c) multiplexer `f = l ? g1(s1) : g2(s2)` over two disjoint signed blocks,
    with m1, m2 ~ U{4..6} i.i.d., g1, g2 independent ACCEPT draws and one fresh
    selector literal l. k = m1 + m2 + 1.
* **S4, composite signed sums, 2 slots.** One of two forms, each with
  probability 1/2:
  * (a) **inner term:** `f = A(u)`, with `u = s + a*tau`. tau is a +-1 term on
    fresh variables: uniformly a literal, the product of two variables (a
    parity), or AND of two literals (as +-1). a ~ U{2,3} and m ~ U{5..14-r},
    where r is the number of tau variables (1 or 2). A(u) is a threshold or a
    centered band (each 1/2). For a threshold, the direction is uniform:
    `[u >= t]` with t uniform over the achievable u-values except the minimum,
    or `[u <= t]` with t uniform over those except the maximum. For a band,
    `[abs(u) <= w]` or `[abs(u) > w]` (uniform), with w uniform over the
    achievable values of abs(u) except the largest. k = m + r.
  * (b) **two sums:** `f = OP(g1(s1), g2(s2))`, with OP ~ U{XOR, AND, OR},
    m1, m2 ~ U{4..7} i.i.d. disjoint blocks, and g1, g2 independent ACCEPT
    draws. k = m1 + m2.

**Non-symmetric controls (3 slots, one of each type).**

* **C1, random read-once AND/OR formula.** k ~ U{5..10} variables, each used
  once. The tree is built recursively: a node with n >= 2 leaves splits them
  into a left part of size ~ U{1..n-1}. Each internal gate is AND or OR
  (uniform), and each leaf literal's sign is uniform.
* **C2, random DNF with overlapping terms.** k ~ U{5..10} and
  t ~ U{2..min(4, floor(k/2))} terms. The variables are randomly permuted and
  split into t private cores, each of size 2 plus a multinomial share of the
  remaining k - 2t variables (each goes to a uniform core). Each term is the
  AND of its core literals (uniform signs). With probability 1/2 a term also
  gets one extra literal on a variable drawn uniformly from outside its core,
  with a uniform sign.
* **C3, random decision list of 1- and 2-conjunctions.** k ~ U{5..10}. The
  variables are randomly permuted and cut into consecutive chunks, each of size
  ~ U{1,2} (the last chunk is truncated if needed). Rule j is "if AND(chunk-j
  literals) then o_j", with uniform literal signs and o_j ~ U{+-1}. The default
  output is -o_last.

**Relevance.** By construction every listed variable is relevant in every form
above: non-constant accept sets on disjoint blocks; read-once formulas;
decision lists whose default is -o_last; DNF cores of size >= 2 with at most one
extra literal per term, so no term absorbs another; inner-term thresholds and
bands with a >= 2. No draw is rejected for relevance, because none can fail it.
An exact relevance check is run afterwards as verification only.

## 4. Balance rule (the only rejection)

For each slot the stratum stays fixed. All of the slot's parameters are drawn,
including the form within S3 or S4. P(f = +1) is then computed **exactly** by
enumerating all 2^k assignments of the relevant variables. If
P(f = +1) is not in [0.25, 0.75], all of the slot's parameters are redrawn,
within the same stratum, from the same rng stream until the condition holds.
Nothing else is ever rejected. The number of redraws per slot is recorded.

## 5. Seed

`seed = 52817`. It was chosen once, before any generation, and is used for one
run only. The draw uses `np.random.default_rng(52817)` in this order: first the
slot permutation, then the slots in order (each with its own redraw loop). The
balance check is exact, so it uses no second rng.

## 6. Rationale

"Signed-sum / symmetric structure" is read as: Boolean functions of one or two
signed counts. ACCEPT spans the standard classes of symmetric functions:
threshold, exact or band (sym9 = `[abs(s) <= 1]` is a band), interval, MOD-q,
and an arbitrary symmetric function. Each block is also plain or randomly
signed with probability 1/2. The mixtures follow the pre-registered wording:
"with parities" is S2 (XOR with a parity of 1-3 other variables), and "with
gates" is S3 (AND/OR with a small gate, a majority gate, a multiplexer between
two sums). S4 covers the remaining natural reading of "signed-sum targets": sums
that contain a heavier-weighted parity, gate or literal term, in the style of
the development `thrsum`, and functions of two separate sums. All size ranges
are set only by the allowed 5-14 relevant variables and the forms' own
arithmetic; nothing was chosen with a learner in mind. The controls are three
standard random non-symmetric models (a read-once formula, a DNF, a decision
list) on 5-10 variables, comparable to the structured targets' typical size.
They face the same balance rule.

---

*Everything below was appended after the single generation run with seed 52817.*

**Pre-run code test.** Before the seeded run, the seven draw functions were
unit-tested with a separate rng, `default_rng(0)`, for crashes and for the
relevance claim in section 3. The test made 400 draws per stratum, checked each
variable's relevance exactly, and found 0 violations in 2800 draws. Acceptance
rates under the balance rule were S1 0.52, S2 1.00, S3 0.69, S4 0.46, C1 0.41,
C2 0.63 and C3 0.63. No test draw was used or selected. The family and seed
were not changed after the test.

**Post-run edit.** After the run, one description string was changed:
`3*-x13` became `3*(-x13)`. This consumes no rng and changes no target.

## 7. The 12 drawn targets

Notation: `[.]` is +1 if true and -1 if false. `*` is the product of +-1 values.
`XOR`, `AND`, `OR` and `MAJ` act on truth values. `-xj` means NOT xj, and
`c ? a : b` is a multiplexer. The format is
`name - stratum/form - k relevant (columns 0..k-1) - balance redraws - formula`.

* `h6_00` - S1 pure - k=13 - 0 redraws - `[((s+13)/2) mod 3 != 1], s = x1+x2+x3+x4+x5+x6+x7+x8-x9-x10-x11-x12+x13`
* `h6_01` - S1 pure - k=9 - 0 redraws - `[s in {-9,-7,-5,-1,1,7,9}], s = -x1+x2-x3+x4+x5+x6-x7-x8-x9`
* `h6_02` - S2 sym*parity (p=2) - k=11 - 0 redraws - `[1 <= s <= 5] * x10 * x11, s = x1+...+x9`
* `h6_03` - C2 DNF, t=3 - k=6 - 0 redraws - `OR(AND(-x4,x5), AND(-x2,-x6), AND(x1,-x3,x4))`
* `h6_04` - C1 read-once formula - k=5 - 0 redraws - `OR(-x1,AND(x2,AND(-x3,OR(x4,x5))))`
* `h6_05` - C3 decision list, 7 rules - k=8 - 0 redraws - `if -x6 -> +1; elif -x2 -> -1; elif x8 -> -1; elif -x4 -> -1; elif -x3 -> +1; elif x5 -> -1; elif AND(-x7,-x1) -> -1; else +1`
* `h6_06` - S2 sym*parity (p=2) - k=8 - 0 redraws - `[s in {-6,-2,0,6}] * x7 * x8, s = x1+...+x6`
* `h6_07` - S3c multiplexer - k=11 - 0 redraws - `-x11 ? [s1 in {-2,4}] : [s2 <= 0], s1 = x1-x2-x3-x4-x5-x6, s2 = x7+x8+x9-x10`
* `h6_08` - S3c multiplexer - k=11 - 1 redraw - `x11 ? [|s1| <= 2] : [((s2+6)/2) mod 3 == 0], s1 = x1+...+x4, s2 = -x5-x6+x7-x8+x9-x10`
* `h6_09` - S4b two sums, XOR - k=11 - 1 redraw - `XOR([-4 <= s1 <= 0], [3 <= s2 <= 5]), s1 = x1+...+x6, s2 = -x7-x8+x9-x10-x11`
* `h6_10` - S4a inner literal, a=3 - k=13 - 0 redraws - `[|u| > 1], u = s + 3*(-x13), s = x1+...+x12`
* `h6_11` - S1 pure - k=7 - 3 redraws - `[s == 1], s = x1+...+x7`

The balance rule needed **5 redraws** in total: 3 for `h6_11`, 1 for `h6_08`
and 1 for `h6_09`. There were none for the other 9 slots.

**What the draw happened to give** (descriptive, not a selection). Both S3
slots came out as the multiplexer form, and the majority and AND/OR-gate forms
were not drawn. S4 gave one two-sum XOR and one inner-literal sum. Across the
targets the accept-set types are: modular 2, arbitrary 3, interval 4 (one of
them the point `s == 1`), band 2 (counting `h6_10`'s band on u), threshold 1.
Six of the 12 blocks are randomly signed. The controls came out at k = 5, 6
and 8. `h6_11` (`[s == 1]` on 7 plain variables) resembles the development
target `sym7` (`|s| <= 1` on 7 variables, i.e. `s in {-1, 1}`). It is a
different function, and it was kept as drawn.

## 8. Verification output

The script (kept outside the repo) imports `suite.py` and builds the suite
twice. It compares both builds on 200000 random rows drawn from
`default_rng(2026)`, and checks that names, relevant lists and descriptions
match. It computes P(+1) exactly by enumerating 2^k inputs and also on the batch.
It checks exactly that every listed variable is relevant. It compares each fn
with an independent hand-coded re-implementation of its description. Finally,
it checks exhaustively whether any control is a function of a single signed sum
over its variables.

```
names identical across builds: True | n targets: 12
name   stratum  k P(+1) exact P(+1) batch redraws  build1==build2  fn==hand-coded  all-k-relevant
h6_00  S1   13      0.6666      0.6653       0            True            True            True
h6_01  S1    9      0.6016      0.6009       0            True            True            True
h6_02  S2   11      0.5000      0.5002       0            True            True            True
h6_03  C2    6      0.5312      0.5325       0            True            True            True
h6_04  C1    5      0.5938      0.5957       0            True            True            True
h6_05  C3    8      0.5430      0.5425       0            True            True            True
h6_06  S2    8      0.5000      0.5000       0            True            True            True
h6_07  S3   11      0.5078      0.5079       0            True            True            True
h6_08  S3   11      0.6094      0.6102       1            True            True            True
h6_09  S4   11      0.5879      0.5904       1            True            True            True
h6_10  S4   13      0.6858      0.6855       0            True            True            True
h6_11  S1    7      0.2734      0.2749       3            True            True            True
total balance redraws: 5
h6_03 (C2): function of one signed sum? False
h6_04 (C1): function of one signed sum? False
h6_05 (C3): function of one signed sum? False
```

Usage: `from suite import make_dl_heldout6_suite; S = make_dl_heldout6_suite()`.
This returns 12 entries, `h6_00` ... `h6_11`, each with `fn`, `relevant` and
`desc`. `heldout6_draw_log()` returns the stratum, k, exact balance and redraw
count for each target.
