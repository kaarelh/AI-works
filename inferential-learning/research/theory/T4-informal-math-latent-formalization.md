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

1. **A bounded-gap verifier that is sound against adaptive provers (§2).** The verifier accepts an informal step iff it is $g$-valid under *every* surviving latent formalization $(L,R,\rho,\mathbb M)$, and it checks *links* (re-uses of a sentence across contexts) the same way. This verifier is deterministically sound against every prover whenever the target is in the class (Thm 2.4). With noisy practice data, the Bayesian version is sound with probability $\ge1-\delta'$ at all times (Thm 2.5). Its threshold depends on the prior mass of the target's *observational-equivalence class*, not of the target itself: redundant formalizations with the same $g$-shadow, such as the ontological variants of Prop 3.5, help. *(Revised after verification: the class is the $\equiv_g$-class, not the whole meaning class.)*
   * Checking steps without checking links is unsound. Equivocation is a separate failure mode, and Cauchy's sum theorem is an instance of it (Prop 2.3).
   * Oracle-answered escalations are bounded by the elasticity of the induced class of informal step relations (Thm 2.7). With an "expand this step" protocol, the verifier becomes complete once the atomic steps are identified (Prop 2.8).

2. **Identifiability up to informal-validity equivalence (§3).**
   * An *informal completeness lemma* (Lemma 3.3) shows that, for first-order hypotheses whose informal fragment is closed under negation, the informal consequence relation $\models_h$ determines both the admissible object valuations and coherence. This is a precise version of the user's "philosophical completeness theorem". It is a standard corollary of compactness and completeness.
   * Consequently, closure-level data identify a latent formalization **exactly up to ≈** (same informal consequence relation on the practice's domain), and no finer (Thm 3.4(a)–(c)).
   * With bounded-gap data, the conservative verifier converges to exactly $h^*$'s $g$-step relation. Meaning is then only *bracketed*: practice bounds it from below, by chains of observed short steps, and objects bound it from above. It is identified when $h^*$ is step-expressive on the practice's domain. Otherwise rivals with strictly *weaker* meaning survive (Thm 3.4(d), revised after verification).
   * Witnesses that the ≈-classes are large: in all three cases the readings differ in ontology but not in informal meaning.
     * Robinson's transfer: whether the intended reals contain infinitesimals is unidentifiable at every gap (Prop 3.5).
     * ε-δ versus internal set theory, on occurrences with standard parameters (Prop 3.6).
     * von Neumann versus Zermelo numerals (Prop 3.7).
   * I argue that ≈ is the inferentialist-correct notion of "same meaning" (§3.4).

3. **Counterexample objects give step-level blame, and that is worth exponentially more than paradoxes (§4).**
   * *Descent along false lines* turns a global counterexample into a refuted step or an equivocating link in at most depth-many evaluations (Lemma 4.1).
   * In the online correction game, object feedback needs at most $\lfloor\log_2|\mathcal H|\rfloor$ corrections, and at most $\log_2(1/w([h^*]))$ with a prior (Thm 4.3). This is classical halving: the object game is Littlestone's mistake-bound model, and its exact value is the Littlestone dimension.
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
   * Coverage of practice selects among them. A practice that uses all five Dedekind–Cantor set operations (∩, ∪, pairs, difference, ∅) selects the *stratified* (NF-like) repair, under the stipulated description lengths. A purely positive practice (∩, ∪, pairs) selects the positive repair instead. Adding Zermelo's 1908 diagonal subsets $\{x\in a:x\notin x\}$ (his theorem that no set contains all its subsets) selects the Zermelo-like repair. With Frege's universal extension also in practice, the choice is decided by usage weights. *(Revised after verification: the original claim covered every sub-support, which is false.)*

   At the instance level, naive comprehension has $2^{\aleph_0}$ maximal consistent subsets (Prop 5.4, full proof). Incurvati & Murzi (2017) show that, under minimal assumptions, none of them is recursively axiomatizable [cited].

5. **The robust-core theorem (§6).** Model vague pre-formal concepts by admissible sharpenings, and practice's "robust core" by supervaluational validity. Then:
   * Every practice proof is valid in every admissible sharpening. Hence it survives *every* future formalization that is one of those sharpenings, which explains why informal mathematics survived formalization.
   * The conservative verifier never accepts beyond the robust core $\mathrm{St}^g_{\rm SV}$. With a finite class and complete practice, it converges to that core. No acceptance set that is $g$-sound for every admissible sharpening is larger. At closure level, no acceptance set sound for every sharpening exceeds ${\models_{\rm SV}}$ (Thm 6.2, revised after verification).
   * Steps invalid under some sharpening have monsters (Thm 6.3).
   * "Valid in most sharpenings" does *not* chain. The sorites is the tight counterexample to the union bound, a known fact re-derived here (Prop 6.4).
   * A selection-plus-completeness argument partly answers the user's "how did the nice notion of proof come to be there?" (Prop 6.5). It explains why surviving steps are *derivable*. It explains why they are *short* only under an extra hypothesis: selection acts on schemas, and the surviving schemas are uniformly derivable (revised after verification).

6. **The user's steeper-simplicity-penalty conjecture (§7).** In an additive two-part-code model, a penalty $\lambda=\kappa N$ includes a rule iff its *compression rate* (frequency × per-use saving ÷ description length) exceeds κ. So the proposal separates valid rules from systematic errors iff every fallacy compresses the practice less, per bit, than every valid rule. This fails for a frequent, short fallacy (the freshman's dream) next to a rare, long valid rule. The user's "vertex of the convex hull" conjecture is therefore false in general [proved; computed]. It does hold in his own motivating regime of rare, expensive, idiosyncratic errors (T5 Thm 3.5). Objects remove such fallacies regardless.

**Depth, honestly (§8).** Most theorems here are TOSU. Their value lies in fixing definitions under which history becomes a theorem.
* The parts with real mathematical content: the bag side of the object-versus-bag separation, with its sorites realization and the linear-in-$r$ lower bound; the comprehension-toy facts. The object side is classical halving and Littlestone dimension. The informal completeness lemma is a standard corollary of completeness. The sorites tightness of the union bound is standard (Adams; Edgington). *(Revised after verification.)*
* The deep parts are cited: Incurvati–Murzi non-recursiveness; Nelson's conservativity and reduction algorithm; Robinson's transfer; Gödel completeness.
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
* $s$ is **$g$-valid under $h$**, written $s\in\mathrm{St}^g_h$, iff in addition $\rho_h(y)$ has an $R_h$-derivation from $\rho_h\Gamma$ with at most $g$ rule applications and with all formulas of size at most a fixed function of $g$ and the input. The size bound makes $\mathrm{St}^g_h$ decidable under the following **effectivity assumptions**, which are in force wherever decidability is used:
  * $\rho_h$ is computable with decidable domain;
  * $R_h$ is a decidable set of steps (a decidable library);
  * derivations use only symbols of the input plus a finite, computably given part of $L_h$ that depends on $g$ (this matters when $L_h$ has infinitely many symbols).

  All results use only two facts: $\mathrm{St}^g_h$ is decidable, and $\mathrm{St}^g_h\subseteq{\models_h}$.
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

The human data are thus **noisy images of short derivations under an unknown reading**. Larger steps, those $h^*$-valid but not $g$-valid, also occur in real practice. The model routes them out of (P). A step that is not $g$-short is either escalated with a request to expand it (Prop 2.8), or, if it enters the data stream, it counts as noise of probability η. *(Made explicit after verification.)* A noise-free larger step in (P) would refute $h^*$ under the $\mathrm{St}^g$ labels of §2.1. So Thms 2.4 and 2.5 assume that (P) lies in $\mathrm{St}^g_{h^*}$, up to the noise that is modelled.

### 1.4 The three feedback channels

* **(P) Practice.** The stream of §1.3. Escalation answers ("is this step acceptable?") are also practice data, labelled by $h^*$.
* **(C) Coherence.** There is a family $\mathcal A$ of finite **designated contexts** $A\subseteq X$ that the community asserts, such as accepted background and axioms, with the promise that $\bot\notin\mathrm{Cl}_{R^*}(\rho^*A)$.
  * A **paradox for $h$** is an $R_h$-derivation of ⊥ from $\rho_hA$ for some $A\in\mathcal A$. It refutes $h$.
  * Paradoxes are found by search, so refutation is semi-decidable.
  * Suppositional contexts are *not* designated, so reductio is never penalized (orchestrator idea 1; T2 §1).
* **(O) Objects.** An object datum is a finite partial valuation $v:X\rightharpoonup\{0,1\}$, together with the promise that $v$ is $h^*$-admissible: $v\subseteq u$ for some $u\in\mathcal V_{h^*}$.
  * In the interactive form, the learner holds an object $o$ (a specific function, polyhedron or configuration) and may query $v_o(x)$ for occurrences $x$ of its choice. This is "checking the step on an example" (Weber & Mejía-Ramos 2011, via L6 §3).
  * $h$ is refuted by $v$ iff $v$ extends to no member of $\mathcal V_h$. When $\mathrm{dom}\,v\not\subseteq\mathrm{dom}\,\rho_h$, see the convention below.
  * **Computation** is the special case of a fixed intended object $M_0\in\mathbb M^*$ queried on a decidable fragment $X_{\rm dec}$. Euler's six-decimal value of $\sum1/n^2$ is a datum $v_{M_0}(\text{"}\sum 1/n^2\in[1.64493,1.64494]\text{"})=1$.

**Convention for partial readings** (added after verification). Readings are partial, and different hypotheses have different domains. For $A\not\subseteq\mathrm{dom}\,\rho_h$, put $\rho_hA:=\rho_h(A\cap\mathrm{dom}\,\rho_h)$: a sentence that $h$ cannot read asserts nothing under $h$. So "paradox for $h$ from $A$" and "$h$ is coherent on $A$" refer to $A\cap\mathrm{dom}\,\rho_h$. Likewise an object datum $v$ refutes $h$ iff $v|_{\mathrm{dom}\,\rho_h}$ extends to no member of $\mathcal V_h$.

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

$\mathrm{VS}_t$ denotes the hypotheses not yet refuted. Refutation searches are budgeted, so membership of a given $h$ in $\mathrm{VS}_t$ is decidable from the data whenever $\mathrm{St}^g_h$ is decidable. The verifier $V^g_t$ below is computable when $\mathcal H$ is finite. For infinite $\mathcal H$, $\mathrm{VS}_t$ can be infinite, and then the unanimity test of Def 2.1 is a $\Pi_1$ condition that needs infinitely many certificates. The effective version is the truncated Bayesian verifier of Prop 2.6. *(Corrected after verification: the earlier text claimed computability for enumerable $\mathcal H$.)* $\mathrm{VS}_t$ may contain incoherent hypotheses whose paradox has not yet been found. Frege's 1903 "way out" was such a hypothesis until Leśniewski showed it inconsistent (1938, reported by Sobociński 1949), and Quine independently showed the same (1955) (L6 §1; the Leśniewski–Sobociński dates are from memory, unverified).

**Definition 2.1 (verifier $V^g_t$).** On a query $q$, which is an informal step or a link:
* ACC if $q$ is $g$-valid (resp. link-valid) under **every** $h\in\mathrm{VS}_t$, with a certificate (a derivation) for each;
* otherwise ESC: ask the community or oracle, or ask the prover to expand $q$ (Prop 2.8).

A rejection rule (REJ when no survivor accepts) may be added. Soundness never needs it.

**Lemma 2.2 (argument soundness) [proved; standard, cf. T1 Lemma 1.1] (domain condition added after verification).** Suppose every line of α lies in $\mathrm{dom}\,\rho_h$. This is automatic for every line that occurs in a valid inference or link; only unused premises can violate it, and they can be dropped. Suppose further that every inference line and every link of α is valid under $h$. Then every line $y_j$ satisfies $\rho_h(y_j)\in\mathrm{Cl}_{R_h}(\rho_h(\mathrm{Prem}\,\alpha))$, so $(\mathrm{Prem}\,\alpha\Rightarrow y_j)\in{\models_h}$. Hence in every $M\in\mathbb M_h$ in which the premises are true, every line is true.

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
* The overall step $\{1,2\}\Rightarrow6$ is $h$-invalid. Abel's series $\sum(-1)^{n+1}\sin(nx)/n$, or the Fourier series of a square wave, is a countermodel. ∎

So the verifier must check links, as Definition 2.1 does. Lakatos's "hidden lemma" in Cauchy's proof is, in this model, an *invalid link*. Seidel's and Stokes's 1847 diagnoses name the reading on which the step fails: non-uniform convergence, which they called "arbitrarily slow" or "infinitely slow". *(Wording corrected after verification.)* The term "uniform convergence" is usually credited to Gudermann and Weierstrass (historical attribution from memory, unverified).

### 2.2 Soundness against adaptive provers

The prover is any strategy: randomized, adaptive, computationally unbounded. It knows $h^*$, the verifier's code and the history. It does not know future data.

**Theorem 2.4 (deterministic soundness) [proved, TOSU].** Assume (BG1) and noise-free, truthful data on all channels, with (P) contained in $\mathrm{St}^g_{h^*}$ (§1.3). Then for every prover, at every time $t$:
* every step or link accepted by $V^g_t$ is $h^*$-valid;
* hence (Lemma 2.2) the conclusion of every argument assembled from accepted items is $h^*$-valid from its premises. Any unused premises outside $\mathrm{dom}\,\rho^*$ are dropped. The conclusion is true in every $M\in\mathbb M^*$ that satisfies the premises.

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

**Remark (gauge redundancy helps) (revised after verification).** $W^*$ is the prior mass of the $\equiv_g$-class of $h^*$. Its members are the formalizations with the same $g$-step relation, the same admissible valuations and the same coherence. Two kinds of variant contribute to $W^*$:
* renamings;
* ontological variants. Prop 3.5 gives $h\equiv_gh'$ for every $g$, for example for standard and nonstandard intended reals.

Equivalent axiomatizations and the ε-δ and infinitesimal readings (Prop 3.6) generally change derivation lengths, and so change $\mathrm{St}^g$. They contribute only if their $g$-step relations happen to coincide. They do share the ≈-class, and the mass of the ≈-class is what matters for a closure-level verifier. That verifier has $\mathrm{St}^g$ replaced by ${\models}$ and likelihoods measurable for $\equiv_\infty$, which equals ≈ by Thm 3.4(a). So at gap $g$, soundness is paid for at the level of *$g$-shadows*. These sit between formalizations and meanings.

**Proposition 2.6 (resource-bounded checking preserves soundness) [proved, TOSU].** Suppose the verifier, for each hypothesis, runs a budgeted proof search for the step (e.g. a hammer within Draft-Sketch-Prove; Jiang et al. 2023) and counts "not found" as "not valid". Then its accepted set is a subset of the idealized one, so Thms 2.4 and 2.5 still hold. For countable $\mathcal H$ it suffices to search under the finitely many hypotheses that carry posterior mass $>1-\delta$, and to treat the rest as rejecting.

*Proof.* Acceptance requires certificates, and a certificate is a derivation, so it implies validity. Shrinking the accepted set preserves soundness. ∎

This is TC3 of L6 and TC8 of L8, made exact. *A learner that proposes expansions and checks them exactly is sound by construction, and the remaining risk is global:* is the true formalization in the class, and have its rivals been eliminated?

### 2.3 Costs: escalation, ambiguity, expansion

Let $\mathcal H^g=\{\mathrm{St}^g_h:h\in\mathcal H\}$ be the induced class of informal step relations. Let $\mathrm{el}(\mathcal H^g,\mathrm{St}^g_{h^*})$ be T1's positive elasticity: the longest chain of $h^*$-valid steps each outside the intersection of the hypotheses that contain the previous ones.

**Theorem 2.7 (escalation costs) [proved by reduction to T1] ((c) and the counting convention revised after verification).** Let the prover be honest, i.e. submit only $h^*$-$g$-valid steps. Count only escalations that the oracle answers. An escalation resolved by asking the prover to expand yields no label and shrinks no version space, so these bounds do not cover it.
* (a) With noise-free data, the number of escalations is at most $\mathrm{el}(\mathcal H^g,\mathrm{St}^g_{h^*})\le|\mathcal H/{\equiv_g}|-1$.
* (b) For the Bayesian verifier with a deterministic oracle, the number of escalations is at most $(\ln(1/W^*)+\ln(1/\delta''))/\delta$, with probability $\ge1-\delta''$.
* (c) (a) is tight: on the single-culprit class of §4 it equals $|\mathcal H|-1$. (b) is tight only up to a factor $O\big((\ln(1/W^*)+\ln(1/\delta''))/\delta'\big)$ when $\delta=W^*\delta'$. On that class with the uniform prior, every $\delta'$-sound verifier needs at least $(1-\delta')(1/W^*-1)$ escalations (T1 Cor 4.5).

*Proof.* The informal steps form a step universe in T1's sense, and $\mathcal H^g$ is a class of step sets. Hence:
* (a) is T1 Thm 3.2: escalated honest steps form an elastic chain, and each answer removes at least one $\equiv_g$-class;
* (b) is T1 Thm 4.4 with the class prior of Thm 2.5;
* (c) is T1 Thm 3.9 for (a), and T1 Cor 4.5 for (b). ∎

**Proposition 2.8 (expansion makes the verifier complete) [proved, TOSU].** Call $h^*$ **step-expressive** if every $R^*$-derivation between ρ*-images can be rewritten as a chain of informal steps, each the $\rho^*$-image of a *single* rule application: a 1-valid step. Suppose step-expressiveness holds, and every survivor agrees with $h^*$ on 1-validity, i.e. the atomic informal rules have been identified (e.g. by T1's schema learning). Then for every $h^*$-valid step there is an argument, using only steps and links that $V^1_t$ accepts, that derives its conclusion from its premises.

*Proof.* Take the expansion that step-expressiveness provides. Every line is a 1-step accepted by unanimity, and every link joins identical readings. ∎

The hypothesis "every survivor agrees with $h^*$ on 1-validity" can be weakened to $\bigcap_{h\in\mathrm{VS}_t}\mathrm{St}^1_h\supseteq\mathrm{St}^1_{h^*}$. Each link of the expansion is a 0-application step, so it lies in $\mathrm{St}^1_{h^*}$. Under complete presentation, the weakened hypothesis is what Thm 3.4(d) delivers at $g=1$. *(Remark added after verification.)*

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

**Proposition 3.2 (no learner sees past the shadow) [proved, TOSU] (assumptions and proof added after verification).** Assume the data-generating process depends on the target only through its shadow:
* (i) the law of the practice data is a function of $\mathrm{St}^g_{h^*}$ and the history (shadow-measurability);
* (ii) escalation and link answers are $\mathrm{St}^g_{h^*}$-labels;
* (iii) the law of the object data is a function of $\mathcal V_{h^*}$ and the history. This covers which occurrences are presented or queried, and their values;
* (iv) the designated family $\mathcal A$ does not depend on the target, and a paradox for a hypothesis $h$ depends only on $h$ and $A$.

If $h\equiv_gh'$, then every data sequence that can occur when the target is $h$ can also occur when the target is $h'$, with the same probability. Hence every learner behaves identically on the two, and no learner identifies the target more finely than $\equiv_g$.

The **closure-level version** replaces $\mathrm{St}^g$ by ${\models}$ in (i) and (ii), and $\equiv_g$ by $\equiv_\infty$.

*Proof.* Induction on the length of the history. Given a history, the conditional law of the next datum is, by (i)–(iv), a function of the shadow, the history and the queries issued. The learner's and prover's queries are themselves functions of the history and their own coins. Equal shadows therefore give equal conditional laws at every step, hence equal joint laws of the whole data sequence. A learner's output is a randomized function of the data, so its law is the same under $h$ and $h'$. ∎

### 3.2 The informal completeness lemma

Call $\mathrm{dom}\,\rho_h$ **negation-closed** if:
* there is an informal operation $x\mapsto{\sim}x$ ("it is not the case that …", performed in the same context) with $\mathrm{dom}\,\rho_h$ closed under it;
* $T_h\vdash\rho_h({\sim}x)\leftrightarrow\neg\rho_h(x)$.

**Lemma 3.3 (informal completeness) [proved; a standard corollary of compactness and Gödel completeness] ((iii) and the gloss corrected after verification).** Let $h$ be first-order complete with negation-closed domain $D_h=\mathrm{dom}\,\rho_h\neq\emptyset$. Define the **coherent valuations of $\models_h$** to be the maps $v:D_h\to\{0,1\}$ such that:
* $v({\sim}x)=1-v(x)$ for every $x$;
* whenever $\Gamma\subseteq v^{-1}(1)$ is finite and $\Gamma\models_hy$, we have $v(y)=1$.

Then:
* (i) $\mathcal V_h$ is exactly the set of coherent valuations of $\models_h$.
* (ii) $\Gamma\models_hy$ iff $\Gamma\cup\{y\}\subseteq D_h$ and every $v\in\mathcal V_h$ with $v(\Gamma)=1$ has $v(y)=1$.
* (iii) A designated $A\subseteq D_h$ is $h$-coherent iff some $v\in\mathcal V_h$ has $v(A)=1$, iff $A\not\models_hy$ for some $y\in D_h$.

So $\models_h$ determines $\mathcal V_h$ and the coherence of every $A$. Conversely:
* $\mathcal V_h$ determines $\models_h$ when $\mathcal V_h\neq\emptyset$, since $D_h$ is then the common domain of its members, and (ii) applies;
* coherence of *all* finite subsets of $D_h$ determines $\models_h$: for $\Gamma\cup\{y\}\subseteq D_h$, $\Gamma\models_hy$ iff $\Gamma\cup\{{\sim}y\}$ is incoherent.

Neither converse holds unconditionally. If $T_h$ is inconsistent, $\mathcal V_h=\emptyset$ does not reveal $D_h$. And coherence on a fixed designated family $\mathcal A$ does not determine $\models_h$.

*Novelty.* The classical-negation-respecting valuations closed under a first-order consequence relation are exactly the model-induced ones. The lemma is a direct corollary of this standard fact, i.e. of Lindenbaum, compactness and completeness. Its role here is conceptual, not technical.

*Proof.*
* (i) ⊆. If $M\models T_h$ and Γ is true in $M$ (via $\rho_h$), then $\Gamma\models_hy$ gives $M\models\rho_h(y)$. Negation follows from the biconditional.
* (i) ⊇. Let $v$ be coherent and $\Theta:=T_h\cup\{\rho_h(x):v(x)=1\}$.
  * Suppose Θ were inconsistent. By compactness, some finite $\Gamma\subseteq v^{-1}(1)$ has $T_h\cup\rho_h\Gamma$ inconsistent, hence $\Gamma\models_hy$ for every $y\in D_h$. Pick any $x\in D_h$. One of $x,{\sim}x$ has $v$-value 0; call it $y$. Then $\Gamma\models_hy$ forces $v(y)=1$, a contradiction.
  * So Θ has a model $M$. For $v(x)=1$ we get $M\models\rho_h(x)$. For $v(x)=0$ we have $v({\sim}x)=1$, so $M\models\neg\rho_h(x)$. Thus $v=v_M\circ\rho_h$.
* (ii) ⇒ is soundness. For ⇐: if $\Gamma\not\models_hy$ with $\Gamma\cup\{y\}\subseteq D_h$, then $T_h\cup\rho_h\Gamma\cup\{\neg\rho_hy\}$ is consistent by completeness. A model of it gives $v\in\mathcal V_h$ with $v(\Gamma)=1$ and $v(y)=0$.
* (iii) $A$ is coherent iff $T_h\cup\rho_hA$ is consistent iff it has a model. For the second equivalence: if $A$ is coherent, pick $x\in D_h$. In a model of $T_h\cup\rho_hA$, one of $x,{\sim}x$ is false; call it $y$. Then $A\not\models_hy$. Conversely, if $T_h\cup\rho_hA$ is inconsistent, then $A\models_hy$ for every $y\in D_h$, by ex falso. ∎

This is the user's "philosophical completeness theorem" ("a mode of talking makes sense (is coherent) iff there is something it could be talking about", L10 §1.5) for informal shadows. *The coherent ways of evaluating the practice's sentences are exactly the admissible objects.* The caveat he already knows is visible in the hypothesis: $\mathbb M_h=\mathrm{Mod}(T_h)$ includes non-standard models. If only standard objects are ever presented, channel (O) sees less than $\mathcal V_h$, and true-but-unprovable strengthenings such as $T+\mathrm{Con}(T)$ survive. These are not errors about truth, but they *are* over-generalizations of the practice's validity relation.

### 3.3 The identifiability theorem

**Theorem 3.4 (identification up to ≈ on the practice's domain) [proved] ((d) revised after verification; hypotheses of (a)–(c) made explicit).** Let every $h\in\mathcal H$ be first-order complete with negation-closed, *nonempty* domain (one fixed informal negation). Let $D^*=\mathrm{dom}\,\rho^*$, let $T^*$ be consistent, and let the designated contexts lie in $D^*$.
* **(a) Shadows coincide with meaning.** $h\equiv_\infty h'$ iff $h\approx h'$, by Lemma 3.3. Nonempty domains are needed. Counterexample: with empty readings, a consistent and an inconsistent theory have the same (empty) $\models$ but different $\mathcal V$.
* **(b) Nothing finer.** By the closure-level version of Prop 3.2, no learner using closure-level data identifies the target more finely than ≈.
* **(c) Exact identification of meaning.** Let $\mathcal H$ be finite with $h^*\in\mathcal H$. Let the presentation be **complete**: every element of ${\models_{h^*}}$ appears in (P), and every finite restriction of every member of $\mathcal V_{h^*}$ appears in (O). Then after finitely many data, the survivors are exactly
  $$U^*=\{h\in\mathcal H:\ h\approx_{D^*}h^*\},$$
  and the accepted relation of the closure-level conservative verifier $V^\infty$ (unanimity on $\models_h$) on $D^*$ equals ${\models_{h^*}}$.
  * This is a statement about the *ideal* version space. Refuting $h$ by a practice datum $s$ requires certifying $s\notin{\models_h}$. That is co-r.e., and not semi-decidable for, e.g., $T_h=\mathrm{ZFC}$. So (c) is information-theoretic, not effective, unlike the budgeted $\mathrm{VS}_t$ of §2.1.
  * In (d), by contrast, practice refutation is decidable, and object and paradox refutations are semi-decidable. There the budgeted version space reaches the ideal survivors after finitely many data and finite budget.
* **(d) Bounded-gap data (revised after verification).** Suppose instead that (P) presents $\mathrm{St}^g_{h^*}$ completely, with (O) and (C) as in (c). Then the eventual survivors are exactly
  $$S^g:=\{h\in\mathcal H:\ \mathrm{St}^g_h\supseteq\mathrm{St}^g_{h^*}\ \text{ and }\ {\models_h}|_{D^*}\subseteq{\models_{h^*}}\},$$
  and the accepted relation of $V^g$ equals $\mathrm{St}^g_{h^*}$ exactly. Every survivor's meaning on $D^*$ is bracketed:
  $$\mathrm{Ch}_{D^*}(\mathrm{St}^g_{h^*})\ \subseteq\ {\models_h}|_{D^*}\ \subseteq\ {\models_{h^*}}.$$
  Here $\mathrm{Ch}_{D^*}(S)$ is the set of steps $(\Gamma\Rightarrow y)$ derivable from Γ by an argument whose lines lie in $D^*$ and whose inferences and links lie in $S$.
  * Call $h^*$ **step-expressive on $D^*$ at gap $g$** if $\mathrm{Ch}_{D^*}(\mathrm{St}^g_{h^*})={\models_{h^*}}$. Prop 2.8's step-expressiveness implies this for every $g\ge1$. In that case $S^g=\{h\in U^*:\mathrm{St}^g_h\supseteq\mathrm{St}^g_{h^*}\}$, which was the original claim, and meaning is identified.
  * Without step-expressiveness, survivors can have *strictly weaker* meaning, so $S^g\not\subseteq U^*$. *The original statement, "the survivors are exactly the $h\in U^*$ with $\mathrm{St}^g_h\supseteq\mathrm{St}^g_{h^*}$", is false in general.* Counterexample (a referee's, re-checked): take propositional readings of $p_0,\neg p_0,p_3,\neg p_3$ as $D^*$. Let $T^*=\{p_0\to p_1,p_1\to p_2,p_2\to p_3\}$, with axiom steps plus one-step tautological consequence. Let the rival have $T_h=\emptyset$, and let $g\le3$. Then $\mathrm{St}^g_h=\mathrm{St}^g_{h^*}$ on $D^*$, since $p_0\Rightarrow p_3$ needs 4 rule applications. But $(p_0\Rightarrow p_3)\in{\models_{h^*}}\setminus{\models_h}$. Objects and coherence never refute the rival, because $\mathrm{Mod}(T^*)\subseteq\mathrm{Mod}(\emptyset)$. Brute force over 2604 random (target, rival) pairs gives three results [computed: `T4-checks/verification_checks.py` V1]:
    * the original (d) mismatches the true survivors in 527 pairs;
    * the revised (d) mismatches in none;
    * the original (d) mismatches in none of the 1545 pairs whose target is step-expressive.

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

(d) (Proof revised after verification.) The original proof said "Case 2 is unchanged". That is where it broke: Case 2 in (c) used ${\models_{h^*}}\subseteq{\models_h}$, which (d)'s practice data no longer supply. The corrected argument has four steps.
* *Practice.* Complete presentation refutes exactly the $h$ with $\mathrm{St}^g_{h^*}\not\subseteq\mathrm{St}^g_h$. For each $x\in D^*$, $(\{x\}\Rightarrow x)\in\mathrm{St}^g_{h^*}$ (0 applications), so practice survivors have $D_h\supseteq D^*$.
* *Objects.* Let $\mathrm{St}^g_h\supseteq\mathrm{St}^g_{h^*}$. We show that some object datum refutes $h$ iff ${\models_h}|_{D^*}\not\subseteq{\models_{h^*}}$.
  * (⇐) This is Case 2 of (c), which never used ${\models_{h^*}}\subseteq{\models_h}$. Take $s=(\Gamma\Rightarrow y)\in{\models_h}\setminus{\models_{h^*}}$ on $D^*$. Lemma 3.3(ii) for $h^*$ gives $u\in\mathcal V_{h^*}$ with $u(\Gamma)=1$ and $u(y)=0$. Its restriction to $\Gamma\cup\{y\}$ is presented and refutes $h$.
  * (⇒) Suppose ${\models_h}|_{D^*}\subseteq{\models_{h^*}}$. Let $v$ be the restriction of some $u\in\mathcal V_{h^*}$ to a finite $F\subseteq D^*$, and put $\Gamma_v:=\{x\in F:v(x)=1\}\cup\{{\sim}x:x\in F,\ v(x)=0\}\subseteq D^*$. Suppose $v$ extended to no member of $\mathcal V_h$. Then $T_h\cup\rho_h\Gamma_v$ would be inconsistent, since a model of it yields an extension. So $\Gamma_v\models_hx$ and $\Gamma_v\models_h{\sim}x$ for any $x\in D^*$. Hence $\Gamma_v\models_{h^*}x$ and $\Gamma_v\models_{h^*}{\sim}x$. But $u$ makes $\Gamma_v$ true, so by soundness it makes both $x$ and ${\sim}x$ true, which is impossible.
* *Coherence.* If ${\models_h}|_{D^*}\subseteq{\models_{h^*}}$ and $h$ were incoherent on a designated $A\subseteq D^*$, then $A\models_hx$ and $A\models_h{\sim}x$, so $h^*$ would be incoherent on $A$. That contradicts the promise. So paradoxes refute no member of $S^g$.
* *Conclusion.* By finiteness of $\mathcal H$, after finitely many data the survivors are exactly $S^g$.
  * $h^*\in S^g$, and every survivor contains $\mathrm{St}^g_{h^*}$, so the intersection of the survivors' $g$-step relations is $\mathrm{St}^g_{h^*}$.
  * Bracketing: the upper bound holds by definition of $S^g$. For the lower bound, apply Lemma 2.2 for $h$ to an argument through $D^*\subseteq D_h$ whose items lie in $\mathrm{St}^g_{h^*}\subseteq\mathrm{St}^g_h\subseteq{\models_h}$.
  * Under step-expressiveness the two bounds meet, so ${\models_h}|_{D^*}={\models_{h^*}}$, i.e. $h\in U^*$. ∎

**What (d) says (revised after verification).** Bounded-gap data identify $h^*$'s *$g$-step relation* exactly, and they bracket its meaning. Practice bounds meaning from below, by the chains of observed short steps. Objects bound it from above, since they refute a hypothesis for validating too much, never for validating too little. Two kinds of rival are never excluded by positive bounded-gap data.
* **Coarser rivals** make the same inferences in coarser steps: a strict superset of $g$-steps, with the same meaning. This is Gold's asymmetry, now about obviousness rather than validity. Negative escalation answers ("this is not one obvious step") would remove them; positive practice cannot.
* **Weaker rivals** exist when $h^*$ is not step-expressive on $D^*$. They validate all of $h^*$'s short steps but strictly fewer inferences overall: a different, weaker meaning. Valid inferences of $h^*$ that are not chains of its short steps through sentences the practice uses are invisible to both channels.

So realistic practice (BG2) fixes meaning only when its long inferences decompose into short steps through its own sentences. The expansion protocol of Prop 2.8 is the corresponding remedy. Occurrences outside $D^*$ (sentences the practice never uses) are never constrained. That is §6's robust core seen from the identifiability side.

### 3.4 Witnesses: different ontologies, same informal meaning

**Proposition 3.5 (transfer: ontology is unidentifiable at every gap) [proved, modulo the cited transfer principle] (hypothesis weakened after verification so that the instance satisfies it).** Let $h=(L,R,\rho,\mathbb M)$ and $h'=(L,R,\rho,\mathbb M')$ both be latent formalizations, so that $R$ is sound for both $\mathbb M$ and $\mathbb M'$. Suppose every member of $\mathbb M'$ agrees with some member of $\mathbb M$ on every sentence in $\rho(\mathrm{dom}\,\rho)$, and vice versa. Then $h\equiv_gh'$ for every $g$, and $h\equiv_\infty h'$.

For instance, let $L$ be a countable sublanguage of the ∈-language of the superstructure over $\mathbb R$, with constants for the standard objects the practice can name. Let ρ read informal analysis into bounded $L$-sentences, as usual. Let $R$ be first-order logic with, as axioms, bounded $L$-sentences true in $V(\mathbb R)$. Take $\mathbb M=\{V(\mathbb R)\}$ and $\mathbb M'=\{{}^*V(\mathbb R)\}$, a nonstandard enlargement with standard constants interpreted by $*$. By Robinson's transfer principle (Robinson 1966; Łoś's theorem) [cited], the two satisfy the same bounded sentences with standard parameters. So $R$ is sound for both, and they agree on $\rho(\mathrm{dom}\,\rho)$. Hence *whether the intended reals of practice contain infinitesimals* cannot be learned from any practice, coherence or object data in this language.

The original hypothesis, elementary equivalence in all of $L$, fails in this instance. $V(\mathbb R)$ and ${}^*V(\mathbb R)$ are not elementarily equivalent in the full ∈-language. Take the unbounded sentence "for every $n\in\mathbb N$ there is a sequence on $\{0,\dots,n\}$ with $s(0)=\mathbb R$ and $s(k+1)=s(k)\cup\mathcal P(s(k))$". It holds in $V(\mathbb R)$. It fails in ${}^*V(\mathbb R)$ at nonstandard $n$, because internal objects have standard rank. (Referee's example, re-checked in outline.) That is why $R$ must contain only bounded axioms.

*Proof.* $R$ and ρ are shared, so $\mathrm{St}^g$, ${\models}$ and paradoxes are shared. A valuation $v_M\circ\rho$ depends only on the truth values in $M$ of the sentences in $\rho(\mathrm{dom}\,\rho)$, so $\mathcal V_h=\mathcal V_{h'}$. ∎

**Proposition 3.6 (ε-δ versus internal set theory) [proved modulo cited theorems of Nelson] (revised after verification: the domain is restricted to standard parameters, and the granularity bullet is corrected).** Nelson's internal set theory (IST) is ZFC plus a predicate "standard" with the idealization, standardization and transfer schemas. Nelson (1977, *Bull. AMS* 83:1165–1198) proved two results [cited]:
* IST is conservative over ZFC;
* his reduction algorithm assigns to each IST formula $A(t)$ an internal formula $B(t)$ with $\mathrm{IST}\vdash\forall^{\rm st}t\,(A(t)\leftrightarrow B(t))$.

The reduction is only for **standard values of the parameters**, and the statement is restricted accordingly.
* *The IST reading.* Let $\rho_{\rm IST}$ read informal analysis literally in IST, under two conventions:
  * every contextual constant $c$ ("let $f$ be continuous") is read as standard, i.e. $T_{\rm IST}:=\mathrm{IST}+\{\mathrm{st}(c):c\text{ contextual}\}$;
  * infinitesimal or unlimited *suppositions* are folded into bound variables. For example, a line ξ in a context that supposes "$dx$ is infinitesimal" is read as $\forall dx\,(dx\simeq0\wedge dx\neq0\to\xi)$.

  Let $D_{\rm st}$ be the occurrences whose reading under these conventions is an IST sentence with standard parameters only. Classically named objects are standard by transfer.
* *The Weierstrassian reading.* Let $h_{\rm W}=(\mathrm{ZFC}+\text{contextual constants},\rho_{\rm W})$, where $\rho_{\rm W}(x)$ is the internal sentence that the reduction algorithm assigns to $\rho_{\rm IST}(x)$, or any sentence ZFC-provably equivalent to it. This is a contextual reading into ZFC. It agrees with the textbook ε-δ reading on sentences about standard objects, but not in general.

**Claim.** $h_{\rm W}\approx_{D_{\rm st}}h_{\rm IST}$.

*Proof.*
1. By the reduction algorithm, $T_{\rm IST}\vdash\rho_{\rm IST}(x)\leftrightarrow\rho_{\rm W}(x)$ for $x\in D_{\rm st}$, since all parameters are standard in $T_{\rm IST}$.
2. $T_{\rm IST}$ is conservative over ZFC + constants for internal sentences. If $T_{\rm IST}\vdash\varphi(\vec c)$ with φ internal, then $\mathrm{IST}\vdash\forall^{\rm st}\vec c\,\varphi(\vec c)$, by the deduction theorem and generalization. Transfer gives $\mathrm{IST}\vdash\forall\vec c\,\varphi(\vec c)$, and Nelson's conservativity gives $\mathrm{ZFC}\vdash\forall\vec c\,\varphi(\vec c)$.
3. Hence for $\Gamma\cup\{y\}\subseteq D_{\rm st}$:
   * $\Gamma\models_{\rm IST}y$ iff $T_{\rm IST}\vdash\bigwedge\rho_{\rm IST}\Gamma\to\rho_{\rm IST}y$;
   * iff $T_{\rm IST}\vdash\bigwedge\rho_{\rm W}\Gamma\to\rho_{\rm W}y$, by step 1;
   * iff $\mathrm{ZFC}\vdash\bigwedge\rho_{\rm W}\Gamma\to\rho_{\rm W}y$, by step 2 and $T_{\rm IST}\supseteq\mathrm{ZFC}$;
   * iff $\Gamma\models_{\rm W}y$. ∎

*Outside $D_{\rm st}$ nothing is claimed.* Literal infinitesimal talk with nonstandard parameters ("this $dx$", "this unlimited $N$") is not covered by the reduction. Example: for $f(x)=Nx$ with $N$ unlimited, $f$ is ε-δ continuous at 0, but the literal IST reading $\forall x(x\simeq0\to f(x)\simeq f(0))$ fails at $x=1/N$. The same example shows that, even inside $D_{\rm st}$, $\rho_{\rm W}$ need not be the textbook ε-δ reading. The folded sentence "for every unlimited $N$, $\lambda x.Nx$ is S-continuous at 0" is false, and its reduction says so.

*Granularity (corrected).* Whether the $g$-step relations coincide is *not* claimed. If infinitesimal proofs are shorter, some $s\in\mathrm{St}^g_{\rm IST}\setminus\mathrm{St}^g_{\rm W}$ exists. Noise-free bounded-gap practice generated by $h_{\rm IST}$ then refutes $h_{\rm W}$ outright (Case 1 of Thm 3.4(d)). That is decisive against $h_{\rm W}$ as a hypothesis about granularity. But $h_{\rm W}\approx_{D_{\rm st}}h_{\rm IST}$, so the identified meaning is unaffected. Conversely, if the target is $h_{\rm W}$ and $h_{\rm IST}$'s $g$-steps are a superset, positive bounded-gap data never refute $h_{\rm IST}$.

**Proposition 3.7 (Benacerraf) [proved, modulo standard facts of ZF].** Let $D_{\rm ar}$ be the occurrences of informal arithmetic sentences. Let $\rho_{\rm vN}$ and $\rho_{\rm Z}$ read them into $L_\in$ via the von Neumann numerals ($n+1=n\cup\{n\}$) and the Zermelo numerals ($n+1=\{n\}$) respectively, with $+$ and $\times$ defined by recursion. Then $(\mathrm{ZF},\rho_{\rm vN})\approx_{D_{\rm ar}}(\mathrm{ZF},\rho_{\rm Z})$. The readings differ on "$1\in3$": true for von Neumann, false for Zermelo, since $3=\{\{\{\emptyset\}\}\}\not\ni\{\emptyset\}$. That sentence lies outside $D_{\rm ar}$.

*Proof.* ZF proves that both $(\omega_{\rm vN},0,S_{\rm vN})$ and $(\omega_{\rm Z},0,S_{\rm Z})$ are Dedekind–Peano systems. ZF proves Dedekind's categoricity theorem: any two such systems are isomorphic by a unique recursion-defined map, which preserves the recursively defined $+$ and $\times$. Hence ZF proves $\rho_{\rm vN}(x)\leftrightarrow\rho_{\rm Z}(x)$ for every closed arithmetic $x$, by induction on formulas transported along the isomorphism. Equal readings up to ZF-provable equivalence give equal informal consequence relations on $D_{\rm ar}$. Occurrences with contextual constants ("let $n$ be a number") are not equivalent sentence by sentence, because the constant denotes different sets under the two readings. The consequence relations still coincide: pass to universal closures and transport along the isomorphism. ∎

Benacerraf (1965, "What numbers could not be") is thus a theorem about non-identifiability: the practice fixes ≈ on its domain and nothing else.

### 3.5 Why ≈ is the inferentialist-correct notion

1. **It is the inferential role.**
   * For a Brandom-style inferentialist, the meaning of a sentence is its role in material inference.
   * Bilateralists add incompatibility; here incompatibility is incoherence, which ≈ fixes by Lemma 3.3(iii).
   * Sellars adds language-entry transitions: what one says when confronted with something. Here these are object evaluations, which ≈ fixes by Lemma 3.3(i).

   So, under completeness, the whole Sellars–Brandom profile of every practice sentence is a function of $\models_h$ on $D^*$. Two latent formalizations that are ≈ on $D^*$ assign *the same inferentialist meaning to every sentence the practice uses*.
2. **It is exactly what soundness needs.** (Revised after verification.) Soundness means soundness with respect to ${\models_{h^*}}$, so it depends only on the ≈-class of $h^*$ (Thm 2.4). At closure level the verifier converges to exactly ${\models_{h^*}}$ (Thm 3.4(c)). At gap $g$ it converges to $\mathrm{St}^g_{h^*}$. That relation carries granularity information beyond ≈, and the meaning it fixes is only bracketed: exactly identified under step-expressiveness, otherwise possibly underdetermined from below (Thm 3.4(d)).
3. **Everything finer is idle and unidentifiable.** Ontology (Prop 3.5), choice of latent language (Prop 3.6, on $D_{\rm st}$) and treatment of junk sentences (Prop 3.7) never change a practice inference, and no closure-level data the practice could produce distinguish them.
4. **Objections.**
   * (a) *Granularity is real.* What counts as one obvious step is cognitively significant, and it is partially identifiable (Thm 3.4(d)). It is pragmatics (which steps are *acceptable*), not semantics (which steps are *valid*).
   * (b) *Proof-theoretic semanticists* (Dummett–Prawitz) individuate meaning by canonical derivations, which is finer than ≈. (Revised after verification.) Bounded-gap practice identifies $h^*$'s $g$-step relation exactly (Thm 3.4(d)), a finite-granularity shadow of their canonical derivations. What it leaves open is twofold. First, rivals' extra coarse steps. Second, when $h^*$ is not step-expressive, inferences that are not chains of practice-sized steps. The second gap concerns ≈ itself.
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

Two points are worth noting. Both are modest reframings of contradiction backtracing, not new techniques.
* *Descent can end at a link.* Then the blame falls on an **equivocation** (Prop 2.3), not on a rule. This is Lakatos's "global but not local" case: every explicit step looks fine and the fault is a hidden change of reading.
* *The refutation is relative to admissibility.* A blamed step refutes exactly the hypotheses that validate it *and* admit the object. A learner may instead revise admissibility (monster-barring, §4.4).

### 4.2 The correction game: objects versus paradoxes

**Definition 4.2.** Let $S$ be a finite step universe (informal steps, or rule schemas) and $\mathcal H\subseteq2^S$ a finite class of step sets, with target $h^*\in\mathcal H$. Here $S$ may be taken to be the steps, and $\mathcal H=\mathcal H^g$ the induced relations. In each round the learner announces an accepted set $A_t\subseteq S$, which need not be a hypothesis. If $A_t\neq h^*$, the environment returns one feedback item:
* **(+)** a step $s\in h^*\setminus A_t$: a practice use or an escalation answer;
* **(−obj)** a step $s\in A_t\setminus h^*$: an object, after descent;
* **(−bag$_r$)** a set $B\subseteq A_t$ with $|B|\le r$ and $B\not\subseteq h^*$: the *suspect steps* of a paradox. Steps in $\bigcap\mathrm{VS}$ are certified and are dropped from a bag without loss.

The learner deletes the inconsistent hypotheses: $h\not\ni s$, $h\ni s$, and $h\supseteq B$ respectively. A *correction* is a round with feedback. $M_{\rm obj}(\mathcal H)$ and $M_{\rm bag}^{(r)}(\mathcal H)$ denote the optimal worst-case numbers of corrections over learners, targets and adversarial environments. The environment picks which item to return. $M_{\rm bag}:=M^{(|S|)}_{\rm bag}$ allows unbounded bags.

*Availability (revised after verification).* The game lets the environment return feedback whenever $A_t\neq h^*$. In reality each negative channel can be silent.
* **Object-completeness.** (−obj) requires an admissible object that refutes some accepted invalid step. This holds *relative to ${\models_{h^*}}$*: in propositional and finite-model-property fragments, every step outside ${\models_{h^*}}$ has a presentable countermodel. It fails in two cases.
  * Incomplete theories: an invalid step that is true in every presentable (standard) object is never refuted by an object.
  * $\mathcal H=\mathcal H^g$ with target $\mathrm{St}^g_{h^*}$: steps that are $h^*$-valid but not $g$-valid lie in $A_t\setminus\mathrm{St}^g_{h^*}$ and have no countermodel at all.

  So apply the object game with target ${\models_{h^*}}\cap S$, or assume $\mathrm{St}^g_{h^*}={\models_{h^*}}$ on $S$.
* **Bag-availability.** (−bag) likewise requires that some paradox implicate an accepted invalid step. Coherence data do not guarantee this: coherent-but-wrong hypotheses exist (T2; §3). The game lets the environment return a singleton bag $\{s\}$ for any accepted invalid $s$, so it implicitly assumes every accepted invalid step is refutable by a paradox.

Restricting the environment only lowers its worst case, so all bounds below remain upper bounds on the number of *corrections* in the real, restricted environment. But when a channel is silent, rounds with $A_t\neq h^*$ can pass without feedback. The bounds then count corrections, not unsound rounds. For example, the super-majority learner of Thm 4.5 can stay silently unsound forever with zero corrections. That is silent unsoundness, beyond the reach of channels (O) and (C).

**Theorem 4.3 (objects: logarithmic) [proved; classical — citations added after verification].**
* (a) $M_{\rm obj}(\mathcal H)\le\lfloor\log_2|\mathcal H|\rfloor$. With a prior $w$, weighted halving makes at most $\log_2(1/w(h^*))$ corrections. With $w=2^{-\ell}$ this is at most $\ell(h^*)$: *the number of counterexamples needed is at most the description length of the target formalization.* Hypotheses with the same step relation are one hypothesis in this game, so their weights add. This improves the bound to $\log_2(1/w([h^*]))$.
* (b) $M_{\rm obj}(\mathcal H)\le M^{(r)}_{\rm bag}(\mathcal H)$ for every $r\ge1$, with equality at $r=1$.
* (c) The object game is exactly Angluin's equivalence-query model with arbitrary (improper) hypotheses, where a counterexample is any element of $A_t\,\Delta\,h^*$. Equivalently, it is Littlestone's mistake-bound model. Hence $M_{\rm obj}(\mathcal H)=\mathrm{Ldim}(\mathcal H)$, the Littlestone dimension (Littlestone 1988) [cited]. On 248 random classes the exact minimax value equals Ldim in every case [computed: `verification_checks.py` V4]. (a) is the classical halving algorithm (Barzdin & Freivalds 1972; Littlestone 1988; Angluin 1988) [cited].

*Proof.*
* (a) Let $A_t=\{s:w(\{h\in\mathrm{VS}:s\in h\})>\tfrac12w(\mathrm{VS})\}$.
  * Feedback (+) on $s\notin A_t$ keeps only $\{h\ni s\}$, which has weight at most $\tfrac12w(\mathrm{VS})$.
  * Feedback (−obj) on $s\in A_t$ keeps only $\{h\not\ni s\}$, which has weight below $\tfrac12w(\mathrm{VS})$.

  Since $h^*$ is never deleted, $w(h^*)\le w(\mathrm{VS})\le2^{-M}$ after $M$ corrections.
* (b) Every (−obj) item $s$ is also a legal (−bag$_r$) item $B=\{s\}$, with the same deletion. So the object environment's moves are a subset of the bag environment's, and a bag learner's strategy works in the object game with no more corrections. At $r=1$ the two games coincide.
* (c) A deterministic mistake-bound learner gives an equivalence-query learner that announces its current prediction function, and conversely. Mistakes correspond to counterexamples. Littlestone's theorem gives the optimal mistake bound $\mathrm{Ldim}$. ∎

**Theorem 4.4 (paradoxes: linear, tightly) [proved; computed].**
* **(a) Upper bound.** $M^{(r)}_{\rm bag}(\mathcal H)\le\mathrm{el}^*(\mathcal H)\le|\mathcal H|-1$, where $\mathrm{el}^*$ is the maximum over targets of T1's positive elasticity. The second inequality always holds: each link of an elastic chain removes at least one hypothesis while the target survives, as in Thm 2.7(a). *(The earlier "min" was redundant.)*
* **(b) Single-culprit class.** Let $S=\{b_1,\dots,b_n\}$ and $\mathcal H_n=\{S\setminus\{b_j\}:j\le n\}$: exactly one of $n$ suspect steps is invalid. Then
  $$M_{\rm obj}(\mathcal H_n)=1,\qquad M^{(r)}_{\rm bag}(\mathcal H_n)=\min(r,\,n-1).$$
  In particular $M_{\rm bag}(\mathcal H_n)=n-1=|\mathcal H_n|-1$ and $\log_2|\mathcal H_n|=\log_2n$. This is an exponential separation, and (a) is tight.
* **(c) Natural realization with essential bags: the chain paradox.**
  * Take informal sentences $q_0,\dots,q_n$, suspect steps $b_i=(q_{i-1}\Rightarrow q_i)$, and the single designated context $A=\{q_0,{\sim}q_n\}$. For example, let $q_k$ be "a pile of $n-k$ grains is a heap", so $b_i$ says that removing one grain from a heap leaves a heap, and $A$ says that $n$ grains make a heap and 0 grains do not. Any chain of "obvious" lemmas also works. *(Indexing corrected after verification; the earlier reading designated "0 grains are a heap".)*
  * Let hypothesis $h_j$ validate every $b_i$ with $i\neq j$; e.g. propositional readings with axioms $p_{i-1}\to p_i$ for $i\neq j$.
  * Every $h_j$ is coherent on $A$, so the designation is truthful whatever the target.
  * Every derivation of ⊥ from $A$ using the $b_i$ uses *all* of them. Every paradox is the same essential bag, and no padding argument is needed.
  * With paradox feedback, every learner suffers $n-1=|\mathcal H|-1$ corrections. A single admissible object (any $u\in\mathcal V_{h_{j^*}}$ with $u(q_0)=1$, $u(q_n)=0$) pins down $j^*$ by descent.

*Proof.*
* (a) The cautious learner $A_t=\bigcap\mathrm{VS}_t$ never accepts an invalid step, since $h^*\in\mathrm{VS}_t$, so it receives only (+) items. The steps so received form an elastic chain, so there are at most $\mathrm{el}^*$ corrections. For $\mathrm{el}^*\le|\mathcal H|-1$: the $i$-th link $s_i$ of an elastic chain lies outside $\bigcap\mathrm{VS}(\{s_{<i}\})$, so some hypothesis containing $s_{<i}$ lacks $s_i$ and is removed, while the target is never removed.
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

*(Figures corrected after verification.)* On the 295 random classes of `bag_vs_elasticity.py` (seed 7), $M_{\rm obj}\le M_{\rm bag}\le\mathrm{el}^*\le|\mathcal H|-1$ always held, and $M_{\rm obj}<M_{\rm bag}$ in 43 of them [computed: `verification_checks.py` V3]. The earlier figures "244 classes, 32" were not produced by any script and are withdrawn. The natural conjecture "$M_{\rm bag}=\mathrm{el}^*$" (paradoxes are worthless and caution is optimal) is **false**. It held in 195 of the 295 classes. The smallest counterexample is $\mathcal H=\{\emptyset,\{0\},\{0,1\}\}$, with $M_{\rm bag}=1<2=\mathrm{el}^*$. Bags help when hypotheses are nested. They are worthless on $\mathcal H_n$, but not on every antichain: $\{\{1\},\{0,3\},\{0,4\}\}$ is an antichain with $M_{\rm bag}=1<2=\mathrm{el}^*$ (V3).

**Bounded bags: the price is linear in the bag size.** Real paradoxes have a bounded number of *suspect* steps. The steps that every surviving hypothesis accepts are certified and drop out.

**Theorem 4.5 (bags of size $\le r$) [proved] (phrasing corrected after verification).** Let $\mathcal H$ be finite with prior $w$, and $r\ge1$. The **super-majority learner** $A_t=\{s:\ w(\{h\in\mathrm{VS}:s\in h\})>\tfrac{r}{r+1}w(\mathrm{VS})\}$ makes at most $\ln(1/w(h^*))/\ln(1+1/r)$ corrections on target $h^*$. With the uniform prior,
$$M^{(r)}_{\rm bag}(\mathcal H)\ \le\ \frac{\ln|\mathcal H|}{\ln(1+1/r)}\ \le\ (r+1)\ln|\mathcal H|.$$
For $r=1$ the learner is halving.

*Proof.* Every $s\in A_t$ is missed by less than $\frac1{r+1}w(\mathrm{VS})$ of the weight.
* A bag $B\subseteq A_t$ with $|B|\le r$ deletes all $h\supseteq B$. By the union bound, the hypotheses missing some element of $B$ weigh less than $\frac r{r+1}w(\mathrm{VS})$, and they are all that remains.
* A (+) item $s\notin A_t$ keeps only $\{h\ni s\}$, of weight at most $\frac r{r+1}w(\mathrm{VS})$.

Since $h^*$ is never deleted, $w(h^*)\le(\frac r{r+1})^M$ after $M$ corrections. ∎

**Proposition 4.6 (the linear dependence on $r$ is necessary) [proved; computed].** Let $\mathcal H$ be the product of $k$ independent single-culprit blocks of size $b$, so $|\mathcal H|=b^k$. Then $M_{\rm obj}=k$ and $M^{(r)}_{\rm bag}\ge k\min(r,b-1)$. With $b=r+1$ this gives
$$M^{(r)}_{\rm bag}\ \ge\ r\cdot\frac{\log|\mathcal H|}{\log(r+1)},$$
while $M_{\rm obj}=\log|\mathcal H|/\log(r+1)$.

*Proof (completed after verification).* Write $C_X$ for the surviving candidate culprits of block $X$. Call $X$ *unresolved* if $|C_X|\ge2$.

*Objects, $M_{\rm obj}\le k$.* Announce every step not yet refuted, i.e. $S$ minus the culprits identified so far. No (+) item is possible, since $A_t\supseteq h^*$. Each (−obj) item is an unidentified culprit and resolves its block.

*Objects, $M_{\rm obj}\ge k$.* The adversary always answers inside one unresolved block $X$:
* (+) on a candidate in $C_X\setminus A_t$, or
* (−obj) on a candidate in $C_X\cap A_t$; one of the two sets is nonempty.

It commits only to hypotheses consistent with the answer, so the other blocks are untouched. Each correction resolves at most one block, and while some block is unresolved the adversary can choose $h^*\neq A_t$.

*Bags, $M^{(r)}_{\rm bag}\ge k\min(r,b-1)$.* Use the potential $\Phi:=\sum_X\min(r,|C_X|-1)$, with initial value $k\min(r,b-1)$. While $\Phi>0$ some block is unresolved, so the adversary can pick a target different from $A_t$. Given $A_t$, the adversary answers as follows.
* If some unresolved $X$ has a candidate $c\in C_X\setminus A_t$, answer (+) $c$. This is legal because the culprit can be another member of $C_X$. Then $C_X\leftarrow C_X\setminus\{c\}$, and Φ drops by at most 1. This also covers a block whose candidates are all rejected.
* Otherwise every unresolved block has all its candidates accepted. Pick one, $X$.
  * If $|C_X|>r$, answer with a bag $B\subseteq C_X$ of size $r$, committing to a culprit in $B$. Then $C_X\leftarrow B$, and $\min(r,|C_X|-1)$ drops from $r$ to $r-1$.
  * If $|C_X|\le r$, answer $B=C_X$. This deletes nothing, and Φ is unchanged.

Rejections of known-valid steps, and acceptances of identified culprits, are simply ignored by this adversary. Each correction lowers Φ by at most 1, so at least $\Phi_0$ corrections are needed.

The script `bag_product.py` confirms equality $M^{(r)}_{\rm bag}=k\min(r,b-1)$ for $(b,k)\in\{(2,2),(3,2),(2,3)\}$ and all $r$. A referee's independent exact solver also confirms it for $(4,2)$ and $(2,4)$ [referee computation, not in `T4-checks/`]. ∎

So in the online, adversarial setting, **the cost of multiple-instance (paradox) feedback grows linearly in the number of suspect steps**. In the worst case over classes of a given size it is $\tilde\Theta(r\log|\mathcal H|)$, up to a $\log r$ factor. Contrast the i.i.d. setting, where Sabato & Tishby (2012) [cited, bound form unverified] obtain only a $\log r$ overhead in sample complexity.

*Relation to L8's TC4 (revised after verification; the earlier text said this "settles" TC4).* TC4 asks for a mistake bound in terms of the Littlestone dimension of the instance class and $\log r$. The present results do two things:
* they refute the expected "$\mathrm{Ldim}\times\mathrm{polylog}(r)$" form, since products have $\mathrm{Ldim}=k$ and $M^{(r)}_{\rm bag}\ge r\cdot\mathrm{Ldim}$;
* they give the upper bound $(r+1)\ln|\mathcal H|$.

An upper bound in terms of Ldim alone is the open conjecture below; Ldim can be far below $\log|\mathcal H|$. Novelty is uncertain: bounds on the Littlestone dimension of $k$-fold aggregations may be related (possibly Ghazi, Golowich, Kumar & Manurangsi 2021; unverified).

**Conjecture (bag price).** $M^{(r)}_{\rm bag}(\mathcal H)\le r\cdot M_{\rm obj}(\mathcal H)=r\cdot\mathrm{Ldim}(\mathcal H)$ [conjecture]. Evidence:
* ratio at most 1 on all 519 (class, $r$) pairs of `bag_size_conjecture.py`;
* a referee's independent search found no violation. It was exhaustive over all classes on $|S|\le4$, covered about 4.7M random pairs on $|S|\le6$, and hill-climbed on $|S|\le8$ [referee computation, not in `T4-checks/`].

The bound is tight in three families:
* single-culprit classes, for $r\le n-1$ (for larger $r$, $M^{(r)}_{\rm bag}(\mathcal H_n)=n-1<r$);
* products, for $r\le b-1$;
* some 2-culprit classes (two culprits of 6, $r=2$: $4=2\cdot2$).

**Proposition 4.6′ (the conjecture holds when $M_{\rm obj}=1$) [proved; computed] (added after verification).** If $M_{\rm obj}(\mathcal H)=1$, then $M^{(r)}_{\rm bag}(\mathcal H)\le r$.

*Proof.* $M_{\rm obj}=1$ means some announcement $A$ makes the sets $A\,\Delta\,h$, for $h\in\mathcal H$, pairwise disjoint: every object or (+) item then pins the target. In the bag game, announce $A$.
* A (+) item $s$ lies in exactly one $A\,\Delta\,h$, and pins the target.
* A bag $B\subseteq A$ with $|B|\le r$ keeps only the $h$ with $B\cap(A\,\Delta\,h)\neq\emptyset$. That is at most $|B|\le r$ hypotheses, since each element of $B$ lies in at most one such set.

Then announce surviving hypotheses one at a time. Every feedback deletes the announced one, so at most $r-1$ further corrections are needed, for a total of at most $r$. If $|\mathcal H|\le r$, elimination alone costs at most $r-1$. ∎ On 304 (class, $r$) pairs with $M_{\rm obj}=1$, the bound held in every case (V5).

**Relation to T2.** T2's oligarchic halving (Thm 2.2) bounds the number of *detected incoherences* by $\log_2(1/w(h^*))$. Theorem 4.4(c) shows that the *total* number of corrections, counting the false rejections that oligarchy forces, can still be $|\mathcal H|-1$, and that every learner suffers this. Coherence bounds the price of boldness, not the price of learning. Objects bound both.

**Moral (revised after verification).** The sorites is the canonical *uninformative paradox*: coherence says that one link of the chain is bad and never which. The paradoxes of set theory are *not* of this kind at the instance level. Russell's paradox is a size-1 bag, $\{\mathrm{Comp}(R)\}$ (F1 in §5), as informative as an object. What they could not do is choose the *generalization*, i.e. the uniform restriction. That needed coverage of practice, because several incomparable maximal coherent repairs exist (Thm 5.1(e), 5.2(iii)). This failure would persist even with perfect instance-level blame. Monsters (Weierstrass's function, Abel's series, the homology sphere) were informative in the sorites sense: they localized blame on steps and generated concepts. The design consequence for the project (L6 TC1) is that a pre-formal learner must *generate and evaluate objects*, not only search for ⊥. It must also have coverage data to choose among coherent generalizations.

### 4.3 Lakatos's operators and the price of monster-barring

In $(L,R,\rho,\mathbb M)$-space, a step blamed by an object can be repaired in four ways (L6 §2). *(Terminology aligned with §6 after verification.)*
* change $R$: *lemma-incorporation*, i.e. drop the rule or guard it;
* change ρ so that the monster no longer satisfies the premise: *monster-barring by redefinition*, e.g. re-read "converges" as "converges uniformly". §6 models this as shrinking the set of admissible sharpenings;
* reject or re-evaluate the datum, by shrinking $\mathbb M$, distrusting the object, or re-interpreting it so that it is no longer a counterexample: *monster-barring by exclusion* and *monster-adjustment*;
* extend $L$: a *proof-generated concept*, i.e. a name for the hidden lemma.

**Proposition 4.7 (free barring nullifies objects) [proved, TOSU] (quantification corrected after verification).** Suppose the learner's selection criterion charges nothing for barring object data. Equivalently, an adversarially chosen learner may bar any datum. Then object data impose no constraint: every hypothesis consistent with (P) and (C) can survive forever, the bounds of Thm 4.3 fail, and on $\mathcal H_n$ the learner is back to Thm 4.4. Now assume objects are truthful, so that $h^*$ never needs to bar, and charge description length $c>0$ per barred datum. A hypothesis $h$ that must bar $m$ data to survive then has MDL score $\ell(h)+mc$, while $h^*$ has score $\ell(h^*)$. So $h$ loses as soon as $m>(\ell(h^*)-\ell(h))/c$, and each wrong hypothesis can absorb only boundedly many monsters.

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
* $\mathrm{MDL}_t:=\arg\min\{\ell(c):\ c\in\mathcal R,\ \mathrm{supp}(w_t)\subseteq c\}$.
* $\mathrm{REP}_t:=\arg\max$, lexicographically, of $(\mathrm{cov}_t(c),-\ell(c))$ over the $c\in\mathcal R$ not refuted by budget $t$.

**Theorem 5.1 [proved, TOSU].**
* **(a)** If $I\in\mathcal R$ ("naive comprehension", NC) and $\ell(I)<\ell(c)$ for all $c\neq I$, then $\mathrm{MDL}_t=I$ for all $t$.
* **(b)** A coherent $c$ is never refuted. An incoherent $c$ is refuted for all $t\ge k(c)$.
* **(c)** For $t\ge t_0:=\max\{k(c):c\in\mathcal R\text{ incoherent}\}$, $\mathrm{REP}_t$ maximizes $(\mathrm{cov}_t,-\ell)$ over the *coherent* members of $\mathcal R$.
* **(d) Convergence.** Suppose $w_t/\|w_t\|_1\to w_\infty$ in $\ell_1$, where $w_\infty$ is a probability vector on $I$; by Scheffé's lemma, pointwise convergence to a probability vector suffices. Suppose also that the coherent maximizer of $\mathrm{cov}_\infty$ is unique (strict). Then $\mathrm{REP}_t$ is eventually constant and equal to it. *(The $\ell_1$ requirement was added after verification. Members of $\mathcal R$ are typically infinite, and with mere pointwise convergence, mass escaping along a sequence of instances inside $c$ breaks the convergence of coverages.)*
* **(e) No canonical repair.** Let $c_1,c_2\in\mathcal R$ be coherent with $c_1\cup c_2$ incoherent. Then no coherent member of $\mathcal R$, and indeed no coherent subset of $I$, contains both. If $\mathrm{supp}(w_t)\subseteq c_1\cap c_2$, the choice between them at time $t$ is made by $\ell$ alone. Any later practice item in $c_1\setminus c_2$ shifts coverage toward $c_1$.

*Proof.*
* (a) $I$ contains every support and is shortest.
* (b) By the choice of search.
* (c) After $t_0$, the unrefuted members are exactly the coherent ones.
* (d) $|\mathrm{cov}_t(c)/\|w_t\|_1-\mathrm{cov}_\infty(c)|\le\|w_t/\|w_t\|_1-w_\infty\|_1\to0$ for every $c$. A strict maximizer stays strict in a neighbourhood.
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
| ZR | $x\in a\wedge x\notin x$ | | | ✓ | Zermelo's 1908 subset (the diagonal set for $f=\mathrm{id}$) |

Stratification works as in NF. A formula is stratified if it admits a typing $t$ with $t(v)=t(u)+1$ for each $u\in v$ and $t(u)=t(v)$ for each $u=v$. The formula $x\in x$ has no typing, so S, R and ZR are unstratified.

*Modelling caveat (added after verification).* Cantor's 1891 diagonal set $\{x\in a:x\notin f(x)\}$ has a function parameter, and ZR is its special case $f=\mathrm{id}$. Identifying "diagonal practice" with ZR-instances is a modelling stretch. A Cantor-style item with a function parameter would be a richer menu entry. NF proves the stratified variant $\{x\in a:x\notin f(\{x\})\}$, which is the source of $|\mathrm{USC}(X)|<|\mathcal P(X)|$ below.

**Hypotheses.** The class $\mathcal R$ restricts to the menu:
* NC = all of Φ;
* POS = positive formulas;
* STRAT = stratified formulas (NF-like);
* SEP = formulas of the form $x\in a\wedge\psi$;
* Z = SEP ∪ {EMP, PAIR, UNI} (Zermelo-like: separation, elementary sets, union).

The description lengths are ordered $\ell(\mathrm{NC})<\ell(\mathrm{POS})<\ell(\mathrm{SEP})<\ell(\mathrm{STRAT})<\ell(\mathrm Z)$. This ordering is *stipulated*. The reason offered for $\ell(\mathrm{STRAT})<\ell(\mathrm Z)$ ("Z is a uniform condition plus three named extra instances") is one encoding choice among several. *(Revised after verification.)* For the full supports of Thm 5.2(iv), only "NC is shortest" and "STRAT is shorter than Z" matter. For partial supports, the positions of POS and SEP matter too. The outcome "Dedekind–Cantor practice selects STRAT" is therefore ℓ-dependent.

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
* **(iv) Coverage selects (revised after verification).** After refutation, $\mathrm{REP}_t$ is determined as follows. Write DC = {INT, UNI, PAIR, DIFF, EMP} for the Dedekind–Cantor operations.
  * *Dedekind–Cantor practice* (support = DC, all five with positive weight). STRAT and Z both cover everything. POS misses DIFF and EMP, and SEP misses UNI, PAIR and EMP. The tie between STRAT and Z is broken by $\ell$, which selects **STRAT**, the NF-like repair.
    * More generally, for support ⊆ DC, STRAT is selected iff the support meets both {DIFF, EMP} and {UNI, PAIR, EMP}.
    * Otherwise POS is selected, if the support avoids DIFF and EMP: a purely positive practice of ∩, ∪ and pairs selects *positive* set theory.
    * Otherwise SEP is selected, if the support avoids UNI, PAIR and EMP.
    * *The original bullet claimed STRAT for every support ⊆ DC; that is false, e.g. {INT, UNI} gives POS and {INT, DIFF} gives SEP.*
  * *Add Zermelo's diagonal subsets* (support = DC ∪ {ZR}). Only Z covers everything, so **Z** is selected. More generally, if ZR ∈ support ⊆ DC ∪ {ZR}, then Z is selected iff the support meets {UNI, PAIR, EMP}, and SEP is selected otherwise.
  * *Add Frege's universal extension* (V) *as well* (support = DC ∪ {ZR, V}). Z and STRAT each miss one item; POS and SEP are strictly worse. Z is selected iff $w(\mathrm{ZR})>w(\mathrm V)$; ties go to STRAT by $\ell$. With partial supports, POS can tie STRAT and win by $\ell$; for example, {INT, UNI, PAIR, ZR, V} with $w(\mathrm V)>w(\mathrm{ZR})$ selects POS.

*Proof.* Combine Thm 5.1(c) with the membership table. The coverages are as follows, with $W$ the total weight:
* $\mathrm{cov(STRAT)}=W-w(\mathrm{ZR})-w(\mathrm S)-w(\mathrm R)$;
* $\mathrm{cov(Z)}=W-w(\mathrm V)-w(\mathrm S)-w(\mathrm R)-w(\mathrm{CMP})$;
* $\mathrm{cov(POS)}$ misses DIFF, EMP, ZR, R and CMP;
* $\mathrm{cov(SEP)}$ misses everything but INT, DIFF and ZR.

The case analysis above follows. All sub-supports of DC, alone, with ZR, and with ZR and V, agree with the stated conditions [computed: `verification_checks.py` V2, 0 mismatches]. `comprehension_toy.py` reproduces the coverage table for illustrative weights. ∎

**The historical reading** is offered as the user asks: "a nice thing shadowed in" practice, not a claim about what Zermelo did.
* The diagonal set $\{x\in a: x\notin f(x)\}$ of Cantor (1891) is unstratified. Accordingly, NF does not prove Cantor's theorem in its general form, only the version for unit subsets: $|\mathrm{USC}(X)|<|\mathcal P(X)|$ [cited: standard; see the NF literature, e.g. Holmes, arXiv:1503.01406].
* Zermelo (1908, *Math. Ann.* 65:261–281) proves from Separation that every set $M$ has a subset $\{x\in M:x\notin x\}$ that is not an element of $M$, so the domain is not a set [cited]. That is exactly ZR applied to an arbitrary $a$, and it is the diagonal argument turned into a theorem.
* So the toy says: *practice that already contains Zermelo-style diagonal subsets selects Separation over stratification, and Frege's universal extension is the price.* Without diagonal practice, and under the stipulated ℓ, simplicity would have favoured stratification, i.e. Quine's NF (1937). That favouring holds only if the practice also used difference or the empty set, and union, pairs or the empty set; a purely positive practice would have favoured positive set theory. *(Qualified after verification. The "NF branch" restates the chosen ℓ ordering rather than deriving it.)*
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

There are only countably many instances, so the number of maximal consistent subsets is exactly $2^{\aleph_0}$. The proof uses only pure logic. With Extensionality as background, the same argument works with Zermelo numerals $z_0=\emptyset$, $z_{k+1}=\{z_k\}$ in place of the $e_i$, $a_n=\{z_0,\dots,z_{n-1}\}$, and $A\subseteq\mathbb N_{\ge2}$. The model is then extensional and well-founded. Each $z_k$ has at most one element, so $p_1$ always holds, which is why $n=1$ is excluded. (A referee's remark, checked.)

**Incurvati & Murzi (2017)**, "Maximally consistent sets of instances of naive comprehension", *Mind* 126(502):371–384 [cited; author list verified this session]. They prove more: there are multiple incompatible maximal consistent sets, *none of them recursively axiomatizable* under minimal assumptions. This generalizes McGee's 1992 theorem for the T-schema (McGee 1992 details unverified). So:
* (a) "the maximal consistent repair" does not exist;
* (b) no computable learner can output a recursive axiomatization, i.e. an r.e. index, of a maximal one. *(Qualified after verification.)* Limit approximations do exist. Enumerate the instances and add each one if the set stays consistent. This greedy construction needs one $0'$ query per instance, since consistency is $\Pi_1$. So some maximal consistent sets are $\Delta_2$, and by Shoenfield's limit lemma a computable learner can converge to one pointwise in the limit.

This is the precise sense in which **uniformity of the restriction class is what makes the learning problem well-posed**. Zermelo's stated method of "restricting sufficiently to exclude contradictions, widely enough to retain everything valuable" (L6 §4) is constrained optimization whose optimum exists only within a uniform class, and is selected only by coverage.

### 5.4 What the toy does not capture

* **Replacement (1922).** It was added because Z cannot prove that $\aleph_\omega$ exists. That is coverage of a *conclusion*, not of an instance used in proofs, and it needs a richer menu. Thm 5.1 covers it, but the toy does not instantiate it.
* **The cumulative-hierarchy conception** (Zermelo 1930) is a semantic prior over repairs, not data. In the model it is a choice of $\ell$.
* **Undecidable coherence.** Coherence of the selected repair is not certified by the learner (Gödel II). $\mathrm{REP}_t$ can hold an incoherent repair until its paradox is found. Frege's way out (1903) survived until Leśniewski showed it inconsistent (1938, published by Sobociński 1949). Quine independently showed the same (1955). The Leśniewski–Sobociński details are from memory and unverified. *(Dates corrected after verification.)* Thm 2.4 shows this costs escalations, never soundness of the conservative verifier.

---

## 6. The robust core: why informal mathematics survived formalization

### 6.1 Sharpenings and the robust-core hypothesis

The user's hypothesis (L10 §1.6) is that pre-formal concepts like "function" were vague. The "rest of the concept" beyond the eventual definition "was untrustworthy/messy … and for this reason unusable whenever people were proving things".

**Definition 6.1.**
* Fix a first-order language $L$, a base theory $T_0$, and a set $W$ of vague words occurring in $\Xi$.
* A **sharpening** σ assigns each $w\in W$ an explicit $L$-definition. $\Sigma$ is the set of **admissible** joint sharpenings; taking them jointly encodes penumbral connections.
* Each σ gives a first-order complete hypothesis $h_\sigma=(L,R_\sigma,\rho_\sigma,\mathrm{Mod}(T_\sigma))$. Here $T_\sigma=T_0$ plus σ's definitions, and $\rho_\sigma$ reads each $w$ by its definition.
* **(Local) supervaluational validity**, i.e. validity under every admissible sharpening, is ${\models_{\rm SV}}:=\bigcap_{\sigma\in\Sigma}{\models_\sigma}$. Also put $\mathrm{St}^g_{\rm SV}:=\bigcap_\sigma\mathrm{St}^g_\sigma$. *(Label corrected after verification.)* The supervaluationist literature distinguishes this *local* notion, truth-preservation at each sharpening, from *global* validity, preservation of supertruth. Global validity is the notion usually called supervaluational validity (Fine 1975, via L7; Williamson 1994 ch. 5; Keefe 2000; Varzi 2007) [cited; attributions from memory, unverified]. With precise vocabulary in $L$ the two differ. Local validity is the right notion for "survives every formalization".
* A *precise object* is a model $M\models T_0$. It expands uniquely to $M_\sigma\models T_\sigma$, since the definitions are explicit. A sentence occurrence is *super-determinate* at $M$ if all $M_\sigma$ agree on it.
* **Object data are SV-truthful** if the community reports $v_M(x)$ only for super-determinate $x$. This is how a vague community *can* evaluate a monster.

**Robust-core hypothesis** $\mathrm{RCH}_g$. Every non-noise practice step lies in $\mathrm{St}^g_{\rm SV}$, and every practice link is valid under every σ. *The practice uses only inferences that are valid however its vague words are made precise.*

### 6.2 The theorems

**Theorem 6.2 (robust-core theorem) [proved, TOSU] (revised after verification).** The original (c) conflated $g$-validity ($\mathrm{St}^g$) with validity (${\models}$). It is split below; the data hypotheses of (b) now include oracle answers, and convergence is now stated and proved.
* **(a) Survival.** Assume $\mathrm{RCH}_g$, and take an argument all of whose inferences and links are non-noise practice items. It is $h_\sigma$-valid for every $\sigma\in\Sigma$ in the sense of Lemma 2.2: for every σ, its conclusion is in $\mathrm{Cl}_{R_\sigma}(\rho_\sigma\mathrm{Prem})$. So a theorem with such a practice proof is a theorem of every admissible sharpening, whichever one a later formalization adopts, provided its premises are $T_\sigma$-provable for every σ (e.g. designated axioms that every admissible sharpening proves). The old proofs survive as written, up to filling gaps of size $g$. Noise steps (BG2) are excluded.
* **(b) SV-truthful data never refute a sharpening.** Suppose $\{h_\sigma\}\subseteq\mathcal H$ and the data are **SV-truthful** in four respects:
  * practice lies in $\mathrm{St}^g_{\rm SV}$;
  * escalation and link answers are given only when all σ agree: "yes" on $\mathrm{St}^g_{\rm SV}$, "no" outside $\bigcup_\sigma\mathrm{St}^g_\sigma$, abstain otherwise;
  * designated contexts are coherent under every σ;
  * objects are SV-truthful.

  Then every $h_\sigma$ survives forever. Consequently, at all times, the accepted set of $V^g_t$ is contained in $\mathrm{St}^g_{\rm SV}$, and the verifier is $g$-sound, hence sound, for *every* sharpening simultaneously.
  * **(b′) Convergence.** If moreover $\mathcal H$ is finite and every element of $\mathrm{St}^g_{\rm SV}$ eventually appears in (P), then after finitely many data the accepted set equals $\mathrm{St}^g_{\rm SV}$.
  * *Effectivity.* For infinite Σ the idealized verifier needs a certificate under infinitely many survivors, and $\mathrm{St}^g_{\rm SV}$ can be undecidable. Example: let $\sigma_n$ read $w_m$ as "machine $m$ does not halt within $n$ steps", with a one-step Δ₀-evaluation rule. Then $(\emptyset\Rightarrow w_m)\in\mathrm{St}^1_{\rm SV}$ iff machine $m$ never halts. So the verifier is an algorithm only for finite Σ, or under extra uniformity.
* **(c) Upper bounds on sound acceptance.** Assume the data hypotheses of (b).
  * **(c1)** Any acceptance set that is *sound*, i.e. contained in ${\models_{\rm target}}$, whatever the target in $\{h_\sigma\}$, is contained in ${\models_{\rm SV}}$.
  * **(c2)** Any acceptance set that is *$g$-sound*, i.e. contained in $\mathrm{St}^g_{\rm target}$, whatever the target in $\{h_\sigma\}$, is contained in $\mathrm{St}^g_{\rm SV}$. If $\mathcal H=\{h_\sigma:\sigma\in\Sigma\}$, the verifier's accepted set is *exactly* $\mathrm{St}^g_{\rm SV}$ at all times, so the robust core is the maximal $g$-sound acceptance set.
  * The gap ${\models_{\rm SV}}\setminus\mathrm{St}^g_{\rm SV}$ is in general nonempty. Example: let $\rho(x)=q$ and $\rho(y)=q\wedge(q\wedge q)$ in a calculus whose only conjunction rule is ∧-introduction. Then $(\{x\}\Rightarrow y)\in{\models_\sigma}\setminus\mathrm{St}^1_\sigma$.
* **(d) The permanent abstention region.** With data as in (b), steps in $\bigcup_\sigma\mathrm{St}^g_\sigma\setminus\mathrm{St}^g_{\rm SV}$ are never accepted. They are of two kinds.
  * **(d1)** Steps outside ${\models_{\rm SV}}$, i.e. invalid under some admissible sharpening. No SV-truthful answer can license them. Only a *definition* (shrinking Σ) or lemma-incorporation (changing the step) removes them.
  * **(d2)** Steps in ${\models_{\rm SV}}\setminus\mathrm{St}^g_{\rm SV}$: valid under every sharpening, but not $g$-short under all of them. The community can truthfully vouch for their *validity*, though not for their shortness. Expansion into $\mathrm{St}^g_{\rm SV}$-steps (Prop 2.8), or adding a library lemma to every $R_\sigma$, removes them without any definition.

*Proof.*
* (a) Apply Lemma 2.2 once for each σ.
* (b) Every datum is consistent with each $h_\sigma$.
  * Practice steps are in $\mathrm{St}^g_\sigma$.
  * Oracle answers are given only when every σ agrees.
  * No paradox exists for a coherent $h_\sigma$.
  * A super-determinate report at $M$ equals $v_{M_\sigma}\circ\rho_\sigma$ on its domain, so it is $h_\sigma$-admissible.

  Hence $h_\sigma\in\mathrm{VS}_t$, and unanimity gives membership in every $\mathrm{St}^g_\sigma$. For (b′), any $h$ lacking some element of $\mathrm{St}^g_{\rm SV}$ is refuted when that element is presented. Finiteness gives a finite time after which every survivor contains $\mathrm{St}^g_{\rm SV}$. The $h_\sigma$ survive, so the intersection is $\mathrm{St}^g_{\rm SV}$.
* (c) If $s\in A\setminus{\models_\sigma}$, then $A$ is unsound when the target is $h_\sigma$. This gives (c1). The same argument with $\mathrm{St}^g_\sigma$ gives the first sentence of (c2). The original proof applied this step to $s\notin\mathrm{St}^g_\sigma$, which does not make $A$ unsound when $s\in{\models_\sigma}$. When $\mathcal H=\{h_\sigma\}$, by (b) every member survives, so the intersection is $\bigcap_\sigma\mathrm{St}^g_\sigma$.
* (d) Non-acceptance follows from (b) and (c2). For (d1), a "yes" on $s\notin{\models_\sigma}$ would be false under σ. For (d2), see Prop 2.8. ∎

**Theorem 6.3 (steps invalid under a sharpening have monsters) [proved, TOSU] (domain hypothesis and scope added after verification).** Let $s=(\Gamma\Rightarrow y)$ with $\Gamma\cup\{y\}\subseteq\mathrm{dom}\,\rho_\sigma$, and suppose $s\notin{\models_\sigma}$ for some admissible σ. Then there is a model $M\models T_\sigma$ in which $\rho_\sigma\Gamma$ holds and $\rho_\sigma y$ fails: a σ-*monster*.

*Proof.* This holds by the definition of ${\models_\sigma}$. $h_\sigma$ is first-order complete, so $\mathrm{Cl}_{R_\sigma}$ is semantic consequence over $T_\sigma$. Gödel completeness is what makes such calculi $R_\sigma$ exist. ∎

*Scope.* The theorem is about steps outside ${\models_{\rm SV}}$. Steps in ${\models_{\rm SV}}\setminus\mathrm{St}^g_{\rm SV}$ are "non-robust" in Thm 6.2's $g$-sense but have no monster. Moreover, a monster need not be presentable under SV-truthful reporting, because its values on Γ and $y$ are generally not super-determinate. For Abel's series, "$\sum f_n$ converges" is true under $\sigma_{\rm pw}$ and false under $\sigma_{\rm unif}$. A vague community can present such a monster only relative to a chosen sharpening.

*Cauchy, again.* "Converges" has two admissible sharpenings, pointwise and uniform. The step "continuous terms + convergent series ⇒ continuous sum" is valid under σ_unif and invalid under σ_pw. So it is not in the robust core, and Abel's series (a Fourier series) is a σ_pw-monster. It is presentable as a monster only relative to σ_pw (see *Scope* above).
* Lakatos's three responses are the three ways to change Σ or the language:
  * *monster-barring*: drop σ_pw from Σ, i.e. define "converges" as uniform convergence;
  * *lemma-incorporation*: add "uniformly" as a premise, which makes the step robust;
  * *proof-generated concept*: introduce a new word whose only sharpening is uniform convergence.
* The robust-core hypothesis predicts *where* pre-formal mathematics broke: exactly at the non-robust steps.

**Proposition 6.4 (only unanimity chains; the sorites is tight) [proved; computed; standard — see below].**
* **(a)** ${\models_{\rm SV}}$ is a consequence relation on the common domain $\bigcap_\sigma\mathrm{dom}\,\rho_\sigma$, being an intersection of consequence relations. Each ${\models_\sigma}$ is reflexive and monotone only on $\mathrm{dom}\,\rho_\sigma$. So supervaluational validity is closed under chaining.
* **(b)** Let μ be a probability distribution over Σ, for instance over the sharpening that future formalization will adopt. Count both inferences and links as steps, and assume $\{\sigma:s\in{\models_\sigma}\}$ is measurable. If each step of an $n$-step argument is valid with μ-probability at least $1-\varepsilon$, then the argument is valid with probability at least $1-n\varepsilon$. This is tight: there are $n$-step arguments each of whose steps is valid with probability $1-1/n$, yet the argument is valid under *no* sharpening. Formally the bound $1-n\varepsilon$ is attained for every $\varepsilon\le1/n$: give mass ε to each $\sigma_c$ below and mass $1-n\varepsilon$ to a sharpening under which every step holds.

*Not new.* The bound "uncertainty of the conclusion ≤ sum of uncertainties of the premises" is Adams's (Adams 1966; Adams & Levine 1975; cf. Suppes 1966). Its application to the sorites, with degrees as measures over precisifications, is Edgington's (1997). Tightness via disjoint failure events is the structure of Kyburg's lottery paradox (1961). [cited; from memory, unverified] *(Novelty claim withdrawn after verification.)*

*Proof.*
* (a) Monotonicity and cut hold in each ${\models_\sigma}$, hence in their intersection.
* (b) The bound is Lemma 2.2 per σ plus the union bound. For tightness use the sorites:
  * sentences $q_k$ = "$k$ grains make a heap", for $k=0..n$;
  * sharpenings $\sigma_c$ for $c=1..n$, with $q_k\mapsto k\ge c$, and μ uniform;
  * step $q_k\Rightarrow q_{k-1}$ fails under $\sigma_c$ iff $c=k$, so each step holds with probability $1-1/n$;
  * $q_n$ is true and $q_0$ is false under every $\sigma_c$, so the argument fails under all of them. ∎

`robust_core_and_mdl.py` checks the sorites for $n=3,5,10$. Its "union bound check" on 2000 random sharpening models only tests $P(\text{all steps valid})\ge1-L\varepsilon$, a probability tautology. It does not exercise Lemma 2.2.

Hence "valid on most readings" is to vagueness what majority vote is to verifier ensembles (T2 Thm 2.4, the doctrinal paradox): it does not compose. The robust-core hypothesis in its *unanimous* form is therefore not an arbitrary strengthening. *(Claim restricted after verification; the earlier "weakest per-step property that composes" was false.)* Validity under one fixed sharpening also composes and is weaker, but it presupposes knowing which sharpening is the target. Precisely:
* among properties of the form "valid with μ-probability ≥ 1−ε", only ε = 0 composes without degradation;
* among properties that guarantee validity whatever the admissible sharpening turns out to be, i.e. soundness for every possible target, unanimity is the weakest.

The same sorites chain is also the uninformative paradox of Thm 4.4(c). In both roles it marks the gap between *bag-level* and *element-level* information.

**Proposition 6.5 (how the nice notion of proof came to be there) [proved, TOSU; the content is Gödel completeness] (revised after verification).** The earlier version had a "bounded repertoire" hypothesis that its proof never used, and an interpretation claiming more than was proved.

*Single-sharpening case.* Let $T$ be an r.e. first-order theory, ρ* a reading, and $A_0$ the practice's initial step repertoire, with $\Gamma\cup\{y\}\subseteq\mathrm{dom}\,\rho^*$ for its steps. Suppose the community drops any step refuted by a presented monster, i.e. a model of $T$, and suppose monster presentation is complete: every step outside ${\models_T}$ is eventually refuted.
* **(a) Derivability.** The surviving repertoire is $A_\infty=A_0\cap{\models_T}$. Take any argument chained from surviving steps. The ρ*-images of its lines interpolate into a derivation in any complete calculus for $T$: each step is a $T$-derivable sequent, and Lemma 2.2 chains them.
* **(b) No gap bound follows.** $A_\infty$ need not be decidable or finitely schematized. The derivations of its steps can have unbounded length, even when $A_0$ is the instance set of a single informal schema. Example: let $A_0$ be the instances of "from χ infer θ", with χ and θ arithmetic sentences, and let $T=\mathrm{PA}$. Then $A_\infty=\{\chi\Rightarrow\theta:\mathrm{PA}\vdash\chi\to\theta\}$ is r.e. but undecidable, and no $g$ has $A_\infty\subseteq\mathrm{St}^g$.
* **(c) A bounded gap needs two extra hypotheses.**
  * $A_0$ consists of finitely many schemas, and selection acts on *schemas*: a schema is dropped as soon as any instance is refuted.
  * Each surviving schema is **uniformly derivable**: there is a derivation template with at most $g$ rule applications, written with the schema's metavariables as schematic letters, that becomes a derivation of each instance under substitution.

  Then every surviving step is in $\mathrm{St}^g$ of a complete calculus for $T$, and the surviving practice is the shadow of finitely many derived rules. Uniform derivability is automatic for pure propositional schemas: a schema all of whose substitution instances are valid has a valid generic instance; derive that once and substitute. It is not automatic in general. In PA, take the schema "infer θ($\bar n$)", where θ(n) says "n is not the code of a PA-proof of 0=1". Every instance is provable, by Σ₁-completeness. But no template uniform in the numeral exists: substituting a fresh variable for the numeral would turn it into a PA-proof of Con(PA), contradicting Gödel II.

*Vague case.* For every σ, apply (a) with $T_\sigma$ and $\rho_\sigma$; the surviving set is $A_0\cap{\models_{\rm SV}}$. Complete monster presentation is then in tension with SV-truthful reporting (Thm 6.3, scope).

*Proof.* (a) A step survives iff no model of $T$ refutes it, iff $T\cup\rho\Gamma\models\rho y$, iff it is derivable, by completeness. For chains, use Lemma 2.2. (b) The example: PA-provability of implications between arithmetic sentences is undecidable. If $A_\infty\subseteq\mathrm{St}^g$ for some $g$, then $A_\infty=A_0\cap\mathrm{St}^g$ would be decidable, given the size bound of §1.2. (c) Instantiate the templates. ∎

This is the model's partial answer to the user's question "how come mathematicians ended up with such a nice notion of proof?". Three ingredients are involved:
1. **Local checkability.** Steps are checked on objects one line at a time (Lemma 4.1). Monster pressure therefore selects for steps that are truth-preserving in every object.
2. **Completeness.** Gödel's theorem turns "truth-preserving in every object of an elementary class" into "derivable in a finite calculus", with *no bound on derivation length*.
3. **Schema-level selection of uniformly derivable schemas.** This is an extra hypothesis, not a consequence of a bounded repertoire (Prop 6.5(b), (c)). Only it makes the surviving practice the shadow of finitely many derived rules with a bounded gap. I do not derive it from anything more basic. It is a hypothesis about how practice generalizes. What makes the calculus differ from "the set of truths" is that $T$ is r.e. (ingredient 2), not the repertoire.

So the model explains why the surviving steps are *derivable*. It explains why they are *short*, the bounded-gap structure of §1, only under ingredient 3. The formal proof structure is "sorta there" in the activity because the activity was *selected by objects*, and completeness says that is the same as being shadowed by a calculus. Three caveats:
* complete monster presentation is an idealization, and the selection took centuries (L6's lag table);
* for intended-model semantics such as $\{\mathbb N\}$, ingredient 2 fails. Selection by standard objects then converges toward true arithmetic, which no calculus captures, and the formal notion of proof is a further choice;
* completeness of the surviving calculus with respect to $T$ does *not* follow. Selection only removes steps from $A_0$.

**Euclid: an analogy, not a proven instance** *(relabelled after verification)*.
* Let a "sharpening" of a drawn diagram be any configuration in a perturbation neighbourhood of it. Perturbations are not sharpenings in the sense of Def 6.1, which are explicit $L$-definitions of vague words, so this is an analogy.
* Under this identification, *co-exact* properties (Manders 2008) are the super-determinate ones, by definition. Manders's thesis that Euclid reads off only co-exact properties is then the analogue of $\mathrm{RCH}$ for diagrammatic steps.
* Avigad, Dean & Mumma's system E (2009) is a calculus for that practice. It is sound and complete for a restricted class of sequents, relative to ruler-and-compass semantics [cited]. It plays the role of what Thm 6.2(c2) says a learner could at best recover.
* *Steiner's 7776 (corrected after verification).* $6^5=7776$ is a Bézout count. It presupposes that the five degree-6 tangency hypersurfaces in the $\mathbb P^5$ of conics meet properly, in finitely many points. That fails for *every* choice of five conics, because all these hypersurfaces contain the Veronese surface of double lines. The correct count is 3264 (de Jonquières 1859, Chasles 1864; L6). The "monster" lives in the solution space, as degenerate solutions, not in a special input configuration. The step is "exact" in Manders's sense and breaks openness.

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

*Proof.* $J_\lambda$ is a sum of independent per-rule terms $\min(\lambda\ell(r),N\pi_rg_r)$. ∎ This is the standard separable-penalty (hard-thresholding) fact, and it duplicates T5 Thm 3.2.

**Corollary 7.2 [proved] (conventions made explicit after verification).** Let $\mathcal T$ be finite, $\pi_r>0$ for every valid $r$, κ > 0, and take max over an empty set of fallacies to be 0. Then some steepness κ makes the MAP exactly the set of valid rules iff
$$\min_{r\ \rm valid}\kappa_r>\max_{f\ \rm fallacy}\kappa_f.$$
With infinitely many tags, min and max become inf and sup, and the "iff" can fail at a common value that is not attained.

**Proposition 7.3 (the vertex conjecture fails) [proved; computed].** Take three rules:
* a common valid rule A: $\ell=10$, $\pi=0.5$, $g=8$;
* a rare, long valid rule B: $\ell=40$, $\pi=0.01$, $g=8$;
* the freshman's dream F: $(a+b)^2=a^2+b^2$, with $\ell=8$, $\pi=0.05$, $g=8$.

Then $\kappa_A=0.4$, $\kappa_F=0.05$ and $\kappa_B=0.002$. As κ increases, the MAP passes through {A,B,F}, then {A,F}, then {A}, then ∅. *No* κ selects the true rule set {A,B}. Equivalently, its point is not on the lower convex hull. `robust_core_and_mdl.py` scans κ.

The failure is stronger than non-vertexhood (remark added after verification). In (complexity, residual bits per datum), {A,B} = (50, 0.4) is Pareto-dominated by {A,F} = (18, 0.08). So {A,B} is selected by no criterion that is strictly increasing in both coordinates. It also lies strictly inside the convex hull of the other subsets' points, so adding further hypotheses cannot make it a vertex. (The hull vertices are ∅, {A}, {A,F}, {A,B,F}, {B,F} and {B}, recomputed after verification.)

**Assessment (revised after verification for consistency with T5).**
* The user's idea is right in a precise sense: a steeper penalty acts as a *frequency-per-bit threshold*, analogous to T1's Thm 6.4 frequency threshold. The hull-selection mechanism itself is correct (T5 Lemma 3.1). What fails is the universal claim that the intended model is always a hull vertex.
* The conjecture *holds* in the user's own motivating regime of rare, expensive, idiosyncratic errors (T5 Thm 3.5). It fails for cheap systematic fallacies. T5 Thm 4.1 (rate blindness) and Prop 4.2 (cheap fallacies out-rate genuine rules) give the same counterexample mechanism as Prop 7.3.
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
| Informal completeness lemma (3.3) | proved | standard corollary of completeness and Lindenbaum, applied to shadows; conceptually central, not new |
| Identification up to ≈ (3.4) | proved; (d) revised after verification | moderate. (d) after revision: bounded-gap data identify the $g$-step relation exactly and bracket meaning; meaning is identified only under step-expressiveness |
| Transfer / IST / Benacerraf witnesses (3.5–3.7) | proved modulo cited theorems (3.6 on standard-parameter occurrences only) | the depth is in the cited theorems |
| Object halving (4.3) | proved; cited | classical: halving, and $M_{\rm obj}=$ Littlestone dimension (Littlestone 1988) |
| Bag lower bounds (4.4, 4.6), bag-size upper bound (4.5), the $M_{\rm obj}=1$ case of the bag-price conjecture (4.6′) | proved; computed | **genuine content**: exact exponential separation, a sorites realization, a linear-in-$r$ adversarial MIL cost; novelty relative to the Littlestone-dimension literature is uncertain |
| Abstract repair theorem (5.1) | proved | TOSU |
| Comprehension toy (5.2) | proved; (iv) corrected after verification | elementary, but every fact checked; the NF branch rests on a stipulated ℓ and on full Dedekind–Cantor support |
| $2^{\aleph_0}$ maximal repairs (5.4); non-r.e. | proved; cited | easy; the non-r.e. part (Incurvati–Murzi) is deep and not ours |
| Robust-core theorem (6.2), monsters (6.3), sorites tightness (6.4), emergence of proof (6.5) | proved; 6.2 and 6.5 revised after verification | TOSU; the *hypothesis* RCH is the empirical content; 6.4's tightness is standard (Adams; Edgington); 6.5 explains derivability, not bounded gap |
| Steeper penalty (7.1–7.3) | proved; computed | easy; it answers the user's open question negatively in general, positively in his rare-expensive-error regime (T5), with the correct positive core |

**The hardest open problem: affordable soundness with language invention.**
* Every positive result assumes realizability ($h^*\in\mathcal H$) in a *fixed* class. Historically the decisive moves enlarged $L$: quantifier structure, ε-δ, uniform convergence, ideals, the fundamental group (L6 §4).
* Realizability can be restored by a universal class: all computable $(L,R,\rho)$ with a description-length prior. Then Thm 2.5 is sound with $W^*\ge2^{-K(h^*)}$. But the escalation cost becomes $\Theta(2^{K(h^*)})$ on unstructured parts of the class (T1 Cor 4.5), and Thm 4.4 shows the paradox channel cannot rescue it.
* The problem is to find a hypothesis class with two properties:
  * (i) it is closed under the definitional extensions history actually made, i.e. new predicates defined by formulas of bounded quantifier rank over the old language;
  * (ii) its escalation dimension, or its correction complexity with object feedback, is polynomial in the description length of the target.

  Alternatively, prove that closure under definitional extension forces antichains of exponential size, as in the single-culprit class, making sound learning with language invention exponentially expensive.
* A partial hope: definitions are themselves schemas, so T1's anti-unification bounds may apply to *definition learning* as they do to rule learning. Whether proof-generated concepts (which name hidden lemmas found by descent) can be learned with $O(\text{depth})$ objects each is the concrete sub-question.

**Other open problems.**
1. *Combinatorics of bags.* Prove $M^{(r)}_{\rm bag}\le r\cdot\mathrm{Ldim}(\mathcal H)$. Thm 4.5 gives $(r+1)\ln|\mathcal H|$, and Prop 4.6′ proves the case $\mathrm{Ldim}=1$. Find the combinatorial dimension that characterizes $M_{\rm bag}$. It lies between $M_{\rm obj}=\mathrm{Ldim}$ and $\mathrm{el}^*$, and both inequalities can be strict. Computed: for "$k$ culprits among $n$" it appears to be $n-k$.
2. *Misspecified practice.* When no coherent bounded-gap formalization exists (Leibnizian infinitesimals before 1960), what should the verifier converge to? Candidate: the robust core of the ε-near-optimal realizations. No theorem yet.
3. *Moving readings.* Model the community's ρ as changing in response to monsters (Lakatos dynamics), and prove that MDL with revision costs converges to a fixed point (L6 TC7).
4. *Granularity as evidence.* Does Leibnizian practice at small $g$ prefer IST to Weierstrassian readings (Prop 3.6)? If it does, noise-free bounded-gap data refute $h_{\rm W}$ as a granularity hypothesis without touching meaning. This is empirical, and decidable with DSP-style tooling.
5. *Is RCH true?* It needs a corpus study: annotate 19th-century proofs with admissible sharpenings, and test whether accepted-and-surviving steps are SV-valid while broken ones are not.
6. *Bounded-gap identifiability of meaning.* (Added after verification.) Characterize when practice plus objects identify ≈ without full step-expressiveness (Thm 3.4(d)). Is there a natural weaker condition on $h^*$ and $D^*$? What do negative escalation answers add?

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
6. **A bounded-gap DSP verifier with two readings.** Use ε-δ and infinitesimal (IST-style) formalizations of the same calculus textbook. Measure $g$-step relations. Check which side of granularity is identified, and whether the textbook is step-expressive enough for meaning to be identified (Thm 3.4(d), revised).

---

## References

Citations marked (unverified) are from memory and should be checked before publication.
* Adams, E. W. (1966). Probability and the logic of conditionals. In Hintikka & Suppes (eds.), *Aspects of Inductive Logic*, North-Holland (unverified details).
* Adams, E. W., Levine, H. P. (1975). On the uncertainties transmitted from premises to conclusions in deductive inferences. *Synthese* 30 (unverified details).
* Angluin, D. (1988). Queries and concept learning. *Machine Learning* 2:319–342 (pages unverified).
* Avigad, J., Dean, E., Mumma, J. (2009). A formal system for Euclid's *Elements*. *Rev. Symb. Logic* 2(4) (pages unverified).
* Barzdin, J., Freivalds, R. (1972). On the prediction of general recursive functions. *Soviet Math. Doklady* 13 (unverified details).
* Benacerraf, P. (1965). What numbers could not be. *Phil. Review* 74:47–73 (unverified pages).
* Cantor, G. (1891). Über eine elementare Frage der Mannigfaltigkeitslehre. *Jahresber. DMV* 1:75–78 (unverified pages).
* Easwaran, K. (2015). Rebutting and undercutting in mathematics. *Phil. Perspectives* (via L6).
* Edgington, D. (1997). Vagueness by degrees. In Keefe & Smith (eds.), *Vagueness: A Reader*, MIT Press (unverified details).
* Fine, K. (1975). Vagueness, truth and logic. *Synthese* 30 (via L7, unverified pages).
* Ghazi, B., Golowich, N., Kumar, R., Manurangsi, P. (2021). Near-tight closure bounds for the Littlestone and threshold dimensions. ALT 2021 (title from memory; relevance to bag feedback **unverified**, listed only as a possible lead).
* Holmes, M. R. New Foundations is consistent. arXiv:1503.01406 (v23, 2025; later co-authorship and the Lean verification unverified).
* Incurvati, L., Murzi, J. (2017). Maximally consistent sets of instances of naive comprehension. *Mind* 126(502):371–384.
* Jiang, A. et al. (2023). Draft, sketch, and prove. ICLR (via L8).
* Keefe, R. (2000). *Theories of Vagueness*. CUP (unverified details).
* Kyburg, H. E. (1961). *Probability and the Logic of Rational Belief*. Wesleyan UP.
* Lakatos, I. (1976). *Proofs and Refutations*. CUP.
* Littlestone, N. (1988). Learning quickly when irrelevant attributes abound: a new linear-threshold algorithm. *Machine Learning* 2:285–318 (pages unverified).
* Manders, K. (2008). The Euclidean diagram. In Mancosu (ed.), *The Philosophy of Mathematical Practice*, OUP.
* McGee, V. (1992). Maximal consistent sets of instances of Tarski's schema (T). *J. Phil. Logic* 21 (unverified).
* Nelson, E. (1977). Internal set theory: a new approach to nonstandard analysis. *Bull. AMS* 83:1165–1198.
* Quine, W. V. (1937). New foundations for mathematical logic. *Amer. Math. Monthly* 44 (unverified pages).
* Quine, W. V. (1955). On Frege's way out. *Mind* 64:145–159.
* Robinson, A. (1966). *Non-standard Analysis*. North-Holland.
* Sabato, S., Tishby, N. (2012). Multi-instance learning with any hypothesis class. *JMLR* 13 (via L8; bound form unverified).
* Shapiro, E. (1983). *Algorithmic Program Debugging*. MIT Press (via L6).
* Sobociński, B. (1949). L'analyse de l'antinomie russellienne par Leśniewski. *Methodos* 1–2 (volume and pages unverified).
* Specker, E. (1953). The axiom of choice in Quine's New Foundations. *PNAS* 39 (unverified).
* Suppes, P. (1966). Probabilistic inference and the concept of total evidence. In Hintikka & Suppes (eds.), *Aspects of Inductive Logic* (unverified details).
* Varzi, A. (2007). Supervaluationism and its logics. *Mind* 116 (unverified details).
* Ville, J. (1939). *Étude critique de la notion de collectif*.
* Weber, K., Mejía-Ramos, J. P. (2011). Why and how mathematicians read proofs. *Educ. Stud. Math.* 76 (via L6).
* Williamson, T. (1994). *Vagueness*. Routledge (ch. 5; unverified).
* Zermelo, E. (1908). Untersuchungen über die Grundlagen der Mengenlehre I. *Math. Ann.* 65:261–281.
* Project files: T1 (Lemma 1.1, Thms 3.2, 3.9, 4.2, 4.4, Cor 4.5), T2 (Thms 2.2, 2.4, Cor 6.2), T5 (Lemma 3.1, Thms 3.5, 4.1, Prop 4.2), L6, L7, L8 (TC4, TC8), L10.
