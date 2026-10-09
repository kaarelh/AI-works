# Notation and conventions (binding for all section writers)

One notation for the whole paper. The four tracks use different names for the same objects, and the same name for different objects; §§3–9 map each track's names to the paper's, and §10 lists the renamings forced by clashes. Macros are in `preamble.tex`: the inherited block (from `../axiom-schemas/paper/preamble.tex`) and the block "axiom-induction macros" (§12 here). Do not redefine either.

## 1. General conventions

* **Logarithms and units.** Write `\ln` for nats and `\log_2` for bits; never a bare `\log`. Every code length, KL divergence and log-odds carries its unit. Model and universal report nats; pa and experiments report bits. Convert only when comparing, and say so.
* **Status and source.** Every theorem-like environment: `\status{...}` with values from {proved, computed, conjecture, known, proof sketch, refuted}, combined with ";" and part labels when parts differ (e.g. `\status{(a), (b) proved; (c) conjecture}`). Then `\src{track item}`: `\src{model Thm 4.1}`, `\src{universal Prop U11}`, `\src{universal Thm B}`, `\src{pa Prop 2.3}`, `\src{experiments Prop X8(c)}`, `\src{experiments E2}`. Definitions: `\src` only. pa's "proved (checked)" is written `\status{proved; computed}` (derivation checked by the track's checker `nd.py`). An editor's one-line reconciliation of two track results is `\src{editor, from <items>}` (only where `CLAIMS.md` allows it).
* **Earlier reports.** "AS" = \citet{claude2026axiomschemas}, cited by its own numbering (AS Thm 2.5, AS §4.5, AS Prop E.16, …; see `OUTLINE.md`). "IL" = \citet{claude2026whatfollows} (IL Thm 4.15, Lemma C.4, Prop C.5).
* **Labels.** `<env>:<key>:<name>`, key ∈ {intro, model, univ, ident, sound, time, pa, exp, disc, ver}. The ids in `CLAIMS.md` are the labels.
* **Named variables in text.** The theory uses de Bruijn indices (AS §2.1); the text writes named bound variables.

## 2. Syntax, templates, instances (inherited from AS; macros already in the preamble)

* Languages: arithmetic $L_A=\{0,S,+,\cdot,<,=\}$ (experiments' language has $<$ with no $\Q$ axiom about it); set theory $L_\in$. Sentences are in closure-normal form: free names are **parameters** $p, p_1, p_2,\dots$, read under universal closure; leading $\forall$ are not stripped. $\mathcal S$ = the set of sentences.
* Templates $\tau,\sigma$ with metavariable occurrences $M(t_1,\dots,t_n)$, arguments metavariable-free. Term metavariables lowercase ($z$ for 0-ary, $f,g$), formula metavariables capital ($P, F$). Classes $\FO\subseteq\PAT\subseteq\DT\subseteq\SO$; $\DTF$ (implemented class). A *ground* template is a sentence.
* $\inst(\tau)$; $\bigcup\inst(T):=\bigcup_{\tau\in T}\inst(\tau)$; $\instc$, $\insto$; generality $\gen$; matching is unique and linear in $\DT$ (AS Thm 2.5).
* **Guards** (experiments, universal): a metavariable may carry a *closed* guard (its body contains no parameter) or an *open* guard (it may). Default: closed. Write "with an open guard" in prose, or a superscript $^{\mathrm{open}}$ on the theory name ($S_{ab}^{\mathrm{open}}$).
* Experiments' code notation `?t`, `?z`, `?P`, `?a` is written $z$, $z'$, $P$, $a$ in the paper.
* **Instance schema** of a formula $\varphi(x)$: $\sigma_\varphi:=\varphi[z/x]$ ($z$ a 0-ary term metavariable). $\Ic(\varphi)$ = closed instances $\{\varphi(t): t \text{ closed}\}$; $\Io(\varphi)$ = instances whose terms may contain parameters.
* $\Q$ = Robinson arithmetic (sans serif, `\Q`). Numbering, the same in all four tracks and in AS §2: Q1 $\forall x\,\neg Sx=0$; Q2 $\forall x\forall y(Sx=Sy\to x=y)$; Q3 $\forall x(\neg x=0\to\exists y\,x=Sy)$ (pa writes $x=0\vee\exists y\,x=Sy$; equivalent); Q4 $\forall x\,(x+0=x)$; Q5 $\forall x\forall y\,(x+Sy=S(x+y))$; Q6 $\forall x\,(x\cdot 0=0)$; Q7 $\forall x\forall y\,(x\cdot Sy=x\cdot y+x)$. pa adds $\Dlt:=\forall u\forall v(u<v\leftrightarrow\exists z(u+Sz=v))$. $\TInd = (P(0)\wedge\forall x(P(x)\to P(Sx)))\to\forall x P(x)$.

## 3. Global symbols, with each track's names

| symbol (macro) | meaning | defined in | model | universal | pa | experiments |
|---|---|---|---|---|---|---|
| $\Hclass$ (`\Hclass`) | countable class of theories | `def:model:theory` | **H** | H | candidate set | pool $R_n$, family $F$ |
| $T$, $T^*$ | theory = finite set of $\DT$ templates; the truth | `def:model:theory` | $T$, $T^*$ | $T$, $T^*$ | $T$, $H_{\mathrm{true}}$ | $T$, $T^*$ |
| $(T,w)$, $w_\tau$, $w^*$ | weighted theory; weights; true weights | `def:model:theory` | same | $w$, $\theta$, $v_j$, $u$ | $w$ | $w_i$ |
| $K$ | number of templates of $T^*$, or of root productions of a split | `lem:sound:regret`, `prop:ident:splitlzero` | $K$ | — | — | $m$ |
| $\alpha$, $\alpha_\tau$, $A$ | Dirichlet parameter(s), default $\tfrac12$; $A=\sum_\tau\alpha_\tau$ | `def:model:prior` | same | $\alpha=\tfrac12$ (c8–c10), $\alpha=1$ Laplace (c2–c7) | $\tfrac12$ (KT) | $\tfrac12$ |
| $\Dir$, $\PDir{T}$ (`\Dir`, `\PDir`) | Dirichlet law; Dirichlet-integrated marginal law of $T$ | `def:model:lzero` | $P^{\mathrm{Dir}}_T$ | "marginal" | KT marginal | $M_T$ |
| $\DirMult$, $\KT$ | Dirichlet-multinomial; KT code length $-\log_2$ of a Dirichlet(½) marginal | `lem:model:dirsum` | DirMult | Lap, DirMult | KT$(k;A)$ | DirMom |
| $\Qg$ (`\Qg`) | instantiation grammar (PCFG on metavariable bodies) | `def:model:grammar` | $Q$ | $Q$ (term law) | $Q$ (KT grammar) | `Grammar`, $Q$ |
| $\Qg_\tau$ | law of $\tau\theta$ with $\theta\sim\Qg$ | `lem:model:grammar` | $Q_\tau$ | $P_A$ | — | $a_i(d)$ (L0 coefficient) |
| $p_f$ | root probability of production $f$ under $\Qg$ | `def:model:grammar` | $p_r$ | $p_f$ | $Q(f)$ | $q_f$ |
| $\Qnum$ (`\Qnum`) | numeral law $\Qnum(S^j0)=(1-q)q^j$, default $q=\tfrac12$ | `def:univ:setup` | — | $Q_c$ | — | $Q_{\mathrm{num}}$ ($q=\tfrac12$) |
| $\QGW$, $\Qopen$, $\Qelim$ | Galton–Watson term law (0 .4, S .3, + .2, · .1); $\rho[p]+(1-\rho)\Qnum$; experiments' elimination-term law | `def:univ:setup`, `def:model:calculi` | — | GW, $Q_{\mathrm{open}}$ | — | Qe |
| $\theta$ | substitution (bodies for metavariables) | AS Def 2.2 | $\theta$ | $\theta$ | $\theta$ | $\theta_d$ |
| $P_{T,w}$ | law of a weighted theory (fixed weights) | `def:model:lzero` | $P_{T,w}$ | $P_T$ | $P_T$ | $P(d\mid T,w)$ |
| $\mu_T$, $Z_T$ | unnormalised derivation mass of a conclusion; total mass | `def:model:lone` | $\mu_T$, $Z_T$ | $P_T$ under "L1(c)", $Z_T$ | — | — (proper chain, $Z=1$) |
| $P_T$ | the theory's data law ($=\mu_T/Z_T$ for derivation likelihoods) | `def:model:lone` | $P_T$ | $P_T/Z_T$ ("L1-norm") | $P_T$ | $P^{L1}(d\mid T,w)$ |
| $\pi$, $\pi_\lambda$ | prior; prefix-code prior | `def:model:prior` | $\pi_\lambda$ | $\pi$ | $\pi\propto 2^{-\beta\lvert T\rvert }$ | $2^{-\lambda\,\mathrm{bits}(T)}(1+\lvert T\rvert )^{-\tau}$ |
| $\ell(T)$ | prior code length of $T$ in bits (template code) | `def:model:prior` | $\ell(T)$ | $\sum_A\lvert A\rvert $ + 1 per axiom | $\beta\sum_\tau\lvert \tau\rvert $ | bits$(T)$ |
| $D_n=(X_1,\dots,X_n)$ | data; $s$ a generic sentence | `def:ident:W` | $D$, $X_i$ | $D_n$, $d_i$ | $D$, $\theta_i$ | $D_n$, $d_j$ |
| $\pi_n$ | posterior $\pi(\cdot\mid D_n)$ | `def:ident:W` | $\pi_n$ | $\pi_n$ (was $\pi(T\mid D_n)$) | $\pi_n$ | $\pi_n$, $\pi_R$ (pool-restricted) |
| $\pi_t$ | posterior at verifier round $t$, including oracle constraints $c_j(T)$ | `def:sound:protocol` | $\pi_t$ | — | — | — |
| $M(X^n)$, $M_n$ | Bayes mixture $\sum_T\pi(T)P_T(X^n)$; predictive law | `prop:ident:rates` | $M$, $M_n$ | $M(\cdot\mid D_n)$ | $P_{\mathrm{mix}}$ | — |
| $\Cstar$ (`\Cstar`) | generator class $\{T: P_T=P_{T^*}\}$ | `def:ident:W` | $C^*$ | $C^*$ (was $E(T^*)$) | $C^*$ | $C^*$ |
| $C^*_d$, $W^*_d$ | $\{T: P_T=P_{T^*},\ \Th_d(T)=\Th_d(T^*)\}$; its prior mass | `def:sound:protocol` | same | — | — | — |
| $C^{\mathrm{Dir}}_d$ | Dirichlet analogue (equal marginals on every $n$, equal $\Th_d$) | `thm:sound:avg` | $C^{\mathrm{Dir}}_d$ | — | — | — |
| $C^*_\forall$ | members of $\Cstar$ that agree with $T^*$ on $\forall x\varphi$ | `cor:univ:sound` | — | $C^*_\forall$ | — | — |
| $\Th(T)$, $\Th_d(T)$ | $\CK$-theorems of $\bigcup\inst(T)$; those with a derivation of symbol size $\le d$ | `def:model:calculus` | same | $\vdash$ | $\Th_d$, $\vdash_{\le d}$ | — |
| $\Th_{\mathsf C}(T)$, $\vdash_{\mathsf C}$ | theorems in calculus $\mathsf C$ | `def:model:calculi` | — | $\mathrm{Thm}_C(T)$, $\vdash_C$ | — | — |
| $\vdash_J$ | derivable by a chain of $\le J$ steps in $\Cch{J}$ | `def:model:calculi` | — | — | — | $\vdash_K$ |
| $\Ver{\delta}{d}$ (`\Ver`) | thresholded verifier: accept $q$ iff $\pi_t(\{T: q\notin\Th_d(T)\})\le\delta$ | `def:sound:protocol` | $V_{\delta,d}$ | "verifier" (on $\Belc$) | $V_{\delta,d}$ | $V_{\delta,K}$ → $V_{\delta,J}$ |
| $\delta$, $\delta'$, $\delta_n$ | threshold; Ville confidence level; shrinking threshold | `thm:sound:fixed`, `thm:sound:shrink` | same | $\delta$ | $\delta$ | same |
| $\Rreg(n,K)$ (`\Rreg`) | regret factor $\min_c \Ex_{\Dir(\alpha)}[\prod w^{c}]/\prod(c/n)^{c}$ | `lem:sound:regret` | $R_\alpha(n,K)$ | — | — | $R(n,m)$ |
| $\Bel,\Dis,\Indep,\Inc,\Pl$; $\Belc$ | posterior mass of provers of $s$, of $\neg s$, of neither, of inconsistent theories; $1-\Dis$; mass of consistent provers | `def:sound:tri` | Bel, Dis, **Ind**, Inc, Pl | Bel, Dis, **Ind**, Inc, $\mathrm{Bel}_{\mathrm{cons}}$ | — | — |
| $\Sprove,\Snc,\Sg$ | Hänni's 0/1 scores and the graded score | `def:model:scores` | $S_{\mathrm{prove}}$, $S_{\mathrm{nc}}$, $S_g$ | $S_{\mathrm{prove}}$, $S_{\mathrm{nc},\beta}$ | $S_{\mathrm{prove}}$, $S_{\mathrm{nc}}$, $S_g$, $L_\varepsilon$ | not implemented |
| $g$, $g_\infty$ | grading function of $\Sg$; $g_\infty:=g(\infty)$ | `def:model:scores` | $g$, $\beta$ | $1/\beta$ | — | — |
| $\eta$, $N$ | noise rate and full-support noise law of a noise mixture $P^\eta_T=(1-\eta)P_T+\eta N$ | `def:model:variants` | (channel $P^K_T$, Rem 8.3) | $\eta$, $N$ | $\varepsilon$, $\mu_0$ in $L_\varepsilon$ | — |
| $\KL$, $\TV$, $\Ex$ | Kullback–Leibler divergence; total variation; expectation | — | KL | KL | KL | — |
| $\CL(T;D)$ (`\CL`) | total code length in bits: $-\log_2$ prior $-\log_2$ likelihood (two-part or marginal) | `def:pa:lsch` | — | — | $L(T;D)$ | "code length" |
| $\nu(\pi)$, $\nu_{\min}(s)$ | number of grammar nodes of a tree; least $\nu$ of a tree concluding $s$ | `prop:time:codelength` | same | — | — | — |
| $\lvert \pi\rvert $, $\kappa$ | total symbol size of a tree; rate of the symbol penalty in $\Lsig$ | `def:model:variants` | same | — | $\beta$ per written symbol | — |

## 4. Likelihood names

Typography: likelihood names are sans-serif (`\Lzero` = $\mathsf{L0}$, …) so that they never collide with languages $L_A$, $L_\in$ or Gold's chain $L_1\subsetneq L_2\subsetneq\dots\subsetneq L_\infty$ (italic). The calculus is a subscript when it matters: $\Lone_{\Cmin}$, $\Lone_{\CK}$.

| paper (macro) | definition | model | universal | pa | experiments |
|---|---|---|---|---|---|
| `\Lzero` | citation: $P_{T,w}(s)=\sum_\tau w_\tau\Qg_\tau(s)$; with Dirichlet weights $\PDir{T}$ | L0 | L0-strict | L0 | L0 |
| `\Lcl` | citation in which a universal sentence $\forall\bar x\chi$ is cited through its instances | — | L0-closure | — | — |
| $\mu_T$ (unnormalised) | probability that the derivation grammar succeeds with conclusion $s$ | $\mu_T$ | L1(c) | — | — |
| `\Lone` ($\Lone_{\mathsf C}$) | normalised derivation likelihood $\mu_T/Z_T$ in calculus $\mathsf C$ (default $\CK$) | L1 | L1-norm | L1 (named, never computed) | L1 (forward chain $\Cch{J}$; proper, $Z_T=1$) |
| `\Ltwo` | $\Lone$ with every node at depth $d$ forced to cite | L2 | — | "bounded" | ($\Cch{J}$ is bounded) |
| `\Lsig` | $\Lone$ reweighted by $e^{-\kappa\lvert \pi\rvert }$, renormalised | L1$^\sigma$ | — | — | — |
| `\Lmax` | best single derivation, $\max_\pi\Pr(\pi)$ (two-part, Viterbi) | "two-part", $V_T$ | L1-max (was "L2") | L1-max | — |
| `\Lsch` | pa's computable two-part code over natural-deduction proofs: $\log_2 10$ per rule, $\log_2\lvert T\rvert $ per citation, premise references, $\beta$ bits per **written symbol**; decodable variant is a prefix code. A two-part code of the $\Lsig$ kind, not of plain $\Lone$ | — | — | L1-sch | — |
| `\Lnaive` | $\Lsch$ with every formula written out at each instance | — | — | L1-naive | — |
| `\Lsel` | stream filter: $P_T(s\mid S)=P_T(s)/P_T(S)$ for $s\in S$ | — | L1-sel$(S)$ | — | — |
| `\Lselc` | per-citation rejection: $\sum_i w_i\,a_i(s)/c_i$, $c_i$ = probability that a chain from component $i$ lands in $S$ | — | — | — | L1sel |
| $P^\eta_T$ | noise mixture | (Rem 8.3: channel $P^K_T$) | noisy $P^\eta_T$ | — | — |
| `\Leps` | $(1-\varepsilon)P_T(s)+\varepsilon\mu_0(s)[T\nvdash_k\neg s]$ | — | — | $L_\varepsilon$ | — |
| `\Leq` | equational derivation grammar on closed $\{0,S,+\}$-equations, terms of size $\le N$ | L1-eq | — | — | — |
| $P^g_T$ | Hänni's graded score normalised: $2^{-\kappa\ell_T(s)}/Z_T$, $\ell_T(s)$ = bits of the shortest explicit derivation ($g_\infty=0$) | Rem 1.10 | — | — | — |

`\Lsel` and `\Lselc` agree for one-component theories and differ for mixtures (experiments §1.7; `CLAIMS.md` conflict C2).

## 5. Calculi

| paper (macro) | rules | normalisation | factor $P_{\Hall}/P_{\Hsch}$ per closed instance | used by |
|---|---|---|---|---|
| `\CK` ($\mathsf K$) | Mendelson's K as a tree grammar: cite a theory axiom ($\alpha_{\mathrm{ax}}$), cite a logical axiom A1–A5 or equality ($\alpha_{\mathrm{lg}}$), MP ($\alpha_{\mathrm{MP}}$), Gen ($\alpha_{\mathrm{Gen}}$), ∀E ($\alpha_{\forall\mathrm E}$); $\alpha_r$ = rule total; $m=2\alpha_{\mathrm{MP}}+\alpha_{\mathrm{Gen}}+\alpha_{\forall\mathrm E}$ | $Z_T$; finite a.s. iff $m\le1$ | not computed; instance-only data are misspecified for every hypothesis (universal U10(c3)) | model |
| `\Cmin` | chain from the conclusion: cite ($1-c$) or ∀E ($c$) with $t\sim\Qg$ | $\mu_T$ or $\mu_T/Z_T$ | $c$ unnormalised; $c/(1+c)$ normalised (quantifier-free $\varphi$) | universal |
| `\Copen` | $\Cmin$ + Gen on the parameter ($g$); cite $p_{\mathrm{cite}}=1-c-g$; terms from $\Qopen$ | same | $c(1-\rho)/(1+c)$ against guarded $\Hsch$, normalised | universal |
| $\mathsf C_{\mathrm{U3}}$ (`\CUiii`) | cite, ∀E, and rules whose premises and conclusions are quantifier-free | trees, $\mu_T$ | $\le c$ (Prop U3) | universal |
| `\Cand` | cite ($p_{\mathrm{cite}}$), ∀E ($c$), ∧I ($a$), ∧E ($e$) on all formulas | trees | $>c$ (refuted conjecture), $\le 0.925$ on the computed grid | universal |
| `\Cch{J}` | forward chain: cite a component, then at most $J\in\{1,2\}$ steps (elim, Gen on $p$, MP with a *cited* major premise), stopping with probability $c_{\mathrm{stop}}$ while a rule applies | proper, never fails, no normaliser | $c_{\mathrm{ch}}:=1-c_{\mathrm{stop}}$ ($=\tfrac12$) | experiments |
| `\CND` + `\Lsch` | natural deduction (hyp, ax, tc, →I, ∀E, ∀I, ∃I, ∃E, refl, subst), two-part code | sub-probability (Kraft, decodable variant) | $2^{-\log_2 10}$ per ∀E step under the fixed rule code; see `tab:pa:rulecode` for learned codes | pa |
| (grammar of `\Leq`) | cite, refl, sym, trans, congS, cong+ | normalised (least fixpoint) | — | model Ex 3.6 |

Numerical rates are comparable only within one calculus and one code. The per-datum factor of `\Cch{J}` equals the *unnormalised* $\Cmin$ factor with $c=c_{\mathrm{ch}}$, although $\Cch{J}$ is proper (conflict C1).

## 6. Priors

| paper | definition | track | proper over all theories? | share of $\Hall$ in $\{\Hall,\Hsch\}$ for $\varphi=(0+x=x)$ |
|---|---|---|---|---|
| $\pi_\lambda$ | $2^{-\lambda\ell(T)}/Z_\lambda$; preorder tree code, $\lceil\log_2\rceil$ bits per token, Elias-γ escapes, $\gamma(k)$ + sorted template codes | model Def 1.3 | yes for $\lambda\ge1$ (Lemma 1.4) | 0.333 ($\lambda=1$), 0.200 ($\lambda=2$) |
| $\pi_{\mathrm{exp}}$ | $\propto 2^{-\lambda\,\mathrm{bits}(T)}(1+\lvert T\rvert )^{-\tau}$, stochastic template grammar code; $(1+\lvert T\rvert )^{-\tau}$ = membership-time factor | experiments §1.3 | yes for $\lambda\ge1$ (Kraft, proved for $\lambda=1$); $\lambda=\tfrac12$ only on finite pools | 0.484 (0.269 for $\neg Sx=0$) |
| $\pi_{\mathrm{univ}}$ | $\propto 2^{-\lambda(\sum_A\lvert A\rvert +\#\text{axioms})}$, dtrc symbol count; memorisers: product-Bernoulli over a named universe | universal §1.3, §1.6 | no; finite or summable families only | 0.333 |
| $\pi_\beta$ | $\propto 2^{-\beta\sum_\tau\lvert \tau\rvert }$; $\beta=5$ (dtlib size, u7 code) or $\log_2 23$ (`nd.size`) | pa Def 0.2 | no; finite candidate sets only | 0.030 ($\beta=5$), 0.042 ($\log_2 23$) |

Every theorem about a countable class assumes a proper prior. Every number that is a prior share names its code (`tab:univ:share`).

## 7. Named hypotheses and theories

| paper (macro) | meaning | universal | experiments | pa | model |
|---|---|---|---|---|---|
| $\Hall$ (`\Hall`) | $\{\forall x\varphi\}$ | $H_\forall$ | H_all | $H_\forall$ | — |
| $\Hsch$ (`\Hsch`) | $\{\sigma_\varphi\}$, closed guard | $H_{\mathrm{sch}}$ | H_sch | schema | — |
| $\Hopen$ (`\Hopen`) | $\{\sigma_\varphi\}$, open guard (with Gen proves $\forall x\varphi$) | $H_{\mathrm{open}}$ | H_open | — | — |
| $\Hboth$ (`\Hboth`) | $\{\forall x\varphi,\sigma_\varphi\}$ | $H_{\mathrm{both}}$ | H_∀+sch | — | — |
| $B\oplus_w A$ | add axiom $A$ with weight $w$ to $B$ | same | — | — | — |
| $R_k$ | numeral split $\{\varphi(0),\dots,\varphi(S^{k-1}0),\varphi(S^kz)\}$; say the guard | $R_k$ (unguarded, $\Copen$) | $N_m$ (closed guard) | — | — |
| $\Split_k$ (`\Split`) | sentence-only split $\{\varphi(0),\dots,\varphi(S^{k-1}0),\forall y\varphi(S^ky)\}$ | Split$_k$ | — | — | — |
| Both0 | $\{\varphi(0),\forall x\varphi\}$ | Both0 | — | — | — |
| $C_1$, $C_2$ | nested chains $\{\sigma_\varphi,\varphi(Sz)\}$, $\{\sigma_\varphi,\varphi(Sz),\varphi(SSz)\}$ | — | C_1 (spare_nested), C_2 | — | — |
| $\Mem(D_n)$, $\Mem(E)$ (`\Mem`) | memoriser: ground templates for the distinct data (for a finite set $E$) | $M_F$, $M^u$, $M^l$ | Mem($D_n$) | "memorise instances"; $\Q\cup S$ on theorem data | $T_E$ |
| $\Trim(T,D_n)$, $\SeenQ(D_n)$ | components of $T$ that could have produced a seen datum; $\Trim(T^*,D_n)$ = Q axioms seen + $\TInd$ | — | Trim, SeenQ | — | — |
| $\Tesc$ (`\Tesc`) | escape template $\{z=0\}$ | — | — | — | $T_{\mathrm{esc}}$ |
| $T_f$ | fragment of $\TInd$ with motive root $f$ | root split | $T_f$ | $T_f$ | $\tau_r$ |
| $H_F$, $H_{\mathrm{root}}$, $H_{\mathrm{used}}$ | $\Q$ + fragments for the roots in $F$; all seven; those used | — | frag-complete (9 roots), frag-observed@$b$, frag-atoms ($F=\{=,<\}$) | same | $T'$ |
| $F_0$ | bare formula metavariable (every sentence is an instance) | ?A | bare ?P | $F_0$ | — |
| Q-lumped | $\{\forall x\forall y P(x,y), \forall x P(x), \TInd\}$ | — | Q-lumped | lump $F_0+\TInd$ | — |

## 8. The collapse (§time) and arithmetic (§pa)

| paper (macro) | meaning | source name |
|---|---|---|
| $\AI$, $\FIcons$, $\FIall$; $W_{\AI}$, $W_{\mathrm{FI}}$ | axiom induction requiring proofs; function induction over consistent / all assigners; their weights of compatible hypotheses | model §6.1 (same) |
| $\Gamma_f$, $A_f$, $A^C_f$ | literals an assigner $f$ decides; Hänni's schema $\{\Accf{f}(\gn{\varphi})\to\varphi\}\cup\{\Rejf{f}(\gn{\varphi})\to\neg\varphi\}$; Craig's set of conjunction powers | model $\Gamma_f$, $A_f$, $A^C_f$ |
| $\Accf{f}$, $\Rejf{f}$ (`\Accf`, `\Rejf`) | $\Sigma_1$ formulas "f halts on input $x$ with acc / rej" | model $\mathrm{Acc}_f$, $\mathrm{Rej}_f$ |
| $\Tr_n$, $\rho_{f,n}$ | $\Sigma_n$ partial truth predicate; the reflection sentence | model same |
| $\Prv_T$, $\Refl_T$ | provability predicate of $T$; reflection schema $\{\Prv_T(\gn\varphi)\to\varphi\}$ | pa $\mathrm{Pr}_T$, $\mathrm{Refl}_T$ |
| $\gn{\varphi}$ (`\gn`) | Gödel numeral | ⌜φ⌝ |
| $\ISigma{n}$, $\IOpen$ | fragments of PA | IΣₙ, IOpen |
| $\CVI$, $\LNP$, $\Ind$ | course-of-values induction, least number principle, induction | same |
| $\Sep$, $\ReplJ$, $\ReplS$, $\Coll$, $\EInd$, $\Found$ | inherited macros; pa's SepJ = `\Sep`, ReplJ = `\ReplJ`, ReplK (bounding form, ∃! spelled out) = `\ReplS` | pa §1.4 |
| $\ell_{\mathrm{cite}}$ | bits of a one-line citation under $\Lsch$ | pa $c$ |
| $D_T(s)$, $\beta^*(s)$ | bits of the cheapest library derivation of $s$ from $T$; memorisation threshold $(D_T(s)-\ell_{\mathrm{cite}})/\lvert s\rvert $ | pa $D_T(\theta)$, $\beta^*(\theta)$ |
| $\mathsf R_d$ | refutation rule: likelihood 0 if $T\vdash_{\le d}\neg s'$ for a datum $s'$, or $T\vdash_{\le d} s$ for a negative datum $s$ | pa Def 0.4 ($R_d$) |
| $\ProvAll$ (`\ProvAll`) | the theories of the class that prove $\forall x\varphi$ | universal "Prov" |

## 9. Symbols local to one section (define where used; do not export)

* §model: $h(\cdot)$, $h_{\min}$, $h_{\max}$, $b$, $\rho$ (Def 1.5 weights, branching bound, contraction); $N$ (body size); $\alpha_{\mathrm{ax}},\dots$ (rule probabilities; a roman subscript means a rule, plain $\alpha$ or $\alpha_\tau$ a Dirichlet parameter).
* §univ: $q$ (numeral parameter); $\rho$ (parameter probability of $\Qopen$); $c, g, p_{\mathrm{cite}}$ (rule probabilities); $\mathcal W_{\mathrm o}:=\ln\frac{1+g\rho}{1-\rho}$ (`\Wo`; per-datum waste of $\Hopen$); $r_{\mathrm w}$ (waste ratio of Lemma N0); $A_\rho:=(1-\rho)/(1-gc\rho)$, $B_\rho:=(1+g\rho)/(1-gc\rho)$ (Prop N1); $h(v)=c/(c+v(1-c))^2$ (Prop B2); $I_n$ (spare-prover integral); $L$, $f_q$, $\Delta(f_q)$ (Prop U12(b)); $K_n$, $m_n$, $S_n$ (memoriser bounds).
* §ident: $\rho_T$ (Bhattacharyya coefficient); $\Delta_n$, $\mathrm{BF}_n$ (split comparisons); $R_n$ (spare-slot ratio); $K_T$, $\mathbb M$ (KL values and minimisers); $\varepsilon$ in Lemma 1.8.
* §sound: $L_t(T)$, $Z_t$, $Z^H_n$, $c_j(T)$ (proof of Thm 4.1); $\varepsilon$ (Ex 4.9 root law); $\gamma$ (Markov level in Thm 4.7; model writes $\eta$).
* §time: $X$, $f_X$, $\varphi_w$, $\nu(w)$ (hard languages); $s(m)$, $\ell(m)$ (time bounds); $d$ (degree of syntactic operations, Thm 6.12; model's letter); $c_T$, $a_T$ (Lemma 6.10).
* §pa: $p_f$ (usage rates of forms), $c_S(f)$ (cost of form $f$ in $T_S$), $\theta_\varphi$ (motive transform), $u$ (fraction of induction uses), $G1,G2,G3$ (u7 usage laws), NAIVE/PC/DPC/SDPC/RDPC/CF (grammar codes), $k$ (geometric level in the tower), $R$ (number of rules in the rule code), $h(f)$ (binary entropy).
* §exp: $c_{\mathrm{stop}}$, $c_{\mathrm{ch}}$, $c_r$ (rule weights), $b$ (build point), $\tau$ (time-factor exponent; distinct from templates by context, write "time exponent $\tau$" at first use).

## 10. Renamings forced by clashes (apply everywhere)

| source name | clash | paper name |
|---|---|---|
| Ind$(s)$ (independent mass; model, universal) | induction schema `\Ind` | $\Indep(s)$ (`\Indep`) |
| $Q$ (instantiation grammar; all tracks) | Robinson's $\Q$ | $\Qg$ (`\Qg`) |
| $\mathrm{Acc}_f$, $\mathrm{Rej}_f$ (model §6) | cautious acceptance `\Acc` | $\Accf{f}$, $\Rejf{f}$ |
| Prov (universal U10) | provability predicate, probability | $\ProvAll$ |
| $\mathrm{Pr}_T$ (pa §4) | probability $\Pr$ | $\Prv_T$ |
| $\kappa_o$ (universal N2) | $\kappa$ of $\Lsig$ | $\mathcal W_{\mathrm o}$ (`\Wo`) |
| $\lambda$ in Lemma N0 (universal) | prior steepness $\lambda$ | $r_{\mathrm w}$ |
| $S_{\mathrm{nc},\beta}$, $\beta\ge1$ (universal) | pa's $\beta$ (bits per symbol), model's $\beta=g(\infty)$ | $\Sg$ with $g\equiv1$ on provable data and $g_\infty=1/\beta$, times the data-independent factor $\beta^n$ |
| model's $\beta=g(\infty)$ | pa's $\beta$ | $g_\infty$ |
| $c$ = citation bits (pa §3) | ∀E probability $c$ | $\ell_{\mathrm{cite}}$ |
| $K$ = Mendelson's calculus (model) | $K$ = number of templates | `\CK` = $\mathsf K$ |
| $K$ = chain bound (experiments) | same | $J$; $\vdash_J$; $\Cch{J}$ |
| $K=1-c-g$ (universal $\Copen$) | same | $p_{\mathrm{cite}}$ |
| $m$ = components of $T^*$ (experiments X8) | $m$ = mean premises (model) | $K$ |
| $N_m$ (experiments E3) | — | $R_m$ (closed guard) |
| $w_0$, `w0` (universal, experiments) | weights $w$ | parameter $p$ |
| $M_T$ (experiments) | Bayes mixture $M$ | $\PDir{T}$ |
| L1(c) (universal, unnormalised) | model's L1 (normalised) | $\mu_T$; "L1-norm" = `\Lone` |
| "L2" = Viterbi (universal `notes.md`) | model's L2 (bounded depth) | `\Lmax` |
| $\eta$ (model Prop 5.6(b), Thm 4.7) | noise rate $\eta$ | $\delta'$ (Ville level), $\gamma$ (Markov level) |
| $d$ = datum (universal) | $d$ = derivation bound | $s$ |
| $\theta$ = weight of $\forall x\varphi$ (universal $\Hboth$, U12) | substitution $\theta$ | $w_\forall$ |
| $\theta$ = theorem datum (pa §3) | substitution $\theta$ | $s$ |
| $T_E$ = memoriser of $E$ (model) | pa's $T_E$ (narrow template) | $\Mem(E)$ |
| L(T; D) code length (pa) | likelihood names | $\CL(T;D)$ |

## 11. Bibliography keys

Use the keys of `bib/core.bib`: hanni2026notes, claude2026whatfollows, claude2026axiomschemas, gold1967language, angluin1980inductive, plotkin1970note, reynolds1970transformational, huet1975unification, huet1978proving, miller1991logic, pfenning1991unification, baumgartner2017higher, cerna2023antiunification, wright1989identification, motoki1991correct, muggleton1991inductive, tarski1957arithmetical, rylln1952axiomatizability, vaught1967axiomatizability, jech2003set, kunen1980set, kaye1991models, hajek1993metamathematics, matiyasevich1993hilbert, rissanen1978modeling, tenenbaum2001generalization, reiter1987theory, shapiro1983algorithmic, garey1979computers, demoura2021lean4, megill2019metamath, debruijn1972lambda.

Canonical keys for other references (add the entry to `bib/<key>.bib`; the verification status is as recorded by the tracks — keep it in a comment and hedge unverified claims):

| key | reference | status in the tracks |
|---|---|---|
| hutter2007universal | M. Hutter, On universal prediction and Bayesian confirmation, TCS 384(1):33–48, 2007, doi:10.1016/j.tcs.2007.05.016 | bibliographic data and abstract checked; full text not |
| leike2015solomonoff | J. Leike, M. Hutter, Solomonoff induction violates Nicod's criterion, ALT 2015, LNCS 9355 | abstract level |
| gaifman1964concerning | H. Gaifman, Concerning measures in first order calculi, Israel J. Math. 2(1):1–18, 1964 | bibliographic data; condition cited from memory |
| gaifman1982probabilities | H. Gaifman, M. Snir, Probabilities over rich languages, testing and randomness, JSL 47(3):495–548, 1982 | bibliographic data; context only |
| doob1949application | J. L. Doob, Application of the theory of martingales, Colloques Int. CNRS 13:23–27, 1949 | bibliographic data |
| schwartz1965bayes | L. Schwartz, On Bayes procedures, Z. Wahrsch. verw. Geb. 4:10–26, 1965 | checked by model's referee |
| berk1966limiting | R. H. Berk, Limiting behavior of posterior distributions when the model is incorrect, Ann. Math. Statist. 37(1):51–58, 1966 | abstract; conditions not read |
| kleijn2006misspecification | B. J. K. Kleijn, A. W. van der Vaart, Misspecification in infinite-dimensional Bayesian statistics, Ann. Statist. 34(2):837–877, 2006 | abstract; conditions not read |
| ghosal2017fundamentals | S. Ghosal, A. van der Vaart, Fundamentals of Nonparametric Bayesian Inference, CUP, 2017 | Thm 6.9 confirmed only via citing papers |
| miller2018doob | J. W. Miller, A detailed treatment of Doob's theorem, arXiv:1801.03122, 2018 | unverified |
| krichevsky1981performance | R. Krichevsky, V. Trofimov, The performance of universal encoding, IEEE Trans. IT 27(2):199–207, 1981 | standard; checked by model's referee |
| ville1939etude | J. Ville, Étude critique de la notion de collectif, Gauthier-Villars, 1939 | standard |
| waudby2020confidence | I. Waudby-Smith, A. Ramdas, Confidence sequences for sampling without replacement, NeurIPS 2020 | as cited in IL |
| horning1969study | J. J. Horning, A Study of Grammatical Inference, PhD thesis, Stanford, 1969 | existence checked; details unverified |
| angluin1988identifying | D. Angluin, Identifying languages from stochastic examples, Yale TR YALEU/DCS/RR-614, 1988 | existence checked; content unverified |
| craig1953axiomatizability | W. Craig, On axiomatizability within a system, JSL 18(1):30–32, 1953 | checked by model's referee |
| cook1972hierarchy | S. A. Cook, A hierarchy for nondeterministic time complexity, STOC 1972 | exact form unverified |
| seiferas1978separating | J. Seiferas, M. Fischer, A. Meyer, Separating nondeterministic time complexity classes, JACM 25(1):146–167, 1978 | checked by model's referee |
| zak1983turing | S. Žák, A Turing machine time hierarchy, TCS 26(3):327–333, 1983 | bibliographic data |
| mendelson1997introduction | E. Mendelson, Introduction to Mathematical Logic (system K, Ch. 2) | edition and numbering unverified |
| athreya1972branching | K. B. Athreya, P. E. Ney, Branching Processes, Springer, 1972 | numbering unverified |
| shafer1976mathematical | G. Shafer, A Mathematical Theory of Evidence, Princeton, 1976 | standard |
| rousseau2011asymptotic | J. Rousseau, K. Mengersen, Asymptotic behaviour of the posterior distribution in overfitted mixture models, JRSS B 73(5):689–710, 2011 | checked by model's referee |
| schwarz1978estimating | G. Schwarz, Estimating the dimension of a model, Ann. Statist. 6(2):461–464, 1978 | from memory |
| clarke1990information | B. Clarke, A. Barron, Information-theoretic asymptotics of Bayes methods, IEEE Trans. IT 36(3):453–471, 1990 | from memory |
| church1936note | A. Church, A note on the Entscheidungsproblem, JSL 1:40–41, 1936 | unverified |
| turing1936computable | A. M. Turing, On computable numbers, Proc. LMS 42:230–265, 1936 | unverified |
| pudlak1998lengths | P. Pudlák, The lengths of proofs, Handbook of Proof Theory, 1998 | unverified |
| birkhoff1935structure | G. Birkhoff, On the structure of abstract algebras, Proc. Camb. Phil. Soc. 31:433–454, 1935 | unverified |
| boolos2007computability | G. Boolos, J. Burgess, R. Jeffrey, Computability and Logic (chapter on Q) | chapter unverified |
| shoenfield1967mathematical | J. Shoenfield, Mathematical Logic, 1967 (substitution for predicate symbols) | location unverified |
| kaye1988parameter | R. Kaye, J. Paris, C. Dimitracopoulos, On parameter free induction schemas, JSL 53(4):1082–1097, 1988 | existence checked by pa's referee |
| zarach1996replacement | A. Zarach, Replacement ↛ Collection, Gödel '96, LNL 6, 307–322, 1996 | abstract and catalogue record |
| gitman2016zfc | V. Gitman, J. D. Hamkins, T. Johnstone, What is the theory ZFC without power set?, MLQ 62(4–5):391–406, 2016 | abstract and catalogue record |
| kaye2007interpretations | R. Kaye, T. L. Wong, On interpretations of arithmetic and set theory, NDJFL 48(4):497–510, 2007 | abstract |
| shepherdson1964nonstandard | J. C. Shepherdson, A non-standard model for a free variable fragment of number theory, Bull. Acad. Polon. Sci. 12:79–86, 1964 | secondary sources only |
| levy1979basic | A. Lévy, Basic Set Theory, 1979 | location unverified |
| parikh1973some | R. Parikh, Some results on the length of proofs, Trans. AMS 177:29–36, 1973 | not opened |
| baaz1993kreisel | M. Baaz, P. Pudlák, Kreisel's conjecture for L∃1, in Arithmetic, Proof Theory and Computational Complexity, OUP, 1993 | not opened |
| hrubes2007theories | P. Hrubeš, Theories very close to PA where Kreisel's conjecture is false, JSL 72(1):123–137, 2007 | not opened |
| hoeffding1963probability | W. Hoeffding, Probability inequalities for sums of bounded random variables, JASA 58:13–30, 1963 | from memory |

Paris–Kirby (Logic Colloquium '77) on fragments, Turing 1939, Feferman 1962, Plandowski 1994, Busatto–Lohrey–Maneth 2008, Schmidt-Schauß 2005 and Levin's Kt are cited by the tracks from memory without full data; cite them only in hedged sentences, and check the bibliographic data before adding an entry.

## 12. Macros added to `preamble.tex` (block "axiom-induction macros")

Likelihoods (text or math): `\Lzero` L0, `\Lone` L1, `\Ltwo` L2, `\Lsig` L1^σ, `\Lmax` L1^max, `\Lsch` L1^sch, `\Lnaive` L1^naive, `\Lsel` L1^sel, `\Lselc` L1^sel_cit, `\Lcl` L0^cl, `\Leq` L1^eq, `\Leps` L_ε.
Scores: `\Sprove`, `\Snc`, `\Sg`.
Calculi: `\CK`, `\Cmin`, `\Copen`, `\Cand`, `\CUiii`, `\Cch{J}`, `\CND`.
Grammars: `\Qg`, `\Qnum`, `\Qopen`, `\QGW`, `\Qelim`.
Bayesian objects: `\Hclass`, `\Cstar`, `\Dir`, `\PDir{T}`, `\DirMult`, `\KT`, `\KL`, `\TV`, `\Ex`, `\Rreg`, `\Ver{δ}{d}`, `\CL`.
Trichotomy: `\Bel`, `\Belc`, `\Dis`, `\Indep`, `\Inc`, `\Pl`.
Hypotheses: `\Hall`, `\Hsch`, `\Hopen`, `\Hboth`, `\Mem`, `\Trim`, `\SeenQ`, `\Split`, `\Tesc`, `\TInd`, `\Ic`, `\Io`, `\Wo`.
Collapse and arithmetic: `\AI`, `\FIcons`, `\FIall`, `\Accf{f}`, `\Rejf{f}`, `\Tr`, `\Prv`, `\Refl`, `\Sent`, `\Cn`, `\NTIME`, `\gn{φ}`, `\ISigma{n}`, `\IOpen`, `\CVI`, `\LNP`, `\Dlt`, `\ProvAll`.
Math-mode only: all except the likelihood names, scores and calculi, which use `\ensuremath`.
