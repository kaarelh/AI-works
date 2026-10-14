# Log of writer W1 (setting, absorption): Paper 2 restructure

Files written (all in `paper-steeper/sections/`): `setup.tex`, `app-setup.tex`, `absorb.tex`, `app-absorb.tex`. No other file was edited. No git command that changes repository state was run.

Inputs read: PLAN.md (in full), REFRAME.md, DECISIONS.md (§0, §A, §B, §E, §F Paper 2, §G); the base versions of `setup.tex`, `app-setup.tex`, `absorb.tex`, `app-absorb.tex`, `split.tex`, `app-split.tex`, `algstat.tex` (`git show dcb3a3a3`, identical to the working files when I started); the synthesis `split/notes-final.md` §0, §1, §3, §5.0–§5.5, §8; `split/kink/notes-final.md` §0–§3; `split/iid/notes-final.md` §1–§2; `split/teacher/notes-final.md` §1.0; `verify-kink.md` §1, §5–§7; `verify-teacher.md` §1–§2; Paper 1 `learn.tex` (Props 5.6, 5.7), `versions.tex` (Remark 4.8) and `paper/main.aux`.

## 1. What each file contains

### `setup.tex` (§3 Setting: data, hypothesis classes and steeper objectives)
* Opening sentence; the companion-objects table replaced by a paragraph (function machine and machine law, $\MF$, $\Mprod$, $\Mpq$; $\Mw$ and $\MH$ are now introduced where their classes are, in `def:setup:class`).
* §3.1 `def:setup:data` with the three objects DS, FR, PQ (the binding text of PLAN §4.3, with a forward `\cref` to `def:setup:product`); `rem:setup:objects` (a)–(d) per PLAN §4.3; `def:setup:product` (PQ reading added: per query the likelihood is the program's term in $\Mpq$, Paper 1 Proposition 5.7(a)); `def:setup:shared` (kept). The base sentence "all noisy data in this paper draw each label once per distinct input" is deleted.
* §3.2 `def:setup:class` (observations now include per-query samples $h_n$ for product classes, $P_\pi(h_n):=\nu_\pi(h_n)$; canonical classes listed compactly; closure under prefix-free simulation kept); the κ and (F1)–(F5) paragraph.
* §3.3 `def:setup:objectives` (the observation may be a per-query sample $h_n$ for a product class, with $P_\pi(h_n)=\nu_\pi(h_n)$; λ is the "complexity weight", λ > 1 "steeper"; the fit $L(\pi;o):=-\log P_\pi(o)$ and $J_\lambda=\lambda\ell+L$ are defined here; one sentence: $J_\lambda$ and its minimisers are defined in the same way for every λ > 0); the F46 paragraph; `lem:setup:basic` with its two-line proof; `rem:setup:persample`; one sentence leading to the hull; **`lem:setup:hull` (moved from App A and merged)**: items (i)–(iv) with the base numbering and content (hypotheses written π, π′, $\pi_c$; the fit written $F$ with a data reading $F=L(\cdot;D)$, $c=\lambda$ and a population reading $F=R$, $c=\lambda/n$), plus (v) vertices and minimisers (split/kink Thms 2.1, 2.2) and (vi) duality (split/kink Prop 2.3), in terms of the hull $C$ and its lower boundary $\underline C$, with no structure function; proof idea (4 sentences), which also carries the absolute-length-bound sentence and the replacement of the "vertex" sentence ("the theorems on the teacher's errors ask not whether the good model is a vertex but whether every near-optimal hypothesis knows the model and not the errors", `\cref{rem:teacher:selected}`); `lem:setup:coding` with proof idea and the new sentence "at a $b$-sufficient program the bound is a right line of slope 1 with offset $b+\kappa$" (`\cref{def:kink:kinks,cor:kink:split}`); the F31 paragraph.

### `app-setup.tex` (App A, Proofs for §3)
* A.1 (F1)–(F5) (kept).
* A.2 Proof of the hull lemma: Step 1 (gift wrapping: attainment, $\rho_i$ attained at length exactly $\alpha_i$, strictly decreasing slopes, $\sigma_i\to0$), Step 2 (the boundary is the epigraph of the polygon $P$, so $\underline C=P$; vertices are exactly the $v_i$), then (i)–(iv) (base proofs, rewritten in the gift-wrapping notation), (v) and (vi) (split/kink Thm 2.2, Prop 2.3). `rem:setup:hullconverse` (F43; now with `\status`/`\src`), the two examples, one computed sentence.
* A.3 Proof of the coding bound (kept; fit notation; "applied to one fixed program for all $(\pi,\dom D)$" made explicit, since that is where the hypothesis-class assumption enters, split/kink §1).

### `absorb.tex` (§4 What counts as one hypothesis: absorption and private randomness)
* Opening paragraph (F38 text, shortened; one sentence placing the section: "Both reasons for a steeper penalty need the selected hypothesis to be a model, not a universal learner, so this section is their precondition").
* §4.1 `sec:absorb:shared`: (Dom) `eq:absorb:dom`; `rem:absorb:examples`; `thm:absorb:absorption` ((a)–(d), (c1)–(c3) unchanged in content; fit notation $L$; the length threshold written $\bar\ell$); proof idea; **the new sentence** pointing to `prop:kink:universal` (every left kink $(\sigma,w)$ at $(\alpha_{\rm r},L_{\rm r})$ with $\alpha_{\rm r}-w>\ell_U$ has $\sigma\le1+(\ell_U+\kappa_0)/(\alpha_{\rm r}-\ell_U)$); `rem:absorb:reading` (shortened).
* §4.2 **new subsection "No split with shared randomness"**, label `sec:split:shared` (alias): one-sentence definition of a sampler in the words of `def:split:setting`, with a forward `\cref`; **`thm:split:shared` (received from W3)**, statement unchanged except $L\to\bar\ell$ and the SI/chronological note set in parentheses; proof idea ("`thm:absorb:absorption`(a) plus one comparison"); the "Compare …" paragraph, shortened (kept: the domination of ν and the KL bounds of F36, the contrast with the product class via `thm:recovery:main`(b) and `thm:split:private`(iv), the pointers to `ex:split:noisyparity` and `rem:split:siprograms`).
* §4.3 `sec:absorb:private`: `prop:absorb:pricing` (statement), one sentence on its proof, `cor:absorb:nouniversal` with proof, one sentence on `rem:absorb:condsemi`.
* §4.4 `sec:absorb:price`: one sentence pointing to `rem:absorb:why` (now in App B); a summary of `prop:absorb:price` (statement now in App B, see deviation D-W1-1); one paragraph on `prop:absorb:history` and `prop:absorb:inputs`.
* §4.5 `sec:absorb:answer`: `rem:absorb:wyeth` (title "Answer to the absorption objection"; items (i)–(iv) run in, shortened; (i) cites `thm:split:shared`, now in this section; (iv) cites `prop:algstat:parity,prop:parity:kink,prop:parity:sets`); `q:absorb:shared` (kept in its section, D3; now with `\status{open}`).

### `app-absorb.tex` (App B, Proofs for §4)
* B.1 classes with an absorbing member (kept).
* B.2 proof of the absorption theorem (kept; fit notation; string length renamed $\bar n$ in (d)).
* B.3 **Proof of the shared-randomness theorem**, label `app:split:shared` (received from W3's `app-split.tex`), followed by **`ex:split:noisyparity`** (received; the sentence "its numbers are not values for any reference machine" added, DECISIONS §A1 for "computed; illustration").
* B.4 proof of per-input pricing (kept; the minimax loss renamed $\mathcal L(\nu,Q)$; condensed) and `rem:absorb:condsemi`.
* B.5 "Why private randomness, and its price": **`rem:absorb:why` (moved from `absorb.tex`)**, the definition of $D_\beta$, **`prop:absorb:price` (moved from `absorb.tex`; deviation D-W1-1)** and its proof.
* B.6 `prop:absorb:history` with proof, `prop:absorb:inputs` with a shortened proof (the optional cut of PLAN §6).

## 2. Labels defined (checked against the manifest, PLAN §3.1–§3.2)

Checked by script: every manifest label assigned to W1 is defined exactly once in W1's files; no other label is defined; **no new structural labels** were added.

| file | labels |
|---|---|
| `setup.tex` | `sec:setup`, `sec:setup:hyp`, `def:setup:data`, `rem:setup:objects` (new, §3.3), `def:setup:product`, `def:setup:shared`, `sec:setup:classes`, `def:setup:class`, `sec:setup:objectives`, `def:setup:objectives`, `lem:setup:basic`, `rem:setup:persample`, `lem:setup:hull` (moved here), `lem:setup:coding` |
| `app-setup.tex` | `app:setup`, `app:setup:facts`, `app:setup:hull`, `rem:setup:hullconverse`, `app:setup:coding` |
| `absorb.tex` | `sec:absorb`, `sec:absorb:shared`, `eq:absorb:dom`, `rem:absorb:examples`, `thm:absorb:absorption`, `rem:absorb:reading`, `sec:split:shared` (alias, received), `thm:split:shared` (received), `sec:absorb:private`, `prop:absorb:pricing`, `cor:absorb:nouniversal`, `sec:absorb:price`, `sec:absorb:answer`, `rem:absorb:wyeth`, `q:absorb:shared` |
| `app-absorb.tex` | `app:absorb`, `app:absorb:examples`, `app:absorb:absorption`, `app:split:shared` (received), `ex:split:noisyparity` (received), `app:absorb:pricing`, `rem:absorb:condsemi`, `app:absorb:price`, `rem:absorb:why` (moved here), `prop:absorb:price` (moved here, **deviation**: manifest destination `absorb.tex`), `app:absorb:history`, `prop:absorb:history`, `prop:absorb:inputs` |

Item structures kept stable for others (PLAN §3.6): `def:setup:data` (DS)/(FR)/(PQ); `rem:setup:objects` (a)–(d); `lem:setup:hull` (i)–(iv) as in the base, plus (v), (vi); `thm:absorb:absorption` (a)–(d), (c1)–(c3); `thm:split:shared` (i), (ii); `prop:absorb:pricing` (i)–(iii); `prop:absorb:price` (i)–(iv); `app:setup:facts` (F1)–(F5).

## 3. Every `\cref` to another group's label

All are in the stable lists of PLAN §3.6.

| from | to (group) | items used |
|---|---|---|
| `setup.tex` `rem:setup:objects`(a) | `thm:recovery:main`, `prop:recovery:frozen` (W3) | — |
| `setup.tex` `rem:setup:objects`(d) | `sec:teacher` (W5) | — |
| `setup.tex` `rem:setup:persample` | `rem:limits:schedule` (W5) | — |
| `setup.tex` before the hull lemma | `sec:kinks` (W2) | — |
| `setup.tex` hull proof idea | `rem:teacher:selected`, `sec:teacher` (W5) | — |
| `setup.tex` coding proof idea | `def:kink:kinks`, `cor:kink:split` (W2) | — |
| `absorb.tex` after `thm:absorb:absorption` | `def:kink:kinks`, `prop:kink:universal` (W2) | (i) of `prop:kink:universal` is what the sentence states |
| `absorb.tex` §4.2 | `def:split:setting`, `sec:recovery`, `thm:recovery:main`(b), `thm:split:private`(iv), `rem:split:siprograms` (W3) | (b), (iv) |
| `absorb.tex` `rem:absorb:wyeth`(iv) | `prop:algstat:parity`, `prop:parity:kink`, `prop:parity:sets` (W4) | — |

Intra-W1 cross-file references (resolve in the full build; undefined in the isolated builds): `setup.tex` → `cor:absorb:nouniversal`, `sec:absorb`; `app-absorb.tex` → `def:setup:shared`; `absorb.tex` → `lem:setup:hull`. The isolated builds show exactly the references listed above as undefined (11 for setup/app-setup, 12 for absorb/app-absorb), nothing else.

## 4. Moves

| label(s) | from | to | note |
|---|---|---|---|
| `thm:split:shared`, `sec:split:shared` | W3 `split.tex` | W1 `absorb.tex` | received; **W3 must delete** them from `split.tex` (emptied) |
| `ex:split:noisyparity`, `app:split:shared` | W3 `app-split.tex` | W1 `app-absorb.tex` | received; **W3 must delete** the base subsection "Proof of the shared-randomness theorem" and the example from `app-split.tex` |
| `lem:setup:hull` | `app-setup.tex` | `setup.tex` | within W1 (plan) |
| `rem:absorb:why` | `absorb.tex` | `app-absorb.tex` | within W1 (plan) |
| `prop:absorb:price` | `absorb.tex` | `app-absorb.tex` | within W1, **deviation D-W1-1** |

Base citers of moved W1 labels keep working, since labels are unchanged (`intro.tex`, `discussion.tex`, `app-related.tex`, `app-limits.tex`, `computable.tex` cite `thm:absorb:absorption`, `prop:absorb:price`, `rem:absorb:why`, `prop:absorb:history`, `lem:setup:hull`(ii),(iii), `def:setup:class`, …). No W1 file cites a cut label (`lem:split:hash`, `rem:limits:method`, `tab:algstat:numbers`).

## 5. [V-T] items

None in W1's files. W1 cites `def:kink:kinks` (whose wording is [V-T]; `verify-teacher.md` §1: Def 1.4 verified with a correction to an example offset, not used here) and `prop:kink:universal` (`verify-kink.md` §5: (ii) verified with a minor correction; W1 uses only (i), refereed). W1 does not cite `lem:kink:main`, `lem:kink:secant` or any W5 [V-T] label.

## 6. Mathematics against the records

* `def:setup:data`, `rem:setup:objects`: iid Defs 1.1, 1.3, Remark 1.4 (proved); teacher §1.0; Paper 1 Props 5.6, 5.7.
* `lem:setup:hull`(v), (vi): kink Thms 2.1, 2.2, Prop 2.3 (refereed). They are stated for every countable family with integer lengths, fits in $[0,\infty]$ and finitely many points per length, which is the scope kink §1 states ("§2 and §3 hold verbatim for any family of points … this includes shared classes and set models"); so the population reading is covered. (i)–(iv) are the base statements.
* `lem:setup:coding`, right-line sentence: kink Remark 2.5, Cor 3.3(a) (refereed; needs a hypothesis class, which the lemma assumes).
* The sentence after `thm:absorb:absorption`: kink Prop 3.5(i) (refereed), whose hypothesis ($L(\pi_U;D)\le L(\pi;D)+\ell(\pi)+\kappa_0$ on $D$) follows from (Dom).
* `thm:split:shared`, its proof and `ex:split:noisyparity`: base (steeper Thm 5, Ex 3.4), unchanged.
* "In the product class it concentrates on programs equivalent to the sampler": `thm:recovery:main`(b) (iid Thm 3.2, refereed) for PQ and `thm:split:private`(iv) for FR (iid Prop 3.3, V-I §1.1).
* Everything else is base material, unchanged in substance.

## 7. Deviations from the plan, with reasons

* **D-W1-1. `prop:absorb:price` moved from `absorb.tex` to App B** (`app:absorb:price`, next to `rem:absorb:why` and its proof). §4.4 keeps a three-sentence summary with the two key inequalities and the model-or-noise reading, and `\cref`s it. Reason: the main-text page budget (§8 below). All citations of the label still resolve.
* **D-W1-2. Page budgets exceeded in the main text** (§8). The planned 2.25 pp per section cannot hold the content the plan places there. The synthesis's own estimate for §3 (2.5 now, −table, +0.25 for PQ, +0.4 for the data hull) omits that the whole hull-lemma statement (0.45 pp) moves into the main text and the new `rem:setup:objects` (0.2 pp); for §4 (3.5 now → 2.0) its list of savings (`rem:absorb:why`, pricing proof sentence, one sentence for history, `q:absorb:shared` out, two remarks shortened) adds up to about 0.8 pp against +0.5 pp for `thm:split:shared` and its paragraph, and `q:absorb:shared` stays in the section by D3. I cut everything the plan lets me cut (see the list in §8) and moved `prop:absorb:price`. Options for FRONT if the main-text cap binds (each needs FRONT's decision, since each changes a placement the plan fixes): (a) move `prop:absorb:pricing` to App B with a two-sentence summary (−0.25 pp); (b) move `lem:setup:hull`(v),(vi) to App A as a separate appendix lemma, keeping (i)–(iv) in the main text (−0.2 pp; W2 cites them); (c) reduce `rem:absorb:wyeth` to (i) and (ii), the discussion carrying the rest (−0.15 pp); (d) move `lem:setup:basic` to App A (−0.12 pp).
* **D-W1-3. Local renamings** (PLAN §4.2 and its rule that symbols clashing with the notation table are renamed locally):
  * length thresholds $L\to\bar\ell$ in `thm:absorb:absorption`(a), `thm:split:shared`(ii), `lem:setup:hull`(iv) and `rem:setup:hullconverse` (lengths are ℓ-letters; $L$ is now the fit);
  * the number of shared coins in `prop:absorb:price` and $D_\beta$: $k\to s$ ($k$ is the sampler's program length in `thm:split:shared`, in the same section); in `rem:absorb:why` the input-length bound $k\to d$ (as in Paper 1 Remark 4.8);
  * in the proof of `prop:absorb:price`: $\gamma:=\min(\lambda,2)\to\bar\lambda$ (γ is a margin), $\tilde R\to\bar Q$ (R is the risk);
  * in the proof of `prop:absorb:pricing`: the loss $L(\nu,Q)\to\mathcal L(\nu,Q)$; in the proof of `thm:absorb:absorption`(d): the string length $L\to\bar n$; in (c3): $L_\pi(n)\to L(\pi;D_n)$;
  * in `lem:setup:hull`: hypotheses $h,h'\to\pi,\pi'$, $h_c\to\pi_c$ (plan); the risk $R\to$ a generic fit $F$, with the two readings named in the statement; the lower boundary $\underline C$; vertices $v_i=(\alpha_i,\rho_i)$ and edge slopes $-\sigma_i$ (as in split/kink §2, so that $v_i$ is a zero-window $(\sigma_i,\sigma_{i+1})$-kink in W2's language);
  * statements use the fit $L(\pi;o)$ for $-\log P_\pi(o)$ (`thm:absorb:absorption`(a), (c2), `lem:setup:coding`).
* **D-W1-4. `rem:setup:persample`**: "The coefficient of the length term must grow with the size of the data set" became "Against a teacher's systematic errors the coefficient …" (synthesis §3.3 item 4; PLAN §1.3, claims-table row "Must the length coefficient grow with the data?": for noise a fixed λ > 1 suffices). The pointer to `rem:limits:schedule` is kept.
* **D-W1-5. `def:setup:objectives`** gained one sentence: $J_\lambda$ and its minimisers are defined in the same way for every λ > 0. Reason: `lem:setup:hull` is stated for every weight $c>0$, and `thm:recovery:main`(d) (W3) has a free-exponent part for every λ > 0 (V-I §1.2). The posteriors stay defined for λ ≥ 1.
* **D-W1-6. Objects paragraph**: the sentence "$\Mprod$, $\MF$ and $\Mw$ agree up to $K(\dom D)+O(1)$ bits, but $\MF/\Mprod$ is unbounded" is no longer in §3 (it is in `rem:absorb:why`, App B, and summarised in `rem:absorb:wyeth`(iii)); $\Mw$ and $\MH$ are introduced in `def:setup:class`.
* **D-W1-7. Cuts inside W1's appendices** (no statement affected): the computed-check sentences after the proofs of `thm:split:shared` (300 cases), `prop:absorb:price` (key inequality) and `prop:absorb:history` (block identity); the "Reading" paragraph after the proof of `prop:absorb:price` (its content is in §4.4); the base sentence "the bound of (i) … with an example of the strict inequality" merged into the proof; the 401/300 point-set counts after the hull proof replaced by one sentence; the detail of the proof of `prop:absorb:inputs` (optional cut of PLAN §6).
* **D-W1-8. Status tags**: `q:absorb:shared` gained `\status{open}\src{…}`; `rem:setup:hullconverse` gained `\status{proved; computed}\src{…}`. Definitions keep `\src{}` only, as in the base and in the binding text of `def:setup:data` (there is no status value for definitions in PLAN §7.1(5)).
* **D-W1-9. Order in §4**: the new subsection on shared randomness and samplers comes second (after the absorption theorem, of which it is a corollary), before private randomness. The plan does not fix the order.

Status rendering (DECISIONS §A1) for W1's non-plain statuses: `lem:setup:hull` "strengthening of (iv) refuted" → `rem:setup:hullconverse` and "cannot be weakened" sentence in the proof idea; `rem:absorb:reading` "remark; known" → plain remark, known results cited inline (Poland–Hutter); `ex:split:noisyparity` "computed; illustration" → title "(an illustration)", "A direct computation (code in the accompanying repository) gives …", and the sentence that it is not an instance and its numbers are not values for any reference machine; `prop:absorb:pricing` "proved; computed" → the number 2.5431 in the proof, introduced by "A direct computation …"; `q:absorb:shared` "open" → question environment.

## 8. Pages (isolated builds, measured to the appendix heading and to "References")

| file | budget (PLAN §6) | measured | base |
|---|---|---|---|
| `setup.tex` | 2.25 | **3.52** | 2.70 |
| `app-setup.tex` | 2.5 | 2.10 | 1.94 |
| `absorb.tex` | 2.25 | **3.36** | 3.39 |
| `app-absorb.tex` | 3.5 | 3.87 | 3.61 |
| main text, W1 | 4.5 | 6.88 | 6.09 |
| appendices, W1 | 6.0 | 5.97 | 5.55 |

The appendices are within W1's total. The main text is about 2.4 pp over (reasons: D-W1-2). Cuts already made to reach these numbers: the companion-objects table → 3-line paragraph; `rem:absorb:why` → App B; `prop:absorb:price` → App B; `rem:absorb:reading`, `rem:absorb:wyeth` (run-in items), the "Compare" paragraph, the history paragraph and the opening of §4 shortened; `lem:setup:basic`'s proof inlined; the "selection has a simple geometry" paragraph cut to one sentence (its content is in the lemma and its proof idea).

Builds: `./test-section.sh setup app-setup` → OK (7 pages, 0 undefined citations, 11 undefined cross-section references, all listed in §3); `./test-section.sh absorb app-absorb` → OK (8 pages, 0 undefined citations, 12 undefined cross-section references, all listed in §3). No overfull boxes.

## 9. Paper 1 citations

No new Paper 1 citation. Numbers used: Theorem 3.8, Theorem 3.11, Question 3.14, Theorem 4.4, Proposition 4.7, Remark 4.8, Theorem 5.1(a), Theorem 5.3, Propositions 5.6, 5.7 and 5.7(a), Theorem 6.16, Corollary 6.17 and 6.17(a); each carries a `% P1:` comment with its label. `check_companion_numbers.py` (run read-only) prints ALL OK and lists "Theorem~5.1" as used but not in its list: checked by hand against `paper/main.aux`, `thm:learn:dominance` is Theorem 5.1 (already cited in the base `rem:absorb:wyeth`).

## Fixes (fix round, DECISIONS-restructure; fix-W1.json)

Files edited: `setup.tex`, `app-setup.tex`, `absorb.tex`, `app-absorb.tex` only. No git command that changes repository state was run. No label was renamed or removed; one new structural label, `app:setup:basic`.

### id → change

* **RW1-01 (length, §3).**
  * (1) `lem:setup:basic` (statement, `\status{proved}`, `\src{steeper Lemma 1.1}`, label) and its two-line proof moved to a new subsection A.2 "Basic properties of the objectives" (`app:setup:basic`, new structural label), between the standard facts and the hull proof. In §3 the exact sentence "If some program has finite $J_\lambda$, the $\lambda$-MAPs are finitely many and nonempty, they maximise both posteriors, and on deterministic hypotheses tempering changes nothing (\cref{lem:setup:basic})." ends the paragraph after `def:setup:objectives`. Citers (`app-split.tex` (iii), `app-parity.tex` (i)) still resolve.
  * (2) The generalised-posterior sentence with its five citations is replaced by "The tempered posterior $\Pi^{1/\lambda}$ is a generalised posterior with learning rate $1/\lambda$ (\cref{rem:related:posteriors})." The five works stay cited in `related.tex`. The sentences on $\Pi_\lambda\propto(\Pi^{1/\lambda})^\lambda$ ("has the same maximiser", now read against the $\Pi^{1/\lambda}$ of the preceding sentence) and "Our posterior results concern $\Pi_\lambda$ unless stated." are kept.
  * (3) `rem:setup:objects` is 4 lines, checked in a build with the full-build reference texts substituted (the isolated build prints "??"). (a)–(d) and both Paper 1 citations with their `% P1:` comments are kept. To fit: title "Repeated inputs" (was "Which object; repeated inputs"); (a) points to `\cref{sec:recovery}` instead of `thm:recovery:main` and `prop:recovery:frozen` (both in §6); (b) without the examples; (c) "Only product hypotheses are scored per query, by their terms in $\Mpq$ [P1 Prop 5.7]; SFI's expected loss would be infinite [P1 Prop 5.6]"; (d) "FQ (\cref{sec:teacher}) counts a frozen table per query".
  * Further prose trims in §3, needed to reach the target (DECISIONS-restructure §3: "trimming prose"); no statement changed:
    * the opening sentence shortened to two lines;
    * the $\Mprod$ sentence of the objects paragraph;
    * the κ paragraph;
    * in the proof idea of `lem:setup:hull`, the clause "and the derivative of $\Phi_D(\lambda)$ … is the MAP length" is cut ($\Phi_D$ is used nowhere else; (vi) states the derivative);
    * "The last lemma is the sufficiency line: one bit of description pays for at most one bit of fit." (was "… line for data-set classes: …"; the lemma says "in every data-set class");
    * the last paragraph of §3 ("What separates …") is one sentence.
* **RW1-02 (length, §4).**
  * (1) `prop:absorb:pricing` (statement, label, `\status`, `\src`) moved to App B.4, with the definition of $Q_x$ before it and the sentence on Gibbs' inequality and Sion's theorem as the first sentence of its proof. B.4 is retitled "Per-input pricing", since it now holds the statement; label `app:absorb:pricing` unchanged. In §4.3 the two decided sentences replace the opening paragraph, the proposition and the Gibbs/Sion sentence. **One addition to the decided text:** "with $Q_x$ the law of $f(x)$" after "$\sum_iH(Q_{x_i})$ bits". Without it $Q_x$ is undefined in the main text, since its definition moved with the proposition. `cor:absorb:nouniversal` and its proof stay; its `\cref{prop:absorb:pricing}(ii)` now points to App B.
  * (2) In the paragraph after the proof idea of `thm:split:shared`, the first sentence and the last two sentences are kept. "Both predictors still predict well: … $\lambda\ell_U+\kappa_0+k$." with `\citet[Theorem~5.3]` (`% P1: thm:learn:merging`) moved to App B.3 (`app:split:shared`). It is placed right after the proof of `thm:split:shared`, not after `ex:split:noisyparity`, which closes B.3. Reason: after the example, "both predictors" would read as the example's finite product and shared classes. Out of context its subject now reads "The product and the shared predictor both still predict well"; the rest is verbatim.
  * (3) `rem:absorb:wyeth`: (iii) "*The restriction has a price and a boundary*: randomness shared across inputs costs more, and the protection ends where hypotheses see labelled history (\cref{rem:absorb:why,prop:absorb:price,prop:absorb:history})". (iv) "*Algorithmic statistics*: the $d$-bit parameter of a noisy random parity is noise for set models, which share their randomness, and model for product models (\cref{prop:algstat:parity,prop:parity:kink,prop:parity:sets})". Each is one clause and keeps its `\cref` targets. (iv) keeps the base reading, which agrees with `parity.tex` ("the minimal sufficient statistic treats it as noise"). (i), (ii) and the two closing sentences, with Theorem~5.1(a) (`% P1: thm:learn:dominance`), are unchanged.
  * Further prose trims in §4 (no statement changed):
    * §4.2, second sentence: "… to select $\pi_\nu$, model plus noise, not a \emph{fill-in}, a deterministic program storing the sampled labels …";
    * §4.4, first paragraph: the pointer to `rem:absorb:why` is now a parenthesis; "A product class pays for such a coin either as model, at $\lambda$ bits, or as noise at every input that shows it"; "Persistent latent causes, such as a per-batch coin, …";
    * §4.4, second paragraph: "one product hypothesis that pays its best member's log-weight once per block"; "pricing stays per input"; "with shared randomness (\SFIhist{}) \cref{thm:absorb:absorption} applies".
* **RW1-03.** The first sentence of §4.2 is now the exact text of D11(g): "A \emph{sampler} is a probability kernel $\nu$ (\cref{def:split:setting}); here it has a program $\pi_\nu$ of length $k$ in the class considered, so in the canonical classes it is a computable conditional measure."
* **RW1-04.** `thm:split:shared`(ii): "for every nonempty set $A$ of programs" (D11(k)).
* **RW1-05.** The fit of the hull lemma is written $L$, not $F$ (D11(z)). Places:
  * the statement of `lem:setup:hull`: the family $(\ell(\pi),L(\pi))_\pi$, $L(\pi)\in[0,\infty]$, $J_c:=c\,\ell+L$, "Data reading: $L=L(\cdot;D)$ … Population reading: $L=R$", (ii) $L(\pi)\le L(\pi')$, (iii) "least-$L$ vertex", (iv) $\min\{L(\pi):\ell(\pi)\le\ell(\pi_c)\}$, $\min\{L(\pi):\ell(\pi)\le\bar\ell\}$, "least-$L$ vertex";
  * its proof in A.3 (every $F(\pi)$, $(\ell,F)$, $c\,\ell+F$, "least-$F$");
  * `rem:setup:hullconverse` ($\min\{L:\ell\le\bar\ell\}$, "least-$L$ vertex").

  Item numbering and content are unchanged. The standard facts (F1)–(F5), the random function $F$ of `def:setup:product` and the check id in `\src{… c6(F) …}` are untouched. No other group's file uses the hull lemma's $F$ (grep).

### Items moved between main text and appendix (this round)

| item | from | to |
|---|---|---|
| `lem:setup:basic` with its proof | §3 (`setup.tex`) | App A.2 `app:setup:basic` (new subsection) |
| `prop:absorb:pricing`, the definition of $Q_x$, the Gibbs/Sion sentence | §4.3 (`absorb.tex`) | App B.4 `app:absorb:pricing` |
| the prediction sentence after `thm:split:shared` (Paper 1 Theorem 5.3) | §4.2 (`absorb.tex`) | App B.3 `app:split:shared` |

### Cross-references changed

* New `\cref`s to other groups' labels:
  * `rem:related:posteriors` (FRONT, defined in `related.tex`; it renders "Section 2");
  * `sec:recovery` (W3), in `rem:setup:objects`.
* `setup.tex` no longer cites `thm:recovery:main` or `prop:recovery:frozen`. `absorb.tex` still cites `thm:recovery:main`.

### Builds and pages (after the last isolated builds)

* `./test-section.sh setup app-setup`: OK, 6 pages, 0 undefined citations, 11 undefined cross-section references. They are `cor:absorb:nouniversal`, `sec:absorb` (both intra-W1), `cor:kink:split`, `def:kink:kinks`, `sec:kinks`, `rem:limits:schedule`, `rem:related:posteriors`, `rem:teacher:selected`, `sec:recovery`, `sec:teacher`.
* `./test-section.sh absorb app-absorb`: OK, 8 pages, 0 undefined citations, 12 undefined cross-section references. They are `def:setup:shared`, `lem:setup:hull` (both intra-W1), `def:kink:kinks`, `prop:kink:universal`, `def:split:setting`, `rem:split:siprograms`, `sec:recovery`, `thm:recovery:main`, `thm:split:private`, `prop:algstat:parity`, `prop:parity:kink`, `prop:parity:sets`.
* Both builds have no overfull boxes and no multiply defined labels.
* Measurement:
  * main text: from the section heading to the appendix heading;
  * appendix: from the appendix heading to "References";
  * in pages of the text block.
* The same numbers come out of a copy built with the full-build reference texts (from `main.aux`) in place of "??".

| file | target (DECISIONS-restructure §3) | before this round | after |
|---|---|---|---|
| `setup.tex` (§3) | 3.0 ± 0.15 | 3.52 | **3.10** |
| `absorb.tex` (§4) | 2.9 ± 0.15 | 3.36 | **3.00** |
| `app-setup.tex` (App A) | 2.4 | 2.10 | 2.28 |
| `app-absorb.tex` (App B) | 4.4 | 3.87 | 4.24 |
| main text, W1 | 5.9 | 6.88 | 6.10 |
| appendices, W1 | 6.8 | 5.97 | 6.52 |

In the full build §3 and §4 start mid-page, so their lengths there can differ by a few lines of page-break slack.

### Paper 1 citations

* No new Paper 1 citation.
* Theorem~5.3 (`% P1: thm:learn:merging`) moved from `absorb.tex` to `app-absorb.tex`.
* `check_companion_numbers.py` (run read-only):
  * prints ALL OK;
  * lists "Theorem~5.1" as used but not known to it. Checked by hand against `paper/main.aux`: `thm:learn:dominance` is Theorem 5.1, as in the first round;
  * lists "Remark~B.3" as intended but unused. It is not used in W1's files, nor in the base `app-related.tex`.
