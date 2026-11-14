# Learners that may abstain, and distribution shift: a literature digest

*For the "principled human imitation" problem. One team member's reading of the literature on learners that are never, or only rarely, silently wrong because they may abstain. Companion digests in this folder: `notes.md` (the researcher's notes) and `repo.md` (what this repository has proved). The lead's working draft is `../candidate-theory.md`.*

## 0. Access, method, conventions

**Web access.** WebSearch works. Pages could be fetched from `arxiv.org` only. The hosts `www.jmlr.org`, `link.springer.com`, `dev.icml.cc`, `ttic.edu` and `proceedings.neurips.cc` are outside this session's allowed network domains (WebFetch and direct download both fail). So four works named in the task could not be opened in their original form:

* Li, Littman, Walsh (and Strehl), "Knows What It Knows" (ICML 2008; Machine Learning 2011);
* El-Yaniv and Wiener, "On the Foundations of Noise-free Selective Classification" (JMLR 2010);
* Sayedi, Zadimoghaddam and Blum, "Trading off mistakes and don't-know predictions" (NIPS 2010);
* Wiener and El-Yaniv, "Agnostic selective classification" (NIPS 2011).

For these four I give the statements as they are restated in papers I did read, and I name the restating paper each time. Everything else the task names was read from the arXiv PDF (text extracted with `pdftotext`). No private details and no project text went into any query.

**Tags.**

* **[read in source: KEY]**: I read the statement in the work KEY in this session. Keys are resolved in §12. "Restated in KEY" means KEY reports another paper's result and I read it there, not in the original.
* **[search]**: seen only on a web-search result page.
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
4. **(c) Impossibility.** Collected in §10. The ones that matter most: never-wrong learning of the 2^d − 1 singletons-plus-zero class, or of conjunctions on d variables, needs about 2^d abstentions; no distribution-free method achieves conditional coverage, and coverage that is robust to all covariate shifts with density ratio at most B cannot beat running at level α/B; in the non-realizable case with noise rate η, error plus rejection is at least √(η/8).
5. **(d) Universal classes.** Every theorem above is stated for a fixed class of finite dimension. A Solomonoff-type class has infinite VC dimension, infinite star number and infinite Littlestone dimension. The theorems are rescued by a complexity budget k (or a prior weight w): H_k has VC dimension about k but star number about 2^k (its patches are a star set). So rate-type guarantees cost about k/ε² examples, and never-wrong guarantees cost about 2^k abstentions or queries, and both need the assumption K(target) ≤ k, which data can refute but not confirm. Bayesian versions exist: Lattimore, Hutter and Sunehag give a sound confidence bound for a Bayes mixture over a countable class, at price 1/w(truth); Cohen, Hutter and Nanda give an imitator over a countable class of samplers with the same kind of price. The exponential is the separation-complexity floor of this repository in learning-theoretic form (§7.5).
6. **(e) Samplers.** Three things carry over: KWIK-style ε-accurate prediction of output distributions (cost 1/ε² per hypothesis, or 1/w in the countable case); the conservative "minimum over plausible models" rule, which never makes any event more likely than the demonstrator does (Cohen–Hutter–Nanda); and conformal prediction, which is model-free but needs exchangeability or the likelihood ratio. I found no PQ-type theorem for samplers under arbitrary shift; Kalai and Kanade's minimax-abstention lemma is general enough to give one (§8.7, a sketch of mine). For generative models there are also lower bounds: a calibrated generator must produce invalid outputs at about the missing-mass rate unless it abstains.
7. **For the design of a protocol** (§9): choose the soundness notion first; the ε-fraction notion with unlabelled deployment inputs is the only one in this literature that is both affordable for a universal class and valid under arbitrary shift, and a scaffold can produce unlabelled deployment inputs without the human; the rejection rule doubles as a test of whether the human needs to be asked again; realizability is assumed everywhere except in conformal prediction, and its failure is not an obvious failure.

---

## 2. A map of the models

| model | who chooses the test inputs | feedback | what is allowed on answered inputs | what is bounded | governing quantity | main source |
|---|---|---|---|---|---|---|
| KWIK | adversary, one at a time | label only after ⊥ | nothing (ε-accurate with probability 1 − δ) | number of ⊥ | eluder dimension; at most \|H\| − 1 | LLWS11 |
| k mistakes (SZB) | adversary, one at a time | label every round | at most k mistakes in total | ⊥ plus mistakes | ELdim(H, k) ≤ (k+1)·\|H\|^(1/(k+1)) | SZB10, ZC16 |
| RPU, perfect selective classification | i.i.d. from the training law | none after training | nothing | rejected mass under μ | n̂, θ, star number | RS88, EYW10, WHE15, HY15 |
| agnostic selective classification | i.i.d. from the training law | none after training | agree with the best f* in H | rejected mass under μ | θ, d, R(f*) | WEY11, GE19 |
| PQ learning (redaction) | arbitrary μ′, or an adversarial batch; unlabelled test inputs given | none | error rate ε on the test inputs | error on μ′, rejection on μ | d | GKKM20 |
| transductive abstention at a cost | as above | none | loss, with cost α per abstention | total loss on the batch | d | KK21b |
| sequential prediction with injections | i.i.d. stream with adversarial insertions | label every round | counted | mistakes plus abstentions on i.i.d. rounds | d (if μ is known) | GHMS23 |
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

**Model** [read in source: restated in JKMR16 §2 and in Bal15 Definition 2.2; informally in WSDL09 §2]. An adversary presents inputs x_1, x_2, … one at a time. The learner outputs a prediction ŷ_t or ⊥. Only when it outputs ⊥ does it observe y_t (or a noisy observation z_t with E z_t = f(x_t)). An algorithm is an (ε, δ)-KWIK learner of a class C with bound m(ε, δ) if for every sequence of inputs and every target f ∈ C, with probability at least 1 − δ: (1) every prediction satisfies |ŷ_t − f(x_t)| ≤ ε, and (2) the number of ⊥ outputs is at most m(ε, δ). LLWS11 ask for m polynomial in 1/ε, 1/δ and the size parameters of the problem.

**Positive results** [read in source: restated in Bal15 §2.2, except where noted].

* *Enumeration.* For a finite class H of deterministic functions: keep the version space, predict when it is unanimous at x_t, else output ⊥ and remove the refuted hypotheses. At most |H| − 1 abstentions. (Also restated in ZC16 §1 and LHS13.)
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

**I did not find a quantity called "KWIK dimension".** A web search for the phrase returned only the KWIK papers, and none of the restatements I read defines one [search; read in source: Bal15, ZC16, JKMR16, LHS13, GHMS23]. I could not open LLWS11 itself, so I cannot exclude that it uses the term. The exact characterisations that I did find are these.

* **The extended Littlestone dimension** [read in source: ZC16 Definitions 2–3, Theorem 2]. ELdim(H, k) is the largest m for which there is a (k, m)-difficult extended mistake tree: a tree of inputs, with a "mistake" edge to each child and one "abstention" edge, every root-to-leaf path consistent with some h ∈ H, such that every path using at most k mistake edges has length at least m. If ELdim(H, k) = m, the algorithm SOA.DK makes at most k mistakes and at most m mistakes-plus-abstentions on every H-realizable sequence, and no deterministic algorithm achieves m − 1. "When k = 0, this is exactly the KWIK model."
* **For k = 0 this is the combinatorial eluder dimension** [my own derivation]. For f* ∈ H let Edim_{f*}(H) be the largest m for which there are (x_1, f_1), …, (x_m, f_m) with f_i ∈ H, f_i(x_i) ≠ f*(x_i) and f_i(x_j) = f*(x_j) for all j < i (the definition is from LKFS21, Definition 4). Then the least worst-case number of abstentions of a deterministic learner that is never wrong on H is sup_{f*} Edim_{f*}(H).
  *Proof.* Lower bound: show x_1, …, x_m labelled by f*. If the learner has abstained at all j < i, it has seen exactly the labels f*(x_j), j < i; these are also the labels under the target f_i, so its output at x_i is the same under both targets, and they differ at x_i; a learner that is never wrong must abstain. By induction it abstains m times. Upper bound: the enumeration learner abstains at x_t only if some f_t in the current version space differs from f* at x_t; f_t agrees with f* at all earlier abstention rounds; so the abstention rounds form such a sequence. ∎
* **Eluder dimension against star number and threshold dimension** [read in source: LKFS21 Definition 4, Proposition 1, Proposition 2, Theorem 8]. The star number Sdim_{f*}(H) is defined like Edim_{f*} but with "for all j ≠ i"; the threshold dimension Tdim_{f*}(H) with "f_i(x_k) ≠ f*(x_k) for all k ≥ i and f_i(x_j) = f*(x_j) for all j < i". Then

      max{Sdim_{f*}, Tdim_{f*}} ≤ Edim_{f*} ≤ 4^max{Sdim_{f*}, Tdim_{f*}},   and   Sdim_{f*} ≤ Edim_{f*} ≤ min{|X|, |H| − 1}.

  For n thresholds the star number is 2 and the eluder dimension is n; for the singletons both are n. Neither inequality of the first display can be improved in general (their Theorems 9–10 for the upper one). ⌊log Tdim⌋ ≤ Ldim ≤ 2^Tdim.

So a class is learnable with zero mistakes on adversarial sequences if and only if both its star number and its threshold dimension are finite: it must contain neither many single-point patches of one function nor a long chain of thresholds. [my own derivation, from the two items above]

### 3.3 The i.i.d. version: reliable and probably useful learning, perfect selective classification

**Model** [read in source: restated in HKLM20 §1.1.3, HKL19 §1, GE19 §2]. The learner sees m labelled examples drawn i.i.d. from a distribution over X labelled by f ∈ H, and outputs a selective classifier (h, g): it predicts h(x) if g(x) = 1 and abstains otherwise. It must make no error on any point where it predicts; its quality is its coverage Φ = Pr_μ[g(X) = 1]. Rivest and Sloan (1988) called this "reliable and probably useful" (RPU) learning; El-Yaniv and Wiener (2010) "perfect selective classification"; Kane, Lovett, Moran and Zhang (2017) "confident" learning. (The word "reliable" is also used for a different model, one-sided agnostic noise; see §5.2.)

**The consistent selective strategy (CSS)**: predict at x if and only if all hypotheses consistent with the sample agree at x.

* *Optimality* [read in source: restated in Bal15 Proposition 3.2 as "Thm. 7, EYW10"; also GHMS23 §4.2]. "In the realizable case, any classifier which has zero error with certainty on any D with any h* satisfies the following condition: if it predicts (a non-⊥ label) on a point x, then so does CSS."
* *Finite classes* [read in source: restated in Bal15 Proposition 3.1 as "Thm. 8, EYW10"]. For CSS, with probability at least 1 − δ,

      Pr_μ(⊥) ≤ (1/m)·( (ln 2)·min(|H|, |X|) + ln(1/δ) ).

  The dependence on |H| is linear, not logarithmic. This cannot be improved in general [my own derivation]: let H be the zero function and the N singletons on N points, μ uniform, target zero. At an unseen point the data are equally consistent with a singleton target, so a never-wrong learner abstains there, and the unseen mass has expectation (1 − 1/N)^m; rejection below ε needs m ≥ N·ln(1/ε).
* *Infinite classes: coverage can be zero* [read in source: restated in Bal15 §3.2, with EYW10's figure]. For linear separators in R² and data uniform on two arcs, one all positive and one all negative, the version space is unanimous only on a set of measure zero for every finite sample: CSS "will almost surely abstain". Kalai and Kanade put it this way: "the natural idea to abstain on test points whose labels are not uniquely determined by the training data can lead to abstaining on all test points even when P = Q" [read in source: KK21b §1].
* *A data-dependent bound* [read in source: WHE15 Definition 1, Lemma 7]. Let n̂(S_m) be the version space compression set size: the size of a smallest subset of the sample that induces the same version space. With probability at least 1 − δ,

      Pr_μ( DIS(VS(S_m)) ) ≤ ( 10·n̂(S_m)·ln(em/n̂(S_m)) + 4·ln(2/δ) ) / m.

* *Disagreement coefficient* [read in source: WHE15 Definition 2, Theorems 3–4, Lemma 27]. θ(r_0) = sup_{r > r_0} Pr_μ(DIS(B(f*, r)))/r ∨ 1, where B(f*, r) is the set of hypotheses at distance at most r from f*. With probability at least 1 − δ every h in the version space after t examples has error at most r_t = (24/t)·(d·ln(880·θ(d/t)) + ln(12/δ)); hence the rejected mass of CSS is at most θ(r)·r_t for every r < r_t [the last step is my own derivation: the version space lies in B(f*, r_t)]. θ and the high-probability bound B_n̂ on n̂ determine each other up to a factor d and logarithms:

      θ(r_0) ≤ max{ max_{r ∈ (r_0,1)} 16·B_n̂(⌈1/r⌉, 1/20), 512 },      B_n̂(1/r_0, δ) ≤ c·θ(d·r_0)·( d·ln(e·θ(d·r_0)) + ln(log(2/r_0)/δ) )·log(2/r_0).

  A rejection rate O(polylog(m)/m) for CSS is equivalent to an exponential speed-up of the CAL active learner (WHE15 Corollary 10; Bal15 Proposition 4.1, restating EYW12 Theorem 9).
* *Distribution-free: the star number* [read in source: HY15 Definition 2, Theorem 10, Table 1; GHMS23 §4.2 restating Han16]. The star number s of H is the largest s such that there are x_1, …, x_s and h_0, h_1, …, h_s ∈ H with h_i and h_0 differing on x_i and on no other x_j. The supremum over distributions and targets of θ(ε) equals min(s, 1/ε); the maximum over samples of n̂ equals min(s, m). "The optimal distribution-free abstention rate for perfect selective classification is sublinear if and only if the star number is finite (in which case it is always at most s log T)." s ≥ d always, and "the gap between s and d can generally be infinite": s = 2 for thresholds on the line, s = ∞ for intervals, for linear separators in R^k (k ≥ 2) and for axis-aligned rectangles.
* *Favourable distributions* [read in source: WHE15 Theorems 11 and 13]. Linear separators in R^k under a mixture of t Gaussians with diagonal covariances: B_n̂(m, 1/20) ≤ c_{k,t}·(log m)^(k−1) (this is EYW10 Lemma 32), so by Lemma 7 the rejected mass is O((log m)^k / m) with a constant depending on k and t [this step is mine]; a lower bound Ω((log m)^((k−1)/2)) on the number of labels CAL requests among m points, for some distribution of this type, is attributed to EYW12. Axis-aligned rectangles under product densities, positive class of mass at least λ: B_n̂(m, δ) ≤ (8k/λ)·ln(8k/δ).
* *The dimension is the enemy* [read in source: HKL19 §1 and §4, GKKM20 §2]. Kivinen showed that RPU-learning rectangles "required an exponential number of samples even under the uniform distribution"; label-only RPU-learning of linear separators under the uniform distribution on the ball is lower-bounded by the number of samples needed for the convex hull of the sample to have measure 1 − ε, exponential in the dimension.

### 3.4 Richer queries make never-wrong learning cheap

[read in source: KLMZ17 §1.2.2, Theorem 1.5.] If, besides labels, the learner may ask comparison queries ("which of x_1, x_2 is further on the positive side?"), the relevant quantity is the inference dimension: the least k such that in every sample of size k some point's label is determined by the label and comparison queries on the others. For half-planes in R² it is at most 7, while their star number is infinite. With inference dimension k the labels of any realizable sample of size n can be revealed with O(k·log k·log n) queries, and "confident" learning has nearly the sample complexity of PAC learning. With label queries alone the inference dimension "specializes to the star dimension". The lesson for imitation: the exponential cost of never-wrong learning is a statement about what a *label* reveals; a richer observation of the target can remove it. (For a human, intermediate work is such an observation; nothing in this literature treats it.)

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

**Why this works where "abstain on the disagreement region" does not** [my reading]. The never-wrong rule controls max over g ∈ V *at each test input*, which costs the star number. MMA and Rejectron control, for each g ∈ V, its *average* disagreement with h *over the test set*, which is a uniform-convergence quantity and costs only the VC dimension. The average over the test set is why the test inputs must be known in advance.

### 5.4 The online version: Goel, Hanneke, Moran and Shetty (2023)

[read in source: GHMS23.] An i.i.d. stream from μ with target f ∈ F; before each round an adversary may replace the input by an arbitrary one ("clean-label injection"; the label is still f's). The learner predicts or abstains, then sees the label. Error = (number of wrong predictions on any round) + (number of abstentions on non-injected rounds). Abstaining on injected rounds is free.

* The disagreement-based learner has no misclassifications and, for thresholds, at most 2·log T abstentions on i.i.d. rounds (Proposition 4.1); for general classes it is governed by the star number (§3.3) and is useless for, say, unions of two intervals.
* **Theorem 5.1** (μ known): for VC dimension d, an algorithm based on the probability that k fresh points are shattered by the version space has E[misclassifications] ≤ d²·log T and E[abstentions on i.i.d. rounds] ≤ 6d.
* **Theorems 6.1, 6.7** (μ unknown): for VC dimension 1, E[misclassifications] ≤ 2·√(T log T) and E[abstentions] ≤ √(T log T); for axis-aligned rectangles in R^p, O(√(pT log T)) each.
* Open (their §7): general VC classes with unknown μ. The label is revealed after every round in this model; the authors mention the variant without labels on abstention rounds as a direction.

### 5.5 Abstaining on the whole test distribution

[read in source: arXiv abstracts of KSV24 and GSSV24 only.] In *testable learning with distribution shift* (TDS; Klivans, Stavropoulos and Vasilyan 2024) the learner gets labelled samples from the training law and unlabelled samples from the test law and runs a test: if the test accepts, the classifier has low test error; if the two input laws are equal, the test accepts. Efficient algorithms are given for half-spaces, intersections of half-spaces and decision trees under Gaussian or uniform training inputs. Goel, Shetty, Stavropoulos and Vasilyan (2024) note that earlier TDS algorithms "end up abstaining entirely even in the presence of a tiny amount of distribution shift", give tolerant versions, and give efficient PQ learners for the same classes.

### 5.6 Asking for help instead of abstaining

Abstract-level reading only, unless stated.

* Plaut, Zhu and Russell (2024) [read in source: PZR24 abstract and theorem statements]: online learning where each round's payoff is the chance of avoiding catastrophe and the agent may query a mentor. "In general, any algorithm either queries the mentor at a linear rate or is nearly guaranteed to cause catastrophe." If the mentor's policy class has finite VC dimension and inputs are σ-smooth, or has finite Littlestone dimension, and nearby inputs have nearby payoffs (Lipschitz constant L), regret tends to 0 with a number of queries of order T^((4n+1)/(4n+2)) (n the input dimension).
* Cohen and Hutter (2020) [read in source: CH20 abstract]: a Bayesian reinforcement learner over a countable class of world-models that maximizes the worst case over the models with enough posterior weight, and defers to a mentor with a probability that tends to 0; with probability 1 − δ it causes no "unprecedented event".
* Kosoy (2019) [read in source: Kos19 abstract]: a regret bound for reinforcement learning with traps when the agent may delegate actions to an advisor; finitely many hypotheses, states and actions.
* Sekhari, Sridharan, Sun and Wu (2023) [read in source: arXiv abstract of SSSW23]: imitation learning with selective queries to a noisy expert; the regret is bounded by that of an online regression oracle and "the query complexity additionally depends on the eluder dimension of the model class", with a matching lower bound.
* Hanneke and Yang (2021), "Toward a general theory of online selective sampling: trading off mistakes and queries" [listed in GHMS23's references; not read].
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
* **This is a statement about covariate shift** [my own derivation]. For an input law μ without atoms, (1 − α, δ)-CC is equivalent to coverage at least 1 − α under every test input law μ′ with dμ′/dμ ≤ 1/δ. (One direction: conditioning on a set of mass ≥ δ is such a shift. The other: miscoverage under μ′ is linear in the density q = dμ′/dμ; over the convex set {0 ≤ q ≤ 1/δ, ∫q dμ = 1} a linear functional is maximized at an extreme point, and for atomless μ the extreme points are (1/δ)·1_A with μ(A) = δ.) So Theorem 2 says: a model-free method that keeps its coverage under every shift with density ratio at most B = 1/δ can do no better than run at miscoverage α/B. The factor B in the lead's Theorem C and in `notes.md` Observation D cannot be removed without assuming something about the class of samplers.
* **Restricting the sets** (Theorems 3–4): coverage conditional on every set of mass ≥ δ in a class 𝒳 of sets is achievable for any 𝒳, but if the VC dimension of 𝒳 is at least 2n + 2 the lower bound of Theorem 2 applies again (for the exchangeable form of the property).

### 6.4 What can be had without the likelihood ratio

* **A finite-dimensional family of shifts** [read in source: GCC23 Theorem 2, Corollary 1]. Conditional coverage is equivalent to E[f(X_{n+1})·(1{Y_{n+1} ∈ Ĉ} − (1 − α))] = 0 for all measurable f; relax "all f" to a class F. For F = {Φ(·)ᵀβ : β ∈ R^d}, a quantile regression over F on the scores gives, for every non-negative f ∈ F, coverage at least 1 − α when the test input is drawn from the law tilted by f; and if the scores are continuous the two-sided error is at most (d/(n+1))·E[max_i |f(X_i)|]. With F spanned by the indicators of finitely many groups 𝒢 this is coverage in every group, exact up to |𝒢|/((n+1)·Pr(G)). So: exact robustness to an unknown shift, provided its density ratio lies in a known d-dimensional family.
* **A ball of distributions** [read in source: CGAD24 Theorem 1, Corollaries 2.1–2.3]. If the test law of the scores is within f-divergence ρ of the training law, a quantile at a level raised according to (f, ρ) restores coverage; for total variation, if 2·TV ≤ ρ, the level 1 − α + ρ/2 gives coverage at least 1 − α − 1/n. The radius must be known or assumed.
* **Unknown, arbitrary shift** [read in source: BCRT23 Theorem 2, Lemma 1]. Without any correction, coverage is at least 1 − α − Σ_i w̃_i·d_TV(R(Z), R(Z^i)), where Z^i swaps the test point with the i-th calibration point, R is the vector of scores and w̃_i are normalized weights; for independent points the gap is at most 2·Σ_i w̃_i·d_TV(Z_i, Z_{n+1}). Coverage is lost silently, in proportion to the distance.
* **Arbitrary sequences, with the label after every round** [read in source: GC21 Lemma 4.1, Proposition 4.1]. Adaptive conformal inference updates the working level by α_{t+1} = α_t + γ·(α − err_t), where err_t indicates miscoverage at time t. For *every* sequence, with probability one, |(1/T)·Σ_{t ≤ T} err_t − α| ≤ (max{α_1, 1 − α_1} + γ)/(Tγ). This is a statement about a long-run frequency, obtained by alternating over- and under-coverage; it identifies no round as safe; and it needs every label.

### 6.5 Summary for this problem

[my reading.] Conformal prediction is the only tool in this digest that needs no realizability assumption, and that is also why it cannot survive shift: its "class" is everything. It gives a guarantee under shift exactly when the shift is brought back to exchangeability, by a known likelihood ratio, by a small known family of ratios, or by drawing the calibration inputs from the deployment distribution itself. The last is what random audits do (`notes.md` Observation A; `repo.md` X3–X4): a uniformly random subset of a batch of deployment inputs is exchangeable with the rest of the batch.

@@PART3@@
