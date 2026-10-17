# Referee A (proofs) on thread `sfi`

*Adversarial referee report on `notes.md` (this folder, 629 lines, dated 2026-10-15) and its scripts `checks/c1`–`c4`, written 2026-10-16. Referee code: `referee_code/rA1_gadget_ratio.py` with its saved output. No git command that changes repository state was run. Numbering of results follows `notes.md`.*

## Verdict

**Sound in its core; no fatal issue; two major issues and a list of minor ones, all fixable by restating.**

Every result in the core of the thread survived a line-by-line attempt at refutation:
* the maps (PS), (EM), (CR), (CL) and the decompositions (Lemmas 1.2, 1.3);
* the coin-free equivalence (Thm 2.1), the one-tape equivalence (Thm 3.1, Cor 3.2) and its penalised form under (S$_{\rm tape}$) (Thm 3.4, Prop 3.5);
* the chain (Prop 4.1);
* the transfer principle (Thm 5.1) and its corollaries;
* logical closure (Prop 6.1);
* the independent-label separations (Lemma 6.3′, Props 6.3–6.5, including the Lebesgue-density argument);
* the global-schedule filter (Prop 6.8(c));
* the Presburger separations with free deduction (Props 9.1, 9.2);
* the circuit sandwich (Thm 10.1) and Cor 10.2.

In each of these I checked:
* the quantifier order;
* the $D=\emptyset$ cases and the $(1-\Omega_V)$ terms;
* that the index maps are injective and computable on all indices;
* that consistency is pathwise where it must be;
* that "proves" refers to $B\cup$(the hypothesis's axioms).

All four scripts reran from scratch to byte-identical outputs.

The two major issues are statements stronger than their proofs:
* **M1.** Prop 9.4 claims the doubly exponential lower bound also for the per-instance reading (a1). The proof given does not cover (a1), and what does follow for (a1) is only singly exponential. The summary (§0 item 9(ii)), the closing paragraph of §9 and table row 30 generalise further, to "derivation-charged SAI with any budget below doubly exponential fails". That is unproved for (a1) and unaddressed for (a2) and (b2).
* **M2.** Prop 6.7(c) claims $\emptyset'$-computability for all eight objects. The proof covers only those whose defining conditions are $\Delta_2$. Closedness and "is a (random) decider" are $\Pi_2$ conditions, so the claim is unproved for $W^{\rm cl}$, $M_F^{\rm cl}$, $W_A^{\rm dec}$ and $M_A^{\rm dec}$.

The minor issues concern:
* a length convention and the verification status of Fischer–Rabin (now verified at the abstract level, below);
* an unnecessary hypothesis ($\Sigma_1$-soundness) in Lemma 6.3′, which is classical in substance;
* missing hypotheses in Cor 4.2, Rem 6.6 and Thm 7.8;
* one wrong scope in Thm 7.8(d);
* a tautological "computed" status (Prop 6.1(c));
* notation and credit.

The novelty claims agree with scout L's record (§5.2–§5.3: one-tape equivalence "new"; Presburger "new application"), with two credit additions (m14).

---

## Issues

### Major

**M1. Prop 9.4 for reading (a1), and the generalisation in §0 item 9(ii), §9's closing paragraph and table row 30.**

*Claim.* Prop 9.4: under $W_A[t,d]$, $d(m)>2^{2^{c''m}}$ infinitely often. "The same holds under readings (a1), (b) (Thm 8.1(a): size $\le$ a polynomial of the material)."

*Problem.*
* Thm 8.1(a) bounds derivation size by a polynomial of the **material**, which reading (b) bounds. So the argument for (b) is correct.
* Reading (a1) bounds only the size $h$ of each axiom instance (AI-paper `app-time.tex`, Def E.18 `def:time:short`: "every axiom line has size at most $h(|\varphi_i|)$"). It does not bound the material. A derivation under (a1) can have about $2^{O(h\log h)}$ distinct lines.
* What does follow for (a1) is through AI-paper Prop E.23(a) (`prop:time:aone`, SD Thm 4.2). Its proof applies verbatim to arbitrary sentence data, not only to literals.
  * A compatible hypothesis yields a **deterministic** decision procedure for $\mathrm{PrA}$ in time $2^{O(H\log H)}(1+t(H))^{O(1)}$, with $H=\max(h(m),m+1)$.
  * Fischer–Rabin then gives only $H\log H\ge\Omega(2^{cm})$, that is, $h(m)>2^{c''m}$ infinitely often: a **singly** exponential lower bound.
  * Whether (a1) fits $D^{\rm Pres}$ at exponential budgets is not settled by anything in the record.
* §0 item 9(ii) and the closing paragraph of §9 ("once derivations are charged below doubly exponential size, SAI fails too") and the Qualifications paragraph ("again disappears when deduction is charged") go further still.
  * Under the nonlogical-only readings (a2) and (b2), logical instances are free. So the guess-and-check route gives no bound at all.
  * Cor 8.2(c) (every decidable $X$ is fitted) is about literal sequences in the literal language. It does not apply to $D^{\rm Pres}$ in $\mathcal L_{\rm Pr}$ with $B=\emptyset$.
  * So nothing is proved for (a2) and (b2) on Presburger data, in either direction.

*Fix.*
* Restate Prop 9.4 as follows:
  * (i) $W_A[t,d]$ and reading (b): doubly exponential, as proved;
  * (ii) reading (a1): $h(m)>2^{c''m}$ for infinitely many $m$, by AI-paper Prop E.23(a) and Fischer–Rabin's deterministic bound;
  * (iii) readings (a2) and (b2): open on $D^{\rm Pres}$.
* Restrict §0 item 9(ii), the §9 closing paragraph, the Qualifications sentence and table row 30 accordingly ("for the size and material readings").
* State explicitly how AI-paper Thm 6.9's hypothesis "$\ell(m)\ge m$ time-constructible" is avoided. Argue by contradiction with the time-constructible clock $2^{2^{cm}}$: if $d(m)^{c_e}\le2^{2^{cm}}$ for all large $m$, the clocked nondeterministic procedure contradicts Fischer–Rabin. The record uses this implicitly.
* Minor improvement in the same place: the final step gives $c''=c/2$, independent of $e$.

**M2. Prop 6.7(c) ($\emptyset'$-computability) is stated for all eight objects but proved only for four.**

*Claim.* "All of them are computable relative to $\emptyset'$, uniformly in $D$." Proof: "Each object is a sum of $\Delta_2$ indicators (support conditions are $\Sigma_1$, consistency is $\Pi_1$)…".

*Problem.*
* The list includes $W^{\rm cl}$ and $M_F^{\rm cl}$, whose defining condition (closedness) is not $\Delta_2$.
  * For a partial computable labeller $\{i\}$, "closed" is $\forall\varphi,b\,[B\cup\Gamma_{\{i\}}\vdash\varphi^b\to\{i\}(\varphi)=b]$, a $\Pi_2$ condition.
  * On one tape the event "$f_\omega$ closed" is a countable intersection of (closed $\cup$ open) sets, a $\Pi^0_2$ class.
  * Its measure is in general only right-c.e. relative to $\emptyset'$ (an infimum of a uniformly left-c.e. sequence), not $\emptyset'$-computable.
* The list also includes $W_A^{\rm dec}$ and $M_A^{\rm dec}$, whose condition "$\{V(p)\}$ is total and 0/1-valued", or "$F_{V(p)}$ halts on every query and every tape", is $\Pi_2$. The latter uses König's lemma per query and then $\forall\chi$.
* The proof says nothing about these conditions.

*Fix.* Either:
* restrict (c) to $W_A$, $W^{\rm cons}$, $M_A$, $M_F^{\rm cons}$ (whose conditions are $\Sigma_1\wedge\Pi_1$) and say "$\emptyset''$" for the closed and decider versions; or
* prove $\emptyset'$-computability for the latter by another route. I see none, and expect it to be false in general.

Parts (a) and (b) are unaffected.

### Minor

**m1. Length convention in F$_{\rm FR}$ (Props 9.1–9.4).**
* The record assumes that "sentence lengths in our syntax and in Fischer–Rabin's differ by a constant factor $\kappa$". This is not checked.
* If either syntax writes variable indices in binary while the other counts a variable as one symbol, the conversion is $O(m\log m)$ in one direction.
* The doubly exponential thresholds then change: a procedure in time $2^{2^{c'm}}$ on our lengths gives only $2^{2^{c'n\log n}}$ on Fischer–Rabin lengths, which is no contradiction.
* *Fix.* Do one of:
  * check Fischer–Rabin's length measure (MIT LCS TM-43);
  * use a syntax with a bounded number of variable names, if their hard sentences admit one;
  * state Props 9.1–9.4 with a conversion function, e.g. clocks $\tau(m)\le2^{2^{c'm/\log(m+2)}}$, which is qualitatively the same result.

**m2. Verification status of the complexity references (§14, Verification log).**
* The record says web search was unavailable.
* I verified the Fischer–Rabin abstract through search results (HUJI and MIT DSpace listings, and secondary summaries; the full text was not retrieved). The abstract states:
  * a fixed constant $c>0$ such that for every (also nondeterministic) decision procedure and all sufficiently large $n$ there is a sentence of length $n$ requiring more than $2^{2^{cn}}$ steps for Presburger arithmetic;
  * the same bounds for proof lengths in complete axiomatisations "in which the axioms are easily recognized".

  So F$_{\rm FR}$ as stated is correct, including the universal constant and "for all large $m$". Upgrade the status to "known; statement verified against the abstract (search), full text not seen".
* For Berman (1980), *TCS* 11(1), 71–77: secondary sources (Haase's notes; Klaedtke) confirm completeness of $\mathrm{PrA}$ for $\mathrm{STA}(*,2^{2^{n^{O(1)}}},O(n))$.
  * The specific form (B*) is not confirmed by these sources: a $\Sigma_2$-time lower bound $2^{2^{c_Bm}}$ with a **linear** exponent.
  * If the hardness is only under polynomial-size reductions, the derivable bound is $2^{2^{m^{\varepsilon}}}$, and Prop 9.3's clock must be weakened to $\tau\le2^{2^{c'm^{\varepsilon}}}$.
  * Prop 9.3 is correctly marked conditional. Add this caveat to (B*).
* Also in Prop 9.3: the constant $\kappa'$ is not needed beyond the length conversion. $(C\tau+m)^{k\kappa}\le2^{2^{c_Bm}}$ holds for large $m$ whenever $c'<c_B$, which is the form Prop 9.1(b) already uses ($c'<c$).

**m3. Lemma 6.3′ is classical, and $\Sigma_1$-soundness is not needed.**
* For every consistent r.e. $T$ with $\Q\subseteq\Cn(T)$, the pair (theorems, refutable sentences) is effectively inseparable. This is classical: Smullyan, *Theory of Formal Systems*, 1961, as reported in Sorbi's CiE 2021 slides and Cheng's arXiv:2210.17333. The exact location in Smullyan should be checked before citing.
* Effective inseparability gives productivity of $\mathrm{Ind}_B$ at once: given $\mathsf W\subseteq\mathrm{Ind}_B$, separate $\mathrm{Thm}_B\cup\mathsf W$ from $\mathrm{Ref}_B$.
* So Lemma 6.3′, and with it Props 6.3–6.5, hold for every **consistent** decidable $B$ with $\Q\subseteq\Cn(B)$.
* The record's own proof (re-checked; correct) uses $\Sigma_1$-soundness only to get $B\nvdash\sigma_e$. A Rosser-style argument removes it.
* *Fix.* Cite the classical fact, weaken the hypothesis (or keep the proof and add a remark), and do not present the productivity as part of what is new.

**m4. Remark after Prop 4.1.** "For any set $S$ of pairwise $B$-incompatible sentences containing $\psi_D$": $K(S)$ requires $S$ finite (scout F's F10(a) assumes this), or r.e. with $K(S)$ read as the complexity of an index. In the r.e. case the first-proved-member argument still works. State which.

**m5. Cor 4.2 and table rows 8–9: the lottery's hypotheses.**
* N1's Thm E1 needs more than "$\mathcal L$ with a binary relation":
  * a binary symbol not occurring in $B$;
  * numerals that are pairwise distinct in some model of $B$;
  * the equality axioms used in E1(b).

  State them.
* Also make explicit that Cor 4.2(c) applies N1 E2(b) with $X=\Sent_{\mathcal L}$, which E2(b) allows.

**m6. Thm 3.4, upper bound.**
* $M_A^U$ is defined by "all tape-reading programs read as theory machines", a single reading.
* Random decider programs (input $\chi$, yes/no) and random enumerator programs (no input) are read as theory machines in two different ways.
* "A random decider or enumerator program is a theory machine … so $M_A^{{\rm chk},t},M_A^{{\rm gen},t}\le M_A^U$" needs a constant-size wrapper for each reading. Say so. The constant is harmless.

**m7. Thm 7.8(d) has the wrong scope.** "Unpenalised $W^{\rm cons}$ and $M_F^{\rm cons}$ have bounded loss on the sequences of (b) and (c)". But (c) includes the coin literals, all labelled true, on which consistent SOI loses $\ge n$ bits in expectation (Rem 5.4). Restrict (d) to the diagonal sequences of (b) and (c).

**m8. Thm 7.8 omits the hypotheses of Thm 7.4.** Parts (b) and (c) need $\mathcal L\supseteq\mathcal L_{\rm ar}$ and $B$ decidable and true in an expansion of $\mathbb N$. Table row 20 has them; the statement does not.

**m9. Prop 6.1(c): the "computed" status is tautological.**
* In `c1` item (4) the abstention variants are added to the family with weight exactly $2^{-k}$ times their base machines.
* So the checked bound holds by construction: the output reports "smallest ratio 1.000".
* The proof is correct; the computation adds no evidence. Relabel item (4)(c) as "construction checked", or test the bound against a family not built to satisfy it.

**m10. Prop 6.7(a), proof.**
* "The lookup table of a consistent $D$ (as a labeller, …) has positive weight" covers $W^{\rm cons}$ and $M_F^{\rm cons}$.
* For $W^{\rm cl}$ and $M_F^{\rm cl}$ the lookup table is not closed.
* Use its closure, the map (CL): proof search from $B\cup D^\pm$.

**m11. Lemma 1.2.** "(for $\nu^{\rm cl}$: add $(1-\Omega_V)\cdot[\text{the empty labeller is closed}]$)". The bracket is always $0$: $B$ proves tautologies, which the empty labeller leaves undefined. Delete the clause or say so. The same applies to $M_F^{\rm cl}(\emptyset)$ in Cor 3.2, which is covered there by proof search from $B$.

**m12. Lemma 1.3 (CR), the decoding of a candidate $\psi=\neg\varphi'$.**
* "If $\psi=\varphi$ (or $\psi=\neg\varphi$) … answer $1$ iff $F$ halts … with label $1$ (label $0$)." This should say that **both** readings are tested:
  * $F$ labels $\neg\varphi'$ with $1$;
  * $F$ labels $\varphi'$ with $0$.

  This matches the union defining the AI-paper's $A^C_f$.
* If only one reading is tested, the member $(\neg\varphi')^{\wedge(k+1)}$ coming from $f(\neg\varphi')=1$ can be lost, and $\Cn$ is not preserved.
* The construction intended (and the AI-paper's) is correct; the wording is ambiguous.

**m13. $\Cn$ notation.**
* NOTATION §3.1 defines $\Cn(\Gamma):=\{\varphi:B\cup\Gamma\vdash\varphi\}$, with $B$ built in.
* The record writes $\Cn(B\cup\cdot)$ throughout. In Prop 2.2(a) it writes $\Cn(B_L\cup\Gamma_f)$, where $B_A$ must be **excluded**. Under the binding notation this reads as $\Cn(B\cup B_L\cup\Gamma_f)$. That is harmless after intersecting with $\Sent_{\mathcal L}$, but confusing.
* Use $\Cn$ as NOTATION defines it, or declare a local plain closure.

**m14. Credit (against scout L's record).**
* The majority vote at a Lebesgue density point, which turns a positive-measure random machine into a deterministic or computable object, is the de Leeuw–Moore–Shannon–Shapiro (1956) technique. Scout L lists `deleeuw1956computability` for exactly this. It is used in Prop 6.5, Prop 9.2 (derandomisation over all tapes), Prop 9.3 and, through N1 E2(b), Cor 4.2(c). Cite it.
* Thm 10.1 is presented as new (§0 item 10). By scout L's verdict on the sandwich ("near-definitional once the sandwich is proved"), it should be presented as the routine circuit form of the sandwich, not as a separate novelty.
* The remaining novelty claims agree with scout L §5.2–§5.3:
  * one-tape equivalence with consistent SOI: "new";
  * Presburger separation: "new application";
  * Craig collapse: "construction known; Bayesian equivalence new".

**m15. Transfer table §5.5, rows "Prop 4.7" and "Thm 5.1 (a)".** "Yes, to coin-per-atom theory machines" refers to an SAI analogue of $M_{\rm prod}$ that the record never defines. Either define the mixture over coin-per-atom theory machines and check that Thm 5.1's maps preserve that class, or mark these rows "(p)".

**m16. Rem 6.6.** The example "on the two inputs $\varphi,\neg\varphi$ … the consistent outcomes are $(1,0)$ and $(0,1)$" needs $\varphi$ independent of $B$. If $B$ decides $\varphi$, one of these outcomes is inconsistent too. Add the hypothesis.

**m17. Prop 6.8(c), the instance "monadic languages with $B=\emptyset$".** Say "monadic predicate languages without function symbols", where consistency of finite sets is decidable. With two unary function symbols it is not.

**m18. Verification log.** Record that the four scripts were rerun by this referee (below). Update §14 with m2.

**m19. A dropped additive constant: Prop 7.6(b).**
* "Unpenalised $W^{\rm cons}$ (and $W$) has loss $\le|u|$" drops two constants:
  * the cost of turning the assigner $u$ (a U-format program in the AI-paper) into a $V$-program for a labeller index;
  * the $\log W(\emptyset)$ term of the loss.
* Write $\le|u|+c$.
* Thm 7.8(d) and table row 22 inherit the statement. There it is already "bounded" or "constant", so nothing else changes.

---

## What was checked and found correct (summary)

* **Lemma 1.2 and the $(1-\Omega_V)$ terms.**
  * Checked against P1 Thm 3.8: $T_U=\{(x,pw,y):p\in\dom V,(x,w,y)\in T_{V(p)}\}$. P1 Prop 3.7 gives an effective enumeration of all function machines, so every index is a machine.
  * On program-less tapes $f_\omega$ is empty and $A_\omega=\emptyset$.
* **Lemma 1.3.**
  * (PS): the runs are deterministic in the bits read. It needs $B$ decidable, which is assumed.
  * (EM) is correct.
  * (CR): runs are bounded by $m-1$ steps. There are at most two parsing candidates, because the left conjunct of a right-nested power is unique. $\Cn$ is preserved (modulo m12).
  * (CL): $\bar f(\varphi)=b\iff B\cup\Gamma_f\vdash\varphi^b$, which gives closedness.
* **Thm 2.1.**
  * The four maps are computable on all indices and injective with constant overhead.
  * The three-way weights hold because closed labellers and their emitted theories decide alike.
  * The loss statement uses the semimeasure convention. Per step in the normalised convention the factor is $2^{\pm2c}$, as table row 1 says.
* **Thm 3.1.**
  * Both mixture inequalities hold (written out with (1.1)). The $(1-\Omega_V)[B\vdash\psi_D]$ term is absorbed by the proof-search labeller of $B$.
  * $D=\emptyset$: both values lie in $[1-\Omega_V,1]$.
  * (b) holds through (CR) on every tape.
* **Cor 3.2.** Correct, including the program-less tapes.
* **Thm 3.4 and Prop 3.5.**
  * Under (S$_{\rm tape}$), the padded decider's time is uniform in $\omega$, and $t\ge m^{a^*}$ covers $\alpha(|q_F|+1)+3\alpha(|\chi|+1)^{a'}$.
  * Each tape carries one padded copy per detection.
  * Class-by-class: the padded hypothesis has the same $\Cn$ on every tape.
  * The upper bound is subject to m6.
* **Prop 4.1.**
  * (iii) uses $K(D)\le K(\dom D)+K(D\mid\dom D)+O(1)$, valid for prefix complexity, and P1 Thm 3.21(a) as stated there ("for every data set $D$").
  * (iv): stored-prefix labellers are consistent whenever $w$ has a consistent extension. P1 Prop 4.6(a)'s count restricts correctly to such $w$.
* **Cor 4.2.** Correct given N1 E1 and E2(b), both re-read; E2(b) is exactly the majority-vote argument. Subject to m5.
* **Thm 5.1.**
  * The model-expansion argument for the consistency of literal sets (interpret $R$ at the distinct $t_x$) is correct, and so is (Lit).
  * The three-way weights on a literal query are correct.
  * Cor 5.2(a)–(d) match P1 Thm 4.9, Cor 4.10, Props 4.5 and 4.6 as printed in `versions.tex`.
  * Prop 5.3 is P1 Rem 4.12(2), transferred. $\delta_D\ge-O(1)$, since $K(D^{\rm str}\mid\dom D^{\rm str})\le|D|+O(1)$.
* **Prop 6.1.**
  * (c): $s\mapsto rq_\chi s$ is injective and the domain of the two-block reader is prefix-free. Restriction preserves consistency.
  * On one tape, $D=\emptyset$ is covered by the program-less tapes.
* **Lemma 6.3′.** Re-checked line by line: both searches fail, so $\sigma_e$ is a false $\Sigma_1$ sentence, unprovable by $\Sigma_1$-soundness, unrefutable and outside $\mathsf W$. Correct as stated; see m3 for the weaker hypothesis.
* **Prop 6.3.** $I_n$ is a finite union of r.e. sets, so it has an index (non-uniformly in $n$, as the statement allows). The tail is $\Omtail{n+1}$ in P1's convention.
* **Prop 6.5(b), the delicate step.**
  * $C_p$ (three-valued consistency) is closed, since its complement is open.
  * The density decomposition and the bound $\le2\varepsilon$ on each $p$ are correct.
  * $J_w\subseteq\mathrm{Ind}_B$ holds because $\varepsilon2^{-|w|}>\Unif([w]\setminus C_p)$.
  * $J_w$ is r.e. uniformly in $(p,w,\varepsilon)$.
  * The final sum is $\le2\varepsilon\Omega_V+\Omtail{n+1}$.
* **Prop 6.7(a), (b).**
  * (a): the support argument, and the instantiation through $\neg\mathrm{Halt}_e$ (co-r.e.-complete set of consistent singletons) and Church's theorem.
  * (b): $F_\alpha$ is inconsistent with probability exactly $\alpha$ (it uses equality: $\exists x\,x\neq x$ is refutable). The rest of the inconsistency probability is left-c.e., and $\alpha=\Omega_V$ gives the contradiction.
* **Prop 6.8.**
  * (a): PS and EM preserve consistency on every tape.
  * (c): the filter's outputs form an initial segment of the event order. Compactness gives consistency on every tape, $F'=F$ on $F$'s consistent tapes, and the index map is computable.
* **§7.**
  * The restatements match the AI-paper's printed statements (Thm 6.3 `thm:time:equiv`, Props 6.4 and 6.5, E.17 `prop:time:bounded`), which I re-read.
  * Thm 7.8(a): the constant $c_1+c+c_\bot$ is correct.
  * Thm 7.8(b): $P:=(M^{{\rm all},\tau}_F+2^{-|D|})/2$ satisfies $q_0+q_1\le1$ and is computable when tails are computable. The loss conversion is $\ge n-0.361-1$.
  * Thm 7.8(c): P1 Def 9.1 has only "computable weights, $\sum w_i\le1$", and the record correctly adds computable tails as a hypothesis.
* **Prop 9.1.**
  * The coin-free argument: compatibility is inherited by prefixes, and dominated convergence yields one clocked $f$ that labels all sentences, hence a decision procedure.
* **Prop 9.2.**
  * The density point plus a majority over all $2^{\tau(m)-|u|}$ tape completions gives deterministic time $2^{\tau(m)}q(\cdot)\le2^{2^{cm}}$ for $c'<c$.
* **Prop 9.3.** The logic is correct given (B*) and (SGL) (see m2).
  * (SGL) in time-bounded form is standard. With $r=O(T\log T)$ random bits after amplification, Lautemann's $\Sigma_2$ machine runs in time $O(T^2\log^2T)$, so $\kappa=3$ suffices.
* **Thm 10.1.**
  * (i), consistency: in the free term algebra with $\mathrm{Bit}$, $\mathrm{Gate}$ and $R$ as defined, all axioms hold. The second output axiom holds because $V$ is consistent. The coincidence $n_i=g_i$ as terms is harmless, since the two kinds of term only ever occupy the first argument of different predicates.
  * (i), derivation sizes: $O(s(\log s+d+k)+(d+k)^3)$ is correct.
  * (ii): (F1) holds trivially for a set of sentences; the checker is polynomial.
* **Cor 10.2.**
  * The prior sums to at most $1$. The exception gadget has at most $2d+2$ gates, is consistent and is injective for fixed $(a,b)$.
  * The prior-ratio bound $w(V')/w(V)\ge2^{-\Gamma_N(s)}$ was verified exactly by `referee_code/rA1_gadget_ratio.py`, including the corrected factor $\log_2(\gamma+1)$ for $k$. The smallest slack is $2.32$ bits over $333{,}720$ cases.
* **"Possible error in the author's view: none".** Consistent with `prior/hanni-solomonoff-axiom-induction.md`. The author conjectured proof-requiring SAI $\equiv$ consistent SOI; this holds. The author's consistency argument for the schema ("a model of the phis alone would be a model of the added sentences") is the known one-sort failure (AI-paper Prop 6.5), already recorded and agreed.

---

## Verification log

**Read in full.**
* `notes.md` (all 629 lines) and `00-brief.md` of this thread.
* The project brief `research/00-brief.md`.
* `NOTATION-draft.md` §0–§5.
* The scripts' docstrings, and `c1` item (4)'s implementation and output.

**Sources re-read for the cited results.**
* P1, `sections/setting.tex`: Def 3.6, Prop 3.7, Thm 3.8 with eq. (1), Thm 3.21, Prop 3.24.
* P1, `sections/versions.tex`: Thm 4.4 to Rem 4.12, in full.
* P1, `sections/comp.tex`: Def 9.1, Thm 9.2, Prop 9.4, Cor 9.5.
* The AI-paper:
  * `time.tex`: Thm 6.3, Props 6.4, 6.5, Thm 6.9, Cor 6.17;
  * `app-time.tex`: Prop E.17 with its proof, the definitions of readings (a1), (a2), (b), (b2), and Prop E.23(a) with its proof (the basis of M1), plus `main.aux` labels.
* Scout F: F1–F10, in particular F3(b) and F10(a).
* Scout N1: Lemma E0, Thm E1, Prop E2.
* Scout L: §0, §3.7–§3.8, §5.1–§5.3 (novelty verdicts).
* The author's note `prior/hanni-solomonoff-axiom-induction.md`, the conjecture and the schema argument.

**Proofs attempted to refute.** Every claim marked proved in §1–§10, line by line, for each of the following:
* quantifiers;
* the empty data set;
* $(1-\Omega_V)$ terms;
* injectivity and computability of the index maps on all indices;
* pathwise versus machine-wise consistency;
* the theory to which "proves" refers;
* equality, (Lit), compactness;
* the hypotheses of the cited P1 and AI-paper results.

Two statements are stronger than their proofs (M1, M2). No proof of a core result failed.

**Scripts rerun.** `c1`–`c4` were copied to the scratchpad and run with `python3 -I`. All exited 0, and all four `.out` files were **byte-identical** to the saved ones (checked with `cmp`).

**Referee code.**
* `referee_code/rA1_gadget_ratio.py` is deterministic. Its output is saved as `referee_code/rA1_gadget_ratio.out`.
* It does an exact evaluation of the Cor 10.2 prior ratio over $d\le24$, $s\le4096$ (grid), $k\in[0,2s]$ (grid), and gadget sizes $1..2d+2$.
* Result: the bound holds in all $333{,}720$ cases, with smallest slack $2.32$ bits.

**Web verification.** The search results listed under Sources at the end of this report.
* *Fischer–Rabin 1974.* The abstract's statement (universal constant $c$, every nondeterministic procedure, all sufficiently large $n$, $2^{2^{cn}}$; the proof-length clause) was confirmed from search-result abstracts (HUJI CRIS listing, MIT DSpace TM-43, secondary summaries). Direct page fetches failed (DNS), and the full text was not seen.
* *Berman 1980.* The bibliographic data were confirmed (*TCS* 11(1):71–77, Utah TCS bibliography). Completeness for $\mathrm{STA}(*,2^{2^{n^{O(1)}}},O(n))$ was confirmed only through secondary sources. The linear-exponent $\Sigma_2$ form (B*) was not confirmed.
* *Effective inseparability of provable and refutable sentences* for consistent c.e. extensions of $\Q$: confirmed through secondary sources (Sorbi, CiE 2021 slides; arXiv:2210.17333). The exact location in Smullyan (1961) was not seen.

**Not done.**
* No proof assistant was used.
* The AI-paper's Thm 8.1 constants and the SD records were not re-derived. They were outside the thread's new material and were re-checked by the thread itself.
* (S$_{\rm tape}$) was not checked for a concrete machine. It is an assumption in the record, correctly labelled.

**Sources (web).**
* [HUJI CRIS listing, Fischer–Rabin](https://cris.huji.ac.il/en/publications/super-exponential-complexity-of-presburger-arithmetic/)
* [MIT DSpace TM-43](https://dspace.mit.edu/handle/1721.1/148872)
* [Rybalov slides](https://web.stevens.edu/algebraic/Files/Presentations/Rybalov_presburger.pdf)
* [Springer abstract (generic-case complexity)](https://link.springer.com/doi/10.1007/s00224-008-9120-3)
* [Utah TCS bibliography, Berman 1980](https://ftp.math.utah.edu/pub/tex/bib/idx/tcs1980/11/1/71_77.html)
* [Haase, notes on Presburger complexity](https://www.cs.ox.ac.uk/people/christoph.haase/home/publication/haa-18/haa-18.pdf)
* [Klaedtke, arXiv cs/0506008](https://arxiv.org/pdf/cs/0506008)
* [Sorbi, CiE 2021 slides](https://people.math.wisc.edu/~lempp/conf/CiE21/Sorbi.pdf)
* [Cheng, arXiv:2210.17333](https://arxiv.org/pdf/2210.17333)
