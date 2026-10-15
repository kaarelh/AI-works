# Outline: Paper 1, "Solomonoff Operator Induction: Definitions, Versions and Basic Theorems"

Renamed on 2026-10-15 under `research/paper-review/rename/RENAME.md` (binding): Solomonoff operator induction (SOI) is the family of universal-prior solutions to Solomonoff's operator-induction problem; SOI without qualification is the one-tape version $\MF$ (stated once, after `def:setting:sfi`); the versions are Solomonoff's per-query solution $\Mpq$ (his eq. (10)), the one-tape version $\MF$, the coin-free version $W$, the Kolmogorov version $\KF$ and the history-aware version \SFIhist{}. Planning text below that predates the rename keeps "SFI" only in quotations. Logs: `research/paper-review/rename/log-p1-{a,b,front}.md`.

> **BINDING NOTE 4 (2026-10-13): framing relative to the author's notes.** The papers read as the first presentation of this material; the author's notes are an internal stage of the research. No running-text citations or quotations of the notes, no framing of results as replies to or corrections of them; credit goes in short neutral footnotes and the acknowledgements. Full rules: `research/paper-review/REFRAME.md` (supersedes DECISIONS.md §A6 and the 'Relation to the author's notes' paragraphs).


> **BINDING NOTE (authorship, 2026-10-12).** arXiv does not allow AI tools as authors, so the author line is **Kaarel Hänni** alone, with no "Claude (Anthropic)" byline. Disclosure goes in two places:
> * **A title-page footnote:** the paper was developed and written with extensive assistance from Claude (Anthropic), an AI system, which produced the proofs, the computations and the text under the author's direction. It was checked by independent AI referees, and no human has yet independently checked all of the mathematics.
> * **A fuller paragraph in the acknowledgements.**
>
> Name the system "Claude (Anthropic)", never a specific model version. Ideas from the author's notes are cited as his notes (\citep{hanni2026notes}) or described as the author's. Sam Eisenstat is credited for his example. The Vaintrob–Hänni slides are cited as such.


> **BINDING NOTE (Hänni, 2026-10-12): the papers must be standard academic papers, suitable for arXiv.**
> * **Status tags and source notes.** The final PDF has no `\status{...}` tags and no `\src{...}` source notes. They stay in the sources only until the arXiv conversion pass, which removes them. Until then, keep them accurate: the conversion reads them.
> * **Proved results** are theorems, propositions, lemmas or corollaries, with proofs.
> * **Proof sketches** are labelled "Proof sketch", and the statement must not be presented as fully proved.
> * **Conjectures** go in the conjecture environment. Open questions go under "Open problems".
> * **Computed results** are stated as examples or remarks: "a direct computation (code in the accompanying repository) gives …".
> * **Refuted earlier claims** appear only where they inform the reader. Example: "the natural strengthening X fails: …". No list of internal corrections.
> * **No process vocabulary in the paper.** No "track", "referee", "ledger", "notes-final", "brief" or "orchestrator". No verification appendix. Instead, a short paragraph in the acknowledgements on how the paper was prepared and checked, and a "Code and data" statement pointing to the repository.
> * **Standard structure:** abstract, introduction with a contributions list, related work, preliminaries, results, discussion and open problems, references, appendices with proofs.
> * **References:** only references whose bibliographic data have been checked. Drop or replace a citation that cannot be checked; never print "unverified".
> * **Hänni's ideas** are credited through citations to his notes, or by stating the authorship arrangement. Sam Eisenstat's example is credited in the text and in the acknowledgements.
> * **Tone:** formal academic register. No conversational references to "his request".


> **BINDING NOTE (Hänni, 2026-10-12): do not call it "Wyeth's objection".** Absorption by a universal hypothesis under a steeper penalty is a standard point. It is known in algorithmic statistics, and Hänni's own note already makes it ("pathology of not specifying even the hypothesis in the seq prediction case"); he was aware of it before the LessWrong exchange. In visible text, call it **the absorption objection** or **the standard absorption point**. Do not name sections, theorems or remarks after Wyeth, and do not quote his comment. At most, one neutral footnote may record that the point was raised in the LessWrong thread. Internal LaTeX labels such as rem:absorb:wyeth may stay as they are (they are invisible), but their printed headings must not mention Wyeth.


Binding plan for all writers of `paper/`. Read it with `NOTATION.md` (one notation for both papers; macros; renamings) and `CLAIMS.md` (the ledger: every result with id = label, status, source, section; the cross-track conflicts; the answers to Hänni's requests). The companion paper is `../paper-steeper/` (Paper 2, steeper simplicity priors), with its own `OUTLINE.md` and `CLAIMS.md`.

## Audience and stance

* Readers: mathematically literate researchers in learning theory and algorithmic information theory. First reader: Kaarel Hänni, who asked for the paper (request quoted in `research/00-brief.md`).
* Purpose (his words): "some paper that explains what Solomonoff function induction is, proves some basic properties, says some stuff about why one might be interested in it". Definitions must be careful and self-contained; this paper establishes public fundamentals.
* Credit, stated in the introduction and where each item appears: the one-tape version of SOI ("function induction" in the notes), many of the theorem claims and most examples are Hänni's \citep{hanni2026notes}; say where his claims were corrected (`CLAIMS.md` §3). The coin example is Sam Eisenstat's, as reported by Hänni \citep{hanni2026request}. The NN Bayes material is from the Vaintrob–Hänni slides \citep{vaintrobhanni2026nnbayes}; state only what they claim, as their claims.
* Two papers, not one: the steeper-simplicity material (teacher's mistakes, model–randomness split, the absorption objection) is Paper 2 \citep{claudeSFI2026steeper}; this paper summarises it in one short section (`sec:steep`).

## Sources (the ONLY sources of claims)

* `research/00-brief.md`: Hänni's request and later request (verbatim), the source list, the orchestrator's hypotheses H1–H10 (to be confirmed or refuted, never assumed).
* `research/tracks/{foundations,history,examples,context}/notes-final.md`, with `referee.md` and `checks/`. Cite as `\src{foundations Thm 4.7}`, `\src{history Cor 3.9}`, `\src{examples Prop 2.9}`, `\src{context Prop 2.16}`. Use the FINAL numbering; where a final note cites another track's superseded numbering, `CLAIMS.md` §2 gives the number to use.
* `research/tracks/steeper/notes-final.md` only through Paper 2 (for `sec:steep`).
* `research/prior/`: Hänni's notes (`\src{Hänni notes}`; quote verbatim and cite \citet{hanni2026notes}) and the slides (`\src{slides, <part>}`).
* The final notes supersede every `notes.md`. Nothing else is a source of claims.

## Rules for writers (binding)

1. **Status and source on every theorem-like environment.** `\status{...}` with values from {proved, computed, conjecture, known, proof sketch, refuted}, combined with ";" and with part labels where parts differ (`\status{(a) proved; (b) proof sketch}`), plus `known; unverified` for literature not checked against the source and `known; unverified (claimed in the slides)` for the slides. `\src{<track> <item>}` on every such environment; definitions get `\src` only. Use exactly the status of `CLAIMS.md`.
2. **Never claim more than the final notes establish.** Keep every hypothesis, convention ("semimeasure convention" on every lower bound), constant and scope restriction. Numbers carry units (bits) and say which check computed them.
3. **Refuted claims stay**, labelled `\status{refuted}`, with the counterexample, next to the corrected statement (e.g. `prop:ood:draftfalse`, `rem:learn:cesaro`, `prop:hist:info`(b), `prop:learn:freshnoise` for H7). The full list goes to `app-verification`.
4. **Labels** exactly as in `CLAIMS.md`: `sec:<key>`, `sec:<key>:<sub>`, `app:<key>`, `thm:`/`prop:`/`lem:`/`cor:`/`def:`/`ex:`/`rem:`/`conj:` + `<key>:<name>`, `tab:<key>:<name>`, `fig:<key>:<name>`, `eq:<key>:<name>`; open questions are `\paragraph{Open question.}\label{q:<key>:<name>}` in prose, never a theorem environment. Keys: `intro, setting, versions, learn, hist, ex, ood, comp, nn, steep, related, discussion, verification`. Cross-reference with `\Cref`.
5. **Proofs.** The main text states each result and gives a proof idea in two to six sentences; full proofs go to the section's appendix (`\Cref{app:<key>}`), as in the notes, naming any step the notes leave out. Short proofs (≤ 6 lines) may stay in the main text.
6. **Notation and macros** only from `NOTATION.md` and the "SOI macros" block. No `\newcommand` in section files except local ones prefixed by the section key (`\histfoo`), defined at the top of the file, and only if unavoidable. Rename sources' symbols as `NOTATION.md` §4 requires (tape measure $\Unif$, $d$ = input length, $N=2^d$, $\Kpad$, $\Ktail$, $\MH$, $j$ for confidence exponents, …).
7. **Bibliography.** Keys of `bib/core.bib` first, then the canonical keys of `NOTATION.md` §9.2, with entries in `bib/<key>.bib` (`setting.bib`, `learn.bib`, `hist.bib`, `examples.bib`, `ood.bib`, `comp.bib`, `nn.bib`, `related.bib`, `steeper.bib`, `framing.bib`). Never invent bibliographic data: an entry you could not check gets a comment `% unverified: <what was checked>` and the sentence citing it is hedged. arxiv.org and lesswrong.com do not resolve from here; WebSearch gives snippets only.
8. **Style.** Plain, precise prose; short sentences; no marketing words. Say "we" for the authors' arguments, "Hänni" for his claims. Every lower bound names its convention.
9. **Build check.** From `paper/`: `./test-section.sh <section> <appendix>` (e.g. `./test-section.sh setting app-setting`). Undefined references to other sections are expected. The full build only as `flock /tmp/claude-0/paper-build-sfi.lock ./build.sh`, and only when told to.
10. **Ownership.** Edit only your own files (below). Ask the planning editor for a new global symbol, a changed label or a moved result; record it in `CLAIMS.md` only through the editor.

## Writers and files

| writer | files (all in `sections/`) | ledger sections |
|---|---|---|
| **setting** | `setting.tex`, `versions.tex`, `app-setting.tex`, `app-versions.tex` | `setting`, `versions` |
| **learn** | `learn.tex`, `app-learn.tex` | `learn` |
| **hist** | `hist.tex`, `app-hist.tex` | `hist` |
| **ex** | `examples.tex`, `app-examples.tex` | `ex` |
| **oodcomp** | `ood.tex`, `comp.tex`, `nn.tex`, `related.tex`, `app-ood.tex`, `app-comp.tex`, `app-nn.tex` | `ood`, `comp`, `nn`, `related` |
| **steep-a** (Paper 2 writer) | `steeper.tex` (this paper's summary of Paper 2) | `steep` |
| **framing editor** (reserved) | `abstract.tex`, `intro.tex`, `discussion.tex`, `app-verification.tex` (stubs exist) | `intro`, `discussion`, `verification` |

Bib files: setting → `bib/setting.bib`; learn → `bib/learn.bib`; hist → `bib/hist.bib`; ex → `bib/examples.bib`; oodcomp → `bib/ood.bib`, `bib/comp.bib`, `bib/nn.bib`, `bib/related.bib`; steep-a → `bib/steeper.bib`; framing → `bib/framing.bib`.

---

## 0. `abstract.tex` (framing editor; written last; ≤ 250 words)

What SOI is (a universal prior over random functions with shared randomness; Hänni's notion); the main results in one sentence each: universality and the versions question (no coding theorem for function programs), dominance/merging/online-to-batch and the fresh-noise caveat, history-aware prediction (\SFIhist{} is the universal chronological semimeasure; Hänni's Thm 1 true in his reading, its proof sketch not), the two worked examples, OOD; one sentence on Paper 2.

## 1. `intro.tex` — key `intro` — ≈ 2.5 pp (framing editor)

Hänni's request and why SOI is of interest (ideal supervised learning; the slides' NN Bayes link); the contributions in brief, one paragraph per answer of `CLAIMS.md` §3 (R1–R8 and the later request), each with `\Cref`s; credit (Hänni, Eisenstat as reported by Hänni, Vaintrob–Hänni); a table `tab:intro:verdicts` of the brief's hypotheses H1–H10 with verdicts and where (H9 → Paper 2); what is not achieved (open problems collected from the `q:` rows); reader's guide. No theorem environments.

---

## 2. `setting.tex` — key `setting` — ≈ 4.5 pp (writer: setting) — "Function semimeasures, function machines and SOI"

**Purpose.** Define the objects carefully, prove universality, fix the conventions, and state the basic properties (invariance, coding bounds, relation to SI, computability). Everything later builds on this section.

**Subsections and results.**
* `sec:setting:data` Data and conventions: `def:setting:data`. State the repeated-input convention and the two loss conventions here.
* `sec:setting:weak` Three notions of function semimeasure: `def:setting:weak`, `prop:setting:predictor`, `prop:setting:normtotal`, `def:setting:rpf`, `prop:setting:mobius`, `ex:setting:weaknotrpf`.
* `sec:setting:machines` Function machines and universality: `def:setting:machine`, `prop:setting:machinelaw`, `thm:setting:universal`, `prop:setting:includes`, `rem:setting:perinput`, `lem:setting:total`, `thm:setting:weakuniversal`, `thm:setting:weakvsmachine`, `cor:setting:normuniversal`, `rem:setting:h1a`, `q:setting:rpf`.
* `sec:setting:sfi` The one-tape version of SOI and its conventions (the default convention is stated here, once): `def:setting:sfi`, `prop:setting:order`, `prop:setting:normalise`, `prop:setting:transfer`, `rem:setting:conventions` (the **updated** list, `CLAIMS.md` C7), `q:setting:normorder`, `rem:setting:recommend`.
* `sec:setting:basic` Basic properties: `thm:setting:invariance`, `thm:setting:coding`, `ex:setting:swap`, `q:setting:twosided`, `prop:setting:si`, `prop:setting:computability`, `q:setting:level`.

**Notes.** Write $\Unif$ for the tape measure, $d$ for input length. State `rem:setting:h1a` as a refutation of the brief's "or equivalently monotone function machines" for the weak definition. The Möbius remark on random sets is "known; unverified". `ex:setting:swap` must say it does not separate SOI from history-aware prediction (C21).

**Appendix `app-setting.tex` (`app:setting`) — ≈ 5 pp.** Proofs of `prop:setting:mobius`, `prop:setting:machinelaw` (with the effective enumeration), `rem:setting:fillin`, `lem:setting:realise`, `prop:setting:includes` (private streams; computable laws; mixtures), `thm:setting:weakuniversal` (trimming), `thm:setting:weakvsmachine` (with the exactness of $(2/3)^k$), `prop:setting:twopoint`, `prop:setting:transfer`, `thm:setting:invariance`, `thm:setting:coding`, `prop:setting:computability`; the reformulation of `q:setting:rpf` (proof sketch, with the quoted Strassen step marked).

**Cross-references out.** `versions` (variants, chain), `learn` (dominance uses `thm:setting:universal`), `hist` (`lem:hist:chrono` uses `prop:setting:order`).

## 3. `versions.tex` — key `versions` — ≈ 3.5 pp (writer: setting) — "Kolmogorov and semimeasure versions"

**Purpose.** Answer Hänni's later request: compare $\KF$, $W$, $\Mprod$, $\MF$, $\Mw$ (and $\Mpq$), state exactly what is equal, what differs with which witnesses and rates, and what it means for prediction. End with the answer in plain words.

**Subsections and results.**
* `sec:versions:defs` The variants: `def:versions:variants`, `rem:versions:Wdelim`, `rem:versions:operator`, `rem:versions:randomness`.
* `sec:versions:chain` The chain and the gaps: `thm:versions:chain`, `prop:versions:Wgap`, `rem:versions:Wrate`, `prop:versions:tape`, `prop:versions:shared`, `rem:versions:sharedsize`.
* `sec:versions:coding` No coding theorem for function programs: `thm:versions:nocoding`, `cor:versions:twopoint`, `prop:versions:covering`, `rem:versions:noncomputable`, `q:versions:explicit`.
* `sec:versions:table` Summary and meaning for prediction: `tab:versions:compare` (one table, all rows of F Table 4.12), `rem:versions:prediction`, `prop:versions:structured`, `rem:versions:hist`, `rem:versions:answer`, `q:versions:open`.

**Notes.** Solomonoff's solutions (`rem:versions:operator`): his eq. (10) is $\Mpq$, his eq. (9) the joint solution, eq. (12) his convergence theorem; Solomonoff 2008 read in full (C1; RENAME.md §2). The hashing bound appears only in the appendix (`rem:versions:hashing`) with the remark that the brief's "log factor via hashing" describes $\KF$. Keep the witnesses' non-computability (`rem:versions:noncomputable`) next to every gap.

**Appendix `app-versions.tex` (`app:versions`) — ≈ 5 pp.** Proofs of `prop:versions:Wgap`, `prop:versions:tape`, `rem:versions:hashing`, `prop:versions:shared`, `thm:versions:nocoding`, `cor:versions:twopoint`, `prop:versions:covering` (with the Kleitman–Spencer remark, known; unverified), `prop:versions:structured`.

**Cross-references out.** `hist` (`prop:hist:programs`), `learn` (Occam comparison), Paper 2 (`rem:absorb:why` uses `prop:versions:shared`, `rem:versions:sharedsize`; `lem:split:stream` adapts `prop:versions:tape`).

## 4. `learn.tex` — key `learn` — ≈ 5 pp (writer: learn) — "Learning theorems: SOI as supervised learning"

**Purpose.** The guarantees that make SOI "ideal supervised learning", with their limits: pathwise dominance, merging, mistake bounds, online-to-batch, noise (fresh vs frozen vs stamped vs per-query), learning curves, in-distribution error, comparison with Occam/PAC-Bayes/MDL, and the analogy's limits.

**Subsections and results.**
* `sec:learn:dominance` Dominance: `thm:learn:dominance`, `rem:learn:h2`.
* `sec:learn:merging` Merging and mistakes: `thm:learn:merging`, `cor:learn:mistakes`.
* `sec:learn:batch` Online-to-batch and noise: `thm:learn:batch`, `prop:learn:freshnoise` (H7 as stated refuted for the one-tape version), `prop:learn:perquery`.
* `sec:learn:curves` Learning curves and in-distribution error: `prop:learn:curve`, `rem:learn:lastiterate`, `prop:learn:splits`, `prop:learn:loo`, `rem:learn:increasing`, `conj:learn:loo`, `prop:learn:typical`, `rem:learn:cesaro`, `cor:learn:perstep`, `rem:learn:relations`.
* `sec:learn:ideal` Comparison and the sense of "ideal": `prop:learn:occam`, `rem:learn:ideal`, `rem:learn:hutterEX`, `prop:learn:active`, `rem:learn:positive`, `rem:learn:interventions`.

**Notes.** Give the exchangeability argument once (`thm:learn:batch`) and cite it for `prop:learn:splits` (C16(d)). $\mu$ is the input distribution. Co's sample size $m$ is $n$ here.

**Appendix `app-learn.tex` (`app:learn`) — ≈ 5 pp.** Proofs of `thm:learn:merging` (posterior lemma, integrability), `thm:learn:batch`, `prop:learn:perquery`, `prop:learn:curve`, `rem:learn:lastiterate` (identity), `prop:learn:splits`, `prop:learn:loo`, `prop:learn:typical`, `cor:learn:perstep`, `prop:learn:occam`, `prop:learn:active`.

**Cross-references out.** `setting`, `versions` (`prop:learn:occam` vs `thm:versions:nocoding`), `hist` (comparator class limit), `ood` (distribution shift), `ex` (positive examples), `comp` (time-bounded analogue of the stamped one-tape version).

## 5. `hist.tex` — key `hist` — ≈ 5.5 pp (writer: hist) — "History-aware prediction"

**Purpose.** What SOI cannot do with the order of the data and what fixes it: Hänni's counterexamples, his Thm 1 (three readings; true in his reading, proof sketch invalid), \SFIhist{} as the universal chronological semimeasure (H4), its relation to SI, and what SOI can exploit.

**Subsections and results.**
* `sec:hist:setting` History-aware predictors: `def:hist:predictor`, `lem:hist:chrono`.
* `sec:hist:counter` Hänni's counterexamples: `thm:hist:chain`, `thm:hist:skipped`, `prop:hist:orderfree`, `prop:hist:normchain` (the broom method, presented once here; C16(c)).
* `sec:hist:thm1` Hänni's Thm 1: `def:hist:readings`, `lem:hist:memory`, `prop:hist:sketchfails`, `thm:hist:shared`, `cor:hist:deterministic`, `cor:hist:joint`, `thm:hist:bayes`, `thm:hist:directed`, `thm:hist:randchain`, `thm:hist:minimax`, `cor:hist:thm1`, `rem:hist:thm1open`, `prop:hist:shannon`, `conj:hist:algmi`, `prop:hist:nopathwise`.
* `sec:hist:sfihist` \SFIhist{} and H4: `def:hist:sfihist`, `lem:hist:chronolaw`, `thm:hist:representation`, `cor:hist:H4`, `prop:hist:variants`, `prop:hist:strict`, `prop:hist:operator`, `prop:hist:programs`.
* `sec:hist:si` As good as SI?: `thm:hist:si`, `prop:hist:inputloss`, `prop:hist:lhg`, `rem:hist:H4verdict`.
* `sec:hist:exploit` What SOI can and cannot exploit: `thm:hist:sandwich`, `cor:hist:initial`, `thm:hist:gf`, `thm:hist:expected`, `prop:hist:info`, `rem:hist:exploit`, `q:hist:open`.

**Notes.** Define the universal chronological semimeasure as $\MH$; mention F's trimming construction as an alternative equal up to constants; Hutter identification "known; unverified" (C13). Hypotheses of the minimax theorem are (A1), (A2). Private memory is $\Gamma$. GF$(2^q)$. Hi's cyclic-permutation result (Hi Prop 4.8) is **not** stated here: it is `prop:ex:cychist` (C16(a)). Lower bounds carry "semimeasure convention"; `prop:hist:normchain` gives the normalised versions.

**Appendix `app-hist.tex` (`app:hist`) — ≈ 7 pp.** `lem:hist:chain0`, proofs of `thm:hist:chain`, `thm:hist:skipped`, `lem:hist:broom`, `prop:hist:normchain`, `thm:hist:shared`, `thm:hist:directed`, `thm:hist:minimax` (with the computable-real extension and the proof-sketch part marked), `thm:hist:representation` (interval allocation), `prop:hist:strict`, `prop:hist:strictinf`, `lem:hist:block`, `thm:hist:si`, `prop:hist:programs`, `lem:hist:charsum`, `thm:hist:gf`, `prop:hist:info`.

**Cross-references out.** `setting` (`prop:setting:order`, `thm:setting:coding`), `learn` (`prop:learn:perquery`), `versions` (`prop:versions:tape` analogue), `ex` (H5, H6 use `cor:hist:H4`, `lem:hist:broom`), `comp` (`prop:comp:history`), Paper 2 (`prop:absorb:inputs` uses `cor:hist:H4`).

## 6. `examples.tex` — key `ex` — ≈ 4.5 pp (writer: ex) — "Worked examples"

**Purpose.** Hänni's two examples where SOI does much worse than SI, worked out exactly (statements with probabilities, conventions and constants), and positive examples where SOI works well.

**Subsections and results.**
* `sec:ex:tools` Tools: `lem:ex:surprisal` (and `lem:ex:silabel` stated, proved in the appendix).
* `sec:ex:cyclic` The cyclic permutation (H5): `def:ex:cyclic`, `thm:ex:cycle`, `thm:ex:ksteps`, `prop:ex:orderfree`, `q:ex:depthweak`, `prop:ex:normalised` (using `lem:hist:broom`), `prop:ex:cychist`, `prop:ex:cycset`, `prop:ex:cycsi`, `tab:ex:cycle`, `rem:ex:where`.
* `sec:ex:eisenstat` Eisenstat's example (H6): `def:ex:eisenstat`, `lem:ex:shape`, `prop:ex:UB`, `thm:ex:sandwich`, `prop:ex:asymp`, `thm:ex:expected`, `prop:ex:law`, `rem:ex:email`, `prop:ex:burnin`, `thm:ex:eisensi`, `cor:ex:rule`, `prop:ex:rulestats`, `tab:ex:eisenstat`, `q:ex:normalised`.
* `sec:ex:positive` Positive examples: `prop:ex:deterministic`, `ex:ex:parity`, `ex:ex:threshold`, `ex:ex:sorting`, `ex:ex:poly`, `prop:ex:frozen`, `rem:ex:fresh`.

**Notes.** Bit length is $d$, $N=2^d$; the touching constant is $\vartheta$; heads and tails counts are $N^1_n,N^0_n$; binary entropy $H(1/3)$; confidence exponent $j$. Credit Eisenstat "as reported by Hänni" and quote the e-mail argument from the brief. SI uses the paper's code $\bar s=1^{|s|}0s$ (C9); raw blocks only in the appendix (C8). Hänni's OOD examples are not here (they are in `ood`).

**Appendix `app-examples.tex` (`app:ex`) — ≈ 5 pp.** `lem:ex:silabel`, `lem:ex:chainsemi`, `lem:ex:depth`, proofs of `thm:ex:cycle`, `thm:ex:ksteps`, `prop:ex:normalised`, `prop:ex:cycsi`, `prop:ex:cycraw`, `conj:ex:raw`, `rem:ex:prior`, `thm:ex:sandwich`, `prop:ex:asymp` (CLT), `lem:ex:behind`, `prop:ex:law`, `lem:ex:pstar`; the description of the checks e1–e7 (seeds, what each verifies).

**Cross-references out.** `hist` (`cor:hist:H4`, `lem:hist:broom`, `prop:hist:orderfree`, `prop:hist:strict`), `learn` (`cor:learn:mistakes`, `prop:learn:freshnoise`), `setting` (`rem:setting:conventions`), Paper 2 (the threshold sampler of H6 is covered by Paper 2's `thm:split:lambda1`).

## 7. `ood.tex` — key `ood` — ≈ 3.5 pp (writer: oodcomp) — "Out-of-distribution behaviour"

**Purpose.** Hänni's OOD proposition and the PDF draft's two-sided result, made precise; the limits (machine dependence, bounded total failure, the converse); his examples.

**Subsections and results.**
* `sec:ood:prop` Unseen simple properties: `prop:ood:hanni`, `rem:ood:logterm`, `prop:ood:relative`, `prop:ood:machine`.
* `sec:ood:twosided` The draft's two-sided result: `thm:ood:twosided`, `prop:ood:draftfalse`.
* `sec:ood:budget` OOD failure is bounded: `thm:ood:cumulative`, `prop:ood:budget`, `rem:ood:lopsided`.
* `sec:ood:converse` Converses: `prop:ood:converse`, `prop:ood:sandwich`, `prop:ood:labelled`, `ex:ood:easyhard`, `rem:ood:answer`, `q:ood:converse`.
* `sec:ood:examples` Hänni's examples: `prop:ood:intended`, `ex:ood:hanniexamples`, `tab:ood:hanni`, `conj:ood:natural`.

**Notes.** Say for each lower bound that it bounds the defined-and-wrong mass and holds in both conventions. Hänni's plain complexities $C(\cdot)$ become $K(\cdot)$ (say so once). Novelty is $\sep_k$. Co Prop 2.14's data set $\lambda_y$ is $D^*_y$.

**Appendix `app-ood.tex` (`app:ood`) — ≈ 2.5 pp.** Proofs of `prop:ood:machine`, `thm:ood:twosided`, `prop:ood:draftfalse`, `prop:ood:converse`, `prop:ood:labelled`; the grammar computation e5 (setting, table).

**Cross-references out.** `learn` (`thm:learn:dominance`, `cor:learn:perstep`), `setting` (conventions), Paper 2 (`prop:limits:ood` is the λ > 1 counterpart of `prop:ood:hanni`).

## 8. `comp.tex` — key `comp` — ≈ 3 pp (writer: oodcomp) — "Computable versions"

**Purpose.** Time-bounded SOI (Hänni's polytime note) and circuit SOI (his circuit notes): what holds, with which constants and running times, and where Occam learning fails.

**Subsections and results.**
* `sec:comp:time` Time-bounded SOI: `def:comp:timebounded`, `thm:comp:timebounded`, `rem:comp:distinct`, `rem:comp:constant`, `prop:comp:round`, `cor:comp:poly`, `rem:comp:apples`, `prop:comp:history`, `prop:comp:samplers`, `q:comp:samplers`.
* `sec:comp:circuits` Circuit SOI: `def:comp:circuits`, `thm:comp:circuitbayes`, `rem:comp:gap`, `prop:comp:occam`, `rem:comp:majority`.
* `sec:comp:ladder` Occam fails out of distribution: `thm:comp:ladder`, `rem:comp:adversary`, `rem:comp:selection`, `rem:comp:uniformties`, `q:comp:open`.

**Notes.** Time bound $t(\cdot)$; clock $\tau_k(x)$; mixtures $\Mlen$, $\Mrd$; circuit mixture $\Wcirc$, size $\csize$; expected Gibbs mistakes $\mathcal E$. The ladder construction is from the slides; credit it.

**Appendix `app-comp.tex` (`app:comp`) — ≈ 2.5 pp.** Proofs of `thm:comp:timebounded` (with the proof-sketch part marked), `prop:comp:history`, `thm:comp:circuitbayes`, `lem:comp:mobius`, `thm:comp:ladder`.

**Cross-references out.** `learn` (stamped one-tape version), `hist` (chronological learner), `nn`, Paper 2 (`prop:related:computable`: Theorems 2 and 4 transfer to computable product classes).

## 9. `nn.tex` — key `nn` — ≈ 2 pp (writer: oodcomp) — "Neural-network Bayes and circuit SOI"

**Purpose.** Hänni asked to link the slides that "explain how NNbayes is kinda like a circuit version of SFI". State what is proved, what the slides claim, and what is open; hedge the bridge.

**Results.** `prop:nn:functionspace`, `prop:nn:upper`, `prop:nn:typical`, `prop:nn:nolower`, `prop:nn:uniform`, `rem:nn:bridge`, `thm:nn:walsh`, `cor:nn:separation`, `rem:nn:oddparity`, `rem:nn:slides`, `rem:nn:rigorous`, `rem:nn:literature`, `q:nn:bridges`.

**Notes.** Every claim of the slides carries `\status{known; unverified (claimed in the slides)}` and the slides' own caveats; their notation $\kappa_N$, $C$, $C_L$ is quoted. Kernel profile $\Psi$. arXiv 2607.05735 is snippet-only (`vaintrob2026width`, unverified).

**Appendix `app-nn.tex` (`app:nn`) — ≈ 1 p.** Proofs of `prop:nn:uniform`, `thm:nn:walsh`, `cor:nn:separation`, `rem:nn:oddparity`(b),(c).

**Cross-references out.** `comp` (circuit setting), Paper 2 (`rem:related:nn`).

## 10. `steeper.tex` — key `steep` — ≈ 1.5 pp (writer: steep-a) — "Steeper simplicity priors (summary of the companion paper)"

**Purpose.** Tell the reader of this paper what Paper 2 shows, in prose, with `\citet{claudeSFI2026steeper}` and result names. No theorem environments, no proofs, no new claims.

**Contents (in order).** Hänni's proposal (λ > 1 on program length; private randomness per input) and the standard absorption objection. Absorption in any class containing its own mixture (SI, $\MF$, $\Mw$, $\MH$), and no universal product hypothesis; the price of private randomness on shared latent causes. The teacher's-mistakes theorem: window $(2^{-m},c_{\rm hi}]$ in $\lambda/n$ at Hänni's sizes, all product hypotheses quantified over, for incompressible error rules; λ must grow linearly in $n$; error envelopes refute the extension to every rule of that density and length; rate blindness. The model–randomness split: λ = 1 similar posterior (per-query solution and SI); fixed λ > 1 with private randomness the sampler wins; shared randomness or SI: no split; product versus set sophistication ($d\pm O(\log d)$ vs $O(\log d)$). Prior work: λ-weighted MDL in noisy classification. Write $\lambda/n$, never $c$.

**Cross-references out.** `versions` (`prop:versions:shared`: the λ = 1 cost of private randomness), `learn` (`prop:learn:perquery`), `hist` (`cor:hist:H4`), `ood` (`prop:ood:hanni`).

## 11. `related.tex` — key `related` — ≈ 1 p (writer: oodcomp) — "Related work"

**Contents.** Solomonoff's operator-induction problem: the term (Solomonoff 1999), the problem, solutions (9) and (10) and theorem (12) (Solomonoff 2008), both read in full; Hutter's chronological semimeasures and "supervised learning from examples"; Lattimore–Hutter–Gavane; Wood–Sunehag–Hutter; Lattimore–Hutter on NFL; Poland–Hutter MDL; Leike–Hutter bad priors; Occam, PAC-Bayes, online-to-batch, expert advice; Ryabko; Vovk and conformal prediction; inductive inference of recursive functions (Gold; Barzdin–Freivalds; Case–Smith); speed priors; simplicity bias in networks (pointer to `sec:nn`). One item: `rem:related:new` (what exists and what appears new at a snippet-level search). Sources: Co §6, Hi §4.6, F §6.6. Hedge every content claim not checked against the source.

## 12. `discussion.tex` — key `discussion` — ≈ 1.5 pp (framing editor)

What SOI is good for and where the analogy with supervised learning breaks (from `rem:learn:ideal`); the main open problems, collected from the `q:` rows (`q:setting:rpf`, `q:versions:open`, `q:setting:normorder`, `q:ex:normalised`, `rem:hist:thm1open`, `conj:hist:algmi`, `conj:learn:loo`, `q:comp:samplers`, `q:nn:bridges`); a pointer to Paper 2.

## Appendices

Order: `app-setting` (A), `app-versions` (B), `app-learn` (C), `app-hist` (D), `app-examples` (E), `app-ood` (F), `app-comp` (G), `app-nn` (H), `app-verification` (I). Each starts with `\section{<title>}\label{app:<key>}` (keys: `setting`, `versions`, `learn`, `hist`, `ex`, `ood`, `comp`, `nn`, `verification`).

**`app-verification.tex` (`app:verification`; framing editor) — ≈ 2.5 pp.** How the claims were checked: the five tracks, the referees, the check scripts (by track, with seeds, as in each verification log); the full list of refuted claims (Hänni's, the brief's, and the tracks' own earlier ones) with where each is corrected; the cross-track conflicts of `CLAIMS.md` §2 in short form; what is not machine-checked; literature checked only by snippets.

---

## Cross-paper references

* Paper 1 cites Paper 2 as `\citet{claudeSFI2026steeper}` with the result's name ("the absorption theorem", "the teacher's-mistakes theorem", "Theorem 3 of …" only after the framing editor has fixed numbers). No `\ref` across papers.
* Paper 2 cites this paper as `\citet{claudeSFI2026fundamentals}` for: function machines and $\MF$ (`thm:setting:universal`), product laws as machine laws (`prop:setting:includes`), $\Mw$ (`thm:setting:weakuniversal`), the variants and the chain (`def:versions:variants`, `thm:versions:chain`), the shared-coin gap and its size (`prop:versions:shared`, `rem:versions:sharedsize`), the tape-length bound and hashing (`prop:versions:tape`, `rem:versions:hashing`), dominance, merging and mistakes (`thm:learn:dominance`, `thm:learn:merging`, `cor:learn:mistakes`), frozen noise and fresh noise (`thm:learn:batch`(c), `prop:learn:freshnoise`), per-query mixture (`prop:learn:perquery`), computability (`prop:setting:computability`), \SFIhist{} (`cor:hist:H4`), OOD (`prop:ood:hanni`), time-bounded SOI (`thm:comp:timebounded`, `prop:comp:samplers`), the NN bridge (`prop:nn:functionspace`), the ladder (`thm:comp:ladder`, `rem:comp:uniformties`).
* T5 (the earlier report) is cited only by Paper 2: `\citet{claude2026whatfollows}`, section "Simplicity and normativity from imitation".

## Global cross-reference map (within Paper 1)

setting → (none earlier). versions → setting. learn → setting, versions. hist → setting, learn. ex → setting, learn, hist. ood → setting, learn. comp → learn, hist. nn → comp. steep → versions, learn, hist, ood. related → all. Forward references only as "see \Cref{...}" without relying on later content for proofs.

## Page budget (11pt, `geometry` margin 1.05in)

| section | file | main pp | appendix pp |
|---|---|---|---|
| intro | intro.tex | 2.5 | — |
| setting | setting.tex / app-setting.tex | 4.5 | 5 |
| versions | versions.tex / app-versions.tex | 3.5 | 5 |
| learn | learn.tex / app-learn.tex | 5 | 5 |
| hist | hist.tex / app-hist.tex | 5.5 | 7 |
| ex | examples.tex / app-examples.tex | 4.5 | 5 |
| ood | ood.tex / app-ood.tex | 3.5 | 2.5 |
| comp | comp.tex / app-comp.tex | 3 | 2.5 |
| nn | nn.tex / app-nn.tex | 2 | 1 |
| steep | steeper.tex | 1.5 | — |
| related | related.tex | 1 | — |
| discussion | discussion.tex | 1.5 | — |
| verification | app-verification.tex | — | 2.5 |
| **total** | | **38** (target 35–40) | **35.5** (target ≈ 35) |

The targets are caps. If a section runs long, move secondary remarks and tables to its appendix first.
