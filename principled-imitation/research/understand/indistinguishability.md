# Indistinguishability by a class of tests: what is proved, and what it would buy for imitation

*For the "principled human imitation" problem. One team member's reading of the literature on learning a model that a class of tests cannot tell apart from the truth, with the sample cost governed by the tests and not by the truth; then a derivation of the statement one would want in the imitation setting; then an assessment of what such a statement does and does not buy. Companion digests in this folder: `repo.md`, `notes.md`, `abstention-shift.md`, `ask-for-help.md`, `imitation-theory.md` (the last covers the imitation-learning literature in detail; §2.10 here overlaps with it only where composition is concerned). "The note" below is the lead's draft `/home/user/AI-works/principled-imitation/note.md`; "the candidate theory" is `/home/user/AI-works/principled-imitation/research/candidate-theory.md`.*

## 0. Access, tags, notation

**Web access.** WebSearch works. Fetching works for `arxiv.org`, `eccc.weizmann.ac.il` and `proceedings.mlr.press`; I downloaded the papers from these hosts and read the theorem statements in the text of the PDFs. The hosts `eprint.iacr.org`, `par.nsf.gov`, `pmc.ncbi.nlm.nih.gov`, `research-explorer.ista.ac.at` and `proceedings.neurips.cc` are refused by this session's network policy (they would have to be allowed in the session's network settings). Consequences:

* Jetchev and Pietrzak (TCC 2014) and Chen, Chung and Liao (EUROCRYPT 2018) were not read. Their theorems are given as restated in Skórski (arXiv:1503.00484) and in Dwork, Lee, Lin and Tankala (arXiv:2301.08837), which I read.
* Kim, Kern, Goldwasser, Kreuter and Reingold (PNAS 2022, "Universal adaptability") was not read. Its definition and theorem are given as restated in two arXiv papers that I read (§2.8).
* Abbeel and Ng (2004), Syed and Schapire (2007), and the forecasting papers of Dawid, Foster–Vohra, Lehrer, Sandroni and Vovk (2007) were not read; statements about them are from memory or from papers that describe them, and are tagged.

No private detail and no text of this project went into a web query.

**Tags.**

* **[read]** (read in source): I read the statement in the cited source in this session. Section, theorem and page numbers refer to the arXiv or ECCC version named in §6.
* **[read, secondary]**: I read the statement in a different paper that restates it; the original was not accessible. **[search result]**: I saw it only in the snippet of a search result. Both are weaker than [read] and should be checked before they are used in the note.
* **[memory]** (from memory, not checked).
* **[mine]** (my own derivation or reading). Unrefereed. Proofs are given where they are short.

**Notation** (that of the note where it exists).

* X, Y: countable sets of strings. A *sampler* S is a probability kernel S(·|x) on Y. The human is the sampler P. K := log₂(1/w(P)) when a weighted class H containing P is assumed (assumption A2 of the note). Nothing in §3 assumes A2 unless it says so.
* A *test* is a function t: X × Y → [0, 1]; a set B of pairs is the test 1_B. (The literature says "distinguisher"; §2.2 explains the difference it makes between the two words.) For a sampler S and an input distribution D, the *pass rate* is S_D(t) := E_{x∼D} E_{y∼S(·|x)} t(x, y).
* T: a countable family of tests with weights π(t) > 0, Σ_t π(t) ≤ 1. For a finite family, π = 1/|T|. With π(t) = 2^(−K(t)) these are the simple tests.
* 𝒟: a countable family of input distributions with weights ρ(D) > 0, Σ ρ ≤ 1.
* S is *(T, ε)-indistinguishable from P on D* if |S_D(t) − P_D(t)| ≤ ε for every t in T.
* Scaffold, run, call, horizon L, Q_A (the law of a run answered by A), closed system, rehearsal, validation: as in the note, §1–2.

---

## 1. The findings that matter for the protocol

1. **The cost in questions depends on the tests and not on the human, and this is a theorem of the literature in the binary case.** For outcomes in {0, 1}, a predictor that no test of a finite class A can tell from Nature with advantage ε can be learned from O(log(|A|/δ)/ε²) labelled samples when the tests do not look at the predictor, and from O(log(|A|/(δε))/ε⁴) when they do, with no assumption on Nature: "p* need not come from any realizable or learnable class of functions" (Dwork, Kim, Reingold, Rothblum, Yona 2021 and 2022; §2.2, §2.5). The tight quantity is the fat-shattering dimension of the test class (Hu, Peale, Reingold 2022; §2.4). For outputs in a large set Y the same holds with a factor log|Y| only when tests look at the predicted distribution (Dwork et al. 2022; §2.5). In the imitation setting (long outputs, tests of pairs (x, y)): 2·ln(2|T|/δ)/ε² questions for one input distribution, with no assumption on the human beyond A1, that each question gets a fresh independent answer (Theorem I1, §3.2).
2. **The same literature says, in as many words, that this does not give closeness to the truth.** "OI does not guarantee statistical closeness to Nature … the feasibility results demonstrate the ability to learn an incorrect model that cannot be detected by efficient inspection" (Dwork et al. 2021, p. 7). The model that the proofs construct is a reference distribution re-weighted by a few tests (§2.5, Lemma I1a). In the imitation setting with unbounded compute, an imitator that searches for outputs passing the tests at the human's rates is indistinguishable. Test-indistinguishability is therefore not a definition of a mind upload, and for a decidable property it tells us nothing we could not have enforced with a filter.
3. **Both regimes can be had from one learner.** The published results say that the cost is governed by the smaller of two complexities, that of the test class and that of the class containing the truth (Hu, Peale, Reingold 2022, Theorem 13 and Remark 16; §2.4). In our notation: the simplest sampler that matches all tests, with the pairwise tests of Yatracos added, costs min{ln|T|, K} up to constants (Proposition I5; it is Pr4 of the candidate theory). The description length of the human is absent exactly as long as one asks only for the tests.
4. **Shift: the price is the number of regions, not the complexity of the human, and only for a restricted class of shifts.** For a family of input distributions that we can sample, the questions are split among them: about 4·2^k·(k·ln 2 + ln|T| + ln(1/δ))/ε² questions for all distributions of description length at most k, and (1 − 2δ)·2^k are necessary (Theorem I2). For shifts given by a class W of density ratios bounded by B the cost is O(B·ln(|T||W|/δ)/ε²): this is the mechanism of "universal adaptability" (§2.8). For *all* shifts with density ratio at most B the test-only price is false: one needs about as many questions as the truth class has bits (Proposition I3).
5. **Properties that have held so far keep holding, at the price of the property.** A property R that held on all n training pairs fails on a fresh input from the same distribution with probability at most (K(R)·ln 2 + ln(1/δ))/n, for the human and for every imitator constrained accordingly (Proposition I4). The conflict between properties that the researcher points out does not arise, because only frequencies on the sampled distribution are constrained. Off that distribution nothing is said.
6. **Composition needs the tests to contain the continuation values of the human system.** Matching per-call tests on a fixed input distribution says nothing about runs (§3.7, C0). By the performance difference lemma, matching per-call tests *on the imitator's own run distribution* gives |Pr[outcome] − Q_P[outcome]| ≤ L·ε, provided the test class contains the function "probability that the human system succeeds from here on" (Theorem C2). This is "on-policy Q-value moment matching" in imitation learning (Swamy, Choudhury, Bagnell, Wu 2021; §2.10), and it is what rehearsal samples. The price is the complexity of that value function, which can be far below K but is not known. Under low stakes the factor L disappears (C3).
7. **Run-level tests with recorded human runs need no such assumption** and cost O(L·ln(|U|/δ)/ε²) calls for a class U of outcome tests; Ω(L/ε) calls are necessary even for one test (C4). Per-call matching on the own distribution costs about L²·K(V)/ε² calls, so it is the better tool only for low-stakes scaffolds.
8. **A certificate for outcomes follows from the validation phase of the note.** Theorem V1(b) of the note, read through the performance difference lemma, bounds |Q_A(u) − Q_P(u)| for every outcome u whose human continuation value is a simple test, for any frozen imitator A, with no assumption on the human or on how A was made (C2′).
9. **The closest published statements to the note's Theorem Pr5** are defensive forecasting (Vovk, Takemura, Shafer 2005), online multicalibration with the same exponential potential (Gupta, Jung, Noarov, Pai, Roth 2021), and, for generative models, "Defensive Generation" (Farina, Perdomo 2026), which defines online outcome indistinguishability for generators and proves an O(√T) gap on any sequence (§2.11). A mixture over learning rates improves Pr5 from K(B)/√n to about √(K(B)/n) per test (§3.7, Remark).
10. **What the guarantee does not buy.** Correct answers, when correctness has no simple decidable test; sane behaviour, when insanity has no simple test; anything at inputs of frequency below about 1/n; anything about whether the imitator is a copy. Each of these needs either closeness to P in total variation (price K, assumption A2), or a human judge inside the validation phase (price: one judge call per checked output).

---

## 2. The literature, with exact statements

### 2.1 The common shape

All the results below have this shape. There is an unknown object g (a function, a predictor, a conditional distribution, a policy), a class F of tests, and a number ε. One constructs h such that every test in F has almost the same expectation on h as on g. The complexity of h, and the number of samples of g needed to find h, are bounded in terms of F and ε only.

The cleanest statement of the existence half is the regularity theorem of Trevisan, Tulsiani and Vadhan.

**Theorem (TTV 2009, Theorem 1.1) [read].** "Let X be a finite set, μ a probability distribution over X, F be a collection of functions f: X → [0, 1], ε > 0 an approximation parameter, and g: X → [0, 1] an arbitrary bounded function. Then there is a function h: X → [0, 1] satisfying E_μ[h] = E_μ[g] that is (1) efficient relative to F: h has complexity ε^(−O(1)) relative to F; (2) indistinguishable from g: for every f ∈ F, |E_{x∼μ}[g(x)f(x)] − E_{x∼μ}[h(x)f(x)]| ≤ ε." Complexity C relative to F means: h is defined from at most C functions of F by at most C operations (multiplication by a constant, a Boolean threshold, sum, product). The boosting proof gives complexity O(ε^(−2)).

Two remarks of the authors bear on imitation [read]:

* Remark 1.2: "the theorem applies to arbitrary functions g, including random functions and functions of very high average-case complexity … the indistinguishability property does not imply that h is a good approximation of g in the sense of the two functions agreeing on many inputs … although h may make many mistakes in computing g, inputs on which h is wrong are indistinguishable from inputs on which h is right."
* Remark 1.6: h is more complex than the tests it fools, and this cannot be avoided: there is no h of fixed complexity that fools all tests of larger complexity (their counterexample takes g = a hash function and the test f = g).

With g(x) = Pr[y = 1 | x] this is the statement that a binary-output sampler has an imitation of complexity O(1/ε²) relative to the tests. The same paper derives from it the weak regularity lemma of Frieze and Kannan, the dense model theorem and Impagliazzo's hardcore lemma [read, §1.3].

### 2.2 Outcome indistinguishability (Dwork, Kim, Reingold, Rothblum, Yona, STOC 2021)

**Setting [read, §1–2].** Individuals i in a discrete set X ⊆ {0,1}^d, outcomes in {0, 1}. Nature is a joint law D* on X × {0,1} with marginal D_X and conditional probability p*_i. A predictor is p̃: X → [0, 1]; D(p̃) is the law of (i, õ_i) with i ∼ D_X and õ_i ∼ Ber(p̃_i). "We make no assumptions about p* other than it defines a valid conditional probability distribution for each i ∈ X. In particular, p* need not come from any realizable or learnable class of functions" (p. 17).

**Definition 2.1 [read].** "For a class of distinguishers A and ε > 0, a predictor p̃: X → [0, 1] satisfies (A, ε)-outcome indistinguishability (OI) if for every A ∈ A, | Pr_{(i,o*_i)∼D*}[A(i, o*_i; p̃) = 1] − Pr_{(i,õ_i)∼D(p̃)}[A(i, õ_i; p̃) = 1] | ≤ ε."

**The four levels [read, Definitions 2.2–2.6]**, by what the test may see of the predictor: *no-access* (A(i, o)); *sample-access* (A(i, o, p̃_i)); *oracle-access* (A may query p̃ at any individual); *code-access* (A is given the description of p̃).

**Equivalences with multi-group notions [read, Theorems 4.3 and 4.4].**

* No-access OI and multi-accuracy. For a collection C of subpopulations with γ_C ≥ min_{S∈C} Pr[i ∈ S], there is a family A_C (one test A_S(i, b) = 1[i ∈ S ∧ b = 1] per set) such that (A_C, α·γ_C)-no-access-OI implies (C, α)-multi-accuracy; conversely for deterministic A there is C_A (two sets per test) such that (C_A, ε/2)-multi-accuracy implies (A, ε)-no-access-OI. Multi-accuracy (Definition 4.1): |E[p*_i | i ∈ S] − E[p̃_i | i ∈ S]| ≤ α for all S ∈ C.
* Sample-access OI and multi-calibration, with a discretisation of the predictions into m bins: (A_{C,m}, α²γ_C/m)-sample-access-OI implies (C, α)-multi-calibration, and (C_{A,m}, ε/4)-multi-calibration implies (A, ε)-sample-access-OI.

The factor γ_C is the cost of conditioning on a subpopulation: a guarantee of absolute error ε on the whole population is a guarantee of ε/Pr[S] inside S.

**Existence, with complexity independent of Nature [read].** Algorithm 1 starts from p ≡ 1/2 and, while some A ∈ A has advantage Δ_A > ε, updates p ← proj_[0,1](p + (Δ_A/2)·δ_A) with δ_A(·) = A(·, 1; p) − A(·, 0; p).

* Lemma 5.1: "Algorithm 1 terminates after at most T ≤ O(1/ε²) iterations." The potential is E_{i∼D_X}(p*_i − p_i)²; each update lowers it by at least 3ε²/4.
* Theorem 5.2: for A implemented by circuits of size s, "for any choice of Nature's distribution D* and ε > 0, there exists an (A, ε)-sample-access-OI predictor p̃ implemented by a circuit of size O(s/ε²)."
* Theorem 5.4: for oracle circuits of size s with at most q queries, an (A, ε)-oracle-access-OI predictor of size s·q^(O(1/ε²)).
* Theorem 5.10: for code-access tests of size (s(d) + n)^k in the length n of the description of p̃, a predictor of size s(d)^(2^(O(1/ε²))). "The bound is independent of the complexity of p*" (p. 6).

**Sample complexity [read, §5.4].** "Applying Hoeffding's inequality, we can see that m_t ≥ Ω(log(|A|/δ)/ε²) labeled samples suffice to estimate Δ_A^(t) for each A ∈ A with probability at least 1 − δ. Naively, we can take a fresh set of labeled samples for each iteration, so by iteration complexity T ≤ O(1/ε²), then in total, m_{1:T} ≥ Ω(log(|A|/(δε))/ε⁴) labeled samples suffice." Fresh samples are needed because the statistics at iteration t depend on the current predictor; the techniques of adaptive data analysis do better (they cite Hébert-Johnson et al.).

**Lower bounds on the complexity of the predictor at the upper levels [read].** Corollary 6.9: if counting k-cliques has no o(ℓ_cc(k, n))-time randomised algorithm, then for every m there are a Boolean p*_n computable in time Õ(t_cc(m, n)), a distribution samplable in time Õ(n²), and m distinguishers computable in time Õ(n³), such that no predictor computable in time ℓ_cc(m, n)·log^(−ω(1))(n) is (A_n, 1/(100m))-OI for infinitely many n. Corollary 6.11: if BPP ≠ PSPACE, there are poly(n) polynomial-time distinguishers and a p* such that no polynomial-time predictor is 1/poly-OI. The construction (technical overview, pp. 10–11; Algorithm 2 in §6.1): the domain is split into levels; the level-i test checks an outcome at level i by a downward self-reduction that uses the predictor's own answers at level i − 1 as an oracle. "Obtaining oracle-access-OI is as hard, up to sub-polynomial factors, as computing p*. We emphasize that this is the case even though the running time of the distinguishers can be arbitrarily small compared to the running time of p*" (p. 6). These are statements about computation time. They do not change the number of samples.

**Several samples; the hybrid argument [read, Proposition 2.8].** If p̃ is (A, ε/m)-oracle-access-OI for single-sample tests of size s, it is (A_m, ε)-OI for m-sample tests of size s (given preprocessing samples from D* and oracle access to p̃). The proof is the telescoping sum over hybrids D_k = (D*)^(m−k) × D(p̃)^k.

**What OI does not give [read].**

* "OI does not guarantee statistical closeness to Nature (it need not be the case that p* ≈ p̃). Thus, the feasibility results demonstrate the ability to learn an incorrect model that cannot be detected by efficient inspection" (p. 7). "We show that a simple random model of Nature—namely, D(p̃) for an OI predictor p̃—suffices to 'fool' efficient observers" (p. 7).
* With all tests one gets closeness: for the family of all subset tests A_S(i, o) = o·1[i ∈ S], "the only predictors p̃ that satisfy no-access-OI will be statistically close to Nature's predictor p*" (p. 19).
* *Prediction* indistinguishability (the test sees p*_i or p̃_i next to Nature's outcome) is too strong: Proposition 3.2 shows that a single simple test forces ‖p* − p̃‖₁ ≤ 4τ + ε when p* is within τ of a Boolean function.

**Tests and distinguishers [read, §1.4].** In the forecasting literature a *test* is something every possible Nature passes with high probability, and passing is good. "Sandroni's powerful result [San03] proves, non-constructively, the existence of an Algorithm that, given any test T, yields a history which passes T with probability at least as great as the minimum probability with which any natural history … passes T." A *distinguisher* has no such meaning: "our goal is to produce an object such that the distinguisher outputs 1 with the same probability as the objects that we are imitating. In this case, getting the distinguisher to output 1 with higher probability may be worse." Proposition 3.4: for families with the "valid-model property" (the acceptance probability on a correctly specified model does not depend on the model), prediction indistinguishability and sample-access OI are equivalent up to a factor 3 in ε.

*Reading for imitation [mine].* A property that every sampler's data would have can be kept by an imitator that knows nothing; this is Sandroni's point. The properties worth keeping are those specific to P, and their rates must be learned from P. And the requirement is two-sided: an imitator that passes a "good" test more often than the human is as distinguishable as one that passes it less often. In practice one would make such tests one-sided (§3.4).

### 2.3 Multicalibration and multiaccuracy

**Hébert-Johnson, Kim, Reingold, Rothblum (ICML 2018) [read].** The universe is finite with uniform distribution; p*: X → [0, 1] arbitrary; C a collection of subsets each of density at least γ.

* Theorem 1: "For any p*: X → [0, 1], there is a predictor that is α-multicalibrated with respect to C implemented by a circuit of size O(s/α⁴γ)", s the circuit size for membership in sets of C.
* Theorem 2: "there is an algorithm that learns a predictor of p*: X → [0, 1] that is α-multicalibrated on C from O(log(|C|)/α^(11/2)γ^(3/2)) samples in time O(|C|·t·poly(1/α, 1/γ))." The naive bound with fresh samples per update is log(|C|)/α⁶γ⁶ (p. 6); the improvement answers the adaptively chosen queries through a differentially private mechanism (Theorems 3.8–3.10).
* Corollary 3.4 (accuracy in expectation on every set, the weaker notion): n = Õ(log(|C|/ξ)/(α²γ)) samples. The queries are non-adaptive, so one sample set and a union bound suffice.
* Theorems 3 and 4 (informal): a weak agnostic learner for C running in time T gives an algorithm that learns a multicalibrated predictor on the large sets of C in time O(T·poly(1/α, 1/γ)), and conversely an algorithm of the second kind gives a weak agnostic learner with polynomial overhead. This is a statement about time, not about samples.

**Kim, Ghorbani, Zou (AIES 2019) [read].** Definition: for C ⊆ [−1, 1]^X, f is (C, α)-multiaccurate if |E_{x∼D}[c(x)·(f(x) − y(x))]| ≤ α for all c ∈ C. "Ideally, we would hope to take C to be the class of all statistical tests. Requiring multiaccuracy with respect to such a C, however, requires learning the function y(x) exactly, which is information-theoretically impossible from a small sample" (p. 4). Theorem 2: with an auditor that agnostically learns C of dimension d(C), their boosting algorithm converges to a (C, α)-multiaccurate hypothesis in T = O(ℓ_D(f₀; y)/α²) iterations from m = Õ(T·(d(C) + log(1/δ))/α²) samples.

**When multiaccuracy implies accuracy (Kim, Ghorbani, Zou, Proposition 1) [read].** "Suppose that for S ⊆ X with Pr[x ∈ S] ≥ γ, there is some c ∈ C such that E_{x∼D}[|c(x) − ŷ_S(x)|] ≤ τ. Then if f is (C, α)-multiaccurate, er_S(f; y) ≤ 2·(α + τ)/γ." Here ŷ is the label function in ±1 form. In words: indistinguishability gives correctness on S exactly when the test class contains something close to the truth on S.

### 2.4 The sample complexity, characterised (Hu, Peale, Reingold, ALT 2022)

Setting [read]: no-access OI with binary outcomes. A (randomised) distinguisher d is identified with f_d(x) = Pr[d(x, 1) accepts] − Pr[d(x, 0) accepts] ∈ [−1, 1], and the advantage is |E_{x∼μ}[f_d(x)(p₁(x) − p₂(x))]| (Lemma 5). So the advantage of a class D is the dual norm ‖p₁ − p₂‖_{μ,D} := sup_{d∈D} |⟨p₁ − p₂, d⟩_μ|, and it never exceeds the ℓ₁ distance, with equality when D contains all ±1 functions (Lemma 7). N_{μ,F₁}(F₂, ε) is the covering number of F₂ in the norm ‖·‖_{μ,F₁}.

**Theorem 13 (distribution-specific, realisable: the learner knows μ and a class P containing p*) [read].** For every P ⊆ [0,1]^X, D ⊆ [−1,1]^X, μ, ε > 0, δ ∈ (0,1):

  log N_{μ,D}(P, 2ε) + log(1 − δ) ≤ SAMP ≤ O(ε^(−4)·log N_{μ,D}(P, ε/32) + ε^(−2)·log(2/δ)),

and

  Ω(ε²·log N_{μ,P}(D, 16ε)) − 1 + log(1 − δ) ≤ SAMP ≤ O(ε^(−2)·log N_{μ,P}(D, ε/4) + ε^(−2)·log(2/δ)).

So the cost is governed, up to powers of 1/ε, by the metric entropy of the truth class measured by the tests, and equally by the metric entropy of the test class measured by the truth class. The upper bound comes from Algorithm 2 ("distinguisher covering"): cover D in the norm defined by P − P, estimate ⟨p*, d⟩ for the covering tests from the sample, and output a predictor of P that nearly matches them (Lemma 9; the same algorithm is 3·inf + ε agnostic).

**Theorem 15 (distribution-free, P = all predictors) [read].**

  fat_D(12ε)/8 + log(1 − δ) ≤ SAMP ≤ O(ε^(−4)·(fat_D(ε/25)·(log(2/ε))² + log(2/δ))).

"Our result refines the log|D| in the sample complexity upper bounds by Dwork et al. [2021] (for OI) and by Hébert-Johnson et al. [2018] (for multicalibration) to the fat-shattering dimension of D with a matching lower bound" (p. 7).

**Remark 16 [read].** Without assuming P = [0,1]^X: SAMP-DF-R(P, D, ε, δ) ≤ O(ε^(−4)·(min{fat_D(ε/25), fat_P(ε²/20)}·(log(2/ε))² + log(2/δ))). This is the "smaller of the two complexities" statement. They note it is not a characterisation.

**Agnostic OI is different [read, §1.3 and §6].** "The sample complexity of agnostic OI can increase when we remove some distinguishers from D, and it can become arbitrarily large even when the realizable sample complexity is bounded by a constant."

They also record why one cannot do with less than estimating the tests: "learning a predictor p with MDA below ε w.r.t. to the target predictor p* necessarily requires estimating the acceptance probability of every distinguisher in D on p* within error ε (the estimates are simply the acceptance probabilities on p)" (p. 6).

### 2.5 Beyond binary outcomes: generative models (Dwork, Kim, Reingold, Rothblum, Yona, ALT 2022)

This is the paper closest to a sampler with long outputs.

**Definition 5 (Generative OI) [read].** "Fix a family of distinguishers A ⊆ {X × Y × Δ(Y) → {0, 1}} and an advantage ε > 0. A generative outcome model M: X → Δ(Y) is (A, ε)-generative-outcome indistinguishable if for all A ∈ A, | Pr_{(X,Y*)∼D*}[A(X, Y*; M(X))] − Pr_{X∼D*_X}[A(X, G(M(X)); M(X))] | ≤ ε", where G(M(X)) is a draw from M(X). "The notion is always definitionally feasible, as we can always take M to be D*_{Y|X}" (p. 18). "If A is taken to be the class of all (possibly-inefficient) statistical distinguishers, then the only way to obtain A-OI would be to learn Nature's probability law in statistical distance. Without any assumptions on the complexity of D*, however, learning in statistical distance is information-theoretically impossible from a bounded sample" (p. 16).

**The algorithm [read, §5].** Start from a prior P_Y for every x. While some A has |ε_A| > ε, re-weight: for every x, multiply the probability of {y : A(x, y; M(x)) = 1} by e^(±η) and renormalise. The model is kept implicitly as the list of tests used and the signs. The returned model is

  W^{B_T(·)}(W^{B_{T−1}(·)}(… W^{B_1(·)}(R(P_Y); η₁) …; η_{T−1}); η_T),

the prior tilted by the tests found (p. 25).

* Proposition 17: with η = ε/2 the algorithm returns an (A, ε)-generative OI model in T ≤ O(φ_KL(P_Y)/ε²) iterations, where φ_KL(P_Y) = E_{X∼D*_X} KL(D*_{Y|X}; P_Y). The potential drops by at least ε²/4 per update.
* Proposition 18: with probability 1 − δ, m ≤ T·O(log(T|A|/δ)/ε²) ≤ Õ(φ_KL(P_Y)·log(|A|/δ)/ε⁴) samples.
* Theorem 20, for a discrete outcome domain Y: sample complexity Õ(log|Y|·log|A|/ε⁴); the learned model generates a sample in time Õ(|Y|·time_A·log|A|/ε²).
* For no-access tests: "we only need to obtain valid estimates of the acceptance probability of the distinguishers once (as there is no dependence on M̃), so we can avoid the factor T blow-up and only take m = O(log|A|/ε²) labeled samples from D*" (p. 30).

So for strings of length λ the number of samples is at most of order λ·log|A|/ε⁴ and, for tests that do not look at the model, does not depend on λ at all; the time to generate one sample is of order 2^λ.

**Weaker notions for partial predictions [read, §1.3, §4, §6].** A predictor of statistics (say mean and variance) is *existentially* OI if some generative model consistent with the predicted statistics fools the tests, and *obliviously* OI if it fools the tests whose acceptance probability depends on the outcome law only through the statistic. Theorem 1 (informal): for a statistic that "linearises" (is an expectation of a function of the outcome), oblivious OI is equivalent to multicalibration of the statistic, with ε and α within constant factors.

**Many outcome classes.** Dwork, Lee, Lin, Tankala (COLT 2023) [read]: Lemma 5.10: their no-regret algorithm yields an (A, ε)-outcome-indistinguishable predictor over a finite outcome set O with t ≲ log|O|/ε² updates and n ≲ log(|A|t)/ε² samples per update. Full multicalibration with ℓ = |O| outcomes needs about log|C| + (1/ε)^ℓ samples in their bound (previous bound: log|C|·(ℓ/ε)^(4ℓ)), "the dependence on ℓ is simply exp(ℓ)" (p. 3). Low-degree multicalibration (Gopalan, Kim, Singhal, Zhao, COLT 2022) avoids the exponential [read: abstract]. For outputs that are long strings, ℓ = 2^λ, so only the no-access notion, or notions that look at the model through a few statistics, are available at a cost polynomial in λ.

### 2.6 Leakage simulation: the same statement in cryptography

The problem [read: Skórski 2016, §1.2; Dwork–Lee–Lin–Tankala 2023, §4]: given correlated (X, Z) with Z ∈ {0,1}^ℓ, find a randomised h of low complexity such that (X, h(X)) and (X, Z) are indistinguishable by circuits of size s with advantage ε. "No access outcome indistinguishability is equivalent to leakage simulation" (Dwork et al. 2023, p. 17).

| source | complexity of the simulator h | status |
|---|---|---|
| Jetchev, Pietrzak (TCC 2014), as claimed in their abstract | O(s·2^(3ℓ)·ε^(−2)) | [search result only] |
| the same, as corrected by Skórski (Theorem 1) | O(s·2^(4ℓ)·ε^(−4)) | [read, secondary] |
| Vadhan, Zheng (CRYPTO 2013), as stated by Skórski (Theorem 2) | O(s·2^ℓ·ε^(−2) + 2^ℓ·ε^(−4)) | [read, secondary] |
| Skórski (TCC 2016), Theorem 3 | O(s·2^(5ℓ)·ε^(−2)) | [read] |
| Chen, Chung, Liao (EUROCRYPT 2018) | Õ(s·2^ℓ·ε^(−2)), and Ω(2^ℓ·ε^(−2)) calls to the distinguishers for black-box simulators | upper bound: [search result only]; lower bound: [read, secondary: Dwork et al. 2023, p. 17, state it as Ω(ℓ′·ε^(−2)) black-box calls for ℓ′ outcomes, for simulators that call the distinguishers only on their own input] |

The exponential dependence on the output length ℓ is a statement about the *complexity of the imitation relative to the tests*, and Chen–Chung–Liao show it is necessary for black-box constructions. It is not a statement about samples. Footnote 1 of Skórski [read] gives the standard reason why closeness in total variation is the wrong demand here: for Z = f(X) with f hard to predict, any efficient h is far from Z in total variation.

### 2.7 Tests as downstream users: omnipredictors and Loss OI

**Gopalan, Kalai, Reingold, Sharan, Wieder (ITCS 2022) [read].** Definition 4.1: f: X → [0, 1] is an (L, C, δ)-omnipredictor if for every loss ℓ ∈ L there is k: [0, 1] → R with ℓ_D(k ∘ f) ≤ min_{c∈C} ℓ_D(c) + δ. Lemma 4.2: the true predictor f* is an (L, C, 0)-omnipredictor for every C, L. Theorem 6.3: if a partition S of X is α-approximately multicalibrated for C, D (Definition 5.3: E_{i∼D}|Cov_{D_i}[c(x), y]| ≤ α for all c ∈ C), its canonical predictor is an (L, C, 2αB + ε)-omnipredictor for the class L(B, ε) of "nice" (convex, Lipschitz-type) losses. Corollary 6.5 extends this to linear combinations of weight W of functions in C, with error 2αBW + ε.

**Gopalan, Hu, Kim, Reingold, Wieder (ITCS 2023) [read: abstract and Propositions 1–3].** A predictor is *Loss OI* for (L, C) if it is indistinguishable from Nature by the tests built from a loss in L and a hypothesis in C; Loss OI implies omniprediction (Proposition 1), and it decomposes into a calibration condition and a multiaccuracy condition for a class derived from L and C (Proposition 2).

*Reading for imitation [mine].* The useful way to choose a test class is by the *uses* of the outputs: a test per (user, loss). An imitator indistinguishable for those tests serves each of those users as well as the human would. In a scaffold, the user of the answer to call j is the rest of the run; the corresponding test is the continuation value of §3.7.

### 2.8 Shift: universal adaptability, and the price of a subpopulation

**Kim, Kern, Goldwasser, Kreuter, Reingold (PNAS 119(4), e2108097119, 2022).** Not accessible here. Ye and Li (arXiv:2405.15948) state the definition "following the definition of Kim et al. (2022)" (their Definition 1) and prove the corresponding theorem in their own setting of survival data (their Theorem 3) [read, secondary]: for a class Σ of propensity scores σ (conditional probabilities of membership), with H(Σ) the class of the corresponding odds ratios w = r·(1 − σ)/σ, a predictor is (Σ, α)-universally adaptable if its error in estimating the mean outcome on the target is at most the error of the inverse-propensity-weighted estimator with the best-fitting weight in H(Σ), plus α; and a predictor that is (H, α′)-multicalibrated on the source satisfies, for any target and any candidate weight w̃, Err_T(predictor) ≤ Err_T(weighted estimator with w̃) + C̃·inf_{h∈H}{d(h, w) + d(h, w̃)} + α′, where w is the true density ratio and d a distance between weights. As summarised by Wu et al. (arXiv:2406.00661) [read, secondary]: "whenever the set of real-valued grouping functions H includes the density ratio between the source and target distributions, a multicalibrated predictor with respect to the source remains calibrated in the shifted target distribution." Kim and Perdomo (ITCS 2023) [read: abstract] recover universal adaptability from a "performative" version of OI.

**The mechanism [mine; two lines].** Under covariate shift (the conditional law of y given x is the same on source D₀ and target D), with w = dD/dD₀: E_D[g(x, y)] = E_{D₀}[w(x)·g(x, y)]. So a guarantee for the tests {w·t : w ∈ W, t ∈ T} on the source is a guarantee for the tests T on every target whose density ratio is in W, and a density ratio within η of W in L¹(D₀) costs an additional η. The shift class is a class of tests. Theorem I2 and the remark after it are this statement for samplers.

**The price of conditioning [read].** Theorem 4.3 of Dwork et al. 2021 (factor γ_C, §2.2) and Corollary 3.4 of Hébert-Johnson et al. 2018 (samples proportional to 1/γ): a guarantee inside a subpopulation of frequency γ costs a factor 1/γ in samples.

### 2.9 Generative models, structured and huge outputs

**The restricted distance generalises; the unrestricted one does not.** Arora, Ge, Liang, Ma, Zhang (ICML 2017) [read]. For a class F of discriminators with p parameters, L-Lipschitz in the parameters, a measuring function φ that is L_φ-Lipschitz with values in [−Δ, Δ], and the distance d_F(μ, ν) = sup_{D∈F} |E_μ D − E_ν D| (the case φ(t) = t): Theorem 3.1: with m ≥ c·p·Δ²·log(L·L_φ·p/ε)/ε² samples each, |d_{F,φ}(μ̂, ν̂) − d_{F,φ}(μ, ν)| ≤ ε with probability at least 1 − e^(−p). Corollary 3.2 ("Low-capacity discriminators cannot detect lack of diversity"): for the same m, d_{F,φ}(μ, μ̂) ≤ ε, "that is, the neural network distance for nets with p parameters cannot distinguish between a distribution μ and a distribution with support Õ(p/ε²)." Sun, Vemula, Boots, Bagnell (ICML 2019), Theorem 3.2 ("Infinite Capacity F does not generalize") [read]: with the class of all bounded functions as discriminators (total variation), the empirical distance between two sample sets of the *same* distribution stays maximal unless the sample size is polynomial in the number of observations |X|.

**Truthfulness: properties that must hold always.** Goldreich, Goldwasser, Nussboim (SIAM J. Comput. 39(7), 2010) introduced implementations of huge random objects that are *truthful*: "a truthful implementation of a random object of Type T must (always) be an object of Type T, and not merely be indistinguishable from a random object of Type T" [search result quoting the abstract]. Hu, Livni-Navon, Reingold (arXiv:2302.12823) [read: §1] study the reverse direction, a distribution of huge objects indistinguishable from *one* unknown huge object B* (for instance a function on {0,1}^n) learned from samples, with truthfulness: "a generative model M is truthful if every object B drawn from the distribution represented by M satisfies a certain global property." Theorem 1.1 (informal): for functions with support size exactly k and an efficiently learnable class of sample-access distinguishers there is an efficient learner whose model is indistinguishable and always has support size k. They note that such a global property "cannot be enforced simply using computationally-bounded distinguishers" and cannot hold for a model that draws each value independently.

*Reading [mine].* This is the literature's name for the distinction between properties one wants *always* (hard constraints, built into the imitator) and properties one wants *as often as the human has them* (tests).

**Calibration of a generator forces invention.** Kalai, Vempala (STOC 2024) [read: abstract, Corollary 1, Theorem 1]. For a language model whose document distribution is calibrated in their generative sense (Definitions 1–2: after coarsening by the model's own probabilities, model and world agree), and for "arbitrary facts whose veracity cannot be determined from the training data": Corollary 1: for any algorithm, with probability at least 1 − δ, the hallucination rate satisfies g(H) ≥ M̂F − Mis_b(g, p) − 3e^(−s)/δ − √(6·ln(6/δ)/n), where M̂F is the Good–Turing estimate of the missing mass of facts (the fraction of training facts seen once) and Mis_b is the miscalibration. In words: a generator that passes its own calibration tests must state unseen "facts" at about the rate at which the truth contains them.

**Generation that keeps an unknown property.** Kleinberg, Mullainathan (NeurIPS 2024) [read]. An adversary enumerates the strings of an unknown language K from a countable list C. (2.1): "There is an algorithm with the property that for any countable collection of languages C = {L₁, L₂, …}, and any enumeration of one of these languages K, the algorithm generates from K in the limit", that is, after some finite time it outputs only unseen strings of K. This holds although identification in the limit is impossible (Gold; Angluin). With prompts, (7.1): the same for completions of prompts, including prompts never seen, provided every prompt is "robust" (every language of C contains arbitrarily long completions of it). For finite C there is a uniform bound t(C) on the number of distinct samples after which generation is correct for ever. Li, Raman, Tewari (arXiv:2410.13714) [read]: Theorem 3.3: a class is uniformly generatable if and only if its *closure dimension* is finite (Definition 3.1: the largest d such that some d distinct points have a finite, non-empty closure, the closure being the intersection of the supports of all hypotheses containing the points); "the optimal uniform generation sample complexity is exactly Θ(C(H))". Corollary 3.6: every countable class is non-uniformly generatable. Their prompted notions require "a sufficient number of distinct examples with prompt y"; they contrast this with Kleinberg–Mullainathan's, where "the generator must eventually perfectly complete prompts it may have never seen in the past" (in the limit only). Kalavasis, Mehrotra, Velegkas (arXiv:2411.09642) [read: abstract]: generation with both consistency (only valid strings) and breadth (all of them) "is impossible for most collections of candidate languages" for a large class of generators.

*Reading [mine].* This is the nearest literature to the researcher's "property induction" and "positive example induction" (`notes.md`, §2.5–2.6). Its method is to output only what *every* candidate property consistent with the examples allows (the closure). That keeps the property and gives up breadth, and for a prompt it works only if the consistent candidates share a completion of that prompt. For a class closed under exceptions ("K, except that on prompts with property Q the valid completions are others") they share none at an unseen prompt in Q; so the positive results are in the limit of complete enumeration, or after enough examples with that prompt. This agrees with Theorem N1 of the note.

**Outputs that carry their own check.** Amit, Goldwasser, Paradise, Rothblum (arXiv:2405.15722) [read: abstract]. A *self-proving model* "with high probability over an input sampled from a given distribution … generates a correct output and successfully proves its correctness to V" by an interactive proof; "the soundness property of V guarantees that, for every input, no model can convince V of the correctness of an incorrect output."

### 2.10 Composition in the imitation-learning literature: which moments, and what horizon factor

Swamy, Choudhury, Bagnell, Wu (ICML 2021) [read]. A learner π and an expert π_E act for T steps; the imitation gap is J(π_E) − J(π) for an unknown reward. Three kinds of moment can be matched, each with a discriminator class F closed under negation:

| moments | what is compared | data needed | upper bound | lower bound |
|---|---|---|---|---|
| reward moments, class F_r | sums of f(s_t, a_t) along learner runs and along expert runs | expert runs; learner runs in the environment | Lemma 1: O(εT) | Lemma 2: Ω(εT) |
| off-policy Q moments, class F_Q of Q-functions of all policies | f(s, a) for a ∼ π(s) against the expert's action, on *expert* states | expert runs only (behaviour cloning) | Lemma 3: O(εT²) | Lemma 4: Ω(εT²) |
| on-policy Q moments, class F_{Q_E} of the *expert's* Q-functions | f(s, a) for the learner's action against a ∼ π_E(s), on *learner* states | an expert that can be asked at the learner's states | Lemma 5: O(εHT) under H-recoverability | Lemma 6: Ω(εT) |

Definition 2: (π_E, F_{Q_E}) is H-recoverable if |f(s, a) − E_{a′∼π_E(s)} f(s, a′)| < H for all s, a and f ∈ F_{Q_E}; "H tells us how many time-steps it takes the expert to recover from an arbitrary mistake." Each bound assumes that the class "spans" the relevant functions (the true reward, or the relevant Q-functions, lies in it). The bounds follow from the performance difference lemma of Kakade and Langford (ICML 2002), expanded in one order or the other. "Our bounds do not depend on the size of the state space."

Sun, Vemula, Boots, Bagnell (ICML 2019) [read]: Assumption 2.1 is "π*_h ∈ Π_h and V*_h ∈ F_h": the expert's value function lies in the discriminator class. Theorem 3.3: under it, their algorithm outputs a policy with J(π) − J(π*) ≤ H²ε′_be + H²ε from Õ(HK·log(|Π||F|/δ)/ε²) trajectories (K the number of actions, ε′_be an averaged inherent Bellman error), a number "independent of the number of unique observations".

Abbeel, Ng (ICML 2004) [memory]: if the reward is linear in k known features, matching the expert's discounted feature expectations to accuracy ε gives a policy within ε of the expert for every such reward, and the number of expert trajectories needed is of order k·log(k/δ)/(ε(1 − γ))²: it depends on the number of features and not on the expert. Syed, Schapire (NIPS 2007) [memory]: the same as a zero-sum game solved by multiplicative weights. Ross, Bagnell (AISTATS 2010) and Ross, Gordon, Bagnell (AISTATS 2011) [memory in this digest; the companion digest `imitation-theory.md` quotes both theorems from the sources]: behaviour cloning with per-step error ε loses up to T²ε, and with the error measured on the learner's own state distribution and an expert that can be asked this becomes uTε, u bounding the increase of the expert's cost-to-go caused by one deviation.

### 2.11 On any sequence: forecasting that passes tests, and its generative form

* Dawid (JASA 1982) proposed calibration as a minimal demand; Foster and Vohra (Biometrika 1998) showed a randomised forecaster can be calibrated on every sequence; Lehrer (Econometrica 2001) and Sandroni, Smorodinsky, Vohra (Math. Oper. Res. 28(1), 2003) extended this to countably many "checking rules": "Given any countable partition of [0,1] and any countable collection of subsequences, we construct a forecasting scheme such that for all infinite strings of data, the long run average forecast for a matches the long run frequency of realized a's" [search result quoting the abstract]; Sandroni (Int. J. Game Theory 32(1), 2003): any test that every true law passes can be passed without knowing the law (as described in Dwork et al. 2021, §1.4 [read]).
* Vovk, Takemura, Shafer (AISTATS 2005; arXiv cs/0505083) [read]. A Skeptic bets against the forecasts; his capital K_n measures how badly the forecasts have been refuted. Theorem 1: in the game where Skeptic announces a continuous strategy S_n: [0, 1] → R before Forecaster moves, "Forecaster has a strategy … that ensures K₀ ≥ K₁ ≥ K₂ ≥ ⋯", whatever Reality does. The strategy: choose p_n with S_n(p_n) = 0 if there is one; otherwise p_n = 1 if S_n > 0 and p_n = 0 if S_n < 0. For a test that does not look at the forecast this is a deterministic forecast in {0, 1}.
* Gupta, Jung, Noarov, Pai, Roth (arXiv:2101.01739; ITCS 2022) [read]. Online multicalibration against an adversary for a finite collection G of groups and n buckets. The surrogate loss is L_s = Σ_{G,i} (exp(ηV_s^{G,i}) + exp(−ηV_s^{G,i})) (Definition 3.2), with V the signed calibration error of group G and bucket i. Theorem 3.2: E[α] ≤ 1/(rn) + 2·√(2·ln(2|G|n)/T).
* Noarov, Ramalingam, Roth, Xie (ICML 2025), as described by Farina and Perdomo [read, secondary]: "√(T·log|F|) regret" for high-dimensional online multicalibration with a finite set F that is enumerated.
* Farina, Perdomo, "Defensive Generation" (arXiv:2602.21390, February 2026) [read: §1]. Definition 1: an algorithm "satisfies online outcome indistinguishability with respect to a class of distinguishers F if it produces distributions μ_t over Y and statistics p_t such that for any f ∈ F, OIGap_T(f) := | Σ_t E_{p_t}[f(x_t, p_t, y_t)] − Σ_t E_{p_t, ỹ_t∼μ_t}[f(x_t, p_t, ỹ_t)] | is o(T) regardless of Nature's choices of (x_t, y_t)." Theorem 1 (informal): for multiclass outcomes, scalar outcomes (tests of the first d moments) and vector outcomes (tests of mean and covariance), and distinguishers in a reproducing-kernel Hilbert space, OIGap_T ≤ O(√T) in time poly(d)·log t per round. For next-token generation with tests linear in an embedding Φ of the history: (1/T)·OIGap_T(f_h) ≤ 4‖h‖·√(G/T). They state that √T is optimal, citing Vovk (2007), and they say of their own guarantee: "Our work on online OI … does not guarantee closeness in statistical distance nor does it rely on unverifiable function approximation assumptions."

---

## 3. The statement one would want here

Everything in this section is **[mine]** unless tagged otherwise: my own derivation, unrefereed. The methods are standard (Hoeffding and Bernstein with a weighted union bound; selection by minimum distance; the performance difference lemma; an exponential potential on any sequence), and for binary outcomes the first statements are those of §2.2–2.4.

### 3.1 The problem, and three facts about its shape

Inputs x; outputs y ∼ P(·|x), which may be long strings; a family T of tests of pairs (x, y); a family 𝒟 of input distributions. The learner chooses the inputs it puts to P, and each question is answered by a fresh draw (assumption A1 of the note). It outputs a sampler P′. Wanted, with probability at least 1 − δ:

  |P_D(t) − P′_D(t)| ≤ ε for all t ∈ T and all D ∈ 𝒟.

Compute is free. In particular, for a candidate sampler S the pass rates S_D(t) can be found to any accuracy without the human; I write as if they were known exactly.

1. **The demand is linear in the sampler.** S_D(t) = Σ_x D(x) Σ_y S(y|x)·t(x, y). The set of samplers that meet any list of constraints "S_D(t) lies in an interval" is convex. This is the structure that Hu, Peale and Reingold exploit for binary outcomes (§2.4); nothing in it depends on the size of Y.
2. **The human always meets the demand.** So existence is never the issue; the issues are how many questions are needed to know the numbers P_D(t), and which of the many samplers that meet the demand one gets.
3. **Knowing the numbers P_D(t) to within ε is necessary**, because P′_D(t) is known by compute and is within ε of P_D(t) (the remark of Hu, Peale and Reingold quoted in §2.4).

### 3.2 One input distribution

**Theorem I1.** Let D be an input distribution that can be sampled, P any sampler, T a countable family of tests with weights π. Draw x₁, …, x_n independently from D and put each to the human once, with answers y_i ∼ P(·|x_i). Let p̂(t) := (1/n)·Σ_i t(x_i, y_i) and r_n(t) := √(ln(2/(π(t)·δ))/(2n)), and let F be the set of samplers S with |S_D(t) − p̂(t)| ≤ r_n(t) for every t ∈ T. With probability at least 1 − δ:

(i) P ∈ F;
(ii) every S ∈ F satisfies |S_D(t) − P_D(t)| ≤ 2·r_n(t) for every t ∈ T.

For a finite family, n ≥ 2·ln(2|T|/δ)/ε² questions give (T, ε)-indistinguishability on D. With π(t) = 2^(−K(t)), every S ∈ F has |S_D(t) − P_D(t)| ≤ √(2·(K(t)·ln 2 + ln(2/δ))/n) for all tests at once.

*Proof.* For fixed t the values t(x_i, y_i) are independent, lie in [0, 1] and have mean P_D(t). By Hoeffding's inequality |p̂(t) − P_D(t)| > r_n(t) has probability at most 2·exp(−2n·r_n(t)²) = π(t)·δ; sum over t. On the complementary event P ∈ F, and (ii) is the triangle inequality. ∎

What the theorem uses about the human: only that the n answers are independent draws from P(·|x_i) (A1). What it does not use: any class containing P, computability of P, the length of the outputs, any cleverness in the choice of questions. Membership in F is checked by compute alone. For binary outputs this is no-access OI learned from log(|A|/δ)/ε² samples (§2.2, §2.5).

**Lemma I1a (F always contains samplers that have nothing to do with the human).** Let T be finite.

(a) *A re-weighted reference.* (Dwork et al. 2022, Proposition 17 [read], for tests in {0,1} that do not look at the model. Their prior is the same for every x; the proof is unchanged for a reference that depends on x, and their bound "the potential drops by at least ε²/4 per update" gives the count below.) Let R be any sampler with Φ := E_{x∼D} KL(P(·|x) ‖ R(·|x)) < ∞. There are at most 4Φ/ε² tests t₁, t₂, … ∈ T and signs σ_k = ±1 such that the sampler

  S(y|x) ∝ R(y|x)·exp((ε/2)·Σ_k σ_k·t_k(x, y))

is (T, ε)-indistinguishable from P on D. If P is a function with outputs of at most λ bits and R is uniform on the strings of at most λ bits, Φ ≤ (λ + 1)·ln 2: the sampler S is described by R, T and fewer than 2.8·(λ + 1)/ε² pairs (test, sign), whatever P is.

(b) *Few deterministic answers.* For every m > ln(2|T|)/(2ε²) there are functions f₁, …, f_m: X → Y such that the sampler "choose i uniformly from {1, …, m} and answer f_i(x)" is (T, ε)-indistinguishable from P on D.

*Proof of (b).* Draw the f_i independently, each with independent values f_i(x) ∼ P(·|x). For fixed t the numbers Z_i := E_{x∼D} t(x, f_i(x)) are independent, lie in [0, 1] and have mean P_D(t). By Hoeffding's inequality and a union bound over T, with positive probability |(1/m)·Σ_i Z_i − P_D(t)| ≤ ε for all t. ∎

Part (a) says what the simplest indistinguishable imitator is: the reference sampler, re-weighted towards the tests the human passes more often than the reference does. If T contains the test "y is a correct solution of x" and the human passes it with frequency 0.9, then S is the reference conditioned, softly, on being a correct solution, at about that frequency. With unbounded compute this is a search over outputs with the test as its filter. Part (b) is the conditional form of the corollary of Arora et al. (§2.9): tests of limited number cannot detect that the imitator has almost no variety.

**Lower bounds.** (i) For binary outputs, samples drawn from an unknown D, and P arbitrary, at least fat_T(12ε)/8 + log₂(1 − δ) samples are needed (Hu, Peale, Reingold 2022, Theorem 15 [read]); for a family of 2^d tests that shatters d points this is of order d = log₂|T|. (ii) Even for one test and one input, Ω(ln(1/δ)/ε²) questions are needed when P may be any sampler: take X = {x₀}, P(·|x₀) a coin of unknown bias, t(x, y) = y; by fact 3 of §3.1 the learner must estimate the bias to within ε. [The bound for estimating a bias is standard; from memory.] I did not find or prove a lower bound that has both the factor ln|T| and chosen queries; I see no way in which choosing the questions helps for tests on one fixed D when P is arbitrary. Where choice helps is §3.3.

### 3.3 Families of input distributions, and the questions the learner chooses

**Theorem I2.** Let 𝒟 be a countable family of input distributions that can be sampled, with weights ρ, and T a countable family of tests with weights π. Given a budget of n questions, put n_D := ⌊ρ(D)·n⌋ questions to independent draws from D, for each D. Let p̂_D(t) be the mean of t over the n_D pairs obtained for D and r(D, t) := √(ln(2/(ρ(D)·π(t)·δ))/(2n_D)) when n_D ≥ 1. With probability at least 1 − δ, the human meets every constraint |S_D(t) − p̂_D(t)| ≤ r(D, t), and every sampler S that meets them all satisfies |S_D(t) − P_D(t)| ≤ 2·r(D, t) for all D with n_D ≥ 1 and all t.

(a) For finite T and a family of at most 2^(k+1) distributions (for instance those with a sampling program of at most k bits), with uniform weights: n = 2^(k+2)·ln(2^(k+2)·|T|/δ)/ε² + 2^(k+1) questions suffice for error ε on every member.

(b) This dependence on 2^k is necessary. Let x₁, …, x_N be N = 2^k distinct inputs, 𝒟 the N point masses, T = {t} with t(x, y) = 1[y = "1"], and let the human be either the function f₀ that answers "0" everywhere or one of the functions f_a that answer "1" at x_a and "0" elsewhere. If a protocol with at most n adaptively chosen questions outputs, for each of these N + 1 humans, with probability at least 1 − δ, a sampler that is (T, ε)-indistinguishable on every member of 𝒟, with ε < 1/2, then n ≥ (1 − 2δ)·N. With the x_j the strings of length k, every human and every distribution here has description length k + O(1).

*Proof.* The first statement is Theorem I1 applied to each D with failure probability ρ(D)·δ and tests weighted by π. For (a): r ≤ ε/2 needs n_D ≥ 2·ln(2^(k+2)·|T|/δ)/ε², and n_D ≥ n·2^(−k−1) − 1. For (b): fix the protocol's internal randomness ω. If the human is f₀ all answers are "0", so the set A(ω) of questions asked and the output P′_ω are determined. If the human is f_a with a ∉ A(ω), the answers are the same and so is the output. Indistinguishability on the point mass at x_a requires P′_ω("1"|x_a) ≤ ε for f₀ and ≥ 1 − ε for f_a; both cannot hold. So {ω: success for f₀ and for f_a} ⊆ {ω: a ∈ A(ω)}. The left side has probability at least 1 − 2δ for each a; summing over a gives N·(1 − 2δ) ≤ E|A| ≤ n. ∎

This is Theorem N1 of the note and N3 of the candidate theory, in the language of tests: the factor is the number of regions that may each hide something, and it multiplies a term that is only logarithmic in the numbers of tests and of regions.

**Remark (one base distribution; density ratios).** Suppose questions are drawn from one base distribution D₀ and the targets are D_w := w·D₀ for weight functions w in a countable class W (weights ρ), with 0 ≤ w ≤ B and E_{D₀} w = 1, each w computable. Estimate P_{D_w}(t) by (1/n)·Σ_i w(x_i)·t(x_i, y_i). The summands lie in [0, B] and have variance at most B, so by Bernstein's inequality, with probability at least 1 − δ, for all w and t the error is at most √(2BΛ/n) + 2BΛ/(3n) with Λ = ln(2/(ρ(w)·π(t)·δ)). So O(B·ln(|T||W|/δ)/ε²) questions give error ε on every target of the class. A target whose density ratio is within η of W in L¹(D₀) is covered with an additional error η. This is universal adaptability (§2.8) for samplers. Any family 𝒟 can be put in this form with D₀ ∝ sup_{D∈𝒟} D(x) and B = Σ_x sup_{D∈𝒟} D(x).

**Proposition I3 (all shifts of bounded density ratio cannot be had at the price of the tests).** Let X = {0,1}^m with D₀ uniform, Y = {0, 1}, T = {t} with t(x, y) = y, B ≥ 10, and let 𝒟 be the set of *all* D with dD/dD₀ ≤ B. Let a protocol put at most 2^(m−1) adaptively chosen questions and output P′. If the human is a uniformly random function f: X → {0, 1}, then with probability at least 1 − exp(−2^m/100) there is D ∈ 𝒟 with |P_D(t) − P′_D(t)| ≥ 1/2.

*Proof.* Let A be the set of questions asked, |A| ≤ 2^(m−1). Given the answers, the values f(x) for x ∉ A are independent fair bits, independent of P′. Write p′(x) := P′(1|x) and g(x) := f(x) − p′(x). For x ∉ A, |g(x)| ≥ 1/2 with probability at least 1/2. By Hoeffding's inequality, with probability at least 1 − exp(−2^m/100) at least 2^m/5 inputs have |g| ≥ 1/2; then at least 2^m/10 of them have the same sign of g. Let G be that set and D := D₀(·|G). Then dD/dD₀ ≤ 10 ≤ B and |P_D(t) − P′_D(t)| = |E_D g| ≥ 1/2. ∎

So for the full ball of density ratios, one test already forces a number of questions of the order of the description length 2^m of the human in the class of all functions. The reason: sup over the ball of E_D[g] is the mean of g over its upper tail of D₀-mass 1/B [the dual form of the conditional value at risk; memory]. Indistinguishability on the whole ball therefore asks that the pass probabilities of P′ and P agree *input by input* outside a set of mass about 2/B, and that is learning P. The test-only price needs a restricted class of shifts, as in Theorem I2 and the remark.

### 3.4 Properties that have held so far

**Proposition I4.** Let ℛ be a countable family of properties R ⊆ X × Y with weights π, and let the data be as in Theorem I1. With probability at least 1 − δ, every R ∈ ℛ that holds for all n data pairs satisfies

  P_D(not R) ≤ ln(1/(π(R)·δ))/n.

So the constraints "S_D(not R) ≤ ln(1/(π(R)·δ))/n for every R ∈ ℛ that held on all the data" are met by the human and may be added to F; with π(R) = 2^(−K(R)) the bound is (K(R)·ln 2 + ln(1/δ))/n.

*Proof.* If P_D(not R) = q, all n pairs satisfy R with probability (1 − q)^n ≤ e^(−qn), which is at most π(R)·δ when q ≥ ln(1/(π(R)δ))/n. Sum over R. ∎

This is the realisable Occam bound (Blumer, Ehrenfeucht, Haussler, Warmuth 1987 [memory]) with the *property* in the place of the hypothesis. Four remarks.

* It is the precise sense in which "properties of (x, y) pairs that have held so far keep holding": each does, on fresh inputs from the sampled distribution, with frequency at least 1 − (K(R)·ln 2 + ln(1/δ))/n.
* The researcher's objection (two properties that held so far and contradict each other at a new input) does not bite. Both are asked to hold with high frequency under D, so the inputs where they conflict have small D-mass, or one of them would have failed in the data. The note makes the same point in §8.2.
* The property "the pair is one of the training pairs" held on all the data. Its complexity is about the length of the data, at least one bit per pair, so its bound is vacuous. Memorisation is not forced.
* Under a target with density ratio at most B the bound is multiplied by B; on a set of inputs of D-mass q it is divided by q. Below mass about K(R)/n it says nothing, as Theorem N1 of the note requires.

A requirement of this one-sided kind is what the forecasting literature calls a test (§2.2). It has a faster rate (1/n, not 1/√n) than the two-sided matching of Theorem I1.

### 3.5 Both regimes with one learner

**Proposition I5 (it is Pr4 of the candidate theory).** Let H be a countable class of samplers with weights w, and T₀ a family of tests with weights π₀. Let T be T₀ with weights π₀/2 together with the tests A_{ν,ν′} := {(x, y) : ν(y|x) > ν′(y|x)} for ν ≠ ν′ in H with weights w(ν)·w(ν′)/2. Define F as in Theorem I1 for T, and let P̂ be a sampler of largest weight in H ∩ F (any member of F if H ∩ F is empty). With probability at least 1 − δ:

(a) with no assumption on P: |P̂_D(t) − P_D(t)| ≤ 2·r_n(t) for all t ∈ T₀;
(b) if P ∈ H with K = log₂(1/w(P)): E_{x∼D} TV(P̂(·|x), P(·|x)) ≤ √((4K·ln 2 + 2·ln(4/δ))/n).

*Proof.* (a) is Theorem I1. For (b): P ∈ H ∩ F, so w(P̂) ≥ w(P). With A := A_{P̂,P}, E_x TV(P̂(·|x), P(·|x)) = P̂_D(A) − P_D(A) ≤ 2·r_n(A), and π(A) = w(P̂)·w(P)/2 ≥ 2^(−2K)/2. ∎

The sets A_{ν,ν′} are those of Yatracos (Ann. Statist. 13(2), 1985) for minimum-distance estimation; for densities without inputs see Devroye and Lugosi, *Combinatorial Methods in Density Estimation* (Springer 2001) [memory], where the agnostic version has the factor 3 that also appears in Lemma 9 of Hu, Peale and Reingold [read]. The proposition is the statement "the smaller of the two complexities" (§2.4, Remark 16) in our notation: (a) costs ln(1/π₀(t)) and (b) costs K. In (b) the imitator is close to the human for *every* test, whatever its complexity; that, and only that, is where the description length of the human is the price.

### 3.6 Tests that look at the imitator

Three kinds occur in the imitation setting.

* **Tests of the imitator's own predictions** (the sample-access level): t(x, y, P′(·|x)), for instance "y has probability at least τ under P′(·|x)". Matching them for all τ says that the surprise −log P′(y|x) has the same law for the human's answers as for the imitator's own: the imitator is calibrated as a generator. Cost [read]: O(Φ·log(|A|/δ)/ε⁴) samples, Φ the expected divergence of the human's answer law from the prior (Dwork et al. 2022, Proposition 18); no dependence on the complexity of the human. What it forces is in §2.9 (Kalai–Vempala).
* **Tests whose inputs the imitator produced** (in effect the oracle-access level): the input distribution is that of the imitator's own runs. This is the case of composition, §3.7.
* **Tests of the imitator's code**: possible at a cost in the complexity of the imitator that is doubly exponential in 1/ε² (§2.2). I see no use for them here.

In each case the constraints depend on the candidate, so one data set cannot be used naively for all candidates. The published remedies are fresh samples for each update (the factor 1/ε² in 1/ε⁴) or the techniques of adaptive data analysis (§2.3). On any sequence, the online algorithms of §2.11 achieve the 1/√n rate without this loss, and that is what §3.7 uses.

### 3.7 Composition: when the imitator's outputs are fed back as inputs

**C0. Matching tests on a fixed input distribution says nothing about runs.** A scaffold with two calls: x₁ = "a"; x₂ = y₁; outcome u = 1[y₂ = "ok"]. The human answers "b" to "a" and "ok" to "b". Let T be any family of tests none of which tells the pair ("a", "b") from the pair ("a", "c"). Let P′ answer "c" to "a", "ok" to "b" and "no" to "c". Then P′ passes every test of T exactly as often as the human on every distribution supported on the human's calls {"a", "b"}, and its run has outcome 0 with certainty. The difference between "b" and "c" matters only through what happens downstream, so a test class that is to exclude this must contain tests that look ahead. Even when T contains all tests, indistinguishability at level ε per call on the human's calls allows the run to leave the human's path with probability Lε, and with additive costs to lose of order L²ε (the second is Swamy et al. 2021, Lemmas 3–4 [read]).

**Setting.** A scaffold of horizon L. The *state* before call j is s_j = (z, ρ, y₁, …, y_{j−1}) and the question is x_j = next_j(s_j). A *context* is c = (j, s). An *answerer* A gives a law A(·|c) on Y; a sampler is an answerer that depends on c only through x_j. An *outcome* is a function u of runs with values in [0, 1]; Q_A(u) is its expectation when A answers. For an answerer B, the *B-continuation value* is

  V^B(c, y) := E[u | the context of call j is c, its answer is y, and all later calls are answered by B].

**C1. Performance difference lemma** (Kakade, Langford 2002 [memory]; used in both orders by Swamy et al. 2021 [read]). For answerers A, B and an outcome u,

  Q_A(u) − Q_B(u) = E_{τ∼Q_A} Σ_{calls j of τ} [ V^B(c_j, y_j) − E_{y∼B(·|c_j)} V^B(c_j, y) ].

*Proof.* Let H_k be the law of the run in which calls 1, …, k are answered by A and later calls by B; H₀ = Q_B and H_L = Q_A. In H_k and H_{k−1} the context c_k has the same law as under Q_A; given c_k, the expected outcome is E_{y∼A(·|c_k)} V^B(c_k, y) in H_k and E_{y∼B(·|c_k)} V^B(c_k, y) in H_{k−1}. Sum over k. ∎

With B = P: the imitator's run differs from the human system's, in the expectation of u, by the sum over the imitator's own calls of how much the imitator's answer changes the human system's chance of success from there. The function V^P(c, y) is a *test* in the sense of this digest (a function of a context and an answer with values in [0, 1]). It is the test "how well would the human system do from here".

**C2. Per-call tests on the imitator's own distribution.** Tests are now functions b of (context, answer) with values in [0, 1], in a countable family with weights π. The *property imitator* of the note (§8.3), with contexts in place of questions: keep S_t(b) := Σ_{r≤t} g_r(b) and let the rule a_t of round t answer a context c with a y that minimises Σ_b π(b)·sinh(η·S_{t−1}(b))·b(c, y). Rehearsal as in §2 of the note: in round t run the scaffold with the rule a_t answering every call; choose J uniformly from {1, …, L}; if the run has a J-th call, put its question to the human and set g_t(b) := b(c_J, a_t(c_J)) − b(c_J, y^P), otherwise g_t := 0. Deploy, for each run, the rule of a uniformly chosen round.

**Theorem C2.** Assume A1 and A3 of the note; assume nothing else about the human. Let η = 1/√n. For every outcome u whose human continuation value V = V^P is a member of the family,

  | E[u(deployed run)] − Q_P(u) | ≤ L·(ln(2/π(V)) + 1/2)/√n,

the expectation being over rehearsal, the choice of round and the deployed run. If V is only within ξ, uniformly, of a member b of the family, the bound holds with π(b) and an additional 2Lξ.

*Proof.* (i) On every sequence, |S_n(b)| ≤ ln(2/π(b))/η + nη/2 for every b. This is Theorem Pr5 of the note, whose proof extends from sets to tests with values in [0, 1] as follows: for g ∈ [−1, 1], convexity of cosh gives cosh(η(S + g)) ≤ cosh(ηS)·cosh(η) + g·sinh(ηS)·sinh(η), and the rest is unchanged. (ii) By A1 and A3, the conditional expectation of g_t(b) given the past is (1/L)·E_{τ∼Q_{a_t}} Σ_j [b(c_j, y_j) − E_{y∼P(·|x_j)} b(c_j, y)]. (iii) For b = V this equals (Q_{a_t}(u) − Q_P(u))/L by C1. (iv) Hence |E Σ_t (Q_{a_t}(u) − Q_P(u))| = L·|E S_n(V)| ≤ L·(√n·ln(2/π(V)) + √n/2); divide by n. ∎

What this is. It is "on-policy Q-value moment matching" (§2.10) carried out by the online algorithm that the note already has, and sampled the way rehearsal samples: single calls of the human at inputs from the imitator's own runs. The assumption "V^P is in the family" plays the role that "P is in the class" plays for the mixture; it is the assumption of Sun et al. (their 2.1) and the "spanning" assumption of Swamy et al.

What to be clear about.

* The price is ln(1/π(V^P)), about K(V^P)·ln 2: the complexity of *how the human system's chance of success depends on the work so far*. It satisfies K(V^P) ≤ K(P) + K(scaffold, u) + O(1) and can be far smaller: in the tree of additions of the note's toy, V is "the partial sums so far are right, times the chance that the remaining additions come out right", whatever else the human is. It is not known in advance, and nothing certifies that it is small.
* The outcome u must be a function of the run that a program can compute (or approximate), or V is not a test of the family.
* The imitator has to evaluate tests of the context, so it is an answerer that sees the state of the run, unless V depends on the context only through (j, x_j). A scaffold can be put in that form by writing the state into every question, which changes what the human is asked.
* The guarantee is two-sided and concerns only u: the deployed system succeeds *as often as the human system*. Lemma I1a applies: an imitator that does the task by other means and fails on purpose at the human's rate satisfies it.
* For infinite Y take a y within a small slack of the infimum; the slack adds a negligible term. Whether the infimum can be found is a matter of compute only.
* As in the note, the bound is for a fresh rule in each run.

**Remark (a better rate for C2 and for Theorem Pr5).** With a single η the error per test is of order ln(1/π)/√n. A mixture over rates gives order √(ln(1/π)/n). Take rates η_i = 2^(−i), i ≥ 0, with weights ρ_i = 1/((i+1)(i+2)); use the potential Ψ_t := Σ_b Σ_i π(b)·ρ_i·e^(−t·η_i²/2)·cosh(η_i·S_t(b)) and let the rule minimise Σ_b Σ_i π(b)·ρ_i·e^(−t·η_i²/2)·sinh(η_i)·sinh(η_i·S_{t−1}(b))·b(c, y). By the same convexity inequality and cosh(η) ≤ e^(η²/2), Ψ_t ≤ Ψ_{t−1} ≤ 1. So for every b and i, |S_n(b)| ≤ ln(2/(π(b)ρ_i))/η_i + n·η_i/2, and choosing i with η_i in (η*/2, η*] for η* := √(2Λ_b/n) gives

  |S_n(b)| ≤ (3/√2)·√(n·Λ_b), Λ_b := ln(2/π(b)) + 2·ln(log₂ n + 2), whenever Λ_b ≤ n/2 and n ≥ 4.

[Mine; a sketch with the constants not optimised. I checked the two inequalities numerically and ran the rule on a toy sequence with 300 tests, where both bounds held with room (scratch scripts, not kept in the repository). The device of mixing over learning rates is standard in online learning; the rate √(T·log|F|) for a finite set of tests is attributed to Noarov et al. 2025 by Farina and Perdomo, §2.11.] With it the bound of Theorem C2 becomes (3/√2)·L·√(Λ_V/n).

**C2′. A certificate for outcomes from the validation phase.** Freeze any answerer A, however obtained. Run the validation phase of the note with m rounds, recording in each round the context c of the asked call, A's answer y^A and the human's answer y^P. For a test b let d̂(b) := (1/m)·Σ_rounds [b(c, y^A) − b(c, y^P)] (rounds without a J-th call count as 0). By Theorem V1(b) of the note, extended from sets of pairs to tests of contexts, with probability at least 1 − δ, for all b at once, the per-call difference Δ(b) := (1/L)·E_{τ∼Q_A} Σ_j [b(c_j, y_j) − E_{y∼P} b(c_j, y)] is within √(2·ln(2/(π(b)·δ))/m) of d̂(b). By C1, Q_A(u) − Q_P(u) = L·Δ(V^{P,u}). Hence, with probability at least 1 − δ, for every outcome u at once,

  |Q_A(u) − Q_P(u)| ≤ L·( |d̂(V^{P,u})| + √(2·ln(2/(π(V^{P,u})·δ))/m) ),

and in particular, for every u with π(V^{P,u}) ≥ 2^(−k),

  |Q_A(u) − Q_P(u)| ≤ L·( max{|d̂(b)| : π(b) ≥ 2^(−k)} + √(2·(k·ln 2 + ln(2/δ))/m) ).

The right-hand side is computed from the validation record. This needs A1 and A3 only. It turns the per-call certificate of the note into a statement about outcomes of runs, for every outcome whose human continuation value is a test of weight at least 2^(−k); it does not tell us which outcomes those are.

**C3. Low stakes remove the factor L.** Suppose that from every context no single answer matters much to the human system: |V(c, y) − V(c, y′)| ≤ h for all c, y, y′. Then V(c, ·) can be shifted and stretched: if the family contains a test b with b(c, y) − b(c, y′) = (V(c, y) − V(c, y′))/h for all c, y, y′, then Δ(V) = h·Δ(b), and in Theorem C2 and in C2′ the factor L becomes L·h, with π(b) in place of π(V). For h = c₀/L the bounds do not depend on the horizon. This is H-recoverability in the sense of Swamy et al. (§2.10); their H, measured in units of one step's reward, corresponds to h·T up to the normalisation of the outcome. It is the analogue for tests of Theorem R3 of the note. The condition concerns all contexts, including those the human system would never reach.

**C4. Outcome tests on recorded human runs** (Pr3 of the candidate theory). Let U be a countable family of outcomes with weights π. Record N independent runs of the human system (at most N·L calls; the human may keep state within a run). With probability at least 1 − δ, the empirical means û(·) satisfy |û − Q_P(u)| ≤ r_N(u) for all u ∈ U, and any answerer whose own run law, found by simulation, matches the empirical means within r_N is within 2·r_N of the human system on every u ∈ U. For finite U: 2L·ln(2|U|/δ)/ε² calls. Nothing is assumed about continuation values. A factor of order L/ε is necessary even for one outcome and adaptively chosen single calls: take the class and the scaffold of Theorem N2 of the note (L independent uniform inputs from {1, …, N}, outcome the OR of the answers, humans f₀ and f_a) with N just below 3L/(8ε) and ε ≤ 1/8; then Q_{f₀}(u) = 0 and Q_{f_a}(u) ≥ (3/4)·L/N > 2ε, so a protocol that is within ε for every member must, as in the proof of Theorem I2(b), ask about (1 − 2δ)·N inputs.

**Comparison** (questions to the human for error ε on one outcome u; constants rounded).

| route | questions | assumed |
|---|---|---|
| outcome tests on N recorded human runs (C4) | 2L·ln(2\|U\|/δ)/ε² | u ∈ U computable; whole human runs |
| per-call tests on the own distribution (C2, rate of the Remark) | about 4.5·L²·(K(V^P)·ln 2 + ln ln n)/ε² single calls | A1, A3; V^{P,u} in the family |
| the same under low stakes, h = c₀/L (C3) | about 4.5·c₀²·(K(b)·ln 2 + ln ln n)/ε² single calls | in addition: no single answer changes the chance of success by more than c₀/L, from any context |
| Bayes mixture with rehearsal (note, R1–R2) | L·K·ln 2/ε for a deterministic human; c₀′·L·K/ε² in general (candidate theory, R2, not yet checked) | A1–A3: P in the class |
| necessary, any protocol | of order L/ε | C4; note, N2 |

So per-call matching on the own distribution is not the cheap route in general: without low stakes it costs a factor L more than recording human runs and assumes more (if V^{P,u} is simple then so is u). Its place is the low-stakes scaffold, where it is free of the horizon, and the certificate C2′, which costs nothing beyond the validation the note already has.

### 3.8 Is the dependence on the description length of the human really absent?

| quantity | does K(P) enter? | where |
|---|---|---|
| questions for (T, ε)-indistinguishability on one input distribution | no: 2·ln(2\|T\|/δ)/ε² | Theorem I1; §2.2, §2.4 |
| the same when tests see the imitator's predictions | no; ε^(−4) and a factor Φ ≤ log\|Y\| | §2.2, §2.5 |
| complexity of some indistinguishable imitator | no; only Φ, the information in an answer relative to the reference | Lemma I1a; §2.1, §2.5 |
| a countable family of input distributions | no; a factor 1/ρ(D), which is 2^k for all shifts of k bits, necessarily | Theorem I2 |
| all shifts of density ratio at most B | **yes**: of the order of the bits of the truth class | Proposition I3 |
| properties that held on all the data | no: K(R)/n | Proposition I4 |
| outcomes of runs, by outcome tests on human runs | no; a factor L, necessarily | C4 |
| outcomes of runs, by per-call tests on the own distribution | through K(V^{P,u}) ≤ K(P) + K(scaffold, u) + O(1) | Theorem C2 |
| every property at once (total variation) | **yes**: K | Proposition I5(b); note R1, R2 |
| whether the tests capture what we care about | **yes**, if "a correct, sane answer" has no test simpler than the human | §4 |

In one sentence: the description length of the human is absent from every statement that asks only for a fixed, restricted family of tests on a fixed, restricted family of input distributions, and it returns as soon as one asks for all tests, for all bounded shifts, or for tests rich enough to mean what we want.

---

## 4. What such a guarantee buys for the researcher's desiderata, and what it does not

This section is **[mine]**. The desiderata are those of the draft and of `notes.md` §1.2 (D1 behaviour that survives shift, D3 a copy, D12 failing obviously, D13 properties keep holding).

### 4.0 Three kinds of property

What a test-based guarantee is worth depends on how the property in question can be checked.

* **(a) Checked by a simple program.** Format; arithmetic; "y contains a formal proof of the statement in x that the proof checker accepts"; "the program in y passes these unit tests".
* **(b) Checked only by a person.** "This solution, written in English, is correct." "This answer is sane."
* **(c) Checked by nobody at hand.** "This is what von Neumann would have said." "He would not regret this on reflection."

### 4.1 Correct solutions

**Kind (a).** If correctness is a test of the family with complexity k, an imitator from Theorem I1 solves problems drawn from D with the human's frequency up to √(2(k·ln 2 + ln(2/δ))/n), and by Proposition I4 a correctness property that held on all the data fails with frequency at most (k·ln 2 + ln(1/δ))/n. This is true and nearly empty. With unbounded compute the same is obtained without the human: draw candidates from any generator and keep the first that passes. Lemma I1a says the simplest indistinguishable imitator is of this kind. The only thing learned from the human is his *rate*, and two-sided indistinguishability would even make the imitator fail on purpose where it could succeed. What is left of value: the tests hold jointly (the imitator fails on the same *simple kinds* of problem as the human, as far as tests of T can tell), and they can be imposed on an imitator obtained otherwise.

**Kind (b).** The test is not a program, so it is not in T. There are three ways to bring the judge in, and they cost different things.

* *The judge as a call of the scaffold.* If the last call of a run is "check this answer", its verdict is an outcome of the run and C1 applies; the judge's questions are then rehearsed like any others, on work the imitator produced. The test "the answer to the last call is 'accept'" has constant complexity. Matching it on the imitator's own distribution says: the imitated judge accepts the imitator's work as often as the real judge would accept that same work. The first frequency is found by compute, so the second becomes known.
* *The judge in validation only.* For one frozen imitator, m judge calls on the outputs of m independent runs give the frequency with which a real judge accepts the imitator's output, to within √(ln(2/δ)/(2m)). This is Theorem V1 of the note with the judge's verdict as the recorded answer. It certifies a rate; it does not say which outputs are wrong.
* *The judge as a training signal.* Each candidate imitator produces different outputs and needs its own judge calls. With unbounded compute and a bounded number of judge calls one cannot search over imitators this way; and a search against a human judge finds what convinces the judge (the researcher's own objection, `notes.md` §2.11).

So for kind (b), tests do not remove the human. They move him from deployment to validation, at one call per checked output.

**Kind (c).** There is no test. The only statement that covers such properties is closeness in total variation: if the run of the imitator is within ε of the run of the human system, every property, formalised or not, has probability within ε of its probability for the human system (the note, §8.1). Its price is K and its assumption is A2.

**Why short tests cannot force correctness in general.** Let D be uniform on N inputs, R a sampler, and f a function drawn with independent values f(x) ∼ R(·|x). For a fixed test t, |(1/N)·Σ_x t(x, f(x)) − R_D(t)| > ε has probability at most 2·exp(−2Nε²). There are fewer than 2^(ℓ+1) tests of description length at most ℓ. So when N ≥ (ℓ + 3)·ln 2/(2ε²), at least half of such f are indistinguishable from the noise source R by all of these tests at once. (The counting argument is that of Trevisan–Tulsiani–Vadhan's Remark 1.6, footnote 5 [read].) If, to tests of at most ℓ bits, the human looks like a typical draw from some simple sampler, then that sampler passes. The human is more than it exactly in the properties that need more than ℓ bits to test. The positive counterpart is Proposition 1 of Kim, Ghorbani and Zou (§2.3): indistinguishability gives correctness on a set of inputs exactly when the test class contains something close to the truth there.

### 4.2 No bizarre behaviour under simple shifts

* **Inside the family that was sampled, yes, at the price of the family.** By Theorem I2, for every input distribution D of weight ρ(D) and every test t, the imitator does what the human does up to √(2·ln(2/(ρ(D)π(t)δ))/(ρ(D)·n)). In the language of the researcher's obstruction: the hypothesis "the human, except that on inputs with property Q it does something else" is excluded when two things hold. Q has frequency of order at least (K(Q) + K(t))/(ε²·n) among the questions asked, and the "something else" is visible to a test t of the family.
* **Outside it, nothing.** A shift to a kind of input that the questions did not contain is not covered by any test-based statement, for the same reason as in Theorem N1 of the note. The price 2^k for all shifts of k bits is necessary (Theorem I2(b)).
* **The shift made by task decomposition is not handled by tests but by where the questions come from.** The inputs that only the imitator's own runs produce have frequency zero in any data collected elsewhere. Rehearsal gives them their true frequency; then C2 and C2′ apply. Test-matching contributes nothing to this beyond what the mixture gets from the same sampling.
* **"Bizarre" has to be a test.** A bizarre behaviour that some simple test B detects, and that the human never showed in n answers, occurs with frequency at most (K(B)·ln 2 + ln(1/δ))/n (Proposition I4). One that no simple test detects (a subtly wrong argument; an output that harms its reader) is not excluded at any n.
* **The reference machine matters less here than for single inputs.** Changing the machine changes K(t) by a constant c and the bound from √(K(t)/n) to √((K(t) + c)/n). The floor 2^(−sep(x; A)) of `ultranatural/note.md` concerns one unasked input; a test-based bound is an average over the sampled distribution and never speaks of one input. The machine still decides which subpopulations and which tests count as simple.

### 4.3 Failing only obviously

"Obviously" has to mean: detected by a check that needs no human, that is, by a test F of kind (a). The event to be made rare is "bad and not flagged by F".

* If badness itself is of kind (a), put the test at deployment and decline when it fails. Every failure is then obvious. No learning theorem is involved.
* If outputs can carry a certificate that a sound verifier checks (formal proofs; the self-proving models of §2.9), silent failure is excluded by the soundness of the verifier, for any generator. This is a property of the task.
* If badness is of kind (b) or (c), a test-based guarantee does not bound "bad and not flagged". What it can give: if the human himself says "I could not do this" at some rate, and that admission is a simple test, the imitator makes it as often as the human on every simple subpopulation of inputs. It need not make it on the *same* inputs: "inputs on which h is wrong are indistinguishable from inputs on which h is right" (Trevisan–Tulsiani–Vadhan, Remark 1.2). A confidence that means what it says on every simple subpopulation is multicalibration (§2.3), and learning it needs labels of correctness, which is kind (a) or a judge.
* Kalai and Vempala's theorem (§2.9) is a warning in the other direction: an imitator held to the calibration of a generator must state, with the human's assurance, "facts" of the arbitrary kind the human states (his memories, his references), at about the rate at which the human's are new. These failures are not obvious.

### 4.4 A copy, or a clever predictor

The test framework is silent on this, by design. Its existence theorems construct an object that is as simple as the tests allow and is *not* the truth: "a simple random model of Nature … suffices to 'fool' efficient observers". A predictor that reasons about the human and about the state of the world differs from the copy on some inputs; it is excluded only if a test of the family sees the difference at a frequency of at least ε on the sampled distribution. The one result in this literature that forces the imitator to *compute what Nature computes* is the lower bound for oracle-access tests (§2.2): tests that use the imitator's own answers on easier instances to check harder ones. It relies on the truth being reducible to itself in that way, and I see no analogue for a person.

### 4.5 In a table

| desideratum | what test-indistinguishability gives | at what price | what it leaves out |
|---|---|---|---|
| correct solutions | the human's rate of passing any program-checkable test | about K(test)/ε² questions; nothing about the human | correctness that only a person can judge; and for checkable correctness a filter does the same |
| properties that held so far keep holding (D13) | each fails at most (K(R)·ln 2 + ln(1/δ))/n of the time on the sampled distribution | its own complexity | properties with no simple test; inputs of frequency below about K(R)/n |
| behaviour under shift (D1) | the same guarantees on every sampled family member | a factor 1/ρ(D); 2^k for all shifts of k bits, necessarily | unsampled kinds of input; all shifts of bounded density ratio (needs the truth class) |
| the inputs made by decomposition (D9) | nothing by itself; with rehearsal, outcome guarantees through continuation-value tests | L·ε, or ε under low stakes; price K(V^P) | outcomes that are not computable from the run; the assumption that V^P is simple cannot be checked |
| failing obviously (D12) | failure rates on checkable tests; the human's own rate of admitting failure on simple subpopulations | as above | silent failures of kinds (b) and (c) |
| a copy (D3) | nothing | | everything |

### 4.6 What I would do with tests in the protocol

1. **Keep a learner that can be a copy** (the mixture, or the simplest consistent hypothesis selected at the end). Total variation is the only notion that covers properties of kind (c), and it is the only place where an assumption on the human is needed.
2. **Impose tests on it; do not derive it from tests.** Use the selection of Proposition I5 (the simplest sampler of the class that meets all test constraints) or the certificate C2′ after the fact. Then the note has two tiers: an unconditional tier (tests; price ln(1/π); no A2), and a conditional tier (everything; price K; A2).
3. **Put program-checkable requirements at deployment as filters**, with an explicit "declined" when no candidate passes. This is the only form of "failing obviously" that needs no theorem.
4. **State the continuation-value assumption where runs are concerned**, and say that it is the test-language form of "P is in the class": weaker when the human's success profile is simple, but equally uncheckable.
5. **Spend human judgement in validation**: the acceptance rate of the deployed system's outputs by a real judge is measurable with m judge calls to within 1/√m, before deployment, in a closed system.
6. **Do not present test-matching as imitation.** By Lemma I1a an imitator that never models the human satisfies every statement of this kind.

---

## 5. Notes for the lead on the draft

1. **Theorem V1(b)** is, in the vocabulary of §2, the *audit* for no-access outcome indistinguishability (multiaccuracy auditing in Kim, Ghorbani and Zou; "estimating the acceptance probability of every distinguisher" in Hu, Peale and Reingold, p. 6), carried out on the imitator's own distribution. The literature's central claim, that the cost does not depend on the truth, is exactly the note's "the complexity of the human does not enter, and nothing is assumed about the human".
2. **Pr3 and Pr4** are minimum-distance selection after Yatracos (1985). The published statement of "the smaller of the two complexities" is Remark 16 of Hu, Peale and Reingold (2022) for binary outcomes; Arora et al. (2017), Theorem 3.1, is the statement that a restricted distance generalises with the capacity of the test class, and their Corollary 3.2 is the warning that it does not see lack of variety.
3. **Theorem Pr5.** The sentence "the argument is the one behind Blackwell's approachability theorem and behind forecasting that passes countably many checking rules" can be made exact as follows. Countably many checking rules, asymptotically: Sandroni, Smorodinsky and Vohra (2003). Any continuous betting strategy, on any sequence, with a deterministic forecast: Vovk, Takemura and Shafer (2005), Theorem 1; for a test that does not look at the forecast their strategy outputs 0 or 1, which is the binary case of the rule of Pr5. The same exponential potential Σ(e^(ηV) + e^(−ηV)) for finitely many groups: Gupta, Jung, Noarov, Pai and Roth (2021), Definition 3.2 and Theorem 3.2; their forecasts are randomised because their tests see the forecast, and the tests of Pr5 do not. The generative form and the name "online outcome indistinguishability": Farina and Perdomo (2026), Definition 1 and Theorem 1; they cite Vovk (2007) for the optimality of the √T rate. I found no published statement of exactly Pr5 (a deterministic rule, countably many weighted tests of pairs); it is a simple case of these.
4. **A detail in the proof of Pr5.** The displayed inequality is correct for g ∈ {−1, 0, 1}, which is all the note needs for sets. For tests with values in [0, 1] (needed for continuation values) the term-by-term step fails for fractional g, and the inequality cosh(η(S + g)) ≤ cosh(η)·cosh(ηS) + g·sinh(η)·sinh(ηS) should be justified by convexity in g. I checked both facts numerically.
5. **Rate of Pr5.** The mixture over learning rates (§3.7, Remark) gives about 2.2·√(n·(ln(2/π(B)) + 2·ln(log₂ n + 2))) in place of √n·(ln(2/π(B)) + 1/2). It needs a referee.
6. **Runs.** The first bullet of §8.4 ("single calls, not runs") can be answered by C1–C3: per-call tests give outcome guarantees when the family contains the human continuation value, with a factor L that low stakes remove; and C2′ gives a certificate for outcomes from the validation phase as it stands.
7. **A caveat that §8.2–8.3 should carry.** By Lemma I1a, a rule that searches for answers meeting the tests satisfies the corollary of §8.3 in full. The sentence "if 'y is a correct solution of x' is a test of the family, the deployed imitator's answers on its own inputs are correct solutions as often as the human's" is true, and with unbounded compute it is also true of a brute-force solver that is throttled to the human's rate. The requirement is two-sided.
8. **Inputs from outside** (the outline's §6). The published form of the density-ratio statement S1 with a *class* of density ratios is universal adaptability (§2.8). Proposition I3 shows that for the full ball of density ratios the statement cannot be had at the price of the tests; S1 as stated in the candidate theory is under A2, which is consistent with this.
9. **Vocabulary.** The literature distinguishes a *test* (passing is good; every true law passes) from a *distinguisher* (only equality of rates matters), and calls a property that must hold always, and not merely indistinguishably often, *truthfulness* (§2.9). The note's "test" is a distinguisher when it is matched two-sidedly (V1(b), Pr5), and a test in the forecasting sense when it is used one-sidedly as in Proposition I4.
10. **Related work to add to the note's §12**, beyond what the outline lists: Dwork et al. 2021 and 2022; Hébert-Johnson et al. 2018; Hu, Peale, Reingold 2022; Trevisan, Tulsiani, Vadhan 2009; Kim et al. 2022; Swamy et al. 2021; Kleinberg and Mullainathan 2024 with Li, Raman, Tewari 2024 (for the property idea); Farina and Perdomo 2026.

**What I could not do.** Read Jetchev–Pietrzak, Chen–Chung–Liao and the PNAS paper in the original (hosts refused). Verify from the source the statements tagged [memory] in §2.10–2.11. Find a lower bound for Theorem I1 with both ln|T| and chosen queries. Check whether Hu, Peale and Reingold's metric-entropy characterisation (Theorem 13) carries over to samplers with long outputs; the upper bound uses only linearity and concentration and I expect it to, while their lower bound counts possible samples and loses a factor log|Y|.

---

## 6. References

Read in this session (text of the PDF from the host named):

* Sanjeev Arora, Rong Ge, Yingyu Liang, Tengyu Ma, Yi Zhang. "Generalization and Equilibrium in Generative Adversarial Nets (GANs)." ICML 2017 (PMLR 70) [venue from memory]. arXiv:1703.00573v5.
* Noga Amit, Shafi Goldwasser, Orr Paradise, Guy N. Rothblum. "Models That Prove Their Own Correctness." arXiv:2405.15722v4 (2025). Abstract only.
* Sílvia Casacuberta, Cynthia Dwork, Salil Vadhan. "Complexity-Theoretic Implications of Multicalibration." STOC 2024 [venue from memory]. arXiv:2312.17223v2. Abstract only: multiaccuracy is equivalent to the regularity notion of Trevisan, Tulsiani and Vadhan; multicalibration gives stronger versions of the hardcore lemma and the dense model theorem.
* Cynthia Dwork, Michael P. Kim, Omer Reingold, Guy N. Rothblum, Gal Yona. "Outcome Indistinguishability." STOC 2021 [venue from memory]. arXiv:2011.13426v1. https://arxiv.org/abs/2011.13426
* Cynthia Dwork, Michael P. Kim, Omer Reingold, Guy N. Rothblum, Gal Yona. "Beyond Bernoulli: Generating Random Outcomes that cannot be Distinguished from Nature." ALT 2022, PMLR vol. 167. https://proceedings.mlr.press/v167/dwork22a/dwork22a.pdf (the PDF's running head prints "vol 132:1–39").
* Cynthia Dwork, Daniel Lee, Huijia Lin, Pranay Tankala. "From Pseudorandomness to Multi-Group Fairness and Back." COLT 2023 (PMLR 195) [venue from memory]. arXiv:2301.08837.
* Gabriele Farina, Juan Carlos Perdomo. "Defensive Generation." arXiv:2602.21390v1 (24 February 2026); a search result lists it in PMLR vol. 336. §1 only.
* Parikshit Gopalan, Lunjia Hu, Michael P. Kim, Omer Reingold, Udi Wieder. "Loss Minimization through the Lens of Outcome Indistinguishability." ITCS 2023. arXiv:2210.08649v2. Abstract and §1 propositions.
* Parikshit Gopalan, Adam Tauman Kalai, Omer Reingold, Vatsal Sharan, Udi Wieder. "Omnipredictors." ITCS 2022 [venue from memory]. arXiv:2109.05389v1.
* Parikshit Gopalan, Michael P. Kim, Mihir Singhal, Shengjia Zhao. "Low-Degree Multicalibration." COLT 2022 [venue from memory]. arXiv:2203.01255v2. Abstract only.
* Varun Gupta, Christopher Jung, Georgy Noarov, Mallesh M. Pai, Aaron Roth. "Online Multivalid Learning: Means, Moments, and Prediction Intervals." arXiv:2101.01739v1; ITCS 2022 (as cited by Farina and Perdomo).
* Úrsula Hébert-Johnson, Michael P. Kim, Omer Reingold, Guy N. Rothblum. "Multicalibration: Calibration for the (Computationally-Identifiable) Masses." ICML 2018 (PMLR 80) [venue from memory]. arXiv:1711.08513. (The arXiv text is titled "Calibration for the (Computationally-Identifiable) Masses".)
* Lunjia Hu, Inbal Livni-Navon, Omer Reingold. "Generative Models of Huge Objects." arXiv:2302.12823v1; CCC 2023 [venue from memory]. §1 only.
* Lunjia Hu, Charlotte Peale, Omer Reingold. "Metric Entropy Duality and the Sample Complexity of Outcome Indistinguishability." ALT 2022. arXiv:2203.04536v1.
* Adam Tauman Kalai, Santosh S. Vempala. "Calibrated Language Models Must Hallucinate." STOC 2024 [venue from memory]. arXiv:2311.14648v3. Abstract, §5.
* Alkis Kalavasis, Anay Mehrotra, Grigoris Velegkas. "On the Limits of Language Generation: Trade-Offs Between Hallucination and Mode Collapse." arXiv:2411.09642v3; STOC 2025 [venue from memory]. Abstract only.
* Michael P. Kim, Amirata Ghorbani, James Zou. "Multiaccuracy: Black-Box Post-Processing for Fairness in Classification." AIES 2019 [venue from memory]. arXiv:1805.12317v2.
* Michael P. Kim, Juan C. Perdomo. "Making Decisions under Outcome Performativity." arXiv:2210.01745v2; ITCS 2023 [venue from memory]. Abstract only.
* Jon Kleinberg, Sendhil Mullainathan. "Language Generation in the Limit." NeurIPS 2024. arXiv:2404.06757v1.
* Jiaxun Li, Vinod Raman, Ambuj Tewari. "Generation through the lens of learning theory." arXiv:2410.13714v5 (December 2024).
* Maciej Skórski. "Simulating Auxiliary Inputs, Revisited." TCC 2016-B [venue from the search result]. arXiv:1503.00484v3.
* Wen Sun, Anirudh Vemula, Byron Boots, J. Andrew Bagnell. "Provably Efficient Imitation Learning from Observation Alone." ICML 2019 (PMLR 97) [venue from memory]. arXiv:1905.10948v2.
* Gokul Swamy, Sanjiban Choudhury, J. Andrew Bagnell, Zhiwei Steven Wu. "Of Moments and Matching: A Game-Theoretic Framework for Closing the Imitation Gap." ICML 2021, PMLR 139. arXiv:2103.03236v2.
* Luca Trevisan, Madhur Tulsiani, Salil Vadhan. "Regularity, Boosting, and Efficiently Simulating Every High-Entropy Distribution." CCC 2009, pp. 126–136. ECCC TR08-103. https://eccc.weizmann.ac.il/report/2008/103/
* Salil Vadhan, Colin Jia Zheng. "A Uniform Min-Max Theorem with Applications in Cryptography." CRYPTO 2013. ECCC TR13-101. Abstract only; the simulation bound is quoted from Skórski.
* Vladimir Vovk, Akimichi Takemura, Glenn Shafer. "Defensive Forecasting." AISTATS 2005. arXiv:cs/0505083v1.
* Hanxuan Ye, Hongzhe Li. "Multicalibration for Modeling Censored Survival Data with Universal Adaptability." arXiv:2405.15948v4. Used only for its restatement of Kim et al. 2022.
* Jiayun Wu, Jiashuo Liu, and others. "Bridging Multicalibration and Out-of-distribution Generalization Beyond Covariate Shift." arXiv:2406.00661v1. Used only for its summary of Kim et al. 2022. [Authors beyond the first two not checked.]

Not read; bibliographic data from search results or from the reference lists of the papers above:

* Yi-Hsiu Chen, Kai-Min Chung, Jyun-Jie Liao. "On the Complexity of Simulating Auxiliary Input." EUROCRYPT 2018. ePrint 2018/171.
* Oded Goldreich, Shafi Goldwasser, Asaf Nussboim. "On the Implementation of Huge Random Objects." SIAM J. Comput. 39(7):2761–2822, 2010 (FOCS 2003).
* Dimitar Jetchev, Krzysztof Pietrzak. "How to Fake Auxiliary Input." TCC 2014, LNCS 8349, pp. 566–590. ePrint 2013/869.
* Michael P. Kim, Christoph Kern, Shafi Goldwasser, Frauke Kreuter, Omer Reingold. "Universal adaptability: Target-independent inference that competes with propensity scoring." PNAS 119(4):e2108097119, 2022. doi:10.1073/pnas.2108097119.
* G. Noarov, R. Ramalingam, A. Roth, S. Xie. "High-dimensional prediction for sequential decision making." ICML 2025 (as listed by Farina and Perdomo).
* Alvaro Sandroni. "The reproducible properties of correct forecasts." Int. J. Game Theory 32(1):151–159, 2003.
* Alvaro Sandroni, Rann Smorodinsky, Rakesh V. Vohra. "Calibration with many checking rules." Math. Oper. Res. 28(1):141–153, 2003.
* Vladimir Vovk. "Non-asymptotic calibration and resolution." Theoretical Computer Science, 2007.
* Yannis G. Yatracos. "Rates of convergence of minimum distance estimators and Kolmogorov's entropy." Ann. Statist. 13(2):768–774, 1985.

From memory, not checked:

* Pieter Abbeel, Andrew Y. Ng. "Apprenticeship Learning via Inverse Reinforcement Learning." ICML 2004.
* Anselm Blumer, Andrzej Ehrenfeucht, David Haussler, Manfred K. Warmuth. "Occam's Razor." Information Processing Letters 24:377–380, 1987.
* A. Philip Dawid. "The Well-Calibrated Bayesian." J. Amer. Statist. Assoc. 77:605–610, 1982.
* Luc Devroye, Gábor Lugosi. *Combinatorial Methods in Density Estimation.* Springer, 2001.
* Dean P. Foster, Rakesh V. Vohra. "Asymptotic Calibration." Biometrika 85(2):379–390, 1998.
* Sham Kakade, John Langford. "Approximately Optimal Approximate Reinforcement Learning." ICML 2002.
* Ehud Lehrer. "Any Inspection is Manipulable." Econometrica 69(5):1333–1347, 2001.
* Stéphane Ross, J. Andrew Bagnell. "Efficient Reductions for Imitation Learning." AISTATS 2010. Stéphane Ross, Geoffrey J. Gordon, J. Andrew Bagnell. "A Reduction of Imitation Learning and Structured Prediction to No-Regret Online Learning." AISTATS 2011. (Bibliographic data as in `ask-for-help.md`; read and quoted in `imitation-theory.md`.)
* Umar Syed, Robert E. Schapire. "A Game-Theoretic Approach to Apprenticeship Learning." NIPS 2007.

