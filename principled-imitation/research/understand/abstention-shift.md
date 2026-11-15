# Learners that may abstain, and distribution shift: a literature digest

*For the "principled human imitation" problem. One team member's reading of the literature on learners that are never, or only rarely, silently wrong because they may abstain. Companion digests in this folder: `notes.md` (the researcher's notes), `repo.md` (what this repository has proved) and `ask-for-help.md` (protocols that query the demonstrator occasionally; it overlaps with §3.1, §4.1, §5 and §8.3 here, and I point to it where it has more). The lead's working draft is `../candidate-theory.md`; §9.7 uses the labels of its version 2.*

## 0. Access, method, conventions

**Web access.** WebSearch works. Pages could be fetched from `arxiv.org` and `proceedings.mlr.press` only. The hosts `www.jmlr.org`, `link.springer.com`, `dev.icml.cc`, `ttic.edu` and `proceedings.neurips.cc` are outside this session's allowed network domains (WebFetch and direct download both fail). So four works named in the task could not be opened in their original form:

* Li, Littman, Walsh (and Strehl), "Knows What It Knows" (ICML 2008; Machine Learning 2011);
* El-Yaniv and Wiener, "On the Foundations of Noise-free Selective Classification" (JMLR 2010);
* Sayedi, Zadimoghaddam and Blum, "Trading off mistakes and don't-know predictions" (NIPS 2010);
* Wiener and El-Yaniv, "Agnostic selective classification" (NIPS 2011).

For these four I give the statements as they are restated in papers I did read, and I name the restating paper each time. Everything else the task names was read from the arXiv or PMLR PDF (text extracted with `pdftotext`). No private details and no project text went into any query.

**Tags.**

* **[read in source: KEY]**: I read the statement in the work KEY in this session. Keys are resolved in §12. "Restated in KEY" means KEY reports another paper's result and I read it there, not in the original.
* **[read in source: web search result]**: seen only on a web-search result page (bibliographic data or a one-line description), not in the work itself.
* **[from memory, not checked]**.
* **[my own derivation]**: mine, unrefereed. Short proofs are given so that they can be checked.

"Read" means the cited statements and the text around them. I did not check the proofs of the papers' theorems unless I say so.

**Notation.**

* Inputs x ∈ X, outputs y ∈ Y. A deterministic target is f; a stochastic target (sampler) is P(·|x). H is the hypothesis class; d = VC(H) for binary classes.
* Training inputs are drawn from μ, deployment (test) inputs from μ′. Goldwasser et al. and Kalai–Kanade write P and Q for these, hence "PQ learning"; I write μ and μ′ so that P stays the human sampler.
* n or m is the number of labelled training examples. ⊥ is an abstention ("reject", "I don't know"). Coverage is the probability of not abstaining.
* VS(D) is the version space, the members of H consistent with the data D. DIS(V) = {x : two members of V differ at x} is the disagreement region.
* K, sep(x; A), "patch" and "guard" are as in `/home/user/AI-works/ultranatural/note.md`, §1. H_k is the set of total computable functions of complexity at most k.
* ln is the natural logarithm, log is to base 2.

---

## 1. The findings in brief

1. **There are three notions of "not silently wrong", and they have three different prices.**
   * *Never wrong at any answered input.* The learner must abstain wherever two surviving hypotheses differ (this rule is optimal: El-Yaniv–Wiener, Theorem 7). The cost is governed by the star number or the eluder dimension of the class, not by its VC dimension: of order |H| for a finite class in the worst case, not log |H|, and infinite for intervals or half-planes (§3).
   * *At most a fraction ε of the answered test inputs wrong.* Here the VC dimension is enough, for arbitrary test inputs, but the learner needs the unlabelled test inputs in advance and ε is of order √(d/n) (§5).
   * *Calibrated on average over a prior.* This holds at every input, in or out of distribution, at no cost; turning it into a statement about one fixed target costs a factor 1/w(target) (§7.4).
2. **(a) Arbitrary test inputs.** With a class of VC dimension d, n labelled training examples and n unlabelled test inputs chosen arbitrarily (even by an adversary who knows the classifier), the Rejectron algorithm of Goldwasser, Kalai, Kalai and Montasser answers wrongly on at most an ε fraction of the test inputs, with certainty, and rejects at most about (2d log 2n)/(εn) of fresh inputs from the training distribution. Balanced, both are about √(d log n / n), and Ω(√(d/n)) is necessary. Nothing bounds the rejection rate on the test inputs themselves beyond (rejection rate on μ) + TV(μ, μ′). Without unlabelled test inputs, or without abstention, nothing can be guaranteed.
3. **(b) Coverage on the training distribution.** For the never-wrong rule the rejected mass after m examples is at most (10·n̂·ln(em/n̂) + 4 ln(2/δ))/m, where n̂ is the version space compression set size; n̂ can be as large as min(star number, m), and is within a factor d of the disagreement coefficient θ. So coverage is 1 − Õ(θd/m) when θ is bounded, and no distribution-free rate exists when the star number is infinite. For the ε-fraction notion the rejected mass is Õ(d/(εn)).
4. **(c) Impossibility.** Collected in §10. The ones that matter most: never-wrong learning of the single-point indicators on {0,1}^d, or of conjunctions on d variables, needs about 2^d abstentions; no distribution-free method achieves conditional coverage, and coverage that is robust to all covariate shifts with density ratio at most B cannot beat running at level α/B; in the non-realizable case with noise rate η, error plus rejection is at least √(η/8); online, without knowledge of the typical input distribution, (mistakes) × (abstentions on typical inputs) is at least of order the horizon, even when every label is shown.
5. **(d) Universal classes.** Every theorem above is stated for a fixed class of finite dimension. A Solomonoff-type class has infinite VC dimension, infinite star number and infinite Littlestone dimension. The theorems are rescued by a complexity budget k (or a prior weight w): H_k has VC dimension about k but star number about 2^k (its patches are a star set). So rate-type guarantees cost about k/ε² examples, and never-wrong guarantees cost about 2^k abstentions or queries, and both need the assumption K(target) ≤ k, which data can refute but not confirm. Bayesian versions exist: Lattimore, Hutter and Sunehag give a sound confidence bound for a Bayes mixture over a countable class, at price 1/w(truth); Cohen, Hutter and Nanda give an imitator over a countable class of samplers with the same kind of price. The exponential is the separation-complexity floor of this repository in learning-theoretic form (§7.5).
6. **(e) Samplers.** Three things carry over: KWIK-style ε-accurate prediction of output distributions (cost 1/ε² per hypothesis, or 1/w in the countable case); the conservative "minimum over plausible models" rule, which never makes any event more likely than the demonstrator does (Cohen–Hutter–Nanda); and conformal prediction, which is model-free but needs exchangeability or the likelihood ratio. I found no PQ-type theorem for samplers under arbitrary shift; Kalai and Kanade's minimax-abstention lemma is general enough to give one (§8.7, a sketch of mine). For generative models there are also lower bounds: a calibrated generator must produce invalid outputs at about the missing-mass rate unless it abstains.
7. **For the design of a protocol** (§9): choose the soundness notion first; the ε-fraction notion with unlabelled deployment inputs is the only one in this literature that is both affordable for a universal class and valid under arbitrary shift, and a scaffold can produce unlabelled deployment inputs without the human; the rejection rule doubles as a test of whether the human needs to be asked again; realizability is assumed everywhere except in conformal prediction, and its failure is not an obvious failure.

---

## 2. A map of the models

| model | who chooses the test inputs | feedback | what is allowed on answered inputs | what is bounded | governing quantity | main source |
|---|---|---|---|---|---|---|
| KWIK | adversary, one at a time | label only after ⊥ | nothing (ε-accurate with probability 1 − δ) | number of ⊥ | at most \|H\| − 1; exactly the eluder dimension (§3.2) | LLWS11 |
| k mistakes (SZB) | adversary, one at a time | label every round | at most k mistakes in total | ⊥ plus mistakes | ELdim(H, k) ≤ (k+1)·\|H\|^(1/(k+1)) | SZB10, ZC16 |
| RPU, perfect selective classification | i.i.d. from the training law | none after training | nothing | rejected mass under μ | n̂, θ, star number | RS88, EYW10, WHE15, HY15 |
| agnostic selective classification | i.i.d. from the training law | none after training | agree with the best f* in H | rejected mass under μ | θ, d, R(f*) | WEY11, GE19 |
| PQ learning (redaction) | arbitrary μ′, or an adversarial batch; unlabelled test inputs given | none | error rate ε on the test inputs | error on μ′, rejection on μ | d | GKKM20 |
| transductive abstention at a cost | as above | none | loss, with cost α per abstention | total loss on the batch | d | KK21b |
| sequential prediction with injections | i.i.d. stream with adversarial insertions | label every round | counted | mistakes plus abstentions on i.i.d. rounds | d if μ is known; a polynomial trade-off in T if not | GHMS23, YB26, EG26 |
| testable learning with shift (TDS) | arbitrary μ′; unlabelled test inputs given | none | error ε on μ′ if the test accepts | accept when μ′ = μ | class- and μ-specific | KSV24 |
| conformal prediction | exchangeable with calibration data | none | miscoverage α on average | set size | none (model-free) | VGS05, TBCR19 |
| adaptive conformal inference | arbitrary sequence | label every round | long-run miscoverage α | — | none | GC21 |
| online imitation with queries | arbitrary, history-dependent | demonstrator acts when queried | events not much more likely than under the demonstrator | Σ (query probability)³ | 1/w(demonstrator) | CHN22 |

Two reading aids.

* **An abstention is a label request.** The KWIK enumeration algorithm, the CSS rule and the CAL active-learning algorithm are the same rule, "ask or abstain exactly on the disagreement region" [read in source: Bal15 §2.2.1, §4.1; WHE15 §4]. So every bound on abstentions below is also a bound on the queries of an "ask when unsure" protocol.
* **Who sees the label, and when, decides which trade-offs exist.** See §4.4.

---

## 3. Never wrong: KWIK, and perfect selective classification

### 3.1 KWIK

**Model** [read in source: restated in SS11 §2 (Algorithm 1, Definition 2.1), JKMR16 §2 and Bal15 Definition 2.2; informally in WSDL09 §2]. An adversary presents inputs x_1, x_2, … one at a time, each chosen with knowledge of the past. The learner outputs a prediction ŷ_t or ⊥ ("passes"). Only when it outputs ⊥ does it observe y_t (or a noisy observation z_t with E z_t = f(x_t)). An algorithm is an (ε, δ)-KWIK learner of a class C with bound m(ε, δ) if for every adversary and every target f ∈ C, with probability at least 1 − δ: (1) every prediction satisfies |ŷ_t − f(x_t)| ≤ ε, and (2) the number of ⊥ outputs is at most m(ε, δ). LLWS11 ask for m polynomial in 1/ε, 1/δ and the size parameters of the problem. Szita and Szepesvári note that if the response is shown at every step whatever the learner does (the "relaxed KWIK protocol"), "the learning problem can only become easier".

**Positive results** [read in source: restated in Bal15 §2.2, except where noted].

* *Enumeration.* For a finite class H of deterministic functions: keep the version space, predict when it is unanimous at x_t, else output ⊥ and remove the refuted hypotheses. At most |H| − 1 abstentions. (Also restated in ZC16 §1.)
* *A coin.* O(ε⁻² ln(1/δ)) abstentions to learn a bias to accuracy ε.
* *An n-sided die.* O(n·ε⁻² ln(n/δ)).
* *Noise-free linear functions on Rⁿ.* At most n: predict when x_t is in the span of the inputs already labelled.
* *Linear functions with noise.* Õ(n³ε⁻⁴).
* *Combinations.* Unions of KWIK-learnable classes, also with noisy observations, and Cartesian products are KWIK-learnable.
* *The k-meteorologists problem* (which of k given probabilistic predictors is right): O((k/ε²)·ln(k/δ)) abstentions [read in source: restated in LHS13 §5, attributed to DLL09].
* KWIK is stronger than the mistake-bound model: a KWIK algorithm with at most B abstentions becomes a mistake-bound algorithm with at most B mistakes by predicting instead of abstaining (Bal15 Proposition 2.3).

**Negative results.**

* *Singletons.* The class of the 2ⁿ indicator functions of single points of {0,1}ⁿ is learnable with one mistake, but a KWIK learner "is not sure until seeing 2ⁿ − 1 examples" [read in source: Bal15 §2.1.2, citing Example 1 of SZB10].
* *Conjunctions.* "There exists a sequence of examples (x_1, …, x_{2^d − 1}) such that for ε, δ ≤ 1/2, every (ε, δ)-KWIK learning algorithm B for the class C of conjunctions on d variables must output ⊥ for x_t for each t ∈ [2^d − 1]" [read in source: JKMR16 Lemma 11, attributed there to Li's 2009 thesis]. Conjunctions are learnable with d + 1 mistakes [from memory, not checked], so the gap between "few mistakes" and "no mistakes" is exponential.
* *Thresholds and intervals on the line.* An infinite set of thresholds has infinite Littlestone dimension, hence no finite bound on abstentions even when any fixed number of mistakes is allowed [read in source: ZC16 footnote 8]. "Basic classes such as intervals on the line are impossible to learn in these harsh online formulations" [read in source: GKKM20 §2; the same in KK21a §1.4].
* In the adversarial model "the error bounds can be as large as the size of the domain" [read in source: GHMS23 §1.2].

### 3.2 The exact characterisation, and the "KWIK dimension"

**I did not find a quantity called "KWIK dimension".** A web search for the phrase returned only the KWIK papers, and none of the restatements I read defines one [read in source: web search result; and Bal15, ZC16, JKMR16, LHS13, GHMS23]. I could not open LLWS11 itself, so I cannot exclude that it uses the term. The exact characterisations that I did find are these.

* **The extended Littlestone dimension** [read in source: ZC16 Definitions 2–3, Theorem 2]. ELdim(H, k) is the largest m for which there is a (k, m)-difficult extended mistake tree: a tree of inputs, with a "mistake" edge to each child and one "abstention" edge, every root-to-leaf path consistent with some h ∈ H, such that every path using at most k mistake edges has length at least m. If ELdim(H, k) = m, the algorithm SOA.DK makes at most k mistakes and at most m mistakes-plus-abstentions on every H-realizable sequence, and no deterministic algorithm achieves m − 1. "When k = 0, this is exactly the KWIK model."
* **For k = 0 this is the combinatorial eluder dimension** [my own derivation]. For f* ∈ H let Edim_{f*}(H) be the largest m for which there are (x_1, f_1), …, (x_m, f_m) with f_i ∈ H, f_i(x_i) ≠ f*(x_i) and f_i(x_j) = f*(x_j) for all j < i (the definition is from LKFS21, Definition 4). Then the least worst-case number of abstentions of a deterministic learner that is never wrong on H is sup_{f*} Edim_{f*}(H).
  *Proof.* Lower bound: show x_1, …, x_m labelled by f*. If the learner has abstained at all j < i, it has seen exactly the labels f*(x_j), j < i; these are also the labels under the target f_i, so its output at x_i is the same under both targets, and they differ at x_i; a learner that is never wrong must abstain. By induction it abstains m times. Upper bound: the enumeration learner abstains at x_t only if some f_t in the current version space differs from f* at x_t; f_t agrees with f* at all earlier abstention rounds; so the abstention rounds form such a sequence. ∎
* **Eluder dimension against star number and threshold dimension** [read in source: LKFS21 Definition 4, Proposition 1, Proposition 2, Theorem 8]. The star number Sdim_{f*}(H) is defined like Edim_{f*} but with "for all j ≠ i"; the threshold dimension Tdim_{f*}(H) with "f_i(x_k) ≠ f*(x_k) for all k ≥ i and f_i(x_j) = f*(x_j) for all j < i". Then

      max{Sdim_{f*}, Tdim_{f*}} ≤ Edim_{f*} ≤ 4^max{Sdim_{f*}, Tdim_{f*}},   and   Sdim_{f*} ≤ Edim_{f*} ≤ min{|X|, |H| − 1}.

  For the thresholds on n points the star number is 2 and the eluder dimension is n; for the n single-point indicators with the zero function both are n. So the lower bound is attained; the upper bound cannot be improved to a polynomial in the star number and the threshold dimension (their Theorem 9). Also ⌊log Tdim_{f*}⌋ ≤ Ldim ≤ 2^Tdim_{f*} (LKFS21 §5, citing Shelah and Hodges).

So a class is learnable with zero mistakes on adversarial sequences if and only if both its star number and its threshold dimension are finite: it must contain neither many single-point patches of one function nor a long chain of thresholds. [my own derivation, from the two items above]

### 3.3 The i.i.d. version: reliable and probably useful learning, perfect selective classification

**Model** [read in source: restated in HKLM20 §1.1.3, HKL19 §1, GE19 §2]. The learner sees m labelled examples drawn i.i.d. from a distribution over X labelled by f ∈ H, and outputs a selective classifier (h, g): it predicts h(x) if g(x) = 1 and abstains otherwise. It must make no error on any point where it predicts; its quality is its coverage Φ = Pr_μ[g(X) = 1]. Rivest and Sloan (1988) called this "reliable and probably useful" (RPU) learning; El-Yaniv and Wiener (2010) "perfect selective classification"; Kane, Lovett, Moran and Zhang (2017) "confident" learning. (The word "reliable" is also used for a different model, one-sided agnostic noise; see §5.2.)

**The consistent selective strategy (CSS)**: predict at x if and only if all hypotheses consistent with the sample agree at x.

* *Optimality* [read in source: restated in Bal15 Proposition 3.2 as "Thm. 7, EYW10"; also GHMS23 §4.2]. "In the realizable case, any classifier which has zero error with certainty on any D with any h* satisfies the following condition: if it predicts (a non-⊥ label) on a point x, then so does CSS."
* *Finite classes* [read in source: restated in Bal15 Proposition 3.1 as "Thm. 8, EYW10"; a search result confirms that EYW10's Theorem 8 is the coverage guarantee for CSS with a finite class]. For CSS (the survey displays the bound without its quantifier; I take it to hold with probability at least 1 − δ over the sample),

      Pr_μ(⊥) ≤ (1/m)·( (ln 2)·min(|H|, |X|) + ln(1/δ) ).

  The dependence on |H| is linear, not logarithmic. This cannot be improved in general [my own derivation]: let H be the zero function and the N singletons on N points, μ uniform, target zero. At an unseen point the data are equally consistent with a singleton target, so a never-wrong learner abstains there, and the unseen mass has expectation (1 − 1/N)^m; rejection below ε needs m ≥ N·ln(1/ε).
* *Infinite classes: coverage can be zero* [read in source: restated in Bal15 §3.2, with EYW10's figure]. For linear separators in R² and data uniform on two arcs, one all positive and one all negative, the version space is unanimous only on a set of measure zero for every finite sample: CSS "will almost surely abstain". Kalai and Kanade put it this way: "the natural idea to abstain on test points whose labels are not uniquely determined by the training data can lead to abstaining on all test points even when P = Q" [read in source: KK21b §1].
* *A data-dependent bound* [read in source: WHE15 Definition 1, Lemma 7]. Let n̂(S_m) be the version space compression set size: the size of a smallest subset of the sample that induces the same version space. With probability at least 1 − δ,

      Pr_μ( DIS(VS(S_m)) ) ≤ ( 10·n̂(S_m)·ln(em/n̂(S_m)) + 4·ln(2/δ) ) / m.

* *Disagreement coefficient* [read in source: WHE15 Definition 2, Theorems 3–4, Lemma 27]. θ(r_0) = sup_{r > r_0} Pr_μ(DIS(B(f*, r)))/r ∨ 1, where B(f*, r) is the set of hypotheses at distance at most r from f*. With probability at least 1 − δ every h in the version space after t examples has error at most r_t = (24/t)·(d·ln(880·θ(d/t)) + ln(12/δ)); hence the rejected mass of CSS is at most θ(r)·r_t for every r < r_t [the last step is my own derivation: the version space lies in B(f*, r_t)]. θ and the high-probability bound B_n̂ on n̂ determine each other up to a factor d and logarithms:

      θ(r_0) ≤ max{ max_{r ∈ (r_0,1)} 16·B_n̂(⌈1/r⌉, 1/20), 512 },      B_n̂(1/r_0, δ) ≤ c·θ(d·r_0)·( d·ln(e·θ(d·r_0)) + ln(log(2/r_0)/δ) )·log(2/r_0).

  A rejection rate O(polylog(m)/m) for CSS is equivalent to an exponential speed-up of the CAL active learner (WHE15 Corollary 10; Bal15 Proposition 4.1, restating EYW12 Theorem 9).
* *Distribution-free: the star number* [read in source: HY15 Definition 2, Theorem 10, Table 1; GHMS23 §4.2 restating Han16]. The star number s of H is the largest s such that there are x_1, …, x_s and h_0, h_1, …, h_s ∈ H with h_i and h_0 differing on x_i and on no other x_j. The supremum over distributions and targets of θ(ε) equals min(s, 1/ε); the maximum over samples of n̂ equals min(s, m). "The optimal distribution-free abstention rate for perfect selective classification is sublinear if and only if the star number is finite (in which case it is always at most s log T)." s ≥ d always, and "the gap between s and d can generally be infinite": s = 2 for thresholds on the line, s = ∞ for intervals, for linear separators in R^k (k ≥ 2) and for axis-aligned rectangles.
* *Favourable distributions* [read in source: WHE15 Theorems 11 and 13]. Linear separators in R^k under a mixture of t Gaussians with diagonal covariances: B_n̂(m, 1/20) ≤ c_{k,t}·(log m)^(k−1) (this is EYW10 Lemma 32), so by Lemma 7 the rejected mass is O((log m)^k / m) with a constant depending on k and t [my own derivation for this step]; a lower bound Ω((log m)^((k−1)/2)) on the number of labels CAL requests among m points, for some distribution of this type, is attributed to EYW12. Axis-aligned rectangles under product densities, positive class of mass at least λ: B_n̂(m, δ) ≤ (8k/λ)·ln(8k/δ).
* *The dimension is the enemy* [read in source: HKL19 §1 and §4, GKKM20 §2]. Kivinen showed that RPU-learning rectangles "required an exponential number of samples even under the uniform distribution"; label-only RPU-learning of linear separators under the uniform distribution on the ball is lower-bounded by the number of samples needed for the convex hull of the sample to have measure 1 − ε, exponential in the dimension.

### 3.4 Richer queries make never-wrong learning cheap

[read in source: KLMZ17 §1.2.2, Theorem 1.5.] If, besides labels, the learner may ask comparison queries ("which of x_1, x_2 is further on the positive side?"), the relevant quantity is the inference dimension: the least k such that in every sample of size k some point's label is determined by the label and comparison queries on the others. For half-planes in R² it is at most 7, while their star number is infinite. With inference dimension k the labels of any realizable sample of size n can be revealed with O(k·log k·log n) queries, through a "confident" learner that abstains but is never wrong. With label queries alone the inference dimension "specializes to the star dimension". Hopkins, Kane and Lovett state that, under conditions on the distribution, comparison queries allow RPU learning of linear separators "with nearly matching sample and query complexity to PAC-learning" [read in source: HKL19 §1]. The lesson for imitation: the exponential cost of never-wrong learning is a statement about what a *label* reveals; a richer observation of the target can remove it. (For a human, intermediate work is such an observation; nothing in this literature treats it.)

### 3.5 What the never-wrong rules give under shift

[my own derivation, immediate from the definitions.] The guarantee of CSS or of a KWIK learner is per input and does not mention a distribution: at *every* x, in or out of distribution, an answer is right. Shift affects only coverage: the coverage under μ′ is 1 − μ′(DIS(VS)), about which the theorems of §3.3 say nothing unless μ′ ≤ B·μ. For H_k and a target f with data on the inputs A, the disagreement region is, up to K(f) + O(1) bits, the set of inputs that a test of complexity below k separates from A (§7.5). This is the "whitelist" behaviour of `notes.md` §6.1: sound everywhere, and silent on every new kind of input.

---

## 4. A bounded number, or a bounded rate, of mistakes

### 4.1 A budget of k mistakes on adversarial sequences

[read in source: ZC16 §§2–5; SZB10's result is restated there and, with its proof, in Bal15 §2.3.] The label is revealed after every round. The learner may make at most k mistakes in total.

* *Finite classes* (SZB10): at most k mistakes and at most (k+1)·|H|^(1/(k+1)) abstentions. The algorithm predicts with the majority of the version space when the minority has at most s hypotheses and abstains otherwise; s starts at |H|^(k/(k+1)) and is lowered after each mistake. One mistake allowed: 2·√|H| abstentions. With k ≈ log |H| the bound is O(log |H|).
* *Exact value* (ZC16 Theorem 4, Corollary 1, Theorem 5): ELdim(H, k) ≤ sup{t : C(t, ≤ k+1) ≤ S(H, t)}, where S(H, t) ≤ |H| is the tree shattering coefficient and C(t, ≤ j) = Σ_{i ≤ j} C(t, i); for n thresholds this holds with equality, so the trade-off of SZB10 is tight up to constants there.
* *Relation to the Littlestone dimension* (ZC16 Theorem 3): if Ldim(H) = d < ∞ then ELdim(H, d) = d. Abstention helps only below d mistakes.
* *Infinite classes* (ZC16 Theorem 6): for unions of at most l singletons on an infinite domain, ELdim = ∞ for k ≤ l − 1 and = l for k ≥ l.
* *Non-realizable case* (ZC16 Theorems 7–10, Lemma 5). Suppose the labels agree with some h ∈ H except on at most l inputs. There is a one-element class H, on a suitable domain, for which no algorithm, deterministic or randomized, that guarantees fewer than l mistakes has a finite bound on abstentions; and there is a class of Littlestone dimension d for which the same holds below l + d mistakes. With k ≥ l mistakes allowed, every finite class needs at most e·(k+1)·|H|^(1/(k+1−l)) mistakes-plus-abstentions.
* *Linear separators with margin γ in R^d* (SZB10, restated in Bal15 Proposition 2.5): k mistakes and O(R^(1/k)·log R) abstentions with R = (1 + √d/γ)^d.

**No mistakes, but a target that is only near the class (agnostic KWIK)** [read in source: SS11 Definition 2.3, Theorems 3.1–3.5 and 4.1]. KWIK feedback (the response is seen only after a pass). The target is within sup-norm distance D of the hypothesis class, and predictions must be accurate to r·D + ε.

* Finite class, noise-free responses: predicting when the D-balls around the surviving hypotheses' values at x intersect is a (D, r = 2, ε = 0) learner with at most |H| − 1 passes (Theorem 3.1); r = 2 is the best possible factor when X is infinite (Theorem 3.2).
* Linear functions on [−X_max, X_max]^d with coefficients bounded by M: the bound becomes 2·d!·(M·X_max/ε + 1)^d (Theorem 3.3); with ε = 0 no bounded learner exists (Theorem 3.4); every learner passes at least 2^(d−1) times on some problem class (Theorem 3.5), against d passes in the realizable case. "The price of non-realizibility is quite high."
* Finite class, noise bounded by K: a pairwise-elimination learner has bound O((K²·N²/ε²)·log(N/δ)), N = |H| (Theorem 4.1).

### 4.2 Agnostic selective classification

[read in source: GE19 §§1–5; LESS is restated also in Bal15 §3.4.] Labels are noisy; f* is a best classifier in H with risk R(f*). A selective classifier is *pointwise-competitive* if, wherever it predicts, it predicts as every f* does.

* *LESS* (Wiener and El-Yaniv): take the empirical risk minimizer f̂ and the set G of hypotheses whose empirical error is within 2σ(m, δ/4, d) of it, where σ(m, δ, d) = 2·√((2d·ln(2me/d) + ln(2/δ))/m); predict f̂(x) where G is unanimous. Whether G is unanimous at x reduces to one constrained empirical risk minimization (the "disbelief principle").
* *ILESS* (GE19 Strategy 2, Lemma 3, Theorem 5). With a radius of order A/m + √(A·R̂/m), A = 4d·ln(16me/(dδ)): with probability at least 1 − δ the classifier is pointwise-competitive and its abstention rate is at most θ_{f*}(R_0)·R_0, where R_0 = 2R(f*) + 11A/m + 6·√(A·R(f*)/m).
* *Converse* (GE19 Theorem 7): if some pointwise-competitive learner has abstention rate at most polylog(m, d, 1/δ)/m for all m ≤ m_max, then θ_{f*}(r) is polylogarithmic in 1/r for r ≥ 1/m_max. So a fast rejection rate, a polylogarithmic disagreement coefficient and an exponential speed-up of disagreement-based active learning are equivalent.
* *The noise floor* (GE19 Example 1): there is a two-hypothesis class with θ ≤ 1 in which every pointwise-competitive strategy rejects mass 2R(f*). With label noise the rejection rate does not go to zero; it goes to about θ·R(f*).

### 4.3 Abstention at a cost; voting

* *Chow's rule* [from memory, not checked]: when an abstention costs α < 1/2 and the conditional law of the label is known, abstain exactly when no label has conditional probability above 1 − α (Chow 1970).
* *Weighted majority with abstention* [read in source: restated in Bal15 §3.5 as Corollary 1 of FMS04]. For a finite class, weight each h by exp(−η·(empirical error)), predict the sign of the log-ratio of the weights of the two labels at x when it exceeds a threshold, abstain otherwise. With η = ln(8|H|)·m^(1/2−θ), θ ∈ (0, 1/2): the error probability is at most 2R(h*) + Õ(m^(θ−1/2)) + δ, with no dependence on |H|, and, for m at least of order (√ln(1/δ)·ln |H|)^(1/θ), the abstention probability is at most 5R(h*) + O((√ln(1/δ) + ln |H|)/m^(1/2−θ)). The dependence on the class is logarithmic. The price is that the error is a rate under the training distribution, not zero.
* *Fast rates* [read in source: KK21b §1.3]: Bousquet and Zhivotovskiy obtain fast rates in agnostic learning with the Chow loss whenever the abstention cost is bounded away from 1/2.
* *Risk against coverage.* EYW10 also bound from below the risk that any selective classifier can have at a given coverage, in terms of d and m (their Theorem 37, restated as Bal15 Proposition 3.3). The survey's display appears to interchange coverage and abstention probability, so I do not reproduce it.

### 4.4 Why the feedback model decides the trade-off

[my own derivation.] The gain from allowing mistakes in §4.1 needs the label after every round, mistaken or not. If labels arrive only after abstentions (KWIK feedback) and inputs are adversarial, a mistake that is never revealed can be repeated for ever: with H = {f, g} differing at x, a learner that answers at x is wrong under one target and learns nothing, and the adversary shows x again. So with abstention-only feedback and adversarial inputs, a bounded number of mistakes forces abstention on the whole disagreement region, and the bounds of §3 return. A bounded *rate* of silent mistakes therefore needs one of three things:

1. labels on some answered rounds (the human stays in the loop, as in the audits of `repo.md` X3–X4 and `notes.md` Observation A);
2. a distribution over test inputs with respect to which the rate is measured, and access to it through unlabelled test inputs (§5);
3. a class with small star and threshold dimensions (§3.2).

---

## 5. Arbitrary test inputs: PQ learning and what followed

### 5.1 Goldwasser, Kalai, Kalai and Montasser (2020)

All of this subsection is [read in source: GKKM20], with their P, Q written μ, μ′. Binary labels; C has VC dimension d; realizable: the same f ∈ C labels training and test inputs ("covariate shift").

**Why both abstention and unlabelled test inputs.** "Given any classifier h, an adversary or test distribution Q may concentrate on or near an error", so without abstention nothing holds; and no selective classifier chosen without seeing the test inputs can cope with an adversary who "can simply repeat any single erroneous example they can find". "Learning such classes is impossible without unlabeled examples", even for intervals on the line.

**Definition 1.1 (PQ learning).** A learner L takes n labelled training examples and n unlabelled test examples and outputs a selective classifier h|_S (predict h on S, reject off S). L (ε, δ, n)-PQ-learns C if for all distributions μ, μ′ over X and all f ∈ C,

    Pr_{x ~ μⁿ, x̃ ~ μ′ⁿ}[ rej_μ(S) + err_μ′(h|_S) ≤ ε ] ≥ 1 − δ,

where rej_D(S) = Pr_D[x ∉ S] and err_D(h|_S) = Pr_D[h(x) ≠ f(x) and x ∈ S]. The error is measured on the *test* law and the rejection rate on the *training* law, because the test rejection rate "cannot be bound absolutely".

**The transductive (white-box) model.** The learner chooses h from the training sample. A "true" test set z ~ μⁿ is drawn. An adversary who knows x, z, f, h and the learner's code replaces any number of the z_i to form an arbitrary x̃ ∈ Xⁿ. The learner then chooses S from x, f(x) and x̃. Performance is the empirical test error err_x̃ and the false rejection rate rej_z.

**The algorithm Rejectron** (their Figure 2). h := ERM(x, y); S_1 := X. For t = 1, 2, …: choose c_t ∈ C maximizing

    s_t(c) := (fraction of test inputs in S_t on which c differs from h) − Λ·(fraction of training inputs on which c differs from h),   Λ = n + 1;

if s_t(c_t) ≤ ε, stop and output h|_{S_t}; otherwise S_{t+1} := S_t ∩ {x : c_t(x) = h(x)}. In words: look for a classifier that fits the training data as well as h does and disagrees with h on more than an ε fraction of the test inputs still answered; reject the region where it disagrees; repeat. There are at most ⌊1/ε⌋ rounds, each one call to an empirical risk minimizer (Lemma 5.1).

**Theorems.**

* *Error, with certainty* (Theorem A.2, eq. 12): for every n, ε, f ∈ C and *all* x, x̃ ∈ Xⁿ, err_x̃(h|_S) ≤ ε. The proof is one line: f itself is a candidate c with zero training disagreement, so the loop cannot stop while h|_S errs on more than εn test inputs.
* *False rejections* (Theorem A.2, eq. 13): with probability at least 1 − δ over x, z ~ μⁿ, for all x̃ ∈ Xⁿ simultaneously, rej_z(S) ≤ (1/n)·((2d/ε)·log 2n + log(1/δ)).
* *Balanced, transductive* (Theorem 5.3): with ε* = √((2d/n)·log 2n) + (1/n)·log(1/δ), Pr_{x,z ~ μⁿ}[∀ x̃ ∈ Xⁿ: err_x̃(h|_S) ≤ ε* and rej_z(S) ≤ ε*] ≥ 1 − δ.
* *Balanced, distributional* (Theorem 5.2): with ε* = √(8d·ln 2n / n) + 8·ln(16/δ)/n, Pr[err_μ′ ≤ 2ε* and rej_μ ≤ ε*] ≥ 1 − δ.
* *Trade-off* (Theorem A.5): for ε ≥ √(8d·ln 2n / n) + 8·ln(8/δ)/n, err_μ′ ≤ 2ε with probability 1 − δ; and for every ε ≥ 0, rej_μ ≤ (2/n)·((2d/ε)·log 2n + log(2/δ)) with probability 1 − δ, for all x̃. So error × rejection is about d/n.
* *Rejection on the test law* (Lemma 4.1): rej_μ′(S) ≤ rej_μ(S) + TV(μ, μ′); and for every Λ ≥ 0, Pr_{x ~ μ′}[x ∉ S and μ′(x) ≤ Λ·μ(x)] ≤ Λ·rej_μ(S). Test inputs in the region where μ′ ≤ Λμ are rarely rejected; elsewhere nothing is promised.
* *Several test laws at once* (Claim 4.2): a PQ learner run on the mixture of μ, μ′_1, …, μ′_k guarantees rej_μ + err_μ + Σ_i err_{μ′_i} ≤ ε, given a learner for ε/(k+1).
* *Unsupervised variant* (URejectron, Theorem 5.6): S is computed from the unlabelled training and test inputs alone, with the same bounds, for all f ∈ C at once; it needs an empirical risk minimizer for the class of disagreement sets of pairs in C.
* *Injected training examples*: the bounds are unchanged if an adversary adds correctly labelled examples to the training set.

**Lower bounds.**

* *Theorem 5.4*: there is K > 0 such that for every d ≥ 1 and n ≥ 2d there are a class C of VC dimension d and distributions μ, μ′ such that for every learner some f ∈ C has E[rej_μ + err_μ′] ≥ K·√(d/n). (C: functions that are 1 on exactly d integers; μ uniform on [8n]; μ′ uniform on [k], k = √(8dn). As the theorem is printed the distributions are quantified before n; in the proof they depend on n, and the authors remark on it.) The lower bound holds with unboundedly many unlabelled test examples.
* *Theorem 5.5* (transductive): E[rej_z + err_x̃] ≥ K·√(d/min{m, n}) with n training and m test examples. So Θ̃(√(d/n)) is the rate, against Θ̃(d/n) when μ′ = μ.
* *One cannot learn where μ and μ′ overlap* (Appendix G): if μ and μ′ were known, S* = {x : μ′(x) ≤ μ(x)/ε} would have rej_μ(S*) < ε and err_μ′(h|_{S*}) ≤ err_μ(h)/ε. But "one cannot even distinguish the case where P = Q from the case where P and Q have disjoint supports with fewer than Ω(√|X|) examples". Rejectron avoids estimating the density ratio: it only detects differences that members of C can express.

**Beyond realizability.**

* *Massart noise* (rate η(x) ≤ η < 1/2, Corollary C.4): Rejectron is a PQ learner given an additional Õ(d·n²/(δ²(1 − 2η)²)) examples from μ.
* *Semi-agnostic* (Lemma D.1, Theorem D.2). Assume some f ∈ C has error at most η on the training law and at most η̃ on the test law, η and η̃ known. Lower bound: there is a class of VC dimension 1 such that for every learner and all η, η̃ ≤ 1/2, E[err_μ̃ + rej_μ] ≥ max{√(η/8), η̃}. Upper bound: Rejectron with Λ* = (8η + ε*²)^(−1/2) has err_μ̃ ≤ 2·√(2η) + 2η̃ + 4ε* and rej_μ ≤ 4·√(2η) + 4ε*, with ε* = 4·√((d·ln 2n + ln(48/δ))/n). A fraction η of unexplained training labels costs √η, not η.

### 5.2 Kalai and Kanade, "Efficient learning with arbitrary covariate shift"

[read in source: KK21a.] Definition 1 restates PQ learning with separate conditions err_μ′(h; f) ≤ ε and rej_μ(h) ≤ ε. *Reliable learning* (Kalai, Kanade and Mansour 2012) is agnostic learning with one-sided error: a positive reliable learner outputs h with false-positive rate at most ε and false-negative rate at most opt₊ + ε, where opt₊ is the least false-negative rate among members of C with no false positives.

* **Theorem 1**: if C is reliably learnable then C is PQ-learnable (the "Slice-and-Dice" algorithm). **Theorem 2**: if C is PQ-learnable then C is reliably learnable. Running times and sample sizes are polynomially related.
* The paper is about computation: "ignoring computation, the number of examples required for learning in all these models was known to be polynomially related to d". Parities are PQ-learnable (Lemma 2); PQ-learning conjunctions would give PAC learning of DNF formulas (Lemma 3 with Theorem 2). So PQ learning sits between PAC and agnostic learning.
* A warning used in §9: rejecting what a distinguisher in C can tell apart from the training inputs is not enough. For homogeneous half-planes with μ on {u, −u} and μ′ on {u, −u, v, −v}, no half-plane separates ±v from ±u, yet ±v must be rejected.

### 5.3 Kalai and Kanade, "Towards optimally abstaining from prediction with OOD test examples"

[read in source: KK21b.] An abstention costs α; a prediction ŷ costs ℓ(y, ŷ) (Chow's model). The learner has n labelled training examples x̄ and n unlabelled test examples x, fits h, and chooses abstention probabilities a ∈ [0,1]ⁿ. Its loss on the test set is ℓ_x(f, h, a) = (1/n)·Σ_i [a_i·α + (1 − a_i)·ℓ(f(x_i), h(x_i))].

**The principle (MMA, "min-max abstention").** Let V be the version space. Choose a to minimize the worst-case test loss, min_a max_{g ∈ V} ℓ_x(g, h, a). "A key insight is that [this] has no unknowns, so MMA will achieve a max … as low as if it knew P, Q and even f."

**Two lemmas that hold for any output space, any loss ℓ ≥ 0, any family F, any V ⊆ F containing f, and any h.** Write L_x(V, h, A) = max_{g ∈ V} ℓ_x(g, h, A) for an abstention set A ⊆ [n], and L_z(V, h) for the same with no abstentions.

* **Lemma 1 (adversarial).** For all z, x ∈ Xⁿ and every minimizer A* of L_x(V, h, ·): ℓ_x(f, h, A*) ≤ (α/n)·|{i : x_i ≠ z_i}| + L_z(V, h). [I checked the proof; it is two lines: compare A* with the set of changed indices, and use f ∈ V.]
* **Lemma 2 (covariate shift).** For all distributions μ, μ′: E_{x ~ μ′ⁿ}[ℓ_x(f, h, A*)] ≤ min_{k ≥ 1} { α·D_k(μ‖μ′) + k·E_{z ~ μⁿ}[L_z(V, h)] } ≤ α·TV(μ, μ′) + E_{z ~ μⁿ}[L_z(V, h)], where D_k(μ‖μ′) = Σ_x max(μ′(x) − k·μ(x), 0), so D_1 is the total variation distance and D_k = 0 when μ′ ≤ k·μ.

The second term, E_z L_z(V, h), is the ordinary quantity "worst consistent hypothesis on a fresh sample from the training law"; the first is the price of the part of the test law that the training law does not cover.

**Theorems for classification** (0–1 loss, VC dimension d, h an empirical risk minimizer, â computed in polynomial time with an ERM oracle).

* **Theorem 1**: E_{x̄ ~ μⁿ, x ~ μ′ⁿ}[ℓ_x(f, h, â)] ≤ α·TV(μ, μ′) + 2d·log(3n)/n.
* **Theorem 2** (future test examples): the same with min_{k ≥ 1}{α·D_k(μ‖μ′) + 2dk·log(3n)/n}. To decide on a new test input, run MMA on the test set with that input substituted for one element (Appendix B).
* **Theorem 3** (adversarial): with probability at least 1 − δ over x̄, z ~ μⁿ, for all x ∈ Xⁿ: ℓ_x(f, h, â) ≤ (α/n)·|{i : x_i ≠ z_i}| + (2d·log 2n + log(1/δ))/n.
* **Theorem 4** (linear regression, noisy labels with E[y|x] = w·x, squared loss against the conditional mean): E[ℓ_x(f, h, â)] ≤ α·TV(μ, μ′) + κ·log n/√n.
* **Lemma 8**: the classification bounds are in expectation for a reason: with X = {1, 2}, μ on {1} and μ′ uniform, every algorithm has loss at least α·TV + α/√n with constant probability.
* **Against PQ learning** (Appendix C): the PQ bound implies loss ≤ α·TV + Õ(√(d/n)); MMA improves the second term to Õ(d/n), and implies E[err_μ′ + rej_μ] ≤ Õ(√(d/n)). The √(d/n) of PQ learning comes from the region where μ is about √(d/n)·μ′, where PQ learning must either reject or err; a cost model does not have to decide.

**Why this works where "abstain on the disagreement region" does not** [my own derivation: an interpretation]. The never-wrong rule controls max over g ∈ V *at each test input*, which costs the star number. MMA and Rejectron control, for each g ∈ V, its *average* disagreement with h *over the test set*, which is a uniform-convergence quantity and costs only the VC dimension. The average over the test set is why the test inputs must be known in advance.

### 5.4 The online version: Goel, Hanneke, Moran and Shetty (2023)

[read in source: GHMS23.] An i.i.d. stream from μ with target f ∈ F; before each round an adversary may replace the input by an arbitrary one ("clean-label injection"; the label is still f's). The learner predicts or abstains, then sees the label. Error = (number of wrong predictions on any round) + (number of abstentions on non-injected rounds). Abstaining on injected rounds is free.

* The disagreement-based learner has no misclassifications and, for thresholds, at most 2·log T abstentions on i.i.d. rounds (Proposition 4.1); for general classes it is governed by the star number (§3.3) and is useless for, say, unions of two intervals.
* **Theorem 5.1** (μ known): for VC dimension d, an algorithm based on the probability that k fresh points are shattered by the version space has E[misclassifications] ≤ d²·log T and E[abstentions on i.i.d. rounds] ≤ 6d.
* **Theorems 6.1, 6.7** (μ unknown): for VC dimension 1, E[misclassifications] ≤ 2·√(T log T) and E[abstentions] ≤ √(T log T); for axis-aligned rectangles in R^p, O(√(pT log T)) each.
* The label is revealed after every round in this model; the authors mention the variant without labels on abstention rounds as a direction. They left open general VC classes with unknown μ (their §7). Two papers of February 2026, to which `ask-for-help.md` §2.8 pointed me, settle much of it.
* **Yu and Blanchard (2026)** [read in source: YB26 Theorems 2–3, Remark 4]. μ unknown, oblivious adversary, VC dimension d: for every α ∈ [0, 1/3] an algorithm (AbstainBoost) has misclassifications ≲ T^(3α) and E[abstentions on i.i.d. rounds] ≲ d²·log^(5/3)(T)·T^(1−α). Lower bound: there is a class of VC dimension 1 such that for every T, every learner and every α ∈ [0, 1], some oblivious adversary forces E[misclassifications] ≥ T^α/32 or E[abstentions] ≥ T^(1−α)/2.
* **Edelman and Goel (2026)** [read in source: EG26 Theorems 1.1–1.3, 3.1]. There is a class of VC dimension 1 for which every learner without access to μ has expected combined error Ω(√T). Classes of inference dimension k (§3.4) have combined error Õ(T^(1−1/k)); half-planes in R² have Õ(T^(2/3)).
* So in the online model the polylogarithmic bounds need knowledge of the clean input distribution. Without it, for that class of VC dimension 1, (worst-case expected misclassifications) × (worst-case expected abstentions on clean rounds) ≥ T/64, even with every label shown [my own derivation from YB26 Theorem 3: choose α with T^α just above 32 times the first quantity; `ask-for-help.md` §2.8 states the same].

### 5.5 Abstaining on the whole test distribution

[read in source: arXiv abstracts of KSV24 and GSSV24 only.] In *testable learning with distribution shift* (TDS; Klivans, Stavropoulos and Vasilyan 2024) the learner gets labelled samples from the training law and unlabelled samples from the test law and runs a test: if the test accepts, the classifier has low test error; if the two input laws are equal, the test accepts. Efficient algorithms are given for half-spaces, intersections of half-spaces and decision trees under Gaussian or uniform training inputs. Goel, Shetty, Stavropoulos and Vasilyan (2024) note that earlier TDS algorithms "end up abstaining entirely even in the presence of a tiny amount of distribution shift", give tolerant versions, and give efficient PQ learners for the same classes.

### 5.6 Asking for help instead of abstaining

Abstract-level reading only, unless stated.

* Plaut, Zhu and Russell (2024) [read in source: PZR24 abstract and theorem statements]: online learning where each round's payoff is the chance of avoiding catastrophe and the agent may query a mentor. In general "any algorithm either queries the mentor at a linear rate or is nearly guaranteed to cause catastrophe". If the mentor's policy class has finite VC dimension and inputs are σ-smooth, or has finite Littlestone dimension, and nearby inputs have nearby payoffs (Lipschitz constant L), regret tends to 0 with a number of queries of order T^((4n+1)/(4n+2)) (n the input dimension).
* Cohen and Hutter (2020) [read in source: CH20 abstract]: a Bayesian reinforcement learner over a countable class of world-models that maximizes the worst case over the models with enough posterior weight, and defers to a mentor with a probability that tends to 0; with probability 1 − δ it causes no "unprecedented event".
* Kosoy (2019) [read in source: Kos19 abstract]: a regret bound for reinforcement learning with traps when the agent may delegate actions to an advisor; finitely many hypotheses, states and actions.
* Sekhari, Sridharan, Sun and Wu (2023) [read in source: arXiv abstract of SSSW23]: imitation learning with selective queries to a noisy expert; the regret is bounded by that of an online regression oracle and "the query complexity additionally depends on the eluder dimension of the model class", with a matching lower bound.
* Hanneke and Yang (2021) [read in source: HY21 §1, Theorems 3–4]. An i.i.d. stream, realizable, VC dimension d, star number s. The learner predicts every round (no abstention) and sees a label only when it asks. M_T and Q_T are the expected numbers of mistakes and queries in T rounds, in the worst case over distributions and targets. For every budget q_T ≤ T some variant of CAL has Q_T ≤ q_T and M_T ≲ d·log T + (dT/q_T)·1[q_T < s·ln(eT)]; and every algorithm has M_T ≳ min{d, T} + (T/Q_T)·1[Q_T < s/16]. So below about s queries, (silent mistakes) × (queries) is of order T, and only at about s queries does the mistake count drop to d·log T. For H_k this threshold is about 2^k (§7.2).
* Cohen, Hutter and Nanda (2022) is treated in §8.3.

---

## 6. Conformal prediction and shift

Conformal methods output a set Ĉ(x) ⊆ Y. The set Y itself is an abstention; a small set is a confident answer. The labels may be stochastic and Y arbitrary, and nothing is assumed about the conditional law of Y given X: in the terms of this digest, the hypothesis class is "all samplers".

### 6.1 Exchangeable data

[read in source: TBCR19 §1; BCRT21 Theorem 1, citing Papadopoulos et al. 2002.] If (X_i, Y_i), i ≤ n + 1, are exchangeable, the (split) conformal set built from any score function satisfies Pr[Y_{n+1} ∈ Ĉ_n(X_{n+1})] ≥ 1 − α, for every distribution. The probability is over the calibration data and the test point: coverage is *marginal*.

### 6.2 Covariate shift with a known likelihood ratio

[read in source: TBCR19 §2, Corollary 1.] Training pairs i.i.d. from μ × P(·|x); one test pair from μ′ × P(·|x), with μ′ absolutely continuous with respect to μ and w = dμ′/dμ known up to a constant. Weight the calibration scores: p_i^w(x) = w(X_i)/(Σ_j w(X_j) + w(x)) for i ≤ n, and p_{n+1}^w(x) = w(x)/(Σ_j w(X_j) + w(x)) on the value +∞; let Ĉ_n(x) be the set of y whose score is at most the (1 − α)-quantile of this weighted distribution. Then Pr[Y_{n+1} ∈ Ĉ_n(X_{n+1})] ≥ 1 − α.

* *It abstains by itself* [my own derivation from the definition]. If p_{n+1}^w(x) > α, that is w(x) > (α/(1 − α))·Σ_j w(X_j), the quantile is +∞ and Ĉ_n(x) = Y. So the method returns the trivial set at inputs whose likelihood ratio exceeds about αn times its average, and in particular wherever μ has no mass.
* *Estimated ratio* [read in source: LC21 Proposition 1]. With an estimate ŵ in place of w, coverage is at least 1 − α − Δ_w, where Δ_w = (1/2)·E_{X ~ μ}|ŵ(X) − w(X)|; with ŵ = w the guarantee holds "without any further assumption", the interval being the whole line where ŵ = ∞. Tibshirani et al. propose estimating w with a classifier that distinguishes unlabelled training from unlabelled test inputs. In general the ratio cannot be estimated from samples (§5.1, Appendix G of GKKM20).

### 6.3 The limits: conditional coverage, and all bounded shifts

[read in source: BCRT21.]

* **Proposition 1** (rephrased from Vovk 2012 and Lei–Wasserman 2014): if a method has distribution-free conditional coverage, Pr[Y_{n+1} ∈ Ĉ_n(X_{n+1}) | X_{n+1} = x] ≥ 1 − α for all distributions and almost all x, then for every distribution E[leb(Ĉ_n(x))] = ∞ at almost every x that is not an atom of the input law.
* **Approximate conditional coverage.** Ĉ_n satisfies (1 − α, δ)-CC if Pr[Y_{n+1} ∈ Ĉ_n(X_{n+1}) | X_{n+1} ∈ 𝒳] ≥ 1 − α for all distributions and all sets 𝒳 with input-law mass at least δ. **Lemma 1**: marginal coverage at level 1 − αδ implies (1 − α, δ)-CC. **Theorem 2**: this is essentially the only way: if Ĉ_n satisfies (1 − α, δ)-CC then for every distribution whose input law has no atoms,

      E[leb(Ĉ_n(X_{n+1}))] ≥ inf_{c ∈ [0,1]} ((1 − α)/(1 − cα))·L_P(1 − cαδ),

  where L_P(1 − β) is the least expected length of a set with marginal coverage 1 − β under the true distribution.
* **This is a statement about covariate shift** [my own derivation]. For an input law μ without atoms, (1 − α, δ)-CC is equivalent to coverage at least 1 − α under every test input law μ′ with dμ′/dμ ≤ 1/δ. (One direction: conditioning on a set of mass ≥ δ is such a shift. The other: miscoverage under μ′ is linear in the density q = dμ′/dμ; over the convex set {0 ≤ q ≤ 1/δ, ∫q dμ = 1} a linear functional is maximized at an extreme point, and for atomless μ the extreme points are (1/δ)·1_A with μ(A) = δ.) So Theorem 2 says: a model-free method that keeps its coverage under every shift with density ratio at most B = 1/δ can do no better than run at miscoverage α/B. The factor B in the lead's S1 (Theorem C of version 1) and in `notes.md` Observation D cannot be removed without assuming something about the class of samplers.
* **Restricting the sets** (Theorems 3–4): coverage conditional on every set of mass ≥ δ in a class 𝒳 of sets is achievable for any 𝒳, but if the VC dimension of 𝒳 is at least 2n + 2 the lower bound of Theorem 2 applies again (for the exchangeable form of the property).

### 6.4 What can be had without the likelihood ratio

* **A finite-dimensional family of shifts** [read in source: GCC23 Theorem 2, Corollary 1]. Conditional coverage is equivalent to E[f(X_{n+1})·(1{Y_{n+1} ∈ Ĉ} − (1 − α))] = 0 for all measurable f; relax "all f" to a class F. For F = {Φ(·)ᵀβ : β ∈ R^d}, a quantile regression over F on the scores gives, for every non-negative f ∈ F, coverage at least 1 − α when the test input is drawn from the law tilted by f; and if the scores are continuous the two-sided error is at most (d/(n+1))·E[max_i |f(X_i)|]. With F spanned by the indicators of finitely many groups 𝒢 this is coverage in every group, exact up to |𝒢|/((n+1)·Pr(G)). So: exact robustness to an unknown shift, provided its density ratio lies in a known d-dimensional family.
* **A ball of distributions** [read in source: CGAD24 Theorem 1, Corollaries 2.1–2.3]. If the test law of the scores is within f-divergence ρ of the training law, a quantile at a level raised according to (f, ρ) restores coverage; for total variation, if 2·TV ≤ ρ, the level 1 − α + ρ/2 gives coverage at least 1 − α − 1/n. The radius must be known or assumed.
* **Unknown, arbitrary shift** [read in source: BCRT23 Theorem 2, Lemma 1]. Without any correction, coverage is at least 1 − α − Σ_i w̃_i·d_TV(R(Z), R(Z^i)), where Z^i swaps the test point with the i-th calibration point, R is the vector of scores and w̃_i are normalized weights; for independent points the gap is at most 2·Σ_i w̃_i·d_TV(Z_i, Z_{n+1}). Coverage is lost silently, in proportion to the distance.
* **Arbitrary sequences, with the label after every round** [read in source: GC21 Lemma 4.1, Proposition 4.1]. Adaptive conformal inference updates the working level by α_{t+1} = α_t + γ·(α − err_t), where err_t indicates miscoverage at time t. For *every* sequence, with probability one, |(1/T)·Σ_{t ≤ T} err_t − α| ≤ (max{α_1, 1 − α_1} + γ)/(Tγ). This is a statement about a long-run frequency, obtained by alternating over- and under-coverage; it identifies no round as safe; and it needs every label.

### 6.5 Summary for this problem

[my own derivation: an interpretation.] Conformal prediction is the only tool in this digest that needs no realizability assumption, and that is also why it cannot survive shift: its "class" is everything. It gives a guarantee under shift exactly when the shift is brought back to exchangeability, by a known likelihood ratio, by a small known family of ratios, or by drawing the calibration inputs from the deployment distribution itself. The last is what random audits do (`notes.md` Observation A; `repo.md` X3–X4): a uniformly random subset of a batch of deployment inputs is exchangeable with the rest of the batch.

---

## 7. Does any of this work for a universal (Solomonoff-type) class?

### 7.1 Not as stated, and why

Every theorem in §§3–5 is about a fixed class with a finite dimension. For the class of all total computable functions:

* the VC dimension is infinite, so no uniform convergence, and the PQ and MMA bounds are void;
* the star number and the Littlestone dimension are infinite, so the never-wrong bounds are void;
* worse, the version space after any data D contains, for every unlabelled x and every label, a consistent function with that label at x (a patch). So the disagreement region is everything unlabelled, and by the optimality of CSS (§3.3) **a learner that is never wrong for every computable target never answers an unlabelled input**. [my own derivation; it is the lead's N1 with item 5 of the draft's §0, Theorem D(c) of version 1.]

The theorems are rescued in three ways, which the literature has in the forms below.

1. *A complexity budget.* Fix k and work in H_k. This is a finite class, so every result for finite classes applies; soundness then holds for targets with K(f) ≤ k and for no others.
2. *A prior.* Replace |H| by 1/w(target) and log |H| by ln(1/w(target)). The Bayes-mixture results of §7.3 are of this kind. Soundness needs a lower bound on w(target).
3. *Non-uniform statements*: for each target there is a sample size after which the guarantee holds, not known in advance (§8.5 has examples for generation).

In all three the assumption "the target is simple enough" does the work that "f ∈ C" does in the fixed-class theorems. It can be refuted by data (the version space becomes empty, or the posterior weight of everything in the budget collapses), and it cannot be confirmed.

### 7.2 The class H_k: VC dimension about k, star number about 2^k

[my own derivation; elementary counting with the conventions of `ultranatural/note.md` §1. In this subsection the functions are binary-valued.]

* |H_k| ≤ 2^k, so VC(H_k) ≤ k and every star set has at most 2^k − 1 points.
* H_k contains every function that is an arbitrary bit pattern on the first m strings and 0 elsewhere, for m ≤ k − 2 log k − c. So VC(H_k) ≥ k − 2 log k − c.
* H_k contains the zero function and the indicator of each single string x with K(x) ≤ k − c, and there are at least 2^(k − 2 log k − c) such strings. These form a star set centred at the zero function. So the star number of H_k, and with it the eluder dimension, is at least 2^(k − 2 log k − c). The same holds around any f with K(f) ≤ k − j, with 2^(j − 2 log j − c) single-point patches.

Consequences, one per model:

| guarantee | cost in H_k | from |
|---|---|---|
| error ε on the training law, no abstention | about (k·ln 2 + ln(1/δ))/ε examples | Occam's razor (`repo.md` B1) |
| never wrong, adversarial order (KWIK) | at most 2^k − 1 abstentions; at least 2^(k − 2 log k − c), even when the target is the zero function | enumeration (§3.1); eluder ≥ star (§3.2) |
| never wrong, i.i.d. (CSS) | rejected mass at most ((ln 2)·2^k + ln(1/δ))/m; for μ uniform on N = 2^(k − 2 log k − c) strings and target zero, at least (1 − 1/N)^m in expectation | EYW10 Theorem 8; the singleton example of §3.3 |
| at most j mistakes, label after every round | at most (j+1)·2^(k/(j+1)) abstentions; with j = k, at most 2(k+1) | SZB10 (§4.1) |
| at most an ε fraction wrong on an arbitrary test batch (Rejectron over H_k) | error ≤ ε on every batch; false rejection rate at most (1/n)·(2k/ε + log(1/δ)); balanced at about √(2k/n) | GKKM20 Theorem A.2, with |C|^(T+1) ≤ 2^(2k/ε) in place of Sauer's lemma in their Lemmas E.1 and B.3 |
| cost α per abstention on an arbitrary test batch (MMA over H_k) | expected loss at most α·TV(μ, μ′) + O(k/n) | KK21b Lemma 2; a consistent g errs on a fresh n-sample at rate above ε with probability at most 2^k·2^(−εn) |

So for a universal class with a budget, the two soundness notions separate exponentially: **per-input soundness costs about 2^k, batch-rate soundness costs about k/ε².** The cost of the first is set by the budget k, not by K(f): a learner that is sound for all of H_k abstains 2^(k − 2 log k − c) times even on the simplest target. Both need unbounded computation plus a halting oracle, or time bounds, to search H_k.

The threshold rule of `repo.md` X2 and the novelty rule of `notes.md` Observation B are the enumeration algorithm for a budget; the table says their exponent cannot be improved for the never-wrong standard, and that the standard, not the rule, is what is expensive.

### 7.3 Bayes mixtures that know what they know

**Lattimore, Hutter and Sunehag (2013)** [read in source: LHS13]. Sequence prediction: a countable class 𝓜 of measures on infinite sequences over a countable alphabet, prior w, Bayes mixture ξ, true measure μ* ∈ 𝓜 (their μ). h_t and d_t are the squared Hellinger distance and the KL divergence between the predictive distributions of μ* and ξ at time t; c_t = Σ_ν w_ν(ω_{<t})·KL(ν‖ξ) at time t is the posterior-expected information gain, computable without knowing μ*.

* *Known* (Theorems 1–2): E Σ_t h_t ≤ E Σ_t d_t ≤ ln(1/w_{μ*}); with probability 1 − δ, Σ_t h_t ≤ ln(1/w_{μ*}) + 2·ln(1/δ).
* *New concentration* (Theorem 3, Proposition 4): with probability 1 − δ, Σ_t d_t ≤ e·ln(6/δ)·(ln(2/δ) + ln(1/w_{μ*})), and this is nearly tight.
* *Confidence bounds* (Theorem 8). Let 𝓜_t be the set of ν whose posterior weight has been at least δ·w_{μ*} at all times up to t, d̂_t = c_t/(w_{μ*}·δ) and ĥ_t = sup_{ν ∈ 𝓜_t} (w_ν/w_{μ*})·h_t(ν, ξ). Then Pr[∀t: d_t ≤ d̂_t] ≥ 1 − δ and Pr[∀t: h_t ≤ ĥ_t] ≥ 1 − δ.
* *They are not vacuous* (Theorems 5, 9, 10). If the prior has finite entropy Ent(w): E Σ_t c_t ≤ Ent(w)/w_{μ*}; E Σ_t d̂_t ≤ Ent(w)/(δ·w_{μ*}²); E Σ_t ĥ_t ≤ (2/w_{μ*})·(ln(1/w_{μ*}) + ln(1/δ) + Ent(w)); with probability 1 − δ, Σ_t ĥ_t ≤ (2/w_{μ*})·(2·ln(1/w_{μ*}) + 5·ln(1/δ) + 3·Ent(w)). For K models with uniform prior: Σ ĥ_t is of order K·(ln K + ln(1/δ)) and E Σ c_t ≤ 6 ln²K + 14 ln K + 8 (Theorem 6).
* *KWIK* (Theorem 12): for |𝓜| = K, the rule "output ξ's prediction if ĥ_t ≤ ε, else ⊥" fails with probability at most δ and outputs ⊥ at most O((K/ε)·ln(K/δ)) times; in total variation with accuracy ε_1, O((K/ε_1²)·ln(K/δ)), matching the k-meteorologists bound. (In their version the next symbol is observed every round.)
* *What they say about the countable case* (§6): the bound "is a worst-case bound that is only achieved when at each time-step only one model differs from ξ"; ĥ_t depends on w_{μ*}, "which is also typically unknown. Either choose a conservatively small w and pay the (1/w)·ln(1/w) price, or decrease w with t at some slow rate".

**The same certificate for samplers with chosen inputs, at every input** [my own derivation, after LHS13 Theorem 8]. Let H be a countable class of samplers with prior w, P ∈ H, data D_t = ((x_i, y_i))_{i ≤ t} with each x_i chosen by any rule from D_{i−1} and independent randomness and y_i ~ P(·|x_i) fresh. Let w_t be the posterior, M_t(·|x) the predictive, and for every x ∈ X

    c_t(x) = Σ_ν w_t(ν)·KL(ν(·|x) ‖ M_t(·|x)),      s_t(x) = Σ_ν w_t(ν)·TV(ν(·|x), M_t(·|x)).

Then with probability at least 1 − δ, simultaneously for all t and **all x ∈ X**,

    KL(P(·|x) ‖ M_t(·|x)) ≤ c_t(x)/(δ·w(P))   and   TV(P(·|x), M_t(·|x)) ≤ s_t(x)/(δ·w(P)).

*Proof.* Z_t = M(D_t)/P(D_t) is a non-negative supermartingale under P with Z_0 = 1, for every input rule. By Ville's inequality Pr[∃t: Z_t ≥ 1/δ] ≤ δ. Off that event w_t(P) = w(P)/Z_t > δ·w(P) for all t, and c_t(x) ≥ w_t(P)·KL(P(·|x) ‖ M_t(·|x)) because every term of the sum is non-negative; likewise for s_t. The event does not involve x. ∎

So "answer with M_t(·|x) when s_t(x) ≤ ε·δ·w_0, abstain otherwise" is, with probability 1 − δ, ε-accurate in total variation at every answered input, under any shift whatever, for every target with w(P) ≥ w_0. Three remarks.

* *Price on the training distribution* [my own derivation for the first claim]. Under the mixture, Σ_t c_t(x_t) over the training rounds has expectation equal to the mutual information between the hypothesis and the data, at most Ent(w), for any input rule; and Pr_P ≤ Pr_w/w(P). So E_P Σ_t c_t(x_t) ≤ Ent(w)/w(P), as in LHS13 Theorem 5, and the expected number of training rounds at which the KL certificate c_t(x_t)/(δ·w_0) exceeds ε is at most Ent(w)/(ε·δ·w_0·w(P)): about 4^K. LHS13's Hellinger certificate ĥ_t does better in the sequence setting, about (1/w)·(ln(1/w) + Ent(w)), that is 2^K up to polynomial factors; I did not re-derive it for chosen inputs.
* *Price off it* [my own derivation, rough]. At an input x that a set Q separates from the inputs seen, guards keep relative posterior weight about 2^(−K(Q)−c) (`repo.md` D1), so s_t(x) is at least about 2^(−sep(x; A)−c) when the predictive is confident. The rule therefore abstains unless sep(x; A) exceeds about log(1/w_0) + log(1/(εδ)): it answers only inputs that no test simpler than the budget separates from the data.
* *The universal prior has infinite entropy* [my own derivation]. For w(ν) = 2^(−K(ν)), Ent(w) = Σ_ν 2^(−K(ν))·K(ν) = ∞: the class contains, say, the constant samplers ν_n, 2^(−K(n)) dominates the computable distribution p(n) ∝ 1/(n·log² n), which has infinite entropy, and −t·log t is increasing near 0. So LHS13's bounds with Ent(w) are void for the plain universal prior. A steeper prior, w(ν) ∝ 2^(−λK(ν)) with λ > 1 or 2^(−K(ν))/K(ν)², has finite entropy. This is a second reason, besides the model–randomness split of this repository's Paper 2, to prefer a steeper prior, and it resembles the summability condition in the lead's Theorem B.

**Why 1/w and not ln(1/w).** Cohen, Hutter and Nanda remark: "Error bounds in Bayesian prediction and MAP prediction tend to be Θ(log(w(truth)⁻¹)) and Θ(w(truth)⁻¹) respectively, so theoretically, our case resembles the MAP one" [read in source: CHN22 §6]. A mixture pays ln(1/w) in *loss* without knowing where it pays; a rule that must *certify* each answer has to wait for every alternative that is still as plausible as the truth might be, and there can be 1/w of them, each wrong at a different place. That is the star set again.

**Hypotheses that abstain** [from memory, not checked]. In the "specialists" (sleeping experts) setting of Freund, Schapire, Singer and Warmuth (STOC 1997), experts may abstain on some rounds, and the mixture's regret against each specialist, counted on the rounds where that specialist is awake, is at most ln(1/w(specialist)). A universal class of partial predictors therefore has, for each member, a loss bound restricted to that member's own domain. I mention it because programs that do not halt on some inputs are such specialists; I did not look for a published treatment of that.

### 7.4 The prior-averaged guarantee is free, at every input

[my own derivation; standard Bayes.] Suppose the target is drawn from the prior w, data D are gathered by any rule that depends on the target only through the labels seen, and a test input x is chosen by any rule from D and independent randomness. Then, given D and x, the label f(x) (or the law P(·|x)) is distributed according to the posterior. Hence:

* for deterministic targets, "answer argmax_y M_D(y|x) when it exceeds 1 − c, else abstain" errs on an answered input with conditional probability at most c, at every x, however far from the data;
* for samplers, the triple (D, x, a draw from M_D(·|x)) has exactly the joint law of (D, x, a draw from P(·|x)); and E[TV(P(·|x), M_D(·|x)) | D, x] = s_D(x), the posterior spread of §7.3.

The posterior is calibrated out of distribution on average over the prior. What fails out of distribution is the statement for one fixed target: Pr_f(E) ≤ Pr_w(E)/w(f) is the only general conversion, and it turns c into c/w(f). This is where the 2^K comes from in every certificate above. It is the counterpart of the grue theorem of `ultranatural/note.md`: a prior-averaged statement about an unseen kind of input is a statement about the reference machine as much as about the target.

### 7.5 The link with separation complexity, and when the exponential disappears

* **The disagreement region of a budget class is a separation-complexity ball** [my own derivation from `ultranatural/note.md` §1 and Theorem 1]. For f ⊇ D with inputs A: every x ∉ A with K(f) + sep(x; A | f) + c ≤ k is in DIS(VS_k(D)) (the patch of f at x is in H_k), and every x in DIS(VS_k(D)) has sep(x; A | f) ≤ k + c (a consistent g differing from f at x gives the separating set {g ≠ f}). So the never-wrong rule over H_k abstains exactly on the inputs that a test of complexity about k separates from the data, up to K(f) + O(1) bits. A star set is a set of single-point patches; the star number of H_k counts the guards available within the budget.
* **Separated classes have no star sets of small measure** [my own derivation]. If every two members of the class differ on μ-mass at least δ (the δ-isolated functions of `note.md` §5), then B(f, r) = {f} for r < δ and the disagreement coefficient is at most 1/δ. After about (k·ln 2 + ln(1/η))/δ samples the version space within budget k is {f} with probability 1 − η (`note.md` Theorem 9), and from then on the never-wrong rule answers *every* input, out of distribution included. In the terms of this literature, patch-free induction is perfect selective classification over a δ-packing. The assumption that the target is in the packing is then the whole content, and its failure is silent.
* **Classes in which exceptions are expensive to state.** The equational inductor of `ultranatural/equational.md` makes a single-point exception cost at least the cost of naming the point (README, item 5). That limits the single-point patches available within a budget, which is what a small star number means. I have not computed a star number there.
* **Richer observations** (§3.4).

---

## 8. From deterministic labels to samplers

### 8.1 What changes

1. *No refutation by one example.* A version space becomes a confidence set: the hypotheses whose likelihood, or posterior weight, is within a factor of the best. That the truth stays in it is Ville's inequality (CHN22 Theorem 2; LHS13 Theorem 8; `repo.md` X5; the lead's Ab2).
2. *What an answer is.* Either a predicted distribution, accurate to ε in total variation, Hellinger distance or KL (this is already KWIK's definition with noisy observations, §3.1), or a sample.
3. *What "not silently wrong" can mean for a sample.* (i) The output law is ε-close to P(·|x). (ii) Domination: the output sub-distribution is pointwise at most P(·|x), so no event is more likely than under P. (iii) Validity: the output lies in a set R_x of acceptable answers.
4. *Rates.* Deterministic elimination gives 1/n; distinguishing distributions at distance ε takes 1/ε² observations per pair.
5. *Noise is not the right model of a sampler.* If the human's randomness is treated as label noise around a deterministic f*, the agnostic lower bounds apply with η equal to that randomness: error plus rejection at least √(η/8) under shift (§5.1), rejection about θ·R(f*) even in distribution (§4.2), no finite abstention bound below l mistakes (§4.1). The class must contain the sampler itself.

### 8.2 KWIK for distributions

Coins, dice, noisy linear functions and the k-meteorologists problem (§3.1) are KWIK problems with stochastic observations; LHS13 (§7.3) extends them to arbitrary finite and countable classes of sequence measures, and the proposition of §7.3 to samplers with chosen inputs. In all of them the abstention count is polynomial in the number of hypotheses, or in 1/w, and in 1/ε.

### 8.3 Cohen, Hutter and Nanda (2022): a conservative imitator

[read in source: CHN22 §§3–6.] Histories of (query flag, action, observation) triples; an arbitrary stochastic environment that never resets; a demonstrator policy π^d in a countable class Π with prior w. Π may be all computable policies with w ∝ 2^(−length) (their Example 1).

* *The imitator.* Update the posterior only on actions chosen by the demonstrator. Let Π^α be the set of policies whose posterior weight is at least α times the total posterior weight of the policies at least as probable. Take action a with probability min_{π′ ∈ Π^α} π′(a | history); with the remaining probability θ_q, query: the demonstrator acts.
* **Theorem 2**: Pr[∀t: π^d ∈ Π^α] ≥ 1 − α/w(π^d). Call this event E.
* **Theorem 1** (queries): E Σ_t θ_q(h_{<t})³ ≤ |A|·α⁻³·(24·w(π^d)⁻¹ + 12).
* **Theorem 3** (convergence): for α < w(π^d), E[Σ_t (Σ_a |π^i_α(0, a | h_{<t}) − π^d(1, a | h_{<t})|)³ | E] ≤ |A|·α⁻³·(24·w(π^d)⁻¹ + 12)/(1 − α·w(π^d)⁻¹).
* **Theorem 4** (if environment and demonstrator do not depend on who chose the actions): the KL divergence from the imitator's law of the first t actions and observations to the demonstrator's, both conditioned on E, is at most α⁻¹·|A|^(1/3)·(24·w(π^d)⁻¹ + 12)^(1/3)·t^(2/3)/(1 − α/w(π^d))² − log(1 − α/w(π^d)). It grows like t^(2/3), so KL/t → 0.
* **Theorem 5** ("preserving unlikeliness"): for an event B on the first t steps, with s_α = |A|·α⁻³·(24·w(π^d)⁻¹ + 12),

      Pr_imitator(B ∩ E) ≤ t²·s_α / [ log( t²·s_α / (27·Pr_demonstrator(B)) ) − 3·log log( 1 + t^(2/3)·s_α^(1/3) / (3·Pr_demonstrator(B)^(1/3)) ) ]³.

  As the demonstrator's probability of B tends to 0, the bound tends to 0 "at least polylogarithmically".
* *Their own assessment*: with α set below w(π^d) the bounds are "effectively quartic in w(π^d)⁻¹"; "setting α well requires estimating w(π^d), something we cannot offer general guidance on"; realizability is required; pre-training on N demonstrator steps may raise the posterior weight of the truth.

How this relates to the lead's Ab2 (Theorem E of version 1) [my own derivation]: Ab2 is this imitator with the demonstrator removed at deployment, so that a query becomes an abstention. Per step, the imitator's own actions are dominated by the demonstrator's on E; CHN22 lose this over a run because queried steps add up to a factor (1 + θ_q) each, which is why their Theorem 5 is polylogarithmic. With abstention instead of querying, domination of non-abstaining transcripts is exact on E. Their top set is defined with cumulative weights, not with a ratio to the largest weight; the Ville bound is the same. The in-distribution abstention rate inherits their Theorem 1: Σ θ_q ≤ T^(2/3)·(Σ θ_q³)^(1/3), so the average rate over T steps is at most (|A|·α⁻³·(24/w + 12)/T)^(1/3), small only for T beyond about |A|/(α³·w·ε³).

### 8.4 Regression with noise under arbitrary shift

Kalai and Kanade's Theorem 4 (§5.3) is the one result I found that has stochastic labels, arbitrary test inputs and abstention: it predicts the conditional mean in a linear class, with expected loss α·TV(μ, μ′) + κ·log n/√n. Their Lemmas 1–2 are stated for any loss and any confidence set containing the truth, and their remark is that the "information theoretic results generalize to more general regression in a straightforward fashion".

### 8.5 Generative models: validity, breadth, and unavoidable errors

**Validity from positive examples alone.**

* *Kleinberg and Mullainathan (2024)* [read in source: KM24 §2, §7]. A countable list of candidate languages (sets of strings, all infinite), accessible through membership queries; an adversary enumerates all strings of one of them, K. An algorithm *generates in the limit* if from some time on every output is an unseen member of K. **(2.1)** There is one algorithm that generates in the limit for every countable collection and every enumeration, although identification in the limit is impossible for such collections (Gold, Angluin). **(2.2)** For a finite collection 𝒞 there is a number t(𝒞) such that after any t(𝒞) distinct examples the algorithm can output infinitely many unseen members of K. **(7.1)** With prompts: if every prompt has arbitrarily long continuations in every candidate language, the algorithm eventually completes every prompt correctly, including prompts it has never seen an example for.
* *Li, Raman and Tewari (2024)* [read in source: LRT24 §§2–3, §5]. Hypotheses h ∈ {0,1}^X with infinite support. The *closure* ⟨x_1, …, x_n⟩_H is the intersection of the supports of all hypotheses whose support contains x_1, …, x_n: "the set of positive examples common to all hypothesis in the version space". The *closure dimension* C(H) is the largest d for which some d distinct points have a non-empty version space and a finite closure. **Theorem 3.3**: H is uniformly generatable (a number d* of distinct examples, the same for all h and all streams, after which every output is a new valid example) if and only if C(H) < ∞, and the optimal d* is Θ(C(H)). **Theorem 3.5, Corollary 3.6**: H is non-uniformly generatable (d* may depend on h) if and only if it is an increasing union of classes of finite closure dimension; every countable class is. Generatability and learnability are incomparable (Theorem 4.1). Prompted versions (Theorems 5.1–5.2, Corollary 5.3) hold with the prompted closure dimension; there the generator must be right for a prompt only after enough examples *with that prompt*.
* *Charikar and Pabbaraju (2024)* [read in source: arXiv abstract of CP24]: non-uniform generation for every countable collection; with membership queries only it is impossible even for two languages; a negative result for "exhaustive" generation.
* *Kalavasis, Mehrotra and Velegkas (2025)* [read in source: KMV24 abstract]: with random samples from the target language, generation that is both consistent and has *breadth* is impossible "for a large class of language models … for most collections of candidate languages"; it becomes possible for every countable collection when negative examples are also given.

What this is, in the terms of §3 [my own derivation: an interpretation]. Generating from the closure is the generative form of CSS: output only what every hypothesis still consistent would accept. Validity then needs no identification of the target. The price is breadth: the generator covers only the part of the target's support that the data force. And the guarantees do not cross a shift: the time after which outputs are valid is when all wrong hypotheses *earlier in the enumeration than the truth* have been refuted by the data shown, and a wrong simpler hypothesis that differs from the truth only on a kind of input that is never shown is never refuted. KM24's (7.1) handles unseen prompts only because the enumeration eventually shows everything.

**Validity with a verifier** [read in source: HKKT18 abstract, §1, Theorems 2–3]. Hanneke, Kalai, Kamath and Tzamos: samples from p, a class 𝒬 of generators, and an oracle that says whether a given output is invalid. Goal: q̂ with loss at most ε_1 above the best fully valid q ∈ 𝒬 and invalid mass at most ε_2. *Improper* learning succeeds with Θ((M²/ε_1²)·log |𝒬|) samples and Θ(M/ε_1) rounds of Θ((M/(ε_1·ε_2))·log |𝒬|) oracle queries (Theorem 3; M bounds the loss); *proper* learning needs 2^Ω(d) queries already for uniform distributions on boxes in {0,1}^d (Theorem 2). With a verifier, validity costs log of the class size.

**A calibrated generator errs at the missing-mass rate.**

* *Kalai and Vempala (2024)* [read in source: KV24 abstract, §1, Corollary 1]. Documents carry "factoids" whose truth cannot be inferred from the training data. For every learning algorithm, with probability 1 − δ, (rate of generating false factoids) ≥ (fraction of training facts seen exactly once) − (miscalibration) − 3e^(−s)/δ − √(6·ln(6/δ)/n), where e^(−s) bounds the ratio of true facts to possible false ones.
* *Kalai, Nachum, Vempala and Zhang (2025)* [read in source: KNVZ25 §3, Theorems 1–2]. For prompts c with valid responses V_c and erroneous ones E_c: err ≥ 2·err_iiv − max_c |V_c|/min_c |E_c| − δ, where err_iiv is the error of the "is it valid?" classifier obtained by thresholding the model's probabilities and δ is a calibration term. In an "arbitrary facts" model in which the correct response may also be "I don't know", with probability at least 99%: err ≥ (fraction of the N training examples whose prompt occurs exactly once without abstention) − 2/min_c |E_c| − (35 + 6 ln N)/√N − δ. "Language models which do not err must not be calibrated."

For imitation [my own derivation: an interpretation]: wherever the human's answers encode facts that cannot be inferred from the other pairs, an imitator that matches the human's distribution on the training inputs must invent such facts on new inputs at about the rate at which new inputs occur. It can avoid this only by abstaining where the human would answer, that is, by not being a copy there. This is the generative face of "K(P) bits must come from somewhere".

### 8.6 Conformal methods for generators

[read in source: arXiv abstracts only.] Quach et al. (2024) calibrate a stopping rule for sampling candidate answers so that the sampled set contains an acceptable answer with high probability. Mohri and Hashimoto (2024) make an answer progressively less specific until, with the calibrated probability, it is correct. Yadkori et al. (2024) calibrate an abstention rule to bound the hallucination rate. All inherit §6: exchangeable calibration data and a judge of correctness.

### 8.7 A statement I did not find, and a sketch of it

I found no theorem of PQ or MMA type for conditional samplers. Kalai–Kanade's Lemma 1 gives the deterministic half at once.

[my own derivation; the rate in the last step is a sketch that I have not checked in detail.] Let H be a finite class of samplers containing P, |H| = N. Let ℓ(g, h)(x) = TV(g(·|x), h(·|x)). From training data D on inputs drawn i.i.d. from μ, form V = {ν ∈ H : ν(D) ≥ (δ/N)·Σ_{ν′} ν′(D)}; then P ∈ V with probability at least 1 − δ (Ville). Let h be any member of V or the mixture. Given a test batch x ∈ Xⁿ, choose the abstention set A* minimizing max_{g ∈ V} [ (α/n)·|A| + (1/n)·Σ_{i ∉ A} ℓ(g, h)(x_i) ]. Then by KK21b Lemma 1, for every batch x and every z ∈ Xⁿ,

    (α/n)·|A*| + (1/n)·Σ_{i ∉ A*} TV(P(·|x_i), h(·|x_i)) ≤ (α/n)·|{i : x_i ≠ z_i}| + max_{g ∈ V} (1/n)·Σ_i TV(g(·|z_i), h(·|z_i)).

With z a fresh sample from μⁿ, the last term should be Õ(√((ln N + ln(1/δ))/n)): members of a likelihood-ratio confidence set are within squared Hellinger distance O((ln N + ln(1/δ))/n) of P on average over μ, and for a finite class this transfers to a fresh sample. So: on an arbitrary deployment batch, (average total-variation error on the answered inputs) + α·(abstained fraction) ≤ α·(fraction of the batch that is not training-like) + Õ(√(ln N / n)); with Lemma 2, the first term can be replaced by α·D_B(μ‖μ′) at the price of a factor B on the second. For H = samplers of complexity at most k, ln N ≤ k·ln 2.

The abstention rule is a search for one plausible sampler that disagrees with h on much of the batch; it tolerates guards that fire on a small fraction of the batch and rejects the region of any guard that fires on a large one.

---

## 9. What this implies for an imitation protocol

Everything in this section is **[my own derivation]**, unrefereed: consequences I draw from the sources, and interpretations. "Budget k" means the assumption that the target has complexity at most k (or prior weight at least w_0 = 2^(−k)).

### 9.1 Four standards of soundness and what each costs

| standard | what a theorem can say | human answers needed | what it assumes | where |
|---|---|---|---|---|
| per-input | with probability 1 − δ, every answered input is right (ε-accurate for a sampler), for any deployment inputs | about 2^k abstentions or queries; fewer only for classes with small star number | budget k; realizability | §3, §7.2, §7.3, §8.3 |
| batch rate | on a given batch of deployment inputs, at most an ε fraction of the answered ones are wrong (average total variation at most ε); the rest are rejected | about k/ε² labelled training inputs; no labels on the batch | budget k; realizability; the batch, unlabelled, in advance | §5, §7.2, §8.7 |
| audited | accuracy or coverage on the deployment distribution, on average | with a budget, about k/ε labels on random deployment inputs; with no budget, a conformal guarantee at level α from about 1/α or more audited inputs | the human answers random deployment inputs; audited and unaudited inputs exchangeable | §6.5; `notes.md` Obs. A |
| prior-averaged | calibrated at every input on average over targets drawn from the prior | none | that the prior is believed | §7.4 |

The researcher's wish (a P′ that "basically only fails obviously", "without needing to keep querying" the human, under a shift between training and deployment) is the per-input standard. For a universal class it has the 2^k price, and by §7.1 no price at all buys it without a budget. The batch-rate standard is the strongest one that is affordable, valid for arbitrary deployment inputs, and needs no human at deployment. Its failures are of three kinds: rejections (obvious); at most an ε fraction of silent errors on the batch (bounded, not obvious); and violation of the budget or of realizability (silent).

### 9.2 Unlabelled deployment inputs cost a scaffold nothing

PQ learning needs the deployment inputs in advance, without labels. For a task-decomposition scaffold they can be produced without the human, by running the scaffold with the current imitator. Three caveats.

1. *Circularity.* The batch depends on the imitator's answers, and the rejection set depends on the batch. GKKM20's error bound holds for every batch, including batches chosen with knowledge of h. But the batch that the scaffold produces with one selective classifier is not the batch it produces once the rejection set has been recomputed from it. One needs a fixed point, or an online version. Online, the polylogarithmic bounds need the typical input distribution to be known, and without it a polynomial price is forced even with every label shown (§5.4). In a scaffold the typical distribution is the human-driven distribution of calls, which is not known in advance. The lead's rehearsal protocol (version 2, R1) gets round the circularity with human answers on random calls of the imitator's own runs; with no human answers on those runs the question is open.
2. *Rates, not runs.* The guarantee counts wrong answers in the batch. A run of L calls that needs every call right needs ε < 1/L, that is n above about 2k·L² with the bound of §7.2.
3. *The rock.* If most deployment inputs share a simple property that no training input has (depth in the decomposition, say), some consistent program within the budget disagrees with h on all of them, and Rejectron rejects them all. That is correct behaviour, and it is the tension between D9 and D12 of `notes.md`. PQ learning does not remove it; it makes it visible, and it tells where.

### 9.3 The rejection rule as a test of whether the human must be asked again

Deterministic, realizable, budget k. Let h be any program in H_k consistent with the labelled data, and B a batch of deployment inputs.

* *Test.* Search H_k for a program consistent with the labelled data that differs from h on more than an ε fraction of B. If there is none, h is wrong on at most an ε fraction of B, with certainty, since the target is itself a program in H_k consistent with the labelled data. No label on B was used.
* *If the test fails, audit.* Ask the human at (k·ln 2 + ln(1/δ))/ε uniformly random inputs of B. With probability 1 − δ this refutes every program in H_k that differs from the target on more than an ε fraction of B, so afterwards every consistent program passes the test with 2ε.

So, for one deployment distribution, the human is asked nothing when the data already determine the answers on the batch up to ε, and about k/ε questions otherwise. This is `notes.md` Observation A with a certificate for the case in which no question is needed. For a sequence of different deployment distributions the worst case is still exponential (each can be concentrated on a new input), as §3 requires.

For samplers the version space becomes the confidence set of §8.7, the test becomes the minimax problem there, and the audit count is of order (k + ln(1/δ))/ε².

### 9.4 For a per-input standard, the tools are the certificate and the minimum rule

* The posterior spread s_t(x) (§7.3) is exactly the prior-averaged error at x, and s_t(x)/(δ·w_0) is a sound bound for every target of weight at least w_0. Use a prior of finite entropy.
* The minimum-over-plausible-models rule (§8.3) gives domination. With abstention in place of querying, the domination of non-abstaining transcripts is exact on the event that the truth stays in the plausible set.
* Both abstain at every input that a test simpler than the budget separates from the data (§7.3, §7.5). They are whitelists.

### 9.5 Realizability is the assumption that fails silently

Every result of §§3–5 and §§7–8 assumes the target is in the class (or in the budget). When it is not: in distribution, the failure can show (empty version space, collapsing posterior, miscalibration on held-out data); out of distribution it does not. The agnostic theorems do not rescue this cheaply: √(η/8) error plus rejection under shift, a rejection floor near θ·R(f*), no finite abstention bound below l mistakes. The only model-free check in this literature is conformal calibration on audited deployment inputs (§6.5).

### 9.6 Candidate theorem shapes, with their status

1. **Batch-rate imitation of a sampler under arbitrary shift** (§8.7). Status: the deterministic inequality is KK21b Lemma 1; the in-distribution term is a sketch. I did not find it in the literature.
2. **A per-input certificate for a sampler, valid at every input** (§7.3). Status: proved above in a few lines; it is LHS13's Theorem 8 moved to chosen inputs. Its price is 1/w.
3. **Test, then audit** (§9.3). Status: elementary for deterministic targets with a budget.
4. **Open.** (i) A version in which deployment inputs depend on earlier answers and no label is seen after training; §5.4 shows what is forced online without knowledge of the typical input distribution. (ii) A structural hypothesis on a human sampler that makes the star number of the budget class small (separation, laws, or richer observations), with an argument that a person satisfies it. (iii) Whether abstention with domination (the lead's Ab2) can be given a batch-rate form whose coverage does not need 1/w.

### 9.7 Where this meets the lead's draft (version 2) and the companion digest

* **The closed-system idea** (rehearsal: draw the training questions from the computation's own inputs). In this digest's terms it is the transductive idea, deployment inputs available in advance, with labels on a random subset: the "audited" standard of §9.1. For inputs from outside the closed system the literature here adds two things. If unlabelled inputs from the new source are available, reject rather than fail (§5, §8.7). And before spending human answers on a new closed system, test whether they are needed (§9.3).
* **N1, and item 5 of the draft's §0** (a rule that is never silently wrong for every member of the class abstains at every new input; Theorem D(c) in version 1): the optimality of CSS, EYW10 Theorem 7 (§3.3), applied to a class closed under patches (§7.1).
* **N3 and S2** (all simple shifts cost 2^k) and **N4** (never silently wrong is exponential): instances of the star-number bounds (§3.2, §3.3, §7.2). HY21's Theorem 4 (§5.6) is the i.i.d. form with queries on request. GKKM20's Claim 4.2 (§5.1) is the positive counterpart of S2 for a known list of m deployment laws with unlabelled samples from each: a factor m + 1 in ε.
* **S1** (density-ratio factor B; Theorem C in version 1): BCRT21 Theorem 2 shows that a model-free method cannot remove the factor (§6.3). GKKM20's set S* (§5.1) and KK21b's Lemma 2 (§5.3) give the form with abstention: pay B times the in-distribution error where μ′ ≤ B·μ and reject the rest, by a rule that needs unlabelled deployment inputs but not the ratio.
* **Ab1** (threshold rule): the Bayes-mixture form of the SZB10 trade-off (§4.1), as `ask-for-help.md` §2.5 also notes; ZC16's theorem for thresholds shows that the exponential rate cannot be improved in general. It needs the label on every counted round (§4.4).
* **Ab2** (pessimism and dominance; Theorem E in version 1): the abstaining variant of CHN22's imitator (§8.3; `ask-for-help.md` §3.2 analyses the withdrawal of the demonstrator). The Ville step is CHN22 Theorem 2 and LHS13 Theorem 8. Its coverage is governed by 1/w (CHN22 Theorem 1, LHS13 Theorems 9–10), and off the training distribution by the remark in §7.3.
* **Ab3** (novelty rule), with `repo.md` X2 and `notes.md` Observation B: KWIK enumeration with a budget (§3.1). The region where it asks is the disagreement region of H_k (§7.5), and its exponential count is forced by the star number of H_k (§7.2).
* **V1** (validation certificate) and the audits of `repo.md` X3–X4 and `notes.md` Observation A: the "audited" standard. V1 is a held-out validation bound; it rests on the same exchangeability between audited and unaudited calls as conformal calibration (§6.5), and assumes nothing about the human. §9.3 adds a label-free test for when audits are unnecessary.
* **Pr3–Pr5** (match the frequencies of all simple tests): the nearest notions in this digest are the relaxation of conditional coverage in GCC23 (§6.4), E[f(X)·(1{Y ∈ Ĉ} − (1 − α))] = 0 for all f in a class, which its authors say is called "multi-accuracy" in theoretical computer science [read in source: GCC23 §1], and the calibration notion of KV24 (§8.5). "Outcome indistinguishability" (Dwork, Kim, Reingold, Rothblum and Yona, 2021) is, as I recall, the same idea for predictors and a class of distinguishers [from memory, not checked].
* **Theorem B** (weights 2^(−λℓ) with λ > 1): the same steepness makes the entropy of the prior finite, which LHS13's confidence bounds need (§7.3).

### 9.8 Pitfalls the literature has already met

* "Train a distinguisher between training and deployment inputs and reject what it flags" is not sufficient (KK21a's four-point example; GKKM20's dense cluster of test points near an error).
* Bounds in expectation may not have high-probability versions (KK21b Lemma 8).
* Conformal coverage is marginal; adaptive conformal coverage is a long-run frequency (§6.4).
* A never-wrong claim always hides a budget (§7.1).
* Calibration and absence of errors are incompatible on facts that cannot be inferred (§8.5).
* The rejection rate on the deployment distribution cannot be bounded; only the rejection rate on the training distribution can (§5.1).

---

## 10. Impossibility results, collected

Sources as in the sections cited.

1. **Never wrong, adversarial order.** Singletons on {0,1}ⁿ: 2ⁿ − 1 abstentions. Conjunctions on d variables: 2^d − 1. Any class of infinite Littlestone dimension (thresholds, intervals on the line): no finite bound, even with any fixed number of mistakes allowed. In general the optimal bound is the eluder dimension, at least max(star number, threshold dimension). (§3.1, §3.2) When the target is only within D of a linear class in dimension d: at least 2^(d−1) passes. (§4.1)
2. **Never wrong, i.i.d.** No distribution-free sublinear abstention rate unless the star number is finite; it is infinite for intervals, half-planes and rectangles. CSS can have coverage zero (two arcs). For finite classes the rejected mass can be of order |H|/m. Rectangles and half-spaces under uniform distributions need a number of samples exponential in the dimension. (§3.3)
3. **A class closed under patches** (all computable functions): a never-wrong learner answers no unlabelled input. (§7.1)
4. **Arbitrary test inputs.** Without abstention, or without unlabelled test inputs, no guarantee. With both: Ω(√(d/n)) for error on the test law plus rejection on the training law; Ω(√(d/min{m, n})) transductively. The rejection rate on the test law has no bound beyond rej_μ + TV(μ, μ′). One cannot tell μ′ = μ from disjoint supports with fewer than about √|X| samples. (§5.1)
5. **Not realizable.** Error plus rejection at least max{√(η/8), η̃} under shift (§5.1). Any pointwise-competitive rule rejects mass of order R(f*) in some two-hypothesis problems (§4.2). With l unexplained labels, fewer than l mistakes cannot be guaranteed with finitely many abstentions for some one-element class (§4.1).
6. **High probability.** Loss at least α·TV + α/√n with constant probability in the cost model (§5.3).
7. **Model-free prediction sets.** Distribution-free conditional coverage forces sets of infinite expected length at non-atoms. Coverage conditional on every set of mass at least δ, equivalently under every shift with density ratio at most 1/δ, forces sets about as large as marginal miscoverage α·δ requires. The same once the family of sets has VC dimension at least 2n + 2. (§6.3)
8. **Asking for help.** Without further assumptions, an algorithm with sublinearly many queries has unbounded worst-case regret. With queries on request on an i.i.d. stream, fewer than about s/16 queries force mistakes of order T/(number of queries). (§5.6)
9. **Online, with injected inputs and an unknown clean distribution.** For some class of VC dimension 1: E[misclassifications] ≥ T^α/32 or E[abstentions on clean rounds] ≥ T^(1−α)/2 for every α; combined error Ω(√T). (§5.4)
10. **Certified Bayes prediction.** The 1/w price is attained when "at each time-step only one model differs" from the mixture (LHS13 §6); within a budget this is the star-number bound of §7.2.
11. **Generators.** A calibrated generator produces invalid "arbitrary facts" at about the missing-mass rate; consistency with breadth is impossible for most collections without negative examples; proper valid generation needs exponentially many validity queries. (§8.5)
12. **From this repository**: the separation-complexity floor and its machine dependence (`ultranatural/note.md`, Theorem 3), which §7.5 identifies with items 1–3 for a budget class.

---

## 11. What I could not verify

* **Originals not opened**: LLWS11, EYW10, SZB10, WEY11 (blocked hosts). Their statements above are restatements, each attributed. In particular the constants and exact hypotheses of EYW10 Theorems 7 and 8 are as given in Bal15, a survey.
* **"KWIK dimension"**: not found (§3.2).
* **Overlap with `ask-for-help.md`.** That digest read several of the same papers from their TeX sources, and found the two 2026 papers of §5.4 before I did; I then read those two myself. Where the two digests state the same theorem I have not compared them line by line.
* **Kivinen's lower bound** for rectangles is known to me only through HKL19, and through GKKM20, who cite it "as cited by" HKL19; **Han16**'s star-number characterisation only through GHMS23; **DLL09**'s bound only through LHS13.
* **Author order of the NIPS 2011 paper**: the reference lists of Bal15 and GHMS23 give "Wiener and El-Yaniv"; a search-result title showed "El-Yaniv and Wiener".
* **Venues marked "from memory" in §12** were not checked.
* **My own derivations**, none refereed: the eluder characterisation of KWIK (§3.2); the tightness example for finite classes (§3.3); the feedback argument (§4.4); the trivial-set condition for weighted conformal and the equivalence between approximate conditional coverage and bounded-ratio shifts (§6.2, §6.3); all of §7.1, §7.2, §7.4, §7.5; the proposition and remarks of §7.3; the readings in §8.3 and §8.5; the sketch of §8.7; all of §9.
* I did not read the proofs of the papers' theorems, except KK21b Lemma 1 and the lower-bound construction of GKKM20 Theorem 5.4.

---

## 12. References

"arXiv" entries were read from the arXiv PDF unless marked. Venue data not printed on the PDF or in the arXiv record are marked (memory).

* **[Bal15]** Akshay Balsubramani, "The Utility of Abstaining in Binary Classification", arXiv:1512.08133, 2015 (short survey). https://arxiv.org/abs/1512.08133
* **[BCRT21]** Rina Foygel Barber, Emmanuel J. Candès, Aaditya Ramdas, Ryan J. Tibshirani, "The limits of distribution-free conditional predictive inference", arXiv:1903.04684 (v2, 2020); *Information and Inference* 10(2), 2021 (memory). https://arxiv.org/abs/1903.04684
* **[BCRT23]** Rina Foygel Barber, Emmanuel J. Candès, Aaditya Ramdas, Ryan J. Tibshirani, "Conformal prediction beyond exchangeability", arXiv:2202.13415 (v5, 2023); *Annals of Statistics* 51(2), 2023 (memory). https://arxiv.org/abs/2202.13415
* **[CGAD24]** Maxime Cauchois, Suyash Gupta, Alnur Ali, John C. Duchi, "Robust Validation: Confident Predictions Even When Distributions Shift", arXiv:2008.04267; *Journal of the American Statistical Association*, 2024. https://arxiv.org/abs/2008.04267
* **[CH20]** Michael K. Cohen, Marcus Hutter, "Pessimism About Unknown Unknowns Inspires Conservatism", *COLT 2020*, PMLR 125:1–30; arXiv:2006.08753. Abstract and statement list read. https://arxiv.org/abs/2006.08753
* **[CHN22]** Michael K. Cohen, Marcus Hutter, Neel Nanda, "Fully General Online Imitation Learning", *Journal of Machine Learning Research* 23 (2022) 1–30; arXiv:2102.08686. https://arxiv.org/abs/2102.08686
* **[CP24]** Moses Charikar, Chirag Pabbaraju, "Exploring Facets of Language Generation in the Limit", arXiv:2411.15364, 2024. Abstract only. https://arxiv.org/abs/2411.15364
* **[DLL09]** Carlos Diuk, Lihong Li, Bethany R. Leffler, "The adaptive k-meteorologists problem and its application to structure learning and feature selection in reinforcement learning", *ICML 2009*, pp. 249–256. Not read; cited through LHS13.
* **[EG26]** Ezra Edelman, Surbhi Goel, "Reliable Abstention under Adversarial Injections: Tight Lower Bounds and New Upper Bounds", arXiv:2602.20111, 2026. Introduction and theorem statements read. https://arxiv.org/abs/2602.20111
* **[EYW10]** Ran El-Yaniv, Yair Wiener, "On the Foundations of Noise-free Selective Classification", *Journal of Machine Learning Research* 11:1605–1641, 2010. Not opened; cited through Bal15, WHE15, GE19. https://www.jmlr.org/papers/volume11/el-yaniv10a/el-yaniv10a.pdf
* **[EYW12]** Ran El-Yaniv, Yair Wiener, "Active Learning via Perfect Selective Classification", *Journal of Machine Learning Research* 13:255–279, 2012. Not opened; cited through WHE15 and Bal15.
* **[FMS04]** Yoav Freund, Yishay Mansour, Robert E. Schapire, "Generalization bounds for averaged classifiers", *Annals of Statistics* 32:1698–1722, 2004. Not read; cited through Bal15.
* **[GC21]** Isaac Gibbs, Emmanuel Candès, "Adaptive Conformal Inference Under Distribution Shift", arXiv:2106.00170; *NeurIPS 2021* (memory). https://arxiv.org/abs/2106.00170
* **[GCC23]** Isaac Gibbs, John J. Cherian, Emmanuel J. Candès, "Conformal Prediction With Conditional Guarantees", arXiv:2305.12616 (v4, 2024). https://arxiv.org/abs/2305.12616
* **[GE19]** Roei Gelbhart, Ran El-Yaniv, "The Relationship Between Agnostic Selective Classification, Active Learning and the Disagreement Coefficient", *Journal of Machine Learning Research* 20 (2019) 1–38 [read in source: web search result]; read as arXiv:1703.06536. https://arxiv.org/abs/1703.06536
* **[GHMS23]** Surbhi Goel, Steve Hanneke, Shay Moran, Abhishek Shetty, "Adversarial Resilience in Sequential Prediction via Abstention", arXiv:2306.13119; *NeurIPS 2023* (memory). https://arxiv.org/abs/2306.13119
* **[GKKM20]** Shafi Goldwasser, Adam Tauman Kalai, Yael Tauman Kalai, Omar Montasser, "Beyond Perturbations: Learning Guarantees with Arbitrary Adversarial Test Examples", *NeurIPS 2020*; arXiv:2007.05145. https://arxiv.org/abs/2007.05145
* **[GSSV24]** Surbhi Goel, Abhishek Shetty, Konstantinos Stavropoulos, Arsen Vasilyan, "Tolerant Algorithms for Learning with Arbitrary Covariate Shift", arXiv:2406.02742, 2024. Abstract only. https://arxiv.org/abs/2406.02742
* **[Han16]** Steve Hanneke, "Refined error bounds for several learning algorithms", *Journal of Machine Learning Research* 17(135):1–55, 2016. Not read; cited through GHMS23.
* **[HKKT18]** Steve Hanneke, Adam Kalai, Gautam Kamath, Christos Tzamos, "Actively Avoiding Nonsense in Generative Models", arXiv:1802.07229; *COLT 2018* (memory). https://arxiv.org/abs/1802.07229
* **[HKL19]** Max Hopkins, Daniel M. Kane, Shachar Lovett, "The Power of Comparisons for Actively Learning Linear Classifiers", arXiv:1907.03816. https://arxiv.org/abs/1907.03816
* **[HKLM20]** Max Hopkins, Daniel Kane, Shachar Lovett, Gaurav Mahajan, "Noise-tolerant, Reliable Active Classification with Comparison Queries", arXiv:2001.05497; *COLT 2020* (memory). https://arxiv.org/abs/2001.05497
* **[HY15]** Steve Hanneke, Liu Yang, "Minimax Analysis of Active Learning", *Journal of Machine Learning Research* 16(109):3487–3602, 2015; arXiv:1410.0996. https://arxiv.org/abs/1410.0996
* **[HY21]** Steve Hanneke, Liu Yang, "Toward a General Theory of Online Selective Sampling: Trading Off Mistakes and Queries", *AISTATS 2021*, PMLR 130 (read from the PMLR PDF). https://proceedings.mlr.press/v130/hanneke21a/hanneke21a.pdf
* **[JKMR16]** Matthew Joseph, Michael Kearns, Jamie Morgenstern, Aaron Roth, "Fairness in Learning: Classic and Contextual Bandits", arXiv:1605.07139; condensed version in *NeurIPS 2016*. https://arxiv.org/abs/1605.07139
* **[KK21a]** Adam Kalai, Varun Kanade, "Efficient Learning with Arbitrary Covariate Shift", *ALT 2021*, PMLR 132:1–15 (venue read on the PMLR PDF); read as arXiv:2102.07802. https://arxiv.org/abs/2102.07802
* **[KK21b]** Adam Tauman Kalai, Varun Kanade, "Towards optimally abstaining from prediction with OOD test examples", *NeurIPS 2021* (Advances in Neural Information Processing Systems 34:12774–12785); arXiv:2105.14119. https://arxiv.org/abs/2105.14119
* **[KKM12]** Adam Tauman Kalai, Varun Kanade, Yishay Mansour, "Reliable agnostic learning", *Journal of Computer and System Sciences* 78(5):1481–1495, 2012. Not read; cited through KK21a.
* **[Kiv90]** Jyrki Kivinen, "Reliable and useful learning with uniform probability distributions", *ALT 1990*, pp. 209–222. Not read; cited through GKKM20 and HKL19.
* **[KLMZ17]** Daniel M. Kane, Shachar Lovett, Shay Moran, Jiapeng Zhang, "Active classification with comparison queries", arXiv:1704.03564; *FOCS 2017* (memory). https://arxiv.org/abs/1704.03564
* **[KM24]** Jon Kleinberg, Sendhil Mullainathan, "Language Generation in the Limit", arXiv:2404.06757; *NeurIPS 2024* (as cited in KMV24). https://arxiv.org/abs/2404.06757
* **[KMV24]** Alkis Kalavasis, Anay Mehrotra, Grigoris Velegkas, "On the Limits of Language Generation: Trade-Offs Between Hallucination and Mode Collapse", *STOC 2025*; arXiv:2411.09642. Abstract only. https://arxiv.org/abs/2411.09642
* **[KNVZ25]** Adam Tauman Kalai, Ofir Nachum, Santosh S. Vempala, Edwin Zhang, "Why Language Models Hallucinate", arXiv:2509.04664, 2025. https://arxiv.org/abs/2509.04664
* **[Kos19]** Vanessa Kosoy, "Delegative Reinforcement Learning: learning to avoid traps with a little help", SafeML ICLR 2019 Workshop; arXiv:1907.08461. Abstract only. https://arxiv.org/abs/1907.08461
* **[KSV24]** Adam R. Klivans, Konstantinos Stavropoulos, Arsen Vasilyan, "Testable Learning with Distribution Shift", *COLT 2024*; arXiv:2311.15142. Abstract only. https://arxiv.org/abs/2311.15142
* **[KV24]** Adam Tauman Kalai, Santosh S. Vempala, "Calibrated Language Models Must Hallucinate", *STOC 2024*; arXiv:2311.14648. https://arxiv.org/abs/2311.14648
* **[LC21]** Lihua Lei, Emmanuel J. Candès, "Conformal Inference of Counterfactuals and Individual Treatment Effects", *Journal of the Royal Statistical Society: Series B*, 2021; arXiv:2006.06138. https://arxiv.org/abs/2006.06138
* **[LHS13]** Tor Lattimore, Marcus Hutter, Peter Sunehag, "Concentration and Confidence for Discrete Bayesian Sequence Predictors", arXiv:1307.0127; *ALT 2013* (memory). https://arxiv.org/abs/1307.0127
* **[LKFS21]** Gene Li, Pritish Kamath, Dylan J. Foster, Nathan Srebro, "Understanding the Eluder Dimension", *NeurIPS 2022*; arXiv:2104.06970. https://arxiv.org/abs/2104.06970
* **[LLWS11]** Lihong Li, Michael L. Littman, Thomas J. Walsh, Alexander L. Strehl, "Knows what it knows: a framework for self-aware learning", *Machine Learning* 82(3):399–443, 2011; conference version by Li, Littman and Walsh, *ICML 2008*, pp. 568–575. Not opened; cited through Bal15, JKMR16, WSDL09, ZC16, LHS13.
* **[LRT24]** Jiaxun Li, Vinod Raman, Ambuj Tewari, "Generation through the lens of learning theory", arXiv:2410.13714 (v5, 2024). https://arxiv.org/abs/2410.13714
* **[MH24]** Christopher Mohri, Tatsunori Hashimoto, "Language Models with Conformal Factuality Guarantees", arXiv:2402.10978, 2024. Abstract only. https://arxiv.org/abs/2402.10978
* **[PZR24]** Benjamin Plaut, Hanlin Zhu, Stuart Russell, "Avoiding Catastrophe in Online Learning by Asking for Help", arXiv:2402.08062 (v6, 2025); *ICML 2025*. https://arxiv.org/abs/2402.08062
* **[QFS24]** Victor Quach, Adam Fisch, Tal Schuster, Adam Yala, Jae Ho Sohn, Tommi S. Jaakkola, Regina Barzilay, "Conformal Language Modeling", *ICLR 2024*; arXiv:2306.10193. Abstract only. https://arxiv.org/abs/2306.10193
* **[RS88]** Ronald L. Rivest, Robert H. Sloan, "Learning complicated concepts reliably and usefully (extended abstract)", *Proceedings AAAI-88*, pp. 635–640. Not read.
* **[SS11]** István Szita, Csaba Szepesvári, "Agnostic KWIK learning and efficient approximate reinforcement learning", *COLT 2011*, JMLR Workshop and Conference Proceedings 19:739–772 (read from the PMLR PDF). https://proceedings.mlr.press/v19/szita11a/szita11a.pdf
* **[SSSW23]** Ayush Sekhari, Karthik Sridharan, Wen Sun, Runzhe Wu, "Selective Sampling and Imitation Learning via Online Regression", arXiv:2307.04998, 2023. Abstract only. https://arxiv.org/abs/2307.04998
* **[SZB10]** Amin Sayedi, Morteza Zadimoghaddam, Avrim Blum, "Trading off mistakes and don't-know predictions", *NIPS 2010*, pp. 2092–2100. Not opened; cited through ZC16 and Bal15.
* **[TBCR19]** Ryan J. Tibshirani, Rina Foygel Barber, Emmanuel J. Candès, Aaditya Ramdas, "Conformal Prediction Under Covariate Shift", arXiv:1904.06019 (v3, 2020); *NeurIPS 2019* (venue as given to me, not checked). https://arxiv.org/abs/1904.06019
* **[VGS05]** Vladimir Vovk, Alexander Gammerman, Glenn Shafer, *Algorithmic Learning in a Random World*, Springer, 2005. Not read; the reference TBCR19 gives for conformal prediction.
* **[WEY11]** Yair Wiener, Ran El-Yaniv, "Agnostic selective classification", *NIPS 2011*, pp. 1665–1673. Not opened; cited through GE19 and Bal15.
* **[WHE15]** Yair Wiener, Steve Hanneke, Ran El-Yaniv, "A Compression Technique for Analyzing Disagreement-Based Active Learning", *Journal of Machine Learning Research* 16:713–745, 2015; arXiv:1404.1504. https://arxiv.org/abs/1404.1504
* **[WSDL09]** Thomas J. Walsh, István Szita, Carlos Diuk, Michael L. Littman, "Exploring compact reinforcement-learning representations with linear regression", *UAI 2009*; arXiv:1205.2606. https://arxiv.org/abs/1205.2606
* **[YB26]** Jialin Yu, Moïse Blanchard, "Distribution-Free Sequential Prediction with Abstentions", arXiv:2602.17918 (v2, 2026). Main results section read. https://arxiv.org/abs/2602.17918
* **[YKS24]** Yasin Abbasi Yadkori, Ilja Kuzborskij, David Stutz, András György, Adam Fisch, Arnaud Doucet, Iuliya Beloshapka, Wei-Hung Weng, Yao-Yuan Yang, Csaba Szepesvári, Ali Taylan Cemgil, Nenad Tomasev, "Mitigating LLM Hallucinations via Conformal Abstention", arXiv:2405.01563, 2024. Abstract only. https://arxiv.org/abs/2405.01563
* **[ZC16]** Chicheng Zhang, Kamalika Chaudhuri, "The Extended Littlestone's Dimension for Learning with Mistakes and Abstentions", *COLT 2016*, pp. 1584–1616; arXiv:1604.06162. https://arxiv.org/abs/1604.06162

Mentioned from memory only, not checked: C. K. Chow, "On optimum recognition error and reject tradeoff", *IEEE Transactions on Information Theory* 16(1):41–46, 1970 (bibliographic data as in Bal15's reference list); Y. Freund, R. E. Schapire, Y. Singer, M. K. Warmuth, "Using and combining predictors that specialize", *STOC 1997*; S. Ben-David, R. Urner, "On the hardness of domain adaptation and the utility of unlabeled target samples", *ALT 2012* (cited in GKKM20 and KK21a for the impossibility of learning under arbitrary covariate shift without abstention).
