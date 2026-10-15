# Paper 2: final check after the imitation integration and its fix round (2026-10-14)

*Fresh final checker. Object: `paper-steeper/` after `log-integrate.md` and `log-fix.md` (both in this folder); `main.pdf` at the start of this check had SHA-256 prefix `4b3df9749519ab5f`, the value `log-fix.md` §4 records. The check covers the author's three requests (verbatim in `research/tracks/imitation/00-brief.md`): (1) λ = cn compared with weight decay; (2) an imitation thread, only if the result is good; (3) clear caveats. Two minimal wording fixes were made (§6); nothing else in `paper-steeper/` was changed.*

* **Read in full.**
  * The brief with the author's message.
  * `review-front.md`, `review-math.md`, `log-integrate.md`, `log-fix.md`.
  * Paper 2 sources: `abstract.tex`, `intro.tex`, `imit.tex`, `app-imit.tex`, `discussion.tex`, `main.tex`, `build.sh`, `test-section.sh`; `teacher.tex` §8.1 (`rem:teacher:weightdecay`); `app-teacher.tex` §F.7; the word diffs against `HEAD` of `related.tex`, `setup.tex`, `teacher.tex`, `intro.tex` and `discussion.tex`.
  * The PDF text of §10 (pp. 34–36), Remark 8.5 (p. 27), App H (pp. 80–84) and the reference list.
* **Read in part, for the spot checks.**
  * `research/tracks/imitation/robust/notes-final.md` §2 (Lemma 2.1, Thm 2.2, Rem 2.4) and §4.1–§4.5 (Setting 4.1, Prop 4.2, Lemmas 4.4–4.6, Thm 4.7, Cor 4.9, Props 4.10, 4.11).
  * `research/tracks/imitation/decay/notes-final.md` §2.1–§3 (Props 2.1–2.3, 3.2, Ex 2.4) and §4.1–§4.3 (Props 4.1, 4.2, Ex 4.3).
  * `research/tracks/imitation/referee-final.md` §2.3–§2.4, §2.8, §3–§7.
  * `research/tracks/imitation/notes-final.md` (synthesis) §2.2.
  * The binding rules: `DECISIONS.md` §0, §A2, §A5, §A8–§A10, §B; `REFRAME.md` in full; `restructure/DECISIONS-restructure.md` §3, §4.
  * `prop:recovery:beyond` (`app-recovery.tex`), its main-text pointer (`recovery.tex`), and `thm:learn:dominance` of Paper 1 (`paper/sections/learn.tex`, `paper/main.aux`).
* **Repository.**
  * No git command that changes repository state was run (only `git status`, `git diff`, `git show HEAD:…`, `git ls-files`).
  * Paper 1 was not edited.
  * Before the edits, `sections/`, `bib/`, `main.tex`, `preamble.tex`, `CLAIMS.md`, `OUTLINE.md` and `main.pdf` were copied to the session scratchpad (`fc-backup/`).
  * `git status` shows no change outside `paper-steeper/`, this folder and the imitation track's referee files, which were already untracked before this check.
  * The tracked `scratch/editor/status_p*.json` were not touched; `extract_status.py` was not run (an independent environment checker was used instead, §4).

---

## 0. Verdict

* **Ready, subject to two decisions that are the author's** (§7): the abstract caveat (front M2) and the page caps (front M3).
* **The major findings are fixed correctly** (§1).
  * The one major finding with a fix in the text, review-front M1 (imitation attached to the wrong thread), is fixed in §10, the introduction, the discussion and the claims table. The new sentences say only what is proved.
  * review-math had no major finding; its two minor findings M1 and M2 are fixed exactly.
  * Fronts M2 and M3 are correctly left to the author. M2 is the abstract caveat: the 1920-character cap of D9 means any caveat costs a result claim. M3 is length: DECISIONS-restructure §3 forbids further moves or cuts without the author's decision.
* **12 statements spot-checked against the records and the final referee report: all match** (§2), with the six referee corrections C1–C6 and the optional κ sentence in place. Eight quoted numbers were recomputed independently, and all reproduce with safe rounding.
* **The abstract, introduction and discussion agree with the body** (§3).
  * The abstract is unchanged and still true. It does not mention imitation or weight decay (M2).
  * The caveats requested by the author are explicit in the introduction ("Scope") and in the discussion ("What the toy cases leave open").
* **Build clean** (§4):
  * 0 errors;
  * 0 undefined references, 0 undefined citations, 0 multiply defined labels;
  * 0 overfull boxes above 10 pt;
  * 87 pages;
  * every grep passes.
* **Companion check: ALL OK** (§5). The one Paper 1 number it does not know, Theorem 5.1(a), was checked by hand.
* **Two wording fixes made** (§6), neither changing any statement or the page count:
  * a main-text use of $c^*$ that clashed with a different $c^*$ of §7;
  * a dangling relative clause in the discussion.

---

## 1. The findings of the two reviews

### 1.1 Major findings

| review, id | what was required | state in the paper | verdict |
|---|---|---|---|
| front M1 | Say that imitation with private coins is the first reason, and that with environment-driven coins a fixed λ (any $\lambda_n=o(n)$) returns a program for the data kernel $P^*$, not a copy; near-copies need λ/n in a window | **§10 ¶1** (`imit.tex` l.17): "If the person's coins are private, this is the first reason: … every fixed $\lambda>1$ eventually returns a shortest copy, not a fill-in (Theorem 6.3). Systems that infer … are excluded by the choice of the private-randomness class, not by the data (Appendix H.1)". **§10 ¶2** (l.19): "The data follow the kernel $P^*$ …, so a fixed λ, or any $\lambda_n=o(n)$, eventually returns a shortest program for $P^*$ (Theorem 6.3(a)), not a copy when $P^*$ differs from the person's kernel; in the feature case such a program encodes the coupling. … the guarantee below needs the schedule of the second reason, λ/n above the reuse factor $2^{-m}$". **Introduction ¶2**, **discussion "Two reasons, one geometry"**, and the **claims-table row** ("near-copies for λ/n in a window") say the same | **Fixed correctly.** Checked against `thm:recovery:main`(a). The pairs are i.i.d. from $\bar\mu\otimes P^*$ (`def:imit:setting`(c)). $P^*$ is computable from finite objects, so it has programs in $\Hcl{\times}$. Every $1\le\lambda_n=o(n)$ therefore ends at a shortest program for $P^*$, which is not a copy exactly when $P^*\ne\nu_H$ on positive $\bar\mu$-mass. In the feature case such a program, given $(h_0,\mu)$, determines β, by injectivity of $h(x,\cdot)$ and because every cell has an input. "Needs the schedule of the second reason" refers to the hypothesis $c=a2^{-m}$, $a>1$, of `thm:imit:main`, which is accurate. The fixer rightly did not adopt the reviewer's stronger "a copy needs λ/n above $2^{-m}$": with tied coin values copies can win below $2^{-m}$ (App H.3), and when the input does not reveal the coin a fixed λ works. The texts are conditioned on "the input partly reveals them" |
| front M2 | A caveat in the abstract | Not changed. The abstract is byte-identical to `HEAD` (1920 characters) | **Correctly left to the author.** It is the exact text of DECISIONS-restructure D9 at its cap. Every claim in it is true. The caveat the author asked for is in the introduction and the discussion (§3). The ready-made option (one sentence of 105 characters plus two cuts, giving 1902 characters) is in `log-fix.md` §2 |
| front M3 | Length: all three caps exceeded | No move or cut | **Correctly left to the author** (DECISIONS-restructure §3: "No further content is moved or removed without the author's decision"). Current overruns are in §4 |

review-math has no major finding (its verdict: "None is fatal or major").

### 1.2 Minor findings and suggestions (checked as well)

| id | state in the paper | verdict |
|---|---|---|
| math M1 (information about the cell vs the coin) | `imit.tex` l.29: "when the input carries information about the coin $\beta(w)$, that is, when $P^*\ne\nu_H$ on a set of positive $\bar\mu$-mass" | correct. $P^*(h(x,b)\mid x)=\Pr[\beta(w)=b\mid x]$ and $\nu_H(h(x,b)\mid x)=\rho(b)=\Pr[\beta(w)=b]$ by exact type, so the two conditions are equivalent |
| math M2 ("iff" → "if") | `app-imit.tex` l.85 | correct |
| math L1 (well-formed condition in (F2)) | `app-imit.tex` l.35 | correct |
| math L2 ("on every sample") | `teacher.tex`, `rem:teacher:weightdecay`; also `setup.tex` (s3) | correct; matches decay Prop 2.2(ii) |
| math L3 = front m9 (Xie–Li conditional) | `ex:teacher:weightdecay`: "If full-batch AdamW … converges, under a non-increasing learning rate with divergent partial sums, its limit is a KKT point …, here the minimiser of $L$ on this box, as $L$ is convex; in the same computation AdamW ends near it" | correct. It matches the decay record's abstract-level entry and d3(D3). The minimiser is unique because $L$ is strictly convex on the box (decay Ex 4.3(e)) |
| math L4 (bullet) | `intro.tex` bullet "Imitation": "identify only the data kernel, not the mechanism or the split into person and environment" | correct |
| math L5, N1, N3 | `app-imit.tex` l.101, l.112; `imit.tex` l.59 | correct |
| math N2 (worlds renamed) | $\mathcal W_1,\dots,\mathcal W_N$ in `prop:imit:limits`(a) and its proof | correct; the rest left as optional |
| math N4 = front m4 | Scope: "for large $d$ and typical error sets"; fourth case "with far more entropy summed over the cells than the sampler has bits", "for λ/n in a window" | correct |
| front m1, m2, m3, m5, m6, m7, m8, s1, s3 | as in `log-fix.md` §2 | all present and correct. m7: a nonzero stationary point of $L+\frac\omega2\|\theta\|^2$ fixes ω (decay Prop 4.2(iii)). m8: no λ is left for the decoupled coefficient in §F.7 |
| front m10, s2, s4 | not changed, with reasons in `log-fix.md` | reasons accepted |

---

## 2. Spot check of 12 statements against the records and the referee report

"✓" means hypotheses, quantifiers, constants and status match the source; differences are listed.

| # | paper item | source | check | verdict |
|---|---|---|---|---|
| 1 | `def:imit:setting`(b)–(d) | robust Setting 4.1; synthesis §2.2 item 1; referee-final §3 | ρ(b)2^m a positive integer; $h$ injective in $b$; copies on $\supp\mu$; every copy has $R=H(\rho)$ by exact type. $B_\beta:=K(\beta\mid h_0,\mu)$ drops the record's extra condition $K(h_0\mid\mu)$. Referee-final §3 verifies the three facts it is used through, and that the change can only help up to κ | ✓ |
| 2 | paragraph after the definition | robust Setting 4.1, Prop 4.2(b); C2 | the type-class bound $L_\beta\ge2^mH(\rho)-|\Sigma|\log(2^m+1)$; $\Pr[\delta_\beta>j]<2^{-j}$ "independently of the person's model and the channel" (C2, with the referee's counterexample when this fails); the coin-information condition (math M1) | ✓ |
| 3 | `thm:imit:main`(i)–(iii) | robust Thm 4.7(U)(ii)–(iv); `lem:kink:main` | (i) $\ell_0+(G+2^m\epsilon)/(a-1)$; left side of (ii) $(aG+2^m\epsilon)/((a-1)2^m)$; right side $c\ell_0+\epsilon$, sharper than the record's $c(\Gamma+\kappa)+\epsilon$ since $\ell_{\mathcal M}=0$ gives $\alpha_{\rm r}-\ell_{\mathcal M}=\ell_0$ (synthesis §2.2 item 3); (iii) from $I_\beta\le\ell(\pi)+\kappa$ | ✓ |
| 4 | `thm:imit:main`(iv) | robust Thm 4.7(U)(vi); referee-final item 2 | bracket $\ell_0+\frac{G+2^m\epsilon}{a-1}+\delta_\beta+|\Sigma|\log(2^m+1)+E+2\kappa=\frac a{a-1}G+\frac{2^m\epsilon}{a-1}+E+\kappa$; times $2/2^m$; $1+\frac2{a-1}=\frac{a+1}{a-1}$; Hellinger form from $D_{1/2}\ge2\Hel/\ln2$. Re-derived | ✓ |
| 5 | last part of `thm:imit:main` (program with kernel $P^*$) | robust Thm 4.7(vii) | feature case, $|\Sigma|\ge2$, distinct values; length $\ell_0+\lceil L_\beta\rceil+a_\rho+\kappa$ with the same $a_\rho$; threshold $\ge2^{-m}(1+(a_\rho+1+\kappa)/(2^mH(\rho)))^{-1}$ from $\lceil L_\beta\rceil\le2^mH(\rho)+1$ | ✓ |
| 6 | `lem:imit:coding` | robust Lemma 4.4 | same statement and proof (arithmetic mean, Jensen), plus the well-formedness clause of L1 | ✓ |
| 7 | `lem:imit:closeness` | robust Lemma 4.6; referee-final item 1 | the same $\tilde q_w$, $\bar D$ and $E(\pi)$, and the same five steps. The trimming clause and "the remaining $2/2^m$ is absorbed in κ" (the referee's optional sentence) are in place | ✓ |
| 8 | `prop:imit:limits`(a) | robust Prop 4.10(a2),(a1); referee-final item 4 | one data law, kernels pairwise different on positive mass, any procedure, every $n$; the twin with $\Sigma=\{\ast\}$ needs $|\Sigma|\ge2$ (stated) | ✓ |
| 9 | `prop:imit:limits`(b) and "No window in (b)" | robust Prop 4.11(a)–(c) | $1\le s_0<2^{m-1}$ (so $m\ge2$, $p\ne\frac12$); $2^{-L_\beta}=\binom{2^m}{s_0}^{-1}$; thresholds $H(p)/(j+4\log(m+1)+2\kappa)$ and $(1-H(p))/(2^m-j-2\log(m+1)-2\kappa)$; the stated condition is exactly their overlap | ✓ |
| 10 | `prop:imit:cheap`(i),(ii) | robust Prop 4.10(c),(d); C5 | (i) rate $H(\rho)/(K(\beta\mid\pi_H)+\kappa)$ against $s_-\le(\log|Y|-H(\rho))/(\ell_0-\ell(\pi_{\rm u}))$. In (ii), the chain $H(\ell_0-\ell_{\rm u})<(\log|Y|-H)(\lceil L_\beta\rceil+a_\rho+\kappa)$ ⇒ $2^m>\frac{\ell_0-\ell_{\rm u}}{\log|Y|-H}-\frac{a_\rho+1+\kappa}{H}$ is redone by hand. All three hypotheses of C5 are in the statement | ✓ |
| 11 | `rem:imit:private` and its proof (App H.1) | robust Lemma 2.1, Thm 2.2(2),(3), Rem 2.4 | the filtration with $x_i$ $\mathcal A_i$-measurable and $y_i$ $\mathcal A_{i+1}$-measurable; (Priv); the supermartingale step; $\Pr[\delta^*\ge j]\le2^{-j}$; the population claim with its hypotheses (product hypotheses, i.i.d. pairs, countable $z$). In "Hypotheses that learn in context", "by construction (`cor:absorb:nouniversal`), not because of anything in the data" | ✓ |
| 12 | `prop:teacher:nofixedprior`(i)–(iv) and `rem:teacher:weightdecay` ¶1 | decay Props 2.1, 2.2(i)–(iii),(v), 2.3, 3.2; refuted R1, R2 | (ii) the threshold for $r$, and "no fixed prior with full support … on all samples" (R2 is the reason for "full support"); (iii) summable priors that charge $\mathcal E$; $c>c^*$ ⇒ disjoint from all of $\mathcal E$; $c<c^*$ case (with $2^{-\ell}$, a special case of the record's $2^{-\lambda\ell}$); (iv) $c_+=H(p)/(B_S-4-\Lambda_1-\kappa_g)$. The main-text remark says "on every sample" and "outside a thin band just above $2^{-m}$", in line with R1 | ✓ |

**Numbers recomputed independently** (`fc/nums.py` in the session scratchpad, `python3 -I`; κ = 0 and $\delta_\beta=\epsilon=0$ where the paper says so):

| quantity (where) | recomputed | printed | rounding |
|---|---|---|---|
| $a_\rho$, $m=20$, $|\Sigma|=2$ (App H.3) | 53.9546 | "$<54$" | up ✓ |
| bound (iv), fair-coin person, $c=2^{-19}$ | $6.139\cdot10^{-4}$ | $6.2\cdot10^{-4}$ | up ✓ |
| $\ell_0$ and $H(2^{-10})$ for the parity person | 119.932; 0.011174 | "$<120$"; 0.0112 | ✓ |
| bound (iv), parity person, $c=2^{-19}$ | $9.421\cdot10^{-4}$ | $9.5\cdot10^{-4}$ | up ✓ |
| bound (iv), parity person, $c=10^{-4}$ | $1.2356\cdot10^{-2}>H(\rho)$ | "exceeds $H(\rho)$" | ✓ |
| cell count of `prop:imit:cheap`(ii), $\ell_0=10^6$, $H=\frac12$, $|Y|=2$ | need $2^m>1.99989\cdot10^6$ ($m=18$–$24$); $2^{20}$ falls short, $2^{21}$ suffices | "more than $1.99\cdot10^6$ cells" | down ✓ |
| $\omega^*$ at $\varepsilon=0.1$, $q=0.2$ (Ex. F.7) | $2.10107\cdot10^{-3}$ ($a^*=1.92302$) | $2.101\cdot10^{-3}$ | ✓ |
| AdamW box thresholds | 0.102780; 0.822237 | 0.1028; 0.8222 "to four digits" | ✓ |

The $c_+$ band "between $1.0044$ and $1.0115$" against the record's 1.00447–1.01141 is rounded outward ✓. The finite-$n$ counts in Ex. F.7 (20/20; 0/20 from $n=10^3$) match decay d2(B).

---

## 3. Abstract, introduction and discussion against the body

### 3.1 Abstract

* **Status.** Byte-identical to `HEAD`, 1920 characters. Every claim in it is unchanged in the body.
* **What it does not say.** It does not mention imitation, weight decay or the caveat. This is front M2, for the author (§7).

### 3.2 Introduction

| sentence or item | body | verdict |
|---|---|---|
| ¶2 imitation motivation: a copy rather than "the sampler with some of its sampled bits stored, or a different system that predicts the person's answers better than the person does"; private coins = first reason; environment-driven coins that the input partly reveals need the second reason's schedule (§10) | `thm:recovery:main`(a) with $P^*$; `thm:imit:main` ($c=a2^{-m}$); `prop:imit:limits`(a) for systems with the same behaviour (gap (1)) | ✓ |
| bullet "Imitation" | `thm:imit:main`; `prop:imit:limits`(a),(b); `prop:imit:cheap`(i) | ✓ (short form of the hypotheses, as review-front m4 allows) |
| `tab:intro:claims` row on imitation | as above, "for λ/n in a window" | ✓ |
| "Scope": not a solution; tools; the four toy cases with their hypotheses; "the last two for the population objective, and from samples only asymptotically or with large constants"; three open conceptual problems named | `thm:recovery:main`; `prop:parity:range`(iii) ($\delta_E=O(d)$); `thm:teacher:main`, `rem:teacher:hypotheses`, `prop:teacher:rates`; `thm:imit:main` with $\ell_0+|\Sigma|m\ll2^mH(\rho)$; `prop:recovery:beyond`(c), `prop:teacher:schedules`(c), `cor:teacher:sampled`; gaps (1), (2) | ✓ |
| "Reader's guide" | §10 placed after §9, before §11 | ✓ |

### 3.3 Discussion

| passage | body | verdict |
|---|---|---|
| "Two reasons", last sentence (imitation needs both) | as front M1 above | ✓ |
| `tab:discussion:reasons`, "What the learner is": "not a fixed prior" | `rem:setup:persample` (now with the $\Hcl{\times}$ restriction), `prop:teacher:nofixedprior`(ii) | ✓ |
| "The window and its price": the weight-decay sentence | `rem:teacher:weightdecay`, decay Props 4.1, 4.2, Ex 4.3 | ✓ (one wording fix, §6) |
| "What the toy cases leave open", gaps (1)–(6) and the closing sentence | (1) §10, `prop:imit:limits`; (2) `prop:limits:noident`, `prop:imit:limits`(a), "reliably" (C6); (3) `prop:imit:cheap`, `prop:imit:limits`(b); (4) `prop:recovery:frozen`; (5) `thm:split:shared`, `prop:absorb:history`, App H.1; (6) `prop:related:computability`, `q:related:open`, `prop:recovery:necessity`, `rem:teacher:numbers` | ✓ none is stronger than its citation |
| Open problem (7) "Imitation" | robust §8 items, `q:imit:open` of the draft | ✓ |

### 3.4 Against the author's three requests

| request | where | verdict |
|---|---|---|
| (1) λ = cn is like weight decay, which keeps preferring a simpler, worse-classifying hypothesis even in the limit | Remark 8.5 (what is analogous, what is not, the window analogue as a range of ω with one classifier); App F.7 (`prop:teacher:nofixedprior`, `ex:teacher:weightdecay`); a related-work sentence; a discussion sentence | done. "As the number of params varies" is read as the sample size (§7, item 3) |
| (2) imitation: recover the original sampler robustly, against fill-ins and against better predictors; only if good | §10 (`def:imit:setting`, `thm:imit:main`, `prop:imit:limits`) and App H | done. Fill-ins and private coins: Remark H.1 with Theorem 6.3. Better predictors: Theorem 10.2, near-copies for λ/n in a window. Limits are stated in the section itself: behaviour, not mechanism; the person/environment split; entanglement; cheap couplings; population only. The final referee verified every refereed item |
| (3) caveats: not solving the practical problems; a toolkit; some toy cases solved; big philosophical problems remain | Introduction "Scope"; discussion "What the toy cases leave open" | done in the introduction and the discussion; not in the abstract (front M2) |

---

## 4. Build, greps and pages

* **Full build** (`flock /tmp/claude-0/paper-build-sfi.lock ./build.sh`). Run twice: once before the fixes, which reproduced `log-fix.md` exactly, and once after. The second run gives:
  * LaTeX errors: 0;
  * undefined references: 0;
  * undefined citations: 0;
  * multiply defined labels: 0;
  * overfull hboxes above 10 pt: 0 (two below 3 pt remain, 1.84 pt and 2.75 pt, as before);
  * 0 LaTeX warnings in `build3.log`, and no warnings in `bibtex.log`;
  * pages: 87;
  * no "??" in the PDF text.
* **Isolated builds** after the fixes: `./test-section.sh teacher app-teacher` OK (16 pp); `./test-section.sh discussion` OK (4 pp); 0 undefined citations each.
* **Process vocabulary** (DECISIONS §A5 regex on `pdftotext main.pdf`).
  * Word hits: only the title footnote's "independent AI referees".
  * Formula fragments: $h_0$, $h_1$ in the proof of Lemma 7.2, and the tokens s0, E0, S1, r0, c1–c3, S2, E1, r1, s1, s2, C1, C2, e1, R2. Each is a formula fragment.
  * One DOI fragment, "s10994-007-0716-7", in the reference list.
  * The token counts are identical to those of the PDF before this check.
* **Status tags** (§A2.5 regex on the PDF): 0 hits. `\status`/`\src` are redefined to print nothing (`preamble.tex` l.122–123).
* **`\status`/`\src` on every environment.** An independent script over all `sections/*.tex` except the switched-off `app-verification.tex`, ignoring comments, checked 118 theorem-like environments (theorem, lemma, proposition, corollary, remark, example, question, definition). Every one carries `\src`, and every non-definition carries `\status`: 0 missing.
* **Wyeth** (§B.6): 0 in the PDF; 0 in the sources outside comments, the label `rem:absorb:wyeth` and `app-verification.tex`.
* **REFRAME.**
  * "the author"/"author's" occurs only in the title footnote (l.56), the intro footnote on the proposal (l.142, l.146), the §5 footnote (l.805) and the acknowledgements.
  * `hanni2026grokking`/`hanni2026notes` are cited only in `intro.tex` (footnote), `kinks.tex` (footnote) and `discussion.tex` (acknowledgements).
  * "alien", "synthesis" and "sub-track" do not occur in the PDF.
  * The new text is "we" or impersonal.
* **Restructure FRONT strings** (DECISIONS-restructure §4.7). None of the forbidden strings is in the PDF. The only source hit is "0.545", in the switched-off `app-verification.tex`. `0.1233\le p` does not occur in the sources. "(o) Level bounds" occurs once.
* **Labels.** Against `HEAD`, the label set of `sections/*.tex` has 0 labels removed and 18 added, exactly those of `log-integrate.md` §8. 249 labels in all; none renamed. This check added none.
* **Pages** (text-block method of `log-integrate.md` §7, its script `integrate/measure.py`; unchanged by this check's fixes):

  | part | pages | cap (DECISIONS-restructure §3) | over |
  |---|---|---|---|
  | main text (title to Code and data) | 39.76 | 33.5 | 6.26 |
  | references | 3.63 | – | – |
  | appendices | 43.28 | 37.5 | 5.78 |
  | total | 86.66 (87 pages) | 73.5 | 13.16 |

  * **By part.** §1 3.97, §2 1.44, §8 6.11, §10 2.44, §12 2.84; App F 9.33, App H 4.11, App I 2.21.
  * **Positions.** `sec:imit` pp. 34–36: Theorem 10.2 on p. 35, Proposition 10.3 on p. 36. Remark 8.5 is on p. 27. App F.7 is on pp. 73–74. App H is on pp. 80–84.
* **SHA-256 prefixes after this check.**

  | file | prefix |
  |---|---|
  | `main.pdf` | `f4fa21e3bd054f48` |
  | `sections/teacher.tex` | `279d2ff9a6b0d64d` |
  | `sections/discussion.tex` | `666bac531acfdf85` |
  | `sections/imit.tex` (unchanged) | `9ab0945b061a9eca` |
  | `sections/app-imit.tex` (unchanged) | `bbf477faa2bc61f7` |

---

## 5. Companion check

* **Result.** `python3 -I research/paper-review/scratch/editor/check_companion_numbers.py` ends with **ALL OK**: all 23 intended citations of Paper 1 numbers resolve to the right labels of `paper/main.aux`.
* **Unknown to the script:** `Theorem~5.1` (`absorb.tex` l.89, "\citep[Theorem~5.1(a)]{claudeSFI2026fundamentals}", comment "P1: thm:learn:dominance"). Checked by hand:
  * `paper/main.aux` has `\newlabel{thm:learn:dominance}{{5.1}{17}…{theorem.5.1}}`;
  * its part (a) is the x-only samplers (`paper/sections/learn.tex` l.19), which is what the sentence cites ("SFI dominates" the computably samplable predictors that use different random bits on different inputs). Correct.
* **Intended but unused:** `Remark~B.3` and `Section~7.3`, as before. Harmless.
* **The other direction.** Paper 1 cites Paper 2 only as a whole (`log-integrate.md` §6), so the renumbering of §10–§12 and App H–I cannot break it.

---

## 6. Fixes made in this check

| file | old | new | why |
|---|---|---|---|
| `teacher.tex`, `rem:teacher:weightdecay` ¶1 | "Per query, for $c>c^*$ the $cn$-MAPs end at shorter programs …" | "Per query, for $c$ above the truth's left steepness $c^*$ (\cref{prop:recovery:beyond}) the $cn$-MAPs end at shorter programs …" | In the main text, $c^*$ was used without definition or pointer. The only main-text definition of $c^*$ is a different constant, $c^*:=2\log d+K(p)+\kappa$ in §7 (`parity.tex` l.136). The meant $c^*$ is the left steepness of `prop:recovery:beyond`(c), which the main text (`recovery.tex` l.142) calls "the truth's left steepness". No statement changes |
| `discussion.tex`, "The window and its price", third sentence | "…, at the price stated in \cref{rem:limits:schedule}, which imitation data cannot justify, because …" | "…, at a price (\cref{rem:limits:schedule}) that imitation data cannot justify, because …" | The relative clause, created when the fix round merged two sentences (front m6) to keep three sentences, read as attached to the remark. The paragraph keeps its three sentences |

* **Comment lines.** Each file gains one `%` comment line naming this check.
* **Effect.** Both edits fit the existing lines; the page measurements are identical before and after (§4). `CLAIMS.md` and `OUTLINE.md` need no update: no label, numbered item or page count changed.

---

## 7. Points for the author

1. **Abstract caveat (front M2).** Add one sentence and make two cuts, as in `log-fix.md` §2 (1902 characters), or keep the abstract. The caveats are now explicit in the introduction ("Scope") and the discussion.
2. **Length (front M3).** 87 pages, against the caps set before this request (main text +6.26 pp, appendices +5.78 pp, total +13.16 pp). The candidates are in `review-front.md` §7 and `log-integrate.md` §7, plus moving Remark 8.5 (front s4). The 1.3-page fallback of the synthesis §5.3 is still available if a lighter imitation section is preferred.
3. **"As the number of params varies."** The paper reads this as the sample size. If model size was meant, the decay record's header gives one sentence that covers it.
4. **Novelty.** `rem:related:new` claims no novelty for `thm:imit:main`, `lem:imit:closeness` or `prop:teacher:nofixedprior`. This is conservative.
5. **Armstrong–Mindermann** is cited at abstract level only. A comparison with its simplicity-prior argument would need the full text.
6. **Notation left as is** (math N2): $a$ in $f_a$ and in $c=a2^{-m}$; $P^*$ and $W$ inside `prop:teacher:nofixedprior` and its proof.
7. **The informative range for low-entropy persons** (review-math §4 item 2). For the parity person the bound of Theorem 10.2(iv) is below $H(\rho)$ only for $c\in[9.9\cdot10^{-7},9.0\cdot10^{-5}]$ (κ = 0), much narrower than the teacher window. The paper states this correctly (App H.3).

---

## Verification log

* **2026-10-14, reading.** As listed in the header. All four logs and reviews of this folder were read in full first.
* **Before any edit.**
  * The sources were backed up to the scratchpad.
  * A full build under the lock reproduced `log-fix.md` §4: 0/0/0/0/0, 87 pages, the same two small boxes.
  * `integrate/measure.py` reproduced its page table (39.76 / 3.63 / 43.28 / 86.66).
* **Checks run.**
  * The greps of §4 on `pdftotext main.pdf`, before and after the edits.
  * The environment script `fc/envcheck.py` (118 environments, 0 missing).
  * The label comparison against `git show HEAD:…` (0 removed, 18 added).
  * The companion script, with a hand check of Theorem 5.1(a).
  * `fc/nums.py` for the numbers of §2 (deterministic; stderr empty).
* **Hand checks.**
  * The application of `thm:recovery:main`(a) to the sampler $P^*$ (front M1).
  * The equivalence behind math M1.
  * The algebra of `prop:imit:cheap`(ii) and of the "No window" condition.
  * The bracket of (iv).
  * The AdamW box threshold $(1-q)\sigma(-2\varepsilon/\omega_{\rm d})\ge q/2\iff\omega_{\rm d}\ge2\varepsilon/\ln((2-3q)/q)$.
* **Edits.**
  * Two exact-string replacements, each unique (§6).
  * Two comment lines, inserted by a script that asserts its anchor.
  * The diff against the backup shows only these four lines.
* **Builds after the edits.**
  * Two isolated builds (teacher with its appendix; discussion).
  * One full build under the lock, with the results of §4.
  * Both changed passages read in the PDF text.
* **Not done.**
  * No new mathematics.
  * No WebSearch.
  * No change to Paper 1, to the research records, to `CLAIMS.md`/`OUTLINE.md` or to shared root files.
  * No git command that changes repository state.
