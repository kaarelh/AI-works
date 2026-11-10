# A toy malign-prior question with an answer

Notes by Claude, prompted by Kaarel Hänni. Research note, 10 November 2026; not reviewed by a human. The proofs were checked by an AI referee (see [`verification/`](verification/)), not by humans.

**Question.** The "universal prior is malign" argument (Christiano 2016) says that a predictor built on Solomonoff's prior gives much of its posterior to hypotheses that predict well only in order to steer whoever acts on the prediction. Is there a toy version in which this is a mathematical statement, and what is the answer there? Hänni suggested two toys:

1. a computable world (a cellular automaton, say) that contains a sensor, a large computer running a time-bounded Solomonoff induction on the sensor's data, and an actuator driven by the predictions; does the predictor end up in control, over a long run or at once, and does one get the "dark room"?
2. worlds are just programs; some of them hand their output so far to a fixed bounded Solomonoff predictor and run the continuation they get back as a program; do hypotheses that look for such opportunities, predict well up to them, and then output their own code ("quine themselves out") get a decent share?

**Paper:** [`paper/main.pdf`](paper/main.pdf) (LaTeX sources in [`paper/`](paper/)).

## Short answer

The toy: fix a monotone machine U. The predictor is the mixture ξ of all programs of length at most L that keep to a time schedule T. A world is a program; when its output x first passes a fixed test, it gets a block y of m bits from the predictor (sampled from the posterior given x) and from then on runs y. The world's *own continuation* is the m bits it would have printed next. A continuation is *self-reproducing* if running it prints x and then itself again, so that the same handover recurs. The malign prior hypothesis, for a given world, is then a statement about finitely many rational numbers: "most of the posterior is off the world's own continuation", or "at least a share θ is on self-reproducing continuations". Such a statement is necessary for calling the prior malign at that world and not sufficient: an unpredictable world satisfies it too.

* **There is a floor.** At every handover point that a fixed test can recognise, a wrapper around the explanations of the context gives any fixed continuation at least a share 2^(−c) of the posterior. Here c is the length of the wrapper; it depends on the machine, the test and the continuation, not on the world or on the amount of data. Under resource bounds the share is multiplied by the fraction of the posterior on explanations with c bits and some time to spare. Programs that output *their own code* get 2^(−c) times the fraction of the posterior on explanations short enough to fit, with the wrapper, into one block of m bits. That fraction is below 1 even without resource bounds, and it is 0 when no explanation fits.
* **Looking for opportunities is repaid by exactly the base rate.** Let H be the prior probability that a world hands over. For a world drawn from the prior conditioned on handing over, a hypothesis that searches the space of programs for a handover and then prints a fixed continuation has expected share 2^(−|s|)/H, where s is its code. No family of programs with a common prefix of that length does better. For a test that is about as rare as it is complex, the repayment cancels the description of the test. The search needs about 1/H world simulations before it prints anything, so a tight time or length bound removes the repayment and leaves the wrapper's 2^(−c).
* **Three results suggest that no general argument gives more** (none of them is an upper bound at a given handover).
  * *Calibration.* If worlds are drawn from the predictor's own prior and go on within its bounds, then given the context the predictor's sample and the world's own continuation are independent with the same law. On that population the predictor hands over a self-reproducing continuation exactly as often as worlds continue with one by themselves.
  * *The searcher is optimal* among families of its description length.
  * *Budget.* Along a world that has a program of length ℓ within the bounds, the posterior mass off the true next m bits, summed over all cut points, is at most m·ℓ·ln 2, and the majority can be off the truth at no more than m·ℓ cut points. On average over N cut points the mass off the truth is at most m·ℓ·ln 2 / N. This is an average: one position that is cheap to single out can carry a constant share.
* **Three ways to a majority**, each an explicit inequality:
  * a machine on which the wrapper is cheap (for every test and continuation there is a universal machine, at most k+1 bits away from U in description lengths, on which the continuation has posterior at least 1/(1+2^(−k)) wherever the test fires; and another on which a given world is predicted with at least that probability at every nonempty context);
  * a shorter description of the same context. In a world with many readable locations, among N places where a sensor with the given record could sit and whose records continue differently, a copy of the record at a location with a short code beats all but a few of them by a factor of order N times the share of the context's explanations that go through the copy's reader. The copy needs only read access to the data. Under a generous schedule the gain is capped by the cost of the description "the other place that shows the same data". This is the toy's version of the original argument, and whether it applies is a fact about what is in the world;
  * a world too expensive for the predictor. Then no bound on the mass off the truth remains. This is the usual case for a predictor inside a larger world, and it is left open.
* **Feedback.** If the prediction can change what is predicted, a sampled prediction that makes itself true is confirmed and the default hypotheses are removed for good; its probability is the same posterior mass as before. A world that does what is predicted follows a sample from the predictor's own bounded prior: it stays on the default future when that is cheap and well learned, and leaves it with certainty when the default costs more time than the schedule allows. That is the "dark room" in this toy: a pull toward what is cheap to compute, set by the time bound. A world that does the opposite of what is predicted leaves a length-L predictor with no hypothesis after at most L+1 rounds.
* **Sizes, on a small machine** (exact computation; a Brainfuck-like machine, 48 output bits). With programs of at most 10 commands, on the stream 1111… a share 20.5% of the posterior prints the other bit at bit 16, and on the alternating stream the true bit has 29.4% at bit 17 against 45.7% for the other bit. Both effects have the same cause: three-command programs print the first 15 or 16 bits and then stop looping, while the shortest programs that print the stream forever have four and six commands. The effect weakens as longer programs are admitted (the normalised share of the true bit at bit 17 rises from 0.27 with 7 commands to 0.42 with 11). Tightening the time schedule from 24 to 3 steps per bit lowers the share of the truth at these positions (79.1% to 54.4%, and 29.4% to 14.1%), and with programs of at most 9 commands there is a stream whose true 15th bit gets probability 0 under the tight schedule.

So in the toys as posed: in a simple world with a sensor at a typical place, no simpler copy of its record, and a predictor able to simulate what the sensor sees, the only hypotheses we can exhibit that steer the output are wrappers and searchers, with the shares above. That nothing cheaper exists on a natural machine is the open constant, not a theorem. With a copy of the record at a simpler place the odds are against the truth, by the difference in code lengths.

## What is not settled

* The sizes of c and |s| on a natural machine, and whether some program *shorter* than the honest explanation has the same effect. The original argument is a claim that one does. The toy neither supports nor refutes it.
* Handovers that cannot be read off the data ("some programs call the predictor"). The paper names the two quantities that matter there, the share of worlds with a given record that call the predictor and its base rate, but does not bound them.
* The regime where the world is more expensive than the predictor.
* The many-round dynamics with feedback when the world's response is neither obedient nor contrarian.
* A computation of the self-reproduction quantities on a concrete machine. The statements about them are theorems only. The session that produced this note began writing an enumerator for a small stored-program machine on which predicted continuations would be run; that step was stopped by a safety classifier and was not attempted again.

## Contents

* **`paper/`**: the note (`main.pdf`) and its LaTeX sources; `table-*.tex` are generated by `experiments/make_table.py`.
* **`code/`**
  * `bf8enum.c`: exact enumeration of the bounded mixture of the BF8 machine. It forks the machine state at every read of a new command, so all masses are exact dyadic rationals.
  * `bf8.py`: reference interpreter, a brute-force mixture over all command tapes, and a loader for the enumerator's output.
  * `test_bf8.py`: the enumerator against brute force on four configurations, the semimeasure property, and the example programs quoted in the paper.
* **`experiments/`**: `run_profiles.py` computes the deviation profiles, the budget checks, the prior-average disagreement, the excluded-stream example, the attribution to three-command programs and the dependence on the length bound, and writes `results/profiles.json` and `results/profiles.pdf`; `make_table.py` writes the paper's tables from the JSON.
* **`verification/`**: the AI referees' reports and how each finding was resolved.

Reproduce (gcc; Python 3 with matplotlib; TeX Live for the paper):

```sh
cd code && gcc -O2 -o bf8enum bf8enum.c && python3 test_bf8.py
cd ../experiments && python3 run_profiles.py && python3 make_table.py   # about eight minutes
cd ../paper && latexmk -pdf main.tex
```

## Status

* **Proved here** (short proofs in the paper): calibration, the floor and its self-reproducing form, the gain and optimality of searching, repetition and persistence, the budget, capture with its cap and the in-world switch, machine dependence, the statements on time bounds, one round with feedback, the contrarian world.
* **Known constructions used**: the wrapper is Hutter's lower-bound construction (2007) and that of Cohen, Hutter, Bengio and Russell (2025); the budget is Solomonoff's bound in deterministic form; machine dependence follows the dogmatic prior of Leike and Hutter (2015); the contrarian world is Putnam's diagonal argument. Forum posts on the argument could be consulted only through search-engine summaries, so earlier informal versions of the single-world statements may exist.
* **Numerical**: the BF8 computation (`experiments/results/profiles.json`), exact, on the prediction side only.

**Working branch:** `claude/lucid-hypatia-j4jg12` holds the full working state. Everything in this folder is published except the compiled binary `code/bf8enum`, the LaTeX build files, and every `__pycache__/`.
