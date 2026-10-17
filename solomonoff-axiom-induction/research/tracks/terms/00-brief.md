# Thread brief: terms (kind: math)

**Title.** Theoretical terms: Craig, Ramsey and the theoretician's dilemma in axiom induction.

**Read first.** `../../00-brief.md` (in particular the seed ideas "Craig's theorem and the theoretician's dilemma" and "Theoretical terms and succinctness", and the ladder in "Existing language"), `../../NOTATION-draft.md` (binding; note the renames of §3.4 and §6.3: free term algebra $\mathfrak T$, pairing model $\mathfrak U$, $\mathrm{Inf}_n$, $\iota_f$), `../../select.md`. Then scout S's record `../../scouts/sfi/notes.md` **§3** (all of it) with `checks/s2_craig_blowup.*` and `checks/s3_vocab_ontology.*`; scout N1's record `../../scouts/novel-logic/notes.md` **§5** (B1–B4) and N8, with `checks/c2_finite_models.*`; scout P §5 Q3 (Prop 5.1, bipartite factoring); scout F's F6, F7, F7′; scout L §3.8 and §5.1 rows 1–2. Sources: the AI-paper and its records SD and TF (`../../../../axiom-induction/research/tracks/{short-derivations,time-followup}/notes-final.md`) for the readings (a1), (a2), (b), (b2) and the constructions SD Props 4.3, 6.1, 4.12.

**Deliverable.** `tracks/terms/notes.md`, scripts in `tracks/terms/checks/`, ending with a Verification log.

---

## Goal

Answer, with theorems, the question behind ladder step 3 and Hempel's theoretician's dilemma: **in which hypothesis classes do theoretical terms pay, and what exactly is it that pays: vocabulary, relations, or entities?** The scouts found a sharp and, by scout L's search, new picture:
* in the universal class with free deduction, theoretical vocabulary costs $O(1)$ (Craig inside the prior), and the r.e. class already contains theoretical apparatus (N1's B3);
* Craig's own construction is useless under charged deduction (it writes run times in unary), but vocabulary can be eliminated at polynomial cost in other ways, by storing content in objects no observational term names;
* what cannot be eliminated, for finite theories, is theoretical relations *or* theoretical entities: finite theories in the observational vocabulary about the named objects, even with unary theoretical predicates, fit exactly the regular regularities;
* with free deduction but finite theories, theoretical functions or sorts pay without bound (infinity; PA).
The thread must turn this into a verified, complete set of statements with full proofs, and one clean theorem for the paper.

## Targets

**T1 (core) Hempel's horn: vocabulary costs $O(1)$.** Scout S Thm 3.1: restricting axioms to $\mathcal L_O$ changes the weight of every observational content, the class-level posterior odds, the predictive probabilities of observational sentences and the cumulative loss by at most a constant, also under penalties on checking or generating axioms ($t\ge m^{a^*}$, under (S)), and for one-tape $M_A$. Relate to `fundamentals` T4 (F7′, translation invariance) without duplicating it: F7′ is the inclusion case; T1 is the class-level and penalised version.

**T2 (core) Craig's construction in practice.** Scout S Lemma 3.2 (canonical proof search takes $\ge2^{d}-1$ steps; every derivation of a literal datum from the Craig set of a literal labeller contains a line of size $\ge2^{d}|\varphi_w|$; the Gödel-number padding variant), Thm 3.3 (run-padded observational axiom sets with polynomial membership fit exactly P under each of the readings (a1), (a2), (b), (b2) at polynomial budgets), Example 3.6 (computed), Cor 3.4 (the table; the separations under (a1) and (a2)/(b2) are unconditional; under (b) the separation holds iff NP ∩ coNP ≠ P). Re-check SD Prop 4.6(i), which Lemma 3.2(b) uses.

**T3 (core) Eliminating vocabulary at polynomial cost.** Scout S Prop 3.5 (proof padding under reading (b): observational certificate axioms at $+O(1)$ description length and polynomial derivation size, given TF Thm 4.2 under (F1)); Lemma 3.9 (the pairing gadget: $\mathrm{Pair}(z):=\mathtt s_1\mathtt s_1z=z$, $\mathrm{Std}$, $\theta_k$, the model $\mathfrak U$); Prop 3.10(a) (ground pairing translation of SD's alternating axioms: observational, parameter-free, polynomial membership, MP derivations; fit class EXPTIME under (a1) at polynomial budgets) and (b) (finite observational theories, readings (a2) and (b2): every decidable $X$; under (b) NP ∩ coNP; under (a1) at least PSPACE). **Write out the machine normal form** that scout S marked "standard; not written out" (read-only binary input and certificate tapes, block-coded work tape in SD's normal form), so that Prop 3.10(b) is fully proved.

**T4 (core) Vocabulary or ontology.** Scout S Thm 3.12: (a) a finite theory in $\mathcal L_O$ plus unary theoretical predicates, with a model whose $\{\mathtt e,\mathtt s_0,\mathtt s_1\}$-reduct is $\mathfrak T$, that proves every literal datum of $X$, forces $X$ regular (via the MSO translation, Rabin 1969, and the reduction from node sets to word automata proved there); (b) every regular $X$ has such a finite theory in $\mathcal L_O$ with linear derivations. Verify Rabin's theorem in the form used (MSO on the full binary tree ⇔ Rabin tree automata) against a primary or textbook source. Rem 3.11 (one theoretical relation of arity 8 over the named objects fits every decidable $X$; infinite observational hypotheses about the named objects fit P, ⊇ NP ∩ coNP and some EXPTIME-complete sets under (a1)). **Extension, high priority:** scout S Q3.15, whether **one binary** theoretical relation suffices over the named objects (proof sketch in Rem 3.11 via a two-stack machine); prove it, so that Cor 3.13's "relation" row needs only arity 2. Cor 3.13 (the 2×3 table of fit classes of finite theories).

**T5 (core) Free deduction, finite theories.** Scout N1 §5:
* B1 (infinity): Lemma B1.1 (quantitative finite model property of monadic logic, by Ehrenfeucht–Fraïssé: a consistent sentence with $k$ predicates and quantifier rank $q$ has a model of size $\le2^k\max(q,1)$), then $K_{\rm fin}^{\mathcal L_{\rm mon}}(D_n)=\min_{m\ge n}K(m)\pm c$ on the data $\mathrm{Inf}_n$, $O(1)$ with one unary function symbol ($\iota_f$), the posterior over finite theories moving to theories that use $f$, and $O(1)$ for the r.e. inducer;
* B1′ (literal symbol count: linear in pure equality, between $\log n-\log\log n$ and $O(\log^2n)$ monadic, constant with $f$; check the binary-counter sentences $\mathrm{Cnt}_k$);
* B2 (PA's theorems as data: no consistent $\mathcal L_{\rm ar}$-sentence proves every PA axiom, by reflexivity and Gödel's second theorem, so $K_{\rm fin}^{\mathcal L_{\rm ar}}\to\infty$; ACA$_0$ in the two-sorted language, or a truth predicate over $\mathrm I\Sigma_1$, gives $O(1)$; ACA$_0$ adds no first-order content). Verify: reflexivity of PA (Mostowski 1952; Kreisel–Lévy 1968), ACA$_0$ finitely axiomatisable and conservative over PA (Simpson, *Subsystems of Second Order Arithmetic*), $\mathrm I\Sigma_1$ finitely axiomatisable; or give self-contained proofs where the literature cannot be checked;
* **B3 (Kleene-type, write the full proof):** r.e. axiom induction in $\mathcal L$ equals finite-theory induction in a three-sorted $\mathcal L^+$ (numbers, assignments, satisfaction) up to $O(1)$: $K_{\rm fin}^{\mathcal L^+}=K_A^{\mathcal L}\pm c$, $W_{\rm fin}^{\mathcal L^+}\asymp W_A^{\mathcal L}$. Compare with Kleene 1952 and Craig–Vaught 1958 (verify their statements);
* B4 (the one-tape failure of B3 on the lottery stream): cite `logic` T1, do not re-prove the lottery.

**T6 (core) Ramsey and Craig side by side.** On the infinity example: the Ramsey sentence $\exists f\,\iota_f$ is one existential second-order sentence with the same first-order $\{=\}$-consequences as $\{\mathrm{Inf}_m:m\ge1\}$; Craig gives an infinite first-order axiomatisation; no finite first-order observational theory exists. Scout P's Prop 5.1 (a factoring predicate saves $nm-(n+m)$ implications in the atom-to-atom format, only a constant factor in full first-order logic) and the reuse remark. Place these in one hierarchy table: *hypothesis class → do theoretical terms pay on observational data → which apparatus → where proved* (scout N1 §5.1's table merged with scout S Cor 3.13), with a row citing `shape` T3 for usability by a weak reasoner.

**T7 (core) The dilemma theorem.** One clean statement for the paper, scout S §3.7 revised: (i) in principle (free deduction) vocabulary costs $O(1)$; (ii) Craig's construction and every run-padded axiomatisation fit exactly P at polynomial budgets; (iii) vocabulary can be eliminated at polynomial cost under every reading, by storing the content in unnamed objects; (iv) finite theories need a polyadic theoretical relation or theoretical entities, either one suffices, unary predicates never; (v) with free deduction and finite theories, theoretical functions or sorts pay without bound. Then a short precise paragraph "what this does and does not show" about the classical reply to Hempel, including scout S's correction of the brief's seed (the separations make the reply a theorem only about Craig's construction, not about theoretical vocabulary). The philosophical discussion itself belongs to `philosophy`; keep this paragraph to what the theorems say.

**T8 (extension, in this order).**
1. N8: speed-up from conservative theoretical extensions for finite theories (ACA$_0$ over PA, NBG over ZF) and the consequence for derivation-charged finite-theory inducers; verify the speed-up results (Pudlák 1998 survey; Gödel 1936; any specific ACA$_0$/PA or NBG/ZF speed-up theorem) before claiming more than a proof sketch.
2. Scout S Q3.18: is the finite observational theory $T^O_M$ conservative over $\Gamma_{f_V}$ for all $\mathcal L_O$-sentences?
3. Scout S Q3.19: richer observational languages (a binary observable relation), where the MSO argument fails.
4. Scout S Q3.16, Q3.17 (fit classes under (a1) of infinite hypotheses about the named objects; finite observational theories and EXPTIME).

## What is known (references to verify)

Craig 1953, 1956; Craig–Vaught 1958; Kleene 1952; Hempel 1958; Putnam 1962, 1965; Ramsey 1931; Lewis 1970; Niiniluoto 1972, Niiniluoto–Tuomela 1973, Hintikka 1970; Rabin 1969; Ehrenfeucht 1961, Fraïssé 1954, Löwenheim 1915; Ryll-Nardzewski 1952; Montague 1961; Mostowski 1952; Kreisel–Lévy 1968; Simpson 2009; Chandra–Kozen–Stockmeyer 1981; Fischer–Rabin 1974; Gödel 1936; Pudlák 1998. The theoretical-terms literature in inductive logic (Niiniluoto–Tuomela) and ILP predicate invention (Muggleton–Buntine 1988) are the closest antecedents (scout L §5.1); say precisely how the results differ.

## What to verify computationally

* Re-run scout S's `s2` and `s3` and scout N1's `c2` on scratch copies; compare outputs.
* **Independent** checks: the pairing lemma and the truth of $A^O_M$ in $\mathfrak U$ on a fresh machine; the signature theories of Thm 3.12(b) for two further regular languages; the colliding-residuals count for a non-regular language; Lemma B1.1 on random monadic sentences with three predicates.
* If T4's arity-2 construction is proved: implement it for a small decider (e.g. EQ) and check derivations of all data with $|w|\le8$, with negative controls.

## What this thread must NOT do

* Not re-prove the time-bounded equivalences, the sandwich or the fit classes of all hypotheses (`sfi` T7–T8; SD); cite them.
* Not usability of intermediate concepts by weak deterministic reasoners (`shape` T3); cite it in the hierarchy table.
* Not the lottery (`logic` T1).
* Not the philosophical assessment of Hempel, Putnam and the ladder beyond the T7 paragraph (`philosophy`).
