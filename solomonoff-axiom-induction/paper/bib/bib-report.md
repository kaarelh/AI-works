# Bibliography and novelty report for the paper on Solomonoff axiom induction (working name)

*Bibliography and novelty editor, 2026-10-16. Folder `paper/bib/`. Inputs: `research/refs.bib` (241 entries); `research/final-check.md` §2; `research/notes-final.md` §5.7, including its list "References the records use but that are NOT in `refs.bib`"; the reference tables of the thread records (`fundamentals` §14, `sfi` §14, `logic` §11, `terms` §14, `shape` §9, `laws` §12, `philosophy` §7). Outputs: `refs.bib` (293 literature entries), `core.bib` (6 internal entries), this report.*

**Restart check.** When this run began, `paper/bib/` did not exist, so there was no partial output to recover. The files were written early and saved after each batch of searches.

**How things were checked.** Every check below is a WebSearch run on 2026-10-16, about 90 queries in all. **No page could be fetched.** WebFetch failed with a DNS error (`getaddrinfo ENOTFOUND`) on every host tried: arxiv.org, alignmentforum.org, www.lesswrong.com, www.greaterwrong.com, agentfoundations.org and scott.garrabrant.com. Every earlier round of this project hit the same failure. So "seen" below means seen in the text the search tool returned: titles, URLs, and passages that the tool presents as quotations from or summaries of the pages. The search tool's text is machine-written; quotations in it were not checked against the pages. Levels:
* **[B]**: the bibliographic data (authors, title, venue, volume, pages, year) appeared in the results, from a publisher, library, DBLP, arXiv, a repository or a citing work's reference list.
* **[A]**: the abstract or the publisher's description appeared.
* **[Q]**: a passage of the work itself appeared as a quotation in the results.
* **[S]**: a secondary source (a survey, an encyclopaedia, a citing paper or a review) stated the content.
* **[not verified]**: not found, or found only in part. The writers must not cite it, or must not use the unconfirmed field.

Every entry this editor touched carries, in `refs.bib`, a comment line that begins "% Bib editor (2026-10-16):". The line says what was searched, what was found and at what level. **The paper must hedge every claim about a work's content to the level recorded there.**

---

## 1. `refs.bib` and `core.bib`

**`core.bib`** holds 6 internal entries, all read in this repository:
* `hanni2026notes`: fields as in the SOI papers' `core.bib`. The note field now names the folder `ai/learning/solomonoff induction`, which holds "solomonoff axiom induction.md".
* `claudeSFI2026fundamentals` and `claudeSFI2026steeper`: authors "H{\"a}nni, Kaarel and {Claude (Anthropic)}"; titles copied exactly from `../solomonoff-operator-induction/paper/bib/core.bib`.
* `claude2026axiominduction` and `claude2026axiomschemas`: the same authors, as in the reports' READMEs and the SOI `core.bib`. Titles are taken from the reports' `paper/main.tex`, with the line break replaced by a colon.
* `claude2026whatfollows`: copied verbatim from the SOI `core.bib`.

**`refs.bib`** was generated from `research/refs.bib` by a throwaway script in the scratchpad, which is not part of the record, and was then edited.
* **The six internal entries moved to `core.bib`.** 235 literature entries remained.
* **The merge artefact is fixed** (`final-check.md` §2):
  * the `shape` table's group comment "[known: abstract level]" is repeated above `darwiche2002knowledge`, `babka2013complexity`, `gwynne2014sat`, `bessiere2009circuit` and `bordeaux2012knowledge`;
  * "for every entry below unless stated" is removed from the comment above `selman1996knowledge`.
* **The header is rewritten.** The wrong sentence "Every literature entry was verified by WebSearch in this project" now says this: 24 entries were checked by the earlier reports, and this editor re-searched them (§2.6).
* **Provenance comments are kept.**
* **Twelve `shape` entries are completed.** They had surnames only and missing fields. They now have full names, DOIs and corrected venues (§2.4).
* **`tenenbaum2006theory` is fixed.** Its unconfirmed volume, issue and pages are dropped (§2.7).
* **58 verified entries are added,** in a final block, each with its verification comment (§2.1–§2.5, §3, §4).
* **Test.** `\nocite{*}` with `plainnat` over `refs.bib` and `core.bib`: BibTeX typesets all 299 entries, with no LaTeX error. Its one warning is the intentional empty publisher in `shapiro1991inductive`, inherited from the earlier records.
* **For the writers.** The planning editor's `paper/merge_bib.py` reads `bib/*.bib` first and `../research/refs.bib` only as a fallback.
  * A key that resolves only through the fallback has not been through this editor. The script reports such keys.
  * All 235 carried keys are present here, so the fallback should never be needed.

---

## 2. Verification of references marked unverified or missing

### 2.1 Belief functions (`fundamentals` §14; synthesis §5.7 item 3)

| key | found | level | verdict |
|---|---|---|---|
| `dempster1967upper` | Ann. Math. Statist. 38(2):325–339, 1967. Project Euclid record; some databases misprint the volume. | [B, A] | citable for belief functions and Dempster's rule (Prop 2.3) |
| `shafer1976mathematical` | Glenn Shafer, Princeton UP, 1976 | [B] | citable for the theory of belief functions |
| `suppes1977using` | Patrick Suppes and Mario Zanotti, Synthese 36(4):427–440, 1977, doi 10.1007/BF00486106 | [B, A] | citable for upper and lower probabilities from random relations. The attribution of the geometric rule $\mathrm{bel}(B\cap A)/\mathrm{bel}(A)$ to it is **[S] only**, so write "the rule usually attributed to Suppes and Zanotti" |
| `pearl1988probabilistic` | Morgan Kaufmann, 1988. Ch. 9 is "Non-Bayesian Formalisms for Managing Uncertainty". | [B]; "probability of provability" [S] (Pearl's own 1999 UAI-list post; Shenoy–Biswas 1990) | citable for the probability-of-provability reading, hedged ("as Pearl puts it"); p. 427 not seen |

### 2.2 Randomness (`fundamentals` §3, §14)

| key | found | level | verdict |
|---|---|---|---|
| `demuth1975constructive` | Comment. Math. Univ. Carolinae 16:315–331, 1975, in Russian; English title as given by Kučera–Nies–Porter | [B] via citing works; result [S] | citable for "a left-c.e. real plus a random left-c.e. real is random" (Lemma 3.3), as attributed by the literature |
| `downey2002randomness` | SIAM J. Comput. 31:1169–1183, 2002, doi 10.1137/S0097539700376937 | [B, A]; the converse of Demuth's theorem is [S] | citable for that converse, hedged |
| `kucera2001randomness` | SIAM J. Comput. 31(1):199–211, 2001 | [B]; content [S] | citable, together with `calude2001recursively`, for "the random left-c.e. reals are the Ω-numbers" |
| `calude2001recursively` | TCS 255(1–2):125–149, 2001 | [B, A] | as above; also for Solovay's domination order |
| `downey2010algorithmic` | Springer, 2010, Theory and Applications of Computability | [B] | citable as the textbook source for Solovay reducibility; no page given |
| `solovay1975draft` | unpublished IBM manuscript, May 1975, 215 pp. | [B] via citing works | citable only for the origin of Solovay reducibility, next to `downey2010algorithmic` |
| Jockusch–Soare 1972 | Trans. AMS 173:33–56 confirmed [B]. The fact that the PA degrees form a null class is attributed to "Jockusch and Soare" without saying which of their two 1972 papers proves it (the other is Pacific J. Math. 40:605–616). | **not verified** for the fact | **not citable** for the null class; Prop 8.7 does not need it |

### 2.3 Logic and complexity (`sfi` §14, `terms` §14, `logic` §11; synthesis §5.7 list)

| key | found | level | verdict |
|---|---|---|---|
| `smullyan1961theory` | Annals of Math. Studies 47, Princeton UP, 1961. Ch. V is "Creativity and Effective Inseparability". | [B]; the statement used is [S] | citable for the effective inseparability of the provable and refutable sentences, hedged; location not seen |
| `sipser1983complexity` | STOC 1983 | [B] (pages **not** confirmed, omitted) | citable for BPP in the polynomial hierarchy |
| `lautemann1983bpp` | IPL 17(4):215–217, 1983, doi 10.1016/0020-0190(83)90044-3 | [B]; content [S] | citable for BPP ⊆ Σ2 ∩ Π2 |
| `hartmanis1965computational` | Trans. AMS 117:285–306, 1965, doi 10.1090/S0002-9947-1965-0170805-7 | [B] | citable; the one-tape simulation in its textbook form |
| `presburger1929vollstandigkeit` | Comptes Rendus, I Congrès des Math. des Pays Slaves, Warszawa 1929, 92–101; some references give 1930 | [B]; [S] Stansifer's translation | citable for completeness and decidability |
| `matiyasevich1970enumerable`, `davis1973hilbert` | Soviet Math. Dokl. 11(2):354–358, 1970; Amer. Math. Monthly 80(3):233–269, 1973 | [B] | citable for MRDP |
| `pippenger1979relations` | J. ACM 26(2):361–381, 1979 | [B, A]: circuits of cost $O(n\log n)$ for $n$ steps | citable for the $O(T\log T)$ circuit simulation |
| `boolos2007computability` | 5th ed., Cambridge UP, 2007 | [B] | citable as the textbook. The chapter numbers in the records (16–17) were **not** checked against this edition, so cite without chapter numbers |
| `ebbinghaus1999finite` | 2nd ed., Springer, 1999 | [B] | citable as the textbook for the EF theorem |
| `lowenheim1915moglichkeiten`, `behmann1922beitrage` | Math. Ann. 76:447–470 (1915); Math. Ann. 86:163–229 (1922) | [B]; decidability of monadic logic [S] | citable for the decidability of monadic first-order logic. **Not citable** for the finite model property in the quantitative form `terms` Lemma 6.1 refers to; say "a quantitative form of the finite model property of monadic logic" without attribution, or prove it, as `terms` does |
| `fraisse1954quelques` | Publ. Sci. Univ. Alger, Sér. A, 1:35–182, 1954 | [B] | citable for the EF characterisation (textbook content) |
| `mostowski1952models` | Fund. Math. 39:133–158, 1952, doi 10.4064/fm-39-1-133-158 | [B]; reflexivity of PA [S] (FOM posts; Theorem XVIII per Detlefsen) | citable for the reflexivity of PA. **Essential** reflexivity was **not** seen attributed to it |
| `kreisel1968reflection` | Z. Math. Logik Grundlagen Math. 14:97–142, 1968 | [B]; PRA + RFN(PRA) ≡ PA [S] | citable for that equivalence only. **Not citable** for essential reflexivity, so `terms`' proof idea of (KL) must stay unattributed or be marked as recalled |
| Montague 1961 | "Semantical closure and non-finite axiomatizability I", *Infinitistic Methods*, 1961, 45–69 | [B]; the ZF result **not verified** | **not citable** for the non-finite axiomatisability of ZF, which the paper does not use |
| `simpson2009subsystems` | 2nd ed., Cambridge UP / ASL, Perspectives in Logic, 2009 | [B]; "ACA₀ finitely axiomatisable, conservative over PA" [S] | citable for that fact, hedged |
| `hajek1993metamathematics` (carried) | Springer, Berlin, 1993, Perspectives in Math. Logic (series added) | [B]; "IΣ1 (every IΣn, n ≥ 1) is finitely axiomatisable" [S] (arXiv:2502.06639; CMUC 28 (1987)) | citable for that fact as standard. Its location in the book was not seen |
| `woodin2011potential` | ch. 5 of Heller and Woodin (eds.), *Infinity: New Research Frontiers*, CUP, 2011, from p. 119 | [B, A] | citable as context for flexible formulas; the end page is omitted |
| `myasnikov2008generic` | JSL 73(2):656–673, 2008, doi 10.2178/jsl/1208359065 | [B, A] | citable for generic undecidability |
| `bienvenu2017diagonally` | Inform. and Comput. 253:64–77, 2017; arXiv:1411.6846 | [B, A] | citable; for Kučera's theorem only as a secondary source |

### 2.4 Circuits, spanners, proof complexity and knowledge compilation (`shape` §9)

*Completed existing entries.* Each was re-searched. Full names were added, and DOIs where shown:
* `selman1996knowledge`, `darwiche2002knowledge`, `babka2013complexity`, `kucera2020bounds`: [B, A];
* `gwynne2014sat`: [B, A], doi 10.1007/978-3-319-04921-2_33;
* `bessiere2009circuit`: [B, A];
* `bordeaux2012knowledge`: [B, A]. The page conflict 612–624 against 612–614 persists; the longer range is kept;
* `emdin2022cnf`: [B, A]; LIPIcs 241, 47:1–47:12 added;
* `goos2019adventures`: [B, A]; the input set is $2n^3$ bits, as the `shape` record says;
* `hastad1986almost`: [B, A]. The doi was added. Pages 6–20 **could not be re-confirmed** and are kept as recorded by the `shape` referee; prefer citing without pages if in doubt;
* `berman2014steiner`: [B, A];
* `urquhart1987hard`: [B]; issue and doi added; content [S].

*New entries:*

| key | found | level | verdict |
|---|---|---|---|
| `babai1999superpolynomial` | Combinatorica 19(3):301–319, 1999. **Title:** "Superpolynomial Lower Bounds for Monotone Span Programs" | [B, A]: a function with linear-size monotone span programs that needs superpolynomial monotone circuits and exponential monotone formulas | citable as `shape` uses it |
| `alon1987optimal` | Tel Aviv TR 71/87, 1987; posted as arXiv:2406.06321 | [B, A] | citable |
| `bhattacharyya2012transitive` | SIAM J. Comput. 41(6):1380–1425, 2012 | [B, A] | citable |
| `yao1982space` | STOC 1982, 128–136 | [B, A] | citable |
| `chandra1985unbounded` | Chandra, Fortune, Lipton, JCSS 30(2):222–234, 1985; STOC 1983 version | [B]; content [S] | citable. The ICALP 1983 paper "Lower bounds for constant depth circuits for prefix problems" is confirmed only as "Proc. ICALP 1983" by citing works, so **do not cite it** with a volume or pages |
| `hansel1964nombre` | C. R. Acad. Sci. Paris 258(25):6037–6040, 1964 | [B] via a citing reference list; content [S] | citable for Hansel's lemma, hedged |
| `katona1967problem` | Studia Sci. Math. Hungar. 2:23–28, 1967 | [B]; the $n\log_2 n$ biclique bound [S] | citable |
| `bensasson2001short` | J. ACM 48(2):149–169, 2001 | [B, A] | citable; this settles the `shape` record's "known, unverified" |
| `orevkov1982lower` | J. Soviet Math. 20:2337–2350, 1982; the Russian original appeared in Zap. LOMI 88, 1979 | [B, A] | citable |
| `cavalar2023constant` | CCC 2023, LIPIcs 264, 29:1–29:37 | [B, A] | citable |
| `delval1994tractable` | KR'94, Morgan Kaufmann, 551–561 | [B]; content [S] | citable for compiling a theory so that unit resolution is complete, hedged |
| `beame2026extending` | the SAT 2026 paper, LIPIcs 377 paper 5 (§4.1) | [B, A] | citable only as a solver whose propagation does linear algebra |

### 2.5 Philosophy (`philosophy` §7, table "References the revision cites but could not verify")

| key | found | level | verdict |
|---|---|---|---|
| `suppes1962models` | in Nagel, Suppes, Tarski (eds.), *LMPS 1960*, Stanford UP, 1962, 252–261 | [B]; [A]/[Q] opening of the Suppes Corpus reprint | citable for the hierarchy of models of data |
| `groenendijk1984studies` | joint dissertation, Universiteit van Amsterdam, 1984 | [B]; partition semantics [S] | citable for partition semantics of questions, hedged |
| `dorling1979bayesian` | Stud. Hist. Phil. Sci. 10(3):177–187, 1979 | [B]; [S] | citable as the standard Bayesian treatment of Duhem's problem |
| `strevens2001bayesian` | BJPS 52:515–537, 2001 | [B, A] | citable for the objection that the standard treatment begs the question, and Strevens's alternative |
| `greaves2006justifying` | Mind 115(459):607–632, 2006 | [B, A] | citable |
| `pettigrew2016accuracy`, `leitgeb2010objective` | OUP, 2016; Philos. Sci. 77(2):201–235, 2010 | [B, A] | citable for accuracy-first epistemology. The claim that accuracy-first arguments favour the Brier score is supported at [A] by Leitgeb–Pettigrew ("only quadratic inaccuracy measures avoid" their dilemmas); hedge it |
| `lanford1975time` | Lecture Notes in Physics 38, Springer, 1975, 1–111 | [B]; content [S] | citable for Lanford's theorem, hedged to "as described in expositions" |
| `salmon1984scientific` | Princeton UP, 1984 | [B, A] | citable for the causal-mechanical account |
| `salmon1971statistical` | Univ. of Pittsburgh Press, 1971, with Jeffrey and Greeno | [B]; S-R model [S] | citable for the statistical-relevance model. **Not** for the specific irrelevance examples |
| Kyburg 1965 | "Salmon's Paper", Philos. Sci. 32(2), 1965, from Cambridge's listing; pages 147–151 only inferred; the hexed-salt example **not seen** | partial | **not citable**. Present the hexed-salt and birth-control examples as "standard examples" without a citation |
| `nauenberg2015reception`, `bodenmann2010battle` | arXiv:1503.06861; Physics Today 63(1):27–32, 2010 | [B, A/S] | citable as secondary sources: Newton accounted for about half of the motion of the lunar apsides; Clairaut's 1749 resolution |
| Woodward 2014 pages; Putnam 1963 pages | re-searched; again not shown | — | keep omitted (`woodward2014simplicity`, `putnam1963degree` carry this note) |
| Wikipedia, "Craig's theorem" | — | — | **not citable** (an encyclopaedia used as a secondary source for Hempel's reply) |

### 2.6 The 24 entries copied without a search in this project

All 24 were re-searched, and all were confirmed at [B]. Most were also confirmed at [A]: `angluin1980inductive`, `berk1966limiting`, `chaitin1975theory`, `cook1979relative`, `filan2016loss`, `hutter2007universal`, `kleijn2006misspecification`, `koppel1987complexity`, `legg2006elegant`, `leike2015computability`, `leike2015solomonoff`, `schmidhuber2002speed`, `seiferas1978separating`, `tenenbaum2001generalization`; `kaye1991models` had a contents description. The rest reached [B] only: `angluin1988identifying` (via citing works only; no abstract or text exists online in the results), `cook1972hierarchy`, `doob1949application`, `hajek1993metamathematics`, `li2008introduction`, `muggleton1991inductive`, `plotkin1970note`, `shapiro1983algorithmic`, `solomonoff1999two` (read in full in the SOI project).

**Corrections made:**
* added DOIs: `angluin1980inductive`, `legg2006elegant`, `leike2015computability`, `li2008introduction`, `muggleton1991inductive`, `tenenbaum2001generalization`;
* `leike2015solomonoff`: pages 349–363;
* `schmidhuber2002speed`: series LNAI and volume 2375, now confirmed;
* series and address: `hajek1993metamathematics` (Perspectives in Mathematical Logic, Berlin), `kaye1991models` (Oxford Logic Guides 15, Clarendon Press), `li2008introduction` (Texts in Computer Science), `shapiro1983algorithmic` (ACM Distinguished Dissertations, Cambridge MA).

**Still unconfirmed fields:**
* `cook1972hierarchy`: pages, which stay omitted;
* `plotkin1970note`: the year, 1970 against 1969; most sources give 1970;
* `koppel1987complexity`: the year, 1987 against 1988 in one review.

### 2.7 `tenenbaum2006theory`

Re-searched twice: through the Princeton record, the hosted PDF of the TiCS special issue, and a search for the DOI usually attached to it. Authors, title, journal and year are confirmed [B, A]. Volume, issue, pages and DOI were again not shown, so **they are dropped**. The entry now gives the journal and year, with a note naming the special issue.

---

## 3. The modified Demski prior

**Sources found.**
* **The original post.** S. Garrabrant, "Asymptotic Logical Uncertainty: A Modification to the Demski Prior", Intelligent Agent Foundations Forum, August 2015 [B]. It is mirrored at `alignmentforum.org/posts/5bd75cc58225bf067037500a/…` and on the LessWrong and GreaterWrong mirrors of the same id.
  * The search results show only its opening [Q]. Demski "proposed a computably approximable coherent probability assignment in 2012", and the post presents "a modification developed last year by Benja Fallenstein, Demski, and the author".
  * The search tool's summary [S] adds that the modification "samples Turing machines rather than logical sentences" and comes with a computable approximation that is a logical predictor.
  * **The body of the post, with its definition, could not be read.** No mirror resolved, and the search results do not reproduce it.
* S. Garrabrant, "Asymptotic Logical Uncertainty: The Modified Demski Prior is Uniformly Coherent", Intelligent Agent Foundations Forum, dated 23 August 2015 in the search results [B]. The result is reported as "primarily due to Benja", that is Fallenstein [S].
* "Strict Dominance for the Modified Demski Prior" (Alignment Forum mirror of an IAFF post; **author and date not shown**).
  * Its stated aim [S]: the modified prior's hypothesis space is larger than Solomonoff induction's.
  * Its Theorem 1: the prior dominates the universal semimeasure.
  * Its Theorem 2: the dominance is strict.
  * A top comment notes that the analysis concerns measures, not semimeasures.
* "A Problem with the Modified Demski Prior" and "Modified Demski prior problem revision" (author and date not shown). The revision says the earlier argument "seems to make sense when the random bits are added as axioms, but fails in the more natural case where one updates on them in a Bayesian manner" [S].
* A. Appel, "Further Progress on a Bayesian Version of Logical Uncertainty", Alignment Forum (date not shown) [Q, below]. It is a later post that describes the modified prior in passing.
* S. Garrabrant, B. Fallenstein, A. Demski, N. Soares, "Inductive Coherence", arXiv:1604.05288 (v1 18 April 2016 as "Uniform Coherence"; v3 7 October 2016) [B, A]. This is already `garrabrant2016inductive`. Its §3 defines "a variant of the distribution and approximation scheme defined by Demski (2012)" [S]. A history post on logical induction credits "a modification of the Demski prior is inductively coherent" to Fallenstein [S].

**The definition, as stated in the sources that could be read.** These are search-result quotations [Q], not checked against the pages.
* *Inductive Coherence*, §3 (search excerpts of arXiv:1604.05288):
  > sample random Turing machines according to a simplicity prior, and interpret their outputs as claims about which sentences are true

  Claims
  > consistent with T* so far are added, and otherwise that machine is discarded

  The result is a random complete, consistent extension $T^*$ of the given theory $T$, obtained by an uncomputable process, and
  > We define P*(φ) to be the probability that φ ∈ T* if T* is sampled according to this process.

  The machine model, per the same excerpts [S]:
  * a universal Turing machine with an output-only tape;
  * an input tape that holds a random infinite bit string;
  * its output is read as a sequence of sentences of a fixed enumeration.

  The excerpts [S] also report two properties:
  * $P^*(\varphi)$ is bounded below in terms of the complexity of "the Turing machine that outputs only φ";
  * $P^*$ is coherent because $T^*$ is almost surely complete and consistent.
* Appel's post:
  > the modified Demski prior sampled turing machines that would spit out a (potentially infinite) list of sentences

  This
  > enables assigning positive probability to certain computable infinite sequences of sentences

  and
  > the Demski and modified Demski prior, in their true forms, involve calling a halting oracle to determine whether a contradiction is present when a sentence/infinite sequence of sentences is added to the "sentence pool"

These are the only wordings of the definition that this project has seen.

**Is `fundamentals` Prop 10.1's description accurate?** Yes, at the level the sources show. No discrepancy was found. Point by point:
1. *Sampling.* `fundamentals` §10 says: "at each step, run a fixed universal machine on fresh random bits and read its output as a set of sentences (a theory, possibly infinite)". The sources say the same: machines are drawn from a simplicity prior, realised as a universal machine with a random input tape, and the output is read as a possibly infinite sequence of sentences.
2. *Keeping.* `fundamentals` says: "keep the drawn theory iff it is consistent with $B$ and with what has been kept". The sources say:
   * a machine's claims are added if they are consistent with $T^*$ so far; otherwise the machine is discarded;
   * an oracle checks whether adding "a sentence/infinite sequence of sentences" creates a contradiction.

   This is the same, with $B$ in place of the sources' base theory $T$. Prop 10.1(e) also covers the one-by-one variant, which keeps a drawn theory's sentences one at a time while they stay consistent. Appel's own variant stops "at the first sentence inconsistent with earlier ones" [S]. So Prop 10.1 does not depend on which reading the original post uses.
3. *Limit and probability.* `fundamentals` says:
   * $T'_\infty$, the deductive closure of everything kept, is complete and consistent almost surely (Prop 10.1(e));
   * the probability of $\varphi$ is $\Pr[\varphi\in T'_\infty]$.

   The sources say:
   * $T^*$ is a random complete consistent extension;
   * $P^*(\varphi)=\Pr[\varphi\in T^*]$;
   * coherence holds because $T^*$ is almost surely complete and consistent.

   This is the same, and Prop 10.1(e) reproves what the paper asserts.
4. *Lower bound.* The proof of Prop 10.1(e) uses that a single draw is $\{\varphi\}$ with probability at least $2^{-K(\varphi)-c}$. Inductive Coherence bounds $P^*(\varphi)$ below by the complexity of the machine that outputs only $\varphi$. The two are consistent.
5. *Oracle.* Prop 10.1(c) says the process is not computable and is computable relative to $\emptyset'$. This agrees with Appel's "calling a halting oracle".
6. *Attribution and date.* `fundamentals` writes "Fallenstein, Demski and Garrabrant, Intelligent Agent Foundations Forum posts, c. 2015". The posts are by Garrabrant, and the August 2015 post says the modification was "developed last year", so in 2014, by Fallenstein, Demski and Garrabrant. Suggested wording: "a modification of Demski's prior due to Fallenstein, Demski and Garrabrant \citep{garrabrant2015modification}, used in \citet{garrabrant2016inductive}".
7. *Still unverified:*
   * the post's own definition text;
   * the details of the process, for example what happens to an infinite output that becomes inconsistent only after finitely many sentences;
   * the exact statements of the dominance post.

   The paper's related-work sentences must stay at the level of items 1–5 and must not quote the post.

**Bib entries.**
* Added: `garrabrant2015modification` and `garrabrant2015uniformly`, both [B], with content at [Q]/[S] as above.
* Kept: `garrabrant2016inductive`, with a "Bib editor" line that records the [Q] passages.
* Not added, because the author or date was not shown: the dominance post, the two "problem" posts and Appel's post.

---

## 4. Novelty checks

### 4.1 `shape` Thm 3.6 and the SAT 2026 paper (LIPIcs vol. 377, paper 5)

*Thm 3.6* (as in the `shape` record): for the hidden-state law $\mathcal H_q$ (weight-1 and weight-3 functionals), every UP-usable theory, with any intermediate concepts and any depth, has written length $2^{\Omega(m^{\varepsilon/3})}$, while Gaussian elimination uses a linear-size theory. It is proved there, given GKRS 2019.

**The SAT 2026 paper is identified.** It is Paul Beame and Glenn Sun, "Extending CDCL to Disjunctions of Parity Equations", SAT 2026, LIPIcs 377, 5:1–5:21, doi 10.4230/LIPIcs.SAT.2026.5, arXiv:2605.15002 [B]. Its abstract was read twice [A]:
* it introduces CDCL(⊕) for XNF formulas (disjunctions of parity equations);
* CDCL(⊕) produces Res(⊕) proofs and, with nondeterministic decisions and restarts, polynomially simulates Res(⊕);
* new Res(⊕) inference rules translate 1-UIP learning;
* its parity reasoning branches on parity equations, does linear algebra during unit propagation and learns linear clauses;
* it comes with a solver, Xorcle.

**Verdict: it neither proves nor implies Thm 3.6.**
* It is about a proof system and a solver that reason natively with parity. It is not about the size of CNF encodings with auxiliary variables, about propagation completeness or arc consistency, or about monotone circuit lower bounds. A targeted search for encoding lower bounds in it found nothing.
* Caveat: the full text was not read, so an introductory remark on encodings cannot be excluded. It would not be a proof of Thm 3.6.
* Its content fits the paper's reasoner-relativity point. A reasoner whose propagation does linear algebra is the algebraic reasoner for which the hidden-state law is cheap. It may be cited for that, as `beame2026extending`.

**Prior statements of Thm 3.6 or its general form.**
* Gwynne and Kullmann (LATA 2014, `gwynne2014sat`; and arXiv:1406.7398 [A]) prove a **superpolynomial** lower bound for "good" (arc-consistent) representations of XOR systems, auxiliary variables allowed. The search summaries agree that their route is through monotone circuits (Bessiere et al.) and BGW.
* GKRS 2019 prove an exponential monotone circuit lower bound for (3-)XOR-SAT on $2n^3$ input bits [A]. Cavalar–Oliveira's CCC 2023 paper restates this [A].
* No source found states the combination: an exponential ($2^{n^{\Omega(1)}}$) lower bound for arc-consistent or propagation-complete CNF representations of XOR systems with auxiliary variables, obtained from GKRS. This was checked by three searches on propagation-complete or arc-consistent XOR encodings with monotone circuit bounds, plus the GK follow-up.
* Kučera–Savický (JAIR 2020) prove exponential gaps **without** auxiliary variables only [A].

**How to state it.** As the `shape` record already says: the bound is a short combination of the Bessiere et al. reduction with GKRS, improving the superpolynomial bound that Gwynne and Kullmann obtained via BGW. "We did not find it stated; it is probably known to specialists." Do not claim it as a new lower-bound technique. **The unread-paper caveat can now be dropped:** the SAT 2026 paper is identified and is not about encodings.

### 4.2 The lottery (`logic` Thm 2.2)

*Statement.* There is a stream $D_\infty$ of labelled sentences, computable from $\emptyset'$, with these properties:
* (a) $M_A(D_n)\ge2^{-K(G_{\rm lot})-c}\cdot0.2887\ldots$ for all $n$, so the loss is bounded;
* (b) no consistent r.e. theory proves every member of $D_\infty^\pm$;
* (c) $W_A$, $K_A$ and $K_{\rm fin}$ diverge;
* (d) the limit posterior lives on random theories whose closure is not r.e.

**Searches.**
* Random axiom systems or probabilistic enumeration of theories against r.e. theories.
* Universal priors over theories.
* Probabilistic inductive inference.

**Found.**
* (i) The relatives already recorded in `logic` §7:
  * de Leeuw–Moore–Shannon–Shapiro: what a probabilistic machine enumerates with positive probability is c.e. The lottery escapes this because different tapes yield different theories.
  * Kučera's theorem and the bounded-DNC dichotomy of Bienvenu–Porter: randomness helps for mass problems, and the lottery's survival condition $\sum_k 2^{-(k+1)}<\infty$ is the convergence condition there.
  * Bienvenu et al. and Shen on random *true* axioms.
  * Levin 2013.
* (ii) **A relative not in the records: probabilistic inductive inference.**
  * Pitt, "Probabilistic Inductive Inference", J. ACM 36(2):383–433, 1989, `pitt1989probabilistic` [B, A]: the classes inferable by probabilistic strategies equal those inferable by teams of machines.
  * Ambainis's survey, arXiv:cs/9902026, `ambainis1999probabilistic` [B, A]. It reports Freivalds-type thresholds [S]: above a success probability (2/3 for finite identification), a probabilistic learner can be made deterministic; below it there are team hierarchies.

  The parallel to the lottery is real. Logic Prop 2.3 shows that the majority vote at a density point with arity $r$ works at threshold $1/(r+1)$, while the lottery survives with probability 0.2888 against constraints of unbounded arity. But that literature concerns learners (strategies that output hypotheses), not hypotheses that are random theories inside a Bayes mixture.
* (iii) Lipton's 2011 blog post on random axioms (non-r.e. sets of random true axioms; a blog, not citable as a result).

**Verdict.**
* No prior statement of the lottery was found: a Bayes mixture over random axiom systems whose one-tape version succeeds where every r.e. theory, and the coin-free and Kolmogorov versions, fail.
* Novelty is plausible at search level, as `logic` §7 states it.
* The paper should cite the mass-problem relatives (as in `logic` §7) and add one sentence on probabilistic inductive inference:
  > that randomisation can succeed where determinism cannot, below a success-probability threshold, is familiar for learners \citep{pitt1989probabilistic,ambainis1999probabilistic}; here the random objects are the hypotheses themselves

  Pitt's content is at abstract level and the thresholds at secondary level, so keep the sentence qualitative.

### 4.3 The complexity-theoretic Craig result (`terms` Thm 3.3; Lemma 3.1)

*Statement.*
* Lemma 3.1: Craig's padding by run time writes $2^{\mathrm{ds}}$ in unary.
* Thm 3.3: run-padded axiomatisations with polynomial-time membership fit exactly $\mathsf P$ under each charged-deduction reading at polynomial budgets.

These make "Craigian axiomatisations are useless in practice" precise.

**Searches.** Two extended searches:
* Craig's trick with complexity, padding, proof length and blow-up;
* lengths of proofs in Craigian re-axiomatisations.

**Found.**
* The standard facts that every r.e. theory has a primitive-recursive and a p-time axiomatisation (Wikipedia; Krajíček, "A proof complexity conjecture and the Incompleteness theorem", JSL 90(3), 2025, arXiv:2303.10637, `krajicek2025proof` [B]). Krajíček writes, per the excerpt [Q], "each r.e. theory has a p-time axiomatization (a simple variant of Craig's trick)".
* Putnam 1965's argument (`putnam1965craig`).
* Pudlák's survey of lengths of proofs (`pudlak1998lengths`; it was not seen to contain such a result).

Nothing found quantifies the size of Craigian axioms or classifies what run-padded axiomatisations can fit.

**Verdict.**
* No prior statement was found. Scout L had reached the same conclusion; this confirms it at search level.
* Suggested wording: "we did not find a complexity-theoretic form of the classical reply in the literature". Cite `krajicek2025proof` for the standard p-time form of Craig's construction, so that no one reads Thm 3.3 as contradicting it. Craig's sets can be decidable in polynomial time; Thm 3.3 concerns what fits the data under charged deduction.

### 4.4 The coin-free equivalence (`sfi` Thm 2.1)

*Statement.* $W_A\asymp W^{\rm cons}\asymp W_A^{\rm dec}$, $W^{\rm cl}$ within constants; $K_A$, $K_A^{\rm dec}$, $K_F^{\rm cons}$ and $K_F^{\rm cl}$ agree up to $\pm c$; the three-outcome weights agree too.

**Searches.** Universal priors over axiom systems against priors over consistent truth assignments; Craig's theorem in Solomonoff induction.

**Found.**
* Nothing outside this repository.
* The nearest literature:
  * the modified Demski prior, which samples theories by a universal machine (§3);
  * the strict-dominance post, which compares that prior with the universal semimeasure. Its author and date were not shown, so it is not citable;
  * Hutter et al.'s and Gaifman's probabilities on sentences, which are probabilities of truth.
* Inside the repository: Hänni's working notes conjecture the equivalence, and the earlier report proved its proof-requiring form (AI-paper Thm 6.3).

**Verdict.**
* No prior statement was found in the literature. Novelty against the literature is plausible at search level.
* Credit inside the repository belongs in the short neutral footnotes: "first appeared in Hänni's working notes \citep{hanni2026notes}"; the proof-requiring version is in \citet{claude2026axiominduction}.
* The paper should present Thm 2.1 as "Craig's construction inside the universal prior", which is what it is.

---

## 5. Citable and not citable

### 5.1 Citable: entries this editor added or changed

The levels are those of §2–§4, and each entry's comment repeats them. Cite each work for the purpose given, and for nothing stronger.

| key | may be cited for |
|---|---|
| `dempster1967upper` | belief functions from a multivalued mapping; Dempster's rule |
| `shafer1976mathematical` | the theory of belief functions |
| `suppes1977using` | upper and lower probabilities from random relations; the geometric rule as "usually attributed to" them |
| `pearl1988probabilistic` | belief functions read as probability of provability (ch. 9), hedged |
| `demuth1975constructive` | a left-c.e. real plus a random left-c.e. real is random (as attributed) |
| `downey2002randomness` | the converse of Demuth's theorem (as attributed); Solovay degrees of c.e. reals |
| `kucera2001randomness`, `calude2001recursively` | random left-c.e. reals = Ω-numbers = Solovay-complete left-c.e. reals |
| `downey2010algorithmic` | textbook source for Solovay reducibility |
| `solovay1975draft` | origin of Solovay reducibility (with `downey2010algorithmic`) |
| `smullyan1961theory` | effective inseparability of the provable and refutable sentences (location not seen) |
| `sipser1983complexity`, `lautemann1983bpp` | BPP in the polynomial hierarchy; BPP ⊆ Σ2 ∩ Π2 |
| `hartmanis1965computational` | time complexity; the multitape-to-one-tape simulation, in textbook form |
| `presburger1929vollstandigkeit` | completeness and decidability of Presburger arithmetic |
| `matiyasevich1970enumerable`, `davis1973hilbert` | MRDP |
| `pippenger1979relations` | $O(T\log T)$ circuits for time-$T$ machines |
| `boolos2007computability`, `ebbinghaus1999finite` | textbook facts (no chapter numbers) |
| `lowenheim1915moglichkeiten`, `behmann1922beitrage` | decidability of monadic first-order logic |
| `fraisse1954quelques` | the back-and-forth characterisation of elementary equivalence |
| `mostowski1952models` | reflexivity of PA |
| `kreisel1968reflection` | PRA + RFN(PRA) ≡ PA |
| `simpson2009subsystems` | ACA₀ finitely axiomatisable and conservative over PA (as reported) |
| `hajek1993metamathematics` | fragments of PA; IΣ1 finitely axiomatisable (standard; location not seen) |
| `woodin2011potential` | context for flexible formulas |
| `myasnikov2008generic` | generic-case undecidability |
| `bienvenu2017diagonally` | DNC functions; a secondary source for Kučera's theorem |
| `babai1999superpolynomial` | linear-size monotone span programs vs superpolynomial monotone circuits |
| `alon1987optimal`, `bhattacharyya2012transitive`, `yao1982space` | product queries and TC-spanners of the path (inverse-Ackermann bounds) |
| `chandra1985unbounded` | constant-depth circuits for associative functions and prefixes |
| `hansel1964nombre`, `katona1967problem` | the $n\log_2n$ biclique-cover bound (Hansel's lemma) |
| `bensasson2001short`, `orevkov1982lower` | resolution width vs size; non-elementary cut elimination |
| `cavalar2023constant` | constant-depth vs monotone circuits; restates GKRS's 3-XOR-SAT bound |
| `delval1994tractable` | compiling a theory so that unit resolution is complete (as reported) |
| `beame2026extending` | a solver whose unit propagation does linear algebra over parity constraints |
| `selman1996knowledge`, `darwiche2002knowledge`, `babka2013complexity`, `kucera2020bounds`, `gwynne2014sat`, `bessiere2009circuit`, `bordeaux2012knowledge`, `emdin2022cnf`, `goos2019adventures`, `hastad1986almost`, `berman2014steiner`, `urquhart1987hard` | as in the `shape` record §9, at abstract level (Urquhart at secondary level) |
| `suppes1962models` | the hierarchy of models of data |
| `groenendijk1984studies` | partition semantics of questions |
| `dorling1979bayesian`, `strevens2001bayesian` | the Bayesian treatment of Duhem's problem and the objection to it |
| `greaves2006justifying`, `pettigrew2016accuracy`, `leitgeb2010objective` | epistemic-utility justifications of conditionalisation; accuracy-first epistemology |
| `lanford1975time` | Lanford's theorem (as described in expositions) |
| `salmon1984scientific` | the causal-mechanical account of explanation |
| `salmon1971statistical` | the statistical-relevance model |
| `nauenberg2015reception`, `bodenmann2010battle` | the lunar-apsides history (Newton accounted for about half; Clairaut 1749) |
| `garrabrant2015modification`, `garrabrant2015uniformly`, `garrabrant2016inductive` | the modified Demski prior, at the level of §3 items 1–5 |
| `pitt1989probabilistic`, `ambainis1999probabilistic` | probabilistic vs deterministic inductive inference; teams (qualitative) |
| `krajicek2025proof` | every r.e. theory has a p-time axiomatisation (Craig's trick) |
| `tenenbaum2006theory` | theory-based Bayesian models of induction (journal and year only) |
| the 24 re-searched entries (§2.6) | as in the synthesis §5.7 groups below, at the level in each comment |

### 5.2 Citable: entries carried from `research/refs.bib`, by group

Each of these was verified by a scout, a thread or a referee of this project, at the level stated in its comment. Those this editor re-searched or completed (§2.4, §2.6, §2.7) appear here too, under their group. Cite each for the topic of its group in the synthesis (`notes-final.md` §5.7), and hedge every content claim to the comment's level ("abstract", "secondary", "bibliographic data only").

* **1. Universal induction and operator induction:** `solomonoff1964formal`, `solomonoff1978complexity`, `solomonoff1999two`, `solomonoff2008three`, `li2008introduction`, `hutter2005universal`, `levin1973universal`, `zvonkin1970complexity`, `leike2015computability`, `sterkenburg2016solomonoff`, `sterkenburg2019putnam`, `putnam1963degree`.
* **2. Probabilities on sentences:** `gaifman1964concerning`, `scott1966assigning`, `gaifman1982probabilities`, `hutter2013probabilities`, `demski2012logical`, `garrabrant2016inductive`, `garrabrant2016logical`, `sawin2013computable`, `christiano2014nonomniscience`, `carnap1950logical`.
* **3. Belief functions:** none carried; see §2.1 (`dempster1967upper`, `shafer1976mathematical`, `suppes1977using`, `pearl1988probabilistic`).
* **4. Formal learning theory:** `gold1965limiting`, `gold1967language`, `putnam1965trial`, `shapiro1981algorithm`, `shapiro1991inductive`, `osherson1986systems`, `osherson1991universal`, `kelly1996logic`, `martin1998elements`, `angluin1980inductive`.
* **5. ILP and compression:** `muggleton1991inductive`, `muggleton1994inductive`, `muggleton1995inverse`, `muggleton1988machine`, `conklin1994complexity`, `srinivasan1994justification`, `cropper2022inductive`.
* **6. Bayesian theory learning in cognitive science:** `kemp2008theory`, `kemp2010probabilistic`, `ullman2012theory`, `goodman2008rational`, `tenenbaum2006theory`, `tenenbaum2001generalization`.
* **7. Random axioms, Chaitin, probabilistic computation:** `chaitin1974information`, `chaitin1975theory`, `raatikainen1998interpreting`, `bienvenu2014axiomatic`, `shen2011random`, `levin2013forbidden`, `calude2005complexity`, `deleeuw1956computability`, `kucera1985measure`, `bienvenu2016deep`, `becher2006randomness`, `barmpalias2016random`, `solovay1977random`, `vereshchagin2007kolmogorov`, `shekhovtsov2023enumerating`, `kyburg1961probability`.
* **8. Gödel phenomena, Kreisel, generic decidability:** `smorynski1977incompleteness`, `kripke1962flexible`, `mostowski1961generalization`, `blanck2017marginalia`, `hamkins2018modal`, `parikh1973some`, `baaz1993kreisel`, `hrubes2007theories`, `hrubes2009kreisel`, `santos2021variants`, `hamkins2006halting`, `garber1983old`, `hacking1967slightly`.
* **9. Craig, Ramsey, Hempel, theoretical terms:** `craig1953axiomatizability`, `craig1956replacement`, `kleene1952finite`, `craigvaught1958finite`, `pakhomov2019question`, `ramsey1931theories`, `lewis1970define`, `carnap1952meaning`, `hempel1958theoretician`, `putnam1965craig`, `putnam1962what`, `niiniluoto1972inductive`, `hintikka1970towards`, `niiniluoto1973theoretical`, `ehrenfeucht1961application`, `rabin1969decidability`, `rylnardzewski1952role`, `godel1936lange`, `pudlak1998lengths`.
* **10. Complexity used:** `fischer1974super`, `berman1980complexity`, `cook1979relative`, `chandra1981alternation`, `cook1972hierarchy`, `seiferas1978separating`.
* **11. Knowledge compilation, propagation, circuits; declarative vs procedural:** `selman1996knowledge`, `darwiche2002knowledge`, `bordeaux2012knowledge`, `babka2013complexity`, `kucera2020bounds`, `gwynne2014sat`, `bessiere2009circuit`, `emdin2022cnf`, `goos2019adventures`, `hastad1986almost`, `berman2014steiner`, `urquhart1987hard`, `statman1979lower`, `mccarthy1959programs`, `winograd1975frame`, `kowalski1979algorithm`, `khardon1997learning`, `juba2013implicit`, `valiant2000robust`, `ellis2021dreamcoder`.
* **12. Best systems, approximation, MDL:** `lewis1983new`, `lewis1994humean`, `lewis1973counterfactuals`, `cohen2009better`, `woodward2014simplicity`, `forster1994how`, `rissanen1978modeling`, `wallace2005statistical`, `grunwald2007minimum`, `gacs2001algorithmic`, `vereshchagin2004kolmogorov`, `koppel1987complexity`, `hutter2010complete`, `scholkopf2000new`, `popper1963conjectures`, `miller1974popper`, `tichy1974popper`, `niiniluoto1987truthlikeness`, `moulines1976approximate`, `helly1923mengen`, `akbarpour2010metitarski`.
* **13. Explanation and unification:** `hempel1948studies`, `friedman1974explanation`, `kitcher1981explanatory`, `kitcher1989explanatory`, `bromberger1966why`, `glymour1978two`, `woodward2003making`, `myrvold2003bayesian`, `schaffner1967approaches`, `duhem1954aim`, `vanfraassen1980scientific`, `belnap1976logic`.
* **14. What a theory is:** `suppe1977structure`, `suppes1960comparison`, `sneed1971logical`, `balzer1987architectonic`, `halvorson2012what`, `lutz2017what`, `kuhn1970structure`, `kuhn1977second`, `polanyi1958personal`, `polanyi1966tacit`, `cartwright1983how`, `cartwright1999dappled`, `morgan1999models`, `frisch2004inconsistency`, `brown2009boltzmann`, `wilson2006wandering`, `hanson1958patterns`, `laudan1977progress`, `laudan1981confutation`, `psillos1999scientific`, `hacking1983representing`, `sellars1953inference`, `kripke1980naming`, `lakatos1976proofs`, `hesse1963models`, `gentner1983structure`, `hobbs1993interpretation`, `bernardo1979expected`.
* **15. Kepler, Newton and the computations:** `kepler1992new`, `kuhn1957copernican`, `wilson1985great`, `clemence1947relativity`, `wesley1978accuracy`, `harper2011newton`, `mackay1992bayesian`, `jefferys1992ockham`, `smith1984efficient`, `neal2003slice`, `langley1987scientific`, `evans2021making`, `udrescu2020ai`, `schmidt2009distilling`.
* **Not assigned to a §5.7 group** (kept for the sections that use them; cite for the content recorded in the comment): `angluin1988identifying`, `bauwens2026solomonoff`, `berk1966limiting`, `carnap1950empiricism`, `carnap1956methodological`, `chater2003simplicity`, `church1936note`, `doob1949application`, `durrett2019probability`, `filan2016loss`, `gaifman2004reasoning`, `garrabrant2017formal`, `hajek1993metamathematics`, `hintikka1966two`, `hintikka1999inquiry`, `hutter2007universal`, `kalmar1937zuruckfuhrung`, `kaye1991models`, `kelly1989convergence`, `kelly1995computable`, `kleijn2006misspecification`, `lattimore2011universal`, `lauth1993inductive`, `legg2006elegant`, `leike2015solomonoff`, `muggleton1996learning`, `muggleton2015meta`, `mukouchi1995towards`, `osherson1986identification`, `osherson1992universal`, `plotkin1970note`, `rathmanner2011philosophical`, `schmidhuber2002speed`, `shapiro1983algorithmic`, `sharma2025learning`, `statman1978bounds`, `sterkenburg2026solomonoff`, `tarski1951decision`, `valiant1984theory`, `vanlambalgen1989algorithmic`, `vitanyi2000minimum`.

### 5.3 Not citable

Do not cite these. For a partly verified entry, do not use the unverified field or claim.
1. **Jockusch–Soare 1972 for "the PA degrees form a null class".** Neither 1972 paper was confirmed to contain it. `fundamentals` Prop 8.7 is proved without it.
2. **Montague 1961 for the non-finite axiomatisability of ZF.** Only the bibliographic data were found, and the paper does not use it.
3. **Mostowski 1952 or Kreisel–Lévy 1968 for the *essential* reflexivity of PA.** Only reflexivity (Mostowski) and PRA + RFN(PRA) ≡ PA (Kreisel–Lévy) were confirmed.
4. **Löwenheim 1915 for the quantitative finite model property** used in `terms` Lemma 6.1. Cite Löwenheim and Behmann only for decidability.
5. **Kyburg 1965 ("Salmon's Paper", Philos. Sci. 32(2)), and any source, for the hexed-salt example.** The example was not seen in any source. Also Salmon 1971 for the birth-control example: cite Salmon 1971 for the S-R model only.
6. **The ICALP 1983 paper of Chandra, Fortune and Lipton.** Its volume and pages were not confirmed; cite `chandra1985unbounded`.
7. **The forum posts without a known author or date:** "Strict Dominance for the Modified Demski Prior"; "A Problem with the Modified Demski Prior"; "Modified Demski prior problem revision"; Appel's "Further Progress on a Bayesian Version of Logical Uncertainty". **And the body of `garrabrant2015modification`.** Cite the post for attribution and date only, and quote no definition from it.
8. **Wikipedia ("Craig's theorem") and Lipton's blog post on random axioms.** Neither is a citable source.
9. **Fields not to use:** pages of Woodward 2014 and Putnam 1963; pages of Sipser 1983 and Cook 1972; the volume, issue, pages and DOI of Tenenbaum–Griffiths–Kemp 2006; the end page of Woodin 2011; the journal volume and pages of Ambainis's survey (cite the arXiv version); the JSL pages of Krajíček 2025. Pages 6–20 of Håstad 1986 were not re-confirmed; they are kept as recorded by the `shape` referee, but are safer omitted if in doubt.
10. **Content beyond the recorded level.** No theorem number, page number or exact constant from a work whose comment does not record it. In particular:
    * the exact error term of Shekhovtsov–Zakharov;
    * theorem numbers in Bienvenu et al. 2014 and Bienvenu–Porter 2016;
    * Pearl's p. 427;
    * Gold's theorem number;
    * the form (B*) and the reduction sizes of Berman 1980;
    * the length conventions of Fischer–Rabin.

---

## 6. Verification log

* **Read.**
  * The brief `research/00-brief.md`, in full.
  * `research/final-check.md`, in full.
  * `research/notes-final.md`: §0, §2.8, §5.1–§5.7, and the list of references not in `refs.bib`.
  * The reference sections of the thread records: `fundamentals` §10 (in full) and §14; `sfi` §14 and the statement of Thm 2.1; `logic` §7, §11 and the statement of Thm 2.2; `terms` §10, §14, Lemma 3.1 and Thm 3.3; `shape` §9, the Thm 3.6 lines and Rem 3.7; `laws` §12; `philosophy` §7.
  * `research/refs.bib`: its header, and every entry this editor changed.
  * The SOI `paper/bib/core.bib` and `merge_bib.py`; the READMEs and `paper/main.tex` titles of `axiom-induction`, `axiom-schemas` and `inferential-learning`; the planning editor's `paper/merge_bib.py` and `build.sh`.
* **Searched.** About 90 WebSearch queries, standard and extended. No page fetch succeeded (DNS errors on every host, as above). The proxy status query was refused by the permission system and was not pursued.
* **Run.**
  * Throwaway scripts in the scratchpad, `/tmp/claude-0/-home-user-AI-works/c4435474-536f-5a96-a73c-7d0c5ea93659/scratchpad/bibed/`:
    * `parse.py`, `make_initial.py`: generate the initial `refs.bib` from `research/refs.bib`;
    * `replace.py`: replace an entry by key.
  * Inline Python edits for comments and fields.
  * A BibTeX test (`\nocite{*}`, `plainnat`): 299 entries typeset, no LaTeX error, one intentional warning.
  * Duplicate-key check: none.
* **Written.** Only `paper/bib/refs.bib`, `paper/bib/core.bib` and `paper/bib/bib-report.md`. Nothing else in the repository was changed. No git command was run.
