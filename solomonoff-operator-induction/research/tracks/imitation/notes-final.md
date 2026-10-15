# Track "imitation": synthesis (final record)

*Brief: `00-brief.md` (this folder), which quotes the author's message in full. This record synthesises the two sub-track records `robust/notes-final.md` (target I1) and `decay/notes-final.md` (target I2), with their referee reports, against Paper 2's current sections, and drafts the paper text for targets I1–I3. Written 2026-10-14 by the synthesis editor. It proves nothing beyond the sub-track records except where marked **[proved here]**: one simplification of a definition (§2.2) and the line-by-line checks of the material no referee has read (§2.3).*

* **Sources read.**
  * The brief, in full.
  * `robust/notes-final.md` (in full), `robust/referee-A.md` (in full), `robust/referee-B.md` (in full); the outputs of `robust/checks-final/f7` and the code of its part (D).
  * `decay/notes-final.md` (in full), `decay/referee.md` (in full), `decay/refs.bib`.
  * Paper 2 (`paper-steeper/sections/`): `abstract`, `intro`, `discussion`, `related`, `teacher`, `limits`, `recovery`, `kinks` in full; `setup` (`def:setup:class`, `def:setup:objectives`, `rem:setup:persample`, `lem:setup:hull`); `parity` (`def:teacher:instance`, `lem:teacher:coding`, `lem:teacher:twopart`); `computable`; `app-setup` (F1)–(F5); `app-recovery` (`lem:recovery:ratios`, `prop:recovery:beyond` and its proof); the section headers of every appendix; `main.tex`, `preamble.tex`, `build.sh`, `merge_bib.py`, `main.toc`.
  * `research/tracks/split/notes-final.md` §0, §1, §4.
  * `research/paper-review/REFRAME.md` (in full) and `DECISIONS.md` §0 and §A (the arXiv conversion: status rendering, process vocabulary, computed numbers, literature hedges).
  * `paper/NOTATION.md` (searched for every symbol the drafts use) and Paper 1's sections (searched for numbered references to Paper 2: there are none, so a new section in Paper 2 renumbers nothing that Paper 1 cites).
* **Scripts.** `checks/s1_synthesis.py` → `checks/s1_synthesis.out` (new; Python 3.11.15, NumPy 2.4.6; deterministic, parts (B), (C), (F) seeded with `default_rng(141)`, `(142)`, `(143)`; 31 s). It imports nothing from the sub-tracks' code. Parts: (A) the numbers quoted in the drafts; (B) the machine-free steps of the closeness lemma on random latent-cause instances; (C) the counting form of the closeness lemma, exhaustively over a type class of 35,960 couplings; (D) the confounding count for $m=3$; (E) the numbers of the weight-decay drafts and a Newton solve on both sides of ω*; (F) the two inequalities that convert $D_{1/2}$.
* **Draft files.** `drafts/` holds the LaTeX of §2 and §3 as files, byte-identical to the blocks below, and unified diffs against the current `paper-steeper/` sources for every edited file (`main`, `intro`, `discussion`, `related`, `teacher`, `app-teacher`). They were built in a scratch copy of `paper-steeper/` (§5); nothing in `paper-steeper/` was changed. The diffs apply with `patch -p1` from inside `paper-steeper/`, and the new files go to `sections/` and `bib/`; on a fresh copy this reproduces the built sources byte for byte (tested).
* **Status tags.** **[proved: X]** proved in record X, which has the full proof (`robust` = `robust/notes-final.md`, `decay` = `decay/notes-final.md`); **[proved, refereed]** read in that form by a sub-track referee; **[proved, not refereed]** added in a final record after the referee round; **[proved here]**; **[computed: script(part)]**; **[known: ref]** with the level of verification; **[remark]**, **[heuristic]**, **[open]**, **[refuted]** as in the sub-track records; **[recommendation]** for an editorial judgment.
* **Conventions.** $\log=\log_2$; κ is Paper 2's machine constant; numbers "with κ = 0" are illustrations. In the drafts the human is called "the person", the coin set is $\Sigma$ (Paper 2's $B$ is the truncation level of `def:teacher:instance`), and the coin law is ρ (local to the new section; Paper 2's ρ with an argument α is a structure function).
* **Repository.** No git command was run. Files written: this record, `checks/s1_synthesis.py`, `checks/s1_synthesis.out`, and `drafts/` (11 files). The sub-track folders are unchanged. A final check (`final-check.md`) then edited this record and seven files of `drafts/`, minimally; every edit is listed there, and `drafts/` is again byte-identical to the blocks below.

---

## 0. Summary

1. **Is the robust-recovery material "cool" enough? Yes, modestly** [recommendation, §1]. It delivers a toy form of the author's ideal theorem: when a person's coins are an incompressible function of an environment variable on many more cells than the person has bits, hypotheses that model the environment predict better, yet for $\lambda=cn$ with $c$ between the reuse factor $2^{-m}$ and about $H(\rho)/\ell_0$, **every** near-optimal private-randomness hypothesis, whatever it computes internally, is close to the person in behaviour (`robust` Theorem 4.7(U)(vi)). It comes with a matching impossibility: an incompressible coupling alone is not enough, for any procedure (`robust` Proposition 4.11). The genuinely new piece is a closeness lemma (`robust` Lemma 4.6); the rest assembles Paper 2's kink lemma with a generalised coding lemma. The positive case is narrow: the better predictors gain only by storing an incompressible table, compact environment models defeat every $c$, and only behaviour is identified.
2. **Recommendation: a new short section** `sec:imit` ("Imitation: a sampler whose coins the environment drives"), placed after `sec:limits` and before `sec:computable`, with its proofs in a new appendix `app:imit` after `app-limits` [recommendation, §1.4]. In the scratch build it takes about 2.6 pages of main text and 3 pages of appendix (§5).
3. **Statements and draft** (§2). The theorem `thm:imit:main`, the lemmas `lem:imit:coding`, `lem:imit:closeness`, the proposition `prop:imit:limits`, the remark `rem:imit:private` and the question `q:imit:open`, each mapped to the record result that proves it. One definition is simplified ($B_\beta:=K(\beta\mid h_0,\mu)$; [proved here] that nothing else changes). The closeness lemma and the behavioural conclusion, which no referee has read, were checked here line by line and by an independent exhaustive computation [computed: s1(B),(C)].
4. **Weight decay** (§3). The decay record's remark, appendix subsection and related-work sentence are adopted with five edits; one sentence is added to the discussion. All twelve cited works (eleven of them new to Paper 2) were confirmed by WebSearch a third time (§3.4). BibTeX: `drafts/imit.bib`, eleven entries, no key collisions with Paper 2's bibliography.
5. **Caveats** (§4). Paper 2 already caveats the teacher thread's scope ("Scope and reader's guide", "The gap to realistic errors"), but it does not say that the motivating problems are unsolved, nor list the conceptual gaps. Drafted: a rewritten scope paragraph that names exactly the four toy cases solved by proved results, one motivation sentence, a contributions bullet and a table row in the introduction; a discussion paragraph naming six concrete open problems, each tied to the result that exhibits it; one open-problems item.
6. **Build** (§5). In a scratch copy of Paper 2 with all drafts: 0 LaTeX errors, 0 undefined references or citations, 0 multiply defined labels, 0 overfull boxes over 10 pt, no process vocabulary in the PDF; 84 pages against 74 now (main text and references +6, appendices +4). §5 lists cuts.

---

## 1. Assessment: is the robust-recovery material cool enough for the paper?

### 1.1 What the author asked for

The message asks for "some sort of robustness of recovering the sampler, at least in a toy setting": one can do better at prediction by arbitrarily alien thinking about the environment around the human, "but we robustly pick out the sampler anyway". It also names two failure modes to avoid, "the sampler with some bits specified" and "some completely alien system that just thinks about what the human would say", and says the material belongs in the paper "only if you come up with sth cool".

### 1.2 What is new and nontrivial, and what restates Paper 2

| result (`robust` numbering) | relation to Paper 2 | assessment |
|---|---|---|
| Lemma 2.1, Thm 2.2 (private coins; Ville with side information) | `lem:split:ville` with a larger filtration; `thm:recovery:main` on inputs $(x,z)$ | **restatement** [proved, refereed]. Ville's inequality for predictable forecasters; the reading "robust against every predictor, whatever it sees" is the only new content. Here no alien predicts better in population: the degenerate case of the author's scenario. Worth one short remark. |
| Prop 3.1, 3.3, Example 3.2 (behaviour, not mechanism) | twin argument of `prop:limits:noident`(iii) | **elementary** [proved, refereed]. Belongs in the caveats, as one sentence. |
| Setting 4.1 (environment-driven coins) | contains `def:teacher:instance` as the feature case with a parity | **new framing**: a teacher's systematic errors are, formally, environment-driven coins, so the teacher thread *is* an imitation problem. Any finite response function, coin law and latent-cause channel. |
| Lemma 4.4 (coding lemma) | generalises `lem:teacher:coding` | **modest**: a simpler proof (Jensen instead of a truncated geometric mean) for a more general setting [proved, refereed]. |
| Lemma 4.5(d), Thm 4.7(U)(i)–(v) (referee A's A1) | `lem:kink:main` with a right line on the whole class | **easy given Paper 2** [proved, refereed]: the right line of slope $2^{-m}$ with offset of order $\ell_0$ is two lines from the coding lemma, and the kink lemma does the rest. Its value is that it needs no left condition, so it covers aliens that do not encode the person's model. |
| **Lemma 4.6 (closeness) and Thm 4.7(U)(vi)** | none | **the genuinely new ingredient** [proved, not refereed; checked here, §2.3]. It turns "predicts no better than the person and holds little information about the coupling" into a *behavioural* statement, a bound on $\Ex_xD_{1/2}(\nu_H\Vert\nu_\pi)$, by a Hölder step and a coding argument for a semimeasure built from per-cell geometric means. Paper 2 has no behavioural closeness statement beyond the parity-specific agreement $u$ and error probability $e$. |
| Thm 4.7(vii) (the lower end $2^{-m}$ is sharp) | generalises `thm:teacher:main`(iv) | restatement in the general setting [proved, refereed in its old form, with the M3 repair]. |
| Prop 4.10(a2) (one data law, at most one copy) | `prop:limits:noident`(iii) for $N$ worlds | **elementary but clarifying** [proved, not refereed; checked here]: imitation data identify the data kernel $P^*$, not its split into a person and an environment. |
| Prop 4.11 (confounding; referee A's R1) | none | **new and nontrivial negative result** [proved, refereed]: with an incompressible coupling, a person as complex as its coupling and entangled with it cannot be copied by any procedure with probability above $2^{-L_\beta}$. It shows that "$\ell_0\ll2^m$, or a left condition" is necessary, not a technicality. |
| Prop 4.10(c),(d) (cheap couplings; a window needs many cells) | analogue of `prop:limits:rateblind` | restatement in the general setting [proved, refereed by rb2]. |
| Prop 4.3, 4.10(b) (rates; schedules) | `lem:setup:hull`, `prop:teacher:schedules` | restatement, plus the boundary results (b4), (b5) [proved, not refereed]. Not proposed for the paper. |
| §5 (latent state: Props 5.1–5.3) | `lem:split:ville`, `thm:split:shared`, Theorem A per episode | restatement [proved, refereed]. Its message, that excluding in-context learners is a choice of class, is one sentence of the draft. |

### 1.3 Why only "modestly" cool

* **The better predictors are memorisers.** In the positive theorem, a hypothesis predicts better than the person only by storing an incompressible table on $2^m$ cells, the least alien kind of "alien thinking". Hypotheses with a *compact* model of how the environment drives the person's randomness are exactly the case of cheap couplings, where no $c$ works (`robust` Prop 4.10(c)) [proved, refereed]. The author's "arbitrarily alien thinking" in its interesting form is therefore covered only negatively.
* **The regime is narrow.** The guarantee needs $\ell_0+|\Sigma|m+\delta_\beta\ll2^m$, and by `robust` Prop 4.10(d) a window for exact copies needs $2^m\gtrsim\ell_0/(\log|Y|-H(\rho))$. A person of $10^6$ bits with $H(\rho)=\frac12$ needs more than $1.99\cdot10^6$ incompressible cells [computed: s1(A); κ = 0, an illustration].
* **Near-copies, on average.** The conclusion bounds an input-averaged Rényi-½ divergence, to be compared with the best predictor's value $H(\rho)$. For the fair-coin person at $m=20$, $c=2^{-19}$, the bound is $6.2\cdot10^{-4}$ bits against $H(\rho)=1$; for the parity person of Paper 2's running example it is $9.5\cdot10^{-4}$ against $0.0112$ at $c=2^{-19}$, and it exceeds $H(\rho)$ at $c=10^{-4}$ [computed: s1(A); κ = 0, $\delta_\beta=0$, an illustration]. The mean total-variation bound of `robust` Cor 4.8(b) (0.025 at $c=2^{-19}$) is not informative for that person, since even the best predictor has mean total variation $2p(1-p)=0.0020$ from it [proved here: $\mathrm{TV}(\nu_H(\cdot\mid x),\delta_{h(x,\beta(w))})=1-\rho(\beta(w))$, averaged over cells of exact type]. The draft therefore quotes $D_{1/2}$ against $H(\rho)$ and no total-variation numbers.
* **Population objective.** From samples the statement holds only eventually, for each fixed $c$ (`prop:recovery:beyond`(c)); finite-sample bounds for general response functions are open.
* **Identification is behavioural and conventional.** Only the person's kernel is identified, and only relative to a convention that splits $P^*$ into person and environment (`robust` Props 3.1, 4.10(a2)).

The lower bound the brief asked for ("no procedure can robustly pick the human against aliens with large advantage per bit") is **[refuted]** for general procedures by referee B's procedure $\Psi_{\rm var}$, whose two success probabilities sum to 1.98 (rb4(C)); it holds for penalised likelihood (`robust` Props 4.3, 4.10(b)) [proved, refereed]. The obstruction for every procedure is a shared data law (Prop 4.10(a2)) and, sharply, entanglement (Prop 4.11). The draft states only the latter two.

### 1.4 Recommendation

**A new short section, `sec:imit`, after `sec:limits`** [recommendation]. Reasons, against the alternatives the brief lists:

* *Not nothing.* It is the toy theorem the author asked for, with a matching impossibility, and it shows that the teacher thread and imitation are one mathematical problem. That connection alone justifies visibility.
* *Not a remark.* A remark cannot carry a theorem with a proof, and the behavioural conclusion is the point.
* *Not a subsection of the split section* (`sec:recovery`). The result uses $\lambda=cn$, the reuse factor $2^{-m}$ and the teacher instance, which come later (`sec:teacher`); placed in `sec:recovery` it would need forward references to all three. Its negative results parallel `sec:limits` (rate blindness, rate not validity, non-identifiability), which it can then cite backwards.
* *Short, not a third thread.* About 2.6 pages: one remark (private coins), one definition, one theorem, one proposition, one question, with the caveats in the running text. The discussion's new paragraph (§4.2) carries the conceptual caveats for both threads.

If the page budget is tight, §5.3 gives a 1.3-page version.

---

## 2. The recommended section: statements, checks and draft

### 2.1 Exact statements as proved, with pointers

| paper item (draft label) | statement | proved in | status |
|---|---|---|---|
| `rem:imit:private` | under privacy given the person's input, $L_n(\pi)\ge L_n(\nu_H)-\ell(\pi)-\delta^*$ for every countable Kraft family of predictors, $\Prob[\delta^*\ge j]\le2^{-j}$; with environment variables in a countable set, i.i.d. pairs and product hypotheses, Theorem A returns the person | `robust` Lemma 2.1, Thm 2.2(2),(3); proof in `app:imit:private` | [proved, refereed]; known in substance (Ville's inequality for predictable forecasters) |
| `def:imit:setting` | environment-driven coins: channel μ, person $(h,\rho)$, coupling β of exact type ρ, data kernel $P^*$, $L_\beta$, $B_\beta:=K(\beta\mid h_0,\mu)$, $\delta_\beta$, $I_\beta$, $D_{1/2}$ | `robust` Setting 4.1, with $B_\beta$ simplified (§2.2) | definition |
| `lem:imit:coding` | $K(\beta\mid h_0,\pi,\mu)\le2^mR(\pi)+\kappa$ for every $\pi\in\Hcl{\times}$ | `robust` Lemma 4.4 | [proved, refereed]; [computed: r6(A), rb2(A), s1(B)] |
| `lem:imit:closeness` | $\Ex_xD_{1/2}(\nu_H\Vert\nu_\pi)\le\bar D(\pi)\le R(\pi)-H(\rho)+2(I_\beta(\pi)+\delta_\beta+\lvert\Sigma\rvert\log(2^m+1)+E(\pi)+\kappa)/2^m$ | `robust` Lemma 4.6 | [proved, not refereed]; checked line by line here (§2.3); [computed: f7(A),(B), s1(B),(C)] |
| `thm:imit:main` (i)–(iii), bound on Φ | at $c=a2^{-m}$, $a>1$: $\ell(\pi)\le\ell_0+(G+2^m\epsilon)/(a-1)$; $-(aG+2^m\epsilon)/((a-1)2^m)\le R(\pi)-H(\rho)\le c\ell_0+\epsilon$; $I_\beta(\pi)\le\ell_0+(G+2^m\epsilon)/(a-1)+\kappa$; $J_c(\pi_H)\le\Phi(c)+G/2^m+c\ell_0$ | `robust` Thm 4.7(U)(ii)–(v) = referee A's A1 | [proved, refereed]; the right side of (ii) is the sharper $c\ell_0+\epsilon$ that `lem:kink:main`(iv) gives with $\ell_{\mathcal M}=0$ (`robust` writes $c(\Gamma+\kappa)+\epsilon$) |
| `thm:imit:main` (iv) | $\Ex_xD_{1/2}(\nu_H\Vert\nu_\pi)\le c\ell_0+\frac{2a}{a-1}\cdot\frac{G+E+\kappa}{2^m}+\frac{a+1}{a-1}\epsilon$; Hellinger gap at most $\frac{\ln2}2$ times that | `robust` Thm 4.7(U)(vi) | [proved, not refereed]; checked here (§2.3) |
| `thm:imit:main`, last sentence | feature case, distinct values of ρ: a program of length $\le\ell_0+\lceil L_\beta\rceil+a_\rho+\kappa$ computes $P^*$ with risk 0 and beats every copy for $c<H(\rho)/(\lceil L_\beta\rceil+a_\rho+\kappa)$ | `robust` Thm 4.7(vii) | [proved, refereed in its old form (referee A confirmed it against $\pi_H$); repaired per A-M3] |
| text after the theorem: $cn$-MAPs | almost surely every $cn$-MAP satisfies (i)–(iv) with ε = 0 for all large $n$ | `robust` Cor 4.9 = `prop:recovery:beyond`(c) with the sampler $P^*$ | [proved, refereed] |
| not in the final draft (dropped when the section was shortened; final check): other classes | part (a) holds in every product class of `def:setup:class` that contains a copy, with its own $\ell_0$, Φ, κ | `robust` Cor 4.9 (B-B6) and the proof (it uses only (F1)–(F3), (F5) and uniform lower semicomputability) | [proved, refereed for (i)–(iii); checked here for (iv)] |
| `prop:imit:limits`(a) | worlds with one data law and pairwise different persons: $\sum_i\Prob_{W_i}[\Psi(h_n)\in\mathcal E(\nu_i)]\le1$ for every procedure | `robust` Prop 4.10(a2),(a1) | [proved, not refereed]; checked here (elementary) |
| `prop:imit:limits`(b) | the entangled world: $\Prob[\delta_\beta>j]<2^{-j}$, yet every procedure copies the person with probability at most $2^{-L_\beta}$ | `robust` Prop 4.11(a),(b) = referee A's R1 | [proved, refereed]; [computed: ra1(B), f8(A), s1(D)] |
| `app:imit:limits`, "No window in (b)" | with probability $\ge1-2^{-j}$, under the stated inequality, the table or the fair coin beats every copy at every $c$ | `robust` Prop 4.11(c) | [proved, refereed; one constant corrected after the referee round, $2\log(m+1)\to4\log(m+1)$] |
| `prop:imit:limits`(c) | cheap couplings: if $H(\rho)/(K(\beta\mid\pi_H)+\kappa)\ge(\log\lvert Y\rvert-H(\rho))/(\ell_0-\ell(\pi_{\rm u}))$, at every $c$ some non-copy is at least as good as every copy | `robust` Prop 4.10(c) | [proved, refereed; computed: f2(B), rb2(C)] |
| text and `app:imit:limits`: the cell count | a window for copies needs $2^m>(\ell_0-\ell(\pi_{\rm u}))/(\log\lvert Y\rvert-H(\rho))-(a_\rho+1+\kappa)/H(\rho)$ | `robust` Prop 4.10(d) | [proved, refereed; computed: rb2(B), s1(A)] |
| section introduction: the in-context learner | a Bayes mixture giving the person weight $w$ loses at most $\log(1/w)$ bits of fit on every data set, so it beats the person's program at every $n$ once λ times the length it saves exceeds $\log(1/w)$ | `robust` Prop 5.2 (the one-line proof $P_U\ge wP_H$) | [proved, refereed; computed: r5(B), rb5(A)] |
| text after the proposition: behaviour, not mechanism | persons with the same response function and coin law share a data law, however they compute them (equal kernels suffice when the coins are private or the values of ρ are distinct; final check F5) | `robust` Prop 3.1; Setting 4.1 ($P^*$ depends on the person only through $h$) | [proved, refereed (Prop 3.1); the environment-driven form elementary] |
| `q:imit:open` | partly private coins; unequal cell masses; finite samples; slow-to-compute couplings; non-imitation data | `robust` §8 items 1, 2, 4, 6, 7 | [open] |

### 2.2 Changes relative to the robust record, and why they are safe

1. **$B_\beta:=K(\beta\mid h_0,\mu)$**, without the extra condition $K(h_0\mid\mu)$ of `robust` Setting 4.1 [proved here]. The extra condition serves only the symmetry-of-information step of `robust` Lemma 4.5(a),(e), that is, case (L) of Theorem 4.7. Case (U) and Lemma 4.6 use $B_\beta$ only through three facts, each of which holds for the simpler definition:
   * $K(\beta\mid h_0,\pi,\mu)=B_\beta-I_\beta(\pi)$: the definition of $I_\beta$;
   * $B_\beta\le\ell(\pi)+K(\beta\mid h_0,\pi,\mu)+\kappa$: (F3) relative to $(h_0,\mu)$, $K(\beta\mid h_0,\mu)\le K(\pi\mid h_0,\mu)+K(\beta\mid h_0,\pi,\mu)+\kappa$, and (F1);
   * $B_\beta=L_\beta-\delta_\beta$ with $\Prob[\delta_\beta>j]<2^{-j}$ for β uniform on its type class independently of $(h_0,\mu)$: fewer than $2^{L_\beta-j}$ programs are shorter than $L_\beta-j$; and $\delta_\beta\ge-1-\kappa$, since given $(h_0,\mu)$ the index of β in its type class has a known length $\lceil L_\beta\rceil$.
2. **Case (L) of Theorem 4.7 is not proposed.** For the parity person, `thm:teacher:main` already gives more (list decoding, knowledge of the parity, error probabilities), and the draft points to it. For other models the left condition is open (`q:teacher:open`(a)).
3. **The right side of (ii)** is $c\ell_0+\epsilon$ (from `lem:kink:main`(iv) with $\ell_{\mathcal M}=0$) instead of `robust`'s weaker $c(\Gamma+\kappa)+\epsilon$; $E$ is defined with $c\ell_0$ accordingly [proved here: the substitution in the proof of (vi) only uses $R(\pi)-H(\rho)\le$ the right side of (ii)].
4. **Numbers come from the stated bound**, not from the tighter intermediate bound of the proof that `robust` f7(D) printed: at $a=2$ the stated form gives $9.42\cdot10^{-4}$ for the parity person against f7(D)'s $8.92\cdot10^{-4}$, and $6.14\cdot10^{-4}$ for the fair-coin person [computed: s1(A)]. The draft quotes the stated form, rounded up.
5. **Vocabulary and notation.** "Person" for "human"; coin set $\Sigma$; "a program that is not a copy" for "alien" (the paper never uses "alien"); no Theorem 4.7(L), no Corollary 4.8 numbers in total variation (§1.3).
6. **Process vocabulary.** The visible text contains none of the words banned by DECISIONS §A5; `\status` and `\src` carry the provenance and print nothing; the one computed sentence uses "A direct computation (code in the accompanying repository)" and "(an illustration)" (§A9).

### 2.3 The material no referee has read: checks done here

`robust/notes-final.md` states that no referee has read Lemma 4.6, Theorem 4.7(vi) and Proposition 4.10(a2),(b4),(b5). The draft uses the first three.

* **Lemma 4.6, line by line** [proved here, as a check].
  * *Hölder.* The generalised Hölder inequality applies with weights $\mu(x\mid w)$ summing to 1; $\prod_xf_x(b)^{\theta_x}=\sqrt{\rho(b)\tilde q_w(b)}$; injectivity of $h(x,\cdot)$ turns $\sum_b$ into $\sum_y$. Averaging over uniform $w$ gives $\Ex_{x\sim\bar\mu}$ because $\bar\mu=2^{-m}\sum_w\mu(\cdot\mid w)$.
  * *Semimeasure.* Weighted AM–GM gives $\tilde q_w\le q_w$; Cauchy–Schwarz gives $Z_w\le1$; $Q$ factorises over cells, so its mass is $\prod_wZ_w$. Lower semicomputability: lower approximations of $\nu_\pi$ increase every factor.
  * *Normalising.* For the conditional coding theorem with the extra condition $k$, the family must be a semimeasure for every value of the condition; the usual trimming (stop adding mass at 1; the set $\Sigma^W$ is finite) does this and changes nothing at the true $k$. Then $K(\beta\mid\cdot)\le K(\beta\mid\cdot,k)+K(k)+\kappa$ and $-k<\log Z+1$. The draft states the trimming explicitly.
  * *Evaluating.* $-\log Q(\beta)=\frac12\big(\sum_w\log\frac1{\rho(\beta(w))}+\sum_w-\log\tilde q_w(\beta(w))\big)=2^{m-1}(H(\rho)+R(\pi))$ uses exact type and the definition of $R$; $\log Z=-2^{m-1}\bar D$ is the definition of $D_{1/2}$; $k\le-\log Z\le-\log Q(\beta)$ since $Q(\beta)\le Z$.
  * *Lower bound and division.* $2^mH-|\Sigma|\log(2^m+1)-\delta_\beta-I_\beta\le2^{m-1}(H+R)-2^{m-1}\bar D+1+E+\kappa$, divided by $2^{m-1}$, is the claim.
* **Theorem 4.7(vi)** [proved here, as a check]. Inserting (ii) and (iii) into the lemma: the bracket is $\ell_0+\frac{G+2^m\epsilon}{a-1}+\delta_\beta+|\Sigma|\log(2^m+1)+E+2\kappa=\frac{a}{a-1}G+\frac{2^m\epsilon}{a-1}+E+\kappa$; times $2/2^m$ plus $c\ell_0+\epsilon$ gives $c\ell_0+\frac{2a}{a-1}\cdot\frac G{2^m}+\frac{2(E+\kappa)}{2^m}+\frac{a+1}{a-1}\epsilon$, at most the stated bound since $\frac{2a}{a-1}\ge2$. $E(\pi)\le E$ uses the right side of (ii).
* **Proposition 4.10(a2)** [proved here, as a check]: one data law gives one output law; the sets $\mathcal E(\nu_i)$ are disjoint because a program in two of them would make the kernels agree almost everywhere. The world with person $P^*$ is an instance of the setting with $|\Sigma|=1$, the same channel, and $h'(x,\ast):=h(x,\beta(w))$.
* **Independent computation** [computed: s1(B),(C)].
  * s1(B): 1240 programs (sub-probabilities, programs near the person, programs with zeros) in 40 random latent-cause instances with $|\Sigma|\in\{2,3\}$, up to four labels, 8 cells, 6 inputs. Hölder step: $\max(\Ex D_{1/2}-\bar D)=0$ (attained at the person), $-7.3\cdot10^{-5}$ over the other programs; $\max(\tilde q_w-q_w)=2.2\cdot10^{-16}$; $\max_w\sum_bq_w=1$; total mass of $Q$ by brute force over all $|\Sigma|^8$ maps at most $1.000000000000$; the identities $-\log Q(\beta)=2^{m-1}(H+R)$ and $\log Z=-2^{m-1}\bar D$ to $7\cdot10^{-15}$.
  * s1(C): the counting (machine-free) form of the lemma, $\Pr_{\beta'}[\exists\pi:\bar D(\pi)\ge H+R_{\beta'}(\pi)-2(L_\beta-\ell(\pi)-j)/2^m]\le k_{\mathcal C}2^{-j}$, exhaustively over all 35,960 couplings of 4 coin-1 cells among 32, in a feature-case class whose person responds to the cell ($h(w,b)=g(w)+b\bmod3$) with 41,793 programs and Kraft sum $0.107$: the person, the uniform kernel, 31 rates, 200 random kernels, 32 interval, 80 subcube, 35,960 full and 5,488 partial memorisers. The event's frequency is $0.00289$ for $j\le0$, $0.00089$ for $j=1,2$ (the 32 interval couplings) and $0$ from $j=3$, below $k_{\mathcal C}2^{-j}$ at every $j$. This is an independent implementation of what `robust` f7(B) checks, in a different class and size.

### 2.4 Numbers used in the draft

| quantity | value | source |
|---|---|---|
| fair-coin person, $m=20$, $c=2^{-19}$, $\ell_0\le a_\rho=53.95$: bound (iv) | $6.139\cdot10^{-4}$ bits (quoted $6.2\cdot10^{-4}$), against $H(\rho)=1$ | [computed: s1(A)] |
| parity person, $d=100$, $p=2^{-10}$, $\ell_0\le119.93$: bound (iv) at $c=2^{-19}$ | $9.421\cdot10^{-4}$ (quoted $9.5\cdot10^{-4}$), against $H(\rho)=0.011174$ (quoted $0.0112$) | [computed: s1(A); f7(D) prints $8.92\cdot10^{-4}$ from the tighter intermediate form] |
| same at $c=10^{-4}$ | $1.2356\cdot10^{-2}>H(\rho)$ | [computed: s1(A)] |
| cell count for $\ell_0=10^6$, $H(\rho)=\frac12$, $\lvert Y\rvert=2$, $\ell(\pi_{\rm u})=0$ | $2^m>1.9998\cdot10^6$ (quoted "more than $1.99\cdot10^6$") | [computed: s1(A); agrees with r6(D)] |

All with κ = 0 and $\delta_\beta=0$: illustrations, not values for a fixed reference machine, as the draft says.

### 2.5 Draft LaTeX

**Placement.**
* `paper-steeper/sections/imit.tex` (new), input in `main.tex` after `\input{sections/limits}`.
* `paper-steeper/sections/app-imit.tex` (new), input after `\input{sections/app-limits}`. The diff is `drafts/main.diff`.
* New labels: `sec:imit`, `rem:imit:private`, `def:imit:setting`, `thm:imit:main`, `prop:imit:limits`, `q:imit:open`, `app:imit`, `app:imit:private`, `app:imit:lemmas`, `lem:imit:coding`, `lem:imit:closeness`, `app:imit:main`, `app:imit:limits`. No existing label or statement changes. The section renumbers `sec:computable` (10 → 11) and the appendices after G; Paper 1 cites no Paper 2 numbers.
* Every cited label exists in Paper 2 (the scratch build has no undefined references): `thm:recovery:main`, `thm:split:shared`, `cor:absorb:nouniversal`, `lem:split:ville`, `def:teacher:instance`, `lem:teacher:coding`, `lem:kink:main`, `def:kink:kinks`, `rem:teacher:selected`, `sec:teacher`, `prop:recovery:beyond`, `thm:teacher:main`, `prop:limits:separable`, `prop:limits:rateblind`, `app:setup:facts`.

**`sections/imit.tex`** (`drafts/imit.tex`):

```latex
% Section "imitation" (draft of the imitation synthesis, research/tracks/imitation/notes-final.md §2; placement: after
% sec:limits, before sec:computable). Sources: research/tracks/imitation/robust/notes-final.md (Lemma 2.1, Thm 2.2,
% Props 3.1, 3.3, Setting 4.1, Lemmas 4.4-4.6, Thm 4.7(U),(vii), Cor 4.9, Props 4.10(a2),(c),(d), 4.11, Props 5.2, 5.3)
% with referee-A.md (A1, R1) and referee-B.md (B1-B3); imitation/notes-final.md §2 (B_beta conditioned on (h_0, mu) only;
% the proof of Thm 4.7(U) needs no symmetry of information). Local notation: Sigma (coin set; B is the truncation level of
% sec:teacher), rho (coin law; not a structure function), beta (coupling), W (cells), bar mu, P^*.
\section{Imitation: a sampler whose coins the environment drives}\label{sec:imit}

Imitation is one motivation for the first reason: a learner trained on a person's answers should return a copy of the person, a sampler with its own randomness. A sampler with some of its sampled bits stored is rejected per query (\cref{thm:recovery:main}). A system that predicts the answers by inferring, from the data seen so far, which person it faces is a single hypothesis only in a class whose hypotheses carry information across queries; there a Bayes mixture over persons that gives the person weight $w$ loses at most $\log(1/w)$ bits of fit to the person's own program on every data set, private coins or not, and so beats it at every $n$ once $\lambda$ times the length it saves exceeds $\log(1/w)$ (as in \cref{thm:split:shared}). The private-randomness class excludes such hypotheses by construction (\cref{cor:absorb:nouniversal}), not because of anything in the data, and a person with memory is not a product sampler. Here we treat hypotheses that predict the person's answers \emph{better} than the person's own kernel does, because the person's coins depend on the environment and they model the environment. Proofs are in \cref{app:imit}.

\begin{remark}[Private coins]\status{proved}\src{imitation/robust notes-final Lemma 2.1, Thm 2.2(2),(3); check r1; referee rb1}\label{rem:imit:private}
If, given its input, the person's answer is independent of everything a hypothesis may use (the earlier data and any variables of the environment, earlier or later), the argument of \cref{lem:split:ville} with this larger filtration shows that no predictor, however it models the environment, gains over the person more than its length plus a Ville deficiency $\delta^*$ with $\Prob[\delta^*\ge j]\le2^{-j}$ (\cref{app:imit:private}). For product hypotheses that also see an environment variable in a countable set, with i.i.d.\ pairs, none then predicts better in population, and \cref{thm:recovery:main} returns the person. This is the degenerate case: a hypothesis can only be lucky on a sample, at one bit of length per bit of luck.
\end{remark}

\begin{definition}[Environment-driven coins]\src{imitation/robust notes-final Setting 4.1 (B$_\beta$ conditioned on $(h_0,\mu)$ only, imitation/notes-final \S2.2); referee-B B1}\label{def:imit:setting}
Let $Y$ and the coin set $\Sigma$ be finite, $m\ge1$, and $W:=\{0,1\}^m$, the \emph{cells}.
(a) A \emph{channel} $\mu=(\mu(\cdot\mid w))_{w\in W}$ of finitely supported laws on inputs with rational masses gives the input law $\bar\mu:=2^{-m}\sum_w\mu(\cdot\mid w)$, with support $\supp\mu$; in the \emph{feature case} every input in $\supp\mu(\cdot\mid w)$ has $w$ as its first $m$ bits.
(b) The \emph{person} has a coin law $\rho$ on $\Sigma$, every $\rho(b)2^m$ a positive integer, and a response function $h:\supp\mu\times\Sigma\to Y$, injective in $b$; its kernel is $\nu_H(y\mid x):=\rho(b)$ if $y=h(x,b)$, and $0$ otherwise, and its \emph{model} is $h_0:=(h,\rho)$. A \emph{copy} is a program of $\Hcl{\times}$ whose kernel equals $\nu_H$ on $\supp\mu$; $\mathcal E$ is the set of copies, $\ell_0:=\min_{\mathcal E}\ell$, and $\pi_H$ is a shortest copy.
(c) A \emph{coupling} $\beta:W\to\Sigma$ of exact type $\rho$, $|\beta^{-1}(b)|=\rho(b)2^m$, drives the coins: at each query, independently, $w_i$ is uniform on $W$, $x_i\sim\mu(\cdot\mid w_i)$ and $y_i:=h(x_i,\beta(w_i))$. The learner sees $(x_i,y_i)$, i.i.d.\ from $\bar\mu\otimes P^*$ with $P^*(y\mid x):=\sum_w\mu(x\mid w)\ind[y=h(x,\beta(w))]/\sum_w\mu(x\mid w)$.
(d) $R(\pi):=\Ex[-\log\nu_\pi(y_i\mid x_i)]$, $J_c:=c\,\ell+R$ and $\Phi(c):=\inf_{\Hcl{\times}}J_c$; every copy has $R=H(\rho)$. $L_\beta:=\log\big(2^m!/\prod_b(\rho(b)2^m)!\big)$, $B_\beta:=K(\beta\mid h_0,\mu)$, $\delta_\beta:=L_\beta-B_\beta$, and $I_\beta(\pi):=B_\beta-K(\beta\mid h_0,\pi,\mu)$, the information of $\pi$ about the coupling. For a probability $P$ and a sub-probability $Q$, $D_{1/2}(P\Vert Q):=-2\log(1-\Hel(P,Q))$.
\end{definition}

So the person draws a coin at every query, but the coin it uses is a fixed function of the cell, which the learner sees in the input (the feature case) or only through the channel (a latent shared cause). The data identify $P^*$ (\cref{thm:recovery:main}); when the input carries information about the cell, hypotheses that model $\beta$ predict better than the person, by up to $H(\rho)$ bits per sample in the feature case, where $P^*$ is deterministic. The teacher of \cref{def:teacher:instance} is the feature case with $h(x,b)=f_a(x)\oplus b$, $\rho=\Bern(p)$ and $\beta=\ind_S$: systematic errors are environment-driven coins. As for error rules, $L_\beta\ge2^mH(\rho)-|\Sigma|\log(2^m+1)$ \citep{cover2006elements}, and $\Prob[\delta_\beta>j]<2^{-j}$ for a coupling drawn uniformly from its type class.

\begin{theorem}[Robust near-imitation]\status{proved}\src{imitation/robust notes-final Thm 4.7(U),(vii), Lemmas 4.4--4.6; referee-A A1; imitation/notes-final \S2.2 (re-derived); checks f7, s1(B),(C)}\label{thm:imit:main}
In the setting of \cref{def:imit:setting} let $c=a2^{-m}$ with $a>1$, $\epsilon\ge0$, and $G:=\ell_0+\delta_\beta+|\Sigma|\log(2^m+1)+\kappa$. Every $\pi\in\Hcl{\times}$ with $J_c(\pi)\le\Phi(c)+\epsilon$, whatever its internal structure, satisfies:
\begin{enumerate}[label=(\roman*),itemsep=0pt,topsep=2pt]
\item $\ell(\pi)\le\ell_0+(G+2^m\epsilon)/(a-1)$;
\item $-(aG+2^m\epsilon)/((a-1)2^m)\le R(\pi)-H(\rho)\le c\,\ell_0+\epsilon$: it predicts neither much better nor much worse than the person;
\item $I_\beta(\pi)\le\ell_0+(G+2^m\epsilon)/(a-1)+\kappa$;
\item with $E:=2\log\big(2^{m-1}(2H(\rho)+c\,\ell_0+\epsilon)+1\big)\le2m+2\log(2H(\rho)+c\,\ell_0+\epsilon+1)$,
\[
\Ex_{x\sim\bar\mu}D_{1/2}\big(\nu_H(\cdot\mid x)\,\Vert\,\nu_\pi(\cdot\mid x)\big)\ \le\ c\,\ell_0+\frac{2a}{a-1}\cdot\frac{G+E+\kappa}{2^m}+\frac{a+1}{a-1}\,\epsilon,
\]
so its Hellinger gap from the person, $\Ex_{x\sim\bar\mu}\Hel(\nu_H(\cdot\mid x),\nu_\pi(\cdot\mid x))$, is at most $\frac{\ln2}2$ times the right side.
\end{enumerate}
Moreover $J_c(\pi_H)\le\Phi(c)+G/2^m+c\,\ell_0$. In the feature case, if $|\Sigma|\ge2$ and the values of $\rho$ are distinct, a program of length at most $\ell_0+\lceil L_\beta\rceil+a_\rho+\kappa$, $a_\rho:=2\log(m+1)+2\log(|\Sigma|+1)+|\Sigma|(m+1)$, has kernel $P^*$ and risk $0$, and so beats every copy for $c<H(\rho)/(\lceil L_\beta\rceil+a_\rho+\kappa)$, a threshold at least $2^{-m}(1+(a_\rho+1+\kappa)/(2^mH(\rho)))^{-1}$.
\end{theorem}

\emph{Proof idea.} A program is a code for the coupling: $K(\beta\mid h_0,\pi,\mu)\le2^mR(\pi)+\kappa$ (\cref{lem:imit:coding}, which extends \cref{lem:teacher:coding}). With the size of the type class this gives the whole class a right line of slope $2^{-m}$ and offset $G/2^m$ at $(\ell_0,H(\rho))$, and \cref{lem:kink:main} with $\mathcal N=\emptyset$ gives (i), (ii) and the bound on $\Phi$. For (iv) a closeness lemma (\cref{lem:imit:closeness}) bounds the divergence by that of per-cell geometric means of the predictions, which define a semimeasure on couplings whose value at $\beta$ is too small unless the divergence is small or the program predicts better or knows more about $\beta$.

The best predictor has $\Ex_xD_{1/2}(\nu_H\Vert P^*)=H(\rho)$ in the feature case. So when the coupling is incompressible ($\delta_\beta\ll2^mH(\rho)$) and the person is much simpler than the coupling ($\ell_0+|\Sigma|m\ll2^mH(\rho)$, about the coupling's $L_\beta$ bits), for every $c$ between the reuse factor $2^{-m}$ and about $H(\rho)/\ell_0$, with $a$ bounded away from $1$, every near-optimal hypothesis is close to the person in behaviour, on the scale $H(\rho)$, and holds little of the coupling, although hypotheses that model the environment predict better. Below $2^{-m}$ the program that models the coupling wins; above about $H(\rho)/\ell_0$ the bound exceeds $H(\rho)$, and above about $(\log|Y|-H(\rho))/\ell_0$ a simpler, worse program can win, as above $c_{\rm hi}$ in \cref{sec:teacher}. The theorem gives near-copies, not copies: in $\Hcl{\times}$ nothing excludes a nearby coin law as the minimiser (cf.\ \cref{rem:teacher:selected}); and the hypotheses that predict better gain only by storing an incompressible table, while compact models of how the environment drives the person are the negative case of \cref{prop:imit:limits}(c). By \cref{prop:recovery:beyond}(c) with the sampler $P^*$, almost surely every $cn$-MAP satisfies (i)--(iv) with $\epsilon=0$ for all large $n$. For example, with $m=20$, $\epsilon=\delta_\beta=0$ and the machine constant set to $0$ (an illustration), a direct computation (code in the accompanying repository) gives at $c=2^{-19}$ the bound $6.2\cdot10^{-4}$ bits for a person who answers with a fair coin ($h(x,b)=b$, $\ell_0\le a_\rho<54$), against $H(\rho)=1$, and $9.5\cdot10^{-4}$ for the parity person of \cref{sec:teacher} ($\ell_0<120$), against $H(\rho)=0.0112$; at $c=10^{-4}$ the latter bound exceeds $H(\rho)$, and only \cref{thm:teacher:main} says more.

\begin{proposition}[What no procedure can do]\status{proved; computed}\src{imitation/robust notes-final Props 4.10(a2),(c),(d), 4.11; referee-A R1; checks f2(B), f8, s1(D); referee rb2(B),(C)}\label{prop:imit:limits}
\begin{enumerate}[label=(\alph*),itemsep=1pt,topsep=2pt]
\item \emph{One data law, at most one copy.} If worlds $W_1,\dots,W_N$ as in \cref{def:imit:setting} have one law of the data pairs and persons whose kernels differ pairwise on sets of positive $\bar\mu$-mass, then every procedure $\Psi$ (a measurable map from samples and independent randomness to programs) has $\sum_i\Prob_{W_i}[\Psi(h_n)\in\mathcal E(\nu_i)]\le1$ at every $n$. In the feature case with $|\Sigma|\ge2$, one such world has the person $P^*$, who responds to the cell.
\item \emph{A person entangled with its coupling.} Let $X=W$, $\mu(\cdot\mid w)=\delta_w$, $Y=\Sigma=\{0,1\}$, $\rho=\Bern(s_0/2^m)$ with $1\le s_0<2^{m-1}$, and let the person $H_f$ answer $f(w)\oplus b$ for a table $f:W\to\{0,1\}$. Draw $f$ uniformly and $\beta$ uniformly from its type class, independently. Then $\Prob[\delta_\beta>j]<2^{-j}$, yet every procedure copies the person with probability at most $2^{-L_\beta}$, at every $n$.
\item \emph{Cheap couplings.} In the feature case, with $|\Sigma|\ge2$ and the values of $\rho$ distinct, let $\pi_{\rm u}$, shorter than $\ell_0$, compute the uniform kernel on $Y$. If $H(\rho)/(K(\beta\mid\pi_H)+\kappa)\ge(\log|Y|-H(\rho))/(\ell_0-\ell(\pi_{\rm u}))$, then at every $c>0$ some program that is not a copy has $J_c$ at most that of every copy.
\end{enumerate}
\end{proposition}

\emph{Proof idea.} (a) The output has one law in all the worlds, and the sets of copies are disjoint. (b) The data depend on the world only through $f\oplus\ind_\beta$, which $\binom{2^m}{s_0}$ equally likely worlds with pairwise different persons share. (c) Compare a copy with the program of \cref{thm:imit:main} that computes $P^*$ and with $\pi_{\rm u}$ (\cref{app:imit:limits}).

So imitation data identify behaviour, not mechanism: persons with the same response function and coin law share a data law, however they compute them, and the selected program is a shortest one for the behaviour, which may compute it unlike the person and extrapolates off $\supp\bar\mu$ as that program does. Nor do they identify the split of $P^*$ into a person and an environment: every procedure adopts a convention, and the $c$-procedure adopts it by rate, as steeper selection does for error rules (\cref{prop:limits:separable}). An incompressible coupling is not enough: in (b) the person is as complex as its coupling and responds to the same cells, and a hypothesis such as $\ell_0\ll2^m$, or the left condition that list decoding gives in \cref{thm:teacher:main}, is needed. (c) is a form of rate blindness (\cref{prop:limits:rateblind}): if the person's apparent randomness has a short description, such as a pseudo-random generator with a short seed, no $c$ returns the person with fresh coins; and if that description is the person's own deterministic state, the program that models it is arguably the more faithful copy, so the target $\nu_H$ is itself a modelling choice. In the feature case the same comparison shows that a window for copies needs $2^m>(\ell_0-\ell(\pi_{\rm u}))/(\log|Y|-H(\rho))-(a_\rho+1+\kappa)/H(\rho)$ cells (\cref{app:imit:limits}): with the machine constant set to $0$ (an illustration), a person of $10^6$ bits with $H(\rho)=\frac12$ and $|Y|=2$ needs more than $1.99\cdot10^6$ incompressible cells.

\begin{question}[imitation]\status{open}\src{imitation/robust notes-final \S8 items 1, 2, 4, 6, 7}\label{q:imit:open}
(a) Is there a near-imitation theorem when the coin combines $\beta(w)$ with a private residual coin, or (b) when the cells have unequal masses? (c) Does \cref{thm:imit:main} hold for $cn$-MAPs at each finite $n$ with probability $1-\delta$, for every response function? (d) Is a coupling that is short to describe but slow to compute private randomness for a time-bounded class? (e) Can data other than imitation data, from several environments or from interventions, identify which structure belongs to the person?
\end{question}
```

**`sections/app-imit.tex`** (`drafts/app-imit.tex`):

```latex
% Appendix for sec:imit (draft of the imitation synthesis, research/tracks/imitation/notes-final.md §2; placement: after
% app-limits.tex). Sources: research/tracks/imitation/robust/notes-final.md Lemma 2.1, Lemmas 4.4-4.6, Thm 4.7(U),(vii),
% Props 4.10(a2),(c),(d), 4.11, Prop 5.2; referee-A.md A1, R1; imitation/notes-final.md §2.2 (B_beta := K(beta | h_0, mu)).
\section{Proofs for \texorpdfstring{\cref{sec:imit}}{Section \ref*{sec:imit}} (imitation)}\label{app:imit}

The setting is \cref{def:imit:setting}, and (F1)--(F5) are the facts of \cref{app:setup:facts}; we use them relative to a condition such as $(h_0,\mu)$, whose proofs are the unconditional ones, uniformly in the condition \citep{li2008introduction}. The channel $\mu$ is a finite object from which $m$, $W$ and $\supp\mu$ are computable.

\subsection{Private coins}\label{app:imit:private}

Let $\mathcal A_1\subseteq\mathcal A_2\subseteq\cdots$ be $\sigma$-algebras, $x_i$ being $\mathcal A_i$-measurable and $y_i$ being $\mathcal A_{i+1}$-measurable, that contain whatever a hypothesis may use to predict $y_i$, and let the coins be private: $\Prob[y_i=y\mid\mathcal A_i]=\nu_H(y\mid x_i)$ almost surely. A \emph{predictor} $\pi$ assigns to each $i$ an $\mathcal A_i$-measurable sub-probability $q_{\pi,i}$ on $Y$, with fit $L_n(\pi):=-\sum_{i\le n}\log q_{\pi,i}(y_i)$. The claim of \cref{rem:imit:private} is: for every countable family of predictors with $\sum_\pi2^{-\ell(\pi)}\le1$, $\delta^*:=\sup_n\log\sum_\pi2^{-\ell(\pi)+L_n(\nu_H)-L_n(\pi)}$ has $\Prob[\delta^*\ge j]\le2^{-j}$, and $L_n(\pi)\ge L_n(\nu_H)-\ell(\pi)-\delta^*$ for all $\pi$ and $n$.

\begin{proof}[Proof of the claim]
Almost surely $\nu_H(y_i\mid x_i)>0$ for all $i$, so $M_n:=\sum_\pi2^{-\ell(\pi)}\prod_{i\le n}q_{\pi,i}(y_i)/\nu_H(y_i\mid x_i)$ is well defined and $\mathcal A_{n+1}$-measurable, with $M_0\le1$. By privacy and monotone convergence, $\Ex[M_{n+1}\mid\mathcal A_{n+1}]=\sum_\pi2^{-\ell(\pi)}\prod_{i\le n}\frac{q_{\pi,i}(y_i)}{\nu_H(y_i\mid x_i)}\sum_{y:\nu_H(y\mid x_{n+1})>0}q_{\pi,n+1}(y)\le M_n$. So $(M_n)$ is a nonnegative supermartingale, and Ville's inequality \citep{ville1939etude} gives $\Prob[\sup_nM_n\ge2^j]\le2^{-j}$; put $\delta^*:=\sup_n\log M_n$. Keeping one term, $2^{-\ell(\pi)}2^{L_n(\nu_H)-L_n(\pi)}\le M_n\le2^{\delta^*}$. For product hypotheses on i.i.d.\ pairs $(x_i,z_i)$, privacy gives $R(\pi)-R(\pi_H)=\Ex_{x,z}\KL(\nu_H(\cdot\mid x)\Vert\nu_\pi(\cdot\mid x,z))\ge0$, and the triples are per-query data on the input set of pairs with the sampler $\nu_H(y\mid x)$, to which \cref{thm:recovery:main} applies.
\end{proof}

\subsection{The coding and closeness lemmas}\label{app:imit:lemmas}

\begin{lemma}[Coding the coupling with a hypothesis]\status{proved}\src{imitation/robust notes-final Lemma 4.4; checks r6(A), s1(B); referee rb2(A)}\label{lem:imit:coding}
For every $\pi\in\Hcl{\times}$, $K(\beta\mid h_0,\pi,\mu)\le2^mR(\pi)+\kappa$.
\end{lemma}

\begin{proof}
For $w\in W$ and $b\in\Sigma$ put $q_w(b):=\sum_x\mu(x\mid w)\,\nu_\pi(h(x,b)\mid x)$, a finite sum, lower semicomputable from $(\pi,h_0,\mu)$. Since $h(x,\cdot)$ is injective, $\sum_bq_w(b)\le\sum_x\mu(x\mid w)\sum_y\nu_\pi(y\mid x)\le1$, so $Q(\beta'):=\prod_wq_w(\beta'(w))$ is a semimeasure on $\Sigma^W$, and (F2) gives $K(\beta\mid h_0,\pi,\mu)\le-\log Q(\beta)+\kappa$. By Jensen's inequality for the convex function $-\log$,
\begin{align*}
-\log Q(\beta)&=\sum_w-\log\Ex_{x\sim\mu(\cdot\mid w)}\nu_\pi(h(x,\beta(w))\mid x)\\
&\le\sum_w\Ex_{x\sim\mu(\cdot\mid w)}\big[-\log\nu_\pi(h(x,\beta(w))\mid x)\big]=2^mR(\pi).\qedhere
\end{align*}
\end{proof}

For a program $\pi$ put
\[
\tilde q_w(b):=\prod_x\nu_\pi(h(x,b)\mid x)^{\mu(x\mid w)},\qquad\bar D(\pi):=2^{-m}\sum_wD_{1/2}(\rho\Vert\tilde q_w)
\]
and $E(\pi):=2\log\big(2^{m-1}(H(\rho)+R(\pi))+1\big)$. Here $\tilde q_w(b)$ is the geometric mean, over the inputs of cell $w$, of the probability that $\pi$ gives to the answer of coin $b$.

\begin{lemma}[Closeness]\status{proved}\src{imitation/robust notes-final Lemma 4.6; imitation/notes-final \S2.2 (proof checked line by line); checks f7(A),(B), s1(B),(C)}\label{lem:imit:closeness}
For every $\pi\in\Hcl{\times}$ with $R(\pi)<\infty$,
\begin{align*}
\Ex_{x\sim\bar\mu}D_{1/2}\big(\nu_H(\cdot\mid x)\Vert\nu_\pi(\cdot\mid x)\big)&\le\bar D(\pi)\\
&\le R(\pi)-H(\rho)+\frac{2\big(I_\beta(\pi)+\delta_\beta+|\Sigma|\log(2^m+1)+E(\pi)+\kappa\big)}{2^m}.
\end{align*}
\end{lemma}

\begin{proof}
\emph{Hölder.} Fix $w$. The generalised Hölder inequality $\sum_b\prod_xf_x(b)^{\theta_x}\le\prod_x\big(\sum_bf_x(b)\big)^{\theta_x}$, for $f_x\ge0$, $\theta_x\ge0$ and $\sum_x\theta_x=1$, with $\theta_x:=\mu(x\mid w)$ and $f_x(b):=\sqrt{\rho(b)\nu_\pi(h(x,b)\mid x)}$, gives $\sum_b\sqrt{\rho(b)\tilde q_w(b)}\le\prod_x\big(\sum_b\sqrt{\rho(b)\nu_\pi(h(x,b)\mid x)}\big)^{\mu(x\mid w)}$. By injectivity, $\sum_b\sqrt{\rho(b)\nu_\pi(h(x,b)\mid x)}=\sum_y\sqrt{\nu_H(y\mid x)\nu_\pi(y\mid x)}$. Taking $-2\log$ gives $D_{1/2}(\rho\Vert\tilde q_w)\ge\Ex_{x\sim\mu(\cdot\mid w)}D_{1/2}(\nu_H(\cdot\mid x)\Vert\nu_\pi(\cdot\mid x))$; average over $w$.

\emph{A semimeasure.} $\tilde q_w(b)\le q_w(b)$ (geometric against arithmetic mean), so $\sum_b\tilde q_w(b)\le1$ and, by the Cauchy--Schwarz inequality, $Z_w:=\sum_b\sqrt{\rho(b)\tilde q_w(b)}\le1$. So $Q(\beta'):=\prod_w\sqrt{\rho(\beta'(w))\,\tilde q_w(\beta'(w))}$ has total mass $Z:=\prod_wZ_w\le1$ on $\Sigma^W$, and it is lower semicomputable from $(\pi,h_0,\mu)$. As $R(\pi)<\infty$, $Z\ge Q(\beta)>0$.

\emph{Normalising.} Let $k:=\lfloor-\log Z\rfloor\ge0$. Then $2^kQ$ is a semimeasure, lower semicomputable from $(\pi,h_0,\mu,k)$ (trimmed as usual, so that every value of the condition gives a semimeasure; for the true $k$ nothing is trimmed), and (F2), (F3), (F5) give
\[
K(\beta\mid h_0,\pi,\mu)\le-\log Q(\beta)-k+K(k)+\kappa\le-\log Q(\beta)+\log Z+1+2\log(k+1)+\kappa .
\]

\emph{Evaluating.} Exact type gives $\sum_w\log(1/\rho(\beta(w)))=2^mH(\rho)$, and the definition of $R$ gives $\sum_w-\log\tilde q_w(\beta(w))=2^mR(\pi)$. So $-\log Q(\beta)=2^{m-1}(H(\rho)+R(\pi))$ and $\log Z=-2^{m-1}\bar D(\pi)$; and $k\le-\log Z\le-\log Q(\beta)$, so $2\log(k+1)\le E(\pi)$.

\emph{Lower bound.} $K(\beta\mid h_0,\pi,\mu)=B_\beta-I_\beta(\pi)=L_\beta-\delta_\beta-I_\beta(\pi)\ge2^mH(\rho)-|\Sigma|\log(2^m+1)-\delta_\beta-I_\beta(\pi)$. Combine with the two previous steps and divide by $2^{m-1}$.
\end{proof}

\subsection{Proof of \texorpdfstring{\cref{thm:imit:main}}{the near-imitation theorem}}\label{app:imit:main}

\emph{The right line.} For every $\pi\in\Hcl{\times}$, (F3), (F1) and \cref{lem:imit:coding} give $B_\beta\le\ell(\pi)+K(\beta\mid h_0,\pi,\mu)+\kappa\le\ell(\pi)+2^mR(\pi)+\kappa$. With $B_\beta=L_\beta-\delta_\beta\ge2^mH(\rho)-|\Sigma|\log(2^m+1)-\delta_\beta$ and $G=\ell_0+\delta_\beta+|\Sigma|\log(2^m+1)+\kappa$,
\[
R(\pi)\ \ge\ H(\rho)-\frac G{2^m}-2^{-m}\big(\ell(\pi)-\ell_0\big)\qquad\text{for every }\pi\in\Hcl{\times}:
\]
in the population reading of \cref{def:kink:kinks}, with the reference point $(\ell_0,H(\rho))$, bounded by $\pi_H$, the whole class has the right line $(2^{-m},G/2^m)$ with length floor $0$. Similarly $I_\beta(\pi)=B_\beta-K(\beta\mid h_0,\pi,\mu)\le\ell(\pi)+\kappa$.

\emph{(i)--(iv) and the bound on $\Phi$.} Apply \cref{lem:kink:main} with $L=L'=R$, $\mathcal M$ the whole class, $\mathcal N=\emptyset$ (so $\eta_{\mathcal N}=+\infty$), $\tau=2^{-m}<c$, $g=G/2^m\ge0$ and $\ell_{\mathcal M}=0$; then $c-\tau=(a-1)2^{-m}$ and $\Delta(c)=G/2^m+(c-2^{-m})\ell_0$. A program with $J_c(\pi)\le\Phi(c)+\epsilon$ has $J_c(\pi)\le J_c(\pi_H)+\epsilon$. \Cref{lem:kink:main}(ii) gives $\ell(\pi)\le\ell_0+(g+\epsilon)/(c-\tau)$, which is (i), and $R(\pi)\ge H(\rho)-(cg+\tau\epsilon)/(c-\tau)$, the left side of (ii); \cref{lem:kink:main}(iv) gives $R(\pi)\le H(\rho)+\epsilon+c\,\ell_0$, the right side; and \cref{lem:kink:main}(i) gives $\Phi(c)\ge J_c(\pi_H)-\Delta(c)\ge J_c(\pi_H)-G/2^m-c\,\ell_0$. (iii) is $I_\beta(\pi)\le\ell(\pi)+\kappa$ with (i). For (iv), \cref{lem:imit:closeness} applies, as $R(\pi)<\infty$; insert the right side of (ii), which also gives $E(\pi)\le E$, and (iii):
\[
\bar D(\pi)\le c\,\ell_0+\epsilon+\frac2{2^m}\Big[\ell_0+\frac{G+2^m\epsilon}{a-1}+\delta_\beta+|\Sigma|\log(2^m+1)+E+2\kappa\Big].
\]
Since $\ell_0+\delta_\beta+|\Sigma|\log(2^m+1)+\kappa=G$, $2+\frac2{a-1}=\frac{2a}{a-1}$ and $1+\frac2{a-1}=\frac{a+1}{a-1}$, this is at most the bound in (iv). Finally $D_{1/2}=-2\log(1-\Hel)\ge2\Hel/\ln2$.

\emph{The program with kernel $P^*$.} It reads a self-delimiting description of $m$, $|\Sigma|$ and the numerators $\rho(b)2^m\le2^m$ ($a_\rho$ bits), then the index of $\beta$ among the couplings of type $\rho$, in $\lceil L_\beta\rceil$ bits, a length computable from what it has read, then $\pi_H$. On an input $x$ with first $m$ bits $w$ it computes $\nu_{\pi_H}(\cdot\mid x)$ exactly: the values are multiples of $2^{-m}$ that sum to $1$ for $x\in\supp\mu$, so the program waits until the lower approximations sum to more than $1-2^{-m}$ and rounds each up to a multiple of $2^{-m}$. The label of mass $\rho(\beta(w))$ is $h(x,\beta(w))$, since the values of $\rho$ are distinct and $h(x,\cdot)$ is injective, and the program gives it probability $1$; where the search does not end it gives nothing, which keeps a semimeasure. So its kernel is $P^*$ on $\supp\mu$, and its risk is $0$. It has smaller $J_c$ than $\pi_H$, hence than every copy, iff $c(\lceil L_\beta\rceil+a_\rho+\kappa)<H(\rho)$; and $\lceil L_\beta\rceil\le2^mH(\rho)+1$. \qed

\subsection{Proof of \texorpdfstring{\cref{prop:imit:limits}}{the limits of imitation}}\label{app:imit:limits}

\emph{(a).} In every $W_i$ the sample $h_n$ has the same law, so $\Psi(h_n)$ has the same law. A program in $\mathcal E(\nu_i)\cap\mathcal E(\nu_j)$ would have $\nu_i=\nu_j$ $\bar\mu$-almost everywhere, so the events are disjoint. In the feature case, the world with $\Sigma=\{\ast\}$, $\rho(\ast)=1$ and the response $h'(x,\ast):=h(x,\beta(w))$, $w$ the first $m$ bits of $x$, has the same channel and the data law $\bar\mu\otimes P^*$, and its person's kernel $P^*$ is deterministic, while $\nu_H$ is not at any input when $|\Sigma|\ge2$.

\emph{(b).} Conditional on $f$, hence on $h_0$ and $\mu$, $\beta$ is uniform on its type class, and fewer than $2^{L_\beta-j}$ programs are shorter than $L_\beta-j$; so $\Prob[\delta_\beta>j]<2^{-j}$. The map $(f,\beta)\mapsto(T,\beta)$, $T:=f\oplus\ind_\beta$, is a bijection, so $T$ is uniform and independent of $\beta$, and the data, $(w_i,T(w_i))$ with $w_i$ uniform, depend on the world only through $T$. Fix $T$, the $w_i$ and the randomness of $\Psi$; then $\Psi$ outputs one program $\psi$. The kernels of the persons $H_{T\oplus\ind_{\beta'}}$ for distinct $\beta'$ differ at every cell of the symmetric difference, each of mass $2^{-m}$, because $s_0\ne2^{m-1}$; so $\psi$ copies the person for at most one $\beta'$, and given $T$ each $\beta'$ has probability $\binom{2^m}{s_0}^{-1}$. Average over the conditioning.

\emph{No window in (b).} Moreover, with probability at least $1-2^{-j}$ over $f$, if $H(p)\,(2^m-j-2\log(m+1)-2\kappa)>(1-H(p))\,(j+4\log(m+1)+2\kappa)$ with $p:=s_0/2^m$, then at every $c>0$ the deterministic table $f\oplus\ind_\beta$ or the fair coin has smaller $J_c$ than every copy. Indeed, from a copy $\pi$ the table $f$ is computable given $m$ ($f(w)$ is the label whose lower approximations of $\nu_\pi(\cdot\mid w)$ eventually exceed $\frac12$, as $p<\frac12$), so $K(f)\le\ell(\pi)+2\log(m+1)+\kappa$; and $\Prob_f[K(f)<2^m-j]<2^{-j}$. The deterministic program for $T$ reads $m$ self-delimitingly and then $2^m$ bits, and has risk $0$; the fair coin has length at most $\kappa$ and risk $1$. So, with probability at least $1-2^{-j}$, every copy has $J_c$ larger than the table's for $c<H(p)/(j+4\log(m+1)+2\kappa)$ and larger than the coin's for $c>(1-H(p))/(2^m-j-2\log(m+1)-2\kappa)$, and the stated condition makes these two ranges cover every $c>0$.

\emph{(c).} As in the last part of the proof of \cref{thm:imit:main}, a program that reads $\pi_H$ and then a shortest description of $\beta$ given $\pi_H$ computes $m$ and $\rho$ from $\beta$ and has kernel $P^*$ on $\supp\mu$, risk $0$ and length $\ell_A\le\ell_0+K(\beta\mid\pi_H)+\kappa$. If $c\le H(\rho)/(K(\beta\mid\pi_H)+\kappa)$, it has $J_c\le c\,\ell_0+H(\rho)=J_c(\pi_H)$. Otherwise $c>(\log|Y|-H(\rho))/(\ell_0-\ell(\pi_{\rm u}))$ by the hypothesis, and $J_c(\pi_{\rm u})=c\,\ell(\pi_{\rm u})+\log|Y|<J_c(\pi_H)$. Neither program is a copy: the first is deterministic, and the second is shorter than $\ell_0$. Every copy has $J_c\ge J_c(\pi_H)$. The bound $K(\beta\mid\pi_H)\le K(\beta)+\kappa$ is (F3).

\emph{The cell count.} In the feature case, with $|\Sigma|\ge2$ and the values of $\rho$ distinct, suppose some $c$ makes the copies the only minimisers of $J_c$. By the last part of \cref{thm:imit:main} the copies are not minimisers for $c<H(\rho)/(\lceil L_\beta\rceil+a_\rho+\kappa)$, and by the comparison with $\pi_{\rm u}$ in (c) they are not the only minimisers for $c\ge(\log|Y|-H(\rho))/(\ell_0-\ell(\pi_{\rm u}))$. So $H(\rho)(\ell_0-\ell(\pi_{\rm u}))<(\log|Y|-H(\rho))(\lceil L_\beta\rceil+a_\rho+\kappa)$; inserting $\lceil L_\beta\rceil\le2^mH(\rho)+1$ and dividing by $H(\rho)(\log|Y|-H(\rho))$ gives $2^m>(\ell_0-\ell(\pi_{\rm u}))/(\log|Y|-H(\rho))-(a_\rho+1+\kappa)/H(\rho)$. \qed
```

---

## 3. The weight-decay remark

### 3.1 Assessment of the decay record

* The record makes the author's first bullet precise, and both its referee issues (M1, M2) and the ten minor ones were fixed before this synthesis [proved, refereed: `decay` §0.1].
* What is proved: $\lambda=cn$ charges the prior factor once per sample; a fixed λ is a fixed prior; no fixed prior with full support gives the $cn$-MAPs on all samples, and in some classes no fixed prior at all does; per query, for $c>c^*$ the $cn$-MAPs end at shorter, worse programs while every summable prior that charges the sampler's programs ends at them; the teacher window is an instance outside a band of relative width at most 1.2 % above $2^{-m}$ at the example's sizes [proved: `decay` Props 1.1–3.2; computed: d1, d3, rd1, s1(E)].
* Weight decay: coupled decay on an averaged loss is MAP under a Gaussian prior of precision $n\omega$; the limit can classify worse, with a closed-form threshold ω* in a two-feature logistic toy, and the $\ell_\infty$ box of AdamW switches where $L_2$ decay never does [proved: `decay` Props 4.1, 4.2, Example 4.3; computed: d2, d3(D), s1(E)].
* The analogy is one of objectives, and its limits are stated: a norm is not a code length, iterates are not minimisers, decoupled decay is a different objective, decay acts per step [known: abstract level, §3.4].
* The reading of the author's "as the number of params varies" as "as the sample size varies" is the brief's; under the other reading the conclusion is the same (`decay` header) [remark; to confirm with the author].

### 3.2 Where it goes

1. **The teacher thread's schedule discussion**: the main-text remark `rem:teacher:weightdecay` directly after `rem:limits:schedule` in `teacher.tex` (`drafts/teacher.diff`). In the scratch build it is on p. 26.
2. **Appendix**: the subsection `app:teacher:weightdecay` with `prop:teacher:nofixedprior` and `ex:teacher:weightdecay`, in `app-teacher.tex` **before** `\subsection{Charging the information about the rule}` (`drafts/app-teacher.diff`), not at the end of the file as the decay record proposed: appended after `tab:teacher:rates`, it pushed that float and, through the float queue, `tab:intro:claims` and `tab:teacher:numbers`, to the last pages of the scratch build.
3. **Related work**: one sentence after the label `rem:related:cold` (`drafts/related.diff`).
4. **Discussion**: one sentence in "The window and its price" (`drafts/discussion.diff`), new in this synthesis.

### 3.3 Final text

**Changes from the decay record's draft** (`decay` §6):
* The remark no longer quotes "1.2 %" (a κ-dependent number) in the main text: "outside a thin band just above $2^{-m}$"; the number stays in the appendix with "with the machine constant set to 0 or 30 (an illustration)" and "a direct computation (code in the accompanying repository)" (DECISIONS §A9).
* "coding weights needs a precision \citep{hinton1993keeping}" becomes "the information in a weight depends on its precision, which \citet{hinton1993keeping} control by adding Gaussian noise", the decay referee's more faithful wording of the abstract.
* "Weight decay \citep{krogh1992simple} has the same form": the brief names Krogh and Hertz as the classic reference; the citation supports only that weight decay is a standard regulariser (abstract level).
* The second paragraph ends by pointing to `thm:imit:main` (the same per-sample threshold keeps the near-copies).
* The AdamW thresholds are quoted as $0.1028$ and $0.8222$ "to four digits"; the draft's "$\lambda\ge0.103$" rounded the threshold up past its value $0.10278$ [computed: d3(D1), s1(E)].

**Main-text remark** (`drafts/wd-remark.tex`), for `teacher.tex` after `rem:limits:schedule`:

```latex
\begin{remark}[$\lambda=cn$ and weight decay]\status{proved; computed; known}\src{imitation/decay notes-final \S\S1--4 (Props 2.1--2.3, 3.2, 4.1, 4.2, Example 4.3); checks d1, d2, d3; imitation/notes-final \S3}\label{rem:teacher:weightdecay}
With $\lambda=cn$ the length is charged once per sample: $2^{-cn\ell(\pi)}\nu_\pi(h_n)=\prod_{i\le n}2^{-c\ell(\pi)}\nu_\pi(y_i\mid x_i)$. A fixed $\lambda$ is Bayes' rule with the fixed prior $2^{-\lambda\ell}$, but no fixed prior with full support gives the $cn$-MAPs at every $n$: the $cn$-MAPs depend on the sample only through its empirical distribution, whereas under such a prior a program that fits a sample worse than another stops being a MAP once the sample is repeated often enough, and in $\Hcl{\times}$, for every $c>0$, some samples have only such $cn$-MAPs. Per query, for $c>c^*$ the $cn$-MAPs end at shorter programs that predict worse, whereas the MAPs of every summable prior that charges $\mathcal E$ end in $\mathcal E$ (\cref{prop:teacher:nofixedprior}). The window of \cref{thm:teacher:main}, outside a thin band just above $2^{-m}$, is an instance: there the $cn$-MAPs eventually do not reproduce the teacher's labels, while every summable prior that charges a program reproducing them eventually selects such a program.

Weight decay \citep{krogh1992simple} has the same form. With the loss averaged over $n$ samples, gradient descent with weight-decay coefficient $\omega$ descends $\hat L_n(\theta)+\frac\omega2\|\theta\|^2$, and, for the log loss, $n$ times this is, up to a constant, the negative log posterior under a Gaussian prior \citep{mackay1992practical} with precision $n\omega$, which grows linearly in $n$ like the exponent of $2^{-cn\ell}$; a fixed prior needs $\omega\propto1/n$. In the limit, for a differentiable population loss $L$, the minimiser of $L(\theta)+\frac\omega2\|\theta\|^2$ minimises $L$ only if $\theta=0$ does, and it can classify worse (\cref{ex:teacher:weightdecay}). In both cases the penalty per sample does not vanish with the data. Discarding a component whose risk reduction per unit of complexity is small requires this (\cref{prop:limits:separable}): every $\lambda_n=o(n)$ eventually learns the errors (\cref{prop:teacher:schedules}(a)), and the same per-sample threshold keeps the near-copies of \cref{thm:imit:main}.

The analogy is one of objectives. $\|\theta\|^2$ is not a description length: the information in a weight depends on its precision, which \citet{hinton1993keeping} control by adding Gaussian noise, and with normalisation layers the norm mainly sets the effective learning rate \citep{vanlaarhoven2017l2}. Stochastic gradient iterates are not minimisers \citep{mandt2017stochastic}; decoupled weight decay in adaptive optimisers is not an $L_2$ penalty \citep{loshchilov2019decoupled,xie2024implicit}; and the decay acts per step, so before convergence its effect depends on the learning rate and the number of steps. Grokking \citep{power2022grokking,liu2022towards} has been related to the weight norm and to weight decay \citep{liu2023omnigrok}, and analysed as memorisation followed by a cleanup that removes memorising components \citep{nanda2023progress}.
\end{remark}
```

**Appendix subsection** (`drafts/wd-appendix.tex`), for `app-teacher.tex` before `app:teacher:rates`:

```latex
\subsection{\texorpdfstring{$\lambda=cn$}{lambda=cn} and weight decay}\label{app:teacher:weightdecay}

A \emph{fixed prior} is a map $w$ from programs to $[0,\infty)$ chosen before the data; its MAPs on a per-query sample $h$ maximise $w(\pi)\nu_\pi(h)$. For $\lambda\ge1$ the $\lambda$-MAPs are the MAPs of the fixed prior $2^{-\lambda\ell}$. Write $h^r$ for the sample $h$ repeated $r$ times.

\begin{proposition}[No fixed prior gives the $cn$-MAPs]\status{proved; computed}\src{imitation/decay notes-final Props 2.1--2.3, 3.2; checks d1, d3}\label{prop:teacher:nofixedprior}
Let $c>0$, and let the class be countable, with Kraft weights and kernels, as in \cref{def:split:setting}.
\begin{enumerate}[label=(\roman*),itemsep=0pt,topsep=2pt]
\item If samples $h$ and $h'$ of sizes $n$ and $n'$ have the same empirical distribution, the $cn$-MAPs of $h$ are the $cn'$-MAPs of $h'$.
\item Let $h$ have size $n_0$, let $\pi^*$ attain $P^*:=\max_\pi\nu_\pi(h)>0$, and let no $cn_0$-MAP of $h$ attain $P^*$. If $w(\pi^*)>0$, then for every $r>\max_{\hat\pi}\log\frac{w(\hat\pi)}{w(\pi^*)}\big/\log\frac{P^*}{\nu_{\hat\pi}(h)}$, the maximum over the $cn_0$-MAPs $\hat\pi$ of $h$ with $w(\hat\pi)>0$ (and every $r\ge1$ if there are none), no $crn_0$-MAP of $h^r$ is a MAP of $w$ on $h^r$. So no fixed prior with full support gives the $cn$-MAPs on all samples; nor does any fixed prior if $\pi^*$ is a $cn$-MAP of some sample whose $cn$-MAPs are not all programs. In $\Hcl{\times}$ samples as in (ii) exist for every $c>0$.
\item Per query, let $\mathcal E\ne\emptyset$ and let $w$ be summable with $w(\pi)>0$ for some $\pi\in\mathcal E$. Almost surely, for all large $n$, the MAPs of $w$ are the programs of $\mathcal E$ of largest weight. If $c>c^*$ (\cref{prop:recovery:beyond}), almost surely for all large $n$ no $cn$-MAP lies in $\mathcal E$, and every minimiser $\pi$ of $c\,\ell+R_\nu$ has $\ell(\pi)<\ell_0$ and $R_\nu(\pi)>R_\nu(\pi_0)$ for $\pi_0\in\mathcal E_0$. If $c<c^*$, the $cn$-MAPs and the MAPs of $2^{-\ell}$ are both eventually $\mathcal E_0$.
\item In the instance of \cref{def:teacher:instance}, with PQ data $\nu=\delta_{y^*}$, inputs uniform on $\{0,1\}^d$ and $B=\infty$, let $c_+:=H(p)/(B_S-4-\Lambda_1-\kappa_g)$, the denominator being positive. Every $c\in(\max\{2^{-m},c_+\},c_{\rm hi})$ has $c>c^*$.
\end{enumerate}
\end{proposition}

\begin{proof}
(i) $J_{cn}(\pi;h)/n=c\,\ell(\pi)+\Ex_{\hat P_h}[-\log\nu_\pi(y\mid x)]$ depends on $h$ only through its empirical distribution $\hat P_h$. (ii) By (i) the $crn_0$-MAPs of $h^r$ are the $cn_0$-MAPs $\hat\pi$ of $h$; they are finitely many (\cref{lem:setup:basic}), with $0<\nu_{\hat\pi}(h)<P^*$, and $w(\hat\pi)\nu_{\hat\pi}(h)^r<w(\pi^*)(P^*)^r$ for the stated $r$. A prior $w$ whose MAPs on the sample where $\pi^*$ is a $cn$-MAP are these $cn$-MAPs has $w(\pi^*)>0$: otherwise every program would have score $0$ there and be a MAP. In $\Hcl{\times}$ take $n_0$ distinct inputs whose labels $y$ have $K(y\mid\dom D)\ge n_0\log|Y|$, which exist by Kraft's inequality, with $n_0\log|Y|-\kappa-\ell_{\rm u}>\log|Y|/c$, where $\ell_{\rm u}$ is the length of a program for the uniform kernel: a lookup program attains $P^*=1$, and by \cref{lem:setup:coding} every program of likelihood $1$ has $J_{cn_0}\ge cn_0(n_0\log|Y|-\kappa)>cn_0\ell_{\rm u}+n_0\log|Y|$, the uniform kernel's value. (iii) Let $W:=\max_{\mathcal E}w$. Almost surely $\nu_\pi(h_n)=\nu(h_n)>0$ for all $\pi\in\mathcal E$ and all $n$, so a MAP $\hat\pi$ of $w$ has $w(\hat\pi)\Lambda_n(\hat\pi)\ge W$. For a cofinite set $T$ of programs, $\sum_{\pi\in T}w(\pi)\Lambda_n(\pi)$ is a nonnegative supermartingale started at $w(T)$ (\cref{lem:recovery:ratios}(a)), so by Ville's inequality some MAP lies in $T$ at some $n$ with probability at most $w(T)/W$, which tends to $0$ along cofinite sets decreasing to $\emptyset$. Of the finitely many other programs, those outside $\mathcal E$ have $\Lambda_n\to0$ almost surely (\cref{lem:recovery:ratios}(c)), and those of $\mathcal E$ with $w<W$ are never MAPs. For $c>c^*$ some $\pi'$ with $\ell(\pi')<\ell_0$ has $J_c(\pi')<J_c(\pi_0)\le J_c(\pi)$ for all $\pi\in\mathcal E$, and $J_c(\pi)>J_c(\pi_0)$ for $\pi\notin\mathcal E$ with $\ell(\pi)\ge\ell_0$; so the minimisers of $J_c$ are shorter than $\ell_0$ and lie outside $\mathcal E$, where $\KL_\mu>0$, and \cref{prop:recovery:beyond}(c) puts every $cn$-MAP among them for all large $n$. For $c<c^*$ use \cref{prop:recovery:beyond}(c) and the first part with $w=2^{-\ell}$. (iv) Here $\mathcal E$ is the set of programs with $R=0$; it contains the memoriser. Let $\pi$ minimise $J_c$, so $J_c(\pi)=\Phi(c)$. As $c2^m>1$ and $J_g(c)<\Phi_2(c)$ on $(0,c_{\rm hi})$, \cref{thm:teacher:main}(ii)(b) with $\epsilon=0$ gives $R(\pi)\ge H(p)-c\Lambda_2/(c2^m-1)$, which is positive for $c>c_+$ because $2^mH(p)-\Lambda_2=B_S-4-\Lambda_1-\kappa_g$. So no minimiser of $J_c$ lies in $\mathcal E$. For $c<c^*$ the minimisers are $\mathcal E_0$ (\cref{prop:recovery:beyond}(c)); at $c=c^*$ the programs of $\mathcal E_0$ are minimisers, since $J_c(\pi)-J_c(\pi_0)=\KL_\mu(\pi)-c^*(\ell_0-\ell(\pi))\ge0$ when $\ell(\pi)<\ell_0$. Hence $c>c^*$.
\end{proof}

Full support cannot be dropped from (ii) in general: in the class of a coin of length $1$ and a deterministic $f$ of length $1+k$, for $ck>1$ the coin is the only $cn$-MAP on every sample, and it is also the only MAP of the prior concentrated on it. With two programs that give the label $1$ probability $\frac12$ and $\frac14$ at every input, of lengths $1$ and $1+k$, the last clause of (ii) applies for every $0<ck<\log\frac32$, and a direct computation (code in the accompanying repository) finds at $ck=0.3$ no fixed prior whose MAPs are the $cn$-MAPs even on the samples of size at most $4$. At the example's sizes, with the machine constant set to $0$ or $30$ (an illustration) and $\delta_S\in\{0,20\}$, a direct computation (code in the accompanying repository) puts $c_+$ between $1.0044\cdot2^{-m}$ and $1.0115\cdot2^{-m}$.

\emph{Weight decay.} For a per-sample loss $f(\theta;z)$ let $\hat L_n:=\frac1n\sum_{i\le n}f(\cdot\,;z_i)$ and $L:=\Ex f(\cdot\,;z)$. A step $\theta\leftarrow\theta-\eta(\nabla\hat L_B(\theta)+\omega\theta)$ on a uniformly drawn minibatch $B$ is a stochastic gradient step on $F_n:=\hat L_n+\frac\omega2\|\theta\|^2$; with full batches its fixed points are the stationary points of $F_n$, for every $\eta$. If $f=-\ln p_\theta(y\mid x)$, then $nF_n(\theta)=-\ln\big(p_\theta(y_{1:n}\mid x_{1:n})\,e^{-n\omega\|\theta\|^2/2}\big)$. As in (i), the minimisers of $F_n$ depend on the sample only through its empirical distribution. If $\theta^*$ minimises $F:=L+\frac\omega2\|\theta\|^2$ and $L$ is differentiable, then $\nabla L(\theta^*)=-\omega\theta^*$, so $\theta^*$ is a stationary point of $L$ only if $\theta^*=0$; and $L(\theta^*)-L(\theta)\le\frac\omega2(\|\theta\|^2-\|\theta^*\|^2)$ for every $\theta$, the analogue of $R_\nu(\pi_c)-R_\nu(\pi)\le c(\ell(\pi)-\ell(\pi_c))$ for a minimiser $\pi_c$ of $J_c$. Unlike a vertex of the hull, a point $\theta\ne0$ is stationary for $L+\frac\omega2\|\theta\|^2$ at one value of $\omega$ at most when $L$ is differentiable; without differentiability it can be selected on an interval ($L(\theta)=|\theta-1|$ selects $\theta=1$ for every $\omega\in(0,1]$). If the decay is not multiplied by the learning rate $\alpha$ of the loss, $\theta\leftarrow\theta-\eta_t(\alpha\nabla L(\theta)+\lambda\theta)$, the fixed points are the stationary points of $L+\frac{\lambda}{2\alpha}\|\theta\|^2$: the effective coefficient then depends on $\alpha$.

\begin{example}[A worse classifier in the limit]\status{proved; computed}\src{imitation/decay notes-final Example 4.3; checks d2(A)--(D), d3(D)}\label{ex:teacher:weightdecay}
Let $y$ be uniform on $\{\pm1\}$, $\xi=1$ with probability $1-q$ and $\xi=-1$ otherwise, independently, $0<q<\frac12$, $\varepsilon>0$, $x=(\varepsilon y,\xi y)$ and $p_\theta(y\mid x)=\sigma(y\,\theta\cdot x)$. The first feature separates the classes, at scale $\varepsilon$; $\inf L=0$ is approached only by classifiers of error rate $0$. If $\varepsilon^2<1-2q$, the minimiser of $F$ has error rate $0$ for $\omega<\omega^*$ and $q$ for $\omega\ge\omega^*$ (a tie counted as an error), where
\[
\omega^*=\frac{2q\varepsilon^2}{(1-\varepsilon^2)\,a^*},\qquad a^*=\ln\frac{2(1-q)(1-\varepsilon^2)-q(1+\varepsilon^2)}{q(1+\varepsilon^2)};
\]
if $\varepsilon^2\ge1-2q$, it has error rate $0$ for every $\omega>0$. At $\varepsilon=0.1$ and $q=0.2$, $\omega^*=2.101\cdot10^{-3}$. A direct computation (code in the accompanying repository) finds the empirical minimisers with $\omega=0.01$ at error rate $0.2$ in all of 20 samples for each $n\in\{10^2,10^3,\dots,10^6\}$, and with $\omega=1/n$, the fixed prior $\mathcal N(0,I)$, at error rate $0$ in all of 20 for each $n\ge10^3$; minibatch gradient descent reaches the same regimes. Full-batch AdamW with decoupled coefficient $\lambda$ ends near the minimiser of $L$ under $\|\theta\|_\infty\le1/\lambda$ \citep{xie2024implicit}, whose error rate is $q$ exactly when $\lambda\ge2\varepsilon/\ln((2-3q)/q)$, for every $\varepsilon\le1$: at $\varepsilon=0.1$, $q=0.2$ the threshold is $0.1028$, and at $\varepsilon=0.8$, $q=0.2$, where $L_2$ decay never switches, it is $0.8222$ (both to four digits).
\end{example}

\emph{Proof idea.} With $a:=\varepsilon\theta_1+\theta_2$, $b:=\varepsilon\theta_1-\theta_2$, the error rate is $(1-q)[a\le0]+q[b\le0]$. The stationarity equations of the strictly convex $F$ give $\theta_1,\theta_2>0$, so the error rate is $q[b\le0]$. At $b=0$ they force $(1-q)(1-\varepsilon^2)\sigma(-a)=\frac q2(1+\varepsilon^2)$. If $\varepsilon^2\ge1-2q$ this is impossible: for $\varepsilon\ge1$ the left side is not positive, and otherwise it needs $\sigma(-a)\ge\frac12$, against $a=2\theta_2>0$. If $\varepsilon^2<1-2q$ it fixes $a=a^*$ and $\omega=\omega^*$. As $b$ is continuous in $\omega$ and $b>0$ for $\omega\le\varepsilon^2q/\ln((2-3q)/q)$, and $\omega\,b\to(\varepsilon^2-(1-2q))/2$ as $\omega\to\infty$, the claim follows. Under the box, $\theta_1=1/\lambda$ because $\partial L/\partial\theta_1<0$, and for $\varepsilon\le1$ the error rate is $q$ iff $\partial L/\partial\theta_2\le0$ at $\theta_2=\varepsilon/\lambda$, that is iff $(1-q)\sigma(-2\varepsilon/\lambda)\ge q/2$.
```

**Related-work sentence**, for `related.tex` directly after `keep the ratio of $\lambda=1$.\label{rem:related:cold}`:

```latex
With $\lambda=cn$ the prior changes with the sample size, as the Gaussian prior implicit in weight decay does (\cref{rem:teacher:weightdecay}); \citet{zhu2026overfitting} likewise read a large complexity weight in a PAC-Bayes rule as a sample-size-dependent prior.
```

**Discussion sentence**, in "The window and its price", after "so $\lambda$ must grow linearly with $n$.":

```latex
A fixed weight-decay coefficient on an averaged loss has the same form, a Gaussian prior whose precision grows linearly in $n$, and it too can keep a cheaper, worse classifier in the limit (\cref{rem:teacher:weightdecay}).
```

### 3.4 Citations: what each supports, and verification

Every work cited by the weight-decay drafts was confirmed three times by WebSearch: by the decay record, by its referee, and here on 2026-10-14 (13 queries; results at abstract level; no full text read; WebFetch was not used).

| key | cited for | confirmed here (abstract level) | status |
|---|---|---|---|
| `krogh1992simple` | weight decay as a regulariser | NIPS 4, pp. 950–957; weight decay suppresses irrelevant components and, if the size is right, static target noise | [known: abstract] |
| `mackay1992practical` | the Gaussian-prior reading of weight decay (the precision $n\omega$ is derived in the paper, not attributed) | Neural Computation 4(3):448–472; doi 10.1162/neco.1992.4.3.448; objective choice of weight-decay terms in a Bayesian framework | [known: abstract] |
| `hinton1993keeping` | information in a weight depends on its precision, controlled by Gaussian noise | COLT '93, pp. 5–13; doi 10.1145/168304.168306; information in a weight controlled by adding Gaussian noise whose level is adapted | [known: abstract] |
| `vanlaarhoven2017l2` | with normalisation the norm mainly sets the effective learning rate | arXiv:1706.05350; no regularising effect with normalisation; changes the scale and the effective learning rate | [known: abstract] |
| `mandt2017stochastic` | stochastic gradient iterates are not minimisers | JMLR 18(134):1–35; constant-rate SGD is a Markov chain with a stationary distribution | [known: abstract] |
| `loshchilov2019decoupled` | decoupled decay is not an $L_2$ penalty in adaptive methods | ICLR 2019, arXiv:1711.05101; equivalent for SGD when rescaled by the learning rate, not for Adam | [known: abstract] |
| `xie2024implicit` | AdamW's limit is a KKT point under an $\ell_\infty$ constraint | ICML 2024, PMLR 235:54488–54510; full batch, convergence to a KKT point under $\lVert\theta\rVert_\infty\le1/\lambda$ | [known: abstract] |
| `power2022grokking` | grokking (no claim about weight decay) | arXiv:2201.02177; generalisation long after overfitting on small algorithmic datasets | [known: abstract] |
| `liu2022towards` | grokking (no claim about weight decay) | NeurIPS 35, arXiv:2205.10343; effective theory, four phases | [known: abstract] |
| `liu2023omnigrok` | grokking related to the weight norm and to weight decay | ICLR 2023, arXiv:2210.01117; the LU mechanism explains weight-decay dependence | [known: abstract] |
| `nanda2023progress` | memorisation, then a cleanup that removes memorising components | ICLR 2023, arXiv:2301.05217; the abstract's closing sentence, verbatim: "the gradual amplification of structured mechanisms encoded in the weights, followed by the later removal of memorizing components" | [known: abstract] |
| `zhu2026overfitting` (already in Paper 2) | "read a large complexity weight as a sample-size-dependent prior" | arXiv:2603.22644; a third paraphrase of the abstract: λ ≫ 1 "yields a sample-size-dependent prior" | [known: abstract, paraphrase; verb "read" kept as the decay referee advised] |

The imitation drafts cite three works that are already in Paper 2's bibliography and cited there for the same facts: `cover2006elements` (type-class bounds; `def:teacher:instance`), `li2008introduction` (the facts (F1)–(F5); `app:setup:facts`) and `ville1939etude` (Ville's inequality; `lem:split:ville`). They are not among the works the decay referee verified; they rest on Paper 2's own bibliography check (final check).

Statements that went beyond the abstracts in the decay record (Omnigrok's constant-norm experiment, Zhang et al.'s weight-decay table, Power et al.'s "particularly effective", Nanda et al.'s attribution of the cleanup to weight decay) are **not** in the drafts (`decay` L1–L4). A search here returned a paraphrase saying that in Nanda et al. "weight decay removes the memorization components"; it is not used.

**BibTeX** (`drafts/imit.bib`, eleven entries; to be added as `paper-steeper/bib/imit.bib`, which `merge_bib.py` picks up; no key exists in `bib/*.bib` already):

```bibtex
% Bibliography for rem:teacher:weightdecay and app:teacher:weightdecay (imitation synthesis, 2026-10-14).
% Entries from research/tracks/imitation/decay/refs.bib, each confirmed by WebSearch three times (decay record,
% its referee, and the synthesis); content used at abstract level only.

@inproceedings{krogh1992simple,
  author    = {Krogh, Anders and Hertz, John A.},
  title     = {A Simple Weight Decay Can Improve Generalization},
  booktitle = {Advances in Neural Information Processing Systems 4 (NIPS 1991)},
  editor    = {Moody, John E. and Hanson, Stephen J. and Lippmann, Richard P.},
  pages     = {950--957},
  publisher = {Morgan Kaufmann},
  year      = {1992}
}

@article{mackay1992practical,
  author  = {MacKay, David J. C.},
  title   = {A Practical {Bayesian} Framework for Backpropagation Networks},
  journal = {Neural Computation},
  volume  = {4},
  number  = {3},
  pages   = {448--472},
  year    = {1992},
  doi     = {10.1162/neco.1992.4.3.448}
}

@inproceedings{hinton1993keeping,
  author    = {Hinton, Geoffrey E. and van Camp, Drew},
  title     = {Keeping the Neural Networks Simple by Minimizing the Description Length of the Weights},
  booktitle = {Proceedings of the Sixth Annual Conference on Computational Learning Theory (COLT '93)},
  pages     = {5--13},
  publisher = {ACM},
  year      = {1993},
  doi       = {10.1145/168304.168306}
}

@inproceedings{loshchilov2019decoupled,
  author    = {Loshchilov, Ilya and Hutter, Frank},
  title     = {Decoupled Weight Decay Regularization},
  booktitle = {International Conference on Learning Representations (ICLR)},
  year      = {2019},
  note      = {arXiv:1711.05101}
}

@misc{vanlaarhoven2017l2,
  author       = {van Laarhoven, Twan},
  title        = {{$L_2$} Regularization versus Batch and Weight Normalization},
  howpublished = {arXiv:1706.05350},
  year         = {2017}
}

@inproceedings{xie2024implicit,
  author    = {Xie, Shuo and Li, Zhiyuan},
  title     = {Implicit Bias of {AdamW}: $\ell_\infty$-Norm Constrained Optimization},
  booktitle = {Proceedings of the 41st International Conference on Machine Learning},
  series    = {Proceedings of Machine Learning Research},
  volume    = {235},
  pages     = {54488--54510},
  year      = {2024}
}

@article{mandt2017stochastic,
  author  = {Mandt, Stephan and Hoffman, Matthew D. and Blei, David M.},
  title   = {Stochastic Gradient Descent as Approximate {Bayesian} Inference},
  journal = {Journal of Machine Learning Research},
  volume  = {18},
  number  = {134},
  pages   = {1--35},
  year    = {2017}
}

@misc{power2022grokking,
  author       = {Power, Alethea and Burda, Yuri and Edwards, Harri and Babuschkin, Igor and Misra, Vedant},
  title        = {Grokking: Generalization Beyond Overfitting on Small Algorithmic Datasets},
  howpublished = {arXiv:2201.02177},
  year         = {2022}
}

@inproceedings{liu2022towards,
  author    = {Liu, Ziming and Kitouni, Ouail and Nolte, Niklas S. and Michaud, Eric and Tegmark, Max and Williams, Mike},
  title     = {Towards Understanding Grokking: An Effective Theory of Representation Learning},
  booktitle = {Advances in Neural Information Processing Systems 35 (NeurIPS 2022)},
  year      = {2022},
  note      = {arXiv:2205.10343}
}

@inproceedings{liu2023omnigrok,
  author    = {Liu, Ziming and Michaud, Eric J. and Tegmark, Max},
  title     = {Omnigrok: Grokking Beyond Algorithmic Data},
  booktitle = {International Conference on Learning Representations (ICLR)},
  year      = {2023},
  note      = {arXiv:2210.01117}
}

@inproceedings{nanda2023progress,
  author    = {Nanda, Neel and Chan, Lawrence and Lieberum, Tom and Smith, Jess and Steinhardt, Jacob},
  title     = {Progress Measures for Grokking via Mechanistic Interpretability},
  booktitle = {International Conference on Learning Representations (ICLR)},
  year      = {2023},
  note      = {arXiv:2301.05217}
}
```

`decay/refs.bib` also holds `dangelo2024why`, `zhang2017understanding`, `arpit2017closer` and `varma2023explaining`; the drafts do not cite them, so they are left out.

---

## 4. The caveats

### 4.1 What the paper says now, and what is missing

* "Scope and reader's guide" (introduction) limits the teacher result to parities, product error sets, uniform inputs, incompressible rules and the two flip-rate bounds, and says that for realistic errors there are counterexamples but no positive result.
* "The gap to realistic errors" (discussion) ends: "We do not expect steeper penalisation alone to solve the general problem of learning a norm from imperfect imitation; it works in one toy case and fails in others."
* Missing: that neither motivating problem is solved; that the results are offered as tools; which toy cases are solved for *both* threads; and the conceptual problems, concretely. So, per the author's message, a change is warranted, and it can be short.

### 4.2 Draft paragraphs

**Introduction, paragraph 2**, after "Does a steeper prior select the sampler?" (`drafts/intro.diff`):

```latex
One motivation is imitation: a learner trained on a person's answers should return a copy of the person, a sampler with its own randomness, rather than the sampler with some of its sampled bits stored, or a different system that predicts the person's answers (\cref{sec:imit}).
```

**Introduction, contributions**, a new last bullet:

```latex
\item \emph{Imitation} (\cref{sec:imit}). If a sampler's coins are an incompressible function of an environment variable on many more cells than the sampler has bits, other hypotheses can predict better, yet for $\lambda/n$ in a window every near-optimal private-randomness hypothesis, whatever its structure, is close to the sampler in behaviour (\cref{thm:imit:main}); imitation data identify only behaviour and the data kernel, cheap couplings defeat every $\lambda/n$, and no procedure reliably copies a sampler entangled with its coupling (\cref{prop:imit:limits}).
```

**Introduction, `tab:intro:claims`**, a row before "Is some other pathology present?" (kept short: a longer row made the table too tall for its `[t]` placement and sent it, with every later float, to the end of the scratch build):

```latex
Is a sampler recovered when other hypotheses predict better? & In part: near-copies, if its coins are an incompressible function of an environment variable on many more cells than it has bits; not for cheap couplings, nor reliably by any procedure when it is entangled with them & \cref{thm:imit:main,prop:imit:limits}\\
```

**Introduction, "Scope and reader's guide"**, replacing its first sentence (the rest is unchanged except "imitation (\cref{sec:imit})" in the reader's guide):

```latex
\paragraph{Scope and reader's guide.} We do not claim to solve the problems that motivate the two reasons, imitating a person and learning what a teacher means rather than what the teacher says. We offer tools for them: the private-randomness class, the kink geometry, the reuse factor and a per-sample threshold on the rate at which a component buys fit. With them we solve toy cases, for idealised learners that minimise the objective exactly over a hypothesis class, in the main results all programs of a fixed reference machine: exact recovery of a computable sampler from per-query samples with i.i.d.\ inputs (\cref{thm:recovery:main}); the full table of a noisy random parity with a dyadic flip rate below $\frac14$, for large $d$ (\cref{prop:parity:range}); a teacher who flips a random parity on an incompressible error rule of product form, with uniform inputs and flip rates below $0.05596$, or $0.1233$ asymptotically (\cref{thm:teacher:main,rem:teacher:hypotheses,prop:teacher:rates}); and, up to near-copies, a sampler whose coins are an incompressible function of the environment on many more cells than it has bits (\cref{thm:imit:main}); the last two for the population objective, and from samples only asymptotically or with large constants. For realistic error patterns we have counterexamples but no positive result, and the conceptual problems listed in \cref{sec:discussion} remain open.
```

**Discussion**, a new paragraph before "Neural networks" (`drafts/discussion.diff`):

```latex
\paragraph{What the toy cases leave open.} The results concern idealised learners in toy worlds; the problems that motivate them remain far from solved. Six gaps are concrete. (1) Data identify behaviour, not mechanism: the selected program is a shortest program in the class for the learned kernel, which may compute it unlike the person and extrapolates off the support of the inputs as that program does (\cref{sec:imit}). (2) Which structure belongs to the person and which to the environment, and with it the complexity weight, are conventions that imitation data cannot settle: strictly proper scores prefer the teacher's channel (\cref{prop:limits:noident}), worlds with one data law cannot all be copied by any procedure (\cref{prop:imit:limits}(a)), and when a person's apparent randomness is its own deterministic state, returning the person with fresh coins is a modelling choice. (3) Realistic errors and realistic randomness have structure: cheap error rules and cheap couplings defeat every $c$, selection sorts components by rate rather than validity, and in a toy world no procedure reliably copies a person entangled with its coupling (\cref{prop:limits:rateblind,prop:limits:separable,prop:imit:limits}). (4) Exact copies need the same question answered afresh; with frozen labels no procedure recovers every sampler (\cref{prop:recovery:frozen}). (5) People have memory, and excluding hypotheses that learn in context, which absorb what they imitate, is a choice of class (\cref{thm:split:shared,prop:absorb:history,sec:imit}). (6) The steeper predictors are not computable, and whether the $\lambda$-MAPs are is open (\cref{prop:related:computability,q:related:open}); the margin form of \cref{thm:recovery:main} gives no computable sample size in $\Hcl{\times}$ (\cref{prop:recovery:necessity}); and which program counts as the shortest copy, and where every window lies, depend on the hypothesis class and the reference machine (\cref{rem:teacher:numbers}). We see the results as tools for these problems, with toy cases in which the tools work, not as solutions.
```

**Discussion, open problems**, a new item after "Resource bounds":

```latex
\item \emph{Imitation.} Partly private coins, cells of unequal mass, finite samples for general response functions, couplings that are short to describe but slow to compute, and data beyond imitation data that identify the person (\cref{q:imit:open}).
```

### 4.3 Every claim of the caveats, against the results

| claim in the drafts | supported by | status |
|---|---|---|
| toy case 1: exact recovery of a computable sampler, per query, i.i.d. inputs | `thm:recovery:main` | [proved: Paper 2] |
| toy case 2: the full table of a noisy random parity, large $d$ | `prop:parity:range`(iii) (dyadic flip rates below 1/4, typical error sets) | [proved: Paper 2] |
| toy case 3: the teacher, with the listed hypotheses | `thm:teacher:main`, `rem:teacher:hypotheses`, `prop:teacher:rates` | [proved: Paper 2] |
| toy case 4: environment-driven coins, near-copies | `thm:imit:main` | [proved: `robust`; §2.3] |
| "the last two for the population objective, and from samples only asymptotically or with large constants" | `prop:teacher:schedules`(c), `cor:teacher:sampled` ($\approx10^{11}$ samples at the example's sizes); `prop:recovery:beyond`(c) for `thm:imit:main` | [proved: Paper 2] |
| (1) behaviour, not mechanism | `robust` Prop 3.1; text after `prop:imit:limits` | [proved, elementary] |
| (2) the person/environment split and $c$ are conventions | `prop:limits:noident`; `prop:imit:limits`(a); the deterministic-state reading of (c) | [proved; the last clause a remark, referee A §5.6(ii)] |
| (3) structured errors and randomness; rate, not validity; entanglement | `prop:limits:rateblind`, `prop:limits:separable`, `prop:imit:limits`(b),(c) | [proved] |
| (4) frozen labels | `prop:recovery:frozen`(a) | [proved: Paper 2] |
| (5) memory; in-context learners excluded by the class | `thm:split:shared`, `prop:absorb:history`, `robust` Prop 5.2 | [proved] |
| (6) the steeper predictors not computable, the computability of the λ-MAPs open; no computable sample size; class and machine dependence | `prop:related:computability`(b), `q:related:open`(b), `prop:recovery:necessity` (the margin form in $\Hcl{\times}$), `rem:teacher:numbers` (windows at κ = 0 and 30) | [proved: Paper 2] |
| "We see the results as tools for these problems, with toy cases in which the tools work, not as solutions." | the author's message; the list above | [remark] |

The brief's list of philosophical problems is covered: behavioural equivalence (1); λ or $c$ not choosable from imitation data (2); structured errors (3); frozen labels (4); uncomputability (6); the choice of hypothesis class and reference machine (5), (6). The drafts add the person/environment split and entanglement, which the robust results make concrete.

---

## 5. Build check and page budget

### 5.1 Build

A scratch copy of `paper-steeper/` (`main.tex`, `preamble.tex`, `sections/`, `bib/`, `build.sh`, `merge_bib.py`, `figures/`) in the session scratchpad, built with its own `build.sh` (pdflatex, bibtex, pdflatex ×2):

| build | LaTeX errors | undefined refs | undefined cites | multiply defined | overfull > 10 pt | pages |
|---|---|---|---|---|---|---|
| unmodified | 0 | 0 | 0 | 0 | 0 | 74 |
| with every draft of §2–§4 and `bib/imit.bib` | 0 | 0 | 0 | 0 | 0 | 84 |

* The DECISIONS §A5 vocabulary grep on `pdftotext main.pdf` finds nothing new: the hits it adds are formula fragments ($s_0$, $\mathcal E_0$, $c_1$), and the only word hit is the title footnote's "independent AI referees", as before.
* Where things land: `rem:teacher:weightdecay` p. 26; `sec:limits` p. 31 (p. 30 in the unmodified build); `sec:imit` pp. 33–36 (about 2.6 pages); `sec:computable` p. 36; discussion p. 37, its new paragraph p. 38; appendices from p. 43 (p. 37 unmodified); `app:teacher:weightdecay` p. 71; `app:imit` pp. 80–83.
* Two layout problems were found and fixed while building: three overfull displays in `app-imit.tex` (split into `align*`), and the float queue described in §3.2 and §4.2.

### 5.2 Growth

Main text and references grow by 6 pages (imitation section 2.6, weight-decay remark 0.6, introduction and discussion about 1, eleven references about 0.7, page breaks the rest); appendices by 4 (imitation 3, weight decay 1.7, less float slack).

### 5.3 Cuts, if needed

* **Imitation, to about 1.3 pages:** keep the definition, the theorem and `prop:imit:limits`(a),(b); move `rem:imit:private`, the numbers after the theorem, `prop:imit:limits`(c) and the cell count to the appendix; drop `q:imit:open` and keep only the open-problems item.
* **Weight decay** (`decay` §6, options): drop the grokking sentence (3 lines); drop the paragraph after the proof of `prop:teacher:nofixedprior` (6 lines); drop the AdamW sentence of the example and the box part of the proof idea (5 lines).
* **Abstract:** unchanged. At 1920 characters of source it is already at the 1920-character limit of the restructure decisions (D9), and the introduction carries the new material.

---

## 6. Claims and statuses

| # | claim | status |
|---|---|---|
| S1 | the robust material contains one genuinely new ingredient (closeness lemma), one new sharp negative result (confounding), and otherwise reassembles Paper 2's tools | [remark; §1.2] |
| S2 | recommendation: a new short section after `sec:limits` | [recommendation] |
| S3 | `thm:imit:main` (i)–(iii), Φ bound | [proved, refereed: robust Thm 4.7(U) = referee A's A1] |
| S4 | `lem:imit:closeness`, `thm:imit:main`(iv) | [proved: robust Lemma 4.6, Thm 4.7(vi); not refereed; checked here line by line; computed: f7(A),(B), s1(B),(C)] |
| S5 | $B_\beta:=K(\beta\mid h_0,\mu)$ suffices for case (U) and the closeness lemma | [proved here] |
| S6 | `prop:imit:limits`(a) | [proved: robust Prop 4.10(a2); checked here] |
| S7 | `prop:imit:limits`(b) and its no-window form | [proved, refereed: robust Prop 4.11 = referee A's R1; computed: f8, s1(D)] |
| S8 | `prop:imit:limits`(c), the cell count | [proved, refereed: robust Prop 4.10(c),(d)] |
| S9 | the brief's lower bound by advantage per bit for every procedure | [refuted: referee B's rb4(C)]; true for penalised likelihood |
| S10 | the numbers of §2.4 | [computed: s1(A)] |
| S11 | the mean total-variation bound is not informative for low-entropy persons: the best predictor has mean TV $2p(1-p)$ | [proved here] |
| S12 | the weight-decay remark, appendix, related and discussion sentences | [proved, refereed: decay; computed: d1–d3, s1(E)]; citations [known: abstract level, three rounds] |
| S13 | "$\lambda\ge0.103$" in the decay draft misstates the threshold $0.10278$ by rounding up | [computed: s1(E)]; fixed |
| S14 | each caveat claim of §4.3 | as listed there |
| S15 | the drafts build cleanly; 84 pages | [computed: scratch build; again after the final check] |
| S16 | the drafts as first written stated six things more strongly than proved: the range $c\lesssim1/\ell_0$ for near-copies (it is $c\lesssim H(\rho)/\ell_0$), "no hypothesis predicts better in population" without its hypotheses, equal kernels giving equal data laws when ρ has ties, the weight-decay limit without differentiability, "the learners are not computable" (open for the λ-MAPs), and "no procedure copies" for a probability bound | [refuted as worded; fixed in the final check, F1, F3, F5, F11, F10, F6/F7/F9] |

---

## 7. Points for the author

1. **Is a 2.6-page section the right weight?** It is the recommendation (§1.4), with a 1.3-page fallback (§5.3).
2. **The weight-decay reading.** The drafts read "as the number of params varies" as "as the sample size varies" (`decay` header); confirm.
3. **Imitation literature.** No literature on imitation learning, behavioural cloning or the identifiability of preferences from behaviour was searched or cited; a pointer in related work may be wanted.
4. **A referee pass on the closeness lemma.** It is checked here and by two independent computations, but no adversarial referee has read it in its final form. The same holds for the simplified $B_\beta$ (§2.2) and the cell count's use in the text.
5. **Vocabulary.** The drafts say "person" and "copy"; the paper's existing text says "sampler", "model" and "teacher". The section's first paragraph ties the two.

---

## Verification log

* **2026-10-14, reading.** As listed under "Sources read". Every Paper 2 label that the drafts cite was found in `paper-steeper/sections/`; the scratch build confirms there are no undefined references.
* **Proof checks done here** (§2.2, §2.3): `robust` Lemma 4.6 step by step, including the trimming needed for the conditional coding theorem with the condition $k$; Theorem 4.7(vi)'s algebra; Proposition 4.10(a2); that case (U) and Lemma 4.6 use $B_\beta$ only through three facts that hold for $K(\beta\mid h_0,\mu)$; the right side of (ii) from `lem:kink:main`(iv); the appendix proofs of the draft against `lem:kink:main`'s hypotheses ($\mathcal N=\emptyset$, $\tau=2^{-m}<c$, $g\ge0$ because $\pi_H$ bounds the point, $\ell_{\mathcal M}=0$); the no-window inequality of `robust` Prop 4.11(c) and the two-case comparison in Prop 4.10(c),(d); the claim that the in-context learner beats the person's program once $\lambda(\ell(\pi_H)-\ell(U))>\log(1/w)$. Not re-proved: the results of Paper 2 used by citation, and the decay record's proofs, which its referee rederived.
* **`checks/s1_synthesis.py`.**
  * First run in the scratchpad (31 s): all assertions passed; stderr had one NumPy warning from part (B), where $0\cdot(-\infty)$ made the risk `nan` for programs with zeros on inputs outside a cell's support, so those programs were skipped in the identity check. Fixed by summing only over inputs of positive mass, and the count of programs used by each check was added to the output (1110 with finite $\bar D$, 901 with finite $R$ at the true coupling). Parts (A), (C)–(F) were byte-identical before and after the fix.
  * Saved run: a fresh copy run with `python3 -I` in a new scratch directory, byte-identical to the second run, stderr empty. SHA-256 (first 16 hex digits) of the script: `9fb6b59bd0b8a802`.
* **Literature** (§3.4): 13 WebSearch queries on 2026-10-14, one per cited work (twelve) plus one on the verbatim closing sentence of Nanda et al.'s abstract. For every entry of `drafts/imit.bib` the searches here reconfirmed authors, title, venue, year and, where the entry gives them, pages, volume or DOI; the editors and publisher of `krogh1992simple` were confirmed by the decay referee (DBLP) and not again here. No full text was read; WebFetch was not used.
* **Drafts.** Built 13 times in the scratch copy (§5.1). Between builds: the section was shortened from 3.5 to 2.6 pages (the private-coins remark was shortened; the example, the remark on what the results do not show and a fourth part of the proposition, the cell count, were folded into the running text and the appendix); three overfull displays were split; the weight-decay appendix was moved before `app:teacher:rates`; the new table row was shortened; wording fixes listed in §2.2 and §3.3. The files in `drafts/` are those of the last build; their SHA-256 prefixes: `app-imit.tex` `681e033c3de70b50`; `app-teacher.diff` `5602e5d70eb97569`; `discussion.diff` `4c2fd3841fa2d09e`; `imit.bib` `d81b6cc116d9095a`; `imit.tex` `70dc41cafdd7568b`; `intro.diff` `0127c67ae7f85bab`; `main.diff` `cb5f2ad08d463e3b`; `related.diff` `7f134c05d67b274f`; `teacher.diff` `c18f68b57c6f8d1e`; `wd-appendix.tex` `f3a46239cd339e12`; `wd-remark.tex` `4d35ee70ef539df8`.
* **Not done.** No independent adversarial referee for the closeness lemma (§7, item 4). No change to `paper-steeper/`, to the sub-track folders, or to any file outside this folder.
* **Final check, 2026-10-14** (`final-check.md`). A fresh checker compared this record and its drafts with `robust/notes-final.md`, `decay/notes-final.md` and the three referee reports, re-ran `checks/s1_synthesis.py` and `robust/checks-final/f7_closeness.py` (both outputs byte-identical to the saved ones, stderr empty), and made twelve minimal edits to the drafts (F1–F12) and nine to the rest of this record (R1–R9), all listed in `final-check.md`. The files of `drafts/` were edited in the same way and are again byte-identical to the blocks above; rebuilt in a fresh scratch copy of `paper-steeper/` with every diff applied: 0 LaTeX errors, 0 undefined references or citations, 0 multiply defined labels, 0 overfull boxes over 10 pt, 84 pages, the same page positions as in §5.1, and no new process vocabulary. New SHA-256 prefixes of the seven edited files: `app-teacher.diff` `4ff0c664e7077d6a`; `discussion.diff` `8f28565d663e2518`; `imit.tex` `0ca8b079ac33cec7`; `intro.diff` `7c784206e83d8292`; `teacher.diff` `9fb939f0029c7fc6`; `wd-appendix.tex` `26a8230041df0f4d`; `wd-remark.tex` `e4cf399c9f491022` (the other four are unchanged).
