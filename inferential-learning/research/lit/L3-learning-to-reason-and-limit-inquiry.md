# L3 — Learning to reason, logical uncertainty, and the learning theory of inquiry

*Strand L3 of the inferential-learning project. Read `00-brief.md` first. Related memos: L5 §7 (incompleteness, limit learning), T2 §3.5 (arithmetic), L1 (Gold/Angluin), L2 (reliable/KWIK/Ville), L4 (Kelly–Ockham Π₁ policy), L10 (user's notes).*

**Status tags.**
* ✓ = bibliographic data, and where stated abstract-level content, checked by web search this session. Full texts were *not* reachable: arxiv.org, intelligence.org, ijcai.org, hutter1.net and eccc are blocked by the egress policy.
* [mem] = from memory, not re-checked.
* [unverified] = I could not check the exact form of this statement.
* [proved here] = a complete proof appears in this memo.
* [std] = textbook.

**Scripts.**
* `lit/L3-scripts/axiom_induction_coherence.py` checks Prop C.
* `lit/L3-scripts/sigma2_weak_coherence.py` sanity-checks the construction in Thm D′(c) *(added after verification)*.

**Revision note.** This memo was revised after adversarial verification. Items whose statement changed materially are marked "(revised after verification)". The full record is in the `## Verification log` at the end and in `../verification/L3-verification.md`.

---

## 0. Bottom line

1. **Three literatures.** Each formalizes a different part of "learning to reason":
   * **PAC-semantics** (Khardon–Roth, Valiant, Juba, Michael). Validity is "true in most *worlds* drawn from D", and learned rules are chained with additive error.
   * **Logical uncertainty** (Gaifman; Demski; Hutter–Lloyd–Ng–Uther; Garrabrant et al.). Credences on sentences, coherent in the limit, learned from a trusted deductive process.
   * **Formal learning theory of inquiry** (Putnam, Gold, Shoenfield, Kelly, Osherson–Stob–Weinstein, Magari's dialectical systems). Exactly which hypotheses can be decided, verified or refuted in the limit, and with how many mind changes.
   
   Our setup sits where the three meet. No one of them answers the user's question alone.
2. **Commitment-order lemma (Lemma A)** *(revised after verification: this was an "iff"; only the two directions below are proved)*. PAC-semantics' chaining lemma survives an adversarial prover *if* the randomness is drawn *after* the rules are fixed and independently of the prover. It fails in the regime where the world is fixed and the prover chooses the instances.
   * It holds for random *situations*: physics problems, and therefore export/bridge rules.
   * It fails for one fixed world with prover-chosen *instances* of a schema, which is mathematics.
   * A third regime is also sound in a fixed world: fresh randomness drawn per check, after the claim is committed (Lemma A(iii)). No general characterization ("exactly when") is proved.
   * So H1 is right for math, while PAC-semantics is the right semantics for H6's export rules. That only holds if test situations follow the training distribution, and olympiad problems are chosen to break exactly that.
3. **Key question, arithmetic, unbounded compute** (Thm G, §5.2).
   * Δ₀ world feedback is computable, so it adds nothing. Coherence detection is Σ₁ search.
   * **Achievable:**
     * correct in the limit on every Boolean combination of Σ₁ sentences, with ≤ k mind changes for k Σ₁ components;
     * stable acceptance of *exactly* the true Σ₂ sentences;
     * credences converging to 1 on exactly the true Π₃ sentences. The construction is incoherent, and it cannot converge on every false sentence (Thm G(f), Thm D′(d)).
     * *weakly coherent* credences converging to 1 on exactly the true Σ₂ sentences. These necessarily oscillate on some false ones (Thm D′(c),(d), *added after verification*).
   * **Impossible:**
     * deciding Σ₂ or Π₂ truth in the limit;
     * stably accepting exactly the true Π₂ sentences;
     * **weakly coherent** computable credences that converge to 1 on true Π₁ sentences, unless some true Π₂ sentence gets **liminf credence 0** (limit 0 if limits exist). This is Thm D, a self-contained form of Sawin–Demski 2013.
   * **What coherence costs** *(revised after verification)*. Among the columns of Thm G, weak coherence removes exactly the Π₂ and Π₃ columns of gradual verification. It leaves the Σ₁, Π₁, B(Σ₁) and Σ₂ columns.
     * Convergent credences, coherent or not, never get beyond Π₂.
     * Among convergent credences, incoherent ones reach Π₂ and weakly coherent ones do not (Thm D′).
     * The earlier slogan "coherence lowers the ceiling from Π₃ to Δ₂" was wrong and is retracted.
4. **Rates.**
   * There is never a computable modulus of convergence on an undecidable class (Lemma K).
   * Meaningful rates are:
     * mind changes;
     * latency after a witness or proof appears;
     * cumulative-loss bounds of Solomonoff type, ≤ ln(1/w);
     * proof-length speed-up. Strengthening the trusted base by sound principles gives *non-recursive* speed-ups (Gödel 1936).
5. **The user's coherence loss is risk-free arbitrage** (Prop E, de Finetti). Coherentizing credences by Euclidean projection *strictly improves Brier accuracy in every world that satisfies the constraints* (Lemma E′).
   * This holds **only if the constraints are sound.** If the actual world violates them, projection strictly worsens some credences, e.g. the actual world's own indicator vector (Lemma E′, converse added after verification).
   * The dominance property belongs to the projection. An arbitrary correction that removes the arbitrage can be less accurate, even in a world that satisfies the constraints.
   * That is the formal reason coherence must be applied to asserted claims in the actual context (H6, orchestrator §1).
   * It must never be computed from learned, untrusted rules.
6. **Rule-trader market** (§4.5) *(revised after verification)*. Learned rules belong among the *traders* of a logical-inductor-like market, never in its *deductive process*.
   * An LI already respects, asymptotically, every efficiently computable sequence of Γ-provable rule instances (Cor F).
   * Take an e.c. family of instances with Γ-provable premises and Γ-refutable conclusions. On such a family, the market's *prices* contradict the rule: $P_n(\gamma_n)-P_n(\varphi_n)\to1$.
   * Whether the rule's *trader* actually goes bankrupt depends on convergence rates. That is conjecture (L3-T6(b)), not a result.
   * The market cannot penalize failures that its deductive process never settles. Examples are conclusions whose falsity the trusted base $B$ does not refute, such as ¬Con(PA) when $B$ = PA. Σ₁- or Π₂-unsoundness alone does not make a failure invisible, since many false Σ₁ or Π₂ sentences are refutable in $B$.
   * With log-utility traders the market is a Bayesian mixture in which wealth = posterior weight, so T1/L2's conservative acceptance is the natural certifying layer on top.
7. **Logical induction is not a truth-tracker on Π₁.** Non-dogmatism forces $P_\infty(\mathrm{Con(PA)})<1$ and $P_\infty(\neg\mathrm{Con(PA)})>0$ for every LI over PA [proved here from the cited theorem]. This sharpens L5 §7.4's "[unverified; check]".
8. **The user's "Solomonoff axiom induction".**
   * Its true/false/independent read-out is a Dempster–Shafer belief/plausibility pair.
   * "Renormalize" and "split independents 50/50" are incoherent (checked by script).
   * The coherent fix is a random completion per hypothesis (Prop C). This is a μ-mixture of Demski-type (2012) priors, one per hypothesis. It need not equal Demski's prior conditioned on the data *(revised after verification)*.
9. **Magari's dialectical systems** are the closest existing formal model of "contradiction-driven versus counterexample-driven revision in mathematics". Andrews–San Mauro (2025) prove strict separations: both > counterexample > contradiction. Read the definitions before relying on them (§5.3).
10. **Ockham efficiency** (Kelly 2007; Genin–Kelly 2019) gives a non-MDL justification for L1's least-general (conservative) rule learners: they are retraction-optimal. This is a candidate transfer, not checked (§5.4).

---

## 1. Frame and dictionary

**Protocol.**
* Language $L$; for formal math, first-order arithmetic.
* Trusted base $B$ (e.g. Q or PA; possibly empty).
* A stream of human derivations (positive data).
* Learner hypotheses $R_t$, which are rule sets or schemas. The acceptance set is $A_t$, i.e. what $R_t$ derives within a budget.
* Feedback:
  * **(a) coherence:** detection of ⊥ ∈ Cn$_{R_t}(K)$ for a designated coherent context $K$. Detection is a Σ₁ event (search).
  * **(b) world:** truth values of Δ₀ sentences (math) or of measured observables (physics).

| Our notion | Khardon–Roth / Valiant / Juba | Logical induction | Kelly / Gold |
|---|---|---|---|
| the world | target $f$, or distribution $D$ over scenes | the theory Γ, its completions | data stream ε in Baire space |
| human proof step | entailment example; partial assignment | (best modelled as a *trader*) | text element |
| coherence | implicit (KB consistent) | no arbitrage over worlds consistent with $D_n$ | refutation of a hypothesis |
| world truth value | example $x\sim D$ (possibly masked) | a Δ₀ theorem entering $D_n$ | a datum |
| learned rule | learned clause/rule (explicit or implicit) | a trader | a hypothesis |
| "derives correct conclusions" | answers a query class correctly / $(1-\varepsilon)$-validity | provability induction, calibration | convergence to the truth |

---

## 2. Learning to reason and PAC-semantics

### 2.1 Khardon & Roth

**Khardon & Roth, "Learning to reason", *JACM* 44(5):697–725 (1997)** ✓.
* **Framework** [abstract, mem]:
  * The agent gets a learning interface to the world $W$ (a Boolean function $f$, with example or query oracles) and a "grace period" in which to build a knowledge base.
  * Afterwards it is scored only on answering queries α from a query language: does $W\models\alpha$?
* **Results** [mem]:
  * L2R algorithms for classes of propositional theories with *no efficient reasoning algorithm from a formula-based KB*.
  * An L2R algorithm for a class not known to be learnable in the traditional sense.
  * So learning-*for*-reasoning can be tractable when learning-then-reasoning is not.
* The key tool is **model-based reasoning**:
  * keep a set of models (characteristic models, Kautz–Kearns–Selman);
  * answer "yes" iff α holds in all of them.
* **Error structure of model-based reasoning** [std consequence]:
  * it is *complete*: if $f\models\alpha$, it says yes;
  * its errors are *false acceptances* of α whose counter-models have small mass.
* **Khardon & Roth, "Learning to reason with a restricted view", *MLJ* 35:95–116 (1999)** ✓. The interface supplies partial assignments. There is a "tradeoff between learnability, the strength of the oracles used in the interface, and the range of reasoning queries the learner is guaranteed to answer correctly" (abstract).

**Mapping.** Model-based reasoning is the user's "verification from truth" ("check whether each claim is true in the context at hand"):
* in math, sampled models are random numerical instantiations or finite substructures;
* in physics, they are simulations.

Its error direction (false acceptance of claims with rare counter-models) is exactly what H1's adversarial prover hunts for.

### 2.2 Valiant: robust logics and knowledge infusion

* **Valiant, "Robust logics"**, STOC 1999 ✓ and *AIJ* (2000) ✓ (volume 117 and pages [mem]).
* **Valiant, "Knowledge infusion"**, AAAI 2006 ✓; FSTTCS 2008 ✓.
* **Michael & Valiant, "A first experimental demonstration of massive knowledge infusion"**, KR 2008 ✓.

**Semantics.** A rule ρ is **$(1-\varepsilon)$-valid** for a distribution $D$ over *scenes* if $\Pr_{x\sim D}[x\models\rho]\ge1-\varepsilon$. Rules are learned to be PAC-valid "relative to any particular programs it may have for recognizing base predicates" ✓ (abstract), and then chained.

**Chaining lemma** [std]. If $\rho_1,\dots,\rho_k$ are $(1-\varepsilon_i)$-valid and $\rho_1\wedge\dots\wedge\rho_k\models\varphi$, then φ is $(1-\sum\varepsilon_i)$-valid. *Proof:* union bound.

Michael–Valiant (2008) report that chaining rules learned from about half a million sentences of text was "efficacious for reasoning" ✓ (abstract).

**Related work on partial observations.** Michael formalized learning from partial observations ("autodidactic learning"; *AIJ* 2010, "Partial observability and learnability") [mem; details unverified].

### 2.3 Juba: implicit learning

**Juba, "Implicit learning of common sense for reasoning"**, IJCAI 2013, pp. 939–946 ✓; preliminary version arXiv:1209.0056 ✓.

**Setting.**
* Examples are *partial* assignments $\rho\sim M(D)$ produced by a masking process.
* A formula is *witnessed* true (false) on ρ if it evaluates to true (false) using only the revealed literals ✓.

**Main result (shape; exact parameters unverified).** Given a KB, a query φ and $m=O(\gamma^{-2}\log\delta^{-1})$ partial examples, a polynomial-time algorithm does the following with probability $1-\delta$:
* it **rejects** if φ is not $(1-\varepsilon-\gamma)$-valid;
* it **accepts** if some ψ, witnessed true with probability $\ge1-\varepsilon+\gamma$, satisfies KB ∧ ψ ⊢ φ in the proof system.
* This holds for "essentially all natural tractable proof systems" (bounded-width and treelike resolution, …) ✓.
* ψ is never output: learning is **implicit**, which sidesteps the intractability of explicit learning.

**Extensions.**
* Juba, "Restricted distribution automatizability in PAC-semantics", ITCS 2015 ✓.
* Belle & Juba, "Implicitly learning to reason in first-order logic", NeurIPS 2019 ✓.

**Practice warning.** Zhang et al., "On the paradox of learning to reason from data", IJCAI 2023 ✓ (authors [mem]): a transformer trained on a logic distribution learns statistical shortcuts rather than the rules. This is the same phenomenon as L8 §8.

### 2.4 What carries over: the commitment-order lemma

**Lemma A** [proved here; folklore] *(hypotheses made explicit after verification)*. Fix a scene distribution $D$.

*Conventions.*
* Rules are stated at **sequent level**. An instance of a rule has premise sequents and a conclusion sequent.
* A sequent Γ ⊢ φ is *true in* $x$ iff every assignment to its free variables that makes all of Γ true in $x$ also makes φ true in $x$.
* An instance *holds in* $x$ iff the conclusion sequent is true in $x$ whenever all premise sequents are.
* A rule or schema is *valid in* $x$ iff all its instances hold in $x$.

This covers rules that discharge assumptions (→I, reductio) and eigenvariable rules (∀I). These rules are not of the form "premises true ⇒ conclusion true" at formula level.

* **(i) Random world, rules fixed first.** Let $R=\{\rho_1..\rho_m\}$ be a finite set of rules or schemas fixed before $x\sim D$. Assume each ρᵢ is $(1-\varepsilon_i)$-valid **per scene**: $\Pr_x[\rho_i\text{ is valid in }x]\ge1-\varepsilon_i$. Then
  $$\Pr_x\big[\exists \text{ an } R\text{-derivation (chosen after seeing } x), \text{ from premises true in } x, \text{ with a conclusion false in } x\big]\le\textstyle\sum_i\varepsilon_i .$$
  *Note.* Many PAC guarantees are stated per random (scene, instance) pair: $\Pr_{(x,\iota)}[\iota\text{ holds in }x]\ge1-\varepsilon$. Such a guarantee does **not** give the per-scene hypothesis. A prover who picks the instance inside the scene is then in regime (ii).
* **(ii) Fixed world, prover-chosen instances.** Let "validity" of a schema mean the fraction of its instances that are true under an instance distribution. Then no bound of type (i) holds against a prover who picks instances. Every schema with a false instance can be broken with probability 1 by a prover who can find that instance. This happens automatically when ε > 0, and it can also happen with ε = 0 when the false instance lies off the support of the instance distribution.
* **(iii) Fresh randomness per check.** Each claim is a polynomial identity $p\equiv q$ in $n$ variables over a field $F$. The **verifier enforces** a total-degree bound $\deg(p-q)\le d$, e.g. by computing the degree from an explicit expression. A compact notation such as repeated squaring can hide degree $2^k$ and defeat the bound.
  * After the claim is committed, the verifier evaluates at a uniform point of $S^n$, $S\subseteq F$ finite, drawn independently of the prover.
  * If $p-q$ is a **nonzero polynomial over $F$**, the claim passes with probability ≤ $d/|S|$ (Schwartz–Zippel). This holds uniformly over adaptive provers.
  * Over $N$ claims, with $N$ fixed in advance, the bound is $Nd/|S|$. For an unbounded sequence of claims, use sets $S_k$ with $\sum_kd/|S_k|\le\delta$, e.g. $|S_k|\ge d\,2^k/\delta$.
  * *The field matters.* $(a+b)^p-a^p-b^p$ is a nonzero integer polynomial for prime $p$, but it vanishes identically over $\mathbb F_p$. So random evaluation mod $p$ always accepts the freshman's dream. Evaluate over ℚ with $S\subseteq\mathbb Z$, or modulo a prime that does not divide all coefficients of $p-q$, e.g. one drawn at random from a large range after commitment.

*Proof.*
* (i) The event "every ρᵢ is valid in $x$" has probability ≥ $1-\sum\varepsilon_i$, by a union bound over the whole fixed library, not just the rules a derivation uses. On this event, induction on derivations shows that every sequent derived from premises true in $x$ is true in $x$.
* (ii) Take the adversary that outputs a false instance.
* (iii) Schwartz–Zippel for each claim, conditional on everything committed before its evaluation point is drawn, then a union bound. ∎

**Upshot.**
* In **physics**, the uncertainty that matters for an export rule is over situations. Lemma A(i) makes PAC-semantics a *worst-case-over-derivations* semantics for bridges, with error = the sum of the validity defects of the rules in the fixed library.
* The caveat is **distribution shift**. Olympiad problems are selected to stress idealizations, so $D_{\rm test}\neq D_{\rm train}$ exactly where it matters.
* In **mathematics** there is one world. $(1-\varepsilon)$-validity of a sentence is 0/1, and Juba's implicit learning collapses to "proof from KB plus revealed facts".
* In math, the randomness that Lemma A shows to help is fresh per-check randomness, as in (iii). Randomness drawn before the prover searches does not help (ii).
  * This is why random evaluation is a sound world oracle for the algebra workhorse (orchestrator §3), provided it meets (iii)'s conditions: a degree bound, the right field, and evaluation points drawn after commitment.
  * A learned verifier trained on samples is not such an oracle: its "randomness" was drawn before the prover searched.

---

## 3. Probabilities on sentences

### 3.1 Gaifman, and Gaifman measures on arithmetic

**Gaifman, "Concerning measures in first order calculi", *Israel J. Math.* 2:1–18 (1964)** ✓.
* Defines *coherent* probabilities on sentences.
* States the **Gaifman condition**: $P(\exists x\,\varphi(x))=\sup_n P(\varphi(t_1)\vee\dots\vee\varphi(t_n))$, with $t_i$ ranging over closed terms.
* Shows that coherent assignments on quantifier-free sentences extend to Gaifman measures ✓ (summary-level).

**Prop B** [proved here]. Let $P$ be a finitely additive probability on arithmetic sentences, coherent with respect to Q ($P(\varphi)=1$ whenever $Q\vdash\varphi$), and satisfying the Gaifman condition with numerals as the closed terms. Then $P(\varphi)=1$ iff $\mathbb N\models\varphi$.

*Proof.* Induction on prenex complexity, with numerals substituted.
* Δ₀ sentences are decided by Q.
* Case ∃xφ(x), true: some φ(k̄) is true, so $P(\varphi(\bar k))=1$ by the induction hypothesis, hence $P(\exists x\varphi)=1$.
* Case ∃xφ(x), false: every $P(\varphi(\bar i))=0$, so $P(\bigvee_{i\le n}\varphi(\bar i))\le\sum_{i\le n}0=0$ for every $n$, hence $P(\exists x\varphi)=0$.
* ∀ follows via negation. ∎

**Consequence.** The full Gaifman condition plus coherence over arithmetic *is* the truth predicate. By Tarski it is not arithmetically definable, let alone limit-computable. Every computable approach must therefore weaken Gaifman, which is what Sawin–Demski and LI do.

### 3.2 Hutter–Lloyd–Ng–Uther and Demski

**Hutter, Lloyd, Ng & Uther, "Probabilities on sentences in an expressive logic", *J. Applied Logic* (2013)** ✓.
* Setting: higher-order logic.
* They want priors that are **Gaifman** and **(strongly) Cournot**, i.e. that give nonzero probability to every sentence that has a model ✓.
* They construct such priors via probabilities on interpretations, and show that Gaifman + Cournot priors permit learning universal hypotheses in the limit ✓ (summary-level).
* Computability of the construction: [unverified]. By Prop B, it cannot be computable in the arithmetic case.

**Demski, "Logical prior probability", AGI 2012, LNCS 7716:50–59** ✓. A computably approximable prior on first-order theories [mem for the construction]:
* sample random sentences;
* keep each one consistent with those kept so far, with consistency checked in the limit.

The result is a measure on completions that is positive on every consistent sentence and is not Gaifman ✓ (summary-level).

### 3.3 The user's "Solomonoff axiom induction", made coherent

The user's note (`ai/learning/solomonoff induction/solomonoff axiom induction.md`) weights axiom systems $A$ (consistent with the data) by complexity $\mu(A)$. It reads off p(true), p(false), p(independent) and asks whether renormalizing, or splitting the independent mass 50/50, gives coherent probabilities. His guess is "probably not".

**Prop C** [proved here; examples machine-checked] *(hypotheses made explicit after verification)*.

*Standing hypotheses.*
* μ is a **probability** (normalized, $\sum_A\mu(A)=1$) on a countable set of hypotheses $A$.
* Each $A$ is **consistent** and **includes the data**, or, equivalently for what follows, $A$ is replaced by $A\cup\text{data}$.

These hypotheses matter:
* A Solomonoff-style semimeasure (total mass < 1) gives $\mathrm{Bel}(\top)<1$.
* An inconsistent $A$ gives the empty focal set and $\mathrm{Bel}(\bot)>0$, i.e. an unnormalized belief function.
* In arithmetic, consistency of $A$ is Π₁, so a computable scheme cannot enforce it exactly. It can only discard $A$ once an inconsistency is found.

* **(i)** $\mathrm{Bel}(\varphi):=\mu\{A:A\vdash\varphi\}$ and $\mathrm{Pl}(\varphi):=1-\mu\{A:A\vdash\neg\varphi\}$ are a **Dempster–Shafer belief/plausibility pair** on the Lindenbaum algebra. The mass function is μ pushed forward to the focal sets $\mathrm{Mod}(A)$.
* **(ii)** Neither read-out is coherent in general.
  * **Renormalizing**, $P=p_T/(p_T+p_F)$, fails with $A_1=\{p,\neg q\}$ and $A_2=\{q\}$ at weight ½ each. It gives $P(p)=1$, $P(q)=\tfrac12$, $P(p\wedge q)=0$, violating $P(p\wedge q)\ge P(p)+P(q)-1$.
  * **Half-splitting**, $P=p_T+p_I/2$, fails already for the single hypothesis $A=\varnothing$. It gives $P(p)=P(p\wedge q)=P(p\wedge\neg q)=\tfrac12$.
* **(iii)** $P:=\sum_A\mu(A)\,\lambda_A$ is coherent and satisfies Bel ≤ P ≤ Pl, for any probability measures $\lambda_A$ on the completions of $A$ (with the data). Canonical choices for $\lambda_A$:
  * a Demski prior over $A$;
  * the limit of a logical inductor over $A$.

  This is the coherent version of his scheme. It is a μ-mixture of Demski-type priors, one per hypothesis. *(Revised after verification: this replaces "essentially Demski 2012 conditioned on the data". The mixture need not equal Demski's prior conditioned on the data, nor the Demski process started from the data.)*

*Proof.*
* (i) is the standard random-set representation. It needs μ normalized and every focal set $\mathrm{Mod}(A)$ nonempty, i.e. $A$ consistent.
* (ii) is direct computation, confirmed by `L3-scripts/axiom_induction_coherence.py` (re-run after verification, same output).
* (iii) Each $\lambda_A$ gives 1 to everything $A$ proves and 0 to everything $A$ refutes. Mixtures of coherent measures are coherent, and the mixture has total mass 1 because μ is normalized. ∎

The same picture answers his `logic/logical induction.md` question ("why probabilities on propositions rather than joint distributions?"). A *coherent* $P$ on the whole sentence algebra *is* a joint distribution, namely a measure on the Stone space of completions, and $P(A\leftrightarrow B)$ distinguishes his two cases. Only incoherent finite-time approximations lack a joint distribution.

### 3.4 The Π₁/Π₂ trilemma

**Sawin & Demski, "Computable probability distributions which converge on believing true Π₁ sentences will disbelieve true Π₂ sentences"**, MIRI technical report (result from a July 2013 workshop; released 2014) ✓ (abstract):
* Π₁-convergence plus weak coherence ("if φ ⇒ ¬ψ then lim sup P(t,φ)+P(t,ψ) ≤ 1") implies arbitrarily low limiting probabilities for some short true Π₂ sentences.
* The quantifier structure of their Theorem 1 is [unverified].

Here is a self-contained version.

**Convention** *(added after verification)*. Quantifier blocks may be empty, so syntactically $\Sigma_n\cup\Pi_n\subseteq\Sigma_{n+1}\cap\Pi_{n+1}$; for example, a Π₁ sentence counts as both Π₂ and Σ₂. Readers who prefer strict prenex syntax can replace a Π₁ sentence ∀y θ by the equivalent ∀y∃z θ (z vacuous) wherever a Π₂ sentence is needed. Nothing below changes.

**Theorem D** [proved here] *(hypothesis weakened after verification, so the theorem is stronger)*. Let $P_t(\varphi)\in\mathbb Q\cap[0,1]$ be computable uniformly in $t,\varphi$. Suppose:
* **(Π₁-convergence)** $\lim_tP_t(\pi)=1$ for every true Π₁ sentence π;
* **(weak coherence, Π₁ premises)** $\limsup_t\,(P_t(\pi)+P_t(\varphi))\le1$ whenever π is **Π₁** and $\mathrm{PA}\vdash\pi\to\neg\varphi$.

  The first version required this for all sentences π. The proof uses only Π₁ π.

Then infinitely many true Π₂ sentences φ have $\liminf_tP_t(\varphi)=0$. If limits exist, then $P_\infty(\varphi)=0$ for these sentences.

*Proof.*
1. Let φ = ∀x∃y R(x,y) be a **false** Π₂ sentence. Then some $x_0$ makes π := ∀y ¬R(x̄₀,y) a true Π₁ sentence with PA ⊢ π → ¬φ. Π₁-convergence and weak coherence give $\limsup P_t(\varphi)\le 1-\lim P_t(\pi)=0$.
2. Let $S=\{\varphi\in\Pi_2:\liminf_tP_t(\varphi)>0\}=\{\varphi:\exists q\in\mathbb Q^+\,\exists s\,\forall t\ge s\;P_t(\varphi)\ge q\}$. This set is Σ₂.
3. By step 1, $S$ contains no false Π₂ sentence.
4. If $S$ contained every true Π₂ sentence, then $\mathrm{Th}_{\Pi_2}(\mathbb N)=S$ would be Σ₂. But $\mathrm{Th}_{\Pi_2}(\mathbb N)$ is Π₂-complete, so it is not Σ₂ (Post) [std]. Contradiction.
5. "Infinitely many": a finite modification of $S$ is still Σ₂. ∎

**Remark (the proof gives more).** Steps 1–5 use only two facts: every false member of the class has a true Π₁ refuter, and the class's truths are not Σ₂. So under the same hypotheses: for every decidable class $C\subseteq\Pi_2$ whose truths $\mathrm{Th}\cap C$ are not Σ₂, infinitely many true φ ∈ C have $\liminf_tP_t(\varphi)=0$. Every false Π₂ sentence ∀x∃y R has such a refuter, namely ∀y ¬R(x̄₀,y) for a suitable $x_0$.

**Reading: you can have at most three of the following.**
* computable (limit-computable) credences;
* (weak) coherence;
* Π₁-truth-convergence (a Π₁-Gaifman condition);
* non-dogmatism on true Π₂ sentences, i.e. liminf > 0 on each of them.

Logical induction keeps the first two and non-dogmatism, and drops Π₁-convergence (§4.3).

The Popperian learner of T2 Thm 3.10(c) outputs verdicts only on Σ₁ ∪ Π₁ sentences, and it is Π₁-convergent. So **any weakly coherent credence extension of it to all sentences** is dogmatic (liminf 0) on infinitely many true Π₂ sentences. *(Reworded after verification: T2's learner itself assigns nothing to Π₂ sentences.)* One example of such an extension: the learner's 0/1 verdicts on Σ₁ ∪ Π₁, and 0 elsewhere. Its limits on Σ₁ ∪ Π₁ are truth values and PA is sound, so it is weakly coherent.

**Theorem D′ (what weak coherence costs in row (f) of Thm G)** [proved here] *(revised after verification)*.

*Setting.*
* Credences are computable $P_t(\varphi)\in\mathbb Q\cap[0,1]$ on all sentences.
* "Weakly coherent" here means $\limsup_t(P_t(\psi)+P_t(\varphi))\le1$ whenever $\mathrm{PA}\vdash\psi\to\neg\varphi$, for **all** sentences ψ, φ. This is stronger than D's hypothesis. So the impossibility in (b) holds a fortiori, and the constructions in (c) meet the stronger form.
* "$P$ gradually verifies $C$" means row (f): for φ ∈ C, $P_t(\varphi)\to1$ iff φ is true.
* Columns refer to Thm G, with the convention above, so Π₁ ⊆ Σ₂ ∩ Π₂.

*Statement.*
* **(a) Incoherent credences reach Π₃.** Thm G(f) gives computable credences that gradually verify the Π₂ column and converge on every Π₂ sentence. It also gives credences that gradually verify the Π₃ column. By (d), the Π₃ credences cannot converge on every false Π₃ sentence.
* **(b) Weak coherence excludes the Π₂ and Π₃ columns.** Suppose $C$ contains every Π₂ sentence, and hence every Π₁ sentence. Gradual verification of $C$ implies Π₁-convergence, and Thm D then gives a true Π₂ sentence with liminf 0, a contradiction. More generally, by the Remark after Thm D, no Π₁-convergent weakly coherent credences gradually verify a decidable $C\subseteq\Pi_2$ whose truths are not Σ₂.
* **(c) Weak coherence does not exclude the Σ₁, Π₁, B(Σ₁) or Σ₂ columns.**
  * *Σ₁, Π₁, B(Σ₁).* Use the 0/1 output of the limit decider of Thm G(c) on $C$, and 0 elsewhere. The limits on $C$ are truth values and PA is sound, so every PA-incompatible pair has limiting sum ≤ 1.
  * *Σ₂.* Use the construction below. Because Π₁ ⊆ Σ₂, it is also Π₁-convergent. It gives credence 0 to every sentence not of Σ₂ form, so it is dogmatic on the strictly Π₂ truths, consistent with Thm D. *(Construction due to the referee; proof checked here, and sanity-checked by `L3-scripts/sigma2_weak_coherence.py`.)*
* **(d) Convergent credences have a Π₂ ceiling, coherent or not.** Suppose $\lim_tP_t(\varphi)$ exists for every φ ∈ C. Then the success set
  $$\{\varphi\in C:\lim_tP_t(\varphi)=1\}=\{\varphi:\forall q\in\mathbb Q^+\,\forall s\,\exists t\ge s\;P_t(\varphi)>1-q\}$$
  is Π₂. So no convergent credences gradually verify the Σ₂ or Π₃ column, since $\mathrm{Th}_{\Sigma_2}$ and $\mathrm{Th}_{\Pi_3}$ are not Π₂. Among convergent credences, incoherent ones reach the Π₂ column (by (a)) and weakly coherent ones do not (by (b)).

*Construction for (c), Σ₂.* Enumerate the Σ₂ sentences σ = ∃x∀y R(x,y), R Δ₀, with an index ind(σ). Quantifier blocks are coded as single variables, and an empty block is treated as a dummy variable. At stage t:
* $x_t(\sigma)$ := the least x ≤ t with R(x,y) for all y ≤ t, or t+1 if there is none.
* $c_t(\sigma)$ := the last stage s ≤ t with $x_s(\sigma)\neq x_{s-1}(\sigma)$, or −1 if there is none.
* $a_t(\sigma):=t-\max(\mathrm{ind}(\sigma),c_t(\sigma))$, the "age" of the current witness, for t ≥ ind(σ).
* $I_t$ := the set of pairs (σ,σ′) of Σ₂ sentences with indices ≤ t that have a PA-proof of ¬(σ∧σ′) with code ≤ t. This includes σ′ = σ.
* The credence:
  $$P_t(\sigma):=\min\Big(1-2^{-a_t(\sigma)},\ \min\{2^{-a_t(\sigma')}:(\sigma,\sigma')\in I_t,\ a_t(\sigma')\ge a_t(\sigma)\}\Big).$$
  Set $P_t:=0$ on sentences not of Σ₂ form, and on σ before stage ind(σ).

*Proof of (c), Σ₂.*
1. *Weak coherence.* Take (σ,σ′) ∈ I_t with $a_t(\sigma)\le a_t(\sigma')$. Then $P_t(\sigma)\le2^{-a_t(\sigma')}$ and $P_t(\sigma')\le1-2^{-a_t(\sigma')}$, so the sum is ≤ 1 at every such stage. Every PA-incompatible pair of Σ₂ sentences lies in $I_t$ from some stage on. A pair with a non-Σ₂ member has that member at 0.
2. *False σ.* Every x is eventually refuted, so $x_t(\sigma)$ is unbounded and changes infinitely often. At each change, $a_t(\sigma)=0$ and $P_t(\sigma)\le1-2^0=0$. So $P_t(\sigma)\not\to1$.
3. *True σ.* Let x* be the least witness. Once every x < x* is refuted and t ≥ x*, $x_t(\sigma)=x^*$ forever. Let $T_0:=\max(\mathrm{ind}(\sigma),\text{last change})$. For t > T₀, $a_t(\sigma)=t-T_0\to\infty$.
   * A competitor σ′ with ind(σ′) > T₀ has $a_t(\sigma')\le t-\mathrm{ind}(\sigma')<a_t(\sigma)$.
   * Only finitely many competitors have index ≤ T₀. Each is PA-incompatible with the true σ, so each is false, because PA is sound. Each such σ′ therefore changes at some stage c > T₀, and from then on $a_t(\sigma')\le t-c<a_t(\sigma)$.
   * So from some stage on, no competitor enters the inner minimum, and $P_t(\sigma)=1-2^{-a_t(\sigma)}\to1$. ∎

*Reading.*
* Coherence does lower the truth-tracking ceiling. Among the columns of Thm G, it removes exactly the Π₂ column for convergent credences. For credences that need not converge, it removes exactly the Π₂ and Π₃ columns.
* **Retracted:** the first version's slogan "coherence lowers the ceiling from Π₃ (incoherent) to Δ₂". Weakly coherent oscillating credences gradually verify Σ₂, which is not Δ₂. Moreover, part of the Π₃-versus-Π₂ gap is the cost of *convergence*, not of coherence.
* This is the probabilistic counterpart of L5's "bold in the limit ⇒ false".
* **Open.** Which classes can weakly coherent credences gradually verify in general? For example, take a Π₂-complete class of Π₂ sentences such as {"W_e is infinite"} with credences that are *not* required to be Π₁-convergent. Then (b) does not apply, and I have no construction either.

### 3.5 Bayesian convergence theorems: what they cover

* **Gaifman & Snir, "Probabilities over rich languages, testing and randomness", *JSL* 47(3):495–548 (1982)** ✓.
  * For a measure on a language containing empirical data sentences: $P(\varphi\mid\text{data}_n)\to\mathbf 1[\varphi]$ almost surely, for φ in the σ-algebra generated by the data (statement form [mem]; this is Lévy's 0–1 law in logical dress).
  * The paper also relates the convergence set to randomness [mem].
* **Blackwell & Dubins, "Merging of opinions with increasing information", *Ann. Math. Stat.* 33(3):882–886 (1962)** ✓. If $Q\ll P$, then $\sup_A|P(A\mid\mathcal F_n)-Q(A\mid\mathcal F_n)|\to0$ $Q$-almost surely (total variation over the future).
* **Belot, "Bayesian orgulity", *Phil. Sci.* 80 (2013)** ✓. The failure set of such theorems can be *comeager*, i.e. topologically typical. So a Bayesian is forced to be certain of success where failure is typical.
* **Kosoy, "Forecasting using incomplete models"**, arXiv:1705.04630 ✓ (abstract). There is a forecaster that, whenever the true measure satisfies some incomplete model (a convex set of measures) in a countable class, converges to that model in the Kantorovich–Rubinstein metric. This is a "merging of opinions" for partial models.

**Mapping.**
* These are theorems about *empirical* uncertainty. For a logically omniscient prior on arithmetic, the Δ₀ "data" are logically determined, the data σ-algebra is trivial, and the theorems say nothing.
* They apply to math only after logical non-omniscience is modelled, e.g. by LI's propositionally consistent worlds.
* They do apply to **physics bridges**:
  * two bridge-validity learners with mutually absolutely continuous priors merge on future observables (Blackwell–Dubins);
  * Belot's point tells us to report the topological size of the failure set.
* Kosoy's incomplete models are the right formalization of a **rule as a partial model**. "If premises then conclusion" is a convex constraint on the forecast. So "eventually satisfy every true rule in a countable class" has a forecasting theorem behind it.

---

## 4. Logical induction

### 4.1 Definitions

**Garrabrant, Benson-Tilsen, Critch, Soares & Taylor, "Logical induction", arXiv:1609.03543 (2016)** ✓. Abridged as "A formal approach to the problem of logical non-omniscience", TARK 2017, EPTCS 251:221–235 ✓. Details in this subsection are [mem] unless marked.

* **Deductive process.** A computable increasing sequence of finite sets $D_n$ whose union is the theorem set of a consistent r.e. theory Γ.
* **Market.** $P=(P_n)$, with $P_n$ a rational price in [0,1] for each sentence.
* **Plausible worlds.** $\mathrm{PC}(D_n)$ is the set of truth assignments $W$ that are *propositionally* consistent with $D_n$. These are "impossible possible worlds": non-omniscient worlds.
* **Trader.** A sequence $T_n$ of trading strategies. Each $T_n$ is a finite linear combination of sentences whose coefficients are "expressible features" (continuous functions of past and current prices), and the sequence is **efficiently computable (e.c.)**.
* **Exploitation.** $T$ *exploits* $P$ if the set of plausible values of its holdings, $\{W(\sum_{i\le n}T_i(P)) : n\in\mathbb N,\ W\in\mathrm{PC}(D_n)\}$, is bounded below but not above ✓.
* **LI criterion.** No e.c. trader exploits $P$ ✓.
* **Existence.** A computable logical inductor exists (LIA). It uses a fixed-point price-finding step each day and a budgeted mixture of all e.c. traders [mem].

### 4.2 Properties

* **Convergence** (4.1.1; theorem numbers in this pair are [mem]). $P_\infty(\varphi)=\lim_nP_n(\varphi)$ exists ✓.
* **Limit coherence** (4.1.2). $P_\infty$ is a probability measure on the completions of Γ: theorems get 1, refutables get 0 ✓.
* **Provability induction** (4.2.1) ✓.
  * For every e.c. sequence of theorems, $P_n(\varphi_n)\eqsim_n1$.
  * For every e.c. sequence of disprovable sentences, $P_n(\psi_n)\eqsim_n0$.
  * This happens *before* the proofs appear in $D$ at time $f(n)$ ("timely" learning).
* **Learning pseudorandom frequencies** (4.4.2) ✓ (name and content). Let $\varphi_n$ be an e.c. sequence of decidable sentences that is pseudorandom with frequency $p$ against polytime selection rules. Then $P_n(\varphi_n)\eqsim_np$.
* **Affine provability induction (Thm 4.5.4)** ✓ (number and statement checked against a search-result snippet by the referee and again by me; full text not reachable) *(restated after verification)*.
  * Let $\bar A\in\mathrm{BCS}(\bar P)$. A bounded combination sequence is a $\bar P$-generable sequence of affine ℝ-combinations of sentences with $\|A_n\|_1$ bounded.
  * Let $b\in\mathbb R$ be a **constant**.
  * If $W(A_n)\ge b$ for all worlds $W\in\mathrm{PC}(\Gamma)$ and all $n$, then $P_n(A_n)\gtrsim_nb$. The same holds for = with $\eqsim_n$, and for ≤ with $\lesssim_n$.
  * The first version paraphrased this as "Γ proves $A_n\ge b_n$" with a sequence $b_n$. That paraphrase was loose: an affine inequality is not a sentence, and the theorem has a constant $b$.
  * Affine coherence (Thm 4.5.5) is the companion result.
* **Non-dogmatism** [mem]:
  * $\Gamma\nvdash\varphi\Rightarrow P_\infty(\varphi)<1$;
  * $\Gamma\nvdash\neg\varphi\Rightarrow P_\infty(\varphi)>0$;
  * "Occam bounds": $P_\infty(\varphi)\ge C\,2^{-\kappa(\varphi)}$ for Γ-consistent φ, where κ is prefix complexity [unverified form].
* **Trust in consistency** ✓ (summary-level). For consistent r.e. Γ′ and computable $f$, the market's credence that Γ′ has no contradiction of length ≤ $f(n)$ tends to 1.
* **Other properties** [mem]:
  * calibration and unbiasedness on e.c. sequences once truth values are revealed;
  * closure under finite conditioning;
  * domination of the universal semimeasure;
  * introspection;
  * self-trust (stated through future expectations with a deferral function);
  * paradox resistance.

**Rates.** Every guarantee is asymptotic ($\eqsim_n$). None comes with a rate, and LIA's running time is astronomically large.

**Precursors.**
* Garrabrant, Fallenstein, Demski & Soares, "Inductive coherence", arXiv:1604.05288 ✓, which targets coherence of finite approximations.
* Garrabrant et al., "Asymptotic logical uncertainty and the Benford test", arXiv:1510.03370 ✓.
* Christiano, "Non-omniscience, probabilistic inference, and metamathematics", MIRI TR 2014-3 ✓.

### 4.3 What logical induction does *not* give

* **(a) LI is not Π₁-convergent** [proved here from non-dogmatism].
  * $\mathrm{PA}\nvdash\mathrm{Con(PA)}$, so $P_\infty(\mathrm{Con(PA)})<1$.
  * $\mathrm{PA}\nvdash\neg\neg\mathrm{Con(PA)}$, so $P_\infty(\neg\mathrm{Con(PA)})>0$.
  * So the limit puts positive mass on Σ₁-unsound completions. The Gödel/Rosser residue of T2 Thm 3.9 reappears as positive probability.
  * This corrects L5 §7.4: nothing forces $P_\infty(\mathrm{Con(PA)})=1$, and in fact non-dogmatism forbids it.
  * Compare "trust in consistency": credence in *finitistic* consistency → 1, while credence in Con(PA) itself stays below 1.
* **(b) No finite-time or worst-case guarantee.**
  * $P_n$ may be incoherent and wrong on any finite set of sentences.
  * The guarantees bind only e.c. traders, which are much weaker than the market itself. A prover with more compute than $P$ can find mispriced sentences, which is exactly T1's worry.
  * Rules that fail on a *sparse* pseudorandom set get per-instance credence → 1.
* **(c) Garbage in, garbage out.** Every guarantee is relative to $D$. If $D$ contains the outputs of unsound learned rules, the market becomes a well-calibrated reasoner about the *wrong* theory. If Γ is inconsistent, everything gets price 1.
* **(d) The limit is limit-computable (Δ₂).** By Thm G(c), no Δ₂ object is the truth on Σ₂ ∪ Π₂.

### 4.4 The user's coherence loss is arbitrage

**Prop E** [de Finetti; std].
* Let $P$ be credences on a finite set $S$ and $\mathcal W$ the worlds consistent with the trusted constraints. Define
  $$\mathrm{Arb}(P)=\max_{x\in[-1,1]^S}\ \min_{W\in\mathcal W}\ \textstyle\sum_{\varphi}x_\varphi\,(W(\varphi)-P(\varphi)).$$
* Then $\mathrm{Arb}(P)\ge0$, with equality iff $P$ is coherent, i.e. extends to a probability on $\mathcal W$.
* "Good arguments for both P and ¬P" means $P(\varphi),P(\neg\varphi)\ge1-\varepsilon$. Selling both earns $1-2\varepsilon$ in *every* world, with no need to wait for the world to reveal anything.
* So the coherence half of the user's protocol is *risk-free* arbitrage, and the world-feedback half is *risky* bets settled by $D$. LI unifies the two.
* LI forbids *unbounded cumulative* exploitation by e.c. traders. This implies the coherence loss vanishes asymptotically on every e.c. family of constraints (affine coherence). The converse fails: LI also demands learning from $D$.

**Lemma E′ (coherentizing is safe when the constraints are sound, and can hurt when they are not)** [proved here; cf. de Finetti 1974; Joyce 1998; Predd et al., IEEE TIT 2009 [mem]].
* Let $K$ be the convex hull of the indicator vectors of the worlds in $\mathcal W$, let $x\notin K$, and let $x^{*}$ be its Euclidean projection onto $K$. Then for every $w\in K$:
  $$\|x-w\|^2\ \ge\ \|x-x^{*}\|^2+\|x^{*}-w\|^2\ >\ \|x^{*}-w\|^2.$$
* *Proof:* the projection inequality $\langle x-x^{*},w-x^{*}\rangle\le0$. ∎
* So coherentizing improves the Brier score by at least $\|x-x^*\|^2$, the **squared Euclidean distance from $x$ to $K$**, **in every world satisfying the constraints**. In particular it improves the score in the actual world *if the constraints are sound*. *(Wording fixed after verification: this is not the Arb of Prop E.)*
* If the constraints come from untrusted learned rules, or from an idealized context that the actual world violates (the air-pressure example), then the true world may lie outside $K$ and projection can make things worse.
  * Minimal example: the unsound constraint "¬φ" gives $K=\{0\}$. With φ true and $x=0.9$, projection moves the Brier loss from 0.01 to 1.
* **Converse** *(added after verification)*. Suppose the actual world's indicator $v$ on $S$ is not among the indicators of $\mathcal W$, i.e. the constraints are unsound on $S$. Then $v\notin K$, because 0/1 vectors are extreme points of the cube. For $x=v$, projection raises the actual-world Brier loss from 0 to $\|v-v^*\|^2>0$. So "projection never hurts in the actual world" holds **iff** the constraints are sound.
* **Scope** *(added after verification)*. The dominance property belongs to the Euclidean projection for the Brier score. For other proper scores it belongs to the corresponding Bregman projection (Predd et al. 2009) [mem]. It does **not** belong to an arbitrary correction that removes the arbitrage.
  * Example: $S=\{\varphi,\neg\varphi\}$ and $x=(0.6,0.6)$, so $\mathrm{Arb}=0.2$.
  * Moving to the coherent point $(1,0)$ gives Brier 2.0 in the world $(0,1)$, against 0.52 before.
  * The projection $(0.5,0.5)$ gives 0.5 in both worlds.

This is a formal argument for orchestrator §1 and H6: coherence pressure should act only on claims asserted in the actual context, with constraints drawn from trusted rules.

### 4.5 A market of rule traders

**Design.**

1. **Trusted deductive process $D$.** It contains exactly:
   * Δ₀ facts computed (world feedback);
   * theorems of a small trusted base $B$ found by proof search;
   * optionally, externally certified facts.
   
   Nothing learned ever enters $D$.
2. **Rule traders.** For each candidate rule schema $r$, possibly with a guard $g$, there is a trader $T_r$ with budget $2^{-|r|}$. At day $n$ it enumerates poly(n) instances $(\gamma\Rightarrow\varphi)$ of $r$. With the continuous ramp $h(u):=\min\{1,\max\{0,u/\epsilon-1\}\}$ it:
   * buys $h(P_n(\gamma)-P_n(\varphi))$ shares of φ (forward direction);
   * sells $h(P_n(\gamma)-P_n(\varphi))$ shares of γ (contrapositive direction).

   *(Revised after verification.)* The first version used hard thresholds ("buy φ when $P_n(\varphi)<P_n(\gamma)-\epsilon$"). A hard threshold is discontinuous in prices, so it is not an LI trader, whose trades must be continuous expressible features. The ramp is 0 below a gap of ε and 1 above a gap of 2ε.
   
   The contrapositive direction is where *blame* flows: a refuted conclusion pushes down the premises. This is the market form of T2's negative bags.
3. **Human trader.** $T_{\rm hum}$ buys the conclusions of human-written steps. Imitation is then a hypothesis whose reliability the market learns, not a premise.
4. **Remaining traders.** All other e.c. traders (or a rich restricted class) are included, so that the LI criterion and §4.2 apply.

**Corollary F** [proved here, *given* Garrabrant et al. 2016, Thm 4.5.4, affine provability induction, in the form stated in §4.2] *(citation made precise after verification)*. Let $(\gamma_n\Rightarrow\varphi_n)$ be an e.c. sequence of instances of $r$ with $\Gamma\vdash\gamma_n\to\varphi_n$ for all $n$, i.e. **Γ-provable instances**. Then $\liminf_n\,(P_n(\varphi_n)-P_n(\gamma_n))\ge0$.

*Proof.*
* Let $A_n:=\varphi_n-\gamma_n$. Its coefficients are the constants ±1, so $\|A_n\|_1=2$.
* The sequence is e.c., hence $\bar P$-generable, so $\bar A\in\mathrm{BCS}(\bar P)$.
* $\gamma_n\to\varphi_n$ is a theorem of Γ, so every $W\in\mathrm{PC}(\Gamma)$ has $W(\varphi_n)\ge W(\gamma_n)$, i.e. $W(A_n)\ge0$.
* Thm 4.5.4 with the constant $b=0$ gives $P_n(A_n)\gtrsim_n0$. ∎

*Scope.* The corollary is per sequence. If a trader checks poly(n) instances per day, each e.c. enumeration of them is one such sequence. Combining them uniformly needs $\bar P$-generable weights, which BCS allows.

In words: **the market respects every efficiently enumerable sequence of Γ-provable rule instances before it has derived any instance.** Any explicit rule-trader layer therefore *exposes* what the LI criterion already enforces: the learned rules become inspectable as solvent traders. Note that "valid" here means Γ-provable, not merely true.

**Detection of invalid rules** *(revised after verification)*.
* **Settled failures.** Suppose an e.c. infinite family of instances has Γ-provable premises and Γ-refutable conclusions.
  * Provability induction gives $P_n(\gamma_n)\eqsim_n1$ and $P_n(\varphi_n)\eqsim_n0$. So the market's prices contradict $r$ on this family: anyone can read the violation off the prices.
  * Whether $T_r$ goes **bankrupt** is *not* established. Once prices have converged, its loss per instance is $P_n(\varphi_n)+(1-P_n(\gamma_n))$, which tends to 0 and may be summable. Provability induction gives no rate.
  * The first version claimed that $T_r$ "realizes losses on each settled instance until its budget is exhausted". That claim is withdrawn and is now part of conjecture L3-T6(b).
* **Pseudorandom failures.** If $r$ fails with pseudorandom frequency $p$, the credences of its conclusions converge to $1-p$ (§4.2). A certification threshold $1-\delta$ never certifies them iff $1-\delta>1-p$, i.e. **δ < p**, which is the right behaviour. *(Inequality corrected after verification. The first version wrote $1-\delta<1-p$, which is reversed.)*
* **Sparse or unsettled failures.** Suppose $r$ fails only on a sparse set, or only on sentences whose falsity $D$ never settles. Then $T_r$ *need not* lose, since its gains on valid instances can cover the losses. Examples of unsettled failures:
  * a rule that yields ¬Con(PA) when $D$'s base $B$ is PA;
  * a rule whose false conclusions (e.g. false Π₂ sentences) have no refutation in $B$.

  Σ₁- or Π₂-*unsoundness as such* does not make a failure invisible. Many false Σ₁ or Π₂ sentences are refutable in $B$, e.g. ∃x (x+1=0) in Q, and so are settled. *(Restricted after verification.)*

  **The market cannot detect what $D$ cannot settle.** This is the same residue as T2 Thm 3.9 and L4-T7, now in market form.

**Bayesian reading** [mem]. With log-utility (Kelly-betting) traders, the market price is the wealth-weighted average belief, and wealth updates by Bayes' rule (Beygelzimer, Langford & Pennock, "Learning performance of prediction markets with Kelly bettors", AAMAS 2012). Partial experts are "specialists" or "sleeping experts" (Freund, Schapire, Singer & Warmuth, STOC 1997).

**Two layers.** In the Bayesian reading, wealth is a posterior over rules, so the T1/L2 machinery plugs in:
* **acceptance** = every step is licensed under δ-conservative posterior acceptance, with Ville's inequality for time-uniformity;
* **learning** = the market.

The market proposes and calibrates; the conservative layer certifies.

**Guards.** When $T_r$ loses on an identifiable set of instances, spawn $T_{r|g}$ for guards $g$ that exclude that set; the market then selects among them. This is Lakatosian monster-barring (orchestrator §3, "x/x → 1 if x ≠ 0") as trader spawning.

---

## 5. Formal learning theory of inquiry

### 5.1 Limiting recursion and Kelly's characterization

**Classical results.**
* **Shoenfield, "On degrees of unsolvability", *Annals* 69 (1959)** [std]. $A\le_T\emptyset'$ iff $\chi_A=\lim_sg(\cdot,s)$ for a computable $g$.
* **Gold, "Limiting recursion", *JSL* 30(1) (1965)**, and **Putnam, "Trial and error predicates and the solution to a problem of Mostowski", *JSL* 30(1) (1965)** [std]. The same class of trial-and-error predicates.
* Putnam's $k$-trial predicates correspond to $k$ mind changes, i.e. the finite levels of the Ershov hierarchy [mem].

**Kelly, *The Logic of Reliable Inquiry*, OUP (1996)** ✓. Hypotheses are sets of data streams in Baire space.
* verifiable with certainty = open (Σ⁰₁);
* refutable with certainty = closed;
* decidable with $n$ mind changes = level $n$ of the difference hierarchy;
* **verifiable in the limit = Σ⁰₂**;
* **refutable in the limit = Π⁰₂**;
* **decidable in the limit = Δ⁰₂**;
* gradual verifiability = Π⁰₃ [mem; I re-derive it below].

For computable methods and computable data the lightface arithmetical analogues hold [mem].

**Further work.**
* Kelly, "Uncomputability: the problem of induction internalized", *TCS* 317:227–249 (2004) ✓, treats the halting problem as an inductive problem. That is precisely our math case, where the "data" are computation.
* Genin & Kelly, "The topology of statistical verifiability", TARK 2017 ✓: "H is verifiable iff H is open" in the weak topology on chance distributions.
* Baltag, Gierasimczuk & Smets, "On the solvability of inductive problems: a study in epistemic topology", TARK 2015 ✓ (title). Their characterization of learnability in the limit for general topological spaces is [unverified].

### 5.2 Applied to arithmetic with coherence and Δ₀ feedback

For an unbounded computable learner, both kinds of feedback are internal:
* Δ₀ truth values are computable;
* coherence of a computable hypothesis is a Σ₁ search.

So the question becomes: which success criteria can a computable $M(\varphi,t)$ meet on a decidable class $C$ of sentences?

**Theorem G** [std: Kelly 1996 and Shoenfield, specialized; proof sketch of standard results here] *(label changed after verification from "proved here")*. Here "Th" means $\mathrm{Th}(\mathbb N)\cap C$.

| Success criterion for $M$ on $C$ | Possible iff | Σ₁ | Π₁ | B(Σ₁) | Σ₂ | Π₂ | Π₃ |
|---|---|---|---|---|---|---|---|
| (a) decide with certainty | Th decidable | no | no | no | no | no | no |
| (b) verify with certainty (accept once, only truths, eventually every truth) | Th Σ₁ | **yes** | no | no | no | no | no |
| (c) decide in the limit | Th Δ₂ | yes (1 mind change) | yes (1) | **yes (≤ k)** | no | no | no |
| (d) verify in the limit (stably accept exactly the truths) | Th Σ₂ | yes | yes | yes | **yes** | no | no |
| (e) refute in the limit | Th Π₂ | yes | yes | yes | no | **yes** | no |
| (f) gradual verification (credence → 1 iff true) | Th Π₃ | yes | yes | yes | yes | yes | **yes** |
| (g) credences converge to the truth value | Th Δ₂ | as (c) | | | | | |

*Proof sketch.*
* **Necessity** in each row: compute the complexity of the success set. For example, in (d), "∃s ∀t≥s M = 1" is Σ₂.
* **Sufficiency**:
  * (c) is Shoenfield. For B(Σ₁): guess every Σ₁ component false, and flip each one when its witness is found; k components give ≤ k flips.
  * (d) Let x_t be the least x ≤ t not yet refuted by any y ≤ t. If every x ≤ t is refuted, set x_t := t+1, which counts as a change. Output 1 iff $x_t=x_{t-1}$.
  * (f) Write a Π₃ statement as $\bigcap_k S_k$ with $S_k$ Σ₂, and run limit-verifiers $V_k$. The credence is $1-2^{-j_t}$, where $j_t$ is the least k ≤ t with $V_k$ currently outputting 0. If there is none, $j_t:=t+1$.
    * True: each $V_k$ eventually outputs 1 forever, so $j_t\to\infty$.
    * False: some $V_{k_0}$ outputs 0 infinitely often, so the credence is ≤ $1-2^{-k_0}$ infinitely often.

    For a Π₂ sentence ∀x∃y R the credence is $1-2^{-k(t)}$, with k(t) = the length of the initial segment of x's already witnessed by stage t. k(t) is nondecreasing, so these Π₂ credences converge on every sentence.
* **The entries "no"** use Post's hierarchy theorem: $\mathrm{Th}_{\Sigma_n}$ is Σₙ-complete and $\mathrm{Th}_{\Pi_n}$ is Πₙ-complete [std]. ∎

**Credences** *(revised after verification)*.
* The first version said: "Row (f) is achievable only incoherently: Theorem D forbids it for weakly coherent credences. The coherent row is (g)." **That was false and is retracted.**
* Theorem D forbids row (f) for weakly coherent credences only on the **Π₂ and Π₃ columns**. Weakly coherent computable credences achieve row (f) on the Σ₁, Π₁, B(Σ₁) **and Σ₂** columns (Thm D′(c)). Th_Σ₂ is not Δ₂.
* For **convergent** credences, coherent or not, the row (f) success set is Π₂ (Thm D′(d)). Here coherence costs exactly the Π₂ column.
* Row (g), credences that converge to the truth value, is achievable with weak coherence exactly where (c) is: use the limit decider on $C$ and 0 elsewhere.
* Whether a sharper "coherent ceiling" exists is open (Thm D′, Open).

**Lemma K (no computable modulus)** [std folklore; one-line proof here]. Suppose $M$ decides $C$ in the limit and a computable τ bounds the stage of its last mind change. Then $\mathrm{Th}\cap C$ is decidable: output $M(\varphi,\tau(\varphi))$. ∎
* So for Π₁ sentences, convergence time is never computably bounded.
* Meaningful rates are therefore relative ones:
  * mind changes;
  * latency after the shortest witness, or after the shortest proof in the trusted base;
  * Solomonoff-type cumulative-loss bounds.
* **Speed-up** [std/mem; Gödel 1936; Buss, *JSL* 59 (1994)]. For $T\subset T'$ with $T'\vdash\mathrm{Con}(T)$, $T$-proof lengths are not bounded by any computable function of $T'$-proof lengths. So **trusting more (sound) principles is a non-recursive rate improvement** for verifying Σ₁ facts and refuting Π₁ claims.

**Prop H (feedback relativization)** [proved here] *(hypothesis made explicit after verification)*. Suppose the world answers **arbitrary** truth-value queries for Σₙ sentences, n ≥ 1: the learner may ask about any Σₙ sentence and gets "true" or "false". That is an oracle for $\mathrm{Th}_{\Sigma_n}\equiv_T\emptyset^{(n)}$. Then decidability in the limit reaches exactly the Δₙ₊₂ sets. For example, a Σ₁ oracle lets a learner limit-decide B(Σ₂).

*Caveat.* A computable stream of Σₙ truths (positive data only) adds nothing. It is computable feedback, so a learner using it still limit-decides only the Δ₂ sets (unrelativized Shoenfield).

*Proof.* Relativized Shoenfield: limit-computable in $X$ iff $\le_TX'$. Also $(\emptyset^{(n)})'=\emptyset^{(n+1)}$, and $\le_T\emptyset^{(n+1)}$ means Δₙ₊₂ (Post). ∎

So in math, world feedback adds power only if it is *non-computable*.
* An example is an oracle that settles every Σ₁ question.
* No consistent r.e. theory provides such an oracle. Trusting a stronger r.e. theory adds *speed* (Gödel speed-up; see the speed-up bullet after Lemma K), not limit power: its theorems are computable feedback, so only the Δ₂ sets are reached. *(Revised after verification. The first version said such an oracle "in effect means trusting stronger theories".)*

In physics, feedback is genuinely external, so Kelly's empirical, Borel version applies.

**Complexity of properties of a learned calculus R** [proved here, or from L5 Prop 7.3]. Each property is listed with its complexity and what that means for inquiry.

| Property of R | Complexity | Inquiry status |
|---|---|---|
| a rule is derivable in B | Σ₁ | verifiable with certainty |
| a rule is sound, Δ₀ premises and Δ₀ or Π₁ conclusions | Π₁ | refutable with certainty; ≤ 1 mind change |
| a rule is sound, Σ₁ conclusions or Π₁ premises | Π₂ | only refutable in the limit |
| R is consistent | Π₁ | refutable with certainty |
| R is Σ₁-sound | Π₂-complete (L5) | only refutable in the limit |
| R is conservative over B | Π₂-complete (L5) | only refutable in the limit |
| R ⊇ R* (covers the human calculus) | Π₂ | only refutable in the limit |
| R ≡ R* | Π₂ | only refutable in the limit |

**"The learner has found a sound and complete calculus" is never verifiable, even in the limit.** This sharpens L5 TC11.

### 5.3 Dialectical systems: contradiction versus counterexample

* **Magari (1974)** [mem] introduced *dialectical systems*. A proposer offers theses; a thesis is retracted when a contradiction is derived; the "final theses" are those eventually stably kept. They model trial-and-error mathematics.
* **Amidei, Pianigiani, San Mauro, Simi & Sorbi, "Trial and error mathematics I: dialectical and quasidialectical systems", *RSL* 9(2):299–324 (2016)** ✓ (abstract):
  * quasidialectical sets are Δ⁰₂ and "spread throughout" the Ershov hierarchy;
  * dialectical sets are ω-c.e.
* **Amidei, Andrews, Pianigiani, San Mauro & Sorbi, *J. Logic Comput.* 29(1):157 (2019)** ✓ (abstract):
  * every consistent system with connectives represents a completion of its theory;
  * dialectical and quasidialectical systems represent the same completions;
  * a *p-dialectical* system, which revises on finding a counterexample, represents a completion of PA that is neither dialectical nor quasidialectical.
* **Andrews & San Mauro, "Comparing dialectical systems: contradiction and counterexample in belief change", arXiv:2507.06798 (2025)** ✓ (abstract). q-dialectical systems (both triggers) are strictly more powerful than p-dialectical systems, which are strictly more powerful than d-dialectical systems (contradiction only).

**Relevance.** This is the closest existing mathematics to "(a) coherence versus (b) counterexample feedback in a mathematical learner". It also matches L5 Cor 4: a convergent bold learner converges to a completion, and therefore to a false theory.

**Caution [unverified].**
* The power comparisons concern which sets a given *revision mechanism* can represent. They are not about information.
* I could not check whether "counterexample" means an *external* truth oracle or an internal refutation.
* T2 Lemma 3.7 shows Δ₀ feedback adds no *information* above Q.
* So the two results need not conflict, but this must be read before the separation is cited as evidence for the user's two-signal design.

### 5.4 Ockham efficiency and mind changes

**Sources.**
* **Kelly, "Ockham's razor, empirical complexity, and truth-finding efficiency", *TCS* 383:270–289 (2007)** ✓ (abstract). "Always choosing the simplest theory compatible with experience, and hanging on to it while it remains the simplest, is both necessary and sufficient for efficiency." Efficiency is the optimum worst-case retractions/errors/time within each complexity class.
* **Genin & Kelly, *Studia Logica* 107:949–989 (2019)** ✓. Explicates Ockham principles in the information topology, and shows they are necessary for reversal- or cycle-optimal convergence.
* Mind-change optimality and Cantor–Bendixson rank: Luo & Schulte, *Information and Computation* (2006); Apsītis [mem].

**Transfer (candidate).** In the topology generated by positive data (texts of valid steps):
* an over-general calculus $R'\supsetneq R$ can be "revealed", since a step in $R'\setminus R$ appears;
* but $R'$ can never be refuted.

So Kelly-simplicity orders calculi by inclusion, and the Ockham method is the **least-general consistent calculus**, i.e. L1's conservative learner. Ockham efficiency would then give a *truth-finding* justification for minimality that does not rest on an MDL prior. With coherence data, incoherent over-generalizations become refutable, but coherent ones stay invisible (T2 Thm 2.6), so the ordering among coherent hypotheses is unchanged.

### 5.5 Other formal-learning results bearing on this strand

* **Osherson, Stob & Weinstein, *Systems That Learn*, MIT Press (1986)** ✓.
* **Osherson & Weinstein**:
  * "Identification in the limit of first order structures", *JPL* 15:55–81 (1986) ✓;
  * "Paradigms of truth detection", *JPL* 18:1–42 (1989) ✓. A scientist must determine the truth of a sentence in the structure generating the data, under five stabilization paradigms.
* **Jeroslow, "Experimental logics and Δ⁰₂ theories", *JPL* 4:253–267 (1975)** ✓, with the Π⁰₃ sequel in *JSL* ✓ (title). Theorem sets of trial-and-error proof procedures; the closest model of a learner's limiting theory.
* **Kaså, "A logic for trial and error classifiers", *JoLLI* 24(3) (2015)** ✓.
* **Putnam's diagonal argument.** Putnam (1963), "'Degree of confirmation' and inductive logic", in Schilpp (ed.) ✓; analysed by Sterkenburg, *Erkenntnis* (2019) ✓. No computable inductive method detects every computable pattern; Solomonoff's mixture escapes only by being semicomputable.
* **Mercier, Lopez-Wild & Spiegel, "At the edge of Putnam's program", arXiv:2606.00363 (2026)** ✓ (abstract). Natural inductive logics on languages containing arithmetic yield non-arithmetical probabilities. The natural weakening is arithmetical but still uncomputable. This is consistent with Prop B and Theorem D.

---

## 6. Solomonoff, and the user's notes

**Solomonoff** [std]:
* Solomonoff 1964, *Information and Control* 7.
* Solomonoff 1978, *IEEE TIT* 24 [mem].
* Hutter 2005.

The key bound: for a computable μ, $\sum_t\mathbb E_\mu\,\mathrm{KL}(\mu(\cdot\mid x_{<t})\,\|\,M(\cdot\mid x_{<t}))\le K(\mu)\ln2+O(1)$. This is the model for "rates" as cumulative loss. It is used in L2 and T1's Bayesian acceptance.

**Mapping to the user's notes.**
* **His Craig-style equivalence.** Function induction with consistent assigners is equivalent to axiom induction requiring proofs. In Prop C's terms, this says the two have the same Bel.
* **His OOD worry** (a simple test/train distinguisher buys constant probability of misbehaviour). It is the probabilistic face of Lemma A(ii) and of T1.
* **LI** reportedly dominates the universal semimeasure (§4.2). So the LI framework subsumes Solomonoff prediction of computation outputs while adding coherence across sentences.

---

## 7. Answer to the key question

**Q1. What is achievable in the limit (formal math)?**
* With unbounded compute, world feedback by Δ₀ computation is redundant (T2 Lemma 3.7; Thm G).
* What can be achieved:
  * limit-correctness on B(Σ₁), with ≤ k mind changes;
  * stable acceptance of exactly the true Σ₂;
  * refutation in the limit of false Π₂;
  * coherent credences that are non-dogmatic (LI). These cannot also be Π₁-convergent unless they are dogmatic somewhere in Π₂ (Thm D);
  * weakly coherent credences that converge to 1 on exactly the true Σ₂ sentences, oscillating on some false ones (Thm D′(c), *added after verification*).
* For the *learned rules*, the hard properties are only refutable in the limit (§5.2 table):
  * soundness when conclusions are Σ₁;
  * Σ₁-soundness;
  * conservativity;
  * coverage.
* Positive identification results therefore need restricted hypothesis classes (L1, T2).

**Q2. At what rates?**
* There is no computable modulus (Lemma K).
* Rates can only be relative:
  * **mind changes**: 1 per Σ₁/Π₁ sentence, k per B(Σ₁) sentence;
  * **latency** after the shortest witness or trusted proof, which is improved non-recursively by trusting sound stronger principles;
  * **cumulative loss** ≤ ln(1/w(R*)) for Bayesian or Kelly-betting markets over a realizable rule class;
  * **contradictions** ≤ log₂(1/w) for oligarchic halving (T2);
  * **per-check error** d/|S| for fresh-randomness numerical checks (Lemma A(iii)).
* For bounded learners, LI's provability induction and pseudorandom-frequency theorems are the "timeliness" results, but they come without explicit rates.

**Q3. How to make "derives lots of correct conclusions" precise.** I recommend a conjunction of four criteria:
* **(i) worst-case soundness** on a class $C$ relative to a trusted base: $\Pr[\exists t\,A_t\cap C\ni\text{false}]\le\delta$, uniformly over adaptive provers (H1, T1);
* **(ii) coverage** of a reference calculus $T^{*}$ (the human practice) with polynomial overhead: every $T^{*}$-proof of size $L$ yields acceptance within $p(L)$ (p-simulation, Cook–Reckhow style), or at least $\mathrm{Thm}(T^{*})\subseteq\bigcup_tA_t$;
* **(iii) limit-correctness** on Σ₁ ∪ Π₁;
* **(iv) calibration and no e.c. exploitation** on everything else (LI).

The fundamental trade-off between (i) and (ii): if $T^{*}\not\subseteq$ the trusted base, then coverage requires accepting rules whose soundness is a Π₂ property, refutable only in the limit. Human practice that is Σ₁-unsound is indistinguishable from sound practice on all available data (T2 Thm 3.9).

**Q4. Impossibility results that delimit the design.**
* **Rosser.** No consistent r.e. extension of Q is complete.
* **Π₁ truth is not r.e.** No r.e. sound theory proves all true Π₁ sentences.
* **No Δ₂ object is right on Σ₂ ∪ Π₂** (Thm G).
* **Weak coherence + Π₁-convergence + computability ⇒ liminf credence 0 on some true Π₂** (Thm D; limit credence 0 if limits exist). *(Wording fixed after verification: the first version said "credence 0".)*
* **LI is Σ₁-unsound in probability**: $P_\infty(\neg\mathrm{Con})>0$.
* **Market blindness.** A market cannot detect rule failures its deductive process never settles (§4.5).
* **Gaifman + coherence on arithmetic = truth**, which is not definable (Prop B).
* **Putnam/Sterkenburg.** No computable universal inductive method.
* **Coherentizing against unsound constraints can hurt accuracy** (Lemma E′).

**Correcting the brief's slogan.** "No computable learner is Σ₁-sound and complete for arithmetic" is not right as stated: PA itself is Σ₁-sound and Σ₁-complete. See §9.

---

## 8. Theorem candidates

* **L3-T1 (Commitment-order dichotomy; Lemma A)** [proved] *(revised after verification)*.
  * PAC-semantics is a worst-case-over-derivations semantics **when** the world is random, the rules are fixed first, and validity is per scene.
  * It is **not** one when the world is fixed and the prover chooses instances.
  * Fresh per-check randomness (A(iii)) is a further sound regime in a fixed world.
  * The first version's "exactly when" is withdrawn: no characterization is proved.
  * Paper role: the principled split between export rules (PAC) and in-context math rules (worst-case).
* **L3-T2 (Coherence/Π₁/Π₂ trilemma; Thm D, D′)** [proved] *(revised after verification)*.
  * Weak coherence excludes the Π₂ and Π₃ columns of gradual verification. It leaves the Σ₁, Π₁, B(Σ₁) and Σ₂ columns, and the Σ₂ case needs oscillating credences.
  * Convergent credences, coherent or not, have a Π₂ ceiling. Among them, incoherent ones reach the Π₂ column and weakly coherent ones do not.
  * This is a clean impossibility result about the user's coherence loss.
  * **Retracted:** the first version's headline "coherence lowers the ceiling from Π₃ (incoherent) to Δ₂ with dogmatic Π₂ errors". Weakly coherent credences gradually verify Σ₂, which is not Δ₂, and part of the Π₃/Π₂ gap is the cost of convergence, not of coherence.
  * Open: the exact class of sets that weakly coherent credences can gradually verify (Thm D′, Open).
* **L3-T3 (Coherentizing is safe when the constraints are sound, and can hurt when they are not; Lemma E′)** [proved].
  * Consequence for contexts: a coherence penalty computed in an idealized context provably can increase error on actual-world claims.
  * Easy experiment: Brier score before and after projection, with true versus idealized constraints.
* **L3-T4 (Success table for coherence plus computation; Thm G, Lemma K, Prop H)** [proved; standard ingredients]. This answers L4-T7's conjecture.
* **L3-T5 (Axiom induction = belief functions; Prop C)** [proved].
  * Answers the user's own coherence question.
  * Suggests the coherent read-out: random completion per hypothesis, i.e. Demski's prior or LI over each A (μ normalized, each A consistent and containing the data).
* **L3-T6 (Rule-trader market)** [Cor F proved modulo the cited LI Thm 4.5.4; the rest is conjecture]. Statement to prove:
  * (a) e.c. sequences of Γ-provable rule instances are respected (Cor F);
  * (b) rules with e.c. settled counterexamples go bankrupt, within a time bound that depends on the settlement latency. This is **conjecture**. Provability induction alone gives no rate, and the per-instance losses may be summable (§4.5). A proof needs convergence rates;
  * (c) failures that $D$ never settles are invisible;
  * (d) a δ-conservative acceptance layer over the wealth-posterior is time-uniformly sound (L2 Ville).
  
  Experiment: the algebra workhorse, with freshman's-dream and x/x rules as traders and random evaluation as $D$.
* **L3-T7 (Ockham transfer)** [conjecture]. Under finite elasticity (L1), the least-general consistent calculus is Genin–Kelly retraction-optimal among learners that identify the class from text plus coherence.

---

## 9. Corrections and refinements to the brief and sibling memos

1. **The brief's "no computable learner is Σ₁-sound and complete for arithmetic"** should be replaced by the precise list in §7 Q4.
   * Σ₁-soundness *together with* Σ₁-completeness is achieved by PA.
   * What fails:
     * r.e. + consistent + complete (Rosser);
     * r.e. + sound + Π₁-complete;
     * Δ₂ (limit) correctness on Σ₂ or Π₂;
     * stable acceptance of exactly the true Π₂;
     * weakly coherent Π₁-convergent computable credences without dogmatic (liminf 0) Π₂ errors.
2. **H1 refined.** PAC-semantics (Valiant/Juba) is *not* just "average-case, hence insufficient". It is sound against adversarial derivations when the randomness is over worlds and the rules are fixed first (Lemma A).
   * It is the right semantics for H6's export rules.
   * It is the wrong semantics for mathematical schemas.
   * Fresh-randomness checks (Schwartz–Zippel, with an enforced degree bound and the right field) are a "statistical" world oracle that is worst-case-sound in math (Lemma A(iii)). Samples drawn before the prover searches are not (Lemma A(ii)). *(The first version said "the only"; that is not proved.)*
3. **H4 and orchestrator §4: "world feedback (computation) refutes false Π₁".** True, but for an unbounded learner this is redundant (Thm G; T2 Lemma 3.7).
   * World feedback adds *power* only if it is non-computable (Prop H).
   * It adds *speed* for bounded learners (LI timeliness; Lemma A(iii)).
4. **H4's "Kelly characterizes what can be learned in the limit".** Correct. Add:
   * gradual verification = Π₃ (Thm G(f)). Weak coherence excludes the Π₂ and Π₃ columns but not Σ₂, and convergent credences of any kind stop at Π₂ (Thm D′). *(Revised after verification: the first version said "achievable only incoherently".)*
   * Kelly 2004 is the reference for treating computation as data;
   * Genin–Kelly supply the statistical/topological generalization needed for physics.
5. **L5 §7.4's "[unverified; check]" about $P_\infty(\mathrm{Con(PA)})$.** Settled: it is < 1 for every LI over PA, and $P_\infty(\neg\mathrm{Con})>0$ (§4.3(a)).
6. **Orchestrator §1 and H6 (coherence on asserted claims only).** Now has a formal justification: Lemma E′.
7. **The user's coherence loss should be formalized as arbitrage** (Prop E), i.e. as distance to the convex hull of trusted-consistent valuations. Do not formalize it as "count of derived contradictions". The arbitrage form is convex and graded, and its Euclidean projection (Bregman projection for other proper scores) has the accuracy-dominance property (Lemma E′). Arbitrary arbitrage-eliminating corrections do not have it (counterexample in Lemma E′). *(Revised after verification.)*
8. **Learned rules must never enter the trusted deductive process.** In LI terms, an unsound $D$ yields calibrated nonsense (§4.3(c)). This is the market version of H1's tonk worry.

---

## References

(✓ = bibliographic data checked this session; content checked only at abstract or summary level unless stated; [mem] = from memory.)

* Amidei, J., Pianigiani, D., San Mauro, L., Simi, G., Sorbi, A. (2016). Trial and error mathematics I: dialectical and quasidialectical systems. *Rev. Symb. Logic* 9(2):299–324. ✓
* Amidei, J., Andrews, U., Pianigiani, D., San Mauro, L., Sorbi, A. (2019). Trial and error mathematics: dialectical systems and completions of theories. *J. Logic Comput.* 29(1):157–. ✓
* Andrews, U., San Mauro, L. (2025). Comparing dialectical systems: contradiction and counterexample in belief change. arXiv:2507.06798. ✓
* Baltag, A., Gierasimczuk, N., Smets, S. (2015). On the solvability of inductive problems: a study in epistemic topology. TARK 2015, EPTCS 215:81–98. ✓ (title/venue)
* Belle, V., Juba, B. (2019). Implicitly learning to reason in first-order logic. NeurIPS. ✓
* Belot, G. (2013). Bayesian orgulity. *Phil. Sci.* 80. ✓
* Beygelzimer, A., Langford, J., Pennock, D. (2012). Learning performance of prediction markets with Kelly bettors. AAMAS. [mem]
* Blackwell, D., Dubins, L. (1962). Merging of opinions with increasing information. *Ann. Math. Stat.* 33(3):882–886. ✓
* Buss, S. (1994). On Gödel's theorems on lengths of proofs I. *JSL* 59. [mem]
* Christiano, P. (2014). Non-omniscience, probabilistic inference, and metamathematics. MIRI TR 2014-3. ✓
* Demski, A. (2012). Logical prior probability. AGI 2012, LNCS 7716:50–59. ✓
* Freund, Y., Schapire, R., Singer, Y., Warmuth, M. (1997). Using and combining predictors that specialize. STOC. [mem]
* Gaifman, H. (1964). Concerning measures in first order calculi. *Israel J. Math.* 2:1–18. ✓
* Gaifman, H., Snir, M. (1982). Probabilities over rich languages, testing and randomness. *JSL* 47(3):495–548. ✓
* Garrabrant, S., Benson-Tilsen, T., Critch, A., Soares, N., Taylor, J. (2016). Logical induction. arXiv:1609.03543; abridged in TARK 2017, EPTCS 251:221–235. ✓
* Garrabrant, S., Fallenstein, B., Demski, A., Soares, N. (2016). Inductive coherence. arXiv:1604.05288. ✓
* Garrabrant, S., et al. (2015). Asymptotic logical uncertainty and the Benford test. arXiv:1510.03370. ✓
* Genin, K., Kelly, K. (2017). The topology of statistical verifiability. TARK 2017, 236–250. ✓
* Genin, K., Kelly, K. (2019). Theory choice, theory change, and inductive truth-conduciveness. *Studia Logica* 107:949–989. ✓
* Gold, E. M. (1965). Limiting recursion. *JSL* 30(1):28–48. [std]
* Hutter, M., Lloyd, J., Ng, K. S., Uther, W. (2013). Probabilities on sentences in an expressive logic. *J. Applied Logic*. ✓
* Jeroslow, R. (1975). Experimental logics and Δ⁰₂-theories. *JPL* 4:253–267. ✓
* Juba, B. (2013). Implicit learning of common sense for reasoning. IJCAI, 939–946. ✓
* Juba, B. (2015). Restricted distribution automatizability in PAC-semantics. ITCS. ✓
* Kaså, M. (2015). A logic for trial and error classifiers. *JoLLI* 24(3). ✓
* Kelly, K. (1996). *The Logic of Reliable Inquiry*. OUP. ✓
* Kelly, K. (2004). Uncomputability: the problem of induction internalized. *TCS* 317:227–249. ✓
* Kelly, K. (2007). Ockham's razor, empirical complexity, and truth-finding efficiency. *TCS* 383:270–289. ✓
* Khardon, R., Roth, D. (1997). Learning to reason. *JACM* 44(5):697–725. ✓
* Khardon, R., Roth, D. (1999). Learning to reason with a restricted view. *MLJ* 35:95–116. ✓
* Kosoy, V. (2017–19). Forecasting using incomplete models. arXiv:1705.04630. ✓
* Mercier, A., Lopez-Wild, J., Spiegel, E. (2026). At the edge of Putnam's program: limitative results for computable inductive logics. arXiv:2606.00363. ✓
* Michael, L., Valiant, L. (2008). A first experimental demonstration of massive knowledge infusion. KR 2008. ✓
* Osherson, D., Stob, M., Weinstein, S. (1986). *Systems That Learn*. MIT Press. ✓
* Osherson, D., Weinstein, S. (1986). Identification in the limit of first order structures. *JPL* 15:55–81. ✓
* Osherson, D., Weinstein, S. (1989). Paradigms of truth detection. *JPL* 18:1–42. ✓
* Predd, J., et al. (2009). Probabilistic coherence and proper scoring rules. *IEEE TIT* 55. [mem]
* Putnam, H. (1963). "Degree of confirmation" and inductive logic. In Schilpp (ed.), *The Philosophy of Rudolf Carnap*. ✓
* Putnam, H. (1965). Trial and error predicates and the solution to a problem of Mostowski. *JSL* 30(1):49–57. [std]
* Sawin, W., Demski, A. (2013). Computable probability distributions which converge on believing true Π₁ sentences will disbelieve true Π₂ sentences. MIRI TR. ✓
* Shoenfield, J. (1959). On degrees of unsolvability. *Annals of Math.* 69:644–653. [std]
* Solomonoff, R. (1964). A formal theory of inductive inference. *Inf. Control* 7. [std]
* Sterkenburg, T. (2019). Putnam's diagonal argument and the impossibility of a universal learning machine. *Erkenntnis*. ✓
* Valiant, L. (2000). Robust logics. *AIJ* 117 (STOC 1999 version). ✓
* Valiant, L. (2006). Knowledge infusion. AAAI. ✓
* Zhang, H., et al. (2023). On the paradox of learning to reason from data. IJCAI. ✓

---

## Verification log

One independent adversarial referee checked:
* Lemma A, Prop C, Theorems D and D′, the Theorem G table and the remark after it, Lemma K, Prop H, Lemma E′ and Corollary F;
* the §4.5 claims about detecting invalid rules;
* the glosses in §0, §7, §8 and §9 that restate these.

The full report is in `../verification/L3-verification.md`.

How I checked:
* I re-checked every issue by hand.
* I re-ran `L3-scripts/axiom_induction_coherence.py` and got the same output.
* I wrote an independent simulation of the referee's Σ₂ construction, `L3-scripts/sigma2_weak_coherence.py`, and ran it on 4 seeds plus one long-horizon re-run. It found 0 pairwise coherence violations, and every false sentence is at 0 at each of its change stages. Every true sentence that was still below 1 at T = 2500 was blocked only by a false competitor whose next change had not yet occurred, and it reached 1 by T = 9000 on the same instance.
* I checked the Lemma E′ counterexample and the §4.5 threshold numerically.
* I confirmed the statement of LI Thm 4.5.4 against a search-result snippet; the full text was not reachable.

Numbering is unchanged. Materially changed items are marked "(revised after verification)".

**Fatal issue (genuine, fixed by retraction and replacement).**

| # | item | verdict | action |
|---|---|---|---|
| R1 | Remark "Credences" after Thm G ("row (f) achievable only incoherently; coherent row is (g)"); L3-T2 headline "ceiling Π₃ → Δ₂"; §0 #3; §9 #4 | **Genuine.** Thm D rules out row (f) only on classes that contain Π₁ and all of Π₂. The referee's construction, which I checked line by line, gives computable credences that are weakly coherent for *all* PA-incompatible pairs and Π₁-convergent, and that gradually verify the Σ₂ column. Th_Σ₂ is not Δ₂. Weakly coherent credences also trivially handle Σ₁, Π₁ and B(Σ₁). Separately, if limits exist then the row (f) success set is Π₂ (∀q∀s∃t≥s P_t > 1−q). So the Π₃ result needs credences that do not converge, and the Π₃-versus-Δ₂ comparison mixed the cost of convergence with the cost of coherence. | **Retracted** the remark and the slogan. **Thm D′ revised** into parts (a)–(d) plus an Open item. (a) Incoherent credences reach Π₂ convergently and Π₃ only non-convergently. (b) Weak coherence excludes the Π₂ and Π₃ columns, generalized via a new Remark after Thm D to any decidable C ⊆ Π₂ whose truths are not Σ₂. (c) Weak coherence leaves Σ₁, Π₁, B(Σ₁) and Σ₂, with the Σ₂ construction and full proof included. (d) Convergent credences have a Π₂ ceiling, coherent or not. Open: the exact class that weakly coherent credences can gradually verify. The referee's example {"W_e infinite"} *is* excluded for Π₁-convergent credences by the new Remark, and is open otherwise. Rewrote the "Credences" remark, §0 #3, §7 Q1, L3-T2 and §9 #4. Added the script. |

**Issues rated "ok" with optional fixes (applied).**

| # | item | verdict | action |
|---|---|---|---|
| R2 | Thm D | Correct. The proof uses weak coherence only with Π₁ π. | Hypothesis restricted to Π₁ π, which makes the theorem stronger. Added the convention that quantifier blocks may be empty (Π₁ ⊆ Σ₂ ∩ Π₂), with the strict-prenex alternative ∀y∃z θ. |
| R4 | Thm G table and proof sketch | Correct. Two undefined cases. | Set x_t := t+1 in (d) when every x ≤ t is refuted, and j_t := t+1 in (f) when no V_k outputs 0. Added the true/false argument for (f) and noted that the Π₂ credences converge. Label changed to "[std … proof sketch of standard results here]". |
| R8 | Cor F | Correct, given LI Thm 4.5.4. I confirmed the form from a search snippet: A ∈ BCS(P̄), constant b, W(A_n) ≥ b for all W ∈ PC(Γ). | §4.2 bullet restated with the theorem number, BCS, the constant b and PC(Γ). The old "Γ proves A_n ≥ b_n" paraphrase is flagged as loose. Cor F now cites Thm 4.5.4 and gives the proof via ‖A_n‖₁ = 2, P̄-generability and b = 0. "Valid" is replaced by "Γ-provable instances". Added a per-sequence scope note. |
| R10 | Lemma K | Correct; standard folklore. | Labelled "[std folklore; one-line proof here]". "Bounds its convergence time" is made precise as "bounds the stage of its last mind change". |
| R11 | Prop H | Correct. Its gloss was misleading. | The statement now requires *arbitrary* queries, answered true or false, and a caveat says a computable positive-only stream adds nothing. The proof adds "≤_T ∅^(n+1) = Δₙ₊₂ (Post)". Replaced "which in effect means trusting stronger theories" with "no consistent r.e. theory provides this; stronger r.e. theories add speed, not limit power". |

**Minor issues (all genuine, all fixed).**

| # | item | verdict | action |
|---|---|---|---|
| R3 | Thm D′ (old) | Genuine on all four points. (i) It needs Π₁ ⊆ Π₂ or the vacuous-quantifier trick. (ii) The Π₃ credences do not converge, so convergent should be compared with convergent. (iii) T2 Thm 3.10(c)'s learner outputs only on Σ₁ ∪ Π₁; I checked T2. (iv) Q4 said "credence 0" where D gives liminf 0. | (i) Convention added (R2). (ii) Handled in the revised D′(a), (d). (iii) Reworded to "any weakly coherent credence extension of it to all sentences", with an explicit example of such an extension. (iv) Q4 and §0 #3 now say "liminf credence 0 (limit 0 if limits exist)" and "weakly coherent". |
| R5 | Lemma A and its glosses (§0 #2, L3-T1, Upshot, §9 #2) | Genuine on all five points. | (1) "iff"/"exactly when" weakened to a sufficient condition plus the failing regime, noting the fresh-randomness regime (iii). The Upshot's and §9 #2's "only" were also softened. (2) (ii) now covers ε = 0 with false instances off the support. (3) (i) states per-scene validity, with a note that per-(scene, instance) PAC guarantees do not supply it. (4) Rules are stated at sequent level, with truth of a sequent under all assignments, which covers discharge and eigenvariables. (5) (iii) now requires a verifier-enforced degree bound, a polynomial nonzero over the field used (freshman's-dream example over 𝔽_p), N fixed in advance, and |S_k| ≥ d·2^k/δ for the unbounded case. |
| R6 | Prop C | Genuine. The assumptions were unstated and "essentially Demski conditioned on the data" was loose. | Added standing hypotheses: μ normalized, each A consistent and containing the data, with the reasons (semimeasure gives Bel(⊤) < 1; inconsistent A gives Bel(⊥) > 0; consistency is Π₁ in arithmetic). The Demski phrase is replaced by "μ-mixture of Demski-type priors, one per hypothesis; need not equal Demski's prior conditioned on the data". Same change in §0 #8 and L3-T5. The script output is unchanged. |
| R7 | Lemma E′ and §9 #7 | Genuine. (a) The bound is the squared *Euclidean distance to K*, not Arb. (b) Dominance belongs to the projection, not to arbitrary arbitrage removal. Checked: x = (0.6, 0.6), Arb = 0.2; moving to (1,0) gives Brier 2.0 in world (0,1), versus 0.52 before and 0.5 for the projection. | (a) Wording fixed. (b) A scope paragraph with the counterexample was added, and §9 #7 and §0 #5 were fixed. Also **added the converse**, which I proved: if the actual world is outside 𝒲, its indicator v ∉ K (0/1 vectors are extreme points of the cube), and projecting x = v strictly hurts. So "projection never hurts in the actual world" holds iff the constraints are sound. |
| R9 | §4.5 "Detection of invalid rules"; §0 #6; L3-T6(b) | Genuine on all four points. | (1) The inequality is corrected to δ < p. (2) The bankruptcy claim is withdrawn. The text now says that prices reveal the violation (P(γ_n) − P(φ_n) → 1), while bankruptcy is conjecture L3-T6(b), because per-instance losses → 0 and may be summable. §0 #6 now matches. (3) Threshold trades are replaced by the continuous ramp h(u) = min{1, max{0, u/ε − 1}}. (4) "Invisible" is restricted to failures that B does not refute, with the example ∃x (x+1=0), which is refutable in Q. "T_r never loses" is changed to "need not lose". |

**Items whose statement or proof changed non-trivially (to re-verify):**
* Thm D′, including the new Σ₂ construction and its proof.
* The "Credences" remark after Thm G.
* L3-T2, and the glosses that restate it (§0 #3, §7 Q1/Q4, §9 #4).
* Thm D: Π₁-premise hypothesis, the convention, and the Remark that "the proof gives more".
* Lemma A: the sequent-level and per-scene hypotheses, and the (iii) conditions.
* Lemma E′: the converse and the scope.
* The §4.5 detection claims and the trading rule.
* Cor F: the precise citation.
