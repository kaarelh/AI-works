# front: resolution log

Group files: `paper/sections/abstract.tex`, `intro.tex`, `discussion.tex`, `app-verification.tex`, `paper/preamble.tex`, `paper/main.tex`, and `paper/CLAIMS.md` (ledger sync, rule 11). No other section file was edited. `bib/framing.bib` needed no change. The optional `sections/app-notation.tex` was not added (see F-45).

This log is the front group's changelog in the sense of DECISIONS.md §1 rule 9.

## 1. Issues

| id | sev | status | what changed (file, label) |
|---|---|---|---|
| F-01 | fatal | done | `abstract.tex`: binding text of §8.3 ("in the calculi analysed … except through non-logical weight effects under a selection-aware likelihood: the odds stay at the prior odds, fall by a constant factor per datum, or drop to zero"). `intro.tex`: short-answer items 3–4 (binding §8.2) and A2 ("In every comparison analysed (`thm:univ:B`) … stay at the prior odds (…), lower them by a constant factor per datum (…) or set them to zero (strict citation), up to non-logical weight effects under a selection-aware likelihood with a background (∧-rules: open)"). Discussion §9.1 "Templates": "in the comparisons analysed". |
| F-02 | fatal | done | `tab:intro:verdicts` (now in `app-verification.tex`, `app:ver:process`), row H2: binding text of §10.F1 (verdict and where cells). Recorded as C-02 in the second part of `tab:ver:writing`. |
| F-03 | fatal | done | Intro A5 (time): "for plain L1 only a logarithmic charge is proved, a polynomial one conjectured"; short-answer item 9 (binding): "For the grammar's own code length only a logarithmic charge is proved". Discussion §9.1 "A time penalty": "only a logarithmic charge is proved, and a polynomial one is conjectured (`conj:time:poly`)". The phrase "proved to charge only logarithmically" no longer occurs. |
| F-04 | fatal | done | Discussion §9.1 "Templates": binding text of §10.F3 (citation likelihood, Dirichlet sum, two-step chain exact over a pool, `prop:exp:exact`; general derivation likelihood a computable real with undecidable positivity, `prop:model:compute`). Intro A1 says the same (canonical §9.11). |
| F-05 | major | done | Abstract replaced by the binding text of §8.3 (248 words; fixed weights; theorems, not axioms; the size principle glossed; ω-gap named after its statement). |
| F-06 | major | done | Abstract (binding): "in finite classes the posterior then goes to the best-fitting generator". Intro short-answer item 7 (binding), A6 ("in finite classes … in the full class even this can fail", `thm:ident:kl`), discussion §9.2 "What it cannot promise" ("in finite classes … in the full class even this picture can fail (`rem:ident:fullclass`)"). |
| F-07 | major | done | Abstract: "AI referees checked first versions; no human has checked the mathematics." Intro short-answer item 10 (binding), §1.4 (vi) and §1.5 ("four independently refereed research notes (`app:ver`)"; results added in revision checked only by their authors and the section writers). `app:ver:process` states the same with the complete list (F-08). |
| F-08 | major | done | `app-verification.tex`, `app:ver:process`, "What this means for the reader": "among them are" replaced by one complete itemised list by track, compiled from model §12, universal §15, pa §9, experiments §16, with track numbers and paper labels (all items named in the fix, plus Lemma 1.6 re-proved (`lem:model:grammar`), the exact tightness remark (`rem:sound:tight`), the mechanism of Ex 4.9, Conj 3.7, 6.15, 4.10, the G1 skeleton theory (`ex:pa:skel`), the §3 theorem-data computations, and the paper's own reconciliations and review changes). app-ident, app-pa and app-sound point to this list (done by their groups); checked that their named items are all in it. |
| F-09 | major | done | Intro A7 (side results): "It is guaranteed sound only for well-specified data … Misspecified, there is no guarantee: in an example a waiting prover wins with probability 1; elsewhere the verifier is merely incomplete." |
| F-10 | major | done | Intro A7: "with learned weights, on average over the weight prior and, for likelihoods linear in the weights, with a threshold shrinking in n, otherwise only on average". Discussion §9.2: binding text of §10.F4 ("What it can promise" and the "Output" replacement). |
| F-11 | major | done | Discussion §9.2 "What it can promise": binding text of §10.F4 (with a selection model only Th(T) ∩ S is identified; deductive questions beyond S keep their prior share). |
| F-12 | major | done | Intro short-answer item 9 (binding, with one deviation, §3 below), A3 (templates: "over PA … Σ_n-sound assigners on Σ_n sentences; for merely consistent assigners this is open") and A5 (time: "a fixed polynomial root of its nondeterministic time … at most a polynomial of its deterministic time (proof sketch)"). Discussion §9.1 "Templates" and "A time penalty" likewise. "between its nondeterministic and deterministic time" no longer occurs. |
| F-13 | major | done | Intro A3 (templates) carries the canonical MDL wording of §9.3: tie at matched weights, Occam terms with learned weights, linear split win when the instantiation grammar misfits the usage; "the posterior tracks usage, not the logical boundary of a schema (`rem:ident:mdl`)". |
| F-14 | major | done | `tab:intro:verdicts` row H7: binding text of §10.F1. |
| F-15 | major | done, modified | Discussion §9.2 "What it cannot promise": binding text of §10.F5 with one added hypothesis, "when $T^*$ refutes $\sigma$" (§3 below). |
| F-16 | major | done | `tab:ver:corrections`: model "weakened" row gains m5 (c9 tautological; c9b); pa "weakened" row gains m10 (toy tower) and the accepted part of m11 (Rem 5.4, `rem:pa:overlap`); experiments "weakened" row now covers m1–m14 (adds m1, m3, m9, m13, m14 with the E5(a2) slope −0.259 → −0.251 ± 0.002). pa rows use final numbers with the old ones in parentheses ("Prop 4.6(c) (old 3.5(c)), F8; M4"; "§5.5 (old §4.5)"). The intro sentence says which refuted claims stay in the main text. `tab:ver:writing` gains a second part, "after the review of the paper", one line per statement-changing correction with the reviewers' ids (all of §10: C-01…C-15, R-20, MA-01…MA-09, MB-01…MB-09, C1…C15, C21, C37) and a closing row naming the remaining precision and wording fixes. |
| F-16b | major | done | `tab:ver:conflicts`: new last row "review C-16" (Σ1-completeness of Q restricted to <-free sentences; Acc_f, Rej_f written without <; pointers to `sec:model:syntax`, `sec:time:schema`, `prop:time:twosorted`). The conflicts paragraph says the review found one more conflict. |
| F-17 | major | done | Intro: binding short answer of §8.2 in a framed box (`framed` package, breakable) directly after the verbatim question; framing sentence; §1.1 "Hänni's note" cut to one short paragraph with no long quotations (pointers to §2.6, §2.7, §6, §9.3). One deviation in item 9 (§3 below). Each item carries at most one `\cref`. |
| F-18 | major | done | Intro §1.3 answers reordered as §8.1 item 6: A1 version; A2 ∀xφ (old A2 and A3 merged); A3 templates (new); A4 derivation-length prior; A5 time penalty; A6 his last bullet with the binding 3×2 table (`\crefabbrev`; a breakable `longtable`, no caption and no new label); A7 side results (verifier, trichotomy). |
| F-19 | major | done | The generator-view numbers (77% of $\{\forall x\varphi\}$'s output is $\forall x\varphi$; factor 0.23 per instance at c = 0.3) are in short-answer item 4 (binding text). A2 states the factor regime and points to `thm:univ:B`; the numbers are not repeated there, for length. |
| F-20 | major | done | `tab:intro:verdicts` moved to `app-verification.tex` (`app:ver:process`, after the paragraph that introduces the brief), label unchanged, cell fixes F-02, F-14, F-33, F-34, `\crefabbrev`. Intro §1.5: one sentence with a pointer. No "the brief's H…" phrase remains in intro or discussion. |
| F-21 | major | done | No undefined symbols in the intro: $C_{\min}$, L1^sel, L1^sel_cit, L1^σ, "closure reading", "guard", "hard assigner" are replaced by words or glossed; $\Lzero$, $\Lone$, "parameters admissible", "instance union", $T^*$, the prior π, generator class $\Cstar$, $C^*_d$, root split, assigner, $\Q+\TInd$ and ω-gap are defined where first used. The blanket sentence ("Each answer holds within the hypotheses …") is deleted; each answer carries its hypothesis. At most two `\cref`s per answer (the binding table excepted). |
| F-22 | major | done | Intro A1 gives the good version in two lines with a pointer to `sec:disc:good`; `sec:disc:good` is the single full statement (with F-10, F-11, F-15). |
| F-23 | major | done | Intro A7 opens with the definition of the verifier ("The posterior, used as a proof checker, accepts a sentence when theories deriving it carry at least 1−δ of the mass") and sits among the side results. |
| F-24 | major | done | Intro A4: "under a two-part code, on a computed stream of six library theorems, Q plus the theorems, strictly weaker than PA, beats Q + T_Ind within the candidates scored (`rem:pa:streams`)"; the generator wins on data from its own derivation process under the full-sum likelihood or on direct uses of its schemas. |
| F-25 | major | partly done | `main.tex`: `\setcounter{tocdepth}{1}`; the contents take p. 1–2 and the main text starts on p. 3. Intro 4.00 pp (target 3.5, cap 3.75); discussion 2.76 pp (target 2.5, cap 2.75); main text 41.42 pp (cap 41.5). Over cap: the intro by 0.25 pp, because the binding short answer alone takes about one page (the plan of §2 assumed +0.45 pp); everything else in the intro was cut to the decided minimum (see §4). |
| F-26 | major | done | Intro §1.1 has no long quotation (two short phrases: "do not contradict the given statements", "a p(true/false/independent)"); his collapse schema is described in words. Discussion §9.3 quotes only short phrases ("easy", "only a very small subset of observations", "making some mistakes"). |
| F-27 | major | done | Discussion: §9.1 cut to three short interpretive paragraphs; §9.2 the single statement of the good version; §9.3 point by point without long quotes; §9.4 trimmed (about 30%); §9.5 condensed to one paragraph of the main open problems, with C-37's additions; the remaining open items moved to `app:ver:open` item (9) (no item dropped). 2.76 pp. |
| F-28 | major | done | `preamble.tex`: binding code of §7 (`\emergencystretch`, upright `\status`, breakable `\src`, no-op `\identbrk`/`\pabrk`/`\expbrk`, `\crefabbrev`, citation aliases in `\AtBeginDocument`), as in `scratch/r_preamble_fix.diff`. Intro §1.5: "as a small grey note". Full build: 0 overfull boxes above 10 pt (one of 0.57 pt). |
| F-29 | major | done | `tab:ver:corrections`: every row points to where the item now lives (`rem:model:subcrit` and the r6 numbers in App A, `app:model:size`; `rem:sound:hyp` with `app:sound:fixed`; `rem:exp:refuted`, `app:exp:results`; `rem:pa:sdpcrefuted` replaces the pointer to `prop:pa:occam` alone; `tab:pa:merge` cited). The m3 row carries the r6 qualifier of §10.M8. |
| F-30 | major | done | No "track X's …", "the brief's H…", "referee m…" or "first version" in the running text of intro or discussion. Intro §1.5: "The results come from four independently refereed research notes (`app:ver`)." |
| F-31 | major | done | Glosses at first use in the intro: generator class, ω-gap ("all closed instances together do not entail ∀xφ"), root split, assigner, \DTRC (§6.3 wording), instance union, parameters admissible. "Spare template", "motive" and "anchor" no longer occur in intro or abstract (the spare-template sentence of A6 was cut for length; the term is glossed at first use in ident.tex). Gold's languages: the verdict table uses no L_k; `prop:pa:isigma`'s $\mathcal L_\infty$ is used in `tab:ver:corrections`. |
| F-32 | minor | not done | The optional addition "when the data are drawn from the model" would make the abstract 256 words (> 250). The intro (short-answer item 5, A2) carries the qualifier. |
| F-33 | minor | done | `tab:intro:verdicts` H4(a) where cell: `\cref{thm:univ:size,prop:univ:memo}`. |
| F-34 | minor | done | H5: "spares cost ≈ ½ log₂ n bits with Dirichlet(½) weights"; H4(a): memorisation refuted "(Laplace weights, geometric numerals)". The intro has no bare log; the memoriser rate is not repeated in the intro (cut for length). |
| F-35 | minor | done | Intro §1.4 (iii) lists the over-Q limits of the split–memoriser races and the memoriser rate, with a pointer to `app:ver:sketches`. |
| F-36 | minor | done | Discussion §9.3: mistakes are harmless for the general results if they are a noise component or corruption channel of the well-specified generator (`prop:univ:robust`, `rem:ident:nearmiss`); "modelled as axioms, as in E4(C1), they are accepted as theorems (`rem:sound:e4`)". |
| F-37 | minor | done | `app:ver:sketches`: added the heavy-tail nesting conjecture of E3(a), the heuristic waiting times after `prop:ident:gold`, the eventual-behaviour sketch of `ex:pa:euler`, the waiting time of `rem:ident:sparetotal`; mirrored §11: `rem:sound:indep` (sketch for schema-generated ψ), `rem:time:upper` (not established for ρ_{f,n}), the Dirichlet part of `prop:pa:wellspec`, `prop:exp:exact`(d) (computed, not proved, for data-derived theories at J = 2). `app:ver:open` (4), (6), (7), (8) mirror `prop:ident:spare`(c), `rem:sound:vacuous`, `rem:ident:nearmiss`, `prop:time:notemplate` (mixed templates), the merely-consistent case of `prop:time:collapse`, `rem:pa:pointwise`, and the (d3) hypothesis; (3) adds `prop:univ:open`(d) for countable classes. |
| F-38 | minor | done | `app:ver:refs`: doob1949application, krichevsky1981performance and rylln1952axiomatizability added, each with what was checked (from the bib comments and pa §9.2). |
| F-39 | minor | done | Discussion §9.5: equal laws ⇒ equivalence for single DT° templates (`prop:ident:splits`(c)); for which assigners a Craig set, or an equivalent set with polynomial membership, is a finite union of DT° templates; `prop:univ:open`(d) for countable classes with learned-weight provers; whether templates block the collapse for merely consistent assigners. |
| F-40 | minor | done | Contributions paragraph deleted; "What is not achieved" (`sec:intro:contrib`, label kept) directly after the answers; reader's guide one clause per section inside `sec:intro:guide`. |
| F-41 | minor | done | The verdict table is in App H with `\crefabbrev`; the intro has no float. The 3×2 table is an in-text breakable longtable with `\crefabbrev`. |
| F-42 | minor | done | `preamble.tex`: `\defcitealias` for AS and IL in `\AtBeginDocument`. `main.tex` title footnote: `\citetalias{…} \citep{…}`. Intro §1.2 first mention: "AS \citep{claude2026axiomschemas}, on axiom schemas, and IL \citep{claude2026whatfollows}, on inferential learning". |
| F-43 | minor | done | Framing sentence in the intro after the short answer ("This paper checks an idea within a precise model; it does not design a prover.") and in the discussion's closing paragraph only. |
| F-44 | minor | done | App H keeps each refuted item once (`tab:ver:corrections`), receives `tab:intro:verdicts`, points to the other appendices. App H is 12 pp (pp. 116–127; was 10). The appendices as a whole are 81 pp (pp. 47–127) against the cap of 66: see §4. |
| F-45 | minor | not done | Optional notation table not added: the appendices already exceed their cap (§4). |
| F-46 | minor | done | `paper/CLAIMS.md` synced (§5 below). |

## 2. Labels

* Moved: `tab:intro:verdicts` from `intro.tex` to `app-verification.tex` (`app:ver:process`). Checked with `grep -n 'tab:intro:verdicts[},]' sections/*.tex`: cited from `intro.tex` §1.5 and `app:ver:process`; no "below" wording.
* Added: none. The 3×2 table of the intro has no caption and no label (only the labels of §13 may be created).
* Deleted or renamed: none. All labels of the four front files are kept: `sec:intro`, `sec:intro:note`, `sec:intro:reading`, `sec:intro:answers`, `sec:intro:contrib`, `sec:intro:guide`, `sec:disc`, `sec:disc:proposal`, `sec:disc:good`, `sec:disc:hanni`, `sec:disc:lit`, `sec:disc:open`, `app:ver` and its eight subsection labels, `tab:ver:corrections`, `tab:ver:writing`, `tab:ver:conflicts`.

## 3. Deviations from binding text, with reasons

1. **Short answer, item 9 (§8.2).** "Templates block your schema" became "Templates block the acceptance half of your schema". `prop:time:notemplate` is proved for the acceptance part $C_f$ only, and time.tex says the rejection part and mixed templates are not treated (univ-time U-27, MB-18). Without the qualifier the item would claim more than the section.
2. **Short answer, item references.** Each item carries at most one `\cref`, as allowed; item 4 carries none (layout).
3. **§10.F5.** "With learned weights it removes a false spare sentence σ, and with it the inconsistent theory T* ∪ {σ}" now reads "…, and with it, when T* refutes σ, the inconsistent theory T* ∪ {σ}". A false σ makes T* ∪ {σ} inconsistent only when T* refutes σ (`rem:ident:sparetotal`; the writers' note in `tab:ver:writing`, ident row).
4. **§8.3 (abstract).** The optional C-18 addition is not made: it would exceed 250 words.
5. **§8.1 structure.** The decided answer list "∀xφ (A2, A3)" and "side results" are each one item (A2, A7); the intro has seven answers. The good version is stated in A1 in two lines. The 3×2 table is placed inside A6 as a breakable longtable rather than a float, so that it stays with its answer.
6. **Discussion §9.5.** The open problems are one paragraph of the main ones; the remaining items moved to `app:ver:open` item (9), so that no open problem is lost and §9 fits its cap.

## 4. Page spans (full build, `flock … ./build.sh`, measured from heading positions in `main.pdf` as in DECISIONS §2)

| section | target | cap | now |
|---|---|---|---|
| 1 intro | 3.5 | 3.75 | **4.00** (pp. 3.00–7.00) |
| 2 model | 5.5 | 5.75 | 5.55 |
| 3 universal | 6.25 | 6.5 | 6.45 |
| 4 ident | 5.0 | 5.25 | 5.16 |
| 5 sound | 3.5 | 3.75 | 3.61 |
| 6 time | 4.5 | 4.75 | 4.57 |
| 7 pa | 6.5 | 6.75 | 6.66 |
| 8 experiments | 2.75 | 3.0 | 2.65 |
| 9 discussion | 2.5 | 2.75 | **2.76** |
| main text | 40.0 | 41.5 | **41.42** |

* Front matter: contents on pp. 1–2 (tocdepth 1); the main text starts on p. 3.
* Intro: the question (verbatim, footnotesize) and the binding short answer (small, framed) take pp. 3–4.3, about 1.3 pp; the plan assumed +0.45 pp for the box. The rest of the intro (§1.1–§1.5 with the 3×2 table) is about 2.7 pp. Cutting below 4.00 would need dropping decided content (the table, the answers, or §1.4–§1.5).
* Discussion: 0.01 pp over its cap (about half a line); the main text is within the hard cap.
* Appendices: pp. 47–127 = 81 pp against the cap of 66 (App A 8, B 12, C 11, D 6, E 7, F 13, G 12, H 12). The overrun comes from the moves of §3 into the appendices of all groups; App H grew by 2 pp (the verdict table and the review rows of `tab:ver:writing`).
* Pages in all: 127.

## 5. CLAIMS.md sync (rule 11)

See the note at the top of `paper/CLAIMS.md`. Changed: the section column of every item now stated in an appendix ("app A" … "app H") or in another main section (the trichotomy items: "model (§2.7) / app A"; `prop:exp:comm`: "pa / app G"; `tab:univ:c2`: "univ"); the statements of §10 (M1–M9, U1–U9, P1–P14, F1–F5) and the other statement changes listed in the three group logs; the statuses of §11 and the logs; a new conflict entry for the review's C-16; the "Answers to the question" section, rewritten to the structure and canonical wordings of the revised intro.

## 6. Builds

* `flock /tmp/claude-0/paper-build-ai.lock ./build.sh`: 0 LaTeX errors, 0 undefined references, 0 undefined citations, 0 multiply defined labels, 0 overfull boxes above 10 pt; 127 pages. Remaining warnings: one font-shape substitution (T1/lmr/bx/sc, from `\DTRC` in bold context), one overfull box of 0.57 pt, one underfull box.
* `./test-section.sh intro`, `./test-section.sh discussion app-verification`, `./test-section.sh abstract`: compile (5, 18 and 1 pp); all undefined references are cross-section.
