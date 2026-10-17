# Referee A (proofs) on thread `terms`

*Adversarial referee report on `notes.md` (this folder, 678 lines, dated 2026-10-15/16) and its scripts in `checks/`. Written 2026-10-16.*
* *Referee code:* `referee_code/rA1_alt_output_rule.py`, with its saved output `referee_code/rA1_alt_output_rule.out`.
* *Repository state:* no git command that changes repository state was run.
* *Numbering:* results are numbered as in `notes.md`.

## Verdict

**Sound in its core. No fatal issue. Two major issues and a list of minor ones, all fixable by restating or by writing out what the script already does.**

Every result marked *proved* was checked line by line, and an attempt was made to refute it. The following survived:
* Hempel's horn (Thm 2.1 (a)–(d)), including the tape-wise identity, the pushforward bounds in (b), and the padded random decider of (c) on one tape.
* Craig's construction in practice (Lemmas 3.1, 3.2, Thm 3.3, Cor 3.5) and proof padding (Prop 4.1).
* The pairing gadget and the ground translation (Lemma 4.2, Prop 4.3).
* The two-stack normal form (Def 4.4, Lemma 4.5), checked rule by rule: phases, disjointness, the invariant $h\le n$, and the left-end case.
* The binary-relation theorem and its observational translation (Thm 4.6 (i)–(iv)).
* The regularity theorem by Ehrenfeucht–Fraïssé (Lemma 5.2, Thm 5.1, Thm 5.3) and the corollaries (Cor 5.4, 5.5).
* Infinity, PA and the Kleene-type theorem (Lemma 6.1, Thm 6.2, Prop 6.3, Thm 6.4 (a)–(c), Thm 6.5, Rem 6.6).
* Ramsey and Craig side by side (Props 7.1, 7.2).
* The extensions (Props 9.1–9.4, Rem 9.3′).

In each of these I checked:
* quantifier order and the domain of every universally quantified variable, including non-standard and non-word elements;
* that "proves" refers to $B\cup$(the hypothesis's axioms), with $B$ possibly theoretical;
* consistency of the induced theory, by exhibiting the model;
* that additive constants are honest: $c$ is independent of $D$, $\Theta$ and $X$, and maps are computable and injective where a pushforward bound is used;
* that cited results of SD, TF, `sfi` and `fundamentals` are used with their hypotheses ((F1), (S), (S$_{\rm tape}$), $B$ $R$-free with distinct $t_w$, polynomial budgets with degrees charged).

All five scripts reran on scratch copies to byte-identical outputs.

**The two major issues:**
* **M1 (a gap in a proof marked proved).** The written construction in the proof of Prop 4.7 is wrong as stated. It takes Lemma 4.5's start rule and Thm 4.6's output rules with a free certificate variable. The first gives wrong verdicts: the record's own self-check found this and fixed the script, but not the text. The second makes the theory inconsistent for some machines (computed counterexample). The script's construction is correct and should be written out. Prop 4.7 feeds Cor 5.4, Thm 8.1(iv) and the (a1) column of every table.
* **M2 (a novelty claim against the literature).** "One binary theoretical relation suffices" is listed as new (§0, "What is new"; §10, ILP bullet, "[new]"). With free deduction, its existence part is the Kleene–Craig–Vaught theorem. As reported in secondary sources (Pakhomov–Visser 2019), every r.e. theory without finite models has a finitely axiomatised, even model-conservative, extension in the language expanded by a relation symbol of arity $\ge2$. What is new is the derivation-bounded construction and the fit classes under charged deduction, which is what scout L's novelty table allows.

The minor issues concern:
* a measurability hypothesis in Thm 2.1;
* missing consistency hypotheses and a non-normalisable "prior" in Prop 6.3;
* a primitive $<$ in Thm 6.5 that plain $\Q$ does not handle;
* overstated general wording drawn from specific propositions (Thm 8.1(iii), (iv));
* statuses of the arithmetic truth-predicate remarks;
* references: Ryll-Nardzewski for (KL); the `shape` row now that that record exists; credit to `fundamentals` Thm 4.4 for the projection machine;
* small inconsistencies in budgets, windows and notation.

## Issues

### Major

**M1. Prop 4.7: the construction written in the text is wrong as stated; only the script's construction is right.**
* *Where.* §4.5, proof of Prop 4.7: "Compile as in Lemma 4.5 with phases 2 and 3 only (no certificate) … At start pairs this gives the output rules, with $R:=X$; the rest of the proof of Thm 4.6(i)–(iii) applies."
* *Problem 1 (start rule).* Lemma 4.5's start rule $(Z;c(s)Y)\Rightarrow({\rm blk}(\#)Z;c(s_0)Y)$ pushes the separator onto $r$, above the raw input. Without phases 0–1 nothing moves it to $l$, and phase 2 then reads the bits of ${\rm blk}(\#)$ as raw input letters.
  * The record's self-check 7 (§16) found this: 1023 mismatches, reproduced in `rA1` Part 1.
  * The script was corrected, but the text of the proof still never states the start rule actually used, $(Z;c(s)Y)\Rightarrow(Z;c(s_2){\rm blk}(\#)Y)$.
* *Problem 2 (output rules).* "The rest of the proof of Thm 4.6 applies" imports Thm 4.6's output rules $\forall x\forall z\,(C(x,\eta\,{\rm st}(s)\,z)\to R(x)^{\pm})$, which have a free certificate variable $z$.
  * Without a certificate phase, $z$ is never consumed. It sits below the separator, and phase 3 rewinds any block-aligned $z$ onto the tape. So $M_1$ runs on $z'\#x$, not on $\#x$.
  * Lemma 4.5(1)'s normal form says nothing about $M_1$ on such tapes.
  * Prop 9.1(a)'s "scan first" argument cannot be borrowed, because it relies on phase 0 consuming $z$.
* *Counterexample (computed: `referee_code/rA1_alt_output_rule.out`, Part 2).*
  * *Setup.* The thread's own `compile_alt` and the fixed-point evaluator `accepts` are imported unchanged from `checks/t3_alternating.py`. Two transitions are added to its machine: $q_0\xrightarrow{0}{\rm ACC}$ and $q_0\xrightarrow{1}{\rm REJ}$. Both are unreachable from every start configuration, because cell 0 of a start tape always holds $\#$.
  * *Exact output rules:* all $2\times1023$ verdicts for $|x|\le9$ stay correct.
  * *Free-$z$ output rules:* $C(x,0\,{\rm st}(s)\,{\rm blk}(0))$ and $C(x,1\,{\rm st}(s)\,{\rm blk}(1))$ hold in the least fixed point for every $x$. So the theory derives both $R(t_x)$ and $\neg R(t_x)$ for every $x$, and it is inconsistent.
  * *Why the script did not show this.* On the script's unmodified machine the free-$z$ rules happen to give no wrong verdict: 0 on 24 test certificates × 1023 words. That machine gets stuck on every garbage prefix, so the script's checks could not expose the gap.
* *Fix.* Write the alternating compile out in full:
  * the start rule $(Z;c(s)|{\rm exact})\Rightarrow(Z;c(s_2){\rm blk}(\#)|{\rm exact})$, or equivalently the script's $(Z;c(s)Y)\Rightarrow(Z;c(s_2){\rm blk}(\#)Y)$;
  * the **exact** output rules $\forall x\,(C(x,0\,{\rm st}(s))\to R(x))$ and $\forall x\,(C(x,1\,{\rm st}(s))\to\neg R(x))$, with the premise $\mathrm{Std}(x)$ in the observational version. These are the rules in the script (`make_theory`: `t + code['s'] + '.e'`);
  * $\mathcal R$ defined as the set of codes reachable from the exact start pairs $(x,\eta\,{\rm st}(s))$, with the claim "$\sigma\in C^{\mathfrak T}$ iff the configuration accepts" used only at these pairs.

  With these changes the rest of the proof is correct. I checked:
  * the set $\{\sigma\in\mathcal R$ 0-tagged accepting$\}\cup(\text{outside }\mathcal R)\cup(\text{1-tagged in }C^{\mathfrak T})$ contains the base and is closed under the 0-tagged rules, because successors of reachable codes are reachable;
  * the induction on the height of computation trees, which needs every path to halt (the clock);
  * the conjunctive and disjunctive backward rules: universal at tag 0, existential at tag 1.

  The issue does not affect Thm 4.6 or Prop 9.1, where phase 0 consumes $z$.

**M2. "One binary theoretical relation suffices" is not new with free deduction; restate the novelty claim.**
* *Where.*
  * §0, "What is new": "**One binary theoretical relation suffices** (scout S's Q3.15, high priority): Theorem 4.6".
  * §10, ILP bullet: "Theorem 5.1 shows that invented *unary* predicates cannot … and Theorem 4.6 that one invented binary relation can [new]".
  * §10, Kleene/Craig–Vaught bullet. It reports their statements but not the arity.
* *Problem.* As reported in two independent search summaries of Pakhomov and Visser, "On a question of Krajewski's" (JSL 2019, arXiv 1712.01713), Kleene (1952) and Craig and Vaught (1958) show the following. If $U$ is r.e. and has no finite models, then there is a finitely axiomatised $\alpha$ that conservatively extends $U$ in the language expanded with at least one relation symbol of arity $\ge2$; Craig–Vaught even make $\alpha$ model-conservative. Unary additions do not suffice, by Skolem. The primary texts could not be fetched (see the Verification log).
  * Apply this to $U:=\{$the axioms of Def 1.3$\}\cup\Gamma_{f_X}$, $X$ decidable. Model-conservativity gives a finite theory with one binary theoretical relation into which $(\mathfrak T,X)$ expands (so it is "about the named objects"). It proves exactly the literals of $X$ and is conservative over $U$.
  * That is the free-deduction content of Thm 4.6(i) together with Prop 9.1(a). Cor 5.5's upper bound $K_{\rm fin}^{\mathcal L_O\cup\{C\}}\le K(V)+c$ is its effective form.
  * Scout L's novelty table (§5.1 row 2) says exactly this: "For finite axiom sets Kleene/Craig–Vaught give unbounded gains. For derivation-charged priors no prior result was found. **New if done for derivation-charged or template priors.**" Scout N1 (§0 row 3) also marks the ingredients as known (Kleene, Craig–Vaught).
* *What is new, and should be claimed.*
  * The explicit backward two-stack construction with derivation bounds (Thm 4.6(iii)), hence the fit classes of finite theories with one binary relation under (a2), (b2), (b) and, with M1 fixed, (a1).
  * The observational pairing translation and the forced ontological commitment (Thm 4.6(ii), Prop 9.1(b)).
  * The regularity theorem for unary vocabulary over the named structure (Thm 5.1). This is in the spirit of the Craig–Vaught unary example but in a different setting; its novelty is plausible but not established.
* *Fix.*
  * In §0, rename the item to "one binary theoretical relation suffices **under charged deduction**". Add one sentence: "with free deduction this is the Kleene–Craig–Vaught theorem (one relation of arity ≥ 2, model-conservative)".
  * In §10, state Craig–Vaught with the arity and model-conservativity, and restrict "[new]" to the charged readings.
  * Cite Craig–Vaught at Cor 5.5 and Prop 9.1(a).
  * Mark the statements of Kleene and Craig–Vaught as "known, verified at the level of secondary summaries", until the primary text is checked.

### Minor

**m1. Thm 2.1: $\Theta$ must be measurable; and the constant in (c) depends on $t$.**
* "For every set $\Theta$ of observational contents" is too broad. The map $\omega\mapsto T_O(A_\omega)\in2^{\Sent_{\mathcal L_O}}$ is Borel (each coordinate is an effectively open event), but the preimage of an arbitrary $\Theta$ need not be measurable, and then $M_A(\Theta;D)$ is undefined.
  * Part (d) is an identity of events, so it holds for every $\Theta$.
  * Parts (a)–(c) use $\Unif(E\cap[p])=2^{-|p|}\nu(\cdot)$ and need $\Theta$ Borel (or universally measurable).
  * *Fix:* "every Borel set $\Theta$". The same applies to Thm 8.1(i) ("every class of observational contents").
* In (c), $c$ depends on $t$, through the padded decider's constants $\alpha$ and $a$ and the clock. Say "for each such $t$ there is $c$".

**m2. Prop 6.3: missing consistency hypotheses, and a "prior" that is not one.**
* (a) and (b) state "$\psi\vdash\mathrm{Inf}_n$ forces $q(\psi)\ge n$" and "$|\psi|\ge\log n-\log\log n-O(1)$". Both are false for inconsistent $\psi$. Add "consistent", as Thm 6.2(a) has it.
* "Under a literal-size prior $2^{-\alpha|\psi|}$ the best theory with $f$ is favoured … by a factor $n^{\Theta(\alpha)}$." With infinitely many predicate symbols each counted as one symbol, $\sum_\psi2^{-\alpha|\psi|}=\infty$: for example, every $\forall x\,P_ix$ has the same size. So this is not a prior, and no posterior is defined.
  * Under any normalisable code (prefix-free codes for the predicate indices), a sentence with $k$ distinct predicates costs $\ge\sum_{i\le k}\lfloor\log i\rfloor=k\log k-O(k)$ bits.
  * Then the monadic cost of "at least $n$ things" is $\Theta(\log n\log\log n)$ bits: the lower bound from $2^kq\ge n$, the upper bound from $\mathrm{Cnt}'_k$ with $2k+1$ predicates. The favour factor is then $n^{\Theta(\alpha\log\log n)}$.
* *Fix:* either speak of the weight $2^{-\alpha|\psi|}$ of the single best theories, not of a prior or posterior, or give the bit-length version.
* The counter itself (binary increment with carry predicates, $O(k)$ size) is very likely folklore. It is the standard device behind the NEXPTIME-hardness of monadic first-order satisfiability. I did not verify a reference, so "new upper bound" should be "new relative to scout N1".

**m3. Thm 6.5: primitive $<$ and $\Q$.** Sort $\mathsf n$ carries $0,S,+,\cdot,<$, and (Q) is "Robinson's $\Q$ on sort $\mathsf n$". Plain $\Q$ has no axiom for a primitive $<$, so its $\Sigma_1$-completeness for formulas with $<$-bounded quantifiers is not available. SD Prop 4.7 was careful to say "$\Sigma_1$-completeness of $\Q$ for $<$-free sentences".
* *Fix:* either drop $<$ from sort $\mathsf n$ and write bounded quantifiers through $\exists z\,(z+x=y)$, or add $\forall x\forall y\,(x<y\leftrightarrow\exists z\,(Sz+x=y))$ to (Q).
* Also make explicit that many-sorted logic has nonempty sorts. The ($\supseteq$) step "sort $\mathsf a$ is nonempty, so $F_e\vdash\varphi$" uses it.
* The remark "*Many sorts.* With one sort and sort predicates the same holds for the data relativised to the $\mathsf o$-sort …" has no status and no proof. Mark it "proof sketch", or delete it. As stated, it is about relativised data, not the original data.

**m4. Thm 6.5 novelty.** "[new as stated]" is acceptable only for the Bayesian corollary $K_{\rm fin}^{\mathcal L^+}=K_A^{\mathcal L}\pm c$, $W_{\rm fin}^{\mathcal L^+}\asymp W_A^{\mathcal L}$. That corollary is immediate once the classical construction is known to be effective with a computable injective map.
* Using extra sorts to remove the infinite-models condition is routine. A two-sorted version (r.e. extensions of a set theory as reducts of finite class theories, via a satisfaction class) appears in the class-theory literature: the search turned up arXiv 1201.5509, "Satisfaction relations for proper classes", not checked further.
* *Fix:* present Thm 6.5 as "an effective, many-sorted form of the Kleene–Craig–Vaught theorem, with the induced Bayesian equivalence". Do not list the removal of the infinite-models condition as a difference.

**m5. Thm 8.1(iv) and §0 item 4: "must assert an observational sentence false of every named object (Prop 9.1(b))".** Prop 9.1(b) proves this only for the particular theory $T^O_P$. The general "must" is Thm 5.1's contrapositive, and in a weaker form: every finite observational theory, possibly with unary predicates and constants, that fits a non-regular $X$ is inconsistent with $\mathrm{Th}_{\mathfrak T}$. So it proves the negation of some $\{\mathtt e,\mathtt s_0,\mathtt s_1\}$-sentence true in $\mathfrak T$. "False of every named object" makes sense only for sentences of the form $\exists z\,\chi(z)$.
* *Fix:* "must prove an $\{\mathtt e,\mathtt s_0,\mathtt s_1\}$-sentence false in the named structure (Thm 5.1); for $T^O_P$ it is $\exists z\,\mathtt s_1\mathtt s_1z=z$, true of no named object (Prop 9.1(b))". The same applies to Rem 5.7 ("the observational theory must assert that such objects exist") and §9.2's *Reading*.

**m6. Thm 8.1(iii) and §0 item 3: "eliminated at polynomial cost under every reading".** The parentheses say what is proved. Per hypothesis there is $O(1)$ bits and a polynomial change of budget only under (b) (Prop 4.1). Under (a1), (a2) and (b2) the fit classes are equal (Prop 4.3, Thm 4.6, Prop 4.7). The per-hypothesis translation under (a1) is a proof sketch (§4.1).
* A reader will take "at polynomial cost" as a per-hypothesis translation. Fit-class equality bounds neither the extra loss nor the description length of the observational substitute.
* Under (a2) and (b2) at a fixed budget $h$, the substitute also needs a table of the data below the size of its own members, so even its description length is not $|p|+O(1)$ in general.
* *Fix:* "eliminated at polynomial cost: per hypothesis, with $O(1)$ bits, under (b); at the level of fit classes under (a1), (a2), (b2)". Use the same wording in the "What this does and does not show" paragraph, whose argument needs only the fit-class form.

**m7. Thm 6.4(d) and the claims built on it.** Thm 6.4(d) is correctly marked a proof sketch. But the following state its content as fact:
* the "*Contrast with infinity*" paragraph ("In arithmetic a unary theoretical predicate suffices");
* §10's "unary ones only where the domain codes syntax (arithmetic, Thm 6.4(d))", which is moreover an unproved generalisation ("only where");
* Table 7.4's "(or a truth predicate)".

*Fix:* add "(proof sketch)" to each, and replace "only where the domain codes syntax" with the two examples.

**m8. (KL): cite Ryll-Nardzewski as the direct reference.** "No consistent finitely axiomatised extension of PA in $\mathcal L_{\rm ar}$" is, according to secondary sources found here (a 2021 Barcelona thesis on the non-finite axiomatisability of PA, and the FOM list), Ryll-Nardzewski's theorem (*Fund. Math.* 39, 1952). The record derives it from essential reflexivity (Kreisel–Lévy) plus Gödel II. The derivation is correct, but the direct reference is the better one.
* *Fix:* cite Ryll-Nardzewski 1952 for (KL), "known, verified at the level of secondary sources". Keep the reflexivity argument as the proof idea.
* The search did not confirm Mostowski 1952 or the essential-reflexivity statement of Kreisel–Lévy 1968; they remain "known, unverified".

**m9. Table 7.4, `shape` row.** The `shape` record now exists (`../shape/notes.md`). Its Prop 3.1 gives the exponential gain for a single parity law: $4m-6$ clauses with $m-2$ auxiliary variables, against $2^{m-1}$ without. But its Prop 3.3 (private intermediate concepts add nothing to a system) and Thm 3.6 (systems of laws need exponential written length with *any* intermediate concepts, given GKRS 2019) qualify "yes, exponentially".
* *Fix:* "yes for single laws (exponentially; `shape` Prop 3.1); for systems only shared intermediate concepts help, and some systems need exponential length anyway (`shape` Prop 3.3, Thm 3.6)".
* Also update §16 "*Not done*", which says the `logic` and `shape` records were unavailable. `logic` §8 now confirms the citation of Rem 6.6: E1(a), (b) are its Thm 2.2(a)–(c), unchanged.

**m10. Credit for the projection machine (Thm 2.1(d)).** $G^O$ is the pull-back machine $G^*$ of `fundamentals` Thm 4.4 for the inclusion $\tau$: $A^{G^*}_\omega=\tau^*(A'_\omega)$, by the same compactness argument. Thm 2.1(d) adds the equality of the events and the class form.
* *Fix:* say so in Rem 2.2. Then drop "Exact tape-wise identity behind Hempel's horn" from "What is new", or reword it as "made explicit".

**m11. Budgets and windows: small inconsistencies.**
* Cor 5.4's header "(a2), (b2): any unbounded budget" should be "every unbounded budget with $h(m)\ge m+1$", as in Thm 4.6(iv). With a budget below the size of every member for small $m$, no derivation can cite anything, and table literals of size $m+1$ are needed.
* Thm 5.3: "Under (a1), (a2), (b2) the needed budgets are linear". Under (a2) and (b2) constant budgets $\ge\max(c_T,m+1)$ suffice. This is not wrong, but it is imprecise.
* §5.2's computed paragraph says the proof guarantees the window "$|u|<n$". The proof gives $W=\max(n-1,1)$, and §16 item 4 says $\{0,1\}^{<n-1}$. Align the three.

**m12. Notation and typos in the proof of Thm 5.1.**
* In "*One edge between the parts*", "$u=u'b$" should be "$u=bu'$": with the outside-in convention, $t_{bu'v}=\mathtt s_bt_{u'v}$.
* $v'$ is used both for the parent word ($v=av'$) and for the second word of the transplant ($v\ne v'$). Rename one, for example $v=a\hat v$ and $H:=\{t_{\hat v}\}$.

**m13. Prop 9.2's "verbatim".** The adaptation is straightforward but not verbatim. Three steps change:
* $\mathtt e$ becomes the $p$ roots, none of them in the range of any $\mathtt s_i$;
* $\{0,1\}$ becomes $\{1,\dots,r\}$;
* the axioms of $\mathrm{Th}(\mathfrak T_{p,r})$ that are used are injectivity, disjoint ranges, roots outside the ranges, and pairwise distinct closed terms.

Two sentences would make it a proof.

**m14. Prop 4.7's (a1) budget statement depends on M1.** Cor 5.4 rows 2–3, Cor 3.5's (a1) entries for finite theories, Thm 8.1(iv) "EXPTIME ((a1))", Table 7.4 and §0 item 4 all inherit Prop 4.7. Once M1 is fixed, nothing else changes.

## What was checked and found correct (summary)

* **Thm 2.1.**
  * (d): $G^O$ is c.e. By compactness and monotonicity, $A^{G^O}_\omega=T_O(A^G_\omega)$. Consistency transfers: $\neg\forall x\,x=x$ is observational because $\mathcal L_O$ has equality. $\Cn(B\cup T_O(A))\cap\Sent_{\mathcal L_O}=T_O(A)$ holds even with a theoretical $B$, and the contents are equal, so the class events are identical.
  * (a): the lower bound through $(G_U)^O$ and the upper bound through $G_U^O$, each with a fixed prefix.
  * (b): $o(e)$ and $f(e)$ are computable, and the pushforward bound is used in the right direction in both inequalities.
  * (c) coin-free: TF's padding of the semi-decider $f^O_e$, which is injective with $O(1)$ length.
  * (c) one-tape: `sfi` Thm 3.4's padded random decider applied once to $G_U$ itself. Here the program-less tapes need no separate matching, though matching them is harmless. The upper bound uses `sfi` Prop 3.5, with classes $\{T:T\cap\Sent_{\mathcal L_O}\in\Theta\}$.
* **Lemma 3.1, Lemma 3.2.**
  * Reinterpreting $R$ in a model of the $R$-free $B$ with distinct $t_w$ handles both labels $b$, and either kind of equivalence (logical or modulo $B$) works.
  * Uniqueness of the Craig member: with $k\ge2^d-1$ the line has size $\ge2^d|\varphi^b_w|$.
  * Gödel padding: $g\ge2^\ell\ge2^d$.
  * Example 3.4's numbers (376; $10^{203.2}$; $10^{204.6}$; 795; 702) match `s2_craig_blowup.out` line 27.
* **Thm 3.3.**
  * (a) The cited member is the unique power of the matching literal. Under each of (a1), (a2), (b), (b2) and size $\le h$, its size is bounded by the budget. The search over $m\le h(|w|+2)$ is polynomial ($|\varphi_w|=|w|+2$ in SD's node count). Compatibility gives correctness in both directions.
  * (b) Clocked Craig set, one MP from a fixed propositional instance.
* **Cor 3.5.** The (b) separation holds iff $\mathsf{NP}\cap\mathsf{coNP}\ne\mathsf P$; the others hold unconditionally.
* **Prop 4.1.** The constants match SD Thm 3.1(iii) exactly: $t^{+\#}=m^{k_0}+m^{k_0}(t+1)$; $2G'+m+31$; $G'+m+16$. $\theta_c$ is observational because it uses only $=,\forall,\neg,\to$.
* **Lemma 4.2, Prop 4.3.** $\mathfrak U$ is well defined. $\mathrm{Pair}$ holds exactly on pairs. $\theta_2(a,b)\leftrightarrow R(P(a,b))$ holds for **all** $a,b\in\mathfrak U$, not only words. The translated ground axioms are true in $\mathfrak U$ under the stated $R$. MP is preserved because the translation is atom by atom.
* **Lemma 4.5**, checked phase by phase:
  * after phase 0, $r={\rm blk}(\mathtt Z_{z_m})\cdots{\rm blk}(\mathtt Z_{z_1}){\rm blk}(\#)x$;
  * after phase 1, $l=c(s_2){\rm blk}(\#){\rm blk}(\mathtt Z_{z_1})\cdots$;
  * after phase 3, the tape is $\mathtt Z_{z_m}\cdots\mathtt Z_{z_1}\#x$ with the head on cell 0;
  * the machine rules in the cases R, S, L, the left end, and a blank read;
  * disjointness on **all** pairs of words, not only reachable ones, as Thm 4.6's backward-closure argument needs;
  * fixed-length state codes prevent a spurious halting prefix.
* **Thm 4.6.**
  * (i) Backward closure equals "the deterministic run reaches a halting prefix", using linearity, disjointness and injectivity of the match. Two models give the two non-provability directions.
  * (ii) $\mathrm{Std}$ relativisation; the pairs carry $C$, the words carry $R$, and other pairs are false.
  * (iii) A4/MP derivations with $O(\ell)$ lines.
  * (iv) Table literals of size $m+1$; the (a2)/(b2) budget is constant; (b) material $O(N\ell)$; (a1) gives deterministic PSPACE.
* **Thm 5.1, Lemma 5.2.**
  * One edge between $\mathrm{Sub}_v$ and the rest. This uses only injectivity and disjoint ranges from $\mathrm{Th}_{\mathfrak T}$, so it holds in non-standard models.
  * Constants lie in $\mathrm{Sub}_v$ only for $v\in E$.
  * The pigeonhole count $N_q+|E|$ is right, including residuals realised only inside $E$.
  * Overlapping $\mathrm{Sub}_v\supset\mathrm{Sub}_{v'}$ is harmless, since labels are copied from the original structure.
  * The quantifier-free redefinition keeps rank $q$, and the EF composition for disjoint unions is right.
* **Thm 5.3.** The refinement $E_{j+1}$ is determined by $E_j$; stabilisation by $n-1$; the signature theory is true in $(\mathfrak T,X)$ and derives each datum inside-out.
* **Cor 5.5, Rem 5.6.**
* **Lemma 6.1, Thm 6.2.**
  * The EF strategy on truncated cells.
  * (b) both bounds, and the $o(G)$ argument. For each $r$ the constant depends on $r$, which is fine.
  * (c) injectivity chain.
  * (d) pushforward under the partial computable $N(\cdot)$.
* **$\mathrm{Cnt}'_k$**: $Q_i\leftrightarrow\bigwedge_{j<i}P_j$ are the carries, and $P_i\oplus Q_i$ is bit $i$ of $v+1$ for $v<2^k-1$.
* **Thm 6.4** (a)–(c), given (KL). The (KL) argument via essential reflexivity and Gödel II is correct (see m8 for the reference).
* **Thm 6.5.**
  * ($\supseteq$): external induction using only instances of the clauses at numerals, whose guards are true $\Sigma_1$ sentences. Extra non-standard witnesses of the guards in other models add constraints but cannot block the derivation. Consistency comes from ($\subseteq$).
  * ($\subseteq$): the standard expansion with $\mathsf n=\mathbb N$ and $\mathsf a=M^{\mathbb N}$.
  * Complexity: both maps are computable, and $e\mapsto F_e$ is injective.
* **Rem 6.6**, with `logic` Thm 2.2 (re-read).
* **Prop 7.1** (countable choice suffices for (a)) and **Prop 7.2**. For (b): a one-element model separates any non-reachable pair, and every member of an equivalent $S$ is an $A_i\to B_j$ edge or a loop.
* **Prop 9.1.**
  * (a): disjointness and injectivity hold in every model of $\mathrm{Th}_{\mathfrak T}$; a non-standard $z$ or $x$ gives an infinite phase 0 or phase 2; standard start pairs follow Lemma 4.5.
  * (b): with no pairs, the output rules give $\forall x\,R(x)\wedge\forall x\,\neg R(x)$.
* **Prop 9.3**: the 15 sentences are true, and the 7-case reduction is complete.
* **Rem 9.3′**: in the term algebra with $\mathtt p$, phases 0 and 2 get stuck at a $\mathtt p$-term.
* **Prop 9.4**:
  * $\mathrm{Acc}\in\mathsf{EXPTIME}$ is reduced to $X$;
  * clocked configurations accept or reject, and every member is true in $(\mathfrak T,X)$;
  * the $\theta$-guards make membership polynomial;
  * every line has polynomial size.

## Verification log

*Reading.* In full:
* this thread's `00-brief.md` and `notes.md`;
* the project brief `../../00-brief.md`;
* `NOTATION-draft.md` (the relevant entries).

In part:
* SD `notes-final.md` §1 (Defs 1.2, 1.3, 1.6, Fact 1.4, Rem 1.5), §3 (Thm 3.1, Cor 3.2), §4.1–4.2 (Lemma 4.1, Thm 4.2, Prop 4.3, Cor 4.4, Prop 4.6);
* `fundamentals` Defs 1.1–1.7, Thm 4.1, Prop 4.2–4.3, Thm 4.4, Cor 4.5;
* `sfi` §3.3 (S$_{\rm tape}$, Def 3.3, Thm 3.4, Prop 3.5) and Thm 7.1;
* `logic` §2.2 and §8 (cross-references);
* `shape` §3 (Props 3.1, 3.3, Thm 3.6);
* scout L §3.4, §3.8 and §5.1;
* scout N1's §0 table rows on B1–B3 and its symbol-count convention.

*Reruns.* `checks/hilbert_check.py`, `t1_hempel_toy.py`, `t3_alternating.py`, `t4_two_stack.py`, `t4_regular.py` and `t5_monadic.py` were copied to the session scratchpad (`…/scratchpad/terms_rerun/`) and run with `python3 -I`. All exited 0 and wrote outputs byte-identical to the saved `.out` files. Wall times were 5, 10, 42, 23 and 1 s.

*Referee code.*
* `referee_code/rA1_alt_output_rule.py` (deterministic, about 10 s) imports `compile_alt`, `accepts`, `alt_machine` and `spec_Y` from `checks/t3_alternating.py` unchanged. Its output, `referee_code/rA1_alt_output_rule.out`, ends "all expectations met".
* Part 1 reproduces the record's 1023 wrong verdicts for Lemma 4.5's start rule in the alternating compile.
* Part 2a: the script's compile with exact output rules gives 0 wrong verdicts. With free-$z$ output rules, the script's own machine also gives 0 wrong verdicts on 24 certificates × 1023 words.
* Part 2b: with two unreachable transitions added, exact verdicts stay correct (0 wrong), while the free-$z$ theory proves $R(t_x)$ and $\neg R(t_x)$ for all 1023 words (M1).

*Literature (web searches, 2026-10-16).* Direct fetches of arxiv.org, ar5iv, cs.nyu.edu, richardzach.org, philpapers and the Utrecht repository all failed: DNS failure, or a proxy 403. So the following rest on search-result summaries (secondary):
* Kleene (1952) and Craig–Vaught (1958, JSL 23(3), 289–308): an r.e. theory without finite models has a finitely axiomatised conservative extension, model-conservative in Craig–Vaught, in the language expanded with at least one relation symbol of arity $\ge2$. Unary additions do not suffice (Skolem). Source: summaries of Pakhomov–Visser, "On a question of Krajewski's", JSL 2019 / arXiv 1712.01713. Used in M2.
* "No consistent finitely axiomatised extension of PA" attributed to Ryll-Nardzewski 1952: a Barcelona thesis (diposit.ub.edu, handle 2445/176007) and the FOM list. Used in m8.
* Not confirmed: Mostowski 1952 and the essential-reflexivity statement of Kreisel–Lévy 1968. The search confirmed only Kreisel–Lévy's PRA + RFN(PRA) ≡ PA.
* A two-sorted (class-theory) Kleene-type theorem appears in arXiv 1201.5509; used in m4, not checked further.

*Not done.*
* No primary-source check of Craig–Vaught; the arity statement in M2 should be confirmed there before the paper cites it.
* No independent re-implementation of the two-stack compiler; that is referee B's domain. My check of Lemma 4.5 and Thm 4.6 is by hand, plus the scripts' symbolic disjointness test.
* No check of the textbook one-tape simulation or of CKS, which are used as known.

*Repository state.* Files were written only in `research/tracks/terms/` (this report, and `referee_code/rA1_alt_output_rule.py` with `.out`) and in the session scratchpad (the reruns). No git command that changes repository state was run.
