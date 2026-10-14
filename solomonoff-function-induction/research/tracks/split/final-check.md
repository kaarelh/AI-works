# Track "split": final check of the synthesis `notes-final.md` (2026-10-13)

*A fresh final check of `notes-final.md` (this folder) against the three sub-track final records `iid/notes-final.md`, `kink/notes-final.md`, `teacher/notes-final.md` and their six referee reports. For every headline statement it checks hypotheses, constants, quantifiers and status, and that the cited proof exists and survived the referees. Mismatches were fixed in `notes-final.md` with minimal edits, listed in §2. Nothing new is proved here.*

* **Sources read.**
  * The brief `00-brief.md`, in full.
  * The synthesis `notes-final.md`, in full.
  * The sub-track final records, in full: iid (1196 lines), kink (737), teacher, §§0–5 and §7.4 (§6, the presentation plan, and §§8–9, the referee table and status table, by heading).
  * The pre-referee `notes.md` of each sub-track: statement lists, and iid's Thm 4.1, Props 4.2–5.3 in full, to tell refereed from post-referee material.
  * The referee reports' verdicts and "checked and found correct" lists: `iid/referee-A.md` (lines 20–115), `iid/referee-B.md` (lines 33–102), `kink/referee-A.md` and `kink/referee-B.md` (verdicts), `teacher/referee-A.md` (verdict and checked list).
  * Paper 2: `split.tex` (`thm:split:lambda1`, `thm:split:private`), `app-split.tex` (the hashing costs), `app-teacher.tex` (`lem:teacher:finite`), `absorb.tex` and `app-absorb.tex` (ξ_λ).
* **Status tags** as in the brief: [proved: X] (proof in record X), [computed: script], [remark].
* **Files written**, all in this folder:
  * `final-check.md` (this file);
  * `checks/fc1_independent_numbers.py` with `.out`;
  * `checks/fc2_k6_margins.py` with `.out`;
  * edits to `notes-final.md` (§2).

  The sub-track folders were not touched.

---

## 1. Verdict

* **No mathematical mismatch.** Every headline statement of the synthesis (Theorems A–D, Cor A′, the general kink lemma, §4's teacher statements, the failure map of §2.5, the status table of §8) is a statement of a sub-track record. Its cited proof exists there.
* **Statuses.** Every "refereed" item was checked against the referee reports, and every "post-referee" item against the revision notes. Two status entries were inconsistent or incomplete and are fixed (§2, rows 8 and 13).
* **The 27 edits** are of four kinds:
  * hypotheses that the synthesis dropped (11);
  * quantifiers or conclusions stated more strongly than the sub-track proves (9);
  * statuses (4);
  * wording that misreported a number or a convention (3).

  No headline claim had to be withdrawn.
* **Scripts.** Five scripts were re-run from scratch copies: iid `i7`, kink `k7`, teacher `t1` (the three chosen as most important), kink `k6` and the synthesis's own `s1`. All five outputs are byte-identical to the saved ones [computed]. Two new deterministic checks, `fc1` and `fc2`, confirm the synthesis's quoted numbers independently, and one assumption of `s1` (§3).

---

## 2. Changes made to `notes-final.md`

Each row gives the place, the old text (abridged), the new text (abridged) and the sub-track statement that requires the change.

| # | place | old | new | reason (source) |
|---|---|---|---|---|
| 1 | §0 item 4 | every λ in a certified interval selects "parity + noise", "for every flip rate below 1/4" | certified intervals "at the computed sizes", and "every fixed λ > 1 … for every flip rate below 1/4 once $d$ is large" | Certified ranges exist only for computed $(p,d,\kappa)$ (kink Prop 4.2, k7). "Every $p<1/4$" is the asymptotic Cor 4.3, for fixed λ and large $d$. |
| 2 | §0 item 6 | the window extends to every $p<0.1233$, population objective | adds "asymptotically in $m$" | teacher Prop 5.3 is a statement for $m\to\infty$. |
| 3 | §2.1, λ = 1 in $\mathcal C_k$ | bracket $(2^{(k-8)/2}-6,\ \max(32,\lceil2^{(k+1)/2}/\sqrt\varepsilon\rceil)]$ | adds "for $\varepsilon<31/32$ and even $k$" | iid Prop 5.1(b′) states the bracket under exactly these conditions. |
| 4 | §2.1, fill-ins at λ = 1 | "on data sets with distinct inputs" | adds "in $\Hcl{\times}$" | `thm:split:lambda1` is stated for $\Hcl{\times}$ (`split.tex`, line 34). |
| 5 | §2.1, Cor A′ frozen counterpart | "rB6(C) agrees in a second class" | "rB6(C) finds 0.13, 0.13, 0.08 and 0.56 in a second class, with another rate code" | The values differ from i8(D)'s 0.26–0.57 (iid Cor 6.1(vi)); only the phenomenon agrees. |
| 6 | §2.1, canonical class | "In $\Hcl{\times}$ the margin $\gamma_L$ is smaller than every computable function of $L$" | adds $Y=\{0,1\}$, a computable ν with $\nu(1\mid x)\in[\beta,1-\beta]$ for a rational β > 0, and "for all large $L$" | iid Prop 4.3's hypotheses and quantifier. |
| 7 | §2.1, what the λ = 1 MAP is | fill-in 1-MAP length in $[L(\nu;D)-\delta(D),\ \ell_0+L(\nu;D)]$ on a single data set | distinct inputs; upper end only when some $\pi_0\in E_0$ has $\nu_{\pi_0}(D)=\nu(D)$ (a.s. for sampled data, not for arbitrary $D$) | iid Prop 5.3(b) after referee A's m11. The unconditional form was the pre-referee claim. |
| 8 | §2.2 (B5), status | "[proved, refereed: kink Prop 3.5]" | "(i) refereed, (ii) post-referee (§8)" | Kink Prop 3.5(ii) was added after A3/B3 (kink §0.1). The synthesis's own §8 row B5 already said so. |
| 9 | §2.2, general form (teacher Lemma 1.1) | right line $(\tau,g)$, $g\in\mathbb R$; margin $J'_c>\dots+\epsilon$; "then for $c>\tau$" | adds τ ≥ 0 and ε ≥ 0; fixes $c>\tau$ before the margin, which is at that $c$; writes $J_c$ and notes that teacher's $J'_c$ equals $J_c$ in the data reading | teacher Lemma 1.1: (R) has τ ≥ 0 (used in the lower fit bound); (ii) has ε ≥ 0 and a margin at the given $c$. $J'_c$ was undefined in the synthesis. |
| 10 | §2.4, the instance | frozen noise at rate $p$ "is exactly this $m=d$ error set" | adds "given that exactly $pN$ inputs are flipped" | `def:teacher:instance` has $\lvert E\rvert=pN$. Bernoulli frozen noise has a binomial count. Kink §9.1 has the same imprecision. |
| 11 | §2.4 (D3) | $d\to\infty$ with $\delta_E=O(d)$ | adds "and $pN$ an integer" | kink Cor 4.3's hypothesis. |
| 12 | §2.5, row λ = cn | "exact recovery iff $c<c^*$, strict on both sides" | "exact recovery for $c<c^*$, failure for $c>c^*$; $c=c^*$ not covered" | iid Prop 3.4(a),(b); iid §7.2 says the boundary is not covered. |
| 13 | §2.5, row λ ↓ 1 | "proved; Remark 4.5 post-referee" | "proved; Remarks 4.5, 4.7 and Prop 5.1(b′) post-referee" | iid revision summary: Remark 4.7 and Prop 5.1(b′) are new after the referees. |
| 14 | §4.1, Prop 2.4 | $b_0=\Lambda_2-4-2\log d$ | adds "(teacher's $b_0$, with $2\log d$; §7.2)" | The synthesis recommends and uses kink's $b_0$ with $2\log(d+1)$ (§1, (D1)). The identity holds only in teacher's convention. |
| 15 | §4.2, FQ | "Every $\lambda_n=o(n)$ memorises it" | if the class contains a program that agrees with ν off a finite set of atoms and memorises the table there, every $\lambda_n=o(n)$ eventually rejects every program for ν (teacher Prop 3.7(b)) | Prop 3.7(b) proves that ν's programs are rejected, under the hypothesis $\pi_A\in\mathcal C$. It does not prove that the MAP is a memoriser. |
| 16 | §4.4, λ = cn for noise | "recovers iff $c<c^*$" | adds "$c=c^*$ is not covered" | As row 12. |
| 17 | §4.5, envelopes | $c_{\rm env}$ "removes $(0,c_{\rm env})$" from the near-optimal slopes | removes from $W_\epsilon$ every $c<c_{\rm env}$ with $J_e(c)+\epsilon<\Phi_2(c)$ and $\zeta(c)<H(p)-R_e$ | teacher Prop 4.1(b) needs both side conditions. |
| 18 | §4.5, rate blindness | (⋆) "says that" the memoriser's secant is at least the coin's | "implies that" | (⋆) is $s_b\ge s_c$, a comparison of bounds on the two secants (teacher Prop 4.2). |
| 19 | §4.6, status | [proved, refereed: … Props 5.2, 5.3 …] | adds "5.3 is proved given the computed constants $p^*$ and $a^*(p)$" | teacher Prop 5.3's own tag. The thresholds 0.07787 and 0.12331 are computed crossings. |
| 20 | §4.6, Prop 5.3 | "Fix a dyadic $p<1/4$ and $a>a^*(p)$" | adds $B=\infty$ | teacher Prop 5.3's hypothesis. |
| 21 | §4.6, example's sizes | window $[2^{-20},2.53\cdot10^{-3}]$; "every near-optimal hypothesis gives the erroneous labels probability at most 0.1965" | window $(2^{-20},2.53\cdot10^{-3}]$, open at $2^{-20}$; the bound 0.1965 is an average probability, at $c=6.75\cdot10^{-5}$, from (a2) | The bound depends on $c$ (teacher Remark 2.6 table and §5 table). Teacher's own remark under the table says the window is open at $2^{-20}$; teacher §0 item 6 prints it closed. |
| 22 | §6 item 1 | margin below every computable function | adds "for $Y=\{0,1\}$ and ν bounded away from 0 and 1" | As row 6. |
| 23 | §7.1, frozen noise | "In FQ every $\lambda_n=o(n)$ memorises the noise" | "eventually rejects every program for ν, when the class contains a program that memorises the noise at finitely many atoms (teacher Prop 3.7(b))" | As row 15. |
| 24 | §8, row A-λ1 | the bracket | adds "($\varepsilon<31/32$, $k$ even)" | As row 3. |
| 25 | §8, row F-cn | "exact iff $c<c^*$" | adds "($c=c^*$ not covered)" | As row 12. |
| 26 | §8, row T-3.7 | "FQ: memorised" | "FQ: every $\lambda_n=o(n)$ rejects ν's programs" | As row 15. |
| 27 | §8, row T-5 | "proved, refereed (range per referee A's M5)" | adds "Prop 5.3 given the computed constants $p^*$, $a^*(p)$" | As row 19. |

A one-paragraph item 8 was added to the synthesis's Verification log. It points to this file.

---

## 3. What was checked and found to match

Each item: the synthesis's statement, its sub-track source, and the referee status confirmed.

**Theorem A and Cor A′ (iid).**
* A(a): iid Thm 3.1. Every schedule $\lambda_n\ge1$, $\lambda_n/n\to0$, λ = 1 included; the set of MAPs equals $E_0$ eventually, a.s. The proof is in iid §3. Referee A re-derived it "for every schedule … including λ = 1" (`iid/referee-A.md`, line 27).
* A(b): iid Thm 3.2(i)–(iii), with the refutation (0.8889, 0.9412) [computed: fc1(E)]. Refereed (A, line 72).
  * The synthesis gives per-program tempered shares $2^{-\ell}/W_1$. iid states only $\Pi^\eta(E_0)\to w_1$, but the per-program form follows from the same proof ($\Lambda_n=1$ on $E$). [remark; not changed]
* A(c): iid Thm 4.1(i)–(iii), the same in `notes.md` with $\ell^*$. Refereed (A, line 76).
* A(d): the free-exponent form is iid Thm 4.1(iv′), post-referee from B's b3. The margin form, $L_\varepsilon$ and $n(\lambda,\ell_0,\gamma,\varepsilon)$ match iid Thm 4.1(iv) symbol for symbol. Refereed.
* λ > 1 rate: iid Prop 4.4(b). Its upper end uses (iv′); (iv) with $L\to\infty$ gives the same bound in $\mathcal C_k$, so the refereed status stands.
* Recovery-time table: identical to iid's §5 table and to the re-run i7(A) [computed: i7 re-run, byte-identical].
* Necessity: iid Props 4.2, 4.4(a),(b) and Remark 4.5; statuses as marked. iid Prop 4.2 holds for ε < 1 − 8.66/(λ($\ell_0$−1)). The synthesis quotes its conclusion sentence ("no sample size from $(\lambda,\ell_0,\varepsilon)$ alone"), which is how iid states it. Not changed.
* Caveats: iid Prop 7.5 (refereed, A line 107), Prop 3.3 (post-referee), Remark 7.7 (post-referee).
* Cor A′: iid Cor 6.1(i)–(v) refereed, (vi) post-referee. The values 0.2555, 0.2555, 0.2037 and 0.5661 round to the quoted 0.26, 0.26, 0.20 and 0.57. $(7/8)^{64}=1.943\cdot10^{-4}$ [computed: fc1(E)].

**Theorem B (kink §§2–3).**
* (B1)–(B4) match kink Thms 2.1, 2.2, Prop 2.3, Thm 3.2 (with τ < σ in (d) and the strictness remark), Cor 3.3 (in a hypothesis class) and Thm 3.4, word for word up to notation.
* Kink referee A: "§2 and §3. Every proof is correct", with the two hypotheses since added.
* (B5): kink Prop 3.5; the status is fixed in row 8.
* The general form: teacher Lemma 1.1. Its final form is post-referee, as marked; the hypotheses are fixed in row 9.
* Right lines and secants: teacher Def 1.4 and Lemma 1.5, post-referee.

**Theorem C (kink §5, iid §8).**
* (C1)–(C5) match kink Lemma 5.2, Thm 5.4(i)–(iii), Cor 5.7(a),(d) and iid Lemma 8.1(i)–(iv).
* The scheme (wor) existed in kink's `notes.md` (line 377), so "refereed in (wor), restated for (pq) post-referee" is correct.
* "With frozen labels … (C4)'s identification fails": kink Prop 5.10(b), counterexample 2, where π* is never a λ-MAP while the margins are positive.
* The finite-sample comparison (9.14·10⁴, 6.10·10⁴, 1.22·10⁵, 2.44·10⁵ against 9.14·10⁴, 6.10·10⁴, 1.11·10⁵, 2.10·10⁵) [computed: s1(B) re-run; independently fc1(B)].
  * s1(B) assumes γ_66 = 2.652·10⁻⁴, while k6 prints margins only up to cap 65.
  * fc2 evaluates k6's own `gamma_le` over the whole class. It gives γ_L = 2.6517·10⁻⁴ for every L from 22 to 100, and no program has a smaller positive gap [computed: fc2]. The assumption holds.

**Theorem D (kink §4).**
* (D1)–(D4) match kink Props 4.1, 4.2(i),(ii), Cor 4.3 and Prop 4.4, including $b_0$ with $2\log(d+1)$, $\Gamma^\circ_t$, $\sigma^{(t_0)}$, $C_{t_0}(\lambda)$ and $c^*$.
* The certified-range table matches kink §4(a),(c) and the re-run k7 output: (1, 11944.9]; (1, 12008.5]; (1, 9.97867·10⁶], printed as 9.979·10⁶; (1, 1.00478·10⁷]; (1, 1.589·10²⁷]; [1.00059, 6530]; [1.3422, 199.8]; (1, 6.896·10²⁶] [computed: k7 re-run, byte-identical].
* Statuses: Prop 4.2(ii) and (g) post-referee; the rest refereed (kink referee A: "§4. Correct").

**§4, the teacher thread.**
* Prop 2.1:
  * reference $(d+\kappa_g,H(p))$, $N$ = level ≥ 2, wedge with steepness $c_{\rm hi}$ and margin $G_1-H(p)$;
  * line τ = $2^{-m}$, $\ell_M=d-4-\Lambda_1$, $g=\Lambda_2/2^m\ge0$;
  * relative error 2.37·10⁻¹⁴, printed 2.4·10⁻¹⁴, over 17,411 sets [computed: t1 re-run, byte-identical].
* Props 2.3, 2.4, Remark 2.5, Remark 2.6 ((a1), (a2), 0.750 → 0.873), Lemma 3.0, Props 3.1, 3.3, 3.6, 3.7, 4.1, 4.2, Lemma 5.1, Props 5.2, 5.3: each matches its source, apart from rows 14–21.
* Referee A's checked list covers Lemma 1.1, Props 2.1, 2.3, 2.4, 3.1, 3.2, 3.3(a),(b), 4.1–4.2, Lemma 5.1 and Props 5.2, 5.3 (`teacher/referee-A.md`, lines 45–96). The synthesis marks Lemma 3.0, Props 3.6, 3.7 and Remark 2.6 post-referee, as teacher's revision summary does.
* Prop 3.6(c)'s "slack that tends to 0" is right: $\epsilon_1=A\sqrt{\ln(2/\delta)/(2n)}$ in `lem:teacher:finite` tends to 0, also with $\delta_n=n^{-2}$.
* The 68–89% of the window's log-width (§3.3 item 3) is teacher's 67.7–88.6%.

**§2.5, §2.6, §6, §7, §8.** Every row cites an existing proof or computation in the stated record. The cross-track comparisons of §7.1 were re-read in both records:
* iid Lemma 8.1(iii)'s "≥ 2" is kink's $A\ge2\ell_0$;
* the right windows agree;
* teacher §7.4(a),(b) say what §7.1 attributes to them;
* §7.3's correction to teacher Prop 2.3's "1 − 2ε" is right (kink Thm 5.4(i) holds with 1 − ε).

**Numbers quoted from Paper 2.**
* The hashing costs "32–143 bits against 5.6–8.9" are `app-split.tex` line 48: 31.9 to 142.7 bits, and 5.6 to 8.9 bits.
* The §4.7 cell "ξ_λ is one shared hypothesis" agrees with `app-absorb.tex` (b): ξ_λ is one weak function semimeasure.

**§7.3's i4 correction.** The ceilings are 4265 and 6548. i4 prints 4264 and 6547 with `{nexp:.0f}` (`iid/checks/i4_noisy_parity.py`, line 75). The other four values agree [computed: fc1(A), and s1(A) re-run].

---

## 4. Points noted, not changed

* **Sub-track wording that the synthesis no longer repeats.**
  * teacher §7.4(a) and iid §9.4(a) say that in FQ "every $\lambda_n=o(n)$ memorises the noise" or "ends at least-risk programs, which memorise $F$". The proved statement is teacher Prop 3.7(b) (rows 15, 23, 26).
  * On an infinite support with a random table no least-risk program need exist. iid's "ends at least-risk programs" cites teacher Prop 3.2(a), which is a pairwise statement. [remark]
* **teacher §0 item 6** prints the $p=1/16$ window as closed at $2^{-20}$. Its own table remark says it is open there (row 21).
* **Kink's §9.1** says frozen noise "is the $m=d$ error set" without conditioning on the number of flips (row 10).
* These are imprecisions in the sub-track records. They are not errors in any proved statement. The sub-track files were not edited, as the task requires.

---

## 5. Script re-runs

| script | what it backs in the synthesis | run time | result |
|---|---|---|---|
| `iid/checks/i7_parity_exact.py` | Theorem A's λ = 1 contrast: the exact recovery-time table, $2^{(k+4)/2}+6$, Remark 4.5 | 166 s | byte-identical; stderr empty |
| `kink/checks/k7_parity_certified.py` | Theorem D: certified λ-ranges, $b_0$, item (g), 0.01879 | 2.5 s | byte-identical; stderr empty |
| `teacher/checks/t1_kink_instances.py` | §4.1: the teacher theorem as the kink lemma with τ = $2^{-m}$; Props 2.3, 2.4 | 6.0 s | byte-identical; stderr empty |
| `kink/checks/k6_perquery.py` | Theorem C: the per-query sample kink, Cor 5.5's $n_0$ | 9.3 s | byte-identical; stderr empty |
| `checks/s1_synthesis_numbers.py` | the synthesis's own recomputations | 1.1 s | byte-identical; stderr empty |

*Method.* The `checks/` and `referee_code/` folders of the three sub-tracks, and this folder's `checks/`, were copied to the session scratchpad. Each script was run there with `PYTHONDONTWRITEBYTECODE=1 python3 -I` from its own folder, and its stdout was compared byte for byte (`cmp`) with the saved `.out`.

---

## Verification log

*Run 2026-10-13 with Python 3.11.15 on the session machine.*

1. **Re-runs** (§5). Five scripts were re-run from scratch copies. All exited with code 0, with empty stderr, and every output is byte-identical to the saved `.out`. A first attempt at i7 failed before starting, because `/usr/bin/time` is missing; it was re-run without the wrapper.
2. **New checks** (deterministic; outputs saved next to them):
   * **`checks/fc1_independent_numbers.py`** recomputes, with no code shared with s1:
     * (A) the i4 sample sizes, raw, ceiling and rounded;
     * (B) Theorem A(d) against kink Cor 5.5 at $\ell_0=19$: ratios 1.000, 1.000, 1.102, 1.161;
     * (C) $2^{(k+4)/2}+6$ inside the proved bracket for $k\in\{16,24,32,40\}$;
     * (D) Remark 4.5's lengths 38, 56, 44, 72, 78, in exact arithmetic;
     * (E) 0.1457, $1.943\cdot10^{-4}$, 0.8889, 0.9412, and 0.830 against 0.811.

     All agree with the synthesis.
   * **`checks/fc2_k6_margins.py`** executes k6's class construction (its source before part (D)'s simulations) and evaluates k6's `gamma_le` at caps 20–100. Results: γ_20 = 3.7358·10⁻³, γ_21 = 1.0128·10⁻³, and γ_L = 2.6517·10⁻⁴ for every L ≥ 22. No program in the 17,536-entry class has a positive gap below 2.652·10⁻⁴. So s1(B)'s γ_66 is right.
   * Both were run in place and then re-run from a scratch copy. The outputs are byte-identical.
3. **Proof existence.** For every statement cited in §3 above, the proof was located in the sub-track record: iid §§2–8, kink §§2–5, teacher §§1–5. Referee status was taken from the referees' "checked" lists and the records' revision summaries and response tables. No proof was re-derived beyond what §3 says.
4. **Edits** (§2). 27 edits to `notes-final.md`, plus one pointer paragraph in its Verification log. Each edit was re-read in place afterwards.
5. **Repository.** One read-only git command was run (`git status --short` on this folder); it showed that the synthesis is untracked. No git command that changes repository state was run. No `__pycache__` was created under `research/tracks/split/` (checked with `find`). Scratch copies are in the session scratchpad only.
6. **Not done.**
   * No proof was re-derived independently: this is a consistency check, not a referee report.
   * The literature statuses (Barron–Cover, Hartman–Wintner, Hoeffding, Maclaurin, Vereshchagin–Vitányi) were not re-examined.
   * The section plan (§5 of the synthesis) and its page counts were not re-checked against `main.toc`.
