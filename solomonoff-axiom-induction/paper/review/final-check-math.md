# Final check (mathematics) of the paper on \SAI: §2–§5, §7–§9, Appendices A–C, E–G

*Fresh final checker, 2026-10-17. Scope: `sections/setting.tex`, `basic.tex`, `soi.tex`, `logic.tex`, `shape.tex`, `terms.tex`, `laws.tex` and `app-basic.tex`, `app-soi.tex`, `app-logic.tex`, `app-shape.tex`, `app-terms.tex`, `app-laws.tex` (§2–§5, §7–§9, App A–C, E–G of the build).*

**Restart check.** At the start of this run `review/final-check-math.md` did not exist and no other output of an earlier run of this check was found; nothing had to be recovered.

*Status of this file: complete.*

## 1. Fatal and major issues of DECISIONS.md in scope

DECISIONS.md lists no fatal issue. The major issues whose fixes fall in the scope files are A-01 (SOI-01), B1 (TER-01, SOI-08), B2 (TER-02), C1 (LAW-01), PHIL-04 (LAW-08), the scope parts of the merged upshot fix PHIL-01 / consistency 3 (SOI-03, SHA-05), and the length entries BAS-L1, BAS-L2, SOI-L1, LOG-L1, SHA-L1, TER-L1, LAW-L1 (consistency 1). Each was read in the source and compared with the decided text and with the thread record.

| issue | decided fix | in place? | correct against the record? |
|---|---|---|---|
| A-01 / SOI-01 (`thm:soi:diagonal`) | last sentence restricted to the sequence built against $P^\ast(D)=(W^{\mathrm{all},\tau}(D)+2^{-\lvert D\rvert})/2$; proof names $P^\ast$; `prop:soi:incomparable` "on a computable sequence (… applied to $P^\ast$)"; Table 1 row "on a computable sequence" | yes, all four places (`soi.tex` statement and Table 1 row; `app-soi.tex` proof paragraph "Clocked \SOIabbr" and `prop:soi:incomparable` with its proof) | yes: `sfi` Thm 7.4 and its re-check ("$W^{\rm all,\tau}$ is turned into a computable predictor by mixing in $2^{-|D|}$"); the bound re-derived: $\ell_{W^{\rm all,\tau}}\ge\ell_{P^\ast}-1\ge n-1.361$, and $\ell_{W^{\rm cons,\tau}}\ge\ell_{P^\ast}-1-c_\bot$ since $W^{\rm cons,\tau}(\emptyset)\ge2^{-c_\bot}$. The one-tape sentence after the theorem says "on a computable sequence", as `sfi` Thm 7.8(b) |
| B1 / TER-01 (empty background) | $B=\emptyset$ in the fit-class statements of `thm:terms:dilemma`(iii), and in (iv), (v); in `cor:terms:table` rows 3–4, `prop:terms:a1fit`, `thm:terms:binary`, `cor:terms:freededuction`, `prop:terms:ontology`(a); main-text prose | yes: the theorem's preamble ("In the fit-class statements of (iii), and in (iv) and (v), $B=\emptyset$"); `cor:terms:table` (dagger on rows 3, 4 and in the "Hence" sentence); `prop:terms:a1fit`, `thm:terms:binary` (via its setting paragraph), `cor:terms:ontology`, `cor:terms:freededuction`, `prop:terms:ontology` all open with "Let $B=\emptyset$"; `sec:terms:craig` and `sec:terms:ontology` say "with empty background"; §8.5 says "$B=\emptyset$" | yes (`terms` §1.2: literal data with a background assume the fresh-atom setting; the proofs build models of the hypothesis alone) |
| B1 / SOI-08 (Table 1) | $B=\emptyset$ for the finite and observational rows | yes: the block was merged by SOI-L1 list B; its row reads "finite theories need a binary relation or entities ($B=\emptyset$)" | yes |
| B2 / TER-02 | "no finite first-order theory in pure equality, or in pure equality with unary predicates added, has the same consequences" | yes (`sec:terms:finite`) | yes (`terms` Prop 7.1(c)); no phrasing that a function is what a finite theory needs |
| C1 / LAW-01 | regime-G refutation probabilities: sinusoid $0.218$, $6.0\times10^{-4}$, $0$; peaked $0.025$, $5.0\times10^{-4}$, $0$ | yes (`app-laws.tex`, "Computations." after `prop:laws:choice`) | yes: `laws/referee_code/rb1_dither_exact.out` §E: sinusoid $2.180\mathrm e{-1}$ (1.00), $6.005\mathrm e{-4}$ (1.49), $0$ (1.50); peaked $2.500\mathrm e{-2}$, $5.000\mathrm e{-4}$, $0$ |
| PHIL-04 / LAW-08 | retitle `prop:laws:kink` "Robustness to the balance is a kink"; replace the sentence after the proof idea; no quotation of Lewis | yes, verbatim | yes (`laws` Prop 5.6 and its reading) |
| PHIL-01 / cons. 3, scope parts | SOI-03: "How to read the table" ends with the U1 text for §4 and says "the separations we know come from …"; SHA-05: "In this model it becomes visible when what is written, or the time to write it, is charged." | yes, verbatim in both | yes |
| consistency 1 (length moves BAS-L1/L2, SOI-L1, LOG-L1, SHA-L1, TER-L1, LAW-L1) | moves to the owning appendix with one main-text sentence that keeps every hypothesis and hedge; no result dropped | yes: every label listed as moved in `logs/edit-front.md` §3 resolves in its appendix, and every summary sentence was compared with the moved statement (§2 below, items marked "summary") | yes, with no strengthening found (see §2) |

Minor issues of the scope groups were also spot-read (not required): BAS-01–08, SOI-02, -04, -05, -06, LOG-01–05, SHA-01–04, TER-03–08, LAW-02–07, -09, -10 are all in place as decided.

## 2. Spot checks against the records

Twenty-seven statements of the scope were compared with the thread records (statement, hypotheses, quantifiers, constants, status) and with their `CLAIMS.md` rows. "Summary" marks a main-text sentence that stands for a statement moved to an appendix by the length pass; it was compared with the moved statement and with the record.

| # | paper item | record item | result |
|---|---|---|---|
| 1 | `thm:soi:coinfree` | `sfi` Thm 2.1 | match (constants, finiteness iff consistent, outcome weights against $\Wcl$, loss corollary) |
| 2 | `thm:soi:onetape` | `sfi` Thm 3.1 | match (empty $D$ included; tape-by-tape inclusions) |
| 3 | `thm:soi:transfer` and the summary of `cor:soi:transfer` | `sfi` Thm 5.1, §5.5; final-check §4 items 1, 4 | match: "up to additive constants", and the four excluded kinds of statement are named |
| 4 | `prop:soi:closure` and the paragraph after it | `sfi` Prop 6.1 | match, including "in the semimeasure convention" and the normalised-convention clause (final-check item 9) |
| 5 | `prop:soi:independent` | `sfi` Lemma 6.3′, Props 6.3, 6.5 | match (consistent $B$ with $\Q\subseteq\Cn(B)$; status "given the productivity lemma and, one-tape, the Lebesgue density theorem") |
| 6 | `thm:soi:diagonal` | `sfi` Thm 7.4 | match, with the last sentence restricted to $P^\ast$ as decided (a weakening) |
| 7 | `prop:soi:freededuction` | `sfi` Prop 7.6(a), (b) | match; (c) is the separate proof sketch `rem:soi:freededuction` (final-check item 10) |
| 8 | summary of `prop:soi:presburgerCharged` (§4.7) | `sfi` Props 9.4, 9.4′, Rem 9.5 | match: doubly exponential for size and material, exponential for (a1); (a1) doubly exponential, (a2), (b2) open |
| 9 | `thm:basic:inc` | `fundamentals` Thm 3.2 | match ((c) given Chaitin and Levin–Schnorr) |
| 10 | `prop:basic:chain` | `fundamentals` Prop 6.1 | match |
| 11 | `thm:basic:nocoding` | `fundamentals` Thm 6.2 | match ($\ell_d$, the tail bound, $K(\lceil\log(d+1)\rceil)$) |
| 12 | `prop:basic:cr` | `fundamentals` Prop 7.1 | match |
| 13 | summary of `prop:basic:mistakes` (App A) | `fundamentals` Prop 5.3 | match (order refining length; the hypothesis is needed) |
| 14 | summary of `prop:basic:crorder` (App A) | `fundamentals` Prop 7.2(a), (b) | match |
| 15 | summary of `thm:basic:merging`, `cor:basic:threeloss` | `fundamentals` Thm 5.4, Cor 5.5 | match ($\nu_G(\emptyset)=1$; questions from the history and independent randomness; $<K(G)$) |
| 16 | `thm:logic:lottery` | `logic` Thm 2.2 | match |
| 17 | `thm:logic:arith`, `cor:logic:false` and the sentence after the theorem | `logic` Thm 2.9, Cor 2.10 | match; LOG-02's wording is correct against the construction of $j^*_k$ |
| 18 | `thm:logic:threshold` and the $T_k$ sentence | `logic` Thms 3.1, 3.2 | match (LOG-01: $\Unif(O_\pi)$ for the level, $\Bel_0(\pi)\ge2^{-k}$ for $T_k$) |
| 19 | summaries of `cor:logic:chaitin`, `prop:logic:normalised` | `logic` Cor 3.6, Prop 3.11 | match (semimeasure and three-valued conventions; $B$ true with $\PA\subseteq\Cn(B)$ for the normalised statement) |
| 20 | summaries of `thm:logic:goedelomega`, `rem:logic:closures` | `logic` Thm 5.3, §5.4 | match (decidable true $B\supseteq\PA$, given (G2); the generative variant only with the universal sentence among the data) |
| 21 | paragraph `sec:logic:thn` | `logic` Thm 6.1, Cor 6.2 | match ($\xi\ge0.0823$ is the record's $\delta\ge0.08234$, a computer-checked certificate) |
| 22 | `thm:shape:invisible`, `thm:shape:visible` and the time-charged sentence | `shape` Thms 1.11, 1.12 | match |
| 23 | `thm:shape:systems`; `prop:shape:depth` (App E) and its summary | `shape` Thm 3.6, Prop 3.8 | match; (d) weakened to "for each fixed $k$" as decided (SHA-02) |
| 24 | directionality paragraph (§7.6) | `shape` Prop 4.2, Thm 4.3 | match (factor $m$ over the base variables or with one round; at most the clause width, at most $9$ in written length with intermediate concepts and unbounded rounds) |
| 25 | `thm:terms:dilemma`; `cor:terms:table` (App F) | `terms` Thm 8.1, Cor 3.5; final-check items 7, 8 | match, with $B=\emptyset$ added (B1) |
| 26 | §8.5 infinity sentence | `terms` Thm 6.2, Prop 7.1(c) | match ("computable unbounded nondecreasing", TER-03; pure equality or with unary predicates, TER-02) |
| 27 | `prop:laws:errormodel`; `prop:laws:kink`; the regime-G and regime-R sentences of §9.2 | `laws` Prop 3.6a, Prop 5.6, Cor 2.2, Props 2.4, 2.5 | match (thresholds $1.79$ and $2.12$; (a)–(c) with a hull vertex; $\delta\ge\varepsilon^*+\delta_0$) |

No statement in the scope was found stronger than its record, missing a hypothesis, or with a status stronger than the record's.

## 3. Computed numbers against saved outputs

Every number in the scope that a computation produced was traced to a saved output in `research/tracks/<key>/checks/` or `referee_code/` (or, for two arithmetic identities, recomputed). Method: a throwaway script in the scratchpad (not part of the record) listed every decimal and every integer of three or more digits outside `\status`, `\src`, labels and citations, and searched the saved outputs of the section's thread; every number it did not find, and every table, was then compared by hand with the output line it comes from.

* **§5 / App C** (`logic`): $0.288788$ and the products for $K\le5$ (`c1_lottery.out` A1); $\xi\ge0.0823$, $x_0=1000/5385$, $T^*\approx0.800042$, $F^*\approx0.609287$, $C=0.7482$, $\kappa=5.385$, no certificate at $5.38$, growth about $5.383$ (`c6_revision.out` R4); the critical value for $s\le12$ (`c6` R6, `rb2` A) and the $166$ families on four sentences (`rb2` B); the block criterion on structures with at most five elements and two blocks (`rb1` A: 14 sentences, 16384 subsets); $n\le60$ (`rb7`).
* **App B** (`sfi`): thresholds $11$–$26$ and $6$–$9$ for $c=1$, $c'=0.9$ (`c3_presburger_constants.out` (A), (B)); circuit-translation sizes (`c4_circuit_axioms.out` (iv)). **Corrected:** the text said $\lvert T_{\mathcal V}\rvert$ "stays between $7.9$ and $9.0$" times $(\lvert\mathcal V\rvert+d)\log(\lvert\mathcal V\rvert+d)$ "for sizes from 33 to 1099 gates", inside a sentence about circuits with $d\in\{2,3\}$; the output gives the ratios $9.03$, $8.78$, $8.11$, $7.86$, $8.03$ for $d=3,8,16,32,32$. Now "for sizes from $33$ to $1099$ gates with $d$ from $3$ to $32$, … between $7.86$ and $9.03$". (The record, `sfi` §10, has the same rounding; it was not edited.)
* **§7 / App E** (`shape`): Kraft sum $0.2525$ (`c7` J); simplex minima $56$, $1920$, $1015808$, $1.35\cdot10^{11}$, $1.2\cdot10^{21}$ and $2352$ literals (`c1` E); the $d_*=2$ example ($4$ against $8$; `c1` D, as the record reads it); equivalence-law minima (`c7` G); twelve laws (`c7` C); ratios $65$, $137$, $256$, $461$ and rounds $7$, $5$ (`c7` E); fractions $0.62$–$0.89$ (`c7` K: $0.623$–$0.885$); $q=3,4$ (`c7` M); rounds $1,3,4,5,5,5,6,7$ (`c7` D); rules for $m=2,\dots,7$ (`c7` F, `c3`); $9852$ clauses on $30$ laws (`c3`); $330$ checkpoints (12, 12 and 6 runs of 11 checkpoints, `c5`) and $21.74$, $54.09$, $129.87$ (`c7` L); the spanner table (`c6` B for $m\le16$, `refB_t7_conj` for $m=17,18$) and the conjecture for $m\le18$.
* **§8 / App F** (`terms`): $10^{204.6}$, $795$, $702$, $N_{\rm cand}$, $L^*$, $\mathrm{ds}_T$ (`t6_revision.out`, `rb8`); $24480$, $21830$, $37$ of $40$ (`t1`) and the three backgrounds (`rb7`); $800$ elements, $583200$ triples (`t4_two_stack` A), $552$ (`rb2`); $2046$, $14322$ (`t3`); $R(t_{0110})$ on three machines (`t6`); $3017$, $318$ of $12519$, $140$ and $274$ rules with their ranges (`t4_two_stack`); $90$ of $1500$ automata and the regular languages at $\lvert w\rvert\le9$ and $\le8$ (`t6` F, `t4_regular`, `rb4`); $200$ of $200$ (`rb2`); $13$ sentences, $3969$, $1023$ and the counts $5,7,9$ (`t6` E, `t4_regular` B); $185$ and $40$ structures (`rb3` C); no model of $\mathrm{Dinf}_f$ up to $7$ (`rb6` C); $64k+13$, $6560$, the bit-bound ratios (`rb6` B, `t5`, `t6` G); $1200$ sentences (`rb3` D: $4\times300$). **Corrected:** "confirms the least sizes $n_An_B$ without $\mathrm{Mid}$ and $\min(\dots)$ with it for all ten pairs up to $(3,3)$": `t6_revision.out` Part C did not search the size without $\mathrm{Mid}$ at $(3,3)$ ("not searched"), and the record (`terms` Prop 7.2, status line) says "(b) for 9 pairs with $n_An_B\le6$, (d) for 10 pairs up to $(3,3)$". Now "… without $\mathrm{Mid}$ for the nine pairs with $n_An_B\le6$, and … with it for all ten pairs up to $(3,3)$".
* **§9 / App G** (`laws`): 271 of the 291 numbers of App G matched the outputs directly; the other 20, and every table, were checked by hand: the regime-G probabilities (`rb1` E); the repeated-times computation ($0.40$, $1.96$, $3.23$, $0.240$, $0.037$, $0.022$, $0.030$; `ra1` E); the exception codes (`l10` G); the retention table and its ratios ($1.8$–$6.9$, $3.9$–$11$, $7.6$–$16$; `l10` F, every entry); the Moon table (`l10` E, every entry, including the $600'$, $\lambda=2$ cell, $2.6933$ against $2.6939$); the correction table (`l9`, every entry); `tab:laws:residuals` (`l10` A, every entry); $429$ cells, SH $0.4\%$–$25.7\%$ below the band (median $6.6\%$), $379$ of $429$, $34$ of $39$, best $\rho$ between $0.52$ and $0.997$ ($1-s^*$ over the 34 pairs: $0.523$–$0.997$), the five pairs and their peakedness $1.60$–$1.96$, the $0.0011$-bit gap to the Gibbs bound (`l10` A–C); $c_{\rm time}$ $14.1$–$21.5$ and $6.8$, $10.5$, $14.7$ ($\log_2$ of the window's days plus $2$); the takeover widths at $\lambda=2,4$ and the $17$ of $39$ pairs (`rb3`); $7.96\varepsilon$ (`l6` C: $7.959$); $(7.03,135.37)$ (`l7`); $94$ data, $94.1$, $942.7$ (`l2` B). In the main text, the Moon "about a degree within a month" and Mars "one or two arcminutes over a few decades" agree with `tab:kepler:residuals` ($1.12^\circ$; $1.58'$, $1.86'$).
* **§2–§4, App A**: no computed number outside the statements (the constants $0.361$, $1.37$, $1/(4\ln2)$ are analytic).

All computed numbers in the scope are outside theorem-like statements.

## 4. arXiv-readiness greps

**On the scope sources** (comments, `\status{…}`, `\src{…}`, labels, references and citation keys removed by a throwaway script):
* Process vocabulary, with the pattern of DECISIONS rule 0.8 plus `\bSFI\b`: one hit, "Simulate the tapes on tracks of one tape" (`app-terms.tex`, multitape simulation), which is mathematics. No "thread", "scout", "referee", "record", "synthesis", "verdict", "revision", "unverified", "abstract level", "AI-paper", "TF", "SD", "P1/P2" or "H1–H15".
* Model names (`opus|sonnet|haiku|claude|gpt|gemini|anthropic`): 0 in all 13 files.
* Hänni's notes: exactly the six credit footnotes of the scope (F1 `setting.tex`, F2 `soi.tex`, F4 `shape.tex`, F5 `logic.tex`, F6 `laws.tex`, F8 `terms.tex`), each a short neutral sentence ending "… first appeared in / are discussed in / is argued in Hänni's working notes \citep{hanni2026notes}"; no quotation of or reply to the notes.
* Citations: the scope cites 120 keys; all are in `bib/all.bib`, none carries a comment recording a failed or partial verification that the text exceeds, and none is on the "not citable" list of `bib-report.md` §5.3. The restricted ones were read in context: Löwenheim and Behmann only for the decidability of monadic logic; Fischer–Rabin "under a proviso on their measure of length" (no length convention attributed); Berman only for completeness for alternating doubly exponential time with linearly many alternations, with (B$^*$) and the reduction sizes not attributed (SOI-06); the modified Demski prior "at the level of the published descriptions" / "for the process as described in those works"; Bienvenu et al. without theorem numbers; Gold without a theorem number.

**On `pdftotext main.pdf`** (after the final build below):
* Rule-0.8 pattern: the only non-mathematical hits are the title-page footnote's "referees", "the revision of the base abstractions" (§11), "Intelligent Agent Foundations Forum" (a venue in the bibliography) and "tracks of one tape" (App F); the rest are symbols ($H_2$, $p_1$, $P_1$, $\Sigma^p_2$). "referee" occurs once, in the title-page footnote.
* Model names (`opus|sonnet|haiku|claude-[0-9]|gpt|gemini`): 0.
* "SFI": 0.
* Printed status tags (`\[(proved|computed|conjecture|known|proof sketch|refuted|remark|assessment)`): one hit, "P[not proved]" in App G, a probability.
* "Hänni" occurs only in the author line, the title-page footnote, the credit footnotes, the acknowledgements, the bibliography and citations of the companion works (§U7 forms).

## 5. Full build

Isolated builds after the two edits: `./test-section.sh soi app-soi` (30 pages) and `./test-section.sh terms app-terms` (29 pages): 0 errors, 0 undefined citations, 0 overfull boxes above 10pt.

Full build, `cd paper && flock /tmp/claude-0/paper-build-sai.lock ./build.sh`, run once after both edits:
* LaTeX errors 0; undefined references 0; undefined citations 0; multiply defined labels 0; overfull boxes above 10pt 0; no "Float too large".
* Largest overfull boxes: $8.37$pt (`tab:laws:residuals`, `app-laws.tex`), $2.02$pt twice (`app-terms.tex`), $0.82$pt (`setting.tex`), $0.67$pt (`shape.tex`).
* `merge_bib.py`: 299 entries (core 6, refs 293, fallback 0); 219 cited keys, 0 missing, 0 from the fallback. BibTeX: one warning, the intentional empty publisher of `shapiro1991inductive` (the build script counts it twice).
* **223 pages.** Main text (heading of §1 to the heading of the references, measured from word positions in `pdftotext -bbox`, fractions of the text block of p. 10; throwaway script in the scratchpad): **50.36 pages**, pdf pp. 2–52, against the front group's 50.38 with its own script (the difference is the estimate of the text block; the two edits of this check are in appendices and do not move the main text). Per section: §1 2.96, §2 3.77, §3 4.55, §4 5.79, §5 5.16, §6 4.81, §7 4.68, §8 3.89, §9 3.64, §10 4.36, §11 2.62, §12 2.45, §13 (with acknowledgements, code and data) 1.67. References from p. 52; appendices A–I pp. 65–223 (A from p. 65, B 88, C 110, E 138, F 159, G 182, as printed in the contents).

## 6. Changes made

1. `sections/app-soi.tex`, computation paragraph after the proof of the verifier-circuit translation: "and $\lvert T_{\mathcal V}\rvert$ stays between $7.9$ and $9.0$ times … for sizes from $33$ to $1099$ gates" → "; and, for sizes from $33$ to $1099$ gates with $d$ from $3$ to $32$, $\lvert T_{\mathcal V}\rvert$ stays between $7.86$ and $9.03$ times …" (§3).
2. `sections/app-terms.tex`, computation paragraph after the proof of `prop:terms:factoring`: "confirms the least sizes $n_An_B$ without $\mathrm{Mid}$ and … with it for all ten pairs up to $(3,3)$" → "… without $\mathrm{Mid}$ for the nine pairs with $n_An_B\le6$, and … with it for all ten pairs up to $(3,3)$" (§3).

## Summary

All fatal and major issues of DECISIONS.md in the scope are fixed as decided, and the fixes agree with the thread records. Twenty-seven statements were spot-checked against the records and `CLAIMS.md` with no mismatch in hypotheses, quantifiers, constants or statuses. Every computed number in the scope was traced to a saved output; two small inaccuracies in appendix computation paragraphs were corrected (§6). The arXiv-readiness greps are clean, and the full build has no errors, undefined references or citations, multiply defined labels or overfull boxes above 10pt; the main text is 50.36 pages by this check's measure (accepted budget: 50.38).

## Verification log

* **Read in full:** `research/00-brief.md`; `research/final-check.md`; DECISIONS.md §V, §0, §U, §L, §G (all groups), §X, §R, §F; the scope's main-text files `setting.tex`, `basic.tex`, `soi.tex`, `logic.tex`, `shape.tex`, `terms.tex`, `laws.tex`; `logs/edit-front.md` §1 (end), §2–§5.
* **Read in part:** the scope appendices at every moved statement, every fix location of DECISIONS §G and every computation paragraph; the thread records `sfi` §2, §3, §5, §6.1–§6.2, §7–§9, §10 (computed paragraph); `fundamentals` Thm 3.2, Props 5.3, 6.1, Thm 6.2, Props 7.1, 7.2; `logic` Thm 2.2, Prop 2.3, Thms 2.9, 3.1, 3.2, Cors 2.10, 3.6, Prop 3.11, Thms 5.3, 6.1, Cor 6.2, §5.4; `shape` Thms 1.11, 1.12, 2.6, 3.6, Rem 3.2a, Prop 3.8, Cor 3.9, Prop 4.2, Thm 4.3, the checks paragraphs of Rem 2.9 and Thm 6.2; `terms` §1, Cor 3.5, Thms 6.2, 8.1, Prop 7.2's status line; `laws` Props 2.1–2.5, 3.6a, 5.6 and the §3.6, §6, §7 computation lines; `CLAIMS.md` §0 and the rows of the spot-checked labels; `bib/bib-report.md` §1, §5.3.
* **Saved outputs read:** `sfi` `c3_presburger_constants.out`, `c4_circuit_axioms.out`; `logic` `c1_lottery.out`, `c6_revision.out`, `rb1_lottery_models.out`, `rb2_majority_tight.out`, `rb7_kreisel.out`; `shape` `c1_linear_noaux.out`, `c3`, `c5_learning.out`, `c6_spanners.out`, `c7_revision.out`, `refB_t2_linear.out`, `refB_t7_conj.out`; `terms` `t1`, `t3`, `t4_two_stack.out`, `t4_regular.out`, `t5_monadic.out`, `t6_revision.out`, `rb2`, `rb3`, `rb4`, `rb6`, `rb7`, `rb8`; `laws` `l2_precision.out`, `l3`, `l5`, `l6_horizons.out`, `l7`, `l8_domains.out`, `l9_correction.out`, `l10_revision.out`, `ra1_checks.out`, `rb1_dither_exact.out`, `rb3_selection.out`. No script was re-run (the numbers were compared with the saved outputs, as asked).
* **Run:** two isolated builds and one full build (§5); `pdftotext` and `pdftotext -bbox` on `main.pdf`; throwaway scripts in the scratchpad (`fcm/`: `comp.py`, `nums.py`, `strip.py`, `measure.py`), none part of the record. No git command was run.
* **Files written:** this file; the two edits of §6 in `sections/app-soi.tex` and `sections/app-terms.tex`. The rebuilt `main.pdf` and build logs. Nothing else in the repository was changed.
