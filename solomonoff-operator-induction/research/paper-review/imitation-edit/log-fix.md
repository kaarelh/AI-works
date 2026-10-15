# Paper 2: fix round after the two reviews of the imitation integration (log, 2026-10-14)

*Fixer's log. This round verifies each finding of `review-math.md` and `review-front.md` (both in this folder) and fixes the confirmed ones minimally in `paper-steeper/`. A finding that is wrong, or that needs the author's decision, is recorded with the reason. The log then gives the build, the greps and the page counts.*

* **Read first.**
  * Both reviews, in full.
  * The brief with the author's verbatim message (`research/tracks/imitation/00-brief.md`).
  * The integration log `log-integrate.md`.
  * The binding rules:
    * `REFRAME.md`, in full;
    * `DECISIONS.md` §0, §A2, §A5–§A10 and §B;
    * `restructure/DECISIONS-restructure.md`, in full.
* **Then, for verification.**
  * Paper 2 as built: `imit.tex` and `app-imit.tex` in full; `intro.tex`, `discussion.tex`, `related.tex` and `abstract.tex` in full; `teacher.tex` §8.1 (`rem:limits:schedule`, `rem:teacher:weightdecay`); `app-teacher.tex` §F.7 in full; `rem:setup:persample`; (F1)–(F5) in `app-setup.tex`.
  * `research/tracks/imitation/decay/notes-final.md`, at the AdamW and Xie–Li entries: §4.4 item 3, d2(D), d3(D3) and the bibliography row.
* **Repository.**
  * No git command that changes repository state was run. Only `git status`, `git diff` and `git diff --no-index` were used, read-only.
  * Paper 1 (`paper/`) was not edited.
  * Before any edit, the sources were backed up to the session scratchpad (`fix-backup/`).
  * The DECISIONS §A2.5 script was run on a copy that writes to the scratchpad. The tracked `status_p*.json` files are untouched (`git status` shows no change in `scratch/editor/`).
* **Files changed.**
  * `paper-steeper/sections/`: `imit.tex`, `app-imit.tex`, `intro.tex`, `discussion.tex`, `teacher.tex`, `app-teacher.tex`, `related.tex`, `setup.tex`. Each gains one `%` comment line naming the fixes it received.
  * `paper-steeper/CLAIMS.md` and `OUTLINE.md` (§3).
  * Build output: `main.pdf`, `main.aux`, the logs, `bib/all.bib`.
  * This log.

---

## 0. Outcome

* **review-math.**
  * Confirmed and fixed: M1, M2, L1, L2, L3, L4, L5, N1 and N3.
  * N4 is fixed together with front m4.
  * N2 is fixed in part: the worlds are renamed. The other clashes are left, with the reason in §1.
  * No finding was rejected as wrong.
  * No formal statement changed, except as noted: the word "iff" in a proof (M2), and one clause in a proof (L1).
* **review-front.**
  * Confirmed and fixed: M1 (the imitation result is attached to the wrong thread), m1–m9, s1 and s3.
  * Confirmed but left to the author:
    * M2, the abstract caveat: it needs a cut of a result or a cap above 1920 characters;
    * M3, the length: DECISIONS-restructure §3 forbids further moves or cuts without the author's decision.
  * No change, with reasons: m10, s2 and s4.
* **Build.**
  * 0 LaTeX errors, 0 undefined references, 0 undefined citations, 0 multiply defined labels.
  * 0 overfull boxes above 10 pt; the same two boxes below 3 pt as before.
  * 87 pages (86 before).
  * Every grep passes (§4).
  * The label set is identical to that before this round.
* **Pages.** Main text 39.76 pp (39.08 before), appendices 43.28 (42.89), total 86.66 (85.66) (§5).

---

## 1. review-math.md

| id | verdict | what was done (file; old → new) |
|---|---|---|
| M1 | **confirmed.** I checked the counterexample by hand: $m=2$, $\beta(w)=w_1$, $\rho=(\frac12,\frac12)$, $h(x,b)=b$, $\mu(\cdot\mid w)=\delta_{w_2}$. Then $P^*(\cdot\mid x)=(\frac12,\frac12)=\nu_H(\cdot\mid x)$ at $x\in\{0,1\}$: the input carries one bit about the cell and none about the coin, and no hypothesis predicts better. The repair is exact. By injectivity, $P^*(h(x,b)\mid x)$ is the conditional law of $\beta(w)$ given $x$, whose unconditional law is $\rho$ by exact type; so "information about the coin" is "$P^*\ne\nu_H$ on positive $\bar\mu$-mass", and then $R(\pi_H)-R(P^*)=\Ex_x\KL(P^*\Vert\nu_H)>0$ | `imit.tex`, paragraph after `def:imit:setting`: "when the input carries information about the cell" → "when the input carries information about the coin $\beta(w)$, that is, when $P^*\ne\nu_H$ on a set of positive $\bar\mu$-mass" |
| M2 | **confirmed.** The program's length is only bounded above, so only "if" follows. The statement of `thm:imit:main` uses only "if" | `app-imit.tex`, end of "The program with kernel $P^*$": "iff" → "if" |
| L1 | **confirmed.** (F2) needs one program that lower-semicomputes a semimeasure for every value of the condition. A table $h$ that is not injective in $b$ breaks $\sum_bq_w(b)\le1$. Well-formedness is decidable, because $(h_0,\mu)$ is a finite object: the table, rational masses, and $\rho(b)2^m$ positive integers. `lem:imit:closeness` already says "trimmed as usual" | `app-imit.tex`, proof of `lem:imit:coding`: "…is a semimeasure on $\Sigma^W$, and (F2) gives" → "…is a semimeasure on $\Sigma^W$ for every well-formed $(h_0,\mu)$, which is decidable from this finite object (put $Q:=0$ otherwise), and (F2) gives" |
| L2 | **confirmed.** `prop:teacher:nofixedprior`(ii) is "on all samples", and its counterexample is the repeated sample $h^r$. "At every $n$" can be read along the realised sequence | `teacher.tex`, `rem:teacher:weightdecay`: "gives the $cn$-MAPs at every $n$" → "gives the $cn$-MAPs on every sample" |
| L3 | **confirmed.** The decay record (§4.4 item 3; bibliography row `xie2024implicit`) states Xie and Li's result as conditional: if full-batch AdamW converges, with a non-increasing learning rate whose partial sums diverge, the limit is a KKT point of the $\ell_\infty$-constrained problem. That AdamW does converge in this toy is a computation (d2(D); d3(D3), within $10^{-4}$ of the box minimiser) | fixed together with front m9, below |
| L4 | **confirmed.** With environment-driven coins the data identify $P^*$, not $\nu_H$ (`prop:imit:limits`(a)). "Identify … behaviour" can be read as the person's behaviour | `intro.tex`, bullet "Imitation": "imitation data identify only behaviour and the data kernel" → "imitation data identify only the data kernel, not the mechanism or the split into person and environment" |
| L5 | **confirmed.** `prop:imit:cheap`(i) conditions on $\pi_H$, not on $h_0$ | `app-imit.tex`, first sentence of H.5: "given the person's model" → "given a shortest copy of the person" |
| N1 | **confirmed.** (F3) as stated in `app:setup:facts` is subadditivity; the bound is the trivial fact that a condition may be ignored | `app-imit.tex`, proof of `prop:imit:cheap`(i): "is (F3)." → "holds because a description of $\beta$ need not read $\pi_H$." |
| N2 | **confirmed; fixed in part** | The worlds $W_1,\dots,W_N$ of `prop:imit:limits`(a) clashed with the cell set $W$ of the definition the proposition cites. They are renamed $\mathcal W_1,\dots,\mathcal W_N$ in the statement and in the proof (`imit.tex`, `app-imit.tex`); $\mathcal W$ is unused elsewhere in Paper 2. **Not changed:** $a$ in $f_a$, which is the teacher's parity vector of `def:teacher:instance` in all of Paper 2; and $P^*$, $W$ inside `prop:teacher:nofixedprior` and its proof in App F, which are defined there and do not meet `sec:imit`. The reviewer marks these optional, and renaming them would touch the teacher notation used throughout |
| N3 | **confirmed** | `imit.tex`, last paragraph: "a shortest one for the behaviour" → "a shortest one for its own kernel" |
| N4 | **confirmed** (also front m4) | `intro.tex`, Scope: "…below $\frac14$, for large $d$" → "…below $\frac14$, for large $d$ and typical error sets", the wording of Theorem B in the same introduction |

---

## 2. review-front.md

| id | verdict | what was done |
|---|---|---|
| M1 | **confirmed, major.** In `sec:imit` the data are i.i.d. from $\bar\mu\otimes P^*$, and $P^*$ has a program in $\Hcl{\times}$, since it is computable from finite objects. So `thm:recovery:main`(a), with the sampler $P^*$, says that every $1\le\lambda_n=o(n)$, fixed $\lambda$ included, eventually returns a shortest program for $P^*$. When $P^*\ne\nu_H$ (M1 of review-math) that program is not a copy. In the feature case it determines $\beta$, given $h_0$ and $\mu$, by injectivity. The paper said "Imitation is one motivation for the first reason" without stating this. **One correction to the reviewer's proposed wording.** "Coins that the environment drives [are discarded] only at $\lambda\propto n$" and "a copy needs $\lambda/n$ above $2^{-m}$" claim more than is proved. When the input carries no information about the coin, $P^*=\nu_H$ and a fixed $\lambda$ works. With tied coin values, copies may win below $2^{-m}$ (H.3). Above the window, a short worse program also discards the coins. The texts below state only what is proved: what $\lambda_n=o(n)$ returns, and that the guarantee holds for $\lambda/n$ in a window | **`imit.tex` ¶1:** "Imitation is one motivation for the first reason:" → "Imitation motivates both reasons:"; "Fill-ins are rejected per query …; if the person's coins are private, …; and systems … are excluded by the private-randomness class (…)." → "If the person's coins are private, this is the first reason: no predictor gains over the person more than its length plus a Ville deficiency, however it models the environment (\cref{rem:imit:private}), and every fixed $\lambda>1$ eventually returns a shortest copy, not a fill-in (\cref{thm:recovery:main}). Systems that infer from the data which person they face are excluded by the choice of the private-randomness class, not by the data (\cref{app:imit:private})." (This includes m2.) **`imit.tex` ¶2**, after its first sentence: "The data follow the kernel $P^*$ of \cref{def:imit:setting}, so a fixed $\lambda$, or any $\lambda_n=o(n)$, eventually returns a shortest program for $P^*$ (\cref{thm:recovery:main}(a)), not a copy when $P^*$ differs from the person's kernel; in the feature case such a program encodes the coupling. The coins are reused at every input of a cell, like an error rule, and the guarantee below needs the schedule of the second reason, $\lambda/n$ above the reuse factor $2^{-m}$ (\cref{sec:teacher})." **`intro.tex` ¶2** (with m1): "…or a different system that predicts the person's answers better than the person does. If the person's coins are private this is the first reason; if the environment drives them and the input partly reveals them, it needs the schedule of the second reason below (\cref{sec:imit})." **`discussion.tex`**, last sentence of "Two reasons, one geometry": "Imitation needs both: a person with private coins is eventually recovered at every fixed $\lambda>1$; when the environment drives the coins and the input partly reveals them, every $\lambda_n=o(n)$ eventually returns a program for the data kernel instead, and near-copies are guaranteed for $\lambda/n$ in a window (\cref{sec:imit})." **`tab:intro:claims`**, imitation row (the reviewer's optional item): "In part: near-copies," → "In part: near-copies for $\lambda/n$ in a window," |
| M2 | **confirmed in substance; left to the author.** The abstract has no caveat and does not mention imitation. It is truthful: every claim in it is a precise toy statement with its hypotheses. The caveat the author asked for is in the introduction (Scope, now sharper by m4, m5) and in the discussion. The author's message also says no change is needed where the caveats already exist. The abstract is the exact text of DECISIONS-restructure D9, at 1920 characters. That is also arXiv's limit for the abstract field, so "raising the cap" means the arXiv abstract differs from the paper's. Any caveat therefore costs a result claim: the reviewer's cuts remove the examples of absorption (SI, shared randomness) and the asymptotic flip rate 0.1233. This is a trade between two of the author's own priorities, so it is not made here | No change (`abstract.tex` byte-identical, 1920 characters). Ready to apply if the author agrees: append " These are toy cases of imitation and of learning from a fallible teacher; we offer tools, not solutions." (105 characters), and cut ", such as Solomonoff induction and SFI with shared randomness," (62) and "; asymptotically, windows exist for flip rates below $0.1233$" (61). This gives 1902 characters, inside the cap |
| M3 | **confirmed; left to the author.** DECISIONS-restructure §3: "No further content is moved or removed without the author's decision". The reviewer's §7 trims are all moves or cuts | No move or cut. This round adds 0.68 pp of main text, because M1, m5 and m7 add text (§5). The reviewer's trim list (§7 of review-front: about 1.1–1.4 pp of main text, 0.3 pp of appendix) and `log-integrate.md` §7 remain the candidates |
| m1 | **confirmed.** What `thm:imit:main` excludes in its window is a system that predicts *better*. One with the same behaviour cannot be told apart (gap (1); `prop:imit:limits`(a)). The author's "ideal theorem" is also about systems that are "better at prediction" | `intro.tex` ¶2, see M1 |
| m2 | **confirmed.** App H.1 says "by construction …, not because of anything in the data" | `imit.tex` ¶1, see M1 |
| m3 | **confirmed.** `prop:imit:cheap`(i) is a proved negative: under its condition some non-copy is at least as good as every copy at every $c$ | `imit.tex` ¶2: "We do not show that a copy itself is selected, that the selected program computes as the person does, or recovery when the environment's influence has a short description (\cref{prop:imit:cheap})" → "We do not show that a copy itself is selected or that the selected program computes as the person does, and a coupling with a short description defeats every $\lambda/n$ (\cref{prop:imit:cheap})". "Defeats" is the shorthand already used in §10 and accepted by final-check §5 note 4, with the precise condition in the proposition |
| m4 | **confirmed.** The condition of §10 is $\ell_0+\lvert\Sigma\rvert m+\delta_\beta\ll2^mH(\rho)$, plus $c$ in a window. For the parity person ($H(\rho)=0.0112$) "many more cells than bits" is not enough for an informative bound at $c=10^{-4}$ (App H.3) | `intro.tex`, Scope. Fourth case: "and, up to near-copies, a sampler whose coins are an incompressible function of the environment on many more cells than it has bits" → "and, up to near-copies and for $\lambda/n$ in a window, a sampler whose coins are an incompressible function of the environment, with far more entropy summed over the cells than the sampler has bits". Second case: see N4. The bullet and the table row keep the short form, as the reviewer allows |
| m5 | **confirmed** | `intro.tex`: the paragraph "Scope and reader's guide" is split into "Scope" and "Reader's guide" (the guide begins at "After related work"). No label is involved; the old name occurred only in comments, `CLAIMS.md` and `OUTLINE.md`, which are updated. Three open problems are named: "…and the conceptual problems listed in \cref{sec:discussion} remain open." → "…and conceptual problems remain open (\cref{sec:discussion}), among them that imitation data identify behaviour, not mechanism, and settle neither which structure belongs to the person nor the complexity weight." (gaps (1), (2)). The reviewer's third item, "realistic errors have structure", is already the first half of the same sentence, so it is not repeated |
| m6 | **confirmed** (all three duplicates are in adjacent paragraphs) | `discussion.tex`. **"The window and its price":** the 74-word sentence is split after "so $\lambda$ must grow linearly with $n$". The paragraph keeps the **three sentences** that DECISIONS-restructure §3 binds, unlike the reviewer's proposal: its second and third sentences are joined instead ("The learner with $\lambda=cn$ is deliberately inconsistent for the teacher's labels, at the price stated in \cref{rem:limits:schedule}, which imitation data cannot justify, because strictly proper scores prefer the teacher's channel, errors included (\cref{prop:limits:noident})."). **Gap (2):** ": strictly proper scores prefer the teacher's channel (\cref{prop:limits:noident})," → " (\cref{prop:limits:noident}, above):". **Gap (3):** "cheap error rules and cheap couplings defeat every $c$, selection sorts components by rate rather than validity, and …" → "like the cheap error rules above, cheap couplings defeat every $c$, and …"; its citations become `prop:imit:cheap`, `prop:imit:limits`. Rate against validity, rate blindness and `prop:limits:separable` stay in "The gap to realistic errors" directly above |
| m7 | **confirmed.** App F.7: a point $\theta\ne0$ is stationary for $L+\frac\omega2\|\theta\|^2$ at one value of $\omega$ at most when $L$ is differentiable, so a nonzero minimiser changes with every $\omega$. Ex. F.7: the classifier is constant on $\omega$-intervals | `teacher.tex`, `rem:teacher:weightdecay`, after "The analogy is one of objectives.": "Unlike a vertex of the hull, a nonzero minimiser of $L+\frac\omega2\|\theta\|^2$ with $L$ differentiable changes with every $\omega$, so the analogue of a window is a range of $\omega$ with one classifier, not with one hypothesis (\cref{app:teacher:weightdecay})." |
| m8 | **confirmed.** λ named the decoupled AdamW/SGDW coefficient in the subsection titled "λ = cn and weight decay". The decay record itself writes it $\lambda_W$ | `app-teacher.tex` §F.7: renamed $\omega_{\rm d}$ in the SGDW sentence, the AdamW sentences of `ex:teacher:weightdecay` and the box part of its proof idea (8 occurrences). The only λ left in §F.7 is the complexity weight. No label is affected |
| m9 | **confirmed** (= math L3) | `ex:teacher:weightdecay`: "Full-batch AdamW with decoupled coefficient $\lambda$ ends near the minimiser of $L$ under $\|\theta\|_\infty\le1/\lambda$ \citep{xie2024implicit}, whose error rate is $q$ exactly when $\lambda\ge…$" → "If full-batch AdamW with decoupled coefficient $\omega_{\rm d}$ converges, under a non-increasing learning rate with divergent partial sums, its limit is a KKT point of $L$ under $\|\theta\|_\infty\le1/\omega_{\rm d}$ \citep{xie2024implicit}, here the minimiser of $L$ on this box, as $L$ is convex; in the same computation AdamW ends near it. That minimiser has error rate $q$ exactly when $\omega_{\rm d}\ge…$". $L$ is the logistic loss, convex in θ. With four input points spanning $\mathbb R^2$ it is strictly convex, so the KKT point on the box is its unique minimiser there. "In the same computation" refers to the "direct computation (code in the accompanying repository)" two sentences earlier (d2(D), d3(D3)), as DECISIONS §A9 requires. The thresholds are unchanged |
| m10 | **not changed.** DECISIONS §A10 requires the collected list to cite every `question` environment of the body, and it does. It does not require every item to cite one. Item (7) states its five questions precisely itself. A new `question` environment would add a numbered environment and length to a paper over its caps; the reviewer offers "accept (7) as written" | – |
| s1 | **accepted** | `related.tex`, Novelty: "and our tools (dominance bounds, …)" → "and the proof techniques we use (dominance bounds, …)". This avoids reading "our" as a novelty claim |
| s2 | **not changed.** The bullet "Limits and computable classes (Sections 9 and 11)" spans §9 and §11, so no position of the imitation bullet (§10) is in section order without splitting it, which adds a line | – |
| s3 | **accepted** (it supports the author's first request) | `discussion.tex`, `tab:discussion:reasons` row "What the learner is": "a family of batch objectives (\cref{rem:setup:persample})" → "a family of batch objectives, not a fixed prior (\cref{rem:setup:persample,prop:teacher:nofixedprior})". `setup.tex`, end of `rem:setup:persample`: "…\emph{batch} statements at a given $n$." → "…\emph{batch} statements at a given $n$, and in $\Hcl{\times}$ no fixed prior with full support gives the $cn$-MAPs on every sample (\cref{prop:teacher:nofixedprior})". "In $\Hcl{\times}$" is needed: in a one-program class every prior gives the $cn$-MAPs, and the proposition's last clause supplies the samples in $\Hcl{\times}$ |
| s4 | **not changed.** Moving `rem:teacher:weightdecay` to the end of §8.3 renumbers the environments of §8 (REFRAME §8: in Paper 2 numbering changes only where necessary), and shortening it is a cut (M3). Its position after `rem:limits:schedule`, the remark on λ ∝ n, is where its subject is. Left to the author with the length decision | – |

Not findings, but recorded: the reviewer's §8 point 4 (the reading of "as the number of params varies") and points 5–6 (novelty, Armstrong–Mindermann) are for the author, as in `log-integrate.md` §9.

---

## 3. Planning files

* **`CLAIMS.md`.**
  * Two occurrences of `H(\rho)` in the §1 imitation paragraph had lost `\r` to a carriage return, written by an earlier script and printing as "H(ho)". They are restored. The file now contains no `\r`.
  * "cn-MAPs at every n" → "on every sample", twice (L2).
  * The §1 imitation paragraph and the §3 imitation answer gain the private/environment-driven distinction (front M1).
  * "Scope and reader's guide" → paragraph "Scope".
  * The ledger is unchanged, since no numbered environment was added, removed or moved.
* **`OUTLINE.md`.**
  * The story now calls imitation a motivation for both reasons, with the distinction of front M1.
  * The paragraph names are updated.
  * A line with the post-fix page counts is added.
  * The stale pointer "`log-integrate.md` §5" for the trim candidates is corrected to §7.

---

## 4. Build and checks

* **Isolated builds** (`./test-section.sh`): `imit app-imit` (7 pp), `teacher app-teacher` (16), `intro` (4), `discussion` (4), `related` (3), `setup app-setup` (6). All OK, with 0 undefined citations; the undefined references are cross-section, as expected.
* **Full build.** `flock /tmp/claude-0/paper-build-sfi.lock ./build.sh`, run twice; the second run is on the final sources. It gives:
  * 0 LaTeX errors;
  * 0 undefined references and 0 undefined citations;
  * 0 multiply defined labels;
  * 0 overfull boxes above 10 pt (the two boxes of 1.84 pt and 2.75 pt are those of before);
  * 87 pages;
  * no "??" in the PDF text.
* **The changed passages** were read in `pdftotext main.pdf`: §10 opening, the paragraph after `def:imit:setting`, Scope and Reader's guide, "Two reasons, one geometry", "The window and its price", the weight-decay remark, Ex. F.7, H.4 and H.5. They print as intended.
* **DECISIONS §A5** (the vocabulary grep on the PDF text):
  * The word hits are the title footnote's "independent AI referees".
  * The remaining hits are formula fragments: $h_0$, $h_1$ in the proof of Lemma 7.2, and 146 lines matching $c_1$, $s_0$, $E_0$, $r_0$, …, of the same kinds as before. The changed text adds none ($\omega_{\rm d}$ prints as "ωd").
* **DECISIONS §A2.5.**
  * The status grep on the PDF returns 0 hits.
  * `extract_status.py`, run on a scratch copy, gives the same counts as after the integration: Paper 2 has 107 `\status` calls, and the 7 calls "outside an environment" are the body's `question` environments, which the script's environment list omits.
  * A separate script checked every theorem-like environment of `imit.tex`, `app-imit.tex`, `teacher.tex`, `app-teacher.tex` and `setup.tex`: all carry `\status` and `\src`, and the definitions carry `\src` only.
* **DECISIONS §B.6.** "Wyeth" occurs 0 times in the PDF and 0 times in the sources outside comments and the label.
* **REFRAME.**
  * "The author" and the author's notes appear in the PDF only in the title footnote, the proposal footnote, the existing §5 footnote, the acknowledgements and the bibliography, as before.
  * No "alien", "synthesis" or "sub-track" appears.
  * The new text is impersonal or "we".
* **Restructure FRONT strings** (DECISIONS-restructure §4.7). None of the forbidden strings occurs in the PDF. In the sources the only hit is "0.545" in the switched-off `app-verification.tex`, as before. `0.1233\le p` does not occur, and "(o) Level bounds" appears once.
* **Labels.** The sorted `\label` sets of `sections/*.tex` before and after this round are identical (249). No label was added, removed or renamed.
* **Companion check.** `check_companion_numbers.py` ends with "ALL OK". No citation of Paper 1 was touched.
* **Abstract.** Byte-identical, 1920 characters.
* **SHA-256 prefixes.**

  | file | prefix |
  |---|---|
  | `main.pdf` | `4b3df9749519ab5f` |
  | `sections/imit.tex` | `9ab0945b061a9eca` |
  | `sections/app-imit.tex` | `bbf477faa2bc61f7` |

---

## 5. Pages

**Method.** Text-block pages between heading positions, from `pdftotext -bbox`, with the method and script of `log-integrate.md` §7.

| part | after the integration | after this round | change |
|---|---|---|---|
| §1 Introduction | 3.80 | 3.97 | +0.17 (M1, m1, m4, m5) |
| §2 Related work | 1.36 | 1.44 | +0.08 (s1 adds a few words; layout) |
| §8 Teacher | 6.04 | 6.11 | +0.07 (m7) |
| §10 Imitation | 2.33 | 2.44 | +0.11 (M1, m3) |
| §12 Discussion etc. | 2.80 | 2.84 | +0.04 (M1 sentence; m6 saves about as much) |
| **main text** | **39.08** | **39.76** | **+0.68** |
| references | 3.69 | 3.63 | −0.06 |
| App F | 9.33 | 9.33 | 0 |
| App H | 3.99 | 4.11 | +0.12 (L1, L5, N1) |
| App I | 1.99 | 2.21 | +0.22 (`app-related.tex` is unchanged; the float of its correspondence table now sits on the last page, p. 87) |
| **appendices** | **42.89** | **43.28** | **+0.39** |
| **total** | **85.66** (86 pages) | **86.66** (87 pages) | **+1.00** |

The remaining sections move by less than 0.1 pp, from page breaks.

All three caps of DECISIONS-restructure §3 remain exceeded:
* main text by 6.26 pp;
* appendices by 5.78 pp;
* total by 13.16 pp.

As that section requires, nothing was moved or cut; see M3.

---

## 6. Points for the author

1. **The abstract (front M2).** Add the caveat with the two cuts of §2, or leave the abstract as it is. Both are consistent with your message: the caveats are now explicit in the introduction (Scope) and in the discussion (six gaps).
2. **Length (front M3).** The paper is now 87 pages against the earlier cap of 73.5. The candidates are those of review-front §7 and `log-integrate.md` §7, plus moving `rem:teacher:weightdecay` (s4).
3. **Imitation and the two threads.** The framing now says what the results support:
   * with private coins, imitation is the first reason;
   * with coins that the environment drives and the input partly reveals, every $\lambda_n=o(n)$ returns a program for the data kernel, which in the feature case encodes the coupling. That is your "sampler with some bits specified". Near-copies are guaranteed only for $\lambda/n$ in a window, as for the teacher.

   The reviewer's stronger phrasing ("coins … only at $\lambda\propto n$", "a copy needs $\lambda/n$ above $2^{-m}$") is not proved, for the reasons in §2 (M1), and was not used.
4. **Notation left as is** (math N2): $a$ in $f_a$ against $c=a2^{-m}$ in §10, and $P^*$, $W$ inside the proof of `prop:teacher:nofixedprior`. Rename them if they bother a reader.

---

## Verification log

* **2026-10-14, reading.** As listed in the header. Every finding was checked against the sources it names before any edit.
* **Hand checks.**
  * The counterexample of math M1, and the equivalence "information about the coin ⇔ $P^*\ne\nu_H$ on positive mass".
  * The "if" of math M2.
  * The decidability claim of L1.
  * The application of `thm:recovery:main`(a) to the sampler $P^*$ (front M1): i.i.d. inputs from $\bar\mu$; $P^*$ computable from finite objects, so in $\Hcl{\times}$.
  * The single-ω stationarity behind m7.
  * Convexity, and strict convexity, of the logistic loss in Ex. F.7 for m9.
  * The class restriction of the new sentence in `rem:setup:persample` (s3).
* **Edits.**
  * Exact-string replacements, each asserted unique.
  * The comment lines were added by a script that asserts the position.
  * The final diff against `fix-backup/` (word level) shows only the changes of §1–§2 and the comment lines.
* **Builds.**
  * Six isolated builds.
  * Two full builds under the lock.
  * One further isolated build of `discussion` after its last edit.
* **Scripts** (session scratchpad only):
  * `integrate/measure.py`, the page measurement;
  * `editor-copy/extract_status.py`, a copy that writes to the scratchpad;
  * an inline status/src checker;
  * the label diff.
* **Not done.**
  * No new mathematics: every changed sentence restates a proved result or narrows a claim.
  * No WebSearch: the Xie–Li wording follows the decay record's verified abstract-level entry.
  * No change to Paper 1, to the research records or to shared root files.
