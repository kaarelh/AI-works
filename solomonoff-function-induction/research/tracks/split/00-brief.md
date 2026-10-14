# Track "split": the model–randomness split as the main thread of Paper 2 (brief, 2026-10-13)

## The author's request (verbatim)

> for paper 2, have you developed the thread of getting a model + randomness split? in my imagination it'd first have a main thread in that direction (if one can prove some nice theorem saying you get model+data splits to work at least in some contexts), and secondarily see if one can use the stronger simplicity prior idea for not learning mistakes of some teachers. like i'd see it as a paper that gives two different reasons to be interested in SFI with a stronger complexity penalty than likelihood penalty, with these two main threads

He approved this plan: develop (1) exact model recovery with i.i.d. inputs and (2) "a kink implies the split" for single data sets, plus anything else that strengthens the split thread; then restructure Paper 2 with the split as the main thread and the teacher's mistakes as the second.

## What already exists (read these first)

* **Paper 2's sources:**
  * `paper-steeper/sections/setup.tex`: classes, J_λ, Π_λ, the tempered posterior, the λ-MAP, the coding lemma `lem:setup:coding`.
  * `absorb.tex`: absorption with shared randomness; no universal product hypothesis.
  * `split.tex` with `app-split.tex`:
    * Lemma `lem:split:ville` (δ*);
    * `thm:split:lambda1`: at λ = 1 there is no split;
    * `thm:split:private`: for λ > 1 with private randomness, MAP length ≤ k + (k+δ*)/(λ−1); fill-ins' posterior decays in the sampled randomness; asymptotic "ν-equivalent on the run";
    * `rem:split:reading`: what that theorem does not say;
    * `thm:split:shared`: no split with shared randomness.
  * `algstat.tex` with `app-algstat.tex`:
    * set models and structure function;
    * product structure function ρ^×_D;
    * product sophistication;
    * `prop:algstat:product`;
    * `prop:algstat:parity`: the product kink at α ≈ d for a noisy random parity; set models treat the parity as noise.
  * `teacher.tex` with `app-teacher.tex`: the teacher's-mistakes theorem and its lemmas.
  * `limits.tex`.
* **The refereed record behind them:** `research/tracks/steeper/notes-final.md`, especially §1, §3.1–3.6 and §2. Its scripts are in `research/tracks/steeper/checks/`.
* **Paper 1:**
  * `paper/sections/setting.tex`: SFI is defined by one universal machine on one random tape; function machines; M_F.
  * `versions.tex`: M_prod, W.
  * `learn.tex`: merging; online-to-batch.
* **Notation:** `paper/NOTATION.md`.

## Targets

**T1. Exact model recovery with i.i.d. inputs (the "split works" theorem).**
* **Setting.** Inputs are i.i.d. from a distribution μ on X, arbitrary and not necessarily computable. State and handle repeated inputs: on a finite or atomic X, inputs repeat. Either restrict to non-atomic μ / distinct inputs, or treat repeats with per-query fresh noise (the per-query mixture M_pq of Paper 1) and say which object the theorem concerns. Labels come from a computable sampler ν with private randomness, ν = ν_{π*} for some program π* in a countable product class C (prior 2^{-ℓ(π)}, Kraft sum ≤ 1).
* **Wanted.**
  * Almost surely, from some n on, every λ-MAP (λ > 1 fixed) is a shortest program π in C whose predictive law equals ν μ-almost everywhere.
  * The power posterior Π_λ(· | D_n), and the tempered posterior, concentrate on that set.
  * Fill-ins' posterior → 0 exponentially in the sampled randomness (exists).
  * **Finite-sample version** under a margin condition. Every program of length ≤ L that is not μ-a.e. equivalent to ν has expected Hellinger affinity gap ≥ γ, or a KL / risk gap. Give an explicit n(λ, k, γ, ε) such that with probability ≥ 1 − ε every λ-MAP is such a shortest equivalent program. Use the δ* tail of `lem:split:ville` for the length bound.
  * **The λ = 1 contrast.** The posterior mass of fill-ins stays ≥ 2^{-k-O(log log)} forever, so λ = 1 never makes the split exact. Also state what the λ = 1 MAP does: is it a fill-in? Does it have length ≈ sampled randomness?
  * **A natural corollary.** Noisy computable functions: y = f(x) ⊕ Bern(p) with f computable and p computable. The selected model is (f, p) up to μ-a.e. equivalence and shortest description; the noise is the flips.
  * **Other corollaries.** Time-bounded and circuit product classes, since the theorem should hold in every countable product class.
  * **What fails.** Shared randomness (no split for any λ: `thm:split:shared`), λ → 1, non-i.i.d. adaptive inputs (what survives: "on the run"), misspecification (ν not in C: is the λ-MAP eventually a shortest program among the KL-projections onto C? Prove or give a counterexample), and finite domains with the population objective.

**T2. A kink implies the split, for a single data set (no probability model).**
* **Characterisation.** For a data set D and a product class C, the λ-MAPs are exactly the programs on the lower convex hull of the points (ℓ(π), −log ν_π(D)), at the vertex or edge where the hull's slope crosses −λ. State this precisely: ties, edges, existence of minimisers. Relate it to the product structure function ρ^×_D(α) = min{−log ν_π(D) : ℓ(π) ≤ α} and its lower convex hull.
* **The kink theorem.** Say ρ^×_D has an (σ, ε)-kink at α₀:
  * for α < α₀, every program of length α gives up at least σ bits of fit per bit of length saved;
  * for α > α₀, adding length buys at most (1+ε) bits of fit per bit.

  Then for every λ ∈ (1+ε, σ), every λ-MAP has length within an explicit distance of α₀ and is product-b-sufficient for an explicit b. Find the right formulation: hull slopes, or "every program shorter than α₀ − Δ has fit worse by ≥ σ·(α₀ − ℓ)", and so on. Give the cleanest true statement.
* **Corollaries.**
  * The noisy random parity of `prop:algstat:parity` satisfies the hypotheses with σ large and ε small. Give the λ-range in which the λ-MAP is "parity + noise", and compare with the teacher's window.
  * Set models have no kink at α ≈ d for that example, so no steeper set-model code finds the parity.
* **Link to T1.** When D_n is a sample from ν (T1's setting), the kink exists with high probability at α₀ ≈ ℓ(π*), with σ growing linearly in n under the margin condition. This connects the deterministic and probabilistic statements.
* **Interpretation.** "The model consists of the bits that each explain more than λ bits of data."

**T3. The teacher's mistakes as an instance of the split.**
* Recast `thm:teacher:main` (λ = cn, window for c) in the language of T2. The teacher's errors are part of the data; they land in the noise when the product structure function's kink at the parity is steeper than λ and the errors' own "slope" is below λ. Explain the role of λ ∝ n there versus fixed λ in T1, and why the teacher's errors, unlike i.i.d. noise, require λ ∝ n.
* Do not re-prove the teacher theorem. Show precisely how it fits, and what in its hypotheses corresponds to the kink conditions.
* Explain why structured errors (`limits.tex`: error envelopes, rate blindness) defeat it: they create a second kink.

**Anything else** that makes the split thread stronger or clearer is welcome: a cleaner headline theorem, a lower bound showing the margin condition or λ > 1 is necessary, or an example where the split is non-unique.

## Conventions (as for the earlier tracks)

* **Mark every claim:**
  * proved, with a full proof in the notes;
  * computed, with the script and its output;
  * conjecture;
  * known, with an exact reference and "unverified" if not checked against the source;
  * proof sketch.
* **Keep refuted claims, marked refuted,** with the counterexample.
* **Code:** seeded or deterministic Python 3.11, in `checks/` (provers) or `referee_code/` (referees), with outputs saved next to each script.
* **Final record:** end each final record with a Verification log.
* **Style:** plain precise prose, short sentences, no claim beyond what is proved.
* **The author's notes are an internal stage.** The track records may cite them, but the eventual paper text will not frame results as replies to them (`research/paper-review/REFRAME.md`).
* **Repository:** do not run git commands that change repository state.
