# Review FRONT: Paper 2 restructure read as a whole (front matter, framing, compliance, length, Paper 1)

Reviewer: front, 2026-10-13. Scope: the whole of Paper 2 as a reader, with weight on the abstract, introduction, related work and discussion (`abstract.tex`, `intro.tex`, `related.tex`, `discussion.tex`, `main.tex`), the two-reasons framing of every section opening, REFRAME/DECISIONS compliance, notation, length against PLAN §6 and DECISIONS §C, and Paper 1's `steeper.tex` with its companion sentences. The paper was not edited. No git command that changes repository state was run.

## 0. What was done

* **Builds.**
  * Paper 2: `flock /tmp/claude-0/paper-build-sfi.lock ./build.sh`: 0 LaTeX errors, 0 undefined references or citations, 0 multiply defined labels, 0 overfull boxes above 10 pt, **75 pages**.
  * Paper 1: the same command in `paper/`: 0 / 0 / 0 / 0 / 0, 91 pages. Then `python3 -I research/paper-review/scratch/editor/check_companion_numbers.py`: last line `ALL OK`. Its one unknown citation, "Theorem~5.1" (`absorb.tex` l. 100, `rem:absorb:wyeth`), was checked by hand: `thm:learn:dominance` is `{[theorem]…5.1}` in `paper/main.aux`, and its item (a) is the dominance of every lsc conditional semimeasure, which is what the sentence uses. "Remark~B.3 intended, not used" is informational (the hashing comparison was cut).
* **Read.** The PDF text (`pdftotext -layout`) of the whole main text (pp. 1–40) in full, and the appendices where the front matter points; the sources of the four front files and `main.tex`; PLAN.md in full; `log-front.md`, `review-math2.md` and the writer logs where they address FRONT; `REFRAME.md`; DECISIONS §0, §A, §B, §C, §D1; the synthesis §0, §2 (headlines) and §8 (statuses); `final-check.md` §1 and §4; `verify-teacher.md` §1; iid `notes-final.md` Thm 4.1 and the recovery-time table; Paper 1's `steeper.tex`, the `sec:steep` bullet of `intro.tex` and the paragraph "The companion paper" of `discussion.tex`, and their PDF text.
* **Every claim of the abstract, the three informal theorems, the contributions list, Table 1, the scope paragraph, related work and the discussion (Table 4 included)** was traced to the body statement it cites and, for the new material, to the record and its verification status.
* **Numbers recomputed independently** (mpmath, scratchpad script, nothing shared with the repository's code): $1-(63/64)^{10}=0.14571$; $p_0=0.0559643\ldots$, $p_1=0.1233073\ldots$; $H(2^{-10})=0.0111738$, the three-hypothesis window $(1.1185\cdot10^{-6},\,8.9893\cdot10^{-3})$ and the switch at $n=8.94\cdot10^5$; $L_S=11{,}710.27$; $c_{\rm hi}=8.0618\cdot10^{-3}$ (κ = 0) and $3.65897\cdot10^{-3}$ (κ = 30) at $d=100$, $m=20$, $p=2^{-10}$, $B=\infty$, with the ratios 8453 and 3837. Table 2 was compared with iid `notes-final.md` (recovery-time table, λ = 1.25 column dropped) and $2^{(k+4)/2}+6$. The $e$ bounds were compared with `teacher/checks/t6_exact_window.out` (D).
* **Greps on the PDF text:** the DECISIONS §A5 pattern plus PLAN §7.2.4's additions (synthesis, sub-track, verified, refereed, post-referee, withdrawn, corrected, iid, T1–T5, script ids, PLAN, W1–W6, FRONT); `wyeth`; citations of the author's notes; "the author"; quotation marks; reply framing ("answers", "confirms", "as proposed in", "the notes").

## 1. Verdict

The restructured paper reads as intended: **two reasons for a complexity penalty steeper than the likelihood penalty, the model–randomness split first and main, the teacher's mistakes second, as "the split at a positive rate"**. The abstract, the introduction (paragraph 2, Theorems A–C, the contributions in thread order, the section map), every section opening (§3 hull, §4 precondition, §5 common geometry, §6 "first and main reason", §7 shared instance, §8 "second reason", §9 "where the second reason fails", §10 "both reasons survive") and the discussion's Table 4 carry the same story without repeating it at length. REFRAME and DECISIONS compliance is clean (§4 below). Paper 1's summary and companion sentences match Paper 2.

I found **no fatal issue**. There are **4 major** issues and **17 minor** ones. Major issue M1 (length) needs a decision by the author; the other three are wording or number fixes of one line each in FRONT's files.

---

## 2. Major

### M1. The paper is 18 pages over the binding caps
* **Where.** Whole paper; PLAN §6, DECISIONS §C ("Hard caps: Paper 2 main text ≤ 27 pages, appendices ≤ 27 pages, total ≤ 57 pages").
* **Problem.** Measured on the 2026-10-13 build (and confirmed against `log-front.md` §4): main text (title to Code and data) **37.4 pp**, references 2.4, appendices **35.2 pp**, total **75 pp**. Every main-text part is over its PLAN budget; the largest overruns are §7 (+1.8), §8 (+1.4), §3 (+1.2), §4 (+1.15), §1 (+1.1), §6 (+1.05), App E (+2.7), App F (+1.9). FRONT's log reports the overrun but no decision has been taken.
* **Fix.** One of the two, decided by the author:
  1. **Relax the caps for the restructured paper**, which now carries two threads with four new headline results (Theorems A–D of the synthesis); a realistic target is main ≤ 32, appendices ≤ 34.
  2. **Or cut**, in this order (estimates from the PDF; each a placement change or the removal of a duplicate, no mathematics lost):
     * *Duplicates (≈ 0.9 pp main).* The Barron–Cover sentence and "we claim no novelty" appear nearly verbatim in §2 (`related.tex` l. 12) and in Remark 6.5 (`recovery.tex` l. 54): reduce Remark 6.5 to one sentence pointing to §2. The generalised-posterior sentence with its five citations appears in §2 and after Definition 3.6 (`setup.tex` l. 58): keep it in §2 only. "We do not claim as new the qualitative finding …" and the Zhu et al. descriptions appear in §2 and in Remark 8.4 (`teacher.tex` l. 44): keep them in §2. The semimeasure-convention sentence of "Conventions" repeats Definition 3.4. "What counts as one hypothesis" (§11) repeats Remark 4.7 and §4.2; "The window and its price" repeats Remark 8.4: two sentences each.
     * *Front (≈ 0.8 pp).* Table 1 rows 2, 3, 4 and 6 restate Theorems A, B, the reuse-factor sentence and Table 4: keep rows 1, 5, 7, 8 (absorption, the "vertex" question, the absolute bound, other pathologies), or move the whole table to §11 next to Table 4. Shorten the contributions bullets on exact recovery and kinks to one line each, since Theorems A and B state them.
     * *Body to appendices, with a two- to four-line pointer (≈ 6 pp main):* the statements of Lemmas 7.2–7.6 and the $F^\sharp_t$ display (keep one paragraph saying what list decoding, the risk floor, the coding lemma, (D1)/(D2) and the sharp floor give); Proposition 7.8(i)(e)–(g) and (ii); Remarks 7.11–7.12 to one sentence; Question 7.13; §8.4 (Propositions 8.12–8.13 with their definitions) to App F with a half-page summary that keeps the asymptotic threshold; Proposition 8.3(c) and Table 3; Corollary 6.9 and its paragraph; Theorem 6.12 with §6.7's tape-length paragraph (keep its one-line reading); Proposition 4.5; Remark 4.7 to five lines; §9.3; Proposition 10.3 with Question 10.5(b).
     * *Appendices (≈ 8 pp needed).* The correspondence table of App H could move to the repository README; `prop:algstat:coarse`, `rem:algstat:near1`, `q:algstat:lsc` (App E), `ex:teacher:version1` and `prop:teacher:concentration` (App F) are the base's own optional items (DECISIONS §C already listed the last two as movable).

     Even all of this leaves the main text near 29 pp, so option 1 (or 1 together with the duplicate removals) is the realistic one.

### M2. Theorem A (informal) calls the margin a bound on the "average Hellinger distance"; it bounds the average *squared* Hellinger distance
* **Where.** `intro.tex` l. 16 (Theorem A): "γ a margin, a lower bound on the average Hellinger distance to ν of the inequivalent programs".
* **Problem.** The margin of Theorem 6.3(d) is a lower bound on the Hellinger *gap* ${\Hel}_\mu(\pi)=\Ex_\mu d_{\rm H}^2$, with `\Hel` = $d_{\rm H}^2:=1-\sum_y\sqrt{PQ}$ (preamble l. 70, "squared Hellinger distance"; Definition 6.1). The informal statement prints a rate $n\ge\lambda(\ell_0+\log(2/\varepsilon))\ln2/(2\min(1,\lambda-1)\gamma)$ in terms of γ, so a reader who takes γ to be a distance gets the wrong rate, by the square root (for the parities of §6.3 the gap is 0.293, the distance 0.541: a factor 1.85 in $n$).
* **Fix.** "…and γ a margin, a lower bound on the average squared Hellinger distance (the Hellinger gap of \cref{def:split:setting}) between ν and the inequivalent programs up to a length fixed by λ, $\ell_0$ and ε".

### M3. The abstract's absorption sentence has no subject: "it absorbs all structure"
* **Where.** `abstract.tex` l. 5: "In every class containing its own universal mixture, such as Solomonoff induction and SFI with shared randomness, it absorbs all structure; no private-randomness hypothesis is universal."
* **Problem.** The only candidate antecedent of "it" in the abstract is the steeper penalty of the previous sentence. The sentence that states the precondition of both reasons therefore reads as "the steeper penalty absorbs all structure", or is unreadable. What is proved (Theorem 4.2) is that the universal mixture, taken as one hypothesis, does so under the steeper penalty.
* **Fix.** Replace "it absorbs all structure" by "that mixture, taken as one hypothesis, absorbs all structure". To stay within 1920 characters, also write "for private-randomness hypotheses" for "for hypotheses with private randomness per input", "a teacher's errors" for "a teacher's systematic errors" (the next clause says "error rule"), and "grow linearly in the sample size" for "grow linearly in the sample size $n$". Measured: 1919 characters. §7 below gives a full abstract that carries M3, m1 and m2 together (1911 characters). (PLAN §1.2's longer draft, "A universal mixture taken as one hypothesis would absorb all structure; we prove that it does in every class containing its own mixture …", is clearer but 88 characters longer.)

### M4. Two numbers of the introduction are rounded to the unsafe side
* **Where.** `intro.tex` l. 20 (Theorem C) and l. 22.
* **Problem.**
  * Theorem C says the near-optimal hypotheses give the erroneous labels "average probability **at most 0.199** (κ = 0)". The computed bound is $e\le0.1991$ (`teacher/checks/t6_exact_window.out` (D), row κ = 0, $\delta_S=0$, $c=10^{-4}$), so the printed bound is stronger than what is computed. (The same value is printed as 0.199 in Table 3, `teacher.tex` l. 108; `review-math2.md` m1 lists the table.)
  * The κ = 30 window is printed "$(9.54\cdot10^{-7},\,3.66\cdot10^{-3}]$", closed at the top. The upper end is $c_{\rm hi}=3.65897\cdot10^{-3}$ (recomputed), so the printed closed interval contains values of $c$ above $c_{\rm hi}$, where Theorem 8.6(ii) gives nothing. (Same in Remark 8.7, `teacher.tex` l. 99; math2 m1.) The κ = 0 end, $8.06\cdot10^{-3}$ against $8.0618\cdot10^{-3}$, is rounded the safe way.
  * PLAN §7.1.4 and DECISIONS §A9 require certified bounds rounded in the safe direction. In the headline informal theorem these are wrong numbers, though off by one unit in the last digit.
* **Fix.** "at most 0.200 (κ = 0) or 0.274 (κ = 30)" (0.2735 rounds up to 0.274, which is safe) and "$(9.54\cdot10^{-7},\,3.65\cdot10^{-3}]$ at κ = 30". Make the same change in Table 3 (0.200, and the other cells per math2 m1) and in Remark 8.7, so that the introduction and the body agree.

---

## 3. Minor

### m1. "With probability 1 − ε beyond a sample size" reads as a uniform-in-time statement the paper does not make
* **Where.** `abstract.tex` l. 5 ("for fixed λ > 1, with probability 1 − ε beyond a sample size depending only on λ, the program's length, a margin and ε"); compare `intro.tex` l. 16 ("with probability at least 1 − ε at every n ≥ …", which is correct).
* **Problem.** Theorem 6.3(d) is a bound for each $n$ separately. The natural reading of the abstract is "with probability 1 − ε, at all $n$ beyond …". That stronger statement is proved in the record (iid Thm 4.1(v), with $n_0$ larger by $\ln(1+1/a)/a$), but PLAN D8 left it out of the paper, so the abstract claims more than the body states.
* **Fix.** "…for fixed λ > 1, with probability at least 1 − ε at each sample size beyond one that depends only on λ, the program's length, a margin and ε." (Or state iid Thm 4.1(v) in one sentence after Theorem 6.3.)

### m2. The abstract drops "computable" from the sampler
* **Where.** `abstract.tex` l. 5: "labels drawn by a sampler with fresh coins per query, every λ-MAP is eventually a shortest program for the sampler".
* **Problem.** "A shortest program for the sampler" presupposes a program for it in the class ($\mathcal E\ne\emptyset$ in Theorem 6.3). PLAN §1.2's draft had "a computable sampler".
* **Fix.** "labels drawn by a computable sampler with fresh coins per query".

### m3. "Every λ ≥ 1 identifies ν on the queried inputs" overstates equivalence on the run
* **Where.** `intro.tex` l. 16 (Theorem A, last sentence) and Table 1 row 2 (`intro.tex` l. 41).
* **Problem.** Theorem 6.10(iv) gives that the λ-MAPs are eventually ν-*equivalent on the run*: $\sum_x d^2_{\rm H}(\nu(\cdot\mid x),\nu_\pi(\cdot\mid x))<\infty$ over the queried inputs. That is not equality with ν on the queried inputs, which is how "identifies ν on the queried inputs" reads.
* **Fix.** "and every λ ≥ 1 eventually selects programs that are indistinguishable from ν on the queried inputs (equivalent on the run)". In Table 1: "on the queried inputs every λ ≥ 1 eventually selects programs equivalent to it on the run".

### m4. Computed numbers inside the italic statement of Theorem C
* **Where.** `intro.tex` l. 20: "…at most 0.199 (κ = 0) or 0.274 (κ = 30) at $c=10^{-4}$ and the example's sizes, against 1 for a memoriser."
* **Problem.** DECISIONS §A9 keeps computed numbers out of theorem-like statements and introduces them with "a direct computation (code in the accompanying repository) gives …". The informal theorem is a plain paragraph, but it is typeset and titled as a theorem. It also uses "the example's sizes" before the next paragraph defines them.
* **Fix.** End the italic statement at "…and gives the erroneous labels far less average probability than a memoriser, for large error rules." Move the numbers into the next paragraph: "The example's sizes are … ; there the window is … , and a direct computation (code in the accompanying repository) gives, at $c=10^{-4}$, average probability at most 0.200 (κ = 0) or 0.274 (κ = 30) on the erroneous labels, against 1 for a memoriser (\cref{rem:teacher:numbers})."

### m5. "Every flip rate below 1/4" for the full table omits δ_E = O(d) and dyadic p
* **Where.** `abstract.tex` l. 5 ("for large d … at each flip rate below 1/4"), `intro.tex` l. 18 (after Theorem B) and Table 1 row 4.
* **Problem.** Proposition 7.8(iii) is for dyadic $p\in(0,\frac14)$, $m=d\to\infty$ and $\delta_E=O(d)$. "Noisy random parity" covers the randomness of $a$; the error set must also be typical.
* **Fix.** Intro: "for large $d$ and typical error sets ($\delta_E=O(d)$), every fixed λ > 1 selects 'parity plus noise' at each dyadic flip rate below 1/4". The abstract may keep its wording if "noisy random parity" is understood to make the flips random too; add "random flips" if characters allow.

### m6. "Samples have such a kink" in the abstract and after Theorem B
* **Where.** `abstract.tex` l. 5; `intro.tex` l. 18.
* **Problem.** The kink of Theorem B is a kink of a data set's (product) structure function at a $b$-sufficient program. The sample kink of Theorem 6.7 is a kink of the per-query point family $(\ell(\pi),L_n(\pi))$ at the shortest equivalent length, with the Ville deficiency, not a sufficiency slack, as the right offset. "Such a kink" is close but not literally the same object.
* **Fix.** Abstract: "per-query samples have a kink of this kind at the sampler"; intro: "With high probability a per-query sample has a kink of the same kind at the shortest equivalent program, …".

### m7. "A universal member flattens every kink" is stronger than Proposition 5.7
* **Where.** `intro.tex` l. 18 (end of the Theorem B paragraph) and l. 27 (Kinks bullet); `discussion.tex` l. 26 ("flattens every kink beyond its own length"). The proposition's own title says the same.
* **Problem.** Proposition 5.7(i) caps the steepness of a left kink at $(\alpha_{\rm r},L_{\rm r})$ with $\alpha_{\rm r}-w>\ell_U$ by $1+(\ell_U+\kappa_0)/(\alpha_{\rm r}-\ell_U)$. Kinks just beyond $\ell_U$ can still be steep; only kinks far beyond $\ell_U$ are flat. §4.1 says it correctly ("no steep change of slope far beyond $\ell_U$").
* **Fix.** "A universal member flattens every kink far beyond its own length" (intro, contributions, discussion); optionally retitle Proposition 5.7 the same way (W2's file).

### m8. Table 1, row 4 answers "Yes for product models"
* **Where.** `intro.tex` l. 43.
* **Problem.** No result says that product structure functions always have a kink at the model. What is proved is: if there is one at a sufficient program, every λ between the slopes selects near it (Corollary 5.5); per-query samples have one with high probability (Theorem 6.7); the noisy parity's full table has one (Propositions 7.7–7.8). Question 7.13 shows the general relation is open.
* **Fix.** "For per-query samples (with high probability) and for the noisy parity's full table at every flip rate below 1/4 (large $d$), yes, and then every λ between the slopes selects the model; not for set models", with `thm:recovery:kink` added to the "Where" column.

### m9. "Each ingredient of its rate necessary" omits the qualifications
* **Where.** `intro.tex` l. 28 (Exact recovery bullet).
* **Problem.** Proposition D.2 shows the margin, $1/\gamma$ (for λ ≥ 2, up to a constant and $\ell_0/\Delta$) and $1/(\lambda-1)$ (up to logarithms) necessary separately, in separate classes; the joint factor is Question 6.14(c). §6.3 says so; the bullet does not.
* **Fix.** "Theorem A, with each ingredient of its rate necessary separately, up to logarithms (\cref{…})".

### m10. Related work and Remark 6.5 drop λ_n ≥ 1, and Remark 6.5 misattributes what needs λ > 1
* **Where.** `related.tex` l. 12 ("every schedule $\lambda_n=o(n)$"); `recovery.tex` l. 54 (Remark 6.5: "every $\lambda_n=o(n)$"; "What needs λ > 1 is (c) and (d)").
* **Problem.** Theorem 6.3(a) needs $\lambda_n\ge1$; its proof uses it (the tail supermartingale). The main display of Theorem 6.3(d) holds for every λ > 0 (V-I §1.2); only the margin form needs λ > 1.
* **Fix.** "every schedule $1\le\lambda_n=o(n)$" in both places; "What needs λ > 1 is (c) and the margin form of (d)". (Remark 6.5 is W3's file; with M1's duplicate removal it shrinks to a pointer anyway.)

### m11. Table 4 lists "frozen labels" as defeating the split
* **Where.** `discussion.tex` l. 19 ("What defeats it: shared randomness; frozen labels; adaptive inputs").
* **Problem.** Frozen labels defeat *exact recovery of ν* (Proposition 6.11), not the split itself: with fixed λ > 1 the selected model is a sampler, not a fill-in, at every $n$ (Theorem 6.10(i)–(iii), Remark 6.13). Listing them next to shared randomness, which removes the split, misleads.
* **Fix.** "shared randomness; for exact recovery, frozen labels and adaptive inputs (…)".

### m12. Discussion, "Neural networks", drops the hypotheses of the transfer
* **Where.** `discussion.tex` l. 32.
* **Problem.** "Theorems 6.3 and 6.10 apply to countable discretisations" omits what Remark 10.4 states: integer code lengths with Kraft weights, and a noise model that contains the sampler.
* **Fix.** "…apply to countable discretisations with Kraft weights whose noise model contains the sampler (\cref{rem:related:nn})".

### m13. A κ = 0 number in the discussion is not marked as an illustration
* **Where.** `discussion.tex` l. 30: "makes the good model non-optimal on about a third of the window".
* **Problem.** The third is the κ = 0 value (31%); DECISIONS §A9 asks for the illustration marker. Table 1 gives both values.
* **Fix.** "…on about a third (with the machine constant set to 0, an illustration) to a quarter (κ = 30) of the window's logarithmic width".

### m14. Open problems (3) puts the lower boundary of the open range at 0.1233 instead of p_1
* **Where.** `discussion.tex` l. 39 ("a junta window at level at most 2 for $0.1233\le p<\frac14$"), echoing Question 8.14(b) (`teacher.tex` l. 180; math2 m2).
* **Problem.** On $[0.1233,\,p_1)$, $p_1=0.1233072\ldots$, Proposition 8.13 does give windows at level 1. 0.1233 is the rounded-down sufficient decimal, so as a lower boundary of the open range it is wrong.
* **Fix.** "for $p_1\le p<\frac14$" in both places ($p_1$ is defined in §7.3). The abstract's and intro's "below 0.1233" / "$p\le0.1233$" are correct as sufficient conditions and stay.

### m15. Open problems (2) describes Question 7.13 as asking for a set model "that omits the parameter"; Question 7.13 as stated does not
* **Where.** `discussion.tex` l. 38; `parity.tex` l. 156.
* **Problem.** The slack $O(\log(kn))$ of Question 7.13 is $O(d)$ in its own example ($n=2^d$, $k=d$), as large as the parameter (math2 m3). The one-line summary and the precise question then say different things.
* **Fix.** Adopt math2 m3's restatement of Question 7.13 ($K(A\mid\dom D)\le|q|+o(k)$, slack $b+o(k)$); the summary then stands.

### m16. Notation clashes in §6.3 and two definitions of "sampler"
* **Where.** `recovery.tex` l. 59 ("inputs uniform on $\{0,1\}^D$ … for $1\le m\le D$ and $w\in\{0,1\}^m$"); `absorb.tex` l. 49 against `recovery.tex` l. 17.
* **Problem.**
  * $D$ is the data set throughout (Definition 3.1); here it is an input length. $m$ is the error-rule length in §7–§9, and $w$ the kink window of §5. PLAN §4.2 asks writers to rename locally any symbol with another meaning in the notation table.
  * §4.2 defines a sampler as "a computable conditional measure … with a program $\pi_\nu$ of length $k$ in the class (Definition 6.1)", but Definition 6.1 defines it as any probability kernel and adds computability only "in $\mathcal H_\times$". The forward pointer promises the same words (PLAN §7.4, W1).
* **Fix.** In §6.3 write the input length as $q$ (or $D'$), the parity's length as $j$ and its vector as $v$, here and in App D.3. In §4.2: "A sampler is a probability kernel ν (\cref{def:split:setting}); here it is computable, with a program $\pi_\nu$ of length $k$ in the class considered."

### m17. Smaller points
* **Abstract, the main reason.** The abstract says "The first reason is the split into model and noise" but not that it is the main one, while the introduction does. Optional: "The first and main reason …".
* **Abstract, λ = 1.** "for each schedule $1\le\lambda_n=o(n)$" includes λ = 1, but only implicitly; since the first reason's limit does not need a steeper prior, saying so makes the logic of the abstract explicit: "…for each schedule $1\le\lambda_n=o(n)$, λ = 1 included; a fixed λ > 1 adds a sample size …". Check the 1920-character limit (now 1913).
* **Theorem A (informal)** is one italic paragraph of 13 lines; a break after "μ-almost everywhere." (limit) and after "sampled randomness." (rate) would make it readable without adding words.
* **Question titles.** Question 6.14's title is capitalised ("Rates, frozen labels, misspecification"); the other six are lower case.
* **Table 1, row 1.** "shared latent causes cannot be expressed" (base text): Proposition B.4 says they cost a factor $\min(\lambda,2)$; "cannot be expressed as shared randomness, and cost up to a factor $\min(\lambda,2)$" is exact.

---

## 4. Checks that passed

* **Framing.** Two reasons, split first and main: abstract, intro ¶2 ("The first, and the main one"), Theorems A, B before C, contributions in thread order, section map, every section opening as PLAN §7.2.1 asks, Table 4. The teacher is "the split at a positive rate" in §8's title, its opening and the abstract. No section repeats the framing at length.
* **Abstract, intro, discussion against the body.** Apart from M2–M4 and m1–m15, every claim is a statement of the body with its hypotheses: Theorem A ⇔ Theorem 6.3(a),(c),(d), Proposition 6.6, Theorem 6.10(iv), Proposition 6.11(a); Theorem B ⇔ Lemma 3.9(v), Corollary 5.5(b) (length, fit and $(b+(\lambda-1)w)$-sufficiency bounds checked term by term), Theorem 5.6; Theorem C ⇔ Theorem 8.6 (o)–(iv) and Proposition 8.5, with $p<0.05596<p_0$; the reuse-factor sentence ⇔ Lemma 8.2, Proposition 8.3(a) (λ_n/n → 0 learns the errors), Corollary 8.10; "$p\le0.1233$" ⇔ Proposition 8.13 (dyadic $p$, asymptotic, $\delta_S=o(2^m)$). Statuses: every new item cited by the front matter is refereed or verified (synthesis §8, V-I, V-K, V-T §1: "no item is not verified").
* **Numbers.** All recomputed numbers of the front matter match (§0), except the two roundings of M4.
* **REFRAME.** The author's notes (`hanni2026notes`, `hanni2026grokking`) are cited only in the two footnotes (`intro.tex`, `kinks.tex`) and the acknowledgements; at most five allowed. "The author" appears only in the title footnote, those footnotes and the acknowledgements. No quotation of the notes; the only quoted strings are the paper's own terms ("parity plus noise", "true parity with flip rate q", "shared class", "guarded φ"). No sentence frames a result as answering or correcting anyone; refuted strengthenings are phrased "The natural strengthening … fails" (Remarks 6.4, 6.8, 8.9). The absorption objection is "a standard objection/point", never attributed to a person.
* **DECISIONS.** §A5 grep: only "independent AI referees" (title footnote) and formula renderings ($W_1$, $c_1$, $S_1$, …). §B: `wyeth` 0 hits in the PDF. §A2: `\status`/`\src` print nothing (preamble l. 121–123); no `[proved]`-type string in the PDF. Proof ideas are labelled; no proof sketch in the main text. Computed numbers are introduced by "a direct computation (code in the accompanying repository) gives", outside statements (m4 is the exception), and κ = 0 numbers are marked (m13 is the exception). Acknowledgements and Code and data match DECISIONS §A4 with REFRAME §4's additions. Title, `pdftitle`, `core.bib` (identical in both papers) carry the new title. Abstract: 1913 characters.
* **Questions.** The discussion's open-problem list cites all seven questions of the body (`q:recovery:open`, `q:parity:open`, `q:algstat:lsc`, `q:teacher:open`, `q:limits:open`, `q:absorb:shared`, `q:related:open`); there is no conjecture or assumption environment.
* **Cross-references.** Every `\cref` of the front files resolves to the intended item (checked against the PDF numbering: e.g. Proposition D.2 = `prop:recovery:necessity`, D.4 = `prop:recovery:beyond`, D.6 = `prop:split:si`, F.1 = `prop:teacher:frozen`, F.2 = `prop:limits:plain`, E.5 = `prop:algstat:parity`, Remark A.1 = `rem:setup:hullconverse`). The emptied `split.tex`, `algstat.tex`, `app-algstat.tex` hold exactly the one comment line and are not input.

---

## 5. Length against the plan (pages; full build of 2026-10-13)

| part | PLAN budget | measured | over |
|---|---|---|---|
| title, abstract, contents | 1.25 | 1.5 | +0.25 |
| §1 Introduction | 2.25 | 3.4 | +1.1 |
| §2 Related work | 0.75 | 1.0 | +0.2 |
| §3 Setting | 2.25 | 3.5 | +1.2 |
| §4 Absorption | 2.25 | 3.4 | +1.15 |
| §5 Kinks | 2.25 | 2.6 | +0.3 |
| §6 Exact recovery | 4.75 | 5.8 | +1.05 |
| §7 Noisy parity | 2.5 | 4.3 | +1.8 |
| §8 Teacher | 4.75 | 6.1 | +1.4 |
| §9 Structured errors | 1.75 | 2.4 | +0.7 |
| §10 Computable classes | 0.5 | 1.1 | +0.6 |
| §11 Discussion etc. | 1.5 | 2.3 | +0.8 |
| **main text** | **26.75** (cap 27) | **37.4** | **+10.65** |
| appendices A–H | **27.0** (cap 27) | **35.2** | **+8.2** |
| **total** | cap 57 | **75** | **+18** |

See M1 for the fix.

---

## 6. Paper 1

* `steeper.tex`: the summary is reordered as the two reasons, the split first ("The first, and the main one"), with the exact-recovery sentence of PLAN §1.6; its only number is 0.05596 (FRONT's deviation from PLAN's 0.056 is required: V-T §9 shows $p<0.056$ is false for some dyadic rule sizes, $p_0=0.0559643\ldots$); the footnote is kept. Every sentence matches Paper 2 (absorption in SI, shared SFI and the history-aware class; the λ = 1 tie; exact recovery at a class-free rate for fixed λ > 1; Theorem 4.4; the teacher theorem with all its hypotheses; λ ∝ n; envelopes).
* The `sec:steep` bullet of `intro.tex` and the paragraph "The companion paper" of `discussion.tex` state the two reasons in one sentence each, consistently.
* No numbered environment, section, subsection, label or footnote was added or removed in the three files (counts equal to the base). Paper 1 builds clean (91 pages) and the companion check ends `ALL OK`.
* No finding.

---

## 7. A proposed abstract with M3, m1, m2 and the "main" of m17 (1911 characters of source)

The three abstract fixes together would exceed the 1920-character limit by about 30 characters; this version carries all of them and saves the difference elsewhere ("for every $1\le\lambda_n=o(n)$", "exponentially slower in that length", "a computable sampler drawing fresh coins", "a teacher's errors", "in the sample size"). Every claim keeps the hypotheses the body states.

```latex
Solomonoff function induction (SFI) predicts labels from inputs with a universal prior on random functions. We study a complexity penalty steeper than log-likelihood by a factor $\lambda>1$, for private-randomness hypotheses, and give two reasons for it. In every class containing its own universal mixture, such as Solomonoff induction and SFI with shared randomness, that mixture, taken as one hypothesis, absorbs all structure; no private-randomness hypothesis is universal. The first, main reason is the split into model and noise. With i.i.d.\ inputs and a computable sampler drawing fresh coins per query, every $\lambda$-MAP is eventually a shortest program for the sampler, for every $1\le\lambda_n=o(n)$; for fixed $\lambda>1$, with probability $1-\varepsilon$ at each $n$ beyond a bound depending only on $\lambda$, the program's length, a margin and $\varepsilon$. At $\lambda=1$ no such bound exists, and in a parity class recovery is exponentially slower in that length. On one data set, a kink of the product structure function at a sufficient program makes every $\lambda$ between $1$ and its steepness select it up to windows; samples have such a kink, and so, for large $d$, does the full table of a noisy random parity at each flip rate below $1/4$, but set models have no steep one. The second reason, the same geometry at a positive rate, is not learning a teacher's errors: an error rule is reused at many inputs, so $\lambda$ must grow linearly in the sample size. For a random parity on uniform inputs, with labels flipped at a rate below $0.05596$ on an error set of product form incompressible relative to the parity, every near-optimal hypothesis of the population objective with $\lambda/n$ in an explicit window knows the parity and, for large error rules, gives the erroneous labels far less probability than a memoriser; asymptotically, windows exist for flip rates below $0.1233$.
```
