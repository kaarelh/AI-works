# Notation for the paper on \SAI (binding)

*Planning editor, 2026-10-16. Binding for every writer of `paper/`. It turns `research/NOTATION-draft.md` into the paper's notation and settles every decision listed in `research/notes-final.md` §5.6 and in the threads' notation requests (`fundamentals` §13, `sfi` §12, `logic` §1.4 and §8, `terms` §1.4 and §12, `shape` §11, `laws` §11, `philosophy` §8). The macros are defined in the "SAI macros" block of `preamble.tex`; section files must not define or redefine global macros. §12 lists every decision with its reason.*

**Rules.**
1. **One symbol per object across the paper.** The symbols in §1–§10 are *global*: they mean the same object in every section and appendix, and nothing else. A writer who needs a new global symbol asks the planning editor (record the request in your section's log); do not invent one.
2. **Local symbols** (defined inside one proof, one example or one subsection, and not used outside it) are allowed, but must not be one of the global symbols below, and must not be a symbol of P1 or P2 that this paper cites. When a source record uses a local letter that is global here, rename it (§11 lists the renames already decided).
3. **Macros.** Every global symbol that has a macro below is written with the macro, never typed out. The name of the family is produced **only** by `\SAI` (and its variants); never write the working name out, and no argument, claim or heading may depend on it.
4. **Translating the records.** The thread records use the item numbers of their development records and some letters that are renamed here (§11). Write this paper's symbol; keep the record's item number in `\src{...}`.

---

## 0. Names

| macro | prints (working value) | use |
|---|---|---|
| `\SAI` | Solomonoff axiom induction | the family, in running prose ("we call this family \SAI"); sentence-initial use is fine |
| `\SAItitle` | Solomonoff Axiom Induction | title-case contexts only (the title, section titles if needed) |
| `\SAIabbr` | SAI | the abbreviation, after first use of `\SAI` in each of: abstract, introduction |
| `\SOI` | Solomonoff operator induction | the companion family |
| `\SOIabbr` | SOI | its abbreviation |

* All five end in `\xspace`; write `\SAI` followed by a space or punctuation as usual.
* **"\SAIabbr" without qualification** means the one-tape proof-requiring law $\MA$. **"\SOIabbr" without qualification** means the one-tape law $\MF$ of the companion paper. When a statement holds for every version, say "every version of \SAIabbr" and list them.
* **First sentence of the paper (binding, synthesis §5.1):** the introduction says, in its first paragraph, that "axiom" in \SAI refers to the hypotheses (axiom systems), not to the induction axiom.
* **Companion papers.** Cite \citet{claudeSFI2026fundamentals} (definitions and versions of \SOIabbr; call it "the companion paper") and \citet{claudeSFI2026steeper} (steeper priors) by their printed numbers or by content, never as "P1", "P2". The earlier report on axiom induction is \citet{claude2026axiominduction}; cite by printed numbers ("Theorem 6.3 of \citet{claude2026axiominduction}"); never "AI-paper", "TF", "SD" in printed text. The axiom-schemas report is \citet{claude2026axiomschemas}.

---

## 1. General conventions (inherited from the SOI papers)

| symbol | macro | meaning |
|---|---|---|
| $\log$ | | base 2; losses and code lengths in bits. $\ln$ natural |
| $c,c',c'',\dots$ | | machine constants: depend only on the fixed universal machines, the coding of syntax and the background $B$ (a statement that lets them depend on more says so). $O(1)$ means the same |
| $\asymp$ | | equality within a factor $2^{\pm c}$ on every data set |
| $\Unif$ | `\Unif` | the fair-coin measure on tapes $\omega\in\{0,1\}^\infty$; $[w]$ the cylinder of a finite string $w$. **Never** $\lambda$ |
| $\Prob,\Ex$ | `\Prob`, `\Ex` | the true law of a data process and its expectation |
| $\ind[\cdot]$ | `\ind` | indicator |
| $\dom$, $\supp$ | `\dom`, `\supp` | domain of a partial function or data set; support |
| $\KL$, $\TV$ | `\KL`, `\TV` | Kullback–Leibler divergence (bits), total variation |
| $V$ | | the fixed universal prefix machine; $\Omega_V:=\sum_{p\in\dom V}2^{-\lvert p\rvert}$ |
| $K$, $K(\cdot\mid\cdot)$ | | prefix complexity; $K(\nu)$ least $K(i)$ over indices $i$ of $\nu$ |
| $\mm$ | `\mm` | $\mm(i)=\sum_{V(p)=i}2^{-\lvert p\rvert}$ |
| $\Kpad(n)$ | `\Kpad` | $\min_{n'\ge n}K(n')$ (nondecreasing, unbounded) |
| $\Ktail$ | `\Ktail` | as in the companion paper (only if needed) |
| $\Omtail{\ell}$ | `\Omtail{\ell}` | halting mass of $V$-programs of length $\ge\ell$ |
| $Kt$, $K^q$ | `\Kt` | Levin's time-bounded complexity $Kt(x)=\min\{\lvert p\rvert+\log t:V(p)=x\text{ in }t\text{ steps}\}$; $K^q(x)$ the least $\lvert p\rvert$ with $V(p)=x$ within $q(\lvert x\rvert)$ steps ($q$ a polynomial) |
| $p$, $\lvert p\rvert$ | | a program and its length |
| $n$ | | the number of revealed data |
| $d$, $N:=2^d$ | | bit length of the words in literal data (§3.4); **not** a derivation budget (renamed $s$, §5) |
| $\lambda$ | | **only** the steepness exponent of the companion paper on steeper priors (weight on length against fit), as in $J_\lambda$ (§8.1) |
| $e$ | | an index of an r.e. set ($\re{e}$) in §2–§5; in §9–§10 the error function of an approximate law (§8.1). The two uses never meet in one statement |
| $\{e\}$ | | the $e$-th partial computable function (Kleene bracket); never $\varphi_e$ |

---

## 2. Logic

| symbol | macro | meaning |
|---|---|---|
| $\mathcal L$ | | a countable first-order language with equality and computable syntax (**languages are calligraphic**) |
| $\Sent=\Sent_{\mathcal L}$ | `\Sent` | its sentences |
| $\vdash$ | | classical first-order derivability (a fixed sound and complete calculus; where derivation size matters, the Hilbert calculus $\mathsf K$ of \citet{claude2026axiominduction}) |
| $B$ | | the **background**: decidable and consistent; default $B=\emptyset$. "$\Gamma$ proves $\varphi$" means $B\cup\Gamma\vdash\varphi$; "$\Gamma$ consistent" means $B\cup\Gamma$ consistent |
| $\Cn(\Gamma)$ | `\Cn` | $\{\varphi:B\cup\Gamma\vdash\varphi\}$ ($B$ built in) |
| $\varphi^1:=\varphi$, $\varphi^0:=\neg\varphi$ | | |
| decides | | $\Gamma$ decides $\varphi$ if it proves $\varphi$ or $\neg\varphi$ |
| $\IndB$ | `\IndB` (`\IndB[B']`) | the $B$-independent sentences: $B$ decides neither (used in `prop:soi:independent`) |
| $[T]$ | | the deductive class $\{e:\Cn(\re e)=\Cn(T)\}$ |
| $\re e$ | `\re{e}` | the $e$-th r.e. set (sans-serif $\mathsf W$; never $W_e$) |
| $\Lar$ | `\Lar` | $\{0,S,+,\cdot,<\}$; numerals $\num n:=S^n0$ (`\num{n}`) |
| $\Q$, $\PA$ | `\Q`, `\PA` | Robinson arithmetic, Peano arithmetic (sans serif) |
| $\Delta_0,\Sigma_1,\Pi_1$; $\Pi_1^*$ | | as usual (syntactic classes); $\Pi_1^*$ = finite conjunctions of $\Pi_1$ sentences and negations of $\Sigma_1$ sentences. "$\Q$-equivalent to" when only up to $\Q$ |
| "$B$ true", "$B\supseteq\Q$" | | $B$ has a model whose $\Lar$-reduct is $\mathbb N$; $\Q\subseteq\Cn(B)$ (likewise $\PA$, and "$B\cup T$ true") |
| $\Sigma_1$-sound | | proves no false $\Sigma_1$ sentence |
| $\Con(T)$ | `\Con` | canonical consistency statement of an r.e. presentation |
| $\Th(\mathfrak M)$, $\Th(\mathbb N)$ | `\Th` | complete theory of a structure |
| $\gn\varphi$ | `\gn{\varphi}` | Gödel number |
| $\cplx{NP}$ etc. | `\cplx{NP}` | complexity classes in sans serif: $\cplx{P}$, $\cplx{NP}\cap\cplx{coNP}$, $\cplx{EXPTIME}$, $\cplx{APSPACE}$ |
| $\mathcal L=\LO\cup\LT$ | `\LO`, `\LT` | observational and theoretical vocabulary (§8 of the paper) |
| $T_O(A)$ | | observational content $\Cn(A)\cap\Sent_{\LO}$ |
| $\ThT$ | `\ThT` | the complete first-order theory of the named structure $(\mathfrak T;\mathtt e,\mathtt s_0,\mathtt s_1)$ |
| about the named objects | | $T$ has a model whose $\{\mathtt e,\mathtt s_0,\mathtt s_1\}$-reduct is $\mathfrak T$ |
| compatible with the named structure | | $T\cup\ThT$ consistent (weaker; nonstandard objects allowed) |
| sentence length | | **the symbol count**, for every clock, budget and length in statements about time or derivation size (Presburger, charged deduction); say so where a statement depends on it |

---

## 3. Data, questions, conventions

### 3.1 Data
* A **data set** $D$ is a finite partial function $\Sent\rightharpoonup\{0,1\}$ (label 1 = true). A **three-valued** data set maps into $Y_3:=\{1,0,\iota\}$; $\iota$ means "independent" (`\iota`; never "ind").
* $D^\pm:=\{\varphi^{D(\varphi)}:D(\varphi)\in\{0,1\}\}$; $\psi_D:=\bigwedge D^\pm$ in a fixed canonical order ($\top$ if empty). $D$ is **consistent** if $B\cup D^\pm$ is.
* $D+(\varphi,y)$ for $\varphi\notin\dom D$. A **reveal sequence** $(\varphi_t,y_t)_{t\le n}$ with prefixes $D_t$; an infinite **stream** $D_\infty$ with $D_\infty^\pm:=\bigcup_nD_n^\pm$.
* **Conditionals.** $\nu(y\mid D,\varphi):=\nu(D+(\varphi,y))/\nu(D)$ for $\varphi\notin\dom D$, and $\ind[y=D(\varphi)]$ for $\varphi\in\dom D$ (the repeated-input convention of the companion paper).

### 3.2 Questions and conditional questions
* A **question** is a finite set $\mathcal Q=\{\varphi_1,\dots,\varphi_k\}$ of pairwise $B$-incompatible sentences whose disjunction $B$ proves (its direct answers); a yes/no question is $\{\varphi,\neg\varphi\}$. Results that need only pairwise incompatibility say so.
* A **conditional question** is a pair $(\alpha,\ell)$, read "given $\alpha$, is $\ell$ the case?". **Encoding (E3)** (`\Ethree`, binding): a theory $T$ is compatible with the conditional datum $(\alpha,\ell)$ iff $B\cup T\cup\{\alpha\}$ is consistent and proves $\ell$; equivalently $T\vdash\alpha\to\ell$ and $T\nvdash\neg\alpha$. The two-valued encoding "$(\alpha\to\ell,1)$" is degenerate (`prop:shape:E2`) and is never used for conditional data. (E3) is not a single datum of $\MAthree$.

### 3.3 Literal data and fresh atoms
* **Literal language:** a constant $\mathtt e$, unary function symbols $\mathtt s_0,\mathtt s_1$, a unary relation symbol $R$; $t_w:=\mathtt s_{w_1}(\cdots\mathtt s_{w_k}(\mathtt e)\cdots)$; $\varphi_w:=R(t_w)$, $\lvert\varphi_w\rvert=\lvert w\rvert+2$; for a set of words $X\subseteq\{0,1\}^*$, $D^X$ lists $(\varphi_w,[w\in X])$ in length-lexicographic order and $f_X$ is the literal labeller of $X$. $\mathfrak T$ is the free term algebra on $\mathtt e,\mathtt s_0,\mathtt s_1$ (the **named structure**). $X$ (a set of words, the "target") is used only in this sense.
* **Fresh atoms** (a defined term; `def:setting:fresh`): $R$ does not occur in $B$, and some model of $B$ interprets the closed terms $t_w$ as pairwise distinct elements; fresh atoms are sentences $R(t_w)$ for **pairwise distinct** words $w$. Every result stated "for fresh atoms" or "on literal data" assumes this.
* The **fit class** of an inducer is the set of $X$ on whose literal sequence $D^X$ it has bounded loss.

### 3.4 Loss conventions (every loss statement names its convention)
* **Semimeasure convention (primary).** The cumulative loss of a consistent reveal sequence is $\sum_{t\le n}-\log\MA(y_t\mid D_{t-1},\varphi_t)=\LA(D_n)-\LA(\emptyset)$; it depends on $D_n$ only through $\Cn(D_n^\pm)$. For the coin-free version: $-\log\WA(D_n)+\log\WA(\emptyset)$.
* **Normalised convention.** Each conditional divided by $\Bel_D(\varphi)+\Dis_D(\varphi)$. Upper bounds transfer from the semimeasure convention; lower bounds do not, and **a lower bound in the semimeasure convention can fail in the normalised convention by an unbounded amount** (`prop:logic:normalised`). The normalised loss depends on the reveal order (`thm:basic:order`).
* **Three-valued convention.** Labels in $Y_3$, scored by $\MAthree$, whose conditionals sum to 1.
* The consistency-requiring predictor has its own loss (`prop:basic:cr`).
* Every **lower bound** says "in the semimeasure convention", "in the three-valued convention" or "in both conventions". Statements about $\KA$, $\Kfin$ and the posterior ($P_\infty$, $\Bel$, $\Dis$, $\Indep$) need no convention.

---

## 4. Theory machines and the one-tape law

| symbol | macro | meaning |
|---|---|---|
| $G$ | | a **theory machine**: a c.e. set $G\subseteq\{0,1\}^*\times\Sent$ ("after reading $w$, emit $\chi$"); no consistency condition |
| $A^G_w$, $A^G_\omega$ | | axioms emitted under a finite prefix $w$ / on a tape $\omega$ |
| $O^G_\chi$ | | $\{\omega:B\cup A^G_\omega\vdash\chi\}$ (effectively open); $O_\chi:=O^{G_U}_\chi$ |
| $\mathrm{Cons}^G$, $\mathrm{Cons}$ | | the consistency event $\{0,1\}^\infty\setminus O^G_\bot$ (a $\Pi^0_1$ class); $\mathrm{Cons}:=\mathrm{Cons}^{G_U}$ |
| $E^G_D$, $E_D$ | | $O^G_{\psi_D}\setminus O^G_\bot$ $=O^G_{\psi_D}\cap\mathrm{Cons}^G$ (consistent and proves the data); $E_D:=E^{G_U}_D$; $E^3_D$ three-valued; $E_\infty:=\bigcap_nE_{D_n}$ |
| $\nu_G$, $\nu_G^3$ | | the **law** $\nu_G(D):=\Unif(E^G_D)$; three-valued law |
| $G_U$, $A_\omega$ | | the universal theory machine (read a self-delimiting $V$-program, run that machine on the rest of the tape); $A_\omega:=A^{G_U}_\omega$ |
| $(G_i)$, $K(G)$ | | a fixed effective enumeration of theory machines; $K(G)$ least $K(i)$ with $G_i=G$ |
| $\Inc_0$ | `\Inc_0` | $\Unif(O_\bot)$: probability that the random theory is inconsistent (macro `\Inc` prints Inc) |
| $\MA$ | `\MA` | **the one-tape proof-requiring law** $\nu_{G_U}$; "\SAIabbr" without qualification |
| $\MAthree$ | `\MAthree` | $\nu^3_{G_U}$ |
| $\LA$ | `\LA` | $-\log\MA$ |
| $P_\infty$ | | $\Unif(\cdot\mid E_\infty)$, the limit posterior, when $\Unif(E_\infty)>0$ |
| $\Bel_D,\Dis_D,\Indep_D$ | `\Bel`, `\Dis`, `\Indep` | posterior probabilities that the random theory proves $\varphi$, proves $\neg\varphi$, decides neither |
| $\Bel_0$ | `\Bel_0` | prior probability of provability $\MA(\{(\chi,1)\})=\Unif(O_\chi)-\Inc_0$; **unnormalised**: $\Bel_0(\top)=1-\Inc_0$ |
| $\Belhat_0$ | `\Belhat_0` | $\Bel_0/(1-\Inc_0)=\Bel_\emptyset$; always write `\Belhat_0` (or $\Bel_\emptyset$) where the normalisation matters; never write $\Bel_0$ for the normalised function |
| $\Pl_0$, $\Pl_D$ | `\Pl` | plausibility $\Pl_0(\chi)=\Bel_0(\top)-\Bel_0(\neg\chi)$ |
| $\tri_\omega$, $\tri^G_\omega$ | `\tri` | trichotomy function of the random theory ($1/0/\iota$ per sentence) |
| $\UA(\mathcal C;D)$ | `\UA` | **the one symbol for class-restricted laws:** $\Unif\{\omega:B\cup A_\omega$ consistent, $\vdash\psi_D$, $\Cn(A_\omega)\in\mathcal C\}$ for a class $\mathcal C$ of deductively closed theories; $\UA(\mathcal C):=\UA(\mathcal C;\emptyset)$ |
| $\UA[T]$ | | $\UA(\{\Cn(T)\})=\Unif\{\omega:B\cup A_\omega\text{ consistent},\ \Cn(A_\omega)=\Cn(T)\}$ |
| $\UA(\Exts T)$ | `\Exts` | **explicit form (binding):** $\Unif\{\omega:B\cup A_\omega\text{ consistent},\ \Cn(A_\omega)\supseteq\Cn(T)\}$ |
| $X(\mathcal C;D)$ | | the same restriction for another version $X$ (e.g. $\MAchk{t}(\mathcal C;D)$ for a penalised law); the observational class laws of §8 are $\UA(\{T:T\cap\Sent_{\LO}\in\Theta\};D)$ for a Borel set $\Theta$ of observational contents |
| $\epsempty$ | `\epsempty` | $\Unif\{\omega:A_\omega=\emptyset\}$, the mass of the empty theory (used in the consistency-requiring results) |

**Variants of the family.**

| symbol | macro | meaning |
|---|---|---|
| $\MAnc$, $\Belnc_D$, $\Disnc_D$ | `\MAnc`, `\Belnc`, `\Disnc` | **consistency-requiring** 0/1 weight $\Unif\{\omega:B\cup A_\omega\cup D^\pm\text{ consistent}\}$; its predictor ("Dempster conditioning") |
| $\MAhalf$ | `\MAhalf` | graded consistency-requiring weight, grade $\tfrac12$ per unproved datum (the grade function is written $\mathrm{gr}_A$) |
| $P_T$, $\Xi$ | | generative (derivation-likelihood) variant: a theory's law on sampled theorems, and the universal mixture of data streams |
| $\MAdec$ | `\MAdec` | the one-tape mixture over random deciders |
| $\MAchk{t}$, $\MAgen{t}$ | `\MAchk{t}`, `\MAgen{t}` | one-tape membership-time / generation-time penalised laws |
| $\MA^{\LO}$, $\WA^{\LO}$, $\KA^{\LO}$ | | hypotheses restricted to observational axioms ($\MA^{\mathcal L}:=\MA$) |

---

## 5. Coin-free and Kolmogorov versions; the SOI side

| symbol | macro | meaning |
|---|---|---|
| $\WA$ | `\WA` | coin-free, over enumerators: $\sum_{p\in\dom V}2^{-\lvert p\rvert}\ind[B\cup\re{V(p)}\text{ consistent and }\vdash\psi_D]$ |
| $\WAdec$ | `\WAdec` | over deciders ($\asymp\WA$) |
| $\WAthree$ | `\WAthree` | three-valued coin-free \SAIabbr (independence observed) |
| $\KA$, $\KAdec$ | `\KA`, `\KAdec` | Kolmogorov versions: shortest consistent r.e. axiomatisation (resp. decider) proving the data ($\infty$ if none) |
| $\Kfin$, $\Wfin$ | `\Kfin`, `\Wfin` | over single sentences $\psi$ (finite axiomatisations); language superscript $\Kfin^{\mathcal L}$ when needed |
| $\Keq(T)$, $\mmeq(T)$ | `\Keq`, `\mmeq` | $\min_{e\in[T]}K(e)$; $\sum_{e\in[T]}\mm(e)$ |
| $\Exts(T)$, $\mm(\Exts T)$ | `\Exts` | the indices $e$ with $B\cup\re e$ consistent and $\Cn(\re e)\supseteq\Cn(T)$; $\sum_{e\in\Exts T}\mm(e)$. (`\Exts`, not `\Ext`, which is extensionality in the earlier report) |
| $\Kenum$, $\mmenum$, $\Uenum$ | `\Kenum`, `\mmenum`, `\Uenum` | enumeration complexity of a set, its universal discrete semimeasure, the universal probabilistic enumeration probability of a set (`prop:basic:tape`, open question on the random tape) |
| $\WAchk{t}$, $\WAgen{t}$, $\WAKt{t}$ | `\WAchk{t}`, `\WAgen{t}`, `\WAKt{t}` | coin-free membership-time, generation-time, Levin-$Kt$ penalties on axioms |
| $W_A[t,s]$ | | charged deduction, derivation **size** $s$ (renamed from the earlier report's $d$) |
| $W_A^{a1}[t,h]$, $W_A^{a2}[t,h]$, $W_A^{b}[t,g]$, $W_A^{b2}[t,g]$ | | charged deduction under the readings (a1) every instance short, (a2) nonlogical instances short, (b) total material, (b2) nonlogical material; $t$ membership time, $h$ instance budget, $g$ material budget; always under (F1) |
| $\Wcert[t',s']$ | `\Wcert` | certificate \SOIabbr |
| $F$, $f^F_\omega$, $\nu_F$ | | a function machine (the companion paper's letter $T$ is renamed $F$, since $T$ is a theory), its random partial labeller, its law; $F_U$, $f_\omega:=f^{F_U}_\omega$ |
| $\MF$ | `\MF` | one-tape \SOIabbr (plain, on sentences or strings) |
| $\Gamma_f$ | | $\{\varphi^{f(\varphi)}:\varphi\in\dom f\}$ for a partial labeller $f$ |
| consistent / closed labeller | | $B\cup\Gamma_f$ consistent / moreover $f(\varphi)=b\iff B\cup\Gamma_f\vdash\varphi^b$ |
| $\MFcons$, $\MFcl$ | `\MFcons`, `\MFcl` | one-tape consistent / closed \SOIabbr |
| $\MFmw$ | `\MFmw` | mixture over function machines consistent on **every** tape ("machine-wise"; the records' $M_F^C$, renamed because $C$ was overloaded) |
| $\MFthreecons$ | `\MFthreecons` | one-tape three-valued consistent \SOIabbr |
| $\MF^{\mathrm{cons},\tau}$, $\MF^{\mathrm{all},\tau}$ | | one-tape clocked consistent / plain \SOIabbr ($\tau$ the labeller clock) |
| $W$ | | the companion paper's coin-free \SOIabbr **on strings** |
| $\Wall$ | `\Wall` | plain coin-free \SOIabbr **on sentences** (no consistency restriction) |
| $\Wcons$, $\Wcl$, $\Wthreecons$ | `\Wcons`, `\Wcl`, `\Wthreecons` | coin-free consistent / closed / three-valued consistent \SOIabbr |
| $W^{\mathrm{cons},\tau}$, $W^{\mathrm{all},\tau}$, $W^{\mathrm{cons},\mathrm{poly}}$ | | clocked coin-free versions |
| $W^1$ | | coin-free weights $2^{-\lvert f\rvert}/(\lvert f\rvert+1)$ (the $Kt$-penalty comparison) |
| $\KF$, $\KFcons$, $\KFcl$ | `\KF`, `\KFcons`, `\KFcl` | Kolmogorov \SOIabbr; shortest consistent / closed labeller extending $D$ |
| $\Mprod$, $\Mpq$ | `\Mprod`, `\Mpq` | the companion paper's product mixture and per-query mixture (only where cited) |
| (S), (S$_{\rm tape}$), (F1) | `\AssS`, `\AssStape`, `\AssF` | the self-simulation assumption of the earlier report, its tape version, and closure under parameter permutations; each is an `assumption` environment in §4 (`ass:soi:S`, `ass:soi:Stape`, `ass:soi:F1`) |
| $t\ge m^{a^*}$ | | time-constructible penalty bound; $a^*$ the membership degree |

**Translation from the earlier report** (for writers; never print the left column): AI → $\WAdec$; FIcons, FIall → $\Wcons$, $\Wall$; AI$^{\rm chk}_t$, AI$^{\rm gen}_t$, AI$^{\rm Kt}_t$ → $\WAchk t$, $\WAgen t$, $\WAKt t$; FIcons$^\tau$ → $W^{\mathrm{cons},\tau}$; AI$[t,d]$ → $W_A[t,s]$; AI$^{a1}[t,h]$ etc. → $W_A^{a1}[t,h]$ etc.; FIcert → $\Wcert$; AI3, FI3 → $\WAthree$, $\Wthreecons$; $S_{\rm prove}$, $S_{\rm nc}$, $S_g$ → $\MA$, $\MAnc$, $\MAhalf$ (the last is the symmetric form).

---

## 6. Logic section (§5 of the paper)

| symbol | macro | meaning |
|---|---|---|
| $\Win$ | `\Win` | the binary relation symbol of the lottery (never $W$) |
| $\Lot_k$ | `\Lot_k` | the lottery sentences; $N_k:=2^{k+1}-1$ (tickets $0,\dots,N_k$) is local to the lottery |
| $\Glot$ | `\Glot` | the random lottery theory machine |
| $\Tick_{k,j}$, $\Lot^{\rm ar}_k$ | `\Tick` | arithmetic tickets and lotteries |
| $\Gthr$, $\Gthr^{\mathrm u}$ | `\Gthr` | the threshold machine and its unsound companion |
| $\Kgt_m(x)$ | `\Kgt_m(x)` | the $\Pi_1$ sentence "$K(x)>m$" |
| $\Bit_k$ | `\Bit_k` | the $\Omega$-bit sentences |
| $\xi$ | | the exponent of the lower bound on $\Th(\mathbb N)$ data, $\xi\ge0.0823$ (the record's $\delta$, renamed: $\delta$ is data precision) |
| data of $\Pi_1$ type | | defined up to $B$-equivalence of literals (`logic` §3.1) |

---

## 7. Theory shape (§7 of the paper)

| symbol | macro | meaning |
|---|---|---|
| $m$ | | number of base variables (local to §7 and App. E; the global $n$ counts data) |
| $x_1,\dots,x_m$; $y_1,\dots,y_{m_{\rm aux}}$ | | base variables; auxiliary variables (the **intermediate concepts**) |
| $\Phi$ | | an **explicit theory** (finite set of non-tautological clauses) or a **linear theory** (equations over $\mathrm{GF}(2)$). Reserved: no other use of $\Phi$ in the paper |
| $\proj\Phi$ | `\proj` | its projection to the base variables |
| $\mathcal S$ | | a **law**: a nonempty subset of $\{0,1\}^m$ (never $V$) |
| $\mathcal Q(\mathcal S)$ | | the question set of a law (conditional questions, encoding (E3)) |
| $\mathcal R$ | | a **reasoner**; named reasoners $\UP_k$ ($k$ **parallel** rounds of unit propagation), $\UP:=\UP_\infty$, $\FC_k$ (forward chaining on directed rules, trivial rules excluded), $\GE$ (Gaussian elimination on linear theories), $\PS_\infty$ (unbounded proof search), $\PS_t$ |
| $\mathcal R$-compatible, $\mathcal R$-usable | | as in `def:shape:model` |
| $K_A^{\mathcal R}$, $W_A^{\mathcal R}$ | `\KA^{\mathcal R}` | **program length** (extends $\KA$, $\WA$ on question data) |
| $\Klst^{\mathcal R}$, $\Wlst^{\mathcal R}$ | `\Klst`, `\Wlst` | **listing**: the theory charged as written (prefix code $\ell_{\rm lst}$) |
| $\KtA^{\mathcal R}$ | `\KtA` | **time-charged** (Levin) |
| superscript $\mathrm{base}$ | | the class **without** intermediate concepts (explicit theories over the base variables only): $\Klst^{\mathcal R,\mathrm{base}}$, $\KtA^{\mathcal R,\mathrm{base}}$, … Without the superscript the class **with** auxiliary variables is meant. (The record's superscript $X$, renamed: $X$ is the literal target set, §3.3) |
| $\mathcal E^{\rm base}_m$, $\mathcal E_m$ | | the hypothesis classes (explicit theories without / with auxiliary variables); the record's $\mathcal C^X$, $\mathcal C^{XY}$, renamed because $\mathcal C$ is a class of theories in $\UA(\mathcal C;D)$ |
| $d_*$ | | least weight of a nonzero derived equation of an affine law (coding-theory notation; not the word length $d$) |
| $\Par^b_m$, $\mathrm{Ch}_m$, $\mathcal H_q$ | `\Par` | the parity law, the implication chain, the hidden-state law |
| $\ia_k$ | `\ia` | the inverse-Ackermann rows (never $\lambda$) |
| $\PI(\cdot)$ | `\PI` | prime implicates |

Every separation statement names its inducer ($\Klst$ or $\KtA$, never $K_A^{\mathcal R}$), its class (base or with intermediate concepts) and its depth (round) budget.

---

## 8. Approximate laws, explanation, the Kepler example (§9–§10 of the paper)

### 8.1 Approximate laws and best systems
| symbol | macro | meaning |
|---|---|---|
| $T_0$, $T^\varepsilon$, $T^{\varepsilon^*}$ | | exact law; honest (tolerance-weakened) law with tolerance $\varepsilon$; the honest law at the true error bound (never "H" for the honest form) |
| $e(t)$, $\varepsilon^*$ | | the true error of a law; $\varepsilon^*:=\operatorname{ess\,sup}\lvert e\rvert$ |
| $\delta$, $\delta_0$ | | data precision; measurement-error bound |
| $\Delta$ | | dithered cell width |
| $\pk(e)$ | `\pk` | **peakedness** $\sup\lvert e\rvert/\Ex\lvert e\rvert$; $\pk_\varepsilon$ uses a band's $\varepsilon$ in place of $\sup\lvert e\rvert$. **Every reported value names its fit** (minimax or mean) |
| $\gamma$; $\gamma_{\rm ex}$, $\gamma_{\rm si}$, $\beta_e$, $c_G$ | | per-datum literal cost; the exception and silence rates and the constants of the honest-law/exception comparison (`prop:laws:peaked`, `prop:laws:errormodel`) |
| $\theta_{\rm ex}$, $\rho$ | | exception share; $\rho$ also the "exact except in a share $\rho$" form (local to §9) |
| $J_\lambda(T;D)$ | | $\lambda\lVert T\rVert+\Exc_D(T)$ (the steeper objective) |
| $\Exc_D(T)$; $\Exc^Q$, $\Exc^F$, $\Exc^R$ | `\Exc` | the literal cost of the data $T$ does not prove ($\infty$ if inconsistent with $D$); exception codes: deterministic patches (Q), finite-theory exceptions (F), randomised completion (R) |
| $\EP_D(\mathcal A;T)$ | `\EP` | explanatory power $(\Exc_D(T\setminus\mathcal A)-\Exc_D(T))/\lVert\mathcal A\rVert$ of a module $\mathcal A\subseteq T$, with $\lVert\mathcal A\rVert:=\sum_{\chi\in\mathcal A}\ell(\chi)$ (the length of the module; **double bars**) |
| $s_\Delta$ | | silence probability (local to §9) |

### 8.2 Questions against raw data, explanation (§6)
| symbol | meaning |
|---|---|
| $\mathrm{Un}_D(\mathcal Q)$ | unanswered mass of a question |
| $\mu$, $\eta$, $\mu_\eta$ | a raw world (computable law on raw data), a partial computable **extractor** (the record's $g$, renamed: $g$ is a material budget), the law it induces on question data |

### 8.3 The Kepler example (§10, App. H; all local to them)
* Languages: $\mathcal L_{\rm hel}$ (heliocentric longitude, latitude, distance; the record's $\mathcal L_{\rm obs}$, renamed to avoid confusion with $\LO$), its direction-only part $\mathcal L_{\rm dir}$, the geocentric $\mathcal L_{\rm geo}$.
* Elements $a,e,i,\Omega,\varpi,M_0,P$ (semi-major axis, eccentricity, inclination, node, perihelion longitude, mean anomaly at epoch, period) are standard astronomical notation, used **only** in §10 and App. H, always with a body argument or subscript ($a(b)$, $e_b$, $P(b)$); $\theta(b,t)$ heliocentric and $\theta_g$ geocentric longitude; $\psi$ eccentric anomaly; $\rho$ the size element.
* K12, K3 (Kepler's first two laws; the third law $P(b)^2a(b')^3=P(b')^2a(b)^3$) in roman: $\mathrm{K12}$, $\mathrm{K3}$.
* $\mathrm{Occ}_{\mathsf F}(\delta)$ (`\Occ`): the Occam factor of a law form $\mathsf F$ (sans-serif $\mathsf F$ ranges over the forms of the Mars pool: circle, eccentric, bisected equant, vicarious hypothesis, ellipse); $\mathrm{Vol}_{\mathsf F}$ its volume.
* Syntaxes S1, S2, S3 of the law texts; $\sigma$ the noise standard deviation and $\tau_{\rm d}$ the distance tolerance (local).
* Every arcminute figure is **against the plan94 ephemeris**, not the sky.

---

## 9. Theoretical terms (§8 of the paper)

| symbol | meaning |
|---|---|
| $\LO=\{\mathtt e,\mathtt s_0,\mathtt s_1,R\}$ | the observational language of the literal results |
| $\mathcal L^+$ | the three-sorted extension (`thm:terms:KCV`) |
| $\mathsf C$ | the **binary theoretical relation** symbol (sans serif; the record's $C$). Italic $C$ is not used for it, nor for the consistency event of theory machines, which is $\mathrm{Cons}^G$ (§4) |
| $\Infn$ (`\Infn`) | "there are at least $n$ things" |
| two-stack program $\mathcal P_{\mathcal V}$ | local to App. F (the verifier is $\mathcal V$, never $V$) |
| $\iota$ | **only** the independent label; the record's $\iota_f$ ("$f$ is injective and not surjective") is written $\mathrm{Dinf}_f$ |

---

## 10. Labels and statuses

* **Label keys:** `intro, setting, basic, soi, logic, phil, shape, terms, laws, kepler, limits, related, discussion`; appendices `app:basic` (proofs for §2–§3), `app:soi`, `app:logic`, `app:phil`, `app:shape`, `app:terms`, `app:laws`, `app:kepler`, `app:notation`, `app:verification` (internal, switched off).
* Forms: `sec:<key>`, `sec:<key>:<sub>`, `thm:`, `prop:`, `lem:`, `cor:`, `def:`, `ex:`, `rem:`, `conj:`, `q:`, `ass:` + `<key>:<name>`; `tab:<key>:<name>`, `fig:<key>:<name>`, `eq:<key>:<name>`. The labels of `CLAIMS.md` are binding.
* **Statuses** (`\status{...}`, printing nothing): proved; proved, given X; computed; known; proof sketch; conjecture; open; refuted; assessment (for a philosophical judgement); combined with ";" and part labels. `\src{<thread> <item>}` on every result, with the thread key and the record's item number. Both macros print nothing and swallow the following space.

---

## 11. Renames of record symbols (for writers)

| record (thread) | symbol there | here | reason |
|---|---|---|---|
| all | $\mathsf U$ (`sfi` development round) | $\Unif$ | one symbol |
| `fundamentals` | $C$, $C^G$ (consistency event) | $\mathrm{Cons}$, $\mathrm{Cons}^G$ | $\mathsf C$ is the binary theoretical relation (§9) |
| `fundamentals` | $g_A(\varphi)$ (grade) | $\mathrm{gr}_A(\varphi)$ | $g$ is a material budget |
| `fundamentals` Thm 5.4 | $\xi_t$ (side randomness) | $u_t$ | $\xi$ is the $\Th(\mathbb N)$ exponent |
| `fundamentals` §6.4, §11.5 | scout F's $H(X)$, $I(X)$ | $\Kenum$, $-\log\mmenum$ | entropy |
| `sfi` | $M_F^C$, $M_A^C$ | $\MFmw$, $M_A^{\mathrm{mw}}$ | $C$ overloaded |
| `sfi` Prop 3.5 | $X(\mathcal C,D)$ | $X(\mathcal C;D)$ | one notation for class-restricted laws |
| `terms` | $M_A(\Theta;D)$ | $\UA(\{T:T\cap\Sent_{\LO}\in\Theta\};D)$ | idem |
| `terms` | $C$ (binary theoretical relation) | $\mathsf C$ | clash with the consistency event |
| `terms` | tags $\eta$ | $\mathrm{tg}$ | $\eta$ is the extractor (§8.2) |
| `terms` | $\iota_f$ | $\mathrm{Dinf}_f$ | $\iota$ is the independent label |
| `logic` | $\delta$ (exponent, Thm 6.1) | $\xi$ | $\delta$ is data precision |
| `logic` §2.7 | flexible formulas $\Phi,\Phi_0,\Phi_1,\Phi_2$ | $\Upsilon,\Upsilon_0,\Upsilon_1,\Upsilon_2$ | $\Phi$ is an explicit theory |
| `logic` (Diag) | $\Theta(z,x)$ | $\vartheta(z,x)$ | $\Theta$ is a Borel set of observational contents |
| `shape` | superscript $X$; $\mathcal C^X$, $\mathcal C^{XY}$; $m_Y$ | superscript $\mathrm{base}$; $\mathcal E^{\rm base}_m$, $\mathcal E_m$; $m_{\rm aux}$ | $X$ is the literal target set; $\mathcal C$ a class of theories; $Y$ a label set |
| NOTATION-draft §6.1 | $V$ (a law) | $\mathcal S$ | $V$ is the universal machine |
| earlier report | $\AI[t,d]$ (derivation size $d$) | $W_A[t,s]$ | $d$ is the word length; both meet in §4 |
| `philosophy` | $\mathcal L_{\rm obs}$ | $\mathcal L_{\rm hel}$ | $\LO$ is the observational vocabulary |
| `philosophy` | $\mathcal E^-$ (numerals) | $\mathrm{Num}^-$ | $\mathcal E_m$ |
| `philosophy` | extractor $g$ | $\eta$ | $g$ material budget |
| `philosophy` | $\xi_b$ (positions) | $\mathbf r_b$ | $\xi$ |
| `philosophy` | $\Psi$ (sampler) | kept, local to App. D | |
| `philosophy` | $\mathrm{Occ}_F$, $\mathrm{Vol}_F$ | $\mathrm{Occ}_{\mathsf F}$, $\mathrm{Vol}_{\mathsf F}$ | $F$ is a function machine |
| `laws` §7 | $R$ (rotation) | $\mathrm{Rot}$ | $R$ is the literal predicate |
| `laws` | $\pi_c$ | $c_{\rm time}$ | $\pi$ is the number |
| `laws` | $\lvert\mathcal A\rvert$ in EP (NOTATION-draft) | $\lVert\mathcal A\rVert$ | the records' form |

---

## 12. Decisions on the requests (synthesis §5.6), with reasons

1. **Fresh atoms** (`fundamentals` Request 5): a defined term, `def:setting:fresh`, with pairwise distinct words (§3.3).
2. **$\Belhat_0=\Bel_\emptyset$** (`fundamentals` Request 6): macro `\Belhat`; $\Bel_0$ stays unnormalised (§4).
3. **$\UA(\Exts T)$ in explicit form** (`fundamentals` Request 1): as in §4; $\Exts(T)$ as a set of indices only inside $\mm(\Exts T)$ (§5).
4. **$\Kenum$, $\mmenum$, $\Uenum$** (`fundamentals` Requests 3, 4): adopted (§5).
5. **`sfi`'s new symbols** $\MFcl$, $\KFcl$, $\KAdec$, $\MAchk t$, $\MAgen t$, $\MFthreecons$, $\IndB$, (S$_{\rm tape}$): adopted. $M_F^C$ → $\MFmw$ (§11). $\mathrm{Ref}_B$, $\mathrm{Thm}_B$ only inside proofs in App. B, if needed.
6. **One symbol for class-restricted laws** (`sfi`, `terms`): $\UA(\mathcal C;D)$ and $X(\mathcal C;D)$ (§4).
7. **$\Win$, $\Gthr$, $\Tick_{k,j}$, $\Kgt_m$** (`logic` §8): adopted, with $\Lot_k$, $\Glot$, $\Bit_k$ (§6).
8. **$\ThT$, "about the named objects", "compatible with the named structure"** (`terms` §12): adopted (§2).
9. **The $C$ clash** (`terms` §12, `fundamentals`): the binary theoretical relation is $\mathsf C$; the consistency event is $\mathrm{Cons}^G$ (§4, §9, §11).
10. **Shape** (`shape` §11): $K_A^{\mathcal R}$/$W_A^{\mathcal R}$ program length; $\Klst^{\mathcal R}$, $\Wlst^{\mathcal R}$, $\KtA^{\mathcal R}$; class superscript $\mathrm{base}$ (renamed from $X$); $\mathcal S$ a law; $\Phi$ explicit theory; $\UP_k$ (parallel rounds), $\FC_k$, $\GE$, $\PS_\infty$; $\ia_k$; $Kt$, $K^q$ global (§1, §7).
11. **Laws** (`laws` §11, `philosophy` §8): $\Exc^Q$, $\Exc^F$, $\Exc^R$; $\lVert\mathcal A\rVert$ in $\EP$; every peakedness names its fit; $\gamma_{\rm ex}$, $\gamma_{\rm si}$, $\beta_e$, $c_G$ added since `prop:laws:peaked` and `prop:laws:errormodel` are in the paper (§8.1).
12. **$\mathrm{Occ}_{\mathsf F}(\delta)$** (`philosophy` §8): adopted, with sans-serif $\mathsf F$ (§8.3).
13. **Encoding (E3)** for conditional questions (`shape` §11 item 5, `laws` §11): fixed in §3.2.
14. **Sentence length for clocks and budgets = symbol count** (`sfi` §12 item 4): §2.
15. **Normalised convention caveat** (`logic` §8 item 5): §3.4.
16. **The derivation-size budget** $d$ of the earlier report is renamed $s$, because $d$ (word length) and the size budget both occur in §4 (Table 1 and the Presburger statements).
17. **The $\Th(\mathbb N)$ exponent** is $\xi$, because $\delta$ is the data precision used throughout §9–§10.
18. **The extractor** is $\eta$, because $g$ is the material budget of §4 and §8.
