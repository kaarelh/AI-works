# Track "imitation": final referee report on the material no referee had read (2026-10-14)

*An adversarial referee of five items of the imitation drafts that no earlier referee read in final form. Each item was re-derived line by line and tested with new, independent, seeded code. Written by the final referee. The verdict is per item: **verified**, **verified with correction** (exact corrected text given), or **not verified** (then it must not be stated as proved).*

* **Items refereed.**
  1. The closeness lemma: `robust` Lemma 4.6, draft `lem:imit:closeness` (`drafts/app-imit.tex`).
  2. The behavioural conclusion: `robust` Theorem 4.7(U)(vi), draft `thm:imit:main`(iv), with (i)–(iii) and the bound on Φ as far as (iv) uses them.
  3. The simplified $B_\beta:=K(\beta\mid h_0,\mu)$ (synthesis `notes-final.md` §2.2).
  4. `robust` Proposition 4.10(a2), draft `prop:imit:limits`(a).
  5. The cell-count statement: the sentence after `prop:imit:limits` in `drafts/imit.tex` and "The cell count" in `app:imit:limits`.
* **Sources read.**
  * The brief `00-brief.md`, in full.
  * The synthesis `notes-final.md`: §0–§2 in full, including every LaTeX block, and §3.1–§3.3.
  * `final-check.md`, in full.
  * `robust/notes-final.md` §4 (Setting 4.1 to Proposition 4.11), in full.
  * `drafts/imit.tex` and `drafts/app-imit.tex`, in full. The imitation lines of `drafts/intro.diff` and `drafts/discussion.diff`, and the environment headers of `drafts/wd-remark.tex` and `drafts/wd-appendix.tex`.
  * Paper 2, at the statements the drafts rest on:
    * `setup.tex`: `def:setup:data`, `def:setup:product`, `def:setup:class`, `def:setup:objectives`, `rem:setup:persample`, `lem:setup:hull`;
    * `app-setup.tex` (F1)–(F5);
    * `kinks.tex`: `def:kink:kinks`, `lem:kink:main`;
    * `recovery.tex`: `def:split:setting` and the Hellinger gap;
    * `app-recovery.tex`: `prop:recovery:beyond`;
    * `parity.tex`: `def:teacher:instance` and the convention $\kappa_g=2\log d+2\log r+\kappa$;
    * `preamble.tex`: `\Hel`.
  * `research/paper-review/DECISIONS.md` §A2 (`\status`/`\src`).
* **Deliberately not read, to keep the code independent:** the scripts and outputs of `robust/checks*`, `robust/referee_code`, `checks/s1_synthesis.py` (only its part (A) parameters were looked up, after q4 was written, to compare $\ell_0$ conventions) and the robust referee reports.
* **Code.** `referee-final_code/q1`–`q5` with saved outputs (§8). Python 3.11.15, NumPy 2.4.6, SymPy 1.14.0. Seeds `default_rng(9101)`–`(9105)`. Every script was re-run in a fresh process; the outputs are byte-identical and stderr is empty.
* **Status tags.**
  * **[verified]**: re-derived here, and consistent with the code.
  * **[verified with correction]**: correct after the stated edit.
  * **[not verified]**.
  * **[proved here]**: a new argument in this report.
  * **[computed: qN(part)]**.
  * **[remark]**.
* **Repository.** No git command was run. Files written: this report, and `referee-final_code/` (five scripts, five outputs). Nothing else was edited: not the drafts, not the records, not `paper-steeper/`, not Paper 1.

---

## 0. Verdicts

| item | verdict | what must change |
|---|---|---|
| 1. closeness lemma, `lem:imit:closeness` | **verified** | Nothing in the statement. Optional: say in the proof that the $+1$ from $-k<\log Z+1$ is absorbed in κ (§1.5). |
| 2. behavioural conclusion, `thm:imit:main`(iv) (with (i)–(iii), Φ) | **verified** (statement, constants, range $a>1$; non-vacuous in both quoted examples) | Three sentences of the running text around the theorem: C1 (the proof idea states the mechanism backwards), C3 (the "informative range" of $c$), C4 ("below $2^{-m}$ the program that models the coupling wins" needs distinct values of ρ, and is false with ties) (§2.8) |
| 3. $B_\beta:=K(\beta\mid h_0,\mu)$ | **verified** | C2: the sentence after the definition must say that the coupling is drawn independently of the person's model and the channel (§3) |
| 4. `prop:imit:limits`(a) | **verified** | Nothing in the statement. C6: in the discussion, "cannot all be copied by any procedure" → "cannot all be copied reliably by any procedure" (§4) |
| 5. the cell count | **verified with correction** | C5: name the hypotheses (|Σ| ≥ 2, distinct values of ρ, $\pi_{\rm u}$ shorter than $\ell_0$); drop "incompressible"; "$H(\rho)=\frac12$" is not attainable with dyadic ρ, so write "$H(\rho)\approx\frac12$" (§5) |

No item is refuted, and no formal statement (lemma, theorem, proposition) needs a change. The six corrections C1–C6 are to running text; §6 gives the exact replacement strings. One positive finding: the factor 2 in front of $I_\beta(\pi)$ in the closeness lemma cannot be halved, so the lemma is tight in that constant (§1.7).

---

## 1. The closeness lemma (`lem:imit:closeness`): verified

The statement checked:
$$\Ex_{x\sim\bar\mu}D_{1/2}(\nu_H\Vert\nu_\pi)\le\bar D(\pi)\le R(\pi)-H(\rho)+\frac{2(I_\beta(\pi)+\delta_\beta+|\Sigma|\log(2^m+1)+E(\pi)+\kappa)}{2^m}$$
for every $\pi\in\Hcl{\times}$ with $R(\pi)<\infty$, where $E(\pi)=2\log(2^{m-1}(H(\rho)+R(\pi))+1)$.

### 1.1 Hölder step [verified]

* **The inequality.** With $p_x:=1/\theta_x$, the generalised Hölder inequality $\sum_b\prod_xg_x(b)\le\prod_x\|g_x\|_{p_x}$ for $g_x:=f_x^{\theta_x}$ is the stated form $\sum_b\prod_xf_x(b)^{\theta_x}\le\prod_x(\sum_bf_x(b))^{\theta_x}$, since $\sum_x\theta_x=1$.
  * Inputs with $\theta_x=0$ contribute the factor $1$, with $0^0:=1$; this is the convention under which $\tilde q_w$ is "the geometric mean over the inputs of cell $w$".
  * $f_x\ge0$ may vanish.
* **The substitution.** With $\theta_x=\mu(x\mid w)$ and $f_x(b)=\sqrt{\rho(b)\nu_\pi(h(x,b)\mid x)}$, $\prod_xf_x(b)^{\theta_x}=\sqrt{\rho(b)}\,\tilde q_w(b)^{1/2}$.
* **Injectivity.** By injectivity of $h(x,\cdot)$, $\nu_H(h(x,b)\mid x)=\rho(b)$ exactly. So $\sum_b\sqrt{\rho(b)\nu_\pi(h(x,b)\mid x)}=\sum_y\sqrt{\nu_H(y\mid x)\nu_\pi(y\mid x)}$, the labels outside $h(x,\Sigma)$ contributing $0$.
* **Averaging.** $-2\log$ reverses the inequality cell by cell. Averaging over uniform $w$ gives $\Ex_{x\sim\bar\mu}$, because $\bar\mu=2^{-m}\sum_w\mu(\cdot\mid w)$.
* **Code** [computed: q1(A),(B)].
  * 20,000 random Hölder instances, with zeros in $f$ and θ: $\max(\text{LHS}-\text{RHS})=0$.
  * 5,004 programs on 60 random instances (feature and latent-cause channels, $|\Sigma|\in\{2,3\}$, $|Y|\ge|\Sigma|$). The kernels are probabilities, sub-probabilities, kernels with zeros, near-person kernels, soft partial memorisers, the data kernel $P^*$, mixtures, and kernels with mass outside $h(x,\Sigma)$. Results:
    * $\max(\Ex D_{1/2}-\bar D)=6.7\cdot10^{-16}$;
    * cell by cell, $1.1\cdot10^{-15}$ (rounding).

### 1.2 The semimeasure [verified]

* **Its mass.** $\tilde q_w\le q_w$ is the weighted AM–GM inequality. $\sum_bq_w(b)\le\sum_x\mu(x\mid w)\sum_y\nu_\pi(y\mid x)\le1$ uses injectivity again. $Z_w\le\sqrt{\sum_b\rho(b)}\sqrt{\sum_b\tilde q_w(b)}\le1$ is Cauchy–Schwarz. $Q$ is a product over cells, so its total mass on $\Sigma^W$ is $\prod_wZ_w$.
* **Lower semicomputability from $(\pi,h_0,\mu)$.** $x\mapsto x^\theta$ is continuous and nondecreasing on $[0,1]$. So increasing rational lower approximations of $\nu_\pi$ give increasing lower approximations of each $\tilde q_w(b)$, converging to it. Rational lower bounds of the irrational powers are computable.
* **Code** [computed: q1(B)]. Brute force over **all** $|\Sigma|^{2^m}$ maps (up to $3^8=6561$), for each of the 5,004 programs:
  * mass $\le1.000000000000000$, with $|$mass$-\prod_wZ_w|\le6.7\cdot10^{-16}$;
  * $\max(\tilde q_w-q_w)=2.2\cdot10^{-16}$;
  * $\max_w\sum_bq_w=1$ and $\max Z_w=1$ (both attained, at the person).

### 1.3 Normalising: trimming and the conditional coding theorem with the extra condition $k$ [verified]

* **$k$ does not depend on β.** $Z$, and hence $k=\lfloor-\log Z\rfloor$, are functions of $(\pi,h_0,\mu)$ alone: $Z=\prod_w\sum_b\sqrt{\rho(b)\tilde q_w(b)}$ involves no coupling. So conditioning on $k$ is legitimate; it would be harmless even if $k$ depended on β, since $K(k)$ is paid unconditionally.
* **Trimming.** (F2) needs one fixed program that lower-semicomputes a semimeasure $Q_z$ for **every** value $z=(h_0,\pi,\mu,k')$ of the condition, including wrong $k'$ and malformed $h_0$ (non-injective $h$, where $\sum_bq_w>1$ is possible; §1.6).
  * The trimming does this: at each stage the finitely many rational lower approximations of $2^{k'}Q$ on the finite set $\Sigma^W$ are summed, and the output is frozen once the sum would exceed $1$.
  * For the true $k$, $2^kZ\le1$, so the sum never exceeds 1: nothing is frozen and the limit is $2^kQ$.
  * So $K(\beta\mid h_0,\pi,\mu,k)\le-\log Q(\beta)-k+\kappa$ with κ independent of every condition.
* **Removing $k$.** (F3) relative to $z$ gives $K(\beta\mid z)\le K(k)+K(\beta\mid z,k)+\kappa$, and (F5) gives $K(k)\le2\log(k+1)+\kappa$. Finally $k>-\log Z-1$, so $-k<\log Z+1$.
* **Code** [computed: q1(D)]. The trimmed enumeration was simulated on a sub-probability kernel with $Z=0.0700$, $k=3$:
  * for the true $k$, never frozen; output mass $0.560251=2^kZ$;
  * for $k+1$, frozen at stage 7 with mass $0.8445<1$;
  * for $k+3$, frozen at stage 4 with mass $0.2480<1$.
  * The lower approximations were checked to be monotone.

### 1.4 Evaluating [verified]

* **Exact type.** $\sum_w\log(1/\rho(\beta(w)))=\sum_b\rho(b)2^m\log(1/\rho(b))=2^mH(\rho)$ uses exact type.
* **The risk.** $\sum_w-\log\tilde q_w(\beta(w))=\sum_w\sum_x\mu(x\mid w)(-\log\nu_\pi(h(x,\beta(w))\mid x))=2^mR(\pi)$ uses uniform $w$ and the definition of $R$.
* **The two identities.** Hence $-\log Q(\beta)=2^{m-1}(H+R)$. And $\log Z=\sum_w\log\mathrm{BC}(\rho,\tilde q_w)=-2^{m-1}\bar D$, because $D_{1/2}=-2\log(1-\Hel)$ with $\Hel=1-\sum\sqrt{PQ}$ (Paper 2's definition, also for sub-probabilities).
* **The bound on $k$.** $Q(\beta)\le Z$, so $k\le-\log Z\le-\log Q(\beta)$, and $2\log(k+1)\le E(\pi)$.
* **Code** [computed: q1(B),(E)]. Both identities hold to relative error $4.4\cdot10^{-16}$. $2\log(k+1)\le E(\pi)$ holds on $2\cdot10^5$ draws.

### 1.5 Lower bound and division [verified]

* **The lower bound.** $K(\beta\mid h_0,\pi,\mu)=B_\beta-I_\beta(\pi)=L_\beta-\delta_\beta-I_\beta(\pi)$ by the definitions. The type-class bound $L_\beta\ge2^mH-|\Sigma|\log(2^m+1)$ was confirmed on 20,000 random exact types, with slack at least $1.585$ bits [computed: q4(B)].
* **The division** [computed: q4(A1), SymPy]. Combining with §1.3 and §1.4 gives exactly
  $$\bar D\le R-H+2\big(I_\beta+\delta_\beta+|\Sigma|\log(2^m+1)+E(\pi)+\kappa+1\big)/2^m .$$
  The stated form absorbs the $+1$ in κ, which is allowed by Paper 2's convention that κ "may differ between occurrences". The draft's proof says only "divide by $2^{m-1}$". **Optional edit:** "… and divide by $2^{m-1}$; the $1$ is absorbed in κ."

### 1.6 Hidden hypotheses [verified: all stated in `def:imit:setting`]

| hypothesis | where the proof uses it | stated? | what fails without it |
|---|---|---|---|
| exact type of β | §1.4, $\sum_w\log1/\rho(\beta(w))=2^mH$; also "every copy has $R=H(\rho)$" | yes, (c) | moving one cell off the type gives an error of $1.29$ bits in the identity [computed: q1(C1)] |
| $h(x,\cdot)$ injective | §1.1 ($\nu_H(h(x,b)\mid x)=\rho(b)$) and §1.2 ($\sum_bq_w\le1$) | yes, (b) | with two coins on one label: $\sum_bq_w$ up to $1.97$, and $\Ex D_{1/2}-\bar D$ up to $+0.83$, so the first inequality fails [computed: q1(C2)] |
| uniform cells | §1.4 (the risk is the uniform average over cells); exact type is a uniform count | yes, (c); unequal masses are `q:imit:open`(b) | the evaluation identity |
| finite Σ, finitely supported μ with rational masses | finite $\Sigma^W$ (trimming), the type-class bound, $\mu$ and $h_0$ as finite objects for conditioning | yes, (a)–(c) | trimming and conditioning |
| $R(\pi)<\infty$ | $Q(\beta)>0$ | yes | — (the theorem supplies it) |
| κ | (F2) for one fixed program over all conditions; (F3), (F5) | yes, by trimming | — |
| $\rho(b)>0$ | the person's support, exact type | yes, "positive integer" | — |

### 1.7 Counting form, exhaustively, and tightness of the factor 2 [verified; computed: q2]

* **The counting form.** Replacing the universal machine by an explicit prefix class $\mathcal C$ with Kraft sum $k_{\mathcal C}$, the proof gives the following ($Q/Z$ is a probability that does not depend on β′):
  $$\Pr_{\beta'\sim\mathrm{Unif}(T)}\big[\exists\pi:\bar D(\pi)\ge H+R_{\beta'}(\pi)-2(L-\ell(\pi)-j)/2^m\big]\le k_{\mathcal C}2^{-j}.$$
  The coding lemma's counting form is the same with the event $2^mR_{\beta'}\le L-\ell-j$.
* **The three instances**, exhaustively over the type class:

  | instance | channel | cells, Σ | couplings | programs, Kraft sum | event frequencies |
  |---|---|---|---|---|---|
  | F | feature | 16 cells, three coins | 160,160 | 1,276; $k_{\mathcal C}=0.270$ | at most $2.0\cdot10^{-4}$, only on the 32 structured couplings; $0$ from $j=3$ (closeness) and $j=5$ (coding) |
  | Lt | latent cause | 8 cells | 420 | 572, including the soft memoriser of every coupling | 0 at every $j$ |
  | F2 | feature | 16 cells, two coins | 1,820 | 1,852, including the soft memoriser of every coupling | 0 at every $j$ |

  Both counting forms hold at every $j$ in all three instances.
* **Tightness.** Halving the information term, the counting form of "$\bar D\le R-H+(I_\beta+2(\delta_\beta+\dots))/2^m$", is false.
  * In F2 its event has frequency $1.000$ for every $j\le2$, against the bound $0.92$ to $0.058$.
  * In F it exceeds the bound at $j=11,12$.

  So the factor 2 in front of $I_\beta(\pi)$ is necessary. A memoriser of cells carrying $s$ bits of the coupling has $\bar D\approx s/2^m$, $R-H\approx-s/2^m$ and $I_\beta\approx s$, which meets the lemma with equality in the leading terms.

**Verdict on item 1: verified.**

---

## 2. The behavioural conclusion, `thm:imit:main`(iv): verified (statement); three running-text corrections

### 2.1 What (iv) takes from (i)–(iii) [verified]

* **The right line.** $B_\beta\le\ell(\pi)+K(\beta\mid h_0,\pi,\mu)+\kappa\le\ell(\pi)+2^mR(\pi)+\kappa$, by (F3) relative to $(h_0,\mu)$, (F1) and `lem:imit:coding`. With $B_\beta=L_\beta-\delta_\beta$ and the type-class bound this gives
  $$R(\pi)\ge H-G/2^m-2^{-m}(\ell(\pi)-\ell_0).$$
* **(i) and the left side of (ii)**, re-derived directly without the kink lemma. Write $\tau=2^{-m}$ and $g=G\tau$. From $J_c(\pi)\le J_c(\pi_H)+\epsilon$ and the line, $(c-\tau)(\ell-\ell_0)\le g+\epsilon$. If $\ell<\ell_0$, the line gives $R\ge H-g$ directly. The SymPy check [q4(A2)] confirms the two substitutions:
  * $(g+\epsilon)/(c-\tau)=(G+2^m\epsilon)/(a-1)$;
  * $(cg+\tau\epsilon)/(c-\tau)=(aG+2^m\epsilon)/((a-1)2^m)$.
* **The kink lemma.** The parameters $\mathcal M$ = the whole class, $\mathcal N=\emptyset$, $\ell_{\mathcal M}=0$, $\tau=2^{-m}<c$ and $g\ge0$ meet the hypotheses of `lem:kink:main`(i),(ii),(iv) as stated in `kinks.tex`.
  * $g\ge0$ because $\delta_\beta\ge-1-\kappa$ and $|\Sigma|\log(2^m+1)\ge\log3>1$.
* **Right side of (ii).** $R(\pi)\le\Phi+\epsilon-c\ell(\pi)\le c\ell_0+H+\epsilon$, which is trivial from $\ell\ge0$. The draft's sharpening over `robust`'s $c(\Gamma+\kappa)+\epsilon$ is correct.
* **Φ.** $\Phi(c)\ge H-g+\tau\ell_0$, so $J_c(\pi_H)\le\Phi+G/2^m+(c-2^{-m})\ell_0\le\Phi+G/2^m+c\ell_0$ [q4(A2): the difference is $\ell_0/2^m\ge0$].
* **(iii).** $I_\beta=B_\beta-K(\beta\mid h_0,\pi,\mu)\le\ell(\pi)+\kappa$, with (i).

### 2.2 The insertion [verified; computed: q4(A3)]

* **The bracket.** Inserting (ii) (also for $E(\pi)\le E$, as $E(\pi)$ increases with $R$) and (iii) into the lemma gives
  $$\bar D\le c\ell_0+\epsilon+\tfrac2{2^m}\big[\ell_0+\tfrac{G+2^m\epsilon}{a-1}+\delta_\beta+|\Sigma|\log(2^m+1)+E+2\kappa\big].$$
* **The exact form.** SymPy: this equals $c\ell_0+\frac{2a}{a-1}\frac G{2^m}+\frac{2(E+\kappa)}{2^m}+\frac{a+1}{a-1}\epsilon$ exactly.
* **Against the stated bound.** The stated bound minus this form is $2^{1-m}(E+\kappa)/(a-1)\ge0$.
* **The Hellinger form.** $\Hel\le\frac{\ln2}2D_{1/2}$ holds on 20,000 pairs, sub-probabilities included [q1(E)].
* **The bound on $E$.** $E\le2m+2\log(2H+c\ell_0+\epsilon+1)$ holds on $2\cdot10^5$ draws, with slack at least 2 [q1(E)].

### 2.3 Constants and the range of $c$ [verified]

* **Range.** (iv) holds for **every** $a>1$ and $\epsilon\ge0$. $a>1$ is exactly the condition $c>\tau$ that the kink lemma needs. Nothing is claimed at $a\le1$, correctly: below about $2^{-m}$ the memoriser wins when the values of ρ are distinct (last part of the theorem).
* **Constants.**
  * The coefficients $\frac{2a}{a-1}$ and $\frac{a+1}{a-1}$ are as derived.
  * Both $\kappa$s are legitimate: one from (iii), one from the lemma.
  * $G$ is as defined.
* **When the bound is informative.** It needs $c\ell_0\ll H(\rho)$, $(\ell_0+\delta_\beta+|\Sigma|m+m+\kappa)\ll2^mH(\rho)$, $a$ bounded away from 1, and $\epsilon\ll H$.

### 2.4 Non-vacuity in the quoted examples [verified; computed: q4(C),(D)]

* **The best predictor's divergence.** $\Ex_xD_{1/2}(\nu_H\Vert P^*)=H(\rho)$ in the feature case: exact on 300 random instances with several inputs per cell, error $1.3\cdot10^{-15}$. This is the right scale for comparison.
* **The quoted numbers** ($m=20$, κ = 0, $\delta_\beta=\epsilon=0$):

  | person | $\ell_0$ | $c$ | bound (iv) | $H(\rho)$ | ratio |
  |---|---|---|---|---|---|
  | fair coin, $h(x,b)=b$ | $a_\rho=53.95$ (draft: $<54$) | $2^{-19}$ | $6.139\cdot10^{-4}$ (draft $6.2\cdot10^{-4}$) | 1 | $6\cdot10^{-4}$ |
  | parity, $d=100$, $p=2^{-10}$ | $119.93$ (draft $<120$) | $2^{-19}$ | $9.421\cdot10^{-4}$ (draft $9.5\cdot10^{-4}$) | $0.011174$ | $0.084$ |
  | parity | $119.93$ | $10^{-4}$ | $1.2356\cdot10^{-2}$ | $0.011174$ | $>1$, as the draft says |

* **The parity person's $\ell_0$.** $119.93=d+2\log d+2\log10$ is Paper 2's convention $\kappa_g=2\log d+2\log r+\kappa$ (`parity.tex`). With the doubling code $2\log(j+1)$ it is $120.24$, and the bound is $9.438\cdot10^{-4}$, still below the quoted $9.5\cdot10^{-4}$.
* **The fair-coin person's $\ell_0$.** The fair-coin person is the uniform kernel, which Paper 2 gives length at most κ. So $\ell_0\le54$ is conservative, and the bound is increasing in $\ell_0$.
* **Robustness to κ and $\delta_\beta$** (ratio to $H(\rho)$ at $c=2^{-19}$):

  | κ | $\delta_\beta$ | fair coin | parity |
  |---|---|---|---|
  | 0 | 0 | 0.0006 | 0.084 |
  | 30 | 20 | 0.0009 | 0.112 |
  | 300 | 0 | 0.0029 | 0.289 |
  | 1000 | 20 | 0.0083 | 0.774 |

  The bound stays below $H$ for machine constants up to about a thousand bits.
* **The informative range of $c$** (κ = 0, for the parity person):
  * the bound is below $H$ exactly for $c\in[9.86\cdot10^{-7},9.01\cdot10^{-5}]$ (with $2^{-20}=9.54\cdot10^{-7}$ and $H/\ell_0=9.32\cdot10^{-5}$);
  * it is below $H/2$ only for $c\in[1.02\cdot10^{-6},4.35\cdot10^{-5}]$.

  So $H(\rho)/\ell_0$ is the end of the range where the bound is below $H$, not of the range where it is small on that scale (C3).

### 2.5 End-to-end machine-free check of (i), (ii), (iv) and Φ [computed: q3]

The universal machine was replaced by explicit prefix classes. For each coupling $j^*(\beta')$ is the least $j$ at which neither counting event of §1.7 occurs, and $G:=\ell_0+j^*+(2^mH-L)$. The draft's proof then implies (i), (ii), (iv) and the Φ bound for every ε-near-optimal program. These implications were checked on every coupling, at $a\in\{1.25,1.5,2,4,16,64\}$ and $\epsilon\in\{0,10^{-3}\}$.

* **(A) Fixed classes.**
  * The cases: $m=4$ exhaustive (1,820 couplings); $m=8$ with 5,000 sampled couplings; $m=8$ with three coins (224, 24, 8) and 3,000 sampled couplings.
  * **0 violations** of any implication.
  * $\Pr[j^*>j]$ is far below $2k_{\mathcal C}2^{-j}$; in fact $j^*<0$ for every coupling.
  * At $m=8$ the bound (iv) is $0.024$–$0.31\,H(\rho)$ for $a=1.25$–$16$, and the minimiser is the person in every coupling.
  * At $m=4$ and $a=4$ the uniform kernel wins. This is the predicted upper end $(\log|Y|-H)/(\ell_0-\ell_{\rm u})=0.19$.
* **(B) Adversarial programs.** Coupling-aware programs were added per coupling: partial memorisers priced at a quarter to one bit per memorised cell, mixtures of the person and the memoriser, and per-cell tilted coin laws. Still **0 violations**. These programs make $j^*$ large (up to 136 at $m=8$), and the bound becomes vacuous (above $H$), as it must when the coupling is cheap relative to the class.

### 2.6 Hidden hypotheses of the theorem [verified]

Those of §1.6, plus:
* a copy exists in $\Hcl{\times}$: $\nu_H$ is a computable rational kernel on $\supp\mu$;
* the data are i.i.d. from $\bar\mu\otimes P^*$.

The last sentence of the theorem (the memoriser) states its own extra hypotheses: feature case, $|\Sigma|\ge2$, distinct values of ρ. Its threshold algebra was checked symbolically [q4(A4)].

### 2.7 The sentence on $cn$-MAPs [verified as a citation]

* `prop:recovery:beyond`(c) applies to $\Hcl{\times}$ (a class as in `def:split:setting`) with the sampler $P^*$, a probability kernel. Some program has finite $J_c$ (the person).
* It puts every $cn$-MAP in $\arg\min J_c$ for all large $n$, almost surely. So (i)–(iv) hold there with $\epsilon=0$.
* Not re-proved here.

### 2.8 Running-text corrections around the theorem

* **C1 [not verified as written; corrected].** The proof idea says the per-cell geometric means "define a semimeasure on couplings whose value at β is too small unless the divergence is small or the program predicts **better** or knows more about β".
  * The mechanism is the reverse. The normalised value is $Q(\beta)/Z=2^{-2^{m-1}(H+R-\bar D)}$.
  * Incompressibility caps it at about $2^{-(L_\beta-I_\beta)}$. So it would be too **large** unless $\bar D$ is small, the program predicts **worse** ($R$ larger), or $I_\beta$ is large.
  * Predicting better makes the contradiction stronger, not weaker. The lemma has $+(R-H)$.
  * The `robust` record says it correctly: "every bit of divergence … must be paid for by worse prediction or by information about β".
* **C3 [imprecise; corrected].** "For every $c$ between the reuse factor $2^{-m}$ and about $H(\rho)/\ell_0$ … every near-optimal hypothesis is close to the person in behaviour, on the scale $H(\rho)$". At $c$ near $H/\ell_0$ the term $c\ell_0$ alone is about $H$ (§2.4). Closeness on the scale $H$ needs $c$ **well below** $H(\rho)/\ell_0$. The sentence that follows ("above about $H(\rho)/\ell_0$ the bound exceeds $H(\rho)$") is correct.
* **C4 [false as written; corrected].** "Below $2^{-m}$ the program that models the coupling wins". This is proved only when the values of ρ are distinct (the theorem's last part), and then only below a threshold slightly under $2^{-m}$. With ties it can fail [proved here]:
  * **The instance.** Feature case; $k\ge3$ inputs per cell with $\mu(\cdot\mid w)$ uniform on them; $\Sigma=Y=\{0,1,2,3\}$; ρ uniform ($m\ge2$). $h(x,\cdot)$ is a uniformly random permutation for each input, drawn independently of β. This is an instance of `def:imit:setting`.
  * **The person.** $\nu_H$ is the uniform kernel, so $\ell_0\le\kappa$. The data are deterministic: $y=T(x):=h(x,\beta(w))$, and $T$ is uniform on $Y^{\supp\mu}$.
  * **The coding step.** The coding argument with the inputs as cells ($Q(T'):=\prod_x\nu_\pi(T'(x)\mid x)$) gives $\ell(\pi)+k2^mR(\pi)\ge K(T\mid\mu)-\kappa\ge2k2^m-j-\kappa$, with probability at least $1-2^{-j}$.
  * **The conclusion.** This is a right line of slope $2^{-m}/k$, not $2^{-m}$. For $c=a'2^{-m}/k$ with $a'>1$, compare with a copy ($J_c\le c\kappa+2$). Every program at least as good as the copies has length at most $((a'+1)\kappa+j)/(a'-1)$, and risk at least $2-a'(2\kappa+j)/((a'-1)k2^m)=2-c(2\kappa+j)/(a'-1)$.
  * A program that models the coupling has risk near $0$ and length at least $2k2^m-j-\kappa$. So for every $c\in(2\cdot2^{-m}/k,\,2^{-m})$ it is worse than the copies, and does not win. At $m=20$, $k=16$, it loses down to about $c=2^{-m}/k\approx6\cdot10^{-8}$, far below $2^{-20}=9.5\cdot10^{-7}$.
  * **What goes wrong.** With ties, a program that models the coupling must also describe the person's labelling of tied coins, input by input, which no copy carries.
  * The theorem itself is unaffected: it claims nothing below $2^{-m}$.

**Verdict on item 2: verified** (statement, constants, the range $a>1$, non-vacuity). C1, C3 and C4 must be applied to the running text.

---

## 3. $B_\beta:=K(\beta\mid h_0,\mu)$: verified, with one correction to the text

* **The three facts** are each re-derived [verified].
  1. $K(\beta\mid h_0,\pi,\mu)=B_\beta-I_\beta(\pi)$ is the definition of $I_\beta$.
  2. $B_\beta\le K(\pi\mid h_0,\mu)+K(\beta\mid h_0,\pi,\mu)+\kappa\le\ell(\pi)+K(\beta\mid h_0,\pi,\mu)+\kappa$, by (F3) relative to $(h_0,\mu)$ and (F1).
  3. $B_\beta=L_\beta-\delta_\beta$ by definition. For β uniform on its type class **conditionally on $(h_0,\mu)$**: the event $\delta_\beta>j$ is $K(\beta\mid h_0,\mu)<L_\beta-j$. Distinct couplings have distinct shortest programs. A prefix-free set has fewer than $2^{x}$ members shorter than $x$, for any real $x$. So $\Pr<2^{L_\beta-j}/2^{L_\beta}=2^{-j}$.
     * Also $\delta_\beta\ge-1-\kappa$: given $(h_0,\mu)$, the type class is computable and β is its index, of length $\lceil L_\beta\rceil$.
* **These are the only uses.** Fact 1 is used in §1.5. Fact 2 is used for the right line and for (iii). Fact 3 is used for $G$ and the type-class bound.
  * No symmetry of information is used anywhere in case (U) or in the lemma.
  * The old condition $K(h_0\mid\mu)$ entered only `robust` Lemma 4.5(a),(e), case (L), which the drafts do not use.
* **The simplification can only help, up to κ.** $K(\beta\mid h_0,\mu)\ge K(\beta\mid h_0,\mu,K(h_0\mid\mu))-\kappa$. So the new $\delta_\beta$ is at most the old one plus κ, and the theorem is at least as strong.
* **C2 [hidden hypothesis; corrected].** The draft says, after the definition, "$\Prob[\delta_\beta>j]<2^{-j}$ for a coupling drawn uniformly from its type class". This is true only if the coupling is drawn **independently of the person's model and the channel**.
  * The synthesis (§2.2) and `robust` Setting 4.1 both say so; the draft dropped it.
  * **Counterexample.** Feature case, binary. A person chosen after the coupling with $h(x,b)=b\oplus\beta(w)$ has $K(\beta\mid h_0,\mu)\le\kappa$, so $\delta_\beta\approx L_\beta$.
  * This is exactly the kind of person who "responds to the cell", the entanglement of `prop:imit:limits`(b). There the independence is stated and correct.

**Verdict on item 3: verified**, with C2 in the text.

---

## 4. `prop:imit:limits`(a): verified

* **The bound** [verified]. In all worlds the sample $h_n$ has one law, so $\Psi(h_n)$, with independent randomness, has one law. A program in $\mathcal E(\nu_i)\cap\mathcal E(\nu_j)$ equals both kernels on $\supp\mu_i=\supp\mu_j=\supp\bar\mu$: the input marginal is part of the shared data law. That contradicts the hypothesis that the kernels differ somewhere on the finite support. So the events are disjoint, and their probabilities under one law sum to at most 1.
* **The twin** [verified].
  * **The world.** $\Sigma'=\{\ast\}$, $\rho'(\ast)=1$ ($\rho'(\ast)2^m=2^m$ is a positive integer), the constant coupling (exact type), $h'(x,\ast)=h(x,\beta(w))$ with $w$ the first $m$ bits of $x$. This is a world of `def:imit:setting`.
  * **Same data law.** In the feature case $w_i$ is the first $m$ bits of $x_i$, so the data law is identical.
  * **Different persons.** Its person is $P^*$, deterministic. $\nu_H(\cdot\mid x)$ has $|\Sigma|\ge2$ positive masses at every input. So the kernels differ at every input. With $|\Sigma|=1$ the twin is the person itself, so the hypothesis $|\Sigma|\ge2$ (final-check F4) is needed.
* **Code** [computed: q5].
  * **(A)** 200 random feature-case worlds (several inputs per cell, random rational channel), in exact rational arithmetic: the data laws are equal in 200/200, and the kernels differ at every input in 130/130 worlds with $|\Sigma|\ge2$.
  * **(B)** Five worlds sharing one deterministic data table, with pairwise different persons. Over all 2,401 deterministic procedures at $n=1$, and 3,000 random ones at $n=2,3$, the sum is at most 1, with maximum exactly 1. So the bound is tight.
  * **(C)** The ties example behind final-check F5 is confirmed: equal kernels, different data laws.
  * **(D)** In 200/200 random latent-cause worlds $P^*$ has input-dependent mass profiles, so no person of the setting has kernel $P^*$. The twin is a feature-case construction, as the draft states.
* **C6 [imprecise; corrected; in `drafts/discussion.diff`, gap (2)].** "Worlds with one data law cannot all be copied by any procedure". A randomised procedure can copy each of $N$ such worlds with probability $1/N>0$. What (a) proves is that they cannot all be copied **reliably**. This matches the wording already adopted for (b) in final-check F6b and F9.

**Verdict on item 4: verified**, with C6 in the discussion.

---

## 5. The cell count: verified with correction

* **The appendix argument** [verified].
  * The copies are not minimisers for $c<H/(\lceil L_\beta\rceil+a_\rho+\kappa)$, because the memoriser has strictly smaller $J_c$.
  * For $c\ge(\log|Y|-H)/(\ell_0-\ell(\pi_{\rm u}))$, $J_c(\pi_{\rm u})\le J_c(\pi_H)$. Since $\pi_{\rm u}$ is not a copy, the copies are not the only minimisers.
  * So a $c$ at which the copies are the only minimisers needs $H(\ell_0-\ell_{\rm u})<(\log|Y|-H)(\lceil L_\beta\rceil+a_\rho+\kappa)$.
  * With $\lceil L_\beta\rceil\le L_\beta+1\le2^mH+1$, and dividing by $H(\log|Y|-H)>0$ (positive since distinct values give $H<\log|\Sigma|\le\log|Y|$), this gives the stated inequality.
* **Code** [computed: q4(A5),(E)].
  * SymPy confirms the rearrangement.
  * In $10^5$ random instances, every non-empty window satisfies the stated necessary condition.
  * The example: $\ell_0=10^6$, $H=\frac12$, $|Y|=2$, $\ell_{\rm u}=0$, κ = 0. The required $2^m$ is at least $1.99916\cdot10^6$ for every $m\le200$ ($a_\rho$ depends on $m$). So "more than $1.99\cdot10^6$" is right.
* **C5 [corrected].** Three problems in the main-text sentence:
  1. **Hypotheses.** It names only "the feature case". The memoriser and the comparison also need $|\Sigma|\ge2$, distinct values of ρ, and $\pi_{\rm u}$ shorter than $\ell_0$. The appendix states the first two; the third is implicit in "the comparison with $\pi_{\rm u}$ in (c)".
  2. **"Incompressible cells".** The necessary condition counts cells and holds for every coupling. A compressible coupling only makes the memoriser cheaper, and is excluded separately by (c). "Incompressible" is not part of what the count shows.
  3. **$H(\rho)=\frac12$.** It is not attainable: $\rho(b)2^m\in\mathbb Z$ with $|\Sigma|=2$ forces ρ dyadic, and $H(p)=\frac12$ has no dyadic solution. The closest at $m=21$ is $H=0.499999776$ [q4(E)]. The number is unaffected.

**Verdict on item 5: verified with correction** C5.

---

## 6. Exact corrections (replacement strings)

All six are in running text; no label, statement, `\status` or `\src` changes. Old strings are quoted from the current `drafts/` files.

**C1** (`drafts/imit.tex`, proof idea after `thm:imit:main`)
* old: `which define a semimeasure on couplings whose value at $\beta$ is too small unless the divergence is small or the program predicts better or knows more about $\beta$.`
* new: `which define a semimeasure on couplings; normalised, it would give $\beta$ a code shorter than the coupling's incompressibility allows, unless the divergence is small, the program predicts worse than the person, or it knows more about $\beta$.`

**C2** (`drafts/imit.tex`, paragraph after `def:imit:setting`)
* old: `and $\Prob[\delta_\beta>j]<2^{-j}$ for a coupling drawn uniformly from its type class.`
* new: `and $\Prob[\delta_\beta>j]<2^{-j}$ for a coupling drawn uniformly from its type class, independently of the person's model and the channel.`

**C3** (`drafts/imit.tex`, paragraph after the proof idea)
* old: `for every $c$ between the reuse factor $2^{-m}$ and about $H(\rho)/\ell_0$, with $a$ bounded away from $1$,`
* new: `for every $c$ above the reuse factor $2^{-m}$, with $a$ bounded away from $1$, and well below $H(\rho)/\ell_0$,`

**C4** (`drafts/imit.tex`, same paragraph)
* old: `Below $2^{-m}$ the program that models the coupling wins;`
* new: `If the values of $\rho$ are distinct, the program that models the coupling wins below about $2^{-m}$ (with ties it must also describe which label each tied coin gives, and the copies can win far below $2^{-m}$);`

**C5** (`drafts/imit.tex`, last paragraph before `q:imit:open`)
* old: `In the feature case the same comparison shows that a window for copies needs`
* new: `In the feature case with $|\Sigma|\ge2$ and the values of $\rho$ distinct, the same comparison shows that a window for copies needs`
* old: `a person of $10^6$ bits with $H(\rho)=\frac12$ and $|Y|=2$ needs more than $1.99\cdot10^6$ incompressible cells.`
* new: `a person of $10^6$ bits with $H(\rho)\approx\frac12$ and $|Y|=2$ needs more than $1.99\cdot10^6$ cells, whatever the coupling.`

**C6** (`drafts/discussion.diff`, the added paragraph "What the toy cases leave open", gap (2))
* old: `worlds with one data law cannot all be copied by any procedure`
* new: `worlds with one data law cannot all be copied reliably by any procedure`

**Optional** (`drafts/app-imit.tex`, end of the proof of `lem:imit:closeness`)
* old: `Combine with the two previous steps and divide by $2^{m-1}$.`
* new: `Combine with the two previous steps and divide by $2^{m-1}$; the remaining $2/2^m$ is absorbed in $\kappa$.`

The same strings occur in the LaTeX block of `notes-final.md` §2.5, which is byte-identical to `drafts/imit.tex`. They should be edited there too, or the block replaced.

---

## 7. Further observations (outside the five items; no verdict requested)

* `\status`/`\src` are present on every theorem-like environment of `imit.tex`, `app-imit.tex`, `wd-remark.tex` and `wd-appendix.tex`. Definitions carry `\src` only, as do Paper 2's other definitions (for example `def:setup:class`). No new label renames an existing one.
* The visible text of `imit.tex` and `app-imit.tex` refers to no notes. The author's notes appear only in `%` comments and `\src`, which print nothing (DECISIONS §A2.4). It uses the "we" voice where it uses a voice.
* $J_c(\pi_H)\le\Phi(c)+G/2^m+c\ell_0$ could be sharpened to $+(c-2^{-m})\ell_0$, and $E\le2m+2\log(\cdot)$ to $2m-2+2\log(\cdot)$. Neither is needed.

---

## 8. Code

| script | what it checks | seed | time | result |
|---|---|---|---|---|
| `q1_closeness_steps.py` | Hölder; AM–GM; $\sum q_w\le1$; Cauchy–Schwarz; brute-force mass of $Q$; the two identities; failure without exact type or injectivity; trimming; scalar inequalities | 9101 | 12 s | all steps hold; both hidden hypotheses needed |
| `q2_counting_forms.py` | counting forms of the coding and closeness lemmas, exhaustively over type classes of 160,160, 420 and 1,820 couplings; the halved-information variant | 9102 | 22 s | both forms hold at every $j$; the halved variant fails (the factor 2 is necessary) |
| `q3_theorem_machine_free.py` | (i), (ii), (iv) and Φ for all near-optimal programs, from $j^*$, with fixed and adversarial classes | 9103 | 23 s | 0 violations; bound informative at $m=8$ |
| `q4_numbers_algebra.py` | SymPy for every rearrangement; type-class bounds; $\Ex D(\nu_H\Vert P^*)=H$; the quoted numbers and their κ, $\delta_\beta$ sensitivity; the informative range; the cell-count example; dyadic $H=\frac12$ | 9104 | 44 s | all identities exact; numbers reproduced |
| `q5_one_data_law.py` | the twin (exact rationals); the sum over worlds for all or random procedures; ties; latent-cause twin | 9105 | 1 s | verified; the bound is tight (maximum 1) |

SHA-256 prefixes:

| file | prefix |
|---|---|
| `q1_closeness_steps.py` | `67ab993122eca8e3` |
| `q2_counting_forms.py` | `05a95c4a9ea2ad73` |
| `q3_theorem_machine_free.py` | `d2cec8d3760dfc34` |
| `q4_numbers_algebra.py` | `52575defb07c2d3f` |
| `q5_one_data_law.py` | `cc481b92c561c409` |
| `q1_closeness_steps.out` | `1ed7894667b24363` |
| `q2_counting_forms.out` | `576a84d7c4a5301a` |
| `q3_theorem_machine_free.out` | `8e1e242bac2f981c` |
| `q4_numbers_algebra.out` | `0bdf822bda92ea5e` |
| `q5_one_data_law.out` | `9f51e76781839796` |

---

## Verification log

* **2026-10-14, reading.** As listed under "Sources read". Every Paper 2 statement the drafts cite for these five items was read at its label. The hypotheses of `lem:kink:main`(i),(ii),(iv) were matched against the appendix proof of `thm:imit:main`.
* **By hand.** Each step of `lem:imit:closeness` (§1.1–§1.5), the inputs and insertion for (iv) (§2.1–§2.2), the three facts behind $B_\beta$ (§3), `prop:imit:limits`(a) and its twin (§4), and the cell-count derivation (§5). Two arguments are new here:
  * the counterexample to the unqualified "below $2^{-m}$" sentence (C4, §2.8);
  * the independence counterexample (C2, §3).
* **Code.** q1–q5 were written before any earlier script of the track was opened, and import nothing from it. Each was run twice in fresh processes, with byte-identical outputs and empty stderr.
* **Not done.**
  * No LaTeX build: the corrections are plain text in existing sentences, and the final check's build of the drafts stands.
  * No WebSearch: no new citation is involved.
  * Items outside the five, such as Proposition 4.11, the weight-decay drafts and the private-coins remark, were not refereed beyond §7.
