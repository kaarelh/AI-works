# Ultranatural functions

A research note on a question from Kaarel Hänni about Solomonoff operator induction (SOI), the subject of [`../solomonoff-operator-induction/`](../solomonoff-operator-induction/).

* **The question.** When we learn a function from input–output pairs, many natural properties P(x,y) may have held of every pair so far and together leave one choice of y at a new x. Can a function be pinned down in this way, by many properties at once, more strongly than SOI pins it down? Could successor or addition be "ultranatural"? Or does a contrived universal machine spoil any such notion?
* **The first note:** [`note.md`](note.md), on properties of input–output pairs, with definitions, theorems, proofs and an experiment.
* **The second note:** [`equational.md`](equational.md), on properties of the whole function: an inductor whose hypotheses are sets of universally quantified equations in the vocabulary {0, S, f}.
* **Author:** Claude (Anthropic), in response to the question and under Hänni's direction.
* **Status:** a draft. One independent AI referee checked every statement and re-implemented the experiment ([`verification/`](verification/)): no error in a numbered statement, four overclaims in the summary and in how the experiment was reported, since corrected. The second note was checked by one independent AI referee in the same way (no error in the main theorems; one proposition corrected, two counts in the computations corrected, and a new result on doubling added by the referee); a second pass on the changes is pending. No human has checked the mathematics.

## Answers in brief: the first note

1. **The idea formalises cleanly, and in its machine-independent form it is what SOI already does.** For a target f, the properties of complexity at most k that are true of all pairs so far leave exactly the label f(x) for every k from K(f) up to about the separation complexity sep(x; A), the complexity of the simplest test that tells x apart from the inputs seen so far. Above sep(x; A) they leave no label. Up to K(f) + O(1) bits this window is SOI's own margin at x.
2. **The number of properties a wrong label breaks does not matter.** One guard, "if the input is like x, do something else", breaks all of them at once for about sep(x; A) bits. For simple f the cheapest property that the *right* label breaks is essentially "no input like x occurs", at the same price. A tally of broken properties agrees with SOI at typical new inputs, and at inputs that are very cheap to separate from the data it is dominated by guard properties that were never tested.
3. **The worry about contrived machines is right, and it applies to every scheme whose inductive bias comes from the reference machine alone.** For any such scheme, any new input x and binary labels, a universal machine sep(x; A) + O(1) bits away gives the opposite answer at x and is indistinguishable from the original elsewhere. SOI's Kolmogorov version is stable under machine changes of up to half its margin at x, and no further. Whether some scheme is stable beyond half of sep(x; A) is open.
4. **"On most new inputs" holds for SOI itself.** After n independent samples, a change of machine by a bits can change the prediction only on a set of inputs of measure about 2^(2a+K(f))·(a + K(f))/n. Inputs of a new kind are all fragile together.
5. **Stronger pinning has a price.** Pinning f(x) with s bits means paying s bits if the exception is real. A universal learner can exceed SOI's pinning by at most a constant plus the loss SOI has already paid on the data, at most K(f) bits, which amounts to a choice of machine.
6. **Where the intuition is right.** Hypotheses that disagree with f on a fraction δ of inputs are killed by n data points at rate (1−δ)ⁿ. Laws such as linearity or the recursion equations of addition make every lawful alternative of this kind, and against them many constraints do add up exponentially. SOI's residual doubt, of order 1/n, is entirely small patches of f.
7. **A notion that does not collapse.** f is *δ-isolated* (ultranatural at scale δ) if every other function that differs from f on less than a fraction δ of inputs is more complex than f. Equivalently: erase any δ-small part of f, and the simplest function consistent with the rest is f again. Induction over isolated functions only pins an isolated f at every input at once, with expected posterior error at most 2^(K(f))·(1−δ)ⁿ. It cannot learn small exceptions, and its confidence is as machine-relative as item 3 says.
8. **Successor and addition are ultranatural in a concrete language.** In a small language of bounded primitive recursion without an addition primitive, enumerated exhaustively up to 11 nodes (86,265 functions on 36 inputs), the nearest function no more complex than successor differs from it on 30 of 36 inputs, and for addition on 24 of 36. The patches of addition that we tried are not isolated, or only at the scale of the patch. After 16 random examples of addition, a hypothesis at most 2 nodes larger than addition still fits the data and disagrees with addition at 7% of the unseen inputs; among hypotheses isolated at δ = 1/6 there is none.

## Answers in brief: the second note

A follow-up question: addition satisfies many short universally quantified statements; can properties of the whole function pin down plus over quus? The second note studies the *equational inductor*. A hypothesis is a finite set of identities in the vocabulary {0, S, f}, with no auxiliary symbols; it fits the data if it is consistent and proves every datum; the belief in a label is the posterior weight of the fitting sets that prove it.

1. **Laws must be true so far.** A fitting set contains no identity that the data refute, that is, none with an instance that the data can evaluate and that comes out false.
2. **Addition is pinned at every input, linearly in the side of the data square.** If the data contain x + y for all x, y < n, every fitting set whose identities have sides of at most n + 1 symbols is true of addition. A wrong sum anywhere needs an identity longer than n, and the belief in any wrong sum is at most 2^(36.5 − 0.485·n), which says something from n = 76 on. SOI keeps at least about 2^(−K(n)) for a wrong sum just outside the square. The same holds for successor. A few missing pairs do not matter unless they are small.
3. **What exceptions cost.** Quus with threshold N needs a set of at least N + 3 symbols (at most about 2N³), against 12 for plus. In SOI the difference is about log N bits.
4. **The price.** The inductor's loss is never less than SOI's by more than a constant. If quus is the truth it loses at least about N/2 bits at the first exception. Squaring has no finite set of laws in this vocabulary, and the inductor's loss on it grows without bound.
5. **Why it works, and where it stops.** The grue theorem of the first note does not apply: the bias is the vocabulary, not a machine. An exception at x costs at least what it costs to name x. With unary numerals that is x symbols. With a doubling function in the vocabulary an exception at 2^j has a set of about j² symbols. With auxiliary function symbols quus with threshold 2^j has one of 79 + 2j symbols, and the inductor behaves much like SOI. And a fast-growing target names large numbers itself: doubling is pinned only polylogarithmically (a result of the referee).
6. **A machine-free difference between plus and quus.** The test radius of a target is how far the data must reach to refute every false law of a given size. For plus it is the size minus 1; for quus it is at least the threshold. What matters about addition's laws is not their number: two of them determine it, and no short law is false of it without being false on small numbers.
7. **A run of the inductor** on unary functions, with every identity set of at most 12 symbols and proofs bounded in length. With no data it leaves a far input undetermined (weight 0.94). After two values of successor its belief in the right value at a far input is 0.9995; after three, no enumerated set fits and proves a wrong value. An exception at 0 is learned at a prior weight about 2000 times smaller; an exception at 3 is fitted by a set of 36 symbols, and none of at most 12 was found.
8. **Limits.** The theorems are for data that contain a full initial square, up to a few missing pairs, and they bound the belief in wrong values only; they do not show that the rest is on the right value and not on "undetermined".

## Layout

| path | contents |
|---|---|
| `note.md` | The first note. |
| `equational.md` | The second note: the equational inductor. |
| `code/enumerate_pr.py` | Exhaustive enumeration of the test language by term size, with the least size of every function. |
| `code/nearest.c`, `code/nearest.py` | For every function, the least size of another function at each Hamming distance. |
| `code/analyze.py` | Isolation of named functions, how many functions are isolated, and the dissent that survives random data. |
| `results/enumerate_pr11.out`, `results/analyze_pr11.out` | Saved outputs of the run reported in the first note. |
| `code/identities.py`, `results/identities_L9.out` | A count of the short identities satisfied by plus, quus and other functions. |
| `code/eqlib.py` | Terms, identities, evaluation, and derivation of values from identity sets by valid equational steps. |
| `code/test_radius.py`, `results/test_radius.out` | Test radius of binary and unary targets. |
| `code/theories.py`, `results/theories.out` | Explicit identity sets for plus, quus, patched plus and others, checked by machine, with their sizes. |
| `code/prior_tail.py`, `results/prior_tail.out` | The prior weight of identity sets with a long term, and the pinning bounds of the second note. |
| `code/holes_check.py`, `results/holes_check.out` | A brute-force check of the proposition on missing data pairs. |
| `code/eq_unary.c`, `code/eq_unary_analyze.py`, `code/eq_unary_recheck.py`, `results/eq_unary_*` | The equational inductor for unary functions with bounded proofs: enumeration of all identity sets up to a size, posterior beliefs, and a recheck with a larger bound. |
| `verification/referee-report.md`, `verification/response.md` | The referee's report on the first draft of the first note, and what was changed in response. |
| `verification/referee-report-equational.md`, `verification/response-equational.md` | The same for the second note. |
| `verification/eq_*` | The referee's independent programs and outputs for the second note: a brute-force inductor, test radii, the identity sets, the prior weights, and the sets for doubling. |
| `verification/independent_*`, `verification/extra_checks.*`, `verification/run_all.sh` | The referee's own enumeration (syntactic, no pruning, to 11 nodes), its comparison with the saved results, and its checks of how the reported numbers depend on the size limit and the seed. |
| `results/*.npz`, `results/*.npy`, `code/nearest` | *(not in git)* The enumeration tables and the compiled helper. Regenerate them as below. |

Nothing in this folder is confined to the working branch `claude/eager-lamport-lo512k`; the files not in git are build output.

## Reproducing

**First note.** Python 3 with NumPy, and gcc with OpenMP. From `code/`:

```bash
python3 enumerate_pr.py 11 ../results/pr11.npz
```

```bash
python3 nearest.py ../results/pr11.npz ../results/nearest11.npy
```

```bash
python3 analyze.py ../results/pr11.npz ../results/nearest11.npy 0
```

The enumeration takes about three minutes and 2 GB of memory; with 10 in place of 11 it takes under a minute. The analysis is seeded and reproduces `results/analyze_pr11.out`.

**Second note.** Python 3 with NumPy, and gcc. From `code/`; the first three take seconds:

```bash
python3 test_radius.py > ../results/test_radius.out
```

```bash
python3 theories.py > ../results/theories.out
```

```bash
python3 prior_tail.py > ../results/prior_tail.out
```

The inductor on unary functions: compile, enumerate all identity sets of at most 12 symbols with proof bound 18 (about 25 minutes; bound 14 takes one minute and 16 five), analyse, and recheck the deviating sets with bound 22.

```bash
gcc -O2 -o eq_unary eq_unary.c -lm
```

```bash
./eq_unary 12 18 dump > all18.txt
```

```bash
grep -v "^D " all18.txt > ../results/eq_unary_cap12_L18.txt
```

```bash
python3 eq_unary_analyze.py ../results/eq_unary_cap12_L18.txt > ../results/eq_unary_analysis_cap12_L18.out
```

```bash
python3 eq_unary_recheck.py all18.txt 22 > ../results/eq_unary_recheck_cap12_L18_to_L22.out
```
