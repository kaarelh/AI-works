**P1-ARX-01** [fatal] `paper/sections/intro.tex` — line 19 (contributions, "History-aware prediction") and line 26 ("Corrections to earlier claims")

- *Problem.* The introduction states that the dominance theorem for computable reveal laws (the notes' 'Thm 1') 'is true in the reading his text supports, under finiteness hypotheses' and 'holds in its intended reading'. The body proves it only with an extra K(n)+K(A) term for random reveal laws, and whether that term can be removed is listed as open. The introduction therefore claims more than the body and the ledger.
- *Evidence.* cor:hist:thm1(a): E LSFI <= E L_P + K(P) + K(Delta_f) + K(n) + K(A) + c under (A1),(A2); text after it: 'So Thm 1 is true in Hänni's reading, with an extra K(n)+K(A) for random reveal laws'; rem:hist:thm1open(i) and the Discussion's open problem 'Can the K(n)+K(A) term of cor:hist:thm1 be removed'; CLAIMS.md §3 R2: 'true under stated hypotheses, with K(n)+K(A)'. The H3 row of tab:intro:verdicts (same page) does carry 'with K(n)+K(A)', so the introduction is also internally inconsistent.
- *Fix.* intro.tex:19, replace the sentence by: "For computable reveal laws, the dominance theorem of [Hän26] holds in the reading its text supports: exactly and on every path for deterministic computable reveal orders, and in expectation, with an additional K(n)+K(A) term, for randomised reveal laws under finiteness assumptions; the original proof sketch fails, and a stronger (oracle) reading is false (Prop. 5.8, Cor. 5.14, Thm 5.12)." intro.tex:26: "... the theorem holds in its intended reading up to an additional K(n)+K(A) term for randomised reveal laws (Cor. 5.14)".

**P1-ARX-02** [major] `paper/sections/abstract.tex` — line 3, sentence "A dominance theorem for computable reveal orders holds in its intended reading, though an earlier proof sketch fails."

- *Problem.* Ambiguous and, for the reading a reader will take, stronger than the body: 'reveal orders' suggests deterministic orders (for which cor:hist:thm1(b) holds exactly), but 'intended reading' and 'earlier proof sketch' refer to randomised reveal laws, where the bound carries K(n)+K(A) and needs (A1),(A2). 'An earlier proof sketch' also refers to unpublished notes the arXiv reader cannot place; whose theorem it is is not said.
- *Evidence.* cor:hist:thm1(a),(b); prop:hist:sketchfails; the abstract never mentions the notes or the extra terms.
- *Fix.* Replace by: "For deterministic computable reveal orders a dominance theorem holds on every path; for randomised reveal laws it holds in expectation up to an additional K(n)+K(A) term, while a natural simulation proof fails and an oracle version is false."

**P1-ARX-03** [major] `paper/sections/intro.tex` — line 20 (contributions, "Worked examples"): "In Sam Eisenstat's coin example SFI pays H(1/3)/2 n ± O(log n) bits"

- *Problem.* Missing 'in expectation'. Pathwise the body proves |LSFI - UB_n| <= log n + O(log log n) + c_b, and UB_n itself fluctuates by Theta(sqrt n) around H(1/3)n/2, so the unqualified ± O(log n) is false pathwise. The same sentence says 'SI pays ... in expectation', which invites the pathwise reading for SFI.
- *Evidence.* thm:ex:expected (expectation, ± log n + 2 log log n + c); thm:ex:sandwich (pathwise, relative to UB_n); prop:ex:asymp: (UB_n - H(1/3)n/2)/sqrt n -> N(0, 1.0497). The H6 row of tab:intro:verdicts ('Confirmed up to O(log n)', citing the pathwise sandwich) has the same problem.
- *Fix.* "... SFI's expected loss is H(1/3)n/2 ± O(log n) bits (and almost surely within log n + O(log log n) of the threshold loss UB_n) in the semimeasure convention ..."

**P1-ARX-04** [major] `paper/sections/abstract.tex; paper/sections/intro.tex` — abstract line 3 ("Solomonoff induction on the interleaved sequence pays O(1) in expectation"); intro.tex line 20

- *Problem.* Missing hypothesis: the O(1) bound for SI on the cyclic permutation holds for the self-delimiting block code bar s = 1^|s| 0 s fixed in the body; with raw d-bit blocks the proved bound is K(d)+c and the conjectured order is K(d).
- *Evidence.* prop:ex:cycsi (prefix code), prop:ex:cycraw (raw blocks, K(d)+c), conj:ex:raw (order K(d)); examples.tex:100 'With raw d-bit blocks the bound becomes K(d)+c ... probably the right order'.
- *Fix.* Abstract: "... while Solomonoff induction on the interleaved sequence, with a self-delimiting encoding of the pairs, pays O(1) in expectation." Intro line 20: add "(with the self-delimiting code of Section 5.5)".

**P1-ARX-05** [major] `paper/CLAIMS.md` — §3, entry R5

- *Problem.* The ledger states that SFI's loss in Eisenstat's example is 'H(1/3)/2 n ± O(log n), pathwise a.s. and in expectation'. Pathwise this is false (fluctuations of order sqrt n); the paper's body is correct, but the conversion pass and the intro were written from this ledger.
- *Evidence.* prop:ex:asymp (CLT for UB_n), thm:ex:sandwich (pathwise statement is relative to UB_n).
- *Fix.* Correct R5 to: "E LSFI = H(1/3)n/2 ± O(log n); almost surely |LSFI - UB_n| <= log n + O(log log n) + c_b, with UB_n = H(1/3)n/2 + O_P(sqrt n)", and check every sentence derived from R5 (intro line 20, H6 row).

**P1-ARX-06** [major] `paper/bib/core.bib; paper/sections/{versions,learn,hist,examples,nn,steeper,intro}.tex; app-examples.tex` — key hanni2026request; versions.tex:4, learn.tex:7, hist.tex:12 and :117, examples.tex:7, :35, :112, nn.tex:8, steeper.tex:14, intro.tex:51, :55, app-examples.tex:140, versions.tex:123 and :137

- *Problem.* The sole author cites 'Request for a paper on Solomonoff function induction. Personal communication to the author ... quoted verbatim in solomonoff-function-induction/research/00-brief.md' (a process file), and the text speaks of 'his request', 'Hänni's request', 'He later asked that the paper include ...', 'Answer to Hänni's request', 'as quoted in his request'. With Hänni as sole author this is a request from the author to himself; the binding note forbids conversational references to 'his request' and process vocabulary ('brief').
- *Evidence.* PDF p. 54: 'Kaarel Hänni. Request for a paper on Solomonoff function induction. Personal communication to the author, 11 October 2026; quoted verbatim in solomonoff-function-induction/research/00-brief.md ...'. versions.tex:4 'He later asked that the paper "include an equivalence ..."'; versions.tex:137 remark title 'Answer to Hänni's request'.
- *Fix.* Delete the entry. Re-source every use: (i) the author's own conjectures and examples -> first person or [Hän26] (the notes) when they are in the notes; (ii) Eisenstat's coin example -> 'S. Eisenstat (personal communication)' in the text and the acknowledgements; (iii) the e-mail heuristic -> 'a heuristic argument (the author, in correspondence with S. Eisenstat)'; (iv) versions.tex:4 -> 'A natural question is whether the Kolmogorov and semimeasure versions are equivalent, as for strings; they are not.'; (v) rem:versions:answer title -> 'Summary: the versions are not equivalent'; (vi) table caption: delete '(Hänni's later request)'.

**P1-ARX-07** [major] `paper/sections/*.tex` — 143 occurrences of "Hänni" in the PDF before Appendix I; section titles sec:hist:counter "Hänni's counterexamples", sec:hist:thm1 "Hänni's Theorem 1", sec:ood:examples "Hänni's examples"; environment titles thm:hist:chain, thm:hist:skipped, thm:hist:randchain, cor:hist:thm1, prop:ood:hanni, ex:ood:hanniexamples, rem:comp:apples, rem:ex:email, rem:hist:H4verdict

- *Problem.* The paper is now sole-authored by Hänni but refers to its author in the third person throughout and names results after him ('Hänni's chain', 'Hänni's proposition, with no log term', 'Verdict on Hänni's conjecture', 'Hänni's Theorem 1 in Reading C'). Self-eponymous theorem titles and third-person self-reference are not standard and will confuse readers (is Hänni the author or someone being corrected?). It also cites unpublished numbering ('Thm 1', 'Remark 4').
- *Evidence.* PDF text: 'Theorem 5.3 (Hänni's chain)', 'Proposition 7.1 (Hänni's proposition, with no log term)', 'Remark 5.23 (Verdict on Hänni's conjecture)'; comp.tex:54 'This is Hänni's "Remark 4"'; hist.tex:62 'Hänni's Thm 1: ...'.
- *Fix.* Neutral titles: 'A chain example', 'Skipped strings', 'Unseen simple properties (no logarithmic term)', 'The randomised chain', 'A dominance theorem for computable reveal laws', 'Three examples', 'Like-for-like comparison', 'A heuristic argument for Eisenstat's example', 'Summary: SFI with the list of previous inputs'. In prose use 'the author's earlier notes [Hän26]' once per section and then '[Hän26]'; state the arrangement once in the introduction ('This paper develops, corrects and extends the author's notes [Hän26]').

**P1-ARX-08** [major] `paper/sections/{intro,ood,versions}.tex` — intro.tex:26 ("the PDF draft", "which the draft hoped"); ood.tex:7, :51 (subsection title "The draft's two-sided result"), :53, :65 (title "the draft's bounds as stated are false"); versions.tex:4, :144 ("Hänni's draft")

- *Problem.* 'The draft' / 'the PDF draft' is an unpublished document the reader cannot identify; it is neither in the bibliography nor distinguished from [Hän26].
- *Evidence.* PDF §7.2 heading 'The draft's two-sided result'; Proposition 7.6 title 'the draft's bounds as stated are false'.
- *Fix.* Cite it as [Hän26] (the PDF 'solomonoff function induction.pdf' is in the same notes folder) and rename: §7.2 'A two-sided bound', prop:ood:draftfalse 'The literal two-sided bounds fail'; state the literal bounds in a displayed formula before refuting them.

**P1-ARX-09** [major] `paper/sections/{setting,versions,hist,ood,nn,steeper,examples}.tex` — e.g. setting.tex:4, hist.tex:28, hist.tex:62, nn.tex:8, nn.tex:33, examples.tex:7, ood.tex:7, ood.tex:153, steeper.tex:6, steeper.tex:14

- *Problem.* Verbatim quotations of informal, lower-case working notes ('you have a bunch of input-output pairs. you have the usual prior on all programs. solomonoff function induction := ...', 'I'm pretty sure Solomonoff induction gets unbounded loss on this sequence. I don't actually have a proof', 'kinda like a circuit version of solomonoff function induction', 'doing sth more like a polyfit') are not formal academic register (binding note: 'Tone: formal academic register'). In a sole-authored paper they read as the author quoting his own chat messages.
- *Evidence.* PDF §2 first paragraph and §5.2, §9 first sentence.
- *Fix.* Paraphrase each in one formal sentence with a citation ([Hän26]); keep at most one short quotation where the exact wording matters (e.g. the definition of SFI in §2).

**P1-ARX-10** [major] `paper/sections/intro.tex` — lines 26-53 (tab:intro:verdicts and the sentence introducing it); learn.tex:87 ("This refutes the fresh-noise form of the supervised-learning hypothesis H7 ... (tab:intro:verdicts)")

- *Problem.* A table of 'the ten working hypotheses with which this study began' (H1-H10) with 'verdicts' is an internal research-process artefact (binding note; the review brief lists 'H1-H10 verdict tables' explicitly). It also duplicates the contributions list and costs a full page.
- *Evidence.* PDF p. 6 Table 1 'The working hypotheses H1-H10, paraphrased, with verdicts'; learn.tex:87 cites it.
- *Fix.* Delete the table, the sentence 'Table 1 lists the ten working hypotheses ...', and learn.tex:87's H7 sentence. Fold the two facts that are not already in the contributions list into it: (a) the weak-versus-machine refutation (rem:setting:h1a), (b) the H7 fresh-noise caveat (already in bullet 3).

**P1-ARX-11** [major] `paper/main.tex; paper/sections/app-verification.tex` — main.tex: \input{sections/app-verification}; Appendix I (pp. 96-103)

- *Problem.* The verification appendix ('How the claims were checked': roles, tracks, referees, corrections table with M/m item numbers, cross-track conflicts C1-C25, reproduction recipe, unresolved points) is required to be dropped by the binding note, and is 7.5 pages of process vocabulary.
- *Evidence.* Appendix I, e.g. 'Five research tracks, each one instance', 'An adversarial referee per track', 'resolved 25 cross-track conflicts', Table 9 'Corrections'.
- *Fix.* Drop the \input. Move: (1) environment (Python 3.11.15, numpy 2.4.6, scipy 1.17.1, mpmath 1.3.0) and the statement that every computation is seeded/deterministic and reproduces its saved output into 'Code and data'; (2) the reproduction recipe into the repository README (not the paper); (3) the account of how the paper was prepared into the existing acknowledgements paragraph (see issue on acknowledgements); (4) proof-sketch and conditional statuses (I.4) into the statements themselves (see conversion table); (5) open problems: already in §12; (6) literature caveats: resolved by verifying references (§5 of this review), not by a disclaimer; (7) the corrections table and conflicts: delete (the corrections that inform the reader are already stated where they occur).

**P1-ARX-12** [major] `paper/preamble.tex; all section files` — \status{...} and \src{...} on 187 of 203 theorem-like environments; inline \status in prose at setting.tex:40, app-versions.tex:92, app-versions.tex:102; inside tables at app-examples.tex:133 (tab:ex:cycle) and app-examples.tex:164 (tab:ex:eisenstat)

- *Problem.* Status tags ('[proved; computed (context c7)]', '[known; unverified (claimed in the slides)]', '[refuted]') and grey source notes ('foundations Thm 6.1; F20-F23') are printed in the PDF. The binding note requires none in the final PDF. Simply redefining the macros to no-ops is not enough for 16 environments whose status carries mathematical information (proof sketch, conjecture, conditional, refuted): those need rewording (conversion table, §4 of this review).
- *Evidence.* PDF: 151 occurrences of '[proved', e.g. 'Theorem 4.1 (dominance). [proved] foundations Thm 6.1'; p. 85 table 'Table ... [computed] examples §2.6; checks e3, e6'.
- *Fix.* Conversion: (1) apply the rewordings of the conversion table (130 rows) first; (2) then delete every \status{...} and \src{...} from the sources (do not just redefine them: \src arguments contain process vocabulary that would remain in the .tex shipped to arXiv); (3) remove the two macro definitions from preamble.tex; (4) grep the final .tex and PDF for 'track', 'referee', 'ledger', 'notes-final', 'brief', 'unverified', 'snippet', 'not checked', 'H[0-9]', 'c[0-9]', 'r[0-9]', 'e[0-9]' as a final check.

**P1-ARX-13** [major] `paper/sections/{setting,learn,app-setting,app-versions,app-learn}.tex` — setting.tex:44 "(c1)", :119 "(c3)", "(context c3)", :156 "(c9(c))"; learn.tex:49 "foundations r6", :87 "(foundations c5)", :108 and :112 "(foundations r12)"; app-setting.tex:115 "check c6", :117 "(c1 checks ...; r1 also k=3)", :125 "(c9(b))", "(c9(b) for k<=4; r1)", :151 "(c10(a4))", :154 "Check c10 ... (r13: 300 of 300)", :166 "(c10(b) checks ...)"; app-versions.tex:35, :60, :86, :99, :102 (c2, c8(a)-(d), r11); app-learn.tex:141 ("Foundations: c4 ... r6 ... Context: c3, c4, c7")

- *Problem.* Visible identifiers of internal check scripts (cN, rN, track names) in the running text. They are meaningless to a reader and are process vocabulary. (Sections ex, ood, comp, nn already use the correct form 'a direct computation (code in the accompanying repository)'.)
- *Evidence.* PDF §2.4: 'semimeasure probability 1/4 in both orders (c3). On a random six-point mixture ... (context c3)'; §4.2: 'in a finite analogue, foundations r6'.
- *Fix.* Replace each by 'a direct computation (code in the accompanying repository) confirms ...' or delete the parenthesis. Rewrite app-learn.tex:141 as 'Computations. All numbers in Section 4 and here come from seeded or deterministic scripts in the accompanying repository: dominance and order independence on finite mixtures over four inputs; ...' (descriptions without identifiers), mirroring app-examples.tex:237.

**P1-ARX-14** [major] `paper/sections/{setting,versions,learn,hist,comp,nn,related,discussion,intro,app-setting,app-versions,app-learn}.tex` — setting.tex:12 ("without re-checking the sources"), :40, :175; versions.tex:21 ("abstract only seen", "search snippet only"); learn.tex:49 ("source not checked"), :77 ("not checked"), :171 ("A table-of-contents snippet shows ... We have not read these sections"); hist.tex:127 ("abstract seen only"; "we have not checked whether ..."), :135, :157; comp.tex:128 ("we have not checked them"); nn.tex:62, :73, :81 ("the rest is unchecked"), :91 ("These descriptions follow the abstracts"); related.tex:6, :8, :10, :12; discussion.tex:13; intro.tex:9, :55, :57; app-setting.tex:81, :132; app-versions.tex:92, :102; app-learn.tex:106, :129, :133

- *Problem.* About 35 visible hedges describing the research process ('we have seen only the abstract', 'search snippet only', 'not checked against the source', 'we have not read these sections'). They are not standard academic form, and the binding note requires verified references instead of printed caveats. Where the hedge protects a content claim that was never verified, deleting it would create an unsupported claim.
- *Evidence.* See the process-vocabulary table (§4.2 of the review) for each sentence.
- *Fix.* For each: (a) bibliographic facts are now verified (§5) -> delete the caveat; (b) content claims about a cited work: either verify against the source (Solomonoff 2008, Hutter 2005/2007, Lattimore-Hutter 2013 and Lattimore-Hutter-Gavane 2011 are obtainable) and state them plainly, or rephrase as the paper's own reading ('We read operator induction [Sol08] as ...'), or drop the sentence; never keep 'abstract seen only'.

**P1-ARX-15** [major] `paper/sections/{versions,related,discussion}.tex; app-hist.tex` — versions.tex:20-22 rem:versions:operator; related.tex:6; discussion.tex:13; app-hist.tex:176 prop:hist:operator

- *Problem.* The identification 'operator induction = per-query mixture M_pq' rests on a search snippet of a secondary source (Özkural 2017), whose abstract does not concern operator induction; the primary source was seen only at abstract level. The conclusion 'So operator induction and M_prod coincide only on distinct inputs' and 'x-only dominance on distinct inputs is then Solomonoff's' are stated flatly. Once the hedges are deleted in the conversion, these become unsupported claims about Solomonoff's work.
- *Evidence.* Status of rem:versions:operator: 'known; unverified; equality on distinct inputs proved'; prop:hist:operator: 'proved, given the unverified description'; bib comment of ozkural2017ultimate: 'the product formula for operator induction seen in a snippet only'.
- *Fix.* Before submission, read Solomonoff (2008) (freely available from raysolomonoff.com) and cite the formula from it; or reformulate everything as statements about M_pq with one sentence 'We read Solomonoff's operator induction [Sol08] as the per-query mixture M_pq'. Drop the two Özkural citations as sources of the formula.

**P1-ARX-16** [major] `paper/sections/{intro,hist,related,discussion}.tex` — intro.tex:9 and :55; hist.tex:135 (after cor:hist:H4); related.tex:8; discussion.tex:13

- *Problem.* The relation of SFI^hist / M_H to Hutter's universal chronological semimeasure is described as 'known, but not checked against the sources', 'expected but was not checked', and 'prior work in substance'. The arXiv version cannot carry these process hedges, but replacing them by 'M_H agrees with Hutter's xi up to constants' would claim more than the sources (CLAIMS.md C13: 'Hutter identification known but unverified').
- *Evidence.* cor:hist:H4 status 'proved; identification known (unverified)'; hist.tex:135.
- *Fix.* Write: 'Chronological semimeasures and their universal mixture were introduced by Hutter [Hut00, Hut05] for the AIXI model, with finite alphabets; Corollary 5.18 shows that M_H is universal in this class for countable alphabets. Hutter also lists supervised learning from examples among AIXI's problem classes [Hut00, Hut07].' Do not assert equality with Hutter's construction unless the author checks [Hut05].

**P1-ARX-17** [major] `paper/sections/related.tex` — rem:related:new (lines 16-19)

- *Problem.* A 'Remark' titled 'what exists and what appears new' that begins 'At the level of a search that saw abstracts and secondary sources only' and ends with an instruction to the authors ('Each of these should be checked against [Sol08], [Hut05] and [LH13] before any claim of novelty'). This is process text, not a paper statement, and it carries a status tag 'known (snippets; unverified)'.
- *Evidence.* PDF p. 50, Remark 11.1.
- *Fix.* Do the three checks (the sources are obtainable). Then replace the remark by a two-sentence 'Novelty' paragraph without process vocabulary, e.g. 'To our knowledge the name and the function-machine formulation are new, as are the separations of Section 5, the OOD results of Section 7 and the time-bounded mixtures of Section 8.1; the per-query mixture, the universal chronological semimeasure, Occam/PAC-Bayes/online-to-batch bounds and the conjunction ladder are not.' If the checks are not done, keep only the first clause about the name.

**P1-ARX-18** [major] `paper/sections/{hist,comp}.tex` — thm:hist:minimax (hist.tex:96-99); thm:comp:timebounded(b) (comp.tex:20-25); prop:comp:round last sentence (comp.tex:36); prop:comp:history last clause (comp.tex:63)

- *Problem.* Parts that are only proof sketches are stated inside Theorem/Proposition environments. Today only the status tag says so; after the tags are removed, these statements would be presented as fully proved (binding note: 'the statement must not be presented as fully proved').
- *Evidence.* thm:hist:minimax status '(a) proved; (b) proved for reveal laws that do not see f, proof sketch for those that do'; the theorem text explicitly allows reveal laws that see f|A_n in case (b). thm:comp:timebounded '(b) proof sketch'; prop:comp:round 'running time proof sketch'; prop:comp:history 'running time proof sketch'.
- *Fix.* Split each: the environment states only what is proved (minimax (b) only for reveal laws that do not see f; time-bounded (a) only; round/history: regret only). The rest goes into a Remark with a paragraph labelled 'Proof sketch.' and the sentence 'We do not write out the machine model and the cost of the clocks.' (exact wording in the conversion table rows for these labels).

**P1-ARX-19** [major] `paper/sections/ood.tex` — conj:ood:natural (lines 177-182)

- *Problem.* A Conjecture environment whose next sentence says 'This is not a precise statement'. A conjecture in an arXiv paper must be a precise mathematical statement; this one is a research direction.
- *Evidence.* ood.tex:182 'This is not a precise statement, and by Proposition 7.4 it fails for some universal machines'.
- *Fix.* Remove the environment; add an item to the Open Problems list of §12: 'Find conditions on a reference machine and on training sets under which SFI gives the intended answers of Example 7.16 with posterior probability close to 1; by Proposition 7.4 no such statement holds for all universal machines.'

**P1-ARX-20** [major] `paper/sections/{setting,versions,hist,examples,ood,comp,nn}.tex; discussion.tex; intro.tex` — 13 "\paragraph{Open question.}\label{q:...}" (setting x4, versions x2, hist, examples x2, ood, comp x2, nn); references in intro.tex:57 and discussion.tex:17-23

- *Problem.* Open questions are unnumbered paragraphs with labels; every cross-reference to them prints the number of the enclosing subsection, so the reader is sent to 'Section 2.3' or 'Sections 2.4 and 6.3' instead of to a question. The Open Problems list in §12 thus points at sections.
- *Evidence.* PDF p. 5: 'whether MF dominates every lower-semicomputable law of a random partial function (Section 2.3); ... several lower bounds in the normalised convention (Sections 2.4 and 6.3)'. Appendix I.7 records this as unresolved.
- *Fix.* Define \theoremstyle{definition}\newtheorem{question}[theorem]{Open question} (or number the items of the §12 list and label those), convert the 13 paragraphs, and make §12's list the single home with back-references.

**P1-ARX-21** [major] `paper/sections/app-learn.tex` — rem:learn:cesaro (lines 117-120)

- *Problem.* A remark that records an internal correction: 'An earlier version of the context notes read Proposition 4.13 as ...'. The binding note: refuted earlier claims appear only where they inform the reader; no list of internal corrections; no 'notes'.
- *Evidence.* app-learn.tex:119.
- *Fix.* Delete, or rewrite as an informative remark: 'Proposition 4.13 should not be read as matching the O(1/n) Cesàro bound up to log^2 n: it is a per-step lower bound, whereas Theorem 4.5 bounds an average; indeed sum_k E e_k <= (ln 2)(K(f)+c), so liminf_k k E e_k = 0. Corollary 4.14 gives the per-step comparison.'

**P1-ARX-22** [major] `paper/sections/app-setting.tex` — line 132, paragraph heading "Reformulation (proof sketch; foundations Problem 3.6)." and "(quoted, not checked against the source)"; line 134

- *Problem.* A printed heading containing a track name and an internal problem number; the paragraph also says 'Two steps are not written out ... An adversary argument ... was tried and settled neither direction'.
- *Evidence.* PDF Appendix A.6 heading 'Reformulation (proof sketch; foundations Problem 3.6).'
- *Fix.* Heading 'A sufficient condition (proof sketch).'; cite Strassen as 'by Strassen's theorem on monotone couplings for finite partially ordered sets [Str65]'; replace the last paragraph by 'We do not carry out the reduction from general lower approximations to finite rational laws.' and delete the sentence about an attempted adversary argument.

**P1-ARX-23** [major] `paper/sections/versions.tex` — tab:versions:compare caption (line 123)

- *Problem.* Caption contains '(Hänni's later request)' and 'Source: foundations Table 4.12.'
- *Evidence.* PDF p. 16, Table 2 caption.
- *Fix.* Caption: 'The Kolmogorov and semimeasure versions compared, for data sets with inputs of length at most d; gaps in bits. Every entry is proved where cited; by Remark 3.12 no computable family exhibits a gap larger than K(k)+O(1) in any row.'

**P1-ARX-24** [major] `paper/bib/core.bib; paper/sections/steeper.tex` — key hanni2026lesswrong; steeper.tex:6 \citep{hanni2026notes,hanni2026lesswrong}

- *Problem.* The LessWrong entry lists 'Kaarel Hänni and Cole Wyeth' as authors of 'Comments in the thread "Jonas Hallgren's Shortform"', year 'undated', note 'Text as pasted by K. Hänni'. Wyeth thereby appears as co-author of a source cited in the sentence that introduces the steeper-prior proposal, directly before the paragraph 'The absorption objection'. The binding note allows at most one neutral footnote recording that the point was raised in the thread, and forbids naming the objection after Wyeth. The entry is also bibliographically wrong (co-authorship of a comment thread) and unverifiable (page not reachable, no search hit, no date).
- *Evidence.* PDF p. 47: '(Hänni, 2026b; Hänni and Wyeth, undated)'; p. 54 bibliography entry.
- *Fix.* Remove hanni2026lesswrong from steeper.tex:6 (the proposal is in [Hän26]). If the thread is to be mentioned, add one footnote to the absorption paragraph: 'The point was also raised in a LessWrong discussion [ref].' with an entry whose author is the thread owner or 'LessWrong', with the comment date, and without quoting anyone. Never print 'undated' or 'Text as pasted'.

**P1-ARX-25** [major] `paper/bib/core.bib` — keys hanni2026notes, vaintrobhanni2026nnbayes

- *Problem.* hanni2026notes prints as 'Kaarel Hänni. notes. Public repository of working notes, https://github.com/kaarelh/notes, 2026b. Accessed October 2026.' (title 'notes'). vaintrobhanni2026nnbayes points to kaarelh.github.io/ai/nnbayes-generalization.pdf, which could not be reached, and no search finds the title or an ILIAD listing; it is the source of all claims of §9 marked 'claimed in the slides' and of the conjunction-ladder construction.
- *Evidence.* WebFetch of github.com/kaarelh/notes: repository exists (MIT, 'some of my notes from 2023-2026'); the SFI note is ai/learning/solomonoff induction/solomonoff function induction.md and .pdf. Slides: no hit (a Fields Institute talk of 21 Apr 2026 by Vaintrob on the joint work exists).
- *Fix.* hanni2026notes: title = {Solomonoff function induction}, howpublished = {Note in the repository \url{https://github.com/kaarelh/notes}, folder ai/learning/solomonoff induction}, year = {2026}. Slides: the author (a co-author) confirms the exact title, venue and date and that the URL is public before submission; otherwise cite as 'D. Vaintrob and K. Hänni, slides of a talk, 2026, available from the authors' and keep only what is needed.

**P1-ARX-26** [major] `paper/sections/discussion.tex` — Acknowledgements, line 31

- *Problem.* The disclosure paragraph uses process vocabulary ('developed in five groups', 'Each group's notes ... were checked by a separate instance ... acting as an adversarial referee') and ends with 'The literature was searched only through a web-search tool that returned excerpts; most cited works were not read in full, and the text says so where it relies on them'. The binding note wants a short account of how the paper was prepared and checked, and verified references instead of caveats; after the conversion the text will no longer 'say so where it relies on them'.
- *Evidence.* discussion.tex:31.
- *Fix.* Replace by: 'This paper was developed and written with extensive assistance from Claude (Anthropic), an AI system. Working from the author's notes [Hän26] and under his direction, Claude produced the proofs, the computations and the text. Each part was checked by further, independent instances of the system, which re-derived the proofs and re-implemented the computations; the author reviewed the results. No human has yet independently checked all of the mathematics, and readers should weigh the results accordingly.' Add: 'The coin example of Section 6.3 is due to Sam Eisenstat (personal communication).'

**P1-ARX-27** [major] `paper/sections/discussion.tex` — Code and data, line 34

- *Problem.* The statement points to 'research/tracks/*/checks/' and 'research/tracks/*/referee_code/' (process vocabulary in printed paths) and does not give the software environment (which is only in Appendix I).
- *Evidence.* PDF p. 52.
- *Fix.* 'Code and data. All computations were done with seeded or deterministic Python scripts (Python 3.11, numpy 2.4, scipy 1.17, mpmath 1.3), available with their saved outputs at https://github.com/kaarelh/AI-works, folder solomonoff-function-induction/ (see its README for the list of scripts and the command that re-runs them).' If the folder names cannot change, refer to the README rather than to the paths.

**P1-ARX-28** [major] `paper/main.tex (whole paper)` — 103 pages: main text pp. 3-52, references pp. 52-57, appendices pp. 57-103; 203 theorem-like environments

- *Problem.* Far longer than a typical arXiv paper in learning theory / algorithmic information theory (usually 20-40 pages of main text plus appendices, often 40-70 pages in total). The length comes from breadth (12 sections, 9 appendices) and from many secondary remarks, not from long proofs. The page budget in OUTLINE.md (38 + 35.5) is already exceeded by 12 pages in the main text, as Appendix I.7 admits.
- *Evidence.* Page counts from main.toc: Intro 4.5, §2 5, §3 5, §4 5, §5 6, §6 6, §7 5, §8 4.5, §9 4, §10 2, §11 1, §12 2.5; App. A 7, B 4, C 6, D 8, E 7, F 2, G 4, H 1, I 7.5.
- *Fix.* Target <= 40 pages of main text and <= 30 of appendices (§6 of the review gives a cut list): drop App. I (-7.5) and Table 1 (-1); shrink §10 to one paragraph in §12 (-1.7); cut or move to appendices rem:versions:prediction/rem:versions:answer overlap (-1), rem:learn:ideal, rem:learn:hutterEX (to §11), rem:learn:positive, rem:learn:interventions, rem:learn:relations, rem:versions:hashing, rem:comp:apples, rem:comp:gap, rem:nn:rigorous, rem:nn:literature (to §11), rem:ood:answer (merge into §12), tab:ood:hanni; consider moving §8-§9 (computable versions, NN Bayes; 8.5 pp main + 5 pp appendix) to a separate short paper or to the companion.

**P1-ARX-29** [major] `paper/sections/intro.tex` — lines 15-24 (Contributions) and line 59 (Reader's guide)

- *Problem.* The contributions list is eight dense bullets of 5-8 lines with up to six cross-references each; it summarises nearly every result rather than stating the main contributions. The 'semimeasure convention', used in the abstract and in four bullets, is only defined in the Reader's guide at the end of the introduction.
- *Evidence.* intro.tex:19-21 use 'semimeasure convention' / 'normalised convention'; the definition is at intro.tex:59.
- *Fix.* Move the two-convention explanation (2-3 sentences) before the contributions list; cut the list to 5-6 bullets of 2-3 lines naming the main theorems (universality and invariance; no coding theorem for function programs; pathwise dominance and online-to-batch with the fresh-noise caveat; order-blindness and SFI^hist; the two worked examples; OOD bounds), and move the detail to the sections.

**P1-ARX-30** [major] `paper/sections/related.tex` — whole section (lines 4-19)

- *Problem.* Related work is one page, placed after all results and the companion-paper summary, and most sentences are hedged ('we have seen only the abstract', 'we have not checked', 'we have not examined'). Primary sources for Solomonoff induction itself are missing (only Li-Vitányi and Solomonoff 1978/2008 are cited), and the Discussion repeats the related-work paragraph ('Relation to the literature').
- *Evidence.* related.tex:6-12; discussion.tex:13.
- *Fix.* Move related work to §2 (after the introduction) or merge it with discussion.tex:13 into one section; remove hedges after verification; add the primary SI references (e.g. Solomonoff 1964, Information and Control 7; Hutter 2005 already cited) and a sentence on Gold-style identification vs Bayesian prediction; move rem:nn:literature and rem:learn:hutterEX into it.

**P1-ARX-31** [major] `paper/sections/abstract.tex; paper/main.tex` — abstract line 3; main.tex \tableofcontents\newpage

- *Problem.* Page 1 consists of the title, a 248-word abstract that lists ten results with undefined symbols (K(dom D), d, K in 'O(K/n)', 'semimeasure convention', 'universal chronological semimeasure', 'reveal orders') and no motivating sentence, and the start of a full-page table of contents; the introduction starts on page 3.
- *Evidence.* PDF pp. 1-2.
- *Fix.* Abstract: open with one sentence of motivation (SFI as an ideal of supervised learning, analogous to Solomonoff induction for sequences), then 4-5 main results in words (no undefined symbols), then the order-blindness/SFI^hist point, then one sentence on the companion paper. Drop \newpage after the TOC (or the TOC itself) so the introduction starts on page 2.

**P1-ARX-32** [minor] `paper/sections/intro.tex` — line 19 "its exact relation to SI on the interleaved sequence is in Theorem 5.20 and Proposition 5.21"

- *Problem.* 'exact' overstates: the relations hold up to additive constants, the identity needs a deterministic input policy, and whether L_M^joint = L_H + L_in^x ± O(1) is open.
- *Evidence.* thm:hist:si; prop:hist:inputloss; q:hist:open (iv).
- *Fix.* 'its relation to SI on the interleaved sequence ...'.

**P1-ARX-33** [minor] `paper/sections/abstract.tex` — line 3: "agree up to K(dom D) bits"; "does not depend, up to a constant factor, on the universal machine or on computable encodings"; "has risk O(K/n)"; "SFI cannot use the order of the data"

- *Problem.* Small imprecisions: the chain holds up to K(dom D)+O(1); invariance under an encoding (alpha,beta) costs a factor 2^{K(alpha,beta)+O(1)} that depends on the encoding; 'K' in O(K/n) is undefined; order-blindness is proved for the semimeasure-convention loss (normalised predictions can depend on the order; open for MF).
- *Evidence.* thm:versions:chain; thm:setting:invariance(b); thm:learn:batch(a); prop:setting:order, prop:setting:normalise(b).
- *Fix.* 'agree up to K(dom D)+O(1) bits'; 'up to a factor depending only on the encoding'; 'risk O(K(f)/n), where K(f) is the complexity of the labelling function'; 'SFI's cumulative loss does not depend on the order of the data'.

**P1-ARX-34** [minor] `paper/sections/intro.tex` — line 22: "makes 2^{Ω(ℓ/log ℓ)} mistakes on some ordering for a target of description length ℓ"

- *Problem.* Reads as a statement about every target of description length ℓ; the theorem is about one target family (the conjunction of d variables, ℓ = Θ(d log d)).
- *Evidence.* thm:comp:ladder.
- *Fix.* '... makes 2^{Ω(ℓ/log ℓ)} mistakes on some ordering for the conjunction of d variables, whose description length is ℓ = Θ(d log d)'.

**P1-ARX-35** [minor] `paper/sections/{setting,learn}.tex` — setting.tex:135 rem:setting:recommend, :143 thm:setting:invariance(c), :151 thm:setting:coding(b)

- *Problem.* Section 2 uses W, K_F, M_prod, M_pq and M^w before Section 3 defines them (forward references to def:versions:variants).
- *Evidence.* thm:setting:coding(b) '... with K_F the shortest consistent program (Definition 3.1)'.
- *Fix.* Either move def:versions:variants into §2.2 (it is three lines) or move thm:setting:invariance(c), the K_F part of thm:setting:coding(b) and rem:setting:recommend to §3.

**P1-ARX-36** [minor] `paper/sections/learn.tex` — prop:learn:curve, line 105: "for w = 1/16, r_0 = 0.912"

- *Problem.* Rounding: r_0 = log2(32/17) = 0.91254, which rounds to 0.913.
- *Evidence.* scratch/p1-arxiv-r2/numbers_check.out: 'r0=0.913 r1=1.544'.
- *Fix.* Write r_0 = 0.913 (or 0.9125).

**P1-ARX-37** [minor] `paper/sections/discussion.tex` — line 5 ("In exchange, ...", "are each a precise statement, not a caveat"); line 26 ("a universal hypothesis absorbs everything instead")

- *Problem.* Rhetorical or informal phrasing in the Discussion.
- *Evidence.* discussion.tex:5, :26.
- *Fix.* 'Moreover, for a computable target f ...'; delete 'are each a precise statement, not a caveat'; 'a universal hypothesis is selected and fits the data as well as the universal mixture (the absorption theorem of [Hän26a])'.

**P1-ARX-38** [minor] `paper/sections/nn.tex` — rem:nn:rigorous (line 86): "the Gaussian-process limits fail on sparse and odd parities where SFI succeeds"

- *Problem.* For sparse parities the failure is in averaged squared error over random targets (cor:nn:separation), and the text after it says 'we do not claim a 0-1 version in general'; only the bias-free two-layer ReLU case has an exact 0-1 failure.
- *Evidence.* cor:nn:separation; nn.tex:69.
- *Fix.* 'the Gaussian-process limits need n >= (1-ε)C(d,k) samples for squared error ε on random k-sparse parities, where SFI needs O(k log d/ε), and bias-free two-layer ReLU kernels never learn odd parities of size >= 3'.

**P1-ARX-39** [minor] `paper/sections/comp.tex` — line 54 "This is Hänni's \"Remark 4\""; hist.tex:12 and :62 "(\"Thm 1\")"

- *Problem.* References to item numbers of unpublished notes.
- *Evidence.* comp.tex:54; hist.tex:12, :62.
- *Fix.* 'This answers a question in [Hän26]'; 'the dominance theorem of [Hän26]'.

**P1-ARX-40** [minor] `paper/sections/app-versions.tex` — rem:versions:hashing title (line 55) "The hashing bound, superseded"

- *Problem.* 'superseded' describes the research history.
- *Evidence.* app-versions.tex:55.
- *Fix.* Title 'A hashing bound'; first sentence 'Proposition 3.6(b) is stronger'. Consider deleting the remark and its proof (1 page).

**P1-ARX-41** [minor] `paper/bib/*.bib` — day2011increasing, orseau2013universal, wood2013non, vovk1990aggregating, barzdin1972prediction, case1983comparison, hoeffding1963probability, grunwald2007suboptimal, kleitman1973families, ville1939etude

- *Problem.* Incomplete or unconfirmed bibliographic data in otherwise verified entries; Barzdin-Freivalds prints without pages, Day without volume and pages, Wood et al. without volume.
- *Evidence.* WebSearch results recorded in scratch/p1-arxiv-r2/bib_log.md (e.g. AMS issue listing: Trans. Amer. Math. Soc. 363(10) (2011) 5577-5604; Springer: ALT 2013 = LNCS 8139).
- *Fix.* Apply the corrections of the bibliography table (§5): Day 363(10):5577--5604; Orseau et al. volume 8139; Wood et al. volume 7070, ed. Dowe; Vovk 1990 pp. 371--383; Barzdin-Freivalds pp. 1224--1228; Case-Smith no. 2; Hoeffding no. 301; Grünwald-Langford no. 2--3 and doi; Kleitman-Spencer no. 3; Ville: confirm the Gauthier-Villars imprint or cite the thesis record.

**P1-ARX-42** [minor] `paper/bib/related.bib; paper/bib/setting.bib` — ozkural2015ultimate, ozkural2017ultimate

- *Problem.* Bibliographic data verified, but both are cited only as secondary sources for the operator-induction formula, which no search confirmed to be in them (2015's abstract is about physical measures of intelligence).
- *Evidence.* bib comments; WebSearch on both arXiv records.
- *Fix.* Drop both once the formula is cited from Solomonoff (2008) (see the operator-induction issue).

**P1-ARX-43** [minor] `paper/bib/core.bib` — claude2026whatfollows, claudeSFI2026fundamentals (uncited in Paper 1); claudeSFI2026steeper

- *Problem.* claude2026whatfollows has author '{Claude (Anthropic)}' and 'Unpublished report prepared for K. Hänni' -- incompatible with the authorship rule if any paper cites it; the companion entry prints 'Companion paper, draft ... Folder ... of GitHub'.
- *Evidence.* core.bib; PDF p. 54.
- *Fix.* Paper 1: nothing to do for the two uncited keys (BibTeX drops them). Companion: cite by arXiv identifier once posted, else 'In preparation'.

**P1-ARX-44** [minor] `paper/NOTATION.md` — §3.1 row \nulen

- *Problem.* NOTATION.md defines the shared-coin law as F(x) = omega_{|x|}; the paper (correctly) uses omega_{|x|+1}. Paper 2 must use the same indexing.
- *Evidence.* versions.tex:61; app-verification.tex:177.
- *Fix.* Update NOTATION.md and check paper-steeper for omega_{|x|}.

**P1-ARX-45** [minor] `paper/sections/app-examples.tex` — tab:ex:cycle (line 133), tab:ex:eisenstat (line 164)

- *Problem.* \status{computed}\src{examples §2.6; checks e3, e6} and '...check e2, seed 20261011' are typeset inside the table floats.
- *Evidence.* PDF Appendix E tables.
- *Fix.* Delete; put the seed into the caption only if useful ('simulation with a fixed seed; code in the accompanying repository').

**P1-ARX-46** [minor] `paper/sections/{versions}.tex` — rem:versions:prediction (lines 127-135) and rem:versions:answer (lines 137-145)

- *Problem.* The two remarks and the table repeat each other (the K_F gap, the W gap, the K(dom D) agreement, deterministic targets).
- *Evidence.* versions.tex:127-145.
- *Fix.* Merge into one remark 'What the gaps mean' of at most half a page.

**P1-ARX-47** [minor] `paper/sections/learn.tex` — rem:learn:ideal (lines 163-167)

- *Problem.* Repeats the introduction's 'Why SFI' paragraph and the Discussion's first paragraph almost item by item.
- *Evidence.* intro.tex:7; discussion.tex:5.
- *Fix.* Keep it here (it has the references) and shorten the other two to one sentence each pointing to it.

**P1-ARX-48** [minor] `paper/sections/intro.tex` — line 59, Reader's guide: "Section 3 answers the question of the Kolmogorov and semimeasure versions"

- *Problem.* 'the question' refers to the request.
- *Evidence.* intro.tex:59.
- *Fix.* 'Section 3 compares the Kolmogorov and semimeasure versions'.

**P1-ARX-49** [major] `paper/main.tex; paper/preamble.tex; paper/sections/*.tex; paper/bib/*.bib` — LaTeX comments, e.g. main.tex lines 5-6 and 44-46, the first lines of every section file, the "% unverified: ..." comments in bib/*.bib

- *Problem.* arXiv distributes the LaTeX source. The comments name the research process and internal files ('Plan: OUTLINE.md; ledger: CLAIMS.md', 'framing editor', 'binding note', '% Sources: research/tracks/foundations/notes-final.md', '% unverified: the LessWrong page did not resolve from the research environment'). They are invisible in the PDF but public in the source tarball.
- *Evidence.* main.tex:5-6 '% Paper 1. Plan: OUTLINE.md; ledger: CLAIMS.md; notation: NOTATION.md.'; setting.tex:1 '% Section 2 (writer: setting). Sources: research/tracks/foundations/notes-final.md (F) ...'.
- *Fix.* Prepare the arXiv tarball from a cleaned copy: strip all comments (e.g. with arxiv_latex_cleaner or a sed pass), include the generated main.bbl instead of bib/*.bib and merge_bib.py, and omit build logs, build-test/ and test-section.sh.

