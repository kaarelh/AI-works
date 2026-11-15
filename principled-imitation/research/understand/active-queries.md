# What the power to choose the questions buys: membership queries, active learning and teaching, for a universal class

*A digest for the "principled human imitation" problem, with own derivations. The question: if the learner may put any inputs it likes to the human, how many questions does it take to be right at **every** input of a deployment set, for functions and for samplers, when the hypothesis class is universal? Companion digests: `abstention-shift.md` (KWIK, perfect selective classification, the class H_k), `ask-for-help.md`, `imitation-theory.md`, `repo.md`, `notes.md`.*

## 0. Access, tags, conventions

* **Web access was partial.** Web search worked. Direct download worked only for `arxiv.org`, `export.arxiv.org`, `proceedings.mlr.press` and `openreview.net`. Not reachable from this session (the proxy refused them): ACM, Springer, Elsevier, IEEE, `jmlr.org`, NeurIPS proceedings, university pages (Berkeley, UIC, Penn, MIT, UCSD, CMU), Wikipedia, Semantic Scholar, the Internet Archive. Consequences:
  * **Opened in full text** (PDF text from arXiv): Hanneke and Yang 2015; Bshouty's survey 2017; Golovin and Krause (arXiv v5); Nowak 2009/2011; Naghshvar and Javidi 2013; Khodier and Schaeffer 2025 (only for its restatement of Angluin's theorem).
  * **Abstracts only** (arXiv API): Puchkin and Zhivotovskiy; Chaudhuri, Kakade, Netrapalli and Sanghavi; Houlsby and co-authors; Hu and co-authors; Gao and co-authors; Garcia-Piqueras and Hernández-Orallo; Bhatia.
  * **Not opened at all:** every pre-2000 paper named in my task (Angluin 1987 and 1988, Kearns–Valiant, Angluin–Kharitonov, Goldman–Kearns, Hegedűs, Blumer et al., Freund et al.), Hanneke's 2014 survey, Dasgupta 2004 and 2005, Balcan–Hanneke–Vaughan. For these I give what a source I opened restates, or what a search result showed, or what I remember, and say which.
* **No private details and no project text went into any query;** searches were for papers and results only.
* **Tags.**
  * **[read in source]**: I read it in the cited paper's text in this session. "[read in source: restated in X]" means I read X's restatement, not the original.
  * **[search result]**: read in a web search result (snippet or summary), not in the work itself. Weaker than the above.
  * **[from memory, not checked]**: not verified here.
  * **[my own derivation]**: derived here; a proof is given. Unrefereed.
* **Notation** (that of `ultranatural/note.md` §1 and of the lead's outline).
  * X is the set of binary strings, identified with the natural numbers in the usual order; Y is a countable set of labels containing 0 and 1.
  * K is prefix complexity on a fixed universal machine; K(g), K(Q) are the lengths of shortest programs for a total computable function g and for a total decider of a set Q; K(· | f) is complexity given a shortest program for f. The letter c is a machine constant that may differ between occurrences. Logarithms are to base 2.
  * A set Q *separates* x from A if x ∈ Q and Q ∩ A = ∅; sep(x; A) and sep(x; A | f) are the least K(Q) and K(Q | f) over decidable separating Q.
  * A *patch* of f on Q is a function equal to f outside Q and different from f somewhere on Q; "is the input in Q?" is its *guard*. A patch that takes the constant value y on Q has complexity at most K(f) + K(Q | f) + K(y) + c.
  * **H_b** is the set of total computable functions g with K(g) ≤ b: the *budget class*. It has fewer than 2^(b+1) members.
  * **T_m** := { x ∈ X : K(x) ≤ m }: the inputs that can be *named* with at most m bits. It has fewer than 2^(m+1) elements and contains every string of length at most m − 2 log m − c.
  * A *question* (membership query) puts one input x to the human and returns f(x), or for a sampler a fresh draw from P(·|x). A *learner* asks questions adaptively and then outputs a function, a sampler, or a rule that may abstain.

## 1. The findings in brief

1. **In the query-learning literature, the number of membership queries needed for exact identification is governed by teaching-type quantities, not by log |C|.** For a finite class C: max(ETD(C), log |C|) ≤ OPT(C) ≤ (2·ETD(C)/log ETD(C))·log |C|, where ETD is the extended teaching dimension (Hegedűs; Moshkov; stated in Bshouty's survey, §2.2). It is about log |C| when ETD is bounded. For a class that contains a function together with N of its one-point changes it is at least N (Angluin 1988). Equivalence queries behave differently: the majority-vote (halving) strategy needs at most log |C| counterexamples.
2. **In active learning under a distribution the same quantity appears as the star number** s: the minimax label complexity for error ε is between max{min{s, 1/ε}, d} and min{s, d/ε}·log(1/ε) up to constants (Hanneke and Yang 2015, Theorem 3), and the worst-case disagreement coefficient, the extended teaching dimension growth function and the reciprocal of the splitting index all equal min{s, 1/ε} or min{s, m} (their Theorems 10, 12, 13). Active learning gains exponentially over passive learning exactly when s is finite.
3. **For the universal class the star number is infinite, and for the budget class H_b it is about 2^b.** So for error ε on a known distribution, choosing the questions saves at most the factor b: between 1/(16ε) and (b ln 2 + ln(1/δ))/ε questions (Proposition AQ8, own). And an exactness guarantee costs about 2^b questions (below).
4. **Exact agreement on a deployment set S, own answer.** A learner that is exact for every target of a class must, when the target is f, ask a set of inputs T that is a *certificate*: every member of the class that agrees with f on T agrees with f on S (Lemma AQ1; this is the teaching-dimension lower bound). In the class of all computable functions the only certificate is S itself. In H_b a certificate is, up to K(f) + O(1) bits in the budget, a set that meets every cheap guard that meets S (Proposition AQ3). Its size is between the number of inputs of S that are cheap to name given f and min(|S|, 2^(b+1)); for a deployment set of L inputs that can be told apart cheaply it is L.
5. **A positive theorem for the universal class (Theorem AQ4, own).** Ask the inputs of T_m, the fewer than 2^(m+1) inputs nameable with m bits. Then every computable function that agrees with f on the answers and differs from f anywhere has complexity above m − K(f) − c and differs from f only at inputs that cost more than m bits to name. If m ≥ 2K(f) + c, the simplest consistent function is f itself: **agreement at every input, with all questions asked in advance and independent of the deployment set.** With a prior of weights 2^(−λK), λ > 1, the posterior mass off f after these q questions is at most 2^((2λ−1)K(f)+c)·(2/q)^(λ−1), at all inputs at once. T_m also maximises the least separation complexity of an unasked input, at log q up to O(log log q).
6. **Matching lower bound (Proposition AQ6, own).** Any learner, adaptive and randomised, that is right at all inputs with probability 1 − δ for every target in H_b asks, when the target is f, at least (1 − 2δ)·2^(b − K(f) − 2 log b − c) questions in expectation; this holds also on average over the prior. An adaptive learner needs fewer than 2^(b+1) (Proposition AQ5). So the cost of certified exactness with budget b is 2^(b ± O(log b)) for simple targets. The exponent is the number of inputs that can be named within the budget: every one of them carries a patch.
7. **Three numbers for one target f** (Section 3.6): a teacher who knows f needs at most K(f) examples (the researcher's own proposition); the best uninformed learner *converges* to f after fewer than 2^(K(f)+1) questions, and for some targets of each complexity no learner converges before 2^(K(f) − 2 log K(f) − c)/4; *certifying* the result against the budget class costs 2^(b − K(f)) to 2^b. Being right is exponentially cheaper than knowing it (the distinction of Balcan, Hanneke and Vaughan 2010), and being taught is exponentially cheaper than finding out.
8. **Abstention does not remove the exponent** (Proposition AQ7, own): a rule that is never wrong on H_b and has asked q questions answers at most a fraction q·2^(−(b − K(f) − 2 log b − c)) of uniformly drawn inputs, however the questions were chosen.
9. **With the plain universal prior (λ = 1), exact identity is never established at a computable rate** (Proposition AQ9, own): after any q questions the posterior probability that the target is not f exceeds a constant times Σ_{ℓ ≥ log 2q} 2^(−K(ℓ)), which tends to 0 more slowly than every computable function. With λ > 1 the rate is q^(−(λ−1)) up to factors 2^(O(K(f))) and polylog q, and this is tight. This is one more reason for a steeper prior.
10. **Samplers (Theorem AQ11 and Proposition AQ12, own).** The same theorem holds with fresh answers: O((b + log(1/δ))/ε²) answers at each input of T_m, m = 2b + K(ε) + c, make every surviving sampler of the budget class ε-close to P in total variation at **every** input. The lower bound is the number of nameable inputs times log(1/(4δ))/(58ε²) (or times log(1/(4δ))/(3ε) where the human is deterministic). With frozen answers (one answer per input for ever) nothing of the kind is possible.
11. **For the protocol.** A guarantee that does not depend on the deployment distribution costs 2^(Θ(K)) questions, whatever the learner; this is a theorem about the class, not about a method. What the power to choose questions buys cheaply is the ability to ask on the deployment distribution of a closed system (the lead's rehearsal), which is Angluin's replacement of an equivalence query by sampling. The remaining levers are a counterexample channel (obvious failures act as equivalence queries: at most K(f) + c of them, on any sequence), an informed teacher, and a hypothesis language in which few inputs are cheap to name (Proposition AQ10).

---

## 2. The literature, with exact statements

### 2.1 Query models and exact identification (Angluin)

**Angluin, "Learning regular sets from queries and counterexamples", *Information and Computation* 75(2):87–106, 1987.** A *minimally adequate teacher* answers membership queries (is the string w in the unknown regular set U?) and conjectures (is this automaton correct? if not, a counterexample is returned).

* [read in source: restated in Khodier and Schaeffer 2025, Theorem 3] "There exists an algorithm L\* that learns a regular language L by performing membership and hypothesis queries. If all negative hypothesis queries return counterexamples of length at most m and the regular language L has a minimal DFA of n states, then the total running time is polynomial in m and n."
* [from memory, not checked] L\* makes at most n − 1 incorrect conjectures and O(k·m·n²) membership queries, k the alphabet size; and in the approximate version the i-th conjecture is replaced by r_i = ⌈(1/ε)(ln(1/δ) + (i+1) ln 2)⌉ random examples, which gives a PAC learner with membership queries.
* [from memory, not checked] Neither kind of query suffices alone: with membership queries only, a "password" automaton forces exponentially many queries (Angluin, "A note on the number of queries needed to identify regular languages", *Information and Control* 51:76–87, 1981), and with equivalence queries only there is no polynomial algorithm (Angluin, "Negative results for equivalence queries", *Machine Learning* 5:121–150, 1990).

**Angluin, "Queries and concept learning", *Machine Learning* 2(4):319–342, 1988.** Defines membership, equivalence, subset, superset, disjointness and exhaustiveness queries for exact identification of a hypothesis from a known class.

* [search result: the paper's abstract] "When the input to an equivalence query is not restricted to the hypothesis space, a majority-vote-based strategy can use exponentially fewer queries. Lower bound techniques are developed for restricted equivalence queries."
* [read in source: restated in Bhatia 2018 and in Bshouty's survey, open problem 3.4] The majority-vote (halving) strategy: conjecture the majority vote of the hypotheses still consistent; every counterexample removes at least half of them; so ⌈log₂ |H|⌉ equivalence queries suffice for any finite H. Bhatia attributes it to Barzdin and Freivald (1972) and Angluin (1988).
* [from memory, not checked] The lower-bound lemma: if the class contains distinct sets L_1, …, L_N and there is a set L_∩, not in the class, with L_i ∩ L_j = L_∩ for all i ≠ j, then exact identification with restricted equivalence, membership and subset queries needs at least N − 1 queries in the worst case. For the N singletons of an N-element domain (L_∩ = ∅): N − 1 membership queries.
* [from memory, not checked] The conversion of equivalence queries to sampling: replace the i-th equivalence query by q_i = ⌈(1/ε)(ln(1/δ) + i ln 2)⌉ draws from the example distribution and conjecture the next hypothesis at the first disagreement; if none of the q_i draws disagrees, stop. The probability of stopping with error above ε is at most Σ_i (1 − ε)^(q_i) ≤ Σ_i δ·2^(−i) ≤ δ. [The one-line proof is mine and is elementary.]

### 2.2 The number of membership queries, with unbounded computation

**Bshouty, "Exact Learning from an Honest Teacher That Answers Membership Queries", arXiv:1706.03935, 2017** (a survey; a journal version appeared in *Theoretical Computer Science* in 2018 [from memory]). OPT_AD(C) is the least worst-case number of membership queries of a deterministic adaptive algorithm that exactly identifies every member of a class C of Boolean functions on X. All of the following are [read in source], §1 and §2.1–2.2 of the survey.

* *Lemma 1.* "Any deterministic learning algorithm for C must ask at least log |C| membership queries. That is OPT_AD(C) ≥ log |C|." *Lemma 2.* A Monte Carlo (hence a Las Vegas) randomised algorithm that learns C with probability at least 3/4 must ask at least log |C| − 1.
* *Teaching dimension.* A *teaching set* for h ∈ C is a set of inputs on which no other member of C agrees with h; TD(C) is the largest size, over h ∈ C, of a smallest teaching set. "We have OPT_AD(C) ≥ TD(C). To show this fact, suppose A is an algorithm that adaptively learns C. Run the algorithm with the target h. The set of all the queries asked is a teaching set for h."
* *Extended teaching dimension.* For an arbitrary h : X → {0,1}, a set T_h is a *specifying set for h with respect to C* if at most one member of C agrees with h on T_h; T(C, h) is the least size; ETD(C) = max over all h of T(C, h). Always ETD(C) ≤ |C|.
* *Lemma 3* (attributed to Hegedűs 1995 and Moshkov 1983):

      OPT_AD(C) ≤ (ETD(C)/log ETD(C))·log |C| + ETD(C) ≤ (2·ETD(C)/log ETD(C))·log |C|,   and   OPT_AD(C) ≥ max(ETD(C), log |C|).

  The algorithm: if some input splits the current version space so that both sides have at least a fraction ε of it, ask it; otherwise ask a specifying set for the majority function of the version space; either its answers identify the target or one of them contradicts the majority and removes all but a fraction ε. "Lemma 3 is just a reduction from the Halving algorithm." Moshkov's examples show that the upper bound cannot be improved in general: OPT_AD(C_{t,ℓ}) = Ω((ETD/log ETD)·log |C_{t,ℓ}|).
* *Greedy.* OPT_AD(C) = min_x max(OPT_AD(C_{x,0}), OPT_AD(C_{x,1})). Finding OPT_AD is NP-complete (Hyafil and Rivest) and cannot be approximated within (1 − o(1))·ln |C| in polynomial time unless P = NP (Laber and Nogueira, with Dinur and Steurer). Asking the input that splits the version space most evenly learns C "with at most (ln |C|)·OPT_AD(C)" queries (*Lemma 4*, after Arkin et al.).

So the answer to "when is it log N?": **OPT_AD(C) = Θ(log |C|) whenever ETD(C) is bounded by a constant, OPT_AD(C) ≥ ETD(C) always, and between the two OPT can be as large as ETD·log |C|/log ETD.** [my reading of Lemma 3]

**Hegedűs, "Generalized teaching dimensions and the query complexity of learning", COLT 1995, pp. 108–117; Hellerstein, Pillaipakkamnatt, Raghavan and Wilkins, "How many queries are needed to learn?", *Journal of the ACM* 43(5):840–862, 1996.** Not opened. [read in source: Hanneke and Yang 2015, §7.3] they are the sources of "analogous notions used to tightly-characterize the query complexity of Exact learning with membership queries". [from memory, not checked] Hellerstein et al. characterise polynomial query complexity with membership and equivalence queries by "polynomial certificates".

**The average case with a prior: generalised binary search.**

* [read in source: Golovin and Krause, arXiv:1003.3967v5, §9] Generalised binary search (GBS) asks the input that splits the prior mass of the version space most evenly. It "provides an O(log |H|)-approximation for the worst-case number of queries (Arkin et al., 1993)", and in the Bayesian setting "an O(log(1/min_h p_H(h)))-approximation for the expected number of queries (Kosaraju et al., 1999; Dasgupta, 2004)". Their Theorem 21: with a prior p_H on a finite H, GBS "makes OPT·(ln(1/min_h p_H(h)) + 1)² queries in expectation to identify a hypothesis drawn from p_H, where OPT is the minimum expected number of queries made by any policy". (In my text extraction the exponent 2 sits on a separate line; I read it as a square, which agrees with my memory that the authors corrected an earlier bound without the square.)
* [read in source: Nowak, arXiv:0910.4397v5, Definition 3, Lemma 1, Theorem 1] With the coherence parameter c\*(X, H) := min_P max_{h ∈ H} |Σ_A h(A)·P(A)| (labels ±1, A ranging over the cells of inputs on which all hypotheses are constant) and the *k-neighborly* condition (the graph on cells, with an edge when at most k hypotheses distinguish two cells, is connected): "If (X, H) is k-neighborly, then GBS terminates with the correct hypothesis after at most ⌈log N / log(λ⁻¹)⌉ queries, where λ = max{(1 + c\*)/2, (k+1)/(k+2)}." So O(log N) queries when c\* is bounded away from 1. For N intervals on a line with the uniform query measure, c\* = 1 − 2N⁻¹ and the theorem gives only a trivial guarantee [read in source: §V of the paper]: that is the star set again.
* [my own derivation, standard] Lower bound by entropy: with binary answers, any zero-error learner asks at least H(w) questions in expectation over the prior w. With *arbitrary* yes–no questions about the target, Huffman coding achieves fewer than H(w) + 1. Membership queries are a very restricted kind of yes–no question, and Section 3 shows that for a universal class the restriction costs an exponential.

### 2.3 Hardness: what computation, not information, limits

These concern polynomial-time learners. With arbitrary compute they do not bind; I list them because my task names them and because they explain why the positive results of §2.1 stop at automata.

* **Kearns and Valiant, "Cryptographic limitations on learning Boolean formulae and finite automata", *Journal of the ACM* 41(1):67–95, 1994.** [search result] A polynomial-time learner (in the distribution-free model, from random examples, with any hypothesis representation) for Boolean formulae, deterministic finite automata or constant-depth threshold circuits would give polynomial-time algorithms for inverting RSA, recognising quadratic residues and factoring Blum integers.
* **Angluin and Kharitonov, "When won't membership queries help?", *Journal of Computer and System Sciences* 50(2):336–355, 1995 (STOC 1991).** [search result: abstract as shown] "We investigate cryptographic limitations on the power of membership queries to help with concept learning"; under the same three assumptions "there is no polynomial-time prediction algorithm with membership queries for Boolean formulas"; and membership queries "will not help with predicting CNF or DNF formulas". [from memory, not checked] The exact form of the last statement: if one-way functions exist, CNF and DNF are either predictable without membership queries or not predictable with them; the negative results also cover constant-depth threshold circuits, finite unions or intersections of DFAs, two-way DFAs, NFAs and context-free grammars, and use signatures so that the learner cannot ask useful queries off the distribution.
* **Bshouty, Cleve, Gavaldà, Kannan and Tamon, "Oracles and queries that are sufficient for exact learning", *Journal of Computer and System Sciences* 52(3):421–433, 1996.** [search result] Boolean circuits are exactly learnable in randomised expected polynomial time with equivalence queries and an NP oracle, and deterministically with equivalence queries and a Σ₃ oracle; a consequence is that NP ⊆ P/poly collapses the polynomial hierarchy to ZPP^NP. The message for us: with enough computation, *equivalence* queries make every circuit class learnable with polynomially many queries; nothing of the kind holds for membership queries alone, for the information-theoretic reason of §2.2.

### 2.4 Teaching

* **Goldman and Kearns, "On the complexity of teaching", *Journal of Computer and System Sciences* 50(1):20–31, 1995.** [read in source: restated in Bshouty's survey] The teaching dimension TD(C) as in §2.2, and the lower bound OPT_AD(C) ≥ TD(C). [search result] TD and the VC dimension "can be arbitrarily far apart in either direction". [from memory, not checked] For the N singletons together with the empty set, TD = N while the VC dimension is 1.
* **Recursive teaching.** [read in source: abstract of Hu, Wu, Li and Wang, "Quadratic Upper Bound for Recursive Teaching Dimension of Finite VC Classes", arXiv:1702.05677, 2017] The recursive teaching dimension RTD "introduced by Zilles et al. (2011)" is "characterized by the worst-case number of examples necessary to identify a concept in C according to the recursive teaching model"; "Simon & Zilles (2015) posed an open problem RTD(C) = O(d)"; "the best known result is an exponential upper bound RTD(C) = O(d·2^d), due to Chen et al. (2016)"; the paper shows RTD(C) = O(d²). (Zilles, Lange, Holte and Zinkevich, "Models of cooperative teaching and learning", *JMLR* 12:349–384, 2011 [from memory].)
* **Preference-based teaching.** [read in source: abstract of Gao, Ries, Simon and Zilles, "Preference-based Teaching", arXiv:1702.02047, 2017] The learner has a preference order on the class and returns a most preferred concept consistent with the examples; the preference-based teaching dimension PBTD "coincides with the well-known recursive teaching dimension (RTD) on finite classes" and is "radically different on infinite ones".
* **Teaching in a universal language.** [search result] Telle, Hernández-Orallo and Ferri, "The teaching size: computable teachers and learners for universal languages", *Machine Learning* 108(8–9):1653–1675, 2019: measure a witness set by its total size, not its cardinality; with a simplicity-ordered learner and a time bound, teacher and learner are computable and every total function computable within the bound can be taught. [read in source: abstract of Garcia-Piqueras and Hernández-Orallo, "Conditional Teaching Size", arXiv:2107.07038, 2021] "there exist data teaching sets surprisingly shorter than the concept description itself".
* **The researcher's proposition is a statement of this kind.** [read in source: `notes.md` §4, Q7, quoting his note] "you can always learn f by showing the function value on K(f) inputs (like, if you choose well)": while f(x) is not the top guess at some x, show (x, f(x)); each such example at least doubles the posterior weight of f. In the vocabulary above this bounds a preference-based teaching number for the Bayes learner by log(1/w(f)); it is the teacher's version of the mistake bound K(f) + c (`repo.md` C1). [my reading]

### 2.5 Active learning in the PAC model

Setting: inputs i.i.d. from a distribution P, a class C of VC dimension d, target in C (the realizable case); the learner sees unlabelled inputs and asks for labels; Λ_RE(ε, δ) is the minimax number of labels, over all P and targets, to reach error ε with probability 1 − δ.

* **Disagreement-based learning.** [read in source: Hanneke and Yang 2015, §7.1] The method of Cohn, Atlas and Ladner (1994) asks for the label of a point exactly when the hypotheses consistent with the labels so far disagree on it. *Definition 9*: "For any r₀ ≥ 0, any classifier h, and any probability measure P over X, the disagreement coefficient of h with respect to C under P is defined as θ_{h,P}(r₀) = sup_{r > r₀} P(DIS(B_P(h, r)))/r ∨ 1", where B_P(h, r) is the set of members of C at distance at most r from h and DIS(V) the set of inputs on which members of V disagree. The known general bound: Λ_RE(ε, δ) ≲ θ̂(ε)·d·polylog(1/(εδ)), with θ̂(ε) the supremum of the disagreement coefficient over distributions and targets. (Hanneke, "A bound on the label complexity of agnostic active learning", ICML 2007; survey: Hanneke, "Theory of Disagreement-Based Active Learning", *Foundations and Trends in Machine Learning* 7(2–3):131–309, 2014; neither opened.)
* **Splitting index.** [read in source: Hanneke and Yang 2015, §7.2, restating Dasgupta, "Coarse sample complexity bounds for active learning", NIPS 2005] With splitting index ρ (at scale ε/4 and unlabelled-data parameter τ), Dasgupta's algorithm reaches error ε with probability 1 − δ using (d/ρ)·polylog(d/(εδτρ)) label requests and Õ(d/(τρ)) unlabelled samples; there is a lower bound of order 1/ρ; and (their Theorem 12) ⌊1/ρ̂(ε)⌋ = s ∧ ⌊1/ε⌋ for the distribution-free worst case ρ̂.
* **Star number.** [read in source: Hanneke and Yang 2015, Definition 2] "Define the star number s as the largest integer s such that there exist x₁, …, x_s ∈ X and h₀, h₁, …, h_s ∈ C with the property that ∀i ∈ {1, …, s}, DIS({h₀, h_i}) ∩ {x₁, …, x_s} = {x_i}; if no such largest integer exists, define s = ∞." So s is the largest number of inputs at each of which some member of the class differs from one centre h₀ while agreeing with it on the others. Always s ≥ d; s = 2 for thresholds on the line; s = ∞ for intervals and for linear separators in the plane.
* **The minimax label complexity.** [read in source: Hanneke and Yang 2015, Theorem 3] "For any ε ∈ (0, 1/9), δ ∈ (0, 1/3),

      max{ min{s, 1/ε}, d, Log(min{1/ε, |C|}) } ≲ Λ_RE(ε, δ) ≲ min{ s, d/ε, s·d/Log(s) }·Log(1/ε)."

  For comparison, passive learning needs M_RE(ε, δ) ≳ (1/ε)(d + Log(1/δ)) labelled examples. Their reading: "when s < ∞, Λ_RE(ε, ·) = O(Log(M_RE(ε, ·))), and when s = ∞, Λ_RE(ε, ·) = Θ(M_RE(ε, ·))."
* **All the earlier complexity measures are the star number in the worst case.** [read in source: Hanneke and Yang 2015] Theorem 10: "∀ε ∈ (0, 1], θ̂(ε) = s ∧ 1/ε". Theorem 13: "∀m ∈ N, XTD(C, m) = TD(C, m) = min{s, m}", where XTD(C, m) is the extended teaching dimension growth function (the largest, over m-point samples U and arbitrary classifiers h, of the least size of a subset of U that specifies h within C on U); and "the star number is not really a new quantity to the active learning literature, but rather a simplified definition for the already-familiar extended teaching dimension growth function" (their footnote 11). So §2.2 and §2.5 measure the same thing.
* **Being right against knowing it.** [search result] Balcan, Hanneke and Vaughan, "The true sample complexity of active learning", *Machine Learning* 80:111–139, 2010 (COLT 2008): the "verifiable sample complexity" counts "the number of label requests needed to obtain a confidence bound indicating an algorithm has achieved at most ε error", the plain sample complexity "the number of label requests before an algorithm actually reaches that accuracy"; there is "a sharp distinction between the sample complexity required to find a good classifier (logarithmic) and the sample complexity needed to both find a good classifier and verify that it is good"; and "any distribution and finite VC dimension concept class has active learning sample complexity asymptotically smaller than the sample complexity of passive learning for nontrivial targets". The 1/ε lower bounds for classes with infinite star number are bounds on the verifiable quantity. Section 3.6 has the analogue for a universal class.
* **Abstention.** [read in source: abstract of Puchkin and Zhivotovskiy, "Exponential Savings in Agnostic Active Learning through Abstention", arXiv:2102.00451, 2021] "if the learner is given the power to abstain from some predictions by paying the price marginally smaller than the average loss 1/2 of a random guess, exponential savings in the number of label requests are possible whenever they are possible in the corresponding realizable problem." So abstention removes the obstruction that *noise* puts in the way of active learning; it does not remove the one that the star number puts there. Proposition AQ7 says the same for the universal class.

### 2.6 Membership queries and the sample complexity of PAC learning

* [search result] **Eisenberg and Rivest, "On the sample complexity of PAC-learning using random and chosen examples", COLT 1990, pp. 154–162**: "Using membership queries can not significantly reduce the total number of random examples needed to pac-learn a dense-in-itself concept class C: Ω((1/ε) ln(1/δ)) random examples are still required."
* **Turán, "Lower bounds for PAC learning with queries", COLT 1993, pp. 384–391.** Exists [search result]; I could not see its statements. [from memory, not checked, low confidence] It bounds the number of examples plus queries from below in terms of the VC dimension for membership queries.
* [search result] **Kulkarni, Mitter and Tsitsiklis, "Active learning using arbitrary binary valued queries", *Machine Learning* 11:23–35, 1993**: the learner may ask any yes–no question about the target. For a fixed distribution, "active learning does not enlarge the set of learnable concept classes, but can improve the sample complexity"; a class is actively learnable with respect to a distribution if and only if it has finite metric entropy, and the number of queries is governed by the metric entropy; in the distribution-free case "a concept class is actively learnable iff it is finite". [from memory, not checked] The count is the logarithm of the ε-covering number.

Read together with §2.5: with arbitrary yes–no questions the cost of learning to error ε is the *logarithm of a covering number* (for H_b: at most b + 1); with membership queries it is min{s, 1/ε} up to the factor d (for H_b: about min{2^b, 1/ε}). The gap between "any question about f" and "the value of f at a point" is the star number. [my reading]

### 2.7 Bayesian choice of questions

* **Freund, Seung, Shamir and Tishby, "Selective sampling using the query by committee algorithm", *Machine Learning* 28:133–168, 1997.** Draw two hypotheses from the posterior; ask for the label of an incoming point when they disagree. [search result: abstract as shown] "if the two-member committee algorithm achieves information gain with positive lower bound, then the prediction error decreases exponentially with the number of queries"; this is shown to hold for perceptrons. [from memory, not checked] The quantitative form: if the expected information gain per query is at least g > 0 bits and the class has VC dimension d, then error ε is reached with probability 1 − δ after m₀ = poly(d, 1/ε, 1/δ, 1/g) unlabelled points and O(((d + 1)/g)·log(m₀/δ)) queries. The theorem assumes the target is drawn from the prior, and the lower bound g is the whole content: for a class with a large star set the expected information gain of the best question falls like the posterior mass of the patches, and the theorem gives nothing (Section 3.8).
* **Bayesian active learning by disagreement.** [read in source: abstract of Houlsby, Huszár, Ghahramani and Lengyel, "Bayesian Active Learning for Classification and Preference Learning", arXiv:1112.5745, 2011] "an approach that expresses information gain in terms of predictive entropies". [from memory, not checked] The rule asks the x that maximises H[y | x, D] − E_{θ ∼ posterior} H[y | x, θ], the mutual information between the answer and the hypothesis. It is the greedy step for the entropy of the posterior; GBS (§2.2) is the same rule for deterministic hypotheses, and the approximation guarantees are those of §2.2. No guarantee at inputs that were not asked follows from it.

### 2.8 Noisy answers and samplers

* **Sequential design of experiments.** [read in source: Naghshvar and Javidi, "Active sequential hypothesis testing", *Annals of Statistics* 41(6):2703–2738, 2013, arXiv:1203.4626] M hypotheses; each action a gives an observation with density q_i^a under hypothesis i; a wrong declaration costs L, each observation costs 1. Their Proposition 1 (after Chernoff, "Sequential design of experiments", *Annals of Mathematical Statistics* 30:755–770, 1959): the optimal expected cost from belief ρ is at least, up to lower-order terms,

      Σ_i ρ_i · (1 − δ)·log(L/(K′ log 2L)) / ( max_{λ ∈ P(A)} min_{j ≠ i} Σ_a λ_a·D(q_i^a ‖ q_j^a) + δ ),

  and a two-phase policy is asymptotically optimal as L → ∞. In words: the number of observations needed to identify hypothesis i with error probability about 1/L is log L divided by D\*(i) := max_λ min_{j ≠ i} Σ_a λ_a·D(q_i^a ‖ q_j^a), the best worst-case rate at which a mixture of questions tells i from its nearest alternative. For samplers this is the right notion of "certificate": Section 4 computes it for the universal class, where the nearest alternatives are one-point patches and D\* is at most (ε-scale divergence)/(number of nameable inputs).
* **Noisy binary search.** [read in source: Nowak, arXiv:0910.4397v5, abstract and §III] "a noise-tolerant version of GBS is developed that also achieves the optimal query complexity" O(log N) under the same neighborly and coherence conditions, with answers flipped independently with probability below 1/2.
* **Log loss and conditional distributions.** [read in source: abstract of Chaudhuri, Kakade, Netrapalli and Sanghavi, "Convergence Rates of Active Learning for Maximum Likelihood Estimation", arXiv:1506.02348, 2015] For maximum likelihood in well-specified parametric models (generalised linear models and others) "we provide a two-stage active learning algorithm"; "an upper bound on the label requirement of our algorithm, and a lower bound that matches it up to lower order terms"; "unlike binary classification in the realizable case, just a single extra round of interaction is sufficient to achieve near-optimal performance in maximum likelihood estimation". So for smooth parametric families the gain from choosing questions is a re-weighting of the input distribution (a constant factor), not a change of rate. I found no result on active learning of conditional distributions under log loss for a countable or universal class beyond the regret bound for Bayes mixtures on adaptively chosen inputs (the lead's L3; `repo.md` A6, A7), which holds for any way of choosing the questions and therefore says that the *order* is worthless for cumulative log loss (`repo.md` C3(1)).

### 2.9 Occam's razor, for comparison

* **Blumer, Ehrenfeucht, Haussler and Warmuth, "Occam's razor", *Information Processing Letters* 24(6):377–380, 1987.** [from memory, not checked] Cardinality form: with m ≥ (1/ε)·ln(|H|/δ) random examples, with probability 1 − δ every member of H consistent with them has error at most ε; and an algorithm that outputs consistent hypotheses of description length at most n^α·m^β, β < 1, is a PAC learner. [read in source: `repo.md` B4, citing Paper 1, Proposition 5.11] The form used in this repository: with probability at least 1 − δ, every program p consistent with n i.i.d. examples has error at most (|p|·ln 2 + ln(1/δ))/n.
* The comparison that matters below: Occam's razor gives error ε on the sampling distribution with about (K ln 2 + ln(1/δ))/ε random questions. It is a bound in which the questions are *not* chosen. Theorem 3 of Hanneke and Yang says that for a class with star number above 1/ε choosing them cannot do better than 1/ε.

---

## 3. Own derivations: deterministic targets

Everything in this section is **[my own derivation]** unless tagged otherwise; proofs are given; nothing has been refereed. Where a statement is a known result in different words I say so.

### 3.1 Certificates: the general answer

**Definition.** Let H be a class of functions X → Y, S ⊆ X a *deployment set*, f ∈ H. A set T ⊆ X is an **S-certificate for f in H** if every g ∈ H that agrees with f on T agrees with f on S. cert_S(f; H) is the least size of an S-certificate (∞ if none is finite). For S = X this is a teaching set and max_f cert_X(f; H) = TD(H).

**Lemma AQ1 (a learner that is exact must ask a certificate).**

(a) If a deterministic learner outputs g|_S for every target g ∈ H, then for every f ∈ H the set of inputs it asks when the target is f is an S-certificate for f in H. So it asks at least cert_S(f; H) questions on f.

(b) If a randomised learner outputs g|_S with probability at least 1 − δ for every target g ∈ H, then for every f ∈ H and every g ∈ H with g|_S ≠ f|_S: when the target is f, the learner asks some input of {g ≠ f} with probability at least 1 − 2δ.

*Proof.* (a) If g ∈ H agrees with f on the asked set, the learner sees the same answers under f and under g, asks the same inputs and gives the same output; the output equals f|_S and g|_S. (b) Fix the learner's coins. Let E be the event that under target f no asked input lies in {g ≠ f}. On E the run under g is the same run and the output is the same; it cannot equal both f|_S and g|_S. So Pr_f[wrong] + Pr_g[wrong] ≥ Pr[E], hence Pr[E] ≤ 2δ. ∎

Part (a) is the argument of Goldman and Kearns quoted in §2.2. Two remarks.

* The bound is per target, but only for learners with a guarantee on the whole class. A learner built to favour one f can test a smallest certificate for f first.
* For a prior w on H the expected number of questions of any exact learner is at least E_{f∼w} cert_S(f; H), and for binary labels at least the entropy of the law of f|_S.

**Proposition AQ2 (an upper bound with a prior).** Let H be countable with weights w(g) > 0 of total at most 1. For an arbitrary h : X → Y call T an *S-specifying set for h* if all members of H that agree with h on T agree with one another on S, and let XTD_S(H) be the supremum over h of the least size of one. There is a learner that, for every f ∈ H, outputs f|_S after at most

    XTD_S(H) · (⌊log₂(1/w(f))⌋ + 1)

questions.

*Proof.* Keep the version space V (the members consistent so far). In each round let h(x) be a label of largest w-weight among the values g(x), g ∈ V, take a smallest S-specifying set T for h within V, and ask its inputs one at a time. If an answer differs from h(x), the surviving weight is at most half of w(V) (the weight of the answered label is at most that of h(x), and the two are disjoint parts of w(V)); start a new round. If all answers agree with h, the survivors agree on S and contain f; output their common restriction. Since w(V) ≥ w(f) throughout and w(V) ≤ 1 at the start, at most ⌊log₂(1/w(f))⌋ rounds end with a halving. ∎

This is Lemma 3 of §2.2 (Hegedűs, Moshkov) with weights in place of counting and a deployment set in place of full identification. Together: for every exact learner and every f, cert_S(f; H) ≤ (questions on f), and some learner has (questions on f) ≤ XTD_S(H)·(log(1/w(f)) + 1). **The minimal number of questions for exactness on S is a teaching quantity times at most the description length of the target.** When XTD_S(H) is bounded, about log(1/w(f)) questions suffice; when the class contains f and many of its one-point changes on S, cert_S(f; H) is at least their number.

### 3.2 In a universal class, certificates are transversals of guards

**Proposition AQ3.**

(a) *No budget.* In the class of all total computable functions, T is an S-certificate for f if and only if T ⊇ S. So a learner that is exact on S for every computable target asks every input of S; for infinite S there is none. (This is the lead's N1 and §7.1 of `abstention-shift.md`.)

(b) *Budget b.* For f ∈ H_b let 𝒬_j(S | f) be the family of decidable sets Q with Q ∩ S ≠ ∅ and K(Q | f) ≤ j. There is a constant c such that:
  * if T is an S-certificate for f in H_b, then T meets every member of 𝒬_{b − K(f) − c}(S | f);
  * if T meets every member of 𝒬_{b + c}(S | f), then T is an S-certificate for f in H_b.

  So with τ(·) the least size of a set meeting every member of a family (its transversal number),

      τ(𝒬_{b − K(f) − c}(S | f)) ≤ cert_S(f; H_b) ≤ τ(𝒬_{b + c}(S | f)).

(c) *Size.* For every j: τ(𝒬_j(S | f)) ≤ min(|S|, 2^(j+1) − 1); τ(𝒬_j(S | f)) is at least the largest number of pairwise disjoint members of the family, hence at least #{x ∈ S : K(x | f) ≤ j − c}; and T_m meets every member of 𝒬_j(S | f), for every S, as soon as m ≥ j + K(f) + c.

*Proof.* (a) If x ∈ S ∖ T, the function equal to f except at x is computable, agrees with f on T and not on S. (b) First claim: let Q be decidable with Q ∩ T = ∅ and x ∈ Q ∩ S. Let y be 0 if f(x) ≠ 0 and 1 otherwise, and let g be y on Q and f elsewhere. Then g agrees with f on T, g(x) ≠ f(x), and K(g) ≤ K(f) + K(Q | f) + c. If K(Q | f) ≤ b − K(f) − c then g ∈ H_b, and T is not a certificate. Second claim: if g ∈ H_b and g|_S ≠ f|_S, the set Q = {g ≠ f} is decidable from programs for g and f, so K(Q | f) ≤ K(g) + c ≤ b + c, and Q meets S; so T meets Q and g disagrees with f on T. (c) S meets every member; one point from each of the fewer than 2^(j+1) members also does. A transversal needs a separate point in each of a family of disjoint members, and the singleton {x} has K({x} | f) ≤ K(x | f) + c. Last: a nonempty decidable Q has a least element z with K(z) ≤ K(Q) + c ≤ K(Q | f) + K(f) + c, so z ∈ T_m when m ≥ j + K(f) + c. ∎

**Examples.**

* *S = X.* Numbers below 2^i have complexity at most i + 2 log i + c. So 2^(b − K(f) − 2 log b − c) ≤ cert_X(f; H_b) ≤ 2^(b+c+1). **For a simple target the certificate has 2^(b − O(log b)) elements: all inputs that the budget can name.**
* *L deployment inputs that can be told apart by their first ℓ₀ bits* (L random strings with ℓ₀ = 2 log L, with high probability). The sets "strings that begin with the first ℓ₀ bits of s_i" are pairwise disjoint, each meets S in one point, and each has complexity at most ℓ₀ + 2 log ℓ₀ + c. So cert_S(f; H_b) = L as soon as b ≥ K(f) + ℓ₀ + 2 log ℓ₀ + c: **no deployment input can be skipped, and asking inputs outside S does not help.** This is the lead's Theorem N2 seen from the side of the questions: its class (the zero function and the indicators of N cells) is a star set, and here the star set is supplied by the budget.
* *The crossover.* cert_S(f; H_b) grows like |S| until |S| reaches the number of inputs the budget can name, and then stops near 2^b. Asking questions pays, in the sense of answering more inputs than were asked, only for deployment sets larger than about 2^b.

This is the structure of the ultranatural notes in the language of query learning: **the guards of `note.md` §1 are the centre-and-spokes of a star set, the floor 2^(−sep(x; A)) is the prior mass of the spoke that the questions A have not cut, and an exact learner has to cut every spoke within its budget.** (`abstention-shift.md` §7.2 has the count of the star number of H_k and §7.5 the same identification for the disagreement region.)

### 3.3 The canonical question set: ask what is cheap to name

**Theorem AQ4.** Let f be total computable, m ≥ 1, and let D_m be the answers of f on T_m = {x : K(x) ≤ m} (fewer than 2^(m+1) questions, fixed in advance and independent of f and of any deployment set). There is a constant c₀ such that:

1. **(What survives.)** Every total computable g ≠ f that agrees with f on T_m has K(g) > m − K(f) − c₀, and differs from f only at inputs x with K(x) > m.
2. **(Exactness.)** If m ≥ 2K(f) + c₀, then f is the unique function of least complexity consistent with D_m. The Kolmogorov version of SOI, given D_m, answers f(x) at every input x.
3. **(A universal certificate.)** If m ≥ 2b + c₀, then T_m is an X-certificate in H_b for every member of H_b at once: the answers on T_m determine the target among the functions of complexity at most b.
4. **(Steeper mixtures.)** For λ > 1 and the prior with weights 2^(−λK(g)) on total computable functions, the posterior mass off f given D_m is at most

       2^((2λ−1)·K(f) + (λ−1)·(c₀ − m)) ≤ 2^((2λ−1)·K(f) + (λ−1)·c₀) · (2/q)^(λ−1),   q := |T_m|.

   On the complement the predictive distribution is right at all inputs simultaneously.
5. **(The plain mixture keeps a floor, and it is the same at every unasked input.)** For every x ∉ T_m,

       m − c₀ < sep(x; T_m) ≤ m + 2 log m + c.

   So after these questions every unasked input, simple or not, is separated from the asked ones by a test of about m bits and by none of fewer; W_tot gives a wrong label in {0,1} at x posterior probability at least 2^(−K(f) − m − 2 log m − c), and the papers' W and M_F at least 2^(−m − 2 log m − c) (`note.md` §1 and Remark 1.1).
6. **(Optimality of the design.)** For every set T of q inputs, min_{x ∉ T} sep(x; T) ≤ log(q+1) + 2 log log(q+2) + c. For T = T_m it is more than m − c₀ > log q − 1 − c₀. So "the simplest inputs first" maximises the least novelty of an unasked input, up to O(log log q).

*Proof.* (1) Q = {g ≠ f} is decidable and nonempty; its least element z satisfies K(z) ≤ K(g) + K(f) + c₀ (search for the first disagreement). Since g agrees with f on T_m, z ∉ T_m, so K(z) > m. (2) and (3) follow from (1). (4) Σ over g ⊇ D_m, g ≠ f, of 2^(−λK(g)) ≤ 2^(−(λ−1)(m − K(f) − c₀))·Σ_g 2^(−K(g)) ≤ 2^(−(λ−1)(m − K(f) − c₀)), and the total posterior weight is at least 2^(−λK(f)); 2^(−m) < 2/q. (5) Lower bound: a separating Q has its least element outside T_m. Upper bound: X ∖ T_m is decidable, and T_m is computed from m and the number of programs of length at most m that halt, so K(X ∖ T_m) ≤ m + 2 log m + c. The floors are those of `note.md` §1. (6) Among the first q + 1 strings one is not in T, and its singleton has complexity at most log(q+1) + 2 log log(q+2) + c. ∎

**What the theorem says.** Exact identification over a universal class is impossible with finitely many questions (Proposition AQ3(a)). Identification *up to patches on inputs that are expensive to name* is possible and has a clean form: after the 2^(m+1) cheapest questions, every surviving alternative both costs more than m − K(f) bits and lives entirely on inputs that cost more than m bits to name. Occam's razor (item 2) or a steeper prior (item 4) then discards the alternatives; a budget (item 3) forbids them.

**Remarks.**

* *"The first q inputs" is not the same design.* If A is the set of the first q strings in length-lexicographic order, the set of strings beyond the next power of two is a separator of complexity about log log q, and every long input has a wrong-label floor of about 1/log q. T_m contains the round numbers of every magnitude; that is what item 6 measures. Drawing questions from the universal distribution m(x) ≈ 2^(−K(x)) is the randomised form of T_m (`notes.md` §6.2, Observation D).
* *Front-loading against asking on novelty.* `notes.md` §6.2, Observation B, asks the human whenever sep(x; A) < s during deployment, at most 2^s − 1 times, and is never wrong once s > 2K(f) + c′. Theorem AQ4 asks the same order of questions, all before deployment; afterwards no deployment input can have novelty below m − c₀, and the human is out of the loop.
* *The "was not asked" guard.* For a learner whose strategy σ is a computable deterministic function of the answers, the set A of the q inputs it asks when the target is f is decidable from σ, q and a program for f. So every unasked input has sep(x; A | f) ≤ K(σ) + K(q) + c, and the function "f on A, something else elsewhere" keeps posterior odds at least 2^(−K(σ) − K(q) − c) against f. A simple deterministic strategy cannot make its unasked inputs look more novel than about log q bits, given f, at *any* unasked input. Fresh randomness in the choice of questions (the lead's assumption A3) removes this particular guard; by item 6 and Proposition AQ8 it does not improve the rate.
* *Computability.* T_m is computable with a halting oracle and not without. A computable version exists for programs with a time bound t on a finite domain {0,1}^(≤n): replace K by complexity with time bound about 2^n·t(n), which is what the search for a first disagreement costs. I have not written this out.
* *The reference machine.* On a machine at distance a from the reference one, the new T_m contains the old T_(m−a). So items 1 to 4 survive a change of machine with m reduced by a, in contrast with the prediction at a single input before the threshold, which the grue theorem flips. Item 5 says where the grue theorem bites after the questions: at about m bits of machine change, at every unasked input alike.

### 3.4 Adaptive questions

**Proposition AQ5.** Order the total computable functions by complexity (ties by the order of their shortest programs).

(a) *Budget known.* The learner that keeps the members of H_b consistent so far and asks an input on which two of them differ asks fewer than 2^(b+1) questions and then holds exactly the target, for every target in H_b.

(b) *No budget.* The learner that repeatedly asks the least input on which the two first consistent functions g₁, g₂ of the order differ, and guesses g₁, has g₁ = f after fewer than 2^(K(f)+1) questions, and for ever after.

*Proof.* (a) Each question removes at least one member, and H_b has fewer than 2^(b+1). (b) While g₁ ≠ f, both g₁ and g₂ precede f or g₂ = f; the answer contradicts one of g₁, g₂, and it never contradicts f; so each question removes a function that precedes f, and fewer than 2^(K(f)+1) − 1 functions precede f. Afterwards f is first and is never removed. ∎

(a) is Angluin's N − 1 bound for N = |H_b|. Non-adaptively Theorem AQ4(3) uses 2^(2b + c₀ + 1) questions; whether a non-adaptive set of size 2^(b + O(log b)) works for all of H_b I do not know.

### 3.5 Lower bounds

**Proposition AQ6.**

(a) *Certified exactness with a budget.* Let a learner, adaptive and possibly randomised, output for every target g ∈ H_b a function that equals g on S with probability at least 1 − δ. Then for every f ∈ H_b the expected number of questions it asks when the target is f is at least

    (1 − 2δ) · #{x ∈ S : K(f) + K(x | f) + c ≤ b},   which for S = X is at least   (1 − 2δ) · 2^(b − K(f) − 2 log b − c).

(b) *On average over the prior.* The same learner, with the target drawn from the prior proportional to 2^(−K(g)) on H_b, asks at least (1 − 2δ)·2^(b − 2 log b − c) questions in expectation (S = X).

(c) *Any number of questions.* For every set T of at most q asked inputs and every f there is a function g that agrees with f on T, differs from f at an input among the first q + 1 strings, and has K(g) ≤ K(f) + log(q+1) + 2 log log(q+2) + c.

(d) *Convergence without a certificate.* For every k and every learner, adaptive and randomised, there is a target f with K(f) ≤ k such that the expected number of questions before the learner's guess first equals f is at least 2^(k − 2 log k − c)/4.

*Proof.* (a) For each such x the one-point change g_x of f at x is in H_b and differs from f on S; by Lemma AQ1(b) the learner asks x with probability at least 1 − 2δ when the target is f; add up over x. Count: numbers below 2^i with i + 2 log i + c ≤ b − K(f). (b) The constant zero function has prior weight at least 2^(−c) and by (a) costs 2^(b − 2 log b − c). (c) One of the first q + 1 strings is not in T; change f there. (d) Take the N = 2^i point functions e_a(x) = 1[x = a], a < 2^i, where i + 2 log i + c ≤ k, and a uniformly random a. Until a is asked all answers are 0, so the sequence of asked inputs and guesses is the one the learner produces against the zero function. In j questions it can ask at most j candidates and guess at most j + 1 of them, so the guess has been e_a, or a has been asked, with probability at most (2j + 1)/N. Summing the tail gives an expectation of at least N/4. ∎

(a) with Proposition AQ5(a): **certified exactness at all inputs within budget b costs between 2^(b − K(f) − 2 log b − c) and 2^(b+1) questions when the target is f.** For simple targets this is 2^(b ± O(log b)): matching up to a polynomial factor. Note which targets are expensive: the *simple* ones, because more of their patches fit in the budget. `abstention-shift.md` §7.2 has the same exponent for KWIK learning of H_k; the content here is that choosing the questions, randomising, and averaging over the prior (b) do not change it.

### 3.6 Three numbers for one target

| task, for a target f | questions | source |
|---|---|---|
| a teacher who knows f makes the Bayes learner's top guess right at every input | at most K(f) | the researcher's proposition (§2.4) |
| an uninformed learner's guess becomes f and stays f | fewer than 2^(K(f)+1); for some f of each complexity k, at least 2^(k − 2 log k − c)/4 | Propositions AQ5(b), AQ6(d) |
| the learner can certify its guess against all targets of complexity at most b | between 2^(b − K(f) − 2 log b − c) and 2^(b+1) | Propositions AQ6(a), AQ5(a) |

* **Teaching against finding out.** The teacher's K(f) examples exist, and only someone who knows f can pick them: for the point functions the single example (a, 1) teaches e_a, and an uninformed learner needs about half of all candidates to find it. This is the gap between the teaching dimension and the membership-query complexity of the singletons, and it is exponential in the universal class. For imitation: *where* the human deviates from the simplest account of the answers so far is worth exponentially more than answers at inputs chosen without that knowledge. A way to obtain it would be an equivalence-type query ("here is the current imitator; show me a question on which it answers unlike you"), which a human can sometimes answer and which is not a membership query.
* **Being right against knowing it.** The learner of Proposition AQ5(b) is right at every input after 2^(K(f)+1) questions, a number that depends on the target and not on any budget; it can never announce this. The certificate costs a further factor of up to 2^(b − K(f)), paid entirely for alternatives that are *more* complex than the hypothesis already held. This is the distinction of Balcan, Hanneke and Vaughan (§2.5) in the universal class, with the roles of "logarithmic" and "1/ε" played by 2^(K(f)) and 2^b.

### 3.7 Abstention: answering only where the answer is certain

**Proposition AQ7.** Let a rule ask questions and then, at each input, give a label or abstain, and suppose that for every target in H_b every label it gives is correct. When the target is f and T is the set of asked inputs:

(a) the rule abstains at every x ∉ T with K(f) + sep(x; T | f) + c ≤ b;

(b) the rule that answers where all consistent members of H_b agree answers every x with sep(x; T | f) > b + c;

(c) if |T| ≤ q and μ is a distribution on strings of length at least ℓ whose first ℓ bits are uniform, the rule answers a set of μ-measure at most q·2^(−ℓ), for every ℓ with K(f) + ℓ + 2 log ℓ + c ≤ b. So its coverage is at most q·2^(−(b − K(f) − 2 log b − c)).

*Proof.* (a) The patch of f at x on a cheapest separating set is in H_b and gives the same answers on T; the rule's output at x is the same under both targets and they differ at x. (b) A consistent g ∈ H_b that differs from f at x gives the separating set {g ≠ f} of complexity at most b + c given f. (c) The 2^ℓ sets "strings with prefix p", |p| = ℓ, are disjoint, have complexity at most ℓ + 2 log ℓ + c, and at most q of them contain an asked input; apply (a) to the others. ∎

So with abstention the picture of §3.5 becomes a picture of coverage: **before about 2^(b − K(f)) questions the never-wrong rule answers a fraction of inputs that is at most proportional to the number of questions; the choice of questions does not help.** After the 2^(b + K(f) + c) questions of T_m it answers everything. For comparison [read in source: `abstention-shift.md` §3.3, restating El-Yaniv and Wiener 2010, Theorem 8], with m random questions from μ the abstention mass is at most ((ln 2)·|H| + ln(1/δ))/m, here about 2^(b+1)/m. The abstention region is known to the rule without asking the human (it is where the consistent hypotheses within budget disagree), so the failure is of the obvious kind; it is just large.

### 3.8 One known deployment distribution: choosing the questions saves at most the factor K

**Proposition AQ8.** Let q ≥ 1, ℓ = ⌈log q⌉ + 1, and let μ be a distribution on strings of length at least ℓ whose first ℓ bits are uniform. Let f be total computable and, for each p ∈ {0,1}^ℓ, let g_p be the function that differs from f at every input with prefix p (0 where f is not 0, 1 where it is) and equals f elsewhere; K(g_p) ≤ K(f) + log q + 2 log log q + c.

(a) For every learner that asks at most q questions (adaptive, randomised, any inputs) and outputs a predictor: either its expected μ-error on target f exceeds 1/4, or its expected μ-error on g_p, averaged over p, is at least 1/(16q).

(b) For SOI (the mixtures W and M_F) after any q questions answered by f: the expected posterior probability of a wrong label at a μ-random input is at least 2^(−c)/(8q·(log q + 2)²).

(c) Random questions from μ suffice up to the factor K: after n ≥ (b ln 2 + ln(1/δ))/ε of them, with probability 1 − δ every member of H_b consistent with the answers has μ-error at most ε (Occam's razor, §2.9).

*Proof.* (a) Fix the coins and consider the run under f, with asked set T and output h. At least 2^ℓ − q ≥ 2^(ℓ−1) prefixes p are not prefixes of any asked input; for these the run under g_p is the same. Since f and g_p differ on all inputs with prefix p, err(h; g_p) ≥ 2^(−ℓ) − μ{x with prefix p : h(x) ≠ f(x)}. Summing over the unasked prefixes, Σ_p err(h; g_p) ≥ 1/2 − err(h; f). Take expectations and divide by 2^ℓ < 4q. (b) A μ-random x has an unasked prefix p with probability at least 1/2, and then sep(x; T) ≤ ℓ + 2 log ℓ + c; apply the floor. (c) is `repo.md` B4. ∎

So on a known distribution the number of questions for error ε on all targets of complexity at most b is between 1/(16ε) and (b ln 2 + ln(1/δ))/ε, provided ε ≥ 2^(−b + O(log b)). **Membership queries, however cleverly chosen, save at most the factor b ln 2 + ln(1/δ) over drawing the questions from the deployment distribution.** This is Theorem 3 of Hanneke and Yang for a class with star number about 2^b (the term min{s, 1/ε}), derived here directly. It is also the reason why the lead's rehearsal protocol, which only samples the imitator's own deployment distribution, cannot be improved by a cleverer choice of questions by more than the factor K, and why query-by-committee and information-gain rules (§2.7) have nothing to offer here: the best question removes posterior mass of order 1/q.

Part (b) is `repo.md` B5 with "n random training inputs" replaced by "any q inputs": the 1/q floor of SOI on its own training distribution does not come from bad luck in the sample.

### 3.9 The posterior probability of exact identity

**Proposition AQ9.** Let T be any set of q asked inputs, D the answers of f on T, and labels binary on the patches used below.

(a) *λ = 1.* The W_tot-posterior probability of f satisfies

    1 − post(f | D) ≥ γ/(1 + γ),   γ := 2^(−c−1) · Σ_{ℓ ≥ ⌈log 2q⌉} 2^(−K(ℓ)).

Consequently, for every computable function N there is a constant c_N > 0 such that for all j ≥ 2, after any N(j) questions the posterior probability that the target is not f is at least c_N/j². No computable number of questions, as a function of the wanted confidence, makes the plain mixture confident that it holds exactly f.

(b) *λ > 1.* For the prior with weights 2^(−λK): after any q questions, 1 − post_λ(f | D) ≥ γ_λ/(1 + γ_λ) with γ_λ = 2^(−λc−1)·(4q)^(−(λ−1))·(log 4q)^(−2λ); and after the questions T_m, by Theorem AQ4(4), 1 − post_λ(f | D_m) ≤ 2^((2λ−1)K(f) + (λ−1)c₀)·(2/q)^(λ−1). So the best achievable doubt about exact identity is q^(−(λ−1)) up to polylog q and a factor 2^(O(K(f))).

*Proof.* For ℓ with 2^ℓ ≥ 2q at least 2^(ℓ−1) prefixes p of length ℓ are prefixes of no asked input. For each, the function g_p that flips f on the strings with prefix p is consistent with D, and K(g_p) ≤ K(f) + ℓ + K(ℓ) + c. These functions are distinct for distinct p. So the weight of consistent functions other than f is at least Σ_ℓ 2^(ℓ−1)·2^(−K(f) − ℓ − K(ℓ) − c) = 2^(−K(f))·γ, and post(f | D) ≤ 2^(−K(f))/(2^(−K(f)) + 2^(−K(f))·γ). For the consequence: a_j := ⌈log 2N(j)⌉ is computable from j, so K(a_j) ≤ 2 log j + c_N′ and γ ≥ 2^(−c−1−c_N′)/j². (b) The same sum with weights 2^(−λ(·)), keeping only the term ℓ = ⌈log 2q⌉ ≤ log 4q and using K(ℓ) ≤ 2 log ℓ + c. ∎

Reading. The universal prior spreads the possibility of an exception evenly over all *scales*: exceptions on a set of relative size 2^(−ℓ) have total prior weight about 2^(−K(ℓ)), and Σ_ℓ 2^(−K(ℓ)) converges more slowly than any computable series. Questions remove the scales coarser than 1/q and leave the finer ones. `note.md` (end of §5) says this in words ("it gives exceptions at every scale comparable total weight, and this is why its doubt decays only like 1/n"); (a) is the quantitative form for exact identity, and it holds for every way of choosing the questions. A steeper prior makes the weight of scale 2^(−ℓ) about 2^(−(λ−1)ℓ), summable geometrically. This is a third reason for λ > 1 in this project, next to the model–randomness split of Paper 2 and the finite entropy noted in `abstention-shift.md` §7.3.

A pointwise upper bound for the plain mixture after T_m, of the form "wrong-label probability at every unasked x at most 2^(O(K(f)))·poly(m)·2^(−m)", would complement Theorem AQ4(5). I could not prove it. It needs the total weight Σ 2^(−K(Q)) of *all* separators of x from T_m, not the weight of the cheapest, and that is open question 5 of `note.md` ("sums against maxima") for A = T_m. In every family of separators I tried (prefix classes, intervals, hash classes, thresholds above the largest element of T_m) the sum is O(2^(−m)), because the index of the separator within the family has to be paid for as well.

### 3.10 Why the exponent is the number of nameable inputs, and when it is not exponential

**Proposition AQ10 (naming growth).** Let a hypothesis language assign to each hypothesis h a size and a total function, with finitely many hypotheses of each size, and let name : X → N be any function such that

  (N) whenever two hypotheses h, h′ denote different functions, they differ at some input x with name(x) ≤ size(h) + size(h′) + c.

Let G(m) := #{x : name(x) ≤ m}. Then the answers on {x : name(x) ≤ 2b + c}, which are G(2b + c) questions fixed in advance, determine the target among all hypotheses of size at most b.

*Proof.* Two hypotheses of size at most b that agree on that set cannot denote different functions, by (N). ∎

* For programs, (N) holds with name = K (the first disagreement is computable from the two programs), and G(m) is about 2^m: Theorem AQ4(3).
* [read in source: `equational.md`, Theorem 2 and the summary items 6 and 7] For the equational inductor the corresponding statement is Theorem 2: once the data contain the target on the box [0, τ_g(m))^k, every identity with sides of at most m symbols in a fitting set is true of the target, where the *test radius* τ_g(m) is how far the data must reach to refute every false identity with sides of at most m symbols. For addition τ(m) ≤ m − 1, so the question set is a box of side linear in m, of polynomial size, and the pinning is linear in its side. The note's explanation is the naming principle: "An exception at x costs at least what it costs to name x in the vocabulary", and "With unary numerals, naming x takes x symbols". With a doubling function in the vocabulary, or with auxiliary symbols, or for a fast-growing target, short terms name large numbers, the test radius becomes exponential in m (2^(m−2) + 1 for doubling) and "the inductor behaves much like SOI".
* So, in both theories, **the number of questions that pins a target at every input is the number of inputs that hypotheses of comparable size can name.** A universal language names 2^m inputs with m bits, and that is the whole reason for the exponent in §3.5. A guarantee at every input with polynomially many questions needs a hypothesis language with polynomial naming growth, which is a restriction of the class (and by `equational.md` Proposition 6 such a language cannot even express squaring by a finite set of laws). Whether a person's behaviour is well described in a language of slow naming growth is not something answers can show.
* The other known way to make certificates small is separation: in a class any two of whose members differ on μ-mass at least δ, O((b + log(1/η))/δ) random questions from μ are a certificate with probability 1 − η (`note.md` Theorem 9; `abstention-shift.md` §7.5). In the terms of §2.2 such a class has no specifying sets larger than that, because it has no star sets of small measure.

### 3.11 The question of the task, answered

*For a class H of deterministic functions with a prior w, and a learner that may ask any inputs, what is the least expected number of questions that guarantees agreement with the target on all inputs of a deployment set S?*

| guarantee | least number of questions, target f | where |
|---|---|---|
| zero error on S, every target in a class H | at least cert_S(f; H); at most XTD_S(H)·(log(1/w(f)) + 1); in expectation over w at least max(E_w cert_S, entropy of f\|_S) | Lemma AQ1, Proposition AQ2 |
| the same, H finite, S = X | max(ETD, log \|H\|) ≤ worst case ≤ (2 ETD/log ETD)·log \|H\|; GBS within (ln(1/min w) + 1)² of the best expected number | §2.2 (Bshouty's Lemma 3; Golovin–Krause Theorem 21) |
| every computable target, no budget | \|S\| (ask everything) | Proposition AQ3(a) |
| every target of complexity ≤ b, error probability δ | between (1 − 2δ)·#{x ∈ S : K(f) + K(x\|f) + c ≤ b} and min(\|S\|, 2^(b+1)); for S = X between 2^(b − K(f) − 2 log b − c) and 2^(b+1); the same on average over the prior | Propositions AQ3, AQ5, AQ6 |
| never wrong on H_b, may abstain | coverage at most q·2^(−(b − K(f) − 2 log b − c)) after q questions | Proposition AQ7 |
| guess equal to f at all inputs from some time on, no certificate | fewer than 2^(K(f)+1); not below 2^(k − 2 log k − c)/4 for some f of each complexity k | Propositions AQ5(b), AQ6(d) |
| posterior probability of exactly f at least 1 − η, prior 2^(−λK) | λ = 1: not bounded by any computable function of 1/η; λ > 1: (2^(O(K(f)))/η)^(1/(λ−1)) questions suffice and (1/η)^(1/(λ−1))/polylog are needed | Proposition AQ9, Theorem AQ4(4) |
| error ε on a known distribution, all targets of complexity ≤ b | between 1/(16ε) and (b ln 2 + ln(1/δ))/ε | Proposition AQ8 |

---

## 4. Samplers

**[my own derivation]** throughout, with the standard tools named.

### 4.1 What changes

A question at x now returns a draw from P(·|x), fresh at every asking (the lead's assumption A1). Three things change.

* A single answer refutes only hypotheses that give it probability 0. To tell P(·|x) from a distribution at total variation distance ε takes of the order of 1/ε² answers *at that x* (1/ε if one of the two is a point mass).
* A patch can be *soft*: "P, except that on Q each answer is tilted by ε". Soft patches of this kind are the nearest alternatives in the sense of Chernoff's D\* (§2.8), and they cost K(Q | P) + K(ε) + O(1) bits.
* The object to be certified is a kernel, and exact identity is replaced by closeness at every input: sup_x TV(P′(·|x), P(·|x)) ≤ ε.

**Setting.** A *total computable kernel* ν gives, for every x, a probability distribution ν(·|x) on Y such that (x, y) ↦ ν(y|x) is a computable real uniformly in (x, y). (A probabilistic program that halts with probability 1 on every input defines one.) K(ν) is the length of a shortest program; **H^s_b** is the set of total computable kernels with K(ν) ≤ b, fewer than 2^(b+1) of them. ε is a rational, K(ε) its complexity (at most 2 log log(1/ε) + c for ε = 2^(−r)).

### 4.2 Closeness at every input after the canonical questions

**Protocol.** Input: b, ε, δ. Let m := 2b + K(ε) + c₃ and N := ⌈(8/ε²)·((m + 2b + 4)·ln 2 + ln(1/δ))⌉. Put each input of T_m to the human N times; let P̂_x be the empirical distribution of the N answers at x. *Accept* a kernel ν ∈ H^s_b if for every x ∈ T_m and every ν′ ∈ H^s_b,

    | ν(A | x) − P̂_x(A) | ≤ ε/4   for   A = A_x(ν, ν′) := { y : ν(y|x) > ν′(y|x) }.

Output the accepted kernel with the shortest program (the first, among several).

**Theorem AQ11.** If P ∈ H^s_b then, with probability at least 1 − δ, P is accepted and every accepted kernel ν satisfies

    TV(ν(·|x), P(·|x)) ≤ ε   for every input x ∈ X.

The protocol asks fewer than 2^(2b + K(ε) + c₃ + 1)·N questions, all fixed in advance. Its output is a single program of at most b bits.

*Proof.* There are fewer than 2^(m+1) inputs in T_m and fewer than 2^(2b+2) pairs (ν, ν′). By Hoeffding's inequality and a union bound, with probability at least 1 − 2^(m+2b+4)·exp(−Nε²/8) ≥ 1 − δ we have |P̂_x(A) − P(A|x)| ≤ ε/4 for all x ∈ T_m and all sets A = A_x(ν, ν′). On this event P is accepted. Let ν be accepted and x ∈ T_m. With A = A_x(ν, P), TV(ν(·|x), P(·|x)) = ν(A|x) − P(A|x) ≤ |ν(A|x) − P̂_x(A)| + |P̂_x(A) − P(A|x)| ≤ ε/2. Now suppose TV(ν(·|z), P(·|z)) > ε for some z ∈ X. For computable kernels the total variation Σ_y (ν(y|x) − P(y|x))⁺ is lower semicomputable uniformly in x, so the set U = {x : TV(ν(·|x), P(·|x)) > ε} is computably enumerable from programs for ν and P and from ε. It is nonempty, so the first element z′ of a fixed enumeration of it has K(z′) ≤ K(ν) + K(P) + K(ε) + c₃ ≤ m. Then z′ ∈ T_m and TV at z′ exceeds ε > ε/2, a contradiction. ∎

The comparison of each candidate with the data on the sets {ν > ν′} is the minimum-distance method of Yatracos (1985) [from memory]; the rest is Theorem AQ4 with "first disagreement" replaced by "first input at which the two kernels are ε-apart".

Remarks.

* The guarantee is at every input, in or out of any distribution, for any deployment set and any scaffold: a run of L calls answered by the output is within L·ε of the human system's run in total variation, by the coupling of the lead's Section 1. The price is the factor 2^(2b).
* The output is one program for a kernel, not a mixture, and it is close to P at every input. Whether it is P's own program, or computes the kernel as P does, is not determined: the data identify behaviour (`repo.md` F8).
* With a budget that is too small (P ∉ H^s_b) either nothing is accepted, which is an obvious failure, or something is accepted that matches P to ε/2 on T_m and may differ elsewhere; the theorem then says nothing. Realizability fails silently here as everywhere (`abstention-shift.md` §9.5).

### 4.3 The lower bound

**Proposition AQ12.** Let 0 < ε ≤ 1/20 and 0 < δ < 1/4, and let a protocol, adaptive and randomised, output for every target ν ∈ H^s_b a kernel P′ with Pr[TV(P′(·|x), ν(·|x)) ≤ ε for all x ∈ S] ≥ 1 − δ. Let P ∈ H^s_b have labels in {0,1} at x₀ ∈ S, and let n(x₀) be the number of times the protocol asks x₀ when the target is P.

(a) If P(1|x₀) ∈ [1/4, 3/4] and K(P) + K(x₀ | P) + K(ε) + c ≤ b, then E[n(x₀)] ≥ ln(1/(4δ))/(58·ε²).

(b) If P(·|x₀) is a point mass and K(P) + K(x₀ | P) + K(ε) + c ≤ b, then E[n(x₀)] ≥ ln(1/(4δ))/(3ε).

So the expected number of questions on target P is at least the number of such inputs times these amounts; for S = X and a P that is balanced at the inputs concerned, at least 2^(b − K(P) − K(ε) − 2 log b − c)·ln(1/(4δ))/(58 ε²).

*Proof.* Let P° equal P except at x₀, where P°(1|x₀) = P(1|x₀) + 2.5ε in case (a) and P°(·|x₀) = (1 − 2.5ε)·(the point mass) + 2.5ε·(a point mass at another label in {0,1}) in case (b). Then P° ∈ H^s_b, TV(P°(·|x₀), P(·|x₀)) = 2.5ε, and κ := KL(P(·|x₀) ‖ P°(·|x₀)) is at most (2.5ε)²/(p′(1 − p′)) ≤ 58ε² with p′ ∈ [1/4, 7/8] in case (a), and ln(1/(1 − 2.5ε)) ≤ 3ε in case (b). The two runs differ in law only through the answers at x₀, so the divergence between the laws of the whole interaction is E_P[n(x₀)]·κ (the chain rule for adaptively chosen questions; the lead's L1). Let A be the event TV(P′(·|x₀), P(·|x₀)) ≤ ε. Under P, Pr[not A] ≤ δ. Under P°, with probability 1 − δ the output is within ε of P° at x₀, hence at distance at least 1.5ε from P, so Pr[A] ≤ δ. By the inequality of Bretagnolle and Huber, Pr_P[not A] + Pr_{P°}[A] ≥ (1/2)·exp(−E_P[n(x₀)]·κ) [from memory: the inequality is standard, e.g. Tsybakov, *Introduction to Nonparametric Estimation*, 2009, Lemma 2.6]. Hence E_P[n(x₀)] ≥ ln(1/(4δ))/κ. ∎

Theorem AQ11 and Proposition AQ12 have the same shape as §3.3 and §3.5: about 2^(2b) inputs against 2^(b − K(P)), and O((b + log(1/δ))/ε²) answers per input against log(1/(4δ))/(58ε²). In the terms of §2.8: D\*(P) is at most 58ε² divided by the number of nameable inputs, because the questions have to be spread over all of them.

### 4.4 Three further remarks on samplers

* **Frozen answers.** If asking x again returns the same answer, no number of questions pins P(·|x₀) at one input, the alternatives P° of Proposition AQ12 can never be refuted, and no protocol has the guarantee of Theorem AQ11 for any ε < 1/2 and any budget that names one input at which P is not deterministic. Only perturbations that are coherent over many inputs can then be excluded, and only frequencies of tests can be certified (the lead's Theorem V1(b)). Fresh answers are doing real work in Theorem AQ11.
* **A deployment distribution.** For closeness on average over a known distribution the analogue of Proposition AQ8 holds with the same proof: soft patches on the 2^ℓ prefix classes force 1/ε-type lower bounds for per-call total variation ε on average, and the Bayes mixture reaches KL of K ln 2/n (`repo.md` B2). Choosing the questions again saves at most the factor K.
* **Abstention.** The rule "answer at x when all accepted kernels are within ε of one another at x, else abstain" is, on the event of Theorem AQ11's proof, never more than ε wrong where it answers, for any set of asked inputs; it abstains wherever a cheap soft patch has not been tested. I have not worked out the coverage bound; it should be Proposition AQ7 with the factor 1/ε² per input.

---

## 5. What this means for an imitation protocol

1. **Three regimes, and they do not mix.**

   | what is guaranteed | questions | human needed later? |
   |---|---|---|
   | right at every input, any deployment (Theorems AQ4, AQ11) | 2^(Θ(b)), b ≥ K(human); necessary by Propositions AQ6, AQ12 | no |
   | error rate ε per call on the deployment distribution of a closed system (the lead's R1) | K ln 2/ε per unit of rate; at least 1/(16ε) (Proposition AQ8) | no |
   | at most K(f) + c wrong answers on any sequence, each then corrected (`repo.md` C1) | one per detected failure | yes, at failures |

   For a person, 2^(K) is not a number of questions. So the first regime is a statement of impossibility in practice and of possibility in principle: **a protocol that "works under every distribution shift" exists and its cost is the number of inputs nameable within the human's description length; no protocol does better.** The second regime is what the lead's draft builds on, and Proposition AQ8 says it is optimal up to the factor K ln 2 among all ways of choosing questions.

2. **Rehearsal is Angluin's simulation of equivalence queries.** An equivalence query ("is this imitator right everywhere? if not, where?") would identify the human with K(f) counterexamples by majority vote. Nobody can answer it. Angluin's conversion (§2.1) replaces it by a sample from the distribution that matters, with error ε on that distribution. Rehearsal draws that sample from the imitator's own runs. The cost K/ε is "K equivalence queries at 1/ε questions each".

3. **A counterexample channel is worth an exponential.** If failures of the imitator during deployment are detected (by a checker, by a later step that does not go through, by the validation phase) and the offending question is then put to the human, each such event is a counterexample in Angluin's sense, and the posterior-majority predictor suffers at most K(f) + c of them on any input sequence whatever. "Failing obviously" is therefore not only a safety property; it is the one cheap substitute for the 2^b certificate. The same holds for an informed teacher (§3.6).

4. **Which questions to ask, if any are to be chosen.** Not the first q inputs of an enumeration and not q inputs of one kind: the design that maximises the least novelty of an unasked input is "the simplest inputs of every kind" (Theorem AQ4(6)), equivalently a sample from a universal mixture of input distributions. In a closed system the lead's protocol already asks on the right distribution; the canonical set is the answer to "which questions protect against the shifts we did not foresee", and its protection is 2^(−sep) with sep ≈ log q at every unasked input.

5. **A steeper prior is needed for any statement about exact identity** (Proposition AQ9), and with λ > 1 the canonical questions give posterior mass off the human of order q^(−(λ−1)) at all inputs at once. This could be stated in the note as the Bayesian form of "identification up to patches that are expensive to name".

6. **Where the exponent could really go away.** (i) A hypothesis language with slow naming growth (Proposition AQ10): the equational inductor is the one worked example, for deterministic laws. (ii) A separated class (isolation). (iii) Richer answers than values at points: in query-learning terms, anything closer to an arbitrary yes–no question about the target (§2.6), such as a truthful answer to "would you ever answer inputs of kind Q differently?", cuts a whole guard with one question; `abstention-shift.md` §3.4 records the same lesson from comparison queries. Each of these is an assumption about the human or about what the human can report, and none can be checked by membership queries.

7. **For the seven tests of `notes.md` §5.** *Guard:* the canonical set answers it for every guard of fewer than m − c₀ bits, at the price 2^m; rehearsal answers it for guards of frequency above about 1/n on the deployment distribution. *Machine:* Theorem AQ4 is stable under a change of machine by a bits with m reduced by a. *Budget:* fails, by a theorem. *Rock:* after T_m no abstention is needed; before it, Proposition AQ7 says the never-wrong rule is a rock on all but a q/2^b fraction.

---

## 6. What I could not verify, and what is open

**Not verified in the original** (tags in the text): the query counts of L\* and the sample sizes r_i, q_i (Angluin 1987, 1988); the N − 1 lemma of Angluin 1988; the exact statements of Kearns–Valiant, Angluin–Kharitonov and Bshouty et al. 1996 (search results only); Goldman–Kearns beyond what Bshouty's survey restates; Hegedűs and Hellerstein et al. (restatements only); the quantitative form of the query-by-committee theorem; the BALD objective; Blumer et al.; Turán 1993 (not seen at all); the metric-entropy formula of Kulkarni, Mitter and Tsitsiklis; Bretagnolle–Huber and Yatracos (standard, from memory); the journal data marked "from memory". The exponent 2 in Golovin and Krause's Theorem 21 is read from a broken line of extracted text.

**Open in the derivations.**

1. A pointwise upper bound for the plain mixture after the canonical questions (§3.9): is Σ 2^(−K(Q)) over all decidable Q that contain a given x ∉ T_m and miss T_m at most poly(m)·2^(−m)?
2. Non-adaptive certificates for all of H_b: 2^(2b + c) questions suffice (Theorem AQ4(3)), 2^(b − O(log b)) are needed. Which is right?
3. The gap between 2^(b − K(f)) and 2^(b+1) for complex targets in Proposition AQ6(a): I conjecture cert_X(f; H_b) is about 2^(b − K(f)) plus a polynomial in b, because alternatives that are not near-patches of f should be refuted by few questions.
4. Coverage of the abstaining rule for samplers (§4.4).
5. Computable versions (time-bounded complexity on a finite domain) of Theorems AQ4 and AQ11.
6. The same analysis for the lead's scaffold: the canonical set for the inputs that a given scaffold can produce, which is a deployment set S with structure; Proposition AQ3 applies, and I have not computed the transversal number for any scaffold.

---

## 7. References

Opened in this session (full text unless noted):

* N. H. Bshouty, "Exact Learning from an Honest Teacher That Answers Membership Queries", arXiv:1706.03935, 2017. https://arxiv.org/abs/1706.03935
* S. Hanneke and L. Yang, "Minimax Analysis of Active Learning", *Journal of Machine Learning Research* 16(109):3487–3602, 2015; arXiv:1410.0996. https://arxiv.org/abs/1410.0996
* D. Golovin and A. Krause, "Adaptive Submodularity: Theory and Applications in Active Learning and Stochastic Optimization", arXiv:1003.3967 (v5); *Journal of Artificial Intelligence Research* 42:427–486, 2011 [journal data from memory]. https://arxiv.org/abs/1003.3967
* R. D. Nowak, "The Geometry of Generalized Binary Search", arXiv:0910.4397 (v5); *IEEE Transactions on Information Theory* 57(12):7893–7906, 2011 [journal data from memory]. https://arxiv.org/abs/0910.4397
* M. Naghshvar and T. Javidi, "Active sequential hypothesis testing", *Annals of Statistics* 41(6):2703–2738, 2013; arXiv:1203.4626. https://arxiv.org/abs/1203.4626
* M. Khodier and L. Schaeffer, "Self-Verifying Predicates in Büchi Arithmetic", arXiv:2507.19717, 2025 (used only for its restatement of Angluin's theorem). https://arxiv.org/abs/2507.19717
* Abstracts only: N. Puchkin and N. Zhivotovskiy, "Exponential Savings in Agnostic Active Learning through Abstention", arXiv:2102.00451, 2021; K. Chaudhuri, S. Kakade, P. Netrapalli and S. Sanghavi, "Convergence Rates of Active Learning for Maximum Likelihood Estimation", arXiv:1506.02348, 2015; N. Houlsby, F. Huszár, Z. Ghahramani and M. Lengyel, "Bayesian Active Learning for Classification and Preference Learning", arXiv:1112.5745, 2011; L. Hu, R. Wu, T. Li and L. Wang, "Quadratic Upper Bound for Recursive Teaching Dimension of Finite VC Classes", arXiv:1702.05677, 2017; Z. Gao, C. Ries, H. U. Simon and S. Zilles, "Preference-based Teaching", arXiv:1702.02047, 2017; M. Garcia-Piqueras and J. Hernández-Orallo, "Conditional Teaching Size", arXiv:2107.07038, 2021; J. Bhatia, "Simple and Fast Algorithms for Interactive Machine Learning with Random Counter-examples", arXiv:1810.00506, 2018.

Not opened (bibliographic data from search results or, where marked, from memory):

* D. Angluin, "Learning regular sets from queries and counterexamples", *Information and Computation* 75(2):87–106, 1987.
* D. Angluin, "Queries and concept learning", *Machine Learning* 2(4):319–342, 1988. doi:10.1007/BF00116828
* D. Angluin, "Negative results for equivalence queries", *Machine Learning* 5:121–150, 1990 [from memory]; D. Angluin, "A note on the number of queries needed to identify regular languages", *Information and Control* 51:76–87, 1981 [from memory].
* D. Angluin and M. Kharitonov, "When won't membership queries help?", *Journal of Computer and System Sciences* 50(2):336–355, 1995.
* M. Kearns and L. G. Valiant, "Cryptographic limitations on learning Boolean formulae and finite automata", *Journal of the ACM* 41(1):67–95, 1994.
* N. H. Bshouty, R. Cleve, R. Gavaldà, S. Kannan and C. Tamon, "Oracles and queries that are sufficient for exact learning", *Journal of Computer and System Sciences* 52(3):421–433, 1996. doi:10.1006/jcss.1996.0032
* T. Hegedűs, "Generalized teaching dimensions and the query complexity of learning", COLT 1995, pp. 108–117. doi:10.1145/225298.225311
* L. Hellerstein, K. Pillaipakkamnatt, V. Raghavan and D. Wilkins, "How many queries are needed to learn?", *Journal of the ACM* 43(5):840–862, 1996 [volume and pages from memory].
* M. Yu. Moshkov, "On conditional tests", *Problemy Kibernetiki* 40:131–170, 1983 [year from memory; cited by Bshouty].
* S. A. Goldman and M. J. Kearns, "On the complexity of teaching", *Journal of Computer and System Sciences* 50(1):20–31, 1995.
* S. Zilles, S. Lange, R. Holte and M. Zinkevich, "Models of cooperative teaching and learning", *Journal of Machine Learning Research* 12:349–384, 2011 [from memory].
* J. A. Telle, J. Hernández-Orallo and C. Ferri, "The teaching size: computable teachers and learners for universal languages", *Machine Learning* 108(8–9):1653–1675, 2019. doi:10.1007/s10994-019-05821-2
* D. Cohn, L. Atlas and R. Ladner, "Improving generalization with active learning", *Machine Learning* 15(2):201–221, 1994 [from memory].
* S. Hanneke, "A bound on the label complexity of agnostic active learning", ICML 2007; S. Hanneke, "Theory of Disagreement-Based Active Learning", *Foundations and Trends in Machine Learning* 7(2–3):131–309, 2014 [both from memory].
* S. Dasgupta, "Coarse sample complexity bounds for active learning", NIPS 2005; S. Dasgupta, "Analysis of a greedy active learning strategy", NIPS 2004; S. R. Kosaraju, T. M. Przytycka and R. S. Borgstrom, "On an optimal split tree problem", WADS 1999 (as cited by Hanneke–Yang and Golovin–Krause).
* M.-F. Balcan, S. Hanneke and J. W. Vaughan, "The true sample complexity of active learning", *Machine Learning* 80:111–139, 2010. doi:10.1007/s10994-010-5174-y
* B. Eisenberg and R. L. Rivest, "On the sample complexity of PAC-learning using random and chosen examples", COLT 1990, pp. 154–162.
* G. Turán, "Lower bounds for PAC learning with queries", COLT 1993, pp. 384–391. doi:10.1145/168304.168382
* S. R. Kulkarni, S. K. Mitter and J. N. Tsitsiklis, "Active learning using arbitrary binary valued queries", *Machine Learning* 11:23–35, 1993. doi:10.1023/A:1022627018023
* Y. Freund, H. S. Seung, E. Shamir and N. Tishby, "Selective sampling using the query by committee algorithm", *Machine Learning* 28:133–168, 1997. doi:10.1023/A:1007330508534
* H. Chernoff, "Sequential design of experiments", *Annals of Mathematical Statistics* 30(3):755–770, 1959 [from memory].
* A. Blumer, A. Ehrenfeucht, D. Haussler and M. K. Warmuth, "Occam's razor", *Information Processing Letters* 24(6):377–380, 1987. doi:10.1016/0020-0190(87)90114-1
* J. Bretagnolle and C. Huber, "Estimation des densités: risque minimax", *Zeitschrift für Wahrscheinlichkeitstheorie und verwandte Gebiete* 47:119–137, 1979; Y. G. Yatracos, "Rates of convergence of minimum distance estimators and Kolmogorov's entropy", *Annals of Statistics* 13(2):768–774, 1985 [both from memory].

In this repository: `/home/user/AI-works/ultranatural/note.md`, `/home/user/AI-works/ultranatural/equational.md`, and the digests `repo.md`, `notes.md`, `abstention-shift.md` in this folder.
