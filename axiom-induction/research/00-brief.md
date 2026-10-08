# Brief: Bayesian (Solomonoff-style) axiom induction

Shared brief for every research track. Read it in full before starting.

## The question, verbatim (Kaarel Hänni, 2026-10-08)

> let's consider the case of going from a bunch of phi(x) statements to forall x phi(x). i wonder if this should happen basically like so:
>
> * forall x phi(x) is a simple law which implies all the other statements. so once we see all these other statements, we should up the probability on forall x phi(x). i guess we should still be entertaining other hypotheses as well
> * i guess this is some sort of solomonoff induction idea. see my writing on solomonoff axiom induction here: https://github.com/kaarelh/notes
> * could you investigate whether there is a good version of sth like this here? some further ideas:
>    * we might want to not allow just any enumerable axioms, but ones with templates
>    * we might want to have a derivation length prior (like, statements given without proof in our data set should be fairly easily derived from axioms)
>    * we might want to have a time complexity penalty. like, it should not take too long to generate axioms / to check whether a statement is an axiom
> * i'm interested in whether you can come up with something that robustly picks up the axioms we actually have, or at least something that is equivalent in terms of theorems derived. or if this will at least get a lot of posterior mass

Read the question as asking for three things:
1. **A good version.** A precise Bayesian or Solomonoff-style axiom-induction method, with:
   * a prior over axiom systems built from templates, not arbitrary enumerable sets;
   * a likelihood that makes statements with short derivations probable;
   * a penalty on computation time.
2. **The case ∀xφ from instances φ(t).** What does the method do here?
3. **Guarantees.** When does the posterior concentrate on the actual axioms, or on a deductively equivalent system, or at least give it a lot of mass? When does it fail, and why?

## Hänni's notes (read these)

* `prior/hanni-solomonoff-axiom-induction.md` (main).
  * **Two variants.** Axiom systems must either *prove* the givens, or merely *not contradict* them.
  * **Trichotomy.** Each statement comes out true, false or independent.
  * **Equivalence.** He argues that axiom induction requiring proofs is equivalent to Solomonoff function induction restricted to *consistent* assigners. The argument encodes an assigner T as the decidable schema "T(⌜φ⌝) = accept → φ".
  * **His conclusion.** Unrestricted axiom induction collapses into function induction. This motivates restricting to substitution schemas.
  * **"Other ideas for how to fix axiom induction".** Generate only a small subset of observations, allow some mistakes, and grade near misses.
* `prior/hanni-polytime-solomonoff.md`: time-bounded Solomonoff, with constant regret against every O(p(n)) predictor. This is relevant to the time penalty.
* `prior/hanni-solomonoff-function-induction.md`: subtleties of function induction when the order in which inputs are revealed depends on the function.

The full notes repository is cloned (read-only) at `/home/user/kaarelh/notes`.

## Prior results to build on (read the relevant parts; cite by file and label)

**`../axiom-schemas/` (paper: `../axiom-schemas/paper/main.pdf`; sources in `../axiom-schemas/paper/sections/*.tex`).** This is the non-Bayesian treatment of the same questions.

* **Templates and learner.** The template classes FO ⊆ PAT ⊆ DT° ⊆ SO°. Matching is unique and linear in DT°. The cautious verifier is Acc(D) = ⋂{inst(T) : D ⊆ inst(T)}.
* **Anchors.** The anchor theorem (R*)+(N)+(U), and its first-order case (Plotkin's (R)+(D)).
* **Question 1.** ∀xφ from instances (`universal.tex`, `app-universal.tex`):
  * the instance schema φ(z) is what is learnable;
  * the ω-gap: the closed instances do not entail ∀xφ;
  * the Tarski–Vaught criterion M₀ ≼ M;
  * Q ⊬ ∀x(0+x=x).
* **ZF schemas and PA induction** (`zfc.tex`): all ZF schemas are Miller patterns. PA induction is not a pattern, but it is determinate. First-order lgg is unsound on induction (Theorem K₀).
* **Many schemas without labels** (`many.tex`, `app-many.tex`):
  * a bound on the number of schemas is necessary (Gold);
  * spare slots are unrefutable;
  * DTRC;
  * ∀xφ as a sound merge.
* **The MDL subsection `sec:many:mdl`** (and its appendix). Its finding: *"MDL tracks the statistics of usage, not the logical boundaries of schemas"*. A naive two-part code splits T_Ind by the main connective of the motive, by a margin linear in n. A well-specified code gains at most O(log n) from splitting. This is directly relevant: a Bayesian posterior over template unions is an MDL-like code, so engage with this result. Say whether a derivation-based likelihood changes it.
* **Code: `../axiom-schemas/code/dtrc/`** (README there). It provides:
  * syntax and parser;
  * DT° templates with unique matching;
  * Min(D) and alignment;
  * sound world oracles for ℕ and V;
  * the template refuter;
  * DTRC.

  Reuse it.

**`../inferential-learning/` (report: `../inferential-learning/paper/main.pdf`).**

* **The Ville argument.** `paper/sections/app-caution.tex`, near `lem:app:caution:ville` and `thm:caution:ville`, and `app-informal.tex` around line 61. It shows that a Bayesian thresholded verifier is sound against adaptive provers with probability ≥ 1 − δ/w(h*). The tool is the prior–posterior-ratio martingale and Ville's inequality. Reuse and adapt it; do not re-derive it from scratch.
* **The steeper simplicity penalty** (`research/theory/T5-...`), which comes from Hänni's notes.
* **Gold and positive data** (`research/theory/T1-...`).

**The earlier conversation** (`../axiom-schemas/research/conversation.md`, §§3–10): the PA proposal, rules versus axioms, Gen in Hilbert systems, untagged PA, Gold's theorem, and L∞ versus L₅.

## Initial hypotheses from the orchestrator (to be checked, refined or refuted, not assumed)

* **H1 (model).** A theory is a finite set of DT° templates. A sentence is a template with no metavariables.
  * **Prior.** π(T) ∝ 2^{−λ|T|}, possibly with a time factor.
  * **Likelihood.** Data are conclusions of derivations sampled from a stochastic derivation process ("derivation grammar"). At each node it either cites an axiom, instantiating its metavariables from a probabilistic grammar Q over terms and formulas, or applies an inference rule (MP, ∀-elim with a term from Q, Gen) to sub-derivations. Then P_T(d) = Σ_{π ⊢ d} P(π).
  * **Two-part (MDL) approximation:** max over π.
  * **Normalisation.** It does not depend on the data. This is what gives the size principle: over-general theories spread their mass more thinly.
  * **Alternative likelihoods to compare:**
    * pure axiom citation (the earlier setting);
    * "statements given without proof are easily derivable";
    * the "do not contradict" variant from Hänni's note.
* **H2 (consistency and identification).** Suppose data are i.i.d. from P_{T*} with T* in a countable class and π(T*) > 0. Then the posterior concentrates on {T : P_T = P_{T*}} almost surely (Doob; or merging plus a countability argument).
  * **Identification is of the generator.** Under a derivation likelihood, deductively equivalent axiomatisations usually have *different* P_T, so the posterior identifies an axiomatisation, not merely a theory.
  * **Misspecification.** With human-written data, concentration is on the KL-minimiser (Berk 1966; Kleijn and van der Vaart 2006), and nothing forces that to be "the actual axioms".
  * **Task.** Make this precise and decide what *can* be promised.
* **H3 (soundness against adaptive provers).** The verifier accepts s iff Σ_{T ⊢ s} π(T|D) ≥ 1 − δ, using bounded derivability where needed.
  * **Claim.** It accepts some s with T* ⊬ s only if π(T*|D) ≤ δ. By Ville's inequality applied to M(D_n)/P_{T*}(D_n), this has probability at most δ/π(T*), uniformly over all times and queries.
  * **Relation to the cautious verifier.** The cautious verifier is the δ → 0 limit, with all D-consistent theories in the support.
  * **What remains.** State the exact hypotheses, especially well-specification, and what fails without them.
* **H4 (∀xφ).** Consider the hypotheses:
  * H_∀ = {∀xφ}, a single sentence, where data φ(t) come from one ∀-elim step;
  * H_sch = the instance schema φ(z), cited directly;
  * H_open = φ(z) with z also ranging over open terms or parameters;
  * memorisation;
  * over-specific schemas (such as the lgg with S at the root);
  * over-general templates.

  The conjectures:
  * Instance data move mass away from memorisation and over-general templates at an exponential rate (the size principle).
  * Instance data do **not** by themselves move mass from H_sch to H_∀. Under a derivation likelihood they may move it the other way, by a factor c^{-n}, where c is the probability of the extra ∀-elim step.
  * Hence "all future data are φ-instances" gets probability → 1 (compare Hutter 2007 on confirming universal hypotheses with the universal prior), but "the axioms prove ∀xφ" need not. This would be a Bayesian form of the ω-gap.
  * With open instances and Gen, H_open ⊢ ∀xφ, so the two are deductively equivalent.
  * Data containing quantified theorems whose derivations use ∀xφ shift mass to H_∀.

  Check each conjecture, with exact statements and rates.
* **H5 (positive data and Gold).** Stochastic positive data plus a likelihood that is normalised independently of the data (the size principle) get around Gold's impossibility. Prior work: Horning 1969; Angluin 1988, *Identifying languages from stochastic examples*.
  * **Spare slots.** A template with mixture weight ε costs a factor (1−ε)^n or, integrated over a Dirichlet prior, about ½ log n bits, plus its prior bits. Do they then vanish from the posterior? At what rate?
  * **Earlier question.** Relate this to the L∞ versus L₅ question from the conversation.
* **H6 (time penalty).** In DT°, axiom membership is decidable in linear time, so a penalty on checking axiomhood barely bites inside the class. Where does it matter?
  * in derivation search, i.e. computing the likelihood;
  * against unrestricted r.e. or decidable axiom sets, i.e. Hänni's collapse construction. A schema "T(⌜φ⌝) = accept → φ" requires running T to check membership, so a Kt- or speed-prior-style penalty prices it by T's running time.

  Is there a clean statement here: templates plus a time penalty block the collapse, or block it up to a constant?
* **H7 (PA, ZF and "the axioms we actually have").**
  * **Equivalent axiomatisations.** Which does the posterior favour, and why? Examples: Q+Ind versus Q+LNP versus strong induction; Q5 as written versus variants; Replacement versus Collection.
  * **Data from all of Th(ℕ).** No r.e. theory generates it, so the posterior should keep moving to stronger theories (compare the IΣₙ chain from the conversation).
  * **Mixtures without labels** (a Bayesian DTRC): spare slots, and fragmentation (the MDL finding).
  * **Failures.** Where does the method fail robustly?

## Conventions

* **Mark every claim:**
  * **proved**, with the full proof in the notes;
  * **computed**, with the script and its output;
  * **conjecture**;
  * **known**, with a reference;
  * **proof sketch**.
* **Keep every refuted claim, marked refuted,** with the counterexample.
* **References.** Name the exact source, and flag any reference you could not verify.
* **Code** goes in your track folder or in `../code/` (experiments), seeded, with outputs saved next to the scripts.
* **Final record.** End each track's notes with a *Verification log*: what was checked, how, and with what result.
* **Style.** Plain, precise prose and short sentences. No marketing. Do not claim more than the notes establish.
* **Framing.** Hänni regards publishing insightful work on AI theorem provers with care. Frame this work as understanding and checking, not as building a stronger prover.
