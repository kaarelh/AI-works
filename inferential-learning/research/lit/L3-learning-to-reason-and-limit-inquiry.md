# L3 — Learning to reason, logical uncertainty, and the learning theory of inquiry

*Strand L3 of the inferential-learning project. Read `00-brief.md` first. Related memos: L5 §7 (incompleteness, limit learning), T2 §3.5 (arithmetic), L1 (Gold/Angluin), L2 (reliable/KWIK/Ville), L4 (Kelly–Ockham Π₁ policy), L10 (user's notes).*

**Status tags.**
* ✓ = bibliographic data, and where stated abstract-level content, checked by web search this session. Full texts were *not* reachable: arxiv.org, intelligence.org, ijcai.org, hutter1.net and eccc are blocked by the egress policy.
* [mem] = from memory, not re-checked.
* [unverified] = I could not check the exact form of this statement.
* [proved here] = a complete proof appears in this memo.
* [std] = textbook.

**Script.** `lit/L3-scripts/axiom_induction_coherence.py` checks Prop C.

---

## 0. Bottom line

1. **Three literatures.** Each formalizes a different part of "learning to reason":
   * **PAC-semantics** (Khardon–Roth, Valiant, Juba, Michael). Validity is "true in most *worlds* drawn from D", and learned rules are chained with additive error.
   * **Logical uncertainty** (Gaifman; Demski; Hutter–Lloyd–Ng–Uther; Garrabrant et al.). Credences on sentences, coherent in the limit, learned from a trusted deductive process.
   * **Formal learning theory of inquiry** (Putnam, Gold, Shoenfield, Kelly, Osherson–Stob–Weinstein, Magari's dialectical systems). Exactly which hypotheses can be decided, verified or refuted in the limit, and with how many mind changes.
   
   Our setup sits where the three meet. No one of them answers the user's question alone.
2. **Commitment-order lemma (Lemma A).** PAC-semantics' chaining lemma survives an adversarial prover iff the randomness is drawn *after* the rules are fixed and independently of the prover.
   * It holds for random *situations*: physics problems, and therefore export/bridge rules.
   * It fails for one fixed world with random *instances* of a schema, which is mathematics.
   * So H1 is right for math, while PAC-semantics is the right semantics for H6's export rules. That only holds if test situations follow the training distribution, and olympiad problems are chosen to break exactly that.
3. **Key question, arithmetic, unbounded compute** (Thm G, §5.2).
   * Δ₀ world feedback is computable, so it adds nothing. Coherence detection is Σ₁ search.
   * **Achievable:**
     * correct in the limit on every Boolean combination of Σ₁ sentences, with ≤ k mind changes for k Σ₁ components;
     * stable acceptance of *exactly* the true Σ₂ sentences;
     * credences converging to 1 on exactly the true Π₃ sentences (incoherently).
   * **Impossible:**
     * deciding Σ₂ or Π₂ truth in the limit;
     * stably accepting exactly the true Π₂ sentences;
     * **coherent** limit credences that converge to 1 on true Π₁ sentences, unless some true Π₂ sentence gets limit credence **0** (Thm D, a self-contained form of Sawin–Demski 2013).
4. **Rates.**
   * There is never a computable modulus of convergence on an undecidable class (Lemma K).
   * Meaningful rates are:
     * mind changes;
     * latency after a witness or proof appears;
     * cumulative-loss bounds of Solomonoff type, ≤ ln(1/w);
     * proof-length speed-up. Strengthening the trusted base by sound principles gives *non-recursive* speed-ups (Gödel 1936).
5. **The user's coherence loss is risk-free arbitrage** (Prop E, de Finetti). Coherentizing credences *strictly improves Brier accuracy in every world that satisfies the constraints* (Lemma E′).
   * This holds **only if the constraints are sound.**
   * That is the formal reason coherence must be applied to asserted claims in the actual context (H6, orchestrator §1).
   * It must never be computed from learned, untrusted rules.
6. **Rule-trader market** (§4.5). Learned rules belong among the *traders* of a logical-inductor-like market, never in its *deductive process*.
   * An LI already respects, asymptotically, every efficiently computable valid rule schema (Cor F).
   * It punishes rules whose failures are efficiently settled.
   * It can never punish rules whose failures are never settled: Σ₁-unsound or Π₂-unsound rules.
   * With log-utility traders the market is a Bayesian mixture in which wealth = posterior weight, so T1/L2's conservative acceptance is the natural certifying layer on top.
7. **Logical induction is not a truth-tracker on Π₁.** Non-dogmatism forces $P_\infty(\mathrm{Con(PA)})<1$ and $P_\infty(\neg\mathrm{Con(PA)})>0$ for every LI over PA [proved here from the cited theorem]. This sharpens L5 §7.4's "[unverified; check]".
8. **The user's "Solomonoff axiom induction".**
   * Its true/false/independent read-out is a Dempster–Shafer belief/plausibility pair.
   * "Renormalize" and "split independents 50/50" are incoherent (checked by script).
   * The coherent fix is a random completion per hypothesis, which is essentially Demski's (2012) prior conditioned on the data (Prop C).
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

**Lemma A** [proved here; folklore]. Fix a scene distribution $D$.
* **(i) Random world, rules fixed first.** Let $R=\{\rho_1..\rho_m\}$ be a finite set of rules or schemas, fixed before $x\sim D$, with ρᵢ being $(1-\varepsilon_i)$-valid (a schema is valid in $x$ iff all its instances hold in $x$). Then
  $$\Pr_x\big[\exists \text{ an } R\text{-derivation (chosen after seeing } x), \text{ from premises true in } x, \text{ with a conclusion false in } x\big]\le\textstyle\sum_i\varepsilon_i .$$
* **(ii) Fixed world, random instances.** Let "validity" of a schema mean the fraction of its instances that are true under an instance distribution. Then no bound of type (i) holds against a prover who picks instances. A $(1-\varepsilon)$-valid schema with ε > 0 has false instances, and a prover who can find them breaks soundness with probability 1.
* **(iii) Fresh randomness per check.** Suppose each claimed instance is checked with randomness drawn after the claim is committed (Schwartz–Zippel: a nonzero polynomial of degree $d$ vanishes at a uniform point of $S^n$ with probability ≤ $d/|S|$). Then each false claim passes with probability ≤ $d/|S|$, uniformly over adaptive provers. Over $N$ claims the bound is $Nd/|S|$.

*Proof.*
* (i) On the event "all ρᵢ hold in $x$", which has probability ≥ $1-\sum\varepsilon_i$, every $R$-derivation preserves truth in $x$.
* (ii) Take the adversary that outputs a false instance.
* (iii) Schwartz–Zippel and a union bound. ∎

**Upshot.**
* In **physics**, the uncertainty that matters for an export rule is over situations. Lemma A(i) makes PAC-semantics a *worst-case-over-derivations* semantics for bridges, with error = the sum of the validity defects of the rules in the fixed library.
* The caveat is **distribution shift**. Olympiad problems are selected to stress idealizations, so $D_{\rm test}\neq D_{\rm train}$ exactly where it matters.
* In **mathematics** there is one world. $(1-\varepsilon)$-validity of a sentence is 0/1, and Juba's implicit learning collapses to "proof from KB plus revealed facts".
* The only randomness that helps in math is fresh per-check randomness, as in (iii). This is why random evaluation is a sound world oracle for the algebra workhorse (orchestrator §3), while a learned verifier trained on samples is not: its "randomness" was drawn before the prover searched.

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

**Prop C** [proved here; examples machine-checked].
* **(i)** $\mathrm{Bel}(\varphi):=\mu\{A:A\vdash\varphi\}$ and $\mathrm{Pl}(\varphi):=1-\mu\{A:A\vdash\neg\varphi\}$ are a **Dempster–Shafer belief/plausibility pair** on the Lindenbaum algebra. The mass function is μ pushed forward to the focal sets $\mathrm{Mod}(A)$.
* **(ii)** Neither read-out is coherent in general.
  * **Renormalizing**, $P=p_T/(p_T+p_F)$, fails with $A_1=\{p,\neg q\}$ and $A_2=\{q\}$ at weight ½ each. It gives $P(p)=1$, $P(q)=\tfrac12$, $P(p\wedge q)=0$, violating $P(p\wedge q)\ge P(p)+P(q)-1$.
  * **Half-splitting**, $P=p_T+p_I/2$, fails already for the single hypothesis $A=\varnothing$. It gives $P(p)=P(p\wedge q)=P(p\wedge\neg q)=\tfrac12$.
* **(iii)** $P:=\sum_A\mu(A)\,\lambda_A$ is coherent and satisfies Bel ≤ P ≤ Pl, for any coherent measures $\lambda_A$ on the completions of $A$. Canonical choices for $\lambda_A$:
  * a Demski prior over $A$;
  * the limit of a logical inductor over $A$.

  This is the coherent version of his scheme. It is essentially Demski 2012 conditioned on the data.

*Proof.* (i) is the standard random-set representation. (ii) is direct computation, confirmed by `L3-scripts/axiom_induction_coherence.py`. (iii) Each $\lambda_A$ gives 1 to everything $A$ proves and 0 to everything $A$ refutes. Mixtures of coherent measures are coherent. ∎

The same picture answers his `logic/logical induction.md` question ("why probabilities on propositions rather than joint distributions?"). A *coherent* $P$ on the whole sentence algebra *is* a joint distribution, namely a measure on the Stone space of completions, and $P(A\leftrightarrow B)$ distinguishes his two cases. Only incoherent finite-time approximations lack a joint distribution.

### 3.4 The Π₁/Π₂ trilemma

**Sawin & Demski, "Computable probability distributions which converge on believing true Π₁ sentences will disbelieve true Π₂ sentences"**, MIRI technical report (result from a July 2013 workshop; released 2014) ✓ (abstract):
* Π₁-convergence plus weak coherence ("if φ ⇒ ¬ψ then lim sup P(t,φ)+P(t,ψ) ≤ 1") implies arbitrarily low limiting probabilities for some short true Π₂ sentences.
* The quantifier structure of their Theorem 1 is [unverified].

Here is a self-contained version.

**Theorem D** [proved here]. Let $P_t(\varphi)\in\mathbb Q\cap[0,1]$ be computable uniformly in $t,\varphi$. Suppose:
* **(Π₁-convergence)** $\lim_tP_t(\pi)=1$ for every true Π₁ sentence π;
* **(weak coherence)** $\limsup_t\,(P_t(\pi)+P_t(\varphi))\le1$ whenever $\mathrm{PA}\vdash\pi\to\neg\varphi$.

Then infinitely many true Π₂ sentences φ have $\liminf_tP_t(\varphi)=0$. If limits exist, then $P_\infty(\varphi)=0$ for these sentences.

*Proof.*
1. Let φ = ∀x∃y R(x,y) be a **false** Π₂ sentence. Then some $x_0$ makes π := ∀y ¬R(x̄₀,y) a true Π₁ sentence with PA ⊢ π → ¬φ. Π₁-convergence and weak coherence give $\limsup P_t(\varphi)\le 1-\lim P_t(\pi)=0$.
2. Let $S=\{\varphi\in\Pi_2:\liminf_tP_t(\varphi)>0\}=\{\varphi:\exists q\in\mathbb Q^+\,\exists s\,\forall t\ge s\;P_t(\varphi)\ge q\}$. This set is Σ₂.
3. By step 1, $S$ contains no false Π₂ sentence.
4. If $S$ contained every true Π₂ sentence, then $\mathrm{Th}_{\Pi_2}(\mathbb N)=S$ would be Σ₂. But $\mathrm{Th}_{\Pi_2}(\mathbb N)$ is Π₂-complete, so it is not Σ₂ (Post) [std]. Contradiction.
5. "Infinitely many": a finite modification of $S$ is still Σ₂. ∎

**Reading: you can have at most three of the following.**
* computable (limit-computable) credences;
* coherence;
* Π₁-truth-convergence (a Π₁-Gaifman condition);
* non-dogmatism on true Π₂ sentences.

Logical induction keeps the first two and non-dogmatism, and drops Π₁-convergence (§4.3). The Popperian learner of T2 Thm 3.10(c) keeps Π₁-convergence, and is therefore dogmatically wrong somewhere in Π₂.

**Theorem D′** (coherence has a truth-tracking cost) [proved here]. Some computable *incoherent* credences converge to 1 on exactly the true Π₂ sentences, and even on exactly the true Π₃ sentences (Thm G(f)). By Theorem D, no weakly coherent credences can converge to 1 on all true Π₂ sentences.
* So **coherence lowers the ceiling for truth-tracking in the limit.**
* This is the probabilistic counterpart of L5's "bold in the limit ⇒ false".

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
* **Affine provability induction / affine coherence** ✓ (name), form [unverified]. If Γ proves $A_n\ge b_n$ for an e.c. sequence of affine combinations $A_n$ of sentences, then $P_n(A_n)\gtrsim_nb_n$.
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
* So coherentizing improves the Brier score by at least the squared incoherence **in every world satisfying the constraints**, in particular the actual world *if the constraints are sound*.
* If the constraints come from untrusted learned rules, or from an idealized context that the actual world violates (the air-pressure example), then the true world may lie outside $K$ and projection can make things worse. Minimal example: the unsound constraint "¬φ" gives $K=\{0\}$; with φ true and $x=0.9$, projection moves the Brier loss from 0.01 to 1.

This is a formal argument for orchestrator §1 and H6: coherence pressure should act only on claims asserted in the actual context, with constraints drawn from trusted rules.

### 4.5 A market of rule traders

**Design.**

1. **Trusted deductive process $D$.** It contains exactly:
   * Δ₀ facts computed (world feedback);
   * theorems of a small trusted base $B$ found by proof search;
   * optionally, externally certified facts.
   
   Nothing learned ever enters $D$.
2. **Rule traders.** For each candidate rule schema $r$, possibly with a guard $g$, there is a trader $T_r$ with budget $2^{-|r|}$. At day $n$ it enumerates poly(n) instances $(\gamma\Rightarrow\varphi)$ of $r$ and:
   * buys φ when $P_n(\varphi)<P_n(\gamma)-\epsilon$ (forward direction);
   * sells γ when $P_n(\gamma)>P_n(\varphi)+\epsilon$ (contrapositive direction).
   
   The contrapositive direction is where *blame* flows: a refuted conclusion pushes down the premises. This is the market form of T2's negative bags.
3. **Human trader.** $T_{\rm hum}$ buys the conclusions of human-written steps. Imitation is then a hypothesis whose reliability the market learns, not a premise.
4. **Remaining traders.** All other e.c. traders (or a rich restricted class) are included, so that the LI criterion and §4.2 apply.

**Corollary F** [proved here, *given* the affine provability induction statement of §4.2, which is unverified]. Let $(\gamma_n\Rightarrow\varphi_n)$ be an e.c. sequence of instances of $r$ with $\Gamma\vdash\gamma_n\to\varphi_n$ for all $n$. Then $\liminf_n\,(P_n(\varphi_n)-P_n(\gamma_n))\ge0$.

*Proof.* Apply affine provability induction to $A_n=\varphi_n-\gamma_n$, which is ≥ 0 in every world consistent with Γ. ∎

In words: **the market respects every efficiently enumerable valid rule before it has derived any instance.** Any explicit rule-trader layer therefore *exposes* what the LI criterion already enforces: the learned rules become inspectable as solvent traders.

**Detection of invalid rules.**
* If an e.c. infinite family of instances has Γ-provable premises and Γ-refutable conclusions, then provability induction gives $P_n(\gamma_n)\to1$ and $P_n(\varphi_n)\to0$. $T_r$ then realizes losses on each settled instance until its budget is exhausted.
* If $r$ fails with pseudorandom frequency $p$, credences converge to the frequency (§4.2). A threshold $1-\delta<1-p$ then never certifies $r$'s instances, which is the right behaviour.
* If $r$ fails only on a sparse set, or only on sentences $D$ never settles, then $T_r$ never loses. Examples:
  * a rule that yields ¬Con(PA);
  * a rule with false Π₂ conclusions.
  
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

**Theorem G** [proved here; Kelly 1996 / Shoenfield specialized]. Here "Th" means $\mathrm{Th}(\mathbb N)\cap C$.

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
  * (d) Let x_t be the least x ≤ t not yet refuted by any y ≤ t. Output 1 iff $x_t=x_{t-1}$.
  * (f) Write a Π₃ statement as $\bigcap_k S_k$ with $S_k$ Σ₂, and run limit-verifiers $V_k$. The credence is $1-2^{-j_t}$, where $j_t$ is the least k ≤ t with $V_k$ currently outputting 0. For a Π₂ sentence ∀x∃y R the credence is $1-2^{-k(t)}$, with k(t) = the length of the initial segment of x's already witnessed by stage t.
* **The entries "no"** use Post's hierarchy theorem: $\mathrm{Th}_{\Sigma_n}$ is Σₙ-complete and $\mathrm{Th}_{\Pi_n}$ is Πₙ-complete [std]. ∎

**Credences.** Row (f) is achievable only incoherently: Theorem D forbids it for weakly coherent credences. The coherent row is (g) together with Theorem D.

**Lemma K (no computable modulus)** [proved here]. Suppose $M$ decides $C$ in the limit and a computable τ bounds its convergence time. Then $\mathrm{Th}\cap C$ is decidable: output $M(\varphi,\tau(\varphi))$. ∎
* So for Π₁ sentences, convergence time is never computably bounded.
* Meaningful rates are therefore relative ones:
  * mind changes;
  * latency after the shortest witness, or after the shortest proof in the trusted base;
  * Solomonoff-type cumulative-loss bounds.
* **Speed-up** [std/mem; Gödel 1936; Buss, *JSL* 59 (1994)]. For $T\subset T'$ with $T'\vdash\mathrm{Con}(T)$, $T$-proof lengths are not bounded by any computable function of $T'$-proof lengths. So **trusting more (sound) principles is a non-recursive rate improvement** for verifying Σ₁ facts and refuting Π₁ claims.

**Prop H (feedback relativization)** [proved here]. Suppose the world answers truth-value queries for Σₙ sentences, i.e. an oracle for $\mathrm{Th}_{\Sigma_n}\equiv_T\emptyset^{(n)}$. Then decidability in the limit reaches exactly the Δₙ₊₂ sets. For example, a Σ₁ oracle lets a learner limit-decide B(Σ₂).

*Proof.* Relativized Shoenfield: limit-computable in $X$ iff $\le_TX'$, and $(\emptyset^{(n)})'=\emptyset^{(n+1)}$. ∎

So in math, world feedback adds power only if it is *non-computable*. An example is a trusted community that settles Σ₁ questions, which in effect means trusting stronger theories. In physics, feedback is genuinely external, so Kelly's empirical, Borel version applies.

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
  * coherent credences that are non-dogmatic (LI). These cannot also be Π₁-convergent unless they are dogmatic somewhere in Π₂ (Thm D).
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
* **Coherence + Π₁-convergence + limit-computability ⇒ credence 0 on some true Π₂** (Thm D).
* **LI is Σ₁-unsound in probability**: $P_\infty(\neg\mathrm{Con})>0$.
* **Market blindness.** A market cannot detect rule failures its deductive process never settles (§4.5).
* **Gaifman + coherence on arithmetic = truth**, which is not definable (Prop B).
* **Putnam/Sterkenburg.** No computable universal inductive method.
* **Coherentizing against unsound constraints can hurt accuracy** (Lemma E′).

**Correcting the brief's slogan.** "No computable learner is Σ₁-sound and complete for arithmetic" is not right as stated: PA itself is Σ₁-sound and Σ₁-complete. See §9.

---

## 8. Theorem candidates

* **L3-T1 (Commitment-order dichotomy; Lemma A)** [proved]. PAC-semantics is a worst-case-over-derivations semantics exactly when the world is random and the rules are fixed first. Paper role: the principled split between export rules (PAC) and in-context math rules (worst-case).
* **L3-T2 (Coherence/Π₁/Π₂ trilemma; Thm D, D′)** [proved]. Coherence lowers the truth-tracking ceiling from Π₃ (incoherent) to "Δ₂ with dogmatic Π₂ errors". This is a clean impossibility result about the user's coherence loss.
* **L3-T3 (Coherentizing is safe when the constraints are sound, and can hurt when they are not; Lemma E′)** [proved].
  * Consequence for contexts: a coherence penalty computed in an idealized context provably can increase error on actual-world claims.
  * Easy experiment: Brier score before and after projection, with true versus idealized constraints.
* **L3-T4 (Success table for coherence plus computation; Thm G, Lemma K, Prop H)** [proved; standard ingredients]. This answers L4-T7's conjecture.
* **L3-T5 (Axiom induction = belief functions; Prop C)** [proved].
  * Answers the user's own coherence question.
  * Suggests the coherent read-out: random completion per hypothesis, i.e. Demski's prior or LI over each A.
* **L3-T6 (Rule-trader market)** [Cor F proved modulo the cited statement; the rest is conjecture]. Statement to prove:
  * (a) valid e.c. rules are respected (Cor F);
  * (b) rules with e.c. settled counterexamples go bankrupt, within a time bound that depends on the settlement latency;
  * (c) unsettled failures are invisible;
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
     * coherent Π₁-convergent credences without dogmatic Π₂ errors.
2. **H1 refined.** PAC-semantics (Valiant/Juba) is *not* just "average-case, hence insufficient". It is sound against adversarial derivations when the randomness is over worlds and the rules are fixed first (Lemma A).
   * It is the right semantics for H6's export rules.
   * It is the wrong semantics for mathematical schemas.
   * Fresh-randomness checks (Schwartz–Zippel) are the only "statistical" world oracle that is worst-case-sound in math.
3. **H4 and orchestrator §4: "world feedback (computation) refutes false Π₁".** True, but for an unbounded learner this is redundant (Thm G; T2 Lemma 3.7).
   * World feedback adds *power* only if it is non-computable (Prop H).
   * It adds *speed* for bounded learners (LI timeliness; Lemma A(iii)).
4. **H4's "Kelly characterizes what can be learned in the limit".** Correct. Add:
   * gradual verification = Π₃, achievable only incoherently (Thm D′);
   * Kelly 2004 is the reference for treating computation as data;
   * Genin–Kelly supply the statistical/topological generalization needed for physics.
5. **L5 §7.4's "[unverified; check]" about $P_\infty(\mathrm{Con(PA)})$.** Settled: it is < 1 for every LI over PA, and $P_\infty(\neg\mathrm{Con})>0$ (§4.3(a)).
6. **Orchestrator §1 and H6 (coherence on asserted claims only).** Now has a formal justification: Lemma E′.
7. **The user's coherence loss should be formalized as arbitrage** (Prop E), i.e. as distance to the convex hull of trusted-consistent valuations. Do not formalize it as "count of derived contradictions": the arbitrage form is convex, graded, and has the accuracy-dominance property.
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
