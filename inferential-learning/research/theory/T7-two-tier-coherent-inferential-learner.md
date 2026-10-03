# T7. The two-tier coherent inferential learner: an end-to-end theorem for formal mathematics

*Theory thread T7 of the inferential-learning project. Read `../00-brief.md` first. This thread assembles T1 (soundness under search) and T2 (coherence as negative data) into one learning architecture with one guarantee. It cites their theorem numbers and does not redo their proofs. It also uses the counterexample-to-blame idea of `lit/L6` TC1 (= T4 Lemma 4.1) and follows `lit/L8` §11 item 7: refutation search is semi-decidable, so every bound below is stated relative to a bounded-size refutation oracle, and search cost is accounted for separately.*

*Status labels as in T1/T2: **[proved]** full proof here; **[cited]** known result, with **(unverified)** where from memory; **[sketch]**; **[conjecture]**; **[computed]** = checked by a script in `theory/T7-checks/`. **TOSU** = trivial once set up, i.e. the content is in the definitions.*

---

## 0. Summary

The orchestrator asked for one theorem of roughly this form. For every target calculus $R^\*$ with finite anchors, human data with sporadic noise below the margin and a systematic fallacy set $F$, and every adaptive prover:
* (i) the cautious assertion tier is sound at all times with probability $\ge1-\delta$;
* (ii) the number of detected incoherences is at most $\log_2(1/w(R^\*))$ plus a noise cost;
* (iii) after $N$ human steps it equals $\mathrm{Cl}(R^\*\cup F_{\rm coh})$;
* (iv) the residue $F_{\rm coh}$ is empty for CPC and complete decidable theories.

**The sketch is inconsistent as stated, and the way it fails is the main finding of this thread.** Three corrections are needed. With them, the theorem holds (Thm 4.1), and each correction is forced by a matching lower bound.

1. **Caution is relative to a class, and fallacies break realizability.** Positive data cannot tell a systematic fallacy from a rule (T1 Cor 6.5). So the realizable target of the positive-data version space is the *practice calculus* $R^P=R^\*\cup R_F$, not $R^\*$.
   * A tier that is cautious over that version space is sound *for practice*. It therefore asserts every frequent fallacy (Prop 2.2).
   * A tier that is cautious over hypotheses allowed to declare practice rules erroneous asserts nothing at all (Prop 2.4).
   * What works is **presumption of validity, applied only after an audit**. The assertion tier asserts the identified practice minus every schema the audit implicates. It waits until practice identification and the audit are complete, and abstains before that.
   * The waiting is necessary. No learner is truth-sound and complete before the rarest rule needed to refute a fallacy has been seen: it needs $N\ge\ln\frac{1-\delta'}{\delta}\big/\ln\frac1{1-\pi}$ samples (Thm 5.5).
2. **Coherence condemns sets, and the blame problem is real.**
   * Given bag-valued evidence, the practice rules that can be soundly condemned are *exactly* those in the union of the minimal conflicts. This is the hitting-set duality of model-based diagnosis (Reiter 1987) (Lemma 2.3).
   * Every genuine rule that lies in a minimal conflict is unassertable by *any* learner that is sound and sees the same evidence (Thm 5.6).
   * The extremal example is almost too clean. Take practice {modus ponens, affirming the consequent} with designated context $\{q,\ p\to q,\ p\to\bot\}$. The only conflict is {MP, AC}. The rival diagnosis, "MP is the fallacy", is the hypothesis that $\to$ means $\leftarrow$.
   * In a bounded Hilbert practice $\{K,S,MP,DN\}+AC$, coherence alone condemns $K$ and $MP$ as collateral [computed].
   * **World feedback with step-level blame (descent, L6 TC1), or a single bilateral denial, turns bags into singletons and removes all collateral** (Lemma 2.5, Prop 6.3). In CPC and arithmetic, computation refutes *nothing* that coherence does not (T2 Lemma 3.7, Post). What it adds is **localization**. This refines T2's "Δ₀ feedback is subsumed by coherence".
3. **Soundness must be relativized to refutation size.** No computable learner is sound at all times relative to full coherence and also complete (Thm 5.7, from Π₁-completeness). The right statement is soundness relative to $R^\*\cup R_{F^{(d)}_{\rm res}}$, where $F^{(d)}_{\rm res}$ is the set of fallacies with no size-$\le d$ refutation. Raising $d$ produces finitely many retractions.

**Main theorem (Thm 4.1, [proved] modulo T1 Thm 5.3/6.3).** The learner is the two-tier learner TTL$(d,\delta)$:
* positive-data module: per-tag trimmed lgg;
* audit: descent-first, with a minimal-conflict fallback;
* assertion tier: the audited practice, frozen after burn-in;
* sandbox: oligarchic halving for conjectures, isolated from the assertion tier.

There is an event $G$ with $\Pr(G)\ge1-\delta$, depending only on the human data, on which the following hold for every adaptive prover:
* **(i)** the assertion tier never accepts a step outside $R^\*\cup R_{F^{(d)}_{\rm res}}$;
* **(ii)** the audit uses at most $|F|+1$ calls to the refutation oracle on the descent path, never removes a genuine rule there, and the isolated sandbox incurs at most $\log_2(1/w(\Sigma^\*))$ detections, plus T2 Thm 2.5's false-alarm term;
* **(iii)** after $N_1=O\big(\Delta^{-2}\log(K/\delta)\big)$ human steps (noise-free: $O(\max_i(\pi_i\rho_i)^{-1}\log(K/\delta))$), the assertion tier equals $(\Sigma^\*\setminus\mathrm{Coll}_d)\cup F^{\rm surv}_d$ (bag fallback) or satisfies $\Sigma^\*\subseteq A\subseteq\Sigma^\*\cup F^{(d)}_{\rm res}$ (descent path);
* **(iv)** under a depth schedule it changes finitely often.

**Specializations.**
* **CPC** (Cor 6.2): with closed-formula evaluation as world feedback, the residue and the collateral are both empty. The learner converges to *exactly* the target calculus after $N_1$ steps, with exactly $|F|$ refutations, and is truth-sound throughout. With coherence alone it remains sound but can lose MP (Prop 6.3).
* **Complete decidable theories** (RCF, Presburger, ACF$_p$, DLO; Cor 6.5): exact, with the decision procedure as the world oracle.
  * Honest caveat: there the oracle is already a step checker. Learning buys identification of *which* calculus practice uses, and fast checking.
  * A restricted (rational, quantifier-free) oracle misses the fallacy "$x\cdot x=2\vdash\bot$", while coherence catches it.
* **Arithmetic** (Thm 6.6), with trusted logic and Δ₀ computation:
  * false Π₁ axioms are removed with singleton blame (Popper, via descent through ∀E);
  * false Σ₁ axioms such as $\neg\mathrm{Con(PA)}$ survive under presumption of validity, and are never asserted under a Popperian Σ₁-caution policy;
  * Turing chains are defeated by the frequency floor, and T2 Thm 3.9 shows the floor is necessary;
  * false Σ₂ axioms cannot be sorted by any computable policy (T2 Thm 3.10(e)).

**Each ingredient is necessary (§5).**

| drop | failure | result |
|---|---|---|
| positive data | refutational evidence is target-independent, so nested sound calculi cannot be told apart | Prop 5.1 |
| caution | the prover exploits an unaudited fallacy | Prop 5.2 (T1 Thm 3.1(b)) |
| negative evidence | fallacy and rule are indistinguishable | Prop 5.3 (T1 Cor 6.5) |
| structurality | instance-level refutation never converges; coherence is toothless | Prop 5.4 (T2 Prop 6.3) |
| burn-in | rare-refuter bound | Thm 5.5 |
| world/bilateral blame | MP–AC symmetry | Thm 5.6 |
| depth relativization | Π₁ barrier | Thm 5.7 |
| truthful designation | global sub-classicality | Prop 5.8 (T2 Prop 7.1) |

**Depth, honestly.**
* Most individual steps are TOSU, or are T1/T2 results transported.
* What is new:
  * the identification of *where* the sketched theorem breaks (Props 2.2, 2.4);
  * the audit principle and its burn-in lower bound (Thm 5.5);
  * the blame theorem, with its MP/AC (→ vs ←) witness (Thm 5.6);
  * the depth-relativization impossibility (Thm 5.7);
  * the observation that world feedback earns its keep by *localization*, not refutation;
  * the assembly into a single statement with explicit constants.
* None of it is deep mathematics. Its value is that it pins down, with matching lower bounds, what "a setup of the user's shape that provably works for formal math" can and cannot mean.

---

## 1. Setting

### 1.1 Steps, schemas, calculi

Everything in T1 §1 is in force:
* judgments $J$ (sequents, possibly with contexts);
* steps $s=(\Pi,j)$;
* closure $\mathrm{Cl}_R(B)$;
* $\mathrm{Sound}(R)=\{(\Pi,j):j\in\mathrm{Cl}_R(\Pi)\}$;
* T1 Lemma 1.1: a set of accepted steps $A$ is safe for derivations of every length iff $A\subseteq\mathrm{Sound}(R^\*)$.

Let $\mathcal S$ be a language of **schemas**: first-order terms with metavariables, as in T1 §1.3, with the decidable matching relation $s\in\mathrm{inst}(\sigma)$. A **calculus** is a finite set $\Sigma\subseteq\mathcal S$, and $R_\Sigma:=\bigcup_{\sigma\in\Sigma}\mathrm{inst}(\sigma)$.

### 1.2 The practice

**Definition 1.1 (practice).**
* The **target** is a finite calculus $\Sigma^\*$, with $R^\*:=R_{\Sigma^\*}$. Its members are the *genuine rules*.
* The **systematic fallacies** form a finite set $F\subseteq\mathcal S$ with $F\cap\Sigma^\*=\emptyset$. Each $\tau\in F$ has an instance outside $\mathrm{Sound}(R^\*)$.
* The **practice** is $\Sigma^P:=\Sigma^\*\sqcup F$, with $|\Sigma^P|\le K$.

**Definition 1.2 (human data).**
* Human steps are i.i.d. and tagged by a practice schema $i\in\Sigma^P$. Tag $i$ occurs with probability $\pi_i$.
* Given tag $i$, the step is a valid instance $\sigma_i\Theta$ with $\Theta\sim\Lambda_i$ with probability $1-a_i$. Otherwise it is an arbitrary step outside $\mathrm{inst}(\sigma_i)$, tagged $i$: *sporadic noise*.
* Write $\beta_i=\pi_i(1-a_i)$ and $\alpha_i=\pi_ia_i$.
* $\rho_i$ and $c_i$ are as in T1 Thm 5.3. The **margin** is $\Delta_i:=(\rho_i\beta_i-\alpha_i)/2$.

Assumptions:
* **(Floor)** Known constants $\Delta>0$, $c$, $K$, $\bar\alpha_i$ satisfy $\Delta_i\ge\Delta$, $c_i\le c$ and $\alpha_i\le\bar\alpha_i$, with $\Delta_i$ computed using $\bar\alpha_i$. Fallacy tags are subject to the floor too.

Fallacy tags are *latent but distinct*: a human committing AC "cites" a rule that is in fact AC. This is an idealization. If fallacies are cited under a genuine rule's name (AC cited as MP), the per-tag class must be unions of $\le k$ schemas, and T1 Thm 5.4 replaces Thm 6.3 below. Nothing else changes.

### 1.3 Evaluation: designated positions, the world, trusted steps

**Definition 1.3 (evaluation sources).**
* A finite set $\mathcal A$ of **designated positions** $[A:D]$: finite sets of asserted and denied judgments. The unilateral case is $D=\emptyset$, with ⊥ always counted as denied.
* A **world**: an evaluable fragment $D_W\subseteq J$ and a truth function $W:D_W\to\{0,1\}$ (e.g. evaluation of closed formulas, Δ₀ computation, a decision procedure). With no world, $D_W=\emptyset$.
* An optional set $T_{\rm rust}$ of **trusted steps**, e.g. the logical rules when only non-logical axioms are being learned.

**Definition 1.4 (evaluation, falsification).**
* Each position $[A:D]$ induces a partial evaluation $e_{[A:D]}$:
  * $e(j)=1$ if $j\in A$ or ($j\in D_W$ and $W(j)=1$);
  * $e(j)=0$ if $j\in D\cup\{\bot\}$ or ($j\in D_W$ and $W(j)=0$).
  
  The pure-world position is $[\emptyset:\emptyset]$.
* A step $(\Pi,j)$ is **falsified** under $e$ if $e(\pi)=1$ for all $\pi\in\Pi$ and $e(j)=0$.

**Assumption (WS): sound evaluation.**
* For every designated position $[A:D]$, the partial evaluation $e_{[A:D]}$ is well defined (no judgment receives both values).
* It extends to a total valuation $V_{[A:D]}:J\to\{0,1\}$ under which no step of $R^\*\cup T_{\rm rust}$ is falsified.
* Also $T_{\rm rust}\subseteq\mathrm{Sound}(R^\*)$.

(WS) implies that every designated position is in bounds for the target: $\bot\notin\mathrm{Cl}_{R^\*}(A)$ and $D\cap\mathrm{Cl}_{R^\*}(A)=\emptyset$. The reason is that $V$ makes $A$ true, preserves truth along $R^\*$-steps, and makes ⊥ and $D$ false.

In formal mathematics, $V$ is truth in the intended structure 𝔐. (WS) then says three things: the designated positions are true of 𝔐, $W$ is truth in 𝔐 on its fragment, and the target calculus and the trusted steps are 𝔐-sound. Without a world ($D_W=\emptyset$), (WS) is *equivalent* to each position being in bounds. For the converse direction, take $V:=$ the indicator function of $\mathrm{Cl}_{R^\*}(A)$, which is closed under $R^\*\cup T_{\rm rust}$, contains $A$, and misses ⊥ and $D$. The non-total version, "no step is falsified at evaluated nodes", is too weak: a derivation could pass through unevaluated nodes from true assertions to a false conclusion.

### 1.4 Refutations, conflicts, residue, collateral

**Definition 1.5 (refutations).**
* Let $B\subseteq\mathcal S$ be a finite set of schemas and $d\in\mathbb N$. A **$d$-refutation of $B$** is a derivation of total size $\le d$ (symbols in all its judgments) with these properties:
  * it is relative to some $[A:D]\in\mathcal A$, and every leaf $\ell$ (a judgment not produced by a step of the derivation) has $e_{[A:D]}(\ell)=1$, i.e. it is an assertion of the position or a $W$-true evaluable judgment;
  * every step is in $R_B\cup T_{\rm rust}$;
  * its conclusion $j$ has $e_{[A:D]}(j)=0$ (⊥, a denied judgment, or a world-false judgment).
  
  A single falsified instance of some $\sigma\in B$, for example a closed instance with $W$-true premises and a $W$-false conclusion, is the special case of a one-step derivation.
* $B$ is **$d$-clean** if it has no $d$-refutation.
* $\mathrm{Conf}_d:=\{C\subseteq\Sigma^P: C\text{ not }d\text{-clean}\}$ is upward closed. Its inclusion-minimal members $\mathcal C_d$ are the **minimal $d$-conflicts**.
* The **refutation oracle** $\mathrm{Ref}_d(B)$ returns a $d$-refutation of $B$, or NONE.

$\mathrm{Ref}_d$ is computable by brute force whenever instance membership and $W$ are decidable, because there are finitely many derivations of size $\le d$. Its cost is $\exp(O(d))$, and **it is accounted separately** (L8 §11.7).

**Definition 1.6 (residue, collateral, blame regimes).**
* **Residue at depth $d$:** $F^{(d)}_{\rm res}:=\{\tau\in F:\ \Sigma^\*\cup\{\tau\}\text{ is }d\text{-clean}\}$. These are the fallacies coherent with the target on the designated positions, and world-adequate, up to size $d$. Also $F_{\rm res}:=\bigcap_dF^{(d)}_{\rm res}$.
* **Survivors:** $F^{\rm surv}_d:=F\setminus\bigcup\mathcal C_d$.
* **Collateral:** $\mathrm{Coll}_d:=\Sigma^\*\cap\bigcup\mathcal C_d$, the genuine rules that lie in some minimal conflict.
* **(BI$_d$) blame identifiability:** $\mathrm{Coll}_d=\emptyset$.
* **(SB$_d$) singleton blame:** every member of $\mathcal C_d$ is a singleton. SB$_d$ implies BI$_d$, by Lemma 2.1(b).

$\Sigma^P$ is finite, so $\mathrm{Conf}_d$ stabilizes: there is $d_0$ with $\mathrm{Conf}_d=\mathrm{Conf}_{d_0}$ for all $d\ge d_0$. Write $d=\infty$ for the stable values.

### 1.5 Provers and soundness

Provers and soundness are as in T1 Def 1.2. The prover is adaptive and computationally unbounded, and knows $\Sigma^\*$, $F$, the learner's code and the history, but not the future data. A tier is **uniformly δ-sound relative to $S\subseteq\mathrm{Steps}$** if there is an event $G$ of probability $\ge1-\delta$, depending only on the human data, on which no prover ever gets a step outside $S$ accepted.

---
## 2. Five structural facts

### 2.1 Refutational evidence is one-sided and target-independent

**Lemma 2.1 [proved; TOSU].**
* **(a)** Every subset of $\Sigma^\*$ is $d$-clean for every $d$.
* **(b)** Every $C\in\mathrm{Conf}_d$ contains a fallacy.
* **(c)** $\mathrm{Conf}_d$, and every answer of $\mathrm{Ref}_d$, is a function of $(\mathcal A,W,T_{\rm rust},d)$ and of the queried schema set alone. It does not depend on which schemas are genuine.

*Proof.*
* (a) Let $B\subseteq\Sigma^\*$, and let π be a derivation relative to $[A:D]$, whose leaves all have $e$-value 1, using steps in $R_B\cup T_{\rm rust}\subseteq R^\*\cup T_{\rm rust}$. By (WS) there is a total $V$ that extends $e$ and falsifies no such step. By induction along π, every node is $V$-true: the leaves have $e$-value 1, hence $V$-value 1, and steps preserve $V$-truth. The conclusion is therefore $V$-true, so it is not $e$-false. Hence π is not a refutation.
* (b) Immediate from (a).
* (c) Definition 1.5 mentions only these data. ∎

So refutations can never condemn a subset of the target (one-sidedness). And two targets with the same practice receive *identical* refutation evidence on every query. Refutational channels can say only that a *set* of practice rules contains a fallacy. They can never say that a rule is genuine.

### 2.2 Caution over practice asserts the fallacies

**Proposition 2.2 [proved; TOSU].** Let the positive-data tier be the per-tag trimmed version space (T1 Thm 6.2) over the practice tags. On the event of T1 Thm 6.3 its accepted set is exactly $R^P=R_{\Sigma^P}$. In particular:
* it accepts an instance of every $\tau\in F$ that lies outside $\mathrm{Sound}(R^\*)$;
* an adaptive prover that queries that instance gets an invalid step accepted;
* in CPC with a complete $\Sigma^\*$, one such step makes every formula derivable (T1 Prop 2.3).

*Proof.* T1 Thm 6.3 applies tag by tag, and fallacy tags are tags like any other. ∎

This is the precise sense in which the requested statement "the cautious assertion tier is sound" is *false* without further structure. Caution is soundness *relative to the realizable class*. Systematic fallacies make the practice, not the target, the realizable object.

### 2.3 The sound blame set is the union of minimal conflicts

**Lemma 2.3 (hitting-set duality) [proved; computed].** Let $\mathcal U$ be finite. Let $\mathcal K$ be an upward-closed family of subsets of $\mathcal U$ with $\emptyset\notin\mathcal K$, and let $\mathcal C$ be its minimal members. Call $M\subseteq\mathcal U$ *clean* if $M\notin\mathcal K$. Then:
* **(a)** The maximal clean sets are exactly the complements of the minimal transversals (hitting sets) of $\mathcal C$.
* **(b)** An element $x$ lies in some minimal transversal iff it lies in some member of $\mathcal C$. Hence $\bigcap\{\text{maximal clean sets}\}=\mathcal U\setminus\bigcup\mathcal C$, and this intersection is clean.
* **(c)** The minimal transversal is unique iff every member of $\mathcal C$ is a singleton.

*Proof.*
* (a) $M$ is clean iff it contains no member of $\mathcal K$. By upward closure, this holds iff it contains no member of $\mathcal C$, i.e. iff $\mathcal U\setminus M$ meets every member of $\mathcal C$. Maximal clean sets thus correspond to minimal transversals.
* (b, ⇐) Let $x\in C\in\mathcal C$, and put $T:=(\mathcal U\setminus C)\cup\{x\}$. Let $E\in\mathcal C$.
  * If $E\not\subseteq C$, then $E$ meets $\mathcal U\setminus C$.
  * If $E\subseteq C$, then $E=C$ by minimality of $C$, so $x\in E$.
  
  So $T$ is a transversal, and it contains a minimal transversal $T'$. Since $T'$ meets $C$ and $T'\cap C\subseteq T\cap C=\{x\}$, we get $x\in T'$.
* (b, ⇒) If $x\in T$ for a minimal transversal $T$, then $T\setminus\{x\}$ is not a transversal. So some $E\in\mathcal C$ has $E\cap T=\{x\}$, and $x\in E$.
* (b, second claim) By (a), $x$ lies outside some maximal clean set iff $x$ lies in some minimal transversal. The intersection of clean sets is clean, because cleanness is closed downward.
* (c, ⇐) If all members are singletons $\{x_1\},\dots,\{x_r\}$, the only minimal transversal is $\{x_1,\dots,x_r\}$.
* (c, ⇒) Suppose $T$ is the unique minimal transversal. By (b), $T=\bigcup\mathcal C$. For each $x\in T$, minimality gives some $E\in\mathcal C$ with $E\cap T=\{x\}$. Since $E\subseteq\bigcup\mathcal C=T$, this means $E=\{x\}$. A member $C\in\mathcal C$ with $|C|\ge2$ would then strictly contain a singleton member, which contradicts minimality. ∎

[computed: `duality.py`, 4000 random families on ≤ 7 points, no failures.]

*Reading.*
* This is Reiter's (1987) theory of diagnosis from first principles, with the hitting-set duality between conflicts and diagnoses [cited; see also de Kleer & Williams 1987]. The dictionary:
  * components are practice schemas;
  * "abnormal" means fallacious;
  * conflicts are T2's negative bags;
  * diagnoses are the hypotheses about which practice rules are fallacies.
* Apply it with $\mathcal U=\Sigma^P$ and $\mathcal K=\mathrm{Conf}_d$, so that $\mathcal C=\mathcal C_d$. Every *maximal* candidate consistent with the evidence then keeps $\Sigma^P\setminus\bigcup\mathcal C_d$.
* So $\bigcup\mathcal C_d$ is exactly the set of practice schemas that a learner who presumes validity, and is cautious across the remaining ambiguity, must withhold.

### 2.4 The caution–presumption dilemma

Suppose the practice $\Sigma^P$ is known. The natural candidate class is
$$\mathcal V:=\{\Sigma\subseteq\Sigma^P\},$$
where a candidate Σ reads as "Σ is the target and the rest of the practice is fallacious". All candidates explain the positive data equally well, because the practice is the same. Let $\mathcal V_d$ be the $d$-clean candidates and $\mathcal V'_t$ the candidates consistent with the refutations *found by time t*.

**Proposition 2.4 [proved].**
* **(a) Caution without presumption is vacuous.** $\emptyset\in\mathcal V_d$ by Lemma 2.1(a), so $\bigcap_{\Sigma\in\mathcal V_d}R_\Sigma=\emptyset$. The version-space verifier over $\mathcal V$ never asserts anything.
* **(b) Presumption without audit is unsound.** Consider the verifier that asserts $\bigcap\{R_\Sigma:\Sigma\text{ maximal in }\mathcal V'_t\}$.
  * Before any refutation has been found, $\mathcal V'_t$ has the unique maximal member $\Sigma^P$, so the verifier asserts all of $R^P$.
  * If $F\not\subseteq F^{(d)}_{\rm res}$, some asserted step lies outside $\mathrm{Sound}(R^\*)$.
* **(c) Presumption after audit works.** Asserting $\bigcap\{R_\Sigma:\Sigma\text{ maximal in }\mathcal V_d\}$ means asserting $R_{\Sigma^P\setminus\bigcup\mathcal C_d}=R_{(\Sigma^\*\setminus\mathrm{Coll}_d)\cup F^{\rm surv}_d}$. Moreover $F^{\rm surv}_d\subseteq F^{(d)}_{\rm res}$.

*Proof.*
* (a) and (b) are immediate.
* (c) The first equality is Lemma 2.3(b) followed by the definitions. For the inclusion, let $\tau\in F\setminus F^{(d)}_{\rm res}$. Then $\Sigma^\*\cup\{\tau\}$ is not clean, so it contains some $C'\in\mathcal C_d$. Since $C'\not\subseteq\Sigma^\*$ by Lemma 2.1(a), $\tau\in C'$, and so $\tau\notin F^{\rm surv}_d$. ∎

*Remark 2.4′ (a Bayesian middle way) [sketch].* Put a prior $w$ on $\mathcal V$. Accept $s$ iff
$$w\{\Sigma\in\mathcal V'_t:s\notin R_\Sigma\}<w_0 .$$
In posterior terms this is an adaptive threshold $w_0/w(\mathcal V'_t)$.
* *Soundness.* By the argument of T1 Thm 4.1, this rule is sound at all times for every target with $w(\Sigma^\*\cup F^{(d)}_{\rm res})\ge w_0$, provided that set is clean.
* *Completeness under a product prior.* Let the prior make each practice rule fallacious independently with probability ε. Then a genuine ρ is asserted once every candidate keeping an incoherent fallacy has been refuted, provided roughly $\varepsilon<(1-\varepsilon)^{|\Sigma^\*|+|F_{\rm res}|}$.
* *Reading.* This is "presumption of validity" in quantitative form, and it waits for the audit automatically.
* *Limits.* Its guarantee covers only targets of prior mass ≥ $w_0$, and it cannot break the symmetry of Thm 5.6, where the rival diagnosis has the same prior mass. I do not develop it further. The audit-then-assert design below is simpler and has explicit constants.

### 2.5 Descent turns a refutation into singleton blame

Let $e^+$ be $e_{[A:D]}$ closed under two propagation rules through trusted steps:
* **forward:** if a trusted step has all its premises at value 1, its conclusion gets 1;
* **backward:** if a trusted step has conclusion value 0 and all but one premise at value 1, the remaining premise gets 0.

**Lemma 2.5 (descent; counterexample-to-blame) [proved].** Assume (WS). Then $e^+$ agrees with $V_{[A:D]}$ wherever $e^+$ is defined.

Let π be a refutation of $B$ (Def. 1.5) whose conclusion has value 0. *Descend* as follows. Start at the conclusion. At a node with value 0 produced by step $s$:
* if all premises of $s$ have value 1, output $s$;
* otherwise move to a premise with value 0.

Say the descent is *unblocked* if, at every visited node, either all premises have value 1 or some premise has value 0. If it is unblocked:
* **(a)** it outputs an untrusted step $s\in R_B$ whose premises are $V$-true and whose conclusion is $V$-false. So $s\notin R^\*$;
* **(b)** it uses at most $\mathrm{depth}(\pi)\cdot\varphi$ evaluations, where φ is the maximal fan-in;
* **(c)** every $\sigma\in B$ with $s\in\mathrm{inst}(\sigma)$ is a fallacy. Removing all of them removes no genuine rule (*certified singleton blame*).

*Proof.*
* $e^+$ agrees with $V$. The forward rule is sound because trusted steps preserve $V$-truth. The backward rule is sound for the same reason: if the remaining premise were $V$-true, the conclusion would be too.
* (a) The descent follows nodes of value 0 strictly downward, so it ends. Leaves of π have value 1, and every other node is the conclusion of some step, possibly a 0-premise step; a 0-premise step with conclusion 0 is output immediately. The output step has $V$-true premises and a $V$-false conclusion. By (WS) it is neither in $T_{\rm rust}$ nor in $R^\*$, so it is an untrusted step of $R_B$.
* (b) There is one evaluation per premise of each visited node.
* (c) If σ were genuine, then $s\in\mathrm{inst}(\sigma)\subseteq R^\*$, contradicting (a). ∎

This is L6 TC1 and T4 Lemma 4.1, with two additions. First, trusted steps carry values *backward* through unevaluable nodes; arithmetic needs this, because $\forall x\theta$ is not Δ₀ (§6.3). Second, item (c): blame lands on *schemas*, with no collateral. When the descent is blocked, all we have is the bag $\{\sigma\in B:\sigma\text{ used in }\pi\}$.

*The principle that emerges.* In CPC and in arithmetic, world feedback refutes nothing that coherence does not already refute (Post; T2 Lemma 3.7). Its whole added value is that descent makes its refutations *singletons*. **World feedback earns its keep by localization, not by refutation.**

---

## 3. The learner TTL$(d,\delta)$

### 3.1 Algorithm

*Inputs:*
* the floor constants $(\Delta,c,K,\bar\alpha)$;
* a refutation oracle $\mathrm{Ref}_d$ (with $\mathcal A,W,T_{\rm rust}$);
* a sandbox class $\mathcal H_S$ with prior $w$.

$\mathrm{Ref}_d$ returns the lexicographically least refutation among the smallest ones. This makes its answers independent of $d$ once $d$ exceeds the smallest refutation size.

**Phase 0** ($t<N_1$), where
$$N_1:=\Big\lceil\tfrac1{2\Delta^2}\ln\tfrac{(1+c)K}{\delta}\Big\rceil.$$
In the noise-free case use instead $N_1:=\lceil\lambda^{-1}\ln\frac{cK}{\delta}\rceil$, with a known $\lambda\le\min_i\pi_i\rho_i$ (T1 Thm 5.3). During Phase 0:
* the assertion tier **abstains**. A query is escalated to a human, or settled by $W$ if all its judgments are evaluable;
* human steps are recorded.

**At $t=N_1$:**
1. *Practice identification.* For each tag $i$ with $n_i>e_i$ samples, where $e_i:=\lfloor(\bar\alpha_i+\Delta)N_1\rfloor$, let
   $$\hat\sigma_i:=\mathrm{mgu}\{\mathrm{lgg}(P_i\setminus E):|E|=e_i\}.$$
   This is the most general common instance of the trimmed lggs, i.e. the schema whose instance set is the trimmed version space's accepted set. Let $\hat P:=\{\hat\sigma_i\}$.
2. *Audit.* Set $B:=\hat P$ and repeat:
   * Call $r:=\mathrm{Ref}_d(B)$. If $r=$ NONE, **return** $B$.
   * Descend on $r$ (Lemma 2.5). If the descent outputs $s$, set $B:=B\setminus\{\sigma\in B:s\in\mathrm{inst}(\sigma)\}$ and continue.
   * If the descent is blocked, **return** $B\setminus\bigcup\mathcal C_d(B)$, where $\mathcal C_d(B)$ is the set of minimal $d$-conflicts contained in $B$, computed by enumeration (*fallback*).
3. Let $A$ be the returned set, and **freeze** it.

**Phase 1** ($t\ge N_1$): the assertion tier accepts $q$ iff $q\in R_A$, which is decidable by matching. It may escalate other queries.

**Sandbox (all times).** This is oligarchic halving (T2 §2.2) over $\mathcal H_S$, for example over candidate generalizations of asserted schemas or candidate new rules.
* It announces the coalition-unanimous set $B_t=\bigcap S_t$, with $w(S_t)\ge\frac12w(\mathrm{VS}_t)$.
* A red team, which may be the prover or the learner's own search, exhibits refutations of $B_t$.
* Each refutation deletes the hypotheses containing it.
* *Isolation:* nothing from the sandbox enters $R_A$. A conjectured rule κ is promoted only as a *derived* rule, i.e. when each of its instances is derivable in $R_A$. This leaves $\mathrm{Cl}_{R_A}$ unchanged (T1 Lemma 1.1).

**Truth maintenance.** Lemmas cached in the assertion tier are $R_A$-derivations. If the audit is re-run at a larger depth (§4, part (iv)), invalidate every cached lemma that uses a removed schema (T2 Thm 2.2, Remark (b)).

### 3.2 Audit correctness

**Lemma 3.1 [proved].** Suppose $\hat P=\Sigma^P$.
* **(a) No descent blocked.** The audit returns a $d$-clean $A$ with $\Sigma^\*\subseteq A\subseteq\Sigma^\*\cup F^{(d)}_{\rm res}$. It uses at most $|F|+1$ calls to $\mathrm{Ref}_d$. Every successful call removes at least one fallacy and no genuine rule.
* **(b) Fallback triggered at stage $B_0$.** Then $\Sigma^\*\subseteq B_0$, and the output $A=B_0\setminus\bigcup\mathcal C_d(B_0)$ is $d$-clean and satisfies
  $$\Sigma^\*\setminus\mathrm{Coll}_d(B_0)\ \subseteq\ A\ \subseteq\ \Sigma^\*\cup F^{(d)}_{\rm res},\qquad \mathrm{Coll}_d(B_0):=\Sigma^\*\cap\textstyle\bigcup\mathcal C_d(B_0).$$
  If $B_0=\Sigma^P$, then exactly $A=(\Sigma^\*\setminus\mathrm{Coll}_d)\cup F^{\rm surv}_d$.

*Proof.*
* (a) *Invariant:* $\Sigma^\*\subseteq B$, by Lemma 2.5(c).
  * Each successful descent outputs an untrusted $s\in R_B$. So at least one $\sigma\in B$ has $s\in\mathrm{inst}(\sigma)$, and every such σ is a fallacy and is removed.
  * Hence there are at most $|F|$ removals, after which $\mathrm{Ref}_d$ returns NONE (we are assuming no blocked descent).
  * The returned $B$ is $d$-clean. For $\tau\in B\setminus\Sigma^\*\subseteq F$, the set $\Sigma^\*\cup\{\tau\}\subseteq B$ is clean, because cleanness is closed downward. So $\tau\in F^{(d)}_{\rm res}$.
* (b) $\Sigma^\*\subseteq B_0$ by the invariant. Lemma 2.3, applied to $\mathcal U=B_0$, shows that $A$ is the intersection of the maximal clean subsets of $B_0$, so it is clean. The left inclusion holds by definition.
  * For the right inclusion, let $\tau\in A\cap F$ and suppose $\tau\notin F^{(d)}_{\rm res}$.
  * Then $\Sigma^\*\cup\{\tau\}\subseteq B_0$ contains a minimal conflict $C'$, and $\tau\in C'$ by Lemma 2.1(a).
  * So $\tau\in\bigcup\mathcal C_d(B_0)$, contradicting $\tau\in A$.
  * The last sentence is Prop 2.4(c). ∎

*Cost accounting.*
* The descent path costs at most $|F|+1$ oracle calls and at most $|F|\cdot d\cdot\varphi$ evaluations.
* The fallback needs $\bigcup\mathcal C_d(B_0)$.
  * By brute force this takes at most $2^{|B_0|}$ oracle calls. Output-sensitive hypergraph dualization runs in quasi-polynomial time in input plus output (Fredman & Khachiyan 1996 [cited (unverified details)]), but the output can be exponential in $|F|$.
  * By Thm 5.6 the fallback's incompleteness is unavoidable; its *cost* is the price of bags.
* $\mathrm{Ref}_d$ itself costs $\exp(O(d))$ by enumeration, and is semi-decidable only as $d\to\infty$.

**Proposition 3.2 (mis-designated positions) [proved].** Suppose at most $m$ designated positions violate (WS). Modify the audit:
* run $\mathrm{Ref}_d$ separately for each position;
* remove a schema only when descents under at least $m+1$ distinct positions blame it. A pure-world falsification counts as $m+1$ votes when $W$ is trusted.

Then:
* no genuine rule is ever removed;
* at most $(m+1)|F|$ successful descents are used;
* fallacies falsifiable under at most $m$ positions join the residue.

*Proof.* A genuine step can be falsified only under a position that violates (WS). There are at most $m$ such positions, so a genuine rule never collects $m+1$ votes. ∎

The soft (multiplicative) version of this is T2 Thm 2.5. The global damage done by an undetected mis-designation is T2 Prop 7.1.

**Proposition 3.3 (sandbox isolation and budget) [proved; transport of T2 Thms 2.2 and 2.5].**
* **(a)** The assertion tier is a function of the first $N_1$ human steps and of the audit's oracle answers alone. No sandbox state, red-team action or prover action affects it. Promotion by derivation leaves $\mathrm{Cl}_{R_A}$ unchanged.
* **(b)** Let $\mathcal H_S$ contain a hypothesis $h_0$ that is clean at every depth, such as $R^\*=R_{\Sigma^\*}$ (Lemma 2.1(a)). Then for every red team:
  * the number of detections against the coalition is at most $\log_2(1/w(h_0))$;
  * with $m$ false alarms and penalty factor β it is at most $\big(\ln\frac1{w(h_0)}+m\ln\frac1\beta\big)/\ln\frac2{1+\beta}$.
* **(c)** Coalition unanimity is computable when $S_t$ is finite: $s\in\bigcap_{h\in S_t}h$ iff $s$ matches a schema of every $h$.
  * For schema-valued hypotheses, the intersection of instance sets is the instance set of the mgu (unification). This is the operation used in step 1 of the algorithm.
  * The idealization in T2's oligarchic halving is the *choice* of a finite $S_t$ with $w(S_t)\ge\frac12w(\mathrm{VS}_t)$. That requires upper approximations of $w(\mathrm{VS}_t)$, hence knowledge of which hypotheses are refuted, up to a tail of small mass.

*Proof.*
* (a) Holds by construction.
* (b) The proofs of T2 Thms 2.2 and 2.5 use only that the protected hypothesis is never deleted. A detection deletes only hypotheses that contain all the steps of an exhibited refutation, and $h_0$ contains no refutation at any depth.
* (c) Standard (Huet's unification; the Plotkin–Reynolds lattice). ∎

This is the answer to "how cautious acceptance interacts with the coalition": **it does not.** The coalition is bold, and its errors are bounded by halving. The assertion tier is cautious, and its soundness is certified by the audit. The only channel from the sandbox to the assertion tier is *derivation*, which cannot enlarge the closure. Re-deriving sandbox lemmas inside $R_A$ is what makes the separation safe. T2's truth-maintenance remark is the same point made across time.

---
## 4. The end-to-end theorem

**Theorem 4.1 (two-tier coherent inferential learning) [proved, modulo T1 Thms 5.3/6.3 and T2 Thms 2.2/2.5].**

*Assumptions:*
* (Floor) and the realizable tagged single-schema class (Defs 1.1–1.2);
* (WS) (Assumption in §1.3);
* $\mathrm{Ref}_d$ exact for size-$\le d$ refutations, with the tie-breaking of §3.1.

*Conclusion.* Run TTL$(d,\delta)$. There is an event $G$ with $\Pr(G)\ge1-\delta$, depending only on the first $N_1$ human steps, on which the following hold for every adaptive prover and every red team.

* **(i) Uniform soundness at all times.**
  * For $t<N_1$ nothing is accepted.
  * For $t\ge N_1$ every accepted step lies in $R^\*\cup R_{F^{(d)}_{\rm res}}$. So for every premise set $B$, the reasoner's derivable judgments satisfy $\mathrm{Cl}_{R_A}(B)\subseteq\mathrm{Cl}_{R^\*\cup R_{F^{(d)}_{\rm res}}}(B)$.
  * If $F^{(d)}_{\rm res}=\emptyset$, then $\mathrm{Cl}_{R_A}(B)\subseteq\mathrm{Cl}_{R^\*}(B)$: the reasoner is sound for the target against arbitrary search.
  * The tier is $d$-clean: no prover can ever exhibit a size-$\le d$ refutation of it.
* **(ii) Refutation budget.**
  * The audit uses at most $|F|+1$ calls to $\mathrm{Ref}_d$ on its descent path, and at most $|F|\,d\,\varphi$ evaluations. It removes no genuine rule there.
  * The sandbox suffers at most $\log_2(1/w(R^\*))$ detections, or $\big(\ln\frac1{w(R^\*)}+m\ln\frac1\beta\big)/\ln\frac2{1+\beta}$ with $m$ false alarms.
  * With up to $m$ mis-designated positions and the voting rule of Prop 3.2, at most $(m+1)|F|$ descents are used.
* **(iii) Convergence modulo the residue.** For $t\ge N_1$ the tier accepts exactly $R_A$, where:
  * if no descent is blocked: $\Sigma^\*\subseteq A\subseteq\Sigma^\*\cup F^{(d)}_{\rm res}$;
  * if the fallback is triggered at $B_0$: $\Sigma^\*\setminus\mathrm{Coll}_d(B_0)\subseteq A\subseteq\Sigma^\*\cup F^{(d)}_{\rm res}$, with $A=(\Sigma^\*\setminus\mathrm{Coll}_d)\cup F^{\rm surv}_d$ when $B_0=\Sigma^P$.
  
  So under (SB$_d$), or whenever no descent is blocked, the tier is **complete for the target**. It accepts every genuine step, and the only fallacies it accepts are residual ones: the target modulo the Kripkensteinian residue. The sample size is
  $$N_1=\Big\lceil\tfrac1{2\Delta^2}\ln\tfrac{(1+c)K}{\delta}\Big\rceil\quad\big(\text{noise-free: }\lceil\lambda^{-1}\ln\tfrac{cK}{\delta}\rceil,\ \lambda\le\min_i\pi_i\rho_i\big).$$
* **(iv) Depth schedule.** Re-run the audit on the frozen $\hat P$ at depths $d_1<d_2<\cdots$, with truth maintenance.
  * $A$ changes only finitely often, and is constant once $d\ge d_1^\*$, the largest minimal-refutation size of a non-clean subset of $\Sigma^P$.
  * At each stage, (i) holds with the current depth.
  * In the limit, the tier is sound relative to $R^\*\cup R_{F_{\rm res}}$.
* **(v) Uniformity.** $G$ is defined by the human data alone, and $\mathrm{Ref}_d$ and $W$ are deterministic. So (i)–(iv) hold simultaneously for all provers and red teams. There is no union bound over queries.

*Proof.*
* *Step 1: identification.* Let $G$ be the event of T1 Thm 6.3 at sample size $N_1$, with budgets $e_i=\lfloor(\bar\alpha_i+\Delta)N_1\rfloor$: for every tag $i$, at most $e_i$ invalid steps are tagged $i$, and the valid tag-$i$ samples are $e_i$-robustly generic.
  * In the proof of T1 Thm 6.3, replace $\alpha_i$ by $\bar\alpha_i\ge\alpha_i$ and $\Delta_i$ by $\Delta\le\Delta_i$. The invalid count has mean at most $\bar\alpha_iN$. Each witness count has mean at least $(\bar\alpha_i+2\Delta)N$. Hoeffding and a union bound give
    $$\Pr(G^c)\le\sum_i(1+c_i)e^{-2N_1\Delta^2}\le(1+c)Ke^{-2N_1\Delta^2}\le\delta.$$
  * On $G$, T1 Thm 6.2(b) shows that the trimmed verifier of tag $i$ accepts exactly $\mathrm{inst}(\sigma_i)$.
  * A finite intersection of instance sets with a common instance is the instance set of the mgu. So $\hat\sigma_i$ is $\sigma_i$ up to renaming, and $\hat P=\Sigma^P$.
  * In the noise-free case, T1 Thm 5.3 gives $\Pr(G^c)\le cKe^{-N_1\lambda}\le\delta$ instead.
  * $G$ depends only on the human data.
* *Step 2: audit.* On $G$, Lemma 3.1 applies to $\hat P=\Sigma^P$. This gives (iii), the cleanness claim in (i), and the audit part of (ii). Prop 3.2 gives the mis-designation clause.
* *Step 3: soundness.* Before $N_1$ nothing is accepted. After $N_1$ the accepted set is $R_A$ with $A\subseteq\Sigma^\*\cup F^{(d)}_{\rm res}$, so $R_A\subseteq R^\*\cup R_{F^{(d)}_{\rm res}}$. The closure inclusion is T1 Lemma 1.1, applied with the calculus $R^\*\cup R_{F^{(d)}_{\rm res}}$ as "target".
* *Step 4: sandbox.* Prop 3.3(b) with $h_0=R^\*$ gives the sandbox clause of (ii). Prop 3.3(a) shows that sandbox activity cannot affect (i).
* *Step 5: depth schedule.*
  * By the tie-breaking rule, each $\mathrm{Ref}_d(B)$ is constant for $d\ge$ the minimal refutation size of $B$, or is NONE for all $d$ if $B$ is clean at every depth.
  * There are only $2^{|\Sigma^P|}$ sets $B$. So the audit's whole computation, and hence $A$, is constant for $d\ge d_1^\*$, and changes at most at the finitely many thresholds below $d_1^\*$.
  * At each stage Steps 2–3 apply with the current $d$. ∎

**Corollary 4.2 (truth-soundness) [proved].** Suppose $R^\*$ is 𝔐-sound and every member of $F^{(d)}_{\rm res}$ is 𝔐-valid, which holds vacuously if $F^{(d)}_{\rm res}=\emptyset$. Then on $G$ the reasoner derives only 𝔐-consequences, at all times and against all provers.

**Remarks.**
1. *What is and is not certified.*
   * Genuine rules are never *certified* valid by anything in the architecture. Their assertion rests on positive data (anchoring with margin) plus presumption of validity after audit.
   * Fallacies are certified *invalid*, by descent, or implicated as a set, by conflicts.
   * This asymmetry is forced by Lemma 2.1: all non-imitative evidence is refutational.
2. *Realizability is load-bearing.* This is T1's weakness 1, unchanged. If the human calculus has a rule outside the class, Step 1 fails. Nothing downstream repairs that.
3. *Why freeze.* Freezing $\hat P$ at $N_1$ keeps the probability accounting to a single event.
   * Continuing to learn is possible: a union bound over $N\ge N_1$ costs an additive $\ln\frac1{1-e^{-2\Delta^2}}\approx\ln\frac1{2\Delta^2}$ inside the logarithm.
   * In that case the audit must be re-run whenever $\hat P$ changes.
4. *Before $N_1$.* Abstention can be softened. Steps all of whose judgments are evaluable can be settled by $W$ directly, and steps derivable in a *trusted base* can be accepted. Thm 5.5 shows that no learner can do much better on the fallacy-candidate schemas.

---

## 5. Each ingredient is necessary: minimax lower bounds

Throughout this section, "a learner" means any (randomized) procedure that receives the same kinds of information as TTL, possibly with a given channel removed.

**Proposition 5.1 (positive data) [proved; TOSU].** Let $\Sigma_1\subsetneq\Sigma_2$ be calculi such that every subset of $\Sigma_2$ is clean at every depth. Suppose a learner receives only refutation evidence: oracle answers on schema sets of its choice, but no human steps.
* Its view is the same under targets $\Sigma_1$ and $\Sigma_2$, by Lemma 2.1(c).
* So if it accepts a step of $R_{\Sigma_2}\setminus\mathrm{Sound}(R_{\Sigma_1})$ with probability $p$ under one target, it does so with probability $p$ under the other. It is either unsound for $\Sigma_1$ or incomplete for $\Sigma_2$.
* Example: $\Sigma_1=\{\wedge\mathrm I,\wedge\mathrm E_1,\wedge\mathrm E_2\}$ and $\Sigma_2=\Sigma_1\cup\{\vee\mathrm I_1\}$, with classical evaluation.

*Honest qualification.* This concerns soundness relative to the *human* calculus. In CPC, structurality plus closed evaluation decides schema validity (Lemma 6.1). A learner that wants only *truth*-soundness could enumerate schemas and assert the valid ones without any human data. Positive data are then needed only to say *which* valid rules the practice uses. In arithmetic, positive data are needed even for truth-completeness, because no refutational evidence ever certifies a true Π₁ axiom.

**Proposition 5.2 (caution) [proved].**
* **(a)** (T1 Thm 3.1(b).) Consider any learner that, at some history, accepts with probability $p$ a step outside $\bigcap\{\mathrm{Sound}(R_{\Sigma}):\Sigma\text{ a target consistent with all information so far}\}$. It is unsound with probability $p$ for some target in the class.
* **(b)** In particular, the following learners accept a falsified instance of some $\tau\in F\setminus F^{(d)}_{\rm res}$ *before* the refutation implicating τ is found:
  * presumption without audit (Prop 2.4(b));
  * the bold coalition used as the assertion tier: T2 Thm 2.2(iii) gives soundness only while $R^\*\in S_t$;
  * any MAP or MDL learner over practice (T1 Prop 2.4).
  
  An adaptive prover that knows $F$ queries such an instance at once. In CPC with $\Sigma^\*$ complete, that single step makes every formula derivable (T1 Prop 2.3). ∎

**Proposition 5.3 (negative evidence) [proved].** Let practice be $\{\wedge\mathrm I,\mathrm{AC}\}$ with fixed frequencies, and compare two worlds.
* $W_1$: classical tables. AC is a fallacy, the target is $\{\wedge\mathrm I\}$ and $F=\{\mathrm{AC}\}$.
* $W_2$: classical tables, except that → is read as ↔. AC is valid ("from $B$ and $A\leftrightarrow B$ infer $A$"), the target is $\{\wedge\mathrm I,\mathrm{AC}\}$ and $F=\emptyset$.

A learner without refutation evidence sees identically distributed data in both worlds. It is therefore unsound under $W_1$ or incomplete under $W_2$; this is T1 Cor 6.5 in two-world form. With evaluation, the closed instance $(\top,\ \bot\to\top\ /\ \bot)$ separates the worlds: under $W_1$ both premises are true and the conclusion is false, while under $W_2$ the premise $\bot\leftrightarrow\top$ is false. ∎

**Proposition 5.4 (structurality) [proved; TOSU].**
* (a) If hypotheses are instance sets rather than schemas, each refutation removes finitely many instances. A fallacy with infinitely many invalid instances then keeps some invalid instance asserted at every finite time, under any learner that asserts the practice minus the refuted instances.
* (b) Without uniformity, coherence is toothless (T2 Prop 6.3: $\mathbf C_2+\{\rhd p_{17}\}$).
* (c) Without structure, positive data cannot generalize at all: $\bigcap\mathrm{VS}(P)=P$ for exception-list classes (T1 §4 discussion). ∎

**Theorem 5.5 (burn-in is necessary: the rare refuter) [proved].** Let $0<\pi<1$, and let $\sigma,\tau,\rho$ be schemas such that:
* $\{\sigma,\tau\}$, $\{\sigma,\rho\}$ and $\{\tau\}$ are clean at every depth;
* $\{\rho,\tau\}$ is a $d$-conflict.

Compare two scenarios with the same $\mathcal A,W$.
* **Scenario 1:** target $\{\sigma,\rho\}$, $F=\{\tau\}$. Tags σ, τ, ρ have frequencies $(1-\pi)q_\sigma$, $(1-\pi)q_\tau$, $\pi$.
* **Scenario 2:** target $\{\sigma,\tau\}$, $F=\emptyset$. Tags σ, τ have frequencies $q_\sigma$, $q_\tau$.

The per-tag instance laws are the same in both. Then for every learner and every $t$: if the learner, under scenario 1, accepts at time $t$ some τ-instance $s\notin\mathrm{Sound}(R_{\{\sigma,\rho\}})$ with probability at most δ, then under scenario 2 it accepts $s$ at time $t$ with probability at most $\delta(1-\pi)^{-t}$. Hence completeness with probability $\ge1-\delta'$ at time $t$ in scenario 2 requires
$$t\ \ge\ \frac{\ln\frac{1-\delta'}{\delta}}{\ln\frac1{1-\pi}}\ \ge\ \frac{1-\pi}{\pi}\,\ln\frac{1-\delta'}{\delta}.$$

*Proof.*
* Let $E_t$ be the event that none of the first $t$ samples has tag ρ, so $\Pr_1(E_t)=(1-\pi)^t$.
* Conditioned on $E_t$, the first $t$ samples under scenario 1 are i.i.d. with exactly scenario 2's law, because the frequencies renormalize to $q_\sigma,q_\tau$.
* Oracle answers depend only on the queried schema sets (Lemma 2.1(c)). They are identical in both scenarios, even if the learner queries sets containing ρ.
* Hence $\Pr_1(\text{accept }s\text{ at }t)\ge(1-\pi)^t\Pr_2(\text{accept }s\text{ at }t)$.
* Such an $s$ exists. Otherwise every τ-instance would be derivable in $\{\sigma,\rho\}$, and the refutation of $\{\rho,\tau\}$ would become a refutation of $\{\sigma,\rho\}$ by T1 Lemma 1.1, contradicting cleanness.
* In scenario 2, $s$ is a genuine instance. ∎

*Concrete instance.* Use the context $A_1=\{q,\ p\to q,\ p\to\bot\}$ with no world. Take $\sigma=\wedge$I, $\tau=$ AC and $\rho=$ MP.
* The closure of $A_1$ under AC (with or without ∧I) is finite and contains no ⊥: it is $\{q,p\to q,p\to\bot,p\}$ plus conjunctions [computed].
* $\{\wedge\mathrm I,\mathrm{MP}\}$ is classically sound.
* AC then MP yields ⊥ in two steps.

So a practice in which **modus ponens is rare** cannot have its affirming-the-consequent habit soundly rejected before MP has been seen about $1/\pi$ times. The upper bound $N_1$ has the same order: in the noise-free case it is $\lambda^{-1}\ln(cK/\delta)$, with $\lambda\le\pi\rho$. This matches up to the $\ln K$ factor and the variability $\rho$.

**Theorem 5.6 (blame: world or bilateral evidence is necessary for completeness) [proved].** Let ρ, τ be schemas and $\Sigma_0$ a calculus such that:
* $\Sigma_0\cup\{\rho\}$ and $\Sigma_0\cup\{\tau\}$ are clean at every depth;
* $\{\rho,\tau\}$ is a $d$-conflict.

Compare scenario 1 (target $\Sigma_0\cup\{\rho\}$, $F=\{\tau\}$) with scenario 2 (target $\Sigma_0\cup\{\tau\}$, $F=\{\rho\}$), with equal tag frequencies. Then:
* the data and all oracle answers have identical laws in the two scenarios;
* every learner that is δ-sound in both scenarios accepts, in scenario 1, some genuine ρ-instance with probability at most δ;
* so $\rho\in\mathrm{Coll}_d$ is collateral for **every** sound learner, and TTL's fallback, which withholds $\bigcup\mathcal C_d$, is optimal.

*Proof.*
* The practice $\Sigma_0\cup\{\rho,\tau\}$ and its frequencies coincide in the two scenarios, and oracle answers are target-independent (Lemma 2.1(c)).
* Some ρ-instance $s$ lies outside $\mathrm{Sound}(R_{\Sigma_0\cup\{\tau\}})$. Otherwise, by T1 Lemma 1.1, the refutation of $\{\rho,\tau\}$ would transfer to the clean set $\Sigma_0\cup\{\tau\}$.
* Soundness in scenario 2 caps the probability of accepting $s$ at δ, and the same cap holds in scenario 1, where $s$ is genuine. ∎

*The MP/AC witness: → versus ←.* Take $\mathcal A=\{A_1\}$ with $A_1=\{q,\ p\to q,\ p\to\bot\}$, no world, $\Sigma_0=\emptyset$, $\rho=$ MP and $\tau=$ AC.
* $\{\mathrm{MP}\}$ is classically sound and $A_1$ is satisfiable.
* $\{\mathrm{AC}\}$ is clean, since the closure of $A_1$ under AC is $\{q,p\to q,p\to\bot,p\}$.
* AC then MP derives ⊥.
* Scenario 2 is literally the hypothesis that "→" denotes converse implication ←. Under that reading:
  * AC is modus ponens for ←;
  * MP is affirming the consequent for ←;
  * $A_1$ reads $\{q,\ q\supset p,\ \bot\supset p\}$, which is consistent.

**Coherence alone cannot tell which way the arrow points.** [computed: `hilbert_blame.py`: core $\{\mathrm{MP},\mathrm{AC}\}$ on $A_1$ has the single minimal conflict $\{\mathrm{AC},\mathrm{MP}\}$ and two diagnoses.]

The symmetry is broken by either of two things:
* world feedback: the closed instance $(\bot\to\bot,\ \bot\to(\bot\to\bot)\ /\ \bot)$ is falsified;
* a single denial: designate $[A_1:\{p\}]$. AC alone then derives the denied $p$, and the conflict becomes $\{\mathrm{AC}\}$.

Both make scenario 2 violate (WS) [computed: with positions $\{[A_1:p]\}$ the minimal conflicts are $\{\{\mathrm{AC}\}\}$ and the collateral is empty].

*A bounded Hilbert illustration* [computed, `hilbert_blame.py`, formulas with ≤ 7 leaves over $\{p,q,\bot\}$]. Take practice $\{K,S,MP,DN,AC\}$ with $\mathcal A=\{\emptyset,A_1\}$.
* The minimal conflicts are $\{\mathrm{AC},K\}$ and $\{\mathrm{AC},\mathrm{MP}\}$.
* The conflict $\{\mathrm{AC},K\}$ is the four-step derivation from ∅: $K$ gives $\bot\to(p\to\bot)$ and $(p\to\bot)\to(\bot\to(p\to\bot))$; AC gives $p\to\bot$; AC gives ⊥.
* The diagnoses are $\{\mathrm{AC}\}$ and $\{K,\mathrm{MP}\}$, so the collateral is $\{K,\mathrm{MP}\}$.

Two caveats.
* This is evidence relative to the bounded oracle, which is what Thm 4.1(iii) uses. I have *not* shown that the rival $\{S,DN,AC\}$ is clean at every depth. No 2- or 3-element matrix witnesses it [computed: `matrix_witness.py`], so the full-depth status is open.
* A prior that prefers fewer fallacies ("protect the centre", in Quine's sense) picks $\{\mathrm{AC}\}$ over $\{K,\mathrm{MP}\}$. In the core $\{\mathrm{MP},\mathrm{AC}\}$ case it is silent, unless it uses frequency. T5 Prop 4.2 shows that frequency does not track validity.

**Theorem 5.7 (depth relativization is necessary) [proved, modulo the standard encoding of T2 Thm 5.3(a)].** There is a uniformly computable family of practices $(\Sigma^P_e)_{e\in\mathbb N}$, with fixed $\mathcal A=\{[\emptyset:\emptyset]\}$ and no world, such that no computable learner achieves both of the following for all $e$, for any δ < 1/2:
* (a) δ-soundness at all times relative to the full-depth residue: $\Pr(\exists t:\text{accepts a step outside }R^\*\cup R_{F_{\rm res}})\le\delta$;
* (b) eventual completeness: $\Pr(\exists t\ \forall t'\ge t:\ R^\*\subseteq\text{accepted at }t')\ge1-\delta$.

*Proof.*
* *Construction.* Let $\Sigma_0$ be a finite elementary formal system with judgments $\mathrm{start}_e$. It simulates the universal machine on input $e$ from $\mathrm{start}_e$, and contains the rule "$\mathrm{halt}\vdash\bot$" (T2 Thm 5.3(a)).
  * Without a start judgment nothing is derivable, so $\Sigma_0$ is clean.
  * Let $\tau_e$ be the 0-premise rule "$\vdash\mathrm{start}_e$", and $\Sigma^P_e:=\Sigma_0\cup\{\tau_e\}$, with fixed frequencies.
  * If $\varphi_e(e)\!\uparrow$, the target is $\Sigma^P_e$ and $F=\emptyset$.
  * If $\varphi_e(e)\!\downarrow$, the target is $\Sigma_0$ and $F=\{\tau_e\}$. Here $\tau_e\notin F_{\rm res}$, since $\Sigma_0\cup\{\tau_e\}$ is incoherent.
* *Indistinguishability.* The data laws coincide. Oracle answers are the same, being a function of $e$ only.
* *Reduction.* Let $S=\{e:\exists t\ \Pr(\text{the learner accepts }\vdash\mathrm{start}_e\text{ by time }t)>1/2\}$.
  * If $\varphi_e(e)\!\uparrow$, then (b) and continuity of measure give $e\in S$.
  * If $\varphi_e(e)\!\downarrow$, then (a) gives $\Pr(\text{ever accepts})\le\delta<1/2$, so $e\notin S$.
  * So $S=\overline K$.
* *Contradiction.* For a computable learner with computable data laws and oracles, the probability of acceptance by time $t$ is a lower-semicomputable real. So $S$ is $\Sigma_1$. But $\overline K$ is not $\Sigma_1$. ∎

So TTL's form of soundness cannot be improved by any computable procedure: sound at time $t$ relative to $F^{(d_t)}_{\rm res}$, and relative to $F_{\rm res}$ only in the limit, with retractions. This is the Π₁-completeness of coherence (T2 Thm 5.3) turned into a statement about *anytime* soundness.

**Proposition 5.8 (truthful designation) [cited; T2 Prop 7.1 and Thm 2.5].**
* If a designated position violates (WS), descent can blame a genuine rule.
* Under structurality, a single classically inconsistent designated context forces the loss of a classical schema everywhere (T2 Prop 7.1).
* Prop 3.2 bounds the damage when at most $m$ positions are known to be suspect; T2 Thm 2.5 is the soft version.
* Nothing bounds the damage of an unknown number of mis-designations.

| ingredient dropped | failure mode | witness |
|---|---|---|
| positive data | target-independent evidence; nested sound calculi indistinguishable | Prop 5.1 |
| caution (audit-then-assert) | adaptive prover exploits an unaudited fallacy; trivialization in CPC | Prop 5.2 |
| negative evidence | fallacy ≡ rule (→ vs ↔ worlds) | Prop 5.3, T1 Cor 6.5 |
| structurality | instance-level refutation never converges; coherence toothless | Prop 5.4, T2 Prop 6.3 |
| burn-in | rare refuter: $t\gtrsim\pi^{-1}\ln(1/\delta)$ | Thm 5.5 |
| world / bilateral blame | MP–AC (→ vs ←) symmetry; collateral for every sound learner | Thm 5.6 |
| depth relativization | Π₁ barrier for anytime soundness | Thm 5.7 |
| truthful designation | global loss of classical schemas | Prop 5.8, T2 Prop 7.1 |

---
## 6. Specializations: what provably works for formal mathematics

### 6.1 Classical propositional logic

*Setting.*
* The language has ¬, ∧, ∨, →, ⊤, ⊥ over atoms. Judgments are formulas, or sequents with finite contexts (for natural deduction).
* All schemas are **pure**: they contain metavariables only and no object atoms. This is structurality; Prop 5.4 shows it cannot be dropped, and L5 Prop 2.5 shows that α-renaming alone is not enough.
* $\Sigma^\*$ is any finite set of classically valid pure schemas that is complete for classical consequence, e.g. a Hilbert system or a sequent-style natural deduction.
* $F$ is any finite set of classically invalid pure schemas.
* The world is $D_W=$ closed (atom-free) formulas, with $W=$ truth-table value. This is "computation".
* $\mathcal A$ consists of any truthful positions, possibly only $[\emptyset:\emptyset]$.

**Lemma 6.1 (closed-instance refutability; Post's substitution) [proved].** A pure schema τ is classically invalid iff some substitution of ⊤/⊥ for its metavariables yields a closed instance whose premises are $W$-true and whose conclusion is $W$-false. Such an instance has size $|\tau|$, and there are at most $2^{v(\tau)}$ candidates, where $v(\tau)$ is the number of metavariables.

*Proof.* (⇐) A falsified instance is an invalid instance. (⇒) Let $\tau\theta$ be an instance and $v$ a valuation making its premises true and its conclusion false. Put $c_x:=\top$ if $v(\theta x)=1$ and $c_x:=\bot$ otherwise. By induction on the structure of τ, every subformula of $\tau[c_x/x]$ has the same value as the corresponding subformula of $\tau\theta$ under $v$. Metavariable positions agree by the choice of $c_x$, and the connectives are truth-functional. Closed formulas take the same value under every valuation. ∎ (This is step 2 of T2 Thm 3.1.)

**Corollary 6.2 (TTL on CPC is exact, truth-sound and uses $|F|$ refutations) [proved].** Let $d\ge\max_{\tau\in F}|\tau|$, and let $\mathrm{Ref}_d$ try one-step world falsifications first. Then on $G$, with $\Pr(G)\ge1-\delta$:
* **(a)** The minimal conflicts are exactly the singletons $\{\tau\}$ for $\tau\in F$. So (SB$_d$) holds, $\mathrm{Coll}_d=\emptyset$ and $F^{(d)}_{\rm res}=\emptyset$.
* **(b)** The assertion tier abstains before $N_1$ and accepts exactly $R^\*$ afterwards. For every premise set $B$ the reasoner derives exactly $\mathrm{Cl}_{R^\*}(B)$, which is the set of classical consequences of $B$. This holds for derivations of any length and formulas of any size (T1 Cor 5.5), against any prover.
* **(c)** The audit makes $|F|+1$ oracle calls and at most $\sum_{\tau\in F}2^{v(\tau)}$ evaluations of closed formulas.
* **(d)** The tier is truth-sound at all times (Cor 4.2).

*Proof.*
* By Lemma 6.1, each τ has a one-step $d$-refutation, so $\{\tau\}\in\mathrm{Conf}_d$.
* Every member of $\mathrm{Conf}_d$ contains some fallacy τ (Lemma 2.1(b)), and hence contains the conflict $\{\tau\}$. So the minimal members are exactly these singletons.
* Each $\Sigma^\*\cup\{\tau\}$ is unclean, so $F^{(d)}_{\rm res}=\emptyset$.
* Thm 4.1(iii) gives $A=\Sigma^\*$. Completeness of $\Sigma^\*$ for classical consequence gives (b).
* Each audit iteration's descent is the one-step refutation itself, which removes exactly the falsified fallacy. ∎

[computed: `ttl_sim.py`. The practice has 9 genuine tagged ND-style rules (∧I, ∧E₁₂, ∨I₁₂, MP, MT, DS, DNE) and 4 fallacies with their own tags (affirming the consequent, denying the antecedent, conversion, "or as xor"). Sporadic noise α = 0.01 is mis-tagged at random, with trim budget $e=2$. There are 20 trials per $N$. The adversarial prover enumerates every step over a 10-formula pool and checks it by truth table.

| $N$ | positive-only cautious tier unsound | TTL unsound | TTL exact (= Σ*) | untrimmed + audit exact |
|---|---|---|---|---|
| 60 | 12/20 | **0/20** | 0/20 | 6/20 |
| 120 | 20/20 | **0/20** | 9/20 | 5/20 |
| 250 | 20/20 | **0/20** | **20/20** | 4/20 |
| 500 | 20/20 | **0/20** | 18/20 (the 2 failures are exactly the trials with > e noise on some tag) | 0/20 |

Reading the table:
* The positive-only cautious tier asserts the fallacies as soon as they are anchored (Prop 2.2).
* TTL is never unsound.
* The untrimmed learner is kept sound by the audit, which refutes the collapsed lgg of T1 Prop 6.1. But it loses whole tags, and loses more of them as $N$ grows.
* One bug found while writing the script is worth recording. With $n\le e$ samples, the trimmed version space contains the empty rule. Its intersection is ∅, *not* "everything". Coding $\bigcap\emptyset$ as "accept all" made TTL unsound in 12/20 trials at $N=60$.]

**Proposition 6.3 (coherence alone on CPC is sound but loses MP; one denial repairs it) [proved; computed].** Let $D_W=\emptyset$ and let $\mathcal A$ be truthful.
* **(a)** In the full language every τ ∈ F lies in some minimal conflict once $d\ge d_\tau$, with $\mathcal A\ni[\emptyset:\emptyset]$. The reason: $\langle\Sigma^\*\cup\{\tau\}\rangle$ is trivial (T2 Thm 3.1), so ⊥ is derivable from ∅. Hence $F^{(d)}_{\rm res}=\emptyset$ for large $d$, and TTL is truth-sound.
* **(b)** $\mathrm{Coll}_d$ can be non-empty, and then TTL's fallback is incomplete, necessarily so (Thm 5.6):
  * in the Hilbert practice, $\mathrm{Coll}=\{K,\mathrm{MP}\}$;
  * in the core $\{\mathrm{MP},\mathrm{AC}\}$ on $A_1$, $\mathrm{Coll}=\{\mathrm{MP}\}$.
* **(c)** *Bilateral repair.* Suppose that for each τ ∈ F, $\mathcal A$ contains a **counterexample position** $[\Pi':\{\varphi'\}]$, where $(\Pi',\varphi')$ is a falsified instance of τ. Then (SB) holds and $A=\Sigma^\*$.

*Proof.*
* (a) T2 Thm 3.1, then Lemma 2.1(b) and Prop 2.4(c).
* (b) Computed, together with Thm 5.6.
* (c) τ derives the denied φ′ from Π′ in one step, so $\{\tau\}\in\mathrm{Conf}$. Conclude as in Cor 6.2. ∎

*Reading.*
* In CPC, closed evaluation refutes *exactly* the schemas that coherence refutes; both refute all invalid ones, by Post.
* The whole difference between the channels is localization. Computation names the culprit; a contradiction only names a suspect list.
* A counterexample position is a syntactic object, a partial valuation. So "bilateral coherence with denials" and "world feedback with descent" are the same resource in two notations.

### 6.2 Complete decidable theories

*Setting.*
* $T$ is complete and decidable: RCF (Tarski), Presburger arithmetic (Presburger 1929), ACF$_p$, DLO, Tarski's elementary geometry [cited]. 𝔐 is a model of $T$.
* Judgments are sequents $\Gamma\vdash\varphi$ of first-order formulas, and $W(\Gamma\vdash\varphi):=[\mathfrak M\models\forall\bar x(\bigwedge\Gamma\to\varphi)]$, decidable by quantifier elimination. So $D_W=J$.
* $\Sigma^\*$ is a finite schema calculus, sound and complete for $T$-consequence on sequents, including →-introduction and ∀-introduction.

**Lemma 6.4 [proved].**
* (a) $\mathrm{Sound}(R^\*)$ is exactly the set of steps that preserve $W$-truth.
* (b) A schema is a fallacy iff it has a $W$-falsified instance. So every τ ∈ F has a smallest falsified instance, of some size $d_\tau$.

*Proof.*
* *All premises true.* Each premise is the universal closure of a sentence true in 𝔐. Since $T$ is complete, $T$ proves that closure, and $\Sigma^\*$ derives the premise. So $\mathrm{Cl}_{R^\*}(\Pi)=\mathrm{Cl}_{R^\*}(\emptyset)$, which is the set of $W$-true sequents. Then $j\in\mathrm{Cl}_{R^\*}(\Pi)$ iff $W(j)=1$.
* *Some premise false.* Say $\Gamma\vdash\varphi$ is false. Using →I and ∀I, $\Sigma^\*$ derives from it the sentence $\forall\bar x(\bigwedge\Gamma\to\varphi)$. This sentence is false, so $T$ refutes it and $\Sigma^\*$ derives its negation. Hence ⊥, and then everything, is derivable: $\mathrm{Cl}_{R^\*}(\Pi)=J$.
* So $(\Pi,j)\in\mathrm{Sound}(R^\*)$ iff some premise is false or $j$ is true. This gives (a), and (b) follows. ∎

**Corollary 6.5 (TTL on complete decidable theories) [proved].** With $d\ge\max_\tau d_\tau$, everything in Cor 6.2 holds verbatim:
* (SB) holds;
* $F^{(d)}_{\rm res}=\emptyset$;
* $A=\Sigma^\*$;
* the tier is truth-sound at all times on $G$;
* the audit makes $|F|+1$ oracle calls.

*Remarks.*
1. **Why learn at all?** Here $W$ is already a sound and complete step checker, so learning is not needed for epistemic access. TTL adds two things.
   * It identifies *which* calculus the practice uses.
   * It makes deployed checking fast: schema matching takes linear time, while $W$ costs doubly-exponential time for RCF (Davenport & Heintz 1988) and $2^{2^{\Omega(n)}}$ for Presburger arithmetic (Fischer & Rabin 1974) [cited]. The audit calls $W$ only on the few instances needed to falsify each fallacy.
   
   This is a real computational dividend, but a modest one, and I do not want to oversell it.
2. **A restricted oracle shows the division of labour.** Suppose $W$ evaluates only quantifier-free sentences with rational constants (numerical evaluation).
   * Lemma 6.4(b) then fails for RCF. The fallacy "$x\cdot x=1+1\vdash\bot$" ("2 has no square root") has no rational falsifying instance, so it is world-adequate for this oracle.
   * Designating the position $[\{x\cdot x=1+1\}:\emptyset]$, which is truthful in ℝ, makes it a singleton conflict.
   * So over ℝ, coherence catches what computation misses. Over ℕ the converse holds: Δ₀ computation adds no refutations beyond coherence (T2 Lemma 3.7), but it adds *localization* (§6.3).
3. **Physics relevance (L5 §3.4).** The RCF core of olympiad algebra and geometry is covered by Cor 6.5. Trigonometric and analytic steps are not: $(\mathbb R,+,\cdot,\sin)$ interprets ℤ and is undecidable.

### 6.3 Arithmetic: precisely what is and is not achieved

*Setting.*
* The language is that of PA, and 𝔐 = ℕ.
* $T_{\rm rust}$ is the rules of first-order logic. The logic is fixed and the learner learns non-logical axiom schemas; logic itself can be learned first, by §6.1 at the propositional level.
* $D_W=$ Δ₀ sentences, and $W$ is computation.
* $\mathcal A$ consists of truthful positions.
* A practice axiom schema is *genuine* iff all its instances are true in ℕ.
  * So $\Sigma^\*$ may contain PA together with true extras such as Con(PA), and (WS) holds with $V=$ truth in ℕ.
  * $F$ is the set of practice schemas with a false instance.

**Theorem 6.6 [proved, modulo cited Gödel II, Shoenfield's limit lemma and Post's hierarchy theorem].**
* **(a) False Π₁ axioms get singleton blame.** Suppose τ has a false instance $\forall\bar x\,\theta(\bar x)$ with θ in Δ₀, and let $\bar n$ be its least counterexample. The refutation is "$\vdash\forall\bar x\theta$ (by τ); $\forall$E (trusted) $\vdash\theta(\bar n)$", with $W(\theta(\bar n))=0$. Descent with the backward rule through ∀E (Lemma 2.5) blames τ alone. So $\tau\notin F^{(d)}_{\rm res}$ once $d\ge|\theta|+|\bar n|+O(1)$, where $|\bar n|=n+1$ in unary. No PA axiom is put at risk, and that is the point.
  * If the refutation were run by coherence through Q's axioms instead, the bag would be $\{\tau\}\cup$ (Q-axioms used). Q's axioms would then be collateral wherever the learner learns them rather than trusts them.
  * So *computation is subsumed by coherence as a source of refutations (T2 Lemma 3.7), but not as a source of blame.*
* **(b) Under presumption of validity, false Σ₁ axioms survive.** Take $\tau=$ "$\vdash\neg\mathrm{Con(PA)}$" with $\Sigma^\*=$ PA and $\mathcal A\subseteq$ Δ₀-truthful positions. Then $\Sigma^\*\cup\{\tau\}$ is clean at every depth. By Gödel II, PA + ¬Con(PA) is consistent. It proves every true Δ₀ sentence and no false one (T2 Lemma 3.7). So no derivation from truthful Δ₀ positions reaches a $W$-false judgment, and τ ∈ $F_{\rm res}$ is asserted forever.
* **(c) Popperian Σ₁-caution removes Σ₁ residue.** Modify the presumption for practice axioms of the form "$\vdash\exists\bar x\theta$" with θ in Δ₀: assert such an axiom only once $W$ has verified a witness.
  * False Σ₁ axioms, ¬Con(PA) included, are then never asserted.
  * True ones are asserted after a witness search. There is no uniform time bound, because witnesses can be arbitrarily large; this is the analogue of Thm 5.5.
  * This is T2 Thm 3.10(c), applied to practice instead of conjectures. It needs no designation of Con(PA).
* **(d) Beyond Σ₁ there is a permanent, provable residue.** False Π₂ or Σ₂ axioms consistent with $\Sigma^\*$ admit no finite refutation from Δ₀ evidence and survive.
  * No computable policy can sort the true from the false ones in the limit. The evidence here is computable practice data, $\mathrm{Ref}_d$ at every depth, and the Δ₀ oracle, so a limiting classification would be Δ₂ (Shoenfield). But Σ₂-truth is not Δ₂ (Post). This is T2 Thm 3.10(e).
* **(e) Turing chains need the floor, and with it they are learned.** Under (Floor), a practice has at most $\min(K,1/\pi_{\min})$ axiom schemas.
  * So $T_k=\mathrm{PA}+\mathrm{Con(PA)}+\dots+\mathrm{Con}(T_{k-1})$ is identified from positive data for every $k$ within the bound. Each $\mathrm{Con}(T_j)$ is genuine, and none is ever refuted.
  * T2 Thm 3.9 shows that without a floor, i.e. for a class containing $T_\omega$ and every $T_k$, no learner identifies the target from positive data, coherence and Δ₀ feedback.
* **(f) Reflection as designation.** If $\mathcal A$ asserts Con(PA), then $\neg\mathrm{Con(PA)}$ becomes a singleton conflict (T2 Thm 3.9(iii)). This is a justification beyond PA-proof, made explicit as a *designation* rather than smuggled in as a rule.

*Proof.*
* (a) Lemma 2.5: the backward rule assigns $\forall\bar x\theta$ the value 0, and τ's 0-premise step is output.
* (b) As stated.
* (c) By construction, using the Σ₁-completeness of $W$-witnessing.
* (d) For a computable family of Σ₂ candidate axioms $\varphi_e$, put "$\vdash\varphi_e$" in the practice. A learner that eventually removes it iff $\varphi_e$ is false decides Σ₂-truth in the limit; apply T2 Thm 3.10(e).
* (e) The floor bounds the number of tags, and T1 Thm 6.3 applies. The necessity is T2 Thm 3.9.
* (f) Immediate. ∎

*Summary for arithmetic.*

**Achieved:**
* exact, localized Popperian falsification of Π₁ errors;
* exclusion of Σ₁ errors under Σ₁-caution;
* identification of finite reflection-extended practices;
* soundness at all times relative to the stated residue.

**Not achieved, and provably not achievable by computable means:**
* elimination of false Σ₂ (and higher) axioms that are consistent with the practice;
* identification without a frequency floor;
* (under presumption of validity) elimination of false Σ₁ axioms such as ¬Con(PA).

The Gödel/Rosser alternatives are the Kripkensteinian residue of arithmetic (T2 Thm 6.4(iii)). TTL leaves it exactly where T2 located it, but now with explicit sample sizes, refutation budgets and soundness against adaptive provers.

---
## 7. Computational checks (`theory/T7-checks/`)

| script | what it checks | result |
|---|---|---|
| `duality.py` | Lemma 2.3: (a) maximal clean sets are complements of minimal transversals; (b) the union of minimal transversals equals the union of minimal members; (c) the minimal transversal is unique iff all minimal members are singletons | 4000 random families on ≤ 7 points, 0 failures |
| `hilbert_blame.py` | minimal conflicts and diagnoses for practice $\{K,S,MP,DN,AC\}$ under bounded closure (≤ 5 and ≤ 7 leaves, $|U|=323{,}175$ at 7) | $\mathcal A=\{\emptyset\}$: $\{\{AC,K\}\}$; $\mathcal A=\{\emptyset,A_1\}$: $\{\{AC,K\},\{AC,MP\}\}$, collateral $\{K,MP\}$; bilateral $[A_1:p]$: $\{\{AC\}\}$, collateral ∅; core $\{MP,AC\}$ on $A_1$: diagnoses $\{MP\}$ and $\{AC\}$; closure of $A_1$ under AC is $\{q,p\to q,p\to\bot,p\}$ |
| `matrix_witness.py` | is there a 2- or 3-element matrix validating S, DN and AC, with $A_1$ satisfiable and ⊥ undesignated? | none; full-depth cleanness of the rival diagnosis $\{S,DN,AC\}$ is left open |
| `ttl_sim.py` | end-to-end TTL on a propositional practice with fallacies and noise, against an exhaustive adversarial prover | the table in §6.1: TTL unsound in 0/80 runs, exact in 20/20 at $N=250$; the positive-only cautious tier is unsound in 72/80 |

---

## 8. In the user's vocabulary

**"Learning which inferences are valid."** The theorem splits this into three acts, each done by a different channel.
1. **Imitation finds the practice's rules.**
   * Generalizing human steps to the *least general* schemas that cover them, with trimming against sporadic slips, finds the schemas the practice actually uses. This includes its systematic fallacies, which are indistinguishable from rules at every rate (T1 Cor 6.5).
   * This is the only channel that says anything *positive* about a rule. Coherence and world feedback are purely refutational, and blind to which valid rules the practice happens to use (Lemma 2.1, Prop 5.1).
2. **Confrontation sorts the rules: an audit, not a loss.**
   * The learner presumes the practice valid. It then searches for derivations, from accepted positions, of ⊥, of a denied claim, or of a computably false claim.
   * Each such derivation shows that *some* rule used is wrong (T2's negative bag).
   * The sound response is to withhold every rule in a minimal such set (Lemma 2.3). When the derivation can be checked step by step against the world ("descent"), the bag shrinks to the one culprit.
   * A "coherence loss" that just penalizes having arguments for P and ¬P does the first half of this, and only the first half.
3. **Assertion comes last.** Steps are asserted only *after* the audit, and only after the practice has been seen enough to rule out a rare rule that would expose a fallacy (Thm 5.5).
   * The resulting checker cannot be fooled by any prover, however hard it searches (Thm 4.1(i)).
   * In propositional logic and in complete decidable theories it accepts *exactly* the valid steps (Cors 6.2, 6.5).
   * This is the user's success criterion 1, "a setup of this shape that provably works for formal math", in a precise form.
   * For arithmetic it works in Popper's sense and no further (Thm 6.6).

**"An argument is valid when it is a sequence of valid inferences."** This is T1 Lemma 1.1, and it cuts both ways.
* One accepted bad step poisons every argument.
* Chaining is also what lets a contradiction be traced back to a step.
* Descent is the user's own "go back to what caused [the contradiction]" (`how do i resolve contradictions, tensions?.md`), made into an algorithm with a guarantee.

**"Learning meanings."** Under an inferentialist reading, the asserted calculus is the learned inferential role. The theorem then says what imitation, coherence and the world each contribute to meaning.
* **Imitation** fixes which inferential role the community *uses*.
* **Coherence** fixes it only up to the choice of *which* member of each conflicting set to give up.
  * In the MP/AC example that choice is literally whether "→" means → or ←.
  * Every sound learner using coherence alone must abstain on modus ponens there (Thm 5.6).
  * The ambiguity is not a gappy-valuation phenomenon (T2 §4). It is a *blame* phenomenon: the community's practice is incoherent, and coherence does not say which half of it is the meaning.
* **The world** (computation, counterexample objects) or a **denial** settles the direction.
  * This is a precise sense in which the user's "hooking of a model onto the world" (L10 §1.1) is needed *beyond* inferential role. It is not needed to make the role coherent, but to make it *the intended one* when practice is self-conflicting.
  * The bilateralists' denials (Rumfitt, Restall) do the same job syntactically, because a counterexample position *is* a partial world (Prop 6.3(c)).
* **What remains** after all three is the Kripkensteinian residue $F_{\rm res}$: fallacies coherent with the rules and invisible to the available world.
  * It is empty for propositional logic and for complete decidable theories.
  * In arithmetic it contains the non-standard alternatives, e.g. ¬Con(PA) under presumption of validity. Removing them needs a *designated* reflection commitment or a Popperian asymmetry. Past Σ₁, nothing computable removes them.

**On "principled justification beyond proof".** A step accepted by TTL carries a three-part warrant:
1. it instantiates a schema the practice uses robustly (frequency margin, anchors);
2. that schema survived an audit of stated depth against stated designated positions and a stated world;
3. the argument is a chain of such steps.

None of the three parts is a proof of validity. Together they give a guarantee *relative to explicit parameters* $(d,\mathcal A,W,\delta)$. Raising $d$ can only retract warrants, finitely often (Thm 4.1(iv)), and no computable procedure can avoid that possibility (Thm 5.7). This matches the user's view that justification is an "infinite endeavor" (L10 §1.11), stated in a form where every intermediate stage is sound relative to what has been checked.

---

## 9. Honest assessment and open problems

**Depth.**
* Almost every step is TOSU, or is T1/T2 transported. The main theorem's proof is about one page given T1 Thm 6.3, T2 Thm 2.2 and Lemma 3.1.
* The contribution is diagnostic:
  * finding exactly where the natural statement breaks (Props 2.2 and 2.4);
  * the three forced corrections (audit-then-assert, blame, depth), each with a matching lower bound (Thms 5.5, 5.6, 5.7);
  * the localization principle (Lemma 2.5 and §6.1).
* Lemma 2.3 is classical (Reiter). Thm 5.7 is a routine reduction. Thm 5.6 is a two-point indistinguishability argument. Its interest lies entirely in the witness: MP/AC is → vs ←.

**Weak points.**
1. *Realizability and tags.* Everything rests on T1's tagged single-schema class with latent fallacy tags. Mis-cited fallacies (AC cited as MP) need per-tag unions (T1 Thm 5.4), whose escalation behaviour is only polynomially bounded under a conjecture (T1 Conj 3.8).
2. *The fallback's cost.* Computing $\bigcup\mathcal C_d$ can be exponential in $|F|$. I have no lower bound on its *query* complexity in the conflict-oracle model.
3. *The audit is offline.* Thm 5.5 says that some abstention is necessary. But the burn-in $N_1$ is set from *known* floor constants, as in PAC learning. A data-driven stopping rule with the same guarantee is open.
4. *(WS) is strong.* Designated positions must be truthful, and in formal mathematics they must be true of 𝔐. For physics (T3), designated positions are idealized chunks, and (WS) holds only for chunks certified consistent (T3 Thm 1.9(d)). Extending Thm 4.1 to T3's anchored contexts is the obvious next step.
5. *The Bayesian middle way* (Remark 2.4′) might give anytime soundness for high-prior targets without a burn-in. I sketched it but did not prove it.

**Open problems.**
1. **Query complexity of sound blame.** In the black-box conflict-oracle model, how many $\mathrm{Ref}$ calls does it take to compute $\bigcup\mathcal C_d$, as a function of $K$ and $|F|$? Is it polynomial when every minimal conflict contains at most one fallacy?
2. **Full-depth status of the Hilbert rival.** Is $\{S,DN,AC\}$ clean at every depth on $\{\emptyset,A_1\}$? If it is, Thm 5.6 applies to the bounded example at full depth. If it is not, find the shortest refutation.
3. **Blame with priors.** Characterize when a "fewest fallacies" prior picks the true diagnosis. Is there a natural structural condition, e.g. every fallacy lies in two conflicts whose genuine parts are disjoint?
4. **Coherence-witness size.** Bound $d_\tau$ for natural fallacies in first-order logic. T2 Cor 6.2 gives polynomial bounds for CPC; quantifier swap has none without a two-object designated context.
5. **Physics.** Run TTL with T3's anchored contexts as designated positions and T3's certified bridges as trusted steps. Does descent through bridges give singleton blame for export errors?

**Suggested experiments.**
* *Blame curve.* Generate random Hilbert-style practices with one injected fallacy. Measure the collateral fraction under (i) unilateral coherence, (ii) bilateral counterexample positions, (iii) closed evaluation. Prediction: (i) has positive collateral that grows with how central the refuting rules are; (ii) and (iii) have none.
* *Rare refuter.* Simulate Thm 5.5 with MP at frequency π. Show that every sound learner's time to accept AC's absence is about $\pi^{-1}\ln(1/\delta)$.
* *Exploitation.* Compare a neural step scorer trained on the same practice with TTL under an RL prover rewarded for deriving a target conclusion. The scorer accepts fallacies; TTL does not.
* *Arithmetic.* Inject a false Π₁ axiom and ¬Con(PA)-style Σ₁ axioms into a bounded-arithmetic practice. Verify singleton blame for the former, survival of the latter under presumption, and removal under Σ₁-caution.

---

## References

✓ = confident; (u) = details unverified, cited from memory.

* Davenport, J. H. & Heintz, J. (1988). Real quantifier elimination is doubly exponential. *J. Symbolic Computation* 5:29–35. ✓
* de Kleer, J. & Williams, B. C. (1987). Diagnosing multiple faults. *Artificial Intelligence* 32:97–130. ✓
* Fischer, M. J. & Rabin, M. O. (1974). Super-exponential complexity of Presburger arithmetic. *SIAM–AMS Proceedings* 7:27–41. ✓
* Fredman, M. L. & Khachiyan, L. (1996). On the complexity of dualization of monotone disjunctive normal forms. *J. Algorithms* 21:618–628. ✓ (u: exact bound form)
* Gödel, K. (1931); Rosser, J. B. (1936); Shoenfield, J. (1959); Post, E. (1921, 1948): as in T2's reference list.
* Huet, G. (1976). *Résolution d'équations dans des langages d'ordre 1, 2, …, ω*. Thèse d'État, Paris VII. (u)
* Plotkin, G. (1970); Reynolds, J. (1970): as in T1.
* Presburger, M. (1929). Über die Vollständigkeit eines gewissen Systems der Arithmetik ganzer Zahlen. ✓
* Reiter, R. (1987). A theory of diagnosis from first principles. *Artificial Intelligence* 32:57–95. ✓
* Restall, G. (2005); Rumfitt, I. (2000): as in T2.
* Tarski, A. (1948/1951). *A Decision Method for Elementary Algebra and Geometry*. RAND / Univ. of California Press. ✓
* Ville, J. (1939); Li, Littman & Walsh (2008); Rivest & Sloan (1988): as in T1.
* Internal: T1 (Lemma 1.1; Thms 3.1, 5.3, 5.4, 6.2, 6.3; Cor 6.5; Props 2.3, 2.4, 6.1); T2 (Lemma 3.7; Thms 2.2, 2.5, 3.1, 3.9, 3.10, 5.3, 6.4; Props 6.3, 7.1); T3 (Thm 1.9); T4 (Lemma 4.1); T5 (Prop 4.2); L5 (Prop 2.5, §3.4); L6 (TC1); L8 (§11.7); L10.
