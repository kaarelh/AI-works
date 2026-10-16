# Thread `laws`: approximate laws, exceptions and the best system (final record)

*Final record of thread `laws`, revision round of 2026-10-16. Folder `research/tracks/laws/`; scripts and their saved outputs in `checks/`; the referees' code in `referee_code/`. It replaces the development record `notes.md`, which is kept unchanged. This record is self-contained: every result is stated and proved (or its status given) here, and nothing below needs `notes.md`. Item numbers are those of `notes.md` wherever an item survives, so that citations by other threads stay valid. New items carry letter suffixes (Prop 3.3a, Prop 3.6a). Where an item changed, §14 says how.*

*Briefs read in full: the thread brief `00-brief.md` and the project brief `../../00-brief.md`. The project brief contains the author's request, which names "kepler's laws not really giving you correct predictions but giving approximately correct predictions" as a limitation; the seeds "Approximate theories", "Laws versus initial conditions" and "Explanation"; and the epistemic policy. Binding notation: `../../NOTATION-draft.md` (§6.4 fixes $J_\lambda$, $\mathrm{Exc}_D$, $\mathrm{EP}_D$, $T_0$, $T^\varepsilon$, $e(t)$, $\varepsilon^*$, $\delta$, $\delta_0$, $\Delta$, $\mathrm{pk}(e)$, $\gamma$). "SAI" is the working name's abbreviation; no argument below depends on the name. Other sources:*
* *Scout records: scout N2 (`../../scouts/novel-science/notes.md`), scout P (`../../scouts/philosophy/notes.md` §2, §5), scout F's F14, scout L's §5.*
* *The other threads' current records, for which see §15.*
* *SOI Paper 2 ("P2", `../../../../solomonoff-operator-induction/paper-steeper/sections/{setup,kinks,app-setup,app-kinks}.tex`), cited by LaTeX label.*
* *The two referee reports `referee-A.md` and `referee-B.md` with their code.*

**Status tags.**
* [proved]: full proof here.
* [proved, given X]: the proof uses the cited result X.
* [computed: script, part]: the script and its saved output are named.
* [known: key; content level]: a published result. Its bibliographic data were verified by WebSearch (this thread, `philosophy`, scout L or a referee, as `refs.bib` says), and its content was checked at the stated level (source, abstract or secondary).
* [proof sketch]: the argument, with the missing steps named.
* [conjecture], [open], and [refuted] (kept with its counterexample).
* [assessment]: a considered judgement argued in the text.

**Local notation** (defined here, not global; see §11).
* $\pi_c$: bits to name one time inside a law sentence (scout N2's $\pi_c$).
* $p_\Delta:=\Ex\min(|e(t)|/\Delta,1)$: the probability that the exact law refutes a dithered datum of cell width $\Delta$.
* $s_\Delta:=\min(2\varepsilon^*/\Delta,1)$: the probability that the honest law is silent on it. (`notes.md` wrote $q_\Delta$, which clashed with the quantity $q(t)$.)
* $\gamma_{\rm ex}$, $\gamma_{\rm si}$: the cost in bits of one exception, and of one datum on which a law is silent (§3.2). $\beta_e$: the code-R price of silence (Lemma 3.6). $\theta_{\rm ex}$: the optimal share of exceptions of a tolerance law (§3.3).
* $H_2(x):=-x\log x-(1-x)\log(1-x)$, the binary entropy; $H_{\rm nat}:=H_2\ln2$.
* Band coordinates: the band $[f(t)-\varepsilon,f(t)+\varepsilon]$ mapped affinely onto $[0,1]$. The true value sits at $x(t):=(\varepsilon-e(t))/(2\varepsilon)$ and the law's value $f(t)$ at $\tfrac12$.
* $\mathrm{BC}_G$, $\mathrm{HY}(\rho)$, $\mathrm{SH}$: band-confined completions (Def 3.6a).
* In §7 only: a rotation $R$ of the plane and a perturbation size $\eta$. (P2's $\eta_{\mathcal N}$ is not used in §7; NOTATION's predicate $R$ does not occur in §7.)

---

## 0. Summary

**T1, the objective and SAI.**
* "Law plus listed exceptions" is a deterministic hypothesis of $W_A$ and $M_A$ when the exceptions carry their full sentences (Prop 1.4).
* $M_A$'s mixture also contains randomised theories. These complete a law at random inside what it allows, and so pay only question-relative costs for data the law is silent on (Prop 1.8).
* $L_A$ *is* the best two-part code over all theory machines, up to $\pm c$ (Prop 1.9(a)). Neither $K_A$ nor literal-exception codes over finite theories match it within $O(1)$ (Prop 1.9(c)); for pointwise interval laws this is open (Remark 1.9a).
* Over all theory machines a steeper penalty collapses onto the universal machine (Prop 1.9(d)). So best-system analyses use classes of laws with private literal facts. In those classes P2's hull, kink and converse results apply, and the coding bound is proved directly (Props 1.10, 1.11).

**T2, precision.**
* Over deterministic theories, proof-requiring compatibility is monotone in logical strength, so data never move the odds towards a hedge (Prop 2.1). This is scout P's Prop 2.3.
* Under guaranteed tolerances the switch point is sharp at $\varepsilon^*+\delta_0$ (Prop 2.4).
* Under dithered rounding, an exact but false law survives $n$ data with probability $(1-p_\Delta)^n$, so it is refuted after about $\Delta/\Ex|e|$ data however coarse the cells (Prop 2.5).
* The brief's precision seed is corrected accordingly (§2.3).

**T3, honest laws, laws with exceptions, laws with error models.**
* *Setting.* Data are about fresh times, with i.i.d. errors and dithers (Setting S3). Deterministic patches that name each time at a fixed cost are only a finite-horizon cost model: any code pays at least $H_2(p)/p$ bits per exception, and literal numerals at least $\log n$ (Prop 3.3a).
* *Deterministic theories (code Q).* The honest law beats the exact law with exceptions iff $\mathrm{pk}(e)<\gamma_{\rm ex}/(2\gamma_{\rm si})$ (Prop 3.4). The optimum of the whole family states the $(1-\theta_{\rm ex})$-quantile of the error as tolerance and lists the rest as exceptions (Prop 3.5; known in form from $\nu$-SVR).
* *SAI's randomised theories.* The silence cost of the honest band is known exactly at every precision (Lemma 3.6: at most $\log e$ bits above $\log(2\varepsilon^*/\Delta)$, and decreasing in $\Delta$). But the uniform band is the best completion inside the band only for uniform errors (Gibbs), and no theory machine beats the law together with its true error distribution (Prop 3.6a(a)–(c)).
* *The two-point form.* "Exact, except in a share $\rho$, then within $\varepsilon$" beats the uniform band iff $\Ex\ln(1+|e|/\varepsilon)<2\ln2-1$. This requires peakedness above $1.79$, and holds whenever it is above $2.12$ (Prop 3.6a(d); after referee B).
* *Almost-sure selection.* It holds under integrable costs; ties oscillate under finite variance; switch times satisfy Wald bounds and scale linearly (Thm 3.8). The phases $0\to E\to P\to H\to N$ follow, also with exact theory-machine costs (Cor 3.9).
* *Humility.* For deterministic theories, humility is the "independent" mass of the honest law. For randomised ones, it is calibration (Prop 3.10).

**T3, the real Kepler residuals** (seven bodies; windows of 12–2000 years).
* The peakedness per fit is 1.60–3.95 (minimax fit) and 1.89–7.08 (mean fit). `notes.md`'s "1.9–4.0" was a cross-fit ratio.
* *Within `notes.md`'s pool,* under SAI's pricing, the uniform honest band wins in every cell.
* *With completions inside the band,* a law with a fitted error histogram wins in all 429 (body, window, precision) cells, $0.4$–$26\%$ below the band. The two-point form beats the band for 34 of 39 body–window pairs.
* *Under literal pricing with deterministic patches,* at $\lambda=1$, the exact law with exceptions wins except at the coarsest cells (§3.6).

**T4, horizons and soundness.**
* The derived tolerance is $e_r=L^re_0+\varepsilon(L^r-1)/(L-1)$. It is exactly a zonotope for linear maps, and the horizon formula is exact for linear maps in one dimension; for non-linear maps it is one-sided (Prop 4.1).
* An exact approximation is correct only to depth $r^*(\delta)$ (Prop 4.2).
* A sound criterion for combining approximate models exists, given a background that decides the comparisons. Honest models are consistent and sound, exact ones explode, and joint consistency is a pairwise check in one dimension, by Helly (Prop 4.3).
* The criterion is worst-case: $7.96\varepsilon$ typical against $100\varepsilon$ worst after 100 steps (Remark 4.4).

**T5, the best system.**
* Marginal slopes, explanatory power, and facts used once never entering for $\lambda>1$ (Props 5.1, 5.3).
* *Solar-system toy.* The $\lambda$-MAP has a closed form. $K3$ beats the law without it iff $s|S|>L_3$, independently of $\lambda$; it compresses initial conditions. Scout N2's criterion is refuted, and the literal "is in the MAP" reading is corrected (Prop 5.5).
* *Lewis.* "Kind nature" holds exactly at a kink of the hull (Prop 5.6). Trivialisation is blocked by the coding bound, up to the complexity of a language chosen after the data (Prop 5.7).
* *Explanatory power.* EP is the per-bit log-likelihood ratio. Myrvold's unification term is $I_h(D_1;D_2)-I_\flat(D_1;D_2)$: zero with stated parameters, and the bits of shared unknown parameters otherwise (Prop 5.8).
* Copernicus beats Ptolemy-with-stated-coincidences iff $H<\sum a_p$ (§5.3). In the question format, initial conditions are antecedents (Prop 5.9, with `shape`'s consistency condition).

**T6, domains and retention.**
* A domain restriction pays iff the law, even with an honest tolerance, is worse than literal data; exact ties are decided by the constants (Prop 6.1).
* Under SAI's pricing that never happens for bands below about $66°$ of longitude. So the Moon is kept with a $2.6°$ tolerance, not excluded.
* A superseded theory is retained for all data coarser than a computable $\Delta^*$, now with exact code-R costs (Prop 6.2).

**T7, correction.** In an exact rational toy, the successor:
* proves the honest old law on every window, with uniform tolerance exactly $\varepsilon_{\min}(W)\le((1+\eta\|P\|)^W-1)|a|$;
* refutes the exact old law;
* shares with it, among uniform-tolerance forms, exactly the one with tolerance $\varepsilon_{\min}(W)$.

Time-dependent tolerances are stronger, and the whole common content is the disjunction of the two theories (Prop 7.1; corrected after both referees).

**T8.** Partial: under SAI's pricing, tolerances and error distributions per body and window are learned, rather than sharp domains (§8).

**Refuted, corrected or withdrawn** (§10, items 1–19). Scout N2's $K3$ criterion. The pricing-independent readings of "spread errors favour honesty", "a steeper prior favours honesty" and "the Moon is excluded". `notes.md`'s claims that under SAI's pricing the uniform honest band wins on Kepler's residuals, and that the honest form is "exactly what the two theories have in common". Several hypotheses, constants and numbers, each with its counterexample. No "Possible error in the author's view" note is raised here: the brief assigns those to `philosophy`, and this record found none of its own.

**Revision.** Both referees found nothing fatal. Every major issue was accepted and fixed. Referee A's suggested example for m8 was not used, because it fails (Remark 1.9a). Referee B's (F1) and (F2) were re-derived and extended into Prop 3.6a. §14 lists every issue; §15 covers cross-thread consistency; §16 is the Verification log.

---

## 1. The setting and its relation to SAI (T1)

### 1.1 Data, questions, theories, codes

**Definition 1.1 (answered questions).**
* **Background.** $B$ is the background: decidable and consistent (NOTATION §3.1). "$T$ proves $\varphi$" means $B\cup T\vdash\varphi$ (`fundamentals` Def 1.1).
* **Questions.** A *question* $\mathcal Q$ is a finite set of pairwise $B$-incompatible sentences whose disjunction $B$ proves (NOTATION §3.2). Put $\gamma(\mathcal Q):=\log|\mathcal Q|$.
* **Answered data.** An *answered datum* is a pair $(\mathcal Q,a)$ with $a\in\mathcal Q$, the true answer. A *data set* $D$ is a finite set of answered data with pairwise distinct questions. $\dom D$ is the list of its questions in a canonical order, and $y_D$ the list of its answers.
* **Reading as two-valued data.** As a two-valued data set in the sense of NOTATION §3.2, $D$ is $\{(a,1):(\mathcal Q,a)\in D\}$. Its literals are $D^\pm=\{a:(\mathcal Q,a)\in D\}$, and its negative content $\neg a'$ ($a'\ne a$) follows from $B$. $M_A(D)$, $L_A(D)$ and $K_A(D)$ mean the values on that two-valued data set. (`notes.md` wrote $D^\sharp$ for it.)
* **Yes/no questions.** A yes/no question $\{\varphi,\neg\varphi\}$ gives the binary data of NOTATION §3.2 ($\gamma=1$).

For a theory $T$ and a datum $(\mathcal Q,a)$:
* $T$ *proves* the datum if $B\cup T\vdash a$, *refutes* it if $B\cup T\vdash\neg a$, and is *silent* on it otherwise.
* The *allowed answers* are $A_T(\mathcal Q):=\{a'\in\mathcal Q:B\cup T\nvdash\neg a'\}$.

For consistent $B\cup T$, $T$ proves $(\mathcal Q,a)$ iff $A_T(\mathcal Q)=\{a\}$:
* if $T\vdash a$, then $T\vdash\neg a'$ for every $a'\ne a$, by incompatibility;
* conversely, if $T$ refutes every $a'\ne a$, then $T\vdash a$, since $B\vdash\bigvee\mathcal Q$.

**Definition 1.2 (lengths).** Fix a prefix-free code $c_S$ for sentences and put $\ell(\chi):=1+|c_S(\chi)|$.
* For a finite theory $T$, listed in a canonical order, $|T|:=1+\sum_{\chi\in T}\ell(\chi)$. Each sentence is preceded by a continuation bit and the list ends with a stop bit.
* This is a prefix-free code of finite theories. So there are at most $2^m$ theories of length $m$, and $K(T)\le|T|+c$.
* For a *module* $\mathcal A\subseteq T$ put $\|\mathcal A\|:=\sum_{\chi\in\mathcal A}\ell(\chi)$. Then $|T|-|T\setminus\mathcal A|=\|\mathcal A\|$, and $|T\cup\mathcal A|=|T|+\|\mathcal A\|$ for $\mathcal A\cap T=\emptyset$. (NOTATION writes $|\mathcal A|$ in $\mathrm{EP}_D$; it means $\|\mathcal A\|$.)

**Definition 1.3 (exceptions and the objective).** Let $B\cup T\cup D^\pm$ be consistent. The *exceptions* of $T$ on $D$ are the data $T$ does not prove, $E_D(T)$. There are three codes for them:
* **(Q) question-relative literal code** (the decoder knows the questions): $\mathrm{Exc}^Q_D(T):=\sum_{(\mathcal Q,a)\in E_D(T)}\gamma(\mathcal Q)$;
* **(F) full literal code** (the answer sentence itself, which also identifies its question): $\mathrm{Exc}^F_D(T):=\sum_{(\mathcal Q,a)\in E_D(T)}\ell(a)$;
* **(R) random completion**, for pointwise interval laws (Def 1.5): $\mathrm{Exc}^R_D(T):=-\log P^R_T(D)$.

If $B\cup T\cup D^\pm$ is inconsistent, $\mathrm{Exc}_D(T):=\infty$ in every code. For $\lambda>0$, $J_\lambda(T;D):=\lambda|T|+\mathrm{Exc}_D(T)$, and its minimisers are the *$\lambda$-MAPs* (NOTATION §6.4, P2 `def:setup:objectives`). Each statement names its code; an unmarked $\mathrm{Exc}$ means code Q.

**Patches.** For a law $T=\{\forall t\,(I(t)\to\Phi(t))\}$ ($I$ the admissible times) and a finite set $S$ of times, the *patched law* is
$$T^{-S}:=\{\forall t\,(I(t)\wedge\textstyle\bigwedge_{s\in S}t\ne\underline s\to\Phi(t))\}.$$
* Its length is $|T^{-S}|=|T|+\sum_{s\in S}\pi_c(s)+O(1)$, where $\pi_c(s)$ is the length of the numeral $\underline s$ plus a connective.
* The brief's "law plus listed exceptions" $(T,E)$ is the theory $T\cup E^\pm$ when $T$ is silent on $E$, and $T^{-S}\cup E^\pm$ when $T$ refutes the data at the times $S$.

### 1.2 Deterministic theories

**Proposition 1.4 (laws plus listed exceptions are deterministic hypotheses) [proved].**
* (a) For every finite $T$ with $B\cup T\cup D^\pm$ consistent:
$$L_A(D)-c\ \le\ K_A(D)\ \le\ |T|+\mathrm{Exc}^F_D(T)+c .$$
* (b) For an r.e. $T$ and $E\subseteq D$ with $B\cup T\cup E^\pm$ consistent and $B\cup T\cup E^\pm\vdash\psi_{D}$: $L_A(D)\le K_\equiv(T)+K(E)+c$ (`fundamentals` Prop 5.2(b), scout F's F14(b)).

*Proof.*
* $T':=T\cup\{a:(\mathcal Q,a)\in E_D(T)\}$ is finite. It is consistent with $B$, being contained in the consistent set $T\cup D^\pm$, and it proves every datum.
* Concatenate the code of $T$ (without its stop bit), the codes $1c_S(a)$ of the exceptions and a stop bit. This is a prefix-free code of $T'$ of length $|T|+\mathrm{Exc}^F_D(T)$.
* A fixed program turns this code into an index of $T'$, so $K_A(D)\le|T|+\mathrm{Exc}^F_D(T)+c$.
* $L_A\le K_A+c$ is `fundamentals` Thm 5.1. ∎

Code F pays for *which* questions are exceptions, since the sentence $a$ names its question. A deterministic theory cannot avoid this, because it does not see the questions. The next proposition shows that SAI's one-tape law has randomised theories in its mixture that avoid this cost for data on which the law is silent.

### 1.3 Randomised theories: question-relative exception costs

**Definition 1.5 (pointwise interval laws).**
* **Language.** Let $B:=\mathrm{RCF}$, the theory of real closed fields in $\{0,1,+,\cdot,<\}$. It is decidable and complete by Tarski's theorem [known: tarski1951decision; standard]. Add fresh constants $q_t$ for $t$ in a decidable set $I$ of numerals (times), and fix a range $[0,\mathsf R]$ ($\mathsf R$ rational).
* **Presentations.** Fix a *presentation language*: a decidable prefix-free set of codewords, each denoting a pair of total computable maps $l\le u:I\to\mathbb Q\cap[0,\mathsf R]$, computed uniformly from the codeword. Examples are codewords of primitive recursive definitions, or programs paired with an explicit clock. No decidable set of programs covers all total computable functions, so the class depends on this choice (referee A, m3); everything below holds for any fixed choice.
* **Laws.** A *pointwise interval law* is $T_{l,u}:=\{l(t)\le q_t\le u(t):t\in I\}$ for a presented pair $(l,u)$. $|T|$ is the length of its codeword, and $K(T)\le|T|+c$.
* **Examples.**
  * the exact law $T_0$ ($l=u=f$);
  * the honest law $T^\varepsilon$ ($l=f-\varepsilon$, $u=f+\varepsilon$, clipped to the range);
  * the patched law $T_0^{-S}$ ($l=0$, $u=\mathsf R$ on $S$; $l=u=f$ elsewhere).
* **Interval data.** These are answers to questions $\mathcal Q$ that partition $[0,\mathsf R)$ into finitely many cells with rational endpoints; each answer is the sentence "$q_t$ lies in the cell".
  * A cell is an interval $[\alpha,\beta)$. For a quantity on a circle (§3) it may be the union of two intervals $[\alpha,\mathsf R)\cup[0,\beta)$, written as a disjunction.
  * For a fixed question family with $k$ cells, the answers are coded by the finite label set $\{1,\dots,k\}$ of P2's `def:setup:data`.

**Lemma 1.6 (decidability) [proved].** Let $T$ be a pointwise interval law and $C$ a cell, a finite union of intervals.
* $T$ proves the datum "$q_t\in C$" iff $[l(t),u(t)]\subseteq C$.
* $T$ refutes it iff $[l(t),u(t)]\cap C=\emptyset$.
* $B\cup T\cup D^\pm$ is consistent iff, for every time $t$ of $D$, $[l(t),u(t)]$ meets the intersection of the cells that $D$ assigns to $t$.

All three are decidable from $(l,u)$.

*Proof.*
* *Models.* Every choice of reals $q_t\in[l(t),u(t)]$ (and in the assigned cells) gives a model in $\mathbb R$. This proves the "only if" of the first two claims (choose $q_t$ outside the cell, resp. inside it) and the "if" of the third.
* *Provability.* Inclusions and disjointness of finite unions of rational intervals are Boolean combinations of rational inequalities between numerals, which $\mathrm{RCF}$ proves or refutes. This gives the "if" of the first two claims.
* *Inconsistency.* If for some $t$ the interval misses the assigned cells, the corresponding finitely many inequalities are jointly refutable in $\mathrm{RCF}$. ∎

**Definition 1.7 (random completion).** For a pointwise interval law $T$ and a data set $D$ of interval data, let $C_t$ be the intersection of the cells that $D$ assigns to time $t$. Put
$$P^R_T(D):=\prod_{t}\frac{|C_t\cap[l(t),u(t)]|}{u(t)-l(t)},$$
where $|\cdot|$ is length, and the factor is read as $\ind[l(t)\in C_t]$ when $l(t)=u(t)$. Then $\mathrm{Exc}^R_D(T):=-\log P^R_T(D)$.

**Proposition 1.8 (randomised theories pay question-relative costs) [proved].** Let $T$ be a pointwise interval law and $D$ a set of interval data consistent with $T$.
* (a) $L_A(D)\le K(T)+\mathrm{Exc}^R_D(T)+c\le|T|+\mathrm{Exc}^R_D(T)+c$.
* (b) Let $D$ be drawn from a computable question family with one question $\mathcal Q_t$ per time, and put $k_t(T):=|A_T(\mathcal Q_t)|\le|\mathcal Q_t|$. Then
$$L_A(D)\le K(T,(\mathcal Q_t)_t)+\sum_{(\mathcal Q_t,a)\in E_D(T)}\log k_t(T)+c,$$
and in particular $L_A(D)\le K(T,(\mathcal Q_t))+\mathrm{Exc}^Q_D(T)+c$.
* (c) Code R charges an exception of a patched law ($t\in S$, $l=0$, $u=\mathsf R$) exactly $\log(\mathsf R/|C_t|)$, which is the code-Q cost for equal cells. It charges the honest law $-\log(|C_t\cap[f-\varepsilon,f+\varepsilon]|/2\varepsilon)$, which is $0$ when the band lies in the cell (Lemma 3.6 computes its average).

*Proof.* (a)
* *The machine.* Enumerate $I$ as $t_1,t_2,\dots$ and fix a computable injection $(i,k)\mapsto\langle i,k\rangle$ into tape positions, increasing in $k$. On a tape $\omega$ put $U_i:=\sum_{k\ge1}\omega_{\langle i,k\rangle}2^{-k}$. Under $\Unif$ the $U_i$ are independent and uniform on $[0,1]$.
* Let $G_T$ be the theory machine that emits $T$ at the empty prefix. Once the prefix read contains the positions $\langle i,1\rangle,\dots,\langle i,k\rangle$, with bits giving the integer $m$, it also emits
$$l(t_i)+(u-l)(t_i)\,m2^{-k}\ \le\ q_{t_i}\ \le\ l(t_i)+(u-l)(t_i)\,(m+1)2^{-k}.$$
* This set of (prefix, sentence) pairs is c.e., and an index of it is computable from an index of $T$. So $K(G_T)\le K(T)+c$.
* *The random theory is always consistent.* Put $q_{t_i}:=v_i:=l(t_i)+(u-l)(t_i)U_i$. Each emitted closed dyadic interval contains $U_i$, so these values satisfy every emitted inequality, and $\mathbb R$ with them is a model.
* *It proves a datum "$q_{t_i}\in C$" whenever $v_i$ lies in the interior of $C$.* The emitted intervals contain $v_i$ and have lengths $(u-l)2^{-k}\to0$, so one of them lies in the interior of $C$, and $\mathrm{RCF}$ proves the inclusion. (If $l=u$, $T$ alone decides the datum.)
* Hence $\nu_{G_T}(D)\ge\Unif\{\omega:v_t\in\operatorname{int}C_t\text{ for all }t\}=P^R_T(D)$. The times of $D$ are distinct indices $i$, the $U_i$ are independent, and endpoints have measure $0$.
* *Dominance.* `fundamentals` Thm 4.1 gives $M_A\ge2^{-K(\nu)}\nu$ for every theory-machine law $\nu$ (scout F's F4). So $M_A(D)\ge2^{-K(G_T)-c}\nu_{G_T}(D)$, which gives (a).

(b) Use $U_i$ to pick the $\lfloor k_{t_i}U_i\rfloor$-th element $a$ of $A_T(\mathcal Q_{t_i})$, which is computable by Lemma 1.6, and emit $a$ once enough bits are read (almost surely finitely many). The cell $a$ meets $[l,u]$, so the random theory has a model. It proves the true answer with probability $1/k_t$, independently across times.

(c) This is the definition. ∎

**Reading [assessment; revised after referee A, m17].** Prop 1.8 is an upper bound on $L_A$. What it shows is that $M_A$'s mixture contains the machine $G_T$, whose law gives the data probability $P^R_T(D)$ with prior weight $2^{-K(G_T)}$.
* **The mechanism.** A random theory assigns random answers to *every* question of the family at once, inside what the law allows, and only the questions asked matter. So for data on which the law is *silent* there is no cost of saying *which* questions were exceptional. This extends scout F's F14(c) (`fundamentals` Prop 5.2(c): fair-coin facts on atoms the law is silent about) from atoms to answers the law only constrains.
* **Refuted data still pay.** For data the law *refutes*, a randomised withdrawal of the law still pays for the positions of the withdrawals. The cost is the flag code of Def 3.1, $H_2(p)$ bits per datum, which is the entropy of the positions (Prop 3.3a).
* **What "SAI's pricing" means below.** It is the relative weight, $2^{-(K(G)-\log\nu_G(D))}$, of two named theory machines in $M_A$'s mixture (Prop 1.9(a)). It is not a claim about the whole posterior. §3.6 and Prop 3.6a show why the difference matters: the posterior also contains machines that are not in a given pool, and those can win.

### 1.4 The converse, and which of P2's results apply

**Proposition 1.9 (SAI's loss is the best two-part code over randomised theories) [proved, given `fundamentals` Thm 4.1, Prop 1.8(d) and Thm 6.2, and P2 `prop:kink:universal`].**
* (a) For every data set $D$: $L_A(D)=\min_G\,[K(G)-\log\nu_G(D)]\pm c$, the minimum over theory machines $G$. It is attained, up to $c$, by the universal machine $G_U$.
* (b) Restricting $G$ gives the upper bounds of Props 1.4 and 1.8:
  * $L_A(D)\le\min_T J^R_1(T;D)+c$ over pointwise interval laws;
  * $L_A(D)\le\min_T J^F_1(T;D)+c$ over finite theories;
  * $L_A(D)\le K_A(D)+c$.
* (c) Neither $K_A$ nor $\min J^Q_1$ over finite theories is within an additive constant of $L_A$ in general (and $J^F_1\ge J^Q_1$ when $\gamma\le\ell$, so neither is $\min J^F_1$).
  * $K_A-L_A$ is unbounded (`fundamentals` Thm 6.2, scout F's F11: no coding theorem).
  * In the language $\{R\}\cup\{c_j:j\in\mathbb N\}$ with $B=\emptyset$, the binary data $D_n:=\{(R(c_j),1):j<n\}\cup\{(\exists x\neg R(x),1)\}$ have $L_A(D_n)\le c$. But $J^Q_1(T;D_n)\ge n$ for every finite $T$, in every syntax code in which each symbol occurrence costs at least one bit.
* (d) Over the class of *all* theory machines, steeper selection collapses. Take the point family of programs $p\in\dom V$ for theory machines, with $\ell(p):=|p|$ and fit $-\log\nu_{G_{V(p)}}(D)$. A program $p_U$ for $G_U$ satisfies P2's condition (Dom) with $\kappa_0=0$. So for $\lambda>1$ every $\lambda$-MAP $p$ has $|p|\le\ell_U+\ell_U/(\lambda-1)$, where $\ell_U:=|p_U|$.

*Proof.*
* (a) Dominance (`fundamentals` Thm 4.1) gives $L_A\le K(G)-\log\nu_G+c$ for every $G$, and $G=G_U$ gives $K(G_U)-\log\nu_{G_U}(D)=L_A(D)+O(1)$.
* (b) Props 1.4 and 1.8.
* (c), first part: cited.
* (c), second part.
  * $L_A(D_n)\le K_A(D_n)+c\le c'$ by `fundamentals` Prop 1.8(d), applied to the r.e. theory $\{R(c_j):j\in\mathbb N\}\cup\{\exists x\neg R(x)\}$.
  * Let $T$ be finite with $T\cup D_n^\pm$ consistent. Suppose $c_j$ does not occur in $T$ and $T\vdash R(c_j)$. Then $T\vdash\forall xR(x)$ by the theorem on constants, contradicting consistency with $\exists x\neg R(x)$.
  * So $T$ proves at most the data $R(c_j)$ with $c_j$ in $T$, together with $\exists x\neg R(x)$.
  * Each constant occurring in $T$ costs at least one bit of $|T|$, and each unproved datum one bit of $\mathrm{Exc}^Q$. So $J^Q_1(T;D_n)\ge n$.
* (d) P2 `prop:kink:universal`(ii) needs only a point family with a member $\pi_U$ such that $L(\pi_U)\le L(\pi)+\ell(\pi)+\kappa_0$ for all $\pi$. The mixture identity of `fundamentals` Thm 4.1, $M_A(D)\ge\sum_p2^{-|p|}\nu_{G_{V(p)}}(D)$, gives $-\log\nu_{G_U}(D)=L_A(D)\le-\log\nu_{G_{V(p)}}(D)+|p|$ for every $p$. This is the condition with $\kappa_0=0$ (referee A's observation; `notes.md` stated $\kappa_0=c$). ∎

**Remark 1.9a (pointwise interval laws: the separation is open) [proved, given `fundamentals` Prop 6.1(a); open].** `notes.md` said that no restriction in (b) is within $O(1)$ of $L_A$. For $\min J^R_1$ over pointwise interval laws that was not proved, and the example referee A suggests (m8) does not prove it.
* **The suggested example.** Data in which pairs of times share a random cell have $L_A\approx n\gamma/2$, and the claim was that $J^R_1\gtrsim n\gamma$.
* **Why it fails.** A presentation of $(l,u)$ may store values: the program that stores the $n/2$ shared cells and returns each one for both times of its pair has length $n\gamma/2+O(\log n)$ and $\mathrm{Exc}^R=0$. So $\min J^R_1\le n\gamma/2+O(\log n)$ as well.
* **Two lower bounds.** In general both $L_A(D)$ and $\min J^R_1$ are at least $K(y_D\mid\dom D)-c$.
  * For $L_A$: the answer conjunctions of the questions in $\dom D$ form a finite set $S$ of pairwise $B$-incompatible sentences, computable from $\dom D$. So `fundamentals` Prop 6.1(a) gives $L_A(D)=-\log M_A(\{(\psi_D,1)\})\ge K(\psi_D\mid S)-c\ge K(y_D\mid\dom D)-c'$.
  * For $\min J^R_1$: Prop 1.11(b) below.
* **Open.** Whether $\min J^R_1-L_A$ is bounded. Claim (c) is now stated only for $K_A$ and $J^Q_1$ (hence $J^F_1$), which the proof covers. Also, "no restricted class matches $L_A$" (`notes.md` §0) was false for a class that contains $G_U$; the summary now says "none of the three restrictions of (b) is known to, and two provably do not".

**Reading [assessment].** (a) says that SAI *is* a two-part code with $\lambda=1$ over randomised theories, with the universal machine as the best member. (d) says that a steeper penalty over that whole class selects nothing long, because the universal machine absorbs every law into its fit. P2 found the same split for SOI: the one-tape class has a universal member and product classes do not (P2 `cor:absorb:nouniversal`). So a best-systems analysis with a steeper penalty (§5) needs a class in which no member absorbs the others; *laws with private literal facts* are such a class. (`notes.md` said "and only there"; Prop 1.9(d) does not show that no other class works, so that phrase is withdrawn: referee A, m18.)

**Proposition 1.10 (P2's hypotheses in the two classes of laws) [proved, given P2].**
* (i) **Class $\mathcal H^R$** (pointwise interval laws in a fixed presentation language, code R, one question family with $k$ cells).
  * Programs are the codewords, a decidable prefix-free set. $P_T:=P^R_T$ is computable uniformly in $T$.
  * $P^R_T$ is the machine law of $G_T$, a shared hypothesis in P2's sense (`def:setup:shared`). On data with distinct times it is a product hypothesis (`def:setup:product`).
  * Kraft's inequality holds; lengths are integers, with finitely many programs of each length.
  * So P2's `lem:setup:basic`, `lem:setup:hull`, `lem:setup:coding`, `lem:kink:main`, `cor:kink:locate`, `cor:kink:split` and `thm:kink:converse` apply verbatim, with $J_\lambda=J^R_\lambda$.
* (ii) **Class $\mathcal H^Q$** (finite theories over a general background, code Q), with $P_T(D):=2^{-\mathrm{Exc}^Q_D(T)}\ind[B\cup T\cup D^\pm\text{ consistent}]$.
  * $P_T$ satisfies the semimeasure inequalities of P2's `def:setup:shared`, and it is a product over questions when consistency can be checked question by question (pointwise laws at distinct times).
  * It is *not* lower semicomputable in general, so $\mathcal H^Q$ is not a hypothesis class of P2. (`notes.md` called $P_T$ "a shared hypothesis"; referee A, m6.)
  * Of P2's results, the hull lemma, the kink lemma, `cor:kink:locate` and `thm:kink:converse` use only the point family $(|T|,\mathrm{Exc}^Q_D(T))_T$: integer lengths, finitely many points of each length, and some finite point ($T=\emptyset$). So they apply, and `lem:setup:basic`(i) applies.
  * `lem:setup:coding` uses lower semicomputability; it is replaced by Prop 1.11. With Prop 1.11, `cor:kink:split` holds with offset $b+\kappa+n$ in general and $b+\kappa$ when provability of the answers is decidable ($\kappa$ the constant of Prop 1.11). On pointwise interval laws $P_T$ is computable (Lemma 1.6) and all of (i) applies.

*Proof.*
* *Which hypotheses are used.* Each listed property is checked in the statement. That the hull, kink and converse results need only the point family can be seen from their statements (P2 `lem:setup:hull` and `def:algstat:product` are about countable point families) and from their proofs (`app:setup:hull`, `app:kinks:data`), which use only lengths, fits and the finiteness of programs per length.
* *The semimeasure inequalities in (ii).* $P_T(\emptyset)=\ind[B\cup T\text{ consistent}]\le1$. For $\mathcal Q\notin\dom D$, $\sum_{a\in\mathcal Q}P_T(D+(\mathcal Q,a))\le P_T(D)$:
  * if $T$ proves an answer $a_0$, every other answer is refuted by $T$ and contributes $0$, and $a_0$ adds no cost;
  * if $T$ proves no answer, each of the at most $|\mathcal Q|$ answers consistent with $T\cup D^\pm$ contributes at most $2^{-\gamma(\mathcal Q)}P_T(D)=P_T(D)/|\mathcal Q|$.
* *Not lower semicomputable.* Take $B=\emptyset$ and a language with a binary relation symbol. If $T\mapsto P_T(\emptyset)$ were lsc uniformly in $T$, the set of finite theories with $P_T(\emptyset)>\frac12$, i.e. the consistent ones, would be r.e. The inconsistent ones are r.e. as well, so consistency of finite theories would be decidable. That fails by Church's theorem [known: church1936note; standard]. (For a complete decidable $B$ such as $\mathrm{RCF}$ the argument does not apply, and `notes.md`'s "in any language with a binary relation symbol" was too broad: referee A, m6.) ∎

**Proposition 1.11 (coding bound for laws with literal exceptions) [proved].** Let $n:=|D|$.
* (a) For every finite $T$ with $B\cup T\cup D^\pm$ consistent: $|T|+n+\mathrm{Exc}^Q_D(T)\ \ge\ K(y_D\mid\dom D)-c$.
* (b) Suppose provability of answers from $T$ is decidable uniformly in $T$, for $T$ ranging over a class of presented theories with $K(T)\le|T|+c$ (finite theories over a decidable complete $B$, or pointwise interval laws). Then $|T|+\mathrm{Exc}^Q_D(T)\ge K(y_D\mid\dom D)-c$ and $|T|+\mathrm{Exc}^R_D(T)\ge K(y_D\mid\dom D)-c$.

*Proof.* (a)
* *The weights.* For a question $\mathcal Q$ put
$$w_T(a\mid\mathcal Q):=\tfrac12\ind[a\text{ is the first answer of }\mathcal Q\text{ found provable from }B\cup T]+\tfrac12|\mathcal Q|^{-1},$$
where "first" refers to a fixed dovetailed proof search.
* Then $\sum_aw_T(a\mid\mathcal Q)\le1$, and $w_T$ is lower semicomputable uniformly in $(T,\mathcal Q)$, because the first answer found never changes.
* $P'_T(y):=\prod_jw_T(y_j\mid\mathcal Q_j)$ is a uniformly lsc semimeasure on the answer lists for $\dom D$.
* *The bound on the cost.* If $T$ is consistent and proves $y_j$, no other answer of $\mathcal Q_j$ is provable, so $y_j$ is the first found and $w_T\ge\frac12$. Otherwise $w_T\ge\frac12|\mathcal Q_j|^{-1}$. Hence $-\log P'_T(y_D)\le n+\mathrm{Exc}^Q_D(T)$.
* *Coding.* The conditional coding theorem (P2 (F2)) gives $K(y_D\mid T,\dom D)\le n+\mathrm{Exc}^Q_D(T)+c$. Then $K(y_D\mid\dom D)\le K(T)+K(y_D\mid T,\dom D)+c\le|T|+n+\mathrm{Exc}^Q_D(T)+c$.

(b)
* *The weights.* With decidable provability, put $w_T(a\mid\mathcal Q):=1$ if $a$ is the first answer, in a fixed order of $\mathcal Q$, that $T$ proves; $:=0$ for the other answers $T$ proves; and $:=|\mathcal Q|^{-1}$ for every answer if $T$ proves none. This sums to at most $1$ also for inconsistent $T$ (referee A, m7: the version in `notes.md` gave weight $1$ to every answer of an inconsistent $T$), and it is computable.
* For consistent $T$ the cost bound of (a) holds without the flag bit.
* For code R, $P^R_T$ is itself a computable semimeasure on answer lists (Prop 1.10(i)), and P2's `lem:setup:coding` applies. ∎

So the right line of slope $1$ around a sufficient law (P2 `cor:kink:split`(a)) holds in both classes. In code Q without decidability it carries the flag cost $n$, which makes it useless. For that reason §§2–6 work with laws whose provability on the data is decidable.

---

## 2. Interval data and precision (T2)

**Setting of §§2–3.**
* A real quantity $q(t)$ (an angle in arcminutes, say) and an exact law $f$ with error $e(t):=f(t)-q(t)$.
* $\varepsilon^*:=\operatorname{ess\,sup}|e|$ under the law of the error at a sampled time (§3.1 makes the sampling precise).
* $T_0$ asserts $q(t)=f(t)$ for all $t$; $T^\varepsilon$ asserts $|q(t)-f(t)|\le\varepsilon$ for all $t$. Both are pointwise interval laws (Def 1.5).
* Data are true interval sentences with rational endpoints (Def 1.5): the centres $v_j$ of Prop 2.4 are rational, and the dithers of Prop 2.5 are read as in Setting S3 (§3.1).

### 2.1 Proof-requiring SAI never rewards a hedge

**Proposition 2.1 (compatibility is monotone in logical strength) [proved].** Let $B\cup T$ be consistent and $\Cn(T)\supseteq\Cn(T')$. For every data set $D$: if $T'$ is compatible with $D$ ($B\cup T'$ consistent and proving every datum), so is $T$. Hence, among deterministic hypotheses of $W_A$ and $M_A$:
* the posterior odds of $T$ against $T'$ equal their prior odds on every $D$ on which $T'$ is compatible;
* $T'$ is incompatible whenever $T$ is.

So data never move the odds towards the weaker theory.

*Proof.* $T$ proves everything $T'$ proves and is consistent; a consistent theory that proves every datum is consistent with the data. ∎

**Corollary 2.2 (scout P's Prop 2.3) [proved].**
* $T_0\vdash T^\varepsilon$ for every $\varepsilon\ge0$. So every data set compatible with the honest law $T^\varepsilon$ is compatible with the exact law $T_0$, at every sample size and every precision.
* Take prior weights $2^{-|T|}$ in a prefix code in which the tolerance clause costs at least one bit. Then the posterior odds of $T_0$ against $T^\varepsilon$ are at least $2^{|T^\varepsilon|-|T_0|}\ge2$ on every such data set.
* Let $e^*:=\sup_t|e(t)|>0$. Then $T_0$ is false, and on a question at precision $\delta'<e^*$ it proves a false answer at some times. $T^\varepsilon$ with $\varepsilon\ge e^*$ is true, and it is silent wherever its band straddles a cell boundary.

**Reading [assessment; revised after referee A, m19].** A tolerance, a domain restriction and a disjunction are all weakenings.
* *What is proved.* Over deterministic theories, data never move the odds towards a weakening (Prop 2.1). A weakening is preferred only when it is shorter and still compatible, and the tolerance clause makes the honest law longer.
* *When the honest law can win.* Only where the strong theory has been refuted and the data's literal costs are counted.
* *Inside $M_A$.* This happens through randomised theories (Prop 1.8). After $T_0$ is refuted, "$T^\varepsilon$ plus random completion" keeps positive weight $2^{-|T^\varepsilon|-\mathrm{Exc}^R_D(T^\varepsilon)-c}$. §3 analyses that competition, and Prop 3.6a shows that the uniform completion is in turn beaten by completions shaped like the error.

**Proposition 2.3 (precision monotonicity) [proved].** If $B\cup T$ proves "$q(t)\in[v-\delta',v+\delta']$", then it proves "$q(t)\in[v-\delta,v+\delta]$" for every $\delta\ge\delta'$. So compatibility with data at a fixed set of centres is monotone in the precision. (The first interval is contained in the second.) ∎

### 2.2 Two precision regimes

**Proposition 2.4 (guaranteed tolerances, regime G) [proved; computed: l2 A; rb1 E].** Datum $j$ is "$q(t_j)\in[v_j-\delta,v_j+\delta]$", with $v_j=q(t_j)+\eta_j$ rational and $|\eta_j|\le\delta_0\le\delta$.
* (a) $T_0$ proves datum $j$ iff $|e(t_j)-\eta_j|\le\delta$, and refutes it otherwise.
* (b) If $\delta\ge\varepsilon^*+\delta_0$, then $T_0$ is compatible with every such data set whose errors lie in the essential range (almost surely), at every $n$.
* (c) Suppose the pairs $(e(t_j),\eta_j)$ are i.i.d. with $e(t_j)$ independent of $\eta_j$, both $\pm\delta_0$ lie in the support of the law of $\eta_j$, and $\delta<\varepsilon^*+\delta_0$. Then the per-datum refutation probability $r(\delta):=\Pr[|e-\eta|>\delta]$ is positive, $\Pr[T_0\text{ survives }n\text{ data}]=(1-r(\delta))^n$, and $T_0$ is almost surely refuted eventually.

So the switch point $\delta=\varepsilon^*+\delta_0$ is sharp.

*Proof.*
* (a) $T_0\vdash q(t_j)=f(t_j)=v_j+e(t_j)-\eta_j$. This point lies in the interval iff $|e(t_j)-\eta_j|\le\delta$; if it does not, $T_0$ proves the negation.
* (b) $|e-\eta|\le|e|+|\eta|\le\varepsilon^*+\delta_0$ almost surely.
* (c) Pick $\varepsilon'<\varepsilon^*$ and $s>0$ with $\varepsilon'+\delta_0-s>\delta$. Since $\varepsilon^*$ is the essential supremum, $\Pr[e>\varepsilon']>0$ or $\Pr[e<-\varepsilon']>0$.
  * In the first case $\Pr[\eta<-\delta_0+s]>0$ (support), and independence gives $\Pr[e-\eta>\delta]>0$.
  * The second case is symmetric, with $\eta>\delta_0-s$.
  * Refutations of distinct data are independent, so survival has probability $(1-r)^n\to0$, and a refuted theory stays refuted. ∎

**Proposition 2.5 (dithered rounding, regime R) [proved; computed: l2 B; rb1 F].** Datum $j$ is "$q(t_j)$ lies in the cell $[\Delta(m-u_j),\Delta(m+1-u_j))$ that contains it", with $u_j$ uniform and independent of everything else (Setting S3 says how $u_j$ is made rational). Then:
* $\Pr[T_0\text{ proves datum }j\mid e(t_j)]=(1-|e(t_j)|/\Delta)^+$, and otherwise $T_0$ refutes it.
* With i.i.d. errors, $\Pr[T_0\text{ survives }n\text{ data}]=(1-p_\Delta)^n$, where $p_\Delta:=\Ex\min(|e|/\Delta,1)$. The index of the first refutation is geometric with mean $1/p_\Delta$.
* $T_0$ is almost surely refuted eventually iff $\Pr[e\ne0]>0$, *for every $\Delta$, however coarse*.
* For $\Delta\ge\varepsilon^*$, $p_\Delta=\Ex|e|/\Delta$, so the exact law survives about $\Delta/\Ex|e|$ data.

The refutation indicators of an exact law depend only on each datum's own error and dither, so this holds also when times repeat (referee A).

*Proof.*
* Two points at distance $|e|<\Delta$ fall in different cells of a uniformly shifted grid of width $\Delta$ with probability $|e|/\Delta$; at distance $\ge\Delta$ they always do.
* $T_0$ proves "$q(t_j)\in$ the cell of $f(t_j)$", and so refutes every other cell.
* Independence across data gives the product, and $p_\Delta>0$ iff $\Pr[e\ne0]>0$. ∎

**Computed [l2 A, B; exact values from rb1 E, F].**
* **(A) Regime G.** Take $\varepsilon^*=1'$, $\delta_0=0.5'$ and $\eta\sim U[-\delta_0,\delta_0]$. Then $r(\delta)$ is exactly $0.218$ at $\delta=1'$, $6.0\times10^{-4}$ at $1.49'$, and $0$ at $\delta\ge1.5'$ (referee B's exact computation; `l2` A's Monte Carlo agrees). This holds both for the spread error ($A\sin2\pi t$) and for the peaked one ($\pm A$ on 5% of times).
* **(B) Regime R.** The simulated survival after $n=1,10,100$ dithered data matches $(1-p_\Delta)^n$, and the mean first-refutation index matches $1/p_\Delta$, at every $\Delta$ from $0.5'$ to $600'$:
  * for the spread error with $\varepsilon^*=1'$: $94.1$ simulated at $\Delta=60'$ against the exact $1/p_\Delta=\pi\Delta/2=94.25$; $942.7$ at $\Delta=600'$ against $942.48$;
  * for the peaked error at $\Delta=600'$: $11941$ against the exact $12000$.

  (`notes.md` printed the Monte Carlo estimates $94.2$, $943.4$, $12006$ as if they were $1/p$: referee B, 9.)

### 2.3 Precision-dependent selection

**Proposition 2.6 (which exact theory a proof-requiring inducer settles on) [proved; computed: l2 C].** Let $T_1,\dots,T_m$ be exact pointwise laws for the same quantity, with lengths $\ell_1<\dots<\ell_m$ and errors $e_i$. Let the inducer choose the shortest compatible theory in the pool (the MAP of any prior that decreases with length, or $K_A$ restricted to the pool). Data are i.i.d.
* (G) Under Prop 2.4(c)'s hypotheses at precision $\delta$: almost surely the choice is eventually $T_{i^*(\delta)}$, with $i^*(\delta):=\min\{i:\varepsilon^*_i+\delta_0\le\delta\}$. If no $i$ qualifies, every theory is eventually refuted. As $\delta$ decreases past the thresholds $\varepsilon^*_i+\delta_0$, the eventual choice moves to longer and more exact theories.
* (R) Under Prop 2.5's hypotheses, for every $\Delta>0$: almost surely the choice is eventually the shortest theory with $\Pr[e_i\ne0]=0$, whatever $\Delta$ is. If there is none, every theory is eventually refuted. At sample size $n$, $T_i$ survives with probability $(1-p_{\Delta,i})^n$; for $\Delta\ge\varepsilon^*_i$ it is abandoned after about $\Delta/\Ex|e_i|$ data.

*Proof.* Apply Props 2.4 and 2.5 to each $T_i$. The choice at $n$ is the first survivor in order of length, and a finite pool has a last refutation time almost surely. ∎

**Computed [l2 C].** The pool is $T_1$ ($\ell=100$, $\varepsilon^*=10'$), $T_2$ ($\ell=150$, $\varepsilon^*=1'$) and $T_3$ ($\ell=400$, exact), with sinusoidal errors and 2000 runs.
* Under (G) with $\delta_0=0.5'$, the share of runs choosing the predicted theory at $n=10^4$ is $1.00$ at each of $\delta=20',10.5',5',1.5',1.2'$ (predictions $T_1,T_1,T_2,T_2,T_3$).
* Under (R) every run ends at $T_3$. $T_1$ is abandoned after about $1/p_1$ data ($94$ at $\Delta=10°$, $9.4$ at $\Delta=1°$), and $T_2$ after about $1/p_2$ ($942$ and $94$).

**Correction of the brief's seed [proved above].** The seed says "the simpler approximate theory is preferred until the data's precision exceeds its error, and the more exact theory after that".
* *Where it holds.* In regime G, with switch point $\varepsilon^*+\delta_0$ (Prop 2.4, Prop 2.6(G)).
* *Where it fails.* In regime R, which is how rounded measurements behave. There precision belongs to the *data set*, not to the datum: an exact but false law is refuted after about $\Delta/\Ex|e|$ data, however coarse the cells. Naked-eye positions at $\Delta=1°$ refute an exact law that is wrong by a sinusoidal $1'$ after about 94 observations.
* *Consequence.* In proof-requiring SAI over deterministic theories, "approximately true" exact laws survive only against guaranteed tolerances. Against rounded data, the relevant quantity is the number of data times the error over the precision. Between the exact law and a better theory sit the forms of §3.
* Scout P's Table 2.3 and `philosophy`'s Kepler tables are in regime G (interval centres taken as exact, $\delta_0=0$).

---

## 3. Honest approximate laws against laws with exceptions (T3)

### 3.1 Setting, forms, pricings, and what a datum costs

**Setting S3 (revised after referee A, M1 and m2; referee B, 10).**
* **The quantity.** It lives on a circle of circumference $\mathsf R$ (for a longitude, $\mathsf R=21600'$). A cell that crosses the zero point is a disjunction of two interval sentences (Def 1.5).
* **Times are fresh.** Datum $j$ is about time $t_j$, where $(t_j)_j$ is an injective computable sequence of numerals (for instance $t_j$ the $j$-th element of $I$).
* **The randomness.** The errors $e_j:=e(t_j)$ are i.i.d. with a law $\mu_e$, and the dithers $u_j$ are i.i.d. uniform and independent of the errors. This is a statistical model of the quantity: the error at a fresh time is a draw from $\mu_e$. For the Kepler residuals (§3.6), $\mu_e$ is the law of $e(t)$ for $t$ uniform in the window.
* **The dither as a sentence.** For the cell endpoints to be rational, read $u_j$ as uniform on $\{k/N_d:0\le k<N_d\}$. Every event below has the form "$u$ lies in an interval of length $\ell$", whose grid probability is within $1/N_d$ of $\ell$. The formulas below are the limit $N_d\to\infty$; equivalently, endpoints may be real algebraic numbers.
* **The datum.** Datum $j$ is the dithered cell of width $\Delta$ containing $q(t_j)$, with $\mathsf R/\Delta$ an integer. Its code-Q literal cost is $\gamma:=\log(\mathsf R/\Delta)$. Write $p:=p_\Delta$ and $s:=s_\Delta$.

*Why fresh times.* `notes.md` drew times i.i.d. from an atomless law. That is impossible: data are sentences, so they mention numerals, a countable set, and no atomless law lives on a countable set (referee A, M1). There are two repairs, and they differ:
* **Times i.i.d. from a law on numerals repeat.** The number of distinct times among $n$ draws is $o(n)$ almost surely: take a finite set of mass $\ge1-\epsilon$ and apply the strong law. Repeats change the costs of every form that is not an exact law; Remark 3.3b gives the numbers.
* **Fresh times have names that grow.** Prop 3.3a makes this precise.

The scripts draw $t\sim U[0,1)$ in floating point. That draw stands for a fresh time with i.i.d. $(e_j,u_j)$, as their docstrings now say. The simulations are therefore simulations of Setting S3.

**Definition 3.1 (forms and pricings).**
* **Forms.**
  * $0$: the empty law.
  * $T^{\varepsilon,-S}$: the tolerance law $T^\varepsilon$ patched at the finite set $S$ of times (§1.1). For a data set, the cheapest consistent patch set is the set of times of the data that $T^\varepsilon$ refutes: fewer patches are inconsistent, and more only add cost. "The patched tolerance law" means that choice.
  * $\varepsilon=0$ gives the exact law with patches, called **E** while it has no patch and **P** afterwards.
  * $\varepsilon\ge\varepsilon^*$ gives the honest law **H** $=T^{\varepsilon}$, which is true and is never patched.
  * **N**: a true exact theory.
  * Lengths: $|0|=0$, $|T_0|=\ell_0$, $|T^\varepsilon|=\ell_0+h$ ($h$ is the tolerance clause and its numeral, scout N2's $\Delta_\varepsilon$), $|N|=\ell_0+h_N$; all lengths are relative to a common part.
* **Pricings.** Each pricing fixes the price of a datum on which a form is silent ($\gamma_{\rm si}$) and of an exception ($\gamma_{\rm ex}$).
  * **Q/det** (scout N2's model): code Q, with patches deterministic and naming each time in the law part at a constant $\pi_c$ bits. So $\gamma_{\rm si}=\gamma$ and $\gamma_{\rm ex}=\lambda\pi_c+\gamma$. **This is a finite-horizon cost model:** by Prop 3.3a no code names fresh times at a constant cost, and the asymptotic per-exception cost of deterministic patches is at least $H_2(p)/p$ (best code), or about $\log n$ (literal numerals).
  * **Q/rand**: code Q with randomised exceptions. The law is withdrawn at each time independently with probability $\rho$, by a theory machine (§1.3). The fit is then charged a flag $-\log(1-\rho)$ per kept datum, and $-\log\rho+\gamma$ per exception.
    * $\rho$ can be stated in $O(\log n)$ bits, or integrated out. The *Laplace mixture* (draw $\rho$ uniformly from the tape, then withdraw independently) is a single theory machine, whose cost for $k$ exceptions among $n$ data is $\log\big((n+1)\binom nk\big)+k\gamma$.
    * Either way the rate is $H_2(p)+p\gamma$, so $\gamma_{\rm ex}=\gamma+H_2(p)/p$.
    * These costs are exact theory-machine costs for every $n$.
  * **R/det** and **R/rand**: as above, with a silent datum priced by random completion inside the band (Def 1.7). In the coarse regime, $\gamma_{\rm si}=\beta_e$ of Lemma 3.6. An exception of a patched law is priced $\gamma$ in code R too (Prop 1.8(c)).
* **SAI's pricing.** R/rand is "SAI's pricing" in the sense of the Reading of Prop 1.8. The honest law with random completion and the exact law with random exceptions are theory machines, and R/rand compares their weights in $M_A$'s mixture. It is not a statement about the whole posterior; Prop 3.6a adds the machines that matter.

**Lemma 3.2 (what the tolerance law does with one datum) [proved; computed: l3 A; rb1 A].** Fix a datum with error $e$ and $\varepsilon\ge0$. Over the dither,
$$\Pr[T^\varepsilon\text{ refutes}\mid e]=\min\!\Big(\frac{(|e|-\varepsilon)^+}{\Delta},1\Big),\qquad\Pr[T^\varepsilon\text{ proves}\mid e]=\Big(1-\frac{\varepsilon+\max(|e|,\varepsilon)}{\Delta}\Big)^+,$$
and it is silent otherwise.
* In the *coarse regime* $\Delta\ge\varepsilon+\max(\varepsilon,\varepsilon^*)$, it is silent with probability exactly $2\varepsilon/\Delta$ whatever $e$ is, and refutes with probability $(|e|-\varepsilon)^+/\Delta$.
* For $\varepsilon=0$ it refutes with probability $\min(|e|/\Delta,1)$ and is never silent (Prop 2.5).

(`notes.md` stated the coarse regime as $\Delta\ge\varepsilon+\varepsilon^*$. That is too weak when $\varepsilon>\varepsilon^*$: with $|e|=\varepsilon^*=1$, $\varepsilon=2$, $\Delta=3$ it gives silence probability $4/3$ (referee A, m1; `ra1` A). Every use in this record has $\varepsilon\le\varepsilon^*$, or $\Delta\ge2\varepsilon$, and is unaffected.)

*Proof.* Place $q$ at $0$. The cell containing it is $[-u\Delta,(1-u)\Delta)$ with $u\sim U[0,1)$, and the band is $B=[e-\varepsilon,e+\varepsilon]$ (as $f=q+e$). By symmetry take $e\ge0$.
* *Refutation* means that $B$ misses the cell. If $e\le\varepsilon$, then $0\in B$ and this is impossible. If $e>\varepsilon$, then $B\subset(0,\infty)$, and it happens iff $(1-u)\Delta\le e-\varepsilon$, of probability $\min((e-\varepsilon)/\Delta,1)$.
* *Proof of the datum* means $B\subseteq$ cell, i.e. $-u\Delta\le e-\varepsilon$ and $e+\varepsilon<(1-u)\Delta$.
  * If $e\le\varepsilon$, this is $u\in[(\varepsilon-e)/\Delta,(\Delta-\varepsilon-e)/\Delta)$, of length $(1-2\varepsilon/\Delta)^+$.
  * If $e>\varepsilon$, the first condition is automatic and the second is $u<(\Delta-e-\varepsilon)/\Delta$.
  * Both cases equal $(1-(\varepsilon+\max(e,\varepsilon))/\Delta)^+$.
* *Silence.* When $\Delta\ge\varepsilon+\max(\varepsilon,\varepsilon^*)$ the positive parts are inactive for every $e$, and silence has probability $1-(1-(\varepsilon+\max)/\Delta)-(\max-\varepsilon)/\Delta=2\varepsilon/\Delta$. ∎

**Proposition 3.3 (rates) [proved; computed: l3 B; rb1 D].** In Setting S3, each form $X$ has $J_\lambda(X;D_n)=a_X+\sum_{j\le n}c_X(d_j)$ with i.i.d. per-datum costs (under Q/rand and R/rand with $\rho$ stated; the Laplace mixture adds $O(\log n)$). In the coarse regime $\Delta\ge2\varepsilon^*$ the rates $m_X:=\Ex c_X$ are:
* $m_0=\gamma$; $m_N=0$; $m_E=\infty$ if $\Pr[e\ne0]>0$ (a refuted unpatched law);
* the patched exact law: $m_P=p\,\gamma_{\rm ex}$, i.e. $p(\lambda\pi_c+\gamma)$ under det and $H_2(p)+p\gamma$ under rand, with $p=\Ex|e|/\Delta$;
* the honest law $T^{\varepsilon^*}$: $m_H=s\,\gamma_{\rm si}$, with $s=2\varepsilon^*/\Delta$ (that is, $s\gamma$ in code Q and $s\beta_e$ in code R).

*Proof.*
* *P.* For the patched exact law at its cheapest patch set, a datum costs $\gamma_{\rm ex}$ if $T_0$ refutes it and $0$ otherwise. Under det the patch names its time ($\lambda\pi_c$) and the datum is then literal ($\gamma$); under rand it is the flag code. Lemma 3.2 with $\varepsilon=0$ gives the probability $p$.
* *H.* A datum costs $\gamma_{\rm si}$ iff $H$ is silent, which in the coarse regime has probability $2\varepsilon^*/\Delta$ (Lemma 3.2), independently of $e$. In code R, the conditional cost given silence is Lemma 3.6. ∎

**Proposition 3.3a (the price of naming exceptions deterministically) [proved; computed: l10 G].** In Setting S3, let $S_n\subseteq\{1,\dots,n\}$ be the indices of the data the exact law refutes. These are i.i.d. Bernoulli($p$), $p\in(0,1)$.
* (a) For every prefix-free code of finite subsets of $\{1,\dots,n\}$ (even one that knows $n$), the expected code length of $S_n$ is at least $nH_2(p)$. So the expected cost per exception is at least $H_2(p)/p$ bits, which is the flag code's cost.
* (b) Suppose the patched law names each patched time by a numeral in a prefix-free code $\ell$ of numerals (literal listing). Then $\Ex\sum_{j\in S_n}\ell(t_j)\ge pn\log n$, so the per-exception cost is at least $\log n$ on average. If $\ell(t_j)\ge\log j-c$ for all $j$ (any standard numeral code), the per-datum cost $\frac1n\sum_{j\in S_n}\ell(t_j)$ tends to $\infty$ almost surely.
* (c) Hence Q/det and R/det with a constant $\pi_c$ are cost models valid only while the times used cost about $\pi_c$ bits to name, i.e. for $n\lesssim2^{\pi_c}$. Asymptotically, with fresh times:
  * deterministic patching costs at least as much per exception as randomised exceptions;
  * literal patching costs unboundedly more;
  * so the patched exact law under det is eventually beaten by the exact law with random exceptions.
  The almost-sure statements below are exact for Q/rand and R/rand. For Q/det and R/det they are statements about the constant-$\pi_c$ cost model.

*Proof.*
* (a) Let $P$ be the law of $S_n$ and $\ell'$ a prefix-free code. By Kraft, $\sum_S2^{-\ell'(S)}\le1$. Then $\Ex\ell'(S_n)-H(S_n)=-\sum_SP(S)\log(2^{-\ell'(S)}/P(S))\ge-\log\sum_S2^{-\ell'(S)}\ge0$ by Jensen's inequality, and $H(S_n)=nH_2(p)$. The expected number of exceptions is $pn$.
* (b) The numerals $t_1,\dots,t_n$ are distinct, so Kraft gives $\sum_{j\le n}2^{-\ell(t_j)}\le1$. By Jensen, $2^{-\frac1n\sum_j\ell(t_j)}\le\frac1n\sum_j2^{-\ell(t_j)}\le\frac1n$, i.e. $\sum_{j\le n}\ell(t_j)\ge n\log n$. Since $\Pr[j\in S_n]=p$ independently of $j$, $\Ex\sum_{j\in S_n}\ell(t_j)\ge pn\log n$.
  * *Almost-sure version.* If $\ell(t_j)\ge\log j-c$, then $\frac1n\sum_{j\in S_n}\ell(t_j)\ge\frac1n\#\{j\in S_n:j>n/2\}(\log n-1-c)$. The count over $n$ tends to $p/2$ almost surely by the strong law.
* (c) follows from (a), (b) and Prop 3.3. ∎

**Computed [l10 G].** Bits per exception, by Elias-delta numerals for literal listing, an enumerative code ($\log(n+1)+\log\binom nk$) for the best set code, and $H_2(p)/p$ for random exceptions:

| $p$ | literal at $n=10^3$ / $10^5$ / $10^7$ | enumerative at $n=10^3$ / $10^5$ / $10^7$ | $H_2(p)/p$ |
|---|---|---|---|
| 0.1 | 14.7 / 23.1 / 30.3 | 4.86 / 4.71 / 4.69 | 4.69 |
| 0.01 | 15.0 / 23.0 / 30.3 | 9.02 / 8.13 / 8.08 | 8.08 |
| 0.001 | 15.5 / 22.5 / 30.3 | 14.45 / 11.66 / 11.43 | 11.41 |

**Remark 3.3b (repeated times) [computed: ra1 E, re-run identical].** Times drawn i.i.d. uniformly from a grid of $N=4383$ days (a 12-year window), with a sinusoidal error, $\varepsilon^*=1'$, $\Delta=60'$, $\lambda=1$ and $\pi_c=\log N+2$:
* the patched law's cost per datum is $0.40$, $1.96$ and $3.23$ bits at $n=10^3$, $10^5$ and $2\times10^5$, against the rate $0.240$ of Prop 3.3;
* the honest law's code-R cost falls from $0.037$ to $0.022$, against $0.030$.

With repeats, a patched law withdraws the law at a whole time, so every later datum at a refuted time is an exception. Almost every day is eventually refuted, so P's cost climbs towards $\gamma$, and the patched law degenerates to the empty law. Meanwhile the honest law's code-R cells at one time intersect, which narrows the band. Prop 3.3's rates therefore hold only for fresh times. The $n=10^3$ row is one sample path (16 refuted times against an expected $11$); the trend at $n\ge10^4$ is the effect.

### 3.2 Rates and the peakedness criterion

**Proposition 3.4 (the peakedness criterion) [proved; computed: l3 B, G; rb1 D].** Work in the coarse regime $\Delta\ge2\varepsilon^*$, under any of the four pricings (for the det pricings, as a cost model: Prop 3.3a).
* (a) *One law.* The honest form of a law has a lower rate than its patched exact form iff
$$\mathrm{pk}(e)\ <\ \frac{\gamma_{\rm ex}}{2\,\gamma_{\rm si}},\qquad\mathrm{pk}(e)=\frac{\varepsilon^*}{\Ex|e|}.$$
* (b) *Two laws (referee A, M6).* Let the patched exact form come from a law $f_1$ with error $e_1$, and the honest form from a law $f_2$ of the same length (up to $O(1)$) with tolerance $\varepsilon_2\ge\operatorname{ess\,sup}|e_2|$ and $\Delta\ge2\varepsilon_2$. Then the honest form of $f_2$ has the lower rate iff $\varepsilon_2/\Ex|e_1|<\gamma_{\rm ex}/(2\gamma_{\rm si})$.

*Proof.* $s\gamma_{\rm si}<p\gamma_{\rm ex}$ iff $2\varepsilon^*\gamma_{\rm si}<\Ex|e|\,\gamma_{\rm ex}$ (Prop 3.3). In (b), $s=2\varepsilon_2/\Delta$ and $p=\Ex|e_1|/\Delta$. ∎

Specialisations:
* **Q/det:** $\lambda\pi_c>\gamma(2\,\mathrm{pk}(e)-1)$. This is scout N2's Prop 3.2, confirmed. Computed [l3 B]: for the sinusoid ($\mathrm{pk}=\pi/2$) with $\pi_c=22$, the simulated rates pick P at $\lambda=1$ and H at $\lambda=2$ for $\Delta=2',3',10'$, and H at both for $\Delta=60'$, exactly as the threshold $(\lambda\pi_c+\gamma)/(2\gamma)$ predicts. For the peaked error ($\mathrm{pk}=20$) they pick P everywhere.
* **Q/rand:** $\mathrm{pk}(e)<\tfrac12+H_2(p)/(2p\gamma)$.
  * Since $H_2(p)/p\approx\log(e/p)$ for small $p$, the threshold grows only logarithmically in $1/p$. At $\gamma=\log360$ it is $1.17$ at $p=10^{-3}$, $1.76$ at $10^{-6}$ and $2.93$ at $10^{-12}$ (`ra1` D; `notes.md` said it "stays near 1", referee A, m12).
  * In the cases computed it is below 1, so under question-relative literal pricing with randomised exceptions the honest law loses there. Computed [l3 G; rb1 D]: the sinusoid has thresholds $0.637$, $0.742$ and $0.971$ at $\Delta=3'$, $10'$ and $60'$, so the exact law with random exceptions wins although the error is spread.
  * Scout N2's verdict in favour of honesty for spread errors rests on deterministic patches, whose cost $\lambda\pi_c$ of naming a time is what makes exceptions dear.
* **R/rand, within the pool $\{0,P,H\}$:** $\mathrm{pk}(e)<\big(\gamma+H_2(p)/p\big)/(2\beta_e)$, with $\beta_e\in[0.44,1.44]$. With $\gamma\approx8$–$14$ bits and $H_2(p)/p\approx5$–$12$ bits, the threshold is roughly $5$–$30$. Computed [l3 G; rb1 D]: $9.2$–$9.3$ for the sinusoid and $20.4$–$20.5$ for the peaked error with $\mathrm{pk}=20$.
  * **This comparison is relative to its pool, and the pool is not what SAI's mixture compares (referee B, 1).** P completes its exceptions uniformly over the *whole circle*. The equally short machine that completes them *inside the band*, $\mathrm{HY}(\rho)$ of Def 3.6a, is the right "law with exceptions" under SAI's pricing. Against it, the peaked error is held as "exact except in about 10% of cases" at a third of H's rate (Prop 3.6a(d)). `notes.md`'s conclusion that "under SAI's pricing honesty wins unless the error is very peaked" is withdrawn (§10, item 2).

So, over deterministic theories (code Q), which form an inducer adopts is decided by the shape of the error and by the relative price of silence. Under literal question-relative pricing, silence costs as much as stating the answer, and only expensive exceptions make honesty pay. Under random completion, silence is cheap, and the comparison moves to the shape of the completion inside the band (§3.3).

### 3.3 The best tolerance; the price of silence; completions inside the band

**Proposition 3.5 (optimal tolerance) [proved; computed: l3 C; rb1 C].** Under Q/det in the regime $\Delta\ge2\varepsilon^*$, the patched tolerance law $T^{\varepsilon,-S}$ ($0\le\varepsilon\le\varepsilon^*$) has rate
$$c(\varepsilon)=\frac{2\varepsilon\,\gamma+(\lambda\pi_c+\gamma)\,\Ex(|e|-\varepsilon)^+}{\Delta}.$$
* $c$ is convex, with right derivative $\big(2\gamma-(\lambda\pi_c+\gamma)\Pr[|e|>\varepsilon]\big)/\Delta$.
* Its minimisers are the $\varepsilon$ with $\Pr[|e|>\varepsilon]\le\theta_{\rm ex}\le\Pr[|e|\ge\varepsilon]$, where
$$\theta_{\rm ex}:=\frac{2\gamma}{\lambda\pi_c+\gamma}.$$
* So the optimal law states the $(1-\theta_{\rm ex})$-quantile of $|e|$ as its tolerance, and lists the remaining share $\theta_{\rm ex}$ of cases as exceptions.
* If $\theta_{\rm ex}\ge1$ ($\lambda\pi_c\le\gamma$), the exact law with patches is optimal.
* The pure honest law ($\varepsilon=\varepsilon^*$, no exceptions) is optimal iff $\Pr[|e|\ge\varepsilon^*]\ge\theta_{\rm ex}$. For an error distribution without an atom at its maximum this never holds. Prop 3.4 (Q/det) compares the two endpoints.

*Proof.* A datum costs $\gamma$ if it is not proved, and in addition $\lambda\pi_c$ if it is refuted (the patch). By Lemma 3.2 with $\Delta\ge2\varepsilon^*\ge\varepsilon+\varepsilon^*$, $\Pr[\text{not proved}]=(2\varepsilon+\Ex(|e|-\varepsilon)^+)/\Delta$ and $\Pr[\text{refuted}]=\Ex(|e|-\varepsilon)^+/\Delta$. The function $\varepsilon\mapsto\Ex(|e|-\varepsilon)^+$ is convex, with right derivative $-\Pr[|e|>\varepsilon]$. This gives convexity and the derivative, and a convex function is minimised where its right derivative changes sign. ∎

*Known in form [known: scholkopf2000new; bibliographic data verified by referee A's WebSearch, the property in secondary sources only].* Minimising $\theta\varepsilon+\Ex(|e|-\varepsilon)^+$ over $\varepsilon$ is the standard quantile-loss fact. The same objective, with $\theta$ bounding the share of points outside an $\varepsilon$-tube, is the $\nu$ of $\nu$-support-vector regression (referee A, m21). What is specific here is only the reading for axiom inducers: the tube is a tolerance clause, the points outside are patched exceptions, and $\theta_{\rm ex}$ is a ratio of literal costs.

**Computed [l3 C; rb1 C].** At $\Delta=10'$, $\pi_c=22$:
* the sinusoid: the grid minimiser against the predicted quantile is $0.52$ against $0.496$ ($\lambda=1$, $\theta_{\rm ex}=0.67$), $0.80$ against $0.807$ ($\lambda=2$), and $0.94$ against $0.939$ ($\lambda=4$);
* $|e|$ uniform on $[0,1]$: $0.33/0.330$, $0.60/0.598$, $0.79/0.776$;
* the optimal rate is below both endpoints in all six cases;
* referee B's exact check: the minimiser set equals the quantile set in 21712/21712 tests on discrete laws with atoms.

**Reading [assessment].** The steeper the prior, or the dearer the naming of an exception, the smaller $\theta_{\rm ex}$: the inducer states a wider tolerance and lists fewer exceptions. Under Q/det, the pure forms "exact with exceptions" and "approximately true" are the two ends of one family, and the optimum lies between them unless the error has an atom at its maximum. This is the formal shape of a law stated "within $\varepsilon$, except in these circumstances" (a finite-horizon cost model, Prop 3.3a).

**Lemma 3.6 (the code-R cost of the honest law, exactly) [proved; computed: l3 A, l10 D; rb1 B, ra1 B].** Let $H=T^\varepsilon$ with $\varepsilon\ge\varepsilon^*$, put $L:=2\varepsilon$, and let $w:=(\varepsilon-e)/(2\varepsilon)\in[0,1]$ be the relative position of $q$ in the band. Put $\phi(z):=1-z+z\ln z$ for $0\le z<1$ ($\phi(0)=1$), and $\phi(z):=0$ for $z\ge1$. The expected code-R cost of a datum, over the dither, is
$$C_\Delta(w)=\begin{cases}\dfrac{L}{\Delta}\big(\log e-H_2(w)\big)&\Delta\ge L\ \text{(coarse)},\\[2mm]\log\dfrac L\Delta+\log e\,\Big[\phi\Big(\dfrac{wL}{\Delta}\Big)+\phi\Big(\dfrac{(1-w)L}{\Delta}\Big)\Big]&\Delta\le L\ \text{(fine)}.\end{cases}$$
Consequences:
* (i) In the coarse regime the cost given silence is $\log e-H_2(w)$. Averaged over the errors, $\gamma_{\rm si}=\beta_e:=\log e-\Ex H_2(w)\in[\log e-1,\log e]=[0.443,1.443]$ bits.
* (ii) In the fine regime $H$ is silent on every datum, and $\log(L/\Delta)\le C_\Delta(w)\le\log(L/\Delta)+\log e$. The upper bound is approached as $w\to0$ at $\Delta=L$. (`notes.md` proved $2\log e$; the bound $\log e$ is referee A's m4, proved here.)
* (iii) For every $w$, $C_\Delta(w)$ is continuous and strictly decreasing in $\Delta\in(0,\infty)$.

*Proof.*
* *Coarse regime.* Given a straddle, exactly one boundary lies in the band, at a relative position $V$ that is uniform on $[0,1]$ (a uniformly shifted lattice of spacing $\Delta\ge L$). The true cell contains the part of the band on $q$'s side: of relative length $V$ if $w<V$, and $1-V$ otherwise. So the expected cost is
$$\int_w^1-\log V\,dV+\int_0^w-\log(1-V)\,dV=\big(1+w\ln w+(1-w)\ln(1-w)\big)/\ln2=\log e-H_2(w).$$
  The straddle has probability $L/\Delta$ (Lemma 3.2).
* *Fine regime.* Let $y$ be the length of the part of $q$'s cell inside the band. The cost is $\log(L/y)=\log(L/\Delta)-\log(y/\Delta)$. With $a:=wL/\Delta$ and $b:=(1-w)L/\Delta$ (so $a+b=L/\Delta\ge1$) and dither $u$, $y/\Delta=\min(u,a)+\min(1-u,b)$.
  * If $a,b\ge1$, then $y=\Delta$, and the excess $-\ln(y/\Delta)$ is $0$.
  * If $a<1\le b$, then $y/\Delta=1$ for $u<a$ and $=1+a-u$ for $u\ge a$. So $\Ex[-\ln(y/\Delta)]=\int_a^1-\ln(1+a-u)\,du=\int_a^1-\ln s\,ds=\phi(a)$. The case $b<1\le a$ is symmetric.
  * If $a,b<1$, then $1-b\le a$. Also $y/\Delta=u+b$ for $u<1-b$, $=1$ on $[1-b,a]$, and $=a+1-u$ for $u>a$. So the excess is $\int_b^1-\ln s\,ds+\int_a^1-\ln s\,ds=\phi(a)+\phi(b)$.
* *(ii).* $\phi\ge0$ and $\phi$ is decreasing on $[0,1]$ ($\phi'(z)=\ln z$). In the last case $\phi(a)+\phi(b)$ is largest on $a+b=1$, where it equals $1-H_{\rm nat}(a)\le1$. In the middle case $\phi(a)\le1$.
* *(iii).* Write $r:=L/\Delta$ and $C$ in nats.
  * Coarse ($r\le1$): $C=r(1-H_{\rm nat}(w))$, with $1-H_{\rm nat}\ge1-\ln2>0$, so $C$ is increasing in $r$.
  * Fine ($r\ge1$): $C=\ln r+\phi(wr)+\phi((1-w)r)$. On each piece,
$$\frac{dC}{dr}=\frac1r\Big(1+\sum_{z\in\{wr,(1-w)r\},\,z<1}z\ln z\Big)\ \ge\ \frac1r\Big(1-\frac2e\Big)>0,$$
    since $z\ln z\ge-1/e$.
  * $C$ is continuous in $r$ ($\phi$ is continuous at $1$), and at $r=1$ the two forms agree, since $\phi(w)+\phi(1-w)=1-H_{\rm nat}(w)$.
  * So $C$ is strictly increasing in $r$, i.e. strictly decreasing in $\Delta$. ∎

**Computed [l10 D; l3 A].**
* The closed form agrees with a 5000-point quadrature over the dither to $1.0\times10^{-4}$ bits on 36090 cells ($w$ on 401 points, $\Delta/L\in[0.02,5]$).
* The largest fine-regime excess is $1.442695=\log e$, and the cost never increases with $\Delta$ on the grid.
* The two forms agree at $\Delta=L$ to $1.4\times10^{-9}$.
* The coarse averages match: $\beta_e=0.885$ for the sinusoid and $0.493$ for the peaked error.

**Definition 3.6a (band-confined completions; referee B, 1).** Fix $\varepsilon\ge\varepsilon^*$ and a computable distribution $G$ on $[0,1]$: for instance piecewise linear with rational knots, plus finitely many atoms at rational points. The machine $\mathrm{BC}_G$:
* emits $T^\varepsilon$;
* for each time $t_i$, draws $X_i\sim G$ from the tape (by inverse CDF on the $U_i$ of Prop 1.8's proof);
* emits the value $f(t_i)-\varepsilon+2\varepsilon X_i$, as narrowing intervals for the continuous part, or as the exact value for an atom.

Special cases:
* **H** $=\mathrm{BC}_{\rm Unif}$, which is Prop 1.8's $G_T$ for $T=T^\varepsilon$;
* $\mathbf{HY}(\rho):=\mathrm{BC}_G$ with $G=(1-\rho)\delta_{1/2}+\rho\,\mathrm{Unif}$: "exact, except in a share $\rho$ of cases, and then within $\varepsilon$";
* $\mathbf{SH}$: $\mathrm{BC}_G$ for a fixed histogram distribution $G$.

Each $\mathrm{BC}_G$ is a theory machine with $K(\mathrm{BC}_G)\le|T^\varepsilon|+K(G)+c$. Its random theory is always consistent, and on data at fresh times $\nu_{\mathrm{BC}_G}(D)=\prod_jG(C'_j)$, where $C'_j$ is datum $j$'s cell in band coordinates, intersected with $[0,1]$. (The argument of Prop 1.8(a); cell endpoints are null events for continuous dithers.)

**Proposition 3.6a (completions inside the band) [proved; computed: l10 B, C; rb2].** Work in Setting S3 with $\varepsilon\ge\varepsilon^*$. Let $x_j:=(\varepsilon-e_j)/(2\varepsilon)$, i.i.d. with CDF $F$.
* (a) *Coarse regime ($\Delta\ge2\varepsilon$).* The rate of $\mathrm{BC}_G$ is $(2\varepsilon/\Delta)\,c_G$, with the per-straddle cost
$$c_G:=\Ex_x\int_0^1\Big([V<x]\big({-\log(1-G(V))}\big)+[V>x]\big({-\log G(V)}\big)\Big)\,dV .$$
  So the ranking of band-confined completions is the same at every coarse $\Delta$.
* (b) *Gibbs.* $c_G\ge c_F:=\int_0^1H_2(F(V))\,dV$, with equality iff $G=F$ almost everywhere on $[0,1]$. In particular, the uniform honest band H is the best band-confined completion iff $F$ is uniform, i.e. iff $e$ is uniform on $[-\varepsilon,\varepsilon]$.
* (c) *Nothing beats the error's own law.* For every theory machine $G'$, including $G_U$ (so $M_A$ itself), almost surely $\liminf_n\frac1n(-\log\nu_{G'}(D_n))\ge r_F(\Delta):=\Ex[-\log F(C'_1)]$, the conditional entropy rate of the answers given the questions. Meanwhile $-\frac1n\log\nu_{\mathrm{BC}_F}(D_n)\to r_F(\Delta)$. If $F$ is computable, then $L_A(D_n)/n\to r_F(\Delta)$ almost surely. In the coarse regime $r_F(\Delta)=(2\varepsilon/\Delta)c_F$.
* (d) *The two-point form against the uniform band.* $c_{\mathrm{HY}(\rho)}$ is convex in $\rho\in(0,1]$, and some $\mathrm{HY}(\rho)$ with $\rho<1$ beats H iff
$$\Ex\ln\!\Big(1+\frac{|e|}{\varepsilon}\Big)\ <\ 2\ln2-1\approx0.386 .$$
  With $\mathrm{pk}_\varepsilon:=\varepsilon/\Ex|e|$:
  * it is necessary that $\mathrm{pk}_\varepsilon>\ln2/(2\ln2-1)\approx1.794$;
  * it is sufficient that $\mathrm{pk}_\varepsilon>e/(4-e)\approx2.121$;
  * $|e|/\varepsilon$ uniform on $[0,1]$ is the boundary case.

*Proof.*
* (a) As in Lemma 3.6. A boundary falls in the band with probability $2\varepsilon/\Delta$, at a relative position $V$ uniform on $[0,1]$ and independent of $x$. With no boundary in the band, the cell contains the band and the datum costs $0$. With a boundary at $V$, $q$'s cell contains $[0,V)$ if $x<V$, of $G$-mass $G(V)$, and $[V,1]$ if $x>V$, of mass $1-G(V)$.
* (b) Given $V$, $[x<V]$ is Bernoulli$(F(V))$, so the conditional expected cost is $F(V)(-\log G(V))+(1-F(V))(-\log(1-G(V)))\ge H_2(F(V))$, with equality iff $G(V)=F(V)$ (Gibbs). Integrate over $V$.
* (c) Let $P$ be the true conditional law of the answer list given the question list. The errors are independent of the questions, and $q=f-e$, so the conditional probability of $q(t_j)$'s cell is $F(C'_j)$. Hence $P$ is the law $\nu_{\mathrm{BC}_F}$, and $-\log\nu_{\mathrm{BC}_F}(D_n)=\sum_j-\log F(C'_j)$, a sum of i.i.d. terms with finite mean $r_F(\Delta)$; the strong law gives the limit.
  * For any theory machine $G'$, the events "the random theory is consistent and proves answer list $y$" are disjoint across the answer lists $y$ to a fixed question list, since answers to one question are pairwise incompatible. So $\sum_y\nu_{G'}(\text{questions},y)\le1$ and $\Ex_P[\nu_{G'}(D_n)/P(D_n)\mid\text{questions}]\le1$.
  * Markov's inequality gives $\Pr[-\log\nu_{G'}(D_n)<-\log P(D_n)-2\log n]\le n^{-2}$, and Borel–Cantelli gives eventually $-\log\nu_{G'}(D_n)\ge-\log P(D_n)-2\log n$. Divide by $n$.
  * For $M_A=\nu_{G_U}$ this gives the liminf. If $F$ is computable, dominance gives $L_A(D_n)\le K(\mathrm{BC}_F)+c-\log\nu_{\mathrm{BC}_F}(D_n)$, hence the limit.
* (d) Write $\sigma:=1-\rho$ for the weight of the atom. By symmetry ($G(1-V)=1-G(V)$ for this family) take $x\le\frac12$.
  * *Convexity.* For fixed $(x,V)$ the probability assigned to the true side is affine in $\sigma$ and positive for $\sigma\in[0,1)$, and $-\ln$ of a positive affine function is convex. So $c$, an expectation of convex functions, is convex.
  * *Right derivative at $\sigma=0$, in nats.* The integrand's derivative is bounded on three ranges:
    * $V<x$: the side has probability $1-(1-\sigma)V$, contributing $-V/(1-V)\in[-1,0]$;
    * $x<V<\frac12$: probability $(1-\sigma)V$, contributing $+1$;
    * $V>\frac12$: probability $\sigma+(1-\sigma)V$, contributing $-(1-V)/V\in[-1,0]$.
  * Convex difference quotients decrease monotonically as $\sigma\downarrow0$, so by monotone convergence the derivative of the expectation is the expectation of these derivatives:
$$c'(0^+)=\Ex\Big[\int_0^x-\tfrac{V}{1-V}dV+\big(\tfrac12-x\big)-\int_{1/2}^1\tfrac{1-V}VdV\Big]=\Ex\big[\ln(1-x)+1-\ln2\big],$$
    using $\int_0^x\frac V{1-V}dV=-\ln(1-x)-x$ and $\int_{1/2}^1\frac{1-V}VdV=\ln2-\frac12$. For $x\le\frac12$, $1-x=(1+|e|/\varepsilon)/2$, so $c'(0^+)=\Ex\ln(1+|e|/\varepsilon)+1-2\ln2$.
  * *The criterion.* If $c'(0^+)<0$, some $\sigma>0$ beats $\sigma=0$ (which is H). If $c'(0^+)\ge0$, convexity gives $c(\sigma)\ge c(0)$ for all $\sigma$.
  * *Necessity.* $\ln(1+z)\ge z\ln2$ on $[0,1]$ (a concave function lies above its chord). So $\Ex\ln(1+|e|/\varepsilon)\ge\ln2/\mathrm{pk}_\varepsilon$, and $c'(0^+)<0$ forces $\mathrm{pk}_\varepsilon>\ln2/(2\ln2-1)$.
  * *Sufficiency.* Jensen gives $\Ex\ln(1+X)\le\ln(1+\Ex X)=\ln(1+1/\mathrm{pk}_\varepsilon)$, which is $<2\ln2-1$ iff $\mathrm{pk}_\varepsilon>e/(4-e)$.
  * *Boundary.* $\int_0^1\ln(1+u)\,du=2\ln2-1$. ∎

Part (d) is referee B's (F2), and (b) is its (F1). Both are re-derived here, (c) is added, and the two peakedness bounds are new: referee B gave only the sufficient one.

**Computed [l10 B; agrees with rb2].** Per-straddle costs in bits, coarse regime, synthetic errors with $2\times10^5$ samples; SH is a 40-bin smoothed histogram fitted on a random half of the samples and evaluated on the other half:

| error | $\mathrm{pk}$ | H | HY* (best $\rho$) | SH (test half) | Gibbs bound $c_F$ (test half) | criterion $c'(0^+)$ |
|---|---|---|---|---|---|---|
| sinusoid | 1.57 | 0.8854 | 0.8854 ($\rho=1$) | 0.8514 | 0.8510 | $+0.087$: no |
| peaked, $\pm1$ on 5% | 20.1 | 0.4924 | 0.1790 ($\rho=0.099$) | 0.2006 | 0.1704 | $-0.352$: yes |
| $|e|$ uniform | 2.00 | 0.7213 | 0.7213 (boundary) | 0.7227 | 0.7227 | $\approx0$ |
| two levels, $0.25$ / $1$ (90% / 10%) | 3.08 | 0.5832 | 0.5543 ($\rho=0.68$) | 0.4797 | 0.4640 | $-0.116$: yes |

* **The real residuals** (39 body–window pairs, minimax-fit series, band $1.01\times$ the sample maximum):
  * HY* < H in 34 of 39 pairs (33 of 39 at band $1.00\times$, referee B), with best $\rho$ between $0.52$ and $0.997$;
  * the criterion of (d) agrees with the numerical optimum in 39/39, and neither peakedness bound is violated;
  * SH < H on the test half in 39/39, and SH lies within $0.0011$ bits of the Gibbs bound of the test half in all 39 pairs.
* **The pairs where the uniform band beats every HY** are Jupiter over 12 and 30 years, Saturn over 100 years, and the Moon over 1 month and 18.6 years, with per-fit peakedness 1.60–1.96.

**Reading [assessment].** Under SAI's pricing, the honest *uniform* band is one completion among many, and it is the best one only for uniform errors (b). What SAI's mixture asymptotically rewards, on data from a law with i.i.d. errors, is *the law together with its error distribution* (c): no theory machine has a lower rate, and $M_A$ attains it when the error law is computable.
* The dichotomy "honest law against law with exceptions" has a counterpart inside this family. The two-point form HY ("exact, except in a share $\rho$, then within $\varepsilon$") beats the uniform band iff $\Ex\ln(1+|e|/\varepsilon)<2\ln2-1$. A peakedness criterion therefore survives, with thresholds $1.79$ (necessary) and $2.12$ (sufficient), not the $5$–$30$ that `notes.md` derived from an incomplete pool.
* On the deterministic Kepler residuals, a better theory has rate $0$ (Newton, or the ephemeris itself), and $M_A$'s posterior eventually prefers it. (c) concerns the i.i.d. model and the competition among Kepler-based machines.

**Proposition 3.7 (fine data) [proved; constant improved after referee A, m4].** For $\Delta\le2\varepsilon^*$ the honest law is silent on every datum.
* *Code Q.* Its rate is $\gamma=m_0$, so it never beats the empty law, and P beats the empty law iff $p\gamma_{\rm ex}<\gamma$.
* *Code R.* Its rate is at most $\log(2\varepsilon^*/\Delta)+\log e$ (Lemma 3.6(ii)), which is below $m_0=\gamma=\log(\mathsf R/\Delta)$ by at least $\log(\mathsf R/2\varepsilon^*)-\log e$ bits per datum. This is positive iff $\varepsilon^*<\mathsf R/(2e)$, about $66.2°$ for a longitude (`notes.md`: $\mathsf R/(2e^2)\approx24°$, from its weaker bound).
* *Code R at small $\Delta$.* Suppose also $\Pr[|e|<\Delta]\log(1/\Delta)\to0$ as $\Delta\to0$ (e.g. $|e|$ has a bounded density near $0$). Then $m_P\ge p\gamma\ge\gamma-\Pr[|e|<\Delta]\gamma$, so the honest law has the lowest rate among $0$, E/P and H for all small $\Delta$.

*Proof.* Lemma 3.2, Lemma 3.6, Prop 3.3, and $1-p_\Delta=\Ex(1-|e|/\Delta)^+\le\Pr[|e|<\Delta]$. ∎

So under SAI's pricing an approximate law keeps its value at precisions finer than its error. It narrows each answer to its band, which is worth $\log(\mathsf R/2\varepsilon^*)$ bits per datum ($\approx13$ bits for a $1'$ Kepler error on a full circle). By Prop 3.6a, a completion shaped like the error narrows it further.

### 3.4 Almost-sure selection, phases and switch points

**Theorem 3.8 (almost-sure selection) [proved, given the strong law of large numbers, the central limit theorem, the Hewitt–Savage 0–1 law, Wald's identity and the finiteness of $\Ex\tau$ for random walks with positive drift (standard: durrett2019probability); hypotheses weakened after referee A, M5].** Let $\mathcal X$ be a finite set of forms with
$$J_\lambda(X;D_n)=a_X+\sum_{j\le n}c_X(d_j)+r_X(n),$$
where the $d_j$ are i.i.d., $c_X(d)\in[0,\infty]$, and $r_X(n)=o(n)$ almost surely ($r_X=0$ for deterministic forms and for stated $\rho$; $O(\log n)$ for a Laplace mixture). Let $m_X:=\Ex c_X\in[0,\infty]$, $m_{\min}:=\min_Xm_X<\infty$, and $\mathcal X^*:=\{X:m_X=m_{\min}\}$.
* (i) Almost surely, for all large $n$ every $\lambda$-MAP within $\mathcal X$ lies in $\mathcal X^*$. If $\mathcal X^*=\{X^*\}$, the $\lambda$-MAP is eventually $X^*$ alone.
* (ii) (ties) Let $X,Y\in\mathcal X^*$ with $r_X=r_Y=0$.
  * If $c_X-c_Y$ is finite with finite variance and not almost surely constant, then almost surely $J_\lambda(X;D_n)<J_\lambda(Y;D_n)$ for infinitely many $n$ and $J_\lambda(Y;D_n)<J_\lambda(X;D_n)$ for infinitely many $n$: there is no eventual winner.
  * If $c_X-c_Y=0$ almost surely, $a_X$ against $a_Y$ decides forever.
* (iii) (switch times) Let $r_X=r_Y=0$, $m_Y<m_X<\infty$, $\Ex|c_X-c_Y|<\infty$ and $L:=a_Y-a_X>0$. Let $\tau_L$ be the first time with $J(Y)<J(X)$, $\sigma_L$ the last time with $J(Y)\ge J(X)$, and $\mu:=m_X-m_Y$.
  * $\Ex\tau_L>L/\mu$.
  * If moreover $c_X-c_Y\le b$ almost surely, then $\Ex\tau_L\le(L+b)/\mu$.
  * On one sample path, as $L\to\infty$, $\tau_L/L\to1/\mu$ and $\sigma_L/L\to1/\mu$ almost surely.

The code-R cost of a silent datum is $-\log$ of a share that is uniform near $0$ (Lemma 3.6's proof), so it has all moments ($-\ln V$ is exponential). So (i)–(iii) cover every application in this record.
* The bounded-increment bound of (iii) applies to the race P→H, whose increments $c_P-c_H\le\max c_P$ are bounded above.
* For H→N in code R, the increments $c_H-c_N=c_H$ are unbounded, and only the lower bound and the path limits are claimed.

*Proof.*
* (i) Let $X\notin\mathcal X^*$ and $X^*\in\mathcal X^*$. Then $\frac1nJ(X^*;D_n)\to m_{\min}$ almost surely.
  * If $\Pr[c_X=\infty]>0$, some datum has infinite cost almost surely.
  * If $c_X<\infty$ almost surely and $m_X=\infty$: for each $K$, $\frac1n\sum_j\min(c_X,K)\to\Ex\min(c_X,K)$ by the strong law, and $\Ex\min(c_X,K)\to\infty$ as $K\to\infty$. So $\frac1nJ(X)\to\infty$.
  * If $m_X<\infty$, then $\frac1n(J(X)-J(X^*))\to m_X-m_{\min}>0$.
  * $\mathcal X$ is finite.
* (ii) $S_n:=\sum_{j\le n}(c_X-c_Y)(d_j)$ is a random walk with mean-zero, non-degenerate increments of finite variance.
  * For each $K$, $\Pr[S_n>K]\to\frac12$ by the central limit theorem, so $\Pr[S_n>K\text{ i.o.}]\ge\limsup_n\Pr[S_n>K]=\frac12$.
  * This event is invariant under finite permutations of the increments, so by the Hewitt–Savage 0–1 law it has probability $1$.
  * Intersecting over $K\in\mathbb N$, $\limsup S_n=+\infty$ almost surely, and likewise $\liminf S_n=-\infty$. So $a_X-a_Y+S_n$ changes sign infinitely often.
* (iii) $S_n:=\sum(c_X-c_Y)(d_j)$ has i.i.d. integrable increments of mean $\mu>0$, so $\tau_L=\min\{n:S_n>L\}$ is a stopping time with $\Ex\tau_L<\infty$.
  * Wald's identity gives $\Ex S_{\tau_L}=\mu\Ex\tau_L$, with $S_{\tau_L}>L$; if the increments are at most $b$, also $S_{\tau_L}\le L+b$.
  * *Path statement.* Fix $\epsilon\in(0,\mu)$. By the strong law there is $N(\omega)$ with $|S_n-n\mu|\le\epsilon n$ for $n\ge N$. For $L>\max_{n<N}S_n$ we have $\tau_L\ge N$, and $S_{\tau_L}>L\ge S_{\tau_L-1}$ gives $L/(\mu+\epsilon)<\tau_L\le L/(\mu-\epsilon)+1$.
  * Similarly $S_{\sigma_L}\le L$ with $\sigma_L\ge\tau_L-1\ge N$ gives $\sigma_L\le L/(\mu-\epsilon)$. ∎

**Corollary 3.9 (the four forms, coarse data) [proved; computed: l3 D–F, l10 H; rb3 B].** Take a pricing with i.i.d. per-datum costs as in Prop 3.3: exactly Q/rand and R/rand (with $\rho$ stated), or Q/det and R/det as a constant-$\pi_c$ cost model (Prop 3.3a). Assume $\Delta\ge2\varepsilon^*$, $\Pr[e\ne0]>0$, $\varepsilon^*>0$ and $h_N>h$ (referee A, m14). The pool is $\{0,\text{E/P},H,N\}$, with $a_0=0$, $a_{E/P}=\lambda\ell_0$, $a_H=\lambda(\ell_0+h)$ and $a_N=\lambda(\ell_0+h_N)$. Almost surely:
* (a) the exact law is refuted for the first time at a geometric index of mean $1/p$; until then E and P coincide;
* (b) N is eventually the unique $\lambda$-MAP; the first time it beats H has mean above $\lambda(h_N-h)/m_H$, and at most $(\lambda(h_N-h)+\gamma)/m_H$ under code Q (where H's costs are bounded by $\gamma$);
* (c) without N, the eventual $\lambda$-MAP is the form of least rate among $m_0$, $m_P$ and $m_H$ (H against P by Prop 3.4; ties by Thm 3.8(ii));
* (d) the expected switch points are:
  * $0\to$E at $\lambda\ell_0/\gamma$ (deterministic, if E is not yet refuted);
  * E$\to$P at the first refutation, mean $1/p$;
  * P$\to$H, if $m_P>m_H$, at a time with mean above $\lambda h/(m_P-m_H)$, and at most $(\lambda h+\gamma_{\rm ex})/(m_P-m_H)$ when $\gamma_{\rm ex}$ is bounded;
  * H$\to$N as in (b).

  When these expected switch points are increasing in this order, the predicted order of the $\lambda$-MAPs is $0\to E\to P\to H\to N$. (`notes.md` called this "the typical sequence" inside a proved statement; how often it occurs is computed below: referee A, m14.)

*Proof.* Theorem 3.8 with the costs of Prop 3.3 and Lemma 3.2: refutation by $T_0$ has probability $p$ per datum, independently. The bound in (d) for P→H is Thm 3.8(iii) applied to the race between E/P and H from $n=0$, at level $\lambda h$. ∎

**Computed [l3 D–F; Q/det cost model]** ($\ell_0=200$, $h=20$, $h_N=2000$, $\pi_c=22$; 400 runs per row):

| error, $\Delta$, $\lambda$ | rates $m_P$ / $m_H$ | most frequent MAP sequences | P$\to$H: mean / Wald | H$\to$N: mean / Wald | first refutation / $1/p$ |
|---|---|---|---|---|---|
| sinusoid, $60'$, 1 | 0.323 / 0.283 | 0EPHN (40), 0EPHPHN (36), 0EPHPHPHN (30) | 529.8 / [495.6, 1251.3] | 7010.1 / [6994.9, 7024.9] | 91.8 / 94.25 |
| sinusoid, $60'$, 2 | 0.557 / 0.283 | 0EPHN (105), 0EPHPHN (68), 0PHN (49) | 214.1 / [146.2, 338.1] | 14033 / [13990, 14020] | 97.1 / 94.25 |
| sinusoid, $10'$, 2 | 3.506 / 2.215 | 0HN (176), 0PHN (56) | 38.5 / [31.0, 73.7] | 1792.7 / [1787.5, 1792.5] | 15.4 / 15.7 |
| sinusoid, $3'$, 1 | 7.389 / 8.543 | 0PN (156), 0P0PN (50) | (P has the lower rate) | 232.6 / [231.8, 233.3] | 5.1 / 4.7 |
| peaked, $10'$, 1 | 0.166 / 2.215 | 0EP (358), 0P (33) | (P) | 896.1 / [893.8, 898.8] (N is never the MAP before $n=4000$: P is cheaper than N there) | 198.9 / 199.3 |

* **Order and alternation.** The five phases $0\to E\to P\to H\to N$ appear in this order when the predicted switch points are ordered (first two rows). When the two rates are close, P and H alternate several times before H settles: Thm 3.8(i) only promises an eventual winner.
* **Monte Carlo error.** The sample means that fall just outside a Wald interval do so by less than one Monte Carlo standard error (about $0.7$ in the third row and $30$ in the second). Referee B's independent simulation (`rb3` B, 2000 runs, seed 20261017) has all means inside the Wald intervals: P→H $612\pm34$ and $214\pm6$; H→N $7017.9\pm10.0$ and $14009\pm14$; first refutation $92.0\pm2.1$ and $94.2\pm2.1$.
* **Ties** [l3 E; rb3 B].
  * With $\pi_c$ tuned so that $m_P=m_H$, $J(P)-J(H)$ changes sign $14.9$ times on average up to $n=2000$ and $148$ times up to $n=2\times10^5$, and 43% of runs still change sign after $n=10^5$. Referee B: $11.3$, $135.6$ and $0.52$; the arcsine law gives $\frac12$ for the last.
  * With $m_P$ 10% above $m_H$: $15.7$ changes up to $2\times10^5$, the last one at a median $n=664$, and none after $10^5$.
* **Scaling** [l3 F]. On one path, $\tau_L/L=0.293$ at $L=10^5$, against $1/(m_P-m_H)=0.285$.

**Computed [l10 H; SAI's pricing, exact theory-machine costs].** The same pool under R/rand, at fresh times:
* **The machines.** E is the exact law. P is the exact law with Laplace-mixture random exceptions, completed over the whole circle, at one extra law bit. H is the uniform band with code-R silence costs. N is a true theory.
* **The setting.** Sinusoidal error, $\varepsilon^*=1'$, $\Delta=60'$, $\lambda=1$, $\ell_0=200$, $h=20$, $h_N=2000$; 400 runs to $n=1.2\times10^5$.
* **Rates.** $m_P=H_2(p)+p\gamma=0.1749$, $m_H=s\beta_e=0.02953$.
* **Predicted switch points.** $0\to$E at $23.6$; first refutation at mean $94.25$; P→H near $\lambda h/(m_P-m_H)=138$; H→N near $\lambda(h_N-h)/m_H=67055$.
* **Observed.**
  * The most frequent sequences are 0EPHN (133), 0EHN (127), 0PHN (66), 0EPHPHN (19), 0EHPHN (16) and 0HN (12). E→H directly means that H overtook E before the first refutation. 0→P means a refutation within the first 24 data, which has probability $1-(1-p)^{24}\approx0.23$.
  * The mean first refutation is $101.7$ (one Monte Carlo standard error is about $4.7$).
  * The mean first time H is the MAP is $133.6$, and the mean first time N is the MAP is $67060$. All 400 runs reach N.

So the phase sequence holds with exact costs under SAI's pricing, within the pool $\{0,E,P,H,N\}$. A pool with band-confined completions (Prop 3.6a) would have SH, not H, as the penultimate phase for this error.

### 3.5 Humility: the independent mass on finer questions

**Proposition 3.10 (what the pool says about finer questions) [proved].** Let $\Pi_\lambda(X\mid D)\propto2^{-J_\lambda(X;D)}$ be P2's power-prior posterior restricted to a finite pool of deterministic forms (code Q) containing 0, E/P, H and possibly N. Ask a new question at a fresh time, with cell width $\Delta'\le2\varepsilon^*$.
* (a) The three-valued prediction of the pool puts:
  * mass $\Pi_\lambda(H\mid D)+\Pi_\lambda(0\mid D)$ on "independent";
  * mass $\Pi_\lambda(E/P\mid D)$ on the cell of $f(t')$, which is wrong with probability $p_{\Delta'}$ over the dither;
  * mass $\Pi_\lambda(N\mid D)$ on the true cell.
* (b) Without N, if the least rate at the training precision $\Delta$ is attained by a unique form, then almost surely, as $n\to\infty$, the posterior concentrates on it (Thm 3.8(i): the log-odds diverge linearly). The inducer ends up:
  * humble, if H or 0 is selected: the independent mass tends to $1$ on finer questions;
  * or overconfident, if P is selected: it asserts a wrong cell with probability $p_{\Delta'}$.

  Which one is decided by Prop 3.4 at $\Delta$, and against 0 by Prop 3.7. If two forms tie in rate with a non-degenerate cost difference, the posterior oscillates between them forever (Thm 3.8(ii)). (`notes.md` omitted the empty law and ties: referee A, m13.)
* (c) In a randomised pool (code R), the honest machine is not silent: its random completion decides every question, putting on each cell the cell's share of the band. More generally, a band-confined completion $\mathrm{BC}_G$ puts on each cell its $G$-mass. Its "humility" is a spread of probability over the cells its band meets, never probability one on a wrong cell. The exact forms put probability $1-\rho$ on the cell of $f(t')$.

*Proof.*
* (a) H is silent on every question with $\Delta'\le2\varepsilon^*$ (Lemma 3.2), and 0 is silent. E/P proves the cell of $f(t')$ ($t'$ is fresh, so it is not a patched time), and N proves the true cell.
* (b) Thm 3.8(i), and $\Pi_\lambda(X)/\Pi_\lambda(Y)=2^{-(J(X)-J(Y))}$.
* (c) Def 3.6a. ∎

**Reading [assessment; revised after referee B, 1].** The trichotomy is the formal home of humility *for deterministic theories*. An honest approximate law is a partial theory, and its silence is the "independent" value. Whether the inducer is humble is not a matter of its prior alone, since the prior favours the overconfident exact law (Cor 2.2), but of the error's shape and the price of silence (Prop 3.4).
* For randomised theories, which is what SAI's one-tape law mixes, the right notion is *calibration*. By Prop 3.6a(c) the asymptotically preferred completion is the true error distribution. A uniform spread over the band is calibrated only for uniform errors.
* The trichotomy's "independent" value appears in $M_A$ only for theories that are silent, not for randomised completions, which decide every question.

### 3.6 The real Kepler residuals

**Data [computed: l4; l10 A].**
* **Bodies and windows.** Mercury, Venus, the Earth–Moon barycentre (EMB), Mars, Jupiter and Saturn (ERFA's plan94), and the Moon (moon98). Windows of 12–2000 years centred on J2000; for the Moon, one month, one year and 18.6 years. 8000 uniform times per body and window.
* **Fits.** One fixed Kepler ellipse (seven elements) is fitted four ways: scout P's 3-D least squares, least squares on longitude and latitude, a robust fit for small mean error, and an $L_p$ continuation for small maximum error. $e(t)$ is the longitude error in arcminutes.
* **The two series kept.** For each window `l4_residuals.npz` keeps the series of the *minimax fit* (least sample $\max|e|$) and of the *mean fit* (least sample mean $|e|$).
* **Agreement with scout P.** The 3-D least-squares column reproduces scout P's Table 2.1 to the expected accuracy (e.g. the Moon over one month, $66.7'$ against P's $1.12°$; Mars over 12 years, $1.71'$ in longitude against P's $1.58'$ angular separation on another sample). The minimax fits are tighter: the Moon is within $30.9'$ of one fixed ellipse in longitude over a month.

**Peakedness per fit (revised after referee A, M6; referee B, 8).** `notes.md` reported as "$\mathrm{pk}(e)$" the ratio $\varepsilon^*(\text{minimax fit})/\Ex|e|(\text{mean fit})$, which mixes two ellipses and is the peakedness of no single law. Each fit's own value:

| body | $\varepsilon^*_{\rm mm}$ (12 / 100 / 2000 yr) | $\mathrm{pk}$, minimax fit | $\mathrm{pk}$, mean fit | cross ratio (`notes.md`'s "pk") | $\beta_e$ (minimax fit) |
|---|---|---|---|---|---|
| Mercury | $0.38'$ / $2.02'$ / $37.4'$ | 2.80–3.19 | 3.29–4.71 | 3.02–3.46 | 0.56–0.59 |
| Venus | $0.36'$ / $0.47'$ / $3.6'$ | 2.27–3.65 | 2.81–4.07 | 2.39–3.66 | 0.54–0.66 |
| EMB | $0.27'$ / $0.62'$ / $7.3'$ | 2.34–3.95 | 2.91–4.03 | 2.42–3.98 | 0.52–0.65 |
| Mars | $1.44'$ / $3.04'$ / $49.9'$ | 2.71–3.38 | 3.33–4.47 | 3.10–3.47 | 0.55–0.60 |
| Jupiter | $0.70'$ / $6.57'$ / $34.0'$ | 1.60–2.65 | 3.00–7.08 | 1.85–2.82 | 0.60–0.84 |
| Saturn | $0.17'$ / $7.46'$ / $81.9'$ | 1.66–2.39 | 3.21–6.91 | 2.30–2.69 | 0.63–0.81 |
| Moon (1 month / 1 yr / 18.6 yr) | $30.9'$ / $156'$ / $480'$ | 1.89–2.21 | 1.89–3.17 | 1.89–2.53 | 0.66–0.72 |

Over all 39 pairs: minimax fit 1.60–3.95, mean fit 1.89–7.08, cross ratio 1.85–3.98 (referee B's values, reproduced by `l10` A). **The real Kepler errors are moderately spread:** a sinusoid has $\pi/2\approx1.57$, uniform $|e|$ has $2$, and scout N2's peaked example had $20$.

**The tolerance must cover the true supremum (referee A, M6).** $\varepsilon^*_{\rm mm}$ is a sample maximum over 8000 times. An honest law with that tolerance is slightly false if the window's true supremum is larger, and it would eventually be refuted.
* *How far the sample maximum may lie below.* A local parabola through the three time-sorted samples around the maximum estimates the true supremum. In 33 of 39 series it estimates an excess of median $2\times10^{-4}$ (relative), at most $1.9\%$ apart from one case. That case, Mercury over 2000 years, gives an estimate ($25\%$) that is unreliable: its sampling interval of about 91 days is comparable to Mercury's 88-day period [computed: l10 A].
* *Effect on the verdicts.* The band machines below use $\varepsilon=(1+\kappa)\varepsilon^*_{\rm mm}$, and the verdicts are identical for $\kappa\in\{0,0.01,0.05\}$ [computed: l10 C]. Within the tolerance family, a datum outside the band costs one randomised exception rather than infinity.

**Selection [computed: l5 (pool of `notes.md`), l10 C (exact H costs and band completions); rb2, rb3 A].** For each body, window, cell width $\Delta\in\{0.1',\dots,1800'\}$ (eleven values), pricing and $\lambda\in\{1,2,4\}$, the per-datum rates are computed from the saved series. The asymptotic $\lambda$-MAP among the forms is the one with the least rate (Thm 3.8(i)); Newton is not in the pool. Under the det pricings, naming a time costs $\pi_c=\log(\text{days in window})+2$ bits: 14.1–21.5 for the planets' windows, and 6.8, 10.5 and 14.7 for the Moon's (`notes.md` said 14–22: referee B, 9). These are finite-horizon cost models (Prop 3.3a).
* **SAI's pricing, within the pool $\{0,P,H\}$** (R/rand; also R/det at $\lambda=1$ and $4$, hence at every $\lambda\ge1$, since $\lambda$ only raises the price of exceptions). The uniform honest law has the least rate in every cell, from $\Delta=0.1'$ to $30°$ (`l5`). `l10` C confirms this with H's exact closed-form costs in 429/429 cells at each $\kappa\in\{0,0.01,0.05\}$. In `l5`'s tolerance family with whole-circle exceptions, the optimum is $\varepsilon\approx(0.7$–$1.0)\varepsilon^*$, with at most 1% of the data as exceptions.
* **SAI's pricing, with completions inside the band (Prop 3.6a).** Adding HY and SH changes the winner in every cell.
  * SH, the law with a 40-bin error histogram fitted on half of the times and scored on the other half, has the least rate in 429/429 cells at each $\kappa$, between $0.4\%$ and $25.7\%$ below H's (median $6.6\%$; `l10` C; `rb2`: 195/195 cells at five widths).
  * HY* beats H in 379 of 429 cells at $\kappa=0.01$. In the coarse regime it does so in 34 of 39 pairs, exactly where Prop 3.6a(d)'s criterion says.
  * The gain persists at fine precision. EMB over 100 years at $\Delta=1'$: H $0.651$, HY* $0.560$, SH $0.503$ bits per datum. Mars over 12 years at $\Delta=1'$: $1.660$, $1.558$, $1.496$.
* **Scout N2's pricing (Q/det, cost model).** The threshold $(\lambda\pi_c+\gamma)/(2\gamma)$ grows as the cells coarsen ($\gamma$ falls), so for each body and window there is a cell width above which the honest law wins.
  * At $\lambda=1$ the honest law wins only at the coarsest cells: $30°$, and already at $10°$ for Jupiter over 30 years and Saturn over 2000 years (and within 2% for Saturn over 300 years; referee B, 9). For 17 of the 39 pairs (e.g. Mars over 12–300 years, the Moon over a month and a year) it does not win even at $30°$ (reproduced exactly by `rb3` A).
  * The exact law with exceptions wins from cells of about $\varepsilon^*$ upwards. At finer cells no law pays: there an honest law is silent at full literal cost.
  * At $\lambda=2$ the takeover width ranges from $8.1'$ (Jupiter over 30 years) to $962'$ (the Moon over 18.6 years), median $134'$. At $\lambda=4$ it ranges from $0.72'$ (Venus over 12 years) to $962'$ (the Moon over 18.6 years), median $13.4'$ (`rb3` A, exact on a fine grid; `l5` agrees to its grid).
  * The tolerance family's optimum at $\lambda=1$ is a small tolerance ($0.05$–$0.5\varepsilon^*$) with exception shares up to tens of per cent: a law "exact except in a stated share of cases".
* **Q/rand.** The exact law with random exceptions wins almost everywhere.
* **What the cell-by-cell agreement of `l5` D shows.** In all 1757 (body, window, $\Delta$, pricing) cells of the coarse regime, the two-law criterion of Prop 3.4(b), with $f_1$ the mean fit and $f_2$ the minimax fit, picks the same pure form as the computed rates. Under the det pricings this compares a formula with its own rearrangement, so it is a consistency check of the code, not evidence for the proposition (referee B, 9). The evidence for Props 3.3–3.4 is the exact checks of `rb1` A, D and the simulations of `l3` B.

**Reading [assessment; rewritten after referee B, 1].**
* **The verdict on Kepler's errors depends on the pricing.**
  * Under literal pricing (code Q) with deterministic patches, they are held as "exact with exceptions" at $\lambda=1$, and honestly only under a steeper prior or at coarse precision.
  * Under SAI's pricing and within the pool of `notes.md`, the uniform honest band wins everywhere. But that pool omits the completions that matter.
  * Among Kepler-based theory machines, SAI's mixture prefers *Kepler's law together with an error distribution shaped like its residuals* (SH). For 34 of the 39 body–window pairs, even the crude two-point model HY ("exact with probability $1-\rho$, else uniform within $\varepsilon$") beats the uniform band.
* **What "approximately true" becomes.** Under SAI's pricing, an approximately true law is a law with a calibrated error model. It is neither a silent partial theory nor an exact law with listed exceptions.
* **Humility.** The silence-based humility of Prop 3.10(a) appears for Kepler only in the deterministic, code-Q reading, and only at steep $\lambda$.
* **Scope.** The real residuals are deterministic functions of time, so a better theory (Newton, or the ephemeris itself) eventually beats every Kepler-based machine (Prop 3.6a(c) concerns the i.i.d. model).
* **Cross-check with `philosophy`.** The 3-D least-squares maxima agree with scout P's Table 2.1, and the minimax longitude errors here are the relevant tolerances for interval data in longitude.

---

## 4. Derivation horizons and the sound criterion for approximate reasoning (T4)

**Setting.**
* Constants $x_0,x_1,\dots$ for the states of a system in $\mathbb R^d$ (or a function symbol on time), over $B=\mathrm{RCF}$.
* A map $F$, definable in $B$, with a Lipschitz constant $L$ for a norm $|\cdot|$ that $B$ proves. For a linear $F(x)=Ax$ with rational $A$ and the sup-norm, $L=\|A\|_\infty$, provably in $\mathrm{RCF}$.
* The **honest dynamical law** is $T^\varepsilon_F:=\{|x_0-a|\le e_0\}\cup\{|x_{s+1}-F(x_s)|\le\varepsilon:s\ge0\}$.
* The **exact law** is $T^0_F:=\{x_0=a\}\cup\{x_{s+1}=F(x_s):s\ge0\}$.

**Proposition 4.1 (derivation horizon) [proved; computed: l6 A, B; rb5 A–C].**
* (a) For every $L\ge0$, $T^\varepsilon_F\vdash|x_r-F^r(a)|\le e_r$, with $e_r:=L^re_0+\varepsilon(L^r-1)/(L-1)$ for $L\ne1$ and $e_r:=e_0+r\varepsilon$ for $L=1$.
* (b) Let $F(x)=Ax$ be linear with sup-norm tolerances. The values of $x_{r,i}$ over the models of $B\cup T^\varepsilon_F$ form exactly the interval $(A^ra)_i\pm h_{r,i}$, with $h_{r,i}:=e_0\|(A^r)_{i\cdot}\|_1+\varepsilon\sum_{s<r}\|(A^s)_{i\cdot}\|_1$ (the projection of a zonotope). So $T^\varepsilon_F$ proves "$x_{r,i}\in[v-\delta,v+\delta]$" iff that interval contains $(A^ra)_i\pm h_{r,i}$. In $d=1$, $h_r=e_r$ with $L=|A|$, so (a) is tight.
* (c) Put $r^*(\delta):=\max\{r:e_r\le\delta\}$. For $e_0=0$:
  * $r^*(\delta)=\lfloor\delta/\varepsilon\rfloor$ for $L=1$;
  * $r^*(\delta)=\lfloor\log_L(1+\delta(L-1)/\varepsilon)\rfloor$ for $L>1$;
  * for $L<1$, $r^*=\infty$ iff $\delta\ge\varepsilon/(1-L)$ (contracting dynamics have no horizon at tolerances above their limit error), and $r^*=\lfloor\log_L(1-\delta(1-L)/\varepsilon)\rfloor$ otherwise.

  For every $L$-Lipschitz $F$, $T^\varepsilon_F$ proves a datum at precision $\delta$ about $x_r$, centred at $F^r(a)$, *if* $r\le r^*(\delta)$ (by (a)). For linear $F$ in $d=1$ with $L=|A|$, also *only if* (by (b)). For non-linear $F$ the "only if" fails (referee B, 6).

*Proof.*
* (a) Induction: $|x_{s+1}-F^{s+1}(a)|\le|x_{s+1}-F(x_s)|+|F(x_s)-F(F^s(a))|\le\varepsilon+Le_s$. Each step is an instance of the axioms and of the provable Lipschitz inequality.
* (b) $x_r-A^ra=A^r(x_0-a)+\sum_{s<r}A^{r-1-s}u_s$, with $u_s:=x_{s+1}-Ax_s$. The deviations $x_0-a$ and $u_s$ range freely over sup-norm boxes in the real model.
  * A linear image of a product of boxes is a zonotope, which is convex; its projection on coordinate $i$ has half-width the sum of the $\ell_1$ norms of the corresponding rows, and the extreme values are attained by sign choices.
  * Every value in the interval is attained in $\mathbb R$, so a narrower interval statement fails in a model and is unprovable.
  * The full interval follows from the axioms by the triangle inequality, as in (a), with the row sums in place of $L^s$.
* (c) Solve $e_r\le\delta$; the "if" is (a), and the "only if" for linear $d=1$ is (b). ∎

**Counterexample to "only if" for non-linear $F$ [computed: rb5 C, exact].** Take $F(x)=0$ on $[-1,1]$ and $F(x)=2(x-\operatorname{sign}x)$ outside, so $L=2$, with $a=0$, $e_0=0$ and $\varepsilon=1/10$.
* The set of values of $x_r$ over the models is exactly $[-1/10,1/10]$ for every $r\le30$.
* So $T^\varepsilon_F$ proves "$x_r\in[-1/10,1/10]$" at every depth, while $e_r=(2^r-1)/10$ gives $r^*(1/10)=1$.

**Computed [l6 A, B; rb5 A, B].**
* *Closed form.* It agrees with exact interval propagation to $4\times10^{-15}$ (relative) for $r\le200$ and $L\in\{0.5,0.9,0.99,1,1.01,1.1,2\}$. The horizon formula agrees with the iterated computation in every cell (referee B: exactly in 2015/2015 cells).
* *Horizons.* At $\delta/\varepsilon=10^4$ they are $10^4$, $463$, $72$ and $13$ for $L=1$, $1.01$, $1.1$ and $2$, and infinite for $L\le0.99$ (limit errors $\le100\varepsilon$).
* *Zonotope versus boxes.* In $d=3$ and $d=10$, for random matrices of spectral radius $0.95$–$1.05$:
  * the exact tolerance $h_{r,i}$ is attained by the constructed sign sequences (50/50 in every row; referee B: 600/600 by enumerating all sign vectors in exact rationals);
  * interval-arithmetic box propagation overestimates it by a median factor of $5$–$300$ at $r=10$, and up to $10^9$ at $r=30$ (the wrapping effect of interval methods);
  * the $\infty$-norm Lipschitz bound overestimates it by up to $10^{13}$;
  * the order exact $\le$ box $\le$ Lipschitz held in all cases.

So what the honest theory proves is the exact zonotope, and a reasoner that propagates boxes has a much shorter effective horizon than the theory.

**Proposition 4.2 (the horizon of an exact approximation) [proved; hypotheses made explicit after referee A, m9].** Suppose the true trajectory satisfies $T^\varepsilon_F$, but the inducer holds the exact law $T^0_F$ (with the same $a$).
* $T^0_F$ is consistent and proves $x_r=F^r(a)$, which is within $e_r$ of the true $x_r$ (Prop 4.1(a), with the true $e_0$).
* *If* $r\le r^*(\delta)$, the depth-$r$ conclusions of $T^0_F$ are $\delta$-correct for every trajectory compatible with the honest law.
* For linear $F$ in $d=1$ with $L=|A|$, some trajectory compatible with the honest law attains the deviation $e_r$ (Prop 4.1(b)). So in that case the conclusions are $\delta$-correct for all such trajectories *only if* $r\le r^*(\delta)$.
* $T^0_F$ together with one true datum about $x_r$, whose interval excludes $F^r(a)$, is inconsistent and so proves every sentence.

*Proof.* The true trajectory is a model of $T^\varepsilon_F$. The first three claims are Prop 4.1(a),(b). For the last, the datum and $x_r=F^r(a)$ are jointly refutable in $B$. ∎

**Reading [assessment].** For an exact but false approximation, the length of a derivation bounds the error of its conclusion. For an honest one, the theory itself says how far its conclusions can be trusted, and it is silent beyond the horizon. So an approximate law's domain of applicability includes a bound on derivation depth. This links the approximation results of this record with the reasoner-relative results of `shape`.

**Proposition 4.3 (a sound criterion for reasoning with approximate models) [proved; computed: l6 D; rb5; hypothesis added after referee A, M3].** Let $T_i:=\{\forall t\in\mathrm{Dom}_i:\ |q(t)-f_i(t)|\le\varepsilon_i\}$, $i\le k$, be honest pointwise models of one quantity $q$ (scalar, or vector-valued with a norm), with $q$ otherwise unconstrained, and let $T_i^0$ be their exact versions ($\varepsilon_i=0$).
* (a) Let $B$ be true in the intended structure. If every $T_i$ is true, then $\bigcup_iT_i$ is consistent, and every sentence derivable from $B\cup\bigcup_iT_i$ is true. In particular every derived statement about $q(t)$ is a set containing the true value.

For (b)–(d), assume in addition that **$B$ decides every sentence built from the $f_i$, the $\mathrm{Dom}_i$ and the $\varepsilon_i$ at the times concerned**. An example is $B=\mathrm{RCF}$ with semialgebraic $f_i$ and $\mathrm{Dom}_i$ and rational $\varepsilon_i$, the case §4 uses.
* (b) $\bigcup_iT^0_i$ is inconsistent iff $f_i(t)\ne f_j(t)$ for some $t\in\mathrm{Dom}_i\cap\mathrm{Dom}_j$. It then proves every sentence ("$100=99.9$" gives everything).
* (c) $\bigcup_iT_i$ is consistent iff, for each $t$, the balls $\{v:|v-f_i(t)|\le\varepsilon_i\}$ with $t\in\mathrm{Dom}_i$ have a common point.
  * For scalar $q$, and for vector $q$ with sup-norm (box) tolerances, this holds iff it holds pairwise: $|f_i(t)-f_j(t)|\le\varepsilon_i+\varepsilon_j$ on every overlap.
  * For Euclidean tolerances in $\mathbb R^m$, $(m+1)$-wise intersection is necessary and sufficient, and pairwise intersection is not sufficient.
* (d) Conclusions carry propagated tolerances. If $g$ is $L_g$-Lipschitz (provably in $B$), then $T_i\vdash|g(q(t))-g(f_i(t))|\le L_g\varepsilon_i$. Iterated dynamics are Prop 4.1.

Without the hypothesis, (b) and (c) fail. Take $B=\emptyset$, $f_i(t)$ and $f_j(t)$ distinct constant symbols, and $\mathrm{Dom}$ a single point: then $T^0_i\cup T^0_j$ is consistent (interpret the two constants as equal), although the values differ in the intended structure (referee A, M3).

*Proof.*
* (a) The intended structure is a model, and derivations preserve truth.
* (b) If two exact models disagree at $t$, they prove $f_i(t)=f_j(t)$, which $B$ refutes by the hypothesis. If they agree on all overlaps, then in every model of $B$ (where the $f_i$-values are fixed by $B$'s decisions) $q(t):=f_i(t)$ for $t\in\mathrm{Dom}_i$, arbitrary elsewhere, is a model.
* (c) The constants $q(t)$ for different $t$ are distinct and otherwise unconstrained. So, by compactness, $B\cup\bigcup_iT_i$ is consistent iff, for each $t$, $B$ is consistent with "$\exists v$ in all the balls at $t$".
  * By the hypothesis $B$ decides this sentence, and $B$ is true in the intended structure. So it is consistent with $B$ iff it holds there, i.e. iff the balls have a common point.
  * Intervals that intersect pairwise have $\max_i(\text{left end})\le\min_j(\text{right end})$, which is a common point (Helly's theorem in dimension 1). Boxes are products of intervals.
  * Helly's theorem in $\mathbb R^m$ gives the $(m+1)$-wise criterion [known: helly1923mengen; standard].
  * Three discs centred at the vertices of an equilateral triangle of side $2$, with radius $1.1$, meet pairwise but have no common point: the circumradius is $2/\sqrt3\approx1.155$.
* (d) The Lipschitz inequality in $B$. ∎

**Computed [l6 D; rb5].** Pairwise overlap and joint overlap agree on $10^5$ random families of $2$–$6$ intervals and on $2\times10^4$ random families of boxes in $\mathbb R^2$ (referee B: on all 12628 families of 2–4 integer intervals and on 20000 box families). The disc family above is the explicit counterexample for Euclidean tolerances.

**Remark 4.4 (typical against worst case) [computed: l6 C; rb5].** The criterion is worst-case.
* With $L=1$ and $r=100$ steps, the worst case is $100\varepsilon$.
* With independent random-sign errors $\pm\varepsilon$, the mean deviation is exactly $\varepsilon\,r\binom{r}{r/2}2^{-r}=7.96\varepsilon$ ($\approx\varepsilon\sqrt{2r/\pi}$; scout N2's simulation gave $7.8\varepsilon$). With uniform errors on $[-\varepsilon,\varepsilon]$ it is about $4.6\varepsilon$.
* At $r=1000$: $25.2\varepsilon$ against $1000\varepsilon$.
* For $L=1.1$ and $r=100$: about $2.4\times10^4$ against $1.38\times10^5$.

A probabilistic error model answers much further out, with a stated confidence instead of a guarantee.

**What this supplies to `philosophy` T6 (no assessment here).** Prop 4.3 is the formal content behind scout N2's "Possible error" candidate on the domain-of-applicability note. A sound formal criterion exists:
* state approximations with tolerances and domains;
* combine them only where the tolerances overlap, which in one dimension is a pairwise check;
* propagate the tolerances.

It blocks the "$100=99.9$" catastrophe exactly (Prop 4.3(b) against (a)), it needs a background that decides the comparisons (true for semialgebraic models over $\mathrm{RCF}$), and it is worst-case (Remark 4.4). Whether the note's claim is an error is assessed in `philosophy`.

---

## 5. The best system as a steeper MAP; explanatory power (T5)

The objective is $J_\lambda(T;D)=\lambda|T|+\mathrm{Exc}_D(T)$ over a class of laws with private literal facts ($\mathcal H^Q$ or $\mathcal H^R$, §1.4). Prop 1.9(d) is why the class matters: over all randomised theories, a steeper penalty selects nothing long.

### 5.1 Marginal slopes and explanatory power

**Proposition 5.1 (marginal slopes) [proved].** Let $T^*$ be a $\lambda$-MAP within a family of theories that contains $T^*\setminus\mathcal A$ and $T^*\cup\mathcal B$ for the modules considered.
* For every module $\mathcal A\subseteq T^*$: $\mathrm{Exc}_D(T^*\setminus\mathcal A)-\mathrm{Exc}_D(T^*)\ge\lambda\|\mathcal A\|$.
* For every $\mathcal B$ disjoint from $T^*$: $\mathrm{Exc}_D(T^*)-\mathrm{Exc}_D(T^*\cup\mathcal B)\le\lambda\|\mathcal B\|$.

*Proof.* $J_\lambda(T^*)\le J_\lambda(T^*\setminus\mathcal A)$ and $J_\lambda(T^*)\le J_\lambda(T^*\cup\mathcal B)$, with $|T^*|-|T^*\setminus\mathcal A|=\|\mathcal A\|$ and $|T^*\cup\mathcal B|-|T^*|=\|\mathcal B\|$ (Def 1.2). ∎

**Definition 5.2 (explanatory power; NOTATION §6.4).** $\mathrm{EP}_D(\mathcal A;T):=\big(\mathrm{Exc}_D(T\setminus\mathcal A)-\mathrm{Exc}_D(T)\big)/\|\mathcal A\|$: bits of data explained by the module, per bit of its statement, in the context $T$.
* By Prop 5.1, every module of a $\lambda$-MAP has $\mathrm{EP}\ge\lambda$, and no addition has $\mathrm{EP}>\lambda$.
* **When the vertex theories of a hull edge are nested** (the longer one is the shorter one plus a module), the edge slope (P2 `lem:setup:hull`) is the explanatory power of that module, averaged over the edge (P2 `rem:kink:reading`). For non-nested vertex theories the edge slope is a rate of exchange between length and fit, not the EP of any module (referee A, m16).
* EP depends on the context: a law and the initial conditions it needs explain nothing apart and much together.

**Proposition 5.3 (facts used once never enter for $\lambda>1$) [proved; (b) given Prop 1.11 and P2 `cor:kink:split`].**
* (a) Let $T^*$ be a $\lambda$-MAP with $\lambda>1$, and $\chi$ a sentence. Suppose that, *in the context $T^*\setminus\{\chi\}$*, adding $\chi$ turns exactly the exceptions $E_\chi\subseteq D$ into proved data and changes nothing else, and that $\sum_{d\in E_\chi}\gamma(d)<\lambda\ell(\chi)$. Then $\chi\notin T^*$.
  * In particular this applies to a datum's answer stated as an axiom ($E_\chi=\{d\}$) whenever the axiom code is no shorter than the literal code, $\gamma(d)\le\ell(a)$, and stating it proves no other datum in that context. (`notes.md` stated the hypothesis for one theory and applied it to every MAP: referee A, m15.)
* (b) No code does better on average. Let $T_s$ be $b$-sufficient ($|T_s|+\mathrm{Exc}_D(T_s)\le K(y_D\mid\dom D)+b$) in a class where provability on the data is decidable.
  * Every theory $T$ has $\mathrm{Exc}_D(T)\ge\mathrm{Exc}_D(T_s)-(|T|-|T_s|)-(b+\kappa)$.
  * So a module $\mathcal A$ added to $T_s$ has $\mathrm{EP}_D(\mathcal A;T_s\cup\mathcal A)\le1+(b+\kappa)/\|\mathcal A\|$.
  * Every $\lambda$-MAP with $\lambda>1$ has $|T|\le|T_s|+(b+\kappa)/(\lambda-1)$.

*Proof.*
* (a) If $\chi\in T^*$, deleting it raises $\mathrm{Exc}$ by exactly $\sum_{d\in E_\chi}\gamma(d)<\lambda\ell(\chi)=\lambda\|\{\chi\}\|$, which contradicts Prop 5.1.
* (b) Prop 1.11(b) is the coding bound $|T|+\mathrm{Exc}_D(T)\ge K(y_D\mid\dom D)-\kappa$. With $b$-sufficiency, this is the right line of slope $1$ of P2 `cor:kink:split`(a), and that corollary gives the length bound. ∎

So at $\lambda=1$ a fact that explains only itself is excluded only by the code's per-axiom overhead, while any $\lambda>1$ excludes every module whose explanatory power is below $\lambda$. Facts used once never qualify.

### 5.2 Laws, initial conditions and contingent facts

**Definition 5.4 (the solar-system toy; scout N2 §4.2).**
* Bodies $b\le m$ with $n_b$ observations each, each observation of literal cost $c$ (code Q).
* Modules:
  * the law $\Lambda$ ($L$ bits);
  * body $b$'s elements $E_b$ ($k$ bits);
  * $K3$ ($L_3$ bits), which shortens every elements module by $s$ bits ($0<s<k$), because it derives the period from the semi-major axis.
* $\Lambda\cup E_b$ proves all of $b$'s observations, and no other combination proves any observation. Laws alone answer no position question (`philosophy` T4, scout P's Prop 2.1), and elements alone answer none.
* Theories are $(\Lambda?,K3?,S)$, with $S$ the set of bodies whose elements are axioms.

**Proposition 5.5 (the $\lambda$-MAP in closed form) [proved; computed: l7 A, C, l10 J; rb4 A].** Put $k_\Lambda:=k$, $k_{\Lambda+K3}:=k-s$ and $N:=\sum_bn_b$. The optimal values of the three law choices are
$$J^*_\emptyset=cN,\qquad J^*_\Lambda=\lambda L+\sum_b\min(cn_b,\lambda k),\qquad J^*_{\Lambda+K3}=\lambda(L+L_3)+\sum_b\min(cn_b,\lambda(k-s)).$$
They are attained by $S_\chi(\lambda):=\{b:cn_b>\lambda k_\chi\}$ (bodies with $cn_b=\lambda k_\chi$ may go either way), and the $\lambda$-MAP is the best of the three. ($K3$ without $\Lambda$ is useless.) In particular:
* (a) $\Lambda$ beats the empty theory iff $\sum_{b\in S_\Lambda(\lambda)}(cn_b-\lambda k)>\lambda L$.
* (b) $J^*_{\Lambda+K3}-J^*_\Lambda=\lambda L_3-\sum_b\big[\min(cn_b,\lambda k)-\min(cn_b,\lambda(k-s))\big]$. If no body has $\lambda(k-s)<cn_b\le\lambda k$ (so $S$ is the same with and without $K3$), then **$J^*_{\Lambda+K3}<J^*_\Lambda$ iff $s|S|>L_3$, whatever $\lambda$ is**. $K3$ is in the $\lambda$-MAP iff in addition $J^*_{\Lambda+K3}<J^*_\emptyset$.
* (c) In the MAP $T^*=\Lambda\cup\{E_b:b\in S\}$: $\mathrm{EP}(\Lambda)=c\sum_{b\in S}n_b/L$ and $\mathrm{EP}(E_b)=cn_b/k_\chi$. With $m$ bodies of $n$ observations each, these are $mnc/L$ and $nc/k_\chi$.

*Proof.*
* For a fixed law choice, $J_\lambda$ is a constant plus $\sum_b$ (the cost of body $b$), where including $E_b$ costs $\lambda k_\chi$ and excluding it costs $cn_b$. Minimise each term.
* (b) The bracket is $\lambda s$ when $cn_b>\lambda k$, $cn_b-\lambda(k-s)$ in between, and $0$ otherwise. The $\lambda$-MAP is the best of the three law choices, including the empty one.
* (c) Deleting $\Lambda$ (resp. $E_b$) makes exactly the observations of the bodies in $S$ (resp. of $b$) literal. ∎

**Corrected after referee B, 3: "K3 enters" in `notes.md` read as "is in the $\lambda$-MAP" is false.** `notes.md` wrote "K3 enters iff $s|S|>L_3$, whatever $\lambda$ is", and §5.2 and §9.1 read it as membership of the $\lambda$-MAP.
* *Counterexample.* Two bodies with one observation each, $c=10$, $L=1000$, $k=5$, $s=4$, $L_3=1$, $\lambda=1$: $S$ is both bodies with and without $K3$, and $s|S|=8>L_3$, but the $\lambda$-MAP is the empty theory, $J^*_\emptyset=20$ against $J^*_\Lambda=1010$ and $J^*_{\Lambda+K3}=1003$ [computed: l10 J; rb4].
* *Frequency.* Among 13250 random cases with the same $S$ under both law choices, "$J^*_{\Lambda+K3}<J^*_\Lambda$ iff $s|S|>L_3$" holds in all 13250, and the literal reading fails in 1445 [l10 J] (referee B: 475 of 5035).

**Refuted: scout N2's stated $K3$ criterion** (Prop 4.5 there: "K3 is in the $\lambda$-MAP iff $s\cdot|S(\lambda)|>\lambda L_3$" when $S$ is the same under both choices).
* *Counterexample* [computed: l7 A; rb4]. Take 15 bodies with 1000 observations each, $L=300$, $L_3=150$, $k=60$, $s=15$, $c=12.4$, $\lambda=2$. Then $J(\Lambda+K3+\text{all})=2250<J(\Lambda+\text{all})=2400$ (both below $J^*_\emptyset$), so $K3$ is in the $\lambda$-MAP. But $s|S|=225$, which is $>L_3=150$ and $<\lambda L_3=300$.
* *Brute-force checks.*
  * Over 2100 random cases (2–8 bodies, random parameters, seven values of $\lambda$), the closed form agrees with brute force in all 2100. Among the 1473 cases with the same $S$ under both choices, "$s|S|>L_3$" decides the comparison of the two law choices in all 1473, and N2's statement in 1280.
  * Referee B's brute force over all $2^{m+2}$ theories agrees with the closed form in 10500/10500 exact cases.
* *N2's computed tables* were obtained by evaluating all choices and are unaffected. `l7` C reproduces them:
  * on N2's population, "law + 8 planets" is the $\lambda$-MAP for $\lambda\in(7.03,135.37)$, a vertex with incoming slope $135.37$ and outgoing slope $7.03$ (ratio $19.3$; referee B: $135.3667$ and $7.0267$);
  * $K3$ enters below $\lambda=7$, where asteroids raise $|S|$. At $\lambda=6.75$, $K3$ is in although $s|S(\lambda)|=135<L_3$: with $K3$, more bodies pay for their elements (the second case of (b)).

**Reading [assessment].**
* **$K3$ is a law about initial conditions** in an exact sense. It explains no datum; it compresses the elements. Both the bits it costs and the bits it saves are law-part bits, so its entry against the law without it is decided at exchange rate $1$ ($s|S|$ against $L_3$), not at the balance $\lambda$. $\lambda$ matters only through which bodies' elements are in the theory, and through whether any law pays at all.
* **The model–randomness split of P2 does not separate laws from initial conditions.** Well-observed bodies' elements have $\mathrm{EP}=cn_b/k$ in the hundreds, and they sit on the steep side of the hull with the law. What the split separates is facts reused across many data from facts used once (Prop 5.3). This corrects the brief's seed ("a steeper prior separates laws ... from contingent facts such as orbital elements").
* **What singles out the law is how its explanatory power scales.** It scales with the number of systems ($mnc/L$), while the elements' scales only with the observations of one system ($nc/k$). [computed: l7 D: with $n=5$ observations per body, $\mathrm{EP}(\Lambda)=20.7$ at $m=100$ and $207$ at $m=1000$, while each body's elements have $\mathrm{EP}=1.38$ (with $K3$).] In the toy the law needs the elements to explain anything, so with few observations per body neither enters at $\lambda$ above $nc/k_\chi$.

**Proposition 5.6 (Lewis's "kind nature" is a kink) [proved, given P2 `lem:setup:hull` and `cor:kink:locate`; computed: l7 B; rb4 B].** Take a family of candidate theories satisfying the hull lemma's hypotheses (Prop 1.10), and $0\le\tau<\sigma\le\infty$. The following are equivalent:
* (a) the set of $\lambda$-MAPs is the same for every $\lambda\in(\tau,\sigma)$;
* (b) some hull vertex $v_i$ has $\sigma_{i+1}\le\tau$ and $\sigma\le\sigma_i$;
* (c) the point family has a zero-window $(\sigma,\tau)$-kink at a point that is a hull vertex.

*Proof.*
* (b)⇒(a): by P2 `lem:setup:hull`(v), for $\lambda\in(\sigma_{i+1},\sigma_i)$ the $\lambda$-MAPs are exactly the programs at $v_i$.
* (a)⇒(b): suppose some edge slope $\sigma_j$ lay in $(\tau,\sigma)$. At $\lambda=\sigma_j$ the $\lambda$-MAP set is the set of programs on the closed edge $[v_{j-1},v_j]$, by (v). This differs from the set just below $\sigma_j$, the programs at $v_j$ only, since $v_{j-1}\ne v_j$. So $(\tau,\sigma)$ lies in one interval $(\sigma_{i+1},\sigma_i)$.
* (b)⇔(c): P2 `cor:kink:locate`(c), both directions. ∎

**Computed [l7 B, C; rb4 B].** On 400 random point families with 10 random intervals each, "the MAP set is constant on $(\tau,\sigma)$", tested exactly at every pairwise crossing point and between consecutive ones, agrees with (b) in 4000/4000 cases. Referee B: 7170/7170, including collinear points, duplicate points, interval ends at hull slopes, and $\sigma=\infty$. In N2's toy, the best system "law + 8 planets" is robust over $(7.03,135.37)$, a factor of $19.3$ in the balance.

**Reading [assessment].** Lewis's best-systems account balances simplicity against strength. Lewis wrote that how good the best balance is "will depend on how kind nature is" [known: lewis1994humean; content: secondary, the quoted sentence and page 478 seen in a citing source found by WebSearch, not in Lewis's text].
* In the steeper objective, the balance is $\lambda$, and strength is fit to data in a fixed base language. Nature is kind on an interval of balances exactly when the data's hull has a kink there: then every balance in the interval selects the same system.
* Inside the interval, the worry that the best system depends on an arbitrary choice of balance [known: woodward2014simplicity; content: abstract/secondary via `philosophy`] is moot. Below the kink (here $\lambda<7$), the selected system changes with every asteroid.
* Kindness is a checkable property of a language, a candidate family and a data set, not of nature alone.

**Proposition 5.7 (the trivialisation is blocked) [proved, given Prop 1.11; constant made explicit after referee A, m10].** Let $\mathcal L'\supseteq\mathcal L$ be any extension of the language, for example by Lewis's predicate $F$, true of exactly the actual things, with the axiom $\forall xFx$. Fix a syntax code for $\mathcal L'$. Let the data be base-language answers whose provability from the theories considered is decidable. Then every finite $T$ in $\mathcal L'$ consistent with $D$ has
$$|T|+\mathrm{Exc}^Q_D(T)\ \ge\ K(y_D\mid\dom D)-K(\mathcal L')-c,$$
where $K(\mathcal L')$ is the complexity of (a decoder for) $\mathcal L'$ and its syntax code. Without decidability, add $n$ on the left. If $\mathcal L'$ and its code are fixed independently of $D$, the term $K(\mathcal L')$ is a constant.

*Proof.* Prop 1.11's decoder searches for proofs from $T$ of base-language answers. Given a decoder for $\mathcal L'$'s syntax, it does not otherwise depend on the language. ∎

**Reading [assessment].** Lewis's trivialisation worry [known: lewis1983new; content: secondary] is that a predicate true of exactly the actual things makes "$\forall xFx$" maximally simple and strong.
* Measured as derivation of base-language data with a coding bound, $F$ buys nothing. Its connection to the data must be stated in bridge axioms, and these pay for every bit.
* A language *chosen after the data* can hide the data in its own description. That cost appears as $K(\mathcal L')$, which is exactly the point of the worry.
* What remains is the choice of base language, and of which questions are data: Cohen and Callender's relativisation of best systems to a vocabulary [known: cohen2009better; content: secondary].

### 5.3 Explanatory power, unification and Myrvold's measure

**Proposition 5.8 (EP as likelihood ratio; Myrvold's unification term) [proved; computed: l7 E; ra1 G, rb4 D].** Write $P_T(D):=2^{-\mathrm{Exc}_D(T)}$ (code Q or R) and, for a hypothesis $h$ and a background $T_\flat$:
* $I(h;D\mid T_\flat):=\log\big(P_{T_\flat\cup h}(D)/P_{T_\flat}(D)\big)$;
* $U(D_1,D_2;h\mid T_\flat):=I(h;D_1\cup D_2\mid T_\flat)-I(h;D_1\mid T_\flat)-I(h;D_2\mid T_\flat)$, for data sets on disjoint questions;
* $I_x(D_1;D_2):=\log\frac{P_x(D_1\cup D_2)}{P_x(D_1)P_x(D_2)}$.

Then:
* (a) $\|\mathcal A\|\cdot\mathrm{EP}_D(\mathcal A;T)=I(\mathcal A;D\mid T\setminus\mathcal A)$.
* (b) For every $h$ and $T_\flat$, $U(D_1,D_2;h\mid T_\flat)=I_{T_\flat\cup h}(D_1;D_2)-I_{T_\flat}(D_1;D_2)$, with no assumption on $P_{T_\flat}$ (referee A, m20). If $P$ is a product over questions for both theories (Prop 1.10: $\mathcal H^Q$ on pointwise laws, $\mathcal H^R$ on distinct times), then $U=0$ for every split: in the two-part code with stated parameters, explanatory power is additive over data.
* (c) Let $h$ be a law family with a $k$-bit parameter $\theta$ (uniform prior), $P_h(D):=2^{-k}\sum_\theta P_{h\cup\{\theta\}}(D)$, and $P_\emptyset$ a product.
  * If each of $D_1$ and $D_2$ is proved by $h\cup\{\theta^*\}$ and has likelihood $0$ under every other $\theta$, then $U(D_1,D_2;h)=k$.
  * If $\theta=(\theta_1,\theta_2)$ with $D_i$ depending only on $\theta_i$, then $U=0$.
  * If $\theta_i=(C,\phi_i)$ share a $k_C$-bit constant $C$ and each $D_i$ identifies $(C,\phi_i)$, then $U=k_C$.

*Proof.*
* (a) The definition.
* (b) Expand the six logarithms. The first term of the difference is $\log P_{T_\flat\cup h}(D_{12})-\log P_{T_\flat\cup h}(D_1)-\log P_{T_\flat\cup h}(D_2)$, and the second is the same expression for $T_\flat$. A product law makes $I_x(D_1;D_2)=0$.
* (c) Use (b), with $I_\emptyset=0$.
  * In the first case, $P_h(D_1)=P_h(D_2)=P_h(D_1\cup D_2)=2^{-k}$, so $I_h(D_1;D_2)=k$.
  * In the second, $P_h(D_1\cup D_2)=P_h(D_1)P_h(D_2)$.
  * In the third, $P_h(D_i)=2^{-k_C-k_\phi}$ and $P_h(D_1\cup D_2)=2^{-k_C-2k_\phi}$, so $I_h=k_C$. ∎

**Computed [l7 E; ra1 G; rb4 D].** With $k=6$ and observations given by a random table: stated parameter, $U=0.00$; marginalised parameter and one body, $U=6.00$; two bodies with independent parameters, $U=0.00$; two bodies sharing a 3-bit constant, $U=3.00$. The identity of (b) holds to $3\times10^{-15}$ on 1000 random joint laws (`ra1` G) and to $9\times10^{-16}$ on 2000 random tables (`rb4` D).

**Relation to Myrvold [known: myrvold2003bayesian; content: secondary].** Myrvold's account, as reported in search summaries of his paper and of its critics, measures unification as the degree to which a hypothesis makes phenomena informationally relevant to one another; it was later called "mutual information unification". It shows that the support a hypothesis gets from joint evidence splits into the supports from the parts plus this term. $U$ of Prop 5.8 has that form, by the identity (b). His exact notation was not checked against his text: neither this thread nor referee A could fetch it. The precise relation:
* EP is the *total* support per bit of statement in the two-part code, where parameters are stated. There Myrvold's term is identically zero (Prop 5.8(b)), and unification appears instead as a module whose EP grows with the number of systems it serves (§5.2).
* Myrvold's term is the support due to *shared unknown parameters* when they are integrated out (Prop 5.8(c)): $k$ bits within one system, nothing across systems with independent initial conditions, and $k_C$ bits across systems that share a constant. A law with a universal constant (the third-law constant, $G$) unifies across systems in his sense; a law whose systems share nothing unifies across them only in the EP sense.

**Copernicus against Ptolemy (scout N2 §4.4, `philosophy` §3.4) [proved; the lengths are not measured; comparisons separated after referee A, m11].** Three theories with a common part:
* $P_f$: Ptolemy with free epicycle phases. It pays the coincidence of each superior planet's retrogression with opposition in its fit, $a_p$ bits per planet.
* $P_s$: Ptolemy with the coincidences stated as axioms, $\sum_pa_p$ more law bits than $P_f$, with the same fit as Copernicus.
* $C$: Copernicus, $H$ more law bits than $P_f$ (the heliocentric reorganisation), with the same fit as $P_s$.

Then:
* **$C$ against $P_s$** (same fit, same predictions): $C$ wins at every $\lambda$ iff $H<\sum_pa_p$. This is unification without better prediction.
* **$C$ against $P_f$**: $C=P_f$ plus the heliocentric module, which has $\mathrm{EP}=\sum_pa_p/H$. So $C$ wins iff $\lambda<\sum_pa_p/H$.
* **$P_s$ against $P_f$**: $P_s$ wins iff $\lambda<1$ (facts used once, at exchange rate 1; Prop 5.3).
* **Conclusion.**
  * If $H<\sum_pa_p$, $C$ is the best system of the three exactly for $\lambda<\sum_pa_p/H$, and $P_f$ above.
  * If $H\ge\sum_pa_p$, $C$ is never strictly best: $P_s$ is best for $\lambda<1$ (tying $C$ if $H=\sum_pa_p$), and $P_f$ for $\lambda>1$.
  * In the marginal-likelihood account, the same $\sum_pa_p$ bits appear as Copernicus's extra likelihood against $P_f$. At $\lambda=1$ the totals agree, and a steeper prior penalises $P_s$, the version that states the coincidences.

**Relation to ILP compression [known: muggleton1995inverse; content: secondary (the author's Progol page: search "guided by compression", trading the description of errors against hypothesis length). Known: srinivasan1994justification; bibliographic data per scout L (chapter 4 of Machine Intelligence 13, 1994; pages not confirmed); content not seen].**
* At $\lambda=1$, adding a module lowers $J_1$ iff its EP exceeds $1$: positive compression. EP is the per-bit form, and the steeper objective asks for compression at rate $\lambda$.
* The coding of a logical theory together with its exceptions by compression has a precedent in ILP, in Srinivasan, Muggleton and Bain's justification of logical theories by data compression (scout L's seed 5; referee A, m21). Its content was not seen, so no closer comparison is claimed.

**Proposition 5.9 (laws and initial conditions in the question format) [proved; computed: l7 D; consistency condition added after `shape`'s final record §15.3].** Let the data be conditional questions "given the elements $\alpha_b$ of body $b$, is $\ell$ the case?". Such a datum is compatible with $T$ when $B\cup T\cup\{\alpha_b\}$ is **consistent** and proves $\ell$ (`shape`'s encoding (E3), NOTATION §3.2).
* Without the consistency condition the encoding is degenerate: a theory that refutes the antecedents proves every datum (`shape` Prop 1.8).
* In the toy, every theory of the family (the law, $K3$, elements modules stating the true elements) is consistent with every true antecedent. So the condition excludes nothing there, and the statement is unchanged from `notes.md`.

In the toy:
* an elements module $E_b$ with the same content as $\alpha_b$ adds nothing ($T\cup\{\alpha_b\}\cup E_b$ and $T\cup\{\alpha_b\}$ prove the same), so $\mathrm{EP}(E_b)=0$ and no $\lambda$-MAP contains elements;
* $\Lambda$ alone answers every question, with $\mathrm{EP}(\Lambda)=cN/L$ however the $N$ observations are spread over bodies.

*Proof.* Immediate from the definition of compatibility. ∎

So in the question format the laws/initial-conditions distinction is the distinction between theory and question antecedent. The laws answer conditional questions with no elements at all, while the Ramsey sentence of the laws answers no unconditioned position question (`philosophy` T4, scout P's Prop 2.1; not re-proved here).

---

## 6. Domains of applicability and retention of superseded theories (T6)

### 6.1 When a domain restriction pays

**Setting.**
* A law $\Lambda$ with per-system elements. For the systems in a set $G$, $\Lambda$ with their elements proves their data.
* For one further system $M$ (the Moon), $\Lambda$ with $M$'s elements ($k_M$ bits) has these per-datum rates, against the literal rate $\gamma$:
  * $m^M_P$, the exact law with exceptions patched (Prop 3.3);
  * $m^M_H$, an honest tolerance for $M$, at a one-off cost $h_M$.
* The **domain-restricted law** is $\Lambda_{\rm Dom}:=\forall b\,(\mathrm{Dom}(b)\to\text{law}(b))$, with $\mathrm{Dom}$ a definable predicate that $B$ proves of the systems in $G$ and refutes of $M$.
  * It costs $\|\mathrm{Dom}\|$ more than $\Lambda$: a few bits if "Planet" is a base predicate, about $\log(\#\text{systems})$ to name $M$.
  * It leaves $M$'s $n_M$ data literal.
* The three treatments of $M$'s data are X (restriction: rate $\gamma$, constant $\lambda\|\mathrm{Dom}\|$), P (rate $m^M_P$, constant $\lambda k_M$) and H (rate $m^M_H$, constant $\lambda(k_M+h_M)$).

**Proposition 6.1 (domain restriction) [proved; computed: l10 E; rb7 A; (b) restated after referee A, M4 and referee B, 5].**
* (a) $J_\lambda(\Lambda_{\rm Dom})-J_\lambda(\Lambda+E_M\text{ with }M\text{'s exceptions})=\lambda\|\mathrm{Dom}\|-\lambda k_M+\sum_{d\in D_M}\big(\gamma(d)-c_P(d)\big)$, and likewise against the honest treatment of $M$, with $\lambda(k_M+h_M)$ and $c_H$. (This is scout N2's C16 made exact: restriction pays iff the domain clause plus the literal cost of the excluded data is below the cost of $M$ under the law.)
* (b) As $n_M\to\infty$ with i.i.d. data, Theorem 3.8 applied to X, P and H gives three cases.
  * If one treatment has strictly the least rate, it is eventually the $\lambda$-MAP's treatment of $M$.
  * If the least rate is shared by two treatments whose per-datum cost difference is almost surely $0$, the constants decide forever. This is the case of X and H under code Q in the fine regime, where H is silent on every datum and costs exactly $\gamma$.
  * If it is shared by two treatments with a non-degenerate cost difference, there is no eventual winner.

  So the restriction is eventually selected iff $\gamma<\min(m^M_P,m^M_H)$, or $\gamma=m^M_H<m^M_P$ with H's cost almost surely $\gamma$ and $\|\mathrm{Dom}\|<k_M+h_M$.
* (c) *Code R (SAI's pricing).*
  * In the fine regime, $m^M_H\le\log(2\varepsilon^*_M/\Delta)+\log e<\gamma=\log(\mathsf R/\Delta)$ whenever $\varepsilon^*_M<\mathsf R/(2e)$, about $66.2°$ for a longitude (Lemma 3.6(ii); `notes.md`: $\mathsf R/(2e^2)\approx24°$, from its weaker bound: referee A, m4).
  * In the coarse regime, $m^M_H=s\beta_e\le s\log e<\gamma$ for $\Delta<\mathsf R/e$.
  * So for every system that the law confines to within about $66°$, a domain restriction never pays asymptotically: the system is kept with its own, wider tolerance. Band-confined completions (Prop 3.6a) only lower $M$'s rate further.

  *Code Q.* At $\Delta\le2\varepsilon^*_M$ the honest treatment costs exactly $\gamma$ per datum (the tie of (b)). So the restriction is eventually selected iff $m^M_P>\gamma$ and $\|\mathrm{Dom}\|<k_M+h_M$. (If $m^M_P=\gamma$, P's cost difference against X is non-degenerate and there is no eventual winner.)

*Proof.*
* (a) The two theories differ in the domain clause, in $M$'s elements, and in the treatment of $M$'s data. $G$'s data are proved by both.
* (b) Thm 3.8(i),(ii).
* (c) Lemma 3.6 and Lemma 3.2. $\log(2\varepsilon^*/\Delta)+\log e<\log(\mathsf R/\Delta)$ iff $2e\varepsilon^*<\mathsf R$. In the coarse regime $s\le1$ and $\log e<\log(\mathsf R/\Delta)$ iff $\Delta<\mathsf R/e$. ∎

`notes.md`'s (b) said "iff $\gamma<\min(m^M_P,m^M_H)$". That fails at the exact tie on which its own Moon example rests: there it predicted no restriction, while its part (c) and its table asserted exclusion, which is correct by the constants.

**Computed [l10 E, exact; agrees with rb7 A].** The Moon as $M$, with one fixed ellipse over one year: $\varepsilon^*_M=156.3'=2.6°$, $\Ex|e|=61.7'$ (mean fit), $k_M=60$, $h_M=20$, $\|\mathrm{Dom}\|=4$, $\pi_c=10.5$. Per-datum rates are in bits; "tie" means equal rates with an almost surely zero cost difference.

| $\Delta$ | $\gamma$ | code Q, $\lambda=1$ | code Q, $\lambda=2$ | code R, $\lambda=1,2$ |
|---|---|---|---|---|
| $10'$ | 11.08 | Moon excluded: H ties X ($11.077$), constants favour X ($4<80$); P $20.52$ | excluded (P $30.51$) | kept honestly: H $4.973$ |
| $60'$ | 8.49 | excluded: tie H–X at $8.492$; P $13.66$ | excluded (P $21.22$) | H $2.445$ |
| $300'$ | 6.17 | kept with exceptions: P $3.430$ (H ties X at $6.170$) | P $5.592$ | H $0.686$ |
| $600'$ | 5.17 | P $1.612$ against H $2.694$ | **P $2.6933$ against H $2.6939$** | H $0.343$ |
| $1800'$ | 3.58 | P $0.483$ against H $0.623$ | H $0.623$ against P $0.843$ | H $0.114$ |

* In code R, H overtakes exclusion after $\lambda\cdot76/(\gamma-m_H)$ Moon data in expectation: about 12 at $\lambda=1$ and 25 at $\lambda=2$, at $\Delta=10'$ and $60'$.
* The bold cell was "honest (rates within $0.001$)" in `notes.md`. That came from a Monte Carlo estimate of H's rate ($2.692$) in a cell of the coarse regime, where H's rate is exactly $s\gamma=2.6939$. P has both the lower rate and the smaller constant, so it wins from the start (referee B, 5).

**Reading [assessment].** Scout N2's illustration, "the Moon is excluded by a domain axiom", is a code-Q phenomenon at fine precision, decided by the constants at an exact tie. Under the pricing of SAI's randomised theories, the inducer does not cut the Moon out of Kepler's law. It keeps the Moon with a tolerance of a few degrees, and with an error model if band-confined completions are in the pool.
* A domain of applicability then shows up as *a tolerance (and an error distribution) that depends on the system and the window*, not as a sharp boundary.
* A sharp boundary is selected only when even an honest tolerance is worse than literal data. For longitudes, $66°$ is a *sufficient* bound for this not to happen; it is not the threshold at which it does (referee A, m4).

### 6.2 Retention of a superseded theory by usage cost

**Setting.**
* The honest Kepler law $K$ (tolerance $\varepsilon_K$ on a window) and an exact successor $N$, with derivation charges. A datum proved from $T$ costs $r_d\cdot dl_T(d)$ bits, where $dl_T(d)$ is the size of the derivation used.
* Write $c_K:=r_d\,dl_K$ and $c_N:=r_d\,dl_N$ per proved datum, with $c_K<c_N$.
* $J^{\rm der}_\lambda(T;D):=\lambda|T|+\mathrm{Exc}_D(T)+\sum_{d\text{ proved}}r_d\,dl_T(d)$.

**Proposition 6.2 (retention) [proved; computed: l10 F; rb7 B; (b), (c) completed after referee A, M4 and m5].**
* (a) For finite $n$: $K$ beats $N$ iff $\lambda(|N|-|K|)+\sum_d\big(c_N-c_K\big)[d\text{ proved by }K]+c_N\cdot\#\{d\text{ not proved by }K\}>\mathrm{Exc}_D(K)$. That is, derivation savings plus the length difference against the lost fit (scout N2's C17, made exact).
* (b) With i.i.d. data, the rates are $m_K=s_K\gamma_{\rm si}+(1-s_K)c_K$ and $m_N=c_N$.
  * If $m_K<m_N$ (resp. $>$), then almost surely $K$ (resp. $N$) is eventually the $\lambda$-MAP among $\{K,N\}$, whatever $\lambda$ and the lengths are (Thm 3.8(i)).
  * At $m_K=m_N$ with an almost surely constant cost difference (code Q with $s_K=1$ and $\gamma=c_N$), the lengths decide. Otherwise there is no eventual winner (Thm 3.8(ii)).
* (c) *Monotonicity.* Let $s_K=\min(2\varepsilon_K/\Delta,1)$.
  * *Code Q.* $m_K=c_K+s_K(\gamma(\Delta)-c_K)$ is non-increasing in $\Delta$ on $\{\Delta:\gamma(\Delta)\ge c_K\}=(0,\mathsf R2^{-c_K}]$.
  * *Code R.* $m_K$ is non-increasing in $\Delta$ on $(0,\infty)$ if $\beta_e\ge c_K$.
  * In either case the set of cell widths in that range at which $K$ is retained is an interval $[\Delta^*,\cdot)$.
  * In the coarse regime under code Q, $\Delta^*$ solves $2\varepsilon_K(\gamma(\Delta)-c_K)/\Delta=c_N-c_K$, i.e. $\Delta^*\approx2\varepsilon_K\gamma/(c_N-c_K)$.

*Proof.*
* (a) Compare the two objectives term by term.
* (b) Thm 3.8 with the costs of Prop 3.3 plus the derivation charges.
* (c) *Code Q.* In the coarse regime, $s_K$ and $\gamma(\Delta)-c_K\ge0$ are both non-increasing and non-negative, so their product is too. In the fine regime, $m_K=\gamma(\Delta)$, which is decreasing.
  * *Code R.* In the fine regime $K$ is silent on every datum and $m_K=\Ex C_\Delta(w)$, strictly decreasing by Lemma 3.6(iii). In the coarse regime $m_K=c_K+s_K(\beta_e-c_K)$, non-increasing when $\beta_e\ge c_K$. The two agree at $\Delta=2\varepsilon_K$.
  * (`notes.md` asserted the code-R monotonicity without proof: referee A, m5.) ∎

**Computed [l10 F: exact code-R costs, bisection; rb7 B].** The derivation sizes are *assumed*, not measured: $dl_N/dl_K=1000$, as for a validated integration against solving Kepler's equation. The table gives the least cell width $\Delta^*$ at which Kepler is retained, for $c_N=0.01$, $0.1$ and $1$ bits per datum:

| body, window | $\varepsilon^*$ | code Q | code R |
|---|---|---|---|
| Mercury, 100 yr | $2.02'$ | $1542'$, $258.5'$, $37.2'$ | $229.8'$, $22.97'$, $2.33'$ |
| Mars, 12 yr | $1.44'$ | $1202'$, $195.6'$, $27.7'$ | $174.2'$, $17.42'$, $1.744'$ |
| Mars, 2000 yr | $49.9'$ | $10450'$, $2895'$, $533'$ | $5717'$, $572'$, $57.8'$ |
| Jupiter, 100 yr | $6.57'$ | $3468'$, $661'$, $101.6'$ | $867'$, $86.7'$, $8.61'$ |
| Saturn, 2000 yr | $81.9'$ | never, $3994'$, $784'$ | $10320'$, $1032'$, $102.9'$ |
| Moon, 1 month | $30.9'$ | $8414'$, $2086'$, $364'$ | $4473'$, $447'$, $44.4'$ |

* `notes.md`'s code-R column at $c_N=1$ ($4.13'$, $2.92'$, $102'$, $13.5'$, $166'$, $62.4'$) priced fine-regime silence by the upper bound $\log(2\varepsilon^*/\Delta)+2\log e$, which never falls below $1$ bit. So its entries landed just above $2\varepsilon^*$ (referee B, 4). The exact values agree with referee B's (Mars over 12 years $1.744'$, the Moon over a month $44.4'$).
* The other entries agree with `notes.md` to its 400-point grid.
* The code-R cost of $K$ never increases with $\Delta$ on a 300-point grid for three series (`l10` F; `rb7`: 120-point grid).

**Reading [assessment].** A superseded theory's domain of applicability is where its derivation savings exceed its fit loss: coarse enough data, short enough windows, and expensive enough derivations from the successor. This is how practice treats Newtonian mechanics after relativity, and Kepler's ellipses after Newton.
* Under random-completion pricing the retention region reaches 1.8–16 times finer precision than under literal pricing: $1.8$–$6.9\times$ at $c_N=0.01$, $3.9$–$11\times$ at $0.1$, and $7.6$–$16\times$ at $1$. The reason is that the honest law's silence is cheap. (`notes.md` said "about ten times".)

---

## 7. Explanation by approximate correction: a provable toy (T7)

**Setting.**
* Language: $\mathrm{RCF}$ plus constants $x_{t,1},x_{t,2}$ for $t\le W$, a planar state per time step.
* $R$ is the rotation with $\cos=3/5$, $\sin=4/5$; $P$ is a rational $2\times2$ matrix; $\eta=1/100$; $A:=R+\eta P$; $a=(1,0)$.
* $|\cdot|$ is the Euclidean norm. Inequalities $|v|\le\varepsilon$ are stated as $|v|^2\le\varepsilon^2$, with rational $\varepsilon^2$.
* The **old exact law** with its initial condition: $T_0^W:=\{x_t=R^ta:t\le W\}$ (uniform circular motion).
* The **successor**: $T_N^W:=\{x_0=a\}\cup\{x_{t+1}=Ax_t:t<W\}$.
* The **honest old law on the window**: $H^\varepsilon_W:=\{|x_t-R^ta|\le\varepsilon:t\le W\}$.
* Its **time-dependent form**: $H^{(\varepsilon_\cdot)}_W:=\{|x_t-R^ta|\le\varepsilon_t:t\le W\}$ for rational $\varepsilon_t^2$.

**Proposition 7.1 (the successor derives the honest law and refutes the exact one) [proved; computed: l9, l10 I; rb6, ra1 F].**
* (a) $T_N^W\vdash H^{\varepsilon}_W$ for every rational $\varepsilon\ge\varepsilon(W):=((1+\eta\|P\|)^W-1)|a|$, where $\|P\|$ is the operator norm.
* (b) $T_N^W\vdash H^\varepsilon_W$ iff $\varepsilon^2\ge\varepsilon_{\min}(W)^2:=\max_{t\le W}|A^ta-R^ta|^2$, a rational number. So $\varepsilon_{\min}(W)\le\varepsilon(W)$, and $H^{\varepsilon_{\min}(W)}_W$ is the strongest *uniform-tolerance* form of the old law on the window that the successor proves.
* (c) If $\eta Pa\ne0$, then $T_N^W\vdash\neg T_0^W$ (already $x_1=Aa\ne Ra$).
* (d) Among uniform-tolerance forms, $H^\varepsilon_W$ is a common consequence of $T_0^W$ and $T_N^W$ iff $\varepsilon\ge\varepsilon_{\min}(W)$. The strongest common one is $H^{\varepsilon_{\min}(W)}_W$.
* (d′) *(added after referees A, M2 and B, 2.)* The time-dependent form with $\varepsilon_t:=|A^ta-R^ta|$ is a common consequence of both theories. It is strictly stronger than $H^{\varepsilon_{\min}(W)}_W$ whenever $\varepsilon_t<\varepsilon_{\min}(W)$ for some $t$.
* (d″) The strongest common consequence of the two finite theories is their disjunction $\bigwedge T_0^W\vee\bigwedge T_N^W$, which is not a tolerance law, and $H^{\varepsilon_{\min}(W)}_W$ does not entail it.
* (e) The derivations exist. The natural one (instantiate the recurrence $t$ times, write each $x_t$ as an exact rational vector, verify $W+1$ numerical inequalities) writes numerals of total bit size $\sum_{t\le W}\mathrm{bits}(A^ta)=O(W^2\log h)$, $h$ the height of the entries of $A$. [Proved for the numerals. That derivations of binary numeral arithmetic from the field axioms have polynomial size is standard and not written out: proof sketch.]

*Proof.*
* (a) Since $\|R\|=1$ and $\|A\|\le1+\eta\|P\|$, $\delta_t:=|A^ta-R^ta|$ satisfies $\delta_{t+1}=|A(A^ta-R^ta)+\eta PR^ta|\le(1+\eta\|P\|)\delta_t+\eta\|P\||a|$, with $\delta_0=0$. So $\delta_t\le((1+\eta\|P\|)^t-1)|a|$, and $T_N^W$ proves $x_t=A^ta$ (below).
* (b) In every model of $B\cup T_N^W$ (any real closed field), the recurrence determines $x_t=A^ta$, a rational vector, since $\mathbb Q$ embeds uniquely into every ordered field. So each conjunct of $H^\varepsilon_W$ is equivalent over $B\cup T_N^W$ to a fixed inequality between rationals, which $\mathrm{RCF}$ proves or refutes. By completeness, $T_N^W\vdash H^\varepsilon_W$ iff all $W+1$ inequalities hold.
* (c) $T_N^W\vdash x_1=Aa$ and $T_0^W\vdash x_1=Ra$, with $Aa-Ra=\eta Pa\ne0$.
* (d) $T_0^W$ proves $x_t=R^ta$, hence $H^\varepsilon_W$ for every $\varepsilon\ge0$; combine with (b).
* (d′) $T_N^W$ proves $|x_t-R^ta|^2=\varepsilon_t^2$, and $T_0^W$ proves $|x_t-R^ta|^2=0\le\varepsilon_t^2$. For strictness, a real point $x_t$ with $\varepsilon_t<|x_t-R^ta|\le\varepsilon_{\min}(W)$ at one $t$ gives a model of $H^{\varepsilon_{\min}}_W$ that violates the time-dependent form.
* (d″) For finite theories, $\varphi$ follows from both iff it follows from their disjunction (proof by cases). The model $x_t=R^ta+(10^{-4},0)$ for all $t\le W$ satisfies $H^{\varepsilon_{\min}(W)}_W$ when $\varepsilon_{\min}(W)\ge10^{-4}$, and it is a model of neither theory.
* (e) The numerals are those of $A^ta$, and their sizes are computed. ∎

**Computed [l9; reproduced digit for digit by rb6]** (exact rational arithmetic), for three perturbations with $\|P\|=1$:

| $P$ | $\varepsilon_{\min}(W)$ for $W=1,10,100,200$ | bound $\varepsilon(W)$ | refitted circle, $W=10,100$ | numeral bits, $W=10,100$ |
|---|---|---|---|---|
| $JR$ (outward spiral and precession) | $0.0100,\ 0.0999,\ 0.961,\ 1.69$ | $0.0100,\ 0.105,\ 1.70,\ 6.32$ | $2.5\times10^{-4},\ 2.5\times10^{-3}$ | $1894,\ 1.8\times10^5$ |
| $SR$, $S=\mathrm{diag}(1,-1)$ (distortion) | $0.0100,\ 0.0127,\ 0.0186,\ 0.0243$ | same | $8.9\times10^{-3},\ 1.0\times10^{-2}$ | $1430,\ 1.3\times10^5$ |
| $I$ (spiral) | $0.0100,\ 0.103,\ 1.33,\ 3.49$ | same | $3.7\times10^{-2},\ 0.80$ | $1322,\ 1.3\times10^5$ |

* In each case $T_N$ refutes $T_0$ at $t=1$.
* The general bound is nearly tight for small windows when the perturbation accumulates ($JR$, $I$), and very loose for a bounded distortion ($SR$: ratio $0.004$ at $W=200$).
* The refitted circle (radius and angular speed fitted on the window, in floating point, for comparison only) absorbs the precession almost entirely in the first case, and the growth not at all in the third. This is the toy analogue of the fitted ellipses of §3.6.
* [l10 I] For $P=JR$:
  * the time-dependent tolerances have $\varepsilon_1=0.0100$, mean $0.0500$ at $W=10$ and $0.490$ at $W=100$; $\varepsilon_{\min}$ is about twice their mean;
  * the rational point $x_1=Ra+(\varepsilon_{\min}/2,0)$ satisfies $H^{\varepsilon_{\min}}_W$ at $t=1$ and violates the time-dependent bound there;
  * the model $x_t=R^ta+(10^{-4},0)$ satisfies $H^{\varepsilon_{\min}}_{10}$ and is the trajectory of neither theory (`ra1` F gives a $W=1$ model of the same kind).

**Reading [assessment; corrected after referees A, M2 and B, 2].**
* The successor does not entail the old law; it contradicts its exact form (c). This is Duhem's observation about Newton and Kepler [known: duhem1954aim; content: secondary, via `philosophy`'s refs.bib].
* What it derives is an honest form of the old law on a window, with a tolerance that the successor itself determines and that grows with the window. The old law's domain of applicability is derived, not stipulated.
* The precise sense is (b)/(d). Among statements of the form "within $\varepsilon$ of the old law's prediction at every $t\le W$", $H^{\varepsilon_{\min}(W)}_W$ is the strongest the successor proves, and the strongest the two theories share.
  * It is *not* "exactly what the two theories have in common". Time-dependent tolerances are stronger common consequences (d′), the full common content is the disjunction of the two theories (d″), and the successor proves far more ($x_t=A^ta$). `notes.md`'s wording "exactly what the old and the new theory have in common" is withdrawn (§10, item 10).
* Read correctly, the toy shows Schaffner's picture of reduction to a corrected reduced theory [known: schaffner1967approaches; content: abstract and secondary, via `philosophy`], in a case where the corrected theory is an honest law with a derived tolerance.
* In SAI terms (Prop 2.1): every datum proved by $H^\varepsilon_W$ with $\varepsilon\ge\varepsilon_{\min}(W)$ is proved by $T_N^W$. True data (the toy's truth is $T_N$) that refute $T_0^W$ refute neither $T_N^W$ nor $H^\varepsilon_W$. So the honest form of an approximate law is humble (§3.5) and is explained by its successor; the exact form is neither.
* Scope: the toy is linear and discrete. It does not touch the real difficulty of deriving "Kepler within $\varepsilon$ on $W$" from Newton (existence theorems and validated integration; scout P §2.5–2.6), which is the textbook point of `shape`.

---

## 8. Learning a domain of applicability (T8, extension: partial)

T8 asks whether the posterior over theories "$\mathrm{Dom}(x)\to\text{law}(x)$" on a hand-picked pool finds "planet $\wedge$ window" and excludes the Moon. §§3.6 and 6.1 settle the following.
* **Under SAI's pricing, a sharp domain is not what is learned [computed: l5, l10 C, E].** For every planet and window, and for the Moon over a month, a year and 18.6 years, a law with its own tolerance has a lower rate than leaving the body's data literal (Prop 6.1(c): this holds for any band narrower than about $66°$). With band-confined completions the rate is lower still (Prop 3.6a). So the inducer keeps every body under the law and learns *a tolerance and an error distribution per body and window* ($\varepsilon^*$ from $0.17'$ to $82'$ for the planets, $31'$ to $8°$ for the Moon; §3.6), not a domain that excludes the Moon.
* **Under literal pricing (code Q) at fine precision, the Moon is excluded** (Prop 6.1(b),(c); `l10` E at $\Delta=10'$, $60'$). There the honest treatment ties the literal one exactly, and the domain clause ($\|\mathrm{Dom}\|=4$ bits) is cheaper than the Moon's elements and tolerance ($80$ bits).
* **A window as a domain.** Restricting a law to $|t|<W$ pays, by the same comparison, only when the data outside the window are better left literal than given a wider tolerance. Under code R this again needs a band wider than about $66°$, which for the planets happens only over many millennia: Mars's error grows from $1.4'$ over 12 years to $50'$ over 2000 years. [assessment from the computed growth; a pool over windows was not computed.]

**Open.** A posterior computation over an explicit pool of domain predicates (base predicates, windows, their conjunctions) with stated syntax costs, as scout P's Q8 proposes. Given the above, the expected answer depends on the pricing: tolerances with error models under SAI's pricing, and sharp domains under literal pricing at fine precision.

---

## 9. What this shows, and what is known

### 9.1 What this shows (for the paper; the philosophical assessment is `philosophy`'s)

* **"Kepler's laws give only approximately correct predictions" is a limitation of proof-requiring compatibility with deterministic theories, not of the axiom view as such.**
  * Over deterministic theories, data never move the odds towards a hedge (Prop 2.1). Exact but false laws survive only against guaranteed tolerances (Prop 2.4), and rounded data refute them at any precision (Prop 2.5).
  * SAI's one-tape law mixes randomised theories (Prop 1.8). These price silence relative to the question and keep an approximate law alive after its exact form is refuted. SAI is itself the best two-part code over such theories (Prop 1.9(a)).
  * On data from a law with i.i.d. errors, SAI's asymptotic rate is that of *the law together with its error distribution*, and no theory machine does better (Prop 3.6a(c)).
  * On the real Kepler residuals, among Kepler-based machines, the law with a fitted error histogram beats both the uniform honest band and the exact law with exceptions, for every body, window and precision computed (§3.6).
* **Honest law, law with exceptions, or law with an error model.**
  * *Over deterministic theories (code Q).* The choice between the honest law and the exact law with exceptions is decided by the error's peakedness against the ratio of the price of an exception to the price of silence (Prop 3.4). The optimum of the whole family is a tolerance with a stated share $\theta_{\rm ex}$ of exceptions (Prop 3.5). Deterministic patches with a fixed naming cost are a finite-horizon model (Prop 3.3a).
  * *Under SAI's pricing.* The comparison moves inside the band. The uniform band is the best completion only for uniform errors, and the two-point form "exact, except in a share $\rho$, then within $\varepsilon$" beats it iff $\Ex\ln(1+|e|/\varepsilon)<2\ln2-1$, i.e. only if the peakedness exceeds $1.79$, and whenever it exceeds $2.12$ (Prop 3.6a).
  * Selection is almost sure, with explicit switch points, under integrable costs (Thm 3.8, Cor 3.9).
* **Precision.** The seed "the simpler approximate theory is preferred until the data's precision exceeds its error" holds for guaranteed tolerances. For rounded data the relevant quantity is the number of data times the error over the precision (§2.3).
* **Humility.** A deterministic honest law is a partial theory, and its silence is the "independent" value. For the randomised theories that SAI mixes, humility is calibration of an error distribution (Props 3.10, 3.6a).
* **Domains of applicability.**
  * A sound formal criterion for reasoning with approximate models exists, given a background that decides the comparisons (Prop 4.3).
  * Approximate dynamical laws have derivation horizons, exact for linear dynamics (Props 4.1, 4.2).
  * Under SAI's pricing, domains appear as tolerances and error distributions per system and window rather than as sharp boundaries: no sharp domain is learned for a band narrower than about $66°$ of longitude (Prop 6.1).
  * A superseded theory is retained where its derivation savings exceed its fit loss (Prop 6.2).
* **Best systems.**
  * Lewis's account has an exact form as a steeper MAP over laws with private literal facts. Over the class of all theory machines it collapses (Prop 1.9(d)).
  * "Kind nature" is a kink of the data's hull (Prop 5.6). The trivialisation is blocked by the coding bound, up to the complexity of a language chosen after the data (Prop 5.7).
  * The model–randomness split separates reused facts from facts used once, not laws from initial conditions. Laws are singled out by how their explanatory power scales with the number of systems.
  * $K3$ is a law about initial conditions, and it is preferred to the law without it at exchange rate $1$ (Prop 5.5).
  * In the question format, initial conditions are question antecedents (Prop 5.9).
* **Explanation.**
  * Explanatory power is per-bit support in the two-part code. Myrvold's unification term is the information carried by shared unknown parameters (Prop 5.8).
  * A successor theory derives an honest form of an approximate law, with a derived, window-dependent tolerance, and refutes its exact form. Among uniform-tolerance forms, the derived one is the strongest that the two theories share (Prop 7.1); the whole common content is larger.

**What it does not show.**
* The language, the question families and the costs (lengths $\ell_0$, $h$, $\pi_c$, $k$) are model inputs, and the derivation sizes of §6.2 are assumed.
* The real-residual analysis uses one-dimensional longitudes, dithered cells, one fixed ellipse per window, and a sample maximum for the tolerance.
* The band-confined pool of Prop 3.6a is still not all of $M_A$. The real residuals are deterministic, so a better theory eventually wins outright.
* §7 is a linear discrete toy and does not derive "Kepler within $\varepsilon$" from Newton.
* T8's posterior over domain predicates was not computed.

### 9.2 Relation to known work

* **Precision-dependent selection** is known in other forms: Akaike-based accounts of simplicity and unification [known: forster1994how; content: abstract], and MDL and MML, where the measurement precision of the data enters the code length [known: rissanen1978modeling, wallace2005statistical, grunwald2007minimum; content: abstract/secondary]. What is specific here is the 0/1 proof-requiring compatibility of axiom inducers, its two regimes (Props 2.4–2.6), and the honest/exception dichotomy with its peakedness criteria (Props 3.4, 3.6a(d)). Neither scout L nor our searches found these stated.
* **The tolerance quantile** of Prop 3.5 is the quantile-loss fact, in the form of $\nu$-support-vector regression [known: scholkopf2000new; secondary].
* **Law plus error model.** That the best two-part code includes the true error distribution (Prop 3.6a(b),(c)) is Gibbs' inequality and Barron-type almost-sure lower bounds. It is the standard MDL situation in which a "model" includes its noise distribution [known in substance: rissanen1978modeling, grunwald2007minimum; content at abstract/secondary level]. What is specific is its reading for axiom inducers: the uniform honest band is one completion among many.
* **Two-part codes with exceptions, and compression-guided theory search,** are MDL [as above] and inductive logic programming [known: muggleton1995inverse; content: secondary; srinivasan1994justification; content not seen]. EP $>\lambda$ is positive compression at rate $\lambda$ (§5.3).
* **The model/noise split** is algorithmic statistics [known: gacs2001algorithmic, vereshchagin2004kolmogorov; content: abstract]. P2's kink results, on which §5 rests, build on it.
* **Theory plus initial conditions in raw-data prediction:** a complete theory as an objective theory plus the observer's location [known: hutter2010complete; content: abstract]. In the question format of §5.3 that location is a question antecedent.
* **Best systems:** Lewis [known: lewis1983new, lewis1994humean; content: secondary], the language-relative version [known: cohen2009better; content: secondary], worries about the balance [known: woodward2014simplicity; content: abstract].
* **Unification:** Friedman, Kitcher [known: friedman1974explanation, kitcher1981explanatory; content: secondary/abstract], Myrvold (§5.3).
* **Approximation and truthlikeness.** Our notion of approximate truth is local (a question family, a tolerance, a window). It avoids a global comparison of false theories, which Popper's definition could not supply [known: popper1963conjectures, miller1974popper, tichy1974popper; content: secondary], and which the similarity approach supplies only relative to a metric [known: niiniluoto1987truthlikeness; content: secondary].
  * Structuralist accounts make approximation a feature of a theory's application [known: moulines1976approximate; content: abstract of a companion paper]. Our honest laws are a first-order, per-question analogue; the relation was not checked against the text.
  * Rules that hold with high probability and tolerate counterexamples [known: valiant2000robust, juba2013implicit; content: secondary/abstract] are the analogue of the law with random exceptions.
* **Reduction and correction:** Duhem, Schaffner (§7).

---

## 10. Refuted and qualified claims (kept with their counterexamples)

Items 1–7 are from `notes.md`, updated. Items 8–19 are withdrawn or corrected in this revision.

1. **[refuted] Scout N2's stated $K3$ criterion** (Prop 4.5 there): "$K3$ is in the $\lambda$-MAP iff $s|S(\lambda)|>\lambda L_3$" when $S$ is the same under both choices.
   * *Counterexample* (`l7` A): 15 bodies with 1000 observations, $L=300$, $L_3=150$, $k=60$, $s=15$, $c=12.4$, $\lambda=2$. $K3$ enters ($2250<2400$), though $s|S|=225<\lambda L_3=300$.
   * *Correct statement:* $J^*_{\Lambda+K3}<J^*_\Lambda$ iff $s|S|>L_3$ (Prop 5.5(b)). N2's tables used brute force and stand.
2. **[pricing-dependent; the R/rand half of `notes.md`'s item withdrawn] "Spread-out errors favour honest approximate laws; concentrated errors favour exact laws with exceptions"** (scout N2 §3.2).
   * It holds under deterministic patches (Q/det, as a cost model), as N2's criterion says.
   * Under Q/rand it fails for spread errors: the sinusoid ($\mathrm{pk}=\pi/2$) is held as exact with exceptions at $\Delta=3'$–$60'$ (`l3` G).
   * `notes.md` also claimed that under R/rand the peaked error ($\mathrm{pk}=20$) is held honestly. That was true only within a pool lacking completions inside the band. With $\mathrm{HY}(\rho)$ in the pool, the peaked error is held as "exact except in about 10% of cases", at per-straddle cost $0.179$ against H's $0.492$ (`l10` B, `rb2`; Prop 3.6a(d)). So under SAI's pricing N2's reading survives in the HY form, with peakedness thresholds $1.79$ (necessary) and $2.12$ (sufficient).
3. **[qualified] "A steeper prior favours honesty"** (scout N2 §3.2). It is true when exceptions are named in the law part (det). With randomised exceptions the flags are fit, and $\lambda$ drops out of the comparison of rates.
4. **[qualified] "The Moon is excluded by a domain axiom"** (scout N2 C16). True under code Q at fine precision, decided by the constants at an exact tie (Prop 6.1(b); `l10` E). Under SAI's pricing the Moon is kept with a tolerance of a few degrees (Prop 6.1(c)).
5. **[corrected, minor]** Scout N2's typical deviation after 100 random-sign steps, $7.8\varepsilon$ (simulated), is exactly $7.96\varepsilon$ (Remark 4.4).
6. **[qualified] Scout P's Prop 2.3** ("proof-requiring SAI prefers a false exact law to its true tolerance-weakened version on every data set"). It is proved for deterministic hypotheses (Cor 2.2). Within $M_A$, randomised theories built on the law keep positive weight after the exact law is refuted. On Kepler's residuals they beat the exact law with exceptions, and the best of them is a law with a calibrated error model, not the uniform honest band (§3.6).
7. **[corrections of the brief's seeds, not of the author]** Precision-dependent selection (§2.3); laws versus initial conditions (§5.2).
8. **[refuted] `notes.md` §0, §3.6, §8, §9.1: "under SAI's pricing the inducer holds Kepler's law honestly (uniform band) at every precision".**
   * *Counterexample* (`l10` C, `rb2`): SH has a lower rate than H in 429/429 (body, window, precision) cells, and HY in 34/39 pairs in the coarse regime.
   * The statement is true within the pool $\{0,P,H\}$ (and `l5`'s tolerance family with whole-circle exceptions) only.
9. **[refuted] `notes.md` Prop 3.4, R/rand: "honesty wins unless the error is very peaked (threshold roughly 5–30)".** The threshold came from an incomplete pool. *Counterexample:* item 2's peaked error. The correct criterion is Prop 3.6a(d).
10. **[refuted] `notes.md` §0, §7, §9.1, §13: "the honest form is exactly what the old and the new theory have in common".**
    * *Counterexamples* (`l10` I, `ra1` F, `rb6`): a model of $H^{\varepsilon_{\min}}_W$ that is a model of neither theory, and a rational point satisfying $H^{\varepsilon_{\min}}_W$ but violating the stronger common time-dependent tolerance law.
    * *Correct statement:* the strongest common *uniform-tolerance* form (Prop 7.1(d)–(d″)).
11. **[corrected] `notes.md` Prop 5.5(b) read as "K3 is in the $\lambda$-MAP iff $s|S|>L_3$".**
    * *Counterexample:* two bodies, one observation each, $c=10$, $L=1000$, $k=5$, $s=4$, $L_3=1$, $\lambda=1$: the empty theory wins ($20<1003<1010$).
    * *Correct statement:* the comparison of law choices (Prop 5.5(b)).
12. **[corrected] `notes.md` Prop 4.1(c) and Prop 4.2, "iff" for every Lipschitz $F$.**
    * *Counterexample* (`rb5` C): $F=0$ on $[-1,1]$, $2(x-\operatorname{sign}x)$ outside. Only "if" holds in general; "iff" holds for linear $F$ in $d=1$.
13. **[corrected] `notes.md` Prop 4.3(b),(c) for any true background.**
    * *Counterexample:* $B=\emptyset$, $f_i(t)$ and $f_j(t)$ distinct constant symbols.
    * *Correct statement:* $B$ must decide the comparisons.
14. **[corrected] `notes.md` Prop 6.1(b) and Prop 6.2(b) at exact ties.** Their own Moon example is a tie with an almost surely constant difference, which the constants decide. The three cases of Thm 3.8 are now stated.
15. **[corrected] Constants and hypotheses.**
    * Lemma 3.2's coarse-regime condition ($\Delta\ge\varepsilon+\max(\varepsilon,\varepsilon^*)$; *counterexample:* $|e|=1$, $\varepsilon=2$, $\Delta=3$ gives probability $4/3$).
    * Lemma 3.6's fine bound ($2\log e\to\log e$), and with it $24°\to66°$ in Props 3.7 and 6.1(c).
    * Thm 3.8's boundedness hypothesis, which code-R costs violate. It is replaced by integrability (i), finite variance (ii), and integrability or boundedness (iii).
16. **[corrected] Numbers.**
    * `l8` A's cell $\Delta=600'$, $\lambda=2$, code Q (honest → exceptions).
    * `l8` B's code-R column at $c_N=1$ (upper-bound artifacts; e.g. Mars over 12 years $2.92'\to1.744'$, the Moon over a month $62.4'\to44.4'$).
    * "Peakedness 1.9–4.0" was a cross-fit ratio; per fit it is 1.60–3.95 and 1.89–7.08.
    * $\pi_c$ ranges over 6.8–21.5 bits, not 14–22.
    * The $1/p$ values are $94.25$, $942.48$ and $12000$ exactly.
    * "About ten times finer" is $1.8$–$16$ times.
17. **[withdrawn; open] `notes.md` Prop 1.9(c) for $J^R_1$ over pointwise interval laws.** It was unproved, and the example suggested in review fails because presentations can store values (Remark 1.9a).
18. **[withdrawn] "Lewis's account has an exact form ... and only there"** (`notes.md` §1.4 reading, §9.1). Prop 1.9(d) shows that one class collapses, not that every other class fails.
19. **[corrected] `notes.md` Setting S3: "times i.i.d. from an atomless law".** Impossible for numerals. Replaced by fresh times with i.i.d. errors. The det pricings with constant $\pi_c$ became a finite-horizon cost model (Prop 3.3a), and repeated times were shown to change costs (Remark 3.3b).

---

## 11. Notation requests

* **$\pi_c$** (cost of naming a time) clashes with P2's program letter $\pi$; it is local here. If the paper needs it globally, use $\varpi$ or $c_{\rm time}$.
* **The silence probability** is renamed $s_\Delta$ here (`notes.md`'s $q_\Delta$ clashed with the quantity $q(t)$). In §5, $s$ is $K3$'s saving per body; the two uses are in different sections.
* **Local symbols:** $p_\Delta$, $\gamma_{\rm ex}$, $\gamma_{\rm si}$, $\beta_e$, $\theta_{\rm ex}$, $\rho$ (exception share), $\phi$ and $C_\Delta(w)$ (Lemma 3.6), $\mathrm{pk}_\varepsilon$, $c_G$, $r_F(\Delta)$. If Props 3.4 and 3.6a go into the paper, $\gamma_{\rm ex}$, $\gamma_{\rm si}$, $\beta_e$ and $c_G$ should be added to NOTATION §6.4.
* **Peakedness.** NOTATION §6.4 defines $\mathrm{pk}(e)$ for one error function. Every reported value must name its fit (minimax or mean). $\mathrm{pk}_\varepsilon$ uses a band's $\varepsilon$ in place of $\sup|e|$.
* **Exception codes.** Request the superscripts $\mathrm{Exc}^Q$, $\mathrm{Exc}^F$, $\mathrm{Exc}^R$ in NOTATION §6.4 (the draft defines only "the literal cost"). $P^R_T$ (the random-completion law) and $\mathrm{BC}_G$, $\mathrm{HY}(\rho)$, $\mathrm{SH}$ are local.
* **Module length.** $\mathrm{EP}_D(\mathcal A;T)$ divides by $\|\mathcal A\|=\sum_{\chi\in\mathcal A}\ell(\chi)$, which NOTATION writes $|\mathcal A|$; the difference is the theory code's stop bit.
* **Letters for forms.** The letter H for the honest form clashes with $H_2$ (entropy) and with P2's classes $\mathcal H$. In the paper, write $T^{\varepsilon^*}$ as NOTATION does, and $\mathrm{BC}_G$ for completions.
* **§7** uses $R$ for a rotation, which NOTATION reserves for the predicate of literal data; it is local to §7.
* **Data.** This record now writes $D^\pm$ (NOTATION §3.2, `fundamentals` Def 1.1) for the answers of an answered data set; `notes.md` wrote $D^\sharp$.
* **Conditional questions.** This record supports `shape`'s request that NOTATION §3.2 fix the encoding (E3): consistency of $B\cup T\cup\{\alpha\}$ plus derivation of $\ell$ (Prop 5.9).

---

## 12. References and their verification status

All keys are in `refs.bib` (this folder), now 30 entries. Each has a comment saying what was confirmed and at what level (source, abstract or secondary).
* **Copied from `../philosophy/refs.bib`:** seventeen entries, re-verified there by WebSearch on 2026-10-16.
* **Searched by this thread on 2026-10-16** (development round): eleven entries. Rissanen 1978, Wallace 2005, Grünwald 2007, Gács–Tromp–Vitányi 2001, Vereshchagin–Vitányi 2004, Hutter 2010, Muggleton 1995, Helly 1923, Tarski 1951, Church 1936, Durrett 2019. Myrvold and Lewis were also searched here for content.
* **Added in this revision:**
  * `scholkopf2000new` (Schölkopf, Smola, Williamson, Bartlett, "New Support Vector Algorithms", *Neural Computation* 12(5):1207–1245, 2000). Bibliographic data verified by referee A's WebSearch (MIT Press and MPI pages). The $\nu$-property was seen only in secondary sources (scikit-learn's NuSVR documentation; arXiv 2403.01769).
  * `srinivasan1994justification`, copied from scout L's `refs.bib`: chapter 4 of *Machine Intelligence 13* (Clarendon Press, 1994), pages not confirmed, content not seen.
* **Not re-searched in this run.** The WebSearch budget of this run was exhausted (a shared limit) before this thread's searches, so neither added entry was re-searched here, and Koenker and Bassett's regression quantiles is not cited: the quantile fact is proved in Prop 3.5.
* **Not seen in full text.** Direct fetches of publisher pages failed in the development round (DNS errors, proxy 403), so no full text was seen. In particular:
  * Myrvold's exact formula was not seen (content from abstracts and summaries of his paper and its critics);
  * Lewis's "kind nature" sentence was seen only in a citing source;
  * the section numbers of the standard probability results in Durrett were not checked.

Standard results used without a specific page: Tarski's decidability of real closed fields, Church's theorem, Helly's theorem, the strong law of large numbers (also for non-negative variables with infinite mean), the central limit theorem, the Hewitt–Savage 0–1 law, Wald's identity, finiteness of $\Ex\tau$ for random walks with positive drift, the Kraft inequality, and Gibbs' and Jensen's inequalities [known; standard: tarski1951decision, church1936note, helly1923mengen, durrett2019probability].

---

## 13. Status of every claim

| item | claim | status |
|---|---|---|
| Prop 1.4 | laws plus listed exceptions are deterministic hypotheses; $K_A\le|T|+\mathrm{Exc}^F+c$ | proved |
| Lemma 1.6 | provability, refutation and consistency of interval data from pointwise interval laws are decidable | proved |
| Prop 1.8 | randomised theories pay question-relative costs: $L_A\le K(T)+\mathrm{Exc}^R+c$; code Q with one question per time | proved |
| Prop 1.9 | $L_A=\min_G[K(G)-\log\nu_G]\pm c$; restricted minima are upper bounds; $K_A$ and $J^Q_1$ (hence $J^F_1$) not within $O(1)$; steeper selection over all theory machines collapses ($\kappa_0=0$) | proved, given `fundamentals` Thm 4.1, Prop 1.8(d), Thm 6.2 and P2 `prop:kink:universal` |
| Remark 1.9a | $J^R_1$: both $L_A$ and $\min J^R_1$ are $\ge K(y_D\mid\dom D)-c$; the separation is open | proved (given `fundamentals` Prop 6.1(a)); open |
| Prop 1.10 | P2's hypotheses: all hold in $\mathcal H^R$; in $\mathcal H^Q$ only the semimeasure inequalities hold, not lower semicomputability, and the point-family results hold | proved, given P2 |
| Prop 1.11 | coding bound for laws with literal exceptions (flags, or decidability) | proved |
| Prop 2.1, Cor 2.2 | proof-requiring compatibility is monotone in logical strength; scout P's Prop 2.3 | proved |
| Prop 2.3 | precision monotonicity | proved |
| Prop 2.4 | regime G: sharp threshold $\varepsilon^*+\delta_0$; a.s. refutation below it | proved; computed (l2 A, rb1 E) |
| Prop 2.5 | regime R: survival $(1-p_\Delta)^n$; refutation at any precision | proved; computed (l2 B, rb1 F) |
| Prop 2.6 | eventual choice among exact theories, regimes G and R | proved; computed (l2 C) |
| Setting S3 | fresh times, i.i.d. errors and dithers | definition (revised) |
| Lemma 3.2 | prove/silent/refute probabilities of a tolerance law; coarse regime $\Delta\ge\varepsilon+\max(\varepsilon,\varepsilon^*)$ | proved; computed (l3 A, rb1 A) |
| Prop 3.3 | per-datum rates of the forms under four pricings | proved; computed (l3 B, G; rb1 D) |
| Prop 3.3a | deterministic patches cost $\ge H_2(p)/p$ per exception (any code), $\ge\log n$ (literal numerals); det pricings are finite-horizon models | proved; computed (l10 G) |
| Remark 3.3b | repeated times change the costs | computed (ra1 E) |
| Prop 3.4 | peakedness criterion $\mathrm{pk}<\gamma_{\rm ex}/2\gamma_{\rm si}$; two-law variant | proved; computed (l3 B, G; rb1 D); l5 D is a code-consistency check |
| Prop 3.5 | optimal tolerance at the $(1-\theta_{\rm ex})$-quantile (Q/det cost model) | proved; computed (l3 C, rb1 C); known in form ($\nu$-SVR) |
| Lemma 3.6 | exact code-R cost of the honest law at every $\Delta$; $\beta_e\in[0.443,1.443]$; fine excess $\le\log e$; strictly decreasing in $\Delta$ | proved; computed (l3 A, l10 D, rb1 B, ra1 B) |
| Prop 3.6a | completions inside the band: Δ-independent ranking; Gibbs optimality of the error law; nothing beats it (a.s.); HY criterion with bounds 1.79/2.12 | proved; computed (l10 B, C; rb2) |
| Prop 3.7 | fine data: honest law useless in code Q; saves $\ge\log(\mathsf R/2\varepsilon^*)-\log e$ bits in code R | proved |
| Thm 3.8 | a.s. selection under integrable costs; ties oscillate (finite variance); Wald bounds and a.s. scaling of switch times | proved, given standard probability; computed (l3 D–F, rb3 B) |
| Cor 3.9 | phases $0\to E\to P\to H\to N$ and switch points | proved; computed (l3 D–F; l10 H with exact R/rand costs) |
| Prop 3.10 | independent mass on finer questions = share of honest and empty theories; ties; randomised humility as a spread | proved |
| §3.6 | real Kepler residuals: per-fit peakedness; H best within $\{0,P,H\}$; SH best with band completions; HY beats H in 34/39; Q/det verdicts | computed (l4, l5, l10 A–C; rb2, rb3 A) |
| Prop 4.1 | derivation horizon $e_r$; exact zonotope for linear maps; $r^*(\delta)$, "iff" for linear $d=1$ | proved; computed (l6 A, B; rb5) |
| Prop 4.2 | horizon of correctness of an exact approximation ("if"; "iff" for linear $d=1$) | proved |
| Prop 4.3 | sound criterion (with a deciding background): honest models consistent and sound; exact ones explode; pairwise check in 1-D and for boxes, $(m+1)$-wise for balls | proved (Helly known); computed (l6 D, rb5) |
| Remark 4.4 | typical vs worst case ($7.96\varepsilon$ vs $100\varepsilon$) | computed (l6 C, rb5) |
| Prop 5.1 | marginal slopes of a $\lambda$-MAP | proved |
| Def 5.2 | EP; edge slope = EP only for nested vertices | definition |
| Prop 5.3 | facts used once never enter for $\lambda>1$ (hypothesis in the MAP context); length bound around a sufficient law | proved ((b) given Prop 1.11 and P2 `cor:kink:split`) |
| Prop 5.5 | closed-form $\lambda$-MAP of the solar-system toy; $J^*_{\Lambda+K3}<J^*_\Lambda$ iff $s|S|>L_3$ | proved; computed (l7 A, C; l10 J; rb4 A) |
| N2 Prop 4.5's $K3$ criterion | $s|S(\lambda)|>\lambda L_3$ | **refuted** (§10.1) |
| Prop 5.6 | kind nature iff kink | proved, given P2; computed (l7 B: 4000/4000; rb4: 7170/7170) |
| Prop 5.7 | trivialisation blocked, up to $K(\mathcal L')$ | proved, given Prop 1.11 |
| Prop 5.8 | EP = per-bit log-likelihood ratio; $U=I_h-I_\flat$ for any $P_\flat$; Myrvold's term $0$ with stated parameters, $k$ / $0$ / $k_C$ with marginalised ones | proved; computed (l7 E; ra1 G; rb4 D) |
| Copernicus–Ptolemy | three comparisons; $C$ best iff $H<\sum a_p$ and $\lambda<\sum a_p/H$ | proved (lengths not measured) |
| Prop 5.9 | question format (with the consistency condition): elements never enter; $\mathrm{EP}(\Lambda)=cN/L$ | proved; computed (l7 D) |
| Prop 6.1 | when a domain restriction pays (three cases); never asymptotically under code R for bands below $\approx66°$ | proved; computed (l10 E; rb7 A) |
| Prop 6.2 | retention of a superseded theory; monotonicity (code R via Lemma 3.6); retention interval $[\Delta^*,\cdot)$ | proved; computed (l10 F; rb7 B; derivation sizes assumed) |
| Prop 7.1 (a)–(d″) | the successor proves the honest law (uniform tolerance $\varepsilon(W)$, exactly $\varepsilon_{\min}(W)$) and refutes the exact law; strongest common uniform-tolerance form; time-dependent forms stronger; common content is the disjunction | proved; computed (l9, l10 I; rb6, ra1 F) |
| Prop 7.1 (e) | derivations of polynomial size in $W$ | proof sketch (numeral sizes computed) |
| §8 (T8) | under SAI's pricing, tolerances and error models are learned, not sharp domains | assessment from computed results (l5, l10 C, E); pool computation open |
| §10 items 2, 8–19 | withdrawn, refuted or corrected statements of `notes.md` and scouts | refuted or corrected, each with its counterexample |

---

## 14. Response to the referee reports

Both referees recommended acceptance after revision and found nothing fatal. Every issue was checked against the record and, where the referee computed something, against the referee's code. That code was re-run on scratch copies and reproduced exactly; §16, item 3.

### 14.1 Referee A (proofs)

| issue | verdict | action |
|---|---|---|
| **M1** atomless i.i.d. times cannot be numerals; repeats change rates; distinct times make $\pi_c$ unbounded | **accepted** (the $o(n)$ argument re-derived; part E re-run) | Setting S3 restated with fresh times and i.i.d. $(e_j,u_j)$; new **Prop 3.3a** (entropy bound $H_2(p)/p$ for any patch code, $\log n$ for literal numerals); det pricings declared a finite-horizon cost model throughout (Def 3.1, Cor 3.9, §3.6); Remark 3.3b (repeats, `ra1` E); exact R/rand phases added (`l10` H); script docstrings updated; Prop 3.10(a) uses fresh times |
| **M2** Prop 7.1's reading: not "exactly what the two theories have in common" | **accepted** (the model re-checked in exact rationals, `l10` I) | Prop 7.1(d′),(d″) added; reading, §0, §9.1 and §13 corrected; §10 item 10 |
| **M3** Prop 4.3(b),(c) need a deciding background | **accepted** (counterexample checked) | hypothesis added; proof of (c) rewritten via completeness on the relevant sentences |
| **M4** Props 6.1(b), 6.2(b) fail at ties; 6.1(c) uses the tie | **accepted** | three cases of Thm 3.8 stated in both; code-Q sentence of 6.1(c) as proposed; table recomputed exactly (`l10` E) |
| **M5** Thm 3.8 assumes bounded costs; code R is unbounded | **accepted** | (i) for non-negative costs (infinite mean allowed, with an $o(n)$ remainder for mixtures); (ii) under finite variance; (iii) lower bound and path limits under integrability, upper bound under bounded increments; which applications use which part is stated |
| **M6** "peakedness" was a cross-fit ratio; sample maximum as tolerance | **accepted** | per-fit values reported (§3.6 table, `l10` A); Prop 3.4(b), the two-law variant; local-parabola estimate of the sup excess and $\kappa$-sensitivity (verdicts unchanged for $\kappa\le0.05$) |
| m1 coarse-regime condition of Lemma 3.2 | accepted | $\Delta\ge\varepsilon+\max(\varepsilon,\varepsilon^*)$ |
| m2 data must be sentences | accepted | dyadic (or algebraic) dithers, rational centres, wrapping cells as disjunctions (Def 1.5, Setting S3, §2) |
| m3 $\mathcal H^R$ needs a presentation language of total programs; finite $Y$ | accepted | Def 1.5 and Prop 1.10(i) |
| m4 fine-regime bound $\log e$; $24°\to66°$ | **accepted, and strengthened** | Lemma 3.6 now gives the exact fine-regime cost (closed form), the bound $\log e$ as a corollary and strict monotonicity in $\Delta$; Props 3.7 and 6.1(c) use $66°$, stated as a sufficient bound |
| m5 monotonicity of $\gamma_{\rm si}$ in code R unproved | accepted | proved (Lemma 3.6(iii)); Prop 6.2(c) restated with the ranges where it holds |
| m6 $\mathcal H^Q$ is not a P2 class; Church argument too broad; offset | accepted | Prop 1.10(ii) reworded |
| m7 Prop 1.11(b) for inconsistent $T$; "finite" | accepted | weights fixed; presented theories allowed |
| m8 Prop 1.9(c) proof does not cover $J^R$ | **accepted in part** | $J^R$ dropped from (c). The suggested two-line example is **not** used: it fails, because a presentation can store the shared cells, giving $\min J^R_1\le n\gamma/2+O(\log n)$ (Remark 1.9a). The separation for $J^R$ is open; both $L_A$ and $\min J^R_1$ are $\ge K(y_D\mid\dom D)-c$ |
| m9 Prop 4.2 hypotheses | accepted | "if" in general, "iff" for linear $d=1$; $e_0$ allowed; datum centring stated |
| m10 Prop 5.7's constant depends on $\mathcal L'$ | accepted | $-K(\mathcal L')$ made explicit |
| m11 Copernicus–Ptolemy mixes two comparisons | accepted | three comparisons separated; conditions $H<\sum a_p$ and $\lambda<\sum a_p/H$ |
| m12 Q/rand threshold "stays near 1" | accepted | grows logarithmically in $1/p$ (values from `ra1` D) |
| m13 Prop 3.10(b) omits ties and the empty law | accepted | added |
| m14 Cor 3.9(b) needs $h_N>h$; "typical" | accepted | hypothesis added; "predicted order", with frequencies in the computed tables |
| m15 Prop 5.3(a) hypothesis for the MAP context | accepted | restated |
| m16 edge slope = EP only for nested vertices | accepted | Def 5.2 |
| m17 §1.3 reading overstates what SAI charges | accepted | reading rewritten (upper bound; silent vs refuted data; "SAI's pricing" = relative weights of named machines) |
| m18 "and only there"; scope of "wins" | accepted | withdrawn (§10, item 18); scopes stated (and further narrowed by referee B, 1) |
| m19 "never prefers" weakenings | accepted | reading of Cor 2.2 |
| m20 Myrvold's identity needs no product assumption | accepted | Prop 5.8(b) states the identity |
| m21 missing citations ($\nu$-SVR; Srinivasan et al. 1994) | accepted | both cited (§3.3, §5.3, §9.2, `refs.bib`) at the verification levels available |

### 14.2 Referee B (computation and counterexamples)

| issue | verdict | action |
|---|---|---|
| **1** under SAI's pricing the pool is incomplete; HY and SH beat H | **accepted**; (F1) and (F2) re-derived line by line and recomputed independently (`l10` B, C) | Def 3.6a and **Prop 3.6a**: (a) Δ-independence, (b) Gibbs, (c) new: no theory machine beats the error's own law and $L_A/n\to r_F$, (d) the HY criterion with a new *necessary* bound $\mathrm{pk}_\varepsilon>1.794$ alongside the sufficient $2.121$. §0, §3.2, §3.5, §3.6, §6.1, §8, §9.1 and §10 items 2, 6, 8, 9 rewritten |
| **2** Prop 7.1 reading (= A-M2) | accepted | as A-M2; the time-dependent tolerance law is now Prop 7.1(d′) |
| **3** Prop 5.5(b) read literally | accepted (counterexample checked by hand and by `l10` J) | comparison of law choices vs MAP membership separated; §10 item 11 |
| **4** `l8` B code-R values at $c_N=1$ are upper-bound artifacts | accepted | recomputed with the exact closed form (`l10` F); agrees with `rb7` B; "ten times" → $1.8$–$16$ times |
| **5** the tie in Prop 6.1(b) (= A-M4); `l8` A's noisy cell | accepted | exact recomputation (`l10` E): the cell is P |
| **6** "iff" for non-linear $F$ | accepted | Prop 4.1(c), Prop 4.2 restricted; counterexample recorded |
| **7** fine bound loose by 2 (= A-m4) | accepted | Lemma 3.6 |
| **8** peakedness cross ratio (= A-M6) | accepted | per-fit values |
| **9** small numerics | accepted | $\pi_c$ for the Moon; exact $1/p$; the 1757/1757 check relabelled as a code-consistency check; "three, counting a near-tie" |
| **10** Setting S3's times (= A-M1) | accepted | as A-M1 |

---

## 15. Cross-thread consistency

The current records were read for every statement that this record uses or that uses this record:
* the final records of `fundamentals` (Defs 1.1–1.7, Thm 4.1, Thm 5.1, Props 5.2, 6.1, Thm 6.2, Prop 1.8, §13, §16), `logic` and `sfi` (their cross-thread sections), `terms` (its cross-thread table) and `shape` (Def of (E3), Prop 1.8, §15.3);
* the development record of `philosophy`, every line citing `laws`. Its final record existed only as a skeleton when this was written.
* `../../NOTATION-draft.md`.

### 15.1 Definitions and notation

* **Inducers.** $M_A$, $\nu_G$, $G_U$, $W_A$, $K_A$ and $L_A$ are used exactly as `fundamentals` Defs 1.2, 1.4 and 1.7 define them. "$T$ proves $\varphi$" means $B\cup T\vdash\varphi$, and "consistent" means consistent with $B$; both conventions are shared by all threads. `fundamentals` keeps the item numbers of its development record, so this record's citations of it stand.
* **Data.** Answered data are written with $D^\pm$, as in NOTATION §3.2 and `fundamentals` Def 1.1 (`notes.md`'s $D^\sharp$ is dropped). A data set of answered questions is the two-valued data set of its answers.
* **Conditional questions** follow `shape`'s encoding (E3), with consistency of $B\cup T\cup\{\alpha\}$ (Prop 5.9).
* **NOTATION §6.4 symbols** are used as defined. Two refinements are reported in §11: $\|\mathcal A\|$ for the module length in $\mathrm{EP}$, and $\mathrm{pk}(e)$ always for one named fit. $\lambda$ is only P2's steepness, $\delta$ is the data precision (as `logic` notes for its own local $\delta$), and $\kappa$ is P2's constant (Prop 1.11 plays its role).
* **Local letters.** $\mathsf R$ (range) is sans serif. $R$ in §7 is a rotation, local, and NOTATION's literal predicate $R$ appears only in Prop 1.9(c), with its NOTATION meaning.

### 15.2 Other threads' items used here, checked

| item used | where | check |
|---|---|---|
| `fundamentals` Thm 4.1 (mixture identity, dominance) | Props 1.8, 1.9, 3.6a(c) | statement as cited, final record |
| `fundamentals` Thm 5.1, Prop 5.2(b),(c), Prop 1.8(d), Thm 6.2 | Props 1.4, 1.9 | as cited; `fundamentals` §16.2 reports these uses as consistent |
| `fundamentals` Prop 6.1(a) (coding lower bound $-\log\Bel_0(\sigma)\ge K(\sigma\mid S)-c$) | Remark 1.9a (new use) | applies with $S$ the answer conjunctions of $\dom D$, pairwise $B$-incompatible and computable from $\dom D$ |
| `shape` (E3) and Prop 1.8 | Prop 5.9 (new) | the toy's theories are consistent with every true antecedent, which answers `shape`'s open question in its §15.3: Prop 5.9 is not affected |
| `philosophy` T4 (Kepler language, Ramsey sentence, scout P's Prop 2.1) | Def 5.4, Prop 5.9 reading | cited, not re-proved |
| P2 `lem:setup:hull`, `lem:setup:coding`, `lem:kink:main`, `cor:kink:locate`, `cor:kink:split`, `thm:kink:converse`, `prop:kink:universal` | Props 1.9–1.11, 5.3, 5.6 | hypotheses checked in Prop 1.10 (unchanged from `notes.md`; referee A checked them) |

### 15.3 Uses of this record by other threads, and what changed for them

| thread and item cited | what changed here | suggested change there |
|---|---|---|
| `fundamentals` §16.2: `laws` Props 1.4, 1.8, 1.9 | Prop 1.9(c) narrowed to $K_A$, $J^Q_1$, $J^F_1$ (Remark 1.9a: $J^R$ open); Prop 1.9(d) with $\kappa_0=0$; Prop 1.8's reading rephrased; Prop 1.4 now writes $D^\pm$ (`fundamentals`' convention) | none needed; if `fundamentals` quotes "no restricted class matches $L_A$", narrow to the classes named |
| `shape` §15.3: `laws` Prop 5.9 | consistency condition (E3) added; the toy is unaffected | mark the open point as settled |
| `terms`: `laws` Prop 5.9's Ramsey mention | unchanged | none |
| `logic`, `sfi` | no use | — |
| `philosophy` (development record) §4.6, §5, claims table: "under SAI's own pricing silence is cheap and honesty wins unless the error is very peaked; on the Kepler residuals (peakedness 1.9–4.0) the honest law wins for every body, window and precision" (`laws` Prop 3.4, §3.6); "randomised honest theories ... win on the real Kepler residuals" (`laws` §10 item 6) | the R/rand pool was incomplete (§3.6, Prop 3.6a; §10 items 8, 9); per-fit peakedness is 1.60–3.95 (minimax fit) and 1.89–7.08 (mean fit) | replace with: "within the pool {no law, exact law with exceptions, uniform honest band} the honest band wins under SAI's pricing; but SAI's mixture prefers the law together with an error distribution shaped like its residuals (`laws` Prop 3.6a, §3.6), and the two-point form 'exact except in a share, then within $\varepsilon$' beats the uniform band iff $\Ex\ln(1+|e|/\varepsilon)<2\ln2-1$ (34 of 39 Kepler body–window pairs)" |
| `philosophy`: "Scout N2's pricing-independent reading ... is refuted as stated (`laws` §10 item 2)" | item 2 restricted: under SAI's pricing N2's reading survives in the HY form, with thresholds 1.79 / 2.12 | "is pricing-dependent: true under deterministic patches; false under literal pricing with random exceptions; under SAI's pricing a peakedness criterion survives with thresholds about 2" |
| `philosophy`: "honest approximate theories are partial theories: the trichotomy is the formal home of humility" | Prop 3.10's reading now limits this to deterministic theories; for SAI's randomised theories humility is calibration of an error distribution | add "for deterministic theories" and the calibration sentence |
| `philosophy`: "a domain restriction ... never happens asymptotically for a system the law confines to within about 24° of longitude, so the Moon is kept with an honest tolerance of a few degrees" (`laws` Prop 6.1) | $24°\to66°$ (sufficient bound, not a threshold); kept "with a tolerance and an error distribution" | update the number and wording; the Moon example stands |
| `philosophy`: "learning domains is partial (`laws` §8: tolerances per body and window are learned)" | "tolerances and error distributions" | wording |
| `philosophy` line on Copernicus: "$\mathrm{EP}=\sum_pa_p/H$ relative to the coincidence axioms it replaces, with no change in fit" | the EP $\sum a_p/H$ is relative to free-phase Ptolemy (fit changes by $\sum a_p$); against the stated coincidences the fit is equal and the comparison is $H$ vs $\sum a_p$ (§5.3, referee A m11) | separate the two comparisons |
| `philosophy`: `laws` Prop 5.5(b) criterion "K3 enters iff $s|S|>|K3|$" (steepness 1) | correct as the comparison of law choices; it is not membership of the $\lambda$-MAP (the empty theory may win, §10 item 11) | none needed if read as "K3 pays given the law", which is how it is used |
| `philosophy`: `laws` Prop 4.3 (sound criterion), Remark 4.4 | Prop 4.3 now assumes a background deciding the comparisons (true for semialgebraic models over RCF) | none in substance |
| `philosophy`: `laws` Prop 7.1 ("the successor proves the honest old law on every window, with least tolerance $\varepsilon_{\min}(W)$") | correct for uniform tolerances; the reading "exactly what the two have in common" is withdrawn | if quoted, add "uniform-tolerance" and drop "exactly in common" |
| `philosophy`: `laws` Props 2.1, 2.4, 2.5, Cor 2.2, Def 5.2, Props 5.8, 5.9 | unchanged in substance (5.8(b) generalised; 5.9 with (E3)) | none |

### 15.4 Notation-draft and points to pass on

* **NOTATION §6.4.** Add $\mathrm{Exc}^Q$, $\mathrm{Exc}^F$, $\mathrm{Exc}^R$; read $|\mathcal A|$ in $\mathrm{EP}$ as $\|\mathcal A\|$; and require every reported peakedness to name its fit (§11).
* **NOTATION §3.2.** Fix the conditional encoding as (E3) (with `shape`).
* **To the synthesis.** The headline about Kepler's errors under SAI's pricing is now: *a law with a calibrated error model*, not "the honest uniform band at every precision" (§3.6, Prop 3.6a). The silence-based humility of the trichotomy applies to deterministic (code-Q) readings only.
* **Possible error in the author's view.** None raised here. The brief assigns these notes to `philosophy`, and this revision found none of its own.

---

## 16. Verification log

1. **Restart check.** At the start of this revision the folder held `notes.md`, the two referee reports, `referee_code/` (`ra1`, `rb1`–`rb8`, each with its output), `checks/` (`l2`–`l9`, with outputs and `l4_residuals.npz`) and `refs.bib`. There was no `notes-final.md` and no revision script, so nothing from an interrupted run had to be recovered. A skeleton of this record was saved first, and each section was appended as it was finished.

2. **Reading.**
   * In full: the thread brief, the project brief, `NOTATION-draft.md`, `notes.md` (653 lines), `referee-A.md` and `referee-B.md`.
   * In full: the developer scripts `l5` and `l8`. The docstrings of `l2` and `l3`.
   * Referee A's part E (code and output).
   * The other threads' records as listed in §15.
   * Scout L's `refs.bib` entry for Srinivasan et al. 1994.

3. **The referees' code.**
   * All nine scripts were copied to the scratchpad (`laws_rev/rerun_ref/`, with a copy of `l4_residuals.npz`) and run with `python3 -I` (Python 3.11.15, numpy 2.4.6, scipy 1.17.1).
   * Run times: `ra1` 40 s, `rb1` 4 s, `rb2` 11 s, `rb3` 29 s, `rb4` 12 s, `rb5` 9 s, `rb6` <1 s, `rb7` 14 s, `rb8` 11 s.
   * `diff` against the saved outputs shows only the runtime line (checked: each saved output has exactly one line matching the filter, `# runtime …`). All nine reproduce.
   * Results used in this record: `ra1` A, B, D, E, F, G; `rb1` A–F; `rb2`; `rb3` A, B; `rb4` A, B, D; `rb5` A–C; `rb6`; `rb7` A, B; `rb8` (propositional checks of §1).
   * The referees' scripts were not modified.

4. **The developer's scripts.**
   * *Edits.* Revision notes were added to the docstrings of `l2`, `l3`, `l5` and `l8`: the reading of $t\sim U[0,1)$ as fresh times, the finite-horizon det pricings, `l5`'s cross ratio and incomplete pool, and `l8`'s two corrected cells. No code changed.
   * *Re-runs.* All except `l4` were re-run on scratch copies (`laws_rev/rerun_dev/`): `l2` 25 s, `l3` 18 s, `l5` 337 s, `l6` 4 s, `l7` 1 s, `l8` <1 s, `l9` 4 s. The outputs are identical to the saved ones apart from the runtime line, so the saved outputs stand.
   * *`l4`.* Not re-run in this revision: it takes 31 min and needs pyerfa, which is not installed in this container. The development round and referee B both re-ran it, and all 117 arrays of `l4_residuals.npz` were bitwise equal.

5. **New script `checks/l10_revision.py`** (seed 20261016; sub-generators seeded 20261017, 20261021, 20261023, 20261027; output `checks/l10_revision.out`).
   * *Independence.* Written from this record's statements, independently of the referees' code; none of it is re-used.
   * *Runs.* First on a scratch copy (190 s), then in place (199 s). The two outputs are identical apart from the runtime line and two output lines whose item labels were changed between the runs (to Thm 3.8(ii) and Props 3.7, 6.1(c)). Before the first full run, a vectorised `math.lgamma` was replaced by `scipy.special.gammaln` for speed; the numbers do not depend on this. Parts and results:
   * **A** (per-fit peakedness; sup estimate):
     * minimax fit 1.60–3.95, mean fit 1.89–7.08, cross ratio 1.85–3.98, as referee B reports;
     * the local-parabola excess of the true supremum over the sample maximum: median $2\times10^{-4}$, 30 of 33 estimates below 1%, two near 2%, and Mercury over 2000 years unresolved.
   * **B** (band-confined completions, coarse regime):
     * the closed form $\log e-H_2$ equals the integral form for H in every row;
     * synthetic: sinusoid no HY gain; peaked HY $0.1790$ at $\rho=0.099$; uniform $|e|$ on the boundary; two-level HY gain;
     * real: HY* < H in 34/39 (band $1.01\times$; referee B 33/39 at $1.00\times$); criterion agrees 39/39; 0 bound violations; SH < H 39/39; SH within $0.0011$ bits of the Gibbs bound in all 39.
   * **C** (rates on the real residuals; 429 cells at each of three $\kappa$):
     * H is best within $\{0,P,H\}$ in 429/429;
     * SH is best with HY and SH added, in 429/429;
     * SH is $0.4$–$25.7\%$ below H (median $6.6\%$);
     * HY* < H in 380, 379 and 373 cells for $\kappa=0$, $0.01$, $0.05$.
   * **D** (Lemma 3.6):
     * closed form against 5000-point quadrature: max error $1.0\times10^{-4}$ bits over 36090 cells;
     * max fine excess $1.442695=\log e$;
     * no increase with $\Delta$; continuity at $\Delta=L$ to $1.4\times10^{-9}$;
     * $\mathsf R/(2e)=3973'=66.2°$.
   * **E** (`l8` A exactly): ties at $\Delta=10',60'$ (code Q) resolved by the constants; the $\Delta=600'$, $\lambda=2$ cell is P ($2.69330<2.69394$); agrees with `rb7` A.
   * **F** (`l8` B exactly): the table of §6.2; Mars over 12 years $1.744'$ and the Moon over a month $44.36'$ (referee B: $1.744'$, $44.4'$); no increase of K's code-R rate with $\Delta$ on 300-point grids.
   * **G** (Prop 3.3a): the table of §3.1.
   * **H** (exact R/rand phases): the table and text of §3.4; all 400 runs reach N.
   * **I** (Prop 7.1(d′),(d″)), in exact rationals:
     * $\varepsilon_{\min}(10)=0.09998$, $\varepsilon_{\min}(100)=0.96123$;
     * the time-dependent tolerances average half of $\varepsilon_{\min}$;
     * the two separating points and the model behave as stated.
   * **J** (Prop 5.5(b)): the hand counterexample ($20<1003<1010$); 13250/13250 for the comparison of law choices; 1445 literal failures.

6. **Proofs re-derived or new in this revision** (each line checked by hand):
   * Prop 3.3a: Kraft plus Jensen for set codes and for numeral codes, and the almost-sure version by the strong law on the second half of the indices.
   * Lemma 3.6: the fine-regime case analysis ($y/\Delta=\min(u,a)+\min(1-u,b)$, three cases); the bound via $\phi(a)+\phi(1-a)=1-H_{\rm nat}(a)$; monotonicity via $dC/dr\ge(1-2/e)/r$; continuity at $r=1$.
   * Prop 3.6a:
     * (a) and (b), referee B's (F1), re-derived;
     * (c) is new: disjointness of the events "proves answer list $y$" across $y$, Markov at level $2\log n$, Borel–Cantelli, the strong law, and dominance;
     * (d), referee B's (F2): the three-range integral recomputed ($\ln(1-x)+1-\ln2$); convexity of $-\ln$ of an affine function; differentiation under the expectation by monotone convergence with bounded derivatives; the necessary bound from the chord $\ln(1+z)\ge z\ln2$ (new); the sufficient bound from Jensen.
   * Thm 3.8: the strong law with infinite mean by truncation; the CLT and Hewitt–Savage under finite variance; Wald with integrable increments and $\Ex\tau<\infty$.
   * Remark 1.9a: the storing presentation; the lower bound from `fundamentals` Prop 6.1(a).
   * Prop 4.3(c) via compactness and the decided sentence.
   * Prop 7.1(d′),(d″).
   * The three Copernicus–Ptolemy comparisons.
   * Prop 6.1(b) and 6.2(b),(c) case analyses.

7. **Literature.**
   * The WebSearch budget of this run was exhausted (a limit shared by all agents of the turn), and the three searches attempted were refused. So `scholkopf2000new` is cited at referee A's verification level and `srinivasan1994justification` at scout L's, and Koenker and Bassett is not cited.
   * `refs.bib` (30 entries) parses with BibTeX (plain style, `\nocite{*}`) in a scratch copy: 30 items, 0 warnings.

8. **Cross-thread reading.** §15. Two points came from other threads' final records and are used here: `shape`'s (E3) condition (Prop 5.9), and `fundamentals` Prop 6.1(a) (Remark 1.9a).

9. **Not done.**
   * T8's posterior over an explicit pool of domain predicates.
   * Measured derivation sizes for §6.2, and a formal derivation-size bound for §7 beyond the numeral sizes.
   * The separation question for $J^R_1$ (Remark 1.9a).
   * The true suprema of the residuals by refined evaluation of the ephemeris (pyerfa unavailable; a local-parabola estimate and $\kappa$-sensitivity instead).
   * A pool larger than the band-confined machines (e.g. time-correlated error models).
   * Fresh literature searches.

10. **Repository.** No git command that changes repository state was run. All writes are in this folder (`notes-final.md`, `checks/l10_revision.py` and its output, docstrings of `checks/l2`, `l3`, `l5`, `l8`, `refs.bib`); scratch work is in the session scratchpad.
