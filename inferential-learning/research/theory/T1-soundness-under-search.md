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
   * Average-case accuracy says nothing about this. For **every** distribution $Q$ on steps and every $\varepsilon>0$, there is a rule set with $Q$-error $<\varepsilon$ that derives every formula. It consists of finitely many pure schemas if $R^*$ does. It needs one bad step, a tonk-like padding rule $A\vee(\top\wedge\cdots\wedge\top)\vdash A$ (Thm 2.1).
   * Any PAC learner can be modified into one that is still PAC, with the same rates up to $O(\varepsilon^{-1}\log\delta^{-1})$ extra samples, but whose every output trivializes the reasoner (Cor 2.2).
   * In classical propositional logic, every unsound *pure* schema (one in which no specific object-language atom occurs) trivializes, by Post completeness (Prop 2.3). A schema that mentions specific atoms can be unsound without trivializing. Replacing its atoms by metavariables restores the dichotomy, and in CPC this replacement preserves soundness.
   * A simplicity (MDL/Occam) learner on positive data chooses the universal schema "anything from anything" (Prop 2.4).
2. **Version-space verification is sound by construction. Its price is exactly a "positive elasticity".**
   * The verifier accepts a step iff every hypothesis consistent with the data accepts it. This is sound against all provers and optimal among sound verifiers (Thm 3.1).
   * Its worst-case number of escalations (human interventions) on honest provers is exactly the length of the longest elastic chain inside the target (Thm 3.2). I call this the *escalation dimension*.
   * Computed values:
     * a **single schema** learned by anti-unification costs at most $1+\mu(t_1)-\mu(\sigma^*)\le N+1$ escalations, which is tight. Here $\mu=$ size minus number of distinct variables and $N$ is the step size (Thm 3.4).
     * **$k$ tagged rules** cost the sum of the per-rule costs (Thm 3.6).
     * **untagged unions of $k$ schemas** cost at least $\lfloor (N-1)/k\rfloor^k$, even when the truth is a single rule. The cost is at most $(k^{N+1}-1)/(k-1)$. For *linear* flat schemas (subcubes of $\{a,b\}^n$, $n\ge k$) it is $\Theta(n^k)$. With repeated metavariables it lies between $\Omega(n^k)$ and $O(n^{2k})$ (Thm 3.7).
     * I conjecture $\binom{h+k-1}{k}$ for any intersection-closed class of height $h$ (Conj 3.8). If true, this is tight at $k=2$ (graphic matroids). It is proved for $(k,h)=(2,3)$.
     * **unstructured** classes cost $|H|-1$, tight (Thm 3.9).
   * Certifying *invalidity* as well (two-sided KWIK) costs at least $\mathrm{Bell}(N-1)$ for a single schema, over a signature that grows with $N$ (Prop 3.5). Over a fixed finite signature it costs at most $2^{O(N)}$. It is never needed for soundness.
3. **The Bayesian-conservative verifier** accepts iff the posterior probability of invalidity is $<\delta$.
   * With the version-space posterior, $\delta\le w^*$ gives deterministic soundness, and this threshold is tight (Thm 4.1).
   * With a well-specified likelihood (noisy human data, noisy oracle), take $\delta\le w^*\delta'$. Then **the probability that any invalid step is ever accepted, at any time, for any adaptive prover that cannot foresee the data or the oracle's (fresh) noise, is at most $\delta'$**. This is the prior–posterior-ratio martingale argument of Waudby-Smith & Ramdas (2020). The constant 1 is tight (Thm 4.2, Prop 4.3). With a deterministic oracle, the good event does not depend on the prover, and the prover may know everything.
   * Escalations are at most $\ln(1/(w^*\delta''))/\delta$ (Thm 4.4). Any $\delta'$-sound verifier needs at least $(1-\delta')(1/w^*-1)$ on unstructured classes (Cor 4.5). This is exponential in description length.
   * Combining with the version space gives $\min\{\text{escalation dimension},\ \ln(1/w^*)/\delta\}$ (Cor 4.6).
   * **Structure, not the prior, is what makes sound learned verification affordable.**
4. **Positive data alone.**
   * The version-space verifier is sound at all times.
   * It becomes complete iff the target has a finite **anchor**: a finite $T$ such that every hypothesis containing $T$ contains the target (Thm 5.1). This is strictly stronger than Angluin's tell-tale. For intersection-closed classes, every nonempty tell-tale is an anchor, so existence of either implies existence of the other (Prop 5.2). The anchor condition is the Lange–Zeugmann condition for strong-monotonic learning.
   * For tagged schemas, exact identification holds with probability $\ge1-\sum_i c_i e^{-N\pi_i\rho_i}$, where $\pi_i$ is a rule's frequency and $\rho_i$ the variability of its instances (Thm 5.3). This is coupon-collector behaviour.
   * For untagged $k$-unions it holds once each rule's instances cannot be covered by $k$ "failure sets", with ε-net sample complexity (Thm 5.4).
   * Exact identification means the verifier accepts *exactly* the human calculus. This gives systematic generalization to derivations of any length and formulas of any size (Cor 5.5).
5. **Noise.**
   * One wrongly-tagged human step turns the lgg of $\wedge$E into "from anything infer anything" (Prop 6.1).
   * The **trimmed version space** (hypotheses that miss at most $e$ data points) is sound when there are at most $e$ errors. With per-rule budgets $e_i$, it is complete when every *witness event* of every rule $i$ occurs more than $e_i$ times (Thm 6.2). Under i.i.d. noise this needs witness frequency to exceed error frequency (Thm 6.3).
   * This is optimal up to a factor of 2, and the factor 2 is tight. Any positive-data verifier robust to error rate $\alpha$ must refuse every generalization supported by less than $\alpha$ of the data (Thm 6.4).
   * **Schema-generated (systematic) errors are indistinguishable from rules at every rate** (Cor 6.5).
   * Removing them needs negative information. In classical propositional logic, *coherence* (deriving $\bot$ in the empty context) detects every unsound *pure* schema. It detects every unsound schema once atoms occurring in schemas are replaced by metavariables (Prop 6.6; see T2 Thm 3.1). Applied directly to a schema that mentions specific atoms, it can miss the error. In arithmetic it does not detect every error.

**Upshot for the user's program.** "Learn inference rules from positive examples" works, provably, for formal math with rule citations. Use anti-unification as the learning algorithm and the version space as the verifier. The result is deterministically sound from the first example and exactly correct after coupon-collector many examples. No negative data or human escalation is needed beyond that. Each bullet is a formal statement below:
* Losing rule citations (informal steps) costs at least a polynomial of degree $k$ in escalations. The proved upper bound is exponential, and $\Theta_k(N^k)$ is conjectured (Conj 3.8).
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

So a verifier is safe for *arbitrarily long* derivations iff its acceptance region contains no non-derivable step. Conversely, one accepted non-derivable step $(\Pi,j)$ with derivable premises yields a conclusion that is not derivable in $R^*$. There is no "small error rate" middle ground.

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
* The cost of a run is the number of rounds in which a valid query is not accepted outright (escalated or rejected). For a randomized verifier, the cost on a given target and query sequence is the *expected* cost. For 0-sound verifiers this distinction never matters below, because the lower bounds hold almost surely.
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
* (i) Every formula $C$ is in $\mathrm{Cl}_{R^*\cup T_j}(\emptyset)$, via a derivation of $j+2$ steps. Only the last step uses $T_j$, and for non-tautologous $C$ that step is invalid.
* (ii) For every probability distribution $Q$ on $S$ (over valid steps, invalid steps or both), $Q(T_j)\to0$ as $j\to\infty$.

So for every $Q$ and every $\varepsilon>0$, the hypothesis $R^*\cup T_j$ has $Q$-error $<\varepsilon$ and trivializes the reasoner. If $R^*$ is given by finitely many pure schemas, so is $R^*\cup T_j$.

*Proof.*
* (i) Derive $\top$ ($\top$I), then $\top^{(2)},\dots,\top^{(j)}$ ($j-1$ applications of $\wedge$I). Next derive $C\vee\top^{(j)}$ ($\vee$I$_2$), and finally $C$ ($T_j$). The premise of the $T_j$ step, $C\vee\top^{(j)}$, is a tautology. So for non-tautologous $C$ the step is unsound, and hence not in $R^*$.
* (ii) The sets $T_j$ are pairwise disjoint, so $\sum_jQ(T_j)\le1$. ∎

**Corollary 2.2 (PAC learners can be maximally unsound) [proved] (revised after verification).** Let $\mathcal L$ be any learner. From a sample $X_1..X_m\sim Q$, let $\mathcal L^+$ output
$$\mathcal L(X_{1..m})\ \cup\ T_{\hat\jmath}\ \cup\ \mathrm{inst}(\top\text{I},\wedge\text{I},\vee\text{I}_2),\qquad\hat\jmath:=1+\max_i|X_i|.$$
Then for every $Q$:
$$\Pr\big[Q(T_{\hat\jmath})>\varepsilon\big]\le(1-\varepsilon)^m.$$
The three added schemas lie in $R^*$, so adding them never increases the error $Q(h\,\Delta\,R^*)$. Since $\mathrm{err}_Q(\mathcal L^+)\le\mathrm{err}_Q(\mathcal L)+Q(T_{\hat\jmath})$, we get $\mathrm{err}_Q(\mathcal L^+)\le\mathrm{err}_Q(\mathcal L)+\varepsilon$ with probability $\ge1-(1-\varepsilon)^m$. If $\mathcal L$ is a PAC learner, so is $\mathcal L^+$, with $O(\varepsilon^{-1}\log\delta^{-1})$ extra samples. But **every** output of $\mathcal L^+$ makes every formula derivable, because the derivation of Thm 2.1(i) uses only $\top$I, $\wedge$I, $\vee$I$_2$ and $T_{\hat\jmath}$. (Without the three added schemas this fails in general. For example, $\mathcal L\equiv\emptyset$ gives the output $T_{\hat\jmath}$, whose closure from $\emptyset$ is empty.)

*Proof.* Every step of $T_j$ has size $\ge|\top^{(j)}|\ge j$, so $T_j\subseteq\{s:|s|\ge j\}$.
* Let $N_\varepsilon=\min\{N:Q(|s|\ge N)\le\varepsilon\}$, which exists since $Q(|s|\ge N)\downarrow0$.
* If $\hat\jmath\ge N_\varepsilon$, then $Q(T_{\hat\jmath})\le\varepsilon$.
* Otherwise all $m$ samples have size $<N_\varepsilon-1$. Since $Q(|s|\ge N_\varepsilon-1)>\varepsilon$, this has probability $\le(1-\varepsilon)^m$. ∎

**Proposition 2.3 (in classical logic every unsound *pure* schema is a tonk) [proved; essentially Post 1921] (scope revised after verification).** Let $R^*_{\rm CPC}$ be sound and complete for classical propositional consequence, with $\top,\bot,\neg$ available. Let $A=R^*_{\rm CPC}\cup A_1$, where $A_1$ is closed under uniform substitution of formulas for atoms. Examples of such $A_1$: the set of all steps, or the instance set of any family of **pure** schemas, i.e. schemas in which no object-language atom occurs as a constant. If $A$ contains an unsound step, then $\mathrm{Cl}_A(\emptyset)$ is the set of all formulas.

*Proof.*
* Let $(\Pi,\varphi)\in A$ be unsound, witnessed by a valuation $v$ with $v(\Pi)=1$ and $v(\varphi)=0$. It lies in $A_1$, since $R^*_{\rm CPC}$ is sound.
* Substitute $\top$ for each atom true under $v$ and $\bot$ for each false atom. This gives a step $(\Pi',\varphi')\in A_1$ with variable-free formulas, each $\pi\in\Pi'$ true and $\varphi'$ false.
* By completeness, each $\pi\in\Pi'$ and $\neg\varphi'$ are derivable from $\emptyset$. The step yields $\varphi'$, hence $\bot$, hence everything. ∎

(The full consequence-relation version, and its use for learning, is T2 Thm 3.1.) For hypotheses built from pure schemas in classical logic, *any* error is total.

*Scope: schemas that mention atoms (added after verification).* In the encoding of §1.3, object-language atoms are constants of $\Sigma$. So a learned schema can mention specific atoms, for example the lgg of data in which some column is constantly $p_0$. Such instance sets are not closed under substitution, and **the proposition fails for them**.
* *Counterexample.* $\tau=(\{x\vee p_0\},x)$ is unsound: its instance $(\{p_1\vee p_0\},p_1)$ is invalid. Yet $\mathrm{Cn}(\neg p_0)$ is closed under $R^*_{\rm CPC}\cup\mathrm{inst}(\tau)$, because $\neg p_0\models B\vee p_0$ implies $\neg p_0\models B$. So $\mathrm{Cl}(\emptyset)\subseteq\mathrm{Cn}(\neg p_0)\not\ni p_0$. The reasoner is unsound, since it derives $\neg p_0$, but it is not trivial.
* *A simpler case.* A single ground error step $(\{p_0\},p_1)$ never fires from $\emptyset$.

*Repair by purification.* Let $\tau^\circ$ be $\tau$ with each atom occurring in it replaced by a fresh metavariable. Since classical consequence is structural, **$\tau$ is sound iff $\tau^\circ$ is sound** [proved]:
* (⇐) $\mathrm{inst}(\tau)\subseteq\mathrm{inst}(\tau^\circ)$.
* (⇒) Let $\bar p$ be the atoms of $\tau$. An instance of $\tau^\circ$ has the form $\tau[\bar x\mapsto\bar A,\ \bar p\mapsto\bar B]$, where $\bar p$ is replaced only at $\tau$'s own occurrences. Pick fresh atoms $\bar r$ that occur nowhere in $\bar A,\bar B,\tau$. Then $\tau[\bar x\mapsto\bar A[\bar p\mapsto\bar r]]$ is an instance of $\tau$, hence valid. Its image under the uniform substitution $\bar p\mapsto\bar B,\ \bar r\mapsto\bar p$ is the given instance, and uniform substitution preserves classical validity.

Hence the proposition applies to $A^\circ:=R^*_{\rm CPC}\cup\bigcup_l\mathrm{inst}(\tau_l^\circ)$, and $A=R^*_{\rm CPC}\cup\bigcup_l\mathrm{inst}(\tau_l)$ is sound iff $A^\circ$ is sound iff $\bot\notin\mathrm{Cl}_{A^\circ}(\emptyset)$.

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
* (b) **(revised after verification)** Fix the human data $P_0$, as in Definition 1.3. Let a (possibly randomized) verifier be $\delta$-sound. Fix a target $R^*\supseteq P_0$ and a history $h$ consistent with $R^*$: queries $q_1..q_t$ with the verifier's answers and the oracle labels. Fix a query $q\notin\bigcap\mathrm{VS}$, where VS is computed from $P_0$ and all labels in $h$. Let
  $$p:=\Pr_{R^*}\big[\text{the run produces }h\text{ and then accepts }q\big]$$
  for the prover that issues $q_1,\dots,q_t,q$. This is a **joint** (unconditional) probability, taken over the verifier's coins. Then $p\le\delta$.
  * In particular, a deterministic $\delta$-sound verifier with $\delta<1$ never accepts any $q\notin\bigcap\mathrm{VS}$ at any history consistent with $R^*$. With fixed queries its history is deterministic, so $p\in\{0,1\}$.
  * For randomized verifiers the *conditional* acceptance probability given $h$ is **not** bounded by $\delta$. Example: $H=\{R_1=\{a,c\},R_2=\{a,b,c\},R_3=\{a,b\}\}$ and $P_0=\emptyset$. The verifier accepts everything with probability $\varepsilon$ ("reckless mode"), and otherwise runs the VS verifier. It is $\varepsilon$-sound. Under $R^*=R_2$, the history $h=(c,\mathrm{ACC})$ occurs only in reckless mode. There $\bigcap\mathrm{VS}=\{a\}\not\ni b$, yet $\Pr[b\text{ accepted}\mid h]=1$. The joint probability is $\varepsilon$, as (b) says.

*Proof.*
* (a) All labels are truthful.
* (b) Pick $R'\in\mathrm{VS}$ with $q\notin R'$, so $P_0\subseteq R'$ and $R'$ agrees with every label in $h$. Run the same prover under target $R'$. Each round's answer has the same conditional law given the past under $R'$ as under $R^*$: the verifier's coins have the same law, and the oracle returns the same labels on $h$. So $\Pr_{R'}[h\text{ and then }q\text{ accepted}]=p$. Since $q\notin R'$, $\delta$-soundness for target $R'$ gives $p\le\delta$. ∎

With *random* human data the same argument gives $\Pr_{R'}[\text{observed data}]\cdot p\le\delta$, where $p$ is the joint probability above given the observed data. The bound weakens as the observed data become unlikely under $R'$. When the data refute $R'$ it disappears, and that is the Bayesian setting of §4.

**Definition (positive elasticity).** For $R\in H$ with $R\supseteq P_0$, an **elastic chain in $R$** is a sequence $s_1,\dots,s_m\in R$ with $s_i\notin\bigcap\mathrm{VS}(P_0\cup\{s_1..s_{i-1}\})$ for every $i$. Equivalently, there are $R_i\in H$ with $P_0\cup\{s_{<i}\}\subseteq R_i\not\ni s_i$. Let $\mathrm{el}(H,R\mid P_0)$ be the supremum of chain lengths. (Wright's elasticity, made bounded and relative to a target; L1 §2.3, L2 Thm 5.)

**Theorem 3.2 (escalation dimension = positive elasticity) [proved].**
$$\mathrm{Esc}(H\mid P_0)=\sup_{R\in H,\,R\supseteq P_0}\mathrm{el}(H,R\mid P_0).$$
The VS verifier attains it. Moreover, every $\delta$-sound randomized verifier has expected cost $\ge(1-\delta)m$ on some honest sequence of length $m$, for every $m\le\sup\mathrm{el}$.

*Proof.*
* *Upper bound.* Against an honest prover the VS verifier never rejects, because $q\in R^*\subseteq\bigcup\mathrm{VS}$. Its escalated queries $s_1,s_2,\dots$ satisfy $s_i\notin\bigcap\mathrm{VS}$ at the time of the query, where VS contains $P_0$ and the earlier escalated positives. So they form an elastic chain in $R^*$. (Accepted queries add nothing, since they already lie in $\bigcap\mathrm{VS}$.)
* *Lower bound* (proof revised after verification). Take an elastic chain $s_1..s_m$ in $R$, with witnesses $R_i\in H$, $P_0\cup\{s_{<i}\}\subseteq R_i\not\ni s_i$. Let the prover query $s_1,\dots,s_m$ in order, non-adaptively. For each $j<i$ we have $s_j\in R\cap R_i$, so the oracle gives the same label under targets $R$ and $R_i$. Hence the joint law of the transcript up to and including the verifier's answer in round $i$ is the same under $R$ and under $R_i$ (a coupling through the verifier's coins). Under $R_i$, $s_i$ is invalid, so by $\delta$-soundness $\Pr_{R_i}[s_i\text{ accepted in round }i]\le\delta$. Hence $\Pr_R[s_i\text{ accepted in round }i]\le\delta$. Summing over $i$, the expected cost under the honest target $R$ is $\ge(1-\delta)m$. With $\delta=0$ the cost is $m$ almost surely. (This is the joint-probability form of Thm 3.1(b).) ∎

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

**Theorem 3.4 (single schema learned by anti-unification) [proved] (displays restated after verification).** For $H_1$, target $\sigma^*$, and nonempty $P_0\subseteq\mathrm{inst}(\sigma^*)$:
$$\mathrm{el}(H_1,\sigma^*\mid P_0)\ \le\ \mu(\mathrm{lgg}\,P_0)-\mu(\sigma^*).$$
With $P_0=\emptyset$ and steps of size $\le N$:
$$\mathrm{el}(H_1,\sigma^*\mid\emptyset;\,|s|\le N)\le 1+N-\mu(\sigma^*),\qquad\text{hence}\qquad\mathrm{Esc}(H_1;\,|s|\le N)\le N+1.$$
This is tight. If $\Sigma$ has two constants $a,b$ and a unary $g$, there is an honest sequence of $N+1$ escalations for $\sigma^*=x$, so $\mathrm{Esc}(H_1;\,|s|\le N)=N+1$.

*Proof.*
* *Upper bound.* By Prop 3.3, a chain gives members $\mathrm{cl}(P_0)=C_0\subsetneq C_1\subsetneq\dots\subsetneq C_m\subseteq\mathrm{inst}(\sigma^*)$. Choose the representatives $g_i:=\mathrm{lgg}(C_i)$.
  * Each $C_i$ is some $\mathrm{inst}(\tau_i)$, and $g_i\preceq\tau_i$, so $\mathrm{inst}(g_i)=C_i$.
  * $C_{i-1}\subseteq C_i\subseteq\mathrm{inst}(g_i)$ gives $g_{i-1}\preceq g_i$. The inequality is strict, because the instance sets differ. This uses no assumption on the signature.
  * $g_0=\mathrm{lgg}(P_0)$, and $g_m\preceq\sigma^*$.

  So $\mathrm{lgg}(P_0)=g_0\prec g_1\prec\dots\prec g_m\preceq\sigma^*$. By Lemma 1.2, $\mu$ drops by $\ge1$ per step and stays $\ge\mu(\sigma^*)$. With $P_0=\emptyset$, the first query is always escalated, since $\bigcap\mathrm{VS}(\emptyset)=\emptyset$, and then $\mu(\text{first query})\le N$.
* *Tightness.* Query $g^{N-1}(a)$, $g^{N-1}(b)$, $g^{N-2}(a)$, $g^{N-3}(a)$, …, $a$. The lggs are $g^{N-1}(a)$, $g^{N-1}(x)$, $g^{N-2}(x)$, …, $x$, with $\mu=N,N-1,\dots,0$. Each query lies outside the previous lgg. [computed: exhaustive search over all ground terms of size $\le N$ for $N\le4$ gives exactly $N+1$; with only one constant it gives $N$.] ∎

This sharpens L2 Thm 5(c), which has $2|s|$. In words, after the human corpus $P_0$ the residual escalation budget is the **generality gap** $\mu(\mathrm{lgg}P_0)-\mu(\sigma^*)$. It is zero once the corpus has identified the rule (§5).

**Proposition 3.5 (two-sided KWIK is super-exponential over growing signatures) [proved] (revised after verification).** Suppose the verifier must also *certify* invalidity, rejecting only steps outside $\bigcup\mathrm{VS}$, and every escalation is counted. Then for $H_1$ over a signature with $n+1$ constants and an $n$-ary symbol, there are a target and a prover forcing at least $\mathrm{Bell}(n)$ escalations on steps of size $n+1$.

The signature must grow with the step size for this. Over a **fixed** finite signature the two-sided cost on steps of size $\le N$ is at most the number of such steps, $2^{O(N)}$, because an escalated step is labelled and never escalated again. So "super-exponential" is in $N$ only when the signature grows with $N$.

*Proof.*
* Use constants $a,b_1,\dots,b_n$, an $n$-ary $f$, target $R^*=\{f(a,\dots,a)\}$, and $P_0=R^*$.
* For a partition $\pi$ of $[n]$, let $s_\pi=f(b_{\pi(1)},\dots,b_{\pi(n)})$, where $\pi(j)$ is the index of $j$'s block, and $\sigma_\pi=f(x_{\pi(1)},\dots,x_{\pi(n)})\succeq f(a,\dots,a)$.
* $s_{\pi'}\in\mathrm{inst}(\sigma_\pi)$ iff $\pi$ refines $\pi'$.
* Query the $s_\pi$ along a linear extension of refinement, finest first. When $s_\pi$ is queried, no coarser $s_{\pi'}$ has been labelled. So $\sigma_\pi$ is alive, $s_\pi\in\bigcup\mathrm{VS}$, and the verifier cannot reject. Each $s_\pi$ is invalid, so it must be escalated. ∎

So certifying *validity* costs $\le N+1$ over every signature. Certifying *invalidity* costs $\ge\mathrm{Bell}(N-1)$ over a signature with $N$ constants and an $(N-1)$-ary symbol, and in general it is bounded only by the number of steps (compare L2 Thm 5(d) for conjunctions). [computed during verification: `T1-code/checks37.py` (brute force) gives forced escalations $2,5,15=\mathrm{Bell}(2),\mathrm{Bell}(3),\mathrm{Bell}(4)$ for $n=2,3,4$.] A step checker never needs the second: an unaccepted step is merely unusable. **One-sidedness is what makes learned verification cheap.**

**Theorem 3.6 (k tagged rules) [proved] (justification revised after verification).**
* Tagged steps $(i,s)$, $i\in[k]$, record which rule the step cites, as formal proofs do (Lean lemma names, Metamath labels, ND rule names).
* Let $H^{\rm tag}_k=\{\bigcup_i\{i\}\times\mathrm{inst}(\sigma_i)\}$.
  * This class is *not* literally intersection-closed: a componentwise intersection can empty one rule's component while the others stay nonempty.
  * What the proof uses is that the **version space factors**. For data $P$ with rule-$i$ part $P^{(i)}$, $\mathrm{VS}(P)=\prod_i\mathrm{VS}_i(P^{(i)})$, where each factor is a nonempty version space of single schemas (it contains $\sigma_i^*$). Hence $\bigcap\mathrm{VS}(P)=\bigcup_i\{i\}\times\bigcap\mathrm{VS}_i(P^{(i)})$.
  * So a tagged step $(i,s)$ escapes iff $s$ escapes in the single-schema class with data $P^{(i)}$.
* Hence elastic chains are exactly the interleavings of per-rule elastic chains, and
$$\mathrm{el}=\sum_i\mathrm{el}_i,\qquad \mathrm{el}_i\le\begin{cases}\mu(\mathrm{lgg}P_0^{(i)})-\mu(\sigma_i^*)&\text{if }P_0^{(i)}\ne\emptyset,\\ 1+N-\mu(\sigma_i^*)&\text{if }P_0^{(i)}=\emptyset,\end{cases}$$
  by Thm 3.4. In particular $\mathrm{el}\le k(N+1)$ from empty data.
* This is tight, by independent chains. ∎

**Theorem 3.7 (untagged unions of k schemas) [proved].** Let $H_k=\{\bigcup_{l\le k}\mathrm{inst}(\tau_l)\}$, with steps of size $\le N$.
* **(i) Lower bound.** Let $\Sigma$ contain a $k$-ary $p$, a unary $g$ and a constant $c$, and let $n+1=\lfloor(N-1)/k\rfloor$. There is an honest sequence for the *single-rule* target $R^*=\mathrm{inst}(p(x_1,\dots,x_k))\in H_1\subseteq H_k$ that forces $(n+1)^k$ escalations. So
  $$\mathrm{Esc}(H_k;N)\ge\lfloor (N-1)/k\rfloor^k,\qquad\text{while}\qquad\mathrm{Esc}(H_1;N)\le N+1.$$
* **(ii) Upper bound.** For $k\ge2$, $\mathrm{Esc}(H_k;N)\le(k^{N+1}-1)/(k-1)$.
* **(iii) Flat case, $\Theta(n^k)$ for linear schemas.** Let the steps be $\{a,b\}^n$ with $n\ge k$, encoded as $f(c_1,\dots,c_n)$, and let $H$ be unions of $k$ linear flat schemas (subcubes). Then
  $$\sum_{w=0}^k\binom nw\le\mathrm{Esc}\le 1+(2^k-1)\binom nk.$$
  With repeated metavariables allowed, $\mathrm{Esc}\le1+(2^{2k}-1)\binom n{2k}$ for $n\ge2k$. The class is then larger, so the linear lower bound still applies, and $\mathrm{Esc}$ lies between $\Omega(n^k)$ and $O(n^{2k})$. Only the linear case is pinned to $\Theta(n^k)$.

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

**Conjecture 3.8 (binomial bound) [conjecture].** Let $C$ be closed under intersections, with height $h$: the longest chain from $\mathrm{cl}(\emptyset)$ to the universe, the universe included. Then the elasticity of $k$-unions of $C$ (unions of $1$ to $k$ members) is at most $\binom{h+k-1}{k}$.

Status (evidence corrected after verification):
* It is exact for $k=1$ (chains) and for $h=2$ (singletons give $k+1$).
* **If true, it is tight at $k=2$ for every height tested.** The flats of the graphic matroid $M(K_{h+1})$ form an intersection-closed family of height $h$, and their 2-union elasticity is exactly $\binom{h+1}2$: the values are $3,6,10,15$ for $h=2,3,4,5$ [computed: `T1-code/graphic.py`]. For $k=3$, $K_4$ and $K_5$ give only $6$ and $10$, below $\binom{h+2}3=10,20$. Here the edge count caps the elasticity.
* **The case $(k,h)=(2,3)$ is proved** [proved during verification]. Points of $\mathrm{cl}(\emptyset)$ never escape, so assume WLOG $\mathrm{cl}(\emptyset)=\emptyset$. Call members of rank 1 *atoms* and members of rank 2 *planes*. Every member other than the universe has rank $\le2$.
  * Any member $Y\not\ni s$ meets a plane $X\ni s$ in a member of rank $\le1$, i.e. in $\emptyset$ or an atom.
  * *At most one sequence element per atom.* If $s_i,s_j\in A$ with $i<j$, any member containing $s_i$ but not $s_j$ meets $A$ in a nonempty proper sub-member of the atom $A$, which is impossible.
  * *At most three sequence elements per plane.* The two witness members of the last element in a plane $X$ meet $X$ in at most two atoms, so they cover at most two earlier elements of $X$.
  * Now suppose $s_1..s_7$ is elastic. The witness of $s_7$ is two members of rank $\le2$ covering six elements, so they are planes $X,Y$, each holding exactly three of $s_1..s_6$, disjointly. Say $s_6\in Y$.
  * The witness of $s_6$ must cover the three $X$-elements. A member $\ne X$ covers at most one of them, so one witness member is $X$ itself, since a member $\supsetneq X$ would be the universe. $X$ contains none of the two $Y$-elements among $s_1..s_5$. So the other witness member must cover both of them, but it meets $Y$ in at most an atom. This is a contradiction. Hence the elasticity is $\le6=\binom42$.
* *Search.* Randomized hill-climbing with $k=2$ (`icclimb.py`) found maxima $6$ and $10$ at $h\le3,4$, on universes of $9$ and $12$ points. These equal the conjectured values. The $h\le5$ run used a universe of only **14 points**, and the elasticity is at most the number of points. So its maximum of 14 is a ceiling artifact. It is neither evidence of slack below 15 nor a test of the conjecture, since a counterexample needs $\ge16$ points. An independent search during verification, on 11–12 points with $h\le4$, found no counterexample.
* For schemas, $h\le N+1$, so the conjecture gives $\mathrm{Esc}(H_k;N)\le\binom{N+k}{k}$. This would match (i) up to $e^{O(k)}$, so the truth would be $\Theta_k(N^k)$.

*Withdrawn after verification.* An earlier version said that "a natural one-step decomposition proof (split off the members containing $s_1$) fails on some extremal sequences [computed]". No script for this survives (`T1-code/` has none), so the claim and its tag are withdrawn.

**Theorem 3.9 (unstructured classes) [proved; KWIK enumeration bound, Li, Littman & Walsh 2008].** For finite $H$, $\mathrm{Esc}(H)\le|H|-1$: each escalation of an honest step outside $\bigcap\mathrm{VS}$ removes $\ge1$ hypothesis, and $R^*$ is never removed. The class $\{U\setminus\{u\}:u\in U\}$ attains $|U|-1$, by querying $U\setminus\{u^*\}$ in any order. A class of $2^L$ hypotheses described by $L$ bits can therefore need $2^L-1$ escalations. Single schemas of size $\le N$ already number $2^{\Omega(N)}$, yet need $\le N+1$.

---

## 4. Bayesian-conservative verification

Setup:
* $H$ is countable with prior $w$, and $w^*:=w(R^*)>0$.
* Each $R$ carries a model: a distribution $p_R$ on $S$ for human data (errors may be included), and an oracle kernel $\ell_R(y\mid q)$ (deterministic: $\mathbf 1[y=\mathbf 1[q\in R]]$).
* The truth is well-specified: human data are i.i.d. $p_{R^*}$, and oracle answers follow $\ell_{R^*}(\cdot\mid q_t)$ given the past. For Thm 4.2(a), "the past" must include **everything the prover knows** when it chooses its next action. So the prover cannot foresee future human data or oracle noise, and the noise is fresh at every query, not persistent across repeated queries (made explicit after verification).
* After the observations of rounds $\le t$, the likelihood is $L_t(R)$, the posterior is $w_t(R)\propto w(R)L_t(R)$, and
  $$Z_t:=\sum_Rw(R)\,L_t(R)/L_t(R^*),\qquad\text{so that}\qquad w_t(R^*)=w^*/Z_t.$$
* **Verifier $V_\delta$:** ACC iff $w_t(\{R:q\notin R\})<\delta$; optionally REJ iff $w_t(\{R:q\in R\})<\delta_r$; ESC otherwise.

**Theorem 4.1 (version-space posterior: deterministic soundness) [proved].** Let $w_t^{\rm VS}(R)\propto w(R)\mathbf 1[R\text{ consistent with all data}]$, and suppose all data are truthful (human positives $\subseteq R^*$ and all oracle labels). If $\delta\le w^*$, then $V_\delta$ never accepts an invalid step, for any prover and at any time. The guarantee is per target: it covers every $R^*$ with $w(R^*)\ge\delta$.

Conversely, for every $\delta>w^*$ there is a two-hypothesis class on which $V_\delta$ accepts an invalid step at time 0.

*Proof.*
* $w_t^{\rm VS}(R^*)=w^*/w(\mathrm{VS}_t)\ge w^*$. For invalid $q$, $w_t(q\notin R)\ge w_t(R^*)\ge w^*\ge\delta$, so $q$ is not accepted.
* For the converse, take $H=\{R^*,R'\}$ with $R'\supsetneq R^*$, $w(R^*)=w^*$, and $q\in R'\setminus R^*$. Then $w_0(q\notin R)=w^*<\delta$, so $q$ is accepted. ∎

(L2 Thm 1 is the same.)

**Theorem 4.2 (Ville: time-uniform soundness against adaptive provers) [proved; (a) is the prior–posterior-ratio martingale argument of Waudby-Smith & Ramdas 2020] (hypothesis of (a) made explicit after verification).** Assume the model is well-specified and $\delta\le w^*\delta'$.
* (a) Assume moreover the following. Conditional on $\mathcal F_t$, the next observation has the model law: a fresh $X\sim p_{R^*}$, or an answer $\sim\ell_{R^*}(\cdot\mid q_{t+1})$. Here $\mathcal F_t$ contains the history and **all of the prover's information**, including its internal randomness. That is, the prover cannot foresee the data or the noise, and the noise is fresh. Then for every such prover, $\Pr[\exists t,\ V_\delta\text{ accepts some }q_t\notin R^*]\le\delta'$.
* (b) With a deterministic oracle the guarantee is **uniform**: there is an event of probability $\ge1-\delta'$, depending only on the human data, on which no prover strategy ever gets an invalid step accepted. Here the prover may know everything, including all future human data. Only the human data need to be i.i.d. $p_{R^*}$.

*Without the hypothesis of (a), (a) fails completely.* Take $H=2^{\{0,1\}}$ with uniform prior, $R^*=\{0\}$, symmetric flip noise $\eta$, and $\delta'=0.05$. A prover that queries the invalid step 1 only in rounds where it knows the answer will be flipped to "valid", and the valid step 0 otherwise, only ever raises the posterior of $\{0,1\}$ relative to $\{0\}$. It gets 1 accepted with probability $1.0$ at $\eta=0.1$ and at $\eta=0.3$ [computed during verification: `T1-code/prescient.py`]. A prover that cannot foresee the noise respects the bound.

*Proof.*
* Let $\mathcal F_t$ be as in (a): everything up to round $t$, including all of the prover's information and its choice of what happens in round $t+1$. Given $\mathcal F_t$, the observation $O_{t+1}$ is either a fresh $X\sim p_{R^*}$ or an answer $\sim\ell_{R^*}(\cdot\mid q_{t+1})$ with $q_{t+1}$ $\mathcal F_t$-measurable. In either case, for every $R$,
  $$\mathbb E\Big[\tfrac{\ell_R(O_{t+1})}{\ell_{R^*}(O_{t+1})}\Big|\mathcal F_t\Big]=\sum_{o:\ell_{R^*}(o)>0}\ell_R(o)\le1.$$
* By Tonelli (nonnegative terms), $\mathbb E[Z_{t+1}\mid\mathcal F_t]\le Z_t$, and $Z_0=\sum_Rw(R)=1$. Note that $L_t(R^*)>0$ a.s.
* Ville's inequality (Ville 1939) gives $\Pr[\sup_tZ_t\ge1/\delta']\le\delta'$.
* Off this event, $w_t(R^*)>w^*\delta'\ge\delta$ for all $t$. Any invalid $q$ has $w_t(q\notin R)\ge w_t(R^*)>\delta$, so it is never accepted. This proves (a).
* For (b), deterministic oracle answers multiply each term by $\mathbf 1[R\text{ agrees with }R^*\text{ on }q]\le1$. So $Z_t\le Z^H_{n(t)}:=\sum_Rw(R)\prod_{j\le n(t)}p_R(X_j)/p_{R^*}(X_j)$ pathwise, and $Z^H$ is computed from the human data alone. Apply Ville to $Z^H$ in the human data's own filtration. ∎

The key phenomenon is that **there is no union bound over queries**. The prover may try $10^{100}$ steps, and one event of probability $\ge1-\delta'$ covers all of them. This is because invalid acceptance requires one global event: the posterior of the truth falling below $\delta$. A per-step scorer, such as a regressor trained to output $P(\text{valid})$, has no such single latent event, and Thm 2.1 shows its per-step errors can be found one at a time.

*Credit (revised after verification).* (a) is the prior–posterior-ratio (PPR) martingale of Waudby-Smith & Ramdas (2020) applied to validity relations, and L2 Thm 2 states it. (b) is an easy corollary of the observation that truthful constraints multiply $Z$ by at most 1. L2 Thm 1 already uses that observation for constraints the prover generates itself. The tightness below (Prop 4.3) is the addition here.

**Proposition 4.3 (the constant 1 is tight) [proved; computed].**
* Take $R^*=\{a,b\}$ with $p_{R^*}(a)=1-u$, $p_{R^*}(b)=u$, and $R'=\{a,c\}$ with $p_{R'}(a)=1$, where $c$ is invalid.
* The likelihood ratio after $t$ copies of $a$ is $(1-u)^{-t}$, and $R'$ dies at the first $b$.
* $V_{w^*\delta'}$ accepts $c$ iff the ratio exceeds $\theta:=(1-w^*\delta')/((1-w^*)\delta')$. Let $t^*$ be the least $t$ with $(1-u)^{-t}>\theta$.
* The prover waits for $t^*$ human data rounds and queries $c$ exactly then. If it queries $c$ earlier, $c$ is escalated, and the deterministic answer "invalid" kills $R'$.
* The probability of acceptance is $(1-u)^{t^*}\in\big[(1-u)/\theta,\,1/\theta\big)$, and $1/\theta=(1-w^*)\delta'/(1-w^*\delta')\le\delta'$.
* As $u,w^*\to0$, this tends to $\delta'$. The exact values are $0.989\,\delta'$ at $u=0.05,\ w^*=\delta'=0.01$, and $0.991\,\delta'$ at $u=0.01$, $w^*=10^{-3}$, $\delta'=0.05$.

**Theorem 4.4 (escalation bound) [proved].** With a deterministic oracle and thresholds $\delta,\delta_r$, let $\delta_m=\min(\delta,\delta_r)$, or $\delta_m=\delta$ for honest provers.
* With probability $\ge1-\delta''$, simultaneously for all $t$: $\#\mathrm{ESC}_t\le\big(\ln(1/w^*)+\ln(1/\delta'')\big)/\delta_m$.
* For the VS posterior, deterministically: $\#\mathrm{ESC}_t\le\ln(1/w^*)/\delta_m$.

*Proof.* $Z$ evolves multiplicatively.
* A human datum multiplies it by $F_u=\sum_Rw_{u-1}(R)\,p_R(X_u)/p_{R^*}(X_u)$, with $\mathbb E[F_u\mid\mathcal F_{u-1}]\le1$.
* An escalation of a valid $q$ happened because $w_{u-1}(q\notin R)\ge\delta$. The answer multiplies $Z$ by $1-w_{u-1}(q\notin R)\le1-\delta$. For an invalid $q$ the factor is likewise $\le1-\delta_r$.
* Let $M_t:=\prod_{\text{data rounds}}F_u$, a nonnegative supermartingale with $M_0=1$. Then $w^*\le Z_t\le M_t(1-\delta_m)^{\#\mathrm{ESC}_t}$, and Ville bounds $\sup M$.
* For the VS posterior, $F_u=w_{u-1}(X_u\in R)\le1$. ∎

Against dishonest provers the bound needs a reject option with $\delta_r>0$. Without REJ, $\delta_m=0$ and the bound is vacuous: escalating an invalid query that almost all of the posterior already excludes multiplies $Z$ by nearly 1, so it makes no progress.

**Corollary 4.5 (essentially tight for unstructured classes) [proved].** On $\{U\setminus\{u\}\}$ with the uniform prior ($w^*=1/|U|$), any $\delta'$-sound verifier has worst-case honest cost $\ge(1-\delta')(1/w^*-1)$, by Thm 3.2 with Thm 3.9's chain. Meanwhile $V_{w^*\delta'}$ pays $\le\ln(1/w^*)/(w^*\delta')$. So the Bayes rule is optimal up to the factor $\ln(1/w^*)/\big(\delta'(1-\delta')(1-w^*)\big)=O(\ln(1/w^*)/\delta')$, for $w^*,\delta'\le1/2$. With a description-length prior $w^*=2^{-L}$ the cost is $\tilde\Theta(2^L)$ (cf. L2 Thm 4). (Ratio stated exactly after verification.)

The $1/\delta'$ is an artifact of the threshold. On this class with the uniform prior, the VS posterior with $\delta=w^*$ accepts exactly $\bigcap\mathrm{VS}$, because every consistent hypothesis has posterior $\ge w^*$. So it *is* the VS verifier: 0-sound, with cost $\le|U|-1$ (Thm 3.9), which is exactly optimal.

**Corollary 4.6 (structure + Bayes) [proved] (wording revised after verification).** The VS-posterior verifier with threshold $\delta$ never accepts an invalid step, for any prover and any target with $w(R^*)\ge\delta$ (Thm 4.1). This is not "0-sound" in the sense of Def 1.2 unless every target has prior $\ge\delta$, which fails for infinite $H$. Its escalations on valid queries are at most
$$\min\{\mathrm{el}(H,R^*\mid P_0),\ \ln(1/w^*)/\delta\}.$$
*Proof.* An escalated valid $q$ had $w(q\notin R)\ge\delta>0$. So $q\notin\bigcap\mathrm{VS}(P,N)$, and since negatives only shrink VS, $\bigcap\mathrm{VS}(P,N)\supseteq\bigcap\mathrm{VS}(P)$. Here $P$ is $P_0$ plus the earlier escalated valid queries. So the escalated valid queries form an elastic chain. The second term is Thm 4.4 (VS case, honest prover). ∎

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
* For finite $P$: $\bigcap\mathrm{VS}(P)=R^*$ iff $P$ contains an anchor. ("For finite $P$" added after verification. For infinite $P$ the "only if" fails: in Prop 5.2's class, $\bigcap\mathrm{VS}(2\mathbb N)=2\mathbb N$, but there is no anchor.)
* On a text ($P_t\uparrow R^*$), or under i.i.d. sampling with $\mathrm{supp}\,D=R^*$ (a.s.), the verifier is eventually exactly $R^*$ iff $R^*$ has an anchor.

*Proof.*
* If $T\subseteq P$, every consistent $R$ contains $R^*$, so $\bigcap\mathrm{VS}\supseteq R^*$; and $\subseteq$ holds by realizability.
* If $\bigcap\mathrm{VS}(P)=R^*$, then $P$ itself is an anchor.
* A text eventually contains any given finite $T\subseteq R^*$. ∎

**Proposition 5.2 (anchors vs. tell-tales) [proved].**
* An anchor is an Angluin tell-tale: no $R$ satisfies $T\subseteq R\subsetneq R^*$.
* **(Revised after verification.)** Let $H\cup\{\emptyset\}$ be intersection-closed. Then every **nonempty** tell-tale is an anchor. If $\emptyset\ne T\subseteq R\not\supseteq R^*$, then $R\cap R^*\supseteq T$ is nonempty, hence a member, with $T\subseteq R\cap R^*\subsetneq R^*$.
  * The empty tell-tale need not be an anchor. For $H=\{\{1\},\{2\}\}$ and $R^*=\{1\}$, $\emptyset$ is a tell-tale but $\{2\}\supseteq\emptyset$ does not contain $R^*$.
  * As existence conditions the two coincide, for $R^*\ne\emptyset$: if $T$ is a tell-tale, so is $T\cup\{r\}$ for any $r\in R^*$.
* In general the converse fails. Take $R^*=2\mathbb N$ and $R_n=\{0,2,..,2n\}\cup\{2n+1\}$.
  * The class is identifiable in the limit (tell-tales $\{0\}$ and $R_n$).
  * Every finite $T\subseteq R^*$ lies in some $R_n\not\supseteq R^*$, so $R^*$ has no anchor and the verifier never becomes complete.

*Moral.* Identification in the limit (a guess that converges) is weaker than certified verification (all consistent hypotheses agree). A learner that guesses $R^*$ would be unsound if the truth were a large $R_n$. Anchors are the ⊆-tell-tales of strong-monotonic learning (Lange & Zeugmann 1992; see L1 §2.3, where the exact form of their characterization is flagged as recalled from memory). So the anchor condition itself is theirs, in non-effective form. Only its reading as the completeness condition for *certified verification* is new here.

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
* A union bound gives $c_i(1-\rho_i)^n$. For $n=0$ this is $c_i\ge2$, a valid bound. Then $\mathbb E(1-\rho)^{N_i}=(1-\pi_i\rho)^N\le e^{-N\pi_i\rho}$.
* For a ground rule ($v_i=0$, so $c_i=0$), the only failure is $N_i=0$, which has probability $(1-\pi_i)^N\le e^{-N\pi_i}$. This is the separate term in the statement. ∎

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
* Apply the ε-net theorem (Haussler & Welzl 1987; Blumer, Ehrenfeucht, Haussler & Warmuth 1989) with $\varepsilon=\zeta_i$. Since $\zeta_i$ is an infimum that may be attained, this uses the "mass $\ge\varepsilon$" form of the theorem. The symmetrization proof gives that form with the same constants. Alternatively, use $\varepsilon=\zeta_i/2$ at a constant-factor cost. ∎

*Remark (revised after verification).*
* $\zeta_i>0$ requires $k$ to be smaller than the variety of instantiations. When this fails, the *sufficient* condition (a) fails, but identification need not fail.
* **A sufficient condition for failure.** Suppose some rule $i$'s samples can be covered by $k-k'+1$ failure sets, i.e. by the corresponding specializations of $\sigma_i$: $x\mapsto f(\bar z)$, or $y:=x$. Suppose also that some instance of $\sigma_i$ lies outside these specializations and outside the other $k'-1$ rules. Then the other rules plus these specializations form a member of $H_k$ that is consistent with the data and misses that instance, so $\bigcap\mathrm{VS}\ne R^*$.
  * For $k'=1$ this recovers the original remark. If a metavariable is only ever instantiated with $\le k$ root symbols, $k$ specialized rules explain the data, and identification fails for as long as this persists.
* **For $k'\ge2$, $\le k$ roots does not block identification.** Take $k=k'=2$, $R^*=\mathrm{inst}\,p(x)\cup\mathrm{inst}\,q(y)$ and $P=\{p(a),p(b),q(a),q(b)\}$. Here $x$ takes only $2=k$ roots, so $\zeta_1=0$. Yet every 2-union covering $P$ either has one schema covering both $p$-terms, and hence $\succeq p(x)$, or has a schema covering a $p$-term and a $q$-term, and hence is a bare variable. The same holds for the $q$-terms. So $\bigcap\mathrm{VS}_{H_2}(P)=R^*$ [proved; also computed: `T1-code/union_remark.py`].
* "Allow up to $k$ rules" is therefore a real assumption about data diversity, and it is the positive-data face of Thm 3.7(i). For $k'\ge2$ the exact diversity threshold is not determined here. A cover by $k-k'+1$ failure sets blocks identification, given the instance condition above. No cover by $k$ failure sets guarantees identification, by (a). The cases in between are open.

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

**Theorem 6.2 (trimmed version space) [proved] (part (b) revised after verification).** Let $\mathrm{VS}_e(P)=\{R\in H:|P\setminus R|\le e\}$, counted with multiplicity. For tagged classes with **per-tag budgets** let
$$\mathrm{VS}_{(e_i)}(P)=\{R\in H:\ |P^{(i)}\setminus R^{(i)}|\le e_i\ \text{for every }i\},$$
where $P^{(i)}$ and $R^{(i)}$ are the tag-$i$ parts. The verifier accepts $\bigcap\mathrm{VS}_e$, respectively $\bigcap\mathrm{VS}_{(e_i)}$.
* (a) For any $H$: if $P$ contains $\le e$ invalid steps, the $\mathrm{VS}_e$ verifier is sound (uniformly over provers). Likewise the $\mathrm{VS}_{(e_i)}$ verifier is sound if, for every $i$, at most $e_i$ invalid steps are tagged $i$.
* (b) For tagged schemas and the per-tag verifier $\bigcap\mathrm{VS}_{(e_i)}$, suppose for each $i$:
  * (i) $\le e_i$ invalid steps are tagged $i$;
  * (ii) the valid rule-$i$ samples are **$e_i$-robustly generic**. There are more than $e_i$ of them. For every $x$ and $f$, more than $e_i$ of them have $\mathrm{root}(\Theta x)\neq f$. For every $x\ne y$, more than $e_i$ of them have $\Theta x\ne\Theta y$. The first clause follows from the second when $v_i\ge1$, and it is the only content of (ii) for ground rules.

  Then the verifier accepts exactly $R^*$.

*Proof.*
* (a) $R^*\in\mathrm{VS}_e$, respectively $R^*\in\mathrm{VS}_{(e_i)}$.
* (b) A hypothesis in $\mathrm{VS}_{(e_i)}$ has a tag-$i$ component $\mathrm{inst}(\tau)$ that covers all but $\le e_i$ of the valid rule-$i$ samples. By (ii), the remaining valid samples are nonempty and still satisfy (R) and (D): for each $f$, at least one remaining sample has root $\ne f$, and likewise for (D). So they are generic, and $\tau\succeq\sigma_i$ by Lemma 1.3. For a ground rule, the remaining samples are copies of $\sigma_i$, so $\tau\succeq\sigma_i$ directly.
* Without the clause "more than $e_i$ valid samples", a ground rule with $\le e_i$ valid samples fails: $\emptyset$ or $\mathrm{inst}(d)$ for $d\ne\sigma_i$ lies in the version space. ∎

*Remark.* Part (b) needs the per-tag budgets. With one global budget $e=\sum_ie_i$, a hypothesis may spend the whole budget on one tag, deleting more than $e_i$ of its valid samples, and (ii) no longer protects that rule's genericity.

The accepted set is $\mathrm{inst}$ of the most general common instance (unification) of the lggs of the $(|P|-e)$-subsets. [computed] With $e=1$ (resp. 2), one (resp. two) mis-tagged errors are removed exactly. With $e=1$ and two errors, the lgg collapses again.

**Theorem 6.3 (i.i.d. noise: witness frequency must beat error frequency) [proved] (ground rules covered after verification).**
* Each datum is a valid rule-$i$ step with probability $\beta_i$ (law $\Lambda_i$), or an invalid step tagged $i$ with probability $\alpha_i$ (arbitrary law).
* Let $\rho_i$ be as in Thm 5.3, with the split $G$ attaining the maximum. For a ground rule ($v_i=0$) set $\rho_i:=1$ and $c_i:=1$.
* Assume the margin $\Delta_i:=(\rho_i\beta_i-\alpha_i)/2>0$, and set $e_i=\lfloor(\alpha_i+\Delta_i)N\rfloor$.

Then the per-tag trimmed verifier $\bigcap\mathrm{VS}_{(e_i)}$ of Thm 6.2(b) satisfies
$$\Pr[\text{trimmed verifier}=R^*]\ \ge\ 1-\sum_i(1+c_i)\,e^{-2N\Delta_i^2}.$$

*Proof.*
* The number of invalid steps tagged $i$ is $\mathrm{Bin}(N,\alpha_i)$, so by Hoeffding $\Pr[>e_i]\le e^{-2N\Delta_i^2}$.
* For robust genericity when $v_i\ge1$, it suffices that $\#\{\mathrm{root}\in G\}$, $\#\{\mathrm{root}\notin G\}$ and $\#\{\Theta x\ne\Theta y\}$ all exceed $e_i$, counted over valid rule-$i$ samples. Every $f$ lies on one side of the split, and the other side's count is $\le\#\{\mathrm{root}\neq f\}$. These events also give more than $e_i$ valid samples.
* For a ground rule, the single event needed is that the number of valid rule-$i$ samples exceeds $e_i$. That count is $\mathrm{Bin}(N,\beta_i)$, and $\beta_i=\rho_i\beta_i$ because $\rho_i=1$.
* Each of these counts is $\mathrm{Bin}(N,\ge\rho_i\beta_i)$, with mean $\ge(\alpha_i+2\Delta_i)N$. Hoeffding again, and a union bound over the $c_i$ events. ∎

**Theorem 6.4 (indistinguishability: the frequency threshold is necessary) [proved; in the spirit of Kearns & Li 1993].**
* Call a positive-data verifier **$(\delta,\alpha)$-robustly sound** for $H$ if, for every $R^*\in H$ and every data law $D$ with $D(S\setminus R^*)\le\alpha$, $\Pr[\exists t:\mathrm{Acc}_t\not\subseteq R^*]\le\delta$.
* Let $R^*\subsetneq R'$ both lie in $H$, and let $D$ be any law on $R'$ with $D(R'\setminus R^*)\le\alpha$.

Then under $D$, every fixed $q\in R'\setminus R^*$ is accepted with probability $\le\delta$ at every time. So the verifier is **not complete** for $R'$ under the clean law $D$.

*Proof.* $D$ is an admissible noisy law for target $R^*$, and the data distribution is the same in both scenarios. ∎

*Consequences for schemas.*
* For tagged schemas, apply Thm 6.4 to $\sigma'$ and each maximal proper specialization $\sigma''$: $x\mapsto f(\bar z)$, or $x:=y$. Completeness under noise rate $\alpha$ requires every witness frequency, measured as a fraction of *all* data, to exceed $\alpha$. That is, $\beta_i\Pr_{\Lambda_i}[\mathrm{root}(\Theta x)\ne f]>\alpha$ and $\beta_i\Pr_{\Lambda_i}[\Theta x\ne\Theta y]>\alpha$. With per-tag noise, $\alpha$ here may be read as $\alpha_i$, since the alternative law places its "noise" on tag $i$ only. (The factor $\beta_i$ was added after verification.)
* Write $F_x$ for the root law of $\Theta x$ and $m:=\max_fF_x(f)$. Then $\rho_x\le1-m\le2\rho_x$ [proved, constant sharpened from 3 after verification].
  * The side of any split that avoids the most likely root has mass $\le1-m$.
  * If $m\ge\frac12$, the split $\{f_{\max}\}$ gives $\rho_x\ge1-m$.
  * If $m<\frac12$, add roots to $G$ one at a time until $F_x(G)\ge\frac{1-m}2$. The final mass is $<\frac{1-m}2+m=\frac{1+m}2$, so both sides have mass $\ge\frac{1-m}2$.
  * The constant 2 is tight: the uniform law on an odd number of roots gives $(1-m)/\rho_x=2$.
  
  So Thm 6.3 matches this necessity up to a factor of 2 plus margins.
* **There is an unavoidable trade-off.** A positive-data verifier that tolerates error rate $\alpha$ must refuse every rule-generality supported by less than $\alpha$ of the data. With human error rates around 1%, rules used in less than about 1% of steps need negative information.

**Corollary 6.5 (systematic errors are rules) [proved].** Let $H$ be closed under adding a schema (tagged multi-schema rules, or untagged unions with unbounded $k$). Let human errors be **schema-generated**: $D_{\rm err}$ is supported on $\mathrm{inst}(\tau)$ with $\mathrm{inst}(\tau)\not\subseteq R^*$. Then the human data law is a *clean* law for $R^*\cup\mathrm{inst}(\tau)\in H$, at every error rate.

So no positive-data method, with any amount of data, can both tolerate such errors and learn genuine rules of the same frequency. This also defeats the Bayesian guarantee: a model that treats errors as sporadic is misspecified, and its posterior moves to "rule + fallacy".

The line between *sporadic* and *systematic* errors is therefore exact:
* errors removable by positive data are those rarer than the witness frequencies of the genuine rules;
* "rule-like" errors at any rate need **negative information**: escalation, coherence, or world feedback.

**Proposition 6.6 (in CPC, coherence refutes every systematic error in pure schemas) [proved; cf. T2 Thm 3.1] (scope revised after verification).** In classical propositional logic, let $A=R^*_{\rm CPC}\cup A_1$ with $A_1$ closed under uniform substitution, for example the instance set of a family of **pure** schemas. Then $A$ is sound iff $\bot\notin\mathrm{Cl}_A(\emptyset)$, by Prop 2.3 plus ex falso. For learned schemas that mention specific atoms, apply the test to their purifications. By the scope remark after Prop 2.3, $A$ is sound iff $\bot\notin\mathrm{Cl}_{A^\circ}(\emptyset)$.

For example, the fallacy "affirming the consequent" yields $\bot$ from $\bot\to\top$ and $\top$. So a coherence test *in the empty (or actual) context*, rather than in hypothetical contexts where deriving $\bot$ is legitimate reductio, catches every unsound learned *pure* schema. After purification it catches every unsound learned schema. The test also returns a **negative bag**: the derivation of $\bot$, at least one of whose steps is invalid. This is the hand-off to T2.

*Limits (added after verification).*
* Run directly on schemas that mention atoms, the test can miss errors. For example, $\mathsf{s1}(\mathsf{or}(x,p_1),x)$, "from $x\vee p_1$ infer $x$", added to a complete CPC calculus never yields $\bot$ from $\emptyset$, since every derivable formula is true whenever $p_1$ is false (Prop 2.3, scope remark).
* Purification costs nothing in soundness, because in CPC $\tau$ is sound iff $\tau^\circ$ is. But it enlarges the accepted set. Relative to a human calculus $R^*$ smaller than all classically valid steps, it may accept valid steps outside $R^*$.

In arithmetic the analogue fails, and in a specific way (remark corrected after verification).
* False $\Pi_1$ additions are already caught by coherence over PA. If $\pi$ is a false $\Pi_1$ sentence, then $\neg\pi$ is a true $\Sigma_1$ sentence, so $\mathrm{PA}\vdash\neg\pi$ by $\Sigma_1$-completeness, and $\mathrm{PA}+\pi\vdash\bot$ (T2 Thm 3.10(a)). Computation (Δ₀ world feedback) adds nothing here (T2 Lemma 3.7).
* The residual failures are false $\Sigma_1$ (and higher) additions such as $\neg\mathrm{Con}(\mathrm{PA})$. They are consistent with PA, so coherence does not refute them, and no finite computation refutes a false $\Sigma_1$ sentence either.
* What handles them is *caution*: accept a $\Sigma_1$ claim only with a witness (T2 Thm 3.10(c)). Otherwise one must accept stronger principles, such as $\mathrm{Con}(\mathrm{PA})$ or reflection. Beyond $\Delta_2$ no computable learner suffices (T2 Thm 3.10(e)).

---

## 7. Computational checks (`T1-code/`)

| check | result |
|---|---|
| single schema chains, exhaustive, $N\le4$ | max $=N+1$ with two constants and $N$ with one; matches Thm 3.4 |
| 2-unions of deep schemas, $\{c,g,p\}$, $N=3,4,5$ | $4,8,13$ (vs. $N+1$ for one schema) |
| 2-unions, $\{a,b,g,p\}$, $N=3,4$ | $8,13$; 3-unions at $N=3$: $10$ (whole universe) |
| subcubes, $k=2$, $n=2,3,4$ | $4,7,11=\sum_{w\le2}\binom nw$ (lower bound in Thm 3.7(iii) exact) |
| partition abstraction, $k=2$, $d=3,4$ | $7,15=2^d-1$ (Ramsey recursion tight for the abstraction) |
| intersection-closed families, hill-climbing, $k=2$, $h\le3,4,5$ on 9, 12, 14 points | $6,10,14$; no counterexample. The $h\le5$ value 14 equals the universe size, a ceiling artifact rather than evidence (corrected after verification) |
| graphic-matroid flats $M(K_{h+1})$, $k=2$, $h=2..5$ (`graphic.py`, added after verification) | $3,6,10,15=\binom{h+1}2$: Conj 3.8 is tight at $k=2$ if true |
| untagged 2-unions, $R^*=p(x)\cup q(y)$, $P=\{p(a),p(b),q(a),q(b)\}$ (`union_remark.py`, added after verification) | $\bigcap\mathrm{VS}_{H_2}(P)=R^*$ although $\zeta_1=0$ (Remark after Thm 5.4) |
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
  * Ville's inequality and test martingales (Shafer, Shen, Vereshchagin & Vovk 2011);
  * Thm 4.2(a), which is the prior–posterior-ratio martingale of Waudby-Smith & Ramdas (2020), as L2 notes. Thm 4.2(b) is an easy corollary, since truthful constraints multiply $Z$ by at most 1 (cf. L2 Thm 1);
  * the anchor condition, which is the Lange–Zeugmann condition for strong-monotonic learning (credit revised after verification).
* *New here, as far as I know:*
  * the exact single-schema budget $1+\mu-\mu^*$;
  * the tagged/untagged separation ($k(N+1)$ vs. $\ge\lfloor(N-1)/k\rfloor^k$);
  * the $\mathrm{Bell}$ lower bound for two-sided checking, over growing signatures;
  * the tightness of the constant in Thm 4.2 (Prop 4.3);
  * the reading of anchors (vs. tell-tales) as the completeness condition for *certified verification*;
  * the witness-event sample complexity and its noise version, with matching necessity up to a factor of 2, which is tight;
  * the exact statement that schema-generated errors are indistinguishable from rules.

  None of these is deep. Their value is that together they pin down when the user's program works.

**Weaknesses.**
1. *Realizability is load-bearing.* If the true calculus is not in $H$ (e.g. two untagged rules, but $H=H_1$), the lgg overgeneralizes and soundness fails. The Bayesian hierarchy repairs this only probabilistically, at exponential escalation cost in the complexity of what is missing.
2. Soundness is relative to the *human* calculus. The rules learned are exactly as good as humans' rules (including naive comprehension, if humans use it).
3. The first-order-term model of steps idealizes away AC contexts, binders and variable-arity rules (see the remarks after Cor 5.5).
4. Untagged unions: the gap between the polynomial lower bound and the exponential upper bound is open (Conj 3.8). The conjecture is proved only for $(k,h)=(2,3)$, and if true it is tight at $k=2$.
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
* *Before formalization.* Without rule citations, untagged unions cost $\Omega((N/k)^k)$ escalations in the worst case. Identification still holds under diversity ($\zeta_i>0$, which needs a bound $k$ on the number of rules smaller than the instantiation variety). This is a sufficient condition. For a single rule, low variety provably blocks identification. With several rules it need not (Remark after Thm 5.4, revised after verification). This quantifies one way in which "inventing a language with named rules" (the user's note on how math got formalized) makes inference learnable.

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
* Lange, S. & Zeugmann, T. (1992). Types of monotonic language learning and their characterization. COLT, 377–390 (title/venue per L1 ✓; page numbers and the exact form of the characterization unverified).
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
* Waudby-Smith, I. & Ramdas, A. (2020). Confidence sequences for sampling without replacement. NeurIPS (prior–posterior-ratio martingale) ✓ (per L2).
* Wright, K. (1989). Identification of unions of languages drawn from an identifiable class. COLT, 328–333 ✓; corrected by Motoki, Shinohara & Wright (1991), COLT ✓.

---

## Verification log

Two independent adversarial referees checked this file: referee A covered §1–§3, referee B covered §4–§6 and the related novelty claims in §8. The full reports are in `../verification/T1-soundness-under-search-verification.md`. I re-checked every issue by hand. Where computation helped, I re-ran the referee scripts (`graphic.py`, `checks37.py`, `union_remark.py`, `prescient.py`, `rho.py`, `thm31b.py`); all reproduced. Scripts that back claims now made in this file were copied into `T1-code/` and added to `run_all.sh`. Theorem numbering is unchanged, and materially changed items are marked "(revised after verification)".

**Major issues (all genuine, all fixed).**

| # | item | verdict | action |
|---|---|---|---|
| A1 | Thm 3.1(b) | Genuine. Read as a conditional probability at a history, (b) is false for randomized verifiers. An $\varepsilon$-sound "reckless with probability $\varepsilon$" verifier reaches $h=(c,\mathrm{ACC})$ with probability $\varepsilon$ and then accepts $b\notin\bigcap\mathrm{VS}$ with conditional probability 1 (re-run: $\Pr[h]=0.0098$, $\Pr[\mathrm{ACC}\,b\mid h]=1.000$). | **Restated** with $p$ the *joint* probability of "history $h$, then $q$ accepted". Added the deterministic special case and the counterexample. Proof made explicit. The random-data remark now reads $\Pr_{R'}(\text{data})\cdot p\le\delta$. |
| A2 / B18 | Prop 2.3 gloss; Summary; Prop 6.6 coverage claim | Genuine, one root cause. Atoms are constants of $\Sigma$ (§1.3), so learned schemas can mention atoms, and their instance sets are not substitution-closed. Two counterexamples were checked by hand. $(\{x\vee p_0\},x)$ is unsound but only adds $\neg p_0$, since $\mathrm{Cn}(\neg p_0)$ is closed. $\mathsf{s1}(\mathsf{or}(x,p_1),x)$ never yields $\bot$. | Hypothesis restated as $A=R^*_{\rm CPC}\cup A_1$ with $A_1$ substitution-closed, e.g. instance sets of **pure** schemas. Added a scope remark with the counterexamples. Added **purification** (atoms → fresh metavariables) and proved that in CPC $\tau$ is sound iff $\tau^\circ$ is. So coherence on $A^\circ$ decides soundness of $A$. Prop 6.6, its gloss and the Summary were restricted accordingly. *Note for T2:* T2 Thm 3.1 is stated for structural closure operators and is unaffected, but any T2 gloss about *learned* schemas should be checked for atom constants. That is outside T1's scope. |

**Minor issues.**

| # | item | verdict | action |
|---|---|---|---|
| A3 | Cor 2.2 "every output trivializes" | Genuine: fails if $\mathcal L$'s output lacks $\top$I, $\wedge$I, $\vee$I$_2$ (e.g. $\mathcal L\equiv\emptyset$). | $\mathcal L^+$ now also adds $\mathrm{inst}(\top\text{I},\wedge\text{I},\vee\text{I}_2)\subseteq R^*$. These cannot increase the error. Summary now says "same rates up to $O(\varepsilon^{-1}\log\delta^{-1})$ extra samples". |
| A4 | Thm 3.2 lower-bound citation | Genuine: it cited the false conditional form of 3.1(b). | Replaced by a direct coupling argument for a non-adaptive honest prover. Def 1.3 now defines randomized cost as expected cost. |
| A5 | Conj 3.8 evidence | Genuine. The $h\le5$ hill-climb ran on 14 points, so "14 vs 15" is a ceiling artifact. The "[computed]" one-step-decomposition claim has no script (only a 2-line stub survives in scratch). | Evidence corrected. Added that $M(K_{h+1})$ flats attain $\binom{h+1}2$ at $k=2$ for $h=2..5$ (re-run `graphic.py`: 3,6,10,15). Added a full proof of the case $(k,h)=(2,3)$: I checked the referee's sketch step by step and wrote it out. Withdrew the decomposition claim. §7 table, §8 weakness 4 and the Summary updated. |
| A6 | Thm 3.4 displays and "chain = generalization chain" | Genuine (presentational). | Target-dependent quantity written as $\mathrm{el}(H_1,\sigma^*\mid\emptyset;N)$, with $\mathrm{Esc}(H_1;N)\le N+1$ ($=N+1$ with two constants and a unary symbol). Proof now uses the representatives $g_i=\mathrm{lgg}(C_i)$, with inclusion giving strict generality. |
| A7 | Prop 3.5 "super-exponential" | Genuine: it needs a signature that grows with $N$. Over a fixed finite signature the two-sided cost is $\le$ the number of steps, $2^{O(N)}$. | Title, statement and the Bell comparison qualified. The fixed-signature upper bound was added. Re-ran `checks37.py`: Bell$(2..4)=2,5,15$ forced escalations. |
| A8 | Thm 3.6 "intersection-closed" | Genuine: $H^{\rm tag}_k$ is not literally intersection-closed. Conclusion correct. | Justification replaced by the factorization $\mathrm{VS}=\prod_i\mathrm{VS}_i$. The bound is split by whether $P_0^{(i)}=\emptyset$. |
| A9 | Thm 3.7(iii) / Summary "$\Theta(n^k)$ for flat schemas" | Genuine: $\Theta(n^k)$ is proved only for linear flat schemas; $n\ge k$ is needed. | Summary and (iii) qualified: linear $\Theta(n^k)$; repeated metavariables between $\Omega(n^k)$ and $O(n^{2k})$; $n\ge k$ added. |
| B2 | Thm 4.2(a) unstated hypothesis | Genuine. A prover that foresees fresh oracle noise defeats (a) with probability 1 (re-run `prescient.py`: 1.0 at $\eta=0.1,0.3$). | Hypothesis stated explicitly, in §4's setup and in (a): $\mathcal F_t$ includes all of the prover's information, and the noise is fresh and unforeseeable. Noted that (b) needs no such assumption, and included the counterexample. |
| B3 | Thm 4.2 novelty/citation | Genuine: (a) is the PPR martingale of Waudby-Smith & Ramdas (2020), and (b) is an easy corollary. | Credit paragraph and reference added. §8 "new" list corrected. |
| B7 | Cor 4.6 "0-sound" | Genuine: the guarantee only covers targets with $w(R^*)\ge\delta$. | Reworded. Proof made explicit about $P$ and $N$. |
| B9 | Prop 5.2 converse for $T=\emptyset$ | Genuine: $H=\{\{1\},\{2\}\}$, $R^*=\{1\}$. | Converse restricted to nonempty tell-tales. Counterexample and the existence-level equivalence added. Anchors credited to Lange–Zeugmann in §5 and §8, and the reference was added. |
| B11 | Remark after Thm 5.4 "identification fails forever" | Genuine for $k'\ge2$. Hand proof for $k=k'=2$, $P=\{p(a),p(b),q(a),q(b)\}$: every covering 2-union contains $p(x)\cup q(y)$. Re-ran `union_remark.py`. | Remark rewritten. A proved sufficient condition for failure ($k-k'+1$ failure sets plus an uncovered instance) recovers the original for $k'=1$. The $k'\ge2$ counterexample was added. The intermediate cases are open. §8 softened. |
| B14 | Thm 6.2(b): ground rules; per-tag vs global budget | Genuine: a ground rule with $\le e_i$ valid samples fails, and (b) needs per-tag budgets. | $\mathrm{VS}_{(e_i)}$ is defined explicitly, and (ii) now requires $>e_i$ valid samples. A remark explains why a global budget fails. |
| B15 | Thm 6.3 ground rules | Genuine: the missing event "valid count $>e_i$". | For $v_i=0$: $\rho_i:=1$, $c_i:=1$. The verifier is specified as per-tag. |
| B16 | Thm 6.4 consequences: factor 3, missing $\beta_i$ | Genuine: the tight constant is 2 (greedy split; uniform law on an odd number of roots gives exactly 2; re-ran `rho.py`: max 1.974 over 20k random laws). $\beta_i$ factor missing. | Factor 2 proved, with tightness. $\beta_i$ inserted. Summary and §8 updated. |
| B19 | Prop 6.6 arithmetic remark | Genuine. False $\Pi_1$ additions are already caught by coherence over PA (Σ₁-completeness), and $\neg\mathrm{Con}(\mathrm{PA})$ is a false Σ₁ sentence that computation cannot refute. | Rewritten per T2 Thm 3.10(a),(c),(e) and Lemma 3.7. |

**Items reported "ok", with optional nits.**
* *Nits applied:*
  * Lemma 1.1 ("non-derivable" in place of "false").
  * Thm 2.1 ("for non-tautologous $C$"; finitely many schemas only if $R^*$ is).
  * Thm 4.1 ("all data truthful"; per-target guarantee).
  * Prop 4.3 (the prover queries $c$ exactly at $t^*$).
  * Thm 4.4 ($\delta_r=0$ makes the dishonest-prover bound vacuous).
  * Cor 4.5 (exact ratio; with $\delta=w^*$ the VS posterior *is* the VS verifier, which is exactly optimal).
  * Thm 5.1 ("for finite $P$").
  * Thm 5.3 (ground-rule case spelled out in the proof).
  * Thm 5.4(b) (the "$\ge\varepsilon$" form of the ε-net theorem).
* *Also corrected by the author during this pass, not flagged by the referees:* the Upshot bullet "losing rule citations costs a polynomial of degree $k$" now says *at least* degree $k$, with $\Theta_k(N^k)$ only conjectured. Thm 3.7(ii)'s proved upper bound is exponential.
* *No change needed:* Thm 3.1(a), Prop 2.4, Prop 3.3, Lemmas 1.2–1.3, Thm 3.7 main statements, Thm 3.9, Cor 5.5, side-condition extension, Prop 6.1, Cor 6.5.
