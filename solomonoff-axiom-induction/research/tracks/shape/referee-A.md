# Referee A (proofs) for thread `shape`

*Adversarial referee report, 2026-10-16. Object: `notes.md` in this folder (544 lines, saved 02:22) and its scripts `checks/c1`–`c6`, `shapelib.py`. Read in full: the project brief `../../00-brief.md`, the thread brief `00-brief.md`, `../../NOTATION-draft.md` §5–§7, the `fundamentals` record §1 (`../fundamentals/notes-final.md`, definitions of $K_A$, $W_A$), the `sfi` record §8 (charged deduction), the literature scout's record `../../scouts/literature/notes.md` §3.8–§3.9, §5.1, §7. Every claim marked [proved] was checked line by line. Independent code (my own unit propagation, GF(2) algebra and search, not `shapelib.py`) is in `referee_code/refA_*.py`, seeded or deterministic, with outputs saved next to each script. Line numbers refer to `notes.md`. No git command was run.*

---

## Verdict

**Sound in its core, with several overstated or false statements that must be repaired before the paper uses them. No fatal issue.**

* The central technical results survive a line-by-line check:
  * Theorem 1.11 (reasoner invariance under program length);
  * the exact minimum without intermediate concepts (Prop 2.5, Theorem 2.6, Corollaries 2.7–2.8), which I replicated independently;
  * the propagation completeness of the chain encoding (Prop 3.1) and the libraries of Prop 3.2–3.3;
  * Lemmas 3.4–3.5 and the reduction in Theorem 3.6;
  * the directed-rule counts of Prop 4.2;
  * the learning theorem 6.2(a)–(e);
  * the depth-2 Hansel-type bound (Theorem 7.2).
* **The main problem (M1)** is a hypothesis-class slip. The listing and time-charged inducers are defined with intermediate concepts allowed (Definition 1.6: $H_{\mathrm{UP}}$ is explicit theories over $X\cup Y$). Yet the record attributes to them the exponential no-intermediate-concept gaps of §2. With intermediate concepts, Prop 3.2's own library makes the simplex family's gap between unit propagation and elimination *polynomial* in written length and $O(\log m)$ bits under $Kt$. The headline "exponential gaps in $K_{\rm lst}$, linear in bits under $Kt$" (§0 item 2, Theorem 1.12) is therefore false as stated. The correct exponential reasoner gap with intermediate concepts allowed is Theorem 3.6, not Corollary 2.8.
* **Statements that are false as written:**
  * the "iff" of Theorem 7.1 (two counterexamples);
  * Lemma 1.5 for the chain law at $m=2$;
  * the use of $K(A,b)$ where a time-bounded complexity is needed (Theorem 1.12(b), Prop 5.1(c), Theorem 5.2).
* **Statements stronger than their proofs:**
  * Theorem 4.3(1)'s "every hypothesis shaped like a program";
  * Theorem 5.2's use of the charged-deduction readings outside their data format;
  * the reading of Prop 8.1 (the added "lemmas" need not follow from $T$);
  * Theorem 3.6's appeal to GKRS, which needs the hidden-state law's observed functionals to match GKRS's input constraints (M7; the fix is one line).
* **Novelty.** The claim for Theorem 7.2 overlaps known Steiner 2-TC-spanner lower bounds. The claim for Theorem 2.6 needs the propagation-completeness literature as context.

Every fix below is local. None changes the thread's qualitative answer: the large separations are between reasoners and between vocabularies, not between declarative and procedural shapes. But the paper must take its numbers from the corrected statements.

---

## Issues

### Fatal

None.

### Major

**M1. The simplex "reasoner gap" under $K_{\rm lst}$ and $Kt$ silently drops intermediate concepts.**
*Where:*
* Theorem 1.12(a) ("§2–§3's size bounds are bounds on $K_{\rm lst}$", line 109);
* the paragraph after Theorem 1.12 (line 113): "about $(m-1)/2$ bits under time charging, and a factor $2^{(m-1)/2}/\mathrm{poly}(m)$ in written length";
* §0 item 2 ("exponential gaps in $K_{\rm lst}$, linear in bits under $Kt$");
* Theorem 4.3(4) ("between reasoners (GE against UP: Corollary 2.8 …)");
* §10 item 2, first bullet;
* Theorem 6.2(f) ("under $Kt$ the gap is $m+O(\log m)$ bits").

*Problem.* Definition 1.6 minimises over $H_{\mathcal R}$, and for $\mathrm{UP}$ that class is explicit theories over $X\cup Y$ (Definition 1.1, line 60). §2's bounds (Prop 2.3, Theorem 2.6, Corollaries 2.7–2.8) hold only over $X$. Prop 3.2 of the record itself gives, for every affine law, a $\mathrm{UP}$-usable library of $\sum_{\rm circuits}\min(2^{|u|-1},4|u|-6)$ clauses of width $\le3$. For the simplex family that is $m(2m-4)$ clauses once $r\ge4$.

*Computed* (`refA_checks` part C, `refA_extra` part I):

| $r$ | $m$ | chain-encoded circuit library | least theory without intermediate concepts (Cor 2.8) | listing bits, library / elimination core |
|---|---|---|---|---|
| 4 | 15 | 390 clauses | 1,920 clauses | 65 |
| 5 | 31 | 1,798 clauses | 1,015,808 clauses | 137 |
| 6 | 63 | | | 256 |
| 7 | 127 | | | 461 |
| 8 | 255 | | | 821 |

The listing-bits ratio grows polynomially, not like $2^{(m-1)/2}$. I checked the library's usability: exhaustively at $r=3$, and on 3,064 consistent antecedents at $r=4$.

Under $Kt$ with intermediate concepts, the library is printed in time polynomial in $m$ from $(A,b)$. So $Kt_A^{\mathrm{UP}}(\mathcal Q(\mathcal S))\le Kt(A,b)+O(\log m)$, and the gap is $O(\log m)$ bits, not $(m-1)/2$. The same holds for parity in Theorem 6.2(f): the chain encoding is printed in polynomial time, so the $Kt$ gap is $O(\log m)$ once intermediate concepts are allowed.

*Fix.*
* Write the hypothesis class into the notation, for example $K_{\rm lst}^{\mathcal R,X}$ and $Kt_A^{\mathcal R,X}$ for theories over the base variables.
* State §2's consequences for those.
* In Theorem 1.12, §0, Theorem 4.3(4) and §10, cite Corollary 2.8 as a gap *between reasoner-and-vocabulary pairs*. Cite Theorem 3.6 as the only exponential gap *between reasoners* with intermediate concepts allowed: $K_{\rm lst}^{\mathrm{UP}}(\mathcal Q(\mathcal H_n))\ge\|F\|\ge2^{\Omega(m^{\varepsilon/3})}$ against a polynomial-size linear theory for $\mathrm{GE}$. Under $Kt$ that gives a gap of $\Omega(m^{\varepsilon/3})$ bits, by Theorem 1.12(b)'s printing argument.
* The summary sentence for `philosophy` (line 438) is already consistent with this ("unless it is allowed new intermediate quantities, which help for a single law but not, in general, for a system of laws"). But the simplex family is a *system* for which intermediate quantities *do* help (polynomially), so it must not be the example of the "in general" clause.

**M2. $K(A,b)$ is used where a time-bounded complexity is required.**
*Where:*
* Theorem 1.12(b), upper bound (line 110): $Kt_A^{\mathrm{UP}_1}(\mathcal Q(\mathcal S))\le K(A,b)+\log_2|\mathrm{PI}(\mathcal S)|+O(k+\log m)$;
* Prop 5.1(c) (line 283): "a decider of length $K(A,b)+c$ running in time polynomial in $m$";
* Theorem 5.2 (line 289): "whose description length is $K(A,b)+c$".

*Problem.* A program of length $K(A,b)+c$ that "hard-codes" $(A,b)$ has to run a shortest program for $(A,b)$. That program's running time is not bounded by any computable function of $m$ in general. For strings $x$ of length $km$, $Kt(x)-K(x)$ can be of order $|x|$. So neither the $Kt$ bound nor "polynomial time and length $K(A,b)+c$" follows. The proofs (lines 115 and 285) silently assume that $(A,b)$ is available in polynomial time at cost $K(A,b)$.

*Fix.*
* In Theorem 1.12(b), use $Kt(A,b)$.
* In Prop 5.1(c) and Theorem 5.2, use the time-bounded complexity $K^{p}(A,b)$ at the polynomial budget of the reading, or simply the literal length $O(km)$ of $(A,b)$.
* The comparison in Theorem 5.2 survives: a decider for the core equations pays the same overhead.
* The examples (parity, simplex) have $Kt(A,b)=O(\log m)$, so their numbers stand.

**M3. Theorem 5.2 applies the charged-deduction readings outside their setting, and its status cites results it does not use.**
*Where:* Theorem 5.2 and its proof (lines 289–291); the Reading (line 293).

*Problem.*
* (i) **Data format.** The readings of the `sfi` record §8 (AI-paper Def E.18, SD Defs 1.2–1.6) are defined for proof-requiring labelled sentences, with hypotheses satisfying (F1), $\mathcal L$ finite and $B$ polynomial-time. Corollary 8.2's fit classes are statements about literal sequences $D^X$. Question data reach these readings only through the two-valued encoding (E2). Under (E2), Prop 1.8's point theory $T_{x^0}$ fits all question data with $m$ one-literal axioms and derivations of size $O(m)$ (from $x_i\leftrightarrow x^0_i$ derive $\neg\alpha$ or $\ell$). Its cost $K(x^0)+c$ is for example $K(m)+c$ for a homogeneous law, typically far below $K(A,b)$. So what the inducer actually prefers is neither the core nor the library. Under (E3) the readings are not defined: consistency of $T\cup\alpha$ is not a bounded-derivation condition.
* (ii) **The comparison.** "These readings assign the same cost … to 'the written core plus Gaussian elimination' and to 'the complete lemma library'" compares unlike things. Gaussian elimination is not a reasoner of SAI, and the readings assign no cost to it. What is shown is: under the readings, the full library costs only the description length of $(A,b)$ plus $c$.
* (iii) **Status.** The proof uses only the *definitions* of the readings (membership time; derivation size or material), not `sfi` Theorem 8.1 or Corollary 8.2.

*Fix.*
* Define explicitly "charged deduction with conditional data": $T\cup\alpha$ consistent (uncharged) and $\alpha\to\ell$ derivable within the budget.
* State: "the library $\mathrm{PI}(\mathcal S)$ fits $\mathcal Q(\mathcal S)$ at cost $K^{p}(A,b)+c$, with one-instance derivations; so these readings do not charge for writing the library out".
* Check the hypotheses in one line: $\mathcal L_m$ is finite; $B=\emptyset$; (F1) holds vacuously, since there are no parameters.
* Change the status to "[proved, from the definitions of the readings]".
* If a cost for the *core* under the readings is claimed, say how XOR equations are written as sentences. As CNFs, the simplex core has exponential material. As $\leftrightarrow$-chains, derivations of derived equations are polynomial in a Frege-type calculus, but this needs a proof.
* The Reading's "fit class … $\mathsf{NP}\cap\mathsf{coNP}$" should carry `sfi` Corollary 8.2's hypotheses: literal sequences, (F1), degrees charged.

**M4. Prop 8.1's added sentences need not be consequences of $T$, so its reading is wrong.**
*Where:* Prop 8.1 (lines 386–387, a proof sketch) and the §8 Reading (line 391: "the same theory with its know-how written out").

*Problem.* A cut formula can be arbitrary. Example: prove $\vdash P\to P$ by a cut on $\bot$, with left premise $P\vdash P,\bot$ and right premise $\bot,P\vdash P$, both by weakening. Then $T\cup\{\forall\vec x A_i\}$ can be strictly stronger than $T$, or inconsistent ($A=\bot$). The literal statement stays true, since a stronger theory proves $\varphi$, but it no longer says that *lemmas* (theorems of $T$) restore short analytic proofs.

*Fix.* Use as the lemma for a cut with left premise $\Gamma\vdash\Delta,A$ the universal closure $L:=\forall\vec x\,(\bigwedge\Gamma\to\bigvee\Delta\vee A)$.
* $L$ is valid because $\mathsf{LK}$ is sound, so $T\cup\{L\}\equiv T$.
* The cut is replaced cut-free from $L$, the right premise and identity axioms for $\Gamma$ and $\Delta$, using $\forall$-left, $\to$-left and $\vee$-left. The overhead per cut is $O(|\Gamma|+|\Delta|+|A|)$.
* The eigenvariable conditions are unaffected, because $L$ is closed.
* Alternatively, restrict the proposition to proofs whose cuts have left premise $T_0\vdash A$ with $T_0\subseteq T$.

The status stays [proof sketch].

**M5. Theorem 7.1's "iff" is false for theories with wide clauses; only "⇒" is proved.**
*Where:* Theorem 7.1 (lines 338–340): "An explicit theory over $X$, with clauses of any width, is $\mathrm{UP}_k$-usable for $\mathrm{Ch}_m$ iff, after replacing each clause by a prime implicate it contains, its edges form a $k$-hop TC-spanner".

*Counterexamples* (variables 1-indexed here):
* *Existential reading* (`refA_checks` B): $m=3$, $k=1$, $F=\{\neg x_1\vee x_2,\ \neg x_2\vee x_3,\ \neg x_1\vee\neg x_2\vee x_3\}$.
  * Replacing the wide clause by the contained prime implicate $\neg x_1\vee x_3$ gives a 1-hop spanner.
  * $F$ is not $\mathrm{UP}_1$-usable: from $x_1=1$, one round does not derive $x_3$.
* *Universal reading* (`refA_extra` B2): $m=4$, $k=2$, $F=\{\neg x_1\vee x_2,\ \neg x_2\vee x_3,\ \neg x_3\vee x_4,\ x_1\vee\neg x_2\vee x_4\}$.
  * The wide clause contains exactly one prime implicate, $\neg x_2\vee x_4$. The replaced edges $\{12,23,34,24\}$ form a 2-hop TC-spanner.
  * $F$ is not $\mathrm{UP}_2$-usable. From $x_4=0$, two rounds derive $x_3=0$ and $x_2=0$ but not $x_1=0$. From $x_1=1$ they do not derive $x_4$.
  * The mechanism: a wide Horn clause propagates in fewer directions than the edge it contains.
* *Random theories* (`refA_checks` B), 400 random implicate theories at $m=4$: 46 have *every* replacement a spanner yet are not usable. No usable theory has a non-spanner replacement, which is consistent with "⇒" (Lemma 2.4).

*Consequence.* The minimum statement ("the least number of clauses … is exactly $s_k(m)$") is correct: Lemma 2.4 gives the lower bound and a 2-CNF spanner gives the upper bound.

*Fix.* State:
1. a 2-CNF of prime implicates is $\mathrm{UP}_k$-usable iff its edges form a $k$-hop TC-spanner;
2. if $F$ over $X$ is $\mathrm{UP}_k$-usable, then for every choice of contained prime implicates the edges form a $k$-hop TC-spanner;
3. hence the minimum.

**M6. Theorem 4.3(1) and §0 item 5 state the directionality separation for "every hypothesis shaped like a program"; Prop 4.2(b) proves it only for rule tables without intermediate concepts.**
*Where:* Theorem 4.3(1) (line 265); §0 item 5 ("The separation the brief asked for exists"); §10 item 2, third bullet.

*Problem.*
* The proved object is a direction-complete set of sound directed rules over the base variables under forward chaining. For one parity law each such rule is a full table entry: its premise assigns all other $m-1$ variables.
* A program in the ordinary sense, a straight-line program or circuit, computes $x_j$ from the other bits with $O(m)$ gates. One program answers all $m$ directions with $O(m)$ gates: output the parity of the given bits.
* So for programs with internal variables the number of directions costs nothing. Meanwhile the "one axiomatised law plus cheap deduction" of the theorem is the $2^{m-1}$-clause CNF, itself exponential.
* The factor $m$ is the ratio between two table representations. The record's "What this shows" paragraph (line 270) says the separation is an artefact of forbidding intermediate concepts. The theorem statement and the summary, which the paper will quote, do not.

*Fix.*
* Replace "every hypothesis shaped like a program" by "every rule base (sound directed rules over the base variables, forward chaining)".
* Replace "the separation the brief asked for exists" by "a separation of the kind the brief asked for holds for rule bases without intermediate concepts, and only there (Prop 4.2(c))".
* Add one sentence: for straight-line programs, the direction factor is $O(1)$ for parity.

**M7. Theorem 3.6 may not follow from GKRS as cited: the input set must match.**
*Where:* Theorem 3.6 (lines 233–238) and its proof's parenthetical "their input encoding lists equations by up to $2n^3$ bits; identifying duplicate inputs changes the size by $O(n^3)$".

*Problem.*
* Search excerpts of ECCC TR18-163 (the GKRS report) say that $3\mathrm{Xor\text{-}Sat}_n$ is defined on $N:=|C|\,n^3=2n^3$ input bits. These are ordered triples $(v_1,v_2,v_3)\in[n]^3$ with two constraint types. The survey *Proofs, Circuits, and Communication* (arXiv 2202.08909), Corollary 3.8, states the bound as $\exp(n^{\varepsilon})$.
* If triples with repeated variables are inputs, they encode weight-1 constraints $x_v=b$ (and $(v,v,v)$ encodes the same).
* The hidden-state law $\mathcal H_n$ uses only weight-3 functionals. The function computed in the proof is then the *restriction* of $3\mathrm{Xor\text{-}Sat}_n$ with those inputs set to 0. A monotone lower bound does not pass to a restriction.
* "Identifying duplicate inputs", i.e. OR-ing the inputs of one constraint, works only if every input constraint has a counterpart in $\mathcal H_n$.

*Fix.*
* Include the weight-1 functionals: let $g_e$ range over $(u,c)$ with $u$ of weight 1 or 3.
* Or verify from the full text that GKRS's constraints use three distinct variables.
* The proof is otherwise unchanged ($\mathcal H_n$ stays a linear law with an $O(n^3)$-equation theory for $\mathrm{GE}$).
* Update the verification status: the form $2^{n^{\Omega(1)}}$ for $3\mathrm{Xor\text{-}Sat}_n$ is now attested at abstract and search-excerpt level by the ECCC text (its Theorem 1) and by the survey's Corollary 3.8, not only by Cavalar–Oliveira.

**M8. The novelty claim for Theorem 7.2 overlaps known Steiner TC-spanner lower bounds.**
*Where:* §9, "New here" (line 418): "the depth-2 bound with auxiliary variables and wide clauses (Theorem 7.2)"; §0 item 8.

*Problem.* Berman, Bhattacharyya, Grigorescu, Raskhodnikova, Woodruff and Yaroslavtsev (Combinatorica 34(3) (2014) 255–277; ICALP 2011; arXiv 1011.6100) prove, by their abstract, a nearly tight lower bound on the size of **Steiner** 2-TC-spanners of $d$-dimensional directed hypergrids. For $d=1$ that is the path. A 2-CNF with auxiliary variables answering single-source questions in two rounds is a Steiner 2-hop TC-spanner of the implication graph, with auxiliary literals as Steiner vertices. So the 2-clause case of Theorem 7.2 is known up to constants. The record cites this paper only for $\Theta(n\lambda_k(n))$ on the line (line 342, line 410).

*Fix.*
* Cite Berman et al. for the 2-clause (Steiner) case.
* Restrict the novelty claim to clauses of width $\ge3$ (conjunctive premises, handled by the Harris step) and to the explicit constant $\tfrac12$.
* Check the $d=1$ case and its constant when the full text is available.
* Prop 7.3 may likewise follow from their Steiner $k$-TC-spanner lower bounds, which would be an alternative to the unverified CFL depth correspondence.

### Minor

**m1. Lemma 1.5 is false for the chain law at $m=2$** (line 54, "for the chain law $x_1\le\dots\le x_m$, $m\ge2$").
* $F=\{\neg x_1\vee x_2,\ x_1\vee\neg x_2\}$ is $\mathrm{UP}$-compatible with $\mathcal Q(\mathrm{Ch}_2)$ but has $\mathrm{proj}\,F=\{00,11\}\ne\mathrm{Ch}_2$. The point $01$ has no coordinate determined by the other.
* Exhaustively, 2 of the 256 theories over two variables are compatible, and 1 of them has the wrong projection (`refA_checks` A).
* For $m\ge3$ every point $0^a1^b$ has $a\ge2$ or $b\ge2$, so it has a determined coordinate (checked for $m\le8$).
* Fix: "$m\ge3$". Theorem 7.1 is unaffected, since it speaks of usability.

**m2. Prop 1.9(a): the proof's "CNF of each sentence" is not available.** The setting is first-order with equality (`fundamentals` Def 1.1).
* $\mathcal L_m$ contains sentences that are not Boolean combinations of the atoms. For example, $T=\{\exists x\exists y\,x\ne y\vee x_1,\ \forall x\forall y\,x=y\vee x_1\}$ proves $x_1$, but neither sentence has a clause translation.
* Fix: let the fixed program enumerate the clauses over $X$ derivable from $T$. That set is r.e., and by completeness it has the same consistency and entailment behaviour as $T$ on question data.
* Also: Definition 1.6 writes $V(p)=\langle F\rangle$ for finite $F$. Part (a) needs the r.e. version, with $V(p)$ an index as in `fundamentals` Def 1.7. Say so.

**m3. Prop 1.9(b): the displayed bound omits the cost of $m$, and the left inequality ignores auxiliary variables.**
* The program must know $m$ to range over $2^m$ points. Write $\ell_{\mathbb N}(m)+\ell_{\mathbb N}(s)+c$ instead of $\ell_{\mathbb N}(2^m)+c$. The prose bound "$m+O(\log m)$" is right.
* The left inequality ("a finite theory is an r.e. set") treats an explicit theory over $X\cup Y$ as an SAI hypothesis, but the auxiliary symbols $y_i$ are not in $\mathcal L_m$. The same holds in (a) if "clauses" may contain auxiliary variables.
* Fix, either way:
  * let the fixed prefix replace $F$ by $\mathrm{PI}(\mathrm{proj}\,F)$, which is computable and behaves the same on question data;
  * or take SAI over $\mathcal L_m\cup Y$ and invoke `fundamentals` Corollary 4.5 (adding vocabulary changes $K_A$ by $\pm c$ on data in the old vocabulary).

**m4. Lemma 1.7: the Kraft sum is over canonical theories only.** Without the identification of renamed auxiliary variables, $\sum_F2^{-\ell_{\rm lst}(F)}$ over all theories diverges.
* Define $H_{\mathcal R}$ modulo renaming of $Y$ (canonical names $y_1,\dots,y_{N-m}$).
* $\ell_{\mathbb N}$ must code 0 ($N-m=0$, $|F|=0$), while Elias delta codes positive integers; shift by one.

**m5. Definition 1.4, last sentence.** "Completeness on base literals" includes the literals of $\alpha$, which $\mathcal Q(\mathcal S)$ excludes. Write "on base literals outside $\mathrm{dom}\,\alpha$".

**m6. Theorem 1.12's "the gap is $O(1)$ bits under program length" needs the converse** $K_A^{\mathrm{GE}}(\mathcal Q(\mathcal S))\le K_A^{\mathrm{UP}}(\mathcal Q(\mathcal S))+c$. The proof is one line: compute the affine hull of $\mathrm{proj}\,F$, which is $\mathcal S$ by Lemma 1.5.

**m7. The gloss of Corollary 2.7(b) (line 164) says "a derived law must be written down iff it cannot be obtained by chaining two derived laws through one intermediate base quantity".**
* This should say "a circuit".
* A non-circuit derived equation, such as the sum of two circuits with disjoint supports, is not decomposable in the defined sense, yet it never needs to be written.

**m8. Prop 4.2(b): "exactly $m2^{m-1}$ sound rules" is false as stated.** Under Definition 4.1, a rule whose conclusion lies in its premise ($\{x_j{=}v\}\cup Q\Rightarrow x_j{=}v$) is sound.
* At $m=3$ there are 54 sound rules, of which 42 are trivial and 12 non-trivial (`refA_extra` H).
* Exclude trivial rules, which correspond to tautological clauses.
* Prop 4.2(b) cites Corollary 2.7(c), which is stated for $m\ge3$, for $m\ge2$. The case $m=2$ is immediate, but say so.

**m9. Theorem 4.3(3) applies Theorem 1.11 to forward chaining on rule sets, which are not explicit theories.** Add the one-line extension: rule $\mapsto$ clause $\mapsto\mathrm{PI}(\mathrm{proj})$, and conversely $\mathrm{rules}(F)$.

**m10. The summary overstates three results.**
* §0 item 7: the Bayes loss "about $m\log_2m$ bits per pattern" is proved only for block-complete data (Theorem 6.2(d)).
* §0 item 8: "superlinear at every fixed depth" omits Prop 7.3's bound $w$ on clause width.
* §0 item 5: the factor "at most 9 … for every law" holds for unbounded propagation only. The Verification log (item 6) says so, but the summary does not.

**m11. Theorem 6.2(d) and (f) write $W_{\rm lst}^{\mathrm{UP}}$, $K_A^{\mathrm{UP}}$, $Kt$ for classes restricted to theories over $X$, while (e) uses the same symbol with intermediate concepts.** Write $W_{\rm lst}^{\mathrm{UP},X}$ etc.; this is tied to M1.

**m12. Prop 3.3.**
* "The base literals derived by unit propagation on $F\cup\alpha$" is undefined when a conflict occurs. State the equality for conflict-free runs, with the conflict clause separately.
* Argue the ($\supseteq$) direction at the fixpoint: the global fixpoint is closed under each $F_t$'s propagation, so it contains the closure.

**m13. Prop 7.3.**
* Say that the CFL bound counts wires. With gates counted, depth-1 prefix-OR has $n$ gates.
* The depth correspondence is unverified (the record says so). It is harmless, since only "superlinear at each fixed depth" is used.
* An alternative route avoids it: the circuit's graph is a Steiner $2k$-hop TC-spanner of the path (see M8).

**m14. Theorem 2.6 and Corollary 2.7(b): the literature context needed for the novelty claim.**
* Kučera and Savický, "Bounds on the size of PC and URC formulas", JAIR 69 (2020) 1395–1420 (arXiv 2001.00819). By the abstract, irredundant propagation-complete formulas for the same function have sizes within a polynomial factor of each other. This is close in spirit to "unique minimum", though weaker.
* Gwynne–Kullmann 2014's abstract: the standard translation is PC for one equation and fails for two. This is the auxiliary-variable analogue of Corollary 2.7(b)'s question.
* Cite both and hedge "new" accordingly.
* A search on 2026-10-16 returned a SAT 2026 paper (LIPIcs vol. 377, paper 5) for a query on propagation-complete XOR encodings. It could not be fetched (DNS failure) and should be checked before the novelty claim for Theorem 3.6 is finalised.

**m15. The literature scout's novelty check for seed 4** (`scouts/literature/notes.md` §5.1) says the paper "must cite the speed-up and learning-to-reason literature": Gödel 1936, Parikh 1973, Pudlák 1998, Bienvenu et al. 2014 on random axioms. §8 cites only Statman and Orevkov, and §9 only learning-to-reason. Add the speed-up references to §8.

Otherwise the record's novelty claims agree with scout L. The directionality theorem is new as a formal separation ("No formal separation theorem found. It would be new"), and Khardon–Roth is engaged, as scout L requires. Scout L did not survey knowledge compilation, so the record's own searches are the only basis for the novelty claims of §2–§3; the record should say so.

**m16. Prop 5.1(c): the one-instance derivation is "size polynomial in $m$" in calculus $\mathsf K$ without a count.** The record acknowledges this (Verification log 6). Give the count, or state "[proof sketch]" for that clause, because Theorem 5.2 rests on it.

**m17. (E3) as a three-valued event** (line 78). "label$(\alpha\to\ell)=1$ and label$(\neg\alpha)\in\{0,\iota\}$" is a union of two $M_A^3$ events, not one three-valued datum. $W_A^{\rm cond}$ is therefore not a value of $M_A^3$ on a data set. The record does not claim it is, but the paper should not suggest it.

**m18. Lemma 3.5:** "$2N$ rounds suffice". $N$ suffice, since each round adds a literal and at most $N$ can be added without conflict. This is harmless.

---

## Claim-by-claim result of the check

| item | check | result |
|---|---|---|
| Lemma 1.5 | line by line; exhaustive $m=2$ chain | **false for chain $m=2$** (m1); correct for affine laws and chain $m\ge3$ |
| Lemma 1.7 | line by line | correct after canonical naming (m4) |
| Prop 1.8 | line by line | correct |
| Prop 1.9 | line by line | statements correct; proof of (a) needs m2; bound in (b) needs m3 |
| Lemma 1.10 | line by line | correct |
| Thm 1.11 | line by line | correct |
| Thm 1.12 | line by line; computed (C, I) | (a) correct only for theories over $X$ (M1); (b) upper bound wrong with $K(A,b)$ (M2); simplex paragraph **false** with intermediate concepts (M1); (c) correct |
| Lemma 2.1, Prop 2.2, Prop 2.3, Lemma 2.4, Prop 2.5 | line by line, including the "some/every $j$" equivalence | correct |
| Thm 2.6 | line by line (both uses of $d_*\ge3$); replicated (D) | correct |
| Cor 2.7, 2.8; Rem 2.9 | line by line; table recomputed | correct (gloss m7; Cor 2.8 is a statement over $X$) |
| Prop 3.1 | line by line (forest argument, conflicts, $z$ in two constraints); exhaustive check $m\le6$ (J) | correct |
| Prop 3.2, Prop 3.3 | line by line | correct (m12) |
| Lemma 3.4, Lemma 3.5 | line by line | correct |
| Thm 3.6 | line by line; GKRS checked at search-excerpt level | correct given GKRS **if** the input sets match (M7) |
| Prop 4.2 | line by line; (c) splitting re-derived and checked (G) | (a), (c) correct; (b) correct after excluding trivial rules (m8) |
| Thm 4.3 | | (1) overstated (M6); (2) correct; (3) needs m9; (4) needs M1 |
| Prop 5.1 | | (a), (b) correct; (c) $K$ against $K^p$ (M2) |
| Thm 5.2 | against `sfi` §8 | stronger than shown; readings used outside their format (M3) |
| Lemma 6.1 | line by line; random check (F) | correct |
| Thm 6.2 | line by line, including the Kraft computation in (d) | (a)–(e) correct; (f) $K_A$ part correct, $Kt$ part only over $X$ (M1, m11) |
| Thm 7.1 | counterexamples (B, B2) | **"iff" false**; "⇒" and the minimum correct (M5) |
| Prop 7.1a | line by line | correct |
| table of $s_k(m)$ | independent exhaustive search (E) | agrees for $m\le9$, $k=2,3,4$ |
| Thm 7.2 | line by line (simplification, serving clauses, pairing, Harris) | correct; novelty overlaps Berman et al. (M8) |
| Prop 7.3 | | correct given CFL; m13 |
| Prop 8.1 | | sketch; reading wrong (M4) |
| Prop 8.2 | | correct (elementary) |

---

## Verification log

1. **Reading.** As listed in the header. Every [proved] item in §1–§8 was checked line by line. These are the places where I first suspected an error and then confirmed the proof:
   * Prop 2.5's use of the "for some, equivalently every, $j$" form of indecomposability. Both directions were re-proved: a witness $u'$ through $i$ for one $j$ gives the decomposition $u=u'+(u+u')$ with intersection $\{i\}$.
   * The two uses of $d_*\ge3$ in Theorem 2.6.
   * Prop 3.1 when the free variable $z$ lies in two active constraints. The root takes $z$, and the other constraint is its child.
   * Lemma 6.1 (ii)⇒(iii).
   * Theorem 6.2(d)'s Kraft bound: the sum over $F\supseteq R$ is at most $2^{-rb_m}\sum_s2^{-\ell_{\mathbb N}(s)}/(s-r)!$.
   * Theorem 7.2's simplification step, the claim that serving clauses have no second positive base literal, the bound $\sum_v|N(v)|\le m+|F|$, the pairing and the independence and Harris steps.

   The issues found are M1–M8 and m1–m18 above.
2. **Code** (`referee_code/`), written independently of `checks/shapelib.py`.
   * `refA_lib.py` implements parallel unit propagation, models, projection and entailment.
   * `refA_checks.py` (seed 20261016, 55 s) and `refA_extra.py` (deterministic, a few seconds) have their outputs saved as `refA_checks.out` and `refA_extra.out`. Results:
     * **A** (m1). Of the 256 theories over two variables, 2 are compatible with $\mathcal Q(\mathrm{Ch}_2)$, and 1 of them has $\mathrm{proj}=\{00,11\}$. Every point of $\mathrm{Ch}_m$ has a determined coordinate for $3\le m\le8$; for $m=2$, $01$ has none.
     * **B, B2** (M5). Counterexamples to the "iff" of Theorem 7.1 in both readings. Of 400 random implicate theories at $m=4$, 46 are non-usable although every replacement is a spanner, and 0 are usable with a non-spanner replacement ("⇒" holds).
     * **C, I** (M1). The chain-encoded circuit library for the simplex family is $\mathrm{UP}$-usable: exhaustively at $r=3$, and on 3,064 antecedents at $r=4$. It has 390 and 1,798 clauses at $r=4,5$, against 1,920 and 1,015,808 without intermediate concepts. The library/elimination listing ratio is 20, 65, 137, 256, 461, 821 for $r=3,\dots,8$.
     * **D** (Theorem 2.6 replicated). On 100 random laws with $d_*\ge3$ ($m=6$–$9$), $F_{\rm ind}$, computed from the *definition* of decomposability, is $\mathrm{UP}$-usable with projection $\mathcal S$ in 100 of 100. Every clause is necessary (a targeted witness antecedent fails after deletion) in 100 of 100. In 93 laws $F_{\rm ind}\subsetneq\mathrm{PI}$; in total $|F_{\rm ind}|=2{,}180$ against $|\mathrm{PI}|=6{,}740$.
     * **E** (the §7 table). An independent exhaustive search (path edges forced) gives $s_2,s_3,s_4$ for $m=2,\dots,9$ equal to the record's table.
     * **F** (Lemma 6.1). Conditions (i) and (iii) agree on 16,800 (theory, question) pairs.
     * **G** (Prop 4.2(c)). Splitting preserves usability in 20 of 20 random laws.
     * **H** (m8). Sound-rule counts with and without trivial rules.
     * **J** (Prop 3.1). The chain encoding is propagation complete on all variables, and conflicts exactly on inconsistent assignments, exhaustively for $m=3,\dots,6$ and both constants ($m=6$: 20,367 consistent and 38,682 inconsistent assignments, 0 failures).
   * **Determinism.** Both scripts were copied to a scratch directory and re-run. Their outputs were identical to the saved ones, ignoring timing.
   * **Defects in my own code, found and fixed.**
     * The first law sampler looped forever on parameter pairs for which no $[m,k,3]$ code exists ($m=6,k=4$; $m=5,k=3$). It now lowers $k$.
     * A follow-up index error followed from that change and was fixed.
     * A memory error in part I came from listing $2^{w-1}$ clause widths. It was replaced by counts.
     * The first necessity test in D (re-checking usability after each deletion) was too slow. It was replaced by a targeted witness per clause, which is what Prop 2.5's proof provides.
3. **The developer's checks, against these findings.**
   * `checks/c4` part D tests Lemma 1.5 only for chain laws with $m\ge3$, and only on perturbations $S\pm$ one point. So it could not see m1.
   * `checks/c6` part A tests the 2-CNF equivalence and the "⇒" direction for wide clauses ("wide sound clauses vs their 2-clause replacements … violations=0"). It does not test the "iff" for wide clauses, which is false (M5).
   * The scripts were not re-run by me. Their outputs agree with mine wherever both exist: Theorem 2.6, the $s_k$ table, Lemma 6.1, Prop 3.1.
4. **Literature** (WebSearch only; fetches of ECCC, Dagstuhl and ar5iv failed with DNS errors).
   * GKRS: ECCC TR18-163 (search excerpts) gives Theorem 1, "$3\mathrm{Xor\text{-}Sat}_n$ requires monotone circuits of size $2^{n^{\Omega(1)}}$". The input is the indicator vector over $N=|C|n^3=2n^3$ constraints, with output 1 iff the set is unsatisfiable. The survey *Proofs, Circuits, and Communication* (arXiv 2202.08909), Corollary 3.8, gives $\exp(n^{\varepsilon})$.
   * Kučera–Savický, JAIR 69 (2020) 1395–1420 (arXiv 2001.00819): abstract.
   * Berman et al., Combinatorica 34(3) (2014) 255–277 (arXiv 1011.6100): abstract.
   * Gwynne–Kullmann, arXiv 1309.3060: abstract.
   * Chandra–Fortune–Lipton, ICALP 1983: citation only; the content was not found.
   * A SAT 2026 paper (LIPIcs vol. 377, paper 5) surfaced for a query on propagation-complete XOR encodings and could not be read (m14).
5. **Novelty claims against scout L.** The novelty claims of §9 were compared with `scouts/literature/notes.md`:
   * §5.1 seed 4 and the theory-shape row (consistent, apart from the missing speed-up references, m15);
   * §3.9 (Khardon–Roth, Kowalski, Winograd, McCarthy: engaged);
   * §7.
6. **Not done.**
   * No proof assistant.
   * GKRS, Gwynne–Kullmann, Berman et al. and CFL were not read in full text, so M7, M8 and m13 rest on abstracts and search excerpts.
   * I did not try to prove or refute Conjecture 7.1b beyond $m\le9$.
   * I did not re-verify the `sfi` record's Theorem 8.1. M3 concerns only how its setting is used here.
7. **Restart safety.** No earlier version of this report existed in the folder. The report was written early (a stub, then the draft issue list, then the full text) and saved after each section.
