# L1 — Learning rule systems from positive data: what carries over to learning inference rules

*Literature memo for the inferential-learning project. Strand L1: Gold/Angluin-style identification from positive data, finite elasticity, elementary formal systems, Plotkin's least general generalisation (lgg), the ILP settings (including learning from proofs), positive-only PAC learning and the closure algorithm, teaching dimension, Horn closure systems, and learning with a simplicity bias.*

**Verification legend.** The web-search budget for the session ran out partway through this memo, and most publisher and arXiv pages were blocked to direct fetching. So:
- **[✓]** means the bibliographic facts, and where stated the result, were checked online this session.
- **[mem]** means a standard reference that I am confident of but did not re-check this session. Treat it as unverified for anything load-bearing.
- **[unverified]** means I am less sure of the details.
- **(ours)** marks statements and proofs I worked out for this memo. They are not claims about the literature.

---

## 0. Bottom line

1. **Learning valid steps is much easier than learning theorems.** If the hypothesis class is "at most $k$ rule schemas, each a tuple of tree patterns (first-order terms)", then the set of valid single steps belongs to a class with **finite thickness per schema**, and hence **finite elasticity for $\le k$ schemas**. Wright's theorem then gives identification in the limit from positive data. Gold's obstruction (superfinite classes) bites only if the number of schemas is unbounded. By contrast, learning the **theorem set** of a $k$-rule Hilbert calculus is hopeless in general. It becomes possible essentially when each theorem has only finitely many normal derivations, as in Shinohara's length-bounded EFS and, I conjecture, analytic cut-free calculi (§8.4). Kanazawa's finite-valued-relation theorem is the right transfer tool here.
2. **Soundness at every time is a strictly stronger requirement than identification.** Call a learner sound if every conjecture is a subset of the target. Two facts (ours, §9 T1) are easy to prove:
   - The **cautious learner** $A_\mathcal C(D)=\bigcap\{L\in\mathcal C: D\subseteq L\}$ (version-space intersection) is the **pointwise-maximal sound learner**.
   - A class can be soundly identified iff every member $L$ has a finite $S\subseteq L$ such that every class member containing $S$ contains $L$.
   
   This is (up to effectivity) the tell-tale condition Lange–Zeugmann use to characterise **strong-monotonic** learning [mem]. Finite elasticity implies it. Plain Gold-identifiability does not (§9, separating example).
3. **For intersection-closed classes, the cautious learner is the closure algorithm, and for single schemas it is anti-unification (Plotkin's lgg).** Its soundness is **deterministic and distribution-free**: no adaptive prover can exploit it. PAC theory (Natarajan; Auer–Ortner; Darnstädt) then bounds only the *completeness* error on the human distribution. This sharpens H1: in the realisable, intersection-closed case, worst-case soundness costs nothing.
4. **Unions of schemas are not intersection-closed.** "Minimal generalisation" learners (the $k$-minimal multiple generalisations of Arimura–Shinohara–Otsuki) **can be unsound**; I give an explicit counterexample in §9 T2. The sound choice is the intersection over **all** $\le k$-block partitions of the data of the union of the blocks' lggs. It is computable, exponential in $|D|$, and converges by finite elasticity.
5. **Structural (substitution-invariant) consequence relations do form an algebraic closure system** (all their defining conditions are Horn conditions). So the "take the observed sequents as rules" learner is sound and monotone, and it identifies every finitely based target behaviourally correctly. But **structurality only generalises along schematic variables that are already present in the data**. On ground (concrete) human steps it generalises nothing. Real generalisation needs anti-unification, and anti-unification is sound only for $k=1$ or inside the cautious learner.
6. **Theorems determine a consequence relation only up to an interval** $[\vdash^{\min}_T,\vdash^{\mathrm{adm}}_T]$, whose upper end is the *admissible-rule* relation (the structural completion). Learning from categorical theorems therefore cannot separate rules that are valid under hypotheses from rules that only preserve theoremhood. This is a precise, formal version of the user's "contexts" worry. The interval **collapses under a deduction theorem**: the conditional makes inferential commitments explicit, in Brandom's phrase, so assertions carry the information that inferences do (§8.3).
7. **The main practical threats are not Gold's theorem.** They are:
   - label noise: a single invalid human step, put through lgg, can turn into a tonk-like schema (§9 T6 gives a bounded-noise robust version);
   - misspecification: side conditions, binders, context variables and implicit premises;
   - an unknown number of schemas, which forces a prior or MDL and so makes soundness only probabilistic;
   - completeness rates: tree-pattern classes have infinite VC dimension, so there is no distribution-free completeness rate (§9 T3).
8. **Two dualities organise everything** (§4.4, §8):
   - Positive examples of *valid inferences* give sound lower bounds.
   - Positive examples of *models* (world observations, learning from interpretations) give upper bounds that are complete but may be unsound.
   - The target is sandwiched between the two. Formal concept analysis's "attribute exploration" is an existing algorithm that alternates between the bounds.

---

## 1. Frame and dictionary

**Steps and schemas.** Formulas are first-order terms over a signature $\Sigma$ with variables. A *step* is a tuple $(\varphi_1,\dots,\varphi_n\Rightarrow\psi)$, encoded as one term $\mathsf{rule}_n(\varphi_1,\dots,\varphi_n,\psi)$. A *rule schema* $r$ is such a term with schematic variables. $\mathrm{Inst}(r)=\{r\theta\}$ is its set of instances. A rule system $R$ is a finite set of schemas, and its set of valid single steps is $V(R)=\bigcup_{r\in R}\mathrm{Inst}(r)$. Derivations are trees whose local steps lie in $V(R)$. They give $\vdash_R$ and the theorem set $\mathrm{Thm}(R)$.

**Data regimes.**

| Regime | Data |
|---|---|
| D1 | step text: positive steps from $V(R^\*)$, as an enumeration or as i.i.d. draws |
| D2 | macro-steps: human steps lying in $\vdash^{\le g}_{R^\*}$, i.e. derivable in at most $g$ primitive steps |
| D3 | theorems only |
| D4 | models or interpretations: "world feedback" |
| D5 | coherence signals: finite sets of accepted steps that jointly derive $\bot$ in the actual context (negative bags) |

**Soundness.** A learner $M$ is *sound on* $\mathcal C$ if $M(\sigma)\subseteq L$ for every finite data sequence $\sigma$ and every $L\in\mathcal C$ with $\mathrm{content}(\sigma)\subseteq L$. This is the notion H1 needs. If $\hat V_t\subseteq V^\*$, then *every* $\hat V_t$-derivation is a $V^\*$-derivation, however adversarially the prover searches. Identification in the limit (EX) asks that the conjectured *index* converge to a correct one. Behaviourally correct identification (BC) asks only that the *denotation* $\hat V_t$ eventually equal $V^\*$.

---

## 2. The Gold paradigm: results we can reuse

### 2.1 Gold (1967)
Gold, "Language identification in the limit", *Information and Control* 10(5):447–474 [mem].
- **Theorem (text).** No class containing all finite languages and at least one infinite language (a *superfinite* class) is identifiable in the limit from positive presentations.
- **Informant.** With complete positive and negative information, every class of primitive recursive languages is identifiable.

*Mapping.* Suppose the number of schemas is unbounded, and ground schemas are allowed. Then every finite set of ground steps is a hypothesis ($k=|D|$ ground schemas), as is at least one infinite schema language. That class is superfinite. So **some bound on the number of schemas, or a prior over it, is unavoidable**. Coherence and world feedback supply only *partial* informant data, which is why it matters exactly which negative information we get (§2.6).

### 2.2 Angluin (1980): tell-tales, finite thickness, pattern languages
Angluin, "Inductive inference of formal languages from positive data", *Information and Control* 45(2):117–135 [mem].

**Theorem (Condition 1).** An indexed family of nonempty, uniformly recursive languages $L_1,L_2,\dots$ is identifiable from text iff there is a procedure that, on input $i$, uniformly enumerates a finite set $T_i$ (the *tell-tale*) such that:
- $T_i\subseteq L_i$;
- for all $j$, if $T_i\subseteq L_j$ then $L_j\not\subsetneq L_i$.

**Other results in the same line.**
- If tell-tales merely exist (non-effectively, "Condition 2"), the indexed family is **BC**-identifiable. This characterisation is attributed in later work (Baliga–Case–Jain, "The synthesis of language learners", *Information and Computation* 1999) [✓ via secondary snippet; exact statement unverified].
- *Finite thickness* (every string lies in finitely many languages of the class) is sufficient.
- Pattern languages: Angluin, "Finding patterns common to a set of strings", *JCSS* 21(1):46–62 (1980) [mem]. For a pattern $p$ over constants and variables, $L(p)$ is the set of non-erasing substitution instances. The class has finite thickness, so it is identifiable via *descriptive patterns*. Membership is NP-complete, but there is a polynomial-time algorithm for one-variable patterns.

*Mapping.* A tell-tale is a finite positive "curriculum" that rules out every hypothesis strictly inside the target. For an intersection-closed class (closure system), **$L$ has a tell-tale iff $L=\mathrm{cl}(F)$ for some finite $F$** (ours, one line). If $T$ is a tell-tale, then $\mathrm{cl}(T)\subseteq L$, and $\mathrm{cl}(T)$ is a class member containing $T$, so it cannot be a proper subset of $L$; hence $\mathrm{cl}(T)=L$. The converse is immediate. So for closure systems, identifiability from positive data is exactly *finite generation*.

### 2.3 Finite elasticity (Wright 1989; Motoki–Shinohara–Wright 1991) and Kanazawa's transfer theorem
Wright, "Identification of unions of languages drawn from an identifiable class", COLT 1989, pp. 328–333 [✓]. Motoki, Shinohara & Wright, "The correct definition of finite elasticity: corrigendum to identification of unions", COLT 1991 [✓].

**Definition (corrected form).** $\mathcal C$ has *infinite elasticity* if there are strings $w_0,w_1,\dots$ and languages $L_1,L_2,\dots\in\mathcal C$ with $\{w_0,\dots,w_{n-1}\}\subseteq L_n$ and $w_n\notin L_n$ for all $n\ge1$. Otherwise $\mathcal C$ has *finite elasticity*.

**Facts.**
- (a) Finite elasticity plus uniformly decidable membership implies identifiability from text (Wright).
- (b) Finite elasticity is preserved under pairwise unions $\{L\cup L'\}$, hence under $\le k$-fold unions (Wright, as corrected), and also under intersections [mem].
- (c) Finite thickness implies finite elasticity (ours, quick proof). In an elasticity witness, every $L_n$ with $n\ge 1$ contains $w_0$. If $L_n=L_m=L$ with $n<m$, then $w_n\in L_m=L=L_n\not\ni w_n$, a contradiction. So the $L_n$ are pairwise distinct and all contain $w_0$, which contradicts finite thickness.
- (d) **Kanazawa's finite-valued relation theorem.** Kanazawa, *Learnable Classes of Categorial Grammars*, CSLI 1998 [✓ existence and use; exact wording mem]. Let $\mathcal M$ over alphabet $\Upsilon$ have finite elasticity, and let $R\subseteq\Sigma^\*\times\Upsilon^\*$ be finite-valued (each $s$ is related to finitely many $u$). Then $\{R^{-1}[M]:M\in\mathcal M\}$ has finite elasticity.

*Mapping.* (d) is exactly the bridge between learning from derivations and learning from theorems. Take $R=\{(\varphi,\tau):\tau$ is a normal derivation with root $\varphi\}$. It is finite-valued iff every theorem has finitely many normal derivations (§8.4).

**Lemma (ours, used repeatedly).** If $\mathcal C$ has finite elasticity, then on every text of a target $T\in\mathcal C$ there is a time after which **every** $H\in\mathcal C$ consistent with the data contains $T$.

*Proof.* Suppose instead that there are infinitely many "bad" times, at each of which some consistent $H\not\supseteq T$ exists. Let $w_0$ be any text element. Inductively, choose a bad time after $w_0,\dots,w_{n-1}$ have all appeared, let $L_n$ be a bad consistent $H$ at that time, and pick $w_n\in T\setminus L_n$. Then $\{w_0..w_{n-1}\}\subseteq L_n\not\ni w_n$, which is infinite elasticity. ∎

### 2.4 Monotonic and "never overgeneralise" learning
- Lange & Zeugmann, "Types of monotonic language learning and their characterization", COLT 1992 [✓ title/existence]. Zeugmann, Lange & Kapur, "Characterizations of monotonic and dual monotonic language learning", *Information and Computation* 120 (1995) [mem]. Lange, Zeugmann & Zilles, "Learning indexed families of recursive languages from positive data: a survey", *TCS* 397:194–232 (2008) [✓].
  - *Strong-monotonic* learning requires $L(h_t)\subseteq L(h_{t+1})$. Combined with convergence, this means every conjecture is a subset of the target.
  - My recollection of the Lange–Zeugmann characterisation, for class-comprising hypothesis spaces: there exist recursively generable finite $T_j\subseteq L_j$ such that $T_j\subseteq L_k\Rightarrow L_j\subseteq L_k$ [mem; exact form unverified]. Compare Angluin's "$\Rightarrow L_k\not\subsetneq L_j$". This "$\subseteq$-tell-tale" is exactly the soundness condition FG in §9 T1.
- Kapur & Bilardi, "Language learning without overgeneralization", STACS 1992, LNCS 577:245–256; *TCS* 141(1–2):151–162 (1995) [✓]. They characterise conservative-style learning through enumerations of pairs (finite set, grammar) in which the grammar's language is a least upper bound of the set [✓ via secondary snippet]. This is the formal "subset principle" (Berwick 1985 [mem]).

### 2.5 Elementary formal systems (Shinohara; Arikawa–Shinohara–Yamamoto)
EFS (Smullyan 1961, *Theory of Formal Systems* [mem]) are logic programs over strings: definite clauses whose arguments are string patterns. Unrestricted EFS define all r.e. languages.

**Main results.**
- Arikawa, Shinohara & Yamamoto, "Learning elementary formal systems", *TCS* 95(1):97–113 (1992) [mem].
- Shinohara, "Inductive inference of monotonic formal systems from positive data", *New Generation Computing* 8(4):371–384 (1991) [mem].
- Shinohara, "Rich classes inferable from positive data: length-bounded elementary formal systems", *Information and Computation* 108:175–186 (1994) [✓ venue].
- **Theorem:** for each $k$, the class of languages definable by *length-bounded* EFS with at most $k$ clauses has finite elasticity, and so is identifiable from positive data. My recollection of "length-bounded" is $|A\theta|\ge\sum_i|B_i\theta|$ for each clause $A\leftarrow B_1,\dots,B_n$ and every substitution $\theta$ [mem; whether it is the sum or the maximum is unverified]. Shinohara shows these classes are rich: as I recall, length-bounded EFS define exactly the context-sensitive languages [mem].
- Follow-ups:
  - Linearly-moded Prolog programs with bounded numbers of clauses have finite elasticity: Krishna Rao, "Some classes of Prolog programs inferable from positive data", *TCS* 241 (2000) [unverified details].
  - Unbounded unions of pattern languages: Shinohara & Arimura, "Inductive inference of unbounded unions of pattern languages from positive data", *TCS* (2000) [✓ title; authors mem].
  - Characteristic sets and "compactness w.r.t. containment" for unions of regular patterns: Sato, Mukouchi & Zheng, ALT 1998 [✓ title; authors mem].
  - Mind-change complexity of unions of patterns, ALT 2006 (de Brecht–Yamamoto [authors mem]).
  - Bounded unions of *Noetherian closed set systems* via characteristic sets (ICGI 2008 [✓ title; authors unverified]).
  - Learning algebraic closure systems (ideals and subspaces) from text: Stephan & Ventsov, "Learning algebraic structures from text", *TCS* 268 (2001) [mem]. Here Noetherianity, i.e. the Hilbert basis theorem, is exactly finite generation.

*Mapping.* The modus ponens schema $A,\ A\to B\ /\ B$ is **not** length-bounded, since its premises are longer than its conclusion. So Hilbert calculi fall outside Shinohara's theorem when learning from theorems. Cut-free sequent rules are size-non-increasing *per premise*. Context-*splitting* (multiplicative) rules also satisfy the *sum* condition; context-*sharing* (additive) rules do not (§8.4).

### 2.6 Positive data plus some negative information
Jain & Kinber, "Learning languages from positive data and negative counterexamples", *JCSS* 74 (2008) [unverified details]. Whenever a conjecture is not a subset of the target, the learner receives a counterexample, i.e. a specific element of conjecture minus target. This is much stronger than text alone.

*Mapping.* A coherence failure (D5) certifies that the *derivation* contains an invalid step, but does not say which. It is a **negative bag**, strictly weaker than a Jain–Kinber counterexample. World feedback in the form of true/false labels on particular propositions (D4) is weaker still. It refutes a *step* only through a derivation from true premises to a false conclusion.

---

## 3. Rule schemas as tree patterns: Plotkin's lattice

**Classical facts.**
- Plotkin, "A note on inductive generalization", *Machine Intelligence* 5:153–163 (1970). Plotkin, "A further note on inductive generalization", *MI* 6:101–124 (1971). Reynolds, "Transformational systems and the algebraic structure of atomic formulas", *MI* 5:135–151 (1970). [mem]
- Atoms (terms) modulo variable renaming, ordered by instantiation, form a lattice once a top and bottom are added. The meet of two unifiable terms is their mgu instance. The join is the **least general generalisation**, computed by anti-unification. Each pair of disagreeing subterms $(s,t)$ goes to one fresh variable $X_{s,t}$, reused for repeated pairs, which is how variable co-occurrence is captured.
- The set of generalisations of a term is finite up to renaming, since $|s|\le|s\theta|$. So strictly ascending generalisation chains above any term are finite. Descending instance chains can be infinite: $f(x)>f(g(x))>\cdots$.
- For **clauses** under θ-subsumption, lggs exist (Plotkin), but there are infinite ascending and descending chains, reduction is needed, and lgg size can grow multiplicatively ($|\mathrm{lgg}(C,D)|\le|C|\cdot|D|$ literals). See Nienhuys-Cheng & de Wolf, *Foundations of Inductive Logic Programming*, LNAI 1228 (1997) [mem]. Relative lggs (relative to background knowledge) need not exist in general [mem].

**Lemmas for us (ours, routine).**
- (L3.1) Suppose there are infinitely many constants not occurring in $s,t$. Then $\mathrm{Inst}_{\text{ground}}(t)\subseteq\mathrm{Inst}_{\text{ground}}(s)$ iff $t$ is an instance of $s$. *Proof.* Ground $t$ with fresh distinct constants $c_i$ for its variables, match against $s$, and replace the $c_i$ by the variables again. So **language inclusion is subsumption, decidable by matching**.
- (L3.2) $\{\mathrm{Inst}(t)\}\cup\{\emptyset\}$ is closed under intersection: $\mathrm{Inst}(s)\cap\mathrm{Inst}(t)=\mathrm{Inst}(s\mu)$ for the mgu $\mu$ of renamed-apart copies. The smallest member containing a set $D$ is $\mathrm{Inst}(\mathrm{lgg}(D))$, which exists even for infinite $D$ by the finiteness of ascending chains. **Anti-unification is the closure algorithm for single schemas.**
- (L3.3) Each ground step lies in finitely many single-schema languages, which is finite thickness. With (c) of §2.3, the class of $\le k$-schema step sets therefore has finite elasticity.

**Extensions that matter for real proofs.**
- *Side conditions (guards).* Use schemas $(t,g)$ with $\mathrm{Inst}(t,g)=\{t\theta: g\theta\}$, where $g$ ranges over a finite menu $G$ of decidable guards ("$x\notin FV(\Gamma)$", type or dimension checks) that is closed under conjunction and stable under substitution. The class remains intersection-closed, and the closure is lgg plus the strongest guard satisfied by all the data (ours).
- *Binders.* For higher-order *patterns* (Miller's fragment), the lgg exists and is unique (Pfenning, "Unification and anti-unification in the calculus of constructions", LICS 1991 [mem]) and is computable in linear time (Baumgartner, Kutsia, Levy & Villaret, *J. Automated Reasoning* 58 (2017) [mem]). Rules in a logical framework such as LF or Isabelle are such patterns, so ∀-introduction with eigenvariables fits.
- *Context and sequence variables* ($\Gamma\vdash\ldots$). Anti-unification modulo associativity, AC or ACU is *finitary or worse* rather than unitary. Some unital theories are *nullary*. See Cerna & Kutsia, "Anti-unification and generalization: a survey", IJCAI 2023 [mem]; also the unital anti-unification paper (FSCD 2020 [unverified]). So sequent calculi with context variables lose the unique lgg.
- *String patterns vs tree patterns.*
  - For *string* pattern languages, inclusion is **undecidable**: Jiang, Salomaa, Salomaa & Yu, "Decision problems for patterns", *JCSS* 50 (1995); Freydenberger & Reidenbach, "Bad news on decision problems for patterns", *Information and Computation* 208 (2010) [mem].
  - Descriptive patterns are not unique, and computing them is hard.
  - *Erasing* pattern languages are not learnable from text over small alphabets (Reidenbach, *TCS* 2006 and 2008 [unverified details]).
  - **Hence:** rules over *unparsed strings*, which is informal text with no parse structure, behave like string patterns: undecidable inclusion and no lattice. Rules over *parsed* expressions are tree patterns with a lattice, matching-decidable inclusion and finite thickness. This is a precise, if partial, formal sense in which *inventing a formal language*, i.e. parsing proofs into trees, is what makes learning rules tractable. It supports H5.

---

## 4. Intersection-closed classes, the closure algorithm, positive-only PAC learning, teaching

### 4.1 Positive-only PAC learning
- Valiant, "A theory of the learnable", *CACM* 27(11):1134–1142 (1984) [mem]: $k$-CNF is learnable from positive examples alone by elimination, which is the closure algorithm for an intersection-closed class.
- Natarajan, "On learning Boolean functions", STOC 1987 (CMU-RI-TR-86-17) [✓]. He develops a dimension notion and the most general class of families learnable from polynomially many positive examples **with one-sided error**. Intersection-closure is *sufficient* for proper positive-only learning with no false positives. His conjecture that it is also necessary was later refuted [✓ via secondary source; the refuting paper was not identified].
- Helmbold, Sloan & Warmuth, "Learning nested differences of intersection-closed concept classes", *Machine Learning* 5:165–196 (1990) [mem]. The closure algorithm and its use as a subroutine.
- Auer & Ortner, "A new PAC bound for intersection-closed concept classes", *Machine Learning* 66:151–163 (2007) [✓]. For the closure algorithm, error $\le\varepsilon$ with $O\big(\tfrac1\varepsilon(d\log d+\log\tfrac1\delta)\big)$ samples, where $d$ is the VC dimension. The optimal $O(\tfrac1\varepsilon(d+\log\tfrac1\delta))$ holds under an extra combinatorial condition, which covers maximum intersection-closed classes.
- Darnstädt, "The optimal PAC bound for intersection-closed concept classes", *Information Processing Letters* 115(4):458–461 (2015) [✓ venue]. It settles Auer–Ortner's question: intersection-closed classes are learnable with $O(\tfrac1\varepsilon(d+\log\tfrac1\delta))$ samples [✓ abstract; that the bound is achieved by the closure algorithm itself is my recollection, mem]. (The brief's "Darnstädt–Simon–Szörényi 2016" is probably a conflation. Darnstädt, Simon & Szörényi wrote "Supervised learning and co-training", *TCS* 2014 [mem], which uses the closure algorithm in co-training.)
- Ben-David, Mansouri, Mehrotra & Zampetakis, "Surprises in proper positive-only learning", arXiv:2606.28309 (2026) [✓ abstract]. The learner sees i.i.d. samples from the positive region and is evaluated under the full distribution. **A class is properly positive-only learnable iff it has finite VC dimension and "uniform exterior separability"**. Proper and improper learning separate, as do randomised and deterministic proper learning. Some classes have no ERM learner. Finite VC dimension is not enough even for non-uniform learning.

*Mapping.* The closure algorithm's hypothesis is a subset of the target **always**, on every sample and for every distribution. **Soundness is certain. PAC concerns only the false-rejection (incompleteness) rate on the human-step distribution.** This is exactly the decoupling H1 wants: worst-case soundness against the prover, average-case completeness against human practice. El-Yaniv–Wiener's consistent selective strategy, KWIK's "⊥ unless all consistent hypotheses agree", and the closure algorithm *coincide* for a realisable intersection-closed class with positive data. Points in $\mathrm{cl}(D)$ are accepted. Points outside it are abstained on, or rejected where every consistent hypothesis rejects. Nothing is falsely accepted.

### 4.2 Teaching
- Goldman & Kearns, "On the complexity of teaching", *JCSS* 50:20–31 (1995) [mem].
- Shinohara & Miyano, "Teachability in computational learning", *New Generation Computing* 8 (1991) [mem].
- Zilles, Lange, Holte & Zinkevich, "Models of cooperative teaching and learning", *JMLR* 12:349–384 (2011), introducing recursive teaching dimension (RTD) [mem].
- Doliwa, Fan, Simon & Zilles, "Recursive teaching dimension, VC-dimension and sample compression", *JMLR* 15:3107–3131 (2014) [mem].
- Kuhlmann, "On teaching and learning intersection-closed concept classes", EuroCOLT 1999 [mem]. For intersection-closed classes, positive teaching sets are *spanning sets*, and $\mathrm{RTD}\le I(\mathcal C)$, the largest minimal spanning set.

**Lemma (ours, short).** A minimal spanning set $S$ of a concept in an intersection-closed class is shattered, so $|S|\le\mathrm{VCdim}$.

*Proof.* Let $S'\subseteq S$ and $x\in S\setminus S'$. If $x\in\mathrm{cl}(S')\subseteq\mathrm{cl}(S\setminus\{x\})$, then $\mathrm{cl}(S\setminus\{x\})=\mathrm{cl}(S)$, which contradicts minimality. So $\mathrm{cl}(S')\cap S=S'$. ∎

**Teaching a schema (ours).** With fresh constants available, a single schema with $v$ variables is taught by **2** instances: substitute two disjoint sets of fresh distinct constants, and anti-unification recovers the schema up to renaming. Over a binary constant alphabet, $m$ instances suffice iff $2^m-2\ge v$. The variables' "columns" must be distinct and non-constant, since a constant column is anti-unified to a constant. Textbook proofs are, in this sense, teaching sets. *Cooperative* data (good textbooks) and *random* data (corpora) have very different sample complexities. For random data, "stochastic finite learning" of pattern languages (Rossmanith & Zeugmann, *Machine Learning* 44:67–91 (2001) [mem]) is the right model: under product distributions on substitutions, with high confidence, the learner outputs the correct pattern and stops.

### 4.3 Horn theories are rule systems that form closure systems
A propositional Horn clause $a_1\wedge\dots\wedge a_n\to b$ *is* an inference rule. A Horn theory is a closure operator (forward chaining). Its models are closed under intersection (McKinsey 1943; Horn 1951 [mem]).
- Angluin, Frazier & Pitt, "Learning conjunctions of Horn clauses", *Machine Learning* 9:147–164 (1992) [mem]: exact learning with membership and equivalence queries in polynomial time. Arias & Balcázar, *Machine Learning* 85 (2011) [mem]: the AFP algorithm outputs the Guigues–Duquenne canonical basis.
- Frazier & Pitt, "Learning from entailment: an application to propositional Horn sentences", ICML 1993, pp. 120–127 [mem]. Examples are *clauses* labelled entailed or not entailed, which is precisely "is this inference valid?". Horn sentences are polynomially learnable with entailment and equivalence queries. A proof-assistant kernel is an entailment oracle, which is why *formal* math is the easy case.
- From **models**: Dechter & Pearl, "Structure identification in relational data", *AI* 58:237–270 (1992); Kautz, Kearns & Selman, "Horn approximations of empirical data", *AI* 74:129–145 (1995) [mem]. The *Horn envelope* of the observed models is the theory of their intersection closure. Its implications hold in every observed model, but it may contain implications false in unobserved target models. **It is complete but unsound.**
- Formal concept analysis: Guigues & Duquenne 1986, the canonical implication basis; Ganter & Wille, *Formal Concept Analysis* (1999); Ganter & Obiedkov, *Conceptual Exploration* (2016) [mem]. *Attribute exploration* proposes the next implication of the canonical basis that is consistent with the examples so far. The expert either accepts it, so it becomes a valid rule, or supplies a counterexample object, i.e. a model. It terminates with the exact implication theory.

### 4.4 The sandwich (our synthesis)
For a target consequence relation $\vdash^\*=\models_{\mathbb K}$:
- positive valid steps give $L_t=\mathrm{cl}(D_t)\subseteq\vdash^\*$, which is sound;
- observed models $M_1,\dots,M_t\in\mathbb K$ give $U_t=\models_{\{M_1..M_t\}}\supseteq\vdash^\*$, which is complete.

Accept steps in $L_t$, reject steps outside $U_t$, and treat the gap as the zone of ignorance. Attribute exploration is an active-learning algorithm that closes the gap. *In the user's terms, human proofs supply $L_t$, the world supplies $U_t$, and coherence (D5) is a third source that shrinks $U_t$ without supplying models.* This is the L1 version of H3 and H4: inference data bound meaning from below, and models bound it from above.

---

## 5. ILP settings, including learning from proofs

- Muggleton, "Inductive logic programming", *New Generation Computing* 8(4):295–318 (1991). Muggleton & De Raedt, "Inductive logic programming: theory and methods", *J. Logic Programming* 19/20:629–679 (1994). [mem]
- De Raedt, "Logical settings for concept-learning", *AI* 95(1):187–201 (1997) [mem]. It distinguishes **learning from entailment** (examples are clauses or facts that the hypothesis must entail), **learning from interpretations** (examples are models), and learning from satisfiability, and relates them by reductions. First-order jk-clausal theories are PAC-learnable from interpretations (De Raedt & Džeroski, *AI* 70:375–392 (1994) [mem]). Learning recursive programs from entailment faces cryptographic hardness (Cohen, "PAC-learning recursive logic programs: negative results", *JAIR* 2:541–573 (1995) [mem]).
- De Raedt, *Logical and Relational Learning*, Springer (2008) [mem]. It adds **learning from proofs** and **learning from traces**. In learning from proofs, an example is a proof tree, and $H$ covers it iff every node is an instance of a clause of $H$. This is the most informative setting, analogous to treebank grammar learning. Shapiro's Model Inference System (*Algorithmic Program Debugging*, MIT Press 1983 [mem]) learns from queries and traces.
- De Raedt, Kersting & Torge, "Towards learning stochastic logic programs from proof-banks", AAAI 2005 [mem; pages unverified]. It learns SLP structure and parameters from proof trees, by analogy with PCFG learning from treebanks. This is the closest existing ILP work to our D1 regime.
- Passerini, Frasconi & De Raedt, "Kernels on Prolog proof trees: statistical learning in the ILP setting", *JMLR* 7:307–342 (2006) [mem]. **Note:** this uses proof trees of a fixed background "visitor" program as structured *features* for kernel classifiers. It is not a method for learning inference rules. Cite it accordingly.
- **Explanation-based generalisation (EBG).**
  - Mitchell, Keller & Kedar-Cabelli, *Machine Learning* 1:47–80 (1986).
  - DeJong & Mooney, *Machine Learning* 1:145–176 (1986).
  - van Harmelen & Bundy, "Explanation-based generalisation = partial evaluation", *AI* 36 (1988).
  
  [mem] Given primitive rules, EBG regresses a proof to its **most general derived rule**, its skeleton composed by unification. It is *deductive* and therefore **sound**. This is how macro-steps (D2) should be handled: learn primitive schemas inductively under soundness constraints, and form derived rules deductively.
- Muggleton, "Learning from positive data", ILP-96, LNAI 1314:358–376 (1997) [mem]. Positive-only learning with a Bayesian posterior $\propto P(H)\,g(H)^{-m}$, where $g$ is the hypothesis's "generality" or probability mass: the size principle. Compare Tenenbaum & Griffiths, *BBS* 24:629–640 (2001) [mem].

---

## 6. Categorial grammars: learning lexical meanings from proof structures

- Buszkowski & Penn, "Categorial grammars determined from linguistic data by unification", *Studia Logica* 49:431–454 (1990) [mem]. Their **RG algorithm** learns rigid AB grammars from *functor–argument structures*: put variables at the leaves, propagate through the structure, and unify.
- Kanazawa (1998) [✓]:
  - the classes of $k$-valued grammars ($k=1,2,\dots$) are learnable **from structures and from strings**;
  - least-valued and least-cardinality grammars are learnable from structures;
  - the proofs go through finite elasticity and the finite-valued relation theorem.
- For Lambek grammars (AB plus *hypothetical reasoning*, the introduction rules), rigid grammars are **not** learnable from strings because limit points appear (Foret & Le Nir, COLING 2002 [unverified]). They remain learnable from suitable structures (Bonato & Retoré 2001 [unverified]; see also arXiv cs/0608033, "A study on learnability for rigid Lambek grammars" [✓ existence]).

*Mapping.* An AB/Lambek derivation *is* a proof, and a word's category *is* its inferential role, a compositional and type-theoretic meaning. So "learning rigid grammars from structures" is literally **learning the inferential roles of words from proof skeletons**. Two lessons follow:
1. Learning from proof *structures* is robustly easier than learning from yields.
2. Adding hypothetical reasoning (discharge) can destroy learnability from yields while leaving learnability from structures intact.

Both bear on D1 versus D3 and on contexts.

Distributional learning also fits the substitution-based inferentialism of Brandom (*Making It Explicit*, 1994, ch. 6 [mem]). Clark & Eyraud, "Polynomial identification in the limit of substitutable context-free languages", *JMLR* 8:1725–1745 (2007) [mem], learn languages in which sharing one context implies sharing all contexts, in polynomial time from positive data. This is a formal cousin of identifying meanings by intersubstitutability.

---

## 7. Simplicity, Bayes and MDL with positive data

- Horning, *A Study of Grammatical Inference*, PhD thesis, Stanford (1969) [mem]: Bayesian identification of stochastic grammars from positive samples.
- Angluin, "Identifying languages from stochastic examples", Yale TR-614 (1988) [mem]. For arbitrary sampling distributions, stochastic text does not enlarge what can be identified with probability 1. Distributional restrictions are what help [unverified exact form].
- Kapur & Bilardi, "Language learning from stochastic input", COLT 1992 [✓ existence]. Pitt, "Probabilistic inductive inference", *JACM* 36:383–433 (1989) [mem].
- Chater & Vitányi, "'Ideal learning' of natural language: positive results about learning from positive evidence", *J. Math. Psych.* 51(3):135–163 (2007). Hsu, Chater & Vitányi, *Cognition* 120 (2011). [mem] They apply Solomonoff's bound: the total expected prediction error of a universal predictor on a computable source $\mu$ is $O(K(\mu))$. They conclude that an ideal learner converges in *prediction* from positive evidence alone, and they bound expected over- and under-generalisation in grammaticality judgements [mem; exact theorem form unverified].

*Mapping and caveats.*
1. These results are **in expectation or frequency under the generating distribution**. An ideal learner can keep a small positive probability on an invalid step forever, and an adversarial prover will find it. So H1's concern stands for the Bayesian route.
2. A Solomonoff predictor of *human steps* learns **what humans write**, errors included, not **what is valid**. The size principle penalises over-general hypotheses only under *strong sampling*, meaning steps drawn in proportion to a hypothesis-dependent distribution. Human step choice is goal-directed, which is closer to weak sampling.
3. Kanazawa's least-cardinality results and Muggleton's posterior are the honest "unbounded $k$" options. Soundness then becomes probabilistic, posterior-conservative acceptance as in H1, and needs Ville-style arguments for time-uniformity.

---

## 8. Steps versus theorems: the central analysis (ours, with literature anchors)

### 8.1 Structural consequence relations form an algebraic closure system
Łoś & Suszko, "Remarks on sentential logics", *Indag. Math.* 20:177–183 (1958); Wójcicki, *Theory of Logical Calculi*, Kluwer (1988) [mem]. Write a finitary structural consequence relation as $\vdash\subseteq\mathcal P_{\rm fin}(Fm)\times Fm$.

**Proposition 8.1.** The structural consequence relations are closed under arbitrary intersection, and the closure operator is algebraic. Its value on $D$ is the relation axiomatised by $D$, read as rules. All the conditions (reflexivity, monotonicity, finite cut, closure under each substitution $\sigma$) are universal Horn conditions with finitely many premises.

**Corollary 8.2.** The learner $D_t\mapsto\vdash_{D_t}$ has three properties:
- (i) it is sound and monotone;
- (ii) it BC-identifies every **finitely based** target from a text of its valid sequents;
- (iii) no learner identifies the whole lattice.

For (iii), take an increasing chain of finitely based relations whose union is not finitely based. A trivial example is axioms $f^i(c)$ for $i\le n$. By algebraicity the union is in the lattice, and then Gold's or Angluin's argument applies. EX-convergence of an *index* needs the derivability of new data to be decidable. That fails for some finite Hilbert calculi: the Linial–Post (1949) undecidability results for propositional calculi [unverified exact statement]. BC is what matters for a reasoner anyway.

**What structurality buys and does not buy.** An observed sequent with propositional variables yields all its substitution instances, which is genuine generalisation. A *ground* observed step (concrete numbers, specific functions) yields nothing beyond itself. So the brief's hope that "minimal closure = sound" is correct, but on ground data it is nearly vacuous. The nontrivial, sound generalisation operator is anti-unification within an intersection-closed class (§3, §9 T2).

### 8.2 Theorems determine only an interval
Let $T$ be a substitution-closed set of formulas. Define:
- $\Gamma\vdash^{\min}_T\varphi$ iff $\varphi\in\Gamma\cup T$;
- $\Gamma\vdash^{\rm adm}_T\varphi$ iff for all $\sigma$, $\sigma\Gamma\subseteq T\Rightarrow\sigma\varphi\in T$.

Both are structural consequence relations with theorem set $T$. Every structural $\vdash$ with $\mathrm{Thm}(\vdash)=T$ satisfies $\vdash^{\min}_T\subseteq\vdash\subseteq\vdash^{\rm adm}_T$. For the upper bound, structurality and cut give $\vdash\sigma\varphi$ from $\vdash\sigma\Gamma$ (routine; ours as stated).

$\vdash^{\rm adm}_T$ is the admissible-rule relation, or **structural completion** (Pogorzelski 1971 [mem]). The interval is non-degenerate for important logics. In intuitionistic logic, Harrop's rule and the Kreisel–Putnam rule $\neg p\to q\vee r\ /\ (\neg p\to q)\vee(\neg p\to r)$ are admissible but not derivable. The admissible rules have a basis given by the Visser rules (Rozière 1992; Iemhoff, *JSL* 66:281–294 (2001); Rybakov, *Admissibility of Logical Inference Rules*, 1997 [mem]). Classical propositional logic is structurally complete.

**Consequences.**
1. From theorem-text, no learner can distinguish members of the interval, so the step relation is not identifiable from theorems.
2. The maximal sound step-learner over "all relations with theorems $T$" outputs $\vdash^{\min}_T$, which cannot reason under hypotheses at all.
3. An *admissible-but-not-derivable* rule never leads from theorems to non-theorems. It is harmless for **categorical** reasoning but **unsound inside hypothetical contexts**.

This is a formal core of the user's context worry. *Eternal truths (theorems) underdetermine the in-context inference relation. Only in-context, hypothetical step data pins it down.*

### 8.3 A deduction theorem collapses the interval
Restrict the hypothesis class to relations satisfying a deduction theorem for a fixed $\to$: $\Gamma,A\vdash B$ iff $\Gamma\vdash A\to B$. Then $\gamma_1..\gamma_n\vdash\varphi$ iff $\vdash\gamma_1\to(\cdots\to\varphi)$, so **the relation is determined by its theorems**. The admissible closure of intuitionistic logic does not satisfy the deduction theorem; otherwise the Kreisel–Putnam rule would become a theorem.

*Philosophical reading.* This is Brandom's expressive role of the conditional ("making explicit" inferential commitments) turned into an identifiability statement. **A conditional that obeys a deduction theorem is exactly what lets assertion data carry inference data.** In physics, the analogue is the explicit "assume X; then Y" packaging of contexts.

### 8.4 When does learnability transfer from derivations to theorems? (conjecture with proof sketch)
**Claim.** Let $\mathcal H$ be a class of $\le k$-schema calculi that are **analytic** in this sense: there is a fixed computable map $\varphi\mapsto\mathrm{Sub}(\varphi)$, a *finite* set of judgments, the same for every $R\in\mathcal H$, such that every $R$-derivable $\varphi$ has a repetition-free $R$-derivation using only judgments in $\mathrm{Sub}(\varphi)$. Examples are subformula-property sequent calculi with set contexts, and the length-bounded case. Then $\{\mathrm{Thm}(R):R\in\mathcal H\}$ has finite elasticity and is identifiable from theorem-text.

*Sketch.*
1. The derivation-languages $\mathrm{Der}_R$ inherit finite elasticity from the step class. From an elasticity witness on trees, take for each $n$ a step of $\tau_n$ outside $V(R_n)$; this gives an elasticity witness on steps.
2. The relation "$\varphi$ is the root of a repetition-free derivation over $\mathrm{Sub}(\varphi)$" is finite-valued, because branching is bounded and depth is bounded by $|\mathrm{Sub}(\varphi)|$.
3. Apply Kanazawa's theorem, and use decidability of membership by finite search to apply Wright's theorem.

This would reprove a Shinohara-type theorem. It also reframes **cut elimination as the transfer of learnability from proofs to theorems**: analytic calculi for a given logic are learnable from its theorems, while Hilbert calculi with modus ponens are not analytic. To be checked:
- whether per-premise bounds suffice where Shinohara uses sums;
- whether the "Sub fixed independently of $R$" requirement is too strong for interesting classes.

---

## 9. Theorem candidates for the project

**T1 (maximal sound learner; characterisation). Status: proved (ours).** For any class $\mathcal C$, define $A_{\mathcal C}(D)=\bigcap\{L\in\mathcal C:D\subseteq L\}$.
- (a) $A_{\mathcal C}$ is sound and monotone in $D$.
- (b) Every sound learner satisfies $M(\sigma)\subseteq A_{\mathcal C}(\mathrm{content}\,\sigma)$.
- (c) The following are equivalent:
  - some sound learner BC-identifies $\mathcal C$ from text;
  - $A_{\mathcal C}$ does;
  - **(FG)** every $L\in\mathcal C$ has a finite $S\subseteq L$ such that, for every $L'\in\mathcal C$, $S\subseteq L'\Rightarrow L\subseteq L'$.
- (d) Finite elasticity implies FG (Lemma §2.3). For intersection-closed $\mathcal C$, FG is equivalent to Angluin's tell-tale condition, which is equivalent to finite generation.
- (e) FG is strictly stronger than Gold-identifiability. Example: $\mathcal C=\{2\mathbb N\}\cup\{H_n\}$ with $H_n=\{0,2,..,2n\}\cup\{2n+1\}$ is EX-identifiable, but $2\mathbb N$ fails FG.

*Proof of (c), (i)⇒(iii).* Suppose FG fails for $L$. Let $M$ converge on a text of $L$ by time $n_0$, and let $S=\mathrm{content}(t[n_0])$. There is an $L_S\supseteq S$ with $L\not\subseteq L_S$. Soundness for $L_S$ forces $L=M(t[n_0])\subseteq L_S$, a contradiction.

*Relevance.* This is the exact price of H1's worst-case soundness in the Gold setting. It is probably the Lange–Zeugmann strong-monotonic characterisation in non-effective form; check before claiming novelty.

**T2 (sound identification of bounded schema systems from steps). Status: proved modulo routine checks (ours).**

*Definition.* For tree-pattern schemas, possibly with a guard menu, let
$$A_k(D)=\bigcap_{\pi\in\mathrm{Part}_{\le k}(D)}\ \bigcup_{B\in\pi}\mathrm{Inst}(\mathrm{lgg}\,B).$$

*Claims.*
- $A_k(D)$ equals the intersection of all consistent $\le k$-unions. Every consistent union contains the cover induced by assigning each datum to one of its schemas.
- Hence it is **sound for every target in $\mathcal H_k$** and monotone.
- It converges to $V^\*$ on every text, by finite elasticity and the Lemma.
- For $k=1$ it is the lgg learner, i.e. the closure algorithm.
- *Every derivation using $A_k(D_t)$ is an $R^\*$-derivation*, so the reasoner is sound against any prover.

*Negative part (ours, explicit).* Picking one minimal consistent cover ($k$-mmg) is **unsound**. Take target $\mathrm{Inst}(f(x,x,a))\cup\mathrm{Inst}(f(x,y,b))$ and data $\{f(c,c,a),f(c,c,b),f(d,e,b)\}$.
- The minimal 2-covers are $H_1=\mathrm{Inst}(f(c,c,w))\cup\{f(d,e,b)\}$ and $H_2=\{f(c,c,a)\}\cup\mathrm{Inst}(f(u,v,b))$. They are incomparable.
- $H_1\ni f(c,c,d)\notin$ target.
- $A_2(D)=H_1\cap H_2=D$.

*Open.* The computational complexity of membership in $A_k(D)$ (it looks NP-hard), and polynomial special cases via the compactness conditions of Arimura–Shinohara–Otsuki ("Finding minimal generalizations for unions of pattern languages and its application to inductive inference from positive data", STACS 1994, LNCS 775 [mem]).

**T3 (completeness rates). Status: easy (ours).**
- *Positive:* for any intersection-closed class of VC dimension $d$ containing the target, the closure algorithm has **zero false acceptances** and completeness error $\le\varepsilon$ after $O(\tfrac1\varepsilon(d+\log\tfrac1\delta))$ human steps (Darnstädt). This applies, for example, to bounded-depth formulas over a finite signature, where the universe is finite.
- *Negative:* single tree-pattern schemas over a binary function symbol have infinite VC dimension. Take depth-$h$ trees $u_i$ with leaf $i$ equal to $a$ and all other leaves $b$; lggs of subsets put variables exactly at the chosen leaves, so the set is shattered. So there is **no distribution-free completeness rate**, even for the target $x$ ("anything"). Accidental shared structure in human examples (e.g. "all textbook examples use small numbers") is exactly this failure mode.
- *Program:* completeness guarantees must use distributional assumptions (Rossmanith–Zeugmann-style stochastic finite learning) or cooperative teaching (T2-style teaching sets).

**T4 (theorems vs steps). Status: proved (§8.2–8.3); T4′ conjectured (§8.4).**
- The interval theorem.
- Non-identifiability of the step relation from theorems.
- Collapse under a deduction theorem.
- T4′: analytic calculi transfer learnability from derivations to theorems.

**T5 (macro-steps). Status: plausible (ours).** Suppose human steps lie in $\vdash^{\le g}_{R^\*}$ with $|R^\*|\le k$ and at most $b$ premises per rule. By EBG-style unification of skeletons, each derivation skeleton of depth $\le g$ yields one derived schema. So the macro-step set is a union of $K\le k^{O(b^g)}$ schemas. Then T2 applies with $K$ in place of $k$: sound identification of the macro-step relation, and hence a sound reasoner, without ever identifying $R^\*$. Caveats: context variables (§3) and eigenvariable side conditions under composition.

**T6 (bounded label noise). Status: proved sketch (ours).**
- *Setup.* Suppose at most $e$ data points are invalid, and every valid step that occurs in the text occurs at least $e+1$ times. Define $A^{(e)}_k(D)=\bigcap_{D'\subseteq D,\ |D\setminus D'|\le e}A_k(D')$.
- *Soundness.* The clean subset is one of the $D'$, so the result is a subset of $A_k(D_{\rm clean})\subseteq V^\*$.
- *Convergence.* Every term eventually contains $V^\*$. Terms with no consistent $k$-union contribute the whole universe.
- *Without robustness:* one bad step amplified by lgg is a tonk-like disaster. From $\wedge$-elimination instances $A\wedge B/A$ plus one erroneous $A\wedge B/C$, the lgg is $X\wedge Y/Z$.
- *Unbounded noise rates* need probabilistic soundness; this connects to H1's Bayesian option. Coherence signals (D5) are then the natural detector of where the noise sits.

**T7 (sandwich convergence). Status: conjecture.** With step-text and model data (§4.4), $L_t\uparrow\vdash^\*$ in the BC sense if the target is finitely based, and $U_t\downarrow\vdash^\*$ if $\vdash^\*$ is determined by finitely many observable models. Examples: the 2-element matrix for classical propositional logic; finitely many finite matrices in general. Attribute exploration converges in at most $|\text{canonical basis}|+|\text{counterexamples}|$ rounds [mem].

**T8 (coherence is error detection for sound learners). Status: easy (ours).**
- If the learner is sound and the target is coherent in the actual context, accepted steps can never derive $\bot$ from actually accepted premises. So coherence signals arise **only** from noise, misspecification or a deliberately liberal (MDL) learner.
- Coherence therefore does not *drive* generalisation for sound learners. It *repairs* liberal or noisy ones.
- Under MDL with unbounded $k$, each $\bot$-derivation is a negative bag over the steps it uses. The natural repair is minimal hitting-set deletion of schemas, as in Lakatos-style monster-barring (H5).

---

## 10. Corrections and refinements to the brief

1. **H2 (Gold's problem).** Gold's obstruction applies only to superfinite or infinitely elastic classes. *Bounded* schema systems over tree patterns have finite elasticity, so identification from positive steps is fine. The real issues are:
   - the unknown bound on $k$ (needs a prior or MDL, which makes soundness probabilistic);
   - noise;
   - misspecification (guards, binders, contexts, implicit premises and lemma citations);
   - theorem-level versus step-level data;
   - completeness rates.
2. **H2, Remedy 1 needs a correction.** "Conservative or minimal learners" are sound only for intersection-closed or FG classes. **$k$-mmg and other minimal-generalisation learners for unions can be unsound** (T2 counterexample). Use the version-space intersection $A_k$. Plotkin's lgg is sound exactly for single schemas, or with guards from a conjunction-closed menu.
3. **H1 (soundness).** In the realisable intersection-closed case, soundness is deterministic and free: closure algorithm, consistent selective strategy and KWIK coincide. Bayesian-conservative acceptance with Ville-type arguments is needed only beyond that case: unbounded $k$, noise or misspecification. Also, PAC guarantees should be stated as *completeness* guarantees on human data, not as soundness guarantees.
4. **"Structural consequence relations are intersection-closed."** True (Proposition 8.1). It buys a sound, BC-convergent learner for finitely based targets, *but structurality generalises only along schematic variables already present in the data*. On ground steps it generalises nothing. The useful sound generalisation operator is anti-unification within an intersection-closed schema class.
5. **H6 (contexts) gets a precise form.** Theorem data cannot distinguish derivable rules from merely admissible ones. Admissible rules are sound categorically but unsound under hypotheses. So **training on in-context (hypothetical) steps is not optional**. A deduction theorem is what lets context-free assertions encode in-context inferences (§8.3).
   - Separately, a minimal learner learns only the inferences humans actually license. That can be a proper sub-relation of classical consequence, possibly without *ex falso*, which may help with technically inconsistent idealised contexts. But if the data include ¬-elimination together with disjunctive syllogism, explosion becomes derivable, so this is not automatic.
6. **H5 (informal math).** Rules over unparsed strings behave like *string* patterns: inclusion is undecidable, there is no unique lgg, and erasing patterns are non-learnable over small alphabets. Rules over *parsed trees* have the Plotkin lattice. This gives a formal reason why *inventing a language*, i.e. a parse into trees, matters: it moves the problem from string patterns to tree patterns.
7. **H3/H4.** At L1 level, positive *inferences* give sound lower bounds, and positive *models* (world observations, learning from interpretations, Horn envelopes) give complete upper bounds that may be unsound. The "coherence" side of bilateralism corresponds to the upper bound.
8. **Citation fixes.**
   - Passerini–Frasconi–De Raedt (2006) is about kernels over proof trees as features, not about learning rules from proofs. For the latter, cite De Raedt–Kersting–Torge (AAAI 2005) and De Raedt (2008).
   - "Darnstädt–Simon–Szörényi 2016" is probably a mix-up. The optimal closure-algorithm-type bound is Darnstädt, *IPL* 2015. Darnstädt–Simon–Szörényi is the co-training paper, *TCS* 2014 [mem].
9. **Scope warning.** The user's own notes treat many everyday inferences as *imperfect* or defeasible ("there's a building across the road ⇒ there's a door within 100 m"). Everything in L1 concerns strict validity of steps. Defeasible or probabilistic inference rules need a different target notion, such as Valiant's robust logics (*AI* 117 (2000)) or Khardon–Roth's "learning to reason" (*JACM* 44 (1997)) [mem], which other strands should cover.

---

## 11. Open problems and next reading

- **The effective version of T1:** relate it precisely to Lange–Zeugmann's strong-monotonic characterisation (find the exact statement in their survey, *TCS* 397, 2008).
- **Complexity of $A_k$ membership,** and polynomial cases: compactness w.r.t. containment, as in Arimura–Shinohara–Otsuki 1994 and Sato–Mukouchi–Zheng 1998.
- **Context variables:** does the multiset-pattern class (sequents $\Gamma, A\vdash B$ with erasable $\Gamma$) have finite thickness or finite elasticity? The erasing string-pattern negative results suggest caution.
- **T4′:** check against Shinohara 1994's exact definition, and Krishna Rao 2000's linearly-moded classes.
- **Learning from structures with discharge:** the Lambek-grammar learnability literature (Foret, Le Nir, Bonato, Retoré, Béchet) is the closest prior art on how hypothetical reasoning interacts with learnability.
- **Implicit premises and lemma citation** in human steps make the data *partial* derivations, a multiple-instance or latent-variable problem. I know no positive-data identification theory that handles them; this is a gap.

## References

The verification status of each reference is marked inline in the sections above. Key anchors:
- Gold 1967
- Angluin 1980a, 1980b, 1988
- Wright 1989; Motoki–Shinohara–Wright 1991
- Shinohara 1991, 1994; Arikawa–Shinohara–Yamamoto 1992
- Kanazawa 1998; Buszkowski–Penn 1990
- Plotkin 1970, 1971; Reynolds 1970; Nienhuys-Cheng–de Wolf 1997; Pfenning 1991; Baumgartner et al. 2017
- Lange–Zeugmann 1992; Lange–Zeugmann–Zilles 2008; Kapur–Bilardi 1992/1995
- Valiant 1984; Natarajan 1987; Helmbold–Sloan–Warmuth 1990; Auer–Ortner 2007; Darnstädt 2015; Ben-David–Mansouri–Mehrotra–Zampetakis 2026
- Goldman–Kearns 1995; Zilles et al. 2011; Doliwa et al. 2014; Kuhlmann 1999
- Angluin–Frazier–Pitt 1992; Frazier–Pitt 1993; Dechter–Pearl 1992; Kautz–Kearns–Selman 1995; Ganter–Wille 1999
- Muggleton 1991, 1997; Muggleton–De Raedt 1994; De Raedt 1997, 2008; De Raedt–Kersting–Torge 2005; Passerini–Frasconi–De Raedt 2006; Cohen 1995
- Mitchell–Keller–Kedar-Cabelli 1986
- Clark–Eyraud 2007; Chater–Vitányi 2007; Rossmanith–Zeugmann 2001
- Łoś–Suszko 1958; Wójcicki 1988; Pogorzelski 1971; Iemhoff 2001; Rybakov 1997
