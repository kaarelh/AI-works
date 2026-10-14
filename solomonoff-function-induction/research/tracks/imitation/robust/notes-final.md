# Track "imitation", sub-track "robust": recovering the sampler robustly (target I1), final record

*Brief: `../00-brief.md`, target I1, parts (a)–(d) and the interpretation. Written 2026-10-14. This record revises `notes.md` (kept unchanged) after the referee reports `referee-A.md` (proofs) and `referee-B.md` (code and counterexamples). It is self-contained and supersedes `notes.md`.*

* **Sources read.**
  * The brief, in full, including the author's message.
  * `notes.md`, both referee reports in full, the outputs of the referees' scripts (`referee-A-checks/ra1`, `referee_code/rb1`–`rb6`), and the scripts `rb4` and `rb5` where this record cites their constructions.
  * Paper 2 (`paper-steeper/sections/`), for the statements used here: `setup` and `app-setup` (the data objects, the classes, the hull lemma, the facts (F1)–(F5)); `kinks` and `app-kinks` (`def:kink:kinks`, `lem:kink:main` and its proof, `lem:kink:secant`); `recovery` and `app-recovery` (`def:split:setting`, `lem:split:ville`, `lem:recovery:ratios`, `thm:recovery:main`, `thm:split:private`, `prop:recovery:frozen`, `prop:recovery:beyond` and its proof); `parity` (the instance and the four lemmas); `teacher` (`prop:teacher:schedules`, `thm:teacher:main`, `rem:teacher:selected`); `absorb`, `limits` and `app-limits` for the results cited by label.
  * `research/tracks/split/notes-final.md` (§0, §1, §4) and `split/iid/notes-final.md` (§7).
  * `research/paper-review/REFRAME.md` (binding rules for any paper text).
* **Scripts.** Python 3.11.15 with NumPy 2.4.6, deterministic or seeded; every output is saved next to its script as a `.out` file.
  * `checks/r1`–`r6`: the scripts of `notes.md`, unchanged and re-run byte-identically.
  * `checks-final/f2`–`f4`: `r2`–`r4` with the code-length bug of referee B (B9) fixed; nothing else changed.
  * `checks-final/f7`, `f8`: new for this revision.
  * Referees' scripts are cited as **[referee: raN]** or **[referee: rbN]**; their outputs were read, and their statements re-derived where this record relies on them.
* **Status tags.**
  * **[proved]**: full proof here. **[proved: Paper 2, label]**: proved in Paper 2, restated, possibly read in a new way. **[proved, new]**: not in Paper 2 or the split records, even when the proof is a short assembly of their lemmas (§7 says what is new). **[proved, new in revision]**: added in this revision.
  * **[computed: X]**: checked by script X; output in its `.out` file. **[evidence: X]**: numerical evidence on an open question. **[example]**: an illustration whose numbers hold by construction.
  * **[known: ref]**, **[conjecture]**, **[open]**, **[sketch]**, **[remark]**, **[heuristic]**: as named. **[refuted]**: shown false as stated; kept, with the reason.
* **Conventions.** $\log=\log_2$. Code lengths, fits, risks and deficiencies are in bits. κ is Paper 2's machine constant and may differ between occurrences. $c=\lambda/n$, and in §4 $a:=c\,2^m$. Numbers computed in an explicit toy class involve no machine constant: they are statements about that class. Notation follows Paper 2: $L_n(\pi)$ is the fit of π after $n$ queries, $J_\lambda=\lambda\ell+L$, $R(\pi)$ a population risk, $J_c=c\,\ell+R$, $\Phi(c)=\inf J_c$; $\Hel(P,Q):=1-\sum_y\sqrt{P(y)Q(y)}$, also for a sub-probability $Q$.
* **Repository.** No git command that changes repository state was run. Files written: this record and `checks-final/`. `notes.md` and `checks/` are unchanged.

---

## Revision summary

Every fatal and major issue is fixed; the moderate and minor issues are fixed or answered. No referee claim was found to be wrong, apart from one constant in the proof of R1 (Proposition 4.11(c)). The main change goes beyond the requested fixes: a new **closeness lemma** (Lemma 4.6) bounds how far a near-optimal program can be from the human *in behaviour*, which turns referee A's unconditional bound (A1) into a robust *near-imitation* theorem (Theorem 4.7). This answers M1 and M4 positively instead of only by rewording.

| issue | referee's point | verdict | what changed |
|---|---|---|---|
| **A-M1** (major) | Theorem 4.6 (old) has no upper end; "coin-flipping human, unconditionally" is not a solved case of *picking the human*: above the human's left steepness the coin is selected (r4(B), ra1(A)) | **agreed** | Theorem 4.7 states both ends: the lower end $2^{-m}$ enters through $a-1$, and conclusions (iii), (v), (vi) carry the term $c\,\Gamma$, so the guarantee holds for $2^{-m}<c\ll1/\Gamma$ and is vacuous above. The old reading is kept as **[refuted]** (§9). The coin-flipping human is now a solved case in the precise sense of Theorem 4.7(vi): near-optimal programs are near-copies for $c=a2^{-m}$, $a>1$, $c\ell_0$ small; exact selection only in explicit classes, on $(s_+,s_-)$. |
| **A-M2** (major) | "Robust against every alien, whatever its structure" was proved only for programs that know the human's model ($M_t$); the left condition is a real hypothesis (R1) | **agreed** | Referee A's A1 is adopted and re-derived in the conditioned setting as Lemma 4.5(d) and Theorem 4.7(U): no left condition, offset $\ell_0$ instead of $t$. Referee A's R1 is adopted and re-derived, with corrected constants, as Proposition 4.11 [computed: f8; referee: ra1(B)]. The wording "whatever its internal structure" now applies to Theorem 4.7(U), where it is proved. |
| **A-M3 / B-B1** | $\pi_H$ was padded with the input mechanism μ, so a shorter copy breaks the left condition, Proposition 4.9(b),(c) and Theorem 4.6(vi); the latent-cause reading inflates every offset by $K(\mu\mid h,\rho)$ | **agreed**; ra1(C) refutes old 4.9(b) as written | Setting 4.1 now conditions every complexity on μ (referee B's repair), takes the reference point at a **shortest copy** $(\ell_0,H(\rho))$, and defines $t_H:=K(h_0\mid\pi_H,\mu)$ without claiming it is a constant ($t_H\le\kappa$ when ρ has pairwise distinct values). Propositions 4.3, 4.10(b)–(d) and Theorem 4.7(vii) are relative to the shortest copy. |
| **A-M4** | "Every near-optimal hypothesis is the human's model with essentially fresh coins" was an interpretation: no divergence between $\nu_\pi$ and $\nu_H$ was bounded | **agreed; fixed by a proof** | Lemma 4.6 (new) and Theorem 4.7(vi) bound $\Ex_xD_{1/2}(\nu_H\Vert\nu_\pi)$, hence Paper 2's Hellinger gap and the mean total variation. "Copy" is reserved for $\mathcal E(\nu_H)$; "near-copy" means a small Hellinger gap. |
| A-m1 / B-B5 | Proposition 4.9(b)'s last sentence ("eventually stays in $[s_+,s_-]$") was not proved; the condition is not sufficient (rb4(B)) | **agreed** | Proposition 4.10(b4) proves, by the Hewitt–Savage 0–1 law, that the shortest copies are eventually the unique MAPs only if $s_+<\lambda_n/n<s_-$ for all large $n$; (b5) proves a sufficient condition (law of the iterated logarithm) in finite classes. |
| A-m2 / B-B11 | the row "(a)-brief refuted" needs the weak/strong distinction: the learner is $\nu_H$-equivalent on the run (ra1(D)) | **agreed** | Row requalified (§9). |
| A-m3 / B-B3 | the in-context learner is excluded by the choice of hypothesis class (product or episodic), not by private randomness; with i.i.d. private coins and a history-aware class it wins (rb5(A)) | **agreed** | Remark 2.4, Proposition 5.3 and §6 reworded; the old sentence of §6.1 item 1 is kept as **[refuted]**. |
| A-m4 / B-B11 | §0 said "every $\lambda_n=o(n)$ eventually selects" the exploiting alien; only rejection of the human is proved | **agreed** | Reworded (§0, Proposition 2.3(b)). |
| A-m5 / B-B8 | Remark 4.12 (several environments) is a sketch | **agreed** | Now Remark 4.14, **[sketch]**, with its two missing conditions stated and referee B's numbers (rb3(B)). |
| A-m6 | Proposition 3.3(b): "interventions on internal variables" is undefined for kernels; enlarged observations move non-identifiability rather than remove it | **agreed** | Proposition 3.3 rewritten. |
| A-m7 / B-B6 | Corollary 4.8 (old) is stated for any countable Kraft class, but Lemma 4.4 needs uniform lower semicomputability and (F1) a c.e. prefix-free class | **agreed** | Corollary 4.9 is stated for $\Hcl{\times}$ and for the classes of `def:setup:class` (through `prop:related:computable`, with their own κ). |
| A-m8 | $h^*$ was "a finite description", so $K(h^*)$ was ill-defined | **agreed** | $h_0:=(h,\rho)$, with $h$ restricted to the finite set $\supp\mu\times B$, is a finite object. |
| A-m9 / B-B7 | "offset of order $m+\delta_\beta$" hides $|B|\log(2^m+1)$, $t$ and the padding; "$2^{-m}(1-o(1))$" is class-specific | **agreed** | Offsets written out in full: $G=\Gamma+\delta_\beta+|B|\log(2^m+1)+\kappa$. The explicit lower end is $2^{-m}(1\pm o(1))$, the sign set by the code (r6(C): $1.0105\cdot2^{-m}$; rb2(B): $1.023\cdot2^{-m}$). |
| A-m10 | Proposition 4.2(b) needs $P^*\ne\nu_H$ on positive mass | **agreed** | Added. |
| A-m11 | Corollary 4.7(b) quotes Paper 2's numbers, which use $\delta_S$, not $\delta_\beta$ | **agreed** | Corollary 4.8(b) says so; $\delta_\beta=\delta_S+O(\log d+\log m+K(p))$. |
| A-m12 | Proposition 5.1: $P_H$ is a property of the human alone only if the inputs depend on the observable history and independent randomness | **agreed** | Assumption stated in Setting 5.0. |
| A-m13 / B §1 | the Ville tails should be compared with (Kraft sum)$\cdot2^{-j}$; "about $40\log(n/80)$" overstates the regret | **agreed** | Comparisons redone (§2, §5). |
| A-m14 | Theorem 2.2(3) needs countable environment features $z$ | **agreed** | Added to Definition 2.0. |
| A, table | Lemma 2.1's novelty is overstated; Lemma 4.4 has a *simpler* proof than Paper 2's; Proposition 4.3 is a tautology for $J_c$-minimisers | **agreed** | Statuses and readings changed. |
| **B-B2** | "the set of aliens a procedure is robust against is the set of humans it cannot copy" is false for general procedures (rb4(C): success probabilities summing to 1.98) | **agreed** | Slogan kept as **[refuted]**. Proposition 4.10(a) now states the general bound for worlds with one data law, and (a3) records that for general procedures the advantage per bit is not an obstruction. |
| B-B9 | `ceil` of a floating-point `lgamma` made some code lengths one bit too long in r2–r4 | **agreed** | Fixed in `checks-final/f2`–`f4` with exact integers. r3 is unchanged; r2 changes only in its offset column; r4(B) changes in five rows, as referee B predicted (Verification log). Numbers quoted here are the corrected ones. |
| B-B10 | Example 3.2's status rests on an identity; "no program's gain exceeded length + δ*" in r1(A) holds by definition | **agreed** | Example 3.2 is **[example]**; the r1(A) sentence is no longer cited as evidence. |
| B-B11 | Lemma 4.4's $K(m)$ term is unnecessary; $\delta_\beta\ge-1-\kappa$ | **agreed** | Both adopted (m is computable from μ). |

Numbering map from `notes.md`: §2–§3 and §5 keep their numbers. In §4: Setting 4.1, Propositions 4.2, 4.3 and Lemmas 4.4, 4.5 keep their numbers (all revised); Lemma 4.6 is new; old Theorem 4.6 is Theorem 4.7(L), merged with referee A's A1 as Theorem 4.7(U); old Corollaries 4.7, 4.8 are 4.8, 4.9; old Proposition 4.9 is 4.10; referee A's R1 is Proposition 4.11; old Remarks 4.10–4.12 are 4.12–4.14.

---

## 0. Summary

The author's "ideal theorem" asks for a learning procedure that returns a copy of a human (a sampler with its own randomness) and not the sampler with some of its random bits stored, nor an alien system that predicts the human by other means, even when some alien predicts better. The results, all in toy settings:

1. **Private coins (§2).**
   * If the human's coins are independent of everything a hypothesis can see, given the human's own input, then no hypothesis, whatever its structure, ever gains more than its own length plus the Ville deficiency δ* over the human, at any sample size, and $\Pr[\delta^*\ge j]\le2^{-j}$ (Lemma 2.1) [proved; known in substance: Ville's inequality for a mixture of predictable forecasters].
   * In the product class this gives Theorem A of Paper 2 for the human: for every $1\le\lambda_n=o(n)$ the selected programs are eventually exactly the shortest programs with the human's predictive law (Theorem 2.2) [proved: Paper 2 with Lemma 2.1].
   * Here no alien predicts better in population; aliens can only win on a sample, and they pay one bit of length per bit gained. This is the degenerate case of the author's scenario.
   * For a calibrated human, privacy is exactly the condition. If the coins depend on something an alien can see, that alien gains linearly in $n$, and every $\lambda_n=o(n)$ eventually rejects every copy of the human (Proposition 2.3) [proved, new].
2. **Behavioural non-identifiability (§3).** Input–output data identify the human's predictive law on the support of the inputs, and the procedure selects a *shortest* program for that law. Which program the human "is", and how it behaves off the support, no procedure can identify (Proposition 3.1) [proved, new; elementary]. Only data about more than the answers, or a class restricted to human-like programs, separate a copy from an equivalent alien; the selected program is then a shortest program for the enlarged observation (Proposition 3.3).
3. **Environment-driven coins (§4): the main result.** The human's coins are a fixed function β of an environment variable $w$ uniform on $2^m$ cells, seen by the learner through the input. Aliens that model β predict better, by up to $H(\rho)$ bits per sample.
   * **Robust near-imitation (Theorem 4.7(U))** [proved, new in revision]. With no further hypothesis, at $c=a2^{-m}$ with $a>1$, every near-optimal program of $\Hcl{\times}$, whatever its internal structure, satisfies
     $$\Ex_{x}D_{1/2}\big(\nu_H(\cdot\mid x)\,\Vert\,\nu_\pi(\cdot\mid x)\big)\ \le\ c\,\ell_0+\frac{2a}{a-1}\cdot\frac{\ell_0+\delta_\beta+|B|\log(2^m+1)+O(m)}{2^m},$$
     with $\ell_0$ the length of a shortest copy of the human and $\delta_\beta$ the compressibility of β. Paper 2's Hellinger gap is at most $\frac{\ln2}2$ times this, and the mean total-variation distance at most $\sqrt{2\cdot\text{gap}}$. Eventually every $cn$-MAP satisfies the same (Corollary 4.9).
   * So when the coupling is incompressible and spread over many more cells than the human has bits ($\ell_0\ll2^m$), every near-optimal hypothesis is a near-copy of the human for every $c$ between the reuse factor $2^{-m}$ and about $1/\ell_0$. It also holds little information about β and predicts no better than the human up to $O(\ell_0/2^m)$ per sample. This is a toy form of the ideal theorem: aliens predict better, yet the procedure returns a near-copy of the human.
   * The key new ingredient is a **closeness lemma** (Lemma 4.6) [proved, new in revision]: a program that predicts the environment-driven answers no better than the human and holds little information about β is, averaged over cells, close to the human's coin law.
   * **With a left condition** (the human's model is decodable from good predictions, proved for parities in Paper 2), the offsets shrink from $\ell_0$ to $t+D_0$, where $t$ bounds the bits a near-optimal program lacks for describing the human's model, and the program knows the human's model (Theorem 4.7(L)).
   * **Toy cases solved:** a coin-flipping human, as near-imitation and unconditionally (Corollary 4.8(a)); Paper 2's noisy-parity human, unconditionally in the sense of Theorem 4.7(U) at Paper 2's sizes, and with the sharper conclusions of Paper 2's Theorem C on its window (Corollary 4.8(b)); explicit finite classes, where the human itself is the unique selection on the window $(s_+,s_-)$ [computed: f2–f4, f7(C)].
   * **What any procedure must give up (Propositions 4.10, 4.11).**
     * (a) Worlds with one data law and different humans cannot all be copied: the probabilities of copying sum to at most 1, for every procedure. Imitation data identify the data kernel $P^*$, not its split into "human" and "environment".
     * When the human is as complex as the coupling and its response depends on the same cells, $2^{L_\beta}$ such worlds, each a human with private-looking coins driven by an incompressible coupling, share one data law, and no procedure copies the human with probability above $2^{-L_\beta}$ (Proposition 4.11, referee A's R1) [proved].
     * (b) A schedule keeps the shortest copies as the unique MAPs only if $s_+<\lambda_n/n<s_-$ eventually; in finite classes a margin larger than $\sqrt{\log\log n/n}$ from both ends suffices.
     * (c) Couplings with short descriptions (a pseudo-random generator with a short seed) defeat every $c$.
     * (d) A window for exact copies needs $2^m\gtrsim\ell_0/(\log|Y|-H(\rho))$ cells.
   * For general procedures the advantage per bit is *not* an obstruction (referee B's rb4(C)); it is the right quantity for penalised-likelihood procedures.
4. **Latent state (§5).** Ville's bound survives for every chronological class (Proposition 5.1). A hypothesis that learns in context, a Bayes mixture over humans, absorbs the human whenever the class lets hypotheses carry information across queries: for every λ > 1 and every data set (Proposition 5.2) [proved; computed: r5, referee: rb5(A)]. Restricting the class to hypotheses that restart at episode boundaries restores Theorem A per episode (Proposition 5.3). This exclusion is a choice of class, not a property of the data.
5. **Interpretation (§6).** The ideal theorem holds in toy form in two senses: against every program when the coins are private, and, as near-imitation, against every program when the coins are driven by an incompressible coupling much larger than the human's description, for $c$ in a window. It does not give a mechanism, it does not choose $c$, it fails for cheap couplings and for humans entangled with their coupling, and it needs per-query answers and a hypothesis class that excludes learners. §6 lists the open problems as the results bear on them.

---

## 1. Setting, and what "a copy" and "an alien" mean

### 1.1 Objects

* **The human** is a sampler: a probability kernel $\nu_H(y\mid x)$ on a finite label set $Y$. "Sampler" means the human answers each query with fresh coins of its own: the per-query data object PQ of `def:setup:data`, with pairs $(x_i,y_i)$, the label redrawn at every query, also at a repeated input.
* **Hypothesis classes.** As in `def:setup:class` and `def:split:setting`: a countable prefix-free set of programs with Kraft weights $\sum2^{-\ell(\pi)}\le1$. The main one is the product class $\Hcl{\times}$ (lower-semicomputable conditional semimeasures, private randomness per query). §2 and §5 also use classes of *predictors with side information* (Definition 2.0).
* **A copy** of the human is a program whose kernel equals $\nu_H$ at almost every input: a member of $\mathcal E=\mathcal E(\nu_H)$ of `def:split:setting`. The shortest copies form $\mathcal E_0$, of length $\ell_0$. "Copy" is behavioural throughout; §3 shows that nothing more is identifiable from input–output data. A **near-copy** is a program with a small Hellinger gap ${\Hel}_\mu(\pi)=\Ex_x\Hel(\nu_H(\cdot\mid x),\nu_\pi(\cdot\mid x))$, Paper 2's measure of distance from the sampler.
* **An alien** is any program of the class that is not a copy. Nothing is assumed about how it computes. In §4 the reference point is a shortest copy $\pi_H\in\mathcal E_0$, with risk $R_H$. An alien's *advantage* is $R_H-R(\pi)$ in population, or $L_n(\pi_H)-L_n(\pi)$ on a sample. For $\ell(\pi)>\ell_0$ its **advantage per bit**, or *rate*, is
  $$r(\pi):=\frac{R_H-R(\pi)}{\ell(\pi)-\ell_0}.$$
* **The human's left steepness and right secant** in population, at the point $(\ell_0,R_H)$:
  $$s_-(H):=\min_{\ell(\pi)<\ell_0}\frac{R(\pi)-R_H}{\ell_0-\ell(\pi)},\qquad s_+(H):=\max\Big\{0,\ \sup_{\ell(\pi)>\ell_0}r(\pi)\Big\}$$
  ($\min\emptyset:=\infty$). These are the left steepness and right secant of `def:kink:kinks` at that point, in the population reading.

### 1.2 Four ways to fail to copy a human, and where each is treated

| failure mode (author's words in quotes) | what it is formally | what handles it | where |
|---|---|---|---|
| "the sampler with some bits specified" | a partial fill-in: the human's kernel with some sampled answers stored | λ > 1 and per-query answers (fixed λ), or any $\lambda_n=o(n)$ per query | Thm 2.2, Rem 3.4 |
| "some completely alien system that just thinks about what the human would say": a learner | an in-context learner, a mixture over humans that infers which human it faces | a hypothesis class without memory across queries (product class) or across episodes; nothing in the data | Rem 2.4, §5 |
| the same, as a fixed predictor computing the human's law differently | a behaviourally equivalent program | nothing in the data; only data about more than the answers, or a restricted class | §3 |
| "alien thinking about the environment around the human" that predicts better | a program exploiting environment-driven coins | λ = cn in a window, if the coupling is incompressible and much larger than the human; nothing if it is cheap or entangled with the human | §4 |

---

## 2. (a) Private coins: robust against every program

### 2.1 The Ville lemma with side information

**Definition 2.0 (side information, privacy, predictors).** On one probability space take queries $x_1,x_2,\dots\in X$, labels $y_1,y_2,\dots\in Y$, and σ-algebras $\mathcal A_1\subseteq\mathcal A_2\subseteq\cdots$ ("what a hypothesis may know before $y_i$ is drawn") with $x_i$ $\mathcal A_i$-measurable and $y_i$ $\mathcal A_{i+1}$-measurable. $\mathcal A_i$ may contain the earlier inputs and labels, environment features $z_i$ observed together with $x_i$, and any other environment variables, past or future, that the human never sees. Where a product class on the extended input $(x,z)$ is used (Theorem 2.2(2),(3), Proposition 2.3), $z$ ranges over a countable set, so that $(x,z)$ is an input of $\Hcl{\times}$.
* **(Priv)** For every $i$: $\Pr[y_i=y\mid\mathcal A_i]=\nu_H(y\mid x_i)$ almost surely. In words: given the human's own input, the human's answer is independent of everything a hypothesis may know.
* A **predictor** π assigns to each $i$ an $\mathcal A_i$-measurable sub-probability $q_{\pi,i}$ on $Y$. Its fit is $L_n(\pi):=-\sum_{i\le n}\log q_{\pi,i}(y_i)$; the human's is $L_n(\nu_H):=-\sum_{i\le n}\log\nu_H(y_i\mid x_i)$.
* Product hypotheses on $x$ or on $(x,z)$, chronological hypotheses, and hypotheses that model the whole environment are all predictors. Nothing is assumed about how $q_{\pi,i}$ is computed, or whether it is computable.

**Lemma 2.1 (Ville deficiency with side information)** [proved; known in substance: this is Ville's inequality for a countable mixture of predictable forecasters against the true conditional law, which (Priv) makes $\nu_H$; the argument is Paper 2's `lem:split:ville` with a larger filtration; the side-information reading is the point]. Assume (Priv). Let $\mathcal C$ be a countable family of predictors with $\sum_{\pi\in\mathcal C}2^{-\ell(\pi)}\le1$, and put $\xi_n:=\sum_\pi2^{-\ell(\pi)-L_n(\pi)}$, $\delta_n:=\log\big(\xi_n\,2^{L_n(\nu_H)}\big)$ and $\delta^*:=\sup_{n\ge0}\delta_n$. Then $\Pr[\delta^*\ge j]\le M_02^{-j}\le2^{-j}$ for every $j\ge0$, with $M_0:=\sum_\pi2^{-\ell(\pi)}$, and for every $\pi\in\mathcal C$ and every $n$,
$$L_n(\pi)\ \ge\ L_n(\nu_H)-\ell(\pi)-\delta_n\ \ge\ L_n(\nu_H)-\ell(\pi)-\delta^*.$$
The human need not belong to $\mathcal C$.

*Proof.* Almost surely $\nu_H(y_i\mid x_i)>0$ for all $i$, so $M_n:=\xi_n2^{L_n(\nu_H)}=\sum_\pi2^{-\ell(\pi)}\prod_{i\le n}q_{\pi,i}(y_i)/\nu_H(y_i\mid x_i)$ is well defined. $M_n$ is $\mathcal A_{n+1}$-measurable. By (Priv) and monotone convergence,
$$\Ex[M_{n+1}\mid\mathcal A_{n+1}]=\sum_\pi2^{-\ell(\pi)}\prod_{i\le n}\frac{q_{\pi,i}(y_i)}{\nu_H(y_i\mid x_i)}\sum_{y:\nu_H(y\mid x_{n+1})>0}q_{\pi,n+1}(y)\ \le\ M_n .$$
So $(M_n)$ is a nonnegative supermartingale for $(\mathcal A_{n+1})_n$ with $M_0\le1$, and Ville's maximal inequality \[Ville 1939\] gives $\Pr[\sup_nM_n\ge2^j]\le M_02^{-j}$. Keeping one term, $2^{-\ell(\pi)}2^{L_n(\nu_H)-L_n(\pi)}\le M_n=2^{\delta_n}$. ∎

**Reading.** An alien may model the environment in arbitrary detail, see the past, even see future environment variables. As long as the human's coins are independent of what it sees, given the human's input, its cumulative gain over the human is at most its own length plus δ*, at every sample size, simultaneously for all aliens.
* [computed: r1(A)] 3000 runs of $n=2000$, in a class with Kraft sum $M_0=0.125$: aliens that see a 10-valued environment variable, a fixed random 80-cell rate table, and a history-aware Krichevsky–Trofimov learner per (input, environment) cell. $\Pr_{\rm emp}[\delta^*\ge j]=0.0333,0.0177,0.0090,0.0047,0.0017,0.0003$ for $j=1,2,3,4,6,8$, below $M_02^{-j}=0.0625,0.0313,0.0156,0.0078,0.0020,0.0005$ at every $j$.
* [referee: rb1(P)] exact enumeration of all paths with predictors that read the next environment value: $\Ex M_n=M_0$ at every $n$, and the Ville ratio is at most 0.460.
* The inequality "no program's gain exceeded its length plus δ*" printed by r1(A) holds on every path by the definition of δ*, so it is not evidence (B10).

### 2.2 Recovery

**Theorem 2.2 (robust recovery of a human with private coins)** [proved: Paper 2's `thm:split:private` and `thm:recovery:main`, with Lemma 2.1 in place of `lem:split:ville`; part 2 and the side-information reading are new]. Assume (Priv), and let $\mathcal C$ be a countable family of predictors with Kraft weights that contains a program $\pi_H$ of length $k$ with $q_{\pi_H,i}=\nu_H(\cdot\mid x_i)$.
1. *(Every $n$, any input rule.)* For fixed λ > 1, simultaneously for all $n$:
   * every λ-MAP $\hat\pi$ has $\ell(\hat\pi)\le(\lambda k+\delta^*)/(\lambda-1)$ and $L_n(\nu_H)-\ell(\hat\pi)-\delta^*\le L_n(\hat\pi)\le L_n(\nu_H)+\lambda k$;
   * the power posterior gives programs longer than $\bar\ell$ mass at most $2^{\lambda k+\delta^*-(\lambda-1)\bar\ell}$;
   * every *fill-in* (a predictor giving the realised answers probability 1) has length at least $L_n(\nu_H)-\delta^*$, and all fill-ins together have power-posterior mass at most $2^{\lambda k+\lambda\delta^*-(\lambda-1)L_n(\nu_H)}$.
2. *(Population.)* If the pairs $(x_i,z_i)$ are i.i.d. and the predictors are product hypotheses on the extended input $(x,z)$, then $R(\pi)-R(\pi_H)=\Ex_{x,z}\KL\big(\nu_H(\cdot\mid x)\,\Vert\,\nu_\pi(\cdot\mid x,z)\big)\ge0$, with equality iff $\nu_\pi(\cdot\mid x,z)=\nu_H(\cdot\mid x)$ almost everywhere. No alien predicts better in population.
3. *(Per query, product class.)* In the setting of 2, Theorem A (`thm:recovery:main`) holds with the input $(x,z)$ and the sampler $\tilde\nu(y\mid x,z):=\nu_H(y\mid x)$:
   * for every schedule $1\le\lambda_n=o(n)$, almost surely the set of $\lambda_n$-MAPs is eventually $\mathcal E_0$, the shortest programs whose kernel equals the human's almost everywhere;
   * for fixed λ > 1 it is $\mathcal E_0$ with probability at least $1-\varepsilon$ at every $n\ge\lambda(\ell_0+\log(2/\varepsilon))\ln2/(2\min(1,\lambda-1)\gamma)$, with γ the margin of `thm:recovery:main`(d).
4. *(Any predictors.)* If infinitely many queries are made, then for every fixed λ ≥ 1, almost surely from some $n$ on every λ-MAP is $\nu_H$-equivalent on the run: $\sum_i\Hel\big(\nu_H(\cdot\mid x_i),q_{\pi,i}\big)<\infty$.

*Proof.* (1) For a λ-MAP, $\lambda\ell(\hat\pi)+L_n(\hat\pi)\le J_\lambda(\pi_H)=\lambda k+L_n(\nu_H)$; insert Lemma 2.1 to get the length bound, and rearrange for the fits. Divide all posterior weights by $2^{-L_n(\nu_H)}$; the normaliser is then at least $2^{-\lambda k}$. Programs longer than $\bar\ell$: $\sum_{\ell(\pi)>\bar\ell}2^{-\lambda\ell(\pi)}2^{L_n(\nu_H)-L_n(\pi)}\le2^{-(\lambda-1)\bar\ell}M_n\le2^{-(\lambda-1)\bar\ell+\delta^*}$. A fill-in has $L_n=0$, so Lemma 2.1 gives $\ell\ge L_n(\nu_H)-\delta^*$, and $\sum_{\rm fill\text{-}ins}2^{-\lambda\ell}2^{L_n(\nu_H)}\le2^{-(\lambda-1)(L_n(\nu_H)-\delta^*)}M_n\le2^{-(\lambda-1)L_n(\nu_H)+\lambda\delta^*}$. This is the proof of `thm:split:private`(i)–(iii) with Lemma 2.1.
(2) Under (Priv), $y$ given $(x,z)$ has law $\nu_H(\cdot\mid x)$, so $R(\pi)-R(\pi_H)=\Ex_{x,z}\sum_y\nu_H(y\mid x)\log\frac{\nu_H(y\mid x)}{\nu_\pi(y\mid x,z)}$; Gibbs' inequality with $\sum_y\nu_\pi\le1$ gives $\ge0$, with equality iff the two agree (`lem:recovery:ratios`(c)).
(3) With i.i.d. $(x_i,z_i)$ on a countable set and (Priv), the triples are per-query data on the input set of pairs, i.i.d. from $\tilde\mu\otimes\tilde\nu$; apply `thm:recovery:main`.
(4) The proof of `thm:split:private`(iv) uses two facts, both valid here. First, the tail sums $Z^{\bar\ell}_n:=\sum_{\ell(\pi)>\bar\ell}2^{-\ell(\pi)}\Lambda_n(\pi)$, $\Lambda_n(\pi):=2^{L_n(\nu_H)-L_n(\pi)}$, are nonnegative supermartingales started at the prior tail, by the computation in Lemma 2.1; this confines the λ-MAPs to a finite set. Second, for each program, $g_{n+1}:=\Hel(\nu_H(\cdot\mid x_{n+1}),q_{\pi,n+1})$ is $\mathcal A_{n+1}$-measurable with $\Ex[\sqrt{\Lambda_{n+1}/\Lambda_n}\mid\mathcal A_{n+1}]=1-g_{n+1}$ by (Priv), so `lem:recovery:ratios`(b) gives $\Lambda_n(\pi)\to0$ on $\{\sum_ig_i=\infty\}$. ∎

**Proposition 2.3 (the privacy dichotomy)** [proved, new]. Let $(x_i,z_i,y_i)$ be i.i.d. from a law $P$, $z$ in a countable set, the learner see $(x_i,z_i)$, and the human's kernel be calibrated, $\nu_H(y\mid x)=P(y\mid x)$. Put $I:=I(Y;Z\mid X)$ in bits.
* (a) If $I=0$, (Priv) holds with $\mathcal A_i:=\sigma\big((x_j,z_j)_{j\ge1},(y_j)_{j<i}\big)$, future inputs and environment variables included. So Lemma 2.1 and Theorem 2.2 apply: almost surely $\sup_n\max_\pi\big[L_n(\nu_H)-L_n(\pi)-\ell(\pi)\big]\le\delta^*<\infty$.
* (b) If $I>0$ and the class contains a program $\pi^*$ with $\nu_{\pi^*}(y\mid x,z)=P(y\mid x,z)$ almost surely, then $\frac1n\big[L_n(\nu_H)-L_n(\pi^*)\big]\to I$ almost surely, so the gain of $\pi^*$ minus its length tends to $+\infty$. For every schedule $\lambda_n=o(n)$, almost surely every copy of the human is a $\lambda_n$-MAP for only finitely many $n$. (Which alien is then selected is not settled by this argument: in r1(B) a history-aware learner also gains linearly, 1414–1425 bits by $n=2000$ against 1665–1676 for $\pi^*$.) In $\Hcl{\times}$ such a $\pi^*$ exists whenever $P(y\mid x,z)$ is computable.

*Proof.* (a) $I=0$ means $P(y\mid x,z)=P(y\mid x)$ almost surely; independence across $i$ lets the other indices be added to the conditioning. (b) The variables $D_i:=\log\big(P(y_i\mid x_i,z_i)/P(y_i\mid x_i)\big)$ are i.i.d. with mean $I$. Their positive part is at most $\log(1/P(y_i\mid x_i))$, of mean $H(Y\mid X)\le\log|Y|$. Their negative part is integrable, by $\Ex(\log Z)^+\le\log e/e$ for $Z:=P(y\mid x)/P(y\mid x,z)$, $\Ex[Z\mid x,z]\le1$ (`lem:recovery:ratios`(c)). The strong law gives the limit. A copy π of the human has the human's fits almost surely, so $\frac1n[J_{\lambda_n}(\pi)-J_{\lambda_n}(\pi^*)]=\frac{\lambda_n}n(\ell(\pi)-\ell(\pi^*))+\frac1n[L_n(\nu_H)-L_n(\pi^*)]\to I>0$. ∎

"Privacy is exactly the condition" presupposes a calibrated human. In the latent-cause reading of §4 privacy fails through $x$ itself: $P^*\ne\nu_H$.

[computed: r1(B): coins a deterministic function of the environment variable, calibrated, $I=0.8272$ bits per sample. The exploiting alien's gain is $1672.4$, $1665.0$, $1676.1$ at $n=2000$, against $nI=1654.3$. At λ = 2 it first beats the human at $n=187,194,195$ (predicted $\lambda\Delta/I=193$), at λ = 4 at $n=386,366,400$ (predicted 387).] [referee: rb1(L),(X): if a variable correlated with $y_i$ is visible to one predictor, $\Ex M_n$ grows above $M_0$; and with $y=x\oplus z$, $z$ independent of $y$ and $x$ independent of $y$, the gain is linear. So independence of the coin from each visible variable separately is not enough, as (Priv) states.]

**Remark 2.4 (two halves of robustness; learners)** [remark, from proved results; computed]. "Robust against every program" has two halves.
* **(R1)** No program gains more than its length plus δ* (Lemma 2.1). This holds in every class, for every kind of predictor.
* **(R2)** Every program *shorter* than the human that is not a copy loses an amount that grows without bound. In product classes with i.i.d. queries it grows linearly, at the KL rate (Theorem 2.2(3)).
* **(R2) fails for an in-context learner.** A Bayes mixture over humans that contains the human with weight $w$ loses at most $\log(1/w)$ bits in total. Such a learner is the formal version of "a completely alien system that just thinks about what the human would say".
* **What excludes it is the hypothesis class, not the data.** The learner is a single hypothesis exactly when hypotheses can carry information across queries. In the product class $\Hcl{\times}$ they cannot, by its definition (`cor:absorb:nouniversal`). In a history-aware class they can, even when the human's coins are i.i.d. and private, and then the learner absorbs the human (Proposition 5.2, whose bound holds for every data set).
  * [referee: rb5(A)] i.i.d. private-coin data, $x$ uniform on four values; a history-aware class with 2401 product kernels of length 20, their Bayes mixture of length 10, and a coin. At λ = 2 the mixture is the MAP in 20 of 20 runs at $n=10^3,10^4,10^5$, and the human's program is never selected. Without the mixture (a product class) the human's program is the MAP in 19 of 20 runs at $n=10^3$ and 20 of 20 from $10^4$ on.
  * In such a class Theorem 2.2(4) still holds: the selected learner is $\nu_H$-equivalent on the run. [referee: ra1(D): in r5's setting the mixture's cumulative Hellinger gap is 1.14, 2.20, 1.02 at $n=4000$ on three trajectories, flat after $n\approx2000$; a memoryless sampler reaches about 100.] What fails is only that the selected program is a copy.
* A parametric learner with regret growing like $\log n$ is rejected eventually at fixed λ; a countable mixture that contains the human is not. [computed: r1(C): a Krichevsky–Trofimov learner over 80 cells, of length 6 against the human's 4, has regret $7.7$, $121$, $194$, $274$ bits at $n=10^2,10^3,5\cdot10^3,2\cdot10^4$; this is 60–86 % of $40\log(n/80)$, the leading term for 80 parameters.]

---

## 3. (b) Behavioural non-identifiability

**Proposition 3.1 (what input–output data identify)** [proved, new; elementary]. Per-query data with inputs i.i.d. from μ.
* (a) If $\nu_{\pi_1}=\nu_{\pi_2}$ at μ-almost every input, then almost surely $L_n(\pi_1)=L_n(\pi_2)$ for all $n$. So for every λ > 0 and every $n$, $J_\lambda(\pi_1)-J_\lambda(\pi_2)=\lambda(\ell(\pi_1)-\ell(\pi_2))$, and the power-posterior odds are $2^{-\lambda(\ell(\pi_1)-\ell(\pi_2))}$, whatever the data.
* (b) *No procedure separates them.* Let two worlds have the same input law μ and humans whose kernels agree μ-almost everywhere, with any mechanisms and any behaviour off the support of μ. The data have the same law in both worlds, so every procedure Ψ (any measurable function of the data, randomised or not) has the same output law in both. For disjoint sets $A_1,A_2$ of programs, $\Pr_{W_1}[\Psi\in A_1]+\Pr_{W_2}[\Psi\in A_2]\le1$.
* (c) *What is identified.* The kernel at μ-almost every input: for every $1\le\lambda_n=o(n)$ the $\lambda_n$-MAPs are eventually exactly $\mathcal E_0$, the shortest copies in the class (Theorem A). Not identified: which member of $\mathcal E$ is "the human's program", the kernel off the support of μ, and anything internal.

*Proof.* (a) The likelihood factors agree whenever $x_i$ lies in the agreement set, which holds for all $i$ almost surely. (b) In both worlds the data are i.i.d. from $\mu\otimes\nu_H$. (c) `thm:recovery:main`(a). ∎

With frozen answers (FR) even the kernel at an atom with noise is not identifiable by any procedure (`prop:recovery:frozen`(a)). So exact behavioural copies need per-query answers: the human answers a repeated question afresh.

**Example 3.2 (an alien that computes the human's law more compactly)** [example; r4(A) confirms numbers that hold by construction]. Inputs $w$ uniform on $\{0,1\}^6$. The "human" computes the parity of *all* bits of its input by a long-winded procedure and flips it with probability $1/8$; the "alien" computes the parity of the first six bits directly, with the same flip. The two are given lengths 40 and 20 bits (assigned, not derived from a code; only the difference matters). On $\{0,1\}^6$ the kernels coincide; on an input of length 7, never queried, they differ. So the fits are equal at every $n$, $J(\text{human})-J(\text{alien})=20\lambda$, and the alien is selected at every $n$ and every λ ≥ 1. The selected program's extrapolation to the input $(1,0,0,0,0,0,1)$ is the alien's (mode 1), not the human's (mode 0).

**Proposition 3.3 (what separates a copy from an equivalent alien)** [proved, new; elementary]. Let $\pi_1,\pi_2$ have equal kernels μ-almost everywhere.
* (a) *More observed per query.* If each query also returns an observable $\tau_i\in T$ drawn jointly with $y_i$ from the human's kernel $\nu_H(y,\tau\mid x)$ (a report, a reaction time, a recorded internal signal), and the hypotheses are kernels on $Y\times T$, Theorem A applies with the label set $Y\times T$. Programs that agree on $y$ but not on τ are then separated.
* (b) *More varied per query.* If the inputs are enlarged, to inputs where $\pi_1$ and $\pi_2$ differ, or to pairs $(x,\iota)$ in which ι is a manipulation of the human's situation that the hypotheses take as part of their input, Theorem A applies with the enlarged input whenever the separating inputs have positive probability. For kernels of $\Hcl{\times}$, an "intervention on an internal variable" has no meaning beyond this: it is an enlarged input on which the two programs' kernels differ.
* (c) *What (a) and (b) give.* They are one statement: the data identify the kernel of whatever is observed, under whatever is varied. The selected program is then a shortest program for *that* enlarged kernel, which can again be a non-human mechanism. Mechanism is identified only as far as the enlarged observation pins it down.
* (d) *A restricted class.* If every program of the class whose kernel equals the human's is longer than $\pi_H$, for example because every such program consists of the human's model plus extra computation, then $\mathcal E_0=\{\pi_H\}$ and Theorem A returns $\pi_H$ itself. This is an assumption about the class, which by Proposition 3.1(b) no data can check.
* (e) *What does not help:* more data from the same μ, any schedule $\lambda_n$, or any prior that depends on programs only through their length. Within $\mathcal E$ all of them order programs by length alone (Proposition 3.1(a)).

*Proof.* (a), (b) are `thm:recovery:main` with the enlarged label or input set; (c) is (a), (b) and Proposition 3.1 applied to the enlarged kernel; (d) is the definition of $\mathcal E_0$; (e) is Proposition 3.1. ∎

**Remark 3.4 (the sampler with some bits specified)** [proved: Paper 2's `prop:recovery:frozen`(c) and `thm:recovery:main`(a); computed: r4(C), f4(C); referee: ra1(E), rb6(A)]. A *partial fill-in* is the human's kernel with the answers at a finite set of inputs stored. Per query it differs from the human at an atom of μ, so it is eventually rejected for every $1\le\lambda_n=o(n)$; with frozen answers it can be selected forever.
* In Paper 2's class (μ uniform on ten inputs, the human $\mathrm{Bern}(1/64)$ of length 5, the exception programs $e_j$ of length 9, λ = 1.2): with frozen answers some $e_j$ is eventually the MAP with probability exactly $1-(63/64)^{10}=0.1457$.
* Per query, $\Pr_n[\text{some }e_j\text{ is a λ-MAP}]\le10\big((9/10+1/640)^n-(9/10)^n\big)$: $5.0\cdot10^{-5}$ at $n=100$ and $5.0\cdot10^{-18}$ at $n=400$. The bound is essentially exact: the exact probability, by inclusion–exclusion in rational arithmetic, is 0.973 of it at $n=10$ and 0.999992 of it at $n=100$ [referee: ra1(E), rb6(A)].
* In 20,000 simulated runs some $e_j$ was a MAP at some time in a fraction 0.1465 of them, after time 100 in 0.0001, and never after time 113. The first figure is the probability that some input's *first* label is 1 (the only way an $e_j$ is ever a MAP early on), which is $1-(1-(1-0.9^{400})/64)^{10}=0.145709$ exactly [referee: rb6(A)], the frozen value to four digits.

---

## 4. (c) Environment-driven coins: aliens predict better, and a window returns a near-copy anyway

### 4.1 The setting

**Setting 4.1 (environment-driven coins; revised).**
* **Environment.** $Y$ and $B$ (the human's coin values) are finite. The *coupling variable* $w$ is uniform on $W:=\{0,1\}^m$. Given $w$, the human's input $x$, in a countable set $X$, is drawn from a law $\mu(\cdot\mid w)$ with finite support and rational masses. The *channel* $\mu:=(\mu(\cdot\mid w))_{w\in W}$ is a finite object; $m$ and the finite set $\supp\mu:=\bigcup_w\supp\mu(\cdot\mid w)$ are computable from it. The input law is $\bar\mu:=2^{-m}\sum_w\mu(\cdot\mid w)$.
* **The human.** A coin law ρ on $B$ with $\rho(b)>0$ and $\rho(b)2^m\in\mathbb Z$; a response function $h:\supp\mu\times B\to Y$, injective in $b$ for each $x$. Its kernel, the human's own description of how it answers, is
  $$\nu_H(y\mid x):=\rho(b)\ \text{ if } y=h(x,b),\qquad 0\text{ otherwise}\qquad(x\in\supp\mu).$$
  The **human's model** $h_0:=(h,\rho)$ is a finite object (a canonical encoding of the table of $h$ on $\supp\mu\times B$ and of ρ), so $K(h_0)$ and $K(h_0\mid\cdot)$ are well defined (A-m8). $B$ is labelled so that ρ is non-increasing.
* **Copies and the reference point.** $\mathcal E$ is the set of programs of $\Hcl{\times}$ whose kernel equals $\nu_H$ on $\supp\mu$; $\ell_0:=\min_{\mathcal E}\ell$; $\pi_H\in\mathcal E_0$ is a fixed shortest copy. Put
  $$t_H:=K(h_0\mid\pi_H,\mu),\qquad D_0:=\ell_0-K(h_0\mid\mu).$$
  * $t_H\le\kappa$ when ρ's values are pairwise distinct. From $(\pi_H,\mu)$ compute $\supp\mu$ and $m$. For $x\in\supp\mu$, $\nu_{\pi_H}(\cdot\mid x)$ is a probability on the finite $Y$, hence computable (lower approximations and total mass 1). Its values are multiples of $2^{-m}$, so they are found exactly; the multiset of positive values is ρ, and $h(x,b)$ is the label of mass $\rho(b)$. With ties in ρ, $t_H$ also pays for which tied label is which coin, input by input; that information is not determined by the human's kernel.
  * $-t_H-\kappa\le D_0\le K(h_0)-K(h_0\mid\mu)+\kappa$. The left inequality is $K(h_0\mid\mu)\le K(\pi_H\mid\mu)+t_H+\kappa\le\ell_0+t_H+\kappa$ by (F3), (F1). The right one holds because a program that reads a shortest description of $h_0$ and outputs $\nu_H$ on the domain of $h$ (and nothing elsewhere) is a copy. So $D_0$ is at most the information μ carries about the human's model, $K(h_0)-K(h_0\mid\mu)$; it is small in the intended reading, where the human's model and the environment's channel share little.
* **The world.** A fixed *coupling* $\beta:W\to B$ with exact type ρ, $|\beta^{-1}(b)|=\rho(b)2^m$. At each query $w_i$ is uniform, $x_i\sim\mu(\cdot\mid w_i)$, and $y_i:=h(x_i,\beta(w_i))$: the human's coin is $\beta(w_i)$. The learner sees $(x_i,y_i)$, i.i.d. from $\bar\mu\otimes P^*$ with the *data kernel* $P^*(y\mid x):=\sum_w\mu(x\mid w)\ind[y=h(x,\beta(w))]/\sum_w\mu(x\mid w)$. $P^*$ differs from $\nu_H$ whenever $x$ carries information about $w$.
* **Three readings** (the brief's three mechanisms):
  * *Feature*: $x=(w,x')$ with $\mu(\cdot\mid w)=\delta_w\otimes\mu'$. The learner sees the environment feature $w$; the human ignores it. $P^*$ is deterministic.
  * *Latent shared cause*: $w$ unobserved, $x$ a noisy function of $w$.
  * *Pseudo-random generator*: β has a short description (Proposition 4.10(c)).
  * Paper 2's teacher instance (`def:teacher:instance`) is the feature case with $w$ the first $m$ bits of $x\in\{0,1\}^d$, $h(x,b)=f_a(x)\oplus b$, $\rho=\mathrm{Bern}(p)$ and $\beta=\ind_S$: a teacher's systematic errors are, formally, environment-driven coins.
* **Description lengths.** $L_\beta:=\log\big(2^m!/\prod_b(\rho(b)2^m)!\big)$, the log-size of the type class. $B_\beta:=K(\beta\mid h_0,\mu,K(h_0\mid\mu))$, and the deficiency $\delta_\beta:=L_\beta-B_\beta$. The information of a program about the coupling is $I_\beta(\pi):=B_\beta-K(\beta\mid h_0,\pi,\mu)$.
  * $\delta_\beta\ge-1-\kappa$: given $h_0$ and μ, the type class is known, and β is its index of fixed length $\lceil L_\beta\rceil$ (B11).
  * For β uniform on the type class, independent of $(h_0,\mu)$: $\Pr[\delta_\beta>j]<2^{-j}$.
  * $2^mH(\rho)-|B|\log(2^m+1)\le L_\beta\le2^mH(\rho)$ [known: the type-class bounds, Cover and Thomas; computed: r6(B)].
* **Population quantities.** $R(\pi):=\Ex[-\log\nu_\pi(y_i\mid x_i)]=2^{-m}\sum_w\sum_x\mu(x\mid w)\big(-\log\nu_\pi(h(x,\beta(w))\mid x)\big)$. Every copy has $R=H(\rho)$, because β has exact type ρ [computed: r6(A)]. $H_W(Y\mid X):=\Ex[-\log P^*(y\mid x)]$ is the best possible risk, 0 in the feature case.
* **Behavioural distance from the human.** $D_{1/2}(P\Vert Q):=-2\log\sum_y\sqrt{P(y)Q(y)}\ge0$, the Rényi divergence of order ½, also for a sub-probability $Q$. For a program π,
  $$\Ex_{x\sim\bar\mu}D_{1/2}\big(\nu_H(\cdot\mid x)\Vert\nu_\pi(\cdot\mid x)\big)\ \ge\ \frac{2}{\ln2}\,{\Hel}_{\bar\mu}(\pi),\qquad \Ex_{x\sim\bar\mu}\mathrm{TV}\big(\nu_H(\cdot\mid x),\nu_\pi(\cdot\mid x)\big)\le\sqrt{2\,{\Hel}_{\bar\mu}(\pi)},$$
  with ${\Hel}_{\bar\mu}$ Paper 2's Hellinger gap and $\mathrm{TV}(P,Q):=\frac12\sum_y|P(y)-Q(y)|$. Both vanish iff $\pi\in\mathcal E$. The first is $-2\log(1-\Hel)\ge2\Hel/\ln2$. The second is $\frac12\sum|P-Q|\le\frac12\big(\sum(\sqrt P-\sqrt Q)^2\big)^{1/2}\big(\sum(\sqrt P+\sqrt Q)^2\big)^{1/2}\le\frac12\sqrt{2\Hel}\cdot2$, followed by Jensen's inequality.

**Why condition on μ** (A-M3, B-B1). In `notes.md` the human's program had to encode the channel μ, so a shorter copy that does not encode it broke the left condition, and in the latent-cause reading every offset grew by $K(\mu\mid h,\rho)$. Programs here are not given μ; the conditioning enters only the complexity bookkeeping of Lemmas 4.4–4.6. The reference point is a shortest copy, whatever it encodes. The price is the term $D_0$, which is at most the information μ carries about the human's model.

A **copy** has kernel $\nu_H$; the "aliens that predict better" are the programs with $R(\pi)<H(\rho)$.

### 4.2 Consistent schedules learn the environment; λ = cn compares rates

**Proposition 4.2 (fixed λ and every λ_n = o(n) select an alien)** [proved; (b) is Theorem A].
* (a) If some program $\pi_A$ has $R(\pi_A)<H(\rho)$, then for every schedule $\lambda_n>0$ with $\lambda_n/n\to0$, almost surely every copy of the human is a $\lambda_n$-MAP for only finitely many $n$.
* (b) In $\Hcl{\times}$, $P^*$ is computable from $(h_0,\mu,\beta)$, so it has programs. For every $1\le\lambda_n=o(n)$ the $\lambda_n$-MAPs are eventually exactly the shortest programs for $P^*$. If $P^*\ne\nu_H$ on a set of positive $\bar\mu$-mass (that is, $x$ carries information about $w$; A-m10), these are aliens; if $x$ is independent of $w$, then $P^*=\nu_H$ and they are copies.

*Proof.* (a) For a copy π, $\frac1n[J_{\lambda_n}(\pi)-J_{\lambda_n}(\pi_A)]=\frac{\lambda_n}n(\ell(\pi)-\ell(\pi_A))+\hat R_n(\pi)-\hat R_n(\pi_A)\to H(\rho)-R(\pi_A)>0$ almost surely, by the strong law for the two empirical risks, which have finite means. (b) `thm:recovery:main`(a) with the sampler $P^*$. ∎

[computed: r3, unchanged in f3: with the coins driven by 64 of 1024 cells, fixed λ = 2 selects the human-type program at $n\le1000$ and the full memoriser of β from $n=3000$ on; λ = 8 switches between $n=3000$ and $10^4$; $\lambda=\sqrt n$ keeps the human up to $n=10^6$ and selects the memoriser at $3\cdot10^6$ and $10^7$, as predicted by $\sqrt n\,\Delta=nH(p)$ at $n\approx(\Delta/H(p))^2\approx1.1\cdot10^6$ with $\Delta=355$ bits.]

**Proposition 4.3 (λ = cn: selection is a rate condition)** [proved: Paper 2's `lem:setup:hull`, population reading]. Let $c>0$ and let $\pi_H$ be a shortest copy.
* For every program π longer than $\ell_0$: $J_c(\pi)>J_c(\pi_H)$ iff $c>r(\pi)$.
* For π shorter than $\ell_0$: $J_c(\pi)>J_c(\pi_H)$ iff $c<(R(\pi)-R_H)/(\ell_0-\ell(\pi))$.
* For π of length $\ell_0$: iff $R(\pi)>R_H$.

So the shortest copies are exactly the minimisers of $J_c$ iff $s_+(H)<c<s_-(H)$ and every non-copy of length $\ell_0$ has risk above $R_H$. When $s_+(H)>0$ the supremum defining it is attained. By `lem:setup:hull`(iii), this happens on a nonempty open interval of $c$ iff the point $(\ell_0,R_H)$ is a vertex of the population hull that only copies share.

*Proof.* $J_c(\pi)-J_c(\pi_H)=c(\ell(\pi)-\ell_0)+R(\pi)-R_H$, rearranged in each case. The $\min$ in $s_-$ is over finitely many programs. If some program has rate $s>0$, every program with rate at least $s$ has $0\le R(\pi)\le R_H-s(\ell(\pi)-\ell_0)$, hence length at most $\ell_0+R_H/s$; only finitely many qualify, so the supremum is a maximum. ∎

**Reading.** For $J_c$-minimisers this is a restatement of the hull lemma: the procedure with $\lambda=cn$ keeps the human against exactly the aliens whose rate is below $c$. The non-trivial content of §4 is the bound on the rates that aliens can have: by Lemma 4.5, every program $x$ bits longer than $\ell_0$ has $r(\pi)\le2^{-m}(1+G/x)$, whatever its internal structure. Whether the advantage per bit is the right quantity *for every procedure* is a different question, answered no by Proposition 4.10(a3).

### 4.3 Three coding lemmas

**Lemma 4.4 (alien coding lemma)** [proved, new; generalises Paper 2's `lem:teacher:coding` from parities to any response function, coin set and input channel, by a simpler proof: an arithmetic mean and Jensen's inequality in place of Paper 2's truncated geometric mean]. In Setting 4.1, for every $\pi\in\Hcl{\times}$,
$$K(\beta\mid h_0,\pi,\mu)\ \le\ 2^mR(\pi)+\kappa .$$

*Proof.* Given $(\pi,h_0,\mu)$ define, for $w\in W$ and $b\in B$, $q_w(b):=\sum_x\mu(x\mid w)\,\nu_\pi(h(x,b)\mid x)$, a finite sum, lower semicomputable uniformly in $(\pi,h_0,\mu)$. By injectivity, $\sum_bq_w(b)\le\sum_x\mu(x\mid w)\sum_y\nu_\pi(y\mid x)\le1$. So $Q(\beta'):=\prod_wq_w(\beta'(w))$ is a semimeasure on $B^W$, lower semicomputable uniformly, and (F2) gives $K(\beta\mid\pi,h_0,\mu)\le-\log Q(\beta)+\kappa$. By Jensen's inequality for the convex $-\log$,
$$-\log Q(\beta)=\sum_w-\log\Ex_{x\sim\mu(\cdot\mid w)}\nu_\pi(h(x,\beta(w))\mid x)\ \le\ \sum_w\Ex_{x\sim\mu(\cdot\mid w)}\big[-\log\nu_\pi(h(x,\beta(w))\mid x)\big]=2^mR(\pi).\ ∎$$

$m$ is computable from μ, so no $K(m)$ term arises (B11). Finite support is used only to make $q_w$ a finite sum; an infinite sum of nonnegative lower-semicomputable terms would also be lower semicomputable.

[computed: r6(A): explicit instances with $B=\{0,1,2\}$, $\rho=(\frac12,\frac14,\frac14)$, eight cells, a latent-cause and a feature channel, and 600 random programs (a third of them sub-probabilities): $\max_w\sum_bq_w(b)=1.000000000000$; total mass of $Q$ over all $3^8$ couplings at most $1.000000000000$; $\max[-\log Q(\beta)-2^mR(\pi)]=-0.127<0$; $R(\pi_H)=H(\rho)=1.5$ exactly.] [referee: rb2(A): 2000 random and 3000 adversarial programs near the human; the Jensen gap approaches 0 from below and never crosses it.]

**Lemma 4.5 (right lines of slope $2^{-m}$)** [proved, new; (a)–(c), (e) generalise (D2) of Paper 2's `lem:teacher:twopart`, with $K(h_0\mid\pi,\mu)$ in place of list decoding; (d) is referee A's A1, re-derived in the conditioned setting]. For every $\pi\in\Hcl{\times}$:
* (a) $\ell(\pi)+2^mR(\pi)\ \ge\ K(h_0\mid\mu)+B_\beta-K(h_0\mid\pi,\mu)-\kappa$;
* (b) $I_\beta(\pi)\ \le\ \ell(\pi)-K(h_0\mid\mu)+K(h_0\mid\pi,\mu)+\kappa$, and in particular $I_\beta(\pi)\le\ell(\pi)+\kappa$;
* (c) $\ell(\pi)\ge K(h_0\mid\mu)-K(h_0\mid\pi,\mu)-\kappa$;
* (d) *(the whole class)* $\ell(\pi)-\ell_0\ \ge\ 2^m\big(H(\rho)-R(\pi)\big)-G^*$, with $G^*:=\ell_0+\delta_\beta+|B|\log(2^m+1)+\kappa$;
* (e) *(programs that know the model)* for $t\ge t_H$ and $M_t:=\{\pi:K(h_0\mid\pi,\mu)\le t\}$, every $\pi\in M_t$ has $\ell(\pi)-\ell_0\ \ge\ 2^m\big(H(\rho)-R(\pi)\big)-G_t$, with $G_t:=t+D_0+\delta_\beta+|B|\log(2^m+1)+\kappa$, and $\ell(\pi)\ge\ell_{\rm fl}:=K(h_0\mid\mu)-t-\kappa=\ell_0-D_0-t-\kappa$; and $\pi_H\in M_t$.

In the language of `def:kink:kinks`, with the reference point $(\ell_0,H(\rho))$: the whole class has the right line of slope $2^{-m}$ per sample and offset $G^*/2^m$, with length floor 0; and $M_t$ has the right line with offset $G_t/2^m$ and length floor $\ell_{\rm fl}$. By `lem:kink:secant`(a), every program of the class (resp. of $M_t$) that is $x>0$ bits longer than $\ell_0$ has rate $r(\pi)\le2^{-m}(1+G^*/x)$ (resp. $2^{-m}(1+G_t/x)$).

*Proof.* Relativising (F3), (F4) to the condition μ (the proofs are the unrelativised ones, uniformly in the condition) [known: Li–Vitányi]:
$$K(h_0\mid\mu)+B_\beta-\kappa\ \le\ K(h_0,\beta\mid\mu)\ \le\ K(\pi\mid\mu)+K(h_0\mid\pi,\mu)+K(\beta\mid h_0,\pi,\mu)+\kappa .$$
With $K(\pi\mid\mu)\le\ell(\pi)+\kappa$ (F1) and Lemma 4.4 this is (a); rearranged for $K(\beta\mid h_0,\pi,\mu)$ it is (b), and $K(h_0\mid\pi,\mu)\le K(h_0\mid\mu)+\kappa$ gives its second form. (c) is $K(h_0\mid\mu)\le K(\pi\mid\mu)+K(h_0\mid\pi,\mu)+\kappa$. (d): $B_\beta\le K(\beta\mid h_0,\mu)+\kappa\le\ell(\pi)+K(\beta\mid h_0,\pi,\mu)+\kappa\le\ell(\pi)+2^mR(\pi)+\kappa$; insert $B_\beta=L_\beta-\delta_\beta\ge2^mH(\rho)-|B|\log(2^m+1)-\delta_\beta$ and subtract $\ell_0$. (e): (a) with $K(h_0\mid\pi,\mu)\le t$, $K(h_0\mid\mu)=\ell_0-D_0$ and the same type-class bound; the floor is (c); $\pi_H\in M_t$ because $t\ge t_H$. ∎

**Reading.** (d) bounds every program of the class, whatever its internal structure, by the information it holds: an alien that beats the human by $a$ bits per sample must be about $2^ma$ bits longer, minus an offset of order $\ell_0+\delta_\beta+|B|m$. Computation without information does not help, because an incompressible coupling cannot be computed from fewer bits than it contains. (e) replaces $\ell_0$ by $t+D_0$ for programs that already know the human's model. The offset in (d) cannot be reduced to order $t$ for every human: in the world of Proposition 4.11 it must be about $H(p)\,\ell_0$ [referee: ra1(B): 351 bits $=0.34\,\ell_0$ at $m=10$].

[computed: f7(B), the counting form of (a)/(d) in an explicit class: over all $\binom{16}4=1820$ couplings of a type class and a class of 75,768 programs with Kraft sum 0.951, the fraction of couplings on which some program beats the coding bound by $j$ bits is $0.0088\le0.951\cdot2^{-j}$ for $j\le4$ and 0 for $j\ge5$; the events occur exactly on the 16 couplings that the class describes cheaply (cyclic intervals).] [referee: rb2(B): the same over all 35,960 couplings of $\binom{32}4$ with 7144 structured sets; the window closes on 12.3 % of couplings, all of them structured.]

**Lemma 4.6 (closeness lemma)** [proved, new in revision]. For a program π put, for $w\in W$ and $b\in B$,
$$\tilde q_w(b):=\prod_x\nu_\pi(h(x,b)\mid x)^{\mu(x\mid w)},\qquad \bar D(\pi):=2^{-m}\sum_wD_{1/2}(\rho\Vert\tilde q_w),$$
the geometric mean over the cell's inputs of the probability π gives to coin $b$'s answer, and its average divergence from ρ. Then for every $\pi\in\Hcl{\times}$ with $R(\pi)<\infty$,
$$\Ex_{x\sim\bar\mu}D_{1/2}\big(\nu_H(\cdot\mid x)\Vert\nu_\pi(\cdot\mid x)\big)\ \le\ \bar D(\pi)\ \le\ \big(R(\pi)-H(\rho)\big)+\frac{2\big(I_\beta(\pi)+\delta_\beta+|B|\log(2^m+1)+E_m(\pi)+\kappa\big)}{2^m},$$
with $E_m(\pi):=2\log\big(2^{m-1}(H(\rho)+R(\pi))+1\big)\le2m+2\log(H(\rho)+R(\pi)+1)$.

*Proof.*
1. *Hölder.* Fix $w$. By the generalised Hölder inequality $\sum_b\prod_xf_x(b)^{\theta_x}\le\prod_x(\sum_bf_x(b))^{\theta_x}$ for $\theta_x\ge0$, $\sum_x\theta_x=1$, applied with $\theta_x:=\mu(x\mid w)$ and $f_x(b):=\sqrt{\rho(b)\nu_\pi(h(x,b)\mid x)}$,
   $$\sum_b\sqrt{\rho(b)\tilde q_w(b)}\le\prod_x\Big(\sum_b\sqrt{\rho(b)\nu_\pi(h(x,b)\mid x)}\Big)^{\mu(x\mid w)}.$$
   By injectivity, $\sum_b\sqrt{\rho(b)\nu_\pi(h(x,b)\mid x)}=\sum_y\sqrt{\nu_H(y\mid x)\nu_\pi(y\mid x)}$. Taking $-2\log$, $D_{1/2}(\rho\Vert\tilde q_w)\ge\Ex_{x\sim\mu(\cdot\mid w)}D_{1/2}(\nu_H(\cdot\mid x)\Vert\nu_\pi(\cdot\mid x))$; average over $w$.
2. *A semimeasure.* $\tilde q_w(b)\le q_w(b)$ (geometric against arithmetic mean), so $\sum_b\tilde q_w(b)\le1$ by Lemma 4.4's injectivity step, and $Z_w:=\sum_b\sqrt{\rho(b)\tilde q_w(b)}\le1$ by Cauchy–Schwarz. Put $Q(\beta'):=\prod_w\sqrt{\rho(\beta'(w))\tilde q_w(\beta'(w))}$ on $B^W$; its total mass is $Z:=\prod_wZ_w\le1$. $Q$ is lower semicomputable from $(\pi,h_0,\mu)$: lower approximations of $\nu_\pi$ give increasing approximations of each $\tilde q_w(b)$. $Z\ge Q(\beta)>0$ because $R(\pi)<\infty$.
3. *Normalising.* Let $k:=\lfloor-\log Z\rfloor\ge0$. Then $2^kQ$ is a semimeasure, lower semicomputable from $(\pi,h_0,\mu,k)$, and (F2), (F3), (F5) give
   $$K(\beta\mid h_0,\pi,\mu)\le-\log Q(\beta)-k+K(k)+\kappa\le-\log Q(\beta)+\log Z+1+2\log(k+1)+\kappa .$$
4. *Evaluating.* Exact type gives $\sum_w\log(1/\rho(\beta(w)))=2^mH(\rho)$, and the definition of $R$ gives $\sum_w-\log\tilde q_w(\beta(w))=2^mR(\pi)$. So $-\log Q(\beta)=2^{m-1}(H(\rho)+R(\pi))$, and $\log Z=\sum_w\log Z_w=-2^{m-1}\bar D(\pi)$. Also $k\le-\log Z\le-\log Q(\beta)$, so $2\log(k+1)\le E_m(\pi)$.
5. *Lower bound.* $K(\beta\mid h_0,\pi,\mu)=B_\beta-I_\beta(\pi)\ge2^mH(\rho)-|B|\log(2^m+1)-\delta_\beta-I_\beta(\pi)$. Combining with 3–4 and dividing by $2^{m-1}$ gives the right inequality. ∎

**Reading.** A program that predicts the environment-driven answers no better than the human ($R(\pi)$ close to $H(\rho)$) and holds little information about the coupling is, cell by cell on average, close to the human's coin law, and therefore, input by input on average, close to the human. Conversely, every bit of divergence a program shows must be paid for by worse prediction or by information about β. The lemma also recovers half of Lemma 4.4: $\bar D\ge0$ gives $2^{m-1}(H(\rho)-R(\pi))\le I_\beta(\pi)+O(\delta_\beta+|B|m)$.

[computed: f7(A): 20 latent-cause instances with $|B|=3$, $|Y|=4$, eight cells and six inputs, 40 programs each (sub-probabilities, zeros, the human): the Hölder step holds with largest gap $1.8\cdot10^{-15}$ (rounding); $\sum_b\tilde q_w\le\sum_bq_w\le1.000000$; the identity of step 4 holds exactly; and brute force over all $3^8$ couplings confirms that $Q$ has total mass $Z\le1$.] [computed: f7(B): the machine-free counting form, for β′ uniform on the type class and an explicit class $\mathcal C$ with Kraft sum $k_{\mathcal C}$: $\Pr_{\beta'}\big[\exists\pi\in\mathcal C:\bar D(\pi)\ge H+R_{\beta'}(\pi)-2(L_\beta-\ell(\pi)-j)/2^m\big]\le k_{\mathcal C}2^{-j}$. Exhaustively over 1820 couplings, feature and latent-cause channels: the event occurs on 0.0088 of the couplings for $j\le4$ (the 16 intervals, feature case) and never in the latent-cause class, against $0.951\cdot2^{-j}$.]

### 4.4 The robust near-imitation theorem

**Theorem 4.7 (robust near-imitation)** [proved, new in revision; (L)(i)–(v) are old Theorem 4.6 in the conditioned setting, (U)(ii)–(v) are referee A's A1, and (vi) is new; all are Paper 2's `lem:kink:main` with Lemma 4.5 as the right side, plus Lemma 4.6]. In Setting 4.1 let $c=a2^{-m}$ with $a>1$, and $\varepsilon\ge0$. Consider two cases.
* **(U), unconditional.** No hypothesis beyond Setting 4.1. Put $\Gamma:=\ell_0$.
* **(L), under a left condition.** For some $t\ge t_H$,
  $$(\mathrm L_{t,c,\varepsilon})\qquad\text{every }\pi\text{ with }K(h_0\mid\pi,\mu)>t\text{ has }J_c(\pi)>J_c(\pi_H)+\varepsilon .$$
  Put $\Gamma:=t+D_0$.

In both cases put $G:=\Gamma+\delta_\beta+|B|\log(2^m+1)+\kappa$ and $E_m:=2\log\big(2^{m-1}(2H(\rho)+c(\Gamma+\kappa)+\varepsilon)+1\big)\le2m+2\log(2H(\rho)+c(\Gamma+\kappa)+\varepsilon+1)$. Then every $\pi\in\Hcl{\times}$ with $J_c(\pi)\le\Phi(c)+\varepsilon$, in particular every minimiser of $J_c$, satisfies:
* (i) *(L) only: it knows the human's model:* $K(h_0\mid\pi,\mu)\le t$;
* (ii) *it is short:* $\ell(\pi)\le\ell_0+(G+2^m\varepsilon)/(a-1)$;
* (iii) *it predicts neither much better nor much worse than the human:*
  $$-\frac{aG+2^m\varepsilon}{(a-1)2^m}\ \le\ R(\pi)-H(\rho)\ \le\ c(\Gamma+\kappa)+\varepsilon;$$
* (iv) *it holds little information about the coupling:* $I_\beta(\pi)\le\Gamma+(G+2^m\varepsilon)/(a-1)+\kappa$;
* (v) *the human is near-optimal:* $J_c(\pi_H)\le\Phi(c)+G/2^m+c(\Gamma+\kappa)$;
* (vi) *it is a near-copy of the human:*
  $$\Ex_{x\sim\bar\mu}D_{1/2}\big(\nu_H(\cdot\mid x)\Vert\nu_\pi(\cdot\mid x)\big)\ \le\ c(\Gamma+\kappa)+\frac{2a}{a-1}\cdot\frac{G+E_m+\kappa}{2^m}+\frac{a+1}{a-1}\,\varepsilon,$$
  so ${\Hel}_{\bar\mu}(\pi)\le\frac{\ln2}2$ times the right side, and $\Ex_x\mathrm{TV}(\nu_H(\cdot\mid x),\nu_\pi(\cdot\mid x))\le\sqrt{2{\Hel}_{\bar\mu}(\pi)}$.
* (vii) *The lower end $2^{-m}$ is sharp* (feature case, ρ with pairwise distinct values). The *memoriser* $\pi_A$, which computes the deterministic $P^*$ from $\pi_H$ and the index of β in its type class, has
  $$\ell(\pi_A)\le\ell_0+\lceil L_\beta\rceil+a_\rho+\kappa,\qquad a_\rho:=2\log(m+1)+2\log(|B|+1)+|B|(m+1),$$
  and $R(\pi_A)=0$. So for every $c<H(\rho)/(\lceil L_\beta\rceil+a_\rho+\kappa)$, a threshold at least $2^{-m}\big(1+(a_\rho+1+\kappa)/(2^mH(\rho))\big)^{-1}$, $J_c(\pi_A)<J_c(\pi)$ for every copy π, and no copy minimises $J_c$.

*Proof.* Apply `lem:kink:main` in the population reading, $L=L'=R$, with the reference point $(\alpha_{\rm r},L_{\rm r}):=(\ell_0,H(\rho))$, bounded by $\pi_H$, and $\tau:=2^{-m}<c$.
* *(U)*: $\mathcal M:=$ the whole class, $\mathcal N:=\emptyset$ (so $\eta_{\mathcal N}=+\infty$), the right line of Lemma 4.5(d) with $g:=G^*/2^m=G/2^m$, and length floor $\ell_{\mathcal M}:=0$; then $\alpha_{\rm r}-\ell_{\mathcal M}=\Gamma$.
* *(L)*: $\mathcal M:=M_t$, $\mathcal N:=$ its complement, the right line of Lemma 4.5(e) with $g:=G_t/2^m=G/2^m$, and $\ell_{\mathcal M}:=\ell_{\rm fl}$; then $\alpha_{\rm r}-\ell_{\mathcal M}=\Gamma+\kappa$. $(\mathrm L_{t,c,\varepsilon})$ is the hypothesis of `lem:kink:main`(ii) on $\mathcal N$.

In both cases $\pi_H\in\mathcal M$, and every π with $J_c(\pi)\le\Phi(c)+\varepsilon$ has $J_c(\pi)\le J_c(\pi_H)+\varepsilon=J_{\rm r}(c)+\varepsilon$.
* `lem:kink:main`(ii) puts π in $\mathcal M$, which is (i) in case (L), and gives $\ell(\pi)\le\ell_0+(g+\varepsilon)/(c-\tau)$ and $R(\pi)\ge H(\rho)-(cg+\tau\varepsilon)/(c-\tau)$. With $c-\tau=(a-1)2^{-m}$ these are (ii) and the left side of (iii).
* `lem:kink:main`(iv) gives $R(\pi)\le H(\rho)+\varepsilon+c(\alpha_{\rm r}-\ell_{\mathcal M})$, the right side of (iii).
* (iv): Lemma 4.5(b). In case (U), $I_\beta(\pi)\le\ell(\pi)+\kappa$ and (ii). In case (L), $I_\beta(\pi)\le\ell(\pi)-K(h_0\mid\mu)+t+\kappa=(\ell(\pi)-\ell_0)+\Gamma+\kappa$ and (ii).
* (v): `lem:kink:main`(i) with $\eta_{\mathcal N}(c)\ge0$ and $\Delta(c)=g+(c-\tau)(\alpha_{\rm r}-\ell_{\mathcal M})\le G/2^m+c(\Gamma+\kappa)$, which is $\ge0$ because $\pi_H\in\mathcal M$.
* (vi): Lemma 4.6, with the right side of (iii) for $R(\pi)-H(\rho)$ and for $E_m(\pi)\le E_m$, and with (iv):
  $$\bar D(\pi)\le c(\Gamma+\kappa)+\varepsilon+\frac2{2^m}\Big[\Gamma+\frac{G+2^m\varepsilon}{a-1}+\delta_\beta+|B|\log(2^m+1)+E_m+2\kappa\Big].$$
  Since $\Gamma+\delta_\beta+|B|\log(2^m+1)+\kappa=G$ and $2+\frac2{a-1}=\frac{2a}{a-1}$, this is at most the stated bound. The Hellinger and total-variation forms are the inequalities of Setting 4.1.
* (vii): The memoriser reads a self-delimiting description of $(m,\rho)$ ($a_\rho$ bits: $m$, $|B|$, and the $|B|$ numerators $\rho(b)2^m\le2^m$), then the fixed-length index of β among the $2^{L_\beta}$ couplings of type ρ, then runs $\pi_H$. On input $x=(w,x')$ it computes $\nu_{\pi_H}(\cdot\mid x)$ exactly as in the bound on $t_H$, finds the label of mass $\rho(\beta(w))$, which is $h(x,\beta(w))$ since ρ's values are distinct, and gives it probability 1; where the search does not end it outputs nothing, which keeps a semimeasure. So it computes $P^*$ on $\supp\mu$ and $R(\pi_A)=0$. Then $J_c(\pi_A)<J_c(\pi_H)$ iff $c(\ell(\pi_A)-\ell_0)<H(\rho)$, and $J_c(\pi_H)\le J_c(\pi)$ for every copy π. The form of the threshold uses $L_\beta\le2^mH(\rho)$. ∎

**What the theorem says, in the author's terms.**
* Aliens that model the environment around the human do predict better, by up to $H(\rho)-H_W(Y\mid X)$ bits per sample.
* Yet in case (U), with no hypothesis on the human's model or on the aliens, for every $c$ between the reuse factor $2^{-m}$ and about $1/\ell_0$, every near-optimal hypothesis is a near-copy of the human: its answers are, on average over inputs, within Hellinger gap $O\big(c\ell_0+\frac{a}{a-1}(\ell_0+\delta_\beta+|B|m)/2^m\big)$ of the human's, it holds only $O(\ell_0+(\ell_0+\delta_\beta+|B|m)/(a-1))$ bits about the coupling, and it predicts no better than the human by more than $O(\frac a{a-1}(\ell_0+\delta_\beta+|B|m)/2^m)$ bits per sample.
* The guarantee is informative when the coupling is incompressible ($\delta_\beta\ll2^m$), the human is much simpler than the coupling ($\ell_0\ll2^m$, and $|B|m\ll2^m$), and $c$ lies in the window $(2^{-m},\,\approx1/\ell_0)$. Below the window the memoriser wins (vii). Above it the bound becomes vacuous, and in explicit classes simpler programs (the coin) win above $s_-(H)\le(\log|Y|-H(\rho))/(\ell_0-\ell(\pi_{\rm u}))$ (A-M1).
* Case (L) adds that the program knows the human's model, and shrinks the offsets from $\ell_0$ to $t+D_0$. That matters when $\ell_0$ is not small compared with $2^m$, or when one wants Paper 2's stronger statements about errors.
* The theorem concerns the near-optimal set, not a single program. As in Paper 2's `rem:teacher:selected`, the minimiser may be a nearby program (another coin law, a few memorised cells), which (vi) shows is behaviourally close to the human. In the explicit classes of f2–f4 and f7(C) the human itself is the unique minimiser on the window.

**Corollary 4.8 (two instances)** [proved].
* **(a) A coin-flipping human** [proved, new]. Let $h(x,b)=b$, so $Y=B$ and the human answers $y\sim\rho$ whatever its input.
  * A copy outputs ρ at every input, so $\ell_0\le K(\rho)+\kappa\le a_\rho+\kappa=O(|B|m)$. Case (U) of Theorem 4.7 therefore holds with $\Gamma=O(|B|m)$, and every near-optimal program at $c=a2^{-m}$, $a>1$, has $\Ex_xD_{1/2}(\nu_H\Vert\nu_\pi)\le c\,\ell_0+O\big(\frac a{a-1}(|B|m+\delta_\beta)/2^m\big)$.
  * This is the precise sense in which this toy case is solved: near-imitation for every $c=a2^{-m}$ with $a>1$ and $c\,\ell_0$ small.
  * It is not solved in the sense that *the human itself is picked* for every $c>2^{-m}$, which `notes.md` suggested; that reading is **[refuted]** (§9). [computed: r4(B), unchanged in f4: in an explicit class with 16 cells, $|S|=2$ and $p=1/8$, the population window is $(0.0544,0.1521)$ and above it the fair coin is selected, with probability 1.0000 from $n=256$ at $c=0.25$; referee: ra1(A).]
* **(b) A parity human** [proved: Paper 2's `thm:teacher:main` and Theorem 4.7]. Paper 2's instance read as imitation: $h_0$ is (the parity $f_a$ on $\{0,1\}^d$, $p$), and μ is determined by $(d,m)$.
  * *(U):* $\ell_0\le\ell(\pi_g)\le d+\kappa_g$, $\kappa_g=2\log d+K(p)+\kappa$. At Paper 2's sizes ($d=100$, $m=20$, $p=2^{-10}$, so $\ell_0\approx120$ bits with κ set to 0, an illustration): at $c=2^{-19}$ ($a=2$) every near-optimal program has Hellinger gap at most $3.1\cdot10^{-4}$ and mean total variation at most 0.025; at $c=10^{-4}$ ($a=105$), at most $4.3\cdot10^{-3}$ and 0.093 [computed: f7(D)].
  * *(L):* level-1 programs have $K(a\mid\pi)\le s(1)+2\log d+\kappa$ (`lem:teacher:list`), so $K(h_0\mid\pi,\mu)\le t:=4+2\log d+K(p)+\kappa$. Programs of level at least 2 have $J_c\ge\Phi_2(c)$ (`thm:teacher:main`(o)). So $(\mathrm L_{t,c,\varepsilon})$ holds on $\{c>2^{-m}:J_g(c)+\varepsilon<\Phi_2(c)\}$, which contains $(2^{-m},c_{\rm hi})$ at $\varepsilon=0$. Since $K(a)\ge d$ and $a$ is computable from $h_0$, $K(h_0\mid\mu)\ge d-2\log d-2\log m-\kappa$, so $D_0\le\kappa_g+2\log d+2\log m+\kappa$ and $\Gamma=t+D_0=O(\log d+\log m+K(p))$.
  * Paper 2's Theorem C (`thm:teacher:main`(ii)) gives more on this window: agreement $u(\pi)\ge\max\{\frac34,2^{-R_{\max}}-p\}$, and average probability $e(\pi)\le1-u(\pi)+\gamma_g+2^{-g}$ on the environment-driven labels. At Paper 2's sizes the window is $(9.54\cdot10^{-7},8.06\cdot10^{-3}]$ with κ set to 0, and at $c=10^{-4}$ every near-optimal hypothesis gives the environment-driven labels average probability at most 0.200 (`tab:teacher:numbers`), against 1 for the memoriser.
  * These numbers of Paper 2 use its deficiency $\delta_S=L_S-K(S\mid a,K(a))$. In this record's notation $\delta_\beta$ conditions on $(h_0,\mu,K(h_0\mid\mu))$; the two differ by $O(\log d+\log m+K(p))$ (A-m11).

**Corollary 4.9 (from samples)** [proved: Paper 2's `prop:recovery:beyond`(c) with Theorem 4.7]. Per-query data, $(x_i,y_i)$ i.i.d. from $\bar\mu\otimes P^*$, in $\Hcl{\times}$ or in a class of `def:setup:class` covered by `prop:related:computable` (with that class's own κ; Lemma 4.4 needs uniform lower semicomputability, and (F1) a c.e. prefix-free class; A-m7, B-B6). Fix $c=a2^{-m}$, $a>1$. Almost surely, for all large $n$, every $cn$-MAP minimises $J_c$, and so satisfies Theorem 4.7(ii)–(vi) with $\varepsilon=0$ in case (U), and also (i) in case (L) when $(\mathrm L_{t,c,0})$ holds.

*Proof.* `prop:recovery:beyond`(c), applied with $P^*$ as the sampler (its $R_\nu$ is $R$), puts every $cn$-MAP in $\arg\min J_c$ for all large $n$, almost surely. ∎

* The statement is for each fixed $c$; it is not uniform in $c$. Paper 2's `prop:teacher:schedules`(c) gives uniformity over compact subintervals of the window for the parity only.
* At the ends of an exact window ($c=s_\pm$) `prop:recovery:beyond`(c) does not apply. [referee: rb4(A): in an explicit class the human is among the MAPs with probability 0.496 at $c=s_+$ and 0.499 at $c=s_-$, at $n=512$.]
* For finite $n$, the parity instance has explicit bounds (`prop:teacher:schedules`(c), `cor:teacher:sampled`, via `lem:teacher:finite`); for a general $h$ the same route needs a truncated form of Lemmas 4.4 and 4.6, not written out [open, expected routine].

[computed: f3 (identical to r3), the explicit class of f2(A) with $(d_u,m,s_0)=(6,10,64)$ and population window $(9.50\cdot10^{-4},5.52\cdot10^{-2})$, 10 seeded runs, exact MAPs over the whole class:
* $c=7.2\cdot10^{-3}$ (inside the window): the human in 9/10 runs at $n=1000$ and in 10/10 at every $n$ from $3000$ to $10^7$;
* $c=4.9\cdot10^{-4}$ (below): aliens memorising a growing number of cells (35 to 43 cells at $n=1000$), and the full memoriser from $n=10^4$ on;
* $c=0.1$ (above): the coin at every $n$.]

[computed: f4(B), exact enumeration with the corrected code lengths; the coin-flipping human with 16 cells, $|S|=2$, $p=1/8$; population window $(0.0544,0.1521)$.
* At the geometric middle $c=0.0909$, $\Pr[\text{the }cn\text{-MAP is the human}]=0.559,0.902,0.9955,1.0000$ at $n=16,64,256,1024$.
* Just inside the ends ($c=1.05s_+$, $0.95s_-$) convergence is slow: $0.816$ and $0.790$ at $n=1024$, with the rest on the memoriser and the coin respectively.
* Below the window ($c=0.03$) the memoriser has probability $1.0000$ from $n=256$; above ($c=0.25$) the coin does.
* At fixed λ = 2 the memoriser has probability $0.964$ at $n=64$.]

[computed: f7(C), population minimisers for the coin-flipping human $\mathrm{Bern}(1/4)$ ($\ell_0=7$) in an explicit class with the coin, rate laws, all memorisers of $t\le s_0$ cells, $2^m$ cyclic-interval memorisers, and 256 random kernels; random couplings and two interval couplings, at $c=a2^{-m}$:
* $m=10$, 50 random couplings: the human is the minimiser in all of them for every $a\in\{0.9,1.5,2,4,8,16,32\}$ (the exact window ends at $a=38.65$), and the coin at $a=64$. The machine-free form of the bound (vi), with each coupling's own class deficiencies, is at most 0.081, 0.061, 0.059, 0.082, 0.135, 0.243 at $a=1.5,\dots,32$, and 0.46 at $a=64$, where the selected coin has $\Ex D_{1/2}=0.100$.
* $m=8$: the human in all 100 couplings for $a\in[0.9,8]$ (window end 9.66), the coin from $a=16$.
* $m=6$ ($\ell_0/2^m=0.11$, not small): the human in 65–85 % of couplings for $a\in[0.9,2]$, otherwise a random kernel with $\Ex D_{1/2}\le0.195$, inside the bound (0.85–1.11).
* Interval couplings (cheap, $\delta_\beta$ large): the interval memoriser is selected up to $a=8$, 16, 64 at $m=6,8,10$; there the bound is vacuous (at least 1.8), as Proposition 4.10(c) predicts.]

### 4.5 Necessary conditions and lower bounds

**Proposition 4.10 (what any procedure must give up, and when no window exists)** [proved; (a1) is the argument of Paper 2's `prop:limits:noident`(iii) in this setting; (b1)–(b3) generalise `prop:teacher:schedules`; (a2), (b4), (b5), (c), (d) new].
* **(a) One data law, one copy.**
  * *(a2) The general bound.* Let $W_1,\dots,W_N$ be worlds (any humans, couplings, response functions and channels) whose data laws coincide, and whose humans' kernels $\nu_1,\dots,\nu_N$ differ pairwise on sets of positive input mass. Then for every procedure Ψ (any measurable function of the data, randomised or not) and every $n$,
    $$\sum_{i=1}^N\Pr_{W_i}\big[\Psi_n\in\mathcal E(\nu_i)\big]\ \le\ 1 .$$
  * *(a1) The twin.* In particular, let $W'$ be the world whose human is a program with kernel $P^*$ and private coins. If $\nu_H\ne P^*$ on a set of positive mass, as in the feature case, then $\Pr_W[\Psi_n\in\mathcal E(\nu_H)]+\Pr_{W'}[\Psi_n\in\mathcal E(P^*)]\le1$. A procedure that copies the human of $W$ with probability at least $1-\epsilon$ copies the human of $W'$, a human who really responds to the environment variable, with probability at most ε.
  * *(a3) Only data-law twins obstruct a general procedure* [example; referee: rb4(C)]. For an alien $A$ whose kernel differs from $P^*$ on positive mass, the world $W_A$ whose human *is* $A$ has a different data law, and per-query data separate $W$ from $W_A$ (Theorem A applied to $P^*$ and to $\nu_A$). Referee B's procedure $\Psi_{\rm var}$ outputs the fresh-coin human when every queried input's labels are constant, and otherwise memorises the inputs whose labels were all 1. In a 16-cell class ($n=200{,}000$, 200 runs) it copies $W$'s human with probability 0.985 and, in $W_A$ with $A$ a partial memoriser of advantage per bit 0.0236, copies $A$ with probability 0.995: a sum of 1.98. So the statement in `notes.md` that "the set of aliens a procedure is robust against is the set of humans it cannot copy" is **[refuted]** for general procedures. It holds for the twin with kernel $P^*$ (a1), and the rate comparison of Proposition 4.3 is specific to penalised likelihood.
  * *What imitation data identify.* By (a2) and Theorem A, they identify $P^*$ and nothing more. The split of $P^*$ into "the human's kernel" and "the environment's coupling" is a convention that every procedure adopts, explicitly or not: it copies at most one of the humans that share a data law, in total probability. Penalised likelihood with $\lambda=cn$ adopts the convention by rate.
* **(b) Schedules.** Let $\pi_H$ be a shortest copy and $s_\pm=s_\pm(H)$.
  * *(b1)* Let π be an alien with $r(\pi)>0$. If $\lambda_n/n\le c'<r(\pi)$ for all $n$ in an infinite set $N'$, then almost surely π beats every copy of the human at all but finitely many $n\in N'$.
  * *(b2)* Let π be shorter than $\ell_0$, with finite risk. If $\lambda_n/n\ge c''>(R(\pi)-R_H)/(\ell_0-\ell(\pi))$ on an infinite set $N''$, then almost surely π beats every copy at all but finitely many $n\in N''$.
  * *(b3)* If $\lambda_n/n\to\infty$, the $\lambda_n$-MAPs eventually have length at most $\ell_{\min}:=\min\{\ell(\pi):R(\pi)<\infty\}$.
  * *(b4) The ends are excluded* [proved, new in revision]. Suppose $s_+>0$ and its maximiser $\pi_+$ (Proposition 4.3) has a log-likelihood ratio against $\pi_H$ of finite variance. If $\lambda_n/n\le s_+$ for infinitely many $n$, then almost surely, for infinitely many $n$, the shortest copies are not the unique $\lambda_n$-MAPs. The same holds at $s_-<\infty$, with its minimiser $\pi_-$ of finite risk and a log-likelihood ratio of finite variance, when $\lambda_n/n\ge s_-$ infinitely often. So if the shortest copies are almost surely the unique MAPs for all large $n$, then $s_+<\lambda_n/n<s_-$ for all large $n$. This replaces the unproved "eventually stays in $[s_+,s_-]$" of `notes.md` (A-m1, B-B5).
  * *(b5) A sufficient condition in finite classes* [proved, new in revision]. In a finite class in which every log-likelihood ratio against $\pi_H$ has finite variance, every non-copy of length $\ell_0$ has risk above $R_H$, and $s_+<s_-$: if $(\lambda_n/n-s_+)\sqrt{n/\log\log n}\to\infty$ and $(s_--\lambda_n/n)\sqrt{n/\log\log n}\to\infty$, then almost surely the $\lambda_n$-MAPs are exactly the shortest copies for all large $n$.
* **(c) Cheap couplings defeat every c** (feature case, ρ with pairwise distinct values). Let $k_\beta:=K(\beta\mid\pi_H)$; for a pseudo-random generator, $\beta=G(\sigma)$ with an $s$-bit seed σ, $k_\beta\le s+K(G)+a_\rho+\kappa$. The program $\pi_A$ for $P^*$ built from $\pi_H$ and a shortest description of β given $\pi_H$, as in Theorem 4.7(vii), has
  $$\ell(\pi_A)\le\ell_0+k_\beta+\kappa,\qquad R(\pi_A)=0,$$
  hence rate $r(\pi_A)\ge H(\rho)/(k_\beta+\kappa)$. The human's left steepness is at most that of the uniform predictor $\pi_{\rm u}$ (risk $\log|Y|$): $s_-(H)\le(\log|Y|-H(\rho))/(\ell_0-\ell(\pi_{\rm u}))$. So if
  $$\frac{H(\rho)}{k_\beta+\kappa}\ \ge\ \frac{\log|Y|-H(\rho)}{\ell_0-\ell(\pi_{\rm u})},$$
  no $c$ makes the copies the minimisers of $J_c$ (Proposition 4.3): roughly, once the seed is shorter than $H(\rho)\,\ell_0/(\log|Y|-H(\rho))$. In the latent-cause reading $\pi_A$ must also compute μ, and $k_\beta$ is replaced by $K(\beta,\mu\mid\pi_H)$ and $R(\pi_A)$ by $H_W(Y\mid X)$.
* **(d) A window needs many cells.** In the feature case with ρ of pairwise distinct values, by Theorem 4.7(vii) and the bound on $s_-(H)$ in (c), a window for exact copies exists only if
  $$\frac{H(\rho)}{L_\beta+a_\rho+1+\kappa}<\frac{\log|Y|-H(\rho)}{\ell_0-\ell(\pi_{\rm u})},\quad\text{which implies}\quad 2^m>\frac{\ell_0-\ell(\pi_{\rm u})}{\log|Y|-H(\rho)}-\frac{a_\rho+1+\kappa}{H(\rho)} .$$
  The coupling must have more cells than the human's description has bits, per bit of the human's explanatory power. Theorem 4.7(U) gives the matching sufficient condition for near-imitation, $\ell_0\ll2^m$, up to the factor $\log|Y|-H(\rho)$ and constants.

*Proof.*
* (a2) In every $W_i$ the data have one law, so $\Psi_n$ has one output law; the sets $\mathcal E(\nu_i)$ are pairwise disjoint because the kernels differ on sets of positive mass. (a1) is $N=2$: in $W$ the data are i.i.d. from $\bar\mu\otimes P^*$ by the definition of $P^*$, and in $W'$ by construction.
* (b1) For an alien, $\frac1n[J_{\lambda_n}(\pi_H)-J_{\lambda_n}(\pi)]\ge\hat R_n(\pi_H)-\hat R_n(\pi)-c'(\ell(\pi)-\ell_0)\to(\ell(\pi)-\ell_0)(r(\pi)-c')>0$ along $N'$, and every copy has the fits of $\pi_H$ and length at least $\ell_0$. (b2) is symmetric. (b3) is the argument of `prop:teacher:schedules`(b): a program longer than $\ell_{\min}$ has $J\ge\lambda_n(\ell_{\min}+1)$, more than $J(\pi_0)=\lambda_n\ell_{\min}+n\hat R_n(\pi_0)$ once $\lambda_n>n\hat R_n(\pi_0)$.
* (b4) Put $\Delta:=\ell(\pi_+)-\ell_0>0$, $V_i:=\log\big(\nu_{\pi_+}(y_i\mid x_i)/\nu_H(y_i\mid x_i)\big)$, i.i.d. with mean $R_H-R(\pi_+)=s_+\Delta$, and $W_n:=\sum_{i\le n}(V_i-s_+\Delta)$. Then $J_{\lambda_n}(\pi_+)-J_{\lambda_n}(\pi_H)=(\lambda_n-ns_+)\Delta-W_n$, which is $\le0$ whenever $\lambda_n/n\le s_+$ and $W_n\ge0$. If $V$ has variance 0, $W_n\equiv0$. Otherwise, by the central limit theorem $\Pr[W_n\ge0]\to\frac12$, so along the infinite set $N_-:=\{n:\lambda_n/n\le s_+\}$, $\Pr[W_n\ge0\text{ for infinitely many }n\in N_-]\ge\limsup_{n\in N_-}\Pr[W_n\ge0]=\frac12$. This event is unchanged by finite permutations of the i.i.d. pairs $(x_i,y_i)$, because $W_n$ is unchanged for every $n$ beyond the permuted indices; by the Hewitt–Savage 0–1 law it has probability 1. At $s_-$, $J_{\lambda_n}(\pi_-)-J_{\lambda_n}(\pi_H)=-(\lambda_n-ns_-)\Delta'+W'_n$ with $\Delta':=\ell_0-\ell(\pi_-)$ and $W'_n$ the centred sum of $\log(\nu_H/\nu_{\pi_-})$, and the same argument applies.
* (b5) For each non-copy π with $\ell(\pi)>\ell_0$, $J_{\lambda_n}(\pi)-J_{\lambda_n}(\pi_H)=n\Delta_\pi(\lambda_n/n-r(\pi))-W^\pi_n\ge n\Delta_\pi(\lambda_n/n-s_+)-W^\pi_n$. By the law of the iterated logarithm (Hartman–Wintner), $|W^\pi_n|=O(\sqrt{n\log\log n})$ almost surely, so the difference is eventually positive. Shorter programs are symmetric with $s_-$. Non-copies of length $\ell_0$ have a positive linear drift. Longer copies lose $\lambda_n(\ell-\ell_0)>0$. Programs of infinite risk have $L_n/n\to\infty$. The class is finite.
* (c) The program reads a shortest description of β given $\pi_H$, recovers $m$ and ρ from β (its domain and its type), and computes $P^*$ as in Theorem 4.7(vii); for a generator, $\beta=G(\sigma)$ is computed from $(G,\sigma,m,\rho)$. If its rate is at least $s_-(H)$, no $c$ satisfies $s_+(H)<c<s_-(H)$.
* (d) Combine the two bounds with $L_\beta\le2^mH(\rho)$. ∎

[computed: f2(B), identical to r2(B): the explicit class with $(d_u,m,s_0)=(6,10,64)$ and the coins given by an $s$-bit-seeded hash generator. The window is empty for $s\le12$ when $\ell_H=14$, for $s\le16$ when $\ell_H=24$, and for $s\le24$ when $\ell_H=40$; it exists for larger seeds. This matches the predicted thresholds $s>6+0.507(\ell_H-2)$, namely 12.1, 17.1 and 25.3. At $s=4$ the generator alien is shorter than the human and predicts better, so the human is never selected.] [referee: rb2(B): over all couplings of $\binom{32}4$ the fraction with an empty window is 0.123, 0.152, 0.152, then 1.000 once the human's model costs 10 bits, exactly where $(\ell_H-\ell_{\rm coin})/(1-H(1/8))$ passes $2^m=32$, as (d) predicts.] [referee: rb4(B): with $\lambda_n/n=s_++\epsilon_n$, the memoriser beats the human at an average of 0.000, 0.485, 0.499, 0.514 of the checkpoints in $[10^6,10^8]$ for $\epsilon_n=n^{-0.3},n^{-0.9},0,-n^{-0.9}$; consistent with (b4), and with (b5) for $n^{-0.3}$ but not $n^{-0.9}$.]

[computed: r6(D), machine constants set to 0 (an illustration): a human of $10^6$ bits with $H(\rho)=0.5$ and explanatory power $\log|Y|-H(\rho)=0.5$ needs an incompressible coupling with $2^m>2.0\cdot10^6$ cells, or a coupling description longer than $10^6$ bits; at $10^{12}$ bits, $2^m>2.0\cdot10^{12}$.]

**Proposition 4.11 (model–coupling confounding: incompressibility is not enough, for any procedure)** [proved: referee A's R1, re-derived here with corrected constants; computed: f8; referee: ra1(B)].
* **Setup.** Fix $m\ge2$ and $1\le s_0<2^{m-1}$, put $p=s_0/2^m$. The feature case with $X=W$, $\mu(\cdot\mid w)=\delta_w$, $Y=B=\{0,1\}$, $\rho=\mathrm{Bern}(p)$. For a table $f:W\to\{0,1\}$ the human $H_f$ answers $h_f(w,b)=f(w)\oplus b$, with kernel $\nu_f(y\mid w)=1-p$ if $y=f(w)$ and $p$ otherwise. Draw $f$ uniformly and β uniformly among the $s_0$-subsets of $W$, independently. The data are i.i.d. pairs $(w_i,T(w_i))$ with $T:=f\oplus\ind_\beta$, $w_i$ uniform.
* **(a)** The coupling is incompressible given the human's model: $\Pr[\delta_\beta>j]<2^{-j}$.
* **(b)** For every procedure Ψ and every $n$, $\Pr[\Psi_n\in\mathcal E(\nu_f)]\le\binom{2^m}{s_0}^{-1}=2^{-L_\beta}$, the probability being over $(f,\beta)$, the data and Ψ's randomness. Hence $\Pr[\Psi_n\in\mathcal E(\nu_f)\mid\delta_\beta\le j]\le2^{-L_\beta}/(1-2^{-j})$.
* **(c)** In $\Hcl{\times}$, with probability at least $1-2^{-j}$ over $f$: every copy of $H_f$ has length at least $2^m-j-2\log(m+1)-\kappa$, while the table program $D(T)$ has length at most $2^m+2\log(m+1)+\kappa$ and risk 0. So $J_c(\text{copy})-J_c(D(T))\ge H(p)-c(j+4\log(m+1)+2\kappa)$ and $J_c(\text{copy})-J_c(\text{fair coin})\ge c(2^m-j-2\log(m+1)-2\kappa)+H(p)-1$. Once
  $$H(p)\,(2^m-j-2\log(m+1)-2\kappa)>(1-H(p))\,(j+4\log(m+1)+2\kappa),$$
  every $c>0$ has $D(T)$ or the fair coin beating every copy, so no window exists; and a right line of slope $2^{-m}$ at the human's point needs an offset of at least about $H(p)\,\ell_0$ on the whole class, the order of Lemma 4.5(d).

*Proof.*
* (a) Conditional on $f$, hence on $h_0=(f,\rho)$ and on μ, β is uniform on its type class; count the descriptions shorter than $L_\beta-j$.
* (b) $(f,\beta)\mapsto(T,\beta)$ is a bijection, so $T$ is uniform and independent of β, and the data depend on $(f,\beta)$ only through $T$ and the independent $w_i$. Fix $T$, the $w_i$ and Ψ's randomness; $\Psi_n=\psi$ is then one program with one kernel. The kernels $\nu_{T\oplus\ind_{\beta'}}$ for distinct $\beta'$ differ at the cells of the symmetric difference, each of mass $2^{-m}$, because $p\ne\frac12$; so ψ copies the human for at most one β′, and given $T$ the event $\beta=\beta'$ has probability $2^{-L_\beta}$. Average. This is Proposition 4.10(a2) with $N=2^{L_\beta}$ worlds per data law.
* (c) From a copy π the table $f$ is computable given $m$: $f(w)$ is the label whose lower approximations of $\nu_\pi(\cdot\mid w)$ eventually exceed $\frac12$, as $p<\frac12$. So $K(f)\le\ell(\pi)+2\log(m+1)+\kappa$ (referee A wrote $\ell(\pi)+\kappa$; the domain size must be supplied, and this changes only constants). $\Pr[K(f)<2^m-j]<2^{-j}$. $D(T)$ reads $m$ self-delimitingly and then $2^m$ bits. The fair coin has length at most κ and risk 1. Compare $J_c$. ∎

**Reading.**
* The human's response depends on the same cells as the coupling, and the human is as complex as the coupling ($\ell_0\approx2^m$). Then the decomposition $T=f\oplus\ind_\beta$ into "human" and "environment" is not identified by anything, although every candidate world is a human with private-looking coins driven by an incompressible coupling, exactly the situation in which §4's positive results are meant to succeed.
* So a hypothesis like $\ell_0\ll2^m$ (Theorem 4.7(U)) or a left condition (Theorem 4.7(L)) is necessary, not a technicality.
* [computed: f8(A): exhaustively for $(m,s_0)=(3,1),(3,2),(3,3),(4,2)$, every data law is shared by exactly $\binom{2^m}{s_0}$ worlds with pairwise different humans, and the best average success is exactly $\binom{2^m}{s_0}^{-1}$ ($1/8$, $1/28$, $1/56$, $1/120$).]
* [computed: f8(B): with the same coupling law, $m=6$, $s_0=16$, in one explicit class, the *simple* human $f=0$ (the coin-flipping human, $\ell=7$) is the unique population minimiser at the sampled values $c\in\{1.6,2.5,3.0\}\cdot10^{-2}$ ($a=1.02,1.6,1.92$); the *complex* human (a random table, $\ell=70$) is never selected: $D(T)$ wins below $c\approx1.6\cdot10^{-2}$ and the coin above.]
* [heuristic; referee A] In $\Hcl{\times}$ the $cn$-MAP in this world would likely select a human-type program $H(f',p)$ with the *simplest* $f'$ within Hamming distance $s_0$ of $T$: a rate–distortion choice, not $f$. Not proved.

### 4.6 Remarks

**Remark 4.12 (the explicit class: the window is exact; its lower end is $2^{-m}(1\pm o(1))$)** [computed: f2(A)]. In an explicit prefix-coded class (coin; the human-type programs "parity $a$ on $d_u$ bits, flip rate $q$" for all $a$ and all $q\in\{j/64\}$; the S-cell aliens that declare a set $T$ of cells to carry coin 1, of length $\ell_H+\gamma(t)+\lceil\log\binom{2^m}t\rceil$, now computed in exact integers), the population window computed from the exact hull is:

| $(d_u,m,s_0)$ | $\ell_H$ | $s_+$ | $s_+\cdot2^m$ | $s_-$ | ratio |
|---|---|---|---|---|---|
| (6, 8, 16) | 14 | $3.63\cdot10^{-3}$ | 0.929 | 0.0552 | 15.2 |
| (6, 10, 64) | 14 | $9.50\cdot10^{-4}$ | 0.973 | 0.0552 | 58.1 |
| (6, 12, 256) | 14 | $2.42\cdot10^{-4}$ | 0.991 | 0.0552 | 228 |
| (6, 14, 1024) | 14 | $6.09\cdot10^{-5}$ | 0.997 | 0.0552 | 907 |
| (6, 16, 4096) | 14 | $1.52\cdot10^{-5}$ | 0.999 | 0.0552 | 3622 |
| (20, 10, 64) | 28 | $9.50\cdot10^{-4}$ | 0.973 | 0.0255 | 26.8 |

* The windows are unchanged by the code-length fix, because $s_+$ is attained by the full memoriser in every row.
* The explicit right line of slope $2^{-m}$ holds with a *negative* offset: $\max_{\rm aliens}[2^m(R_H-R)-(\ell-\ell_H)]$ is between $-15$ and $-6.10$ bits (f2; it was $-15$ to $-6$ with the one-bit-too-long lengths of r2). The machine-free part of Lemma 4.5's offset, $|B|\log(2^m+1)$, is 16–32 bits here; it is not tight in this class.
* In this class the lower end is slightly *below* $2^{-m}$, because the memoriser pays for a rate code and for $\gamma(t)$. In other codes it is slightly above: r6(C) gives the memoriser's rate $1.0105\cdot2^{-m}$ for $\rho=(\frac12,\frac14,\frac14)$, $m=6$, and referee B's rb2(B), with a deterministic memoriser that needs no rate code, gives $1.023\cdot2^{-m}$. The general form is $2^{-m}(1\pm o(1))$, the sign set by the code (B-B7).
* The assertion "the human's point is a hull vertex iff $s_+<s_-$" was checked against the hull in every row. The hull of the (6, 10, 64) row has exactly three vertices: the coin, the human and the full memoriser.
* The left condition holds in this class by construction: its only programs that do not contain the true parity are the coin and wrong-parity programs, which the coin dominates (A-M2). The class therefore tests Lemma 4.5(e) and Proposition 4.3, not the unconditional case; f7 and f8 test the latter.

**Remark 4.13 (partially private coins)** [proved (first part); computed: r2(C), f2(C); referee: rb3(C); conjecture].
* If the human's coin is $\beta(w)\oplus b'$ with a private residual $b'\sim\mathrm{Bern}(p')$, the human's flip rate is $p_h=s(1-p')+(1-s)p'$, $s=s_0/2^m$.
* Lemma 4.4 still holds: average over $b'$ inside $q_w$; injectivity in $b$ for each fixed $b'$ suffices, because $b\mapsto b\oplus b'$ is a bijection.
* But the line of Lemma 4.5 is then anchored at $2^mH(s)<2^mH(p_h)$. Its offset at the human's point is $2^m(H(p_h)-H(s))$ bits, so it says nothing useful.
* In explicit classes the lower end of the window falls below $2^{-m}$, to about the full-knowledge rate $2^{-m}(H(p_h)-H(p'))/H(s)$: $s_+2^m=0.764,0.660,0.795,0.537$ against $0.808,0.698,0.808,0.545$ in four instances (r2(C)), and $0.585,0.529,0.785,0.387$ against $0.698,0.597,0.808,0.394$ in four more (rb3(C)).
* *Conjecture:* in $\Hcl{\times}$ a right line of slope $2^{-m}(H(p_h)-H(p'))/H(s)$ holds, with an offset of order $|B|m+\delta_\beta+\Gamma$. It would need a noisy-channel version of Lemma 4.4.

**Remark 4.14 (several environments: what is shared is kept, what varies is discarded)** [sketch; numbers: referee rb3(B)]. Downgraded from "[proved]" (A-m5, B-B8).
* *Setting.* The human is observed in $E$ environments, equally often, with the environment's index part of the input. In world $W_E$ each environment $e$ has its own coupling $\beta_e$, and the tuple $(\beta_1,\dots,\beta_E)$ is incompressible given $h_0$. In world $W''$ the human itself carries one coupling β, the same in every environment, so its answers are $h(x,\beta(w))$ everywhere.
* *In $W_E$* the coupling variable is $(e,w)$, uniform on $E\,2^m$ cells, and Lemma 4.5 applies with $2^m$ replaced by $E2^m$: every alien's advantage per bit is at most about $2^{-m}/E$, up to the offset.
* *In $W''$* the coupling β lives on $2^m$ cells, and the program "$\pi_H$ plus β" beats the copies at every $c$ below about $2^{-m}$ (Theorem 4.7(vii)).
* *Sketched consequence.* For $c$ between about $2^{-m}/E$ and $2^{-m}$, the $c$-procedure attributes a dependence on $w$ that varies across environments to the environment, and one that is shared across environments to the human: an invariance principle. Two conditions are not proved: that the selected program in $W''$ has $W''$'s kernel or low risk (for general $h$ this needs a memoriser-regime theorem like `thm:teacher:main`(iii)), and the left condition (or $\ell_0\ll E2^m$) in $W_E$.
* [referee: rb3(B): $2^m=256$, $s_0=16$; the largest per-environment alien rate in $W_E$ is $0.899,0.457,0.229,0.115$ times $2^{-m}$ for $E=1,2,4,8$, and the shared memoriser's rate in $W''$ is $0.928\cdot2^{-m}$ for every $E$; the human's left steepness, 0.1105, is above both.]
* *What it does not remove.* The twin of $W_E$ in Proposition 4.10(a1), a human who carries all $E$ couplings and selects one by the environment's index, has the same data law as $W_E$. Data from several environments do not make the choice data-driven; they make one convention, "what is the same across environments is the human", available to a rate threshold.

---

## 5. (d) A human with latent state

**Setting 5.0.**
* At step $i$ the environment chooses $x_i$ from the observable history $(x_{<i},y_{<i})$ and independent randomness of its own (A-m12). The human, whose hidden state evolves with private randomness, answers $y_i$.
* $P_H(y_i\mid x_{\le i},y_{<i})$ is the human's *predictive law given the observable history*, the hidden state integrated out. Under the assumption on the environment it depends on the human alone. If the inputs could depend on anything correlated with the hidden state, $P_H$ would depend on the environment's policy, and so would the set $\mathcal E^{\rm ep}$ of Proposition 5.3.
* Hypotheses are chronological predictors: Paper 2's class $\Hcl{\mathrm{chr}}$, the hypotheses of Paper 1's history-aware SFI, or a subclass.
* *Episodes*: blocks of $T$ steps after which the human restarts from its initial law and the environment restarts independently.

**Proposition 5.1 (Ville survives)** [proved: Lemma 2.1]. With $\mathcal A_i:=\sigma(x_{\le i},y_{<i})$ and the environment's randomness, (Priv) holds with $P_H$ in place of $\nu_H(\cdot\mid x_i)$, by the definition of $P_H$. So for every countable chronological class with Kraft weights, at every $n$:
* every program's gain over the human is at most its length plus δ*, with $\Pr[\delta^*\ge j]\le M_02^{-j}$;
* for fixed λ > 1 the λ-MAPs have length at most $(\lambda k+\delta^*)/(\lambda-1)$, with $k$ the length of a program for $P_H$.

If hypotheses could also see environment variables correlated with the human's hidden state, (Priv) could fail, and §4 would apply instead.

[computed: r5(A): a two-mood hidden Markov human, a class of 3375 hidden Markov programs, a Bayes mixture, 15 memoryless samplers and a coin, Kraft sum $M_0=0.258$; over 400 single trajectories of length 1500, $\Pr_{\rm emp}[\delta^*\ge j]=0.138,0.050,0.018,0.015,0.005$ for $j=1,2,3,4,6$, against $M_02^{-j}=0.129,0.064,0.032,0.016,0.004$: at $j=1$ and $j=6$ slightly above, by 55 runs against 51.6 and 2 against 1.6, within sampling error.] [referee: rb5(C): 4000 runs of $n=300$, $M_0=0.255$: 0.105, 0.054, 0.025, 0.0145, 0.0032 for $j=1,2,3,4,6$, below $M_02^{-j}$ at every $j$.]

**Proposition 5.2 (an in-context learner absorbs the human)** [proved; in $\Hcl{\mathrm{chr}}$ it is Paper 2's `thm:split:shared`(i) with $U=\MH$; the finite-family form is new]. Let the class contain $\pi_H$ (length $\ell_H$, law $P_H$) and $\pi_U$ (length $\ell_U$) with $P_U\ge w\,P_H$ on every finite history, for example a Bayes mixture over a family of humans that gives the human weight $w$. Then for every λ > 0, every $n$ and every data set,
$$J_\lambda(\pi_U)-J_\lambda(\pi_H)\ \le\ \lambda(\ell_U-\ell_H)+\log(1/w).$$
So if $\lambda(\ell_H-\ell_U)>\log(1/w)$, the human's program is never a λ-MAP, whatever $n$ and whatever the data, including i.i.d. data from a human with private coins.
* *Family coding.* If the human's program is "family code, then index", with $\ell_H=\ell_{\rm fam}+\ell_{\rm idx}$, $w=2^{-\ell_{\rm idx}}$ and $\ell_U=\ell_{\rm fam}+\kappa_U$, the condition is $(\lambda-1)\ell_{\rm idx}>\lambda\kappa_U$.
* *The universal class.* In $\Hcl{\mathrm{chr}}$ with $\pi_U$ a program for $\MH$, $w=2^{-\ell_H-\kappa}$, the condition is $(\lambda-1)\ell_H>\lambda\ell_U+\kappa$.
* *At λ = 1* the human's program is never ahead of the learner by more than $\kappa_U$ bits, at any $n$.

*Proof.* $P_U\ge wP_H$ gives $L(\pi_U)\le L(\pi_H)+\log(1/w)$; add $\lambda\ell$ to both. ∎

This is the formal form of "some completely alien system that just thinks about what the human would say". Once hypotheses carry information across queries, such a system is a single hypothesis; it pays its learning cost once and then predicts like the human, so it is shorter at almost no cost in fit. It is still $P_H$-equivalent on the run (Theorem 2.2(4); referee ra1(D)): what fails is that the selected program is a copy.

[computed: r5(B): human $\theta^*=(3/16,13/16)$, stay probability $15/16$; family of 3375 HMMs with 12-bit indices ($\ell_H=20$), learner of length 10, λ = 2. Over three trajectories of length 4000, $\max_n[J(U)-J(\theta^*)]=-9.00,-9.01,-9.00$, below the proved bound $-8$; it does not reach $-8$ because the mirror image of $\theta^*$ has the same law and doubles its weight in the mixture. The MAP is the learner at $n=1000$ and $n=4000$ in all three runs.] [referee: rb5(A), with i.i.d. private coins: the bound is attained ($-8.00$), and the learner is the MAP in 20 of 20 runs (Remark 2.4).]

**Proposition 5.3 (episodes restore Theorem A, in a class of restarting hypotheses)** [proved, new; the proof is Theorem A's].
* *Setting.* The data are i.i.d. episodes. Each episode is a $T$-step interaction between an environment with a fixed law (inputs may depend on earlier steps of the episode, as in Setting 5.0) and the human, restarted from its initial law with fresh private randomness.
* *Class.* Countable, with Kraft weights, of *episodic* predictors: each restarts at episode boundaries, $P_\pi(\text{data})=\prod_eP^{\rm ep}_\pi(y^e\Vert x^e)$ with $P^{\rm ep}_\pi(y^e\Vert x^e):=\prod_{t\le T}q_\pi(y^e_t\mid x^e_{\le t},y^e_{<t})$, sub-probability conditionals.
* *Copies.* $\mathcal E^{\rm ep}$ is the set of programs whose conditionals equal $P_H$'s at almost every history, under the joint law of the human and the environment, at every $t\le T$. $\ell_0$ and $\mathcal E_0^{\rm ep}$ are as in `def:split:setting`.
* *Conclusion.* `thm:recovery:main`(a)–(d) hold with $n$ the number of episodes, the per-episode Hellinger gap, and the per-episode Chernoff coefficient. In particular, an episodic learner (a mixture over humans restarted at each episode) has expected per-episode regret $\KL^{\rm ep}(\pi_U)>0$ unless it is a copy, and it is a $\lambda_n$-MAP for only finitely many $n$, for every $1\le\lambda_n=o(n)$.
* *The exclusion is a choice of class* (A-m3, B-B3). A class whose hypotheses keep memory across episodes contains a cross-episode mixture, which pays $\log(1/w)$ once in total; Proposition 5.2 then applies again. Restarting hypotheses, like product hypotheses, are a structural assumption about what counts as a copy; the data do not force it.

*Proof.* The per-episode ratios $Z_e(\pi):=P^{\rm ep}_\pi/P^{\rm ep}_H$ are i.i.d. across episodes. Within an episode the step ratios have conditional mean at most 1 given the past and the current input, so $\Ex Z_e\le1$ by the tower property. These are the facts `lem:recovery:ratios`(a),(d) use.
* For (c): $\KL^{\rm ep}(\pi):=-\Ex\log Z_e\in[0,\infty]$, and $\Ex(\log Z_e)^+\le\log e/e$.
* $\KL^{\rm ep}(\pi)=0$ iff $\pi\in\mathcal E^{\rm ep}$. If the KL is 0, Jensen's inequality forces $Z_e=1$ almost surely. The step products $M_t$ form a nonnegative supermartingale with $M_0=1$ and $M_T=1$ almost surely, so $\Ex M_t=1$ and, since $M_t\ge\Ex[M_T\mid\mathcal F_t]=1$, $M_t=1$ almost surely for every $t$. Each step ratio is then 1 almost surely, so $q_\pi(y\mid h)=P_H(y\mid h)$ wherever $P_H(y\mid h)>0$, and $\sum_yq_\pi\le1$ forces equality.
* The proof of `thm:recovery:main` (`app:recovery:main`) uses only these facts, the strong law across episodes, and $\Lambda_n=1$ on $\mathcal E^{\rm ep}$. ∎

[computed: r5(C): episodes of $T=20$ steps, λ = 2, 12 runs of 3000 episodes.
* The restarted learner's mean per-episode regret is $1.014$ bits (s.e. $0.008$), so the human should overtake it after about $2\cdot(20-10)/1.014\approx20$ episodes. It did after 13–35 episodes, and the learner was never ahead after episode 34.
* After 3000 episodes the λ-MAPs are exactly $\theta^*$ and its mirror image, tied to the last bit in all 12 runs: two shortest copies with different latent labellings, an instance of Proposition 3.1.]

**Remark 5.4 (what breaks without episodes)** [remark; open part marked; evidence].
* (1) *Product hypotheses* cannot represent the human ($\mathcal E=\emptyset$), and the answers are not i.i.d. given the inputs, so the misspecification results of `split/iid` §7.4, which assume i.i.d. pairs, do not apply as stated.
* (2) *Chronological hypotheses with a dominating member* absorb the human (Proposition 5.2), and so does SFI with history; with $\lambda=cn$ the absorption bound $\ell^*_\lambda$ tends to $\ell_U$.
* (3) *A single trajectory in a class without a dominating member*, such as hidden Markov programs with a bounded number of states: whether the $\lambda_n$-MAP converges to programs with the human's output-process law is **[open]**. For ergodic humans and finite classes we expect the answer yes, by analogy with the consistency of maximum likelihood for hidden Markov models (that literature was not checked). [evidence; referee: rb5(B): 343 HMMs, 15 memoryless samplers and a coin, λ = 2; in 10 of 10 runs the MAP is $\theta^*$ or its mirror image at every checkpoint from $n=1000$ to $20{,}000$.]

---

## 6. Interpretation: what the results show about imitation, and what they do not

### 6.1 What is shown, in toy settings

1. **The two cheap failure modes are handled, in toy form, by Paper 2's machinery.**
   * *Stored coins* ("the sampler with some bits specified") are excluded per query: for fixed λ > 1 their posterior mass is exponentially small in the sampled randomness at every $n$, and for every $1\le\lambda_n=o(n)$ the MAP is eventually an exact behavioural copy (Theorem 2.2, Remark 3.4).
   * *A learner that "just thinks about what the human would say"* is excluded only by the choice of hypothesis class: product hypotheses, which carry nothing across queries, or episodic hypotheses, which restart (Remark 2.4, Proposition 5.3). With a class that lets hypotheses keep memory, the learner absorbs the human for every λ > 1 and every data set, even with i.i.d. private coins (Proposition 5.2; rb5(A)). The sentence of `notes.md` that attributed the exclusion to private randomness is **[refuted]** (§9).
2. **With private coins, robustness against every program holds for fixed λ > 1** (§2). *Gain:* in every class, no program, however it is built and whatever it knows about the environment, beats the human by more than its own length plus δ* (Lemma 2.1). *Selection:* in the product class the selected program is eventually an exact behavioural copy (Theorem 2.2(3)). Here aliens never predict better in population, so this is the degenerate case of the author's scenario: robustness against luck.
3. **With environment-driven coins, the ideal theorem holds in toy form as near-imitation** (Theorem 4.7, Corollary 4.9). Aliens do predict better, by up to $H(\rho)$ bits per sample. Yet for every $c$ between the reuse factor $2^{-m}$ and about $1/\ell_0$, every near-optimal hypothesis, whatever its internal structure, is a near-copy of the human: Hellinger gap $O(c\ell_0+(\ell_0+\delta_\beta+|B|m)/2^m)$ for $a=c2^m$ bounded away from 1. This needs the coupling to be incompressible and much larger than the human's description, $\ell_0\ll2^m$. The robustness comes from information bounds (Lemmas 4.5, 4.6), not from listing aliens: each bit an alien knows about an incompressible coupling buys at most $2^{-m}$ bits of prediction per sample, and every bit of behavioural divergence from the human costs prediction or information. Toy cases solved:
   * a coin-flipping human, as near-imitation, unconditionally (Corollary 4.8(a));
   * a noisy-parity human, as near-imitation unconditionally at Paper 2's sizes, and with Paper 2's sharper conclusions on its window (Corollary 4.8(b), Paper 2's Theorem C);
   * explicit finite classes, where the human itself is the unique selection on $(s_+,s_-)$ (f2–f4, f7(C)).
4. **The geometry is the teacher thread's.** Paper 2's teacher instance *is* an imitation instance: systematic errors are environment-driven coins. What differs is the reading, namely which structure we call "the environment" and which "the human". The lower end $2^{-m}$ of the window is the reuse factor in both, and the upper end, about $1/\ell_0$, plays the role of $c_{\rm hi}$.

### 6.2 What is not shown; the problems that remain

1. **Mechanism.** Identification is behavioural (Proposition 3.1). The selected program is a shortest program for the human's law *in the class*. It may compute that law in a way nothing like the human's (Example 3.2), and off the support of the inputs it behaves as the shortest program does, not as the human does. Richer observations move the problem to the enlarged observation rather than remove it (Proposition 3.3(c)); a class restricted to human-like architectures assumes what we would want to learn.
2. **The split into "human" and "environment" is not identified by the data** (Proposition 4.10(a)). Imitation data identify the data kernel $P^*$. Worlds with the same $P^*$ and different humans cannot all be copied by any procedure. A $c$-procedure resolves this by a convention: it declares structure with advantage per bit below $c$ to be "environment" and structure above $c$ to be "human". It therefore also discards rare, costly-to-describe idiosyncrasies of the human (as in `prop:limits:separable`), and it keeps every environment influence that is cheap enough. The choice of $c$ is a judgment that imitation data cannot make. For general procedures the advantage per bit is not even the relevant quantity (Proposition 4.10(a3)).
3. **Cheap or pseudo-random couplings defeat it** (Proposition 4.10(c)). If the human's apparent randomness has a short description (a pseudo-random generator with a short seed, a simple environmental feature), aliens have a high rate and no $c$ returns the fresh-coin human. When the "coupling" is the human's own deterministic brain with a short initial condition, the program that models it is arguably the *more* faithful copy: the "failure" is a failure to return the stipulated target $\nu_H$, the human with fresh coins, and that target is a modelling choice that the data cannot make (referee A §5.6(ii)). Whether real human "noise" is incompressible and spread over many more cells than a human has bits is an empirical question these results do not touch.
4. **Entanglement of the human with its coupling** (Proposition 4.11). If the human is as complex as the coupling and its response depends on the same environmental cells, no procedure copies it with probability above $2^{-L_\beta}$, although every candidate world is "a human with private-looking coins driven by an incompressible coupling". The positive results need the human to be much simpler than the coupling, or its model to be decodable from good predictions (the left condition).
5. **The left condition** (the near-optimal program knows the human's model) is proved for parities and open for other families of human models (Paper 2's `q:teacher:open`(a)). Theorem 4.7(U) makes it unnecessary for *behavioural* closeness when $\ell_0\ll2^m$, but not for knowing the model, and not for Paper 2's statement that the environment-driven answers are not predicted.
6. **Residual private noise and non-uniform environments** are understood only in explicit classes (Remark 4.13, open question 2).
7. **Memory and the choice of class.** Real humans have state. The positive results need hypotheses that cannot carry information across queries or episodes, which is a choice of class, not a fact about the data (§6.1 item 1). On one long history, a class rich enough to contain a learner lets that learner absorb the human (Proposition 5.2).
8. **The data object.** Exact behavioural copies need per-query answers: the same question asked again, answered afresh. With frozen answers, partial fill-ins persist (Remark 3.4), and no procedure identifies the human's randomness at a repeated input (`prop:recovery:frozen`).
9. **Uncomputability, constants, the class and the reference machine.** $\Hcl{\times}$, the λ-MAP and the power posterior are not computable. The windows and all offsets depend on the machine constant: Paper 2's example window is $(9.54\cdot10^{-7},8.06\cdot10^{-3}]$ at κ = 0 and $(9.54\cdot10^{-7},3.65\cdot10^{-3}]$ at κ = 30. Computable classes keep the statements with their own constants (`prop:related:computable`). The choice of hypothesis class and of reference machine decides which programs are short, and so which program counts as "the" copy and what $\ell_0$ is.
10. **What "the human" is.** The (near-)copy of §4 has fresh coins. It reproduces the human's behaviour averaged over the environment's influence, not the human's correlation with the environment. Whether that is "the human" is a philosophical question, and Proposition 4.10(a) shows that imitation data alone cannot settle it.

---

## 7. What is new, and what is reused from Paper 2

| result here | relation to Paper 2, the split records, and the referees |
|---|---|
| Lemma 2.1 (Ville with side information) | `lem:split:ville`'s argument with a larger filtration; known in substance (Ville's inequality for predictable forecasters); the side-information reading is the contribution |
| Theorem 2.2 | (1) = `thm:split:private`(i)–(iii), (3) = `thm:recovery:main`, (4) = `thm:split:private`(iv), each with Lemma 2.1; (2) and the imitation reading are new and elementary |
| Proposition 2.3 (privacy dichotomy) | new; elementary (Lemma 2.1 and the strong law) |
| Remark 2.4 | new reading of `cor:absorb:nouniversal` and `prop:absorb:history`; referee B's rb5(A) |
| Propositions 3.1, 3.3; Example 3.2 | new; elementary; 3.1(b) is the twin-world argument of `prop:limits:noident`(iii) |
| Remark 3.4 | `prop:recovery:frozen`(c) and `thm:recovery:main`(a); the per-query bound and the simulation are new; exactness from the referees |
| Setting 4.1 | new; contains `def:teacher:instance` as the feature case with a parity; conditioning on μ is referee B's repair |
| Proposition 4.2 | (a) new, elementary; (b) = `thm:recovery:main` with $P^*$; cf. `prop:teacher:schedules`(a) |
| Proposition 4.3 | `lem:setup:hull`(iii) in the population reading |
| Lemma 4.4 | generalises `lem:teacher:coding` to any response function, coin set and channel, with a simpler proof |
| Lemma 4.5 | (a)–(c), (e) generalise (D2) of `lem:teacher:twopart`; (d) is referee A's A1 |
| **Lemma 4.6 (closeness)** | **new in this revision** |
| **Theorem 4.7** | `lem:kink:main` with Lemma 4.5 as the right side; (L)(i)–(v) = old Theorem 4.6, (U)(ii)–(v) = referee A's A1, **(vi) new in this revision**; (vii) generalises `thm:teacher:main`(iv) |
| Corollary 4.8 | (a) new; (b) = `thm:teacher:main` read as imitation, plus Theorem 4.7(U) at Paper 2's sizes |
| Corollary 4.9 | `prop:recovery:beyond`(c) + Theorem 4.7 |
| Proposition 4.10 | (a1) = the argument of `prop:limits:noident`(iii); (a2) new, elementary; (a3) referee B's rb4(C); (b1)–(b3) generalise `prop:teacher:schedules`(a),(b); (b4), (b5) new in this revision; (c) a new form of rate blindness (`prop:limits:rateblind`) for couplings with short descriptions; (d) new |
| Proposition 4.11 | referee A's R1, re-derived with corrected constants |
| Remarks 4.12–4.14 | new computations; 4.14 a sketch |
| Proposition 5.1 | Lemma 2.1 |
| Proposition 5.2 | `thm:split:shared`(i) with $U=\MH$; the finite-family form is new and elementary |
| Proposition 5.3 | new; its proof is `thm:recovery:main`'s with episodes as queries |

Nothing in this record changes a statement of Paper 2.

---

## 8. Open questions

1. **Residual private noise.** In $\Hcl{\times}$, does a right line of slope $2^{-m}(H(p_h)-H(p'))/H(s)$, with an offset of order $|B|m+\delta_\beta+\Gamma$, hold when the human's coin is $\beta(w)\oplus b'$ with private $b'$ (Remark 4.13)? This needs a noisy-channel form of Lemma 4.4. Does Lemma 4.6 have a noisy-channel form?
2. **Non-uniform environments.** What replaces the slope $2^{-m}$ when the cells have unequal masses? The proof of Lemma 4.4 gives unweighted per-cell risks, so the slope is governed by the cell masses. [evidence; referee: rb3(A): with masses proportional to $k^{-a}$, the lower end $s_+$ is set by memorising one or two of the heaviest coin-1 cells, and $s_+$ is 0.31–0.50 times the largest coin-1 cell mass in all 15 non-uniform draws; it reaches $5.0$, $14.4$ and $2.9$ times $2^{-m}$ at $a=0.5,1,1.5$. This supports "the largest coin-1 cell mass, up to logarithmic factors".]
3. **Other human models.** For which families of response functions does the left condition of Theorem 4.7(L) hold, that is, is the human's model decodable from near-optimal predictions? This is Paper 2's `q:teacher:open`(a) in imitation form. By Theorem 4.7(U) it matters only for knowing the model and for sharper offsets.
4. **Finite samples for general $h$.** Truncated forms of Lemmas 4.4 and 4.6, as in `lem:teacher:coding` with finite truncation, together with `lem:teacher:finite`, should give Corollary 4.9 at each $n$ with probability $1-\delta$. Expected routine; not written out.
5. **A single trajectory without a dominating member** (Remark 5.4(3); referee rb5(B) gives evidence for convergence).
6. **Computational depth.** Lemmas 4.4–4.6 use unbounded Kolmogorov complexity, so a generator with a short seed is a cheap coupling (Proposition 4.10(c)). In a time-bounded class an alien must also *run* the generator. Does a coupling that is short to describe but slow to compute act as private randomness for a time-bounded class, giving a computational form of robustness?
7. **Choosing the convention from data other than imitation data.** Data from several environments make the invariance convention of Remark 4.14 available. Do interventions that move the human between environments, or other non-imitation data, ever *identify* which structure belongs to the human?
8. **Selection in confounded worlds.** In the world of Proposition 4.11, which human-type program does the $cn$-MAP select in $\Hcl{\times}$? Referee A's heuristic is the simplest table within Hamming distance $s_0$ of the data table.

---

## 9. Claims and statuses

| # | claim | status |
|---|---|---|
| 2.1 | Ville deficiency with side information: under (Priv), every predictor's gain over the human is at most its length + δ*, $\Pr[\delta^*\ge j]\le M_02^{-j}$ | proved (known in substance); computed r1(A), r5(A); referee rb1(P), rb5(C) |
| 2.2(1) | fixed λ > 1, every $n$, any input rule: length bound, fit bounds, posterior tail, fill-in mass | proved (Paper 2 + Lemma 2.1) |
| 2.2(2) | under (Priv) no product hypothesis on $(x,z)$ predicts better than the human in population | proved |
| 2.2(3) | per query, product class on $(x,z)$, $z$ countable: Theorem A for the human | proved (Paper 2) |
| 2.2(4) | any predictors, every λ ≥ 1: eventually $\nu_H$-equivalent on the run | proved (Paper 2's argument) |
| 2.3 | privacy dichotomy: bounded gains iff $I(Y;Z\mid X)=0$; if $I>0$ (and the class contains the exploiting program) every copy is eventually rejected | proved; computed r1(B); referee rb1(L),(X) |
| (a)-brief | "with fixed λ > 1 the selected programs are eventually equivalent in law to the sampler, robustly against all programs" | **weak sense proved** in every predictor class under (Priv): every λ-MAP is eventually $\nu_H$-equivalent on the run (2.2(4); referee ra1(D)). **Strong sense** (eventually a copy) **proved** in the product class (2.2(3)) and **refuted** in classes that contain a dominating in-context learner (5.2; r5(B), referee rb5(A)) |
| 2.4 | robustness has two halves; learners violate the second; what excludes them is the class | remark (from proved results); computed r1(C); referee rb5(A) |
| 3.1 | only the kernel on the input support and the set $\mathcal E_0$ are identified; no procedure separates equivalent programs | proved |
| 3.2 | an equivalent, shorter alien is selected at every $n$ and λ; off-support behaviour is the alien's | example (r4(A)) |
| 3.3 | richer observations or inputs separate equivalent programs, but the selected program is then shortest for the enlarged kernel; a restricted class works by assumption; more data, schedules and length priors do not help | proved |
| 3.4 | partial fill-ins: excluded per query (union bound, essentially exact), persist with frozen answers ($0.1457$) | proved (Paper 2 + new bound); computed r4(C), f4(C); referee ra1(E), rb6(A) |
| 4.2 | fixed λ and every $\lambda_n=o(n)$ eventually reject every copy; with $P^*\ne\nu_H$ on positive mass, they select aliens | proved; computed r3/f3 |
| 4.3 | the shortest copies are the $J_c$-minimisers iff $s_+(H)<c<s_-(H)$ (and no tie at their point) | proved (hull lemma); computed f2(A) |
| 4.4 | alien coding lemma $K(\beta\mid h_0,\pi,\mu)\le2^mR(\pi)+\kappa$ | proved; computed r6(A); referee rb2(A) |
| 4.5 | right lines of slope $2^{-m}$: on the whole class with offset $G^*\sim\ell_0$, on $M_t$ with offset $G_t\sim t+D_0$; information bound; length floor | proved; computed f2(A), f7(B), r6(B); referee rb2(B) |
| 4.5-old | `notes.md`'s Lemma 4.5 with $\pi_H$ padded with μ | superseded: correct as stated, but the reference point must be a shortest copy (A-M3, B-B1) |
| **4.6** | **closeness lemma: $\Ex_xD_{1/2}(\nu_H\Vert\nu_\pi)\le(R-H)+2(I_\beta+\delta_\beta+|B|\log(2^m+1)+E_m+\kappa)/2^m$** | **proved, new in revision; computed f7(A),(B)** |
| **4.7(U)** | **unconditional robust near-imitation: for $c=a2^{-m}$, $a>1$, every near-optimal program is short, predicts within $O(\ell_0/2^m)$ of the human, holds $O(\ell_0)$ bits about β, and has $\Ex D_{1/2}\le c\ell_0+\frac{2a}{a-1}(G+E_m+\kappa)/2^m$** | **proved, new in revision** (ii)–(v) referee A's A1; computed f7(C),(D) |
| 4.7(L) | under the left condition: the same with $\Gamma=t+D_0$, and the program knows the human's model | proved (old Theorem 4.6, conditioned on μ) |
| 4.7(vii) | the lower end $2^{-m}$ is sharp up to $1+O((|B|m+\kappa)/(2^mH(\rho)))$ | proved; computed f2(A), r6(C) |
| 4.6-strong | "the human's own program is the unique minimiser on the whole window" | **refuted** in general (Paper 2's `rem:teacher:selected`: nearby rates take over on part of the window in explicit rate codes); true in the explicit classes of f2–f4 and f7(C); in $\Hcl{\times}$ only near-copies are claimed (4.7(vi)) |
| 4.7(a)-old reading | "a coin-flipping human, unconditionally" as a solved case of *picking the human* for every $c>2^{-m}$ | **refuted** (r4(B)/f4(B), referee ra1(A): above $s_-$ the fair coin is selected); replaced by near-imitation for $c=a2^{-m}$ with $c\ell_0$ small (4.8(a)) |
| 4.8(a) | coin-flipping human: Theorem 4.7(U) with $\Gamma=O(|B|m)$ | proved |
| 4.8(b) | parity human: Paper 2's Theorem C is a robust imitation theorem on its window; Theorem 4.7(U) at Paper 2's sizes | proved (Paper 2 + Theorem 4.7); computed f7(D) |
| 4.9 | from samples: eventually every $cn$-MAP satisfies Theorem 4.7 with ε = 0 (in $\Hcl{\times}$ and `def:setup:class` classes) | proved; computed f3, f4(B), f7(C) |
| 4.9-finite | the same at each $n$ with probability $1-\delta$ for general $h$ | open (expected routine); proved for the parity instance in Paper 2 |
| 4.10(a1),(a2) | one data law, one copy: $\sum_i\Pr_{W_i}[\text{copy of }W_i\text{'s human}]\le1$ for every procedure; the twin with kernel $P^*$ | proved; computed f8(A) |
| 4.10(a)-slogan | "the set of aliens a procedure is robust against is the set of humans it cannot copy" | **refuted** for general procedures (referee rb4(C): 0.985 + 0.995); holds for the twin with kernel $P^*$ and, by rate, for cn-procedures |
| brief (c), lower bound | "no procedure can robustly pick the human against aliens with large advantage per bit" | **refuted** for general procedures (Proposition 4.10(a3)); **proved** for penalised-likelihood procedures (4.3, 4.10(b)); the obstruction for every procedure is a shared data law (4.10(a2), 4.11) |
| 4.10(b1)–(b3) | schedules: aliens of rate above $\limsup\lambda_n/n$, or shorter programs steeper than $\liminf$, beat the human infinitely often | proved |
| 4.10(b)-old | `notes.md`'s 4.9(b) with rates relative to a padded $\pi_H$ | **refuted** as written (referee ra1(C)); corrected by taking the shortest copy |
| 4.10(b4) | the shortest copies are eventually the unique MAPs only if $s_+<\lambda_n/n<s_-$ eventually | proved, new in revision (Hewitt–Savage); referee rb4(B) consistent |
| 4.10(b5) | in finite classes, $(\lambda_n/n-s_\pm)\sqrt{n/\log\log n}\to\pm\infty$ suffices | proved, new in revision (LIL); referee rb4(B) consistent |
| 4.10(c) | couplings with short descriptions (PRG seeds) defeat every $c$ once the seed is short relative to $H(\rho)\ell_0/(\log|Y|-H(\rho))$ | proved; computed f2(B), f7(C) (interval couplings); referee rb2(C) |
| 4.10(d) | a window for exact copies needs $2^m\gtrsim(\ell_0-\ell_{\rm u})/(\log|Y|-H(\rho))$ cells | proved; computed r6(D); referee rb2(B) |
| 4.11 | model–coupling confounding: no procedure copies an entangled complex human with probability above $2^{-L_\beta}$; no window | proved (referee A's R1, constants corrected); computed f8; referee ra1(B) |
| 4.12 | explicit class: exact windows; lower end $2^{-m}(1\pm o(1))$, sign set by the code; the full memoriser attains $s_+$ | computed f2(A), r6(C); referee rb2(B) |
| 4.13 | residual private noise: Lemma 4.5's line is then useless; the explicit lower end is near $2^{-m}(H(p_h)-H(p'))/H(s)$ | proved (first part); computed r2(C)/f2(C); referee rb3(C); a line of that slope in $\Hcl{\times}$ is a conjecture |
| 4.14 | several environments: shared dependence kept, environment-specific dependence discarded, for $c$ in about $(2^{-m}/E,2^{-m})$; the twin obstruction persists | sketch (downgraded from proved); referee rb3(B) |
| 5.1 | Ville's bound survives for chronological classes (inputs from the observable history) | proved; computed r5(A); referee rb5(C) |
| 5.2 | an in-context learner beats the human's program at every $n$ and for every data set once $\lambda(\ell_H-\ell_U)>\log(1/w)$ | proved; computed r5(B); referee rb5(A) |
| 5.3 | episodes restore Theorem A in a class of restarting hypotheses; the restarted learner pays its regret every episode | proved; computed r5(C) |
| §6.1-1-old | "a learner … is not a single hypothesis when randomness is private to each query" | **refuted** as stated (referee rb5(A)): the exclusion comes from the hypothesis class |
| 5.4(3) | single trajectory, class without a dominating member | open; evidence referee rb5(B) |

---

## References

* **Paper 2** (`paper-steeper/sections/`), by label: `def:setup:data`, `def:setup:class`, `def:setup:objectives`, `lem:setup:hull`, `cor:absorb:nouniversal`, `prop:absorb:history`, `thm:split:shared`, `def:kink:kinks`, `lem:kink:main`, `lem:kink:secant`, `def:split:setting`, `lem:split:ville`, `thm:recovery:main`, `lem:recovery:ratios`, `thm:split:private`, `prop:recovery:frozen`, `prop:recovery:beyond`, `def:teacher:instance`, `lem:teacher:list`, `lem:teacher:coding`, `lem:teacher:twopart`, `thm:teacher:main`, `rem:teacher:selected`, `tab:teacher:numbers`, `prop:teacher:schedules`, `cor:teacher:sampled`, `lem:teacher:finite`, `prop:limits:separable`, `prop:limits:noident`, `prop:limits:rateblind`, `prop:related:computable`, `q:teacher:open`; the facts (F1)–(F5) of `app:setup:facts`.
* `research/tracks/split/notes-final.md` and `split/iid/notes-final.md` (§7.4 for misspecification).
* `referee-A.md` (A1, R1, ra1) and `referee-B.md` (B1's repair, rb1–rb6) in this folder.
* J. Ville, *Étude critique de la notion de collectif*, Gauthier-Villars, 1939 (as cited by Paper 2).
* S. Kakutani, "On equivalence of infinite product measures", *Ann. Math.* 49:214–224, 1948 (as cited by Paper 2; used through `lem:recovery:ratios`(b)).
* T. M. Cover, J. A. Thomas, *Elements of Information Theory*, 2nd ed., Wiley, 2006: the type-class bounds $(n+1)^{-|B|}2^{nH}\le|T(P)|\le2^{nH}$ (theorem number not re-checked; r6(B) checks the inequality numerically; Paper 2's `def:teacher:instance` cites the binary case to the same book).
* Standard facts used without a new citation, each a textbook result: the relativised forms of (F3), (F4) (M. Li, P. Vitányi, *An Introduction to Kolmogorov Complexity and Its Applications*, the proofs relativise uniformly); the generalised Hölder inequality; the Hewitt–Savage 0–1 law; the law of the iterated logarithm for i.i.d. variables of finite variance (Hartman–Wintner). No new literature was searched for this revision. The remark on maximum-likelihood consistency for hidden Markov models (Remark 5.4(3)) is an analogy, not a citation; it was not checked.

---

## Verification log

*Run 2026-10-14 with Python 3.11.15 and NumPy 2.4.6. Scripts of `notes.md` are in `checks/`; scripts of this revision in `checks-final/`. Each output is the `.out` file of the same name. Every script is deterministic or seeded with its own `numpy.random.default_rng` seed, named in its docstring.*

**Scripts of `notes.md` (unchanged).**
* **r1_side_info_ville** (seed 1). Lemma 2.1, Proposition 2.3, Remark 2.4. Cited: r1(A) tail (now compared with $M_02^{-j}$), r1(B), r1(C).
* **r2_window_exact** (seed 2 for the PRG seeds). Superseded by f2 for all numbers quoted here.
* **r3_window_samples** (seed 3). Its output is byte-identical to f3's.
* **r4_nonident_exact** (seeds 41, 43; exact enumeration). r4(A) and r4(C) are identical to f4's; r4(B) is superseded by f4(B).
* **r5_latent_state** (seed 5). Propositions 5.1–5.3.
* **r6_coding_lemma** (seed 6). Lemma 4.4, type-class bounds, the memoriser's rate, Proposition 4.10(d) arithmetic.

**Scripts of this revision.**
* **f2_window_exact, f3_window_samples, f4_nonident_exact.** Copies of r2–r4 in which every code length $\lceil\log\binom Nt\rceil$ is computed by the exact integer `(comb(N, t) - 1).bit_length()` (B-B9), with two docstring typos in f4 corrected. Comparison with the saved outputs of r2–r4, by `diff`:
  * f3 is byte-identical to r3.
  * f2 differs from r2 only in the offset column `G_expl` of four rows of (A): $-9.61\to-9.00$ (three rows) and $-10.39\to-10.00$. No window changes.
  * f4 differs from r4 only in (B): the $t=1$ alien's length $13\to12$, and the rows $c=0.03,n=64$ (human $0.0058\to0.0040$, $t=1$ alien $0.0300\to0.0318$), $c=0.0571,n=64$ (human $0.5891\to0.5797$), $c=0.0909$ at $n=16$ (H(other q) $0.3108\to0.2626$, coin $0.1302\to0.1168$, $t=1$ alien $0.0616$ new), $n=64$ (human $0.9025\to0.9024$), and the λ = 2 row at $n=64$. These are exactly the changes referee B computed in rb6(B). The quoted values change only from 0.903 to 0.902 at the middle, $n=64$.
* **f7_closeness** (seeds 71, 72, 73; 10 s). Lemma 4.6, Theorem 4.7, Corollaries 4.8, 4.9.
  * (A) Hölder step, $\sum_b\tilde q_w\le\sum_bq_w\le1$, the identity $-\log Q(\beta)=2^{m-1}(H+R)$, and the total mass $Z\le1$ by brute force over $3^8$ couplings; 20 latent-cause instances × 40 programs.
  * (B) Counting forms of Lemmas 4.4 and 4.6, exhaustively over the $\binom{16}4=1820$ couplings, feature (75,768 programs, Kraft 0.951) and latent-cause (3040 programs) channels; an internal assertion that $\Ex D_{1/2}\le\bar D$ for every program.
  * (C) Population $J_c$-minimisers at $m=6,8,10$ for random and interval couplings, with the machine-free bound of Theorem 4.7(vi).
  * (D) Theorem 4.7(U)'s bound at Paper 2's sizes with κ = 0.
* **f8_confounding** (exact; seed 81 in (B); 15 s). Proposition 4.11 and 4.10(a2): exhaustive counts for four $(m,s_0)$, and the simple-versus-complex human in one explicit class.

**Reproducibility.** All scripts were copied to a scratch directory and re-run with `python3 -I`; every stderr was empty.

| script | time | result |
|---|---|---|
| r1 | 5 s | byte-identical |
| r2 | 1 s | byte-identical |
| r3 | 6 s | byte-identical |
| r4 | 35 s | byte-identical |
| r5 | 337 s | byte-identical |
| r6 | 2 s | byte-identical |
| f2 | 5 s | byte-identical |
| f3 | 6 s | byte-identical |
| f4 | 36 s | byte-identical |
| f7 | 10 s | byte-identical |
| f8 | 15 s | byte-identical |

After the run, the docstring of f8 was corrected (a section number); f8 was run again in a fresh scratch directory, and its output is byte-identical to the saved one. SHA-256 (first 16 hex digits) of the final revision scripts: f2 `6b31c8fd69dc503d`, f3 `4ce5e81ff86bb217`, f4 `b43ac75fe5b76abb`, f7 `56c088f0c7c55ebf`, f8 `382f228efd157c7d`.

**Referees' scripts.** Their outputs were read and the numbers quoted here were taken from them: ra1(A)–(E), rb1–rb6. Both referees report byte-identical re-runs of their own scripts and of r1–r6. The constructions of rb4(C) ($\Psi_{\rm var}$) and rb5(A) (the history-aware class) were read in the scripts. The referees' proofs relied on here were re-derived: A1 (as Lemma 4.5(d) and Theorem 4.7(U), in the conditioned setting) and R1 (as Proposition 4.11; one constant corrected, $K(f)\le\ell(\pi)+2\log(m+1)+\kappa$, which changes $2\log(m+1)$ to $4\log(m+1)$ in the no-window condition).

**Proof checks done for this record.**
* *Setting 4.1.* The bounds $t_H\le\kappa$ (pairwise distinct ρ) and $-t_H-\kappa\le D_0\le K(h_0)-K(h_0\mid\mu)+\kappa$; $\delta_\beta\ge-1-\kappa$.
* *Lemma 4.4.* Lower semicomputability from $(\pi,h_0,\mu)$; no $K(m)$ term.
* *Lemma 4.5.* The relativised chain (F4), (F3), (F1); (d) directly from $B_\beta\le K(\beta\mid h_0,\mu)+\kappa$; (e) with $K(h_0\mid\mu)=\ell_0-D_0$; $\pi_H\in M_t$ for $t\ge t_H$.
* *Lemma 4.6.* The generalised Hölder step and its use of injectivity; $\sum_b\tilde q_w\le1$ by the inequality of geometric and arithmetic means; lower semicomputability of $Q$; the normalisation by $2^k$ with $K(k)\le2\log(k+1)+\kappa$ and $k\le-\log Q(\beta)$; the exact evaluation of $-\log Q(\beta)$ and $\log Z$; the sign conventions in the final division.
* *Theorem 4.7.* Each hypothesis of `lem:kink:main`(i),(ii),(iv) matched in both cases: the reference point bounded by $\pi_H\in\mathcal M$; $c>\tau=2^{-m}$; $\eta_{\mathcal N}=+\infty$ (U) or the left condition (L); $\alpha_{\rm r}-\ell_{\mathcal M}=\Gamma$ (U) or $\Gamma+\kappa$ (L). The algebra of (vi) from Lemma 4.6, (iii) and (iv), including $2+\frac2{a-1}=\frac{2a}{a-1}$ and the ε coefficient $1+\frac2{a-1}=\frac{a+1}{a-1}$. (vii): the memoriser's code and its computation of $h(x,\cdot)$ from $\pi_H$.
* *Corollary 4.8(b).* $K(h_0\mid\pi,\mu)$ for level-1 programs; $D_0$ from $K(a)\ge d$ and the computability of $a$ from $h_0$.
* *Proposition 4.10.* (a2) disjointness; (b4) the identity $J(\pi_+)-J(\pi_H)=(\lambda_n-ns_+)\Delta-W_n$, the exchangeability of the event, and the reverse Fatou step; (b5) all five kinds of competitor; (c), (d) relative to the shortest copy.
* *Proposition 4.11.* (a)–(c) re-derived, with the corrected constant in (c).
* *Proposition 5.3.* The step "KL = 0 implies equal conditionals", through $M_t\ge\Ex[M_T\mid\mathcal F_t]=1$ and $\Ex M_t\le1$.
* *Not checked independently.* The proofs that are assemblies of Paper 2's lemmas inherit Paper 2's verification status. The relativised symmetry of information and the other textbook facts listed under References were not re-proved. No referee has read the material new in this revision (Lemma 4.6, Theorem 4.7(vi), Proposition 4.10(a2),(b4),(b5)).
