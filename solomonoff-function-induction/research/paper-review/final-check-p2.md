# Final check, Paper 2 (`paper-steeper/`, groups p2-front and p2-body)

Fresh final checker, 2026-10-12, 22:05 to 22:20. Read before checking: `DECISIONS.md` (all sections), `edits/status-rendering.md`, `edits/p2-front.json`, `edits/p2-body.json`, `edits/log-p2-front.md` (phases 3 and 4), `edits/log-p2-body.md`, every file of `paper-steeper/sections/` except `app-verification.tex`, `main.tex`, `preamble.tex`, `bib/core.bib`, the steeper `notes-final.md` (§0–§4.6), the context `notes-final.md` (Thm 3.11, Rem 3.13), the check outputs `checks/c3_junta_window.out` and `checks/c7_run2.out`, and the grokking note `research/prior/hanni-grokking-a-notion.md`. No git command was run. No label was added, renamed, moved or deleted.

**Result.** Every fatal and major issue of both lists is fixed in the sources as decided. Four small edits were made (§0). The full build is clean (0 errors, 0 undefined references and citations, 0 multiply defined labels, no overfull box above 10pt). All greps of §A2.5, §A5 and §B.6 return only the allowed hits. One acceptance criterion is still not met: the **main text is 28 pages against the cap of 27** (§5). Closing that gap needs about one page of cuts and a decision by the lead editor.

---

## 0. Edits made in this check

| file | change | reason |
|---|---|---|
| `sections/abstract.tex` | "…knows the parity and gives the erroneous labels far less probability…" → "…knows the parity and, **when the error rule is large,** gives the erroneous labels far less probability…" | The decided §F28 sentence states the error-label conclusion for every instance in the window. The body proves it (`thm:teacher:main`(e), bound $1-u+\gamma_g+2^{-g}$) only when $s_0$ is large compared with the information budget, which is the condition §F35 itself puts in the body ("when the error rule is large compared with the information budget"). For the in-scope instance `ex:teacher:version1` ($m=10$, $p=2^{-6}$, $s_0=16$) the bound exceeds 1 and nothing is proved. The decided text is therefore stronger than the body, so it is corrected (rule: "if a decided fix is itself mathematically wrong, make the correct fix and record why"). |
| `sections/abstract.tex` | "…on a random set of inputs of density below $1/4$…" → "…of **fixed** density below $1/4$…" | This sentence was added by p2-front (P2F-04 allows it). Its gap $d-O(\log d)$ for every $p<1/4$ is `prop:algstat:parity`(iv), which holds for fixed $p$ of small complexity $K(p)$, as $d\to\infty$. For a density that depends on $d$ with $K(p)$ of order $d$, the set-sophistication bound $2\log d+K(p)+\kappa$ uses up the gap. "Fixed" brings in both conditions. The abstract is now 1744 characters, under the limit of 1920. The source comment on line 1 records both qualifiers. |
| `sections/teacher.tex`, first paragraph | "…a window of $c=\lambda/n$ of more than three orders of magnitude at the example's sizes" → "…at the example's sizes **for $\kappa\le30$**" | The window ratio depends on the machine constant: 8453 at $\kappa=0$ and 3837 at $\kappa=30$ (`rem:teacher:numbers`). $c_{\rm hi}$ decreases in $\kappa$, so the claim holds for every $\kappa\le30$ but not for every $\kappa$ (P2F-04 raised this point for the abstract). The line break is unchanged. |
| `sections/app-setup.tex` | `\begin{remark}[the converse in (iv)]` → `[The converse in (iv)]` | Capitalisation, to match the other remark titles. |
| `sections/app-limits.tex`, l.75 | "a direct computation gives the held-out losses" → "a direct computation (code in the accompanying repository) gives…" | §A1/§A9 wording. The other bare "a direct computation" sentences (`limits.tex` l.22 and l.65, `app-limits.tex` l.116, `app-teacher.tex` l.125) sit inside or point to paragraphs that already carry the repository pointer, so they are left unchanged. Changing the main-text ones would risk the page layout. |

After the edits the full build gives the same layout: 57 pages, section start pages unchanged, references from p. 29, Appendix A from p. 31.

---

## 1. Fatal and major issues: decided fix in place and correct

All of them were checked in the current `.tex` files (file and label given). "OK" means the decided text, or an equivalent wording that the group logged, is present and is correct against the source notes.

### p2-front (3 fatal, 17 major)

| id | where | status |
|---|---|---|
| P2F-01 (fatal) | `discussion.tex` ¶"The gap to realistic errors" | OK: exact §F37 sentences ("in the parity instance … in two ways …; Whether any window survives for structured errors in general is open"). The LessWrong quotation is replaced by the author's-voice sentence. |
| P2F-02 (fatal) | `tab:intro:claims`, vertex row | OK: exact §F30 row-3 text. |
| P2F-03 (fatal) | `intro.tex`, Limits bullet | OK: "$(\lambda_n/n)(d+L_S)\to0$ along a sequence of instances". No bare "$\lambda_n/n\to0$" claim remains in either paper's Paper-2 files. |
| P2F-04 | `abstract.tex` | §F28 text present, plus the allowed algorithmic-statistics sentence. **Two qualifiers added in this check (§0).** |
| P2F-05 | intro Absorption bullet; Discussion ¶1 | OK: "for every fixed $\lambda>1$"; "longer than $\ell^*_\lambda$, a bound that does not depend on the data". |
| P2F-06 | intro informal theorem; Discussion ¶2 | OK. The §F29 teacher sentence is the informal theorem's conclusion (logged deviation 1 of p2-front, acceptable). The window is open, $2^{-m}<c<c_{\rm hi}$, and the numbers 0.199/0.274 match `tab:teacher:numbers` ($\delta_S=0$, stated). |
| P2F-07 | Discussion ¶"model–randomness split"; intro Split bullet | OK: "at most triply logarithmically"; "doubly logarithmic in the input length and at most triply logarithmic in $n$ and in the sampled randomness". |
| P2F-08 | `bib/core.bib`; intro; discussion | OK: `hanni2026lesswrong` dropped; 0 citations; the grokking-note quotations are verified verbatim (note l.41, 61, 65). |
| P2F-09 | `bib/core.bib`; intro | OK: `hanni2026request` dropped; the decided sentence on the second question; Eisenstat "(personal communication; see also \citet[Section~7.3]{…})" (Section 7.3 = `sec:ex:eisenstat` in Paper 1's `main.aux`). |
| P2F-10 | `bib/core.bib` | OK: `hanni2026notes` and `hanni2026grokking` exactly as §G2. |
| P2F-11 | intro ¶"Relation …"; `related.tex` | OK: the "Prior work" paragraph is in §2; P2M-20 wording; no abstract hedges; open problem (8) and the acknowledgements' literature clause are deleted. |
| P2F-12 | `main.tex` | OK: `\sfirecordfalse` with a one-line comment; `app-verification.tex` unchanged (mtime 16:59); no `app:verif` reference outside it. |
| P2F-13 | `preamble.tex` l.121–123 | OK: exact §A2.4 lines (see §4). |
| P2F-14 | intro | OK: arrangement sentence; table header "Question & Answer & Where"; caption exact (§A11); answers Yes/No/In part; no third person. |
| P2F-15 | `discussion.tex` | OK: Acknowledgements and Code and data are byte-identical to §A4 (checked by script). |
| P2F-16 | `bib/core.bib`; intro | OK: `claude2026whatfollows` per §G2. Cited once with `[Section~8]` in the intro, then "the earlier report"; at most one citation per file. |
| P2F-17 | all Paper-2 files (phase 4) | OK: all 23 pinpoints match Paper 1's current `main.aux` (rebuilt 22:02, no Paper 1 source changed since). Checked by script, including Theorem 3.11 = `thm:setting:weakuniversal`, Section 9.1 = `sec:comp:time` and Section 7.3 = `sec:ex:eisenstat`. |
| P2F-18 | `discussion.tex` §10.1 | OK: one numbered list that `\cref`s all five questions (`q:absorb:shared`, `q:teacher:open`, `q:limits:open`, `q:related:open`, `q:algstat:lsc`); (8) deleted; "we expect" with no "presumably". Paper 2 has no conjecture. |
| P2F-19 | `main.tex`; intro | OK: input order as §D2; informal theorem with all hypotheses (uniform inputs, product-form error set, $p<0.056$, incompressible rule, population objective, $\lambda=cn$ in a window); 5-bullet contributions list. Length: see §5. |
| P2F-26 | Discussion ¶"Relation to other work"; `related.tex` | OK: tempered versus power-prior posterior as in §F46. |

### p2-body (3 fatal, 18 major)

| id | where | status |
|---|---|---|
| P2B-01 (fatal) | `setup.tex`, after `lem:setup:coding` | OK: exact §F31. Checked: (Dom) gives $\ell_U-\log U(D)\le\ell(\pi)-\log P_\pi(D)+\ell_U+\kappa_0$. |
| P2B-02 (fatal) | `cor:absorb:nouniversal`; §4 opening; `rem:absorb:wyeth`(ii) | OK: exact §F32 ("in $\Hcl{\times}$, and in every product class that contains … programs of length at most $d+2\log d+\kappa$ for the parities"). |
| P2B-03 (fatal) | `prop:limits:plain`(b); `rem:limits:schedule` (twice); `app-limits.tex` proof (b) | OK: exact §F34. The proof gives the $\lambda_n=n^{0.9}$ arithmetic ($n^{-0.1}\ge2^{-10}=p$ for $n\le2^{100}$), as in the lead editor's §V check. |
| P2B-04 | `thm:absorb:absorption`(a),(c); `thm:split:shared` | OK: "$U(o)>0$"; "Let $\lambda>1$ be fixed"; "With $\lambda=cn$, (c1) and (c3) are not available; (a) and (c2) hold at each $n$." |
| P2B-05 | `teacher.tex`, paragraph after the theorem | OK: exact §F35, with the open window. |
| P2B-06 | `split.tex` (opening, (iii), title of 7.3, l.49, Eisenstat, after `thm:split:shared`) | OK: every §F36 sentence. |
| P2B-07 | `prop:limits:plain`(a); `cor:teacher:fulltable`; `prop:limits:noident`(ii) | OK: numbers are outside the statements, with "(an illustration)" for $\kappa=0$; the $d=20$ windows are printed open. No computed number remains inside a theorem-like statement (scripted scan; the only remaining number is the decided $\lambda_n=n^{0.9}$ example of §F34). |
| P2B-08 | `absorb.tex` l.5 | OK: exact §F38 sentence and footnote, with no name and no citation. |
| P2B-09 | setup, absorb, teacher, limits | OK: every LessWrong citation is re-sourced. "The example was chosen to favour the proposal" is in the author's voice. |
| P2B-10 | setup objects table; end of `rem:absorb:wyeth` | OK: `\citet[note on Solomonoff function induction]{hanni2026notes}`. |
| P2B-11 | teacher, limits, split, algstat, absorb, setup | OK: retitles as §A6; no third person (source grep with comments, citations, `\status` and `\src` removed). One verbatim quotation per section (setup, absorb, teacher, algstat, intro), each checked against the grokking note. |
| P2B-12 | `related.tex`, `algstat.tex`, `app-algstat.tex`, `setup.tex` | OK: §A8 items. |
| P2B-13 | all | OK: 47/47 statuses rendered (§4). |
| P2B-14 | five questions | OK: `question` environments with the same labels. |
| P2B-15 | see P2F-17 | OK. |
| P2B-16 | structure | OK: §2 is Related work in prose with the labels kept; `computable.tex` = §9; appendix titles follow "Proofs for Section N (…)"; "the trick" does not occur in the PDF. |
| P2B-17 | `teacher.tex` "Notation for this section" | OK. $j_g$ and $\varrho$ stay in the statement (logged deviation 2: the statement uses them; correct). |
| P2B-18 | all | OK: at most one `claude2026whatfollows` citation per file. |
| P2B-37 | `cor:teacher:fulltable`(ii) and its proof | OK: exact §F44 hypotheses; the proof uses them (`app-teacher.tex` l.146). |
| P2B-38 | parenthesis after `prop:limits:envelope`; `app-limits.tex` l.139 | OK: exact §F45. The appendix only states the deficiencies (about 5,300 and 1,300 bits). |
| P2B-39 | `setup.tex`; `rem:related:posteriors` | OK: exact §F46. |

Not fixed: none.

---

## 2. Abstract, introduction and discussion against the body

Each claim was checked against the body statement it summarises, with the same scope and the same hypotheses.

* **Abstract.** Absorption in every class containing its own mixture (`thm:absorb:absorption`, `rem:absorb:examples`) and no universal private-randomness hypothesis (`cor:absorb:nouniversal`): OK. The teacher's theorem: hypotheses OK (uniform inputs, $p<0.056$, product form, incompressible rule, population objective, $\lambda=cn$ with $c$ in a window); **the error-label clause lacked the large-rule condition and is fixed (§0).** "The window needs $\lambda$ proportional to $n$; density and description length … do not suffice" (`prop:limits:plain`, `rem:limits:schedule`, `prop:limits:envelope`): OK. Samplers versus fill-ins (`thm:split:lambda1,private,shared`): OK. Algorithmic statistics: **"fixed" added (§0)**; otherwise OK (`prop:algstat:parity`(iii),(iv)).
* **Introduction.** ¶1–2: the quoted proposal and the example (100-bit model, $2^{-10}$ error fraction, 10,000 bits, three hypotheses, the note's two questions) are all in the grokking note (l.41, 46, 55–65): OK. Conventions: OK. Informal theorem and window numbers: match `thm:teacher:main` and `rem:teacher:numbers` (same closed right end as the body; the identification conclusions are stated on the open interval): OK. Contributions: all five bullets match their cited statements (the bounds $[2^{-2\log(t_n+1)-\kappa},2^{k+\delta^*}]$, the fill-in threshold $\lambda(k+\delta^*)/(\lambda-1)$ from `rem:split:reading`, "almost a third / a quarter", "(for the split, one that contains the sampler)"): OK. `tab:intro:claims`: all ten rows match their cited results (Version 1 $\lambda\in(9.77,58.0]$; the hull row; the slope row "every flip rate below $1/4$"): OK. ¶"Relation …" and ¶"Scope": OK ($10^{11}$/$10^9$ samples match `cor:teacher:sampled` and App C.5).
* **Discussion.** ¶1–5 match `thm:absorb:absorption`, `thm:teacher:main`, `rem:limits:schedule` ("by at most $c\,\ell(\pi)$ bits per sample"), `prop:limits:noident`, `prop:limits:rateblind`, `lem:limits:robust`, `prop:limits:envelope` ("about a third" at $\kappa=0$), `prop:limits:separable`, `thm:split:lambda1`, `rem:split:reading`, `rem:split:siprograms` and `rem:related:nn`. The open problems match the five questions. OK.
* **Also checked:** the teacher section's opening (window width): **qualifier added (§0)**. The related-work paragraphs: OK.

---

## 3. Spot-check of 27 claims against the source notes

Sources: S = `research/tracks/steeper/notes-final.md` (with `checks/`), C = `research/tracks/context/notes-final.md`. Every claim checked agrees with its source in numbers, hypotheses and status (proved, computed or illustration).

| # | place | claim | source | result |
|---|---|---|---|---|
| 1 | §2 `rem:related:t5` | earlier $d=20$ window $\approx(1-H(p))/d\approx0.049$; rigorous $c_{\rm hi}=0.01139$ at $\kappa=0$ | S §6 l.1207; c3 out l.11 (1.139e-02) | OK |
| 2 | §3 `lem:setup:basic` | (i)–(iii) | S Lemma 1.1 | OK, proved |
| 3 | §3 after `lem:setup:coding` | (Dom) member attains the best two-part code length up to $\ell_U+\kappa_0$ | S Lemma 1.6 and the paragraph after it; Thm 1(a) | OK |
| 4 | §4 `thm:absorb:absorption`(a) | $\ell\le(\lambda\ell_U+\kappa_0)/(\lambda-1)$; no MAP of length $\ge L$ if $\lambda>(L+\kappa_0)/(L-\ell_U)$ | S Thm 1(a) | OK |
| 5 | §4 `prop:absorb:price` | $\min(\lambda,2)(K(\beta\mid k)-\kappa)$; excess $(\min(\lambda,2)-1)k-2j-(\lambda+2)\kappa$ w.p. $1-2^{-j}$ | S Prop 1.7 | OK |
| 6 | App B.3 | pricing example $2.5431<2.5850$ | S Prop 1.3 (c2(a)) | OK, computed |
| 7 | §5 `rem:teacher:numbers` | window $(9.54\cdot10^{-7},8.06\cdot10^{-3}]$ (ratio 8453), $\kappa=30$: $3.66\cdot10^{-3}$ (3837) | S §2.4 Numbers | OK |
| 8 | §5 `tab:teacher:numbers` | all four rows ($u$, $\ell$, $I$, $L_S-K$, $e$) | S table l.541–546 | OK |
| 9 | §5 `rem:teacher:numbers` | $m=24$: $e\le0.065$; (iii) for $c<0.99418\cdot2^{-m}$ ($0.98914$ at $\kappa=30$); $e\ge\frac12$ for $c\le0.937\cdot2^{-m}$ ($0.888$); about 6% band | S l.548–557; c7_run2 out l.78, 82 | OK |
| 10 | §5 `rem:teacher:hanni` | rates $1.1185\cdot10^{-6}$, $8.989\cdot10^{-3}$; MDL switch $n\approx8.94\cdot10^5$; Version 1 $\lambda\in(10,100)$ | S §2.1 | OK, computed |
| 11 | §5 | $c_{\rm hi}>0$ iff $p<0.0560$ at $B=\infty$ | S l.466 | OK |
| 12 | §5 `cor:teacher:fulltable` | (ii) hypotheses $G_1>H(p)$, $N(G_1-H(p))>d+\kappa_g+\log(N+1)$; $d=20$ windows $1.19\cdot10^4$ and $6456$ | S Cor 2.5 | OK (printed open, per §F42) |
| 13 | §5/App C.5 | sampled data: $9.2$ bits at $10^{11}$, $0.9$ at $10^{13}$; at $10^9$: $\ell\le d+113.9$, $e\le0.284$ | S Cor 2.7; c3 out l.104 | OK |
| 14 | App C.6 `ex:teacher:version1` | $L_S=115.58$; $c_{\rm hi}=5.803\cdot10^{-3}$; $\lambda\in(9.77,58.0]$; $\ell\le d+47.8$, $I\le65.0$; (iv) threshold $6.917\cdot10^{-4}$; (e) vacuous | S Ex 2.7a | OK. The printed $0.321$ (S: $0.31$) is p2-body's logged deviation; the arithmetic $6\sqrt{82.71\ln2/(2\cdot10^4)}=0.321$ is confirmed |
| 15 | App C.7 `prop:teacher:concentration` | "$cn\ge1$"; $-1000+241.7=-758.3$; $\hat L'=241.7$, $\epsilon'=1.0933\cdot10^{-3}$ | S Prop 2.8 | OK (§F39) |
| 16 | §6 `prop:limits:plain`(a), App D.1 | fraction $9.6\cdot10^{-24}$ ($2^{90}=1.238\cdot10^{27}$ error inputs, $11{,}853$ exceptions) | S Prop 2.9(a) | OK; arithmetic re-checked |
| 17 | §6/App D.1 (b) | $e\ge0.649$ at $10^{13}$ ($\lambda=1$), $0.734$ at $10^{15}$ ($\sqrt n$); the $n^{0.9}$ example | S Prop 2.9(b); DECISIONS §V | OK |
| 18 | §6 `prop:limits:envelope` | $j=13$: 10,418 bits, $c_{\rm env}=1.64\cdot10^{-5}$ = 31% (25%), $e_1\ge0.545$; $j=11$: 47%, $e_1\ge0.862$ | S Prop 2.17 table | OK; $\ln17.19/\ln8449=0.315$ |
| 19 | §6 `lem:limits:robust` | $\alpha_0,\beta_0$; $d_0=49/169$ (3-bit), $450/1005$ (6-bit) | S Lemma 2.11a and table | OK |
| 20 | App D.3 `prop:limits:guard` | $\rho_\sigma=1.2226\cdot10^{-2}$, $\rho_G=1.8103\cdot10^{-4}$; switch at $3.2032\cdot10^{-4}$ | S Prop 2.13 | OK |
| 21 | App D.5 | ladder: deterministic tie rules make exponentially many mistakes; uniform $\lambda\to\infty$ posterior makes $O(d^2)$ Gibbs mistakes | C Thm 3.11, Rem 3.13 ($d+d^2\ln2$) | OK |
| 22 | §7 `thm:split:lambda1` | odds in $[2^{-2\log(t_n+1)-\kappa},2^{k+\delta^*}]$; $i_n\le\lceil\log(18n)\rceil$ for $\beta\ge1/3$; hashing 32–143 bits | S Thm 3, Lemma 3.2′ | OK |
| 23 | §7 `thm:split:private`, `rem:split:reading` | (i)–(iv); fill-in threshold $\lambda(k+\delta^*)/(\lambda-1)$ | S Thm 4 and reading | OK (threshold derived from (i) and (iii)) |
| 24 | App E.6 `ex:split:noisyparity` | $d=12$, 509 flips, $\ell=24.2$, threshold $1.315$ ($1.311$ from rounded values); illustration, not an instance | S Ex 3.4 | OK |
| 25 | §8 `prop:algstat:parity`, App F `tab:algstat:numbers` | (i)–(iv) hypotheses; all 8 rows | S Prop 3.8; c7_run2 out l.44–71 | OK (upper ends rounded down, as the caption says) |
| 26 | §9 `prop:related:computable`, `prop:related:computability` | (a)–(c); computability of the $\lambda$-MAP is a question | S Props 4.4, 4.5 ("not settled") | OK |
| 27 | App A `rem:setup:hullconverse` | counterexample $\{(0,1),(10,0),(20,0)\}$ | S Lemma 1.2, correction | OK |

---

## 4. arXiv readiness

* **§A2.5.** The lead editor's `extract_status.py`, run as a copy that writes its JSON to my scratchpad so the editor's files are unchanged: Paper 2 has **59 `\status` calls, 17 plain, 42 non-plain, 0 outside an environment, 0 inside a table float**. The 42 live non-plain labels and the 5 kept as comments in `related.tex` (`rem:related:{posteriors,mdl,cold,t5,new}`) are the 47 rows of `status-rendering.md`. Each has a "rendered as" entry in `log-p2-body.md` §2, and I checked the rendering in the text for each one cited in §1–§3. The `\src` grep for slides, T5, request, draft and known finds 16 "T5" notes. Every T5 result they name appears in `app:related:t5`; no note names the slides, the request or the draft. The redefinition is in `preamble.tex` l.121–123. After it, `pdftotext main.pdf | grep -E '\[(proved|computed|conjecture|known|proof sketch|refuted|remark)'` returns nothing.
* **§A5 grep on the PDF** (final build, 22:15). The only hits are the footnote's "independent AI referees" and formula symbols: $E_1$, $\mathbb R^2$, $S_1$, $S_2$, $s_0$–$s_2$, $e_1$, parts (c1)–(c3), $c2^m$, $h_0,h_1$. The DOI "s10994-…" also matches. On the sources, with comments, `\status` and `\src` removed, the grep finds only the label `rem:absorb:wyeth` and the footnote. "personal communication" occurs 3 times, each for Sam Eisenstat. "Hänni" occurs only in the author line and in author–year citations. The terms "the trick", "presumably", "his/he", script names and `research/` do not occur.
* **§B.6.** `grep -c -i wyeth` on the PDF gives 0. The source grep (non-comment lines, excluding the label and `app-verification`) is empty.
* **Proof sketches.** Paper 2 has no "proof sketch" status, and the PDF contains no theorem-like item headed as a sketch. Main-text results carry "Proof idea" with full proofs in the appendices.
* **Conjectures and questions.** There are no conjectures. The 5 open points are `question` environments with precise questions (§A10), and all 5 are `\cref`d in the Open problems list.
* **Computed numbers.** None sits inside a theorem, proposition, lemma or corollary (scripted scan; see P2B-07). The $\kappa=0$ numbers say "the machine constant set to 0 (an illustration)" or sit under a caption that says so. The remaining bare "a direct computation" sentences sit inside or point to paragraphs with the repository pointer (§0).
* **Bibliography (§G).** `hanni2026request` and `hanni2026lesswrong` are dropped. `hanni2026notes`, `hanni2026grokking`, `claudeSFI2026fundamentals`, `claudeSFI2026steeper` (with subtitle, logged deviation 3 of p2-front) and `claude2026whatfollows` are as §G2. Also as §G2: `hoeffding1963probability` (301, DOI), `barzdin1972prediction` (pages), `ville1939etude` (series, number), `grunwald2007suboptimal` (2–3, DOI) and the five DOIs of P2X-36. `diff paper/bib/core.bib paper-steeper/bib/core.bib` is empty. 34 references are printed; 0 undefined citations.
* **Title page (§A4).** The author line is `\author{Kaarel H\"anni\thanks{…}}`, and the footnote is byte-identical to §A4 with `\citet{claudeSFI2026fundamentals}`. `\hypersetup` is set (pdfinfo shows Title and Author). The TOC is kept, with no `\newpage`.
* **Acknowledgements and Code and data.** Byte-identical to §A4 (Paper 2).
* **Structure (§D).** Related work is Section 2. The introduction contains the conventions (before the contributions), an informal theorem, a 5-bullet contributions list and the relation to the author's notes. The Discussion ends with "10.1 Open problems". The appendix titles follow the decided pattern. The verification appendix is off.

---

## 5. Full build and page counts

`cd paper-steeper && flock /tmp/claude-0/paper-build-sfi.lock ./build.sh` (last run 22:15, after all edits):

```
41 entries; 0 title conflicts: []
LaTeX errors: 0
Undefined references: 0
Undefined citations: 0
Multiply defined labels: 0
Overfull hboxes >10pt: 0
Pages: 57
```

The only overfull box is 1.84pt, in the exact Code and data text of §A4. There are no "Label(s) may have changed" warnings.

**Page counts**, measured from word positions in the PDF (text block 76–720pt):

| part | pages | §C budget / cap |
|---|---|---|
| title, abstract, TOC (to §1 on p. 2) | 1.43 | 1.5 |
| §1 Introduction | 2.86 | 2.5 (±0.5) |
| §2 Related work | 1.21 | 1.5 |
| §3 Setting | 2.76 | 2.5 |
| §4 Absorption | 3.53 | 3 (over by 0.53) |
| §5 Teacher's mistakes | 5.21 | 5 |
| §6 Limits | 3.30 | 3.5 |
| §7 Split | 2.70 | 2.5 |
| §8 Algorithmic statistics | 2.22 | 2 |
| §9 Computable classes | 0.85 | 0.5 |
| §10 Discussion, open problems, acknowledgements, code and data | 1.92 | 2 |
| **main text (pp. 1–28)** | **28** | **cap 27: exceeded by 1 page** |
| references | pp. 29–31 (about 2.4) | — |
| App A / B / C / D / E / F / G | 1.97 / 3.67 / 7.00 / 5.12 / 4.18 / 2.82 / 1.62 | 1.5 / 3.5 / 7.5 / 4.5 / 4 / 2.5 / 2 |
| **appendices (pp. 31–57; p. 57 is filled to 0.74)** | **about 26.4** | **cap 27: met** |
| **total** | **57** | **cap 57: met** |

**Open item (needs the lead editor).** The main text fills p. 28 completely, so the references start at the top of p. 29. About one page (≈45 lines) must go from §1–§10 to meet the cap of 27. This cannot be done by moving material to the appendices: they have only about 0.6 page of room under their cap, and the total is exactly at its cap. I did not make the cut, because it is not a minimal edit and §A11 keeps `tab:intro:claims` (about 0.55 page) in the introduction. Options, roughly 0.2–0.6 page each:
* shorten `tab:intro:claims` to the rows that are not repeated in the contributions list;
* shorten the "Objects from the companion paper" table in §3;
* move `rem:absorb:reading` and `rem:teacher:hypotheses` to their appendices, keeping one sentence each (this uses the appendix room);
* trim §9 to its 0.5-page budget by moving `rem:related:nn` to App G;
* accept 28 pages, since the total cap holds.

---

## 6. Notes for Paper 1 (not edited; outside this paper)

* `paper/sections/steeper.tex` (§F20 text) has the same error-label sentence that I qualified in Paper 2's abstract ("…knows the parity and gives the erroneous labels far less probability than a memoriser does"). For it to match `thm:teacher:main`(e), it needs "when the error rule is large" (see §0).
* The extraction script reports one Paper 1 `\status` "outside an environment", at `app-examples.tex:99`. That call is inside `\begin{question}…\label{conj:ex:raw}`, and the script's environment list has no `question`. This is an artefact of the script, not a stray call.
