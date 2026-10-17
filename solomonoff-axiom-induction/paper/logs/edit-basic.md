# Edit log, group basic (setting.tex, basic.tex, app-basic.tex)

Phase 1 started 2026-10-17. Inputs: review/DECISIONS.md, review/issues-basic.json (11 issues).

Status: PHASE 1 DONE (2026-10-17). All 11 issues applied; isolated builds compile; greps of rule 0.8 clean.

## Plan (order of work)

1. setting.tex: BAS-01, BAS-02, BAS-03 (def part), BAS-04, BAS-X19; moves of BAS-L1 list A (1)-(5).
2. app-basic.tex: receive the setting moves (app:setting, app:basic:cr, app:basic:generative); BAS-03 (remark), BAS-06, BAS-07, BAS-08, BAS-X19.
3. basic.tex: BAS-05 with BAS-L2 list A (1)-(8); BAS-X19; app-basic receives the statements.
4. Isolated builds, page counts, list B if over target, greps of rule 0.8.

Baseline (isolated builds of 2026-10-17, before edits): §2 setting 4.52 pp., §3 basic 7.00 pp. (full build: 4.66 and 6.91).

## Issues

* **BAS-01** (done). `setting.tex`, `rem:setting:defects`, last sentence: "the pair $(\Bel_D,\Pl_D)$ is a coherent lower and upper probability" replaced by "keeping it, there is a probability on the complete consistent extensions of $B$ that lies between $\Bel_D$ and $\Pl_D$ (\cref{prop:basic:geometric}(c))". No envelope argument added.
* **BAS-02** (done). `setting.tex`, `def:setting:fresh`: "a constant $\mathtt e$, unary function symbols $\mathtt s_0,\mathtt s_1$, and the unary relation symbol $R$".
* **BAS-03** (done). `setting.tex`, `def:setting:versions`, bullet of $\WAgen t$: added "and $K_A^{\mathrm{gen},t}(D)$, the least length of such an enumerator compatible with $D$" (no macro in the preamble; written in full). `app-basic.tex`, `rem:setting:versions`(b) (moved there, see below): "and $\lvert\KA(D)-K_A^{\mathrm{gen},t}(D)\rvert\le c$"; its proof names the same inequality at the start of the Kolmogorov part.
* **BAS-04** (done). `setting.tex`, paragraph "Algorithmic notation": added the definitions of $\Omtail{\ell}$ (tail of $\Omega_V$, tends to $0$) and $\Kpad(n):=\min_{n'\ge n}K(n')$ (nondecreasing, unbounded), as decided (matches fundamentals Prop 1.8(d)). Front group: FRO-20 pointers in app-notation.
* **BAS-L1** (done; see page counts). List A:
  1. `rem:setting:versions` moved to App A, `app:setting`, before its proof (statement unchanged except BAS-03). The paragraph after it was dropped: its content is in the proof (Craig's trick, Lemma E.12 under (S)) and in the new main-text sentence. Main text after `def:setting:versions`: the decided sentence, with "of the earlier report" added after "self-simulation assumption" and the \cref in parentheses.
  2. Examples (i)-(iv) moved to App A, `app:setting`, as `\paragraph{Examples of theory machines.}\label{par:setting:examples}` (with `\status{definition}\src{fundamentals \S1, Examples after Lemma 1.3}`). §2 keeps the measurability sentence (now ending "; examples are in \cref{par:setting:examples}") and the randomised-theories sentence ("More generally" dropped). `thm:basic:dominance`(iv) and its proof point to `par:setting:examples`.
  3. `def:setting:variants` keeps $\epsempty$ and the consistency-requiring weight (now in prose, no itemize), followed by the decided sentence. New `def:setting:graded` (start of `app:basic:cr`, with the $S_g$ paragraph after it) and `def:setting:generative` (start of `app:basic:generative`; merges the bullet with the former first paragraph there, which stated the same definition in detail). Grep for `def:setting:variants`, `MAhalf`, `\Xi`: only `basic.tex` (fixed there) and `app-notation.tex` (front, FRO-20) needed updates.
  4. The two last sentences of `def:setting:complexities` moved to App A, `app:setting`, as `rem:setting:complexities` (new label; `\status{proved}\src{fundamentals Def 1.9}`); the definition keeps the four objects and points to the remark; its status is now `definition`.
  5. "An r.e. background would serve as well" cut to its first sentence. First paragraph of §2 cut (the core is under 400 bytes; one sentence added for DECISIONS §U7, which asks setting.tex to introduce all three names of the companion works). Paragraph after `def:setting:questions` cut to its first and last sentences; the two middle sentences (E3 is not one datum of $\MAthree$; the two-valued encoding is degenerate) moved to App A as `\paragraph{The encoding \Ethree.}\label{par:setting:E3}`, with a pointer from §2.
  List B (applied, §2 was still over 3.75 in the isolated build): (1) "If $\omega=p\omega'$" paragraph shortened to two sentences; (2) the correspondence sentence of `rem:setting:defects` moved to App A, `app:setting`, as `\paragraph{The two defects and function machines.}\label{par:setting:defects}`, with a parenthetical pointer in the remark. Further prose cuts: the intro sentence of §2.4 moved into `def:setting:versions`; the intro of §2.5 cut to one sentence; one sentence of the intro of §2.2 merged.
* **BAS-05** (done, merged with BAS-L2 item 6). `basic.tex`, paragraph after `thm:basic:dominance`: the lead-in "Neither the universal machine nor the background matters beyond a constant factor:" replaced by the decided sentence "The universal machine matters only up to a constant factor (\cref{prop:basic:invariance}), and building a background $B'$ into $B$ gains at most $K(B')+c$ bits on any data, while the converse fails (\cref{prop:basic:background})." Both propositions moved to App A (below).
* **BAS-06** (done). `app-basic.tex`, paragraph before `prop:basic:wholetheory`: "The bounds of \cref{thm:basic:loss} are stated with $\Keq(T)$, the least complexity of an index of a theory equivalent to $T$ (\cref{def:setting:complexities}); for whole theories the question is how $\Keq$ compares with the mixture weight $\mmeq$." Light copy-edit of the decided text: "the length of a shortest index" became "the least complexity of an index", which is the definition of $\Keq$ ($\min_{e\in[T]}K(e)$); the decided wording would have described a different quantity.
* **BAS-07** (done). `app-basic.tex`, proof of `prop:basic:crorder`(b): the sentence "Write $\zeta_{i,j}$ for the sentence $e_{i,j}$ of the statement, ... (this avoids a clash with indices $e$)." deleted. The statement (moved to App A) keeps its notation $\zeta_{i,j}$, $b_{i,j}$.
* **BAS-08** (done). `app-basic.tex`, paragraph after `prop:basic:demski`: the clause "the processes are computable relative to $\emptyset'$, since ... (a single draw of Process 2 can output one sentence)" replaced by the decided three sentences (Process 1 computable relative to $\emptyset'$; Process 2 needs a consistency test $\Pi^0_1$ in the tapes; neither is computable).
* **BAS-X19** (done, all three files; DECISIONS §U7). `setting.tex`: see above. `basic.tex`: first mentions "the companion paper \citep{claudeSFI2026fundamentals}" (§3.1, "Recall from ...") and "our earlier report \citep{claude2026axiominduction}" (after `prop:basic:geometric`); all later mentions "Theorem 3.8 of the companion paper", "Proposition 2.22(b) of the earlier report" etc., possessive forms ("the companion paper's Theorem 4.9") rewritten in that style. `app-basic.tex`: first mentions "our earlier report \citep{...}" (proof of `rem:setting:versions`) and "Corollary 5.4 of the companion paper \citep{...}" (proof of `prop:basic:mistakes`); 16 later mentions rewritten without citation commands (no `\citet{claude2026axiominduction}`, `\citealp{...}` or possessive form remains in the three files). Item numbers unchanged.
* **BAS-L2** (done; see page counts). List A:
  1. `prop:basic:exceptions` moved to App A, `app:basic:loss`, before its proof (now a plain proof). Follow-up: its first sentence is the main-text summary; the second ("\cref{sec:laws} extends (c) ...") kept in App A after the statement. Main text: the decided sentence.
  2. `prop:basic:mistakes` moved to App A, `app:basic:loss`, before the proof of (a), (b) (now "Proof of (a) and (b)"). Follow-up: the halving/Kraft sentence dropped (it repeats the proof); "The bound of (b) is essentially attained ... not the prior" kept in App A; the lead-in to the merging theorem dropped. Main text: the decided sentence, with the two predictors named ("Bayes predictor", "Kolmogorov predictor", each defined in one clause, since §3.8 uses both names) and "under a well-order that refines length" written "when the order refines length".
  3. `thm:basic:merging` and `cor:basic:threeloss` moved to App A, `app:basic:loss`, each before its proof (plain proofs). Follow-up of the theorem: the proof-idea sentence dropped (it repeats Steps 1-2 of the proof); the two-valued caveat kept in App A after the statement. Main text: the decided sentence, with "with $B\cup T$ consistent" added (hypothesis of the corollary).
  4. `prop:basic:lower` moved with its proof to App A, `app:basic:coding`, after the proof of `prop:basic:chain`; `prop:basic:chain`(b) now ends "(also \cref{prop:basic:lower})".
  5. `prop:basic:crorder` moved to App A, `app:basic:cr`, before its proof (plain proof); its follow-up (stream of fresh atoms; stronger datum first) kept after the statement. Main text: the decided sentence appended to the sentence on Dempster's rule after `prop:basic:cr`, with "on suitable data of fresh atoms" (the order gap is an existence statement in the literal setting).
  6. `prop:basic:invariance` and `prop:basic:background` moved to App A, `app:basic:dominance`, each before its proof (plain proofs). Main text: BAS-05 sentence. The sentence "So building knowledge into the background gains ..." dropped (now in that sentence); the proof-idea sentence on cylinders dropped (it is in the proof of `thm:basic:dominance`).
  7. Graded-weight paragraph cut to two sentences (weak semimeasure, $\MAhalf\ge\MA$, entailed data charged, so the law of no theory machine, packaging not induction, \cref{prop:basic:graded,prop:basic:gradedgap}; Möbius sum $-\frac12$ against $+1$, negative when $B$ does not decide $\varphi$, not a containment functional, and the mixture form, \cref{prop:basic:crmix}), plus the short lead-in to `prop:basic:prcr`. $\MAhalf$ is introduced with a pointer to `def:setting:graded`.
  8. Paragraph after `thm:basic:inc`: about 610 bytes (construction in one sentence; novelty sentence; $\emptyset'$/lsc sentence with the attribution to Propositions 3.7 and A.10 of the companion paper); the Kučera/Calude and Becher/Barmpalias sentences moved to App A after the proof of `thm:basic:inc`; the citation for $\le_S$ is in the proof there. §3.7: one paragraph, about 910 bytes (the strict-extension example and the uniform convergence of beliefs are left to `prop:basic:limits`). §3.8: about 640 bytes including the definition of $\Theta$ and $\beta$ needed by `q:basic:domination` (the gap of `thm:basic:order` is stated as "a number of bits linear in $n$", its constant being in the theorem); the question and its follow-up kept. Paragraphs after `prop:basic:geometric` (680 to about 430), `thm:basic:dominance` (600 to about 330 plus the BAS-05 sentence), `cor:basic:vocabulary` (660 to about 330) and `thm:basic:nocoding` (780 to about 480; the pointer to `cor:soi:transfer` dropped, it is in §4) shortened.
  List B (applied, §3 was 5.0 pp. after list A): (1) `prop:basic:dempster` moved to App A, `app:basic:structure`, before its proof (plain proof); main text "Consistency-requiring updating is Dempster's rule of conditioning \citep{dempster1967upper,shafer1976mathematical} (\cref{prop:basic:dempster})." followed by the contrast of the two rules (kept; $\psi$ written $\psi_D$). (2) `prop:basic:form` moved with its proof to the start of App A, `app:basic:computability`; its content is summarised in the first sentence of §3.2. Further prose cuts: the section's first paragraph to one sentence; the proof-idea sentences after `prop:basic:structure` and before `thm:basic:nocoding` (both in the proofs); the "In short" sentence of §3.6 (the Demski sentence kept); the paragraph after `thm:basic:loss` by one clause.
* **BAS-X19, setting.tex** (done). First paragraph introduces "the companion paper \citep{claudeSFI2026fundamentals}", "the companion paper on steeper priors \citep{claudeSFI2026steeper}" and "our earlier report \citep{claude2026axiominduction}". Every later `\citet{claude2026axiominduction}` in setting.tex is now "... of the earlier report" without a citation command.

## Moved labels (main text to App A; statement with label, \status and \src before its proof)

| label | from | to |
|---|---|---|
| `rem:setting:versions` | §2.4 (`setting.tex`) | `app:setting` |
| `rem:setting:complexities` (new; the inequalities of `def:setting:complexities`) | §2.4 | `app:setting` |
| `par:setting:examples` (new paragraph label; Examples (i)-(iv)) | §2.2 | `app:setting` |
| `par:setting:defects` (new paragraph label; correspondence sentence of `rem:setting:defects`) | §2.3 | `app:setting` |
| `par:setting:E3` (new paragraph label; two sentences on \Ethree) | §2.5 | `app:setting` |
| `def:setting:graded` (new; graded bullet and the $S_g$ paragraph) | §2.5 (`def:setting:variants`) | start of `app:basic:cr` |
| `def:setting:generative` (new; generative bullet, merged with the definition already in App A) | §2.5 (`def:setting:variants`) | start of `app:basic:generative` |
| `prop:basic:dempster` | §3.1 (`basic.tex`) | `app:basic:structure` |
| `prop:basic:form` (with its proof) | §3.2 | start of `app:basic:computability` |
| `prop:basic:invariance`, `prop:basic:background` | §3.3 | `app:basic:dominance` |
| `prop:basic:exceptions`, `prop:basic:mistakes`, `thm:basic:merging`, `cor:basic:threeloss` | §3.4 | `app:basic:loss` |
| `prop:basic:lower` (with its proof) | §3.4 | `app:basic:coding`, after the proof of `prop:basic:chain` |
| `prop:basic:crorder` | §3.6 | `app:basic:cr` |

No label was renamed or removed; no theorem-like environment was dropped. Labels checked with `grep -rn` across `sections/`: the citing places in other files (`app-logic` for `rem:setting:versions`(c), `logic` for `prop:basic:lower`, `limits` for `prop:basic:background`, `app-soi` for `prop:basic:form`, `intro` for `prop:basic:dempster`, `related` for `def:setting:variants`) still read correctly. A combined build of `setting`, `basic` and `app-basic` has no undefined reference among the labels of this group and no multiply defined label.

## Shortened labelled paragraphs

None in this group's files (no labelled paragraph existed in them); three labelled paragraphs were added in App A (above).

## Page counts (measured as in DECISIONS §L1, from the heading to the next heading, pdftotext -layout)

| | before | isolated build (`./test-section.sh`) | combined build (§2, §3 and App A together, refs between them resolved) | target |
|---|---|---|---|---|
| §2 `setting.tex` | 4.52 (full build 4.66) | 3.83 | 3.80 | 3.75 (+0.25) |
| §3 `basic.tex` | 7.00 (full build 6.91) | 4.44 | 4.54 | 4.50 (+0.25) |
| App A `app-basic.tex` | about 21 | 22.3 | 22.5 | not capped |

Both sections are within +0.25 page of their targets; list B of both was applied. Source size: `setting.tex` about 17.4 kB, `basic.tex` about 21.5 kB of text (headers excluded).

## Requests to other groups

* **front (FRO-20, app-notation):** $\MAhalf$ is now defined in `def:setting:graded` and $\Xi$ in `def:setting:generative` (both in App A; the row "$\MAnc$, $\Belnc_D$, $\Disnc_D$; $\MAhalf$; $\Xi$" points to `def:setting:variants`, which now defines only $\epsempty$, $\MAnc$, $\Belnc_D$, $\Disnc_D$). $K_A^{\mathrm{gen},t}$ is defined in `def:setting:versions` (no macro; written in full). $\Omtail{\ell}$ and $\Kpad$ are defined in `sec:setting:data` ("Algorithmic notation"). The inequalities between $\Keq$, $\mmeq$, $\mm(\Exts T)$ and the class probabilities are in `rem:setting:complexities`.
* **front (app-verification status table):** `def:setting:complexities` now has status `definition`; new labels with statuses: `rem:setting:complexities` (proved), `def:setting:graded`, `def:setting:generative` (definition), `par:setting:examples`, `par:setting:E3` (definition), `par:setting:defects` (proved).
* **logic (and front, to verify):** `app-logic.tex`, proof using $\UA(\Exts T)\ge2^{-c}\mm(\Exts T)$ (the "Left:" step, line about 292): the `\cref{def:setting:complexities}` there pointed to a sentence that moved; I changed it to `\cref{rem:setting:complexities}` (the only edit outside this group's files, allowed as the repair of a `\cref` target my move broke). Please keep it if you rewrite that line.
* **limits (U6):** `prop:basic:invariance` and `prop:basic:background` are now Propositions in App A; the `\cref`s print "Proposition A.x"; no wording in `limits.tex` or `related.tex` depends on their being in §3.
