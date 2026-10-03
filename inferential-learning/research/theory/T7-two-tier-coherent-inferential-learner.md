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
   * The waiting is necessary. No learner that is sound whether or not a schema is a fallacy can accept that schema before the rarest rule needed to refute it could have been seen: with $\delta+\delta'<1$ it needs $N\ge\ln\frac{1-\delta'}{\delta}\big/\ln\frac1{1-\pi}$ samples (Thm 5.5, a standard two-point rare-event bound).
2. **Coherence condemns sets, and the blame problem is real.**
   * Given bag-valued evidence, the practice schemas that can be soundly condemned *as schemas* are exactly those in the union of the minimal conflicts. This is the hitting-set duality of model-based diagnosis (Reiter 1987) (Lemma 2.3).
   * At stable depth, every genuine rule that lies in a minimal conflict has an instance that *no* learner sound in all admissible scenarios can accept (Thm 5.6(b)). So TTL's fallback is optimal among schema-level policies. *(Revised after verification:* at finite depth this can fail (Thm 5.6(c)), and individual instances shared with a rival diagnosis can still be asserted (Prop 2.4(c)).)
   * The extremal example is almost too clean. Take practice {modus ponens, affirming the consequent} with designated context $\{q,\ p\to q,\ p\to\bot\}$. The only conflict is {MP, AC}. The rival diagnosis, "MP is the fallacy", is the hypothesis that $\to$ means $\leftarrow$.
   * In a Hilbert practice $\{K,S,MP,DN\}+AC$, coherence alone condemns $K$ and $MP$ as collateral [computed at bounded depth; necessarily so at full depth by Thm 5.6(b)].
   * **World feedback with step-level blame (descent, L6 TC1), or a single bilateral denial, turns bags into singletons and removes all collateral** (Lemma 2.5, Prop 6.3). In CPC and arithmetic, computation refutes *nothing* that coherence does not (T2 Lemma 3.7, Post). What it adds is **localization**. This refines T2's "Δ₀ feedback is subsumed by coherence".
3. **Soundness must be relativized to refutation size.** No computable learner is sound at all times relative to full coherence and also complete (Thm 5.7, from Π₁-completeness). The right statement is soundness relative to $R^\*\cup R_{F^{(d)}_{\rm res}}$, where $F^{(d)}_{\rm res}$ is the set of fallacies with no size-$\le d$ refutation together with the target. Raising $d$ changes the tier only finitely often. *(Revised after verification:* the changes need not be retractions only. The tier is not monotone in $d$: a schema withheld as collateral at one depth can be restored at a larger one.)

**Main theorem (Thm 4.1, [proved] modulo T1 Thm 5.3/6.3).** The learner is the two-tier learner TTL$(d,\delta)$:
* positive-data module: per-tag trimmed lgg;
* audit: descent-first, with a minimal-conflict fallback;
* assertion tier: the audited practice, frozen after burn-in;
* sandbox: oligarchic halving for conjectures, isolated from the assertion tier.

There is an event $G$ with $\Pr(G)\ge1-\delta$, depending only on the human data, on which the following hold for every adaptive prover:
* **(i)** the assertion tier never accepts a step outside $R^\*\cup R_{F^{(d)}_{\rm res}}$;
* **(ii)** the audit uses at most $|F|+1$ calls to the refutation oracle on the descent path and never removes a genuine rule there. If the sandbox class contains a hypothesis $h_0$ clean at every depth (e.g. $R^\*$) with $w(h_0)>0$, the isolated sandbox incurs at most $\log_2(1/w(h_0))$ detections, plus T2 Thm 2.5's false-alarm term;
* **(iii)** after $N_1=O\big(\Delta^{-2}\log(K/\delta)\big)$ human steps (noise-free, with trim budget 0: $O(\max_i(\pi_i\rho_i)^{-1}\log(K/\delta))$), the assertion tier satisfies $\Sigma^\*\subseteq A\subseteq\Sigma^\*\cup F^{(d)}_{\rm res}$ (descent path) or $\Sigma^\*\setminus\mathrm{Coll}_d(B_0)\subseteq A\subseteq\Sigma^\*\cup F^{(d)}_{\rm res}$ (bag fallback at stage $B_0$), with $A=(\Sigma^\*\setminus\mathrm{Coll}_d)\cup F^{\rm surv}_d$ when the fallback triggers at $B_0=\Sigma^P$;
* **(iv)** under a depth schedule it changes finitely often.

**Specializations.**
* **CPC** (Cor 6.2): with closed-formula evaluation as world feedback, the residue and the collateral are both empty. The learner converges to *exactly* the target calculus after $N_1$ steps, with at most $|F|$ refutations, and is truth-sound throughout. With coherence alone it remains sound but can lose MP and K (Prop 6.3).
* **Complete decidable theories** (Cor 6.5, *conditional after verification*): exact, with the decision procedure as the world oracle, *provided* the target calculus is realizable in the schema class. ∀-elimination and the infinite axiom families of RCF, ACF$_p$ and Presburger arithmetic are not first-order patterns, so for the listed theories this proviso is open.
  * Honest caveat: there the oracle is already a step checker. Learning buys identification of *which* calculus practice uses, and fast checking.
  * A restricted (rational, quantifier-free) oracle misses the fallacy "$\vdash\neg\exists x\,(x\cdot x=1+1)$", while a designated truth catches it.
* **Arithmetic** (Thm 6.6), with trusted logic and Δ₀ computation:
  * false Π₁ axioms are removed with singleton blame (Popper, via descent through ∀E);
  * false Σ₁ axioms such as $\neg\mathrm{Con(PA)}$ survive under presumption of validity. They are never asserted under a Popperian Σ₁-caution policy, which is syntactic and so misses equivalent disguises;
  * finite reflection-extended practices (Turing chains $T_k$) are identified under the frequency floor, *given a realizable encoding of the induction schema* (revised after verification). Without a floor there is no uniform sample bound;
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
  * the audit principle; its burn-in lower bound (Thm 5.5) is a standard two-point rare-event argument, and only its reading (the rare *refuter* is the relevant event) is new;
  * the blame theorem, with its MP/AC (→ vs ←) witness and its stable-depth form (Thm 5.6);
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

When $D_W\neq\emptyset$ we assume $[\emptyset:\emptyset]\in\mathcal A$. Refutations are always relative to a designated position (Def 1.5), so without this convention world-only falsifications would not count *(added after verification)*.

**Definition 1.4 (evaluation, falsification).**
* Each position $[A:D]$ induces a partial evaluation $e_{[A:D]}$:
  * $e(j)=1$ if $j\in A$ or ($j\in D_W$ and $W(j)=1$);
  * $e(j)=0$ if $j\in D\cup\{\bot\}$ or ($j\in D_W$ and $W(j)=0$).
  
  The pure-world position is $[\emptyset:\emptyset]$.
* A step $(\Pi,j)$ is **falsified** under $e$ if $e(\pi)=1$ for all $\pi\in\Pi$ and $e(j)=0$.

**Assumption (WS): sound evaluation** *(revised after verification)*.
* For every designated position $[A:D]$, the partial evaluation $e_{[A:D]}$ is well defined (no judgment receives both values).
* It extends to a total valuation $V_{[A:D]}:J\to\{0,1\}$ under which no step of $R^\*\cup T_{\rm rust}$ is falsified.

An earlier version added a third clause, $T_{\rm rust}\subseteq\mathrm{Sound}(R^\*)$. Nothing uses it. It also fails in §6.3, where $R^\*$ consists of non-logical axioms and $T_{\rm rust}$ is first-order logic, so it has been dropped. Where the reasoner also uses trusted steps, the relevant target closure is $\mathrm{Cl}_{R^\*\cup T_{\rm rust}}$ (Thm 4.1(i)).

(WS) implies that every designated position is in bounds for $R^\*\cup T_{\rm rust}$: $\bot\notin\mathrm{Cl}_{R^\*\cup T_{\rm rust}}(A)$ and $D\cap\mathrm{Cl}_{R^\*\cup T_{\rm rust}}(A)=\emptyset$. The reason is that $V$ makes $A$ true, preserves truth along $R^\*\cup T_{\rm rust}$-steps, and makes ⊥ and $D$ false.

*Equivalent form (corrected after verification).* Suppose $e_{[A:D]}$ is well defined. Then (WS) holds for $[A:D]$ iff no derivation with steps in $R^\*\cup T_{\rm rust}$ leads from $e$-true judgments to an $e$-false one, i.e. iff $\Sigma^\*$ is clean at every depth relative to $[A:D]$ (Def 1.5).
* (⇒) is Lemma 2.1(a).
* (⇐) Take $V:=$ the indicator function of $\mathrm{Cl}_{R^\*\cup T_{\rm rust}}(A\cup W^{-1}(1))$. It is closed under $R^\*\cup T_{\rm rust}$ and contains $A$ and the $W$-true judgments. By cleanness it misses ⊥, $D$ and the $W$-false judgments.
* Without a world this says that each position is in bounds for $R^\*\cup T_{\rm rust}$. (The earlier text said "in bounds for $R^\*$"; that version needed the dropped clause.)
* The same argument applies to any candidate target $\Sigma$ in place of $\Sigma^\*$. §5 uses this.

In formal mathematics, $V$ is truth in the intended structure 𝔐. (WS) then holds when the designated positions are true of 𝔐, $W$ is truth in 𝔐 on its fragment, and the target calculus and the trusted steps are 𝔐-sound. The non-total version, "no step is falsified at evaluated nodes", is too weak: a derivation could pass through unevaluated nodes from true assertions to a false conclusion.

### 1.4 Refutations, conflicts, residue, collateral

**Definition 1.5 (refutations).**
* Let $B\subseteq\mathcal S$ be a finite set of schemas and $d\in\mathbb N$. A **$d$-refutation of $B$** is a derivation of total size $\le d$ (symbols in all its judgments) with these properties:
  * it is relative to some $[A:D]\in\mathcal A$, and every leaf $\ell$ (a judgment not produced by a step of the derivation) has $e_{[A:D]}(\ell)=1$, i.e. it is an assertion of the position or a $W$-true evaluable judgment;
  * every step is in $R_B\cup T_{\rm rust}$;
  * its conclusion $j$ has $e_{[A:D]}(j)=0$ (⊥, a denied judgment, or a world-false judgment).
  
  A single falsified instance of some $\sigma\in B$, for example a closed instance with $W$-true premises and a $W$-false conclusion, is the special case of a one-step derivation.
* More generally, for a set $S$ of steps (e.g. a sandbox hypothesis or $B_t=\bigcap S_t$ in §3.1), a $d$-refutation of $S$ is defined in the same way with $R_B$ replaced by $S$ *(added after verification)*.
* $B$ (or $S$) is **$d$-clean** if it has no $d$-refutation.
* $\mathrm{Conf}_d:=\{C\subseteq\Sigma^P: C\text{ not }d\text{-clean}\}$ is upward closed. Its inclusion-minimal members $\mathcal C_d$ are the **minimal $d$-conflicts**.
* The **refutation oracle** $\mathrm{Ref}_d(B)$ returns a $d$-refutation of $B$, or NONE.

$\mathrm{Ref}_d$ is computable by brute force whenever instance membership and $W$ are decidable and there are finitely many derivations of size $\le d$ up to renaming. This holds for a finite signature. It also holds when derivations are counted up to renaming of the symbols (atoms, object variables) that occur in none of $\mathcal A$ and $B$ and on which $W$ does not depend, because such a renaming maps refutations to refutations. With infinitely many atoms and no such quotient the count is infinite *(qualified after verification)*. Its cost is $\exp(O(d))$, and **it is accounted separately** (L8 §11.7).

**Definition 1.6 (residue, collateral, blame regimes).**
* **Residue at depth $d$:** $F^{(d)}_{\rm res}:=\{\tau\in F:\ \Sigma^\*\cup\{\tau\}\text{ is }d\text{-clean}\}$. These are the fallacies coherent with the target on the designated positions, and world-adequate, up to size $d$. Also $F_{\rm res}:=\bigcap_dF^{(d)}_{\rm res}$. For $\tau\in F$ let $d_\tau:=\min\{d:\Sigma^\*\cup\{\tau\}\text{ is not }d\text{-clean}\}$ ($=\infty$ for $\tau\in F_{\rm res}$).
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
* **(a)** Every subset of $\Sigma^\*$ is $d$-clean for every $d$. More generally, every step set $S\subseteq\mathrm{Sound}(R^\*)$ is $d$-clean for every $d$ *(generalization added after verification; used in Prop 3.3)*.
* **(b)** Every $C\in\mathrm{Conf}_d$ contains a fallacy.
* **(c)** $\mathrm{Conf}_d$, and every answer of $\mathrm{Ref}_d$, is a function of $(\mathcal A,W,T_{\rm rust},d)$ and of the queried schema set alone. It does not depend on which schemas are genuine.

*Proof.*
* (a) Let $S\subseteq\mathrm{Sound}(R^\*)$, e.g. $S=R_B$ with $B\subseteq\Sigma^\*$. Let π be a derivation relative to $[A:D]$ whose leaves all have $e$-value 1 and whose steps are in $S\cup T_{\rm rust}$. By (WS) there is a total $V$ that extends $e$ and falsifies no step of $R^\*\cup T_{\rm rust}$. It then falsifies no step of $\mathrm{Sound}(R^\*)$ either, since $V$-truth is preserved along $R^\*$-derivations. By induction along π, every node is $V$-true: the leaves have $e$-value 1, hence $V$-value 1, and steps preserve $V$-truth. The conclusion is therefore $V$-true, so it is not $e$-false. Hence π is not a refutation.
* (b) Immediate from (a).
* (c) Definition 1.5 mentions only these data. ∎

So refutations can never condemn a subset of the target (one-sidedness). And two targets with the same practice receive *identical* refutation evidence on every query. Refutational channels can say only that a *set* of practice rules contains a fallacy. They can never say that a rule is genuine.

### 2.2 Caution over practice asserts the fallacies

**Proposition 2.2 [proved; TOSU].** Let the positive-data tier be the per-tag trimmed version space (T1 Thm 6.2) over the practice tags. On the event of T1 Thm 6.3 its accepted set is exactly $R^P=R_{\Sigma^P}$. In particular:
* it accepts an instance of every $\tau\in F$ that lies outside $\mathrm{Sound}(R^\*)$;
* an adaptive prover that queries that instance gets an invalid step accepted;
* *(revised after verification)* in CPC with a complete $\Sigma^\*$ and a **pure** τ, the prover can query the closed ⊤/⊥ instance of τ that has true premises and a false conclusion (Lemma 6.1). That single step makes every formula derivable from ∅: $\Sigma^\*$ derives its true closed premises, hence its false closed conclusion $j$, and also $\neg j$, hence ⊥ and then everything. The whole instance set $R_{\{\tau\}}\subseteq R^P$ does the same (T1 Prop 2.3). An arbitrary single invalid step need not: adding $(p\,/\,q)$ to complete CPC leaves $\mathrm{Cl}(\emptyset)$ unchanged. For impure τ even the whole instance set need not trivialize.

*Proof.* T1 Thm 6.3 applies tag by tag, and fallacy tags are tags like any other. The third bullet is argued in place. ∎

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

[computed: `duality.py`, 4000 random families on ≤ 7 points, no failures.] Part (b) is the standard fact that the vertices of the transversal hypergraph $\mathrm{Tr}(\mathcal C)$ are exactly the vertices of the minimal edges (Berge) [cited].

*Reading.*
* This is Reiter's (1987) theory of diagnosis from first principles, with the hitting-set duality between conflicts and diagnoses [cited; see also de Kleer & Williams 1987]. The dictionary:
  * components are practice schemas;
  * "abnormal" means fallacious;
  * conflicts are T2's negative bags;
  * diagnoses are the hypotheses about which practice rules are fallacies.
* Apply it with $\mathcal U=\Sigma^P$ and $\mathcal K=\mathrm{Conf}_d$, so that $\mathcal C=\mathcal C_d$. Every *maximal* candidate consistent with the evidence then keeps $\Sigma^P\setminus\bigcup\mathcal C_d$.
* *(Revised after verification.)* So $\bigcup\mathcal C_d$ is exactly the set of practice schemas that a learner who presumes validity, and is cautious across the remaining ambiguity *at the level of schemas*, must withhold as schemas.
  * At the level of instances a learner can do better. Instances shared by all maximal candidates can be asserted soundly even when they belong to a withheld schema (Prop 2.4(c)).
  * That withholding is *forced* for every sound learner is proved only at stable depth (Thm 5.6(b)). At finite depth it can fail (Thm 5.6(c)).

### 2.4 The caution–presumption dilemma

Suppose the practice $\Sigma^P$ is known. The natural candidate class is
$$\mathcal V:=\{\Sigma\subseteq\Sigma^P\},$$
where a candidate Σ reads as "Σ is the target and the rest of the practice is fallacious". All candidates explain the positive data equally well, because the practice is the same. Let $\mathcal V_d$ be the $d$-clean candidates and $\mathcal V'_t$ the candidates consistent with the refutations *found by time t*.

**Proposition 2.4 [proved].**
* **(a) Caution without presumption is vacuous.** $\emptyset\in\mathcal V_d$ by Lemma 2.1(a), so $\bigcap_{\Sigma\in\mathcal V_d}R_\Sigma=\emptyset$. The version-space verifier over $\mathcal V$ never asserts anything.
* **(b) Presumption without audit is unsound.** Consider the verifier that asserts $\bigcap\{R_\Sigma:\Sigma\text{ maximal in }\mathcal V'_t\}$.
  * Before any refutation has been found, $\mathcal V'_t$ has the unique maximal member $\Sigma^P$, so the verifier asserts all of $R^P$.
  * If $F\not\subseteq F^{(d)}_{\rm res}$, some asserted step lies outside $\mathrm{Sound}(R^\*)$.
* **(c) Presumption after audit works (revised after verification).**
  * *Schema level.* The policy that asserts the instances of the schemas common to all maximal candidates asserts
    $$R_{\bigcap\{\Sigma:\ \Sigma\text{ maximal in }\mathcal V_d\}}=R_{\Sigma^P\setminus\bigcup\mathcal C_d}=R_{(\Sigma^\*\setminus\mathrm{Coll}_d)\cup F^{\rm surv}_d}.$$
    Moreover $F^{\rm surv}_d\subseteq F^{(d)}_{\rm res}$, so this set is sound relative to $R^\*\cup R_{F^{(d)}_{\rm res}}$.
  * *Instance level.* The instance-level policy asserts $\bigcap\{R_\Sigma:\Sigma\text{ maximal in }\mathcal V_d\}$. This set **contains** the schema-level set, since $R_{\bigcap\Sigma}\subseteq\bigcap R_\Sigma$. It can be **strictly larger**, because schemas from different maximal candidates can share instances. The earlier version asserted equality, which is false. It is still sound: $\bigcap R_\Sigma\subseteq R^\*\cup R_{F^{(d)}_{\rm res}}$, and it is $d$-clean.
  * *Example* [computed: `overlap.py`]. Take MP/AC on $A_1$ (§5): $\{\mathrm{MP}\}$ and $\{\mathrm{AC}\}$ are the maximal candidates, so the schema-level set is $R_\emptyset=\emptyset$. But MP $=(A,\ A\to B\,/\,B)$ and AC $=(B,\ A\to B\,/\,A)$ unify, with most general common instance $(A,\ A\to A\,/\,A)$, which is valid. Its instances lie in $R_{\rm MP}\cap R_{\rm AC}$ and may be asserted.
  * Membership in the instance-level set is decidable by matching against each maximal candidate, given the list of maximal candidates (Lemma 3.1, cost accounting).

*Proof.*
* (a) and (b) are immediate.
* (c), schema level. The first equality is Lemma 2.3(b) at the level of schema sets; the second follows from the definitions. For the inclusion, let $\tau\in F\setminus F^{(d)}_{\rm res}$. Then $\Sigma^\*\cup\{\tau\}$ is not clean, so it contains some $C'\in\mathcal C_d$. Since $C'\not\subseteq\Sigma^\*$ by Lemma 2.1(a), $\tau\in C'$, and so $\tau\notin F^{\rm surv}_d$.
* (c), instance level. $\Sigma^\*$ is $d$-clean (Lemma 2.1(a)), so it lies in some maximal $\Sigma_{\max}\in\mathcal V_d$. For $\tau\in\Sigma_{\max}\cap F$, the set $\Sigma^\*\cup\{\tau\}\subseteq\Sigma_{\max}$ is $d$-clean, so $\tau\in F^{(d)}_{\rm res}$. Hence $\bigcap R_\Sigma\subseteq R_{\Sigma_{\max}}\subseteq R^\*\cup R_{F^{(d)}_{\rm res}}$. As a subset of the $d$-clean $R_{\Sigma_{\max}}$, it is $d$-clean. ∎

*Remark 2.4′ (a Bayesian middle way) [sketch].* Put a prior $w$ on $\mathcal V$. Accept $s$ iff
$$w\{\Sigma\in\mathcal V'_t:s\notin R_\Sigma\}<w_0 .$$
In posterior terms this is an adaptive threshold $w_0/w(\mathcal V'_t)$.
* *Soundness.* By the argument of T1 Thm 4.1, this rule is sound at all times for every target with $w(\Sigma^\*\cup F^{(d)}_{\rm res})\ge w_0$, provided that set is clean.
* *Completeness under a product prior.* Let the prior make each practice rule fallacious independently with probability ε. Then a genuine rule is asserted once every candidate keeping an incoherent fallacy has been refuted, provided roughly $\varepsilon<(1-\varepsilon)^{|\Sigma^\*|+|F_{\rm res}|}$.
* *Reading.* This is "presumption of validity" in quantitative form, and it waits for the audit automatically.
* *Limits.* Its guarantee covers only targets of prior mass ≥ $w_0$, and it cannot break the symmetry of Thm 5.6, where the rival diagnosis has the same prior mass. I do not develop it further. The audit-then-assert design below is simpler and has explicit constants.

### 2.5 Descent turns a refutation into singleton blame

*(Revised after verification.)* Fix a derivation π relative to $[A:D]$. Let $e^+_\pi$ be the partial map on the judgments of π obtained from $e_{[A:D]}$ by closing under two propagation rules through the **trusted steps of π**:
* **forward:** if a trusted step of π has all its premises at value 1, its conclusion gets 1;
* **backward:** if a trusted step of π has conclusion value 0 and all but one premise at value 1, the remaining premise gets 0.

This is a fixed point over the finitely many judgments of π. A worklist computes it with $O(|\pi|\cdot\varphi)$ evaluations of $e$, where φ is the maximal fan-in. The earlier version closed $e$ under *all* trusted steps globally. That closure is not computable in general: in §6.3, forward closure from the $W$-true Δ₀ sentences reaches exactly the true Σ₁ sentences. It is also not needed.

**Lemma 2.5 (descent; counterexample-to-blame) [proved] (revised after verification).** Assume (WS). Then $e^+_\pi$ agrees with $V_{[A:D]}$ wherever it is defined. In particular it never assigns a judgment both values, so a conflict certifies that $[A:D]$ violates (WS).

Let π be a refutation of $B$ (Def. 1.5) whose conclusion has value 0. *Descend* as follows. Start at the conclusion. At a node with value 0 produced by step $s$:
* if all premises of $s$ have value 1, output $s$;
* otherwise move to a premise with value 0.

Say the descent is *unblocked* if, at every visited node, either all premises have value 1 or some premise has value 0. If it is unblocked:
* **(a)** it outputs an untrusted step $s\in R_B$ whose premises are $V$-true and whose conclusion is $V$-false. So $s\notin R^\*$;
* **(b)** computing $e^+_\pi$ and descending costs $O(|\pi|\cdot\varphi)\le O(d\cdot\varphi)$ evaluations of $e$;
* **(c)** every $\sigma\in B$ with $s\in\mathrm{inst}(\sigma)$ is a fallacy. Removing all of them removes no genuine rule (*certified singleton blame*);
* **(d)** *(added after verification)* for every such σ, the singleton $\{\sigma\}$ is a $d$-conflict. The step $s$, together with the trusted steps of π that justify the values of its premises and of its conclusion, is a $d$-refutation of $\{\sigma\}$.

*Proof.*
* $e^+_\pi$ agrees with $V$. The forward rule is sound because trusted steps preserve $V$-truth. The backward rule is sound for the same reason: if the remaining premise were $V$-true, the conclusion would be too.
* (a) The descent follows nodes of value 0 strictly downward, so it ends. Leaves of π have value 1, and every other node is the conclusion of some step, possibly a 0-premise step; a 0-premise step with conclusion 0 is output immediately. The output step has $V$-true premises and a $V$-false conclusion. By (WS) it is neither in $T_{\rm rust}$ nor in $R^\*$, so it is an untrusted step of $R_B$.
* (b) There is one fixed-point computation over π, and one evaluation per premise of each visited node.
* (c) If σ were genuine, then $s\in\mathrm{inst}(\sigma)\subseteq R^\*$, contradicting (a).
* (d) Each premise of $s$ with value 1 is $e$-true, or is the conclusion of a trusted step of π whose premises have value 1. Recursively, it has a derivation inside π from $e$-true judgments using trusted steps only.
  * The conclusion of $s$ is $e$-false, or it is a premise of a trusted step of π whose conclusion has value 0 and whose other premises have value 1. Recursively, a chain of trusted steps of π leads from it to an $e$-false judgment, with side premises derivable as before.
  * Together with $s$ this is a refutation of $\{\sigma\}$ whose judgments are judgments of π, so its size is at most $|\pi|\le d$. ∎

This is L6 TC1 and T4 Lemma 4.1, which are in turn Shapiro's *contradiction backtracing* from algorithmic debugging and model inference (Shapiro 1981, 1983) [cited]. Two additions are specific to this setting. First, trusted steps carry values *backward* through unevaluable nodes; arithmetic needs this, because $\forall x\theta$ is not Δ₀ (§6.3). Second, items (c) and (d): blame lands on *schemas*, with no collateral, and each blamed schema is a singleton conflict. When the descent is blocked, all we have is the bag $\{\sigma\in B:\sigma\text{ used in }\pi\}$.

*The principle that emerges.* In CPC and in arithmetic, world feedback refutes nothing that coherence does not already refute (Post; T2 Lemma 3.7). Its whole added value is that descent makes its refutations *singletons*. **World feedback earns its keep by localization, not by refutation.**

---

## 3. The learner TTL$(d,\delta)$

### 3.1 Algorithm

*Inputs:*
* the floor constants $(\Delta,c,K,\bar\alpha)$;
* a refutation oracle $\mathrm{Ref}_d$ (with $\mathcal A,W,T_{\rm rust}$);
* a sandbox class $\mathcal H_S$ with prior $w$.

$\mathrm{Ref}_d$ returns the lexicographically least refutation among the smallest ones. This makes its answers independent of $d$ once $d$ exceeds the smallest refutation size.

*Variant (prefer-unblocked tie-breaking; made explicit after verification).* Among the size-$\le d$ refutations, return one whose descent is unblocked if one exists, then the smallest, then the lexicographically least. Unblockedness is decidable, since $e^+_\pi$ is local to π. Cor 6.2, Thm 6.6(a) and Prop 3.2 use this variant. For each $B$ its answer changes at most twice as $d$ grows. Both rules are deterministic functions of $(B,d,\mathcal A,W,T_{\rm rust})$, so Lemma 2.1(c) and everything below hold for either.

**Phase 0** ($t<N_1$), where
$$N_1:=\Big\lceil\tfrac1{2\Delta^2}\ln\tfrac{(1+c)K}{\delta}\Big\rceil.$$
In the noise-free case (*noise-free mode*) use instead $N_1:=\lceil\lambda^{-1}\ln\frac{cK}{\delta}\rceil$, with a known $\lambda\le\min_i\pi_i\rho_i$ (T1 Thm 5.3). Here $c\ge\max_i\max(c_i,1)$, and $\rho_i:=1$ for ground rules *(revised after verification)*. T1 Thm 5.3 has $c_i=0$ for ground rules, so if every tag were a ground rule, $\ln(cK/\delta)$ with $c=0$ would be undefined, although the failure probability $(1-\pi_i)^{N}$ is positive; this is the convention of T1 Thm 6.3. During Phase 0:
* the assertion tier **abstains**. A query may be escalated to a human. If all its judgments lie in $D_W$, it may instead be answered by the **world channel**, which accepts it iff it is not $W$-falsified.
  * *(Clarified after verification.)* World-channel answers are **not** acceptances of the assertion tier. They are truth-sound when $W$ is truth in 𝔐, but need not lie in $\mathrm{Sound}(R^\*)$. Example: for $\Sigma^\*=\{\wedge\mathrm I,\wedge\mathrm E_1,\wedge\mathrm E_2\}$, the step $(\top\,/\,\top\vee\bot)$ is $W$-truth-preserving but not $R^\*$-derivable.
  * Thm 4.1(i) concerns the assertion tier only. A reasoner that also chains world-channel steps is covered by Cor 4.2 (truth-soundness), not by the closure inclusion of Thm 4.1(i). The same holds if the world channel stays open in Phase 1.
* human steps are recorded. Human answers to escalated queries are **not** added to the i.i.d. sample.

**At $t=N_1$:**
1. *Practice identification.* For each tag $i$ with $n_i>e_i$ samples, where $e_i:=\lfloor(\bar\alpha_i+\Delta)N_1\rfloor$ (*noise-free mode: $e_i:=0$*, added after verification), let
   $$\hat\sigma_i:=\mathrm{mgu}\{\mathrm{lgg}(P_i\setminus E):|E|=e_i\}.$$
   This is the most general common instance of the trimmed lggs, i.e. the schema whose instance set is the trimmed version space's accepted set. Let $\hat P:=\{\hat\sigma_i\}$.
   * The noise-free $N_1$ comes from T1 Thm 5.3, which is about the *untrimmed* lgg. With $\bar\alpha_i=0$ the noisy formula would still give a positive budget $e_i=\lfloor\Delta N_1\rfloor$, and then Thm 5.3's event does not imply identification.
   * [computed: `noisefree.py`. One tag, one metavariable, two equiprobable roots ($\lambda=1/2$), δ = 0.001: $N_1=16$. With $e=4$, identification fails with probability 0.077; with $e=0$ it fails with probability $3\cdot10^{-5}$.]
2. *Audit.* Set $B:=\hat P$ and repeat:
   * Call $r:=\mathrm{Ref}_d(B)$. If $r=$ NONE, **return** $B$.
   * Descend on $r$ (Lemma 2.5). If the descent outputs $s$, set $B:=B\setminus\{\sigma\in B:s\in\mathrm{inst}(\sigma)\}$ and continue.
   * If the descent is blocked, **return** $B\setminus\bigcup\mathcal C_d(B)$, where $\mathcal C_d(B)$ is the set of minimal $d$-conflicts contained in $B$, computed by enumeration (*fallback*).
3. Let $A$ be the returned set, and **freeze** it.

**Phase 1** ($t\ge N_1$): the assertion tier accepts $q$ iff $q\in R_A$, which is decidable by matching. It may escalate other queries.

**Sandbox (all times).** This is oligarchic halving (T2 §2.2) over $\mathcal H_S$, a class of step sets, for example over candidate generalizations of asserted schemas or candidate new rules.
* It announces the coalition-unanimous set $B_t=\bigcap S_t$, with $w(S_t)\ge\frac12w(\mathrm{VS}_t)$.
* A red team, which may be the prover or the learner's own search, exhibits refutations π of the step set $B_t$ (Def 1.5, step-set form).
* Each refutation π deletes every hypothesis $h\supseteq\mathrm{Steps}(\pi)\setminus T_{\rm rust}$, i.e. every hypothesis containing its **untrusted** steps *(made precise after verification)*.
* *Isolation:* nothing from the sandbox enters $R_A$ as a primitive step.
  * A conjectured rule κ is promoted only as a *derived* rule, i.e. when a schematic $R_A$-derivation of κ is found, so that each of its instances is derivable in $R_A$. This leaves $\mathrm{Cl}_{R_A}$ unchanged (T1 Lemma 1.1).
  * A promoted κ is a **macro** *(clarified after verification)*: a κ-instance is answered by expanding it into its $R_A$-derivation, so the tier's primitive accepted steps remain exactly $R_A$ (see Prop 3.3(a) for what changes if promoted rules are accepted as primitive steps instead).

**Truth maintenance.** Lemmas and promoted macros cached in the assertion tier are $R_A$-derivations. If the audit is re-run at a larger depth (§4, part (iv)), invalidate every cached lemma or macro that uses a removed schema (T2 Thm 2.2, Remark (b)).

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
* The descent path costs at most $|F|+1$ oracle calls and $O((|F|+1)\cdot d\cdot\varphi)$ evaluations of $e$ (Lemma 2.5(b)).
* The fallback needs $\bigcup\mathcal C_d(B_0)$.
  * By brute force this takes at most $2^{|B_0|}$ oracle calls.
  * *(Citation corrected after verification.)* Only a cleanness (membership) oracle is available here, not an explicit hypergraph. The relevant result is therefore **joint generation** of the minimal conflicts and the maximal clean sets of a monotone property from a membership oracle (Bioch & Ibaraki 1995; Gurvich & Khachiyan 1999; Boros, Elbassioni, Gurvich & Khachiyan, early 2000s [cited (u)]), with Fredman & Khachiyan's (1996) dualization as the engine. This costs time quasi-polynomial in $|\mathcal C_d(B_0)|+|\{\text{maximal clean subsets of }B_0\}|$ and outputs both families. The second family can be exponentially larger than the first, and both can be exponential in $|F|$.
  * The list of maximal clean sets is also what the instance-level fallback of Prop 2.4(c) needs.
  * At stable depth the fallback's schema-level incompleteness is unavoidable (Thm 5.6(b)); its *cost* is the price of bags.
* $\mathrm{Ref}_d$ itself costs $\exp(O(d))$ by enumeration, and is semi-decidable only as $d\to\infty$.

**Proposition 3.2 (mis-designated positions; voting audit) [proved] (revised after verification).**

*Setting.* At most $m$ designated positions violate (WS), and it is not known which. The others are *good*. Assume $\hat P=\Sigma^P$. Write $\mathrm{Ref}^p_d$ for the oracle restricted to refutations relative to the single position $p$, with the prefer-unblocked tie-breaking of §3.1. Thm 4.1 assumes (WS) for every position, so this proposition lies outside its hypotheses.

*Voting audit.*
1. *Per-position descent loops.* For each position $p$, run the descent loop of §3.1 relative to $p$ alone, starting from $B_p:=\Sigma^P$ and $\mathrm{Blamed}_p:=\emptyset$. Repeat:
   * call $r:=\mathrm{Ref}^p_d(B_p)$;
   * stop if $r=$ NONE (call $p$ *finished*), or if the descent on $r$ is blocked;
   * stop if $e^+_{p,r}$ assigns some judgment both values, or if $e_p$ itself is ill defined. This certifies that $p$ is bad (Lemma 2.5), so discard $p$'s blame;
   * otherwise move every $\sigma\in B_p$ with $s\in\mathrm{inst}(\sigma)$ from $B_p$ to $\mathrm{Blamed}_p$.
2. *Votes.* $\mathrm{votes}(\sigma):=\#\{p:\sigma\in\mathrm{Blamed}_p\}$. If the world is known to be truthful, i.e. $[\emptyset:\emptyset]$ is good, blame from $[\emptyset:\emptyset]$ counts as $m+1$ votes.
3. *Return* $A:=\Sigma^P\setminus\{\sigma:\mathrm{votes}(\sigma)\ge m+1\}$.

Then:
* **(a)** No genuine rule is removed: $\Sigma^\*\subseteq A$.
* **(b)** The audit makes at most $\sum_p(|\mathrm{Blamed}_p|+1)\le|\mathcal A|(|F|+1)+m|\Sigma^\*|$ oracle calls.
* **(c)** *Residue.* Call $p$ *complete* if it is good and finished. For every complete $p$ and every $\tau\in F$ such that $\Sigma^\*\cup\{\tau\}$ is not $d$-clean relative to $p$, we have $\tau\in\mathrm{Blamed}_p$. Hence
  $$A\cap F\ \subseteq\ F^{(d,m)}_{\rm res}:=\{\tau\in F:\ \#\{p\text{ complete}:\ \Sigma^\*\cup\{\tau\}\text{ is not }d\text{-clean relative to }p\}\le m\}.$$
  If $m=0$ and every position is complete, then $F^{(d,0)}_{\rm res}=F^{(d)}_{\rm res}$, $A$ is $d$-clean, and Lemma 3.1(a) is recovered.

*Proof.*
* (a) For a good $p$, every blamed schema is a fallacy (Lemma 2.5(c)). So a genuine σ collects votes only from bad positions, of which there are at most $m$. The $[\emptyset:\emptyset]$ bonus is used only when that position is good.
* (b) Each call either ends $p$'s loop or moves at least one schema into $\mathrm{Blamed}_p$.
  * For a good $p$, only fallacies move, so there are at most $|F|+1$ calls.
  * For a bad $p$, there are at most $|\Sigma^P|+1=|F|+|\Sigma^\*|+1$ calls.
  * Summing gives the bound.
* (c) Let $p$ be complete. Its loop ended with NONE, so the final $B_p$ is $d$-clean relative to $p$. Since $p$ is good, $\Sigma^\*\subseteq B_p$ by (a).
  * If $\tau\notin\mathrm{Blamed}_p$, then $\tau\in B_p$, so $\Sigma^\*\cup\{\tau\}\subseteq B_p$ is $d$-clean relative to $p$.
  * A surviving τ has at most $m$ votes, so it is in $\mathrm{Blamed}_p$ for at most $m$ complete positions.
  * For $m=0$: $A=\Sigma^P\setminus\bigcup_p\mathrm{Blamed}_p$ lies inside every final $B_p$, so it is clean relative to every position. ∎

*What changed, and why.*
* The earlier version ran one smallest-refutation query per position and voted on the results. It claimed (i) at most $(m+1)|F|$ successful descents and (ii) that "fallacies falsifiable under at most $m$ positions join the residue", implying that the others are removed. Both claims are false.
  * Counterexample to (i): one bad position $[\{a,\ a\to b\}:\{b\}]$, target $\{\mathrm{MP}\}$, $F=\emptyset$, $m=1$. The bad position blames MP once, but $(m+1)|F|=0$.
  * Counterexample to (ii): $m=1$, with truthful positions $p_1=[\{q,\ p\to q,\ \neg p\}:\{p,\neg q\}]$ and $p_2=[\{\neg r,\ r\to t\}:\{\neg t\}]$, and practice $\{\mathrm{MP},\mathrm{AC},\mathrm{DA}\}$. The smallest refutation at $p_1$ always blames AC and hides DA. So DA gets one vote although it is refutable at two positions, and it survives.
* The per-position loops above exclude already-blamed schemas, so DA is blamed at both positions and removed. AC is refutable at one position only, so it may survive, as (c) allows [computed: `prop32_voting.py`].

The soft (multiplicative) version of this is T2 Thm 2.5. The global damage done by an undetected mis-designation is T2 Prop 7.1.

**Proposition 3.3 (sandbox isolation and budget) [proved; transport of T2 Thms 2.2 and 2.5].**
* **(a)** The assertion tier is a function of the first $N_1$ human steps and of the audit's oracle answers alone. No sandbox state, red-team action or prover action affects it. Promotion by derivation leaves $\mathrm{Cl}_{R_A}$ unchanged.
  * *(Added after verification.)* This is why promoted rules are macros (§3.1). Suppose instead that a promoted κ were accepted as a primitive step. Then κ ⊆ $\mathrm{Sound}(R_A)$, and Thm 4.1(i) would hold only in the weaker form "accepted ⊆ $\mathrm{Sound}(R^\*\cup R_{F^{(d)}_{\rm res}})$". The closure inclusion would be unchanged.
  * *d*-cleanness would then hold for the schema set $A$ but not for the enlarged step set: if some $\tau\in A$ is residual with a shortest refutation of size $2d$, a κ that packages its first half yields one of size $\le d$.
  * Primitive promoted rules would also need truth maintenance under the depth schedule.
* **(b)** *(Hypothesis made explicit after verification.)* Suppose $\mathcal H_S$ contains a hypothesis $h_0$ that is clean at every depth (Def 1.5, step-set form), with $w(h_0)>0$; for example $h_0=R^\*$ when $R^\*\in\mathcal H_S$ (Lemma 2.1(a)). Then for every red team:
  * the number of detections against the coalition is at most $\log_2(1/w(h_0))$;
  * with $m$ false alarms and penalty factor β it is at most $\big(\ln\frac1{w(h_0)}+m\ln\frac1\beta\big)/\ln\frac2{1+\beta}$.
  * Without such an $h_0$, e.g. when $\mathcal H_S$ contains only generalizations of $A$ that miss collateral rules, the bound is vacuous ($+\infty$).
* **(c)** Coalition unanimity is computable when $S_t$ is finite: $s\in\bigcap_{h\in S_t}h$ iff $s$ matches a schema of every $h$.
  * For schema-valued hypotheses, the intersection of instance sets is the instance set of the mgu (unification). This is the operation used in step 1 of the algorithm.
  * The idealization in T2's oligarchic halving is the *choice* of a finite $S_t$ with $w(S_t)\ge\frac12w(\mathrm{VS}_t)$. That requires upper approximations of $w(\mathrm{VS}_t)$, hence knowledge of which hypotheses are refuted, up to a tail of small mass.

*Proof.*
* (a) Holds by construction. The weaker form follows from $\kappa\subseteq\mathrm{Sound}(R_A)\subseteq\mathrm{Sound}(R^\*\cup R_{F^{(d)}_{\rm res}})$.
* (b) The proofs of T2 Thms 2.2 and 2.5 use only that the protected hypothesis is never deleted. A detection by π deletes only hypotheses $h\supseteq\mathrm{Steps}(\pi)\setminus T_{\rm rust}$, and such a π would be a refutation of $h$. For $h_0=R^\*$ this contradicts Lemma 2.1(a). (If deletion tested *all* steps of π against hypotheses that do not contain $T_{\rm rust}$, coalition members using trusted steps would never be deleted, and halving would fail.)
* (c) Standard: first-order unification and the most general unifier (Robinson 1965); the lattice of generalizations (Plotkin 1970; Reynolds 1970). ∎

This is the answer to "how cautious acceptance interacts with the coalition": **it does not.** The coalition is bold, and its errors are bounded by halving. The assertion tier is cautious, and its soundness is certified by the audit. The only channel from the sandbox to the assertion tier is *derivation*, which cannot enlarge the closure. Re-deriving sandbox lemmas inside $R_A$ is what makes the separation safe. T2's truth-maintenance remark is the same point made across time.

---
## 4. The end-to-end theorem

**Theorem 4.1 (two-tier coherent inferential learning) [proved, modulo T1 Thms 5.3/6.3 and T2 Thms 2.2/2.5].**

*Assumptions:*
* (Floor) and the realizable tagged single-schema class (Defs 1.1–1.2);
* (WS) (Assumption in §1.3) for **every** designated position. This forces $m=0$ in Prop 3.2, so mis-designated positions are outside this theorem; Prop 3.2 is the separate statement for them;
* $\mathrm{Ref}_d$ exact for size-$\le d$ refutations, with either tie-breaking rule of §3.1.

*Conclusion.* Run TTL$(d,\delta)$. There is an event $G$ with $\Pr(G)\ge1-\delta$, depending only on the first $N_1$ human steps, on which the following hold for every adaptive prover and every red team.

* **(i) Uniform soundness at all times.**
  * For $t<N_1$ the assertion tier accepts nothing. World-channel answers (§3.1, Phase 0) are not acceptances of the tier; see Cor 4.2 for their status.
  * For $t\ge N_1$ every step accepted by the tier lies in $R^\*\cup R_{F^{(d)}_{\rm res}}$. So for every premise set $B$, the reasoner's derivable judgments satisfy $\mathrm{Cl}_{R_A}(B)\subseteq\mathrm{Cl}_{R^\*\cup R_{F^{(d)}_{\rm res}}}(B)$.
  * If the reasoner also uses trusted steps, then $\mathrm{Cl}_{R_A\cup T_{\rm rust}}(B)\subseteq\mathrm{Cl}_{R^\*\cup T_{\rm rust}\cup R_{F^{(d)}_{\rm res}}}(B)$. This equals $\mathrm{Cl}_{R^\*\cup R_{F^{(d)}_{\rm res}}}(B)$ when $T_{\rm rust}\subseteq\mathrm{Sound}(R^\*)$ *(added after verification)*.
  * If $F^{(d)}_{\rm res}=\emptyset$, then $\mathrm{Cl}_{R_A}(B)\subseteq\mathrm{Cl}_{R^\*}(B)$: the reasoner is sound for the target against arbitrary search.
  * The schema set $A$ is $d$-clean: no prover can ever exhibit a size-$\le d$ refutation of $R_A$. Promoted rules are macros (§3.1), so they do not enlarge the primitive step set.
* **(ii) Refutation budget.**
  * The audit uses at most $|F|+1$ calls to $\mathrm{Ref}_d$ on its descent path, and $O((|F|+1)\,d\,\varphi)$ evaluations of $e$. It removes no genuine rule there.
  * *(Hypothesis made explicit after verification.)* If $\mathcal H_S$ contains a hypothesis $h_0$ that is clean at every depth with $w(h_0)>0$, e.g. $h_0=R^\*$, the sandbox suffers at most $\log_2(1/w(h_0))$ detections. With $m$ false alarms the bound is $\big(\ln\frac1{w(h_0)}+m\ln\frac1\beta\big)/\ln\frac2{1+\beta}$.
  * *(The earlier clause "with up to $m$ mis-designated positions … at most $(m+1)|F|$ descents" is removed after verification. It lay outside the (WS) hypothesis, and its count was false; see Prop 3.2.)*
* **(iii) Convergence modulo the residue.** For $t\ge N_1$ the tier accepts exactly $R_A$, where:
  * if no descent is blocked: $\Sigma^\*\subseteq A\subseteq\Sigma^\*\cup F^{(d)}_{\rm res}$;
  * if the fallback is triggered at $B_0$: $\Sigma^\*\setminus\mathrm{Coll}_d(B_0)\subseteq A\subseteq\Sigma^\*\cup F^{(d)}_{\rm res}$, with $A=(\Sigma^\*\setminus\mathrm{Coll}_d)\cup F^{\rm surv}_d$ when $B_0=\Sigma^P$.
  
  So under (SB$_d$), or whenever no descent is blocked, the tier is **complete for the target**. It accepts every genuine step, and the only fallacies it accepts are residual ones: the target modulo the Kripkensteinian residue. The sample size is
  $$N_1=\Big\lceil\tfrac1{2\Delta^2}\ln\tfrac{(1+c)K}{\delta}\Big\rceil\quad\big(\text{noise-free mode, with }e_i:=0\text{: }\lceil\lambda^{-1}\ln\tfrac{cK}{\delta}\rceil,\ \lambda\le\min_i\pi_i\rho_i,\ c\ge\max_i\max(c_i,1)\big).$$
* **(iv) Depth schedule.** Re-run the audit on the frozen $\hat P$ at depths $d_1<d_2<\cdots$, with truth maintenance.
  * $A$ changes only finitely often, and is constant once $d\ge d_1^\*$. Here $d_1^\*$ is the largest depth at which some answer $\mathrm{Ref}_d(B)$, $B\subseteq\Sigma^P$, changes. With the default tie-breaking this is the largest minimal-refutation size of a subset of $\Sigma^P$ that is not clean at every depth.
  * *(Added after verification.)* The changes need not be retractions. Because the union of minimal conflicts is not monotone in $d$, $A$ is not monotone in $d$ either: a new small conflict can make an old larger one non-minimal, and so restore a schema withheld as collateral. [computed: `depth_nonmono.py`: practice {MP, AC}, $A=\{\mathrm{AC},\mathrm{MP}\}$ for $d<9$, $A=\emptyset$ for $9\le d<29$, $A=\{\mathrm{MP}\}$ for $d\ge29$.] Restored schemas are genuine or residual at the larger depth, so soundness is unaffected.
  * At each stage, (i) holds with the current depth.
  * In the limit, the tier is sound relative to $R^\*\cup R_{F_{\rm res}}$.
* **(v) Uniformity.** $G$ is defined by the human data alone, and $\mathrm{Ref}_d$ and $W$ are deterministic. So (i)–(iv) hold simultaneously for all provers and red teams. There is no union bound over queries.

*Proof.*
* *Step 1: identification.* Let $G$ be the event of T1 Thm 6.3 at sample size $N_1$, with budgets $e_i=\lfloor(\bar\alpha_i+\Delta)N_1\rfloor$: for every tag $i$, at most $e_i$ invalid steps are tagged $i$, and the valid tag-$i$ samples are $e_i$-robustly generic.
  * In the proof of T1 Thm 6.3, replace $\alpha_i$ by $\bar\alpha_i\ge\alpha_i$ and $\Delta_i$ by $\Delta\le\Delta_i$. The invalid count has mean at most $\bar\alpha_iN$. Each witness count has mean at least $(\bar\alpha_i+2\Delta)N$. Hoeffding and a union bound give
    $$\Pr(G^c)\le\sum_i(1+c_i)e^{-2N_1\Delta^2}\le(1+c)Ke^{-2N_1\Delta^2}\le\delta.$$
  * On $G$, T1 Thm 6.2(b) shows that the trimmed verifier of tag $i$ accepts exactly $\mathrm{inst}(\sigma_i)$.
  * A finite intersection of instance sets with a common instance is the instance set of the mgu. So $\hat\sigma_i$ is $\sigma_i$ up to renaming, and $\hat P=\Sigma^P$.
  * In noise-free mode ($e_i:=0$, so $\hat\sigma_i=\mathrm{lgg}(P_i)$), let $G$ be the event of T1 Thm 5.3. That theorem bounds $\Pr(G^c)$ by $\sum_ic_ie^{-N_1\pi_i\rho_i}$, with the ground-rule term $e^{-N_1\pi_i}$; with $\rho_i:=1$ and $c_i$ replaced by $\max(c_i,1)$ for ground rules, this is $\le cKe^{-N_1\lambda}\le\delta$. *(Corrected after verification: with the noisy budget $e_i=\lfloor\Delta N_1\rfloor>0$, Thm 5.3's event does not imply identification.)*
  * $G$ depends only on the human data. Human answers to escalated queries are not part of the sample (§3.1).
* *Step 2: audit.* On $G$, Lemma 3.1 applies to $\hat P=\Sigma^P$. This gives (iii), the cleanness claim in (i), and the audit part of (ii).
* *Step 3: soundness.* Before $N_1$ the tier accepts nothing. After $N_1$ the accepted set is $R_A$ with $A\subseteq\Sigma^\*\cup F^{(d)}_{\rm res}$, so $R_A\subseteq R^\*\cup R_{F^{(d)}_{\rm res}}$. The closure inclusion is T1 Lemma 1.1, applied with the calculus $R^\*\cup R_{F^{(d)}_{\rm res}}$ (or $R^\*\cup T_{\rm rust}\cup R_{F^{(d)}_{\rm res}}$) as "target".
* *Step 4: sandbox.* Prop 3.3(b) with the assumed $h_0$ gives the sandbox clause of (ii). Prop 3.3(a) shows that sandbox activity cannot affect (i).
* *Step 5: depth schedule.*
  * By either tie-breaking rule, each $\mathrm{Ref}_d(B)$ changes at most twice as $d$ grows, and is constant beyond its last threshold. If $B$ is clean at every depth, it is NONE for all $d$.
  * There are only $2^{|\Sigma^P|}$ sets $B$. So the audit's whole computation, and hence $A$, is constant for $d\ge d_1^\*$, and changes at most at the finitely many thresholds below $d_1^\*$.
  * At each stage Steps 2–3 apply with the current $d$. ∎

**Corollary 4.2 (truth-soundness) [proved].** Suppose $R^\*$ is 𝔐-sound and every member of $F^{(d)}_{\rm res}$ is 𝔐-valid, which holds vacuously if $F^{(d)}_{\rm res}=\emptyset$. If the reasoner uses trusted steps, suppose they are 𝔐-sound too. Then on $G$ the reasoner derives only 𝔐-consequences, at all times and against all provers. *(Added after verification.)* This also holds for a reasoner that chains world-channel steps (§3.1) with $R_A$-steps, provided $W$ is 𝔐-truth on $D_W$. Such steps preserve $W$-truth and hence 𝔐-truth, although they need not lie in $\mathrm{Sound}(R^\*)$.

**Remarks.**
1. *What is and is not certified.*
   * Genuine rules are never *certified* valid by anything in the architecture. Their assertion rests on positive data (anchoring with margin) plus presumption of validity after audit.
   * Fallacies are certified *invalid*, by descent, or implicated as a set, by conflicts.
   * This asymmetry is forced by Lemma 2.1: all non-imitative evidence is refutational.
2. *Realizability is load-bearing.* This is T1's weakness 1, unchanged. If the human calculus has a rule outside the class, Step 1 fails. Nothing downstream repairs that. At best the audit removes an over-general identified schema, which restores soundness but not completeness. Quantifier rules and the induction schema are such rules (Cor 6.5, Thm 6.6(e), both revised after verification).
3. *Why freeze.* Freezing $\hat P$ at $N_1$ keeps the probability accounting to a single event.
   * Continuing to learn is possible: a union bound over $N\ge N_1$ costs an additive $\ln\frac1{1-e^{-2\Delta^2}}\approx\ln\frac1{2\Delta^2}$ inside the logarithm.
   * In that case the audit must be re-run whenever $\hat P$ changes.
4. *Before $N_1$.* Abstention can be softened. Steps all of whose judgments are evaluable can be settled by the world channel, and steps derivable in a *trusted base* can be accepted. Both are separate channels (§3.1): they are truth-sound (Cor 4.2), but not covered by the $R^\*$-closure inclusion of (i) unless they lie in $\mathrm{Sound}(R^\*)$. Thm 5.5 shows that no learner can do much better on the fallacy-candidate schemas.

---

## 5. Each ingredient is necessary: minimax lower bounds

Throughout this section, "a learner" means any (randomized) procedure that receives the same kinds of information as TTL, possibly with a given channel removed: the human data stream, refutation-oracle answers and $W$.

*Standing conventions (made explicit after verification).*
* Escalation answers, if a learner uses them, follow the practice, so they have the same law in every scenario with that practice. A target-truthful labeller ($y=1[q\in R^\*]$) would be a different and stronger channel, T1's labelled setting, and would defeat Thms 5.5–5.6.
* Lower bounds use a fixed prover whose queries do not depend on the scenario.
* Fix a practice $\Sigma^P$ with its frequencies, instance laws and noise law, and fix $\mathcal A,W,T_{\rm rust}$. A target $\Sigma\subseteq\Sigma^P$ is **admissible** if it satisfies (WS) and $F_\Sigma:=\Sigma^P\setminus\Sigma$ satisfies Def 1.1, i.e. each member has an instance outside $\mathrm{Sound}(R_\Sigma)$.
* By §1.3, (WS) for Σ is equivalent to Σ being clean at every depth.
* All admissible targets share the data law and the oracle answers (Lemma 2.1(c)), and satisfy (Floor) with the same constants.

**Proposition 5.1 (positive data) [proved; TOSU] (hypothesis added after verification).** Let $\Sigma_1\subsetneq\Sigma_2$ be calculi such that every subset of $\Sigma_2$ is clean at every depth, and such that $R_{\Sigma_2}\not\subseteq\mathrm{Sound}(R_{\Sigma_1})$, i.e. some rule of $\Sigma_2\setminus\Sigma_1$ is not derivable in $\Sigma_1$. Suppose a learner receives only refutation evidence: oracle answers on schema sets of its choice, but no human steps.
* Its view is the same under targets $\Sigma_1$ and $\Sigma_2$, by Lemma 2.1(c).
* So if it accepts a step of $R_{\Sigma_2}\setminus\mathrm{Sound}(R_{\Sigma_1})$, a nonempty set by hypothesis, with probability $p$ under one target, it does so with probability $p$ under the other. It is either unsound for $\Sigma_1$ (plain soundness, $\mathrm{Sound}(R_{\Sigma_1})$) or incomplete for $\Sigma_2$.
* Example: $\Sigma_1=\{\wedge\mathrm I,\wedge\mathrm E_1,\wedge\mathrm E_2\}$ and $\Sigma_2=\Sigma_1\cup\{\vee\mathrm I_1\}$, with classical evaluation. Here $\vee\mathrm I_1$ is not derivable in $\Sigma_1$.
* Without the non-derivability hypothesis the dichotomy can fail. Take $\Sigma_2=\Sigma_1\cup\{(A\wedge B\,/\,B\wedge A)\}$ with this $\Sigma_1$: accepting $R_{\Sigma_2}$ is both sound for $\Sigma_1$ and complete for $\Sigma_2$.

*Honest qualification.* This concerns soundness relative to the *human* calculus. In CPC, structurality plus closed evaluation decides schema validity (Lemma 6.1). A learner that wants only *truth*-soundness could enumerate schemas and assert the valid ones without any human data. Positive data are then needed only to say *which* valid rules the practice uses. In arithmetic, positive data are needed even for truth-completeness, because no refutational evidence ever certifies a true Π₁ axiom.

**Proposition 5.2 (caution) [proved] (part (a) revised after verification).**
* **(a)** *(Joint-probability form of T1 Thm 3.1(b), relative to the residue.)* Let 𝒯 be the admissible targets for the given practice. Take any learner, a fixed prover, a finite history $h$ and a step $q$.
  * The joint probability $p(h,q):=\Pr[\text{the run produces }h\text{ and then accepts }q]$ is the same under every $\Sigma\in\mathcal T$, because the data law and the oracle answers are.
  * Hence if $q\notin\bigcap_{\Sigma\in\mathcal T}\mathrm{Sound}\big(R_\Sigma\cup R_{F^{(d)}_{\rm res}(\Sigma)}\big)$, the learner is unsound with probability $\ge p(h,q)$ under some admissible target. Here $F^{(d)}_{\rm res}(\Sigma)$ is the depth-$d$ residue when Σ is the target.
  * A learner that is δ-sound under every admissible target therefore has $p(h,q)\le\delta$ for every such $q$.
  * *TTL passes.* On $G$, $R_A\subseteq R_\Sigma\cup R_{F^{(d)}_{\rm res}(\Sigma)}$ for **every** $\Sigma\in\mathcal T$.
* **(b)** In particular, the following learners accept a falsified instance of some $\tau\in F\setminus F^{(d)}_{\rm res}$ *before* the refutation implicating τ is found:
  * presumption without audit (Prop 2.4(b));
  * the bold coalition used as the assertion tier, *for priors under which every coalition member contains such an instance*, e.g. a prior concentrated on the practice hypothesis $R^P$. T2 Thm 2.2(iii) gives soundness only while $R^\*\in S_t$, and nothing forces $R^\*$ into $S_t$. Conversely, a prior with more than half its mass on $R^\*$ gives $S_t=\{R^\*\}$ and a sound coalition *(qualified after verification)*;
  * any MAP or MDL learner over practice (T1 Prop 2.4).
  
  An adaptive prover that knows $F$ queries such an instance at once. In CPC with $\Sigma^\*$ complete and τ pure, it queries the closed ⊤/⊥ falsified instance of Lemma 6.1, and that single step makes every formula derivable from ∅ (Prop 2.2).

*Proof of (a).*
* The prover is fixed. The learner's information (data, oracle answers, $W$, escalation answers) has the same law under every $\Sigma\in\mathcal T$. Coupling the learner's coins, the run up to and including the answer to $q$ has the same law, so $p(h,q)$ is scenario-independent.
* If $q\notin\mathrm{Sound}(R_\Sigma\cup R_{F^{(d)}_{\rm res}(\Sigma)})$ for some admissible Σ, then under Σ the event "$h$ and then $q$ accepted" is an unsound acceptance.
* *TTL passes.* On $G$ the audit runs on $\hat P=\Sigma^P$, identically in all admissible scenarios.
  * Every schema it removes by descent is outside every admissible Σ. Indeed $V_\Sigma$ extends $e$ and falsifies no trusted step, so $e^+_\pi$ agrees with $V_\Sigma$ (proof of Lemma 2.5). The output step then has $V_\Sigma$-true premises and a $V_\Sigma$-false conclusion, so it is not in $R_\Sigma$.
  * Hence every admissible Σ is contained in the returned set (descent path) or in $B_0$ (fallback).
  * Let $x\in A\setminus\Sigma$. On the descent path, $\Sigma\cup\{x\}\subseteq A$ is $d$-clean. In the fallback, if $\Sigma\cup\{x\}$ were not $d$-clean it would contain a minimal conflict $C\subseteq B_0$ with $C\not\subseteq\Sigma$, so $x\in C$, contradicting $x\notin\bigcup\mathcal C_d(B_0)$.
  * Either way $x\in F^{(d)}_{\rm res}(\Sigma)$.

*Remarks on (a).*
* The earlier statement used the *conditional* acceptance probability given $h$. That is false for randomized learners, as T1 itself notes. Here is T1's "reckless" example transposed to this setting. The learner flips a coin at time 0. With probability ε it accepts every query from time 1 on; otherwise it runs TTL. It is $(\delta+\varepsilon)$-sound. But the history "$q_1$ accepted at time 1" occurs only in reckless mode, and given that history the learner accepts any fallacy instance with conditional probability 1.
* The earlier statement also used plain $\mathrm{Sound}(R_\Sigma)$. Typically $\emptyset\in\mathcal T$ (cf. Prop 2.4(a)); that makes the intersection trivial and convicts TTL itself. Relativizing to the residue is what separates TTL from the learners in (b). ∎

**Proposition 5.3 (negative evidence) [proved].** Let practice be $\{\wedge\mathrm I,\mathrm{AC}\}$ with fixed frequencies, and compare two worlds.
* $W_1$: classical tables. AC is a fallacy, the target is $\{\wedge\mathrm I\}$ and $F=\{\mathrm{AC}\}$.
* $W_2$: classical tables, except that → is read as ↔. AC is valid ("from $B$ and $A\leftrightarrow B$ infer $A$"), the target is $\{\wedge\mathrm I,\mathrm{AC}\}$ and $F=\emptyset$.

A learner without refutation evidence sees identically distributed data in both worlds. It is therefore unsound under $W_1$ or incomplete under $W_2$; this is T1 Cor 6.5 in two-world form. With evaluation, the closed instance $(\top,\ \bot\to\top\ /\ \bot)$ separates the worlds: under $W_1$ both premises are true and the conclusion is false, while under $W_2$ the premise $\bot\leftrightarrow\top$ is false. ∎

**Proposition 5.4 (structurality) [proved; TOSU].**
* (a) If hypotheses are instance sets rather than schemas, each refutation removes finitely many instances. A fallacy with infinitely many invalid instances then keeps some invalid instance asserted at every finite time, under any learner that asserts the practice minus the refuted instances.
* (b) Without uniformity, coherence is toothless (T2 Prop 6.3: $\mathbf C_2+\{\rhd p_{17}\}$).
* (c) Without structure, positive data cannot generalize at all: $\bigcap\mathrm{VS}(P)=P$ for exception-list classes (T1 §4 discussion). ∎

**Theorem 5.5 (burn-in is necessary: the rare refuter) [proved] (revised after verification).** Let $0<\pi<1$, and let $\sigma,\tau,\mu$ be schemas such that:
* $\{\sigma,\tau\}$ and $\{\sigma,\mu\}$ are clean at every depth (hence so is $\{\tau\}$);
* $\{\mu,\tau\}$ is a $d$-conflict.

(The schema called ρ in the earlier version is renamed μ, to avoid a clash with the variability $\rho_i$.) Compare two scenarios with the same $\mathcal A,W,T_{\rm rust}$; both targets are admissible in the sense of the §5 conventions.
* **Scenario 1:** target $\{\sigma,\mu\}$, $F=\{\tau\}$. Tags σ, τ, μ have frequencies $(1-\pi)q_\sigma$, $(1-\pi)q_\tau$, $\pi$.
* **Scenario 2:** target $\{\sigma,\tau\}$, $F=\emptyset$. Tags σ, τ have frequencies $q_\sigma$, $q_\tau$.

The per-tag instance laws are the same in both. The prover is fixed and does not depend on the scenario, and escalation answers follow the practice (§5 conventions). Then for every learner and every $t$: if under scenario 1 the learner accepts at time $t$ some τ-instance $s\notin\mathrm{Sound}(R_{\{\sigma,\mu\}})$ with probability at most δ, then under scenario 2 it accepts $s$ at time $t$ with probability at most $\delta(1-\pi)^{-t}$.

Hence, if $\delta+\delta'<1$, accepting $s$ at time $t$ in scenario 2 with probability $\ge1-\delta'$ requires
$$t\ \ge\ \frac{\ln\frac{1-\delta'}{\delta}}{\ln\frac1{1-\pi}}\ \ge\ \frac{1-\pi}{\pi}\,\ln\frac{1-\delta'}{\delta}.$$
* The second inequality uses $\ln\frac1{1-\pi}\le\frac\pi{1-\pi}$ and $\ln\frac{1-\delta'}\delta>0$. It fails without $\delta+\delta'<1$: for $\delta=\delta'=0.6$ and $\pi=1/2$ the two sides are $-0.585$ and $-0.405$ *(hypothesis added after verification)*.
* The first bound is attained. The learner that, at time $t$, accepts τ-instances iff no μ-tag occurs among the first $t$ samples has scenario-1 error exactly $(1-\pi)^t$ at time $t$, and scenario-2 completeness 1.

*Proof.*
* Let $E_t$ be the event that none of the first $t$ samples has tag μ, so $\Pr_1(E_t)=(1-\pi)^t$.
* Conditioned on $E_t$, the first $t$ samples under scenario 1 are i.i.d. with exactly scenario 2's law, because the frequencies renormalize to $q_\sigma,q_\tau$.
* Oracle answers depend only on the queried schema sets (Lemma 2.1(c)). They are identical in both scenarios, even if the learner queries sets containing μ. The prover's queries and the escalation answers do not depend on the scenario, by assumption. Without that assumption, a target-truthful labeller could separate the scenarios with one escalated τ-instance.
* Hence $\Pr_1(\text{accept }s\text{ at }t)\ge(1-\pi)^t\Pr_2(\text{accept }s\text{ at }t)$.
* Such an $s$ exists. Otherwise every τ-instance would be derivable in $\{\sigma,\mu\}$, and the refutation of $\{\mu,\tau\}$ would become a refutation of $\{\sigma,\mu\}$ by T1 Lemma 1.1, contradicting cleanness.
* In scenario 2, $s$ is a genuine instance. ∎

This is the standard two-point rare-event lower bound, of the kind behind PAC sample-complexity lower bounds. Its only content here is that the relevant rare event is the absence of the *refuter* μ.

*Concrete instance.* Use the context $A_1=\{q,\ p\to q,\ p\to\bot\}$ with no world. Take $\sigma=\wedge$I, $\tau=$ AC and $\mu=$ MP.
* The closure of $A_1$ under AC alone is $\{q,p\to q,p\to\bot,p\}$ [computed]. *(Corrected after verification.)* Under $\{\wedge\mathrm I,\mathrm{AC}\}$ the closure is infinite, since it contains all conjunctions of those four formulas. It contains no ⊥, because ∧I creates no implications and AC needs an implication premise with consequent $q$ or ⊥.
* $\{\wedge\mathrm I,\mathrm{MP}\}$ is classically sound.
* AC then MP yields ⊥ in two steps.

*Reading (corrected after verification).* Suppose modus ponens is rare, with frequency π. Then no learner that is sound whether or not AC is a fallacy can accept AC, in the scenario where AC is genuine, before about $\pi^{-1}\ln(1/\delta)$ samples. That is roughly the time by which MP, the rule that would expose AC if it were a fallacy, has been seen with confidence; MP has then been seen about $\ln(1/\delta)$ times. The upper bound $N_1$ has the same order: in noise-free mode it is $\lambda^{-1}\ln(cK/\delta)$, with $\lambda\le\pi\rho_{\rm MP}$. This matches up to the $\ln K$ factor and the variability $\rho_{\rm MP}$.

**Theorem 5.6 (blame: world or bilateral evidence is necessary for completeness) [proved] (revised after verification).**

**(a) Two-point core.** Let μ, τ be schemas and $\Sigma_0$ a calculus such that:
* $\Sigma_0\cup\{\mu\}$ and $\Sigma_0\cup\{\tau\}$ are clean at every depth;
* $\{\mu,\tau\}$ is a $d$-conflict.

(The schema called ρ in the earlier version is renamed μ, as in Thm 5.5.) Compare scenario 1 (target $\Sigma_0\cup\{\mu\}$, $F=\{\tau\}$) with scenario 2 (target $\Sigma_0\cup\{\tau\}$, $F=\{\mu\}$), with equal tag frequencies, a fixed prover, and the §5 conventions. Then:
* the data and all oracle answers have identical laws in the two scenarios;
* there is a genuine μ-instance $s$ such that every learner that is δ-sound in both scenarios accepts $s$ in scenario 1 with probability at most δ;
* so μ, which lies in $\mathrm{Coll}_d$ in scenario 1, is collateral for **every** sound learner. *(The earlier clause "and TTL's fallback, which withholds $\bigcup\mathcal C_d$, is optimal" does not follow from this two-point argument. It is replaced by (b) and (c).)*

*Proof of (a).*
* The practice $\Sigma_0\cup\{\mu,\tau\}$ and its frequencies coincide in the two scenarios, and oracle answers are target-independent (Lemma 2.1(c)).
* Some μ-instance $s$ lies outside $\mathrm{Sound}(R_{\Sigma_0\cup\{\tau\}})$. Otherwise, by T1 Lemma 1.1, the refutation of $\{\mu,\tau\}$ would transfer to the clean set $\Sigma_0\cup\{\tau\}$.
* μ is not residual in scenario 2, because $\Sigma_0\cup\{\tau,\mu\}$ contains the conflict $\{\mu,\tau\}$. So soundness in scenario 2 caps the probability of accepting $s$ at δ. The same cap holds in scenario 1, where $s$ is genuine. ∎

**(b) Stable depth: the fallback is optimal among schema-level policies (added after verification) [proved].** Let $d\ge d_0$, so that $\mathrm{Conf}_d=\mathrm{Conf}_\infty$. Suppose that on $G$ the audit falls back at $B_0$; this computation is the same in all admissible scenarios. Then for every $g\in\bigcup\mathcal C_d(B_0)$ there are:
* an admissible target $M\subseteq B_0$ with $g\notin M$ and $F^{(d)}_{\rm res}(M)=\emptyset$;
* an instance $s_g\in\mathrm{inst}(g)\setminus\mathrm{Sound}(R_M)$.

Consequences:
* Every learner that is δ-sound under every admissible target accepts $s_g$, at any fixed time, with probability at most δ under every admissible target, in particular under the true one.
* *Necessary collateral.* Every genuine $g\in\mathrm{Coll}_d(B_0)$ is withheld, on some instance, by every such learner.
* *Schema-level optimality.* The same holds for every schema of $\Sigma^P$ outside $A=B_0\setminus\bigcup\mathcal C_d(B_0)$. For a schema outside $B_0$, the witness is the falsified instance found by descent, together with any maximal $M$. So a policy that asserts $R_{A'}$ for a (possibly random) $A'\subseteq\Sigma^P$, and is δ-sound under every admissible target, includes each schema outside $A$ with probability at most δ. TTL's fallback asserts exactly $R_A$.
* On the descent path (no fallback) the same holds with $M:=A$. At stable depth $A$ is clean at every depth and is itself admissible, by the second case below, and every schema outside $A$ has a descent witness.
* At the level of *instances* more can be asserted: Prop 2.4(c).

*Proof of (b).*
* *Choice of M.* Apply Lemma 2.3(b) with $\mathcal U=B_0$ and $\mathcal K=\mathrm{Conf}_d\cap2^{B_0}$: $g$ lies outside some maximal $d$-clean $M\subseteq B_0$. Since $d\ge d_0$, $M$ is clean at every depth, so it satisfies (WS) (§1.3, equivalent form).
* *Each $x\in\Sigma^P\setminus M$ has an instance outside $\mathrm{Sound}(R_M)$, so $M$ is admissible.*
  * For $x\in B_0\setminus M$: $M\cup\{x\}$ is not $d$-clean, by maximality. If every $x$-instance were in $\mathrm{Sound}(R_M)$, replacing each $x$-step of a refutation of $M\cup\{x\}$ by an $R_M$-derivation (T1 Lemma 1.1) would give a refutation of $M$, contradicting cleanness at every depth.
  * For $x\in\Sigma^P\setminus B_0$: $x$ was removed by a descent on some π, with output $s\in\mathrm{inst}(x)$. The valuation $V_M$ extends $e$ and falsifies no trusted step, so $e^+_\pi$ agrees with it (proof of Lemma 2.5). Hence $s$ has $V_M$-true premises and a $V_M$-false conclusion. Since $V_M$ preserves truth along $R_M$-derivations, $s\notin\mathrm{Sound}(R_M)$.
* *$F^{(d)}_{\rm res}(M)=\emptyset$.* For $x\in B_0\setminus M$ this is maximality. For $x\notin B_0$, $\{x\}$ is itself a $d$-conflict, by Lemma 2.5(d), applied in the true scenario.
* *Witness for g.* $g\in B_0\setminus M$, so the first case gives $s_g$.
* *Conclusion.* All admissible scenarios share the data law and the oracle answers, the prover is fixed, and escalation answers follow the practice. So the probability that $s_g$ is accepted at a given time is the same under $M$ as under the true target. δ-soundness under $M$, relative to $R_M\cup R_{F^{(d)}_{\rm res}(M)}=R_M$, bounds it by δ. ∎

**(c) At finite depth the fallback can be strictly suboptimal (added after verification) [proved; computed: `thm56_finite_d.py`].**
* *Setting.* No world, practice {MP, AC}, $\mathcal A=\{[A_1:\emptyset],[A_2:\emptyset]\}$ with $A_2=\{\varphi,\ \bot\to\varphi\}$ and $\varphi=q\wedge(q\wedge q)$. Size counts symbols in distinct judgments.
* *Refutation sizes.* The minimal refutation sizes are 9 for {MP, AC} (on $A_1$) and 13 for {AC} (on $A_2$: AC infers ⊥ from φ and ⊥→φ). {MP} is clean at every depth.
* *What TTL does.* For $9\le d\le12$, $\mathcal C_d=\{\{\mathrm{MP},\mathrm{AC}\}\}$. The descent is blocked, and the fallback returns $A=\emptyset$, withholding MP.
* *Why that is suboptimal.* The admissible targets are only {MP} and ∅, because {AC} is refuted at size 13. Asserting $R_{\rm MP}$ after burn-in is sound under both: under {MP} trivially, and under ∅ because MP is residual, at depth $d$ and at every depth. That learner is strictly more complete than TTL$(d)$.
* *At stable depth.* For $d\ge13=d_0$, $\mathcal C_d=\{\{\mathrm{AC}\}\}$ and TTL returns {MP}, as (b) predicts. The depth schedule of Thm 4.1(iv) repairs (c) in the limit.

*The MP/AC witness: → versus ←.* Take $\mathcal A=\{A_1\}$ with $A_1=\{q,\ p\to q,\ p\to\bot\}$, no world, $\Sigma_0=\emptyset$, $\mu=$ MP and $\tau=$ AC.
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

Two caveats *(the first revised after verification)*.
* *Full depth.* The earlier caveat said the full-depth status was open because the rival $\{S,DN,AC\}$ might not be clean. That misdiagnosed what is open.
  * $\{\mathrm{AC},K\}$ and $\{\mathrm{AC},\mathrm{MP}\}$ are minimal conflicts at **every** depth beyond their sizes. $\{\mathrm{AC}\}$ is clean at every depth on $\{\emptyset,A_1\}$: from ∅ it derives nothing, and the closure of $A_1$ under AC alone is $\{q,p\to q,p\to\bot,p\}$. $\{K\}$ and $\{\mathrm{MP}\}$ are classically sound.
  * With no world and no trusted steps every descent is blocked, so the fallback runs at $B_0=\Sigma^P$. By Thm 5.6(b), $K$ and MP are **necessarily** collateral at full depth, whichever maximal clean set is the rival.
  * What remains open (Open Problem 2) is whether $\{S,DN,AC\}$ is clean at every depth, equivalently whether $\mathrm{Coll}_\infty=\{K,\mathrm{MP}\}$ or also contains $S$ or $DN$. No 2-, 3- or 4-valued matrix witnesses its cleanness [computed: `matrix_witness.py`; `matrix4.py`, exhaustive backtracking, 5.0M nodes for $n=4,|D|=3$].
* A prior that prefers fewer fallacies ("protect the centre", in Quine's sense) picks $\{\mathrm{AC}\}$ over $\{K,\mathrm{MP}\}$. In the core $\{\mathrm{MP},\mathrm{AC}\}$ case it is silent, unless it uses frequency. T5 Prop 4.2 shows that frequency does not track validity.

**Theorem 5.7 (depth relativization is necessary) [proved, modulo the standard encoding of T2 Thm 5.3(a)] (statement made precise after verification).** There is a uniformly computable family of practices $(\Sigma^P_e)_{e\in\mathbb N}$ with the following properties: fixed $\mathcal A=\{[\emptyset:\emptyset]\}$, no world, and frequencies and per-tag instance laws that are computable uniformly in $e$. For this family, and for the fixed prover that queries $\vdash\mathrm{start}_e$ at every round, no computable learner achieves both of the following for all $e$, for any δ < 1/2:
* (a) δ-soundness at all times relative to the full-depth residue: $\Pr(\exists t:\text{accepts a step outside }R^\*\cup R_{F_{\rm res}})\le\delta$;
* (b) eventual completeness: $\Pr(\exists t\ \forall t'\ge t:\ R^\*\subseteq\text{accepted at }t')\ge1-\delta$.

*Proof.*
* *Construction.* Let $\Sigma_0$ be a finite elementary formal system with judgments $\mathrm{start}_e$. It simulates the universal machine on input $e$ from $\mathrm{start}_e$, and contains the rule "$\mathrm{halt}\vdash\bot$" (T2 Thm 5.3(a)).
  * $\Sigma_0$ has no 0-premise rules, so without a start judgment nothing is derivable, and $\Sigma_0$ is clean. In particular $(\emptyset,\mathrm{start}_e)\notin R_{\Sigma_0}$, and it is not in $\mathrm{Sound}(R_{\Sigma_0})$ either.
  * Let $\tau_e$ be the 0-premise rule "$\vdash\mathrm{start}_e$", and $\Sigma^P_e:=\Sigma_0\cup\{\tau_e\}$, with fixed frequencies.
  * If $\varphi_e(e)\!\uparrow$, the target is $\Sigma^P_e$ and $F=\emptyset$.
  * If $\varphi_e(e)\!\downarrow$, the target is $\Sigma_0$ and $F=\{\tau_e\}$. Here $\tau_e\notin F_{\rm res}$, since $\Sigma_0\cup\{\tau_e\}$ is incoherent. Accepting $\vdash\mathrm{start}_e$ is then a step outside $R^\*\cup R_{F_{\rm res}}=R_{\Sigma_0}$.
* *Uniformity (replaces the earlier "indistinguishability" bullet, which was vacuous: for each $e$ only one case occurs).* The data laws and the oracle answers are computable uniformly in $e$. The argument uses this computability, not an indistinguishability of two scenarios.
* *Reduction.* Let $S=\{e:\exists t\ \Pr(\text{the learner accepts }\vdash\mathrm{start}_e\text{ by time }t)>1/2\}$.
  * If $\varphi_e(e)\!\uparrow$, then (b) and continuity of measure give $e\in S$.
  * If $\varphi_e(e)\!\downarrow$, then (a) gives $\Pr(\text{ever accepts})\le\delta<1/2$, so $e\notin S$.
  * So $S=\overline K$.
* *Contradiction.* For a computable learner, given the computable data laws, oracle and prover, the probability of acceptance by time $t$ is a lower-semicomputable real, uniformly in $(e,t)$. So $S$ is $\Sigma_1$. But $\overline K$ is not $\Sigma_1$. ∎

So TTL's form of soundness cannot be improved by any computable procedure: sound at time $t$ relative to $F^{(d_t)}_{\rm res}$, and relative to $F_{\rm res}$ only in the limit, with retractions. This is the Π₁-completeness of coherence (T2 Thm 5.3) turned into a statement about *anytime* soundness.

**Proposition 5.8 (truthful designation) [cited; T2 Prop 7.1 and Thm 2.5].**
* If a designated position violates (WS), descent can blame a genuine rule.
* Under structurality, a single classically inconsistent designated context forces the loss of a classical schema everywhere (T2 Prop 7.1).
* Prop 3.2 bounds the damage when at most $m$ positions (it is not known which) violate (WS); T2 Thm 2.5 is the soft version.
* Nothing bounds the damage of an unknown number of mis-designations.

| ingredient dropped | failure mode | witness |
|---|---|---|
| positive data | target-independent evidence; nested sound calculi indistinguishable | Prop 5.1 |
| caution (audit-then-assert) | adaptive prover exploits an unaudited fallacy; trivialization in CPC | Prop 5.2 |
| negative evidence | fallacy ≡ rule (→ vs ↔ worlds) | Prop 5.3, T1 Cor 6.5 |
| structurality | instance-level refutation never converges; coherence toothless | Prop 5.4, T2 Prop 6.3 |
| burn-in | rare refuter: $t\gtrsim\pi^{-1}\ln(1/\delta)$ | Thm 5.5 |
| world / bilateral blame | MP–AC (→ vs ←) symmetry; collateral for every sound learner (at stable depth) | Thm 5.6 |
| depth relativization | Π₁ barrier for anytime soundness | Thm 5.7 |
| truthful designation | global loss of classical schemas | Prop 5.8, T2 Prop 7.1 |

---
## 6. Specializations: what provably works for formal mathematics

### 6.1 Classical propositional logic

*Setting.*
* The language has ¬, ∧, ∨, →, ⊤, ⊥ over atoms. Judgments are formulas, or sequents with finite contexts (for natural deduction). Contexts are *lists*, with explicit structural rules. Set or multiset contexts would need anti-unification modulo AC, for which T1 §5's bounds are not proved *(restriction added after verification)*.
* All schemas are **pure**: they contain metavariables only and no object atoms. This is structurality; Prop 5.4 shows it cannot be dropped, and L5 Prop 2.5 shows that α-renaming alone is not enough.
* $\Sigma^\*$ is any finite set of classically valid pure schemas that is complete for classical consequence, e.g. a Hilbert system or a sequent-style natural deduction.
* $F$ is any finite set of classically invalid pure schemas.
* The world is $D_W=$ closed (atom-free) formulas, with $W=$ truth-table value. This is "computation".
* $\mathcal A$ consists of any truthful positions, and contains $[\emptyset:\emptyset]$ (§1.3 convention).

**Lemma 6.1 (closed-instance refutability; Post's substitution) [proved].** A pure schema τ is classically invalid iff some substitution of ⊤/⊥ for its metavariables yields a closed instance whose premises are $W$-true and whose conclusion is $W$-false. Such an instance has size $|\tau|$, and there are at most $2^{v(\tau)}$ candidates, where $v(\tau)$ is the number of metavariables.

*Proof.* (⇐) A falsified instance is an invalid instance. (⇒) Let $\tau\theta$ be an instance and $v$ a valuation making its premises true and its conclusion false. Put $c_x:=\top$ if $v(\theta x)=1$ and $c_x:=\bot$ otherwise. By induction on the structure of τ, every subformula of $\tau[c_x/x]$ has the same value as the corresponding subformula of $\tau\theta$ under $v$. Metavariable positions agree by the choice of $c_x$, and the connectives are truth-functional. Closed formulas take the same value under every valuation. ∎ (This is step 2 of T2 Thm 3.1.)

For sequent judgments with a context metavariable Γ, substitute the one-element list $[\top]$ or $[\bot]$ according to $v(\bigwedge\Gamma\theta)$; the same argument applies [computed: `lemma61.py` checks the formula case by brute force, on 30,000 random pure schemas, 16,309 of them invalid, with 0 mismatches].

**Corollary 6.2 (TTL on CPC is exact, truth-sound and uses at most $|F|$ refutations) [proved] (counts corrected after verification).** Let $d\ge\max_{\tau\in F}|\tau|$. Implement $\mathrm{Ref}_d$ via Lemma 6.1: return the first, in a fixed enumeration order, closed ⊤/⊥ instance of a schema of $B$ that has $W$-true premises and a $W$-false conclusion, if one exists, and NONE otherwise.
* This oracle is exact for size-$\le d$ refutations. If every schema of $B$ is classically valid, $B$ has no refutation at any size: take a classical valuation agreeing with the truthful position and with $W$; it falsifies no valid step. Otherwise Lemma 6.1 gives a one-step refutation of size $\le d$.
* Its refutations are one-step and fully evaluable, so every descent is unblocked. It is an instance of the prefer-unblocked tie-breaking of §3.1.

Then on $G$, with $\Pr(G)\ge1-\delta$:
* **(a)** The minimal conflicts are exactly the singletons $\{\tau\}$ for $\tau\in F$. So (SB$_d$) holds, $\mathrm{Coll}_d=\emptyset$ and $F^{(d)}_{\rm res}=\emptyset$.
* **(b)** The assertion tier abstains before $N_1$ and accepts exactly $R^\*$ afterwards. For every premise set $B$ the reasoner derives exactly $\mathrm{Cl}_{R^\*}(B)$, which is the set of classical consequences of $B$. This holds for derivations of any length and formulas of any size (T1 Cor 5.5), against any prover.
* **(c)** The audit makes **at most** $|F|+1$ oracle calls and at most $|F|$ successful descents (refutations). There are fewer when one falsified step is an instance of several fallacies. For example, $(\top,\ \bot\to\top\ /\ \bot)$ is a falsified instance of both AC and $(\top,\ A\to\top\ /\ A)$, and one descent removes both [computed: `lemma61.py`].
  * *Evaluation cost (corrected).* Each oracle call checks at most $\sum_{\sigma\in B}2^{v(\sigma)}$ closed instances, *including those of the genuine schemas*, which certify the final NONE. Each check evaluates at most (number of premises + 1) closed formulas.
  * The total is at most $(|F|+1)\sum_{\sigma\in\Sigma^P}2^{v(\sigma)}$ instance checks, or $\sum_{\sigma\in\Sigma^P}2^{v(\sigma)}$ if per-schema results are cached. The earlier bound $\sum_{\tau\in F}2^{v(\tau)}$ omitted the genuine schemas.
* **(d)** The tier is truth-sound at all times (Cor 4.2).

*Proof.*
* By Lemma 6.1, each τ has a one-step $d$-refutation, so $\{\tau\}\in\mathrm{Conf}_d$.
* Every member of $\mathrm{Conf}_d$ contains some fallacy τ (Lemma 2.1(b)), and hence contains the conflict $\{\tau\}$. So the minimal members are exactly these singletons.
* Each $\Sigma^\*\cup\{\tau\}$ is unclean, so $F^{(d)}_{\rm res}=\emptyset$.
* Thm 4.1(iii) gives $A=\Sigma^\*$. Completeness of $\Sigma^\*$ for classical consequence gives (b).
* Each audit iteration's descent is the one-step refutation itself. It removes every schema of $B$ having that step as an instance, all of them fallacies (Lemma 2.5(c)), and at least one. Hence there are at most $|F|$ successful descents. ∎

[computed: `ttl_sim.py`. The practice has 9 genuine tagged ND-style rules (∧I, ∧E₁₂, ∨I₁₂, MP, MT, DS, DNE) and 4 fallacies with their own tags (affirming the consequent, denying the antecedent, conversion, "or as xor"). Sporadic noise α = 0.01 is mis-tagged at random, with trim budget $e=2$. There are 20 trials per $N$. The adversarial prover enumerates every step over a 10-formula pool and checks it by truth table.

*Table regenerated after verification* from the committed script, `python3 ttl_sim.py 0`, which is deterministic across `PYTHONHASHSEED` values. The earlier table did not match the script's output in four cells, and its $N=500$ parenthetical was wrong.

| $N$ | positive-only cautious tier unsound | TTL unsound | TTL exact (= Σ*) | untrimmed + audit exact |
|---|---|---|---|---|
| 60 | 12/20 | **0/20** | 0/20 | 6/20 |
| 120 | 20/20 | **0/20** | 10/20 | 8/20 |
| 250 | 20/20 | **0/20** | **20/20** | 1/20 |
| 500 | 20/20 | **0/20** | **20/20** (one trial has > e noise, on the fallacy tag XOR, and is still exact) | 0/20 |

Reading the table:
* The positive-only cautious tier asserts the fallacies as soon as they are anchored (Prop 2.2).
* TTL is never unsound.
* Excess noise on a *fallacy* tag is harmless: whatever schema the trimmed lgg produces for that tag is world-refuted and dropped anyway.
* The untrimmed learner is kept sound by the audit, which refutes the collapsed lgg of T1 Prop 6.1. But it loses whole tags, and loses more of them as $N$ grows.
* One bug found while writing the script is worth recording. With $n\le e$ samples, the trimmed version space contains the empty rule. Its intersection is ∅, *not* "everything". Coding $\bigcap\emptyset$ as "accept all" made TTL unsound in 12/20 trials at $N=60$.
* Scope of the script: it tests the CPC singleton-conflict case with a fixed $e=2$ and a per-schema world audit. It does not exercise $\mathrm{Ref}_d$-with-descent on multi-step refutations, the fallback, or the $N_1$ formula.]

**Proposition 6.3 (coherence alone on CPC is sound but loses MP and K; one denial repairs it) [proved; computed] ((b) revised after verification).** Let $D_W=\emptyset$ and let $\mathcal A$ be truthful.
* **(a)** In the full language every τ ∈ F lies in some minimal conflict once $d\ge d_\tau$ (Def 1.6), with $\mathcal A\ni[\emptyset:\emptyset]$. The reason: $\langle\Sigma^\*\cup\{\tau\}\rangle$ is trivial (T2 Thm 3.1), so ⊥ is derivable from ∅, and $d_\tau$ is at most the size of the shortest such derivation. Hence $F^{(d)}_{\rm res}=\emptyset$ for $d\ge\max_\tau d_\tau$, and TTL is truth-sound.
* **(b)** $\mathrm{Coll}_d$ can be non-empty. Then TTL's fallback is incomplete, and at stable depth necessarily so (Thm 5.6(b)).
  * *Within the standing assumptions.* Let $\Sigma^\*$ be any complete full-language Hilbert system containing $K$ and MP, with $F=\{\mathrm{AC}\}$ and $\mathcal A=\{[\emptyset:\emptyset]\}$ or $\{[\emptyset:\emptyset],[A_1:\emptyset]\}$. Then $\{\mathrm{AC},K\}$ is a minimal conflict at every depth at least the size of the four-step derivation of §5 (Thm 5.6, Hilbert illustration). The reason: $\{\mathrm{AC}\}$ is clean at every depth on these positions (from ∅ it derives nothing; the closure of $A_1$ under AC alone is $\{q,p\to q,p\to\bot,p\}$), and $\{K\}\subseteq\Sigma^\*$. If $A_1$ is designated, $\{\mathrm{AC},\mathrm{MP}\}$ is a minimal conflict as well. With a counterexample position for AC, $\{\mathrm{AC}\}$ would itself be a conflict, and there would be no collateral; see (c).
  * With no world and no trusted steps every descent is blocked, so the fallback runs at $B_0=\Sigma^P$. Hence $K$, and with $A_1$ also MP, lie in $\mathrm{Coll}_d$ for all large $d$, and by Thm 5.6(b) every sound learner using coherence alone must withhold them as rules.
  * *Outside the standing assumptions* ($\Sigma^\*$ not complete for the full language): the computed examples. In the $\{\to,\bot\}$ Hilbert practice $\{K,S,MP,DN\}+AC$ on $\{\emptyset,A_1\}$, $\mathrm{Coll}\supseteq\{K,\mathrm{MP}\}$. In the core $\{\mathrm{MP},\mathrm{AC}\}$ on $A_1$, $\mathrm{Coll}=\{\mathrm{MP}\}$, by the two-point Thm 5.6(a).
  * The earlier text placed these two examples under §6.1's standing assumption, which they violate, and cited Thm 5.6 without the depth qualification.
* **(c)** *Bilateral repair.* Suppose that for each τ ∈ F, $\mathcal A$ contains a **counterexample position** $[\Pi':\{\varphi'\}]$, where $(\Pi',\varphi')$ is a closed falsified instance of τ (Lemma 6.1), so that the position is truthful, and $d\ge\max_\tau|\tau|$. Then (SB) holds and $A=\Sigma^\*$.

*Proof.*
* (a) T2 Thm 3.1, then Lemma 2.1(b) and Prop 2.4(c).
* (b) The minimality of $\{\mathrm{AC},K\}$ is argued in place. The rest follows from Thm 5.6(b) and the computations.
* (c) τ derives the denied φ′ from Π′ in one step, so $\{\tau\}\in\mathrm{Conf}_d$. Every conflict contains a fallacy (Lemma 2.1(b)) and hence a singleton conflict, so the minimal conflicts are exactly the singletons. Whether the audit descends or falls back, $A=\Sigma^\*$. ∎

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
* (b) A schema is a fallacy iff it has a $W$-falsified instance. So every τ ∈ F has a smallest falsified instance, of some size $f_\tau$. (This was called $d_\tau$ before verification; now $d_\tau\le f_\tau$ is the Def 1.6 quantity.)

*Proof.*
* *All premises true.* Each premise is the universal closure of a sentence true in 𝔐. Since $T$ is complete, $T$ proves that closure, and $\Sigma^\*$ derives the premise. So $\mathrm{Cl}_{R^\*}(\Pi)=\mathrm{Cl}_{R^\*}(\emptyset)$, which is the set of $W$-true sequents. Then $j\in\mathrm{Cl}_{R^\*}(\Pi)$ iff $W(j)=1$.
* *Some premise false.* Say $\Gamma\vdash\varphi$ is false. Using →I and ∀I, $\Sigma^\*$ derives from it the sentence $\forall\bar x(\bigwedge\Gamma\to\varphi)$. This sentence is false, so $T$ refutes it and $\Sigma^\*$ derives its negation. Hence ⊥, and then everything, is derivable: $\mathrm{Cl}_{R^\*}(\Pi)=J$.
* So $(\Pi,j)\in\mathrm{Sound}(R^\*)$ iff some premise is false or $j$ is true. This gives (a), and (b) follows. ∎

**Corollary 6.5 (TTL on complete decidable theories) [proved, conditional on realizability] (revised after verification).**

*Realizability hypothesis.* Suppose, in addition to the setting, that $\Sigma^\*$ and $F$ lie in a schema class for which T1 Thm 6.3's identification holds, e.g. first-order patterns, possibly with T1 §5's side-condition predicates such as the eigenvariable condition of ∀I. Then Thm 4.1 applies.

Take $d\ge\max_\tau f_\tau$ and $[\emptyset:\emptyset]\in\mathcal A$, and let $\mathrm{Ref}_d$ search the instances of size $\le d$ of the schemas of $B$ for a $W$-falsified one. This is exact, by Lemma 6.4. Then everything in Cor 6.2 holds verbatim:
* (SB) holds;
* $F^{(d)}_{\rm res}=\emptyset$;
* $A=\Sigma^\*$;
* the tier is truth-sound at all times on $G$;
* the audit makes at most $|F|+1$ oracle calls.

*The hypothesis is not established for the listed theories (caveat added after verification).*
* *∀-elimination.* The rule (from $\forall x\varphi$ infer $\varphi[t/x]$) is not a first-order pattern, because its conclusion is a substitution result, not a fixed term context. With $t$ arbitrary it is not a higher-order (Miller) pattern either. [computed: `ind_lgg.py`. The lgg of three ∀E instances is $(\forall x(?z_0+?z_1=?z_2)\ /\ ?z_3+?z_4=?z_5)$, which has the invalid instance $(\forall x(0+0=0)\ /\ 0+0=S0)$. More data only generalize it further.]
* *Infinite axiom families.* The usual axiomatizations of RCF and ACF$_p$ contain degree-indexed families: roots of polynomials of every odd degree, respectively of every degree. Presburger arithmetic contains an induction or congruence schema. None of these is a single first-order pattern. DLO is finitely axiomatized, so only the quantifier rules matter there.
* *What happens without realizability.* The identified schema for a non-pattern rule is in general an over-general lgg.
  * If it has an instance outside $\mathrm{Sound}(R^\*)$, which is the case for ∀E and induction, then with the total oracle $W$ it has a $W$-falsified instance (Lemma 6.4(b)). An audit of depth at least that instance's size then removes it, with singleton blame. If it has no such instance, it is sound anyway, by Lemma 6.4(a).
  * So TTL stays sound, eventually so under the depth schedule. But $A$ then lacks the rule, or contains a valid over-general replacement of it, and "exact" ($A=\Sigma^\*$) fails.
* *Two possible repairs, not carried out here.*
  * (i) An EFS-style encoding with auxiliary decidable judgments $\mathrm{Sub}(\varphi,x,t,\psi)$ ("ψ is $\varphi[t/x]$"), evaluated by $W$. ∀E becomes $(\forall x\varphi,\ \mathrm{Sub}(\varphi,x,t,\psi)\ /\ \psi)$, a first-order pattern. The human data must then record the auxiliary premises, and the infinite axiom families need similar auxiliary judgments (e.g. for polynomial degree). Lemma 6.4 would have to be re-verified for the encoded calculus.
  * (ii) An identification theorem for higher-order-pattern schemas. T1 §5 only says the theory "plausibly lifts".

  For induction, (i) is checked in `ind_sub_lgg.py` (Thm 6.6(e)).

*Remarks.*
1. **Why learn at all?** Here $W$ is already a sound and complete step checker, so learning is not needed for epistemic access. TTL adds two things.
   * It identifies *which* calculus the practice uses.
   * It makes deployed checking fast. Schema matching takes linear time, while $W$ is expensive *(citations corrected after verification)*:
     * real quantifier elimination is doubly exponential in the worst case (Davenport & Heintz 1988);
     * deciding RCF sentences is possible in exponential space (Ben-Or, Kozen & Reif 1986 [cited (u)]), and already the first-order theory of $(\mathbb R,+)$ needs exponential time (Fischer & Rabin 1974);
     * Presburger arithmetic needs $2^{2^{\Omega(n)}}$ time (Fischer & Rabin 1974) [cited].
     
     The audit calls $W$ only on the few instances needed to falsify each fallacy.
   
   This is a real computational dividend, but a modest one, and I do not want to oversell it.
2. **A restricted oracle shows the division of labour** *(revised after verification)*. Suppose $W$ evaluates only quantifier-free sentences with rational constants (numerical evaluation). For this remark, let the logical rules be trusted, as in §6.3.
   * Lemma 6.4(b) then fails for RCF. The fallacy τ = "$\vdash\neg\exists x\,(x\cdot x=1+1)$" ("2 has no square root", a 0-premise axiom) has no instance this oracle can evaluate, so it is world-adequate for this oracle.
   * Designate the true sentence $\exists x\,(x\cdot x=1+1)$; the position $[\{\exists x\,(x\cdot x=1+1)\}:\emptyset]$ is truthful in ℝ. Then τ and the trusted ¬E derive ⊥.
   * Descent goes backward through ¬E, giving $\neg\exists x(\ldots)$ the value 0, and outputs τ's 0-premise step. So $\{\tau\}$ is a singleton conflict.
   * Without trusted logic the conflict is the bag $\{\tau,\neg\mathrm E\}$. With the bilateral position $[\emptyset:\{\vdash\neg\exists x(x\cdot x=1+1)\}]$ it is $\{\tau\}$, by a one-step refutation.
   * The earlier version designated $[\{x\cdot x=1+1\}:\emptyset]$. Under this section's universal-closure semantics that asserts $\forall x\,(x\cdot x=2)$, which is false, so the position violated (WS). It also stated the fallacy as the sequent $x\cdot x=1+1\vdash\bot$, whose refutation needs cut or substitution and so is not a singleton.
   * So over ℝ, coherence with a designated truth catches what this computation misses. Over ℕ the converse holds: Δ₀ computation adds no refutations beyond coherence (T2 Lemma 3.7), but it adds *localization* (§6.3).
3. **Physics relevance (L5 §3.4).** The RCF core of olympiad algebra and geometry would be covered by Cor 6.5, once its realizability hypothesis is met. Trigonometric and analytic steps are not: $(\mathbb R,+,\cdot,\sin)$ interprets ℤ and is undecidable.

### 6.3 Arithmetic: precisely what is and is not achieved

*Setting.*
* The language is that of PA, and 𝔐 = ℕ.
* $T_{\rm rust}$ is the rules of first-order logic. The logic is fixed and the learner learns non-logical axiom schemas; logic itself can be learned first, by §6.1 at the propositional level.
* $D_W=$ Δ₀ sentences, and $W$ is computation.
* $\mathcal A$ consists of truthful positions.
* A practice axiom schema is *genuine* iff all its instances are true in ℕ.
  * So $\Sigma^\*$ may contain PA together with true extras such as Con(PA), and (WS) holds with $V=$ truth in ℕ.
  * Here $R^\*$ consists of 0-premise axiom steps, so the relevant target closure is $\mathrm{Cl}_{R^\*\cup T_{\rm rust}}$ (Thm 4.1(i)). The former third clause of (WS), $T_{\rm rust}\subseteq\mathrm{Sound}(R^\*)$, fails here; it has been dropped (§1.3).
  * $F$ is the set of practice schemas with a false instance.
* *Realizability (added after verification).* Identification (Thm 4.1, Step 1) needs every practice schema to be a realizable pattern. Ground axioms are 0-premise ground rules and are fine: the axioms of Q, each $\mathrm{Con}(T_j)$, $\neg\mathrm{Con(PA)}$. The induction schema is not a first-order pattern (see (e)). Parts (a)–(d) and (f) concern the audit and hold for any $\hat P=\Sigma^P$; part (e) is about identification and needs the encoding given there.

**Theorem 6.6 [proved, modulo cited Gödel II, Shoenfield's limit lemma and Post's hierarchy theorem].**
* **(a) False Π₁ axioms get singleton blame** *(depth bound and oracle corrected after verification)*. Suppose τ has a false instance $\forall\bar x\,\theta(\bar x)$ with θ in Δ₀, and let $\bar n$ be its least counterexample. The refutation is "$\vdash\forall\bar x\theta$ (by τ); $\forall$E (trusted) $\vdash\theta(\bar n)$", with $W(\theta(\bar n))=0$. Descent with the backward rule through ∀E (Lemma 2.5) blames τ alone.
  * *Depth.* For one quantified variable with $m$ free occurrences in θ, the refutation contains both $\forall x\theta$ and $\theta(\underline n)$, and each occurrence of $x$ becomes a numeral of size $n+1$. So $\tau\notin F^{(d)}_{\rm res}$ once $d\ge2|\theta|+m(n+1)+O(1)$; for $k$ variables, $(k+1)\big(|\theta|+m(n+1)+O(k)\big)$ suffices, with $n$ the largest component of $\bar n$. The earlier bound $|\theta|+|\bar n|+O(1)$ was too small: for $\theta(x)=x<S^5\,0$ (least counterexample 5) the refutation's judgments $\forall x\,(x<S^5\,0)$ and $S^5\,0<S^5\,0$ have sizes 10 and 13, total 23, against the earlier $|\theta|+|\bar n|+O(1)=8+6+O(1)$.
  * *Oracle.* Singleton blame needs $\mathrm{Ref}_d$ to return this unblocked refutation, so use the prefer-unblocked tie-breaking of §3.1. Under the default rule a smaller *blocked* refutation through learned axioms could trigger the fallback, and those axioms could become collateral.
  * With that oracle, no PA axiom is put at risk by τ's refutation, and that is the point.
  * If the refutation were run by coherence through Q's axioms instead, the bag would be $\{\tau\}\cup$ (Q-axioms used). Q's axioms would then be collateral wherever the learner learns them rather than trusts them.
  * So *computation is subsumed by coherence as a source of refutations (T2 Lemma 3.7), but not as a source of blame.*
* **(b) Under presumption of validity, false Σ₁ axioms survive.** Take $\tau=$ "$\vdash\neg\mathrm{Con(PA)}$" with $\Sigma^\*=$ PA and $\mathcal A\subseteq$ Δ₀-truthful positions. Then $\Sigma^\*\cup\{\tau\}$ is clean at every depth. By Gödel II, PA + ¬Con(PA) is consistent. It proves every true Δ₀ sentence and no false one (T2 Lemma 3.7). So no derivation from truthful Δ₀ positions reaches a $W$-false judgment, and τ ∈ $F_{\rm res}$ is asserted forever.
* **(c) Popperian Σ₁-caution removes syntactically Σ₁ residue** *(made precise after verification)*.
  * *The policy.* Fix a computable normal form: prenex form, with negations pushed into the Δ₀ matrix and double negations removed. In it $\neg\mathrm{Con(PA)}$, written $\neg\forall p\,\neg\mathrm{Prf}_{\rm PA}(p,\ulcorner\bot\urcorner)$, becomes $\exists p\,\mathrm{Prf}_{\rm PA}(p,\ulcorner\bot\urcorner)$. For practice axioms whose instances are sentences with Σ₁ normal form $\exists\bar x\theta$, θ in Δ₀, modify the presumption: assert an instance only once $W$ has verified a witness.
  * False axioms with Σ₁ normal form, ¬Con(PA) included, are then never asserted.
  * True ones are asserted after a witness search. There is no uniform time bound, because witnesses can be arbitrarily large; this is the analogue of Thm 5.5.
  * For a *schematic* axiom with infinitely many instances the policy works instance by instance. Phase-1 acceptance is then a semi-decision, with the tier abstaining while the search runs, rather than a decision by matching.
  * *Limitation.* The policy is syntactic. A false axiom that is logically equivalent to a Σ₁ sentence, but whose normal form is not Σ₁, escapes it. Example: $\forall y\,\exists p\,(\mathrm{Prf}_{\rm PA}(p,\ulcorner\bot\urcorner)\vee y\neq y)$, whose normal form is Π₂. PA plus it is consistent (Gödel II) and Δ₀-sound, so it is residual by the argument of (b), and it falls under (d).
  * This is T2 Thm 3.10(c), applied to practice instead of conjectures. It needs no designation of Con(PA).
* **(d) Beyond Σ₁ there is a permanent, provable residue** *(hypothesis corrected after verification)*. Consider false Π₂ or Σ₂ axioms τ such that $\Sigma^\*\cup\{\tau\}$ is clean at every depth. For example, take $\Sigma^\*\supseteq Q$ and suppose that $\Sigma^\*\cup\{\tau\}\cup A\cup\neg D$ is consistent for every designated $[A:D]$, where $\neg D:=\{\neg\delta:\delta\in D\}$. (The earlier wording "consistent with $\Sigma^\*$" ignored designated positions with non-Δ₀ assertions, such as Con(PA) in (f).) Such axioms admit no finite refutation from the evidence and survive.
  * No computable policy can sort the true from the false ones in the limit. The evidence here is computable practice data, $\mathrm{Ref}_d$ at every depth, and the Δ₀ oracle, so a limiting classification would be Δ₂ (Shoenfield). But Σ₂-truth is not Δ₂ (Post). This is T2 Thm 3.10(e).
  * [sketch] The same holds for randomized learners that classify correctly in the limit with probability > 1/2. The set $\{e:\Pr(\text{eventually and permanently removes }\vdash\varphi_e)>1/2\}$ is Σ₂, and so is the corresponding set for assertion. Σ₂-truth of the family would then be Δ₂.
* **(e) Finite reflection-extended practices are learned under the floor, given a realizable encoding of induction** *(revised after verification)*.
  * *The obstacle.* The induction schema $\varphi(0)\wedge\forall x(\varphi\to\varphi(Sx))\to\forall x\varphi$ is not a first-order pattern. Its lgg over instances is over-general and has false instances. TTL's audit then refutes it with singleton blame, by descent through the trusted →E and ∀E, so the asserted calculus would lack induction and would not be $T_k$. [computed: `ind_lgg.py`. Four instances give an lgg with the false instance $(0+0=0)\wedge\forall x(0+0=x\to0+S0=Sx)\to\forall x(0+0=x)$.]
  * *An encoding that works.* Add auxiliary decidable judgments $\mathrm{Sub}(\varphi,x,t,\psi)$ ("ψ is $\varphi[t/x]$") to $D_W$, and write induction as
    $$\mathrm{Sub}(\varphi,x,0,a),\ \mathrm{Sub}(\varphi,x,Sx,b)\ /\ \vdash a\wedge\forall x(\varphi\to b)\to\forall x\varphi,$$
    with the human data recording the Sub premises. This is a first-order pattern, and the lgg of generic instances recovers it [computed: `ind_sub_lgg.py`]. Its instances with a false Sub premise are harmless, since Sub judgments enter derivations only as $W$-true leaves.
  * With that encoding and under (Floor), a practice has at most $\min(K,1/\pi_{\min})$ axiom schemas. So $T_k=\mathrm{PA}+\mathrm{Con(PA)}+\dots+\mathrm{Con}(T_{k-1})$ is identified from positive data for every $k$ within the bound. Each $\mathrm{Con}(T_j)$ is genuine, and none is ever refuted.
  * *What the floor buys (corrected).* It buys **uniform sample bounds**. Without it there are none. Consider targets $T_{k-1}$ and $T_k$, where the tag $\mathrm{Con}(T_{k-1})$ has frequency π under $T_k$. A learner that is δ-sound for $T_{k-1}$ cannot accept $\mathrm{Con}(T_{k-1})$ under $T_k$ with probability $\ge1-\delta'$ before $\ln\frac{1-\delta'}\delta/\ln\frac1{1-\pi}$ samples. This is the two-point argument of Thm 5.5, conditioning on that tag's absence; $\mathrm{Con}(T_{k-1})\notin\mathrm{Sound}(R_{T_{k-1}})$ by Gödel II. [proved; TOSU]
  * T2 Thm 3.9 shows more over a class containing $T_\omega$ and every $T_k$: no learner identifies the target in the limit from positive data, coherence and Δ₀ feedback. But $T_\omega$ has infinitely many axioms, so it lies outside Def 1.1's finite practices. Within those, the floor is what yields uniform bounds; the earlier text presented T2 Thm 3.9 as showing that the floor is necessary for identification.
* **(f) Reflection as designation.** If $\mathcal A$ asserts Con(PA), then $\neg\mathrm{Con(PA)}$ becomes a singleton conflict (T2 Thm 3.9(iii)). This is a justification beyond PA-proof, made explicit as a *designation* rather than smuggled in as a rule.

*Proof.*
* (a) Lemma 2.5: the backward rule assigns $\forall\bar x\theta$ the value 0, and τ's 0-premise step is output.
* (b) As stated.
* (c) By construction, using the Σ₁-completeness of $W$-witnessing.
* (d) For a computable family of Σ₂ candidate axioms $\varphi_e$, put "$\vdash\varphi_e$" in the practice. A learner that eventually removes it iff $\varphi_e$ is false decides Σ₂-truth in the limit; apply T2 Thm 3.10(e).
* (e) The floor bounds the number of tags, and T1 Thm 6.3 applies to the Sub-encoded practice. The uniform-bound remark is Thm 5.5's argument verbatim, with $\mathrm{Con}(T_{k-1})$ in the role of the rare tag. The limit statement is T2 Thm 3.9.
* (f) Immediate. ∎

*Summary for arithmetic.*

**Achieved:**
* exact, localized Popperian falsification of Π₁ errors;
* exclusion of syntactically Σ₁ errors under Σ₁-caution;
* identification of finite reflection-extended practices, given a realizable (e.g. Sub-encoded) induction schema;
* soundness at all times relative to the stated residue.

**Not achieved, and provably not achievable by computable means:**
* elimination of false Σ₂ (and higher) axioms that are consistent with the practice;
* uniform sample bounds without a frequency floor (and, over classes containing $T_\omega$, identification in the limit; T2 Thm 3.9);
* (under presumption of validity) elimination of false Σ₁ axioms such as ¬Con(PA).

The Gödel/Rosser alternatives are the Kripkensteinian residue of arithmetic (T2 Thm 6.4(iii)). TTL leaves it exactly where T2 located it, but now with explicit sample sizes, refutation budgets and soundness against adaptive provers.

---
## 7. Computational checks (`theory/T7-checks/`)

| script | what it checks | result |
|---|---|---|
| `duality.py` | Lemma 2.3: (a) maximal clean sets are complements of minimal transversals; (b) the union of minimal transversals equals the union of minimal members; (c) the minimal transversal is unique iff all minimal members are singletons | 4000 random families on ≤ 7 points, 0 failures |
| `hilbert_blame.py` | minimal conflicts and diagnoses for practice $\{K,S,MP,DN,AC\}$ under bounded closure (≤ 5 and ≤ 7 leaves, $|U|=323{,}175$ at 7) | $\mathcal A=\{\emptyset\}$: $\{\{AC,K\}\}$; $\mathcal A=\{\emptyset,A_1\}$: $\{\{AC,K\},\{AC,MP\}\}$, collateral $\{K,MP\}$; bilateral $[A_1:p]$: $\{\{AC\}\}$, collateral ∅; core $\{MP,AC\}$ on $A_1$: diagnoses $\{MP\}$ and $\{AC\}$; closure of $A_1$ under AC is $\{q,p\to q,p\to\bot,p\}$ |
| `matrix_witness.py` | is there a 2- or 3-element matrix validating S, DN and AC, with $A_1$ satisfiable and ⊥ undesignated? | none; full-depth cleanness of the rival diagnosis $\{S,DN,AC\}$ is left open |
| `ttl_sim.py` | end-to-end TTL on a propositional practice with fallacies and noise, against an exhaustive adversarial prover | the table in §6.1 (regenerated after verification): TTL unsound in 0/80 runs, exact in 20/20 at $N=250$ and $N=500$; the positive-only cautious tier is unsound in 72/80 |

*Scripts added during verification.* The first seven were written by referees and re-run by the author; `prop32_voting.py`, `ind_sub_lgg.py` and the fixed `thm56_finite_d.py` are the author's.

| script | what it checks | result |
|---|---|---|
| `overlap.py` | Prop 2.4(c): MP and AC share instances | mgu $(A,\ A\to A\,/\,A)$, valid; the instance-level fallback strictly exceeds the schema-level one |
| `depth_nonmono.py` | Thm 4.1(iv): is $A$ monotone in $d$? | no: {AC, MP} → ∅ (at $d=9$) → {MP} (at $d=29$) |
| `noisefree.py` | Thm 4.1(iii): noise-free $N_1$ with the noisy trim budget | failure 0.077 at δ = 0.001 with $e=4$; $3\cdot10^{-5}$ with $e=0$ |
| `ind_lgg.py` | Cor 6.5, Thm 6.6(e): lgg of ∀E and of induction instances | over-general, with explicit false instances |
| `lemma61.py` | Lemma 6.1; Cor 6.2(c) shared falsifier | 30,000 schemas, 0 mismatches; $(\top,\bot\to\top/\bot)$ lies in inst(AC) and inst$(\top,A\to\top/A)$ |
| `matrix4.py` | Open Problem 2: 2-, 3- and 4-valued matrices for $\{S,DN,AC\}$ | none (re-run: 5.0M nodes, 235 s for $n=4$, $|D|=3$) |
| `thm56_finite_d.py` | Thm 5.6(c): fallback suboptimal at finite $d$ (well-founded derivations; the referee's version admitted circular ones) | sizes 9 ({MP, AC} on $A_1$) and 13 ({AC} on $A_2$); $A=\emptyset$ for $9\le d\le12$, $A=\{\mathrm{MP}\}$ for $d\ge13$ |
| `prop32_voting.py` | Prop 3.2: old vs revised voting audit | old: DA survives and 1 descent > $(m+1)|F|=0$; revised: DA removed, AC kept, MP kept under a bad position |
| `ind_sub_lgg.py` | Thm 6.6(e) repair: Sub-encoded induction | the lgg of 5 generic instances equals the pattern up to renaming |

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
   * In propositional logic it accepts *exactly* the valid steps (Cor 6.2). In complete decidable theories it does so too, provided the target calculus is realizable in the schema class (Cor 6.5, conditional after verification).
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
  * No sound learner using coherence alone can assert modus ponens as a rule there: some MP instances can be accepted by no sound learner (Thm 5.6(a)). *(Refined after verification.)* It can still accept MP instances that are also AC instances, such as $(\varphi,\ \varphi\to\varphi\ /\ \varphi)$ (Prop 2.4(c)).
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

None of the three parts is a proof of validity. Together they give a guarantee *relative to explicit parameters* $(d,\mathcal A,W,\delta)$. Raising $d$ changes the warrants only finitely often (Thm 4.1(iv)). *(Corrected after verification:* the changes can retract warrants and can also restore a genuine rule withheld as collateral at a smaller depth.) No computable procedure can avoid the possibility of retraction (Thm 5.7). This matches the user's view that justification is an "infinite endeavor" (L10 §1.11), stated in a form where every intermediate stage is sound relative to what has been checked.

---

## 9. Honest assessment and open problems

**Depth.**
* Almost every step is TOSU, or is T1/T2 transported. The main theorem's proof is about one page given T1 Thm 6.3, T2 Thm 2.2 and Lemma 3.1.
* The contribution is diagnostic:
  * finding exactly where the natural statement breaks (Props 2.2 and 2.4);
  * the three forced corrections (audit-then-assert, blame, depth), each with a matching lower bound (Thms 5.5, 5.6, 5.7);
  * the localization principle (Lemma 2.5 and §6.1).
* Lemma 2.3 is classical (Reiter). Lemma 2.5 is Shapiro's contradiction backtracing. Thm 5.5 is a standard two-point rare-event bound. Thm 5.7 is a routine reduction.
* Thm 5.6(a) is a two-point indistinguishability argument, whose interest lies entirely in the witness: MP/AC is → vs ←. Its stable-depth form (b), added after verification, is a short consequence of Lemma 2.3. Its finite-depth counterexample (c) shows that the depth qualification is needed.

**Weak points.**
1. *Realizability and tags.* Everything rests on T1's tagged single-schema class with latent fallacy tags. Mis-cited fallacies (AC cited as MP) need per-tag unions (T1 Thm 5.4), whose escalation behaviour is only polynomially bounded under a conjecture (T1 Conj 3.8).
   * *(Added after verification.)* First-order patterns also exclude ∀-elimination, the induction schema, and degree-indexed axiom families. Cor 6.5 is therefore conditional, and Thm 6.6(e) needs an auxiliary-judgment encoding. An identification theorem for higher-order-pattern schemas would remove this weakness.
2. *The fallback's cost.* Computing $\bigcup\mathcal C_d$ can be exponential in $|F|$. I have no lower bound on its *query* complexity in the conflict-oracle model.
3. *The audit is offline.* Thm 5.5 says that some abstention is necessary. But the burn-in $N_1$ is set from *known* floor constants, as in PAC learning. A data-driven stopping rule with the same guarantee is open.
4. *(WS) is strong.* Designated positions must be truthful, and in formal mathematics they must be true of 𝔐. For physics (T3), designated positions are idealized chunks, and (WS) holds only for chunks certified consistent (T3 Thm 1.9(d)). Extending Thm 4.1 to T3's anchored contexts is the obvious next step.
5. *The Bayesian middle way* (Remark 2.4′) might give anytime soundness for high-prior targets without a burn-in. I sketched it but did not prove it.

**Open problems.**
1. **Query complexity of sound blame.** In the black-box conflict-oracle model, how many $\mathrm{Ref}$ calls does it take to compute $\bigcup\mathcal C_d$, as a function of $K$ and $|F|$? Is it polynomial when every minimal conflict contains at most one fallacy?
2. **Full-depth status of the Hilbert rival** *(restated after verification)*. $K$ and MP are necessarily collateral at full depth (Thm 5.6(b); §5, Hilbert illustration), so necessity is no longer open. What remains open is whether $\{S,DN,AC\}$ is clean at every depth on $\{\emptyset,A_1\}$, equivalently whether $\mathrm{Coll}_\infty=\{K,\mathrm{MP}\}$ or also contains $S$ or $DN$. No matrix with at most 4 values witnesses cleanness (`matrix4.py`). If it is not clean, find the shortest refutation.
3. **Blame with priors.** Characterize when a "fewest fallacies" prior picks the true diagnosis. Is there a natural structural condition, e.g. every fallacy lies in two conflicts whose genuine parts are disjoint?
4. **Coherence-witness size.** Bound $d_\tau$ for natural fallacies in first-order logic. T2 Cor 6.2 gives polynomial bounds for CPC; quantifier swap has none without a two-object designated context.
5. **Physics.** Run TTL with T3's anchored contexts as designated positions and T3's certified bridges as trusted steps. Does descent through bridges give singleton blame for export errors?

**Suggested experiments.**
* *Blame curve.* Generate random Hilbert-style practices with one injected fallacy. Measure the collateral fraction under (i) unilateral coherence, (ii) bilateral counterexample positions, (iii) closed evaluation. Prediction: (i) has positive collateral that grows with how central the refuting rules are; (ii) and (iii) have none.
* *Rare refuter.* Simulate Thm 5.5 with MP at frequency π. Show that a learner sound in both scenarios needs about $\pi^{-1}\ln(1/\delta)$ samples before it can accept AC in the scenario where AC is genuine.
* *Full audit.* Simulate the full audit, with $\mathrm{Ref}_d$, descent on multi-step refutations and the fallback, setting $e_i$ from $(\bar\alpha,\Delta,N_1)$. `ttl_sim.py` covers only the CPC singleton case *(suggested by a referee)*.
* *Exploitation.* Compare a neural step scorer trained on the same practice with TTL under an RL prover rewarded for deriving a target conclusion. The scorer accepts fallacies; TTL does not.
* *Arithmetic.* Inject a false Π₁ axiom and ¬Con(PA)-style Σ₁ axioms into a bounded-arithmetic practice. Verify singleton blame for the former, survival of the latter under presumption, and removal under Σ₁-caution.

---

## References

✓ = confident; (u) = details unverified, cited from memory.

* Ben-Or, M., Kozen, D. & Reif, J. (1986). The complexity of elementary algebra and geometry. *J. Computer and System Sciences* 32:251–264. (u) *(added after verification)*
* Berge, C. (1989). *Hypergraphs: Combinatorics of Finite Sets*. North-Holland. (u: for the transversal hypergraph behind Lemma 2.3(b)) *(added after verification)*
* Bioch, J. C. & Ibaraki, T. (1995). Complexity of identification and dualization of positive Boolean functions. *Information and Computation* 123:50–63. (u) *(added after verification)*
* Boros, E., Elbassioni, K., Gurvich, V. & Khachiyan, L. (early 2000s). Papers on the joint generation of dual-bounded monotone families (e.g. "Generating dual-bounded hypergraphs", *Optimization Methods and Software*, 2002). (u: exact titles and venues) *(added after verification)*
* Davenport, J. H. & Heintz, J. (1988). Real quantifier elimination is doubly exponential. *J. Symbolic Computation* 5:29–35. ✓ (a lower bound for quantifier *elimination*, not for deciding sentences)
* de Kleer, J. & Williams, B. C. (1987). Diagnosing multiple faults. *Artificial Intelligence* 32:97–130. ✓
* Fischer, M. J. & Rabin, M. O. (1974). Super-exponential complexity of Presburger arithmetic. *SIAM–AMS Proceedings* 7:27–41. ✓ (u: that the exponential lower bound for the theory of real addition is in the same paper)
* Fredman, M. L. & Khachiyan, L. (1996). On the complexity of dualization of monotone disjunctive normal forms. *J. Algorithms* 21:618–628. ✓ (u: exact bound form)
* Gurvich, V. & Khachiyan, L. (1999). On generating the irredundant conjunctive and disjunctive normal forms of monotone Boolean functions. *Discrete Applied Mathematics* 96–97:363–373. (u) *(added after verification)*
* Gödel, K. (1931); Rosser, J. B. (1936); Shoenfield, J. (1959); Post, E. (1921, 1948): as in T2's reference list.
* Huet, G. (1976). *Résolution d'équations dans des langages d'ordre 1, 2, …, ω*. Thèse d'État, Paris VII. (u) (mainly higher-order unification; for first-order unification see Robinson 1965)
* Miller, D. (1991). A logic programming language with lambda-abstraction, function variables, and simple unification. *J. Logic and Computation* 1:497–536. (u) (higher-order patterns) *(added after verification)*
* Plotkin, G. (1970); Reynolds, J. (1970): as in T1.
* Presburger, M. (1929). Über die Vollständigkeit eines gewissen Systems der Arithmetik ganzer Zahlen. ✓
* Reiter, R. (1987). A theory of diagnosis from first principles. *Artificial Intelligence* 32:57–95. ✓
* Robinson, J. A. (1965). A machine-oriented logic based on the resolution principle. *J. ACM* 12:23–41. ✓ *(added after verification)*
* Shapiro, E. Y. (1981). Inductive inference of theories from facts. Technical Report 192, Yale University. (u: report number) *(added after verification)*
* Shapiro, E. Y. (1983). *Algorithmic Program Debugging*. MIT Press. ✓ *(added after verification)*
* Restall, G. (2005); Rumfitt, I. (2000): as in T2.
* Tarski, A. (1948/1951). *A Decision Method for Elementary Algebra and Geometry*. RAND / Univ. of California Press. ✓
* Ville, J. (1939); Li, Littman & Walsh (2008); Rivest & Sloan (1988): as in T1.
* Internal: T1 (Lemma 1.1; Thms 3.1, 5.3, 5.4, 6.2, 6.3; Cor 6.5; Props 2.3, 2.4, 6.1); T2 (Lemma 3.7; Thms 2.2, 2.5, 3.1, 3.9, 3.10, 5.3, 6.4; Props 6.3, 7.1); T3 (Thm 1.9); T4 (Lemma 4.1); T5 (Prop 4.2); L5 (Prop 2.5, §3.4); L6 (TC1); L8 (§11.7); L10.

---

## Verification log

Two independent adversarial referees checked this file: Referee A for §§1–4 and Referee B for §§5–6. Their full reports are reproduced in `verification/T7-verification.md`. For each reported issue I re-checked the claim myself and re-ran every referee script.
* `ttl_sim.py` with seed 0 under several `PYTHONHASHSEED` values; plus a diagnostic of the one $N=500$ trial with > e noise, whose excess noise is on the fallacy tag XOR.
* `overlap.py`, `depth_nonmono.py`, `noisefree.py`, `ind_lgg.py`, `lemma61.py`, and `matrix4.py` (no witness with ≤ 4 values; 235 s).
* `thm56_finite_d.py`. The referee's version admitted circular derivations and printed 5 instead of 9 for {MP, AC} on $A_1$. The fixed version enforces well-foundedness and confirms the reported sizes 9 and 13.
* New author scripts: `prop32_voting.py` (revised voting audit) and `ind_sub_lgg.py` (Sub-encoded induction is a learnable pattern).

All referee scripts used as evidence are now in `T7-checks/`, with a header saying they were written by a referee. Severity tags are the referees'. Every issue was found genuine; none was rejected. "ok" items are listed only where I acted on an optional suggestion.

### Referee A (§§1–4)

| # | item | severity | genuine? | action |
|---|---|---|---|---|
| A1 | Prop 2.4(c), first equality $\bigcap R_\Sigma=R_{\Sigma^P\setminus\bigcup\mathcal C_d}$ | major | Yes. $\Sigma\mapsto R_\Sigma$ does not commute with ∩, and MP/AC share the valid instances $(A,A\to A/A)$ (re-ran `overlap.py`). | **Fixed (revised after verification).** The equality is now stated at the schema level, $R_{\bigcap\Sigma}$. The instance-level set $\bigcap R_\Sigma$ is shown to be a superset, possibly strict, and also sound and $d$-clean (new proof). The reading after Lemma 2.3 is weakened to "must withhold as schemas", with forcing only at stable depth. Thm 5.6's "optimal" is replaced by schema-level optimality at stable depth (B2). §8's MP gloss is refined. |
| A2 | Prop 3.2 (mis-designated positions) | major | Yes. Both counterexamples reproduced (`prop32.py`): one descent against a bound of 0, and DA kept although refutable at $m+1$ positions. | **Fixed (revised after verification).** The voting audit is now fully specified. Each position runs its own descent loop, excluding already-blamed schemas, with the prefer-unblocked oracle; a conflicting $e^+_\pi$ certifies a bad position. New claims: (a) no genuine rule is removed; (b) at most $|\mathcal A|(|F|+1)+m|\Sigma^\*|$ calls; (c) $A\cap F\subseteq F^{(d,m)}_{\rm res}$, defined via complete positions, reducing to Lemma 3.1(a) when $m=0$. New proof. `prop32_voting.py` shows DA removed and AC kept. |
| A3 | Thm 4.1(ii) mis-designation clause | minor | Yes: outside the (WS) hypothesis, which forces $m=0$, and its count was false. | Clause removed from Thm 4.1, with a note; Step 2 adjusted; the assumptions now say "(WS) for every position". |
| A4 | Phase 0 W-settlement vs Thm 4.1(i) | minor | Yes: the step $(\top/\top\vee\bot)$ is $W$-truth-preserving but not $R^\*$-sound for $\{\wedge\mathrm I,\wedge\mathrm E_{1,2}\}$. | Defined a separate **world channel**, which is not part of the tier. Thm 4.1(i) now concerns the tier only. Cor 4.2 now covers chaining world-channel steps (truth-soundness). Human answers to escalated queries are not added to the sample. Remark 4 clarified. |
| A5 | Noise-free $N_1$ / trim budget; $c=0$ for ground rules | minor | Yes (re-ran `noisefree.py`: 0.077 vs $3\cdot10^{-5}$ at δ = 0.001). | Noise-free mode now sets $e_i:=0$, with $c\ge\max_i\max(c_i,1)$ and $\rho_i:=1$ for ground rules. Updated in §3.1, Thm 4.1(iii) and Step 1. |
| A6 | Depth-schedule glosses ("only retract") | minor | Yes (re-ran `depth_nonmono.py`: {AC, MP} → ∅ → {MP}). | §0 item 3, Thm 4.1(iv) and §8 corrected: $A$ changes finitely often, is not monotone, and can restore withheld schemas. $d_1^\*$ is defined for either tie-breaking rule. |
| A7 | Sandbox bound needs $R^\*\in\mathcal H_S$; deletion rule; refutations of step sets | minor | Yes. | Prop 3.3(b) and Thm 4.1(ii) now assume $h_0$ clean at every depth with $w(h_0)>0$. Deletion is defined as $h\supseteq\mathrm{Steps}(\pi)\setminus T_{\rm rust}$. Def 1.5 is extended to step sets, and Lemma 2.1(a) generalized to $S\subseteq\mathrm{Sound}(R^\*)$. §0 updated. |
| A8 | Promotion vs "accepted ⊆ $R^\*\cup R_{F_{\rm res}}$" and $d$-cleanness | minor | Yes. | Promoted rules are now **macros**, expanded into $R_A$-derivations (§3.1). Prop 3.3(a) states what weakens if they were primitive. Truth maintenance covers macros. Thm 4.1(i) says "the schema set $A$ is $d$-clean". |
| A9 | Lemma 2.5: global $e^+$ not computable; cost; Shapiro citation | minor | Yes. | $e^+$ is replaced by the local fixed point $e^+_\pi$ over π's judgments, with cost $O(|\pi|\varphi)$. Lemma revised; new part (d): each blamed schema is a singleton $d$-conflict, used in Thm 5.6(b). Shapiro (1981, 1983), contradiction backtracing, cited. |
| A10 | Prop 2.2 third bullet (one step trivializes) | minor | Yes: a single $(p/q)$ does not. | Restricted to pure τ and its closed ⊤/⊥ falsified instance, with the argument given. Prop 5.2(b) aligned. |
| A11 | §1 model: (WS) equivalence, finite derivations, nonempty $\mathcal A$, Summary (iii) | minor | Yes, all four. | (WS)'s third clause dropped (see also B14). New equivalent form: (WS) ⟺ Σ* clean at every depth, via the closure-indicator valuation for $R^\*\cup T_{\rm rust}$. Finite-signature or renaming qualification for $\mathrm{Ref}_d$. Convention $[\emptyset:\emptyset]\in\mathcal A$ when $D_W\ne\emptyset$. Summary (iii) qualified. |
| A12 | Lemma 3.1 cost: Fredman–Khachiyan citation | minor | Yes. | Joint generation from a membership oracle cited (Bioch–Ibaraki; Gurvich–Khachiyan; Boros et al.; marked (u)), with output both families. |
| A13 | Prop 3.3(c) citation (Huet) | minor | Yes. | Robinson (1965) cited for first-order mgu; Plotkin/Reynolds for the lattice; Huet's entry annotated. |
| A-ok | Lemma 2.3 | ok | — | Optional suggestion adopted: Berge's transversal hypergraph cited for (b). |
| A-ok | Thm 4.1 caveat: `ttl_sim.py` scope | ok | — | Scope note added under the §6.1 table, plus a "full audit" experiment in §9. |

### Referee B (§§5–6)

| # | item | severity | genuine? | action |
|---|---|---|---|---|
| B1 | Prop 5.2(a) (conditional probability; plain soundness) | major | Yes. T1's reckless counterexample transfers, and with plain Sound the intersection is trivial and convicts TTL. | **Fixed (revised after verification).** Restated in joint-probability form over admissible targets (new §5 conventions), relative to the residue. New proof that TTL passes: $R_A\subseteq R_\Sigma\cup R_{F^{(d)}_{\rm res}(\Sigma)}$ for every admissible Σ. Coalition bullet qualified by the prior. Trivialization claim restricted to the closed ⊤/⊥ instance of a pure τ. |
| B2 | Thm 5.6, "TTL's fallback is optimal" | major | Yes. False at finite $d$; reproduced with well-founded derivations (`thm56_finite_d.py`, fixed). | **Fixed (revised after verification).** (a) keeps the correct two-point core; the optimality clause is removed. New (b), [proved]: at stable depth every $g\in\bigcup\mathcal C_d(B_0)$ has an instance no learner sound in all admissible scenarios accepts with probability > δ; hence schema-level optimality, which also holds on the descent path. New (c): the finite-$d$ counterexample. Combined with A1: not instance-optimal. §0, §2.3 reading, §3.2 and the §5 table updated. |
| B3 | Cor 6.5 (∀E, axiom families not first-order patterns) | major | Yes (re-ran `ind_lgg.py`: the ∀E lgg is over-general with an invalid instance). | **Fixed (revised after verification).** Cor 6.5 is now conditional on realizability. Caveat added: ∀E, and the degree-indexed or induction schemas of RCF, ACF$_p$ and Presburger, are not first-order patterns; DLO is finitely axiomatized. Stated what happens without realizability (sound, not exact). Two repairs sketched: Sub-encoding, or a higher-order-pattern theorem. §0, §6.2 Remark 3, §8 and §9 weak point 1 updated. |
| B4 | Thm 6.6(e) (induction not a pattern; T2 Thm 3.9 and $T_\omega$) | major | Yes (re-ran `ind_lgg.py`: false instance of the induction lgg). | **Fixed (revised after verification).** (e) now assumes a Sub-encoded induction rule, a first-order pattern whose lgg is recovered from generic instances (new `ind_sub_lgg.py`). The necessity remark is replaced by "the floor buys uniform sample bounds", with a two-point argument ([proved; TOSU]), and T2 Thm 3.9 is restated as a limit result over classes containing $T_\omega$, which lies outside Def 1.1. §6.3 setting and summaries updated. |
| B5 | Prop 5.1 missing non-derivability hypothesis | minor | Yes: $\Sigma_2=\Sigma_1\cup\{(A\wedge B/B\wedge A)\}$. | Hypothesis $R_{\Sigma_2}\not\subseteq\mathrm{Sound}(R_{\Sigma_1})$ added, with the counterexample. |
| B6 | Thm 5.5 (δ+δ′<1; scenario-independence; ∧I closure; gloss; ρ overloaded; novelty) | minor | Yes, all points (checked: −0.585 vs −0.405). | Added δ+δ′<1; fixed prover and practice-following escalation (§5 conventions); ∧I closure corrected (infinite, no ⊥); gloss rewritten; schema ρ renamed μ (also in Thm 5.6); tightness of the first bound noted; novelty toned down in §0 and §9. |
| B7 | Hilbert caveat / Open Problem 2 | minor | Yes: {AC,K} and {AC,MP} are minimal conflicts at every depth. | Caveat rewritten: K and MP are necessarily collateral at full depth (Thm 5.6(b)). Open Problem 2 restated as whether Coll∞ also contains S or DN. `matrix4.py` re-run: no witness with ≤ 4 values. |
| B8 | Thm 5.7 presentation | minor | Yes. | Statement now includes computable instance laws and a fixed prover querying $\vdash\mathrm{start}_e$. The "indistinguishability" bullet is replaced by "uniformity". $\Sigma_0$ having no 0-premise rules is made explicit. |
| B9 | Cor 6.2 ("exactly" counts; evaluation cost; $\mathcal A\ne\emptyset$; set contexts) | minor | Yes (re-ran `lemma61.py`: shared falsifier of AC and $(\top,A\to\top/A)$). | "At most" $|F|+1$ calls and $|F|$ refutations. Cost now includes the genuine schemas: $(|F|+1)\sum_{\Sigma^P}2^{v}$, or $\sum_{\Sigma^P}2^{v}$ with caching. The oracle is specified and shown exact. $[\emptyset:\emptyset]\in\mathcal A$. List contexts with structural rules; Lemma 6.1's sequent extension noted. |
| B10 | `ttl_sim.py` table does not reproduce | minor | Yes (re-run matches the referee exactly). | Table regenerated from the script. The $N=500$ parenthetical corrected: the one >e-noise trial had its excess noise on the fallacy tag XOR and is still exact. Explanatory bullet added. §7 updated. |
| B11 | Prop 6.3 ($d_\tau$ undefined; examples outside the standing assumption; necessity) | minor | Yes. | $d_\tau$ defined in Def 1.6; Lemma 6.4's quantity renamed $f_\tau$. (b) restated for any complete full-language Hilbert system with $\mathcal A=\{[\emptyset:\emptyset]\}$ (optionally $+A_1$), where {AC,K} is a minimal conflict at every depth, with necessity from Thm 5.6(b). The computed examples are flagged as outside the assumption. |
| B12 | §6.2 Remark 2 (position not truthful; not a singleton) | minor | Yes. | Rewritten: the designated sentence $\exists x(x\cdot x=1+1)$, fallacy $\vdash\neg\exists x(x\cdot x=1+1)$, trusted logic, so descent gives singleton blame. Bag $\{\tau,\neg\mathrm E\}$ without trusted logic; bilateral variant noted. |
| B13 | §6.2 Remark 1 (Davenport–Heintz) | minor | Yes. | Corrected: QE is doubly exponential (D–H); deciding RCF sentences is in EXPSPACE (Ben-Or–Kozen–Reif, (u)); exponential lower bound already for real addition (Fischer–Rabin, (u)). |
| B14 | §6.3 violates (WS)'s third clause | minor | Yes. | Third clause dropped globally (§1.3). Target closure $\mathrm{Cl}_{R^\*\cup T_{\rm rust}}$ used in Thm 4.1(i) and §6.3. |
| B15 | Thm 6.6(a) depth bound; oracle tie-breaking | minor | Yes (checked $\theta=x<S^5 0$: size 23). | Bound corrected to $2|\theta|+m(n+1)+O(1)$ (with a $k$-variable form). The prefer-unblocked oracle (§3.1 variant) is now required. |
| B16 | Thm 6.6(c) syntactic Σ₁-caution | minor | Yes. | Normal form fixed; claim restricted to axioms with Σ₁ normal form. Disguise example and its residual status stated. Schematic case: acceptance becomes a semi-decision. |
| B17 | Thm 6.6(d) hypothesis; randomized learners | minor | Yes. | Hypothesis now "clean at every depth", e.g. $\Sigma^\*\supseteq Q$ and $\Sigma^\*\cup\{\tau\}\cup A\cup\neg D$ consistent for every designated position. Randomized-learner remark added [sketch]. |
| B18 | Prop 5.8 wording | ok (optional) | — | Adopted: "at most $m$ positions (it is not known which) violate (WS)". |

*Items whose statement or proof changed non-trivially, for re-verification:* (WS) and its equivalent form (§1.3); Lemma 2.1(a); Prop 2.4(c); Lemma 2.5 (local $e^+_\pi$, new (d)); Prop 3.2; Prop 3.3(a)(b); Thm 4.1 (i)–(iv) and proof Step 1; Prop 5.2(a); Thm 5.5; Thm 5.6(b)(c); Prop 6.3(b); Cor 6.2(c); Cor 6.5; §6.2 Remark 2; Thm 6.6(a),(c),(d),(e).
