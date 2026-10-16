# Thread `laws`: approximate laws, exceptions and the best system

*Research record of the development round, 2026-10-16. Folder `research/tracks/laws/`, scripts in `checks/`. Brief: `00-brief.md` (this folder), read in full; project brief `../../00-brief.md`, read in full (the author's request names "kepler's laws not really giving you correct predictions but giving approximately correct predictions" as a limitation; seeds "Approximate theories", "Laws versus initial conditions", "Explanation"; the epistemic policy). Binding notation: `../../NOTATION-draft.md` (§6.4 fixes $J_\lambda$, $\mathrm{Exc}_D$, $\mathrm{EP}_D$, $T_0$, $T^\varepsilon$, $e(t)$, $\varepsilon^*$, $\delta$, $\delta_0$, $\Delta$, $\mathrm{pk}(e)$, $\gamma$). "SAI" is the working name's abbreviation; no argument below depends on the name. Sources read: `../../select.md`; scout N2 (`../../scouts/novel-science/notes.md`, all of it, and `checks/n2_best_system.py`, `n3_precision_phases.py` with their outputs); scout P (`../../scouts/philosophy/notes.md` §2 and §5, `checks/c1_kepler_fit.py`); scout F's F14 (`../../scouts/fundamentals/notes.md` §3.5); the `fundamentals` thread record (`../fundamentals/notes.md` §1, §5) for the definitions of $M_A$, $W_A$, $K_A$ and their loss bounds; the `philosophy` thread record (§3.3, §3.4, §4.3, §4.6, §5.2–5.3, §6.1) for the Kepler data and what it cites from this thread; SOI Paper 2 (`../../../../solomonoff-operator-induction/paper-steeper/sections/{setup,kinks,app-setup,app-kinks}.tex`: `def:setup:objectives`, `def:setup:class`, `lem:setup:hull`, `lem:setup:coding`, `lem:setup:basic`, `def:kink:kinks`, `lem:kink:main`, `cor:kink:locate`, `cor:kink:split`, `thm:kink:converse`, `prop:kink:universal`).*

*This run was restarted once. The earlier run had re-run scout N2's `n2` and `n3` on scratch copies (outputs identical to the saved ones apart from the timing line) and left an unrun script `checks/l4_kepler_pk.py`; that script was checked, cut down to its residual computation (its selection part is now `l5_kepler_select.py`, rewritten for the corrected criteria of §3) and run. No other output of the earlier run survived; the literature searches were redone (§12).*

**Status tags.** [proved]: full proof here. [proved, given X]: the proof uses the cited result X. [computed: script, part]: script and saved output named. [known: key; content level]: a published result, bibliographic data verified by WebSearch (this thread or `philosophy`'s `refs.bib`), content checked at the stated level (source / abstract / secondary). [proof sketch]: the argument with the missing steps named. [conjecture], [open], [refuted] (kept with its counterexample). [assessment]: a considered judgement argued in the text.

**Local notation** (defined here, not global; see §11 for requests).
* $\pi_c$: bits to name one time (a numeral) inside a law sentence (scout N2's $\pi_c$).
* $p_\Delta:=\Ex\min(|e(t)|/\Delta,1)$: probability that the exact law refutes a dithered datum of cell width $\Delta$; $q_\Delta:=\min(2\varepsilon^*/\Delta,1)$: probability that the honest law is silent on it.
* $\gamma_{\rm ex}$: cost of one exception; $\gamma_{\rm si}$: cost of one datum on which a law is silent (both in bits; §3.2).
* $\theta_{\rm ex}$: the optimal share of exceptions of a tolerance law (§3.3).
* $H_2(x):=-x\log x-(1-x)\log(1-x)$, the binary entropy.
* In §7 only: a rotation $R$ of the plane and a perturbation size $\eta$ (P2's $\eta_{\mathcal N}$ is not used in §7).

---

## 0. Summary

**T1, the objective and SAI.** "Law plus listed exceptions" is a deterministic hypothesis of $W_A$ and $M_A$ when exceptions carry their full sentences (Prop 1.4). SAI's one-tape law pays only *question-relative* exception costs, through randomised theories that complete a law at random inside what it allows (Prop 1.8: $L_A(D)\le|T|+\mathrm{Exc}^R_D(T)+c$). Conversely, $L_A$ *is* the best two-part code over all theory machines up to $\pm c$ (Prop 1.9(a)). No restricted class matches it within $O(1)$, and over all theory machines a steeper penalty collapses onto the universal machine (Prop 1.9(d)). So best-system analyses need classes of laws with private literal facts. In those classes P2's hull, kink and converse results apply; only P2's coding bound needs a replacement, proved directly (Props 1.10, 1.11).

**T2, precision.** Over deterministic theories, proof-requiring compatibility is monotone in logical strength, so data never favour a hedge (Prop 2.1, giving scout P's Prop 2.3). Under guaranteed tolerances the switch point is sharp at $\varepsilon^*+\delta_0$ (Prop 2.4). Under dithered rounding an exact but false law survives $n$ data with probability $(1-p_\Delta)^n$, so it is refuted after about $\Delta/\Ex|e|$ data however coarse the cells (Prop 2.5). The brief's precision seed is corrected (§2.3).

**T3, honest laws against laws with exceptions.**
* *Criterion.* The honest law beats the exact law with exceptions iff $\mathrm{pk}(e)<\gamma_{\rm ex}/(2\gamma_{\rm si})$, the ratio of the price of an exception to that of silence (Prop 3.4). Scout N2's criterion is the case of deterministic patches with literal pricing. Under SAI's own pricing, silence costs at most $\log e$ bits (Lemma 3.6), and honesty wins unless the error is very peaked. With randomised exceptions under literal pricing it almost never wins.
* *Optimum.* The best member of the whole family states the $(1-\theta_{\rm ex})$-quantile of the error as tolerance and lists the rest as exceptions (Prop 3.5).
* *Almost-sure selection.* Selection is almost sure. Ties oscillate forever. Switch points satisfy Wald bounds and scale linearly (Thm 3.8), giving the phases $0\to E\to P\to H\to N$ (Cor 3.9). The trichotomy's "independent" mass on finer questions is the posterior share of honest theories (Prop 3.10).
* *Real Kepler residuals.* Seven bodies, 12–2000-year windows. The peakedness is 1.9–4.0. Under SAI's pricing the honest law wins for every body, window and precision ($0.1'$ to $30°$), with optimal tolerance $\approx(0.7$–$1)\varepsilon^*$ and at most 1% exceptions. Under N2's pricing at $\lambda=1$ the exact law with exceptions wins (§3.6).

**T4, horizons and soundness.** Derived tolerance $e_r=L^re_0+\varepsilon(L^r-1)/(L-1)$, exactly a zonotope for linear maps; horizons; contracting dynamics have none (Prop 4.1). An exact approximation is correct only to depth $r^*(\delta)$ (Prop 4.2). A sound criterion for combining approximate models: honest models are consistent and sound, exact ones explode, and joint consistency is a pairwise check in one dimension, by Helly (Prop 4.3). The criterion is worst-case: $7.96\varepsilon$ typical against $100\varepsilon$ worst after 100 steps (Remark 4.4).

**T5, the best system.**
* *Basic facts.* Marginal slopes and explanatory power; facts used once never enter for $\lambda>1$ (Props 5.1, 5.3).
* *Solar-system toy.* Closed form; it corrects scout N2's stated $K3$ criterion (refuted: $K3$ enters iff $s|S|>L_3$, independently of $\lambda$; it compresses initial conditions) (Prop 5.5).
* *Lewis.* "Kind nature" holds exactly at a kink of the hull (Prop 5.6). Trivialisation is blocked by the coding bound (Prop 5.7).
* *Explanatory power.* EP is the per-bit log-likelihood ratio. Myrvold's unification term is zero with stated parameters and equals the bits of shared unknown parameters otherwise (Prop 5.8). In the question format initial conditions are antecedents (Prop 5.9).

**T6, domains and retention.** A domain restriction pays iff the law, even with an honest tolerance, is worse than literal data. Under SAI's pricing that never happens for bands below about $24°$, so the Moon is kept with a $2.6°$ tolerance rather than excluded (Prop 6.1). A superseded theory is retained for all data coarser than a computable $\Delta^*$ (Prop 6.2).

**T7, correction.** In an exact rational toy the successor proves the honest old law on every window, with tolerance exactly $\varepsilon_{\min}(W)\le((1+\eta\|P\|)^W-1)|a|$, refutes the exact old law, and shares with it exactly the honest form (Prop 7.1).

**T8.** Partial: under SAI's pricing, tolerances per body and window are learned rather than sharp domains (§8).

**Refuted or qualified** (§10): N2's $K3$ criterion; the pricing-independent readings of "spread errors favour honesty", "a steeper prior favours honesty", "the Moon is excluded"; scout P's Prop 2.3 inside $M_A$. No "Possible error in the author's view" note is raised here: the brief assigns those to `philosophy`, and this record found none of its own.

---

## 1. The setting and its relation to SAI (T1)

### 1.1 Data, questions, theories, codes

**Definition 1.1 (answered questions).** $B$ is the background (decidable, consistent; NOTATION §3.1). A *question* $\mathcal Q$ is a finite set of pairwise $B$-incompatible sentences whose disjunction $B$ proves (NOTATION §3.2); $\gamma(\mathcal Q):=\log|\mathcal Q|$. An *answered datum* is a pair $(\mathcal Q,a)$ with $a\in\mathcal Q$ (the true answer); as a two-valued data set it is $\{(a,1)\}$, and its negative content $\neg a'$ ($a'\ne a$) follows from $B$. A *data set* $D$ is a finite set of answered data with pairwise distinct questions; $\dom D$ is the list of its questions in a canonical order, $y_D$ the list of its answers, and $M_A(D)$, $L_A(D)$, $K_A(D)$ mean the values on $D^\sharp:=\{(a,1):(\mathcal Q,a)\in D\}$. A yes/no question $\{\varphi,\neg\varphi\}$ gives the binary data of NOTATION §3.2 ($\gamma=1$).

For a theory $T$ and a datum $(\mathcal Q,a)$: $T$ *proves* it if $B\cup T\vdash a$, *refutes* it if $B\cup T\vdash\neg a$, and is *silent* on it otherwise. The *allowed answers* are $A_T(\mathcal Q):=\{a'\in\mathcal Q:B\cup T\nvdash\neg a'\}$. For consistent $B\cup T$: $T$ proves $(\mathcal Q,a)$ iff $A_T(\mathcal Q)=\{a\}$. (If $T\vdash a$ then $T\vdash\neg a'$ for $a'\ne a$ by incompatibility; conversely if $T$ refutes every $a'\ne a$, then $T\vdash a$ since $B\vdash\bigvee\mathcal Q$.)

**Definition 1.2 (lengths).** Fix a prefix-free code $c_S$ for sentences and put $\ell(\chi):=1+|c_S(\chi)|$. For a finite theory $T$ (listed in a canonical order), $|T|:=1+\sum_{\chi\in T}\ell(\chi)$: each sentence is preceded by a continuation bit and the list ends with a stop bit. This is a prefix-free code of finite theories; there are at most $2^m$ theories of length $m$; $K(T)\le|T|+c$. For a *module* $\mathcal A\subseteq T$ put $\|\mathcal A\|:=\sum_{\chi\in\mathcal A}\ell(\chi)$, so that $|T|-|T\setminus\mathcal A|=\|\mathcal A\|$ and $|T\cup\mathcal A|=|T|+\|\mathcal A\|$ for $\mathcal A\cap T=\emptyset$. (NOTATION writes $|\mathcal A|$ in $\mathrm{EP}_D$; it means $\|\mathcal A\|$.)

**Definition 1.3 (exceptions and the objective).** Let $B\cup T\cup D^{\sharp}$ be consistent. The *exceptions* of $T$ on $D$ are the data $T$ does not prove, $E_D(T)$. Three codes for them:
* **(Q) question-relative literal code** (the decoder knows the questions): $\mathrm{Exc}^Q_D(T):=\sum_{(\mathcal Q,a)\in E_D(T)}\gamma(\mathcal Q)$;
* **(F) full literal code** (the answer sentence itself, which also identifies its question): $\mathrm{Exc}^F_D(T):=\sum_{(\mathcal Q,a)\in E_D(T)}\ell(a)$;
* **(R) random completion**, for pointwise interval laws (Def 1.5): $\mathrm{Exc}^R_D(T):=-\log P^R_T(D)$.

If $B\cup T\cup D^\sharp$ is inconsistent, $\mathrm{Exc}_D(T):=\infty$ in every code. $J_\lambda(T;D):=\lambda|T|+\mathrm{Exc}_D(T)$ for $\lambda>0$; its minimisers are the *$\lambda$-MAPs* (NOTATION §6.4, P2 `def:setup:objectives`). Statements name their code; unmarked $\mathrm{Exc}$ means code Q.

**Patches.** For a law $T=\{\forall t\,(I(t)\to\Phi(t))\}$ ($I$ the admissible times) and a finite set $S$ of times, the *patched law* is $T^{-S}:=\{\forall t\,(I(t)\wedge\bigwedge_{s\in S}t\ne\underline s\to\Phi(t))\}$, with $|T^{-S}|=|T|+\sum_{s\in S}\pi_c(s)+O(1)$, $\pi_c(s)$ the length of the numeral $\underline s$ plus a connective. The brief's "law plus listed exceptions" $(T,E)$ is the theory $T\cup E^\sharp$ when $T$ is silent on $E$, and $T^{-S}\cup E^\sharp$ when $T$ refutes the data at the times $S$.

### 1.2 Deterministic theories

**Proposition 1.4 (laws plus listed exceptions are deterministic hypotheses) [proved].** For every finite $T$ with $B\cup T\cup D^\sharp$ consistent:
$$L_A(D)-c\ \le\ K_A(D)\ \le\ |T|+\mathrm{Exc}^F_D(T)+c .$$
For an r.e. $T$ and $E\subseteq D$ with $B\cup T\cup E^\sharp$ consistent and $T\cup E^\sharp\vdash\psi_{D^\sharp}$: $L_A(D)\le K_\equiv(T)+K(E)+c$ (`fundamentals` Prop 5.2(b), scout F's F14(b)).

*Proof.* $T':=T\cup\{a:(\mathcal Q,a)\in E_D(T)\}$ is finite, consistent with $B$ (it is contained in the consistent set $T\cup D^\sharp$) and proves every datum. Concatenating the code of $T$ (without its stop bit), the codes $1c_S(a)$ of the exceptions and a stop bit is a prefix-free code of $T'$ of length $|T|+\mathrm{Exc}^F_D(T)$; a fixed program turns it into an index of $T'$, so $K_A(D)\le|T|+\mathrm{Exc}^F_D(T)+c$. $L_A\le K_A+c$ is `fundamentals` Thm 5.1. ∎

Code F pays for *which* questions are exceptions: the sentence $a$ names its question. In a deterministic theory there is no way around this, because the theory does not see the questions. The next proposition shows that SAI, through its random tape, pays only the question-relative cost.

### 1.3 Randomised theories: SAI pays question-relative exception costs

**Definition 1.5 (pointwise interval laws).** Let $B:=\mathrm{RCF}$, the theory of real closed fields in $\{0,1,+,\cdot,<\}$ (decidable and complete by Tarski's theorem [known: tarski1951decision; standard]), and add fresh constants $q_t$ for $t$ in a decidable set $I$ of numerals (times). Fix a range $[0,\mathsf R]$ ($\mathsf R$ rational). A *pointwise interval law* is $T_{l,u}:=\{l(t)\le q_t\le u(t):t\in I\}$ for computable $l\le u:I\to\mathbb Q\cap[0,\mathsf R]$, presented by a program for $(l,u)$; $|T|$ is the length of that presentation in a fixed prefix-free code, and $K(T)\le|T|+c$. Examples: the exact law $T_0$ ($l=u=f$); the honest law $T^\varepsilon$ ($l=f-\varepsilon$, $u=f+\varepsilon$, clipped to the range); the patched law $T_0^{-S}$ ($l=0$, $u=\mathsf R$ on $S$, $l=u=f$ elsewhere). *Interval data* are answers to questions $\mathcal Q$ that partition $[0,\mathsf R)$ into finitely many cells $[\alpha,\beta)$ with rational endpoints, each answer being the sentence $\alpha\le q_t<\beta$.

**Lemma 1.6 (decidability) [proved].** For a pointwise interval law $T$ and an interval datum $\alpha\le q_t<\beta$: $T$ proves it iff $[l(t),u(t)]\subseteq[\alpha,\beta)$; $T$ refutes it iff $[l(t),u(t)]\cap[\alpha,\beta)=\emptyset$; and $B\cup T\cup D^\sharp$ is consistent iff, for every time $t$ of $D$, $[l(t),u(t)]$ meets the intersection of the cells $D$ assigns to $t$. All three are decidable from $(l,u)$.

*Proof.* Every choice of reals $q_t\in[l(t),u(t)]$ (and in the assigned cells) gives a model in $\mathbb R$; this proves the "only if" of the first two claims (choose $q_t$ outside the cell, resp. inside it) and the "if" of the third. Conversely, rational inequalities between numerals are provable in $\mathrm{RCF}$, which gives the "if" of the first two claims; and if for some $t$ the interval misses the assigned cells, the corresponding finitely many inequalities are jointly refutable in $\mathrm{RCF}$. ∎

**Definition 1.7 (random completion).** For a pointwise interval law $T$ and a data set $D$ of interval data, let $C_t$ be the intersection of the cells $D$ assigns to time $t$, and put
$$P^R_T(D):=\prod_{t}\frac{|C_t\cap[l(t),u(t)]|}{u(t)-l(t)},$$
with the factor read as $\ind[l(t)\in C_t]$ when $l(t)=u(t)$; $|\cdot|$ is length. $\mathrm{Exc}^R_D(T):=-\log P^R_T(D)$.

**Proposition 1.8 (SAI pays question-relative exception costs) [proved].** Let $T$ be a pointwise interval law and $D$ a set of interval data consistent with $T$.
* (a) $L_A(D)\le K(T)+\mathrm{Exc}^R_D(T)+c\le|T|+\mathrm{Exc}^R_D(T)+c$.
* (b) If $D$ is drawn from a computable question family with one question $\mathcal Q_t$ per time, then $L_A(D)\le K(T,(\mathcal Q_t)_t)+\sum_{(\mathcal Q_t,a)\in E_D(T)}\log k_t(T)+c$ with $k_t(T):=|A_T(\mathcal Q_t)|\le|\mathcal Q_t|$; in particular $L_A(D)\le K(T,(\mathcal Q_t))+\mathrm{Exc}^Q_D(T)+c$.
* (c) Code R charges an exception of a patched law ($t\in S$, $l=0$, $u=\mathsf R$) exactly $\log(\mathsf R/|C_t|)$, the code-Q cost for equal cells; it charges the honest law $-\log(|C_t\cap[f-\varepsilon,f+\varepsilon]|/2\varepsilon)$, which is $0$ when the band lies in the cell (Lemma 3.6 averages it).

*Proof.* (a) Enumerate $I$ as $t_1,t_2,\dots$ and fix a computable injection $(i,k)\mapsto\langle i,k\rangle$ into tape positions, increasing in $k$. On a tape $\omega$ put $U_i:=\sum_{k\ge1}\omega_{\langle i,k\rangle}2^{-k}$; under $\Unif$ the $U_i$ are independent and uniform on $[0,1]$. Let $G_T$ be the theory machine that emits $T$ at the empty prefix and, once the prefix read contains the positions $\langle i,1\rangle,\dots,\langle i,k\rangle$ with bits giving the integer $m$, emits
$$l(t_i)+(u-l)(t_i)\,m2^{-k}\ \le\ q_{t_i}\ \le\ l(t_i)+(u-l)(t_i)\,(m+1)2^{-k}.$$
This set of (prefix, sentence) pairs is c.e., and an index of it is computable from an index of $T$, so $K(G_T)\le K(T)+c$.
* *The random theory is always consistent:* $q_{t_i}:=v_i:=l(t_i)+(u-l)(t_i)U_i$ satisfies every emitted inequality (each closed dyadic interval contains $U_i$), so $\mathbb R$ with these values is a model.
* *It proves a datum $\alpha\le q_{t_i}<\beta$ whenever $v_i$ lies in the open cell $(\alpha,\beta)$:* the emitted intervals contain $v_i$ and have lengths $(u-l)2^{-k}\to0$, so one of them lies in $(\alpha,\beta)$, and $\mathrm{RCF}$ proves the inclusion. (If $l=u$, $T$ alone decides the datum.)
* Hence $\nu_{G_T}(D)\ge\Unif\{\omega:v_t\in\operatorname{int}C_t\text{ for all }t\}=P^R_T(D)$: the times of $D$ are distinct indices $i$, the $U_i$ are independent, and endpoints have measure $0$.

By dominance (`fundamentals` Thm 4.1: $M_A\ge2^{-K(\nu)}\nu$ for every theory-machine law $\nu$; scout F's F4), $M_A(D)\ge2^{-K(G_T)-c}\nu_{G_T}(D)$, which gives (a).
(b) Use $U_i$ to pick the $\lfloor k_{t_i}U_i\rfloor$-th element $a$ of $A_T(\mathcal Q_{t_i})$ (computable by Lemma 1.6), and emit $a$ once enough bits are read (almost surely finitely many). The cell $a$ meets $[l,u]$, so the random theory has a model; it proves the true answer with probability $1/k_t$, independently across times. (c) is the definition. ∎

**Reading [assessment].** The deterministic route (Prop 1.4) names each exceptional question. A random theory instead assigns random answers to *every* question of the family at once; only the questions asked matter, so the cost of saying *which* question was exceptional disappears when the tape is integrated out. This is the mechanism of scout F's F14(c) (`fundamentals` Prop 5.2(c): fair-coin facts on atoms the law is silent about), extended from atoms on which the law is silent to answers the law only constrains. So the question-relative codes Q and R, which the selection theorems of §§2–6 use, are not a convenience: they are what SAI's one-tape law actually charges for exceptions, up to $K(T)+c$.

### 1.4 The converse, and which of P2's results apply

**Proposition 1.9 (SAI's loss is the best two-part code over randomised theories) [proved, given `fundamentals` Thm 4.1, Prop 1.8(d) and Thm 6.2, and P2 `prop:kink:universal`].**
* (a) For every data set $D$: $L_A(D)=\min_G\,[K(G)-\log\nu_G(D)]\pm c$, the minimum over theory machines $G$; it is attained, up to $c$, by the universal machine $G_U$.
* (b) Restricting $G$ gives the upper bounds of Props 1.4, 1.8: $L_A(D)\le\min_T J^R_1(T;D)+c$ over pointwise interval laws, $L_A(D)\le\min_T J^F_1(T;D)+c$ over finite theories, and $L_A(D)\le K_A(D)+c$.
* (c) No such restriction is within an additive constant of $L_A$ in general. $K_A-L_A$ is unbounded (`fundamentals` Thm 6.2, scout F's F11: no coding theorem). And for finite theories with question-relative exceptions: in the language $\{R\}\cup\{c_j:j\in\mathbb N\}$ with $B=\emptyset$, the binary data $D_n:=\{(R(c_j),1):j<n\}\cup\{(\exists x\neg R(x),1)\}$ have $L_A(D_n)\le c$, but $J^Q_1(T;D_n)\ge n$ for every finite $T$, in every syntax code in which each symbol occurrence costs at least one bit.
* (d) Over the class of *all* theory machines, steeper selection collapses. Take the point family of programs $p\in\dom V$ for theory machines, with $\ell(p):=|p|$ and fit $-\log\nu_{G_{V(p)}}(D)$. A program $p_U$ for $G_U$ satisfies P2's condition (Dom) with $\kappa_0=c$, so for $\lambda>1$ every $\lambda$-MAP $p$ has $|p|\le\ell_U+(\ell_U+c)/(\lambda-1)$, where $\ell_U:=|p_U|$.

*Proof.* (a) Dominance (`fundamentals` Thm 4.1) gives $L_A\le K(G)-\log\nu_G+c$ for every $G$; and $G=G_U$ gives $K(G_U)-\log\nu_{G_U}(D)=L_A(D)+O(1)$. (b) Props 1.4, 1.8. (c) The first part is cited. For the second: $L_A(D_n)\le K_A(D_n)+c\le c'$ by `fundamentals` Prop 1.8(d) (the r.e. theory $\{R(c_j):j\in\mathbb N\}\cup\{\exists x\neg R(x)\}$). Let $T$ be finite with $T\cup D_n^\sharp$ consistent. If $c_j$ does not occur in $T$ and $T\vdash R(c_j)$, then $T\vdash\forall x R(x)$ by the theorem on constants, contradicting consistency with $\exists x\neg R(x)$. So $T$ proves at most the data $R(c_j)$ with $c_j$ in $T$, and $\exists x\neg R(x)$. Each constant occurring in $T$ costs at least one bit of $|T|$, and each unproved datum one bit of $\mathrm{Exc}^Q$; so $J^Q_1(T;D_n)\ge n$. (d) P2 `prop:kink:universal`(ii) needs only a point family with a member $\pi_U$ such that $L(\pi_U)\le L(\pi)+\ell(\pi)+\kappa_0$ for all $\pi$. The mixture identity of `fundamentals` Thm 4.1, $M_A(D)\ge\sum_p2^{-|p|}\nu_{G_{V(p)}}(D)$, gives $-\log\nu_{G_U}(D)=L_A(D)\le-\log\nu_{G_{V(p)}}(D)+|p|$ for every $p$, which is this condition. ∎

**Reading [assessment].** (a) says that SAI *is* a two-part code with $\lambda=1$, over randomised theories, with the universal machine as the best member. (d) says that a steeper penalty over that whole class selects nothing long: the universal machine absorbs every law into its fit. P2 found the same split for SOI (the one-tape class has a universal member; product classes do not; P2 `cor:absorb:nouniversal`). So a best-systems analysis with a steeper penalty (§5) must be done over a class of *laws with private literal facts*, where no member absorbs the others. The two classes below are of this kind.

**Proposition 1.10 (P2's hypotheses in the two classes of laws) [proved, given P2].**
* (i) **Class $\mathcal H^R$** (pointwise interval laws, code R). Programs are the codewords of law presentations (a decidable prefix-free set); $P_T:=P^R_T$ is computable uniformly in $T$; it is the machine law of $G_T$ (a shared hypothesis in P2's sense, `def:setup:shared`) and, on data with distinct times, a product hypothesis (`def:setup:product`); Kraft's inequality holds; lengths are integers with finitely many programs of each length. So P2's `lem:setup:basic`, `lem:setup:hull`, `lem:setup:coding`, `lem:kink:main`, `cor:kink:locate`, `cor:kink:split` and `thm:kink:converse` apply verbatim, with $J_\lambda=J^R_\lambda$.
* (ii) **Class $\mathcal H^Q$** (finite theories over a general background, code Q), with $P_T(D):=2^{-\mathrm{Exc}^Q_D(T)}\ind[B\cup T\cup D^\sharp\text{ consistent}]$. This is a shared hypothesis (a weak function semimeasure, P2 `def:setup:shared`), and a product over questions when consistency can be checked question by question (pointwise laws at distinct times); but it is *not* lower semicomputable in general, because the consistency factor is co-r.e. Of P2's results, the hull lemma, the kink lemma, `cor:kink:locate` and `thm:kink:converse` use only the point family $(|T|,\mathrm{Exc}^Q_D(T))_T$ (integer lengths, finitely many points of each length, some point finite since $T=\emptyset$ is), and they apply; `lem:setup:basic`(i) applies; `lem:setup:coding` uses lower semicomputability and is replaced by Prop 1.11, with which `cor:kink:split` holds as stated (constant $\kappa$ of Prop 1.11; offset $b+\kappa+n$ in the general case, $b+\kappa$ when provability is decidable). On pointwise interval laws $P_T$ is computable (Lemma 1.6) and all of (i) applies.

*Proof.* Each listed property is checked in the statement; that the hull, kink and converse results need only the point family is visible from their statements (P2 `lem:setup:hull` and `def:algstat:product` are about countable point families) and proofs (`app:setup:hull`, `app:kinks:data`), which use only lengths, fits and the finiteness of programs per length. For (ii), the semimeasure property (P2 `def:setup:shared`): $P_T(\emptyset)=\ind[B\cup T\text{ consistent}]\le1$, and for $\mathcal Q\notin\dom D$, $\sum_{a\in\mathcal Q}P_T(D+(\mathcal Q,a))\le P_T(D)$. Indeed, if $T$ proves an answer $a_0$, every other answer is refuted by $T$ and contributes $0$, and $a_0$ adds no cost; if $T$ proves no answer, each of the at most $|\mathcal Q|$ answers consistent with $T\cup D^\sharp$ contributes at most $2^{-\gamma(\mathcal Q)}P_T(D)=P_T(D)/|\mathcal Q|$. Not lower semicomputable: if $T\mapsto P_T(\emptyset)$ were lsc uniformly in $T$, the set of finite theories with $P_T(\emptyset)>\frac12$, i.e. the consistent ones, would be r.e.; the inconsistent ones are r.e. as well, so consistency of finite theories would be decidable, which fails in any language with a binary relation symbol (Church's theorem [known: church1936note; standard]). ∎

**Proposition 1.11 (coding bound for laws with literal exceptions) [proved].** For every finite $T$ with $B\cup T\cup D^\sharp$ consistent, $n:=|D|$:
* (a) $|T|+n+\mathrm{Exc}^Q_D(T)\ \ge\ K(y_D\mid\dom D)-c$;
* (b) if provability of answers from $T$ is decidable uniformly in $T$ (e.g. on pointwise interval laws), $|T|+\mathrm{Exc}^Q_D(T)\ge K(y_D\mid\dom D)-c$, and also $|T|+\mathrm{Exc}^R_D(T)\ge K(y_D\mid\dom D)-c$.

*Proof.* (a) For a question $\mathcal Q$ put $w_T(a\mid\mathcal Q):=\tfrac12\ind[a\text{ is the first answer of }\mathcal Q\text{ found provable from }B\cup T]+\tfrac12|\mathcal Q|^{-1}$, "first" in a fixed dovetailed proof search. Then $\sum_aw_T(a\mid\mathcal Q)\le1$, and $w_T$ is lower semicomputable uniformly in $(T,\mathcal Q)$ (the first answer found never changes). $P'_T(y):=\prod_jw_T(y_j\mid\mathcal Q_j)$ is a uniformly lsc semimeasure on the answer lists for $\dom D$. If $T$ is consistent and proves $y_j$, no other answer of $\mathcal Q_j$ is provable, so $y_j$ is the first found and $w_T\ge\frac12$; otherwise $w_T\ge\frac12|\mathcal Q_j|^{-1}$. Hence $-\log P'_T(y_D)\le n+\mathrm{Exc}^Q_D(T)$. The conditional coding theorem (P2 (F2)) gives $K(y_D\mid T,\dom D)\le n+\mathrm{Exc}^Q_D(T)+c$, and $K(y_D\mid\dom D)\le K(T)+K(y_D\mid T,\dom D)+c\le|T|+n+\mathrm{Exc}^Q_D(T)+c$. (b) With decidable provability, take $w_T(a\mid\mathcal Q):=1$ if $T$ proves $a$, $:=|\mathcal Q|^{-1}$ if $T$ proves no answer, $:=0$ otherwise; it sums to at most $1$ and is computable. For code R, $P^R_T$ is itself a computable semimeasure on answer lists (Prop 1.10(i)), and P2 `lem:setup:coding` applies. ∎

So the right line of slope $1$ around a sufficient law (P2 `cor:kink:split`(a)) holds in both classes; in code Q without decidability it carries the flag cost $n$, which makes it useless, and for that reason §§2–6 work with laws whose provability on the data is decidable.

---

## 2. Interval data and precision (T2)

Throughout §§2–3: a real quantity $q(t)$ (an angle in arcminutes, say), an exact law $f$ with error $e(t):=f(t)-q(t)$, and $\varepsilon^*:=\operatorname{ess\,sup}|e|$ under the law $\mu$ of sampled times. $T_0$ asserts $q(t)=f(t)$ for all $t$; $T^\varepsilon$ asserts $|q(t)-f(t)|\le\varepsilon$ for all $t$. Both are pointwise interval laws (Def 1.5). Data are true interval sentences.

### 2.1 Proof-requiring SAI never rewards a hedge

**Proposition 2.1 (compatibility is monotone in logical strength) [proved].** Let $B\cup T$ be consistent and $\Cn(T)\supseteq\Cn(T')$. For every data set $D$: if $T'$ is compatible with $D$ ($B\cup T'$ consistent and proving every datum), so is $T$. Hence, among deterministic hypotheses of $W_A$ and $M_A$, the posterior odds of $T$ against $T'$ equal their prior odds on every $D$ on which $T'$ is compatible, and $T'$ is incompatible whenever $T$ is: data never move the odds towards the weaker theory.

*Proof.* $T$ proves everything $T'$ proves and is consistent; a consistent theory that proves every datum is consistent with the data. ∎

**Corollary 2.2 (scout P's Prop 2.3) [proved].** $T_0\vdash T^\varepsilon$ for every $\varepsilon\ge0$. So every data set compatible with the honest law $T^\varepsilon$ is compatible with the exact law $T_0$, at every sample size and every precision. With prior weights $2^{-|T|}$ in a prefix code in which the tolerance clause costs at least one bit, the posterior odds of $T_0$ against $T^\varepsilon$ are at least $2^{|T^\varepsilon|-|T_0|}\ge2$ on every such data set. If $e^*:=\sup_t|e(t)|>0$, $T_0$ is false, and on a question at precision $\delta'<e^*$ it proves a false answer at some times; $T^\varepsilon$ with $\varepsilon\ge e^*$ is true and is silent wherever its band straddles a cell boundary.

**Reading [assessment].** A tolerance, a domain restriction and a disjunction are all weakenings, so a proof-requiring inducer over deterministic theories never prefers them: it rewards strength, and data can only remove the strong theory, never favour the weak one over it. The honest approximate law can therefore win only where the strong one has been refuted and the data's literal costs are counted. Inside $M_A$ this happens through randomised theories (Prop 1.8): after $T_0$ is refuted, "$T^\varepsilon$ plus random completion" keeps positive weight $2^{-|T^\varepsilon|-\mathrm{Exc}^R_D(T^\varepsilon)}$. §3 analyses that competition.

**Proposition 2.3 (precision monotonicity) [proved].** If $B\cup T$ proves "$q(t)\in[v-\delta',v+\delta']$" then it proves "$q(t)\in[v-\delta,v+\delta]$" for every $\delta\ge\delta'$. So compatibility with data at a fixed set of centres is monotone in the precision. (The first interval is contained in the second.) ∎

### 2.2 Two precision regimes

**Proposition 2.4 (guaranteed tolerances, regime G) [proved].** Datum $j$ is "$q(t_j)\in[v_j-\delta,v_j+\delta]$" with $v_j=q(t_j)+\eta_j$, $|\eta_j|\le\delta_0\le\delta$.
* (a) $T_0$ proves datum $j$ iff $|e(t_j)-\eta_j|\le\delta$, and refutes it otherwise.
* (b) If $\delta\ge\varepsilon^*+\delta_0$, $T_0$ is compatible with every such data set whose times are $\mu$-typical (almost surely), at every $n$.
* (c) If the pairs $(t_j,\eta_j)$ are i.i.d. with $t_j\sim\mu$ independent of $\eta_j$, both $\pm\delta_0$ lie in the support of the law of $\eta_j$, and $\delta<\varepsilon^*+\delta_0$, then the per-datum refutation probability $r(\delta):=\Pr[|e(t)-\eta|>\delta]$ is positive, $\Pr[T_0\text{ survives }n\text{ data}]=(1-r(\delta))^n$, and $T_0$ is almost surely refuted eventually.
So the switch point $\delta=\varepsilon^*+\delta_0$ is sharp.

*Proof.* (a) $T_0\vdash q(t_j)=f(t_j)=v_j+e(t_j)-\eta_j$; this point lies in the interval iff $|e(t_j)-\eta_j|\le\delta$, and if it does not, $T_0$ proves the negation. (b) $|e-\eta|\le|e|+|\eta|\le\varepsilon^*+\delta_0$ for $\mu$-almost every $t$. (c) Pick $\varepsilon'<\varepsilon^*$ and $s>0$ with $\varepsilon'+\delta_0-s>\delta$. Since $\varepsilon^*$ is the essential supremum, $\Pr[e(t)>\varepsilon']>0$ or $\Pr[e(t)<-\varepsilon']>0$; in the first case $\Pr[\eta<-\delta_0+s]>0$ (support), and independence gives $\Pr[e-\eta>\delta]>0$; the second case is symmetric with $\eta>\delta_0-s$. Refutations of distinct data are independent, so survival has probability $(1-r)^n\to0$, and a refuted theory stays refuted. ∎

**Proposition 2.5 (dithered rounding, regime R) [proved].** Datum $j$ is "$q(t_j)$ lies in the cell $[\Delta(m-u_j),\Delta(m+1-u_j))$ that contains it", with $u_j\sim U[0,1)$ independent of everything else. Then $\Pr[T_0\text{ proves datum }j\mid t_j]=(1-|e(t_j)|/\Delta)^+$, and otherwise $T_0$ refutes it. With i.i.d. times, $\Pr[T_0\text{ survives }n\text{ data}]=(1-p_\Delta)^n$, $p_\Delta:=\Ex\min(|e(t)|/\Delta,1)$; the index of the first refutation is geometric with mean $1/p_\Delta$; and $T_0$ is almost surely refuted eventually iff $\Pr[e(t)\ne0]>0$, *for every $\Delta$, however coarse*. For $\Delta\ge\varepsilon^*$, $p_\Delta=\Ex|e|/\Delta$, so the exact law survives about $\Delta/\Ex|e|$ data.

*Proof.* Two points at distance $|e|<\Delta$ fall in different cells of a uniformly shifted grid of width $\Delta$ with probability $|e|/\Delta$; at distance $\ge\Delta$ always. $T_0$ proves "$q(t_j)\in$ the cell of $f(t_j)$" and so refutes every other cell. Independence across data gives the product, and $p_\Delta>0$ iff $\Pr[e\ne0]>0$. ∎

**Computed [l2 A, B].** (A) For $\varepsilon^*=1'$, $\delta_0=0.5'$ and $\eta\sim U[-\delta_0,\delta_0]$: $r(\delta)$ falls from $0.22$ at $\delta=1'$ to $6\times10^{-4}$ at $1.49'$ and is exactly $0$ (in $10^6$ draws) at $\delta\ge1.5'$, for both the spread error ($A\sin2\pi t$) and the peaked one ($\pm A$ on 5% of times). (B) Simulated survival after $n=1,10,100$ dithered data matches $(1-p_\Delta)^n$, and the mean first-refutation index matches $1/p_\Delta$ (e.g. $94.1$ against $94.2$ at $\Delta=60'$ and $942.7$ against $943.4$ at $\Delta=600'=10°$ for the spread error with $\varepsilon^*=1'$; $11941$ against $12006$ at $\Delta=600'$ for the peaked one), at every $\Delta$ from $0.5'$ to $600'$. These agree with scout N2's `n3` A, B, which the earlier run of this thread re-ran unchanged (identical output).

### 2.3 Precision-dependent selection

**Proposition 2.6 (which exact theory a proof-requiring inducer settles on) [proved].** Let $T_1,\dots,T_m$ be exact pointwise laws for the same quantity with lengths $\ell_1<\dots<\ell_m$ and errors $e_i$, and let the inducer choose the shortest compatible theory in the pool (the MAP of any prior that decreases with length, or $K_A$ restricted to the pool). Data are i.i.d.
* (G) Under Prop 2.4(c)'s hypotheses at precision $\delta$: almost surely the choice is eventually $T_{i^*(\delta)}$ with $i^*(\delta):=\min\{i:\varepsilon^*_i+\delta_0\le\delta\}$ (if no $i$ qualifies, every theory is eventually refuted). As $\delta$ decreases past the thresholds $\varepsilon^*_i+\delta_0$, the eventual choice moves to longer and more exact theories.
* (R) Under Prop 2.5's hypotheses, for every $\Delta>0$: almost surely the choice is eventually the shortest theory with $\Pr[e_i\ne0]=0$, whatever $\Delta$ is (if none, every theory is eventually refuted). At sample size $n$, $T_i$ survives with probability $(1-p_{\Delta,i})^n$; for $\Delta\ge\varepsilon^*_i$ it is abandoned after about $\Delta/\Ex|e_i|$ data.

*Proof.* Apply Props 2.4 and 2.5 to each $T_i$; the choice at $n$ is the first survivor in order of length, and a finite pool has a last refutation time almost surely. ∎

**Computed [l2 C].** Pool $T_1$ ($\ell=100$, $\varepsilon^*=10'$), $T_2$ ($\ell=150$, $\varepsilon^*=1'$), $T_3$ ($\ell=400$, exact), sinusoidal errors, 2000 runs. Under (G) with $\delta_0=0.5'$ the share of runs choosing the predicted theory at $n=10^4$ is $1.00$ at each of $\delta=20',10.5',5',1.5',1.2'$ (predictions $T_1,T_1,T_2,T_2,T_3$). Under (R) every run ends at $T_3$, with $T_1$ abandoned after about $1/p_1$ data ($94$ at $\Delta=10°$, $9.4$ at $\Delta=1°$) and $T_2$ after about $1/p_2$ ($942$ and $94$).

**Correction of the brief's seed [proved above].** The seed says "the simpler approximate theory is preferred until the data's precision exceeds its error, and the more exact theory after that". This holds in regime G, with switch point $\varepsilon^*+\delta_0$ (Prop 2.4, Prop 2.6(G)). It fails in regime R, which is how rounded measurements behave: there precision belongs to the *data set*, not to the datum, and an exact but false law is refuted after about $\Delta/\Ex|e|$ data however coarse the cells. Naked-eye positions at $\Delta=1°$ refute an exact law that is wrong by a sinusoidal $1'$ after about 94 observations. So in proof-requiring SAI, "approximately true" exact laws survive only against guaranteed tolerances; against rounded data the relevant quantity is the number of data times the error over the precision, and between the exact law and the better theory sit the honest and patched forms of §3. Scout P's Table 2.3 and `philosophy` §4.4 are regime G (interval centres taken as exact, $\delta_0=0$).

---

## 3. Honest approximate laws against laws with exceptions (T3)

### 3.1 Forms, pricings, and what a datum costs

**Setting S3.** The quantity lives on a circle of circumference $\mathsf R$ (for a longitude, $\mathsf R=21600'$); times are i.i.d. from an atomless $\mu$ (so they are almost surely distinct); datum $j$ is the dithered cell of width $\Delta$ containing $q(t_j)$ (Prop 2.5), with $\mathsf R/\Delta$ an integer and $\gamma:=\log(\mathsf R/\Delta)$ its code-Q literal cost. $p:=p_\Delta$, $q:=q_\Delta$ (local notation).

**Definition 3.1 (forms and pricings).**
* **Forms.** $0$: the empty law. $T^{\varepsilon,-S}$: the tolerance law $T^\varepsilon$ patched at the finite set $S$ of times (§1.1); for a data set, the cheapest consistent patch set is the set of times of the data $T^\varepsilon$ refutes (fewer is inconsistent, more only adds cost), and "the patched tolerance law" means that choice. $\varepsilon=0$ gives the exact law with patches, called **E** while it has no patch and **P** afterwards; $\varepsilon=\varepsilon^*$ gives the honest law **H** $=T^{\varepsilon^*}$, which is true and is never patched. **N**: a true exact theory. Lengths: $|0|=0$, $|T_0|=\ell_0$, $|T^\varepsilon|=\ell_0+h$ ($h$ = tolerance clause and numeral, scout N2's $\Delta_\varepsilon$), $|N|=\ell_0+h_N$ (lengths relative to a common part).
* **Pricings** of a datum on which a form is silent ($\gamma_{\rm si}$) and of an exception ($\gamma_{\rm ex}$):
  * **Q/det** (scout N2's model): code Q; patches are deterministic and name the time in the law part: $\gamma_{\rm si}=\gamma$, $\gamma_{\rm ex}=\lambda\pi_c+\gamma$.
  * **Q/rand**: code Q, exceptions randomised: the law is withdrawn at each time independently with probability $\rho$ (a theory machine, §1.3), so that the fit is charged a flag $-\log(1-\rho)$ per kept datum and $-\log\rho+\gamma$ per exception; at the best $\rho$ (the exception share) the rate is $H_2(p)+p\gamma$ (up to an $O(\log n)$ cost of stating $\rho$), i.e. $\gamma_{\rm ex}=\gamma+H_2(p)/p$.
  * **R/det**, **R/rand**: as above, with a silent datum priced by random completion inside the band (Def 1.7): $\gamma_{\rm si}=\beta_e$ of Lemma 3.6 in the coarse regime. An exception of a patched law is priced $\gamma$ in code R too (Prop 1.8(c)).
  R/rand is SAI's own pricing: both the honest law with random completion and the exact law with random exceptions are theory machines whose laws are what $M_A$ mixes (Prop 1.8, Prop 1.9).

**Lemma 3.2 (what the tolerance law does with one datum) [proved; computed: l3 A].** Fix $t$ and $\varepsilon\ge0$. Over the dither,
$$\Pr[T^\varepsilon\text{ refutes}\mid t]=\min\!\Big(\frac{(|e(t)|-\varepsilon)^+}{\Delta},1\Big),\qquad\Pr[T^\varepsilon\text{ proves}\mid t]=\Big(1-\frac{\varepsilon+\max(|e(t)|,\varepsilon)}{\Delta}\Big)^+,$$
and it is silent otherwise. In the *coarse regime* $\Delta\ge\varepsilon+\varepsilon^*$: silent with probability exactly $2\varepsilon/\Delta$, whatever $e(t)$; refutes with probability $(|e(t)|-\varepsilon)^+/\Delta$. For $\varepsilon=0$: refutes with probability $\min(|e|/\Delta,1)$ and is never silent (Prop 2.5).

*Proof.* Place $q(t)$ at $0$. The cell containing it is $[-u\Delta,(1-u)\Delta)$ with $u\sim U[0,1)$, and the band is $B=[e-\varepsilon,e+\varepsilon]$ (as $f=q+e$). By symmetry take $e\ge0$. *Refutation* means $B$ misses the cell; if $e\le\varepsilon$, $0\in B$ and this is impossible; if $e>\varepsilon$, $B\subset(0,\infty)$ and it happens iff $(1-u)\Delta\le e-\varepsilon$, of probability $\min((e-\varepsilon)/\Delta,1)$. *Proof of the datum* means $B\subseteq$ cell: $-u\Delta\le e-\varepsilon$ and $e+\varepsilon<(1-u)\Delta$. If $e\le\varepsilon$ this is $u\in[(\varepsilon-e)/\Delta,(\Delta-\varepsilon-e)/\Delta)$, of length $(1-2\varepsilon/\Delta)^+$; if $e>\varepsilon$ the first condition is automatic and the second is $u<(\Delta-e-\varepsilon)/\Delta$. Both cases equal $(1-(\varepsilon+\max(e,\varepsilon))/\Delta)^+$. In the coarse regime the positive parts are inactive and silence has probability $1-(1-(\varepsilon+\max)/\Delta)-(\max-\varepsilon)/\Delta=2\varepsilon/\Delta$. ∎

### 3.2 Rates and the peakedness criterion

**Proposition 3.3 (rates) [proved; computed: l3 B].** In Setting S3, each form $X$ has $J_\lambda(X;D_n)=a_X+\sum_{j\le n}c_X(d_j)$ with i.i.d. per-datum costs, and in the coarse regime $\Delta\ge2\varepsilon^*$ the rates $m_X:=\Ex c_X$ are:
* $m_0=\gamma$; $m_N=0$; $m_E=\infty$ if $\Pr[e\ne0]>0$ (a refuted unpatched law);
* the patched exact law: $m_P=p\,\gamma_{\rm ex}$ (det: $p(\lambda\pi_c+\gamma)$; rand: $H_2(p)+p\gamma$), with $p=\Ex|e|/\Delta$;
* the honest law: $m_H=q\,\gamma_{\rm si}$, with $q=2\varepsilon^*/\Delta$ (Q: $q\gamma$; R: $q\beta_e$).

*Proof.* For the patched exact law at its cheapest patch set, a datum costs $\gamma_{\rm ex}$ if $T_0$ refutes it and $0$ otherwise (det: the patch names its time, $\lambda\pi_c$, and the datum is then literal, $\gamma$; rand: the flag code); Lemma 3.2 with $\varepsilon=0$ gives the probability $p$. For $H$, a datum costs $\gamma_{\rm si}$ iff $H$ is silent, which in the coarse regime has probability $2\varepsilon^*/\Delta$ (Lemma 3.2), independently of $e(t)$; in code R the conditional cost given silence is Lemma 3.6 (end of §3.3). ∎

**Proposition 3.4 (the peakedness criterion) [proved].** In the coarse regime $\Delta\ge2\varepsilon^*$, under any of the four pricings, the honest law has the lower rate iff
$$\mathrm{pk}(e)\ <\ \frac{\gamma_{\rm ex}}{2\,\gamma_{\rm si}},\qquad\mathrm{pk}(e)=\frac{\varepsilon^*}{\Ex|e|}.$$
*Proof.* $q\gamma_{\rm si}<p\gamma_{\rm ex}$ iff $2\varepsilon^*\gamma_{\rm si}<\Ex|e|\,\gamma_{\rm ex}$. ∎

Specialisations:
* **Q/det:** $\lambda\pi_c>\gamma(2\,\mathrm{pk}(e)-1)$: scout N2's Prop 3.2, confirmed. Computed [l3 B]: for the sinusoid ($\mathrm{pk}=\pi/2$) with $\pi_c=22$, the simulated rates pick P at $\lambda=1$ and H at $\lambda=2$ for $\Delta=2',3',10'$, and H at both for $\Delta=60'$, exactly as the threshold $(\lambda\pi_c+\gamma)/(2\gamma)$ predicts; for the peaked error ($\mathrm{pk}=20$) P everywhere.
* **Q/rand:** $\mathrm{pk}(e)<\tfrac12+H_2(p)/(2p\gamma)$. Since $H_2(p)/p\approx\log(e/p)$ for small $p$, the threshold is below $1\le\mathrm{pk}(e)$ unless $p<e\,2^{-\gamma}=e\Delta/\mathsf R$, and even then it stays near $1$ (it is $1.04$ for $\Ex|e|=0.3'$ at $\Delta=60'$): under question-relative literal pricing with randomised exceptions, the honest law has the lower rate only for errors of nearly constant modulus. [computed: l3 G: the sinusoid ($\mathrm{pk}=\pi/2$) has thresholds $0.64$, $0.74$, $0.97$ at $\Delta=3',10',60'$, so the exact law with random exceptions wins although the error is spread.] Scout N2's verdict in favour of honesty for spread errors rests on the deterministic patches, whose cost $\lambda\pi_c$ of naming a time is what makes exceptions dear; randomised exceptions are cheaper than deterministic ones whenever $H_2(p)<\lambda\pi_c\,p$, which holds for every $p\ge2^{-\lambda\pi_c+2}$ or so (e.g. all $p\ge10^{-5}$ at $\lambda\pi_c=22$).
* **R/rand (SAI's pricing):** $\mathrm{pk}(e)<\big(\gamma+H_2(p)/p\big)/(2\beta_e)$, with $\beta_e\in[0.44,1.44]$. With $\gamma\approx8$–$14$ bits and $H_2(p)/p\approx5$–$12$ bits the threshold is roughly $5$–$30$: honesty wins unless the error is strongly peaked. [computed: l3 G: thresholds $9.2$–$9.3$ for the sinusoid and $20.4$–$20.5$ for the peaked error with $\mathrm{pk}=20$, so under SAI's pricing even that peaked error is held honestly, narrowly.]

So which form an inducer adopts is decided by the shape of the error *and by the relative price of silence*: under literal question-relative pricing silence costs as much as stating the answer, and only expensive exceptions make honesty pay; under SAI's random-completion pricing silence costs at most $\log e$ bits, because a silent honest law still narrows the answer to the two cells its band meets.

### 3.3 The best tolerance: a law within a tolerance, except in a stated share of cases

**Proposition 3.5 (optimal tolerance) [proved; computed: l3 C].** Under Q/det in the regime $\Delta\ge2\varepsilon^*$, the patched tolerance law $T^{\varepsilon,-S}$ ($0\le\varepsilon\le\varepsilon^*$) has rate
$$c(\varepsilon)=\frac{2\varepsilon\,\gamma+(\lambda\pi_c+\gamma)\,\Ex(|e|-\varepsilon)^+}{\Delta}.$$
$c$ is convex; its right derivative is $\big(2\gamma-(\lambda\pi_c+\gamma)\Pr[|e|>\varepsilon]\big)/\Delta$; its minimisers are the $\varepsilon$ with $\Pr[|e|>\varepsilon]\le\theta_{\rm ex}\le\Pr[|e|\ge\varepsilon]$, where
$$\theta_{\rm ex}:=\frac{2\gamma}{\lambda\pi_c+\gamma}.$$
So the optimal law states the $(1-\theta_{\rm ex})$-quantile of $|e|$ as its tolerance and lists the remaining share $\theta_{\rm ex}$ of cases as exceptions. If $\theta_{\rm ex}\ge1$ ($\lambda\pi_c\le\gamma$) the exact law with patches is optimal. The pure honest law ($\varepsilon=\varepsilon^*$, no exceptions) is optimal iff $\Pr[|e|\ge\varepsilon^*]\ge\theta_{\rm ex}$, which for an error distribution without an atom at its maximum never holds. Prop 3.4 (Q/det) compares the two endpoints.

*Proof.* A datum costs $\gamma$ if not proved and in addition $\lambda\pi_c$ if refuted (the patch); by Lemma 3.2 in the regime $\Delta\ge\varepsilon+\varepsilon^*$, $\Pr[\text{not proved}]=(2\varepsilon+\Ex(|e|-\varepsilon)^+)/\Delta$ and $\Pr[\text{refuted}]=\Ex(|e|-\varepsilon)^+/\Delta$. The function $\varepsilon\mapsto\Ex(|e|-\varepsilon)^+$ is convex with right derivative $-\Pr[|e|>\varepsilon]$, which gives convexity and the derivative; a convex function is minimised where its right derivative changes sign. ∎

**Computed [l3 C].** $\Delta=10'$, $\pi_c=22$: for the sinusoid the grid minimiser and the predicted quantile are $0.52$ and $0.496$ ($\lambda=1$, $\theta_{\rm ex}=0.67$), $0.80$ and $0.807$ ($\lambda=2$), $0.94$ and $0.939$ ($\lambda=4$); for $|e|$ uniform on $[0,1]$, $0.33/0.330$, $0.60/0.598$, $0.79/0.776$. The optimal rate is below both endpoints in all six cases.

**Reading [assessment].** The steeper the prior or the dearer the naming of an exception, the smaller $\theta_{\rm ex}$: the inducer states a wider tolerance and lists fewer exceptions. The pure forms "exact with exceptions" and "approximately true" are the two ends of one family; the optimum is in between unless the error has an atom at its maximum. This is the formal shape of a law stated "within $\varepsilon$, except in these circumstances".

**The price of silence under random completion, and fine data.**

**Lemma 3.6 (the code-R price of silence) [proved; computed: l3 A].** In the coarse regime $\Delta\ge2\varepsilon^*$, given that the honest band straddles a cell boundary, the expected code-R cost of the datum is $\log e-H_2(w)$ with $w:=(\varepsilon^*-e(t))/(2\varepsilon^*)$ (the relative position of $q$ in the band). Averaged over times,
$$\gamma_{\rm si}=\beta_e:=\log e-\Ex\,H_2\Big(\frac{\varepsilon^*-e(t)}{2\varepsilon^*}\Big)\ \in[\log e-1,\ \log e]=[0.443,\ 1.443]\text{ bits}.$$
For $\Delta\le2\varepsilon^*$ (fine regime) the expected code-R cost of $H$ per datum lies in $[\log(2\varepsilon^*/\Delta),\ \log(2\varepsilon^*/\Delta)+2\log e]$.

*Proof.* Coarse regime: given a straddle, exactly one boundary lies in the band, at a relative position $V$ that is uniform on $[0,1]$ (a uniformly shifted lattice of spacing $\Delta\ge2\varepsilon^*$). The true cell contains the part of the band on $q$'s side: of relative length $V$ if $w<V$, $1-V$ otherwise; so the expected cost is $\int_w^1-\log V\,dV+\int_0^w-\log(1-V)\,dV=\big(1+w\ln w+(1-w)\ln(1-w)\big)/\ln2=\log e-H_2(w)$. Fine regime: write $L:=2\varepsilon^*\ge\Delta$ and let $y$ be the length of the part of $q$'s cell inside the band; the cost is $\log(L/y)\ge\log(L/\Delta)$. With $a:=wL/\Delta$, $b:=(1-w)L/\Delta$, $y/\Delta=\min(1-u,b)+\min(u,a)$. If $a\ge1$ and $b\ge1$, $y=\Delta$. If $a<1\le b$, $\Ex[-\log(y/\Delta)]=\int_a^1-\log(1-u+a)\,du=\int_a^1-\log s\,ds\le\log e$; symmetrically if $b<1\le a$; if both are below $1$ (possible only when $L<2\Delta$), the two edge terms add at most $\log e$ each. ∎

The simulated averages match: e.g. $0.4422$ against $0.4427$ at $e=0$, $1.4370$ against $1.4365$ at $e=0.999\varepsilon^*$; $\beta_e=0.885$ for the sinusoidal error and $0.493$ for the peaked one [computed: l3 A].

**Proposition 3.7 (fine data) [proved].** For $\Delta\le2\varepsilon^*$ the honest law is silent on every datum. Under code Q its rate is $\gamma=m_0$, so it never beats the empty law, and P beats the empty law iff $p\gamma_{\rm ex}<\gamma$. Under code R its rate is at most $\log(2\varepsilon^*/\Delta)+2\log e$ (Lemma 3.6), below $m_0=\gamma=\log(\mathsf R/\Delta)$ by at least $\log(\mathsf R/2\varepsilon^*)-2\log e$ bits per datum; and if $\varepsilon^*<\mathsf R/(2e^2)$ and $\Pr[|e|<\Delta]\log(1/\Delta)\to0$ as $\Delta\to0$ (e.g. $|e|$ has a bounded density near $0$), then $m_P\ge p\gamma\ge\gamma-\Pr[|e|<\Delta]\gamma$, so the honest law has the lowest rate among $0$, E/P and H for all small $\Delta$. ∎ (Lemma 3.2, Prop 3.3, and $1-p_\Delta=\Ex(1-|e|/\Delta)^+\le\Pr[|e|<\Delta]$.)

So under SAI's pricing an approximate law keeps its value at precisions finer than its error: it narrows each answer to its band, worth $\log(\mathsf R/2\varepsilon^*)$ bits per datum ($\approx13$ bits for a $1'$ Kepler error on a full circle).

### 3.4 Almost-sure selection, phases and switch points

**Theorem 3.8 (almost-sure selection) [proved, given the strong law of large numbers, the central limit theorem, the Hewitt–Savage 0–1 law and Wald's identity (standard; e.g. durrett2019probability)].** Let $\mathcal X$ be a finite set of forms with $J_\lambda(X;D_n)=a_X+\sum_{j\le n}c_X(d_j)$, the $d_j$ i.i.d., $c_X(d)\in[0,b]\cup\{\infty\}$, rates $m_X:=\Ex c_X\in[0,\infty]$, $m_{\min}:=\min_Xm_X<\infty$, $\mathcal X^*:=\{X:m_X=m_{\min}\}$.
* (i) Almost surely, for all large $n$ every $\lambda$-MAP within $\mathcal X$ lies in $\mathcal X^*$. If $\mathcal X^*=\{X^*\}$, the $\lambda$-MAP is eventually $X^*$ alone.
* (ii) (ties) If $X,Y\in\mathcal X^*$ and $c_X-c_Y$ is not almost surely constant, then almost surely $J_\lambda(X;D_n)<J_\lambda(Y;D_n)$ for infinitely many $n$ and $J_\lambda(Y;D_n)<J_\lambda(X;D_n)$ for infinitely many $n$: no eventual winner. If $c_X-c_Y=0$ almost surely, $a_X$ against $a_Y$ decides forever.
* (iii) (switch times) If $m_Y<m_X<\infty$ and $L:=a_Y-a_X>0$, the first time $\tau_L$ at which $J(Y)<J(X)$ satisfies $L/(m_X-m_Y)<\Ex\tau_L\le(L+b)/(m_X-m_Y)$; and on one sample path, as $L\to\infty$, $\tau_L/L\to1/(m_X-m_Y)$ and $\sigma_L/L\to1/(m_X-m_Y)$ almost surely, where $\sigma_L$ is the last time $J(Y)\ge J(X)$.

*Proof.* (i) For $X\notin\mathcal X^*$: if $m_X=\infty$ then $\Pr[c_X=\infty]>0$ (costs are bounded otherwise) and some datum has infinite cost almost surely; otherwise, for $X^*\in\mathcal X^*$, $(J(X)-J(X^*))/n\to m_X-m_{\min}>0$ almost surely by the strong law; $\mathcal X$ is finite. (ii) $S_n:=\sum_{j\le n}(c_X-c_Y)(d_j)$ is a random walk with bounded, mean-zero, non-degenerate increments. For each $K$, $\Pr[S_n>K]\to\frac12$ by the central limit theorem, so $\Pr[S_n>K\text{ i.o.}]\ge\limsup_n\Pr[S_n>K]=\frac12$; this event is invariant under finite permutations of the increments, so by the Hewitt–Savage 0–1 law it has probability $1$. Intersecting over $K\in\mathbb N$, $\limsup S_n=+\infty$ a.s., and likewise $\liminf S_n=-\infty$; so $a_X-a_Y+S_n$ changes sign infinitely often. (iii) $S_n:=\sum(c_X-c_Y)(d_j)$ has i.i.d. increments of mean $\mu:=m_X-m_Y>0$ bounded above by $b$; $\tau_L=\min\{n:S_n>L\}$ is a stopping time with finite mean (positive drift), and Wald's identity gives $\Ex S_{\tau_L}=\mu\Ex\tau_L$ with $L<S_{\tau_L}\le L+b$. For the path statement fix $\epsilon\in(0,\mu)$; by the strong law there is $N(\omega)$ with $|S_n-n\mu|\le\epsilon n$ for $n\ge N$. For $L>\max_{n<N}S_n$, $\tau_L\ge N$, and $S_{\tau_L}>L\ge S_{\tau_L-1}$ gives $L/(\mu+\epsilon)<\tau_L\le L/(\mu-\epsilon)+1$; similarly $S_{\sigma_L}\le L$ with $\sigma_L\ge\tau_L-1\ge N$ gives $\sigma_L\le L/(\mu-\epsilon)$. ∎

**Corollary 3.9 (the four forms, Q/det, coarse data) [proved; computed: l3 D–F].** Assume $\Delta\ge2\varepsilon^*$, $\Pr[e\ne0]>0$, $\varepsilon^*>0$, pool $\{0,\text{E/P},H,N\}$ with $a_0=0$, $a_{E/P}=\lambda\ell_0$, $a_H=\lambda(\ell_0+h)$, $a_N=\lambda(\ell_0+h_N)$. Almost surely:
* (a) the exact law is refuted for the first time at a geometric index of mean $1/p$; until then E and P coincide;
* (b) N is eventually the unique $\lambda$-MAP; the first time it beats H has mean in $[\lambda(h_N-h)/m_H,(\lambda(h_N-h)+\gamma)/m_H]$;
* (c) without N, the eventual $\lambda$-MAP is the form of least rate among $m_0=\gamma$, $m_P=p(\lambda\pi_c+\gamma)$, $m_H=q\gamma$ (H against P by Prop 3.4; ties by Thm 3.8(ii));
* (d) the expected switch points are: $0\to$E at $\lambda\ell_0/\gamma$ (deterministic, if E is not yet refuted); E$\to$P at the first refutation, mean $1/p$; P$\to$H (if $m_P>m_H$) at a time whose mean lies in $[\lambda h/(m_P-m_H),(\lambda h+\lambda\pi_c+\gamma)/(m_P-m_H)]$; H$\to$N as in (b). When these are increasing in this order, the typical sequence of $\lambda$-MAPs is $0\to E\to P\to H\to N$.

*Proof.* Theorem 3.8 with the costs of Prop 3.3 and Lemma 3.2 (refutation by $T_0$ has probability $p$ per datum, independently). The bound in (d) for P$\to$H is Thm 3.8(iii) applied to the race between E/P and H from $n=0$, with level $\lambda h$ and increments in $[-\gamma,\lambda\pi_c+\gamma]$. ∎

**Computed [l3 D–F]** ($\ell_0=200$, $h=20$, $h_N=2000$, $\pi_c=22$; 400 runs per row):
| error, $\Delta$, $\lambda$ | rates $m_P$ / $m_H$ | most frequent MAP sequences | P$\to$H: mean / Wald | H$\to$N: mean / Wald | first refutation / $1/p$ |
|---|---|---|---|---|---|
| sinusoid, $60'$, 1 | 0.323 / 0.283 | 0EPHN (40), 0EPHPHN (36), 0EPHPHPHN (30) | 529.8 / [495.6, 1251.3] | 7010.1 / [6994.9, 7024.9] | 91.8 / 94.3 |
| sinusoid, $60'$, 2 | 0.557 / 0.283 | 0EPHN (105), 0EPHPHN (68), 0PHN (49) | 214.1 / [146.2, 338.1] | 14033 / [13990, 14020] | 97.1 / 94.3 |
| sinusoid, $10'$, 2 | 3.506 / 2.215 | 0HN (176), 0PHN (56) | 38.5 / [31.0, 73.7] | 1792.7 / [1787.5, 1792.5] | 15.4 / 15.7 |
| sinusoid, $3'$, 1 | 7.389 / 8.543 | 0PN (156), 0P0PN (50) | (P has the lower rate) | 232.6 / [231.8, 233.3] | 5.1 / 4.7 |
| peaked, $10'$, 1 | 0.166 / 2.215 | 0EP (358), 0P (33) | (P) | 896.1 / [893.8, 898.8] (N is never the MAP before $n=4000$: P is cheaper than N there) | 198.9 / 199.3 |

The full five-phase sequence $0\to E\to P\to H\to N$ appears when the predicted switch points are ordered (first two rows); when the two rates are close, P and H alternate several times before H settles (Thm 3.8(i) only promises an eventual winner). The few sample means that fall just outside a Wald interval do so by less than one Monte Carlo standard error (about $0.7$ in the third row and $30$ in the second). **Ties** [l3 E]: with $\pi_c$ tuned so that $m_P=m_H$, $J(P)-J(H)$ changes sign $14.9$ times on average up to $n=2000$ and $148$ times up to $n=2\times10^5$, and 43% of runs still change sign after $n=10^5$; with $m_P$ 10% above $m_H$, $15.7$ changes up to $2\times10^5$, the last one at a median $n=664$, none after $10^5$. **Scaling** [l3 F]: on one path, $\tau_L/L=0.293$ at $L=10^5$ against $1/(m_P-m_H)=0.285$.

### 3.5 Humility: the independent mass on finer questions

**Proposition 3.10 (what the pool says about finer questions) [proved].** Let $\Pi_\lambda(X\mid D)\propto2^{-J_\lambda(X;D)}$ be P2's power-prior posterior restricted to a finite pool of deterministic forms (code Q) containing 0, E/P, H and possibly N, and ask a new question at a fresh time with cell width $\Delta'\le2\varepsilon^*$.
* (a) The three-valued prediction of the pool puts mass $\Pi_\lambda(H\mid D)+\Pi_\lambda(0\mid D)$ on "independent"; mass $\Pi_\lambda(E/P\mid D)$ on the cell of $f(t')$, which is wrong with probability $p_{\Delta'}$ over the dither; and mass $\Pi_\lambda(N\mid D)$ on the true cell.
* (b) Without N, almost surely, as $n\to\infty$ the posterior concentrates on the form of least rate at the *training* precision $\Delta$ (Thm 3.8(i): the log-odds diverge linearly). So the inducer ends up either humble (independent mass $\to1$ on finer questions: H selected) or overconfident (asserting a wrong cell with probability $p_{\Delta'}$: P selected), and which one is decided by Prop 3.4 at $\Delta$.
* (c) In a randomised pool (code R), the honest machine is not silent: its random completion decides every question, putting on each cell its share of the band. Its humility is a spread of probability over the cells its band meets, never probability one on a wrong cell; the exact forms put probability $1-\rho$ on the cell of $f(t')$.

*Proof.* (a) H is silent on every question with $\Delta'\le2\varepsilon^*$ (Lemma 3.2); 0 is silent; E/P proves the cell of $f(t')$ ($t'$ is almost surely not a patched time); N proves the true cell. (b) Thm 3.8(i) and $\Pi_\lambda(X)/\Pi_\lambda(Y)=2^{-(J(X)-J(Y))}$. (c) Prop 1.8's machine $G_T$. ∎

**Reading [assessment].** The trichotomy is the formal home of humility *for deterministic theories*: an honest approximate law is a partial theory, and its silence is the "independent" value. Whether the inducer is humble is not a matter of its prior alone (Cor 2.2: the prior favours the overconfident exact law) but of the error's shape and the price of silence, through Prop 3.4. For randomised theories, which is what SAI's one-tape law mixes, humility takes the form of a spread probability instead of an independent label.

### 3.6 The real Kepler residuals

**Data [computed: l4].** For each of Mercury, Venus, the Earth–Moon barycentre (EMB), Mars, Jupiter and Saturn (ERFA's plan94) and the Moon (moon98), and windows of 12–2000 years centred on J2000 (the Moon: one month, one year, 18.6 years), 8000 uniform times; one fixed Kepler ellipse (seven elements) is fitted four ways (scout P's 3-D least squares, least squares on longitude and latitude, a robust fit for small mean error, an $L_p$ continuation for small maximum error), and $e(t)$ is the longitude error in arcminutes. $\varepsilon^*$ is the smallest sample maximum over the fits (an upper bound on the minimax error of a fixed ellipse, up to sampling), $\Ex|e|$ the smallest sample mean. The residual series are saved in `checks/l4_residuals.npz`. The 3-D least-squares column reproduces scout P's Table 2.1 to the expected accuracy (e.g. Moon over one month $66.7'$ against P's $1.12°$; Mars over 12 years $1.71'$ in longitude against P's $1.58'$ angular separation on another sample). The minimax fits are tighter: the Moon is within $30.9'$ of one fixed ellipse in longitude over a month.

| body | $\varepsilon^*$ (12 / 100 / 2000 yr) | $\mathrm{pk}(e)$ range over windows | $\beta_e$ range |
|---|---|---|---|
| Mercury | $0.38'$ / $2.02'$ / $37.4'$ | 3.0–3.5 | 0.56–0.59 |
| Venus | $0.36'$ / $0.47'$ / $3.6'$ | 2.4–3.7 | 0.54–0.66 |
| EMB | $0.27'$ / $0.62'$ / $7.3'$ | 2.4–4.0 | 0.52–0.65 |
| Mars | $1.44'$ / $3.04'$ / $49.9'$ | 3.1–3.5 | 0.55–0.60 |
| Jupiter | $0.70'$ / $6.57'$ / $34.0'$ | 1.9–2.8 | 0.60–0.84 |
| Saturn | $0.17'$ / $7.46'$ / $81.9'$ | 2.3–2.7 | 0.63–0.81 |
| Moon (1 month / 1 yr / 18.6 yr) | $30.9'$ / $156'$ / $480'$ | 1.9–2.5 | 0.66–0.72 |

So **the real Kepler errors are spread**, with peakedness between $1.9$ and $4.0$ (a sinusoid has $\pi/2$; scout N2's peaked example had $20$).

**Selection [computed: l5].** For every body, window, cell width $\Delta\in\{0.1',\dots,1800'\}$ (eleven values), pricing and $\lambda\in\{1,2,4\}$, the per-datum rates of the empty law, the patched exact law (P), the honest law (H) and the whole tolerance family ($\varepsilon\in\{0,0.05\varepsilon^*,\dots,\varepsilon^*\}$, both fits, optimal patches or exception rate) were computed from the saved series: exactly over the dither in the coarse regime (Lemmas 3.2, 3.6), by Monte Carlo (20 dithers per sample) otherwise. The asymptotic $\lambda$-MAP among the forms is the least rate (Thm 3.8(i); Newton not in the pool). Naming a time costs $\pi_c=\log(\text{days in window})+2$ bits (14–22 bits).
* **SAI's pricing (R/rand), and R/det at $\lambda=1$ and $4$ (hence at every $\lambda\ge1$, since $\lambda$ only raises the price of exceptions):** the honest law has the least rate among $0$, P, H for *every* body, window and precision, from $\Delta=0.1'$ to $30°$. In the tolerance family the optimum is $\varepsilon\approx(0.7$–$1.0)\varepsilon^*$ with at most 1% of the data as exceptions. So under SAI's own pricing the inducer holds Kepler's law as approximately true, with a stated tolerance, for every planet and the Moon, and at precisions finer than the error the honest law still narrows each answer to its band (Prop 3.7).
* **Scout N2's pricing (Q/det):** the threshold $(\lambda\pi_c+\gamma)/(2\gamma)$ grows as the cells coarsen ($\gamma$ falls), so for each body and window there is a cell width above which the honest law wins. At $\lambda=1$ the honest law wins only at the coarsest cells ($30°$, in two windows already $10°$), and for 17 of the 39 body-window pairs (e.g. Mars over 12–300 years, the Moon over a month and a year) not even at $30°$; the exact law with exceptions wins from cells of about $\varepsilon^*$ upwards, and at finer cells no law pays (there an honest law is silent at full literal cost). At $\lambda=2$ the takeover width ranges from $10'$ (Jupiter over 30 years) to $30°$, typically $2°$–$10°$; at $\lambda=4$ from $1'$ (Venus over 12 years) to $30°$ (the Moon over 18.6 years), typically $10'$–$60'$. The tolerance family's optimum at $\lambda=1$ is a small tolerance ($0.05$–$0.5\varepsilon^*$) with exception shares up to tens of per cent: a law "exact except in a stated share of cases".
* **Q/rand:** the exact law with random exceptions wins almost everywhere.
* **Check of Prop 3.4:** in all 1757 (body, window, $\Delta$, pricing) cells of the coarse regime the criterion $\mathrm{pk}<\gamma_{\rm ex}/(2\gamma_{\rm si})$ and the exact rates pick the same pure form.

**Reading [assessment].** For Kepler's real errors the peakedness criterion does not decide on its own: the errors are spread enough that the verdict turns on how silence is priced. Under the pricing SAI's one-tape law actually uses (Prop 1.8), where a silent honest law costs at most $\log e$ bits per datum, Kepler's laws are held honestly ("within $\varepsilon$ on this window") at every precision. Under literal pricing they are held as "exact with exceptions" at $\lambda=1$, and honestly only under a steeper prior or at coarse precision. The trichotomy-based humility of Prop 3.10(a) therefore appears for Kepler only in the deterministic, code-Q reading and at steep $\lambda$; in SAI's randomised reading the honest law's humility is a spread probability over the cells its band meets (Prop 3.10(c)). For the cross-check with `philosophy` §4.3: the 3-D least-squares maxima agree with scout P's Table 2.1, and the minimax longitude errors here are the relevant tolerances for interval data in longitude.

---

## 4. Derivation horizons and the sound criterion for approximate reasoning (T4)

**Setting.** Constants $x_0,x_1,\dots$ for the states of a system in $\mathbb R^d$ (or a function symbol on time), over $B=\mathrm{RCF}$; a map $F$ definable in $B$ with a Lipschitz constant $L$ for a norm $|\cdot|$ that $B$ proves (for a linear $F(x)=Ax$ with rational $A$ and the sup-norm, $L=\|A\|_\infty$, provable in $\mathrm{RCF}$). The **honest dynamical law** is $T^\varepsilon_F:=\{|x_0-a|\le e_0\}\cup\{|x_{s+1}-F(x_s)|\le\varepsilon:s\ge0\}$; the **exact law** is $T^0_F:=\{x_0=a\}\cup\{x_{s+1}=F(x_s):s\ge0\}$.

**Proposition 4.1 (derivation horizon) [proved; computed: l6 A, B].**
* (a) $T^\varepsilon_F\vdash|x_r-F^r(a)|\le e_r$ with $e_r:=L^re_0+\varepsilon(L^r-1)/(L-1)$ ($L\ne1$) and $e_r:=e_0+r\varepsilon$ ($L=1$), for every $L\ge0$.
* (b) For linear $F(x)=Ax$ with sup-norm tolerances, the values of $x_{r,i}$ over the models of $B\cup T^\varepsilon_F$ form exactly the interval $(A^ra)_i\pm h_{r,i}$ with $h_{r,i}:=e_0\|(A^r)_{i\cdot}\|_1+\varepsilon\sum_{s<r}\|(A^s)_{i\cdot}\|_1$ (the projection of a zonotope). So $T^\varepsilon_F$ proves "$x_{r,i}\in[v-\delta,v+\delta]$" iff that interval contains $(A^ra)_i\pm h_{r,i}$. In $d=1$, $h_r=e_r$ with $L=|A|$: (a) is tight.
* (c) In $d=1$ with $e_0=0$, a datum at precision $\delta$ about $x_r$ (centred at the honest prediction) is provable iff $r\le r^*(\delta):=\max\{r:e_r\le\delta\}$:
  $r^*(\delta)=\lfloor\delta/\varepsilon\rfloor$ for $L=1$; $\lfloor\log_L(1+\delta(L-1)/\varepsilon)\rfloor$ for $L>1$; for $L<1$, $r^*=\infty$ iff $\delta\ge\varepsilon/(1-L)$ (contracting dynamics have no horizon at tolerances above their limit error), and $\lfloor\log_L(1-\delta(1-L)/\varepsilon)\rfloor$ otherwise.

*Proof.* (a) Induction: $|x_{s+1}-F^{s+1}(a)|\le|x_{s+1}-F(x_s)|+|F(x_s)-F(F^s(a))|\le\varepsilon+Le_s$, each step an instance of the axioms and of the provable Lipschitz inequality. (b) $x_r-A^ra=A^r(x_0-a)+\sum_{s<r}A^{r-1-s}u_s$ with $u_s:=x_{s+1}-Ax_s$, and the deviations $x_0-a$ and $u_s$ range freely over sup-norm boxes in the real model. A linear image of a product of boxes is a zonotope, convex, whose projection on coordinate $i$ has half-width $\sum$ of the $\ell_1$ norms of the corresponding rows; the extreme values are attained by sign choices. Every value in the interval is attained in $\mathbb R$, so a narrower interval statement fails in a model and is unprovable; the full interval follows from the axioms by the triangle inequality, as in (a), with the row sums in place of $L^s$. (c) solves $e_r\le\delta$. ∎

**Computed [l6 A, B].** The closed form agrees with exact interval propagation to $4\times10^{-15}$ (relative) for $r\le200$ and $L\in\{0.5,0.9,0.99,1,1.01,1.1,2\}$, and the horizon formula with the iterated computation in every cell; at $\delta/\varepsilon=10^4$ the horizons are $10^4$, $463$, $72$, $13$ for $L=1,1.01,1.1,2$, and infinite for $L\le0.99$ (limit errors $\le100\varepsilon$). In $d=3$ and $d=10$, for random matrices of spectral radius $0.95$–$1.05$, the exact tolerance $h_{r,i}$ is attained by the constructed sign sequences (50/50 in every row), interval-arithmetic box propagation overestimates it by a median factor of $5$–$300$ at $r=10$ and up to $10^9$ at $r=30$ (the wrapping effect of interval methods), and the $\infty$-norm Lipschitz bound by up to $10^{13}$; the order exact $\le$ box $\le$ Lipschitz held in all cases. So what the honest theory proves is the exact zonotope; a reasoner that propagates boxes has a much shorter effective horizon than the theory.

**Proposition 4.2 (the horizon of an exact approximation) [proved].** Suppose the true trajectory satisfies $T^\varepsilon_F$ but the inducer holds the exact law $T^0_F$ (with the same $a$). Then $T^0_F$ is consistent and proves $x_r=F^r(a)$, which is within $e_r$ of the true $x_r$; for linear $F$ in $d=1$ some true trajectory attains the deviation $e_r$. So the depth-$r$ conclusions of $T^0_F$ are $\delta$-correct for every trajectory compatible with the honest law iff $r\le r^*(\delta)$. And $T^0_F$ together with one true datum at precision below the actual deviation of some $x_r$ is inconsistent, so it proves every sentence.

*Proof.* Prop 4.1(a),(b) applied to the true trajectory, which is a model of $T^\varepsilon_F$; the last claim because the datum and $x_r=F^r(a)$ are jointly refutable in $B$. ∎

**Reading [assessment].** For an exact but false approximation, the length of a derivation bounds the error of its conclusion; for an honest one, the theory itself says how far its conclusions can be trusted, and is silent beyond the horizon. An approximate law's domain of applicability therefore includes a bound on derivation depth. This links the approximation results of this record with the reasoner-relative results of `shape`.

**Proposition 4.3 (a sound criterion for reasoning with approximate models) [proved; computed: l6 D].** Let $T_i:=\{\forall t\in\mathrm{Dom}_i:\ |q(t)-f_i(t)|\le\varepsilon_i\}$, $i\le k$, be honest pointwise models of one quantity $q$ (scalar, or vector-valued with a norm), over a background $B$ true in the intended structure, with $q$ otherwise unconstrained; $T_i^0$ are their exact versions ($\varepsilon_i=0$).
* (a) If every $T_i$ is true, $\bigcup_iT_i$ is consistent and every sentence derivable from $B\cup\bigcup_iT_i$ is true. In particular every derived statement about $q(t)$ is a set containing the true value.
* (b) $\bigcup_iT^0_i$ is inconsistent iff $f_i(t)\ne f_j(t)$ for some $t\in\mathrm{Dom}_i\cap\mathrm{Dom}_j$; it then proves every sentence ("$100=99.9$" gives everything).
* (c) $\bigcup_iT_i$ is consistent iff for each $t$ the balls $\{v:|v-f_i(t)|\le\varepsilon_i\}$, $t\in\mathrm{Dom}_i$, have a common point. For scalar $q$, and for vector $q$ with sup-norm (box) tolerances, this holds iff it holds pairwise: $|f_i(t)-f_j(t)|\le\varepsilon_i+\varepsilon_j$ on every overlap. For Euclidean tolerances in $\mathbb R^m$, $(m+1)$-wise intersection is necessary and sufficient, and pairwise is not sufficient.
* (d) Conclusions carry propagated tolerances: if $g$ is $L_g$-Lipschitz (provably in $B$), $T_i\vdash|g(q(t))-g(f_i(t))|\le L_g\varepsilon_i$; iterated dynamics are Prop 4.1.

*Proof.* (a) The intended structure is a model; derivations preserve truth. (b) Two exact models that disagree at $t$ prove $f_i(t)=f_j(t)$, which $B$ refutes; if they agree on all overlaps, $q(t):=f_i(t)$ for $t\in\mathrm{Dom}_i$ (arbitrary elsewhere) is a model. (c) The models are exactly the choices of $q(t)$ in the intersection, independently for each $t$. Intervals that intersect pairwise have $\max_i(\text{left end})\le\min_j(\text{right end})$, which is a common point (Helly's theorem in dimension 1; boxes are products of intervals). Helly's theorem in $\mathbb R^m$ gives the $(m+1)$-wise criterion [known: helly1923mengen; standard]; three discs centred at the vertices of an equilateral triangle of side $2$ with radius $1.1$ meet pairwise but have no common point (the circumradius is $2/\sqrt3\approx1.155$). (d) Lipschitz inequality in $B$. ∎

**Computed [l6 D].** Pairwise overlap and joint overlap agree on $10^5$ random families of $2$–$6$ intervals and on $2\times10^4$ random families of boxes in $\mathbb R^2$; the disc family above is the explicit counterexample for Euclidean tolerances.

**Remark 4.4 (typical against worst case) [computed: l6 C].** The criterion is worst-case. With $L=1$ and $r=100$ steps, the worst case is $100\varepsilon$; with independent random-sign errors $\pm\varepsilon$ the mean deviation is exactly $\varepsilon\,r\binom{r}{r/2}2^{-r}=7.96\varepsilon$ ($\approx\varepsilon\sqrt{2r/\pi}$; scout N2's simulation gave $7.8\varepsilon$), with uniform errors on $[-\varepsilon,\varepsilon]$ about $4.6\varepsilon$; at $r=1000$, $25.2\varepsilon$ against $1000\varepsilon$; for $L=1.1$, $r=100$, about $2.4\times10^4$ against $1.38\times10^5$. A probabilistic error model answers much further out, with a stated confidence instead of a guarantee.

**What this supplies to `philosophy` T6 (no assessment here).** Prop 4.3 is the formal content behind scout N2's "Possible error" candidate on the domain-of-applicability note: a sound formal criterion exists (state approximations with tolerances and domains; combine them only where the tolerances overlap, which in one dimension is a pairwise check; propagate the tolerances), it blocks the "$100=99.9$" catastrophe exactly (Prop 4.3(b) against (a)), and it is worst-case (Remark 4.4). Whether the note's claim is an error is assessed in `philosophy` §6.1.

---

## 5. The best system as a steeper MAP; explanatory power (T5)

The objective is $J_\lambda(T;D)=\lambda|T|+\mathrm{Exc}_D(T)$ over a class of laws with private literal facts ($\mathcal H^Q$ or $\mathcal H^R$, §1.4). Prop 1.9(d) is why the class matters: over all randomised theories a steeper penalty selects nothing long.

### 5.1 Marginal slopes and explanatory power

**Proposition 5.1 (marginal slopes) [proved].** Let $T^*$ be a $\lambda$-MAP within a family of theories that contains $T^*\setminus\mathcal A$ and $T^*\cup\mathcal B$ for the modules considered. For every module $\mathcal A\subseteq T^*$: $\mathrm{Exc}_D(T^*\setminus\mathcal A)-\mathrm{Exc}_D(T^*)\ge\lambda\|\mathcal A\|$. For every $\mathcal B$ disjoint from $T^*$: $\mathrm{Exc}_D(T^*)-\mathrm{Exc}_D(T^*\cup\mathcal B)\le\lambda\|\mathcal B\|$.

*Proof.* $J_\lambda(T^*)\le J_\lambda(T^*\setminus\mathcal A)$ and $J_\lambda(T^*)\le J_\lambda(T^*\cup\mathcal B)$, with $|T^*|-|T^*\setminus\mathcal A|=\|\mathcal A\|$ and $|T^*\cup\mathcal B|-|T^*|=\|\mathcal B\|$ (Def 1.2). ∎

**Definition 5.2 (explanatory power; NOTATION §6.4).** $\mathrm{EP}_D(\mathcal A;T):=\big(\mathrm{Exc}_D(T\setminus\mathcal A)-\mathrm{Exc}_D(T)\big)/\|\mathcal A\|$: bits of data explained by the module per bit of its statement, in the context $T$. By Prop 5.1 every module of a $\lambda$-MAP has $\mathrm{EP}\ge\lambda$, and no addition has $\mathrm{EP}>\lambda$. On a hull edge (P2 `lem:setup:hull`) the edge slope is the explanatory power of the bits added along it, on average over the edge (P2 `rem:kink:reading`). EP depends on the context: a law and the initial conditions it needs explain nothing apart and much together.

**Proposition 5.3 (facts used once never enter for $\lambda>1$) [proved; (b) given Prop 1.11 and P2 `cor:kink:split`].**
* (a) If adding one sentence $\chi$ to $T$ turns exactly the exceptions $E_\chi\subseteq D$ into proved data and changes nothing else, $\mathrm{EP}_D(\{\chi\};T\cup\{\chi\})=\sum_{d\in E_\chi}\gamma(d)/\ell(\chi)$. For a datum's answer stated as an axiom ($E_\chi=\{d\}$), this is $\gamma(d)/\ell(a)$, which is at most $1$ whenever the axiom code is no shorter than the literal code; then no $\lambda$-MAP with $\lambda>1$ contains it.
* (b) On average no code does better. Let $T_s$ be $b$-sufficient ($|T_s|+\mathrm{Exc}_D(T_s)\le K(y_D\mid\dom D)+b$) in a class where provability on the data is decidable. Every theory $T$ has $\mathrm{Exc}_D(T)\ge\mathrm{Exc}_D(T_s)-(|T|-|T_s|)-(b+\kappa)$. So a module $\mathcal A$ added to $T_s$ has $\mathrm{EP}_D(\mathcal A;T_s\cup\mathcal A)\le1+(b+\kappa)/\|\mathcal A\|$, and every $\lambda$-MAP with $\lambda>1$ has $|T|\le|T_s|+(b+\kappa)/(\lambda-1)$.

*Proof.* (a) Definition 5.2. (b) Prop 1.11(b) is the coding bound $|T|+\mathrm{Exc}_D(T)\ge K(y_D\mid\dom D)-\kappa$, which with $b$-sufficiency is the right line of slope $1$ of P2 `cor:kink:split`(a); that corollary gives the length bound. ∎

So at $\lambda=1$ a fact that explains only itself is excluded only by the code's per-axiom overhead, while any $\lambda>1$ excludes every module whose explanatory power is below $\lambda$; facts used once never qualify.

### 5.2 Laws, initial conditions and contingent facts

**Definition 5.4 (the solar-system toy; scout N2 §4.2).** Bodies $b\le m$ with $n_b$ observations, each of literal cost $c$ (code Q). Modules: the law $\Lambda$ ($L$ bits); body $b$'s elements $E_b$ ($k$ bits); $K3$ ($L_3$ bits), which shortens every elements module by $s$ bits ($0<s<k$; it derives the period from the semi-major axis). $\Lambda\cup E_b$ proves all of $b$'s observations; no other combination proves any observation (laws alone answer no position question, `philosophy` T4 / scout P's Prop 2.1; elements alone answer none). Theories are $(\Lambda?,K3?,S)$, $S$ the bodies whose elements are axioms.

**Proposition 5.5 (the $\lambda$-MAP in closed form) [proved; computed: l7 A, C].** Put $k_\Lambda:=k$, $k_{\Lambda+K3}:=k-s$, $N:=\sum_bn_b$. The optimal values of the three law choices are
$$J^*_\emptyset=cN,\qquad J^*_\Lambda=\lambda L+\sum_b\min(cn_b,\lambda k),\qquad J^*_{\Lambda+K3}=\lambda(L+L_3)+\sum_b\min(cn_b,\lambda(k-s)),$$
attained by $S_\chi(\lambda):=\{b:cn_b>\lambda k_\chi\}$ (bodies with $cn_b=\lambda k_\chi$ may go either way), and the $\lambda$-MAP is the best of the three. (K3 without $\Lambda$ is useless.) In particular:
* (a) $\Lambda$ beats the empty theory iff $\sum_{b\in S_\Lambda(\lambda)}(cn_b-\lambda k)>\lambda L$.
* (b) $J^*_{\Lambda+K3}-J^*_\Lambda=\lambda L_3-\sum_b\big[\min(cn_b,\lambda k)-\min(cn_b,\lambda(k-s))\big]$. If no body has $\lambda(k-s)<cn_b\le\lambda k$ (so $S$ is the same with and without $K3$), **$K3$ enters iff $s|S|>L_3$, whatever $\lambda$ is.**
* (c) In the MAP $T^*=\Lambda\cup\{E_b:b\in S\}$: $\mathrm{EP}(\Lambda)=c\sum_{b\in S}n_b/L$ and $\mathrm{EP}(E_b)=cn_b/k_\chi$. With $m$ bodies of $n$ observations each these are $mnc/L$ and $nc/k_\chi$.

*Proof.* For a fixed law choice, $J_\lambda$ is a constant plus $\sum_b$ (the cost of body $b$), where including $E_b$ costs $\lambda k_\chi$ and excluding it costs $cn_b$; minimise each term. (b): the bracket is $\lambda s$ when $cn_b>\lambda k$, $cn_b-\lambda(k-s)$ in between, $0$ otherwise. (c): deleting $\Lambda$ (resp. $E_b$) makes exactly the observations of the bodies in $S$ (resp. of $b$) literal. ∎

**Refuted: scout N2's stated $K3$ criterion** (Prop 4.5 there: "K3 is in the $\lambda$-MAP iff $s\cdot|S(\lambda)|>\lambda L_3$" when $S$ is the same under both choices). *Counterexample* [computed: l7 A]: 15 bodies with 1000 observations each, $L=300$, $L_3=150$, $k=60$, $s=15$, $c=12.4$, $\lambda=2$: $J(\Lambda+K3+\text{all})=2250<J(\Lambda+\text{all})=2400$, so $K3$ enters; $s|S|=225>L_3=150$, but $s|S|<\lambda L_3=300$. Over 2100 random cases (2–8 bodies, random parameters, seven values of $\lambda$) the closed form agrees with brute force in all 2100; among the 1473 cases with the same $S$ under both choices, "$s|S|>L_3$" is right in all 1473 and N2's statement in 1280. N2's computed tables were obtained by evaluating all choices and are unaffected; l7 C reproduces them: on N2's population, "law + 8 planets" is the $\lambda$-MAP for $\lambda\in(7.03,135.37)$, a vertex with incoming slope $135.37$ and outgoing slope $7.03$ (ratio $19.3$), and $K3$ enters below $\lambda=7$, where asteroids raise $|S|$ (at $\lambda=6.75$, $K3$ is in although $s|S(\lambda)|=135<L_3$: with $K3$ more bodies pay for their elements, the second case of (b)).

**Reading [assessment].**
* **$K3$ is a law about initial conditions** in an exact sense: it explains no datum; it compresses the elements. Both the bits it costs and the bits it saves are law-part bits, so its entry is decided at exchange rate $1$ ($s|S|$ against $L_3$), not at the balance $\lambda$; $\lambda$ matters only through which bodies' elements are in the theory.
* **The model–randomness split of P2 does not separate laws from initial conditions.** Well-observed bodies' elements have $\mathrm{EP}=cn_b/k$ in the hundreds and sit on the steep side of the hull with the law; what the split separates is facts reused across many data from facts used once (Prop 5.3), which correct the brief's seed ("a steeper prior separates laws ... from contingent facts such as orbital elements").
* **What singles out the law is how its explanatory power scales:** with the number of systems ($mnc/L$), while the elements' scales only with the observations of one system ($nc/k$) [computed: l7 D: with $n=5$ observations per body, $\mathrm{EP}(\Lambda)=20.7$ at $m=100$ and $207$ at $m=1000$, while each body's elements have $\mathrm{EP}=1.38$ (with $K3$)]. In the toy the law needs the elements to explain anything, so with few observations per body neither enters at $\lambda$ above $nc/k_\chi$.

**Proposition 5.6 (Lewis's "kind nature" is a kink) [proved, given P2 `lem:setup:hull` and `cor:kink:locate`; computed: l7 B].** For a family of candidate theories satisfying the hull lemma's hypotheses (Prop 1.10) and $0\le\tau<\sigma\le\infty$, the following are equivalent:
* (a) the set of $\lambda$-MAPs is the same for every $\lambda\in(\tau,\sigma)$;
* (b) some hull vertex $v_i$ has $\sigma_{i+1}\le\tau$ and $\sigma\le\sigma_i$;
* (c) the point family has a zero-window $(\sigma,\tau)$-kink at a point that is a hull vertex.

*Proof.* (b)⇒(a): by P2 `lem:setup:hull`(v), for $\lambda\in(\sigma_{i+1},\sigma_i)$ the $\lambda$-MAPs are exactly the programs at $v_i$. (a)⇒(b): if some edge slope $\sigma_j$ lay in $(\tau,\sigma)$, the $\lambda$-MAP set at $\lambda=\sigma_j$ (the programs on the closed edge $[v_{j-1},v_j]$, by (v)) would differ from the set just below $\sigma_j$ (the programs at $v_j$ only), since $v_{j-1}\ne v_j$; so $(\tau,\sigma)$ lies in one interval $(\sigma_{i+1},\sigma_i)$. (b)⇔(c): P2 `cor:kink:locate`(c), both directions. ∎

**Computed [l7 B, C].** On 400 random point families with 10 random intervals each, "MAP set constant on $(\tau,\sigma)$", tested exactly at every pairwise crossing point and between consecutive ones, agrees with (b) in 4000/4000 cases. In N2's toy the best system "law + 8 planets" is robust over $(7.03,135.37)$, a factor of $19.3$ in the balance.

**Reading [assessment].** Lewis's best-systems account balances simplicity against strength, and Lewis wrote that how good the best balance is "will depend on how kind nature is" [known: lewis1994humean; content: secondary, the quoted sentence and the page 478 seen in a citing source found by WebSearch, not in Lewis's text]. In the steeper objective the balance is $\lambda$, strength is fit to data in a fixed base language, and nature is kind on an interval of balances exactly when the data's hull has a kink there: then every balance in the interval selects the same system, and the worry that the best system depends on an arbitrary choice of balance [known: woodward2014simplicity; content: abstract/secondary via `philosophy`] is moot inside the interval. Below the kink (here $\lambda<7$) the selected system changes with every asteroid. Kindness is a checkable property of a language, a candidate family and a data set, not of nature alone.

**Proposition 5.7 (the trivialisation is blocked) [proved, given Prop 1.11].** Let $\mathcal L'\supseteq\mathcal L$ be any extension of the language (e.g. by Lewis's predicate $F$ true of exactly the actual things, with the axiom $\forall xFx$), and let the data be base-language answers whose provability from the theories considered is decidable. Then every finite $T$ in $\mathcal L'$ consistent with $D$ has $|T|+\mathrm{Exc}^Q_D(T)\ge K(y_D\mid\dom D)-c$ (and $|T|+n+\mathrm{Exc}^Q_D(T)\ge K(y_D\mid\dom D)-c$ without decidability).

*Proof.* Prop 1.11 does not use the language: its decoder searches for proofs from $T$ of base-language answers. ∎

**Reading [assessment].** Lewis's trivialisation worry [known: lewis1983new; content: secondary] is that a predicate true of exactly the actual things makes "$\forall xFx$" maximally simple and strong. Measured as derivation of base-language data with a coding bound, $F$ buys nothing: its connection to the data must be stated in the bridge axioms, and these pay for every bit. What remains is the choice of base language and of which questions are data, Cohen and Callender's relativisation of best systems to a vocabulary [known: cohen2009better; content: abstract/secondary via `philosophy`].

### 5.3 Explanatory power, unification and Myrvold's measure

**Proposition 5.8 (EP as likelihood ratio; Myrvold's unification term) [proved; computed: l7 E].** Write $P_T(D):=2^{-\mathrm{Exc}_D(T)}$ (code Q or R) and, for a hypothesis $h$ and background $T_\flat$, $I(h;D\mid T_\flat):=\log\big(P_{T_\flat\cup h}(D)/P_{T_\flat}(D)\big)$ and $U(D_1,D_2;h\mid T_\flat):=I(h;D_1\cup D_2\mid T_\flat)-I(h;D_1\mid T_\flat)-I(h;D_2\mid T_\flat)$ for data sets on disjoint questions.
* (a) $\|\mathcal A\|\cdot\mathrm{EP}_D(\mathcal A;T)=I(\mathcal A;D\mid T\setminus\mathcal A)$.
* (b) If $P_T$ is a product over questions (Prop 1.10: $\mathcal H^Q$ on pointwise laws, $\mathcal H^R$ on distinct times), $U(D_1,D_2;\mathcal A\mid T_\flat)=0$ for every split: in the two-part code with stated parameters, explanatory power is additive over data.
* (c) Let $h$ be a law family with a $k$-bit parameter $\theta$ (uniform prior), $P_h(D):=2^{-k}\sum_\theta P_{h\cup\{\theta\}}(D)$, and $P_\emptyset$ a product. If each of $D_1$, $D_2$ is proved by $h\cup\{\theta^*\}$ and has likelihood $0$ under every other $\theta$, then $U(D_1,D_2;h)=k$. If $\theta=(\theta_1,\theta_2)$ with $D_i$ depending only on $\theta_i$, $U=0$. If $\theta_i=(C,\phi_i)$ share a $k_C$-bit constant $C$ and each $D_i$ identifies $(C,\phi_i)$, $U=k_C$.

*Proof.* (a) Definition. (b) $\log P$ is additive over the questions for $T_\flat\cup\mathcal A$ and for $T_\flat$. (c) In the first case $P_h(D_1)=P_h(D_2)=P_h(D_1\cup D_2)=2^{-k}$, so $U=-k-(-k-k)=k$ (the $P_\emptyset$ terms cancel because $P_\emptyset$ is a product). In the second, $P_h(D_1\cup D_2)=P_h(D_1)P_h(D_2)$. In the third, $P_h(D_i)=2^{-k_C-k_\phi}$ and $P_h(D_1\cup D_2)=2^{-k_C-2k_\phi}$, so $U=k_C$. ∎

**Computed [l7 E].** With $k=6$, observations given by a random table: stated parameter, $U=0.00$; marginalised parameter, one body, $U=6.00$; two bodies with independent parameters, $U=0.00$; two bodies sharing a 3-bit constant, $U=3.00$.

**Relation to Myrvold [known: myrvold2003bayesian; content: secondary].** Myrvold's account, as reported in search summaries of his paper and of its critics, measures unification as the degree to which a hypothesis makes phenomena informationally relevant to one another (later called "mutual information unification"), and shows that the support a hypothesis gets from joint evidence splits into the supports from the parts plus this term. $U$ above has that form (an identity once $P_\emptyset$ is a product); his exact notation was not checked against his text. The precise relation:
* EP is the *total* support per bit of statement in the two-part code, where parameters are stated; there Myrvold's term is identically zero (Prop 5.8(b)), and unification appears instead as a module whose EP grows with the number of systems it serves (§5.2).
* Myrvold's term is the support due to *shared unknown parameters* when they are integrated out (Prop 5.8(c)): $k$ bits within one system, nothing across systems with independent initial conditions, and $k_C$ bits across systems that share a constant. A law with a universal constant (the third-law constant, $G$) unifies across systems in his sense; a law whose systems share nothing unifies across them only in the EP sense.
* The two accounts book the same bits in different places. Take Copernicus against Ptolemy (scout N2 §4.4, `philosophy` §3.4): Ptolemy with free epicycle phases pays the coincidence of each superior planet's retrogression with opposition in its likelihood, $a_p$ bits per planet; Ptolemy with the coincidences stated as axioms pays $\sum_pa_p$ bits in the law part; Copernicus pays its heliocentric reorganisation, $H$ bits, once. In the two-part code the heliocentric module has $\mathrm{EP}=\sum_pa_p/H$ against the stated coincidences, with no change in fit: unification without better prediction [proved; the lengths are not measured]; it is in the best system for $\lambda<\sum_pa_p/H$. In the marginal-likelihood account the same $\sum_pa_p$ bits appear as Copernicus's extra likelihood against free-phase Ptolemy. At $\lambda=1$ the totals agree; a steeper prior penalises the version that states the coincidences more.

**Relation to ILP compression [known: muggleton1995inverse; content: secondary (the author's Progol page: search "guided by compression", trading the description of errors against hypothesis length)].** At $\lambda=1$, adding a module lowers $J_1$ iff its EP exceeds $1$: positive compression. EP is the per-bit form, and the steeper objective asks for compression at rate $\lambda$.

**Proposition 5.9 (laws and initial conditions in the question format) [proved; computed: l7 D].** Let the data be conditional questions "given the elements $\alpha_b$ of body $b$, is $\ell$ the case?", compatible with $T$ when $B\cup T\cup\{\alpha_b\}\vdash\ell$ (`shape`'s format, NOTATION §3.2). In the toy, an elements module $E_b$ with the same content as $\alpha_b$ adds nothing ($T\cup\{\alpha_b\}\cup E_b$ and $T\cup\{\alpha_b\}$ prove the same), so $\mathrm{EP}(E_b)=0$ and no $\lambda$-MAP contains elements; $\Lambda$ alone answers every question, with $\mathrm{EP}(\Lambda)=cN/L$ however the $N$ observations are spread over bodies.

*Proof.* Immediate from the definition of compatibility. ∎

So in the question format the laws/initial-conditions distinction is the distinction between theory and question antecedent: the laws answer conditional questions with no elements at all, while the Ramsey sentence of the laws answers no unconditioned position question (`philosophy` T4, scout P's Prop 2.1; not re-proved here).

---

## 6. Domains of applicability and retention of superseded theories (T6)

### 6.1 When a domain restriction pays

**Setting.** A law $\Lambda$ with per-system elements. For the systems in a set $G$, $\Lambda$ with their elements proves their data; for one further system $M$ (the Moon) $\Lambda$ with $M$'s elements ($k_M$ bits) has per-datum rates $m^M_P$ (exact law, exceptions patched; Prop 3.3) and $m^M_H$ (an honest tolerance for $M$, at a one-off cost $h_M$), against the literal rate $\gamma$. The **domain-restricted law** $\Lambda_{\rm Dom}:=\forall b\,(\mathrm{Dom}(b)\to\text{law}(b))$, with $\mathrm{Dom}$ a definable predicate that $B$ proves of the systems in $G$ and refutes of $M$, costs $\|\mathrm{Dom}\|$ more than $\Lambda$ (a few bits if "Planet" is a base predicate; about $\log(\#\text{systems})$ to name $M$), and leaves $M$'s $n_M$ data literal.

**Proposition 6.1 (domain restriction) [proved; computed: l8 A].**
* (a) $J_\lambda(\Lambda_{\rm Dom})-J_\lambda(\Lambda+E_M\text{ with }M\text{'s exceptions})=\lambda\|\mathrm{Dom}\|-\lambda k_M+\sum_{d\in D_M}\big(\gamma(d)-c_P(d)\big)$, and likewise against the honest treatment of $M$ with $\lambda(k_M+h_M)$ and $c_H$. (This is scout N2's C16, made exact: restriction pays iff the domain clause plus the literal cost of the excluded data is below the cost of $M$ under the law.)
* (b) As $n_M\to\infty$ with i.i.d. data, almost surely the restriction is eventually in the $\lambda$-MAP iff $\gamma<\min(m^M_P,m^M_H)$: the law, even with exceptions or an honest tolerance, describes $M$ worse than no law (Thm 3.8(i)); otherwise $M$ is eventually kept, in its cheaper form.
* (c) Under SAI's pricing (code R), $m^M_H\le\log(2\varepsilon^*_M/\Delta)+2\log e<\gamma=\log(\mathsf R/\Delta)$ in the fine regime whenever $\varepsilon^*_M<\mathsf R/(2e^2)$ (about $24°$ for a longitude), and $m^M_H\le q\log e<\gamma$ in the coarse regime (for $\Delta<\mathsf R/e$). So for every system the law confines to within about $24°$, a domain restriction never pays asymptotically: the system is kept with its own, wider tolerance. Under code Q at $\Delta\le2\varepsilon^*_M$ the honest law is silent at the literal rate, $m^M_H=\gamma$, and the restriction pays asymptotically iff $m^M_P>\gamma$.

*Proof.* (a) The two theories differ in the domain clause, $M$'s elements, and the treatment of $M$'s data; $G$'s data are proved by both. (b) Thm 3.8(i) applied to the three forms of $M$'s data. (c) Lemma 3.6 and Lemma 3.2; $\log(2\varepsilon^*/\Delta)+2\log e<\log(\mathsf R/\Delta)$ iff $2e^2\varepsilon^*<\mathsf R$. ∎

**Computed [l8 A]** (the Moon as $M$, one fixed ellipse over one year, $\varepsilon^*_M=156'=2.6°$, $\Ex|e|=61.7'$; $k_M=60$, $h_M=20$, $\|\mathrm{Dom}\|=4$, $\pi_c=10.5$):

| $\Delta$ | code Q, $\lambda=1$ | code Q, $\lambda=2$ | code R, $\lambda=1,2$ |
|---|---|---|---|
| $10'$, $60'$ | Moon excluded (honest law silent at the literal rate; patches dearer) | excluded | Moon kept with an honest $2.6°$ tolerance (rate $5.0$, resp. $2.4$ bits against $\gamma=11.1$, $8.5$); it overtakes exclusion after 12–25 Moon data |
| $300'$ | kept, exact with exceptions | kept, exact with exceptions (after $\approx194$ data) | honest |
| $600'$ | exceptions | honest (rates within $0.001$: $34542$ data to overtake) | honest |
| $1800'$ | exceptions | honest | honest |

**Reading [assessment].** Scout N2's illustration, "the Moon is excluded by a domain axiom", is a code-Q phenomenon at fine precision. Under the pricing SAI uses, the inducer does not cut the Moon out of Kepler's law; it keeps it with a tolerance of a few degrees. A domain of applicability then shows up as a *tolerance that depends on the system and the window*, not as a sharp boundary; a sharp boundary is selected only when even an honest tolerance is worse than literal data (for longitudes, a band wider than about $24°$).

### 6.2 Retention of a superseded theory by usage cost

**Setting.** The honest Kepler law $K$ (tolerance $\varepsilon_K$ on a window) and an exact successor $N$, with derivation charges: a datum proved from $T$ costs $r_d\cdot dl_T(d)$ bits, where $dl_T(d)$ is the size of the derivation used; write $c_K:=r_d\,dl_K$, $c_N:=r_d\,dl_N$ per proved datum, $c_K<c_N$. $J^{\rm der}_\lambda(T;D):=\lambda|T|+\mathrm{Exc}_D(T)+\sum_{d\text{ proved}}r_d\,dl_T(d)$.

**Proposition 6.2 (retention) [proved; computed: l8 B].**
* (a) For finite $n$: $K$ beats $N$ iff $\lambda(|N|-|K|)+\sum_d\big(c_N-c_K\big)[d\text{ proved by }K]+c_N\cdot\#\{d\text{ not proved by }K\}>\mathrm{Exc}_D(K)$: derivation savings plus the length difference against the lost fit (scout N2's C17, made exact).
* (b) With i.i.d. data the rates are $m_K=q_K\gamma_{\rm si}+(1-q_K)c_K$ and $m_N=c_N$, and almost surely $K$ is eventually the $\lambda$-MAP among $\{K,N\}$ iff $m_K<m_N$, whatever $\lambda$ and the lengths are (Thm 3.8(i)).
* (c) If $\gamma_{\rm si}\ge c_K$, the set of cell widths at which $K$ is retained is an interval $[\Delta^*,\infty)$: $q_K=\min(2\varepsilon_K/\Delta,1)$ and $\gamma_{\rm si}$ are non-increasing in $\Delta$, so $m_K=c_K+q_K(\gamma_{\rm si}-c_K)$ is non-increasing. In the coarse regime under code Q, $\Delta^*$ solves $2\varepsilon_K(\gamma(\Delta)-c_K)/\Delta=c_N-c_K$, i.e. $\Delta^*\approx2\varepsilon_K\gamma/(c_N-c_K)$.

*Proof.* (a) Compare the two objectives term by term. (b) Thm 3.8(i) with the costs of Prop 3.3 plus the derivation charges. (c) Monotonicity as stated; the equation is $m_K=m_N$ with $q_K=2\varepsilon_K/\Delta$. ∎

**Computed [l8 B]** (derivation sizes *assumed*, not measured: $dl_N/dl_K=1000$, as for a validated integration against solving Kepler's equation): the least cell width $\Delta^*$ at which Kepler is retained, for $c_N=0.01,\,0.1,\,1$ bits per datum: Mars over 12 years $1200',\,197',\,28'$ under code Q and $177',\,17.8',\,2.9'$ under code R; Mars over 2000 years $10800',\,2980',\,541'$ (Q) and $5770',\,580',\,102'$ (R); the Moon over one month $8460',\,2100',\,369'$ (Q) and $4520',\,454',\,62'$ (R).

**Reading [assessment].** A superseded theory's domain of applicability is where its derivation savings exceed its fit loss: coarse enough data, short enough windows, and expensive enough derivations from the successor. This is how practice treats Newtonian mechanics after relativity and Kepler's ellipses after Newton. Under SAI's pricing the retention region reaches about ten times finer precision than under literal pricing, because the honest law's silence is cheap.

---

## 7. Explanation by approximate correction: a provable toy (T7)

**Setting.** Language: $\mathrm{RCF}$ plus constants $x_{t,1},x_{t,2}$ for $t\le W$ (a planar state per time step). $R$ is the rotation with $\cos=3/5$, $\sin=4/5$; $P$ a rational $2\times2$ matrix; $\eta=1/100$; $A:=R+\eta P$; $a=(1,0)$. Write $|\cdot|$ for the Euclidean norm; inequalities $|v|\le\varepsilon$ are stated as $|v|^2\le\varepsilon^2$ with rational $\varepsilon^2$.
* The **old exact law** with its initial condition: $T_0^W:=\{x_t=R^ta:t\le W\}$ (uniform circular motion).
* The **successor**: $T_N^W:=\{x_0=a\}\cup\{x_{t+1}=Ax_t:t<W\}$.
* The **honest old law on the window**: $H^\varepsilon_W:=\{|x_t-R^ta|\le\varepsilon:t\le W\}$.

**Proposition 7.1 (the successor derives the honest law and refutes the exact one) [proved; computed: l9].**
* (a) $T_N^W\vdash H^{\varepsilon}_W$ for every rational $\varepsilon\ge\varepsilon(W):=((1+\eta\|P\|)^W-1)|a|$ ($\|P\|$ the operator norm).
* (b) $T_N^W\vdash H^\varepsilon_W$ iff $\varepsilon^2\ge\varepsilon_{\min}(W)^2:=\max_{t\le W}|A^ta-R^ta|^2$, a rational number. So $\varepsilon_{\min}(W)\le\varepsilon(W)$, and $H^{\varepsilon_{\min}(W)}_W$ is the strongest honest form of the old law on the window that the successor proves.
* (c) If $\eta Pa\ne0$, $T_N^W\vdash\neg T_0^W$ (already $x_1=Aa\ne Ra$).
* (d) $H^\varepsilon_W$ is a common consequence of $T_0^W$ and $T_N^W$ iff $\varepsilon\ge\varepsilon_{\min}(W)$; the strongest common honest consequence is $H^{\varepsilon_{\min}(W)}_W$.
* (e) The derivations exist, and the natural one (instantiate the recurrence $t$ times, write each $x_t$ as an exact rational vector, verify $W+1$ numerical inequalities) writes numerals of total bit size $\sum_{t\le W}\mathrm{bits}(A^ta)=O(W^2\log h)$, $h$ the height of the entries of $A$ [proved for the numerals; the polynomial size of derivations of binary numeral arithmetic from the field axioms is standard and not written out: proof sketch].

*Proof.* (a) Since $\|R\|=1$ and $\|A\|\le1+\eta\|P\|$, $\delta_t:=|A^ta-R^ta|$ satisfies $\delta_{t+1}=|A(A^ta-R^ta)+\eta PR^ta|\le(1+\eta\|P\|)\delta_t+\eta\|P\||a|$ with $\delta_0=0$, so $\delta_t\le((1+\eta\|P\|)^t-1)|a|$; and $T_N^W$ proves $x_t=A^ta$ (below). (b) In every model of $B\cup T_N^W$ (any real closed field) the recurrence determines $x_t=A^ta$, a rational vector, since $\mathbb Q$ embeds uniquely into every ordered field. So each conjunct of $H^\varepsilon_W$ is equivalent over $B\cup T_N^W$ to a fixed inequality between rationals, which $\mathrm{RCF}$ proves or refutes; by completeness $T_N^W\vdash H^\varepsilon_W$ iff all $W+1$ inequalities hold. (c) $T_N^W\vdash x_1=Aa$ and $T_0^W\vdash x_1=Ra$, with $Aa-Ra=\eta Pa\ne0$. (d) $T_0^W$ proves $x_t=R^ta$, hence $H^\varepsilon_W$ for every $\varepsilon\ge0$; combine with (b). (e) The numerals are those of $A^ta$; their sizes are computed. ∎

**Computed [l9]** (exact rational arithmetic), for three perturbations with $\|P\|=1$:

| $P$ | $\varepsilon_{\min}(W)$ for $W=1,10,100,200$ | bound $\varepsilon(W)$ | refitted circle, $W=10,100$ | numeral bits, $W=10,100$ |
|---|---|---|---|---|
| $JR$ (outward spiral and precession) | $0.0100,\ 0.0999,\ 0.961,\ 1.69$ | $0.0100,\ 0.105,\ 1.70,\ 6.32$ | $2.5\times10^{-4},\ 2.5\times10^{-3}$ | $1894,\ 1.8\times10^5$ |
| $SR$, $S=\mathrm{diag}(1,-1)$ (distortion) | $0.0100,\ 0.0127,\ 0.0186,\ 0.0243$ | same | $8.9\times10^{-3},\ 1.0\times10^{-2}$ | $1430,\ 1.3\times10^5$ |
| $I$ (spiral) | $0.0100,\ 0.103,\ 1.33,\ 3.49$ | same | $3.7\times10^{-2},\ 0.80$ | $1322,\ 1.3\times10^5$ |

In each case $T_N$ refutes $T_0$ at $t=1$. The general bound is nearly tight for small windows when the perturbation accumulates ($JR$, $I$), and very loose for a bounded distortion ($SR$: ratio $0.004$ at $W=200$). The refitted circle (radius and angular speed fitted on the window, floating point, for comparison only) absorbs the precession almost entirely in the first case and the growth not at all in the third: the toy analogue of the fitted ellipses of §3.6.

**Reading [assessment].**
* The successor does not entail the old law; it contradicts its exact form (c), which is Duhem's observation about Newton and Kepler [known: duhem1954aim; content: secondary, via `philosophy`'s refs.bib]. What it derives is the old law's honest form on a window, with a tolerance that it also determines, and that grows with the window: the old law's domain of applicability is derived, not stipulated.
* The honest form is exactly what the old and the new theory have in common (d). This is the formal content of "the successor explains why the old law worked", and it is Schaffner's picture of reduction to a corrected reduced theory [known: schaffner1967approaches; content: abstract and secondary, via `philosophy`], in a case where the corrected theory is the honest law.
* In SAI terms (Prop 2.1): every datum proved by $H^\varepsilon_W$ with $\varepsilon\ge\varepsilon_{\min}(W)$ is proved by $T_N^W$, and true data (the toy's truth is $T_N$) that refute $T_0^W$ refute neither $T_N^W$ nor $H^\varepsilon_W$. So the honest form of an approximate law is the form that is both humble (§3.5) and explicable by its successor; the exact form is neither.
* Scope: the toy is linear and discrete; it does not touch the real difficulty of deriving "Kepler within $\varepsilon$ on $W$" from Newton (existence theorems and validated integration; scout P §2.5–2.6), which is the textbook point of `shape`.

---

## 8. Learning a domain of applicability (T8, extension: partial)

T8 asks whether the posterior over theories "$\mathrm{Dom}(x)\to\text{law}(x)$" on a hand-picked pool finds "planet $\wedge$ window" and excludes the Moon. What §§3.6 and 6.1 already settle:
* **Under SAI's pricing, a sharp domain is not what is learned [computed: l5, l8 A].** For every planet and window and for the Moon (over a month, a year, 18.6 years), the honest law with its own tolerance has a lower rate than leaving the body's data literal (Prop 6.1(c): this holds for any band narrower than about $24°$). The inducer therefore keeps every body under the law and learns a *tolerance per body and window* ($\varepsilon^*$ from $0.17'$ to $82'$ for the planets, $31'$ to $8°$ for the Moon; §3.6 table), not a domain that excludes the Moon.
* **Under literal pricing (code Q) at fine precision, the Moon is excluded** (Prop 6.1(b), l8 A at $\Delta=10'$, $60'$), and the domain clause costs only $\|\mathrm{Dom}\|$, a few bits for a base predicate.
* **A window as a domain.** Restricting a law to $|t|<W$ pays, by the same comparison, only when the data outside the window are better left literal than given a wider tolerance; under code R this again requires a band wider than about $24°$, which for the planets happens only over tens of millennia (Mars's error grows from $1.4'$ over 12 years to $50'$ over 2000 years). [assessment from the computed growth; a pool over windows was not computed.]

**Open.** A posterior computation over an explicit pool of domain predicates (base predicates, windows, their conjunctions) with stated syntax costs, as scout P's Q8 proposes. Given the above, the expected answer is pricing-dependent: honest tolerances under SAI's pricing, sharp domains under literal pricing at fine precision.

---

## 9. What this shows, and what is known

### 9.1 What this shows (for the paper; the philosophical assessment is `philosophy`'s)

* **"Kepler's laws give only approximately correct predictions" is a limitation of proof-requiring compatibility with deterministic theories, not of the axiom view as such.** Over deterministic theories, data never favour a hedge over the stronger theory (Prop 2.1), exact but false laws survive only against guaranteed tolerances (Prop 2.4), and rounded data refute them at any precision (Prop 2.5). SAI's one-tape law mixes randomised theories, which price exceptions and silence relative to the question (Prop 1.8). It is itself the best two-part code over such theories (Prop 1.9(a)), and among them an honest approximate law ("within $\varepsilon$ on this window", with random completion inside the band) competes and, for Kepler's real errors, wins at every precision (§3.6).
* **Honest law or law with exceptions** is decided by the error's peakedness against the ratio of the price of an exception to the price of silence (Prop 3.4). The optimum of the whole family is a tolerance with a stated share $\theta_{\rm ex}$ of exceptions (Prop 3.5). Selection is almost sure, with explicit switch points (Thm 3.8, Cor 3.9).
* **Precision.** The seed "the simpler approximate theory is preferred until the data's precision exceeds its error" holds for guaranteed tolerances; for rounded data the relevant quantity is the number of data times the error over the precision (§2.3).
* **Humility.** A deterministic honest law is a partial theory; its silence is the "independent" value. A randomised honest law spreads probability over its band (Prop 3.10).
* **Domains of applicability.** A sound formal criterion for reasoning with approximate models exists (Prop 4.3); approximate dynamical laws have derivation horizons, tight for linear dynamics (Prop 4.1, 4.2). Under SAI's pricing, domains appear as tolerances per system and window rather than as sharp boundaries (Prop 6.1); a superseded theory is retained where its derivation savings exceed its fit loss (Prop 6.2).
* **Best systems.** Lewis's account has an exact form as a steeper MAP over laws with private literal facts, and only there (Prop 1.9(d)). "Kind nature" is a kink of the data's hull (Prop 5.6), and the trivialisation is blocked by the coding bound (Prop 5.7). The model–randomness split separates reused facts from facts used once, not laws from initial conditions. Laws are singled out by how their explanatory power scales with the number of systems, and $K3$ is a law about initial conditions that enters at exchange rate $1$ (Prop 5.5). In the question format, initial conditions are question antecedents (Prop 5.9).
* **Explanation.** Explanatory power is per-bit support in the two-part code; Myrvold's unification term is the information carried by shared unknown parameters (Prop 5.8). The honest form of an approximate law is exactly what its successor derives and what the two theories have in common (Prop 7.1).

**What it does not show.** The language, the question families and the costs (lengths $\ell_0$, $h$, $\pi_c$, $k$) are model inputs; the derivation sizes of §6.2 are assumed; the real-residual analysis uses one-dimensional longitudes with dithered cells and one fixed ellipse per window; §7 is a linear discrete toy and does not derive "Kepler within $\varepsilon$" from Newton; T8's posterior over domain predicates was not computed.

### 9.2 Relation to known work

* **Precision-dependent selection** is known in other forms: Akaike-based accounts of simplicity and unification [known: forster1994how; content: abstract], and MDL and MML, where the measurement precision of the data enters the code length [known: rissanen1978modeling, wallace2005statistical, grunwald2007minimum; content: abstract/secondary]. What is specific here is the 0/1 proof-requiring compatibility of axiom inducers, its two regimes (Props 2.4–2.6), and the honest/exception dichotomy with its peakedness criterion and tolerance quantile (Props 3.4, 3.5), which neither scout L nor our searches found stated.
* **Two-part codes with exceptions and compression-guided theory search** are MDL [as above] and inductive logic programming [known: muggleton1995inverse; content: secondary]; EP $>\lambda$ is positive compression at rate $\lambda$ (§5.3).
* **The model/noise split** is algorithmic statistics [known: gacs2001algorithmic, vereshchagin2004kolmogorov; content: abstract]; P2's kink results, on which §5 rests, build on it.
* **Theory plus initial conditions in raw-data prediction**: a complete theory as an objective theory plus the observer's location [known: hutter2010complete; content: abstract]. In the question format of §5.3 that location is a question antecedent.
* **Best systems**: Lewis [known: lewis1983new, lewis1994humean; content: secondary], the language-relative version [known: cohen2009better; content: secondary], worries about the balance [known: woodward2014simplicity; content: abstract].
* **Unification**: Friedman, Kitcher [known: friedman1974explanation, kitcher1981explanatory; content: secondary/abstract], Myrvold (§5.3).
* **Approximation and truthlikeness**: our notion of approximate truth is local (a question family, a tolerance, a window) and avoids a global comparison of false theories, which Popper's definition could not supply [known: popper1963conjectures, miller1974popper, tichy1974popper; content: secondary] and the similarity approach supplies only relative to a metric [known: niiniluoto1987truthlikeness; content: secondary]. Structuralist accounts make approximation a feature of a theory's application [known: moulines1976approximate; content: abstract of a companion paper]; our honest laws are a first-order, per-question analogue (the relation is not checked against the text). Rules that hold with high probability and tolerate counterexamples [known: valiant2000robust, juba2013implicit; content: secondary/abstract] are the analogue of the law with random exceptions.
* **Reduction and correction**: Duhem, Schaffner (§7).

---

## 10. Refuted and qualified claims (kept with their counterexamples)

1. **[refuted] Scout N2's stated $K3$ criterion** (Prop 4.5 there): "$K3$ is in the $\lambda$-MAP iff $s|S(\lambda)|>\lambda L_3$" when $S$ is the same under both choices. Counterexample (l7 A): 15 bodies with 1000 observations, $L=300$, $L_3=150$, $k=60$, $s=15$, $c=12.4$, $\lambda=2$: $K3$ enters ($2250<2400$) though $s|S|=225<\lambda L_3=300$. Correct: $s|S|>L_3$ (Prop 5.5(b)). N2's tables used brute force and stand.
2. **[refuted as pricing-independent] "Spread-out errors favour honest approximate laws; concentrated errors favour exact laws with exceptions"** (scout N2 §3.2). It holds under deterministic patches (Q/det) as N2's criterion says. Under Q/rand the sinusoid ($\mathrm{pk}=\pi/2$) is held as exact with exceptions at $\Delta=3'$–$60'$; under R/rand the peaked error ($\mathrm{pk}=20$) is held honestly at $\Delta=3'$–$60'$ (l3 G). The correct statement is Prop 3.4: peakedness against the price ratio $\gamma_{\rm ex}/2\gamma_{\rm si}$.
3. **[qualified] "A steeper prior favours honesty"** (scout N2 §3.2): true when exceptions are named in the law part (det); with randomised exceptions the flags are fit, and $\lambda$ drops out of the comparison of rates.
4. **[qualified] "The Moon is excluded by a domain axiom"** (scout N2 C16): true under code Q at fine precision (l8 A); under SAI's pricing the Moon is kept with an honest tolerance of a few degrees (Prop 6.1(c)).
5. **[corrected, minor]** Scout N2's typical deviation after 100 random-sign steps, $7.8\varepsilon$ (simulated), is exactly $7.96\varepsilon$ (Remark 4.4).
6. **[qualified] Scout P's Prop 2.3** ("proof-requiring SAI prefers a false exact law to its true tolerance-weakened version on every data set"): proved for deterministic hypotheses (Cor 2.2); within $M_A$, randomised honest theories keep positive weight after the exact law is refuted and win on Kepler's residuals (§3.6).
7. **[corrections of the brief's seeds, not of the author]** precision-dependent selection (§2.3); laws versus initial conditions (§5.2).

---

## 11. Notation requests

* $\pi_c$ (cost of naming a time) clashes with P2's program letter $\pi$; local here. If the paper needs it globally, $\varpi$ or $c_{\rm time}$.
* **Clash, local fix needed:** $q$ is both the quantity $q(t)$ and the silence probability $q_\Delta$; the paper should rename the silence probability (e.g. $s_\Delta$).
* $p_\Delta$, $\gamma_{\rm ex}$, $\gamma_{\rm si}$, $\beta_e$, $\theta_{\rm ex}$: local; if Prop 3.4 goes into the paper, $\gamma_{\rm ex}$, $\gamma_{\rm si}$ and $\beta_e$ should be added to NOTATION §6.4.
* Exception codes: request superscripts $\mathrm{Exc}^Q$, $\mathrm{Exc}^F$, $\mathrm{Exc}^R$ in NOTATION §6.4 (the draft defines only "the literal cost"). $P^R_T$ (the random-completion law) is local.
* Module length: $\mathrm{EP}_D(\mathcal A;T)$ divides by $\|\mathcal A\|=\sum_{\chi\in\mathcal A}\ell(\chi)$, which NOTATION writes $|\mathcal A|$; the difference is the theory code's stop bit.
* The letter H for the honest form clashes with $H_2$ (entropy) and with P2's classes $\mathcal H$; in the paper write $T^{\varepsilon^*}$, as NOTATION does.
* §7 uses $R$ (a rotation), which NOTATION reserves for the predicate of literal data; local to §7.

---

## 12. References and their verification status

All keys are in `refs.bib` (this folder), 28 entries, each with a comment saying what was confirmed and at what level (source, abstract, secondary). Seventeen are copied from `../philosophy/refs.bib`, where they were re-verified by WebSearch on 2026-10-16; eleven were searched here on 2026-10-16: Rissanen 1978, Wallace 2005, Grünwald 2007, Gács–Tromp–Vitányi 2001, Vereshchagin–Vitányi 2004, Hutter 2010, Muggleton 1995, Helly 1923, Tarski 1951, Church 1936, Durrett 2019 (Myrvold and Lewis were also searched here for content). Direct fetches of publisher pages failed (DNS errors, proxy 403), so no full text was seen. In particular:
* Myrvold's exact formula was not seen (content from abstracts and summaries of his paper and its critics);
* Lewis's "kind nature" sentence was seen only in a citing source;
* the section numbers of the standard probability results in Durrett were not checked.

Standard results used without a specific page: Tarski's decidability of real closed fields, Church's theorem, Helly's theorem, the strong law of large numbers, the central limit theorem, the Hewitt–Savage 0–1 law, Wald's identity [known; standard: tarski1951decision, church1936note, helly1923mengen, durrett2019probability].

---

## 13. Status of every claim

| item | claim | status |
|---|---|---|
| Prop 1.4 | laws plus listed exceptions are deterministic hypotheses; $K_A\le|T|+\mathrm{Exc}^F+c$ | proved |
| Lemma 1.6 | provability/refutation/consistency of interval data from pointwise interval laws are decidable | proved |
| Prop 1.8 | SAI pays question-relative exception costs: $L_A\le K(T)+\mathrm{Exc}^R+c$; code Q with one question per time | proved |
| Prop 1.9 | $L_A=\min_G[K(G)-\log\nu_G]\pm c$; restricted minima are upper bounds, none within $O(1)$ in general ($J^Q_1\ge n$ vs $L_A\le c$); steeper selection over all theory machines collapses | proved, given `fundamentals` Thm 4.1, Prop 1.8(d), §6 and P2 `prop:kink:universal` |
| Prop 1.10 | P2's hypotheses: all hold in $\mathcal H^R$; in $\mathcal H^Q$ lower semicomputability fails (Church), point-family results hold | proved, given P2 |
| Prop 1.11 | coding bound for laws with literal exceptions (flags or decidability) | proved |
| Prop 2.1, Cor 2.2 | proof-requiring compatibility is monotone in logical strength; scout P's Prop 2.3 | proved |
| Prop 2.3 | precision monotonicity | proved |
| Prop 2.4 | regime G: sharp threshold $\varepsilon^*+\delta_0$, a.s. refutation below | proved; computed (l2 A) |
| Prop 2.5 | regime R: survival $(1-p_\Delta)^n$, refutation at any precision | proved; computed (l2 B) |
| Prop 2.6 | eventual choice among exact theories, regimes G and R | proved; computed (l2 C) |
| Lemma 3.2 | prove/silent/refute probabilities of a tolerance law | proved; computed (l3 A) |
| Lemma 3.6 | code-R price of silence $\beta_e\in[0.443,1.443]$; fine-regime bounds | proved; computed (l3 A) |
| Prop 3.3 | per-datum rates of the forms under four pricings | proved; computed (l3 B, G) |
| Prop 3.4 | peakedness criterion $\mathrm{pk}<\gamma_{\rm ex}/2\gamma_{\rm si}$ | proved; computed (l3 B, G; l5 D: 1757/1757) |
| Prop 3.5 | optimal tolerance at the $(1-\theta_{\rm ex})$-quantile, $\theta_{\rm ex}=2\gamma/(\lambda\pi_c+\gamma)$ (Q/det) | proved; computed (l3 C) |
| Prop 3.7 | fine data: honest law useless in code Q, saves $\log(\mathsf R/2\varepsilon^*)-2\log e$ bits in code R | proved |
| Thm 3.8 | a.s. selection; ties oscillate; Wald bounds and a.s. scaling of switch times | proved, given SLLN, CLT, Hewitt–Savage, Wald; computed (l3 D–F) |
| Cor 3.9 | phases $0\to E\to P\to H\to N$ and switch points | proved; computed (l3 D) |
| Prop 3.10 | independent mass on finer questions = share of honest (and empty) theories; randomised humility | proved |
| §3.6 | real Kepler residuals: pk 1.9–4.0; honest law at every precision under SAI's pricing; exceptions under N2's at $\lambda=1$ | computed (l4, l5) |
| Prop 4.1 | derivation horizon $e_r$; tight zonotope for linear maps; $r^*(\delta)$ | proved; computed (l6 A, B) |
| Prop 4.2 | horizon of correctness of an exact approximation | proved |
| Prop 4.3 | sound criterion: honest models consistent and sound; exact ones explode; pairwise check in 1-D and for boxes, $(m+1)$-wise for balls | proved (Helly known); computed (l6 D) |
| Remark 4.4 | typical vs worst case ($7.96\varepsilon$ vs $100\varepsilon$) | computed (l6 C) |
| Prop 5.1 | marginal slopes of a $\lambda$-MAP | proved |
| Prop 5.3 | facts used once never enter for $\lambda>1$; length bound around a sufficient law | proved ((b) given Prop 1.11 and P2 `cor:kink:split`) |
| Prop 5.5 | closed-form $\lambda$-MAP of the solar-system toy; $K3$ enters iff $s|S|>L_3$ | proved; computed (l7 A, C) |
| N2 Prop 4.5's $K3$ criterion | $s|S(\lambda)|>\lambda L_3$ | **refuted** (§10.1) |
| Prop 5.6 | kind nature iff kink (best system constant on an interval iff hull vertex) | proved, given P2; computed (l7 B: 4000/4000) |
| Prop 5.7 | trivialisation blocked | proved, given Prop 1.11 |
| Prop 5.8 | EP = per-bit log-likelihood ratio; Myrvold's term $0$ with stated parameters, $k$ / $0$ / $k_C$ with marginalised ones | proved; computed (l7 E) |
| Copernicus–Ptolemy | heliocentric module has $\mathrm{EP}=\sum_pa_p/H$, unification without better prediction | proved (lengths not measured) |
| Prop 5.9 | question format: elements never enter, $\mathrm{EP}(\Lambda)=cN/L$ | proved; computed (l7 D) |
| Prop 6.1 | when a domain restriction pays; never asymptotically under code R for bands below $\approx24°$ | proved; computed (l8 A) |
| Prop 6.2 | retention of a superseded theory; retention region $[\Delta^*,\infty)$ | proved; computed (l8 B; derivation sizes assumed) |
| Prop 7.1 (a)–(d) | successor proves the honest law (tolerance $\varepsilon(W)$, exactly $\varepsilon_{\min}(W)$), refutes the exact law; honest law is the strongest common consequence | proved; computed (l9) |
| Prop 7.1 (e) | derivations of polynomial size in $W$ | proof sketch (numeral sizes computed) |
| §8 (T8) | under SAI's pricing tolerances, not sharp domains, are learned | assessment from computed results (l5, l8); pool computation open |
| §10.2–10.4, 10.6 | pricing-independent readings of N2/P | refuted or qualified (l3 G, l8 A, §3.6) |

---

## 14. Verification log

1. **Reading.** The thread brief and the project brief in full; NOTATION-draft and select.md in full; scout N2's record in full and its `n2`, `n3` scripts; scout P's §2 and §5 and `c1_kepler_fit.py`; scout F's F14; the `fundamentals` record §1 and §5 (definitions of $M_A$, $W_A$, $K_A$; Thm 4.1, Thm 5.1, Prop 5.2 cited); the `philosophy` record's sections that cite this thread (§3.3, §3.4, §4.3, §4.6, §5.2–5.3, §6.1); P2's `setup.tex`, `kinks.tex`, `app-setup.tex`, `app-kinks.tex` (the hull lemma, coding bound, kink lemma, `cor:kink:locate`, `cor:kink:split`, `thm:kink:converse`, `prop:kink:universal`, with their proofs, to check which hypotheses each uses).
2. **Restart.** The earlier run of this thread left `checks/l4_kepler_pk.py` (unrun) and, in the scratchpad, re-runs of scout N2's `n2` and `n3` whose outputs were identical to the saved ones apart from the timing line (re-checked with `diff` in this run). `l4` was reviewed: its copied machinery was compared with scout P's `c1_kepler_fit.py` by AST: `eq_to_ecl`, `moon_pv`, `kepler_xyz` and the constants are identical, and `planet_pv`, `osculating` and `model` differ only in docstrings, line breaks and `model` being c1's seven-element "free_n" variant. Its selection part was removed (rewritten as `l5`, for the corrected criteria).
3. **Literature.** §12. WebSearch worked in this run; WebFetch and curl to publisher hosts failed (DNS errors, proxy 403), so contents are at abstract or secondary level, as marked. `refs.bib` parses with BibTeX (plain style, `\nocite{*}`, 28 entries, no warnings) in a scratch copy.
4. **Scripts** (all in `checks/`, seeded with 20261016 or deterministic, outputs saved next to them; each was run on a scratch copy and in place, and the two outputs compared with `diff`, ignoring the runtime line):
   * `l2_precision.py` (17 s): regimes G and R, pool selection. Identical.
   * `l3_phases.py` (15 s): Lemma 3.2, Lemma 3.6, rates, criterion, optimal tolerance, phases, ties, scaling, four pricings. Identical. Defects found and fixed during the work: the first version timed the P/H race from the first refutation instead of from $n=0$ (E is P with no patch), and lacked a coarse-data row in which all five phases appear; part F's levels were extended to $10^5$; a lemma label was renamed.
   * `l4_kepler_pk.py` (31 min): residuals and peakedness; series saved in `l4_residuals.npz` (3.4 MB). Determinism re-run on a scratch copy: see item 7.
   * `l5_kepler_select.py` (5 min): selection on the real residuals. The first version averaged over random dithers in the coarse regime, where refutation probabilities are near $10^{-4}$, and its predicted and simulated winners disagreed in 5 of 133 smoke-test cells by Monte Carlo noise; the coarse regime is now averaged exactly (Lemmas 3.2, 3.6), after which agreement is 1757/1757. A pipe through `head` once killed a smoke run before it wrote its output; it was re-run.
   * `l6_horizons.py` (3 s): horizons, zonotope against box and Lipschitz, typical against worst case, Helly checks. Identical. Defects fixed: a horizon cell exactly at the contraction limit ($L=0.9$, $\delta/\varepsilon=10$) was decided by rounding (now a tolerance), and means over matrices were dominated by outliers (now medians).
   * `l7_best_system.py` (3 s): closed form against brute force (2100/2100), $K3$ criteria, Prop 5.6 (exact test, 4000/4000; an earlier grid test gave 4 spurious mismatches when a breakpoint lay within one grid step of an interval end), N2's population, EP scaling, Myrvold's term. Identical.
   * `l8_domains.py` (<1 s): domain restriction and retention. Identical. The first parametrisation of retention (derivation charges $\ge100$ bits per datum) made Newton never win; it was replaced by per-datum charges $c_N\in\{0.01,0.1,1\}$ bits.
   * `l9_correction.py` (4 s, exact rational arithmetic): the correction toy. Identical. The general bound held at every $W$ checked.
5. **Proofs: self-checks.**
   * Prop 1.8 uses distinct question indices per time; several data at one time are handled by intersecting their cells (Def 1.7), so no consistency issue arises.
   * Prop 1.10(ii): the non-lower-semicomputability argument uses $D=\emptyset$ and Church's theorem; for pointwise interval laws everything is decidable.
   * Lemma 3.2's coarse-regime formulas need $\Delta\ge\varepsilon+|e(t)|$ for every $t$; Prop 3.5 uses them for all $\varepsilon\le\varepsilon^*$, hence needs $\Delta\ge2\varepsilon^*$, as stated.
   * Thm 3.8 assumes bounded finite costs; the exact law's infinite cost is the only unbounded one and is handled separately.
   * Prop 5.5's ties ($cn_b=\lambda k_\chi$) give several MAPs; the brute force breaks ties towards shorter theories.
   * Prop 5.6 counts programs at the same point as the same MAP point.
   * Prop 7.1(b) uses that $\mathbb Q$ embeds uniquely into every ordered field, so the recurrence determines rational values in every model.
   * The fine-regime code-R bound of Lemma 3.6 is an upper bound and is used as such in `l8` B.
6. **Not done.** T8's posterior over an explicit pool of domain predicates; measured derivation sizes for §6.2; a formal derivation-size bound for §7 beyond the numeral sizes.
7. **Determinism of l4 and l5.** `l5` was re-run on a scratch copy (with a copy of `l4_residuals.npz`): output identical apart from the runtime line. `l4` was re-run on a scratch copy (2645 s under heavy machine load from other threads' jobs): the full output is identical to the saved `l4_kepler_pk.out` apart from the runtime line, and all 117 arrays in the re-run `l4_residuals.npz` are bitwise equal to the saved ones.

