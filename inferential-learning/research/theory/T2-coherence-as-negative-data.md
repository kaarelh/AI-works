# T2. Coherence as negative data, and the learning-theoretic Carnap problem

*Theory thread T2 of the inferential-learning project. Read `00-brief.md` first. This note develops definitions, theorems and proofs. Every result is labelled with a status: **[proved]** means a full proof appears here; **[cited]** means a known result that I quote, with the source given and flagged as **(unverified)** where I am working from memory; **[sketch]** and **[conjecture]** mean what they say. I also rate each result's depth honestly: "trivial once set up" (TOSU) means the content lies in the framing.*

*Related memos: `lit/L1-positive-data-learning.md` (Gold/Angluin, finite elasticity, closure systems), `lit/L2-reliable-selective-kwik.md` (coherence bags as multiple-instance constraints; soundness and escalations), `lit/L7-contexts-idealization-inconsistency.md` (contexts, chunk-and-permeate). Sanity-check scripts are in `theory/T2-checks/`.*

---

## 0. Summary of results

The thread asks what coherence ("don't have good arguments for both P and ¬P") can and cannot do for a learner of inference rules. The answers, compressed:

1. **Coherence is negative data. It is informative only for bold learners, and oligarchic aggregation makes each detection informative.** A derivation of ⊥ from a context certified coherent is a *negative bag*: at least one step in it is invalid. Suppose the learner's accepted rule set at each time is the set of steps on which a weighted half of its surviving hypotheses agree (an "oligarchy"). Then the number of detected incoherences is at most $\log_2(1/w(h^\*))$ (Thm 2.2).
   * Oligarchy is necessary for *guaranteed per-round halving* of detections against a worst-case prover (Prop 2.3). It is not necessary for a logarithmic bound as such.
   * Suppose the environment withholds discriminating positive data. Then majority-vote aggregation of individually coherent hypotheses can produce the same uninformative incoherence forever. This is the doctrinal paradox (Thm 2.4).
   * A sound (cautious) learner never receives any coherence signal at all (Prop 2.9).
   * The detection bound controls only one of the two error types. On Prop 2.9's class every oligarchic learner makes $|\mathcal H|-1$ incompleteness errors, as many as the cautious learner, while a non-oligarchic learner makes none of either type. Per-round halving of both error types can be impossible (Prop 2.9(d),(e)). So boldness buys a two-sided trade-off, not a free lunch. *(Revised after verification.)*

2. **What coherence can never see.** Given positive data and coherence, the hypotheses that are never refuted are exactly the *coherent over-generalizations* of the target: $U(h^\*)=\{h\supseteq h^\*: h \text{ coherent}\}$ (Thm 2.6). By compactness, the union of a chain of coherent hypotheses is coherent (Prop 2.7). Suppose the designated contexts are *fixed and known independently of the target*. Then coherence never removes the *limit points* (infinite ascending chains together with their unions) that drive Gold's impossibility theorem (Cor 2.8). It prunes from above, but it cannot remove limit points. If instead designations are target-dependent data, they are genuine negative data. With classical negation, a complete designation stream plus the text is an informant, and the limit-point obstruction disappears (Prop 2.8′). *(Revised after verification.)*

3. **Post-completeness is exactly what makes coherence sufficient.** Every structural (substitution-closed) consequence relation extending classical propositional consequence is either classical or trivial (Thm 3.1). This consequence-level form of Post-completeness is standard (Wójcicki 1988; Pogorzelski & Wojtylak 2008). The proof, included for completeness, needs no finitarity. Hence a learner that uses positive data plus a *single* coherence datum identifies CPC with no simplicity or minimality bias (Thm 3.3).
   * Subtleties: in theorem-free fragments such as $\{\wedge,\vee\}$, there is exactly one extra structural extension, the *almost inconsistent* one (Prop 3.2). Coherence must then use a non-empty context.
   * The largest structural consequence relation with a given theorem set is its *structural completion* (Prop 3.4). In a language with theorems, this is $\mathbf C_2$ for CPC (structural completeness). For IPC it is strictly larger than IPC, because of admissible underivable rules (Prop 3.5).

4. **Where coherence cannot pin the target.**
   * Intuitionistic logic: by Glivenko, every intermediate logic has *literally the same* coherence data as CPC. A Jankov chain then gives a class that no learner using positive data and coherence can identify (Thm 3.6).
   * Arithmetic:
     * Δ₀ world feedback is *subsumed* by coherence for every theory extending Q (Lemma 3.7).
     * A Turing-progression chain defeats every learner that uses positive data, coherence relative to true contexts, and a Δ₀ oracle (Thm 3.9).
     * Coherence with PA is an exact *truth detector for Π₁ sentences*, but not for Σ₁ sentences. The correct boldness is therefore *Popperian*: be bold on universal claims and cautious on existential ones. This is the standard Σ₁/Π₁ asymmetry of formal learning theory (Putnam 1965; Kelly 1996), read for coherence-learners. A naively bold learner builds a Lindenbaum completion that depends on the enumeration and can be Σ₁-unsound.
     * No learner fed computable data decides Σ₂-truth in the limit (Thm 3.10).
   * Complete theories (RCF, Presburger arithmetic, Tarski's elementary geometry) are coherence-pinned *at the level of theorems* (Prop 3.11(a)). The user's setting is the level of rules applied in contexts with parameters. There a single coherence datum pins the target if hypotheses are closed under ∃-elimination (Prop 3.11(b)). Without that closure, RCF has unsound coherent rule-level extensions that survive the empty context and even a non-empty one (Prop 3.11(c)). This matters for physics, whose algebraic core is RCF. *(Revised after verification.)*

5. **The learning-theoretic Carnap problem is Gold's problem in the dual (valuation) space, with a twist.** A sequent excludes a basic clopen set of valuations, so inference data are *negative data about valuations*. Coherence certifications ("this position is in bounds") and world feedback are *positive* data about valuations.
   * Single-conclusion data determine the admissible valuations only up to ∩-closure, even when the data are complete (Thm 4.2). For CPC the indistinguishable alternatives are exactly the characteristic functions of non-maximal CPC-theories, plus the all-true valuation.
   * A *denial-rank trichotomy* (Thm 4.3) sorts every non-Boolean valuation by how many denials are needed to exclude it:
     * rank 0: excluded by a 0-denial *non-contradiction* constraint such as $p,\neg p\rhd$, the sequent-level principle behind the coherence loss;
     * rank 1: excluded by ordinary inference;
     * rank 2: excluded only by "exhaustiveness" data with 2 denials. Carnap's tautology-valuation has rank 2.
     
     So the user's coherence loss cannot fix classical meanings, whether it is read as in-bounds certifications or as the non-contradiction constraint behind them, and neither can imitation. An exhaustiveness loss is needed. *(Clarified after verification.)*
   * Bilateral (multiple-conclusion) data plus structurality identify the Boolean meanings from a **finite tell-tale of 12 data points**: the 11 atomic multiple-conclusion sequents $\mathrm{TT}(p,q)$ (3 with two conclusions, 1 with none, 7 single-conclusion) and 1 coherence datum (Thm 4.4). Without structurality, BV is not identifiable in the limit at all (Thm 4.4(d), revised after verification).
   * A compositional prior (a single 2-valued matrix) also solves the problem, from single-conclusion data alone (Prop 4.5). This is the analogue of restricting the hypothesis class in Gold's setting.

6. **tonk, harmony, conservativity.**
   * Under transitivity, tonk trivializes. Coherence catches it in 2 steps, *provided* the logic has a theorem or the designated context is non-empty (Prop 5.1). In a theorem-free setting with only the empty context designated, tonk survives coherence.
   * Coherence is strictly weaker than conservativity (Prop 5.2), with coherence read as non-triviality (§1).
   * Coherence is Π₁-complete and so decidable in the limit with at most one mind change. Conservativity over an r.e. base is Π₂-complete, so it is *not decidable in the limit by any computable learner* (Thm 5.3).

7. **Fallacies and Kripkenstein.**
   * Coherence eliminates a fallacy iff "target + generalized fallacy" is incoherent on some designated context (Thm 6.1).
   * Over CPC, *every* structurally generalized propositional fallacy is eliminated, with a polynomial-size witness obtained by substituting ⊤ and ⊥ (Cor 6.2).
   * Natural survivors: quantifier swap (survives the empty context, dies in any context with two distinct objects); the gambler's fallacy without an accepted independence premise; affirming the consequent restricted to background laws, i.e. conditional perfection (survives *if* the per-law converse is consistent with the context; the converse direction fails).
   * The residue after coherence is the set of *coherent uniform alternatives* (Thm 6.4). Structurality does the anti-gerrymander work, coherence does the anti-conflict work, and data do the anti-under-generalization work. What remains is genuine incompleteness: the Gödel/Rosser alternatives are the Kripkensteinian residue of arithmetic.

8. **Contexts.** Designating a single classically inconsistent context as coherent forces every structural learner to give up a classical rule schema *globally*. For example, it must become atomically paraconsistent (Prop 7.1). This is the formal version of the user's air-pressure worry, and it is why idealized contexts must be designated as consistent chunks $\Gamma\cup K_\Gamma$.

The headline answer to "does something of this shape provably work for formal math?":
* **Yes for propositional logic, and for complete first-order theories at the level of theorems.** There, positive data, structural generalization and a single coherence datum provably identify the target. The proof is short, and the content is Post-completeness. For complete theories at the level of rules applied in contexts with parameters, the same holds provided hypotheses are closed under ∃-elimination; otherwise one coherence datum is not enough (Prop 3.11, revised after verification).
* **No for arithmetic and other incomplete theories.** Coherence plus any computable world feedback leaves a residue of coherent alternatives that is provably ineliminable. The right supplements are Popperian asymmetry for Π₁ claims, and reflection or holistic coherence with *stronger accepted theories*.

---

## 1. Setting and notation

**Formulas, sequents.**
* $\mathrm{Fm}$ is a countable set of formulas, built over atoms $p_0,p_1,\dots$ (propositional case) or a first-order language (arithmetic case).
* A *(single-conclusion) sequent* is $\Gamma\rhd\varphi$ with $\Gamma\subseteq_{\rm fin}\mathrm{Fm}$.
* A *multiple-conclusion sequent* is $\Gamma\rhd\Delta$ with $\Gamma,\Delta$ finite. Following Restall (2005, "Multiple conclusions") [cited], read it as *the position $[\Gamma:\Delta]$, asserting all of Γ while denying all of Δ, is out of bounds*.
* When ⊥ is present it is a formula, and "coherent" means "⊥ not derivable".
* In a language without ⊥ (e.g. $\{\wedge,\vee\}$ or pure $\{\to\}$), "coherent" means *non-trivial*: $h$ is $A$-coherent iff $h(A)\neq\mathrm{Fm}$. For structural $h$ this is equivalent to $A\nvdash_h q$ for an atom $q$ not occurring in $A$: substitute arbitrary formulas for $q$. For hypotheses that contain ex falso ($\bot\rhd\varphi$) the two readings agree. *(Clarified after verification.)*

**Hypotheses** come in three equivalent-looking but importantly different guises.
1. *Step sets* $R$ (a learned step verifier): a set of sequents read as one-step inferences. An *argument* π from $A$ is a finite derivation tree whose leaves are in $A$ and whose internal nodes are steps; $\mathrm{Steps}(\pi)$ is the finite set of steps it uses. Reflexivity and weakening are free. $\mathrm{Der}(R)$ is the least consequence relation containing $R$: arguments chain, so cut is built in.
2. *Consequence relations* ⊢: finitary closure operators, i.e. reflexive, monotone, closed under cut. Equivalently, closure operators $C:\mathcal P(\mathrm{Fm})\to\mathcal P(\mathrm{Fm})$.
   * ⊢ is *structural* if $\Gamma\vdash\varphi$ implies $\sigma\Gamma\vdash\sigma\varphi$ for every substitution (endomorphism) σ. Equivalently, $\sigma C(X)\subseteq C(\sigma X)$.
   * The intended reading of structurality is that *rules are uniform schemata*. A learner that generalizes human steps to schemata is a structural learner.
3. *Meanings as sets of valuations* $V\subseteq 2^{\mathrm{Fm}}$ (§4).

**Target and data.**
* The target is $h^\*$: a step set $R^\*$ or a consequence relation $\vdash^\*$.
* *Positive data*: sequents valid in the target (imitation of human inferences).
* *Coherence data*: a family $\mathcal A$ of *designated contexts*, finite premise sets certified coherent: $A\nvdash^\*\bot$ for $A\in\mathcal A$. In the bilateral version, positions $[A:D]$ are certified in bounds: $A\nvdash^\* D$.
  * Designated contexts are where coherence is enforced. Hypothetical contexts (reductio) are *not* designated, so deriving ⊥ in them is never penalized (§7).
  * Unless stated otherwise, $\mathcal A$ is a *fixed* family known to the learner, so every possible target is $\mathcal A$-coherent and the coherence information does not depend on the target. When designations are instead data about the target (contexts certified coherent *for this target*), they carry genuine negative information; see Prop 2.8′.
* A hypothesis $h$ is **$\mathcal A$-coherent** if $A\nvdash_h\bot$ for all $A\in\mathcal A$. The *effective class* is $\mathcal H_{\mathcal A}=\{h\in\mathcal H: h\ \mathcal A\text{-coherent}\}$.
* *World feedback*: truth values, in an intended structure, of sentences from a restricted class (e.g. Δ₀ sentences in arithmetic).

**Learning criteria.**
* Gold-style identification in the limit (EX: syntactic convergence to one correct index; BC: eventually every conjecture is correct) from a *text* (an enumeration of all positive data), possibly supplemented by coherence and world data.
* Online mistake bounds (§2).
* Standard references: Gold (1967); Angluin (1980); Blum & Blum (1975) for locking sequences; Littlestone (1988) and Littlestone & Warmuth (1994) for halving and weighted majority [all cited]. See L1 for details.

---

## 2. Coherence as negative data

### 2.1 Negative bags

**Lemma 2.1 (negative bag) [proved; TOSU].** Let π be an argument from a designated $A\in\mathcal A$ to ⊥.
* Then $\mathrm{Steps}(\pi)\not\subseteq R^\*$: at least one step is target-invalid.
* Every step-set hypothesis $R$ with $\mathrm{Steps}(\pi)\subseteq R$ is refuted *by the witness π*.
* *(Revised after verification.)* Two notions of "refuted" must be kept apart.
  * *Logically*, the designation $A\nvdash^\*\bot$ excludes every hypothesis $h$ with $A\vdash_h\bot$, independently of π. For step sets this is every $R$ with $A\vdash_{\mathrm{Der}(R)}\bot$. This holds equally for step sets and for consequence relations.
  * *By witness*, a learner that deletes using π deletes $\{h:\mathrm{Steps}(\pi)\subseteq h\}$. This set depends on π and can be a strict subset of $\{h:A\vdash_h\bot\}$, even for consequence relations. Example: target CPC, $A=\{p\}$, π with steps $p\rhd q$ and $q\rhd\bot$. Let $h$ be the least consequence relation containing $p\rhd\bot$, without explosion. Then $A\vdash_h\bot$, but neither step of π is in $h$.
  * A learner that can test $A\rhd\bot\in h$ directly by membership deletes the full logical set. For it π is unnecessary, and the information was already in the designation (cf. Prop 2.9(c)). So π matters *computationally*, as a finite witness that can be checked by membership.

*Proof.* If every step were valid, then chaining (cut) would give $A\vdash^\*\bot$, contradicting designation. A hypothesis containing all the steps derives ⊥ from $A$ and so is not $\mathcal A$-coherent, while the target is. The example in the third bullet is checked directly. ∎

So a coherence violation is a *multiple-instance* label: "not all of these steps are valid". This is a positive bag for the concept "invalid step", in the sense of Dietterich, Lathrop & Lozano-Pérez (1997) [cited]. Suppose hypotheses are cut-closed and the learner can test membership of $A\rhd\bot$ directly. Then the bag collapses to an ordinary negative example of the sequent $A\rhd\bot$. The bag structure matters exactly when the learned object is a *step verifier that is not itself cut-closed*: a process-reward model, a neural step scorer, or a majority of verifiers. That case is the interesting one for H1.

### 2.2 Oligarchic halving

**Online protocol.**
* The class $\mathcal H$ of step sets is countable, with prior $w$, $\sum_h w(h)=1$. The target is $R^\*\in\mathcal H$ and every $A\in\mathcal A$ is target-coherent.
* In round $t$ the learner holds a version space $\mathrm{VS}_t$ (initially $\mathcal H$) and announces an *accepted step set* $\hat R_t$. The reasoner may chain any steps of $\hat R_t$.
* The environment does one of three things:
  * **(P)** presents a positive datum $s\in R^\*$; the learner deletes every $R\not\ni s$;
  * **(N)** exhibits a *detected incoherence*, an argument π from some $A\in\mathcal A$ to ⊥ with $\mathrm{Steps}(\pi)\subseteq\hat R_t$; the learner deletes every $R\supseteq\mathrm{Steps}(\pi)$;
  * nothing.
* The environment is adversarial. It may be the learner's own proof search.
* *Two error types.* A (P)-round presenting $s\notin\hat R_t$ is an *incompleteness error*: a valid step the learner did not accept. An (N)-round is a *detection*. *(Definition made explicit after verification.)*

**Learner OH (oligarchic halving).** Choose any $S_t\subseteq \mathrm{VS}_t$ with $w(S_t)\ge \tfrac12 w(\mathrm{VS}_t)$ and announce $\hat R_t=\bigcap_{R\in S_t}R$, the steps on which the whole coalition agrees.

**Theorem 2.2 [proved].** Under OH:
* (i) $R^\*$ is never deleted.
* (ii) Assume $w(R^\*)>0$. The number of type-(N) rounds (detections) is at most $\log_2\!\big(1/w(R^\*)\big)$, which is $\le\log_2|\mathcal H|$ for the uniform prior. The bound says nothing about incompleteness errors: oligarchic learners can make $|\mathcal H|-1$ of them (Prop 2.9(d)).
* (iii) Whenever $R^\*\in S_t$, the accepted set is sound: $\mathrm{Der}(\hat R_t)\subseteq \mathrm{Der}(R^\*)$.
* (iv) In every round, $\mathrm{Der}(\hat R_t)\subseteq\mathrm{Der}(R)$ for all $R\in S_t$. So $\hat R_t$ is a single compositional rule set: chaining never takes the reasoner outside what each coalition member accepts.

*Proof.*
* (i) A (P)-datum is in $R^\*$. A (N)-deletion removes only $R\supseteq\mathrm{Steps}(\pi)$, and $R^\*\not\supseteq\mathrm{Steps}(\pi)$ by Lemma 2.1.
* (ii) In an (N)-round every $R\in S_t$ satisfies $\mathrm{Steps}(\pi)\subseteq\hat R_t\subseteq R$, so all of $S_t$ is deleted and $w(\mathrm{VS}_{t+1})\le \tfrac12 w(\mathrm{VS}_t)$. (P)-rounds never increase $w(\mathrm{VS})$. After $D$ such rounds, $w(R^\*)\le w(\mathrm{VS})\le 2^{-D}$.
* (iii) and (iv): $\hat R_t\subseteq R$ for every $R\in S_t$, and $\mathrm{Der}$ is monotone. ∎

*Remarks.*
* (a) The free choice of $S_t$ encodes the learner's *style*.
  * "Simplest half" (largest prior mass, i.e. MDL) gives a simplicity-biased reasoner.
  * "Boldest half" (the hypotheses accepting the most steps) is the boldest choice *within oligarchy*. It still accepts only steps shared by a weighted half, so $\hat R_t$ lies inside a single surviving hypothesis. It can therefore be exactly as incomplete as the cautious learner (Prop 2.9(d)). *(Revised after verification: earlier text called it "completeness-seeking" without qualification.)*
  * The detection bound holds for every choice of style.
  * The classical sources for this halving argument are Barzdin–Freivalds and Littlestone (1988). The only new ingredient is the reduction from negative bags to coalitions.
* (b) **Truth maintenance is required.** Lemmas proved under $\hat R_t$ are certified only by the coalition $S_t$. If the coalition later changes and old lemmas are kept, the effective accepted set becomes a union over coalitions. The doctrinal-paradox failure of Thm 2.4 then reappears *across time*. A learner must therefore re-validate cached lemmas against the current coalition.
* (c) The bound counts *detected* incoherences only. Silent unsoundness is the subject of §2.5.

### 2.3 Halving forces oligarchy; majority fails

**Proposition 2.3 (characterization of per-round halving) [proved] (revised after verification).** Let $\mathrm{VS}$ be countable (finite or infinite) with $w(\mathrm{VS})>0$, and let $\hat R$ be the announced set. Assume the worst case: any finite $P\subseteq\hat R$ with $P\not\subseteq\bigcap\mathrm{VS}$ can occur as $\mathrm{Steps}(\pi)$ of a detected incoherence.
* $P\not\subseteq\bigcap\mathrm{VS}$ says exactly that the detection is legal for some target in VS (Lemma 2.1).
* The adversarial prover can pad derivations.

Then the following are equivalent:
* every possible detection deletes at least half of $w(\mathrm{VS})$;
* $\hat R\subseteq\bigcap S$ for some $S\subseteq\mathrm{VS}$ with $w(S)\ge\tfrac12 w(\mathrm{VS})$.

*Scope.* This characterizes *per-round* halving against a worst-case prover. It does not say that a logarithmic detection bound requires oligarchy.
* Coalitions of weight $\ge\frac13 w(\mathrm{VS}_t)$ give $D\le\log_{3/2}(1/w(R^\*))$ by the argument of Thm 2.2.
* Finitely many non-oligarchic rounds add only a constant.

*Proof.*
* (⇐) A legal detection $P\subseteq\hat R\subseteq\bigcap S$ deletes $\{R\in\mathrm{VS}:P\subseteq R\}\supseteq S$.
* (⇒) The step universe is countable because Fm is. Enumerate $\hat R=\{s_1,s_2,\dots\}$ (finite or infinite), let $P_k=\{s_1,\dots,s_k\}$, and let $S_k=\{R\in\mathrm{VS}:P_k\subseteq R\}$.
  * If $P_k\not\subseteq\bigcap\mathrm{VS}$, then $P_k$ is a possible detection deleting exactly $S_k$, so $w(S_k)\ge\frac12 w(\mathrm{VS})$.
  * If $P_k\subseteq\bigcap\mathrm{VS}$, then $S_k=\mathrm{VS}$.
  * The $S_k$ decrease to $S:=\bigcap_k S_k=\{R\in\mathrm{VS}:\hat R\subseteq R\}$.
  * By countable additivity (continuity from above; $w$ is finite), $w(S)=\lim_k w(S_k)\ge\frac12 w(\mathrm{VS})>0$. Trivially $\hat R\subseteq\bigcap S$.
  * For finite VS one can instead take $P_0=\{s_R\}$, with one step $s_R\in\hat R\setminus R$ for each $R$ with $\hat R\not\subseteq R$. ∎

**Theorem 2.4 (doctrinal paradox: uninformative incoherence) [proved] (precision added after verification).**
* *Setup.* Let $\mathcal H=\{h_1,h_2,h_3\}$ with uniform prior and $h_i=\mathrm{Cn}_{\rm CPC}(T_i)$ (all sequents valid from $T_i$), where $T_1=\{p,q\}$, $T_2=\{p,\neg q\}$, $T_3=\{\neg p,q\}$. Let $\mathcal A=\{\emptyset\}$. Every $h_i$ is coherent, and any of them may be the target.
* *Majority aggregation* over the current version space is $\hat R_t=\{s: w(\{R\in\mathrm{VS}_t:s\in R\})>\frac12w(\mathrm{VS}_t)\}$. While $\mathrm{VS}_t=\mathcal H$, this is $\hat R_{\rm maj}=\{s: s\in h_i\text{ for at least two }i\}$.
* *Claim.* For every target there is an environment under which the prover exhibits the same detected incoherence in every round and no hypothesis is ever deleted. The environment presents only π, or interleaves π with uninformative positive data such as $\rhd p\vee\neg p$, which lie in every $h_i$.
* *Caveat.* The environment must withhold discriminating positive data.
  * Suppose the target is $h_1$ and $\rhd p$ is presented. Then $h_3$ is deleted. Majority over $\{h_1,h_2\}$ is $h_1\cap h_2$, which is oligarchic, and π is no longer available ($\rhd q\notin h_2$).
  * The $h_i$ are pairwise incomparable, so on any complete text every wrong hypothesis is eventually text-refuted, and the uninformative incoherences stop.

*Proof.* Consider the argument π with steps $\rhd p$, $\rhd q$, $p,q\rhd p\wedge q$, $\rhd\neg(p\wedge q)$, $p\wedge q,\neg(p\wedge q)\rhd\bot$.
* Every step is in $\hat R_{\rm maj}$:
  * $\rhd p\in h_1,h_2$;
  * $\rhd q\in h_1,h_3$;
  * $\rhd\neg(p\wedge q)\in h_2,h_3$;
  * the last two steps are in all three.
* Yet $\mathrm{Steps}(\pi)\not\subseteq h_i$ for each $i$: $h_1$ lacks $\rhd\neg(p\wedge q)$, $h_2$ lacks $\rhd q$, and $h_3$ lacks $\rhd p$.
* By Lemma 2.1 the deletion set is empty. Tautological (P)-data delete nothing either. So VS and $\hat R_{\rm maj}$ never change, and π is available forever. ∎

This is Kornhauser & Sager's (1986) doctrinal paradox and Pettit's (2001) discursive dilemma, transposed to verifier ensembles [cited].
* List & Pettit (2002) prove that no aggregation function satisfies all of the following, for agendas containing at least two atomic propositions together with their conjunction (or disjunction, or material conditional) [cited]:
  * universal domain;
  * anonymity;
  * systematicity;
  * consistent and complete collective judgment sets.
* Oligarchic aggregation is characterized as the rules that yield deductively closed (but not necessarily complete) collective judgments by Gärdenfors (2006) and Dietrich & List (2008). See also Dokow & Holzman (2010) on abstentions, and Nehring & Puppe for related characterizations [cited; exact hypotheses and theorem statements (unverified)].

Prop 2.3 is the learning-theoretic face of that literature.

> **Moral for H1.** An ensemble of individually coherent verifiers that is chained *stepwise by vote* can be incoherent *and* yield no information about which member is wrong. Coherence feedback is informative only if acceptance is *unanimity within a coalition*. With a halving coalition, each detection then costs at least one bit.

### 2.4 Robust version: mis-designated contexts

Designations can be wrong. For example, "air pressure = 0" plus full background is classically inconsistent (§7). Replace deletion with multiplicative penalties.
* Let $\beta\in[0,1)$. On an (N)-round, multiply $w(R)$ by β for every $R\supseteq\mathrm{Steps}(\pi)$.
* Choose $S_t$ with $w_t(S_t)\ge\frac12 W_t$, where $W_t$ is the total current weight ($W_0=1$), and announce $\hat R_t=\bigcap S_t$.
* (P)-rounds delete every $R\not\ni s$ as before. Positive data are assumed noise-free here; for noisy positive data see the note after the proof.
* Call an (N)-round a *false alarm* if its context $A$ is in fact target-incoherent.

**Theorem 2.5 [proved; the Littlestone–Warmuth (1994) weighted-majority bound].** If $m$ of the (N)-rounds are false alarms, the number $D$ of (N)-rounds satisfies
$$D\ \le\ \frac{\ln(1/w_0(R^\*))+m\ln(1/\beta)}{\ln\!\big(2/(1+\beta)\big)}.$$
For β = 0 and m = 0 read $0\cdot\ln(1/0)=0$, which gives Thm 2.2. For β = 0 and m > 0 the bound is vacuous, because $R^\*$ can be deleted. The bound itself is Littlestone & Warmuth's (1994). The only new ingredient is the bag-to-coalition reduction of Thm 2.2.

*Proof.*
* Each (N)-round penalizes a set containing $S_t$, so $W_{t+1}\le W_t-(1-\beta)\tfrac12W_t=\tfrac{1+\beta}{2}W_t$.
* $R^\*$ is penalized only if $\mathrm{Steps}(\pi)\subseteq R^\*$. In that case $A\vdash_{R^\*}\bot$, i.e. a false alarm. Hence $w_T(R^\*)\ge\beta^m w_0(R^\*)$.
* Combining with $w_T(R^\*)\le W_T\le(\frac{1+\beta}2)^D$ gives the bound. ∎

Noisy positive data (human fallacies, §6) can be handled the same way, by penalizing $R\not\ni s$ with a factor β′. This is standard Littlestone–Warmuth bookkeeping.

### 2.5 What coherence cannot see

Take consequence-relation hypotheses. For $h$ and finite $D\subseteq\vdash^\*$, write $h\oplus D$ for the least consequence relation containing $h\cup D$. Assume the environment is complete: it eventually presents every positive datum and eventually exhibits every ⊥-derivation from every designated context in any hypothesis the learner uses forever.

Define three ways a hypothesis can be refuted:
* **text-refutable**: $\vdash^\*\not\subseteq h$ (some valid sequent is not accepted);
* **coherence-refutable**: $A\vdash_h\bot$ for some $A\in\mathcal A$;
* **refutable by coherence-with-data**: $A\vdash_{h\oplus D}\bot$ for some $A\in\mathcal A$ and finite $D\subseteq\vdash^\*$. This is the case where the learner uses accepted human conclusions as extra premises.

**Theorem 2.6 (silent over-generalizations) [proved; TOSU].**
* (i) $h$ is refutable by coherence-with-data iff $h\oplus{\vdash^\*}$ is $\mathcal A$-incoherent.
* (ii) The hypotheses refuted in none of the three ways are exactly
$$U(\vdash^\*)=\{h:\ \vdash^\*\subseteq h,\ h\ \text{is }\mathcal A\text{-coherent}\}.$$
* (iii) Every $h\in U(\vdash^\*)\setminus\{\vdash^\*\}$ is unsound (it accepts a target-invalid sequent). If $h$ is itself a possible target in the class, every finite stage of every data stream for $\vdash^\*$ is also a finite stage of a data stream for $h$.

*Proof.*
* (i) $h\oplus{\vdash^\*}$ is the directed union of the $h\oplus D$ over finite $D$, because a directed union of finitary consequence relations is one. A finite ⊥-derivation from $A$ lies in some $h\oplus D$.
* (ii) If $\vdash^\*\not\subseteq h$, then $h$ is text-refutable. Otherwise $h\oplus D=h$ for all $D\subseteq\vdash^\*$, so the other two criteria both reduce to "$h$ is $\mathcal A$-coherent".
* (iii) $h\supsetneq{\vdash^\*}$ gives unsoundness. Positive data for $\vdash^\*$ are positive data for $h$, and the designated set $\mathcal A$ is the same. ∎

**Proposition 2.7 (compactness: coherent chains have coherent unions) [proved].** If $h_1\subseteq h_2\subseteq\cdots$ are $\mathcal A$-coherent finitary consequence relations, then $h_\omega=\bigcup_n h_n$ is a consequence relation and is $\mathcal A$-coherent.

*Proof.* $h_\omega$ is closed under cut because any two sequents of $h_\omega$ lie in a common $h_n$. If $A\vdash_{h_\omega}\bot$, the single sequent $A\rhd\bot$ lies in some $h_n$. ∎

**Corollary 2.8 (coherence does not cure superfiniteness) [proved].** Suppose $\mathcal H_{\mathcal A}$ contains a strictly increasing chain $h_1\subsetneq h_2\subsetneq\cdots$ together with $h_\omega=\bigcup h_n$, which is automatically coherent by Prop 2.7. Then no learner identifies $\mathcal H_{\mathcal A}$ in the limit from text plus $\mathcal A$-coherence information.

*Proof.* The coherence information is the same fixed set $\mathcal A$ whatever the target, so a learner is in effect a text learner. Suppose $M$ identifies $h_\omega$. By Blum & Blum (1975) there is a *locking sequence*: a finite σ of $h_\omega$-data such that $M(\sigma\tau)$ is an index for $h_\omega$ for every finite $h_\omega$-sequence τ. Since σ is finite and the chain exhausts $h_\omega$, σ lies inside some $h_k$. On any text for $h_k$ that begins with σ, $M$ outputs an index for $h_\omega\neq h_k$ at every later stage, so it fails on $h_k$. ∎

So coherence prunes only *non-limit* over-generalizations. Positive-data structure decides everything else: finite generation, tell-tales, finite elasticity (L1 §2). This is why §3 needs Post-completeness. Coherence suffices exactly when the target has no coherent proper extension in the hypothesis class, i.e. $U(\vdash^\*)\cap\mathcal H=\{\vdash^\*\}$.

### 2.6 Coherence is data only for bold, bounded learners

**Proposition 2.9 [proved].**
* (a) If $\hat R_t\subseteq R^\*$, no (N)-round can occur. The same holds if $\hat R_t\subseteq\bigcap\mathrm{VS}_t$ (a *certified-sound*, cautious learner).
* (b) The incompleteness errors of cautious learners are not $O(\log|\mathcal H|)$, even when $\log_2|\mathcal H|=k$. Take
  * $h_b=\mathrm{Cn}_{\rm CPC}\{a_i\to\ell_i^{b_i}:i\le k\}$ for $b\in\{0,1\}^k$, where $\ell^1_i=p_i$ and $\ell^0_i=\neg p_i$;
  * $\mathcal A=\{\emptyset\}$.
  
  Then every certified-sound learner makes $2^k-1$ type-(P) errors on some text.
* (c) If membership and coherence of every $h\in\mathcal H$ are decidable, $\mathcal A$-coherence is *prior knowledge*, a restriction of the class to $\mathcal H_{\mathcal A}$, rather than data.

*Proof.*
* (a) A detection needs $\mathrm{Steps}(\pi)\subseteq \hat R_t\subseteq R^\*$, which contradicts Lemma 2.1.
* (b) Let $s_c:=\bigvee_i(a_i\to\ell_i^{1-c_i})$. Then $s_c\in h_b$ iff $b\neq c$:
  * If $b_i\neq c_i$, then $h_b\vdash a_i\to\ell_i^{1-c_i}$.
  * For $b=c$, the valuation with all $a_i$ true and $p_i=c_i$ satisfies $h_c$'s axioms and falsifies $s_c$.
  
  While $h_c\in\mathrm{VS}$, a certified-sound learner does not accept $s_c$. Presenting $s_c$ for each $c\ne b^\*$ produces $2^k-1$ errors, each deleting only $h_c$.
* (c) The learner can delete incoherent hypotheses a priori. ∎

So coherence is an informative *signal* only because consistency is undecidable (Π₁; §5.3). The learner cannot check its own hypotheses, and an adversarial or self-play prover finds contradictions for it. The signal is a dividend paid on *boldness*: a learner that never risks accepting a step outside the cautious intersection never hears from coherence. Coherence bounds the price of boldness ($\log_2(1/w^\*)$ detections, Thm 2.2). Nothing bounds the price of caution except the positive-data structure of the class.

### 2.7 The bilateral version

Everything in §2 holds verbatim for multiple-conclusion hypotheses:
* coherence data are positions $[A:D]$ certified in bounds;
* a negative bag is a multiple-conclusion argument showing $[A:D]$ out of bounds.

The *shape* of the data starts to matter only when the learning target is a set of valuations (§4).

---

## 3. Post-completeness and the bold learner

Write $\mathbf C_2$ for classical (CPC) consequence on a propositional language. It is the consequence of the Boolean matrix: $\varphi\in\mathbf C_2(X)$ iff every Boolean valuation making $X$ true makes φ true. Write $C_{\mathrm{Fm}}$ for the trivial operator, $C_{\mathrm{Fm}}(X)=\mathrm{Fm}$.

### 3.1 Structural Post-completeness

**Theorem 3.1 [proved].** Suppose the language contains ¬ and one of ∧, ∨, →. Then every structural closure operator $C\supseteq\mathbf C_2$ on $\mathcal P(\mathrm{Fm})$ (not necessarily finitary) equals $\mathbf C_2$ or $C_{\mathrm{Fm}}$. The same holds for the pure implicational language $\{\to\}$.

*Proof.* Fix an atom $p_0$, a tautology $\top_0$ in $p_0$ (e.g. $\neg(p_0\wedge\neg p_0)$, $p_0\vee\neg p_0$ or $p_0\to p_0$) and $\bot_0:=\neg\top_0$.
1. Suppose $C\neq\mathbf C_2$. Then there are $X$ and φ with $\varphi\in C(X)\setminus\mathbf C_2(X)$. Pick a Boolean $v$ with $v[X]=1$ and $v(\varphi)=0$.
2. Let $\sigma_v(p)=\top_0$ if $v(p)=1$ and $\sigma_v(p)=\bot_0$ otherwise.
   * For every Boolean $u$, $u\circ\sigma_v$ agrees with $v$ on atoms, so $u(\sigma_v\psi)=v(\psi)$ for all ψ.
   * Hence $\sigma_vX\subseteq\mathrm{Taut}=\mathbf C_2(\emptyset)\subseteq C(\emptyset)$, while $\sigma_v\varphi$ is a contradiction.
3. By structurality, monotonicity and idempotence: $\sigma_v\varphi\in C(\sigma_vX)\subseteq C(C(\emptyset))=C(\emptyset)$.
4. A contradiction classically entails everything, so $\mathrm{Fm}=\mathbf C_2(\{\sigma_v\varphi\})\subseteq C(C(\emptyset))=C(\emptyset)$. Then $C(Y)\supseteq C(\emptyset)=\mathrm{Fm}$ for all $Y$.

*Pure $\{\to\}$:* use $\sigma_v(p)=p_0\to p_0$ if $v(p)=1$ and $\sigma_v(p)=p_0$ otherwise. Induction on ψ shows $\sigma_v\psi\equiv_2 p_0\to p_0$ when $v(\psi)=1$ and $\sigma_v\psi\equiv_2p_0$ when $v(\psi)=0$. The cases for $\alpha\to\beta$:
* $v(\alpha)=0$: $p_0\to(\cdot)\equiv\top$.
* $v(\alpha)=1,\ v(\beta)=1$: $\top\to\top\equiv\top$.
* $v(\alpha)=1,\ v(\beta)=0$: $\top\to p_0\equiv p_0$.

So $\sigma_vX\subseteq\mathrm{Taut}$ and $\sigma_v\varphi\equiv_2p_0$. As above, $p_0\in C(\emptyset)$, and by structurality $C(\emptyset)=\mathrm{Fm}$. ∎

The theorem-level version is Post's 1921 completeness of the propositional calculus (no consistent proper substitution- and MP-closed extension of Taut) [cited]. Wójcicki (1988, *Theory of Logical Calculi*) is the standard source on extensions of consequence operations [cited (unverified)].

**Proposition 3.2 (theorem-free fragment; the almost inconsistent extension) [proved].** For the $\{\wedge,\vee\}$ language, the structural closure operators extending $\mathbf C_2$ are exactly three:
* $\mathbf C_2$;
* $C_{\rm ai}$, defined by $C_{\rm ai}(\emptyset)=\emptyset$ and $C_{\rm ai}(X)=\mathrm{Fm}$ for $X\neq\emptyset$ (the *almost inconsistent* operator, in Wójcicki's terminology [cited (unverified)]);
* $C_{\mathrm{Fm}}$.

*Proof.* $C_{\rm ai}$ is a structural closure operator. Since $\mathbf C_2(\emptyset)=\emptyset$ here (the all-false valuation falsifies every $\{\wedge,\vee\}$-formula), $C_{\rm ai}\supseteq\mathbf C_2$. Now let $C\supsetneq\mathbf C_2$ be structural.
* *Case $C(\emptyset)\neq\emptyset$.* Pick φ in it and substitute $p_0$ for every atom. Every one-variable lattice term is $\equiv_2 p_0$, so $p_0\in C(C(\emptyset))=C(\emptyset)$, hence $C=C_{\mathrm{Fm}}$.
* *Case $C(\emptyset)=\emptyset$.* Take $\varphi\in C(X)\setminus\mathbf C_2(X)$ (so $X\ne\emptyset$) and a Boolean $v$ with $v[X]=1$ and $v(\varphi)=0$. Let σ send the atoms true under $v$ to $q$ and the false ones to $r$ (distinct atoms).
  * Each $\sigma\psi$ is a monotone lattice term in $q,r$ taking the value $v(\psi)$ at $(q,r)=(1,0)$. Up to $\equiv_2$, the lattice terms in $q,r$ are $q,r,q\wedge r,q\vee r$.
  * So $\sigma\psi\in\{q,q\vee r\}$ for $\psi\in X$, and $\sigma\varphi\in\{r,q\wedge r\}$.
  * Then $\sigma X\subseteq\mathbf C_2(\{q\})$, and therefore $r\in\mathbf C_2(\sigma\varphi)\subseteq C(\sigma X)\subseteq C(\{q\})$.
  * By structurality $\psi\in C(\{\chi\})$ for all χ, ψ, so $C=C_{\rm ai}$. ∎

*Learning reading.* In a theorem-free language, a bold learner with only "⊬ from the empty context" as coherence datum will happily output $C_{\rm ai}$: "from any premise, everything follows". So coherence must be enforced on a non-empty designated context. This is the "theorems vs consequence" subtlety in its sharpest form.

### 3.2 The bold learner identifies CPC

For data $D$ (a set of sequents), let $\langle D\rangle$ be the least structural consequence relation containing $D$. The *structural version space* is
$$\mathcal S(D,A_0)=\{h \text{ structural}: D\subseteq h,\ A_0\nvdash_h\bot\}.$$
Here $A_0$ is a designated $\mathbf C_2$-consistent context; it must be non-empty in theorem-free fragments.

**Theorem 3.3 (coherence pins CPC) [proved].** Let the language be as in Thm 3.1.
* **(a) Finite collapse.** For $D\subseteq\mathbf C_2$: $\mathcal S(D,A_0)=\{\mathbf C_2\}$ iff $\langle D\rangle=\mathbf C_2$. A finite $D$ suffices. For example, take the four sequents
  * $\rhd p\to(q\to p)$,
  * $\rhd (p\to(q\to r))\to((p\to q)\to(p\to r))$,
  * $\rhd(\neg p\to\neg q)\to(q\to p)$,
  * $p,\ p\to q\rhd q$,
  
  with distinct atoms $p,q,r$, together with defining sequents for ∧ and ∨.
* **(b) Identification without bias.** Let $\mathcal H=(h_i)$ be any uniformly decidable family of structural consequence relations containing $\mathbf C_2$ (e.g. all finite-matrix logics). Let $M$ output the least $i$ such that $h_i$ contains the data seen so far and $A_0\nvdash_{h_i}\bot$. Then $M$ EX-identifies $\mathbf C_2$ from every text, with at most $i^\*$ mind changes, where $i^\*$ is the least index of $\mathbf C_2$. This holds *for every ordering of $\mathcal H$*: no simplicity, minimality or conservatism bias is needed.
* **(c) Each assumption is needed.**
  * *Structurality:* $\mathbf C_2$ plus the non-structural axiom $\rhd p_{17}$ is coherent and contains every text for $\mathbf C_2$.
  * *A coherence datum:* $C_{\mathrm{Fm}}$ contains every text.
  * *A non-empty context in theorem-free fragments:* $C_{\rm ai}$, by Prop 3.2.

*Proof.*
* (a) If $\langle D\rangle=\mathbf C_2$, then every $h\in\mathcal S$ satisfies $h\supseteq\mathbf C_2$, so $h\in\{\mathbf C_2,C_{\mathrm{Fm}}\}$ by Thm 3.1. $C_{\mathrm{Fm}}$ is excluded by $A_0$. Conversely, if $\langle D\rangle\subsetneq\mathbf C_2$, then $\langle D\rangle$ and $\mathbf C_2$ are distinct members of $\mathcal S$. The four sequents generate implicational-negation CPC by the standard completeness of the Łukasiewicz-style axiomatization [cited].
* (b) Take $j<i^\*$. Then $h_j\neq\mathbf C_2$.
  * If $h_j\not\supseteq\mathbf C_2$, some $s\in\mathbf C_2\setminus h_j$ eventually appears in the text, and $j$ is rejected from then on.
  * If $h_j\supseteq\mathbf C_2$, then $h_j=C_{\mathrm{Fm}}$ by Thm 3.1, which is rejected at once by $A_0$.
  * $h_{i^\*}$ is never rejected.
* (c) Immediate. ∎

*Assessment.* This is "a setup of the user's shape that provably works for formal (propositional) math". The learning algorithm is trivial. The whole content is Thm 3.1, and the proof of Thm 3.1 explains *why* it works: any rule invalid in CPC has a falsifying assignment. Substituting ⊤/⊥ along that assignment turns the rule into "from tautologies infer a contradiction". So a learner that generalizes uniformly (structurally) is caught at once by coherence. §6 turns this into a fallacy-elimination theorem.

### 3.3 Theorems versus consequence: structural completeness

Human corpora mostly contain *theorems* (proved statements), not explicit rules. So what do theorem-only data fix?

**Proposition 3.4 (largest structural consequence with given theorems) [proved].** Let $\mathrm{Th}$ be a substitution-closed set of formulas. Define
$$C_{\rm adm}(X)=\{\varphi:\forall\sigma\,(\sigma X\subseteq \mathrm{Th}\Rightarrow\sigma\varphi\in\mathrm{Th})\}.$$
Then $C_{\rm adm}$ is a structural closure operator with $C_{\rm adm}(\emptyset)=\mathrm{Th}$, and every structural $C$ with $C(\emptyset)=\mathrm{Th}$ satisfies $C\subseteq C_{\rm adm}$. In other words, $C_{\rm adm}$ is the consequence of all *admissible* rules: the structural completion.

*Proof.*
* *Extensive and monotone:* clear.
* *Idempotent:* if $\sigma X\subseteq\mathrm{Th}$, then $\sigma C_{\rm adm}(X)\subseteq\mathrm{Th}$ by definition.
* *Structural:* if $\varphi\in C_{\rm adm}(X)$ and $\sigma\tau X\subseteq\mathrm{Th}$, then $\sigma(\tau\varphi)\in\mathrm{Th}$, applying the definition to $\sigma\circ\tau$.
* *Maximal:* if $\varphi\in C(X)$ and $\sigma X\subseteq\mathrm{Th}=C(\emptyset)$, then $\sigma\varphi\in C(\sigma X)\subseteq C(C(\emptyset))=\mathrm{Th}$. ∎

**Proposition 3.5 [proved; cited for IPC].**
* (a) For CPC, $C_{\rm adm}=\mathbf C_2$ (*structural completeness*; Pogorzelski 1971 [cited (unverified)]). Hence, from theorem-only data, the *bold* learner (output the largest structural relation with the observed theorems) recovers full classical consequence.
  * A non-bold learner may converge to the rule-poor relation $C(X)=X\cup\mathrm{Taut}$. That relation is structural, coherent and has the right theorems, but it cannot chain inferences from premises. Under the user's slogan "an argument is a sequence of valid inferences", it is useless.
* (b) For IPC, $C^{\rm IPC}_{\rm adm}\supsetneq{\vdash_{\rm IPC}}$. Harrop's rule $\neg p\to(q\vee r)\ /\ (\neg p\to q)\vee(\neg p\to r)$ is admissible but not derivable (Harrop 1960; Rybakov 1997; Iemhoff 2001 for a basis) [cited (unverified)]. Both relations have the same theorems *and the same coherence profile*: $A\vdash^{\rm IPC}_{\rm adm}\bot\iff A\vdash_{\rm CPC}\bot$. So no learner fed theorems and coherence data can distinguish IPC-derivability from IPC-admissibility, and the bold learner picks admissibility.

*Proof.*
* (a) If $\varphi\notin\mathbf C_2(X)$, then $\sigma_v$ from Thm 3.1 maps $X$ into Taut and φ to a contradiction, so $\varphi\notin C_{\rm adm}(X)$.
* (b) Coherence profiles:
  * If $A$ is classically consistent, take a Boolean $v\models A$ and substitute $\top:=\bot\to\bot$ or ⊥ according to $v$. The image $\sigma_vA$ consists of classically true variable-free formulas. IPC proves every such formula: by induction, IPC decides each variable-free formula according to its classical value. So $A\nvdash_{\rm adm}\bot$.
  * If $A$ is classically inconsistent, then $A\vdash_{\rm IPC}\bot$ by Glivenko, as in Thm 3.6(a).
  
  The rest is cited. ∎

### 3.4 Intuitionistic logic: coherence is blind

**Theorem 3.6 [proved, modulo cited Glivenko/Jankov].**
* **(a) Same coherence data.** For every intermediate logic $L$ (IPC ⊆ L ⊆ CPC as consequence relations) and every finite $A$: $A\vdash_L\bot\iff A\vdash_{\rm CPC}\bot$. So $\mathcal A$-coherence data, for any $\mathcal A$, are identical across the continuum of intermediate logics.
* **(b) The bold learner fails on IPC.** A learner that outputs a maximal coherent structural hypothesis never outputs IPC, because CPC is a coherent proper extension.
* **(c) Impossibility.** There is a strictly increasing chain $L_1\subsetneq L_2\subsetneq\cdots$ of finitely axiomatizable intermediate logics whose union $L_\omega$ is an intermediate logic. No learner identifies $\{L_k:k\le\omega\}$ from text plus $\mathcal A$-coherence, for any $\mathcal A$.
* **(d) What works instead is minimality.** The conservative learner that outputs $\langle D_n\rangle$ (the structural closure of the data seen so far) BC-identifies every finitely axiomatizable structural target from every text. The text eventually contains the target's atomic generators, and $\langle D_n\rangle\subseteq$ target always.

*Proof.*
* (a) Glivenko (1929) [cited] gives $\vdash_{\rm CPC}\neg\psi\iff\vdash_{\rm IPC}\neg\psi$. With $\psi=\bigwedge A$ and the deduction theorem: $A\vdash_{\rm CPC}\bot\iff\vdash_{\rm CPC}\neg\bigwedge A\iff\vdash_{\rm IPC}\neg\bigwedge A\iff A\vdash_{\rm IPC}\bot$. Intermediate $L$ is sandwiched between the two.
* (b) Immediate.
* (c) The chain and the impossibility:
  * Jankov (1963/1968) [cited (unverified details); see Chagrov & Zakharyaschev 1997, *Modal Logic*, ch. 9] gives an infinite family of finite subdirectly irreducible Heyting algebras $B_1,B_2,\dots$ with $B_i\notin\mathbf{SH}(B_j)$ for $i\neq j$. Their Jankov formulas χ(B_i) satisfy: a Heyting algebra $B$ refutes $\chi(B_i)$ iff $B_i\in\mathbf{SH}(B)$.
  * Put $L_k=\mathrm{IPC}+\{\chi(B_1),\dots,\chi(B_k)\}$.
  * The chain is strictly increasing: $B_{k+1}$ validates $\chi(B_i)$ for $i\le k$ and refutes $\chi(B_{k+1})$.
  * Each $\chi(B_i)$ is classically valid when $|B_i|>2$, since $\mathbf{SH}(\mathbf 2)$ contains only $\mathbf 2$ and the trivial algebra. So $L_\omega\subseteq$ CPC is consistent.
  * By (a) the coherence information is target-independent. Cor 2.8 then applies.
* (d) Immediate. ∎

So for IPC the work is done by *minimality* (Remedy 1 of H2), not coherence (Remedy 2). The two remedies are complementary:
* minimality is correct when the target is at the bottom of its coherent version space;
* coherence-plus-boldness is correct when the target is at the top.

CPC sits at both ends, which is why everything works there.

### 3.5 Arithmetic

Hypotheses are now r.e. first-order theories $T\supseteq\mathrm{PA}$. World feedback is a Δ₀-oracle (computation), and ℕ is the intended model.

**Lemma 3.7 (Δ₀ feedback is subsumed by coherence above Q) [proved, standard].** If $T\supseteq Q$ is consistent, then $T$ proves every true Δ₀ sentence and no false one. Hence no finite or infinite amount of Δ₀ world feedback ever refutes a consistent extension of Q.

*Proof.* Q proves every true Δ₀ sentence (Σ₁-completeness of Q; e.g. Boolos, Burgess & Jeffrey, *Computability and Logic*) [cited]. If $T$ proved a false Δ₀ sentence δ, it would also prove ¬δ, which is true, and so be inconsistent. ∎

**Theorem 3.8 (no coherence-maximal r.e. hypothesis) [cited: Gödel 1931, Rosser 1936].** For every consistent r.e. $T\supseteq Q$ there is ρ with $T+\rho$ and $T+\neg\rho$ both consistent.
* So a bold learner restricted to r.e. hypotheses has no maximal choice, and every r.e. coherent hypothesis has two incompatible coherent refinements.
* Allowing non-r.e. hypotheses, the maximal coherent extensions of PA are the $2^{\aleph_0}$ complete consistent extensions. They agree with every Δ₀ datum and every PA-text.

**Theorem 3.9 (Turing-chain impossibility) [proved, modulo Gödel II].**
* *Setup.* Let $T_0=\mathrm{PA}$, $T_{k+1}=T_k+\mathrm{Con}(T_k)$ and $T_\omega=\bigcup_kT_k$ (Turing 1939; Feferman 1962) [cited]. Let $\mathcal A$ be any family of finite sets of *true* sentences. Let $\mathcal K\supseteq\{T_k:k\le\omega\}$ be any class whose members are possible targets; for instance, add the $T_k+\neg\mathrm{Con}(T_k)$.
* *Claim.* No learner identifies $\mathcal K$ in the limit from text, $\mathcal A$-coherence and a Δ₀ oracle.
* The Σ₁-unsound members $T_k+\neg\mathrm{Con}(T_k)$ have the following status:
  * (i) they are consistent, by Gödel II;
  * (ii) no Δ₀ data refute them (Lemma 3.7);
  * (iii) coherence refutes them only relative to accepted premises that prove $\mathrm{Con}(T_k)$. For example, if the target is $T_j$ with $j>k$, the text eventually contains $\mathrm{Con}(T_k)$, and the hypothesis plus that datum is inconsistent.

*Proof.*
* Every $T_k$ is sound, by induction: $\mathrm{Con}(T_k)$ is true if $T_k$ is sound. Hence each $T_k$ is consistent with every true $A$, and gives the same answers as the Δ₀ oracle.
* On targets $T_k$ the learner's extra information is therefore target-independent.
* The chain is strictly increasing by Gödel II. $T_\omega$ is its union, and Cor 2.8's locking-sequence argument applies verbatim to theories.
* (i)–(iii) are immediate. ∎

**Theorem 3.10 (coherence as a Π₁-truth detector; Popperian boldness; the Σ₂ barrier) [proved, modulo cited Shoenfield/Post].**
* **(a)** For Π₁ π: $\mathrm{PA}+\pi$ is consistent iff π is true.
* **(b)** For Σ₁ σ: σ true ⇒ $\mathrm{PA}+\sigma$ consistent, and the converse fails ($\sigma=\neg\mathrm{Con(PA)}$).
* **(c) The Popperian learner** converges to the correct truth value of every Σ₁∪Π₁ sentence with at most one mind change per sentence, using only coherence with PA. Its rule:
  * on a Π₁ sentence, say "true" until a PA-refutation is found;
  * on a Σ₁ sentence σ, say "false" until a PA-refutation of ¬σ is found.
* **(d) The naively bold learner fails.** This learner enumerates sentences and accepts each one that is coherent with what it has already accepted. It performs a Lindenbaum construction "in the limit", so its output depends on the enumeration order. It accepts $\neg\mathrm{Con(PA)}$ forever if that sentence comes before $\mathrm{Con(PA)}$.
* **(e) The Σ₂ barrier.** For every computable learner $M$ that receives a text of an r.e. theory, runs coherence searches and queries a Δ₀ oracle, there is a computable data presentation on which $M$ fails to converge to the truth value of some Σ₂ sentence.

*Proof.*
* (a) If π is true, $\mathrm{PA}+\pi\subseteq\mathrm{Th}(\mathbb N)$. If π is false, ¬π is a true Σ₁ sentence, so $\mathrm{PA}\vdash\neg\pi$ by Σ₁-completeness.
* (b) Soundness gives the first part. Gödel II gives the counterexample.
* (c) By (a), and by applying (a) to ¬σ, which is Π₁.
* (d) Both $\mathrm{Con(PA)}$ and $\neg\mathrm{Con(PA)}$ are individually coherent, so whichever comes first is accepted.
* (e) On computable presentations, $M$'s guesses form a computable function $g(\varphi,n)$. If they converge, the limit set is Δ₂ by Shoenfield's limit lemma (Shoenfield 1959; Gold 1965; Putnam 1965) [cited]. The set of true Σ₂ sentences is Σ₂-complete and not Δ₂ by Post's hierarchy theorem [cited]. ∎

*Reading.* In arithmetic, computation (Δ₀ world feedback) adds nothing beyond coherence with a Σ₁-complete base (Lemma 3.7, Thm 3.10(a)). What *does* matter is *how* boldness is applied:
* bold on universal (Π₁) claims, which coherence can refute;
* cautious on existential (Σ₁) claims, which need a witness.

This is exactly Popper's asymmetry, now a theorem about coherence-learners. Beyond Δ₂ nothing computable helps. The Rosser/Gödel alternatives are the permanent residue, and they are eliminated only by accepting stronger principles: reflection, Con(PA), or coherence with ZFC. Accepting PA's soundness is a justification that is not a PA-proof. This matches the brief's "principled justification beyond proof".

**Proposition 3.11 (complete theories are coherence-pinned) [proved; TOSU].** If $T$ is a complete consistent theory, the only consistent deductively closed theory containing $T$ is $T$. If $T$ is also r.e. (hence decidable), the learner of Thm 3.3(b) identifies $T$ from text plus one coherence datum.

Examples: real closed fields (Tarski), algebraically closed fields of fixed characteristic, Presburger arithmetic, dense linear orders, and Tarski's elementary geometry [cited].

*Relevance to physics.* Much of the formal core of a physics olympiad solution is real-closed-field algebra and elementary geometry. In that fragment the user's setup works as cleanly as in CPC. Incompleteness enters only with richer analysis, e.g. exponentiation or ODE solutions.

---

## 4. The learning-theoretic Carnap problem

### 4.1 Valuations, positions and the duality

A *valuation* is any $v:\mathrm{Fm}\to\{0,1\}$; it need not be compositional. Identify $v$ with its true-set, and topologize $2^{\mathrm{Fm}}$ as Cantor space. A *meaning hypothesis* is a set $V$ of admissible valuations. Let BV be the Boolean (truth-table) valuations, and define:
* $\Gamma\models^1_V\varphi$ iff every $v\in V$ with $v[\Gamma]=1$ has $v(\varphi)=1$;
* $\Gamma\models^m_V\Delta$ iff no $v\in V$ has $v[\Gamma]=1$ and $v[\Delta]=0$;
* $\mathrm{Val}(S)$: the valuations satisfying every sequent in $S$;
* $V^\cap$: the closure of $V$ under arbitrary intersections of true-sets. It includes the empty intersection $v_\top\equiv1$.

**The duality.** The sequent $\Gamma\rhd\Delta$ excludes exactly the basic clopen set $U(\Gamma,\Delta)=\{v:v[\Gamma]=1,v[\Delta]=0\}$, the valuations realizing the position $[\Gamma:\Delta]$. So, as data about $V$:
* **Inference data (sequents) are negative data about valuations.** "No admissible valuation realizes $[\Gamma:\Delta]$."
* **Coherence data and world feedback are positive data about valuations.** "Some admissible valuation realizes $[A:D]$"; "the actual world's valuation is admissible".

**Lemma 4.1 [proved].**
* (a) $\mathrm{Val}(\models^m_V)=\overline V$, the topological closure.
* (b) If $V$ is closed, then $C_V(X):=\bigcap\{v\in V:X\subseteq v\}$ is finitary, and $\mathrm{Val}(\models^1_V)=V^\cap$.
* (c) $\mathrm{BV}^\cap$ is the set of characteristic functions of CPC-theories, including Fm.

*Proof.*
* (a) Both inclusions:
  * If $v\notin\overline V$, a basic neighbourhood $U(\Gamma,\Delta)\ni v$ misses $V$. Then $\Gamma\models^m_V\Delta$, and $v$ violates it.
  * If $v\in\overline V$ violates a valid $\Gamma\rhd\Delta$, then $U(\Gamma,\Delta)$ is a neighbourhood of $v$, so it contains some $u\in V$, and $u$ violates it too. Contradiction.
* (b) Finitarity and the identification with $V^\cap$:
  * *Finitary:* if $\varphi\in C_V(X)$, then the closed sets $V\cap\{v:v(\varphi)=0\}$ and $\{v: v(x)=1\}$ for $x\in X$ have empty intersection. By compactness, a finite subfamily already does.
  * So $v$ respects all finite-premise single-conclusion sequents iff $C_V(v)=v$.
  * $\mathrm{Fix}(C_V)=V^\cap$: a fixed point $X$ is $\bigcap\{v\in V:X\subseteq v\}$; conversely, for $X=\bigcap W$ with $W\subseteq V$, $C_V(X)\subseteq\bigcap W=X$.
* (c) An intersection of theories is a theory. Conversely, a consistent theory $T$ is the intersection of the Boolean valuations extending it: if φ∉T, then completeness gives a Boolean $v\supseteq T$ with $v(\varphi)=0$. And Fm is the empty intersection. ∎

### 4.2 Single-conclusion data underdetermine; the denial-rank trichotomy

**Theorem 4.2 (Carnap 1943, in learning form) [proved].** $\models^1_{\mathrm{BV}}=\models^1_{W}$ for every $W$ with $\mathrm{BV}\subseteq W\subseteq\mathrm{BV}^\cap$.
* Consequently, no learner receiving data that are any function of the single-conclusion relation can distinguish BV from such a $W$. This covers a text, an informant, the whole relation at once, and any natural-deduction metarules with discharge (they are closure properties of the relation).
* The indistinguishable non-Boolean valuations are exactly the $v_T$ for CPC-theories $T$ that are not maximal consistent:
  * $v_\top$ ($T=\mathrm{Fm}$) violates the table for ¬;
  * $v_{\mathrm{Taut}}$ and every non-maximal consistent $v_T$ violate the tables for ¬, ∨ and → (with $\varphi,\neg\varphi\notin T$: $\varphi\vee\neg\varphi\in T$, and $\varphi\to\psi\notin T$ is possible with $v_T(\varphi)=0$);
  * every $v_T$ respects ∧, which is thus categorical even single-conclusionally.
* $\mathrm{BV}^\cap$ is closed and substitution-invariant ($v_T\circ\sigma=v_{\sigma^{-1}T}$), so the problem persists under structurality.

*Proof.* By Lemma 4.1(b), $\mathrm{Val}(\models^1_{\mathrm{BV}})=\mathrm{BV}^\cap$. Since $W\subseteq\mathrm{BV}^\cap$, every $w\in W$ satisfies $\models^1_{\rm BV}$, so $\models^1_{\rm BV}\subseteq\models^1_W$. Since $W\supseteq\mathrm{BV}$, also $\models^1_W\subseteq\models^1_{\rm BV}$. The rest is direct checking. ∎

For a valuation $v$, define its **denial rank**
$$d(v)=\min\{|\Delta|:\ \Gamma\models^m_{\rm BV}\Delta,\ v[\Gamma]=1,\ v[\Delta]=0\},$$
the fewest denials in a valid position-exclusion that $v$ violates (with $d=\infty$ if there is none).

**Theorem 4.3 (denial-rank trichotomy) [proved].** For every valuation $v$:
* $d(v)=0$ iff the true-set of $v$ is classically inconsistent;
* $d(v)=1$ iff it is consistent but not deductively closed;
* $d(v)=2$ iff it is a consistent, deductively closed, non-maximal theory;
* $d(v)=\infty$ iff $v\in\mathrm{BV}$.

*Proof.*
* $d=0$ means some finite $\Gamma\subseteq v$ with $\Gamma\models\emptyset$, i.e. inconsistency.
* If $v$ is consistent, $d(v)\le1$ iff some finite $\Gamma\subseteq v$ and some φ∉v have $\Gamma\models\varphi$, i.e. $v$ is not closed.
* If $v=v_T$ for a consistent non-maximal theory, there is φ with $\varphi,\neg\varphi\notin T$, and $\emptyset\models\{\varphi,\neg\varphi\}$ gives $d\le2$.
* If $T$ is maximal consistent, $v\in\mathrm{BV}$ and satisfies everything. ∎

*Reading.* The three kinds of supervision available to the user's learner sort exactly by denial rank:

| supervision | denial rank of what it excludes | excludes |
|---|---|---|
| coherence ("no good arguments for both P and ¬P") | 0 | $v_\top$ and inconsistent valuations |
| imitation of single-conclusion inferences | 1 | non-closed valuations |
| **exhaustiveness** ("one may not deny both P and ¬P", "one of the cases must hold") | 2 | $v_{\rm Taut}$, all *gappy* theories |

So a learner trained on imitation plus a coherence loss is provably free to settle on gappy, undecided valuations. It can stay consistent and inferentially competent while never committing on open questions. Pinning classical meaning needs a loss on positions with *two* denials. The bilateral reading of $\rhd p,\neg p$ is "it is out of bounds to deny both". The bilateral sequent $+\Gamma,-\Delta\rhd\pm\varphi$ (Rumfitt 2000; Smiley 1996) [cited] is semantically the multiple-conclusion sequent $\Gamma\rhd\Delta,\varphi$ (or $\Gamma,\varphi\rhd\Delta$). So "bilateral single-conclusion" equals "unilateral multiple-conclusion", and denials are what carry rank-2 information.

### 4.3 Bilateral determinacy with a finite tell-tale

Let TT be the 11 truth-table schemata:
* ¬: $\varphi,\neg\varphi\rhd\ $ and $\ \rhd\varphi,\neg\varphi$;
* ∧: $\varphi\wedge\psi\rhd\varphi$, $\ \varphi\wedge\psi\rhd\psi$, $\ \varphi,\psi\rhd\varphi\wedge\psi$;
* ∨: $\varphi\rhd\varphi\vee\psi$, $\ \psi\rhd\varphi\vee\psi$, $\ \varphi\vee\psi\rhd\varphi,\psi$;
* →: $\rhd\varphi,\varphi\to\psi$, $\ \psi\rhd\varphi\to\psi$, $\ \varphi,\varphi\to\psi\rhd\psi$.

Write $\mathrm{TT}(p,q)$ for their 11 instances with distinct atoms. A meaning $V$ is *structural* if $v\in V$ implies $v\circ\sigma\in V$ for every substitution σ.

**Theorem 4.4 (Shoesmith–Smiley/Carnap determinacy, with a 12-datum tell-tale) [proved].**
* (a) $\mathrm{Val}(\mathrm{TT})=\mathrm{BV}$, and BV is closed. Hence $\models^m_{\rm BV}$ determines BV (Lemma 4.1(a)).
* (b) Let $V$ be any structural meaning such that every $v\in V$ satisfies the 11 sequents $\mathrm{TT}(p,q)$, and suppose a single coherence datum holds: some position, e.g. the empty one $[\ :\ ]$, is in bounds, i.e. $V\neq\emptyset$. Then $V=\mathrm{BV}$.
* (c) Hence, among *all* structural meanings, BV is identified *finitely*: by 11 positive bilateral data plus 1 coherence datum. Without the coherence datum, $V=\emptyset$ (the trivial logic: all positions out of bounds) survives every positive datum. That survivor is the Gold over-generalization.
* (d) Without structurality no finite set of data suffices. A valuation that is Boolean except at a single large formula χ is refuted only by data mentioning χ. Identification in the limit still holds via the text.

*Proof.*
* (a) Each schema enforces one row-condition of the corresponding truth table, as checked row by row; together they say exactly that $v$ is a homomorphism into the 2-element Boolean algebra. BV is an intersection of clopen conditions, so it is closed.
* (b) Show $V\subseteq\mathrm{BV}$, then equality.
  * *$V\subseteq\mathrm{BV}$.* Let $v\in V$ and consider an instance $\sigma(\mathrm{TT}_j(p,q))$. Then $v$ satisfies it iff $v\circ\sigma$ satisfies $\mathrm{TT}_j(p,q)$, which holds because $v\circ\sigma\in V$. So $V\subseteq\mathrm{Val}(\mathrm{TT})=\mathrm{BV}$.
  * *Equality.* Take any $v\in V$ (nonempty) and any $u\in\mathrm{BV}$. Let $\sigma(p)=p_0\vee\neg p_0$ if $u(p)=1$ and $\sigma(p)=\neg(p_0\vee\neg p_0)$ otherwise. Then $v\circ\sigma$ is Boolean and agrees with $u$ on atoms, so $u=v\circ\sigma\in V$.
* (c) Follows from (b).
* (d) The finite data mention finitely many formulas. ∎

The three two-conclusion schemata in TT ($\rhd\varphi,\neg\varphi$, $\ \varphi\vee\psi\rhd\varphi,\psi$, $\ \rhd\varphi,\varphi\to\psi$) are exactly the rank-2 data that $v_{\rm Taut}$ violates. The script `T2-checks/carnap_check.py` verifies Lemma 4.1–Thm 4.4 on the 16 formulas of depth ≤ 1 over two atoms:
* TT leaves exactly the 4 Boolean restrictions;
* all valid single-conclusion sequents leave exactly the 14 members of the ∩-closure;
* adding 0-denial (coherence) sequents leaves exactly those 14 minus $v_\top$.

### 4.4 Two other remedies, and what world feedback does

**Proposition 4.5 (compositional prior) [proved].** Among all 2-element matrices $(\{0,1\},f_\neg,f_\wedge,f_\vee,f_\to,\{1\})$, exactly one validates all twelve single-conclusion rules listed below and is non-trivial: the standard one. The rules:
* explosion $p,\neg p\rhd q$;
* $\neg\neg p\rhd p$ and $p\rhd\neg\neg p$;
* the three ∧ rules;
* ∨-introduction (two rules);
* disjunctive syllogism $p\vee q,\neg p\rhd q$;
* modus ponens;
* $q\rhd p\to q$ and $\neg p\rhd p\to q$.

So if the meaning hypothesis class is restricted to *single truth-functional interpretations*, single-conclusion data suffice.

*Proof.* Row by row:
* *¬:* explosion forces $f_\neg(1)=0$; then $p\rhd\neg\neg p$ forces $f_\neg(0)=1$.
* *∧:* the three rules force the ∧ table.
* *∨:* ∨-introduction forces $f_\vee(a,1)=f_\vee(1,b)=1$; disjunctive syllogism at $p=q=0$ forces $f_\vee(0,0)=0$.
* *→:* modus ponens forces $f_\to(1,0)=0$; the last two rules force the remaining rows to 1.

`T2-checks/matrix_check.py` confirms by brute force over all $4\cdot16^3$ matrices. ∎

This is the analogue of Angluin-style class restriction in Gold's setting. Compare Bonnay & Westerståhl (2016), "Compositionality solves Carnap's problem", *Erkenntnis* [cited (unverified); their notion of compositionality is more general]. Garson (2013, *What Logics Mean*) and Raatikainen (2008), with the reply by Murzi & Hjortland (2009), discuss the natural-deduction versions [cited].

**Proposition 4.6 (world feedback) [proved; TOSU].**
* World feedback presents (finite restrictions of) the actual valuation, which is Boolean. It never refutes any $V\supseteq\mathrm{BV}$, in particular $\mathrm{BV}^\cap$. So it cannot by itself fix meanings.
* Under the compositional prior of Prop 4.5, world feedback identifies the truth tables, provided the world exhibits every row. Each observation of the values of φ, ψ and φ∘ψ reveals one row.

### 4.5 Gold versus Carnap, made precise

| | Gold (sequent space) | Carnap (valuation space) |
|---|---|---|
| hypothesis | consequence relation ⊢ (a language of sequents) | admissible valuations $V$ |
| positive data | valid sequents (text) | world / coherent positions |
| negative data | in-bounds positions (coherence) | sequents (excluded positions) |
| over-generalization | too many sequents; extreme: trivial logic | too many valuations: $v_\top$, $v_{\rm Taut}$, … |
| failure mode | *learnability*: finite data never exclude supersets | *identifiability*: even complete single-conclusion data determine $V$ only up to $V^\cap$ |
| remedy | one negative datum (coherence); Post-completeness | data of the right *shape*: 2-denial (bilateral/multiple-conclusion); or a compositional prior |

So hypothesis H3 is half right. Carnap's $v_\top$ is the twin of Gold's trivial over-generalization, and coherence removes both. But $v_{\rm Taut}$ is a different phenomenon: a Horn-closure (∩-closure) blindness of single-conclusion data. Coherence does not touch it. Only exhaustiveness data or a compositional prior do. With both fixes and structurality, classical meaning is *finitely* identifiable (Thm 4.4).

---

## 5. tonk, harmony and conservativity

**Proposition 5.1 (tonk) [proved].** Let ⊢ be transitive (closed under cut) and contain $\varphi\rhd\varphi\ \mathrm{tonk}\ \psi$ and $\varphi\ \mathrm{tonk}\ \psi\rhd\psi$.
* Then $\varphi\vdash\psi$ for all φ, ψ.
* If $\mathcal A$ contains a non-empty context, or ⊢ has a theorem τ, coherence refutes ⊢ via a 2-step argument: $a\rhd a\,\mathrm{tonk}\,\bot\rhd\bot$, or starting from $\rhd\tau$.
* In a theorem-free base with $\mathcal A=\{\emptyset\}$, tonk survives coherence. For example, $\mathbf C_2^{\wedge\vee}$ plus tonk generates exactly $C_{\rm ai}$, as in Prop 3.2.
* Without cut, tonk need not trivialize. Cook (2005), "What's wrong with tonk(?)", *JPL* [cited (unverified)], gives a non-transitive consequence relation in which tonk is harmless.

*Proof.* The first claim is one cut. For the theorem-free case: no derivation without premises exists, because every rule has premises. From any premise, tonk yields everything. ∎

So the user's principle that "an argument is a chain of valid inferences" (transitivity) is double-edged. It is what lets a single bad rule poison everything, and it is also what lets coherence catch it.

**Proposition 5.2 (coherence ≠ conservativity) [proved].** Add classical negation rules ($\neg\neg$-elimination) to the implicational fragment of IPC. The result is the {→,¬} fragment of CPC.
* It is coherent.
* It is not conservative over intuitionistic →, because it proves Peirce's law $((p\to q)\to p)\to p$, which IPC does not.

*Proof.* The extension is CPC, which proves Peirce's law. Intuitionistic countermodel: the two-world Kripke frame $w\le w'$ with $p$ true only at $w'$ and $q$ true nowhere. Then $p\to q$ fails at both worlds, $(p\to q)\to p$ holds at $w$ vacuously, and $p$ fails at $w$. ∎

So the conservativeness-constrained learner (Belnap 1962 [cited]) rejects classical negation over intuitionistic positive logic, while the coherence-constrained learner accepts it. In standard natural-deduction settings, harmony with normalization and the subformula property gives conservativity (Prawitz 1965; Dummett 1991) [cited (unverified exact scope)]. Harmony is a *decidable syntactic* sufficient condition that a learner can enforce a priori.

Let a *finite rule system* be a Post canonical system or elementary formal system over a finite alphabet. Every r.e. set is the theorem set of one (Post 1943; Smullyan 1961) [cited].

**Theorem 5.3 (complexity of the two filters) [proved via standard reductions].**
* (a) $\{R: R\nvdash\bot\}$ is Π₁-complete.
* (b) There is a fixed finite base $B$ such that $\{N: B+N\text{ is conservative over }B\}$, where $N$ ranges over finite systems in an extended vocabulary, is Π₂-complete.
* (c) Hence coherence is decidable in the limit with at most one mind change ("coherent" until a ⊥-derivation is found). Conservativity is *not* decidable in the limit by any computable learner, because Π₂-complete sets are not Δ₂. It is only refutable in the limit, in the Σ₂/Π₂ sense of Kelly (1996, *The Logic of Reliable Inquiry*) [cited].
* (d) If the base $B$ is decidable, as for CPC or IPC, conservativity drops to Π₁.

*Proof.*
* (a) Membership is Π₁. For hardness, simulate the computation of $\varphi_e(e)$ by rules and add "halting configuration ⊢ ⊥". Then $R_e$ is coherent iff $e\notin K$.
* (b) Membership: "∀s∀ derivations of $s$ in $B+N$, ∃ a derivation in $B$" is Π₂. For hardness:
  * Let $B$ be a universal system deriving $T(\bar x,\bar e)$ iff $\varphi_e(x)\!\downarrow$, designed so that $T$-strings are never premises.
  * Let $B$ also contain rules deriving $\mathrm{Num}(\bar n)$ for exactly the unary numerals. Let $N_e$ add a new symbol $c$ with rules $\rhd c\,\bar e$ and $c\,y,\ \mathrm{Num}(x)\rhd T(x,y)$ (schematic in $x,y$).
  * The old-vocabulary theorems of $B+N_e$ are $\mathrm{Thm}(B)\cup\{T(\bar n,\bar e):n\in\mathbb N\}$.
  * So $B+N_e$ is conservative iff $\forall n\,\varphi_e(n)\!\downarrow$ iff $e\in\mathrm{Tot}$, which is Π₂-complete.
* (c) Shoenfield's limit lemma.
* (d) Immediate. ∎

*Learning reading.* A coherence filter can be built into an EX-learner. The incoherent hypotheses below the target are each eventually excluded forever, as in Thm 3.3(b). A conservativity filter cannot be, in general. The learner-friendly norms are coherence plus decidable syntactic harmony. Global conservativity is an ideal that no limiting procedure can enforce.

---

## 6. Systematic human errors, and Kripkenstein

Human data contain fallacious steps. A learner with a *generalization operator* 𝒢 (e.g. structural closure of the anti-unification of observed steps) turns a finite set $F$ of fallacious instances into rules $\mathcal G(F)$.

**Theorem 6.1 (elimination criterion) [proved; TOSU].**
* Coherence eliminates the generalized fallacy, i.e. it is eventually refuted (for OH, at a cost charged against the $\log_2(1/w^\*)$ budget), iff $h^\*\oplus\mathcal G(F)$ is $\mathcal A$-incoherent.
* *Semantic sufficient condition for survival.* Suppose $h^\*$ is sound for a class of intended structures 𝔐. If every $A\in\mathcal A$ holds in some $\mathfrak M\in\mathfrak M$ that also validates $\mathcal G(F)$, the fallacy survives.

*Proof.* The first part is Theorem 2.6(i) applied to $h=h^\*\oplus\mathcal G(F)$. The second is soundness: if $\mathfrak M$ validates $h^\*$, $\mathcal G(F)$ and $A$, then $A\nvdash\bot$. ∎

**Corollary 6.2 (all structural propositional fallacies die, quickly) [proved; sketch for the size bound].** Let 𝒢 be structural closure and let $h^\*\supseteq\mathbf C_2$ be structural and coherent (hence $h^\*=\mathbf C_2$ by Thm 3.1). Then every CPC-invalid rule $r=\Gamma/\varphi$ is eliminated.
* *Witness.* Substitute ⊤/⊥ along a falsifying assignment. The premises become tautologies and the conclusion a contradiction.
* *Size.* Given the assignment, the ⊥-derivation has size polynomial in $|r|$ in any Frege system. Frege systems prove true constant formulas by bottom-up evaluation in quadratic size [sketch; standard]. Finding the assignment is an NP-search.

Instances, checked by `T2-checks/fallacy_check.py`:

| fallacy | rule | witness substitution |
|---|---|---|
| affirming the consequent | $q,\ p\to q\ /\ p$ | $p:=\bot,\ q:=\top$ |
| denying the antecedent | $\neg p,\ p\to q\ /\ \neg q$ | $p:=\bot,\ q:=\top$ |
| conversion | $p\to q\ /\ q\to p$ | $p:=\bot,\ q:=\top$ |
| illicit contraposition | $p\to q\ /\ \neg p\to\neg q$ | $p:=\bot,\ q:=\top$ |
| "or" read as "xor" (added to ∨) | $p\vee q,\ p\ /\ \neg q$ | $p:=q:=\top$ |

Examples where coherence does *not* eliminate the fallacy, or does so only in suitable contexts:

1. **Quantifier swap** $\forall x\exists yR\ /\ \exists y\forall xR$, schematic in $R$.
   * FOL plus the swap is sound in one-element structures, hence coherent for $\mathcal A=\{\emptyset\}$.
   * Its coherent alternative meaning is "the domain is a singleton". Indeed it proves $\forall x\forall y\,x{=}y$ via $R:=(x{=}y)$.
   * Any designated context with two distinct objects (e.g. $0\neq1$) kills it.
   
   So coherence works here only if the learner's designated contexts are *substantive*. FOL, unlike CPC, is not Post-complete.
2. **Gambler's fallacy.** The rule: from "fair coin" and "last $n$ flips heads", infer $P(\text{tails next})>\frac12$.
   * It is incoherent with any designated context that includes *independence*, since the probability calculus then yields $=\frac12$.
   * Without independence it is coherent. An anti-persistent stationary Markov chain with switching probability 0.6 has all marginals $\frac12$ and validates the rule.
   * Its coherent alternative meaning is "the process is anti-persistent", the urn model. Only world feedback (frequencies) or an accepted independence premise eliminates it.
3. **Base-rate neglect** as a schema, $P(E|H)=a\ /\ P(H|E)=a$.
   * Apply it to $H$ and ¬H with $P(E|H)=P(E|\neg H)=0.9$. It yields $P(H|E)+P(\neg H|E)=1.8$, contradicting additivity.
   * So it is eliminated once additivity is in the target and the schema is uniform.
4. **Affirming the consequent restricted to background laws** (abduction): from $q$ and a law $(p\to q)\in K$, infer $p$.
   * Its closure is contained in $\mathrm{Cn}(K\cup A\cup\{q\to p:(p\to q)\in K\})$. So it is coherent whenever the *completion* (conditional perfection; Geis & Zwicky 1971; Clark 1978 [cited]) is consistent with the context. Example: $K=\{\mathit{rain}\to\mathit{wet}\}$, $A=\{\mathit{wet}\}$.
   * It is eliminated when two exclusive laws share a consequent: $K\ni \mathit{rain}\to\mathit{wet},\ \mathit{sprinkler}\to\mathit{wet},\ \neg(\mathit{rain}\wedge\mathit{sprinkler})$.
   * Its coherent alternative meaning is "if" read as "iff" in a closed world.

**Proposition 6.3 (without uniformity, coherence is toothless) [proved; TOSU].** For any coherent $h^\*$ and any set $F$ of extra sequents with $h^\*\oplus F$ $\mathcal A$-coherent, the non-structural hypothesis $h^\*\oplus F$ survives forever. Example: $\mathbf C_2+\{\rhd p_{17}\}$, the "quus" of propositional logic.

**Theorem 6.4 (the Kripkensteinian residue) [proved; TOSU].** Define $\mathrm{Alt}_{\mathcal G}(h^\*,\mathcal A)=\{h\in\mathcal G\text{-closed hypotheses}: h\supseteq h^\*,\ h\ \mathcal A\text{-coherent}\}$. In the limit of complete data, this is exactly the set of hypotheses that no combination of positive data and coherence ever refutes (Thm 2.6(ii)). Its value in the three test cases:
* (i) 𝒢 = structural, $h^\*=\mathbf C_2$: $\mathrm{Alt}=\{\mathbf C_2\}$ (Thm 3.1).
* (ii) 𝒢 = structural, $h^\*=$ IPC: $\mathrm{Alt}\supseteq$ all intermediate logics, by Thm 3.6(a).
* (iii) Arithmetic: $\mathrm{Alt}=$ all consistent extensions, including non-standard completions such as $\mathrm{PA}+\neg\mathrm{Con(PA)}$ (Thms 3.8–3.10).

**Division of labour (answer to H7).** Each mechanism is responsible for a different class of rival hypotheses:
* **Community practice** (positive data) eliminates *under*-generalizations. This is Gold's text.
* **Uniformity/simplicity** (structurality, MDL, anti-unification) eliminates *gerrymandered* alternatives (Prop 6.3: quus as an atom-specific or bounded patch).
  * It is vocabulary-relative, which is Goodman's point.
  * It is what converts an instance-level fallacy into a schema that coherence can refute (Cor 6.2).
* **Coherence** eliminates *uniform alternatives that conflict* with other accepted uniform rules. Examples: tonk; AC as a schema; quus as a second rule for "+" alongside the recursion equations $x+Sy=S(x+y)$, which give $57+58=S(57+57)$.
* **Nothing in the setup** eliminates coherent, uniform alternatives agreeing with all data. For CPC there are none. For arithmetic they are exactly the Gödel/Rosser/non-standard alternatives, the precise mathematical content of Kripkenstein-for-arithmetic, close to Skolemite or Putnamian skepticism. They are eliminated only by accepting reflection principles or stronger theories on other grounds.

---

## 7. Contexts

Coherence data are indexed by *designated* contexts $\mathcal A$. Deriving ⊥ from an undesignated hypothesis (reductio) is never penalized. The eternalist picture is the special case $\mathcal A=\{\emptyset,K\}$, with $K$ the background. Everything above is relative to $\mathcal A$. The one danger is designating an inconsistent context.

**Proposition 7.1 (mis-designation forces global sub-classicality) [proved].** Let $C$ be structural and $\mathcal A$-coherent, with some $A\in\mathcal A$ classically inconsistent. Then:
* (a) $C\not\supseteq\mathbf C_2$. Moreover, for every CPC-derivation of ⊥ from $A$, some rule *schema* used in it is not $C$-valid: its most general instance (distinct atoms) is not in $C$. So the learner loses that classical schema as a uniform rule, everywhere.
* (b) If $A\supseteq\{\alpha,\neg\alpha\}$ — the typical clash, as in "air pressure is 0" versus the background-derivable "air pressure is not 0" — then $p,\neg p\nvdash_C\bot$ for atoms $p$: $C$ is paraconsistent at the atomic level, *everywhere*, not only in that context.

*Proof.*
* (a) The first claim is immediate. For the second: some specific step instance used in the derivation is not in $C$, otherwise chaining gives $A\vdash_C\bot$. By structurality, the general instance of its schema is then not in $C$ either, because the specific instance is a substitution instance of it.
* (b) If $p,\neg p\vdash_C\bot$, then substituting α gives $\alpha,\neg\alpha\vdash_C\bot$, and monotonicity gives $A\vdash_C\bot$. ∎

*Reading.* A coherence loss applied to "idealization plus full background" teaches the learner a paraconsistent logic for *all* reasoning. This is the formal content of the user's worry, and of L7's point that @ must be phenomenological. The fix is to designate only consistent chunks $\Gamma\cup K_\Gamma$ (chunk-and-permeate; Brown & Priest 2004 [cited]) and to learn the import filters. With soft weights, the damage from residual mis-designations is bounded by Thm 2.5: the factor $m\ln(1/\beta)$ counts false alarms. Truthful designation is soundness-critical (L2 §H6), and this proposition says *how* untruthfulness propagates under structurality.

---

## 8. Upshot for the user's program, honestly assessed

1. *Learning algorithm.* Generalize human steps to schemata (structural, MDL-ordered hypotheses). Announce the coalition-unanimous rule set of a weighted half of the surviving hypotheses (OH). Let an adversarial prover search for ⊥ in designated contexts. Delete or penalize the coalition on detection. Re-validate cached lemmas.
   * **Guarantees:** at most $\log_2(1/w^\*)$ detections (Thm 2.2), robust to false alarms (Thm 2.5).
   * **Non-guarantees:** silent over-generalizations (Thm 2.6) and Gold limits (Cor 2.8).
2. *Formal math.*
   * Propositional logic and complete theories (RCF, geometry, Presburger arithmetic) are provably learned by this setup from positive data plus one coherence datum (Thm 3.3, Prop 3.11). This is mathematically shallow but real: Post-completeness is the reason.
   * Intuitionistic logic needs minimality, not coherence (Thm 3.6).
   * Arithmetic leaves an ineliminable residue (Thms 3.8–3.10). The best coherence policy there is Popperian (Thm 3.10(c)), and computation adds nothing beyond coherence with a Σ₁-complete base.
3. *Meaning.*
   * Imitation plus coherence fixes inferential role but not classical truth-conditions. It leaves "gappy" valuations (Thm 4.3).
   * An exhaustiveness loss (2-denial data, e.g. "these cases are exhaustive") or a compositional prior is needed (Thm 4.4, Prop 4.5).
   * This is a concrete, testable prediction for LLM-style training: imitation plus a contradiction penalty should produce consistent but *noncommittal* reasoners.
4. *Norms on new rules.* Coherence is limit-decidable; conservativity is not (Thm 5.3). Use coherence plus decidable harmony checks.
5. *Fallacies.*
   * Propositional fallacies die under coherence the moment they are generalized uniformly (Cor 6.2).
   * Quantifier-swap-like fallacies die only in substantive designated contexts.
   * Probabilistic fallacies die only if the relevant independence or additivity principles are accepted.
   * Some, like conditional perfection and the gambler's fallacy, are coherent alternative meanings that only world feedback can remove.
6. *Contexts.* Designation is soundness-critical, and mis-designation propagates globally under uniformity (Prop 7.1).

## 9. Open problems

1. **Two-sided optimal mistake bounds.** Find a combinatorial dimension (a Littlestone-type tree with bag-labelled incoherence moves) that characterizes the minimax number of detected errors of both types. For product classes the answer is $\log_2|\mathcal H|$. For cautious learners it can be $|\mathcal H|-1$ (Prop 2.9). What is the general answer, and which learners achieve it?
2. **Quantitative Post-completeness beyond CPC.** For which first-order or modal targets does every uniform invalid rule have a *short* coherence witness in *some* designated context? (Cor 6.2 gives this for CPC.) Is there a "coherence-witness complexity" hierarchy?
3. **A coherence-pinnedness characterization.** Characterize the structural logics $L$ (or theories) with $U(L)=\{L\}$ for natural families of designated contexts. Is it exactly structural Post-completeness relative to $\mathcal A$? Does it interact with structural completeness as in Props 3.4–3.5?
4. **Context learning.** Model the import filter $K\mapsto K_\Gamma$ as a learned object. Prove that coherence plus world feedback on *exported* claims identifies a correct filter, or give a counterexample. L7's one-sidedness of export tolerances suggests world feedback is necessary.
5. **Exhaustiveness losses in practice.** Do 2-denial losses destabilize training? With noisy data they might force premature commitment, which is an eternalism-style failure.
6. **Iterated reflection as learning.** Is there a principled learner over Turing–Feferman progressions that converges to "the right amount of reflection", given some natural notion of feedback?

## 10. Suggested experiments

1. **Doctrinal paradox in verifier ensembles.** Train $k$ step verifiers on the same propositional or algebra corpus with different seeds. Chain proofs (a) by stepwise majority and (b) by coalition-unanimity. Measure the incoherence rate and the information per detected incoherence (the fraction of the ensemble refutable). Prediction: (a) produces uninformative incoherences (Thm 2.4); (b) halves.
2. **Fallacy injection.** Use propositional and FOL natural-deduction corpora, and inject affirming the consequent, quantifier swap and conditional perfection at rate ε. Learn schemata by anti-unification plus MDL, with an adversarial ⊥-prover over designated contexts. Predictions:
   * affirming the consequent is eliminated after about one detection (Post witness);
   * quantifier swap survives under $\mathcal A=\{\emptyset\}$ and dies with $0\neq1$ designated;
   * conditional perfection survives in closed-world contexts.
3. **Carnap in a neural truth-assigner.** Train a model to assign truth values to formulas from (a) single-conclusion inference imitation plus a contradiction penalty, and (b) the same plus a 2-denial penalty. Prediction: (a) converges to gappy valuations that commit on neither $p$ nor ¬p for open atoms; (b) to Boolean valuations.
4. **Popperian versus naive boldness on bounded arithmetic.** Use Π₁/Σ₁ statements about small programs, with coherence checked by a bounded prover. Show that naive boldness gives order-dependent completions and that Popperian boldness converges to the truth.
5. **Mis-designated physics contexts.** Train with contexts "idealization plus full background". Measure the loss of explosion and disjunctive syllogism (Prop 7.1). Then switch to chunk-designation and observe recovery.

---

## References

Status markers: ✓ means confident in the bibliographic data; (u) means unverified detail.

* Angluin, D. (1980). Inductive inference of formal languages from positive data. *Information and Control* 45:117–135. ✓
* Belnap, N. (1962). Tonk, plonk and plink. *Analysis* 22:130–134. ✓
* Blum, L., Blum, M. (1975). Toward a mathematical theory of inductive inference. *Information and Control* 28:125–155. ✓
* Bonnay, D., Westerståhl, D. (2016). Compositionality solves Carnap's problem. *Erkenntnis* 81:721–739. (u)
* Boolos, G., Burgess, J., Jeffrey, R. *Computability and Logic* (5th ed. 2007). ✓
* Brown, B., Priest, G. (2004). Chunk and permeate, a paraconsistent inference strategy. Part I. *J. Phil. Logic* 33:379–388. ✓ (per L7)
* Carnap, R. (1943). *Formalization of Logic*. Harvard UP. ✓
* Chagrov, A., Zakharyaschev, M. (1997). *Modal Logic*. OUP. ✓
* Clark, K. (1978). Negation as failure. In *Logic and Data Bases*. ✓
* Cook, R. (2005). What's wrong with tonk(?). *J. Phil. Logic* 34:217–226. (u)
* Dietrich, F., List, C. (2007/2008). Papers on judgment aggregation and oligarchies. (u: exact titles and theorems)
* Dietterich, T., Lathrop, R., Lozano-Pérez, T. (1997). Solving the multiple instance problem with axis-parallel rectangles. *Artificial Intelligence* 89:31–71. ✓
* Dummett, M. (1991). *The Logical Basis of Metaphysics*. ✓
* Feferman, S. (1962). Transfinite recursive progressions of axiomatic theories. *JSL* 27:259–316. ✓
* Garson, J. (2013). *What Logics Mean*. CUP. ✓
* Geis, M., Zwicky, A. (1971). On invited inferences. *Linguistic Inquiry* 2:561–566. ✓
* Glivenko, V. (1929). Sur quelques points de la logique de M. Brouwer. ✓
* Gold, E. M. (1965). Limiting recursion. *JSL* 30:28–48. ✓
* Gold, E. M. (1967). Language identification in the limit. *Information and Control* 10:447–474. ✓
* Harrop, R. (1960). Concerning formulas of the types A→B∨C, A→∃xB(x). *JSL* 25:27–32. (u)
* Iemhoff, R. (2001). On the admissible rules of intuitionistic propositional logic. *JSL* 66:281–294. (u)
* Jankov, V. A. (1968). The construction of a sequence of strongly independent superintuitionistic propositional calculi. *Soviet Math. Dokl.* 9. (u)
* Kelly, K. (1996). *The Logic of Reliable Inquiry*. OUP. ✓
* Kornhauser, L., Sager, L. (1986). Unpacking the court. *Yale Law Journal* 96. ✓
* Kripke, S. (1982). *Wittgenstein on Rules and Private Language*. ✓
* List, C., Pettit, P. (2002). Aggregating sets of judgments: an impossibility result. *Economics and Philosophy* 18:89–110. ✓
* Littlestone, N. (1988). Learning quickly when irrelevant attributes abound. *Machine Learning* 2:285–318. ✓
* Littlestone, N., Warmuth, M. (1994). The weighted majority algorithm. *Information and Computation* 108:212–261. ✓
* Murzi, J., Hjortland, O. (2009). Inferentialism and the categoricity problem: reply to Raatikainen. *Analysis* 69:480–488. (u)
* Pogorzelski, W. A. (1971). Structural completeness of the propositional calculus. *Bull. Acad. Polon. Sci.* 19. (u)
* Post, E. (1921). Introduction to a general theory of elementary propositions. *Amer. J. Math.* 43. ✓
* Prawitz, D. (1965). *Natural Deduction*. ✓
* Prior, A. (1960). The runabout inference-ticket. *Analysis* 21:38–39. ✓
* Putnam, H. (1965). Trial and error predicates and the solution to a problem of Mostowski. *JSL* 30:49–57. ✓
* Raatikainen, P. (2008). On rules of inference and the meanings of logical constants. *Analysis* 68:282–287. (u)
* Restall, G. (2005). Multiple conclusions. In *Logic, Methodology and Philosophy of Science XII*. ✓
* Rosser, J. B. (1936). Extensions of some theorems of Gödel and Church. *JSL* 1:87–91. ✓
* Rumfitt, I. (2000). "Yes" and "No". *Mind* 109:781–823. ✓
* Rybakov, V. (1997). *Admissibility of Logical Inference Rules*. Elsevier. ✓
* Shoenfield, J. (1959). On degrees of unsolvability. *Annals of Math.* 69:644–653. ✓
* Shoesmith, D. J., Smiley, T. J. (1978). *Multiple-Conclusion Logic*. CUP. ✓
* Smiley, T. (1996). Rejection. *Analysis* 56:1–9. ✓
* Smullyan, R. (1961). *Theory of Formal Systems*. ✓
* Tokarz, M. (1973). Connections between some notions of completeness of structural propositional calculi. *Studia Logica* 32. (u)
* Turing, A. (1939). Systems of logic based on ordinals. *Proc. LMS* 45. ✓
* Wójcicki, R. (1988). *Theory of Logical Calculi*. Kluwer. ✓ (book); (u) for the specific terminology "almost inconsistent"
