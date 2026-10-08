# Readability and answer-quality review

**Paper:** `paper/main.pdf`, built 2026-10-08 16:22, 122 pp.; sources in `paper/sections/*.tex`.
**Read as:** the user who asked the question, Kaarel Hänni (`research/00-brief.md`). He is mathematically and philosophically literate. He wants to know whether his idea works, in what form, and why.
**Other reviews in this folder:** mathematics (`review-math-A.md`, `review-math-B.md`) and consistency (`review-consistency.md`). Their findings are not repeated here; they are cited by id (C-xx, MA-xx, MB-xx) where they bear on readability. In particular, the short answer proposed in §1.1 uses the qualified wording that C-01, C-03, C-04, C-05 and MB-01 require.

**Scratch files** (`research/paper-review/scratch/`):

* `r_blocks.py` and `r_blocks.out`: the printed length of every block (theorem-like environment, table, paragraph group) of each main section. Estimates are calibrated on the measured page span of that section.
* `r_build/`: a copy of the sources with the typography fixes of §4 applied, and its build script and logs. The paper itself was not touched.
* `r_preamble_fix.diff`: the tested changes.
* `r_example_numbers.py` and `.out`: the numbers for the page-1 example.
* `r_make_issues.py`: generates `issues-readability.json` and the numbered list at the end of this file.

**Measurements**

* Main text: p.5.1 to p.61.1, which is **56.0 pages**. By section: intro 4.7, model 6.5, universal 7.9, ident 6.5, sound 5.9, time 5.9, pa 8.4, experiments 6.6, discussion 3.7.
* Front matter: title and abstract on p.1, then a 3-page table of contents. The main text starts on p.5.
* Appendices: pp.63–122, about 60 pages.
* 169 grey `\src` superscripts in the main text (184 in all).
* 54 cross-references in the nine answers of §1.3, which run to about 900 words.
* No figures.

---

## Verdict in brief

**The answers are in the paper, and the nine bold headlines of §1.3 nearly make a good summary.** The user still has to work too hard to get them:

* **They come late.** The first answer starts on p.6, after 1.1 pages that summarise his own notes back to him.
* **They follow the research tracks, not his question.** A6 (the verifier) sits between the ∀xφ answers and his three refinements. His last bullet (the actual axioms; something equivalent; at least a lot of posterior mass) is answered in pieces across A4, A5 and A9.
* **The qualifications are hard to read.** Each headline is followed by about six cross-references and symbols the intro has not defined.
* **The key fact is never shown with a number.** The fact that makes the main result intuitive is this: a generator whose axiom is ∀xφ mostly outputs ∀xφ itself, so instance-only data count against it.

**Length.** The main text is 56 pages against a plan of about 40. About 7 pages are duplicated:

* each experiment is told two or three times;
* his note is summarised five times;
* refuted first-version claims appear both in the text and in App. H;
* the good version is given twice, the MDL finding three times, and the collapse summary three times.

Another 8 pages are technical statements that the appendix can carry with one-line pointers, and tightening saves about 3 more. The cut list in §2 reaches about 38.5 pages, leaving room for the added short answer and running example within 40, and drops no result or caveat.

**Structure.** Four problems stand out:

* §2 is a 6.5-page catalogue (8 calculi, about 12 likelihoods) with forward references.
* Sections 3 and 6 state their answer at the end.
* His trichotomy is filed under "Soundness of the thresholded verifier", after it has already been used in §3.
* Process vocabulary is everywhere ("track pa's", "referee m9", "the brief's H6"), and the notation is overloaded: α, c, q, ρ, L, R and K each have three to eight meanings.

**Typography.** The `\src` superscripts are unbreakable boxes. Three sections and one appendix push 78 of them to the start of a line by a hack. `\status` is italic in theorem heads and upright elsewhere. The table of contents runs to 3 pages, and one table is 81 pt too wide. A five-line preamble change plus two table fixes, tested in a scratch build, takes the overfull boxes from 9 to 1, removes the dangling superscripts, and starts the main text on p.3.

Counts: **1 fatal, 25 major, 19 minor**. The full list is at the end.

---

## 1. Does the paper answer the question clearly and early?

### 1.1 The ten-line answer I would want on page 1

Place this as a boxed "Short answer" directly after the verbatim question. The numbers are the paper's own: tab:univ:odds, tab:univ:share, tab:pa:theorems, and `scratch/r_example_numbers.out`.

> 1. **There is a coherent version.** The prior is 2^(−code length) over finite sets of schemas (templates such as φ(z) or induction). The likelihood is the probability that a random derivation process (cite an axiom, fill in its schematic variables at random, apply MP, Gen and ∀-elimination) outputs the datum, divided by a normaliser that does not depend on the data.
> 2. **The normaliser is the key ingredient.** Because of it, a theory pays for the probability it spends on sentences that are never observed. Your "prove the givens" and "do not contradict" scores lack this, so a consistent strengthening never loses its prior odds.
> 3. **From φ(t) to ∀xφ.** Instances push mass off memorisers and off over-general schemas. They do not favour ∀xφ over the schema φ(z), which is just as simple and implies exactly the data.
> 4. **A derivation likelihood even favours φ(z).** A generator whose axiom is ∀xφ mostly outputs ∀xφ itself: 77% of its output at ∀-elimination rate 0.3. So each observed instance costs it a factor of 0.23. (This is proved in the simplest calculus. With learned weights there is a bounded exception, and with ∧-detours the question is open.)
> 5. **So prediction is confirmed but derivability is not.** "All future data are instances" gets posterior probability → 1. "The axioms prove ∀xφ" stays at its prior share (3–48% for 0+x=x, depending on the code) or goes to 0 (for data drawn from the model). One instance at a free parameter, φ(p), or one quantified datum that entails ∀xφ, does license it.
> 6. **If the data are drawn from some theory's law** (fixed weights, or almost every learned weight vector), the posterior finds the right theorems, that is, a deductively equivalent system. It does not find the particular axioms: among theories with the same law, the prior decides.
> 7. **Human-stated theorems are not such data.** The posterior then goes to the best-fitting generator (proved for finite classes), which can be strictly weaker than the axioms behind the data, or unsound. For PA it finds the axioms that are *used*. PA-equivalents win only on direct axiom-use data, and only within the candidates that were scored.
> 8. **"Statements given without proof should be easily derivable"** turns short theorems with long proofs, and frequently used lemmas, into axioms. Under a two-part code, memorising such a theorem is 6–24 times cheaper than deriving it.
> 9. **A time penalty on checking or generating axioms does not stop your collapse.** Templates block your schema, but over PA one reflection sentence still carries the collapse for sound assigners. What does charge for it is derivation length in written symbols (a proved lower bound).
> 10. **For the trichotomy, keep (belief, plausibility).** Renormalising and 50/50 are incoherent in general. Positive results need data drawn from the model. AI referees checked the track notes; no human has checked the mathematics.

### 1.2 How the intro differs

The intro does three things well, and these should stay:

* it quotes the question verbatim;
* its bold headlines are accurate;
* its "What is not achieved" list (l.98–104) is honest and specific.

The differences, in the order a reader meets them:

* **D1. Position.** Page 5 contains the quote, a framing sentence and nearly all of §1.1, which retells Hänni's note to its author. §1.2 then packs about ten defined notions into one paragraph: DT°, metavariables, Q, L0, L1, normaliser, size principle, L1^σ, L1^sel, L1^sel_cit. Answer A1 begins in the lower half of p.6. Only the abstract answers early, and it is dense (R-01, R-10).
* **D2. Order.** The answers run in the order of the research tracks. The user's order is: the ∀xφ case; then a good version with templates, a derivation-length prior and a time penalty; then whether it robustly finds the axioms, or an equivalent system, or at least gives them a lot of mass.
  * A6, the verifier, is something he did not ask about. It comes before A7 and A8, which answer what he did ask.
  * Templates, his first refinement, get no headline of their own (R-02).
* **D3. The three-tier last bullet is answered in pieces.** The pieces are in A4 (equivalent system, prior share of the actual axioms), A5 (not robust), A9 (errors positive data cannot correct) and §7.7.1 (PA mass within candidate sets). A 3×2 table answers it at a glance. Its rows are "actual axioms / equivalent theorems / much mass" and its columns are "data drawn from the model / human-stated theorems" (R-02).
* **D4. The intuition is missing.** A2 says "∀xφ spends probability on outputs never observed" but never says that the output is mostly ∀xφ itself. It gives no number: 0.77 versus 0.23 per instance at c = 0.3 (R-03). There is no example and no figure. The appendix table tab:univ:c2 tells the whole story in five rows (R-04).
* **D5. Density.** There are 54 cross-references in about 900 words. The answers use, undefined in the intro: C_min, "citation with the closure reading", L1^sel, "parameters admissible", "spare slot", "root split", "the MDL finding of AS", "Gold's limit point", C*_d, "motive", "guard" and "hard assigner" (R-06). The blanket sentence "each answer holds within the hypotheses of the results it points to" (l.48) leaves the reader to find the hypotheses (R-11).
* **D6. "A good version exists" (A1) does not state the version.** The recipe appears for ∀xφ in §3.9 (p.23) and in general in §9.2 (p.58) (R-07).
* **D7. Table 1 grades the hypotheses of an internal research brief, not Hänni's.** "Refutes the brief's H6" recurs ten times in the paper (R-05).
* **D8. Some of the answers' statements need scope.** The scope corrections of the other reviewers (C-01, C-03, C-04, C-05, MB-01) should go into the answers. So should one found here: A8's "the MAP is strictly weaker than PA" is a two-candidate computation (R-09).

---

## 2. Length: a cut list from 56 to about 40 pages

Rules used:

* **Delete** only material that is duplicated elsewhere in the main text or in App. H.
* **Move** a result statement to the appendix only with a one-line pointer that names it and gives its conclusion, and keep every caveat.
* **Tighten** means the same content in fewer words.

The estimates come from `scratch/r_blocks.out`, using the source size per printed page fitted for each section.

| § | now | target | delete (duplicated) | move to appendix, with a pointer | tighten | ≈ after |
|---|---|---|---|---|---|---|
| 1 intro | 4.7 | 3.0 | quotations of the collapse argument in §1.1 (0.7); Table 1 → App. H (0.55) | — | the model paragraph; contributions merged into the guide; answers at ≤2 refs each (0.6); add the short answer (+0.3) | 3.1 |
| 2 model | 6.5 | 4.5 | refuted part of rem:model:graded and rem:model:subcrit (0.25) | tab:model:calculi (0.5); lem:model:a4 with proof (0.2); Elias-γ details of def:model:prior (0.12); lem:model:grammar (a)(b)(d) (0.12); four items of def:model:variants (L1^sch/L1^naive, L1^sel_cit with rem:model:sel, L_ε, L1^eq), with P^η defined where it is used in Prop 3.5 (0.25); prop:model:max (0.17) | rem:model:priors (0.15); cost paragraph; AS recap in §2.1 (0.15) | 4.6 |
| 3 universal | 7.9 | 6.0 | re-quote in the opening (0.1); E1 sentence l.96 (0.07); rem:univ:mdl merged into rem:ident:mdl (0.18) | check-script defaults l.17 (0.12); prop:univ:overspec (0.1); rem:univ:B2cit (0.08); prop:univ:rkrate with the waste paragraph (0.13); lem:univ:survivors and rem:univ:kreisel (0.18); proof of cor:univ:sound (0.18) | merge factorisation, odds theorem and table (0.15); shorten detour, hutter, openrefuted, the c8 paragraph, eqfrag paragraph, §3.8 (0.6) | 6.0 |
| 4 ident | 6.5 | 4.7 | rem:ident:e8 (0.13); rem:ident:e3a (0.12); E6 sentence of rem:ident:splitsL1 (0.05); rem:ident:exact → App. H (0.1) | prop:ident:rates (0.18); rem:ident:x5 → §8 (0.08); prop:ident:spare (d1)(d2) (0.1); ex:ident:lonedq, conj:ident:cder, rem:ident:fullclass (0.38); prop:ident:proofs and rem:ident:nearmiss (0.33) | rem:ident:sparetotal (0.1); tab:ident:misspec "where" column (0.08) | 4.85 |
| 5 sound | 5.9 | 4.0 | §5.5: rem:sound:e4, rem:sound:lumps and the text between (0.6); refuted sentences of rem:sound:hyp and rem:sound:vacuous (0.12); "Hänni's three questions" merged into the examples (0.2) | rem:sound:tight (0.13); truncation and computable-verifier part of rem:sound:hyp (0.08); prop:sound:cautious (c)(d) (0.12); lem:sound:regret (b)(d) (0.1); pool version of thm:sound:avg (0.07) | opening, text after Thm 5.2, rem:sound:indep, rem:sound:belc (0.3) | 4.2 |
| 6 time | 5.9 | 4.0 | quotations in the opening (0.25); rem:time:e7 (0.1); rem:time:links (iii) (0.08); rem:time:upper folded into the summary (0.08) | rem:time:convention (0.13); lem:time:symexp, prop:time:codelength, thm:time:log with proofs (0.4); cor:time:hard (b) (0.07); counterexample details of prop:time:lonesize (0.12); conj:time:polytime → §9.5 (0.12) | text after prop:time:cheap (0.1); rem:time:links (0.15); summary moved to the front (0.1) | 4.2 |
| 7 pa | 8.4 | 5.8 | rem:pa:e6 (0.11); rem:pa:e3b (0.14); rem:pa:e2 (0.15); prop:pa:spare, a duplicate of prop:ident:spare(a) (0.08); prop:pa:refl, a duplicate of the last sentence of prop:time:notemplate (0.07); the unlabelled "constant margin" remark (0.08); last sentence of sec:pa:answer (0.03) | def:pa:lsch details and the paragraph after it (0.3); prop:pa:lower with its text (0.13); prop:pa:recursion (0.08); tab:pa:costs (0.15); prop:pa:chain (0.08); prop:pa:gibbs and prop:pa:must (0.2); ex:pa:skel (0.11) | rem:pa:usage, rem:pa:zf, §7.3 opening and G1 numbers, rem:pa:lumps, rem:pa:merge, text after prop:pa:isigma (0.65) | 6.0 |
| 8 experiments | 6.6 | 2.7 | rem:exp:refuted → App. H (0.25); E-paragraph findings already stated in the thematic remarks (≈1.5) | the E1–E8 detail paragraphs and tab:exp:e1, e2, e3a, e3b → app-experiments, labels unchanged (≈2.0); proof idea of prop:exp:exact (0.1); prop:exp:comm with its proof note (0.25); pool-construction details (0.25) | opening (0.2); add one summary table of E1–E8 (+0.6) | 2.7 |
| 9 discussion | 3.7 | 2.6 | the parts of §9.1 that restate A1, A7, A8 and §3.9 (0.7) | — | literature (0.15); open problems (0.1) | 2.75 |
| **total** | **56.0** | **≈40** | **≈6.8** | **≈8.2** | **≈2.7** | **≈38.5** |

Notes on the cut list:

* **No result is dropped.** Every moved result keeps a one-line pointer in the main text. Examples:
  * "(The rates of Prop 4.5, the strong-consistency rate and its degeneration for spares, are in App. C.1.)"
  * "Two further calculi with ∧- and tree rules are in App. A.3; the direction is proved for the tree calculi under the unnormalised law, the two-part code and the scores, and is open with ∧-detours."
* **Each experiment gets one home** (R-14). The thematic remark (one or two sentences, with the numbers) stays where the theorem it tests is stated. §8 becomes: what is implemented, why it is exact, a summary table, and what it does not show.
* **Some cuts change the order** (§3). These are: the trichotomy moved to §2, §3.9 and rem:time:summary moved to the starts of their sections, and the good version stated once. They change no length but remove forward references.
* **The appendix will grow** by about 8 pages unless its own duplicates go: the duplicate proofs of C-41, refuted items both in sections and in App. H, and repeated E-text. With them removed it lands at about 64–66 pages (R-45).
* **Front matter.** `\setcounter{tocdepth}{1}` brings the table of contents to one page (tested; the main text starts on p.3).

---

## 3. Structure, ordering, motivation, examples, definitions and notation

### 3.1 Proposed order

1. **Introduction (3 pp).** The question; the short answer (§1.1 above); a running-example table (R-04); how we read the question; what is not achieved; a guide.
2. **The model (4.5 pp).** Only what §3–§4 use. It should cover:
   * Hänni's scores and **his trichotomy** (moved from §5.6, R-21);
   * the size principle;
   * a short boxed statement, in words, of the **recommended inducer**; the full form goes in §9.2 (R-07).
3. **∀xφ from instances (6 pp).** Open with the verdict of §3.9 (R-22). Then the merged odds theorem with its two formulas, the ω-gap split into a theorem and a proposition (R-23), what licenses ∀xφ, and the case without templates.
4. **What the posterior identifies (4.7 pp).**
5. **Hänni's collapse and the time penalty (4 pp).** This answers his third refinement, so it comes before the verifier. Open with the four-point summary (R-24).
6. **The axioms we actually have: PA and ZF (5.8 pp).** End with the three-tier answer for PA.
7. **A use of the posterior: the verifier (4 pp).**
8. **Experiments (2.7 pp).**
9. **Discussion (2.6 pp).**

### 3.2 Motivation and examples

* **Use one running example.** Take φ = 0+x=x with its five hypotheses (H∀, Hsch, the over-specific φ(Sz), the over-general {0+z₁=z₂}, the root split), and give their posteriors at n = 0, 1, 5, 20 under L1 and L0^cl. The data already exist in tab:univ:c2. This example shows the size principle, the schema's win, the prior share under the closure reading, and the death of over-general templates. Today that table sits on p.71.
* **Show the generator view in one sentence** (R-03). "A theory whose axiom is ∀xφ, used as a generator, states ∀xφ itself 77% of the time." This sentence explains Theorem B to a philosopher better than the factorisation does.
* **Give each technical section a one-sentence "why you care" before its first theorem.** Today the openings of §4 and §5 do this, but §2.2–§2.5, §3.6, §6.5 and §7.3 do not.

### 3.3 Definitions before use (main cases)

| item | first used | defined | fix |
|---|---|---|---|
| H∀, Hsch, ρ (Q_open), m, L1^sch, L1^eq in Table 2 / Def 2.4 | p.11 | p.13–17, p.42 | R-19 |
| C* (generator class) in Thm 3.15 | p.19 | Def 4.1, p.24 (informal in A4) | restate in one line in §3.5 |
| Bel, Dis, Indep, Inc, Bel_cons | p.19–23 | Def 5.15, p.35 | R-21 |
| DirMult (Prop 3.12); Mem(D_n) (§3.3) | p.18 | p.26; §8.1 | C-26 |
| KT ("the KT rule", Lemma 2.12) | p.13 | expanded only in §7 | expand at first use |
| spare template | intro, p.15, p.18 | never (implicit, p.28) | R-27 |
| ω-gap | abstract, A3, §3 | never ("of AS") | R-27 |
| motive | A5, Table 5 | p.43 | R-27 |
| DTRC, anchor, cautious verifier, Acc_k, H_k | intro, §5.3, §7.6 | never (AS) | R-27 |
| NAIVE / PC / DPC / SDPC / RDPC / CF, u7, G1–G3 | p.44 | never (AS code) | R-25 |
| pool names skel4@8, DTRC@8, frag-*, IndSwap | p.53–54 | partly | R-30 |

### 3.4 Jargon and process vocabulary

The main sections use "track(s)" 55 times, "referee" 42 times, and "first version / pre-referee / first summary" 18 times. Mathematical objects are named after the unit that produced them, for example "track universal's chains C_min ... track experiments' forward chain ... track pa's natural deduction" (Def 2.4). Name objects by content, and keep provenance in `\src` and App. H (R-17). Of the refuted first-version claims, keep three in the main text, because they change what the reader should believe. Move the rest to App. H with pointers (R-16).

### 3.5 Notation overload (worst cases)

| symbol | meanings (first occurrences) | suggested |
|---|---|---|
| α | Dirichlet parameter (Lemma 2.12) **and** rule probabilities α_ax … α_∀E (Def 2.13, next paragraph) | rule probabilities r_ax, … |
| q | numeral-law parameter (Def 3.1); extinction root (Lemma 2.14); query q_t (Def 5.1); probe sentence q (Ex 5.12); f_q (Prop 3.23) | query s_t; probe ψ; root q_ext |
| ρ | subcriticality rate (Def 2.8); parameter probability of Q_open (Def 3.1); affinity ρ_T (Prop 4.5); reflection sentence ρ_{f,n} (Prop 6.8) | p_par for Q_open; BC_T for the affinity |
| L | L_A, L_∈, L (§6); languages L_1 ⊊ L_2 ⊊ … (Prop 4.12); likelihood names L0/L1/L2/L_ε; code length L_Q(φ) (Def 7.1); count of vacuous quantifiers L (Prop 3.23) | 𝓛_i for Gold's languages; k for the count |
| c | ∀E probability; c_ch, c_stop; c_i (L1^sel_cit); constant c (Thm 6.3); constraints c_j (Def 5.1); costs c_S(f); count c(s); c_T, c_e, c_der, c_{K,α}; check scripts c1–c16 | c_U for the constant; χ_j for constraints; scripts out of the main text (R-29) |
| R | splits R_k; ratio R_n; regret R_α; refutation rule R_d; predicate R; renormalised R(s); depth count R | at least rename R(s) and R_n |
| K | Mendelson's calculus 𝖪; number of templates K; channel K(s′\|s); K_T = KL | Γ for the channel; D_T for the KL |
| H | hypotheses H∀, H_F, H_k(DT°); 50/50 rule H(s) | F_{1/2}(s) |

Also: the sans-serif likelihood names "L1" and "L2" sit on the same pages as the languages L_1, L_2 (pp.25–26). Turning NOTATION.md into a one-page notation table at the head of the appendix would help every reader (R-28).

### 3.6 Places where a reader gets lost

* **p.11:** Table 2 and Def 2.4 (forward references; R-19).
* **p.12:** the grammar definition with type weights h, ρ and b. It is fine in an appendix but heavy before any result.
* **p.17:** Theorem 3.3 states only "as in Table 4" (R-22).
* **p.19:** the five-part ω-gap theorem with an embedded definition (R-23).
* **p.21–22:** §3.6, deep splits R_k, the waste W_o and races between families (R-31).
* **p.22:** the l.198 paragraph on the equational fragment (R-31).
* **p.40:** the §6.5 chain of four results for one conclusion (R-24).
* **p.44:** the code names of AS (R-25).
* **p.53–54:** the pool names (R-30).

---

## 4. Typography

### 4.1 `\src` and `\status`: a preamble fix (tested)

`\src` is `\textsuperscript{...}`, a box that cannot break. Long notes overflow the margin. In ident, pa and experiments a local hack (`\identbrk`, `\pabrk`, `\expbrk` = `\hfil\penalty0\hfilneg`, 78 uses) pushes the superscript to the start of the next line, where it dangles. This happens on p.25, p.29, p.43 and p.48. Separately, `\status` comes out italic in plain-style theorem heads and upright in definitions and remarks.

Change tested in `scratch/r_build/` (diff in `scratch/r_preamble_fix.diff`):

```latex
\setlength{\emergencystretch}{2em}
\newcommand{\status}[1]{\textup{\textsf{\small[#1]}}}
\newcommand{\src}[1]{\unskip\hskip0pt plus 1fil\penalty300\hskip0.35em plus -1fil\relax
  \textup{\textcolor{gray}{\scriptsize\textsf{#1}}}}
% and delete \identbrk, \pabrk, \expbrk from ident.tex, pa.tex, experiments.tex
```

| build | overfull hboxes | dangling superscripts | pages | main text starts |
|---|---|---|---|---|
| current | 9 (one of 80.8 pt) | yes (p.25, 29, 43, 48, …) | 122 | p.5 |
| with the fix, `tocdepth`=1 and the two table fixes | 1 (3.4 pt, model.tex l.22, unrelated) | no | 120 | p.3 |

* The provenance note becomes small grey upright text that can break at spaces. Where it does not fit, a ragged line break goes before it.
* If the editor prefers, the same macro can be switched off in the main text and the notes collected in an appendix index. In a test, hiding all notes saved under one page, so the case for hiding them is visual, not length.
* Update intro.tex l.111 ("as a grey superscript").

### 4.2 Tables

* **tab:sound:constant** (app-sound l.135–147) is 80.8 pt too wide. Fix: tabularx with p-columns (tested, R-36).
* **tab:univ:hyp** has a justified X column with large gaps, and `\src` inside its caption. Fix: ragged X (tested), and take the note out of the caption (R-38).
* **tab:ident:misspec and tab:intro:verdicts:** cleveref's `noabbrev` makes three-line "where" cells. Use abbreviated reference names inside tables (R-39).
* **Floats split statements.** Table 1 splits answer A8; Tables 3–4 sit between Prop 3.2 and its proof idea. Moving those tables (R-05, R-22) removes both cases (R-40).

### 4.3 Other

* The two earlier reports both print as "Claude (Anthropic) (2026a/b)". Use citation aliases AS and IL (R-41).
* The proof-idea style is inconsistent in §3 (R-42).
* Status strings are longer than a line in several heads (R-37).
* One remaining overfull line (R-43).

---

## 5. Numbered issue list

Severity scale: **fatal** = a false or unsupported mathematical claim, or a claim stronger than the sources. **major** = a missing hypothesis, wrong number, inconsistency, misleading framing, or a place the reader cannot follow. **minor** = local wording or formatting. The same list is in `issues-readability.json`.

1. **R-01 [major]** `paper/sections/intro.tex`, l.29-68 (sec:intro:note, sec:intro:reading, sec:intro:answers).  
   *Problem.* The answer arrives late. After the verbatim question (p.5) the reader gets a framing sentence, 1.1 pages that summarise Hänni's own notes back to him (sec:intro:note), and a dense model paragraph. The first answer starts in the second half of p.6. Page 5 says nothing about the results.  
   *Evidence.* TOC: 1.1 at p.5, 1.3 'Answers in brief' at p.6. Block estimate (scratch/r_blocks.out): quote 0.33 pp, sec:intro:note 1.11 pp, before A1. Only the abstract, which is dense, answers early.  
   *Fix.* Directly after the quote, insert a boxed 'Short answer' of about ten lines (proposed text in review-readability.md §1.1). Cut sec:intro:note to about a third of a page: his two variants, the trichotomy, the collapse and the restriction to substitution schemas, one sentence each. The full quotations already appear in §6 (time.tex l.18) and §9.3.

2. **R-02 [major]** `paper/sections/intro.tex`, l.50-68 (A1-A9).  
   *Problem.* The answers follow the research tracks, not the question. A6 (the verifier) answers a question the user did not ask, and it sits between the ∀xφ answers and his three refinements (A7 time, A8 derivation length). Templates, his first refinement, get no answer of their own: it is spread over A1 and A7. His last bullet has three tiers (the actual axioms; something equivalent in theorems; at least a lot of posterior mass), and its answer is split across A4, A5 and A9.  
   *Evidence.* Question bullets: ∀xφ; 'good version' with templates, derivation-length prior and time penalty; 'robustly picks up the axioms ... or equivalent ... or a lot of posterior mass'. The intro order is A1 version, A2-A3 ∀xφ, A4-A5 identification, A6 verifier, A7 time, A8 derivation length, A9 Gold/spares.  
   *Fix.* Reorder to follow the question. (1) The version (A1). (2) ∀xφ (A2, A3). (3) The three refinements: templates (one new line: they block his schema, bring φ(z) into the class, and do not see schema boundaries), derivation length (A8), time (A7). (4) His last bullet as a 3×2 table, with rows 'actual axioms / equivalent theorems / much mass' and columns 'data drawn from the model / human-stated theorems', built from A4, A5 and A9. (5) Side results last: the verifier (A6) and the trichotomy.

3. **R-03 [major]** `paper/sections/intro.tex`, l.53 (A2); universal.tex l.72.  
   *Problem.* The fact that makes the main result intuitive is stated only abstractly ('∀xφ spends probability on outputs never observed') and never with a number. The output in question is mostly ∀xφ itself: as a generator, the theory {∀xφ} usually states its own axiom.  
   *Evidence.* In C_min, quantifier-free φ, c = 0.3: P_{H∀}(∀xφ) = 1/(1+c) = 0.769 and P_{H∀}(φ(t)) = 0.2308·Q(t), against P_{Hsch}(φ(t)) = Q(t). So each instance multiplies the odds by 0.23: 2.1 bits per datum, a factor 4.3e-7 after 10 instances (scratch/r_example_numbers.out; matches tab:univ:odds, row L1, and the c2 posterior table p.71, where H∀ falls from 0.021 to 0.000 by n=5).  
   *Fix.* Add one sentence with these numbers to A2 and to the start of §3.2. For example: 'A generator whose axiom is ∀xφ outputs ∀xφ itself 77% of the time (c = 0.3) and each instance only with probability 0.23·Q(t); the schema outputs exactly the instances. So every instance multiplies the odds of ∀xφ against φ(z) by 0.23.'

4. **R-04 [major]** `paper/sections/universal.tex`, §3.1-3.2 (p.16-18); app-universal.tex tab:univ:c2 (p.71).  
   *Problem.* There is no running example and no figure: 0 figures in 122 pages. The one table that shows the whole ∀xφ story at a glance is buried in Appendix B. It shows mass leaving the over-general templates, the schema rising, ∀xφ dying under L1 and staying at its prior share under L0^cl.  
   *Evidence.* tab:univ:c2 (p.71): under L1, H∀ goes 0.021 → 0.053 → 0.000 → 0.000 and Hsch 0.042 → 0.455 → 0.892 → 0.996 (n = 0, 1, 5, 20). Under L0^cl, H∀:Hsch stays 1:2 (0.332 against 0.665). Over-general templates go 0.926 → 0.000 by n=20. paper/figures/ is empty.  
   *Fix.* Bring a 4-row excerpt of tab:univ:c2 (or a small plot of the same numbers) into the intro or the first page of §3, and use φ = 0+x=x as a running example through §2-§4. Give its data, its five hypotheses and their posterior trajectories. Keep the full table in the appendix.

5. **R-05 [major]** `paper/sections/intro.tex`, l.70-91 (tab:intro:verdicts); also l.53, l.63; universal.tex l.113; sound.tex l.16, l.131; time.tex l.104, l.109; experiments.tex l.164; discussion.tex l.20.  
   *Problem.* The intro's only table, and ten sentences across the paper, grade the hypotheses H1-H7 of the orchestrator's internal research brief. The reader has never seen that document, and its hypotheses are not Hänni's. 'Refutes the brief's H6' or 'the brief's H4(a)' tells him nothing about his own proposals and spends 0.6 pages of the intro.  
   *Evidence.* tab:intro:verdicts caption: 'The hypotheses of the research brief (research/00-brief.md), which were to be checked'. time.tex l.109 quotes and refutes 'the brief's sentence'. The question itself contains no hypotheses H1-H7.  
   *Fix.* Move tab:intro:verdicts to app-verification (H.1 'Process' already introduces the brief), with a one-line pointer from the intro. In the body, state each claim directly. For example, replace 'which refutes the brief's H6' with 'so a penalty on the time to check membership does not price the collapse'.

6. **R-06 [major]** `paper/sections/intro.tex`, l.43 (model paragraph); l.51-67 (A1-A9).  
   *Problem.* The answers are dense with symbols and with jargon not yet defined. Nine answers of about 900 words carry 54 cross-references. In the intro the following are never defined or explained: C_min, L1^sel, L1^sel_cit, 'citation with the closure reading', 'parameters admissible', generator class (defined only in A4), 'spare slot', 'root split', 'the MDL finding of AS', 'Gold's limit point', C*_d, 'motive', 'guard', 'hard assigner'.  
   *Evidence.* Cross-references per answer line: 6, 6, 7, 8, 4, 6, 8, 4, 5 (grep in intro.tex l.51-67). For example, A2: 'the posterior odds stay at the prior odds (citation with the closure reading, L1^sel, Hänni's scores) or fall by a constant factor per datum under a derivation likelihood in the minimal calculus C_min'.  
   *Fix.* Write the intro in words and keep symbols for §2. Use at most two cross-references per answer: the main theorem, plus the section. Where a term is unavoidable, gloss it in a clause: 'a spare template (an extra schema the data never use)', 'the ω-gap (closed instances never entail ∀xφ)', 'a motive (the formula substituted into induction)'. Move the variant names L1^σ, L1^sel and L1^sel_cit out of the intro's model paragraph (l.43).

7. **R-07 [major]** `paper/sections/intro.tex`, l.51 (A1); universal.tex l.224; discussion.tex l.25-31.  
   *Problem.* A1 says 'A good version exists, in a precise and limited sense' but never says what it is. The recipe appears twice, in different words: for ∀xφ only in §3.9 (p.23), and in general in §9.2 (p.58). The user asked 'is there a good version of sth like this'; the paper's own answer to that is a definition, and it is not in one place.  
   *Evidence.* A1 lists properties (finite DT° sets, prefix-code prior, data-independent normaliser) and cites a lemma, but gives no definition. universal.tex l.224 and discussion.tex l.27-29 give overlapping ingredient lists: selection model, noise, Bel_cons verifier, shrinking threshold.  
   *Fix.* State the recommended inducer once in full, in §9.2. Give it in four lines: prior; likelihood (L1^σ if computation is to be priced; a selection model; a noise component); output (Bel, Pl); verifier (Bel_cons ≥ 1−δ, with a shrinking threshold for learned weights). Give it in two lines of words in A1, with a pointer, and as a short boxed statement in words at the end of §2. In §3.9 keep only what is specific to ∀xφ (what the verifier accepts on closed instances) and point to §9.2 for the rest.

8. **R-08 [major]** `paper/sections/intro.tex`, l.61 (A6).  
   *Problem.* The intro uses 'the thresholded verifier' without defining it or saying why it bears on the question. A reader who asked about axiom induction cannot tell what is being verified, or by whom.  
   *Evidence.* The intro mentions it only in A6 and the reader's guide ('the verifier against adaptive provers'). The definition is in §5.1 (p.30).  
   *Fix.* Open A6 with one sentence: 'Used as a proof checker, the posterior accepts a sentence when theories deriving it carry at least 1−δ of the mass; we ask whether a prover that adapts to the checker can get a non-theorem accepted.' Move A6 to the end of the answers (R-02).

9. **R-09 [major]** `paper/sections/intro.tex`, l.65 (A8).  
   *Problem.* A8 says 'on theorem data without direct uses of induction the MAP is strictly weaker than PA'. That is a computed comparison of two candidates on one stream, stated as if it were a general fact about the MAP.  
   *Evidence.* pa notes-final §3.5: the data are a stream of six library theorems (seed 42), and the candidates are T_Ind + library and Q + library; the 'MAP' is the better of these two. pa.tex l.144 (rem:pa:streams (iii)) gives it as computed. The table only supports '6 to 24 times' (ratios 5.8-24.2 in tab:pa:theorems).  
   *Fix.* Write: 'on a computed stream of six library theorems, Q plus the theorems as axioms beats Q + T_Ind, and that theory is strictly weaker than PA (rem:pa:streams)'. Keep 'within the candidates scored' in A8 as A5 does.

10. **R-10 [minor]** `paper/sections/abstract.tex`, l.3.  
   *Problem.* The abstract's key terms go unexplained: 'proper prefix-code prior', 'which gives the size principle', 'a Bayesian ω-gap'. For the first reader these are the hooks of the answer.  
   *Evidence.* 'the likelihood is a derivation grammar whose normaliser does not depend on the data, which gives the size principle'; '... tends to a prior share or to zero, a Bayesian ω-gap'.  
   *Fix.* Add two glosses of a few words each: '(theories that predict sentences never observed lose a constant factor per datum)'; '(closed instances never entail ∀xφ, and the posterior inherits this)'. The qualifications requested in C-01, C-04 and C-05 still apply.

11. **R-11 [minor]** `paper/sections/intro.tex`, l.48.  
   *Problem.* 'Each answer holds within the hypotheses of the results it points to' leaves the reader to collect the hypotheses. The three that change the answer are well-specified data, fixed against Dirichlet weights, and the calculus (C_min). Each answer should carry the ones it needs.  
   *Evidence.* A2 needs C_min, and fixed or common weights, for 'never favour' (see MB-01, C-01). A4 needs fixed weights for concentration (C-04). A6 needs fixed weights.  
   *Fix.* Delete the blanket sentence. Put the needed hypothesis into each answer in a few words ('with data drawn from the model', 'in the minimal calculus', 'with fixed weights').

12. **R-12 [minor]** `paper/sections/intro.tex`, l.94-122 (sec:intro:contrib, sec:intro:guide).  
   *Problem.* The contributions paragraph and the reader's guide list the same nine sections twice in different words. 'What is not achieved' is the paragraph the user most needs, and it sits between them.  
   *Evidence.* l.96 lists sections 2-8 by content; l.113-122 lists them again.  
   *Fix.* Merge the contributions into the reader's guide, one line per section. Move 'What is not achieved' up, directly after the answers, or fold its first two items into the short answer.

13. **R-13 [major]** `paper/main.pdf`, whole main text, p.5-61.  
   *Problem.* The main text is 56.0 pages against a plan of about 40 (outline cap 46), and the table of contents adds 3 pages. Section spans (measured from the PDF): intro 4.7, model 6.5, univ 7.9, ident 6.5, sound 5.9, time 5.9, pa 8.4, exp 6.6, disc 3.7.  
   *Evidence.* Section starts measured with pdftotext -bbox: p.5.10, 9.77, 16.25, 24.10, 30.61, 36.48, 42.40, 50.80, 57.39; references at p.61.10. Block estimates are in scratch/r_blocks.out. C-38 records the same overrun.  
   *Fix.* Apply the per-section cut list in review-readability.md §2. It deletes about 7 pages of duplicated material, moves about 8 pages of technical statements to the appendices with one-line pointers, and tightens about 3 pages. The estimated result is 38.5 pages, with no result statement or caveat dropped.

14. **R-14 [major]** `paper/sections/experiments.tex`, l.47-169 (sec:exp:results, tab:exp:e1, e2, e3a, e3b); ident.tex l.66-68, l.125-127, l.190-192; sound.tex l.124-135; pa.tex l.84-86, l.216-218, l.247-253; time.tex l.199, l.204-206; universal.tex l.96, l.189.  
   *Problem.* Each experiment's findings are written out two or three times: in §8.2 with tables, and again with the same numbers in one to three thematic remarks. §8.2 alone is about 4.3 pages (p.52-56).  
   *Evidence.* E2 appears in rem:sound:lumps, rem:pa:e2, rem:pa:lumps and §8 E2(2). E3(a) in rem:ident:e3a, universal l.189 and §8 E3(a). E4 in rem:sound:e4 and §8 E4. E6 in rem:pa:e6, rem:ident:splitsL1 and §8 E6. E7 in rem:time:links(iii), rem:time:e7 and §8 E7. E8 in rem:ident:e8 and §8 E8 (C-40 lists them).  
   *Fix.* Give each finding one home. Keep one or two sentences in the thematic section where the theorem it tests is stated. Reduce §8 to: implementation (0.6 pp), prop:exp:exact (statement only), one summary table with columns 'experiment | setup in one line | theorem tested | finding | where discussed' (0.6 pp), and rem:exp:limits. Move the E1-E8 paragraphs and tab:exp:e1, e2, e3a and e3b to app-experiments, with labels unchanged. Expected §8 length: about 2.7 pages.

15. **R-15 [major]** `paper/sections/intro.tex`, l.32-36; model.tex l.185; universal.tex l.8; sound.tex l.141, l.191-194; time.tex l.18-20; discussion.tex l.40.  
   *Problem.* Hänni's note is summarised or quoted five to six times, with the same quotations ('T(quoted-phi) = accept => phi', 'being an axiom of the right form is in fact decidable', 'p(true/false/independent)', 'think of this as there being some model...'). He wrote the note and needs it once at most.  
   *Evidence.* Intro §1.1 (1.1 pp) and time.tex l.18 repeat the collapse argument with the same quotations (C-39). model.tex l.185 and intro l.34 repeat the variants. sound.tex l.191-194 quotes his three questions after their answers have been given as Examples 5.19, 5.20 and Proposition 5.21.  
   *Fix.* Quote the note once. Either keep a compressed §1.1 and make §9.3 the only point-by-point treatment, or the reverse. Elsewhere cite the item ('his collapse schema (§1.1)'). In §5.6 answer each of his three questions next to its example instead of in a separate paragraph.

16. **R-16 [major]** `paper/sections/model.tex`, rem:model:subcrit l.117-119; rem:model:graded l.216; ident.tex rem:ident:exact l.83-85; sound.tex rem:sound:hyp l.45, rem:sound:vacuous l.85; pa.tex l.57, l.106-108, l.298; time.tex l.127; experiments.tex rem:exp:refuted l.183-192.  
   *Problem.* About 1.2 pages of the main text narrate first-version claims, refuted, that do not change what the reader should believe. All of them are already in tab:ver:corrections (App. H.2). The outline (rule 3) keeps refuted claims in the text only 'where they matter to the reader'.  
   *Evidence.* Examples: 'The first version's argument ("at least two lines") was wrong' (pa l.57); '(The pre-referee version let c depend on T; referee m1.)' (time l.127); the unlabelled 'Refuted: a constant margin' remark (pa l.106); rem:exp:refuted (0.27 pp, seven items); the last sentence of sec:pa:answer.  
   *Fix.* Keep three refuted remarks in the main text, shortened to two or three lines each, because they change what the reader should believe: prop:time:lonesize (L1 does not charge symbol size), rem:univ:openrefuted (no ω-step without a guard), and rem:univ:detour (the factor c is specific to the calculus). Move the rest to app-verification. Where a corrected statement depends on one, leave a pointer such as '(an earlier version claimed more; H.2)'.

17. **R-17 [major]** `paper/sections/model.tex`, §2.2-2.8 throughout; also ident.tex, sound.tex, time.tex, pa.tex, experiments.tex.  
   *Problem.* Process vocabulary runs through the mathematics. Objects are named after the organisational unit that produced them ('track universal's chains', 'track pa's natural deduction', 'track experiments' grammar'), and statements carry 'referee m9', 'editor, from ...' and 'the model track's first version'. The reader has to learn the project's org chart to follow the definitions.  
   *Evidence.* Counts in the main sections: 'track(s)' 55, 'referee' 42, 'first version / pre-referee / first summary' 18 (grep). model.tex alone has 17 'track' mentions. Example: Def 2.4 (p.11): 'track universal's chains C_min ... track experiments' forward chain Ch_J ... track pa's natural deduction ND'.  
   *Fix.* Name objects by content: 'the minimal chain calculus C_min', 'the forward chain Ch_J', 'the two-part natural-deduction code L1^sch', 'the numeral term law Q_num'. Keep provenance in the \src notes and app-verification. Say once in §1.5 that numbers come from four independently refereed notes.

18. **R-18 [major]** `paper/sections/model.tex`, §2 (p.9-16).  
   *Problem.* §2 is a 6.5-page catalogue placed before any result: Mendelson's calculus, eight calculi, about twelve likelihoods, three priors, the Elias-γ code, the uniform-subcriticality condition with h-weights, Hänni's scores, the size principle, and computability. Many items are used once, much later (L1^eq in Ex 4.25; L_ε in §7.5; P^η in Prop 3.5; L1^max; L1^naive). The reader does not yet know why any of it matters.  
   *Evidence.* Block estimates: tab:model:calculi 0.56 pp, def:model:variants 0.43, the grammar definition with lemma and refuted remark 0.61, def:model:prior with Elias-γ 0.25, lem:model:a4 with proof and paragraph 0.2.  
   *Fix.* Keep in §2 only what §3-§4 use: theory and template, the prior formula, Q in two sentences, L0, L0^cl, L1 (with C_min as its simplest instance), L2, L1^σ, L1^max, L1^sel, Hänni's scores with the trichotomy (R-21), and the size principle. Move the other calculi and likelihoods to app-model, where tab:model:likelihoods already is, or next to their first use, each with a one-line pointer. Cut list: review §2.

19. **R-19 [major]** `paper/sections/model.tex`, l.53-71 (tab:model:calculi, p.11); def:model:calculi l.49-51.  
   *Problem.* Table 2 and Definition 2.4 cannot be read at p.11. They use objects defined later: H∀ and Hsch (tab:univ:hyp, p.17), ρ, the parameter probability of Q_open (Def 3.1, p.16), m (Def 2.13, p.13), L1^sch and L1^eq (Def 2.15, p.13; Def 7.1), Theorem 3.15(c3), Proposition B.1 and Table 'pa §5.5'. The column 'factor P_H∀/P_Hsch per closed instance' presupposes §3.  
   *Evidence.* model.tex l.57-66: 'factor P_{H∀}/P_{Hsch} per closed instance'; '(ρ: parameter probability of Q_open)'; 'finite a.s. iff m ≤ 1'; '(\cref{thm:univ:omega}(c3))'.  
   *Fix.* Move tab:model:calculi to app-model, or place it after Theorem 3.4, where its last column means something. In §2 keep three lines of prose naming the calculi the later sections use.

20. **R-20 [fatal]** `paper/sections/discussion.tex`, l.16 (sec:disc:proposal, 'Templates').  
   *Problem.* 'Inside the class membership is matching, so likelihoods can be computed exactly over a pool (prop:exp:exact)' claims more than the sources. prop:exp:exact covers the citation likelihood L0, the Dirichlet sum, and the two-step chain L1 for the component shapes the code checks. It does not cover the derivation-grammar likelihood of Def 2.13, whose positivity is undecidable.  
   *Evidence.* prop:model:compute(c): 'No algorithm decides whether a theory has likelihood 0 on a datum.' experiments.tex l.35 (prop:exp:exact(d)): 'complete for the component shapes ... the code admits into L1 pools only theories of the shapes it checks'. discussion.tex l.31 itself says 'exact computation is feasible over finite pools with short derivations'.  
   *Fix.* Write: 'Inside the class membership is matching, so the citation likelihood and the two-step chain likelihood can be computed exactly over a pool (prop:exp:exact); the general derivation likelihood is only a computable real whose positivity is undecidable (prop:model:compute).'

21. **R-21 [major]** `paper/sections/sound.tex`, §5.6 l.139-194 (def:sound:tri, Hänni's three questions).  
   *Problem.* The trichotomy comes from Hänni's own note and he asked three questions about it, but it sits as §5.6 inside the verifier section. Bel, Dis, Indep, Inc and Bel_cons are used earlier: in thm:univ:omega(a) (p.19), in prop:univ:hanni and the paragraph after it (p.20), and Bel_cons in §3.9 (p.23). Definitions therefore come after use, and a reader looking for his trichotomy has to find it under 'Soundness'.  
   *Evidence.* def:sound:tri is Def 5.15 on p.35. thm:univ:omega(a) (p.19) reads 'likewise ... for Bel, Dis, Indep, Inc (\Cref{def:sound:tri})'.  
   *Fix.* Move def:sound:tri and the answers to his three questions into §2 next to his scores (new §2.7, 'Hänni's trichotomy'; about 0.8 pages after compression). Alternatively make it a short section of its own before §3. Keep the verifier section about soundness only.

22. **R-22 [major]** `paper/sections/universal.tex`, l.8-96 (§3 opening to §3.2) and l.220-224 (§3.9).  
   *Problem.* §3 states its answer last. The plain-language verdict ('The intuition, precisely', §3.9, p.23) comes after 7 pages. §3.2 opens with the technical Factorisation (Prop 3.2), and the central Theorem 3.3 has no content of its own: 'O_n/O_0 as in Table 4', a float that LaTeX placed before the theorem.  
   *Evidence.* universal.tex l.48: 'the odds ... satisfy O_n/O_0 as in \Cref{tab:univ:odds}'. On p.17, Tables 3 and 4 sit at the top of the page, between Prop 3.2 and its proof idea.  
   *Fix.* Open §3 with the first paragraph of §3.9 (where the intuition is right, where it needs refinement, what licenses ∀xφ). Merge Prop 3.2 and Thm 3.3 into one theorem that displays the three formulas: factor 1 (L0^cl, L1^sel, scores), c^n (unnormalised), (c/(1+c))^n (L1, quantifier-free φ). The factorisation becomes the proof idea, and Table 4 moves to the appendix.

23. **R-23 [major]** `paper/sections/universal.tex`, l.131-142 (thm:univ:omega).  
   *Problem.* The theorem that answers 'the axioms prove ∀xφ' runs 0.64 pages. It has parts (a)-(e), sub-parts (c1)-(c3) and (d1)-(d2), a definition ('faithful for C') embedded in part (c), and a seven-item status line. The headline (a)+(b), that the limit is the prior share of provers inside C*, is lost among the special regimes.  
   *Evidence.* Status: '(a), (b), (c1)-(c3), (d1), (e) proved; (d2) proved for the pair, proof sketch in general; computed'. Part (c) defines 'faithful' inside the statement.  
   *Fix.* Split it in two. Theorem 3.15 'Bayesian ω-gap' keeps (a) and (b), with a one-line gloss of the ω-gap. Proposition 3.16 'When the limit is 0 or 1' takes (c)-(e). Define 'faithful' in a sentence before it.

24. **R-24 [major]** `paper/sections/time.tex`, l.18-20 (opening); l.136-185 (§6.5); l.190-194 (rem:time:summary).  
   *Problem.* §6 also states its result last (rem:time:summary, p.41). Its opening restates the intro's account of the collapse (R-15). The middle carries a four-step technical chain (Lemma 6.14 → Prop 6.15 → Thm 6.16 → Cor 6.17) whose only use in the main text is the conclusion that L1 is proved to charge at least logarithmically.  
   *Evidence.* Block estimates: opening 0.43 pp; lem:time:symexp, prop:time:codelength and thm:time:log with proofs 0.43 pp; rem:time:summary 0.31 pp at the end.  
   *Fix.* Open §6 with the four points of rem:time:summary, cutting the opening's quotations. Move lem:time:symexp, prop:time:codelength and thm:time:log to app-time and keep cor:time:log with a pointer. Move conj:time:polytime to §9.5.

25. **R-25 [major]** `paper/sections/pa.tex`, l.22-26 (def:pa:lsch); l.91, l.110 (§7.3).  
   *Problem.* §7 uses code-level and AS-internal names that this paper never defines: nd.size, dtlib, u7, G1/G2/G3, NAIVE, PC, DPC, SDPC, RDPC, CF. A reader at p.44 cannot follow 'the split leads by 274656, 94089, 163028 and 17242 bits under NAIVE, PC, DPC and CF, and trails by 762 (SDPC) and 5986 (RDPC)'.  
   *Evidence.* pa.tex l.9 lists them as 'local symbols (not exported)'. l.91 introduces SDPC, RDPC and CF in one parenthesis. NAIVE, PC and DPC are not explained at all. AS's code u7 and law G1 are named without description.  
   *Fix.* In the main text distinguish only 'a fixed instantiation grammar' from 'a learned positional grammar shared by all templates (SDPC)'. Give the result as: 'with a fixed or per-template grammar the split wins linearly (Table F.x); with a shared learned grammar it is held at the prior margin up to Occam terms'. Move the code names, the u7/G1 description and the decodable-variant details of def:pa:lsch to app-pa.

26. **R-26 [major]** `paper/sections/discussion.tex`, l.14-35 (§9.1, §9.2).  
   *Problem.* The discussion repeats the intro and §3.9 at length. §9.1 'Templates', 'A derivation-length prior' and 'A time penalty' restate A1, A8, A7 and rem:time:summary. §9.2's 'good version' restates §3.9 l.224, and 'what it can promise' restates A4 and A6. The discussion has 82 cross-references in 3.7 pages.  
   *Evidence.* Block estimates: §9 opening with §9.1 1.21 pp; §9.2 0.3 pp plus text. Compare discussion.tex l.20 with time.tex l.191 and intro.tex l.63.  
   *Fix.* Cut §9.1 to three short paragraphs that add only interpretation, not results. Keep the good-version recipe in one place (R-07). Keep §9.3 (his note, point by point), §9.4 (trimmed by about 30%) and §9.5. Target: 2.6-2.8 pages.

27. **R-27 [major]** `paper/sections/ident.tex`, prop:ident:spare l.136-145 (and every earlier use of 'spare').  
   *Problem.* Several central terms are used throughout and never defined in this paper. 'Spare template/slot' is used in the intro (A4, A9, H5), Prop 2.20(c), Prop 3.9 and Rem 4.19, and is only implicit in Prop 4.18 ('σ a spare'). 'ω-gap' appears in the abstract, A3, §3 and §4, always as 'of AS'. 'Motive' appears in A5, Table 5 and §7. Also undefined: DTRC (intro l.109; the §7.6 title), 'anchor' (Prop 5.7 title), 'cautious verifier', Acc_k and H_k(DT°) (Prop 5.6), 'Gold's limit point' and 'L∞ against L5' (A9; Prop 4.12), and 'KT' (Lemma 2.12; first expanded in §7).  
   *Evidence.* grep: no sentence of the form 'a spare template is ...' in the main text. 'ω-gap' is always 'of AS' or 'AS §4.5'. 'motive' is first defined at pa.tex l.35 (p.43). C-26 lists further symbols used before their definition (DirMult, Mem, SeenQ, T_{L∞}, T_E, T_N, Q_e).  
   *Fix.* Give each term a one-clause definition at first use. Spare: 'an extra template beside the generator's own, which the data never or rarely use'. ω-gap: 'all closed instances φ(0), φ(S0), ... together still do not entail ∀xφ'. Motive: 'the formula substituted for P in induction'. DTRC: expand it and gloss it in one line ('AS's learner that clusters data by skeleton and refutes'). Anchor: 'a datum that fixes a schema uniquely (AS Lemma 2.8)'. Retitle Prop 4.12 'Gold's limit point L_1 ⊂ L_2 ⊂ ... ⊂ L_∞'.

28. **R-28 [major]** `paper/sections/model.tex`, l.81, l.133 vs l.141; universal.tex l.14 vs model.tex l.102; sound.tex l.22, l.119; ident.tex l.91-92; time.tex l.44; pa.tex l.23.  
   *Problem.* The notation is overloaded, sometimes within one page. α is both the Dirichlet parameter (Lemma 2.12) and the rule probabilities α_ax, ..., α_∀E (Def 2.13, next paragraph). q is the numeral-law parameter, the extinction root (Lemma 2.14), the query q_t and the probe sentence q (§5). ρ is the subcriticality rate, the Q_open parameter probability, the affinity ρ_T and the reflection sentence ρ_{f,n}. L names the languages L_A, L and L_1 ⊊ L_2 ⊊ ..., the likelihood names L0/L1/L2/L_ε, the code length L_Q(φ) and a count of vacuous quantifiers. c is the ∀E probability, the constant of Thm 6.3, the constraints c_j, the costs c_S(f), the count c(s), c_T, c_e, c_der, c_{K,α} and the check scripts c1-c16. R has six meanings; K four (Mendelson's calculus, the number of templates, the channel K(s'|s), K_T = KL); H(s) is the 50/50 rule beside the hypotheses H∀, H_F and H_k.  
   *Evidence.* On p.25-26 Prop 4.12 uses languages L_1 ⊊ L_2 while Thm 4.9 on the same spread uses the likelihoods L0 and L1. sound.tex l.22 (q_t queries) and l.119 (q a sentence) are three pages apart. model.tex l.133 and l.141 are adjacent.  
   *Fix.* Rename at least: the rule probabilities (α_ax → r_ax, etc.); the query and probe (q_t → s_t, q → ψ); the Q_open parameter probability (ρ → p_par); the Gold languages (L_i → 𝓛_i); the vacuous-quantifier count (L → k); the 50/50 rule (H → F_{1/2}); the channel (K → Γ). Keep check-script names out of the main text (R-30). Turn NOTATION.md into a one-page 'Notation' table at the head of the appendix.

29. **R-29 [minor]** `paper/sections/universal.tex`, universal.tex l.17, l.189; sound.tex l.188; \src notes model.tex l.132 ('c8'), l.197 ('c1'), pa.tex l.196 ('referee r8').  
   *Problem.* Names of check scripts appear in the main text: 'checks c2-c7', 'c8-c10', 'In c8', 'universal's c2 class', and in \src notes '(c8)', '(c1)'. They mean nothing to the reader. They also collide with the constant c and with the parts (c1)-(c3) of Theorem 3.15, which appear two pages later.  
   *Evidence.* universal.tex l.17: 'Dirichlet α = 1 in checks c2-c7, α = ½ in c8-c10'. l.189: 'In c8 (\Cref{tab:univ:noguard}), with R_{1..4} ...'.  
   *Fix.* Move script names to table captions and appendix paragraphs. In the main text write 'in the computations of App. B' and state α where it matters ('with Laplace weights').

30. **R-30 [minor]** `paper/sections/experiments.tex`, tab:exp:e2 l.81-88; tab:exp:e3b l.126-131; l.75.  
   *Problem.* Pool-member names appear in tables before or without definition: skel4@8, DTRC@8, Trim(Q-lumped), skel6@16, frag-observed@16, @32, frag1, IndSwap.  
   *Evidence.* Table 11 (p.53) 'MAP [tag]' column; Table 13 (p.54) 'frag-observed@16, @32'. 'skel' and '@b' are explained only implicitly in l.29 ('stopped at k clusters').  
   *Fix.* Add one caption line: 'skel k@b: skeleton clustering into k clusters built from the first b data; DTRC@b: AS's learner run on the first b data; frag-*: Q plus induction split by motive root'. Use descriptive words in the main text.

31. **R-31 [minor]** `paper/sections/universal.tex`, l.183-189 (§3.6, prop:univ:noguard and the c8 paragraph); l.198 (equational fragment).  
   *Problem.* Two places where a reader gets lost. §3.6 debates deep splits R_k, guards, the waste rate W_o and races between families over Q. Its conclusion ('it approximates the missing guard by ever deeper splits, whose waste q^k W_o tends to 0') needs one plain sentence first. l.198 packs into one 9-line paragraph the equational-fragment result, a sufficient condition q > e^{-(1-μ)²/2}, a negative remark for q = ½ and a Kt remark.  
   *Evidence.* Block estimates: §3.6 about 1.1 pp; the §3.7 text paragraph 0.3 pp.  
   *Fix.* Lead §3.6 with: 'Without a guard the outcome depends on which competitors the class contains; with a selection-aware likelihood the ω-step is taken.' Then state Props 3.19 and 3.22 and move prop:univ:rkrate to the appendix. Split l.198 into two sentences of result and move the sufficient condition to the appendix with prop:univ:eqfrag.

32. **R-32 [minor]** `paper/sections/ident.tex`, l.129-131 (rem:ident:mdl); pa.tex l.91, l.110; universal.tex l.236-238 (rem:univ:mdl).  
   *Problem.* The MDL finding of AS is quoted three times ('MDL tracks the statistics of usage ...'). The paper's conclusion about it ('when the instantiation model is misspecified, the posterior tracks usage') comes as the last sentence of a 10-line remark.  
   *Evidence.* Quoted at universal l.237, ident l.104 and pa l.91. rem:ident:mdl is 0.32 pp, with its conclusion at the end.  
   *Fix.* Quote it once, at ident §4.4. Open rem:ident:mdl with the conclusion and follow it with the three qualifications in one line each. Merge rem:univ:mdl into it and leave a pointer.

33. **R-33 [major]** `paper/preamble.tex`, \src definition (l.37); ident.tex l.13, pa.tex l.12, experiments.tex l.14 (\identbrk, \pabrk, \expbrk).  
   *Problem.* \src is \textsuperscript{...}, an unbreakable box. Its 184 uses (169 in the main text) either overflow the margin or, in ident, pa and experiments, are pushed by a local hack (\hfil\penalty0\hfilneg) to the start of the next line, where a grey superscript dangles alone before the statement. Long notes ('model §1.5; universal §1.5; pa Def 0.3; experiments §1.7; model Ex 3.6', 79 characters) make this worse.  
   *Evidence.* build3.log: the overfull boxes at model.tex l.140-146 (Def 2.13 head) and l.214-217 (Rem 2.21 head) come from the unbreakable status-plus-superscript head. Dangling superscripts on p.25 (Prop 4.7, Thm 4.9, Rem 4.10), p.29 (Conj 4.26, Rem 4.27), p.43 (Def 7.2, Props 7.3, 7.5, Rem 7.4) and p.48 (Ex 7.27). 78 uses of the hack (30 in ident, 44 in pa and app-pa, 4 in experiments).  
   *Fix.* Tested in scratch/r_build (diff: scratch/r_preamble_fix.diff). Replace with \newcommand{\src}[1]{\unskip\hskip0pt plus 1fil\penalty300\hskip0.35em plus -1fil\relax\textup{\textcolor{gray}{\scriptsize\textsf{#1}}}}, which is inline, breakable at spaces, and allows a ragged break before the note. Delete \identbrk, \pabrk and \expbrk (the test neutralises them in the preamble), and add \setlength{\emergencystretch}{2em}. Result of the test build with R-33 to R-36 and R-38 applied: overfull boxes fall from 9 to 1 (3.4 pt, model.tex l.22, unrelated to \src); no dangling superscripts; 120 pages instead of 122; main text from p.3. Update intro.tex l.111 ('as a grey superscript').

34. **R-34 [minor]** `paper/preamble.tex`, \status definition (l.35).  
   *Problem.* \status is \textsf{\small[...]} without \textup. In plain-style theorem heads (theorem, lemma, proposition, corollary, conjecture) it comes out italic sans; in definition and remark styles it is upright. The same marker therefore looks different from one statement to the next.  
   *Evidence.* p.10: Lemma 2.3 '[(a) proved; (b) proof sketch]' italic; Remark 2.10 upright. p.25: Theorem 4.9 status italic, wrapping over two lines; Remark 4.10 upright.  
   *Fix.* \newcommand{\status}[1]{\textup{\textsf{\small[#1]}}} (tested). Also shorten very long status strings (R-37).

35. **R-35 [minor]** `paper/main.tex`, l.12 (\tableofcontents).  
   *Problem.* The table of contents runs 3 pages (pp.1-4) because it lists every subsection of eight appendices, so the main text starts on p.5.  
   *Evidence.* pdftotext of pp.1-4: the TOC lists A.1-H.7. Section 1 starts at p.5.  
   *Fix.* \setcounter{tocdepth}{1} before \tableofcontents (tested: Section 1 then starts on p.3). Alternatively list subsections for the main text only, with \addtocontents{toc}{\protect\setcounter{tocdepth}{1}} before \appendix.

36. **R-36 [minor]** `paper/sections/app-sound.tex`, l.135-147 (tab:sound:constant).  
   *Problem.* Table 27 is 80.8 pt wider than the text block: a plain tabular with long column heads.  
   *Evidence.* build3.log: 'Overfull \hbox (80.84259pt too wide) in paragraph at lines 135--147' (app-sound.tex).  
   *Fix.* Use tabularx with a ragged X first column and p{} columns for the three heads (tested: the overfull box disappears). The test also adds the missing first-column head 'implementation'.

37. **R-37 [minor]** `paper/sections/universal.tex`, thm:univ:omega l.131; prop:univ:noguard l.183; prop:univ:sentences l.205; prop:univ:quant l.194; time.tex prop:time:single l.66.  
   *Problem.* Status strings in statement heads are often longer than a line, so the statement begins on the third line. Examples: '(a), (b), (c1)–(c3), (d1), (e) proved; (d2) proved for the pair, proof sketch in general; computed'; 'provability, (a), (b) proved; (c) proof sketch; computed; (d) computed, limit conjecture'; 'proved, assuming Con(PA) and the standard formalisation of computations; Hänni's consistency argument refuted in this reading'.  
   *Evidence.* p.19-22 and p.37 as rendered.  
   *Fix.* Keep the head short ('[proved; parts sketched or conjectured]') and mark exceptions at the parts themselves ('(d2) [sketch]'). Put assumptions such as 'assuming Con(PA)' into the statement, where they belong.

38. **R-38 [minor]** `paper/sections/universal.tex`, l.19-36 (tab:univ:hyp).  
   *Problem.* In Table 3 the X column is justified, so short cells stretch across the full width with large gaps (p.17, row R_k: 'z unguarded;   weights   (v_0, ...)'). \src sits inside the caption ('Hypotheses of Section 3^{universal §1.3}'). R_k, Split_k and Both0 are defined here but used only in §3.6 and §3.8, five pages later.  
   *Evidence.* p.17 as rendered. universal.tex l.21: \begin{tabularx}{\textwidth}{@{}l X c@{}}.  
   *Fix.* Use >{\raggedright\arraybackslash}X (tested). Move \src out of the caption into the text. Define R_k, Split_k and Both0 where they are used.

39. **R-39 [minor]** `paper/sections/ident.tex`, l.196-222 (tab:ident:misspec); intro.tex tab:intro:verdicts.  
   *Problem.* With cleveref's noabbrev, the narrow 'where' columns wrap to three lines ('Propositions 4.14 and 4.15 and Remark 4.27'; 'Remark 7.30 and Proposition 7.29'; 'Remarks 5.14 and 7.32'), which makes Table 5 a page tall (p.29).  
   *Evidence.* p.29 as rendered; ident.tex l.198 gives the column as p{2.7cm}.  
   *Fix.* Inside tables use abbreviated names (\crefname{proposition}{Prop.}{Props.} and so on, set locally in a group), or a single reference per row with the rest in the text.

40. **R-40 [minor]** `paper/sections/intro.tex`, tab:intro:verdicts (p.8); universal.tex tab:univ:hyp, tab:univ:odds (p.17).  
   *Problem.* Floats interrupt statements. Table 1 is set at the top of p.8 in the middle of answer A8 (its bold heading is split by the table). Tables 3 and 4 sit between Proposition 3.2 (p.16) and its proof idea (p.17).  
   *Evidence.* p.7-8 and p.16-17 as rendered.  
   *Fix.* Moving Table 1 to the appendix (R-05) and Table 4 to the appendix (R-22) removes both cases. Otherwise use [b] placement or put the float after the list or proof.

41. **R-41 [minor]** `paper/main.tex`, title footnote l.6; model.tex l.20; intro.tex l.43, l.109.  
   *Problem.* The two earlier reports print as 'Claude (Anthropic) (2026a)' and 'Claude (Anthropic) (2026b)', which the reader cannot tell apart. The title footnote reads 'a follow-up to Claude (Anthropic) (2026b) and Claude (Anthropic) (2026a)'. The paper then refers to them as AS and IL.  
   *Evidence.* p.1 footnote; p.10 'the earlier report Claude (Anthropic) (2026a) ("AS" below)'.  
   *Fix.* Use natbib's \defcitealias{claude2026axiomschemas}{AS} and \defcitealias{claude2026whatfollows}{IL} with \citetalias, and introduce them once as 'AS (Claude, 2026a), on axiom schemas' and 'IL (Claude, 2026b), on inferential learning'.

42. **R-42 [minor]** `paper/sections/universal.tex`, l.45, l.72, l.142, l.187 ('\noindent\emph{Proof idea.}'); l.230-232 (manual \qed).  
   *Problem.* Proof sketches in §3 are plain paragraphs starting '\noindent\emph{Proof idea.}', with no end mark. Other sections use \begin{proof}[Proof idea] with a QED box. The proof of Cor 3.27 sets \qed by hand.  
   *Evidence.* p.16-23 compared with p.10-15 and p.36-41.  
   *Fix.* Use \begin{proof}[Proof idea] ... \end{proof} throughout §3.

43. **R-43 [minor]** `paper/sections/model.tex`, l.22-23.  
   *Problem.* An overfull line of 3.4 pt remains after the preamble fix: 'occurrences $M(t_1,\dots,t_n)$ with metavariable-' near the margin.  
   *Evidence.* Test build (scratch/r_build_after_fix.log): the only remaining overfull box.  
   *Fix.* Reword ('may contain metavariables applied to metavariable-free arguments, $M(t_1,\dots,t_n)$') or let \emergencystretch handle it.

44. **R-44 [minor]** `paper/sections/intro.tex`, l.29; experiments.tex l.20; discussion.tex l.64.  
   *Problem.* The framing sentence 'a study of an idea ... not the design of a stronger prover' appears three times in almost the same words. The outline asks for it in the intro and the discussion only.  
   *Evidence.* intro l.29; experiments l.20 ('It is a laboratory for checking the claims ..., not a prover'); discussion l.64.  
   *Fix.* Keep it in the intro and the closing paragraph. In §8 say only 'a small exact laboratory'.

45. **R-45 [minor]** `paper/sections/app-*.tex`, appendix as a whole (p.63-122).  
   *Problem.* The cut list moves about 8 pages into appendices that already run about 60 pages against a plan of 36 (C-38). Without offsetting deletions the appendix would reach about 70 pages.  
   *Evidence.* Block estimates in scratch/r_blocks.out. Duplicate proofs exist in app-ident and app-sound (rem:ident:exact against rem:sound:vacuous) and in app-time and app-pa (prop:time:notemplate against prop:pa:refl) (C-41). Refuted items appear both in appendix sections and in tab:ver:corrections.  
   *Fix.* While moving material, delete the appendix duplicates (C-41), keep each refuted item only in tab:ver:corrections, and let app-experiments absorb the E-paragraphs without repeating tab:exp:e2seen and tab:exp:e4-e8 text. Expected appendix length: about 64-66 pages.
