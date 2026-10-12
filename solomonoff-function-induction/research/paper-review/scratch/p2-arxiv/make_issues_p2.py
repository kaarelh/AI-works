"""Issue list of the Paper 2 consistency and arXiv-readiness review. Writes the JSON array
(id, file, label_or_line, severity, problem, evidence, fix) and a markdown rendering.
Usage: python3 -I make_issues_p2.py <out.json> <out.md>"""
import json, sys

I = []
def add(file, where, sev, problem, evidence, fix):
    I.append(dict(id='', file=file, label_or_line=where, severity=sev, problem=problem, evidence=evidence, fix=fix))

# ---------------------------------------------------------------- fatal
add('sections/intro.tex', 'tab:intro:claims, row 3 (line 31)', 'fatal',
    'The verdict on the claim "the good model could be a vertex of the convex hull" says "refuted for some error rules with the same density and description length". Nothing in the paper refutes that the good model is a vertex for such rules; what is proved is weaker.',
    'Prop. 5.3 (prop:limits:envelope) shows, for the j=13 rule, that no program fitting no better than the good model is near-optimal for c < c_env, i.e. on 31% (kappa=0, illustration) or 25% (kappa=30) of the window\'s logarithmic width. limits.tex:44 says "above c_env nothing is proved for it". The source verdict (steeper notes-final §5) and CLAIMS.md §3 R6 both read "refuted as a statement about every error rule with that density and description length", a universal statement. "Refuted for some error rules" moves the quantifier and asserts, for those rules, that the good model cannot be a vertex, which is open for c in [c_env, c_hi].',
    'Replace the verdict by: "Confirmed for error rules incompressible relative to the model. It does not extend to every rule with the same density and description length: for one such rule, no hypothesis that fits no better than the good model is near-optimal on about a quarter to a third of the window\'s logarithmic width; the rest of the window is open." Keep the "Where" column.')

# ---------------------------------------------------------------- major
add('bib/core.bib', 'hanni2026lesswrong (lines 26-34); 15 \\citep sites: intro.tex:10,12(x2),43,48; setup.tex:48,61,64; absorb.tex:5 (footnote),104; teacher.tex:11,16; limits.tex:21,44; discussion.tex:9', 'major',
    'Wyeth is named 16 times in the arXiv-mode PDF: the entry lists "Hänni, Kaarel and Wyeth, Cole" as authors, so every citation of Hänni\'s own comments prints "(Hänni and Wyeth, undated)", and the reference list prints "Kaarel Hänni and Cole Wyeth". The Section 3 footnote "It was also raised in the comment thread in which the proposal was discussed (Hänni and Wyeth, undated)" thereby names Wyeth as a source of the absorption point, and 14 quotations of Hänni\'s words are attributed jointly to Wyeth. The entry is also unverifiable as printed: year "undated", note "Text as pasted by K. Hänni on 11 October 2026" (process vocabulary in the references).',
    'pdftotext of an arXiv-mode build (\\sfirecordfalse, \\status/\\src emptied; scratch/p2-arxiv/build-norecord) contains "Wyeth" 16 times, on pp. 3 (3), 5 (2), 7, 8 (2), 9, 12, 13 (2), 19, 20, 31 and 33 (reference list); the current 63-page PDF has 17 (one more in App. H.6). Binding note (OUTLINE.md, CLAIMS.md): the absorption objection must not be attributed to or named after Wyeth, Wyeth must not be quoted, and at most one neutral footnote may record that the point was raised in the thread. All quoted thread passages are Hänni\'s (research/prior/hanni-lesswrong-comment-thread.md), so the joint attribution is also factually wrong. All but five of them also occur in the "messy notes" of the author\'s public note "beating solomonoff induction at grokking a notion" (research/prior/hanni-grokking-a-notion.md, lines 37-70); the five thread-only passages are at intro.tex:12 ("cherry-picked"), teacher.tex:14 (Version 2 wording), limits.tex:44 and discussion.tex:9 (two).',
    '(1) Cite every quotation that occurs in the grokking note to that note (see the hanni2026notes issue). (2) Make the LessWrong entry single-author and dated: author = {H{\\"a}nni, Kaarel}, title = {Comment on ``Jonas Hallgren\'s Shortform\'\'}, howpublished = {LessWrong, <URL>}, with the comment\'s date supplied by the author; delete "Text as pasted ..."; cite it only for the five thread-only passages. (3) Keep the absorb.tex:5 footnote neutral, e.g. "The point was also raised in the online discussion of the proposal \\citep{...}", or delete it. (4) Rebuild and check that pdftotext output contains no "Wyeth".')

add('bib/core.bib', 'hanni2026request (lines 19-25); cited intro.tex:12,43,48; split.tex:5,55', 'major',
    'The sole author cites a "Personal communication to the author" from himself, titled "Request for a paper on Solomonoff function induction", whose howpublished field points to a process file (solomonoff-function-induction/research/00-brief.md) and whose note mentions "Hänni\'s e-mail argument". This prints process vocabulary in the references and gives readers a citation they cannot use.',
    'Reference list of the arXiv-mode build: "Kaarel Hänni. Request for a paper on Solomonoff function induction. Personal communication to the author, 11 October 2026; quoted verbatim in solomonoff-function-induction/research/00-brief.md in the accompanying repository, 2026c. Includes Sam Eisenstat\'s example and Hänni\'s e-mail argument about it." Uses: the sampler/fill-in quotation (intro.tex:12, split.tex:5, quoted from 00-brief.md line 23), Table 1 caption, the credits paragraph and the Eisenstat example (intro.tex:48, split.tex:55). Binding note: no process vocabulary; Eisenstat credited in text and acknowledgements.',
    'Delete the entry. State the sampler/fill-in question as the author\'s own, without quotation marks (e.g. "A second question, which motivated this work, is whether a steeper prior prefers a simple sampler to programs that fill in its sampled bits; at lambda=1 Solomonoff induction has no such preference"), or cite a public note if one contains it (the request says such a note may exist in github.com/kaarelh/notes). Credit the coin example as "S. Eisenstat, personal communication" plus the companion paper\'s treatment of it. Remove the key from the Table 1 caption and the credits paragraph.')

add('bib/core.bib', 'hanni2026notes (lines 3-9); about 30 quotations in intro, setup, absorb, teacher, algstat', 'major',
    'The entry prints "Kaarel Hänni. notes. Public repository of working notes, https://github.com/kaarelh/notes, 2026b. Accessed October 2026." The title is the word "notes", and nothing tells the reader which of the repository\'s notes contains the roughly 30 quoted passages, so the quotations cannot be checked.',
    'Quote check (scratch/p2-arxiv/quote_check.py): the quotations come from two notes, "beating solomonoff induction at grokking a notion" (research/prior/hanni-grokking-a-notion.md; most quotations) and the SFI note ("computably samplable", "use different bits of randomness from the universal semimeasure\'s infinite read tape ...", research/prior/hanni-sfi-notes.md). The Paper 1 reviewer confirmed today that github.com/kaarelh/notes exists and located the SFI note (ai/learning/solomonoff induction/).',
    'Split into one entry per note, each with the note\'s title, its path or URL in the repository, a date or commit hash, and "Working note": e.g. hanni2026grokking "Beating Solomonoff induction at grokking a notion" and hanni2025sfi "Solomonoff function induction". Re-point every \\citep{hanni2026notes} to the note it quotes.')

add('sections/discussion.tex', 'Code and data (lines 32-33); bib/core.bib claudeSFI2026fundamentals; main.tex:17 footnote', 'major',
    'The code-and-data statement and the companion-paper citation point to folders that are not on the public branch: "solomonoff-function-induction/research/tracks/steeper/ of the repository https://github.com/kaarelh/AI-works" and "Folder solomonoff-function-induction/paper/ ... Draft". A reader following either link today finds nothing. The path also exposes the internal word "tracks", and the notes it points to (tracks/steeper/notes-final.md, §0 and §1.8 "Answer to Wyeth\'s objection") name and quote Wyeth.',
    '`git ls-tree --name-only origin/main` lists no solomonoff-function-induction folder (the repository is public: GitHub API returns private=false). CLAUDE.md: projects are published to main at milestones. The record (App. H.3) gives the exact environment (Python 3.11.15, NumPy 2.4.6, SciPy 1.17.1), which the arXiv version would lose.',
    'Before submission: publish the project to main per CLAUDE.md; cite a tag or commit hash (or a Zenodo DOI) instead of the moving main branch; submit Paper 1 first and cite its arXiv identifier in claudeSFI2026fundamentals; move the exact package versions into the code-and-data statement. Decide whether the link should expose the research notes (which name Wyeth) or only the scripts and their outputs; if the notes are linked, the author may want their §1.8 heading renamed.')

add('sections/intro.tex', 'line 46 (Prior work); setup.tex:48; algstat.tex:48,82; related.tex:35,39,47,51; discussion.tex:26 (open problem 8), 30 (acknowledgements)', 'major',
    'The comparison with prior work rests, by the paper\'s own account, on abstracts and search snippets: "Our literature search went only as far as abstracts", "As their abstracts describe them" (twice), "As far as we can tell from the abstracts", "though our search was limited to abstracts", "This is our reading, not checked against the papers\' precise criteria", "presumably that translation", "are reported to appear", and an open problem that is a reading task ("The novelty claims ... need a comparison with the full texts"). The novelty claims of Remark 8.8 depend on this. The introduction also states without hedge what Section 2 hedges ("Two-part codes with a complexity weight above one appear in MDL theory" vs "are reported to appear").',
    'Visible in the arXiv-mode build at the listed lines. App. H.6 (to be removed) records that Zhu-Srebro 2025, Zhu-Ohannessian-Srebro 2026, Grünwald-Langford 2007, Vereshchagin-Vitanyi 2010, Milovanov 2016, the set-distribution equivalence of Vereshchagin-Shen 2017, Wenzel et al. 2020 and Poland-Hutter 2005 were checked against abstracts or snippets only, and that the weight-above-one claim for Barron-Cover 1991 rests on a secondary source. All of these papers are openly available (arXiv 2503.02110, 2603.22644, math/0406221, 1512.04510, 2002.02405, cs/0506022, and the IEEE/Springer versions).',
    'Before submission, read the listed papers and Grünwald (2007) on two-part MDL with complexity weight above one; replace each hedge by a precise statement with a theorem or section pointer; delete open problem (8), the last sentence of related.tex:51 and the clause "and the comparison with the literature rests on abstracts and search snippets" in the acknowledgements. If the reading is not done, keep one standard hedge ("to our knowledge") in the related-work section and the honest disclosure in the acknowledgements, and make the introduction match the hedged wording of Section 2.')

add('main.tex + preamble.tex + sections/*.tex + bib/*.bib', 'main.tex:5-13; preamble.tex:31-40; header comments of every section file; all \\status/\\src calls; label rem:absorb:wyeth (absorb.tex:5,101; intro.tex:16); sections/app-verification.tex', 'major',
    'arXiv distributes the LaTeX source. Setting \\sfirecordfalse and redefining \\status and \\src as no-ops hides them only in the PDF; the uploaded source would still contain the internal record (app-verification.tex), the \\src arguments ("referee r3, q2(c)", "check c7(B)", "steeper Prop 2.17"), comments such as "% Section 3 (writer: steep-a). Source: research/tracks/steeper/notes-final.md", "% Binding: the absorption objection is a standard point; do not attribute it to a person", the main.tex block on the "internal verification record", bib comments ("% unverified: ... as pasted by Hänni"), and the label rem:absorb:wyeth.',
    'Scratch build with \\sfirecordfalse and empty \\status/\\src (scratch/p2-arxiv/build-norecord): 58 pages, 0 LaTeX errors, 0 undefined references or citations, so the switch itself works and nothing outside App. H references app:verification. But the sources still carry the material listed. The binding note permits invisible labels such as rem:absorb:wyeth, but on arXiv the source is visible.',
    'In the arXiv tarball: delete every \\status{...} and \\src{...} call with a brace-aware script, delete their definitions and the comment block in preamble.tex, strip all % comments (e.g. arxiv_latex_cleaner), delete the \\newif/\\sfirecord lines and the \\ifsfirecord\\input line from main.tex, omit sections/app-verification.tex, rename rem:absorb:wyeth to rem:absorb:answer, and upload main.bbl instead of the .bib files. Then grep the tarball for "track|referee|ledger|notes-final|steep-a|steep-b|writer|framing|binding|Wyeth|status|src{" and expect no hits.')

add('sections/abstract.tex', 'line 3, sentence "For a random parity ... little probability."', 'major',
    'The abstract says that "for lambda=cn, with c in an explicit window, every near-optimal private-randomness hypothesis knows the parity and gives the erroneous labels little probability", without saying that this is a statement about the population objective. The finite-sample version needs about 10^11 samples at the example\'s sizes. "Little probability" means an average of up to 0.2-0.29 at the example\'s sizes, against 2^-10 for the good model. n is not defined in the abstract.',
    'teacher.tex:34: "The objective is the population objective J_c; finite samples are treated in Cor. 4.11." App. C.5 table: excess 9.2 bits at n=10^11, 92.5 bits at 10^9. Table 2: e <= 0.199 (kappa=0, delta_S=0) to 0.287 (kappa=30, delta_S=20); teacher.tex:108: the good model has e=2^-10. intro.tex:48 states the 10^11 caveat, but the abstract does not.',
    'Rewrite as, e.g.: "For a random parity with a systematic error rule incompressible relative to it, we prove that for the population objective with weight c=lambda/n per sample (n the sample size) and c in an explicit window, every near-optimal private-randomness hypothesis knows the parity, holds little information about the error rule and gives the erroneous labels bounded average probability (about 0.2 at the original sizes, against 1 for a memoriser); finite-sample guarantees need very large n." Trim elsewhere to stay within 200 words.')

add('sections/abstract.tex', 'line 3 (last sentence); intro.tex:19; intro.tex:38 (Table 1, row 10); split.tex:5', 'major',
    'Missing hypothesis. "For lambda>1 the sampler wins with private but not with shared randomness", "with shared randomness, and in SI, the universal mixture wins" and "the universal mixture wins instead and no split is made" are stated for all samplers. Theorem 6.8 excludes the sampler program only when (lambda-1)k > lambda*l_U + kappa_0, i.e. for samplers longer than l*_lambda.',
    'split.tex:89, Thm 6.8(i): "if (lambda-1)k > lambda*l_U + kappa_0, then J_lambda(pi_U;o) < J_lambda(pi_nu;o): the sampler program is never a lambda-MAP". Part (ii) bounds the posterior mass of long programs only. A sampler with k <= l*_lambda is not excluded.',
    'Add the condition where the result is summarised: "with shared randomness, and in SI, the universal mixture beats every sampler longer than l*_lambda=(lambda*l_U+kappa_0)/(lambda-1)". In the abstract: "... for lambda>1 the sampler wins with private randomness, while with shared randomness a fixed universal mixture beats every sufficiently long sampler."')

add('sections/discussion.tex', 'line 9 (The gap to realistic errors)', 'major',
    '"Human labelling errors are often cheap, frequent patterns rather than incompressible sets, and for such errors the trick provably fails" drops the hypotheses of the cited results and rests on an uncited empirical premise.',
    'Rate blindness (Prop. 5.4 with Lemma 5.5) gives failure for a fixed cheap rule only once d >= d_0(kappa) (e.g. d_0 = 450 at kappa=0 and 1005 at kappa=30 for a single 6-bit prefix). The envelope result (Prop. 5.3) gives failure only for c < c_env, about a quarter to a third of the window, and limits.tex:44 says nothing is proved above c_env. No source is given for the claim about human labelling errors.',
    'Rewrite: "If, as seems plausible, many human labelling errors are cheap and frequent rather than incompressible, the guarantee does not cover them: a fixed cheap rule defeats every c once the simple model is long enough (Prop. 5.4, Lemma 5.5), and a rule with a cheap dense part defeats a substantial part of the window (Prop. 5.3)."')

add('sections/abstract.tex', 'line 3 ("it needs lambda proportional to n and fails for some compressible error rules ..."); intro.tex:18', 'major',
    'Two summaries of the envelope result overstate it. In the abstract, "it ... fails for some compressible error rules of the same density and description length" (with "it" = the window) reads as "no window exists". The introduction says "on almost a third of the window\'s logarithmic width", which is the kappa=0 figure (31%). The paper calls kappa=0 numbers illustrations, and the kappa=30 figure is 25%.',
    'limits.tex:42: "31% of the logarithmic width ... at kappa=0 (25% at kappa=30)"; limits.tex:44: "above c_env nothing is proved for it"; intro.tex:48 and teacher.tex:108: kappa=0 rows are illustrations.',
    'Abstract: "... and, for some compressible error rules of the same density and description length, it fails on a substantial part of the window." Introduction: "on about a quarter (kappa=30) to a third (kappa=0) of the window\'s logarithmic width".')

add('sections/limits.tex; sections/teacher.tex', 'prop:limits:plain(a) (limits.tex:12); cor:teacher:fulltable (teacher.tex:155); prop:limits:noident(ii) (limits.tex:78)', 'major',
    'Computed numbers, two of them at kappa=0, appear inside environments presented as proved: "if all inputs are revealed, this is a fraction 1-9.6*10^-24 ... (kappa=0)" in Prop. 5.1(a), "a direct computation gives the window lambda in (1,1.19*10^4] at kappa=0 and (1,6456] at kappa=30" in Cor. 4.10, and "the losses are 1.0, 0.0112, 0.0112, 0" in Prop. 5.8(ii). The paper\'s own rule is that kappa=0 numbers are illustrations.',
    'Binding note (OUTLINE.md): "Computed results are stated as examples or remarks". Remark 4.8 and intro.tex:48 say that kappa=0 rows are illustrations, not results about any reference machine.',
    'Move each of the three sentences out of the statement into a remark or example immediately after it: "For instance, a direct computation (code in the accompanying repository) gives ... with the machine constant set to 0."')

add('sections/teacher.tex', 'thm:teacher:main and the display before it (lines 65-101)', 'major',
    'Hard to read. The central theorem runs to about a page, with five parts and about 16 auxiliary quantities (psi_c, Phi_1, Phi_2, t*, J_g, J_b, Delta(c), c_hi, Lambda_1, Lambda_2, Lambda_3, Delta_l, gamma_g, j_g, Gamma_g, varrho). They are defined in three places: Def. 4.2, the display before the theorem, and inside parts (ii) and (iii). In part (e) the integer g collides with the subscript g ("good") of pi_g, J_g and kappa_g inside one formula. A reader cannot extract the main statement without working through the appendix.',
    'teacher.tex:83-96 defines Lambda_2, Lambda_3 and Delta_l inside part (ii), and gamma_g, j_g and Gamma_g inside (e), where Gamma_g contains Delta_l, which contains kappa_g. The only plain-language version is the paragraph after the proof idea (teacher.tex:105).',
    'State an informal version first ("Theorem (informal): for c in (2^-m, c_hi), every near-optimal product hypothesis agrees with the parity on more than 3/4 of inputs, fits no better than noise up to O(c(log d+kappa)+delta_S 2^-m), has length d+O(log d+kappa), holds O(log d+kappa) bits about the rule beyond delta_S, and gives the erroneous labels average probability at most 1-u+o(1)"). Collect the constants in a table with one-line meanings. Move (iii)-(iv) into a separate proposition on the lower end of the window. Rename the integer g, e.g. to q.')

# ---------------------------------------------------------------- minor
add('sections/*.tex', 'abstract.tex:3 vs about 120 uses of "Hänni" in the body; teacher.tex:8 (subsection 4.1 title); intro.tex:14,43 ("verdicts")', 'minor',
    'The paper switches between conventions. The abstract and credits say "the author\'s notes", while the body refers to the sole author in the third person throughout: "Hänni\'s sizes" (8 times), "Hänni called the example ... cherry-picked", "This agrees with Hänni\'s assessment", "as Hänni expected", subsection title "Hänni\'s calculation", and a table of "Hänni\'s specific claims ... with verdicts". On an arXiv paper whose only author is Kaarel Hänni, this reads as if an outside party were judging the author\'s claims.',
    'pdftotext of the arXiv-mode build: "Hänni" 124 times, including citations; "the author" 4 times. The binding note allows either "his notes" or "the author\'s", but the paper uses both.',
    'Keep the explanation in the credits paragraph. Replace possessives that need no attribution with neutral phrases ("the original example", "the sizes of the original example [H26]"). Retitle 4.1 "The original calculation". Recast Table 1 as "Questions raised in the earlier notes and where they are answered", with an "Answer" column in place of "Verdict".')

add('bib/core.bib', 'claude2026whatfollows (lines 51-57); cited intro.tex:46, absorb.tex:38, related.tex:43, app-teacher.tex, app-related.tex, discussion.tex:30', 'minor',
    'The earlier report on which Remark 8.7 bases its priority statements is printed as "Claude (Anthropic). What follows from what ... Unpublished report prepared for K. Hänni, 2026. inferential-learning/ in the accompanying repository." It has no URL, and the report itself is marked "Draft; authorship and publication to be decided".',
    'The report is on the public main branch (inferential-learning/paper/main.pdf). Its author line is "Claude (Anthropic)", and its Section 8 is "Simplicity and normativity from imitation" (inferential-learning/paper/sections/simplicity.tex), so the citation is verifiable. The brief says the earlier papers stay as they are.',
    'Give a stable URL to the PDF (with a commit hash) and the section number ("Section 8"). Keep the author as "Claude (Anthropic)" with "Unpublished report", or "Unpublished report prepared with Claude (Anthropic)"; either is honest, and the author should choose.')

add('bib/core.bib', 'vaintrobhanni2026nnbayes (lines 10-15); cited related.tex:29, discussion.tex:13', 'minor',
    'Not verifiable from here. The slides\' URL (kaarelh.github.io/ai/nnbayes-generalization.pdf) does not resolve, and the Paper 1 reviewer found no search hit for the title or an ILIAD 2026 listing. A related arXiv paper by the same authors (2607.05735) exists.',
    'Proxy refused kaarelh.github.io (this review). Paper 1 review bib table, row 25: "unverifiable".',
    'The author, a co-author of the slides, should confirm the title, venue, date and a live URL. If arXiv:2607.05735 contains the result referred to in Remark 8.4, cite it instead or in addition.')

add('bib/core.bib; bib/steep-a.bib; bib/steep-b.bib', 'hoeffding1963probability, grunwald2007suboptimal, ville1939etude, kushilevitz1993learning, milovanov2016algorithmic', 'minor',
    'Small bibliographic fixes, plus entries this review could not re-verify by search.',
    'Paper 1 review (WebSearch today): Hoeffding is JASA 58(301):13-30; Grünwald-Langford is Machine Learning 66(2-3):119-149, doi 10.1007/s10994-007-0716-7; Ville is listed by Numdam as a thesis (Thèses de l\'entre-deux-guerres no. 218, 1939), and the Gauthier-Villars imprint was not confirmed. steep-b.bib: Kushilevitz-Mansour pages were taken from a sibling project because the SIAM snippet showed none. Milovanov: the steeper notes\' reference list says "exact title and pages unverified", while steep-a.bib says "Confirmed: CSR 2016, LNCS 9691, pp. 280-293". The search budget ran out during this review, so cover2006elements, kakutani1948equivalence, koppel1987complexity, koppel1991almost, vitanyi2006meaningful and wenzel2020good were not re-searched. Their data match the writers\' snippet checks and standard records.',
    'Add number = {301} (and the doi) to Hoeffding. Add number = {2--3} and the doi to Grünwald-Langford. Confirm Ville\'s imprint (Monographies des Probabilités, fasc. 3) or cite it as a thesis. Confirm Kushilevitz-Mansour pp. 1331-1348 and add doi 10.1137/0222080. Reconcile Milovanov\'s record (arXiv 1512.04510). Re-check the six entries above once more before submission.')

add('sections/split.tex; sections/app-split.tex', 'split.tex:104 (rem:split:siprograms); app-split.tex:32,36 (p_w); app-split.tex:60,62 (p_s)', 'minor',
    'Notation. Programs are written p ("2^{-lambda|p|}", "p_w", "p_s") in a paper where p is the error density.',
    'NOTATION.md §1, Programs: "Paper 2 writes programs pi and l(pi):=|pi|, because p is Hänni\'s error density there."',
    'Write 2^{-lambda*l(pi)}, pi_w and pi_s.')

add('sections/algstat.tex; app-algstat.tex; app-split.tex; split.tex', 'algstat.tex:45 (rho); app-algstat.tex:20 (u); app-split.tex:85 (M_n); split.tex:90 (set A of programs)', 'minor',
    'Symbols overloaded within one section or appendix. rho is both the product structure function rho^x_D (Def. 7.3) and the integer ceil(-log nu_pi(D)) in Prop. 7.5. u is both the agreement u(pi) of Section 7.3 and an integer index in the proof of Prop. 7.6(i). M_n is a supermartingale in App. E.5, which shares an appendix with Solomonoff\'s M (App. E.4). A is a set of programs in Thm 6.8(ii), while NOTATION.md reserves A for set models.',
    'NOTATION.md §3.3 and §5 fix rho^x_D, u(pi), M and A.',
    'Rename the integer rho to r_D, the index u to v, M_n to Y_n, and the program set in Thm 6.8 to \\mathcal P.')

add('sections/teacher.tex; sections/intro.tex; app-teacher.tex', 'teacher.tex:155; app-teacher.tex:137; intro.tex:17', 'minor',
    'Window endpoints are inconsistent. Cor. 4.10(i) proves its conclusion for lambda in (1, N c_hi) (open), or wherever J_g<Phi_2, but the window is then printed as "(1,1.19*10^4]" and "(1,11945]" (closed). The introduction states the identification conclusions for c in (2^-m, c_hi], whereas Thm 4.7(ii) requires J_g(c)+epsilon < Phi_2(c), which fails at c=c_hi when epsilon=0.',
    'teacher.tex:152: "in particular every lambda in (1, N c_hi)". App. H.4 row 22: "the endpoint can tie".',
    'Print (1, 1.19*10^4) and (1, 6456). In the introduction, write "c in (2^-m, c_hi)" where the identification conclusions are summarised.')

add('sections/limits.tex', 'line 61', 'minor',
    'Wrong rounding of a ratio. The text says the incompressible rule "leaves a window of a factor of about 8000 (kappa=0) or 3800 (kappa=30)", but the kappa=0 ratio is 8453. About 8000 is the ratio of the three-hypothesis window (8037).',
    'teacher.tex:108: "a ratio of 8453 ... (ratio 3837)". The independent arithmetic in scratch/p2-arxiv/numbers_check.out gives 8452 and 3838.',
    'Write "about 8500 (kappa=0) or 3800 (kappa=30)".')

add('sections/absorb.tex', 'rem:absorb:wyeth (iii), line 105', 'minor',
    'The sentence "So ``nothing is lost at lambda=1\'\' holds only relative to the product class" quotes a phrase that has no source in the paper. It is a leftover of an internal correction.',
    'App. H.4 row 5: "private randomness loses nothing" was an earlier statement of the notes, corrected. Binding note: refuted earlier claims appear only where they inform the reader, with no list of internal corrections.',
    'Rephrase: "So the restriction is costless at lambda=1 only relative to the product class, not relative to M_F."')

add('sections/*.tex', 'section 5 title (limits.tex:4) and subsection 5.2 title; limits.tex:6,21,24,102; intro.tex:18; discussion.tex:9,19; app-limits.tex:3; absorb.tex:38', 'minor',
    'Informal register. The paper calls the proposal "the trick" in section and subsection titles ("Limits of the trick", "Which error rules defeat the trick", "Proofs for the limits of the trick") and in five other places. Remark 3.3 says "a dog classifier with millions of bits certainly is" longer than l_U, where "certainly" is unsupported because l_U depends on the machine.',
    'Binding note: "Tone: formal academic register."',
    'Replace "the trick" by "the steeper objective" or "the proposal" and retitle Section 5 "Limits of steeper selection". Replace the dog sentence by "realistic classifiers typically are" or delete it.')

add('sections/app-teacher.tex; app-limits.tex; app-related.tex', 'app-teacher.tex:17,56,125,137,178,216,220; app-limits.tex:10,12,37,53,65,75,102; app-related.tex:46', 'minor',
    'Process residue in the appendices. Script names such as "c7_run2.py" and "c6_revision.py" record the research process (run 2, revision), and "re-run from scratch copies" is internal jargon.',
    'pdftotext of the arXiv-mode build shows these strings on pp. 41-50 and 57.',
    'Refer to the scripts neutrally ("script C7, part (C)") and map numbers to files in the repository README, or rename the files before publishing. Replace "re-run from scratch copies" by "re-run independently".')

add('sections/*.tex', 'setup.tex:8,17,36; absorb.tex:71,112; limits.tex:18,89; split.tex:25,55,97; related.tex:16,22,29; app-absorb.tex:6,67; app-limits.tex:143; app-split.tex:65,99', 'minor',
    'Results of the companion paper are cited by name, e.g. "\\citep[the fresh-noise proposition]{...}", which renders as "(Hänni, 2026a, the fresh-noise proposition)". This is non-standard and hard to look up.',
    'Current numbers in Paper 1 (paper/main.aux, 103-page build): fresh-noise Prop 4.6; per-query Prop 4.7; corollary on SFI^hist Cor 5.18; chain Thm 3.4, shared coin Prop 3.7, remark Rem 3.8; mistake bound Cor 4.4; tape-length bound Prop 3.6; merging Thm 4.3; representation Thm 5.17; time-bounded SFI Thm 8.2; computability Prop 2.24; NN Bayes is function-space Bayes Prop 9.1; "Hänni\'s proposition" Prop 7.1; hashing Rem B.3; conjunction ladder Thm 8.14 with Rem 8.16; open problem in §2.3.',
    'Once both papers are final, cite by number ("[Hän26a, Proposition 4.6]"). Keep the names only as glosses where helpful.')

add('sections/absorb.tex; teacher.tex; limits.tex; algstat.tex; related.tex', 'q:absorb:shared (absorb.tex:111), q:teacher:open (teacher.tex:182), q:limits:open (limits.tex:101), q:algstat:lsc (algstat.tex:50), q:related:open (related.tex:50)', 'minor',
    'Each section ends with an "Open question" paragraph that §9.1 then repeats, and \\cref to these paragraphs renders as "Section x.y".',
    'discussion.tex:15-27 collects the same questions. Binding note: "Open questions go under \'Open problems\'".',
    'Delete the per-section paragraphs, or cut them to one-line pointers to §9.1, and point §9.1 items to the results rather than to the q: labels. This saves about half a page.')

add('main.tex; sections/*.tex', 'whole paper (page map)', 'minor',
    'The paper is long and its structure departs in places from a standard arXiv paper. The main text runs pp. 3-33 (31 pages: introduction 3, setup 3, absorb 4, teacher 6, limits 4, split 3, algstat 3, related 2, discussion 2), against the OUTLINE target of 18-22. The arXiv-mode build has 58 pages in all. Section 8 mixes two new propositions (computable classes) with related work, and page 2 is half empty because \\newpage follows the table of contents.',
    'main.toc: sections start on pp. 3, 6, 9, 13, 19, 23, 26, 29, 31, references on p. 33, appendices on pp. 36-58. The OUTLINE.md page budget is 21 main pages. App. H.7 already lists the move candidates.',
    'Move to the appendices: Example 6.9 (noisy parity illustration), Remark 6.10, Prop. 3.10 (history of inputs only), Remark 5.11 (limitation of the method), Remark 8.7 (relation to the earlier report, keeping one sentence in the introduction), Prop. 8.2 (computability), and the numbers paragraphs after Prop. 5.7 (guard erosion) and Lemma 5.5. Shorten the introduction to at most 2 pages, e.g. by moving Table 1 to the end of the discussion or shortening its rows. Make Section 8 "Related work" only, placing Prop. 8.1 at the end of Section 6 or in an appendix. Drop the per-section open questions and the \\newpage after the table of contents. Consider one figure of the (length, risk) plane with the coin, the good model and the memoriser, and the window on a log-c axis.')

add('sections/absorb.tex; sections/intro.tex', 'absorb.tex:5 ("This is a standard point."); intro.tex:12 ("A standard objection")', 'minor',
    'The absorption point is called "standard" without any citation. The binding note allows pointing to algorithmic statistics.',
    'Binding note (OUTLINE.md): "It is known in algorithmic statistics". Section 7 of the paper discusses the related set-model picture, and Gács-Tromp-Vitányi 2001, Vereshchagin-Vitányi 2004 and Vereshchagin-Shen 2017 are already in the bibliography.',
    'Add a pointer that does not claim more than is checked, e.g. "This is a standard point, closely related to the treatment of two-part codes and sufficient statistics in algorithmic statistics \\citep{gacs2001algorithmic,vereshchagin2017algorithmic}; see Section 7." Do not attribute it to any person.')

add('sections/intro.tex', 'tab:intro:claims row 8 (line 36)', 'minor',
    'The row lists "confident wrong extrapolation" among demonstrated pathologies. Prop. 5.10 shows only that the posterior concentrates on the shortest hypotheses that fit the training data. Confident wrong extrapolation follows only if such a hypothesis is wrong on the unseen set.',
    'limits.tex:95: "if a shorter one fits the training data and is wrong on Q, it is more confidently wrong. No guarantee about unseen properties follows."',
    'Write "possible confident wrong extrapolation off the training support".')

add('sections/discussion.tex', 'lines 7 and 11', 'minor',
    'Two summaries drop qualifiers. Line 7, "near-optimal product hypotheses are the simple model with noise", drops "up to explicit slack". Line 11, "indifferent, up to bounded factors", hides that the factor 2^{2 log(t_n+1)} grows (very slowly) with n and d and that delta* is a random deficiency.',
    'teacher.tex:6: "every near-optimal hypothesis is, up to explicit slack, the simple model with noise". Thm 6.4(iii): odds in [2^{-2log(t_n+1)-kappa}, 2^{k+delta*}].',
    'Line 7: "... are, up to explicit slack, the simple model with noise". Line 11: "up to factors 2^k, 2^{delta*} and a triply logarithmic factor".')

add('sections/intro.tex', 'line 20 (contribution bullet "Computable classes")', 'minor',
    'The bullet says the private-randomness split holds "in every c.e. prefix-free product class" and omits the hypothesis that the class contains a program for the sampler.',
    'related.tex:12, Prop. 8.1(b): "in every countable product class with Kraft weights that contains a program for the sampler".',
    'Add "that contains the sampler".')

add('sections/teacher.tex; app-verification.tex', 'tab:teacher:numbers; App. H.7 ("Rounding")', 'minor',
    'The record states that the upper bounds in Table 2 are rounded to nearest, so their last digit may sit on the unsafe side. Removing the record would drop this caveat silently.',
    'App. H.7, third bullet. For example, c6_revision.out prints "e<=0.199"; a true value of 0.1994 would round to 0.199, below the bound.',
    'Recompute the tables with outward rounding (upward for upper bounds, downward for lower bounds), or state the rounding convention in the caption of Table 2 and in Remark 4.8.')

add('main.tex; preamble.tex', 'hyperref setup; main.tex:23-24', 'minor',
    'The PDF metadata title and author fields are empty, and \\newpage after the table of contents leaves page 2 half empty.',
    'pdfinfo main.pdf: "Title:" and "Author:" are empty. pdftotext page 2 has 10 lines.',
    'Add \\hypersetup{pdftitle={Steeper Simplicity Priors in Solomonoff Function Induction}, pdfauthor={Kaarel H\\"anni}}. Remove the \\newpage, or drop the table of contents.')

add('sections/discussion.tex', 'Acknowledgements (lines 29-30)', 'minor',
    'The acknowledgements meet the binding note but could be tightened for arXiv. "Refereed them adversarially in two rounds" is internal phrasing. The paragraph does not say that the author takes responsibility for the content, which arXiv\'s policy on generative-AI tools expects. Eisenstat\'s example would be better credited as a personal communication.',
    'Binding note: a short paragraph on how the paper was prepared and checked. Title footnote (main.tex:17) already contains the required disclosure.',
    'Suggested text: "This paper was developed and written with extensive assistance from Claude (Anthropic), an AI system. Under the author\'s direction, separate instances of Claude wrote the proofs, the computations and the text, and independently re-checked the proofs and re-implemented the computations in two rounds of review. No human has yet independently checked all of the mathematics; the author takes responsibility for the content. The earlier report [...], whose results are re-derived here, was also prepared with Claude. The author thanks Sam Eisenstat for the coin example (personal communication)."')

add('sections/abstract.tex', 'line 3', 'minor',
    'The abstract leaves out the algorithmic-statistics result (product sophistication exceeds set sophistication by d - O(log d)), which OUTLINE.md item 0 lists. It also uses n without defining it (see also the issue on the population objective).',
    'OUTLINE.md §0: "... the model-randomness split (... product vs set sophistication)". Prop. 7.6(iii).',
    'If space permits after the other abstract fixes, add: "For a noisy random parity the product analogue of Kolmogorov\'s structure function keeps the parity in the model, while set models treat it as noise."')

add('sections/absorb.tex; sections/related.tex', 'rem:absorb:examples (absorb.tex:14); prop:related:computable proof (app-related.tex:5)', 'minor',
    'Two environment types do not match their content. Remark 3.1 has status "proved" and its own proof in App. B.1, so it is a proposition in substance. The proof of Prop. 8.1 reads "By inspection" and lists what each lemma uses, which is closer to a proof sketch. The examples after Prop. 8.1 ("kappa_g is of order d log d and c_hi shrinks by a factor of order log d") are unproved heuristics stated without a label.',
    'Binding note: proof sketches are labelled "Proof sketch", and heuristics are not stated as results. App. B.1: "We prove Remark 3.1."',
    'Make Remark 3.1 a Proposition ("Classes with an absorbing member"). Either expand the proof of Prop. 8.1 into an itemised argument or label it "Proof (sketch)". Prefix the examples with "heuristically".')

for k, it in enumerate(I, 1):
    it['id'] = 'P2A-%02d' % k
json.dump(I, open(sys.argv[1], 'w'), indent=1, ensure_ascii=False)
md = []
for it in I:
    md.append('**%s** [%s] `%s` -- %s\n' % (it['id'], it['severity'], it['file'], it['label_or_line']))
    md.append('* *Problem.* ' + it['problem'])
    md.append('* *Evidence.* ' + it['evidence'])
    md.append('* *Fix.* ' + it['fix'] + '\n')
open(sys.argv[2], 'w').write('\n'.join(md))
from collections import Counter
print(len(I), Counter(i['severity'] for i in I))
