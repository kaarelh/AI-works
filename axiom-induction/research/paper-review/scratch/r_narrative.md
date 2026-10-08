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

