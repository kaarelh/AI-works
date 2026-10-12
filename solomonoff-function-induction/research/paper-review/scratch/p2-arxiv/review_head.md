# Paper 2: consistency and arXiv-readiness review

**Paper.** "Steeper Simplicity Priors in Solomonoff Function Induction: Absorption, the Teacher's Mistakes and the Model–Randomness Split" (Kaarel Hänni), `paper-steeper/main.pdf` built 2026-10-12 16:59 (63 pages), sources `paper-steeper/sections/*.tex`, `paper-steeper/bib/*.bib`, `main.tex`, `preamble.tex`.

**Scope.** The seven points of a full arXiv-readiness review: (1) abstract, introduction and discussion against the body; (2) notation against `paper/NOTATION.md`; (3) statuses against `paper-steeper/CLAIMS.md`; (4) a complete arXiv conversion plan, including every mention of Wyeth; (5) every bibliography entry; (6) structure and length; (7) readability. The mathematics of the body is not re-proved here; the body's statements are taken as given, except for two independent numerical checks.

**Rules applied.** The three binding notes at the top of `paper-steeper/OUTLINE.md` (sole author with AI-assistance disclosure; standard academic paper for arXiv; no "Wyeth's objection", Wyeth not quoted, at most one neutral footnote on the LessWrong thread). Sources of claims: `research/tracks/{foundations,history,examples,context,steeper}/notes-final.md` (with `referee.md` and `checks/`) and `research/00-brief.md`; for quotations, `research/prior/` and the public repository `github.com/kaarelh/notes`.

**Independent checks** (all in `research/paper-review/scratch/p2-arxiv/`):
* `extract_status.py` → `envs.json`, `envs.txt`: all 73 theorem-like environments with label, `\status`, `\src`.
* `compare_status.py` → `compare_status.out`: statuses against `CLAIMS.md`.
* `process_vocab_p2.py` → `process_vocab.out`: process vocabulary, literature hedges, Wyeth, third-person references and script names in the visible text (comments, `\status`, `\src` stripped).
* `window_scope.py` → `window_scope.out`: re-implements the window and identification bounds of Theorem 4.7 from the paper's formulas. It reproduces Table 2(a) exactly, computes the e-bound over the whole window, and gives the window size as a function of the machine constant.
* `concentration_exponent.py` → `concentration_exponent.out`: the power-posterior exponent of Proposition 4.13.
* `conversion_table.py` → `conversion_table.md`: the arXiv conversion table of section 4.1.
* `bibcheck-log.md`: one line per bibliography entry.
* `make_issues.py` → `../../p2/issues-p2-arxiv.json` and `issue_list.md`.
* `main.txt`: pdftotext of the PDF.

**Limitation.** The session's shared WebSearch budget ran out after 21 searches by this reviewer. Nine printed entries could therefore be checked only against the writers' own search records and the Paper 1 review's same-day log (section 5, issue P2X-37).

---

## 0. Summary

The mathematics is presented with care. Every statement in the body carries its hypotheses. The numbers reproduce: Table 2(a) is matched digit for digit by an independent re-implementation. Each refuted reading is kept where it informs the reader. All 73 environments have ledger rows, and every status agrees with `CLAIMS.md` in substance (section 3).

The paper is **not yet an arXiv paper**. Five groups of problems need fixing first.

1. **Wyeth is named 17 times in the PDF** (P2X-05). Every citation of the author's own LessWrong comments prints "(Hänni and Wyeth, undated)", and the bibliography lists "Kaarel Hänni and Cole Wyeth". No heading names Wyeth and no comment of his is quoted; the problem is the bibliography entry. The fix is simple. Eleven of the fifteen body citations can point to the public grokking note, which contains the same sentences. Three support remarks found only in the thread, which the author can restate in his own voice. The fifteenth is the permitted footnote. The entry is also unverifiable as printed ("undated", "text as pasted"; P2X-06).
2. **The front and back matter claim more than the body proves.**
   * Fatal: the discussion says the trick "provably fails" for cheap, frequent human errors in general (P2X-01). The body proves failure only for one constructed rule and for fixed cheap rules once d ≥ d₀(κ), and only in the parity instance.
   * Major: the abstract states the teacher's-mistakes theorem without four of its hypotheses: population objective, uniform inputs, junta-shaped errors, p < 0.056 (P2X-02). It also calls an error-label bound of 0.19–0.27 "little probability". The proved bound is never below 0.194 anywhere in the window.
   * Major: the abstract says "the sampler wins" under private randomness, but the theorem selects *a* sampler, not necessarily ν (P2X-03).
   * Major: Section 6 and the discussion call the λ = 1 factors "bounded" or "independent of the sampled randomness". The paper's own lemma says they grow triply logarithmically (P2X-04).
3. **Process material is printed throughout** (P2X-10, P2X-11, P2X-14, P2X-21, P2X-28):
   * 64 status tags and 73 grey source notes ("[proved; computed] steeper Prop 1.3 (T5 Thm 2.1, Prop 2.2); check c2(a); referee r2");
   * a 5.5-page "internal record" appendix;
   * ten passages saying the literature was read only at abstract level;
   * a Code and data statement pointing to `research/tracks/steeper/`, which is not on the public main branch;
   * script names `c6_revision.py`, `c7_run2.py`.
4. **Voice and sources** (P2X-07, P2X-08, P2X-12, P2X-13, P2X-22, P2X-23).
   * The sole author is referred to in the third person 65 times. His claims are graded in a "Verdict" table, and four theorem-like headings carry his name.
   * The introduction quotes his informal notes at length, including their lowercase and abbreviations.
   * Six citations go to a "personal communication to the author" from the author ("Request for a paper").
   * His notes are cited as one repository titled "notes".
   * The companion paper and the earlier report are cited as folders, one of which is not public.
5. **Literature claims rest on abstracts** (P2X-15 to P2X-20). The paper's central disclaimer of prior work (λ-weighted MDL), the novelty of product sophistication, the "complexity weight above one" in MDL theory and the SafeBayes remark were checked only against abstracts or secondary sources. All the works are open access. They need reading, not rewording.

**Bibliography** (section 5). The bibliography has 42 entries; 37 are printed.
* 19 are verified by this reviewer's WebSearch (7 of them need a DOI, issue number or series added).
* 2 are verified against the public source itself, but both must be rewritten: the notes repository and the earlier report.
* 8 are verified by the Paper 1 review's same-day searches; 4 of these are not printed.
* 9 printed entries were re-checked only against the writers' records.
* 3 printed entries are unusable as printed: `hanni2026lesswrong` (drop), `hanni2026request` (drop), and `claudeSFI2026fundamentals` (not yet public).

**Structure.** The paper has 63 pages: 30 pages of main text with 70 theorem-like environments, and 28 pages of appendices including the internal record. The outline's budget of 18–22 main pages is exceeded by about 9 pages (P2X-26), and the central theorem is hard to read (P2X-27).

**Counts.** 45 issues: 1 fatal, 27 major, 17 minor (`issues-p2-arxiv.json`).

---

## 1. Abstract, introduction and discussion against the body

"OK" means same scope and same hypotheses. Page numbers refer to `main.pdf`.

### 1.1 Abstract (`abstract.tex` line 3; 200 words, 1,334 characters)

| # | claim (abridged) | body | verdict |
|---|---|---|---|
| A1 | SFI predicts labels with a universal prior over random functions | setup.tex "Objects from the companion paper" | OK |
| A2 | the author's notes proposed λ > 1 with private randomness, so that learning selects simple model plus noise | intro ¶1; grokking note | OK (cite the note: P2X-08) |
| A3 | "A standard objection: under a steeper penalty, a universal mixture taken as one hypothesis absorbs everything" | absorb.tex 5 | "standard" has no citation (P2X-09); "absorbs everything" undefined (P2X-45) |
| A4 | "it does in every class containing its own mixture, such as SI and shared-randomness SFI" | thm:absorb:absorption with rem:absorb:examples (H_F, H_w, H_SI, H_chr) | OK |
| A5 | "no private-randomness hypothesis is universal; the protection has a price on latent causes shared across inputs" | cor:absorb:nouniversal; prop:absorb:price | OK |
| A6 | "For a random parity with a systematic error rule incompressible relative to it ... for λ = cn, with c in an explicit window, every near-optimal private-randomness hypothesis knows the parity and gives the erroneous labels little probability" | thm:teacher:main; def:teacher:instance | **major**: population objective, uniform inputs, junta form and p < 0.056 are missing; the e-bound is ≥ 0.194 everywhere in the window (window_scope.out), so "little" overstates it; vacuous for Version 1 (P2X-02) |
| A7 | "In the original example the window spans three orders of magnitude" | rem:teacher:numbers: ratio 8453 (κ = 0), 3837 (κ = 30) | true for κ ≤ about 300 (window_scope.out: ratio 1004 at κ = 300); the machine constant should be named (P2X-02) |
| A8 | "it needs λ proportional to n and fails for some compressible error rules of the same density and description length" | prop:limits:plain, rem:limits:schedule; prop:limits:envelope | OK ("fails" on part of the window; acceptable in an abstract) |
| A9 | "At λ = 1 a computable sampler and programs that fill in its sampled bits get similar posterior" | thm:split:lambda1 | OK |
| A10 | "for λ > 1 the sampler wins with private but not with shared randomness" | thm:split:private, rem:split:reading; thm:split:shared(i) | **major**: *a* sampler, not necessarily ν; shared randomness excludes only samplers longer than ℓ*_λ (P2X-03) |

### 1.2 Introduction (`intro.tex`)

| # | place | claim | body | verdict |
|---|---|---|---|---|
| I1 | l. 6 | SFI "like SI learns every computable regularity of the labels, including the labeller's mistakes" | Paper 1 (dominance); prop:limits:plain(a) | OK |
| I2 | l. 6 | J_λ(π;D) = λℓ(π) − log P_π(D) or power prior 2^{−λℓ} | def:setup:objectives | OK |
| I3 | l. 12 | the absorption objection, "a standard objection" | absorb.tex 5 | no citation for "standard" (P2X-09); close paraphrase of the thread comment, not a quotation (acceptable) |
| I4 | l. 12 | his example: 100-bit model, 2^{−10} fraction, 10,000 bits, three hypotheses, "selected for a range of λ/n" | rem:teacher:hanni | OK |
| I5 | l. 16 | in every class containing its own mixture "every λ-MAP is shorter than a bound that does not depend on the data, and a computable deterministic teacher's labels, errors included, are eventually predicted" | thm:absorb:absorption (a), (c); for SI only (d), in expectation, with i.i.d. computable inputs | OK for data-set classes; SI is covered only in expectation (acceptable in an introduction) |
| I6 | l. 16 | product hypotheses lose 2^d − 1 bits on a parity with a d + 2 log d + O(1)-bit program | cor:absorb:nouniversal | OK |
| I7 | l. 16 | factor min(λ, 2) on coins shared by pairs; protection ends with labelled history | prop:absorb:price, prop:absorb:history | OK |
| I8 | l. 17 | window (2^{−m}, c_hi]; near-optimal hypotheses "know the parity, are short, hold little information about S and give the erroneous labels small average probability" | thm:teacher:main (ii) | "small average probability" (≈ 0.2) overstates; population and uniform inputs are not said here (said in l. 48) (P2X-02) |
| I9 | l. 17 | (9.54·10⁻⁷, 8.06·10⁻³] at κ = 0, (9.54·10⁻⁷, 3.66·10⁻³] at κ = 30, against (1.12·10⁻⁶, 8.99·10⁻³) | tab:teacher:numbers, rem:teacher:hanni; window_scope.out | OK (reproduced) |
| I10 | l. 18 | plain Bayes, MDL, SI and λₙ/n → 0 learn the errors; λ = Θ(n) needed | prop:limits:plain, rem:limits:schedule | OK |
| I11 | l. 18 | envelope rule: "on almost a third of the window's logarithmic width" | limits.tex 42: 31% at κ = 0, 25% at κ = 30 | add κ (P2X-29) |
| I12 | l. 18 | a cheap frequent rule defeats every c once the model is long enough; selection "depends on the input law" | prop:limits:rateblind, lem:limits:robust; prop:limits:inputlaw (separable case only) | OK; input-law dependence is proved only in the separable case (said in limits.tex 85, not here; minor) |
| I13 | l. 19 | λ = 1 odds in [2^{−2log(t_n+1)−κ}, 2^{k+δ*}] "whatever the sampled randomness" | thm:split:lambda1 (iii) | OK as stated, since t_n is shown; contrast with split.tex 5 and discussion (P2X-04) |
| I14 | l. 19 | for fixed λ > 1, λ-MAP at most (k+δ*)/(λ−1) bits longer than the sampler; fill-ins' posterior exponentially small | thm:split:private (i), (iii) | OK |
| I15 | l. 19 | "with shared randomness, and in SI, the universal mixture wins" | thm:split:shared (i): only against samplers with (λ−1)k > λℓ_U + κ₀ | add "against long samplers" (P2X-03) |
| I16 | l. 19 | product sophistication exceeds set sophistication by d − O(log d) | prop:algstat:parity (iii), (iv) | holds for a range of b and δ_E = O(d) (P2X-29) |
| I17 | l. 20 | lower bounds and private split hold in every c.e. prefix-free product class | prop:related:computable | OK |
| I18 | Table 1 | twelve rows of "Claim / Verdict / Where" | rows checked against the cited results | content OK; Version 1 numbers match ex:teacher:version1; the form (grading the sole author) is the problem (P2X-12) |
| I19 | l. 46 | "Two-part codes with a complexity weight above one appear in MDL theory" | setup.tex 48: "reported to appear" | stronger than its own section and unverified (P2X-17) |
| I20 | l. 46 | the three classification papers "find that a bounded λ fits the noise and that λ must grow" | rem:related:mdl (abstracts only) | Grünwald–Langford is about λ = 1; unverified (P2X-15) |
| I21 | l. 48 | the positive result holds only for parities, product-form errors, uniform inputs, p < 0.056, incompressible rules; 10¹¹ samples; batch objectives | rem:teacher:hypotheses, cor:teacher:sampled, rem:setup:persample | OK. This paragraph is the correct hedge; the abstract should match it (P2X-02) |

### 1.3 Discussion (`discussion.tex`)

| # | place | claim | body | verdict |
|---|---|---|---|---|
| D1 | l. 5 | when a universal mixture is a member, a steeper prior "cannot" separate model from noise | thm:absorb:absorption (a): only models longer than ℓ*_λ are excluded | overstated (P2X-30) |
| D2 | l. 5 | the product view counts as model what is reused, as noise what is private; price on shared latent causes; protection ends with labelled history | rem:absorb:wyeth, prop:absorb:price, prop:absorb:history | OK |
| D3 | l. 7 | window 2^{−m} < c ≤ c_hi for incompressible rules; lower end sharp; λ ∝ n; code length exceeds the program's loss by cℓ(π) per sample | thm:teacher:main (iv); rem:limits:schedule | OK |
| D4 | l. 7 | strictly proper scores prefer the teacher's channel | prop:limits:noident (i) | OK |
| D5 | l. 9 | "Human labelling errors are often cheap, frequent patterns ... and for such errors the trick provably fails" | prop:limits:envelope, prop:limits:rateblind (parity instance; one constructed rule; d ≥ d₀(κ)) | **fatal**: stronger than the body (P2X-01) |
| D6 | l. 9 | quotes the author's assessment via the LessWrong thread | not in the grokking note | restate in the author's voice (P2X-05) |
| D7 | l. 11 | at λ = 1 a Bayes mixture is indifferent "up to bounded factors" | thm:split:lambda1; lem:split:stream (triply logarithmic growth) | **major**: not bounded (P2X-04) |
| D8 | l. 11 | the steeper prior breaks the tie in the limited sense of Remark 6.7; in SI's program representation no steepness does | thm:split:private, rem:split:reading, rem:split:siprograms | OK |
| D9 | l. 13 | relation to MDL, safe and fractional posteriors, cold posteriors, NN Bayes | rem:related:* | content OK; the "bridge question" belongs to the companion paper (P2X-42); literature caveats (P2X-15, P2X-18) |
| D10 | l. 15–26 | eight open problems | q: paragraphs | item (8) "Literature" is a to-do, not a research problem (P2X-14); the cross-references print wrong section numbers (P2X-25) |
| D11 | l. 30 | acknowledgements | binding note | content required by the binding note is present; delete "the comparison with the literature rests on abstracts and search snippets" (P2X-14) |
| D12 | l. 33 | Code and data | — | path with "tracks", not on main (P2X-21) |

---

## 2. Notation against `paper/NOTATION.md`

What is right:
* the n/N/d swap is applied consistently (St's N → n, n → N, n_N → d_n); every displayed formula checked in Sections 4–7 uses the new letters;
* c = λ/n throughout, and machine constants are κ, κ₀, κ₁, κ_g, κ_b, κ_e;
* level is `\lev`, the lower bounds of Theorem 4.7 are Φ₁, Φ₂ and the slack is ε;
* the Ville deficiency is δ*; set models are A; the sufficiency slack is b;
* the input law is μ; the true law is `\Prob`;
* the hull point set is 𝒜, as NOTATION §5 asks.

The macros of NOTATION §10 are used and none is redefined. No hard-coded numbering of the steeper notes (no "Thm 2", "Prop 2.17") survives in the visible text; it survives only in the `\src` notes (section 4).

Deviations:

| # | where | NOTATION rule | deviation | issue |
|---|---|---|---|---|
| N1 | split.tex 104; app-split.tex 32, 60 | §1 "Programs": Paper 2 writes π, because p is the error density | 2^{−λ\|p\|}; programs p_w, p_s | P2X-34 |
| N2 | app-split.tex 69 | §4 item 18: subscripted δ = deficiencies | δ_w = point mass | P2X-34 |
| N3 | limits.tex 58 | §5 local symbols must not clash inside a section | constants a, b in Lemma 5.5; a is the parity, b the behaviour of Prop. 5.10 | P2X-34 |
| N4 | app-algstat.tex 20, 52, 77 | same | u = agreement and integer index; e, h in p = h/2^e versus e(π), h_z | P2X-34 |
| N5 | algstat.tex 45 | same | ρ := ⌈−log ν_π(D)⌉ next to ρ^×_D; ρ also the chronological semimeasure (setup), rates ρ_σ, ρ_G, a prefix string (app-limits) | P2X-34 |
| N6 | absorb.tex 65 | §1: κ′ for a subclass constant | κ′ is a different constant | P2X-34 |
| N7 | absorb.tex 78 (iv) | §6: every lower bound states its convention | "pays at least ... more than M_F" without "(semimeasure convention)" | P2X-35 |
| N8 | ~20 citations of Paper 1 | §8: cross-paper references by citation and result name | names used do not match Paper 1's printed titles in five cases; no numbers | P2X-24 |

---

## 3. Statuses against `CLAIMS.md`

`compare_status.out` lists 37 textual mismatches. All 37 are the ledger's parenthetical check ids ("(St c2(a); referee r2)"), which the paper correctly omits, or rewordings with the same content. No status differs in substance:
* no result is promoted from computed or known to proved;
* no proof sketch is presented as a proof;
* there are no conjectures;
* the one "illustration" (ex:split:noisyparity) says so in its title.

Every ledger id has an environment in the paper, and every environment has a ledger row, with one exception: `rem:teacher:numbers` carries the content of the ledger's `tab:teacher:numbers`.

Three ledger rows are stale; the paper is right in each case (P2X-41):
* `rem:absorb:examples`: the ledger says ξ₁ = U; the paper says ξ₁ ≤ U (correction 30 of the internal record).
* `cor:teacher:fulltable`: the ledger has λ ∈ (1, Nc_hi]; the paper has the open interval (correction 22).
* `tab:teacher:numbers`: the ledger says "nothing is proved in the top 0.6%"; the paper says "(iii) applies only for c < 0.99418·2^{−m}" and "in a band of relative width about 6% nothing useful is proved". Both statements are in the source (steeper notes-final lines 50 and 557) and are consistent.

Three environments are remarks with status "proved" and their argument inline: `rem:absorb:examples` (proof in App. B.1), `rem:absorb:condsemi` and `rem:split:siprograms` (both short, standard). This is acceptable.

---

## 4. arXiv conversion plan

### 4.1 Every environment whose status is not plain "proved"

Every `\status` (64) and every `\src` (73) is deleted, and the two macro definitions are removed from `preamble.tex`. The table gives, for each non-plain status, the academic form and the rewording. It is generated by `conversion_table.py`.

