# T4. Informal mathematics as latent formalization

*Theory thread T4 of the inferential-learning project. Read `../00-brief.md` and `../01-orchestrator-ideas.md` first. The literature background is in `../lit/L6` (history of informal mathematics and formalization), `../lit/L7` (contexts, supervaluation), `../lit/L8` §9–10 (TC8, bounded-gap validity, Draft-Sketch-Prove) and `../lit/L10` (the user's notes). This thread builds on `T1-soundness-under-search.md` (version-space and Bayesian verifiers, escalation dimension) and `T2-coherence-as-negative-data.md` (negative bags, oligarchic halving). Sanity-check scripts are in `T4-checks/`.*

**Status tags.**
* **[proved]**: a complete proof is given here.
* **[proved, TOSU]**: proved, but "trivial once set up". The content lies in the definitions.
* **[cited]**: a known result, with source. **(unverified)** marks details I could not check this session.
* **[computed]**: verified by exhaustive computation on small cases (script named).
* **[sketch]**, **[conjecture]**: what they say.

---

## 0. Summary

**The question** (success criterion 2 of the brief): could a learner have learned to check, and to produce, valid mathematical proofs *before* anyone knew how to formalize them? The user's own versions: "how come mathematicians ended up with such a nice notion of proof? … this nice structure of a formal proof is sorta there in their activities. how did it come to be there?" (L10 §1.6); and his robust-core hypothesis that pre-formal mathematicians used only the part of their concepts that later survived formalization.

**The model (§1).** A pre-formal practice is the shadow of an unknown **latent formalization** $h^*=(L^*,R^*,\rho^*,\mathbb M^*)$. This consists of:
* a formal language $L^*$;
* a calculus $R^*$ (rule schemas plus a library of definitions and lemmas);
* a partial, context-dependent **reading** $\rho^*$ of informal sentence occurrences into $L^*$;
* an intended semantics $\mathbb M^*$.

A human step is the $\rho^*$-image of an $R^*$-derivation with at most $g$ steps (the **gap**, an operational de Bruijn factor), plus noise. The learner has three feedback channels:
* **(P) practice**: accepted steps (noisy positive data);
* **(C) coherence**: derivations of ⊥ from designated contexts, i.e. paradoxes;
* **(O) objects**: examples and counterexamples, i.e. structures on which informal sentences can be evaluated. *Computation is the special case of evaluating on the intended object, restricted to a decidable fragment.*

**Main results.**

1. **A bounded-gap verifier that is sound against adaptive provers (§2).** The verifier accepts an informal step iff it is $g$-valid under *every* surviving latent formalization $(L,R,\rho,\mathbb M)$, and it checks *links* (re-uses of a sentence across contexts) the same way. This verifier is deterministically sound against every prover whenever the target is in the class (Thm 2.4). With noisy practice data, the Bayesian version is sound with probability $\ge1-\delta'$ at all times (Thm 2.5). Its threshold depends on the prior mass of the target's *equivalence class*, not of the target itself: redundant formalizations of the same meaning help.
   * Checking steps without checking links is unsound. Equivocation is a separate failure mode, and Cauchy's sum theorem is an instance of it (Prop 2.3).
   * Escalation costs are bounded by the elasticity of the induced class of informal step relations (Thm 2.7). With an "expand this step" protocol, the verifier becomes complete once the atomic steps are identified (Prop 2.8).

2. **Identifiability exactly up to informal-validity equivalence (§3).**
   * An *informal completeness lemma* (Lemma 3.3) shows that, for first-order hypotheses whose informal fragment is closed under negation, the informal consequence relation $\models_h$ determines both the admissible object valuations and coherence. This is a precise version of the user's "philosophical completeness theorem".
   * Consequently, closure-level data identify a latent formalization **exactly up to ≈** (same informal consequence relation on the practice's domain), and no finer (Thm 3.4). With bounded-gap data, the conservative verifier converges to exactly $h^*$'s $g$-step relation.
   * Witnesses that the ≈-classes are large: in all three cases the readings differ in ontology but not in informal meaning.
     * Robinson's transfer: whether the intended reals contain infinitesimals is unidentifiable at every gap (Prop 3.5).
     * ε-δ versus internal set theory (Prop 3.6).
     * von Neumann versus Zermelo numerals (Prop 3.7).
   * I argue that ≈ is the inferentialist-correct notion of "same meaning" (§3.4).

3. **Counterexample objects give step-level blame, and that is worth exponentially more than paradoxes (§4).**
   * *Descent along false lines* turns a global counterexample into a refuted step or an equivocating link in at most depth-many evaluations (Lemma 4.1).
   * In the online correction game, object feedback needs at most $\lfloor\log_2|\mathcal H|\rfloor$ corrections, and at most $\log_2(1/w([h^*]))$ with a prior (Thm 4.3).
   * With only paradoxes (negative bags), the worst case is $|\mathcal H|-1$, attained by a **sorites-shaped chain paradox** in which every bag is essential (Thm 4.4).
   * With bags of size $\le r$:
     * the exact value on the single-culprit class is $\min(r,|\mathcal H|-1)$;
     * for every class, a super-majority learner achieves $(r+1)\ln|\mathcal H|$ (Thm 4.5);
     * products of single-culprit blocks need $r\log|\mathcal H|/\log(r+1)$ (Prop 4.6).

     So adversarial multiple-instance feedback costs a factor linear in the number of suspect steps. In the i.i.d. setting the overhead is only logarithmic.

4. **Frege → Russell → Zermelo as a theorem (§5).** I prove an abstract repair theorem (Thm 5.1) and a concrete toy over ten comprehension instances (Thm 5.2), in four stages:
   * Unconstrained MDL picks naive comprehension.
   * Russell's 4-line derivation refutes it.
   * The coherent repairs in the uniform restriction class have exactly three maximal elements: positive, stratified (NF-like) and Zermelo-like. They are pairwise *jointly* incoherent, so there is no "minimal repair".
   * Coverage of practice selects among them. Dedekind–Cantor set operations alone select the *stratified* (NF-like) repair by description length. Adding Cantor's diagonal sets (Zermelo 1908's theorem that no set contains all its subsets) selects the Zermelo-like repair. With Frege's universal extension also in practice, the choice is decided by usage weights.

   At the instance level, naive comprehension has $2^{\aleph_0}$ maximal consistent subsets (Prop 5.4, full proof). Incurvati & Murzi (2017) show that none of them is recursively axiomatizable [cited].

5. **The robust-core theorem (§6).** Model vague pre-formal concepts by admissible sharpenings, and practice's "robust core" by supervaluational validity. Then:
   * Every practice proof is valid in every admissible sharpening. Hence it survives *every* future formalization that is one of those sharpenings, which explains why informal mathematics survived formalization.
   * The conservative learner learns exactly the robust core, and nothing more can be learned soundly (Thm 6.2).
   * Non-robust steps have monsters (Thm 6.3).
   * "Valid in most sharpenings" does *not* chain. The sorites is the tight counterexample to the union bound (Prop 6.4).
   * A selection-plus-completeness argument answers the user's "how did the nice notion of proof come to be there?" (Prop 6.5).

6. **The user's steeper-simplicity-penalty conjecture (§7).** In an additive two-part-code model, a penalty $\lambda=\kappa N$ includes a rule iff its *compression rate* (frequency × per-use saving ÷ description length) exceeds κ. So the proposal separates valid rules from systematic errors iff every fallacy compresses the practice less, per bit, than every valid rule. This fails for a frequent, short fallacy (the freshman's dream) next to a rare, long valid rule. The user's "vertex of the convex hull" conjecture is therefore false in general [proved; computed]. Objects remove such fallacies regardless.

**Depth, honestly (§8).** Most theorems here are TOSU. Their value lies in fixing definitions under which history becomes a theorem.
* The parts with real mathematical content: the exact object-versus-bag separation and its sorites realization; the informal completeness lemma; the comprehension-toy facts; the sorites tightness of the union bound.
* The deep parts are cited: Incurvati–Murzi non-recursiveness; Nelson's conservativity; Robinson's transfer; Gödel completeness.
* **The hardest open problem** is *affordable soundness with language invention*. All positive results assume the target formalization lies in a fixed class. A universal (language-inventing) class restores realizability, but the sound-verification cost is then exponential in the target's description length (T1 Cor 4.5). Real progress needs a class that is rich enough to contain the definitional extensions history actually made (ε-δ, uniform convergence, ideals) and structured enough to have polynomial escalation dimension, or a proof that no such class exists.

---

## 1. The formal model

### 1.1 Informal sentences, contexts, arguments

* $\Xi$ is a countable set of informal sentence *strings*, such as "the series $\sum f_n$ converges".
* $C$ is a set of *contexts*. A context fixes the definitions and conventions in force, the notation, and the local suppositions.
* An **occurrence** is a pair $x=(c,\xi)\in X:=C\times\Xi$. Write $\mathrm{str}(x)=\xi$.
* An **informal step** is $s=(\Gamma\Rightarrow y)$ with $\Gamma\subseteq_{\rm fin}X$ and $y\in X$.
* An **informal argument** α is a finite list of lines $y_1,\dots,y_m\in X$. Each line is one of:
  * a *premise*;
  * an *inference* $\Gamma_j\Rightarrow y_j$, with $\Gamma_j$ among earlier lines;
  * a *link* $y_i\leadsto y_j$ with $i<j$ and $\mathrm{str}(y_i)=\mathrm{str}(y_j)$, meaning "the same claim, used in another context".

  The conclusion is $y_m$. The depth of α is the length of its longest dependency path.

Links are the formal locus of **equivocation**. Practice re-uses a sentence proved in one context in another, and the two occurrences may be read differently.

### 1.2 Latent formalizations

**Definition 1.1.** A **latent formalization** (or hypothesis) is $h=(L_h,R_h,\rho_h,\mathbb M_h)$, where:
* $L_h$ is a countable formal language with a sentence ⊥;
* $R_h$ is a set of formal steps $\Pi\vdash\varphi$ over $\mathrm{Sent}(L_h)$: the instances of finitely many schemas, plus a library of definitions and derived lemmas;
* $\rho_h:X\rightharpoonup\mathrm{Sent}(L_h)$ is a partial **reading**;
* $\mathbb M_h$ is a class of $L_h$-structures (the intended semantics) for which $R_h$ is sound: every step preserves truth in every $M\in\mathbb M_h$.

Further notation and terminology:
* $\mathrm{Cl}_{R}(\Gamma)$ is the closure of Γ under $R$.
* $h$ is **first-order complete** if $L_h$ is first-order, $\mathbb M_h=\mathrm{Mod}(T_h)$ for a theory $T_h$, and $\mathrm{Cl}_{R_h}(\Gamma)=\{\varphi:T_h\cup\Gamma\models\varphi\}$. For example, take a complete Hilbert calculus with axioms $T_h$, plus derived rules.
* The informal step $s=(\Gamma\Rightarrow y)$ is **valid under $h$**, written $s\in{\models_h}$, iff $\Gamma\cup\{y\}\subseteq\mathrm{dom}\,\rho_h$ and $\rho_h(y)\in\mathrm{Cl}_{R_h}(\rho_h\Gamma)$.
* $s$ is **$g$-valid under $h$**, written $s\in\mathrm{St}^g_h$, iff in addition $\rho_h(y)$ has an $R_h$-derivation from $\rho_h\Gamma$ with at most $g$ rule applications and with all formulas of size at most a fixed function of $g$ and the input. The size bound makes $\mathrm{St}^g_h$ decidable. All results use only two facts: $\mathrm{St}^g_h$ is decidable, and $\mathrm{St}^g_h\subseteq{\models_h}$.
* A **link** $y_i\leadsto y_j$ is valid under $h$ iff the one-premise step $(\{y_i\}\Rightarrow y_j)$ is in $\mathrm{St}^g_h$. Typically $\rho_h(y_i)=\rho_h(y_j)$, i.e. zero steps. So links are steps of a special form, and everything said below about steps applies to them.
* The **admissible valuations** of $h$ are $\mathcal V_h:=\{v_M\circ\rho_h:\ M\in\mathbb M_h\}$, where $v_M(\varphi)=[M\models\varphi]$. These are total functions on $\mathrm{dom}\,\rho_h$.

**Why a library and a gap.** De Bruijn observed a roughly constant ratio between formal and informal proof size, and Wiedijk measured an intrinsic factor of about 4. Mathias's $4.5\times10^{12}$-symbol term for Bourbaki's "1" shows that the constant holds only *relative to a definitional library* (L6 §5). So $g$ is measured over $R_h$ including the library.

### 1.3 The data-generating process

**Assumption BG (bounded gap).** There is a target $h^*$ with the following properties.
* (BG1) *Realizability*: $h^*\in\mathcal H$, the learner's hypothesis class.
* (BG2) *Practice*: each accepted human step is, with probability $1-\eta$, drawn from some distribution over $\mathrm{St}^g_{h^*}$. With probability η it is noise, of one of two kinds:
  * sporadic, from an arbitrary distribution;
  * systematic, from the instances of a *fallacy schema* (e.g. $(a+b)^2=a^2+b^2$).
* (BG3) Human links are $h^*$-valid, up to the same noise.

The human data are thus **noisy images of short derivations under an unknown reading**. Larger steps, those $h^*$-valid but not $g$-valid, also occur; the verifier treats them by asking for expansion (Prop 2.8).

### 1.4 The three feedback channels

* **(P) Practice.** The stream of §1.3. Escalation answers ("is this step acceptable?") are also practice data, labelled by $h^*$.
* **(C) Coherence.** There is a family $\mathcal A$ of finite **designated contexts** $A\subseteq X$ that the community asserts, such as accepted background and axioms, with the promise that $\bot\notin\mathrm{Cl}_{R^*}(\rho^*A)$.
  * A **paradox for $h$** is an $R_h$-derivation of ⊥ from $\rho_hA$ for some $A\in\mathcal A$. It refutes $h$.
  * Paradoxes are found by search, so refutation is semi-decidable.
  * Suppositional contexts are *not* designated, so reductio is never penalized (orchestrator idea 1; T2 §1).
* **(O) Objects.** An object datum is a finite partial valuation $v:X\rightharpoonup\{0,1\}$, together with the promise that $v$ is $h^*$-admissible: $v\subseteq u$ for some $u\in\mathcal V_{h^*}$.
  * In the interactive form, the learner holds an object $o$ (a specific function, polyhedron or configuration) and may query $v_o(x)$ for occurrences $x$ of its choice. This is "checking the step on an example" (Weber & Mejía-Ramos 2011, via L6 §3).
  * $h$ is refuted by $v$ iff $v$ extends to no member of $\mathcal V_h$.
  * **Computation** is the special case of a fixed intended object $M_0\in\mathbb M^*$ queried on a decidable fragment $X_{\rm dec}$. Euler's six-decimal value of $\sum1/n^2$ is a datum $v_{M_0}(\text{"}\sum 1/n^2\in[1.64493,1.64494]\text{"})=1$.

Two remarks on what this model leaves out.
* **The community's reading moves.** $\rho^*$ is fixed here. Historically, the readings of "function", "convergent" and "polyhedron" shifted *during* the episodes that L6 tabulates. §6 handles the main consequence by making the pre-formal reading *vague*, i.e. a set of sharpenings, rather than moving.
* **Language invention.** $L$ ranges over a fixed class. The decisive historical steps (quantifier logic, ε-δ, uniform convergence, ideals) were inventions of new $L$ (L6 §4). §8 returns to this as the hardest open problem.

---

## 2. The bounded-gap verifier

### 2.1 Definition and argument-level soundness

Say $h$ is **consistent with the data at time $t$** if all four of the following hold:
* every practice step and escalation answer seen so far is labelled correctly by $h$, using the label $\mathrm{St}^g_h$;
* no paradox for $h$ has been found within the search budget used so far;
* no object datum seen so far has been shown, within the budget, to be $h$-inadmissible;
* every link answer is consistent with $h$.

$\mathrm{VS}_t$ denotes the hypotheses not yet refuted. Because refutation searches are budgeted, $\mathrm{VS}_t$ is computable from the data whenever $\mathcal H$ is a finite or enumerable class with decidable $\mathrm{St}^g_h$. It may contain incoherent hypotheses whose paradox has not yet been found, as Frege's 1903 "way out" was for 52 years (L6 §1).

**Definition 2.1 (verifier $V^g_t$).** On a query $q$, which is an informal step or a link:
* ACC if $q$ is $g$-valid (resp. link-valid) under **every** $h\in\mathrm{VS}_t$, with a certificate (a derivation) for each;
* otherwise ESC: ask the community or oracle, or ask the prover to expand $q$ (Prop 2.8).

A rejection rule (REJ when no survivor accepts) may be added. Soundness never needs it.

**Lemma 2.2 (argument soundness) [proved].** Suppose every inference line of α is valid under $h$, and every link of α is valid under $h$. Then every line $y_j$ satisfies $\rho_h(y_j)\in\mathrm{Cl}_{R_h}(\rho_h(\mathrm{Prem}\,\alpha))$. Hence in every $M\in\mathbb M_h$ in which the premises are true, every line is true.

*Proof.* Induction on $j$.
* Premises are immediate.
* For an inference $\Gamma_j\Rightarrow y_j$: by induction $\rho_h\Gamma_j\subseteq\mathrm{Cl}(\rho_h\mathrm{Prem})$. Validity gives $\rho_h y_j\in\mathrm{Cl}(\rho_h\Gamma_j)$. Monotonicity and idempotence of $\mathrm{Cl}$ then give $\rho_h y_j\in\mathrm{Cl}(\mathrm{Cl}(\rho_h\mathrm{Prem}))=\mathrm{Cl}(\rho_h\mathrm{Prem})$.
* Links are the same, with $\Gamma_j=\{y_i\}$.
* The semantic statement follows from soundness of $R_h$ for $\mathbb M_h$. ∎

**Proposition 2.3 (equivocation: step-checking alone is unsound) [proved, TOSU].** There is a hypothesis $h$ and an argument α such that:
* every inference of α is $h$-valid;
* every link of α joins equal strings;
* the conclusion is $h$-invalid.

*Proof (Cauchy's sum theorem).* Take two contexts:
* $c_1$ is Cauchy's proof, where $\rho_h$ reads "the series $\sum f_n$ converges" as *uniform* convergence;
* $c_2$ is the theorem's statement and Abel's 1826 counterexample, where the same string is read as *pointwise* convergence.

The argument runs:
1. premise $(c_2,$ "each $f_n$ is continuous"$)$;
2. premise $(c_2,$ "$\sum f_n$ converges"$)$;
3. link 2 ↝ $(c_1,$ "$\sum f_n$ converges"$)$;
4. link 1 ↝ $(c_1,$ "each $f_n$ is continuous"$)$;
5. inference from 3 and 4: $(c_1,$ "the sum is continuous"$)$. This step is valid, since a uniform limit of continuous functions is continuous;
6. link 5 ↝ $(c_2,$ "the sum is continuous"$)$.

Now check each item.
* Link 4 is valid, because both occurrences have the same reading.
* Link 6 is valid, because continuity of the sum is read the same in both contexts.
* Link 3 (pointwise ⇒ uniform) is *invalid*.
* The overall step $\{1,2\}\Rightarrow6$ is $h$-invalid: the Fourier series of a square wave is a countermodel. ∎

So the verifier must check links, as Definition 2.1 does. Lakatos's "hidden lemma" in Cauchy's proof is, in this model, an *invalid link*. Seidel's and Stokes's 1847 diagnosis ("uniform convergence") is the act of naming the reading on which the step is valid.

### 2.2 Soundness against adaptive provers

The prover is any strategy: randomized, adaptive, computationally unbounded. It knows $h^*$, the verifier's code and the history. It does not know future data.

**Theorem 2.4 (deterministic soundness) [proved, TOSU].** Assume (BG1) and noise-free, truthful data on all channels. Then for every prover, at every time $t$:
* every step or link accepted by $V^g_t$ is $h^*$-valid;
* hence (Lemma 2.2) the conclusion of every argument assembled from accepted items is $h^*$-valid, and true in every $M\in\mathbb M^*$ that satisfies its premises.

*Proof.* $h^*$ is never refuted, for four reasons:
* practice and escalation data are labelled by $h^*$;
* a paradox for $h^*$ from a designated context does not exist;
* object data are $h^*$-admissible;
* budgeted searches cannot refute what is not refutable.

So $h^*\in\mathrm{VS}_t$, and unanimity over $\mathrm{VS}_t$ implies validity under $h^*$. ∎

As in T1 there is **no union bound over queries**: one structural fact, $h^*\in\mathrm{VS}_t$, covers all of the prover's attempts. Incoherent survivors (unfound paradoxes) do not threaten soundness. They only make the intersection smaller and so cost escalations. This is why Frege's inconsistent "way out" would not have made a conservative verifier unsound. It would only have made it timid.

**Noisy practice.** With sporadic noise, $h^*$ may be refuted by a bad datum, so replace the version space by a posterior.
* Each $h$ carries a likelihood $p_h$ for practice data, with its noise model, and the oracle kernel is deterministic.
* Call the likelihoods **shadow-measurable** if $p_h$ depends only on the class $[h]$ of $h$ under the observational equivalence $\equiv_g$ of §3. This means the data distribution is a function of what the data can reveal.
* $V^{g,\delta}_t$ accepts $q$ iff $w_t(\{h: q\text{ not }g\text{-valid under }h\})<\delta$.

**Theorem 2.5 (time-uniform soundness, class prior) [proved; adapts T1 Thm 4.2].** Assume well-specification and shadow-measurable likelihoods, and let $W^*:=w([h^*])=\sum_{h\equiv_g h^*}w(h)$. If $\delta\le W^*\delta'$, then for every prover
$$\Pr[\exists t:\ V^{g,\delta}_t\text{ accepts an }h^*\text{-invalid query}]\le\delta'.$$
With a deterministic oracle, the good event depends only on the human data.

*Proof.*
* Let $Z_t=\sum_hw(h)L_t(h)/L_t(h^*)$. By shadow-measurability, $L_t(h')=L_t(h^*)$ for $h'\in[h^*]$, so $w_t([h^*])=W^*/Z_t$.
* $Z_t$ is a nonnegative supermartingale with $Z_0=1$, by the argument of T1 Thm 4.2: each observation's likelihood ratio has conditional expectation ≤ 1 under the truth, including for observations chosen adaptively by the prover.
* By Ville's inequality, with probability ≥ 1−δ′ we have $Z_t<1/\delta'$ for all $t$, so $w_t([h^*])>W^*\delta'\ge\delta$.
* Every $h'\in[h^*]$ has the same $g$-step relation as $h^*$. Hence for an $h^*$-invalid query, $w_t(\text{invalid})\ge w_t([h^*])>\delta$, and the query is not accepted.
* The deterministic-oracle clause is T1 Thm 4.2(b) verbatim. ∎

**Remark (gauge redundancy helps).** A meaning that admits many formalizations (renamings, equivalent axiomatizations, ε-δ or infinitesimal readings) gets prior mass from all of them. Soundness is paid for at the level of *meanings*, not of formalizations.

**Proposition 2.6 (resource-bounded checking preserves soundness) [proved, TOSU].** Suppose the verifier, for each hypothesis, runs a budgeted proof search for the step (e.g. a hammer within Draft-Sketch-Prove; Jiang et al. 2023) and counts "not found" as "not valid". Then its accepted set is a subset of the idealized one, so Thms 2.4 and 2.5 still hold. For countable $\mathcal H$ it suffices to search under the finitely many hypotheses that carry posterior mass $>1-\delta$, and to treat the rest as rejecting.

*Proof.* Acceptance requires certificates, and a certificate is a derivation, so it implies validity. Shrinking the accepted set preserves soundness. ∎

This is TC3 of L6 and TC8 of L8, made exact. *A learner that proposes expansions and checks them exactly is sound by construction, and the remaining risk is global:* is the true formalization in the class, and have its rivals been eliminated?

### 2.3 Costs: escalation, ambiguity, expansion

Let $\mathcal H^g=\{\mathrm{St}^g_h:h\in\mathcal H\}$ be the induced class of informal step relations. Let $\mathrm{el}(\mathcal H^g,\mathrm{St}^g_{h^*})$ be T1's positive elasticity: the longest chain of $h^*$-valid steps each outside the intersection of the hypotheses that contain the previous ones.

**Theorem 2.7 (escalation costs) [proved by reduction to T1].** Let the prover be honest, i.e. submit only $h^*$-$g$-valid steps.
* (a) With noise-free data, the number of escalations is at most $\mathrm{el}(\mathcal H^g,\mathrm{St}^g_{h^*})\le|\mathcal H/{\equiv_g}|-1$.
* (b) For the Bayesian verifier with a deterministic oracle, the number of escalations is at most $(\ln(1/W^*)+\ln(1/\delta''))/\delta$, with probability $\ge1-\delta''$.
* (c) Both bounds are tight up to the constants of T1: on the single-culprit class of §4, (a) equals $|\mathcal H|-1$.

*Proof.* The informal steps form a step universe in T1's sense, and $\mathcal H^g$ is a class of step sets. Hence:
* (a) is T1 Thm 3.2: escalated honest steps form an elastic chain, and each answer removes at least one $\equiv_g$-class;
* (b) is T1 Thm 4.4 with the class prior of Thm 2.5;
* (c) is T1 Thm 3.9. ∎

**Proposition 2.8 (expansion makes the verifier complete) [proved, TOSU].** Call $h^*$ **step-expressive** if every $R^*$-derivation between ρ*-images can be rewritten as a chain of informal steps, each the $\rho^*$-image of a *single* rule application: a 1-valid step. Suppose step-expressiveness holds, and every survivor agrees with $h^*$ on 1-validity, i.e. the atomic informal rules have been identified (e.g. by T1's schema learning). Then for every $h^*$-valid step there is an argument, using only steps and links that $V^1_t$ accepts, that derives its conclusion from its premises.

*Proof.* Take the expansion that step-expressiveness provides. Every line is a 1-step accepted by unanimity, and every link joins identical readings. ∎

So the architecture the user proposes in his notes ("ask them to explain/justify/derive those [primitives]") is *sound at all times* (Thm 2.4) and *complete via expansion* once the atomic level is learned. All learning difficulty concentrates in the 1-step relation and in ρ. Section 6 adds the case where the readings themselves are vague, and escalation there means "which sharpening do you mean?".

---

## 3. Identifiability up to informal-validity equivalence

### 3.1 Three equivalences

**Definition 3.1.**
* **Informal-validity equivalence**: $h\approx h'$ iff ${\models_h}={\models_{h'}}$, as subsets of $\mathcal P_{\rm fin}(X)\times X$. Note that $\mathrm{dom}\,\rho_h=\{x:(\{x\}\Rightarrow x)\in{\models_h}\}$ is recovered from $\models_h$.
* For $D\subseteq X$, write $h\approx_Dh'$ if the two relations agree on steps whose occurrences all lie in $D$. The case of interest is $D=\mathrm{dom}\,\rho^*$, the *practice's domain*.
* **Observational equivalence at gap $g$**: $h\equiv_g h'$ iff all three of the following hold:
  * $\mathrm{St}^g_h=\mathrm{St}^g_{h'}$;
  * $\mathcal V_h=\mathcal V_{h'}$;
  * for every $A\in\mathcal A$, $h$ is coherent on $A$ iff $h'$ is.
* $\equiv_\infty$ is the same with ${\models}$ in place of $\mathrm{St}^g$.

Data on the three channels are functions of these "shadows":
* practice data are elements of $\mathrm{St}^g_{h^*}$, with a shadow-measurable distribution;
* paradoxes refute exactly the hypotheses that are incoherent on some $A$;
* object data are restrictions of members of $\mathcal V_{h^*}$.

**Proposition 3.2 (no learner sees past the shadow) [proved, TOSU].** If $h\equiv_gh'$, then every data sequence that can occur when the target is $h$ can also occur when the target is $h'$, with the same probability. Hence every learner behaves identically on the two, and no learner identifies the target more finely than $\equiv_g$.

### 3.2 The informal completeness lemma

Call $\mathrm{dom}\,\rho_h$ **negation-closed** if:
* there is an informal operation $x\mapsto{\sim}x$ ("it is not the case that …", performed in the same context) with $\mathrm{dom}\,\rho_h$ closed under it;
* $T_h\vdash\rho_h({\sim}x)\leftrightarrow\neg\rho_h(x)$.

**Lemma 3.3 (informal completeness) [proved].** Let $h$ be first-order complete with negation-closed domain $D_h=\mathrm{dom}\,\rho_h\neq\emptyset$. Define the **coherent valuations of $\models_h$** to be the maps $v:D_h\to\{0,1\}$ such that:
* $v({\sim}x)=1-v(x)$ for every $x$;
* whenever $\Gamma\subseteq v^{-1}(1)$ is finite and $\Gamma\models_hy$, we have $v(y)=1$.

Then:
* (i) $\mathcal V_h$ is exactly the set of coherent valuations of $\models_h$.
* (ii) $\Gamma\models_hy$ iff $\Gamma\cup\{y\}\subseteq D_h$ and every $v\in\mathcal V_h$ with $v(\Gamma)=1$ has $v(y)=1$.
* (iii) A designated $A\subseteq D_h$ is $h$-coherent iff some $v\in\mathcal V_h$ has $v(A)=1$, iff $A\not\models_hy$ for some $y$.

So $\models_h$, $\mathcal V_h$ and the coherence data determine one another.

*Proof.*
* (i) ⊆. If $M\models T_h$ and Γ is true in $M$ (via $\rho_h$), then $\Gamma\models_hy$ gives $M\models\rho_h(y)$. Negation follows from the biconditional.
* (i) ⊇. Let $v$ be coherent and $\Theta:=T_h\cup\{\rho_h(x):v(x)=1\}$.
  * Suppose Θ were inconsistent. By compactness, some finite $\Gamma\subseteq v^{-1}(1)$ has $T_h\cup\rho_h\Gamma$ inconsistent, hence $\Gamma\models_hy$ for every $y\in D_h$. Pick any $x\in D_h$. One of $x,{\sim}x$ has $v$-value 0; call it $y$. Then $\Gamma\models_hy$ forces $v(y)=1$, a contradiction.
  * So Θ has a model $M$. For $v(x)=1$ we get $M\models\rho_h(x)$. For $v(x)=0$ we have $v({\sim}x)=1$, so $M\models\neg\rho_h(x)$. Thus $v=v_M\circ\rho_h$.
* (ii) ⇒ is soundness. For ⇐: if $\Gamma\not\models_hy$ with $\Gamma\cup\{y\}\subseteq D_h$, then $T_h\cup\rho_h\Gamma\cup\{\neg\rho_hy\}$ is consistent by completeness. A model of it gives $v\in\mathcal V_h$ with $v(\Gamma)=1$ and $v(y)=0$.
* (iii) $A$ is coherent iff $T_h\cup\rho_hA$ is consistent iff it has a model. The second equivalence is ex falso, together with consistency. ∎

This is the user's "philosophical completeness theorem" ("a mode of talking makes sense (is coherent) iff there is something it could be talking about", L10 §1.5) for informal shadows. *The coherent ways of evaluating the practice's sentences are exactly the admissible objects.* The caveat he already knows is visible in the hypothesis: $\mathbb M_h=\mathrm{Mod}(T_h)$ includes non-standard models. If only standard objects are ever presented, channel (O) sees less than $\mathcal V_h$, and true-but-unprovable strengthenings such as $T+\mathrm{Con}(T)$ survive. These are not errors about truth, but they *are* over-generalizations of the practice's validity relation.

### 3.3 The identifiability theorem

**Theorem 3.4 (identification exactly up to ≈ on the practice's domain) [proved].** Let every $h\in\mathcal H$ be first-order complete with negation-closed domain (one fixed informal negation), and let $D^*=\mathrm{dom}\,\rho^*$.
* **(a) Shadows coincide with meaning.** $h\equiv_\infty h'$ iff $h\approx h'$, by Lemma 3.3.
* **(b) Nothing finer.** By Prop 3.2, no learner using closure-level data identifies the target more finely than ≈.
* **(c) Exact identification of meaning.** Let $\mathcal H$ be finite with $h^*\in\mathcal H$. Let the presentation be **complete**: every element of ${\models_{h^*}}$ appears in (P), and every finite restriction of every member of $\mathcal V_{h^*}$ appears in (O). Then after finitely many data, the survivors are exactly
  $$U^*=\{h\in\mathcal H:\ h\approx_{D^*}h^*\},$$
  and the conservative verifier's accepted relation on $D^*$ equals ${\models_{h^*}}$.
* **(d) Bounded-gap data.** If instead (P) presents $\mathrm{St}^g_{h^*}$, the eventual survivors are exactly the $h\in U^*$ with $\mathrm{St}^g_h\supseteq\mathrm{St}^g_{h^*}$, and the accepted relation equals $\mathrm{St}^g_{h^*}$ exactly.

*Proof.* (a) and (b) are immediate from Lemma 3.3 and Prop 3.2.

(c) Let $h\not\approx_{D^*}h^*$. There are two cases.
* *Case 1:* some $s\in{\models_{h^*}}\setminus{\models_h}$. Then $s$ is eventually presented and refutes $h$.
* *Case 2:* ${\models_{h^*}}\subseteq{\models_h}$ on $D^*$, with some $s=(\Gamma\Rightarrow y)\in{\models_h}\setminus{\models_{h^*}}$ whose occurrences lie in $D^*$.
  * By Lemma 3.3(ii) for $h^*$, some $u\in\mathcal V_{h^*}$ has $u(\Gamma)=1$ and $u(y)=0$. Its restriction to $\Gamma\cup\{y\}$ is eventually presented.
  * Every $v\in\mathcal V_h$ with $v(\Gamma)=1$ has $v(y)=1$, so this datum refutes $h$.

Finiteness of $\mathcal H$ gives a finite time after which only $U^*$ survives. $U^*$ itself is never refuted:
* its members agree with $h^*$ on all positive data on $D^*$;
* they have the same admissible valuations restricted to $D^*$. To see this, apply the proof of Lemma 3.3(i) to $\rho_h$ restricted to the negation-closed set $D^*$. The coherent valuations of ${\models_h}|_{D^*}={\models_{h^*}}$ are realized by models of $T_h$, and every finite restriction of $u\in\mathcal V_{h^*}$ is such a valuation's restriction;
* designated contexts lie in $D^*$, so by Lemma 3.3(iii) coherence on them is the same for $h$ and $h^*$.

The intersection of the survivors' relations contains ${\models_{h^*}}$, because all survivors contain it. It is contained in ${\models_{h^*}}$, because $h^*$ survives.

(d) Case 1 now refutes exactly the $h$ with $\mathrm{St}^g_{h^*}\not\subseteq\mathrm{St}^g_h$, and Case 2 is unchanged. An $h\approx_{D^*}h^*$ whose $g$-step relation is a strict superset is refuted by nothing. The intersection argument is the same. ∎

**What (d) says.** Bounded-gap data reveal *granularity* only from one side. The practice's own step relation is learned exactly, but a hypothesis that makes the same inferences in coarser steps is never excluded. This is Gold's asymmetry, now about obviousness rather than validity. Occurrences outside $D^*$ (sentences the practice never uses) are never constrained. That is §6's robust core seen from the identifiability side.

### 3.4 Witnesses: different ontologies, same informal meaning

**Proposition 3.5 (transfer: ontology is unidentifiable at every gap) [proved, modulo the cited transfer principle].** Let $h=(L,R,\rho,\mathbb M)$, and let $h'=(L,R,\rho,\mathbb M')$ be such that every member of $\mathbb M'$ is elementarily equivalent to some member of $\mathbb M$ and vice versa. Then $h\equiv_gh'$ for every $g$.

For instance, let $L$ be a countable sublanguage of the first-order language of the superstructure over $\mathbb R$, with constants for the standard objects the practice can name. Let ρ read informal analysis into bounded $L$-sentences, as usual. Take $\mathbb M=\{V(\mathbb R)\}$ and $\mathbb M'=\{{}^*V(\mathbb R)\}$, a nonstandard enlargement. By Robinson's transfer principle (Robinson 1966; Łoś's theorem) [cited], the two satisfy the same bounded sentences with standard parameters. So *whether the intended reals of practice contain infinitesimals* cannot be learned from any practice, coherence or object data in this language.

*Proof.* $R$ and ρ are shared, so $\mathrm{St}^g$ and coherence are shared. A valuation $v_M\circ\rho$ depends only on the complete theory of $M$, so $\mathcal V_h=\mathcal V_{h'}$. ∎

**Proposition 3.6 (ε-δ versus internal set theory) [cited; sketch].** Let $h_{\rm W}$ be the Weierstrassian formalization: ZFC, with informal infinitesimal talk read by contextual definition into limit statements. Let $h_{\rm IST}$ read the same talk literally in Nelson's internal set theory, i.e. ZFC plus a predicate "standard" with the idealization, standardization and transfer schemas. Nelson (1977, *Bull. AMS* 83:1165–1198) proved IST conservative over ZFC [cited], and his reduction algorithm translates each IST formula with standard parameters into an equivalent internal one [cited].
* *Sketch.* For informal sentences about standard objects, conservativity gives the same consequences. For infinitesimal talk, the reduction algorithm *is* a contextual reading into ZFC, so $h_{\rm W}\approx_{D}h_{\rm IST}$ on the practice's domain.
* Whether the $g$-step relations also coincide is *not* claimed. Infinitesimal proofs are plausibly shorter, so bounded-gap Leibnizian practice may be fit better by $h_{\rm IST}$. By Thm 3.4(d), however, this is evidence about *granularity*, never decisive against $h_{\rm W}$.

**Proposition 3.7 (Benacerraf) [proved, modulo standard facts of ZF].** Let $D_{\rm ar}$ be the occurrences of informal arithmetic sentences. Let $\rho_{\rm vN}$ and $\rho_{\rm Z}$ read them into $L_\in$ via the von Neumann numerals ($n+1=n\cup\{n\}$) and the Zermelo numerals ($n+1=\{n\}$) respectively, with $+$ and $\times$ defined by recursion. Then $(\mathrm{ZF},\rho_{\rm vN})\approx_{D_{\rm ar}}(\mathrm{ZF},\rho_{\rm Z})$. The readings differ on "$1\in3$": true for von Neumann, false for Zermelo, since $3=\{\{\{\emptyset\}\}\}\not\ni\{\emptyset\}$. That sentence lies outside $D_{\rm ar}$.

*Proof.* ZF proves that both $(\omega_{\rm vN},0,S_{\rm vN})$ and $(\omega_{\rm Z},0,S_{\rm Z})$ are Dedekind–Peano systems. ZF proves Dedekind's categoricity theorem: any two such systems are isomorphic by a unique recursion-defined map, which preserves the recursively defined $+$ and $\times$. Hence ZF proves $\rho_{\rm vN}(x)\leftrightarrow\rho_{\rm Z}(x)$ for every arithmetic $x$, by induction on formulas transported along the isomorphism. Equal readings up to ZF-provable equivalence give equal informal consequence relations on $D_{\rm ar}$. ∎

Benacerraf (1965, "What numbers could not be") is thus a theorem about non-identifiability: the practice fixes ≈ on its domain and nothing else.

### 3.5 Why ≈ is the inferentialist-correct notion

1. **It is the inferential role.**
   * For a Brandom-style inferentialist, the meaning of a sentence is its role in material inference.
   * Bilateralists add incompatibility; here incompatibility is incoherence, which ≈ fixes by Lemma 3.3(iii).
   * Sellars adds language-entry transitions: what one says when confronted with something. Here these are object evaluations, which ≈ fixes by Lemma 3.3(i).

   So, under completeness, the whole Sellars–Brandom profile of every practice sentence is a function of $\models_h$ on $D^*$. Two latent formalizations that are ≈ on $D^*$ assign *the same inferentialist meaning to every sentence the practice uses*.
2. **It is exactly what verification needs.** The verifier's soundness and completeness depend on nothing else (Thms 2.4 and 3.4(c, d)).
3. **Everything finer is idle and unidentifiable.** Ontology (Prop 3.5), choice of latent language (Prop 3.6) and treatment of junk sentences (Prop 3.7) never change a practice inference, and no data the practice could produce distinguish them.
4. **Objections.**
   * (a) *Granularity is real.* What counts as one obvious step is cognitively significant, and it is partially identifiable (Thm 3.4(d)). It is pragmatics (which steps are *acceptable*), not semantics (which steps are *valid*).
   * (b) *Proof-theoretic semanticists* (Dummett–Prawitz) individuate meaning by canonical derivations, which is finer than ≈. The theorem says such a meaning is identifiable from practice at most up to one-sided granularity. The non-identified remainder is exactly what they would add.
   * (c) *A representationalist* says ε-δ and infinitesimals differ in what they are about. Prop 3.5 shows that the practice cannot settle it. The inferentialist reads this as "there was no fact of the matter in the practice", the realist as "the fact outruns the evidence". The mathematics is neutral. The verifier needs only ≈.

---

## 4. Counterexample objects and step-level blame

### 4.1 Descent along false lines

**Lemma 4.1 (descent; Lakatos–Shapiro–Easwaran) [proved, TOSU].** Let α be an argument, and let $v$ be a valuation defined on its lines with $v(\text{premises})=1$ and $v(\text{conclusion})=0$. Then α contains either:
* an inference line $\Gamma_j\Rightarrow y_j$ with $v(\Gamma_j)=1$ and $v(y_j)=0$, or
* a link $y_i\leadsto y_j$ with $v(y_i)=1$ and $v(y_j)=0$.

Such an item is found by evaluating at most $\sum_{\text{lines on one dependency path}}(\text{fan-in})$ lines, and after at most $\mathrm{depth}(\alpha)$ moves. If $v$ is $h$-admissible, the item found is $h$-invalid.

*Proof.* Start at the conclusion, which is false.
* At a false inference line: if all its antecedents are true, stop. Otherwise move to a false antecedent.
* At a false link target: if the source is true, stop. Otherwise move to the source.

Premises are true, so the walk never ends at a premise. Each move goes to a strictly earlier line, so the walk terminates within depth-many moves, evaluating the antecedents of the visited lines only.

For the last claim, let $v=v_M\circ\rho_h$ with $M\in\mathbb M_h$. If the item were $h$-valid, soundness of $R_h$ for $\mathbb M_h$ would make its conclusion true in $M$. ∎

This is Shapiro's contradiction backtracing (MIS) transposed to informal arguments (L6 §2). It is also Lakatos's conversion of a *global* counterexample into a *local* one, and Easwaran's "convertibility" requirement on published proofs (L6 §2): an argument is convertible exactly when its lines are fine enough for $v$ to be evaluated on each.

Two points are new here.
* *Descent can end at a link.* Then the blame falls on an **equivocation** (Prop 2.3), not on a rule. This is Lakatos's "global but not local" case: every explicit step looks fine and the fault is a hidden change of reading.
* *The refutation is relative to admissibility.* A blamed step refutes exactly the hypotheses that validate it *and* admit the object. A learner may instead revise admissibility (monster-barring, §4.4).

### 4.2 The correction game: objects versus paradoxes

**Definition 4.2.** Let $S$ be a finite step universe (informal steps, or rule schemas) and $\mathcal H\subseteq2^S$ a finite class of step sets, with target $h^*\in\mathcal H$. Here $S$ may be taken to be the steps, and $\mathcal H=\mathcal H^g$ the induced relations. In each round the learner announces an accepted set $A_t\subseteq S$, which need not be a hypothesis. If $A_t\neq h^*$, the environment returns one feedback item:
* **(+)** a step $s\in h^*\setminus A_t$: a practice use or an escalation answer;
* **(−obj)** a step $s\in A_t\setminus h^*$: an object, after descent;
* **(−bag$_r$)** a set $B\subseteq A_t$ with $|B|\le r$ and $B\not\subseteq h^*$: the *suspect steps* of a paradox. Steps in $\bigcap\mathrm{VS}$ are certified and are dropped from a bag without loss.

The learner deletes the inconsistent hypotheses: $h\not\ni s$, $h\ni s$, and $h\supseteq B$ respectively. A *correction* is a round with feedback. $M_{\rm obj}(\mathcal H)$ and $M_{\rm bag}^{(r)}(\mathcal H)$ denote the optimal worst-case numbers of corrections over learners, targets and adversarial environments. The environment picks which item to return. $M_{\rm bag}:=M^{(|S|)}_{\rm bag}$ allows unbounded bags.

*Availability.* (−obj) requires an admissible object refuting some accepted invalid step. Call this **object-completeness**. It holds for propositional and finite-model-property fragments. It fails for incomplete theories: an $R^*$-invalid step that is true in every presentable (standard) object is never refuted by an object. That is silent unsoundness, beyond the reach of channel (O).

**Theorem 4.3 (objects: logarithmic) [proved].**
* (a) $M_{\rm obj}(\mathcal H)\le\lfloor\log_2|\mathcal H|\rfloor$. With a prior $w$, weighted halving makes at most $\log_2(1/w(h^*))$ corrections. With $w=2^{-\ell}$ this is at most $\ell(h^*)$: *the number of counterexamples needed is at most the description length of the target formalization.* Hypotheses with the same step relation are one hypothesis in this game, so their weights add. This improves the bound to $\log_2(1/w([h^*]))$.
* (b) $M_{\rm obj}(\mathcal H)\le M^{(r)}_{\rm bag}(\mathcal H)$ for every $r\ge1$, with equality at $r=1$.

*Proof.*
* (a) Let $A_t=\{s:w(\{h\in\mathrm{VS}:s\in h\})>\tfrac12w(\mathrm{VS})\}$.
  * Feedback (+) on $s\notin A_t$ keeps only $\{h\ni s\}$, which has weight at most $\tfrac12w(\mathrm{VS})$.
  * Feedback (−obj) on $s\in A_t$ keeps only $\{h\not\ni s\}$, which has weight below $\tfrac12w(\mathrm{VS})$.

  Since $h^*$ is never deleted, $w(h^*)\le w(\mathrm{VS})\le2^{-M}$ after $M$ corrections.
* (b) Every (−obj) item $s$ is also a legal (−bag$_r$) item $B=\{s\}$, with the same deletion. So the object environment's moves are a subset of the bag environment's, and a bag learner's strategy works in the object game with no more corrections. At $r=1$ the two games coincide. ∎

**Theorem 4.4 (paradoxes: linear, tightly) [proved; computed].**
* **(a) Upper bound.** $M^{(r)}_{\rm bag}(\mathcal H)\le\min\{\mathrm{el}^*(\mathcal H),\ |\mathcal H|-1\}$, where $\mathrm{el}^*$ is the maximum over targets of T1's positive elasticity.
* **(b) Single-culprit class.** Let $S=\{b_1,\dots,b_n\}$ and $\mathcal H_n=\{S\setminus\{b_j\}:j\le n\}$: exactly one of $n$ suspect steps is invalid. Then
  $$M_{\rm obj}(\mathcal H_n)=1,\qquad M^{(r)}_{\rm bag}(\mathcal H_n)=\min(r,\,n-1).$$
  In particular $M_{\rm bag}(\mathcal H_n)=n-1=|\mathcal H_n|-1$ and $\log_2|\mathcal H_n|=\log_2n$. This is an exponential separation, and (a) is tight.
* **(c) Natural realization with essential bags: the chain paradox.**
  * Take informal sentences $q_0,\dots,q_n$ (e.g. "a pile of $k$ grains is a heap", or any chain of "obvious" lemmas), suspect steps $b_i=(q_{i-1}\Rightarrow q_i)$, and the single designated context $A=\{q_0,{\sim}q_n\}$.
  * Let hypothesis $h_j$ validate every $b_i$ with $i\neq j$; e.g. propositional readings with axioms $p_{i-1}\to p_i$ for $i\neq j$.
  * Every $h_j$ is coherent on $A$, so the designation is truthful whatever the target.
  * Every derivation of ⊥ from $A$ using the $b_i$ uses *all* of them. Every paradox is the same essential bag, and no padding argument is needed.
  * With paradox feedback, every learner suffers $n-1=|\mathcal H|-1$ corrections. A single admissible object (any $u\in\mathcal V_{h_{j^*}}$ with $u(q_0)=1$, $u(q_n)=0$) pins down $j^*$ by descent.

*Proof.*
* (a) The cautious learner $A_t=\bigcap\mathrm{VS}_t$ never accepts an invalid step, since $h^*\in\mathrm{VS}_t$, so it receives only (+) items. The steps so received form an elastic chain, so there are at most $\mathrm{el}^*$ corrections. The learner $A_t:=$ any $h\in\mathrm{VS}_t$ has every feedback item delete $h$, so there are at most $|\mathcal H|-1$ corrections.
* (b) *Objects.* Announce $A=S$. The only possible feedback is (−obj) $b_{j^*}$, which deletes every $h_j$ with $j\neq j^*$. That is one correction, and at least one is needed since $|\mathcal H_n|\ge2$.

  *Bags, lower bound.* Let $C$ be the set of surviving candidate culprits. The learner gains nothing by rejecting known-valid steps: positive feedback on them deletes nothing, so the environment could repeat it forever. Consider one round.
  * If the learner accepts all of $C$ and $|C|\le r$, the environment returns $B=C$. This deletes $\{h_j:B\subseteq h_j\}=\{h_j:b_j\notin B\}$, which contains no survivor. The round is useless, so the learner must not do this.
  * If it accepts all of $C$ and $|C|>r$, the environment returns $r$ candidates as $B$, and $C\leftarrow B$.
  * If it rejects some $b_i$ with $i\in C$, the environment returns (+) $b_i$, which is consistent with any $j^*\in C\setminus\{i\}$. Then $C\leftarrow C\setminus\{i\}$.

  So from $|C|=c$ one correction reaches at best $\min(c,r)$ (only if $c>r$) or $c-1$. With $f(1)=0$:
  * $f(c)=c-1$ for $c\le r$;
  * $f(c)=\min(1+f(r),1+f(c-1))=r$ for $c>r$.

  Hence $f(n)=\min(r,n-1)$.

  *Bags, upper bound.* If $|C|>r$, announce $A=S$. Only bags are possible, and one bag leaves at most $r$ candidates. Then repeatedly announce $S\setminus\{b_c\}$ for some $c\in C$. Every possible feedback deletes $h_c$: a bag must contain the true culprit and cannot contain $b_c$, and (+) can only name $b_c$. Each correction therefore removes at least one candidate.
* (c) Coherence of $h_j$ on $A$: the valuation with $p_i$ true iff $i<j$ satisfies all its axioms together with $q_0$ and ${\sim}q_n$. A ⊥-derivation from $A$ must derive $q_n$ from $q_0$. With the $b_i$ as the only non-logical steps between the $q$'s, it must traverse every $b_i$. So every bag is $S$, which deletes nothing. The learner must reject a candidate each round, and the environment answers with (+) on one rejected candidate, deleting one hypothesis. There are therefore $n-1$ corrections.

  The object: any $u\in\mathcal V_{h_{j^*}}$ with $u(q_0)=1$ and $u(q_n)=0$ has $u(q_i)=1$ exactly for $i<j^*$. Descent on the chain stops at $b_{j^*}$. ∎

**Computed values** (`T4-checks/bag_vs_object_game.py`, exact minimax over all learner announcements and environment replies):

| class | $\vert\mathcal H\vert$ | $\log_2\vert\mathcal H\vert$ | $M_{\rm obj}$ | $M^{(r)}_{\rm bag}$, $r=1..n$ |
|---|---|---|---|---|
| single culprit, $n=4$ | 4 | 2.00 | 1 | 1, 2, 3, 3 |
| single culprit, $n=6$ | 6 | 2.58 | 1 | 1, 2, 3, 4, 5, 5 |
| two culprits of 6 | 15 | 3.91 | 2 | 2, 4, 4, 4, 4, 4 |
| three culprits of 5 | 10 | 3.32 | 2 | 2, 2, 2, 2, 2 |

On 244 random classes (`bag_vs_elasticity.py`), $M_{\rm obj}\le M_{\rm bag}\le\min(\mathrm{el}^*,|\mathcal H|-1)$ always held, and $M_{\rm obj}<M_{\rm bag}$ in 32 of them. The natural conjecture "$M_{\rm bag}=\mathrm{el}^*$" (paradoxes are worthless and caution is optimal) is **false**. It held in about two thirds of 295 random classes; the smallest counterexample is $\mathcal H=\{\emptyset,\{0\},\{0,1\}\}$, with $M_{\rm bag}=1<2=\mathrm{el}^*$. Bags help when hypotheses are nested; they are worthless on antichains such as $\mathcal H_n$.

**Bounded bags: the price is linear in the bag size.** Real paradoxes have a bounded number of *suspect* steps. The steps that every surviving hypothesis accepts are certified and drop out.

**Theorem 4.5 (bags of size $\le r$) [proved].** For every finite $\mathcal H$ with prior $w$ and every $r\ge1$,
$$M^{(r)}_{\rm bag}(\mathcal H)\ \le\ \frac{\ln(1/w(h^*))}{\ln(1+1/r)}\ \le\ (r+1)\ln|\mathcal H|\quad(\text{uniform }w).$$
It is achieved by the **super-majority learner** $A_t=\{s:\ w(\{h\in\mathrm{VS}:s\in h\})>\tfrac{r}{r+1}w(\mathrm{VS})\}$. For $r=1$ this is halving.

*Proof.* Every $s\in A_t$ is missed by less than $\frac1{r+1}w(\mathrm{VS})$ of the weight.
* A bag $B\subseteq A_t$ with $|B|\le r$ deletes all $h\supseteq B$. By the union bound, the hypotheses missing some element of $B$ weigh less than $\frac r{r+1}w(\mathrm{VS})$, and they are all that remains.
* A (+) item $s\notin A_t$ keeps only $\{h\ni s\}$, of weight at most $\frac r{r+1}w(\mathrm{VS})$.

Since $h^*$ is never deleted, $w(h^*)\le(\frac r{r+1})^M$ after $M$ corrections. ∎

**Proposition 4.6 (the linear dependence on $r$ is necessary) [proved; computed].** Let $\mathcal H$ be the product of $k$ independent single-culprit blocks of size $b$, so $|\mathcal H|=b^k$. Then $M_{\rm obj}=k$ and $M^{(r)}_{\rm bag}\ge k\min(r,b-1)$. With $b=r+1$ this gives
$$M^{(r)}_{\rm bag}\ \ge\ r\cdot\frac{\log|\mathcal H|}{\log(r+1)},$$
while $M_{\rm obj}=\log|\mathcal H|/\log(r+1)$.

*Proof.* Objects: accept everything; each object, after descent, names one culprit.

Bags: the environment answers within a single block, as in Thm 4.4(b).
* If some block's surviving candidates are partly rejected, answer (+) on one rejected candidate.
* Otherwise, if some block has more than $r$ candidates, answer with a bag of $r$ of them.
* Otherwise the learner accepts all candidates of a block with at most $r$ candidates. The environment answers with that whole block, which deletes nothing, so the round is useless.

Every correction shrinks one block's candidate set, exactly as in the one-block game, so each block costs $\min(r,b-1)$ corrections. The script `bag_product.py` confirms equality for $(b,k)\in\{(2,2),(3,2),(2,3)\}$ and all $r$. ∎

So in the online, adversarial setting, **the cost of multiple-instance (paradox) feedback grows linearly in the number of suspect steps**: $\tilde\Theta(r\log|\mathcal H|)$, up to a $\log r$ factor. Contrast the i.i.d. setting, where Sabato & Tishby (2012) [cited, bound form unverified] obtain only a $\log r$ overhead in sample complexity. This settles the "open part" of L8's TC4 for finite classes. I also conjecture the sharper $M^{(r)}_{\rm bag}\le r\,M_{\rm obj}$ [conjecture]. It held with ratio at most 1 on all 519 (class, $r$) pairs tested (`bag_size_conjecture.py`), with equality on single-culprit and product classes.

**Relation to T2.** T2's oligarchic halving (Thm 2.2) bounds the number of *detected incoherences* by $\log_2(1/w(h^*))$. Theorem 4.4(c) shows that the *total* number of corrections, counting the false rejections that oligarchy forces, can still be $|\mathcal H|-1$, and that every learner suffers this. Coherence bounds the price of boldness, not the price of learning. Objects bound both.

**Moral.** The sorites is the canonical *uninformative paradox*: coherence says that one link of the chain is bad and never which. This explains why the paradoxes of set theory (Russell, Burali-Forti) did not by themselves select a repair (§5), while monsters (Weierstrass's function, Abel's series, the homology sphere) generated concepts. The design consequence for the project (L6 TC1) is that a pre-formal learner must *generate and evaluate objects*, not only search for ⊥.

### 4.3 Lakatos's operators and the price of monster-barring

In $(L,R,\rho,\mathbb M)$-space, a step blamed by an object can be repaired in four ways (L6 §2):
* change $R$: *lemma-incorporation*, i.e. drop the rule or guard it;
* change ρ: *monster-adjustment*, e.g. re-read "converges" as "converges uniformly";
* reject the datum, i.e. shrink $\mathbb M$ or distrust the object: *monster-barring*;
* extend $L$: a *proof-generated concept*, i.e. a name for the hidden lemma.

**Proposition 4.7 (free barring nullifies objects) [proved, TOSU].** Suppose the learner may discard object data at no cost. Then every hypothesis consistent with (P) and (C) survives forever, and the bounds of Thm 4.3 fail; on $\mathcal H_n$ the learner is back to Thm 4.4. Now charge description length $c>0$ per barred datum. A hypothesis $h$ that must bar $m$ data to survive then has MDL score $\ell(h)+mc$, while the unbarred $h^*$ has score $\ell(h^*)$. So $h$ loses as soon as $m>(\ell(h^*)-\ell(h))/c$, and each wrong hypothesis can absorb only boundedly many monsters.

*Proof.* Without data from (O), only (P) and (C) refute. The cost claim is arithmetic. ∎

So the object channel is powerful only if objects are *independently certified*: the community, or computation, vouches that Abel's series converges in the relevant sense. Otherwise revisions of ρ are charged for, which is Lakatos's own preference ordering (L6 TC7). Proof-generated concepts are the MDL-cheap response when many monsters share a short distinguishing predicate. This is the user's biclique concept-invention heuristic (L10 §1.2) in another guise.

---

## 5. Frege → Russell → Zermelo as a theorem

### 5.1 The abstract repair theorem

**Setting.**
* $I$ is a set of rule instances, here comprehension instances.
* $\mathrm{Con}\subseteq\mathcal P(I)$ is the coherence predicate. It is downward closed and of finite character: a set is coherent iff its finite subsets are (compactness).
* $\mathcal R\subseteq\mathcal P(I)$ is a finite class of *uniformly specified restrictions*, with description lengths $\ell$.
* Practice at time $t$ is a usage-weight function $w_t:I\to[0,\infty)$ with finite support. Its coverage of $c$ is $\mathrm{cov}_t(c)=\sum_{i\in c}w_t(i)$.
* A ⊥-search with budget $t$ refutes $c$ iff $c$ has a refutation of size at most $t$. Every incoherent $c$ has one, of size $k(c)<\infty$, by compactness and completeness.

**Learners.**
* $\mathrm{MDL}_t:=\arg\min\{\ell(c):\ \mathrm{supp}(w_t)\subseteq c\}$.
* $\mathrm{REP}_t:=\arg\max$, lexicographically, of $(\mathrm{cov}_t(c),-\ell(c))$ over the $c\in\mathcal R$ not refuted by budget $t$.

**Theorem 5.1 [proved, TOSU].**
* **(a)** If $I\in\mathcal R$ ("naive comprehension", NC) and $\ell(I)<\ell(c)$ for all $c\neq I$, then $\mathrm{MDL}_t=I$ for all $t$.
* **(b)** A coherent $c$ is never refuted. An incoherent $c$ is refuted for all $t\ge k(c)$.
* **(c)** For $t\ge t_0:=\max\{k(c):c\in\mathcal R\text{ incoherent}\}$, $\mathrm{REP}_t$ maximizes $(\mathrm{cov}_t,-\ell)$ over the *coherent* members of $\mathcal R$.
* **(d) Convergence.** Suppose $w_t/\|w_t\|_1\to w_\infty$, and the coherent maximizer of $\mathrm{cov}_\infty$ is unique (strict). Then $\mathrm{REP}_t$ is eventually constant and equal to it.
* **(e) No canonical repair.** Let $c_1,c_2\in\mathcal R$ be coherent with $c_1\cup c_2$ incoherent. Then no coherent member of $\mathcal R$, and indeed no coherent subset of $I$, contains both. If $\mathrm{supp}(w_t)\subseteq c_1\cap c_2$, the choice between them at time $t$ is made by $\ell$ alone. Any later practice item in $c_1\setminus c_2$ shifts coverage toward $c_1$.

*Proof.*
* (a) $I$ contains every support and is shortest.
* (b) By the choice of search.
* (c) After $t_0$, the unrefuted members are exactly the coherent ones.
* (d) The normalized coverages converge, and a strict maximizer stays strict in a neighbourhood.
* (e) Supersets of an incoherent set are incoherent. When the supports are contained in $c_1\cap c_2$, coverage cannot separate $c_1$ from $c_2$. ∎

The theorem is trivial. The content lies in the instance below, which makes every hypothesis of the historical story checkable.

### 5.2 A comprehension toy with fully proved facts

**Formulas.** Work in first-order logic with $\in$ and $=$. For a formula $\varphi(x,a,b)$, let $\mathrm{Comp}(\varphi):=\forall a\forall b\exists y\forall x(x\in y\leftrightarrow\varphi)$. The menu Φ has ten formulas:

| name | $\varphi(x,a,b)$ | positive | stratified | of the form $x\in a\wedge\psi$ | historical role |
|---|---|---|---|---|---|
| V | $x=x$ | ✓ | ✓ | | Frege's extension of "object" |
| EMP | $x\neq x$ | | ✓ | | empty set |
| S | $x\in x$ | ✓ | | | |
| R | $x\notin x$ | | | | Russell's set |
| INT | $x\in a\wedge x\in b$ | ✓ | ✓ | ✓ | intersection (Dedekind) |
| UNI | $x\in a\vee x\in b$ | ✓ | ✓ | | union |
| PAIR | $x=a\vee x=b$ | ✓ | ✓ | | pairs |
| DIFF | $x\in a\wedge x\notin b$ | | ✓ | ✓ | difference (Cantor) |
| CMP | $x\notin a$ | | ✓ | | complement |
| ZR | $x\in a\wedge x\notin x$ | | | ✓ | Cantor's diagonal set / Zermelo 1908 |

Stratification works as in NF. A formula is stratified if it admits a typing $t$ with $t(v)=t(u)+1$ for each $u\in v$ and $t(u)=t(v)$ for each $u=v$. The formula $x\in x$ has no typing, so S, R and ZR are unstratified.

**Hypotheses.** The class $\mathcal R$ restricts to the menu:
* NC = all of Φ;
* POS = positive formulas;
* STRAT = stratified formulas (NF-like);
* SEP = formulas of the form $x\in a\wedge\psi$;
* Z = SEP ∪ {EMP, PAIR, UNI} (Zermelo-like: separation, elementary sets, union).

The description lengths are ordered $\ell(\mathrm{NC})<\ell(\mathrm{POS})<\ell(\mathrm{SEP})<\ell(\mathrm{STRAT})<\ell(\mathrm Z)$. Only "NC is shortest" and "STRAT is shorter than Z" matter below. The latter holds because Z is a uniform condition plus three named extra instances.

**Facts.** All are [proved].
* **F1. NC is incoherent.** Comp(R) gives $y$ with $\forall x(x\in y\leftrightarrow x\notin x)$. Instantiating $x:=y$ gives $y\in y\leftrightarrow y\notin y$, and hence ⊥. The refutation has 4 lines.
* **F2. POS is coherent,** even for *all* positive formulas with parameters. Take the one-element model $\{u\}$ with $u\in u$. Every atomic formula is true there, so every positive formula is true. Hence $y:=u$ witnesses every positive Comp instance. Extensionality holds trivially.
* **F3. STRAT∩Φ is coherent.**
  * Let $D=\mathbb N$ and let $e:\mathbb N\to\mathrm{FinCof}(\mathbb N)$ be a bijection onto the finite and cofinite subsets (a countable family). Put $x\in y:\iff x\in e(y)$.
  * For all parameters, the extension of each stratified menu formula is finite or cofinite: $D$, $\emptyset$, $e(a)\cap e(b)$, $e(a)\cup e(b)$, $\{a,b\}$, $e(a)\setminus e(b)$, $D\setminus e(a)$. Each is therefore $e(y)$ for some $y$.
  * Since $e$ is injective, Extensionality also holds.
* **F4. Z∩Φ is coherent.** The hereditarily finite sets HF, with real membership, satisfy all of Z∩Φ:
  * INT, DIFF and ZR define subsets of $a\in\mathrm{HF}$, which lie in HF;
  * EMP, PAIR and UNI define finite sets of HF-elements.

  Extensionality and Foundation hold too.
* **F5. Pairwise joint incoherence.**
  * POS ∪ Z and STRAT ∪ Z both contain {V, ZR}. Let $v$ be the V-set. Then ZR with $a:=v$ gives $\{x\in v:x\notin x\}$, which is Russell's set; so ⊥ by F1.
  * POS ∪ STRAT contains {S, CMP}. Let $s=\{x:x\in x\}$. Then CMP with $a:=s$ gives $\{x:x\notin s\}=\{x:x\notin x\}$; so ⊥.
* **F6. Inclusions.** SEP ⊊ Z, and POS, STRAT and Z are pairwise ⊆-incomparable: S ∈ POS∖STRAT, CMP ∈ STRAT∖POS, ZR ∈ Z∖STRAT, V ∈ STRAT∖Z, DIFF ∈ Z∖POS.

**Theorem 5.2 (the Frege–Russell–Zermelo trajectory) [proved from F1–F6; computed in `T4-checks/comprehension_toy.py`].**
* **(i) MDL picks the incoherent rule.** For every practice, $\mathrm{MDL}=\mathrm{NC}$ (Thm 5.1(a)). This is Frege's Basic Law V as the compression of "every concept has an extension".
* **(ii) Coherence refutes it,** with a 4-line search budget (F1).
* **(iii) There is no "minimal repair".** The maximal coherent members of $\mathcal R$ are exactly POS, STRAT and Z (F2–F4, F6; SEP ⊊ Z), and they are pairwise jointly incoherent (F5).
* **(iv) Coverage selects.** After refutation, $\mathrm{REP}_t$ is determined as follows:
  * *Dedekind–Cantor operations only* (support ⊆ {INT, UNI, PAIR, DIFF, EMP}). STRAT and Z both cover everything. POS misses DIFF and EMP. The tie between STRAT and Z is broken by $\ell$, which selects **STRAT**, the NF-like repair.
  * *Add Cantor's diagonal sets* (ZR). Only Z covers everything. **Z** is selected.
  * *Add Frege's universal extension* (V) *as well*. Z and STRAT each miss one item. Z is selected iff $w(\mathrm{ZR})>w(\mathrm V)$.

*Proof.* Combine Thm 5.1(c) with the membership table. The script reproduces the coverage table for illustrative weights. ∎

**The historical reading** is offered as the user asks: "a nice thing shadowed in" practice, not a claim about what Zermelo did.
* The diagonal set $\{x\in a: x\notin f(x)\}$ of Cantor (1891) is unstratified. Accordingly, NF does not prove Cantor's theorem in its general form, only the version for unit subsets: $|\mathrm{USC}(X)|<|\mathcal P(X)|$ [cited: standard; see the NF literature, e.g. Holmes, arXiv:1503.01406].
* Zermelo (1908, *Math. Ann.* 65:261–281) proves from Separation that every set $M$ has a subset $\{x\in M:x\notin x\}$ that is not an element of $M$, so the domain is not a set [cited]. That is exactly ZR applied to an arbitrary $a$, and it is the diagonal argument turned into a theorem.
* So the toy says: *practice that already contains diagonal arguments selects Separation over stratification, and Frege's universal extension is the price.* Without diagonal practice, simplicity would have favoured stratification, i.e. Quine's NF (1937).
* NF's consistency was open until Holmes's proof (arXiv:1503.01406) [cited], which has reportedly been checked in Lean **(unverified)**.
* Specker (1953) showed that NF refutes the Axiom of Choice **(citation details unverified)**. Practice that uses AC, defended by Zermelo in 1908 precisely by pointing to its uses (L6 §4), is a second separating datum outside this toy.

### 5.3 Non-uniqueness without coverage: the instance level

The class $\mathcal R$ is uniform: each member is given by a syntactic condition. Without uniformity, the repair problem is far worse.

**Proposition 5.4 (continuum many maximal consistent repairs) [proved].** The set of all instances of naive comprehension has at least $2^{\aleph_0}$ maximal consistent subsets. Even the single coherent practice item Comp($x\neq x$) has $2^{\aleph_0}$ pairwise incompatible maximal consistent extensions.

*Proof.* Some notation:
* for $n\ge1$, let $p_n$ be the sentence "some object has exactly $n$ elements";
* for a sentence $q$, let $J(q):=\mathrm{Comp}(x\notin x\wedge q)$;
* for $A\subseteq\mathbb N_{\ge1}$, let $I_A:=\{J(p_n):n\notin A\}\cup\{J(\neg p_n):n\in A\}\cup\{\mathrm{Comp}(x\neq x)\}$.

Then:
1. $J(q)\wedge q\vdash\bot$: if $q$ holds, $J(q)$ yields Russell's set. Hence $I_A\vdash\neg p_n$ for $n\notin A$ and $I_A\vdash p_n$ for $n\in A$. So $I_A\cup I_B$ is inconsistent whenever $A\neq B$.
2. $I_A$ is consistent. Let $M_A$ have domain $\{e_0,e_1,\dots\}\cup\{a_n:n\in A\}$, where every $e_i$ has no elements, $a_n$ has exactly the elements $e_0,\dots,e_{n-1}$, and there is no other membership.
   * Then $p_n$ holds in $M_A$ iff $n\in A$.
   * Every instance in $I_A$ is $J(q)$ with $q$ false in $M_A$, or Comp($x\neq x$). Each of these defines the empty class, which is witnessed by $e_0$.
3. Consistency has finite character, so by Zorn's lemma each $I_A$ extends to a maximal consistent $J_A$. If $A\neq B$, then $J_A\neq J_B$ by 1. ∎

**Incurvati & Murzi (2017)**, "Maximally consistent sets of instances of naive comprehension", *Mind* 126(502):371–384 [cited; author list verified this session]. They prove more: there are multiple incompatible maximal consistent sets, *none of them recursively axiomatizable* under minimal assumptions. This generalizes McGee's 1992 theorem for the T-schema (McGee 1992 details unverified). So:
* (a) "the maximal consistent repair" does not exist;
* (b) no computable learner can even output a single maximal one.

This is the precise sense in which **uniformity of the restriction class is what makes the learning problem well-posed**. Zermelo's stated method of "restricting sufficiently to exclude contradictions, widely enough to retain everything valuable" (L6 §4) is constrained optimization whose optimum exists only within a uniform class, and is selected only by coverage.

### 5.4 What the toy does not capture

* **Replacement (1922).** It was added because Z cannot prove that $\aleph_\omega$ exists. That is coverage of a *conclusion*, not of an instance used in proofs, and it needs a richer menu. Thm 5.1 covers it, but the toy does not instantiate it.
* **The cumulative-hierarchy conception** (Zermelo 1930) is a semantic prior over repairs, not data. In the model it is a choice of $\ell$.
* **Undecidable coherence.** Coherence of the selected repair is not certified by the learner (Gödel II). $\mathrm{REP}_t$ can hold an incoherent repair until its paradox is found: Frege's way out lasted 1903–1955. Thm 2.4 shows this costs escalations, never soundness of the conservative verifier.

---

## 6. The robust core: why informal mathematics survived formalization

### 6.1 Sharpenings and the robust-core hypothesis

The user's hypothesis (L10 §1.6) is that pre-formal concepts like "function" were vague. The "rest of the concept" beyond the eventual definition "was untrustworthy/messy … and for this reason unusable whenever people were proving things".

**Definition 6.1.**
* Fix a first-order language $L$, a base theory $T_0$, and a set $W$ of vague words occurring in $\Xi$.
* A **sharpening** σ assigns each $w\in W$ an explicit $L$-definition. $\Sigma$ is the set of **admissible** joint sharpenings; taking them jointly encodes penumbral connections.
* Each σ gives a first-order complete hypothesis $h_\sigma=(L,R_\sigma,\rho_\sigma,\mathrm{Mod}(T_\sigma))$. Here $T_\sigma=T_0$ plus σ's definitions, and $\rho_\sigma$ reads each $w$ by its definition.
* **Supervaluational validity** is ${\models_{\rm SV}}:=\bigcap_{\sigma\in\Sigma}{\models_\sigma}$, and $\mathrm{St}^g_{\rm SV}:=\bigcap_\sigma\mathrm{St}^g_\sigma$ (Fine 1975, via L7) [cited].
* A *precise object* is a model $M\models T_0$. It expands uniquely to $M_\sigma\models T_\sigma$, since the definitions are explicit. A sentence occurrence is *super-determinate* at $M$ if all $M_\sigma$ agree on it.
* **Object data are SV-truthful** if the community reports $v_M(x)$ only for super-determinate $x$. This is how a vague community *can* evaluate a monster.

**Robust-core hypothesis** $\mathrm{RCH}_g$. Every non-noise practice step lies in $\mathrm{St}^g_{\rm SV}$, and every practice link is valid under every σ. *The practice uses only inferences that are valid however its vague words are made precise.*

### 6.2 The theorems

**Theorem 6.2 (robust-core theorem) [proved, TOSU].**
* **(a) Survival.** Under $\mathrm{RCH}_g$, every practice argument is $h_\sigma$-valid for every $\sigma\in\Sigma$. So every accepted theorem with a practice proof is a theorem of every admissible sharpening, whichever one a later formalization adopts. The old proofs survive as written, up to filling gaps of size $g$.
* **(b) The conservative learner learns the robust core.** Suppose $\{h_\sigma\}\subseteq\mathcal H$ and the data are SV-truthful: practice $\subseteq\mathrm{St}^g_{\rm SV}$, designated contexts coherent under every σ, and SV-truthful objects. Then every $h_\sigma$ survives forever. Consequently, at all times, the accepted set of $V^g_t$ is contained in $\mathrm{St}^g_{\rm SV}$, and the verifier is sound for *every* sharpening simultaneously.
* **(c) Nothing more is soundly learnable.** Any acceptance set that is sound whatever the target in $\{h_\sigma\}$ is contained in $\mathrm{St}^g_{\rm SV}$. If $\mathcal H=\{h_\sigma:\sigma\in\Sigma\}$, the verifier's accepted set is *exactly* $\mathrm{St}^g_{\rm SV}$ at all times, so the robust core is the maximal sound acceptance set.
* **(d) The permanent abstention region.** Steps in $\bigcup_\sigma\mathrm{St}^g_\sigma\setminus\mathrm{St}^g_{\rm SV}$ are never accepted. A vague community cannot answer escalations about them. Only a *definition*, which shrinks Σ, removes them.

*Proof.*
* (a) Apply Lemma 2.2 once for each σ.
* (b) Every datum is consistent with each $h_\sigma$. Practice steps are in $\mathrm{St}^g_\sigma$. No paradox exists for a coherent $h_\sigma$. A super-determinate report at $M$ equals $v_{M_\sigma}\circ\rho_\sigma$ on its domain, so it is $h_\sigma$-admissible. Hence $h_\sigma\in\mathrm{VS}_t$, and unanimity gives membership in every $\mathrm{St}^g_\sigma$.
* (c) If $s\in A\setminus\mathrm{St}^g_\sigma$, then $A$ is unsound when the target is $h_\sigma$. When $\mathcal H=\{h_\sigma\}$, by (b) every member survives, so the intersection is $\bigcap_\sigma\mathrm{St}^g_\sigma$.
* (d) Follows from (b) and (c). ∎

**Theorem 6.3 (non-robust steps have monsters) [proved, TOSU].** If $s=(\Gamma\Rightarrow y)\notin{\models_\sigma}$ for some admissible σ, there is a model $M\models T_\sigma$ in which $\rho_\sigma\Gamma$ holds and $\rho_\sigma y$ fails: a σ-*monster*. The proof is Gödel completeness.

*Cauchy, again.* "Converges" has two admissible sharpenings, pointwise and uniform. The step "continuous terms + convergent series ⇒ continuous sum" is valid under σ_unif and invalid under σ_pw. So it is not in the robust core, and Abel's Fourier series is a σ_pw-monster.
* Lakatos's three responses are the three ways to change Σ or the language:
  * *monster-barring*: drop σ_pw from Σ, i.e. define "converges" as uniform convergence;
  * *lemma-incorporation*: add "uniformly" as a premise, which makes the step robust;
  * *proof-generated concept*: introduce a new word whose only sharpening is uniform convergence.
* The robust-core hypothesis predicts *where* pre-formal mathematics broke: exactly at the non-robust steps.

**Proposition 6.4 (only unanimity chains; the sorites is tight) [proved; computed].**
* **(a)** ${\models_{\rm SV}}$ is a consequence relation, being an intersection of consequence relations. So supervaluational validity is closed under chaining.
* **(b)** Let μ be a probability distribution over Σ, for instance over the sharpening that future formalization will adopt. If each step of an $n$-step argument is valid with μ-probability at least $1-\varepsilon$, then the argument is valid with probability at least $1-n\varepsilon$. This is tight: there are $n$-step arguments each of whose steps is valid with probability $1-1/n$, yet the argument is valid under *no* sharpening.

*Proof.*
* (a) Monotonicity and cut hold in each ${\models_\sigma}$, hence in their intersection.
* (b) The bound is Lemma 2.2 per σ plus the union bound. For tightness use the sorites:
  * sentences $q_k$ = "$k$ grains make a heap", for $k=0..n$;
  * sharpenings $\sigma_c$ for $c=1..n$, with $q_k\mapsto k\ge c$, and μ uniform;
  * step $q_k\Rightarrow q_{k-1}$ fails under $\sigma_c$ iff $c=k$, so each step holds with probability $1-1/n$;
  * $q_n$ is true and $q_0$ is false under every $\sigma_c$, so the argument fails under all of them. ∎

`robust_core_and_mdl.py` checks the sorites for $n=3,5,10$, and checks the union bound on 2000 random sharpening models.

Hence "valid on most readings" is to vagueness what majority vote is to verifier ensembles (T2 Thm 2.4, the doctrinal paradox): it does not compose. The robust-core hypothesis in its *unanimous* form is therefore not an arbitrary strengthening. It is the weakest per-step property that composes.

The same sorites chain is also the uninformative paradox of Thm 4.4(c). In both roles it marks the gap between *bag-level* and *element-level* information.

**Proposition 6.5 (how the nice notion of proof came to be there) [proved, TOSU; the content is Gödel completeness].** Assume:
* the practice's initial step repertoire $A_0$ is the image under $\rho^*$ of finitely many informal schemas, a bounded cognitive repertoire;
* the community drops any step refuted by a presented monster, i.e. a model of an r.e. theory $T$ (for one sharpening, or for all of them), and monster presentation is complete.

Then the surviving repertoire is $A_\infty=A_0\cap{\models_T}$. Every argument chained from surviving steps is the $\rho^*$-image of a derivation in any complete calculus for $T$.

*Proof.* A step survives iff no model of $T$ refutes it, iff $T\cup\rho\Gamma\models\rho y$, iff it is derivable, by completeness. For chains, use Lemma 2.2. ∎

This is the model's answer to the user's question "how come mathematicians ended up with such a nice notion of proof?". Three ingredients combine:
1. **Local checkability.** Steps are checked on objects one line at a time (Lemma 4.1). Monster pressure therefore selects for steps that are truth-preserving in every object.
2. **Completeness.** Gödel's theorem turns "truth-preserving in every object of an elementary class" into "derivable in a finite calculus".
3. **Bounded repertoire.** This makes the surviving practice the shadow of finitely many schemas, so the calculus is not merely the set of truths.

The formal proof structure is "sorta there" in the activity because the activity was *selected by objects*, and completeness says that is the same as being shadowed by a calculus. Two caveats:
* complete monster presentation is an idealization, and the selection took centuries (L6's lag table);
* for intended-model semantics such as $\{\mathbb N\}$, ingredient 2 fails. Selection by standard objects then converges toward true arithmetic, which no calculus captures, and the formal notion of proof is a further choice.

**Euclid as a proven instance.**
* Let a "sharpening" of a drawn diagram be any configuration in a perturbation neighbourhood of it.
* *Co-exact* properties (Manders 2008) are exactly the super-determinate ones. Manders's thesis that Euclid reads off only co-exact properties is then $\mathrm{RCH}$ for diagrammatic steps.
* Avigad, Dean & Mumma's system E (2009) is a calculus for that practice, sound and complete for ruler-and-compass semantics [cited]. It is what Thm 6.2(c) says a learner could at best recover.
* Steiner's 7776 is a non-robust "exact" step: a Bézout count valid only for generic configurations, with a degenerate configuration as its monster.

---

## 7. The user's steeper-simplicity-penalty conjecture

L10 (§1.2, T5) records the user's proposal. Score hypotheses by $\lambda\cdot K(h)+\mathrm{NLL}$ with a *steeper* simplicity coefficient λ, so that the MAP hypothesis is "simple model + noise" rather than "model + memorized teacher errors". He conjectures that the good model is "a vertex of the convex hull of the set of attainable (hypothesis complexity, expected neg log likelihood) tuples", and notes that he has not searched for a proof or a pathology.

**Model (additive two-part code).**
* There are candidate rule tags $r\in\mathcal T$ with disjoint supports. Some are valid rules; others are systematic fallacy schemas.
* Of the $N$ data steps, a fraction $\pi_r$ are instances of $r$. Coding them via $r$ rather than as noise saves $g_r>0$ bits each. $\ell(r)$ is $r$'s description length.
* For $R\subseteq\mathcal T$: $J_\lambda(R)=\lambda\sum_{r\in R}\ell(r)+N\sum_{r\notin R}\pi_rg_r+\mathrm{const}$.

**Proposition 7.1 [proved, TOSU].** Up to ties, $\mathrm{MAP}_\lambda=\{r:\ \lambda\ell(r)<N\pi_rg_r\}$. Hence:
* (i) For fixed λ and $N\to\infty$, every systematic error with $\pi_r>0$ is eventually learned. *Imitation with any fixed simplicity weight learns the teacher's systematic mistakes.*
* (ii) With $\lambda=\kappa N$, $r$ is included iff its **compression rate** $\kappa_r:=\pi_rg_r/\ell(r)$ exceeds κ.

*Proof.* $J_\lambda$ is a sum of independent per-rule terms $\min(\lambda\ell(r),N\pi_rg_r)$. ∎

**Corollary 7.2 [proved].** Some steepness κ makes the MAP exactly the set of valid rules iff
$$\min_{r\ \rm valid}\kappa_r>\max_{f\ \rm fallacy}\kappa_f.$$

**Proposition 7.3 (the vertex conjecture fails) [proved; computed].** Take three rules:
* a common valid rule A: $\ell=10$, $\pi=0.5$, $g=8$;
* a rare, long valid rule B: $\ell=40$, $\pi=0.01$, $g=8$;
* the freshman's dream F: $(a+b)^2=a^2+b^2$, with $\ell=8$, $\pi=0.05$, $g=8$.

Then $\kappa_A=0.4$, $\kappa_F=0.05$ and $\kappa_B=0.002$. As κ increases, the MAP passes through {A,B,F}, then {A,F}, then {A}, then ∅. *No* κ selects the true rule set {A,B}. Equivalently, its point is not on the lower convex hull. `robust_core_and_mdl.py` scans κ.

**Assessment.**
* The user's idea is right in a precise sense: a steeper penalty acts as a *frequency-per-bit threshold*, which is T1's Thm 6.4 frequency threshold in MDL clothing.
* It cannot separate rule from error when errors are frequent and short. In student algebra and in Euler-style manipulations they often are.
* The separation comes from the other channels. One evaluation at $a=b=1$ (an object) refutes F, whatever its frequency. Coherence refutes structural fallacies in classical propositional logic (T2 Cor 6.2).
* What survives all three channels is the T2 "Kripkensteinian residue": coherent, object-compatible alternatives, which are alternative meanings rather than errors.

---

## 8. Depth assessment and open problems

| Result | Status | Depth |
|---|---|---|
| Model (§1), verifier soundness (2.4), resource-bounded checking (2.6), expansion (2.8) | proved | TOSU; the value is in the definitions, especially *links* |
| Equivocation (2.3) | proved | trivial, but it names a failure mode that step-level checkers miss |
| Class-prior Ville soundness (2.5) | proved | small twist on T1 |
| Informal completeness lemma (3.3) | proved | standard completeness and Lindenbaum, applied to shadows; conceptually central |
| Identification exactly up to ≈ (3.4) | proved | moderate; (d)'s one-sided granularity is the new observation |
| Transfer / IST / Benacerraf witnesses (3.5–3.7) | proved modulo cited theorems | the depth is in the cited theorems |
| Object halving (4.3) | proved | standard halving |
| Bag lower bounds (4.4, 4.6), bag-size upper bound (4.5) | proved; computed | **genuine content**: exact exponential separation, a sorites realization, linear-in-$r$ adversarial MIL cost |
| Abstract repair theorem (5.1) | proved | TOSU |
| Comprehension toy (5.2) | proved | elementary, but every fact checked; historically suggestive (the NF branch) |
| $2^{\aleph_0}$ maximal repairs (5.4); non-r.e. | proved; cited | easy; the non-r.e. part (Incurvati–Murzi) is deep and not ours |
| Robust-core theorem (6.2), monsters (6.3), sorites tightness (6.4), emergence of proof (6.5) | proved | TOSU; the *hypothesis* RCH is the empirical content |
| Steeper penalty (7.1–7.3) | proved; computed | easy; it answers the user's open question negatively, with the correct positive core |

**The hardest open problem: affordable soundness with language invention.**
* Every positive result assumes realizability ($h^*\in\mathcal H$) in a *fixed* class. Historically the decisive moves enlarged $L$: quantifier structure, ε-δ, uniform convergence, ideals, the fundamental group (L6 §4).
* Realizability can be restored by a universal class: all computable $(L,R,\rho)$ with a description-length prior. Then Thm 2.5 is sound with $W^*\ge2^{-K(h^*)}$. But the escalation cost becomes $\Theta(2^{K(h^*)})$ on unstructured parts of the class (T1 Cor 4.5), and Thm 4.4 shows the paradox channel cannot rescue it.
* The problem is to find a hypothesis class with two properties:
  * (i) it is closed under the definitional extensions history actually made, i.e. new predicates defined by formulas of bounded quantifier rank over the old language;
  * (ii) its escalation dimension, or its correction complexity with object feedback, is polynomial in the description length of the target.

  Alternatively, prove that closure under definitional extension forces antichains of exponential size, as in the single-culprit class, making sound learning with language invention exponentially expensive.
* A partial hope: definitions are themselves schemas, so T1's anti-unification bounds may apply to *definition learning* as they do to rule learning. Whether proof-generated concepts (which name hidden lemmas found by descent) can be learned with $O(\text{depth})$ objects each is the concrete sub-question.

**Other open problems.**
1. *Combinatorics of bags.* Prove $M^{(r)}_{\rm bag}\le r\,M_{\rm obj}$ (Thm 4.5 gives $(r+1)\ln|\mathcal H|$). Find the combinatorial dimension that characterizes $M_{\rm bag}$. It lies strictly between $M_{\rm obj}$ and $\mathrm{el}^*$. Computed: for "$k$ culprits among $n$" it appears to be $n-k$.
2. *Misspecified practice.* When no coherent bounded-gap formalization exists (Leibnizian infinitesimals before 1960), what should the verifier converge to? Candidate: the robust core of the ε-near-optimal realizations. No theorem yet.
3. *Moving readings.* Model the community's ρ as changing in response to monsters (Lakatos dynamics), and prove that MDL with revision costs converges to a fixed point (L6 TC7).
4. *Granularity as evidence.* Does Leibnizian practice at small $g$ prefer IST to Weierstrassian readings (Prop 3.6)? This is empirical, and decidable with DSP-style tooling.
5. *Is RCH true?* It needs a corpus study: annotate 19th-century proofs with admissible sharpenings, and test whether accepted-and-surviving steps are SV-valid while broken ones are not.

---

## 9. Suggested experiments

1. **Objects versus paradoxes on planted fallacies.** In equational algebra practice with $k$ planted fallacy schemas, compare corrections to identification:
   * (a) objects: random numerical evaluation (Schwartz–Zippel) plus descent;
   * (b) ⊥-derivations only, with suspect-step bags.

   Prediction: $\approx k$ versus growth linear in bag size (Thms 4.3–4.6).
2. **Comprehension at scale.** Use a menu of about 50 comprehension formulas, a first-order prover for refutations (e.g. Vampire) and a model finder (e.g. Mace4) for coherence. Compute the maximal coherent uniform repairs, weight instances by counts from Dedekind's *Was sind und was sollen die Zahlen?* and Cantor's papers, and see whether $\mathrm{REP}$ picks a Z-like repair. Check the role of diagonal sets.
3. **Equivocation detection.** Use context-tagged readings for textbook analysis proofs. Plant pointwise/uniform equivocations and check that link-checking catches what step-checking misses (Prop 2.3).
4. **Robust core in Cauchy's *Cours d'analyse*.** Annotate steps with readings of "convergent" and "continuous". Test whether the steps that later broke are exactly the non-SV-valid ones.
5. **The steeper penalty on student-error corpora.** Estimate compression rates of common algebra errors versus rare valid identities, and test Cor 7.2's condition.
6. **A bounded-gap DSP verifier with two readings.** Use ε-δ and infinitesimal (IST-style) formalizations of the same calculus textbook. Measure $g$-step relations and check one-sided granularity identifiability (Thm 3.4(d)).

---

## References

Citations marked (unverified) are from memory and should be checked before publication.
* Avigad, J., Dean, E., Mumma, J. (2009). A formal system for Euclid's *Elements*. *Rev. Symb. Logic* 2(4) (pages unverified).
* Benacerraf, P. (1965). What numbers could not be. *Phil. Review* 74:47–73 (unverified pages).
* Cantor, G. (1891). Über eine elementare Frage der Mannigfaltigkeitslehre. *Jahresber. DMV* 1:75–78 (unverified pages).
* Easwaran, K. (2015). Rebutting and undercutting in mathematics. *Phil. Perspectives* (via L6).
* Fine, K. (1975). Vagueness, truth and logic. *Synthese* 30 (via L7, unverified pages).
* Holmes, M. R. New Foundations is consistent. arXiv:1503.01406 (v23, 2025; later co-authorship and the Lean verification unverified).
* Incurvati, L., Murzi, J. (2017). Maximally consistent sets of instances of naive comprehension. *Mind* 126(502):371–384.
* Jiang, A. et al. (2023). Draft, sketch, and prove. ICLR (via L8).
* Lakatos, I. (1976). *Proofs and Refutations*. CUP.
* Manders, K. (2008). The Euclidean diagram. In Mancosu (ed.), *The Philosophy of Mathematical Practice*, OUP.
* McGee, V. (1992). Maximal consistent sets of instances of Tarski's schema (T). *J. Phil. Logic* 21 (unverified).
* Nelson, E. (1977). Internal set theory: a new approach to nonstandard analysis. *Bull. AMS* 83:1165–1198.
* Quine, W. V. (1937). New foundations for mathematical logic. *Amer. Math. Monthly* 44 (unverified pages).
* Robinson, A. (1966). *Non-standard Analysis*. North-Holland.
* Sabato, S., Tishby, N. (2012). Multi-instance learning with any hypothesis class. *JMLR* 13 (via L8; bound form unverified).
* Shapiro, E. (1983). *Algorithmic Program Debugging*. MIT Press (via L6).
* Specker, E. (1953). The axiom of choice in Quine's New Foundations. *PNAS* 39 (unverified).
* Ville, J. (1939). *Étude critique de la notion de collectif*.
* Weber, K., Mejía-Ramos, J. P. (2011). Why and how mathematicians read proofs. *Educ. Stud. Math.* 76 (via L6).
* Zermelo, E. (1908). Untersuchungen über die Grundlagen der Mengenlehre I. *Math. Ann.* 65:261–281.
* Project files: T1 (Thms 3.2, 3.9, 4.2, 4.4, Cor 4.5), T2 (Thms 2.2, 2.4, Cor 6.2), L6, L7, L8 (TC4, TC8), L10.
