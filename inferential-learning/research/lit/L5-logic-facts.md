# L5. Mathematical-logic facts the theory leans on

*Strand L5 of the inferential-learning project. Read `00-brief.md` first. This memo is the logic backbone for `theory/T2-coherence-as-negative-data.md`: T2 §§3 and 5 rely on the facts collected here. Where this memo corrects or sharpens T2, it says so (§13).*

**Verification status (read this first).**
* In this session the web-search budget was already exhausted. Egress to Wikipedia, SEP, arXiv, Crossref and Springer was also blocked.
* So **no citation in this memo was checked online**. Everything is from memory, and the mathematical claims are instead checked by proof where that is feasible.

Markers:
* **[proved here]**: a complete proof is given in this memo, possibly reducing to a named standard theorem. The mathematical claim is checked independently of the citation.
* **[std]**: textbook-standard result, stated as in standard texts. The bibliographic data are from memory and believed correct.
* **[mem]**: statement and bibliographic data are from memory. I believe them, but they should be checked before going into the paper.
* **[unverified]**: I am genuinely unsure of the statement, the attribution or the details.

---

## 0. Summary for the project

1. **Post-completeness, in its sharp consequence-level form [proved here, Thm 2.2].**
   * *What it says.* Take any set $L$ of Boolean connectives, and the structural closure operators that extend classical consequence $C_2^L$ (finitarity is not needed). If $L$ can express a tautology, they form the 2-element chain $C_2^L<C_{\rm Fm}$. Otherwise they form the 3-element chain $C_2^L<C_{\rm ai}<C_{\rm Fm}$, where $C_{\rm ai}$ is the *almost inconsistent* operator.
   * *Why it holds.* Substitute constants along a falsifying truth-table row. Any non-classical schematic rule then becomes "tautologies ⊢ contradiction".
   * *What it gives us.* Structural (schematic) generalization plus a single coherence datum *simulates the truth-table oracle*, with polynomial-size witnesses (Cor 2.3).
   * *A corollary.* Over a Post-complete base, Belnap's conservativeness criterion for new vocabulary collapses to mere coherence (Cor 2.4).
2. **The guarantee is fragile in exactly three ways.**
   * (i) It needs substitution of *arbitrary formulas*, or at least of constants. Renaming-only generalization breaks it (Prop 2.5).
   * (ii) In theorem-free fragments it needs a non-empty designated context.
   * (iii) It needs the target to be a *coatom* of the hypothesis lattice. For IPC, normal modal logic K, schematic first-order logic and ring identities, the target is not a coatom, and a bold coherence-maximizer overshoots:
     * to CPC (§3.1);
     * to Triv or Ver, which destroy modality (Makinson; §3.3);
     * to small-domain logics where ∃ collapses into ∀ (§3.4);
     * to characteristic-p arithmetic (§2.4).
3. **Equational analogue [proved here, Thm 2.6].**
   * The commutative-ring identities CR are *not* Post-complete. Their maximal coherent equational extensions are exactly the theories $\mathrm{Eq}(\mathbb F_p)$, so for instance the "freshman's dream" $(x+y)^2=x^2+y^2$ is coherent with CR.
   * CR *is* Post-complete relative to the designated context $\{n\cdot1\neq0\}$. Every non-identity $p=q$ yields $n\cdot 1=0$, with $n=\gcd$ of the values of $p-q$ at integer points.
   * So the orchestrator's "random numerical evaluation" is precisely coherence against the characteristic-0 diagram. Its witnesses are closed instances, mirroring the truth-table trick.
4. **Admissible versus derivable rules is a matter of context sensitivity [proved here, Prop 3.3].**
   * Two structural consequence relations with the same theorems agree on every context that consists of theorems.
   * IPC's admissible-but-underivable rules (Kreisel–Putnam/Harrop, Visser) show that the remaining gap is real.
   * So data from "eternal" (context-free) truths can never separate the two. Hypothetical contexts are not a nuisance for the user's program; they are *necessary data*.
5. **Arithmetic: the complexity ladder.**
   * The ladder runs:
     * schema matching and proof checking are in P;
     * theoremhood is Σ₁;
     * consistency is Π₁;
     * conservativity and Σ₁-soundness are Π₂-complete [proved here, Prop 7.3];
     * Σ₂-truth and beyond are not limit-learnable.
   * Rosser: no consistent r.e. hypothesis extending Q is coherence-maximal. For r.e. extensions of PA, completeness is *equivalent to inconsistency*.
   * A computable learner can converge in the limit to a complete consistent extension of PA. That limit is then necessarily false in ℕ (§7.4).
6. **Reflection as graded entitlement [proved here, Prop 8.2].**
   * Local Π₁-reflection (≡ Con(T)) is true iff T is consistent. Uniform Σ₁-reflection is true iff T is Σ₁-sound. Full reflection is true iff T is sound.
   * Evidence of coherence alone, which is what a coherence-trained learner has, licenses $\mathrm{Con}(T)$ and nothing stronger.
7. **Reflective coherence is a strictly stronger test, but never enough [proved here, Thm 8.3].** Iterated consistency extensions refute some Σ₁-unsound coherent hypotheses: $\mathrm{PA}+\neg\mathrm{Con}(\mathrm{PA})$ dies after one round, and $\mathrm{PA}+\Box^k\bot$ survives exactly $k-1$ rounds. But no Π₁ (indeed no Δ₂) test separates Σ₁-sound from Σ₁-unsound theories.
8. **Progressions and implicit commitment.**
   * Turing–Feferman progressions are complete only through a non-effective choice of ordinal notations. Membership in Kleene's O is Π¹₁-complete.
   * Autonomous progressions give principled stopping points (Γ₀ for predicativity).
   * Feferman's (1991) *reflective closure* of schematic theories is the best existing formalization of "what a learner who accepts a system is committed to". It is the principled source of new inferences beyond imitation.
9. **Conservativity: definitional versus theoretical terms.**
   * Definitional extensions are conservative and eliminable. Independently learned conservative libraries combine conservatively [proved here via Craig, Prop 6.1].
   * For theoretical terms in empirical theories, the Ramsey sentence carries all observational content. The Carnap sentence is observationally conservative, so it is *invisible to coherence plus observational feedback* [proved here, Prop 6.2].
10. **Kreisel's squeezing argument is the right template for "it would have worked before formalization".**
    * The template has three parts: a sound learned lower bound, a coherence or countermodel upper bound, and a completeness theorem that closes the gap. T2 Thm 3.3 *is* a squeeze.
    * The learner can never check that the squeeze has closed. By Linial–Post, completeness of a finite propositional calculus is undecidable even though its soundness is decidable.

---

## 1. Definitions and notation

* **Language.** $\mathrm{Fm}=\mathrm{Fm}_L$ is the absolutely free algebra of formulas over a countable set of atoms, for a set $L$ of connectives.
* **Closure operators.** A *closure operator* (Tarski consequence operation) is a map $C:\mathcal P(\mathrm{Fm})\to\mathcal P(\mathrm{Fm})$ that is:
  * extensive: $X\subseteq C(X)$;
  * monotone;
  * idempotent.
  * $C$ is *finitary* if $C(X)=\bigcup\{C(Y):Y\subseteq_{\rm fin}X\}$.
  * $C$ is *structural* if $\sigma C(X)\subseteq C(\sigma X)$ for every substitution (endomorphism) σ.
  * The notion of structurality is due to Łoś & Suszko (1958) [mem].
* **Order and theories.** $C\le C'$ means $C(X)\subseteq C'(X)$ for all $X$. A *theory* is a set $T$ with $C(T)=T$.
* **Theorems.** The *theorems* of $C$ are $C(\emptyset)$. A *logic*, in the older Polish sense, is a set of formulas closed under substitution and under given rules; its theorem set is $C(\emptyset)$.
* **Special operators.**
  * The *inconsistent* operator is $C_{\rm Fm}(X)=\mathrm{Fm}$.
  * The *almost inconsistent* operator is $C_{\rm ai}(\emptyset)=\emptyset$ and $C_{\rm ai}(X)=\mathrm{Fm}$ for $X\neq\emptyset$. Its only theories are ∅ and Fm.
  * Terminology: I recall "almost inconsistent" from Font 2016 and the Wójcicki school [mem].
* **Classical consequence.** For a set $L$ of Boolean connectives (finitary operations on $\{0,1\}$, constants allowed), $C_2^L$ is the consequence of the matrix $\langle\mathbf 2_L,\{1\}\rangle$: $\varphi\in C_2^L(X)$ iff every valuation satisfying $X$ satisfies φ. Write $K_L$ for the *clone* generated by $L$ (all Boolean functions expressible by $L$-formulas).
* **Rules.** A *rule* is a pair $X/\varphi$ with $X$ finite.
  * It is *derivable* in $C$ if $\varphi\in C(X)$.
  * It is *admissible* in $C$ if for every σ, $\sigma X\subseteq C(\emptyset)$ implies $\sigma\varphi\in C(\emptyset)$.
  * $C$ is *structurally complete* if every admissible rule is derivable (Pogorzelski 1971 [mem]).
* **Post-completeness.** A logic is *Post-complete* (maximal) if it is consistent and every proper extension closed under substitution and its rules is inconsistent. At the consequence level the analogue is: the only structural $C'>C$ is $C_{\rm Fm}$, or, in theorem-free fragments, $C_{\rm ai}$ and $C_{\rm Fm}$.
  * *Do not confuse this with Post's functional completeness theorem* (the characterization of complete sets of connectives by the five maximal clones). That is also Post's, but it is a different result.
* **Learning vocabulary (as in T2).**
  * *Bold learner*: outputs a maximal hypothesis consistent with the data and coherence.
  * *Conservative (minimal) learner*: outputs the closure of the data.
  * *Designated context*: a premise set certified coherent by the environment.

---

## 2. Post-completeness of classical logic

### 2.1 The theorem-level version

**Theorem 2.1 (Post 1921) [std; proved here].** Let Fm be the $\{\neg,\to\}$-formulas and Taut the tautologies. Let $S\supseteq\mathrm{Taut}$ be closed under uniform substitution and modus ponens. Then $S=\mathrm{Taut}$ or $S=\mathrm{Fm}$.

*Proof.*
1. Let $\varphi\in S\setminus\mathrm{Taut}$. Choose $v$ with $v(\varphi)=0$.
2. Put $\top:=p_0\to p_0$ and $\bot:=\neg\top$. Let $\sigma_v(p)=\top$ if $v(p)=1$, and $\bot$ otherwise.
3. Then $\sigma_v\varphi\in S$, and every valuation gives $\sigma_v\varphi$ the value $v(\varphi)=0$. So $\neg\sigma_v\varphi\in\mathrm{Taut}\subseteq S$.
4. For any ψ, $\neg\sigma_v\varphi\to(\sigma_v\varphi\to\psi)\in\mathrm{Taut}$. Two applications of MP give $\psi\in S$. ∎

**Remarks.**
* (i) MP matters. A set closed only under substitution can contain non-tautologies without being trivial.
* (ii) Post's original 1921 argument went through normal forms and truth tables. The substitution trick above is the modern folklore proof.
* (iii) The proof is constructive and *local*. From one bad formula and one falsifying row it builds an explicit derivation of everything.

### 2.2 The consequence-level version, for every Boolean fragment

The brief asks for "the precise correct version for consequence relations". Here it is, in full generality.

**Theorem 2.2 [proved here].** Let $L$ be any set of Boolean connectives. Let $C$ be any structural closure operator on $\mathrm{Fm}_L$ with $C\ge C_2^L$. Finitarity is not assumed.
* **(a)** If $C_2^L(\emptyset)\neq\emptyset$, then $C\in\{C_2^L,C_{\rm Fm}\}$. Equivalently, the clone $K_L$ contains the constant 1.
* **(b)** If $C_2^L(\emptyset)=\emptyset$, then $C\in\{C_2^L,C_{\rm ai},C_{\rm Fm}\}$, and all three are structural extensions.

Two standard instances:
* For $L=\{\neg,\wedge,\vee,\to\}$, or any $L$ with ¬ and a binary connective, or with →, case (a) applies.
* For $\{\wedge,\vee\}$, $\{\wedge\}$, $\{\vee\}$, $\{\neg\}$, majority or $x\oplus y\oplus z$, case (b) applies.

*Proof.* Throughout: if $\varphi\in C(X)\setminus C_2^L(X)$, fix a valuation $v$ with $v[X]=1$ and $v(\varphi)=0$. The basic move is: for any σ, structurality gives
$$\sigma\varphi\in C(\sigma X),$$
and if moreover $\sigma X\subseteq C(\emptyset)$, then $C(\sigma X)\subseteq C(C(\emptyset))=C(\emptyset)$.

**(a)** Let $t(p_0)$ be a one-variable tautology. One exists: identify all atoms of any tautology.
* *(a1) Some $f\in K_L$ does not preserve 1.* Then $f(t,\dots,t)$ is a one-variable formula $\equiv 0$; call it $u(p_0)$.
  * Let $\sigma_v(p)=t$ or $u$ according to $v(p)$. Each $\sigma_v\psi$ then has the constant value $v(\psi)$.
  * So $\sigma_vX\subseteq C_2^L(\emptyset)\subseteq C(\emptyset)$, hence $\sigma_v\varphi\in C(\emptyset)$.
  * $\sigma_v\varphi$ is unsatisfiable, so $\mathrm{Fm}=C_2^L(\{\sigma_v\varphi\})\subseteq C(C(\emptyset))=C(\emptyset)$.
* *(a2) Every $f\in K_L$ preserves 1.* Let $\sigma_v(p)=t(p_0)$ if $v(p)=1$, and $p_0$ otherwise.
  * Each $\sigma_v\psi$ is a one-variable formula. Its value at $p_0=1$ is 1, by 1-preservation; its value at $p_0=0$ is $v(\psi)$.
  * Hence $\sigma_v\psi$ is a tautology for $\psi\in X$, and $\sigma_v\varphi\equiv p_0$.
  * As before, $\sigma_v\varphi\in C(\emptyset)$, so $p_0\in C_2^L(\sigma_v\varphi)\subseteq C(\emptyset)$. By structurality, $C(\emptyset)=\mathrm{Fm}$.

**(b)** Now $K_L$ lacks the constant 1. $C_{\rm ai}$ is structural, since σX is non-empty iff X is, and $C_{\rm ai}\ge C_2^L$ because $C_2^L(\emptyset)=\emptyset$.
* *Case $C(\emptyset)\neq\emptyset$.*
  * Take $\chi\in C(\emptyset)$ and identify all its atoms with $p_0$, giving $\chi'\in C(\emptyset)$. Then $\chi'$ is a unary member of $K_L$ other than the constant 1, so $\chi'\equiv p_0$, $\neg p_0$ or $0$.
  * In the first and third cases $p_0\in C(\emptyset)$ directly.
  * In the second, substituting $\neg p_0$ for $p_0$ gives $\neg\neg p_0\in C(\emptyset)$, and hence $p_0\in C(\emptyset)$.
  * So $C=C_{\rm Fm}$.
* *Case $C(\emptyset)=\emptyset$ and $C\neq C_2^L$.* It suffices to show $r\in C(\{q\})$ for distinct atoms $q,r$. Structurality then gives $\chi\in C(\{\psi\})$ for all ψ, χ, so $C=C_{\rm ai}$. Note:
  * If some $f\in K_L$ fails to preserve 0, then $f(p,\dots,p)\equiv\neg p$, since constant 1 is absent. So $\neg\in K_L$.
  * Otherwise $K_L$ preserves 0. If it then failed to preserve 1, it would contain the constant 0.

  Three exhaustive sub-cases:
  * *(b1) $\neg\in K_L$.* Then $K_L$ has no constants, since $\neg0=1$.
    * Every member of $K_L$ is self-dual. If $f(\neg\bar a)=f(\bar a)$ for some $\bar a$, then plugging $p$ or $\neg p$ into the coordinates according to $\bar a$ yields a constant.
    * Let σ send the atoms true under $v$ to $q$ and the false ones to $\neg q$. Each $\sigma\psi$ is a unary self-dual function, i.e. $\equiv q$ or $\equiv\neg q$, taking the value $v(\psi)$ at $q=1$.
    * So $\sigma X\subseteq C_2^L(\{q\})$ and $\sigma\varphi\equiv\neg q$. Hence $\neg q\in C(\{q\})$, and $r\in C_2^L(\{q,\neg q\})\subseteq C(\{q\})$.
  * *(b2) $K_L$ preserves 0 and contains the constant 0, say $u(q)$.*
    * Let σ send the true atoms to $q$ and the false ones to $u(q)$. Each $\sigma\psi$ is unary and 0-preserving, so it is $\equiv q$ or $\equiv0$ according to $v(\psi)$.
    * So $\sigma\varphi\equiv 0\in C(\{q\})$, which gives $r\in C(\{q\})$.
  * *(b3) $K_L$ preserves both 0 and 1.*
    * Let σ send the true atoms to $q$ and the false ones to $r$. Each $\sigma\psi$ is a binary idempotent function with value $v(\psi)$ at $(q,r)=(1,0)$.
    * For $\psi\in X$, $\sigma\psi$ has value 1 at $(1,0)$, so its table is that of $q$ or of $q\vee r$. Either way it lies in $C_2^L(\{q\})$.
    * $\sigma\varphi$ has value 0 at $(1,0)$, so its table is that of $r$ or of $q\wedge r$. Either way $r\in C_2^L(\{\sigma\varphi\})$.
    * Hence $r\in C(\{q\})$. ∎

**Attribution.**
* The $\{\neg,\to\}$ and full-language cases are folklore in the Polish school; Wójcicki (1988) is the standard reference [mem].
* The $\{\wedge,\vee\}$ case, with its almost inconsistent extension, is T2 Prop 3.2.
* I believe the general classification of the extensions of all two-element matrix logics is in Rautenberg (1981, "2-element matrices", *Studia Logica* 40) [unverified]. The proof above is self-contained.
* The brief asked about Tokarz. I believe Tokarz (1973, *Studia Logica* 32) relates Post-completeness, structural completeness and allied notions for structural calculi, and that the Wójcicki–Tokarz school studies a "degree of maximality", roughly the number of structural extensions with the same theorems. I could not check either definition [unverified]. The learning-relevant quantity is the set of structural hypotheses above the target that agree with all theorem data. That is exactly the residual ambiguity of a bold learner fed only theorems (§3.2).

### 2.3 Corollaries for the learner

**Corollary 2.3 (one-shot detection of bad schemata; witness size) [proved here].** Let $C\ge C_2^L$ be structural and contain a rule $X/\varphi$ that is not classically valid. Assume case (a1), e.g. the full language.
* Then ⊥ is derivable from ∅ using **one** instance $\sigma_v(X/\varphi)$ of the rule plus classical steps.
* The classical steps prove formulas whose atoms are replaced by constant-valued subformulas. Frege-style "evaluation proofs" of such formulas have size polynomial in $|X|+|\varphi|$ [std].
* Finding $v$ is a SAT search, and deciding whether a rule is classically valid is coNP-complete (Cook 1971) [std].
* So, for schematic propositional rules, *coherence-based detection is exactly as hard as SAT and never harder*. Coherence plus structurality is a complete, polynomially-witnessed soundness test.

**Corollary 2.4 (coherence equals conservativity over a Post-complete base) [proved here].** Let $L\subseteq L'$, and let $C'$ be a structural closure operator on $\mathrm{Fm}_{L'}$ whose restriction to $L$-formulas extends $C_2^L$. (For instance, $C'$ is CPC plus learned rules for a new connective ★.) Let $A$ be a designated context: classically consistent $L$-formulas, non-empty in case (b). Then
$$C'\ \text{is conservative over } C_2^L\iff A\nvdash_{C'}\text{everything}.$$

*Proof.*
* The restriction $C'|_L$ is a structural closure operator above $C_2^L$, so Thm 2.2 applies to it.
* If it is not $C_2^L$, it is $C_{\rm ai}$ or $C_{\rm Fm}$, so $A$ explodes in $C'$.
* Conversely, conservativity gives $C'(A)\cap\mathrm{Fm}_L=C_2^L(A)\neq\mathrm{Fm}_L$. ∎

The same holds over any **complete** first-order theory $T$. If $T'\supseteq T$ is consistent and $T'\vdash\varphi$ for an $L$-sentence φ, then $T\vdash\varphi$: otherwise $T\vdash\neg\varphi$ by completeness, and $T'$ would be inconsistent. [std]

*Reading.*
* Belnap's (1962) existence (conservativeness) requirement for introducing a connective is, over CPC, *the same as* non-triviality. So tonk-style failures over a classical base are always caught by coherence, on a non-empty context in case (b).
* Harmony and conservativeness become a substantive filter only over sub-classical bases. This is why the Dummett–Prawitz debate is about intuitionistic logic.
* This does not contradict T2 Prop 5.2. There the base is intuitionistic → (positive implicational IPC), which is not Post-complete.

**Proposition 2.5 (structurality must include substitution of non-atoms) [proved here].**
* *The construction.* Let $C$ be the least closure operator above $C_2$ (full language) that contains the rule $p/q$ for distinct atoms and is closed under *renamings* (atom-to-atom substitutions). Then $C(X)=C_2(X)$ if $C_2(X)$ contains no atom, and $C(X)=C_2(X\cup\mathrm{Atoms})$ otherwise.
* *Its properties.* $C$ is consistent and renaming-invariant, and $C(\emptyset)=\mathrm{Taut}$. Yet $C\neq C_2$.
* *The positive side.* Thm 2.2's proof uses only the substitutions $\sigma_v$. So closure under *instantiation of atoms by (constant-valued) formulas* suffices.

*Reading.*
* A learner whose generalization is only α-renaming of variables (a common shortcut in ML pattern-mining) gets **no** Post-completeness guarantee.
* It must generalize schematically over arbitrary subformulas, or at least must be willing to instantiate metavariables with ⊤/⊥.
* Guards and typed metavariables are fine *provided the constants are admissible instances*.

### 2.4 Equational analogues: Boolean algebras and commutative rings

This matters for the orchestrator's "algebra as experimental workhorse" (`01-orchestrator-ideas.md` §3). There, *hypotheses are equational theories*, and the only equationally inconsistent theory is $\{x=y\}$.

**Theorem 2.6 [(i) std; (ii)–(iv) proved here].**
* **(i)** The equational theory of Boolean algebras is *equationally complete*. Every equation not valid in $\mathbf 2$, when added, yields $x=y$. The reason: every nontrivial Boolean algebra contains $\mathbf 2$ as a subalgebra, so the variety is minimal.
* **(ii)** Let CR be the equational theory of commutative rings with 1. Its maximal consistent equational extensions are exactly $\mathrm{Eq}(\mathbb F_p)$ for primes $p$. So CR is **not** Post-complete. Coherent "fallacies" include:
  * $(x+y)^2=x^2+y^2$, valid in characteristic 2;
  * $x^2=x$ (Boolean rings);
  * $x^p=x$.
* **(iii)** $\mathrm{CR}=\bigcap_p\mathrm{Eq}(\mathbb F_p)$. The target is the *meet* of the coatoms above it.
* **(iv) Post-completeness relative to the characteristic.** Suppose $p(\bar x)=q(\bar x)$ is not a CR-identity. Let $J\subseteq\mathbb Z$ be the ideal generated by $\{p(\bar m)-q(\bar m):\bar m\in\mathbb Z^k\}$, and $n\ge1$ its generator (the gcd of the values). Then $\mathrm{CR}+(p=q)\vdash n\cdot1=0$. The derivation uses finitely many *closed instances* $p(\bar m_i)=q(\bar m_i)$, combined by Bézout. Hence $\mathrm{CR}+(p=q)$ is incoherent with the designated context $\{n\cdot1\neq0\}$.

*Proof.*
* *(iv).* Let $V$ be the variety of $\mathrm{CR}+(p=q)$.
  * $\mathbb Z/J\models p=q$, because every tuple lifts to $\mathbb Z^k$. So $\mathbb Z/J\in V$.
  * Conversely, every closed instance holds in $V$, so $J\subseteq\{n:V\models n=0\}$. Hence the initial algebra of $V$ is $\mathbb Z/J$.
  * $J\neq0$, because $p-q$ is a nonzero polynomial over $\mathbb Z$ and so is nonzero at some integer point.
* *(ii).*
  * Each $\mathrm{Var}(\mathbb F_p)$ is minimal: a nontrivial member has characteristic $p$, since $V\models p=0$, so its prime subring is $\mathbb F_p$.
  * Let $V$ be any nontrivial variety of commutative rings. A nontrivial $R\in V$ has a field quotient $F\in V$. If $\mathrm{char}F=0$, then $\mathbb Z\subseteq F$, so $\mathbb Z\in V$, and $\mathrm{Var}(\mathbb Z)$ is all of CR's models (identities of $\mathbb Z$ are the polynomial identities). Otherwise $\mathbb F_p\in V$.
  * So the minimal varieties are exactly $\mathrm{Var}(\mathbb F_p)$.
* *(iii).* A non-principal ultraproduct of the $\mathbb F_p$ is a characteristic-0 field in $\mathrm{Var}\{\mathbb F_p\}$, so that variety contains $\mathbb Z$. ∎
* *Attribution.* (ii) is presumably in Kalicki & Scott (1955, "Equational completeness of abstract algebras", *Indag. Math.* 17) [mem; unverified exact content].

*Reading for experiments.*
* Coherence alone does **not** refute the freshman's dream. It refutes it only against the designated disequation $2\neq0$, and in general against "$n\cdot1\neq0$" for the $n$ of (iv).
* Evaluation at integer points *is* this coherence check. The witness is a closed instance, which is exactly the role $\sigma_v$ plays in Thm 2.2.
* So the experimental workhorse should model numerical evaluation as *coherence with the diagram of $\mathbb Z$*. That unifies "world feedback" and "coherence" in the equational setting.
* For identities involving division (with guards $x\neq0$), or elementary functions, we leave equational logic.
  * Identity-testing of expressions with exp, sin, |·| and π is undecidable (Richardson 1968, *JSL* 33) [mem].
  * Polynomial identity testing is in coRP (Schwartz 1980; Zippel 1979; DeMillo–Lipton 1978) [std].

### 2.5 The general lesson: bold versus skeptical coherence

**Proposition 2.7 (coatom lemma) [proved here; trivial once set up].**
* *Setting.* Let $\mathcal H$ be a set of hypotheses ordered by inclusion and closed under the learner's generalization operator. Let "coherent" be a property that is closed downward.
* *Assumption.* Every coherent hypothesis lies below a maximal coherent one, as Zorn's lemma gives for finitary hypotheses with compact incoherence. Suppose also that the data closure $\langle D\rangle$ reaches the target $h^\*$.
* *Bold learner.* The bold learner (output *some* maximal coherent $h\ge\langle D\rangle$) is correct on every text iff $h^\*$ is the *unique* maximal coherent element above itself.
* *Skeptical learner.* The skeptical learner (output the meet of all maximal coherent $h\ge\langle D\rangle$) is correct iff $h^\*$ is the meet of the maximal coherent elements above it.

| target | maximal coherent extensions | bold | skeptical |
|---|---|---|---|
| CPC consequence (any fragment) | itself | ✓ | ✓ |
| Eq(Boolean algebras) | itself | ✓ | ✓ |
| complete theories (RCF, ACF_p, Presburger, DLO, Tarski geometry) | itself | ✓ | ✓ |
| CR (ring identities) | Eq(𝔽_p), all p | ✗ | ✓ (Thm 2.6(iii)) |
| IPC, any intermediate logic | CPC only (Thm 3.1) | ✗ | ✗ |
| normal modal K | Triv, Ver (Thm 3.4) | ✗ | ✗ (K ⊊ Triv ∩ Ver) |
| PA | 2^ℵ₀ completions, none r.e. | ✗ | gives PA itself (no extrapolation) |

*Reading.* Coherence works "from above". It succeeds exactly when the target sits at the top of its coherent version space, or at the meet of the tops. Minimality works "from below". CPC is at both ends, which is why everything works there (T2 §3.4 already noted this). H4's slogan "the maximal coherent structural extension is the truth" is a *property of the target*, true for coatoms only.

*Check of the K entry.* $\Diamond\top\to(\Box p\to p)$ is valid in both one-point frames but not in K.

---

## 3. Where Post-completeness fails

### 3.1 Intuitionistic and intermediate logics

**Theorem 3.1 [std; proved here].** Work in the IPC language $\{\wedge,\vee,\to,\bot\}$.
* (a) Every consistent superintuitionistic logic (a substitution- and MP-closed set containing IPC) is contained in CPC. So CPC is the unique Post-complete si-logic.
* (b) Every consistent structural consequence relation extending $\vdash_{\rm IPC}$ is contained in $\vdash_{\rm CPC}$.

*Proof.*
* Every variable-free formula is IPC-equivalent to ⊤ or ⊥. This is an easy induction: $\top\vee\bot\equiv\top$, $\top\to\bot\equiv\bot$, $\bot\to\chi\equiv\top$, and so on.
* Now run the case-(a1) argument of Thm 2.2 with ⊤ and ⊥. ∎

**Facts [std/mem].**
* **Glivenko (1929)** [std]: $\vdash_{\rm CPC}\neg\varphi$ iff $\vdash_{\rm IPC}\neg\varphi$. Equivalently, $\vdash_{\rm CPC}\varphi$ iff $\vdash_{\rm IPC}\neg\neg\varphi$ (propositional case).
  * Consequence: for every intermediate $L$ and finite $A$, $A\vdash_L\bot\iff A\vdash_{\rm CPC}\bot$. Coherence data are *identical* across the whole interval (T2 Thm 3.6(a)).
* **Jankov (1968)** [mem]: there are continuum many intermediate logics. This is proved with Jankov (characteristic) formulas of an infinite antichain of finite subdirectly irreducible Heyting algebras. Standard exposition: Chagrov & Zakharyaschev 1997, ch. 9 [std].
* **Complexity** [std]:
  * IPC derivability is PSPACE-complete (Statman 1979).
  * CPC validity is coNP-complete (Cook 1971).

*Learning consequence.* A bold coherence learner trained on intuitionistic mathematicians' proofs becomes **classical**, provably and on every text. Coherence cannot learn a constructivist's meanings; only minimality can.

### 3.2 Structural completeness: admissible versus derivable

**Proposition 3.2 (largest structural relation with given theorems) [std; proof in T2 Prop 3.4].**
* Fix a substitution-closed theorem set Th.
* The structural consequence relations with theorem set Th form an interval. Its bottom is $X\mapsto X\cup\mathrm{Th}$. Its top is the admissibility relation $C_{\rm adm}(X)=\{\varphi:\forall\sigma(\sigma X\subseteq\mathrm{Th}\Rightarrow\sigma\varphi\in\mathrm{Th})\}$, the *structural completion*.
* If hypotheses are required to satisfy a deduction theorem for a fixed →, theorems determine the relation (L1 §3).

**Facts [std/mem].**
* **CPC is structurally complete** (Pogorzelski 1971 [mem]). Proof: Thm 2.2's $\sigma_v$ shows that every non-derivable rule fails admissibility.
* **IPC is not structurally complete.**
  * The Kreisel–Putnam/Harrop rule $\neg p\to q\vee r\ /\ (\neg p\to q)\vee(\neg p\to r)$ is admissible but not derivable.
  * References: Kreisel & Putnam 1957 for the logic KP; Harrop 1960 for admissibility [mem].
* **The admissible rules of IPC.**
  * The Visser rules form a basis (Iemhoff 2001, *JSL* 66; independently Rozière 1992, thesis, Paris VII) [mem].
  * Admissibility is decidable (Rybakov 1984; monograph Rybakov 1997) [mem]. Ghilardi's (1999) unification approach is another route [mem].
  * Admissibility is coNEXP-complete (Jeřábek 2007, *Arch. Math. Logic* 46) [mem].
* **Structurally complete intermediate logics.**
  * Gödel–Dummett LC is structurally complete, indeed hereditarily so (Dzik & Wroński 1973) [mem].
  * So is Medvedev's logic (Prucnal 1976) [mem].
  * Citkin (1978) characterizes the hereditarily structurally complete intermediate logics [mem; details unverified].

**Proposition 3.3 (the admissible/derivable gap is a context gap) [proved here].** Let $C,C'$ be structural with $C(\emptyset)=C'(\emptyset)=\mathrm{Th}$. Then $C(A)=C'(A)=\mathrm{Th}$ for every context $A\subseteq\mathrm{Th}$.

*Proof.*
* $C(A)\subseteq C(C(\emptyset))=\mathrm{Th}$, and similarly for $C'$.
* In particular, for $C_{\rm adm}$: σA ⊆ Th for all σ, so $\varphi\in C_{\rm adm}(A)$ iff all $\sigma\varphi\in\mathrm{Th}$ iff $\varphi\in\mathrm{Th}$. ∎

*Reading for the user's context question.*
* Admissible rules *preserve theoremhood*. A bold IPC learner fed theorem-only data (it converges to $C_{\rm adm}$) never derives a non-theorem from theorems. It is wrong only when reasoning **under hypotheses**. Example: in a context assuming $\neg p\to q\vee r$, it concludes $(\neg p\to q)\vee(\neg p\to r)$, which does not follow.
* So "eternalist" data cannot even *in principle* separate derivability from admissibility. Contexts are exactly what is needed.
* This is a structural argument *for* the user's insistence on contexts, independent of physics.

### 3.3 Modal logic: boldness destroys modality

**Theorem 3.4 (Makinson 1971, *NDJFL* 12 [mem]; proof checked here).** Every consistent normal modal logic is contained in $\mathrm{Triv}=\mathbf K\oplus(\Box p\leftrightarrow p)$ or in $\mathrm{Ver}=\mathbf K\oplus\Box\bot$. These two are the only Post-complete normal modal logics.

*Proof sketch.* Let $L$ be consistent and normal, with canonical model $M_L$ (non-empty, and every member of $L$ is true at every world).
* If $M_L$ has a dead end $w$, every variable-free formula takes the same value at $w$ as at the irreflexive one-point frame.
* If $M_L$ has no dead end, it is serial. Then, by induction, every variable-free formula takes the same value at every world as at the reflexive one-point frame.
* Suppose $L\not\subseteq\mathrm{Ver}$. Ver is the logic of the irreflexive point. Take $\varphi\in L$ falsified there under some valuation $v$, and apply the constant substitution $\sigma_v$ (⊤/⊥ according to $v$). This gives a variable-free $\varphi'\in L$ that is false at the irreflexive point. Hence $M_L$ has no dead end.
* Likewise, $L\not\subseteq\mathrm{Triv}$ yields a variable-free member of $L$ that is false at the reflexive point. Hence $M_L$ is not serial.
* A consistent $L$ contained in neither would need $M_L$ to be both dead-end-free and non-serial, which is absurd. ∎

*Reading.* A coherence-maximizing learner of a modal vocabulary (necessity, knowledge, provability, obligation) converges to □p ↔ p ("modality is idle") or to □⊥ ("everything is necessary"). Coherence alone *cannot* learn a modal meaning. Minimality or world feedback is required.

### 3.4 First-order logic as a schematic logic

The valid first-order schemata (closed under substitution of formulas for predicate letters) are **not** Post-complete [std].
* Adding $\exists xP(x)\to\forall xP(x)$ is consistent: it is valid exactly in one-element domains. With equality, $\forall x\forall y\,x=y$ does the same.
* So a bold learner may adopt "hasty generalization" (∃ ⟹ ∀) and is never refuted unless some designated context forces two distinguishable objects, e.g. $\{P(a),\neg P(b)\}$. Compare T2's surviving quantifier-swap fallacy.
* Contrast: *complete* first-order theories (RCF, ACF_p, Presburger, DLO, Tarski's elementary geometry) are trivially coherence-pinned (Cor 2.4; T2 Prop 3.11).
* For physics, note:
  * $(\mathbb R,+,\cdot,\exp)$ is model complete (Wilkie 1996, *JAMS* 9). It is decidable if Schanuel's conjecture holds (Macintyre & Wilkie 1996) [mem].
  * $(\mathbb R,+,\cdot,\sin)$ defines ℤ (via sin(πx) = 0), so it is undecidable and incomplete [std].
  * So the "RCF core" of olympiad physics is coherence-pinned, but trigonometric and analytic reasoning is not.

---

## 4. Lindenbaum, Łoś–Suszko, Suszko, Scott: the valuation side

These are brief, because T2 §4 builds on them.

* **Lindenbaum's lemma** [std].
  * Statement: let $C$ be finitary. If $\varphi\notin C(X)$, there is a theory $T\supseteq X$ that is *maximal among theories omitting φ*.
  * Consequence: if some finite set is explosive, every consistent set extends to a maximal consistent theory.
  * For CPC, the maximal consistent theories are exactly $\{\psi:v(\psi)=1\}$ for Boolean $v$. Lindenbaum (reported in Tarski 1930) [std].
  * *Learning reading*: the bold learner of **facts**, as opposed to rules, *is* a Lindenbaum construction. Its output depends on the enumeration order (T2 Thm 3.10(d)).
* **Closure systems** [std]. $C$ is determined by $\mathrm{Th}(C)$, which is closed under arbitrary intersections, via $C(X)=\bigcap\{T\in\mathrm{Th}(C):X\subseteq T\}$. $C$ is finitary iff $\mathrm{Th}(C)$ is also closed under directed unions.
* **Łoś–Suszko (1958); Wójcicki (1970)** [mem].
  * Every structural $C$ is complete for its *Lindenbaum bundle* $\{\langle\mathrm{Fm},T\rangle: T\in\mathrm{Th}(C)\}$. So the structural consequence operations are exactly those determined by classes of logical matrices.
  * The single-matrix characterization (Łoś–Suszko's "uniformity" condition) had a gap, repaired by Wójcicki [mem; details unverified].
* **Suszko's thesis (1977)** [mem].
  * Every structural Tarskian consequence is "logically two-valued": it is determined by a set of (non-truth-functional) bivaluations, namely the characteristic functions of its theories.
  * This is the formal background of Carnap's categoricity problem (Carnap 1943) [std]. Single-conclusion consequence fixes the admissible valuations only up to intersection-closure.
* **Scott (1974)** [mem] and **Shoesmith & Smiley (1978)** [std].
  * Multiple-conclusion consequence relations on finite sequents (overlap, dilution, cut) correspond to sets of bivaluations, up to topological closure in $2^{\mathrm{Fm}}$.
  * So bilateral (multiple-conclusion) data can pin an arbitrary closed set of valuations, which single-conclusion data cannot. This is the mathematical core of T2 Thm 4.2–4.4 and of H3. T2 cites Restall (2005) for the reading; Scott and Shoesmith–Smiley are the theorems behind it.
* **Chang–Łoś–Suszko preservation theorem** [std]. A first-order theory's model class is closed under unions of chains iff the theory is ∀∃-axiomatizable (Chang 1959; Łoś & Suszko 1957).
  * Relevance: a world revealed as an increasing chain of finite substructures preserves exactly the Π₂-axiomatizable hypotheses in the limit. This matches the Σ₂/Π₂ boundary of limit learning in §7.4.

---

## 5. Interpolation, definability, joint consistency

* **Craig interpolation** (Craig 1957, *JSL* 22) [std]. In first-order logic with equality: if $\models\varphi\to\psi$, there is θ whose non-logical symbols occur in both φ and ψ, with $\models\varphi\to\theta$ and $\models\theta\to\psi$. If the formulas share no relation symbols, θ may be built from = or be ⊤/⊥. Propositional: θ uses only shared atoms.
* **Robinson joint consistency** (A. Robinson 1956) [std].
  * Statement: let $T_i$ be consistent $L_i$-theories ($i=1,2$) and $L_0=L_1\cap L_2$. Then $T_1\cup T_2$ is inconsistent iff some $L_0$-sentence θ has $T_1\vdash\theta$ and $T_2\vdash\neg\theta$.
  * Equivalent formulation: if $T_1\cap\mathrm{Sent}(L_0)$ is a complete $L_0$-theory contained in $T_2$, the union is consistent.
* **Beth definability** (Beth 1953) [std]. If $T(P)\cup T(P')\models\forall\bar x(P\bar x\leftrightarrow P'\bar x)$ (implicit definability), then there is an explicit definition $\theta(\bar x)$ in $L\setminus\{P\}$ with $T\models\forall\bar x(P\bar x\leftrightarrow\theta)$. Beth follows from Craig.
* **Feasible interpolation** [mem].
  * From a resolution refutation of $A(\bar p,\bar q)\wedge B(\bar p,\bar r)$, an interpolant circuit in $\bar p$ can be computed in time linear in the refutation (Krajíček 1997, *JSL* 62; Pudlák 1997, *JSL* 62).
  * Used in model checking by McMillan (2003, CAV).
* **Intermediate logics** [mem]. Exactly seven consistent intermediate logics have Craig interpolation (Maksimova 1977).

**Uses for the project.**
* **(a) A merge criterion for contexts (chunks).**
  * Two internally consistent chunks can be merged iff they disagree on no sentence of their *shared* vocabulary (Robinson). The disagreement, if any, is witnessed by an interpolant.
  * In the air-pressure example, the interpolant is the shared-vocabulary sentence on which the idealization and the background clash (e.g. "$P=0$" versus "$P>0$"). It is the formal "footprint" of the idealization.
  * The permeability filter of chunk-and-permeate (L7) can be specified as: *permit into chunk Γ exactly those background sentences in Γ's vocabulary that do not entail the negation of an interpolant of the clash*. This is a proposal to formalize, not a known result.
* **(b) Blame localization in negative bags.** Suppose a refutation uses steps from two chunks. Interpolation splits it into "$\Gamma_1\vdash\theta$" and "$\Gamma_2\vdash\neg\theta$". Either one of the two sub-derivations contains an invalid step, or the chunks are genuinely incompatible on θ. For resolution, the split is computable in linear time.
* **(c) Inferentialism and new vocabulary.**
  * Belnap's (1962) *uniqueness* condition for a connective is the propositional analogue of implicit definability.
  * In first-order logic, Beth says: rules that uniquely determine a new predicate *and* are conservative make it explicitly definable, hence eliminable.
  * So "meaning fully determined by inferential role, and conservative" ⟹ "adds no content". That is good for learned definitions and abbreviations (library learning), and the wrong criterion for theoretical terms (§6.3). Došen & Schroeder-Heister (1985, *Theoria* 51) treat conservativeness and uniqueness together [mem].

---

## 6. Conservative extensions: definitional versus theoretical vocabulary

### 6.1 Definitional extensions, and combining them

* **Definitional extensions** [std; Shoenfield 1967, §§4.5–4.7]. Adding $\forall\bar x(P\bar x\leftrightarrow\theta)$, or a function symbol $f$ with $\forall\bar x\,\theta(\bar x,f\bar x)$ when $T\vdash\forall\bar x\exists!y\,\theta$, gives a conservative extension. Every new formula is $T$-provably equivalent to an old one, so the extension is eliminable.
* **Skolem and Henkin extensions** are conservative but not eliminable [std].
* **Hilbertian "ideal" extensions** [mem].
  * ACA₀ is conservative over PA for arithmetic sentences (Simpson 2009, *SOSOA*).
  * WKL₀ is Π¹₁-conservative over RCA₀ and Π⁰₂-conservative over PRA (Friedman 1976, abstract; Sieg 1985; Harrington, unpublished).
  * NBG is conservative over ZF (Novak 1950; Shoenfield 1954).

**Proposition 6.1 (independently learned conservative libraries combine conservatively) [proved here via Craig].** Let $T_1\supseteq T$ and $T_2\supseteq T$ be conservative over $T$, in languages $L_1,L_2$ with $L_1\cap L_2=L(T)$. Then $T_1\cup T_2$ is conservative over $T$.

*Proof.*
1. Suppose $T_1\cup T_2\vdash\varphi$ with φ in $L(T)$. Compactness gives $\alpha_1\wedge\alpha_2\vdash\varphi$ with $\alpha_i\in T_i$.
2. So $\alpha_1\vdash\alpha_2\to\varphi$. Interpolation gives θ in $L(T)$ with $\alpha_1\vdash\theta$ and $\theta\vdash\alpha_2\to\varphi$.
3. By conservativity of $T_1$, $T\vdash\theta$. Hence $T_2\vdash\varphi$, and by conservativity of $T_2$, $T\vdash\varphi$. ∎

*Use.* Modular learning of definitional or ideal-element libraries is safe as long as the libraries share only the base vocabulary. Name clashes are exactly what break the hypothesis.

### 6.2 Speed-up: why conservative rules still matter

Conservative extensions can shorten proofs dramatically.
* Gödel (1936, "Über die Länge von Beweisen"), for $(i+1)$-th order arithmetic over $i$-th order [mem].
* Pudlák (1998) is the survey [mem].
* In propositional proof complexity, Frege plus the extension rule (definitions) is *Extended Frege*. Whether it is polynomially stronger than Frege is a major open problem [std].

So library learning (L8) adds no content but can change the search landscape by large factors. That is exactly the regime where an adversarial prover exploits a learned verifier (H1).

### 6.3 Theoretical terms: Ramsey, Carnap, Craig, Lewis

Let $T(\bar O,\bar\tau)$ be a finitely axiomatized theory with observational vocabulary $\bar O$ and theoretical vocabulary $\bar\tau$.
* **Ramsey sentence** (Ramsey 1929, "Theories", in *The Foundations of Mathematics*, 1931) [std]: $R(T):=\exists\bar X\,T(\bar O,\bar X)$, a second-order sentence.
* **Carnap sentence** (Carnap 1958, *Dialectica* 12; 1966, *Philosophical Foundations of Physics*) [mem]: $C(T):=R(T)\to T$. We have $T\equiv R(T)\wedge C(T)$.
* **Craig (1953, *JSL* 18; 1956, *Phil. Review* 65)** [std]: the $O$-consequences of an r.e. theory are r.e., hence recursively axiomatizable in $O$. Usually they are not finitely axiomatizable.
* **Lewis (1970, "How to define theoretical terms", *J. Phil.* 67)** [mem]: with a uniqueness clause, the Ramsey-style construction yields explicit definitions of the τ's.
* **Newman (1928)** [mem]: if $O$ is too thin, the Ramsey sentence says little more than a cardinality claim. Revived by Demopoulos & Friedman (1985, *Phil. Sci.* 52); see Ketland (2004, *BJPS* 55) [mem].
* **Hempel (1958)** "The theoretician's dilemma" [mem]: Craig and Ramsey show theoretical terms are dispensable for $O$-content, so their value must lie elsewhere (organization, inductive systematization, proof length).

**Proposition 6.2 (Ramsey content and Carnap invisibility) [proved here; standard second-order semantics].**
* (i) For every $O$-sentence ψ: $T\models\psi$ iff $R(T)\models\psi$.
* (ii) Every $O$-structure expands to a model of $C(T)$. In particular, $C(T)\cup D$ is satisfiable for every satisfiable set $D$ of $O$-sentences.
* (iii) Hence if $R(T)\equiv R(T')$, then for every set $D$ of $O$-data, $T\cup D$ is coherent iff $T'\cup D$ is coherent, and $T$ and $T'$ have the same $O$-consequences.

*Proof.*
* (i) A model of $R(T)$ expands, via witnesses for $\bar X$, to a model of $T$.
* (ii) If $M\not\models R(T)$, any expansion satisfies the conditional vacuously. Otherwise, expand by witnesses.
* (iii) Combine (i) and (ii). ∎

*Reading.* For a learner of physical inference rules that receives only observational world feedback plus coherence:
* the **empirical content** of learned theoretical rules is their Ramsey sentence;
* the **meaning postulate** part (Carnap sentence) is untouchable by any data.

So H7's residual non-identifiability in physics is *exactly* the Ramsey-equivalence class of the learned theory. In physics, conservativity is the wrong norm: non-conservativity over $O$ is the whole point of theoretical terms. The right norm is empirical adequacy of $R(T)$ on the calibrated observable class, which is what orchestrator idea 2 already proposes.

---

## 7. Incompleteness and the space of coherent extensions

### 7.1 The basic theorems

* **Gödel I (1931)** [std]. The original form: an ω-consistent r.e. extension of the system P is incomplete. Gödel's proof uses only 1-consistency for the unprovability of ¬G.
* **Rosser (1936, *JSL* 1)** [std]. Every *consistent* r.e. theory interpreting Robinson's Q has a Π₁ sentence ρ with $T\nvdash\rho$ and $T\nvdash\neg\rho$.
* **Essential undecidability of Q** (Tarski, Mostowski & Robinson 1953) [std]. Every consistent extension of Q is undecidable. Hence:
  * no consistent r.e. extension of Q is complete;
  * the Lindenbaum sentence algebra of each consistent r.e. $T\supseteq Q$ is the countable atomless Boolean algebra.
  * Pour-El & Kripke (1967, *Fund. Math.* 61) show these algebras are even effectively isomorphic [mem].
* **Gödel II** [std]. If $T\supseteq\mathrm{PA}$ (indeed $\supseteq$ EA, with care) is consistent and r.e., and $\mathrm{Con}_T$ is built from a standard provability predicate satisfying the Hilbert–Bernays–Löb conditions, then $T\nvdash\mathrm{Con}_T$. Hence:
  * $T+\neg\mathrm{Con}_T$ is consistent;
  * it is Σ₁-unsound, since it proves the false Σ₁ sentence $\neg\mathrm{Con}_T$;
  * it is ω-inconsistent.
* **Löb (1955, *JSL* 20)** [std]: $T\vdash\Pr_T(\varphi)\to\varphi$ implies $T\vdash\varphi$. Formalized: $T\vdash\Pr_T(\Pr_T\varphi\to\varphi)\to\Pr_T\varphi$.
* **Provability logic** [std]. GL is arithmetically complete for PA (Solovay 1976, *Israel J. Math.* 25). For variable-free modal sentences the decision is simpler (Boolos 1976) [mem].
* **Many incompatible coherent extensions.**
  * Iterating Rosser builds a binary tree of consistent finite extensions, so there are $2^{\aleph_0}$ completions.
  * Completions of PA form a Π⁰₁ class with no computable member. Some members are low (Jockusch & Soare 1972, *Trans. AMS* 173) [mem]. Some are Δ₂ (relativized Lindenbaum) [std].
  * Mostowski (1961, *Fund. Math.* 49): there is a single sentence independent of every theory in a given r.e. sequence of consistent r.e. extensions [mem; exact form unverified]. Kripke's "flexible formulas" (1962) are related [unverified].

### 7.2 Soundness notions

For r.e. $T\supseteq Q$:
* **Consistent:** $T\nvdash\bot$.
* **1-consistent:** $T$ plus all true Π₁ sentences is consistent. Equivalently, **Σ₁-sound**: $T$ proves no false Σ₁ sentence. [std; proof: if $T\vdash\sigma$ with σ false, then ¬σ is a true Π₁ sentence contradicting $T$; conversely, an inconsistency with a true Π₁ π gives $T\vdash\neg\pi$.]
* **n-consistent / Σₙ-sound:** defined analogously.
* **ω-consistent:** there is no φ(x) with $T\vdash\exists x\neg\varphi(x)$ and $T\vdash\varphi(\bar n)$ for all $n$.

Implications [std]: sound ⟹ ω-consistent ⟹ 1-consistent ⟹ consistent, and the last arrow is strict ($\mathrm{PA}+\neg\mathrm{Con}(\mathrm{PA})$).

### 7.3 Complexity of properties of r.e. theories

Index r.e. theories as $T_e=\mathrm{PA}+W_e$, where $W_e$ is the $e$-th r.e. set of sentences.

**Proposition 7.3 [proved here; standard reductions].**
* (a) $\{e: T_e\text{ consistent}\}$ is **Π₁-complete**.
* (b) $\{e:T_e\text{ Σ₁-sound}\}$ is **Π₂-complete**.
* (c) $\{e:T_e\text{ conservative over PA}\}$ is **Π₂-complete**, in the same language and so a fortiori in extended languages. Here conservative means: every axiom is a PA-theorem.
* (d) For r.e. extensions of PA, "**complete**" is equivalent to "**inconsistent**" (Rosser). It is therefore Σ₁-complete.
* (e) ω-consistency is Π₃ (upper bound). Completeness for Π₃ [unverified].
* (f) For finite propositional calculi (finitely many axiom schemata, with MP and substitution):
  * *soundness* (being contained in CPC) is **decidable**: truth tables for finitely many schemata;
  * *equivalence to CPC* is **undecidable**: Linial & Post 1949, *Bull. AMS* 55, abstract [mem]. Its upper bound is Σ₁.
  * Kuznetsov (1963) proved analogous undecidability results for superintuitionistic calculi [mem; unverified details].

*Proof.*
* (a) Membership is Π₁. For hardness, let $W_{f(e)}=\{0=1\}$ if $\varphi_e(e)\!\downarrow$, and ∅ otherwise.
* (b) and (c) Membership: Σ₁-soundness is $\forall\sigma\in\Sigma_1(\Pr_T(\sigma)\to\mathrm{True}_{\Sigma_1}(\sigma))$, which is Π₂. Conservativity is $\forall\varphi(\varphi\in W_e\to\Pr_{\rm PA}(\varphi))$, also Π₂.
* Hardness, for both (b) and (c):
  * Reduce from Tot. Let $W_{f(e)}=\{\sigma_n:n\in\mathbb N\}$ with $\sigma_n:=$ "$\varphi_e(n)$ halts", a Σ₁ sentence.
  * If $e\in\mathrm{Tot}$, all $\sigma_n$ are true, PA proves them (Σ₁-completeness), and $T_{f(e)}$ is PA: conservative and Σ₁-sound.
  * If not, some $\sigma_n$ is false. Then $T_{f(e)}$ proves a false Σ₁ sentence, and PA does not prove it, since PA is sound.
* (d) Immediate from Rosser. ∎

This confirms T2 Thm 5.3. Note that T2's construction for (c) uses Post systems and an extended vocabulary; the version here is simpler.

### 7.4 What can be learned in the limit

* **Shoenfield limit lemma** (Shoenfield 1959, *Annals* 69) [std]. $A\le_T\emptyset'$ (i.e. $A\in\Delta_2$) iff there is a computable $g$ with $\chi_A(x)=\lim_s g(x,s)$ for all $x$.
* **Gold (1965), "Limiting recursion"; Putnam (1965), "Trial and error predicates"** (both *JSL* 30) [std]: the same class, introduced as the class of predicates decidable by trial and error.
* **Mind-change bounds** correspond to levels of the Ershov hierarchy: d.c.e., $n$-c.e., ω-c.e. (Ershov 1968; Putnam 1965 already had the $k$-trial predicates) [mem].
* **Kelly (1996, *The Logic of Reliable Inquiry*)** [std]. In the data topology:
  * hypotheses verifiable in the limit are Σ₂;
  * hypotheses refutable in the limit are Π₂;
  * hypotheses decidable in the limit are Δ₂.
  * The arithmetical analogues hold for computable learners on computable data.
  * Martin & Osherson (1998, *Elements of Scientific Inquiry*) give first-order versions [mem].
* **Jeroslow (1975, "Experimental logics and Δ⁰₂ theories", *JPL* 4)** and **Hájek (1977, *JSL* 42, Π⁰₃)** [mem; details unverified]. They study theories whose theorems are those eventually stably accepted by a computable trial-and-error procedure. This is the closest existing formalization of "a learner's limiting theory".

**Corollaries for the coherence learner [proved here, modulo the cited theorems].**
1. *Consistency.* Consistency of a learned calculus is Π₁. It is decidable in the limit with at most one mind change: say "coherent" until ⊥ is found.
2. *Conservativity and Σ₁-soundness.* Both are Π₂-complete (Prop 7.3), so not Δ₂ and not limit-decidable. They are only refutable in the limit.
3. *Truth.* Consider a computable learner on computable data whose verdicts on arithmetic sentences converge. Its limit set is Δ₂.
   * True Σ₂-arithmetic is Σ₂-complete, so it is not Δ₂.
   * Hence the learner is wrong in the limit on some Σ₂ ∪ Π₂ sentence. This is T2 Thm 3.10(e).
   * It *can* be right on all Σ₁ ∪ Π₁ sentences. Run a ∅′-Lindenbaum construction starting from PA plus the true Π₁ sentences, which form a Δ₂ set.
4. *Bold in the limit implies false.* If such a learner converges to a *complete* consistent extension of PA, the limit is not Th(ℕ), because Th(ℕ) is not Δ₂. So it is false in ℕ.
   * So boldness in the limit (Lindenbaum) buys completeness at the price of certain falsity.
   * A sound limit theory is necessarily incomplete.
   * This is the precise form of "coherence-maximality forces error" in arithmetic.
5. *Logical induction.* Logical induction (Garrabrant, Benson-Tilsen, Critch, Soares & Taylor 2016, arXiv:1609.03543) [std] is a computable belief sequence whose limit is a coherent probability measure on the completions of the theory. Gaifman (1964) is the classical notion of a measure on sentences [mem].
   * It is the natural computable realization of the user's "Solomonoff axiom induction" note (`ai/learning/solomonoff induction/`), and of its "true / false / independent" trichotomy.
   * It does not by itself enforce reflection commitments. For example, nothing forces $P_\infty(\mathrm{Con}(\mathrm{PA}))=1$ [unverified; check].

---

## 8. Reflection principles, progressions, implicit commitment

### 8.1 Reflection principles

For r.e. $T\supseteq\mathrm{EA}$ and a formula class Γ:
* $\mathrm{Rfn}_\Gamma(T)$ (local reflection) is the schema $\Pr_T(\ulcorner\varphi\urcorner)\to\varphi$ for sentences $\varphi\in\Gamma$.
* $\mathrm{RFN}_\Gamma(T)$ (uniform reflection) is the schema $\forall x\,(\Pr_T(\ulcorner\varphi(\dot x)\urcorner)\to\varphi(x))$ for $\varphi(x)\in\Gamma$.

Facts [std/mem; Kreisel & Lévy 1968, *Z. Math. Logik Grundlagen Math.* 14; Beklemishev 2005, *Russian Math. Surveys* 60; Smoryński 1977]:
* Over EA: $\mathrm{Con}(T)\equiv\mathrm{Rfn}_{\Pi_1}(T)\equiv\mathrm{RFN}_{\Pi_1}(T)$.
* $\mathrm{RFN}_{\Sigma_n}(T)\equiv\mathrm{RFN}_{\Pi_{n+1}}(T)$.
* $\mathrm{RFN}_{\Sigma_1}(T)$ expresses 1-consistency.
* $\mathrm{PA}\equiv\mathrm{EA}+\mathrm{RFN}(\mathrm{EA})$ (Kreisel–Lévy) [mem]. $\mathrm{I}\Sigma_n\equiv\mathrm{EA}+\mathrm{RFN}_{\Pi_{n+2}}(\mathrm{EA})$ for $n\ge1$ (Leivant 1983; Beklemishev) [mem].
* Uniform reflection is a *formalized, uniform ω-rule*. From "for each $x$, $T$ proves $\varphi(\bar x)$" (formalized as $\forall x\Pr_T(\varphi(\dot x))$), infer $\forall x\varphi(x)$. This is the principled form of "I can prove each instance, so the generalization holds".

### 8.2 Graded entitlement

**Proposition 8.2 [proved here].** Let $T\supseteq Q$ be r.e. (and $\supseteq$ EA for the formalized equivalences).
* (a) Every instance of $\mathrm{Rfn}_{\Pi_1}(T)$ is true iff $T$ is consistent.
* (b) Every instance of $\mathrm{RFN}_{\Sigma_1}(T)$ is true iff $T$ is Σ₁-sound.
* (c) Every instance of $\mathrm{RFN}(T)$ is true iff $T$ is sound.

*Proof.*
* (a, ⇒) Use the instance with $\varphi=(0=1)$.
* (a, ⇐) Suppose $T\vdash\varphi$, with φ Π₁ and false. Then ¬φ is a true Σ₁ sentence, so $Q\vdash\neg\varphi$, and $T$ is inconsistent.
* (b) The instances with sentences give Σ₁-soundness. Conversely, Σ₁-soundness gives each numerical instance.
* (c) Similar. ∎

*Reading.* What a coherence-trained learner actually has is *evidence of coherence*: no contradiction found. That entitles it to $\mathrm{Con}(T)$, equivalently Π₁-reflection, all of whose instances are true if $T$ is consistent. Commitment to $\mathrm{RFN}_{\Sigma_1}(T)$ or beyond requires Σ₁-soundness. No coherence test certifies Σ₁-soundness, not even in the limit (Prop 7.3(b)). So **coherence licenses exactly Π₁-reflection**. Stronger reflection is a bet on soundness, and its risk is real: for Σ₁-unsound $T$, $\mathrm{RFN}_{\Sigma_1}(T)$ is false.

### 8.3 Reflective coherence: stronger than coherence, never sufficient

Let $T^{(0)}=T$ and $T^{(n+1)}=T^{(n)}+\mathrm{Con}(T^{(n)})$. Say $T$ is *reflectively coherent* (RC) if every $T^{(n)}$ is consistent.

**Theorem 8.3 [proved here].**
* (a) Every Σ₁-sound $T$ is RC. The reason is that adding a true Π₁ sentence π preserves Σ₁-soundness: if $T+\pi\vdash\sigma$ with σ false Σ₁, then $T\vdash\neg\pi\vee\sigma$, which is a false Σ₁ sentence.
* (b) RC is Π₁ in the index of $T$. More generally, for any uniformly r.e. family of reflection extensions, including transfinite iterations along any fixed computable notation system, "all members consistent" is Π₁.
* (c) Hence some Σ₁-unsound $T$ is RC. Otherwise RC would equal Σ₁-soundness, a Π₂-complete set, contradicting (b). The same argument shows that *no Δ₂ test* (no test decidable in the limit) passed by all Σ₁-sound theories separates them from the unsound ones.
* (d) RC is strictly stronger than consistency, with unbounded depth. For $k\ge1$, $T_k:=\mathrm{PA}+\Box^k\bot$ (□ = $\Pr_{\rm PA}$) is consistent and Σ₁-unsound. $T_k^{(n)}$ is consistent iff $n<k$. In particular, $\mathrm{PA}+\neg\mathrm{Con}(\mathrm{PA})$ dies at round 1.

*Proof of (d).*
* *The modal translation.* $\Box^k\bot$ is false: by induction, $\Box^{j}\bot$ is false for all $j$, since PA is sound. The added axiom $\alpha_n$ of $T_k^{(n)}$ satisfies $\alpha_0=\Box^k\bot$ and $\alpha_{n+1}=\alpha_n\wedge\Diamond\alpha_n$, because $\mathrm{Con}(\mathrm{PA}+\alpha)\leftrightarrow\Diamond\alpha$ provably.
* *The Kripke analysis.* In finite irreflexive transitive trees, $\Box^k\bot$ holds at $w$ iff the height of $w$ is $<k$. By induction, $\alpha_n$ holds at $w$ only if $n\le h(w)<k$, and it holds at a point of height exactly $n$ when $n<k$. So $\alpha_n$ is GL-satisfiable iff $n<k$.
* *Transfer to PA.* For variable-free sentences, GL-satisfiability coincides with PA-consistency of the arithmetical translation (Solovay 1976; Boolos 1976). ∎

*Reading.*
* Accepting one's own consistency is a principled extra coherence test. It refutes hypotheses that "predict their own incoherence", and is the mathematical analogue of a self-trust or reflection filter.
* It is not a substitute for soundness. The ineliminable residue of Σ₁-unsound coherent hypotheses survives every computable reflective test.
* This sharpens T2 Thm 3.9 and answers part of T2's open problem 6.

### 8.4 Progressions

* **Turing (1939, "Systems of logic based on ordinals", *Proc. LMS* 45)** [std/mem].
  * Define $T_0=T$, $T_{a+1}=T_a+\mathrm{Con}(T_a)$, and unions at limits, along notations $a\in\mathcal O$.
  * Turing's completeness theorem: for each true Π₁ sentence π, there is $a\in\mathcal O$ with $|a|=\omega+1$ such that $T_a\vdash\pi$.
  * The notation $a$ encodes π's truth, so the completeness is "cheap".
* **Feferman (1962, "Transfinite recursive progressions of axiomatic theories", *JSL* 27)** [std/mem].
  * Progressions based on iterated *uniform* reflection are complete for all true arithmetic sentences, along suitable paths through $\mathcal O$.
  * I recall the bound $|a|<\omega^{\omega^{\omega+1}}$ [mem; unverified].
* **Feferman & Spector (1962, *JSL* 27)** [mem]: along any Π¹₁ path through $\mathcal O$, the progression is incomplete.
* **The moral** (Feferman; Kreisel; Franzén 2004, *BSL* 10, "Transfinite progressions: a second look at completeness") [mem].
  * The new knowledge lies in recognizing that a notation denotes a well-ordering, and $\mathcal O$ is Π¹₁-complete [std].
  * Reflection relocates the inductive problem; it does not solve it.
* **Autonomous progressions** (Feferman 1964, *JSL* 29; Schütte 1965) [std].
  * The rule: ascend to ordinal α only after proving, at an earlier stage, that a notation for α is well-founded.
  * Predicative analysis then has proof-theoretic ordinal Γ₀.
  * This is a principled, non-arbitrary stopping rule for a reflecting learner.

### 8.5 Feferman's reflective closure and the implicit commitment thesis

* **Feferman (1991, "Reflecting on incompleteness", *JSL* 56(1):1–49)** [mem].
  * He asks what one *ought to* accept given that one accepts a schematic theory $S$. Schemata are read as open-ended, with a free predicate letter $P$ and a substitution rule.
  * He defines the reflective closure $\mathrm{Ref}(S)$, which adds compositional truth plus reflection.
  * For non-finitist arithmetic, the schematic version $\mathrm{Ref}^\*(\mathrm{PA}(P))$ has the strength of predicative analysis ($\Gamma_0$) [mem].
  * Follow-ups: Feferman & Strahm (2000, *APAL* 104; 2010, *RSL* 3) on "unfolding" [mem].
* **Kreisel (1970, "Principles of proof and ordinals implicit in given concepts")** [mem]: the earlier formulation of "implicit in accepting".
* **The implicit commitment thesis (ICT).** The thesis: whoever accepts $T$ is thereby committed to statements not provable in $T$, such as Con(T) and reflection. Main sources [all mem; summaries unverified]:
  * Dean (2015, "Arithmetical reflection and the provability of soundness", *Phil. Math.* 23(1)) scrutinizes the arguments from acceptance to reflection.
  * Nicolai & Piazza (2019, *Erkenntnis* 84) locate the "semantic core" of the commitment in truth-theoretic principles.
  * Łełyk & Nicolai (2022, "A theory of implicit commitment", *Synthese* 200).
  * Cieśliński (2017, *The Epistemic Lightness of Truth*, CUP).
  * Horsten & Leigh (2017, "Truth is simple", *Mind* 126).
  * Fischer, Horsten & Nicolai (2021, "Hypatia's silence", *Noûs* 55).
* **The brief's guesses.** I could not identify a "Lingamfelter" in this literature. Nogina's work, as far as I recall, is in justification and provability logic with Artemov, not ICT [unverified]. Artemov (2019, arXiv, "The provability of consistency") argues that PA proves its consistency in a schematic, "selector" sense. This is relevant but contested [mem].
* **Truth-theoretic grounding** [mem].
  * Compositional truth with full induction, CT[PA], proves global reflection for PA, and hence Con(PA).
  * CT⁻ without induction for the truth predicate is conservative over PA (Kotlarski, Krajewski & Lachlan 1981; Enayat & Visser 2015; Leigh 2015).
  * Accepting "everything $T$ proves is *true*", with induction for "true", is thus where reflection comes from. This is the formal side of the Shapiro (1998) and Ketland (1999) conservativeness debate.

**What this gives the project.** It is a principled source of new inferences beyond imitation.
* Once a learned system $R$ is accepted, the learner is entitled to:
  * Con(R) and Π₁-reflection, on coherence evidence alone (Prop 8.2);
  * uniform reflection, as a bet on soundness, which reflective coherence partly tests (Thm 8.3);
  * the open-ended reading of its schemata, i.e. instances in *new vocabulary* (Feferman's substitution rule).
* None of these are in the deductive closure of the imitation data. Löb's theorem guarantees that $R$ itself never certifies them.

### 8.6 Open-ended schemata and categoricity (relevant to H7)

* **McGee (1997, "How we learn mathematical language", *Phil. Review* 106)** and **Parsons (1990, "The uniqueness of the natural numbers", *Iyyun* 39)** [mem].
  * The claim: if two parties each accept the induction schema *open-endedly* (for every extension of the language), then in a joint language their number systems are provably isomorphic. This is the "internal categoricity" argument.
  * See Button & Walsh (2018, *Philosophy and Model Theory*, OUP) for the current treatment [std].
  * Precise first-order versions are delicate [unverified].
* **Reading.**
  * Open-ended structurality (substitution into schemata across language extensions) does for arithmetic's *structure* what structurality plus coherence does for CPC's *meanings*: it pins them.
  * But it does not pin the *theory*. The Gödel/Rosser residue is epistemic (which truths we can reach), not semantic (which structure we mean).
  * This refines H7. The Kripkenstein residue of arithmetic is not "quus versus plus". It is which independent sentences to accept, and only reflection and stronger theories bear on that.
  * Compare Putnam (1980, "Models and reality", *JSL* 45) for the opposite, model-theoretic worry [std].

---

## 9. Kreisel's informal rigour and the squeezing argument

**The argument** (Kreisel 1967, "Informal rigour and completeness proofs", in Lakatos (ed.), *Problems in the Philosophy of Mathematics*, North-Holland; pages 138–186 [unverified]). Let:
* Val(φ): φ is intuitively valid, i.e. true in every structure, whatever its domain;
* D(φ): φ is derivable in a standard first-order calculus;
* V(φ): φ is true in all set-sized (or all countable) models.

Then:
* $D\subseteq\mathrm{Val}$, because each rule is intuitively sound;
* $\mathrm{Val}\subseteq V$, because set models are structures;
* $V\subseteq D$, by Gödel's completeness theorem (Gödel 1930; Henkin 1949).

So all three coincide. One can sharpen V using the Hilbert–Bernays arithmetized completeness theorem (Hilbert & Bernays 1939; Kleene 1952) [mem]. A non-derivable φ has a countermodel with domain ℕ and Δ₂ relations. So invalidity is witnessed by a *limit-computable* countermodel.

**Discussion** [mem]:
* P. Smith (2011, "Squeezing arguments", *Analysis* 71(1)) generalizes the argument and applies it to Church's thesis.
* Field (2008, *Saving Truth from Paradox*, ch. 2; 1991, "Metalogic and modality", *Phil. Studies* 62) uses it to argue that model-theoretic validity is extensionally correct without being the definition of validity.
* Andrade-Lotero & Dutilh Novaes (2012, *JPL* 41) examine it for syllogistic.
* Dean & Kurokawa ("On the methodology of informal rigour", in Horsten & Welch (eds.), *Gödel's Disjunction*, OUP 2016) [unverified].
* The brief also asks for "Halbach discussions". Halbach (2020, "The substitutional analysis of logical consequence", *Noûs* 54) proves a coincidence of substitutional and model-theoretic consequence. I am unsure whether he frames it as a squeeze [unverified].
* Kreisel's paper also argues that CH is decided by second-order validity, via Zermelo's (1930) quasi-categoricity of second-order ZF [std]. That is informal rigour *without* a completeness theorem.

**The learned-squeeze template (proposal).** "A setup that would have worked before formalization" needs three ingredients.
1. A **lower bound**: a learned calculus $R_n$ accepted only conservatively, so that $\langle R_n\rangle\subseteq\mathrm{Val}$. This is the soundness side, H1 and L2.
2. An **upper bound**: a test that every valid inference passes, e.g. "structural and coherent on designated contexts" (§2), or "no countermodel found in the Δ₂ search".
3. A **completeness theorem** for some finite calculus $R^\*$ that the learner can reach. Then the bounds collapse once $R^\*\subseteq R_n$.

*Instances and limits.*
* For CPC, (2) plus (3) is Thm 2.2. T2's Thm 3.3 is literally a squeeze.
* For FOL, (3) is Gödel.
* For arithmetic and second-order logic there is no (3), so there is no squeeze for mathematical truth (L6 §7 reaches the same conclusion).
* Even when a squeeze exists, *the learner cannot verify that it has closed*:
  * completeness of $R_n$ is Π₂ in general;
  * it is undecidable even for finite propositional calculi, whose soundness is decidable (Linial–Post, Prop 7.3(f)).
* The guarantee is therefore of the form "if the target is complete for a finite calculus, the learner converges (EX) to it". This is a non-trivial but honest form of "it would have worked".

---

## 10. Decidability and complexity table

| question | complexity | source |
|---|---|---|
| is this step an instance of schema $S$ (first-order matching, metavariables for formulas/terms) | linear time | [std] |
| same, with capture-avoidance side conditions ("$t$ free for $x$", "$x$ not free in φ") | polynomial | [std] |
| same, schema with second-order metavariables applied to terms (e.g. the induction schema in a binder-free encoding) | NP-complete (second-order matching; Baxter 1977) | [mem] |
| higher-order matching in general | decidable (Stirling 2009, *LMCS* 5) | [mem] |
| higher-order *pattern* unification (Miller patterns) | decidable, unitary, efficient (Miller 1991) | [mem] |
| higher-order unification | undecidable (Huet 1973, third order; Goldfarb 1981, second order) | [mem] |
| is this a correct Hilbert/Metamath proof | polynomial (essentially linear) | [std] |
| dependent type checking (Lean) | decidable for idealized CIC. Lean's definitional equality is undecidable in theory (Carneiro 2019, MSc thesis) | [mem] |
| CPC validity / rule validity | coNP-complete | Cook 1971 |
| IPC derivability | PSPACE-complete | Statman 1979 |
| IPC admissibility | coNEXP-complete | Jeřábek 2007 [mem] |
| RCF / Tarski geometry | decidable; doubly exponential in quantifier alternation (Collins 1975; Davenport & Heintz 1988) | [mem] |
| Presburger | decidable; $2^{2^{cn}}$ lower bound (Fischer & Rabin 1974) | [mem] |
| identity of elementary-function expressions | undecidable (Richardson 1968) | [mem] |
| polynomial identity | coRP (Schwartz–Zippel) | [std] |
| FOL validity; theoremhood of an r.e. theory ⊇ Q | Σ₁-complete (Church 1936; Turing 1936) | [std] |
| consistency of an r.e. calculus | Π₁-complete | Prop 7.3(a) |
| conservativity of an r.e. extension of PA | Π₂-complete | Prop 7.3(c) |
| conservativity over a decidable base | Π₁ (T2 Thm 5.3(d)); over CPC = consistency (Cor 2.4) | proved |
| Σ₁-soundness | Π₂-complete | Prop 7.3(b) |
| completeness of an r.e. extension of PA | ⟺ inconsistency, Σ₁-complete | Prop 7.3(d) |
| finite propositional calculus ⊆ CPC (soundness) | decidable | Prop 7.3(f) |
| finite propositional calculus = CPC (completeness) | undecidable (Linial–Post 1949), Σ₁ | [mem] |
| truth of Σₙ arithmetic sentences | Σₙ-complete; not limit-computable for $n\ge2$ | [std] |
| is $a\in\mathcal O$ (Kleene's ordinal notations) | Π¹₁-complete | [std] |

*Moral.* For a fixed finite set of rule schemata, *checking a step* is cheap. Checking that a whole learned system is coherent is Π₁; that it is conservative or Σ₁-sound is Π₂; that it is complete is Π₂ in general and undecidable even propositionally.

The orchestrator's H1 architecture fits this ladder exactly:
* a cheap, exact step-checker;
* a coherence monitor that is refutation-complete in the limit;
* soundness beyond Π₁, which has to be a *prior* or a bet, not a check.

---

## 11. Answers to the key question

**Q1. In which logics does the maximal coherent extension of the data coincide with the target?**
* Exactly when the target is the unique maximal coherent hypothesis above itself (Prop 2.7):
  * CPC consequence in every Boolean fragment (Thm 2.2), with a non-empty designated context when the fragment has no theorems;
  * the equational theory of Boolean algebras;
  * complete theories (RCF, ACF_p, Presburger, DLO, Tarski geometry);
  * trivially, Triv and Ver.
* Relative versions:
  * ring identities become Post-complete relative to the characteristic-0 context (Thm 2.6(iv));
  * CR is recovered by *skeptical* coherence even without that context (Thm 2.6(iii)).
* Over such bases, coherence equals conservativity (Cor 2.4).

**Q2. Where does coherence fail to determine the target?**
* IPC and all intermediate logics: coherence-blind by Glivenko, and boldness overshoots to CPC.
* Normal modal logics: boldness yields Triv or Ver.
* Schematic first-order logic: small-domain collapse.
* Ring identities without characteristic data.
* Arithmetic:
  * no r.e. coherence-maximum (Rosser);
  * coherent Σ₁-unsound alternatives, some of which survive every computable reflective test (Thm 8.3);
  * a complete limit theory must be false (§7.4).
* Empirical theories: Carnap-sentence invisibility (Prop 6.2).
* The admissible/derivable gap, for any non-structurally-complete logic, when contexts are absent (Prop 3.3).

**Q3. What can be checked or learned in the limit?**
* Step-checking is decidable and cheap.
* Coherence is limit-decidable with one mind change.
* Conservativity and Σ₁-soundness are only refutable in the limit.
* Completeness of a learned calculus is not checkable.
* Truth beyond Δ₂ is not limit-learnable by computable means.
* Positive learning results therefore have the form: "EX-identification for targets that are coatoms (bold), meets of coatoms (skeptical) or finitely axiomatized (minimal)", with Gold-style impossibility for the rest (T2 Cor 2.8, Thm 3.6(c), Thm 3.9).

**Q4. What do reflection principles say about new inferences?**
* A learner that accepts a learned system $R$ is entitled to Con(R), i.e. Π₁-reflection, on coherence evidence alone.
* Uniform reflection (the formalized ω-rule) requires soundness, which coherence cannot certify.
* Open-ended instantiation of schemata in new vocabulary is part of what acceptance means (Feferman 1991; McGee 1997).
* Reflection is the principled, non-imitative growth mechanism. Its transfinite iteration is limited by well-ordering recognition (Π¹₁), and autonomy gives the principled stopping point (Γ₀).
* As a side effect, reflection is an additional coherence test that kills hypotheses predicting their own incoherence.

---

## 12. Theorem candidates for the project

All of the following are proved in this memo except where marked.

1. **TC1, complete extension lattices of Boolean fragments (Thm 2.2).** Combined with T2 Thm 3.3(b), this gives a bias-free EX-identification theorem for *every* Boolean fragment: one coherence datum, on a non-empty context exactly when the fragment has no theorems. It comes with the SAT-hardness and polynomial-witness statement of Cor 2.3.
2. **TC2, coherence = conservativity over Post-complete bases (Cor 2.4).** This yields a corollary for inferentialism: Belnap's existence condition is vacuous over CPC beyond non-triviality.
3. **TC3, the necessity of non-atomic substitution (Prop 2.5).** It can be made quantitative: how much instantiation power does the generalization operator need? Constants suffice; renaming does not.
4. **TC4, equational Post-completeness relative to characteristic, plus skeptical coherence (Thm 2.6, Prop 2.7).** This is directly testable in the algebra workhorse.
   * Prediction: a bold coherence learner without disequation data converges to characteristic-$p$ identities on some texts.
   * With the context $\{n\cdot1\neq0\}_{n\le N}$, every fallacy whose characteristic witness $n$ is $\le N$ is refuted by one closed instance.
5. **TC5, the context-necessity theorem (Prop 3.3 plus the KP rule).** No learner fed only categorical (context-free) data can identify the consequence relation of a non-structurally-complete logic. This is a formal argument that the user's contexts are required. A natural extension, still to be proved: for intermediate logics, identification becomes possible with contexts drawn from unifiable formulas.
6. **TC6, overshoot theorems (Thms 3.1, 3.4, §3.4).** The bold coherence learner provably converges to CPC from intuitionistic data, and to Triv or Ver from modal data. These are clean negative results showing that minimality is necessary.
7. **TC7, graded reflective entitlement and the incompleteness of reflective coherence (Prop 8.2, Thm 8.3).**
   * The PA + □ᵏ⊥ family shows that the reflective depth needed to refute a coherent unsound hypothesis is unbounded.
   * The Rice-style argument shows that no limit-decidable test suffices.
   * *Conjecture* [open]: for every Σ₁-unsound $T$ with $T\vdash\sigma$ false Σ₁, the reflective depth needed is bounded below by a function of the "provability-nesting" of σ; and $\mathrm{PA}+\neg\mathrm{Con}(\mathrm{ZFC})$ is RC.
     * I verified only the first round of the latter: $\mathrm{PA}+\neg\mathrm{Con(ZFC)}+\neg\Pr_{\rm PA}(\mathrm{Con(ZFC)})$ is consistent.
     * Otherwise PA would prove $\neg\mathrm{Con(ZFC)}\leftrightarrow\Pr_{\rm PA}(\mathrm{Con(ZFC)})$. Making Con(ZFC) a Gödel fixed point would force $\mathrm{PA}\vdash\mathrm{Con(ZFC)}\leftrightarrow\mathrm{Con(PA)}$, and then ZFC ⊢ Con(ZFC).
8. **TC8, the conservative-library combination lemma (Prop 6.1).** A safety theorem for modular library learning (L8).
9. **TC9, theoretical underdetermination is exactly Ramsey-equivalence (Prop 6.2).** This is the physics instance of H7. Combined with orchestrator idea 2, it suggests a theorem: a refinement-tower checker is complete for empirical content iff it is complete for the Ramsey sentences of the tower's top model, restricted to the calibrated observables. This is a candidate, not proved.
10. **TC10, bold-in-the-limit implies false (§7.4, Cor 4).** Any computable learner whose limit theory is a complete extension of PA is wrong in ℕ. The best achievable is correctness on Σ₁ ∪ Π₁, which the Popperian learner of T2 Thm 3.10(c) attains.
11. **TC11, a learned squeeze (§9), as a framework theorem.** If the target consequence relation is generated by a finite calculus and satisfies a "coherence upper bound" (every structural coherent hypothesis is below it), then a sound-and-bold learner EX-identifies it. Moreover, no learner can certify convergence (by Linial–Post, even propositionally). This is the honest form of "would have worked before formalization".
12. **TC12, interpolant blame-splitting (§5(b))** [sketch]. For refutations in a resolution-style calculus spanning two chunks, the negative bag splits in linear time into two smaller bags joined by an interpolant. This could give a logarithmic-depth blame search, in the style of a mistake bound, over chunk structure.

---

## 13. Corrections and refinements to the brief (and to T2)

1. **H4's "Post-completeness ⇒ maximal coherent structural extension is the truth"** is correct for CPC *consequence*, but only with three qualifications:
   * (i) hypotheses must be closed under substitution of formulas, or at least constants, for atoms; renaming-only generalization fails (Prop 2.5);
   * (ii) theorem-free fragments need a non-empty designated context ($C_{\rm ai}$);
   * (iii) it is a property of the *target*, true only for coatoms.
   For IPC, modal logics, schematic FOL and ring identities, the bold coherent learner provably converges to the *wrong* logic (CPC, Triv or Ver, small domains, characteristic $p$).
   * Non-structural hypotheses, such as memorized facts, have $2^{\aleph_0}$ maximal coherent extensions (Lindenbaum completions), even over CPC.
2. **Orchestrator idea 3, "coherence or evaluation refutes each of these [algebra fallacies]".** For equational hypotheses, coherence **alone** refutes none of the freshman's-dream-type fallacies: they are all valid in some $\mathbb F_p$. Only coherence with designated disequations $n\cdot1\neq0$, i.e. integer evaluation, refutes them (Thm 2.6). Evaluation is therefore *not* a separate world oracle. It is coherence against the characteristic-0 diagram, and its witnesses are closed instances.
3. **H4's "world feedback (computation) can refute false Π₁ claims".** True, but for hypotheses extending Q this adds nothing beyond coherence (T2 Lemma 3.7). What computation cannot do is refute false *Σ₁* claims such as ¬Con(PA). Those require reflection or trust, and some survive every computable reflective test (Thm 8.3).
4. **"Conservativity" as the fallback criterion in H4 and orchestrator §4.**
   * It is Π₂-complete. It collapses to coherence over Post-complete bases (Cor 2.4).
   * It rejects classical negation over positive intuitionistic logic (T2 Prop 5.2).
   * It is the *wrong* norm in two places:
     * for theoretical terms, whose non-conservativity over $O$ is their point (§6.3);
     * for mathematical growth, since Con(T), reflection and new set-existence axioms are non-conservative by design.
   * The principled norms are: definitional conservativity for libraries; graded reflection for mathematical growth; empirical adequacy of the Ramsey sentence for physics.
5. **H5's use of Kreisel.** The squeeze pins *logical* validity, where a completeness theorem exists. It does not pin mathematical truth or axioms (agreeing with L6 §7). Moreover, the learner can never verify that its squeeze has closed (Linial–Post).
6. **H6, contexts.** Robinson joint consistency and Craig interpolation give a precise *merge criterion* and a *conflict footprint* for chunks (§5). Prop 3.3 gives an independent, purely logical reason why contexts are necessary: they are what separates derivable from admissible rules.
7. **H7, Kripkenstein residue in arithmetic.** Open-ended schemata plausibly remove the *semantic* residue (internal categoricity: McGee, Parsons). What remains is *epistemic*: which independent sentences to accept. In physics the residue is exactly Ramsey-equivalence (Prop 6.2).
8. **The brief's citation guesses.**
   * "Lingamfelter" is not a name I recognize in the implicit-commitment literature. "Nogina" is, I believe, associated with justification and provability logic rather than ICT [unverified].
   * The core ICT references are Feferman 1991, Kreisel 1970, Dean 2015, Nicolai & Piazza 2019, Łełyk & Nicolai 2022, Cieśliński 2017, Horsten & Leigh 2017 and Fischer, Horsten & Nicolai 2021 [mem].
9. **On T2 (no errors found; refinements).**
   * T2 Thm 3.1 and Prop 3.2 are special cases of Thm 2.2 here, which covers every Boolean fragment.
   * T2 Prop 5.2 ("coherence ≠ conservativity") is right for its intuitionistic base, but should note that equality holds over Post-complete bases (Cor 2.4).
   * T2 Thm 3.9 can be strengthened by Thm 8.3: reflective coherence does not help in the limit.
   * T2's citations "Pogorzelski 1971", "Wójcicki 1988", "Harrop 1960", "Iemhoff 2001" and "Rybakov 1997" match my recollection [mem].
   * T2's "Prop 3.11 examples" are correct as stated [std].

---

## References

Markers: [std] textbook-standard; [mem] from memory, believed correct; [unverified] uncertain. Nothing was checked online in this session.

**Propositional logic, consequence operations, matrices**
* Post, E. L. (1921). Introduction to a general theory of elementary propositions. *Amer. J. Math.* 43(3):163–185. [std]
* Tarski, A. (1930). Fundamentale Begriffe der Methodologie der deduktiven Wissenschaften I. *Monatshefte f. Math. u. Physik* 37:361–404. [mem]
* Łoś, J. & Suszko, R. (1958). Remarks on sentential logics. *Indag. Math.* 20:177–183. [mem]
* Wójcicki, R. (1970). Some remarks on the consequence operation in sentential logics. *Fund. Math.* 68:269–279. [mem]
* Wójcicki, R. (1988). *Theory of Logical Calculi: Basic Theory of Consequence Operations*. Synthese Library 199, Kluwer. [std]
* Pogorzelski, W. A. (1971). Structural completeness of the propositional calculus. *Bull. Acad. Polon. Sci., Sér. Sci. Math.* 19:349–351. [mem]
* Tokarz, M. (1973). Connections between some notions of completeness of structural propositional calculi. *Studia Logica* 32. [unverified content]
* Rautenberg, W. (1981). 2-element matrices. *Studia Logica* 40(4):315–353. [mem; content relative to Thm 2.2 unverified]
* Font, J. M. (2016). *Abstract Algebraic Logic: An Introductory Textbook*. College Publications. [mem]
* Suszko, R. (1977). The Fregean axiom and Polish mathematical logic in the 1920s. *Studia Logica* 36(4):377–380. [mem]
* Scott, D. (1974). Completeness and axiomatizability in many-valued logic. In *Proc. Tarski Symposium*, Proc. Symp. Pure Math. 25, AMS, 411–435. [mem]
* Shoesmith, D. J. & Smiley, T. J. (1978). *Multiple-Conclusion Logic*. CUP. [std]
* Carnap, R. (1943). *Formalization of Logic*. Harvard UP. [std]
* Cook, S. A. (1971). The complexity of theorem-proving procedures. *STOC*. [std]
* Linial, S. & Post, E. L. (1949). Recursive unsolvability of the deducibility, Tarski's completeness and independence of axioms problems of propositional calculus (abstract). *Bull. AMS* 55:50. [mem]
* Kalicki, J. & Scott, D. (1955). Equational completeness of abstract algebras. *Indag. Math.* 17:650–659. [mem]
* Richardson, D. (1968). Some undecidable problems involving elementary functions of a real variable. *JSL* 33:514–520. [mem]

**Intuitionistic, intermediate and modal logics; admissible rules**
* Glivenko, V. (1929). Sur quelques points de la logique de M. Brouwer. *Bull. Acad. Royale de Belgique* (5) 15:183–188. [mem]
* Kreisel, G. & Putnam, H. (1957). Eine Unableitbarkeitsbeweismethode für den intuitionistischen Aussagenkalkül. *Archiv f. math. Logik u. Grundlagenforschung* 3:74–78. [mem]
* Harrop, R. (1960). Concerning formulas of the types A→B∨C, A→(Ex)B(x) in intuitionistic formal systems. *JSL* 25(1):27–32. [mem]
* Jankov, V. A. (1968). The construction of a sequence of strongly independent superintuitionistic propositional calculi. *Soviet Math. Dokl.* 9:806–807. [mem]
* Makinson, D. (1971). Some embedding theorems for modal logic. *NDJFL* 12(2):252–254. [mem]
* Dzik, W. & Wroński, A. (1973). Structural completeness of Gödel's and Dummett's propositional calculi. *Studia Logica* 32:69–73. [mem]
* Prucnal, T. (1976). Structural completeness of Medvedev's propositional calculus. *Rep. Math. Logic* 6:103–105. [mem]
* Citkin, A. (1978). On structurally complete superintuitionistic logics. *Soviet Math. Dokl.* 19. [mem]
* Maksimova, L. (1977). Craig's theorem in superintuitionistic logics and amalgamable varieties of pseudo-Boolean algebras. *Algebra and Logic* 16. [mem]
* Statman, R. (1979). Intuitionistic propositional logic is polynomial-space complete. *TCS* 9(1):67–72. [std]
* Rybakov, V. V. (1997). *Admissibility of Logical Inference Rules*. Studies in Logic 136, Elsevier. [std]
* Ghilardi, S. (1999). Unification in intuitionistic logic. *JSL* 64(2):859–880. [mem]
* Iemhoff, R. (2001). On the admissible rules of intuitionistic propositional logic. *JSL* 66(1):281–294. [mem]
* Rozière, P. (1992). *Règles admissibles en calcul propositionnel intuitionniste*. PhD thesis, Paris VII. [mem]
* Jeřábek, E. (2007). Complexity of admissible rules. *Arch. Math. Logic* 46(2):73–92. [mem]
* Chagrov, A. & Zakharyaschev, M. (1997). *Modal Logic*. OUP. [std]
* Visser, A. (1999). Rules and arithmetics. *NDJFL* 40(1):116–140. [mem]

**Interpolation, definability, conservativity, theoretical terms**
* Beth, E. W. (1953). On Padoa's method in the theory of definition. *Indag. Math.* 15:330–339. [mem]
* Craig, W. (1953). On axiomatizability within a system. *JSL* 18(1):30–32. [mem]
* Craig, W. (1956). Replacement of auxiliary expressions. *Phil. Review* 65(1):38–55. [mem]
* Craig, W. (1957). Linear reasoning; Three uses of the Herbrand–Gentzen theorem. *JSL* 22(3):250–268, 269–285. [std]
* Robinson, A. (1956). A result on consistency and its application to the theory of definition. *Indag. Math.* 18:47–58. [mem]
* Belnap, N. (1962). Tonk, plonk and plink. *Analysis* 22(6):130–134. [std]
* Prior, A. N. (1960). The runabout inference-ticket. *Analysis* 21(2):38–39. [std]
* Došen, K. & Schroeder-Heister, P. (1985). Conservativeness and uniqueness. *Theoria* 51(3):159–173. [mem]
* Shoenfield, J. R. (1967). *Mathematical Logic*. Addison-Wesley. [std]
* Simpson, S. G. (2009). *Subsystems of Second Order Arithmetic*, 2nd ed. CUP/ASL. [std]
* Gödel, K. (1936). Über die Länge von Beweisen. *Ergebnisse eines math. Kolloquiums* 7:23–24. [mem]
* Pudlák, P. (1998). The lengths of proofs. In Buss (ed.), *Handbook of Proof Theory*, 547–637. [mem]
* Krajíček, J. (1997). Interpolation theorems, lower bounds for proof systems, and independence results for bounded arithmetic. *JSL* 62(2):457–486. [mem]
* Pudlák, P. (1997). Lower bounds for resolution and cutting plane proofs and monotone computations. *JSL* 62(3):981–998. [mem]
* McMillan, K. (2003). Interpolation and SAT-based model checking. *CAV 2003*, LNCS 2725. [mem]
* Ramsey, F. P. (1929/1931). Theories. In *The Foundations of Mathematics* (ed. Braithwaite). [std]
* Carnap, R. (1958). Beobachtungssprache und theoretische Sprache. *Dialectica* 12:236–248. [mem]
* Carnap, R. (1966). *Philosophical Foundations of Physics*. Basic Books. [std]
* Lewis, D. (1970). How to define theoretical terms. *J. Phil.* 67(13):427–446. [mem]
* Hempel, C. G. (1958). The theoretician's dilemma. *Minnesota Studies in the Philosophy of Science* 2:37–98. [mem]
* Newman, M. H. A. (1928). Mr. Russell's "causal theory of perception". *Mind* 37:137–148. [mem]
* Demopoulos, W. & Friedman, M. (1985). Bertrand Russell's *The Analysis of Matter*. *Phil. Sci.* 52(4):621–639. [mem]
* Ketland, J. (2004). Empirical adequacy and ramsification. *BJPS* 55(2):287–300. [mem]

**Incompleteness, computability, limit learning**
* Gödel, K. (1930). Die Vollständigkeit der Axiome des logischen Funktionenkalküls. *Monatshefte* 37:349–360. [std]
* Gödel, K. (1931). Über formal unentscheidbare Sätze … I. *Monatshefte* 38:173–198. [std]
* Rosser, J. B. (1936). Extensions of some theorems of Gödel and Church. *JSL* 1(3):87–91. [std]
* Church, A. (1936). A note on the Entscheidungsproblem. *JSL* 1:40–41. [std]
* Henkin, L. (1949). The completeness of the first-order functional calculus. *JSL* 14:159–166. [std]
* Hilbert, D. & Bernays, P. (1939). *Grundlagen der Mathematik II*. Springer. [std]
* Kleene, S. C. (1952). *Introduction to Metamathematics*. North-Holland. [std]
* Tarski, A., Mostowski, A. & Robinson, R. M. (1953). *Undecidable Theories*. North-Holland. [std]
* Löb, M. H. (1955). Solution of a problem of Leon Henkin. *JSL* 20(2):115–118. [std]
* Mostowski, A. (1961). A generalization of the incompleteness theorem. *Fund. Math.* 49:205–232. [mem]
* Pour-El, M. B. & Kripke, S. (1967). Deduction-preserving "recursive isomorphisms" between theories. *Fund. Math.* 61:141–163. [mem]
* Jockusch, C. & Soare, R. (1972). Π⁰₁ classes and degrees of theories. *Trans. AMS* 173:33–56. [mem]
* Solovay, R. (1976). Provability interpretations of modal logic. *Israel J. Math.* 25:287–304. [std]
* Boolos, G. (1976). On deciding the truth of certain statements involving the notion of consistency. *JSL* 41:779–781. [mem]
* Smoryński, C. (1977). The incompleteness theorems. In Barwise (ed.), *Handbook of Mathematical Logic*, 821–865. [mem]
* Lindström, P. (1997). *Aspects of Incompleteness*. Lecture Notes in Logic 10. [mem]
* Shoenfield, J. R. (1959). On degrees of unsolvability. *Annals of Math.* 69(3):644–653. [mem]
* Gold, E. M. (1965). Limiting recursion. *JSL* 30(1):28–48. [std]
* Putnam, H. (1965). Trial and error predicates and the solution to a problem of Mostowski. *JSL* 30(1):49–57. [std]
* Ershov, Yu. L. (1968). On a hierarchy of sets I. *Algebra i Logika* 7. [mem]
* Jeroslow, R. G. (1975). Experimental logics and Δ⁰₂ theories. *JPL* 4(3):253–267. [mem]
* Hájek, P. (1977). Experimental logics and Π⁰₃ theories. *JSL* 42(4):515–522. [mem]
* Kelly, K. T. (1996). *The Logic of Reliable Inquiry*. OUP. [std]
* Martin, E. & Osherson, D. (1998). *Elements of Scientific Inquiry*. MIT Press. [mem]
* Gaifman, H. (1964). Concerning measures in first order calculi. *Israel J. Math.* 2:1–18. [mem]
* Garrabrant, S., Benson-Tilsen, T., Critch, A., Soares, N. & Taylor, J. (2016). Logical induction. arXiv:1609.03543. [std]
* Wilkie, A. (1996). Model completeness results for expansions of the ordered field of real numbers by restricted Pfaffian functions and the exponential function. *JAMS* 9:1051–1094. [mem]
* Macintyre, A. & Wilkie, A. (1996). On the decidability of the real exponential field. In *Kreiseliana*, A K Peters. [mem]
* Stirling, C. (2009). Decidability of higher-order matching. *LMCS* 5(3). [mem]
* Huet, G. (1973). The undecidability of unification in third order logic. *Information and Control* 22:257–267. [mem]
* Goldfarb, W. (1981). The undecidability of the second-order unification problem. *TCS* 13:225–230. [mem]
* Miller, D. (1991). A logic programming language with lambda-abstraction, function variables, and simple unification. *J. Logic Comput.* 1(4):497–536. [mem]
* Baxter, L. D. (1977). *The Complexity of Unification*. PhD thesis, Waterloo. [mem; NP-completeness attribution unverified]

**Reflection, progressions, implicit commitment, truth**
* Turing, A. M. (1939). Systems of logic based on ordinals. *Proc. LMS* (2) 45:161–228. [std]
* Feferman, S. (1962). Transfinite recursive progressions of axiomatic theories. *JSL* 27(3):259–316. [std]
* Feferman, S. & Spector, C. (1962). Incompleteness along paths in progressions of theories. *JSL* 27(4):383–390. [mem]
* Feferman, S. (1964). Systems of predicative analysis. *JSL* 29(1):1–30. [mem]
* Schütte, K. (1965). Predicative well-orderings. In *Formal Systems and Recursive Functions*, North-Holland. [mem]
* Kreisel, G. & Lévy, A. (1968). Reflection principles and their use for establishing the complexity of axiomatic systems. *Z. Math. Logik Grundlagen Math.* 14:97–142. [mem]
* Kreisel, G. (1970). Principles of proof and ordinals implicit in given concepts. In Kino, Myhill & Vesley (eds.), *Intuitionism and Proof Theory*, 489–516. [mem]
* Leivant, D. (1983). The optimality of induction as an axiomatization of arithmetic. *JSL* 48(1):182–184. [mem]
* Feferman, S. (1991). Reflecting on incompleteness. *JSL* 56(1):1–49. [mem]
* Feferman, S. & Strahm, T. (2000). The unfolding of non-finitist arithmetic. *APAL* 104:75–96. [mem]
* Beklemishev, L. D. (2005). Reflection principles and provability algebras in formal arithmetic. *Russian Math. Surveys* 60(2):197–268. [mem]
* Franzén, T. (2004). Transfinite progressions: a second look at completeness. *BSL* 10(3):367–389. [mem]
* Dean, W. (2015). Arithmetical reflection and the provability of soundness. *Phil. Math.* 23(1):31–64. [mem]
* Nicolai, C. & Piazza, M. (2019). The implicit commitment of arithmetical theories and its semantic core. *Erkenntnis* 84:913–937. [mem]
* Łełyk, M. & Nicolai, C. (2022). A theory of implicit commitment. *Synthese* 200. [mem]
* Cieśliński, C. (2017). *The Epistemic Lightness of Truth*. CUP. [mem]
* Horsten, L. & Leigh, G. (2017). Truth is simple. *Mind* 126(501):195–232. [mem]
* Fischer, M., Horsten, L. & Nicolai, C. (2021). Hypatia's silence: truth, justification, and entitlement. *Noûs* 55(1):62–85. [mem]
* Shapiro, S. (1998). Proof and truth: through thick and thin. *J. Phil.* 95(10):493–521. [mem]
* Ketland, J. (1999). Deflationism and Tarski's paradise. *Mind* 108:69–94. [mem]
* Kotlarski, H., Krajewski, S. & Lachlan, A. (1981). Construction of satisfaction classes for nonstandard models. *Canad. Math. Bull.* 24(3):283–293. [mem]
* Enayat, A. & Visser, A. (2015). New constructions of satisfaction classes. In *Unifying the Philosophy of Truth*, Springer. [mem]
* Leigh, G. (2015). Conservativity for theories of compositional truth via cut elimination. *JSL* 80(3):845–865. [mem]
* Artemov, S. (2019). The provability of consistency. arXiv. [mem]
* McGee, V. (1997). How we learn mathematical language. *Phil. Review* 106(1):35–68. [mem]
* Parsons, C. (1990). The uniqueness of the natural numbers. *Iyyun* 39:13–44. [mem]
* Button, T. & Walsh, S. (2018). *Philosophy and Model Theory*. OUP. [std]
* Zermelo, E. (1930). Über Grenzzahlen und Mengenbereiche. *Fund. Math.* 16:29–47. [std]
* Putnam, H. (1980). Models and reality. *JSL* 45(3):464–482. [std]

**Informal rigour and squeezing**
* Kreisel, G. (1967). Informal rigour and completeness proofs. In Lakatos (ed.), *Problems in the Philosophy of Mathematics*, North-Holland, 138–186. [pages unverified]
* Smith, P. (2011). Squeezing arguments. *Analysis* 71(1):22–30. [mem]
* Field, H. (1991). Metalogic and modality. *Phil. Studies* 62:1–22. [mem]
* Field, H. (2008). *Saving Truth from Paradox*. OUP. [std]
* Andrade-Lotero, E. & Dutilh Novaes, C. (2012). Validity, the squeezing argument and alternative semantic systems: the case of Aristotelian syllogistic. *JPL* 41(2):387–418. [mem]
* Halbach, V. (2020). The substitutional analysis of logical consequence. *Noûs* 54(2):431–450. [mem; relevance to squeezing unverified]
* Dean, W. & Kurokawa, H. On the methodology of informal rigour. In Horsten & Welch (eds.), *Gödel's Disjunction*, OUP 2016. [unverified]
