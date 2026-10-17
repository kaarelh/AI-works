# Shared notation for the research threads (draft)

*Written by the lead researcher at thread selection, 2026-10-15. Binding for every thread record (`tracks/<key>/notes.md`, `notes-final.md`), every referee report and the synthesis, until the planning editor turns it into the paper's `NOTATION.md`. A thread that needs a new global symbol, or finds a clash, says so in a section "Notation requests" of its record instead of inventing one silently. Local letters are allowed inside one thread if they are defined there and are not in the global tables below.*

**Compatibility.** This file extends the SOI notation, `../solomonoff-function-induction/paper/NOTATION.md` (identical copy at `../solomonoff-operator-induction/paper/NOTATION.md`; call it **SOI-N**). Where an object here is the same as an object there, the symbol is the same, with the exceptions listed in §2, each forced by a clash with standard logical notation.

---

## 0. Names (macros; the final name is undecided)

The family studied in the paper has the working name "Solomonoff axiom induction". The author has not chosen a final name, so:
* **No argument, claim or heading may depend on the name.**
* In LaTeX the name is only ever produced by the macros below. In the markdown records write "SAI" (the abbreviation the macro will print) or "axiom induction"; write the laws by their symbols ($M_A$, $W_A$, $K_A$, ...), which do not contain the name.

| macro | prints (working value) | use |
|---|---|---|
| `\SAI` | Solomonoff axiom induction | the family, in prose |
| `\SAIabbr` | SAI | abbreviation, in prose |
| `\SOI` | Solomonoff operator induction | the companion family (SOI-N, `RENAME.md`) |
| `\SOIabbr` | SOI | abbreviation |

* "SOI" without qualification means the one-tape law $M_F$ (SOI-N). Write SOI, not SFI, in new records (brief, "Naming of the companion papers"). The thread key `sfi` is kept only as a folder name.
* "SAI" without qualification means the one-tape proof-requiring law $M_A$ (§4).
* The earlier report `../axiom-induction` is cited as **the AI-paper** (printed numbers, e.g. "AI-paper Thm 6.3") and its records as **model, universal, pa, experiments, TF** (time-followup) and **SD** (short-derivations). Its abbreviations AI, FIcons, FIall are translated in §5; do not use them for this paper's objects.
* SOI Paper 1 and Paper 2 are **P1** and **P2**, cited by printed numbers or LaTeX labels.

---

## 1. Inherited unchanged from SOI-N

* $\log=\log_2$; losses and code lengths in bits. $c,c',\dots$ are machine constants (they depend only on the fixed universal machines, the syntax coding and the background $B$); $O(1)$ means the same.
* $\Unif$ (`\Unif`) is the fair-coin measure on tapes $\omega\in\{0,1\}^\infty$; $[w]$ is the cylinder of a finite string $w$. $\Prob$, $\Ex$ are the true law of a data process and its expectation. $\lambda$ is **only** the steepness exponent of P2 (weight on program or axiom length against fit), never the tape measure.
* $V$ is the fixed universal prefix machine; $K$, $K(\cdot\mid\cdot)$ prefix complexity; $\mm(i)=\sum_{V(p)=i}2^{-|p|}$; $K(\nu)$ the least $K(i)$ over indices of $\nu$; `\Kpad`, `\Ktail`, `\Omtail{\ell}` as in SOI-N. $p$ is a program, $|p|$ its length.
* $n$ = number of revealed data; $d$ = bit length of inputs (words); $N:=2^d$.
* SOI objects, same symbols and macros: function machines (renamed letter, §2), $M_F$ (`\MF`), $\bar M_F$, $W$ (coin-free SOI), $K_F$ (`\KF`), $M_{\rm prod}$, $M_{\rm pq}$, $M_H$, $M_{\rm len}$, $M_{\rm rd}$, $\Wcirc$, `\csize`, $L_{\rm SOI}$ (`\LSFI`). P2's $J_\lambda$, λ-MAP, hull and kink vocabulary (`lem:setup:hull`, `lem:setup:coding`, `lem:kink:main`, `thm:kink:converse`, `cor:kink:split`).
* Conventions (§7 below repeats them): semimeasure convention primary; normalised convention; every lower bound says which convention.
* Statuses (SOI-N §7): proved; computed; known (with a verified reference); known, unverified; proof sketch; conjecture; refuted (kept with its counterexample); open (not a theorem environment).

---

## 2. Renames forced by clashes with SOI-N

| SOI-N symbol | meaning there | here | reason |
|---|---|---|---|
| $T$, $T_U$, $f^T_\omega$, $\nu_T$ | function machine, universal one, its random partial function, its law | $F$, $F_U$, $f^F_\omega$ (and $f_\omega:=f^{F_U}_\omega$), $\nu_F$ | $T$ is a theory here. `\MF` still prints $M_F$ and now reads "the function version". |
| $\varphi_e$ | $e$-th partial computable function | $\{e\}$ (Kleene bracket) | $\varphi,\psi,\chi$ are sentences here |
| (none; scouts wrote $W_e$) | $e$-th r.e. set | $\mathsf W_e$ (sans serif; macro `\re{e}`) | $W$, $W_A$ are coin-free mixtures |
| $X$, $Y$ | input set, label set | $X=\Sent_{\mathcal L}$, $Y=\{0,1\}$ (two-valued) or $Y_3=\{1,0,\iota\}$ (three-valued) | same objects, made explicit |
| $L_\nu$, $L$ | losses | unchanged; **languages are calligraphic** $\mathcal L$ | the scouts wrote $L$ for languages and $L_A$ for both the arithmetic language and the loss of $M_A$ |
| $R$ | risk (P1, P2) | not used here; $R$ is the unary predicate of literal data (§3.4); a reasoner is $\mathcal R$ | the risk does not occur in this paper |
| $\Pi_\lambda$ | posterior (P2) | unchanged where P2 is cited; one-tape class probabilities are $\Unif_A(\cdot)$ (§3.6), never $\Pi[\cdot]$ | $\Pi_1$ is the arithmetical class |
| $\kappa$ | P2's machine constant | P2 only. Peakedness of an error is $\mathrm{pk}(e)$ (§6.4); the Chaitin sentence is $\mathrm{Kgt}_m(x)$ (§6.2) | scouts N1, N2 used $\kappa$ for both |
| $\delta$ | confidence | data precision in the laws and Kepler material (local to those threads, stated there); confidence is never used in those threads | |

Further renames of scout notation are in §5.

---

## 3. Logic and data

### 3.1 Languages and theories

* $\mathcal L$ is a countable first-order language with equality and computable syntax; $\Sent_{\mathcal L}$ its sentences (`\Sent`); $\vdash$ classical first-order derivability (a fixed Hilbert calculus where derivation size matters, the AI-paper's calculus $\mathsf K$).
* $B\subseteq\Sent_{\mathcal L}$ is the **background**: decidable (no loss, by Craig) and consistent; default $B=\emptyset$. Results that need more say so: "$B$ true and $\supseteq\Q$" means $\Q\subseteq\Cn(B)$ and $B$ has a model whose arithmetic reduct is $\mathbb N$.
* For $\Gamma\subseteq\Sent_{\mathcal L}$: $\Cn(\Gamma):=\{\varphi:B\cup\Gamma\vdash\varphi\}$ (`\Cn`); $\Gamma$ is *consistent* if $B\cup\Gamma$ is. A **theory** is any set $T$ of sentences, identified up to deductive equivalence where stated: $[T]:=\{e:\Cn(\mathsf W_e)=\Cn(T)\}$.
* $\varphi^1:=\varphi$, $\varphi^0:=\neg\varphi$. $T$ **decides** $\varphi$ if it proves $\varphi$ or $\neg\varphi$.
* $\mathcal L_{\rm ar}:=\{0,S,+,\cdot,<\}$; $\Q$, $\PA$ (sans serif, AI-paper macros); numerals $\underline n:=S^n0$; $\Delta_0,\Sigma_1,\Pi_1$ as usual; $\Pi_1^*$ := finite conjunctions of $\Pi_1$ sentences and negations of $\Sigma_1$ sentences (each equivalent to a $\Pi_1$ sentence). A theory is **$\Sigma_1$-sound** if it proves no false $\Sigma_1$ sentence. $\Con(T)$ is the canonical consistency statement of an r.e. presentation.
* Observational and theoretical vocabulary: $\mathcal L=\mathcal L_O\cup\mathcal L_T$; the **observational content** of $T$ is $T_O:=\Cn(T)\cap\Sent_{\mathcal L_O}$.

### 3.2 Data

* A **data set** $D$ is a finite partial function $\Sent_{\mathcal L}\rightharpoonup\{0,1\}$ (label 1 = true, 0 = false), as in SOI-N with $X=\Sent_{\mathcal L}$. **Three-valued** data sets map into $Y_3=\{1,0,\iota\}$, $\iota$ = "independent" (`\iota`; never write "ind").
* $D^\pm:=\{\varphi^{D(\varphi)}:\varphi\in\dom D\}$ (the literals, two-valued part); $\psi_D:=\bigwedge D^\pm$ in a fixed canonical order ($\top$ if empty). $D$ is **consistent** if $B\cup D^\pm$ is.
* $D+(\varphi,b)$ for $\varphi\notin\dom D$; a reveal sequence $(\varphi_t,b_t)_{t\le n}$ with prefixes $D_t$; an infinite stream $D_\infty$.
* A **question** is a finite set $\mathcal Q=\{\varphi_1,\dots,\varphi_k\}$ of pairwise $B$-incompatible sentences whose disjunction $B$ proves (its direct answers); a yes/no question is $\{\varphi,\neg\varphi\}$. A **conditional question** is a pair $(\alpha,\ell)$ "given $\alpha$, is $\ell$ the case?" (used by `shape`).

### 3.3 Complexities of theories

| symbol | meaning |
|---|---|
| $K_\equiv(T)$ (`\Keq`) | $\min_{e\in[T]}K(e)$: complexity up to deductive equivalence |
| $\mm_\equiv(T)$ (`\mmeq`) | $\sum_{e\in[T]}\mm(e)$ |
| $\Ext(T)$ (`\Exts`) | $\{e:\mathsf W_e\text{ consistent},\ \Cn(\mathsf W_e)\supseteq\Cn(T)\}$, the consistent extensions; $\mm(\Ext T):=\sum_{e\in\Ext T}\mm(e)$. (The AI-paper's `\Ext` is the extensionality axiom; do not reuse it.) |
| $K_{\rm fin}^{\mathcal L}(D)$, $W_{\rm fin}^{\mathcal L}(D)$ (`\Kfin`, `\Wfin`) | least $K(\psi)$, resp. $\sum\mm(\psi)$, over single sentences $\psi\in\Sent_{\mathcal L}$ with $B\cup\{\psi\}$ consistent and $\vdash\psi_D$ (finite theories) |

### 3.4 Special languages

* **Literal language** (SD Def 1.3): a constant $\mathtt e$, unary function symbols $\mathtt s_0,\mathtt s_1$, a unary relation symbol $R$; $t_w:=\mathtt s_{w_1}(\cdots\mathtt s_{w_k}(\mathtt e)\cdots)$, $\varphi_w:=R(t_w)$, $|\varphi_w|=|w|+2$; $D^X$ lists $(\varphi_w,[w\in X])$ in length-lexicographic order; $f_X$ the literal labeller of $X$. The free term algebra on $\mathtt e,\mathtt s_0,\mathtt s_1$ is $\mathfrak T$ (scout S wrote $W$); the pairing model of scout S §3.6 is $\mathfrak U$ (scout S wrote $U$).
* **Positive literals of a fresh predicate**: condition (Lit) of scout F (F9) or the hypothesis of scout S Thm 2.7 (closed terms pairwise distinct in some model of $B$, $R$ not in $B$).

---

## 4. The inducers (one symbol per object)

### 4.1 Machines and the one-tape law

| symbol (macro) | meaning | scout names |
|---|---|---|
| $G$, $A^G_\omega$ | **theory machine**: a c.e. set $G\subseteq\{0,1\}^*\times\Sent_{\mathcal L}$; $A^G_\omega:=\{\chi:(w,\chi)\in G,\ w\sqsubseteq\omega\}$, the axioms emitted on tape $\omega$ | F: theory machine; S: axiom machine |
| $\nu_G$ | its law: $\nu_G(D):=\Unif\{\omega:B\cup A^G_\omega\text{ consistent and }\vdash\psi_D\}$ | F: $\nu_G$; S: $\mu_G$ |
| $\nu^3_G$ | three-valued law (also requires: decides no $\iota$-labelled sentence) | F |
| $G_U$, $A_\omega$ | universal theory machine (read a $V$-program, run that machine on the rest of the tape); $A_\omega:=A^{G_U}_\omega$ | F, S |
| $E_D$ | $\{\omega:B\cup A_\omega\text{ consistent},\ \vdash\psi_D\}$; $E_\infty:=\bigcap_nE_{D_n}$ | F |
| $O_\varphi$ | $\{\omega:B\cup A_\omega\vdash\varphi\}$, an r.e. open set | N1: $V_\varphi$ (clash with $V$) |
| $\Inc_0$ (`\Inc`) | $\Unif(O_\bot)$, the probability that the random theory is inconsistent | F |
| $M_A$ (`\MA`) | **the one-tape proof-requiring law** $\nu_{G_U}$; "SAI" without qualification | F: $M_A$; S: $M_{\rm AI}$ |
| $M_A^3$ (`\MAthree`) | $\nu^3_{G_U}$ | F |
| $L_A$ (`\LA`) | $-\log M_A$; cumulative loss in the semimeasure convention is $L_A(D_n)-L_A(\emptyset)$ | F (the scouts also wrote $L_A$ for the arithmetic language: now $\mathcal L_{\rm ar}$) |
| $\Bel_D$, $\Dis_D$, $\Indep_D$ (`\Bel`, `\Dis`, `\Indep`) | posterior probabilities that the random theory proves $\varphi$, proves $\neg\varphi$, decides neither | F, AI-paper |
| $\Bel_0$ | prior "probability of provability", $\Bel_0(\chi)=M_A(\{(\chi,1)\})$; $\Bel_0(\varphi)=\Unif(O_\varphi)-\Inc_0$ | F |
| $\Pl$ (`\Pl`) | plausibility $\Bel_0(\top)-\Bel_0(\neg\cdot)$ | F |
| $\Unif_A(\mathcal C)$ (`\UA`) | for a set $\mathcal C$ of deductive classes: $\Unif\{\omega:B\cup A_\omega\text{ consistent},\ [A_\omega]\in\mathcal C\}$; so $\Unif_A[T]$ and $\Unif_A(\Ext T)$ | F: $\Pi[T]$, $\Pi\mathrm{Ext}(T)$ |
| $M_A^{\rm dec}$ | mixture over random deciders (function machines with total $\{0,1\}$-valued outputs read as axiom sets) | S |

### 4.2 Coin-free and Kolmogorov versions

| symbol (macro) | meaning | scout / AI-paper names |
|---|---|---|
| $W_A$ (`\WA`) | $\sum_{p\in\dom V}2^{-|p|}\,\ind[B\cup\mathsf W_{V(p)}\text{ consistent},\ \vdash\psi_D]$ (enumerators) | F: $W_A$ |
| $W_A^{\rm dec}$ | the same over deciders; $W_A^{\rm dec}\asymp W_A$ (Craig) | AI-paper $W_{\rm AI}$; S: $W_{\rm AI}$ |
| $K_A$ (`\KA`) | $\min\{|p|:\dots\}$, the shortest consistent r.e. axiomatisation proving the data | F: $K_A$; S: $K_{\rm AI}$ |

### 4.3 Other variants of the family

| symbol (macro) | meaning | names |
|---|---|---|
| $M_A^{\rm nc}$ (`\MAnc`), $\Bel^{\rm nc}_D$ | consistency-requiring 0/1 weight $\Unif\{B\cup A_\omega\cup D^\pm\text{ consistent}\}$ and its Dempster-conditioned predictor | F; AI-paper $S_{\rm nc}$ |
| $M_A^{1/2}$ (`\MAhalf`) | graded consistency-requiring weight, grade ½ per unproved datum | F; AI-paper $S_g$ |
| $P_T$, $\Xi$ | generative (derivation-likelihood) variant: a theory's law on sampled theorems (AI-paper L1) and the universal mixture of data streams | F §2.9 |
| $W_A^3$, $W^{3,\rm cons}$ | three-valued coin-free AI and SOI (independence observed) | S: AI3, FI3 |

### 4.4 Consistent SOI (the comparison class)

| symbol (macro) | meaning | names |
|---|---|---|
| $\Gamma_f$ | $\{\varphi^{f(\varphi)}:\varphi\in\dom f\}$ for a partial labeller $f:\Sent_{\mathcal L}\rightharpoonup\{0,1\}$ | AI-paper, F, S |
| consistent / closed labeller | $B\cup\Gamma_f$ consistent / moreover $f(\varphi)=b\iff B\cup\Gamma_f\vdash\varphi^b$ | S Def 2.1 |
| $\nu_F^{\rm cons}$, $M_F^{\rm cons}$ (`\MFcons`) | $\Unif\{\omega:f^F_\omega\supseteq D,\ B\cup\Gamma_{f^F_\omega}\text{ consistent}\}$; universal: $F=F_U$ | F, S |
| $W^{\rm cons}$, $W^{\rm cl}$ (`\Wcons`, `\Wcl`) | coin-free SOI restricted to consistent / closed labellers | AI-paper $W_{\rm FI}$ (FIcons); S: $W_{\rm cons}$, $W_{\rm cl}$ |
| $K_F^{\rm cons}$ (`\KFcons`) | shortest consistent labeller extending $D$ | F, S |
| $W^{\rm all}$ | coin-free SOI on sentences without the consistency restriction | AI-paper FIall |

---

## 5. Resource-bounded variants (translation of the AI-paper and TF/SD)

| AI-paper / TF / SD | here | meaning |
|---|---|---|
| AI | $W_A^{\rm dec}$ (≍ $W_A$) | coin-free proof-requiring |
| FIcons, FIall | $W^{\rm cons}$, $W^{\rm all}$ | |
| AI$^{\rm chk}_t$, AI$^{\rm gen}_t$, AI$^{\rm Kt}_t$ | $W_A^{{\rm chk},t}$, $W_A^{{\rm gen},t}$, $W_A^{{\rm Kt},t}$ | membership-time, generation-time, Levin-Kt penalties on axioms |
| FIcons$^\tau$, FIall$^\tau$, FIcons$^{\rm poly}$ | $W^{{\rm cons},\tau}$, $W^{{\rm all},\tau}$, $W^{{\rm cons},{\rm poly}}$ | clocked labellers ($\tau$ = labeller clock) |
| (S §2.5) | $M_F^{{\rm cons},\tau}$, $M_F^{{\rm all},\tau}$ | one-tape clocked SOI |
| AI$[t,d]$; AI$^{a1}[t,h]$, AI$^{a2}[t,h]$, AI$^{b}[t,g]$, AI$^{b2}[t,g]$ | $W_A[t,d]$; $W_A^{a1}[t,h]$, $W_A^{a2}[t,h]$, $W_A^{b}[t,g]$, $W_A^{b2}[t,g]$ | charged deduction: $t$ = axiom-membership time, $d$ = derivation size, $h$, $g$ = per-instance or material budgets under readings (a1), (a2), (b), (b2) of SD Def 1.2, all under (F1) |
| FIcert$[t',d']$ | $W^{\rm cert}[t',d']$ | certificate SOI |
| AI$_{\mathcal L}$, AI$_O$ (S §3) | $W_A^{\mathcal L}$, $W_A^{\mathcal L_O}$ (same superscript on $M_A$, $K_A$) | all axioms vs observational axioms only |

Fit class (TF Lemma 1.6, AI-paper Lemma E.11): the set of $X$ on whose literal sequence $D^X$ a mixture has bounded loss.

---

## 6. Thread-specific global symbols

These are used across threads, so they are fixed here. Each thread may add local symbols.

### 6.1 `shape` (reasoner-relative theories)
* $\mathcal R$ is a **reasoner**: a deterministic procedure that, given a finite explicit theory $\Phi$ and a question antecedent $\alpha$, outputs a set of derived literals. Named reasoners: $\mathrm{UP}$ (unit propagation), $\mathrm{UP}_k$ ($k$ rounds), $\mathrm{GE}$ (Gaussian elimination, for theories written as linear equations), $\mathrm{PS}_t$ (proof search with time budget $t$).
* $\Phi$ is **$\mathcal R$-usable** for a law $V$ if $\mathcal R$ answers every conditional question in $\mathcal Q(V)$; auxiliary variables are the "intermediate concepts".
* Reasoner-relative inducers: $K_A^{\mathcal R}(D)$, $W_A^{\mathcal R}(D)$: shortest / weighted explicit theories that are consistent with each question antecedent and from which $\mathcal R$ derives each answer. With $\mathcal R$ unbounded proof search these reduce to $K_A$, $W_A$ on the question data.

### 6.2 `logic`
* $\mathrm{Lot}_k$: the lottery sentences (N1 wrote $\lambda_k$, which clashes with $\lambda$); $G_{\rm lot}$; $j^*_k$.
* $T_k$: the threshold theory of N1 Thm A1; $I'_k$ the $(k+2)$-bit truncation of $\Inc_0$.
* $\mathrm{Kgt}_m(x)$: the $\Pi_1$ sentence "$K(x)>m$" (N1 wrote $\kappa(x,m)$).

### 6.3 `terms`
* $\mathrm{Pair}$, $\mathrm{Std}$, $\theta_k$, $\mathfrak U$ (pairing gadget, S §3.6); $\iota_f$ for "$f$ is injective and not surjective" (N1 wrote $\iota$, which is now the independent label); $\mathrm{Inf}_n$ for "there are at least $n$ things" (N1 wrote $\lambda_n$).

### 6.4 `laws` (and the Kepler material of `philosophy`)
* **Two-part objective with exceptions:** $J_\lambda(T;D):=\lambda|T|+\mathrm{Exc}_D(T)$ (`\Exc`), where $\mathrm{Exc}_D(T)$ is the literal cost of the data $T$ does not prove ($\infty$ if $T$ is inconsistent with $D$). (N2 wrote $X(T;D)$, which clashes with SOI's input set.) λ-MAP as in P2.
* **Explanatory power:** $\mathrm{EP}_D(\mathcal A;T):=(\mathrm{Exc}_D(T\setminus\mathcal A)-\mathrm{Exc}_D(T))/|\mathcal A|$ for a module $\mathcal A\subseteq T$ (`\EP`).
* Approximate laws: exact law $T_0$, honest (tolerance-weakened) law $T^\varepsilon$; true error $e(t)$, $\varepsilon^*:=\operatorname{ess\,sup}|e|$; data precision $\delta$, measurement error bound $\delta_0$; dithered cell width $\Delta$ (N2 wrote $h$, which is a derivation budget here); **peakedness** $\mathrm{pk}(e):=\sup|e|/\Ex|e|$ (N2 wrote $\kappa$); per-datum literal cost $\gamma$ (N2 wrote $c$).

---

## 7. Conventions on predictions and losses

* **Semimeasure convention (primary).** Cumulative loss on a reveal sequence: $\sum_t-\log M_A(b_t\mid D_{t-1},\varphi_t)=L_A(D_n)-L_A(\emptyset)$; it depends on $D_n$ only as a set (indeed only through $\Cn(\psi_{D_n})$).
* **Normalised convention.** $\Bel/(\Bel+\Dis)$ per query. Upper bounds transfer from the semimeasure convention; lower bounds do not.
* **Three-valued convention.** Labels in $Y_3$, scored by $M_A^3$, whose conditionals sum to 1.
* Every loss statement names its convention; every lower bound says "semimeasure convention" or "both conventions".
* "$\asymp$" means equality within a factor $2^{\pm c}$ on every data set; "$\pm c$" an additive machine constant.

---

## 8. Records, statuses, labels

* Statuses as in §1; a status on every claim; refuted claims are kept with their counterexamples.
* Cite other threads as `<key> T<n>` (the target number in the thread's brief) or `<key> <item>` (the item number in its final record), and the scouts as scout F, S, P, L, N1 (`novel-logic`), N2 (`novel-science`) with their item numbers.
* Prospective LaTeX label keys for the paper: `intro, setting, basic, soi, logic, phil, kepler, laws, terms, shape, limits, related, discussion, verification`. Threads may already name their items `thm:<key>:<name>`.

## 9. Macro list (for the eventual preamble)

New macros (in addition to SOI-N §10 and the AI-paper's `\Bel`, `\Dis`, `\Indep`, `\Inc`, `\Pl`, `\Cn`, `\Sent`, `\Con`, `\Th`, `\PA`, `\Q`, `\gn`, `\num`, `\cplx`):

`\SAI`, `\SAIabbr`, `\SOI`, `\SOIabbr`, `\MA`, `\MAthree`, `\MAnc`, `\MAhalf`, `\WA`, `\KA`, `\LA`, `\UA`, `\Keq`, `\mmeq`, `\Exts`, `\Kfin`, `\Wfin`, `\MFcons`, `\Wcons`, `\Wcl`, `\KFcons`, `\re{e}`, `\Exc`, `\EP`.
