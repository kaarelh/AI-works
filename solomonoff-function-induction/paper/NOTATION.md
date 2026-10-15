# Notation for both SOI papers (binding)

This file fixes one notation for

* **Paper 1** (`paper/`): *Solomonoff Operator Induction: Definitions, Versions and Basic Theorems*, and
* **Paper 2** (`paper-steeper/`): *Steeper Simplicity Priors in Solomonoff Operator Induction: The Model–Randomness Split and the Teacher's Mistakes*.

**Naming** (binding: `research/paper-review/rename/RENAME.md`, 2026-10-15). *Solomonoff operator induction* (SOI) is the family of universal-prior solutions to Solomonoff's operator-induction problem; "SOI" without qualification means the one-tape version $\MF$ (stated once, after `def:setting:sfi`). Versions: one-tape $\MF$; per-query $\Mpq$ (Solomonoff's solution, eq. (10) of `solomonoff2008three`); product mixture $\Mprod$; coin-free $W$; Kolmogorov $\KF$; history-aware \SFIhist{}. "SFI" is not printed anywhere; the macro names `\LSFI`, `\LSFIbar`, `\SFIhist`, `\SFIset`, `\SFIcount`, `\SFIpairs`, the labels (`def:setting:sfi`, `sec:setting:sfi`, ...) and the bib keys (`claudeSFI2026...`) keep their names.

It is binding for every writer of both papers. The macros listed in §10 are defined in the block marked "SFI macros" at the end of `paper/preamble.tex` and `paper-steeper/preamble.tex`; the two blocks are identical. Use the macros where they exist. Do not redefine them, and do not add global macros in section files. A section may use a letter locally (§5) if it defines it in that section and the letter is not in the global table (§3).

Sources and their names below: **F** = `research/tracks/foundations/notes-final.md`, **Hi** = `history/notes-final.md`, **Ex** = `examples/notes-final.md`, **Co** = `context/notes-final.md`, **St** = `steeper/notes-final.md`, **Hä** = Hänni's notes and request (`research/prior/`, `research/00-brief.md`), **Sl** = the Vaintrob–Hänni slides. Item numbers are always the FINAL numbering of each track.

---

## 1. General conventions

* **Logarithms.** $\log=\log_2$; $\ln$ is natural. Losses, code lengths, KL divergences and mutual informations are in bits unless marked.
* **Constants.**
  * Paper 1: $c,c',c''$ are constants that depend only on the fixed universal machines and encodings ("machine constants"); $O(1)$ means the same. $c_\omega$ depends also on a Martin-Löf random sequence $\omega$; $c_b$ on a Bern(1/3)-random sequence $b$ (H6).
  * Paper 2: the machine constant is $\kappa$ (St's $\kappa$, the constant of $K(\pi)\le|\pi|+\kappa$), with $\kappa_g,\kappa_b,\kappa_e$ for the overheads of the reference programs and $\kappa'$ for a subclass. The constants of (Dom) and of $\xi_1\le2^{\kappa_1}U$ are $\kappa_0,\kappa_1$ (St's $c_0,c_1$). **In Paper 2, $c$ always means $\lambda/n$**, never a machine constant.
  * In Paper 1's summary of Paper 2 (`sections/steeper.tex`) write $\lambda/n$, never $c$, for the per-sample rate.
* **Sets and data.** $X$ inputs, $Y$ labels; default $X=Y=\{0,1\}^*$, any infinite decidable $X$ and countable $Y$ with $|Y|\ge2$ unless stated. Paper 2 takes $Y$ finite. $\bot$ = undefined; $\Ybot=Y\cup\{\bot\}$. A **data set** $D$ is a finite partial function $X\rightharpoonup Y$; $\dom D$; $D+(x,y):=D\cup\{(x,y)\}$ for $x\notin\dom D$; $D|_T$ restriction; $f\supseteq D$ "$f$ extends $D$". A sequence $(x_t,y_t)_{t\le n}$ is **consistent** if $D_n:=\{(x_t,y_t):t\le n\}$ is a partial function. The history is $h_t:=(x_1,y_1,\dots,x_t,y_t)$.
* **Counts and lengths (one meaning in both papers).**
  * $n$ = number of revealed pairs (sample size). St's $N$ becomes $n$; schedules are $\lambda_n$; St's $D_N,t_N,\beta_N,i_N$ become $D_n,t_n,\beta_n,i_n$.
  * $d$ = bound on the bit length of inputs. F's and Ex's "$n$-bit inputs" become $d$-bit inputs; St's $n_N:=\max_{i\le N}|x_i|$ becomes $d_n:=\max_{i\le n}|x_i|$.
  * $N:=2^d$ = number of inputs of length $d$ (Ex's $N=2^n$ in H5 becomes $N=2^d$; St's table size $n=2^d$ becomes $N$). A full-table data set has $n=N$.
  * $k$ is free for local counts (points in a data set, blocks, steps).
* **Probability.** $\Unif$ is the uniform (fair-coin) measure on tapes $\omega\in\{0,1\}^\infty$, $[w]$ the cylinder of a finite string $w$. $\Prob,\Ex$ are the true law of the data process and its expectation. $\mu$ is the input distribution (both papers). $H(p)$ is the binary entropy of a number $p$; $H(Z)$, $H(Z\mid W)$ Shannon entropies of random variables. $\Bern(p)$, $\Var$, $\KL$, $\Hel$ (squared Hellinger distance).
* **Complexity.** $V$ is the fixed universal prefix machine, $V(\cdot,x)$ its conditional form; $K$, $K(\cdot\mid\cdot)$ prefix complexity; $\mm(i)=\sum_{V(p)=i}2^{-|p|}$; $K(\nu)$ is the least $K(i)$ over indices $i$ of $\nu$ in the stated effective enumeration. $\varphi_e$ is the $e$-th partial computable function.
* **Programs.** Paper 1 writes programs $p\in\dom V$. Paper 2 writes programs $\pi$ and $\ell(\pi):=|\pi|$, because $p$ is Hänni's error density there. This is the one deliberate difference between the papers; Paper 1's summary of Paper 2 uses Paper 2's letters.
* **Conventions for predictions.** Every statement about losses says which convention it uses. *Semimeasure convention*: the cumulative loss on $D$ is $-\log\nu(D)$ (§6). *Normalised convention*: per-step conditionals divided by their sum. Upper bounds proved in the semimeasure convention hold in both; lower bounds do not transfer automatically.
* **Statuses** (§7) and **labels** (§8) are fixed below.

---

## 2. How to read the tables

Each row gives the symbol (and macro), its meaning, where it is defined in the papers (label), and each source's name for it. "—" means the source does not use the object. "=" means the same symbol as in the paper.

---

## 3. Global symbols

### 3.1 Objects of Paper 1 (also used in Paper 2)

| symbol (macro) | meaning | defined in | F | Hi | Ex | Co | St |
|---|---|---|---|---|---|---|---|
| $\Unif$ (`\Unif`) | fair-coin measure on tapes | `def:setting:machine` | $\lambda$ | $\lambda$ | $\lambda$ | $\lambda$ | — |
| $T$, $f^T_\omega$, $\nu_T$ | function machine (c.e. consistent triples), its random partial function, its machine law | `def:setting:machine` | = (Def 2.5) | = | = | = | = |
| $T_U$, $\MF$ (`\MF`) | universal function machine; the one-tape version of SOI (the default), law $\nu_{T_U}$ | `thm:setting:universal`, `def:setting:sfi` | = (Thm 3.2, Def 5.1) | = | = | = | mixture of $\Pi_F$ |
| $\MFbar$ (`\MFbar`) | normalised conditional of $\MF$ | `def:setting:sfi` | $\bar M_F$ | $\bar M_F$ | $\bar M_F$ | $\bar\nu$ | — |
| $\Znorm(D,x)$ (`\Znorm`) | normaliser $\sum_y\MF(D+(x,y))$ | `prop:setting:transfer` | $Z_t\cdot M_F(D_{t-1})$ | $S_t$ | $S_t$ | — | — |
| $Z_t$ | $\Znorm(D_{t-1},x_t)/\MF(D_{t-1})$, posterior probability that $f_\omega(x_t)$ is defined | `prop:setting:transfer` | $Z_t$ | — | — | — | — |
| $\nu$ (weak) | weak function semimeasure | `def:setting:weak` | = (Def 2.1) | = | = | = | shared hypothesis $P$ |
| $\nu_P$ | containment functional of a random partial function with law $P$ | `def:setting:rpf` | = (Def 2.2) | — | — | — | — |
| $\Mob_T\nu(D)$ (`\Mob`) | Möbius sum $\sum_{\dom E\subseteq T}(-1)^{|E|}\nu(D\cup E)$ | `prop:setting:mobius` | $\Delta(D,T)$ | — | — | — | — |
| $\nutri$ (`\nutri`) | three-input weak semimeasure of F Ex 2.4 | `ex:setting:weaknotrpf` | $\tau$ | — | — | — | — |
| $\Mw$ (`\Mw`) | universal weak function semimeasure | `thm:setting:weakuniversal` | $M^w$ | $M^w$ | — | $M^w$ | mixture of $\Pi_w$ |
| $W$ | coin-free version: deterministic program mixture (programs self-delimit before reading the input) | `def:versions:variants` | $W$ | — | — | $W$ | — (St's $W_{\rm det}$ is a different object) |
| $\KF$ (`\KF`) | single shortest consistent program, the Kolmogorov version | `def:versions:variants` | $K_F$ | — | — | $K_F$ | — |
| $\Mprod$ (`\Mprod`) | mixture of product laws (private randomness per input), on data sets | `def:versions:variants` | $M_{\rm prod}$ | $M_{\rm prod}$ | "product law" | $M_{\rm prod}$ | $\xi_\times$ |
| $\Mpq$ (`\Mpq`) | per-query version (fresh randomness per query), on sequences; Solomonoff's solution, eq. (10) of `solomonoff2008three` | `def:versions:variants` | $M_{\rm pq}$ | per-query mixture (Prop 4.9) | — | $S$ (§6 item 1) | — |
| $\nu_P$ (product) | product law $\prod_{(x,y)\in D}P(y\mid x)$ of a conditional semimeasure $P$ (Hänni's x-only sampler) | `prop:setting:includes` | $\nu_P$ | $\nu_P$ | — | product law | $\nu^{\otimes}$ |
| $\nulen$ (`\nulen`) | law of $F(x)=\omega_{|x|+1}$: one shared coin per input length | `prop:versions:shared` | $\sigma$ | — | — | — | $\sigma$ (Prop 1.7(iii)) |
| $\Omtail{\ell}$ (`\Omtail`) | $\sum\{2^{-|p|}:p\in\dom V,|p|\ge\ell\}$ | `prop:versions:Wgap` | $\tau_V(\ell)$ | — | — | — | — |
| $\Kpad(N)$ (`\Kpad`) | padded complexity $\min_{L\ge N}K(L)$ | `prop:versions:tape` | $\kappa(N)$ | $\kappa(N)$ | — | — | — |
| $\Ktail(N)$ (`\Ktail`) | $-\log\sum_{L\ge N}2^{-K(L)}$ | `prop:hist:programs` | — | $\tau(N)$ | — | — | — |
| $\KP(z\mid x)$ (`\KP`) | input-independent conditional complexity $\min\{|h|:h\in\dom V,h(x)=z\}$ | `rem:versions:Wdelim` | — | — | — | $K^{\mathcal P}$ | — |
| $\MH$ (`\MH`) | law of \SFIhist{}, the universal chronological semimeasure | `def:hist:sfihist` | $\xi\asymp M_H$ (Prop 7.2) | $\xi:=M_H$ | $\xi$, (F7) | SFI$^{\rm hist}$ | $M_H\asymp\xi$ |
| $\MHin$ (`\MHin`) | universal chronological semimeasure for inputs given previous labels | `thm:hist:si` | — | $\xi'$ | — | — | — |
| \SFIhist, \SFIset, \SFIcount, \SFIpairs | SOI whose hypotheses see the list / set / count of previous inputs / previous pairs (print SOI$^{\rm hist}$ etc.) | `def:hist:sfihist`, `prop:hist:variants` | — | = | SFI$^{\rm hist}$, SFI$^{\rm set}$ | = | — |
| $\Mcount,\Mset,\Mpairs$ | their universal laws | `prop:hist:variants` | — | $M_{\rm count}$ etc. | — | — | — |
| $\Whist$, $\Khist$ (`\Whist`, `\Khist`) | program mixture and single shortest program for \SFIhist | `prop:hist:programs` | — | $W_{\rm hist}$, $K_{\rm hist}$ | — | — | — |
| $\rho$ | chronological semimeasure $\rho(y_{1:n}\Vert x_{1:n})$ | `def:hist:predictor` | $\rho$ | $\rho$ | — | — | $P_\pi$ in $\Pi_{\rm chr}$ |
| $P$ | Hänni's label sampler or a history-aware predictor $P(y\mid h,x)$ | `def:hist:predictor` | — | $P$ | $P$ | — | — |
| $\Delta$ | reveal law (input sampler); $\Delta(x_{1:n}\Vert y_{1:n-1})$ its sequence law | `def:hist:predictor`, `def:hist:readings` | — | $\Delta$ | — | — | — |
| $\Kpred(x_{1:n})$ (`\Kpred`) | least $|p|$ with $V(p,x_i)=\langle x_1,\dots,x_{i-1}\rangle$ for all $i\le n$ | `thm:hist:sandwich` | — | $KH$ | — | — | — |
| $M$, $\Mnorm$ (`\Mnorm`) | Solomonoff's universal monotone semimeasure, its normalised version | `prop:setting:si`, `thm:hist:si` | $M$ | $M$ | $M$, $M_{\rm norm}$ | $M$ | $M$ |
| $\code(h)$ (`\code`) | prefix-free block code $\bar x_1\bar y_1\bar x_2\cdots$ with the paper's code $\bar s:=1^{|s|}0s$ unless stated | `thm:hist:si` | — | $\mathrm{code}$ | $c(h_t)$, $\bar s$ | — | fixed-length blocks (Thm 1(d), local) |
| $\sep_k$ (`\sep`) | novelty: least $K(Q)$ of a decidable $Q$ separating $x_k$ from $x_{<k}$ | `prop:ood:budget` | — | — | — | $\sigma_k$ | — |
| $\Wcirc$ (`\Wcirc`) | circuit mixture with prior $2^{-s}/N_s$ | `def:comp:circuits` | — | — | — | $W$ (§3.2) | — |
| $\csize(f)$ (`\csize`) | least circuit size of $f$ (on $B$: $\csize_B(f)$) | `def:comp:circuits` | — | — | — | $c(f)$, $c_B(f)$ | — |
| $\Mlen$, $\Mrd$ (`\Mlen`, `\Mrd`) | length-activated and round-activated time-bounded mixtures | `def:comp:timebounded`, `prop:comp:round` | — | — | — | $S$, $S^{\rm rd}$ | — |
| $t(\cdot)$ | time bound of time-bounded classes | `def:comp:timebounded` | — | — | — | $p(\cdot)$ | — |
| $\mathcal C_t$, $\mathcal C^{\rm hist}_t$ | time-$O(t)$ $x$-only predictors; time-bounded history-aware predictors | `def:comp:timebounded`, `prop:comp:history` | — | — | — | $\mathcal C_p$, $\mathcal H_p$ | — |
| $\Psi(\rho)$ | kernel profile (arc-cosine kernels $\Psi_0,\Psi_1$) | `thm:nn:walsh` | — | — | — | $\kappa(\rho)$, $\kappa_0,\kappa_1$ | — |
| $P_A$ | NN Bayes prior on functions induced by an architecture | `prop:nn:functionspace` | — | — | — | $P_A$ | — |

### 3.2 Losses

| symbol (macro) | meaning | defined in | F | Hi | Ex | Co | St |
|---|---|---|---|---|---|---|---|
| $L_\nu(D)$ | $-\log\nu(D)$ for any weak semimeasure $\nu$ | `def:setting:sfi` | $-\log\nu$ | — | — | $L_\nu$ | $-\log P(D)$ |
| $\LSFI(D)$ (`\LSFI`, prints $L_{\rm SOI}$) | $L_{\MF}(D)=-\log\MF(D)$, the cumulative loss of $\MF$ in the semimeasure convention | `def:setting:sfi` | $L_n$ | $L_{\rm SFI}$ | $L_{\rm SFI}$ | $L_{M_F}$ | — |
| $\LSFIbar$ (`\LSFIbar`) | normalised cumulative loss of $\MF$ along a given order | `prop:setting:normalise` | $\bar L_n$ | $\bar L$ | $\bar\ell_t$ summed | — | — |
| $L_\rho(y\Vert x)$, $L_P$, $\LH$ (`\LH`) | $-\log\rho(y_{1:n}\Vert x_{1:n})$; for a predictor $P$; for $\MH$ | `def:hist:predictor`, `def:hist:sfihist` | — | $L_P$, $L_H=L_\xi$ | $L$ | — | — |
| $\LMjoint,\LMx,\LMy$ | SI's loss on $\code(h_n)$; on the inputs; on the labels given the inputs | `thm:hist:si` | — | $L_M^{\rm joint},L_M^x,L_M^y$ | $L^y_M$ | — | — |
| $L^x_{\rm in}$ | $-\log\MHin(x_{1:n}\Vert y_{1:n-1})$ | `thm:hist:si` | — | $L^x_{\xi'}$ | — | — | — |
| $R(Q)$ | expected log risk of a predictor $Q$ under $\mu$ | `thm:learn:batch` | $R(Q)$ | — | — | — | $R(\pi)$ (Paper 2, population risk) |

### 3.3 Objects of Paper 2

| symbol (macro) | meaning | defined in | St | T5 (`claude2026whatfollows`) / Hä |
|---|---|---|---|---|
| $\lambda$ | steepness exponent: weight $\lambda\ge1$ on program length against log-likelihood (both papers; never the tape measure) | `def:setup:objectives` | $\lambda$ | $\lambda$; Hä "higher coefficient on the length" |
| $c:=\lambda/n$ | per-sample rate; $\lambda=cn$ | `rem:setup:persample` | $c=\lambda/N$ | $c$ |
| $\eta=1/\lambda$ | exponent of the tempered (fractional) posterior $\Pi^\eta$ | `def:setup:objectives` | $\eta$ | — |
| $\epsilon$ | near-optimality slack ($J_c(\pi)\le\Phi(c)+\epsilon$) | `thm:teacher:main` | $\eta$ (Thm 2, Props 2.8, 2.17) | — |
| $\mathcal H$; $\Hcl{\times},\Hcl{F},\Hcl{w},\Hcl{\mathrm{SI}},\Hcl{\mathrm{chr}}$ (`\Hcl`) | hypothesis class (c.e. prefix-free program set with uniformly lsc likelihoods); canonical product, machine-law, weak, SI and chronological classes | `def:setup:class` | $\Pi$; $\Pi_\times,\Pi_F,\Pi_w,\Pi_{\rm SI},\Pi_{\rm chr}$ | — |
| $\pi$, $\ell(\pi)$, $P_\pi$, $\nu_\pi$ | program, its length, its likelihood map, its conditional semimeasure (product classes) | `def:setup:class` | = | — |
| $J_\lambda(\pi;o)$, λ-MAP | two-part objective $\lambda\ell(\pi)-\log P_\pi(o)$ and its minimisers | `def:setup:objectives` | = | = |
| $\Pi_\lambda(\pi\mid o)$, $\xi_\lambda$ | power-prior posterior and mixture $\sum_\pi2^{-\lambda\ell(\pi)}P_\pi$; $\xi^\times_\lambda,\xi^F_\lambda$ for $\Hcl{\times},\Hcl{F}$; $\xi_{\mathcal C}$ for a class $\mathcal C$ | `def:setup:objectives` | = | — |
| $\Pi^\eta(\pi\mid o)$ | tempered posterior $\propto2^{-\ell(\pi)}P_\pi(o)^\eta$ | `def:setup:objectives` | = | — |
| $\xi_\times=\xi_1$ over $\Hcl{\times}$ | equals $\Mprod$ exactly | `def:setup:class` | $\xi_\times$ | — |
| $U$, $\pi_U$, $\ell_U$; (Dom) | universal member of a class and its length; the domination hypothesis with constant $\kappa_0$ | `thm:absorb:absorption` | $U,\pi_U,\ell_U$; $c_0$ | — |
| $\ell^*_\lambda$ | $(\lambda\ell_U+\kappa_0)/(\lambda-1)$, the length bound of absorption | `thm:absorb:absorption` | $L_\lambda$ | T5 Prop 2.3 threshold |
| $R(\pi)$, $R_B(\pi)$ | population risk; risk truncated at $B$ | `def:teacher:instance` | = | = |
| $J_c,J^B_c,\hat J_c$; $\Phi(c),\Phi^B(c)$ | per-sample objective (population, truncated, empirical); its infimum | `rem:setup:persample`, `def:teacher:instance` | = | = |
| $\Phi_1(c),\Phi_2(c)$ | the two lower bounds of Thm 2 | `thm:teacher:main` | $M_1(c),M_2(c)$ | — |
| $\lev(\pi)$ (`\lev`) | agreement level $\min\{t\ge1:u(\pi)>\tfrac12+2^{-t-1}\}$ | `def:teacher:instance` | $T(\pi)$ | — |
| $u(\pi)$ | agreement with the simple model | `def:teacher:instance` | = | — |
| $f_a$, $S$, $E$, $y^*$, $p=2^{-r}$, $m$ | parity model, error rule $S\subseteq\{0,1\}^m$, error set $E=S\times\{0,1\}^{d-m}$, teacher $f_a\oplus\ind_E$, error density, junta size | `def:teacher:instance` | = | Hä: "simple model", "systematic error", $2^{-10}$ |
| $L_S$, $B_S$, $\delta_S$, $I(\pi)$ | $\log\binom{2^m}{p2^m}$; $K(S\mid a,K(a))$; deficiency $L_S-B_S$; information about the rule beyond the parity | `def:teacher:instance` | = | — |
| $\pi_g,\pi_b$; coin | good model, memoriser, fair coin | `def:teacher:instance` | = | Hä: "good model", "model that learns the errors", "50/50 model" |
| $\Wdet$ (`\Wdet`) | total weight of deterministic fill-ins consistent with $D$ in a product class | `def:split:setting` | $W_{\rm det}$ | — |
| $\delta^*$ | Ville deficiency $\sup_n\log(\xi(D_n)/\nu(D_n))$, $\Prob[\delta^*\ge j]\le2^{-j}$ | `lem:split:ville` | $m^*$ | — |
| $\sophset_b$, $\sophx_b$ (`\sophset`, `\sophx`) | set and product sophistication with sufficiency slack $b$ | `def:algstat:set`, `def:algstat:product` | $\mathrm{soph}^{\rm set}_c,\mathrm{soph}^\times_c$ | = |
| $\rho^\times_D(\alpha)$, $h_z(\alpha)$ | product structure function; Kolmogorov structure function | `def:algstat:product`, `def:algstat:set` | = | = |
| $A$ | finite set model ($A\ni z$) | `def:algstat:set` | $S$ | $S$ |

---

## 4. Clashes and how they are resolved

Each entry: the clash, the decision, what writers must rename. Every rename is binding.

1. **$\lambda$** — tape measure (F, Hi, Ex, Co) vs steepness exponent (St, brief H9). *Decision:* $\lambda$ is the steepness exponent in both papers. The tape measure is $\Unif$. Rename every tape-measure $\lambda$ (F §1, Hi §1.1, Ex §1.1, Co §1.1).
2. **$\kappa$** — padded complexity (F, Hi) vs machine constant (St) vs kernel profile (Co §4.4) vs the slides' norm complexity $\kappa_N$ vs Ex's touching constant $0.7995$. *Decision:* $\kappa$ is the machine constant in Paper 2 only. Padded complexity $\to\Kpad$. Kernel profile $\kappa(\rho)\to\Psi(\rho)$, $\kappa_0,\kappa_1\to\Psi_0,\Psi_1$. Touching constant $\to\vartheta=0.7995167$ (so $\Ex L_{P^*}(\infty)=3\vartheta$). The slides' $\kappa_N$ stays, local to `sec:nn`, quoted as the slides' notation. Paper 1 uses no bare $\kappa$.
3. **$\tau$** — Hi's $\tau(N)$ (tail sum), F's $\tau_V(\ell)$ (halting mass), F's weak semimeasure $\tau$ (Ex 2.4), Hi's second order $\tau$ (Thm 5.2), Ex's tail frontier $\tau_n$, St's $\tau_B=2^{1-B}$. *Decision:* $\tau(N)\to\Ktail(N)$; $\tau_V(\ell)\to\Omtail{\ell}$; weak $\tau\to\nutri$; Hi's orders $\sigma,\tau\to\sigma,\sigma'$; Ex's $\tau_n$ (tail frontier) stays, local to `sec:ex`; St's $\tau_B$ stays, local to `sec:teacher`.
4. **$m$** — $\mathbf m$ (F, St) vs confidence exponent (Ex: $\Pr[\cdot<\cdot-m-c]<2^{-m}$) vs Co's sample size and expected Gibbs mistakes vs Hi's field degree GF$(2^m)$ vs St's junta size vs St's Ville deficiency $m^*$. *Decision:* bold $\mm$ is the universal discrete semimeasure (both papers). Paper 2: $m$ = junta size. Paper 1: confidence exponent $\to j$ (bounds read "with probability at least $1-2^{-j}$"); Co's sample size $\to n$; Co's expected Gibbs mistakes $\to\mathcal E$; Hi's GF$(2^m)\to$ GF$(2^q)$. St's $m^*\to\delta^*$.
5. **$c$** — machine constant (F, Hi, Co, Ex) vs $\lambda/N$ (St) vs St's sufficiency slack in $\mathrm{soph}_c$, "$c$-sufficient" (§3.5). *Decision:* §1: Paper 1 $c$ = machine constant; Paper 2 $c=\lambda/n$ and machine constants are $\kappa$'s; St's $c_0,c_1\to\kappa_0,\kappa_1$; St's sufficiency slack $\to b$ ($b$-sufficient, $\sophset_b$, $\sophx_b$).
6. **$h$ / $H$** — Ex's $h(1/3)$ vs Shannon $H$ vs histories $h_t$ vs Ex's $H$ (number of 1-labels, Prop 3.7) and $H_n,T_n$ (heads, tails) vs St's $H_G$. *Decision:* $H(\cdot)$ is entropy (binary entropy for a number); $h_t$ histories; Ex's $h(1/3)\to H(1/3)$; Ex's counts of 1-labels and 0-labels $\to N^1_n,N^0_n$ (so $UB_n=\tau_n\log3-N^0_n$); St's $H_G$ (entropy of the G-context law) stays local. Hellinger $\mathrm H^2\to\Hel$.
7. **$n$, $N$, $d$** — see §1. F's "$n$-bit inputs" and Ex's bit length $n$ become $d$; Ex's $N=2^n$ becomes $N=2^d$; St's $N$ (samples) becomes $n$ and St's $n=2^d$ becomes $N$; St's $n_N\to d_n$. Co's $N=|B|$ (Props 2.9, 2.10, Thm 3.5) is written $|B|$. **Writers must apply this swap with care in St §2–§3**; every displayed formula of St that contains $N$ or $n$ changes.
8. **$S$** — Co's time-bounded mixture and per-query mixture, Hi's normaliser $S_t$, St's error rule and set models, Ex's domain $S$ of a data set (Prop 3.7), Hi's input set $S$ (Prop 4.5). *Decision:* time-bounded mixtures $\to\Mlen,\Mrd$; per-query mixture $\to\Mpq$; normaliser $\to\Znorm$; St's error rule stays $S$ (Paper 2, `sec:teacher`, `sec:limits`); St's set models $\to A$ (`sec:algstat`); Ex's and Hi's local uses of $S$ for a finite set of inputs may stay local in `sec:ex` and `sec:hist`.
9. **$\sigma$** — F's shared-coin law (Prop 4.5), Co's novelty $\sigma_k$, Hi's orders, St's guard schema $\sigma$ (Prop 2.13), St's shared-coin law (Prop 1.7(iii)). *Decision:* shared coin per length $\to\nulen$ (both papers); novelty $\to\sep_k$; orders are $\sigma,\sigma'$ (`sec:hist`, local); St's schema $\sigma$ stays local to `sec:limits`.
10. **$\pi$ / $\mu$** — F and Co write $\pi$ for the input distribution, Hi writes $\pi$ for a computable random function, St writes $\pi$ for programs and for the input law (Props 2.13, 2.15), Hi and Ex write $\mu$ for the joint law of the data process, St Prop 3.3 writes $\mu$ for the SI measure. *Decision:* $\mu$ = input distribution (both papers); $\Prob$ = true joint law of the data process; Hi's computable random function $\pi\to\nu$ (with $K(\nu)$); $\pi$ = program in Paper 2 only; St's input-law $\pi\to\mu$ (Prop 2.13: $\pi_G,\pi_{\neg G}\to\mu(G),\mu(\neg G)$; Prop 2.15); St Prop 3.3's $\mu\to\nu$ and its posterior $\pi(\mu\mid z)\to\Pi_1(\nu\mid z)$; St Thm 1(d)'s computable law $\mu$ of the interleaved string $\to\Prob$ (with program $\pi_{\Prob}$).
11. **$\xi$** — F's trimming universal chronological semimeasure, Hi's $\xi:=M_H$, Hutter's $\xi$, St's $\xi_\lambda,\xi_\times,\xi_{\mathcal C}$, St Prop 3.3's Solomonoff mixture. *Decision:* Paper 1 uses no bare $\xi$: the universal chronological semimeasure is $\MH$, defined as the law of \SFIhist{} (Hi §4.1); F's trimming construction is mentioned as an alternative construction equal to $\MH$ up to constants; "agrees with Hutter's $\xi$" is stated as known but unverified. Paper 2 keeps $\xi_\lambda,\xi^\times_\lambda,\xi^F_\lambda,\xi_{\mathcal C}$ for steeper mixtures and writes $M$ for the Solomonoff mixture of St Prop 3.3. Hi's $\xi'$ $\to\MHin$; $L_\xi\to\LH$.
12. **$\Delta$** — Hi's reveal law (Hänni's notation), F's Möbius sum $\Delta(D,T)$, St's $\Delta(c),\Delta_\ell,\Delta_G,\Delta_j$. *Decision:* $\Delta$ = reveal law in Paper 1; Möbius sum $\to\Mob_T\nu(D)$; St's $\Delta(c),\Delta_\ell,\Delta_G,\Delta_j$ stay local to Paper 2 (no reveal laws there).
13. **$L$** — losses $L_\nu$ vs Hi's cumulative block length $L_k$ vs St's $L_\lambda$ (length bound), $L_S,L_E$ (rule lengths), F's $L_{1/2}(\nu,D)$ (tape length). *Decision:* $L$ with a law or predictor subscript is a loss. Hi's $L_k\to\bar\ell_k:=\sum_{i\le k}\ell_i$; St's $L_\lambda\to\ell^*_\lambda$; $L_S,L_E$ and $L_{1/2}(\nu,D)$ stay (lengths, local to `sec:teacher`/`sec:algstat` and `sec:versions`).
14. **$T$** — function machines vs St's level $T(\pi)$ vs Ex's tails count $T_n$. *Decision:* $T$ = function machine; level $\to\lev(\pi)$; tails count $\to N^0_n$.
15. **$\Pi$** — St's classes $\Pi_\times,\dots$ vs St's posterior $\Pi_\lambda$ and $\Pi^\eta$ vs St's sets $\Pi_\lambda$ (short programs, Thm 1 proof) and $\Pi_{\rm fin}$. *Decision:* classes $\to\mathcal H$ (§3.3); posteriors keep $\Pi_\lambda,\Pi^\eta$; the proof's sets $\to\mathcal H_{\le\ell^*_\lambda},\mathcal H_{\rm fin}$.
16. **$M_1,M_2$** (St Thm 2) vs Solomonoff's $M$. *Decision:* $\to\Phi_1(c),\Phi_2(c)$ (they are lower bounds on $\Phi(c)$).
17. **$\eta$** — St's tempered exponent, near-optimality slack, guard noise rate; Ex's heads frontier $\eta_n$. *Decision:* $\eta=1/\lambda$ tempered exponent (Paper 2); slack $\to\epsilon$ (so Cor 2.7 reads "with $\epsilon=\epsilon_n$", $\epsilon_n$ the excess of Lemma 2.6); guard noise rate $\to\epsilon_G$; Ex's $\eta_n$ stays local to `sec:ex`.
18. **$\delta$** — confidence (St Lemma 2.6, Co) vs deficiencies $\delta_S,\delta_E,\delta_2$ vs Hi's deterministic policy $\delta$. *Decision:* bare $\delta$ = confidence parameter; subscripted $\delta_S,\delta_E,\delta_2$ and $\delta^*$ = randomness deficiencies (Paper 2); Hi's deterministic reveal policy keeps the letter $\delta$, but only inside `sec:hist`, where no confidence parameter appears. Never use both meanings in one statement.
19. **$W$** — program mixture (F, Co) vs Co's circuit mixture vs St's $W_{\rm det}$. *Decision:* $W$ = program mixture; circuit mixture $\to\Wcirc$; St's $\Wdet$ (deterministic fill-ins inside a product class) is a different object and is never called $W$.
20. **$c(f)$, $K_B$, $C(P)$** — Co's circuit size $c(f)$ $\to\csize(f)$; Co's old $K_B(f)\to\KF(f|_B)$; Hänni's plain complexities $C(P),C(Q)$ in the draft $\to$ prefix complexities $K(P,Q)$ (state that the draft wrote $C$).
21. **$p$** — programs (Paper 1), Co's time bound $p(\cdot)$, St's error density. *Decision:* time bound $\to t(\cdot)$; Co's clock $t_k(x)\to\tau_k(x)$ (local to `sec:comp`); error density $p$ (Paper 2 only).
22. **$\lambda_y$** (Co Prop 2.14, a data set) $\to D^*_y$.
23. **$B$** — Co's input set $B$ and weight-ratio function $B(s)$; St's truncation level $B$ and $B_S$. *Decision:* Co's $B(s)\to\Gamma(s)$ (local to `sec:comp`); $B$ as a finite input set stays local in `sec:learn`, `sec:ood`, `sec:comp`; St's $B$ (truncation) and $B_S$ stay in Paper 2.
24. **$R$** — risk (F Thm 6.7, St) vs Hi's private memory $R$ (Lemma 3.0). *Decision:* $R$ = risk; Hi's private memory $\to\Gamma$ (local to `sec:hist`).
25. **$U$** — Hi writes $U$ for the conditional universal prefix machine (Thm 5.2) and $U^\omega$ for the universal function machine's output (Thm 5.4); St's $U$ is the universal member of a class. *Decision:* Paper 1: $V(\cdot,x)$ and $f_\omega$ (with $T_U$, $T_U^H$ for the universal machines); $U$ only in Paper 2 and in Paper 1's summary of it.
26. **Hypotheses (H1),(H2)** of Hi Thm 3.8 clash with the brief's H1–H10. *Decision:* $\to$ (A1),(A2). The brief's items are cited as H1–H10 only in CLAIMS.md and in the verification appendix, never inside theorem statements.
27. **$\theta$, $\Theta$** — Hi's reveal-law index $\Theta$ (Prop 3.10); St's persona index set $\Theta$ (Prop 4.1), levels $\theta_t$ and envelope density $\theta$. All local; no clash across papers in practice.
28. **$e$** — Co's errors $e_k,e^{\rm wr},e_{\rm norm},e_{\rm LOO}$ (Paper 1, `sec:ood`, `sec:learn`) and St's error-label probability $e(\pi),e_1(\pi)$ (Paper 2). Local; keep.
29. **$\nu$** in St Prop 1.7(iii) ($\sigma$) $\to\nulen$, as in item 9.
30. **$g$** — Ex's smallest unrevealed index, Co's clock factor, St's Hoeffding grid index and $\pi_g$. Local; keep.

---

## 5. Local symbols by section

Letters below may be used inside the named section (and its appendix) only, defined there. If a local symbol must be cited elsewhere, restate its definition.

**Paper 1**
* `setting`: $E$ (an extension of $D$), $q$ (predictor), $P$ (law of a random partial function), $F$ (random partial function), $A_t$ events, $I(s)$ dyadic sets (Lemma 3.1), $\phi_i$ enumerations, $j(x)$ length-lexicographic index, $\alpha,\beta$ encodings, $E_{\vec\imath}$ block data sets.
* `versions`: $\ell_n:=\lceil\log(d/\log3)\rceil-1$ (F's $\ell_n$ with $n\to d$), $E_\ell$ program sets, $L_{1/2}(\nu,D)$ (tape length), $\nu^{(L)}$, $N_{\rm cov}$ (F Prop 4.9's family size), $\rho_K(d)$ (F Cor 4.8), $s,d'$ padding.
* `learn`: $Q_t,\bar Q_n,q_t,\bar q_n$ predictors, $R$, $d_t$ (one-step KL, F Thm 6.5), $\tilde x_t$ stamped inputs, $B$ finite input set, $e_{\rm LOO}$, $\alpha,p_{\max}$ (F Prop 6.8), $w$ (prior weight, F Prop 6.10), $r_t$.
* `hist`: $\Delta$, $P$, $\Gamma$ (private memory), $\Theta$, $A_n$ and $K(A)$, $C_{\rm dir}$, $\ell_i,\bar\ell_k$, $s_\ell$, $\sigma,\sigma'$ (orders), $\delta$ (deterministic policy), $q$ and $D_{abr}$ (GF example), $N(G)$, $\chi_u$, $u_j,v_j$ (Prop 4.5′), $e(n)$ and $e^*(n)$ (Prop 4.10(d)).
* `ex`: $f$ (cyclic permutation), $x_0=0^d$, $(N-1)_{k}$ falling factorial, $A_k(F)$ depth sets, $b$ (coin sequence), $\tau_n,\eta_n$ (tail and heads frontiers), $g_n$ (smallest unrevealed index), $UB_n$, $N^1_n,N^0_n$, $P^*$, $N_{\rm touch}$, $E_{\rm rule}$, $\vartheta$, $\sigma^2$ (variance constant $1.0496602$), $r$ (constant in the exact law), $p_T$ (proof-search program), $g$ (computable target in positive examples), $\varepsilon$ (frozen noise rate).
* `ood`: $Q$, $b$, $K(Q,b)$, $S$ (finite test set), $E=b|_S$, $e_k,e^{\rm wr},e_{\rm norm}$, $A$ (training inputs), $x^*$, $D^*_y$, $P$ (property of pairs, Co Thm 2.5), $q,r$ (indices, Co Prop 2.3).
* `comp`: $A_i$ (RAM programs), $w_i$, $n_i$ (activation lengths), $k_i$ (activation rounds), $g$ (clock factor), $\tau_k(x)$ (clock), $u$ (uniform vector), $N_s$, $\Gamma(s)$, $L_B,L_{\rm circ}$, $\mathcal E$ (expected Gibbs mistakes), $h$ (hypotheses in the ladder), $V_h$, $\ell(f)$.
* `nn`: $\Theta,\theta,f_\theta$ (architecture), $P_A$, $a$ (program lower-semicomputing $P_A$), $\Psi$, $\chi_S$ (Walsh characters), $\kappa_N$, $C$, $C_L$ (slides' notation, quoted).

**Paper 2**
* `setup`: $o$ (observation), $\mathcal O$, $A$ (hull point set, St Lemma 1.2; rename to $\mathcal A$ to avoid the set-model $A$ of `sec:algstat`), $C$ (convex hull), $s_\pm$.
* `absorb`: $t$ (deterministic teacher), $\pi_t,\ell_t$, $F$ (finite function set), $Q$, $Q_x$, $\beta\in\{0,1\}^k$ (shared coins), $D_\beta$, $a_j,b_j$, $s_j,q_j,R(\beta)$ (proof of Prop 1.7; write $\tilde R$ to avoid the risk $R$), $\nu_\theta,w_\theta,Z_i,h_w$ (Prop 4.1).
* `teacher`: Setting 2.0 symbols ($a,f_a,S,E,y^*,r,s_0,L_S,B_S,\delta_S,I(\pi),R,R_B,B,\tau_B,\beta_B,u,\theta_t,\lev,s(t),G_j,\kappa_g,\kappa_b,\Lambda_1,\Lambda_2,\Lambda_3,\psi_c,t^*,J_g,J_b,\Delta(c),\Delta_\ell,c_{\rm hi},e(\pi),\gamma_g,j_g,\Gamma_g$), $\epsilon_1,\epsilon_n,\hat L$ (Lemma 2.6), $L_E,B_E,\delta_E$ (full table).
* `limits`: $H:=H(2^{-r})$, $q$, $a,b,F(d),d_0(\kappa)$ (Lemma 2.11a), $X_j,k_j,r_j,\Delta_j$ (separable components), $\sigma,G,n_{\rm st}$ (number of possible steps; St's $M$), $\epsilon_G$, $H_G,g,\rho_\sigma,\rho_G,\Delta_G$, $S_1,S_2,s_1,s_2,p_1,p_2,E_1,\pi_e,R_e,\kappa_e,J_e,\zeta,c_{\rm env},B_2,\delta_2,e_1,\bar R_1$.
* `split`: $\nu$ (sampler), $k$ (its program length), $\pi_\nu$, $\delta^*$, $Z_n$ (supermartingale), $r$ (dyadic resolution), $\sigma(x,b)$, $q$ (field degree), $h_s$, $p_s$, $j(x)$, $\langle a,b\rangle$, $F_h$, $q_{i,h}$, $\varphi_w$, $\beta_D,i_D,t_D$, $\Lambda_n$ (likelihood ratio in Thm 4's proof).
* `algstat`: $z$ (string), $A$ (set model), $h_z$, $\rho^\times_D$, $A_0,A_u$ (set models of Prop 3.8; St's $S_0,S_u$), $F_t$, $\gamma_d$.

---

## 6. Losses and the two conventions (both papers)

* For a weak semimeasure $\nu$ and a data set $D$: $L_\nu(D):=-\log\nu(D)$. The loss of $\MF$ is $\LSFI(D):=L_{\MF}(D)$. In any reveal order the cumulative log loss of $\nu$'s predictor is $L_\nu(D_n)+\log\nu(\emptyset)\le L_\nu(D_n)$ (semimeasure convention; `prop:setting:order`).
* Normalised convention: $\MFbar(y\mid D,x):=\MF(D+(x,y))/\Znorm(D,x)$ and $\LSFIbar$ along a given order. $\LSFIbar\le\LSFI$ (`prop:setting:normalise`).
* History-aware losses: $L_\rho(y_{1:n}\Vert x_{1:n}):=-\log\rho(y_{1:n}\Vert x_{1:n})$; $L_P$ for a predictor; $\LH$ for $\MH$.
* SI losses on $\code(h_n)$: $\LMjoint=\LMx+\LMy$.
* Every lower bound carries the words "semimeasure convention" or "both conventions" in its statement.

---

## 7. Status and provenance markers (both papers)

* Every theorem-like environment (theorem, proposition, lemma, corollary, conjecture, and example or remark that asserts something) gets `\status{...}` with one of: `proved`, `computed`, `conjecture`, `known`, `proof sketch`, `refuted`, combinations such as `proved; computed`, and `known; unverified`. Definitions get `\src{...}` only.
* Every such environment gets `\src{<track> <item>}` in the FINAL numbering, e.g. `\src{foundations Thm 4.7}`, `\src{history Cor 3.9}`, `\src{steeper Thm 2}`, `\src{context Prop 2.16}`, `\src{examples Prop 2.9}`, `\src{slides, App.\ K}`, `\src{Hänni notes}`.
* Claims of the Vaintrob–Hänni slides: `\status{known; unverified (claimed in the slides)}`.
* Refuted claims are stated as refuted, with the counterexample, never silently dropped: `\status{refuted}`.
* Open problems are not theorem environments. Write `\paragraph{Open question.}` in prose; the ledger lists them with status `open` and ids `q:<key>:<name>`.
* Heuristics are not in theorem environments; say "heuristic, not proved".
* "known" requires a citation; if the content was not checked against the source, write `known; unverified` and hedge in the text.

## 8. Labels

* Sections `sec:<key>`; subsections `sec:<key>:<name>`; appendices `app:<key>`; theorem-like items `thm:`, `prop:`, `lem:`, `cor:`, `def:`, `ex:`, `rem:`, `conj:` followed by `<key>:<name>`; tables `tab:<key>:<name>`; figures `fig:<key>:<name>`; equations `eq:<key>:<name>`. Open questions `q:<key>:<name>` (on the `\paragraph`, via `\label` after it).
* The ids in `CLAIMS.md` are the labels. Use them exactly.
* Keys: Paper 1 `intro, setting, versions, learn, hist, ex, ood, comp, nn, steep, related, discussion, verification`; Paper 2 `intro, setup, absorb, teacher, limits, split, algstat, related, discussion, verification`.
* Cross-paper references are by citation and result name, never by `\ref`: "\citet[Theorem~\emph{absorption}]{claudeSFI2026steeper}" or "the absorption theorem of \citet{claudeSFI2026steeper}". The framing editor may add theorem numbers after both builds.

---

## 9. Bibliography

### 9.1 Keys in `bib/core.bib` (both papers; identical)

`hanni2026notes` (Hänni's public notes, including the SFI drafts and the grokking note), `hanni2026request` (his request of 2026-10-11, with Sam Eisenstat's example and the e-mail argument), `hanni2026lesswrong` (the LessWrong thread with Cole Wyeth's objection; undated; text as pasted by Hänni), `vaintrobhanni2026nnbayes` (the slides), `claudeSFI2026fundamentals` (Paper 1), `claudeSFI2026steeper` (Paper 2), `claude2026whatfollows` (the earlier report; T5 is its section "Simplicity and normativity from imitation"), and verified standard references copied from the sibling projects: `li2008introduction`, `hoeffding1963probability`, `sion1958general`, `barron1991minimum`, `gacs2001algorithmic`, `vereshchagin2004kolmogorov`, `vereshchagin2010rate`, `vereshchagin2017algorithmic`, `grunwald2007minimum`, `gneiting2007strictly`, `grunwald2012safe`, `grunwald2017inconsistency`, `zhang2006epsilon`, `bissiri2016general`, `bhattacharya2019fractional`, `littlestone1988learning`, `gold1967language`, `ville1939etude`, `barzdin1972prediction`, `vovk2005algorithmic`.

### 9.2 Canonical keys for other references (add to `bib/<section>.bib`; check `core.bib` and the other section files first)

Use these keys so that two sections never create two entries for one work. Every entry not checked against its source carries `% unverified: <what was checked, e.g. search snippet>` and the text hedges the claim.

* Solomonoff: `solomonoff1964formalI`, `solomonoff1964formalII` (Inform. Control 7), `solomonoff1978complexity` (IEEE IT 24(4):422–432), `solomonoff2008three` (Comput. J. 51(5):566–570, doi 10.1093/comjnl/bxm120), `solomonoff1999two`, `solomonoff2003progress`.
* Coding theorem and AIT: `zvonkin1970complexity`, `levin1974laws`, `gacs1974symmetry`, `chaitin1975theory`, `gacs1983relation`, `day2011increasing`, `levin2016occam`, `epstein2011sets`, `koppel1987complexity`, `koppel1991almost`, `vitanyi2006meaningful`, `antunes2009sophistication`, `milovanov2016algorithmic`.
* Hutter and coauthors: `hutter2000theory` (arXiv cs/0004001), `hutter2005universal` (book), `hutter2007aixi` (AGI chapter, arXiv cs/0701125; do not confuse with the existing `hutter2007universal`, TCS 384), `lattimore2011universal` (LHG, ALT 2011, LNAI 6925:262–276), `lattimore2013nofree`, `wood2013non` (Wood–Sunehag–Hutter), `poland2005asymptotics`, `poland2005strong`, `leike2015bad` (COLT 2015, PMLR 40:1244–1259), `leike2015computability` (ALT 2015; do not use `leike2015solomonoff`, which is the Nicod paper), `filan2016loss`, `orseau2013universal`.
* Operator induction: `solomonoff1999two` (the term), `solomonoff2008three` (the problem, solutions (9) and (10), convergence theorem (12)); both read in full. Secondary (dropped from the bibliographies): `ozkural2015ultimate`, `ozkural2017ultimate`.
* Learning theory: `blumer1987occam`, `mcallester1999some`, `haussler1994bounds`, `haussler1994predicting`, `littlestone1989online`, `cesabianchi2004generalization`, `cesabianchi2006prediction`, `vovk1990aggregating`, `vovk1992universal`, `ryabko2006pattern`, `case1983comparison`, `chater2007ideal`, `kakutani1948equivalence`, `cover2006elements`, `kleitman1973families`, `strassen1965existence`.
* λ-MDL and posteriors: `grunwald2007suboptimal` (Grünwald–Langford, Machine Learning 66:119–149), `zhu2025quantifying` (COLT 2025, PMLR 291:6124–6155), `zhu2026overfitting` (arXiv 2603.22644), `wenzel2020good`.
* Complexity and speed: `impagliazzo1990no`, `schmidhuber2002speed`.
* NN and kernels: `valle2019deep`, `mingard2021sgd`, `dingle2018input`, `goldblum2023no`, `grau2024learning`, `buzaglo2024`, `basri2019convergence`, `bietti2019inductive`, `yang2019fine`, `kamath2020approximate`, `donhauser2021rotational`, `vaintrob2026width` (arXiv 2607.05735, snippet only).

---

## 10. Macros (the "SFI macros" block, identical in both preambles)

| macro | renders | use |
|---|---|---|
| `\dom`, `\supp` | dom, supp | operators |
| `\ind` | **1** | indicator, `\ind[x\in E]` or `\ind_E` |
| `\Ybot` | $Y_\bot$ | |
| `\code` | code | `\code(h_n)` |
| `\Unif`, `\Prob`, `\Ex` | $\mathbb U,\mathbb P,\mathbb E$ | tape measure; true law; expectation |
| `\Var`, `\Bern`, `\KL`, `\Hel` | Var, Bern, KL, $d_{\rm H}^2$ | |
| `\mm` | $\mathbf m$ | universal discrete semimeasure |
| `\Kpad`, `\Ktail`, `\Omtail{\ell}` | $K^{\rm pad}$, $K^{\rm tail}$, $\Omega_V^{\ge\ell}$ | |
| `\KP`, `\Kpred`, `\KF`, `\Khist` | $K^{\mathcal P}$, $K^{\rm pred}$, $K_F$, $K_{\rm hist}$ | |
| `\sep` | sep | `\sep_k` |
| `\MF`, `\MFbar`, `\Mw`, `\Mprod`, `\Mpq`, `\MH`, `\MHin` | $M_F,\bar M_F,M^w,M_{\rm prod},M_{\rm pq},M_H,M_H^{\rm in}$ | |
| `\Mcount`, `\Mset`, `\Mpairs`, `\Mnorm` | $M_{\rm count},M_{\rm set},M_{\rm pairs},M_{\rm norm}$ | |
| `\Wdet`, `\Whist`, `\Wcirc` | $W_{\rm det},W_{\rm hist},W_{\rm circ}$ | |
| `\Mlen`, `\Mrd` | $M_{\rm len},M_{\rm rd}$ | |
| `\nulen`, `\nutri` | $\nu_{\rm len},\nu_\triangle$ | |
| `\Znorm`, `\Mob` | $\mathcal Z$, $\nabla$ | `\Znorm(D,x)`, `\Mob_T\nu(D)` |
| `\Hcl{\times}` etc. | $\mathcal H_\times$ | Paper 2 classes |
| `\LSFI`, `\LSFIbar`, `\LH`, `\LMjoint`, `\LMx`, `\LMy` | $L_{\rm SOI},\bar L_{\rm SOI},L_H,L_M^{\rm joint},L_M^x,L_M^y$ | |
| `\SFIhist`, `\SFIset`, `\SFIcount`, `\SFIpairs` | SOI$^{\rm hist}$ etc. | write `\SFIhist{}` in running text |
| `\csize`, `\lev`, `\soph`, `\sophset`, `\sophx` | size, lev, soph, soph$^{\rm set}$, soph$^\times$ | |

Plain letters ($W$, $M$, $K$, $\nu$, $\rho$, $\Delta$, $\lambda$, $\kappa$, $\pi$, $\mu$) have no macro; their meanings are fixed in §3.
