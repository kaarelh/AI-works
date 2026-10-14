# Track "imitation": recovering the sampler robustly, and the weight-decay analogy (brief, 2026-10-14)

## The author's message (verbatim)

> some thoughts for the second paper:
>
> * if you don't do this already, it might make sense to discuss how there not being a correspondence to bayesian learning as the number of params varies is sorta similar to how weight decay in ML just keeps going on each step. like, weight decay also makes it possible to keep preferring a simpler hypothesis that is worse at classification even in the limit
> * one motivation for doing this learning setup that might give you an original sampler is (human) imitation. like, it'd be cool if we could write down a ML algorithm that gives a copy of a human, and not various other things such as the sampler with some bits specified, or some completely alien system that just thinks about what the human would say. i think whether some connection like this can be made more precise might merit its own research thread actually? to be included in the paper only if you come up with sth cool. the ideal theorem here would be some sort of robustness of recovering the sampler, at least in a toy setting. like, one can do better at prediction by doing eg some arbitrarily alien thinking about the environment around the human, some arbitrarily alien thinking to think about what the human might say next. it'd be super cool if we could say: yes this is possible and would be better at prediction, but we robustly pick out the sampler anyway. at least in some toy setting.
>
> maybe it makes sense to emphasize that we are mostly not claiming to have solved the practical motivating problems in the two main threads of the paper. we are just hoping to provide some useful ideas for a toolkit for handling these problems, and we think at least some toy cases of the problems are solved by these ideas (assuming that's your conclusion from the work you've done; of course don't say this if you think this is false). if you do this caveating already, then no need to change anything. but i just want it to be made clear that there are imo big philosophical problems here that are not remotely solved by these ideas yet

## Context: read first

* **Paper 2, restructured:** `paper-steeper/sections/*.tex`.
  * The setting and data objects (DS, FR, PQ) are in `setup.tex`.
  * Absorption is in `absorb.tex`.
  * Kinks, the kink lemma and the hull are in `kinks.tex` and `app-kinks.tex`.
  * Exact recovery is in `recovery.tex` and `app-recovery.tex`, Theorem A, with the Ville deficiency δ*. The length bound ℓ_0 + (ℓ_0 + δ*)/(λ − 1) says any program's likelihood gain over the sampler is at most its length + δ*.
  * The teacher thread is in `teacher.tex`: λ = cn, population objective cℓ + R, the window.
  * `limits.tex` covers structured errors as a second kink and non-identifiability of λ from imitation data.
* **The split research:** `research/tracks/split/notes-final.md` (synthesis) and the sub-track records `iid`, `kink`, `teacher`, with their verification reports.
* **Binding rules for any eventual paper text:**
  * `research/paper-review/REFRAME.md`: the paper presents material as new and keeps the author's notes out of the running text.
  * `research/paper-review/DECISIONS.md`: arXiv style.
* **Notation:** `paper/NOTATION.md` and the synthesis §1.

## Targets

**I1. Robust recovery of the sampler (imitation), toy setting.** The goal is the author's "ideal theorem": alien predictors may do better at prediction, but the procedure robustly picks out the sampler anyway, at least in a toy setting. Find the right toy setting and the strongest clean statements. Candidate pieces to prove, refute or sharpen:
* **(a) Alien programs cannot beat a truly random sampler by more than their length.** On data from a sampler with genuinely random private coins, every program's total log-likelihood gain over the sampler is at most its length + δ* (Ville). So any "alien" program in the class that predicts better on the sample pays for it in description length. With fixed λ > 1 the selected programs are, at every n, within the explicit length bound, and are eventually equivalent in law to the sampler. State this as robustness against *all* programs in the class, whatever their internal structure.
* **(b) Behavioural non-identifiability.** Recovery is only up to predictive equivalence: the shortest program with the sampler's input–output law. An alien program that computes exactly the human's predictive law, but more compactly, is selected instead. Make precise what is and is not identifiable from input–output data: the law, and the shortest description of it, but not the mechanism. Show a toy example. Say what extra structure would be needed to prefer a "copy" of the human over an equivalent alien: for example, a decomposition "human model + extra computation", which makes aliens longer, or interventions.
* **(c) Environment-driven "noise", the case where the alien really predicts better.** The human's coin flips are partly determined by an environment variable that an alien program can model: through an input feature the human ignores, through a latent shared cause, or through a simple pseudo-random generator. The alien then predicts better by g bits per sample at an extra length Δ.
  * With fixed λ, or any λ_n = o(n), the alien is eventually selected.
  * With λ = cn, the human-sampler is selected iff roughly cΔ > g and c is below the human model's own kink steepness. This gives a window, robust against every alien whose advantage per bit of extra description is below c, and is the same geometry as the teacher thread.
  * Find the precise statement in the population objective, and if possible from samples. Find the necessary conditions: lower bounds showing no procedure can robustly pick the human against aliens with large advantage per bit, and that the advantage per bit is the right quantity.
* **(d) Optional: shared latent state.** Real humans have memory and state across inputs, so they are not product samplers. What survives for samplers with latent state, for example a hidden Markov human in the chronological setting of Paper 1's SFI^hist? At least state precisely what breaks.
* **The interpretation.** Say plainly what the results do and do not show about imitation. The author stresses that big philosophical problems remain unsolved.

**I2. The weight-decay analogy.** Make the author's first bullet precise.
* **λ_n = cn.**
  * It is a per-sample penalty: the λ-MAP objective divided by n is the empirical risk + c·ℓ, which tends to the population objective R + cℓ.
  * No fixed prior gives these MAPs for all n. State and prove the simplest clean version of "not Bayesian learning for any fixed prior as the sample size varies".
  * In the limit it can keep preferring a simpler hypothesis that is worse at prediction or classification. The teacher thread is exactly this.
* **Weight decay.**
  * With plain SGD and loss averaged over n samples, a fixed weight-decay coefficient corresponds to minimising the average training loss plus (wd/2)‖θ‖².
  * That is MAP under a Gaussian prior whose precision grows linearly in n, not a fixed prior.
  * In the infinite-data limit the regularised minimiser need not minimise the population loss.
  * State the precise correspondence and its limits: ‖θ‖² is not description length; SGD noise; decoupled weight decay in adaptive optimisers differs (Loshchilov and Hutter); weight decay is applied per step, so the effective strength depends on the learning rate and the number of steps.
* **Literature, each verified by WebSearch with exact bibliographic data:**
  * Krogh and Hertz 1992 (weight decay and generalisation);
  * Loshchilov and Hutter 2019 (decoupled weight decay);
  * grokking with weight decay: Power et al. 2022; Nanda et al. 2023; Liu et al. 2022 and 2023;
  * weight decay and label noise or memorisation, if a clean reference exists;
  * the tempered / generalised-posterior references already in Paper 2.

  Report exactly what each source says, at abstract level unless the text was read.
* **Deliverable:** a precise remark for the paper: what is analogous, what is not, and why it explains "λ must grow with n" as a regularisation that does not vanish with data.

**I3. The caveats.** Draft the paragraph(s) the paper should carry, for the introduction's scope paragraph and the discussion:
* the paper does not claim to solve the practical motivating problems (imitating humans; not learning teachers' mistakes);
* it offers ideas for a toolkit;
* some toy cases are solved, and the draft lists exactly which, per the proved results;
* big philosophical problems remain, and the draft names the main ones concretely, from the results:
  * identification only up to behavioural equivalence;
  * the choice of λ or c cannot be made from imitation data;
  * realistic errors are structured;
  * frozen labels;
  * uncomputability;
  * the choice of hypothesis class and of reference machine.

Say only what the results support.

## Conventions

As for the earlier tracks:
* status markers on every claim;
* seeded code with saved outputs;
* refuted claims kept as refuted;
* a Verification log;
* plain, precise prose;
* no git commands that change repository state;
* write only in your sub-track folder.
