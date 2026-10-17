# Thread brief: sfi (kind: math)

**Title.** The relation to Solomonoff operator induction (SOI), with the time-bounded equivalences and separations. (The folder key is `sfi`; write SOI in the record, per the brief's naming section.)

**Read first.** `../../00-brief.md`, `../../NOTATION-draft.md` (binding; note §2: SOI's function machines $T$ are written $F$ here), `../../select.md`, and scout S's record `../../scouts/sfi/notes.md` §0–§2 and §4–§6 (its §3, the theoretician's dilemma, belongs to `terms`). Also scout F §1, §3.3 (F8, F9), scout N1 §3.4 (E2 for SOI) and §8. Sources: the AI-paper `../../../../axiom-induction/paper/sections/{time,app-time}.tex` (§6, App. E) with `main.aux` for printed numbers; the refereed records `research/tracks/{model,time-followup,short-derivations}/notes-final.md`; SOI Paper 1 `../../../../solomonoff-function-induction/paper/` (`setting`, `versions`, `learn`, `comp`) and its `NOTATION.md`; `../../../../solomonoff-operator-induction/research/paper-review/rename/RENAME.md` (naming).

**Deliverable.** `tracks/sfi/notes.md`, scripts in `tracks/sfi/checks/`, ending with a Verification log.

---

## Goal

State and prove, in this paper's notation, exactly how axiom induction relates to SOI, version by version, and how the relation behaves under time bounds and charged deduction. The author asked for "the relation to SFI; the time-bounded equivalences". Most results exist in refereed form (the AI-paper's §6 and its records) or in scout S's first pass. The thread must:
1. **re-verify** every transcribed result against its source (read the proof, not only the statement), and restate it with its exact hypotheses and constants;
2. **restate** the earlier results for the objects of this paper (one-tape $M_A$, coin-free $W_A$, Kolmogorov $K_A$; one-tape $M_F$, $W$, $K_F$), saying for each where the earlier report's slogan "axiom induction ≡ consistent function induction" holds and where it must be qualified;
3. **complete** the new results scout S started and the proof sketches it left;
4. deliver the paper's **table of equivalences and separations**.

## Targets

**T1 (core) Dictionary and mixture decompositions.** Scout S §2.1: consistent and closed labellers; the coin-free and one-tape versions on both sides; the decompositions (2.1), (2.2) of $M_F^{\rm cons}$ and $M_A$ with the $(1-\Omega_V)$ term.

**T2 (core) Coin-free equivalence.** Scout S Thm 2.4: (a) $W_A^{\rm dec}\asymp W^{\rm cons}$ and $W^{\rm cons}\asymp W^{\rm cl}$ (the latter within $2^{-c}$ below); (b) $K_A=K_F^{\rm cons}\pm c$; (c) the three-way outcome weights (prove / refute / neither) agree with closed labellers within $2^{\pm c}$. Remarks: enumerators need no Craig; steeper priors $2^{-\lambda|p|}$ give factor $2^{\lambda c}$. Re-check AI-paper Thm 6.3's proof (Craig's padded conjunction powers; injectivity of the maps). Also restate briefly, with the AI-paper's proofs re-checked, the status of Hänni's schema "Acc$_f(\ulcorner\varphi\urcorner)\to\varphi$": works with two sorts (AI-paper Prop 6.4, TF Prop 2.4(b1)), fails in one sort over $\PA$ (Prop 6.5), repaired by bounded witnesses (Prop E.17), and the template results (Props 6.6–6.7). This is the author's conjectured equivalence; say in one sentence how the one-tape version avoids the schema (scout F's remark after F8).

**T3 (core) One-tape equivalence.** Scout S Thm 2.5 (= scout F's F8): $M_A\asymp M_F^{\rm cons}\asymp M_A^{\rm dec}$ on nonempty $D$, tape by tape. Then the **penalised one-tape version** (scout S's remark after Thm 2.5, a proof sketch): padding by the work counter tape by tape, so that membership stays polynomial on every tape. Write out the machine assumption (S) for tape-reading machines and prove it, or state exactly what remains.

**T4 (core) Chain and the random tape.** Scout S Prop 2.6: $2^{-K_F^{\rm cons}}\le W^{\rm cons}\le2^cM_F^{\rm cons}\le2^{K(\dom D)+c}2^{-K_F^{\rm cons}}$ and the $\Kpad$ bound on $\log(M_F^{\rm cons}/W^{\rm cons})$; the same for $M_A$, $W_A$, $K_A$. Add one sentence citing `logic` T1: on the lottery stream the one-tape loss is bounded and the coin-free loss is not, for both SAI and consistent SOI (not possible in plain SOI: `logic` T1, N1's E2(b)).

**T5 (core) Transfer principle: SAI is SOI on positive literals.** Scout S Thm 2.7 (= scout F's F9) and Cor 2.8: $K_A=K_F\pm c$, $W_A\asymp W$, $M_A\asymp M_F$ on literals of a fresh predicate, under the stated hypothesis on $B$. Then go through P1's results systematically and **produce a table**: which P1 results transfer (those stated up to additive constants in $K_F$, $-\log W$, $-\log M_F$ on binary labels), which do not (normalised-convention results, results with $\mathcal Y$ larger than two labels, results about private randomness, $M_{\rm pq}$), and why. Include P1's Solomonoff-induction fragment (SI ⊂ binary SOI ⊂ SAI on atomic data). Re-derive the reading of AI-paper Prop E.1 as an encoding effect (scout S, end of §2.4). Check scout S's own correction of Cor 2.8(b) (two-point data only) against P1 `prop:versions:tape` and `rem:versions:Wrate`.

**T6 (core) What breaks.** Scout S Prop 2.11 (logical closure; SOI's $\bot$ mixes independence with laziness; agreement only with closed labellers), Rem 2.11′ (three outcomes form a measure for SAI), Prop 2.12 (an observed independent label: one-sided equivalence, unbounded gap on one datum; check the use of the recursion theorem and of AI-paper Lemma E.14 line by line), Rem 2.13 (shared versus private randomness), Rem 2.15 (no lower semicomputability). Attempt Rem 2.14 (is $M_F^{\rm cons}/M_F^{C}$ bounded, pathwise versus machine-wise consistency?); report proved bounds and leave it open if not settled.

**T7 (core) Time bounds with free deduction.** Restate and re-verify, in this paper's notation:
* TF Thm 2.2 / AI-paper Thm 6.14: penalties on checking or generating axioms leave $W_A\asymp W^{\rm cons}$ intact (strict, delay and cumulative forms; $t\ge m^{a^*}$; under (S));
* TF Prop 2.3: Kt penalties cost $\log(|f|+1)+O(1)$;
* TF Thm 3.1 (general domination lemma) and Thm 3.2 / AI-paper Thm 6.15 (diagonal: every computable predictor loses $\ge n-0.361$ on a computable arithmetic sequence on which $W_A$, $W_A^{{\rm chk},t}$, $W_A^{{\rm gen},t}$ lose $O(1)$); TF Prop 3.4 (incomparability via coin literals); TF Prop 4.1 (the constant-size evaluator: the separation comes from free deduction, not from axioms);
* TF Prop 5.1 (disguised assigners);
* scout S Thm 2.9: the one-tape transfers and P1's time-bounded mixtures $M_{\rm len}$, $M_{\rm rd}$ (incomparable with SAI).

**T8 (core) Charged deduction.** Restate and re-verify the sandwich (AI-paper Thm 6.16; TF Thm 4.2; SD Lemma 2.2, Cor 2.3, Thm 3.1): derivation-charged SAI is certificate SOI $W^{\rm cert}$ up to constant description length and polynomial budget changes; the fit classes at polynomial budgets (AI-paper Cor 6.17; SD Cor 3.2, Thm 4.2, Cor 4.4, Prop 4.12): NP ∩ coNP under total material (b), EXPTIME under (a1), every decidable set under (a2), (b2); the soft version (SD Thm 5.2, Prop 5.3); the role of (F1) (SD §7). State clearly that these readings charge derivation size but not the search for a derivation (the nondeterminism is free). One sentence pointing to `shape` T5 for what this means for the textbook point.

**T9 (core) A natural separation: Presburger arithmetic.** Scout S Prop 2.10 (coin-free clocked consistent SOI with $\tau\le2^{2^{c'm}}$ has unbounded loss on the length-lexicographic presentation of Th(ℕ, 0, 1, +), while $W_A$ has bounded loss) and Prop 2.10′ (one-tape, $\tau\le2^{c'm}$, by Lebesgue density and derandomisation). Verify Fischer–Rabin 1974 by WebSearch: the exact statement of the nondeterministic lower bound, its constant, and the proof-length clause for "easily recognised" axiomatisations. **Extension:** the one-tape doubly-exponential case (scout S's conjecture; route via Sipser–Gács–Lautemann and a lower bound for alternating machines with few alternations, Berman 1980). Prove it, or state precisely which published lower bound would finish it and whether it is verified.

**T10 (extension) Circuit analogue of the sandwich.** Scout S §4 item 8: axiom sets of size $s$ with derivation budget $\ell$ on $d$-bit literals correspond to nondeterministic (NP ∩ coNP-type) verifier circuits of size poly$(s,\ell,d)$. Prove both directions with explicit polynomials and a gate-indexing scheme that keeps the language finite, or leave a precise proof sketch. If proved, check whether P1's circuit-Bayes theorem (`thm:comp:circuitbayes`) transfers with nondeterministic circuit size.

**T11 (core) The table.** Rewrite scout S §5's table in the shared notation: every row with the pair compared, the relation, the overhead, the hypotheses, the status after your verification, and the source (AI-paper number, TF/SD item, scout S item, or this thread's item). Rows on the theoretician's dilemma (scout S rows 20–22, 25–28) are cited from `terms`.

## What is known (references to verify)

Craig 1953; Fischer–Rabin 1974; Presburger 1929; Berman 1980; Sipser 1983, Gács, Lautemann 1983 (BPP in the polynomial hierarchy); Cook–Reckhow 1979; Chandra–Kozen–Stockmeyer 1981; Kleene's recursion theorem; MRDP; Solomonoff 1999, 2008 (operator induction; read in full for the SOI rename, see `RENAME.md`); Levin 1973; Schmidhuber 2002 (speed prior). Scout S §7 and scout L record the verification levels.

## What to verify computationally

* An **independent** finite analogue of the one-tape equivalence and of Prop 2.11 (do not copy scout S's `s1_onetape_toy.py`; compare outputs).
* A finite toy of Prop 2.12's mechanism where possible (e.g. a finite family of "labellers" that must commit to $\iota$ against theories that certify independence on a finite propositional fragment).
* For T9, a small numerical table of the constants: for which $m$ the bound $2^{\tau(m)}\,q(C\tau(m)+m)<2^{2^{cm}}$ holds for illustrative $c'$, $c$.
* For T10, if attempted, a brute-force check of the circuit-to-axioms translation for tiny $d$.

## What this thread must NOT do

* Not the theoretician's dilemma: scout S §3 (Thm 3.1, Lemma 3.2, Thm 3.3, Cor 3.4, Prop 3.5, Prop 3.10, Thm 3.12, Cor 3.13) belongs to `terms`. Cite it.
* Not the basic theorems of the versions ($K_A$/$W_A$/$M_A$ chain with $K(\text{question})$ slack, the direct no-coding-theorem proof): `fundamentals` T6. Here the chain is for the consistent SOI versions and the transfer.
* Not the lottery or $\Pi_1$ phenomena (`logic`), and not the reasoner-relative reading of charged deduction (`shape`).
* Do not re-prove the refereed results from scratch where the source proof checks out: re-verify, restate, and cite. Spend the effort on T3, T6, T9, T10 and the table.
