# Paper 1: consistency and arXiv-readiness review

**Paper.** "Solomonoff Function Induction: Definitions, Versions and Basic Theorems" (Kaarel Hänni), `paper/main.pdf` built 2026-10-12 16:59 (103 pages), sources `paper/sections/*.tex`, `paper/bib/*.bib`.
**Scope of this review.** Consistency of the front and back matter with the body, notation, statuses against `CLAIMS.md`, a complete plan for the arXiv conversion, verification of every bibliography entry, structure and length, readability. The mathematics of the body is reviewed separately (`review-p1-math-A.md`, `review-p1-math-B.md`); this review uses the body's statements as given.
**Rules applied.** The three binding notes at the top of `paper/OUTLINE.md` (authorship and disclosure; standard academic paper for arXiv; no "Wyeth's objection"). Sources of claims: `research/tracks/{foundations,history,examples,context,steeper}/notes-final.md` and `research/00-brief.md`.
**Independent checks** (all in `research/paper-review/scratch/p1-arxiv/`):
`extract_status.py` → `envs.json`, `envs.txt` (every theorem-like environment with label, `\status`, `\src`); `compare_status.py` → `compare_status.out` (paper statuses against `CLAIMS.md`); `process_vocab.py`, `process_vocab_filtered.md` (process vocabulary in the visible text, with `\status`, `\src` and comments stripped); `conversion_table.py` → `conversion_table.md`; `bibcheck-log.md` (one line per bibliography entry, from WebSearch on 2026-10-12) → `bib_table.md`; `make_issues.py` → `../../p1/issues-p1-arxiv.json`; `main.txt` (pdftotext of the PDF).

## 0. Summary

The paper is mathematically rich, carefully hedged and internally well cross-referenced: every one of its 203 theorem-like environments has a ledger row, and the printed statuses agree with `CLAIMS.md` (section 3). It is **not yet an arXiv paper**. Four groups of problems must be fixed first.

1. **Two front-matter claims are stronger than the body (fatal).** The abstract says that the reveal-law dominance theorem "holds in its intended reading"; the body proves it only with an extra K(n)+K(A) term under finiteness hypotheses, and whether that term is needed is open (P1X-01). The abstract says "SFI cannot use the order of the data"; the body proves this only in the semimeasure convention and says explicitly that the normalised predictor is not order-free (P1X-02). Three further front/back-matter statements overreach or contradict the body (P1X-03 intro "closes this gap"; P1X-04 discussion "gaps small on the known witnesses", false for the weak semimeasure; P1X-06 "all of them are proved" in the summary of Paper 2).
2. **Process material is printed throughout.** 114 non-plain `\status` tags and 203 `\src` notes; a 7-page verification appendix; the H1–H10 "verdicts" table; 13 citations (15 with Appendix I) of a "personal communication to the author" from the sole author ("Hänni's request"); 17 internal check-script ids and 12 track names in the text; 28 hedges of the form "not checked", "abstract seen only", "search snippet"; references to an uncited "draft"; and a third-person voice in which the sole author is graded ("his remark is correct"). Section 4 gives the full conversion plan, environment by environment and line by line.
3. **Literature: the novelty of the core results is undetermined.** The paper says its central history-aware result is "prior work in substance" (Hutter) without having checked Hutter's text; it has not compared SFI with the Solomonoff-style supervised classifier of Lattimore and Hutter (2013); it does not cite decision complexity (Loveland 1969; Uspensky and Shen 1996), the natural home of K_F; and it ends its related-work section with a to-do ("Each of these should be checked ... before any claim of novelty"). These need reading, not rewording (P1X-14 to P1X-18, P1X-34).
4. **Length and readability.** 103 pages (main text 50 pages, 12 sections, 155 theorem-like environments in the main text, 100 of them theorems, propositions, lemmas or corollaries), no figure, an abstract that uses undefined terms, an introduction with no informal main theorems, and open questions whose cross-references print the wrong section number (P1X-07, P1X-27 to P1X-29).

**Bibliography (section 5).** All 84 entries in `bib/*.bib` were searched. 67 are verified as printed (10 of them are not cited by Paper 1 and are not printed), 11 are verified but need a fix (missing issue numbers or pages, a missing LNCS volume, an unconfirmed imprint), 1 (the Vaintrob–Hänni slides) is verified against the local copy only, 2 are not printed, and 3 printed entries are unverifiable and must be dropped or replaced: `hanni2026request`, `hanni2026lesswrong` (which also prints "Hänni and Wyeth, undated" in the body), and `hanni2026notes` as printed (title "notes").

**Counts.** 53 issues: 2 fatal, 32 major, 19 minor (`issues-p1-arxiv.json`).

## 1. Claims in the abstract, introduction and discussion against the body (task 1)

Each claim is checked against the body result it cites, with the scope (convention, hypotheses, quantifiers). "OK" means same scope.

### 1.1 Abstract

| # | claim (abridged) | body result | verdict |
|---|---|---|---|
| A1 | SFI: a random program reading random bits shared by all inputs labels every input | def:setting:machine, def:setting:sfi | OK |
| A2 | universal function machine exists; its law dominates every function machine's law | thm:setting:universal | OK |
| A3 | "does not depend, up to a constant factor, on the universal machine or on computable encodings" | thm:setting:invariance (a),(b): computable **injections**, factor 2^{K(α,β)+O(1)} | minor: say "injective", factor depends on the encoding (P1X-36) |
| A4 | five versions agree up to K(dom D) bits; "no two of the first three" (K_F, W, M_prod) agree up to a constant | thm:versions:chain; thm:versions:nocoding; prop:versions:Wgap | true, but the body's "three objects" are K_F, W, M_F (rem:versions:answer) (P1X-35) |
| A5 | no coding theorem for function programs | thm:versions:nocoding | OK |
| A6 | on every consistent sequence, regret ≤ labeller's complexity + constant | thm:learn:dominance (machine laws) | OK |
| A7 | i.i.d. inputs, computable labels: averaged predictor has risk O(K/n) | thm:learn:batch(a): **deterministic** partial computable labels | minor: "deterministic" (P1X-36) |
| A8 | SFI cannot model fresh noise on repeated inputs; per-query mixture can | prop:learn:freshnoise, prop:learn:perquery | OK |
| A9 | "SFI cannot use the order of the data" | prop:setting:order (semimeasure convention only); normalised predictor "not order-free" (examples.tex 70, hist.tex 51); q:setting:normorder open | **fatal** (P1X-02) |
| A10 | cyclic permutation: about (d − log₂e)2^d bits (semimeasure convention); SI pays O(1) in expectation | thm:ex:cycle(c),(d); prop:ex:cycsi (label loss L^y) | OK; say "label loss" and "backwards along its cycle" (P1X-36) |
| A11 | hypotheses that see the list of previous inputs give the universal chronological semimeasure | cor:hist:H4 | OK |
| A12 | "A dominance theorem for computable reveal orders holds in its intended reading" | cor:hist:thm1(a) has + K(n) + K(A), needs (A1),(A2) and computable real values; rem:hist:thm1open(i)–(iii) open | **fatal** (P1X-01) |
| A13 | "though an earlier proof sketch fails" | prop:hist:sketchfails | OK; unattributed in the abstract (P1X-07) |

### 1.2 Introduction

| # | location | claim | verdict |
|---|---|---|---|
| I1 | l.5 | SI's regret against each computable source is a constant depending on the source | OK (standard; cite Li–Vitányi with section) |
| I2 | l.7 | SFI is the Bayes predictor for "a random lsc labeller"; pathwise regret ≤ complexity + constant on consistent sequences, any input law | OK (thm:learn:dominance, rem:learn:ideal) |
| I3 | l.7 | i.i.d.: Occam rate O(K/n) for the averaged predictor, no union bound | OK (thm:learn:batch(a)) |
| I4 | l.9 | SI is SFI on inputs 0,…,n−1 up to constant factors | OK (prop:setting:si) |
| I5 | l.9 | SFI's cumulative loss in the semimeasure convention does not depend on the order | OK |
| I6 | l.9 | "Giving SFI's hypotheses the list of previous inputs closes this gap" | **major**, overstated (P1X-03) |
| I7 | l.9 | "this is the kind of object that underlies Hutter's AIXI; we have not checked the identification" | hedge must be resolved (P1X-15) |
| I8 | l.11 | slides argue NN Bayes ≈ circuit SFI under a strong prior | OK as attribution |
| I9 | l.16 | universality; weak class exceeds M_F by linearly many bits on some data sets | OK (thm:setting:weakvsmachine(iii)) |
| I10 | l.17 | K_F ≥ log d − 2 while −log W = O(log log d) on two points | OK (thm:versions:nocoding (i),(ii)) |
| I11 | l.17 | W falls short of M_F only by the padded complexity of the needed tape length | OK (prop:versions:tape(a)) |
| I12 | l.18 | fresh noise: infinite expected loss; repairs; risk need not decrease | OK (prop:learn:freshnoise, thm:learn:batch(b),(c), prop:learn:perquery, prop:learn:curve — for a Bayes mixture, not M_F) |
| I13 | l.19 | chain/skipped strings: quadratic loss in both conventions, loss-0 set-based predictor | OK (thm:hist:chain, thm:hist:skipped, prop:hist:normchain) |
| I14 | l.19 | "every order-independent predictor pays the same lower bounds" | **major**, lsc / in expectation missing (P1X-05) |
| I15 | l.19 | Hänni's dominance theorem "true in the reading his text supports, under finiteness hypotheses" | **fatal** with A12: extra K(n)+K(A) omitted (P1X-01) |
| I16 | l.20 | cyclic permutation numbers; normalised δd − O(log d) per step for t ≤ 2^{(1−δ)d}; SI O(1) in expectation; SFIhist O(1) uniformly | OK (thm:ex:cycle, prop:ex:normalised, prop:ex:cycsi, prop:ex:cychist) |
| I17 | l.20 | Eisenstat: H(1/3)n/2 ± O(log n), optimal among order-independent predictors up to O(log n); SI ≤ 2.4 + c in expectation | OK (thm:ex:expected, prop:ex:law(b), thm:ex:eisensi; 3ϑ = 2.39855) |
| I18 | l.21 | OOD: bound with no log term, independent of data; machine-dependent; total error ≤ (ln 2)(K(f)+c); naive converse fails, labelled converse holds | OK |
| I19 | l.22 | time-bounded mixtures: constant regret against all predictors of a given running time | OK for x-only predictors; thm:comp:timebounded(a) needs distinct inputs, prop:comp:round does not (minor: say "x-only") |
| I20 | l.22 | circuit Bayes: mistakes and size polynomially related on every ordering; Occam 2^{Ω(ℓ/log ℓ)} on some ordering | OK (thm:comp:circuitbayes, thm:comp:ladder) |
| I21 | l.22 | GP limits vs SFI separation on parities | OK in the squared-error sense (cor:nn:separation) |
| I22 | l.26 | corrections paragraph and Table 1 | content consistent with the body (read row by row; each row cites the right results), but the paragraph and table are process material (P1X-10) |
| I23 | l.55 | credit; "we have checked them only at the level of abstracts" | must be resolved (P1X-15) |
| I24 | l.57 | list of open questions | consistent with the q: rows; cross-references print wrong numbers (P1X-27) |
| I25 | l.59 | upper bounds in the semimeasure convention hold in both conventions | OK (prop:setting:normalise(a)) |

### 1.3 Discussion

| # | location | claim | verdict |
|---|---|---|---|
| D1 | l.5 | dominance, merging (inputs not depending on unrevealed labels), O(K/n) | OK (thm:learn:merging allows rules s_t(h_{t−1}, ξ_t) with ξ independent of F) |
| D2 | l.5 | OOD: probability bounded below for every simple behaviour; total error ≤ (ln 2)(K(f)+c) | OK |
| D3 | l.7 | gaps are properties of order-free prediction; list of previous inputs removes them; set not enough; joint vs label loss | OK |
| D4 | l.9 | "their gaps, although unbounded, are small on the known witnesses" | **major**: false for M_w vs M_F (linear) (P1X-04) |
| D5 | l.9 | deterministic targets: all versions learn at the same rate | OK (rem:versions:prediction (5), prop:learn:occam) |
| D6 | l.11 | time-bounded constant regret; circuit Bayes; Occam fails "exponentially" | OK; "exponentially" means 2^{Ω(ℓ/log ℓ)} (2^d − 2 in d); say so |
| D7 | l.11 | parameter–function map alone implies no simplicity bias | OK (prop:nn:nolower(b)) |
| D8 | l.13 | operator induction "as secondary sources describe it" is M_pq | depends on an unverified source (P1X-34) |
| D9 | l.13 | "we claim no novelty for anything listed there as existing" | process / to-do (P1X-18) |
| D10 | l.15–24 | open problems | consistent with the q: rows, the conjectures and rem:hist:thm1open; conj:ood:natural is not precise (P1X-25) |
| D11 | l.26 | companion paper: window of λ/n; fixed λ > 1 sampler wins; absorption with shared randomness or in SI; structured rules open | consistent with `paper-steeper/CLAIMS.md` (teacher's-mistakes theorem, thm:split:private, absorption theorem, q:teacher:open) |
| D12 | l.29–31 | acknowledgements, AI disclosure | as required by the binding note; see P1X-31 on responsibility |

The summary of Paper 2 (`steeper.tex`) was checked number by number against `research/tracks/steeper/notes-final.md` and `paper-steeper/CLAIMS.md`: 2^{−20} ≈ 9.54·10^{−7}, 8.06·10^{−3}, 3.66·10^{−3}, 0.983, 37.7 of 11,710 bits, 0.199, p < 0.056, 1.6·10^{−5}, 31 % / 25 %, 128 + 896 points ≈ 10,400 bits, min(λ,2) bits per coin, d + 2 log d + O(1), the odds interval [2^{−2log(t_n+1)−O(1)}, 2^{k+δ*}], flip rate < 1/4: all match. The only problem is the sentence "all of them are proved there" (P1X-06). No visible text names Wyeth except the bibliography entry and its citation (P1X-12) and the verification appendix (to be dropped).

## 2. Notation and definitions before use (task 2)

* **NOTATION.md is followed.** The binding renamings were spot-checked: the tape measure is `\Unif` (no tape-measure λ; λ appears only as the steepness exponent, including the power posterior in rem:comp:uniformties); no bare κ (only the slides' κ_N in nn.tex); confidence exponents are j; the universal chronological semimeasure is `\MH` (no bare ξ for it); Möbius sums `\Mob`; padded and tail complexities `\Kpad`, `\Ktail`; the novelty `\sep`; no `\newcommand` in section files.
* **One NOTATION.md rule is broken by the paper's own front matter:** NOTATION.md §4 item 26 says H1–H10 appear only in CLAIMS.md and the verification appendix; Table 1 and learn.tex line 87 print them (P1X-10, P1X-22).
* **Clashes a reader will notice** (P1X-38): H_f is the entropy of the reveal sequence in cor:hist:thm1(c) and a hypothesis set in prop:comp:occam; P_A is a sampler's output law in prop:comp:samplers and the architecture prior in Section 9; e is the error e(x*) and Euler's number in the same formula of cor:learn:perstep(a); the empty string is ε (`\epsilon`) in Section 5 and `\varepsilon` in ex:ood:easyhard; ℓ is used for six different lengths (block lengths, ℓ_d, ℓ(f), ℓ(π), ℓ bits of a prefix, ℓ bisection queries) — locally defined each time, acceptable.
* **Used before definition** (P1X-37): M_F in setting.tex line 32 (defined at line 60); `\Mnorm` (normalised Solomonoff measure) is used in Section 6 but defined only in Appendix E; "LHG" is never expanded; "semimeasure convention" is used in the abstract and the contributions list before the reader's guide defines it at the end of the introduction (it is defined in Section 2 too). K_F and W are used in Section 2 with forward pointers to Definition 3.1 (acceptable).
* **Terms used in the abstract without definition:** semimeasure convention, universal weak semimeasure, reveal orders, d, K (P1X-07).

## 3. Statuses against CLAIMS.md (task 3)

`compare_status.py` parses the ledger tables of `CLAIMS.md` §1 and compares the status column with every `\status{}` in the paper.

* Every labelled environment of the paper has a ledger row, and every ledger row (except q:, tab:, sec: rows) has an environment: no missing or extra items.
* 71 strings differ, all cosmetically: the ledger abbreviates track names (F, Hi, Ex, Co) where the paper spells them out, and the ledger lists check ids that the paper drops. Three differences carry content: prop:learn:freshnoise prints "refuted (the brief's fresh-noise claim, as stated)" where the ledger has "refuted (H7 as stated)" — both are process vocabulary (P1X-22); conj:ood:natural drops the ledger's "(machine-dependent by prop:ood:machine)"; prop:ex:cycsi prints "computed (examples e6(f), an illustration)" for the ledger's "illustrated". None changes the strength of a claim.
* The ledger's statuses also agree with the final notes for the items checked in this review (cor:hist:thm1 "proved under the stated hypotheses" = history notes-final row 3.9; thm:comp:timebounded and prop:comp:round/history = context notes-final Thm 3.1, Props 3.2a/c; cor:comp:poly "proved" = context Cor 3.2b).
* So the statuses are accurate. The problem is not their content but that they are printed (section 4).

## 4. Plan for the arXiv conversion (task 4)

### 4.1 Every theorem-like environment whose status is not plain "proved"

`extract_status.py` finds 203 theorem-like environments. 73 carry `\status{proved}` exactly; they need only the deletion of `\status` and `\src`. 16 have no status (13 definitions and rem:setting:perinput, rem:setting:recommend, rem:versions:randomness); they need only the deletion of `\src`. The remaining **114** are listed below, sorted by category (proof sketch, conditional, conjecture, refuted, known/unverified, known/cited, remark, open, proved with an open part, qualified "proved", computed, proved + computed), with the academic form each needs and the exact rewording. Theorem numbers in the rewordings are those of the current PDF. For the 50 rows "proved + computed" (those without a special entry) the action is the same: delete the tag; where the text quotes a number from the computation, introduce it by "A direct computation (code in the accompanying repository) gives ..."; where it does not, drop the computation from the paper and list the script in the Code-and-data table.

Two inline `\status` calls outside environments also need rewording: setting.tex line 40 ("... random sets [Choquet; Matheron; Shafer] \status{known; unverified}; we have not checked the analogy against these sources" → "The proposition is the function-space analogue of the correspondence between completely monotone set functions and random sets [Cho54, Mat75, Sha76]."), app-versions.tex line 92 (Levin's bound: after reading arXiv:1403.4539, state "Levin [Lev16] shows that the two quantities differ by at most the information the set carries about the halting problem; whether this applies to the infinite c.e. sets S_D we leave open", and delete "we have not checked its statement") and line 102 (Kleitman–Spencer: "This is the construction of Kleitman and Spencer [KS73]; for N ≤ 8 a direct computation confirms that it is optimal" and delete "reported to be optimal ... we did not check optimality against the source").

| # | file:line | label | current \status | category | academic form | exact rewording / action |
|---|---|---|---|---|---|---|
| 1 | app-learn.tex:131 | `rem:learn:positive` | proof sketch; known (snippet) | proof sketch | Remark (informal) | Title "Remark C.5 (positive examples; informal)". Drop "known (snippet)". Either read Chater and Vitanyi (2007) (open access at CWI) and state the relation precisely, or delete the sentence "It appears to be the object of ... their exact model was not checked." |
| 2 | comp.tex:20 | `thm:comp:timebounded` | (a) proved (corrected); (b) proof sketch; computed (context c5, c9) | proof sketch | Theorem (a) only | Keep part (a) as Theorem 8.2 (drop "(corrected)"). Move (b) to a new remark directly after the theorem, "Remark (running time)", that begins "We sketch the cost per round; we do not fix a machine model (RAM versus multitape) or analyse the clocks." Label the appendix argument "Proof sketch of the running-time remark". Keep the toy check as "A direct computation on a toy instance (code in the accompanying repository) matches the brute-force mixture to 2.5e-16 and gives regret 132.4 bits against the bound 184." |
| 3 | comp.tex:34 | `prop:comp:round` | proved; running time proof sketch; computed (context c9) | proof sketch | Proposition (regret) + remark (cost) | Keep the regret bound as Proposition 8.4. Replace the last sentence of the statement by a sentence after it: "The learner performs #{i : k_i <= k} simulations of g(k)t(|x_k|) steps in round k, plus as many arithmetic operations; see the running-time remark after Theorem 8.2 (sketch)." Numbers from the stream test: "A direct computation (code in the accompanying repository) gives regret 10.0 bits against the bound 20." |
| 4 | comp.tex:61 | `prop:comp:history` | regret proved; running time proof sketch | proof sketch | Proposition (regret) + remark (cost, sketch) | State only the regret bound in the proposition. Move "round k costs O(...) steps plus the replay memory" into a sentence "We only sketch the running time: ..." after the proof idea. |
| 5 | hist.tex:96 | `thm:hist:minimax` | (a) proved; (b) proved for reveal laws that do not see $f$, proof sketch for those that do; computed | proof sketch | Theorem restricted + remark | Restrict (b) to reveal laws that do not see f (all that Corollary 5.14 uses) and delete "and possibly f|_{A_n}" from the hypotheses of (b). Add, after the theorem, "Remark (reveal laws that see f). For reveal laws that may see f|_{A_n} the argument of case (b) goes through if C_dir(Delta,n) can be computed to within one bit from (P,Delta,n,A); we do not carry this out." Delete "not written out" from the proof idea. |
| 6 | app-examples.tex:116 | `rem:ex:where` | proved; the other-direction part conditional | conditional | Remark + pointer to Assumption | Keep the proved part. Rephrase the last sentence: "Conversely, under Assumption (LHG-even) (with X=Y={0,1} and y_i=x_i) SI's unnormalised label loss is unbounded while L_SFI <= c (Proposition 5.22)." |
| 7 | hist.tex:159 | `prop:hist:lhg` | conditional (on LHG transfer); LHG known, unverified beyond the abstract | conditional | Assumption + Proposition | Introduce "Assumption (LHG-even)" and "Assumption (LHG-odd)" with the present wording, preceded by "Lattimore, Hutter and Gavane (2011) show that unnormalised Solomonoff induction can fail on simple recursive sub-patterns; we do not verify that their construction gives the following." Then "Proposition 5.22. Under Assumption (LHG-even), ...; under Assumption (LHG-odd), ...". Remove the status. (Use the existing assumption environment.) |
| 8 | app-examples.tex:100 | `conj:ex:raw` | conjecture | conjecture | Conjecture (make precise) or open question | Make precise: "Conjecture E.5. With raw blocks, E L^y_M(1) >= K(d) - K_tail(d) - c for all d", or move to the open problems; "for typical d" is not a mathematical statement. |
| 9 | hist.tex:111 | `conj:hist:algmi` | conjecture (untested) | conjecture | Conjecture | Plain conjecture; drop "(untested)"; optionally "Proposition D.8 is its Shannon analogue." |
| 10 | learn.tex:129 | `conj:learn:loo` | conjecture | conjecture | Conjecture | Keep; it is precise. Keep the heuristic in the appendix under "Heuristic (not a proof)". |
| 11 | ood.tex:177 | `conj:ood:natural` | conjecture | conjecture | Open problem (informal) | Remove the conjecture environment ("This is not a precise statement"). In Section 12, Open problems: "Is there a natural class of universal machines for which the intended answers of Example 7.16 receive posterior probability close to 1? By Proposition 7.4 no such statement holds for every universal machine." |
| 12 | app-hist.tex:248 | `prop:hist:info` | (a) proved; (b) refuted; computed | refuted | Proposition | Plain proposition; (b) already reads "The natural strengthening ... is false". Remove status. |
| 13 | app-learn.tex:117 | `rem:learn:cesaro` | refuted | refuted | Delete or rewrite | Delete: it records an internal correction ("An earlier version of the context notes"). If kept: "Remark C.3. Proposition 4.13 is a per-step lower bound and cannot be compared with the O(1/n) Cesaro bound of Theorem 4.5: since sum_k E e_k <= (ln 2)(K(f)+c), liminf_k k E e_k = 0. Corollary 4.14 gives the per-step comparison." |
| 14 | comp.tex:29 | `rem:comp:distinct` | refuted; computed (context c9) | refuted | Remark (counterexample + computation) | "Remark 8.3 (distinct inputs are needed). Theorem 8.2(a) does not extend to streams with repeated inputs: ... A direct computation (code in the accompanying repository) on 4000 rounds that repeat 12 short inputs gives regret 469 bits, growing linearly. Proposition 8.4 removes the restriction." |
| 15 | hist.tex:88 | `thm:hist:randchain` | proved; refutes Reading B | refuted | Theorem | Title "Theorem 5.12 (the randomised chain; Reading B fails)". Remove "refutes Reading B" status. |
| 16 | learn.tex:79 | `prop:learn:freshnoise` | proved; refuted (the brief's fresh-noise claim, as stated); computed (foundations c5, r9(b)) | refuted | Proposition | Plain proposition. Delete "refuted (the brief's fresh-noise claim, as stated)" and, in the text after it, "This refutes the fresh-noise form of the supervised-learning hypothesis H7 ... (Table 1)". Replace "(foundations c5)" by "(a direct computation; code in the accompanying repository)". |
| 17 | ood.tex:65 | `prop:ood:draftfalse` | refuted; proved | refuted | Proposition (counterexample) | Title "Proposition 7.6 (the literal bounds fail)". Text before it: "Read literally, both bounds stated in Hanni (2026b, draft) fail:". Remove "draft's" from headings; cite the draft as its own bibliography entry. |
| 18 | ood.tex:95 | `rem:ood:lopsided` | refuted as stated; remark | refuted | Remark | Plain remark; first sentence "One might read Theorem 7.7 and Proposition 7.8 as saying ... ; this reading is wrong:". |
| 19 | setting.tex:95 | `rem:setting:h1a` | refuted (weak definition); open (random-function laws) | refuted | Remark (failed expectation) | "Remark 2.14 (weak and machine universality differ). By analogy with sequences (Zvonkin and Levin 1970) one might expect lsc function semimeasures and laws of function machines to agree up to a constant factor. For weak semimeasures this fails: ... For laws of random partial functions it is open (q:setting:rpf)." Replace "a natural conjecture" by "a natural expectation". |
| 20 | app-hist.tex:176 | `prop:hist:operator` | proved, given the unverified description | known; unverified | Proposition about M_pq | Title "Proposition D.12 (the per-query mixture ignores the history)". State it for M_pq. In the text: "If operator induction is read as M_pq (Remark 3.2), this applies to it." Remove "given the unverified description". |
| 21 | app-setting.tex:76 | `lem:setting:realise` | proved (binary case known: Zvonkin--Levin 1970, unverified) | known; unverified | Lemma with attribution | Heading "Lemma A.5 (realisation; the binary case is due to Zvonkin and Levin 1970)". Delete "(not checked against the source)" in the proof. |
| 22 | comp.tex:126 | `rem:comp:selection` | computed (context c6(e)); known; unverified (claimed in the slides) | known; unverified | Remark (computation + cited claims) | Title "Remark 8.15 (the selection rule matters)". "An exact computation (code in the accompanying repository; ties count 1/2) gives ... Vaintrob and Hanni (2026b, App. K) also state ...; we prove only the first and last rows (Theorem 8.14, Remark 8.13)." Replace "we have not checked them" by "we do not prove them here". |
| 23 | hist.tex:129 | `cor:hist:H4` | proved; identification known (unverified) | known; unverified | Corollary + sentence on Hutter | Plain corollary. Before posting, check Hutter (2005, the chapter on chronological semimeasures) and state either "M_H coincides up to constant factors with Hutter's universal chronological semimeasure xi (Hutter 2005, Sec. x)" or "We do not use any identification with Hutter's xi". Delete "identification known (unverified)". |
| 24 | learn.tex:51 | `cor:learn:mistakes` | proved; known (Littlestone 1988; Barzdin--Freivalds 1972, content unverified) | known; unverified | Corollary with citation | Heading "Corollary 4.4 (mistake bound; cf. the halving bound of Barzdin and Freivalds 1972 and Littlestone 1988)". Drop "content unverified". |
| 25 | learn.tex:156 | `prop:learn:occam` | proved (standard); references known, unverified | known; unverified | Proposition (standard) | Heading "Proposition 4.15 (Occam bound in description-length form; Blumer et al. 1987)". Add "The proof is the standard union bound; we include it for completeness." Drop "references known, unverified". |
| 26 | learn.tex:169 | `rem:learn:hutterEX` | known; unverified | known; unverified | Related-work prose | Move into Section 11: "Hutter (2000, 2005, 2007) lists supervised learning from examples among the problem classes of AIXI (Hutter 2007, Sec. x)." Check the section in the arXiv version cs/0701125 first. Delete "A table-of-contents snippet shows" and "We have not read these sections". |
| 27 | nn.tex:79 | `rem:nn:slides` | known; unverified (claimed in the slides); warm-up arithmetic re-checked (context c8) | known; unverified | Related-work paragraph | Replace the remark by a paragraph "Claims of Vaintrob and Hanni (2026b)" in Section 9 or 11: "Vaintrob and Hanni (2026b) state the following (we do not reproduce their proofs): (i)...(vi)." Replace "We re-checked ... the rest is unchecked" by "Claim (i), the character argument of their Appendix J and the construction of their Appendix K are proved here as Theorem 9.7(a) and Theorem 8.14." Keep their own caveats. |
| 28 | nn.tex:89 | `rem:nn:literature` | known (snippets; unverified) | known; unverified | Related-work prose | Move to Section 11 as plain prose with citations; delete "These descriptions follow the abstracts" and "known (snippets; unverified)". |
| 29 | related.tex:16 | `rem:related:new` | known (snippets; unverified) | known; unverified | Delete / novelty sentence | Delete the remark. After checking Hutter (2005), Lattimore and Hutter (2013), Solomonoff (2008) and the decision-complexity literature, add one sentence to the contributions: "To our knowledge the following are new: ...", or say nothing about novelty. Never print "Each of these should be checked ... before any claim of novelty". |
| 30 | versions.tex:20 | `rem:versions:operator` | known; unverified; equality on distinct inputs proved | known; unverified | Remark (literature) | Obtain the full text of Solomonoff (2008) (PDF on raysolomonoff.com) and quote the operator-induction formula from it, with section number; cite Ozkural only if needed. Then "Remark 3.2 (operator induction). Solomonoff (2008, Sec. x) predicts ... by sum_j a_j prod_i O^j(A_i|Q_i). This is M_pq; on distinct inputs it equals M_prod (proof: ...)." Delete "(abstract only seen)" and "(search snippet only)". If the formula cannot be checked, write "We read operator induction as the per-query mixture M_pq" and make no attribution claim. |
| 31 | app-setting.tex:156 | `prop:setting:transfer` | proved; (b) uses the relativised coding theorem (known); computed | known/cited | Proposition | Plain proposition; in the proof cite the relativised coding theorem as "(Li and Vitanyi 2008, Sec. 4.3, relativised)". Replace "(c10(b) checks this exactly on 16,200 cases ...)" by nothing or by the Code-and-data table. |
| 32 | comp.tex:102 | `prop:comp:occam` | (a) known; (b) proved | known/cited | Proposition with citation | "Proposition 8.12. (a) (Blumer et al. 1987) ... (b) ..." and "We prove (b) in Appendix G". |
| 33 | comp.tex:109 | `rem:comp:majority` | proved; known | known/cited | Remark with citation | Plain remark citing Littlestone (1988), Littlestone and Warmuth (1994). Rephrase "Hanni's physicist's proof" as "An informal argument in Hanni (2026b, circuit notes) ..." |
| 34 | comp.tex:119 | `thm:comp:ladder` | proved; computed (context c6, c11); construction from the slides | known/cited | Theorem with attribution | Heading "Theorem 8.14 (conjunction ladder; the construction is from Vaintrob and Hanni 2026b, App. K)". Replace "A direct computation (d=3,4,5, seven tie rules) finds ..." by "A direct computation (code in the accompanying repository) for d=3,4,5 and seven tie rules confirms ...". |
| 35 | learn.tex:117 | `prop:learn:splits` | proved; technique known; computed (context c3) | known/cited | Proposition | Drop "technique known"; one sentence in the text: "The exchangeability argument is standard (Haussler et al. 1994; Cesa-Bianchi et al. 2004)." Check Haussler et al. first or drop that citation (currently "(not checked)"). |
| 36 | nn.tex:26 | `prop:nn:typical` | proved; known (standard) | known/cited | Proposition (standard) | Heading "Proposition 9.3 (standard; cf. Li and Vitanyi 2008)". |
| 37 | nn.tex:56 | `thm:nn:walsh` | proved; (a) known, (b) standard; computed (context c2) | known/cited | Theorem with attribution | "Theorem 9.7. (a) (Yang and Salman 2019; also in Vaintrob and Hanni 2026b, App. J) ... (b) (the standard dimension argument; cf. Kamath et al. 2020)." Check the attribution against arXiv:1907.10599 before posting. |
| 38 | nn.tex:71 | `rem:nn:oddparity` | proved; computed (context c2, c10, c12); known | known/cited | Proposition (a)-(c) + numerical remark | Make (a)-(c) "Proposition 9.9"; heading of (a) "(the Boolean-cube analogue of Basri et al. 2019)". Move the kernel-ridge accuracy numbers to a following sentence "A direct computation (code in the accompanying repository) gives sign accuracy 0.05-0.07 at n=900, d=10; we do not prove this." |
| 39 | ood.tex:43 | `prop:ood:machine` | proved; analogue known | known/cited | Proposition with citation | "(cf. Leike and Hutter 2015 for the analogous dependence of AIXI)". Drop "analogue known". |
| 40 | app-hist.tex:256 | `rem:hist:exploit` | remark (informal part not a theorem) | remark | Remark (informal) | Title "Remark D.17 (what SFI can and cannot exploit; informal)". Keep the "Informally"/"Proved" split. |
| 41 | app-learn.tex:122 | `rem:learn:relations` | remark | remark | Remark | Plain remark (no status). |
| 42 | app-learn.tex:136 | `rem:learn:interventions` | remark | remark | Delete | Delete ("Nothing specific to SFI is proved here"). |
| 43 | comp.tex:56 | `rem:comp:apples` | remark | remark | Remark | Plain remark; rephrase "Hanni's apples to oranges caveat" as "a caveat raised in Hanni (2026b)". |
| 44 | comp.tex:97 | `rem:comp:gap` | remark; computed (context c1) | remark | Remark | Plain remark; "For formulas on d=3, an exhaustive computation (code in the accompanying repository) ..."; rephrase "Hanni's sketch". |
| 45 | hist.tex:165 | `rem:hist:H4verdict` | remark (cited items) | remark | Remark (summary) | Title "Remark 5.23 (summary: hypotheses that see the previous inputs)". Replace "Verdict on Hanni's conjecture" and "H4". |
| 46 | learn.tex:163 | `rem:learn:ideal` | remark (each item cited) | remark | Remark | Plain remark; drop "(each item cited)". |
| 47 | nn.tex:49 | `rem:nn:bridge` | remark | remark | Remark | Plain remark. |
| 48 | nn.tex:84 | `rem:nn:rigorous` | remark | remark | Delete or merge | Delete (it repeats the section summary); fold one sentence into the Discussion. |
| 49 | ood.tex:143 | `rem:ood:answer` | remark | remark | Remark | Plain remark; title "Remark 7.14 (summary of the out-of-distribution results)". |
| 50 | app-hist.tex:112 | `rem:hist:thm1open` | open | open | Remark (open cases) | Title "Remark D.6 (open cases)". Fine otherwise; replace "a direct computation certifies" by "a direct computation (code in the accompanying repository) certifies". |
| 51 | app-versions.tex:30 | `rem:versions:Wrate` | proved; rate open | proved + open part | Remark | Plain remark; the open rate goes to the open question q:versions:open. |
| 52 | examples.tex:59 | `prop:ex:orderfree` | proved; sharper weak case open | proved + open part | Proposition + question | Plain proposition; the "sharper weak case" is the open question q:ex:depthweak. |
| 53 | examples.tex:161 | `rem:ex:email` | proved; normalised open | proved + open part | Remark | Title "Remark 6.17 (an informal argument)". "The argument of Hanni (2026b) [or: an e-mail argument of the author, quoted in Appendix E.3] is correct in the semimeasure convention ...". Drop "normalised open" status; the open part points to the open question q:ex:normalised. |
| 54 | learn.tex:30 | `rem:learn:h2` | proved; open part | proved + open part | Remark | Title "Remark 4.2 (scope of dominance)"; item (iii) points to the open question q:setting:rpf. Remove status "proved; open part". |
| 55 | learn.tex:110 | `rem:learn:lastiterate` | identity proved; computed (foundations c11(b)); bound open | proved + open part | Remark | Plain remark; "A direct computation on 300 random finite instances (code in the accompanying repository) gives max (n+1)r_n/K = 0.873." Delete "(foundations r12)". |
| 56 | setting.tex:125 | `rem:setting:conventions` | proved (as a list); transfer open where stated | proved + open part | Remark | Plain remark; drop "(as a list); transfer open where stated". |
| 57 | app-examples.tex:229 | `rem:ex:fresh` | proved (citing) | proved (qualified) | Remark | Plain remark; drop "(citing)". |
| 58 | comp.tex:68 | `prop:comp:samplers` | proved (corrected) | proved (qualified) | Proposition | Plain proposition; drop "(corrected)". |
| 59 | examples.tex:79 | `prop:ex:cychist` | proved, given \cref{cor:hist:H4} | proved (qualified) | Proposition | Plain proposition (its proof uses Corollary 5.18, which is proved). |
| 60 | hist.tex:103 | `cor:hist:thm1` | proved under the stated hypotheses | proved (qualified) | Corollary | Title "Corollary 5.14 (Theorem 1 of Hanni (2026b) in Reading C)"; drop the status. |
| 61 | nn.tex:10 | `prop:nn:functionspace` | proved (trivial) | proved (qualified) | Proposition or observation | Either "Proposition 9.1" without "(trivial)", or turn into a sentence "Grouping the parameter integral by f_theta shows that ...".  |
| 62 | nn.tex:19 | `prop:nn:upper` | proved (given the coding theorem) | proved (qualified) | Proposition | Plain proposition (the coding theorem is a cited standard fact). Move the Gaussian-weights lower-semicomputability argument into a new "Remark (Gaussian weights; sketch)" and say it is a sketch. |
| 63 | ood.tex:36 | `prop:ood:relative` | proved (corrected) | proved (qualified) | Proposition | Plain proposition; drop "(corrected)". |
| 64 | app-learn.tex:112 | `rem:learn:increasing` | computed (context c3 Part 2) | computed | Example | Make it "Example C.2 (learning curves can increase)". The loss formula is an exact calculation: state it as such; the number 0.255 as "a direct calculation gives". |
| 65 | app-comp.tex:36 | `lem:comp:mobius` | proved; computed (context c6(a), $d\le4$) | proved + computed | Lemma (status removed) | add, where the number is quoted in the text: "A direct computation (code in the accompanying repository) gives/confirms ..."; otherwise drop the computation from the paper and list it in the Code-and-data table |
| 66 | app-comp.tex:57 | `rem:comp:adversary` | proved; computed (context c11) | proved + computed | Remark (status removed) | add, where the number is quoted in the text: "A direct computation (code in the accompanying repository) gives/confirms ..."; otherwise drop the computation from the paper and list it in the Code-and-data table |
| 67 | app-examples.tex:42 | `lem:ex:depth` | proved; computed (examples e6(b)) | proved + computed | Lemma (status removed) | add, where the number is quoted in the text: "A direct computation (code in the accompanying repository) gives/confirms ..."; otherwise drop the computation from the paper and list it in the Code-and-data table |
| 68 | app-examples.tex:168 | `lem:ex:behind` | proved; computed (examples e7(a)) | proved + computed | Lemma (status removed) | add, where the number is quoted in the text: "A direct computation (code in the accompanying repository) gives/confirms ..."; otherwise drop the computation from the paper and list it in the Code-and-data table |
| 69 | app-examples.tex:196 | `lem:ex:pstar` | proved; computed (examples e1(c)) | proved + computed | Lemma (status removed) | add, where the number is quoted in the text: "A direct computation (code in the accompanying repository) gives/confirms ..."; otherwise drop the computation from the paper and list it in the Code-and-data table |
| 70 | app-hist.tex:124 | `prop:hist:shannon` | proved; computed | proved + computed | Proposition (status removed) | add, where the number is quoted in the text: "A direct computation (code in the accompanying repository) gives/confirms ..."; otherwise drop the computation from the paper and list it in the Code-and-data table |
| 71 | app-hist.tex:184 | `prop:hist:programs` | proved; toy computed | proved + computed | Proposition (status removed) | add, where the number is quoted in the text: "A direct computation (code in the accompanying repository) gives/confirms ..."; otherwise drop the computation from the paper and list it in the Code-and-data table |
| 72 | app-hist.tex:227 | `lem:hist:charsum` | proved; computed | proved + computed | Lemma (status removed) | add, where the number is quoted in the text: "A direct computation (code in the accompanying repository) gives/confirms ..."; otherwise drop the computation from the paper and list it in the Code-and-data table |
| 73 | app-setting.tex:138 | `prop:setting:twopoint` | proved; computed | proved + computed | Proposition (status removed) | add, where the number is quoted in the text: "A direct computation (code in the accompanying repository) gives/confirms ..."; otherwise drop the computation from the paper and list it in the Code-and-data table |
| 74 | app-versions.tex:55 | `rem:versions:hashing` | proved; computed | proved + computed | Remark | Title "Remark B.3 (a hashing bound)"; delete "superseded"; say "weaker than Proposition 3.6 but of independent interest" if kept at all. |
| 75 | comp.tex:87 | `thm:comp:circuitbayes` | proved; computed (context c1, c8) | proved + computed | Theorem (status removed) | add, where the number is quoted in the text: "A direct computation (code in the accompanying repository) gives/confirms ..."; otherwise drop the computation from the paper and list it in the Code-and-data table |
| 76 | examples.tex:37 | `thm:ex:cycle` | proved; computed (examples e3, e6(d)) | proved + computed | Theorem (status removed) | add, where the number is quoted in the text: "A direct computation (code in the accompanying repository) gives/confirms ..."; otherwise drop the computation from the paper and list it in the Code-and-data table |
| 77 | examples.tex:49 | `thm:ex:ksteps` | proved; computed (examples e6(a),(b),(c)) | proved + computed | Theorem (status removed) | add, where the number is quoted in the text: "A direct computation (code in the accompanying repository) gives/confirms ..."; otherwise drop the computation from the paper and list it in the Code-and-data table |
| 78 | examples.tex:72 | `prop:ex:normalised` | proved; proxy computed (examples e6(e)) | proved + computed | Proposition (status removed) | add, where the number is quoted in the text: "A direct computation (code in the accompanying repository) gives/confirms ..."; otherwise drop the computation from the paper and list it in the Code-and-data table |
| 79 | examples.tex:95 | `prop:ex:cycsi` | proved; computed (examples e6(f), an illustration) | proved + computed | Proposition | Plain proposition; any numbers from e6(f) go in a sentence "A finite illustration (code in the accompanying repository) ..." or are dropped. |
| 80 | examples.tex:141 | `prop:ex:asymp` | proved; computed (examples e1, e2, e7(d)) | proved + computed | Proposition (status removed) | add, where the number is quoted in the text: "A direct computation (code in the accompanying repository) gives/confirms ..."; otherwise drop the computation from the paper and list it in the Code-and-data table |
| 81 | examples.tex:146 | `thm:ex:expected` | proved; computed (examples e2) | proved + computed | Theorem (status removed) | add, where the number is quoted in the text: "A direct computation (code in the accompanying repository) gives/confirms ..."; otherwise drop the computation from the paper and list it in the Code-and-data table |
| 82 | examples.tex:152 | `prop:ex:law` | proved; computed (examples e1, s2(d)) | proved + computed | Proposition (status removed) | add, where the number is quoted in the text: "A direct computation (code in the accompanying repository) gives/confirms ..."; otherwise drop the computation from the paper and list it in the Code-and-data table |
| 83 | examples.tex:168 | `prop:ex:burnin` | proved; computed (examples e1(e), e7(a),(b)) | proved + computed | Proposition (status removed) | add, where the number is quoted in the text: "A direct computation (code in the accompanying repository) gives/confirms ..."; otherwise drop the computation from the paper and list it in the Code-and-data table |
| 84 | examples.tex:190 | `prop:ex:rulestats` | proved; computed (examples e2, e7) | proved + computed | Proposition (status removed) | add, where the number is quoted in the text: "A direct computation (code in the accompanying repository) gives/confirms ..."; otherwise drop the computation from the paper and list it in the Code-and-data table |
| 85 | examples.tex:213 | `ex:ex:parity` | proved; computed (examples e4(a)) | proved + computed | Example (status removed) | add, where the number is quoted in the text: "A direct computation (code in the accompanying repository) gives/confirms ..."; otherwise drop the computation from the paper and list it in the Code-and-data table |
| 86 | examples.tex:218 | `ex:ex:threshold` | proved; computed (examples e4(b)) | proved + computed | Example (status removed) | add, where the number is quoted in the text: "A direct computation (code in the accompanying repository) gives/confirms ..."; otherwise drop the computation from the paper and list it in the Code-and-data table |
| 87 | examples.tex:235 | `prop:ex:frozen` | proved; computed (examples e4(c)) | proved + computed | Proposition (status removed) | add, where the number is quoted in the text: "A direct computation (code in the accompanying repository) gives/confirms ..."; otherwise drop the computation from the paper and list it in the Code-and-data table |
| 88 | hist.tex:53 | `prop:hist:normchain` | proved; finite proxy computed | proved + computed | Proposition (status removed) | add, where the number is quoted in the text: "A direct computation (code in the accompanying repository) gives/confirms ..."; otherwise drop the computation from the paper and list it in the Code-and-data table |
| 89 | hist.tex:70 | `prop:hist:sketchfails` | computed; proved | proved + computed | Proposition | Title "Proposition 5.8 (a simulator with separate randomness per input fails)". Replace "the proof sketch" in the title by "the simulation argument of Hanni (2026b)". |
| 90 | hist.tex:84 | `thm:hist:directed` | proved; identity computed | proved + computed | Theorem (status removed) | add, where the number is quoted in the text: "A direct computation (code in the accompanying repository) gives/confirms ..."; otherwise drop the computation from the paper and list it in the Code-and-data table |
| 91 | hist.tex:123 | `thm:hist:representation` | proved; construction computed | proved + computed | Theorem (status removed) | add, where the number is quoted in the text: "A direct computation (code in the accompanying repository) gives/confirms ..."; otherwise drop the computation from the paper and list it in the Code-and-data table |
| 92 | hist.tex:137 | `prop:hist:strict` | proved; lemma computed | proved + computed | Proposition (status removed) | add, where the number is quoted in the text: "A direct computation (code in the accompanying repository) gives/confirms ..."; otherwise drop the computation from the paper and list it in the Code-and-data table |
| 93 | hist.tex:153 | `prop:hist:inputloss` | proved; toy computed | proved + computed | Proposition (status removed) | add, where the number is quoted in the text: "A direct computation (code in the accompanying repository) gives/confirms ..."; otherwise drop the computation from the paper and list it in the Code-and-data table |
| 94 | hist.tex:183 | `thm:hist:gf` | proved; computed | proved + computed | Theorem (status removed) | add, where the number is quoted in the text: "A direct computation (code in the accompanying repository) gives/confirms ..."; otherwise drop the computation from the paper and list it in the Code-and-data table |
| 95 | learn.tex:40 | `thm:learn:merging` | proved; finite analogue computed (foundations c4, r6; integrability inequality c11(c)) | proved + computed | Theorem (status removed) | add, where the number is quoted in the text: "A direct computation (code in the accompanying repository) gives/confirms ..."; otherwise drop the computation from the paper and list it in the Code-and-data table |
| 96 | learn.tex:65 | `thm:learn:batch` | proved; finite analogues computed (foundations r9; c7, r7) | proved + computed | Theorem (status removed) | add, where the number is quoted in the text: "A direct computation (code in the accompanying repository) gives/confirms ..."; otherwise drop the computation from the paper and list it in the Code-and-data table |
| 97 | learn.tex:89 | `prop:learn:perquery` | proved; computed (foundations c7, r7) | proved + computed | Proposition (status removed) | add, where the number is quoted in the text: "A direct computation (code in the accompanying repository) gives/confirms ..."; otherwise drop the computation from the paper and list it in the Code-and-data table |
| 98 | learn.tex:103 | `prop:learn:curve` | proved; computed (foundations c11(a), r12) | proved + computed | Proposition (status removed) | add, where the number is quoted in the text: "A direct computation (code in the accompanying repository) gives/confirms ..."; otherwise drop the computation from the paper and list it in the Code-and-data table |
| 99 | learn.tex:122 | `prop:learn:loo` | proved; computed (context c7) | proved + computed | Proposition (status removed) | add, where the number is quoted in the text: "A direct computation (code in the accompanying repository) gives/confirms ..."; otherwise drop the computation from the paper and list it in the Code-and-data table |
| 100 | learn.tex:136 | `prop:learn:typical` | proved; computed (context c4) | proved + computed | Proposition (status removed) | add, where the number is quoted in the text: "A direct computation (code in the accompanying repository) gives/confirms ..."; otherwise drop the computation from the paper and list it in the Code-and-data table |
| 101 | learn.tex:143 | `cor:learn:perstep` | proved; computed (context c7) | proved + computed | Corollary (status removed) | add, where the number is quoted in the text: "A direct computation (code in the accompanying repository) gives/confirms ..."; otherwise drop the computation from the paper and list it in the Code-and-data table |
| 102 | nn.tex:64 | `cor:nn:separation` | proved; computed (context c2) | proved + computed | Corollary (status removed) | add, where the number is quoted in the text: "A direct computation (code in the accompanying repository) gives/confirms ..."; otherwise drop the computation from the paper and list it in the Code-and-data table |
| 103 | ood.tex:125 | `prop:ood:labelled` | proved; disjointness computed (context c7) | proved + computed | Proposition (status removed) | add, where the number is quoted in the text: "A direct computation (code in the accompanying repository) gives/confirms ..."; otherwise drop the computation from the paper and list it in the Code-and-data table |
| 104 | ood.tex:166 | `ex:ood:hanniexamples` | proved; computed (examples e5) | proved + computed | Example (status removed) | add, where the number is quoted in the text: "A direct computation (code in the accompanying repository) gives/confirms ..."; otherwise drop the computation from the paper and list it in the Code-and-data table |
| 105 | setting.tex:42 | `ex:setting:weaknotrpf` | proved; computed | proved + computed | Example (status removed) | add, where the number is quoted in the text: "A direct computation (code in the accompanying repository) gives/confirms ..."; otherwise drop the computation from the paper and list it in the Code-and-data table |
| 106 | setting.tex:83 | `thm:setting:weakuniversal` | proved; trimming computed | proved + computed | Theorem (status removed) | add, where the number is quoted in the text: "A direct computation (code in the accompanying repository) gives/confirms ..."; otherwise drop the computation from the paper and list it in the Code-and-data table |
| 107 | setting.tex:87 | `thm:setting:weakvsmachine` | proved; computed | proved + computed | Theorem (status removed) | add, where the number is quoted in the text: "A direct computation (code in the accompanying repository) gives/confirms ..."; otherwise drop the computation from the paper and list it in the Code-and-data table |
| 108 | setting.tex:109 | `prop:setting:order` | proved; computed | proved + computed | Proposition (status removed) | add, where the number is quoted in the text: "A direct computation (code in the accompanying repository) gives/confirms ..."; otherwise drop the computation from the paper and list it in the Code-and-data table |
| 109 | setting.tex:115 | `prop:setting:normalise` | proved; computed | proved + computed | Proposition (status removed) | add, where the number is quoted in the text: "A direct computation (code in the accompanying repository) gives/confirms ..."; otherwise drop the computation from the paper and list it in the Code-and-data table |
| 110 | setting.tex:155 | `ex:setting:swap` | proved; computed | proved + computed | Example (status removed) | add, where the number is quoted in the text: "A direct computation (code in the accompanying repository) gives/confirms ..."; otherwise drop the computation from the paper and list it in the Code-and-data table |
| 111 | versions.tex:48 | `prop:versions:tape` | proved; finite analogue computed | proved + computed | Proposition (status removed) | add, where the number is quoted in the text: "A direct computation (code in the accompanying repository) gives/confirms ..."; otherwise drop the computation from the paper and list it in the Code-and-data table |
| 112 | versions.tex:60 | `prop:versions:shared` | proved; counting step computed | proved + computed | Proposition (status removed) | add, where the number is quoted in the text: "A direct computation (code in the accompanying repository) gives/confirms ..."; otherwise drop the computation from the paper and list it in the Code-and-data table |
| 113 | versions.tex:74 | `thm:versions:nocoding` | proved; arithmetic and covering numbers computed | proved + computed | Theorem (status removed) | add, where the number is quoted in the text: "A direct computation (code in the accompanying repository) gives/confirms ..."; otherwise drop the computation from the paper and list it in the Code-and-data table |
| 114 | versions.tex:88 | `prop:versions:covering` | proved; computed | proved + computed | Proposition (status removed) | add, where the number is quoted in the text: "A direct computation (code in the accompanying repository) gives/confirms ..."; otherwise drop the computation from the paper and list it in the Code-and-data table |

### 4.2 Every place with process vocabulary or an unverified-literature hedge

Scan of the visible text (comments, `\status{}` and `\src{}` removed; `app-verification.tex` excluded because it is dropped as a whole): 111 distinct hits. Kinds: H1–H10 / verdict (19, of which 15 in Table 1), check-script ids (17), track names and "the notes" (12), "request"/"brief" (14), "draft"/"e-mail" (12), literature hedges (28), history-of-writing words ("superseded", "An earlier version") (2), to-do phrases ("not written out", "should be checked") (7). The acknowledgements sentence that the binding note prescribes ("checked by independent AI referees") is allowed and is not listed as a defect; the Code-and-data paths `research/tracks/*/referee_code/` are (P1X-30). Each hit is covered by an issue: H1–H10 → P1X-10, P1X-22; check ids and track names → P1X-20; request → P1X-11, P1X-21; draft → P1X-19; hedges → P1X-14, P1X-15, P1X-18, P1X-34; to-do → P1X-18, P1X-24; history-of-writing → P1X-23, P1X-39.

| file:line | kind | context |
|---|---|---|
| app-comp.tex:11 | to-do | `tape) and the cost of running the clocks are not written out; this part is a proof sketch.` |
| app-examples.tex:140 | request/brief | `H\"anni's e-mail argument, as quoted in his request \citep{hanni2026request}, reads:` |
| app-examples.tex:140 | draft/e-mail | `H\"anni's e-mail argument, as quoted in his request \citep{ha` |
| app-hist.tex:104 | to-do | `ity of entropy on a finite alphabet; this is not written out, so this case is a proof sketch.` |
| app-learn.tex:33 | track name | `\emph{Integrability} (not written out in the notes for (b)). If $\Ex_\mu\KL(P\/P')=\infty$ ther` |
| app-learn.tex:33 | to-do | `\emph{Integrability} (not written out in the notes for (b)). If $\Ex_\mu\KL(P\/P')` |
| app-learn.tex:106 | unchecked-literature hedge | `on gain \citep{orseau2013universal} (content not checked).` |
| app-learn.tex:119 | track name | `An earlier version of the context notes read \cref{..} as ``matching the $O(1/n)$ Ce` |
| app-learn.tex:119 | history-of-writing | `An earlier version of the context notes read \cref{..} as ``mat` |
| app-learn.tex:129 | track name | `\emph{Comparison with other bounds} (foundations §6.6; the cited works were not checked against` |
| app-learn.tex:129 | unchecked-literature hedge | `nds} (foundations §6.6; the cited works were not checked against their sources). \emph{Occam} \citep{` |
| app-learn.tex:133 | unchecked-literature hedge | `itet{chater2007ideal}; their exact model was not checked.` |
| app-learn.tex:141 | check/script id | `f{..} and here are taken from these outputs. Foundations: c4 (dominance, order independence and the worst` |
| app-setting.tex:81 | unchecked-literature hedge | `his is due to \citet{zvonkin1970complexity} (not checked against the source); the proof below covers ` |
| app-setting.tex:115 | check/script id | ` proper subsets of $S$ only ``$\le$'' holds; check c6 confirms both facts on examples.) The index ` |
| app-setting.tex:117 | check/script id | `des vanish; so $\nutri^{\otimes k}$ is weak (c1 checks $k=2$ exhaustively, 1458 inequalities; r1 al` |
| app-setting.tex:125 | check/script id | `(D)$, with equality on the $E_{\vec\imath}$ (c9(b) for $k\le4$; r1).` |
| app-setting.tex:132 | track name | `\paragraph{Reformulation (proof sketch; foundations Problem 3.6).} Suppose an lsc $\nu_P$ has approximat` |
| app-setting.tex:132 | unchecked-literature hedge | ` sets \citep{strassen1965existence} (quoted, not checked against the source), such a coupling exists ` |
| app-setting.tex:134 | to-do | `Two steps are not written out: the Strassen step is quoted, and the reduct` |
| app-setting.tex:151 | check/script id | `rmalised probabilities are order-independent (c10(a4)).` |
| app-setting.tex:166 | check/script id | `ontributes a point mass on its stored label (c10(b) checks this exactly on 16,200 cases, repeated input` |
| app-versions.tex:35 | check/script id | `$2^\ell\log3<d$, i.e.\ with $3^{2^\ell}<2^d$ (c8(a)). \emph{$\log(1/\Omtail{\ell})\le\Kpad(\ell)+` |
| app-versions.tex:55 | history-of-writing | `\begin{remark}[The hashing bound, superseded]\label{rem:versions:hashing}` |
| app-versions.tex:60 | check/script id | `d independent, and so are their lowest bits (c2 checks this exhaustively for $(q,k)\in\{(3,2),(3,3)` |
| app-versions.tex:86 | check/script id | `og(d/\log3)\rceil-1$, so that $3^{2^g}<2^d$ (c8(a) checks the arithmetic for all $d\le2\cdot10^5$ and ` |
| app-versions.tex:92 | unchecked-literature hedge | ` \citep{levin2016occam,epstein2011sets} ; we have not checked its statement, nor whether it applies to inf` |
| app-versions.tex:99 | check/script id | `il$ and $d':=2^s-2\ge d$; then $d'+2<2(d+2)$ (c8(d)). There are at most $\binom{2^{d'+1}-1}{k}2^k` |
| app-versions.tex:102 | check/script id | `Check c8(c) computes, for $d\le3$ and $k\le3$, the exact` |
| app-versions.tex:102 | unchecked-literature hedge | `an1973families}, reported to be optimal ; we did not check optimality against the source, and the check` |
| comp.tex:128 | unchecked-literature hedge | `.}); the other claims are the slides' and we have not checked them.` |
| comp.tex:136 | to-do | `ersus multitape, the cost of the clocks) are not written out.` |
| discussion.tex:13 | unchecked-literature hedge | `er's universal chronological semimeasure (we have not checked the identification against his texts), and H` |
| discussion.tex:31 | track name | `rived the proofs and wrote independent code; the notes were then revised, and the paper was written` |
| examples.tex:7 | request/brief | `\citet{hanni2026request} proposed two examples in which SFI ``does m` |
| examples.tex:7 | draft/e-mail | `h H\"anni reported with an argument from his e-mail to Eisenstat. We work both out and add examp` |
| examples.tex:35 | request/brief | `SI but high loss under SFI'' \citep{hanni2026request}. The map $f\mapsto(x_1,\dots,x_{N-1})$ is a` |
| examples.tex:112 | request/brief | `nction, up to $o(n)$ terms'' \citep{hanni2026request}. We take as threshold function the \emph{th` |
| examples.tex:112 | draft/e-mail | `H\"anni's e-mail claims that SFI's ``log loss \dots{} is the ` |
| examples.tex:161 | draft/e-mail | `\begin{remark}[H\"anni's e-mail argument]\label{rem:ex:email}` |
| hist.tex:12 | request/brief | `em (``Thm 1'') for simple reveal orders; his request conjectures that SFI whose hypotheses see th` |
| hist.tex:101 | to-do | ` case (b) needs $C_{\rm dir}$ to within $1$, not written out.` |
| hist.tex:117 | request/brief | `H\"anni's request: ``if you further give the function oracle a` |
| hist.tex:127 | unchecked-literature hedge | `-based universal priors form the same class (abstract seen only); we have not checked whether \cref{..}` |
| hist.tex:135 | unchecked-literature hedge | `000theory,hutter2005universal} is known, but not checked against the sources (he uses finite alphabet` |
| hist.tex:157 | unchecked-literature hedge | ` odd bit repeated at the next even position (abstract seen only). With $X=Y=\{0,1\}$ and the identity c` |
| hist.tex:165 | H1-H10/verdict | `ct on H\"anni's conjecture]\label{rem:hist:H4verdict}` |
| intro.tex:9 | unchecked-literature hedge | `ep{hutter2000theory,hutter2005universal}; we have not checked the identification against Hutter's texts.` |
| intro.tex:26 | track name | `lds (\cref{..}). The converse asked about in the notes, ``no simple separating property implies goo` |
| intro.tex:26 | H1-H10/verdict | `repairs (\cref{..}). \cref{..} lists the ten working hypotheses with which this study began and what becam` |
| intro.tex:26 | draft/e-mail | `ut-of-distribution generalisation in the PDF draft are false as literally stated; the intended ` |
| intro.tex:34 | H1-H10/verdict | `& hypothesis (paraphrased) & verdict and where\\` |
| intro.tex:36 | H1-H10/verdict | `H1(a) & Universal lsc function semimeasures exi` |
| intro.tex:37 | H1-H10/verdict | `H1(b) & The program mixture loses about $K(\dom` |
| intro.tex:38 | H1-H10/verdict | `H1(c) & The mixture of product laws is a third ` |
| intro.tex:39 | H1-H10/verdict | `H1 & SFI's cumulative loss does not depend on t` |
| intro.tex:40 | H1-H10/verdict | `H2 & Dominance over computable predictors that ` |
| intro.tex:41 | H1-H10/verdict | `H3 & H\"anni's counterexamples; his Theorem 1 f` |
| intro.tex:42 | H1-H10/verdict | `H4 & With the list of previous inputs, SFI is t` |
| intro.tex:43 | H1-H10/verdict | `H5 & Cyclic permutation: high loss under SFI, l` |
| intro.tex:44 | H1-H10/verdict | `H6 & Eisenstat's example: SFI pays about $\frac` |
| intro.tex:45 | H1-H10/verdict | `H7 & For every input law and computable conditi` |
| intro.tex:46 | H1-H10/verdict | `H8 & An unseen simple property gives constant p` |
| intro.tex:47 | H1-H10/verdict | `H9 & A steeper simplicity prior with private ra` |
| intro.tex:48 | H1-H10/verdict | `H10 & Time-bounded and circuit versions; NN Baye` |
| intro.tex:51 | request/brief | `ost come from \citet{hanni2026notes,hanni2026request}; H1, H2 and H7 formalise natural expectatio` |
| intro.tex:51 | H1-H10/verdict | `\caption{The working hypotheses H1--H10, paraphrased, with verdicts. Most ` |
| intro.tex:52 | H1-H10/verdict | `\label{tab:intro:verdicts}` |
| intro.tex:55 | request/brief | `m \citet{hanni2026notes} and \citet{hanni2026request}: the dominance template for samplers that s` |
| intro.tex:55 | unchecked-literature hedge | `ubstance for \cref{..}; we have checked them only at the level of abstracts and tables of contents (\cref{..}).` |
| intro.tex:57 | unchecked-literature hedge | `ef{..}). The main theorems of the slides are not checked here. The constants in our bounds depend on ` |
| learn.tex:7 | request/brief | ` ideal supervised learning'' \citep{hanni2026request}. This section states the guarantees behind ` |
| learn.tex:49 | track name | `against a bound of $1$ in a finite analogue, foundations r6); \eqref{eq:learn:dominance} still holds, an` |
| learn.tex:49 | unchecked-literature hedge | `rem \citep{solomonoff1978complexity} (source not checked). If the rule may see $F$, e.g.\ picks input` |
| learn.tex:77 | unchecked-literature hedge | `ng} use a permutation argument of this kind (not checked). In (b) the stamps make inputs distinct; (c` |
| learn.tex:87 | check/script id | `95$, $0.113$, $5\cdot10^{-4}$ at $n=2,10,20$ (foundations c5). This refutes the fresh-noise form of the su` |
| learn.tex:87 | track name | `5$, $0.113$, $5\cdot10^{-4}$ at $n=2,10,20$ (foundations c5). This refutes the fresh-noise form of the s` |
| learn.tex:87 | H1-H10/verdict | `e form of the supervised-learning hypothesis H7 for random-function SFI (\cref{..}). The fin` |
| learn.tex:108 | check/script id | `dom finite instances had non-monotone curves (foundations r12); see also \cref{..}.` |
| learn.tex:108 | track name | `om finite instances had non-monotone curves (foundations r12); see also \cref{..}.` |
| learn.tex:112 | check/script id | `stances the largest $(n+1)r_n/K$ was $0.873$ (foundations r12).` |
| learn.tex:112 | track name | `tances the largest $(n+1)r_n/K$ was $0.873$ (foundations r12).` |
| learn.tex:171 | unchecked-literature hedge | `A table-of-contents snippet shows a section ``Supervised Learning from E` |
| nn.tex:8 | request/brief | `omonoff function induction'' \citep{hanni2026request}, referring to slides by Vaintrob and H\"ann` |
| nn.tex:81 | unchecked-literature hedge | `)) and the ladder of Appendix K; the rest is unchecked. \cref{..}(a) is the Markov half of the rele` |
| nn.tex:91 | unchecked-literature hedge | `ate Solomonoff induction. These descriptions follow the abstracts.` |
| ood.tex:7 | draft/e-mail | `g term'' is lost \citep{hanni2026notes}. His draft adds a two-sided version, asks for a convers` |
| ood.tex:51 | draft/e-mail | `\subsection{The draft's two-sided result}\label{sec:ood:twosided}` |
| ood.tex:53 | draft/e-mail | ``$y$ is a correct proof of $x$''), H\"anni's draft states that ``the probability of $P$-abiding` |
| ood.tex:63 | draft/e-mail | `he bounds hold for every amount of data. The draft's upper bound must be read as a lower bound ` |
| ood.tex:65 | draft/e-mail | `\begin{proposition}[the draft's bounds as stated are false]\label{prop:ood` |
| related.tex:6 | unchecked-literature hedge | `lement of a new pair from the first (we have seen only the abstract). Secondary sources describe it` |
| related.tex:8 | unchecked-literature hedge | `n up to constant factors is expected but was not checked against his texts; Hutter lists supervised l` |
| related.tex:10 | unchecked-literature hedge | `selection result coincides with \cref{..} we have not checked. \citet{poland2005asymptotics} show that two` |
| related.tex:12 | unchecked-literature hedge | `ting algorithms \citep{vovk1992universal} we have not examined. Inductive inference of recursive functions ` |
| related.tex:18 | to-do | `tatements of \cref{..}(b),(c). Each of these should be checked against \citet{solomonoff2008three}, \citet{` |
| setting.tex:12 | unchecked-literature hedge | ` ``lsc'' means lower semicomputable. We use, without re-checking the sources \citep{levin1974laws,gacs1974sym` |
| setting.tex:40 | unchecked-literature hedge | `heron1975random,shafer1976mathematical} ; we have not checked the analogy against these sources.` |
| setting.tex:44 | check/script id | `a,1)\}$, and $0$ elsewhere. $\nutri$ is weak (c1), and $E_1,E_2,E_3$ are pairwise inconsistent` |
| setting.tex:119 | check/script id | `measure probability $\frac14$ in both orders (c3). On a random six-point mixture the semimeasu` |
| setting.tex:119 | track name | `alised loss between $7.33$ and $10.64$ bits (context c3).` |
| setting.tex:156 | check/script id | `d}=x_1\oplus x_2$, with probability $2^{-d}$ (c9(c)). For every $x_1$ some $x_2$ has $K(x_2\mid x` |
| setting.tex:175 | unchecked-literature hedge | `ff's $M$ see \citet{leike2015computability} (not checked against the source).` |
| steeper.tex:14 | request/brief | `both get similar posterior'' \citep{hanni2026request}. At $\lambda=1$ this is confirmed with expl` |
| versions.tex:4 | request/brief | `en it should explain that)'' \citep{hanni2026request}. They are not equivalent: \cref{..} summari` |
| versions.tex:4 | draft/e-mail | `H\"anni's draft has a section headed ``Equivalence between K` |
| versions.tex:21 | unchecked-literature hedge | ` from the first \citep{solomonoff2008three} (abstract only seen). Secondary sources write its predictio` |
| versions.tex:123 | track name | ` larger than $K(k)+O(1)$ in any row. Source: foundations Table 4.12.}` |
| versions.tex:123 | request/brief | `mimeasure versions compared (H\"anni's later request). Data sets $D$ with inputs of length at mos` |
| versions.tex:137 | request/brief | `\begin{remark}[Answer to H\"anni's request]\label{rem:versions:answer}` |
| versions.tex:144 | draft/e-mail | `The coding theorem, which H\"anni's draft names as the tool, gives agreement of all fi` |

### 4.3 The verification appendix: drop, and what moves where

`sections/app-verification.tex` (Appendix I, PDF pages 96–103) is dropped entirely (remove `\input{sections/app-verification}` from `main.tex`). Its parts go as follows.

| part of Appendix I | destination |
|---|---|
| I.1 "Process" (roles, five tracks, referees, revision, planning editor; "No referee found a fatal issue ...") | Acknowledgements only, in the two-to-four sentences already there (discussion.tex line 31): developed with Claude (Anthropic) under the author's direction; each part checked by independent AI referee passes that re-derived the proofs and wrote independent code; what a human has checked (P1X-31). Nothing else. |
| scripts table (seeds, re-runs, Python versions) | New short appendix "Code and data": one table result → script → command → output file → seed, plus the environment line (Python 3.11, numpy 2.4.6, scipy 1.17.1, mpmath 1.3.0) and the reproduction loop (P1X-30). |
| I.2 "Corrections" longtable (58 rows) | Dropped. Corrections of the author's notes that inform the reader stay where they occur in the body (prop:hist:sketchfails, prop:ood:draftfalse, prop:ood:converse, rem:comp:majority, rem:ex:email). Internal corrections of the tracks are not mentioned anywhere (this also removes rem:learn:cesaro, P1X-23). |
| I.3 cross-track conflicts C1–C25 (incl. "C25: a promised Wyeth–Hutter reference") | Dropped. |
| I.4 "What is not fully established": conjectures; proof sketches and conditional results; "results checked by their authors only"; the slides | Conjectures stay as conjecture environments; each proof sketch and conditional result is marked where it is stated (section 4.1, rows 1–7); the slides' unverified claims are stated as theirs in Section 11 (P1X-33). "Results checked by their authors only" is dropped (the acknowledgements say how the paper was checked). |
| I.5 "Literature" (no source could be opened) | Dropped after the literature is checked (P1X-14); any remaining limitation is one sentence in the acknowledgements. |
| I.6 "Reproduction" | Code-and-data appendix. |
| I.7 "Unresolved points" (length, conversion, status vocabulary, paragraph labels, ω-indexing note, shared bibliography) | Dropped; the items are addressed by P1X-08, P1X-27, P1X-28 and the bib fixes. |

No bibliography entry is cited only in Appendix I (checked against `main.aux`), so dropping it removes no reference.

### 4.4 Mechanical steps, in order

1. Rewrite the 114 environments of the table in 4.1 (content changes first, while `\status` still shows what each item is).
2. Fix the 111 visible process-vocabulary and hedge hits of 4.2 (most are covered by rewrites in step 1 and by the literature check).
3. Remove `\status{...}` and `\src{...}` from all section files (203 + 203 calls, plus the inline `\status` in setting.tex line 40 and app-versions.tex lines 92 and 102), then delete both macros from `preamble.tex`, so that any leftover call fails to compile.
4. Delete Table 1 (tab:intro:verdicts) and the reference to it in learn.tex line 87; rewrite the corrections paragraph (P1X-10).
5. Drop Appendix I; add the Code-and-data appendix.
6. Replace the `\paragraph{Open question.}` labels by a numbered question environment (P1X-27).
7. Bibliography: drop `hanni2026request`, `hanni2026lesswrong`; fix `hanni2026notes`; add the draft entry if cited; apply the field fixes of section 5; add the missing related work (decision complexity) after reading it.
8. Delete the source-file comments that point to `research/tracks/...`, `CLAIMS.md`, `OUTLINE.md` and "writer"/"framing editor" (they are invisible in the PDF but arXiv distributes the sources): every section file starts with such a comment block (e.g. hist.tex lines 1–9, main.tex lines 5–7 and 36–38).
9. Build: add `\hypersetup{pdftitle=..., pdfauthor=...}`; submit `main.bbl` (arXiv does not run `merge_bib.py`); check that no string from the list "track, referee, ledger, notes-final, brief, orchestrator, request, verdict, H1–H10, snippet, unverified, not checked, draft, Wyeth" remains in `pdftotext main.pdf` (except "referee" in the disclosure sentence the binding note prescribes).


## 5. Bibliography: every entry in bib/*.bib (task 5)

All 84 entries of the ten source files (`all.bib` is generated from them by `merge_bib.py`; no key is duplicated) were searched with WebSearch on 2026-10-12. arxiv.org, dblp.org, crossref.org, lesswrong.com and kaarelh.github.io do not resolve from this environment, so a fact counts as verified when publisher, repository, DBLP/mlanthology, PMLR or library records shown by the search agree. 72 entries are printed in the PDF; 12 are not cited by Paper 1 and are therefore not printed (10 Paper-2 entries in `core.bib`, plus `claudeSFI2026fundamentals` and `claude2026whatfollows`).

**Result.** verified as printed: 57 printed + 10 not printed; fixable (verified, with a field to add or correct): 11; verified against the local copy only: 1 (the slides); unverifiable and printed: 3 (`hanni2026notes` as printed, `hanni2026request`, `hanni2026lesswrong`); not printed: 2.

**Content versus metadata.** Verifying an entry's metadata does not verify the content the paper attributes to it. Two entries are used as sources of content that no search confirmed: `ozkural2017ultimate` and `ozkural2015ultimate` (the operator-induction formula; P1X-34). The content attributed to `hutter2000theory`, `hutter2005universal`, `hutter2007aixi`, `lattimore2011universal`, `lattimore2013nofree`, `wood2013non`, `levin2016occam`, `kleitman1973families`, `yang2019fine`, `basri2019convergence`, `chater2007ideal`, `haussler1994predicting`, `solomonoff1978complexity`, `leike2015computability` must be checked in the text before the hedges are removed (P1X-14). The search results did confirm several of these at abstract level: Solomonoff (2008) treats "an unordered set of ordered pairs"; Lattimore–Hutter–Gavane (2011) report that "the unnormalised version can fail" on simple recursive sub-patterns; Wood–Sunehag–Hutter (2013) find that "the Solomonoff and Levin constructions define the same class of priors"; Levin (2016) bounds the gap between a set's universal probability and its simplest member by the set's information about the halting sequence; the Springer description of Hutter (2005) lists "supervised learning" among AIXI's problem classes; Lattimore–Hutter (2013) give "an off-line classification algorithm inspired by Solomonoff induction" and a random-selection result (P1X-16).

**Recommended additions** (verified by WebSearch; P1X-17): Loveland, "A variant of the Kolmogorov concept of complexity", Information and Control 15 (1969) — pages differ between sources (510–526 or 602–619), check before citing; Uspensky and Shen, "Relations between varieties of Kolmogorov complexities", Mathematical Systems Theory 29(3) (1996) 271–292 (Crossref 270–291; doi 10.1007/BF01201280); Shen, Uspensky and Vereshchagin, *Kolmogorov Complexity and Algorithmic Randomness*, AMS Mathematical Surveys and Monographs 220 (2017).

| bib file | key | printed in P1 | class | data confirmed (WebSearch, 2026-10-12) | action |
|---|---|---|---|---|---|
| comp.bib | filan2016loss | yes | verified | AISTATS 2016, PMLR 51:1394-1402; author order Filan, Leike, Hutter on PMLR (arXiv: Filan, Hutter, Leike) | none |
| comp.bib | impagliazzo1990no | yes | verified | FOCS 1990, 812-821 | none |
| comp.bib | littlestone1994weighted | yes | verified | Inf. Comput. 108(2):212-261, doi 10.1006/inco.1994.1009 | none |
| comp.bib | schmidhuber2002speed | yes | verified | COLT 2002 (eds Kivinen, Sloan), Springer, 216-228, doi 10.1007/3-540-45435-7_15; LNAI 2375 not confirmed | none |
| core.bib | barron1991minimum | yes | verified | IEEE TIT 37(4):1034-1054 (correction 37(6):1738) | none |
| core.bib | barzdin1972prediction | yes | fixable | Soviet Math. Dokl. 13:1224-1228 (transl. of Dokl. Akad. Nauk SSSR 206(3):521-524); authors Barzdin (Bārzdiņš) & Freivalds | add pages 1224--1228 |
| core.bib | bhattacharya2019fractional | no | verified | Ann. Stat. 47(1):39-66 | uncited |
| core.bib | bissiri2016general | no | verified | JRSS-B 78(5):1103-1130 | uncited |
| core.bib | claude2026whatfollows | no | not printed (uncited) | not printed in Paper 1 | none for Paper 1 (relevant for Paper 2) |
| core.bib | claudeSFI2026fundamentals | no | not printed (uncited) | not printed in Paper 1 | none (rename keys later; invisible) |
| core.bib | claudeSFI2026steeper | yes | fixable | replace howpublished "Companion paper, draft" by the arXiv identifier once both are posted (or "Preprint, 2026") | FIXABLE at submission |
| core.bib | gacs2001algorithmic | no | verified | IEEE TIT 47(6):2443-2463 | uncited in P1: harmless (bibtex drops it) |
| core.bib | gneiting2007strictly | no | verified | JASA 102(477):359-378 | uncited |
| core.bib | gold1967language | yes | verified | Inf. Control 10(5):447-474 | none |
| core.bib | grunwald2007minimum | yes | verified | MIT Press 2007 | none |
| core.bib | grunwald2012safe | no | verified | ALT 2012, LNCS 7568, 169-183 | uncited |
| core.bib | grunwald2017inconsistency | no | verified | Bayesian Anal. 12(4):1069-1103, doi 10.1214/17-BA1085 | uncited |
| core.bib | hanni2026lesswrong | yes | unverifiable | the cited proposal text is also in Hänni's note "beating solomonoff induction at grokking a notion" (research/prior/hanni-grokking-a-notion.md) | DROP from Paper 1; cite hanni2026notes only |
| core.bib | hanni2026notes | yes | unverifiable | local copies in research/prior/ | FIXABLE: confirm the repository is public; cite with an informative title, e.g. "Hänni, K. (2025-26). Notes on Solomonoff function induction. Unpublished notes, https://github.com/kaarelh/notes"; or deposit the cited notes in the paper's repository |
| core.bib | hanni2026request | yes | unverifiable | text in research/00-brief.md | DROP: rephrase every citing sentence (see report), credit Eisenstat as "personal communication" in acknowledgements |
| core.bib | hoeffding1963probability | yes | fixable | JASA 58(301):13-30, doi 10.1080/01621459.1963.10500830 | add number=301, doi |
| core.bib | li2008introduction | yes | verified | Springer, 3rd ed., 2008, Texts in CS, doi 10.1007/978-0-387-49820-1 | none |
| core.bib | littlestone1988learning | yes | verified | Mach. Learn. 2(4):285-318 | none |
| core.bib | sion1958general | yes | verified | Pacific J. Math 8(1):171-176, doi 10.2140/pjm.1958.8.171 | add doi (optional) |
| core.bib | vaintrobhanni2026nnbayes | yes | verified (local copy); URL unconfirmed | title slide of research/prior/vaintrob-hanni-nnbayes-generalization-slides.pdf: "A Generalization Result for Overparametrized Neural Net Bayesian Learning", Dmitry Vaintrob, Kaarel Hänni, ILIAD 2026; URL kaarelh.github.io/... does not resolve here and is not found by search | keep; check URL before submission (or deposit slides in the code-and-data repository and cite that) |
| core.bib | vereshchagin2004kolmogorov | no | verified | IEEE TIT 50(12):3265-3290, doi 10.1109/TIT.2004.838346 | uncited |
| core.bib | vereshchagin2010rate | no | verified | IEEE TIT 56(7):3438-3454, doi 10.1109/TIT.2010.2048491 | uncited |
| core.bib | vereshchagin2017algorithmic | no | verified | LNCS 10010, 669-737, Springer 2017 | uncited |
| core.bib | ville1939etude | yes | fixable | Numdam: thesis, Thèses de l'entre-deux-guerres no. 218 (1939), 124 pp.; Gauthier-Villars imprint NOT confirmed by search | cite as thesis per Numdam record, or confirm imprint |
| core.bib | vovk2005algorithmic | yes | verified | Springer 2005, doi 10.1007/b106715 | none |
| core.bib | zhang2006epsilon | no | verified | Ann. Stat. 34(5):2180-2210 | uncited |
| examples.bib | robbins1955remark | yes | verified | Amer. Math. Monthly 62(1):26-29, doi 10.2307/2308012 | none |
| hist.bib | lattimore2011universal | yes | verified | ALT 2011, LNCS (LNAI) 6925, 262-276, doi 10.1007/978-3-642-24412-4_22 | none |
| hist.bib | wood2013non | yes | fixable | in Algorithmic Probability and Friends, LNCS 7070, doi 10.1007/978-3-642-44958-1_33 (pages 417-425 not confirmed by this search) | add volume=7070 (same volume as lattimore2013nofree entry) |
| learn.bib | blumer1987occam | yes | verified | Inf. Process. Lett. 24(6):377-380 | none |
| learn.bib | cesabianchi2004generalization | yes | verified | IEEE TIT 50(9):2050-2057, doi 10.1109/TIT.2004.833339 | none |
| learn.bib | cesabianchi2006prediction | yes | verified | CUP 2006, ISBN 978-0-521-84108-5 | none |
| learn.bib | chater2007ideal | yes | verified | J. Math. Psych. 51(3):135-163 | none |
| learn.bib | haussler1994predicting | yes | verified | Inf. Comput. 115(2):248-292 | none |
| learn.bib | hutter2000theory | yes | verified | arXiv:cs/0004001 (3 Apr 2000) | none |
| learn.bib | hutter2005universal | yes | verified | Springer, Berlin 2005, Texts in TCS (EATCS), doi 10.1007/b138233; publisher description lists "supervised learning" among problem classes | add series; rem:learn:hutterEX can cite the book description too |
| learn.bib | hutter2007aixi | yes | verified | in Goertzel & Pennachin (eds), Artificial General Intelligence, Springer (Cognitive Technologies) 2007, 227-290; arXiv cs/0701125 | none |
| learn.bib | littlestone1989online | yes | verified | COLT 1989 (eds Rivest, Haussler, Warmuth), Morgan Kaufmann, 269-284 | none |
| learn.bib | mcallester1999some | yes | verified | Mach. Learn. 37(3):355-363, doi 10.1023/A:1007618624809 | none |
| learn.bib | orseau2013universal | yes | verified | ALT 2013 Singapore, Springer, pp. 158-172, doi 10.1007/978-3-642-40935-6_12; LNCS volume (8139) not confirmed by search | none (volume correctly omitted) |
| learn.bib | solomonoff1978complexity | yes | verified | IEEE TIT IT-24(4):422-432, July 1978 | none |
| learn.bib | vovk1990aggregating | yes | fixable | COLT 1990 (eds Fulk, Case), Morgan Kaufmann, pp. 371-383 (Royal Holloway repository; one arXiv reference list says 371-386) | add pages 371--383 and editors, or leave pages out |
| nn.bib | basri2019convergence | yes | verified | NeurIPS 2019 (NeurIPS 32); pages 4761-4771 (mlanthology) vs 4763-4772 (IUCC) | pages correctly omitted |
| nn.bib | buzaglo2024 | yes | verified | ICML 2024, PMLR 235:5035-5081 | none |
| nn.bib | dingle2018input | yes | verified | Nat. Commun. 9:761 (2018), doi 10.1038/s41467-018-03101-6 | none |
| nn.bib | goldblum2023no | yes | verified | ICML 2024 (position paper), PMLR 235:15788-15808; arXiv 2304.05366 (2023) | key year 2023 vs entry year 2024: harmless |
| nn.bib | grau2024learning | yes | verified | ICML 2024, PMLR 235:16178-16205 | none |
| nn.bib | kamath2020approximate | yes | verified | COLT 2020, PMLR 125:2236-2262 | none |
| nn.bib | mingard2021sgd | yes | verified | JMLR 22(79):1-64 | none |
| nn.bib | mingard2025deep | yes | verified | Nat. Commun. 16:220 (2025), doi 10.1038/s41467-024-54813-x | none |
| nn.bib | vaintrob2026width | yes | verified | arXiv:2607.05735 (7 Jul 2026), Vaintrob & Hänni | none (content statements must be the abstract's) |
| nn.bib | valle2019deep | yes | verified | ICLR 2019; arXiv 1805.08522 | none |
| nn.bib | yang2019fine | yes | verified | arXiv:1907.10599 (v4 9 Apr 2020); MSR lists ICLR 2020 | optional: check whether an ICLR 2020 version exists before citing it |
| ood.bib | leike2015bad | yes | verified | COLT 2015, PMLR 40:1244-1259 (eds Grünwald, Hazan, Kale) | none |
| related.bib | case1983comparison | yes | fixable | TCS 25(2):193-220, doi 10.1016/0304-3975(83)90061-0 | add number=2 |
| related.bib | lattimore2013nofree | yes | verified | Algorithmic Probability and Friends (ed. Dowe), LNCS 7070, 223-235, doi 10.1007/978-3-642-44958-1_17 | none |
| related.bib | ozkural2015ultimate | yes | verified | arXiv:1504.03303; DBLP gives the bib title "Physical Measure and Complexity of Intelligence"; later version/AGI 2016 title "Physical Complexity and Limits of Inductive Inference Systems" | cite with arXiv version (v1) or the AGI 2016 version; content cited only via a snippet -> replace by a primary source (see report) |
| related.bib | poland2005asymptotics | yes | verified | IEEE TIT 51(11):3780-3795, doi 10.1109/TIT.2005.856956 (erratum 2006) | none |
| related.bib | ryabko2006pattern | yes | verified | JMLR 7:645-664 | none |
| related.bib | vovk1992universal | yes | verified | Inf. Comput. 96(2):245-277, Feb 1992 | none |
| setting.bib | chaitin1975theory | yes | verified | JACM 22(3):329-340, doi 10.1145/321892.321894 | none |
| setting.bib | choquet1954theory | yes | verified | Ann. Inst. Fourier 5 (1954) 131-295, doi 10.5802/aif.53 | none |
| setting.bib | day2011increasing | yes | fixable | Trans. AMS, Oct 2011 confirmed (VUW award page); volume 363(10):5577-5604 NOT confirmed by search; conference version CCR 2009 pp. 263-273 (the bib comment says "CCC 2009": wrong venue name, comment only) | keep without volume/pages, or confirm 363(10):5577-5604 via MathSciNet/AMS and add |
| setting.bib | epstein2011sets | yes | verified | arXiv:1107.1458 | none |
| setting.bib | gacs1974symmetry | yes | fixable | Soviet Math. Dokl. 15(5):1477-1480 (transl. of Dokl. Akad. Nauk SSSR 218(6):1265-1267) | add number=5 |
| setting.bib | gacs1983relation | yes | verified | TCS 22(1-2):71-93 (Jan 1983); short version FOCS 1981 296-303 | none |
| setting.bib | kleitman1973families | yes | fixable | Discrete Math. 6(3):255-262 (1973) | add number=3 |
| setting.bib | leike2015computability | yes | verified | ALT 2015, LNCS 9355, 364-378, doi 10.1007/978-3-319-24486-0_24 | none |
| setting.bib | levin1974laws | yes | verified | Problems Inform. Transmission 10(3):206-210 (some cite 206-211); Russian orig. Probl. Peredachi Inf. 10(3):30-35 | none |
| setting.bib | levin2016occam | yes | verified | Ann. Pure Appl. Logic 167(10):897-900 (2016); arXiv 1403.4539 | none |
| setting.bib | matheron1975random | yes | verified | Wiley, New York, 1975 [imprint 1974, c1975], Wiley Ser. Prob. Math. Stat. | none |
| setting.bib | ozkural2017ultimate | yes | verified | arXiv:1709.03879 (DBLP CoRR 2017) | content (the product formula for operator induction) not confirmed by any search; replace as source of the formula (see report) |
| setting.bib | shafer1976mathematical | yes | verified | Princeton UP 1976 | none |
| setting.bib | solomonoff2008three | yes | verified | Comput. J. 51(5):566-570, doi 10.1093/comjnl/bxm120; abstract confirms "unordered set of ordered pairs" | none (content: only the abstract confirmed) |
| setting.bib | strassen1965existence | yes | verified | Ann. Math. Stat. 36(2):423-439, doi 10.1214/aoms/1177700153 | none |
| setting.bib | zvonkin1970complexity | yes | verified | Russian Math. Surveys 25(6):83-124 (transl. of Uspekhi 25:6(156) 85-127) | none |
| steeper.bib | grunwald2007suboptimal | yes | fixable | Mach. Learn. 66(2-3):119-149, doi 10.1007/s10994-007-0716-7 | add number={2--3}, doi |
| steeper.bib | zhu2025quantifying | yes | verified | COLT 2025, PMLR 291:6124-6155 | none |
| steeper.bib | zhu2026overfitting | yes | verified | arXiv:2603.22644 (23 Mar 2026), Zhu, Ohannessian, Srebro | none |

## 6. Structure and length against a typical arXiv paper in learning theory / AIT (task 6)

**Current shape.** 103 pages: title + abstract + contents (pp. 1–2), introduction (pp. 3–7), Sections 2–9 of results (pp. 7–47), summary of Paper 2 (pp. 47–49), related work (pp. 49–50, one page), discussion and open problems (pp. 50–52), references (pp. 52–56), eight proof appendices (pp. 57–96) and the verification appendix (pp. 96–103). About 50,000 words in the section files; 203 theorem-like environments (33 theorems, 68 propositions, 17 lemmas, 12 corollaries, 48 remarks, 13 definitions, 8 examples, 4 conjectures) and about 20 open questions. No figures.

**Typical arXiv paper in the area.** A foundational paper in algorithmic information theory or learning theory (e.g. the ALT/COLT long versions cited here: Lattimore–Hutter–Gavane 2011, Leike–Hutter 2015; or JMLR/TCS articles) has 20–40 pages including appendices, one to three main theorems stated informally in the introduction, a contributions list of four to six short items, a related-work section of one to two pages based on read sources, preliminaries, results, discussion. Very long AIT surveys exist (Vereshchagin–Shen 2017 is 69 pages), but they are surveys.

**Assessment.** The paper is about two to three times the usual length and covers three papers' worth of topics: (i) foundations (definitions, versions, learning theorems), (ii) order and history (Sections 5–6), (iii) out-of-distribution, computable versions and neural networks (Sections 7–9). The introduction has a contributions list (good) but it is a catalogue (8 bullets, 65 cross-references) and no informal main theorems; the related-work section exists (good) but is one page of hedges.

**Recommended structure** (main text ≤ 35 pages; appendices ≤ 35 pages):

| new § | content | from | target pp. |
|---|---|---|---|
| 1 | Introduction: motivation; informal definition; Theorems A–D stated informally (universality/invariance/dominance; no coding theorem; order blindness and SFIhist; the two examples); contributions (5 short bullets); relation to the author's notes; organisation | intro.tex | 3 |
| 2 | Preliminaries and definitions: data, conventions, function machines, universality, SFI, invariance, coding bounds (move weak semimeasures, Möbius, normalised-transfer details to App. A) | setting.tex | 4 |
| 3 | Versions: chain, W gap, tape bound, no coding theorem, table | versions.tex | 3 |
| 4 | Learning: dominance, merging, mistakes, online-to-batch, fresh noise, per-query mixture, Occam comparison (move sec:learn:curves except cor:learn:perstep to App. C) | learn.tex | 4 |
| 5 | Order and history: counterexamples, reveal-law theorem (short), SFIhist universality, SI comparison (move thm:hist:gf, thm:hist:expected, prop:hist:lhg, prop:hist:inputloss details to App. D) | hist.tex | 5 |
| 6 | Worked examples: cyclic permutation, Eisenstat, positive examples (short) | examples.tex | 4 |
| 7 | Out-of-distribution (move ex:ood:easyhard, ex:ood:hanniexamples to App. F) | ood.tex | 3 |
| 8 | Computable versions and neural networks (merge Sections 8 and 9; move rem:comp:apples, prop:comp:samplers, rem:comp:selection, rem:comp:uniformties, rem:nn:slides, rem:nn:literature, rem:nn:rigorous out) | comp.tex, nn.tex | 4 |
| 9 | Related work (2 pp., after reading the sources; include decision complexity, Lattimore–Hutter 2013, Hutter's EX section, operator induction from the primary source) | related.tex | 2 |
| 10 | Discussion and open problems (one paragraph on Paper 2 replaces Section 10) | discussion.tex, steeper.tex | 2 |
| App. | proofs A–H; Code and data | app-*.tex | ≤ 35 |

An alternative that keeps more material: split off Sections 8–9 (computable versions and neural networks, about 9 pages with appendices G–H) as a short third paper.

## 7. Readability (task 7)

### 7.1 Page-1 story and a proposed abstract

Page 1 currently holds the title, a 248-word abstract and the start of a table of contents; the introduction begins on page 3 after a `\newpage`. The abstract lists results without motivation and uses undefined terms (P1X-07). A proposal (about 1,700 characters, under arXiv's limit of 1,920; it also fixes P1X-01 and P1X-02):

> Solomonoff induction is the standard ideal predictor for sequences. We study its analogue for supervised learning, Solomonoff function induction (SFI): Bayesian prediction of labels from input–output pairs under a universal prior over random functions, in which a random program reads random bits shared by all inputs. A universal function machine exists; its law dominates every machine law and is invariant, up to constant factors, under the choice of universal machine and under computable injective re-encodings. The shortest consistent program, the program mixture, the mixture of product laws, SFI and the universal weak semimeasure agree up to K(dom D) bits, but there is no coding theorem for function programs. On every consistent data sequence, chosen in any way, SFI's cumulative log loss exceeds that of every computable random labeller by at most the labeller's complexity; with i.i.d. inputs and deterministic computable labels the averaged predictor has risk O(K/n). Random-function SFI cannot model fresh label noise on repeated inputs; a per-query mixture can. SFI's cumulative loss, measured on its raw sub-probabilities, ignores the order of the data: on a random cyclic permutation of {0,1}^d revealed backwards along its cycle it pays about (d − log₂ e)2^d bits, while Solomonoff induction on the interleaved sequence pays O(1) bits of label loss in expectation. Letting hypotheses see the list of previous inputs gives the universal chronological semimeasure and removes these gaps. We also treat a dominance theorem for computable reveal orders, a coin example due to Sam Eisenstat, out-of-distribution behaviour, time-bounded and circuit versions, and neural-network Bayes.

(If the reveal-law theorem is mentioned with a result, use the wording of P1X-01.)

### 7.2 Motivation and examples

* The first paragraph defines SFI by quoting informal, lower-case notes (P1X-44). The "Why SFI" paragraph is good and should come first, followed by an informal definition in the paper's own words.
* The introduction never shows a small example. The shared-coin law F(x) = ω_{|x|+1} (one fair coin per input length) is the paper's simplest example of what shared randomness buys (prop:versions:shared) and would make "random program reading shared random bits" concrete on page 2; the cyclic permutation is the natural example for order blindness. Both are already in the paper.
* Informal statements of three or four main theorems on page 2 would let a reader decide whether to read on (P1X-29).
* A figure of the chain 2^{−K_F} ≤ W ≤ M_prod ≤ M_F ≤ M_w with the known gaps (from Table 2) would replace a paragraph of prose; a diagram of SFI / SFIhist / SI on the interleaved sequence would anchor Sections 5–6.

### 7.3 Definitions before use

Section 2 is dense but in the right order (data, weak semimeasures, machines, universality, SFI, conventions, basic properties). Fixes are local: P1X-37 (M_F, Mnorm, LHG), the semimeasure convention defined on page 1–2 of the introduction rather than at the end of the reader's guide, and Definition 2.1, which packs eight notions (data set, D+(x,y), restriction, extension, consistency, history, conditional, repeated-input convention) into one paragraph and would read better as a short list.

### 7.4 Voice

With the sole author named Hänni, sentences that assess "Hänni's" claims in the third person must be neutralised (P1X-13). The register is otherwise formal and concise; the remaining informal phrases are listed in P1X-43, P1X-50, P1X-53.


## 8. Numbered issue list
Severity: fatal = false or unsupported mathematical claim, or a claim stronger than the sources; major = missing hypothesis, wrong number, inconsistency, misleading framing, arXiv-standard violation a reader would notice, or a reader cannot follow; minor = local wording or formatting. The same records are in `issues-p1-arxiv.json`.

**P1X-01 (fatal)** — `paper/sections/abstract.tex`, abstract, sentence "A dominance theorem for computable reveal orders holds in its intended reading"; also intro.tex line 19 (contributions bullet "History-aware prediction")
* Problem: The abstract asserts that the reveal-law dominance theorem of the author's notes holds in its intended reading. The body proves it only with an extra additive K(n)+K(A) term, under finiteness hypotheses (A1),(A2) and for samplers with computable real values; whether the extra term can be dropped, and the case of defective samplers and infinite alphabets, are open. The intro bullet repeats the claim with "under finiteness hypotheses" but also omits the extra term.
* Evidence: cor:hist:thm1(a): "E L_SFI <= E L_P + K(P) + K(Delta_f) + K(n) + K(A) + c" under (A1),(A2) and computable real values; rem:hist:thm1open (app-hist.tex line 112): "(i) Whether K(n)+K(A) can be dropped ... (ii) Defective samplers ... (iii) Infinite alphabets"; history notes-final line 30: "proved under the stated hypotheses; rest open". Only the deterministic case (cor:hist:thm1(b)) has no extra term.
* Fix: Abstract: "A dominance theorem for computable reveal orders, stated with a proof sketch in earlier notes, holds pathwise for deterministic reveal policies and, for random reveal laws on finite alphabets, up to an additive K(n)+K(A) term; the proof sketch itself fails." Intro line 19: "... is true in the reading his text supports: pathwise for deterministic reveal policies, and with an additional K(n)+K(A) term for random reveal laws under finiteness hypotheses (cor:hist:thm1); whether that term is needed is open (rem:hist:thm1open)."

**P1X-02 (fatal)** — `paper/sections/abstract.tex`, abstract, sentence "SFI cannot use the order of the data: ..."
* Problem: Unqualified claim that SFI cannot use the order of the data. The body proves order independence only for the cumulative loss in the semimeasure convention. The normalised predictor, which is what one would use to predict, is explicitly not order-free, and whether the normalised loss of MF depends on the order is an open question of the paper.
* Evidence: prop:setting:order is stated "Semimeasure convention". examples.tex line 70: "The normalised predictor is not order-free"; hist.tex line 51: "The normalised MFbar is not order-free"; q:setting:normorder: "Is the normalised loss of MF order-dependent ...?" (open); prop:setting:normalise(b): normalised losses of random partial functions can depend on the order.
* Fix: Replace by: "In the semimeasure convention (raw sub-probabilities) SFI's cumulative loss does not depend on the order of the data: on a random cyclic permutation ... it pays about (d - log2 e)2^d bits, while ...". The intro paragraph "Relation to Solomonoff induction" already says this correctly; align the abstract with it.

**P1X-03 (major)** — `paper/sections/intro.tex`, line 9 ("Relation to Solomonoff induction": "Giving SFI's hypotheses the list of previous inputs closes this gap")
* Problem: Overstated. "This gap" is the advantage of SI on the interleaved sequence. The body shows that SFIhist matches SI's joint loss and removes the gaps in the worked examples, but against SI's conditional label loss the difference is SI's loss on the inputs, and for unnormalised M it fails in both directions (conditionally); the normalised case is open.
* Evidence: rem:hist:H4verdict: "As good as SI holds against Solomonoff induction's joint loss (thm:hist:si(a)); against its conditional label loss the difference is M's loss on the inputs (prop:hist:inputloss), and for unnormalised M it fails both ways, conditionally on prop:hist:lhg; the normalised case is open." The discussion (line 7) states this correctly.
* Fix: Replace by: "Giving SFI's hypotheses the list of previous inputs removes the gaps of Sections 5-6: the result, SFIhist, is the universal chronological semimeasure (cor:hist:H4) and is within a constant of SI's joint loss on the interleaved sequence (thm:hist:si); against SI's label loss alone the comparison involves SI's loss on the inputs (prop:hist:inputloss)."

**P1X-04 (major)** — `paper/sections/discussion.tex`, line 9 ("Which version to call SFI": "their gaps, although unbounded, are small on the known witnesses")
* Problem: Contradicts the paper's own table. One of the versions of Section 3, the universal weak semimeasure, exceeds MF by a number of bits linear in the size of the data set on known witnesses.
* Evidence: thm:setting:weakvsmachine(iii): log(Mw(D_k)/MF(D_k)) >= k log(3/2) - K(k) - O(1) on 2k-point data sets; tab:versions:compare row "MF vs Mw": "k log 3/2 - K(k) - O(1) on some 2k-point D".
* Fix: Say: "... their gaps are unbounded; between the program-based versions they are small on the known witnesses (about log d for the single shortest program on two points, a padded tape-length cost for the program mixture), while the weak semimeasure, which has no posterior over functions, can exceed MF by linearly many bits (thm:setting:weakvsmachine)."

**P1X-05 (major)** — `paper/sections/intro.tex`, line 19 (contributions bullet: "every order-independent predictor pays the same lower bounds")
* Problem: Missing hypothesis. The pathwise lower bounds transfer only to lower-semicomputable order-independent predictors, with K(nu) subtracted; for arbitrary order-independent predictors the paper proves the bounds only in expectation over independent uniform blocks.
* Evidence: prop:hist:orderfree: "(b) If nu is lsc, the lower bounds ... hold for -log nu with K(nu) subtracted. (c) For every nu, with independent uniform blocks, E[-log nu(D_n)] >= ..."
* Fix: Write: "... and every lower-semicomputable order-independent predictor pays the same lower bounds up to its complexity, every order-independent predictor in expectation (prop:hist:orderfree)."

**P1X-06 (major)** — `paper/sections/steeper.tex`, line 6, last sentence ("This section summarises the results; all of them are proved there.")
* Problem: Stronger than the source. Several numbers quoted in this section are computed instances of proved bounds, one of them explicitly "an illustration", and Paper 2 contains computed-only items.
* Evidence: steeper.tex line 10: "up to 8.06e-3 (machine constant set to 0, an illustration)"; paper-steeper/CLAIMS.md: tab:teacher:numbers "computed (St c3, c6(B), c7(D); referee r1)", ex:split:noisyparity "computed (St c4(C)); illustration", rem:teacher:hanni "computed".
* Fix: Replace by: "The results summarised here are proved in the companion paper; the numerical values are evaluations of its bounds at the parameters stated (with the machine constant set as indicated)."

**P1X-07 (major)** — `paper/sections/abstract.tex`, whole abstract
* Problem: The abstract is a dense list of results that a reader outside the project cannot parse: "semimeasure convention", "universal weak semimeasure", "reveal orders", "an earlier proof sketch" (whose?), d (input length) and K are undefined; there is no sentence of motivation and no statement of what is new.
* Evidence: Abstract text: "...pays about (d - log2 e)2^d bits in the semimeasure convention..."; "A dominance theorem for computable reveal orders holds in its intended reading, though an earlier proof sketch fails."
* Fix: Rewrite (also fixing P1X-01, P1X-02). A concrete proposal of about 1,700 characters (under arXiv's 1920) is given in review-p1-arxiv.md, section 7.1: one sentence of motivation (SI is the ideal sequence predictor; SFI is its supervised analogue), then universality/invariance, versions/no coding theorem, dominance and O(K/n), fresh noise, order blindness (qualified) with the cyclic example, SFIhist, and one sentence listing the remaining topics.

**P1X-08 (major)** — `paper/preamble.tex + all sections`, \status and \src on all 203 theorem-like environments (114 with a status other than plain "proved")
* Problem: Every theorem-like environment prints a bracketed status ("[proved; computed (context c6, c11); construction from the slides]") and a grey source note ("context Thm 3.11") in the PDF. The binding note forbids both in the final PDF. Simply redefining the macros to nothing is not enough: 114 statuses carry information that must be re-expressed in standard form (proof sketch parts, conditional results, conjectures, refuted readings, literature attributions, computations).
* Evidence: PDF text, e.g. "Proposition 6.5 (order-free predictors). [proved; sharper weak case open]"; extract_status.py output (scratch/p1-arxiv/envs.txt): 203 environments, 114 non-plain statuses: 50 "proved + computed", 1 "computed", 11 "known; unverified", 10 "remark", 9 "known/cited", 8 "refuted", 6 "proved + open part", 1 "open", 7 qualified "proved", 5 "proof sketch", 4 "conjecture", 2 "conditional".
* Fix: Apply the environment-by-environment plan in review-p1-arxiv.md section 4.1 (generated table, one row per environment with the exact academic rewording), then delete \status and \src from preamble.tex and from all section files, and also the two inline \status calls (setting.tex line 40; app-versions.tex lines 92 and 102).

**P1X-09 (major)** — `paper/sections/app-verification.tex`, whole Appendix I (pages 96-103) and main.tex \input{sections/app-verification}
* Problem: The PDF contains a 7-page appendix "How the claims were checked" written in process vocabulary (tracks, referees, ledger, notes-final, H1-H10, check-script seeds, 25 cross-track conflicts, "a promised Wyeth-Hutter reference not cited", "Results checked by their authors only", "Unresolved points" including the page overrun). The binding note requires no verification appendix.
* Evidence: app-verification.tex lines 7-179; PDF pages 96-103; line 136 "C25: a promised Wyeth--Hutter reference not cited (not relevant)"; line 174 "Conversion to arXiv form ... must also decide how to cite the request".
* Fix: Delete the \input. Keep: (1) the acknowledgements paragraph (already in discussion.tex lines 31) adjusted per P1X-31; (2) the Code-and-data statement, expanded into a short appendix "Code and data" with a table claim -> script -> output file (see P1X-30); (3) the in-text markers of proof sketches and conditional results (they replace the list in app-verification lines 140-142). Drop: the scripts table, the corrections longtable, the conflicts list, "results checked by their authors only", "Literature" and "Unresolved points". No bibliography entry is cited only in this appendix, so no entry is lost.

**P1X-10 (major)** — `paper/sections/intro.tex`, lines 26-53 (paragraph "Corrections to earlier claims" and Table 1 tab:intro:verdicts, "working hypotheses H1-H10 ... with verdicts")
* Problem: Process artefact. The table lists the orchestration's working hypotheses H1-H10 with "verdicts", which a reader of an arXiv paper has no context for; NOTATION.md itself rules that H1-H10 appear only in CLAIMS.md and the verification appendix. The corrections paragraph is a list of internal corrections, which the binding note excludes, and refers to an uncited "PDF draft".
* Evidence: intro.tex line 26 "\Cref{tab:intro:verdicts} lists the ten working hypotheses with which this study began and what became of each"; line 51 caption "The working hypotheses H1--H10, paraphrased, with verdicts"; NOTATION.md §4 item 26: "The brief's items are cited as H1--H10 only in CLAIMS.md and in the verification appendix"; learn.tex line 87 also refers to "hypothesis H7 ... (tab:intro:verdicts)".
* Fix: Delete Table 1 and the reference in learn.tex line 87. Replace the corrections paragraph by a short paragraph "Relation to the author's notes": "Several questions treated here were raised in unpublished notes of the author [Hän26b]. Where those notes claimed more than holds, the relevant section says so: the simulation argument for the reveal-law theorem (Prop. 5.8), the literal two-sided OOD bounds (Prop. 7.6), the converse without dependence on K(f) (Prop. 7.10), and the online-mistake argument for Occam learning (Thm. 8.14)." Keep each correction where it occurs.

**P1X-11 (major)** — `paper/bib/core.bib + 9 section files`, hanni2026request (13 citations outside Appendix I, 15 with it): examples.tex 7, 35, 112; hist.tex 12, 117; learn.tex 7; nn.tex 8; steeper.tex 14; versions.tex 4 (plus the uncited mentions in the table caption, line 123, and the remark title, line 137); app-examples.tex 140; intro.tex 51, 55 (twice)
* Problem: The paper cites "Request for a paper on Solomonoff function induction. Personal communication to the author, 11 October 2026; quoted verbatim in .../research/00-brief.md" by the sole author. With Hänni as sole author this is a communication from the author to himself (in fact to the AI system), it is not a verifiable reference, and sentences such as "He later asked that the paper include an equivalence ... (if they don't, then it should explain that)", "Hänni's request: ...", "his request conjectures" are conversational process text that the binding note forbids ("No conversational references to his request").
* Evidence: PDF bibliography: "Kaarel Hänni. Request for a paper on Solomonoff function induction. Personal communication to the author, 11 October 2026; quoted verbatim in solomonoff-function-induction/research/00-brief.md ..."; versions.tex line 4; hist.tex line 117; examples.tex line 7 "\citet{hanni2026request} proposed two examples".
* Fix: Remove the entry. Rewrite each citing sentence as the paper's own motivation or cite the notes: versions.tex 4 -> "The author's notes [Hän26b] ask whether the Kolmogorov and semimeasure versions are equivalent via a coding theorem. They are not: ..."; hist.tex 117 -> "It is natural to conjecture that hypotheses that see the list of previous inputs are as good as Solomonoff induction [Hän26b]"; examples.tex 7 -> "We work out two examples in which SFI does much worse than SI: a random cyclic permutation ... and a coin-flip example due to Sam Eisenstat (personal communication)". learn.tex 7 "ideal supervised learning" -> drop the quote or cite the notes. Eisenstat is credited in the acknowledgements; the e-mail argument (app-examples.tex 140) becomes "an informal argument of the author (e-mail to S. Eisenstat, 2026)", or is paraphrased.

**P1X-12 (major)** — `paper/sections/steeper.tex`, line 6 (\citep{hanni2026notes,hanni2026lesswrong}); bib/core.bib hanni2026lesswrong
* Problem: The body text prints "(Hänni, 2026b; Hänni and Wyeth, undated)" next to the paragraph on the absorption objection. The entry is unverified (the page did not resolve; search does not find it), has year "undated", and lists Cole Wyeth as co-author, so the absorption objection is visually associated with Wyeth, contrary to the spirit of the binding note (at most one neutral footnote). The proposal quoted is in Hänni's own note, so the LessWrong citation is not needed.
* Evidence: PDF line ~2560 "noise rather than a model plus memorised errors of the teacher (Hänni, 2026b; Hänni and Wyeth, undated)"; core.bib comment "% unverified: the LessWrong page did not resolve"; research/prior/hanni-grokking-a-notion.md lines 41-61 contain "a higher coefficient on the length of the program" and "if each input gets its own private randomness".
* Fix: Cite only \citep{hanni2026notes} (the note "beating solomonoff induction at grokking a notion"). Remove hanni2026lesswrong from Paper 1. If Paper 2 keeps the neutral footnote, give the entry a date and the thread title only, author "LessWrong discussion", after verifying the URL from a machine that can reach lesswrong.com.

**P1X-13 (major)** — `paper/sections/*.tex`, voice throughout: e.g. ood.tex 7, 111, 153; hist.tex 28, 62, 68, 92, 109; comp.tex 54, 58, 99, 107, 111; nn.tex 24, 33, 47, 51, 86, 91; examples.tex 35, 100; app-ood Table 6 caption
* Problem: With Kaarel Hänni as sole author, the paper reads as a third party grading the author: "Several claims of Hänni (2026b) are corrected here", "his remark is correct", "So Thm 1 is true in Hänni's reading", "Hänni's predictors are not order-independent", "This makes precise Hänni's weakly held hypothesis", "which Hänni doubts", "He wrote plausibly and did not claim the last column". A reader will find this confusing (who is "we"?), and the binding note asks for a formal register and for crediting the author's ideas by citation to his notes.
* Evidence: intro.tex line 26 "Several claims of \citet{hanni2026notes} are corrected here"; hist.tex line 92 "This is H\"anni's own example, and his remark is correct"; nn.tex line 86 "which H\"anni doubts"; app-ood Table 6 caption.
* Fix: State once in the introduction: "Many of the questions and examples studied here first appeared in unpublished notes of the author [Hän26b]; we cite them where they arise." Then use neutral forms: "[Hän26b] conjectures ...", "the argument sketched in [Hän26b] ...", "the informal claim of [Hän26b] holds in the following form". Remove evaluative phrases ("his remark is correct", "weakly held", "He wrote ... did not claim").

**P1X-14 (major)** — `paper/sections/*.tex`, 28 literature hedges in visible text; list in review-p1-arxiv.md section 4.2 (e.g. setting.tex 12, 40, 175; versions.tex 21; learn.tex 49, 77, 171; hist.tex 127, 135, 157; related.tex 6, 8, 10, 12; nn.tex 81, 91; app-setting 81, 132; app-versions 92, 102; app-learn 106, 129, 133; intro.tex 9, 55, 57; discussion.tex 13)
* Problem: The text repeatedly says that a cited source was "not checked", "seen only in the abstract", "a search snippet", "unverified", or "we have not read these sections". The binding note: "only references whose bibliographic data have been checked ... never print unverified". More importantly, content claims attributed to sources nobody read cannot appear in an arXiv paper; either the content is checked or the claim is dropped.
* Evidence: versions.tex 21 "(abstract only seen) ... (search snippet only)"; learn.tex 171 "A table-of-contents snippet shows ..."; nn.tex 91 "These descriptions follow the abstracts."; setting.tex 12 "We use, without re-checking the sources"; app-versions 92 "we have not checked its statement".
* Fix: Before posting, read the sources (almost all are open access: Hutter cs/0004001 and cs/0701125, Lattimore-Hutter-Gavane 1107.5531, Lattimore-Hutter 1111.3846, Wood-Sunehag-Hutter 1111.3854, Leike-Hutter 1507.04124 and 1510.04931, Levin 1403.4539, Solomonoff 2008 on raysolomonoff.com, Yang-Salman 1907.10599, Basri et al. 1906.00425, Chater-Vitanyi on CWI) and replace each hedge by a plain statement with a section or theorem number, or delete the sentence. For textbook facts (coding theorem, Levin-Schnorr, Kraft) cite Li-Vitanyi 2008 with section numbers and delete "without re-checking".

**P1X-15 (major)** — `paper/sections/hist.tex`, lines 127, 135 (after thm:hist:representation and cor:hist:H4); intro.tex 9, 55; related.tex 8; discussion.tex 13
* Problem: The paper says its central history-aware result is "prior work in substance" (Hutter's universal chronological semimeasure and his "supervised learning from examples") but that the identification was never checked against Hutter's texts. An arXiv paper cannot leave the novelty and the exact relation of its main Section 5 result to a well-known book undetermined.
* Evidence: hist.tex 135: "Agreement with Hutter's universal chronological semimeasure ... is known, but not checked against the sources (he uses finite alphabets), and is not used"; intro.tex 55: "we have checked them only at the level of abstracts and tables of contents".
* Fix: Read Hutter (2005) (chronological semimeasures; Section on supervised learning from examples) and Hutter (2007, arXiv cs/0701125, section "Supervised Learning from Examples (EX)"). Then state precisely: whether Hutter defines xi on finite alphabets only, whether thm:hist:representation (function-machine form) is new, and whether SFIhist = xi up to constants for countable X, Y. Replace all six hedges by that statement.

**P1X-16 (major)** — `paper/sections/related.tex`, line 10 (lattimore2013nofree: "whether their random-selection result coincides with prop:learn:splits we have not checked")
* Problem: Lattimore and Hutter (2013) propose a Solomonoff-inspired off-line classifier for supervised learning and prove a result on randomly selected training data. This is the closest prior object to SFI and to prop:learn:splits, and the paper has not compared them.
* Evidence: Search result (ANU record / arXiv 1111.3846): "proposes an off-line classification algorithm inspired by Solomonoff induction, and proves that the common heuristic of randomly selecting training data helps reduce misclassification rates".
* Fix: Read arXiv:1111.3846 and add a precise comparison: which of W, Mprod, MF their classifier is (or is not), and whether prop:learn:splits is their result in another form. Adjust the novelty statements (P1X-18) accordingly.

**P1X-17 (major)** — `paper/sections/related.tex`, whole section; versions.tex section 3.3 (thm:versions:nocoding)
* Problem: Missing related work on decision complexity. K_F on the initial-segment data set {(i, x_{i+1})} is a prefix variant of Loveland's decision (uniform) complexity, and the relations between decision, prefix, monotone and a priori complexity are studied by Uspensky and Shen (1996) and in Shen-Uspensky-Vereshchagin (2017). The "no coding theorem for function programs" should be positioned relative to that literature (the paper already cites the monotone analogue, Gács 1983 and Day 2011, only in an appendix).
* Evidence: Verified by WebSearch: Loveland, "A variant of the Kolmogorov concept of complexity", Information and Control 15 (1969) (pages differ between sources: 510-526 vs 602-619; check); Uspensky and Shen, "Relations between varieties of Kolmogorov complexities", Math. Systems Theory 29(3) (1996), pp. 271-292 (Crossref: 270-291), doi 10.1007/BF01201280; Shen, Uspensky, Vereshchagin, Kolmogorov Complexity and Algorithmic Randomness, AMS Math. Surveys and Monographs 220 (2017).
* Fix: Add a paragraph to Section 11 and one sentence after thm:versions:nocoding: "On initial segments K_F is a prefix version of decision complexity [Lov69, US96]; known gaps between ... [Gác83, Day11] are the sequence analogue of Theorem 3.9." Check whether the two-point construction is known before claiming it.

**P1X-18 (major)** — `paper/sections/related.tex`, rem:related:new (lines 16-19); discussion.tex line 13
* Problem: The remark lists what "appears new at a snippet-level search" and ends with a to-do: "Each of these should be checked against Solomonoff (2008), Hutter (2005) and Lattimore and Hutter (2013) before any claim of novelty." The discussion adds "we claim no novelty for anything listed there as existing". This is an unfinished novelty assessment printed in the paper.
* Evidence: related.tex line 18 (verbatim above); status "known (snippets; unverified)".
* Fix: Do the check (P1X-15, P1X-16, P1X-17), delete the remark, and state novelty once, in the contributions list: "To our knowledge, the following are new: ...". If the check is not done, delete all novelty language instead.

**P1X-19 (major)** — `paper/sections/ood.tex`, line 7 ("His draft adds ..."), subsection 7.2 title "The draft's two-sided result" (line 51), lines 53, 63, prop:ood:draftfalse title (line 65); intro.tex 26 ("the PDF draft"); versions.tex 4, 144
* Problem: The paper repeatedly refers to "Hänni's draft" / "the PDF draft", a document that is not in the bibliography (only "notes" is). A reader cannot locate it, and "the draft's" in a subsection heading and a proposition title is process vocabulary.
* Evidence: PDF: "7.2 The draft's two-sided result"; "Proposition 7.6 (the draft's bounds as stated are false)"; intro: "in the PDF draft are false as literally stated"; bibliography has no draft entry (research/prior/hanni-sfi-draft-2025-09.txt is the source).
* Fix: Add a bibliography entry for the draft (e.g. "K. Hänni, Solomonoff function induction, unpublished draft, September 2025", with a URL if public) or cite the specific note in [Hän26b]. Rename: subsection 7.2 "A two-sided bound on P-abiding generalisation"; Proposition 7.6 "The literal two-sided bounds fail". In versions.tex 144 replace "which Hänni's draft names as the tool" by "the coding theorem".

**P1X-20 (major)** — `paper/sections/*.tex`, check-script identifiers and track names in visible text: setting.tex 44, 119, 156; learn.tex 49, 87, 108, 112; versions.tex 123; app-setting.tex 115, 117, 125, 132, 151, 166; app-versions.tex 35, 60, 86, 99, 102; app-learn.tex 33, 119, 129, 141
* Problem: The PDF cites internal script identifiers and track names: "(c1)", "(c9(c))", "(context c3)", "(foundations r6)", "(foundations c5)", "(foundations r12)", "Check c8(c) computes ...", "(proof sketch; foundations Problem 3.6)" (a paragraph heading), "Foundations: c4 ..., r6 ..., c5 (seed 20261011 ...). Context: c3 ...", "Source: foundations Table 4.12", "not written out in the notes", "An earlier version of the context notes". These are meaningless to a reader and are process vocabulary.
* Evidence: process_vocab_filtered.md (scratch/p1-arxiv): 17 check-id hits and 12 track-name hits outside the verification appendix; e.g. versions.tex 123 caption "Source: foundations Table 4.12."; app-setting.tex 132 "\paragraph{Reformulation (proof sketch; foundations Problem 3.6).}".
* Fix: Replace each by "a direct computation (code in the accompanying repository) gives ..." when the number is used in the argument, otherwise delete it and list the check in the Code-and-data table. Specific: versions.tex 123 delete "Source: foundations Table 4.12."; app-setting.tex 132 heading "Reformulation (sketch)"; app-learn.tex 33 "(not written out in the notes for (b))" -> delete; app-learn.tex 141 paragraph -> Code-and-data appendix table.

**P1X-21 (major)** — `paper/sections/versions.tex`, Table 2 caption (line 123: "(Hänni's later request)"); rem:versions:answer title (line 137: "Answer to Hänni's request"); line 4
* Problem: Process vocabulary in a table caption and a remark title.
* Evidence: PDF: "Table 2: The Kolmogorov and semimeasure versions compared (Hänni's later request) ... Source: foundations Table 4.12."; "Remark 3.14 (Answer to Hänni's request)".
* Fix: Caption: "Table 2: The Kolmogorov and semimeasure versions compared. Data sets D with inputs of length at most d; ..." Title: "Remark 3.14 (summary: Kolmogorov versus semimeasure versions)". Line 4: see P1X-11.

**P1X-22 (major)** — `paper/sections/learn.tex`, prop:learn:freshnoise status (line 80) and text line 87
* Problem: The status prints "refuted (the brief's fresh-noise claim, as stated)" and the text says "This refutes the fresh-noise form of the supervised-learning hypothesis H7 for random-function SFI (Table 1)", with "(foundations c5)" for the numbers. "brief", "H7" and the check id are process vocabulary.
* Evidence: learn.tex lines 80, 87.
* Fix: Delete the status and the H7 sentence. Keep the mathematics: part (c) already states "The statement ... is false for random-function SFI". Replace "(foundations c5)" by "(a direct computation)".

**P1X-23 (major)** — `paper/sections/app-learn.tex`, rem:learn:cesaro (lines 117-120)
* Problem: An internal correction is printed as a remark: "An earlier version of the context notes read prop:learn:typical as matching the O(1/n) Cesàro upper bound ... The comparison is invalid". The binding note: refuted earlier claims appear only where they inform the reader; no list of internal corrections.
* Evidence: app-learn.tex line 119; status "refuted"; source "context Prop 2.12, X13".
* Fix: Delete, or keep only the mathematical content: "Remark C.3. Proposition 4.13 bounds the error at a single step from below and cannot be compared with the Cesàro bound of Theorem 4.5: since sum_k E e_k <= (ln 2)(K(f)+c), liminf_k k E e_k = 0. Corollary 4.14 gives the per-step comparison."

**P1X-24 (major)** — `paper/sections/comp.tex`, thm:comp:timebounded (b) (line 20-24); prop:comp:round last sentence (line 36); prop:comp:history last clause (line 63); hist.tex thm:hist:minimax (b) (line 96-101)
* Problem: Parts whose proofs are only sketched are stated inside theorems/propositions, so the statements are presented as fully proved. The binding note: proof sketches are labelled and the statement must not be presented as fully proved.
* Evidence: Statuses: "(a) proved (corrected); (b) proof sketch"; "proved; running time proof sketch"; "regret proved; running time proof sketch"; "(b) proved for reveal laws that do not see f, proof sketch for those that do". app-comp.tex line 11 "this part is a proof sketch"; hist.tex line 101 "case (b) needs C_dir to within 1, not written out".
* Fix: Split each: keep the proved part as the theorem; move the sketched part into a remark headed "(sketch)" with the sentence "We only sketch this; ...". Exact rewordings in review-p1-arxiv.md section 4.1, rows for thm:comp:timebounded, prop:comp:round, prop:comp:history, thm:hist:minimax. For thm:hist:minimax restrict (b) to reveal laws that do not see f; cor:hist:thm1 needs only that case.

**P1X-25 (major)** — `paper/sections/ood.tex`, conj:ood:natural (lines 177-182)
* Problem: A conjecture environment holds a statement that the paper itself calls imprecise: "This is not a precise statement, and by prop:ood:machine it fails for some universal machines". That is not a conjecture in the standard sense.
* Evidence: ood.tex line 182; app-verification line 140 "the last is not a precise statement".
* Fix: Remove the environment. In the open problems (discussion.tex line 22) write: "Is there a natural class of universal machines for which the intended answers of Example 7.16 receive posterior probability close to 1? By Proposition 7.4 no such statement holds for every universal machine."

**P1X-26 (major)** — `paper/sections/hist.tex`, prop:hist:lhg (lines 157-161) and rem:ex:where (app-examples.tex 116)
* Problem: A proposition is "conditional (on LHG transfer); LHG known, unverified beyond the abstract": it rests on hypotheses (LHG-even), (LHG-odd) whose truth is attributed to a paper read only in abstract. In standard form, unproved hypotheses are named assumptions, and the attribution must be checked.
* Evidence: Status of prop:hist:lhg; hist.tex 157 "(abstract seen only)"; the acronym LHG is never expanded.
* Fix: Use the existing assumption environment: "Assumption (LHG-even) ..." and "Assumption (LHG-odd) ...", preceded by a sentence on what Lattimore, Hutter and Gavane (2011) prove (after reading arXiv:1107.5531, Sec. x). Then "Proposition 5.22. Under Assumption (LHG-even) ...; under Assumption (LHG-odd) ...". Point rem:ex:where to the assumption.

**P1X-27 (major)** — `paper/sections/*.tex`, all "\paragraph{Open question.}\label{q:...}" (setting.tex 99, 132, 161, 175; versions.tex 102, 147; hist.tex 197; examples.tex 68, 197; ood.tex 148; comp.tex 75, 136; nn.tex 94)
* Problem: Open questions carry labels on unnumbered paragraphs, so every cross-reference prints the number of the enclosing subsection. Two different questions both print as "Section 2.5"; the question on the normalised loss over the cyclic permutation prints "Section 6.3", which is the subsection on Eisenstat's example. A reader cannot find the referenced question.
* Evidence: PDF discussion: "two-sided characterisation ... (Section 2.5)? What is the arithmetical level ... (Section 2.5)?"; PDF line ~1621 "Over the whole cycle these bounds sum to at most about 2N bits (Section 6.3)"; app-verification line 176 notes the same defect.
* Fix: Define a numbered environment, e.g. \theoremstyle{definition}\newtheorem{question}[theorem]{Question} with \crefname{question}{Question}{Questions}, and convert each paragraph into \begin{question}...\end{question}. Then each question gets its own number (e.g. "Question 2.15") and every cross-reference prints it.

**P1X-28 (major)** — `paper/main.tex`, whole paper (103 pages: main text pp. 3-52, references pp. 52-56, appendices pp. 57-103)
* Problem: Too long and too broad for one arXiv paper in learning theory / AIT. The main text is 50 pages with 12 sections and 155 theorem-like environments (100 theorems, propositions, lemmas or corollaries); the outline's own target was 38 + 35 pages. Sections 8-10 (computable versions, NN Bayes, summary of Paper 2) are each a separate topic; the NN section is about one third restatement of unverified claims of slides.
* Evidence: main.toc: Sec 1 p.3, 2 p.7, 3 p.12, 4 p.17, 5 p.22, 6 p.28, 7 p.34, 8 p.39, 9 p.43, 10 p.47, 11 p.49, 12 p.50; App A p.57 ... I p.96; app-verification line 173 "The main text (pages 3--52) runs well beyond its target of about 38 pages".
* Fix: Target <= 30-35 pages of main text. Concretely: drop App I (7 pp) and Table 1; shorten Sec 10 to one paragraph in the Discussion (Paper 2 is cited); merge Secs 8 and 9 into one section "Computable versions and neural networks" of <= 4 pp (move rem:comp:apples, prop:comp:samplers, rem:comp:selection, rem:comp:uniformties, rem:nn:slides, rem:nn:literature, rem:nn:rigorous to the appendix or related work); move sec:learn:curves except cor:learn:perstep to App C; move thm:hist:gf, thm:hist:expected, prop:hist:lhg, prop:hist:inputloss to App D with a one-paragraph summary; move ex:ood:easyhard and ex:ood:hanniexamples to App F. Alternative: publish Sections 8-9 separately.

**P1X-29 (major)** — `paper/sections/intro.tex`, lines 13-24 (contributions) and page 1-2 layout (main.tex: \tableofcontents \newpage)
* Problem: No informal statement of the main results: the contributions list has 8 bullets, each 3-6 lines, with 65 cross-references in all, and reads as a catalogue. Page 1 holds only title, abstract and the start of the table of contents; the introduction starts on page 3. There is no figure in 103 pages.
* Evidence: intro.tex lines 15-24; main.tex lines 15-18; grep finds no \includegraphics.
* Fix: Add 3-4 informal main theorems on page 2 (A: universality, invariance and dominance; B: no coding theorem for function programs; C: order blindness and SFIhist; D: the two examples). Shorten each contribution bullet to 1-2 lines. Move the table of contents after the introduction or drop it, and remove the \newpage. Add one figure: the chain 2^{-K_F} <= W <= Mprod <= MF <= Mw with the known gaps, or a diagram of SFI vs SFIhist vs SI on the interleaved sequence.

**P1X-30 (major)** — `paper/sections/discussion.tex`, Code and data (line 34) and app-examples.tex 237, app-ood.tex 39, app-learn.tex 141
* Problem: The Code-and-data statement points to research/tracks/*/checks/ and research/tracks/*/referee_code/ (process vocabulary in paths) and gives no map from claims to scripts; in the text the computations are identified by internal ids. A reader cannot find the script behind a given number.
* Evidence: discussion.tex line 34: "the scripts are in \texttt{research/tracks/*/checks/}, \texttt{research/tracks/*/referee\_code/} and \texttt{code/}". The repository itself exists and is public (gh api repos/kaarelh/AI-works: private = false, 2026-10-12).
* Fix: Publish a curated folder (or a tagged release) with a README, and add a one-page appendix "Code and data" with a table: result (e.g. the numbers after Prop 2.17; Table 3; Ex 7.16(c) grammar; Thm 8.14 tie rules; Rem 9.9 accuracy) -> script name -> command -> output file -> seed. Keep the sentence on reproducibility (fixed seeds; runtime lines differ).

**P1X-31 (major)** — `paper/main.tex`, title footnote (\thanks) and discussion.tex line 31 (acknowledgements)
* Problem: arXiv requires that the listed author take full responsibility for the content. The disclosure states that "no human has yet independently checked all of the mathematics". The disclosure is honest and required by the binding note, but posting an AI-produced 100-page mathematics paper that its sole author has not checked invites moderation problems and readers' distrust.
* Evidence: main.tex line 8 footnote; discussion.tex line 31 "No human has yet independently checked all of the mathematics, and readers should weigh the results accordingly."
* Fix: Before submission the author should check at least the main theorems (those in the informal main-results list) and the disclosure should then say so: "The author has checked the proofs of Theorems A-D; the remaining proofs were checked by independent AI referees only." Keep the AI-assistance disclosure as required.

**P1X-32 (major)** — `paper/bib/core.bib`, hanni2026notes, hanni2026request, hanni2026lesswrong (printed as Hänni 2026b, 2026c, Hänni and Wyeth undated)
* Problem: Three printed references could not be verified: "Kaarel Hänni. notes. Public repository of working notes, https://github.com/kaarelh/notes, 2026b" (lower-case title "notes", repository not found by search and not reachable here, notes partly dated 2025); the personal-communication "request"; the undated LessWrong thread. The binding note: drop or replace a citation that cannot be checked.
* Evidence: WebSearch (2026-10-12): no hit for github.com/kaarelh/notes or the LessWrong thread; local copies in research/prior/ (hanni-sfi-notes.md, hanni-sfi-draft-2025-09.txt, hanni-grokking-a-notion.md).
* Fix: hanni2026notes: confirm the repository is public, give an informative title and the years covered, e.g. "K. Hänni. Notes on Solomonoff function induction and related topics. Unpublished notes, 2025-2026, https://github.com/kaarelh/notes", or deposit the cited notes in the paper's repository and cite that. Drop hanni2026request (P1X-11) and hanni2026lesswrong (P1X-12).

**P1X-33 (major)** — `paper/sections/nn.tex`, rem:nn:slides (lines 79-82), rem:nn:literature (89-92), rem:nn:rigorous (84-87)
* Problem: About a third of Section 9 restates claims of the Vaintrob-Hänni slides that the paper does not prove ("known; unverified (claimed in the slides)", "the rest is unchecked"), describes literature "as the abstracts" do, and repeats the section summary. These are not results and inflate the section.
* Evidence: nn.tex lines 79-92; status strings "known; unverified (claimed in the slides)", "known (snippets; unverified)".
* Fix: Replace by a half-page paragraph "Claims of Vaintrob and Hänni (2026b)" in Section 11 stating their results as theirs (no "unverified"), and the sentence "Claim (i) and the arguments of their Appendices J and K are proved here (Theorem 9.7(a), Theorem 8.14)". Move the literature paragraph to Section 11 after reading the cited papers; delete rem:nn:rigorous.

**P1X-34 (major)** — `paper/sections/app-versions.tex`, rem:versions:operator (versions.tex 20-22) and related.tex line 6
* Problem: The identification "operator induction = per-query mixture M_pq" rests on a formula seen only in a search snippet of a secondary source (Özkural 2017), while the primary source (Solomonoff 2008) was seen only in abstract. The discussion (line 13) and related work build on it.
* Evidence: versions.tex 21: "Secondary sources write its prediction as ... (search snippet only)"; bib comment for ozkural2017ultimate: "the product formula for operator induction seen in a snippet only". WebSearch confirms only the abstract of Solomonoff 2008 ("an unordered set of ordered pairs").
* Fix: Read Solomonoff (2008) (PDF on raysolomonoff.com) and quote the operator-induction predictor with its section number; cite Özkural only if still needed. If that is not possible, write "We call M_pq the per-query mixture; it corresponds to Solomonoff's operator induction as described in [Sol08]" only after checking, or drop the identification and keep M_pq as the paper's own object.

**P1X-35 (minor)** — `paper/sections/abstract.tex`, abstract: "no two of the first three agree up to a constant"; versions.tex rem:versions:answer "There are three objects"
* Problem: The abstract's triple is (K_F, W, Mprod) while the body's "three objects" are (K_F, W, MF). Both statements are true but a reader comparing them will be confused.
* Evidence: abstract; intro.tex line 17 "no two of K_F, W, MF agree up to a constant"; rem:versions:answer.
* Fix: Use (K_F, W, MF) everywhere: "... agree up to K(dom D) bits, but no two of the shortest consistent program, the program mixture and SFI agree up to a constant".

**P1X-36 (minor)** — `paper/sections/abstract.tex`, abstract: "does not depend, up to a constant factor, ... on computable encodings"; "computable labels"; "revealed along its cycle"; "risk O(K/n)"
* Problem: Small imprecisions: invariance holds for computable injective encodings with factor 2^{K(alpha,beta)+O(1)}; the O(K/n) risk is for deterministic computable labels; the permutation is revealed backwards along its cycle; K is undefined in the abstract.
* Evidence: thm:setting:invariance(b) "computable injections alpha, beta ... K(alpha,beta)+O(1)"; thm:learn:batch(a) "Deterministic labels"; examples.tex line 7 "revealed backwards along its cycle".
* Fix: Write "computable injective re-encodings (with a factor depending on the encoding)", "deterministic computable labels", "revealed backwards along its cycle", "risk O(K(f)/n), K(f) the complexity of the target".

**P1X-37 (minor)** — `paper/sections/setting.tex`, line 32 (MF used before thm:setting:universal); examples.tex line 23 (Mnorm "the normalised Solomonoff measure" defined only in app-examples.tex line 22); hist.tex 157 (acronym LHG never expanded)
* Problem: Symbols used before definition.
* Evidence: setting.tex line 32 "MF dominates every such lsc law" precedes the definition at line 60; Mnorm appears in prop:ex:cycsi; "(LHG-even)".
* Fix: Move the sentence in setting.tex 32 after thm:setting:universal; define Mnorm in one line in examples.tex 23 (Mnorm(zb) = Mnorm(z) M(zb)/(M(z0)+M(z1))); expand "LHG" as Lattimore-Hutter-Gavane at first use, or rename the assumptions (P1X-26).

**P1X-38 (minor)** — `paper/sections/*.tex`, notation clashes: H_f (hist.tex 106 entropy of reveal sequence; comp.tex 104 hypothesis set); P_A (comp.tex 70 output law of sampler A; nn.tex 12 prior induced by architecture A); e (Euler's number and the error e(x*) in the same formula, learn.tex 146); empty string \epsilon (hist.tex) vs \varepsilon (ood.tex 138)
* Problem: Same symbol, different meanings in nearby sections; in cor:learn:perstep(a) e is both the error and the base of the exponential.
* Evidence: learn.tex 146: "E e(x*) <= eps + 2^{K(f)+c} e^{-eps n}"; comp.tex 104 "H_f:={h preceding or equal to f}" vs hist.tex 106 "H_f the entropy of the reveal sequence given f".
* Fix: Rename: entropy H(x_{1:n} | f) in cor:hist:thm1(c); hypothesis set \mathcal H_f in prop:comp:occam; sampler law P^{samp}_A in prop:comp:samplers; write exp(-eps n) in cor:learn:perstep; use \epsilon for the empty string throughout.

**P1X-39 (minor)** — `paper/sections/app-versions.tex`, rem:versions:hashing title (line 55: "The hashing bound, superseded")
* Problem: "superseded" records the history of the notes.
* Evidence: PDF "Remark B.3 (The hashing bound, superseded)".
* Fix: Title "Remark B.3 (a hashing bound)"; first sentence "This bound is weaker than Proposition 3.6 but uses a different construction."

**P1X-40 (minor)** — `paper/sections/examples.tex`, conj:ex:raw (app-examples.tex 100-103)
* Problem: The conjecture "SI's expected label loss is of order K(d) for typical d" is not a precise mathematical statement.
* Evidence: app-examples.tex line 102.
* Fix: Make it precise ("there is c such that E L^y_M(1) >= K(d) - K_tail(d) - c for all d") or move it to the open problems as a question.

**P1X-41 (minor)** — `paper/sections/hist.tex`, conj:hist:algmi status "(untested)"; rem:hist:H4verdict title "Verdict on Hänni's conjecture" (line 165); subsection 5.3 title "Hänni's Theorem 1"
* Problem: Process words ("untested", "Verdict") and a heading naming an unpublished theorem number.
* Evidence: hist.tex lines 60, 111, 165.
* Fix: Conjecture without "(untested)"; "Remark 5.23 (summary: hypotheses that see the previous inputs)"; subsection title "A dominance theorem for computable reveal laws".

**P1X-42 (minor)** — `paper/sections/app-learn.tex`, rem:learn:interventions (lines 136-139)
* Problem: The remark ends "Nothing specific to SFI is proved here." It adds length without content.
* Evidence: app-learn.tex line 138.
* Fix: Delete.

**P1X-43 (minor)** — `paper/sections/app-ood.tex`, Table 6 caption
* Problem: Conversational: "Hänni's OOD examples (Ex. 7.16). He wrote plausibly and did not claim the last column."
* Evidence: PDF Table 6 caption.
* Fix: "Table 6: The out-of-distribution examples of Example 7.16: what is proved, what is plausible, and strengthenings that fail."

**P1X-44 (minor)** — `paper/sections/intro.tex`, line 5 (first paragraph)
* Problem: The paper's first definition of its subject is a lower-case quotation from informal notes ("you think of the input-output pairs as being generated by picking a random program from this prior..."). Fine as an attribution, weak as the opening of an arXiv paper.
* Evidence: intro.tex line 5.
* Fix: Define SFI in one formal-sounding sentence of the paper's own ("the Bayes predictor for the prior under which a random program, reading random bits shared by all inputs, labels every input") and cite the notes as the origin of the idea; move the quotation to Section 2 (where it already appears) or drop it.

**P1X-45 (minor)** — `paper/main.tex`, build and metadata
* Problem: arXiv does not run Python or BibTeX reliably: the build merges bib/*.bib with merge_bib.py and needs bibtex; PDF metadata (Title, Author) are empty; the author block has no affiliation or e-mail.
* Evidence: build.sh; pdfinfo main.pdf: "Title: (empty)", "Author: (empty)".
* Fix: Submit main.bbl with the sources; add \hypersetup{pdftitle={Solomonoff Function Induction: Definitions, Versions and Basic Theorems},pdfauthor={Kaarel H\"anni}}; add an affiliation or "Independent researcher" and a contact e-mail.

**P1X-46 (minor)** — `paper/sections/app-*.tex`, appendix titles
* Problem: Inconsistent appendix titles: A-E "Function semimeasures and SFI: proofs", "Proofs and remarks for the learning theorems", but F-H "Proofs for Section 7/8/9".
* Evidence: main.toc entries for appendices A-H.
* Fix: Use one pattern, e.g. "Proofs for Section 2 (function semimeasures and SFI)", ..., "Proofs for Section 9 (neural-network Bayes)".

**P1X-47 (minor)** — `paper/sections/steeper.tex`, whole Section 10 (2 pages of numbers from Paper 2)
* Problem: The summary repeats many numerical values of Paper 2 (window ends, 37.7 of 11,710 bits, 0.983, 0.199, 31%, 25%), which must then be kept in sync with Paper 2, and it duplicates the Discussion paragraph "The companion paper".
* Evidence: steeper.tex lines 10-14; discussion.tex line 26.
* Fix: Shorten to one paragraph (about 8 lines) stating the three results qualitatively with a citation; drop the numbers.

**P1X-48 (minor)** — `paper/bib/*.bib`, fixable bibliographic data (all verified by WebSearch, see bib table in review section 5)
* Problem: Missing or uncertain fields in printed entries.
* Evidence: hoeffding1963probability: JASA 58(301):13-30; barzdin1972prediction: Soviet Math. Dokl. 13:1224-1228; wood2013non: LNCS 7070 (same volume as lattimore2013nofree, which the bib already gives as 7070); case1983comparison: TCS 25(2); gacs1974symmetry: Soviet Math. Dokl. 15(5):1477-1480; kleitman1973families: Discrete Math. 6(3); grunwald2007suboptimal: Mach. Learn. 66(2-3), doi 10.1007/s10994-007-0716-7; vovk1990aggregating: pages 371-383 per the Royal Holloway record (another source 371-386); ville1939etude: Numdam lists it as a 1939 thesis (Thèses de l'entre-deux-guerres no. 218, 124 pp.), the Gauthier-Villars imprint was not confirmed; day2011increasing: Trans. AMS (Oct. 2011) confirmed, volume/pages 363(10):5577-5604 not confirmed.
* Fix: Add number=301; pages=1224--1228; volume=7070; number=2; number=5; number=3; number={2--3} and doi; pages=371--383 (or leave out); for Ville either confirm the imprint in a library catalogue or cite the thesis as Numdam lists it; for Day confirm 363(10):5577-5604 in MathSciNet before adding.

**P1X-49 (minor)** — `paper/sections/intro.tex`, line 57 ("What is not achieved"): "The main theorems of the slides are not checked here." and "Much of the literature was seen only through abstracts and secondary sources"
* Problem: Process statements; once the literature is checked (P1X-14) the second sentence becomes false.
* Evidence: intro.tex line 57.
* Fix: "We do not verify the main theorems of [VH26b]." Delete the literature sentence after the check.

**P1X-50 (minor)** — `paper/sections/discussion.tex`, line 5 ("... are each a precise statement, not a caveat")
* Problem: Rhetorical phrasing in a formal register.
* Evidence: discussion.tex line 5.
* Fix: Delete the clause or write "Each of these limits is made precise in Remark 4.16."

**P1X-51 (minor)** — `paper/sections/setting.tex`, rem:setting:h1a (line 96: "(a natural conjecture, by analogy with sequences)")
* Problem: The "natural conjecture" is the orchestration's hypothesis H1(a), not a conjecture in the literature; calling it a conjecture invites a citation request.
* Evidence: setting.tex line 96; CLAIMS.md row rem:setting:h1a "Answer to brief H1(a)".
* Fix: "By analogy with sequences [ZL70] one might expect lsc function semimeasures and laws of function machines to agree up to a constant factor. For the weak definition this fails: ..."

**P1X-52 (minor)** — `paper/sections/examples.tex`, line 197 (q:ex:normalised: "(19.2 against 40.25 bits at d=4)"), app-examples.tex 225, ood.tex 171, comp.tex 27, 43, 95, 124, 128
* Problem: Numerical values from finite computations are quoted without saying they are computed (some do say "a direct computation (code in the accompanying repository)", others do not).
* Evidence: examples.tex 197; comp.tex 95 "A grid computation gives the largest ratio 10.85 in place of 16".
* Fix: Use one formula everywhere: "A direct computation (code in the accompanying repository) gives ...", and list each in the Code-and-data table.

**P1X-53 (minor)** — `paper/sections/hist.tex`, line 62 and elsewhere: "Hänni's Thm 1", "(``Thm 1'')", "Remark 4" (comp.tex 54), "first main afaik-open problem" (nn.tex 47)
* Problem: Theorem and remark numbers of unpublished notes are used as names; quoting "afaik-open" is informal.
* Evidence: hist.tex 62; comp.tex 54 "This is H\"anni's Remark 4"; nn.tex 47.
* Fix: Refer to content: "the reveal-law dominance statement of [Hän26b]", "a remark in [Hän26b, polytime note]", "an open problem posed in [Hän26b]".

---

## Addendum: findings of a second independent pass (ids P1-ARX-nn)

A second reviewer ran the same brief at the same time. Its full report is `p1/review-p1-arxiv-pass2.md` (with `p1/issues-p1-arxiv-pass2.json`; checks in `scratch/p1-arxiv-r2/`). The two passes agree on every point they both cover. This addendum lists only what the second pass adds; the same 14 issues are appended to `issues-p1-arxiv.json`.
Combined counts in `issues-p1-arxiv.json`: 67 issues (2 fatal, 37 major, 28 minor).

**Bibliography corrections to section 5:**

* **`hanni2026notes`: the repository exists**, so the entry is fixable, not unverifiable. WebFetch of github.com/kaarelh/notes shows a public MIT-licensed repository described as "some of my notes from 2023–2026". The SFI note is `ai/learning/solomonoff induction/solomonoff function induction.md` (with a `.pdf`), and the same folder holds "polytime solomonoff (response to lucius).md". Suggested entry: `title={Solomonoff Function Induction}, howpublished={Note in the repository \url{https://github.com/kaarelh/notes}, folder ai/learning/solomonoff induction}, year={2026}`.
* **`day2011increasing`: volume and pages confirmed.** An extended WebSearch returns the AMS issue listing for Trans. Amer. Math. Soc. 363(10) with "Increasing the gap between descriptional complexity and algorithmic probability: Adam R. Day. Trans. Amer. Math. Soc. 363 (2011), 5577-5604". Add `volume={363}, number={10}, pages={5577--5604}`.
* **`orseau2013universal`: volume confirmed.** Springer lists the ALT 2013 proceedings (eds. Jain, Munos, Stephan, Zeugmann) as Lecture Notes in Computer Science volume 8139 (LNAI subseries). Add `volume={8139}`.

**Additional issues:**

**P1-ARX-03 (major)** — `paper/sections/intro.tex`, line 20 (contributions, "Worked examples"): "In Sam Eisenstat's coin example SFI pays H(1/3)/2 n ± O(log n) bits"
* Problem: [Second pass] Not in the P1X list (its table marks the Eisenstat sentence of the introduction OK). Missing 'in expectation'. Pathwise the body proves |LSFI - UB_n| <= log n + O(log log n) + c_b, and UB_n itself fluctuates by Theta(sqrt n) around H(1/3)n/2, so the unqualified ± O(log n) is false pathwise. The same sentence says 'SI pays ... in expectation', which invites the pathwise reading for SFI.
* Evidence: thm:ex:expected (expectation, ± log n + 2 log log n + c); thm:ex:sandwich (pathwise, relative to UB_n); prop:ex:asymp: (UB_n - H(1/3)n/2)/sqrt n -> N(0, 1.0497). The H6 row of tab:intro:verdicts ('Confirmed up to O(log n)', citing the pathwise sandwich) has the same problem.
* Fix: "... SFI's expected loss is H(1/3)n/2 ± O(log n) bits (and almost surely within log n + O(log log n) of the threshold loss UB_n) in the semimeasure convention ..."

**P1-ARX-04 (major)** — `paper/sections/abstract.tex; paper/sections/intro.tex`, abstract line 3 ("Solomonoff induction on the interleaved sequence pays O(1) in expectation"); intro.tex line 20
* Problem: [Second pass] Not in the P1X list (its row A10 marks the abstract sentence OK). Missing hypothesis: the O(1) bound for SI on the cyclic permutation holds for the self-delimiting block code bar s = 1^|s| 0 s fixed in the body; with raw d-bit blocks the proved bound is K(d)+c and the conjectured order is K(d).
* Evidence: prop:ex:cycsi (prefix code), prop:ex:cycraw (raw blocks, K(d)+c), conj:ex:raw (order K(d)); examples.tex:100 'With raw d-bit blocks the bound becomes K(d)+c ... probably the right order'.
* Fix: Abstract: "... while Solomonoff induction on the interleaved sequence, with a self-delimiting encoding of the pairs, pays O(1) in expectation." Intro line 20: add "(with the self-delimiting code of Section 5.5)".

**P1-ARX-05 (major)** — `paper/CLAIMS.md`, §3, entry R5
* Problem: [Second pass] Not in the P1X list; concerns the ledger from which the introduction was written. The ledger states that SFI's loss in Eisenstat's example is 'H(1/3)/2 n ± O(log n), pathwise a.s. and in expectation'. Pathwise this is false (fluctuations of order sqrt n); the paper's body is correct, but the conversion pass and the intro were written from this ledger.
* Evidence: prop:ex:asymp (CLT for UB_n), thm:ex:sandwich (pathwise statement is relative to UB_n).
* Fix: Correct R5 to: "E LSFI = H(1/3)n/2 ± O(log n); almost surely |LSFI - UB_n| <= log n + O(log log n) + c_b, with UB_n = H(1/3)n/2 + O_P(sqrt n)", and check every sentence derived from R5 (intro line 20, H6 row).

**P1-ARX-25 (major)** — `paper/bib/core.bib`, keys hanni2026notes, vaintrobhanni2026nnbayes
* Problem: [Second pass] Corrects P1X-32: the repository does exist. hanni2026notes prints as 'Kaarel Hänni. notes. Public repository of working notes, https://github.com/kaarelh/notes, 2026b. Accessed October 2026.' (title 'notes'). vaintrobhanni2026nnbayes points to kaarelh.github.io/ai/nnbayes-generalization.pdf, which could not be reached, and no search finds the title or an ILIAD listing; it is the source of all claims of §9 marked 'claimed in the slides' and of the conjunction-ladder construction.
* Evidence: WebFetch of github.com/kaarelh/notes: repository exists (MIT, 'some of my notes from 2023-2026'); the SFI note is ai/learning/solomonoff induction/solomonoff function induction.md and .pdf. Slides: no hit (a Fields Institute talk of 21 Apr 2026 by Vaintrob on the joint work exists).
* Fix: hanni2026notes: title = {Solomonoff function induction}, howpublished = {Note in the repository \url{https://github.com/kaarelh/notes}, folder ai/learning/solomonoff induction}, year = {2026}. Slides: the author (a co-author) confirms the exact title, venue and date and that the URL is public before submission; otherwise cite as 'D. Vaintrob and K. Hänni, slides of a talk, 2026, available from the authors' and keep only what is needed.

**P1-ARX-26 (major)** — `paper/sections/discussion.tex`, Acknowledgements, line 31
* Problem: [Second pass] Complements P1X-09 and P1X-31, which do not address the process vocabulary of the acknowledgements paragraph. The disclosure paragraph uses process vocabulary ('developed in five groups', 'Each group's notes ... were checked by a separate instance ... acting as an adversarial referee') and ends with 'The literature was searched only through a web-search tool that returned excerpts; most cited works were not read in full, and the text says so where it relies on them'. The binding note wants a short account of how the paper was prepared and checked, and verified references instead of caveats; after the conversion the text will no longer 'say so where it relies on them'.
* Evidence: discussion.tex:31.
* Fix: Replace by: 'This paper was developed and written with extensive assistance from Claude (Anthropic), an AI system. Working from the author's notes [Hän26] and under his direction, Claude produced the proofs, the computations and the text. Each part was checked by further, independent instances of the system, which re-derived the proofs and re-implemented the computations; the author reviewed the results. No human has yet independently checked all of the mathematics, and readers should weigh the results accordingly.' Add: 'The coin example of Section 6.3 is due to Sam Eisenstat (personal communication).'

**P1-ARX-34 (minor)** — `paper/sections/intro.tex`, line 22: "makes 2^{Ω(ℓ/log ℓ)} mistakes on some ordering for a target of description length ℓ"
* Problem: [Second pass] Reads as a statement about every target of description length ℓ; the theorem is about one target family (the conjunction of d variables, ℓ = Θ(d log d)).
* Evidence: thm:comp:ladder.
* Fix: '... makes 2^{Ω(ℓ/log ℓ)} mistakes on some ordering for the conjunction of d variables, whose description length is ℓ = Θ(d log d)'.

**P1-ARX-36 (minor)** — `paper/sections/learn.tex`, prop:learn:curve, line 105: "for w = 1/16, r_0 = 0.912"
* Problem: [Second pass] Rounding: r_0 = log2(32/17) = 0.91254, which rounds to 0.913.
* Evidence: scratch/p1-arxiv-r2/numbers_check.out: 'r0=0.913 r1=1.544'.
* Fix: Write r_0 = 0.913 (or 0.9125).

**P1-ARX-38 (minor)** — `paper/sections/nn.tex`, rem:nn:rigorous (line 86): "the Gaussian-process limits fail on sparse and odd parities where SFI succeeds"
* Problem: [Second pass] Applies only if rem:nn:rigorous is kept (P1X-33 proposes deleting it). For sparse parities the failure is in averaged squared error over random targets (cor:nn:separation), and the text after it says 'we do not claim a 0-1 version in general'; only the bias-free two-layer ReLU case has an exact 0-1 failure.
* Evidence: cor:nn:separation; nn.tex:69.
* Fix: 'the Gaussian-process limits need n >= (1-ε)C(d,k) samples for squared error ε on random k-sparse parities, where SFI needs O(k log d/ε), and bias-free two-layer ReLU kernels never learn odd parities of size >= 3'.

**P1-ARX-41 (minor)** — `paper/bib/*.bib`, day2011increasing, orseau2013universal, wood2013non, vovk1990aggregating, barzdin1972prediction, case1983comparison, hoeffding1963probability, grunwald2007suboptimal, kleitman1973families, ville1939etude
* Problem: [Second pass] Complements P1X-48: two fields that P1X-48 leaves unconfirmed are now confirmed. Incomplete or unconfirmed bibliographic data in otherwise verified entries; Barzdin-Freivalds prints without pages, Day without volume and pages, Wood et al. without volume.
* Evidence: WebSearch results recorded in scratch/p1-arxiv-r2/bib_log.md (e.g. AMS issue listing: Trans. Amer. Math. Soc. 363(10) (2011) 5577-5604; Springer: ALT 2013 = LNCS 8139).
* Fix: Apply the corrections of the bibliography table (§5): Day 363(10):5577--5604; Orseau et al. volume 8139; Wood et al. volume 7070, ed. Dowe; Vovk 1990 pp. 371--383; Barzdin-Freivalds pp. 1224--1228; Case-Smith no. 2; Hoeffding no. 301; Grünwald-Langford no. 2--3 and doi; Kleitman-Spencer no. 3; Ville: confirm the Gauthier-Villars imprint or cite the thesis record.

**P1-ARX-43 (minor)** — `paper/bib/core.bib`, claude2026whatfollows, claudeSFI2026fundamentals (uncited in Paper 1); claudeSFI2026steeper
* Problem: [Second pass] claude2026whatfollows has author '{Claude (Anthropic)}' and 'Unpublished report prepared for K. Hänni' -- incompatible with the authorship rule if any paper cites it; the companion entry prints 'Companion paper, draft ... Folder ... of GitHub'.
* Evidence: core.bib; PDF p. 54.
* Fix: Paper 1: nothing to do for the two uncited keys (BibTeX drops them). Companion: cite by arXiv identifier once posted, else 'In preparation'.

**P1-ARX-44 (minor)** — `paper/NOTATION.md`, §3.1 row \nulen
* Problem: [Second pass] NOTATION.md defines the shared-coin law as F(x) = omega_{|x|}; the paper (correctly) uses omega_{|x|+1}. Paper 2 must use the same indexing.
* Evidence: versions.tex:61; app-verification.tex:177.
* Fix: Update NOTATION.md and check paper-steeper for omega_{|x|}.

**P1-ARX-45 (minor)** — `paper/sections/app-examples.tex`, tab:ex:cycle (line 133), tab:ex:eisenstat (line 164)
* Problem: [Second pass] A special case of P1X-08 that a macro redefinition does not catch (the tags sit inside table floats). \status{computed}\src{examples §2.6; checks e3, e6} and '...check e2, seed 20261011' are typeset inside the table floats.
* Evidence: PDF Appendix E tables.
* Fix: Delete; put the seed into the caption only if useful ('simulation with a fixed seed; code in the accompanying repository').

**P1-ARX-46 (minor)** — `paper/sections/{versions}.tex`, rem:versions:prediction (lines 127-135) and rem:versions:answer (lines 137-145)
* Problem: [Second pass] The two remarks and the table repeat each other (the K_F gap, the W gap, the K(dom D) agreement, deterministic targets).
* Evidence: versions.tex:127-145.
* Fix: Merge into one remark 'What the gaps mean' of at most half a page.

**P1-ARX-47 (minor)** — `paper/sections/learn.tex`, rem:learn:ideal (lines 163-167)
* Problem: [Second pass] Repeats the introduction's 'Why SFI' paragraph and the Discussion's first paragraph almost item by item.
* Evidence: intro.tex:7; discussion.tex:5.
* Fix: Keep it here (it has the references) and shorten the other two to one sentence each pointing to it.
