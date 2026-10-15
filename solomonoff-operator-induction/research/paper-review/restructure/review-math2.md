# Review math2: noisy parity, teacher, structured errors, computable classes (Paper 2 restructure)

Reviewer: math2, 2026-10-13. Scope: `parity.tex`, `teacher.tex`, `limits.tex`, `computable.tex` and their appendices `app-parity.tex`, `app-teacher.tex`, `app-limits.tex`, `app-related.tex` (§7–§10, App E–H of the built PDF). The paper was not edited. No git command that changes repository state was run.

## 0. What was done

* **Build.** `flock /tmp/claude-0/paper-build-sfi.lock ./build.sh` in `paper-steeper/`: 0 LaTeX errors, 0 undefined references or citations, 0 multiply defined labels, 0 overfull boxes above 10 pt, 75 pages. The PDF text (`pdftotext -layout`) of §7–§10 and App E–H was read in full, together with the sources.
* **Inputs read.**
  * `PLAN.md`: §0–§3.6, §4, §5, §6 and §7.
  * The logs `log-W4.md`, `log-W5.md`, `log-W6.md` and `log-front.md`.
  * `verify-kink.md` §4, `verify-teacher.md` in full, and `final-check.md` (correction table).
  * The records: kink `notes-final.md` §4; teacher `notes-final.md` §1–§5; iid Cor 6.2; steeper notes on the majority remark.
  * Paper 1's `prop:ood:hanni` and `cor:learn:mistakes`, with `paper/main.aux`.
* **Checks.** Every statement and proof in scope was compared with its record, including hypotheses, quantifiers, constants and statuses. Each proof was re-derived line by line. The exceptions are base material that is unchanged and was refereed earlier (`prop:algstat:coarse`, `prop:limits:guard`, `prop:limits:inputlaw`, `prop:related:computability`, `prop:teacher:concentration`); for those the statements and the main steps were checked.
* **Numbers recomputed independently** (scripts in the scratchpad, `mpmath`, not in the repository):
  * $p_0$, $p_1$, $\min(f_2-H)$, and $L_S$ (example and `ex:teacher:version1`);
  * $c_{\rm hi}$ at $d=100$, $m=20$ for κ = 0 and 30, the ratio 8453, and $Nc_{\rm hi}$ at $d=m=20$;
  * the numbers of `rem:teacher:hanni`(2), and $c_{\rm hi}$, $n(1-H)$ and $nH$ of `ex:teacher:version1`;
  * the 11,853 exceptions out of $1.238\cdot10^{27}$ error inputs;
  * the envelope numbers: $\log\binom{2^m-s_1}{s_2}$, $H-R_e$, $c_{\rm env}$, the window shares and the $e_1$ bounds;
  * the $d_0$ table of `lem:limits:robust` (with exact ceilings it matches all 18 entries);
  * the guard-erosion rates;
  * the memoriser-regime $e$ bounds, and the $d=20$, λ = 2 bounds of `cor:teacher:fulltable`.
  * The printed values of `tab:teacher:rates` and `tab:teacher:numbers` were compared with the saved outputs `teacher/checks/t6_exact_window.out` and `teacher/verify_code/v5_junta_constants.out`. `tab:parity:ranges` and the identification numbers were compared with `verify-kink.md` §4.2–§4.3.
* **Paper 1 citations in scope** (Cor 5.4, Prop 8.1, Prop 8.1(a), §9.1, Thm 9.10, Rem G.11, Prop A.10(c), Prop 10.1, Q 10.9, Rem H.2):
  * `check_companion_numbers.py` ends with `ALL OK`;
  * Cor 5.4 (`cor:learn:mistakes`) and Prop 8.1 (`prop:ood:hanni`) were also checked by hand against `paper/main.aux` and the statements.
* **Visible vocabulary.** The DECISIONS §A5 grep and the PLAN §7.2.4 additions were run on the in-scope PDF text. There are no hits outside formula renderings ($s_0$, $c_1$, $S_1$, …) and the Paper 1 citations "(Hänni, 2026a)". The κ = 0 numbers are marked as illustrations at first use.

**Overall.** The mathematics in scope is faithful to the records as verified. Where a verification report corrected a statement, the paper uses the corrected form:
* the corrected $R_{\max}$;
* the wording fixes of Prop 3.6;
* (b) of Prop 3.7 for every program for ν;
* the reference scaling in Lemma 3.0;
* the corrected ranges and roundings of V-K §4.2–§4.3;
* $p_0$, $p_1$ and $p^*$ with the "≥" reading and decimals rounded down;
* both side conditions of the $c_{\rm env}$ reading;
* "implies" in rate blindness.

I found no fatal issue. There are **3 major** issues, each fixable in a line or two, and **14 minor** issues.

---

## 1. Major

### M2-1. Theorem 8.6, item (o) prints as "()"
* **Where.** `teacher.tex` l. 75, `\begin{enumerate}[label=(\roman*),start=0,…]`. PDF p. 28: "() Level bounds."
* **Problem.** `\roman{0}` is empty, so the item has no visible label. The text cites it as "Theorem 8.6(o)" in five places: §9.1 proof idea; Prop 10.1(a); App F.2 ("We prove (o)", "Proof of Theorem 8.6(o)", "By (o)"); App G.1. A reader cannot find the item. The defect was already in the base.
* **Fix.** Use `start=1` and write the first item as `\item[(o)]`. The later items stay (i)–(iv).

### M2-2. The truncation level $B$ must be an integer or ∞ wherever (D2) is used
* **Where.**
  * `parity.tex` l. 30 (`def:teacher:instance`(c): "$B\in[\log(1/p),\infty]$") and l. 56 (`lem:teacher:twopart`, no restriction on $B$);
  * `teacher.tex` l. 74 (`thm:teacher:main`: "with $B\in[\log(1/p),\infty]$"), and through it `prop:teacher:kinks`, `prop:teacher:sharp` and `cor:teacher:sampled` ("let $B<\infty$");
  * `app-teacher.tex` l. 31 (`prop:limits:plain`(b): "Let $B<\infty$").
* **Problem.** `lem:teacher:coding` is stated and proved only "for integer or infinite $B$": its proof describes $B$ in $2\log B$ bits. (D2), and with it (o), (i), (ii) and (iii) of the theorem, uses the coding lemma at the instance's $B$, which may be any real number. For a non-integer $B$ the stated (D2) does not follow from that proof.
  * Replacing $B$ by $\lfloor B\rfloor$ does not give the stated bound either, because the slack term $2^m\log(1+2^{1-B})$ changes, and for non-dyadic $p$, $\lfloor B\rfloor$ can fall below $\log(1/p)$.
  * The teacher record flags this as "an inherited condition (A m19) … a point for the paper" (teacher `notes-final.md` after Prop 2.1). It was not carried over.
* **Fix.** In `def:teacher:instance`(c), write "for a truncation level $B$ that is $\infty$ or an integer $\ge\log(1/p)$". Every number in the paper uses $B=\infty$ or $B=30$, so nothing else changes. `prop:teacher:schedules`(c) already says "an integer".

### M2-3. "Useless over set models" overstates Props 7.10 and E.5 and contradicts App E.5
* **Where.** `parity.tex` l. 148 (`rem:algstat:reading`): "This is why steeper simplicity is useless over set models in this example (Propositions 7.10 and E.5)".
* **Problem.** The two propositions bound the set models' left steepness by $1+O((\log d+\delta_E)/d)$. They say nothing for $\lambda-1$ of that order, as §7.4 itself states ("For λ−1 of order (log d+δ_E)/d nothing is claimed").
  * The last paragraph of App E.5 reports that with an Elias code for $v$ the set that knows $a$ is a set-hull vertex up to $\lambda=1.36$ at $d=30$.
  * The kink record (§4, "Set hull: the code for $v$ decides") marks the code-independent reading "the parity is noise for every λ" as refuted.
  * As written, the remark restates that reading and contradicts the paper's own appendix.
* **Fix.** "…is useless over set models in this example once $\lambda-1\gg(\log d+\delta_E)/d$ (Props 7.10 and E.5; closer to 1 the code's $O(\log d)$ terms decide), and decisive over product models…".

---

## 2. Minor

### m1. Several bounds are rounded toward the stronger side (PLAN §7.1.4: bounds in the safe direction)
* **`tab:teacher:numbers`** (`teacher.tex` l. 108–111). The saved outputs give the following; the bold entries are printed too small:

  | row | ℓ | $I$ | $L_S-K$ | $e$ |
  |---|---|---|---|---|
  | κ = 0, $\delta_S=0$ | **$d+20.43$** (printed 20.4) | **37.72** (37.7) | 37.72 | **0.1991** (0.199) |
  | κ = 0, $\delta_S=20$ | **20.63** (20.6) | **37.91** (37.9) | **57.91** (57.9) | 0.2177 |
  | κ = 30, $\delta_S=0$ | **51.01** (51.0) | 98.30 | 98.30 | 0.2735 |
  | κ = 30, $\delta_S=20$ | 51.20 | 98.49 | 118.49 | 0.2869 |

  Sources: `t6_exact_window.out` ll. 61, 66, 71, 73; `v5(D)`.
  * The caption says "rounded to the nearest unit". DECISIONS §A9 tolerates a stated convention, but PLAN §7.1.4 asks for the safe direction.
  * *Fix:* regenerate with $u$ rounded down and ℓ, $I$, $L_S-K$ and $e$ rounded up (for example $d+20.5$, 37.8, 37.8, 0.200 in row 1), and say so in the caption.
* **`rem:teacher:numbers`** (`teacher.tex` l. 99). The κ = 30 window "$(9.54\cdot10^{-7},3.66\cdot10^{-3}]$" has a closed upper end, rounded up from the true $c_{\rm hi}=3.65897\cdot10^{-3}$. *Fix:* $3.65\cdot10^{-3}$ (or $3.658\cdot10^{-3}$).
* **App F.2 "Numbers"** (`app-teacher.tex` l. 83). The memoriser-regime lower bounds on $e$, recomputed with $\kappa_b$ as defined (with $2\log s_0$), are:
  * κ = 0: 0.95463, 0.83051, 0.65846, 0.48317, 0.22286, printed 0.955, 0.831, 0.658, 0.483, 0.223;
  * κ = 30: 0.91664, 0.70598, 0.45686, 0.25572, 0.05994, printed 0.917, 0.706, 0.457, 0.256, 0.060.

  Six of these lower bounds are printed above their true values. *Fix:* print 0.954, 0.830, 0.658, 0.483, 0.222 and 0.916, 0.705, 0.456, 0.255, 0.059.
* **Envelope** (`limits.tex` l. 33; `app-limits.tex` l. 32). The lower bound "at least 0.545" ($j=13$, $\delta_2=0$) is 0.54494; print 0.544. The κ = 30 share "25%" (0.25) is 0.2493; print "24%", or "about 25%" in the main text.

### m2. Question 8.14(b): the boundary should be $p_1$, not 0.1233
* **Where.** `teacher.tex` l. 180: "For $0.1233\le p<\frac14$ … The present floors cannot give level 1 there".
* **Problem.** On $[0.1233,\,p_1=0.1233072\ldots)$, `prop:teacher:rates` does give level 1 (asymptotically). The sentence is false on that interval; 0.1233 is the rounded-down sufficient decimal.
* **Fix.** "For $p_1\le p<\frac14$" ($p_1$ is defined in §7.3).

### m3. Question 7.13: the slack $O(\log(kn))$ is as large as the parameter in its own example
* **Where.** `parity.tex` l. 156.
* **Problem.** For the noisy parity, $n=|\dom D|=2^d$ and $k=d$, so $O(\log(kn))=O(d)$, the size of the parameter.
  * With that slack, a set model may contain the whole parameter. The question then does not express "a near-sufficient set model that omits the parameter", which is how §11 describes it.
  * The closing cap $1+(b+O(\log(kn)))/(\alpha_{\rm r}-K(A\mid\dom D))$ can then be vacuous at $\alpha_{\rm r}\approx d$.
  * The record's question (kink §8 item 4) is informal; this precise form is the writer's own (log-W4 deviation 10).
* **Fix.** Ask for $K(A\mid\dom D)\le|q|+o(k)$ and slack $b+o(k)$ as $k\to\infty$ (or $O(\log k)$ terms that do not depend on $n$). $A_0$ satisfies both, since $K(A_0)\le c^*=O(\log d)$. Adjust the cap the same way.

### m4. Two cross-references that no longer support their sentences
* **App H.1, last sentence** (`app-related.tex` l. 60): "The scripts of the earlier report reproduce its numbers (`app:teacher:computations`)".
  * W5 removed the supporting sentence from `app:teacher:computations` (log-W5 D-W5-9). In the base it read "the scripts of the earlier report give the same window $(1.119\cdot10^{-6},8.989\cdot10^{-3})$ … and the same λ = 1 switch".
  * The pointer now leads to a paragraph that says nothing about the earlier report.
  * *Fix:* delete the sentence, or restore one sentence in `app:teacher:computations`.
* **§10, proof idea of `prop:related:computable`(d)** (`computable.tex` l. 18): "with a finite input set … inputs repeat, so the data are per query (Remark 3.2)".
  * This misstates iid Cor 6.2 ("So PQ is the object for which recovery holds"). Repetition does not make the data per query. Remark 3.2(a) says that FR and PQ differ there.
  * *Fix:* "…inputs repeat, so (d) concerns per-query labels; with frozen labels the data eventually form one table (`rem:recovery:frozentable`)".

### m5. A computed decimal in a proposition title
* **Where.** `teacher.tex` l. 171, `prop:teacher:rates`: "A window for every flip rate below $0.1233$, asymptotically".
* **Problem.** DECISIONS §A9 and PLAN §5.2 ("state it with the explicit crossing conditions … the decimals after the statement") keep computed numbers out of theorem-like environments. 0.1233 is a computed crossing, rounded down.
* **Fix.** "A window for every flip rate below $p_1$, asymptotically". The subsection title "Flip rates below 0.1233" may stay.

### m6. "For $p\ge1/16$ it starts above 1" holds only at the levels of Table 5
* **Where.** `parity.tex` l. 127; `app-parity.tex` l. 123.
* **Problem.** Table 5 uses $t_0=1$ at $p=1/16$.
  * At $t_0=2$, $G_2(1/16)=0.541>H(1/16)=0.337$, so the level-≤2 range at $p=1/16$ reaches λ → 1.
  * The claim is right for the certified levels of the table, not for every level.
* **Fix.** "for $p\ge1/16$, at the level $t_0$ of Table 5, it starts above 1".

### m7. Γ and $t_0$ reused with other meanings
* **Where.** `app-teacher.tex` l. 10 defines $\Gamma_g:=\delta_S+\Delta_\ell+\Lambda_3+\ldots$ (a threshold, used once, l. 76). §7.3 uses $\Gamma_t$, $\Gamma^\circ_t$ and $\Gamma_t(\lambda)$ for floors in the same instance. App F.7 (l. 150) uses $t_0$ for a level other than §7.3's $t_0$.
* **Fix.** Drop $\Gamma_g$ and write the threshold inline at l. 76, or call it $T_g$. Rename the F.7 level $t_c$. PLAN §4.2 asks writers to rename local clashes.

### m8. Undeclared δ and δ*
* **Where.**
  * `prop:teacher:schedules`(c) (`teacher.tex` l. 35) and `prop:limits:plain`(b) (`app-teacher.tex` l. 31) use the confidence δ without introducing it.
  * `prop:teacher:frozen`(a) (`app-teacher.tex` l. 16) uses $\delta^*$ with only its tail.
* **Fix.** Add "$\delta\in(0,1)$" to both statements. In `prop:teacher:frozen`(a) write "where $\delta^*$ is the Ville deficiency of $\xi_{\mathcal C}$ (Lemma 6.2) along the distinct inputs, so $\Prob[\delta^*\ge j]\le2^{-j}$".

### m9. "Stays within" for a one-sided bound
* **Where.** `teacher.tex` l. 28.
* **Problem.** "for fixed $\lambda>1$ the $\lambda$-MAP stays within $(k+\delta^*)/(\lambda-1)$ bits of the sampler's length $k$". `prop:teacher:frozen`(a) and `thm:split:private`(i) give only an upper bound on the length.
* **Fix.** "is at most $(k+\delta^*)/(\lambda-1)$ bits longer than the sampler's program".

### m10. Table 6 floats into Appendix G
* **Where.** `app-teacher.tex` l. 170, `\begin{table}[h]`.
* **Problem.** `tab:teacher:rates` (App F.7) lands at the top of p. 70, after the heading of Appendix G.
* **Fix.** `\FloatBarrier` (package `placeins`) at the end of `app-teacher.tex`, or place the table before the paragraph that cites it with `[ht]`.

### m11. Computed numbers inside a proof
* **Where.** Proof of `prop:limits:plain`(b) (`app-teacher.tex` l. 40): "With the machine constant set to 0, $B=30$ and $\delta=0.01$, a direct computation gives $e\ge0.649$ … $e\ge0.734$".
* **Problem.** DECISIONS §A9 puts such numbers after the statement or proof, with "(code in the accompanying repository)" and "(an illustration)".
* **Fix.** Move the sentence into the "For instance" paragraph after the proposition, with both phrases.

### m12. A step that the proof of Prop 8.12(iii) leaves out
* **Where.** `app-teacher.tex` l. 151.
* **Problem.** The proof of Thm 8.6(i) that it reuses obtains $\Lambda_2\ge0$ from "$c\le c_{\rm hi}$ forces $G_1>H(p)$, hence $p<p_0$". With $\Phi_2^\sharp$ that route is gone.
  * The conclusion still holds. If the Φ₂♯-window is nonempty, $\pi_g\notin\mathcal N$; otherwise $J_g\ge J^B_c(\pi_g)\ge LB_2\ge\Phi_2^\sharp$. So $p<\frac14$, and $\Lambda_2\ge0$ by Prop 8.5(b).
  * In any case $\Delta$'s $\max\{0,\cdot\}$ keeps $J_c(\pi_g)\le\Phi+\Delta$.
* **Fix.** Add that sentence.

### m13. Lemma 8.2: margins and offsets are not λ-thresholds
* **Where.** `teacher.tex` l. 23.
* **Problem.** "every λ-threshold of $D$ is multiplied by $r$: … wedge margins, … offsets of right lines". Margins and offsets are fit quantities; they also scale by $r$ (V-T §4).
* **Fix.** "every λ-threshold (edge slopes, vertex λ-intervals, left steepness, right-line slopes and right secants) is multiplied by $r$, and so are the wedge margins and the right-line offsets".

### m14. Small points of clarity (optional)
* At $c=10^{-4}$ the paper prints three $(u,e)$ pairs for the same quantity:
  * Table 3: 0.983 / 0.199 (base (a));
  * Remark 8.7: 0.988 / 0.194 ($R_{\max}$);
  * Table 6: 0.989 / 0.193 (a2).

  One clause in the caption of Table 6 would prevent confusion.
* Remark 8.7, "a band of relative width about 6% below $2^{-m}$": this is the κ = 0 value. At κ = 30 App F.2 gives 0.888, about 11%.
* §7.1 l. 38 cites "(F5)" with no pointer to `app:setup:facts`.

---

## 3. Verified and correct (no action needed)

* **§7 / App E.**
  * `def:teacher:instance` for general $s_0$, with $\kappa_g$ via $K(p)$. Checked against teacher Prop 5.3 and kink §4: nothing else uses $p=2^{-r}$.
  * The four lemmas and the sharp floor, including the "any $I\ge I(\pi)$" form and its monotonicity (V-K fact (β)). Every step of the $V$-side and $A$-side coding was re-derived.
  * `prop:parity:kink` (kink Prop 4.1): the window lies in $[0,\kappa_g+s(t_0)+\Lambda_1]$, and the level-∞ case holds.
  * `prop:parity:range`: (i)(a)–(g); (ii) with the facts (α), (β), (γ) of V-K §4.1; (iii) in its dyadic form, with $\epsilon_d$ at $g=d$.
  * `prop:parity:sets`: the bounded reference point is used correctly. The proposition equals `prop:kink:universal`(i) with $A_0$, $\ell_U=c^*$ and $\kappa_0=\delta_E+2\kappa$.
  * `prop:algstat:parity`(ii) in its merged form, which the proofs imply. Its lower end is never stronger than the base.
  * The crossing derivatives; $p_0=0.0559643\ldots$, $p_1=0.1233072\ldots$ and $\min(f_2-H)=0.0187969$ (recomputed).
  * Table 5 and the identification numbers (0.9928, $d+45.7$, 58.4, 0.209; 0.9903, $d+15.6$, 28.3, 0.184) are exactly the corrected values of V-K.
* **§8 / App F.**
  * `prop:teacher:kinks` and `thm:teacher:main` via `lem:kink:main`: Δ, $\Delta_\ell$, the risk bound and $R_{\max}=J_g+\epsilon-c(d-4-\Lambda_1)^+$ (V-T §8).
  * `cor:teacher:fulltable` (teacher Prop 3.1(a),(b)). At $d=m=20$, λ = 2: $\ell\le d+58.12$ and $I\le70.76$, printed as 58.2 and 70.8, which is safe. $Nc_{\rm hi}=11945.04$ and 6456.24 are printed as $1.194\cdot10^4$ and 6456.
  * `lem:teacher:reuse`, `prop:teacher:schedules` (with the V-T §6 fixes), and `prop:teacher:frozen` ((b) for every program for ν, as in V-T §7).
  * `prop:teacher:sharp`: Lemma 5.1, Prop 5.2, and the continuity of V-T §6. `prop:teacher:rates`: the claim needs no computed constant; the readings are "iff $f_1>H$" and "$a^*=1$ iff $\psi_2(p,1)\ge H$"; the uniqueness bound for $h'$ was re-derived.
  * `rem:teacher:selected` (67.7–88.6%).
  * `rem:teacher:hanni` numbers: $1.1185\cdot10^{-6}$, $8.989\cdot10^{-3}$ and $8.94\cdot10^5$.
  * `ex:teacher:version1`: $c_{\rm hi}=5.8025$ and $2.5301\cdot10^{-3}$, λ-range $(9.77,58.0]$, $L_S=115.58$.
  * The 11,853 exceptions and the fraction $9.6\cdot10^{-24}$.
  * Table 6 against t6 and v5, with lower ends rounded up and upper ends rounded down.
* **§9 / App G.**
  * `prop:limits:envelope`(i) via Lemma (iv); (ii) re-derived, including the piecewise minimum $\min(c,2^{-m})B_2'$.
  * The $c_{\rm env}$ paragraph, with both side conditions (final-check row 17).
  * `prop:limits:rateblind`(ii) in secant form, with the two dominated cases (teacher Prop 4.2).
  * The algebra of `lem:limits:robust`, and the $d_0$ table (all 18 entries, recomputed with exact ceilings).
  * Guard-erosion rates $1.2226\cdot10^{-2}$ and $1.8103\cdot10^{-4}$; held-out losses; envelope numbers.
  * `rem:limits:hull`, and `q:limits:open` updated as planned.
* **§10 / App H.**
  * `prop:related:computable`(d) matches iid Cor 6.2 and kink §5.0. `thm:recovery:kink` is stated for the class $\mathcal C$, so (d) holds for it.
  * `rem:related:nn` is narrowed to integer code lengths with Kraft weights.
  * The H.1 rows that were updated for moved content are correct, except the last sentence (m4).
  * $c_{\rm hi}=0.01139$ at $d=20$.
* **Framing.** Each section opens with its place in the two reasons, as PLAN §7.2.1 asks. REFRAME: no running-text citation of the notes, no footnotes in scope, no "the author", no Wyeth.
