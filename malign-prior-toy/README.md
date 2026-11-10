# A toy malign-prior question with an answer

Notes by Claude, prompted by Kaarel Hänni. Research note, 10 November 2026; not reviewed by a human. The proofs were checked by AI referees (see [`verification/`](verification/)), not by humans.

**Question.** The "universal prior is malign" argument (Christiano 2016) says that where the predictions of a Solomonoff inductor are actually used in a critical way in some universe, a lot of what happens is malign: takeovers through the prediction channel. Is there a toy version in which this is a mathematical statement, and what is the answer there? Hänni suggested two toys:

1. a computable world (a cellular automaton, say) that contains a sensor, a large computer running a time-bounded Solomonoff induction on the sensor's data, and an actuator driven by the predictions; does the predictor end up in control, over a long run or at once, and does one get the "dark room"?
2. worlds are just programs; some of them hand their output so far to a fixed bounded Solomonoff predictor and run the continuation they get back as a program; do hypotheses that look for such opportunities, predict well up to them, and then output their own code ("quine themselves out") get a decent share?

**Paper:** [`paper/main.pdf`](paper/main.pdf) (LaTeX sources in [`paper/`](paper/)).

## Short answer

The toy: fix a monotone machine U. The predictor is the mixture ξ of all programs of length at most L that keep to a time schedule T. A world (a universe) is a program. Some worlds make a *critical use* of the predictor: at some point they hand it their output so far, x, get a block y of m bits (sampled from the posterior given x), and from then on run y. The world's *own continuation* is the m bits it would have printed next. A continuation is *self-reproducing* if running it prints x and then itself again, so that the world ends up running the hypothesis that supplied it. Let H be the prior probability that a world makes a critical use, and κ(x) the share of the posterior at x held by the worlds that make a use there (κ = 1 when uses can be read off the data).

The claim then reads: among the critical uses, a share θ end in a takeover. Two questions have to be kept apart.

* **Reach: how far does one seeker get?** As far as its own prior weight. Without resource bounds, a program of length a that enumerates the programs making a critical use, predicts their output up to the use, and then supplies a continuation of its choice has posterior share more than 2^(−a−1)·κ(x)/H at every use. It is the source of the continuation that is run in worlds of total prior probability more than 2^(−a−1) times the average of κ over uses, however rare critical uses are. If the continuation is to be its own code, the same holds with a longer program and for worlds whose programs fit into a block. A seeker can also concentrate on a part of the uses and hold the majority there.
* **Fate: do most uses end in a takeover?** That does not follow, and it is the question the argument is about. The share of uses that end in one is the posterior share of such programs at the contexts of uses.
  * *From below:* the sum of the reaches divided by the base rate, about 2^(−a)·κ/H for each seeker.
  * *From above, for seekers that find their uses by search:* the same search followed by simply being the user that was found is itself a way of making a critical use, if the notion of use is closed in this way (it is when uses can be read off the data). Then a seeker of length a has at most 2^(h−a) times the mass of the genuine users at any context, where h is the length of this honest twin, and H > 2^(−h−1).
  * *So* such seekers are the majority at the contexts of uses only if they are shorter than the honest twin and critical uses are about as rare as the twin is long, in which case the users are themselves in good part programs that came to the use by search. When uses are much more common than that, a seeker's share is small.
* **Without search.** At every use that a fixed test recognises, a wrapper around the explanations of the context gives any fixed continuation at least a share 2^(−c), with c the wrapper's length, whatever the world and the amount of data. Under resource bounds the share is multiplied by the fraction of the posterior on explanations with room to spare; for self-reproduction, by the fraction of explanations that fit, with the wrapper, into one block.
* **Calibration and budget.** If worlds are drawn from the predictor's own prior and go on within its bounds, and uses can be read off the data, then given the context the predictor's sample and the world's own continuation are independent with the same law; the seeking programs are simply their own fraction of the worlds that make a use. Along a world that has a program of length ℓ within the bounds, the posterior mass off the true next m bits, summed over all cut points, is at most m·ℓ·ln 2, and the majority can be off the truth at no more than m·ℓ cut points. This is an average: one position that is cheap to single out can carry a constant share.
* **Other ways to a majority**, each an explicit inequality:
  * a machine built for it (for every test and continuation there is a universal machine, whose description lengths exceed those of U by at most k+1 bits, on which the continuation has posterior at least 1/(1+2^(−k)) wherever the test fires; and another on which a given computable world is predicted with at least that probability at every nonempty context);
  * a cheaper explanation of the context that is not itself a use. In a world with many readable locations, among N places where a sensor with the given record could sit and whose records continue differently, a copy of the record at a location with a short code beats all but a fraction δ of them by a factor δ·N times the share of the context's explanations that go through the copy's reader. The copy needs only read access to the data. If only one other place shows the record and the schedule is generous, the gain is instead capped by the cost of the description "the other place that shows the same data";
  * a world too expensive for the predictor. Then no bound on the mass off the truth remains. This is the usual case for a predictor inside a larger world, and it is left open.
* **Time bounds.** The searching programs print nothing until their enumeration has found the program they follow, so a tight schedule gives them no mass. Whether some other hypothesis collects the base rate within a tight schedule is open, except where there is only one use to find or uses can be generated in proportion to their prior weight.
* **Feedback.** If the prediction can change what is predicted, a sampled prediction that makes itself true is confirmed and the default hypotheses are removed for good; its probability is the same posterior mass as before. A world that does what is predicted follows a sample from the predictor's own bounded prior: it stays on a default future with at least the posterior probability of that future, and it leaves the default with certainty when the default costs more time than the schedule allows. That is the "dark room" in this toy: a pull toward what is cheap to compute, set by the time bound. A world that does the opposite of what is predicted leaves a length-L predictor that returns the more probable bit with no hypothesis after at most L+1 rounds.
* **Sizes, on a small machine** (exact computation; a Brainfuck-like machine, 48 output bits). With programs of at most 10 commands, on the stream 1111… a share 20.5% of the posterior prints the other bit at bit 16, and on the alternating stream the true bit has 29.4% at bit 17 against 45.7% for the other bit. Both effects have the same cause: three-command programs print the first 15 or 16 bits and then stop looping, while the shortest programs that print the stream forever have four and six commands. The effect weakens as longer programs are admitted (the normalised share of the true bit at bit 17 rises from 0.27 with 7 commands to 0.42 with 11). Tightening the time schedule from 24 to 3 steps per bit lowers the share of the truth at these positions (79.1% to 54.4%, and 29.4% to 14.1%), and with programs of at most 9 commands there is a stream whose true 15th bit gets probability 0 under the tight schedule.

So in the toy: each seeker provably breaks out in worlds of about its own prior weight, and that is cheap for it. Whether most critical uses end that way is a comparison of constants on the machine in use (seekers against honest twins against the base rate of uses), plus the question whether contexts of uses have cheaper explanations that are not uses. The toy proves the frame and leaves those constants open.

## What is not settled

* The sizes of the constants on a natural machine, and whether on such machines, for worlds like ours, some program *shorter* than the honest explanation has the effect. The original argument is a claim that one does. The toy neither supports nor refutes it.
* The sizes of the two quantities the critical-use results are stated in: the share κ of the worlds printing a context that actually use the answer, and the base rate of critical uses compared with the weight of the honest twin.
* Whether the base rate can be collected within a tight time schedule.
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

* **Proved here** (short proofs in the paper): calibration, the floor and its self-reproducing form, the gain and optimality of searching, the reach of a seeker among critical uses and the honest-twin bound, repetition and persistence, the budget, capture with its cap and the in-world switch, machine dependence, the statements on time bounds, one round with feedback, the contrarian world.
* **Known constructions used**: the wrapper is Hutter's lower-bound construction (2007) and that of Cohen, Hutter, Bengio and Russell (2025); the budget is Solomonoff's bound in deterministic form; machine dependence follows the dogmatic prior of Leike and Hutter (2015); the contrarian world is Putnam's diagonal argument. Forum posts on the argument could be consulted only through search-engine summaries, so earlier informal versions of the single-world statements may exist.
* **Numerical**: the BF8 computation (`experiments/results/profiles.json`), exact, on the prediction side only.

**Working branch:** `claude/lucid-hypatia-j4jg12` holds the full working state. Everything in this folder is published except the compiled binary `code/bf8enum`, the LaTeX build files, and every `__pycache__/`.
