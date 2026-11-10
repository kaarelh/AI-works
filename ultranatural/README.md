# Ultranatural functions

A research note on a question from Kaarel Hänni about Solomonoff operator induction (SOI), the subject of [`../solomonoff-operator-induction/`](../solomonoff-operator-induction/).

* **The question.** When we learn a function from input–output pairs, many natural properties P(x,y) may have held of every pair so far and together leave one choice of y at a new x. Can a function be pinned down in this way, by many properties at once, more strongly than SOI pins it down? Could successor or addition be "ultranatural"? Or does a contrived universal machine spoil any such notion?
* **The note:** [`note.md`](note.md), with definitions, theorems, proofs and an experiment.
* **Author:** Claude (Anthropic), in response to the question and under Hänni's direction.
* **Status:** a draft. An independent AI referee's check of the proofs and of the experiment is in progress; its report will be in `verification/`. No human has checked the mathematics.

## Answers in brief

1. **The idea formalises cleanly, and in its machine-independent form it is what SOI already does.** For a simple target f, the properties of complexity at most k that are true of all pairs so far leave exactly the label f(x) for every k between K(f) and the separation complexity sep(x; A), the complexity of the simplest test that tells x apart from the inputs seen so far. Above sep(x; A) they leave no label. This window is SOI's own margin at x.
2. **The number of properties a wrong label breaks does not matter.** One guard, "if the input is like x, do something else", breaks all of them at once for sep(x; A) bits. The cheapest property that the *right* label breaks is "no input like x occurs", at the same price. A tally of properties that ignores what each was tested on is swamped by such never-tested properties.
3. **The worry about contrived machines is right, and it applies to every scheme.** For any scheme that takes its inductive bias from the reference machine alone, and any new input x, a universal machine sep(x; A) + O(1) bits away gives the opposite answer at x and is indistinguishable from the original elsewhere. SOI is stable up to about half that distance.
4. **"On most new inputs" holds for SOI itself.** After n independent samples, a change of machine by a bits can change the prediction only on a set of inputs of measure about 2^a/n. Inputs of a new kind are all fragile together.
5. **Stronger pinning has a price.** Pinning f(x) with s bits means paying s bits if the exception is real. A universal learner can exceed SOI's pinning by at most about the loss SOI has already paid on the data, at most K(f) bits, which amounts to a choice of machine.
6. **Where the intuition is right.** Hypotheses that disagree with f on a fraction δ of inputs are killed by n data points at rate (1−δ)ⁿ. Laws such as linearity or the recursion equations of addition make every lawful alternative of this kind, and against them many constraints do add up exponentially. SOI's residual doubt, of order 1/n, is entirely small patches of f.
7. **A notion that does not collapse.** f is *δ-isolated* (ultranatural at scale δ) if every other function that differs from f on less than a fraction δ of inputs is more complex than f. Equivalently: erase any δ-small part of f, and the simplest function consistent with the rest is f again. Induction over isolated functions only pins an isolated f at every input with error at most 2^(K(f))·(1−δ)ⁿ. It cannot learn small exceptions, and its confidence is as machine-relative as item 3 says.
8. **Successor and addition are ultranatural in a concrete language.** In a small language of bounded primitive recursion without an addition primitive, enumerated exhaustively up to 11 nodes (86,265 functions on 36 inputs), the nearest function no more complex than successor differs from it on 30 of 36 inputs, and for addition on 24 of 36. Their patches are not isolated. After 16 random examples of addition, some consistent hypothesis still disagrees with addition at 38% of the unseen inputs; among hypotheses isolated at δ = 1/6 this is 4%, and at δ = 1/3 none.

## Layout

| path | contents |
|---|---|
| `note.md` | The note. |
| `code/enumerate_pr.py` | Exhaustive enumeration of the test language by term size, with the least size of every function. |
| `code/nearest.c`, `code/nearest.py` | For every function, the least size of another function at each Hamming distance. |
| `code/analyze.py` | Isolation of named functions, how many functions are isolated, and the dissent that survives random data. |
| `results/enumerate_pr11.out`, `results/analyze_pr11.out` | Saved outputs of the run reported in the note. |
| `verification/` | The referee's report, the referee's independent script and its output, and the record of what was changed in response. |
| `results/*.npz`, `results/*.npy`, `code/nearest` | *(not in git)* The enumeration tables and the compiled helper. Regenerate them as below. |

Nothing in this folder is confined to the working branch `claude/eager-lamport-lo512k`; the files not in git are build output.

## Reproducing

Python 3 with NumPy, and gcc with OpenMP. From `code/`:

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
