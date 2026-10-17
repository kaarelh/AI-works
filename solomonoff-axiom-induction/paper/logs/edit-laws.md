# Edit log: group "laws" (§9 `sections/laws.tex`, Appendix G `sections/app-laws.tex`)

*2026-10-17. Editor pass after the review. Binding: `review/DECISIONS.md` and `review/issues-laws.json`. No git command was run. Only `sections/laws.tex` and `sections/app-laws.tex` were edited.*

**Status: phase 1 done.** All 12 issues are done (§1). Page counts are in §4, requests to other groups in §5.

## 0. Restart check

When this run started there was no `logs/edit-laws.md`. Both files still had the writer's timestamps (13:54), which are older than the issue list (15:59). So no earlier edit run had changed them, and the edit started from the writer's version. Copies of the intermediate versions are in the session scratchpad, folder `laws-editor/`; they are not part of the paper.

## 1. Issues

| id | what changed | where |
|---|---|---|
| **LAW-01** (major, C1) | The regime-G refutation probabilities are now given per error: $0.218$, $6.0\times10^{-4}$, $0$ for the sinusoid, and $0.025$, $5.0\times10^{-4}$, $0$ for the peaked error, with "positive below $\varepsilon^*+\delta_0$ and zero above it for both". Wording as decided. | `app-laws.tex`, `app:laws:precision`, paragraph "Computations." |
| **LAW-02** (minor, C2) | Main text uses the corrected bound, word for word as decided: at most $\log(2\varepsilon^*/\Delta)+\log\mathrm e$ when $\Delta\le2\varepsilon^*$, below the literal cost iff $\varepsilon^*<\mathsf R/(2\mathrm e)$; at most $(2\varepsilon^*/\Delta)\log\mathrm e<\log(\mathsf R/\Delta)$ when $2\varepsilon^*\le\Delta<\mathsf R/\mathrm e$. | `laws.tex`, `sec:laws:domains`, paragraph `rem:laws:domainlearning` (after LAW-L1 item 4 this is the section's only paragraph) |
| **LAW-03** (minor, C5) | The statement now reads "its minimisers on $[0,\varepsilon^*]$ are the $\varepsilon$ with $\Prob[\lvert e\rvert>\varepsilon]\le\theta_{\rm ex}$ and, if $\varepsilon>0$, $\theta_{\rm ex}\le\Prob[\lvert e\rvert\ge\varepsilon]$". The proof adds "(at $\varepsilon=0$ only the right derivative matters)". | `app-laws.tex`, `prop:laws:quantile` and its proof |
| **LAW-04** (minor, C7) | Now "up to about $10^{10}$ at $r=30$" and "by up to about $7\times10^{13}$". | `app-laws.tex`, paragraph after `prop:laws:horizon` |
| **LAW-05** (minor, C8) | Now "we fitted one Kepler ellipse four ways and kept the fit with the least largest longitude error (the minimax fit) and the one with the least mean error (the mean fit)". | `laws.tex`, paragraph "Kepler's residuals." |
| **LAW-06** (minor, C9) | Now "$U$ is $k$ within one system when each part of the data identifies the parameter, $0$ across systems with independent parameters, and the bits of a shared constant across systems that share one and each identify it". | `laws.tex`, `sec:laws:explain`, first paragraph |
| **LAW-07** (minor, C10) | Both places now read: "Newton's theory does not entail Kepler's laws; with the planets' masses and initial conditions it contradicts their exact form (cf. Duhem) and derives corrected statements". The main text ends the sentence there. The Schaffner clause ("as in reduction to a corrected reduced theory") is kept in App G only. | `laws.tex`, `sec:laws:explain`, second paragraph; `app-laws.tex`, paragraph before `prop:laws:correction` |
| **LAW-08** (major, PHIL-04) | Retitled "Robustness to the balance is a kink", with the label unchanged. The first sentence after the proof idea is replaced by the decided text: the hull-kink sentence; "one aspect of what Lewis calls a kind nature (cf. Lewis 1994)" with the measures of simplicity and fit held fixed; and the failure among the compatible Mars forms, with `\cref{sec:kepler:pool}`. Lewis is not quoted. The App G sentence that had "kindness is a checkable property" now says "robustness to the balance (\cref{prop:laws:kink}) is a checkable property". Neither file uses "kind nature is" or "kindness" any more. | `laws.tex`, `prop:laws:kink` and the paragraph after it; `app-laws.tex`, `app:laws:best` |
| **LAW-09** (minor, consistency 13) | Caption sentence added: "Largest longitude errors of the minimax fit; the least-squares fits of \cref{tab:kepler:residuals} measure angular separation and differ." The main text has "($\varepsilon^*=2.6^\circ$ over a year, minimax fit)". | `app-laws.tex`, `tab:laws:residuals`; `laws.tex`, `rem:laws:domainlearning` |
| **LAW-10** (minor, consistency 16) | "every verdict below is the same" became "every comparison below comes out the same for the three values". | `app-laws.tex`, paragraph "The Kepler residuals." |
| **LAW-X19** (minor, consistency 19) | Applied §U7. The first mention in §9 is "Definition~3.6 of the companion paper on steeper priors \citep{claudeSFI2026steeper}", in `def:laws:setting`(b). The first mention in App G is "Proposition~5.7(ii) of the companion paper on steeper priors \citep{…}", in the proof of `prop:laws:twopart`(d). Every later mention reads "Lemma~3.8 of the companion paper on steeper priors", "Definition~5.2 there", and so on, with no citation command. No `\citet`/`\citep` of the companion works remains apart from those two. Item numbers are unchanged. The other two companion works are not cited in these files. | both files; 4 places in §9, 10 in App G |
| **LAW-L1** (major, consistency 1) | List A items 1–5 and list B items 1–2 were applied (§2). §9 went from 5.45 to 3.57 pages in the isolated build (target 3.5, at most 3.75). | both files |

## 2. Length moves (LAW-L1) and labels

**Moved labels** (statement, `\status` and `\src` unchanged except LAW-08's title; checked by script against the writer's version):

| label | from | to |
|---|---|---|
| `prop:laws:rounding` | §9.2 | App G, `app:laws:precision`, directly before its proof. "Proof of …" became a plain proof. |
| `rem:laws:typical` | §9.4 | App G, `app:laws:sound`, after the paragraph that follows `prop:laws:horizon` (it has no proof) |
| `def:laws:EP` (list B 1) | §9.5 | App G, start of `app:laws:best` |

**New label:** `def:laws:settingfull` ("The setting in full, continuing \cref{def:laws:setting}"), at the start of App G, `app:laws:setting`. It holds:
* $\dom D$, $y_D$ and $A_T$;
* $J^Q_\lambda$, $J^F_\lambda$, $J^R_\lambda$;
* RCF decidable and complete (Tarski) and the rational range;
* the presentation language with total computable maps;
* clipping of the honest law;
* finitely many cells with rational endpoints;
* the formula for $P^R_T$ with $C_t$, read as the probability of uniform completion;
* regime G in full ($v_j$, $\zeta_j$);
* regime R in full (circle, fresh times, $e_j$, $\mathsf R/\Delta$ an integer, the dither $u_j$).

No label was renamed or removed. All section and paragraph labels of §9 remain (`sec:laws:setting`, `sec:laws:strength`, `sec:laws:random`, `sec:laws:sound`, `sec:laws:best`, `sec:laws:explain`, `sec:laws:domains`, `rem:laws:domainlearning`).

**List A.**
1. `def:laws:setting`: (a), (b) and (e) are kept. Notation used only in App G was moved to the continuation: $\dom D$, $y_D$, $A_T$, $J^{Q,F,R}_\lambda$.
   * (b) defines code R in words ("the probability of the data when the law's interval is completed uniformly at random") and points to `def:laws:settingfull`.
   * (c) keeps the interval law, $T_0$, $T^\varepsilon$ and one sentence on interval data.
   * (d) keeps regime R compactly (with $e_j$, $p_\Delta$, $s_\Delta$, and $\mathrm e$ as Euler's number, which the main text uses and no longer defines elsewhere) and regime G in one clause.
   * The definition is now a run-in paragraph with (a)–(e) inline, about 2,300 bytes including markup.
2. `prop:laws:rounding` and the paragraph after it moved to App G.
   * The main text has the decided sentence, lightly copy-edited: "In regime R the exact law survives $n$ data with probability $(1-p_\Delta)^n$ and is almost surely refuted eventually iff …; with a sinusoidal error of amplitude $1'$ it is refuted by positions rounded to a dithered grid of $1^\circ$ after about $94$ data".
   * The following paragraph is in App G after the proof, with the novelty sentence and the AIC/MDL/MML citations.
3. §9.4 is one paragraph of about 800 bytes, covering `prop:laws:sound`, `prop:laws:horizon`, `prop:laws:exacthorizon`, `rem:laws:typical` and `sec:limits:domains`. It includes the decided worst-case sentence, with "with Lipschitz constant $1$" added (the remark's hypothesis $L=1$).
4. §9.7 is the single paragraph `rem:laws:domainlearning`, with C2's bound and LAW-09.
   * Its status is now "assessment, resting on prop:laws:domain and prop:laws:retention (proved; computed)".
   * Three claims from the old text moved to App G, after the Moon table: the "every planet and window, and the Moon over three windows" claim, the "sharp boundary only when …" clause, and the `q:laws:domains` pointer, which is now the question environment that follows. The first claim was checked against laws record §8.
5. Shortened: the opening (keeps footnote F6), the lead of §9.3, the proof idea, the paragraph after it, "Kepler's residuals", the hull paragraph, the kink paragraph, the paragraph on explanatory power, and §9.6.

**List B** (applied, because after list A the main text was still at 3.74–3.93 pages):
1. `def:laws:EP` moved to App G. §9 now has: "The explanatory power $\EP_D(\mathcal A;T)$ of a module $\mathcal A\subseteq T$ is the bits of data it explains per bit of its statement, in the context $T$ (\cref{def:laws:EP})".
2. The Copernicus sentence is now "Copernicus against Ptolemy is unification without better prediction (\cref{prop:laws:copernicus})". The history citation (Kuhn) and "the lengths … are not measured" are in App G, directly before `prop:laws:copernicus`.

**Claims cut from §9 and kept in App G** (rule 0.3: no claim is lost):
* "SAI is the best two-part code …": the steeper-penalty collapse and the reason for laws with private literal facts. New sentence after the proof of `prop:laws:twopart`.
* The kink toy (planet, asteroid and comet counts; $\lambda\in(7.03,135.37)$, changes below 7) and the Woodward sentence. New paragraph after the follow-up to `prop:laws:K3`. That follow-up's `\cref{sec:laws:best}`, which had pointed to the main-text description of the population, now describes the population in place.
* "elements explain hundreds of bits per bit", in the same new paragraph.
* "at $\lambda=1$ a module pays iff its EP exceeds 1, the compression criterion of ILP" (Muggleton, Srinivasan). Moved to the end of the Myrvold paragraph after `prop:laws:EP`. Without the move these citations would have been lost.
* "validated perturbation bounds (\cref{sec:kepler:newton})". Added to the paragraph before `prop:laws:correction`.
* "eleven cell widths from $0.1'$ to $30^\circ$" and "the residuals are deterministic functions of time …". Added to "The Kepler residuals".
* The precise Q/det criterion $\lambda c_{\rm time}>\gamma(2\pk(e)-1)$ was already in App G after `prop:laws:peaked`. §9 now states it qualitatively: the threshold on $\pk(e)$ is set by the prices of an exception and of silence, for $\Delta\ge2\varepsilon^*$.
* The Band-confined completions paragraph in App G no longer says "the claims made in \cref{sec:laws}". It now gives $K(\mathrm{BC}_{\mathcal G})\le\lVert T^\varepsilon\rVert+K(\mathcal G)+c$ directly, since §9 no longer states it.

The U3-consistent wording "not of the axiom view as \SAIabbr formalises it" replaces "as such" in the opening. This is a weakening, matching the canonical text.

## 3. Checks

* **Mathematics.** No statement was changed except LAW-03 (as decided) and LAW-08's title. Moved environments are byte-identical to the writer's version (checked by script).
* The summary sentences were checked against `research/tracks/laws/notes-final.md`: Prop 2.4, 2.5, 3.5, 3.6a, 5.6, 5.8, 6.1, 7.1, Rem 4.4, §3.6 and §8. Hypotheses that the summaries keep:
  * $\Delta\ge2\varepsilon^*$ for the peakedness comparison;
  * "when the background decides the comparisons" for the explosion of exact models;
  * $L=1$ for the worst-case remark;
  * "among the Kepler-based theory machines compared";
  * "each part of the data identifies the parameter".
* **Saved outputs** checked for LAW-01 (`laws/referee_code/rb1_dither_exact.out`, part E) and LAW-04 (`laws/checks/l6_horizons.out`, part B: 8.5e9, 6.78e13).
* **Final greps (rule 0.8)** on both files, outside comments and `\status`/`\src`: no hits. No model names. "kind nature is" and "kindness" are gone. The only "verdict" was LAW-10's, and it is fixed.
* **Credit footnote F6** is kept in the opening of §9.
* **Isolated builds.**
  * `./test-section.sh laws`: OK, 5 pages; 0 undefined citations; 36 undefined references, all to other sections; 0 overfull boxes.
  * `./test-section.sh laws app-laws`: OK, 31 pages; 0 undefined citations; 19 undefined references, all to labels of other groups (`def:setting:questions`, `prop:basic:*`, `thm:basic:*`, `rem:terms:named`, `prop:shape:E2`, `sec:kepler*`, `tab:kepler:residuals`, `sec:limits:domains`); 0 multiply defined labels; 0 LaTeX errors; 0 overfull boxes.

## 4. Page counts

Measured as in §L1: the position of the last main-text line relative to the text block, from `pdftotext -bbox` of the isolated build. The script is in the session scratchpad, `laws-editor/measure_laws.py`.

| part | before | after | target |
|---|---|---|---|
| §9 main text (isolated, refs to App G resolved) | 5.45 | **3.57** | 3.50 (cap 3.75) |
| Appendix G | about 25.5 | about 25.9 | not capped |

The 5 references to other groups' labels print as "??" in the isolated build; resolved, they add at most about one line. Source size of §9 without comments: 26,089 → 16,939 bytes.

## 5. Requests to other groups

* **front (FRO-20, `app-notation.tex`).**
  * The rows that point to `def:laws:setting` stay correct: $(\mathcal Q,a)$, $\gamma$, $\ell$, $\lVert\cdot\rVert$, $\Exc^{Q,F,R}$, $\lambda$, $J_\lambda$, $\lambda$-MAP, $T_0$, $T^\varepsilon$, $e$, $\varepsilon^*$, $\delta$, $\delta_0$, $\Delta$ and $\pk$ are all still defined there.
  * If rows are added for $P^R_T$, $A_T$, $\dom D$, $y_D$, $\zeta_j$, fresh times or $J^{Q,F,R}_\lambda$, point them to `def:laws:settingfull`.
  * The row for $\EP_D$ still points to `def:laws:EP`, now in App G (`app:laws:best`).
  * The row for $\mathrm{BC}_{\mathcal G}$ and $\mathrm{HY}(\rho)$ still points to `sec:laws:random`, which still defines them.
* **front (FRO-06, `intro.tex` item 10).** `\cref{prop:laws:kink,def:laws:EP}` now prints a §9 proposition and an Appendix G definition, which DECISIONS foresees. The proposition's new title is "Robustness to the balance is a kink".
* **phil.** `phil.tex` cites `\cref{def:laws:EP}` ("the explanatory power of \cref{def:laws:EP} gives one precise measure of …"), which now resolves to Appendix G. The wording still fits.
* **kepler / limits.** Two citations of moved labels still read correctly:
  * `app-kepler.tex` (moved there by the kepler group) cites `prop:laws:rounding`, now in App G.
  * `limits.tex` cites `rem:laws:typical`, now in App G, and `rem:laws:domainlearning`, still in §9.
  * §9 and App G cite `sec:kepler:pool`, `sec:kepler:newton`, `tab:kepler:residuals` and `sec:limits:domains`. Please keep these labels.
