# Brief: a paper on Solomonoff function induction

This is the shared brief for every research track and every writer. Read it in full before starting.

## The request, verbatim (Kaarel Hänni, 2026-10-11)

> ok i'm realizing that maybe we should publicly establish some fundamentals first before proceeding with this. as a separate project for the github, could you write a paper on solomonoff function induction? i might later ask for a second paper on axiom induction and their relations. i think that for now it'd be good for there to just exist some paper that explains what solomonoff function induction is, proves some basic properties, says some stuff about why one might be interested in it. eg here can talk about how it's just ideal supervised learning, which is central to ML, and could also link my slides with dmitry that explain how NNbayes is kinda like a circuit version of solomonoff function induction. if you can work everything out rigorously, i'd like you to include the following ideas:
>
> * some basic SFI learning theorems claimed in https://github.com/kaarelh/notes . see the SFI writeup drafts. in addition to what is there, i think one should be able to get a theorem saying that if you further give the function oracle access to a list of previous x (but not previous y), then it just becomes as good as SI
> * it might be good to just work out some examples. it'd be nice to give some examples where it works well, but here are also some examples where it does much worse than SI which could be worth discussing:
>    * take the function being learned to be a random cyclic permutation on all 2^n bitstrings of length n. display the (x,y) pairs in the following order: first show x_1 = f^{-1}(0000..0000) whose output is f(x_1)=000...000, then show x_2 = f^{-1}(x_1) whose output is f(x_2)=x_1, and so on. this will have very low loss under SI but high loss under SFI. i think it's a good example for clarifying the difference
>    * another example from sam eisenstat: take an infinite random bitstring of 1/3 coinflips, think of it as a function from index to coinflip. then flip 2/3 coins for whether to show the next head or tails. i think it should be possible to figure out what SI and SFI do here. here's an argument for SFI from which you can hopefully reconstruct context, copied from an email i sent to Sam "Claim. log loss in your solomonoff function induction coinflip question is the loss given by our threshold function, up to o(n) terms
>
> Pf sketch.
>
> easy direction: We know log loss of solomonoff function induction L_S is at most the log loss of an appropriate threshold function L_T (up to a log n term for specifying the threshold), because this guy lives inside the solomonoff distribution.
>
> other direction: Say for a contradiction that L_S < 0.999 * L_T. Then SFI log loss on the initial mixed coinflip segment L'_S would be even lower than that. But then you can specify that coinflip sequence with only L'_S bits (by the standard pointing trick for going from a solomonoff measure lower bound to a complexity upper bound). This contradicts a random 1/3 coinflip sequence being with very high probability incompressible below h(1/3) per bit.
>
> So L_S approx L_T."
>
> * the trick idea for, in a specific case, not learning your teacher's mistakes via a stronger simplicity prior: https://www.lesswrong.com/posts/hTPpXCuX3TvjyHBAt/jonas-hallgren-s-shortform?commentId=zH3HodivrhKjycMsa (the point is that this could be an interesting thing that one can do with SFI but not usual SI)
> * i think one might also get a preference for a simple sampler over a model where the sampled bits are filled in (solomonoff doesn't have a preference here, both get similar posterior). like, solving the model vs randomness split problem. iirc i have some note about this in https://github.com/kaarelh/notes but if you can't find it and don't otherwise know what i'm talking about, then please ask and i can try to explain it more
>
> you should think if there's anything else that would be good to include in the paper. feel free to develop new theory — maybe spend some time trying but no need to include anything in the writeup if you don't find anything that cool. also feel free to split into multiple papers if that seems more appropriate as you're working on it

## Sources (in `prior/`, copied from `kaarelh/notes`; the full repository is at `/home/user/kaarelh/notes`)

* **`hanni-sfi-notes.md`** and **`hanni-sfi-draft-2025-09.txt`** (the SFI writeup drafts). They contain:
  * the definition;
  * "Thm 1 (template)", the dominance theorem for x-only computable samplers, which uses separate randomness per input via dovetailing;
  * the history-aware version, with counterexamples:
    * the chain (x_{i+1}, x_i) of random strings;
    * the "skipped string" construction;
  * his "Thm 1" for a computable reveal distribution Δ, with a proof sketch (simulator plus Jensen);
  * open questions:
    * a version using the algorithmic mutual information of Δ and f;
    * whether the Kolmogorov and universal-semimeasure versions are equivalent ("need coding theorem");
  * the OOD remarks (a simple property separating test from train);
  * the generalization section of the PDF draft.
* **`hanni-si-not-paragon-draft-2025-08.txt`**: "Solomonoff Induction is not the paragon of generalization" (a plan and introduction).
* **`hanni-grokking-a-notion.md`** ("beating solomonoff induction at grokking a notion"). **This is the source for both the teacher's-mistakes trick and the model-vs-randomness split.**
  * Its "messy notes" are, as far as we can tell, the content of the LessWrong comment in the request, which cannot be fetched from here.
  * The idea:
    * a steeper simplicity penalty, λ > 1 on program length against likelihood;
    * applied in *function* induction where each input gets its own private randomness;
    * so that the MAP is "simple model + noise" rather than "model + memorised errors";
    * whereas in sequence induction a universal hypothesis absorbs everything.
  * Also the line "have people not already considered this for solving the model + data split problem?".
* **`hanni-lesswrong-comment-thread.md`**: the LessWrong thread Hänni pasted after this brief was written. It confirms that the grokking note is the source. It adds **Cole Wyeth's objection**: under a steeper penalty, a hypothesis that is itself a universal distribution absorbs everything, "studied in algorithmic statistics". It also gives **Hänni's reply**, with his numbers: a 100-bit simple model; errors on a 2^{-10} fraction of inputs, whose set costs 10,000 bits; the 'good model', 'error-learning model' and '50/50 model'; and private randomness as the reason no universal hypothesis fits in the function case. The paper must answer Wyeth's objection explicitly.
* **`hanni-*ood*`, `hanni-some-examples-where-function-solomonoff-generalizes-well-ood.md`, `hanni-does-solomonoff-generalize-well-out-of-distribution.md`, `hanni-solomonoff-induction-is-weird.md`**: OOD generalisation of SFI.
* **`hanni-polytime-solomonoff.md`**: time-bounded Solomonoff, with constant regret against O(p(n)) predictors.
* **`hanni-circuit-*.md`**: circuit Solomonoff. Regret and complexity are polynomially related; circuit Occam learning; OOD min-circuit induction.
* **`hanni-bridging-parametrized-bayes-and-solomonoff.md`** and **`hanni-kolmogorov-prior-in-NNs.md`**: NN Bayes versus Solomonoff.
* **`hanni-ideal-inductions-sequence-meta.md`**: his plan for a sequence of notes on ideal inductions: functional Solomonoff induction, positive-example induction, axiom induction, property induction, circuit induction, time-bounded universal induction.

**Earlier project material (formalisations; re-verify before reuse):**
* `../../inferential-learning/research/theory/T5-steeper-simplicity-and-normativity-from-imitation.md` and its checks in `T5-checks/`. This formalises the grokking note:
  * private randomness against a universal hypothesis (Thm 2.1, Prop 2.2);
  * the sequence pathology (Prop 2.3);
  * the kink theorem (Thm 2.5);
  * the convex hull and rate thresholds (Lemma 3.1, Thms 3.2–3.5);
  * the pathologies (Thm 4.1, Prop 4.2, Thm 4.3, Props 4.4–4.5);
  * in-context universality (Prop 2.6).
* `../../inferential-learning/paper/` (the report *What Follows from What*), especially the imitation and caution sections.
* `../../axiom-induction/paper/sections/time.tex`: Hänni's axiom-vs-function-induction equivalence, the semimeasure convention, and the asymmetric time-penalty results. These are for the *later* paper. This paper should not depend on them, but should use compatible definitions.

**Slides with Dmitry, now available.** `prior/vaintrob-hanni-nnbayes-generalization-slides.{pdf,txt}`: Vaintrob and Hänni, *A Generalization Result for Overparametrized Neural Net Bayesian Learning* (ILIAD 2026, 110 pages, slide footers numbered to 38). The link is https://kaarelh.github.io/ai/nnbayes-generalization.pdf.
* **The SFI warm-up.**
  * Python programs with prior 3^{-|p|}; i.i.d. inputs.
  * Proposition: after n = O(C) samples, the average posterior probability on the correct answer exceeds 99.9%, with probability 1 − exp(−Ω(C)).
  * A relevance-based sample-complexity bound.
* **The main theorem.** Under a strong ℓ2 prior, the NN Bayes prior of a function roughly tracks its MLP-circuit complexity even when the net is overparametrized. Hence circuit-simple functions are learned from poly(d, C) samples.
* **The NNGP case is different:** XORs are circuit-simple but slow to learn.

This is the source for the NN Bayes ≈ circuit SFI bridge (H10). Cite it as these slides, and state only what they claim, with their own caveats.

**Not available.**
* (The slides with Dmitry are now available; see above.)
* A web search found arXiv 2607.05735, "Width-Robust Learnability in Mean-Field Bayesian Neural Networks" (Vaintrob, Hänni), and a LessWrong post "Deep Learning is cheap Solomonoff induction?" (slides from an October 2024 talk; authors not confirmed). Neither could be opened.
* **Network:** arxiv.org, lesswrong.com and greaterwrong.com do not resolve. WebSearch works (snippets only). Mark any reference you could not check against its source as **unverified**, and never invent bibliographic data.

## Later request (Hänni, 2026-10-11, verbatim)

> oh i just remembered that also the paper should include an equivalence between the kolmogorov complexity version and the universal semimeasure version, if these turn out to be equivalent (if they don't, then it should explain that). of course only include it if you can figure it out rigorously first

The paper must therefore give this question a section of its own, built from the foundations track's refereed results (H1). Cover:
* the universal function semimeasure M_F and its machine form;
* the weak-semimeasure variant;
* the deterministic program mixture W;
* the single-shortest-program (Kolmogorov) version K_F;
* the mixture of product laws.

For each comparison, state exactly what is proved: equivalence up to a constant, an unbounded gap with an explicit example, upper bounds on the gap, and what remains open. Then explain what the differences mean for prediction. Include only rigorously established claims; mark open questions as open.

## Orchestrator's preliminary analysis: hypotheses to prove, correct or refute, not assume

* **H1 (definitions).** Make precise and compare:
  * (a) the *universal function semimeasure*: lower-semicomputable semimeasures over finite partial functions D ⊆ X×Y, consistent under extension, or equivalently monotone "function machines" ω ↦ f_ω whose value at x depends on a finite part of ω. Randomness is shared across inputs.
  * (b) the *program mixture* Σ_{p consistent with D} 2^{-|p|} over deterministic programs.
  * (c) the mixture over computable *product* random functions, with private randomness per input.

  Questions:
  * Is (a) universal (Levin-style)?
  * How do (a) and (b) relate (the "Kolmogorov vs semimeasure" question in his draft)? A hint: (b) may need to pay roughly K(dom D), or a log factor via k-wise independent hashing.
  * What is the right definition of SFI, and what is invariant under the choice of universal machine and of input encoding (his §2.1 "input encoding doesn't matter much")?
  * The semimeasure convention for losses: telescoping makes SFI's cumulative loss −log M_F(D_n), **independent of the order of the data**.
* **H2 (dominance against x-only predictors).** For every computable random function P and every input sequence, including adversarial and non-computable ones: loss_SFI ≤ loss_P + K(P) + O(1). The comparison class is computable random functions: repeated queries give the same label.
* **H3 (history-aware predictors).** His draft's Thm 1 needs scrutiny.
  * A possible counterexample to its proof sketch (check it): inputs {a, b}, f(a) = f(b) = β, a uniform bit. Δ shows a, then b. P predicts y_1 uniform and y_2 = y_1. P's loss is 1 bit. The private-randomness simulator g, which gives each input its own simulated history, has marginals 1/2, 1/2 and loss 2 bits. So "simulator loss ≤ P's loss" fails when P exploits cross-input correlation. SFI itself is fine here through deterministic hypotheses.
  * A shared-randomness simulator gives a bound with the input sequence's log loss under Δ added, not K(Δ).
  * Find the correct theorem, for example:
    * Δ independent of f given the observed history;
    * a comparison with the Bayes-optimal predictor;
    * a K(Δ) or mutual-information form.
  * Prove the counterexamples (the chain and the skipped string) rigorously.
* **H4 (Hänni's new conjecture).** Give the function oracle access to the list of previous x's, not the y's. Then SFI^hist should be, up to constants, the *chronological* universal semimeasure (Hutter's ξ for AIXI, with inputs as actions and labels as percepts). A random function with shared randomness can recompute earlier labels from the earlier inputs.
  * Hence: dominance over **every** computable history-aware predictor on **every** input sequence.
  * Make "as good as SI" precise: the relation to Solomonoff's M on the interleaved sequence x_1 y_1 x_2 y_2 …, whose conditional y-predictions may differ from ξ's. Check what is known (Hutter 2005 book; papers on universal prediction with side information or actions) and prove what you can.
* **H5 (cyclic permutation, his example).**
  * SFI's loss over the whole cycle is −log M_F(f) ≥ K(f | n) − O(1) ≈ log₂((2^n − 1)!) ≈ (n − log₂ e)·2^n, for most cyclic permutations.
  * SI on the interleaved sequence has loss O(K(n)) plus small terms, since y_k = x_{k−1}.
  * SFI^hist also does well.
  * Give exact statements, with probabilities over the random permutation.
* **H6 (Eisenstat's example).** b_i ~ Bern(1/3) i.i.d.; at each step a Bern(2/3) coin says whether to reveal the next unrevealed head (label 1) or the next unrevealed tail (label 0).
  * After n steps about 2n/3 heads are revealed, covering indices up to about 2n, and about n/3 tails, covering indices up to about n/2.
  * So the revealed set is roughly [0, n/2) together with the heads in [n/2, 2n).
  * **SFI:**
    * the order-independent loss −log M_F(D_n) is at most the loss of a threshold hypothesis ("Bern(1/3) below t, 1 at or above t", t mixed over at log n cost), about (n/2)·h(1/3) + O(log n);
    * it is at least K(labels | domain) − O(1) ≈ (n/2)·h(1/3), by the coding theorem applied uniformly in the domain;
    * so loss_SFI = (h(1/3)/2)·n + o(n) w.h.p. (≈ 0.459n bits);
    * the i.i.d. Bern(1/3) hypothesis would pay ≈ 1.25n.
  * **SI:** the smallest unrevealed index is (after a burn-in) the next tail, so a revealed index equal to it is a tail and otherwise a head. SI's loss should be bounded (O(1) in expectation). Verify, including the burn-in and the fluctuation terms. Make "our threshold function" precise.
* **H7 (ideal supervised learning).** For any input distribution, even a non-computable one, and any computable conditional law P(y|x): SFI's cumulative expected log loss is at most K(P) + O(1). By online-to-batch conversion, its average risk is at most K(P)/n.
  * Compare with Occam bounds, PAC-Bayes and MDL.
  * Explain why this makes SFI "ideal supervised learning", and where the analogy breaks (log loss against 0/1 loss; the inputs are never predicted).
* **H8 (OOD).**
  * His proposition: a simple property absent from training gives a constant probability of bad behaviour (for example, output 0) on inputs that have it.
  * Is there a converse, or a positive result when no simple property separates test from train?
  * His examples where SFI plausibly generalises well (proof/disproof labels; counting).
* **H9 (steeper simplicity; teacher's mistakes; model vs randomness).** Re-derive and adapt T5:
  * in sequence SI with λ > 1 a universal hypothesis absorbs everything;
  * in SFI with private per-input randomness, a steeper penalty selects "simple model + noise" in his specific case (simple model plus idiosyncratic errors), so the learner does not learn the teacher's mistakes;
  * the model-vs-randomness split: with λ > 1, SFI prefers a simple sampler to a model with the sampled bits filled in, whereas at λ = 1, and in SI, the two get similar posterior;
  * the relation to the Kolmogorov structure function, sophistication and algorithmic sufficient statistics (Vereshchagin–Vitányi 2004; Gács–Tromp–Vitányi 2001; Koppel);
  * the pathologies (rate blindness; cheap systematic errors are learned; the good window cannot be identified from imitation data).

  Say exactly what is new relative to T5, and keep its corrections.
* **H10 (computable and physical versions).**
  * Time-bounded SFI (his polytime note).
  * Circuit SFI (his circuit notes: regret and complexity polynomially related; Occam).
  * The bridge: NN Bayes as approximately circuit SFI. Hedge it; cite the slides when the link arrives.
  * Simplicity-bias literature, all to be checked: Valle-Pérez et al. 2019; Mingard et al. 2021; Goldblum et al. 2023 on no free lunch and Kolmogorov complexity; Grau-Moya et al. 2024 *Learning universal predictors*.

## Conventions

* **Mark every claim:**
  * **proved**, with the full proof in the notes;
  * **computed**, with the seeded script and its saved output;
  * **conjecture**;
  * **known**, with an exact reference (unverified if not checked against the source);
  * **proof sketch**;
  * **refuted**, kept with its counterexample.
* **Hänni's claims are hypotheses,** not facts. Where one is wrong as stated, say so and give the corrected statement.
* **Code:** in your track folder (`checks/`) or in `../code/`, seeded, with outputs saved next to the scripts.
* **Final record:** end each track's notes with a *Verification log*.
* **Style:** plain, precise prose, short sentences, no marketing, and nothing claimed beyond what the notes establish.
* **Audience:** a mathematically literate reader (learning theory, algorithmic information theory). The paper is meant to establish public fundamentals, so definitions must be careful and self-contained.
