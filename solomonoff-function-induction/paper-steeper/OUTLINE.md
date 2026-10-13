# Outline: Paper 2, "Steeper Simplicity Priors in Solomonoff Function Induction" (working title)

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


Binding plan for all writers of `paper-steeper/`. Read it with `../paper/NOTATION.md` (one notation for both papers; the macro block in `preamble.tex` is identical to Paper 1's) and `CLAIMS.md` (this paper's ledger, conflicts and answers). The companion paper is `../paper/` (Paper 1, fundamentals), cited as `\citet{claudeSFI2026fundamentals}`.

## Audience and stance

* Readers: learning theory, MDL, algorithmic information theory. First reader: Kaarel Hänni.
* Subject: Hänni's proposal to penalise program length more steeply than likelihood (λ > 1) in *function* induction where "each input gets its own private randomness", so that the selected hypothesis is "simple model + noise" rather than "model + memorised errors", and his related hope for a preference for a simple sampler over filled-in bits. Sources of the idea: his grokking note and the LessWrong thread \citep{hanni2026notes,hanni2026lesswrong}, where the standard absorption objection also came up. **The paper must answer the absorption objection explicitly** (`rem:absorb:wyeth`), without attributing it to Wyeth (see the binding note above).
* Credit: the proposal, the example and its numbers are Hänni's; the absorption objection is a standard point (do not attribute it to Wyeth or quote him); the earlier formalisation T5 is section "Simplicity and normativity from imitation" of \citet{claude2026whatfollows}; say what is re-derived from T5 and what is new (`rem:related:t5`). λ-weighted two-part MDL in noisy classification is prior work (`rem:related:mdl`); "bounded λ overfits, λ must grow" is not claimed.
* Self-contained but short on foundations: definitions of function machines, $\MF$, $\Mprod$, $\Mw$, $\MH$ are recalled in two paragraphs with pointers to Paper 1.

## Sources (the ONLY sources of claims)

* `research/tracks/steeper/notes-final.md` (+ `referee.md`, `referee-run1.md`, `checks/`): cite as `\src{steeper Thm 2}`, `\src{steeper Prop 2.17}`, `\src{steeper Lemma 3.2′}` (FINAL numbering).
* Paper 1's results, cited by name through `\citet{claudeSFI2026fundamentals}`; their track sources are in `../paper/CLAIMS.md`.
* `research/prior/hanni-grokking-a-notion.md`, `hanni-lesswrong-comment-thread.md` (quote verbatim), and T5 through \citet{claude2026whatfollows}.

## Rules for writers (binding)

Rules 1–10 of `../paper/OUTLINE.md` apply verbatim, with these changes:
* Keys: `intro, setup, absorb, teacher, limits, split, algstat, related, discussion, verification`.
* Build check from `paper-steeper/`: `./test-section.sh <section> <appendix>`. Full build only as `flock /tmp/claude-0/paper-build-sfi.lock ./build.sh`, and only when told to.
* **Notation swap (binding, error-prone):** $n$ = number of samples (St's $N$); $N=2^d$ (St's $n$); $d_n$ = largest input length (St's $n_N$); $c=\lambda/n$; machine constant κ; (Dom) constants $\kappa_0,\kappa_1$; classes $\mathcal H_\times$ etc.; $\lev(\pi)$; $\Phi_1,\Phi_2$; slack $\epsilon$; Ville deficiency $\delta^*$; $\ell^*_\lambda$; sufficiency slack $b$; set models $A$; input law $\mu$. See `CLAIMS.md` P1 and `../paper/NOTATION.md` §4. Re-derive every displayed formula after renaming; check one numerical instance against St's tables.
* **κ = 0 numbers are illustrations.** Every table row at κ = 0 says so; the κ = 30 rows show how bounds degrade.
* Paper 2 uses programs $\pi$ and $\ell(\pi)$; $p$ is the error density.

## Writers and files

| writer | files (all in `sections/`) | ledger sections |
|---|---|---|
| **steep-a** | `setup.tex`, `absorb.tex`, `split.tex`, `algstat.tex`, `app-setup.tex`, `app-absorb.tex`, `app-split.tex`, `app-algstat.tex`; also `../paper/sections/steeper.tex` (Paper 1's summary) | `setup`, `absorb`, `split`, `algstat` |
| **steep-b** | `teacher.tex`, `limits.tex`, `related.tex`, `app-teacher.tex`, `app-limits.tex`, `app-related.tex` | `teacher`, `limits`, `related` |
| **framing editor** (reserved) | `abstract.tex`, `intro.tex`, `discussion.tex`, `app-verification.tex` (stubs exist) | `intro`, `discussion`, `verification` |

Bib files: steep-a → `bib/steep-a.bib`; steep-b → `bib/steep-b.bib`; framing → `bib/framing.bib`. Shared verified entries are in `bib/core.bib` (identical to Paper 1's).

---

## 0. `abstract.tex` (framing; ≤ 200 words)

Hänni's proposal; the absorption objection and the absorption theorem; private randomness blocks absorption at a price; the teacher's-mistakes theorem (all product hypotheses, Hänni's numbers, incompressible error rules, λ ∝ n) and its limits (error envelopes, rate blindness); the model–randomness split (λ = 1 similar posterior; λ > 1 private: sampler wins; shared: no split; product vs set sophistication).

## 1. `intro.tex` — key `intro` — ≈ 1.5 pp (framing)

Hänni's proposal in his words; the absorption objection (a standard point) and Hänni's reply; what we prove (one paragraph per answer in `CLAIMS.md` §3); what is prior work; reader's guide. Table `tab:intro:claims`: Hänni's specific claims (St §5) with verdicts and where.

## 2. `setup.tex` — key `setup` — ≈ 2.5 pp (writer: steep-a) — "Setting: hypothesis classes and steeper objectives"

**Results.** `def:setup:data`, `def:setup:product`, `def:setup:shared`, `def:setup:class`, `def:setup:objectives`, `lem:setup:basic`, `rem:setup:persample`, `lem:setup:hull`, `lem:setup:coding`.

**Notes.** Recall from Paper 1 (by name): function machines and $\MF$, product laws as machine laws, $\Mw$, $\Mprod$, $\MH$, frozen vs fresh noise (`prop:learn:freshnoise`, `thm:learn:batch`(c)). State clearly that $\lambda=cn$ is a family of batch objectives, not one Bayesian predictor. Keep the refuted "iff" of St `notes.md` as a remark inside `lem:setup:hull`.

**Appendix `app-setup.tex` (`app:setup`) — ≈ 1 p.** Proof of `lem:setup:hull` (with the computed check c6(F)), `lem:setup:coding`.

## 3. `absorb.tex` — key `absorb` — ≈ 3 pp (writer: steep-a) — "The absorption objection, and why private randomness blocks it"

**Results.** `thm:absorb:absorption`, `rem:absorb:examples`, `rem:absorb:reading`, `prop:absorb:pricing`, `cor:absorb:nouniversal`, `rem:absorb:condsemi`, `rem:absorb:why`, `prop:absorb:price`, `prop:absorb:history`, `prop:absorb:inputs`, `rem:absorb:wyeth`, `q:absorb:shared`.

**Notes.** `rem:absorb:wyeth` is the explicit answer to the absorption objection; do not quote or name Wyeth. The cost at λ = 1 cites Paper 1's `prop:versions:shared` and `rem:versions:sharedsize` (C12 / P4). $\MH\asymp$ Hutter's ξ is read as universality only.

**Appendix `app-absorb.tex` (`app:absorb`) — ≈ 3 pp.** Proofs of `thm:absorb:absorption` (all parts), `prop:absorb:pricing` (Sion step), `prop:absorb:price` (AM–GM, coding), `prop:absorb:history`.

## 4. `teacher.tex` — key `teacher` — ≈ 4.5 pp (writer: steep-b) — "The teacher's-mistakes theorem"

**Results.** `rem:teacher:hanni`, `def:teacher:instance`, `lem:teacher:list`, `lem:teacher:floor`, `lem:teacher:coding`, `lem:teacher:twopart`, `thm:teacher:main`, `tab:teacher:numbers`, `rem:teacher:hypotheses`, `cor:teacher:fulltable`, `cor:teacher:sampled`, `ex:teacher:version1`, `prop:teacher:concentration`, `q:teacher:open`.

**Notes.** State Theorem 2 in full (all five parts), then the numbers table, then the hypotheses it relies on. Say "for error rules that are incompressible relative to the model" wherever the theorem is summarised. $\lev(\pi)$, $\Phi_1,\Phi_2$, $\epsilon$. `lem:teacher:sharpfloor` and `lem:teacher:finite` are stated in the appendix only.

**Appendix `app-teacher.tex` (`app:teacher`) — ≈ 6 pp.** Proofs of `lem:teacher:list` (Parseval list decoding for semimeasures), `lem:teacher:floor`, `lem:teacher:sharpfloor`, `lem:teacher:coding`, `lem:teacher:twopart`, `thm:teacher:main` (o)–(iv), `cor:teacher:fulltable` (with its table), `lem:teacher:finite`, `cor:teacher:sampled` (table), `ex:teacher:version1`, `prop:teacher:concentration`; the checks c1, c3, c6(B,C,H), c7(D,F,H) with seeds.

## 5. `limits.tex` — key `limits` — ≈ 3 pp (writer: steep-b) — "Limits of the trick"

**Results.** `prop:limits:plain`, `rem:limits:schedule`, `prop:limits:rateblind`, `lem:limits:robust`, `prop:limits:envelope`, `prop:limits:separable`, `prop:limits:guard`, `prop:limits:noident`, `prop:limits:inputlaw`, `prop:limits:ood`, `rem:limits:method`, `q:limits:open`.

**Notes.** Order: why λ must be Θ(n) (`prop:limits:plain`, `rem:limits:schedule`); which error rules defeat it (`prop:limits:envelope`, then rate blindness); the other pathologies; OOD. `prop:limits:envelope` carries "refutes the extension of Hänni's example to every error rule with his density and description length", and says Hänni called the example cherry-picked. `prop:limits:ood` is the λ > 1 counterpart of Paper 1's `prop:ood:hanni`.

**Appendix `app-limits.tex` (`app:limits`) — ≈ 3.5 pp.** Proofs of `prop:limits:plain`, `lem:limits:robust` (with the $d_0(\kappa)$ table), `prop:limits:separable`, `prop:limits:guard` (numbers), `prop:limits:noident`, `prop:limits:envelope` (with the numbers table), `prop:limits:ood`.

## 6. `split.tex` — key `split` — ≈ 2.5 pp (writer: steep-a) — "The model–randomness split"

**Results.** `def:split:setting`, `lem:split:ville`, `lem:split:stream`, `thm:split:lambda1`, `prop:split:si`, `thm:split:private`, `rem:split:reading`, `thm:split:shared`, `ex:split:noisyparity`, `rem:split:siprograms`.

**Notes.** Quote Hänni ("solomonoff doesn't have a preference here, both get similar posterior"). Theorem 3 covers every computable sampler (Bern(1/3) of H6 included); the hashing lemma is the appendix alternative (P8). `lem:split:stream` adapts Paper 1's tape-length bound (`prop:versions:tape`). Example 3.4 is an illustration, not an instance (P13).

**Appendix `app-split.tex` (`app:split`) — ≈ 3.5 pp.** Proofs of `lem:split:ville`, `lem:split:hash`, `lem:split:stream`, `thm:split:lambda1`, `prop:split:si`, `thm:split:private` (Kakutani-type argument), `thm:split:shared`; checks c4(A–C), c6(E), c7(A).

## 7. `algstat.tex` — key `algstat` — ≈ 2 pp (writer: steep-a) — "Relation to algorithmic statistics"

**Results.** `def:algstat:set`, `prop:algstat:set`, `def:algstat:product`, `prop:algstat:product`, `prop:algstat:coarse`, `prop:algstat:parity`, `rem:algstat:restricted`, `rem:algstat:reading`, `q:algstat:lsc`.

**Notes.** Sufficiency slack $b$, set models $A$, full table $N=2^d$. Keep the refuted reading of Prop 3.5 inside `prop:algstat:set`. The "1 bit paying for 1 bit" remark is Hänni's; quote it.

**Appendix `app-algstat.tex` (`app:algstat`) — ≈ 2 pp.** Proofs of `prop:algstat:coarse`, `prop:algstat:parity` (i)–(iv), with the numbers table of (iv).

## 8. `related.tex` — key `related` — ≈ 1 p (writer: steep-b) — "Computable versions and related work"

**Results.** `prop:related:computable`, `prop:related:computability`, `rem:related:cold`, `rem:related:nn`, `rem:related:mdl`, `rem:related:posteriors`, `rem:related:t5`, `rem:related:new`, `q:related:open`.

**Appendix `app-related.tex` (`app:related`) — ≈ 0.5 p.** Proofs of `prop:related:computable` (inspection) and `prop:related:computability`; the T5 correspondence table (St §6).

## 9. `discussion.tex` — key `discussion` — ≈ 1 p (framing)

What the trick can and cannot do: the shared/private contrast, the window, the price (λ = cn is deliberately inconsistent; $c\ell$ bits per sample), the gap to realistic human errors (envelopes); open problems from the `q:` rows.

## Appendices

Order: `app-setup` (A), `app-absorb` (B), `app-teacher` (C), `app-limits` (D), `app-split` (E), `app-algstat` (F), `app-related` (G), `app-verification` (H). Each starts with `\section{<title>}\label{app:<key>}`.

**`app-verification.tex` (`app:verification`; framing) — ≈ 1.5 pp.** The steeper track's two referee rounds, the checks c1–c7 and the T5 re-run with seeds, the refuted statements (Hänni's overbroad reading; St's own earlier errors; T5's heuristic window), and what is only an illustration (κ = 0 numbers, Example 3.4).

---

## Cross-paper references

* Cite Paper 1 as `\citet{claudeSFI2026fundamentals}` by result name; the list of Paper 1 results Paper 2 uses is in `../paper/OUTLINE.md` "Cross-paper references".
* Paper 1's section `sec:steep` (file `../paper/sections/steeper.tex`, written by steep-a) summarises this paper; keep its numbers identical to this paper's.

## Global cross-reference map (within Paper 2)

setup → (none). absorb → setup. teacher → setup. limits → teacher, setup. split → setup, absorb. algstat → setup, teacher (Lemma 2.1, 2.2, 2.2c, (D1)), absorb. related → all.

## Page budget

| section | file | main pp | appendix pp |
|---|---|---|---|
| intro | intro.tex | 1.5 | — |
| setup | setup.tex / app-setup.tex | 2.5 | 1 |
| absorb | absorb.tex / app-absorb.tex | 3 | 3 |
| teacher | teacher.tex / app-teacher.tex | 4.5 | 6 |
| limits | limits.tex / app-limits.tex | 3 | 3.5 |
| split | split.tex / app-split.tex | 2.5 | 3.5 |
| algstat | algstat.tex / app-algstat.tex | 2 | 2 |
| related | related.tex / app-related.tex | 1 | 0.5 |
| discussion | discussion.tex | 1 | — |
| verification | app-verification.tex | — | 1.5 |
| **total** | | **21** (target 18–22) | **21** (target ≈ 20) |
