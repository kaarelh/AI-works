# Bibliography check log, Paper 2 (2026-10-12)

Scope: every entry of `paper-steeper/bib/*.bib` (42 entries in `bib/all.bib`; 37 are cited and printed in `main.bbl`, 5 are not cited and not printed).
Method: WebSearch by this reviewer (21 searches, listed as "WS"), one WebFetch of the public GitHub notes repository, `gh api` for the public AI-works repository, local copies. The session's shared WebSearch budget ran out after 21 searches; for the entries marked "WS-P1" the same-day WebSearch log of the Paper 1 arXiv review (`../p1-arxiv/bibcheck-log.md`) is used; for entries marked "writer" only the writer's own search record (comments in `bib/steep-a.bib`, `bib/steep-b.bib`) and the reviewer's own knowledge are available, and the entry must be re-checked by search before submission. arxiv.org, kaarelh.github.io, lesswrong.com and greaterwrong.com do not resolve from this environment.

Format: key | printed? | verdict | evidence | action

## Verified by this reviewer's WebSearch
hoeffding1963probability | yes | VERIFIED, fixable | WS: JASA 58(301):13-30, 1963, doi 10.1080/01621459.1963.10500830 | add number = {301}, doi
sion1958general | yes | VERIFIED | WS: Pacific J. Math. 8(1):171-176, 1958, doi 10.2140/pjm.1958.8.171 | optional doi
barron1991minimum | yes | VERIFIED (bibliographic) | WS: IEEE TIT 37(4):1034-1054, July 1991; correction notice Nov. 1991 (eq. 1.3) | bibliographic data fine; the claim it supports ("complexity weight above one ... reported to appear") is NOT verified: see issue P2X-17
gacs2001algorithmic | yes | VERIFIED | WS: IEEE TIT 47(6):2443-2463, Sept. 2001; arXiv math/0006233 | none
vereshchagin2004kolmogorov | yes | VERIFIED | WS: IEEE TIT 50(12):3265-3290, Dec. 2004, doi 10.1109/TIT.2004.838346; arXiv cs/0204037 | none
vereshchagin2010rate | yes | VERIFIED | WS: IEEE TIT 56(7):3438-3454, July 2010, doi 10.1109/TIT.2010.2048491; arXiv cs/0411014; abstract: distortion balls, Hamming distortion, denoising | none (content claim in rem:algstat:restricted matches the abstract; full text open on arXiv/CWI)
vereshchagin2017algorithmic | yes | VERIFIED | WS: LNCS 10010, 669-737, Springer 2017; arXiv 1607.08077 | none (open access: the set/distribution equivalence can be checked in the full text)
grunwald2007minimum | yes | VERIFIED (bibliographic) | WS: MIT Press, June 2007, ISBN 978-0-262-07281-6 | none; content for "weight above one" not found by search
gneiting2007strictly | yes | VERIFIED | WS: JASA 102(477):359-378, 2007, doi 10.1198/016214506000001437; abstract defines strict propriety as in prop:limits:noident(i) | none
grunwald2012safe | yes | VERIFIED | WS: ALT 2012, LNCS 7568, 169-183, doi 10.1007/978-3-642-34106-9_16; author copy at homepages.cwi.nl/~pdg/ftp/alt12longer.pdf (abstract: learning rate chosen by randomized sequential prediction loss) | add doi
grunwald2017inconsistency | yes | VERIFIED | WS: Bayesian Anal. 12(4):1069-1103, 2017, doi 10.1214/17-BA1085; arXiv 1412.3730 | add doi
zhang2006epsilon | yes | VERIFIED | WS: Ann. Statist. 34(5):2180-2210, 2006, doi 10.1214/009053606000000704; arXiv math/0702653 | add doi
bissiri2016general | yes | VERIFIED | WS: JRSS-B 78(5):1103-1130, 2016, doi 10.1111/rssb.12158 | add doi
bhattacharya2019fractional | yes | VERIFIED | WS: Ann. Statist. 47(1):39-66, Feb. 2019, doi 10.1214/18-AOS1712 | add doi
li2008introduction | yes | VERIFIED | WS: Springer, New York, 3rd ed., 2008, Texts in Computer Science, doi 10.1007/978-0-387-49820-1 | optional series
solomonoff1978complexity | yes | VERIFIED (bibliographic) | WS: IEEE TIT IT-24(4):422-432, July 1978 | none
poland2005asymptotics | yes | VERIFIED | WS: IEEE TIT 51(11):3780-3795, Nov. 2005, doi 10.1109/TIT.2005.856956; erratum 52(3):1279, 2006; abstract: MDL bounds exponentially worse than Bayes | none (rem:absorb:reading's use matches the abstract)
kakutani1948equivalence | yes | VERIFIED | WS: Ann. of Math. 49(1):214-224, 1948, doi 10.2307/1969123 | none
ville1939etude | yes | VERIFIED, fixable | WS: Monographies des Probabilités, fascicule III (ed. É. Borel), Gauthier-Villars, Paris, 1939, 144 pp. (Math. Gazette and AMS Bull. reviews); also Numdam thesis record THESE_1939__218__1_0 (124 pp.) | add series = {Monographies des Probabilit\'es}, number = {3}

## Verified by the public source itself
hanni2026notes | yes (15 citations) | VERIFIED as a source, UNFIT as printed | WebFetch github.com/kaarelh/notes: public repository "some of my notes from 2023-2026"; file `philosophy/philosophy of thinking/beating solomonoff induction at grokking a notion.md` exists and contains the quoted phrases "an even stronger simplicity prior than solomonoff", "messy notes", "predicts $100$ bits per specification bit"; the "computably samplable" quotes are in `ai/learning/solomonoff induction/solomonoff function induction.md` (local clone, commit 541b175, 17 June 2026) | REPLACE by two entries with the note titles, file paths, commit or access date: (a) "Beating Solomonoff induction at grokking a notion", (b) "Solomonoff function induction"; drop the title "notes"
claude2026whatfollows | yes (10 citations) | VERIFIED as a source, FIXABLE | `gh api`: kaarelh/AI-works is public; folder `inferential-learning/` (README, paper, code, research) is on main; its title page reads "What Follows from What: Learning Inference Rules from Imitation, Coherence, and the World", author "Claude (Anthropic)", "Draft; authorship and publication to be decided by him"; the cited section is \section{Simplicity and normativity from imitation} (sections/simplicity.tex) | give the URL https://github.com/kaarelh/AI-works/tree/main/inferential-learning, the section number, a date; drop "prepared for K. Hänni"; settle the author line consistently with the report's own title page

## Verified by the Paper 1 review's same-day WebSearch (WS-P1); not re-searched here
grunwald2007suboptimal | yes | VERIFIED, fixable | WS-P1: Machine Learning 66(2-3):119-149, 2007, doi 10.1007/s10994-007-0716-7 | add number = {2--3}, doi
zhu2025quantifying | yes | VERIFIED | WS-P1: COLT 2025, PMLR 291:6124-6155 | none (content must be checked against the full text: issue P2X-15)
zhu2026overfitting | yes | VERIFIED | WS-P1: arXiv:2603.22644 (23 Mar 2026), Zhu, Ohannessian, Srebro | none (content: issue P2X-15)
vaintrobhanni2026nnbayes | yes | VERIFIED against the local copy only | WS-P1: title slide of research/prior/vaintrob-hanni-nnbayes-generalization-slides.pdf; URL kaarelh.github.io/ai/nnbayes-generalization.pdf not found by search and does not resolve here | check the URL in a browser before submission
littlestone1988learning | no | VERIFIED (WS-P1) | Mach. Learn. 2(4):285-318 | not printed
barzdin1972prediction | no | FIXABLE (WS-P1) | Soviet Math. Dokl. 13:1224-1228 | not printed
gold1967language | no | VERIFIED (WS-P1) | Inf. Control 10(5):447-474 | not printed
vovk2005algorithmic | no | VERIFIED (WS-P1) | Springer 2005, doi 10.1007/b106715 | not printed

## Writer's search record only (search budget exhausted); re-check before submission
koppel1987complexity | yes | writer: Complex Systems 1(6):1087-1091 (journal page, Crossref) | data agree with the reviewer's knowledge | re-check
koppel1991almost | yes | writer: Inform. Sci. 56(1):23-33, doi 10.1016/0020-0255(91)90021-L | agrees with reviewer's knowledge (issue numbering 1-3 in some records) | re-check
vitanyi2006meaningful | yes | writer: IEEE TIT 52(10):4617-4626, doi 10.1109/TIT.2006.881729; arXiv cs/0111053 | agrees with reviewer's knowledge | re-check
antunes2009sophistication | yes | writer: Theory Comput. Syst. 45(1):150-161, doi 10.1007/s00224-007-9095-5 | agrees with reviewer's knowledge | re-check
milovanov2016algorithmic | yes | writer: CSR 2016, LNCS 9691, 280-293; arXiv 1512.04510. NOTE: the steeper source (notes-final §bibliography) says "exact title and pages unverified" | conflict between the source and the bib comment | re-check title and pages
cover2006elements | yes | writer: Wiley-Interscience, 2nd ed., 2006, ISBN 978-0-471-24195-9 | standard | re-check (low risk)
goldreich1989hard | yes | writer: STOC 1989, 25-32, doi 10.1145/73007.73010 | standard | re-check (low risk)
kushilevitz1993learning | yes | writer: SIAM J. Comput. 22(6), doi 10.1137/0222080; pages 1331-1348 "taken from the sibling project; the SIAM snippet did not show the pages" | pages agree with the reviewer's knowledge | confirm pages
wenzel2020good | yes | writer: ICML 2020, PMLR 119:10248-10259, arXiv 2002.02405 | agrees with reviewer's knowledge | re-check

## Unverifiable as printed
hanni2026lesswrong | yes (16 citations) | UNVERIFIABLE; VIOLATES the binding note | lesswrong.com and greaterwrong.com do not resolve; WebSearch did not find the thread or "Jonas Hallgren's Shortform"; printed as "Kaarel Hänni and Cole Wyeth ... undated ... Text as pasted by K. Hänni" and in the text as "(Hänni and Wyeth, undated)" 16 times | DROP the entry; cite the grokking note for every quotation that it also contains; restate the three LessWrong-only remarks in the author's voice; if the one permitted footnote cites the thread, use a new entry with Hänni as sole author, the comment's actual date and URL, checked by the author
hanni2026request | yes (6 citations) | UNVERIFIABLE; not a citable source | a private message from the sole author to the AI system, printed as "Personal communication to the author ... quoted verbatim in .../research/00-brief.md" | DROP; pose the sampler question in the author's voice; credit Eisenstat's example as "(S. Eisenstat, personal communication)" and via Paper 1
claudeSFI2026fundamentals | yes (22 citations) | NOT YET PUBLIC | `gh api .../contents/solomonoff-function-induction?ref=main` returns 404: the folder is not on main | replace by the arXiv identifier at submission, or publish to main first and cite a tagged URL
claudeSFI2026steeper | no | not printed | self-reference | none
