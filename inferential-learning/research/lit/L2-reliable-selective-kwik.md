# L2: Learning with worst-case reliability (abstaining learners, anytime-valid inference, verifier overoptimization)

Strand memo for the inferential-learning project. Read together with `../00-brief.md`.

**How the citations were checked.** Web *search* worked while this memo was prepared, but the network proxy blocked full-text fetching (arXiv, JMLR, Springer, PMLR, NeurIPS). So:
* Bibliographic data and abstract-level claims were checked against search results. They are marked ✓ in the reference list.
* Theorem-level details that I could not read in full text are marked **[unverified]** where they are used.
* The results in §3 are my own derivations, with proofs complete enough to check line by line. They are elementary and may exist in the literature in some form. Treat them as candidates for the project's theorem list, to be adversarially checked.

---

## 0. Bottom line

1. **Worst-case soundness against an adaptive prover is achievable, and it is the cheap part.** Take the *Bayesian-conservative checker*: accept step $x$ iff the posterior mass of the hypotheses that call $x$ invalid is $<\delta$.
   * If all evidence is truthful, the checker is **deterministically** sound against *every* prover, even one that knows the truth, whenever $\delta\le w^*$, the prior weight of the true validity relation (Thm 1). Ville is not needed in this case.
   * If evidence is noisy, Ville's inequality gives $\Pr[\text{ever accept an invalid step}]\le\delta'$ whenever $\delta\le \delta' w^*$. This holds uniformly over adaptive query sequences and stopping times (Thm 2).
   * In both cases a *single* good event covers every step of every proof. So there is no union bound over proof length or search effort, which is the Rivest–Sloan point that reliability composes.
2. **The price is paid in escalations to humans (KWIK "⊥"s), not in soundness.**
   * The Bayes rule escalates at most $\ln(1/w^*)/\ln\frac{1}{1-\delta}$ times. Truncated enumeration escalates at most $1/\delta-1$ times.
   * Any checker that is sound with probability $1-\delta'$ needs $(1-\delta')(1/w^*-1)$ escalations on an unstructured class, even an intersection-closed one (Thms 3–4).
   * With a description-length prior $w^*=2^{-K}$, the escalation count is $\tilde\Theta(2^K)$. A mistake-making learner needs only $\log_2(1/w^*)=K$ corrections. This exponential "reliability tax" is the Bayesian analogue of the KWIK vs. mistake-bound separation of Li et al.
3. **Structure is what makes escalation bounds small, and one-sidedness is what makes structure sufficient.**
   * A step checker never needs to certify *invalidity*. A step it is unsure of is simply unusable by the prover. The protocol is therefore one-sided (no false positives allowed).
   * In that protocol, the exact worst-case number of human interventions on steps the prover genuinely needs equals the length of the longest **elastic chain inside the target** (Thm 5). This is a bounded, quantitative version of Wright's finite elasticity.
   * For rule schemas learned by anti-unification (first-order patterns), the closure checker $x\in\mathrm{inst}(\mathrm{lgg}(S))$ is sound and needs at most $2|s|$ interventions, where $s$ is any seed example.
   * Conjunctive side conditions need at most $n+1$ interventions one-sided, versus exponentially many in two-sided KWIK.
   * Sound checkers combine by union, and the combined intervention bound is the *minimum* of the components' bounds.
4. **Corrections to the brief.**
   * (a) Gold's overgeneralization problem **does not threaten soundness** of conservative acceptance. Over-general, tonk-like hypotheses never block a step, and they never license one either. The truth, or any sound fragment of it, acts as a *guardian*. In the noise-free case coherence negatives are not needed for soundness. Their uses are to shrink the escalation budget, to enable certified *rejection*, and to serve as anytime-valid *alarms*.
   * (b) **Gold returns in the noisy case.** Suppose we use positive-only human corpora with a naive "consistency" likelihood. Then over-general hypotheses absorb human errors and can drive the posterior of the truth to 0, which breaks soundness (§3.3). The fixes are a correctly specified selection model (the size principle) or tolerant version spaces with an anytime-valid bound on the number of human errors.
   * (c) A coherence constraint taken from a context that is inconsistent under its own import regime is an *untruthful constraint*. It can eliminate the truth and silently destroy soundness. Context handling (H6) is therefore soundness-critical.
5. **Why learned verifiers with only average-case guarantees fail under search.** When search selects an accepted step, it is invalid with probability $\beta/(\alpha+\beta)$. Here $\alpha$ is the rate of valid-and-accepted proposals and $\beta$ the rate of invalid-and-accepted ones. For the hard steps that search exists to find, $\alpha\to 0$ (Prop 6). This is the mechanism behind several known results:
   * Cobbe et al.'s degradation beyond about 400 samples;
   * Gao–Schulman–Hilton's overoptimization curves;
   * Stroebl–Kapoor–Narayanan's ceiling on resampling with imperfect verifiers;
   * Skalse et al.'s result that non-trivial unhackable proxies do not exist over all stochastic policies.

---

## 1. Frame: our problem in the language of this strand

* **Steps.** $X$ is a countable set of context-indexed steps $x=(\Gamma;\ \varphi_1,\dots,\varphi_k\Rightarrow\psi)$. Contexts are part of the step.
* **Hypotheses.** A hypothesis is a validity relation $h:X\to\{0,1\}$. The class is $H$, the truth is $h^*$, the prior is $w$, and $w^*:=w(h^*)>0$. Write $I_x:=\{h:h(x)=0\}$ for the hypotheses calling $x$ invalid.
* **Evidence** comes in two kinds.
  * *Truthful constraints* $E\subseteq H$ with $h^*\in E$. Examples:
    * a human step known to be valid: $E=\{h: h(x)=1\}$;
    * a coherence bag, i.e. a derivation of $\bot$ in a context certified consistent: $E=\{h:\exists i\, h(x_i)=0\}$;
    * an escalation answered correctly.
  * *Stochastic observations* $e$ with likelihood kernels $P_h(e\mid\text{past},\text{design})$. Examples are noisy human labels and noisy world measurements.
* **Version space and posterior.** The version space is $V_t=\bigcap E_s$. The posterior is $\pi_t$, and $Z_t:=w(V_t)$ is the unnormalized prior mass of the version space.
* **Protocol.** A *prover* (adversary) chooses queries $x_t$ adaptively. The *checker* answers Accept, Reject, or ⊥ (escalate to a human, who returns a label).
  * **Two-sided** (KWIK-style): accepts and rejects must both be correct.
  * **One-sided** (what we need): accepts must be correct. Anything else counts as "abstain". An abstention on a *valid* step that the prover then escalates is a **costly abstention**.
* **Soundness**: never accept $x$ with $h^*(x)=0$.

Dictionary:

| our notion | strand notion |
|---|---|
| sound step checker | reliable / perfect selective / KWIK learner (one-sided) |
| prover queries | adversarial inputs (KWIK), injected examples (Goel et al.), test set $Q$ (PQ learning) |
| escalation to human | ⊥ with label feedback (KWIK), label query (CAL), mentor query (Cohen–Hutter) |
| human proof corpus | i.i.d. stream from $P$ (selective classification, PQ), demonstrator (imitation) |
| coherence bag | multiple-instance "at least one negative" constraint |
| prior budget $\delta$ | weighted union bound (Occam), Bayes threshold (Chow's reject rule with asymmetric costs) |

---

## 2. Literature

### 2.1 Reliable learning: Rivest–Sloan, Kivinen, Kalai–Kanade–Mansour

* **Rivest & Sloan (1988)** ✓ introduced *reliable and probably useful* (RPU) learning. The hypothesis may answer "I don't know" but must never be wrong. "Probably useful" means that with high probability the mass of "I don't know" is $\le\varepsilon$ under the example distribution. Their motivation was learning *complicated* concepts (Boolean circuits) with a helpful teacher who supplies intermediate concepts.
  * My reading of why this works [the composition argument is not quoted from the paper]: a reliable sub-learner's outputs can be fed to the next level without compounding error, and only "I don't know" propagates.
  * This is exactly the structure of derivations. Valid steps compose into valid arguments. ⊥ just makes a step unusable.
* **Kivinen (1995)** ✓, *Learning reliably and with one-sided error*. He reduces RPU learning to learning with one-sided error and proves strong *negative* results in the distribution-free model:
  * monotone conjunctions and disjunctions are not RPU-learnable from polynomially many examples;
  * axis-parallel rectangles in $\mathbb R^n$ ($n\ge2$) are not RPU-learnable from *any* finite number of examples.

  **Lesson for us.** Two-sided reliability plus distributional usefulness is very demanding. One-sided reliability (certify only validity) is a much weaker requirement, and §3.5 shows it is often cheap.
* **Kalai, Kanade & Mansour (2012)** ✓, *Reliable agnostic learning*, treat false positives and false negatives asymmetrically.
  * *Positive-reliable*: false-positive rate $\le\varepsilon$, and false-negative rate within $\varepsilon$ of the best classifier in the class with zero false positives.
  * *Fully reliable*: partial classifiers ("unknown" allowed) competing with the best zero-error partial classifier.
  * Their reductions to agnostic learning are [unverified in detail].

  Our checker is a positive-reliable learner with two changes: the false-positive guarantee must be worst-case (adversarial inputs) rather than distributional, and the class may be misspecified. Follow-ups: Kanade & Thaler (2014) ✓ (title), and **Kalai & Kanade (2021)** ✓ (title), which build PQ-learning on reliable learners [details unverified].

### 2.2 KWIK and the mistakes/abstentions trade-off

* **KWIK** (Li, Littman & Walsh 2008 ✓; Li, Littman, Walsh & Strehl 2011 ✓).
  * On each round an *adversary* chooses $x_t$. The learner outputs $\hat y_t\in Y\cup\{\perp\}$, and after ⊥ it observes a (possibly noisy) label.
  * Requirement: with probability $\ge 1-\delta$, every non-⊥ output is $\varepsilon$-accurate, and the number of ⊥s is at most $B(\varepsilon,\delta)$.
  * The quantifiers match H1 exactly: the guarantee holds over *all* rounds, for adversarially chosen inputs.
  * Standard facts [statement forms from memory of the paper; unverified in detail]:
    * enumeration over a finite deterministic class has KWIK bound $|H|-1$;
    * memorization over a finite input space has bound $|X|$;
    * learning a coin's bias takes $O(\varepsilon^{-2}\ln\frac1\delta)$;
    * KWIK-learnable implies mistake-bound (MB) learnable with mistakes $\le B$, by guessing at ⊥s;
    * combination theorems: input-partition, cross-product, and (noisy) union, the last being the "$k$-meteorologists" problem.
  * MB does not imply efficient KWIK. Conjunctions over $n$ variables are MB-learnable with $n+1$ mistakes but need exponentially many ⊥s ✓. The follow-up literature quotes $\Omega(2^{n/2})$ [exponent unverified]. Singletons and disjunctions likewise need exponentially many ✓.
  * The motivating application is KWIK + R-max ⇒ PAC-MDP: the ⊥ count bounds visits to "unknown" states. Our analogue is a prover that uses optimism-under-uncertainty and escalates unknown steps when they would help. Its human interventions are bounded by the checker's ⊥ bound.
* **Walsh & Littman (2008)** ✓ studied learning STRIPS *action schemas*, the closest analogue to inference-rule schemas: preconditions correspond to premises plus side conditions, effects to conclusions.
  * General STRIPS operators cannot be learned efficiently from raw experience.
  * Bounding the precondition size gives a positive result.
  * With a *teacher providing solution traces*, efficient learning becomes possible.
  * **Walsh, Subramanian, Littman & Diuk (2010)** ✓ generalize this into an *apprenticeship* protocol and relate it to KWIK and MB.

  This is direct precedent for the brief's "start from imitation of human proofs". Positive traces from a teacher move learning from the KWIK regime toward the MB regime.
* **Sayedi, Zadimoghaddam & Blum (2010)** ✓ allow $k$ mistakes and minimize ⊥s; for finite classes they give a general algorithm. **Demaine & Zadimoghaddam (2013)** [unverified] give near-optimal trade-offs for disjunctions. **Zhang & Chaudhuri (2016)** ✓ introduce the *Extended Littlestone's Dimension*, which captures the number of abstentions needed to guarantee at most $k$ mistakes, and is optimal in the realizable case. With $k=0$ this is the exact KWIK complexity; that specialization is my reading.
* **Agnostic KWIK** (Szita & Szepesvári 2011) ✓ allows approximation error (the target is not in $H$). Efficient model learners still give efficient RL, but "learning can be substantially slower". Their bounds are [unverified]. This matters because informal-math validity is not crisply in any class. §3.2 gives a *one-sided* agnostic substitute ("fragment soundness") that is much more forgiving.

### 2.3 Perfect selective classification, compression, and disagreement

* **El-Yaniv & Wiener (2010)** ✓. A selective classifier $(f,g)$ predicts $f(x)$ when $g(x)=1$. Its risk is measured on accepted points; its coverage is $\Pr[g=1]$.
  * The **consistent selective strategy (CSS)** takes $f$ to be any consistent hypothesis and $g(x)=1$ iff $x\notin \mathrm{DIS}(\mathrm{VS})$, i.e. iff all hypotheses in the version space agree on $x$.
  * In the realizable case CSS has zero risk deterministically.
  * CSS is optimal among strategies that are perfect for every consistent target. The argument is elementary: accepting any $x\in\mathrm{DIS}$ is wrong for some consistent target. The exact form of their optimality theorem is [unverified].
  * Coverage guarantees are *distributional*. For rich classes such as linear separators, coverage can vanish for adversarial distributions, while positive results hold for specific distributions [details unverified].
* **El-Yaniv & Wiener (2012)** ✓ show that stream-based active learning (CAL; Cohn, Atlas & Ladner 1994 [unverified]) reduces to perfect selective classification, because CAL queries exactly on $\mathrm{DIS}(V)$, which is where CSS abstains. They obtain exponential label-complexity speedups, for example for linear separators under Gaussian mixtures.
* **Wiener, Hanneke & El-Yaniv (2015)** ✓.
  * The *version-space compression set size* $\hat n(S_m)$ is the size of the smallest subset of the sample that induces the same version space.
  * With probability $\ge1-\delta$, $P(\mathrm{DIS}(V_m))\le \frac{c}{m}\big(\hat n\ln\frac{m}{\hat n}+\ln\frac1\delta\big)$. The constants are reported as about 10 and 4 [exact form unverified].
  * They tie this to **Hanneke's disagreement coefficient** $\theta(r_0)=\sup_{r>r_0}P(\mathrm{DIS}(B(h^*,r)))/r$ (Hanneke 2007 ✓; survey Hanneke 2014 ✓) and to CAL's label complexity.

**Mapping.** These results bound the *usefulness* side, meaning abstention mass under a fixed distribution such as human-like steps. They do not bound behaviour under search. CSS's soundness is deterministic, so adversarial queries cannot hurt soundness. They can only force abstentions, and an adversary can always query inside $\mathrm{DIS}(V)$. Hence the adversarial abstention count is a KWIK quantity, while the distributional coverage is an El-Yaniv–Wiener quantity. For our checker we want both:
* worst-case soundness;
* worst-case *costly*-abstention bounds (§3.5);
* distributional coverage on human-like steps, where compression-set arguments apply.

### 2.4 Arbitrary test-time adversaries with free abstention

This is the closest modern theory to "the prover is an adversary that chooses where to query."

* **Goldwasser, Kalai, Kalai & Montasser (2020)** ✓, PQ-learning. The learner gets labeled training data from $P$ and arbitrary unlabeled test points (any $Q$, possibly adversarial). Their transductive algorithm *Rejectron* outputs a selective classifier with low error on accepted test points and a low rejection rate with respect to $P$, for any class of bounded VC dimension. This gives the first nontrivial guarantees for arbitrary train/test pairs. The exact rates are [unverified].
* **Goel, Hanneke, Moran & Shetty (2023)** ✓. The stream is i.i.d. with injected clean-label adversarial examples. Abstaining is free on injected rounds and costly on i.i.d. rounds; mistakes count everywhere.
  * With known marginal, the error is $O(d^2\log T)$ for VC dimension $d$. The relevant complexity is therefore VC-type, not Littlestone-type.
  * Without the marginal they give algorithms for VC-1 classes and for axis-aligned rectangles.
* **Edelman & Goel (2026, arXiv 2602.20111)** ✓.
  * Distribution-agnostic learners need $\Omega(\sqrt T)$ even for VC-1, which is tight.
  * A potential-based framework gives combined error $O(T^{1-1/k})$ for classes of *inference dimension* $k$ (a notion due to Kane, Lovett, Moran & Zhang 2017 [unverified]).
  * They introduce a *certificate dimension*; halfspaces in $\mathbb R^2$ have certificate dimension 3 and error $O(T^{2/3})$.
* **Yu & Blanchard (COLT 2026)** ✓. *AbstainBoost* achieves sublinear error for general VC classes against oblivious adversaries in the distribution-free setting, with adaptive-adversary guarantees for structured classes such as linear classifiers.

**Mapping.** Human-like steps play the role of the i.i.d. rounds and the prover's exotic steps play the role of injections. Two protocol differences matter:
1. In these models a label is revealed every round [as I understand; unverified]. Our prover's queries are unlabeled unless escalated.
2. Our soundness requirement is "zero false accepts with high probability", not a bounded mistake count. A single false accept can be catastrophic (tonk).

The structural parameters these papers use (inference dimension, certificate dimension) are exactly the kind of quantity H1 asks for: how few confirmed instances *certify* the labels of new ones.

### 2.5 Closure algorithms, intersection-closed classes, safe action models

* **Helmbold, Sloan & Warmuth (1990)** ✓ introduced the **closure algorithm** for intersection-closed classes. Its hypothesis is the intersection of all concepts containing the positives. It makes no false positives in the realizable case, and its only mistakes are false negatives.
  * PAC analysis: **Auer & Ortner (2007)** ✓ give a PAC bound for the closure algorithm on intersection-closed classes without the $\log(1/\varepsilon)$ factor [exact form unverified].
  * Robustness to malicious noise: Auer & Cesa-Bianchi (1998) [unverified].
* **Safe action-model learning** (SAM: Stern & Juba 2017 ✓; Juba, Le & Stern 2021 ✓) learns STRIPS/PDDL action models from *positive* trajectories.
  * Preconditions are learned conservatively as the conjunction of everything true in all observed pre-states. That is the closure algorithm on conjunctions.
  * As a result, plans made with the learned model are *guaranteed* valid ("safe").
  * The guarantee is "probably approximately complete": with $m$ trajectories, linear in the size of the domain model, a fresh problem is unsolvable by the learned model with probability $\le\varepsilon$.

  This is the best existing template for our goal of sound inference-rule learning from positive human practice. Its soundness is worst-case; its completeness is PAC.
* **Plotkin (1970)** and **Reynolds (1970)** [unverified, classical]: least general generalization (lgg / anti-unification) and the lattice of first-order terms. §3.5 uses the fact that single-pattern instance sets form an intersection-closed class whose closure operator is $\mathrm{inst}\circ\mathrm{lgg}$.
* **Finite elasticity** (Wright 1989; Motoki, Shinohara & Wright 1991 [unverified, classical]): a class has infinite elasticity iff there are $x_0,x_1,\dots$ and $L_1,L_2,\dots$ in the class with $\{x_0,\dots,x_{n-1}\}\subseteq L_n\not\ni x_n$. Finite elasticity is sufficient for identification in the limit from text, and it is preserved under finite unions (hence it covers bounded unions of patterns and length-bounded elementary formal systems; Shinohara 1994 [unverified]). §3.5 shows that the *bounded, within-target* version of this condition is exactly the worst-case escalation complexity of one-sided checking.

### 2.6 Anytime-valid inference and Bayesian conservatism

* **Ville's inequality** (Ville 1939 [unverified, classical]). If $(M_t)$ is a nonnegative supermartingale with $M_0=1$, then $\Pr(\exists t:\ M_t\ge 1/c)\le c$. The bound holds at all stopping times, so it is immune to optional stopping and continuation.
* **Test martingales and Bayes factors** (Shafer, Shen, Vereshchagin & Vovk 2011 ✓). Nonnegative martingales with initial value 1 measure evidence against a hypothesis. A Bayes factor is such a martingale under the null, and its value at a stopping time can be read as a (conservative) Bayes factor.
* **Safe anytime-valid inference** (SAVI; Ramdas, Grünwald, Vovk & Shafer 2023 ✓) collects e-processes, confidence sequences, universal inference, and Ville's inequality into one framework.
* **Time-uniform concentration** (Howard, Ramdas, McAuliffe & Sekhon 2020 ✓, 2021 ✓) gives line-crossing and stitched boundaries, i.e. time-uniform Hoeffding, Bernstein, Freedman and LIL-rate confidence sequences.
* **Universal inference** (Wasserman, Ramdas & Balakrishnan 2020 ✓) gives split likelihood-ratio e-values valid without regularity conditions.
* **The prior–posterior-ratio (PPR) martingale** (Waudby-Smith & Ramdas 2020 ✓). The ratio of prior to posterior at the true parameter is a martingale, so $\{\theta:\pi_t(\theta)\ge c\,\pi_0(\theta)\}$ is a $(1-c)$ confidence sequence. *This is precisely the lemma behind Thm 2.*
* **Game-theoretic probability** (Shafer & Vovk 2001, 2019 [unverified, classical]). Ville-type bounds hold for Skeptic's capital in any perfect-information protocol, *without a probability model of the other player's moves*. That fits our setting: the prover's moves need no model, and only the label-generating process must be modelled.
* **E-values** (Vovk & Wang 2021; Grünwald, de Heide & Koolen 2024 [unverified]) can be multiplied along sequentially valid evidence and averaged across alternatives.
* **Bayesian conservatism with a mentor.**
  * **Cohen & Hutter (2020)** ✓ build a pessimistic Bayesian agent. It plans against the worst model in a top set of high-posterior-weight models and defers to a mentor when its pessimistic value is low. With probability $1-\delta$ it causes no "unprecedented events", and mentor queries become rarer over time.
  * **Cohen, Hutter & Nanda (2022)** ✓ give a *conservative Bayesian imitator*. It underestimates each action's probability by taking the minimum over the policies whose posterior weight is at least $\alpha$ times the total weight of policies at least as likely, and it queries the demonstrator with the leftover probability. Events unlikely under the demonstrator stay unlikely under the imitator, and queries "rapidly diminish".

  These are the closest existing "Bayesian KWIK" results. Our Thm 2 is the binary step-validity specialization of the same idea. Their key lemma is, I believe, a Ville-type lower bound on the posterior of the true model [lemma form unverified].
* **Bayes mixture regret.** $\ln P_{h^*}(D)-\ln\xi(D)\le\ln(1/w^*)$ pointwise, hence $\sum_t\mathbb E[\mathrm{KL}_t]\le\ln(1/w^*)$ (Solomonoff 1978; Hutter 2005 [unverified, classical]). This is the potential function for the noisy escalation bound in §3.4.

### 2.7 Conformal prediction: the right guarantee for the wrong quantifier

* Split or full conformal prediction (Vovk, Gammerman & Shafer 2005 [unverified, classical]) gives *marginal* coverage under exchangeability. In our terms: $\Pr_{x\sim P}[\text{accept invalid }x]\le\alpha$ for a fresh exchangeable $x$.
* A prover's query is *selected* by search, so exchangeability fails and the guarantee does not transfer.
* Adaptive conformal inference (Gibbs & Candès 2021 ✓) gives long-run miscoverage frequency $\approx\alpha$ on *arbitrary* sequences. But a frequency guarantee lets the adversary place the misses where they hurt, and one false accept of a tonk-like step suffices.
* Conformal/LTT-style calibration is therefore useful for the *coverage* side (abstention rate on human-like steps), not for soundness. Selection-aware variants exist (e.g., Jin & Candès 2023 [unverified]), but they control error *rates* over selected sets, not the existence of errors.

### 2.8 Overoptimization and Goodhart: what happens without worst-case guarantees

* **Cobbe et al. (2021)** ✓. At 6B scale, verifier-reranked accuracy rises with the number of sampled solutions up to about 400 and then falls: "the benefits of search are eventually outweighed by the risk of finding adversarial solutions that fool the verifier."
* **Gao, Schulman & Hilton (2023; arXiv 2022)** ✓. With $d:=\sqrt{\mathrm{KL}(\pi\|\pi_{\rm init})}$, the gold reward follows $R_{\rm bon}(d)=d(\alpha_{\rm bon}-\beta_{\rm bon}d)$ for best-of-$n$ and $R_{\rm RL}(d)=d(\alpha_{\rm RL}-\beta_{\rm RL}\log d)$ for RL. The coefficients vary smoothly, roughly logarithmically, with proxy reward-model size.
* **Stroebl, Kapoor & Narayanan (2024)** ✓. False positives of imperfect verifiers impose a ceiling on resampling-based inference scaling, even with infinite compute. The optimal number of samples can be below 10.
* **Huang, Block, Liu, Jiang, Krishnamurthy & Foster (2025)** ✓. Best-of-$N$ with an imperfect reward model provably reward-hacks for large $N$ and is suboptimal under realistic coverage conditions. Their fix is pessimism (χ²-regularized inference) [details unverified].

  This is the *average-case + bounded density ratio + pessimism* alternative to our *worst-case + abstention* route. It works when search stays close to the training distribution, which a deep prover does not.
* **Skalse, Howe, Krasheninnikov & Krueger (2022)** ✓. Over all stochastic policies, two reward functions are "unhackable" only if one of them is constant. Non-trivial unhackable pairs exist only for restricted policy sets.
* **Manheim & Garrabrant (2018)** [unverified] distinguish four kinds of Goodhart effect: regressional, extremal, causal and adversarial. Prover vs. $\hat V$ is *extremal* (search leaves the training distribution) plus *adversarial* (search optimizes against $\hat V$'s errors).
* Prover–verifier games (Kirchner et al. 2024 ✓, title) train verifiers against "sneaky" provers, an empirical robustification with no worst-case guarantee.
* Self-proving models and interactive proofs for ML (Amit, Goldwasser, Paradise & Rothblum 2024 [unverified]; Goldwasser, Rothblum, Shafer & Yehudayoff 2021 [unverified]) take the other route: keep the verifier sound by construction and learn only the prover.

---

## 3. Core results (worked out for our setting)

Notation as in §1. The checker $R_\delta$:
* **Accept** iff $\pi_t(I_x)<\delta$;
* **Reject** iff $\pi_t(I_x^c)<\delta$ (two-sided version only);
* **⊥** otherwise.

The one-sided version replaces Reject with "abstain".

### 3.1 The guardian lemma and deterministic soundness

**Lemma 0 (guardian).** For every $t$ and every $x$ with $h^*(x)=0$: $\pi_t(I_x)\ge\pi_t(h^*)$. Hence on any run where $\inf_t\pi_t(h^*)\ge\delta$, $R_\delta$ never accepts an invalid step. *Proof.* $h^*\in I_x$. ∎

**Theorem 1 (deterministic soundness under truthful evidence).** Suppose all evidence consists of truthful constraints from *any* source:
* human positives;
* coherence bags from contexts that are actually consistent;
* escalation answers;
* constraints generated by the prover itself.

Then $\pi_t(h^*)=w^*/Z_t\ge w^*$ for all $t$. So $R_\delta$ with $\delta\le w^*$ is sound against every prover strategy, including one that knows $h^*$, with probability 1.

*Proof.* Conditioning on $E\ni h^*$ multiplies $\pi(h^*)$ by $1/\pi(E)\ge1$. ∎

Remarks.
1. **The prior is a union-bound budget.** $R_\delta$ is simultaneously sound for every target in $H_\delta:=\{h:w(h)\ge\delta\}$, and $|H_\delta|\le 1/\delta$. Choosing a prior *is* choosing how to split an error budget across candidate meanings, as in Occam bounds.
2. **Over-general hypotheses are harmless.** Hypotheses that accept more than $h^*$ (tonk, naive comprehension) are never in $I_x$ for the invalid $x$ they wrongly license. They can neither block a step nor license it past the guardian. Gold's theorem (positive data never refutes over-general hypotheses) is about identification, not about sound acceptance.
3. **Generalization is licensed by the prior alone.** An unseen valid $x$ is accepted iff the posterior mass of *restrictive* deviants, i.e. data-consistent hypotheses that reject $x$, is below $\delta$. Kripkenstein's quus is such a deviant for "68+57=125". Coherence cannot remove it, since quus is coherent. Only the prior, or a point-wise escalation, can.

**Corollary 1′ (fragment soundness: one-sided agnostic version).** We do *not* need $h^*\in H$. Suppose some $g\in H$ satisfies all three of:
* (i) $g\le h^*$ pointwise, i.e. $g$ is a sound fragment;
* (ii) $g$ accepts every step ever confirmed valid by a truthful constraint;
* (iii) $w(g)\ge\delta$.

Then $R_\delta$ is sound. *Proof.* $g$ satisfies every truthful positive constraint by (ii). It satisfies every truthful "at least one invalid" constraint because $g\le h^*$. So $g\in V_t$, and $g\in I_x$ whenever $h^*(x)=0$. ∎

This is the right realizability notion for informal mathematics. We need not assume that "true informal validity" is a simple member of $H$, only that the *practice we have confirmed* sits inside a simple sound fragment.

### 3.2 Ville: soundness under stochastic evidence

**Assumptions.** Rounds are of two kinds.
* *Constraint rounds*: a truthful $E_t\ni h^*$, chosen arbitrarily, even adversarially.
* *Stochastic rounds*: a design $a_t$ is chosen arbitrarily as a function of the past and of external randomness (it may even depend on $h^*$). Then $e_t\sim P_{h^*}(\cdot\mid\mathcal F_{t-1},a_t)$. This is **fresh noise**: the chooser of $a_t$ cannot see $e_t$ in advance.

The model kernels $P_h$ for $h\neq h^*$ may be arbitrary, even misspecified. Only the one for $h^*$ must be correct. The posterior is updated by Bayes' rule, and all evidence is recorded: **no selective reporting.**

**Theorem 2 (anytime soundness).** For every $c\in(0,1]$, $\Pr\big(\exists t:\ \pi_t(h^*)\le c\,w^*\big)\le c$. Consequently, if $\delta\le\delta' w^*$, then
$$\Pr\big(R_\delta \text{ ever accepts an invalid step}\big)\le\delta',$$
uniformly over adaptive provers and arbitrary stopping.

*Proof.* Let $M_t:=w^*/\pi_t(h^*)$, so $M_0=1$.
* On a stochastic round, $M_t/M_{t-1}=\xi_t(e_t)/P_{h^*}(e_t)$, where $\xi_t=\sum_h\pi_{t-1}(h)P_h(\cdot\mid\mathcal F_{t-1},a_t)$. Then $\mathbb E[M_t/M_{t-1}\mid\mathcal F_{t-1},a_t]=\sum_{e:P_{h^*}(e)>0}\xi_t(e)\le1$.
* On a constraint round, $M_t/M_{t-1}=\pi_{t-1}(E_t)\le1$.

So $M$ is a nonnegative supermartingale. Ville's inequality gives $\Pr(\sup_t M_t\ge1/c)\le c$. On the complement, $\pi_t(h^*)>c\,w^*\ge\delta$ for all $t$, and Lemma 0 applies. ∎

This is the PPR martingale of Waudby-Smith & Ramdas, applied to the hypothesis "the validity relation is $h^*$". The mixture $\xi$ does the work of a union bound over all alternatives, at cost exactly $\ln(1/w^*)$.

**Lemma 2a (a conservative noise model is safe).** Let escalation labels be symmetric flips with true rate $\eta_t\le\eta_m\le\frac12$, possibly varying with $t$ and conditionally independent given the past. If the posterior is computed with $\eta_m$, then $M_t$ is still a supermartingale under the true law.

*Proof.* Let $p$ be the posterior mass agreeing with $h^*$ on $x_t$. Then $\mathbb E_{\rm true}[\xi(y)/P_{h^*,\eta_m}(y)]$ is linear in $p$:
* it equals 1 at $p=1$;
* at $p=0$ it equals $f(\eta_t)=\frac{\eta_m(1-\eta_t)}{1-\eta_m}+\frac{(1-\eta_m)\eta_t}{\eta_m}$, which is increasing in $\eta_t$ when $\eta_m<\frac12$ and equals 1 at $\eta_t=\eta_m$. ∎

So *over*-estimating human noise is safe for soundness. Under-estimating it is not.

**When the hypotheses of Thm 2 fail (important).**
1. *Selective reporting / data poisoning.* If the adversary can choose *which* realized noisy labels enter the record after seeing them, $M$ is no longer a supermartingale. Optional *stopping* is fine; optional *reporting* is not.
2. *Systematic human error.* The theorem needs fresh, conditionally independent noise. A community-wide misconception is not noise, and no amount of escalation can correct it. Only coherence feedback or world feedback can.
3. **Positive-only noisy corpora with a consistency likelihood (Gold strikes back).** Model a human-presented step $x$ with the pseudo-likelihood $L_h(x)=1-\eta$ if $h(x)=1$ and $\eta$ otherwise, ignoring that presented steps are *selected* to look valid.

   Take $H=\{h^*,h_{\top}\}$ with $h_\top$ accepting everything. Every invalid-but-presented step multiplies $\pi(h^*)/\pi(h_\top)$ by $\eta/(1-\eta)$, and *nothing* ever favours $h^*$. So $\pi(h^*)\to0$ almost surely, and $R_\delta$ eventually accepts invalid steps.

   In general, $\mathbb E[\xi/L_{h^*}]=\sum_h\pi(h)Z_h/Z_{h^*}$, where $Z_h$ is the acceptance mass of $h$ under the human's proposal distribution. This exceeds 1 when over-general hypotheses carry posterior mass.

   The correct generative likelihood divides by $Z_h$ (the **size principle**; cf. Tenenbaum & Griffiths 2001 [unverified]) and restores Thm 2. But it requires modelling the human proposal distribution, which is a new misspecification risk.

   *Escalation labels do not have this problem*: the design $x$ is chosen independently of its label. Hence: **treat labels on queries as clean evidence, and presented positives as dirty evidence.**

**Theorem 2′ (tolerant version space).** Let $D_n$ be the first $n$ presented positives. Let $(K_n)$ satisfy $\Pr(\exists n:\#\{\text{invalid in }D_n\}>K_n)\le\delta'$. For example, if each presented step is invalid with conditional probability $\le\eta$, a time-uniform binomial confidence sequence (Howard et al.) gives $K_n=\eta n+O(\sqrt{n(\log\log n+\log(1/\delta'))})$.

Let $V^{\rm tol}_n=\{h:\ h\text{ meets all truthful constraints and rejects}\le K_n\text{ items of }D_n\}$. Apply the threshold rule to the prior restricted to $V^{\rm tol}_n$ with $\delta\le w^*$. Then the rule is sound with probability $\ge1-\delta'$, with no model of the human proposal distribution.

*Proof.* On the good event $h^*\in V^{\rm tol}_n$ for all $n$, so Lemma 0 applies with $\pi(h^*)\ge w^*$. ∎

The cost is that more restrictive hypotheses survive, so there are more escalations. Coherence bags help here because they prune over-general survivors.

### 3.3 Composition, and coherence as an alarm

**Corollary 3 (composition).** On the good event of Thm 1 or Thm 2 (probability 1, or $\ge 1-\delta'$), *every* accepted step at every time is valid. So every argument assembled from accepted steps, in any number, found by any search, is valid in its context. There is no dependence on proof length $L$ or on the number of candidates explored. Compare a per-step false-accept rate $\varepsilon$, which yields failure probability up to $1-(1-\varepsilon)^{L}$ even before selection effects (Prop 6).

**Corollary 3′ (coherence violations are anytime-valid falsifiers).** Suppose a derivation of $\bot$ uses only accepted steps, in a context certified consistent under its import regime. That event implies a soundness failure. Under the assumptions of Thm 2 (prior budget, well-specification at the truth, fresh noise), it therefore has probability $\le\delta'$ over the whole run.

Observing one therefore rejects the checker's inductive assumptions at level $\delta'$, as a test valid at any stopping time. This gives the brief's "coherence loss" a principled role as **model criticism**: it is not what makes acceptance sound, but it *detects* when the assumptions behind soundness are wrong.

### 3.4 Escalation bounds (upper)

**Theorem 3.**
* **(a) Noise-free, two-sided** ($\delta\le w^*$; escalations answered truthfully): against any prover, $\#\perp\ \le\ \log_{1/(1-\delta)}(Z_0/w^*)\ \le\ \frac{1}{\delta}\ln\frac{Z_0}{w^*}.$ The same bound holds in the **one-sided** protocol for costly abstentions. Any other truthful evidence (human corpus, coherence) that shrinks $Z$ uses up the same budget: it "pre-pays" escalations.
* **(b) Truncated enumeration.** Run CSS on $V_t\cap H_\delta$. It is sound for all targets in $H_\delta$ and has $\#\perp\le|H_\delta|-1\le1/\delta-1$.
* **(c) Noisy labels.** Escalation answers are symmetric flips with known rate $\eta<\frac12$, and the other evidence is truthful constraints. Then with probability $\ge1-\gamma$, simultaneously for all $T$: $\#\perp(T)\ \le\ \frac{2\ln(1/\gamma)+\ln(1/w^*)}{\delta^2(1-2\eta)^2}.$ With $\delta=\delta'w^*$ for soundness, this is $O\!\big(\frac{\ln(1/w^*)+\ln(1/\gamma)}{\delta'^2w^{*2}(1-2\eta)^2}\big)$.

*Proofs.*
* (a) At an escalation both $w(V_t\cap I_x)$ and $w(V_t\setminus I_x)$ are $\ge\delta Z_t$. The answer removes one of them, so $Z_{t+1}\le(1-\delta)Z_t$, and $Z_t\ge w^*$ throughout. In the one-sided case the answer "valid" removes $V_t\cap I_x$, whose mass is $\ge\delta Z_t$.
* (b) Every ⊥ means $V_t\cap H_\delta$ disagrees on $x$, so the answer removes at least one member.
* (c) Let $\mathrm{BC}_t=\sum_y\sqrt{P_{h^*}(y)\xi_t(y)}$ and $H^2_t=1-\mathrm{BC}_t$. The process $S_T=\prod_{t\le T}\sqrt{\xi_t(y_t)/P_{h^*}(y_t)}/\mathrm{BC}_t$ is a nonnegative martingale with mean 1, so Ville gives, with probability $\ge 1-\gamma$ for all $T$:
  $$\exp\!\big(-\tfrac12 L^{\rm stoch}_T\big)\le\gamma^{-1}\prod_t\mathrm{BC}_t\le\gamma^{-1}e^{-\sum_t H_t^2}.$$
  Since $\pi_T(h^*)=w^*e^{L_T}\le1$ and constraint rounds only add to $L_T$, we have $L^{\rm stoch}_T\le L_T\le\ln(1/w^*)$, where $L$ is the log-likelihood ratio of $h^*$ against the mixture. Hence $\sum_tH^2_t\le\ln\frac1\gamma+\frac12\ln\frac1{w^*}$.

  At an escalation the predictive probability of the true label differs from the truth by $\mathrm{TV}=(1-2\eta)\cdot(\text{mass on the wrong side})\ge(1-2\eta)\delta$. Also $H^2\ge\mathrm{TV}^2/2$. ∎

  The expectation version replaces $H^2$ by KL: $\mathbb E[\#\perp]\le\ln(1/w^*)/\kappa(\delta,\eta)$, with $\kappa\ge2\delta^2(1-2\eta)^2$ by Pinsker.

Bound (c) is probably loose by a factor of about $1/\delta$. In the chain example below, each escalation moves the minority's log-odds by $\ln\frac{1-\eta}{\eta}$, which suggests $\tilde O(\frac1{w^*}\log\frac1{\delta'})$. Closing this gap is an open problem worth a lemma.

**Proposition 3d (Bayesian RPU on the human distribution).** Suppose every costly abstention is followed by adding the step as a truthful positive. Then the total number of costly abstentions on *any* stream of valid steps is at most the bound in (a). For an i.i.d. stream of $m$ human steps, the expected abstention rate at a uniformly random stopping index is $\le\ln(Z_0/w^*)/(\delta m)$. This is a distribution-free "probably useful" guarantee with sample size $O(\ln(1/w^*)/(w^*\varepsilon))$. Compare Kivinen's negative results, which concern the *two-sided* version.

### 3.5 Escalation bounds (lower), and the role of structure

**Theorem 4 (lower bound; reliability tax).**
* Let $X=\{x_1,\dots,x_N\}$ and $H=\{h_0,\dots,h_N\}$ with $h_k(x_i)=1\iff i\le k$ (a chain). Give it the uniform prior, so $w^*=1/(N+1)$.
* Let the prover be *oblivious* and query $x_1,\dots,x_N$ in order, with truthful escalation answers.
* Then any (randomized) checker that, for every target in $H$, accepts an invalid step with probability $\le\delta'$, has under target $h_N$ an expected number of costly abstentions $\ge(1-\delta')N=(1-\delta')(1/w^*-1)$.
* In the two-sided protocol with rejection error $\le\delta''$, the bound is $\ge(1-\delta'-\delta'')N$.
* With $N=2^K-1$ and description-length prior $2^{-K}$, this is exponential in $K$.
* Weighted halving, by contrast, makes $\le\log_2(1/w^*)$ mistakes on every sequence.

*Proof.* Before round $k$, the transcript has the same law under $h_N$ and under $h_{k-1}$, because all earlier answers are "valid" under both. Under $h_{k-1}$, $x_k$ is invalid, so $\Pr_{h_N}[\text{accept }x_k]=\Pr_{h_{k-1}}[\text{accept }x_k]\le\delta'$. ∎

Together with Thm 3(a) and 3(b), the worst-case escalation complexity of prior-only (unstructured) reliability is $\Theta(1/w^*)$, up to the $\ln(1/w^*)$ factor that the Bayes rule pays relative to truncation. The orchestrator's conjectured "exponential lower bound for unstructured classes" is confirmed. Note that the chain class is intersection-closed, so the lower bound applies to one-sided checking as well.

**Theorem 5 (one-sided escalation complexity = elastic-chain length).**

*Definition.* Let $C\subseteq2^X$ be the class of validity sets, $S_0$ the truthful seed positives (the human corpus), and $c\in C$ the target with $c\supseteq S_0$. An **$S_0$-elastic chain in $c$** is a sequence $x_1,\dots,x_n\in c$ such that for each $i$ some $L_i\in C$ satisfies $L_i\supseteq S_0\cup\{x_1,\dots,x_{i-1}\}$ and $x_i\notin L_i$. Let $\mathcal E(c,S_0)$ be the supremum of the lengths $n$.

Claims:
* **(a) Upper bound.** The closure checker accepts iff $x\in\mathrm{cl}(S):=\bigcap\{L\in C:L\supseteq S\}$, where $S$ is all confirmed positives. It is sound for every target in $C$. Against every prover, its costly abstentions are $\le\mathcal E(c,S_0)$.
* **(b) Lower bound.** For each $n\le\mathcal E(c,S_0)$, an oblivious prover forces $\ge(1-\delta')n$ expected costly abstentions on any checker that is sound with probability $\ge1-\delta'$ for all targets in $C$ containing $S_0$.
* **(c) Single first-order patterns.** Let $C=\{\mathrm{inst}(p)\}\cup\{\emptyset\}$ over ground terms. This class is intersection-closed: $\mathrm{inst}(s)\cap\mathrm{inst}(t)=\mathrm{inst}(s\theta)$ for $\theta=\mathrm{mgu}$, after renaming apart. Its closure is $\mathrm{cl}(S)=\mathrm{inst}(\mathrm{lgg}(S))$ by Plotkin. Then $\mathcal E(\mathrm{inst}(p),S_0)\le 2|s|$ for every $s\in S_0$, where $|s|$ counts symbol occurrences. With $S_0=\emptyset$, $\mathcal E=\infty$: the prover's first escalated step can be arbitrarily large. So we need either seed data or size-bounded queries.
* **(d) Conjunctive side conditions.** For conjunctions of literals over $n$ Boolean features (as in SAM-style precondition learning), $\mathcal E\le n+1$. Contrast this with the exponential two-sided KWIK bound. The exponential cost comes entirely from certifying *negatives*, which a step checker never has to do.
* **(e) Combination.** Accept iff any of several checkers, each sound for the truth, accepts. The combination is sound, and its costly abstentions are $\le$ the minimum of the components' bounds, provided each component updates on all confirmed positives. In particular, the closure checker combined with $R_\delta$ has costly abstentions $\le\min\big(2|s|,\ \log_{1/(1-\delta)}(Z_0/w^*)\big)$. The first term is independent of how complex the target is; the second is independent of how large the queries are.

*Proof sketch.*
* (a) Soundness: $x\in\mathrm{cl}(S)$ and $c\supseteq S$ with $c\in C$ give $x\in c$. Every costly abstention $x$ lies in $c\setminus\mathrm{cl}(S)$, so some $L\in C$ contains $S$, and hence all earlier escalated points, but not $x$. The escalated points therefore form an elastic chain.
* (b) Same indistinguishability argument as Thm 4: before round $i$, the target $L_i$ is consistent with the transcript.
* (c) Let $\varphi(t)=2\,\#\text{fn-occ}(t)+\#\text{var-occ}(t)-\#\text{distinct-vars}(t)\ \ (\ge0)$. Every strict instantiation factors into renamings plus elementary steps of two kinds, each of which raises $\varphi$:
  * binding a variable occurring $m$ times to $f(\vec y)$ with $k$ fresh variables changes $\varphi$ by $m+1+k(m-1)\ge2$;
  * identifying two distinct variables changes $\varphi$ by $+1$.

  Along an elastic chain, $\mathrm{lgg}$ strictly generalizes at each step, because $x_i\notin\mathrm{cl}\supseteq$ the previous closure. So $n\le\varphi(\mathrm{lgg}(S_0))\le\varphi(s)=2|s|$.
* (d) The closure of the positives is the conjunction of the literals satisfied by all of them. Each strict growth removes at least one literal.
* (e) Every costly abstention of the combination is a costly abstention of each component, and each component counts it in its own potential. ∎

Remarks.
* $\mathcal E$ is a bounded, within-target version of Wright's elasticity. Finite elasticity means every *run* has finitely many costly abstentions; a uniform bound needs $\mathcal E<\infty$.
* For *unions* of $k$ patterns (realistic calculi) the class is not intersection-closed, but $\mathrm{cl}$ is still well defined. Generalization is then forced by pigeonhole once $|S|>k$.
* I conjecture $\mathcal E\le\mathrm{poly}(s)^{O(k)}$ for $k$-unions with examples of size $\le s$. This may follow from ordinal mind-change bounds for unions of pattern languages (Ambainis, Jain & Sharma 1999 [unverified]): each costly abstention of the closure checker is a mind change of the conservative learner.
* Associative–commutative anti-unification (multiset contexts $\Gamma$), and side conditions such as eigenvariable restrictions, need richer classes such as elementary formal systems. These are open.

### 3.6 Why average-case verifiers fail under search

**Proposition 6 (base-rate amplification).**
* At a step, let the prover propose $x\sim Q$ and keep the first proposal $\hat V$ accepts. Let $\alpha=Q(\text{valid}\wedge\text{acc})$ and $\beta=Q(\text{invalid}\wedge\text{acc})$. The kept step is invalid with probability $\beta/(\alpha+\beta)$.
* If $\hat V$'s false-accept mass under the training distribution $P$ is $\varepsilon$, then $\beta\le\varepsilon\,\|dQ/dP\|_\infty$. Best-of-$n$ from $P$ has density ratio $\le n$. A constructive search that leaves $\mathrm{supp}(P)$ has density ratio $\infty$.
* An $L$-step search-found proof is valid with probability about $\prod_i\alpha_i/(\alpha_i+\beta_i)$.
* For exactly the steps that need search ($\alpha_i$ small), average-case accuracy $\varepsilon\gg\alpha_i$ makes the output almost surely wrong.

This is the formal content of Cobbe et al.'s 400-sample peak, Gao et al.'s curves, and Stroebl et al.'s ceiling. It also explains why Huang et al.'s pessimism needs coverage (a bounded density ratio), which deep proof search does not provide.

---

## 4. Implications for the brief's hypotheses

* **H1 (worst-case soundness needed).** *Confirmed and sharpened* (Prop 6, Cor 3). Refinements:
  1. In the noise-free case, soundness is *deterministic* given a prior budget $\delta\le w^*$. Ville is needed only for stochastic evidence.
  2. Ville's guarantee needs three things: well-specification *at the truth* (with over-estimated noise allowed, Lemma 2a), fresh noise, and no selective reporting.
  3. CSS and RPU give *distributional* usefulness. Only KWIK-type accounting bounds abstentions under adversarial queries, and it is exponential without structure (Thm 4). So H1's frameworks must be paired with structural results (Thm 5; inference dimension; compression).
  4. In formal math, soundness is free, since the proof kernel is a guardian (Cor 1′ with $g$ = the kernel). The learning problem there is entirely completeness and usefulness.
* **H2 (Gold; coherence as negative data).** *Needs correction.*
  * Positive data suffices for *soundness* of conservative acceptance (Remark 2 after Thm 1).
  * Gold's problem reappears in two places: usefulness (restrictive deviants force escalations), and the noisy case (§3.2, item 3), where over-general hypotheses absorb errors.
  * Coherence bags are free truthful constraints. They never lower $\pi(h^*)$. They:
    * shrink $Z$ and so pre-pay escalations;
    * enable certified rejection;
    * counter the over-generalization pull of noisy positives;
    * act as level-$\delta'$ alarms (Cor 3′).

    They do *not* make acceptance sounder in the noise-free case. In fact, removing over-general mass makes the conservative rule *more* cautious.
* **H5/H7 (informal math; rule-following).** Cor 1′ replaces "true informal validity is in $H$" with "confirmed practice lies in a simple sound fragment". This strand assigns a precise division of labour among the three answers to the rule-following problem:
  * The **prior** decides which unseen steps are accepted without asking. It does this through the mass of restrictive deviants such as quus and grue.
  * **Coherence** removes over-general deviants (tonk, naive comprehension). That matters for refutation, generation, and noise, not for sound acceptance.
  * **Community practice**, i.e. escalation, resolves deviants point by point. The number of times it must be consulted is bounded by Thm 3 and Thm 5.

  Systematic community error is invisible to escalation and can be caught only by coherence or world feedback.
* **H6 (contexts).** *Soundness-critical.* A coherence bag is a *truthful* constraint only if the context, *together with its permeation/import regime*, is consistent. Suppose a constraint from "air pressure = 0 plus all background facts" were applied. It is untruthful, because ⊥ is derivable by valid steps. It could eliminate $h^*$ and silently void Thms 1–2.

  There are two correct designs:
  1. Make import steps part of the learned validity relation (chunk-and-permeate). The bag "some step, possibly an import, is invalid" is then truthful.
  2. Apply coherence evidence only to contexts *certified* consistent, for example by exhibiting a model or a simulation.

  **Export rules and world feedback.** The hypothesis concerns the *validity of the export step*, a binary fact: does $|Q_{\rm world}-q|\le\varepsilon$ hold in contexts of this type? The likelihood is a *measurement* model of the instrument, which can be well specified even when the physics model is idealized. So Thm 2 applies to export rules trained on noisy measurements.

---

## 5. Theorem candidates for the project

1. **(T-Guardian) Deterministic and anytime soundness of conservative acceptance.** Thm 1, Cor 1′, Thm 2, Lemma 2a, and Thm 2′, stated for context-indexed steps with truthful coherence bags. *Status:* proofs above; they need an adversarial check of the filtration and measurability details (countable $H$, randomized provers).
2. **(T-Escalation) Tight escalation complexity.** The upper bounds of Thm 3(a–c) and the lower bound of Thm 4. *Open:* close the $\ln(1/w^*)$ gap for the Bayes rule. Is there a soft-Bayes rule matching $1/w^*$? Also close the $1/\delta$ gap in the noisy case; conjecture $\tilde\Theta\big(\frac1{w^*}\cdot\frac{\log(1/\delta')}{(1-2\eta)^2}\big)$.
3. **(T-Elastic) One-sided checking complexity equals elastic-chain length.** Thm 5, with patterns at $\le2|s|$ and conjunctions at $\le n+1$. *Conjecture:* $k$-unions of size-$s$ patterns satisfy $\mathcal E\le (2s+1)^{O(k)}$, perhaps via ordinal mind-change complexity. This would give "provably works for formal-calculus learning from human proofs, with polynomially many human interventions for fixed $k$". It is the strongest candidate for the user's success criterion 1.
4. **(T-Hybrid) Worst-case soundness plus distributional coverage.** For the closure checker on an intersection-closed class with VC dimension $d$, the abstention mass on human-distributed valid steps is $O((d+\log\frac1\gamma)/m)$, via Auer–Ortner [form unverified] or El-Yaniv–Wiener compression. Combined with Thm 5, this is a SAM-style "sound and probably approximately complete" theorem for inference rules.
5. **(T-Noise-Gold) An impossibility/necessity pair for noisy positive-only data.** (i) Any learner that uses only consistency pseudo-likelihoods on noisy presented positives is unsound for some two-hypothesis class (§3.2, item 3). (ii) Soundness is restored by the size-principle likelihood under correct specification of the human proposal distribution, or by tolerant version spaces with anytime error bounds. A further result would be that coherence bags make the tolerant version space shrink at a quantifiable rate.
6. **(T-Alarm) Coherence violations among accepted steps as an anytime-valid test of the checker's inductive assumptions** (Cor 3′). Also an e-process that accumulates evidence from *near*-violations, which would turn the coherence loss into a calibrated diagnostic.
7. **(T-Search) Base-rate amplification** (Prop 6), together with a matching statement: no checker with only distributional guarantees at density ratio $\rho$ can have per-proof soundness better than $1-\min(1,\rho\varepsilon/\alpha)$. This is the formal case for H1.
8. **(T-Export) Export-rule soundness.** Thm 2 applied to export steps whose evidence is instrument measurements with known error models. This is the first principled component of a physics-solution checker: in-context chunks are checked by T-Guardian, exports by T-Export.

---

## 6. Open problems and risks flagged by this strand

* **Computation.** $\pi_t(I_x)$ is a semantic specification, not an algorithm. Monte Carlo posterior samples give per-query failure about $e^{-cM\delta}$ with $M$ samples. A union bound over $T$ queries is fine if the sampler's randomness is hidden from the prover, but exact posterior sampling is itself intractable. Structural checkers such as the lgg closure are efficient. A practical system should accept iff *some* efficient sound checker accepts (Thm 5(e)) and use the Bayes rule only as a specification and for analysis. An ensemble of neural verifiers gives no guarantee unless it contains a sound member, in which case unanimity inherits soundness.
* **What $w^*$ means for real calculi.** With $K$ in the thousands of bits, the prior-only bounds are vacuous. Only structural bounds (Thm 5) are meaningful at scale.
* **Misspecification beyond the truth.** For informal mathematics the "fragment" assumption of Cor 1′ is the crux. How large and how simple is the sound fragment that covers a corpus of human proofs? This is empirical. The toy experiments should measure it.
* **Correlated human error** is the main gap between the theory and practice. It cannot be fixed by more human labels.

---

## References (✓ = bibliographic data or abstract-level claims checked by web search during this memo; [unverified] = from memory, not re-checked)

* Amit, N., Goldwasser, S., Paradise, O., Rothblum, G. (2024). *Models that prove their own correctness.* arXiv:2405.15722. [unverified]
* Ambainis, A., Jain, S., Sharma, A. (1999). *Ordinal mind change complexity of language identification.* TCS 220. [unverified]
* Auer, P., Ortner, R. (2007). *A new PAC bound for intersection-closed concept classes.* Machine Learning 66 (COLT 2004 version). ✓ (title, venue)
* Cobbe, K., et al. (2021). *Training verifiers to solve math word problems.* arXiv:2110.14168. ✓ (400-sample observation)
* Cohen, M. K., Hutter, M. (2020). *Pessimism about unknown unknowns inspires conservatism.* COLT, PMLR 125:1344–1373. ✓
* Cohen, M. K., Hutter, M., Nanda, N. (2022). *Fully general online imitation learning.* JMLR 23. ✓
* Cohn, D., Atlas, L., Ladner, R. (1994). *Improving generalization with active learning.* Machine Learning 15(2). [unverified]
* Demaine, E., Zadimoghaddam, M. (2013). *Learning disjunctions: near-optimal trade-off between mistakes and "I don't knows".* SODA. [unverified]
* Edelman, E., Goel, S. (2026). *Reliable abstention under adversarial injections: tight lower bounds and new upper bounds.* arXiv:2602.20111. ✓
* El-Yaniv, R., Wiener, Y. (2010). *On the foundations of noise-free selective classification.* JMLR 11:1605–1641. ✓
* El-Yaniv, R., Wiener, Y. (2012). *Active learning via perfect selective classification.* JMLR 13:255–279. ✓
* Gao, L., Schulman, J., Hilton, J. (2023). *Scaling laws for reward model overoptimization.* ICML, PMLR 202 (arXiv:2210.10760). ✓ (functional forms)
* Gibbs, I., Candès, E. (2021). *Adaptive conformal inference under distribution shift.* NeurIPS. ✓
* Goel, S., Hanneke, S., Moran, S., Shetty, A. (2023). *Adversarial resilience in sequential prediction via abstention.* NeurIPS (arXiv:2306.13119). ✓ ($O(d^2\log T)$ with known marginal)
* Goldwasser, S., Kalai, A. T., Kalai, Y. T., Montasser, O. (2020). *Beyond perturbations: learning guarantees with arbitrary adversarial test examples.* NeurIPS (arXiv:2007.05145). ✓
* Goldwasser, S., Rothblum, G., Shafer, J., Yehudayoff, A. (2021). *Interactive proofs for verifying machine learning.* ITCS. [unverified]
* Grünwald, P., de Heide, R., Koolen, W. (2024). *Safe testing.* JRSS-B. [unverified]
* Hanneke, S. (2007). *A bound on the label complexity of agnostic active learning.* ICML, 353–360. ✓
* Hanneke, S. (2014). *Theory of disagreement-based active learning.* Foundations and Trends in ML 7(2–3):131–309. ✓
* Helmbold, D., Sloan, R., Warmuth, M. (1990). *Learning nested differences of intersection-closed concept classes.* Machine Learning 5(2):165–196. ✓
* Howard, S., Ramdas, A., McAuliffe, J., Sekhon, J. (2020). *Time-uniform Chernoff bounds via nonnegative supermartingales.* Probability Surveys 17:257–317. ✓
* Howard, S., Ramdas, A., McAuliffe, J., Sekhon, J. (2021). *Time-uniform, nonparametric, nonasymptotic confidence sequences.* Annals of Statistics 49(2). ✓
* Huang, A., Block, A., Liu, Q., Jiang, N., Krishnamurthy, A., Foster, D. J. (2025). *Is best-of-N the best of them? Coverage, scaling, and optimality in inference-time alignment.* ICML (arXiv:2503.21878). ✓
* Hutter, M. (2005). *Universal Artificial Intelligence.* Springer. [unverified]
* Juba, B., Le, H. S., Stern, R. (2021). *Safe learning of lifted action models.* KR. ✓
* Kalai, A. T., Kanade, V. (2021). *Efficient learning with arbitrary covariate shift.* ALT, PMLR 132. ✓ (title, venue)
* Kalai, A. T., Kanade, V., Mansour, Y. (2012). *Reliable agnostic learning.* JCSS 78(5):1481–1495. ✓
* Kane, D., Lovett, S., Moran, S., Zhang, J. (2017). *Active classification with comparison queries.* FOCS. [unverified]
* Kanade, V., Thaler, J. (2014). *Distribution-independent reliable learning.* COLT. ✓ (title, venue)
* Kirchner, J. H., et al. (2024). *Prover-verifier games improve legibility of LLM outputs.* arXiv:2407.13692. ✓ (title)
* Kivinen, J. (1995). *Learning reliably and with one-sided error.* Mathematical Systems Theory 28:141–172. ✓ (negative results)
* Li, L., Littman, M., Walsh, T. (2008). *Knows what it knows: a framework for self-aware learning.* ICML. ✓
* Li, L., Littman, M., Walsh, T., Strehl, A. (2011). *Knows what it knows: a framework for self-aware learning.* Machine Learning 82:399–443. ✓ (framework; conjunction separation as quoted in follow-ups)
* Littlestone, N. (1988). *Learning quickly when irrelevant attributes abound.* Machine Learning 2. [unverified]
* Littlestone, N., Warmuth, M. (1994). *The weighted majority algorithm.* Information and Computation 108. [unverified]
* Manheim, D., Garrabrant, S. (2018). *Categorizing variants of Goodhart's law.* arXiv:1803.04585. [unverified]
* Motoki, T., Shinohara, T., Wright, K. (1991). *The correct definition of finite elasticity: corrigendum to Identification of unions.* COLT. [unverified]
* Plotkin, G. (1970). *A note on inductive generalization.* Machine Intelligence 5. [unverified]
* Ramdas, A., Grünwald, P., Vovk, V., Shafer, G. (2023). *Game-theoretic statistics and safe anytime-valid inference.* Statistical Science 38(4):576–601. ✓
* Reynolds, J. (1970). *Transformational systems and the algebraic structure of atomic formulas.* Machine Intelligence 5. [unverified]
* Rivest, R., Sloan, R. (1988). *Learning complicated concepts reliably and usefully.* Proc. AAAI-88, 635–639. ✓
* Sayedi, A., Zadimoghaddam, M., Blum, A. (2010). *Trading off mistakes and don't-know predictions.* NIPS 23. ✓
* Shafer, G., Shen, A., Vereshchagin, N., Vovk, V. (2011). *Test martingales, Bayes factors and p-values.* Statistical Science 26(1):84–101. ✓
* Shafer, G., Vovk, V. (2001; 2019). *Probability and Finance: It's Only a Game!*; *Game-Theoretic Foundations for Probability and Finance.* Wiley. [unverified]
* Shinohara, T. (1994). *Rich classes inferable from positive data: length-bounded elementary formal systems.* Information and Computation 108. [unverified]
* Skalse, J., Howe, N., Krasheninnikov, D., Krueger, D. (2022). *Defining and characterizing reward hacking.* NeurIPS. ✓
* Solomonoff, R. (1978). *Complexity-based induction systems: comparisons and convergence theorems.* IEEE Trans. IT 24(4). [unverified]
* Stern, R., Juba, B. (2017). *Efficient, safe, and probably approximately complete learning of action models.* IJCAI, 4405–4411. ✓
* Stroebl, B., Kapoor, S., Narayanan, A. (2024). *Inference scaling fLaws: the limits of LLM resampling with imperfect verifiers.* arXiv:2411.17501. ✓
* Szita, I., Szepesvári, Cs. (2011). *Agnostic KWIK learning and efficient approximate reinforcement learning.* COLT, JMLR W&CP 19:739–772. ✓
* Tenenbaum, J., Griffiths, T. (2001). *Generalization, similarity, and Bayesian inference.* BBS 24. [unverified]
* Ville, J. (1939). *Étude critique de la notion de collectif.* Gauthier-Villars. [unverified]
* Vovk, V., Gammerman, A., Shafer, G. (2005). *Algorithmic Learning in a Random World.* Springer. [unverified]
* Vovk, V., Wang, R. (2021). *E-values: calibration, combination and applications.* Annals of Statistics 49(3). [unverified]
* Walsh, T., Littman, M. (2008). *Efficient learning of action schemas and web-service descriptions.* AAAI, 714–719. ✓
* Walsh, T., Subramanian, K., Littman, M., Diuk, C. (2010). *Generalizing apprenticeship learning across hypothesis classes.* ICML, 1119–1126. ✓
* Wasserman, L., Ramdas, A., Balakrishnan, S. (2020). *Universal inference.* PNAS 117(29):16880–16890. ✓
* Waudby-Smith, I., Ramdas, A. (2020). *Confidence sequences for sampling without replacement.* NeurIPS (PPR martingale). ✓
* Wiener, Y., Hanneke, S., El-Yaniv, R. (2015). *A compression technique for analyzing disagreement-based active learning.* JMLR 16:713–745. ✓ (bound constants as reported secondhand)
* Wright, K. (1989). *Identification of unions of languages drawn from an identifiable class.* COLT. [unverified]
* Yu, J., Blanchard, M. (2026). *Distribution-free sequential prediction with abstentions.* COLT, PMLR 336. ✓
* Zhang, C., Chaudhuri, K. (2016). *The extended Littlestone's dimension for learning with mistakes and abstentions.* COLT, PMLR 49:1584–1616. ✓
