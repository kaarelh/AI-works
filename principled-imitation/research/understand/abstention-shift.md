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

@@PART2@@
