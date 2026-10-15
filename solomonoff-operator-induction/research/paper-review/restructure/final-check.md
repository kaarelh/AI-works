# Final check, Paper 2 after the restructure and its fix round (`paper-steeper/`)

Fresh final checker, 2026-10-13/14. I had not seen Paper 2 before this check.

**Read before checking.**
* `REFRAME.md`, `DECISIONS.md` §A, `restructure/PLAN.md` (in full), `restructure/DECISIONS-restructure.md` (in full), all seven `fix-*.json`, `log-front.md` (fix-round section).
* The whole PDF (`pdftotext`, all 74 pages), and the sources of every input file.
* The records: the synthesis `tracks/split/notes-final.md` §8; `verify-iid.md`, `verify-kink.md`, `verify-teacher.md` in full; the statements and proofs in `split/{iid,kink,teacher}/notes-final.md` that the spot-checks below name.

**Rules kept.** No git command that changes repository state was run. Script re-runs used copies in the session scratchpad. No label was added, renamed, moved or removed.

**Result.**
* No fatal item exists. All 22 major items of the fix lists are fixed in the sources as decided (§1).
* The abstract, the introduction and the discussion agree with the body. One sentence of the introduction was corrected (§0).
* 27 statements, spread over every section and appendix, agree with the records and their verification reports in hypotheses, constants and status (§3).
* Six scripts were re-run, and every output is byte-identical to the saved one (§3).
* The arXiv and REFRAME greps return only the allowed hits (§4).
* Both full builds are clean, and the companion-number check ends ALL OK (§5).
* **One acceptance criterion is not met: length** (§5).
  * The main text is 34.5 pp against the cap of 33.5 in DECISIONS-restructure §3.
  * The total is 73.8 pp (74 pages) against 73.5.
  * The appendices are within their cap (37.0 against 37.5).
  * DECISIONS-restructure §3 forbids further cuts or moves without the author's decision, so I made none.

---

## 0. Edit made in this check

| file | change | reason |
|---|---|---|
| `sections/intro.tex`, Theorem A (informal) | "At $\lambda=1$ no recovery time depends only on $(\ell_0,\gamma,\varepsilon)$**:** in a class of parities with a uniform margin it is $\Theta(2^{\ell_0/2})$ …" → "…$(\ell_0,\gamma,\varepsilon)$**;** in a class of parities …" | With the colon, the $\Theta(2^{\ell_0/2})$ recovery time in $\mathcal C_k$ reads as the reason why no $(\ell_0,\gamma,\varepsilon)$-bound exists. `verify-iid.md` §1.6 (F3) says this conflation is false: $\mathcal C_k$ has the bound $\max(32,\lceil2^{(\ell_0+1)/2}/\sqrt\varepsilon\rceil)$. The absence of a class-free bound comes from $\mathcal C_{k,r_0}$ (`prop:recovery:lambda1`(a)), and the exponential time from $\mathcal C_k$ (`prop:recovery:lambda1`(b)). With a semicolon the two claims are separate, as in the body (§6.3) and the abstract. The rebuilt PDF differs from the previous one only in this character, so the layout is unchanged. |

---

## 1. Fatal and major items of the fix lists

There are no fatal items. Each of the 22 major items was checked in the current `.tex` files and in the rebuilt PDF. A script compared the decided exact texts of DECISIONS-restructure (D1–D4, D6–D9, the D11 table) with the sources: every new text is present, and every replaced text is gone.

| id | check in the sources / PDF | status |
|---|---|---|
| RF-01 | `abstract.tex`: the D9 body, verbatim, 1920 characters of stripped source; the comment lines updated | OK |
| RF-02 | `intro.tex`: the D1 sentence closing Theorem A, and the row-2 answer of `tab:intro:claims`, verbatim; "identifies … on the queried" occurs in neither the sources nor the PDF | OK |
| RF-03 | `intro.tex`: "average squared Hellinger distance to $\nu$ (the Hellinger gap of \cref{def:split:setting})" (D8) | OK |
| RF-04 | `intro.tex`: "at most $0.200$ $(\kappa=0)$ or $0.274$ $(\kappa=30)$ at $c=10^{-4}$ and the sizes given below"; "$(9.54\cdot10^{-7},3.65\cdot10^{-3}]$ at $\kappa=30$" | OK |
| RF-05 | The row "What does $\lambda=1$ do?" is gone. The Kinks and Exact-recovery bullets are two lines each. "What counts as one hypothesis" has 2 sentences and "The window and its price" 3, neither repeating `rem:absorb:wyeth` or `rem:limits:schedule` | OK |
| RF-06 | Integration: see §4 and §5 (builds clean, greps clean, companion check ALL OK, `CLAIMS.md` and `OUTLINE.md` free of the removed numbers). The page caps are not met, as FRONT reported | OK except the length |
| RW1-01 | `lem:setup:basic`, with its proof, is Lemma A.1 in App A.2, with the decided pointer sentence in §3.3. The generalised-posterior sentence is a pointer to §2. `rem:setup:objects` is 4 lines and keeps both Paper 1 citations (Prop 5.7, Prop 5.6) | OK |
| RW1-02 | `prop:absorb:pricing` is Prop B.2 in App B.4, after the two decided sentences in §4.3. The dominance and KL sentence, with Theorem 5.3 of Paper 1, ends App B.3. `rem:absorb:wyeth`(iii),(iv) are one clause each | OK |
| RW2-01 | `rem:kink:reading` is 4 lines. The paragraph after `def:kink:kinks` is trimmed. No statement changed | OK |
| RW3-01 | Opening of §6: the D1 sentence (ν-equivalence on the run, summable Hellinger gaps) | OK |
| RW3-02 | D2 in three places: `def:split:setting`, the first sentence of `lem:recovery:ratios`, and the proof of `lem:split:ville` ("$Z_{n+1}=Z_n$"). `app:split:private`(iv) and `prop:recovery:frozen`(b) read correctly with the distinct-input indexing | OK |
| RW3-03 | `rem:split:reading` opens with the D3 text, fill-in threshold $L_n(\nu)>\lambda(k+\delta^*)/(\lambda-1)$ | OK |
| RW3-04 | The D4 paragraph after `cor:recovery:noisy` ($(7/8)^{64}$, "an explicit class"); the computed values 0.255/0.255/0.204/0.566 and 0.136/0.136/0.085/0.566 in App D after `rem:recovery:frozentable`; "In an explicit class" inside the remark | OK |
| RW3-05 | `rem:recovery:window` is Remark D.3 in App D.4, with the pointer sentence in §6.4. The paragraph after `thm:split:lambda1` is one sentence, keeping Eisenstat's credit and `% P1: sec:ex:eisenstat`. `rem:recovery:posterior` is 3 lines. The paragraph after `prop:recovery:frozen` is 4 lines. `\cref{sec:split:lambda1}` in the acknowledgements resolves (§6.7) | OK |
| RW4-01 | `lem:teacher:twopart`: "Let $\lev(\pi)=t<\infty$. Then (D1) … and, if $B$ is an integer or $\infty$, (D2) …". The decided sentence ends `def:teacher:instance`(c). No result of §7 or App E uses (D2) at a non-integer $B$ | OK |
| RW4-02 | `rem:algstat:reading` ends with the D7 sentence ("once $\lambda-1\gg(\log d+\delta_E)/d$"); "useless over set models in this example (" is gone | OK |
| RW4-03 | Trims only: the opening is 6 lines, the covers paragraph 2 sentences, `rem:algstat:restricted` one sentence (with "see also" Milovanov). The notation box, the four lemmas, the sharp floor and Question 7.13 stay in §7 | OK |
| RW5-01 | `\begin{enumerate}[label=(\roman*),start=1,…]` with `\item[(o)]`. The PDF prints "(o) Level bounds." once and no "() Level"; items (i)–(iv) follow. The "(o)" citations (proof of Prop 9.1, Prop 10.1(a), App F.2) match | OK |
| RW5-02 | `prop:teacher:kinks` opens "Let $B=\infty$ or let $B\ge\log(1/p)$ be an integer."; `thm:teacher:main` has "with $B=\infty$ or an integer $B\ge\log(1/p)$"; the samples paragraph has "let $B\ge\log(1/p)$ be an integer". "(with $B$ as in \cref{thm:teacher:main})" is in `prop:teacher:sharp`(iii) and `prop:teacher:concentration`. `prop:teacher:schedules`(c) already says integer | OK |
| RW5-03 | `tab:teacher:numbers` has the four D10 rows and the caption "Lower bounds are rounded down and upper bounds up." `rem:teacher:numbers` has $e\le0.195$, $3.65\cdot10^{-3}$, and "about $6\%$ ($\kappa=0$; about $11\%$ at $\kappa=30$)" | OK |
| RW5-04 | `prop:teacher:sharp`, with the Floor/Ψ/LB/$\Phi_2^\sharp$ display, is Prop F.6 in App F.7; §8.4 keeps the decided paragraph. `rem:limits:schedule` has no literature sentences; "literature: \cref{rem:related:mdl}" is in its parenthesis. The FQ paragraph is 6 lines; the samples paragraphs are 4 lines and 2 sentences | OK |
| RW6-01 | §9.3 is App G.4, with `sec:limits:ood` as an alias on `app:limits:ood`, and the decided sentence ends §9.2. `prop:related:computability` is Prop H.1 in App H, with the decided sentence in §10. `rem:computable:examples` is 3 lines. The $d_0$ table is one sentence | OK |

The removed-phrase grep of DECISIONS-restructure §4 item 7 ("identifies it on the queried inputs", "identifies $\nu$/ν on the queried", "average Hellinger distance", "0.199", "3.66", "0.545", "0.955", "useless over set models in this example (", "() Level", and in the sources `0.1233\le p`) has no hit in the sources (outside the switched-off `app-verification.tex`) or in the PDF. "(o) Level bounds" occurs once.

---

## 2. Abstract, introduction and discussion against the body

Each claim was traced to the body statement it summarises, with its hypotheses.

* **Abstract (D9 text).**
  * Absorption: `thm:absorb:absorption`, `rem:absorb:examples`; no universal private-randomness hypothesis: `cor:absorb:nouniversal`.
  * "every $1\le\lambda_n=o(n)$ … eventually a shortest program for the sampler": `thm:recovery:main`(a), with a computable sampler in $\Hcl{\times}$.
  * "for fixed λ > 1, with probability $1-\varepsilon$ at each $n$ beyond a bound depending only on λ, the program's length, a margin and ε": `thm:recovery:main`(d).
  * "At λ = 1 no such bound exists; in a parity class recovery is exponentially slower": `prop:recovery:lambda1`(a), (b).
  * Kink ⇒ split up to windows: `cor:kink:split`(b). "per-query samples have one": `thm:recovery:kink` (with probability $1-\varepsilon$; almost surely in (v)).
  * Full table of a noisy random parity at each dyadic $p<1/4$, large $d$: `prop:parity:kink` with `prop:parity:range`(iii) (level ≤ 2; a random error set has $\delta_E=O(d)$ with high probability).
  * No steep set kink: `prop:parity:sets`.
  * λ must grow linearly: `prop:teacher:schedules`(a).
  * Teacher theorem: `thm:teacher:main`, with every hypothesis named ($p<0.05596<p_0$, product form, incompressible relative to the parity, uniform inputs, population objective, $\lambda/n$ in a window, "for large error rules" for (e)).
  * Below 0.1233: `prop:teacher:rates` ($0.1233<p_1=0.1233072\ldots$).
* **Introduction.**
  * Theorem A: the class (countable, Kraft, contains a program for ν; Prop 10.1(d) for subclasses), the limit, the rate $n\ge\lambda(\ell_0+\log(2/\varepsilon))\ln2/(2\min(1,\lambda-1)\gamma)$ with the squared-Hellinger margin of `def:split:setting`, the fill-in mass, the λ = 1 contrast and the frozen-label statement all match `thm:recovery:main`(a),(c),(d), `prop:recovery:lambda1` and `thm:split:private`(iv). I edited the λ = 1 sentence (§0).
  * Theorem B: `lem:setup:hull`, `cor:kink:split`(b) (all four bounds and the $(b+(\lambda-1)w)$-sufficiency), `thm:kink:converse`; the sample kink (`thm:recovery:kink`, Ville line); the parity (`prop:parity:kink`, `prop:parity:range`(iii), "typical error sets ($\delta_E=O(d)$)", "dyadic"); `prop:parity:sets`; `prop:kink:universal`.
  * Theorem C: `thm:teacher:main` and `prop:teacher:kinks`, with the open window $(2^{-m},c_{\rm hi})$. The numbers 0.200/0.274 are rows 1 and 3 of Table 3 ($\delta_S=0$). The windows $(9.54\cdot10^{-7},8.06\cdot10^{-3}]$ and $(…,3.65\cdot10^{-3}]$ round $c_{\rm hi}=8.0617951\cdot10^{-3}$ and $3.6589743\cdot10^{-3}$ down, inside the open window. The reuse factor: `lem:teacher:reuse`, `prop:teacher:schedules`. "$p\le0.1233$": `prop:teacher:rates`.
  * The contributions and `tab:intro:claims`: every row's "Where" column holds what the row says. The window shares 31% and 24% are those of §9.1. The factor min(λ, 2) is `prop:absorb:price`(iv).
  * The scope paragraph's "recovers the function (μ-a.e.) and the rate" is `cor:recovery:noisy`(i) (per query).
* **Discussion.**
  * `tab:discussion:reasons`, row by row, against `thm:recovery:main`, `thm:recovery:kink`, `prop:parity:kink`, `prop:teacher:kinks`, `prop:teacher:schedules`, `prop:teacher:frozen`, `lem:teacher:reuse`, `cor:teacher:fulltable`, `prop:limits:plain`, `thm:split:shared`, `prop:recovery:frozen`, `prop:recovery:beyond`, `prop:limits:envelope`, `prop:limits:rateblind`, `rem:setup:persample`.
  * "the same tail": Remark 8.8(5).
  * "a third to a quarter": 0.31 and 0.24, from App G.1.
  * Neural networks: `rem:related:nn`.
  * Open problems (1)–(6) cite every question environment of the body: `q:recovery:open`, `q:parity:open`, `q:algstat:lsc`, `q:teacher:open`, `q:limits:open`, `q:absorb:shared`, `q:related:open`.

No other discrepancy was found.

---

## 3. Spot-check of 27 statements against the records

"Record" names the sub-track statement; V-I, V-K and V-T are the verification reports. Every row was compared with its source in hypotheses, quantifiers, constants and status, and every row agrees.

| # | paper item (number in the PDF) | record | what was compared |
|---|---|---|---|
| 1 | `lem:setup:hull` (Lemma 3.8)(v),(vi); App A.3 | kink Thms 2.1, 2.2, Prop 2.3 | gift wrapping; $\sigma_0=\infty$, $\sigma_{q+1}=0$; MAPs on open λ-intervals and on closed edges; duality. Remark A.2 is the refuted strengthening of (iv), rendered as "cannot be weakened" |
| 2 | `thm:split:shared` (Thm 4.4)(i),(ii) | base; kink Prop 3.5; D11(k) | the condition $(\lambda-1)k>\lambda\ell_U+\kappa_0$; "for every nonempty set $A$"; the bound $2^{-(\lambda-1)\min_A\ell+\lambda\ell_U+\kappa_1}$ |
| 3 | `lem:kink:main` (Lemma 5.3)(i)–(v) | teacher Lemma 1.1, Remark 1.2; V-T §2 | $\Delta(c)=g+(c-\tau)(\alpha_r-\ell_M)$; pointwise margin; length and fit bounds; the wedge $\vartheta(1-c/\sigma)$ |
| 4 | `def:kink:kinks`, Lemma C.1 | teacher Def 1.4, Lemma 1.5; V-T §3 | the corrected example offset $L_r+\tau(\alpha_r-\ell_M)$; (c) for $c\ge0$, $c\ne s_+$ |
| 5 | `cor:kink:locate` (Cor 5.4); App C.3 examples | kink Thm 3.2, Remark 3.2′; V-K §6 | strict λ < σ and λ > τ; τ < σ in (c); the examples $(0,10),(1,5),(2,0)$ and $\{(0,10),(2,0)\}$ |
| 6 | `cor:kink:split` (Cor 5.5) | kink Cor 3.3 | right line $(1,b+\kappa)$; window $(b+\kappa)/(\tau-1)$; the four bounds of (b); stated in a hypothesis class |
| 7 | `thm:kink:converse` (Thm 5.6) | kink Thm 3.4 | indices $i,j$; the exception τ = 0 with infinitely many vertices |
| 8 | `prop:kink:universal` (Prop 5.7)(ii) | kink Prop 3.5; V-K §5 | "when λ ≥ 1 + ϵ, and, if $\ell_U+\kappa_0>0$, only then" (corrected form) |
| 9 | `thm:recovery:main` (Thm 6.3)(c),(d) | iid Thm 4.1(i)–(iv′); V-I §1.2 | the free-exponent bound for every λ > 0; $\bar\ell_\varepsilon=\lceil(\lambda\ell_0+\log(2/\varepsilon))/(\lambda-1)\rceil$; the sample size; fill-in masses under $\Pi_\lambda$ and $\Pi^{1/\lambda}$ |
| 10 | `prop:recovery:lambda1` (Prop 6.6) | iid Prop 5.1(a),(b),(b′), 4.4(b); V-I §1.4, §1.6 | $k\ge8$, $r_0\ge6$, $n=r_0-5$, 31/32; the bracket $(2^{(k-8)/2}-6,\max(32,\lceil2^{(k+1)/2}/\sqrt\varepsilon\rceil)]$ with $d\ge2^{(k-8)/2}$; $2^{k-2-(1-1/\lambda)n}$. The following paragraph uses only Remark 4.7′ (no "Z(s) = ∞ in $\mathcal C_k$") |
| 11 | `tab:recovery:times` (Table 2) | iid i7(A) | all 20 entries; "at λ = 1 the times equal $2^{(k+4)/2}+6$" (i7(B)); no illustration mark (V-I §2 item 7) |
| 12 | `prop:recovery:necessity` (Prop D.2)(d) | iid Remark 4.5; V-I §1.5 | "an integer $k$ and λ > 1 with $n=\lambda(k-2)/(\lambda-1)$ a positive integer"; 0.2887; the exact length formula |
| 13 | `rem:recovery:window` (Remark D.3) | iid Lemma 8.1(iv), Remark 8.2; V-I §1.7 | excess $k-7$; $31/32-2^{7-k}$; "no fixed λ ≤ 1 lies in a guaranteed kink interval at finite $n$" (iid Remark 8.2) |
| 14 | `thm:recovery:kink` (Thm 6.7)(i)–(v) | kink Lemma 5.2, Thm 5.4 (pq), Cor 5.7; iid Lemma 8.1; V-K §2–§3 | $\sigma_n$ and the condition $A\ge2\ell_0$; window $(\ell_0+\log(1/\varepsilon))/(\tau-1)$ and the Ville line $\ell_0+\delta^*$; $n>(\bar\ell+\log(1/\varepsilon))/(\log e\cdot\gamma_{\bar\ell})$; probability $1-2\varepsilon$; $s_+<1<s_-$ |
| 15 | `cor:recovery:noisy` (Cor 6.8) | iid Cor 6.1(i)–(v) | membership in $E$ for both labels; exact rate; fill-in mass; $p=\frac12$ and $p=0$; the canonical-class remark with a rational β ∈ (0, p] |
| 16 | `rem:recovery:frozentable` (Remark D.4) and the values after it | iid Cor 6.1(vi); V-I §1.10 | the corrected "penalised empirical rate" sentence; $(7/8)^{64}$; 0.255/0.255/0.204/0.566 and 0.136/0.136/0.085/0.566 |
| 17 | `thm:split:private` (Thm 6.9)(iv); App D.10 | iid Prop 3.3; V-I §1.1 | the almost-sure hypothesis $\nu_{\pi_\nu}(o_n)=\nu(o_n)$; every λ ≥ 1; the $Z^{\bar\ell}$ supermartingale replaces the confinement by (i); Borel–Cantelli for the posterior |
| 18 | `prop:recovery:beyond` (Prop D.5)(c) | iid Prop 3.4; V-I §1.3 | "suppose $J_c(\pi)<\infty$ for some π"; recovery for $c<c^*$, failure for $c>c^*$, "$c=c^*$ is not covered"; no "iff" |
| 19 | `prop:parity:kink` (Prop 7.7) | kink Prop 4.1 | $\sigma^{(t_0)}$ with $\mathrm{den}_t=\kappa_g+\min\{d,s(t+1)+\Lambda_1\}$; the window $w$; $b_0$ |
| 20 | `prop:parity:range` (Prop 7.8)(ii),(iii) and `tab:parity:ranges` (Table 5); App E.3 numbers | kink Prop 4.2, Cor 4.3; V-K §4 | facts (α), (β), (γ) in the proof of (ii); (iii) for dyadic $p$ with the explicit condition $1-\log(\frac32-p)>H(p)$; all seven table rows equal the corrected prints of V-K §4.2 ("(1, x]" only at $p=2^{-10}$); $u\ge0.9928$, $I\le58.4$ at λ = 2 and $u\ge0.9903$, $I\le28.3$, $e\le0.184$ at λ = 105 (V-K §4.3) |
| 21 | `prop:parity:sets` (Prop 7.10) | kink Prop 4.4 | $c^*=2\log d+K(p)+\kappa$; $\sigma\le1+(c^*+\delta_E+2\kappa)/(\alpha_r-c^*)$ |
| 22 | `lem:teacher:reuse` (Lemma 8.2) | teacher Lemma 3.0; V-T §4 | the reference $(\alpha_r,L_r)\mapsto(\alpha_r,rL_r)$; every listed threshold, the wedge margins and the offsets scale by $r$ |
| 23 | `prop:teacher:schedules` (Prop 8.3) | teacher Prop 3.6; V-T §6 | (a) $\lambda_n>0$; (b) $\ell_{\min}\le\kappa$ in $\Hcl{\times}$; (c) integer $B$, $c_{\rm hi}$ at that $B$, δ ∈ (0, 1), $\bar L$, $\bar\epsilon_n$; almost sure with $\delta=n^{-2}$ |
| 24 | `prop:teacher:frozen` (Prop F.1) | teacher Prop 3.7; V-T §7 | (a) the length bound $k+(k+\delta^*)/(\lambda-1)$ with δ* along the distinct inputs; (b) every program equal to ν on the support is rejected by every $\lambda_n=o(n)$; (c) the scaling by $\bar n$ |
| 25 | `thm:teacher:main`(ii)(a) and `tab:teacher:numbers`; `rem:teacher:numbers`; App F.2 numbers | teacher Prop 2.1, Remark 2.6; V-T §8; D10 | $R_{\max}=J_g(c)+\epsilon-c(d-4-\Lambda_1)^+$; the four table rows against the lead editor's unrounded values; 0.954 … 0.059 |
| 26 | `prop:teacher:sharp` (Prop F.6) and `prop:teacher:rates` (Prop 8.12); `tab:teacher:rates` (Table 6) | teacher Lemma 5.1, Props 5.2, 5.3; V-T §9 | the information charge; $LB_t$, $\Phi_2^\sharp$; the claim for dyadic $p$, $a>a^*(p)$, $d2^{-m}\to0$, $\delta_S=o(2^m)$, $c_md\to0$; "$a^*(p)<\infty$ iff $1-\log(\frac32-p)>H(p)$"; $p^*=0.0778658\ldots$ with "$p\le0.0778$" rounded down; every window end of Table 6 rounded safely against t6(B), and every $u$ and $e$ against t6(C) and the lead editor's (a2) values (0.9897, 0.1925) |
| 27 | `prop:limits:envelope` (Prop 9.1) numbers (§9.1, App G.1); `prop:related:computable` (Prop 10.1)(d) | teacher Prop 4.1 and the lead editor's recomputation; iid Cor 6.2 | $c_{\rm env}=1.64\cdot10^{-5}$ ($0.746\cdot10^{-5}$), shares 0.31/0.24 and 0.47/0.42, $e_1\ge0.544$/0.862 (0.489/0.839 at $\delta_2=20$); the subclass statement uses only countability, Kraft and Ville |

**Statuses.** No item above is stated more strongly than the record proves it.
* The [V-T] items (rows 3, 4, 22–24, 26) are all "verified" or "verified with correction" in `verify-teacher.md` §1, and the corrected forms are the ones printed.
* The post-referee iid and kink items (rows 8–10, 12–14, 16–18, 20) are verified in V-I and V-K, in the forms printed.

**Re-runs.** Each script was run from a copy in the session scratchpad, with `python3 -I`. Each output was compared with `diff` against the saved `.out` in the repository.

| script | what it backs | runtime | result |
|---|---|---|---|
| `split/iid/checks/i7_parity_exact.py` | Table 2; Prop 6.6 bracket; Remark D.3 rank law | 2 min 48 s | identical |
| `split/teacher/checks/t6_exact_window.py` | Table 6; the (a1)/(a2) values | 7 min 36 s | identical |
| `split/kink/verify_code/v4_parity_range.py` | Table 5; the App E.3 identification numbers | 45 s | identical |
| `restructure/scratch/lead_teacher_numbers.py` (with t6) | Table 3; $c_{\rm hi}$ | < 1 s | identical |
| `restructure/scratch/lead_envelope_numbers.py` | §9.1 and App G.1 envelope numbers | < 1 s | identical |
| `restructure/scratch/lead_memoriser_numbers.py` | App F.2 memoriser-regime bounds | < 1 s | identical |

---

## 4. arXiv and REFRAME checks

* **Status tags.**
  * `\status`/`\src` are redefined to print nothing (`preamble.tex` l.122–123).
  * The source has 103 `\status` calls. 32 are plain "proved", 27 "proved; computed" and 12 "remark".
  * Each of the other 32 was checked against its rendering in the text, for example:
    * the refuted strengthenings are phrased "The natural strengthening … fails" (`rem:recovery:posterior`, `rem:recovery:window`, `rem:teacher:selected`, Remark A.2);
    * the known tools are cited at their use (Ville, Kakutani, Poland–Hutter, Li–Vitányi, Gneiting–Raftery);
    * κ = 0 computations say "with the machine constant set to 0 (an illustration)" (`ex:split:noisyparity`, `ex:teacher:version1`, `prop:limits:noident`);
    * every `open` is a question environment that the discussion's open-problem list cites;
    * `prop:algstat:coarse` is stated for computable rational hypotheses, and the lower-semicomputable case is Question E.4.
  * The PDF grep `\[(proved|computed|conjecture|known|proof sketch|refuted|remark|open)` returns nothing.
* **Computed numbers.** No computed decimal sits inside a theorem, proposition, lemma or corollary. A script over all such environments found only proved constants (8.66, 0.2887 in Prop D.2), the exact threshold "λ < 1.5" in Prop 6.10, and Paper 1 locators.
* **Process vocabulary.**
  * The DECISIONS §A5 grep, extended with synthesis, sub-track, verified, refereed, withdrawn, corrected, iid, T1–T5, V-I/V-K/V-T, verify-, refuted, record, checker, plan and writer, hits in the PDF text only:
    * the title footnote's "independent AI referees";
    * "Sam Eisenstat (personal communication)";
    * formula renderings ((c1)–(c3), $c_1,c_2$, $s_0$, $E_0$, $r_0$, $S_1,S_2$, $e_1$, (D1), (D2), $h_0,h_1$).
* **Wyeth.** No occurrence in the PDF. In the sources it occurs only in the label `rem:absorb:wyeth`, whose title is "Answer to the absorption objection", and in a comment.
* **The author's notes.**
  * `hanni2026notes` and `hanni2026grokking` are cited only in the proposal footnote (`intro.tex`), the change-of-slope footnote (`kinks.tex`) and the acknowledgements.
  * "the author" occurs only in the title footnote, those two footnotes and the acknowledgements.
  * There is no running-text quotation of the notes. The absorption objection is "a standard objection".
* **Footnotes.** There are 2 `\footnote`s, besides the title `\thanks`, against the limit of 5. Neither sits in a statement or a float.
* **Labels.**
  * 223 labels are defined in the input files, with no duplicate.
  * Every base label (`dcb3a3a3`) still exists, except the six cut by the plan: `lem:split:hash`, `app:split:hash`, `rem:limits:method`, `app:limits:method`, `tab:algstat:numbers`, `app:algstat:numbers`.
  * The moved labels are each defined once in `main.aux`: `lem:setup:basic`, `prop:absorb:pricing`, `rem:recovery:window`, `rem:recovery:frozentable`, `prop:teacher:sharp`, `prop:related:computability`, `sec:limits:ood`, `app:limits:ood`.
  * `split.tex`, `algstat.tex` and `app-algstat.tex` hold only the one-line superseded comment and are not input.

---

## 5. Builds, companion check, pages

* **Paper 2.**
  * Command: `flock /tmp/claude-0/paper-build-sfi.lock ./build.sh`, run before and after the edit of §0.
  * Result: 0 LaTeX errors, 0 undefined references, 0 undefined citations, 0 multiply defined labels, 0 overfull boxes above 10 pt (one of 1.84 pt, in the bibliography); 74 pages.
* **Paper 1.**
  * The same command gives 0 / 0 / 0 / 0 / 0 (overfull boxes of 0.84 and 1.84 pt only); 91 pages.
  * Paper 1 was not edited in this check. Since the base commit it has only text changes (`steeper.tex`, one sentence each in `intro.tex` and `discussion.tex`), with no environment, section or equation added or removed.
  * Its summary of Paper 2 agrees with the fixed body: the two reasons, exact recovery per query, and 0.05596.
  * `paper/bib/core.bib` and `paper-steeper/bib/core.bib` are identical.
* **Companion check.**
  * `python3 -I research/paper-review/scratch/editor/check_companion_numbers.py`, run after the Paper 1 build, ends **ALL OK**.
  * It lists "Theorem~5.1" as used but not intended. Checked by hand: `thm:learn:dominance` is `{5.1}` in `paper/main.aux`.
  * It lists "Section~7.3" and "Remark~B.3" as intended but not used. Section 7.3 is the `\citealp[Section~7.3]` in `recovery.tex`, which the script does not parse; `sec:ex:eisenstat` is `{7.3}`. Remark B.3 is no longer cited, because the hashing comparison was cut.
  * Every other locator (Theorems 3.8, 3.11, 4.4, 5.3, 6.16, 9.10; Propositions 4.6(a), 4.7, 5.6, 5.7(a), 8.1(a), 10.1, A.10(c); Corollaries 5.4, 6.17(a); Remarks 4.8, G.11, H.2; Questions 3.14, 10.9; Section 9.1) is in the script's verified list.
* **Pages.**
  * Measured as text-block fractions between the heading positions of `pdftotext -bbox`. The text block runs from y = 0.096 to 0.909 of the page height.
  * The binding caps are those of DECISIONS-restructure §3, which supersede PLAN.md §6 for Paper 2.

| part | PLAN.md §6 budget | DECISIONS-restructure §3 target | measured |
|---|---|---|---|
| title, abstract, contents | 1.25 | 1.5 | 1.51 |
| §1 Introduction | 2.25 | 3.2 | 3.28 |
| §2 Related work | 0.75 | 0.95 | 0.97 |
| §3 Setting | 2.25 | 3.0 | 3.24 |
| §4 Absorption | 2.25 | 2.9 | 3.00 |
| §5 Kinks | 2.25 | 2.5 | 2.54 |
| §6 Exact recovery | 4.75 | 5.1 | 5.33 |
| §7 Noisy parity | 2.5 | 3.8 | 3.84 |
| §8 Teacher | 4.75 | 5.3 | 5.42 |
| §9 Structured errors | 1.75 | 2.1 | 2.31 |
| §10 Computable classes | 0.5 | 0.8 | 0.95 |
| §11 Discussion, acknowledgements, code | 1.5 | 2.0 | 2.10 |
| **main text** | **26.75** (cap 27) | **33.15, cap 33.5** | **34.46** (34.5 to the start of the references) |
| references | – | – | 2.32 |
| App A / B / C | 2.5 / 3.5 / 1.75 | 2.4 / 4.4 / 2.1 | 2.33 / 4.30 / 2.07 |
| App D / E / F | 7.0 / 3.75 / 4.5 | 8.7 / 6.3 / 7.0 | 8.80 / 6.37 / 7.31 |
| App G / H | 2.75 / 1.25 | 4.0 / 2.2 | 3.80 / 1.99 |
| **appendices** | **27.0** (cap 27) | **37.1, cap 37.5** | **36.96** |
| **total** | cap 57 | **cap 73.5** | **73.8 (74 pages)** |

**What this means.**
* Against PLAN.md §6, both parts are far over: the main text by 7.7 pp, the appendices by 10.0. Those budgets were replaced by DECISIONS-restructure §3, because the added thread could not fit them without deleting proved results.
* Against the binding caps:
  * the appendices hold;
  * the main text exceeds its cap by about 1.0 pp, spread over §3 (+0.24), §6 (+0.23), §9 (+0.21) and §10 (+0.15);
  * the total exceeds its cap by about 0.3 pp.
* These figures agree with FRONT's measurement in `log-front.md`.
* As DECISIONS-restructure §3 requires, I moved and cut nothing. The candidates, which need the author's decision, are the ones FRONT lists:
  * for the main text, `rejected.json` REJ-01, REJ-04 and REJ-05;
  * for the appendices, REJ-08.

---

## 6. For the author

* **The length decision** of §5 is the only open acceptance criterion.
* **Nothing else needs action** for the arXiv form or for the mathematics. The statements in the paper are those of the records and the verification reports, in their corrected forms.
