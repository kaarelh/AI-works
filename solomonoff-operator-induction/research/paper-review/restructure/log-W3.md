# Log of writer W3 (exact model recovery): Paper 2 restructure

Files written (all in `paper-steeper/sections/`): `recovery.tex` (new), `app-recovery.tex` (new), `app-split.tex` (rewritten as the continuation of App D, no `\section`), `split.tex` (emptied to the one line of PLAN §2). No other file was edited. No git command that changes repository state was run (only `git status`, `git log`, `git show dcb3a3a3:…`).

Inputs read: PLAN.md (in full); REFRAME.md; DECISIONS.md (§0, §A1–§A12, §B, §C, §D, §E, §F Paper 2, §G, §H); `split/notes-final.md` (in full); `split/final-check.md`; `split/verify-iid.md` and `split/verify-kink.md` (in full); `split/verify-teacher.md` (verdicts, §2); `split/iid/notes-final.md` (§0–§9, every statement and proof used); `split/kink/notes-final.md` (§0–§3, §5 in full); `split/iid/referee-A.md` (M3); the base `split.tex`, `app-split.tex`, `setup.tex`, `discussion.tex` (`git show dcb3a3a3`); the working `setup.tex`, `absorb.tex`, `kinks.tex` (for labels and notation only) and `log-W1.md`; `paper/main.aux` (Paper 1 numbers).

## 1. What each file contains

### `recovery.tex` — §6 "Exact model recovery from samples" (`sec:recovery`, alias `sec:split`)
* Opening paragraph: the first and main reason (model-plus-noise splits work exactly per query); λ = 1 on one data set (similar posterior) against λ = 1 in the limit (exact per query, on the run with frozen labels); what λ > 1 adds (class-free rate); the sample kink; frozen labels.
* §6.1 `sec:split:setting`: `def:split:setting` (rewritten: class $\mathcal C$ with Kraft weights and kernels; sampler = probability kernel; $o_n$, $L_n(\pi)$, sampled randomness $L_n(\nu)$; per-query part: $\mathcal E,\mathcal E_0,\ell_0$, ${\Hel}_\mu$, margins $\gamma_{\bar\ell},\gamma_-,\gamma_=(\ell)$; any-input-rule part: $\pi_\nu$ of length $k$; fill-ins and $\Wdet$); `lem:split:ville` (scope: every input rule fixing $x_{n+1}$ before $y_{n+1}$, frozen or per-query labels, ν need not be in the class; current deficiency $\delta_n$ added; δ* with $\nu(o_n)$ inside, V-K §2.3) with proof idea.
* §6.2 `sec:recovery:main` (new): $H_\mu(\nu)$, $W_\lambda$, the Chernoff coefficient $\mathsf C_s$; `thm:recovery:main` (a) limit for every $1\le\lambda_n=o(n)$, (b) posteriors, (c) every $n$ for λ > 1, (d) free exponent (every λ > 0) and margin form; proof idea; `rem:recovery:posterior` (concentration on $\mathcal E$ not $\mathcal E_0$; 8/9 at λ = 1.5, 4/5 tempered: exact arithmetic from (b)); `rem:recovery:method` (standard method, no novelty for (a),(b); Barron–Cover "studied by").
* §6.3 `sec:recovery:lambda1` (new): the classes $\mathcal C_k$, $\mathcal C_{k,M}$ and the recovery time $n_{\rm rec}(\varepsilon)$; `prop:recovery:lambda1` (a)–(c) with proof idea; the computed-numbers sentence and `tab:recovery:times` (ε = 0.01, $\ell_0\in\{16,24,32,40\}$, λ ∈ {1, 1.1, 1.5, 2, 3}; no κ, so not marked as illustrations, V-I §2 item 7); Remark 4.7′ as prose (only the corrected form, D10); a summary paragraph of `prop:recovery:necessity` (statement in App D, deviation D-W3-1).
* §6.4 `sec:recovery:kink` (new): `thm:recovery:kink` (i)–(v) with proof idea and a two-line reading; `rem:recovery:window` (excess $k-7$; "the natural strengthening … fails").
* §6.5 `sec:recovery:noisy` (new): `cor:recovery:noisy` (i)–(iii) with proof idea; the frozen comparison after it with the exact values of V-I §1.10 (0.255, 0.255, 0.204, 0.566; second class 0.136, 0.136, 0.085, 0.566); the proved part is in `rem:recovery:frozentable` (App D).
* §6.6 `sec:split:private`: definition of "ν-equivalent on the run"; `thm:split:private` ((i)–(iii) for fixed λ > 1, any input rule, frozen or per-query labels; (iv) for every λ ≥ 1, hypothesis on $\pi_\nu$ in the almost-sure form of V-I §1.1); proof idea; one paragraph on what equivalence on the run is per query and with frozen labels; `prop:recovery:frozen` (a)–(c) with proof idea; the decimal $0.1457$; a summary paragraph of `prop:recovery:beyond` (statement in App D, deviation D-W3-2).
* §6.7 `sec:split:lambda1`: the stream-lemma paragraph (Paper 1 Prop 4.6(a)); $d_n,\beta_n,i_n,t_n$; `thm:split:lambda1` (i)–(iii), (iv) cut; its 3-line proof; the Eisenstat paragraph (personal communication, as the acknowledgements require) and the SI paragraph (`prop:split:si`, `rem:split:siprograms`); `rem:split:reading` (rewritten: what frozen labels give); `q:recovery:open` (a)–(e).

### `app-recovery.tex` — App D "Proofs for §6 (exact model recovery)" (`app:recovery`, alias `app:split`)
* Notation paragraph ($\Lambda_n$, $t_{\bar\ell}$, $Z^{\bar\ell}_n$: proofs only).
* D.1 `app:recovery:tools`: `lem:recovery:ratios` (appendix-only; iid Lemmas 2.1, 2.2(b),(c); kink Lemma 5.1 (pq)) with proof: (a) supermartingales and the tail bound for any input rule, (b) the Kakutani step, (c) KL and the strong law, (d) Chernoff coefficients and Hellinger.
* D.2 `app:recovery:main`: proof of `thm:recovery:main` (iid Thm 3.1 with `eq:recovery:beats`, Thm 3.2, Thm 4.1(i)–(iii), (iv′), (iv)).
* D.3 `app:recovery:lambda1`: parity facts; proofs of `prop:recovery:lambda1` (iid Prop 5.1(a),(b),(b′), Thm 4.1(iv′)); the statement of `prop:recovery:necessity` (a)–(e) and its proofs (iid Props 4.4(a) with 4.2, 4.4(b), Remark 4.5 in the V-I §1.5 form, Prop 4.3).
* D.4 `app:recovery:kink`: proof of `thm:recovery:kink` (kink Lemmas 5.1–5.3 (pq), Thm 5.4, Cor 5.7(a),(d)) and of `rem:recovery:window` (iid Lemma 8.1(iv)).
* D.5 `app:recovery:noisy`: proof of `cor:recovery:noisy`; `rem:recovery:frozentable` (appendix-only; iid Cor 6.1(vi): the penalised empirical rate sentence in the corrected wording of V-I §1.10, "eventually (once the table is complete)", the proved bound $(7/8)^{64}$).
* D.6 `app:recovery:beyond`: the run with frozen labels; proofs of `prop:recovery:frozen` (iid Props 7.5, 7.6(b),(d)); $\KL_\mu$, $R_\nu$; the statement of `prop:recovery:beyond` (a)–(c) and its proofs (iid Props 7.2(b), 7.3(iii′), 3.4(a)–(c)).

### `app-split.tex` — continuation of App D (first line is a `\subsection`)
* `app:split:ville`: proof of `lem:split:ville` (one-point inequality for shared hypotheses and termwise for $\xi_{\mathcal C}$; per query and frozen).
* `app:split:stream`: `lem:split:stream` and its proof (base, unchanged in substance); the computed costs sentence (5.6–8.9 bits); the hashing comparison dropped.
* `app:split:si`: `prop:split:si` with proof; `rem:split:siprograms` (base).
* `app:split:private`: proof of `thm:split:private`; (iv) now for every λ ≥ 1, the confinement by (i) replaced by the $Z^{\bar\ell}$ supermartingale step and the tail by $Z^{\bar\ell}$ with Borel–Cantelli (V-I §2 item 4).
* Removed (given to W1): the subsection `app:split:shared` and `ex:split:noisyparity`. Cut: `lem:split:hash`, `app:split:hash`.

### `split.tex`
* Exactly the one line of PLAN §2 ("% Superseded in the restructure (PLAN.md): …").

## 2. Labels defined (checked against the manifest, PLAN §3.1–§3.3)

Checked by script (`grep \label` on my files against the manifest): every manifest label assigned to W3 is defined exactly once in my files; the cut labels and the labels given away are absent; the combined build of my three files (scratch, `recovery`+`app-recovery`+`app-split`) shows 0 multiply defined labels.

| file | labels |
|---|---|
| `recovery.tex` | `sec:recovery` (new), `sec:split` (alias), `sec:split:setting`, `def:split:setting`, `lem:split:ville`, `sec:recovery:main` (**new structural**), `thm:recovery:main`, `rem:recovery:posterior`, `rem:recovery:method`, `sec:recovery:lambda1` (**new structural**), `prop:recovery:lambda1`, `tab:recovery:times`, `sec:recovery:kink` (**new structural**), `thm:recovery:kink`, `rem:recovery:window`, `sec:recovery:noisy` (**new structural**), `cor:recovery:noisy`, `sec:split:private`, `thm:split:private`, `prop:recovery:frozen`, `sec:split:lambda1`, `thm:split:lambda1`, `rem:split:reading`, `q:recovery:open` |
| `app-recovery.tex` | `app:recovery` (new), `app:split` (alias), `app:recovery:tools` (**new structural**), `lem:recovery:ratios` (**new, appendix-only**), `app:recovery:main` (**new structural**), `eq:recovery:beats` (**new structural**), `app:recovery:lambda1` (**new structural**), `prop:recovery:necessity` (manifest: `recovery.tex`; **deviation D-W3-1**), `app:recovery:kink` (**new structural**), `app:recovery:noisy` (**new structural**), `rem:recovery:frozentable` (**new, appendix-only**, cited only from my own `recovery.tex`), `app:recovery:beyond` (**new structural**), `prop:recovery:beyond` (manifest: `recovery.tex`; **deviation D-W3-2**) |
| `app-split.tex` | `app:split:ville`, `app:split:stream`, `lem:split:stream`, `app:split:si`, `prop:split:si`, `rem:split:siprograms`, `app:split:private` |
| `split.tex` | none |

Item structures (PLAN §3.6), all kept: `thm:recovery:main` (a)–(d); `prop:recovery:lambda1` (a)–(c); `prop:recovery:necessity` (a)–(e); `thm:recovery:kink` (i)–(v); `prop:recovery:frozen` (a)–(c); `prop:recovery:beyond` (a)–(c), with (b) reduced (D-W3-2); `thm:split:private` (i)–(iv); `thm:split:lambda1` (i)–(iii); `q:recovery:open` (a)–(e). `cor:recovery:noisy` has (i)–(iii) (PLAN: "W3 numbers the items"; D-W3-3).

## 3. Every `\cref` to another group's label

All are in the stable lists of PLAN §3.6.

| from | to (group) | items used |
|---|---|---|
| `recovery.tex` `def:split:setting` | `def:setup:data` (W1) | — |
| `recovery.tex` opening, §6.4, §6.6 | `sec:kinks` (W2) | — |
| `recovery.tex` §6.4 | `def:kink:kinks` (W2) | left steepness $s_-$, right secant $s_+$ with $\mathcal M=\mathcal C$; right line |
| `recovery.tex` `thm:recovery:kink` proof idea; `app-recovery.tex` D.4 | `cor:kink:locate` (W2) | (c) |
| `recovery.tex` `thm:recovery:kink` proof idea; `app-recovery.tex` D.4, D.6 | `lem:setup:hull` (W1) | (v) |
| `recovery.tex` §6.6 | `sec:teacher` (W5) | — |
| `app-recovery.tex` D.2; `app-split.tex` `rem:split:siprograms` | `lem:setup:basic` (W1) | (i), (iii) |
| `app-split.tex` stream proof | `def:setup:class` (W1) | closure under prefix-free simulation |
| `app-split.tex` Ville proof | `def:setup:shared` (W1) | one-point inequality |

No [V-T] label is cited (`lem:kink:secant` is not used).

Labels of mine cited by other groups' working files (checked by grep): `def:split:setting`, `sec:recovery`, `thm:recovery:main`(b), `thm:split:private`(iv), `rem:split:siprograms`, `prop:recovery:frozen` (W1); `sec:recovery`, `thm:recovery:kink` (W2); `thm:split:private`, `lem:split:ville` (W6 base files); FRONT's base files cite `thm:split:lambda1`, `prop:split:si`, `rem:split:reading`, `sec:split`, `sec:split:lambda1`. All exist. No working file outside `app-verification.tex` (switched off, not edited) cites `lem:split:hash` or `app:split:hash`.

## 4. Moves

| label(s) | from | to | note |
|---|---|---|---|
| `thm:split:shared`, `sec:split:shared` | W3 `split.tex` | W1 `absorb.tex` | given; `split.tex` emptied, so they no longer exist in my files (W1's log confirms receipt) |
| `ex:split:noisyparity`, `app:split:shared` | W3 `app-split.tex` | W1 `app-absorb.tex` | given; deleted from `app-split.tex` |
| base `split.tex` labels (`def:split:setting`, `lem:split:ville`, `thm:split:lambda1`, `thm:split:private`, `rem:split:reading`, `sec:split`, `sec:split:setting`, `sec:split:private`, `sec:split:lambda1`) | `split.tex` | `recovery.tex` | within W3 |
| `app:split` | `app-split.tex` | `app-recovery.tex` (alias on the App D `\section`) | within W3 |
| cut | `lem:split:hash`, `app:split:hash`, `thm:split:lambda1`(iv) | — | PLAN §3.1 |

## 5. [V-T] items

None. My files use no item of `verify-teacher.md`. (`verify-teacher.md` exists; not needed.)

## 6. Mathematics against the records and the verification reports

| label | record | status used |
|---|---|---|
| `thm:recovery:main`(a),(b) | iid Thms 3.1, 3.2 | refereed |
| `thm:recovery:main`(c) | iid Thm 4.1(i)–(iii) | refereed |
| `thm:recovery:main`(d) | iid Thm 4.1(iv′), (iv) | (iv′) V-I §1.2: main display for every λ > 0; the $s=1/\lambda$ forms only used for λ > 1; (iv) refereed |
| tempered limit shares $2^{-\ell}/W_1$ in (b) | iid Thm 3.2 proof | final-check: follows from the same proof (E-terms constant, normaliser → $W_1$); the appendix proof shows it |
| `rem:recovery:posterior` | iid Thm 3.2 and the refutation after it | the 8/9 and 4/5 are exact from (b), so not "computed" |
| `prop:recovery:lambda1` (a), (b), (c) | iid Prop 5.1(a), (b), (b′); Thm 4.1(iv′) with $s=1/\lambda$ | (a),(b) refereed; (b′) V-I §1.4 (ε < 31/32, $k$ even; lower end needs $D\ge2^{(k-8)/2}$, upper end uniform in $D$) |
| Remark 4.7′ prose | iid Remark 4.7 | **V-I §1.6 corrected form only**; none of the three false sentences is stated |
| `tab:recovery:times` | iid i7(A), V-I v4(A) | computed; exact |
| `prop:recovery:necessity` (a)–(e) | iid Props 4.2, 4.4(a), 4.4(b), Remark 4.5, Prop 4.3 | refereed; (d) V-I §1.5 ("an integer $k$ and a real λ > 1", $\mathcal C_{k,n}$ so $D\ge M$) |
| `thm:recovery:kink` (i)–(iv) | kink Lemmas 5.1–5.3, Thm 5.4 (pq); iid Lemma 8.1(i)–(iii) | V-K §2 (δ* with $\nu(h_n)$, V-K §2.3; offset $\ell_0+\delta^*\ge0$, V-K §2.3) |
| `thm:recovery:kink` (v) | kink Cor 5.7(a),(d) | V-K §3 |
| `rem:recovery:window` | iid Lemma 8.1(iv) | V-I §1.7 |
| `cor:recovery:noisy` (i)–(iii) | iid Cor 6.1(i),(ii),(iv),(v) | refereed |
| frozen comparison; `rem:recovery:frozentable` | iid Cor 6.1(vi) | **V-I §1.10 corrected**: exact values 0.255/0.255/0.204/0.566 and 0.136/0.136/0.085/0.566; corrected "penalised empirical rate" sentence; "eventually (once the table is complete)" |
| `thm:split:private` (i)–(iii) | steeper Thm 4; iid Prop 7.2(a) for per-query labels and any rule | refereed |
| `thm:split:private` (iv), every λ ≥ 1 | iid Prop 3.3 | **V-I §1.1**: hypothesis in the a.s. form; proof per V-I §2 item 4 |
| `prop:recovery:frozen` (a)–(c) | iid Props 7.5, 7.6(b),(d) | refereed; $1-(63/64)^{10}=0.1457$ outside the statement |
| `prop:recovery:beyond` (a) | iid Prop 7.2(b) | refereed |
| `prop:recovery:beyond` (b) | iid Prop 7.3(iii′) | V-I §1.8 |
| `prop:recovery:beyond` (c) | iid Prop 3.4(a)–(c) | (a) refereed; (b),(c) V-I §1.3: never "iff", "$c=c^*$ not covered", "provided $J_c(\pi)<\infty$ for some π" |
| `lem:recovery:ratios` | iid Lemmas 2.1, 2.2(b),(c); kink Lemma 5.1 (pq) | refereed / V-K §2.1 |
| `lem:split:ville`, `thm:split:lambda1`, `lem:split:stream`, `prop:split:si`, `rem:split:siprograms` | base (steeper) | unchanged in substance |

Statements not made (D8 and budget): iid Thm 4.1(v) (uniform in time), (vi), (vii); Prop 7.3(i), (ii), (iv), (v) (the LIL), Conj 7.4 (asked as `q:recovery:open`(e)); Prop 4.4(c); Lemma 5.2, Prop 5.3(b)–(d); Remark 7.7; Cor 6.1(iii) (the gap formula for competitors); kink Cor 5.5, Thm 5.6, Prop 5.8, Prop 5.10.

## 7. Deviations from the plan, with reasons

* **D-W3-1. `prop:recovery:necessity` is stated in App D** (`app:recovery:lambda1`), not in `recovery.tex`. §6.3 carries a four-sentence summary that cites it. Reason: the main-text budget (§8). Label and items (a)–(e) unchanged; every `\cref` resolves.
* **D-W3-2. `prop:recovery:beyond` is stated in App D** (`app:recovery:beyond`); §6.6 carries a one-paragraph summary. Its item (b) is reduced to iid Prop 7.3(iii′) ("misspecification: no fill-ins per query"), the first optional cut of PLAN §6 for W3; the oscillation result (iid Prop 7.3(ii)) is not stated. Reason: page budget. Items (a), (c) unchanged.
* **D-W3-3. `cor:recovery:noisy` has three items**: (i) model and exact rate; (ii) fill-ins; (iii) degenerate cases and the canonical class (iid Cor 6.1(iv),(v) merged). iid Cor 6.1(iii) (the Hellinger gap of competitors) is not stated. The frozen comparison: the computed values are in the main text after the corollary, as the plan asks; the proved bound $(7/8)^{64}$, the class description and the corrected "penalised empirical rate" sentence are in the new appendix remark `rem:recovery:frozentable` (W3 prefix, cited only from my own files).
* **D-W3-4. Hashing comparison dropped** from the numbers paragraph after `lem:split:stream` (the plan allows it). Paper 2 no longer cites Paper 1 Remark B.3 (`check_companion_numbers.py` lists it as "intended not used"; informational).
* **D-W3-5. Computed re-checks after proofs dropped** (the Ville simulation, the certification check on 600 samplers, the 1440-case check of `thm:split:private`; DECISIONS §A9 allows; budget).
* **D-W3-6. `thm:split:private` generalised as the plan intends**: any input rule, frozen or per-query labels (iid Prop 7.2(a) for (i)–(iii), iid Prop 3.3 for (iv)); hypothesis on $\pi_\nu$ in the almost-sure form $\nu_{\pi_\nu}(o_n)=\nu(o_n)$ for all $n$ (V-I §1.1). Its section title is now "Frozen labels, adaptive inputs and misspecification" (the base "λ > 1 with private randomness: samplers beat fill-ins" became the first sentence of the subsection's material).
* **D-W3-7. `thm:split:lambda1`** states δ* explicitly (Ville deficiency of $\xi_\times=\Mprod$) and defines $i_n$ through $|\dom D_n|$ (with frozen labels after $n$ queries $D_n$ may have fewer than $n$ inputs; on distinct inputs this is the base's $n$).
* **D-W3-8. Notation** (PLAN §4; local names recorded): $o_n$ for the data after $n$ queries ($h_n$ or $D_n$); $\KL_\mu(\pi)$ for the records' $D(\pi)$ ($D$ is a data set); $R_\nu$ for the records' $R$ (risk under the sampler; $R$ is the teacher risk of `rem:setup:persample`); $n_{\rm rec}(\varepsilon)$; $Z(s)$; $\underline s$ in `thm:recovery:kink`(v); $\Lambda_n$, $t_{\bar\ell}$, $Z^{\bar\ell}_n$, $g_i$ in proofs only; length caps $\bar\ell$, $\bar\ell_\varepsilon$; $\mathsf C_s$ (Chernoff coefficient); braced ${\Hel}_\mu$. No new preamble macro.
* **D-W3-9. Sampler**: `def:split:setting` defines a sampler as a probability kernel (needed for the per-query theorems, where ν need not be computable) and, under "any input rule", a program $\pi_\nu$ of length $k$ equal to ν at every queried input, noting that in $\Hcl{\times}$ such a ν is a computable conditional measure. W1's one-sentence definition in `absorb.tex` ("a computable conditional measure … with a program $\pi_\nu$ of length $k$ in the class considered (`def:split:setting`)") is consistent with this; FRONT may want to align the wording.
* **D-W3-10. Page budgets exceeded** (§8). Options for FRONT if the caps bind, each a placement change only: (a) move `cor:recovery:noisy` and its paragraph to App D with a three-line summary (−0.45 pp main); (b) move `rem:recovery:window` to App D, keeping one sentence (−0.1); (c) drop the posterior example in `rem:recovery:posterior` (third optional cut of PLAN §6; −0.05); (d) move `prop:recovery:frozen`(c) to App D (−0.1); (e) in App D, drop `rem:recovery:frozentable` and `prop:recovery:beyond`(b) (−0.3 app).

Status rendering (DECISIONS §A1) for non-plain statuses: `lem:split:ville` "Ville's inequality known" → \citep{ville1939etude} in the proof idea; `thm:split:private` "Kakutani-type argument known" → \citep{kakutani1948equivalence}; `prop:recovery:lambda1` "proved; computed" → "A direct computation (code in the accompanying repository) … \cref{tab:recovery:times}"; `rem:recovery:posterior`, `rem:recovery:window` "a natural strengthening refuted" → "The natural strengthening … fails: …"; `rem:recovery:method` "remark; known" → standard argument, no novelty, Barron–Cover "studied by"; `prop:split:si` "(iii) known" → \citep{li2008introduction}; `lem:split:stream` "proved; computed" → the computed costs sentence; `lem:recovery:ratios` "strong law and Ville's inequality known" → named and cited in the proof; `q:recovery:open` "open" → question environment. Process vocabulary: the DECISIONS §A5 grep on the text of both isolated builds finds only formula renderings ($\mathcal E_0$ as "E0").

## 8. Pages (isolated builds; combined scratch build of the three files for the split between them)

| file | budget (PLAN §6) | measured |
|---|---|---|
| `recovery.tex` | 4.75 | **5.85** |
| `app-recovery.tex` | 5.0 | **5.85** |
| `app-split.tex` | 2.0 | **2.5** |
| `split.tex` | — | 0 |
| main text, W3 | 4.75 | 5.85 |
| App D, W3 | 7.0 | 8.35 |

Base: `split.tex` 3 pp, App E 4 pp. Reasons for the excess: the plan places in §6 four theorems/propositions with 4–5 items each (`thm:recovery:main`, `prop:recovery:lambda1`, `thm:recovery:kink`, `thm:split:private`) plus two further propositions, a corollary, the base λ = 1 theorem, a table, five remarks and a question; even after D-W3-1, D-W3-2 and the cuts of D-W3-3 to D-W3-5 the material does not fit 4.75 pp. Cuts already made: the uniform-in-time and posterior finite-sample forms of iid Thm 4.1; `prop:recovery:necessity` and `prop:recovery:beyond` moved to App D; their proof ideas replaced by summaries; the frozen-table proof moved to App D; the hashing comparison and the computed re-checks; compressed opening, proof ideas, readings and question.

Builds: `./test-section.sh recovery app-recovery` → OK (12 pages, 0 undefined citations, 17 undefined references: all other groups' labels listed in §3 plus my own `app-split.tex` labels); `./test-section.sh split app-split` → OK (3 pages, 0 undefined citations, 10 undefined references, all to `recovery.tex`, `app-recovery.tex` and W1's `def:setup:*`, `lem:setup:basic`). 0 overfull boxes in both. A combined scratch build of `recovery` + `app-recovery` + `app-split` gives 0 multiply defined labels, and its only undefined references are the other groups' labels of §3.

## 9. Paper 1 citations

No new Paper 1 citation. Used: Proposition 4.6(a) (`prop:versions:tape`) and Section 7.3 (`sec:ex:eisenstat`), each with a `% P1:` comment; both in the known list and checked against `paper/main.aux`. Remark B.3 is no longer cited (D-W3-4). `check_companion_numbers.py` (read-only run): ALL OK.

## Fixes (fix round, DECISIONS-restructure; `fix-W3.json`, 12 entries)

Files edited: `recovery.tex`, `app-recovery.tex`, `app-split.tex` (all W3). `split.tex` unchanged. No label renamed, added or removed; every moved statement keeps its label, `\status{}` and `\src{}`. No git command that changes repository state; no full build (FRONT's).

| id | change |
|---|---|
| RW3-01 | `recovery.tex` opening paragraph: "every $\lambda\ge1$ identifies it on the queried inputs" replaced by the exact D1 text ("eventually selects programs that are $\nu$-equivalent on the run: their Hellinger gaps to $\nu$ along the queried inputs are summable"). |
| RW3-02 | D2 verbatim, three places: (1) `def:split:setting`, end of "Any input rule": the sentence on indexing by distinct inputs; (2) `lem:recovery:ratios`: new first sentence (indexing by queries per query, by distinct inputs for frozen labels; $o_i$, $\Lambda_i$, $g_i$ at the $i$-th step; the parenthesis on query indexing); (3) proof of `lem:split:ville`: "With frozen labels and a repeated query, $Z_{n+1}=Z_n$. Otherwise, given …". Check of downstream proofs: `thm:split:private`(iv) and `prop:recovery:frozen`(b) sum over distinct inputs and read correctly; the bounded-length step uses (a), which the lemma's parenthesis covers in either indexing. One clarifying clause added in the "(iv), MAPs" step of `app:split:private` ("with frozen labels along the distinct inputs; $\Lambda$ is constant at a repeated query"), because that step applies (b), stated in the distinct-input indexing, to $\Lambda_n$ indexed by queries. No mathematical change. |
| RW3-03 | `rem:split:reading`: first three sentences replaced by the exact D3 text ("no $\lambda$-MAP is a fill-in once $L_n(\nu)>\lambda(k+\delta^*)/(\lambda-1)$ …"; "selects programs that are $\nu$-equivalent on the run"). Checked: from `thm:split:private`(i),(iii) a fill-in MAP needs $L_n(\nu)-\delta^*\le(\lambda k+\delta^*)/(\lambda-1)$, i.e. $L_n(\nu)\le\lambda(k+\delta^*)/(\lambda-1)$. Last two sentences unchanged. |
| RW3-04 | D4: (1) `recovery.tex` paragraph after the proof idea of `cor:recovery:noisy` replaced by the exact text ($(7/8)^{64}$ for every λ in an explicit class; `prop:recovery:frozen`(a) for every procedure); (2) `app-recovery.tex`: the exact computed-values sentence added directly after `rem:recovery:frozentable` (0.255, 0.255, 0.204, 0.566; second class "with another rate code and single-input exception programs" 0.136, 0.136, 0.085, 0.566; checked against verify-iid §1.10 / v6: 0.25542, 0.25542, 0.20399, 0.56641 and 0.13623, 0.13623, 0.08481, 0.56641); (3) inside the remark, "In the class of \cref{sec:recovery:noisy}" → "In an explicit class". |
| RW3-05 | Length. (1) `rem:recovery:window` moved from §6.4 to the start of `app:recovery:kink` (App D.4), label/status/src unchanged; inside it "(iii)" → "\cref{thm:recovery:kink}(iii)", "the limit (v)" → "the limit in \cref{thm:recovery:kink}(v)", and the D11(h) symbols; the proofs that follow now open with "Proof of \cref{thm:recovery:kink}(i)". §6.4 keeps the exact pointer sentence after the reading paragraph. (2) Paragraph after `thm:split:lambda1` replaced by the exact one-sentence text (Eisenstat credit, "personal communication; \citealp[Section~7.3]{…}"), `% P1: sec:ex:eisenstat` comment kept; the $i_n\le\lceil\log(18|\dom D_n|)\rceil$ bound moved to a lead paragraph of `app:split:si`; the SI weight bound is `prop:split:si`(ii) in that subsection, so the lead paragraph points to it ("In SI the analogous bounds hold, …") instead of repeating it. `sec:split:lambda1` unchanged (acknowledgements resolve). (3) `rem:recovery:posterior`: 3 lines in the build (8/9 and 4/5 kept; the explicit fraction $2^{-5\lambda}/(\dots)$ and the clause "where every program has longer equivalents" dropped). (4) Paragraph after the proof idea of `prop:recovery:frozen`: 4 lines; the sentence "With frozen labels on a finite support the data are eventually one table …" dropped (it now duplicates the D4 paragraph of §6.5); the decimal $1-(63/64)^{10}=0.1457$ moved to the end of the proof idea of (c). Further prose trims for the §6 target, no content or mathematics changed: the Ville proof idea ("Ville's inequality"), the parity-classes paragraph ("$d$ large"; "the least $n$ with …"), the pointer "(\cref{prop:recovery:necessity})" without the appendix name, the kink reading ("the hull vertex at length $\ell_0$"), the sentence "That is all frozen labels allow." (its content is the last sentence of `rem:split:reading`), the proof of `thm:split:lambda1` (its second equality is statement (ii) itself), the proof idea of `thm:recovery:main` ("(b) is similar"), the caption of `tab:recovery:times`, the proof idea of `cor:recovery:noisy`, and "for every $\lambda\ge1$" in the proof idea of `thm:split:private` ((iv) states it). |
| RW3-06 | `rem:recovery:method` body replaced by the exact D11(e) sentence (cites `rem:related:posteriors`; Barron–Cover now only in `related.tex`, where it is present, l.12). Label, status, src unchanged. |
| RW3-07 | §6.3: the "$s=1/\lambda$ turns the prior factor into $2^{-\ell(\pi)}$" sentence replaced by the exact D11(a) text; the next sentence ($\lambda=1$, $Z(s)$) unchanged. |
| RW3-08 | `prop:recovery:lambda1`(a) replaced by the exact D11(b) text ("every $1$-MAP at $n$ is a parity"; "for $\varepsilon<31/32$"). Proof in App D.3 ends "…$<k+n$, so every $1$-MAP is a parity." |
| RW3-09 | Renaming (D11(h)) in §6.3 (paragraph "Two parity classes", `prop:recovery:lambda1`, caption of `tab:recovery:times`), `rem:recovery:window`, `prop:recovery:necessity`(c), App D.3 and the window proof in D.4: input dimension $D\to d$; parity length $m\to r$ ($m^*,m_1\to r^*,r_1$, $A_m\to A_r$, $\ell(m)\to\ell(r)$); parity vector $w\to\theta$; class bound $M\to r_0$ ($\mathcal C_{k,M}\to\mathcal C_{k,r_0}$). In `prop:recovery:necessity`(d) the class is $\mathcal C_{k,n}$ ($r_0=n$) and its matrix is written $A_n$. Also in D.3: $\ell(r):=r+2\lceil\log(r+1)\rceil+1$ is now defined where it is first used; the total prior weight of the parities in the proof of (c) is no longer called $w$ (the kink window); the local mean $m$ in the proof of `prop:recovery:necessity`(b) is written $\Ex X_1$ ($m$ is the error-rule length). The dummy argument of $h(m)$ in the proof of (e) is unchanged (a bound variable). Grep of §6.3 and App D.3–D.4 afterwards: no input-dimension $D$, no class bound $M$, no parity-length $m$, no parity-vector $w$ left. $D$ (data set), $\Wdet(D)$, $\Mprod$ and $\mathcal M=\mathcal C$ (§6.4) untouched. |
| RW3-10 | `prop:recovery:frozen`(a): "Here $\mathcal E_\nu$ is the set of programs whose kernel equals $\nu$ at $\mu$-almost every input." inserted after "…under $\nu'$." |
| RW3-11 | `q:recovery:open`(e): second question deleted; title "rates, frozen labels, misspecification". `\src` updated: "Conj 7.4" replaced by "\S7.4 (open for countable classes)" and "(item 6: its first question only)", because Conj 7.4 is the deleted memorisation-region question, while the first question of (e) is the countable-class case that iid §7.4 lists as open. `discussion.tex` l.37 ("misspecification in countable classes") still matches. |
| RW3-12 | `app:recovery:main` title: `\subsection{Proof of \texorpdfstring{\cref{thm:recovery:main}}{Theorem \ref*{thm:recovery:main}}}`. No "Theorem A–D" remains in W3's files. |

**Moved between main text and appendix in this round:** `rem:recovery:window` (§6.4 → App D.4); the computed frozen-table failure probabilities (§6.5 → after `rem:recovery:frozentable`, App D.5); the $i_n$ bound after `thm:split:lambda1` (§6.7 → `app:split:si`); the SI weight bound sentence (§6.7; now only `prop:split:si`(ii) in `app:split:si`).

**Builds.** `./test-section.sh recovery app-recovery`: OK, 12 pages, 0 undefined citations, 17 undefined references (other groups' labels and my `app-split.tex` labels). `./test-section.sh split app-split`: OK, 3 pages, 0 undefined citations, 11 undefined references (my `recovery.tex`/`app-recovery.tex` labels and W1's). 0 overfull boxes in both. A combined scratch build of `recovery` + `app-recovery` + `app-split` (in my scratchpad): 0 multiply defined labels, 0 overfull boxes; its only undefined references are other groups' labels (`cor:kink:locate`, `def:kink:kinks`, `def:setup:class`, `def:setup:data`, `def:setup:shared`, `lem:setup:basic`, `lem:setup:hull`, `rem:related:posteriors`, `sec:kinks`, `sec:teacher`). The DECISIONS §A5 grep on the text of both isolated builds hits only formula renderings ($\mathcal E_0$, $r_0$, $r_1$, $\mathsf C_{1/2}$).

**Pages** (combined scratch build, measured from text positions at the start and end of each file):

| file | before this round | after |
|---|---|---|
| `recovery.tex` (§6) | 5.93 | **5.39** |
| `app-recovery.tex` | 5.90 | 6.33 |
| `app-split.tex` | 2.49 | 2.61 |
| App D | 8.39 | **8.93** |

On the 2026-10-13 full build the same method reads 0.12 pp more for §6 and 0.09 pp more for App D than the lead editor's measurement (5.80 and 8.27; heading positions in `main.pdf` give 5.81 and 8.30). On the lead editor's scale this round therefore gives about **5.27** for §6 (target 5.1 ± 0.15) and about **8.84** for App D (target 8.7 ± 0.15). FRONT's full build decides; page breaks under `\raggedbottom` move these by a few lines.

**Notes for FRONT.**
* `check_companion_numbers.py` matches only `\citet`/`\citep`, so the mandated `\citealp[Section~7.3]{claudeSFI2026fundamentals}` now shows as "intended not used: Section~7.3". Checked by hand: `paper/main.aux` has `sec:ex:eisenstat` = 7.3. The script still ends ALL OK. ("used not in intended: Theorem~5.1" is in `absorb.tex`, W1.)
* `intro.tex` l.16 still has "identifies $\nu$ on the queried inputs" and "average Hellinger distance" (FRONT's D1, D8).
* The symbols $r$, $r_0$, θ now name the parity classes of §6.3; if the introduction or discussion mentions $\mathcal C_{k,M}$ or the input dimension $D$, they should follow (a grep of the working sections finds no such use outside W3's files).
