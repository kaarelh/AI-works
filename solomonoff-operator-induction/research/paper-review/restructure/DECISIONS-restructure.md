# Paper 2 restructure: lead editor's decisions after the three reviews (binding; 2026-10-13)

Paper 2 is `paper-steeper/`. Inputs: `review-math1.md`, `review-math2.md`, `review-front.md`; `PLAN.md`; the seven logs; the sources as built on 2026-10-13 (75 pages); the records and verification reports of `research/tracks/split/`; `DECISIONS.md`; `REFRAME.md`.

Outputs of this pass: this file; the fix lists `fix-W1.json` … `fix-W6.json`, `fix-FRONT.json`; `rejected.json`.

The lead editor's recomputations are in `restructure/scratch/`, as scripts with saved outputs:
* `lead_teacher_numbers.py`, run with the path of `split/teacher/checks/t6_exact_window.py` as its argument;
* `lead_memoriser_numbers.py`;
* `lead_envelope_numbers.py`, which re-implements the formulas of `steeper/checks/c7_run2.py` (B).

The values they give are quoted below.

**Order of authority for this fix round.**
* For framing, voice, attribution and the arXiv form: `REFRAME.md`, then `DECISIONS.md` §A, §B, §E, §G.
* For the content of this round: this file. Where this file gives exact text, use it verbatim. Only LaTeX layout may change, and only where a line would otherwise overflow. Where this file and a reviewer's proposed fix disagree, this file wins.
* For mathematics: the records, as in PLAN.md.
* For page limits: §3 of this file. It supersedes `DECISIONS.md` §C and `PLAN.md` §6 for Paper 2.
* `PLAN.md` §2 (ownership), §3 (labels), §4 (notation) and §7 (rules for writers) remain binding.

---

## 0. Summary of the verification

* **Fatal findings: none** in any review. I agree, after checking:
  * the claims of the abstract, the informal theorems and the contributions against the body;
  * every major finding below against the sources and the records.
* **Major findings.** The reviews report 12: math1 M1–M5, math2 M2-1 to M2-3, front M1–M4. Two of them (math1 M5 and front M1) are the same length issue, so there are **11 distinct major issues**.
  * **All 11 are confirmed** as real defects.
  * Three are accepted with a modified fix:
    * the length (§3): the caps are relaxed and specific moves are ordered, instead of either reviewer's list;
    * the integer truncation level (D6): restricted only where (D2) is used;
    * the abstract (D9): the lead editor's own text, because the reviewer's proposed abstract keeps "samples have such a kink", contrary to its own m6, and omits "dyadic".
* **Minor findings.** The reviews report 49 minor items, counting sub-items: math1 12, math2 16, front 21 (m17 has five parts).
  * Accepted: 47, several with modified wording.
  * Partly accepted: 1. Front m4: the numbers stay in Theorem C per §F29, and the rounding and the forward reference are fixed.
  * Not adopted: 1. Front m17, "λ = 1 included" in the abstract.
  * `rejected.json` records these two, the parts of the length proposals that are not adopted, and the three fixes adopted with modified text (15 entries).
* **One reviewer argument is corrected, not its conclusion.**
  * Front m11 argues that, with frozen labels, "the selected model is a sampler, not a fill-in, at every n". That sentence is the false claim of math1 M3.
  * The conclusion of m11 still holds, for the correct reason: frozen labels defeat exact recovery, not the split, because no λ-MAP is a fill-in once $L_n(\nu)>\lambda(k+\delta^*)/(\lambda-1)$.
* **Independent recomputations by the lead editor.**
  * The running example at $c=10^{-4}$:
    * $u\ge0.98309$, $e\le0.19911$, $\ell\le d+20.434$, $I\le37.722$ at κ = 0, δ_S = 0;
    * the other three rows are in D10;
    * $c_{\rm hi}=8.0617951\cdot10^{-3}$ (κ = 0) and $3.6589743\cdot10^{-3}$ (κ = 30).
  * The memoriser-regime lower bounds of App F.2: 0.95463, 0.83051, 0.65846, 0.48317, 0.22286 (κ = 0) and 0.91664, 0.70598, 0.45686, 0.25572, 0.05994 (κ = 30).
  * The envelope numbers:
    * j = 13: $e_1\ge0.54494$, window shares 0.31466 (κ = 0) and 0.24932 (κ = 30);
    * j = 11: 0.86213, 0.47479 and 0.42293.
  * Two arguments checked by hand:
    * the counterexample of math1 M2 (one input repeated forever);
    * the gap and the one-line repair of math2 m12.

---

## 1. Verdicts on the fatal and major findings

| finding | verdict | evidence (checked by the lead editor) |
|---|---|---|
| math1 M1 (and front m3) | **confirmed, major** | `thm:split:private`(iv) gives $\nu$-equivalence on the run, $\sum_i\Hel<\infty$ (iid Prop 3.3; V-I §1.1). "Identifies $\nu$ on the queried inputs" reads as equality there. `prop:recovery:beyond`(a) is a program that differs from ν at every query and is still equivalent on the run. Fix: D1. |
| math1 M2 | **confirmed, major** | `def:split:setting` indexes the data by queries, and FR allows repeats. With frozen labels and a repeated query, $\Lambda_{n+1}=\Lambda_n$, so the equality in `lem:recovery:ratios`(a) fails there. (b) fails outright: let the rule query one $x_0$ forever and let π have gap ½ there. Then $\sum g_i=\infty$, while Λ is constant and positive. The iid record (Prop 3.3, line 283) indexes the frozen case by distinct inputs, and every downstream use is correct in that reading. Fix: D2. |
| math1 M3 | **confirmed, major** | `rem:split:reading` says "at every $n$ the selected model is a sampler, not a fill-in". `thm:split:private`(i),(iii) exclude fill-ins only once $L_n(\nu)-\delta^*>(\lambda k+\delta^*)/(\lambda-1)$, that is $L_n(\nu)>\lambda(k+\delta^*)/(\lambda-1)$. Fix: D3. |
| math1 M4 | **confirmed, major** | `recovery.tex` l.118 says that the λ-MAP is wrong with positive probability whatever λ, for every class. The records prove this only in one explicit class (iid Cor 6.1(vi); V-I §1.10), plus the impossibility for every procedure in `prop:recovery:frozen`(a). In a one-program class the MAP is always right. Fix: D4. |
| math1 M5 = front M1 | **confirmed, major** (accepted, modified) | Measured: main text 37.4 pp, appendices 35.2, total 75, against the caps 27/27/57. The plan's budgets cannot hold the content that the author's restructure added. Decision: §3 (new caps, ordered moves and trims). |
| math2 M2-1 | **confirmed, major** | `\begin{enumerate}[label=(\roman*),start=0]` prints "()" for item (o), as on PDF p. 28 ("() Level bounds."). The text cites "(o)" in five places. Fix: D5. |
| math2 M2-2 | **confirmed, major** (accepted, modified) | `lem:teacher:coding` is stated "for integer or infinite B", and its proof codes $B$ in $2\log B$ bits. (D2) and everything built on it (`prop:teacher:kinks`(b), `thm:teacher:main`, `cor:teacher:sampled`, `prop:teacher:sharp`(iii)) is stated for real $B\in[\log(1/p),\infty]$. The teacher record flags this ("A m19 … a point for the paper"). Every number uses $B=\infty$ or $B=30$. The sharp floor, the risk floor and (D1) do not use the coding lemma, so they keep real $B$. Fix: D6. |
| math2 M2-3 | **confirmed, major** | `rem:algstat:reading` says "useless over set models in this example". `prop:parity:sets` and `prop:algstat:parity` give only $1+O((\log d+\delta_E)/d)$, and §7.4 itself says that nothing is claimed for λ − 1 of that order. In the kink record (§4, "Set hull: the code for $v$ decides") the parity-knowing set is a set-hull vertex up to λ = 1.36 at $d=30$ with an Elias code. The record marks the code-independent reading as refuted. Fix: D7. |
| front M2 | **confirmed, major** | `\Hel` is $d_{\rm H}^2$, the squared Hellinger distance (preamble l.70), and the margin bounds ${\Hel}_\mu$ from below. Theorem A (informal) says "average Hellinger distance", and its rate is then off by a square. Fix: D8. |
| front M3 | **confirmed, major** (accepted, modified) | In the abstract, "it absorbs all structure" has the penalty as its only antecedent. Fix: D9 (new abstract, 1920 characters). |
| front M4 | **confirmed, major** | The headline numbers are rounded the unsafe way. The computed bound is $e\le0.19911$, printed as "at most 0.199". The upper end at κ = 30 is $c_{\rm hi}=3.65897\cdot10^{-3}$, printed as the closed end "3.66·10⁻³". The same holds in `tab:teacher:numbers` and `rem:teacher:numbers`. Fix: D10. |

---

## 2. Decisions with exact new text

Line numbers refer to the sources of the 2026-10-13 build. Each change is located by its label and the quoted old text.

### D1. Equivalence on the run, not identification on the queried inputs (math1 M1; front m3)

* **`recovery.tex` l.12 (W3).**
  * Old: "With frozen labels no procedure recovers every sampler, and every $\lambda\ge1$ identifies it on the queried inputs (\cref{thm:split:private,prop:recovery:frozen})."
  * New: "With frozen labels no procedure recovers every sampler, and every $\lambda\ge1$ eventually selects programs that are $\nu$-equivalent on the run: their Hellinger gaps to $\nu$ along the queried inputs are summable (\cref{thm:split:private,prop:recovery:frozen})."
* **`intro.tex` l.16, the last sentence of Theorem A (FRONT).**
  * Old: "With frozen labels no procedure recovers every computable sampler, and every $\lambda\ge1$ identifies $\nu$ on the queried inputs."
  * New: "With frozen labels no procedure recovers every computable sampler, and every $\lambda\ge1$ eventually selects programs equivalent to $\nu$ on the run, with summable Hellinger gaps to $\nu$ along the queried inputs."
* **`intro.tex` l.41, `tab:intro:claims` row "Does a steeper prior separate a sampler from its fill-ins?" (FRONT).** New answer: "Yes per query, exactly, and for fixed $\lambda>1$ at rates that depend on the class only through a margin. With frozen labels no procedure recovers every sampler; every $\lambda\ge1$ eventually selects programs equivalent to it on the run (summable Hellinger gaps along the queried inputs)".
* **`rem:split:reading`:** see D3.

### D2. Frozen labels are indexed by distinct inputs (math1 M2; W3)

* **`def:split:setting`**, at the end of the paragraph "*Any input rule:* …", after "…in $\Hcl{\times}$ such a $\nu$ is a computable conditional measure.", insert:
  > With frozen labels a repeated query changes no data; where a process is needed, it is indexed by distinct inputs in order of first appearance, and frozen labels with i.i.d.\ inputs are an input rule of this kind.
* **`lem:recovery:ratios`** (`app-recovery.tex` l.13).
  * Replace the first sentence of the statement by:
    > Let the inputs be chosen by any rule of \cref{def:split:setting}, indexed by queries for per-query labels and by distinct inputs, in order of first appearance, for frozen labels; let $o_i$ and $\Lambda_i(\pi)$ be the data and the likelihood ratio at the $i$-th step of this indexing, and put $g_i(\pi):=\Hel(\nu(\cdot\mid x_i),\nu_\pi(\cdot\mid x_i))$ for its $i$-th input, which is fixed before $y_i$ is drawn. (Indexed by queries, $\Lambda$ is constant at a repeated query with frozen labels, so the supermartingale statements of (a) hold in either indexing.)
  * The rest of the statement and the proof are unchanged.
* **The proof of `lem:split:ville`** (`app-split.tex` l.7).
  * Old: "Given the past and the next input $x_{n+1}$, which the rule fixes before $y_{n+1}$ is drawn, $\Ex[Z_{n+1}]\le"
  * New: "With frozen labels and a repeated query, $Z_{n+1}=Z_n$. Otherwise, given the past and the next input $x_{n+1}$, which the rule fixes before $y_{n+1}$ is drawn, $\Ex[Z_{n+1}]\le"
  * Everything after it is unchanged.

### D3. `rem:split:reading` (math1 M3; W3)

Replace the first three sentences, from "With frozen labels and fixed $\lambda>1$, at every $n$ …" to "… within the factors of \cref{thm:split:lambda1}.", by:

> With frozen labels and fixed $\lambda>1$, no $\lambda$-MAP is a fill-in once $L_n(\nu)>\lambda(k+\delta^*)/(\lambda-1)$, and the fill-ins' posterior is exponentially small in the sampled randomness, but positive (\cref{thm:split:private}). The selected program need not be $\nu$: it may carry up to $(k+\delta^*)/(\lambda-1)$ bits beyond it, such as noise memorised at a few inputs. In the limit every $\lambda\ge1$ selects programs that are $\nu$-equivalent on the run, although at $\lambda=1$ the posterior odds stay within the factors of \cref{thm:split:lambda1}.

The last two sentences ("Equivalence on the run says nothing … (\cref{thm:recovery:main,prop:recovery:frozen}).") are unchanged.

### D4. Frozen labels on a finite support (math1 M4, m10; W3)

* **`recovery.tex` l.118.** Replace the paragraph after the proof idea of `cor:recovery:noisy` by:
  > The rate, a real number, is identified exactly, and the flips stay out of the model. With frozen labels on a finite support the data set is eventually the full table, so the selection depends on one table: no procedure identifies every such sampler (\cref{prop:recovery:frozen}(a)), and in an explicit class of parities with eight noise rates the $\lambda$-MAP is then wrong with probability at least $(7/8)^{64}$ for every $\lambda$, while per query (i) applies (\cref{rem:recovery:frozentable} in \cref{app:recovery:noisy}).
* **`app-recovery.tex`**, directly after `rem:recovery:frozentable`, add the computed values, which leave the main text (length, §3):
  > A direct computation (code in the accompanying repository) gives the exact failure probabilities $0.255$, $0.255$, $0.204$ and $0.566$ in this class at $\lambda=1$, $1.5$, $2$ and $4$, and $0.136$, $0.136$, $0.085$ and $0.566$ in a second class, with another rate code and single-input exception programs; per query \cref{cor:recovery:noisy}(i) applies to both classes.
* Inside `rem:recovery:frozentable`, "In the class of \cref{sec:recovery:noisy}" becomes "In an explicit class". The parenthesis that describes the class follows, unchanged.

### D5. Item (o) of `thm:teacher:main` (math2 M2-1; W5)

* In `teacher.tex` l.75, replace `\begin{enumerate}[label=(\roman*),start=0,itemsep=1pt,topsep=2pt]` by `\begin{enumerate}[label=(\roman*),start=1,itemsep=1pt,topsep=2pt]`.
* Write the first item as `\item[(o)] \emph{Level bounds.} …`. With enumitem the optional label does not step the counter, so the following items stay (i)–(iv).
* Check in the PDF that the item reads "(o) Level bounds.", and that the five citations "(o)" (the proof idea of `prop:limits:envelope`, `prop:related:computable`(a), App F.2 three times) still match.

### D6. The truncation level where (D2) is used (math2 M2-2; W4, W5)

* **`lem:teacher:twopart` (W4).** Replace "If $\lev(\pi)=t<\infty$, then" by "Let $\lev(\pi)=t<\infty$. Then", and replace "and \( \text{(D2)} …\)" by "and, if $B$ is an integer or $\infty$, \( \text{(D2)} …\)". (D1) stays for every $B$.
* **`def:teacher:instance`(c) (W4).** Append, after "$2^{-\infty}:=0$.":
  > Results that use (D2) of \cref{lem:teacher:twopart} take $B$ to be $\infty$ or an integer.
* **`prop:teacher:kinks` (W5).** Replace "Take the reference point $(d+\kappa_g,H(p))$, bounded by $\pi_g$, the fits $R\ge R_B$," by "Let $B=\infty$ or let $B\ge\log(1/p)$ be an integer. Take the reference point $(d+\kappa_g,H(p))$, bounded by $\pi_g$, the fits $R\ge R_B$,".
* **`thm:teacher:main` (W5).** Replace "with $B\in[\log(1/p),\infty]$," by "with $B=\infty$ or an integer $B\ge\log(1/p)$,".
* **The samples paragraph before `cor:teacher:sampled`** (`teacher.tex` l.141; W5). Replace "let $B<\infty$," by "let $B\ge\log(1/p)$ be an integer,".
* **Unchanged:**
  * `lem:teacher:sharpfloor` and `lem:teacher:floor`: their proofs do not code $B$;
  * `prop:limits:plain`(b) and `lem:teacher:finite`: they use no (D2);
  * `prop:teacher:schedules`(c): it already says "integer".

### D7. `rem:algstat:reading` (math2 M2-3; W4)

Replace the last sentence by:

> This is why steeper simplicity is useless over set models in this example once $\lambda-1\gg(\log d+\delta_E)/d$ (\cref{prop:parity:sets,prop:algstat:parity}; closer to $1$ the code's $O(\log d)$ terms decide), and decisive over product models (\cref{cor:kink:split,prop:parity:range}).

### D8. The margin in Theorem A (informal) (front M2; FRONT)

* Old (`intro.tex` l.16): "and $\gamma$ a margin, a lower bound on the average Hellinger distance to $\nu$ of the inequivalent programs up to a length fixed by $\lambda$, $\ell_0$ and $\varepsilon$"
* New: "and $\gamma$ a margin, a lower bound on the average squared Hellinger distance to $\nu$ (the Hellinger gap of \cref{def:split:setting}) of the inequivalent programs up to a length fixed by $\lambda$, $\ell_0$ and $\varepsilon$"

### D9. The abstract (front M3, m1, m2, m5, m6, m17 first part; FRONT)

Replace the body of `abstract.tex`. The text below is 1920 characters, measured as before: the stripped source between the environment lines.

```latex
Solomonoff function induction (SFI) predicts labels from inputs with a universal prior on random functions. We study a complexity penalty steeper than log-likelihood by a factor $\lambda>1$, for private-randomness hypotheses, and give two reasons for it. In each class containing its own universal mixture, such as Solomonoff induction and SFI with shared randomness, that mixture, taken as one hypothesis, absorbs all structure; no private-randomness hypothesis is universal. The first and main reason is the split into model and noise. With i.i.d.\ inputs and a computable sampler with fresh coins per query, for every $1\le\lambda_n=o(n)$ every $\lambda_n$-MAP is eventually a shortest program for the sampler; for fixed $\lambda>1$, with probability $1-\varepsilon$ at each $n$ beyond a bound depending only on $\lambda$, the program's length, a margin and $\varepsilon$. At $\lambda=1$ no such bound exists, and in a parity class recovery is exponentially slower in that length. On one data set, a kink of the product structure function at a sufficient program makes every $\lambda$ between $1$ and its steepness select it up to windows; per-query samples have one, and so, for large $d$, does the full table of a noisy random parity at each dyadic flip rate below $1/4$, but set models have no steep one. The second reason, the same geometry at a positive rate, is not learning a teacher's errors: an error rule is reused at many inputs, so $\lambda$ must grow linearly in the sample size. For a random parity on uniform inputs, with labels flipped at a rate below $0.05596$ on an error set of product form incompressible relative to the parity, every near-optimal hypothesis of the population objective with $\lambda/n$ in an explicit window knows the parity and, for large error rules, gives the erroneous labels far less probability than a memoriser; asymptotically, windows exist for flip rates below $0.1233$.
```

Each claim of this text traces to the body:
* `thm:absorb:absorption`, `cor:absorb:nouniversal`;
* `thm:recovery:main`(a),(d); `prop:recovery:lambda1`(a),(b);
* `cor:kink:split`(b); `thm:recovery:kink`(ii);
* `prop:parity:range`(iii) (dyadic $p$; a noisy random parity has $\delta_E=O(d)$ with high probability); `prop:parity:sets`;
* `prop:teacher:schedules`(a); `thm:teacher:main`; `prop:teacher:rates`.

Update the comment lines at the top of `abstract.tex`.

### D10. Safe rounding of the teacher numbers (front M4, m4 in part; math2 m1)

Lower bounds are rounded down and upper bounds up (DECISIONS §A9; PLAN §7.1(4)). The values below are from the lead editor's recomputation.
* **`tab:teacher:numbers` (W5).** Replace the four rows by:
  ```
  0 & 0 & 0.983 & $d+20.5$ & 37.8 & 37.8 & 0.200\\
  0 & 20 & 0.983 & $d+20.7$ & 38.0 & 58.0 & 0.218\\
  30 & 0 & 0.981 & $d+51.1$ & 98.3 & 98.3 & 0.274\\
  30 & 20 & 0.981 & $d+51.3$ & 98.5 & 118.5 & 0.287\\
  ```
  * These come from $(u,\ell-d,I,L_S-K,e)$ = (0.98309, 20.434, 37.722, 37.722, 0.19911); (0.98309, 20.627, 37.914, 57.914, 0.21773); (0.98105, 51.012, 98.299, 98.299, 0.27351); (0.98105, 51.204, 98.492, 118.492, 0.28687).
  * In the caption, replace "Numbers are rounded to the nearest unit in the last digit." by "Lower bounds are rounded down and upper bounds up."
* **`rem:teacher:numbers` (W5).**
  * "with $R_{\max}$ the first row has $u\ge0.988$ and $e\le0.194$" → "… $u\ge0.988$ and $e\le0.195$" (the value is 0.19405).
  * "$(9.54\cdot10^{-7},\,3.66\cdot10^{-3}]$ at $\kappa=30$" → "$(9.54\cdot10^{-7},\,3.65\cdot10^{-3}]$ at $\kappa=30$".
  * "In a band of relative width about $6\%$ below $2^{-m}$" → "In a band of relative width about $6\%$ ($\kappa=0$; about $11\%$ at $\kappa=30$) below $2^{-m}$" (from $0.937\cdot2^{-m}$ and $0.888\cdot2^{-m}$ in App F.2; math2 m14).
* **`intro.tex` l.20 and l.22 (FRONT).**
  * In Theorem C, "average probability at most $0.199$ $(\kappa=0)$ or $0.274$ $(\kappa=30)$ at $c=10^{-4}$ and the example's sizes" → "average probability at most $0.200$ $(\kappa=0)$ or $0.274$ $(\kappa=30)$ at $c=10^{-4}$ and the sizes given below".
  * In the next paragraph, "$(9.54\cdot10^{-7},3.66\cdot10^{-3}]$ at $\kappa=30$" → "$(9.54\cdot10^{-7},3.65\cdot10^{-3}]$ at $\kappa=30$".
  * The numbers stay in the informal theorem, as DECISIONS §F29 requires (`rejected.json`, REJ-09).
* **App F.2 "Numbers"** (`app-teacher.tex` l.83; W5).
  * "it gives $e\ge0.955$, $0.831$, $0.658$, $0.483$, $0.223$ … and $e\ge0.917$, $0.706$, $0.457$, $0.256$, $0.060$" → "it gives $e\ge0.954$, $0.830$, $0.658$, $0.483$, $0.222$ … and $e\ge0.916$, $0.705$, $0.456$, $0.255$, $0.059$".
* **The envelope** (W6).
  * `limits.tex` l.33: "at least $0.545$" → "at least $0.544$"; "($25\%$ at $\kappa=30$)" → "($24\%$ at $\kappa=30$)".
  * `app-limits.tex` l.32: "($0.42$ and $0.25$ at $\kappa=30$)" → "($0.42$ and $0.24$ at $\kappa=30$)"; "is $0.862$ and $0.545$ for $\delta_2=0$" → "is $0.862$ and $0.544$ for $\delta_2=0$".
  * The other envelope numbers were checked and are already rounded safely: 0.47, 0.31, 0.42; 0.862, 0.839, 0.489, 0.042; $6.98$, $3.12$, $1.64$, $0.746\cdot10^{-5}$.
* **Unchanged:**
  * "about a third ($\kappa=0$) to a quarter ($\kappa=30$)" in `tab:intro:claims` and in the discussion (approximate wording);
  * `tab:teacher:rates` (already rounded safely: $u\ge0.989$ against 0.98974, $e\le0.193$ against 0.19247).

### D11. Further statement and sentence changes (exact text)

| # | file (group) | where | new text |
|---|---|---|---|
| a | `recovery.tex` (W3) | l.69, the sentence "In \cref{thm:recovery:main}(d), for $\lambda>1$, the exponent $s=1/\lambda$ … charged by the prior." (math1 m2) | "In \cref{thm:recovery:main}(d), for $\lambda>1$, the steeper prior charges every program longer than $\bar\ell_\varepsilon$ by $2^{-\lambda(\ell(\pi)-\ell_0)}$, at most $\varepsilon/2$ in total in every class, and $s=1/\lambda$ turns the prior factor of the shorter programs into $2^{\ell_0-\ell(\pi)}$, which is Kraft-summable; so the margin matters only up to length $\bar\ell_\varepsilon$." The next sentence ("At $\lambda=1$ one exponent $s<1$ …") stays. |
| b | `recovery.tex` (W3) | `prop:recovery:lambda1`(a) (math1 m7) | "(a) Let $k\ge8$, $r_0\ge6$ and $n:=r_0-5$. In $\mathcal C_{k,r_0}$, with probability at least $31/32$ every $1$-MAP at $n$ is a parity. So for $\varepsilon<31/32$ no function of $(\ell_0,\gamma,\varepsilon)$ bounds the recovery time at $\lambda=1$, even with a uniform margin." (The symbols follow D11(h).) |
| c | `recovery.tex` (W3) | `prop:recovery:frozen`(a), after "…is almost surely not eventually in $\mathcal E_{\nu'}$ under $\nu'$." (math1 m8) | insert "Here $\mathcal E_\nu$ is the set of programs whose kernel equals $\nu$ at $\mu$-almost every input." |
| d | `recovery.tex` (W3) | `q:recovery:open`(e) (math1 m9; front m17) | Delete the second question, "With fixed $\lambda>1$, in classes that can memorise … local entropy?" Item (e) keeps its first question. Title: "rates, frozen labels, misspecification" (lower case, as the other questions). |
| e | `recovery.tex` (W3) | `rem:recovery:method` (math1 m1; front m10; length §3) | Replace the whole remark body by: "Parts (a) and (b) use the standard argument from Ville's inequality and the strong law, and we claim no novelty for them (\cref{rem:related:posteriors}); what needs $\lambda>1$ is (c) and the margin form of (d)." Label, status and source unchanged. |
| f | `app-recovery.tex` (W3) | l.35, subsection title (math1 m11) | `\subsection{Proof of \texorpdfstring{\cref{thm:recovery:main}}{Theorem \ref*{thm:recovery:main}}}` |
| g | `absorb.tex` (W1) | l.49, the first sentence of §4.2 (math1 m3; front m16) | "A \emph{sampler} is a probability kernel $\nu$ (\cref{def:split:setting}); here it has a program $\pi_\nu$ of length $k$ in the class considered, so in the canonical classes it is a computable conditional measure." |
| h | `recovery.tex`, `app-recovery.tex` (W3) | §6.3, `tab:recovery:times`, `prop:recovery:necessity`, `rem:recovery:window`, App D.3–D.4 (math1 m6; front m16) | Rename locally (PLAN §4.2):<br>• input dimension $D\to d$;<br>• parity length $m\to r$, and $m^*,m_1\to r^*,r_1$, $A_m\to A_r$, $\ell(m)\to\ell(r)$;<br>• parity vector $w\to\theta$;<br>• class bound $M\to r_0$ ($\mathcal C_{k,M}\to\mathcal C_{k,r_0}$, "the $2^{r_0}$ parities on the first $r_0$ bits").<br>$r$, $r_0$ and θ are unused in §6 and App D. $d$ keeps its meaning of input length. |
| i | `kinks.tex` (W2) | l.61 (math1 m4) | "…; per-query samples have one with high probability (\cref{thm:recovery:kink}, where the Ville line of \cref{thm:recovery:kink}(iii) replaces the coding bound), and so does the full table of a noisy random parity under the conditions of \cref{prop:parity:kink}." |
| j | `kinks.tex` (W2) | title of `prop:kink:universal` (front m7) | "A universal member flattens every kink far beyond its length" |
| k | `absorb.tex` (W1) | `thm:split:shared`(ii) (math1 m11) | "for every nonempty set $A$ of programs, …" |
| l | `parity.tex` (W4) | `q:parity:open` (math2 m3; front m15) | Replace the body by: "Let $\pi_s=q\theta\in\Hcl{\times}$ be product-$b$-sufficient for a data set $D$, with a $k$-bit parameter $\theta$ such that $K(\theta\mid q)\ge k$, and let $\rho^\times_D$ have a left kink of steepness $\sigma>1$ at the point of $\pi_s$. Is there a function $\epsilon(k)=o(k)$, not depending on $D$, such that there is always a set model $A\ni y_D$ with $K(A\mid\dom D)\le|q|+\epsilon(k)$ and $K(A\mid\dom D)+\log|A|\le K(y_D\mid\dom D)+b+\epsilon(k)$? By the argument of \cref{prop:parity:sets}, such a set caps the steepness of the set models' left kinks beyond $K(A\mid\dom D)$ at $1+(b+\epsilon(k)+2\kappa)/(\alpha_{\rm r}-K(A\mid\dom D))$. For the noisy parity, $A_0$ has complexity $O(\log d)$ and is $(\delta_E+O(\log d))$-sufficient (\cref{sec:algstat:set})." |
| m | `parity.tex`, `app-parity.tex` (W4) | `parity.tex` l.127, `app-parity.tex` l.123 (math2 m6) | `parity.tex`: "for $p\ge1/16$ it starts above $1$" → "for $p\ge1/16$, at the levels $t_0$ of \cref{tab:parity:ranges}, it starts above $1$". `app-parity.tex`: "For $p\ge1/16$ the condition fails near $\lambda=1$" → "For $p\ge1/16$, at the levels $t_0$ of the table, the condition fails near $\lambda=1$". |
| n | `parity.tex` (W4) | l.38 (math2 m14) | "(F5) gives" → "(F5) of \cref{app:setup:facts} gives" |
| o | `teacher.tex` (W5) | `q:teacher:open`(b) (math2 m2; front m14) | "For $0.1233\le p<\frac14$ and $m<d$, …" → "For $p_1\le p<\frac14$ and $m<d$, with $p_1=0.1233072\ldots$ as in \cref{sec:parity:full}, …" |
| p | `teacher.tex` (W5) | title of `prop:teacher:rates` (math2 m5) | "A window for every flip rate below $p_1$, asymptotically" |
| q | `teacher.tex` (W5) | `lem:teacher:reuse`, second sentence (math2 m13) | "With every reference point $(\alpha_{\rm r},L_{\rm r})$ moved to $(\alpha_{\rm r},rL_{\rm r})$, every $\lambda$-threshold of $D$ (the hull's edge slopes and vertex $\lambda$-intervals, left steepness, the slopes of right lines and right secants) is multiplied by $r$, and so are the wedge margins and the offsets of right lines." |
| r | `teacher.tex` (W5) | l.28 (math2 m9) | "for fixed $\lambda>1$ the $\lambda$-MAP stays within $(k+\delta^*)/(\lambda-1)$ bits of the sampler's length $k$ at every $n$" → "for fixed $\lambda>1$ every $\lambda$-MAP is at most $(k+\delta^*)/(\lambda-1)$ bits longer than the sampler's program, at every $n$" |
| s | `teacher.tex`, `app-teacher.tex` (W5) | `prop:teacher:schedules`(c); `prop:limits:plain`(b); `prop:teacher:frozen`(a) (math2 m8) | (c): insert "$\delta\in(0,1)$," before "$\epsilon_1:=…$". `prop:limits:plain`(b): "Let $B<\infty$, $\delta\in(0,1)$, let $\lambda=…$". `prop:teacher:frozen`(a): "…, where $\delta^*$ is the Ville deficiency of $\xi_{\mathcal C}$ along the distinct inputs (\cref{lem:split:ville}), so $\Prob[\delta^*\ge j]\le2^{-j}$." |
| t | `app-teacher.tex` (W5) | the proof of `prop:teacher:sharp`(iii) (math2 m12) | Append to (iii): "On this window $\Lambda_2\ge0$: if $\pi_g$ had level at least $2$, then by (ii) $J_g(c)\ge J_c(\pi_g)\ge J^B_c(\pi_g)\ge\Phi_2^\sharp(c)$, against $J_g(c)+\epsilon<\Phi_2^\sharp(c)$; so $u(\pi_g)=1-p>\frac34$, hence $p<\frac14$, and $\Lambda_2\ge0$ by \cref{prop:teacher:kinks}(b)." |
| u | `app-teacher.tex` (W5) | l.10 and l.76; l.150 (math2 m7) | Rename the threshold $\Gamma_g$ to $T_g$ (it clashes with the floors $\Gamma_t$ of §7.3). Rename the level $t_0$ in the continuity step of the proof of `prop:teacher:sharp` to $t_c$ (it clashes with $t_0$ of §7.3). |
| v | `app-teacher.tex` (W5) | the proof of `prop:limits:plain`(b), l.40 (math2 m11) | Delete "With the machine constant set to $0$, $B=30$ and $\delta=0.01$, a direct computation gives $e\ge0.649$ at $n=10^{13}$ for $\lambda=1$, and $e\ge0.734$ at $n=10^{15}$ for $\lambda_n=\sqrt n$." from the proof. Append to the "For instance" paragraph after the proposition: "With $B=30$ and $\delta=0.01$ (machine constant $0$, an illustration), the same computation gives $e\ge0.649$ at $n=10^{13}$ for $\lambda=1$, and $e\ge0.734$ at $n=10^{15}$ for $\lambda_n=\sqrt n$." |
| w | `app-teacher.tex` (W5) | the caption of `tab:teacher:rates` (math2 m14) | Append: "At $p=2^{-10}$ and $c=10^{-4}$ this is the sharpest of three forms of (ii)(a): \cref{tab:teacher:numbers} uses $J_g(c)+\epsilon$ for $R_{\max}$ ($u\ge0.983$, $e\le0.200$), and \cref{rem:teacher:numbers} uses $R_{\max}$ ($u\ge0.988$, $e\le0.195$)." |
| x | `computable.tex` (W6) | l.18, the proof idea of `prop:related:computable` (math2 m4) | "…with a finite input set, as for circuits on $\{0,1\}^d$, inputs repeat, so the data are per query (\cref{rem:setup:objects})." → "…with a finite input set, as for circuits on $\{0,1\}^d$, inputs repeat, so (d) concerns per-query labels; with frozen labels the data eventually form one table (\cref{rem:recovery:frozentable})." |
| y | `app-related.tex` (W6) | l.60 (math2 m4) | Delete the last sentence, "The scripts of the earlier report reproduce its numbers (\cref{app:teacher:computations})." The supporting sentence in App F was removed (log-W5 D-W5-9). |
| z | `setup.tex`, `app-setup.tex` (W1) | `lem:setup:hull` and its proof (math1 m5) | Write the fit as $L(\pi)$ instead of $F(\pi)$ throughout: data reading $L=L(\cdot;D)$, population reading $L=R$. $F$ is the random function of `def:setup:product` and the frozen table of §6. |

The FRONT texts (front m5–m15, m17) are in `fix-FRONT.json`, with exact wording.

---

## 3. Length (math1 M5; front M1)

**Decision.** The DECISIONS §C caps (main ≤ 27, appendices ≤ 27, total ≤ 57) were set on 2026-10-12, for the paper before the restructure. The restructure adds the first reason as a full thread: Theorems A–D of the synthesis and their proofs. Reaching the old caps would need about 18 pages of cuts, which would remove proved results: `prop:recovery:lambda1`, `thm:recovery:kink`, `prop:teacher:sharp`/`prop:teacher:rates`, the computed tables and the appendix examples. Neither the records nor the author's request supports dropping them. So, for Paper 2 after the restructure:

* **New hard caps:**
  * main text (title page to the end of Code and data) **≤ 33.5 pp**;
  * appendices **≤ 37.5 pp**;
  * total **≤ 73.5 pp**.
* **The main text must still shrink by about 4.3 pp.** This comes from:
  * removing the duplicates that front M1 found;
  * moving secondary statements to their own group's appendix, with a pointer of one or two sentences;
  * trimming prose.
* **No proved result is deleted.** Labels, `\status{}` and `\src{}` go with the moved items. Proofs of moved statements stay next to them in the appendix.
* **If the caps are still exceeded after these actions,** FRONT reports the overrun in its log and lists the next candidates: `rejected.json` REJ-01, REJ-04 and REJ-05 for the main text, REJ-08 for the appendices. No further content is moved or removed without the author's decision.

**Section targets (pp; tolerance ±0.15 per section; the caps above bind).**

| part | now | target | group |
|---|---|---|---|
| title, abstract, contents | 1.51 | 1.5 | FRONT |
| §1 Introduction | 3.38 | 3.2 | FRONT |
| §2 Related work | 0.97 | 0.95 | FRONT |
| §3 Setting | 3.49 | 3.0 | W1 |
| §4 Absorption | 3.40 | 2.9 | W1 |
| §5 Kinks | 2.57 | 2.5 | W2 |
| §6 Exact recovery | 5.80 | 5.1 | W3 |
| §7 Noisy parity | 4.31 | 3.8 | W4 |
| §8 Teacher | 6.12 | 5.3 | W5 |
| §9 Structured errors | 2.43 | 2.1 | W6 |
| §10 Computable classes | 1.12 | 0.8 | W6 |
| §11 Discussion etc. | 2.30 | 2.0 | FRONT |
| **main text** | **37.40** | **33.15** (cap 33.5) | |
| App A | 2.09 | 2.4 | W1 |
| App B | 3.85 | 4.4 | W1 |
| App C | 2.10 | 2.1 | W2 |
| App D (with `app-split.tex`) | 8.27 | 8.7 | W3 |
| App E | 6.46 | 6.3 | W4 |
| App F | 6.38 | 7.0 | W5 |
| App G | 4.05 | 4.0 | W6 |
| App H | 1.99 | 2.2 | W6 |
| **appendices** | **35.19** | **37.1** (cap 37.5) | |

**Required actions.** The details are in the fix lists, entries with category `length`.
* **FRONT.**
  * Discussion: "What counts as one hypothesis" and "The window and its price" become at most three sentences each, without repeating `rem:absorb:wyeth` or `rem:limits:schedule`.
  * Delete the `tab:intro:claims` row "What does $\lambda=1$ do?". `tab:discussion:reasons` carries it.
  * The contribution bullets on kinks and on exact recovery become at most two lines each.
* **W1.**
  * `lem:setup:basic` moves to App A, with one sentence in §3.
  * The generalised-posterior sentence after `def:setup:objects` becomes a pointer to §2.
  * `rem:setup:objects` becomes at most four lines.
  * `prop:absorb:pricing` moves to App B, with a two-sentence summary.
  * The dominance and KL sentence after `thm:split:shared` moves to App B.3.
  * In `rem:absorb:wyeth`, (iii) and (iv) become one clause each.
* **W2.** Trim `rem:kink:reading` and the paragraph after `def:kink:kinks`.
* **W3.**
  * `rem:recovery:method` becomes one sentence (D11(e)).
  * `rem:recovery:window` moves to App D, with one sentence in §6.4.
  * The frozen-table numbers move to App D (D4).
  * The paragraph after `thm:split:lambda1` (Eisenstat's coin, SI) becomes one sentence; its details move to `app:split:si`.
  * `rem:recovery:posterior` becomes at most three lines.
  * The paragraph after `prop:recovery:frozen` becomes at most four lines.
  * `q:recovery:open`(e) loses its second question (D11(d)).
* **W4.**
  * `rem:algstat:restricted` becomes one sentence.
  * `rem:algstat:reading` becomes at most four lines, with D7.
  * The set-sophistication paragraph before `prop:parity:sets` becomes at most four lines.
  * The paragraph on certified covers becomes two sentences.
  * The opening paragraph becomes at most six lines.
  * Proof ideas are tightened.
* **W5.**
  * `prop:teacher:sharp`, with the display of $\mathrm{Floor}_t$, $\Psi_t$, $LB_t$ and $\Phi_2^\sharp$, moves to App F. Its statement, items, label, status and source are unchanged.
  * §8.4 keeps one paragraph that defines $\Phi_2^\sharp$ in words and points to App F; then $\psi_2$, $a^*$, `prop:teacher:rates` and the paragraph after it.
  * `rem:limits:schedule`: the literature sentences give way to a pointer to `rem:related:mdl`; the label and the batch-excess sentence stay.
  * The FQ paragraph (l.28) becomes at most six lines.
  * The samples paragraphs (l.141, l.147) become at most four lines and two sentences.
* **W6.**
  * §9.3 "Unseen properties" moves to App G. Its label `sec:limits:ood` becomes an alias on `app:limits:ood`, and one sentence at the end of §9.2 cites `prop:limits:ood`.
  * `prop:related:computability` moves to App H, with one sentence in §10.
  * `rem:computable:examples` becomes at most three lines.
  * The table of $d_0$ in App G becomes one sentence with its two quoted rows.

---

## 4. Rules for this fix round

1. **Ownership** as in PLAN.md §2. A writer edits only its own files, and nothing moves between groups in this round.
2. **Order.** W1–W6 work in parallel. FRONT works on its own files in parallel, and integrates after the six logs exist.
3. **Labels** are never renamed.
   * A moved statement keeps its label, `\status{}` and `\src{}`.
   * A section label whose text moves becomes an alias on the receiving subsection.
   * No new theorem-like label is needed in this round.
   * New structural labels follow PLAN §3 prefixes.
4. **Mathematics:** only what this file and the fix lists state. Every changed statement uses the exact text above.
5. **Builds.**
   * Isolated builds as in PLAN §2 until they report OK.
   * Measure pages from the isolated build.
   * Full builds only by FRONT: `cd paper-steeper && flock /tmp/claude-0/paper-build-sfi.lock ./build.sh`.
   * No git command that changes repository state.
6. **Logs.** Each group appends a section "Fix round (DECISIONS-restructure)" to its log `log-<group>.md`, with:
   * for each fix id, what was changed or why not;
   * pages per file after the last isolated build;
   * every item moved between main text and appendix.
7. **FRONT's integration checks**, in this order:
   * full build of Paper 2: 0 errors, 0 undefined references or citations, 0 multiply defined labels, no overfull box above 10 pt;
   * page measurement against §3;
   * the greps of DECISIONS §A2.5, §A5 and §B.6, and REFRAME's checks;
   * the companion check `python3 -I research/paper-review/scratch/editor/check_companion_numbers.py`: last line ALL OK, and any Paper 1 citation it does not know checked by hand against `paper/main.aux`. Paper 1 is not edited in this round and need not be rebuilt;
   * a grep of the sources and of the PDF text: none of these may remain:
     * "identifies it on the queried inputs", "identifies $\nu$ on the queried";
     * "average Hellinger distance";
     * "0.199", "3.66", "0.545", "0.955";
     * "useless over set models in this example (";
     * "() Level";
     * in the sources, `0.1233\le p`;
   * "(o) Level bounds" must appear;
   * update `CLAIMS.md` and `OUTLINE.md` (pages, the abstract, the moved items);
   * write the log section.

---

## 5. Counts

| group | entries | fatal | major | minor |
|---|---|---|---|---|
| W1 | 5 | 0 | 2 | 3 |
| W2 | 3 | 0 | 1 | 2 |
| W3 | 12 | 0 | 5 | 7 |
| W4 | 6 | 0 | 3 | 3 |
| W5 | 15 | 0 | 4 | 11 |
| W6 | 4 | 0 | 1 | 3 |
| FRONT | 17 | 0 | 6 | 11 |
| **total** | **62** | **0** | **22** | **40** |

`rejected.json` has 15 entries:
* 12 not adopted, in full or in part:
  * 10 parts of the length proposals (REJ-01 to REJ-08, REJ-10, REJ-11);
  * 2 minor-finding parts (REJ-09, REJ-12);
* 3 fixes adopted with a modified text: REJ-13 (abstract), REJ-14 (truncation level), REJ-15 (caps).

The 22 major fix entries are made up as follows:
* 13 come from the 10 distinct confirmed findings other than the length. Some findings need fixes in two groups' files:
  * W3: RW3-01 to RW3-04;
  * W4: RW4-01, RW4-02;
  * W5: RW5-01 to RW5-03;
  * FRONT: RF-01 to RF-04.
* 8 are the length actions, one per group and two for W1 (category `length`): RW1-01, RW1-02, RW2-01, RW3-05, RW4-03, RW5-04, RW6-01, RF-05.
* 1 is FRONT's integration (RF-06).
