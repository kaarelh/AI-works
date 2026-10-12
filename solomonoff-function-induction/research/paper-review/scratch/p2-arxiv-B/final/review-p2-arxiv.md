# Paper 2: consistency and arXiv-readiness review

**Paper.** "Steeper Simplicity Priors in Solomonoff Function Induction: Absorption, the Teacher's Mistakes and the Model–Randomness Split" (Kaarel Hänni), `paper-steeper/main.pdf` built 2026-10-12 16:59 (63 pages), sources `paper-steeper/sections/*.tex`, `paper-steeper/bib/*.bib`, `main.tex`, `preamble.tex`.

**Scope.** The seven points of a full arXiv-readiness review: (1) abstract, introduction and discussion against the body; (2) notation against `paper/NOTATION.md`; (3) statuses against `paper-steeper/CLAIMS.md`; (4) a complete arXiv conversion plan, including every mention of Wyeth; (5) every bibliography entry; (6) structure and length; (7) readability. The mathematics of the body is not re-proved here; the body's statements are taken as given, except for two independent numerical checks.

**Rules applied.** The three binding notes at the top of `paper-steeper/OUTLINE.md` (sole author with AI-assistance disclosure; standard academic paper for arXiv; no "Wyeth's objection", Wyeth not quoted, at most one neutral footnote on the LessWrong thread). Sources of claims: `research/tracks/{foundations,history,examples,context,steeper}/notes-final.md` (with `referee.md` and `checks/`) and `research/00-brief.md`; for quotations, `research/prior/` and the public repository `github.com/kaarelh/notes`.

**Independent checks** (all in `research/paper-review/scratch/p2-arxiv-B/`):
* `extract_status.py` → `envs.json`, `envs.txt`: all 73 theorem-like environments with label, `\status`, `\src`.
* `compare_status.py` → `compare_status.out`: statuses against `CLAIMS.md`.
* `process_vocab_p2.py` → `process_vocab.out`: process vocabulary, literature hedges, Wyeth, third-person references and script names in the visible text (comments, `\status`, `\src` stripped).
* `window_scope.py` → `window_scope.out`: re-implements the window and identification bounds of Theorem 4.7 from the paper's formulas. It reproduces Table 2(a) exactly, computes the e-bound over the whole window, and gives the window size as a function of the machine constant.
* `concentration_exponent.py` → `concentration_exponent.out`: the power-posterior exponent of Proposition 4.13.
* `conversion_table.py` → `conversion_table.md`: the arXiv conversion table of section 4.1.
* `bibcheck-log.md`: one line per bibliography entry.
* `make_issues.py` → `../../p2/issues-p2-arxiv.json` and `issue_list.md`.
* `main.txt`: pdftotext of the PDF.

**Working folder.** A second reviewer working in parallel used `scratch/p2-arxiv/` and overwrote several of this reviewer's files there (`conversion_table.*`, `process_vocab_p2.py`, `compare_status.out`). All files of this review are therefore kept in `scratch/p2-arxiv-B/`; anything in `scratch/p2-arxiv/` belongs to the other review.

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

| # | label | file:line | env | current \status | arXiv form | action |
|---|---|---|---|---|---|---|
| 1 | `rem:absorb:reading` | absorb.tex:37 | remark | remark; known | Remark | Delete tag. Keep the citation of Poland and Hutter (2005). Replace "a dog classifier with millions of bits certainly is" by "a model of millions of bits is longer than $\ell_U$ for any reasonable reference machine". |
| 2 | `prop:absorb:pricing` | absorb.tex:45 | proposition | proved; computed | Proposition (proof in App. B.3) | Delete tag. The value 2.5431 already reads "a direct computation (code in the accompanying repository) gives"; keep. |
| 3 | `rem:absorb:why` | absorb.tex:70 | remark | remark; cites proved results | Remark | Delete tag; cite the companion paper's results by number, not by informal name (P2X-24). |
| 4 | `prop:absorb:price` | absorb.tex:76 | proposition | proved; computed | Proposition (proof in App. B.4) | Delete tag; the computed check (24,732 cases) stays in App. B.4. Add "(semimeasure convention)" to (iv) (P2X-35). |
| 5 | `prop:absorb:history` | absorb.tex:85 | proposition | proved; computed | Proposition (proof in App. B.5) | Delete tag; the block-identity check stays in App. B.5. |
| 6 | `rem:absorb:wyeth` | absorb.tex:101 | remark | remark; cites proved results | Remark "Answer to the absorption objection" | Delete tag. Rename the label to rem:absorb:answer (arXiv distributes the source). In (ii) cite the grokking note, which contains the quoted sentence, instead of the LessWrong thread. In (iii) remove the quotation marks around "nothing is lost at $\lambda=1$" (P2X-33). |
| 7 | `prop:algstat:set` | algstat.tex:15 | proposition | proved; a natural reading refuted | Proposition + Remark | Delete tag. Move the refuted reading out of the statement into a short Remark: "The bounds do not show that $\lambda$ slightly above $1$ selects an approximately minimal sufficient statistic: as $\lambda\to1$ the length bound becomes vacuous." |
| 8 | `prop:algstat:coarse` | algstat.tex:44 | proposition | proved for computable hypotheses; that it is the standard set--distribution translation is believed (known; unverified) | Proposition (computable rational hypotheses) | Delete tag. Check Vereshchagin and Shen (2017; arXiv 1607.08077) for the set/distribution equivalence and cite the section, or delete "the thresholding above is presumably that translation" (P2X-19). |
| 9 | `prop:algstat:parity` | algstat.tex:57 | proposition | proved; computed | Proposition (proof in App. F.2) | Delete tag; numbers already in academic form (Table 3). |
| 10 | `rem:algstat:restricted` | algstat.tex:81 | remark | known; unverified (content per abstracts); remark | Remark | Delete tag. Read Vereshchagin and Vitanyi (2010) and Milovanov (2016) and rewrite without "As far as we can tell from the abstracts" and "A comparison with the full texts is left open" (P2X-16). |
| 11 | `rem:algstat:reading` | algstat.tex:85 | remark | remark | Remark | Delete tag; replace "Hanni's '1 bit paying for 1 bit'" and "as Hanni expected" by a citation of the note in the author's voice. |
| 12 | `lem:split:hash` | app-split.tex:46 | lemma | proved; computed | Lemma (App. E.3) | Delete tag. |
| 13 | `lem:teacher:sharpfloor` | app-teacher.tex:31 | lemma | proved; computed | Lemma (App. C.2) | Delete tag; replace "(script c7_run2.py, part (C), seed 7)" by the content-named script (P2X-39). |
| 14 | `prop:limits:plain` | limits.tex:10 | proposition | proved; computed | Proposition (proof in App. D.1) | Delete tag. |
| 15 | `rem:limits:schedule` | limits.tex:20 | remark | remark (from proved results); known | Remark | Delete tag. Keep the citations of Zhu and Srebro (2025) and Zhu, Ohannessian and Srebro (2026) after checking the full texts (P2X-15); replace "This confirms Hanni's remark" by "as anticipated in [grokking note]". |
| 16 | `prop:limits:envelope` | limits.tex:28 | proposition | proved; computed | Proposition (proof in App. D.4) | Delete tag. "the extension of Hanni's example ... is false" becomes "density and description length alone do not suffice"; keep the counterexample. |
| 17 | `prop:limits:rateblind` | limits.tex:46 | proposition | proved; computed | Proposition (proof in App. D.2) | Delete tag. |
| 18 | `lem:limits:robust` | limits.tex:57 | lemma | proved; computed | Lemma (proof in App. D.2) | Delete tag; rename the constants a, b (clash with the parity a and the behaviour b) to alpha_0, beta_0 (P2X-34). |
| 19 | `prop:limits:separable` | limits.tex:65 | proposition | proved; computed | Proposition (proof in App. D.3) | Delete tag. |
| 20 | `prop:limits:guard` | limits.tex:71 | proposition | proved; computed | Proposition (proof in App. D.3) | Delete tag; candidate for the appendix (P2X-26). |
| 21 | `prop:limits:noident` | limits.tex:77 | proposition | proved; computed; (i) known | Proposition (proof in App. D.3) | Delete tag; (i) keeps the citation of Gneiting and Raftery (2007). |
| 22 | `rem:limits:method` | limits.tex:97 | remark | remark; computed | Remark | Delete tag. Replace "A window for p<0.123 and c well above 2^{-m} looks within reach but is not proved" by an open question (P2X-43). |
| 23 | `prop:related:computable` | related.tex:9 | proposition | proved; the examples are remarks | Proposition + Remark | Delete tag. Move the paragraph of examples (time-bounded classes, circuits) into a Remark after the proposition; it already says "constants not computed". |
| 24 | `rem:related:cold` | related.tex:24 | remark | known; remark | Remark | Delete tag. Check the definition of the cold posterior in Wenzel et al. (2020) (PMLR, open access). |
| 25 | `rem:related:nn` | related.tex:28 | remark | remark | Remark | Delete tag; attribute the "bridge question" to the companion paper (P2X-42). |
| 26 | `rem:related:mdl` | related.tex:34 | remark | known; unverified | Remark (Related work) | Delete tag. Read the three papers and state their results precisely; delete "As their abstracts describe them" and "can only be settled from the full texts" (P2X-15). |
| 27 | `rem:related:posteriors` | related.tex:38 | remark | known; unverified; remark | Remark (Related work) | Delete tag. Check the SafeBayes criterion in Grunwald (2012) and either state the consequence with its reason or delete the two sentences (P2X-18). |
| 28 | `rem:related:t5` | related.tex:42 | remark | remark | Remark (Related work) | Delete tag; cite the report once as [Cla26, Section 8], then "the earlier report" (P2X-23). |
| 29 | `rem:related:new` | related.tex:46 | remark | remark | Paragraph "Novelty" (Related work) | Delete tag; delete "though our search was limited to abstracts"; after the check of P2X-15/P2X-16 write "To our knowledge the following are new" (P2X-20). |
| 30 | `rem:setup:persample` | setup.tex:60 | remark | remark | Remark | Delete tag; replace "Hanni's remark that ..." by "as noted in [grokking note]". |
| 31 | `lem:setup:hull` | setup.tex:66 | lemma | proved; computed; strengthening of (iv) refuted | Lemma + Remark | Delete tag. Move the counterexample out of the statement into a Remark: "The converse in (iv) cannot be weakened to 'on the boundary of C': ...". The computed check stays in App. A.2. |
| 32 | `lem:split:ville` | split.tex:15 | lemma | proved; computed; Ville's inequality known | Lemma (proof in App. E.1) | Delete tag; Ville (1939) is already cited. |
| 33 | `lem:split:stream` | split.tex:27 | lemma | proved; computed | Lemma (proof in App. E.2) | Delete tag. |
| 34 | `prop:split:si` | split.tex:57 | proposition | proved; (iii) known | Proposition (proof in App. E.4) | Delete tag; (iii) already cites Li and Vitanyi (2008). |
| 35 | `thm:split:private` | split.tex:68 | theorem | proved; computed; Kakutani-type argument known | Theorem (proof in App. E.5) | Delete tag; Kakutani (1948) is already cited. |
| 36 | `rem:split:reading` | split.tex:80 | remark | remark | Remark | Delete tag; "the split Hanni hoped for" becomes "the split asked for in Section 1". |
| 37 | `thm:split:shared` | split.tex:86 | theorem | proved; computed | Theorem (proof in App. E.6) | Delete tag. |
| 38 | `ex:split:noisyparity` | split.tex:99 | example | computed; illustration | Example | Delete tag; the title already says "an illustration". |
| 39 | `rem:teacher:hanni` | teacher.tex:10 | remark | computed | Example "The three-hypothesis calculation" | Delete tag; retitle without the author's name (P2X-12). |
| 40 | `lem:teacher:list` | teacher.tex:40 | lemma | proved; computed | Lemma (proof in App. C.1) | Delete tag. |
| 41 | `lem:teacher:floor` | teacher.tex:46 | lemma | proved; computed | Lemma (proof in App. C.2) | Delete tag. |
| 42 | `rem:teacher:numbers` | teacher.tex:107 | remark | computed | Remark "Numbers for the running example" | Delete tag; retitle (P2X-12). |
| 43 | `rem:teacher:hypotheses` | teacher.tex:141 | remark | remark | Remark | Delete tag. |
| 44 | `cor:teacher:fulltable` | teacher.tex:149 | corollary | proved; computed | Corollary (proof in App. C.4) | Delete tag; print the computed window as an open interval at the right end (P2X-31). |
| 45 | `cor:teacher:sampled` | teacher.tex:160 | corollary | proved; computed | Corollary "Finite samples" | Delete tag; retitle without the author's name. |
| 46 | `ex:teacher:version1` | teacher.tex:166 | example | proved (instance of Thm 4.7); computed | Example "The total-bits version of the example" | Delete tag and "(instance of Theorem 4.7)"; write "By Theorem 4.7 with d=100, m=10, p=2^{-6}, ..." in the text. |
| 47 | `prop:teacher:concentration` | teacher.tex:172 | proposition | proved; computed | Proposition (proof in App. C.7) | Delete tag; in App. C.7 correct "-1000+242.3" to "-1000+241.7" (P2X-32). |

Plain "proved" (17; delete the tag and the \src note only): `rem:absorb:examples`, `thm:absorb:absorption`, `cor:absorb:nouniversal`, `rem:absorb:condsemi`, `prop:absorb:inputs`, `prop:algstat:product`, `lem:teacher:finite`, `prop:limits:inputlaw`, `prop:limits:ood`, `prop:related:computability`, `lem:setup:basic`, `lem:setup:coding`, `thm:split:lambda1`, `rem:split:siprograms`, `lem:teacher:coding`, `lem:teacher:twopart`, `thm:teacher:main`.

Definitions (9; no status; delete the \src note only): `def:algstat:set`, `def:algstat:product`, `def:setup:data`, `def:setup:product`, `def:setup:shared`, `def:setup:class`, `def:setup:objectives`, `def:split:setting`, `def:teacher:instance`.


### 4.2 Every process-vocabulary passage in the visible text

This section covers what remains once the `\status`/`\src` markers (4.1) and Appendix H (4.4) are gone. The list comes from `process_vocab.out`, filtered by hand. Ordinary English uses are excluded ("selection tracks population selection", "a dovetailed search"). So is the title-page footnote's "independent AI referees", which the binding note prescribes.

| # | file:line | passage | replacement |
|---|---|---|---|
| V1 | intro.tex 14 | "lists Hänni's specific claims with their verdicts" | "lists the questions raised in [grokking note] and where they are answered" |
| V2 | intro.tex 27, 43 | Table 1 header "Claim & Verdict & Where"; caption "Hänni's specific claims about the proposal \citep{...,hanni2026request}, with verdicts" | header "Question & Answer & Where"; caption "Questions raised in the author's notes [grokking note] and where they are answered. Numbers with κ = 0 are illustrations." |
| V3 | intro.tex 46 | "as their abstracts describe them" | state what the papers prove (P2X-15) |
| V4 | intro.tex 46 | "Our literature search went only as far as abstracts, so the novelty claims of Remark 8.8 need a check against full texts." | delete (P2X-14, P2X-20) |
| V5 | intro.tex 48 | "which are cited in the third person, as Hänni's" | delete (P2X-12) |
| V6 | intro.tex 12, 43, 48; split.tex 5, 55 | `\citep{hanni2026request}` (prints "Personal communication to the author ... 00-brief.md") | author's voice; Eisenstat as personal communication (P2X-07) |
| V7 | setup.tex 48 | "are reported to appear in MDL convergence theory" | verified statement with chapter, or delete (P2X-17) |
| V8 | absorb.tex 105 | ``nothing is lost at λ = 1'' (an earlier draft's claim, in quotation marks) | "restricting to private randomness is not free at λ = 1 when compared with M_F" (P2X-33) |
| V9 | teacher.tex 8, 10, 107, 160, 166 | headings "Hänni's calculation" (subsection and remark), "Numbers at Hänni's sizes", "Hänni's numbers with sampled data", "Hänni's Version 1, in population form" | "The three-hypothesis calculation", "Numbers for the running example", "Finite samples", "The total-bits version of the example" (P2X-12) |
| V10 | limits.tex 89 | `\citep[H\"anni's proposition, with no log term]{...}` | the companion's result number (P2X-24) |
| V11 | limits.tex 98 | "looks within reach but is not proved" | open question (P2X-43) |
| V12 | algstat.tex 48 | "the thresholding above is presumably that translation" | verify or delete (P2X-19) |
| V13 | algstat.tex 82 | "As far as we can tell from the abstracts, ...", "A comparison with the full texts is left open." | after reading, a plain statement (P2X-16) |
| V14 | related.tex 35 | "As their abstracts describe them", "Their abstracts do not mention ...; whether their analysis covers some of this can only be settled from the full texts." | P2X-15 |
| V15 | related.tex 39 | "This is our reading, not checked against the papers' precise criteria." | P2X-18 |
| V16 | related.tex 47 | "We have not found the following in the literature, though our search was limited to abstracts:" | "To our knowledge the following are new:" after the check (P2X-20) |
| V17 | related.tex 51 | "And the novelty claims of Remark 8.8 remain to be checked against the full texts of ..." | delete |
| V18 | discussion.tex 26 | open problem "(8) Literature. The novelty claims ... need a comparison with the full texts ..." | delete |
| V19 | discussion.tex 30 | "and the comparison with the literature rests on abstracts and search snippets" | delete (after P2X-15 to P2X-20) |
| V20 | discussion.tex 33 | "the research notes with full proofs from which the paper was written are in the folder solomonoff-function-induction/research/tracks/steeper/" | new Code and data statement (4.5; P2X-21) |
| V21 | app-teacher.tex 56, 125, 137, 196, 216, 220; app-limits.tex 10, 12, 37, 65, 102 | script names `c6_revision.py`, `c7_run2.py` | content names (P2X-39) |
| V22 | app-teacher.tex 220; app-related.tex 46 | "were re-run from scratch copies and reproduce" | "reproduce" |
| V23 | app-teacher.tex 17, 125; app-limits.tex 65, 127; app-split.tex 42, 95, 101; app-absorb.tex 48 | "an independent computation/re-implementation" | acceptable once the Code and data statement says that independent implementations are included (4.5) |
| V24 | 65 visible "Hänni" and 19 "his/he" | third-person voice | P2X-12 |

### 4.3 Every mention of Wyeth, and how to remove it

**In the PDF (17 lines):**
* pp. 3 (×3), 5 (×2), 7, 8 (×2), 9 (footnote), 12, 13, 14, 19, 20 and 32 print "(Hänni and Wyeth, undated)";
* p. 34 prints the bibliography entry "Kaarel Hänni and Cole Wyeth. Comments in the thread ...";
* p. 62 (Appendix H.6) prints the citation again.

**In the source** (public on arXiv):
* the label `rem:absorb:wyeth` (absorb.tex 5, 101; intro.tex 16);
* `bib/core.bib` line 28 and `bib/all.bib` line 31 (`author = {H{\"a}nni, Kaarel and Wyeth, Cole}`);
* `main.bbl` lines 112–113;
* comments in absorb.tex 2 and intro.tex 7 (harmless wording, but they would be public).

**Not present:** no quotation of Wyeth's comment (checked against `research/prior/hanni-lesswrong-comment-thread.md`). No heading, theorem or remark is named after him. The visible title of `rem:absorb:wyeth` is "Answer to the absorption objection", as required. The paraphrase of the objection at intro.tex 12 and absorb.tex 5 is close to his wording ("a universal distribution which penalizes complexity minimally as usual"), but it is not a quotation and describes a standard point. That is acceptable once the point is attributed to algorithmic statistics (P2X-09).

**Replacement map for the 15 body citations of `hanni2026lesswrong`.** "Grokking note" means `philosophy/philosophy of thinking/beating solomonoff induction at grokking a notion.md` in github.com/kaarelh/notes, verified public (WebFetch, 2026-10-12).

| .tex line | what is cited | in the grokking note? | action |
|---|---|---|---|
| intro 10 | "each input gets its own private randomness" | yes (messy notes, second draft) | cite the note |
| intro 12 (1st) | "I don't see how to write down a universal hypothesis that gets good loss here" | yes | cite the note |
| intro 12 (2nd) | "Maybe I'm just failing ...", "some other pathology", "somewhat cherry-picked for the idea to work" | first two yes; "cherry-picked" no | cite the note; restate "cherry-picked" in the author's voice ("the example was chosen to favour the idea") |
| intro 43 | Table 1 caption | n/a | cite the note only |
| intro 48 | credits | n/a | cite the note only |
| setup 48 | "a higher coefficient on the length of the program than on the likelihood terms"; "penalize the likelihood term less" | yes, both | cite the note |
| setup 61 | "we will need to increase the hypothesis term coefficient ... as the data set size increases" | yes | cite the note |
| setup 64 | "the `good model' could be a vertex of the convex hull ..." | yes | cite the note |
| absorb 5 | footnote "It was also raised in the comment thread ..." | n/a | keep as the one neutral footnote with a sole-author entry and a real date, or delete |
| absorb 104 | "if each input gets its own private randomness, then I don't see how ..." | yes | cite the note |
| teacher 11 | the two versions of the example | yes (Version 2 wording there: "with those inputs taking 10000 bits to specify") | cite the note; quote its wording |
| teacher 16 | "Maybe I'm just failing to construct the right `universal hypothesis' ..." | yes | cite the note |
| limits 21 | "we will need to increase the hypothesis term coefficient ..." | yes | cite the note |
| limits 44 | "definitely somewhat cherry-picked for the idea to work, though I also don't consider it completely contrived" | no | restate in the author's voice, no quotation |
| discussion 9 | "it's very unlikely this steeper penalization is anywhere close to a full solution ...", "some hope that it works in some specific toy cases" | no | restate in the author's voice ("We do not expect steeper penalisation to solve the general problem; ...") |

After this, `hanni2026lesswrong` is cited at most once (the footnote). Rename the label to `rem:absorb:answer`. The tarball check of 4.6 must find no "Wyeth".

### 4.4 The internal-record appendix and the `\ifsfirecord` switch

`main.tex` lines 9–13 define `\newif\ifsfirecord` and set `\sfirecordtrue`; line 46 inputs `sections/app-verification.tex` (Appendix H, pp. 58–63) when the switch is true. The appendix's own first paragraph says that the arXiv version sets `\sfirecordfalse`. That is not sufficient, because arXiv distributes the source and the file would be in it. Plan:

1. Delete lines 9–13 and the `\ifsfirecord` line from the arXiv copy of `main.tex`, and do not upload `sections/app-verification.tex`. Keep both on the working branch as the internal record.
2. What a reader needs from Appendix H is already elsewhere or moves:
   * H.1 (preparation) is covered by the acknowledgements paragraph (4.5).
   * H.2 (referee rounds): one clause in the acknowledgements ("refereed in two rounds with independently written code") is enough.
   * H.3 (scripts and reproduction) moves into Code and data and Appendix C.8, with neutral script names.
   * H.4 rows 1–3 (refuted statements) are already in the body (prop:limits:envelope, lem:setup:hull, prop:algstat:set). Rows 4–31 are internal corrections and are not printed.
   * H.5 (status of the claims): not printed. The theorem environments now carry this information.
   * H.6 (references not checked): resolved by P2X-14 to P2X-20 and section 5, not printed.
   * H.7 (open issues of this draft): resolved by P2X-26, P2X-05/06 and P2X-24, not printed.

### 4.5 Acknowledgements and Code and data (proposed text)

The title-page footnote already matches the binding note word for word and can stay.

**Acknowledgements.** "This paper was developed and written with extensive assistance from Claude (Anthropic), an AI system. Under the author's direction, Claude produced the proofs, the computations and the text. Separate instances checked the proofs in two adversarial rounds and re-implemented the main computations independently. The earlier report [Cla26], whose results are re-derived here, was prepared in the same way. No human has yet independently checked all of the mathematics. The author thanks Sam Eisenstat for the coin example discussed in Section 6.2 and in the companion paper."

**Code and data.** "All numerical statements are produced by deterministic or seeded Python 3.11 scripts (NumPy, SciPy). The scripts, their saved outputs and independent re-implementations of the main computations are in the folder `solomonoff-function-induction/code/steeper/` of https://github.com/kaarelh/AI-works (release <tag>). Appendix C.8 lists the script for each computation."

This requires publishing the scripts to main under a neutral path, with names by content, and pinning a tag (P2X-21, P2X-39).

### 4.6 Mechanical steps, in order

1. Resolve the content issues first: P2X-01 to P2X-04 (front and back matter), P2X-09 and P2X-15 to P2X-20 (literature), P2X-05 to P2X-08 and P2X-22, P2X-23 (sources). Steps 2–10 are mechanical.
2. Delete every `\status{...}` and `\src{...}` (a brace-matching script such as `extract_status.py` can do it); apply the rewordings listed in 4.1.
3. Apply 4.2 (V1–V24) and 4.3.
4. Rename `rem:absorb:wyeth` → `rem:absorb:answer` (3 places).
5. Retitle the four theorem-like headings and Section 4.1 (V9); rewrite Table 1.
6. Replace the open-question cross-references (P2X-25); cite Paper 1 by number (P2X-24).
7. Delete the `\ifsfirecord` lines and leave out `app-verification.tex` (4.4).
8. Replace the acknowledgements and Code and data statements (4.5).
9. Fix the bibliography (section 5); rebuild; check that the printed bibliography has no "undated", "personal communication", "Draft", "prepared for".
10. Make the arXiv folder:
    * `latexpand main.tex > arxiv/main.tex`;
    * strip comments (arxiv_latex_cleaner);
    * copy `main.bbl` (not the `.bib` files);
    * add `\hypersetup{pdftitle=..., pdfauthor=...}` (P2X-40);
    * compile there twice;
    * `grep -i -E 'wyeth|track|referee|ledger|notes-final|brief|orchestrat|CLAIMS|OUTLINE|steep-[ab]|framing editor|unverified|snippet|abstracts? only|run2|revision\.py|scratch'` must return nothing. The only exception is "independent AI referees" in the footnote, which the binding note prescribes. "Claude" may appear only in the footnote and the acknowledgements.
11. Suggested arXiv categories: cs.LG (primary), cross-list cs.IT (math.IT) and stat.ML.

---

## 5. Bibliography: every entry in `bib/*.bib`

The bibliography has 42 entries in `bib/all.bib` (`core.bib` 27, `steep-a.bib` 9, `steep-b.bib` 6), of which 37 are cited and printed. Sources:
* "WS": this reviewer's WebSearch, 2026-10-12;
* "WS-P1": the Paper 1 review's same-day WebSearch log;
* "writer": the writers' bib comments only, because the shared search budget ran out.

Full log: `scratch/p2-arxiv-B/bibcheck-log.md`.

| key | printed | verdict | confirmed data / problem | action |
|---|---|---|---|---|
| hoeffding1963probability | yes | verified, fixable (WS) | JASA 58(301):13–30, doi 10.1080/01621459.1963.10500830 | add number, doi |
| sion1958general | yes | verified (WS) | Pacific J. Math. 8(1):171–176 | — |
| barron1991minimum | yes | verified (WS) | IEEE TIT 37(4):1034–1054 (correction Nov. 1991) | the content it is cited for is unverified (P2X-17) |
| gacs2001algorithmic | yes | verified (WS) | IEEE TIT 47(6):2443–2463 | — |
| vereshchagin2004kolmogorov | yes | verified (WS) | IEEE TIT 50(12):3265–3290 | — |
| vereshchagin2010rate | yes | verified (WS) | IEEE TIT 56(7):3438–3454; abstract matches rem:algstat:restricted's description | read the full text (P2X-16) |
| vereshchagin2017algorithmic | yes | verified (WS) | LNCS 10010:669–737; arXiv 1607.08077 | check the cited equivalence (P2X-19) |
| grunwald2007minimum | yes | verified (WS) | MIT Press 2007 | content (P2X-17) |
| gneiting2007strictly | yes | verified (WS) | JASA 102(477):359–378; the abstract's definition of strict propriety matches prop:limits:noident(i) | — |
| grunwald2012safe | yes | verified, fixable (WS) | ALT 2012, LNCS 7568:169–183, doi 10.1007/978-3-642-34106-9_16 | add doi; content (P2X-18) |
| grunwald2017inconsistency | yes | verified, fixable (WS) | Bayesian Anal. 12(4):1069–1103, doi 10.1214/17-BA1085 | add doi |
| zhang2006epsilon | yes | verified, fixable (WS) | Ann. Statist. 34(5):2180–2210, doi 10.1214/009053606000000704 | add doi |
| bissiri2016general | yes | verified, fixable (WS) | JRSS-B 78(5):1103–1130, doi 10.1111/rssb.12158 | add doi |
| bhattacharya2019fractional | yes | verified, fixable (WS) | Ann. Statist. 47(1):39–66, doi 10.1214/18-AOS1712 | add doi |
| li2008introduction | yes | verified (WS) | Springer 3rd ed. 2008 | — |
| solomonoff1978complexity | yes | verified (WS) | IEEE TIT IT-24(4):422–432 | — |
| poland2005asymptotics | yes | verified (WS) | IEEE TIT 51(11):3780–3795; the abstract confirms "exponentially worse than Bayes" (rem:absorb:reading) | — |
| kakutani1948equivalence | yes | verified (WS) | Ann. of Math. 49(1):214–224 | — |
| ville1939etude | yes | verified, fixable (WS) | Monographies des Probabilités, fasc. III, Gauthier-Villars 1939 (also Numdam thesis no. 218) | add series |
| hanni2026notes | yes | source verified; entry unfit | public repo; grokking note and SFI note located | replace by two specific entries (P2X-08) |
| claude2026whatfollows | yes | source verified (public on main); entry fixable | inferential-learning/ on main; Section 8 | URL, year, author line, drop "prepared for" (P2X-23) |
| grunwald2007suboptimal | yes | verified, fixable (WS-P1) | Machine Learning 66(2–3):119–149, doi 10.1007/s10994-007-0716-7 | add number, doi; content (P2X-15) |
| zhu2025quantifying | yes | verified (WS-P1) | COLT 2025, PMLR 291:6124–6155 | content (P2X-15) |
| zhu2026overfitting | yes | verified (WS-P1) | arXiv:2603.22644 | content (P2X-15) |
| vaintrobhanni2026nnbayes | yes | verified against the local copy only | URL not reachable or found | check the URL (P2X-38) |
| koppel1987complexity | yes | writer only | Complex Systems 1(6):1087–1091 | re-check (P2X-37) |
| koppel1991almost | yes | writer only | Inform. Sci. 56:23–33 | re-check |
| vitanyi2006meaningful | yes | writer only | IEEE TIT 52(10):4617–4626 | re-check |
| antunes2009sophistication | yes | writer only | Theory Comput. Syst. 45(1):150–161 | re-check |
| milovanov2016algorithmic | yes | writer only; conflict | the steeper notes say "exact title and pages unverified", the bib comment says confirmed | re-check title and pages |
| cover2006elements | yes | writer only | Wiley 2nd ed. 2006 | re-check (low risk) |
| goldreich1989hard | yes | writer only | STOC 1989, 25–32 | re-check (low risk) |
| kushilevitz1993learning | yes | writer only | SIAM J. Comput. 22(6); pages copied from a sibling project | confirm pages |
| wenzel2020good | yes | writer only | ICML 2020, PMLR 119:10248–10259 | re-check |
| hanni2026lesswrong | yes | **unverifiable; violates the binding note** | "undated", "text as pasted", Wyeth as co-author | drop (P2X-05, P2X-06) |
| hanni2026request | yes | **unverifiable; not a source** | private message to the AI system, path to the brief | drop (P2X-07) |
| claudeSFI2026fundamentals | yes | **not yet public** | folder not on main (404) | arXiv id or published URL (P2X-22) |
| claudeSFI2026steeper | no | self-reference | — | — |
| littlestone1988learning | no | verified (WS-P1) | — | not printed |
| barzdin1972prediction | no | fixable (WS-P1) | pages 1224–1228 | not printed |
| gold1967language | no | verified (WS-P1) | — | not printed |
| vovk2005algorithmic | no | verified (WS-P1) | — | not printed |

Totals over the 37 printed entries:
* 19 verified by this reviewer's WebSearch, 7 of them needing a DOI, issue number or series;
* 2 verified as sources, but the entries need rewriting;
* 4 verified by WS-P1;
* 9 rest on writer records only;
* 3 are not usable as printed.

---

## 6. Structure and length against a typical arXiv paper

| | this paper | typical arXiv paper in learning theory / AIT | outline budget |
|---|---|---|---|
| pages | 63 (1 title/abstract, 1 TOC, 30 main, 2.5 references, 22 appendices A–G, 5.5 internal record) | 25–45 including appendices | main 21, appendices ≈ 20 |
| theorem-like environments in the main text | 70 (5 theorems, 20 propositions, 10 lemmas, 3 corollaries, 21 remarks, 9 definitions, 2 examples) | 10–25 | — |
| in the appendices | 3 lemmas | most auxiliary lemmas | — |
| introduction | 3 pages with a full-page table; no informal theorem statement | 2–3 pages with 2–4 informal main results | 1.5 |
| related work | "Prior work" paragraph in the introduction, plus Section 8 (which also proves two propositions) | one section, early or late, without results | — |
| figures | none | 1–3 (e.g. a hull or structure-function plot) | — |
| open questions | a paragraph at the end of five sections plus a collected list | one list | — |

The standard elements are present: abstract, introduction with contributions, preliminaries (Section 2), results, discussion with open problems, references, appendices with proofs. The binding note's order would put related work before the preliminaries. The main text should shrink to about 20–22 pages. The moves are listed in P2X-26; the theorem restructuring in P2X-27. After the moves the main text would contain:
* Theorem 3.2 with Corollary 3.5 and Proposition 3.8;
* a simplified Theorem 4.7 with Table 2(a);
* Propositions 5.1, 5.3, 5.4 and Lemma 5.5;
* Theorems 6.4, 6.6 and 6.8;
* Proposition 7.6.

---

## 7. Readability

### 7.1 Proposed abstract (199 words)

> Solomonoff function induction (SFI) predicts labels from inputs with a universal prior over random partial functions. We analyse a proposal from the author's notes: penalise program length λ > 1 times more than log-loss, over hypotheses that use private randomness for each input, so that the selected hypothesis is a simple model with noise rather than a model of the teacher's errors. A standard objection is that a universal mixture, taken as one hypothesis, then wins. We show that it does in every class containing its own Bayes mixture, including Solomonoff induction and shared-randomness SFI, while no private-randomness hypothesis is universal; the price is a constant factor on latent causes shared by inputs. For a random parity on uniform inputs with errors on a junta-shaped set incompressible relative to the parity and flip rate below 0.056, we prove that for λ = cn, with n the sample size and c in an explicit window, every near-optimal hypothesis of the population objective knows the parity and holds little information about the errors. The window needs λ ∝ n and fails partly for some compressible error rules. At λ = 1 a sampler and programs filling in its random bits get similar posterior; for λ > 1, private randomness selects a sampler, shared randomness a universal mixture.

### 7.2 The first page

The first paragraph is mostly quotation of informal notes (P2X-13). The reader learns the problem ("learn what the teacher means, not what the teacher says") only through four quoted fragments. Suggested opening: "A learner trained on labels from a fallible teacher should ideally learn the teacher's intended concept, not the teacher's mistakes. Bayesian prediction with a universal prior, whether Solomonoff induction or its supervised counterpart SFI, does the opposite: it learns every computable regularity of the labels, the mistakes included. The author has proposed [grokking note] a steeper simplicity prior ..." Then the objective J_λ, and then an informal statement of the three main results as "Theorem 1 (informal)", "Theorem 2 (informal)", "Theorem 3 (informal)".

### 7.3 The central theorem

Theorem 4.7 needs about 40 symbols, five parts and sub-parts (a)–(e) (P2X-27). The table that follows it is what a reader remembers: window (9.54·10⁻⁷, 8.06·10⁻³]; at c = 10⁻⁴, u ≥ 0.983, ℓ ≤ d + 20.4, I ≤ 37.7, e ≤ 0.199. The main text should state a simplified form with B = ∞ and ε = 0 and the constants absorbed into O(log d + κ). The full form, with truncation level B, ε-slack and parts (iii)–(iv), goes to Appendix C.

### 7.4 Voice

The paper should speak as its author (P2X-12):
* "our proposal [grokking note]" or "the proposal of [grokking note]", not "Hänni's proposal";
* "the original sizes", not "Hänni's sizes";
* no "Verdict" column grading the author.

The third person is acceptable only where the earlier report, written by someone else, is discussed.

### 7.5 A figure

One figure would help readers more than several pages of remarks: the (length, risk) plane at the original sizes, with the coin, the good model, the memoriser, the lower hull, and the window of slopes (2^{−m}, c_hi]. The envelope of Proposition 5.3 can be added to show where the trick fails. A second candidate shows the set and product structure functions of the noisy parity, with the kink at α ≈ d (Proposition 7.6).

---

## 8. Numbered issue list

Severity: **fatal** = false or unsupported mathematical claim, or a claim stronger than the sources. **Major** = missing hypothesis, wrong number, inconsistency, misleading framing, an arXiv-standard violation a reader would notice, or a passage a reader cannot follow. **Minor** = local wording or formatting. The same list is in `issues-p2-arxiv.json`.

**P2X-01 (fatal)**: `paper-steeper/sections/discussion.tex`, line 9, paragraph "The gap to realistic errors": "for such errors the trick provably fails".  
*Problem.* The discussion states as proved that the trick fails for human labelling errors that are cheap, frequent patterns. The body proves failure only inside its instance: a random parity on uniform inputs, junta-shaped error sets, and either (a) one constructed rule (a cheap subcube plus random points) on part of the window, or (b) a fixed cheap rule once the parity length d exceeds d_0(kappa). Nothing is proved for other model classes, other input laws or other cheap patterns. This is a claim stronger than the body and the source.  
*Evidence.* prop:limits:envelope (limits.tex 28-44): one rule (j=13: 128 cheap + 896 random points), failure only for c < c_env, '31% of the logarithmic width ... (25% at kappa=30)'; 'above c_env nothing is proved for it'. prop:limits:rateblind and lem:limits:robust: under condition (star), which holds only for d >= d_0(kappa) (e.g. d_0=49 at kappa=0, 169 at kappa=30 for a 3-bit prefix). steeper notes-final §0 item 2: 'Density and description length do not suffice' (an existence statement), and §2.6(b) (for a fixed cheap rule and d >= d_0(kappa)). q:limits:open: 'Which structured error rules leave a window? ... A theory for realistic, low-complexity human errors is the main gap'.  
*Fix.* Replace the sentence by: "Human labelling errors are often cheap, frequent patterns rather than incompressible sets. In the parity instance the trick provably fails for such errors in two ways: a fixed cheap rule defeats every c once the simple model is long enough (Proposition 5.4, Lemma 5.5), and a rule made of a cheap region plus random points, with the original density and description length, makes the good model non-optimal on about a third of the window (Proposition 5.3). Whether any window survives for structured errors in general is open."

**P2X-02 (major)**: `paper-steeper/sections/abstract.tex`, line 3, sentences "For a random parity with a systematic error rule ... gives the erroneous labels little probability. In the original example the window spans three orders of magnitude"; also intro.tex line 17 (Contributions, second bullet: "gives the erroneous labels small average probability").  
*Problem.* The abstract states the teacher's-mistakes theorem without four of its hypotheses and overstates its conclusion. (1) The theorem is about the population objective J_c, not the empirical lambda-MAP at sample size n; the finite-sample version needs about 10^11 samples at the example's sizes. (2) Inputs must be uniform; (3) the error set must have product (junta) form; (4) the flip rate must be below 0.056 (otherwise c_hi <= 0). (5) 'Little probability' for the erroneous labels: the proved bound on their average probability is never below 0.194 anywhere in the window (kappa=0) and 0.268 (kappa=30), against 2^-10 for the good model; for the total-bits version of the example the bound is vacuous. (6) 'Spans three orders of magnitude' holds for machine constants up to about 300 bits only; the abstract does not mention the machine constant.  
*Evidence.* thm:teacher:main (teacher.tex 78-101): population quantities R, J_c (def:teacher:instance(c): 'Inputs are uniform'), E = S x {0,1}^{d-m}, 'c_hi > 0 requires G_1 > H(p); with B = inf this holds iff p < 0.0560'. tab:teacher:numbers: e <= 0.199 (kappa=0), 0.274 (kappa=30) at c=1e-4. ex:teacher:version1: '(e) is vacuous because s_0=16 is too small'. cor:teacher:sampled and text after it: n = 10^11 to 10^13. rem:teacher:hypotheses lists the five hypotheses. Independent check scratch/p2-arxiv-B/window_scope.py (.out): reproduces Table 2(a) exactly; minimum of the e-bound over the whole window 0.194 (kappa=0), 0.268 (kappa=30); window ratio c_hi*2^m = 8453 (kappa=0), 3837 (30), 1004 (300), 811 (400).  
*Fix.* Abstract: "For a random parity on uniformly distributed inputs whose labels are flipped on a junta-shaped error set that is incompressible relative to the parity, with flip rate below 0.056, we prove that for lambda = cn with c in an explicit window every near-optimal hypothesis of the population objective knows the parity, holds little information about the error set and gives the erroneous labels average probability at most about 0.2 at the sizes of the original example (a memoriser gives 1). For machine constants up to 30 bits the window spans more than three orders of magnitude." Intro bullet 2: replace "small average probability" by "average probability at most 0.199 (kappa=0) or 0.274 (kappa=30) at the example's sizes" and add "(population objective; uniform inputs)".

**P2X-03 (major)**: `paper-steeper/sections/abstract.tex`, line 3, last sentence "for lambda > 1 the sampler wins with private but not with shared randomness"; also split.tex section title 6.3 "the sampler wins".  
*Problem.* Two missing qualifications. (a) Private randomness: the theorem does not say that the sampler nu is selected. It says a lambda-MAP is at most (k+delta*)/(lambda-1) bits longer than nu's program, is not a fill-in once the sampled randomness is large, and (for infinite input sequences only) is eventually nu-equivalent on the run; rem:split:reading says explicitly 'not necessarily nu'. (b) Shared randomness: the universal mixture beats only samplers with (lambda-1)k > lambda*l_U + kappa_0, i.e. longer than l*_lambda; short samplers are not excluded.  
*Evidence.* thm:split:private (i)-(iv); rem:split:reading: 'The selected model is a sampler, not a fill-in, but not necessarily nu: it may carry up to (k+delta*)/(lambda-1) bits beyond the sampler ... On a finite domain such as {0,1}^d, (iv) is vacuous.' thm:split:shared (i): 'if (lambda-1)k > lambda l_U + kappa_0, then ... the sampler program is never a lambda-MAP'.  
*Fix.* Abstract: "for fixed lambda > 1, private randomness selects a sampler rather than a fill-in, while with shared randomness a short universal mixture beats every sampler longer than about l_U." Retitle Section 6.3 "lambda > 1 with private randomness: samplers beat fill-ins".

**P2X-04 (major)**: `paper-steeper/sections/split.tex`, line 5 ("up to explicit factors that do not depend on how much randomness was sampled"); discussion.tex line 11 ("indifferent, up to bounded factors").  
*Problem.* Inconsistent with the paper's own lemma. The lower end of the posterior odds in Theorem 6.4 is 2^{-2log(t_n+1)-kappa}, and t_n depends on beta_n = min nu(y_i|x_i), hence (triply logarithmically) on the sampled randomness and on n; the upper end 2^{k+delta*} contains the random Ville deficiency. So the factors are neither independent of the sampled randomness nor bounded.  
*Evidence.* lem:split:stream (split.tex 32): 'the cost 2log(t_D+1) is doubly logarithmic in d and triply logarithmic in n and in the sampled randomness -log nu(D)'. thm:split:lambda1 (iii) bounds involve t_n and delta*. Source steeper notes-final §0 item 3 states the doubly/triply logarithmic dependence.  
*Fix.* split.tex line 5: "up to explicit factors: 2^{k+delta*} in one direction and 2^{2log(t_n+1)+kappa} in the other, where 2log(t_n+1) grows only triply logarithmically in n and in the sampled randomness". discussion.tex line 11: replace "up to bounded factors" by "up to factors that grow at most triply logarithmically in the amount of data".

**P2X-05 (major)**: `paper-steeper/bib/core.bib (entry hanni2026lesswrong) and every \citep of it`, core.bib line 28 (author = {Hänni, Kaarel and Wyeth, Cole}); printed in the PDF 17 times: pp. 3 (x3), 5 (x2), 7, 8 (x2), 9 (footnote), 12, 13, 14, 19, 20, 32, 34 (bibliography), 62; .tex citations: intro.tex 10, 12 (x2), 43, 48; setup.tex 48, 61, 64; absorb.tex 5, 104; teacher.tex 11, 16; limits.tex 21, 44; discussion.tex 9; app-verification.tex 115, 129.  
*Problem.* Wyeth is named in the printed paper 17 times: every citation of the author's own LessWrong comments renders as "(Hänni and Wyeth, undated)", and the bibliography lists "Kaarel Hänni and Cole Wyeth" as authors. The binding note requires that Wyeth not be named (at most one neutral footnote may record that the point was raised in the thread); this review's brief requires every mention to go. The footnote at absorb.tex 5 therefore also names him through its citation. Blocking for arXiv.  
*Evidence.* pdftotext of main.pdf: 17 lines contain 'Wyeth' (pages 3,5,7,8,9,12,13,14,19,20,32,34,62). main.bbl lines 112-113: '\bibitem[H{\"a}nni and Wyeth(undated)]{hanni2026lesswrong} Kaarel H{\"a}nni and Cole Wyeth.' app-verification.tex 129 already notes the problem. No Wyeth quotation is printed (checked against research/prior/hanni-lesswrong-comment-thread.md), and no heading names him.  
*Fix.* Drop the entry hanni2026lesswrong (P2X-06). Every quotation it supports except three is also in the public grokking note: cite that note instead (see the replacement map in the review, section 4.3). Restate the three LessWrong-only remarks ("somewhat cherry-picked", "anywhere close to a full solution", "some specific toy cases") in the author's voice without quotation. If the neutral footnote is kept, cite a new entry with Hänni as sole author ("Comment on Jonas Hallgren's Shortform", LessWrong, <date>, <URL>), whose date the author checks.

**P2X-06 (major)**: `paper-steeper/bib/core.bib`, entry hanni2026lesswrong (year = {undated}, note = {Text as pasted by K. Hänni on 11 October 2026}).  
*Problem.* Unverifiable reference: no date, text known only as pasted into the preparation conversation, page unreachable and not found by search. The binding note allows only references whose bibliographic data have been checked.  
*Evidence.* WebSearch (2026-10-12) for the thread and for "Jonas Hallgren's Shortform" found neither; lesswrong.com and greaterwrong.com do not resolve (WebFetch: ENOTFOUND). core.bib comment: 'unverified: the LessWrong page did not resolve ...; The date of the comments is not known.' Printed year: 'undated'.  
*Fix.* Drop it (see P2X-05). If the author wants the thread cited, he supplies the comment's date and permalink and the entry names him alone.

**P2X-07 (major)**: `paper-steeper/bib/core.bib; intro.tex; split.tex`, entry hanni2026request; citations at intro.tex 12, 43, 48 (x2); split.tex 5, 55.  
*Problem.* A private message from the sole author to the AI system is cited 6 times as "Personal communication to the author, ... quoted verbatim in solomonoff-function-induction/research/00-brief.md". A sole author cannot cite a personal communication to himself, the entry exposes the preparation process ("Request for a paper", the brief file), and it is not a checkable source.  
*Evidence.* main.bbl: 'Kaarel Hänni. Request for a paper on Solomonoff function induction. Personal communication to the author, 11 October 2026; quoted verbatim in solomonoff-function-induction/research/00-brief.md in the accompanying repository'. The quoted sentence ('a preference for a simple sampler over a model where the sampled bits are filled in (solomonoff doesn't have a preference here, both get similar posterior)') occurs only in research/00-brief.md, not in the public notes (grep of the local clone of github.com/kaarelh/notes).  
*Fix.* Drop the entry. intro.tex 12 and split.tex 5: pose the question in the author's voice without quotation ("A second question is whether a steeper prior prefers a simple sampler to programs in which the sampled bits are filled in; at lambda = 1, Solomonoff induction has no such preference."). split.tex 55 and intro.tex 48: "Sam Eisenstat's coin example (S. Eisenstat, personal communication; see also [companion paper])". Remove the key from Table 1's caption.

**P2X-08 (major)**: `paper-steeper/bib/core.bib`, entry hanni2026notes (title = {notes}); 15 citations.  
*Problem.* The entry cites a whole public repository under the title "notes", with no file, date or version. The quotations it supports come from two specific notes; a reader cannot find them from the entry.  
*Evidence.* WebFetch github.com/kaarelh/notes: public repository, description 'some of my notes from 2023-2026'. File 'philosophy/philosophy of thinking/beating solomonoff induction at grokking a notion.md' exists and contains 'an even stronger simplicity prior than solomonoff', the 'messy notes' section and 'predicts $100$ bits per specification bit'. The 'computably samplable' quotations (setup.tex 8, absorb.tex 108) are in 'ai/learning/solomonoff induction/solomonoff function induction.md' (local clone, commit 541b175, 17 June 2026).  
*Fix.* Replace by two entries: Hänni, K. (2026). Beating Solomonoff induction at grokking a notion. Note, https://github.com/kaarelh/notes, file philosophy/philosophy of thinking/beating solomonoff induction at grokking a notion.md (commit 541b175, accessed <date>); and Hänni, K. (2026). Solomonoff function induction. Note, same repository, file ai/learning/solomonoff induction/solomonoff function induction.md. Cite each where its text is quoted.

**P2X-09 (major)**: `paper-steeper/sections/absorb.tex`, line 5 ("This is a standard point." with the only citation being the LessWrong footnote); intro.tex line 12 ("A standard objection").  
*Problem.* The paper calls the absorption point standard but cites no standard source; the only citation attached is the LessWrong thread (in the footnote) and the author's note. The binding note says the point is known in algorithmic statistics, and the paper may cite algorithmic statistics for it. A reader cannot check 'standard' as written.  
*Evidence.* absorb.tex 5: '...can absorb all the structure of the data. This is a standard point.\footnote{It was also raised in the comment thread ... \citep{hanni2026lesswrong}.}' OUTLINE.md binding note: 'Absorption by a universal hypothesis under a steeper penalty is a standard point. It is known in algorithmic statistics'. The relevant fact: if lower-semicomputable semimeasures are admitted as models, the universal semimeasure is a model of complexity O(1) that is optimal for every string, which is why algorithmic statistics restricts models to finite sets or computable distributions (surveyed in Vereshchagin and Shen 2017, already in the bibliography and open access at arXiv 1607.08077).  
*Fix.* After checking the passage, write: "This is a standard point: in algorithmic statistics, admitting the universal semimeasure as a model makes every string have an O(1)-complexity optimal two-part description, which is why models are restricted to finite sets or computable distributions (Gacs, Tromp and Vitanyi 2001; Vereshchagin and Shen 2017, Section <n>)." Keep the footnote only in the form of P2X-05's fix, or drop it.

**P2X-10 (major)**: `paper-steeper/sections/*.tex; preamble.tex`, 64 \status{...} and 73 \src{...} markers (all theorem-like environments).  
*Problem.* The PDF prints, in every theorem-like environment, a status tag and a grey source note in the vocabulary of the preparation process, e.g. 'Proposition 3.4 (Per-input pricing). [proved; computed] steeper Prop 1.3 (T5 Thm 2.1, Prop 2.2); check c2(a); referee r2'. 47 status tags are not plain 'proved', some outside any standard vocabulary ('proved for computable hypotheses; that it is the standard set--distribution translation is believed (known; unverified)', 'known; unverified (content per abstracts); remark').  
*Evidence.* scratch/p2-arxiv-B/envs.txt (73 environments; 47 non-plain statuses); main.txt lines 454, 573, 606, 648, 732, 807, 815, 819, 1059, 1195, 1269, 1279, 1294, 1668, 2449, 2730 (examples of printed markers).  
*Fix.* Apply the conversion table (review section 4.1; scratch/p2-arxiv-B/conversion_table.md): delete every \status and \src, then reword the nine environments whose status carries content, as listed there: refuted readings (lem:setup:hull, prop:algstat:set), unverified literature (prop:algstat:coarse, rem:algstat:restricted, rem:related:mdl, rem:related:posteriors), examples inside a proposition (prop:related:computable), 'instance of' (ex:teacher:version1) and speculation (rem:limits:method). Delete the \status and \src definitions from preamble.tex.

**P2X-11 (major)**: `paper-steeper/main.tex; paper-steeper/sections/app-verification.tex`, main.tex lines 9-13 (\newif\ifsfirecord, \sfirecordtrue) and line 46 (\ifsfirecord\input{sections/app-verification}\fi); Appendix H (pp. 58-63).  
*Problem.* The PDF contains Appendix H 'How the results were checked (internal record)', 5.5 pages of process material (tracks, referees with dates, a planning editor, section writers, a framing editor, a 31-row correction table, 'References not checked against the source', 'Open issues of this draft'). The binding note excludes a verification appendix. Setting \sfirecordfalse is not enough for arXiv, because arXiv distributes the uploaded source: the file and the switch would still be public.  
*Evidence.* main.toc: 'H How the results were checked (internal record) ... 58'; app-verification.tex lines 7 ('It is not part of the arXiv version ... switch \sfirecordfalse'), 11 ('Every role was played by a separate instance of Claude ...'), 111-121, 123-131.  
*Fix.* For the arXiv version: delete the \newif, \sfirecordtrue and the \ifsfirecord line from main.tex, and do not upload sections/app-verification.tex. What the appendix records that a reader needs moves as follows: the refuted statements (rows 1-3) are already in the body; the two refereeing rounds become one sentence in the acknowledgements (already there); the script table becomes part of the Code and data statement (P2X-21); the literature caveats are resolved by P2X-14 to P2X-20, not printed. Keep app-verification.tex on the working branch as the internal record.

**P2X-12 (major)**: `paper-steeper/sections/*.tex (65 occurrences of H\"anni in visible text, 19 of his/he)`, intro.tex 6-48 incl. Table 1 (tab:intro:claims, columns 'Claim | Verdict | Where'); headings: teacher.tex 8 (Section 4.1 'Hänni's calculation'), 10 (Remark 'Hänni's calculation'), 107 (Remark 'Numbers at Hänni's sizes'), 160 (Corollary 'Hänni's numbers with sampled data'), 166 (Example 'Hänni's Version 1'); limits.tex 89 (citation '[Hänni's proposition, with no log term]').  
*Problem.* The sole author is referred to in the third person throughout and his claims are graded ('Confirmed', 'refuted', 'This confirms Hänni's remark', 'This is the split Hänni hoped for', 'as Hänni expected'); four theorem-like headings and a subsection carry his name. The introduction even explains the device ('which are cited in the third person, as Hänni's'). In a paper whose author is Hänni this reads as an external review of the author, not as his paper; the binding note asks for formal register and for his ideas to be credited by citation.  
*Evidence.* process_vocab.out category Hanni-3rd-person (65 lines) and his/he (19); intro.tex 48 'which are cited in the third person, as Hänni's'; Table 1 'Verdict' column; main.toc: '4.1 Hänni's calculation'.  
*Fix.* Use the author's voice with citations: 'the proposal of [grokking note]', 'the example of [grokking note]', 'the original sizes (d=100, m=20, p=2^-10)'. Retitle: 4.1 'The three-hypothesis calculation'; Remark 'Numbers for the running example'; Corollary 'Finite samples'; Example 'The total-bits version of the example'. Table 1: 'Questions raised in [notes] and where they are answered', columns 'Question | Answer | Where'. Delete 'which are cited in the third person, as Hänni's'. Cite Paper 1's results by number, not as 'Hänni's proposition'.

**P2X-13 (major)**: `paper-steeper/sections/intro.tex, setup.tex, absorb.tex, teacher.tex, algstat.tex, split.tex, discussion.tex`, intro.tex 6 and 12; algstat.tex 5; absorb.tex 5, 43, 104, 108; discussion.tex 9.  
*Problem.* Long verbatim quotations of informal working notes, with their lowercase and abbreviations ('roughly speaking solomonoff would be making the same mistakes', 'see some point at which the derivative changes or sth.', 'seq prediction case', 'abs bound'), carry the argument of the introduction and of Sections 3 and 7. In a sole-author paper this is self-quotation of drafts; the binding note asks for formal academic register.  
*Evidence.* algstat.tex 5 quotes 47 words including 'like imagine this graphed ... or sth. (this doesn't show up in the seq case because there it's pretty much just 1 bit paying for 1 bit (until you specify it in full if it's finite complexity))'; intro.tex 6 quotes four fragments in one paragraph.  
*Fix.* Paraphrase in formal English in the author's voice and cite the note; keep at most one short quotation where the exact wording matters (e.g. the example's sizes).

**P2X-14 (major)**: `paper-steeper/sections/intro.tex, algstat.tex, related.tex, discussion.tex`, intro.tex 46 ('as their abstracts describe them'; 'Our literature search went only as far as abstracts, so the novelty claims ... need a check against full texts'); algstat.tex 48 ('presumably that translation'), 82 ('As far as we can tell from the abstracts', 'A comparison with the full texts is left open'); related.tex 35 ('As their abstracts describe them', '... can only be settled from the full texts'), 39 ('This is our reading, not checked against the papers' precise criteria'), 47 ('though our search was limited to abstracts'), 51 ('the novelty claims ... remain to be checked against the full texts'); discussion.tex 26 (open problem (8) 'Literature'), 30 (acknowledgements: 'the comparison with the literature rests on abstracts and search snippets').  
*Problem.* Ten passages tell the reader that the cited literature was not read. These are statements about the preparation process, not about mathematics; they are not acceptable in an arXiv paper, and a to-do ('need a comparison with the full texts') is listed as an open research problem. The underlying works are open access, so the check can be done (P2X-15 to P2X-20).  
*Evidence.* Quoted passages; scratch/p2-arxiv-B/process_vocab.out categories abstract(s), full text, hedge, snippet. Open-access copies found by this review's WebSearch: Zhu-Srebro (PMLR 291), Zhu-Ohannessian-Srebro (arXiv 2603.22644), Vereshchagin-Vitanyi 2010 (arXiv cs/0411014), Vereshchagin-Shen 2017 (arXiv 1607.08077), Grunwald 2012 (homepages.cwi.nl/~pdg/ftp/alt12longer.pdf), Wenzel et al. 2020 (PMLR 119).  
*Fix.* Read the works and rewrite each passage as a plain statement of what the work proves (see P2X-15 to P2X-20). Delete open problem (8) and the acknowledgements clause. If a work cannot be read, remove the sentence that relies on it rather than hedging it.

**P2X-15 (major)**: `paper-steeper/sections/related.tex`, rem:related:mdl (line 35); intro.tex 46 (Prior work); rem:limits:schedule (limits.tex 21).  
*Problem.* The closest prior work is described only 'as their abstracts describe them'. The paper's central disclaimer ('That a bounded lambda fits the noise and lambda must grow with the sample size is their finding ..., not ours') and its claim of difference ('Their abstracts do not mention universal hypotheses, the shared/private contrast, or Kolmogorov-complexity classes') rest on abstracts. Also, Grunwald and Langford (2007) is about lambda = 1 (Bayes and MDL under misspecification), so the intro's 'these works find that a bounded lambda fits the noise and that lambda must grow' misdescribes it.  
*Evidence.* related.tex 35; intro.tex 46; CLAIMS.md rem:related:mdl status 'known (verified bibliographically; content per abstracts and snippets)'; CLAIMS.md conflict P12 (a growth rate attributed to Zhu-Srebro 'could not be confirmed'). Bibliographic data verified (WS-P1): COLT 2025, PMLR 291:6124-6155; arXiv 2603.22644; Machine Learning 66(2-3):119-149.  
*Fix.* Read the three papers and state, with theorem numbers: the hypothesis class and objective they analyse, what they prove about bounded lambda, what growth of lambda they need, and whether any of their hypotheses is universal. Describe Grunwald-Langford separately ('at lambda = 1, Bayes and MDL classifiers can be inconsistent under misspecification'). Then state the difference in one sentence without hedging.

**P2X-16 (major)**: `paper-steeper/sections/algstat.tex`, rem:algstat:restricted (line 82).  
*Problem.* The novelty of product sophistication relative to restricted model families is asserted 'as far as we can tell from the abstracts', and 'A comparison with the full texts is left open'. Milovanov (2016) is described from a snippet (the source notes say 'exact title and pages unverified').  
*Evidence.* steeper notes-final line 1038 ('Milovanov (CSR 2016) ... [known (snippet); unverified]') and line 1377; CLAIMS.md rem:algstat:restricted status 'known (VV 2010 verified bibliographically, content per abstract)'. Vereshchagin-Vitanyi 2010 abstract (this review's WebSearch): distortion balls, Hamming distortion, denoising.  
*Fix.* Read Vereshchagin-Vitanyi 2010 (arXiv cs/0411014) and Milovanov 2016 (arXiv 1512.04510); state precisely what the Hamming-ball structure function gives for the noisy parity and what the product family adds; delete the hedges. If not read, keep only the Hamming-ball sentence and drop (a)-(c).

**P2X-17 (major)**: `paper-steeper/sections/setup.tex`, line 48 ('two-part codes with a complexity weight above 1 are reported to appear in MDL convergence theory \citep{barron1991minimum,grunwald2007minimum}'); intro.tex 46 ('Two-part codes with a complexity weight above one appear in MDL theory'); rem:related:new ('Known: two-part codes and MDL with complexity weights above 1').  
*Problem.* A literature claim is supported only by a secondary source: the paper itself says 'reported to appear', and the intro and rem:related:new then state it as known fact. Neither cited work was checked for it.  
*Evidence.* steeper notes-final line 1448: 'Barron-Cover 1991 (alpha > 1 only via a secondary source)'; app-verification.tex 117: 'A complexity weight above one in Barron and Cover (1991) is known only through a secondary source'. This review's WebSearch confirmed the bibliographic data of both works but found nothing on the weight.  
*Fix.* Check Grunwald (2007), Part III (the chapter on consistency of two-part MDL, where an alpha-two-part code with alpha > 1 is analysed, if the reviewer's recollection is right) and Barron and Cover (1991); cite the exact chapter/theorem and state it without 'reported'. If it cannot be checked, delete the clause in all three places.

**P2X-18 (major)**: `paper-steeper/sections/related.tex`, rem:related:posteriors (line 39): 'SafeBayes chooses eta ... by \cref{prop:limits:noident}(i) such a criterion has no reason to leave eta=1 in well-specified imitation. This is our reading, not checked against the papers' precise criteria.'.  
*Problem.* A claim about the behaviour of SafeBayes is made and immediately disowned as unchecked. Either it is an argument (then it needs the criterion's definition) or it should go.  
*Evidence.* Text as quoted. Grunwald (2012) author copy (homepages.cwi.nl/~pdg/ftp/alt12longer.pdf; abstract via this review's WebSearch): the learning rate is chosen by randomised sequential prediction loss.  
*Fix.* Read Grunwald (2012) and Grunwald-van Ommen (2017) for the SafeBayes criterion; if the conclusion follows, state it as a remark with the one-line reason; otherwise delete the two sentences.

**P2X-19 (major)**: `paper-steeper/sections/algstat.tex`, prop:algstat:coarse status and line 48 ('Vereshchagin and Shen state that set and distribution models are equivalent up to logarithmic terms; the thresholding above is presumably that translation').  
*Problem.* The status tag says the equivalence is 'believed (known; unverified)' and the text says 'presumably'. A cited survey is used for a statement that was not checked in it.  
*Evidence.* envs.txt: status 'proved for computable hypotheses; that it is the standard set--distribution translation is believed (known; unverified)'; CLAIMS.md: 'Vereshchagin-Shen, per snippet, unverified'. The survey is open access (arXiv 1607.08077; LNCS 10010:669-737 verified).  
*Fix.* Check the survey's section on distributions versus finite sets; cite it with the section number and drop 'presumably', or delete the sentence (the proposition stands without it).

**P2X-20 (major)**: `paper-steeper/sections/related.tex`, rem:related:new (line 47); q:related:open (line 51).  
*Problem.* The paper lists five contributions it 'has not found in the literature, though our search was limited to abstracts'. Novelty claims resting on an abstract-level search are not acceptable; the honest form after a proper check is 'to our knowledge'.  
*Evidence.* related.tex 47, 51; CLAIMS.md rem:related:new: '(possibly new; needs a full literature check before publication)'.  
*Fix.* After P2X-15 and P2X-16, rewrite: 'To our knowledge the following are new: ...' and delete the last sentence of q:related:open. If the check is not done, list the results as contributions without novelty claims.

**P2X-21 (major)**: `paper-steeper/sections/discussion.tex`, Code and data statement (line 33); title-page footnote (main.tex 16).  
*Problem.* The statement points to 'solomonoff-function-induction/research/tracks/steeper/' (the banned word 'tracks' in visible text) and to 'the research notes with full proofs from which the paper was written'; the folder is not on the repository's main branch, so the link does not resolve; no commit or release is pinned.  
*Evidence.* PDF p. 33: '... are in the folder solomonoff-function-induction/research/tracks/steeper/ of the repository https://github.com/kaarelh/AI-works'. gh api: solomonoff-function-induction is absent from main (404).  
*Fix.* Publish the scripts to main in a neutral folder (e.g. solomonoff-function-induction/code/steeper/, with the referee scripts as code/steeper/independent/) and write: 'Code and data. All numerical statements are produced by deterministic or seeded Python 3.11 scripts (NumPy, SciPy), with their outputs, in the folder solomonoff-function-induction/code/steeper of https://github.com/kaarelh/AI-works (release <tag>). Appendix C.8 lists the script for each computation.' Do not mention research notes or tracks.

**P2X-22 (major)**: `paper-steeper/bib/core.bib`, entry claudeSFI2026fundamentals ("Draft ... Folder solomonoff-function-induction/paper/ of https://github.com/kaarelh/AI-works"); 22 citations and the title-page footnote.  
*Problem.* The companion paper, cited 22 times for definitions and results, cannot be reached: the cited folder is not on the repository's main branch.  
*Evidence.* gh api repos/kaarelh/AI-works/contents/solomonoff-function-induction?ref=main returns 404 (the repository itself is public; inferential-learning/ is on main).  
*Fix.* Submit the two papers together and cite the companion by its arXiv identifier; until then publish the folder to main (per CLAUDE.md) and cite a tagged URL. Keep the key; change howpublished/note.

**P2X-23 (major)**: `paper-steeper/bib/core.bib; absorb.tex, intro.tex, teacher.tex, app-teacher.tex, related.tex, app-related.tex, discussion.tex`, entry claude2026whatfollows (author = {Claude (Anthropic)}, howpublished = {Unpublished report prepared for K. Hänni}); 10 citations, 8 of them with the pinpoint [section ``Simplicity and normativity from imitation''].  
*Problem.* The earlier report on which several results are 're-derived' is cited as an unpublished report by an AI system 'prepared for K. Hänni' (the author of this paper), with no URL, date or section number. An AI system listed as author of a cited work, and a work 'prepared for' the citing author, will draw a reader's and a moderator's attention; the long pinpoint is repeated 8 times.  
*Evidence.* The report is public: gh api shows inferential-learning/ (README, paper, code, research) on main of github.com/kaarelh/AI-works; its title page (inferential-learning/paper/main.tex line 6) reads author 'Claude (Anthropic)', 'Draft; authorship and publication to be decided by him'. The cited section is \section{Simplicity and normativity from imitation} in sections/simplicity.tex (Section 8 of that report).  
*Fix.* Decide the report's author line first (the report itself says it is for Hänni to decide) and use the same line here; give the URL https://github.com/kaarelh/AI-works/tree/main/inferential-learning and the year; drop 'prepared for K. Hänni'. Cite as \citet[Section 8]{claude2026whatfollows} once in the introduction, then 'the earlier report' without the pinpoint.

**P2X-24 (major)**: `paper-steeper/sections/setup.tex, absorb.tex, limits.tex, split.tex, related.tex, app-absorb.tex, app-split.tex, app-limits.tex`, e.g. setup.tex 8 '[the fresh-noise proposition]', 17 '[the per-query proposition]', 36 '[the corollary on SFI^hist]'; absorb.tex 71 '[the chain theorem, the shared-coin proposition and the remark after it]'; app-split.tex 65 '[the hashing remark]'; related.tex 103 '[the time-bounded theorem]'; limits.tex 89 '[Hänni's proposition, with no log term]'.  
*Problem.* About 15 references to the companion paper use informal names instead of numbers (10 of them as bracketed pinpoints such as [the shared-coin proposition], others as 'the mistake bound of', 'the tape-length bound of', 'the merging theorem of'), and five of the names do not match the companion's printed titles, so a reader cannot find the result. 'The hashing remark' points to a remark that the companion itself titles 'The hashing bound, superseded'.  
*Evidence.* Paper 1 titles (paper/sections): learn.tex 79 'random-function SFI cannot model fresh label noise' (cited as 'the fresh-noise proposition'); learn.tex 89 'the per-query mixture' ('the per-query proposition'); hist.tex 129 'Universality of SFI^hist' ('the corollary on SFI^hist'); versions.tex 60 'Shared randomness is not a mixture of private randomness' ('the shared-coin proposition'); app-versions.tex 55 'The hashing bound, superseded' ('the hashing remark'). app-verification.tex 130: 'theorem numbers can be added once both papers are final'.  
*Fix.* Once Paper 1 is frozen, cite by number and exact title, e.g. \citet[Proposition 6.3]{...}; build both papers from one shared .aux (xr-hyper) or fill numbers by hand and check them.

**P2X-25 (major)**: `paper-steeper/sections/discussion.tex`, Open problems list, lines 15-26 (cross-references to q:teacher:open, q:limits:open, q:absorb:shared, q:related:open, q:algstat:lsc).  
*Problem.* The \label of each 'Open question' paragraph picks up the number of the enclosing subsection, so the list sends the reader to the wrong place: '(Section 5.4)' is the subsection 'Unseen properties', '(Section 4.5)' is 'Idiosyncratic errors, finite samples and Version 1', '(Section 3.4)' is 'Answer to the absorption objection'. The open questions themselves are unnumbered paragraphs at the ends of those subsections.  
*Evidence.* PDF p. 32-33: '(Section 5.4)', '(Section 4.5, Remark 5.11)', '(Section 3.4)', '(Section 8.2)', '(Section 7.2)'; labels q:limits:open (limits.tex 101), q:teacher:open (teacher.tex 182), q:absorb:shared (absorb.tex 111).  
*Fix.* Either drop the per-section 'Open question' paragraphs and keep only the numbered list in Section 9.1 (shorter), or give each open question its own counter (a 'question' environment) and refer to 'Question 4.12'.

**P2X-26 (major)**: `paper-steeper (structure)`, main text pp. 3-33 (30 pages, 70 theorem-like environments: 5 theorems, 20 propositions, 10 lemmas, 3 corollaries, 21 remarks, 9 definitions, 2 examples); Section 8 'Computable versions and related work'.  
*Problem.* Against a typical arXiv paper in learning theory (main text about 20-25 pages, results stated in a handful of theorems, secondary results in appendices) the main text is long and flat: 70 environments, of which only 3 lemmas are in the appendices; every section ends with remarks and an open question. The outline's own budget (18-22 pages) is exceeded by about 9 pages. Related work is split between the introduction and a final section that also proves two propositions; the binding note asks for related work before the preliminaries.  
*Evidence.* main.toc; scratch/p2-arxiv-B/envs.json (main 70, appendix 3); OUTLINE.md page budget (total 21); app-verification.tex 126 ('about 30 pages against a target of 18-22').  
*Fix.* Move to the appendices: prop:absorb:inputs, rem:absorb:condsemi, prop:limits:guard, prop:limits:inputlaw, prop:limits:ood, rem:limits:method, ex:split:noisyparity, rem:split:siprograms, prop:algstat:product, prop:algstat:coarse, prop:related:computable, prop:related:computability, rem:related:cold, rem:related:nn, and Theorem 4.7 (iii)-(iv) with Table 2(b). Make Section 2 'Related work' (rem:related:mdl, rem:related:posteriors, rem:related:t5, restricted families) or keep it last but without results. Collect open questions once (P2X-25). Target 20-22 main pages.

**P2X-27 (major)**: `paper-steeper/sections/teacher.tex`, def:teacher:instance (lines 21-32), the display before thm:teacher:main (65-76), thm:teacher:main (78-101).  
*Problem.* The central theorem cannot be read on its own. Before it the reader meets about 40 symbols (s_0, L_S, B_S, delta_S, I, R, R_B, J_c, J_c^B, Phi, Phi^B, tau_B, beta_B, u, theta_t, lev, s(t), G_j, pi_coin, pi_g, pi_b, kappa_g, kappa_b, Lambda_1, psi_c, Phi_1, Phi_2, t*, J_g, J_b, Delta(c), c_hi, Lambda_2, Lambda_3, Delta_l, e, gamma_g, j_g, Gamma_g, varrho), and the theorem has five parts with sub-parts (a)-(e). The introduction gives no informal statement of it.  
*Evidence.* teacher.tex 21-101; intro.tex 17 (bullet) states the conclusion but not a theorem.  
*Fix.* Add 'Theorem 1 (informal)' to the introduction. In Section 4 state a simplified Theorem 4.7 with B = infinity and epsilon = 0 (window, identification (a)-(e) with numeric constants suppressed into O(log d + kappa)) and move the general form with truncation, epsilon-slack and parts (iii)-(iv) to Appendix C. Put the symbol definitions that only the proofs need (tau_B, beta_B, Gamma_g, j_g, varrho) in the appendix.

**P2X-28 (major)**: `paper-steeper (all .tex, .bib, .bbl files that would be uploaded)`, comment lines in main.tex (7), preamble.tex (23) and every section file; label rem:absorb:wyeth (absorb.tex 5, 101; intro.tex 16); bib comments.  
*Problem.* arXiv makes the LaTeX source public. As it stands the source contains process vocabulary in comments ('writer: steep-a', 'Source: research/tracks/steeper/notes-final.md', 'CLAIMS.md', 'OUTLINE.md', 'framing editor', 'The binding note ... excludes it from the arXiv version'), a label naming Wyeth, and bib files whose entries name Wyeth and carry '% unverified' comments.  
*Evidence.* grep: 36 full-line comments in sections/*.tex (plus inline comments), 7 in main.tex, 23 in preamble.tex; e.g. setup.tex 1 '% Section 2 (writer: steep-a). Source: research/tracks/steeper/notes-final.md ...'; intro.tex 7 '% Binding notes: the absorption objection is not attributed to a person ...'; absorb.tex 101 '\label{rem:absorb:wyeth}'.  
*Fix.* Build the arXiv upload in a separate folder: flatten the inputs (latexpand), strip comments (arxiv_latex_cleaner or a script), rename rem:absorb:wyeth to rem:absorb:answer (3 places), upload main.bbl but not bib/*.bib, and grep the tarball for 'Wyeth', 'track', 'referee', 'notes-final', 'ledger', 'CLAIMS', 'OUTLINE', 'steep-', 'Claude' (the last should occur only in the footnote and acknowledgements).

**P2X-29 (minor)**: `paper-steeper/sections/intro.tex`, line 18 (Contributions, Limits bullet: 'on almost a third of the window's logarithmic width'); line 19 (split bullet: 'product sophistication exceeds set sophistication by d - O(log d) bits').  
*Problem.* Two summaries drop qualifiers that the body states. 'Almost a third' holds with the machine constant set to 0 (a quarter at kappa=30). The sophistication gap holds for sufficiency slacks b in a stated range and deficiency delta_E = O(d), with p < 1/4.  
*Evidence.* limits.tex 42 ('31% of the logarithmic width ... at kappa=0 (25% at kappa=30)'); prop:algstat:parity (ii)-(iv) ranges of b and 'delta_E = O(d)'.  
*Fix.* 'on almost a third (kappa=0; a quarter at kappa=30) of the window's logarithmic width'; 'by d - O(log d) bits for a range of sufficiency slacks'.

**P2X-30 (minor)**: `paper-steeper/sections/discussion.tex`, line 5 ('When a universal mixture is a member of the class ... it cannot').  
*Problem.* Overstated: the absorption theorem excludes only hypotheses longer than l*_lambda (which tends to l_U); a model shorter than about l_U can still be selected.  
*Evidence.* thm:absorb:absorption (a); rem:absorb:reading ('Whether a given model is longer than l_U depends on the reference machine').  
*Fix.* 'it cannot for any model longer than l*_lambda, a bound that does not depend on the data'.

**P2X-31 (minor)**: `paper-steeper/sections/teacher.tex`, cor:teacher:fulltable, line 155 ('the window lambda in (1, 1.19 10^4]') and app-teacher.tex 137 ('(1,11945]').  
*Problem.* Part (i) of the corollary needs J_g < Phi_2 (strict), i.e. the open interval (1, N c_hi); the computed window is printed closed at the right end.  
*Evidence.* cor:teacher:fulltable (i): 'every lambda > 1 with J_g(lambda/N) < Phi_2(lambda/N), in particular every lambda in (1, N c_hi)'; app-verification row 22 records the fix of the statement but not of the number.  
*Fix.* Print '(1, 1.19 10^4)' and '(1, 6456)', or say 'the window (1, N c_hi] (part (i) holds on its interior)'.

**P2X-32 (minor)**: `paper-steeper/sections/app-teacher.tex`, line 216 ('-n epsilon + (J_g + epsilon)/c = -1000 + 242.3').  
*Problem.* Wrong intermediate number: with J_g(c) = c(d + kappa_g) + H(p) = 0.023167 at c = 1e-4, kappa=0, (J_g + epsilon)/c = 241.67, so the exponent is -758.33. The main-text bound 2^-758 is right; 242.3 is not.  
*Evidence.* scratch/p2-arxiv-B/concentration_exponent.py (.out): J_g = 0.023167, (J_g+eps)/c = 241.67, exponent -758.33; research/tracks/steeper/checks/c5_limits.out line 24: 'J_c(good)=0.0232 ... log2 bound = -758'.  
*Fix.* '-1000 + 241.7'.

**P2X-33 (minor)**: `paper-steeper/sections/absorb.tex`, rem:absorb:wyeth (iii), line 105 ('So ``nothing is lost at lambda=1'' holds only relative to the product class'); rem:absorb:reading line 38 ('a dog classifier with millions of bits certainly is').  
*Problem.* (iii) puts in quotation marks a claim that appears nowhere in the paper (it is an earlier draft's claim, removed in revision); (38) 'certainly' asserts something about every reference machine.  
*Evidence.* steeper notes-final 339, 1260 ('"Nothing is lost" was removed (§1.6)').  
*Fix.* (iii): 'So restricting to private randomness is not free at lambda = 1 when compared with M_F.' (38): 'a model of millions of bits is longer than l_U for any reasonable reference machine.'

**P2X-34 (minor)**: `paper-steeper/sections/split.tex, app-split.tex, limits.tex, app-algstat.tex, absorb.tex`, split.tex 104 ('2^{-lambda|p|}'); app-split.tex 32 (p_w), 60 (p_s), 69 (delta_w); limits.tex 58 (a:=2+4q, b:=...); app-algstat.tex 20 and 77 (integer u), 52 (p = h/2^e); algstat.tex 45 (rho:=ceil(-log nu_pi(D))) next to rho^x_D; absorb.tex 65 (kappa').  
*Problem.* Notation clashes with ../paper/NOTATION.md and within sections: programs are pi in Paper 2 because p is the error density (NOTATION §1); subscripted delta is reserved for deficiencies (§4 item 18); in Section 5 a is the parity vector and b the behaviour of prop:limits:ood, yet Lemma 5.5 defines constants a, b; in Section 7 u is the agreement u(pi) and also an integer index, e and h are e(pi) and h_z and also p = h/2^e, rho is both the product structure function and an integer; kappa' is reserved for a subclass constant.  
*Evidence.* NOTATION.md §1 'Programs', §4 items 18 and 2; the quoted lines.  
*Fix.* Write pi for programs (pi_w, pi_s, 2^{-lambda l(pi)}); point mass 1_w or [w]; Lemma 5.5 constants alpha_0, beta_0; integer index v (A_v); p = h'/2^{e'} or 'p a dyadic rational of small complexity'; rho -> r_D; kappa' -> kappa_2.

**P2X-35 (minor)**: `paper-steeper/sections/absorb.tex`, prop:absorb:price (iv), line 78.  
*Problem.* A lower bound on a predictor's loss without its convention. NOTATION.md §6 requires every lower bound to say 'semimeasure convention' or 'both conventions'; the excess of the steeper product predictor over M_F is proved for -log xi(D) (semimeasure convention), and normalising xi^x_lambda can only lower its loss.  
*Evidence.* prop:absorb:price (iv) and its proof (app-absorb.tex 69); NOTATION.md §6 last bullet.  
*Fix.* Add '(semimeasure convention)' after 'pays at least'.

**P2X-36 (minor)**: `paper-steeper/bib/core.bib, steep-a.bib, steep-b.bib`, entries hoeffding1963probability, grunwald2007suboptimal, ville1939etude, grunwald2012safe, grunwald2017inconsistency, zhang2006epsilon, bissiri2016general, bhattacharya2019fractional.  
*Problem.* Verified entries with incomplete data.  
*Evidence.* This review's WebSearch: Hoeffding JASA 58(301), doi 10.1080/01621459.1963.10500830; Ville: Monographies des Probabilités, fasc. III (ed. Borel), Gauthier-Villars 1939; DOIs 10.1007/978-3-642-34106-9_16, 10.1214/17-BA1085, 10.1214/009053606000000704, 10.1111/rssb.12158, 10.1214/18-AOS1712. Paper 1 review: Grunwald-Langford Machine Learning 66(2-3).  
*Fix.* Add number = {301} (Hoeffding), number = {2--3} (Grunwald-Langford), series and number (Ville), and DOIs throughout (plainnat prints them).

**P2X-37 (minor)**: `paper-steeper/bib/steep-a.bib, steep-b.bib`, koppel1987complexity, koppel1991almost, vitanyi2006meaningful, antunes2009sophistication, milovanov2016algorithmic, cover2006elements, goldreich1989hard, kushilevitz1993learning, wenzel2020good.  
*Problem.* Nine printed entries could not be re-verified in this review (the session's shared WebSearch budget ran out); only the writers' own search records support them. Milovanov's title and pages conflict between the source notes ('exact title and pages unverified') and the bib comment ('Confirmed'); Kushilevitz-Mansour's pages were copied from a sibling project ('the SIAM snippet did not show the pages').  
*Evidence.* scratch/p2-arxiv-B/bibcheck-log.md section 'Writer's search record only'; steeper notes-final line 1377; steep-b.bib comment on kushilevitz1993learning. All nine agree with the reviewer's own knowledge of these works.  
*Fix.* Re-check the nine by search before submission (DBLP or publisher pages), with priority on milovanov2016algorithmic and the pages of kushilevitz1993learning.

**P2X-38 (minor)**: `paper-steeper/bib/core.bib`, entry vaintrobhanni2026nnbayes (URL https://kaarelh.github.io/ai/nnbayes-generalization.pdf).  
*Problem.* The title and authors are confirmed only against the local copy of the slides; the URL was not found by search and does not resolve from this environment.  
*Evidence.* WebFetch: ENOTFOUND kaarelh.github.io; Paper 1 review: 'verified against local copy only'. The title slide in research/prior/ matches the entry.  
*Fix.* The author checks the URL in a browser; if it is not public, cite the slides as 'Slides, ILIAD 2026' without URL or deposit them in the repository.

**P2X-39 (minor)**: `paper-steeper/sections/app-teacher.tex, app-limits.tex, app-related.tex`, script names c6_revision.py, c7_run2.py (app-teacher 56, 125, 137, 196, 216, 220; app-limits 10, 12, 37, 65, 102); 'were re-run from scratch copies' (app-teacher 220, app-related 46).  
*Problem.* Script names and one phrase expose the preparation process ('revision', 'run2', 're-run from scratch copies'); elsewhere the same kind of computation is cited only as 'code in the accompanying repository, seed N'. The two conventions are mixed.  
*Evidence.* process_vocab.out category process-run (24 lines).  
*Fix.* Rename the scripts in the published code folder by content (e.g. c6_constants_examples.py, c7_streams_envelopes.py) and cite every computation the same way ('script <name>, seed N'); replace 're-run from scratch copies and reproduce' by 'reproduce'.

**P2X-40 (minor)**: `paper-steeper/main.tex; preamble.tex`, main.tex 15-24 (no \hypersetup, \tableofcontents + \newpage); preamble.tex 13 (\usepackage{framed}); author line without affiliation.  
*Problem.* PDF metadata are empty (pdfinfo: Title, Author blank); a full-page table of contents is unusual for an arXiv paper of this length; the 'framed' package is loaded but unused; no affiliation or contact address.  
*Evidence.* pdfinfo main.pdf; grep finds no 'framed' environment in sections/.  
*Fix.* Add \hypersetup{pdftitle={...}, pdfauthor={Kaarel Hänni}}; drop the TOC or keep it without \newpage; remove 'framed'; add an affiliation (or 'Independent researcher') and an e-mail address.

**P2X-41 (minor)**: `paper-steeper/CLAIMS.md`, rows rem:absorb:examples, cor:teacher:fulltable; missing row rem:teacher:numbers.  
*Problem.* The ledger is stale in three places (the paper is right): it says xi_1 = U where the paper (correctly) proves xi_1 <= U; it states the full-table corollary for lambda in (1, N c_hi] where the paper has the open interval; and it has no row for rem:teacher:numbers (only tab:teacher:numbers).  
*Evidence.* scratch/p2-arxiv-B/compare_status.out ('NOT IN LEDGER: rem:teacher:numbers'); app-verification rows 22 and 30.  
*Fix.* Update CLAIMS.md (not part of the arXiv upload).

**P2X-42 (minor)**: `paper-steeper/sections/related.tex; discussion.tex`, rem:related:nn line 29 and discussion.tex 13 ('the bridge question raised by the Vaintrob--Hänni result').  
*Problem.* The 'bridge question' is posed in the companion paper (rem:nn:bridge, q:nn:bridges), not in the slides; attributing it to the slides misstates the source.  
*Evidence.* paper/sections/nn.tex 49, 94; CLAIMS.md rem:related:nn: 'Paper 1's bridge question'.  
*Fix.* 'is the bridge question of the companion paper (Remark <n>), which the slides of Vaintrob and Hänni (2026) motivate'.

**P2X-43 (minor)**: `paper-steeper/sections/limits.tex, teacher.tex, related.tex`, limits.tex 98 ('looks within reach but is not proved'); teacher.tex 183 and discussion.tex 20 ('presumably do not'); related.tex 51 ('It presumably is not, but we have no proof').  
*Problem.* Speculative phrasing in remarks and open questions; academic style states conjectures as conjectures or questions.  
*Evidence.* Quoted lines.  
*Fix.* 'We do not know whether the window extends to p < 0.123'; 'we expect that majority-like functions do not give a window'; 'Is the lambda-MAP computable from the data? We conjecture not.' (or a conjecture environment if the author wants to commit).

**P2X-44 (minor)**: `paper-steeper/sections/setup.tex`, paragraph 'Objects from the companion paper' (line 8).  
*Problem.* One paragraph introduces nine objects of the companion paper (function machine, f^T_omega, nu_T, M_F, product laws, M_prod, M^w, M_H, frozen vs fresh noise) with a dominance relation and an unboundedness result; most are needed only in Section 3. Hard to absorb on first reading.  
*Evidence.* setup.tex 8.  
*Fix.* Turn it into a short table (object, meaning, where used) or move M^w, M_H and the M_F/M_prod comparison to the start of Section 3.

**P2X-45 (minor)**: `paper-steeper/sections/abstract.tex`, line 3 (first sentences).  
*Problem.* The abstract uses n and c (in 'lambda = cn') without saying what they are, and the informal 'absorbs everything' is not defined anywhere in the paper.  
*Evidence.* abstract.tex 3.  
*Fix.* Use the rewritten abstract of the review's section 7.1, which defines n (sample size) and replaces 'absorbs everything' by what Theorem 3.2 proves.
