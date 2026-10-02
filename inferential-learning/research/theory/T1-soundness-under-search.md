# T1. Worst-case soundness of a learned step checker under adversarial search

*Theory thread T1 for the inferential-learning project. Read with `../00-brief.md`. Literature context: `../lit/L1-positive-data-learning.md` (Gold/Angluin/Plotkin/closure algorithm) and `../lit/L2-reliable-selective-kwik.md` (KWIK, selective classification, Ville). Several results below were derived independently of L2; where they overlap, they agree, and I say so. Where L2 gives a bound, I sharpen it or give the matching lower bound.*

**Status tags.**
* **[proved]**: a complete proof is given here.
* **[known]**: a known result, cited. Citations marked (unverified) are from memory.
* **[computed]**: checked by exhaustive or randomized computation on small cases. The scripts are in `T1-code/`.
* **[conjecture]**.

---

## 0. Summary

The user's architecture has three parts: a learned relation $\hat V$ ("this step is valid"), a prover that searches for derivations all of whose steps $\hat V$ accepts, and a training signal that starts from human steps. This thread asks what the step checker must satisfy so that **the reasoner is sound no matter how hard the prover searches**, and what that costs.

1. **Soundness is a uniform property, and search makes it the only one that matters.**
   * A reasoner is sound iff every accepted step is a derivable step (Lemma 1.1).
   * Average-case accuracy says nothing about this. For **every** distribution $Q$ on steps and every $\varepsilon>0$, there is a rule set built from pure schemas with $Q$-error $<\varepsilon$ that derives every formula. It needs one bad step, a tonk-like padding rule $A\vee(\top\wedge\cdots\wedge\top)\vdash A$ (Thm 2.1).
   * Any PAC learner can be modified into one that is still PAC with the same rates but whose every output trivializes the reasoner (Cor 2.2).
   * In classical propositional logic, every unsound *schema* trivializes, by Post completeness (Prop 2.3).
   * A simplicity (MDL/Occam) learner on positive data chooses the universal schema "anything from anything" (Prop 2.4).
2. **Version-space verification is sound by construction. Its price is exactly a "positive elasticity".**
   * The verifier accepts a step iff every hypothesis consistent with the data accepts it. This is sound against all provers and optimal among sound verifiers (Thm 3.1).
   * Its worst-case number of escalations (human interventions) on honest provers is exactly the length of the longest elastic chain inside the target (Thm 3.2). I call this the *escalation dimension*.
   * Computed values:
     * a **single schema** learned by anti-unification costs at most $1+\mu(t_1)-\mu(\sigma^*)\le N+1$ escalations, which is tight. Here $\mu=$ size minus number of distinct variables and $N$ is the step size (Thm 3.4).
     * **$k$ tagged rules** cost the sum of the per-rule costs (Thm 3.6).
     * **untagged unions of $k$ schemas** cost at least $\lfloor (N-1)/k\rfloor^k$, even when the truth is a single rule. The cost is at most $(k^{N+1}-1)/(k-1)$. For flat schemas it is $\Theta(n^k)$ (Thm 3.7). I conjecture $\binom{h+k-1}{k}$ for any intersection-closed class of height $h$ (Conj 3.8).
     * **unstructured** classes cost $|H|-1$, tight (Thm 3.9).
   * Certifying *invalidity* as well (two-sided KWIK) costs at least $\mathrm{Bell}(N-1)$ for a single schema (Prop 3.5). It is never needed for soundness.
3. **The Bayesian-conservative verifier** accepts iff the posterior probability of invalidity is $<\delta$.
   * With the version-space posterior, $\delta\le w^*$ gives deterministic soundness, and this threshold is tight (Thm 4.1).
   * With a well-specified likelihood (noisy human data, noisy oracle), take $\delta\le w^*\delta'$. Then **the probability that any invalid step is ever accepted, at any time, for any adaptive prover, is at most $\delta'$**. The constant 1 is tight (Thm 4.2, Prop 4.3). With a deterministic oracle, the good event does not depend on the prover.
   * Escalations are at most $\ln(1/(w^*\delta''))/\delta$ (Thm 4.4). Any $\delta'$-sound verifier needs at least $(1-\delta')(1/w^*-1)$ on unstructured classes (Cor 4.5). This is exponential in description length.
   * Combining with the version space gives $\min\{\text{escalation dimension},\ \ln(1/w^*)/\delta\}$ (Cor 4.6).
   * **Structure, not the prior, is what makes sound learned verification affordable.**
4. **Positive data alone.**
   * The version-space verifier is sound at all times.
   * It becomes complete iff the target has a finite **anchor**: a finite $T$ such that every hypothesis containing $T$ contains the target (Thm 5.1). This is strictly stronger than Angluin's tell-tale. The two coincide for intersection-closed classes (Prop 5.2).
   * For tagged schemas, exact identification holds with probability $\ge1-\sum_i c_i e^{-N\pi_i\rho_i}$, where $\pi_i$ is a rule's frequency and $\rho_i$ the variability of its instances (Thm 5.3). This is coupon-collector behaviour.
   * For untagged $k$-unions it holds once each rule's instances cannot be covered by $k$ "failure sets", with ε-net sample complexity (Thm 5.4).
   * Exact identification means the verifier accepts *exactly* the human calculus. This gives systematic generalization to derivations of any length and formulas of any size (Cor 5.5).
5. **Noise.**
   * One wrongly-tagged human step turns the lgg of $\wedge$E into "from anything infer anything" (Prop 6.1).
   * The **trimmed version space** (hypotheses that miss at most $e$ data points) is sound when there are at most $e$ errors. It is complete when every *witness event* of every rule occurs more than $e$ times (Thm 6.2). Under i.i.d. noise this needs witness frequency to exceed error frequency (Thm 6.3).
   * This is optimal up to a factor of 3. Any positive-data verifier robust to error rate $\alpha$ must refuse every generalization supported by less than $\alpha$ of the data (Thm 6.4).
   * **Schema-generated (systematic) errors are indistinguishable from rules at every rate** (Cor 6.5).
   * Removing them needs negative information. In classical propositional logic, *coherence* (deriving $\bot$ in the empty context) detects every unsound schema (Prop 6.6; see T2 Thm 3.1). In arithmetic it does not.

**Upshot for the user's program.** "Learn inference rules from positive examples" works, provably, for formal math with rule citations. Use anti-unification as the learning algorithm and the version space as the verifier. The result is deterministically sound from the first example and exactly correct after coupon-collector many examples. No negative data or human escalation is needed beyond that. Each bullet is a formal statement below:
* Losing rule citations (informal steps) costs a polynomial of degree $k$ in escalations.
* Human errors are tolerated when they are rarer than the evidence for each rule's generality.
* Systematic human errors are where coherence or world feedback (threads T2/T3) must take over.

---

## 1. Setting

### 1.1 Judgments, steps, rule sets, closure

* Let $J$ be a countable set of **judgments**. A canonical example is sequents $\Gamma\vdash\varphi$. **Contexts are part of judgments**, so hypothetical reasoning, and physics "assume air pressure is 0" contexts, live inside the step language.
* A **step** is a pair $s=(\Pi,j)$, where $\Pi\subseteq J$ is finite (the premises) and $j\in J$ (the conclusion). $S$ denotes the set of steps.
* A **rule set** is any $R\subseteq S$, typically the set of instances of finitely many schemas.
* For $B\subseteq J$, the **closure** $\mathrm{Cl}_R(B)$ is the least $X\supseteq B$ such that $(\Pi,j)\in R$ and $\Pi\subseteq X$ imply $j\in X$. Equivalently, it is the set of $j$ having a finite $R$-derivation from $B$.

The human calculus is an unknown rule set $R^*$ (the *valid steps*). Its *derivable steps* are
$$\mathrm{Sound}(R^*)=\{(\Pi,j): j\in\mathrm{Cl}_{R^*}(\Pi)\}.$$

**Lemma 1.1 (reasoner soundness = stepwise soundness) [proved].** For $A\subseteq S$, the following are equivalent:
$$\forall B\subseteq J:\ \mathrm{Cl}_A(B)\subseteq\mathrm{Cl}_{R^*}(B)\qquad\Longleftrightarrow\qquad A\subseteq\mathrm{Sound}(R^*).$$

*Proof.*
* (⇐) $\mathrm{Cl}_{R^*}$ is monotone and idempotent. Let $(\Pi,j)\in A$ with $\Pi\subseteq \mathrm{Cl}_{R^*}(B)$. Then $j\in\mathrm{Cl}_{R^*}(\Pi)\subseteq\mathrm{Cl}_{R^*}(\mathrm{Cl}_{R^*}(B))=\mathrm{Cl}_{R^*}(B)$. So $\mathrm{Cl}_{R^*}(B)$ is a superset of $B$ that is closed under $A$, and by leastness $\mathrm{Cl}_A(B)\subseteq\mathrm{Cl}_{R^*}(B)$.
* (⇒) For $(\Pi,j)\in A$: $j\in\mathrm{Cl}_A(\Pi)\subseteq\mathrm{Cl}_{R^*}(\Pi)$. ∎

So a verifier is safe for *arbitrarily long* derivations iff its acceptance region contains no non-derivable step. Conversely, one accepted non-derivable step $(\Pi,j)$ with derivable premises yields a false conclusion. There is no "small error rate" middle ground.

Soundness here is **relative to the human calculus**, not to truth. Improving on $R^*$ is the job of coherence and world feedback (T2, T3). In what follows I require the stronger condition $A\subseteq R^*$ (only rule instances are accepted). The version-space verifiers below satisfy it.

### 1.2 Protocol, soundness, cost

* A **hypothesis class** is $H\subseteq 2^S$, assumed realizable: $R^*\in H$.
* **Human data** is a sequence $X_1,X_2,\dots$, a finite $P_0\subseteq R^*$ or an i.i.d. sample (noisy versions in §4 and §6).
* **The interaction.** In rounds $t=1,2,\dots$, a **prover** submits a query $q_t\in S$. The prover may be any (randomized, adaptive, computationally unbounded) strategy that knows $R^*$, the verifier's code and the whole history, but not the verifier's future coins.
* The **verifier** answers $a_t\in\{\mathrm{ACC},\mathrm{REJ},\mathrm{ESC}\}$. On ESC an **oracle** returns the label $y_t=\mathbf 1[q_t\in R^*]$, which joins the history. Noisy oracles are treated in §4.

**Definition 1.2 (soundness).** A verifier is **$\delta$-sound for $H$** if, for every $R^*\in H$ and every prover,
$$\Pr[\exists t:\ a_t=\mathrm{ACC}\wedge q_t\notin R^*]\le\delta.$$
It is **0-sound** if $\delta=0$. It is **uniformly $\delta$-sound** if there is an event $G$ with $\Pr(G)\ge1-\delta$, depending only on the human data and the verifier's coins, on which no prover strategy ever gets an invalid step accepted.

**Definition 1.3 (escalation cost).**
* A prover is **honest** if all its queries are in $R^*$.
* The cost of a run is the number of rounds in which a valid query is not accepted outright (escalated or rejected).
* $\mathrm{Esc}(H\mid P_0)$ is the infimum, over 0-sound verifiers, of the supremum over targets $R^*\in H$ with $R^*\supseteq P_0$ and over honest query sequences, of the cost. Write $\mathrm{Esc}(H)=\mathrm{Esc}(H\mid\emptyset)$.

This cost is one-sided. Invalid queries from a dishonest prover are its own problem: they can be rejected or escalated and charged to the prover. §3.3 shows why this one-sidedness is essential.

### 1.3 Schemas and anti-unification

* Steps are encoded as **ground first-order terms** over a signature $\Sigma$, e.g. $\mathsf{s1}(\mathsf{and}(p_0,p_1),p_0)$ for one $\wedge$E step. Object-language variables are constants of $\Sigma$.
* A **schema** is a term with metavariables. $\mathrm{inst}(\sigma)$ is its set of ground instances.
* $\sigma\succeq\tau$ (" $\sigma$ is more general") iff $\tau=\sigma\theta$ for some substitution $\theta$.
* Every nonempty set $P$ of terms has a **least general generalization** $\mathrm{lgg}(P)$, unique up to renaming, with $\mathrm{inst}(\mathrm{lgg}(P))=\bigcap\{\mathrm{inst}(\sigma):P\subseteq\mathrm{inst}(\sigma)\}$ [known: Plotkin 1970, Reynolds 1970].
* It is computed by **anti-unification** $A$ on tuples of terms:
  * If all $u_j$ have the same root $f$ of arity $r$, then $A(u_1,\dots,u_n)=f(A(\mathrm{col}_1),\dots,A(\mathrm{col}_r))$.
  * Otherwise $A(u_1,\dots,u_n)$ is a variable $z_{(u_1,\dots,u_n)}$ indexed by the tuple itself, so equal tuples get equal variables.
* For a term $t$, let
  $$\mu(t):=|t|-|\mathrm{vars}(t)|,$$
  where $|t|$ counts symbol occurrences, variable occurrences included. So $\mu\ge0$, $\mu(x)=0$, and $\mu(t)=|t|$ for ground $t$.

**Lemma 1.2 (rank) [proved; folklore in the Plotkin–Reynolds lattice].** If $\tau=\sigma\theta$, then $\mu(\tau)\ge\mu(\sigma)$, with equality iff $\theta$ restricted to $\mathrm{vars}(\sigma)$ is a renaming. Hence every strictly increasing generalization chain above $t$ has length $\le\mu(t)-\mu(\text{top of chain})\le\mu(t)$.

*Proof.* Let $\sigma$ have distinct variables $x_1,\dots,x_k$, with $x_i$ occurring $m_i\ge1$ times. Then $|\tau|=|\sigma|+\sum_i m_i(|\theta x_i|-1)$. Also $|\mathrm{vars}(\tau)|\le\sum_i|\mathrm{vars}(\theta x_i)|$, with equality iff the sets $\mathrm{vars}(\theta x_i)$ are pairwise disjoint. Hence
$$\mu(\tau)-\mu(\sigma)\ \ge\ \sum_{i=1}^k\Big[m_i(|\theta x_i|-1)+1-|\mathrm{vars}(\theta x_i)|\Big].$$
Bound each summand:
* If $\theta x_i$ is a variable, the summand is $0$.
* Otherwise $|\theta x_i|\ge|\mathrm{vars}(\theta x_i)|+1$, so the summand is $\ge(|\theta x_i|-1)+1-|\mathrm{vars}(\theta x_i)|\ge1$.

So the difference is $\ge0$. Equality forces every $\theta x_i$ to be a variable and these variables to be pairwise distinct, i.e. a renaming. ∎

**Lemma 1.3 (when the lgg recovers the schema) [proved].** Let $\sigma$ have variables $x_1,\dots,x_v$, and let $t_j=\sigma\theta_j$ ($j=1..n$, $n\ge1$) be ground instances. Then $\mathrm{lgg}(t_1..t_n)\preceq\sigma$ always. Equality (up to renaming) holds iff both of the following hold:
* **(R)** for each $x$, the roots of $\theta_1x,\dots,\theta_nx$ are not all equal;
* **(D)** for each $x\neq y$, there is $j$ with $\theta_jx\neq\theta_jy$.

*Proof.* Run $A$ on $(t_1,\dots,t_n)$ by structural induction on $\sigma$.
* At non-variable positions of $\sigma$, all $t_j$ share $\sigma$'s symbol, so $A$ copies it.
* At a position holding $x$, $A$ receives the column $c_x=(\theta_1x,\dots,\theta_nx)$. So $A(\bar t)=\sigma[x\mapsto A(c_x)]$.
* $A(c_x)$ is a variable iff (R) holds at $x$. Two such variables coincide iff $c_x=c_y$, i.e. iff (D) fails for $x,y$.

So if (R) and (D) hold, $x\mapsto z_{c_x}$ is a renaming. If either fails, the substitution is not a renaming, and by Lemma 1.2 the lgg is strictly more specific. ∎

Call (R) and (D) the **witness events** of $\sigma$. The whole positive-data theory of §5–§6 runs on counting them.

---

## 2. Average-case accuracy cannot give soundness

Fix a propositional language with atoms $p_0,p_1,\dots$, the constant $\top$, and the connectives $\wedge,\vee$ (others optional). Judgments are formulas. Let $R^*$ contain the instances of the following rules, plus any other sound rules:
* $\top$I: $(\emptyset,\top)$;
* $\wedge$I: $(\{A,B\},A\wedge B)$;
* $\wedge$E$_{1,2}$;
* $\vee$I$_1$: $(\{A\},A\vee B)$ and $\vee$I$_2$: $(\{B\},A\vee B)$.

Let $\top^{(j)}$ denote $\top\wedge(\top\wedge\cdots)$ with $j$ conjuncts, and define the pure single-metavariable schema
$$T_j:=\{(\{A\vee\top^{(j)}\},A):A\text{ a formula}\}.$$

**Theorem 2.1 (tonk beyond the horizon) [proved].**
* (i) Every formula $C$ is in $\mathrm{Cl}_{R^*\cup T_j}(\emptyset)$, via a derivation of $j+2$ steps of which exactly one is invalid.
* (ii) For every probability distribution $Q$ on $S$ (over valid steps, invalid steps or both), $Q(T_j)\to0$ as $j\to\infty$.

So for every $Q$ and every $\varepsilon>0$, the hypothesis $R^*\cup T_j$ is a union of finitely many pure schemas, has $Q$-error $<\varepsilon$, and trivializes the reasoner.

*Proof.*
* (i) Derive $\top$ ($\top$I), then $\top^{(2)},\dots,\top^{(j)}$ ($j-1$ applications of $\wedge$I). Next derive $C\vee\top^{(j)}$ ($\vee$I$_2$), and finally $C$ ($T_j$). The step from $T_j$ is invalid because $C\vee\top$ is a tautology for every $C$.
* (ii) The sets $T_j$ are pairwise disjoint, so $\sum_jQ(T_j)\le1$. ∎

**Corollary 2.2 (PAC learners can be maximally unsound) [proved].** Let $\mathcal L$ be any learner. From a sample $X_1..X_m\sim Q$, let $\mathcal L^+$ output $\mathcal L(X_{1..m})\cup T_{\hat\jmath}$, where $\hat\jmath:=1+\max_i|X_i|$. Then for every $Q$:
$$\Pr\big[Q(T_{\hat\jmath})>\varepsilon\big]\le(1-\varepsilon)^m.$$
So $\mathrm{err}_Q(\mathcal L^+)\le\mathrm{err}_Q(\mathcal L)+\varepsilon$ with probability $\ge1-(1-\varepsilon)^m$ more. If $\mathcal L$ is a PAC learner, so is $\mathcal L^+$, with $O(\varepsilon^{-1}\log\delta^{-1})$ extra samples. But **every** output of $\mathcal L^+$ makes every formula derivable.

*Proof.* Every step of $T_j$ has size $\ge|\top^{(j)}|\ge j$, so $T_j\subseteq\{s:|s|\ge j\}$.
* Let $N_\varepsilon=\min\{N:Q(|s|\ge N)\le\varepsilon\}$, which exists since $Q(|s|\ge N)\downarrow0$.
* If $\hat\jmath\ge N_\varepsilon$, then $Q(T_{\hat\jmath})\le\varepsilon$.
* Otherwise all $m$ samples have size $<N_\varepsilon-1$. Since $Q(|s|\ge N_\varepsilon-1)>\varepsilon$, this has probability $\le(1-\varepsilon)^m$. ∎

**Proposition 2.3 (in classical logic every unsound schema is a tonk) [proved; essentially Post 1921].** Let $R^*_{\rm CPC}$ be sound and complete for classical propositional consequence, with $\top,\bot,\neg$ available. Let $A\supseteq R^*_{\rm CPC}$ be closed under uniform substitution, as the instance set of any family of schemas is. If $A$ contains an unsound step, then $\mathrm{Cl}_A(\emptyset)$ is the set of all formulas.

*Proof.*
* Let $(\Pi,\varphi)\in A$ be unsound, witnessed by a valuation $v$ with $v(\Pi)=1$ and $v(\varphi)=0$.
* Substitute $\top$ for each atom true under $v$ and $\bot$ for each false atom. This gives a step $(\Pi',\varphi')\in A$ with variable-free formulas, each $\pi\in\Pi'$ true and $\varphi'$ false.
* By completeness, each $\pi\in\Pi'$ and $\neg\varphi'$ are derivable from $\emptyset$. The step yields $\varphi'$, hence $\bot$, hence everything. ∎

(The full consequence-relation version, and its use for learning, is T2 Thm 3.1.) For schema-structured hypotheses in classical logic, *any* error is total.

**Proposition 2.4 (simplicity is the wrong bias for positive data) [proved].** In the single-schema class, the shortest schema consistent with any positive data is a single metavariable $x$, which accepts every step.

More generally, an MDL learner without a likelihood term picks a hypothesis containing the data and of minimal description length. Over-general hypotheses are never refuted by positive data and are typically short, so the learner over-generalizes. The positive-data remedies are:
* *least* generality (anti-unification; §3, §5);
* a likelihood with the size principle (§4).

Even with the size principle, **MAP selection** (accept the instances of the most probable hypothesis) is unsound whenever an over-general hypothesis is temporarily most probable. §4 replaces MAP by conservative thresholding.

*Remarks.*
* (a) Thm 2.1 and Cor 2.2 are trivial once set up. The content is the *quantifier*: a soundness guarantee must be $\sup_s$, not $\mathbb E_{s\sim Q}$, because a prover chooses $s$ after seeing the verifier.
* (b) The selection effect. If a prover reports a derivation of a non-derivable target, the derivation contains an invalid step with probability 1, whatever the verifier's error rate on human steps. L2 Prop 6 quantifies how search drives the base rate of accepted-invalid steps toward 1. This is the mechanism behind reward-model over-optimization (Gao, Schulman & Hilton 2023) and the limits of process reward models trained on human-like steps (Lightman et al. 2023).
* (c) The uniform requirement is exactly reliable learning (Rivest & Sloan 1988), perfect selective classification (El-Yaniv & Wiener 2010), or the "accept" side of KWIK (Li, Littman & Walsh 2008), applied to steps.

---

## 3. Version-space verification and the escalation dimension

For data consisting of positives $P$ and negatives $N$, the version space is $\mathrm{VS}(P,N)=\{R\in H:P\subseteq R,\ R\cap N=\emptyset\}$. The **VS verifier**:
* accepts $q$ iff $q\in\bigcap\mathrm{VS}$;
* rejects iff $q\notin\bigcup\mathrm{VS}$;
* otherwise escalates, adding the label to $P$ or $N$.

The positive part of $P$ starts as $P_0$.

**Theorem 3.1 (soundness and optimality) [proved].**
* (a) The VS verifier is 0-sound and uniformly so: $R^*\in\mathrm{VS}$ at all times, so $\bigcap\mathrm{VS}\subseteq R^*$.
* (b) Fix the human data $P_0$, as in Definition 1.3. Let a (possibly randomized) verifier be $\delta$-sound, and suppose that at some history consistent with $R^*$ it accepts, with probability $p$, a query $q\notin\bigcap\mathrm{VS}$, where VS is computed from $P_0$ and all labels in the history. Then $p\le\delta$.

*Proof.*
* (a) All labels are truthful.
* (b) Pick $R'\in\mathrm{VS}$ with $q\notin R'$, so $P_0\subseteq R'$. Under target $R'$, the oracle answers in the history have the same probability, since all are consistent with $R'$, and the verifier's coins have the same law. A prover that issues the same queries and then queries $q$ therefore gets an invalid step accepted with probability $p$. ∎

With *random* human data the same argument applies whenever the data law of $R'$ gives the observed data positive probability. Otherwise the data can refute $R'$, which is the Bayesian setting of §4.

**Definition (positive elasticity).** For $R\in H$ with $R\supseteq P_0$, an **elastic chain in $R$** is a sequence $s_1,\dots,s_m\in R$ with $s_i\notin\bigcap\mathrm{VS}(P_0\cup\{s_1..s_{i-1}\})$ for every $i$. Equivalently, there are $R_i\in H$ with $P_0\cup\{s_{<i}\}\subseteq R_i\not\ni s_i$. Let $\mathrm{el}(H,R\mid P_0)$ be the supremum of chain lengths. (Wright's elasticity, made bounded and relative to a target; L1 §2.3, L2 Thm 5.)

**Theorem 3.2 (escalation dimension = positive elasticity) [proved].**
$$\mathrm{Esc}(H\mid P_0)=\sup_{R\in H,\,R\supseteq P_0}\mathrm{el}(H,R\mid P_0).$$
The VS verifier attains it. Moreover, every $\delta$-sound randomized verifier has expected cost $\ge(1-\delta)m$ on some honest sequence of length $m$, for every $m\le\sup\mathrm{el}$.

*Proof.*
* *Upper bound.* Against an honest prover the VS verifier never rejects, because $q\in R^*\subseteq\bigcup\mathrm{VS}$. Its escalated queries $s_1,s_2,\dots$ satisfy $s_i\notin\bigcap\mathrm{VS}$ at the time of the query, where VS contains $P_0$ and the earlier escalated positives. So they form an elastic chain in $R^*$. (Accepted queries add nothing, since they already lie in $\bigcap\mathrm{VS}$.)
* *Lower bound.* Take an elastic chain $s_1..s_m$ in $R$, and let the honest prover for target $R$ query it in order. By Thm 3.1(b), applied with target $R_i$, round $i$ is accepted outright with probability $\le\delta$. ∎

**Proposition 3.3 (intersection-closed classes) [known in substance: closure algorithm; Natarajan 1987, Helmbold, Sloan & Warmuth 1990].** Suppose $H\cup\{\emptyset\}$ is closed under arbitrary intersections. Then:
* $\bigcap\mathrm{VS}(P)=\mathrm{cl}(P)$, the least member containing $P$;
* the VS verifier is the *closure algorithm*;
* $\mathrm{el}(H,R\mid P_0)$ equals the maximal length $m$ of a strict chain $\mathrm{cl}(P_0)=C_0\subsetneq C_1\subsetneq\dots\subsetneq C_m\subseteq R$ of members.

*Proof.*
* An elastic chain gives $C_i=\mathrm{cl}(P_0\cup s_{\le i})$, strictly increasing.
* Conversely, given a chain of members, pick $s_i\in C_i\setminus C_{i-1}$. Then $\mathrm{cl}(P_0\cup s_{<i})\subseteq C_{i-1}\not\ni s_i$. ∎

The single-schema class $H_1=\{\mathrm{inst}(\sigma)\}\cup\{\emptyset\}$ qualifies:
* $\mathrm{inst}(\sigma)\cap\mathrm{inst}(\tau)=\mathrm{inst}(\mathrm{mgu})$ or $\emptyset$.
* An arbitrary nonempty intersection contains some ground $t$. Each member of the family is a generalization of $t$, and $t$ has only finitely many generalizations, so the intersection reduces to a finite one.

**Theorem 3.4 (single schema learned by anti-unification) [proved].** For $H_1$, target $\sigma^*$, and nonempty $P_0\subseteq\mathrm{inst}(\sigma^*)$:
$$\mathrm{el}(H_1,\sigma^*\mid P_0)\ \le\ \mu(\mathrm{lgg}\,P_0)-\mu(\sigma^*).$$
With $P_0=\emptyset$ and steps of size $\le N$:
$$\mathrm{Esc}(H_1;\,|s|\le N)\le 1+N-\mu(\sigma^*).$$
This is tight. If $\Sigma$ has two constants $a,b$ and a unary $g$, there is an honest sequence of $N+1$ escalations for $\sigma^*=x$.

*Proof.*
* *Upper bound.* By Prop 3.3, a chain is a strictly increasing generalization chain $\mathrm{lgg}(P_0)\prec g_1\prec\dots\prec g_m\preceq\sigma^*$. By Lemma 1.2, $\mu$ drops by $\ge1$ per step and stays $\ge\mu(\sigma^*)$. With $P_0=\emptyset$, the first query is always escalated, since $\bigcap\mathrm{VS}(\emptyset)=\emptyset$, and then $\mu(\text{first query})\le N$.
* *Tightness.* Query $g^{N-1}(a)$, $g^{N-1}(b)$, $g^{N-2}(a)$, $g^{N-3}(a)$, …, $a$. The lggs are $g^{N-1}(a)$, $g^{N-1}(x)$, $g^{N-2}(x)$, …, $x$, with $\mu=N,N-1,\dots,0$. Each query lies outside the previous lgg. [computed: exhaustive search over all ground terms of size $\le N$ for $N\le4$ gives exactly $N+1$; with only one constant it gives $N$.] ∎

This sharpens L2 Thm 5(c), which has $2|s|$. In words, after the human corpus $P_0$ the residual escalation budget is the **generality gap** $\mu(\mathrm{lgg}P_0)-\mu(\sigma^*)$. It is zero once the corpus has identified the rule (§5).

**Proposition 3.5 (two-sided KWIK is super-exponential) [proved].** Suppose the verifier must also *certify* invalidity, rejecting only steps outside $\bigcup\mathrm{VS}$, and every escalation is counted. Then for $H_1$ there are a target and a prover forcing at least $\mathrm{Bell}(n)$ escalations on steps of size $n+1$.

*Proof.*
* Use constants $a,b_1,\dots,b_n$, an $n$-ary $f$, target $R^*=\{f(a,\dots,a)\}$, and $P_0=R^*$.
* For a partition $\pi$ of $[n]$, let $s_\pi=f(b_{\pi(1)},\dots,b_{\pi(n)})$, where $\pi(j)$ is the index of $j$'s block, and $\sigma_\pi=f(x_{\pi(1)},\dots,x_{\pi(n)})\succeq f(a,\dots,a)$.
* $s_{\pi'}\in\mathrm{inst}(\sigma_\pi)$ iff $\pi$ refines $\pi'$.
* Query the $s_\pi$ along a linear extension of refinement, finest first. When $s_\pi$ is queried, no coarser $s_{\pi'}$ has been labelled. So $\sigma_\pi$ is alive, $s_\pi\in\bigcup\mathrm{VS}$, and the verifier cannot reject. Each $s_\pi$ is invalid, so it must be escalated. ∎

So certifying *validity* costs $\le N+1$, while certifying *invalidity* costs $\ge\mathrm{Bell}(N-1)$ (compare L2 Thm 5(d) for conjunctions). A step checker never needs the second: an unaccepted step is merely unusable. **One-sidedness is what makes learned verification cheap.**

**Theorem 3.6 (k tagged rules) [proved].**
* Tagged steps $(i,s)$, $i\in[k]$, record which rule the step cites, as formal proofs do (Lean lemma names, Metamath labels, ND rule names).
* $H^{\rm tag}_k=\{\bigcup_i\{i\}\times\mathrm{inst}(\sigma_i)\}$ is a product of $k$ intersection-closed classes on disjoint domains, hence intersection-closed.
* Its chains are interleavings of per-rule chains, so
$$\mathrm{el}=\sum_i\mathrm{el}_i\le\sum_i\big(\mu(\mathrm{lgg}P_0^{(i)})-\mu(\sigma_i^*)\big)\quad(\le k(N+1)\text{ from empty data}).$$
* This is tight, by independent chains. ∎

**Theorem 3.7 (untagged unions of k schemas) [proved].** Let $H_k=\{\bigcup_{l\le k}\mathrm{inst}(\tau_l)\}$, with steps of size $\le N$.
* **(i) Lower bound.** Let $\Sigma$ contain a $k$-ary $p$, a unary $g$ and a constant $c$, and let $n+1=\lfloor(N-1)/k\rfloor$. There is an honest sequence for the *single-rule* target $R^*=\mathrm{inst}(p(x_1,\dots,x_k))\in H_1\subseteq H_k$ that forces $(n+1)^k$ escalations. So
  $$\mathrm{Esc}(H_k;N)\ge\lfloor (N-1)/k\rfloor^k,\qquad\text{while}\qquad\mathrm{Esc}(H_1;N)\le N+1.$$
* **(ii) Upper bound.** For $k\ge2$, $\mathrm{Esc}(H_k;N)\le(k^{N+1}-1)/(k-1)$.
* **(iii) Flat case, $\Theta(n^k)$.** Let the steps be $\{a,b\}^n$, encoded as $f(c_1,\dots,c_n)$, and let $H$ be unions of $k$ linear flat schemas (subcubes). Then
  $$\sum_{w=0}^k\binom nw\le\mathrm{Esc}\le 1+(2^k-1)\binom nk.$$
  With repeated metavariables allowed, $\mathrm{Esc}\le1+(2^{2k}-1)\binom n{2k}$ for $n\ge2k$.

*Proof.*
* **(i)** The steps are $p(g^{a_1}c,\dots,g^{a_k}c)$ with $a\in\{0..n\}^k$, each of size $\le1+k(n+1)\le N$. Query them in order of non-increasing $\sum_ja_j$.
  * When $a$ is queried, every earlier $a'\neq a$ has $\sum a'\ge\sum a$, so $a'_j>a_j$ for some $j$.
  * Hence the earlier steps lie in $R'=\bigcup_{j\le k}\mathrm{inst}\big(p(x_1,..,g^{a_j+1}(x_j),..,x_k)\big)\in H_k$, and the current step does not.
  * By Thm 3.2, every step is escalated.
* **(ii)** Take an elastic chain $s_1..s_m$ with witnesses $R_i=\bigcup_l\mathrm{inst}(\tau_{i,l})$. Let $\pi_i$ partition $[i-1]$ by "least $l$ with $s_j\in\mathrm{inst}(\tau_{i,l})$".
  * Call $i_0<\dots<i_r$ a *chain* if, for each $b\ge1$, all of $i_0..i_{b-1}$ lie in one block of $\pi_{i_b}$. Then $s_{i_b}\notin\mathrm{inst}\,\mathrm{lgg}(s_{i_0},\dots,s_{i_{b-1}})$, since that block's schema covers the prefix and misses $s_{i_b}$. So $\mathrm{lgg}(s_{i_0})\prec\mathrm{lgg}(s_{i_0},s_{i_1})\prec\cdots$ strictly. By Lemma 1.2, $\mu$ drops from $\le N$ by $\ge1$ per step and stays $\ge0$, so the chain has length $\le N+1$. This is the proof of Thm 3.4; it needs no common target schema.
  * Let $g(d)$ be the maximal length of a sequence of $k$-partitions all of whose chains have length $\le d$. Split $[m-1]$ by $\pi_m$. Each block carries an induced structure whose chains, extended by $m$, are chains, so each block has chains $\le d-1$.
  * Hence $g(d)\le1+k\,g(d-1)$ and $g(1)=1$, which gives $g(d)\le(k^d-1)/(k-1)$. Take $d=N+1$.
* **(iii)**
  * A subcube avoiding $p$ fixes some coordinate $j$ to $1-p_j$, so it lies in a half-cube $\{x_j=1-p_j\}$.
  * Hence $p$ escapes iff there is a $k$-set $J$ of coordinates such that no earlier point agrees with $p$ on $J$, i.e. the pattern $(J,p|_J)$ is new.
  * There are $2^k\binom nk$ patterns. The first point creates $\binom nk$ of them, and each escape creates $\ge1$.
  * For the lower bound, take all points of weight $\le k$ in order of weight. A point $x$ of weight $w\le k$ is new on any $J\supseteq\mathrm{supp}(x)$, because an earlier point agreeing on $J$ would have support $\supseteq\mathrm{supp}(x)$ and weight $\le w$, hence equal $x$.
  * With sharing, the maximal avoiding sets are half-cubes and the "equalities" $\{x_i=x_j\}$ with $p_i\neq p_j$. Each is determined by $\le2$ coordinates of $p$, so patterns on $2k$ coordinates suffice. ∎

[computed]
* Subcubes, $k=2$: the exact values for $n=2,3,4$ are $4,7,11=\sum_{w\le2}\binom nw$, so the lower bound in (iii) is exact there.
* Deep schemas, signature $\{c,g/1,p/2\}$, $k=2$: the exact values for $N=3,4,5$ are $4,8,13$ (universes of 4, 8, 17 terms). For $\{a,b,g,p\}$ they are $8,13$ at $N=3,4$.
* The partition abstraction used in (ii) attains $2^d-1$ for $k=2$, $d=3,4$, so the Ramsey-type method cannot do better. Any polynomial bound must use intersection-closure.

**Conjecture 3.8 (binomial bound) [conjecture].** Let $C$ be closed under intersections, with height $h$: the longest chain from $\mathrm{cl}(\emptyset)$ to the universe, the universe included. Then the elasticity of $k$-unions of $C$ is at most $\binom{h+k-1}{k}$.

Status:
* It is exact for $k=1$ (chains) and for $h=2$ (singletons give $k+1$).
* Randomized hill-climbing over intersection-closed families with $k=2$ found maxima of $3,6,10,14$ at $h=2,3,4,5$ [computed], against the conjectured $3,6,10,15$.
* For schemas, $h\le N+1$, so the conjecture gives $\mathrm{Esc}(H_k;N)\le\binom{N+k}{k}$. This would match (i) up to $e^{O(k)}$, so the truth would be $\Theta_k(N^k)$.

A natural one-step decomposition proof (split off the members containing $s_1$) fails on some extremal sequences [computed].

**Theorem 3.9 (unstructured classes) [proved; KWIK enumeration bound, Li, Littman & Walsh 2008].** For finite $H$, $\mathrm{Esc}(H)\le|H|-1$: each escalation of an honest step outside $\bigcap\mathrm{VS}$ removes $\ge1$ hypothesis, and $R^*$ is never removed. The class $\{U\setminus\{u\}:u\in U\}$ attains $|U|-1$, by querying $U\setminus\{u^*\}$ in any order. A class of $2^L$ hypotheses described by $L$ bits can therefore need $2^L-1$ escalations. Single schemas of size $\le N$ already number $2^{\Omega(N)}$, yet need $\le N+1$.

---

## 4. Bayesian-conservative verification

Setup:
* $H$ is countable with prior $w$, and $w^*:=w(R^*)>0$.
* Each $R$ carries a model: a distribution $p_R$ on $S$ for human data (errors may be included), and an oracle kernel $\ell_R(y\mid q)$ (deterministic: $\mathbf 1[y=\mathbf 1[q\in R]]$).
* The truth is well-specified: human data are i.i.d. $p_{R^*}$, and oracle answers follow $\ell_{R^*}(\cdot\mid q_t)$ given the past.
* After the observations of rounds $\le t$, the likelihood is $L_t(R)$, the posterior is $w_t(R)\propto w(R)L_t(R)$, and
  $$Z_t:=\sum_Rw(R)\,L_t(R)/L_t(R^*),\qquad\text{so that}\qquad w_t(R^*)=w^*/Z_t.$$
* **Verifier $V_\delta$:** ACC iff $w_t(\{R:q\notin R\})<\delta$; optionally REJ iff $w_t(\{R:q\in R\})<\delta_r$; ESC otherwise.

**Theorem 4.1 (version-space posterior: deterministic soundness) [proved].** Let $w_t^{\rm VS}(R)\propto w(R)\mathbf 1[R\text{ consistent with all data}]$, and suppose all labels are truthful. If $\delta\le w^*$, then $V_\delta$ never accepts an invalid step, for any prover and at any time.

Conversely, for every $\delta>w^*$ there is a two-hypothesis class on which $V_\delta$ accepts an invalid step at time 0.

*Proof.*
* $w_t^{\rm VS}(R^*)=w^*/w(\mathrm{VS}_t)\ge w^*$. For invalid $q$, $w_t(q\notin R)\ge w_t(R^*)\ge w^*\ge\delta$, so $q$ is not accepted.
* For the converse, take $H=\{R^*,R'\}$ with $R'\supsetneq R^*$, $w(R^*)=w^*$, and $q\in R'\setminus R^*$. Then $w_0(q\notin R)=w^*<\delta$, so $q$ is accepted. ∎

(L2 Thm 1 is the same.)

**Theorem 4.2 (Ville: time-uniform soundness against adaptive provers) [proved].** Assume the model is well-specified and $\delta\le w^*\delta'$.
* (a) For every prover, $\Pr[\exists t,\ V_\delta\text{ accepts some }q_t\notin R^*]\le\delta'$.
* (b) With a deterministic oracle the guarantee is **uniform**: there is an event of probability $\ge1-\delta'$, depending only on the human data, on which no prover strategy ever gets an invalid step accepted.

*Proof.*
* Let $\mathcal F_t$ contain everything up to round $t$, including the prover's choice of what happens in round $t+1$. Given $\mathcal F_t$, the observation $O_{t+1}$ is either a fresh $X\sim p_{R^*}$ or an answer $\sim\ell_{R^*}(\cdot\mid q_{t+1})$ with $q_{t+1}$ $\mathcal F_t$-measurable. In either case, for every $R$,
  $$\mathbb E\Big[\tfrac{\ell_R(O_{t+1})}{\ell_{R^*}(O_{t+1})}\Big|\mathcal F_t\Big]=\sum_{o:\ell_{R^*}(o)>0}\ell_R(o)\le1.$$
* By Tonelli (nonnegative terms), $\mathbb E[Z_{t+1}\mid\mathcal F_t]\le Z_t$, and $Z_0=\sum_Rw(R)=1$. Note that $L_t(R^*)>0$ a.s.
* Ville's inequality (Ville 1939) gives $\Pr[\sup_tZ_t\ge1/\delta']\le\delta'$.
* Off this event, $w_t(R^*)>w^*\delta'\ge\delta$ for all $t$. Any invalid $q$ has $w_t(q\notin R)\ge w_t(R^*)>\delta$, so it is never accepted. This proves (a).
* For (b), deterministic oracle answers multiply each term by $\mathbf 1[R\text{ agrees with }R^*\text{ on }q]\le1$. So $Z_t\le Z^H_{n(t)}:=\sum_Rw(R)\prod_{j\le n(t)}p_R(X_j)/p_{R^*}(X_j)$, which is computed from the human data alone. Apply Ville to $Z^H$. ∎

The key phenomenon is that **there is no union bound over queries**. The prover may try $10^{100}$ steps, and one event of probability $\ge1-\delta'$ covers all of them. This is because invalid acceptance requires one global event: the posterior of the truth falling below $\delta$. A per-step scorer, such as a regressor trained to output $P(\text{valid})$, has no such single latent event, and Thm 2.1 shows its per-step errors can be found one at a time. (L2 Thm 2 states (a). Statement (b), and the tightness below, are additions here.)

**Proposition 4.3 (the constant 1 is tight) [proved; computed].**
* Take $R^*=\{a,b\}$ with $p_{R^*}(a)=1-u$, $p_{R^*}(b)=u$, and $R'=\{a,c\}$ with $p_{R'}(a)=1$, where $c$ is invalid.
* The likelihood ratio after $t$ copies of $a$ is $(1-u)^{-t}$, and $R'$ dies at the first $b$.
* $V_{w^*\delta'}$ accepts $c$ iff the ratio exceeds $\theta:=(1-w^*\delta')/((1-w^*)\delta')$. Let $t^*$ be the least $t$ with $(1-u)^{-t}>\theta$. The probability of acceptance is $(1-u)^{t^*}\in\big[(1-u)/\theta,\,1/\theta\big)$, and $1/\theta=(1-w^*)\delta'/(1-w^*\delta')\le\delta'$.
* As $u,w^*\to0$, this tends to $\delta'$. The exact values are $0.989\,\delta'$ at $u=0.05,\ w^*=\delta'=0.01$, and $0.991\,\delta'$ at $u=0.01$, $w^*=10^{-3}$, $\delta'=0.05$.

**Theorem 4.4 (escalation bound) [proved].** With a deterministic oracle and thresholds $\delta,\delta_r$, let $\delta_m=\min(\delta,\delta_r)$, or $\delta_m=\delta$ for honest provers.
* With probability $\ge1-\delta''$, simultaneously for all $t$: $\#\mathrm{ESC}_t\le\big(\ln(1/w^*)+\ln(1/\delta'')\big)/\delta_m$.
* For the VS posterior, deterministically: $\#\mathrm{ESC}_t\le\ln(1/w^*)/\delta_m$.

*Proof.* $Z$ evolves multiplicatively.
* A human datum multiplies it by $F_u=\sum_Rw_{u-1}(R)\,p_R(X_u)/p_{R^*}(X_u)$, with $\mathbb E[F_u\mid\mathcal F_{u-1}]\le1$.
* An escalation of a valid $q$ happened because $w_{u-1}(q\notin R)\ge\delta$. The answer multiplies $Z$ by $1-w_{u-1}(q\notin R)\le1-\delta$. For an invalid $q$ the factor is likewise $\le1-\delta_r$.
* Let $M_t:=\prod_{\text{data rounds}}F_u$, a nonnegative supermartingale with $M_0=1$. Then $w^*\le Z_t\le M_t(1-\delta_m)^{\#\mathrm{ESC}_t}$, and Ville bounds $\sup M$.
* For the VS posterior, $F_u=w_{u-1}(X_u\in R)\le1$. ∎

**Corollary 4.5 (essentially tight for unstructured classes) [proved].** On $\{U\setminus\{u\}\}$ with the uniform prior ($w^*=1/|U|$), any $\delta'$-sound verifier has worst-case honest cost $\ge(1-\delta')(1/w^*-1)$, by Thm 3.2 with Thm 3.9's chain. Meanwhile $V_{w^*\delta'}$ pays $\le\ln(1/w^*)/(w^*\delta')$. So the Bayes rule is optimal up to $\ln(1/w^*)/\delta'$, and with a description-length prior $w^*=2^{-L}$ the cost is $\tilde\Theta(2^L)$ (cf. L2 Thm 4).

**Corollary 4.6 (structure + Bayes) [proved].** The VS-posterior verifier with $\delta\le w^*$ is 0-sound, and its escalations on valid queries are at most
$$\min\{\mathrm{el}(H,R^*\mid P_0),\ \ln(1/w^*)/\delta\}.$$
*Proof.* An escalated valid $q$ had $w(q\notin R)\ge\delta>0$, so $q\notin\bigcap\mathrm{VS}$, and negatives only enlarge $\bigcap\mathrm{VS}$. So the escalated valid queries form an elastic chain. ∎

**Discussion: structure, not the prior, makes it feasible.**
* For single schemas with a description-length prior, $\ln(1/w^*)/\delta\approx2^{c|\sigma^*|}$, while $\mathrm{el}\le N+1$.
* The prior earns its keep elsewhere. Over a **countable hierarchy** (any number of tagged schemas), the bare version space never generalizes: $\bigcap\mathrm{VS}(P)=P$, because exception-lists are hypotheses. The Bayesian verifier is sound for all targets with $w(R^*)\ge\delta/\delta'$, i.e. all rule systems of description length $\le\log_2(\delta'/\delta)$.
* The practical recipe has three layers:
  * a structured version-space core, which gives cheap escalations and exact soundness when realizable;
  * a Bayesian hierarchy over the structure, which handles realizability failures;
  * conservative thresholds rather than MAP.
* **Caveat.** Thm 4.2 needs well-specification. Systematic human errors are precisely a misspecification the model does not anticipate (Cor 6.5). Then the posterior concentrates on "rule + error" as a rule.

---

## 5. Positive data only (no escalation)

The VS verifier fed only human positives accepts $\bigcap\mathrm{VS}(P_t)\subseteq R^*$. **It is sound at every time**, whatever the data.

**Theorem 5.1 (eventual completeness ⇔ finite anchor) [proved].** Call a finite $T\subseteq R^*$ an **anchor** if every $R\in H$ with $T\subseteq R$ satisfies $R\supseteq R^*$. Then:
* $\bigcap\mathrm{VS}(P)=R^*$ iff $P$ contains an anchor.
* On a text ($P_t\uparrow R^*$), or under i.i.d. sampling with $\mathrm{supp}\,D=R^*$ (a.s.), the verifier is eventually exactly $R^*$ iff $R^*$ has an anchor.

*Proof.*
* If $T\subseteq P$, every consistent $R$ contains $R^*$, so $\bigcap\mathrm{VS}\supseteq R^*$; and $\subseteq$ holds by realizability.
* If $\bigcap\mathrm{VS}(P)=R^*$, then $P$ itself is an anchor.
* A text eventually contains any given finite $T\subseteq R^*$. ∎

**Proposition 5.2 (anchors vs. tell-tales) [proved].**
* An anchor is an Angluin tell-tale: no $R$ satisfies $T\subseteq R\subsetneq R^*$.
* For intersection-closed classes the converse holds: if $T\subseteq R\not\supseteq R^*$, then $R\cap R^*$ is a member with $T\subseteq R\cap R^*\subsetneq R^*$.
* In general the converse fails. Take $R^*=2\mathbb N$ and $R_n=\{0,2,..,2n\}\cup\{2n+1\}$.
  * The class is identifiable in the limit (tell-tales $\{0\}$ and $R_n$).
  * Every finite $T\subseteq R^*$ lies in some $R_n\not\supseteq R^*$, so $R^*$ has no anchor and the verifier never becomes complete.

*Moral.* Identification in the limit (a guess that converges) is weaker than certified verification (all consistent hypotheses agree). A learner that guesses $R^*$ would be unsound if the truth were a large $R_n$. Anchors are the ⊆-tell-tales of strong-monotonic learning (Lange–Zeugmann; see L1 §2.3).

**Theorem 5.3 (tagged schemas: exact identification, coupon-collector rate) [proved].**
* Human data are i.i.d. $(I,X)$ with $\Pr(I=i)=\pi_i$ and $X=\sigma_i\Theta$, $\Theta\sim\Lambda_i$.
* For a variable $x$ of $\sigma_i$, define the balanced-split variability
  $$\rho_{i,x}:=\max_{G\subseteq\Sigma}\min\big(\Pr[\mathrm{root}(\Theta x)\in G],\Pr[\mathrm{root}(\Theta x)\notin G]\big).$$
* For variables $x\ne y$, let $r_{i,xy}:=\Pr[\Theta x\neq\Theta y]$.
* Let $\rho_i$ be the minimum of all of these, and $c_i:=2v_i+\binom{v_i}2$, where $v_i=|\mathrm{vars}(\sigma_i)|$.

Then the per-rule lgg verifier (= the VS verifier for $H^{\rm tag}_k$) satisfies
$$\Pr\big[\bigcap\mathrm{VS}\neq R^*\big]\ \le\ \sum_i c_i\,e^{-N\pi_i\rho_i}\qquad(\text{ground rules: }e^{-N\pi_i}).$$
So $N\ge\max_i\frac{1}{\pi_i\rho_i}\ln\frac{k\,c_i}{\delta}$ suffices. Order $1/(\pi_i\rho_i)$ samples are also necessary: if one root has probability $1-\rho$, (R) fails with probability $\ge(1-\pi_i\rho)^N$.

*Proof.* Condition on $N_i=n$ rule-$i$ samples. By Lemma 1.3, identification fails only if some witness event fails.
* (R$_x$) fails only if all $n$ roots lie in $G$ or all lie in $G^c$, which has probability $\le2(1-\rho_i)^n$.
* (D$_{xy}$) fails with probability $(1-r)^n\le(1-\rho_i)^n$.
* A union bound gives $c_i(1-\rho_i)^n$. Then $\mathbb E(1-\rho)^{N_i}=(1-\pi_i\rho)^N\le e^{-N\pi_i\rho}$. ∎

[computed] Toy natural deduction with 6 rules ($\wedge$I, $\wedge$E$_{1,2}$, $\vee$I$_{1,2}$, MP), random formulas over 4 atoms, and 400 trials per $N$:

| $N$ | 12 | 24 | 48 | 96 | 192 |
|---|---|---|---|---|---|
| empirical exact-identification rate | .003 | .41 | .98 | 1.00 | 1.00 |
| bound $1-30e^{-N/12}$ | vacuous | vacuous | .45 | .99 | .999997 |

(Here $\rho=1/2$ and $c=5$.)

**Theorem 5.4 (untagged unions: anchors and sample complexity) [proved, modulo the cited ε-net theorem].**
* Let $R^*=\bigcup_{i\le k'}\mathrm{inst}(\sigma_i)$ with $k'\le k$.
* For each rule $i$, the **failure sets** are
  $$\mathfrak F_i=\big\{\{\theta:\mathrm{root}(\theta x)=f\}:x,f\big\}\cup\big\{\{\theta:\theta x=\theta y\}:x\ne y\big\}.$$
  A nonempty set of instances is non-generic iff its substitutions lie in a single failure set (Lemma 1.3).
* **(a)** Suppose that for each $i$, the rule-$i$ samples in $P$ cannot be covered by $k$ failure sets. Then $\bigcap\mathrm{VS}_{H_k}(P)=R^*$.
  * This holds in particular if each rule has $k+1$ pairwise-generic samples, which gives anchors of size $k'(k+1)$. A failure set contains at most one member of a pairwise-generic set.
* **(b)** Suppose $\zeta_i:=\inf_{F_1..F_k\in\mathfrak F_i}\Lambda_i(\overline{F_1\cup\dots\cup F_k})>0$. Then it suffices to have
  $$n_i\ge\frac{8D_i}{\zeta_i}\log_2\frac{13}{\zeta_i}+\frac4{\zeta_i}\log_2\frac{2k'}{\delta}$$
  rule-$i$ samples, where $D_i\le2k\log_2(4k(v_i^2+1))$.

*Proof.*
* (a) Let $R=\bigcup_l\mathrm{inst}(\tau_l)\in\mathrm{VS}$. Partition rule-$i$'s samples by the first covering $l$. If no class were generic, each class would lie in a failure set, giving a cover by $k$ failure sets. So some class $Q$ is generic, and $\tau_l\succeq\mathrm{lgg}(Q)=\sigma_i$. Hence $R\supseteq R^*$.
* (b) Bound the growth function of $\mathfrak F_i$. For fixed $x$, the sets $\{\mathrm{root}(\theta x)=f\}$ are disjoint, so $\Pi_{\mathfrak F_i}(n)\le M(n+1)$, where $M=v_i+\binom{v_i}2$.
* So complements of $k$-unions have growth $\le(M(n+1))^k$. Shattering $D$ points needs $2^D\le(M(D+1))^k$, which fails at $D=2k\log_2(4kM)$.
* Apply the ε-net theorem (Haussler & Welzl 1987; Blumer, Ehrenfeucht, Haussler & Warmuth 1989) with $\varepsilon=\zeta_i$. ∎

*Remark.*
* $\zeta_i>0$ requires $k$ to be smaller than the variety of instantiations. If some metavariable is only ever instantiated with $\le k$ distinct root symbols, the data are explained equally well by $k$ specialized rules, and identification fails forever.
* "Allow up to $k$ rules" is therefore a real assumption about data diversity, and it is the positive-data face of Thm 3.7(i).

**Corollary 5.5 (exact identification ⇒ systematic out-of-distribution generalization) [proved].** Once $\bigcap\mathrm{VS}(P)=R^*$:
* the verifier accepts exactly $R^*$;
* the reasoner derives exactly $\mathrm{Cl}_{R^*}(B)$ for every $B$, including conclusions that need derivations far longer, and formulas far larger, than anything in the human data, and independently of $D$.

*Proof.* Lemma 1.1, and in fact equality. ∎

Inferentialist reading: the anchor is a finite set of *uses* that fixes the inferential role of the connectives within $H$. For tagged natural deduction, two or three generic instances per rule suffice. Overgeneralizations such as tonk are never adopted, because the lgg is the *least* generalization covering usage. This is a learning-theoretic analogue of Belnap-style conservativeness.

*Extensions and limits.*
* **Side conditions** drawn from a finite family $\Phi$ of predicates on ground steps are handled the same way. Examples are eigenvariable and freshness conditions, such as "the constant at position $u$ does not occur in the subterm at position $v$".
  * Hypotheses are $\mathrm{inst}(\sigma)\cap\bigcap_{\varphi\in\Psi}\varphi^{-1}(1)$ for $\Psi\subseteq\Phi$.
  * The closure of $P$ is $(\mathrm{lgg}P,\ \{\varphi:\varphi\text{ holds on all of }P\})$.
  * The class stays intersection-closed. Each strict closure step generalizes the schema or drops a predicate, so the bound of Thm 3.4 becomes $\mu(\mathrm{lgg}P_0)-\mu(\sigma^*)+|\Phi|$ [proved by this argument].
* **Sets/multisets as contexts** need anti-unification modulo AC, which is finitary rather than unitary (Alpuente et al. 2014, unverified). There may be several minimal generalizations. The intersection verifier stays sound, but the bounds above need re-proof.
* **Binders** need higher-order pattern anti-unification, which is unitary (Baumgartner, Kutsia, Levy & Villaret 2017, unverified). So the theory plausibly lifts.
* **Informal steps** are elements of $\mathrm{Sound}(R^*)$ (derived, multi-step), not of $R^*$. This is a different hypothesis class, left to other threads.

---

## 6. Noise: sporadic vs. systematic errors

**Proposition 6.1 (one error collapses the lgg) [proved; computed].**
* Let $P$ be generic $\wedge$E$_1$ instances $\mathsf{s1}(\mathsf{and}(A_j,B_j),A_j)$, plus one invalid step $\mathsf{s1}(\varphi,\psi)$ tagged $\wedge$E$_1$, where $\varphi$ is not a conjunction.
* Then $\mathrm{lgg}=\mathsf{s1}(z,w)$:
  * the premise column has mixed roots;
  * the conclusion column has mixed roots by (R);
  * the two columns differ, so $z\ne w$.
* The verifier then accepts every one-premise step, and from any derivable formula it derives everything.
* [computed] A mis-tagged "$p_0\vee p_1\vdash p_0$" does exactly this. A 15% rate of affirming the consequent, tagged MP, turns MP's lgg into $\mathsf{s2}(\mathsf{imp}(v_0,v_1),v_2,v_3)$: from $A\to B$ and anything, infer anything.

**Theorem 6.2 (trimmed version space) [proved].** Let $\mathrm{VS}_e(P)=\{R\in H:|P\setminus R|\le e\}$, counted with multiplicity, and let the verifier accept $\bigcap\mathrm{VS}_e$.
* (a) For any $H$: if $P$ contains $\le e$ invalid steps, the verifier is sound (uniformly over provers).
* (b) For tagged schemas with budgets $e_i$, suppose for each $i$:
  * (i) $\le e_i$ invalid steps are tagged $i$;
  * (ii) the valid rule-$i$ samples are **$e_i$-robustly generic**: for every $x$ and $f$, more than $e_i$ samples have $\mathrm{root}(\Theta x)\neq f$; and for every $x\ne y$, more than $e_i$ samples have $\Theta x\ne\Theta y$.

  Then the verifier accepts exactly $R^*$.

*Proof.*
* (a) $R^*\in\mathrm{VS}_e$.
* (b) A tag-$i$ hypothesis $\mathrm{inst}(\tau)\in\mathrm{VS}_{e_i}$ covers all but $\le e_i$ of the valid samples. By (ii), the remaining valid samples still satisfy (R) and (D), so they are generic. Then $\tau\succeq\sigma_i$ by Lemma 1.3. ∎

The accepted set is $\mathrm{inst}$ of the most general common instance (unification) of the lggs of the $(|P|-e)$-subsets. [computed] With $e=1$ (resp. 2), one (resp. two) mis-tagged errors are removed exactly. With $e=1$ and two errors, the lgg collapses again.

**Theorem 6.3 (i.i.d. noise: witness frequency must beat error frequency) [proved].**
* Each datum is a valid rule-$i$ step with probability $\beta_i$ (law $\Lambda_i$), or an invalid step tagged $i$ with probability $\alpha_i$ (arbitrary law).
* Let $\rho_i$ be as in Thm 5.3, with the split $G$ attaining the maximum. Assume the margin $\Delta_i:=(\rho_i\beta_i-\alpha_i)/2>0$, and set $e_i=\lfloor(\alpha_i+\Delta_i)N\rfloor$.

Then
$$\Pr[\text{trimmed verifier}=R^*]\ \ge\ 1-\sum_i(1+c_i)\,e^{-2N\Delta_i^2}.$$

*Proof.*
* The number of invalid steps tagged $i$ is $\mathrm{Bin}(N,\alpha_i)$, so by Hoeffding $\Pr[>e_i]\le e^{-2N\Delta_i^2}$.
* For robust genericity, it suffices that $\#\{\mathrm{root}\in G\}$, $\#\{\mathrm{root}\notin G\}$ and $\#\{\Theta x\ne\Theta y\}$ all exceed $e_i$. Every $f$ lies on one side of the split, and the other side's count is $\le\#\{\mathrm{root}\neq f\}$.
* Each of these counts is $\mathrm{Bin}(N,\ge\rho_i\beta_i)$, with mean $\ge(\alpha_i+2\Delta_i)N$. Hoeffding again, and a union bound over the $c_i$ events. ∎

**Theorem 6.4 (indistinguishability: the frequency threshold is necessary) [proved; in the spirit of Kearns & Li 1993].**
* Call a positive-data verifier **$(\delta,\alpha)$-robustly sound** for $H$ if, for every $R^*\in H$ and every data law $D$ with $D(S\setminus R^*)\le\alpha$, $\Pr[\exists t:\mathrm{Acc}_t\not\subseteq R^*]\le\delta$.
* Let $R^*\subsetneq R'$ both lie in $H$, and let $D$ be any law on $R'$ with $D(R'\setminus R^*)\le\alpha$.

Then under $D$, every fixed $q\in R'\setminus R^*$ is accepted with probability $\le\delta$ at every time. So the verifier is **not complete** for $R'$ under the clean law $D$.

*Proof.* $D$ is an admissible noisy law for target $R^*$, and the data distribution is the same in both scenarios. ∎

*Consequences for schemas.*
* For tagged schemas, apply Thm 6.4 to $\sigma'$ and each maximal proper specialization $\sigma''$: $x\mapsto f(\bar z)$, or $x:=y$. Completeness under noise rate $\alpha$ requires every witness frequency $\Pr[\mathrm{root}(\Theta x)\ne f]$ and $\Pr[\Theta x\ne\Theta y]$ to exceed $\alpha$.
* Since $\rho_x\le1-\max_fF_x(f)\le3\rho_x$, Thm 6.3 matches this necessity up to a factor of 3 plus margins.
* **There is an unavoidable trade-off.** A positive-data verifier that tolerates error rate $\alpha$ must refuse every rule-generality supported by less than $\alpha$ of the data. With human error rates around 1%, rules used in less than about 1% of steps need negative information.

**Corollary 6.5 (systematic errors are rules) [proved].** Let $H$ be closed under adding a schema (tagged multi-schema rules, or untagged unions with unbounded $k$). Let human errors be **schema-generated**: $D_{\rm err}$ is supported on $\mathrm{inst}(\tau)$ with $\mathrm{inst}(\tau)\not\subseteq R^*$. Then the human data law is a *clean* law for $R^*\cup\mathrm{inst}(\tau)\in H$, at every error rate.

So no positive-data method, with any amount of data, can both tolerate such errors and learn genuine rules of the same frequency. This also defeats the Bayesian guarantee: a model that treats errors as sporadic is misspecified, and its posterior moves to "rule + fallacy".

The line between *sporadic* and *systematic* errors is therefore exact:
* errors removable by positive data are those rarer than the witness frequencies of the genuine rules;
* "rule-like" errors at any rate need **negative information**: escalation, coherence, or world feedback.

**Proposition 6.6 (in CPC, coherence refutes every systematic error) [proved; cf. T2 Thm 3.1].** In classical propositional logic, a substitution-closed $A\supseteq R^*_{\rm CPC}$ is sound iff $\bot\notin\mathrm{Cl}_A(\emptyset)$, by Prop 2.3 plus ex falso.

For example, the fallacy "affirming the consequent" yields $\bot$ from $\bot\to\top$ and $\top$. So a coherence test *in the empty (or actual) context*, rather than in hypothetical contexts where deriving $\bot$ is legitimate reductio, catches every unsound learned schema. The test also returns a **negative bag**: the derivation of $\bot$, at least one of whose steps is invalid. This is the hand-off to T2.

In arithmetic the analogue fails. Unsound but consistent additions exist (e.g. $\neg\mathrm{Con}(\mathrm{PA})$), so coherence must be supplemented by world feedback (computation refuting false $\Pi_1$ claims; T2 §3.5).

---

## 7. Computational checks (`T1-code/`)

| check | result |
|---|---|
| single schema chains, exhaustive, $N\le4$ | max $=N+1$ with two constants and $N$ with one; matches Thm 3.4 |
| 2-unions of deep schemas, $\{c,g,p\}$, $N=3,4,5$ | $4,8,13$ (vs. $N+1$ for one schema) |
| 2-unions, $\{a,b,g,p\}$, $N=3,4$ | $8,13$; 3-unions at $N=3$: $10$ (whole universe) |
| subcubes, $k=2$, $n=2,3,4$ | $4,7,11=\sum_{w\le2}\binom nw$ (lower bound in Thm 3.7(iii) exact) |
| partition abstraction, $k=2$, $d=3,4$ | $7,15=2^d-1$ (Ramsey recursion tight for the abstraction) |
| intersection-closed families, hill-climbing, $k=2$, $h=2..5$ | $3,6,10,14$ (Conj 3.8 predicts $\le3,6,10,15$) |
| Ville example | ratio to $\delta'$: 0.78 at $u=.5$; 0.99 at $u=.01$ |
| toy ND identification, noise collapse, trimming | as reported in §5–§6 |

---

## 8. Assessment

**Deep, trivial-once-set-up, or known.**
* *Trivial once set up, but the setup is the point:*
  * Lemma 1.1;
  * Thm 2.1 / Cor 2.2 (the right quantifier is $\sup$);
  * Thm 3.1;
  * Thm 5.1;
  * Thm 6.4 / Cor 6.5.
* *Known in substance:*
  * the closure-algorithm facts (Prop 3.3, Natarajan; Helmbold–Sloan–Warmuth);
  * the Plotkin lattice;
  * the KWIK enumeration bound;
  * Ville's inequality and test martingales (Shafer, Shen, Vereshchagin & Vovk 2011).
* *New here, as far as I know:*
  * the exact single-schema budget $1+\mu-\mu^*$;
  * the tagged/untagged separation ($k(N+1)$ vs. $\ge\lfloor(N-1)/k\rfloor^k$);
  * the $\mathrm{Bell}$ lower bound for two-sided checking;
  * the prover-uniform form of Thm 4.2(b) and the tightness of its constant;
  * anchors vs. tell-tales for *verification*;
  * the witness-event sample complexity and its noise version, with matching necessity up to a factor of 3;
  * the exact statement that schema-generated errors are indistinguishable from rules.

  None of these is deep. Their value is that together they pin down when the user's program works.

**Weaknesses.**
1. *Realizability is load-bearing.* If the true calculus is not in $H$ (e.g. two untagged rules, but $H=H_1$), the lgg overgeneralizes and soundness fails. The Bayesian hierarchy repairs this only probabilistically, at exponential escalation cost in the complexity of what is missing.
2. Soundness is relative to the *human* calculus. The rules learned are exactly as good as humans' rules (including naive comprehension, if humans use it).
3. The first-order-term model of steps idealizes away AC contexts, binders and variable-arity rules (see the remarks after Cor 5.5).
4. Untagged unions: the gap between the polynomial lower bound and the exponential upper bound is open (Conj 3.8).
5. Informal mathematics, where steps are derived and gappy, is not covered by these classes.

**What this says about the user's questions.**
* *"Give an appropriate learning algorithm for inference rules — maybe learning from positive examples?"* Yes. The algorithm is:
  * least-general generalization per cited rule;
  * the version-space intersection as the verifier;
  * trimming for sporadic errors;
  * escalation for uncertain steps;
  * a conservative (not MAP) Bayesian layer over the number and shape of rules.

  Not MDL-simplest (Prop 2.4), and not a scalar step-scorer (Thm 2.1).
* *"Does it + coherence get formal math working?"* For a formal calculus with rule citations it works from positive data alone, provably:
  * sound at all times;
  * exactly the calculus after $\tilde O(\max_i 1/(\pi_i\rho_i))$ steps;
  * systematic generalization;
  * search-proof soundness.

  Coherence is needed only for systematic errors, or, in T2's terms, for rules too rare to be learned robustly.
* *Before formalization.* Without rule citations, untagged unions cost $\Omega((N/k)^k)$ escalations in the worst case. Identification still holds under diversity ($\zeta_i>0$), but requires a bound $k$ on the number of rules that is smaller than the instantiation variety. This quantifies one way in which "inventing a language with named rules" (the user's note on how math got formalized) makes inference learnable.

**Open problems.**
1. Prove or refute Conj 3.8. Even $N^{O(k)}$ for deep schemas would suffice for the qualitative picture.
2. Escalation bounds for AC-contexts and side conditions with eigenvariables.
3. Robust identification with *rare* rules: how many coherence-derived negative bags (T2) replace one oracle escalation?
4. A hypothesis class for derived (gappy) informal steps with finite anchors.
5. Efficient computation of $\bigcap\mathrm{VS}_{H_k}$ (it looks NP-hard in $|P|$; Arimura–Shinohara–Otsuki compactness conditions may give polynomial cases).

---

## References

(✓ = bibliographic data believed accurate; (unverified) = from memory.)

* Alpuente, Escobar, Espert & Meseguer (2014). A modular order-sorted equational generalization algorithm. *Information and Computation* 235 (unverified).
* Angluin, D. (1980). Inductive inference of formal languages from positive data. *Information and Control* 45:117–135 ✓.
* Arimura, H., Shinohara, T. & Otsuki, S. (1994). Finding minimal generalizations for unions of pattern languages and its application to inductive inference from positive data. STACS 1994, LNCS 775 (unverified details).
* Baumgartner, Kutsia, Levy & Villaret (2017). Higher-order pattern anti-unification in linear time. *J. Automated Reasoning* 58 (unverified).
* Belnap, N. (1962). Tonk, plonk and plink. *Analysis* 22:130–134 ✓.
* Blumer, A., Ehrenfeucht, A., Haussler, D. & Warmuth, M. (1989). Learnability and the Vapnik–Chervonenkis dimension. *JACM* 36:929–965 ✓.
* El-Yaniv, R. & Wiener, Y. (2010). On the foundations of noise-free selective classification. *JMLR* 11:1605–1641 ✓.
* Gao, L., Schulman, J. & Hilton, J. (2023). Scaling laws for reward model overoptimization. ICML ✓.
* Gold, E. M. (1967). Language identification in the limit. *Information and Control* 10:447–474 ✓.
* Haussler, D. & Welzl, E. (1987). ε-nets and simplex range queries. *Discrete & Computational Geometry* 2:127–151 ✓.
* Helmbold, D., Sloan, R. & Warmuth, M. (1990). Learning nested differences of intersection-closed concept classes. *Machine Learning* 5:165–196 ✓.
* Kearns, M. & Li, M. (1993). Learning in the presence of malicious errors. *SIAM J. Comput.* 22:807–837 ✓.
* Li, L., Littman, M. & Walsh, T. (2008). Knows what it knows: a framework for self-aware learning. ICML ✓.
* Lightman, H. et al. (2023). Let's verify step by step. arXiv:2305.20050 ✓.
* Natarajan, B. K. (1987). On learning Boolean functions. STOC ✓.
* Plotkin, G. D. (1970). A note on inductive generalization. *Machine Intelligence* 5:153–163 ✓.
* Post, E. (1921). Introduction to a general theory of elementary propositions. *Amer. J. Math.* 43:163–185 ✓.
* Prior, A. N. (1960). The runabout inference-ticket. *Analysis* 21:38–39 ✓.
* Reynolds, J. C. (1970). Transformational systems and the algebraic structure of atomic formulas. *Machine Intelligence* 5:135–151 ✓.
* Rivest, R. & Sloan, R. (1988). Learning complicated concepts reliably and usefully. AAAI ✓.
* Shafer, G., Shen, A., Vereshchagin, N. & Vovk, V. (2011). Test martingales, Bayes factors and p-values. *Statistical Science* 26:84–101 ✓.
* Ville, J. (1939). *Étude critique de la notion de collectif*. Gauthier-Villars ✓.
* Wright, K. (1989). Identification of unions of languages drawn from an identifiable class. COLT, 328–333 ✓; corrected by Motoki, Shinohara & Wright (1991), COLT ✓.
