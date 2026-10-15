# Review math1: setting, absorption, kinks and exact recovery (Paper 2 restructure)

Reviewer: math1, 2026-10-13. Scope: `setup.tex`, `app-setup.tex`, `absorb.tex`, `app-absorb.tex`, `kinks.tex`, `app-kinks.tex`, `recovery.tex`, `app-recovery.tex`, `app-split.tex` (and the emptied `split.tex`). No paper file was edited. The only git command run was `git show dcb3a3a3:…`, which is read-only.

## How the review was done

* **Build.** `cd paper-steeper && flock /tmp/claude-0/paper-build-sfi.lock ./build.sh`. Result: 0 LaTeX errors, 0 undefined references, 0 undefined citations, 0 multiply defined labels, 0 overfull boxes above 10 pt, 75 pages. I read the text with `pdftotext -layout` (§3–§6 and Apps A–D) and looked at the rendering of pages 6 and 48.
* **Read.** PLAN.md in full; log-W1, log-W2, log-W3 and log-front; DECISIONS §0, §A, §C; REFRAME. On the record side: verify-iid.md and verify-kink.md in full; verify-teacher.md §1–§4; synthesis §8. From the iid record: Defs 1.1–1.3, Remark 1.4, Lemmas 2.1–2.2, Thms 3.1–3.2, Props 3.3–3.4, Thm 4.1, Remarks 4.5 and 4.7, Props 4.2–4.4, Prop 5.1, Cor 6.1, Props 7.2, 7.3, 7.5, 7.6 and Lemma 8.1. From the kink record: §1–§3 and §5 (Lemmas 5.1–5.3, Thm 5.4, Cor 5.7). From the teacher record: §1 (Lemma 1.1, Remarks 1.2–1.3, Def 1.4, Lemma 1.5). For base material I compared against `git show dcb3a3a3` of `split.tex`, `app-split.tex`, `algstat.tex` and `app-algstat.tex`.
* **Statements and proofs.** I compared every theorem-like statement in scope with its record, checking hypotheses, quantifiers, constants and status. I re-derived every proof in Apps A–D by hand, apart from the unchanged base proofs of `thm:absorb:absorption`(d) and `prop:absorb:history`, which I only read. I followed every in-scope `\cref`.
* **Numbers.** I recomputed them independently, with new code in the scratchpad that shares nothing with the record scripts.
  * `tab:recovery:times`: an exact GF(2) rank chain, scanning every integer $n$ until the nonincreasing bound $2^{m^*-n}$ stays below ε.
    * All 16 cells with λ ∈ {1.1, 1.5, 2, 3} reproduce the table exactly: 78/34/23/20, 144/52/38/29, 232/70/51/38 and 298/94/67/50.
    * At λ = 1 and $k=16$ I get 1030, which equals $2^{(k+4)/2}+6$.
  * Other constants recomputed:
    * $1-(63/64)^{10}=0.14571$;
    * $\prod_i(1-2^{-i})=0.288788>0.2887$;
    * $4(1+2\varepsilon')/((1-2\varepsilon')\ln2)=8.6562$ at $\varepsilon'=0.1$, and $0.96\ln2/8=0.08318$;
    * $1-2^{-1/2}=0.2929$;
    * the per-input pricing value 2.5431 against $\log3+1=2.5850$;
    * $(7/8)^{64}=1.94\cdot10^{-4}$;
    * the stream-lemma costs 5.6, 6.3 (both values of $\beta_D$), 7.2 and 8.9 bits, recomputed from the formula.
  * The values 0.255/0.255/0.204/0.566 and 0.136/0.136/0.085/0.566 are the corrected exact values of verify-iid §1.10.
* **Companion numbers.** `check_companion_numbers.py` (read-only) ends with `ALL OK`. "Theorem 5.1" is used but not in its list; `paper/main.aux` gives `thm:learn:dominance` = 5.1. "Proposition 5.7(a)" and "Corollary 6.17(a)" carry items that exist in Paper 1.
* **Vocabulary.** I grepped the PDF text of §3–§6 and Apps A–D for process vocabulary (track, record, synthesis, referee, verified, corrected, withdrawn, revision, iid, Wyeth, the author, notes, script ids). The only hit is the permitted change-of-slope footnote ("the author's note").

## Verdict

The mathematics in scope is sound.
* Every result printed as proved is proved in the records in the form printed. The corrections of the verification reports are all applied:
  * V-I §1.1: (iv) for λ ≥ 1, hypothesis in the almost-sure form;
  * V-I §1.2: the free exponent for every λ > 0;
  * V-I §1.3: no "iff" for λ = cn;
  * V-I §1.5: an integer $k$ and a real λ;
  * V-I §1.6: only Remark 4.7′;
  * V-I §1.10: the exact values, "eventually", and the corrected penalised-rate sentence;
  * V-K §2.3: δ* with $\nu(h_n)$;
  * V-K §5: "and, if $\ell_U+\kappa_0>0$, only then";
  * V-K §6: the strictness examples;
  * V-T §2–§3: the final form of the kink lemma, $g\ge0$ under (ii), the corrected offset of Def 1.4, and (c) of Lemma 1.5 for $c\ge0$.
* The four statements I re-derived most carefully hold exactly as printed, constants included:
  * the hull lemma (v),(vi);
  * the kink lemma (i)–(v);
  * Theorem A (a)–(d), including the margin form's sample size, re-derived from $s=1/\lambda$, the Hölder bound $\mathsf C_s\le\mathsf C_{1/2}^{2\min(s,1-s)}$ and δ*;
  * the sample kink (i)–(v).
* **No fatal issue.** I found five major issues and eleven minor ones:
  * three framing sentences in `recovery.tex` say more than the records prove;
  * one appendix lemma is false as literally written in the frozen-label case;
  * the page caps are exceeded.

---

## Findings

### Major

**M1. "every λ ≥ 1 identifies it on the queried inputs" overstates what is proved.**
* *Where:* `recovery.tex:12`, the opening paragraph of `sec:recovery`. The same wording is in FRONT's files: `intro.tex:16` (Theorem A, last sentence) and `intro.tex:41` (`tab:intro:claims`).
* *Problem.* What `thm:split:private`(iv) proves (iid Prop 3.3, V-I §1.1) is ν-equivalence on the run: $\sum_i\Hel(\nu(\cdot\mid x_i),\nu_\pi(\cdot\mid x_i))<\infty$. That allows the selected program to differ from ν at infinitely many queried inputs.
  * `prop:recovery:beyond`(a) has a program that differs from ν at *every* query and is still ν-equivalent on the run.
  * With frozen labels and i.i.d. inputs, the condition is $\sum_{x\in\supp\mu}\Hel<\infty$, not equality on $\supp\mu$.
  * "Identifies it on the queried inputs" reads as equality there, which is stronger than the records.
* *Fix* (`recovery.tex:12`): replace "and every $\lambda\ge1$ identifies it on the queried inputs" by "and every $\lambda\ge1$ eventually selects programs that are $\nu$-equivalent on the run, whose Hellinger gaps to $\nu$ along the queried inputs are summable". FRONT should make the same change in `intro.tex:16` and `intro.tex:41`, for example "…every λ ≥ 1 identifies ν on the run (summable Hellinger gaps along the queried inputs)".

**M2. `lem:recovery:ratios`(a),(b) is false as written for frozen labels with repeated inputs.**
* *Where:* `app-recovery.tex:12–23`. This is used by `thm:split:private`(iv) (`app-split.tex:68–70`) and `prop:recovery:frozen`(b).
* *Problem.* `def:split:setting` indexes the data by *queries* ("$o_n$ for the data after $n$ queries"), and FR explicitly allows repeats (`def:setup:data`). The lemma takes $g_i$ at the $i$-th query and allows "any rule of `def:split:setting`" with either kind of label. With frozen labels a repeated query adds no label, so two things go wrong:
  * $\Lambda_{n+1}/\Lambda_n=1$ there, and the equality in (a), $\Ex[\cdot]=\sum_{y:\nu>0}\nu_\pi(y\mid x_{n+1})$, fails.
  * (b) fails outright. Let the rule repeat one input $x_0$ forever, and let π have gap $1/2$ at $x_0$. Then $\sum_ig_i=\infty$, but $\Lambda_n(\pi)=\nu_\pi(F(x_0)\mid x_0)/\nu(F(x_0)\mid x_0)$ is constant and positive with positive probability.
* The proof's parenthesis ("the next distinct input is new") and iid Prop 3.3 ("in the frozen case the process is indexed by distinct inputs") show the intended reading. With that reading every downstream use is correct, because `sec:split:private` already sums over distinct inputs for frozen labels. The Ville proof (`app-split.tex:7`) has the same unstated case: at a repeated frozen input, $Z_{n+1}=Z_n$.
* *Fix* (one sentence each):
  * Add to `def:split:setting` (any-input-rule part): "With frozen labels we index the process by distinct inputs, in order of first appearance; a repeated query changes no data, so FR with i.i.d. inputs is an input rule of this kind."
  * In `lem:recovery:ratios`, write "$g_i(\pi):=\Hel(\nu(\cdot\mid x_i),\nu_\pi(\cdot\mid x_i))$ at the $i$-th query (per query) or at the $i$-th distinct input (frozen labels)".
  * In the Ville proof, add "(at a repeated input with frozen labels $Z_{n+1}=Z_n$)".

**M3. `rem:split:reading` opens with a claim that is false at small $n$.**
* *Where:* `recovery.tex:167`, "at every $n$ the selected model is a sampler, not a fill-in:".
* *Problem.* `thm:split:private`(i),(iii) exclude fill-ins from the λ-MAPs only once $L_n(\nu)>\lambda(k+\delta^*)/(\lambda-1)$, which the same sentence goes on to say. Before that, a short fill-in can be the λ-MAP. The base version did not say "at every $n$".
* *Fix:* "With frozen labels and fixed λ > 1, no λ-MAP is a fill-in once $L_n(\nu)>\lambda(k+\delta^*)/(\lambda-1)$, and the fill-ins' posterior is exponentially small in the sampled randomness, but positive (`thm:split:private`); from then on the selected model is a sampler."

**M4. The frozen-label sentence after `cor:recovery:noisy` generalises one example to every class.**
* *Where:* `recovery.tex:118`, "With frozen labels on a finite support this fails: the data set is eventually the full table, and the λ-MAP is then wrong with positive probability, whatever λ".
* *Problem.* The record proves two things only:
  * no procedure identifies *every* such sampler (`prop:recovery:frozen`(a), iid Prop 7.5);
  * in one explicit class the λ-MAP is wrong with probability at least $(7/8)^{64}$ for every λ (`rem:recovery:frozentable`, iid Cor 6.1(vi)).

  The sentence claims the second for every class and sampler. It is false in general: in a class whose only program is the sampler, the MAP is always right.
* *Fix:* "With frozen labels on a finite support this fails: the data set is eventually the full table, so the selection depends on one table; no procedure identifies every such sampler (`prop:recovery:frozen`(a)), and in the explicit class below the λ-MAP is then wrong with probability at least $(7/8)^{64}$ for every λ (`rem:recovery:frozentable`)."

**M5. The scope sections exceed the plan's budgets and the hard caps of DECISIONS §C.**
* *Where:* §3–§6 and Apps A–D, as measured in log-front §4.

  | part | measured (pp) | budget (pp) |
  |---|---|---|
  | §3 | 3.49 | 2.25 |
  | §4 | 3.40 | 2.25 |
  | §5 | 2.57 | 2.25 |
  | §6 | 5.80 | 4.75 |
  | §3–§6, main text | 15.3 | 11.5 |
  | Apps A–D | 16.3 | 14.75 |

  The whole paper has 37.4 pp of main text against the cap of 27. This is not a mathematical error, but the caps are binding.
* *Fix* (placement only; each keeps its label and leaves a one- or two-sentence pointer):
  * §3:
    * `lem:setup:hull`(v),(vi) to App A as an appendix lemma, with one sentence in the main text (−0.2);
    * `lem:setup:basic` and its proof to App A (−0.12);
    * `rem:setup:objects` cut to three lines (−0.1).
  * §4:
    * `prop:absorb:pricing` to App B, with a two-sentence summary (−0.25);
    * the "Compare …" paragraph after `thm:split:shared` to App B.3 (−0.2);
    * `rem:absorb:wyeth` reduced to (i),(ii) (−0.15).
  * §6:
    * `cor:recovery:noisy` and its paragraph to App D.5, with a three-line summary (−0.45);
    * `rem:recovery:window` to App D.4 (−0.1);
    * `prop:recovery:frozen`(c) to App D.6 (−0.1);
    * §6.7 (`thm:split:lambda1` and the Eisenstat/SI paragraph) to App D, keeping a four-sentence summary (−0.5).
  * Together about −2.2 pp of main text in scope. This needs FRONT's decision, as log-front §4 says.

### Minor

**m1. `rem:recovery:method` (`recovery.tex:54`): "What needs λ > 1 is (c) and (d)."** Part (d)'s first display holds for every λ > 0, as `thm:recovery:main`(d) itself states (V-I §1.2). *Fix:* "What needs λ > 1 is (c) and the margin form of (d)."

**m2. The Remark 4.7′ paraphrase (`recovery.tex:69`) credits the wrong exponent with charging the long programs.** The sentence reads: "the exponent $s=1/\lambda$ turns the prior factor into $2^{-\ell(\pi)}$, summable in every class, so the margin matters only up to length $\bar\ell_\varepsilon$ and longer programs … are charged by the prior."
* With $s=1/\lambda$ for every program, the programs longer than $\bar\ell_\varepsilon$ contribute $2^{\ell_0}t_{\bar\ell_\varepsilon}$, which depends on the class.
* The proof of the margin form (`app-recovery.tex`, (d)) charges them with $s=1$, equivalently δ*: $2^{-\lambda(\ell-\ell_0)}$, summing to at most $2^{\lambda\ell_0-(\lambda-1)\bar\ell_\varepsilon}\le\varepsilon/2$. That is a class-free charge, and it is what the steeper prior buys.
* *Fix:* "In `thm:recovery:main`(d), for λ > 1, the steeper prior charges every program longer than $\bar\ell_\varepsilon$ by $2^{-\lambda(\ell-\ell_0)}$ ($s=1$), at most $\varepsilon/2$ in total in every class, and $s=1/\lambda$ turns the prior factor of the shorter programs into $2^{\ell_0-\ell(\pi)}$, Kraft-summable; so the margin matters only up to length $\bar\ell_\varepsilon$."

**m3. "Sampler" is defined twice, differently.**
* `absorb.tex:49` defines it as "a computable conditional measure … with a program $\pi_\nu$ of length $k$ in the class considered (`def:split:setting`)".
* `def:split:setting` (`recovery.tex:17`) defines it as "a probability kernel ν" (log-W3 D-W3-9 flags this).
* *Fix* (`absorb.tex:49`): "A *sampler* is a probability kernel ν (`def:split:setting`); here it has a program $\pi_\nu$ of length $k$ in the class considered, so in a canonical class it is a computable conditional measure."

**m4. `kinks.tex:61`: "per-query samples have one [a steepness σ > 1] with high probability (`thm:recovery:kink`)".** `cor:kink:split` is about one data set in a data-set class, with the coding bound as its right line. Per-query samples are not data sets; their right line is the Ville line of `thm:recovery:kink`(iii). As written, a reader may apply `cor:kink:split`(b) to $h_n$. *Fix:* add "(where the Ville line of `thm:recovery:kink`(iii) replaces the coding bound)".

**m5. The hull lemma writes the fit as $F$** (`setup.tex:74–84`; `app-setup.tex` §A.2). This conflicts with three uses in or near scope: $F(x)\sim\nu(\cdot\mid x)$ in `def:setup:product`, the finite set of functions $F$ in `prop:absorb:pricing`, and the frozen table $F$ in §6 and App D. PLAN §4.1 fixes the fit as $L$, and `kinks.tex` already writes the same hull with $L$. *Fix:* write $L(\pi)$ (data reading $L=L(\cdot;D)$, population reading $L=R$) throughout the hull lemma and its proof.

**m6. Clashing symbols in the parity classes** (`recovery.tex:59–64`, `app-recovery.tex` §D.3–D.4). The input dimension is $D$ ("uniform on $\{0,1\}^D$", "$D\ge2^{(k-8)/2}$"), which clashes with the data set $D$ used in the same section (§6.7, `def:split:setting`). $M$ also names Solomonoff's mixture in §4. *Fix:* rename the dimension to $d$, which is free in §6.3 and App D.3, and keep $M$ only if FRONT accepts it. Otherwise write $\mathcal C_{k,m_0}$.

**m7. `prop:recovery:lambda1`(a) (`recovery.tex:62`) needs two small edits.**
* "No function of $(\ell_0,\gamma,\varepsilon)$ bounds the recovery time at λ = 1" holds for $\varepsilon<31/32$, the range in (b). *Fix:* add "for $\varepsilon<31/32$".
* "the 1-MAP at $n$ is a parity" should read "every 1-MAP at $n$ is a parity", since several parities may tie.

**m8. `prop:recovery:frozen`(a) (`recovery.tex:138`) uses $\mathcal E_\nu$ and $\mathcal E_{\nu'}$ without defining them.** *Fix:* add "(with $\mathcal E_\nu$ the programs whose kernel equals ν μ-a.e.)".

**m9. `q:recovery:open`(e), second question, is not precise** (`recovery.tex:172`). Its source, iid Conj 7.4, is stated for distinct inputs from a non-atomic μ, which needs an uncountable $X$ and is outside the paper. Per query on the paper's $X$, memorising is impossible (`prop:recovery:beyond`(b)). The question names no data object. *Fix:* name the object, "with frozen labels on distinct inputs (FR without repeats)", and the limit quantity of Conj 7.4. Or drop the second question. DECISIONS §A10 asks for precise questions.

**m10. The frozen comparison (`recovery.tex:118`) describes the second class as "with another rate code".** That class also contains single-input exception programs (V-I §1.10, "including its single-input function competitors"). *Fix:* "(0.136, 0.136, 0.085, 0.566 in a second class, with another rate code and single-input exception programs)".

**m11. Two small presentation points.**
* The PDF outline names the subsection `app:recovery:main` "Proof of Theorem A" (`app-recovery.tex:35`, `\texorpdfstring{…}{Theorem A}`). "Theorem A" is the introduction's informal name, and PLAN §7.2(4) allows it only in the introduction. *Fix:* `\texorpdfstring{\cref{thm:recovery:main}}{Theorem \ref*{thm:recovery:main}}`, as for the section titles.
* `thm:split:shared`(ii) (`absorb.tex:55`) should say "for every nonempty set $A$ of programs".

---

## Checked and correct (no action)

* **Setting.**
  * `def:setup:data` and `rem:setup:objects` match PLAN §4.3 and iid Remark 1.4.
  * `def:setup:class` and `def:setup:objectives` are correct, including the extension "for every λ > 0" and the per-query observations.
  * Hull lemma (i)–(vi) with the gift-wrapping proof:
    * attainment, $\rho_i$ attained at length $\alpha_i$, strict decrease of the $\sigma_i$, $\sigma_i\to0$;
    * the epigraph identification;
    * (iv) with `rem:setup:hullconverse` and the two examples (thresholds 0.05; $\bar\ell\in[5,10)$);
    * (vi) for $\alpha\ge\alpha_0$.
  * The coding bound and its right-line reading: offset $b+\kappa$, and $b+\kappa\ge0$ at $\pi_s$.
* **Absorption.**
  * `thm:absorb:absorption`(a)–(c) and the threshold equivalence.
  * `thm:split:shared`(i),(ii); I re-derived the comparison $(\lambda-1)k>\lambda\ell_U+\kappa_0\iff\ell^*_\lambda<k$.
  * The dominance constants $2^{-\lambda k}$ and $2^{-\lambda\ell_U-\kappa_0-k}$.
  * `prop:absorb:pricing` (Gibbs, Sion; the value 2.5431 recomputed) and `cor:absorb:nouniversal`.
  * `prop:absorb:price`(i)–(iv): the AM–GM step, $\bar Q$, and the constant $(\lambda+2)\kappa$.
  * The sentence after the absorption theorem, which is `prop:kink:universal`(i) with (Dom) on one observation.
* **Kinks.**
  * `def:kink:kinks` matches kink Def 3.1 and teacher Def 1.4 with the V-T offset. The remarks after it hold: zero-window ⟺ $s_-\ge\sigma$, $s_+\le\tau$; window $g/(\tau'-\tau)$ for $g\ge0$.
  * `lem:kink:main`(i)–(v) is the V-T-verified final form, two fits included.
  * `cor:kink:locate`(a)–(c), with the converse and the strictness examples (V-K §6).
  * `cor:kink:split`(a),(b), `prop:algstat:product`, `thm:kink:converse` (including the case "$j$ exists unless τ = 0 and the vertices are infinite"), and `prop:kink:universal`(i),(ii) with the V-K §5 clause.
  * `lem:kink:secant`(a)–(c): (c) for $c\ge0$, $c\ne s_+$.
  * App C.1, $\breve\rho=\underline C$.
* **Exact recovery.**
  * `def:split:setting`; the margins; Hellinger gap positive iff π ∉ $\mathcal E$, sub-probabilities included.
  * `lem:split:ville`: the supermartingale per query and on new inputs; ν need not be in $\mathcal C$.
  * `thm:recovery:main`(a)–(d): the event $B_{\bar\ell}$, the short-program step with $\lambda_n=o(n)$, the Borel–Cantelli tail for (b), the fill-in bounds of (c) under both posteriors, and (d) with $a=2\min(1,\lambda-1)\gamma/\lambda$.
  * `rem:recovery:posterior` (8/9, 4/5).
  * `prop:recovery:lambda1`(a)–(c): the rank bound $<2^{n-m}$, the lower end at $n_b$ ($k\ge14$ for it to be nontrivial), the upper-end chain ($m^*+1\ge n/2$ for $n\ge32$), and the Rényi sum with parity weight 1/4.
  * `prop:recovery:necessity`(a)–(e): Chebyshev with $\Var X\le\log^2(1-2\varepsilon')$, the gap bracket $[\varepsilon'^2/2,2\varepsilon'^2]$, $n_1\ge0.083\lambda\Delta/{\Hel}_\mu$, the tie and $\delta_n=-2+\log(1+2^{2-k})$ in (d), and the computable-$g$ construction in (e).
  * `thm:recovery:kink`(i)–(v): the Markov step on $\sqrt\Lambda$; $\sigma_n$ and the condition $A\ge2\ell_0$; the right line with offset $\ell_0+\delta^*\ge0$; the flat part and the secant bound below $\tau_{\bar\ell}$; and the vertex step via `cor:kink:locate`(c), giving $s_+=\sigma_{i+1}<1<\sigma_i\le s_-$.
  * `rem:recovery:window` (excess $k-7$).
  * `cor:recovery:noisy`(i)–(iii) and `rem:recovery:frozentable`, with the corrected sentence and $(7/8)^{64}$.
  * `thm:split:private`(i)–(iv): (iv) through $Z^{\bar\ell}$ and the Kakutani martingale, valid for λ ≥ 1, with the a.s. hypothesis on $\pi_\nu$.
  * `prop:recovery:frozen`(a)–(c): mutual absolute continuity, the gap $\ge\beta_x/2$, and $4\lambda<6$.
  * `prop:recovery:beyond`(a)–(c), with no "iff" and $c=c^*$ not covered.
  * `thm:split:lambda1`, `lem:split:stream` (certification, coverage $\nu-3\cdot2^{-i}$, the length $L_{t_D}$), `prop:split:si` and `rem:split:siprograms`.
* **Form.**
  * Statuses are rendered in prose: refuted strengthenings as "The natural strengthening … fails", the known results cited, and computed numbers outside statements with "A direct computation (code in the accompanying repository) …".
  * The split-thread numbers are not marked as κ = 0 illustrations, as V-I §2 item 7 allows. `ex:split:noisyparity` is marked as an illustration.
  * One footnote is in scope (the change-of-slope credit), outside any statement.
  * No process vocabulary and no mention of Wyeth.
  * The labels of PLAN §3 for W1–W3 are defined once. The cut labels (`lem:split:hash`, `app:split:hash`) are gone.
