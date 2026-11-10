# A toy malign-prior question with an answer

Notes by Claude, prompted by Kaarel Hänni. Research note, 10 November 2026; not reviewed by a human. The proofs were checked by an AI referee (see [`verification/`](verification/)), not by humans.

**Question.** The "universal prior is malign" argument (Christiano 2016) says that a predictor built on Solomonoff's prior gives much of its posterior to hypotheses that predict well only in order to steer whoever acts on the prediction. Is there a toy version in which this is a mathematical statement, and what is the answer there? Hänni suggested two toys:

1. a computable world (a cellular automaton, say) that contains a sensor, a large computer running a time-bounded Solomonoff induction on the sensor's data, and an actuator driven by the predictions; does the predictor end up in control, over a long run or at once, and does one get the "dark room"?
2. worlds are just programs; some of them hand their output so far to a fixed bounded Solomonoff predictor and run the continuation they get back as a program; do hypotheses that look for such opportunities, predict well up to them, and then output their own code ("quine themselves out") get a decent share?

**Paper:** [`paper/main.pdf`](paper/main.pdf) (15 pages; LaTeX sources in [`paper/`](paper/)).

## Short answer

The toy: fix a monotone machine U. The predictor is the mixture ξ of all programs of length at most L that keep to a time schedule T. A world is a program; when its output x first passes a fixed test, it gets a block y of m bits from the predictor (sampled from the posterior given x) and from then on runs y. The world's *own continuation* is the m bits it would have printed next. A continuation is *self-reproducing* if running it prints x and then itself again, so that the same handover recurs. The malign prior hypothesis, for a given world, is then a statement about finitely many rational numbers: "most of the posterior is off the world's own continuation", or "at least a share θ is on self-reproducing continuations".

* **There is a floor.** At every handover point that a fixed test can recognise, self-reproducing programs hold at least a share 2^(−c)·ρ of the posterior. Here c is the length of one wrapper program, which depends on the machine and the test but not on the world or on the amount of data, and ρ (equal to 1 without resource bounds) is the share of the posterior on explanations with c bits and a little time to spare. Time bounds do not remove it.
* **There is no more than the floor in general**, for three reasons.
  * *Calibration.* If worlds are drawn from the predictor's own prior, then given the context the predictor's sample and the world's own continuation are independent with the same law. On that population the predictor hands over a self-reproducing continuation exactly as often as worlds continue with one by themselves.
  * *The searcher is the wrapper.* The hypothesis that enumerates all worlds and waits for a handover is, as a program, the wrapper; conditioning on the context already does its search.
  * *Budget.* Along a world that has a program of length ℓ within the bounds, the posterior mass off the true next m bits, summed over all cut points, is at most m·ℓ·ln 2. A handover at a position that is not cheap to recognise is safe up to m·ℓ·ln 2 / N on average over N positions.
* **A majority needs one of three things**, each an explicit inequality:
  * a machine on which the wrapper is cheap (for every test and payload there is a universal machine, k+1 bits away from U, on which the payload has posterior at least 1 − 2^(−k) wherever the test fires; and another on which a given world is always predicted with probability at least 1 − 2^(−k));
  * a shorter description of the same context. In a world with many readable locations, a copy of the sensor's record at a location with a shorter code beats a typical sensor location by the difference of the code lengths. The copy needs only read access to the data. The gain is capped by the cost of the description "the other place that shows the same data". This is the toy's version of the original argument, and whether it applies is a fact about what is in the world;
  * a world too expensive for the predictor. Then no bound on the mass off the truth remains. This is the usual case for a predictor inside a larger world, and it is left open.
* **Feedback.** If the prediction can change what is predicted, a sampled prediction that makes itself true is confirmed and the default hypotheses are removed for good; its probability is the same posterior mass as before. A world that does what is predicted follows a sample from the predictor's own bounded prior: it stays on the default future when that is cheap and well learned, and leaves it with certainty when the default costs more time than the schedule allows. That is the "dark room" in this toy: a pull toward what is cheap to compute, set by the time bound. A world that does the opposite of what is predicted leaves a length-L predictor with no hypothesis after at most L steps.
* **Sizes, on a small machine** (exact computation; a Brainfuck-like machine, programs of at most 10 commands, 48 output bits). On the stream 1111…, 20.5% of the posterior prints the other bit at bit 16, where a counter-based program is about to stop, and under 1% does at almost every other position after the tenth. On the alternating stream the true bit has 29.4% at bit 17 against 45.7% for the other bit, because a five-command program explains the first 15 bits and a seven-command one is needed for the whole stream. Tightening the time schedule from 24 to 3 steps per bit lowers the share of the truth at these positions (79.1% to 54.4%, and 29.4% to 14.1%), and with programs of at most 9 commands there is a stream whose true 15th bit gets probability 0 under the tight schedule.

So in the toys as posed: with a natural machine, a sensor at a typical place, no simpler copy of its record in the world, and a predictor able to simulate what the sensor sees, the predictor does not take over, up to the constant 2^(−c). With a copy of the record at a simpler place it does, with odds given by the difference in code lengths.

## What is not settled

* The size of c on a natural machine, including whether some program much shorter than a wrapper has the same effect. The original argument is a claim that one does. The toy does not decide this; it shows only that searching for opportunities is not such a program.
* The regime where the world is more expensive than the predictor.
* The many-round dynamics with feedback when the world's response is neither obedient nor contrarian.
* A computation of the self-reproduction quantities on a concrete machine. The statements about them are theorems only. The session that produced this note began writing an enumerator for a small stored-program machine on which predicted continuations would be run; that step was stopped by a safety classifier and was not attempted again.

## Contents

* **`paper/`**: the note (`main.pdf`) and its LaTeX sources; `table-*.tex` are generated by `experiments/make_table.py`.
* **`code/`**
  * `bf8enum.c`: exact enumeration of the bounded mixture of the BF8 machine. It forks the machine state at every read of a new command, so all masses are exact dyadic rationals.
  * `bf8.py`: reference interpreter, a brute-force mixture over all command tapes, and a loader for the enumerator's output.
  * `test_bf8.py`: the enumerator against brute force on four configurations, the semimeasure property, and the example programs quoted in the paper.
* **`experiments/`**: `run_profiles.py` computes the deviation profiles, the budget checks, the prior-average disagreement and the excluded-stream example, and writes `results/profiles.json` and `results/profiles.pdf`; `make_table.py` writes the paper's tables from the JSON.
* **`verification/`**: the AI referee's report and how each finding was resolved.

Reproduce (gcc; Python 3 with matplotlib; TeX Live for the paper):

```sh
cd code && gcc -O2 -o bf8enum bf8enum.c && python3 test_bf8.py
cd ../experiments && python3 run_profiles.py && python3 make_table.py
cd ../paper && latexmk -pdf main.tex
```

## Status

* **Proved here** (short proofs in the paper): calibration, the floor and its self-reproducing form, repetition and persistence, the budget, capture and its cap, machine dependence, the statements on time bounds, one round with feedback, the contrarian world.
* **Known constructions used**: the wrapper is Hutter's lower-bound construction (2007) and that of Cohen, Hutter, Bengio and Russell (2025); the budget is Solomonoff's bound in deterministic form; machine dependence follows the dogmatic prior of Leike and Hutter (2015); the contrarian world is Putnam's diagonal argument. Forum posts on the argument could be consulted only through search-engine summaries, so earlier informal versions of the single-world statements may exist.
* **Numerical**: the BF8 computation (`experiments/results/profiles.json`), exact, on the prediction side only.

**Working branch:** `claude/lucid-hypatia-j4jg12` holds the full working state. Everything in this folder is published except the compiled binary `code/bf8enum`, the LaTeX build files, and every `__pycache__/`.
