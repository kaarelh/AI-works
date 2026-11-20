# Thread B: knowledge elicitation

*What if the human is also asked for knowledge, not only for task steps: "write down what you know about τ", "what is your plan for p"? After such probes, every bound of the three notes holds with K(P) replaced by a residual R_T, the information about the human's task behaviour that the probe transcript leaves open. R_T is at most K(P's task behaviour | probe transcript) plus the complexity of the probe questions. For a human that is a core acting on a knowledge base, it is at most K(core, reporting map) + K(operative knowledge | reported knowledge) + K(questions), whatever the size of the knowledge base. Probes alone do not remove the factor n. On insights the human cannot report, note.md's Theorem 3 holds even when probes are free. What removes n is knowing where decisive knowledge acts. In the experiment, eliciting the full content of a knowledge base leaves the cost of chained imitation unchanged; eliciting each item's stage to within w steps brings the cost down to about w queries per item.*

Research thread B of the monitored-imitation project, by Claude (Anthropic). Draft. Not refereed. No human has checked the mathematics. Code: [`threadB_kb_probes.py`](threadB_kb_probes.py). Outputs: [`threadB_results/`](threadB_results/).

## Answers in brief

1. **Transfer (Theorem 1).** Probe answers from the same P are data like any other. After probe data D_z, at most R_T(D_z) ≤ K(P) − L(D_z) task queries land on mistakes. Here L(D_z) is the log loss already paid on the probes, and R_T counts only what is still open about the human's behaviour on task states. Every bound of the notes holds with R_T in place of K. If R_T < 1, the imitator's runs are the human's, with no task queries at all.
2. **The coding caveat (Proposition 2).** For the program mixture:

   K(P|_T | D_z) − O(log L) ≤ K_T − L(D_z), and R_T ≤ K_T − L(D_z) ≤ K(P|_T | D_z) + K(Z₀) + O(1).

   Here K_T is the shortest program consistent with the probes that acts as P on tasks, and Z₀ is the list of probe questions.
   * The K(Z₀) slack is function induction's K(dom D) gap, and it is attained: the learner is credited for information in the answers, not in the questions.
   * Given the questions, the coding theorem does hold: L(D_z) ≥ K(answers | questions) − O(1).
3. **Core + knowledge base (Theorem 3).** Let P act on task states as c(·, B_op), and let the probes determine a reported base B_rep. Then

   R_T ≤ K(c, e) + K(B_op | B_rep) + K(Z₀) + O(1),

   independent of K(B_rep).
   * Insights that the core generates during work from B_op cost nothing extra: an unbounded learner simulates the work.
   * What remains is the core and the tacit knowledge, K(B_op | B_rep).
4. **The lower bound relative to probes (Theorem 4).** Suppose each problem's insight is reportable with probability φ. Then every protocol needs (1−φ)·nm/4 task queries for failure ε on the hidden-insight class, even if it gets any number of probes free. That is Ω((1−φ)·n·R/(ε log(n/ε))), with R the residual after the probes. Probes turn the K of n·K/ε into R; they do not remove the n.
5. **Location, not content, is what costs (Remark after Theorem 4, and E5).** Take a silent rare item whose step is uniform over w candidates. Any protocol needs at least (w+1)/2 task queries to find it, and random testing needs w, whatever is known about its content. A probe that removes b bits of location divides that cost by about 2^b. A probe that removes content bits divides it by nothing. Only *generative* probes, whose answers name the item or its place, beat rarity. Those need the human to recall the item outside the context that normally triggers it.
6. **What does remove n without a check (Theorem 5, Proposition 6).** Each of the following is the kind of assumption the second note says is needed:
   * (a) complete elicitation relative to the learner's prior (R_T < 1);
   * (b) *located probes*: if the human names at most s steps that contain the decoder's first mistake on every failing run, 2s·R_T/ε task queries suffice;
   * (c) *diagnostic probes*: if every decoder whose run on p fails errs on a probe about p with probability δ, R/(δε) probes suffice and no task queries are needed;
   * (d) δ-isolation, with the patch-free learner of [`../../ultranatural/note.md`](../../ultranatural/note.md): (K ln 2 + ln(1/β))/δ samples.

   Each supplies *where* decisive knowledge acts, or a guarantee that nothing rare is left. Without them, n multiplies R_T, and Theorem 4 says this is unavoidable.
7. **Experiment E5** (Section 5; exact posteriors; about 50 techniques, each used by 2 problems; n = 16 → 1024). Chained imitation needs 3,000 → 185,000 task queries. Eliciting every content gives 760 → 47,000, the same as eliciting only *that* a technique exists, although it removes about 1,100 of the 1,370–1,600 bits. Content and stage give 0; the stage to within 8 steps, with aimed queries, about 380 at every n; 90% recall 570 → 32,000; stages misreported 20% of the time, with verification, 180 → 7,400.
8. **Real researchers** (Section 6). I expect much of the *bits* of a researcher's knowledge to be reportable, and the decisive rare events of a run (noticing that something applies here, now) to sit disproportionately in the part that is not: conditions of use, context-triggered recall, rarely exercised skills, inaccurate self-reports. Conjecture: probes cut K a lot and the factor n much less, unless they elicit conditions of use and the human's plans are accurate. With a check they help straightforwardly.

## 1. Setting

As in [`../note.md`](../note.md) §1, with the states split as X = T ⊔ Z.
* *The two kinds of input.* T holds the task states: everything a run of the human or of an imitator can visit. Z holds the *probe* inputs.
* *Queries.* The human is one total P : X → X. A probe at z returns P(z). Probes and task queries are counted separately.
* *The prior.* Hypotheses are functions on all of X, so the prior is what links probe answers to task behaviour.
* *Probe data.* D_z = {(z_i, a_i)}, with questions Z₀ = (z₁, …, z_J) in the order asked and answers a_i = P(z_i).
* *Notation.* L(D) = −log₂ W(D) is the loss paid on D, in any order. [P]_T = {ν : ν = P on T}.
* *The two residuals.*

  R(D_z) = log₂(W(D_z)/w(P)) = K(P) − L(D_z),  R_T(D_z) = log₂(W(D_z)/w(H_{D_z} ∩ [P]_T)) ≤ R(D_z).

  R_T is the posterior surprisal of "the human's task behaviour" after the probes.

## 2. Transfer

**Theorem 1.** Let D_z be labelled by P. Let task queries x₁, x₂, … ∈ T be chosen adaptively, and let D_t be D_z plus the earlier answers. Then Σ_t log₂ 1/ξ_{D_t}(P(x_t) | x_t) ≤ R_T(D_z), and at most ⌊R_T(D_z)⌋ task queries land on a mistake of the current decoder.
* Hence the following hold after the probes, with ⌊R_T(D_z)⌋ in place of ⌊K(P)⌋:
  * [`../note.md`](../note.md)'s Propositions 2, 8 and 10 and Theorems 6 and 7;
  * Theorems 1 and 3 of [`../without-a-check.md`](../without-a-check.md);
  * Theorem 1 of [`../robust-runs.md`](../robust-runs.md).
* If R_T(D_z) < 1, then G_{D_z} = P on T, so every imitator run is the human's.

*Proof.*
* The sum telescopes to log₂(W(D_z)/W(D_{T+1})).
* Every hypothesis in H_{D_z} ∩ [P]_T agrees with all the task answers, so W(D_{T+1}) ≥ w(H_{D_z} ∩ [P]_T).
* A query on a mistake pays at least one bit (note.md, Lemma 1). The protocols' proofs use Lemma 1 only in the form "at most ⌊K⌋ queries land on mistakes".
* Finally, at x ∈ T we have ξ_{D_z}(P(x) | x) ≥ 2^(−R_T) > 1/2, so the majority label is P(x). ∎

*Remarks.*
* If probes are interleaved with task queries, all queries together pay at most K(P), so the task queries pay at most K(P) minus what the probes paid when they were asked.
* One probe can pay many bits, up to the length of a long answer. A task query on a mistake is guaranteed only one, so probes are the "many bits per query" of slide 30. But only the bits about P|_T lower R_T. Bits about how the human phrases things, or about probes never asked, do not.

**Proposition 2 (residual and conditional complexity).** Take the program mixture of note.md, Remark 1.2: w(p) = 2^(−|p|) over the programs of a universal prefix machine, and w(P) = 2^(−K(P)).
* K(P|_T | D) is the length of a shortest program that, given D, computes P on T.
* K_T(D_z) is the length of a shortest program that is consistent with D_z and agrees with P on T.

For a constant c:
* **(a)** K(a | Z₀) ≤ L(D_z) + c.
* **(b)** R_T(D_z) ≤ K_T(D_z) − L(D_z) ≤ K(P|_T | D_z) + K(Z₀) + c.
* **(c)** K(P|_T | D_z) ≤ K_T(D_z) − L(D_z) + K(⌈L(D_z)⌉) + c.
* **(d)** The term K(Z₀) in (b) cannot be dropped. There are P and D_z with K(P|_T | D_z) ≤ c and R_T(D_z) ≥ K(Z₀) − O(log K(Z₀)).

With T = X, K_T = K(P), so (b) and (c) place R itself within K(P | D_z) − O(log L) and K(P | D_z) + K(Z₀) + c.

*Proof.*
* (a) Given Z₀, the map a ↦ W(Z₀, a) is lower semicomputable. Its sum over a is at most 1, because each program contributes to at most one a. Apply the conditional coding theorem.
* (b), first inequality: H_{D_z} ∩ [P]_T contains a program of length K_T.
* (b), second inequality: let q be a shortest program that computes P on T given D_z. Consider the program "decode Z₀, then decode a given Z₀, then decode q; on input z_i output a_i; otherwise run q with D_z".
  * Its length is K(Z₀) + K(a | Z₀) + |q| + c.
  * It is consistent with D_z and agrees with P on T.
  * Use (a).
* (c) Given D_z and k = ⌈L(D_z)⌉, enumerate the programs consistent with D_z, and request a codeword of length |p| − k + 1 for each.
  * The Kraft sum is 2^(k−1)·W(D_z) ≤ 1, so by Kraft–Chaitin K(p | D_z, k) ≤ |p| − k + c.
  * Apply this to a shortest program in H_{D_z} ∩ [P]_T, which given D_z computes P on T. Pay K(k) to supply k.
* (d) The example.
  * Let s be a string of length ℓ with K(s) ≥ ℓ. Let P(x) = s at every task state, including a fixed simple t₀ ∈ T.
  * Take one probe z_s, "is s your secret?", with P(z_s) = 1.
  * Given D_z, s can be read off the question, so K(P|_T | D_z) ≤ c.
  * The constant-1 program is consistent with D_z, so L(D_z) ≤ c.
  * Every program in [P]_T outputs s at t₀. By the coding theorem, their total weight is at most 2^(−K(s|t₀)+c) ≤ 2^(−ℓ+2c).
  * So R_T ≥ ℓ − 3c, while K(Z₀) ≤ ℓ + O(log ℓ). ∎

*What it means.*
* Up to the complexity of the questions, a probe transcript is worth the algorithmic information it carries about the task behaviour.
* The coding theorem fails for function programs by up to K(dom D) ([`../../solomonoff-operator-induction/README.md`](../../solomonoff-operator-induction/README.md)). Here the domain is the list of questions, and the learner is not credited for it. A question that contains the secret is explained equally well by a human who answers "yes" to everything.
* For questions from a short fixed curriculum, K(Z₀) is small. For long questions written by the protocol, it need not be.
* R_T itself can be smaller than the Kolmogorov residual K_T − L, since a mixture weight can exceed the weight of the shortest program. The protocols need only the upper bound (b).
* *Total functions.* For Solomonoff's mixture over total functions, (a) and (b) still hold: W_tot ≤ W, and the program in (b) is total if T is decidable. Part (c) uses an enumeration of the consistent hypotheses, which only the program mixture has.

## 3. A core acting on a knowledge base

**Theorem 3.** Suppose:
* P(x) = c(x, B_op) for x ∈ T, and P(z) = e(z, B_rep) for z ∈ Z;
* c and e are total computable, and B_op and B_rep are finite strings;
* B ↦ (e(z, B))_{z∈Z₀} is injective.

Then K(P|_T | D_z) ≤ K(c, e) + K(B_op | B_rep) + c₀. So after the probes every bound of the notes holds with

  R_T(D_z) ≤ K(c, e) + K(B_op | B_rep) + K(Z₀) + c₀.

*Proof.* Given D_z, search for the string B with e(z_i, B) = a_i for all i; it exists and is unique. Compute B_op from it with a shortest program for B_op given B_rep, and output c(x, B_op). Apply Proposition 2(b) and Theorem 1. ∎

* **The size of the base does not appear.** K(B_rep) is absent: a large knowledge base, fully reported, costs only probes.
* **K(c, e)** is the reasoning procedure together with the way the human expresses knowledge. With a class prior that knows c and e and that B_op = B_rep, R_T = 0 after complete elicitation (E5, row full(1)).
* **K(B_op | B_rep) is tacit knowledge.** What the human uses but does not report costs its full description. What it reports but does not use costs only the bits needed to strike it.

**Pre-existing knowledge versus insights generated during work.** In this formalism, an insight that the core derives during a run from B_op and the current state costs nothing beyond K(c). The learner has unlimited compute and simulates the n steps. So "not elicitable in advance" is not by itself an obstacle to the *bits*. Two things decide the cost:
* **Whether the information is in the transcript.** An insight is fresh relative to the probes if no short program computes it from them: it lives in c, or in the part of B_op not in B_rep.
* **Where the residual is exercised.** Chained imitation's factor n comes from residual bits exercised rarely, at unpredictable steps.
  * Learning the core suffices for the mistake count, which is at most K(c, e) + ….
  * But rare behaviours of the core cost as much as any rare knowledge: Theorem 4 applies to them with φ = 0.
  * So "no rare behaviours" has to be read in a sense that makes the decoder's mistakes located, detectable, or absent: (Loc) or (Cov) of Theorem 5, or isolation (Proposition 6). Learning c is not enough on its own.

**Theorem 4 (hidden insights relative to probes).**
* *The class.* Take note.md's class: m problems, n steps, insight probability η, q values. Add a probe z_p for each problem.
* *Reporting.* Each problem has an indicator E_p ~ Bernoulli(φ), independent of everything else.
  * If E_p = 1, then P(z_p) = (t_p, k_p), or "none" if p has no insight.
  * If E_p = 0, then P(z_p) = "nothing comes to mind".
  * P's answers to any other probe are functions of E and of (θ_p)_{E_p=1}.
* *The protocol.* It asks any number of probes and Q task queries, adaptively, and outputs Ĝ.

For θ and E drawn from the prior, and a fresh uniform problem p,

  Pr[the run of Ĝ on p differs from the human's] ≥ (1 − 1/q)·η·(1 − φ − 2Q/(nm)).

Take q = 2 and η = 8ε/(1−φ), for ε ≤ (1−φ)/16.
* Failure ≤ ε then needs Q ≥ (1−φ)nm/4.
* The expected residual, the unreported insights, is E[R] = (1−φ)m(h(η) + η·log₂(2n)) ≤ 8εm·log₂(en/(4ε)).
* So Q ≥ (1−φ)·n·E[R]/(32ε·log₂(en/(4ε))).

*Proof.* As for note.md's Theorem 3.
* Probe answers are functions of E and of θ_p for the problems with E_p = 1.
* Take p with E_p = 0, and let S be the set of steps at which p was task-probed and missed. Given the transcript, (t_p, k_p) has the prior law conditioned on t_p ∉ S. This uses that E is independent of θ, and that the other problems' parameters are independent of θ_p.
* So each task query hits with probability at most 2η/n, and the fresh p has been hit with probability at most 2ηQ/(nm).
* Hence Pr[E_p = 0, t_p < n, not hit] ≥ (1−φ)η − 2ηQ/(nm). On that event k_p is uniform given the transcript.
* The consequence follows as there, using h(x) ≤ x·log₂(e/x). ∎

With φ = 0 this is note.md's Theorem 3, with probes free. That case covers insights that cannot be reported in advance, and tacit rules of the core.

**Remark (location, and discriminative versus generative probes).** Step 2 of the proof is the whole story.
* Consider a silent item whose step is uniform over w candidates, given everything else.
* Each query at it tests one candidate, whatever is known about its content.
* So any protocol needs at least (w+1)/2 queries in expectation to find it, and uniform random testing needs w.
* Removing b bits of its location divides this by about 2^b. Removing bits of its content divides it by nothing.
* The same argument covers *discriminative* probes ("if you were at step j of p, would you have the idea?"). However cheap they are, each tests one candidate.
* Only *generative* probes, whose answers name the item or its place, beat rarity. They need the human to recall the item without the context that normally triggers it: the recall rate φ.

## 4. Combining with the protocols, and removing n

| after probes D_z | assumption | task queries | other queries |
|---|---|---|---|
| CI | none | n·R_T/ε | probes |
| EW (without-a-check.md) | (C_r) | 2r·H_n·R_T/ε | probes |
| MB, MB-PAC (note.md) | (M1), (M2) | at most R_T | probes, and checks as in note.md |
| any task-only protocol | none | at least (1−φ)·n·R/(32ε·log₂(en/(4ε))) on Theorem 4's class | any number of probes |
| none | R_T < 1 | 0 | probes |
| located probes (Theorem 5b) | (Loc_s) | 2s·R_T/ε | probes, plus one plan probe per problem |
| probe-chained (Theorem 5c) | (Cov_δ) | 0 | R/(δε) probes |
| patch-free learner (Proposition 6) | δ-isolation with respect to μ | 0 if μ is on probes | (K ln 2 + ln(1/β))/δ samples from μ |

* Under Theorem 3's structure, R_T ≤ K(c, e) + K(B_op | B_rep) + K(Z₀) + O(1).
* The rows for CI, EW, located probes and probe-chained imitation hold in expectation, with a random stopping round, on i.i.d. problems.

**Theorem 5.** Rounds are as in note.md's Protocol CI, with problems in any order. Part (a), complete elicitation, is the last claim of Theorem 1.
* **(b) Located probes.**
  * *The protocol.* In round t, ask the human a plan probe and obtain S_t ⊆ {0, …, n−1} with |S_t| ≤ s. The answer is used to choose where to ask; it is not added to the data. Then task-query step k_t ~ ½·U{0, …, n−1} + ½·U(S_t) of the decoder's run.
  * *The events.* A_t: run t fails and the decoder's first mistake on it lies in S_t. B_t: run t fails otherwise.
  * *The bound.* E Σ_t (1[A_t]/(2s) + 1[B_t]/(2n)) ≤ ⌊R_T⌋.
  * *Under (Loc_s),* that B_t never happens, at most 2s·R_T runs fail in expectation, and 2s·R_T/ε task queries give failure ε.
* **(c) Diagnostic probes.**
  * *The protocol.* For each problem p let μ_p be a distribution over probes. Ask one probe z_t ~ μ_{p_t} per round, and no task queries.
  * *The condition (Cov_δ):* whenever the decoder's run on p_t fails, Pr_{z∼μ_{p_t}}[G_t(z) ≠ P(z)] ≥ δ.
  * *The bound.* The expected number of failed runs is at most R(D_z)/δ.

*Proof.*
* (b) A failed run has a first mistake, at a state of the human's run (the first-divergence observation). So the step numbers in the human's plan refer to the decoder's states up to that point. The query lands on a mistake with probability at least 1/(2s) on A_t and at least 1/(2n) on B_t. Apply without-a-check.md's Theorem 1, with Theorem 1 here.
* (c) The probe lands on a mistake with probability at least δ·1[run t fails]. Lemma 1, applied to the probe queries, bounds the expected number of such probes by R(D_z). ∎

* **(Loc_s)** is a joint condition on the human and the learner, like (C_r).
  * *Where it holds.* In the hidden-insight class, with the plan answer S_p = {t_p} or a window around it. The class-prior decoder never writes an unconfirmed insight (without-a-check.md, Lemma 5), so its first mistake is at t_p.
  * *What it needs.* The human must know in advance where its decisive steps are. The misreport rows of E5 show the cost of being wrong.
* **(Cov_δ)** makes a probe into a check, with the comparison done by the protocol: the decoder's answer against the human's.
  * *Its weak point* is the learner's say–do gap. Under a universal prior, a hypothesis that answers probes as the human does but acts without the knowledge costs about as much as the human. So nothing forces a decoder that answers the probes right to act right.
  * *Where it holds:* class priors in which acting and reporting share one B.

**Proposition 6 (isolation).** Let μ be any distribution over X that the protocol can sample, and let d(f, g) = μ{f ≠ g}, a pseudometric. Let P be δ-isolated: K(g) > K(P) for every total computable g ≠ P with d(P, g) < δ. Use the patch-free prior, with weights 2^(−K(g)) on the δ-isolated g. After N ≥ (K(P)·ln 2 + ln(1/β))/δ independent μ-samples labelled by P, with probability at least 1 − β the posterior gives P mass above 1/2. Then the decoder equals P everywhere, and every run is the human's.

*Proof.* Proposition 8(2) and Theorem 9 of the ultranatural note use only that d is a pseudometric. Posterior mass off P is below 1/2 exactly when R < 2^(−K(P)). By Markov's inequality this fails with probability at most 2^(K(P))·(1−δ)^N ≤ β. ∎

* **If μ lives on probes only,** isolation requires that every function at most as complex as P that answers the probes as P does also *acts* as P does. P's task behaviour must be the Occam completion of its reports. Any simpler core with the same reports violates this, which rules out any interesting human.
* **If μ also covers common task states,** isolation asks that the rare decisive behaviours be *consequences* of mechanisms used throughout and of reported knowledge, not stored exceptions. Switching them off must then cost a guard (the ultranatural note's Proposition 8(4)).
  * A rarely used, unreported knowledge item is the opposite: deleting it makes P simpler.
  * So hidden-insight humans are isolated only at the scale of the insight states' measure.
  * Sampling the human's own run states costs up to n task queries each.
* **The patch-free learner fails outright** on a human that is not isolated.

**Does any version remove n without a check?**
* *Yes,* under (Loc_s), under (Cov_δ), under complete elicitation, or under isolation. Each supplies what the second note says the hard class lacks:
  * *where* the decisive knowledge acts (located or diagnostic probes);
  * or a guarantee that nothing rare is left (complete elicitation, isolation).
* *Without them,* n multiplies R_T. Theorem 4 says this cannot be avoided for residual insights at unpredictable steps.

## 5. Experiment E5

Code: [`threadB_kb_probes.py`](threadB_kb_probes.py). Outputs: [`threadB_results/`](threadB_results/). Running it takes about 100 s and reproduces the outputs.

**The class.**
* There are L = 100 topics and m = 200 problems. Problem p has the visible topic p mod L, so each technique is used by 2 problems.
* A topic has a technique with probability ½. The technique has a stage s_ℓ, uniform on {0, …, n−1}, and a fresh content.
* The human writes that content at stage s_ℓ and is silent otherwise, as in Theorem 3's class.

**The protocols.**
* One probe is asked per topic, before any task query: 100 probes. With probability φ, a technique is recalled. The probe types are presence, content, full (content and stage), a stage window of width w, and misreport (a stated stage that is wrong with probability ψ, which the prior knows).
* Posteriors are exact under the class prior.
* The protocols skip topics on which the posterior is certain, except in row 1, which is E1's CI.
* LOC asks inside the reported window. VER first verifies the stated stage.
* Failure means that the run differs from the human's. The stopping rule is an oracle at 2%, as in E1.
* There are 10 humans per n. All of them reached the target in every configuration.

Mean task queries:

| probes + protocol | n = 16 | n = 64 | n = 256 | n = 1024 | R_T after probes, bits (n = 16 / 1024) |
|---|---|---|---|---|---|
| none + CI, asking every round (E1) | 4,757 | 16,350 | 76,056 | 274,569 | 1,370 / 1,603 |
| none + CI | 2,998 | 11,082 | 49,475 | 184,626 | 1,370 / 1,603 |
| presence(1) + CI | 788 | 2,921 | 12,022 | 47,264 | 1,270 / 1,503 |
| content(1) + CI | 762 | 2,919 | 12,022 | 47,264 | 212 / 501 |
| full(1) | 0 | 0 | 0 | 0 | 0 / 0 |
| full(0.9) + CI | 574 | 3,007 | 7,734 | 31,979 ± 12,776 | 179 / 144 |
| full(0.5) + CI | 1,947 | 7,834 | 34,056 | 136,522 | 685 / 803 |
| window(1, w = 8) + CI | 749 | 2,805 | 11,302 | 45,996 | 159 / 150 |
| window(1, w = 8) + LOC | 383 | 350 | 371 | 392 | 159 / 150 |
| window(1, w = n/4) + LOC | 187 | 692 | 3,442 | 12,736 | 106 / 401 |
| misreport(1, ψ = 0.2) + CI | 762 | 2,859 | 10,857 | 46,118 | 73 / 135 |
| misreport(1, ψ = 0.2) + VER | 184 | 461 | 1,896 | 7,404 | 73 / 135 |
| none + MB, perfect check | 51 | 48 | 49 | 48 | 1,370 / 1,603 |
| full(0.5) + MB, perfect check | 24 | 22 | 23 | 22 | 685 / 803 |

* **Content does not help.** Eliciting every content removes about 1,100 bits, 69–85% of the residual. The cost is exactly that of presence probes, which remove about 100 bits. Both are about 0.9·n queries per technique, so the factor n is intact.
  * The factor 4 over plain CI comes from presence: no queries are wasted on topics with nothing to find. That is location information at the level of problems.
* **Incomplete recall.**
  * With recall 0.5, the cost is still 65–74% of CI's. The cost is set by the last few unfound items, a coupon-collector effect.
  * With recall 0.9 it varies a lot: 0 for humans with at most two unrecalled techniques, large otherwise.
* **Location must be reported and used.**
  * The window w = 8 with targeted queries gives about 380 at every n, about w per technique.
  * The same probes with untargeted CI cost as much as presence probes.
  * With w = n/4 the cost grows with n again.
* **Misreports.** With 20% misreported stages, verification costs about one query per technique. The misreported ones fall back to about 0.7·n each.
* **R_T bounds mistakes, not cost.** Rows with similar R_T differ by a factor of 100 in cost, depending on the location entropy and on whether the protocol uses it.
* **With a perfect check,** probes cut MB's task queries in proportion to recall. The checks per human fall from 578–810 to 364–451.

## 6. Real researchers: for and against

**For the conditions.**
* *Much of what a research run uses is pre-existing and reportable:* known results, techniques, literature and standard moves. Researchers write surveys and lecture notes, and they can say how they would attack a problem.
* *Long answers.* A probe answer can be long, so one probe can carry far more bits than a task step's decisive contribution.
* *Located probes.* Researchers can often name the crux in advance ("the hard part will be the error terms"). That is location information, which Theorem 5(b) turns into cost.
* *Insights derived during work* from known techniques by general reasoning cost an unbounded learner nothing once the techniques and the reasoning are learned (Theorem 3).
* *Verifying a report* that names a place is cheap (VER).

**Against the conditions.**
* **Tacit knowledge.** Experts "know more than they can tell" (Polanyi 1966).
  * The knowledge-acquisition bottleneck of 1980s expert systems was a large-scale test of the core + knowledge-base programme. As it is usually described, elicited rules were incomplete and did not reproduce the experts' behaviour, especially *when* a rule applies.
  * Experts sort problems by the principles that decide which method applies, novices by surface features (Chi, Feltovich and Glaser 1981).
  * In the terms here, K(B_op | B_rep) is large, and its content is location, the part that Theorem 4 and E5 show is costly.
* **Recall is triggered by context.** Knowledge that is used rarely is plausibly recalled mainly when its triggering situation arises, so φ is lowest for exactly the rare items. In E5 the cost is set by the last few of them.
* **Self-reports about one's own process are unreliable** (Nisbett and Wilson 1977). Concurrent verbalization is more faithful than retrospective explanation (Ericsson and Simon 1993). Plans and predicted cruxes are often wrong: ψ > 0, and misreported items fall back to the full cost.
* **Some insights are genuinely work-generated.**
  * Accounts of mathematical discovery describe ideas arriving at unpredictable times, not available on request (Hadamard 1945).
  * Where such ideas depend on rarely exercised, problem-specific skill, such as taste or what to try when stuck, they are part of the core, not of B. Theorem 4 then applies with φ ≈ 0.
* **A universal learner does not get the say–do link for free.** Under a universal prior, complete elicitation leaves at least K(c, e), and diagnostic probes need (Cov_δ), which a universal prior does not supply.
* **Probing changes the human.** Articulating knowledge changes how one works (the self-explanation effect). The probed human is then a different program, as with the scaffold instruction in without-a-check.md §5.

**What could be measured:**
* *Recall φ:* list techniques before working on a problem, and compare with what the work used.
* *Location accuracy, w and ψ:* predict the crux and when it will come, and compare.
* *The say–do link:* whether reported knowledge is used when it is relevant.

These are cheap studies, like the measurement of persistence proposed in without-a-check.md §7.

## 7. Limitations and open questions

**Limitations.**
* The human is deterministic, answers probes honestly and consistently, and is not changed by them.
* The link between reports and behaviour comes from the learner's prior. A universal prior pays K(c, e) plus the tacit part. E5's class prior trusts reports, with ψ known.
* Theorem 4 is a worst case over a constructed class.
* (Loc_s) and (Cov_δ) are joint conditions on the human and the learner.
* E5 is a stylized class:
  * silent humans;
  * oracle stopping;
  * 10 humans per n, with a large variance for full(0.9).
* Nothing here has been refereed.

**Open.**
1. A natural condition on the human alone that implies (Loc_s) or (Cov_δ) for the majority decoder of a universal mixture.
2. Probes combined with persistence: does a catch-up human's report shorten r?
3. Whether located probes plus audits give a bound between 2s·R_T and n·R_T when (Loc_s) holds only for a fraction of failures. Theorem 5(b) already gives the weighted form.
4. Empirical values of φ, ψ and w for real researchers.

**References.**
* Chi, Feltovich and Glaser (1981), *Categorization and representation of physics problems by experts and novices*, Cognitive Science.
* Ericsson and Simon (1993), *Protocol Analysis*, revised edition.
* Hadamard (1945), *The Psychology of Invention in the Mathematical Field*.
* Nisbett and Wilson (1977), *Telling more than we can know*, Psychological Review.
* Polanyi (1966), *The Tacit Dimension*.
