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

