# Referee report on the citations of the note (editor of Section 12 and of the references)

Written on 16 November 2026 by the editor of Section 12. Files produced with this report:

* `research/sections/related-work-final.md`: Section 12 of the note (1497 whitespace-separated tokens by `wc -w`, of which 1266 contain a word of two or more letters; the limit is 1500 words).
* `research/sections/references-short.md`: the reference list as it stands in the note, 67 entries, one line each.
* `references.md`: the same 67 entries with bibliographic data and provenance.

`note.md` was not edited. Line numbers below refer to `note.md` as assembled on 16 November at 03:11. Two section sources (`rehearsal-core.md`, `hellinger-runs.md`) were revised by others while this report was written; where a sentence quoted below has changed there, this is said.

## 0. Result in brief

1. **Three attributions of the note are not supported by the project's own records** (Section 2; the second is graded major): the example of singletons in N4 is credited to Li, Littman and Walsh, while the only source that anybody read credits it to Sayedi, Zadimoghaddam and Blum; "Observation B of the researcher's notes" (Ab3) is not in the researcher's notes but is a derivation of this project's digest of them; and the seven tests of Section 10 are a derivation of that digest, not tests that "the researcher's notes apply".
2. **Four further attributions say more than their source** (Section 2): "standard; Barron and Cover 1991" for the oracle inequality without A2; "standard, Thompson 1933" in 9.2; "Paper 1, Proposition 8.2" for the mixture of this note; and Cohen, Hutter, Bengio and Russell (2025) for "the mixture's weight on such partners".
3. **Twenty-five works cited in Sections 0 to 11 were opened by nobody in this project** (Section 4); Section 12 adds three more, and three works are named without a year and were not opened either. For each, the statement used rests on another work that was read, on a search result, or on memory. `references.md` says which. Sections 0 to 11 of the note mark this for some of them and not for others.
4. **The citations that could be opened were opened again in this session and agree with the note**, apart from the points above: 30 arXiv papers (of one only the abstract) and 2 papers on proceedings.mlr.press were read at the places cited, and the three documents of this repository at the statements cited (Section 8).
5. **Bibliographic data** were verified for all entries except the fields listed in Section 5.
6. **Section 12** was rewritten; Section 7 says what changed against the draft, what was left out and why.

## 1. What was done, and how

* **Citations extracted.** `note.md` was read in full. Every citation of Sections 0 to 11 and 13 was listed by hand and the list was checked with two pattern searches (author names followed by a year; possessive forms such as "Blackwell's … (1956)"). After the new Section 12 and the new reference list were written, the note was assembled into a scratch file with a copy of `research/orchestration/assemble.py` that writes outside the project (all replacements of `patches.py` still match exactly once), and a script compared every pair (surname, year) in the assembled text with the reference list. Result: 53 distinct pairs, all with an entry; the entries that no pair matches are those cited by label or by possessive form (Paper 1, Paper 2, `ultranatural/note.md`, the researcher's notes, Blackwell, Spencer, Christiano, Landauer, Lehrer, the second Dasgupta entry), the three entries marked [named] (Azuma, Le Cam, Yu) and the one marked [restatement] (Özkural).
* **Provenance.** Taken from the editors' notes at the end of the section sources `research/sections/*.md`, from the literature sections of the eight proof files, from the reference list of the draft `research/sections/related-work.md`, and from `research/literature-checks.md`. Where a file says that a source was not opened, `references.md` says so; nothing was upgraded on the strength of those files.
* **Sources read in this session.** Where this report or `references.md` says "this session", the editor of Section 12 downloaded the PDF from arxiv.org or proceedings.mlr.press, extracted the text with `pdftotext`, and read the passage named. Section 8 lists them.
* **Network.** arxiv.org and proceedings.mlr.press could be opened. api.crossref.org, dblp.org, jmlr.org, proceedings.neurips.cc and ttic.edu did not resolve, and after these failures no further hosts were tried. To check the remaining fields and to open the works of Section 4, these hosts (and the publishers' sites, the Alignment Forum and jstor.org) would have to be allowed in the session's network settings. For works that are on neither reachable host, bibliographic data rest on web-search results and on the reference lists of papers that were read.
* **Web queries.** Queries contained titles, authors and venues of published works only. No name of a person of this project, no repository name and no text of the project was put into a query.

## 2. Attributions in the note that the provenance does not support

Each item gives the place, what the note says, what the records and this session's reading support, and the grade. The exact replacements are in Section 3.

**A1 (minor). Section 7.4, Proposition N4: the example of singletons is credited to Li, Littman and Walsh (2008).** The note: "standard: the example of singletons for learners that may say "I don't know", Li, Littman and Walsh 2008". Nobody opened that paper. The only reading on record is the digest `research/understand/abstention-shift.md` (its Section 3.1, "read in source: Bal15 §2.1.2, citing Example 1 of SZB10"), and the draft of Section 12, which lists the example under Sayedi et al. This session Balsubramani (arXiv:1512.08133, Section 2.1.2) was read: it describes the model of Li, Littman and Walsh, gives the singletons as a class that needs 2ⁿ − 1 answers "I don't know", and ends "for the formal details, the reader is referred to Example 1 of [SZB10]". A search result this session reports from the text of Sayedi, Zadimoghaddam and Blum (2010) that its Example 1 "shows how hard it can be to learn in the KWIK model"; the paper itself could not be opened. So the model is Li, Littman and Walsh's, the bound of |H| − 1 answers is theirs (as Zhang and Chaudhuri and Balsubramani restate it), and the example is, on the evidence available, Example 1 of Sayedi et al. Whether the 2008 paper also has it is not known, which is why the grade is minor; the sentence can also be read as crediting only the model, and then it leaves the example without a source.

**A2 (major). Section 7.3, Proposition Ab3: "Observation B of the researcher's notes".** Observation B is in `research/understand/notes.md`, Section 6.2. That file is this project's digest of the researcher's notes, and its Section 6 begins: "Everything in this section is [my own derivation] unless tagged otherwise, and is unrefereed." This session the researcher's notes were searched in the local copy that the digest used (971 text files and the text of 29 PDF files): the words "Observation A" and "Observation B" occur in none of them. `proofs/rehearsal-core.md`, Section 17, already says of Observation A that it "is that digest's own derivation". The reader of the note is the researcher; he will not find the observation in his notes.

**A3 (minor). Section 10, first sentence: "The tests are those that the researcher's notes apply to any proposal."** The seven tests are a list in Section 5 of the digest, headed "The tests he is likely to apply to any proposal [my own derivation, from the pattern of his objections to his own schemes]". They are the digest's reading of his objections, not tests stated or applied in his notes. (By contrast, "as the researcher's notes claim" in Section 8.6 is supported: the sentence "the probability of P-abiding generalization is at least 2^(−C(P))" was found this session in his note on Solomonoff function induction, PDF, Section 3, stated without proof.)

**A4 (minor). Section 1, caveat on A2: "Without it R1 is an oracle inequality (standard; Barron and Cover 1991)".** Nobody opened Barron and Cover (1991). According to Zhang (2006), read by a verifier, an editor and again this session, that paper is about the estimator that minimises description length and shows a rate in probability for it in terms of the index of resolvability; Zhang adds that "no simple finite-sample bound was obtained". The inequality of the caveat is the regret bound of the mixture against an arbitrary member (Section 3.1). `proofs/assumptions.md`, Section 11, says it correctly: the regret bound "in the form of the index of resolvability of Barron and Cover". The note's shorter wording credits them with the inequality.

**A5 (minor). Section 9.2: "(Proposition 7.7; standard, Thompson 1933)".** Thompson (1933) was opened by nobody; it was named from memory by the second verifier of assumptions as the origin of posterior sampling. The statement in the note (averaged over the prior, a posterior draw per run is exact) is proved in the proof file in two lines. As written, the citation says that the statement is in Thompson's paper.

**A6 (minor). Section 10, test 2: "on some machine a deviant answer there has probability at least one half (Paper 1, Proposition 8.2)".** Read this session in the PDF of Paper 1: Proposition 8.2 is stated for the coin-free version W and for the one-tape version M_F, not for the mixture of this note (Solomonoff's per-query mixture, a class of samplers with private coins). `proofs/assumptions.md` quotes the proposition from the digest `repo.md`; nobody in that part opened the paper. The statement for any scheme whose bias comes from the reference machine alone is Theorem 3 of `ultranatural/note.md` (read this session): on a machine sep(x; A) + O(1) bits away the roles of two labels at x are exchanged, and the scheme behaves as before away from the separating set. The draft of Section 12 cited both.

**A7 (minor). Section 4.1: "The mixture's weight on such partners was known (Paper 2, Proposition G.5; Cohen, Hutter, Bengio and Russell 2025)".** Proposition G.5 of Paper 2 was read this session and is exactly this statement for the per-query mixture (posterior mass at least 2^(−λ(K(Q,b)+κ)), λ ≥ 1). Theorem 1 of Cohen, Hutter, Bengio and Russell, also read this session, is a different statement: after an unprecedented event some nearly optimal policy lies within a small KL divergence of the Bayesian imitator. `research/outline.md`, Addendum 2, item 3, calls it "a published relative". The note lists it as a second source of the same fact.

**A8 (note). Section 4.3, N2c: "It is the membership-query algorithm of Hegedűs (1995) and Moshkov (1983), as in Bshouty (2017, Lemma 3)".** Neither Hegedűs nor Moshkov was opened by anyone. Bshouty (read by a verifier, by the editor and this session) attributes the *bounds* of his Lemma 3 to them and introduces the algorithm of his proof with "Here, we will give another proof that gives, asymptotically, the same upper bound". Hanneke and Yang (Appendix B.1, read this session) attribute an algorithm of the same kind (majority vote of the version space, then a specifying set) to Hegedűs. The attribution is right in substance; "as in Bshouty" should carry the weight.

**A9 (note). Section 6.2, S5: "label-efficient prediction, Cesa-Bianchi, Lugosi and Stoltz 2005".** The paper was opened by nobody. An abstract seen in a search result this session says that label-efficient prediction is "a variant of prediction with expert advice proposed by Helmbold and Panizza" and that the paper gives matching upper and lower bounds for a fixed number of queries. The name of the setting and the citation are right as far as this goes; the earlier origin is not checked.

**A10 (note). Sections 5.1 and 8.4: the halving algorithm, "Littlestone 1988".** The paper was opened by nobody. Search results this session: course notes that attribute the bound log₂|C| to it, and a technical report that says the algorithm goes back to earlier work and "is given this name in [Lit88]". Paper 1 of this repository cites "the halving argument of Barzdin and Freivalds, 1972; Littlestone, 1988". The note's citation is acceptable; "the halving algorithm (so named by Littlestone 1988)" would be exact.

## 3. Sentences of Sections 0 to 11 and 13 whose citation should change

Each item gives the exact sentence of `note.md`, the replacement, and the section source in which the sentence stands. No source was edited.

1. **Section 1, caveat on A2** (`research/sections/assumptions.md`, block A). Finding A4.
   * Sentence: "Without it R1 is an oracle inequality (standard; Barron and Cover 1991): for every ν in H the bound is L·ln(1/w(ν))/n plus the divergence of ν from the human, summed along the *mixtures'* runs, not the human system's, and averaged over the rounds (Theorem 2.1)."
   * Replacement: "Without it R1 is an oracle inequality (standard: the regret bound of Section 3.1 against an arbitrary member; its right side has the form of the index of resolvability of Barron and Cover 1991): for every ν in H the bound is L·ln(1/w(ν))/n plus the divergence of ν from the human, summed along the *mixtures'* runs, not the human system's, and averaged over the rounds (Theorem 2.1)."
2. **Section 3.4** (`research/sections/rehearsal-core.md`). The citation has no year and could not be resolved before the reference list existed.
   * Sentence: "("Low stakes" is Christiano's term.)"
   * Replacement: "("Low stakes" is the term of Christiano 2021.)"
3. **Section 4.1** (`research/sections/lower-bounds.md`). Finding A7.
   * Sentence: "The mixture's weight on such partners was known (Paper 2, Proposition G.5; Cohen, Hutter, Bengio and Russell 2025); N1 covers every protocol."
   * Replacement: "The mixture's weight on such partners was known (Paper 2 of this repository, Proposition G.5; Theorem 1 of Cohen, Hutter, Bengio and Russell 2025 is a published relative for Bayesian imitators); N1 covers every protocol."
4. **Section 4.2** (`research/sections/lower-bounds.md`). "Dasgupta" has no year.
   * Sentence: "For one call this is the star-number bound of active learning, with the same argument (Hanneke and Yang 2015, Theorem 3, crediting Dasgupta)."
   * Replacement: "For one call this is the star-number bound of active learning, with the same argument (Hanneke and Yang 2015, Theorem 3, crediting Dasgupta 2004, 2005)."
5. **Section 4.3** (`research/sections/lower-bounds.md`). Finding A8.
   * Sentence: "It is the membership-query algorithm of Hegedűs (1995) and Moshkov (1983), as in Bshouty (2017, Lemma 3), with prior weights and with audits of runs."
   * Replacement: "It follows the membership-query algorithm with which Bshouty (2017, Lemma 3) proves the bound of Hegedűs (1995) and Moshkov (1983), with prior weights and with audits of runs."
6. **Section 4.5** (`research/sections/lower-bounds.md`). The method is named without a reference; the proof files give Yu (1997) from memory.
   * Sentence: "**Theorem N6** (proved here by Assouad's method: Theorems 6.1, 6.3 there)."
   * Replacement: "**Theorem N6** (proved here by Assouad's method, for which see Yu 1997: Theorems 6.1, 6.3 there)."
7. **Section 7.3** (`research/sections/shift-abstain.md`). Finding A2.
   * Sentence: "**Proposition Ab3** (proved here; Observation B of the researcher's notes)."
   * Replacement: "**Proposition Ab3** (proved here; first stated as Observation B in this project's digest of the researcher's notes, `research/understand/notes.md`, Section 6.2)."
8. **Section 7.4** (`research/sections/shift-abstain.md`). Finding A1.
   * Sentence: "**Proposition N4** (standard: the example of singletons for learners that may say "I don't know", Li, Littman and Walsh 2008)."
   * Replacement: "**Proposition N4** (standard: the example of singletons, Example 1 of Sayedi, Zadimoghaddam and Blum 2010 as Balsubramani 2015 reports it, in the model of Li, Littman and Walsh 2008 for learners that may say "I don't know")."
9. **Section 8.3** (`research/sections/property-batch.md`). "Yatracos" has no year.
   * Sentence: "**Theorem Pr4** (proved here; minimum-distance estimation after Yatracos)."
   * Replacement: "**Theorem Pr4** (proved here; minimum-distance estimation after Yatracos 1985)."
10. **Section 8.3** (`research/sections/property-batch.md`). "Theorem 19" is the numbering of arXiv version 5 (14 December 2025), which also corrects the proof (its Remark 1); the editor's notes of the section source say so, the note does not.
    * Sentence: "The estimate is the modified minimum-distance estimate of Mahalanabis and Štefankovič (2008), with weights; it attains the factor 3, which is optimal for rules that return a member and whose number of runs does not grow with the space of runs (Bousquet, Kane and Moran 2019, Theorem 19)."
    * Replacement: the same sentence with "(Bousquet, Kane and Moran 2019; Theorem 19 of arXiv version 5)" at its end.
11. **Section 8.7** (`research/sections/property-batch.md`). No year.
    * Sentence: "**Theorem Pr7** (proved here; the observation is Dwork et al.'s)."
    * Replacement: "**Theorem Pr7** (proved here; the observation is that of Dwork et al. 2021)."
12. **Section 8.5** (`research/sections/property-online.md`). The method is named without a reference; the editor's notes of the section source give Le Cam (1973) from memory.
    * Sentence: "For a human who varies, both match frequencies at order 1/√n, which no imitator built from n answers can beat (Proposition 6.7; Le Cam's two-point argument, standard); K ln 2/n is the mixture's rate for the divergence."
    * Replacement: the same sentence with "(Proposition 6.7; Le Cam's two-point argument, standard: Le Cam 1973)".
13. **Section 9.2** (`research/sections/assumptions.md`, block B). Finding A5.
    * Sentence: "Averaged over the prior, a posterior draw per run is exact with no question asked (Proposition 7.7; standard, Thompson 1933): the theorems are about a human who is not typical of the prior, and a rare situation is a bet on the prior."
    * Replacement: "Averaged over the prior, a posterior draw per run is exact with no question asked (Proposition 7.7; this is the defining property of posterior sampling, which goes back to Thompson 1933): the theorems are about a human who is not typical of the prior, and a rare situation is a bet on the prior."
14. **Section 10, test 2** (`research/sections/assumptions.md`, block C). Finding A6.
    * Sentence: "So is the behaviour at inputs met less than about once in n runs: on some machine a deviant answer there has probability at least one half (Paper 1, Proposition 8.2), and R1 holds for both machines."
    * Replacement: "So is the behaviour at inputs met less than about once in n runs: on some machine a deviant answer there has probability at least one half (Paper 1, Proposition 8.2, for the coin-free and the one-tape version; `ultranatural/note.md`, Theorem 3, for every scheme whose only bias is the machine's: a nearby machine exchanges the two answers there), and R1 holds for both machines."
15. **Section 10, first sentence** (`research/sections/assumptions.md`, block C). Finding A3.
    * Sentence: "The tests are those that the researcher's notes apply to any proposal."
    * Replacement: "The tests are seven questions that this project's digest of the researcher's notes (`research/understand/notes.md`, Section 5) derives from his objections to his own schemes."

Not a replacement, but for the same reason: Section 3.4 names the "Azuma–Hoeffding inequality" without a reference (Section 8.4 has "Hoeffding 1963"); the reference list has an entry for Azuma (1967), marked as named. "Paper 2" is used in Section 4.1 without the words "of this repository", which only "Paper 1" carries in Section 3.1; the reference list now resolves both.

## 4. Citations that could not be matched to a source that somebody opened

For each of the following works, nobody in this project read the work itself, in the version cited (this session included, because the work is on no host that could be opened). The count of twenty-five leaves out the row of Batu et al., whose journal version was read. The table says through what the statement is known. "Marked" says whether Sections 0 to 11 of the note tell the reader so.

| work | cited in | the statement rests on | marked in the note |
|---|---|---|---|
| Barron and Cover (1991) | 1, 5.1, 5.2 | Zhang (2006), read | in 5.2 ("as Zhang 2006 reports it"); not in 1 and 5.1 |
| Barron, Schervish and Wasserman (1999) | 5.2 | Zhang (2006, Section 4.4), read | yes ("after") |
| Batu et al. (2000), conference version | 8.7 | the journal version (arXiv:1009.5397), read | no; the versions agree in what is used |
| Blackwell (1956) | 8.5 | Abernethy et al. (2011) and Perchet (2013), read | yes |
| Catoni (1997); Yang (2000) | 5.2 | Juditsky, Rigollet and Tsybakov (2008), read | no |
| Cesa-Bianchi, Lugosi and Stoltz (2005) | 6.2 | digests, from memory; an abstract seen in search results | no |
| Christiano (2021) | 3.4 | search excerpts of the post | no |
| Dasgupta (2004, 2005) | 4.2 | Hanneke and Yang (2015), read | yes ("crediting") |
| Goldreich and Ron (2000) | 8.7 | Batu et al., read | no ("after") |
| Hegedűs (1995); Moshkov (1983) | 4.3 | Bshouty (2017) and Hanneke and Yang (2015), read | yes ("as in Bshouty") |
| Hoeffding (1963) | 8.4 | memory; the inequality is proved in the proof files | "standard" |
| Landauer (1986) | 9.1 | search results | yes ("from secondary sources") |
| Langford (2005) | 8.2 | memory of two verifiers | yes ("quoted from memory") |
| Lehrer (2001); Sandroni, Smorodinsky and Vohra (2003) | 8.5 | Perchet (2013), read | yes |
| Li, Littman and Walsh (2008) | 7.4 | Zhang and Chaudhuri (2016) and Balsubramani (2015), read | no; see finding A1 |
| Littlestone (1988) | 5.1, 8.4, 8.5 | abstracts and memory | in 8.5 ("Littlestone from memory"); not in 5.1 and 8.4 |
| Sayedi, Zadimoghaddam and Blum (2010) | 7.1 | Zhang and Chaudhuri (2016) and Balsubramani (2015), read | no |
| Solomonoff (2008) | 1, 3.1 | Paper 1, read; the paper was read in full for Paper 1 (comment in its bibliography file) | no |
| Spencer (1977) | 8.5 | Bárány (2024), read | yes |
| Thompson (1933) | 9.2 | memory | no; see finding A5 |
| Ville (1939) | 7.2, 9.4 | memory; the inequality is standard | "standard" |
| Yatracos (1985) | 8.3 | Mahalanabis and Štefankovič (2008) and Bousquet, Kane and Moran (2019), read | no ("after") |

Works that the new Section 12 adds and that nobody opened: Solomonoff (1978), through Özkural (2011), read; Jayram (2009), through Foster, Han, Qian and Rakhlin (2024), read; El-Yaniv and Wiener (2010), through Balsubramani (2015), read. Of Plaut, Zhu and Russell (2025) only the abstract was read this session; the digest `ask-for-help.md` read the paper.

Named in the note without a year and opened by nobody: Azuma (1967), Le Cam (1973), Yu (1997, for Assouad's method). All three are from memory in the proof files, and the arguments are written out there.

A suggestion that follows from the table: one sentence in Section 12 or after the status paragraph of the note, such as "Where a work is cited through another, `references.md` says so", would cover the unmarked rows. Section 12 as written leaves this to the first sentence of the reference list.

## 5. Bibliographic data: disagreements, and fields that remain unverified

**Disagreements between files, or between versions of a work, and what the check showed.**

* *Abernethy, Bartlett and Hazan.* `proofs/property-online.md` has the arXiv title ("… low-regret learning …") and the venue from memory; the draft list has the proceedings title. Checked this session: PMLR 19:27–46 with "No-Regret" in the title; arXiv:1011.1936 with "Low-Regret". Both are right for their versions.
* *Luo and Schapire.* The proof file has "adaptive NormalHedge" and "COLT 2015 per memory". Checked: PMLR 40:1286–1304, title "… AdaNormalHedge"; arXiv:1502.05934, title "… Adaptive NormalHedge".
* *Chernov and Vovk.* The proof file has "UAI 2010 per memory". Checked: the PMLR page of a reissue of the proceedings (R8:125–133); a search result gives the original pages as 117–125. The short list gives both.
* *Hébert-Johnson et al.* The arXiv record is titled "Calibration for the (Computationally-Identifiable) Masses"; the proceedings version carries "Multicalibration:" in front (PMLR 80:1939–1948).
* *Hegedűs.* Bshouty's reference list and a search result have "Generalized teaching dimensions"; the reference list of Hanneke and Yang has "dimension". The list follows the first two.
* *Hanneke and Yang.* The note cites 2015; the version that was read is the arXiv version of 2014. The journal data of the second verifier of lower-bounds (JMLR 16(109):3487–3602), which the editor of that part had not verified, were confirmed by a search.
* *Mahalanabis and Štefankovič.* The note cites 2008 (COLT); the version read is arXiv:0712.2869 of December 2007. The conference pages, marked "not verified" in `research/sections/property-batch.md`, are 503–512 according to the reference list of Bousquet, Kane and Moran.
* *Batu et al.* The note cites the conference paper of 2000; the version read is the journal version (arXiv 2010; *Journal of the ACM* 60(1), Article 4, 2013, by a search).
* *Li, Littman and Walsh.* The note cites the conference paper of 2008; both restatements that were read cite the journal version of 2011 (with A. L. Strehl).
* *Bousquet, Kane and Moran.* "Theorem 19" is the numbering of arXiv version 5 of December 2025, not necessarily that of the proceedings of 2019 (item 10 of Section 3).
* *Cohen, Hutter and Nanda.* The first verifier of shift-abstain could not confirm the article number 334; the header of arXiv version 2 gives "23 (2022) 1-30", and a search this session returns 23(334):1–30.
* *Ross, Gordon and Bagnell.* `proofs/assumptions.md` has the pages from memory and quotes Theorem 3.1 and "a footnote"; `proofs/rehearsal-core.md` quotes Theorem 4.1 and "footnote 3". Checked this session: PMLR 15:627–635; both theorems exist as quoted; footnote 3 stands on the page of Theorem 3.1 and speaks of "the same guarantee"; the proof of Theorem 4.1 bounds the average over the iterates, so the footnote applies to it as well. The note's sentence in Section 2 is accurate.
* *Thompson (1933).* Title and pages were from an editor's memory; a search confirms *Biometrika* 25(3/4):285–294.
* *Solomonoff (2008).* The draft list says "not opened in this session"; a comment in the bibliography file of Paper 1 says that the paper was read in full for that project on 15 October 2026. No conflict; `references.md` records both.
* *The example of singletons* (finding A1) is the one disagreement about content.

**Fields that remain unverified.** The pages of Dasgupta (2005). Volume and pages in the NeurIPS proceedings of Foster, Block and Misra (2024), Foster, Han, Qian and Rakhlin (2024), Lee et al. (2022) and Li and Zhang (2025); for these the short list gives the conference and the arXiv number only. The pages of the journal version of Perchet (2013), which a search places in *Journal of Dynamics and Games* 1(2), 2014; the journal version of Bshouty (2017), which one search result places in *Theoretical Computer Science* (2018). The issue numbers of Lehrer (2001) and Spencer (1977). The day of Christiano (2021): "30 April 2021" comes from a search of the author of the draft and was not confirmed by a search this session. The original pages of Chernov and Vovk (2010): from a search result only.

**Entries that the draft list marked as not verified.**

* *Li and Zhang; Foster, Block and Misra* ("venue from the arXiv record; proceedings data not verified"): the arXiv comments were read again ("42 pages, Accepted by NeurIPS 2025"; "NeurIPS 2024"); searches found the conference listings and, for the second, the proceedings file; volume and pages still not verified.
* *Goldwasser et al. (2020)* ("pages not verified"): a search confirmed authors, title and *Advances in Neural Information Processing Systems* 33; it did not return the pages. The work is no longer cited.
* *Chan et al. (2014)* (order of the last two authors): a search confirmed the difference. The arXiv record has G. Valiant before P. Valiant; a record of the SODA proceedings (pp. 1193–1203) has P. Valiant before G. Valiant. No longer cited.
* *Christiano (2016a)*: a search found mirrors of the post, one of which says that it was originally posted on 29 January 2016. *Christiano (2016b)*: not confirmed by a search this session. *Xu (2020)*: a search confirmed author, title and address; not the date. None was opened; none is cited any longer.
* *Christiano (2021)*: see above.

**Works of the draft that the final Section 12 does not cite** (twelve): Chan et al. (2014), Christiano (2016a, 2016b), Cohen and Hutter (2020), Devroye and Lugosi (2001), Dwork et al. (2022), Farina and Perdomo (2026), Goldwasser et al. (2020), Kosoy (2019), Paninski (2008), von Neumann (1956), Xu (2020). They have no entry in `references.md`. If the lead restores a sentence that cites one of them, its entry in the draft list can be taken over. Of these, the abstract and the main safety theorem of Cohen and Hutter (arXiv:2006.08753, Theorem 11 in version 1, "Probably Respecting Precedent") and the abstract of Kosoy (arXiv:1907.08461) were read this session and agree with the draft's entries.

## 6. Li and Zhang (2025): what Appendix A says, and what the note does with it

`research/literature-checks.md` records that the lead had not verified what Appendix A of Li and Zhang says is open, and decides: "The note makes no claim about what that paper leaves open." The draft of Section 12 had such a claim ("Li and Zhang call lower bounds for single-state queries open"). The final Section 12 follows the lead and makes none.

Appendix A was read in full this session, in the PDF of version 3 (13 January 2026). For the lead's use, three sentences of it, verbatim except that the fraction in the second is transcribed:

1. "Analyzing state-wise annotation with first-step mixing remains an open question." (In their terms the committee of this note is an each-step mixture, and one posterior draw per run a first-step mixture over the class, as `research/sections/one-mind.md` notes; R4 is a bound for that case for a deterministic human, with the factor 2L²/(L + 1) in place of L.)
2. "We observe that the proof of [17, Theorem 2.2] also implicitly implies a Ω(H/ε) sample complexity lower bound for the state-wise annotation setting." ([17] is Foster, Block and Misra. Their Theorem 2.2, read this session, has two policies and two self-looping states, rewards in [0, 1] per step and expected loss at least c·H/n. In the units of this note, where a run fails or does not, this is a bound of order 1/δ on the questions: one rare place, no factor L. N2 has L independent places per run, and the factor L. This conversion is this report's reading, not a statement of either paper.)
3. "Nonetheless, obtaining lower bounds for state-wise sample complexity for general MDPs, policy classes, and general recoverability constants remains an open question."

The same appendix says that Ross, Gordon and Bagnell returned "the best policy selected through validation" and that later works used a uniform mixture of the iterates instead; this agrees with Section 2 of the note, which adds, correctly, that their footnote already allows the uniformly chosen iterate. Their footnote 3 says that a one-sample-per-iteration version of another algorithm was analysed earlier in the lecture notes of Agarwal, Jiang, Kakade and Sun (not opened; `proofs/rehearsal-core.md` mentions it; the note does not).

If the lead wishes to use sentences 1 and 3 now that they are verified, two sentences would do, in Section 5.1 after "Proof: … Theorem 2.1": "Li and Zhang (2025, Appendix A) call the analysis of single-state questions with one policy drawn per episode open; R4 is such an analysis for a deterministic human." and in Section 12 after "we did not find that form": "Li and Zhang (2025, Appendix A) state that lower bounds for single-state queries on general systems are open."

## 7. Section 12: what changed against the draft, and what was left out

**Brought in line with the final note.** Labels (H1 and H2 for Theorems A and B; N6, N7, Pr7, S4, S5, L4). Constants (4 and 2.9642, example 2.9639; R2 is no longer restated). The statement on the Hellinger constant is confined to the inequality with H² on the left by "this inequality", and keeps its two caveats.

**Added, as the sections now attribute.** The index of resolvability for the caveat on A2. The uniformly chosen iterate of Ross, Gordon and Bagnell and the recoverable form of R3. The star-number bound behind N2 and its credit to Dasgupta. Protocol AB and the bound of Hegedűs and Moshkov. Assouad's method for N6. The halving gap behind R6(a). H1 as the progressive mixture rule; the open problem of Grünwald and Kotłowski. H2 and R6(c) in the line of Barron and Cover and of Zhang; the failure at λ = 1. S5 as label-efficient prediction. The exact optimum of Zhang and Chaudhuri behind row 3 of Ab4. Pr3 as the Occam's razor bound; the modified minimum-distance estimate; the quantifier of the lower bound of Bousquet, Kane and Moran (a number of samples that does not grow with the domain), which the editor of property-batch asked for. Pr5: Spencer's game, Lee et al., the potentials of expert algorithms without a learning rate, halving. The observation of Dwork et al. behind Pr7.

**Added beyond the sections.** Three sentences place statements that the sections leave without a source.

* *El-Yaniv and Wiener (2010, Theorem 7)*: a rule that is never wrong answers only where all consistent hypotheses agree. The proof files attach this theorem to their own forms of it (`proofs/shift-abstain.md`, Proposition 5.4, on which the forced column of Section 7.4 rests; `proofs/lower-bounds.md`, Corollary 1.7 and Remark 4.5); the note did not cite it. That N4 (Proposition 7.1 there) is the same fact for a learner with questions is this editor's reading of its statement. The theorem was read through Balsubramani's restatement only.
* *Plaut, Zhu and Russell (2025)* as a relative of N7. Only the abstract was read this session; the sentence paraphrases it and names the standing assumption of that paper.
* *Christiano, Shlegeris and Amodei (2018)*, iterated amplification, as the scheme whose step rehearsal is. Read this session. The sentence says "a predictor of a human who answers with the current model's help on subquestions"; in that paper a second model is trained on the composite, which the sentence omits for length.

**Left out of the draft, and why.**

* The mentor literature other than Plaut et al. (Cohen and Hutter 2020; Kosoy 2019), PQ-learning (Goldwasser et al. 2020), von Neumann (1956): for length; no statement of the note rests on them.
* HCH and the argument that the universal prior is malign (Christiano 2016a, 2016b; Xu 2020): three posts that nobody could open; the draft itself did not quote them. The sentence "It … is the reason to treat unfaithful calls as adversarial, as Theorem R3 does" is thereby gone; R3's definition stands without it.
* "Theorem R3 is this claim [of Christiano 2021] for the Bayes mixture, and Theorem N2 its high-stakes counterpart": the post was not opened, so the note should not say what it claims beyond the term.
* The testing lower bounds (Paninski 2008; Chan et al. 2014) and the sentence that validation "certifies tests and not total variation is forced": Pr7 now states this with its quantifier and a direct construction, and the editor of property-batch asked that the old sentence not stand without it.
* Farina and Perdomo (2026), Dwork et al. (2022), Devroye and Lugosi (2001), and the bound of Cohen, Hutter and Nanda on cubed query probabilities: for length. The last is stated in Section 7.2.
* Lehrer (2001) and Sandroni, Smorodinsky and Vohra (2003), and the collision statistic (Goldreich and Ron; Batu et al.): Sections 8.5 and 8.7 attribute them fully; Section 12 does not repeat them. `research/outline.md`, Addendum 2, item 6, lists Sandroni et al. among the attributions to get right; Section 8.5 has it right ("asymptotic and its rules see the forecast").
* Any claim about what Li and Zhang leave open (Section 6 above).

**"We did not find": the basis of each.** (i) A constant below 7 for the subadditivity of H²: web searches of the prover and both verifiers of hellinger-runs, not exhaustive; Lemma 11.5.3 of Duchi's lecture notes and a course note "Chain rule for squared Hellinger distance (following T. S. Jayram)" were opened by nobody, nor was Jayram (2009). This session two searches added nothing that decides the matter: the record of Kabanov, Liptser and Shiryaev (*Probability Theory and Related Fields* 71:19–35, 1986) confirms that the paper bounds the variation distance from above and below by the Hellinger process, without the constants, so Section 12 does not relate L4(b) to it, as the editor of hellinger-runs advised; and Daskalakis and Pan (arXiv:1612.03164, abstract read) prove a subadditivity of H² for Bayesian networks in terms of marginals on a node and its parents, which "does not involve the conditionals" and is a different inequality. (ii) N2 with L critical calls: the search of the author of the draft, and Section 6 above. (iii) The exponential bound of H2 with its free exponent, and the comparison of the per-call mixture with one posterior draw per run: `proofs/hellinger-runs.md`, Section 5.4, items 2 and 6. (iv) Pr4 with weights: the prover of property-batch (`proofs/property-batch.md`, Section 3.6). (v) Pr5 for a deterministic rule and countably many weighted tests of pairs: the digest `indistinguishability.md`, the prover and the second verifier of property-online. For all other statements Section 12 says that no systematic search was made. `proofs/assumptions.md`, Section 11, lists further statements that its second verifier believes are not in the literature "in this form"; Section 12 does not repeat that, because no search stands behind it.

**Two points for the lead about the reference list.**

* The list has an entry for the researcher's notes, in the form in which Paper 1 cites them, because the note cites them three times. If the note is to refer to them only as "the researcher's notes", the entry can be reduced to the pointer to the digest.
* Three entries are marked as named only (Azuma, Le Cam, Yu). They are in the list so that a reader who meets "Assouad's method" or "Le Cam's two-point argument" finds a reference; items 6 and 12 of Section 3 would turn two of them into ordinary citations.

## 8. What was read in this session

**arXiv, in the PDF text, at the places cited** (version in brackets): Li and Zhang (2412.07057v3: Algorithm 1, Assumption 1, Section 3.1, Theorem 3 with the sketch of its proof, Appendix A, Lemma 11); Foster, Block and Misra (2407.15007v2: Proposition 2.1, Theorem 2.2 with the start of its proof, Theorem G.1 with its construction); Foster, Han, Qian and Rakhlin (2404.10122v1: Lemma D.2 and the start of its proof); Foster, Kakade, Qian and Rakhlin (2112.13487v3: Lemmas A.13, A.14); Ross, Gordon and Bagnell (1011.0686v3: Theorems 2.1, 2.2, 3.1, 4.1, Algorithm 3.1, footnote 3); Hutter (cs/0301014v1: Theorem 1(i)); Cohen, Hutter, Bengio and Russell (2410.06213v1: Theorem 1); Cohen, Hutter and Nanda (2102.08686v2: Theorems 1, 2, 5); Hanneke and Yang (1410.0996v1: Definition 2, Theorem 3, two passages of Appendix B.1); Bshouty (1706.03935v1: Lemma 3 with proof); Zhang (math/0702653v1: Theorem 4.1, Sections 4.3 and 4.4 in part, Theorem 5.1); Juditsky, Rigollet and Tsybakov (math/0511468v4: Corollary 5.4 and the sentence after it); Zhang and Chaudhuri (1604.06162v3: introduction, model, Corollary 1, Theorem 5, Section 6); Dwork et al. (2011.13426v1: five passages); Bousquet, Kane and Moran (1902.05876v5: Theorems 1 and 19, Remark 1); Mahalanabis and Štefankovič (0712.2869v1: Theorems 2 to 4); Balsubramani (1512.08133v1: Sections 2.1.2 and 2.3.1, Algorithm 3, Proposition 3.2); Gupta et al. (2101.01739v1: Theorem 3.2); Vovk, Takemura and Shafer (cs/0505083v1: Theorem 1 with protocol and proof); Lee et al. (2108.03837v3: Theorem 2.1); Chernov and Vovk (1006.0475v1: Theorem 9); Luo and Schapire (1502.05934v1: potential, weights, Theorem 1); Perchet (1301.2663v1: Theorem 3.2, Proposition 3.2 and the text between); Bárány (2412.08238v1: start of Section 1); Abernethy, Bartlett and Hazan (1011.1936v1: Theorem 3 and the paragraph after it); Batu et al. (1009.5397v2: a passage of Section 1.1); Hébert-Johnson et al. (1711.08513v2: Theorem 2); Christiano, Shlegeris and Amodei (1810.08575v1: abstract, Sections 1.1 and 2 in part, the list of simplifications); Özkural (1107.2788, latest version: equation (2)); Plaut, Zhu and Russell (2402.08062v6: abstract only); and, for works that are no longer cited, Cohen and Hutter (2006.08753v1: abstract, Theorem 11) and Kosoy (1907.08461v1: abstract).

**proceedings.mlr.press, in the PDF text:** Ross and Bagnell (2010): Theorem 2.1 and the remark on tightness. Grünwald and Kotłowski (2011): the whole paper.

**Records:** the arXiv abstract pages of 51 papers (title, authors, comment, versions, journal reference); the index pages of PMLR volumes 9, 15, 19, 40, 49, 80, 99, 125, 167, 267, 286 and R5 and the page of one paper of R8.

**This repository and the researcher's notes:** Paper 1 (PDF text: Theorem 5.3, Proposition 5.7 with the remark after it, Propositions 8.1, 8.2, 8.5); Paper 2 (PDF text: Proposition G.5 with proof and the paragraph before it); `ultranatural/note.md` (Theorem 3, Section 5); the digest `research/understand/notes.md` (Sections 0, 5, 6.2 and item Q5); the local copy of the researcher's notes (the PDF note on Solomonoff function induction, Section 3; a search of all 971 text files and 29 PDF files for "Observation A" and "Observation B").

**Searches:** 40 web searches for bibliographic data and abstracts. A search result is a summary made by the search tool; where an entry rests on one, `references.md` says "search".

## 9. Not done

* No mathematics of the note was checked.
* The works of Section 4 were not opened; their hosts could not be reached.
* The digests' accounts of sources were taken over, not compared with the sources, except where Section 8 names the source.
* Of the passages that others read, only those named in Section 8 were read again. In particular Theorem 5 of Cohen, Hutter and Nanda was read only in its statement, the proofs of the cited lemmas were not read, and Lemma 1 of Abernethy et al. was read only in its statement.
* The section sources changed while this report was written (`rehearsal-core.md` at 03:52, `hellinger-runs.md` at 03:54). A comparison of a fresh assembly with `note.md` showed no new citation in them. The sentence quoted in item 2 of Section 3 was still present in the source at that time. Later changes were not seen.
* Whether the open problem of Grünwald and Kotłowski has been solved was checked by one web search only (no solution found for a countable model; two later papers seen in abstract only: arXiv:1912.10784, arXiv:2511.12718). The revised source of Section 5.2 now says "we found no published solution"; that agrees with this search, and this report knows of no other search behind it.

STATUS: COMPLETE.
