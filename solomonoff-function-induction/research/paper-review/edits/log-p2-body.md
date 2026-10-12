# Edit log: group p2-body (Paper 2, phases 1 and 2)

Files edited (all in `paper-steeper/sections/`): `setup.tex`, `absorb.tex`, `teacher.tex`, `limits.tex`, `split.tex`, `algstat.tex`, `related.tex` (rewritten as §2 Related work), the new `computable.tex` (§D2), and `app-setup.tex`, `app-absorb.tex`, `app-teacher.tex`, `app-limits.tex`, `app-split.tex`, `app-algstat.tex`, `app-related.tex`. No other file was edited. No git command was run. No label was renamed or deleted.

Isolated builds: every pair compiles with `./test-section.sh` (0 errors, 0 undefined citations, 0 overfull boxes): `setup app-setup`, `absorb app-absorb`, `teacher app-teacher`, `limits app-limits`, `split app-split`, `algstat app-algstat`, `related app-related`, `computable app-related`. A scratch build of all eight sections and seven appendices together (in the scratchpad, not in the paper folder; `\status`/`\src` redefined to empty as in the final version) has 0 errors, 0 undefined references (apart from the stubs for `sec:intro`, `sec:discussion`), 0 multiply defined labels and 0 overfull boxes. The §A5 grep on its `pdftotext` output gives only hits inside formulas ($s_0$, $e_1$, $c_1$, (c1)–(c3)); `grep -c -i wyeth` gives 0.

---

## 1. Issues of `edits/p2-body.json`

### Fatal

* **P2B-01** (F31). `setup.tex`, proof idea after `lem:setup:coding`: last two sentences replaced by the exact text of §F31 ("What separates the two kinds of class is whether one member attains the class's best two-part code length … In the product class no member does (\cref{cor:absorb:nouniversal})"). Checked: (Dom) gives $\ell_U-\log U(D)\le\ell(\pi)-\log P_\pi(D)+\ell_U+\kappa_0$.
* **P2B-02** (F32). `absorb.tex`, `cor:absorb:nouniversal`: "(Dom) fails in every product class" replaced by "(Dom) fails in $\Hcl{\times}$, and in every product class that contains, for every $d$, programs of length at most $d+2\log d+\kappa$ for the parities on $\{0,1\}^d$". First paragraph of §absorb: "show that the product class $\Hcl{\times}$ contains no such hypothesis"; `rem:absorb:wyeth`(ii): "unavailable in the product class $\Hcl{\times}$".
* **P2B-03** (F34). `limits.tex`, `prop:limits:plain`(b): last sentence replaced by the §F34 text ("In particular $e(\hat\pi)\ge1-2^{-B}-o(1)$ whenever $(\lambda_n/n)\hat L\to0$ and $\hat L/n\to0$, along any sequence of instances … for $n\le2^d$"). `rem:limits:schedule`: both occurrences of "every schedule with $\lambda_n/n\to0$ …" replaced by "every schedule with $(\lambda_n/n)(d+L_S)\to0$ along a sequence of instances eventually reproduces them (\cref{prop:limits:plain}(b))". `app-limits.tex` proof of (b): "If $\lambda_n/n\to0$, both terms … tend to 0" replaced by the corrected condition, plus the arithmetic for $\lambda_n=n^{0.9}$ ($\lambda_n/n=n^{-0.1}\ge2^{-10}=p$ for $n\le2^{100}$, so the bound says nothing for any $n\le2^d$), which is the lead editor's check in §V.

### Major

* **P2B-04** (F33). `thm:absorb:absorption`(a) "For every observation $o$ with $U(o)>0$"; (c) begins "Let $\lambda>1$ be fixed."; after (c3): "With $\lambda=cn$, (c1) and (c3) are not available; (a) and (c2) hold at each $n$." `thm:split:shared`: "For every observation $o$ with $U(o)>0$" (covers (i) and (ii)). Proofs in `app-absorb.tex` (a) and `app-split.tex` (i) use $U(o)>0$ explicitly. `rem:absorb:wyeth`(i) now says "for fixed $\lambda$ it reproduces a deterministic teacher's errors".
* **P2B-05** (F35). `teacher.tex`, paragraph after `thm:teacher:main`: replaced by the §F35 text ("… gives the erroneous labels average probability at most $1-u+\gamma_g+2^{-g}$ (at most $0.2$ to $0.29$ at the example's sizes, against $1$ for the memoriser and $2^{-10}$ for the good model), when the error rule is large compared with the information budget"), window "$2^{-m}<c<c_{\rm hi}$" (open). Part (i) of the theorem stays closed at $c_{\rm hi}$ as allowed.
* **P2B-06** (F36, all sentences). `split.tex`: section opening replaced (the request quotation removed; "A second question of the author's notes is whether a steeper prior prefers …"; "up to explicit factors: $2^{k+\delta^*}$ in one direction and $2^{2\log(t_n+1)+\kappa}$ in the other …"; "At fixed $\lambda>1$ with private randomness samplers beat fill-ins (not necessarily $\nu$ itself; \cref{rem:split:reading})"); `thm:split:lambda1`(iii) "with a lower end that depends on the sampled randomness only through $t_n$"; `sec:split:private` title "$\lambda>1$ with private randomness: samplers beat fill-ins"; old line 62 "with the dependence on the sampled randomness only through $t_n$"; Eisenstat "(personal communication; see also \citet{claudeSFI2026fundamentals})"; paragraph after `thm:split:shared` replaced by the P2M-11 text of §F36. (F36's "of the author's notes" is kept as decided, without citation; the question is stated in the author's request and the author says he has a note on it; the grokking note asks the related model-plus-data-split question.)
* **P2B-07** (§A9, F42, F34). `prop:limits:plain`(a): the fraction $1-9.6\cdot10^{-24}$ moved after the statement ("For instance, … with the machine constant set to $0$ (an illustration), a direct computation … shows that the exceptions in (a) are a fraction at most $9.6\cdot10^{-24}$ of the error inputs"); "$d+L_S+O(\log d+\log m)$ inputs in total (the memoriser can name $s_0$ through $r$)". `cor:teacher:fulltable`: $d=20$ window moved after the corollary, printed $(1,1.19\cdot10^4)$ and $(1,6456)$ (also in App C: $(1,11945)$, $(1,6456)$). `prop:limits:noident`(ii): losses moved after the statement as "For instance, for the three hypotheses …, with the machine constant set to $0$ (an illustration), a direct computation gives …" (now in App D, see moves).
* **P2B-08** (F38). `absorb.tex` opening: exact §F38 sentence with \citep{gacs2001algorithmic,vereshchagin2017algorithmic} and the exact footnote without citation or name; the author's note paraphrased without quotation, cited to \citet{hanni2026grokking}.
* **P2B-09**. Every citation of `hanni2026lesswrong` in my files re-sourced: setup (proposal wording, $\lambda=cn$ remark, convex-hull observation) → `hanni2026grokking`; absorb footnote → no citation (§B.3); `rem:absorb:wyeth`(ii) → `hanni2026grokking` (verbatim, checked against `research/prior/hanni-grokking-a-notion.md`); teacher (two versions of the example; "Maybe I'm just failing …") → `hanni2026grokking`; `rem:limits:schedule` → "as anticipated in \citet{hanni2026grokking}"; limits "cherry-picked" → author's voice without quotation marks: "The example was chosen to favour the proposal, though it is not contrived". Remaining citations in my files: 0.
* **P2B-10**. Grokking-note quotations and paraphrases cite `hanni2026grokking`; the "computably samplable" passages (setup objects table, last paragraph of `rem:absorb:wyeth`) cite `\citet[note on Solomonoff function induction]{hanni2026notes}`.
* **P2B-11** (§A6). Retitles: subsection `sec:teacher:hanni` and `rem:teacher:hanni` "The three-hypothesis calculation"; `rem:teacher:numbers` "Numbers for the running example"; `cor:teacher:sampled` "Finite samples"; `ex:teacher:version1` "The total-bits version of the example"; "H\"anni's sizes" → "the example's sizes" throughout; limits companion pinpoint "[the proposition on unseen simple properties, with no logarithmic term]". All third-person references removed (grep for `H\"anni`, `his`, `he` in my files: 0 outside comments). Quotations: at most one per section, verbatim: setup "a higher coefficient on the length of the program than on the likelihood terms"; absorb (in `rem:absorb:wyeth`(ii)) "I don't see how to write down a universal hypothesis that gets good loss here"; teacher "Maybe I'm just failing to construct the right `universal hypothesis' for this example?"; algstat "pretty much just 1 bit paying for 1 bit"; none in limits, split, related, computable. `rem:split:reading` "This is the split asked for in \cref{sec:intro}"; `rem:algstat:reading` in the author's voice ("as the note \citep{hanni2026grokking} anticipated for the function case").
* **P2B-12** (§A8). `rem:related:mdl` (now a prose paragraph): Grünwald–Langford by its title, Zhu–Srebro and Zhu–Ohannessian–Srebro at title/abstract level, P2M-20 sentence "We do not claim as new the qualitative finding that a bounded $\lambda$ fits the noise and that $\lambda$ must grow with $n$"; no hedges. `rem:related:posteriors`: §F46 text, SafeBayes sentences deleted. `rem:related:new`: "To our knowledge the following are new: …" minus the consistent-schedules item; "though our search was limited to abstracts", the weight-above-one item and the "We do not claim …" duplicate deleted. `q:related:open`: last sentence (full texts) and "presumably" deleted. `rem:algstat:restricted`: only the §A8 sentences plus "See also \citet{milovanov2016algorithmic}". `prop:algstat:coarse`: the Vereshchagin–Shen "presumably" sentence deleted. `setup.tex` l.48: the "reported to appear in MDL convergence theory" clause deleted (replaced by §F46). `rem:limits:schedule`: Zhu et al. at title level, P2M-20 wording.
* **P2B-13**. All 47 non-plain statuses rendered; see §2 below.
* **P2B-14** (§A10). `q:absorb:shared`, `q:teacher:open`, `q:limits:open`, `q:related:open`, `q:algstat:lsc` are now `question` environments with the same labels and precise questions; no "presumably" ("we expect that majority-like functions … give none"); the "looks within reach" sentence of `rem:limits:method` became `q:limits:open`(b).
* **P2B-15**. Companion results named by Paper 1's titles, each with a source comment `% P1: <label>` for phase 4: `prop:learn:freshnoise`, `prop:learn:perquery`, `cor:hist:H4` (setup); `thm:versions:chain`, `prop:versions:shared`, `rem:versions:sharedsize`, `q:setting:rpf` (absorb); `cor:learn:mistakes`, `prop:ood:hanni` (limits); `prop:versions:tape`, `thm:learn:merging` (split); `thm:comp:timebounded`, `prop:setting:computability`, `prop:nn:functionspace`, `rem:nn:bridge`/`q:nn:bridges` (computable); `rem:versions:hashing` ("a hashing bound"; app-split); `thm:comp:ladder`, `rem:comp:uniformties` (app-limits); `thm:hist:representation`, `cor:hist:H4`, `thm:setting:universal` (app-absorb); `cor:hist:H4` (app-split).
* **P2B-16** (§C, §D2). `related.tex` is now `\section{Related work}\label{sec:related}\label{sec:related:work}` in prose (paragraphs keep `rem:related:posteriors`, `rem:related:mdl`, `rem:related:cold`, `rem:related:t5`, `rem:related:new`; a new unlabelled paragraph "Algorithmic statistics"), and contains the introduction's "Prior work" paragraph (received, see §4). New `computable.tex`, `\section{Computable hypothesis classes}\label{sec:computable}\label{sec:related:computable}`, with `prop:related:computable`, the new `rem:computable:examples` (its former examples paragraph), `prop:related:computability`, `rem:related:nn`, `q:related:open`. `app-related.tex` retitled "Proofs for \cref{sec:computable} and the correspondence with the earlier report". Moves of the §C list and further moves for length: §3. "The trick" replaced throughout my files ("steeper selection"); `sec:limits` "Limits of steeper selection", `sec:limits:rules` "Which error rules defeat steeper selection", App D "Proofs for \cref{sec:limits} (limits of steeper selection)". All appendix titles follow "Proofs for \cref{…} (short title)", with `\texorpdfstring{\cref{…}}{Section \ref*{…}}` so the PDF bookmarks show the number.
* **P2B-17** (§D2). "Notation for this section" before `def:teacher:instance`: a two-column list of the symbols in the statement of `thm:teacher:main`. $\tau_B$, $\beta_B$ and $\Gamma_g$ are now defined at the start of App C and inlined in the main text ($G_j$, $\Lambda_1$, `lem:teacher:coding`, (e)). $j_g$ and $\varrho$ stay defined inside the statement of the theorem, because the statement uses them ((e) and (iii)); moving them to App C would make the theorem unreadable. The theorem stays in full.
* **P2B-18**. The long pinpoint `[section ``Simplicity and normativity from imitation'']` removed everywhere in my files (absorb, app-teacher ×4, related, app-related ×2); each section cites `\citep{claude2026whatfollows}` at most once, then "the earlier report". The intro's single `\citet[Section~8]{…}` is p2-front's.
* **P2B-37** (F44). `cor:teacher:fulltable`(ii) replaced by the exact §F44 text (hypotheses $G_1>H(p)$ and $N(G_1-H(p))>d+\kappa_g+\log(N+1)$; $\ell+NR$ notation); the proof in `app-teacher.tex` uses $\ell+NR$ and the two hypotheses explicitly.
* **P2B-38** (F45). `limits.tex`: parenthesis after `prop:limits:envelope` replaced by the exact §F45 text. `app-limits.tex` l.125 checked: it only states the deficiencies ($5{,}300$, $1{,}300$ bits) and does not claim that the theorem does not cover the rule; unchanged.
* **P2B-39** (F46). Exact §F46 text in `setup.tex` (after `def:setup:objectives`) and in the paragraph `rem:related:posteriors` of §2.

### Minor

* **P2B-19**. All script file names removed from my files (`c2_pricing_kink.py`, `c3_junta_window.py`, `c5_limits.py`, `c6_revision.py`, `c7_run2.py`, and "part (X), seed N"); replaced by "code in the accompanying repository" or "the script for \cref{tab:teacher:numbers}". "were re-run from scratch copies and reproduce" → "reproduce" (App C, App G). The former subsection C.8 "Computations" is folded into the paragraph "Numbers" of App C, which carries the label `app:teacher:computations`.
* **P2B-20** (F39). `prop:teacher:concentration`: "Let $\lambda=cn$ with $cn\ge1$"; App C: "$-n\epsilon+(J_g+\epsilon)/c=-1000+241.7=-758.3$" (checked: $J_g=0.023167$ at $\kappa=0$).
* **P2B-21** (F41). `rem:absorb:wyeth`(i) threshold $\ell^*_\lambda=\ell_U+(\ell_U+\kappa_0)/(\lambda-1)$ for samplers; (iii) "So restricting to private randomness is not free at $\lambda=1$ when compared with $\MF$" (no quotation marks). `rem:absorb:reading`: "a model of millions of bits is longer than $\ell_U$ for any reasonable reference machine".
* **P2B-22** (§E). Programs $\pi$: $2^{-\lambda\ell(\pi)}$ in `rem:split:siprograms`, $\pi_w$, $\pi_s$ in App E; point mass $\mathbf 1_w$ (App E); `lem:limits:robust` constants $\alpha_0,\beta_0$ (statement and proof); App F index $v$ ($A_v$) and $p=h'/2^{e'}$; `prop:algstat:coarse` integer $r_D$ (threshold $2^{-r_D}$; no separate $\rho_0$ was needed); subclass constant $\kappa_2$ (App G); the constant in `rem:absorb:condsemi` is $\kappa_{\mm}$ (it was $\kappa'$, which NOTATION reserves); simulation prefixes $\sigma,\sigma'$ (App E; also in `def:setup:class` and in the proof of `prop:limits:ood`, where the program for $b$ is now $q'$); App E canonical sampler renamed $\mathrm{lab}(x,b)$ to free $\sigma$; guard gain $g_G$; product index $j$ in `prop:absorb:history`.
* **P2B-23**. `prop:absorb:price`(iv) "(in the semimeasure convention)".
* **P2B-24**. `rem:related:nn`: "the bridge question of the companion paper, which the slides of \citet{vaintrobhanni2026nnbayes} motivate".
* **P2B-25**. "Objects from the companion paper" is now a five-row table (object, meaning) plus two sentences.
* **P2B-26**. `limits.tex`: "a window of a factor of about $8500$ ($\kappa=0$) or $3800$ ($\kappa=30$)".
* **P2B-27**. Rounding convention ("rounded to the nearest unit in the last digit") in the caption of `tab:teacher:numbers` and in `rem:teacher:numbers`.
* **P2B-28**. `rem:absorb:examples` titled "Classes with an absorbing member (proved in \cref{app:absorb:examples})" (environment unchanged); proof of `prop:related:computable` expanded into one item per lemma or theorem (property used, constant that changes); "By inspection" deleted.
* **P2B-29**. App F: "with … $t=2$ … and the least $g$ for which the range of $b$ is nonempty" ("best" dropped); `prop:algstat:parity`(iv) now prints $+2\kappa$ in the threshold for $j_d$ (this is what the proof gives: $\delta_S+I(\pi)+\dots+\kappa$ with $I(\pi)<d+\kappa$), so the $\kappa=30$ rows match the statement; App F text says every occurrence of $\kappa$ is set to $0$ or $30$; caption notes that the upper ends depend on $g$. F40 for (i): see §F below.
* **P2B-30**. Memoriser-regime table: $\kappa=30$, $c2^m=0.99$ printed "--" with the note "(iii) does not apply, since at $\kappa=30$ it needs $c<0.989\cdot2^{-m}$"; `rem:teacher:numbers` gives the $\kappa=30$ thresholds $0.98914$ and $0.888$ (source: `tracks/steeper/checks/c7_run2.out`). The table (former part (b)) moved to App C (§C allows it).
* **P2B-31**. `prop:limits:ood`(i): "a family of programs that answer $b(x)$ on $Q$ and run an arbitrary program of the class elsewhere (one for each such program) carries posterior mass exactly …; hence all programs with this behaviour together carry at least this mass".
* **P2B-32**. App B proof of `prop:absorb:pricing`(i): the density sentence added.
* **P2B-33**. App D envelope table: "The values of $e_1$ are computed from the relaxed bound for $c\ge2^{-m}$ at the end of the proof, with $K(S_1)\le k_1+2\log m+\kappa$."
* **P2B-34**. App C Version 1: justification now "$\hat L\ge\ell(\pi_g)\ge d-4-2\log d-\kappa$ by (D1), whose proof uses only the terms $2\log d+\kappa$ of $\Lambda_1$". With this justification the printed bound is $6\sqrt{(d-4-2\log d)\ln2/(2n)}=0.321$ at $\kappa=0$ (the old $0.308$ came from the $B=\infty$ value of $\Lambda_1$); the conclusion (excess > margin $0.224$) is unchanged. $d=13$ windows printed $(8,62.0]$ and $(8,39.7]$.
* **P2B-35**. App D proof of `prop:limits:guard`: "Adding back the risk $\log n_{\rm st}$ of ``none'' per context shifts all three objectives by the same constant and makes the risks nonnegative, so \cref{lem:setup:hull} applies."
* **P2B-36** (§E). Shared-coin law $\nulen$ of $F(x)=\omega_{|x|+1}$: `rem:absorb:why` and App B proof of `prop:absorb:price`(iii) (machine $\{(x,w,b):|w|=|x|+1,\ w_{|x|+1}=b\}$, as in Paper 1). Certificate length checked: inputs of length $\le k$ read tape bits up to $k+1$, so the gap is $\Kpad(k+1)+O(1)$, as printed, consistent with Paper 1's $\Kpad(d+1)$.
* **P2B-40**. Sentence after `cor:teacher:sampled`: "… it gives near-population constants only at about $10^{11}$ samples (…); coarser guarantees hold earlier (at $n=10^9$: $\ell\le d+113.9$, $e\le0.284$; \cref{app:teacher:sampled})"; `q:teacher:open`(c) rephrased accordingly.
* **P2B-41**. `def:teacher:instance` begins "Throughout this section and the next, $Y=\{0,1\}$."
* **P2B-42**. Sentence before $c_{\rm hi}$: "$J_g$ minus each piece of $\Phi_2$ is affine and increasing in $c$, so $\{c>0:J_g(c)\le\Phi_2(c)\}=(0,c_{\rm hi}]$ (empty if $c_{\rm hi}\le0$)". Checked for both cases of $t^*$.
* **P2B-43**. `prop:algstat:parity`(ii) "while $\rho^\times_D(\alpha)\le NH(p)$ for $\alpha\ge d+\kappa_g$ (the good model)", and the same in (iv).
* **P2B-44**. `limits.tex`: paragraph after `prop:limits:ood` replaced by the decided text; `rem:limits:schedule` "by at most $c\,\ell(\pi)$ bits per sample (the guaranteed excess)"; paragraph after `lem:limits:robust`: "is ever the unique optimum: at every $c$ it is beaten by the memoriser or beaten or tied by the coin" (the exact wording of `prop:limits:rateblind`(ii), rather than "matched").
* **P2B-45**. `rem:related:nn`: "deterministic parameter settings that reproduce the noisy labels".
* **P2B-46**. App D paragraph after the proof of `prop:limits:ood` replaced by the decided text.
* **P2B-47**. `rem:teacher:numbers`: "$e\le0.065$ ($\kappa=0$, $\delta_S=0$)".
* **P2B-48**. Last sentence of `thm:split:shared` replaced by the decided text; App E proof (end) rewritten in the same sense.
* **P2B-49**. `rem:split:reading`: "In particular no $\lambda$-MAP is a fill-in once $-\log\nu(D_n)>\lambda(k+\delta^*)/(\lambda-1)$." (Checked: fill-ins have $\ell\ge-\log\nu(D_n)-\delta^*$, $\lambda$-MAPs $\ell\le(\lambda k+\delta^*)/(\lambda-1)$.)
* **P2B-50**. `lem:setup:hull`(iv): "not on the open horizontal ray to the right of the least-$R$ vertex"; App A proof wording matched.

### §F statements of DECISIONS applied in my files

F31 (P2B-01), F32 (P2B-02), F33 (P2B-04), F34 (P2B-03, P2B-07), F35 (P2B-05), F36 (P2B-06), F38 (P2B-08), F39 (P2B-20), F40 (`prop:algstat:parity`(i): "lies on the sufficiency line, within $\delta_E+O(\log d)$, for $\alpha$ between $O(\log d)$ and $d+O(\log d)$"), F41 (P2B-21), F42 (P2B-07), F43 (`lem:setup:hull` → `rem:setup:hullconverse`; `prop:algstat:set` → `rem:algstat:near1`), F44 (P2B-37), F45 (P2B-38), F46 (P2B-39). §E Paper 2 list: P2B-22, P2B-36.

---

## 2. Status rendering (all 47 non-plain Paper 2 statuses of `status-rendering.md`)

The 17 plain `proved` statuses need nothing. The `\status`/`\src` calls stay in the sources. My files now contain 59 live `\status` calls, all inside environments (0 outside; checked with a read-only copy of the extraction logic). The five former remarks of `related.tex` are now prose paragraphs (§D2); to keep "outside env" at 0, their five `\status{…}\src{…}` records are kept verbatim as comments in the header of `related.tex` (they print nothing and are not counted by `extract_status.py`).

| # | label | rendered as |
|---|---|---|
| 1 | `rem:absorb:reading` | plain remark; "a model of millions of bits is longer than $\ell_U$ for any reasonable reference machine"; Poland–Hutter at abstract level |
| 2 | `prop:absorb:pricing` | plain proposition; the example value $2.5431$ is in App B.3 after the proof, "a direct computation (code in the accompanying repository) gives" |
| 3 | `rem:absorb:why` | plain remark; companion results by their titles with `% P1:` comments for phase 4 |
| 4 | `prop:absorb:price` | plain proposition; the computational confirmation is one sentence after the proof in App B.4 |
| 5 | `prop:absorb:history` | plain proposition (moved to App B.5); the computation is one sentence after the proof |
| 6 | `rem:absorb:wyeth` | printed title "Answer to the absorption objection"; items per §F41; quotation cited to `hanni2026grokking` |
| 7 | `prop:algstat:set` | plain proposition (moved to App F.1); the refuted reading is `rem:algstat:near1` after it ("The bounds do not show that $\lambda$ slightly above $1$ selects an approximately minimal sufficient statistic …"); one-sentence summary in §8 |
| 8 | `prop:algstat:coarse` | plain proposition (moved to App F.1); the "presumably that translation" sentence deleted |
| 9 | `prop:algstat:parity` | plain proposition; numbers in `tab:algstat:numbers` (App F.3), introduced by "A direct computation (code in the accompanying repository) produced the values", $\kappa=0$ rows "illustrations" |
| 10 | `rem:algstat:restricted` | plain remark; only the §A8 Hamming-ball sentences; Milovanov "see also" |
| 11 | `rem:algstat:reading` | plain remark in the author's voice with a citation; the verbatim "1 bit paying for 1 bit" is quoted once at the start of §8 (one quotation per section) |
| 12 | `lem:split:hash` | plain lemma; computation one sentence after the proof |
| 13 | `lem:teacher:sharpfloor` | plain lemma; computation described by content ("code in the accompanying repository"), no script name |
| 14 | `prop:limits:plain` | plain proposition; (a) computed fraction after the statement with "the machine constant set to $0$ (an illustration)"; (b) last sentence per §F34 |
| 15 | `rem:limits:schedule` | plain remark; §F34 replacements; Zhu et al. at title level; "as anticipated in \citet{hanni2026grokking}" |
| 16 | `prop:limits:envelope` | plain proposition; "So density and description length alone do not suffice: …"; parenthesis per §F45 |
| 17 | `prop:limits:rateblind` | plain proposition; numbers after `lem:limits:robust`, "a direct computation gives … with the machine constant set to $0$" |
| 18 | `lem:limits:robust` | plain lemma ($\alpha_0,\beta_0$); numbers after it as in 17 and in App D.2 |
| 19 | `prop:limits:separable` | plain proposition; computation one sentence in App D.3 |
| 20 | `prop:limits:guard` | plain proposition (moved to App D.3); numbers after the proof |
| 21 | `prop:limits:noident` | plain proposition (moved to App D.3); (i) cites Gneiting–Raftery (also in the main-text summary); (ii) losses after the statement as an example with the machine constant set to $0$ |
| 22 | `rem:limits:method` | plain remark (moved to App D.6); its last sentence now points to `q:limits:open`(b) |
| 23 | `prop:related:computable` | plain proposition in `computable.tex`; the examples paragraph is the new `rem:computable:examples` after it |
| 24 | `rem:related:cold` | prose paragraph "Cold posteriors" in §2 (label kept); Wenzel et al. at abstract level |
| 25 | `rem:related:nn` | plain remark in `computable.tex`; "the bridge question of the companion paper, which the slides … motivate"; "deterministic parameter settings that reproduce the noisy labels" |
| 26 | `rem:related:mdl` | prose paragraph in §2 (label kept); Grünwald–Langford by its title; Zhu et al. at title level; P2M-20 sentence |
| 27 | `rem:related:posteriors` | prose paragraph in §2 (label kept); §F46 text; SafeBayes sentences deleted |
| 28 | `rem:related:t5` | prose paragraph "The earlier report" in §2 (label kept); `\citep{claude2026whatfollows}` without pinpoint, then "the earlier report" |
| 29 | `rem:related:new` | prose paragraph "Novelty" in §2 (label kept): "To our knowledge the following are new: …" |
| 30 | `rem:setup:persample` | plain remark; "As noted in \citet{hanni2026grokking}, …" |
| 31 | `lem:setup:hull` | plain lemma (moved to App A.2) with "open horizontal ray"; the counterexample is the remark `rem:setup:hullconverse` after it; one-paragraph summary in §3; computation one sentence after the proof |
| 32 | `lem:split:ville` | plain lemma; Ville (1939) cited in the proof idea and App E.1; simulation one sentence in App E.2 |
| 33 | `lem:split:stream` | plain lemma (moved to App E.2); numbers after the proof ("A direct computation …"); summary paragraph in §7 |
| 34 | `prop:split:si` | plain proposition (moved to App E.4); (iii) cites Li–Vitányi; summary sentence in §7 |
| 35 | `thm:split:private` | plain theorem; Kakutani (1948) cited |
| 36 | `rem:split:reading` | plain remark; "the split asked for in \cref{sec:intro}"; fill-in threshold added |
| 37 | `thm:split:shared` | plain theorem; computation one sentence after the proof in App E.6 |
| 38 | `ex:split:noisyparity` | example titled "Noisy parity, full table: an illustration" (moved to App E.6); says it is not an instance of the theorem |
| 39 | `rem:teacher:hanni` | remark titled "The three-hypothesis calculation"; "A direct computation (code in the accompanying repository) confirms this arithmetic" |
| 40 | `lem:teacher:list` | plain lemma; computation one sentence after the proof in App C.1 |
| 41 | `lem:teacher:floor` | plain lemma |
| 42 | `rem:teacher:numbers` | remark titled "Numbers for the running example"; $\kappa=0$ rows illustrations; $\delta_S$ stated; rounding convention; $\kappa=30$ thresholds |
| 43 | `rem:teacher:hypotheses` | plain remark |
| 44 | `cor:teacher:fulltable` | plain corollary; (ii) per §F44; $d=20$ window after the statement, open at the right end |
| 45 | `cor:teacher:sampled` | corollary titled "Finite samples" |
| 46 | `ex:teacher:version1` | example titled "The total-bits version of the example" (moved to App C.6), beginning "By \cref{thm:teacher:main} with $d=100$, $m=10$ and $p=2^{-6}$ …, a direct computation (code in the accompanying repository) gives" |
| 47 | `prop:teacher:concentration` | plain proposition (moved to App C.7) with "$cn\ge1$"; App C.7 arithmetic "$-1000+241.7=-758.3$" |

---

## 3. Moved, new and deleted labels

**Deleted:** none. **Renamed:** none.

**Moved within the group** (label unchanged; one-sentence pointer left in the main text):

| label | from | to | in §C list? |
|---|---|---|---|
| `rem:absorb:condsemi` | absorb.tex | app-absorb.tex (B.3, after the pricing proof) | yes |
| `prop:absorb:inputs` | absorb.tex | app-absorb.tex (B.5) | yes |
| `prop:absorb:history` | absorb.tex | app-absorb.tex (B.5) | no (length) |
| `prop:limits:guard` | limits.tex | app-limits.tex (D.3) | yes |
| `prop:limits:inputlaw` | limits.tex | app-limits.tex (D.3) | yes |
| `rem:limits:method` | limits.tex | app-limits.tex (new D.6, `app:limits:method`) | yes |
| `prop:limits:noident` | limits.tex | app-limits.tex (D.3) | no (length) |
| `ex:split:noisyparity` | split.tex | app-split.tex (E.6) | yes |
| `rem:split:siprograms` | split.tex | app-split.tex (E.6) | yes |
| `lem:split:stream` | split.tex | app-split.tex (E.2) | no (length) |
| `prop:split:si` | split.tex | app-split.tex (E.4) | no (length) |
| `prop:algstat:product` | algstat.tex | app-algstat.tex (F.1) | yes |
| `prop:algstat:coarse` | algstat.tex | app-algstat.tex (F.1) | yes |
| `q:algstat:lsc` | algstat.tex | app-algstat.tex (F.1, after `prop:algstat:coarse`) | with it |
| `prop:algstat:set` | algstat.tex | app-algstat.tex (F.1) | no (length) |
| `ex:teacher:version1` | teacher.tex | app-teacher.tex (C.6) | yes |
| `prop:teacher:concentration` | teacher.tex | app-teacher.tex (C.7) | yes |
| `tab:teacher:numbers`(b) (no label of its own) | teacher.tex | app-teacher.tex (C.3, after "Numbers") | allowed |
| `lem:setup:hull` | setup.tex | app-setup.tex (A.2) | no (length) |
| `prop:related:computable`, `prop:related:computability`, `rem:related:nn`, `q:related:open` | related.tex | computable.tex | yes (§D2) |
| `sec:related:computable` | related.tex (subsection) | computable.tex (on the new section, next to `sec:computable`) | §D2 |
| `sec:related:work` | related.tex (subsection) | related.tex, on `\section{Related work}` next to `sec:related` | §D2 |
| `app:teacher:computations` | App C.8 subsection (deleted heading) | App C.3, paragraph "Numbers" | P2B-19 |

All references were checked by grep in both papers' `sections/*.tex` before moving; all are `\cref`s that still resolve (the combined scratch build has 0 undefined references).

**New labels:** `sec:computable`, `rem:setup:hullconverse`, `rem:algstat:near1`, `rem:computable:examples`, `app:limits:method`.

---

## 4. Received from another group

* The introduction's "Prior work" paragraph (p2-front gives, p2-body receives): its content is in `related.tex` as prose — §F46 wording for the posteriors (the "complexity weight above one in MDL theory" clause is dropped per §A8), the MDL paragraph (`rem:related:mdl`), the new paragraph "Algorithmic statistics" (restricted model families), the earlier-report paragraph (`rem:related:t5`). "Our literature search went only as far as abstracts …" is not carried over (§A8).

---

## 5. Page counts (isolated builds, `\status`/`\src` suppressed as in the final version)

Measured in the scratchpad with each section and its appendix compiled alone and the used height recorded with `zref-savepos` (pages of text height, floats included).

| section (new number) | main (budget) | appendix (budget) |
|---|---|---|
| §2 Related work | 1.15 (1.5) | — |
| §3 Setting | 2.80 (2.5) | A 1.98 (1.5) |
| §4 Absorption | 3.51 (3) | B 3.56 (3.5) |
| §5 Teacher's mistakes | 5.22 (5) | C 7.06 (7.5) |
| §6 Limits | 3.28 (3.5) | D 5.09 (4.5) |
| §7 Split | 2.71 (2.5) | E 4.21 (4) |
| §8 Algorithmic statistics | 2.20 (2) | F 2.79 (2.5) |
| §9 Computable classes | 0.88 (0.5) | G 1.65 (2) |
| **total** | **21.75 (20.5)** | **26.34 (25.5)** |

Before the edits (same method): main 25.0, appendices 23.2. Every section is within its ±0.5 guide except §4 (+0.51) and appendix D (+0.59). The appendix total is under the hard cap of 27. The main text: with the front matter at its budget (title, abstract and TOC 1.5, introduction 2.5, discussion with acknowledgements and code and data 2.0), the main text would be about 27.75 pages, 0.75 over the cap of 27; the introduction loses the "Prior work" paragraph and the TOC its `\newpage`, so the cap is reachable if the front matter stays near or below its budget (see §6).

---

## 6. For p2-front

* `main.tex`: input order intro, related, setup, absorb, teacher, limits, split, algstat, **computable**, discussion (§D2); `sections/computable.tex` exists. Appendices unchanged in order; `app-related.tex` now holds the proofs for §9.
* Intro and discussion references to update: the computable-classes bullet and the reader's guide cite `\cref{sec:related}` for computable classes → `\cref{sec:computable}` (related work is now §2, `sec:related`); "Full truth tables, sampled data, his other version of the example and the power posterior are treated too (\cref{sec:teacher:more})" → Version 1 and the power posterior are now in App C (`ex:teacher:version1`, `prop:teacher:concentration`); several cited results now sit in appendices (`lem:setup:hull`, `prop:absorb:history`, `prop:limits:noident`, `rem:split:siprograms`, `prop:split:si`, `prop:algstat:coarse`, `q:algstat:lsc`, `rem:limits:method`), which still resolve.
* `\cref{rem:related:mdl,rem:related:posteriors}` (discussion) and `\cref{rem:related:mdl,rem:algstat:restricted,rem:related:new}`, `\cref{rem:limits:schedule,rem:related:mdl}` (intro) will print "Section 2" twice or "Sections 2 and 2", because the related-work labels are now on prose paragraphs; cite `\cref{sec:related}` instead.
* "the trick" in intro.tex and discussion.tex → "steeper selection" (P2X-49); "H\"anni's sizes" → "the example's sizes" (the body's wording).
* The intro's "Prior work" paragraph can be deleted (its content is in §2) and replaced by two sentences pointing to \cref{sec:related}.
* §A2.5 check: the five statuses of the former related-work remarks (`rem:related:mdl`, `rem:related:posteriors`, `rem:related:cold`, `rem:related:t5`, `rem:related:new`) are kept as comments in the header of `related.tex`, so `extract_status.py` no longer sees them; their "rendered as" entries are rows 24, 26–29 above. Expected count for Paper 2 after my edits: 59 calls, 42 non-plain, 0 outside an environment.
* Discussion open problems: the question labels are unchanged (`q:absorb:shared`, `q:teacher:open`, `q:limits:open`, `q:related:open`, `q:algstat:lsc`), now `question` environments; `q:teacher:open`(b) and `q:limits:open`(b) contain the flip-rate questions; `q:related:open` no longer has the literature item, so open problem (8) can go as decided.
* Length: my main text is 21.75 pages against 20.5; to meet the 27-page cap the front matter needs to come in at about 5.25 pages.
* `CLAIMS.md` (optional, P2F-25): locations of the moved items above.

## 7. Deviations from DECISIONS, with reasons

1. Five related-work statuses are kept as comments, not as live calls (§2 above): a live `\status` in a prose paragraph would sit outside every environment, which §A2.5 forbids, and §A2.2 allows hand deletion only of the listed inline calls.
2. $j_g$ and $\varrho$ stay defined in the statement of `thm:teacher:main` (§D2 lists them among the symbols to define in App C), because the statement uses them; $\tau_B$, $\beta_B$, $\Gamma_g$ are defined in App C and inlined in the main text.
3. P2B-34: the printed value is $0.321$, not $0.308$, because the decided justification ($\hat L\ge d-4-2\log d-\kappa$) gives $6\sqrt{(d-4-2\log d)\ln2/(2n)}=0.321$ at $\kappa=0$; the conclusion is unchanged.
4. P2B-29: instead of a footnote, `prop:algstat:parity`(iv) prints $2\kappa$ in $j_d$, which is exactly what its proof gives; the table and statement now agree.
5. Six moves beyond the §C list (marked "length" in §3) to bring the main text from 25.0 to 21.75 pages; each leaves a summary sentence with the statement's content and a pointer.
6. §E "threshold $\rho_0$" was not introduced: after renaming the integer to $r_D$ the threshold is $2^{-r_D}$ and needs no symbol.
7. P2B-44: "matched by the coin" is written "beaten or tied by the coin", the wording of `prop:limits:rateblind`(ii).

---

## Final check (fresh checker, 22:05–22:20; report `research/paper-review/final-check-p2.md`)

Edits to this group's files: `teacher.tex`, first paragraph, "three orders of magnitude at the example's sizes **for $\kappa\le30$**" (the ratio is 8453 at $\kappa=0$ and 3837 at $\kappa=30$, and decreases in $\kappa$); `app-setup.tex`, remark title "[The converse in (iv)]" (capitalisation); `app-limits.tex` l.75, "(code in the accompanying repository)" added (§A9 wording). No label was touched. The full build is clean, 57 pages, with the layout unchanged.
